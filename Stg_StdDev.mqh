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
INPUT int StdDev_MA_Period = 10;                                      // Period
INPUT int StdDev_MA_Shift = 0;                                        // Shift
INPUT ENUM_MA_METHOD StdDev_MA_Method = 1;                            // MA Method
INPUT ENUM_APPLIED_PRICE StdDev_Applied_Price = PRICE_CLOSE;          // Applied Price
INPUT int StdDev_Shift = 0;                                           // Shift
INPUT int StdDev_SignalOpenMethod = 0;                                // Signal open method (0-
INPUT double StdDev_SignalOpenLevel = 0.00000000;                     // Signal open level
INPUT int StdDev_SignalCloseMethod = 0;                               // Signal close method (0-
INPUT double StdDev_SignalCloseLevel = 0.00000000;                    // Signal close level
INPUT int StdDev_PriceLimitMethod = 0;                                // Price limit method
INPUT double StdDev_PriceLimitLevel = 0;                              // Price limit level
INPUT double StdDev_MaxSpread = 6.0;                                  // Max spread to trade (pips)

// Struct to define strategy parameters to override.
struct Stg_StdDev_Params : Stg_Params {
  unsigned int StdDev_Period;
  ENUM_APPLIED_PRICE StdDev_Applied_Price;
  int StdDev_Shift;
  long StdDev_SignalOpenMethod;
  double StdDev_SignalOpenLevel;
  int StdDev_SignalCloseMethod;
  double StdDev_SignalCloseLevel;
  int StdDev_PriceLimitMethod;
  double StdDev_PriceLimitLevel;
  double StdDev_MaxSpread;

  // Constructor: Set default param values.
  Stg_StdDev_Params()
      : StdDev_Period(::StdDev_Period),
        StdDev_Applied_Price(::StdDev_Applied_Price),
        StdDev_Shift(::StdDev_Shift),
        StdDev_SignalOpenMethod(::StdDev_SignalOpenMethod),
        StdDev_SignalOpenLevel(::StdDev_SignalOpenLevel),
        StdDev_SignalCloseMethod(::StdDev_SignalCloseMethod),
        StdDev_SignalCloseLevel(::StdDev_SignalCloseLevel),
        StdDev_PriceLimitMethod(::StdDev_PriceLimitMethod),
        StdDev_PriceLimitLevel(::StdDev_PriceLimitLevel),
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
    sparams.SetSignals(_params.StdDev_SignalOpenMethod, _params.StdDev_SignalOpenMethod,
                       _params.StdDev_SignalCloseMethod, _params.StdDev_SignalCloseMethod);
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
   *   _method (int) - signal method to use by using bitwise AND operation
   *   _level1 (double) - signal level to consider the signal
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, double _level = 0.0) {
    bool _result = false;
    double stddev_0 = ((Indi_StdDev *)this.Data()).GetValue(0);
    double stddev_1 = ((Indi_StdDev *)this.Data()).GetValue(1);
    double stddev_2 = ((Indi_StdDev *)this.Data()).GetValue(2);
    if (_level1 == EMPTY) _level1 = GetSignalLevel1();
    if (_level2 == EMPTY) _level2 = GetSignalLevel2();
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
          if (METHOD(_method, 0)) _result &= Open[CURR] > Close[CURR];
          */
        break;
      case ORDER_TYPE_SELL:
        /*
          bool _result = StdDev_0[LINE_UPPER] != 0.0 || StdDev_1[LINE_UPPER] != 0.0 || StdDev_2[LINE_UPPER] != 0.0;
          if (METHOD(_method, 0)) _result &= Open[CURR] < Close[CURR];
          */
        break;
    }
    return _result;
  }

  /**
   * Check strategy's closing signal.
   */
  bool SignalClose(ENUM_ORDER_TYPE _cmd, int _method = 0, double _level = 0.0) {
    return SignalOpen(Order::NegateOrderType(_cmd), _method, _level);
  }

  /**
   * Gets price limit value for profit take or stop loss.
   */
  double PriceLimit(ENUM_ORDER_TYPE _cmd, ENUM_STG_PRICE_LIMIT_MODE _mode, int _method = 0, double _level = 0.0) {
    double _trail = _level * Market().GetPipSize();
    int _direction = Order::OrderDirection(_cmd) * (_mode == LIMIT_VALUE_STOP ? -1 : 1);
    double _default_value = Market().GetCloseOffer(_cmd) + _trail * _method * _direction;
    double _result = _default_value;
    switch (_method) {
      case 0: {
        // @todo
      }
    }
    return _result;
  }
};
