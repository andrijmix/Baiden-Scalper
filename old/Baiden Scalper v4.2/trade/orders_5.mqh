#include <Trade\SymbolInfo.mqh>

CSymbolInfo* c_symbol_info;

void init_symbol_info() {
    c_symbol_info = new CSymbolInfo();
} 

//+------------------------------------------------------------------+

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

datetime get_open_time() {
    return (datetime) PositionGetInteger(POSITION_TIME);
}

//+------------------------------------------------------------------+

double get_volume() {
    return PositionGetDouble(POSITION_VOLUME);
}

//+------------------------------------------------------------------+

double get_ask(int set_index) {
    return SymbolInfoDouble(sets[set_index].symbol, SYMBOL_ASK);
}

//+------------------------------------------------------------------+

double get_bid(int set_index) {
    return SymbolInfoDouble(sets[set_index].symbol, SYMBOL_BID);
}

//+------------------------------------------------------------------+

double get_point(int set_index) {
    return SymbolInfoDouble(sets[set_index].symbol, SYMBOL_POINT);
}

//+------------------------------------------------------------------+

double get_start_lot(bool mode, int set_index, int sig_index) {
    bool selected;
    
    if (mode) {
        selected = select_order_by_ticket(sets[set_index].signals[sig_index].buy_grid[0]);
    } else {
        selected = select_order_by_ticket(sets[set_index].signals[sig_index].sell_grid[0]);
    }    

    if (selected)
        return get_volume();
    else {
        Print("Error selecting order in ", __FILE__, ", line ", __LINE__);
        return 0.0;
    }    
}

//+------------------------------------------------------------------+

bool close_order(bool mode, ulong ticket, int set_index, int sig_index, int order_number) {

    if (!select_order_by_ticket(ticket)) return false;    

    MqlTradeRequest request;
    MqlTradeResult result;
    ZeroMemory(request);
    ZeroMemory(result);

    request.action = TRADE_ACTION_DEAL;
    request.symbol = sets[set_index].symbol;
    request.volume = get_volume();
    request.deviation = sets[set_index].deviation;
    //request.magic = sets[set_index].magic;
    request.comment = comment;
    request.position = ticket;
    
    set_filling_type(request);
    
    c_symbol_info.Name(request.symbol);
    c_symbol_info.RefreshRates();
    
    if (mode) {
        request.price = get_bid(set_index);
        request.type = ORDER_TYPE_SELL;        
    } else {
        request.price = get_ask(set_index);
        request.type = ORDER_TYPE_BUY;
    }
    
    if (OrderSend(request, result) && result.retcode == TRADE_RETCODE_DONE) {    
        if (mode) {
            sets[set_index].signals[sig_index].buy_grid[order_number] = 0;
            return true;
        } else {
            sets[set_index].signals[sig_index].sell_grid[order_number] = 0;
            return true;
        }
    } else    
        return false;
}

//+------------------------------------------------------------------+

bool open_order(bool mode, int set_index, int sig_index) {
    if (sets[set_index].lot < SymbolInfoDouble(sets[set_index].symbol, SYMBOL_VOLUME_MIN)) return false;
    if (AccountInfoDouble(ACCOUNT_BALANCE) < 10) return false;
    
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
    
    string magic_str = IntegerToString(sets[set_index].magic) + comment_sig_index;
    
    set_filling_type(request);      
    
    if (mode) { //buy        
        request.type = ORDER_TYPE_BUY;        
        num_buy_orders = count_orders(BUY, set_index, sig_index);
        request.volume = calc_lot(set_index, num_buy_orders);
        
        if (num_buy_orders < 10)
            comment_num_buy = "0" + IntegerToString(num_buy_orders);
        else
            comment_num_buy = IntegerToString(num_buy_orders);            
        
        comment_open += comment_num_buy;
        magic_str += comment_num_buy;
    } else {        
        request.type = ORDER_TYPE_SELL;
        num_sell_orders = count_orders(SELL, set_index, sig_index);
        request.volume = calc_lot(set_index, num_sell_orders);
        
        if (num_sell_orders < 10)
            comment_num_sell = "0" + IntegerToString(num_sell_orders);
        else
            comment_num_sell = IntegerToString(num_sell_orders);            
        
        comment_open += comment_num_sell;
        magic_str += comment_num_sell;  
    }
    
    request.comment = comment_open;
    request.magic = StringToInteger(magic_str);
    
    c_symbol_info.Name(request.symbol);
    c_symbol_info.RefreshRates();
    
    if (mode) request.price = get_ask(set_index);
    else      request.price = get_bid(set_index);
    

    if (!OrderSend(request, result) && !(result.retcode == TRADE_RETCODE_DONE)) {
        return false;
    } else if (mode) { //buy
        sets[set_index].signals[sig_index].buy_grid[num_buy_orders] = result.order;
        if (sets[set_index].signals[sig_index].buy_grid[0] > 0) sets[set_index].signals[sig_index].in_long = true;
        return true;
    } else if (!mode) {
        sets[set_index].signals[sig_index].sell_grid[num_sell_orders] = result.order;
        if (sets[set_index].signals[sig_index].sell_grid[0] > 0) sets[set_index].signals[sig_index].in_short = true;
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+

void open_order_retry(bool mode, int set_index, int sig_index) {
    for (int i = 0; i < RETRY; i++) {
        if (open_order(mode, set_index, sig_index)) return;
        Print("Error opening order in ", __FILE__, " on line ", __LINE__, ": ", GetLastError(), ", retry...");
        Sleep(SLEEP);
    }
}

//+------------------------------------------------------------------+

void close_order_retry(bool mode, ulong ticket, int set_index, int sig_index, int order_number) {
    for (int i = 0; i < RETRY; i++) {
        if (close_order(mode, ticket, set_index, sig_index, order_number)) return;
        Print("Error closing order in ", __FILE__, " on line ", __LINE__, ": ", GetLastError(), ", retry...");
        Sleep(SLEEP);
    }
}

//+------------------------------------------------------------------+

void set_filling_type(MqlTradeRequest& request) {
    string _symbol = request.symbol;
    uint filling = (uint) SymbolInfoInteger(_symbol, SYMBOL_FILLING_MODE);
    
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
