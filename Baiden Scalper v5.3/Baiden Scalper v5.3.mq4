//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

#property strict
#property link "https://tlap.com"
#property icon "graphics/tio_logo.ico"


const string version = "5.2";
string bot_name = "       Baiden Scalper v" + version;

//+------------------------------------------------------------------+
#include "logic/MT4Orders.mqh" // если есть #include <Trade/Trade.mqh>, вставить эту строчку ПОСЛЕ
#include "logic/mql4_to_mql5.mqh"
#include "logic/settings.mqh"
#include "logic/filters.mqh"
#include "logic/main.mqh"
#include "logic/initialize.mqh"
#include "graphics/panel.mqh"
#include "logic/recovery.mqh"
#include "logic/indicators.mqh"

#ifdef __MQL4__
#include "\\Time\TradeTimeFullDefine.mqh"
TradeTimeManager* tradeTimeManager;
#endif

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
#ifdef __MQL4__
   tradeTimeManager = CreateTradeTimeManager();
   #endif

   TesterHideIndicators(true);
   return init_ea();
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  #ifdef __MQL4__
   if(CheckPointer(tradeTimeManager) == POINTER_DYNAMIC)
      delete(tradeTimeManager);
      #endif

   if(!is_testing)
      ObjectsDelete("FTP|");
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
  #ifdef __MQL4__
   TradeTimeStatus tradeTimeStatus = tradeTimeManager.GetTradeTimeStatus();
#endif


   if(big_spread() || !IsTradeAllowed())
      return;

   if(is_new_bar())
     {
     #ifdef __MQL4__
      if(tradeTimeStatus.isOpenAllowed)
      #endif
        {

         if(trade_buy)
            find_entries(buy);

         if(trade_sell)
            find_entries(sell);
        }
#ifdef __MQL4__
      if(tradeTimeStatus.isCloseAllowed)
      #endif
        {

         find_exit(buy);
         find_exit(sell);
        }
      if(!is_testing)
         refresh_panel_profit();
     }

   find_global_stop();

   if(!is_testing)
      refresh_panel();

  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id == CHARTEVENT_OBJECT_CLICK && sparam == "FTP|StopBtn")
     {
      close_orders_btn();
      ObjectSet("FTP|StopBtn", OBJPROP_STATE, false);
     }

  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
   double dd = TesterStatistics(STAT_EQUITY_DD);
   if(dd > 0.0)
      return TesterStatistics(STAT_PROFIT) / dd;
   return 0.0;
  }

//+------------------------------------------------------------------+
