//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                       Copyright 2016-2017, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
    This file is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Properties.
#property strict

/**
 * @file
 * Implementation of StdDev Strategy based on the Average True Range indicator (StdDev).
 *
 * @docs
 * - https://docs.mql4.com/indicators/iStdDev
 * - https://www.mql5.com/en/docs/indicators/iStdDev
 */

// Includes.
#include <EA31337-classes\Strategy.mqh>
#include <EA31337-classes\Strategies.mqh>

// User inputs.
#ifdef __input__ input #endif string __StdDev_Parameters__ = "-- Settings for the Standard Deviation indicator --"; // >>> STDDEV <<<
#ifdef __input__ input #endif ENUM_APPLIED_PRICE StdDev_Applied_Price = 0; // Applied Price
#ifdef __input__ input #endif int StdDev_MA_Period = 10; // Period
#ifdef __input__ input #endif ENUM_MA_METHOD StdDev_MA_Method = 0; // MA Method
#ifdef __input__ input #endif int StdDev_MA_Shift = 0; // Shift
#ifdef __input__ input #endif double StdDev_SignalLevel = 0.00000000; // Signal level
#ifdef __input__ input #endif int StdDev_SignalMethod = 31; // Signal method for M1 (0-

class StdDev: public Strategy {
protected:

  double stddev[H1][FINAL_ENUM_INDICATOR_INDEX];
  int       open_method = EMPTY;    // Open method.
  double    open_level  = 0.0;     // Open level.

    public:

  /**
   * Update indicator values.
   */
  bool Update(int tf = EMPTY) {
    // Calculates the Standard Deviation indicator.
    for (i = 0; i < FINAL_ENUM_INDICATOR_INDEX; i++) {
      stddev[index][i] = iStdDev(symbol, tf, StdDev_MA_Period, StdDev_MA_Shift, StdDev_MA_Method, StdDev_Applied_Price, i);
    }
    if (VerboseDebug) PrintFormat("StdDev M%d: %s", tf, Arrays::ArrToString2D(stddev, ",", Digits));
    success = stddev[index][CURR];
  }

  /**
   * Checks whether signal is on buy or sell.
   *
   * @param
   *   cmd (int) - type of trade order command
   *   period (int) - period to check for
   *   signal_method (int) - signal method to use by using bitwise AND operation
   *   signal_level (double) - signal level to consider the signal
   */
  bool Signal(int cmd, ENUM_TIMEFRAMES tf = PERIOD_M1, int signal_method = EMPTY, double signal_level = EMPTY) {
    bool result = FALSE; int period = Timeframe::TfToIndex(tf);
    UpdateIndicator(S_STDDEV, tf);
    if (signal_method == EMPTY) signal_method = GetStrategySignalMethod(S_STDDEV, tf, 0);
    if (signal_level  == EMPTY) signal_level  = GetStrategySignalLevel(S_STDDEV, tf, 0.0);
    switch (cmd) {
      /*
        //27. Standard Deviation
        //Doesn't give independent signals. Is used to define volatility (trend strength).
        //Principle: the trend must be strengthened. Together with this Standard Deviation goes up.
        //Growth on 3 consecutive bars is analyzed
        //Flag is 1 when Standard Deviation rises, 0 - when no growth, -1 - never.
        if (iStdDev(NULL,pistd,pistdu,0,MODE_SMA,PRICE_CLOSE,2)<=iStdDev(NULL,pistd,pistdu,0,MODE_SMA,PRICE_CLOSE,1)&&iStdDev(NULL,pistd,pistdu,0,MODE_SMA,PRICE_CLOSE,1)<=iStdDev(NULL,pistd,pistdu,0,MODE_SMA,PRICE_CLOSE,0))
        {f27=1;}
      */
      case OP_BUY:
        /*
          bool result = StdDev[period][CURR][LOWER] != 0.0 || StdDev[period][PREV][LOWER] != 0.0 || StdDev[period][FAR][LOWER] != 0.0;
          if ((signal_method &   1) != 0) result &= Open[CURR] > Close[CURR];
          if ((signal_method &   2) != 0) result &= !StdDev_On_Sell(tf);
          if ((signal_method &   4) != 0) result &= StdDev_On_Buy(fmin(period + 1, M30));
          if ((signal_method &   8) != 0) result &= StdDev_On_Buy(M30);
          if ((signal_method &  16) != 0) result &= StdDev[period][FAR][LOWER] != 0.0;
          if ((signal_method &  32) != 0) result &= !StdDev_On_Sell(M30);
          */
      break;
      case OP_SELL:
        /*
          bool result = StdDev[period][CURR][UPPER] != 0.0 || StdDev[period][PREV][UPPER] != 0.0 || StdDev[period][FAR][UPPER] != 0.0;
          if ((signal_method &   1) != 0) result &= Open[CURR] < Close[CURR];
          if ((signal_method &   2) != 0) result &= !StdDev_On_Buy(tf);
          if ((signal_method &   4) != 0) result &= StdDev_On_Sell(fmin(period + 1, M30));
          if ((signal_method &   8) != 0) result &= StdDev_On_Sell(M30);
          if ((signal_method &  16) != 0) result &= StdDev[period][FAR][UPPER] != 0.0;
          if ((signal_method &  32) != 0) result &= !StdDev_On_Buy(M30);
          */
      break;
    }
    result &= signal_method <= 0 || Convert::ValueToOp(curr_trend) == cmd;
    return result;
  }
};
