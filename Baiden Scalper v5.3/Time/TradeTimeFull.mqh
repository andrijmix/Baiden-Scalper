#property strict

#ifndef  SECONDS_IN_MINUTE
#define  SECONDS_IN_MINUTE   60
#endif
#ifndef  SECONDS_IN_HOUR
#define  SECONDS_IN_HOUR     3600
#endif
#ifndef  SECONDS_IN_DAY
#define  SECONDS_IN_DAY      86400
#endif
#ifndef  MINUTES_IN_DAY
#define  MINUTES_IN_DAY      1440
#endif
#ifndef  MINUTES_IN_HOUR
#define  MINUTES_IN_HOUR     60
#endif
#ifndef  ROLLOVER_MINUTE
#define  ROLLOVER_MINUTE     1020
#endif
//#define GMT_URL "http://worldclockapi.com/api/json/utc/now"
#define GMT_URL "http://worldtimeapi.org/api/timezone/Etc/UTC"
#include "WebUtils.mqh"

enum DstMode{
   DST_OFF        = 0,  //No DST
   DST_EUROPE     = 1,  //Europe (Alpari)
   DST_NEW_YORK   = 2    //New-York (Tickmill)  
};

struct TradeTimeStruct {
   datetime gmtTime;
   datetime estTime;
   datetime targetTime;
   int weekDayTarget;
   int weekDayBusiness;
   bool isSummerTime;
};

struct TradeTimeStatus {
 
   bool isTradingSessionActive;
   bool isRollover;
   bool isOpenAllowed;
   bool isCloseAllowed;
   int activeSessionWeekDay;        //1 for Monday through 5 for Friday, -1 when session is not active
   int minutesSinceSessionFinished; //0 when session is active
   int minutesToSessionFinish;      //0 when session is not active
   int minutesToNextSession;        //0 when session is active
   int minutesToRollover;
   TradeTimeStruct tradeTimeStruct;
   
   TradeTimeStatus() {
      Reset();
   } 
   void Reset() {
      isTradingSessionActive = false;
      isRollover = false;
      isOpenAllowed = false;
      isCloseAllowed = true;
      activeSessionWeekDay = -1;
      minutesSinceSessionFinished = INT_MAX;
      minutesToSessionFinish = 0;
      minutesToNextSession = INT_MAX;
      minutesToRollover = MINUTES_IN_DAY;
   }  
};
struct TradeInterval {
   int startMinute;
   int endMinute;
   TradeInterval() : startMinute(0), endMinute(0){};
};
struct DaySchedule {
   TradeInterval intervals[];
   void Add(TradeInterval &_interval) {
      int pos = ArraySize(intervals);
      ArrayResize(intervals, pos + 1);
      intervals[pos].startMinute = _interval.startMinute;
      intervals[pos].endMinute = _interval.endMinute;
   }
};
class TradeTimeManager {

   static int nyMarchDSTon[];
   static int euMarchDSTon[];
   static int nyNovemberDSToff[];
   static int euOctoberDSToff[];
   DaySchedule weekDaysWinter[7];
   DaySchedule weekDaysSummer[7];
   bool skipMonths[12];
   int christmasBreakStart;
   int christmasBreakEnd;
   int liveGMTOffset;
   int brokerGMTOffset;
   int targetGMTOffset;
   DstMode targetDSTMode;
   DstMode brokerDSTMode;
   bool rolloverOpen;
   bool rolloverClose;
   int rolloverFreezeStart;
   int rolloverFreezeFinish;
   datetime lastGMTOffsetVerificationTime;
   bool autoGmt;
   TradeTimeStatus lastStatus;
   int lastCheckMinute; 
   datetime lastCheckTime;
   bool isRoundTheClock;  
   
