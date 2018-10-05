CREATE OR REPLACE PACKAGE BODY EcDp_Lift_Acc_Forecast IS
/****************************************************************
** Package        :  EcDp_Lift_Acc_Forecast; body part
**
** $Revision: 1.8 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  13.09.2006  Kari Sandvik
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
** 01.07.2011  meisihil  Added new getTotalMonth function
** 08.03.2011  chooysie  ECPD-23227 added function to populate production_day and summer_time
******************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getForecastMonth
-- Description    : Retreives the total forecast number for the month.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :  lift_acc_day_forecast
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION getForecastMonth(p_object_id VARCHAR2,
        p_daytime DATE,
        p_xtra_qty NUMBER DEFAULT 0)
RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_all(cp_object_id VARCHAR2, cp_from DATE, cp_to DATE) IS

  SELECT SUM(forecast_qty) forecast_qty, SUM(forecast_qty2) forecast_qty2, SUM(forecast_qty3) forecast_qty3
  FROM   lift_acc_day_forecast
  WHERE  object_id = cp_object_id
        AND daytime >= cp_from
        AND daytime < cp_to;

  ln_forecast_qty      NUMBER := NULL;
  ld_fist_of_next_month   DATE;

BEGIN
  ld_fist_of_next_month := add_months(p_daytime, 1);

  FOR curAll IN c_all (p_object_id, p_daytime, ld_fist_of_next_month) LOOP

    if (p_xtra_qty = 1 ) THEN
      ln_forecast_qty := curAll.forecast_qty2;
    ELSIF
       (p_xtra_qty = 2 ) THEN
      ln_forecast_qty := curAll.forecast_qty3;
    ELSE
      ln_forecast_qty := curAll.forecast_qty;
    END IF;
  END LOOP;

  RETURN ln_forecast_qty;

END getForecastMonth;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalMonth
-- Description    : Retreives the total official/forecast number for the month.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :  lift_acc_day_forecast, lift_acc_day_official
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION getTotalMonth(p_object_id VARCHAR2,
        p_daytime DATE,
        p_xtra_qty NUMBER DEFAULT 0)
RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_all(cp_object_id VARCHAR2, cp_from DATE, cp_to DATE) IS

  SELECT sum(nvl(o.official_qty, f.forecast_qty)) qty,
         sum(nvl(o.official_qty2, f.forecast_qty2)) qty2,
         sum(nvl(o.official_qty3, f.forecast_qty3)) qty3
  FROM  lift_acc_day_forecast f, lift_acc_day_official o
  WHERE  o.object_id (+)= f.object_id
      AND f.object_id = cp_object_id
         and o.daytime (+)= f.daytime
         and f.daytime >= cp_from
         and f.daytime < cp_to;

  ln_qty      NUMBER := NULL;
  ld_fist_of_next_month   DATE;

BEGIN
  ld_fist_of_next_month := add_months(p_daytime, 1);

  FOR curAll IN c_all (p_object_id, p_daytime, ld_fist_of_next_month) LOOP

    if (p_xtra_qty = 1 ) THEN
      ln_qty := curAll.qty2;
    ELSIF
       (p_xtra_qty = 2 ) THEN
      ln_qty := curAll.qty3;
    ELSE
      ln_qty := curAll.qty;
    END IF;
  END LOOP;

  RETURN ln_qty;

END getTotalMonth;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : aggregateSubDay
-- Description    : Sums up hourly nomination quantities and stores the result in the daily data table.
--
-- Preconditions  : p_daytime should be production day. Daily record must exist before sub daily record
-- Postconditions :
--
-- Using tables   : lift_acc_sub_day_forecast
--                  lift_acc_day_forecast
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Finds the sum of all the sub-daily quantities for the given day. The resulting
--                  quantity is written to the daily table.
--
---------------------------------------------------------------------------------------------------
PROCEDURE aggregateSubDay(p_object_id VARCHAR2,
              p_daytime   DATE,
              p_xtra_qty  NUMBER DEFAULT 0)
--</EC-DOC>
 IS
  CURSOR c_sum_sub_day(cp_object_id VARCHAR2, cp_daytime DATE) IS
    SELECT SUM(forecast_qty) forecast
      FROM lift_acc_sub_day_forecast
     WHERE object_id = cp_object_id
       AND production_day = cp_daytime;

  CURSOR c_sum_sub_day2(cp_object_id VARCHAR2, cp_daytime DATE) IS
    SELECT SUM(forecast_qty2) forecast2
      FROM lift_acc_sub_day_forecast
     WHERE object_id = cp_object_id
       AND production_day = cp_daytime;

   CURSOR c_sum_sub_day3(cp_object_id VARCHAR2, cp_daytime DATE) IS
    SELECT SUM(forecast_qty3) forecast3
      FROM lift_acc_sub_day_forecast
     WHERE object_id = cp_object_id
       AND production_day = cp_daytime;

  ln_sum_sub_day NUMBER;

BEGIN
  IF (p_xtra_qty = 0) THEN
    FOR curSum IN c_sum_sub_day(p_object_id, p_daytime) LOOP
      ln_sum_sub_day := curSum.forecast;
    END LOOP;

    UPDATE lift_acc_day_forecast
       SET forecast_qty = ln_sum_sub_day, last_updated_by = ecdp_context.getAppUser
     WHERE object_id = p_object_id
       AND daytime = p_daytime;

  ELSIF (p_xtra_qty = 1) THEN
    FOR curSum IN c_sum_sub_day2(p_object_id, p_daytime) LOOP
      ln_sum_sub_day := curSum.forecast2;
    END LOOP;

    UPDATE lift_acc_day_forecast
       SET forecast_qty2 = ln_sum_sub_day, last_updated_by = ecdp_context.getAppUser
     WHERE object_id = p_object_id
       AND daytime = p_daytime;

    ELSIF (p_xtra_qty = 2) THEN
    FOR curSum IN c_sum_sub_day3(p_object_id, p_daytime) LOOP
      ln_sum_sub_day := curSum.forecast3;
    END LOOP;

    UPDATE lift_acc_day_forecast
       SET forecast_qty3 = ln_sum_sub_day, last_updated_by = ecdp_context.getAppUser
     WHERE object_id = p_object_id
       AND daytime = p_daytime;

  END IF;
END aggregateSubDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : aggregateFcstSubDay
-- Description    : Sums up hourly nomination quantities and stores the result in the daily data table.
--
-- Preconditions  : p_daytime should be production day. Daily record must exist before sub daily record
-- Postconditions :
--
-- Using tables   : LIFT_ACC_SUB_DAY_FCST_FC
--                  LIFT_ACC_DAY_FCST_FCAST
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Finds the sum of all the sub-daily quantities for the given day. The resulting
--                  quantity is written to the daily table.
--
---------------------------------------------------------------------------------------------------
PROCEDURE aggregateFcstSubDay(p_forecast_id VARCHAR2,
                              p_object_id VARCHAR2,
                  p_daytime   DATE,
                  p_xtra_qty  NUMBER DEFAULT 0)
--</EC-DOC>
 IS
  CURSOR c_sum_sub_day(cp_forecast_id VARCHAR2, cp_object_id VARCHAR2, cp_daytime DATE) IS
    SELECT SUM(forecast_qty) forecast
      FROM lift_acc_sub_day_fcst_fc
     WHERE object_id = cp_object_id
       AND production_day = cp_daytime
       AND forecast_id = cp_forecast_id;

  CURSOR c_sum_sub_day2(cp_forecast_id VARCHAR2, cp_object_id VARCHAR2, cp_daytime DATE) IS
    SELECT SUM(forecast_qty2) forecast2
      FROM lift_acc_sub_day_fcst_fc
     WHERE object_id = cp_object_id
       AND production_day = cp_daytime
       AND forecast_id = cp_forecast_id;

  CURSOR c_sum_sub_day3(cp_forecast_id VARCHAR2, cp_object_id VARCHAR2, cp_daytime DATE) IS
    SELECT SUM(forecast_qty3) forecast3
      FROM lift_acc_sub_day_fcst_fc
     WHERE object_id = cp_object_id
       AND production_day = cp_daytime
       AND forecast_id = cp_forecast_id;

  ln_sum_sub_day NUMBER;

BEGIN
  IF (p_xtra_qty = 0) THEN
    FOR curSum IN c_sum_sub_day(p_forecast_id, p_object_id, p_daytime) LOOP
      ln_sum_sub_day := curSum.forecast;
    END LOOP;

    UPDATE lift_acc_day_fcst_fcast
       SET forecast_qty = ln_sum_sub_day, last_updated_by = ecdp_context.getAppUser
     WHERE object_id = p_object_id
       AND daytime = p_daytime
       AND forecast_id = p_forecast_id;

  ELSIF (p_xtra_qty = 1) THEN
    FOR curSum IN c_sum_sub_day2(p_forecast_id, p_object_id, p_daytime) LOOP
      ln_sum_sub_day := curSum.forecast2;
    END LOOP;

    UPDATE lift_acc_day_fcst_fcast
       SET forecast_qty2 = ln_sum_sub_day, last_updated_by = ecdp_context.getAppUser
     WHERE object_id = p_object_id
       AND daytime = p_daytime
       AND forecast_id = p_forecast_id;

  ELSIF (p_xtra_qty = 2) THEN
    FOR curSum IN c_sum_sub_day3(p_forecast_id, p_object_id, p_daytime) LOOP
      ln_sum_sub_day := curSum.forecast3;
    END LOOP;

    UPDATE lift_acc_day_fcst_fcast
       SET forecast_qty3 = ln_sum_sub_day, last_updated_by = ecdp_context.getAppUser
     WHERE object_id = p_object_id
       AND daytime = p_daytime
       AND forecast_id = p_forecast_id;

  END IF;
END aggregateFcstSubDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : populateSubDailyValueAdj
-- Description    : Update production_day and summer time value.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCST_LIFT_ACC_ADJ
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Update production_day and summer_time value.
--
---------------------------------------------------------------------------------------------------
PROCEDURE populateSubDailyValueAdj(p_object_id VARCHAR2,
              p_daytime   DATE,
              p_forecast_id VARCHAR2)
--</EC-DOC>
IS
lv_pday_object_id	VARCHAR2(32);
lv_summer_time VARCHAR2(1);
ld_production_day date;

BEGIN
    lv_pday_object_id := EcDp_ProductionDay.findProductionDayDefinition(NULL, p_object_id, p_daytime);

    lv_summer_time := null;
    ld_production_day := null;

     IF lv_summer_time IS NULL THEN
        lv_summer_time := EcDp_Date_Time.summertime_flag(p_daytime, NULL, lv_pday_object_id);
     END IF;

     IF ld_production_day IS NULL THEN
        ld_production_day := EcDp_ProductionDay.getProductionDay('LIFTING_ACCOUNT', p_object_id, p_daytime, lv_summer_time);
     END IF;

    UPDATE FCST_LIFT_ACC_ADJ
       SET production_day = ld_production_day, summer_time = lv_summer_time
     WHERE object_id = p_object_id
       AND daytime = p_daytime
       AND forecast_id = p_forecast_id;

END populateSubDailyValueAdj;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : populateSubDailyValueSinAdj
-- Description    : Update production_day and summer time value.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCST_LIFT_ACC_ADJ_SINGLE
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Update production_day and summer_time value.
--
---------------------------------------------------------------------------------------------------
PROCEDURE populateSubDailyValueSinAdj(p_object_id VARCHAR2,
              p_daytime   DATE,
              p_forecast_id VARCHAR2)
--</EC-DOC>
IS
lv_pday_object_id	VARCHAR2(32);
lv_summer_time VARCHAR2(1);
ld_production_day date;

BEGIN
    lv_pday_object_id := EcDp_ProductionDay.findProductionDayDefinition(NULL, p_object_id, p_daytime);

    lv_summer_time := null;
    ld_production_day := null;

     IF lv_summer_time IS NULL THEN
        lv_summer_time := EcDp_Date_Time.summertime_flag(p_daytime, NULL, lv_pday_object_id);
     END IF;

     IF ld_production_day IS NULL THEN
        ld_production_day := EcDp_ProductionDay.getProductionDay('LIFTING_ACCOUNT', p_object_id, p_daytime, lv_summer_time);
     END IF;

    UPDATE FCST_LIFT_ACC_ADJ_SINGLE
       SET production_day = ld_production_day, summer_time = lv_summer_time
     WHERE object_id = p_object_id
       AND daytime = p_daytime
       AND forecast_id = p_forecast_id;

END populateSubDailyValueSinAdj;

END EcDp_Lift_Acc_Forecast;