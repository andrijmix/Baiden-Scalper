

/* returns true if we are in trade range */
bool time_check() {
    datetime current   = TimeCurrent();
    int      time_hour = TimeHour(current);
    int      time_min  = TimeMinute(current);
    int      mon       = TimeMonth(current);
    int      day       = TimeDay(current);    
    
    /* Check new year */
    if ( (mon == 12 && day >= new_year_start) || (mon == 1 && day <= new_year_end))
        return false;
    
    /* Check trade hours */
    bool over_night = false;
    
    if (start_trade_hour > end_trade_hour)
        over_night = true;
    else if (start_trade_hour == end_trade_hour) {
        if (start_trade_minute > end_trade_minute)
            over_night = true;
    }            
    
    bool check_1 = false;
    bool check_2 = false;    
    
    if (time_hour > start_trade_hour) {
        if (time_hour < 23) {
            check_1 = true;
        } else if (time_hour == 23) {
            if (time_min <= 59) {
                check_1 = true;
            }
        }            
    } else if (time_hour == start_trade_hour) {
        if (time_min >= start_trade_minute) {
            check_1 = true;
        }
    }
    
    if (time_hour < end_trade_hour) {
        check_2 = true;                    
    } else if (time_hour == end_trade_hour) {
        if (time_min <= end_trade_minute) {
            check_2 = true;
        }
    }
    
    if (over_night) {
        if (check_1 || check_2)
            return true;
    } else {
        if (check_1 && check_2)
            return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