   void ParseSkipMonths(const string _skipMonths) {
      for(int i = 0; i < 12; i++)
         skipMonths[i] = false;
      if(StringLen(_skipMonths) > 0) {
         string skips[];
         StringSplit(_skipMonths, ',', skips);
         for(int i = 0; i < ArraySize(skips); i++) {
            int skip = (int)StringToInteger(skips[i]);
            if(skip > 0 && skip < 13) {
               Print("Month ", skips[i], " will be skipped");
               skipMonths[skip - 1] = true;
            } else {
               Print("Invalid month: ", skips[i], ", acceptable values 1-12");
            } 
         }   
      }
   }
public:
   TradeTimeManager(const bool _autoGmt,
                    const int _brokerGmtOffset,
                    const DstMode _brokerDstMode,
                    const int _targetGmtOffset,
                    const DstMode _targetDstMode,
                    const string _skipMonths,
                    const int _christmasBreakStart,
                    const int _christmasBreakEnd) {
      logger.Debug("Trading round the clock");
      autoGmt = _autoGmt;
      brokerGMTOffset = _brokerGmtOffset;
      brokerDSTMode  = _brokerDstMode;
      targetGMTOffset = _targetGmtOffset;
      targetDSTMode = _targetDstMode;
      liveGMTOffset = _brokerGmtOffset;
      isRoundTheClock = true;
      lastStatus.isOpenAllowed = true;
      lastStatus.isCloseAllowed = true;
      lastStatus.isTradingSessionActive = true;
      lastStatus.minutesSinceSessionFinished = 0;
      christmasBreakStart = _christmasBreakStart;
      christmasBreakEnd = _christmasBreakEnd;
      ParseSkipMonths(_skipMonths);
      VerifyGMTOffset();
   }   
   TradeTimeManager(const string _sunday, 
                    const string _monday, 
                    const string _tuesday,
                    const string _wednesday,
                    const string _thursday,
                    const string _friday,
                    const bool _autoGmt,
                    const int _brokerGmtOffset,
                    const DstMode _brokerDstMode,
                    const int _targetGmtOffset,
                    const DstMode _targetDstMode,
                    const bool _rolloverOpen,
                    const bool _rolloverClose,
                    const int _rolloverMinutesBefore,
                    const int _rolloverMinutesAfter,
                    const string _skipMonths,
                    const int _christmasBreakStart,
                    const int _christmasBreakEnd) {
      logger.Debug("Trading on winter schedule all year");
      weekDaysWinter[0] = ParseDaySchedule(_sunday);
      weekDaysWinter[1] = ParseDaySchedule(_monday);
      weekDaysWinter[2] = ParseDaySchedule(_tuesday);
      weekDaysWinter[3] = ParseDaySchedule(_wednesday);
      weekDaysWinter[4] = ParseDaySchedule(_thursday);
      weekDaysWinter[5] = ParseDaySchedule(_friday);
      weekDaysSummer[0] = weekDaysWinter[0];
      weekDaysSummer[1] = weekDaysWinter[1];
      weekDaysSummer[2] = weekDaysWinter[2];
      weekDaysSummer[3] = weekDaysWinter[3];
      weekDaysSummer[4] = weekDaysWinter[4];
      weekDaysSummer[5] = weekDaysWinter[5];
      autoGmt = _autoGmt;
      brokerGMTOffset = _brokerGmtOffset;
      brokerDSTMode  = _brokerDstMode;
      targetGMTOffset = _targetGmtOffset;
      targetDSTMode = _targetDstMode;
      rolloverOpen = _rolloverOpen;
      rolloverClose = _rolloverClose;
      liveGMTOffset = _brokerGmtOffset;
      lastGMTOffsetVerificationTime = 0;
      rolloverFreezeStart = (ROLLOVER_MINUTE - _rolloverMinutesBefore + 1440) % 1440;
      rolloverFreezeFinish = (ROLLOVER_MINUTE + _rolloverMinutesAfter + 1440) % 1440;
      lastCheckTime = 0;
      lastCheckMinute = 0;
      christmasBreakStart = _christmasBreakStart;
      christmasBreakEnd = _christmasBreakEnd;
      ParseSkipMonths(_skipMonths);
      VerifyGMTOffset();
   }
   TradeTimeManager(const string _sundayWinter, 
                    const string _sundaySummer, 
                    const string _mondayWinter, 
                    const string _mondaySummer, 
                    const string _tuesdayWinter,
                    const string _tuesdaySummer,
                    const string _wednesdayWinter,
                    const string _wednesdaySummer,
                    const string _thursdayWinter,
                    const string _thursdaySummer,
                    const string _fridayWinter,
                    const string _fridaySummer,
                    const bool _autoGmt,
                    const int _brokerGmtOffset,
                    const DstMode _brokerDstMode,
                    const int _targetGmtOffset,
                    const DstMode _targetDstMode,
                    const bool _rolloverOpen,
                    const bool _rolloverClose,
                    const int _rolloverMinutesBefore,
                    const int _rolloverMinutesAfter,
                    const string _skipMonths,
                    const int _christmasBreakStart,
                    const int _christmasBreakEnd) {
      logger.Debug("Trading on separate schedules on winter and summer");
      weekDaysWinter[0] = ParseDaySchedule(_sundayWinter);
      weekDaysWinter[1] = ParseDaySchedule(_mondayWinter);
      weekDaysWinter[2] = ParseDaySchedule(_tuesdayWinter);
      weekDaysWinter[3] = ParseDaySchedule(_wednesdayWinter);
      weekDaysWinter[4] = ParseDaySchedule(_thursdayWinter);
      weekDaysWinter[5] = ParseDaySchedule(_fridayWinter);
      weekDaysSummer[0] = ParseDaySchedule(_sundaySummer);
      weekDaysSummer[1] = ParseDaySchedule(_mondaySummer);
      weekDaysSummer[2] = ParseDaySchedule(_tuesdaySummer);
      weekDaysSummer[3] = ParseDaySchedule(_wednesdaySummer);
      weekDaysSummer[4] = ParseDaySchedule(_thursdaySummer);
      weekDaysSummer[5] = ParseDaySchedule(_fridaySummer);
      autoGmt = _autoGmt;
      brokerGMTOffset = _brokerGmtOffset;
      brokerDSTMode  = _brokerDstMode;
      targetGMTOffset = _targetGmtOffset;
      targetDSTMode = _targetDstMode;
      rolloverOpen = _rolloverOpen;
      rolloverClose = _rolloverClose;
      liveGMTOffset = _brokerGmtOffset;
      lastGMTOffsetVerificationTime = 0;
      lastCheckTime = 0;
      lastCheckMinute = 0;

      rolloverFreezeStart = (ROLLOVER_MINUTE - _rolloverMinutesBefore + 1440) % 1440;
      rolloverFreezeFinish = (ROLLOVER_MINUTE + _rolloverMinutesAfter + 1440) % 1440;
      christmasBreakStart = _christmasBreakStart;
      christmasBreakEnd = _christmasBreakEnd;
      ParseSkipMonths(_skipMonths);
      VerifyGMTOffset();
   }
   TradeTimeManager(const DaySchedule &_sundayWinter, 
                    const DaySchedule &_sundaySummer, 
                    const DaySchedule &_mondayWinter, 
                    const DaySchedule &_mondaySummer, 
                    const DaySchedule &_tuesdayWinter,
                    const DaySchedule &_tuesdaySummer,
                    const DaySchedule &_wednesdayWinter,
                    const DaySchedule &_wednesdaySummer,
                    const DaySchedule &_thursdayWinter,
                    const DaySchedule &_thursdaySummer,
                    const DaySchedule &_fridayWinter,
                    const DaySchedule &_fridaySummer,
                    const bool _autoGmt,
                    const int _brokerGmtOffset,
                    const DstMode _brokerDstMode,
                    const int _targetGmtOffset,
                    const DstMode _targetDstMode,
                    const bool _rolloverOpen,
                    const bool _rolloverClose,
                    const int _rolloverMinutesBefore,
                    const int _rolloverMinutesAfter,
                    const string _skipMonths,
                    const int _christmasBreakStart,
                    const int _christmasBreakEnd) {
      logger.Debug("Trading on separate schedules on winter and summer");
      weekDaysWinter[0] = _sundayWinter;
      weekDaysWinter[1] = _mondayWinter;
      weekDaysWinter[2] = _tuesdayWinter;
      weekDaysWinter[3] = _wednesdayWinter;
      weekDaysWinter[4] = _thursdayWinter;
      weekDaysWinter[5] = _fridayWinter;
      weekDaysSummer[0] = _sundaySummer;
      weekDaysSummer[1] = _mondaySummer;
      weekDaysSummer[2] = _tuesdaySummer;
      weekDaysSummer[3] = _wednesdaySummer;
      weekDaysSummer[4] = _thursdaySummer;
      weekDaysSummer[5] = _fridaySummer;
      autoGmt = _autoGmt;
      brokerGMTOffset = _brokerGmtOffset;
      brokerDSTMode  = _brokerDstMode;
      targetGMTOffset = _targetGmtOffset;
      targetDSTMode = _targetDstMode;
      rolloverOpen = _rolloverOpen;
      rolloverClose = _rolloverClose;
      liveGMTOffset = _brokerGmtOffset;
      lastGMTOffsetVerificationTime = 0;
      rolloverFreezeStart = (ROLLOVER_MINUTE - _rolloverMinutesBefore + 1440) % 1440;
      rolloverFreezeFinish = (ROLLOVER_MINUTE + _rolloverMinutesAfter + 1440) % 1440;
      lastCheckTime = 0;
      lastCheckMinute = 0;
      christmasBreakStart = _christmasBreakStart;
      christmasBreakEnd = _christmasBreakEnd;
      ParseSkipMonths(_skipMonths);
      VerifyGMTOffset();
   }
   TradeTimeManager(const DaySchedule &_oneSchedule, 
                    const bool _autoGmt,
                    const int _brokerGmtOffset,
                    const DstMode _brokerDstMode,
                    const int _targetGmtOffset,
                    const DstMode _targetDstMode,
                    const bool _rolloverOpen,
                    const bool _rolloverClose,
                    const int _rolloverMinutesBefore,
                    const int _rolloverMinutesAfter,
                    const string _skipMonths,
                    const int _christmasBreakStart,
                    const int _christmasBreakEnd) {
      logger.Debug("Trading on same schedule every day");
      weekDaysWinter[0] = _oneSchedule;
      weekDaysWinter[1] = _oneSchedule;
      weekDaysWinter[2] = _oneSchedule;
      weekDaysWinter[3] = _oneSchedule;
      weekDaysWinter[4] = _oneSchedule;
      weekDaysWinter[5] = _oneSchedule;
      weekDaysSummer[0] = _oneSchedule;
      weekDaysSummer[1] = _oneSchedule;
      weekDaysSummer[2] = _oneSchedule;
      weekDaysSummer[3] = _oneSchedule;
      weekDaysSummer[4] = _oneSchedule;
      weekDaysSummer[5] = _oneSchedule;
      autoGmt = _autoGmt;
      brokerGMTOffset = _brokerGmtOffset;
      brokerDSTMode  = _brokerDstMode;
      targetGMTOffset = _targetGmtOffset;
      targetDSTMode = _targetDstMode;
      rolloverOpen = _rolloverOpen;
      rolloverClose = _rolloverClose;
      liveGMTOffset = _brokerGmtOffset;
      lastGMTOffsetVerificationTime = 0;
      rolloverFreezeStart = (ROLLOVER_MINUTE - _rolloverMinutesBefore + 1440) % 1440;
      rolloverFreezeFinish = (ROLLOVER_MINUTE + _rolloverMinutesAfter + 1440) % 1440;
      lastCheckTime = 0;
      lastCheckMinute = 0;
      christmasBreakStart = _christmasBreakStart;
      christmasBreakEnd = _christmasBreakEnd;
      ParseSkipMonths(_skipMonths);
      VerifyGMTOffset();
   }

