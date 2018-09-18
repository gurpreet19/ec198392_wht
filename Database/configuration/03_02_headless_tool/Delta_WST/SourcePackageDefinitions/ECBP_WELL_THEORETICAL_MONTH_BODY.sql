CREATE OR REPLACE PACKAGE BODY EcBp_well_theoretical_Month IS
/****************************************************************
** Package        :  EcBp_well_theoretical_Month, body part
**
** $Revision: 1.223 $
**
** Purpose        :  Calculates theoretical well values (rates etc)
**
** Documentation  :  www.energy-components.com
**
** Created  : 21.09.2015  Alok Dhavale
**
** Modification history:
**
** Version  Date        Whom      Change description:
** -------  ----------  --------  --------------------------------------
** 1.0      21.09.2015  dhavaalo       Initial version
** 1.1      07.10.2015  dhavaalo       ECPD-32095-New Theoretical Monthly Method for Steam Injection-Function getInjectedStdRateMonth Added
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getOilStdRateMonth
-- Description    : Returns theoretical oil volume for well on a given month, source method specified
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getOilStdRateMonth(p_object_id   well.object_id%TYPE,
                          p_daytime     DATE,
                          p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method            VARCHAR2(32);
  lr_well_version            WELL_VERSION%ROWTYPE;
  lr_pwel_mth_status         PWEL_MTH_STATUS%ROWTYPE;
  ln_ret_val                 NUMBER;
  lr_pwel_result             PWEL_RESULT%ROWTYPE;
  lr_pwel_result_next        PWEL_RESULT%ROWTYPE;
  valid_test_date            DATE;
  ln_oil_rate_per_hr         NUMBER;
  ln_prod_hrs                NUMBER;
  ln_estimated_prod          NUMBER :=0;

BEGIN

lr_well_version :=ec_well_version.row_by_pk(p_object_id, p_daytime, '<=');
lv2_calc_method := NVL(p_calc_method, lr_well_version.CALC_OIL_MTH_METHOD);

IF (lv2_calc_method IS NOT NULL) THEN
    lr_pwel_mth_status := ec_pwel_mth_status.row_by_pk(p_object_id, p_daytime);

  IF (lv2_calc_method = EcDp_Calc_Method.MEASURED_NET) THEN
      ln_ret_val := lr_pwel_mth_status.oil_vol;

  ELSIF (lv2_calc_method = EcDp_Calc_Method.PERIOD_WELL_TEST) THEN

  valid_test_date:=p_daytime;--to execute while loop

  WHILE valid_test_date<=TRUNC(LAST_DAY(p_daytime))
    LOOP
       lr_pwel_result:=NULL;
       lr_pwel_result := EcDp_Performance_Test.getLastValidWellResult(p_object_id, valid_test_date);

       IF(lr_pwel_result.result_no IS NULL) THEN
          lr_pwel_result := EcDp_Performance_Test.getNextValidWellResult(p_object_id, TRUNC(p_daytime,'month'));
       END IF;
       ln_oil_rate_per_hr:=lr_pwel_result.net_oil_rate_adj/24;
       lr_pwel_result_next := EcDp_Performance_Test.getNextValidWellResult(p_object_id, lr_pwel_result.valid_from_date+1);

       IF(TO_CHAR(lr_pwel_result.valid_from_date,'MON')=TO_CHAR(p_daytime,'MON')) THEN

       ln_prod_hrs:=ec_pwel_day_status.math_on_stream_hrs(p_object_id,lr_pwel_result.valid_from_date,
       CASE WHEN TO_CHAR(lr_pwel_result_next.valid_from_date,'MON')=TO_CHAR(lr_pwel_result.valid_from_date,'MON') THEN (lr_pwel_result_next.valid_from_date-1)
            WHEN TO_CHAR(lr_pwel_result_next.valid_from_date,'MON')!=TO_CHAR(lr_pwel_result.valid_from_date,'MON') THEN TRUNC(LAST_DAY(p_daytime))
            WHEN lr_pwel_result_next.valid_from_date IS NULL THEN TRUNC(LAST_DAY(p_daytime)) END,
        'SUM');
        ELSE
        ln_prod_hrs:=ec_pwel_day_status.math_on_stream_hrs(p_object_id,TRUNC (p_daytime, 'month'),lr_pwel_result_next.valid_from_date-1,'SUM');
        END IF;

       ln_estimated_prod:=ln_estimated_prod+ROUND(ln_prod_hrs*ln_oil_rate_per_hr,1);
       valid_test_date:=lr_pwel_result_next.valid_from_date;

    END LOOP;
          ln_ret_val:=ln_estimated_prod;

  ELSIF (SUBSTR(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_ret_val := Ue_Well_Theoretical_Month.getOilStdRateMonth(p_object_id,p_daytime);
  END IF;

ELSE
        ln_ret_val := NULL;
END IF;

  RETURN ln_ret_val;

END getOilStdRateMonth;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasStdRateMonth
-- Description    : Returns theoretical gas volume for well on a given month, source method specified
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getGasStdRateMonth(p_object_id   well.object_id%TYPE,
                          p_daytime     DATE,
                          p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method            VARCHAR2(32);
  lr_well_version            WELL_VERSION%ROWTYPE;
  lr_pwel_mth_status         PWEL_MTH_STATUS%ROWTYPE;
  ln_ret_val                 NUMBER;
  lr_pwel_result             PWEL_RESULT%ROWTYPE;
  lr_pwel_result_next        PWEL_RESULT%ROWTYPE;
  valid_test_date            DATE;
  ln_gas_rate_per_hr         NUMBER;
  ln_prod_hrs                NUMBER;
  ln_estimated_prod          NUMBER :=0;

BEGIN

lr_well_version :=ec_well_version.row_by_pk(p_object_id, p_daytime, '<=');
lv2_calc_method := NVL(p_calc_method, lr_well_version.CALC_GAS_MTH_METHOD);

IF (lv2_calc_method IS NOT NULL) THEN
    lr_pwel_mth_status := ec_pwel_mth_status.row_by_pk(p_object_id, p_daytime);

  IF (lv2_calc_method = EcDp_Calc_Method.MEASURED_NET) THEN
      ln_ret_val := lr_pwel_mth_status.gas_vol;

  ELSIF (lv2_calc_method = EcDp_Calc_Method.PERIOD_WELL_TEST) THEN

  valid_test_date:=p_daytime;--to execute while loop

  WHILE valid_test_date<=TRUNC(LAST_DAY(p_daytime))
    LOOP
       lr_pwel_result:=NULL;
       lr_pwel_result := EcDp_Performance_Test.getLastValidWellResult(p_object_id, valid_test_date);

       IF(lr_pwel_result.result_no IS NULL) THEN
          lr_pwel_result := EcDp_Performance_Test.getNextValidWellResult(p_object_id, TRUNC(p_daytime,'month'));
       END IF;
       ln_gas_rate_per_hr:=lr_pwel_result.gas_rate_adj/24;
       lr_pwel_result_next := EcDp_Performance_Test.getNextValidWellResult(p_object_id, lr_pwel_result.valid_from_date+1);

       IF(TO_CHAR(lr_pwel_result.valid_from_date,'MON')=TO_CHAR(p_daytime,'MON')) THEN

       ln_prod_hrs:=ec_pwel_day_status.math_on_stream_hrs(p_object_id,lr_pwel_result.valid_from_date,
       CASE WHEN TO_CHAR(lr_pwel_result_next.valid_from_date,'MON')=TO_CHAR(lr_pwel_result.valid_from_date,'MON') THEN (lr_pwel_result_next.valid_from_date-1)
            WHEN TO_CHAR(lr_pwel_result_next.valid_from_date,'MON')!=TO_CHAR(lr_pwel_result.valid_from_date,'MON') THEN TRUNC(LAST_DAY(p_daytime))
            WHEN lr_pwel_result_next.valid_from_date IS NULL THEN TRUNC(LAST_DAY(p_daytime)) END,
        'SUM');
        ELSE
        ln_prod_hrs:=ec_pwel_day_status.math_on_stream_hrs(p_object_id,TRUNC (p_daytime, 'month'),lr_pwel_result_next.valid_from_date-1,'SUM');
        END IF;

       ln_estimated_prod:=ln_estimated_prod+ROUND(ln_prod_hrs*ln_gas_rate_per_hr,1);
       valid_test_date:=lr_pwel_result_next.valid_from_date;

    END LOOP;
          ln_ret_val:=ln_estimated_prod;

  ELSIF (SUBSTR(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_ret_val := Ue_Well_Theoretical_Month.getGasStdRateMonth(p_object_id,p_daytime);
  END IF;

ELSE
        ln_ret_val := NULL;
END IF;

  RETURN ln_ret_val;

END getGasStdRateMonth;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWatStdRateMonth
-- Description    : Returns theoretical water volume for well on a given month, source method specified
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getWatStdRateMonth(p_object_id   well.object_id%TYPE,
                          p_daytime     DATE,
                          p_calc_method VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method            VARCHAR2(32);
  lr_well_version            WELL_VERSION%ROWTYPE;
  lr_pwel_mth_status         PWEL_MTH_STATUS%ROWTYPE;
  ln_ret_val                 NUMBER;
  lr_pwel_result             PWEL_RESULT%ROWTYPE;
  lr_pwel_result_next        PWEL_RESULT%ROWTYPE;
  valid_test_date            DATE;
  ln_water_rate_per_hr       NUMBER;
  ln_prod_hrs                NUMBER;
  ln_estimated_prod          NUMBER :=0;

BEGIN

lr_well_version :=ec_well_version.row_by_pk(p_object_id, p_daytime, '<=');
lv2_calc_method := NVL(p_calc_method, lr_well_version.CALC_WATER_MTH_METHOD);

IF (lv2_calc_method IS NOT NULL) THEN
    lr_pwel_mth_status := ec_pwel_mth_status.row_by_pk(p_object_id, p_daytime);

  IF (lv2_calc_method = EcDp_Calc_Method.MEASURED_NET) THEN
      ln_ret_val := lr_pwel_mth_status.water_vol;

  ELSIF (lv2_calc_method = EcDp_Calc_Method.PERIOD_WELL_TEST) THEN

  valid_test_date:=p_daytime;--to execute while loop

  WHILE valid_test_date<=TRUNC(LAST_DAY(p_daytime))
    LOOP
       lr_pwel_result:=NULL;
       lr_pwel_result := EcDp_Performance_Test.getLastValidWellResult(p_object_id, valid_test_date);

       IF(lr_pwel_result.result_no IS NULL) THEN
          lr_pwel_result := EcDp_Performance_Test.getNextValidWellResult(p_object_id, TRUNC(p_daytime,'month'));
       END IF;
       ln_water_rate_per_hr:=lr_pwel_result.tot_water_rate_adj/24;
       lr_pwel_result_next := EcDp_Performance_Test.getNextValidWellResult(p_object_id, lr_pwel_result.valid_from_date+1);

       IF(TO_CHAR(lr_pwel_result.valid_from_date,'MON')=TO_CHAR(p_daytime,'MON')) THEN

       ln_prod_hrs:=ec_pwel_day_status.math_on_stream_hrs(p_object_id,lr_pwel_result.valid_from_date,
       CASE WHEN TO_CHAR(lr_pwel_result_next.valid_from_date,'MON')=TO_CHAR(lr_pwel_result.valid_from_date,'MON') THEN (lr_pwel_result_next.valid_from_date-1)
            WHEN TO_CHAR(lr_pwel_result_next.valid_from_date,'MON')!=TO_CHAR(lr_pwel_result.valid_from_date,'MON') THEN TRUNC(LAST_DAY(p_daytime))
            when lr_pwel_result_next.valid_from_date IS NULL THEN TRUNC(LAST_DAY(p_daytime)) END,
        'SUM');
        ELSE
        ln_prod_hrs:=ec_pwel_day_status.math_on_stream_hrs(p_object_id,TRUNC (p_daytime, 'month'),lr_pwel_result_next.valid_from_date-1,'SUM');
        END IF;

       ln_estimated_prod:=ln_estimated_prod+ROUND(ln_prod_hrs*ln_water_rate_per_hr,1);
       valid_test_date:=lr_pwel_result_next.valid_from_date;

    END LOOP;
          ln_ret_val:=ln_estimated_prod;

  ELSIF (SUBSTR(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_ret_val := Ue_Well_Theoretical_Month.getWatStdRateMonth(p_object_id,p_daytime);
  END IF;

ELSE
        ln_ret_val := NULL;
END IF;

  RETURN ln_ret_val;

END getWatStdRateMonth;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCondStdRateMonth
-- Description    : Returns theoretical condensate volume for well on a given month, source method specified
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getCondStdRateMonth(p_object_id   well.object_id%TYPE,
                           p_daytime     DATE,
                           p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method            VARCHAR2(32);
  lr_well_version            WELL_VERSION%ROWTYPE;
  lr_pwel_mth_status         PWEL_MTH_STATUS%ROWTYPE;
  ln_ret_val                 NUMBER;
  lr_pwel_result             PWEL_RESULT%ROWTYPE;
  lr_pwel_result_next        PWEL_RESULT%ROWTYPE;
  valid_test_date            DATE;
  ln_cond_rate_per_hr        NUMBER;
  ln_prod_hrs                NUMBER;
  ln_estimated_prod          NUMBER :=0;

BEGIN

lr_well_version :=ec_well_version.row_by_pk(p_object_id, p_daytime, '<=');
lv2_calc_method := NVL(p_calc_method, lr_well_version.CALC_COND_MTH_METHOD);

IF (lv2_calc_method IS NOT NULL) THEN
    lr_pwel_mth_status := ec_pwel_mth_status.row_by_pk(p_object_id, p_daytime);

  IF (lv2_calc_method = EcDp_Calc_Method.MEASURED_NET) THEN
      ln_ret_val := lr_pwel_mth_status.cond_vol;

  ELSIF (lv2_calc_method = EcDp_Calc_Method.PERIOD_WELL_TEST) THEN

  valid_test_date:=p_daytime;--to execute while loop

  WHILE valid_test_date<=TRUNC(LAST_DAY(p_daytime))
    LOOP
       lr_pwel_result:=NULL;
       lr_pwel_result := EcDp_Performance_Test.getLastValidWellResult(p_object_id, valid_test_date);

       IF(lr_pwel_result.result_no IS NULL) THEN
          lr_pwel_result := EcDp_Performance_Test.getNextValidWellResult(p_object_id, TRUNC(p_daytime,'month'));
       END IF;
       ln_cond_rate_per_hr:=lr_pwel_result.net_cond_rate_adj/24;
       lr_pwel_result_next := EcDp_Performance_Test.getNextValidWellResult(p_object_id, lr_pwel_result.valid_from_date+1);

       IF(TO_CHAR(lr_pwel_result.valid_from_date,'MON')=TO_CHAR(p_daytime,'MON')) THEN

       ln_prod_hrs:=ec_pwel_day_status.math_on_stream_hrs(p_object_id,lr_pwel_result.valid_from_date,
       CASE WHEN TO_CHAR(lr_pwel_result_next.valid_from_date,'MON')=TO_CHAR(lr_pwel_result.valid_from_date,'MON') THEN (lr_pwel_result_next.valid_from_date-1)
            WHEN TO_CHAR(lr_pwel_result_next.valid_from_date,'MON')!=TO_CHAR(lr_pwel_result.valid_from_date,'MON') THEN TRUNC(LAST_DAY(p_daytime))
            when lr_pwel_result_next.valid_from_date IS NULL THEN TRUNC(LAST_DAY(p_daytime)) END,
        'SUM');
        ELSE
        ln_prod_hrs:=ec_pwel_day_status.math_on_stream_hrs(p_object_id,TRUNC (p_daytime, 'month'),lr_pwel_result_next.valid_from_date-1,'SUM');
        END IF;

       ln_estimated_prod:=ln_estimated_prod+ROUND(ln_prod_hrs*ln_cond_rate_per_hr,1);
       valid_test_date:=lr_pwel_result_next.valid_from_date;

    END LOOP;
          ln_ret_val:=ln_estimated_prod;

  ELSIF (SUBSTR(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_ret_val := Ue_Well_Theoretical_Month.getCondStdRateMonth(p_object_id,p_daytime);
  END IF;
ELSE
        ln_ret_val := NULL;
END IF;

  RETURN ln_ret_val;

END getCondStdRateMonth;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getInjectedStdRateDay
-- Description    : Returns theoretical injection volume for well on a given day, source method specified
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getInjectedStdRateMonth(p_object_id   well.object_id%TYPE,
                               p_inj_type    VARCHAR2,
                               p_daytime     DATE,
                               p_calc_inj_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
   lv2_calc_inj_method    VARCHAR2(32);
   ln_ret_val         NUMBER;
   lr_well_version    WELL_VERSION%ROWTYPE;
   lr_iwel_mth_status        IWEL_MTH_STATUS%ROWTYPE;
   ln_total_val 			  NUMBER:=0;
   ln_return_val			  NUMBER;
  CURSOR c_system_days IS
  SELECT daytime
  FROM system_days
  WHERE daytime BETWEEN p_daytime AND LAST_dAY(p_daytime);

BEGIN

  lr_well_version := ec_well_version.row_by_pk(p_object_id, p_daytime, '<=');
  lr_iwel_mth_status := ec_iwel_mth_status.row_by_pk(p_object_id, p_daytime,p_inj_type);
 IF (p_inj_type = Ecdp_Well_Type.STEAM_INJECTOR) THEN
    lv2_calc_inj_method := Nvl(p_calc_inj_method, lr_well_version.calc_steam_inj_mth_mtd);
 END IF;

 IF (NVL(lr_well_version.ALLOW_THEOR_OVERRIDE_MTH, 'N') = 'Y' AND lr_iwel_mth_status.OVERRIDE_THEOR_INJ_VOL IS NOT NULL) THEN
      ln_ret_val := lr_iwel_mth_status.OVERRIDE_THEOR_INJ_VOL;
 ELSE

 IF (lv2_calc_inj_method = Ecdp_Calc_Method.MEASURED) THEN
    ln_ret_val := lr_iwel_mth_status.inj_vol;

 ELSIF (lv2_calc_inj_method = Ecdp_Calc_Method.SUM_FROM_DAILY) THEN

  FOR mycur IN c_system_days LOOP

  ln_return_val := EcBp_well_theoretical.getInjectedStdRateDay(
                                  p_object_id,
                                 'SI',
                                  mycur.daytime);

    ln_total_val := ln_total_val + NVL(ln_return_val,0);
   END LOOP;
	ln_ret_val :=ln_total_val;

 ELSIF (lv2_calc_inj_method = Ecdp_Calc_Method.SUM_FROM_DAILY_ALLOCATED) THEN

   FOR mycur IN c_system_days LOOP

   ln_return_val := ec_iwel_day_alloc.alloc_inj_vol(p_object_id, mycur.daytime, 'SI');

   ln_total_val := ln_total_val + NVL(ln_return_val,0);
   END LOOP;
    ln_ret_val :=ln_total_val;

 ELSIF (substr(lv2_calc_inj_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_ret_val := Ue_Well_Theoretical_Month.getInjectedStdRateMonth(
                    p_object_id,
                    p_inj_type,
                    p_daytime);

 END IF;
 END IF;

  RETURN ln_ret_val;

END getInjectedStdRateMonth;

END EcBp_well_theoretical_Month;