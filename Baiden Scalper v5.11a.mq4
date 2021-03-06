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


#include "\\Time\TradeTimeFullDefine.mqh"
TradeTimeManager* tradeTimeManager;


//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

   tradeTimeManager = CreateTradeTimeManager();


   TesterHideIndicators(true);
   return init_ea();
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

   if(CheckPointer(tradeTimeManager) == POINTER_DYNAMIC)
      delete(tradeTimeManager);


   if(!is_testing)
      ObjectsDelete("FTP|");
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   TradeTimeStatus tradeTimeStatus = tradeTimeManager.GetTradeTimeStatus();



   if(big_spread() || !IsTradeAllowed())
      return;

   if(is_new_bar())
     {

      if(tradeTimeStatus.isOpenAllowed)

        {

         if(trade_buy)
            find_entries(buy);

         if(trade_sell)
            find_entries(sell);
        }

      if(tradeTimeStatus.isCloseAllowed)

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