   void AddIntervalWinter(TradeInterval& _interval) {
      logger.Debug("Adding winter interval from " + IntegerToString(_interval.startMinute) + " to " + IntegerToString(_interval.endMinute));
      for(int day = 0; day < 6; day++)
         weekDaysWinter[day].Add(_interval);
   }
   void AddIntervalSummer(TradeInterval& _interval) {
      logger.Debug("Adding summer interval from " + IntegerToString(_interval.startMinute) + " to " + IntegerToString(_interval.endMinute));
      for(int day = 0; day < 6; day++)
         weekDaysSummer[day].Add(_interval);
   }
   int GetLiveGMTOffset() {
      return (liveGMTOffset);
   }   

   TradeTimeStruct GetTradeTimeStruct() {
      TradeTimeStruct result;
      VerifyGMTOffset();
      result.gmtTime = TimeCurrent() - liveGMTOffset * SECONDS_IN_HOUR;
      result.targetTime = result.gmtTime + targetGMTOffset * SECONDS_IN_HOUR;
      result.isSummerTime = IsSummerTime(result.targetTime, targetDSTMode);
      if(result.isSummerTime)
         result.targetTime += SECONDS_IN_HOUR;
      result.weekDayTarget = TimeDayOfWeek(result.targetTime);
      result.estTime = result.gmtTime - 5 * SECONDS_IN_HOUR;
      if(IsSummerTime(result.estTime, DST_NEW_YORK))
         result.estTime += SECONDS_IN_HOUR;
      result.weekDayBusiness = TimeDayOfWeek(result.estTime + 7 * SECONDS_IN_HOUR);
      return (result);
   }
      
