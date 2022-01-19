#ifdef IS_OPT
    #define EXT input
    #define SETS_NUM 1
#else 
    #define EXT
#endif

EXT string s1 = "#============ General Settings ==========#"; //>   >   >   >   >   >   >
    string symbol = _Symbol;
EXT int    magic = 4747; //Magic Number
EXT double max_spread = 5; //Max Spread in pips
EXT int    deviation = 3; //Deviation
EXT bool   trade_buy = true; //Trade in Buy direction?
EXT bool   trade_sell = true; //Trade in Sell direction?
EXT ENUM_TIMEFRAMES tf = PERIOD_M30; //Trading Timeframe
    string comment = "TIO";
EXT string set_name = "Set Name"; //Name of Set File

EXT string s2 = "#============ Money Management ==========#"; //>   >   >   >   >   >   >
EXT double lot = 0.01; //Lot
input double depo_per_lot = 0; //Depo Per Lot (0-off)
EXT double take_profit = 0.0; //Take Profit in pips
input int  stop_loss = 0; //Stop Loss, % of balance (0-off)

EXT string s3 = "#============ ATR Filter =========#"; //>   >   >   >   >   >   >
EXT    ENUM_TIMEFRAMES atr_tf = PERIOD_D1;
EXT int    atr_period = 14; //ATR Period (0-off)
EXT double atr_above = 1.75; //Don't trade above this level
EXT double atr_under = 0; //Don't trade atr_under this level

EXT string s4 = "#============ Recovery Settings ===========#"; //>   >   >   >   >   >   >

EXT bool   use_recovery = false; //Use Recovery?
EXT bool   use_arithmetic_multiplier = false; //Use arithmetic lot multiplier?
EXT int    grid_step = 20; //Grid Step
EXT int    max_orders = 10; //Max Orders
EXT double recovery_factor = 1.0; //Recovery Factor
EXT int    start_factor_knee = 2; //Start Factor Knee
enum CLOSE_BY {MA, TAKE};
EXT CLOSE_BY close_by = TAKE; //Close grid by
EXT int    bar_to_reduce = 0; //From what bar start reduce TP (0-off)?
EXT double take_reduce = 0.0; //Step for take reducing
EXT double take_reduce_limit = 0.0; //Lower limit for TP

EXT string s5 = "#============ Signal 1 =========#"; //>   >   >   >   >   >   >
EXT int    std_period_1 = 60; //StDev period (0-off)
EXT double std_level_1 = 0.514; //StDev level
EXT bool   include_ma_as_filter_1 = true; //Include MA as filter?

EXT string s6 = "#============ Signal 2 =========#"; //>   >   >   >   >   >   >
EXT int    std_period_2 = 60; //StDev period (0-off)
EXT double std_level_2 = 0.514; //StDev level
EXT bool   include_ma_as_filter_2 = true; //Include MA as filter?

EXT string s7 = "#============ Signal 3 =========#"; //>   >   >   >   >   >   >
EXT int    std_period_3 = 60; //StDev period (0-off)
EXT double std_level_3 = 0.514; //StDev level
EXT bool   include_ma_as_filter_3 = true; //Include MA as filter?

EXT string s8 = "#============ Signal 4 =========#"; //>   >   >   >   >   >   >

EXT int    std_period_4 = 60; //StDev period (0-off)
EXT double std_level_4 = 0.514; //StDev level
EXT bool   include_ma_as_filter_4 = true; //Include MA as filter?

EXT string s9 = "#============ Signal 5 =========#"; //>   >   >   >   >   >   >

EXT int    std_period_5 = 60; //StDev period (0-off)
EXT double std_level_5 = 0.514; //StDev level
EXT bool   include_ma_as_filter_5 = true; //Include MA as filter?

EXT string s10 = "#============ Signal 6 =========#"; //>   >   >   >   >   >   >

EXT int    std_period_6 = 60; //StDev period (0-off)
EXT double std_level_6 = 0.514; //StDev level
EXT bool   include_ma_as_filter_6 = true; //Include MA as filter?

