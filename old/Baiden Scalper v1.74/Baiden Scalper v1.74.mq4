/*
    1.74
    - защита кнопки от нажатия на выходных
    - подтверждение закрытия ордеров на кнопке
    - правка стопа (он нажимал кнопку Close All Orders на графике - работало, но сделал логичнее и безопаснее)
    - Current Pair DD -> Current Chart DD
    - выпилена новая офигенная панель
    - важно: добавлено попыток открытия/закрытия ордеров - 5 на баре
*/


#property strict
#property link "https://tlap.com"
const string version = "1.74";


#include "logic/settings.mqh"
#include "logic/time_control.mqh"
#include "logic/filters.mqh"
#include "logic/main.mqh"
#include "logic/initialize.mqh"
#include "graphics/panel.mqh"
#include "logic/recovery.mqh"

//+------------------------------------------------------------------+

int OnInit() {
    return init_ea();
}

//+------------------------------------------------------------------+

void OnDeinit(const int reason) {
    if (!is_testing)
        ObjectsDelete("FTP|");
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
    if (id == CHARTEVENT_OBJECT_CLICK && sparam == "FTP|StopBtn") {        
        close_orders_btn();        
        ObjectSet("FTP|StopBtn", OBJPROP_STATE, false);
    }
    
}

//+------------------------------------------------------------------+

double OnTester() {
    double dd = TesterStatistics(STAT_EQUITY_DD);
    if (dd > 0.0)
        return TesterStatistics(STAT_PROFIT) / dd;
    return 0.0;  
}

//+------------------------------------------------------------------+