   TradeTimeStatus GetTradeTimeStatus() {
      if(lastGMTOffsetVerificationTime == 0) {
         lastStatus.tradeTimeStruct = GetTradeTimeStruct();
         if(lastGMTOffsetVerificationTime == 0)
            return (lastStatus);
      }
      if(TimeCurrent() - lastCheckTime >= SECONDS_IN_MINUTE || Minute() != lastCheckMinute) {
         lastCheckTime = TimeCurrent();
         lastCheckMinute = Minute();
         lastStatus.tradeTimeStruct = GetTradeTimeStruct();
         lastStatus.minutesToRollover = (17 * SECONDS_IN_HOUR - (int)lastStatus.tradeTimeStruct.estTime % SECONDS_IN_DAY) / 60;
         if(lastStatus.minutesToRollover < 0)
            lastStatus.minutesToRollover += MINUTES_IN_DAY;
         if(isRoundTheClock) {
//            Print("Round the clock. Christmas: ", IsChristmasSeason(), ", IsTradingMonth: ", IsTradingMonth());
            lastStatus.activeSessionWeekDay = lastStatus.tradeTimeStruct.weekDayTarget;
            if(IsChristmasSeason() || !IsTradingMonth()) {
               lastStatus.Reset();
            } else {
               lastStatus.isOpenAllowed = true;
               lastStatus.isCloseAllowed = true;
               lastStatus.isTradingSessionActive = true;
               lastStatus.minutesSinceSessionFinished = 0;
            }   
         } else {
            lastStatus.Reset();
            if(IsChristmasSeason() || !IsTradingMonth())
               return (lastStatus);         
            int weekDay = lastStatus.tradeTimeStruct.weekDayTarget;
            int minute = TimeHour(lastStatus.tradeTimeStruct.targetTime) * MINUTES_IN_HOUR + TimeMinute(lastStatus.tradeTimeStruct.targetTime);
            DaySchedule schedule = weekDaysWinter[weekDay];
            if(lastStatus.tradeTimeStruct.isSummerTime)
               schedule = weekDaysSummer[weekDay]; 
            for(int i = 0; i < ArraySize(schedule.intervals); i++){
               if((schedule.intervals[i].startMinute < schedule.intervals[i].endMinute && minute >= schedule.intervals[i].startMinute && minute < schedule.intervals[i].endMinute)
               || (schedule.intervals[i].startMinute > schedule.intervals[i].endMinute && (minute >= schedule.intervals[i].startMinute || minute < schedule.intervals[i].endMinute))) {
                  lastStatus.isTradingSessionActive = true;
                  lastStatus.activeSessionWeekDay = weekDay;
                  lastStatus.isCloseAllowed = true;
                  lastStatus.isOpenAllowed = true;
                  lastStatus.minutesSinceSessionFinished = 0;
                  if(schedule.intervals[i].startMinute < schedule.intervals[i].endMinute || minute < schedule.intervals[i].startMinute)
                     lastStatus.minutesToSessionFinish = schedule.intervals[i].endMinute - minute;
                  else
                     lastStatus.minutesToSessionFinish = schedule.intervals[i].endMinute + minute - schedule.intervals[i].startMinute;
                  lastStatus.minutesToNextSession = 0;
                  break;
               } else {
                  int minutesTo = schedule.intervals[i].startMinute - minute;
                  if(minutesTo >= 0 && minutesTo < lastStatus.minutesToNextSession)
                     lastStatus.minutesToNextSession = minutesTo;
                  if(schedule.intervals[i].endMinute > schedule.intervals[i].startMinute) {
                     int minutesSince = minute - schedule.intervals[i].endMinute;
                     if(minutesSince >= 0 && minutesSince < lastStatus.minutesSinceSessionFinished){
      //                  Print("The weekday itself yeilded the last session value: ", minutesSince);
                        lastStatus.minutesSinceSessionFinished = minutesSince;
                     }
                  }
               }
            }
            int tmpWeekDay = weekDay;
            if(!lastStatus.isTradingSessionActive) {
               if(weekDay > 1) {
                  tmpWeekDay--;
                  schedule = weekDaysWinter[weekDay - 1];
                  if(lastStatus.tradeTimeStruct.isSummerTime)
                     schedule = weekDaysSummer[weekDay - 1];
                  for(int i = 0; i < ArraySize(schedule.intervals); i++){
                     if(schedule.intervals[i].startMinute > schedule.intervals[i].endMinute && minute < schedule.intervals[i].endMinute) {
                        lastStatus.isTradingSessionActive = true;
                        lastStatus.activeSessionWeekDay = weekDay - 1;
                        lastStatus.isCloseAllowed = true;
                        lastStatus.isOpenAllowed = true;
                        lastStatus.minutesSinceSessionFinished = 0;
                        lastStatus.minutesToSessionFinish = schedule.intervals[i].endMinute - minute;
                        lastStatus.minutesToNextSession = 0;
                        break;
                     } else {
                        int minutesSince = minute - schedule.intervals[i].endMinute + (schedule.intervals[i].endMinute > schedule.intervals[i].startMinute ? MINUTES_IN_DAY : 0);
                        if(minutesSince >= 0 && minutesSince < lastStatus.minutesSinceSessionFinished){
      //                     Print("Previous day's session used for the last session value: ", minutesSince);
                           lastStatus.minutesSinceSessionFinished = minutesSince;
                        }
                     }
                  }
               }
            }
            if(lastStatus.minutesSinceSessionFinished == INT_MAX) {
               //here we're looking to populate minutes since previous session  
               int shift = weekDay - tmpWeekDay;
               while(lastStatus.minutesSinceSessionFinished == INT_MAX && shift < 7) {
                  tmpWeekDay--;
                  if(tmpWeekDay < 0)
                     tmpWeekDay = 6;
                  schedule = weekDaysWinter[tmpWeekDay];
                  if(lastStatus.tradeTimeStruct.isSummerTime)
                     schedule = weekDaysSummer[tmpWeekDay];
                  
                  for(int i = 0; i < ArraySize(schedule.intervals); i++){
                     int minutesSince = minute - schedule.intervals[i].endMinute + (shift + (schedule.intervals[i].endMinute > schedule.intervals[i].startMinute ? 1 : 0)) * MINUTES_IN_DAY;
                     if(minutesSince < lastStatus.minutesSinceSessionFinished){
      //                  Print("Last session value came from scan: ", minutesSince, "; shift = ", shift, "; tmpWeekDay = ", tmpWeekDay);
                        lastStatus.minutesSinceSessionFinished = minutesSince;
                     }
                  }
                  shift++;
               }
            }
            if(lastStatus.minutesToNextSession == INT_MAX) {
               //here we're looking to populate minutes to next session 
               tmpWeekDay = weekDay;
               int shift = 1;
               while(lastStatus.minutesToNextSession == INT_MAX && shift < 7) {
                  tmpWeekDay++;
                  if(tmpWeekDay > 6)
                     tmpWeekDay = 0;
                  schedule = weekDaysWinter[tmpWeekDay];
                  if(lastStatus.tradeTimeStruct.isSummerTime)
                     schedule = weekDaysSummer[tmpWeekDay];
                  for(int i = 0; i < ArraySize(schedule.intervals); i++){
                     int minutesTo = schedule.intervals[i].startMinute - minute + shift * MINUTES_IN_DAY;
                     if(minutesTo < lastStatus.minutesToNextSession)
                        lastStatus.minutesToNextSession = minutesTo;
                  }
                  shift++;
               }
            }
         }
         int estMinute = TimeHour(lastStatus.tradeTimeStruct.estTime) * MINUTES_IN_HOUR + TimeMinute(lastStatus.tradeTimeStruct.estTime);
         if((rolloverFreezeStart < rolloverFreezeFinish && estMinute >= rolloverFreezeStart && estMinute < rolloverFreezeFinish)
         || (rolloverFreezeStart > rolloverFreezeFinish && (estMinute >= rolloverFreezeStart || estMinute < rolloverFreezeFinish))){
            lastStatus.isRollover = true;
            lastStatus.isOpenAllowed = lastStatus.isOpenAllowed && rolloverOpen;
            lastStatus.isCloseAllowed = lastStatus.isCloseAllowed && rolloverClose;
         }
      }
      return (lastStatus);
   }

