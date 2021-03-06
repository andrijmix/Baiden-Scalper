//+------------------------------------------------------------------+

int init_ea() {
    is_testing = IsTesting();
    
    fill_struct();
    activate_signals();  
    
    for (int i = 0; i < 15; i++) {
        if (signals[i].include_ma_as_filter)
            activated_mas++;
        ArrayResize(recoveries[i].long_tickets, max_orders);
        ArrayResize(recoveries[i].short_tickets, max_orders);
        ArrayInitialize(recoveries[i].long_tickets, 0);
        ArrayInitialize(recoveries[i].short_tickets, 0);
    }
    
    if (!is_testing) {
        create_panel();
        catch_orders();
        catch_orders_recovery();
    }
    
    HideTestIndicators(true);
    
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+

void tick_handler() {
    if (big_spread() || !IsTradeAllowed()) return; 
    
    if (is_new_bar()) {
        if (trade_buy && time_check()) 
            find_entries(buy);
    
        if (trade_sell && time_check())
            find_entries(sell);
            
        find_exit(buy);
        find_exit(sell);
        
        if (!is_testing) refresh_panel_profit();
    }
    
    find_global_stop();
    
    if (!is_testing) refresh_panel();
}

//+------------------------------------------------------------------+

void find_entries(bool mode) {
    double movings[];
    int ma_periods[15];
    int std_periods[15];
    
    ArrayInitialize(ma_periods, 0);
    ArrayResize(movings, activated_mas);
    
    for (int i = 0; i < 15; i++)
        if (signals[i].include_ma_as_filter)
            ma_periods[i] = signals[i].ma_period;
        
    ArraySort(ma_periods);  
    
    int counter = 0;
    
    for (int i = 0; i < 15; i++)
        if (ma_periods[i] != 0)
            movings[counter++] = iMA(_Symbol, PERIOD_CURRENT, ma_periods[i], 0, MODE_SMA, PRICE_CLOSE, 1);    
    
    if (mode) {        
        if (compare_movings(buy, movings)) {            
            for (int i = 0; i < 15; i++) {
                if (signals[i].active && !signals[i].in_long) {
                    double std_curr = iStdDev(_Symbol, PERIOD_CURRENT, signals[i].std_period, 0, MODE_SMA, PRICE_CLOSE, 1);
                    double std_prev = iStdDev(_Symbol, PERIOD_CURRENT, signals[i].std_period, 0, MODE_SMA, PRICE_CLOSE, 2);
                    if (std_curr > std_prev && std_curr > signals[i].std_level && std_prev < signals[i].std_level)
                    {
                        double atr = iATR(_Symbol, atr_tf, atr_period, 1);
                        if (atr < atr_above) {
                            if (Ask < movings[0]) {
                                if (!open_first_order(buy, i)) {
                                    Print("Не удалось открыть ордер на покупку: ошибка ", GetLastError(), " новая попытка...");
                                    Sleep(1000);
                                    for (int j = 1; j < retry; j++) {
                                        if (open_first_order(buy, i)) break;
                                        else Print("Не удалось открыть ордер на покупку: ошибка ", GetLastError(), " новая попытка...");
                                        Sleep(1000);
                                    }
                                }    
                            }    
                        }
                    }
                }
            }
        } 
    } else {
        if (compare_movings(sell, movings)) {
            for (int i = 0; i < 15; i++) {
                if (signals[i].active && !signals[i].in_short) {
                    double std_curr = iStdDev(_Symbol, PERIOD_CURRENT, signals[i].std_period, 0, MODE_SMA, PRICE_CLOSE, 1);
                    double std_prev = iStdDev(_Symbol, PERIOD_CURRENT, signals[i].std_period, 0, MODE_SMA, PRICE_CLOSE, 2);
                    if (std_curr > std_prev && std_curr > signals[i].std_level && std_prev < signals[i].std_level)
                    {
                        double atr = iATR(_Symbol, atr_tf, atr_period, 1);
                        if (atr < atr_above) {
                            if (Bid > movings[0]) {
                                if (!open_first_order(sell, i)) {
                                    Print("Не удалось открыть ордер на продажу: ошибка ", GetLastError());
                                    Sleep(1000);
                                    for (int j = 1; j < retry; j++) {
                                        if (open_first_order(sell, i)) break;
                                        else Print("Не удалось открыть ордер на продажу: ошибка ", GetLastError(), " новая попытка...");
                                        Sleep(1000);
                                    }
                                }    
                            }    
                        }
                    }
                }    
            }
        }  
    }
}

//+------------------------------------------------------------------+

void find_exit(bool mode) {
    double open_price = 0;
    double price_close = 0;
    double ma = 0;
    
    if (mode) {
        for (int i = 0; i < 15; i++) {
            if (signals[i].in_long) {                
                if (OrderSelect(signals[i].long_ticket, SELECT_BY_TICKET)) {                    
                    if (!use_recovery) {
                        /* tp closing */
                        if (signals[i].take_profit > 0) {
                            open_price = OrderOpenPrice();
                            if (Bid - open_price >= signals[i].take_profit * _Point) {
                                if (close_first_order(buy, i)) {
                                    return;
                                } else {
                                    Print("Не удалось закрыть ордер на покупку: ошибка ", GetLastError(), " новая попытка...");
                                    Sleep(1000);
                                    for (int j = 1; j < retry; j++) {
                                        if (close_first_order(buy, i)) return;
                                        else Print("Не удалось закрыть ордер на покупку: ошибка ", GetLastError(), " новая попытка...");
                                        Sleep(1000);
                                    }
                                }    
                            }
                        }
                        
                        /* ma closing */                                       
                        ma = iMA(_Symbol, PERIOD_CURRENT, signals[i].ma_period, 0, MODE_SMA, PRICE_CLOSE, 1);
                        price_close = iClose(_Symbol, PERIOD_CURRENT, 1);
                        
                        if (price_close > ma) {
                            if (close_first_order(buy, i)) {
                                return; 
                            } else {
                                Print("Не удалось закрыть ордер на покупку: ошибка ", GetLastError(), " новая попытка...");
                                Sleep(1000);
                                for (int j = 1; j < retry; j++) {
                                    if (close_first_order(buy, i)) return;
                                    else Print("Не удалось закрыть ордер на покупку: ошибка ", GetLastError(), " новая попытка...");
                                    Sleep(1000);
                                }
                            }    
                        }                        
                    } else
                        manage_grid(buy, i);                                                              
                }
            }
        }
    } else {
        for (int i = 0; i < 15; i++) {
            if (signals[i].in_short) {                
                if (OrderSelect(signals[i].short_ticket, SELECT_BY_TICKET)) {                    
                    if (!use_recovery) {
                        /* tp closing */
                        if (signals[i].take_profit > 0) {
                            open_price = OrderOpenPrice();
                            if (open_price - Ask >= signals[i].take_profit * _Point) {
                                if (close_first_order(sell, i)) {
                                    return; 
                                } else {
                                    Print("Не удалось закрыть ордер на продажу: ошибка ", GetLastError(), " новая попытка...");
                                    Sleep(1000);
                                    for (int j = 1; j < retry; j++) {
                                        if (close_first_order(sell, i)) return;
                                        else Print("Не удалось закрыть ордер на продажу: ошибка ", GetLastError(), " новая попытка...");
                                        Sleep(1000);
                                    }
                                }                                    
                            }
                        }
                        
                        /* ma closing */                        
                        ma = iMA(_Symbol, PERIOD_CURRENT, signals[i].ma_period, 0, MODE_SMA, PRICE_CLOSE, 1);
                        price_close = iClose(_Symbol, PERIOD_CURRENT, 1);
                        
                        if (price_close < ma) {
                            if (close_first_order(sell, i)) {
                                return; 
                            } else {
                                Print("Не удалось закрыть ордер на продажу: ошибка ", GetLastError(), " новая попытка...");
                                Sleep(1000);
                                for (int j = 1; j < retry; j++) {
                                    if (close_first_order(sell, i)) return;
                                    else Print("Не удалось закрыть ордер на продажу: ошибка ", GetLastError(), " новая попытка...");
                                    Sleep(1000);
                                }
                            }                                
                        }                        
                    } else
                        manage_grid(sell, i);                                        
                }
            }
        }
    }
}

//+------------------------------------------------------------------+

bool open_first_order(bool mode, int index) {
    double lot_size = lot;
    int order_type = 0;
    double price = 0;
    double sl = 0;
    double tp = 0;
    string comment_open = comment + " signal " + IntegerToString(index);
    color clr = White;
    
    if (mode) { //buy
        order_type = OP_BUY;
        price = Ask;
        clr = Blue;
    } else {
        order_type = OP_SELL;
        price = Bid;
        clr = Red;
    }
    
    if (mode) { //buy
        int ticket = OrderSend(_Symbol, order_type, lot_size, price, slippage, sl, tp, comment_open, magic, 0, clr);
        if (ticket > 0) {
            signals[index].long_ticket = ticket;
            signals[index].in_long = true;
            if (use_recovery)
                recoveries[index].long_tickets[0] = ticket;        
            return true;
        } else return false; 
    } else {
        int ticket = OrderSend(_Symbol, order_type, lot_size, price, slippage, sl, tp, comment_open, magic, 0, clr);
        if (ticket > 0) {
            signals[index].short_ticket = ticket;
            signals[index].in_short = true;
            if (use_recovery)
                recoveries[index].short_tickets[0] = ticket;
            return true;
        } else return false;
    }
}

//+------------------------------------------------------------------+

bool close_first_order(bool mode, int index) {
    double price = 0.0;
    color clr = Green;
    int ticket = 0;
    
    if (mode) {
        price = Bid;
        ticket = signals[index].long_ticket;
        clr = Blue;
    } else {
        price = Ask;
        ticket = signals[index].short_ticket;
        clr = Red;
    }
         
    if (mode) {
        if (OrderSelect(ticket, SELECT_BY_TICKET)) {                   
            if (OrderClose(ticket, OrderLots(), price, slippage, clr)) {
                signals[index].in_long = false;
                signals[index].long_ticket = 0;
                return true;
            } else
                return false;
        }  
    } else {
        if (OrderSelect(ticket, SELECT_BY_TICKET)) {                   
            if (OrderClose(ticket, OrderLots(), price, slippage, clr)) {
                signals[index].in_short = false;
                signals[index].short_ticket = 0;
                return true;
            } else
                return false;
        } 
    }
    return false;
}

//+------------------------------------------------------------------+

bool compare_movings(bool mode, const double &movings[]) {
    if (mode) {    
        if (activated_mas == 2) {
            return (movings[0] < movings[1]);
        }
        if (activated_mas == 3) {
            return (movings[0] < movings[1] && movings[1] < movings[2]);
        }
        if (activated_mas == 4) {
            return (movings[0] < movings[1] && movings[1] < movings[2] && movings[2] < movings[3]);
        }
        if (activated_mas == 5) {
            return (movings[0] < movings[1] && movings[1] < movings[2] && movings[2] < movings[3] &&
            movings[3] < movings[4]);
        } 
        if (activated_mas == 6) {
            return (movings[0] < movings[1] && movings[1] < movings[2] && movings[2] < movings[3] &&
            movings[3] < movings[4] && movings[4] < movings[5]);
        } 
        if (activated_mas == 7) {
            return (movings[0] < movings[1] && movings[1] < movings[2] && movings[2] < movings[3] &&
            movings[3] < movings[4] && movings[4] < movings[5] && movings[5] < movings[6]);
        }    
        if (activated_mas == 8) {
            return (movings[0] < movings[1] && movings[1] < movings[2] && movings[2] < movings[3] &&
            movings[3] < movings[4] && movings[4] < movings[5] && movings[5] < movings[6] &&
            movings[6] < movings[7]);
        }
        if (activated_mas == 9) {
            return (movings[0] < movings[1] && movings[1] < movings[2] && movings[2] < movings[3] &&
            movings[3] < movings[4] && movings[4] < movings[5] && movings[5] < movings[6] &&
            movings[6] < movings[7] && movings[7] < movings[8]);
        }
        if (activated_mas == 10) {
            return (movings[0] < movings[1] && movings[1] < movings[2] && movings[2] < movings[3] &&
            movings[3] < movings[4] && movings[4] < movings[5] && movings[5] < movings[6] &&
            movings[6] < movings[7] && movings[7] < movings[8] && movings[8] < movings[9]);
        }
        if (activated_mas == 11) {
            return (movings[0] < movings[1] && movings[1] < movings[2] && movings[2] < movings[3] &&
            movings[3] < movings[4] && movings[4] < movings[5] && movings[5] < movings[6] &&
            movings[6] < movings[7] && movings[7] < movings[8] && movings[8] < movings[9] &&
            movings[9] < movings[10]);
        } 
        if (activated_mas == 12) {
            return (movings[0] < movings[1] && movings[1] < movings[2] && movings[2] < movings[3] &&
            movings[3] < movings[4] && movings[4] < movings[5] && movings[5] < movings[6] &&
            movings[6] < movings[7] && movings[7] < movings[8] && movings[8] < movings[9] &&
            movings[9] < movings[10] && movings[10] < movings[11]);
        } 
        if (activated_mas == 13) {
            return (movings[0] < movings[1] && movings[1] < movings[2] && movings[2] < movings[3] &&
            movings[3] < movings[4] && movings[4] < movings[5] && movings[5] < movings[6] &&
            movings[6] < movings[7] && movings[7] < movings[8] && movings[8] < movings[9] &&
            movings[9] < movings[10] && movings[10] < movings[11] && movings[11] < movings[12]);
        }    
        if (activated_mas == 14) {
            return (movings[0] < movings[1] && movings[1] < movings[2] && movings[2] < movings[3] &&
            movings[3] < movings[4] && movings[4] < movings[5] && movings[5] < movings[6] &&
            movings[6] < movings[7] && movings[7] < movings[8] && movings[8] < movings[9] &&
            movings[9] < movings[10] && movings[10] < movings[11] && movings[11] < movings[12] &&
            movings[12] < movings[13]);
        }
        if (activated_mas == 15) {
            return (movings[0] < movings[1] && movings[1] < movings[2] && movings[2] < movings[3] &&
            movings[3] < movings[4] && movings[4] < movings[5] && movings[5] < movings[6] &&
            movings[6] < movings[7] && movings[7] < movings[8] && movings[8] < movings[9] &&
            movings[9] < movings[10] && movings[10] < movings[11] && movings[11] < movings[12] &&
            movings[12] < movings[13] && movings[13] < movings[14]);
        }     
    } else {
        if (activated_mas == 2) {
            return (movings[0] > movings[1]);
        }
        if (activated_mas == 3) {
            return (movings[0] > movings[1] && movings[1] > movings[2]);
        }
        if (activated_mas == 4) {
            return (movings[0] > movings[1] && movings[1] > movings[2] && movings[2] > movings[3]);
        }
        if (activated_mas == 5) {
            return (movings[0] > movings[1] && movings[1] > movings[2] && movings[2] > movings[3] &&
            movings[3] > movings[4]);
        }
        if (activated_mas == 6) {
            return (movings[0] > movings[1] && movings[1] > movings[2] && movings[2] > movings[3] &&
            movings[3] > movings[4] && movings[4] > movings[5]);
        }
        if (activated_mas == 7) {
            return (movings[0] > movings[1] && movings[1] > movings[2] && movings[2] > movings[3] &&
            movings[3] > movings[4] && movings[4] > movings[5] && movings[5] > movings[6]);
        }
        if (activated_mas == 8) {
            return (movings[0] > movings[1] && movings[1] > movings[2] && movings[2] > movings[3] &&
            movings[3] > movings[4] && movings[4] > movings[5] && movings[5] > movings[6] &&
            movings[6] > movings[7]);
        }
        if (activated_mas == 9) {
            return (movings[0] > movings[1] && movings[1] > movings[2] && movings[2] > movings[3] &&
            movings[3] > movings[4] && movings[4] > movings[5] && movings[5] > movings[6] &&
            movings[6] > movings[7] && movings[7] > movings[8]);
        }
        if (activated_mas == 10) {
            return (movings[0] > movings[1] && movings[1] > movings[2] && movings[2] > movings[3] &&
            movings[3] > movings[4] && movings[4] > movings[5] && movings[5] > movings[6] &&
            movings[6] > movings[7] && movings[7] > movings[8] && movings[8] > movings[9]);
        }
        if (activated_mas == 11) {
            return (movings[0] > movings[1] && movings[1] > movings[2] && movings[2] > movings[3] &&
            movings[3] > movings[4] && movings[4] > movings[5] && movings[5] > movings[6] &&
            movings[6] > movings[7] && movings[7] > movings[8] && movings[8] > movings[9] &&
            movings[9] > movings[10]);
        } 
        if (activated_mas == 12) {
            return (movings[0] > movings[1] && movings[1] > movings[2] && movings[2] > movings[3] &&
            movings[3] > movings[4] && movings[4] > movings[5] && movings[5] > movings[6] &&
            movings[6] > movings[7] && movings[7] > movings[8] && movings[8] > movings[9] &&
            movings[9] > movings[10] && movings[10] > movings[11]);
        } 
        if (activated_mas == 13) {
            return (movings[0] > movings[1] && movings[1] > movings[2] && movings[2] > movings[3] &&
            movings[3] > movings[4] && movings[4] > movings[5] && movings[5] > movings[6] &&
            movings[6] > movings[7] && movings[7] > movings[8] && movings[8] > movings[9] &&
            movings[9] > movings[10] && movings[10] > movings[11] && movings[11] > movings[12]);
        }    
        if (activated_mas == 14) {
            return (movings[0] > movings[1] && movings[1] > movings[2] && movings[2] > movings[3] &&
            movings[3] > movings[4] && movings[4] > movings[5] && movings[5] > movings[6] &&
            movings[6] > movings[7] && movings[7] > movings[8] && movings[8] > movings[9] &&
            movings[9] > movings[10] && movings[10] > movings[11] && movings[11] > movings[12] &&
            movings[12] > movings[13]);
        }
        if (activated_mas == 15) {
            return (movings[0] > movings[1] && movings[1] > movings[2] && movings[2] > movings[3] &&
            movings[3] > movings[4] && movings[4] > movings[5] && movings[5] > movings[6] &&
            movings[6] > movings[7] && movings[7] > movings[8] && movings[8] > movings[9] &&
            movings[9] > movings[10] && movings[10] > movings[11] && movings[11] > movings[12] &&
            movings[12] > movings[13] && movings[13] > movings[14]);
        } 
    }
    return false;
}

//+------------------------------------------------------------------+

void find_global_stop() {
    if (stop_loss == 0.0) return;
    
    double drawdown = 0.0;
    
    for (int i = 0; i < 15; i++) {
        if (signals[i].active && signals[i].in_long)
            if (OrderSelect(signals[i].long_ticket, SELECT_BY_TICKET))             
                drawdown += OrderProfit();
        
        if (signals[i].active && signals[i].in_short)
            if (OrderSelect(signals[i].short_ticket, SELECT_BY_TICKET))                
                drawdown += OrderProfit();
        
        if (use_recovery) {
            for (int j = 1; j < max_orders; j++) {
                if (recoveries[i].long_tickets[j] > 0 && OrderSelect(recoveries[i].long_tickets[j], SELECT_BY_TICKET))                    
                    drawdown += OrderProfit();                    
                
                if (recoveries[i].short_tickets[j] > 0 && OrderSelect(recoveries[i].short_tickets[j], SELECT_BY_TICKET))                    
                    drawdown += OrderProfit();
            }
        }
    }
    
    if (drawdown <= -stop_loss)
        close_all_orders();
}

//+------------------------------------------------------------------+

void close_all_orders() {
    bool close_flag = false;
        
    do {
        /* try to close */
        for (int i = 0; i < 15; i++) {
            if (use_recovery) {
                close_grid(buy, i);
                close_grid(sell, i);               
            } else {
                close_first_order(buy, i);
                close_first_order(sell, i);
            }
        }
        
        /* Check for left orders */
        for (int i = 0; i < 15; i++) {
            if (use_recovery) {
                if (recoveries[i].buy_close_flag) {
                    close_flag = true;
                    break;
                } else
                    close_flag = false;
                    
                if (recoveries[i].sell_close_flag) {
                    close_flag = true;
                    break;
                } else
                    close_flag = false;    
            } else {
                if (signals[i].in_long) {
                    close_flag = true;
                    break;
                } else
                    close_flag = false;
                
                if (signals[i].in_short) {
                    close_flag = true;
                    break;
                } else
                    close_flag = false;
            }   
        }    
        Sleep(1000);
    } while (close_flag);
}

//+------------------------------------------------------------------+