EXT string s11 = "#============ Signal 7 =========#"; //>   >   >   >   >   >   >

EXT int    std_period_7 = 60; //StDev period (0-off)
EXT double std_level_7 = 0.514; //StDev level
EXT bool   include_ma_as_filter_7 = true; //Include MA as filter?

EXT string s12 = "#============ Signal 8 =========#"; //>   >   >   >   >   >   >

EXT int    std_period_8 = 60; //StDev period (0-off)
EXT double std_level_8 = 0.514; //StDev level
EXT bool   include_ma_as_filter_8 = true; //Include MA as filter?

EXT string s13 = "#============ Signal 9 =========#"; //>   >   >   >   >   >   >

EXT int    std_period_9 = 60; //StDev period (0-off)
EXT double std_level_9 = 0.514; //StDev level
EXT bool   include_ma_as_filter_9 = true; //Include MA as filter?

EXT string s14 = "#============ Signal 10 =========#"; //>   >   >   >   >   >   >

EXT int    std_period_10 = 60; //StDev period (0-off)
EXT double std_level_10 = 0.514; //StDev level
EXT bool   include_ma_as_filter_10 = true; //Include MA as filter?

EXT string s15 = "#============ Signal 11 =========#"; //>   >   >   >   >   >   >

EXT int    std_period_11 = 60; //StDev period (0-off)
EXT double std_level_11 = 0.514; //StDev level
EXT bool   include_ma_as_filter_11 = true; //Include MA as filter?

EXT string s16 = "#============ Signal 12 =========#"; //>   >   >   >   >   >   >

EXT int    std_period_12 = 60; //StDev period (0-off)
EXT double std_level_12 = 0.514; //StDev level
EXT bool   include_ma_as_filter_12 = true; //Include MA as filter?

EXT string s17 = "#============ Signal 13 =========#"; //>   >   >   >   >   >   >

EXT int    std_period_13 = 60; //StDev period (0-off)
EXT double std_level_13 = 0.514; //StDev level
EXT bool   include_ma_as_filter_13 = true; //Include MA as filter?

EXT string s18 = "#============ Signal 14 =========#"; //>   >   >   >   >   >   >

EXT int    std_period_14 = 60; //StDev period (0-off)
EXT double std_level_14 = 0.514; //StDev level
EXT bool   include_ma_as_filter_14 = true; //Include MA as filter?

EXT string s19 = "#============ Signal 15 =========#"; //>   >   >   >   >   >   >

EXT int    std_period_15 = 60; //StDev period (0-off)
EXT double std_level_15 = 0.514; //StDev level
EXT bool   include_ma_as_filter_15 = true; //Include MA as filter?

//+------------------------------------------------------------------+



#define SIGNALS 15


bool is_test = false;
MqlDateTime time;

struct Signal {
    int  std_period;
    double std_level;
    bool include_ma_as_filter;
    
    ulong buy_grid[];
    ulong sell_grid[];
    bool in_short;
    bool in_long;
    bool close_long_flag;
    bool close_short_flag;
};

const bool BUY = true;
const bool SELL = false;
const int  RETRY = 10;
const int  SLEEP = 4000;
const int  NY_START = 20;
const int  NY_END = 10;

struct Set {
    string symbol;  
    int magic;
    double max_spread;
    int deviation;
    bool trade_buy;
    bool trade_sell;
    ENUM_TIMEFRAMES tf;
    string set_name;
    double lot;
    double depo_per_lot;
    double take_profit;
    int atr_period;
    double atr_above;
    double atr_under;
    bool use_recovery;
    bool use_arithmetic_multiplier;    
    int grid_step;
    int max_orders;
    double recovery_factor;
    int start_factor_knee;
    CLOSE_BY close_by;
    int    bar_to_reduce;
    double take_reduce;
    double take_reduce_limit;
    
    Signal signals[SIGNALS];
    int  activated_mas;
};

Set sets[SETS_NUM];
static datetime new_times[SETS_NUM];