   bool IsChristmasSeason() {
//      Print("Target time: ", TimeToStr(lastStatus.tradeTimeStruct.targetTime, TIME_DATE), ", TimeMonth: ", TimeMonth(lastStatus.tradeTimeStruct.targetTime),
//            ", TimeDay: ", TimeDay(lastStatus.tradeTimeStruct.targetTime));
      return ((TimeMonth(lastStatus.tradeTimeStruct.targetTime) == 12 && TimeDay(lastStatus.tradeTimeStruct.targetTime) > christmasBreakStart) 
            || (TimeMonth(lastStatus.tradeTimeStruct.targetTime) == 1 && TimeDay(lastStatus.tradeTimeStruct.targetTime) < christmasBreakEnd));
   }
   bool IsTradingMonth() {
      return (!skipMonths[TimeMonth(lastStatus.tradeTimeStruct.targetTime) - 1]);
   }

private:

   static TradeInterval ParseInterval(string _interval) {
      TradeInterval result;
      int pos = StringFind(_interval, "-");
      if(pos > 0) {
         string strStart = StringTrimRight(StringTrimLeft(StringSubstr(_interval, 0, pos)));
         string strEnd   = StringTrimRight(StringTrimLeft(StringSubstr(_interval, pos + 1, StringLen(_interval) - pos - 1)));
         Print("Parsing trade interval: start=" + strStart + "; end=" + strEnd);
         result.startMinute = ParseMinute(strStart);
         result.endMinute = ParseMinute(strEnd);
         Print("Parsed interval starting from ", result.startMinute, " minute of the day, ending by ", result.endMinute, " minute of the day");
      }
      return (result);      
   }

