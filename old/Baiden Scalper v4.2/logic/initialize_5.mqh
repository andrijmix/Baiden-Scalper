

void catch_orders() {
    int total = PositionsTotal();
    for (int i = 0; i < total; i++) {
        ulong ticket = PositionGetTicket(i);
        if (PositionSelectByTicket(ticket)) {
            for (int j = 0; j < SETS_NUM; j++) {
                if (PositionGetString(POSITION_SYMBOL) != sets[j].symbol)
                    continue;
                
                string test_magic = IntegerToString(PositionGetInteger(POSITION_MAGIC));
                int test_magic_len = StringLen(test_magic);
                int etalon_magic = sets[j].magic;
                int etalon_magic_len = StringLen(IntegerToString(etalon_magic));
                
                if ( (test_magic_len == etalon_magic_len + 4) ) {
                    int catch_magic = (int) StringSubstr(test_magic, 0, etalon_magic_len);
                    if (catch_magic == etalon_magic) {
                        int catch_sig  = (int) StringToInteger(StringSubstr(test_magic, etalon_magic_len, 2));
                        int catch_knee = (int) StringToInteger(StringSubstr(test_magic, etalon_magic_len + 2, 2));
                        
                        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) {
                            sets[j].signals[catch_sig].buy_grid[catch_knee] = ticket;
                            sets[j].signals[catch_sig].in_long = true;
                        }
                        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) {
                            sets[j].signals[catch_sig].sell_grid[catch_knee] = ticket;
                            sets[j].signals[catch_sig].in_short = true;
                        }
                    }
                }
            }
        }    
    }
}

//+------------------------------------------------------------------+
