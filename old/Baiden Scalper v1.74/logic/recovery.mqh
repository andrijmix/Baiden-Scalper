
void manage_grid(bool mode, int index) {
    double pips_profit = 0.0;
    
    if (mode) {
        if (recoveries[index].buy_close_flag) {
            close_grid(buy, index);
            return;
        }
        
        if (close_by == TAKE) {
            int total = get_last_order(mode, index) + 1;
            for (int i = 0; i < total; i++)
                if (OrderSelect(recoveries[index].long_tickets[i], SELECT_BY_TICKET))
                    pips_profit += calc_pips_profit(buy);
            
            if (pips_profit >= recovery_take_profit) {
                close_grid(buy, index);
                return;
            }
        }    
        
        if (close_by == MA) {                                       
            double ma = iMA(_Symbol, PERIOD_CURRENT, signals[index].ma_period, 0, MODE_SMA, PRICE_CLOSE, 1);
            double price_close = iClose(_Symbol, PERIOD_CURRENT, 1);
            
            if (price_close > ma) {
                close_grid(buy, index);
                return;
            }    
        }
        
        /* New knee opening block */
        int last_index = get_last_order(buy, index);
        if (last_index <= max_orders - 2) {
            if (OrderSelect(recoveries[index].long_tickets[last_index], SELECT_BY_TICKET)) {
                double price_open = OrderOpenPrice();
                if (price_open - Ask >= grid_step * 10 * _Point) {
                    if (!open_grid_order(buy, index)) {
                        for (int j = 1; j < retry; j++) {
                            Print("Не удалось открыть ордер рекавери на покупку: ошибка ", GetLastError(), ", новая попытка...");
                            Sleep(1000);                            
                            if (open_grid_order(buy, index)) break;
                        }
                    }
                }    
            }            
        }
    } else {
        if (recoveries[index].sell_close_flag) {
            close_grid(sell, index);
            return;
        }
        
        if (close_by == TAKE) {
            int total = get_last_order(mode, index) + 1;
            for (int i = 0; i < total; i++)
                if (OrderSelect(recoveries[index].short_tickets[i], SELECT_BY_TICKET))
                    pips_profit += calc_pips_profit(sell);               
            
            if (pips_profit >= recovery_take_profit) {
                close_grid(sell, index);
                return;
            }
        }
        
        if (close_by == MA) {
            double ma = iMA(_Symbol, PERIOD_CURRENT, signals[index].ma_period, 0, MODE_SMA, PRICE_CLOSE, 1);
            double price_close = iClose(_Symbol, PERIOD_CURRENT, 1);
            
            if (price_close < ma) {
                close_grid(sell, index);
                return;
            }       
        }
        
        /* New knee opening block */
        int last_index = get_last_order(sell, index);
        if (last_index <= max_orders - 2) {
            if (OrderSelect(recoveries[index].short_tickets[last_index], SELECT_BY_TICKET)) {
                double price_open = OrderOpenPrice();
                if (Bid - price_open >= grid_step * 10 * _Point) {
                    if (!open_grid_order(sell, index)) {
                        for (int j = 1; j < retry; j++) {
                            Print("Не удалось открыть ордер рекавери на продажу: ошибка ", GetLastError(), ", новая попытка...");
                            Sleep(1000);                            
                            if (open_grid_order(sell, index)) break;
                        }
                    }
                }    
            }            
        } 
    }
}

//+------------------------------------------------------------------+

double calc_pips_profit(bool mode) {
    double profit = 0.0;
    double start_grid_lot = lot;
        
    if (mode) {//buy        
        profit = Bid - OrderOpenPrice();
        profit = profit / start_grid_lot * OrderLots();
        return profit / _Point / 10;        
    } else {   
        profit = OrderOpenPrice() - Ask;
        profit = profit / start_grid_lot * OrderLots();
        return profit / _Point / 10;        
    }
    return 0.0;
}

//+------------------------------------------------------------------+

int count_orders(bool mode, int index) {
    int grid_total = 0;
    
    
    if (mode) { //buy
        
        for (int i = 0; i < max_orders; i++) {
            if (recoveries[index].long_tickets[i] != 0)
                grid_total++;            
        }     
    } else {        
        for (int i = 0; i < max_orders; i++) {
            if (recoveries[index].short_tickets[i] != 0)
                grid_total++;            
        }     
    }
    return grid_total;
}

//+------------------------------------------------------------------+

/* Returns last grid order index */
int get_last_order(bool mode, int index) {
    int counter = 0;
    if (mode) { //buy
        for (int i = 0; i < max_orders; i++) {            
            if (recoveries[index].long_tickets[i] <= 0)
                break;
            counter = i;    
        }        
    } else {
        for (int i = 0; i < max_orders; i++) {            
            if (recoveries[index].short_tickets[i] <= 0)
                break;
            counter = i;    
        }
    }   
    return counter; 
}