   static DaySchedule ParseDaySchedule(string _schedule) {
      DaySchedule result();
      if(StringLen(_schedule) > 0) {
         string split[];
         StringSplit(_schedule, ',', split);
         for(int i = 0; i < ArraySize(split); i++)
            result.Add(ParseInterval(split[i]));
      }
      return (result);
   }

   static int ParseMinute(string _time){
      int pos = StringFind(_time, ":", 0);
      int hour = (int)StrToInteger(StringSubstr(_time, 0, pos)) % 24;
      int minute = (int)StringToInteger(StringSubstr(_time, pos + 1, StringLen(_time) - pos)) % 60;
      return (hour * MINUTES_IN_HOUR + minute);
   }
   void VerifyGMTOffset() {
      datetime serverGmtTime = TimeGMT();
      int mt4GMToffset = brokerGMTOffset + (IsSummerTime(serverGmtTime, brokerDSTMode) ? 1 : 0);
      if (!IsTesting() && autoGmt){
         if (!(IsConnected())){
            Print("Terminal is not connected. Will wait for it to be online to verify GMT Offset");
            return;
         }
         if (TimeDayOfWeek(TimeCurrent()) >= 5 && (TimeDayOfWeek(TimeGMT()) == 6 || TimeDayOfWeek(TimeGMT()) <= 1))   
            return;
         if(TimeCurrent() - lastGMTOffsetVerificationTime < 5 * SECONDS_IN_MINUTE)
            return;
         mt4GMToffset = StrToInteger(DoubleToStr(MathRound((TimeCurrent() - serverGmtTime + 5 * SECONDS_IN_MINUTE) / SECONDS_IN_HOUR)));
         if(lastGMTOffsetVerificationTime == 0) {
            datetime webGmtTime = GetGMTTimeFromWeb();
            if(webGmtTime == 0) {
               Alert("Failed to fetch date from the web server, the expert will have to follow broker's GMT time blindly");
            } else {
               int webGmtOffset = StrToInteger(DoubleToStr(MathRound((TimeCurrent() - webGmtTime + 15 * SECONDS_IN_MINUTE) / SECONDS_IN_HOUR)));
               if (MathAbs(webGmtTime - serverGmtTime) >= SECONDS_IN_MINUTE * 5)
                  Alert("There is a difference of at least five minutes between MT4 GMT time: " + TimeToStr(serverGmtTime, TIME_DATE|TIME_MINUTES) + "\n"
                      + "and GMT time from web: " + TimeToStr(webGmtTime, TIME_DATE|TIME_MINUTES) + "\n"
                      + "Please check your local PC time settings. \nIt should be synced with the correct local time (not necessarily GMT)");
               if (webGmtOffset - mt4GMToffset != 0)
                  Alert("There is a difference between GMT time from broker MT4 GMT offset and GMT offset determined from server. \nPlease check your local PC time settings. \nIt should be synced with the correct local time (not necessarily GMT). \nWeb: " + TimeToString(webGmtTime,3) + ", offset: " + IntegerToString(webGmtOffset,0,32) + "\nMT4: " + TimeToString(serverGmtTime,3) + ", offset: " + IntegerToString(mt4GMToffset,0,32)); 
               Print("GMT offset from server: ",webGmtOffset," | webTimeGMT: ",webGmtTime," | broker: ",TimeCurrent()," | MT4 GMT: ",serverGmtTime," | local: ",TimeLocal()); 
            }
         }
      }
      if (mt4GMToffset >  12)
         mt4GMToffset = 12;
      else if (mt4GMToffset < -12)
         mt4GMToffset = -12;
      if(liveGMTOffset != mt4GMToffset) {
         if(lastGMTOffsetVerificationTime > 0 && !IsTesting() && autoGmt) {
            datetime webGmtTime = GetGMTTimeFromWeb();
            if(webGmtTime == 0) {
               Alert("GMT offset changed from " + IntegerToString(liveGMTOffset,0,32) + " to " + IntegerToString(mt4GMToffset,0,32) + ". \nThis should only happen when server time \nis changed due to daylight saving time.\n"
                   + "Expert failed to fetch GMT time from web for verification, will fall back to MT4 GMT Time provided."); 
               liveGMTOffset = mt4GMToffset;
            } else {
               int webGmtOffset = StrToInteger(DoubleToStr(MathRound((TimeCurrent() - webGmtTime + 15 * SECONDS_IN_MINUTE) / SECONDS_IN_HOUR)));
               if (MathAbs(webGmtTime - serverGmtTime) >= SECONDS_IN_MINUTE * 5) {
                  Print("There is a difference of at least five minutes between MT4 GMT time: " + TimeToStr(serverGmtTime, TIME_DATE|TIME_MINUTES) + "\n"
                      + "and GMT time from web: " + TimeToStr(webGmtTime, TIME_DATE|TIME_MINUTES) + "\n"
                      + "It suggests a foul play by the broker tweaking GMT Time in the middle of the trading session, ignoring...");
               } else {
                  Alert("GMT offset changed from " + IntegerToString(liveGMTOffset,0,32) + " to " + IntegerToString(mt4GMToffset,0,32) + ". \nThis should only happen when server time \nis changed due to daylight saving time.\n"
                      + "This change has been verified with the server and accepted"); 
                  liveGMTOffset = mt4GMToffset;
               }
               Print("GMT offset from server: ",webGmtOffset," | webTimeGMT: ",webGmtTime," | broker: ",TimeCurrent()," | MT4 GMT: ",serverGmtTime," | local: ",TimeLocal()); 
            }
         } else {
            Print("GMT offset changed from " + IntegerToString(liveGMTOffset,0,32) + " to " + IntegerToString(mt4GMToffset,0,32) + ". Switching daylight saving time.");
            liveGMTOffset = mt4GMToffset;
         }
         Print("Live GMT offset: ", mt4GMToffset," | Broker GMT offset: ", brokerGMTOffset, " | DST: ", (IsSummerTime(serverGmtTime, brokerDSTMode) ? "ON" : "OFF"), " | broker: ",TimeCurrent()," | MT4 GMT: ",TimeGMT()," | local: ",TimeLocal()); 
      }
      brokerGMTOffset = liveGMTOffset - (IsSummerTime(serverGmtTime, brokerDSTMode) ? 1 : 0);
      lastGMTOffsetVerificationTime = TimeCurrent();
   }
//<<==VerifyGMTOffset <<==
   datetime GetGMTTimeFromWeb() {
      string responseStr = CWebUtils::Get(GMT_URL);
      Print("Got this from web:", responseStr);
      string gmtTimeStr = StringSubstr(responseStr, StringFind(responseStr, "datetime\":\"") + 11, 19);
      StringReplace(gmtTimeStr, "T", " ");
      StringReplace(gmtTimeStr, "-", ".");
      Print("Substring is: "+ gmtTimeStr);
      datetime webGMTTime = StrToTime(gmtTimeStr);
      Print("Parsed GMT time from worldclockapi.org: ", webGMTTime);
      return (webGMTTime);
   }
   int GetDSTOnDayOfMonth(int _year, DstMode _mode) {
      if(_year < 2010) {
         switch(_mode) {
         case DST_NEW_YORK:
            return (11);
         case DST_EUROPE:
            return (25);
         default:
            return (32);
         }
      }
      switch(_mode) {
      case DST_NEW_YORK:
         return (nyMarchDSTon[_year - 2010]);
      case DST_EUROPE:
         return (euMarchDSTon[_year - 2010]);
      default:
         return (32);
      }
   }
   int GetDSTOffDayOfMonth(int _year, DstMode _mode) {
      if(_year < 2010) {
         switch(_mode) {
         case DST_NEW_YORK:
            return (11);
         case DST_EUROPE:
            return (25);
         default:
            return (32);
         }
      }
      switch(_mode) {
      case DST_NEW_YORK:
         return (nyNovemberDSToff[_year - 2010]);
      case DST_EUROPE:
         return (euOctoberDSToff[_year - 2010]);
      default:
         return (32);
      }
   }
   bool IsSummerTime(datetime _gmtTime, DstMode _mode) {
      switch(_mode) {
      case DST_NEW_YORK:
         return((TimeMonth(_gmtTime) > 3 && TimeMonth(_gmtTime) < 11) 
               || (TimeMonth(_gmtTime) == 3 && TimeDay(_gmtTime) >= GetDSTOnDayOfMonth(TimeYear(_gmtTime), DST_NEW_YORK)) 
               || (TimeMonth(_gmtTime) == 11 && TimeDay(_gmtTime) < GetDSTOffDayOfMonth(TimeYear(_gmtTime), DST_NEW_YORK)));
      case DST_EUROPE:
         return((TimeMonth(_gmtTime) > 3 && TimeMonth(_gmtTime) < 10) 
               || (TimeMonth(_gmtTime) == 3 && TimeDay(_gmtTime) >= GetDSTOnDayOfMonth(TimeYear(_gmtTime), DST_EUROPE)) 
               || (TimeMonth(_gmtTime) == 10 && TimeDay(_gmtTime) < GetDSTOffDayOfMonth(TimeYear(_gmtTime), DST_EUROPE)));
      }      
      return (false);
   }
   
};
static int TradeTimeManager::nyMarchDSTon[]      = {14, 13, 11, 10, 9, 8, 13, 12, 11, 10, 8, 14, 13, 12, 10, 9, 8, 14, 12, 11, 10};
static int TradeTimeManager::euMarchDSTon[]      = {28, 27, 25, 31, 30, 29, 27, 26, 25, 31, 29, 28, 27, 26, 31, 30, 29, 28, 26, 25, 31};
static int TradeTimeManager::nyNovemberDSToff[]  = {7, 6, 4, 3, 2, 1, 6, 5, 4, 3, 1, 7, 6, 5, 3, 2, 1, 7, 5, 4, 3};
static int TradeTimeManager::euOctoberDSToff[]   = {31, 30, 28, 27, 26, 25, 30, 29, 28, 27, 25, 31, 30, 29, 27, 26, 25, 31, 29, 28, 27};
 
