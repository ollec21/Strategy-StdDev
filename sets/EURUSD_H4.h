//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_StdDev_EURUSD_H4_Params : Stg_StdDev_Params {
  Stg_StdDev_EURUSD_H4_Params() {
    symbol = "EURUSD";
    tf = PERIOD_H4;
    StdDev_Period = 2;
    StdDev_Applied_Price = 3;
    StdDev_Shift = 0;
    StdDev_SignalOpenMethod = 0;
    StdDev_SignalOpenLevel = 36;
    StdDev_SignalCloseMethod = 1;
    StdDev_SignalCloseLevel = 36;
    StdDev_PriceLimitMethod = 0;
    StdDev_PriceLimitLevel = 0;
    StdDev_MaxSpread = 10;
  }
};
