//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void fill_struct()
  {
   signals[0].ma_period = std_period_1;
   signals[1].ma_period = std_period_2;
   signals[2].ma_period = std_period_3;
   signals[3].ma_period = std_period_4;
   signals[4].ma_period = std_period_5;
   signals[5].ma_period = std_period_6;
   signals[6].ma_period = std_period_7;
   signals[7].ma_period = std_period_8;
   signals[8].ma_period = std_period_9;
   signals[9].ma_period = std_period_10;
   signals[10].ma_period = std_period_11;
   signals[11].ma_period = std_period_12;
   signals[12].ma_period = std_period_13;
   signals[13].ma_period = std_period_14;
   signals[14].ma_period = std_period_15;
   
    signals[0].std_period = std_period_1;
    signals[1].std_period = std_period_2;
    signals[2].std_period = std_period_3;
    signals[3].std_period = std_period_4;
    signals[4].std_period = std_period_5;
    signals[5].std_period = std_period_6;
    signals[6].std_period = std_period_7;
    signals[7].std_period = std_period_8;    
    signals[8].std_period = std_period_9;
    signals[9].std_period = std_period_10;
    signals[10].std_period = std_period_11;
    signals[11].std_period = std_period_12;
    signals[12].std_period = std_period_13;
    signals[13].std_period = std_period_14;
    signals[14].std_period = std_period_15;   

   signals[0].std_level = std_level_1;
   signals[1].std_level = std_level_2;
   signals[2].std_level = std_level_3;
   signals[3].std_level = std_level_4;
   signals[4].std_level = std_level_5;
   signals[5].std_level = std_level_6;
   signals[6].std_level = std_level_7;
   signals[7].std_level = std_level_8;
   signals[8].std_level = std_level_9;
   signals[9].std_level = std_level_10;
   signals[10].std_level = std_level_11;
   signals[11].std_level = std_level_12;
   signals[12].std_level = std_level_13;
   signals[13].std_level = std_level_14;
   signals[14].std_level = std_level_15;

   signals[0].take_profit = take_profit_1;
   signals[1].take_profit = take_profit_2;
   signals[2].take_profit = take_profit_3;
   signals[3].take_profit = take_profit_4;
   signals[4].take_profit = take_profit_5;
   signals[5].take_profit = take_profit_6;
   signals[6].take_profit = take_profit_7;
   signals[7].take_profit = take_profit_8;
   signals[8].take_profit = take_profit_9;
   signals[9].take_profit = take_profit_10;
   signals[10].take_profit = take_profit_11;
   signals[11].take_profit = take_profit_12;
   signals[12].take_profit = take_profit_13;
   signals[13].take_profit = take_profit_14;
   signals[14].take_profit = take_profit_15;

   signals[0].include_ma_as_filter = include_ma_as_filter_1;
   signals[1].include_ma_as_filter = include_ma_as_filter_2;
   signals[2].include_ma_as_filter = include_ma_as_filter_3;
   signals[3].include_ma_as_filter = include_ma_as_filter_4;
   signals[4].include_ma_as_filter = include_ma_as_filter_5;
   signals[5].include_ma_as_filter = include_ma_as_filter_6;
   signals[6].include_ma_as_filter = include_ma_as_filter_7;
   signals[7].include_ma_as_filter = include_ma_as_filter_8;
   signals[8].include_ma_as_filter = include_ma_as_filter_9;
   signals[9].include_ma_as_filter = include_ma_as_filter_10;
   signals[10].include_ma_as_filter = include_ma_as_filter_11;
   signals[11].include_ma_as_filter = include_ma_as_filter_12;
   signals[12].include_ma_as_filter = include_ma_as_filter_13;
   signals[13].include_ma_as_filter = include_ma_as_filter_14;
   signals[14].include_ma_as_filter = include_ma_as_filter_15;
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void activate_signals()
  {
   if(signals[0].std_period != 0)
      signals[0].active = true;
   if(signals[1].std_period != 0)
      signals[1].active = true;
   if(signals[2].std_period != 0)
      signals[2].active = true;
   if(signals[3].std_period != 0)
      signals[3].active = true;
   if(signals[4].std_period != 0)
      signals[4].active = true;
   if(signals[5].std_period != 0)
      signals[5].active = true;
   if(signals[6].std_period != 0)
      signals[6].active = true;
   if(signals[7].std_period != 0)
      signals[7].active = true;
   if(signals[8].std_period != 0)
      signals[8].active = true;
   if(signals[9].std_period != 0)
      signals[9].active = true;
   if(signals[10].std_period != 0)
      signals[10].active = true;
   if(signals[11].std_period != 0)
      signals[11].active = true;
   if(signals[12].std_period != 0)
      signals[12].active = true;
   if(signals[13].std_period != 0)
      signals[13].active = true;
   if(signals[14].std_period != 0)
      signals[14].active = true;
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void catch_orders()
  {
   int total = OrdersTotal();
   for(int i = 0; i < total; i++)
     {
      if(OrderSelect(i, SELECT_BY_POS))
        {
         if(OrderSymbol() == _Symbol && OrderMagicNumber() == magic)
           {
            if(OrderType() == OP_BUY && OrderComment() == "FTP signal 0")
              {
               signals[0].in_long = true;
               signals[0].long_ticket = OrderTicket();
               if(use_recovery)
                  recoveries[0].long_tickets[0] = OrderTicket();
              }
            if(OrderType() == OP_SELL && OrderComment() == "FTP signal 0")
              {
               signals[0].in_short = true;
               signals[0].short_ticket = OrderTicket();
               if(use_recovery)
                  recoveries[0].short_tickets[0] = OrderTicket();
              }
            if(OrderType() == OP_BUY && OrderComment() == "FTP signal 1")
              {
               signals[1].in_long = true;
               signals[1].long_ticket = OrderTicket();
               if(use_recovery)
                  recoveries[1].long_tickets[0] = OrderTicket();
              }
            if(OrderType() == OP_SELL && OrderComment() == "FTP signal 1")
              {
               signals[1].in_short = true;
               signals[1].short_ticket = OrderTicket();
               if(use_recovery)
                  recoveries[1].short_tickets[0] = OrderTicket();
              }
            if(OrderType() == OP_BUY && OrderComment() == "FTP signal 2")
              {
               signals[2].in_long = true;
               signals[2].long_ticket = OrderTicket();
               if(use_recovery)
                  recoveries[2].long_tickets[0] = OrderTicket();
              }
            if(OrderType() == OP_SELL && OrderComment() == "FTP signal 2")
              {
               signals[2].in_short = true;
               signals[2].short_ticket = OrderTicket();
               if(use_recovery)
                  recoveries[2].short_tickets[0] = OrderTicket();
              }
            if(OrderType() == OP_BUY && OrderComment() == "FTP signal 3")
              {
               signals[3].in_long = true;
               signals[3].long_ticket = OrderTicket();
               if(use_recovery)
                  recoveries[3].long_tickets[0] = OrderTicket();
              }
            if(OrderType() == OP_SELL && OrderComment() == "FTP signal 3")
              {
               signals[3].in_short = true;
               signals[3].short_ticket = OrderTicket();
               if(use_recovery)
                  recoveries[3].short_tickets[0] = OrderTicket();
              }
            if(OrderType() == OP_BUY && OrderComment() == "FTP signal 4")
              {
               signals[4].in_long = true;
               signals[4].long_ticket = OrderTicket();
               if(use_recovery)
                  recoveries[4].long_tickets[0] = OrderTicket();
              }
            if(OrderType() == OP_SELL && OrderComment() == "FTP signal 4")
              {
               signals[4].in_short = true;
               signals[4].short_ticket = OrderTicket();
               if(use_recovery)
                  recoveries[4].short_tickets[0] = OrderTicket();
              }
            if(OrderType() == OP_BUY && OrderComment() == "FTP signal 5")
              {
               signals[5].in_long = true;
               signals[5].long_ticket = OrderTicket();
               if(use_recovery)
                  recoveries[5].long_tickets[0] = OrderTicket();
              }
            if(OrderType() == OP_SELL && OrderComment() == "FTP signal 5")
              {
               signals[5].in_short = true;
               signals[5].short_ticket = OrderTicket();
               if(use_recovery)
                  recoveries[5].short_tickets[0] = OrderTicket();
              }
            if(OrderType() == OP_BUY && OrderComment() == "FTP signal 6")
              {
               signals[6].in_long = true;
               signals[6].long_ticket = OrderTicket();
               if(use_recovery)
                  recoveries[6].long_tickets[0] = OrderTicket();
              }
            if(OrderType() == OP_SELL && OrderComment() == "FTP signal 6")
              {
               signals[6].in_short = true;
               signals[6].short_ticket = OrderTicket();
               if(use_recovery)
                  recoveries[6].short_tickets[0] = OrderTicket();
              }
            if(OrderType() == OP_BUY && OrderComment() == "FTP signal 7")
              {
               signals[7].in_long = true;
               signals[7].long_ticket = OrderTicket();
               if(use_recovery)
                  recoveries[7].long_tickets[0] = OrderTicket();
              }
            if(OrderType() == OP_SELL && OrderComment() == "FTP signal 7")
              {
               signals[7].in_short = true;
               signals[7].short_ticket = OrderTicket();
               if(use_recovery)
                  recoveries[7].short_tickets[0] = OrderTicket();
              }
            if(OrderType() == OP_BUY && OrderComment() == "FTP signal 8")
              {
               signals[8].in_long = true;
               signals[8].long_ticket = OrderTicket();
               if(use_recovery)
                  recoveries[8].long_tickets[0] = OrderTicket();
              }
            if(OrderType() == OP_SELL && OrderComment() == "FTP signal 8")
              {
               signals[8].in_short = true;
               signals[8].short_ticket = OrderTicket();
               if(use_recovery)
                  recoveries[8].short_tickets[0] = OrderTicket();
              }
            if(OrderType() == OP_BUY && OrderComment() == "FTP signal 9")
              {
               signals[9].in_long = true;
               signals[9].long_ticket = OrderTicket();
               if(use_recovery)
                  recoveries[9].long_tickets[0] = OrderTicket();
              }
            if(OrderType() == OP_SELL && OrderComment() == "FTP signal 9")
              {
               signals[9].in_short = true;
               signals[9].short_ticket = OrderTicket();
               if(use_recovery)
                  recoveries[9].short_tickets[0] = OrderTicket();
              }
            if(OrderType() == OP_BUY && OrderComment() == "FTP signal 10")
              {
               signals[10].in_long = true;
               signals[10].long_ticket = OrderTicket();
               if(use_recovery)
                  recoveries[10].long_tickets[0] = OrderTicket();
              }
            if(OrderType() == OP_SELL && OrderComment() == "FTP signal 10")
              {
               signals[10].in_short = true;
               signals[10].short_ticket = OrderTicket();
               if(use_recovery)
                  recoveries[10].short_tickets[0] = OrderTicket();
              }
            if(OrderType() == OP_BUY && OrderComment() == "FTP signal 11")
              {
               signals[11].in_long = true;
               signals[11].long_ticket = OrderTicket();
               if(use_recovery)
                  recoveries[11].long_tickets[0] = OrderTicket();
              }
            if(OrderType() == OP_SELL && OrderComment() == "FTP signal 11")
              {
               signals[11].in_short = true;
               signals[11].short_ticket = OrderTicket();
               if(use_recovery)
                  recoveries[11].short_tickets[0] = OrderTicket();
              }
            if(OrderType() == OP_BUY && OrderComment() == "FTP signal 12")
              {
               signals[12].in_long = true;
               signals[12].long_ticket = OrderTicket();
               if(use_recovery)
                  recoveries[12].long_tickets[0] = OrderTicket();
              }
            if(OrderType() == OP_SELL && OrderComment() == "FTP signal 12")
              {
               signals[12].in_short = true;
               signals[12].short_ticket = OrderTicket();
               if(use_recovery)
                  recoveries[12].short_tickets[0] = OrderTicket();
              }
            if(OrderType() == OP_BUY && OrderComment() == "FTP signal 13")
              {
               signals[13].in_long = true;
               signals[13].long_ticket = OrderTicket();
               if(use_recovery)
                  recoveries[13].long_tickets[0] = OrderTicket();
              }
            if(OrderType() == OP_SELL && OrderComment() == "FTP signal 13")
              {
               signals[13].in_short = true;
               signals[13].short_ticket = OrderTicket();
               if(use_recovery)
                  recoveries[13].short_tickets[0] = OrderTicket();
              }
            if(OrderType() == OP_BUY && OrderComment() == "FTP signal 14")
              {
               signals[14].in_long = true;
               signals[14].long_ticket = OrderTicket();
               if(use_recovery)
                  recoveries[14].long_tickets[0] = OrderTicket();
              }
            if(OrderType() == OP_SELL && OrderComment() == "FTP signal 14")
              {
               signals[14].in_short = true;
               signals[14].short_ticket = OrderTicket();
               if(use_recovery)
                  recoveries[14].short_tickets[0] = OrderTicket();
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void catch_orders_recovery()
  {
   if(use_recovery)
     {
      int total = OrdersTotal();
      for(int i = 0; i < total; i++)
        {
         if(OrderSelect(i, SELECT_BY_POS))
           {
            if(OrderSymbol() == _Symbol && OrderMagicNumber() == magic)
              {
               string catch_comment = OrderComment();
               if(StringSubstr(catch_comment, 0, 8) == "FTP_Rec_")
                 {
                  int catch_sig = (int) StringToInteger(StringSubstr(catch_comment, 8, 2));
                  int catch_knee = (int) StringToInteger(StringSubstr(catch_comment, 10, 2));

                  if(OrderType() == OP_BUY)
                     recoveries[catch_sig].long_tickets[catch_knee] = OrderTicket();
                  if(OrderType() == OP_SELL)
                     recoveries[catch_sig].short_tickets[catch_knee] = OrderTicket();
                 }
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
