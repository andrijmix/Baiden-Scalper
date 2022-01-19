//+------------------------------------------------------------------+

bool big_spread(int i) {
    double spread = (double) (SymbolInfoInteger(sets[i].symbol, SYMBOL_SPREAD) / 10);
    
    if (spread > sets[i].max_spread)
        return true;
    else
        return false;  
}

//+------------------------------------------------------------------+

bool is_new_bar(int i) {
    datetime curr_time = iTime(sets[i].symbol, sets[i].tf, 0);
    
    if (new_times[i] == 0) {
        new_times[i] = curr_time;
        return false;
    }  
    
    if (new_times[i] != curr_time) {            
        new_times[i] = curr_time;
        return true;
    }
    return false;
}

//+------------------------------------------------------------------+

bool is_new_year() {
    TimeCurrent(time);
    
    if ((time.mon == 12 && time.day >= NY_START) || (time.mon == 1 && time.day <= NY_END))
        return true;
    
    return false;
}

//+------------------------------------------------------------------+
