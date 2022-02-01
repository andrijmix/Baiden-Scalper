// MQL4&5-code

#ifdef __MQL5__

#define show_inputs script_show_inputs

#define extern input

#define init OnInit

#define Point _Point
#define Digits _Digits

#define Bid (::SymbolInfoDouble(_Symbol, ::SYMBOL_BID))
#define Ask (::SymbolInfoDouble(_Symbol, ::SYMBOL_ASK))

#define True true
#define False false

#define TimeToStr TimeToString
#define DoubleToStr DoubleToString

#define CurTime TimeCurrent

#define HistoryTotal OrdersHistoryTotal

#define LocalTime TimeLocal

#define MODE_BID 9
#define MODE_ASK 10
#define MODE_DIGITS 12
#define MODE_SPREAD 13
#define MODE_STOPLEVEL 14
#define MODE_LOTSIZE 15
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MarketInfo(const string Symb, const int Type)
  {
   switch(Type)
     {
      case MODE_BID:
         return(::SymbolInfoDouble(Symb, ::SYMBOL_BID));
      case MODE_ASK:
         return(::SymbolInfoDouble(Symb, ::SYMBOL_ASK));
      case MODE_DIGITS:
         return((double)::SymbolInfoInteger(Symb, ::SYMBOL_DIGITS));
      case MODE_SPREAD:
         return((double)::SymbolInfoInteger(Symb, ::SYMBOL_SPREAD));
      case MODE_STOPLEVEL:
         return((double)::SymbolInfoInteger(Symb, ::SYMBOL_TRADE_STOPS_LEVEL));
      case MODE_LOTSIZE:
         return(::SymbolInfoDouble(Symb, ::SYMBOL_TRADE_CONTRACT_SIZE));
     }

   return(-1);
  }

