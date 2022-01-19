//+------------------------------------------------------------------+
//|                                          TradeTimeFullDefine.mqh |
//|                      Copyright 2020, Igor Ryabchikov (aka Rigal) |
//|                     https://tlap.com/forum/profile/109537-rigal/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Igor Ryabchikov (aka Rigal)"
#property link      "https://tlap.com/forum/profile/109537-rigal/"
#property strict

#include "TradeTimeFull.mqh"

sinput string            TradeTimeStr0                   = "#============= Time settings =============#";//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sinput bool              TradeRoundTheClock              = false;                                        //Trade round the clock (faster)
sinput string            TradeTimeStr1                   = "- broker GMT offset will be auto-adjusted -";//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sinput string            TradeTimeStr2                   = "-- Set your winter GMT offset for tester --";//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
input bool               AutoGMT                         = false;                                        //Auto detect GMT
input int                BrokerGMTOffsetWinter           = 2;                                            //Broker GMT Offset (winter time)
sinput DstMode           BrokerDstMode                   = DST_NEW_YORK;                                 //DST mode of your broker (or in TDS2)
input int                TargetGMTOffsetWinter           = 2;                                            //Target GMT Offset (winter time)
sinput DstMode           TargetDstMode                   = DST_NEW_YORK;                                 //DST mode of the target timezone
sinput string            TradeTimeStr3                   = "----- Trade intervals, comma separated ----";//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sinput string            TradeTimeStr4                   = "----- set time in the target timezone -----";//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sinput string            TradeTimeStr5                   = "Format: 'hh:mm-hh:mm', blank for no trading";//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sinput string            TradeTimeStr6                   = "----------------- WINTER ------------------";//Winter trade intervals
sinput string            TradeTimeStr7                   = "<== SUNDAY ==>";                             //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sinput string            SUNDAY_TradeIntervalsW          = "";                                           //Sunday Trade intervals
sinput   string          TradeTimeStr8                   = "<== MONDAY ==>";                             //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sinput string            MONDAY_TradeIntervalsW          = "";                                           //Monday Trade intervals
sinput   string          TradeTimeStr9                   = "<== TUESDAY ==>";                            //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sinput string            TUESDAY_TradeIntervalsW         = "";                                           //Tuesday Trade intervals
sinput   string          TradeTimeStr10                  = "<== WEDNESDAY ==>";                          //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sinput string            WEDNESDAY_TradeIntervalsW       = "";                                           //Wednesday Trade intervals
sinput   string          TradeTimeStr11                  = "<== THURSDAY ==>";                           //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sinput string            THURSDAY_TradeIntervalsW        = "";                                           //Thursday Trade intervals
sinput   string          TradeTimeStr12                  = "<== FRIDAY ==>";                             //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sinput string            FRIDAY_TradeIntervalsW          = "";                                           //Friday Trade intervals
sinput string            TradeTimeStr13                  = "--- Extra interval, every day (for opt) ---";//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
input   int              StartTradeHourW                 = 17;                                           //Start Trade Hour
input   int              StartTradeMinuteW               = 0;                                            //Start Trade Minute
input   int              DurationMinutesW                = 120;                                          //Session duration, minutes 
sinput string            TradeTimeStr14                  = "";                                           //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sinput string            TradeTimeStr15                  = "----------------- SUMMER ------------------";//Summer trade intervals
sinput bool              UseWinterScheduleAllYear        = true;                                         //Use winter schedule all year
sinput string            TradeTimeStr16                  = "<== SUNDAY ==>";                             //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sinput string            SUNDAY_TradeIntervalsS          = "";                                           //Sunday Trade intervals
sinput   string          TradeTimeStr17                  = "<== MONDAY ==>";                             //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sinput string            MONDAY_TradeIntervalsS          = "";                                           //Monday Trade intervals
sinput   string          TradeTimeStr18                  = "<== TUESDAY ==>";                            //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sinput string            TUESDAY_TradeIntervalsS         = "";                                           //Tuesday Trade intervals
sinput   string          TradeTimeStr19                  = "<== WEDNESDAY ==>";                          //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sinput string            WEDNESDAY_TradeIntervalsS       = "";                                           //Wednesday Trade intervals
sinput   string          TradeTimeStr20                  = "<== THURSDAY ==>";                           //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sinput string            THURSDAY_TradeIntervalsS        = "";                                           //Thursday Trade intervals
sinput   string          TradeTimeStr21                  = "<== FRIDAY ==>";                             //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sinput string            FRIDAY_TradeIntervalsS          = "";                                           //Friday Trade intervals
sinput string            TradeTimeStr22                  = "--- Extra interval, every day (for opt) ---";//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
input   int              StartTradeHourS                 = 17;                                           //Start Trade Hour
input   int              StartTradeMinuteS               = 0;                                            //Start Trade Minute
input   int              DurationMinutesS                = 120;                                          //Session duration, minutes 
sinput  string           TradeTimeStr23                  = "<==== Roll Over Filter ====>";               //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
input   bool             OpenOrdersInRollover            = true;                                         //Open deals in Rollover
input   bool             CloseOrdersInRollover           = true;                                         //Close deals in Rollover
sinput  int              FreezeMinutesBeforeRollover     = 5;                                            //Freeze before Rollover, minutes
sinput  int              FreezeMinutesAfterRollover      = 15;                                           //Freeze after Rollover, minutes
sinput  string           TradeTimeStr24                  = "<==== Christmas&SkipMonths ====>";           //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

input  int               DayChristmasBreakStarts         = 15;                                           //Last day to trade in December
input  int               DayChristmasBreakStops          = 15;                                           //First day to trade in January
input  string            MonthsToSkip                    = "";                                           //Months to skip in trading, comma-separated



TradeTimeManager* CreateTradeTimeManager() {
   return (CreateTradeTimeManager(TradeRoundTheClock,
                                  AutoGMT,
                                  BrokerGMTOffsetWinter,
                                  BrokerDstMode,
                                  TargetGMTOffsetWinter,
                                  TargetDstMode,
                                  SUNDAY_TradeIntervalsW,
                                  MONDAY_TradeIntervalsW,
                                  TUESDAY_TradeIntervalsW,
                                  WEDNESDAY_TradeIntervalsW,
                                  THURSDAY_TradeIntervalsW,
                                  FRIDAY_TradeIntervalsW,
                                  StartTradeHourW,
                                  StartTradeMinuteW,
                                  DurationMinutesW,
                                  UseWinterScheduleAllYear,
                                  SUNDAY_TradeIntervalsS,
                                  MONDAY_TradeIntervalsS,
                                  TUESDAY_TradeIntervalsS,
                                  WEDNESDAY_TradeIntervalsS,
                                  THURSDAY_TradeIntervalsS,
                                  FRIDAY_TradeIntervalsS,
                                  StartTradeHourS,
                                  StartTradeMinuteS,
                                  DurationMinutesS,
                                  OpenOrdersInRollover,
                                  CloseOrdersInRollover,
                                  FreezeMinutesBeforeRollover,
                                  FreezeMinutesAfterRollover,
                                  DayChristmasBreakStarts,
                                  DayChristmasBreakStops,
                                  MonthsToSkip));
}

