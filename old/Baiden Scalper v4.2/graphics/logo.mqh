
#resource "tio_logo.bmp"

void draw_logo() {
    string path = "::tio_logo.bmp";
    string promo_name = "TIO|Logo";
    
    RectLabelCreate(0, "TIO|Rect1", 0, 4, 19, 451, 184);
    
    if (!ObjectCreate(0, promo_name, OBJ_BITMAP_LABEL, 0, 0, 0))
        Print("Can't create promo object: error ", GetLastError());
    if (!ObjectSetInteger(0, promo_name, OBJPROP_CORNER, CORNER_LEFT_UPPER))
        Print("Cant set object property! Error: ", GetLastError());      
    if (!ObjectSetInteger(0, promo_name, OBJPROP_XDISTANCE, 5))
        Print("Cant set object property! Error: ", GetLastError());
    if (!ObjectSetInteger(0, promo_name, OBJPROP_YDISTANCE, 20))
        Print("Cant set object property! Error: ", GetLastError());                  
    if (!ObjectSetString(0, promo_name, OBJPROP_BMPFILE, 0, path))
        Print("Can't load image: error ", GetLastError());
         
    ChartRedraw(0);
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
   
    if (!ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,sub_window,0,0)) {
        Print(__FUNCTION__,": не удалось создать прямоугольную метку! " + IntegerToString(GetLastError())); 
        return false;
    } 
   
   ObjectSetInteger(chart_ID,name, OBJPROP_XDISTANCE, x); 
   ObjectSetInteger(chart_ID,name, OBJPROP_YDISTANCE, y); 
   ObjectSetInteger(chart_ID,name, OBJPROP_XSIZE, width); 
   ObjectSetInteger(chart_ID,name, OBJPROP_YSIZE, height); 
   ObjectSetInteger(chart_ID,name, OBJPROP_BGCOLOR, back_clr); 
   ObjectSetInteger(chart_ID,name, OBJPROP_BORDER_TYPE, border); 
   ObjectSetInteger(chart_ID,name, OBJPROP_CORNER, _corner); 
   ObjectSetInteger(chart_ID,name, OBJPROP_COLOR, clr); 
   ObjectSetInteger(chart_ID,name, OBJPROP_STYLE, style); 
   ObjectSetInteger(chart_ID,name, OBJPROP_WIDTH, line_width);
   
   return true; 
}

//+------------------------------------------------------------------+
