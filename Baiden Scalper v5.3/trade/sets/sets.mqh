
void init_sets() {
    #ifdef IS_OPT
        load_set(0);
    #endif
    
    #ifndef IS_OPT
        int i = 0;
        //#include "eurusd.mqh" i++;
        //#include "audcad.mqh" i++;
        //#include "eurgbp.mqh" i++;
    #endif
}

//+------------------------------------------------------------------+

void load_set(int i) {
    //General
    sets[i].symbol = symbol;
    sets[i].magic = magic;
    sets[i].max_spread = max_spread;
    sets[i].deviation = deviation;
    sets[i].trade_buy = trade_buy;
    sets[i].trade_sell = trade_sell;
    sets[i].tf = tf;
    sets[i].set_name = set_name;
    
    //MM
    sets[i].lot = lot;
    sets[i].depo_per_lot = depo_per_lot;
    sets[i].take_profit = take_profit;
    sets[i].stop_loss = stop_loss;
    
    //ATR
    sets[i].atr_period = atr_period;
    sets[i].atr_above = atr_above;
    
    //Recovery
    sets[i].use_recovery = use_recovery;
    sets[i].grid_step = grid_step;
    sets[i].max_orders = max_orders;    
    sets[i].recovery_factor = recovery_factor;
    sets[i].start_factor_knee = start_factor_knee;
    sets[i].close_by = close_by;
    
    //Signal 1
    sets[i].signals[0].std_period = std_period_1;
    sets[i].signals[0].std_level = std_level_1;
    sets[i].signals[0].include_ma_as_filter = include_ma_as_filter_1;
    
    //Signal 2
    sets[i].signals[1].std_period = std_period_2;
    sets[i].signals[1].std_level = std_level_2;
    sets[i].signals[1].include_ma_as_filter = include_ma_as_filter_2;
    
    //Signal 3
    sets[i].signals[2].std_period = std_period_3;
    sets[i].signals[2].std_level = std_level_3;
    sets[i].signals[2].include_ma_as_filter = include_ma_as_filter_3;
    
    //Signal 4
    sets[i].signals[3].std_period = std_period_4;
    sets[i].signals[3].std_level = std_level_4;
    sets[i].signals[3].include_ma_as_filter = include_ma_as_filter_4;
    
    //Signal 5
    sets[i].signals[4].std_period = std_period_5;
    sets[i].signals[4].std_level = std_level_5;
    sets[i].signals[4].include_ma_as_filter = include_ma_as_filter_5;
    
    //Signal 6
    sets[i].signals[5].std_period = std_period_6;
    sets[i].signals[5].std_level = std_level_6;
    sets[i].signals[5].include_ma_as_filter = include_ma_as_filter_6;
    
    //Signal 7
    sets[i].signals[6].std_period = std_period_7;
    sets[i].signals[6].std_level = std_level_7;
    sets[i].signals[6].include_ma_as_filter = include_ma_as_filter_7;
    
    //Signal 8
    sets[i].signals[7].std_period = std_period_8;
    sets[i].signals[7].std_level = std_level_8;
    sets[i].signals[7].include_ma_as_filter = include_ma_as_filter_8;
    
    //Signal 9
    sets[i].signals[8].std_period = std_period_9;
    sets[i].signals[8].std_level = std_level_9;
    sets[i].signals[8].include_ma_as_filter = include_ma_as_filter_9;
    
    //Signal 10
    sets[i].signals[9].std_period = std_period_10;
    sets[i].signals[9].std_level = std_level_10;
    sets[i].signals[9].include_ma_as_filter = include_ma_as_filter_10;
    
    //Signal 11
    sets[i].signals[10].std_period = std_period_11;
    sets[i].signals[10].std_level = std_level_11;
    sets[i].signals[10].include_ma_as_filter = include_ma_as_filter_11;
    
    //Signal 12
    sets[i].signals[11].std_period = std_period_12;
    sets[i].signals[11].std_level = std_level_12;
    sets[i].signals[11].include_ma_as_filter = include_ma_as_filter_12;
    
    //Signal 13
    sets[i].signals[12].std_period = std_period_13;
    sets[i].signals[12].std_level = std_level_13;
    sets[i].signals[12].include_ma_as_filter = include_ma_as_filter_13;
    
    //Signal 14
    sets[i].signals[13].std_period = std_period_14;
    sets[i].signals[13].std_level = std_level_14;
    sets[i].signals[13].include_ma_as_filter = include_ma_as_filter_14;
    
    //Signal 15
    sets[i].signals[14].std_period = std_period_15;
    sets[i].signals[14].std_level = std_level_15;
    sets[i].signals[14].include_ma_as_filter = include_ma_as_filter_15;
}

//+------------------------------------------------------------------+
