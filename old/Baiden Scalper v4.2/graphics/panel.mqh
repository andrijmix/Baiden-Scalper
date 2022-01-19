
void create_panel() {
    RectLabelCreate(0, comment + "|Rect1", 0, 5, 20, 220, 175, clrBlack, BORDER_FLAT, 0, C'16,107,135');    
    RectLabelCreate(0, comment + "|Rect2", 0, 6, 21, 218, 25, C'16,107,135', BORDER_FLAT, 0, clrBlack);
    RectLabelCreate(0, comment + "|Rect3", 0, 132, 68, 93, 125, clrBlack, BORDER_FLAT, 0, C'16,107,135');
    
    RectLabelCreate(0, comment + "|Rect4", 0, 133, 69, 91, 22, C'16,107,135', BORDER_FLAT, 0, clrBlack);    
    RectLabelCreate(0, comment + "|Rect5", 0, 133, 90, 91, 22, C'16,107,135', BORDER_FLAT, 0, clrBlack);
    RectLabelCreate(0, comment + "|Rect6", 0, 133, 111, 91, 22, C'16,107,135', BORDER_FLAT, 0, clrBlack);
    RectLabelCreate(0, comment + "|Rect8", 0, 133, 130, 91, 22, C'16,107,135', BORDER_FLAT, 0, clrBlack);
    RectLabelCreate(0, comment + "|Rect9", 0, 133, 150, 91, 22, C'16,107,135', BORDER_FLAT, 0, clrBlack);
    RectLabelCreate(0, comment + "|Rect10",0, 133, 170, 91, 22, C'16,107,135', BORDER_FLAT, 0, clrBlack);
    
    out_Label(comment + "|Title0", bot_name, "Lucida Console", 16, 34, 10, clrBlack);
    out_Label(comment + "|Title1", set_name, "Arial", 10, 59, 10, clrWheat);
    out_Label(comment + "|Title2", "Profit/Loss ","Arial", 10, 79, 10, clrWheat); 
    out_Label(comment + "|Title3", "Opened Orders Buy ", "Arial", 10, 99, 10, clrWheat); 
    out_Label(comment + "|Title4", "Opened Orders Sell ", "Arial", 10, 119, 10, clrWheat);
    out_Label(comment + "|Title5", "Total Lot Buy ", "Arial", 10, 139, 10, clrWheat);
    out_Label(comment + "|Title6", "Total Lot Sell ","Arial", 10, 159, 10, clrWheat);
    out_Label(comment + "|Title7", "Current Chart DD ", "Arial", 10, 179, 10, clrWheat);
    
    out_Label(comment + "|Title8",  "0.0", "Arial", 168, 80,  10, clrBlack);
    out_Label(comment + "|Title9",  "0.0", "Arial", 168, 100, 10, clrBlack);
    out_Label(comment + "|Title10", "0.0", "Arial", 168, 120, 10, clrBlack);
    out_Label(comment + "|Title11", "0.0", "Arial", 168, 140, 10, clrBlack);
    out_Label(comment + "|Title12", "0.0", "Arial", 168, 160, 10, clrBlack);
    out_Label(comment + "|Title13", "0.0", "Arial", 168, 180, 10, clrBlack);
    
    
    ButtonCreate(0, comment + "|StopBtn", 0, 5, 192, 220, 30, CORNER_LEFT_UPPER, "Close All Orders", "Arial", 10, C'16,107,135', White);
}

//+------------------------------------------------------------------+