#define StringGetChar StringGetCharacter
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string  StringSetChar(const string &String_Var, const int iPos, const ushort Value)
  {
   string Str=String_Var;

   ::StringSetCharacter(Str, iPos, Value);

   return(Str);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeDayOfWeek(const datetime Date)
  {
   MqlDateTime mTime;
   ::TimeToStruct(Date, mTime);
   return(mTime.day_of_week);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsTesting(void)
  {
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsTradeContextBusy(void)
  {
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsTradeAllowed(void)
  {
   return(::MQLInfoInteger(::MQL_TRADE_ALLOWED));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool RefreshRates(void)
  {
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string WindowExpertName(void)
  {
   return(::MQLInfoString(::MQL_PROGRAM_NAME));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string AccountName(void)
  {
   return(::AccountInfoString(::ACCOUNT_NAME));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int AccountNumber(void)
  {
   return((int)::AccountInfoInteger(::ACCOUNT_LOGIN));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AccountFreeMargin(void)
  {
   return(::AccountInfoDouble(::ACCOUNT_MARGIN_FREE));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AccountFreeMarginCheck(const string Symb, const int Cmd, const double dVolume)
  {
   double Margin;

   return(::OrderCalcMargin((ENUM_ORDER_TYPE)Cmd, Symb, dVolume,
                            ::SymbolInfoDouble(Symb, (Cmd==::ORDER_TYPE_BUY) ? ::SYMBOL_ASK : ::SYMBOL_BID), Margin) ?
          ::AccountInfoDouble(::ACCOUNT_MARGIN_FREE) - Margin : -1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AccountEquity(void)
  {
   return(::AccountInfoDouble(::ACCOUNT_EQUITY));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MT4Bars(void)
  {
   return(::Bars(_Symbol, _Period));
  }

#define Bars (::MT4Bars())


#define DEFINE_TIMESERIE(NAME,FUNC,T)                                                                         \
  class CLASS##NAME                                                                                           \
  {                                                                                                           \
  public:                                                                                                     \
    static T Get(const string Symb,const int TimeFrame,const int iShift)                                      \
    {                                                                                                         \
      T tValue[];                                                                                             \
                                                                                                              \
      return((Copy##FUNC((Symb == NULL) ? _Symbol : Symb, _Period, iShift, 1, tValue) > 0) ? tValue[0] : -1); \
    }                                                                                                         \
                                                                                                              \
    T operator[](const int iPos) const                                                                        \
    {                                                                                                         \
      return(CLASS##NAME::Get(_Symbol, _Period, iPos));                                                       \
    }                                                                                                         \
  };                                                                                                          \
                                                                                                              \
  CLASS##NAME NAME;                                                                                           \
                                                                                                              \
  T i##NAME(const string Symb,const int TimeFrame,const int iShift)                                           \
  {                                                                                                           \
    return(CLASS##NAME::Get(Symb, TimeFrame, iShift));                                                        \
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
DEFINE_TIMESERIE(Volume, TickVolume, long)
DEFINE_TIMESERIE(Time, Time, datetime)
DEFINE_TIMESERIE(Open, Open, double)
DEFINE_TIMESERIE(High, High, double)
DEFINE_TIMESERIE(Low, Low, double)
DEFINE_TIMESERIE(Close, Close, double)


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ObjectSetText(string name,
                   string text,
                   int font_size,
                   string font="",
                   color text_color=CLR_NONE)
  {
   int tmpObjType=(int)ObjectGetInteger(0, name, OBJPROP_TYPE);
   if(tmpObjType!=OBJ_LABEL && tmpObjType!=OBJ_TEXT)
      return(false);
   if(StringLen(text)>0 && font_size>0)
     {
      if(ObjectSetString(0, name, OBJPROP_TEXT, text)==true
         && ObjectSetInteger(0, name, OBJPROP_FONTSIZE, font_size)==true)
        {
         if((StringLen(font)>0)
            && ObjectSetString(0, name, OBJPROP_FONT, font)==false)
            return(false);
         if(text_color>-1
            && ObjectSetInteger(0, name, OBJPROP_COLOR, text_color)==false)
            return(false);
         return(true);
        }
      return(false);
     }
   return(false);
  }

//+------------------------------------------------------------------+
//string TimeToStr(datetime value, int mode=TIME_DATE|TIME_MINUTES)  //is mt4
//  {
//   return(TimeToString(value, mode));
//  }
////+------------------------------------------------------------------+
bool ObjectSet(string name, int index, double value)
  {
   switch(index)
     {
      //case OBJPROP_TIME1:
      //   ObjectSetInteger(0,name,OBJPROP_TIME,(int)value);return(true);
      //case OBJPROP_PRICE1:
      //   ObjectSetDouble(0,name,OBJPROP_PRICE,value);return(true);
      //case OBJPROP_TIME2:
      //   ObjectSetInteger(0,name,OBJPROP_TIME,1,(int)value);return(true);
      //case OBJPROP_PRICE2:
      //   ObjectSetDouble(0,name,OBJPROP_PRICE,1,value);return(true);
      //case OBJPROP_TIME3:
      //   ObjectSetInteger(0,name,OBJPROP_TIME,2,(int)value);return(true);
      //case OBJPROP_PRICE3:
      //   ObjectSetDouble(0,name,OBJPROP_PRICE,2,value);return(true);
      case OBJPROP_COLOR:
         ObjectSetInteger(0, name, OBJPROP_COLOR, (int)value);
         return(true);
      case OBJPROP_STYLE:
         ObjectSetInteger(0, name, OBJPROP_STYLE, (int)value);
         return(true);
      case OBJPROP_WIDTH:
         ObjectSetInteger(0, name, OBJPROP_WIDTH, (int)value);
         return(true);
      case OBJPROP_BACK:
         ObjectSetInteger(0, name, OBJPROP_BACK, (int)value);
         return(true);
      case OBJPROP_RAY:
         ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, (int)value);
         return(true);
      case OBJPROP_ELLIPSE:
         ObjectSetInteger(0, name, OBJPROP_ELLIPSE, (int)value);
         return(true);
      case OBJPROP_SCALE:
         ObjectSetDouble(0, name, OBJPROP_SCALE, value);
         return(true);
      case OBJPROP_ANGLE:
         ObjectSetDouble(0, name, OBJPROP_ANGLE, value);
         return(true);
      case OBJPROP_ARROWCODE:
         ObjectSetInteger(0, name, OBJPROP_ARROWCODE, (int)value);
         return(true);
      case OBJPROP_TIMEFRAMES:
         ObjectSetInteger(0, name, OBJPROP_TIMEFRAMES, (int)value);
         return(true);
      case OBJPROP_DEVIATION:
         ObjectSetDouble(0, name, OBJPROP_DEVIATION, value);
         return(true);
      case OBJPROP_FONTSIZE:
         ObjectSetInteger(0, name, OBJPROP_FONTSIZE, (int)value);
         return(true);
      case OBJPROP_CORNER:
         ObjectSetInteger(0, name, OBJPROP_CORNER, (int)value);
         return(true);
      case OBJPROP_XDISTANCE:
         ObjectSetInteger(0, name, OBJPROP_XDISTANCE, (int)value);
         return(true);
      case OBJPROP_YDISTANCE:
         ObjectSetInteger(0, name, OBJPROP_YDISTANCE, (int)value);
         return(true);
      //case OBJPROP_FIBOLEVELS:
      //   ObjectSetInteger(0,name,OBJPROP_LEVELS,(int)value);return(true);
      case OBJPROP_LEVELCOLOR:
         ObjectSetInteger(0, name, OBJPROP_LEVELCOLOR, (int)value);
         return(true);
      case OBJPROP_LEVELSTYLE:
         ObjectSetInteger(0, name, OBJPROP_LEVELSTYLE, (int)value);
         return(true);
      case OBJPROP_LEVELWIDTH:
         ObjectSetInteger(0, name, OBJPROP_LEVELWIDTH, (int)value);
         return(true);

      default:
         return(false);
     }
   return(false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeDay(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date, tm);
   return(tm.day);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int TimeDayOfYear(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date, tm);
   return(tm.day_of_year);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeHour(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date, tm);
   return(tm.hour);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeMinute(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date, tm);
   return(tm.min);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeMonth(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date, tm);
   return(tm.mon);
  }


#endif // __MQL5__
