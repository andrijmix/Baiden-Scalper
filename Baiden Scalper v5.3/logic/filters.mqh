//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool big_spread()
  {
   double spread = MarketInfo(_Symbol, MODE_SPREAD) / 10;
   if(spread > max_spread)
      return true;
   else
      return false;
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_new_bar()
  {
   static datetime new_time = 0;

   if(new_time == 0)
     {
      new_time = Time[0];
      return false;
     }

   if(new_time != Time[0])
     {
      new_time = Time[0];
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
bool distance_order_check()
  {
   if(distance_orders == 0)
      return true;
      
   double dis = distance_order();
   if(dis == 0)
      return true;
   if(dis < distance_orders)
      return false;
   else
      return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double distance_order()    //выдает дистанцию до ближайшего ордера
  {

   double dist = 9999;
   double dist1 = 0;

   int total=OrdersTotal();
   for(int pos=0; pos<total; pos++)
     {
      if(OrderSelect(pos, SELECT_BY_POS, MODE_TRADES)==false)
         continue;
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!= magic)
         continue;

      dist1 = MathAbs(Bid - OrderOpenPrice());
      if(dist1 < dist)
         dist = dist1;
     }
   return(dist/_Point);
  }
//+------------------------------------------------------------------+
