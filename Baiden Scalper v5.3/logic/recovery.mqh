//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void manage_grid(bool mode, int index)
  {
   double pips_profit = 0.0;
   double grid_tp = 0.0;
   double icls = iClose(_Symbol, atr_tf, 1);
   double atr = i_atr(_Symbol, atr_tf, atr_period, 1) / icls;

   if(mode)
     {
      if(recoveries[index].buy_close_flag)
        {
         close_grid(buy, index);
         return;
        }

      if(close_by == TAKE)
        {
         int total = get_last_order(mode, index) + 1;
         for(int i = 0; i < total; i++)
            if(OrderSelect(recoveries[index].long_tickets[i], SELECT_BY_TICKET))
               pips_profit += calc_pips_profit(buy);

         grid_tp = calc_grid_tp(buy, index);

         if(pips_profit >= grid_tp)
           {
            close_grid(buy, index);
            return;
           }
        }

      if(close_by == MA)
        {
         double ma = i_ma(_Symbol, PERIOD_CURRENT, signals[index].ma_period, 0, MODE_SMA, PRICE_CLOSE, 1);
         double price_close = iClose(_Symbol, PERIOD_CURRENT, 1);

         if(price_close > ma)
           {
            close_grid(buy, index);
            return;
           }
        }

      /* New knee opening block */
      int last_index = get_last_order(buy, index);
      if(last_index <= max_orders - 2)
        {
         if(OrderSelect(recoveries[index].long_tickets[last_index], SELECT_BY_TICKET))
           {
            double price_open = OrderOpenPrice();
            if(price_open - Ask >= grid_step * 10 * _Point && atr < atr_above && atr > atr_below)
              {
               if(!open_grid_order(buy, index))
                 {
                  for(int j = 1; j < retry; j++)
                    {
                     Print("Не удалось открыть ордер рекавери на покупку: ошибка ", GetLastError(), ", новая попытка...");
                     Sleep(SLEEP);
                     if(open_grid_order(buy, index))
                        break;
                    }
                 }
              }
           }
        }
     }
   else
     {
      if(recoveries[index].sell_close_flag)
        {
         close_grid(sell, index);
         return;
        }

      if(close_by == TAKE)
        {
         int total = get_last_order(mode, index) + 1;
         for(int i = 0; i < total; i++)
            if(OrderSelect(recoveries[index].short_tickets[i], SELECT_BY_TICKET))
               pips_profit += calc_pips_profit(sell);

         grid_tp = calc_grid_tp(sell, index);

         if(pips_profit >= grid_tp)
           {
            close_grid(sell, index);
            return;
           }
        }

      if(close_by == MA)
        {
         double ma = i_ma(_Symbol, PERIOD_CURRENT, signals[index].ma_period, 0, MODE_SMA, PRICE_CLOSE, 1);
         double price_close = iClose(_Symbol, PERIOD_CURRENT, 1);

         if(price_close < ma)
           {
            close_grid(sell, index);
            return;
           }
        }

      /* New knee opening block */
      int last_index = get_last_order(sell, index);
      if(last_index <= max_orders - 2)
        {
         if(OrderSelect(recoveries[index].short_tickets[last_index], SELECT_BY_TICKET))
           {
            double price_open = OrderOpenPrice();
            if(Bid - price_open >= grid_step * 10 * _Point && atr < atr_above && atr > atr_below)
              {
               if(!open_grid_order(sell, index))
                 {
                  for(int j = 1; j < retry; j++)
                    {
                     Print("Не удалось открыть ордер рекавери на продажу: ошибка ", GetLastError(), ", новая попытка...");
                     Sleep(SLEEP);
                     if(open_grid_order(sell, index))
                        break;
                    }
                 }
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_pips_profit(bool mode)
  {
   double profit = 0.0;
   double start_grid_lot = lot;

   if(mode)   //buy
     {
      profit = Bid - OrderOpenPrice();
      profit = profit / start_grid_lot * OrderLots();
      return profit / _Point / 10;
     }
   else
     {
      profit = OrderOpenPrice() - Ask;
      profit = profit / start_grid_lot * OrderLots();
      return profit / _Point / 10;
     }
   return 0.0;
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int count_orders(bool mode, int index)
  {
   int grid_total = 0;


   if(mode)    //buy
     {

      for(int i = 0; i < max_orders; i++)
        {
         if(recoveries[index].long_tickets[i] != 0)
            grid_total++;
        }
     }
   else
     {
      for(int i = 0; i < max_orders; i++)
        {
         if(recoveries[index].short_tickets[i] != 0)
            grid_total++;
        }
     }
   return grid_total;
  }

//+------------------------------------------------------------------+

/* Returns last grid order index */
int get_last_order(bool mode, int index)
  {
   int counter = 0;
   if(mode)    //buy
     {
      for(int i = 0; i < max_orders; i++)
        {
         if(recoveries[index].long_tickets[i] <= 0)
            break;
         counter = i;
        }
     }
   else
     {
      for(int i = 0; i < max_orders; i++)
        {
         if(recoveries[index].short_tickets[i] <= 0)
            break;
         counter = i;
        }
     }
   return counter;
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void close_grid(bool mode, int index)
  {
   for(int j = 0; j < retry; j++)
     {
      if(mode)    // buy
        {
         for(int i = max_orders - 1; i >= 0; i--)
           {
            if(recoveries[index].long_tickets[i] <= 0)
               continue;
            if(!close_grid_order(mode, recoveries[index].long_tickets[i]))
              {
               Print("failed to close order, error ", GetLastError());
               recoveries[index].buy_close_flag = true;
              }
            else
               recoveries[index].long_tickets[i] = 0;
           }
         if(count_orders(buy, index) == 0)
           {
            signals[index].in_long = false;
            signals[index].long_ticket = 0;
            recoveries[index].buy_close_flag = false;
            return;
           }
         else
           {
            Print("Failed to close buy grid, another try...");
            Sleep(SLEEP);
           }
        }
      else
        {
         for(int i = max_orders - 1; i >= 0; i--)
           {
            if(recoveries[index].short_tickets[i] <= 0)
               continue;
            if(!close_grid_order(mode, recoveries[index].short_tickets[i]))
              {
               Print("failed to close order, error ", GetLastError());
               recoveries[index].sell_close_flag = true;
              }
            else
               recoveries[index].short_tickets[i] = 0;
           }
         if(count_orders(sell, index) == 0)
           {
            signals[index].in_short = false;
            signals[index].short_ticket = 0;
            recoveries[index].sell_close_flag = false;
            return;
           }
         else
           {
            Print("Failed to close sell grid, another try...");
            Sleep(SLEEP);
           }
        }
     }
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool close_grid_order(bool mode, int ticket)
  {
   double price = 0.0;
   color clr = Green;

   RefreshRates();

   if(mode)
     {
      price = Bid;
      clr = Blue;
     }
   else
     {
      price = Ask;
      clr = Red;
     }

   if(mode)
     {
      if(OrderSelect(ticket, SELECT_BY_TICKET))
        {
         if(OrderClose(ticket, OrderLots(), price, slippage, clr))
           {
            return true;
           }
         else
            return false;
        }
     }
   else
     {
      if(OrderSelect(ticket, SELECT_BY_TICKET))
        {
         if(OrderClose(ticket, OrderLots(), price, slippage, clr))
           {
            return true;
           }
         else
            return false;
        }
     }
   return false;
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool open_grid_order(bool mode, int index)
  {
   double lot_size = lot;
   int num_buy_orders = 0;
   int num_sell_orders = 0;
   int order_type = 0;
   double price = 0;
   double sl = 0;
   double tp = 0;
   color clr = White;
   string comment_open;
   string comment_index;
   string comment_num_buy;
   string comment_num_sell;

   if(index < 10)
      comment_index = "0" + IntegerToString(index);
   else
      comment_index = IntegerToString(index);

   if(mode)    //buy
     {
      num_buy_orders = count_orders(buy, index);

      if(num_buy_orders < 10)
         comment_num_buy = "0" + IntegerToString(num_buy_orders);
      else
         comment_num_buy = IntegerToString(num_buy_orders);

      order_type = OP_BUY;
      clr = Blue;
      lot_size = calc_lot(num_buy_orders);
      comment_open = comment + "_Rec_" + comment_index + comment_num_buy;
     }
   else
     {
      num_sell_orders = count_orders(sell, index);

      if(num_sell_orders < 10)
         comment_num_sell = "0" + IntegerToString(num_sell_orders);
      else
         comment_num_sell = IntegerToString(num_sell_orders);

      order_type = OP_SELL;
      clr = Red;
      lot_size = calc_lot(num_sell_orders);
      comment_open = comment + "_Rec_" + comment_index + comment_num_sell;
     }

   RefreshRates();

   if(mode)
      price = Ask;
   else
      price = Bid;

   if(mode)    //buy
     {
      long ticket = OrderSend(_Symbol, order_type, lot_size, price, slippage, sl, tp, comment_open, magic, 0, clr);
      if(ticket > 0)
        {
         recoveries[index].long_tickets[num_buy_orders] = (int)ticket;
         return true;
        }
      else
         return false;
     }
   else
     {
      long ticket = OrderSend(_Symbol, order_type, lot_size, price, slippage, sl, tp, comment_open, magic, 0, clr);
      if(ticket > 0)
        {
         recoveries[index].short_tickets[num_sell_orders] = (int)ticket;
         return true;
        }
      else
         return false;
     }
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_lot(int num_orders)
  {
   double lot_size = lot;
   double mm_lot = lot;

   if(depo_per_lot != 0)
     {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      lot_size = balance / depo_per_lot * lot;
      mm_lot = lot_size;
     }

   if(num_orders >= start_factor_knee - 1)
     {
      for(int i = start_factor_knee - 1; i <= num_orders; i++)
        {
         if(use_arithmetic_multiplier)
            lot_size += mm_lot;
         else
            lot_size *= recovery_factor;
        }
     }

   lot_size *= 100.0;
   lot_size = MathFloor(lot_size);
   lot_size /= 100.0;

   return lot_size;
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_grid_tp(bool mode, int index)
  {

   double new_tp = recovery_take_profit;
   datetime start_grid_time;
   int bars_shift;

   if(mode)
     {
      if(OrderSelect(signals[index].long_ticket, SELECT_BY_TICKET))
        {
         start_grid_time = OrderOpenTime();
         bars_shift = iBarShift(_Symbol, PERIOD_CURRENT, start_grid_time, true);

         if(bars_shift >= 0)
           {
            if(bars_shift >= bar_to_reduce && bar_to_reduce !=0)
              {
               int shift = bars_shift - bar_to_reduce;
               for(int i = 0; i < shift; i++)
                  new_tp -= take_reduce;

               if(new_tp <= take_reduce_limit)
                  new_tp = take_reduce_limit;
              }
            if(grid_order_number_for_tp_0 >0)
              {
               int n = get_last_order(buy, index);
               if(grid_order_number_for_tp_0 <= n)
                 {
                  Print("recovery_take_profit_is_n_orders = 0");
                  return(recovery_take_profit_is_n_orders);
                 }
              }

           }
         else
           {
            Print("Start grid bar not found.");
            Print("Take profit was NOT reduced. Use normal take instead.");
           }
        }
      else
        {
         Print("Error selecting order in ", __FUNCTION__, ", file ", __FILE__, ", line ", __LINE__, ": ", GetLastError());
         Print("Take profit was NOT reduced. Use normal take instead.");
        }
     }
   else //sell
     {
      if(OrderSelect(signals[index].short_ticket, SELECT_BY_TICKET))
        {
         start_grid_time = OrderOpenTime();
         bars_shift = iBarShift(_Symbol, PERIOD_CURRENT, start_grid_time, true);

         if(bars_shift >= 0)
           {
            if(bars_shift >= bar_to_reduce && bar_to_reduce !=0)
              {
               int shift = bars_shift - bar_to_reduce;
               for(int i = 0; i < shift; i++)
                  new_tp -= take_reduce;

               if(new_tp <= take_reduce_limit)
                  new_tp = take_reduce_limit;
              }

            if(grid_order_number_for_tp_0 >0)
              {
               int n = get_last_order(sell, index);
               if(grid_order_number_for_tp_0 <= n)
                 {
                  Print("recovery_take_profit_is_n_orders = 0");
                  return(recovery_take_profit_is_n_orders);
                 }
              }

           }
         else
           {
            Print("Start grid bar not found.");
            Print("Take profit was NOT reduced. Use normal take instead.");
           }
        }
      else
        {
         Print("Error selecting order in ", __FUNCTION__, ", file ", __FILE__, ", line ", __LINE__, ": ", GetLastError());
         Print("Take profit was NOT reduced. Use normal take instead.");
        }
     }

   return new_tp;
  }

//+------------------------------------------------------------------+