bool RectLabelCreate( const long             chart_ID    = 0,                 // ID графика 
                      const string           name        = "RectLabel",       // имя метки 
                      const int              sub_window  = 0,                 // номер подокна 
                      const int              x           = 0,                 // координата по оси X 
                      const int              y           = 0,                 // координата по оси Y 
                      const int              width       = 50,                // ширина 
                      const int              height      = 18,                // высота 
                      const color            back_clr    = C'236,233,216',    // цвет фона 
                      const ENUM_BORDER_TYPE border      = BORDER_FLAT,       // тип границы 
                      const ENUM_BASE_CORNER _corner     = CORNER_LEFT_UPPER, // угол графика для привязки 
                      const color            clr         = clrRed,            // цвет плоской границы (Flat) 
                      const ENUM_LINE_STYLE  style       = STYLE_SOLID,       // стиль плоской границы 
                      const int              line_width  = 1)                 // толщина плоской границы 
{ 
   
   ResetLastError();
   
   if(ObjectFind(chart_ID,name) == -1) {
      if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,sub_window,0,0)) { //--- создадим прямоугольную метку 
          Print(__FUNCTION__,": не удалось создать прямоугольную метку! " + IntegerToString(GetLastError())); 
   	      return(false); 
      } 
   }
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x); 
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y); 
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width); 
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height); 
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr); 
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,border); 
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,_corner); 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,line_width);
   
   return(true); 
}

//+------------------------------------------------------------------+

bool ButtonCreate(const long              chart_ID=0,               // ID графика
                  const string            name="FTP|Button",        // имя кнопки
                  const int               sub_window=0,             // номер подокна
                  const int               x=0,                      // координата по оси X
                  const int               y=0,                      // координата по оси Y
                  const int               width=50,                 // ширина кнопки
                  const int               height=18,                // высота кнопки
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // угол графика для привязки
                  const string            text="Button",            // текст
                  const string            font="Arial",             // шрифт
                  const int               font_size=10,             // размер шрифта
                  const color             clr=clrBlack,             // цвет текста
                  const color             back_clr=C'236,233,216',  // цвет фона
                  const color             border_clr=clrNONE,       // цвет границы
                  const bool              state=false,              // нажата/отжата
                  const bool              back=false,               // на заднем плане
                  const bool              selection=false,          // выделить для перемещений
                  const bool              hidden=false,              // скрыт в списке объектов
                  const long              z_order=0)                // приоритет на нажатие мышью
  {

    if(!ObjectCreate(chart_ID, name, OBJ_BUTTON, sub_window, 0, 0)) {
        Print(__FUNCTION__, ": не удалось создать кнопку! Код ошибки = ", GetLastError());
        return false;
    }
//--- установим координаты кнопки
    ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
    ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- установим размер кнопки
    ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
    ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- установим угол графика, относительно которого будут определяться координаты точки
    ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- установим текст
    ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- установим шрифт текста
    ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- установим размер шрифта
    ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- установим цвет текста
    ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- установим цвет фона
    ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- установим цвет границы    
    ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
//--- отобразим на переднем (false) или заднем (true) плане
    ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- переведем кнопку в заданное состояние
    ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
//--- включим (true) или отключим (false) режим перемещения кнопки мышью
    ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
    ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- скроем (true) или отобразим (false) имя графического объекта в списке объектов
    ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- установим приоритет на получение события нажатия мыши на графике
    ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- успешное выполнение
    return true;
}

//+------------------------------------------------------------------+

void out_Label( string name, 
                string text, 
                string font, 
                int X, 
                int Y, 
                int font_size, 
                color col)

{
    if(ObjectFind(0, name) < 0) {
        ObjectCreate(0,name,OBJ_LABEL,0,0,0);
        ObjectSetInteger(0,name,OBJPROP_CORNER,0); 
        ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
        ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_LEFT);
        ObjectSetInteger(0,name,OBJPROP_XDISTANCE,X);
        ObjectSetInteger(0,name,OBJPROP_YDISTANCE,Y);
      
        ObjectSetString(0, name, OBJPROP_TEXT, text);
        ObjectSetInteger(0, name, OBJPROP_COLOR, col);
        ObjectSetString(0, name, OBJPROP_FONT, font);   
    }  
}

//+------------------------------------------------------------------+

