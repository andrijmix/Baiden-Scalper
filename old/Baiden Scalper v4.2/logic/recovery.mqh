
void manage_grid(bool mode, int set_index, int sig_index) {
    double pips_profit = 0.0;
    double grid_tp = 0.0;
    
    if (mode) {
        if (sets[set_index].signals[sig_index].close_long_flag) {
            close_grid(BUY, set_index, sig_index);
            return;
        }
    
        if (sets[set_index].close_by == TAKE) {
            int total = get_last_order(mode, set_index, sig_index) + 1;
            for (int i = 0; i < total; i++)
                if (select_order_by_ticket(sets[set_index].signals[sig_index].buy_grid[i]))
                    pips_profit += calc_pips_profit(BUY, set_index, sig_index);
            
            grid_tp = calc_grid_tp(BUY, set_index, sig_index);
            
            if (pips_profit >= grid_tp) {
                close_grid(BUY, set_index, sig_index);
                return;
            }
        }
        
        if (sets[set_index].close_by == MA) {
            double ma = i_ma(sets[set_index].symbol, sets[set_index].tf, sets[set_index].signals[sig_index].std_period, 0, MODE_SMA, PRICE_CLOSE, 1);
            double price_close = iClose(sets[set_index].symbol, sets[set_index].tf, 1);
            
            if (price_close > ma) {
                close_grid(BUY, set_index, sig_index);
                return;
            }    
        }
        
        /* New knee opening block */
        if (sets[set_index].use_recovery) {     
            int last_index = get_last_order(mode, set_index, sig_index);
            if (last_index <= sets[set_index].max_orders - 2)
                if (select_order_by_ticket(sets[set_index].signals[sig_index].buy_grid[last_index]))
                    if (get_price_open() - get_ask(set_index) >= sets[set_index].grid_step * 10 * get_point(set_index))
                        open_order_retry(BUY, set_index, sig_index);
        }           
    } else {
        if (sets[set_index].signals[sig_index].close_short_flag) {
            close_grid(SELL, set_index, sig_index);
            return;
        }
    
        if (sets[set_index].close_by == TAKE) {
            int total = get_last_order(mode, set_index, sig_index) + 1;
            for (int i = 0; i < total; i++)
                if (select_order_by_ticket(sets[set_index].signals[sig_index].sell_grid[i]))
                    pips_profit += calc_pips_profit(SELL, set_index, sig_index);             
            
            grid_tp = calc_grid_tp(SELL, set_index, sig_index);
            
            if (pips_profit >= sets[set_index].take_profit) {
                close_grid(SELL, set_index, sig_index);
                return;
            }
        }
        
        if (sets[set_index].close_by == MA) {
            double ma = i_ma(sets[set_index].symbol, sets[set_index].tf, sets[set_index].signals[sig_index].std_period, 0, MODE_SMA, PRICE_CLOSE, 1);
            double price_close = iClose(sets[set_index].symbol, sets[set_index].tf, 1);
            
            if (price_close < ma) {
                close_grid(SELL, set_index, sig_index);
                return;
            }    
        }        
        
        /* New knee opening block */
        if (sets[set_index].use_recovery) {      
            int last_index = get_last_order(mode, set_index, sig_index);
            if (last_index <= sets[set_index].max_orders - 2)
                if (select_order_by_ticket(sets[set_index].signals[sig_index].sell_grid[last_index]))
                    if (get_bid(set_index) - get_price_open() >= sets[set_index].grid_step * 10 * get_point(set_index))
                        open_order_retry(SELL, set_index, sig_index);
        }             
    }
}

//+------------------------------------------------------------------+

double calc_pips_profit(bool mode, int set_index, int sig_index) {
    double profit;
    double bid;
    double ask;
    double price_open;
    double volume;
    double start_grid_lot;
    
    price_open = get_price_open();
    volume = get_volume();
    start_grid_lot = get_start_lot(mode, set_index, sig_index);
    
    if (start_grid_lot < 0.001) return 0.0;
        
    if (mode) {//buy
        bid = SymbolInfoDouble(sets[set_index].symbol, SYMBOL_BID);      
        profit = bid - price_open;
        profit = profit / start_grid_lot * volume;
        return profit / get_point(set_index) / 10;
    } else {
        ask = SymbolInfoDouble(sets[set_index].symbol, SYMBOL_ASK);
        profit = price_open - ask;
        profit = profit / start_grid_lot * volume;
        return profit / get_point(set_index) / 10;
    }
    return 0.0;
}

//+------------------------------------------------------------------+

/* Returns last grid order index */
int get_last_order(bool mode, int set_index, int sig_index) {
    int counter = 0;
    if (mode) { //buy
        for (int i = 0; i < sets[set_index].max_orders; i++) {            
            if (sets[set_index].signals[sig_index].buy_grid[i] <= 0)
                break;
            counter = i;
        }        
    } else {
        for (int i = 0; i < sets[set_index].max_orders; i++) {
            if (sets[set_index].signals[sig_index].sell_grid[i] <= 0)
                break;
            counter = i; 
        }
    }   
    return counter;
}

//+------------------------------------------------------------------+

