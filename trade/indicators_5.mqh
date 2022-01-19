
double i_ma(string _symbol, ENUM_TIMEFRAMES _tf, int ma_period, int ma_shift, ENUM_MA_METHOD ma_method, int applied_price, int bar) {
    int ma_handle = iMA(_symbol, _tf, ma_period, ma_shift, ma_method, applied_price);
    double ma_buffer[1];
    CopyBuffer(ma_handle, 0, bar, 1, ma_buffer);
    return ma_buffer[0];
}

//+------------------------------------------------------------------+

double i_stdev(string _symbol, ENUM_TIMEFRAMES _tf, int ma_period, int ma_shift, ENUM_MA_METHOD ma_method, int applied_price, int bar) {
    int std_handle = iStdDev(_symbol, _tf, ma_period, ma_shift, ma_method, applied_price);
    double std_buffer[1];
    CopyBuffer(std_handle, 0, bar, 1, std_buffer);
    return std_buffer[0];
}

//+------------------------------------------------------------------+
