//+------------------------------------------------------------------+

bool select_order_by_ticket(int ticket) {
    if (OrderSelect(ticket, SELECT_BY_TICKET))
        return true;
    
    return false;
}

//+------------------------------------------------------------------+

double get_price_open() {
    return OrderOpenPrice();
}

//+------------------------------------------------------------------+

datetime get_open_time() {
    return OrderOpenTime();
}

//+------------------------------------------------------------------+

double get_volume() {
    return OrderLots();
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

bool close_order(bool mode, int ticket, int set_index, int sig_index, int order_number) {
    if (!select_order_by_ticket(ticket)) return false;

    double price;
    double volume = get_volume();
    int _deviation = sets[set_index].deviation;
    
    RefreshRates();
    
    if (mode)
        price = get_bid(set_index);
    else
        price = get_ask(set_index);
    
    if (OrderClose(ticket, volume, price, _deviation)) {
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

    double price;
    int order_type;
    double volume;
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
    
    string open_symbol = sets[set_index].symbol;
    int open_deviation = sets[set_index].deviation;
    int open_magic = sets[set_index].magic;
    
    string magic_str = IntegerToString(open_magic) + comment_sig_index;
    
    if (mode) { //buy        
        order_type = OP_BUY;   
        num_buy_orders = count_orders(BUY, set_index, sig_index);
        volume = calc_lot(set_index, num_buy_orders);
        
        if (num_buy_orders < 10)
            comment_num_buy = "0" + IntegerToString(num_buy_orders);
        else
            comment_num_buy = IntegerToString(num_buy_orders);            
        
        comment_open += comment_num_buy;
        magic_str += comment_num_buy;
    } else {        
        order_type = OP_SELL;
        num_sell_orders = count_orders(SELL, set_index, sig_index);
        volume = calc_lot(set_index, num_sell_orders);
        
        if (num_sell_orders < 10)
            comment_num_sell = "0" + IntegerToString(num_sell_orders);
        else
            comment_num_sell = IntegerToString(num_sell_orders);            
        
        comment_open += comment_num_sell;
        magic_str += comment_num_sell;  
    }
    
    open_magic = StringToInteger(magic_str);
    
    RefreshRates();
    
    if (mode) price = get_ask(set_index);
    else      price = get_bid(set_index);
    
    int ticket = OrderSend(open_symbol, order_type, volume, price, open_deviation, 0, 0, comment_open, open_magic);
    
    if (ticket < 0) {
        return false;
    } else if (mode) { //buy
        sets[set_index].signals[sig_index].buy_grid[num_buy_orders] = ticket;
        if (sets[set_index].signals[sig_index].buy_grid[0] > 0) sets[set_index].signals[sig_index].in_long = true;        
        return true;
    } else if (!mode) {
        sets[set_index].signals[sig_index].sell_grid[num_sell_orders] = ticket;
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