void close_grid(bool mode, int set_index, int sig_index) {
    for (int j = 0; j < RETRY; j++) {
        if (mode) { // buy            
            for (int i = 0; i < sets[set_index].max_orders; i++) {
                ulong ticket = sets[set_index].signals[sig_index].buy_grid[i];
                if (ticket <= 0) continue;
                close_order_retry(BUY, ticket, set_index, sig_index, i);                
            }        
            if (count_orders(BUY, set_index, sig_index) == 0) {
                sets[set_index].signals[sig_index].in_long = false;
                sets[set_index].signals[sig_index].close_long_flag = false;
                return;
            } else {
                sets[set_index].signals[sig_index].close_long_flag = true;
                Print("Failed to close buy grid, retry...");
                Sleep(SLEEP);
            }
        } else {
            for (int i = 0; i < sets[set_index].max_orders; i++) {
                ulong ticket = sets[set_index].signals[sig_index].sell_grid[i];
                if (ticket <= 0) continue;
                close_order_retry(SELL, ticket, set_index, sig_index, i);                
            }        
            if (count_orders(SELL, set_index, sig_index) == 0) {
                sets[set_index].signals[sig_index].in_short = false;
                sets[set_index].signals[sig_index].close_short_flag = false;
                return;
            } else {
                sets[set_index].signals[sig_index].close_short_flag = true;
                Print("Failed to close sell grid, retry...");
                Sleep(SLEEP);
            }
        }
    }
    
    Print("After ", RETRY, " tries and more than minute of time grid was NOT closed. Waiting for the next bar.");
}

//+------------------------------------------------------------------+

double calc_lot(int set_index, int num_orders) {
    double lot_size = sets[set_index].lot;
    double mm_lot = lot_size;
    
    if (depo_per_lot != 0) {
        double balance = AccountInfoDouble(ACCOUNT_BALANCE);
        lot_size = balance / depo_per_lot * sets[set_index].lot;
        mm_lot = lot_size;
    }
    
    if (num_orders >= sets[set_index].start_factor_knee - 1) {
        for (int i = sets[set_index].start_factor_knee - 1; i <= num_orders; i++) {
            if (use_arithmetic_multiplier)
                lot_size += mm_lot;
            else    
                lot_size *= sets[set_index].recovery_factor;
        }    
    }
        
    lot_size *= 100.0;
    lot_size = MathFloor(lot_size);
    lot_size /= 100.0;
    
    return lot_size;
}

//+------------------------------------------------------------------+

int count_orders(bool mode, int set_index, int sig_index) {
    int grid_total = 0; 
    
    if (mode) { //buy        
        for (int i = 0; i < sets[set_index].max_orders; i++) {
            if (sets[set_index].signals[sig_index].buy_grid[i] != 0)
                grid_total++;         
        }     
    } else {        
        for (int i = 0; i < sets[set_index].max_orders; i++) {
            if (sets[set_index].signals[sig_index].sell_grid[i] != 0)
                grid_total++;            
        }     
    }
    return grid_total;
}

//+------------------------------------------------------------------+

double calc_grid_tp(bool mode, int set_index, int sig_index) {
    if (sets[set_index].bar_to_reduce == 0) return sets[set_index].take_profit;
    
    double new_tp = sets[set_index].take_profit;
    datetime start_grid_time;
    int bars_shift;
    
    if (mode) {
        if (select_order_by_ticket(sets[set_index].signals[sig_index].buy_grid[0])) {
            start_grid_time = get_open_time();
            bars_shift = iBarShift(sets[set_index].symbol, sets[set_index].tf, start_grid_time, true);
            
            if (bars_shift >= 0) {
                if (bars_shift >= sets[set_index].bar_to_reduce) {
                    int shift = bars_shift - sets[set_index].bar_to_reduce;
                    for (int i = 0; i < shift; i++)
                        new_tp -= sets[set_index].take_reduce;
                    
                    if (new_tp <= sets[set_index].take_reduce_limit)
                        new_tp = sets[set_index].take_reduce_limit;
                }
            } else {
                Print("Start grid bar not found.");
                Print("Take profit was NOT reduced. Use normal take instead.");
            }    
        } else {
            Print("Error selecting order in ", __FUNCTION__, ", file ", __FILE__, ", line ", __LINE__, ": ", GetLastError());
            Print("Take profit was NOT reduced. Use normal take instead.");
        }  
    } else {
        if (select_order_by_ticket(sets[set_index].signals[sig_index].sell_grid[0])) {
            start_grid_time = get_open_time();
            bars_shift = iBarShift(sets[set_index].symbol, sets[set_index].tf, start_grid_time, true);
            
            if (bars_shift >= 0) {
                if (bars_shift >= sets[set_index].bar_to_reduce) {
                    int shift = bars_shift - sets[set_index].bar_to_reduce;
                    for (int i = 0; i < shift; i++)
                        new_tp -= sets[set_index].take_reduce;
                    
                    if (new_tp <= sets[set_index].take_reduce_limit)
                        new_tp = sets[set_index].take_reduce_limit;
                }
            } else {
                Print("Start grid bar not found.");
                Print("Take profit was NOT reduced. Use normal take instead.");
            }    
        } else {
            Print("Error selecting order in ", __FUNCTION__, ", file ", __FILE__, ", line ", __LINE__, ": ", GetLastError());
            Print("Take profit was NOT reduced. Use normal take instead.");
        }
    }
    
    return new_tp;
}

//+------------------------------------------------------------------+
