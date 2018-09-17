CREATE OR REPLACE PACKAGE BODY Ecdp_Well_Test_Curve IS
/******************************************************************************
** Package        :  Ecdp_Well_Test_Curve, body part
**
** $Revision: 1.15 $
**
** Purpose        :  Business logic for trending curves for well test results for the PT module.
**
** Documentation  :  www.energy-components.com
**
** Created  : 25.08.2005 Ron Boh
**
** Modification history:
**
** Date        Whom      Change description:
** ----------  -----     --------------------------------------------------------------------------
** 08.06.2006  DN        Procedure analyzeTrend: Dynamic SQL replaced with plain UPDATE statement.
** 01.10.2007  zakiiari  ECPD-5765: - Added extra parameter to getYfromX
**                                  - Added getTrendSegmentStartDaytime, trendCurveRowCount, copyTrendSegment, convertLnToExp, acceptTestResult, rejectTestResult
** 24.03.2010  sharawan  ECPD-13077: Added LIQUID_RATE_ADJ Trend Parameter to the analyzeTrend procedure.
** 05.12.2010  limmmchu  ECPD-22424: Modified analyzeTrend() to support include todate.
** 28.08.2014  shindani  ECPD-27724: Modified function trendSegmentRowCount() , removed trend_analysis_ind flag condition.
** 13.10.2015  leongwen  ECPD-30954: Modified procedure acceptTestResult and rejectTestResult to update the USE_CALC with "N", include the similar test_device_result update, and add rev_text with screen name,
**                                   to differentiate the rev_text get updated to ptst_result, pwel_result and eqpm_result from "Trend and Validate Test Result" (PT.0012) screen.
**                                   Because the Ecdp_Performance_Test.acceptTestResult, acceptTestResultNoAlloc and rejectTestResult from "Production Test Result" (PT.0010) screen
**                                   would update the same column rev_text on the same tables.
**26.10.2016   singishi  ECPD-30801: Trend and Validate Test Result screen: added trend_method=actual.
********************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : analyzeTrend
-- Description    : Analyze the data for the segment of test results by calculating the Coefficients (C1 and C2) for
--		    all the 4 different Rates (oil, gas, cond, water).
--
-- Preconditions  :
-- Postconditions : Selected row of test results will have its C1s and C2s updated.
--
-- Using tables   : PWEL_RESULT, PTST_RESUL
-- Using functions: EcBp_Mathlib.calcLinearRegression
--		    ec_bs_obj_pop.execute_statement
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE analyzeTrend(p_object_id VARCHAR2, p_result_no NUMBER, p_focus_date DATE, p_from_daytime DATE, p_to_daytime DATE, p_user VARCHAR2)
--</EC-DOC>
IS

   ln_C0 NUMBER := 0;
   ln_C1 NUMBER := 0;
   ln_R2 NUMBER := 0;
   ln_slope NUMBER:=0;
   ln_y_intersect NUMBER:=0;
   ln_tempValue NUMBER:=0;
   ln_r NUMBER := 0;
   ld_next_daytime DATE := p_to_daytime+1;

   i NUMBER:=0;
   lv2_oil_status VARCHAR2(30) := 'NO_ZERO';
   lv2_gas_status VARCHAR2(30) := 'NO_ZERO';
   lv2_cond_status VARCHAR2(30) := 'NO_ZERO';
   lv2_wat_status VARCHAR2(30) := 'NO_ZERO';
   lv2_gor_status VARCHAR2(30) := 'NO_ZERO';
   lv2_watcut_status VARCHAR2(30) := 'NO_ZERO';
   lv2_cgr_status VARCHAR2(30) := 'NO_ZERO';
   lv2_wgr_status VARCHAR2(30) := 'NO_ZERO';
   lv2_liq_status VARCHAR2(30) := 'NO_ZERO';
   lv2_whp_status VARCHAR2(30) := 'NO_ZERO';
   lv2_bhp_status VARCHAR2(30) := 'NO_ZERO';


   oilRatePoints Ecbp_mathlib.Ec_discrete_func_type;
   gasRatePoints Ecbp_mathlib.Ec_discrete_func_type;
   condRatePoints Ecbp_mathlib.Ec_discrete_func_type;
   watRatePoints Ecbp_mathlib.Ec_discrete_func_type;

   -- ECPD-5765: adding gor,watercut,cgr,wgr
   gorRatePoints Ecbp_mathlib.Ec_discrete_func_type;
   watercutRatePoints Ecbp_mathlib.Ec_discrete_func_type;
   cgrRatePoints Ecbp_mathlib.Ec_discrete_func_type;
   wgrRatePoints Ecbp_mathlib.Ec_discrete_func_type;

   -- ECPD-13077: adding Liquid Rate
   liqRatePoints Ecbp_mathlib.Ec_discrete_func_type;

   -- ECPD-13374: adding SI WH Press and SI BH Press
   siWhpRatePoints Ecbp_mathlib.Ec_discrete_func_type;
   siBhpPoints Ecbp_mathlib.Ec_discrete_func_type;

   ld_min_daytime          DATE;
   ld_min_daytime_2        DATE;
   ld_max_daytime          DATE;
   ln_row_count            NUMBER;
   n_lock_columns          EcDp_Month_lock.column_list;
   lr_result               PTST_RESULT%ROWTYPE;
   ld_trend_start          DATE;
   ln_trend_curve_count    NUMBER;
   lv_trend_src            VARCHAR2(2000);
   ld_max_daytime_2        DATE;


   CURSOR min_daytime_2_cur is
         SELECT MIN(ptst_result.DAYTIME) as min_daytime_2 from pwel_result, ptst_result
         where pwel_result.result_no = ptst_result.result_no
         and pwel_result.OBJECT_ID = p_object_id
         AND ptst_result.DAYTIME <= p_focus_date
         AND ptst_result.DAYTIME >= p_from_daytime;

   CURSOR RatePoints_cur(c_min_daytime DATE, c_min_daytime_2 DATE, c_max_daytime DATE, c_object_id VARCHAR2) IS
      select pwel_result.net_oil_rate_adj as oil_y,
             pwel_result.gas_rate_adj as gas_y,
             pwel_result.net_cond_rate_adj as cond_y,
             pwel_result.tot_water_rate_adj as wat_y,
             pwel_result.gor as gor_y,
             pwel_result.watercut_pct as watercut_y,
             pwel_result.cgr as cgr_y,
             pwel_result.wgr as wgr_y,
             pwel_result.si_whp as whp_y,
             pwel_result.si_bhp as bhp_y,
             (ptst_result.daytime - nvl(c_min_daytime,c_min_daytime_2)) as x,
             pwel_result.result_no as result_no
	           from pwel_result, ptst_result
             where pwel_result.result_no = ptst_result.result_no
	           AND pwel_result.trend_analysis_ind = 'Y'
	           AND ptst_result.DAYTIME >= NVL(c_min_daytime, p_from_daytime)
	           AND ptst_result.DAYTIME < NVL(c_max_daytime, ld_next_daytime)
             AND ptst_result.DAYTIME between p_from_daytime and ld_next_daytime
             AND pwel_result.object_id = c_object_id
             order by ptst_result.DAYTIME DESC;

   CURSOR trendCurve_cur(cp_trendStartDate DATE) IS
     SELECT * FROM trend_curve
     WHERE trend_curve.object_id = p_object_id
     AND trend_curve.daytime = cp_trendStartDate;

   CURSOR c_max_trend_segment_daytime2(cp_min_daytime DATE, cp_max_daytime DATE) IS
     SELECT MAX(pr.daytime) as daytime
     FROM pwel_result pr
     where pr.object_id = p_object_id
     and pr.daytime >= nvl(cp_min_daytime, p_from_daytime)
     and pr.daytime < nvl(cp_max_daytime, ld_next_daytime)
     and pr.trend_analysis_ind='Y'
     and pr.primary_ind='Y'
     and ec_ptst_result.status(result_no) not in ('REJECTED')
     order by pr.daytime desc;

BEGIN

   lr_result := ec_ptst_result.row_by_pk(p_result_no);

   -- Lock test
   EcDp_month_lock.AddParameterToList(n_lock_columns,'CLASS_NAME','PROD_TEST_RESULT','STRING',NULL,NULL,NULL);
   EcDp_month_lock.AddParameterToList(n_lock_columns,'TABLE_NAME','PTST_RESULT','STRING',NULL,NULL,NULL);
   EcDp_month_lock.AddParameterToList(n_lock_columns,'RESULT_NO','RESULT_NO','NUMBER','Y','N',anydata.ConvertNumber(lr_result.RESULT_NO));
   EcDp_month_lock.AddParameterToList(n_lock_columns,'VALID_FROM_DATE','VALID_FROM_DATE','DATE','N','N',anydata.Convertdate(lr_result.VALID_FROM_DATE));
   EcDp_month_lock.AddParameterToList(n_lock_columns,'STATUS','STATUS','STRING','N','N',anydata.ConvertVarChar2(lr_result.STATUS));

  ld_min_daytime := Ecdp_Performance_Test.getTrendSegmentMinDate(p_object_id, p_focus_date);
  ld_max_daytime := Ecdp_Performance_Test.getTrendSegmentMaxDate(p_object_id, p_focus_date);

  FOR min_2_cur in min_daytime_2_cur LOOP
      ld_min_daytime_2 := min_2_cur.min_daytime_2;
  end loop;


  ln_row_count := Ecdp_Well_Test_Curve.trendSegmentRowCount(p_object_id, p_from_daytime, ld_next_daytime, ld_min_daytime, ld_max_daytime);

   If ln_row_count < 2 then
      RAISE_APPLICATION_ERROR(-20200, 'Too few distint data points to analyze of draw trend.');
   end if;

   -- checking for trend-curve availability
   ln_trend_curve_count := Ecdp_Well_Test_Curve.trendCurveRowCount(p_object_id, p_focus_date, p_from_daytime, ld_next_daytime);
   IF ln_trend_curve_count = 0 THEN
     -- if none, copy from recent trend-curve
     Ecdp_Well_Test_Curve.copyTrendSegment(p_object_id, p_focus_date, p_from_daytime, ld_next_daytime, p_user);
   END IF;

  FOR my_cur in RatePoints_cur(ld_min_daytime, ld_min_daytime_2, ld_max_daytime, p_object_id) LOOP
    i:=i+1;

    IF lv_trend_src IS NOT NULL THEN
      lv_trend_src := lv_trend_src || ', ';
    END IF;
    lv_trend_src := lv_trend_src || to_char(my_cur.result_no);

    If my_cur.oil_y = 0 then
         lv2_oil_status := 'ZERO_EXIST';
    else
         oilRatePoints(i).y := ln(my_cur.oil_y);
         oilRatePoints(i).x := my_cur.x;
    end if;

    If my_cur.gas_y = 0 then
         lv2_gas_status := 'ZERO_EXIST';
    else
         gasRatePoints(i).y:= ln(my_cur.gas_y);
         gasRatePoints(i).x:= my_cur.x;
    end if;

    If my_cur.cond_y = 0 then
         lv2_cond_status := 'ZERO_EXIST';
    else
         condRatePoints(i).y:= ln(my_cur.cond_y);
         condRatePoints(i).x:= my_cur.x;
    end if;

    If my_cur.wat_y = 0 then
         lv2_wat_status := 'ZERO_EXIST';
    else
         watRatePoints(i).y:= ln(my_cur.wat_y);
         watRatePoints(i).x:= my_cur.x;
    end if;

    If my_cur.gor_y = 0 then
         lv2_gor_status := 'ZERO_EXIST';
    else
         gorRatePoints(i).y:= ln(my_cur.gor_y);
         gorRatePoints(i).x:= my_cur.x;
    end if;

    If my_cur.watercut_y = 0 then
         lv2_watcut_status := 'ZERO_EXIST';
    else
         watercutRatePoints(i).y:= ln(my_cur.watercut_y);
         watercutRatePoints(i).x:= my_cur.x;
    end if;

    If my_cur.cgr_y = 0 then
         lv2_cgr_status := 'ZERO_EXIST';
    else
         cgrRatePoints(i).y:= ln(my_cur.cgr_y);
         cgrRatePoints(i).x:= my_cur.x;
    end if;

    If my_cur.wgr_y = 0 then
         lv2_wgr_status := 'ZERO_EXIST';
    else
         wgrRatePoints(i).y:= ln(my_cur.wgr_y);
         wgrRatePoints(i).x:= my_cur.x;
    end if;

    If (nvl(my_cur.oil_y, my_cur.cond_y) + nvl(my_cur.wat_y, 0)) = 0 then
         lv2_liq_status := 'ZERO_EXIST';
    else
         liqRatePoints(i).y:= ln(nvl(my_cur.oil_y, my_cur.cond_y) + nvl(my_cur.wat_y, 0));
         liqRatePoints(i).x:= my_cur.x;
    end if;
-- New attributes
	If my_cur.whp_y = 0 then
         lv2_whp_status := 'ZERO_EXIST';
    else
         siWhpRatePoints(i).y:= ln(my_cur.whp_y);
         siWhpRatePoints(i).x:= my_cur.x;
    end if;

	If my_cur.bhp_y = 0 then
         lv2_whp_status := 'ZERO_EXIST';
    else
         siBhpPoints(i).y:= ln(my_cur.bhp_y);
         siBhpPoints(i).x:= my_cur.x;
    end if;

  end loop;

  -- trend segment start date
  ld_trend_start := Ecdp_Well_Test_Curve.getTrendSegmentStartDaytime(p_object_id, p_focus_date, p_from_daytime, ld_next_daytime);

  FOR c_trend_curve IN trendCurve_cur(ld_trend_start) LOOP

    CASE c_trend_curve.trend_method

      WHEN 'EXP' THEN

        CASE c_trend_curve.trend_parameter
          WHEN 'NET_OIL_RATE_ADJ' THEN
            --OIL
            IF lv2_oil_status = 'NO_ZERO' THEN
              EcBp_Mathlib.calcLinearRegression(oilRatePoints, ln_slope ,ln_y_intersect);
              ln_tempValue := (POWER(2.71828, ln_slope)) - 1;
              ln_C0 := POWER(2.71828, ln_y_intersect);
              ln_C1 := 100*ln_tempValue;
              Ecbp_Mathlib.calcCorrelationCoefficient(oilRatePoints,ln_r);
              ln_R2 := POWER(ln_r, 2);

            ELSIF lv2_oil_status = 'ZERO_EXIST' THEN
              ln_C0 := 0;
              ln_C1 := 0;

            END IF;

          WHEN 'GAS_RATE_ADJ' THEN
            --GAS
            IF lv2_gas_status = 'NO_ZERO' THEN
              EcBp_Mathlib.calcLinearRegression(gasRatePoints, ln_slope ,ln_y_intersect);
              ln_tempValue := (POWER(2.71828, ln_slope)) - 1;
              ln_C0 := POWER(2.71828, ln_y_intersect);
              ln_C1 := 100*ln_tempValue;
              Ecbp_Mathlib.calcCorrelationCoefficient(gasRatePoints,ln_r);
              ln_R2 := POWER(ln_r, 2);

            ELSIF lv2_gas_status = 'ZERO_EXIST' THEN
              ln_C0 := 0;
              ln_C1 := 0;

            END IF;

          WHEN 'NET_COND_RATE_ADJ' THEN
            --COND
            IF lv2_cond_status = 'NO_ZERO' THEN
              EcBp_Mathlib.calcLinearRegression(condRatePoints, ln_slope ,ln_y_intersect);
              ln_tempValue := (POWER(2.71828, ln_slope)) - 1;
              ln_C0 := POWER(2.71828, ln_y_intersect);
              ln_C1 := 100*ln_tempValue;
              Ecbp_Mathlib.calcCorrelationCoefficient(condRatePoints,ln_r);
              ln_R2 := POWER(ln_r, 2);

            ELSIF lv2_cond_status = 'ZERO_EXIST' THEN
              ln_C0 := 0;
              ln_C1 := 0;

            END IF;

          WHEN 'TOT_WATER_RATE_ADJ' THEN
            --WATER
            IF lv2_wat_status = 'NO_ZERO' THEN
              EcBp_Mathlib.calcLinearRegression(watRatePoints, ln_slope ,ln_y_intersect);
              ln_tempValue := (POWER(2.71828, ln_slope)) - 1;
              ln_C0 := POWER(2.71828, ln_y_intersect);
              ln_C1 := 100*ln_tempValue;
              Ecbp_Mathlib.calcCorrelationCoefficient(watRatePoints,ln_r);
              ln_R2 := POWER(ln_r, 2);

            ELSIF lv2_wat_status = 'ZERO_EXIST' THEN
              ln_C0 := 0;
              ln_C1 := 0;

            END IF;

          WHEN 'GOR' THEN
            --GOR
            IF lv2_gor_status = 'NO_ZERO' THEN
              EcBp_Mathlib.calcLinearRegression(gorRatePoints, ln_slope ,ln_y_intersect);
              ln_tempValue := (POWER(2.71828, ln_slope)) - 1;
              ln_C0 := POWER(2.71828, ln_y_intersect);
              ln_C1 := 100*ln_tempValue;
              Ecbp_Mathlib.calcCorrelationCoefficient(gorRatePoints,ln_r);
              ln_R2 := POWER(ln_r, 2);

            ELSIF lv2_gor_status = 'ZERO_EXIST' THEN
              ln_C0 := 0;
              ln_C1 := 0;

            END IF;

          WHEN 'WATERCUT_PCT' THEN
            --WATERCUT
            IF lv2_watcut_status = 'NO_ZERO' THEN
              EcBp_Mathlib.calcLinearRegression(watercutRatePoints, ln_slope ,ln_y_intersect);
              ln_tempValue := (POWER(2.71828, ln_slope)) - 1;
              ln_C0 := POWER(2.71828, ln_y_intersect);
              ln_C1 := 100*ln_tempValue;
              Ecbp_Mathlib.calcCorrelationCoefficient(watercutRatePoints,ln_r);
              ln_R2 := POWER(ln_r, 2);

            ELSIF lv2_watcut_status = 'ZERO_EXIST' THEN
              ln_C0 := 0;
              ln_C1 := 0;

            END IF;

          WHEN 'CGR' THEN
            --CGR
            IF lv2_cgr_status = 'NO_ZERO' THEN
              EcBp_Mathlib.calcLinearRegression(cgrRatePoints, ln_slope ,ln_y_intersect);
              ln_tempValue := (POWER(2.71828, 30*ln_slope)) - 1;
              ln_C0 := POWER(2.71828, ln_y_intersect);
              ln_C1 := 100*ln_tempValue;
              Ecbp_Mathlib.calcCorrelationCoefficient(cgrRatePoints,ln_r);
              ln_R2 := POWER(ln_r, 2);

            ELSIF lv2_cgr_status = 'ZERO_EXIST' THEN
              ln_C0 := 0;
              ln_C1 := 0;

            END IF;

          WHEN 'WGR' THEN
            --WGR
            IF lv2_wgr_status = 'NO_ZERO' THEN
              EcBp_Mathlib.calcLinearRegression(wgrRatePoints, ln_slope ,ln_y_intersect);
              ln_tempValue := (POWER(2.71828, ln_slope)) - 1;
              ln_C0 := POWER(2.71828, ln_y_intersect);
              ln_C1 := 100*ln_tempValue;
              Ecbp_Mathlib.calcCorrelationCoefficient(wgrRatePoints,ln_r);
              ln_R2 := POWER(ln_r, 2);

            ELSIF lv2_wgr_status = 'ZERO_EXIST' THEN
              ln_C0 := 0;
              ln_C1 := 0;

            END IF;

          WHEN 'LIQUID_RATE_ADJ' THEN
            --LIQUID_RATE
            IF lv2_liq_status = 'NO_ZERO' THEN
              EcBp_Mathlib.calcLinearRegression(liqRatePoints, ln_slope ,ln_y_intersect);
              ln_tempValue := (POWER(2.71828, ln_slope)) - 1;
              ln_C0 := POWER(2.71828, ln_y_intersect);
              ln_C1 := 100*ln_tempValue;
              Ecbp_Mathlib.calcCorrelationCoefficient(liqRatePoints,ln_r);
              ln_R2 := POWER(ln_r, 2);

            ELSIF lv2_liq_status = 'ZERO_EXIST' THEN
              ln_C0 := 0;
              ln_C1 := 0;

            END IF;

			WHEN 'SI_WHP' THEN
            --SI_WHP
            IF lv2_whp_status = 'NO_ZERO' THEN
              EcBp_Mathlib.calcLinearRegression(siWhpRatePoints, ln_slope ,ln_y_intersect);
              ln_tempValue := (POWER(2.71828, ln_slope)) - 1;
              ln_C0 := POWER(2.71828, ln_y_intersect);
              ln_C1 := 100*ln_tempValue;
              Ecbp_Mathlib.calcCorrelationCoefficient(siWhpRatePoints,ln_r);
              ln_R2 := POWER(ln_r, 2);

            ELSIF lv2_liq_status = 'ZERO_EXIST' THEN
              ln_C0 := 0;
              ln_C1 := 0;

            END IF;

			WHEN 'si_bhp' THEN
            --si_bhp
            IF lv2_whp_status = 'NO_ZERO' THEN
              EcBp_Mathlib.calcLinearRegression(siWhpRatePoints, ln_slope ,ln_y_intersect);
              ln_tempValue := (POWER(2.71828, ln_slope)) - 1;
              ln_C0 := POWER(2.71828, ln_y_intersect);
              ln_C1 := 100*ln_tempValue;
              Ecbp_Mathlib.calcCorrelationCoefficient(siWhpRatePoints,ln_r);
              ln_R2 := POWER(ln_r, 2);

            ELSIF lv2_liq_status = 'ZERO_EXIST' THEN
              ln_C0 := 0;
              ln_C1 := 0;

            END IF;

        END CASE;


      WHEN 'LINEAR' THEN

        CASE c_trend_curve.trend_parameter

          WHEN 'NET_OIL_RATE_ADJ' THEN
            --OIL
            IF lv2_oil_status = 'NO_ZERO' THEN
              oilRatePoints := convertLnToExp(oilRatePoints);
              EcBp_Mathlib.calcLinearRegression(oilRatePoints, ln_slope ,ln_y_intersect);
              ln_C0 := ln_y_intersect;
              ln_C1 := ln_slope;
              Ecbp_Mathlib.calcCorrelationCoefficient(oilRatePoints,ln_r);
              ln_R2 := POWER(ln_r, 2);

            ELSIF lv2_oil_status = 'ZERO_EXIST' THEN
              ln_C0 := 0;
              ln_C1 := 0;
              ln_R2 := 0;
            END IF;

          WHEN 'GAS_RATE_ADJ' THEN
            --GAS
            IF lv2_gas_status = 'NO_ZERO' THEN
              gasRatePoints := convertLnToExp(gasRatePoints);
              EcBp_Mathlib.calcLinearRegression(gasRatePoints, ln_slope ,ln_y_intersect);
              ln_C0 := ln_y_intersect;
              ln_C1 := ln_slope;
              Ecbp_Mathlib.calcCorrelationCoefficient(gasRatePoints,ln_r);
              ln_R2 := POWER(ln_r, 2);

            ELSIF lv2_gas_status = 'ZERO_EXIST' THEN
              ln_C0 := 0;
              ln_C1 := 0;
              ln_R2 := 0;
            END IF;

          WHEN 'NET_COND_RATE_ADJ' THEN
            --COND
            IF lv2_cond_status = 'NO_ZERO' THEN
              condRatePoints := convertLnToExp(condRatePoints);
              EcBp_Mathlib.calcLinearRegression(condRatePoints, ln_slope ,ln_y_intersect);
              ln_C0 := ln_y_intersect;
              ln_C1 := ln_slope;
              Ecbp_Mathlib.calcCorrelationCoefficient(condRatePoints,ln_r);
              ln_R2 := POWER(ln_r, 2);

            ELSIF lv2_cond_status = 'ZERO_EXIST' THEN
              ln_C0 := 0;
              ln_C1 := 0;
              ln_R2 := 0;
            END IF;

          WHEN 'TOT_WATER_RATE_ADJ' THEN
            --WATER
            IF lv2_wat_status = 'NO_ZERO' THEN
              watRatePoints := convertLnToExp(watRatePoints);
              EcBp_Mathlib.calcLinearRegression(watRatePoints, ln_slope ,ln_y_intersect);
              ln_C0 := ln_y_intersect;
              ln_C1 := ln_slope;
              Ecbp_Mathlib.calcCorrelationCoefficient(watRatePoints,ln_r);
              ln_R2 := POWER(ln_r, 2);

            ELSIF lv2_wat_status = 'ZERO_EXIST' THEN
              ln_C0 := 0;
              ln_C1 := 0;
              ln_R2 := 0;
            END IF;

          WHEN 'GOR' THEN
            --GOR
            IF lv2_gor_status = 'NO_ZERO' THEN
              gorRatePoints := convertLnToExp(gorRatePoints);
              EcBp_Mathlib.calcLinearRegression(gorRatePoints, ln_slope ,ln_y_intersect);
              ln_C0 := ln_y_intersect;
              ln_C1 := ln_slope;
              Ecbp_Mathlib.calcCorrelationCoefficient(gorRatePoints,ln_r);
              ln_R2 := POWER(ln_r, 2);

            ELSIF lv2_gor_status = 'ZERO_EXIST' THEN
              ln_C0 := 0;
              ln_C1 := 0;
              ln_R2 := 0;
            END IF;

          WHEN 'WATERCUT_PCT' THEN
            --WATERCUT
            IF lv2_watcut_status = 'NO_ZERO' THEN
              watercutRatePoints := convertLnToExp(watercutRatePoints);
              EcBp_Mathlib.calcLinearRegression(watercutRatePoints, ln_slope ,ln_y_intersect);
              ln_C0 := ln_y_intersect;
              ln_C1 := ln_slope;
              Ecbp_Mathlib.calcCorrelationCoefficient(watercutRatePoints,ln_r);
              ln_R2 := POWER(ln_r, 2);

            ELSIF lv2_watcut_status = 'ZERO_EXIST' THEN
              ln_C0 := 0;
              ln_C1 := 0;
              ln_R2 := 0;
            END IF;

          WHEN 'CGR' THEN
            --CGR
            IF lv2_cgr_status = 'NO_ZERO' THEN
              cgrRatePoints := convertLnToExp(cgrRatePoints);
              EcBp_Mathlib.calcLinearRegression(cgrRatePoints, ln_slope ,ln_y_intersect);
              ln_C0 := ln_y_intersect;
              ln_C1 := ln_slope;
              Ecbp_Mathlib.calcCorrelationCoefficient(cgrRatePoints,ln_r);
              ln_R2 := POWER(ln_r, 2);

            ELSIF lv2_cgr_status = 'ZERO_EXIST' THEN
              ln_C0 := 0;
              ln_C1 := 0;
              ln_R2 := 0;
            END IF;

          WHEN 'WGR' THEN
            --WGR
            IF lv2_wgr_status = 'NO_ZERO' THEN
              wgrRatePoints := convertLnToExp(wgrRatePoints);
              EcBp_Mathlib.calcLinearRegression(wgrRatePoints, ln_slope ,ln_y_intersect);
              ln_C0 := ln_y_intersect;
              ln_C1 := ln_slope;
              Ecbp_Mathlib.calcCorrelationCoefficient(wgrRatePoints,ln_r);
              ln_R2 := POWER(ln_r, 2);

            ELSIF lv2_wgr_status = 'ZERO_EXIST' THEN
              ln_C0 := 0;
              ln_C1 := 0;
              ln_R2 := 0;
            END IF;

          WHEN 'LIQUID_RATE_ADJ' THEN
            --LIQUID_RATE
            IF lv2_liq_status = 'NO_ZERO' THEN
              liqRatePoints := convertLnToExp(liqRatePoints);
              EcBp_Mathlib.calcLinearRegression(liqRatePoints, ln_slope ,ln_y_intersect);
              ln_C0 := ln_y_intersect;
              ln_C1 := ln_slope;
              Ecbp_Mathlib.calcCorrelationCoefficient(liqRatePoints,ln_r);
              ln_R2 := POWER(ln_r, 2);

            ELSIF lv2_liq_status = 'ZERO_EXIST' THEN
              ln_C0 := 0;
              ln_C1 := 0;
              ln_R2 := 0;
            END IF;

			WHEN 'SI_WHP' THEN
            --SI_WHP
            IF lv2_whp_status = 'NO_ZERO' THEN
              siWhpRatePoints := convertLnToExp(siWhpRatePoints);
              EcBp_Mathlib.calcLinearRegression(siWhpRatePoints, ln_slope ,ln_y_intersect);
              ln_C0 := ln_y_intersect;
              ln_C1 := ln_slope;
              Ecbp_Mathlib.calcCorrelationCoefficient(siWhpRatePoints,ln_r);
              ln_R2 := POWER(ln_r, 2);

            ELSIF lv2_whp_status = 'ZERO_EXIST' THEN
              ln_C0 := 0;
              ln_C1 := 0;
              ln_R2 := 0;
            END IF;

			WHEN 'SI_BHP' THEN
            --SI_BHP
            IF lv2_whp_status = 'NO_ZERO' THEN
              siWhpRatePoints := convertLnToExp(siWhpRatePoints);
              EcBp_Mathlib.calcLinearRegression(siWhpRatePoints, ln_slope ,ln_y_intersect);
              ln_C0 := ln_y_intersect;
              ln_C1 := ln_slope;
              Ecbp_Mathlib.calcCorrelationCoefficient(siWhpRatePoints,ln_r);
              ln_R2 := POWER(ln_r, 2);

            ELSIF lv2_whp_status = 'ZERO_EXIST' THEN
              ln_C0 := 0;
              ln_C1 := 0;
              ln_R2 := 0;
            END IF;
        END CASE;

      WHEN 'ACTUAL' THEN
              ln_C0 := c_trend_curve.C0;
              ln_C1 := c_trend_curve.C1;
              ln_R2 := 0;


    END CASE;

    UPDATE trend_curve tc
      SET tc.c0=ln_C0,
          tc.c1=ln_C1,
          tc.r_squared=ln_R2,
          tc.trend_source=lv_trend_src,
          tc.last_updated_by=p_user,
          tc.last_updated_date=Ecdp_Timestamp.getCurrentSysdate
    WHERE tc.object_id = p_object_id
    AND tc.daytime = ld_trend_start
    AND tc.trend_segment_no = c_trend_curve.trend_segment_no;

  END LOOP;

END analyzeTrend;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getYfromX
-- Description    : Calculates y from a given x based on formula type and coefficients/points
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Calculates y from the given x
--
--
--
--
--
---------------------------------------------------------------------------------------------------
FUNCTION getYfromX(p_x_value NUMBER, p_c0 NUMBER, p_c1 NUMBER, p_trend_method VARCHAR2) RETURN NUMBER
--</EC-DOC>
IS
   ln_temp NUMBER;
   ln_time NUMBER;
   ln_retVal NUMBER;

BEGIN
   IF p_x_value IS NULL THEN
      RETURN NULL;
   END IF;

   IF p_trend_method = 'EXP' THEN
     ln_temp := 1 + (p_c1 / 100);
     ln_time := p_x_value; -- / 30;

     ln_retVal := p_c0 * power(ln_temp, ln_time);

   ELSIF p_trend_method = 'LINEAR' THEN
     ln_time := p_x_value;
     ln_temp := p_c1 * ln_time;

     ln_retVal := p_c0 + ln_temp;
   END IF;

   return ln_retVal;

END getYfromX;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : trendSegmentRowCount
-- Description    : Calculate the number of test results selected for a segment, if its less than 2 then
--                  it should raise an error. It will not be allowed to analyze of draw the trend.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION trendSegmentRowCount(p_object_id VARCHAR2, p_from_daytime DATE, p_to_daytime DATE, p_min_daytime DATE, p_max_daytime DATE)
RETURN NUMBER

IS

   ln_row_count NUMBER;

   CURSOR trend_segment_row_count_cur IS
      select COUNT(pwel_result.result_no) as row_count
	           from pwel_result, ptst_result
             where pwel_result.result_no = ptst_result.result_no
	           and pwel_result.OBJECT_ID = p_object_id
	           AND ptst_result.DAYTIME >= NVL(P_min_daytime, p_from_daytime)
	           AND ptst_result.DAYTIME < NVL(P_max_daytime, p_to_daytime)
             AND ptst_result.DAYTIME between p_from_daytime and p_to_daytime
             order by ptst_result.DAYTIME DESC;

BEGIN

   FOR my_cur in trend_segment_row_count_cur LOOP
       ln_row_count := my_cur.row_count;
	 end loop;

   RETURN ln_row_count;

END trendSegmentRowCount;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : trendSegmentRowCountCheck
-- Description    : Check if the row count is less than 2, if its less than 2 raise an application error
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE trendSegmentRowCountCheck(p_object_id VARCHAR2, p_focus_date DATE, p_from_daytime DATE, p_to_daytime DATE)
--</EC-DOC>
IS
   ln_row_count NUMBER;
   ld_min_daytime DATE;
   ld_max_daytime DATE;


BEGIN

  ld_min_daytime := Ecdp_Performance_Test.getTrendSegmentMinDate(p_object_id, p_focus_date);
  ld_max_daytime := Ecdp_Performance_Test.getTrendSegmentMaxDate(p_object_id, p_focus_date);
  ln_row_count := Ecdp_Well_Test_Curve.trendSegmentRowCount(p_object_id, p_from_daytime, p_to_daytime, ld_min_daytime, ld_max_daytime);

   If ln_row_count < 2 then
      RAISE_APPLICATION_ERROR(-20200, 'Too few distint data points to analyze of draw trend.');
   end if;

END trendSegmentRowCountCheck;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTrendSegmentStartDaytime
-- Description    : Get the trend start-date. If no record has RESET_IND=Y, return last segment row's date.
--                  If still null, return the focused date.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PWEL_RESULT, PTST_RESULT
-- Using functions: Ecdp_Performance_Test.getTrendSegmentMinDate, Ecdp_Performance_Test.getTrendSegmentMaxDate
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTrendSegmentStartDaytime(p_object_id VARCHAR2, p_focus_date DATE, p_from_daytime DATE, p_to_daytime DATE)
RETURN DATE
--</EC-DOC>
IS
  ld_min_daytime DATE;
  ld_max_daytime DATE;
  ld_trend_start_date DATE;

  CURSOR trend_segment_start(cp_min_daytime DATE, cp_max_daytime DATE) IS
    SELECT min(pwel_result.daytime) trend_start
    FROM pwel_result, ptst_result
    WHERE pwel_result.result_no = ptst_result.result_no
    AND pwel_result.primary_ind='Y'
    AND pwel_result.OBJECT_ID = p_object_id
    AND pwel_result.trend_analysis_ind = 'Y'
    AND pwel_result.trend_reset_ind = 'Y'
    AND ptst_result.DAYTIME >= NVL(cp_min_daytime, p_from_daytime)
    AND ptst_result.DAYTIME < NVL(cp_max_daytime, p_to_daytime)
    AND ptst_result.DAYTIME between p_from_daytime and p_to_daytime
    ORDER BY ptst_result.DAYTIME DESC;

BEGIN
  ld_min_daytime := Ecdp_Performance_Test.getTrendSegmentMinDate(p_object_id, p_focus_date);
  ld_max_daytime := Ecdp_Performance_Test.getTrendSegmentMaxDate(p_object_id, p_focus_date);

  FOR c_trend IN trend_segment_start(ld_min_daytime,ld_max_daytime) LOOP
    ld_trend_start_date := nvl(c_trend.trend_start,ld_min_daytime);
  END LOOP;

  IF ld_trend_start_date IS NULL THEN
    -- if no actual trend-start and no min-date
    -- return focused-row's date
    RETURN p_focus_date;
  END IF;

  RETURN ld_trend_start_date;

END getTrendSegmentStartDaytime;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : trendCurveRowCount
-- Description    : Calculate the number of trend curve record for the focused trend-segment
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION trendCurveRowCount(p_object_id VARCHAR2, p_focus_date DATE, p_from_daytime DATE, p_to_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

   ln_row_count   NUMBER;
   ld_trend_start DATE;

   CURSOR trend_curve_row_count_cur(cp_trendStartDate DATE) IS
     SELECT count(*) as row_count
     FROM trend_curve
     WHERE trend_curve.object_id = p_object_id
     AND trend_curve.daytime = cp_trendStartDate;

BEGIN

   ld_trend_start := getTrendSegmentStartDaytime(p_object_id,p_focus_date,p_from_daytime,p_to_daytime);

   FOR my_cur in trend_curve_row_count_cur(ld_trend_start) LOOP
       ln_row_count := my_cur.row_count;
	 END LOOP;

   RETURN ln_row_count;

END trendCurveRowCount;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : copyTrendSegment
-- Description    : Copy trend-curve of previous trend-segment into current trend-segment.Copy only
--                  OBJECT_ID, TREND_PARAMETER, TREND_METHOD, HIGHLOW_BAND,etc.
--                  Except: C0 and C1
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE copyTrendSegment(p_object_id VARCHAR2, p_focus_date DATE, p_from_daytime DATE, p_to_daytime DATE, p_user VARCHAR2)
--</EC-DOC>
IS
  TYPE t_trend_curve IS TABLE OF trend_curve%ROWTYPE;
  l_trend_curve  t_trend_curve;
  ld_trend_start DATE;

  CURSOR prev_trend_curve_cur(cp_trend_start DATE) IS
    SELECT *
    FROM trend_curve
    WHERE trend_curve.object_id = p_object_id
    AND trend_curve.daytime = (SELECT MAX(daytime) FROM trend_curve tc WHERE tc.daytime < cp_trend_start);

BEGIN

  ld_trend_start := getTrendSegmentStartDaytime(p_object_id, p_focus_date, p_from_daytime, p_to_daytime);

  IF ld_trend_start IS NOT NULL THEN
    OPEN prev_trend_curve_cur(ld_trend_start);
      LOOP
        FETCH prev_trend_curve_cur BULK COLLECT INTO l_trend_curve LIMIT 100;

        FOR i IN 1..l_trend_curve.COUNT LOOP
          -- set to NULL to allow generation of sequence by IU trigger
          l_trend_curve(i).trend_segment_no := null;
          -- set coefficients to NULL, else direct copy
          l_trend_curve(i).c0 := NULL;
          l_trend_curve(i).c1 := NULL;
          l_trend_curve(i).r_squared := null;
          l_trend_curve(i).trend_source := null;
          -- this trend-curve belongs to current trend-segment
          l_trend_curve(i).daytime := ld_trend_start;
          l_trend_curve(i).last_updated_by := p_user;
          l_trend_curve(i).last_updated_date := Ecdp_Timestamp.getCurrentSysdate;
        END LOOP;

        FORALL i IN 1..l_trend_curve.COUNT
          INSERT INTO trend_curve VALUES l_trend_curve(i);

        EXIT WHEN prev_trend_curve_cur%NOTFOUND;

      END LOOP;

    CLOSE prev_trend_curve_cur;
  END IF;

END copyTrendSegment;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : convertLnToExp
-- Description    : Convert number that has been ln() to exp()
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION convertLnToExp(p_point_list Ecbp_Mathlib.Ec_discrete_func_type)
RETURN Ecbp_Mathlib.Ec_discrete_func_type
--</EC-DOC>
IS
  lt_point_list  Ecbp_Mathlib.Ec_discrete_func_type;
  ln_point_count NUMBER := 0;
  i              BINARY_INTEGER := 0;
  j              NUMBER:=0;

BEGIN
  ln_point_count := p_point_list.count;
  lt_point_list := p_point_list;

  FOR i IN 1..ln_point_count LOOP
    j := j+1;
    lt_point_list(j).y := exp(p_point_list(i).y);
  END LOOP;

  RETURN lt_point_list;

END convertLnToExp;


---------------------------------------------------------------------------------------------------
-- Procedure      : acceptTestResult
-- Description    : This procedure updates status on test result to be ACCEPTED and record status = Approved
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PTST_RESULT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE acceptTestResult (p_result_no NUMBER, p_user VARCHAR2)
IS
  ld_last_updated_date DATE;
	lv2_addon_rev_text VARCHAR2(100);
	lv2_ptst_use_calc ptst_result.use_calc%TYPE;
	lv2_pwel_use_calc pwel_result.use_calc%TYPE;

  CURSOR c_ptst_result(cp_result_no NUMBER) IS
  SELECT use_calc FROM ptst_result WHERE result_no=cp_result_no;

  CURSOR c_pwel_result(cp_result_no NUMBER) IS
  SELECT use_calc FROM pwel_result WHERE result_no=cp_result_no;

BEGIN
  ld_last_updated_date := Ecdp_Timestamp.getCurrentSysdate;
	lv2_addon_rev_text := ' performed at PT.0012.';

	FOR curRow_ptst_result IN c_ptst_result(p_result_no) LOOP
	  lv2_ptst_use_calc := curRow_ptst_result.use_calc;
	END LOOP;

	FOR curRow_pwel_result IN c_pwel_result(p_result_no) LOOP
	  lv2_pwel_use_calc := curRow_pwel_result.use_calc;
	END LOOP;

	IF lv2_ptst_use_calc IS NULL THEN
		UPDATE ptst_result
		SET status = 'ACCEPTED', use_calc = 'N', record_status = 'A', trend_analysis_ind = 'Y', last_updated_by = p_user, last_updated_date = ld_last_updated_date,
				rev_no = rev_no + 1, rev_text = 'Accepted, No Alloc at ' || to_char(ld_last_updated_date, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
		WHERE result_no = p_result_no;
	ELSE
		UPDATE ptst_result
		SET status = 'ACCEPTED', record_status = 'A', trend_analysis_ind = 'Y', last_updated_by = p_user, last_updated_date = ld_last_updated_date,
				rev_no = rev_no + 1, rev_text = 'Accepted at ' || to_char(ld_last_updated_date, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
		WHERE result_no = p_result_no;
	END IF;

	IF lv2_pwel_use_calc IS NULL THEN
		UPDATE pwel_result
		SET status = 'ACCEPTED', use_calc = 'N', record_status = 'A', trend_analysis_ind = 'Y', last_updated_by = p_user, last_updated_date = ld_last_updated_date,
				rev_no = rev_no + 1, rev_text = 'Accepted, No Alloc at ' || to_char(ld_last_updated_date, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
		WHERE result_no = p_result_no;
	ELSE
		UPDATE pwel_result
		SET status = 'ACCEPTED', record_status = 'A', trend_analysis_ind = 'Y', last_updated_by = p_user, last_updated_date = ld_last_updated_date,
				rev_no = rev_no + 1, rev_text = 'Accepted at ' || to_char(ld_last_updated_date, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
		WHERE result_no = p_result_no;
  END IF;

	UPDATE test_device_result
	SET record_status = 'A', last_updated_by = p_user, last_updated_date = ld_last_updated_date,
			rev_no = rev_no + 1, rev_text = 'Accepted at ' || to_char(ld_last_updated_date, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
	WHERE result_no = p_result_no;

END acceptTestResult;

---------------------------------------------------------------------------------------------------
-- Procedure      : rejectTestResult
-- Description    : This procedure updates status on test result to be REJECTED and record status = Verified
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PTST_RESULT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE rejectTestResult (p_result_no NUMBER, p_user VARCHAR2)
IS
  ld_last_updated_date DATE;
	lv2_addon_rev_text VARCHAR2(100);

BEGIN
  ld_last_updated_date := Ecdp_Timestamp.getCurrentSysdate;
	lv2_addon_rev_text := ' performed at PT.0012.';

	UPDATE ptst_result
	SET status = 'REJECTED', use_calc = 'N', record_status = 'V', trend_analysis_ind = 'N', last_updated_by = p_user, last_updated_date = ld_last_updated_date,
			rev_no = rev_no + 1, rev_text = 'Rejected, at ' || to_char(ld_last_updated_date, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
	WHERE result_no = p_result_no;

	UPDATE pwel_result
	SET status = 'REJECTED', use_calc = 'N', record_status = 'V', trend_analysis_ind = 'N', last_updated_by = p_user, last_updated_date = ld_last_updated_date,
			rev_no = rev_no + 1, rev_text = 'Rejected, at ' || to_char(ld_last_updated_date, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
	WHERE result_no = p_result_no;

	UPDATE test_device_result
	SET record_status = 'V', last_updated_by = p_user, last_updated_date = ld_last_updated_date,
			rev_no = rev_no + 1, rev_text = 'Rejected, at ' || to_char(ld_last_updated_date, 'YYYY-MM-DD"T"HH24:MI:SS') || lv2_addon_rev_text
	WHERE result_no = p_result_no;

END rejectTestResult;

END EcDp_Well_Test_Curve;