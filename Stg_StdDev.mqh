//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2019, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/**
 * @file
 * Implements StdDev strategy the Standard Deviation indicator.
 */

// Includes.
#include <EA31337-classes/Indicators/Indi_StdDev.mqh>
#include <EA31337-classes/Strategy.mqh>

// User input params.
INPUT string __StdDev_Parameters__ = "-- StdDev strategy params --";  // >>> STDDEV <<<
INPUT int StdDev_Active_Tf = 0;             // Activate timeframes (1-255, e.g. M1=1,M5=2,M15=4,M30=8,H1=16,H2=32...)
INPUT int StdDev_MA_Period = 10;            // Period
INPUT int StdDev_MA_Shift = 0;              // Shift
INPUT ENUM_MA_METHOD StdDev_MA_Method = 1;  // MA Method
INPUT ENUM_APPLIED_PRICE StdDev_Applied_Price = PRICE_CLOSE;         // Applied Price
INPUT int StdDev_Shift = 0;                                          // Shift
INPUT ENUM_TRAIL_TYPE StdDev_TrailingStopMethod = 22;                // Trail stop method
INPUT ENUM_TRAIL_TYPE StdDev_TrailingProfitMethod = 1;               // Trail profit method
INPUT double StdDev_SignalOpenLevel = 0.00000000;                    // Signal open level
INPUT int StdDev1_SignalBaseMethod = 0;                              // Signal base method (0-
INPUT int StdDev1_OpenCondition1 = 0;                                // Open condition 1 (0-1023)
INPUT int StdDev1_OpenCondition2 = 0;                                // Open condition 2 (0-)
INPUT ENUM_MARKET_EVENT StdDev1_CloseCondition = C_STDDEV_BUY_SELL;  // Close condition for M1
INPUT double StdDev_MaxSpread = 6.0;                                 // Max spread to trade (pips)

// Struct to define strategy parameters to override.
struct Stg_StdDev_Params : Stg_Params {
  unsigned int StdDev_Period;
  ENUM_APPLIED_PRICE StdDev_Applied_Price;
  int StdDev_Shift;
  ENUM_TRAIL_TYPE StdDev_TrailingStopMethod;
  ENUM_TRAIL_TYPE StdDev_TrailingProfitMethod;
  double StdDev_SignalOpenLevel;
  long StdDev_SignalBaseMethod;
  long StdDev_SignalOpenMethod1;
  long StdDev_SignalOpenMethod2;
  double StdDev_SignalCloseLevel;
  ENUM_MARKET_EVENT StdDev_SignalCloseMethod1;
  ENUM_MARKET_EVENT StdDev_SignalCloseMethod2;
  double StdDev_MaxSpread;

  // Constructor: Set default param values.
  Stg_StdDev_Params()
      : StdDev_Period(::StdDev_Period),
        StdDev_Applied_Price(::StdDev_Applied_Price),
        StdDev_Shift(::StdDev_Shift),
        StdDev_TrailingStopMethod(::StdDev_TrailingStopMethod),
        StdDev_TrailingProfitMethod(::StdDev_TrailingProfitMethod),
        StdDev_SignalOpenLevel(::StdDev_SignalOpenLevel),
        StdDev_SignalBaseMethod(::StdDev_SignalBaseMethod),
        StdDev_SignalOpenMethod1(::StdDev_SignalOpenMethod1),
        StdDev_SignalOpenMethod2(::StdDev_SignalOpenMethod2),
        StdDev_SignalCloseLevel(::StdDev_SignalCloseLevel),
        StdDev_SignalCloseMethod1(::StdDev_SignalCloseMethod1),
        StdDev_SignalCloseMethod2(::StdDev_SignalCloseMethod2),
        StdDev_MaxSpread(::StdDev_MaxSpread) {}
};

// Loads pair specific param values.
#include "sets/EURUSD_H1.h"
#include "sets/EURUSD_H4.h"
#include "sets/EURUSD_M1.h"
#include "sets/EURUSD_M15.h"
#include "sets/EURUSD_M30.h"
#include "sets/EURUSD_M5.h"