void ObjectsDelete(string search) {
   for(int i = ObjectsTotal(0) - 1; i >= 0; i--) {
      if(StringFind(ObjectName(0, i), search) != -1) ObjectDelete(0, ObjectName(0, i));
   }
}

//+------------------------------------------------------------------+

double count_history_profit() {
    datetime end = TimeCurrent();
    datetime start = end - 30 * PeriodSeconds(PERIOD_D1);
    HistorySelect(start, end);
    
    int history_total = HistoryDealsTotal();
    double history_profit = 0;
    
    for (int i = 0; i < history_total; i++) {
        ulong ticket = HistoryDealGetTicket(i);
        if (HistoryDealSelect(ticket) && HistoryDealGetString(ticket, DEAL_SYMBOL) == _Symbol && HistoryDealGetInteger(ticket, DEAL_MAGIC) == magic) {
            history_profit += HistoryDealGetDouble(ticket, DEAL_PROFIT) + HistoryDealGetDouble(ticket, DEAL_COMMISSION) + HistoryDealGetDouble(ticket, DEAL_SWAP);
        }
    }
    return history_profit;
}

//+------------------------------------------------------------------+

void refresh_panel_profit() {    
    out_Label(comment + "|Title8", DoubleToString(count_history_profit(), 2), "Arial", 168, 76, 10, clrBlack);
}

//+------------------------------------------------------------------+

void refresh_panel() {
    double drawdown = 0;
    double lot_buy = 0;
    double lot_sell = 0;
    int buy_orders_count = 0;
    int sell_orders_count = 0;
    
    for (int i = 0; i < 15; i++) {
        if (signals[i].active && signals[i].in_long) {
            if (PositionSelectByTicket(signals[i].long_ticket)) {
                buy_orders_count++;
                drawdown += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
                lot_buy += PositionGetDouble(POSITION_VOLUME);
            }
        }
        if (signals[i].active && signals[i].in_short) {
            if (PositionSelectByTicket(signals[i].short_ticket)) {
                sell_orders_count++;
                drawdown += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
                lot_sell += PositionGetDouble(POSITION_VOLUME);
            }
        }
        if (true) {
            for (int j = 1; j < MAX_ORDERS; j++) {
                if (recoveries[i].long_tickets[j] > 0 && PositionSelectByTicket(recoveries[i].long_tickets[j])) {
                    buy_orders_count++;
                    drawdown += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
                    lot_buy  += PositionGetDouble(POSITION_VOLUME);
                }
                if (recoveries[i].short_tickets[j] > 0 && PositionSelectByTicket(recoveries[i].short_tickets[j])) {
                    sell_orders_count++;
                    drawdown += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
                    lot_sell += PositionGetDouble(POSITION_VOLUME);
                }
            }
        }
    }
    
    out_Label(comment + "|Title9",  IntegerToString(buy_orders_count), "Arial", 168, 96, 10, clrBlack); 
    out_Label(comment + "|Title10", IntegerToString(sell_orders_count), "Arial", 168, 116, 10, clrBlack);
    out_Label(comment + "|Title11", DoubleToString(lot_buy, 2),"Arial", 168, 136, 10, clrBlack);
    out_Label(comment + "|Title12", DoubleToString(lot_sell, 2), "Arial", 168, 156, 10, clrBlack);
    out_Label(comment + "|Title13", DoubleToString(drawdown, 2), "Arial", 168, 176, 10, clrBlack);
}

//+------------------------------------------------------------------+

void close_orders_btn() {
    /* Check for holidays */
    TimeCurrent(time);
    if (time.day_of_week == 6 || time.day_of_week == 0) return;
    
    /* Confirm close */
    //string msg = "Close all BUY and SELL orders on this chart?";
    string msg = "This button doesn't work yet. Press anything to quit.";  
    if (MessageBox(msg, NULL, MB_YESNO|MB_ICONQUESTION) != IDYES) return;

    //close_all_orders();
}

//+------------------------------------------------------------------+
