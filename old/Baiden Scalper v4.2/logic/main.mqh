//+------------------------------------------------------------------+

int init_ea() {
    is_test = (bool) MQLInfoInteger(MQL_TESTER);
    Comment("");
    
    /* license check */
    if (license_check && account != AccountInfoInteger(ACCOUNT_LOGIN)) {
        Comment("Trading on this account FORBIDDEN.");
        return INIT_PARAMETERS_INCORRECT;
    }
    
    draw_logo();
    init_sets();
    
    #ifdef MQL5 init_symbol_info(); #endif
    
    for (int i = 0; i < SETS_NUM; i++) {
        for (int j = 0; j < SIGNALS; j++) {
            if (sets[i].signals[j].include_ma_as_filter)
                sets[i].activated_mas++;
            ArrayResize(sets[i].signals[j].buy_grid, sets[i].max_orders);
            ArrayResize(sets[i].signals[j].sell_grid, sets[i].max_orders);
            ArrayInitialize(sets[i].signals[j].buy_grid, 0);
            ArrayInitialize(sets[i].signals[j].sell_grid, 0);
        }
    }
    
    if (!is_test) catch_orders();
    
    #ifdef IS_OPT
        //if (!is_test) create_panel();
    #endif
    
    //TesterHideIndicators(true);
    
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+

void tick_handler() {
    if (!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) return;
    
    for (int i = 0; i < SETS_NUM; i++) { 
        if (is_new_bar(i)) {
            if (big_spread(i)) continue;
        
            for (int j = 0; j < SIGNALS; j++) {
                if (sets[i].signals[j].std_period == 0) continue;
            
                if (sets[i].trade_buy && !sets[i].signals[j].in_long && !is_new_year()) 
                    start_grid(BUY, i, j);
            
                if (sets[i].trade_sell && !sets[i].signals[j].in_short && !is_new_year())
                    start_grid(SELL, i, j);
                    
                if (sets[i].signals[j].in_long)  manage_grid(BUY, i, j);
                if (sets[i].signals[j].in_short) manage_grid(SELL, i, j);
            }       
        }
    }
    
    find_global_stop();
}

//+------------------------------------------------------------------+

void start_grid(bool mode, int set_index, int sig_index) {
    if (mode) {
        if (is_signal(BUY, set_index, sig_index))
            open_order_retry(BUY, set_index, sig_index);
    } else {
        if (is_signal(SELL, set_index, sig_index))
            open_order_retry(SELL, set_index, sig_index);
    }
}

//+------------------------------------------------------------------+

/* returns true if movings are in right order */
bool compare_movings(bool mode, int set_index) {
    double movings[];
    int ma_periods[SIGNALS];
    ArrayResize(movings, sets[set_index].activated_mas);
    ArrayInitialize(movings, 0);
    ArrayInitialize(ma_periods, 0);
    
    for (int i = 0; i < SIGNALS; i++)
        if (sets[set_index].signals[i].include_ma_as_filter)
            ma_periods[i] = sets[set_index].signals[i].std_period; //std_period == ma_period
     
    ArraySort(ma_periods);

    int counter = 0;
    
    for (int i = 0; i < SIGNALS; i++)
        if (ma_periods[i] != 0)
            movings[counter++] = i_ma(sets[set_index].symbol, sets[set_index].tf, ma_periods[i], 0, MODE_SMA, PRICE_CLOSE, 1); 

    if (mode) {
        for (int i = 0; i < sets[set_index].activated_mas - 1; i++)
            if ( !(movings[i] < movings[i+1]) )
                return false; 
    } else {
        for (int i = 0; i < sets[set_index].activated_mas - 1; i++)
            if ( !(movings[i] > movings[i+1]) )
                return false;
    }
    
    if (mode && SymbolInfoDouble(sets[set_index].symbol, SYMBOL_ASK) < movings[0])
        return true;
    
    if (!mode && SymbolInfoDouble(sets[set_index].symbol, SYMBOL_BID) > movings[0])
        return true;

    return false;    
}

//+------------------------------------------------------------------+

/* return true if there is a signal */
bool is_signal(bool mode, int set_index, int sig_index) {        
    if (mode) {
        if (compare_movings(BUY, set_index)) {
            double std_curr = i_stdev(sets[set_index].symbol, sets[set_index].tf, sets[set_index].signals[sig_index].std_period, 0, MODE_SMA, PRICE_CLOSE, 1);
            double std_prev = i_stdev(sets[set_index].symbol, sets[set_index].tf, sets[set_index].signals[sig_index].std_period, 0, MODE_SMA, PRICE_CLOSE, 2);
            if (std_curr >= sets[set_index].signals[sig_index].std_level && std_prev < sets[set_index].signals[sig_index].std_level)
            {
                double atr = i_atr(sets[set_index].symbol, atr_tf, sets[set_index].atr_period, 1);
                if (atr < sets[set_index].atr_above)                
                    return true;
                                    if (atr > sets[set_index].atr_under)                
                    return true;
            }
        }
    } else {
        if (compare_movings(SELL, set_index)) {
            double std_curr = i_stdev(sets[set_index].symbol, sets[set_index].tf, sets[set_index].signals[sig_index].std_period, 0, MODE_SMA, PRICE_CLOSE, 1);
            double std_prev = i_stdev(sets[set_index].symbol, sets[set_index].tf, sets[set_index].signals[sig_index].std_period, 0, MODE_SMA, PRICE_CLOSE, 2);
            if (std_curr >= sets[set_index].signals[sig_index].std_level && std_prev < sets[set_index].signals[sig_index].std_level)
            {   
                double atr = i_atr(sets[set_index].symbol, atr_tf, sets[set_index].atr_period, 1);
                if (atr < sets[set_index].atr_above)                
                    return true;
            }
        }
    }
    return false;
}

//+------------------------------------------------------------------+

void find_global_stop() {
    if (stop_loss == 0) return;
    
    double balance = AccountInfoDouble(ACCOUNT_BALANCE);
    double profit = AccountInfoDouble(ACCOUNT_PROFIT);
    
    if (profit < 0 && profit / balance * 100 <= -stop_loss) {
        Print("Stop Loss reached. Closing all orders.");
        close_all_orders();
    }    
}

//+------------------------------------------------------------------+

void close_all_orders() {
    for (int i = 0; i < SETS_NUM; i++) {
        for (int j = 0; j < SIGNALS; j++) {
            if (sets[i].signals[j].in_long)
                close_grid(BUY, i, j);
            if (sets[i].signals[j].in_short)
                close_grid(SELL, i, j);    
        }
    }    
}

//+------------------------------------------------------------------+