class Stg_StdDev : public Strategy {
 public:
  Stg_StdDev(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_StdDev *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    Stg_StdDev_Params _params;
    switch (_tf) {
      case PERIOD_M1: {
        Stg_StdDev_EURUSD_M1_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M5: {
        Stg_StdDev_EURUSD_M5_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M15: {
        Stg_StdDev_EURUSD_M15_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M30: {
        Stg_StdDev_EURUSD_M30_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_H1: {
        Stg_StdDev_EURUSD_H1_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_H4: {
        Stg_StdDev_EURUSD_H4_Params _new_params;
        _params = _new_params;
      }
    }
    // Initialize strategy parameters.
    ChartParams cparams(_tf);
    StdDev_Params adx_params(_params.StdDev_Period, _params.StdDev_Applied_Price);
    IndicatorParams adx_iparams(10, INDI_StdDev);
    StgParams sparams(new Trade(_tf, _Symbol), new Indi_StdDev(adx_params, adx_iparams, cparams), NULL, NULL);
    sparams.logger.SetLevel(_log_level);
    sparams.SetMagicNo(_magic_no);
    sparams.SetSignals(_params.StdDev_SignalBaseMethod, _params.StdDev_SignalOpenMethod1,
                       _params.StdDev_SignalOpenMethod2, _params.StdDev_SignalCloseMethod1,
                       _params.StdDev_SignalCloseMethod2, _params.StdDev_SignalOpenLevel,
                       _params.StdDev_SignalCloseLevel);
    sparams.SetStops(_params.StdDev_TrailingProfitMethod, _params.StdDev_TrailingStopMethod);
    sparams.SetMaxSpread(_params.StdDev_MaxSpread);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_StdDev(sparams, "StdDev");
    return _strat;
  }

  /**
   * Check if StdDev indicator is on buy or sell.
   *
   * @param
   *   _cmd (int) - type of trade order command
   *   period (int) - period to check for
   *   _signal_method (int) - signal method to use by using bitwise AND operation
   *   _signal_level1 (double) - signal level to consider the signal
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, long _signal_method = EMPTY, double _signal_level = EMPTY) {
    bool _result = false;
    double stddev_0 = ((Indi_StdDev *)this.Data()).GetValue(0);
    double stddev_1 = ((Indi_StdDev *)this.Data()).GetValue(1);
    double stddev_2 = ((Indi_StdDev *)this.Data()).GetValue(2);
    if (_signal_method == EMPTY) _signal_method = GetSignalBaseMethod();
    if (_signal_level1 == EMPTY) _signal_level1 = GetSignalLevel1();
    if (_signal_level2 == EMPTY) _signal_level2 = GetSignalLevel2();
    switch (_cmd) {
      /*
        //27. Standard Deviation
        //Doesn't give independent signals. Is used to define volatility (trend strength).
        //Principle: the trend must be strengthened. Together with this Standard Deviation goes up.
        //Growth on 3 consecutive bars is analyzed
        //Flag is 1 when Standard Deviation rises, 0 - when no growth, -1 - never.
        if
        (iStdDev(NULL,pistd,pistdu,0,MODE_SMA,PRICE_CLOSE,2)<=iStdDev(NULL,pistd,pistdu,0,MODE_SMA,PRICE_CLOSE,1)&&iStdDev(NULL,pistd,pistdu,0,MODE_SMA,PRICE_CLOSE,1)<=iStdDev(NULL,pistd,pistdu,0,MODE_SMA,PRICE_CLOSE,0))
        {f27=1;}
      */
      case ORDER_TYPE_BUY:
        /*
          bool _result = StdDev_0[LINE_LOWER] != 0.0 || StdDev_1[LINE_LOWER] != 0.0 || StdDev_2[LINE_LOWER] != 0.0;
          if (METHOD(_signal_method, 0)) _result &= Open[CURR] > Close[CURR];
          */
        break;
      case ORDER_TYPE_SELL:
        /*
          bool _result = StdDev_0[LINE_UPPER] != 0.0 || StdDev_1[LINE_UPPER] != 0.0 || StdDev_2[LINE_UPPER] != 0.0;
          if (METHOD(_signal_method, 0)) _result &= Open[CURR] < Close[CURR];
          */
        break;
    }
    return _result;
  }

  /**
   * Check strategy's closing signal.
   */
  bool SignalClose(ENUM_ORDER_TYPE _cmd, long _signal_method = EMPTY, double _signal_level = EMPTY) {
    if (_signal_level == EMPTY) _signal_level = GetSignalCloseLevel();
    return SignalOpen(Order::NegateOrderType(_cmd), _signal_method, _signal_level);
  }
};