//+------------------------------------------------------------------+

void close_grid(bool mode, int index) {
    for (int j = 0; j < retry; j++) {
        if (mode) { // buy            
            for (int i = max_orders - 1; i >= 0; i--) {
                if (recoveries[index].long_tickets[i] <= 0) continue;
                if (!close_grid_order(mode, recoveries[index].long_tickets[i])) {
                    Print("failed to close order, error ", GetLastError());
                    recoveries[index].buy_close_flag = true;
                } else
                    recoveries[index].long_tickets[i] = 0;
            }        
            if (count_orders(buy, index) == 0) {
                signals[index].in_long = false;
                signals[index].long_ticket = 0;
                recoveries[index].buy_close_flag = false;
                return;
            } else {
                Print("Failed to close buy grid, another try...");
                Sleep(1000);
            }    
        } else {
            for (int i = max_orders - 1; i >= 0; i--) {
                if (recoveries[index].short_tickets[i] <= 0) continue;
                if (!close_grid_order(mode, recoveries[index].short_tickets[i])) {
                    Print("failed to close order, error ", GetLastError());
                    recoveries[index].sell_close_flag = true;
                } else
                    recoveries[index].short_tickets[i] = 0;
            }        
            if (count_orders(sell, index) == 0) {
                signals[index].in_short = false;
                signals[index].short_ticket = 0;
                recoveries[index].sell_close_flag = false;
                return;
            } else {
                Print("Failed to close sell grid, another try...");
                Sleep(1000);
            }    
        }
    }
}

//+------------------------------------------------------------------+

bool close_grid_order(bool mode, int ticket) {
    double price = 0.0;
    color clr = Green;
    
    if (mode) {
        price = Bid;
        clr = Blue;
    } else {
        price = Ask;
        clr = Red;
    }
         
    if (mode) {
        if (OrderSelect(ticket, SELECT_BY_TICKET)) {                   
            if (OrderClose(ticket, OrderLots(), price, slippage, clr)) {                
                return true;
            } else
                return false;
        }  
    } else {
        if (OrderSelect(ticket, SELECT_BY_TICKET)) {                   
            if (OrderClose(ticket, OrderLots(), price, slippage, clr)) {                
                return true;
            } else
                return false;
        } 
    }
    return false;
}

//+------------------------------------------------------------------+

bool open_grid_order(bool mode, int index) {
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
    
    if (index < 10)
        comment_index = "0" + IntegerToString(index);
    else
        comment_index = IntegerToString(index);
    
    if (mode) { //buy
        num_buy_orders = count_orders(buy, index);
                
        if (num_buy_orders < 10)
            comment_num_buy = "0" + IntegerToString(num_buy_orders);
        else
            comment_num_buy = IntegerToString(num_buy_orders);  
                  
        order_type = OP_BUY;
        price = Ask;
        clr = Blue;
        lot_size = calc_lot(num_buy_orders);
        comment_open = comment + "_Rec_" + comment_index + comment_num_buy;
    } else {
        num_sell_orders = count_orders(sell, index);
        
        if (num_sell_orders < 10)
            comment_num_sell = "0" + IntegerToString(num_sell_orders);
        else
            comment_num_sell = IntegerToString(num_sell_orders);
        
        order_type = OP_SELL;
        price = Bid;
        clr = Red;
        lot_size = calc_lot(num_sell_orders);
        comment_open = comment + "_Rec_" + comment_index + comment_num_sell;
    }
    
    
    
    if (mode) { //buy
        int ticket = OrderSend(_Symbol, order_type, lot_size, price, slippage, sl, tp, comment_open, magic, 0, clr);
        if (ticket > 0) {
            recoveries[index].long_tickets[num_buy_orders] = ticket;
            return true;
        } else return false; 
    } else {
        int ticket = OrderSend(_Symbol, order_type, lot_size, price, slippage, sl, tp, comment_open, magic, 0, clr);
        if (ticket > 0) {
            recoveries[index].short_tickets[num_sell_orders] = ticket;
            return true;
        } else return false;
    }
}

//+------------------------------------------------------------------+

double calc_lot(int num_orders) {
    double lot_size = lot;
    
    if (num_orders >= start_factor_knee - 1) {
        for (int i = start_factor_knee - 1; i <= num_orders; i++)
            lot_size *= recovery_factor;
    }       
        
    lot_size *= 100.0;
    lot_size = MathFloor(lot_size);
    lot_size /= 100.0;
    
    return lot_size;
}

//+------------------------------------------------------------------+
