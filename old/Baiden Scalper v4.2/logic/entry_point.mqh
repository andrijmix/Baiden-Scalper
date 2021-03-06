#property strict
#property link "https://tlap.com"

/*
Baiden Scalper v4.2

*/

//+------------------------------------------------------------------+

/* Здесь у нас то, что надо менять постоянно */

#property version "4.2"
const string version = "4.2";

 #define IS_OPT

#ifndef IS_OPT
    #define SETS_NUM 1
#endif
        
string bot_name = "Baiden Scalper v" + version;

//license check
bool license_check = false;
const long account = 61017514;

//+------------------------------------------------------------------+

#include "settings.mqh"
//#include "graphics/panel.mqh"
#include "../graphics/logo.mqh"
#include "filters.mqh"
#include "recovery.mqh"
#include "main.mqh"
#include "../trade/sets/sets.mqh"


#ifdef MQL4
    #include "initialize_4.mqh"
    #include "../trade/orders_4.mqh"
    #include "../trade/indicators_4.mqh"
#endif

#ifdef MQL5
    #include "initialize_5.mqh"
    #include "../trade/orders_5.mqh"
    #include "../trade/indicators_5.mqh"
#endif

//+------------------------------------------------------------------+

int OnInit() {
    return init_ea();
}

//+------------------------------------------------------------------+

void OnDeinit(const int reason) {
    if (!is_test)
        ObjectsDeleteAll(0, "TIO|");  
}

//+------------------------------------------------------------------+

void OnTick() {
    tick_handler();
}

//+------------------------------------------------------------------+

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
    #ifdef IS_OPT
    if (id == CHARTEVENT_OBJECT_CLICK && sparam == "TIO|StopBtn") {        
        //close_orders_btn();
        //ObjectSetInteger(0, "AST|StopBtn", OBJPROP_STATE, false);
    }
    #endif
    
}

//+------------------------------------------------------------------+

double OnTester() {
    double dd = TesterStatistics(STAT_EQUITY_DD);
    if (dd > 0.0)
        return TesterStatistics(STAT_PROFIT) / dd;
    return 0.0;
}

//+------------------------------------------------------------------+
