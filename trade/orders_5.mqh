
bool select_order_by_ticket(ulong ticket) {
    if (PositionSelectByTicket(ticket))
        return true;
    
    return false;
}

//+------------------------------------------------------------------+

double get_price_open() {
    return PositionGetDouble(POSITION_PRICE_OPEN);
}

//+------------------------------------------------------------------+

double get_volume() {
    return PositionGetDouble(POSITION_VOLUME);
}

//+------------------------------------------------------------------+

int close_order(bool mode, ulong ticket, int set_index) {

    if (!PositionSelectByTicket(ticket)) return -1;
    
    int sig_num = (int) StringToInteger(StringSubstr(PositionGetString(POSITION_COMMENT), 8, 2));

    MqlTradeRequest request;
    MqlTradeResult result;
    ZeroMemory(request);
    ZeroMemory(result);

    request.action = TRADE_ACTION_DEAL;
    request.symbol = sets[set_index].symbol;
    request.volume = PositionGetDouble(POSITION_VOLUME);
    request.deviation = sets[set_index].deviation;
    request.magic = sets[set_index].magic;
    request.comment = comment;
    request.position = ticket;
    
    set_filling_type(request);
    
    if (mode) {
        request.price = SymbolInfoDouble(sets[set_index].symbol, SYMBOL_BID);
        request.type = ORDER_TYPE_SELL;        
    } else {
        request.price = SymbolInfoDouble(sets[set_index].symbol, SYMBOL_ASK);
        request.type = ORDER_TYPE_BUY;
    }
    
    if (OrderSend(request, result) && result.retcode == TRADE_RETCODE_DONE)        
        return sig_num;
    else    
        return -1;
}

//+------------------------------------------------------------------+

bool open_order(bool mode, int set_index, int sig_index) {    
    
    int num_buy_orders;
    int num_sell_orders;
    string comment_open;    
    string comment_sig_index;
    string comment_num_buy;
    string comment_num_sell;
    
    if (sig_index < 10)
        comment_sig_index = "0" + IntegerToString(sig_index);
    else
        comment_sig_index = IntegerToString(sig_index);
    
    comment_open = comment + "_Rec_" + comment_sig_index;
    
    MqlTradeRequest request;
    MqlTradeResult result;
    ZeroMemory(request);
    ZeroMemory(result);
    
    request.action = TRADE_ACTION_DEAL;
    request.symbol = sets[set_index].symbol;
    request.deviation = sets[set_index].deviation;
    request.magic = sets[set_index].magic;
    
    set_filling_type(request);
    
    
    if (mode) { //buy
        request.price = SymbolInfoDouble(sets[set_index].symbol, SYMBOL_ASK);
        request.type = ORDER_TYPE_BUY;        
        num_buy_orders = count_orders(BUY, set_index);
        request.volume = calc_lot(set_index, num_buy_orders);
        
        if (num_buy_orders < 10)
            comment_num_buy = "0" + IntegerToString(num_buy_orders);
        else
            comment_num_buy = IntegerToString(num_buy_orders);            
        
        comment_open += comment_num_buy;
    } else {
        request.price = SymbolInfoDouble(sets[set_index].symbol, SYMBOL_BID);
        request.type = ORDER_TYPE_SELL;
        num_sell_orders = count_orders(SELL, set_index);
        request.volume = calc_lot(set_index, num_sell_orders);
        
        if (num_sell_orders < 10)
            comment_num_sell = "0" + IntegerToString(num_sell_orders);
        else
            comment_num_sell = IntegerToString(num_sell_orders);            
        
        comment_open += comment_num_sell;    
    }
    
    request.comment = comment_open;

    if (!OrderSend(request, result) && !(result.retcode == TRADE_RETCODE_DONE)) {
        Print("Error in ", __FUNCSIG__, ", line ", __LINE__, ": ", GetLastError());
        return false;
    } else if (mode) { //buy
        sets[set_index].buy_grid[num_buy_orders] = result.order;
        sets[set_index].signals[sig_index].l_active = true;
        if (sets[set_index].buy_grid[1] == 0) sets[set_index].in_long = true;
        return true;
    } else if (!mode) {
        sets[set_index].sell_grid[num_sell_orders] = result.order;
        sets[set_index].signals[sig_index].s_active = true;
        if (sets[set_index].sell_grid[1] == 0) sets[set_index].in_short = true;
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+

void set_filling_type(MqlTradeRequest& request) {
    string symbol = request.symbol;
    uint filling = (uint) SymbolInfoInteger(symbol, SYMBOL_FILLING_MODE);
    
    if ((filling & SYMBOL_FILLING_FOK) == SYMBOL_FILLING_FOK) {
        request.type_filling = ORDER_FILLING_FOK;
        return;
    }
        
    if ((filling & SYMBOL_FILLING_IOC) == SYMBOL_FILLING_IOC) {
        request.type_filling = ORDER_FILLING_IOC;
        return;
    }
}

//+------------------------------------------------------------------+
