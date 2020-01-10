//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_StdDev_EURUSD_M15_Params : Stg_StdDev_Params {
  Stg_StdDev_EURUSD_M15_Params() {
    symbol = "EURUSD";
    tf = PERIOD_M15;
    StdDev_Period = 2;
    StdDev_Applied_Price = 3;
    StdDev_Shift = 0;
    StdDev_TrailingStopMethod = 6;
    StdDev_TrailingProfitMethod = 11;
    StdDev_SignalOpenLevel = 36;
    StdDev_SignalBaseMethod = -63;
    StdDev_SignalOpenMethod1 = 389;
    StdDev_SignalOpenMethod2 = 0;
    StdDev_SignalCloseLevel = 36;
    StdDev_SignalCloseMethod1 = 1;
    StdDev_SignalCloseMethod2 = 0;
    StdDev_MaxSpread = 4;
  }
};