TradeTimeManager*  CreateTradeTimeManager(const bool _tradeRoundTheClock,
                                          const bool _autoGMT,
                                          const int _brokerGMTOffsetWinter, 
                                          const DstMode _brokerDstMode,
                                          const int _targetGMTOffsetWinter,
                                          const DstMode _targetDstMode,
                                          const string _sundayTradeIntervalsW,
                                          const string _mondayTradeIntervalsW,
                                          const string _tuesdayTradeIntervalsW,
                                          const string _wednesdayTradeIntervalsW,
                                          const string _thursdayTradeIntervalsW,
                                          const string _fridayTradeIntervalsW,
                                          const int _startTradeHourW,
                                          const int _startTradeMinuteW,
                                          const int _durationMinutesW,
                                          const bool _useWinterScheduleAllYear, 
                                          const string _sundayTradeIntervalsS,
                                          const string _mondayTradeIntervalsS,
                                          const string _tuesdayTradeIntervalsS,
                                          const string _wednesdayTradeIntervalsS,
                                          const string _thursdayTradeIntervalsS,
                                          const string _fridayTradeIntervalsS,
                                          const int _startTradeHourS,
                                          const int _startTradeMinuteS,
                                          const int _durationMinutesS,
                                          const bool _openOrdersInRollover,
                                          const bool _closeOrdersInRollover,
                                          const int _freezeMinutesBeforeRollover,
                                          const int _freezeMinutesAfterRollover,
                                          const int _dayChristmasBreakStarts,
                                          const int _dayChristmasBreakStops,
                                          const string _monthsToSkip) {
   TradeTimeManager* manager = NULL;
   if(_tradeRoundTheClock) {
      manager = new TradeTimeManager(_autoGMT,
                                     _brokerGMTOffsetWinter,
                                     _brokerDstMode,
                                     _targetGMTOffsetWinter,
                                     _targetDstMode,
                                     _monthsToSkip,
                                     _dayChristmasBreakStarts,
                                     _dayChristmasBreakStops);
   } else {
      if(_useWinterScheduleAllYear) {
         manager = new TradeTimeManager(_sundayTradeIntervalsW,
                                        _mondayTradeIntervalsW,
                                        _tuesdayTradeIntervalsW,
                                        _wednesdayTradeIntervalsW,
                                        _thursdayTradeIntervalsW,
                                        _fridayTradeIntervalsW,
                                        _autoGMT,
                                        _brokerGMTOffsetWinter,
                                        _brokerDstMode,
                                        _targetGMTOffsetWinter,
                                        _targetDstMode,
                                        _openOrdersInRollover,
                                        _closeOrdersInRollover,
                                        _freezeMinutesBeforeRollover,
                                        _freezeMinutesAfterRollover,
                                        _monthsToSkip,
                                        _dayChristmasBreakStarts,
                                        _dayChristmasBreakStops);
         if(_durationMinutesW > 0) {
            TradeInterval intervalWinter();
            intervalWinter.startMinute = _startTradeHourW % 24 * MINUTES_IN_HOUR + _startTradeMinuteW % 60;
            intervalWinter.endMinute = _durationMinutesW == 1440 ? intervalWinter.startMinute : (intervalWinter.startMinute + _durationMinutesW) % 1440;
            manager.AddIntervalWinter(intervalWinter);
            manager.AddIntervalSummer(intervalWinter);
         }
      } else {
         manager = new TradeTimeManager(_sundayTradeIntervalsW,
                                        _sundayTradeIntervalsS,
                                        _mondayTradeIntervalsW,
                                        _mondayTradeIntervalsS,
                                        _tuesdayTradeIntervalsW,
                                        _tuesdayTradeIntervalsS,
                                        _wednesdayTradeIntervalsW,
                                        _wednesdayTradeIntervalsS,
                                        _thursdayTradeIntervalsW,
                                        _thursdayTradeIntervalsS,
                                        _fridayTradeIntervalsW,
                                        _fridayTradeIntervalsS,
                                        _autoGMT,
                                        _brokerGMTOffsetWinter,
                                        _brokerDstMode,
                                        _targetGMTOffsetWinter,
                                        _targetDstMode,
                                        _openOrdersInRollover,
                                        _closeOrdersInRollover,
                                        _freezeMinutesBeforeRollover,
                                        _freezeMinutesAfterRollover,
                                        _monthsToSkip,
                                        _dayChristmasBreakStarts,
                                        _dayChristmasBreakStops);
         if(_durationMinutesW > 0) {
            TradeInterval intervalWinter();
            intervalWinter.startMinute = _startTradeHourW % 24 * MINUTES_IN_HOUR + _startTradeMinuteW % 60;
            intervalWinter.endMinute = _durationMinutesW == 1440 ? intervalWinter.startMinute : (intervalWinter.startMinute + _durationMinutesW) % 1440;
            manager.AddIntervalWinter(intervalWinter);
         }
         if(_durationMinutesS > 0) {
            TradeInterval intervalSummer();
            intervalSummer.startMinute = _startTradeHourS % 24 * MINUTES_IN_HOUR + _startTradeMinuteS % 60;
            intervalSummer.endMinute = _durationMinutesS == 1440 ? intervalSummer.startMinute : (intervalSummer.startMinute + _durationMinutesS) % 1440;
            manager.AddIntervalSummer(intervalSummer);
         }
      }
               
   }
   return (manager);
}
