

//+------------------------------------------------------------------+

bool big_spread() {
    double spread = MarketInfo(_Symbol, MODE_SPREAD) / 10;
    if (spread > max_spread)
        return true;
    else
        return false;  
}

//+------------------------------------------------------------------+

bool is_new_bar() {   
    static datetime new_time = 0;
    
    if (new_time == 0) {
        new_time = Time[0];
        return false;
    }  
    
    if (new_time != Time[0]) {            
        new_time = Time[0];
        return true;
    }
    return false;
}

//+------------------------------------------------------------------+
