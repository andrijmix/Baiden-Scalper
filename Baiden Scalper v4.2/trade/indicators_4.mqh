
double i_ma(string _symbol, ENUM_TIMEFRAMES _tf, int ma_period, int ma_shift, ENUM_MA_METHOD ma_method, int applied_price, int bar) {
    return iMA(_symbol, _tf, ma_period, ma_shift, ma_method, applied_price, bar);
}

//+------------------------------------------------------------------+

double i_stdev(string _symbol, ENUM_TIMEFRAMES _tf, int ma_period, int ma_shift, ENUM_MA_METHOD ma_method, int applied_price, int bar) {
    return iStdDev(_symbol, _tf, ma_period, ma_shift, ma_method, applied_price, bar);
}

//+------------------------------------------------------------------+

double i_atr(string _symbol, ENUM_TIMEFRAMES _tf, int _atr_period, int bar) {
    return iATR(_symbol, _tf, _atr_period, bar);
}

//+------------------------------------------------------------------+
