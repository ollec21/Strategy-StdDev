/**
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_StdDev_Params_M1 : StdDevParams {
  Indi_StdDev_Params_M1() : StdDevParams(indi_stddev_defaults, PERIOD_M1) {
    applied_price = (ENUM_APPLIED_PRICE)0;
    ma_method = (ENUM_MA_METHOD)0;
    ma_period = 30;
    shift = 0;
  }
} indi_stddev_m1;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_StdDev_Params_M1 : StgParams {
  // Struct constructor.
  Stg_StdDev_Params_M1() : StgParams(stg_stddev_defaults) {
    lot_size = 0;
    signal_open_method = 0;
    signal_open_filter = 1;
    signal_open_level = (float)0.0;
    signal_open_boost = 0;
    signal_close_method = 0;
    signal_close_level = (float)0;
    price_stop_method = 0;
    price_stop_level = (float)1;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_stddev_m1;
