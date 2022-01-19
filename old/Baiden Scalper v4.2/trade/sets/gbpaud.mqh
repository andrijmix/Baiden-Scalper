
//General
sets[i].symbol = "GBPAUD";
sets[i].magic = 5757;
sets[i].max_spread = 10;
sets[i].deviation = 3;
sets[i].trade_buy = true;
sets[i].trade_sell = true;
sets[i].tf = PERIOD_M30;
sets[i].set_name = "GBPAUD M30 RecTP v4.6";

//MM
sets[i].lot = 0.01;
sets[i].take_profit = 48.0;

//ATR
sets[i].atr_period = 14;
sets[i].atr_above = 0.08;

//Recovery
sets[i].use_recovery = true;
sets[i].use_arithmetic_multiplier = false;
sets[i].grid_step = 67;
sets[i].max_orders = 11;
sets[i].recovery_factor = 3.0;
sets[i].start_factor_knee = 4;
sets[i].close_by = TAKE;
sets[i].bar_to_reduce = 0;
sets[i].take_reduce = 5;
sets[i].take_reduce_limit = 0.0;

//Signal 1
sets[i].signals[0].std_period = 350;
sets[i].signals[0].std_level = 0.009;
sets[i].signals[0].include_ma_as_filter = true;

//Signal 2
sets[i].signals[1].std_period = 295;
sets[i].signals[1].std_level = 0.001;
sets[i].signals[1].include_ma_as_filter = true;

//Signal 3
sets[i].signals[2].std_period = 105;
sets[i].signals[2].std_level = 0.005;
sets[i].signals[2].include_ma_as_filter = true;

//Signal 4
sets[i].signals[3].std_period = 440;
sets[i].signals[3].std_level = 0.008;
sets[i].signals[3].include_ma_as_filter = false;

//Signal 5
sets[i].signals[4].std_period = 45;
sets[i].signals[4].std_level = 0.001;
sets[i].signals[4].include_ma_as_filter = false;

//Signal 6
sets[i].signals[5].std_period = 420;
sets[i].signals[5].std_level = 0.004;
sets[i].signals[5].include_ma_as_filter = false;

//Signal 7
sets[i].signals[6].std_period = 550;
sets[i].signals[6].std_level = 0.002;
sets[i].signals[6].include_ma_as_filter = false;

//Signal 8
sets[i].signals[7].std_period = 340;
sets[i].signals[7].std_level = 0.003;
sets[i].signals[7].include_ma_as_filter = false;

//Signal 9
sets[i].signals[8].std_period = 355;
sets[i].signals[8].std_level = 0.002;
sets[i].signals[8].include_ma_as_filter = false;

//Signal 10
sets[i].signals[9].std_period = 150;
sets[i].signals[9].std_level = 0.01;
sets[i].signals[9].include_ma_as_filter = false;

//Signal 11
sets[i].signals[10].std_period = 465;
sets[i].signals[10].std_level = 0.004;
sets[i].signals[10].include_ma_as_filter = false;

//Signal 12
sets[i].signals[11].std_period = 580;
sets[i].signals[11].std_level = 0.005;
sets[i].signals[11].include_ma_as_filter = false;

//Signal 13
sets[i].signals[12].std_period = 330;
sets[i].signals[12].std_level = 0.002;
sets[i].signals[12].include_ma_as_filter = false;

//Signal 14
sets[i].signals[13].std_period = 80;
sets[i].signals[13].std_level = 0.004;
sets[i].signals[13].include_ma_as_filter = false;

//Signal 15
sets[i].signals[14].std_period = 175;
sets[i].signals[14].std_level = 0.008;
sets[i].signals[14].include_ma_as_filter = false;
    
//+------------------------------------------------------------------+ 
