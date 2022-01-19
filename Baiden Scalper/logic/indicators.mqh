//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double i_ma(string symbol, ENUM_TIMEFRAMES tf, int ma_period, int ma_shift, ENUM_MA_METHOD ma_method, int applied_price, int bar)
  {
#ifdef __MQL5__
   int ma_handle = iMA(symbol, tf, ma_period, ma_shift, ma_method, applied_price);
   double ma_buffer[1];
   CopyBuffer(ma_handle, 0, bar, 1, ma_buffer);
   return ma_buffer[0];
#endif
#ifdef __MQL4__
  return(iMA(symbol, tf, ma_period, ma_shift, ma_method, applied_price, bar));
#endif
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double i_stdev(string symbol, ENUM_TIMEFRAMES tf, int ma_period, int ma_shift, ENUM_MA_METHOD ma_method, int applied_price, int bar)
  {
#ifdef __MQL5__
   int std_handle = iStdDev(symbol, tf, ma_period, ma_shift, ma_method, applied_price);
   if(std_handle ==INVALID_HANDLE)
     {
      printf("Error creating iStdDev indicator");
     }

   double std_buffer[1];
   Sleep(3000);

   for(int i=0; i < 5; i++)
     {
      if(CopyBuffer(std_handle, 0, bar, 1, std_buffer) <= 0)
         Print("CopyBuffer iStdDev failed, no data");
      else
         break;
      Sleep(3000);
     }
   return std_buffer[0];
#endif

#ifdef __MQL4__
   double std = iStdDev(symbol, tf, ma_period, ma_shift, ma_method, applied_price, bar);
   return(std);
#endif

  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double i_atr(string symbol, ENUM_TIMEFRAMES tf, int ma_period, int bar)
  {
#ifdef __MQL5__
   int atr_handle = iATR(symbol, tf, ma_period);
   if(atr_handle ==INVALID_HANDLE)
      printf("Error creating atr indicator");
   double atr_buffer[1];
   Sleep(3000);
   for(int i=0; i < 5; i++)
     {
      if(CopyBuffer(atr_handle, 0, bar, 1, atr_buffer) <= 0)
         Print("CopyBuffer atr_handle failed, no data");
      else
         break;
      Sleep(3000);
     }
   return atr_buffer[0];
#endif

#ifdef __MQL4__
   double atr = iATR(symbol, tf, ma_period, bar);
   return(atr);
#endif
  }

//+------------------------------------------------------------------+
