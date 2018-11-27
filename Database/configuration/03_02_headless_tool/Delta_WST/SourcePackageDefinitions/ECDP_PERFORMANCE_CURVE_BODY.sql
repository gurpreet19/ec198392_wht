CREATE OR REPLACE PACKAGE BODY EcDp_Performance_Curve IS
/****************************************************************
** Package        :  EcDp_Performance_Curve, body part
**
** $Revision: 1.30 $
**
** Purpose        :  Provide service layer for Performace curves
**
** Documentation  :  www.energy-components.com
**
** Created  : 28.04.2000  Arild vervik
**
** Modification history:
**
** Date     	Whom  	Change description:
** --------   	----- 	---------------------------------------------------------------------
** 13.06.00 	AV    	Changed insertWellCurve and UpdateWellCurve
**            	        to find phase from p_y_axis_parameter,
**	       		        Overrules the phase given from well_type
** 07.07.00 	AV    	Added functions UpdateCurveSegment,
**	       		        insertCurvesegment and delete curvesegment
** 14.07.00   	        Added function segmentAutoGenerate
**            	        For auto generation of segments not to take place
**            	        Add a row in t_preferanse with pref_id = 'CURV_AUTSEGMENT'
**            	        and pref_verdi = 'N'
**            	        Introduced curve_parameter_axis as a new column in performance_curve
**            	        NB! Database change for this must be in place for this package to compile
** 10.08.00 	AV    	Extended insertCurvePoint to allow several X-axis
**            			for a performance curve. That means several
**            			physicla curves for one logical performance curve
**            			This also include the local functions addUpdateExtraXValue
**            			and addUpdatePerfCurveExtraXValue
** 16.08.00 	AV    	Added function insertFlowlineCurve
** 21.09.00 	CFS   	addUpdatePerfCurveExtraXValue: Added calls to addUpdateExtraXValue
**            			for ts_press, ss_press and ts_dsc_press.
** 23.09.00 	BF		Bug fix: addUpdatePerfCurveExtraXValue:
**	           			Replaced p_wh_press with p_ts_press, p_ss_press and p_ts_dsc_press
**	           			in the appropriate addUpdateExtraXValue calls (3 places).
** 25.09.00   �    	Bug fix in : addUpdatePerfCurveExtraXValue in-argument ln_curve_id in
**            	        ec_perf_curve_assignment.phase replaced with p_curve_id
** 27.09.00   PGI   	Inserted exception-handling removed from version 4.2.
** 03.10.00   DN    	3 new subprocedures to maintain well_perf_curve_table.
**            	        May soon be moved to lowest package level (ec-packages).
** 09.11.00   BF    	Added procedures: deleteFlowlineCurve, updateFlowlineCurve.
** 11.12.00   PGI   	Removed use of y_value in cursor c_curve_point in addUpdateExtraXValue.
**            			Changed implementation of deleteCurvePoint.
**            			Use getPointNo function instead of ec_... calls.
** 17.01.01   PGI   	Replaced function addUpdatePerfCurveExtraXValue
**                		with insert... and update... procedures.
**	               		Changed insertCurvePoint and updateCurvePoint to call the new procedures.
**	               		Changed addUpdateExtraXValue: FUNCTION -> PROCEDURE +
**	               		Updating point rows containing x-values like NULL are now deleted.
** 24.01.01   PGI   	Changes in addUpdateExtraXValue: When deleting last point from a curve
**                		delete the curve as well.
** 30.03.01   KEJ   	Documented functions and procedures.
** 13.03.02   PGI   	Added duplicate functionality in updateWellCurve and updateFlowlineCurve.
**
** 05.03.04   BIH   	! Cleared package !
**                      Added getWellPerformanceCurveId, getNextWellPerformanceCurveId,
**                      getStdRateFromParamValue and copyPerformanceCurve that supports new database model
**                      (from EnergyX 7.3)
**
** 23.04.04   DN    	Replaced ecDp_System_key.assignNextKeyValue with EcDp_System_Key.assignNextNumber.
** 10.06.05   ROV   	Tracker #2292:
**                 		Updated getStdRateFromParamValue to support p_phase = 'COND'.
**                 		Updated oil calculation from gas curve in getStdRateFromParamValue to use GOR instead of GCR
**                 		Removed calculation of oil from gas curve using GCR in getStdRateFromParamValue as this gives no sense
** 21.07.05   CHONGJER  Tracker #2442: Updated getStdRateFromParamValue to support theoretical oil from gas perf. curve
** 23.12.05   AV        Tracker 2288, Added new support function getPrevWellPerformanceCurveId
** 05.04.06   johanein  T#3668 Updated getStdRateFromParamValue in order to support LIQUID as curve output phase
** 24.08.06   MOT       Tracker #1597: Updated getStdRateFromParamValue to support GOR and other constants stored on
**                      curve points instead of common constants on performance curve
** 23.03.2010 musaamah  ECPD-13372: Modified functions getWellPerformanceCurveId, getNextWellPerformanceCurveId and getPrevWellPerformanceCurveId to access the latest
                        performance curve having status = ACCEPTED or IS NULL.
** 29-12-2010 Leongwen  ecpd-11637 Well Performance Curve should accept more than one curve pr Valid From date
** 28-01-2011 leongwen ECDP-16574: To correct and enhance the screens which are affected by the changes made in ECPD-16525.
** 08-06-2011 syazwnur ECPD-17576: Modified function getCurveIdPhase to handle for phase=GAS and purpose=GAS_LIFT.
** 05.07.2011 rajarsar ECPD-17700: Updated getCurveIdPhase, getWellPerformanceCurveId,getNextWellPerformanceCurveId,getPrevWellPerformanceCurveId and getCurveStdRate to add p_calc_method as passing parameter.
** 17-11-2011 leongwen ECPD-18170: Modified getCurveIdPhase() to check daily and subdaily methods, getWellPerformanceCurveId(), getPrevWellPerformanceCurveId() and getNextWellPerformanceCurveId() to check perf_curve_status='ACCEPTED'
** 19.01.2012 rajarsar ECPD-19447: Updated getCurveIdPhase,getWellPerformanceCurveId,getNextWellPerformanceCurveId,getPrevWellPerformanceCurveId and getStdRateFromParamValue.
** 20.02.2012 kumarsur ECPD-20098: Calc method code "CURVE" fails for all phases other than "OIL".
** 21.11.2012 limmmchu ECPD-21585: Modified getWellPerformanceCurveId, getNextWellPerformanceCurveId and getPrevWellPerformanceCurveId
** 17.12.2012 musthram ECPD-21528: Modified getCurveIdPhase
** 10.05.2013 wonggkai ECPD-23348: Modified getCurveIdPhase
** 14.04.2014 leongwen ECPD-22866: Modified getCurveIdPhase, getWellPerformanceCurveId, getNextWellPerformanceCurveId and getPrevWellPerformanceCurveId to include the same well curve logic for Flowline
** 27.02.2017 choooshu ECPD-32359: Modified copyPerformanceCurve to support POLYNOM_4.
** 03.08.2017 leongwen ECPD-46335: Added procedure perfCurveStatusUpdate to update the 'record status' of performance curve, curve and curve_point tables after changing the 'perf curve status' at performance curve.
*************************************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCurveIdPhase                                                          --
-- Description    :                                                                              --
--                                                                                               --
--                                                                                               --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getCurveIdPhase(
                        p_curve_object_id VARCHAR2,
                        p_daytime DATE,
                        p_curve_purpose VARCHAR2,
                        p_phase VARCHAR2,
                        p_calc_method VARCHAR2 DEFAULT NULL
) RETURN VARCHAR2
--</EC-DOC>
IS
   lv2_phase VARCHAR2(32);

BEGIN
   -- find out if we should access a performance curve directly for a given phase and purpose, or if we should only access based on purpose (e.g. get GAS from OIL Curve + GOR)

  IF ecdp_objects.GetObjClassName(p_curve_object_id) = 'WELL' THEN
    IF (p_phase=EcDp_Phase.OIL and p_curve_purpose=EcDp_Curve_Purpose.PRODUCTION) THEN
      IF ec_well_version.well_meter_freq(p_curve_object_id, p_daytime, '<=') IN ('YR', 'MTH', 'DAY') THEN
        IF nvl(p_calc_method,ec_well_version.calc_method(p_curve_object_id, p_daytime, '<=')) = EcDp_Calc_Method.CURVE THEN
          lv2_phase := EcDp_Phase.OIL;
        ELSE
          lv2_phase := NULL; -- is not supported, oil cannot be derived from a Gas or Water curve.
        END IF;
      ELSIF ec_well_version.well_meter_freq(p_curve_object_id, p_daytime, '<=') IN ('2H', '1H', '30M','15M','10M','5M', '1M') THEN
        IF nvl(p_calc_method,ec_well_version.calc_sub_day_method(p_curve_object_id, p_daytime, '<=')) = EcDp_Calc_Method.CURVE THEN
          lv2_phase := EcDp_Phase.OIL;
        ELSE
          lv2_phase := NULL; -- is not supported, oil cannot be derived from a Gas or Water curve.
        END IF;
      END IF;
    ELSIF (p_phase=EcDp_Phase.LIQUID and p_curve_purpose=EcDp_Curve_Purpose.PRODUCTION) THEN
      IF ec_well_version.well_meter_freq(p_curve_object_id, p_daytime, '<=') IN ('YR', 'MTH', 'DAY') THEN
        IF nvl(p_calc_method,ec_well_version.calc_method(p_curve_object_id, p_daytime, '<=')) = EcDp_Calc_Method.CURVE_LIQUID THEN
          lv2_phase := EcDp_Phase.LIQUID;
        ELSE
          lv2_phase := NULL; -- is not supported, oil cannot be derived from a Gas or Water curve.
        END IF;
      ELSIF ec_well_version.well_meter_freq(p_curve_object_id, p_daytime, '<=') IN ('2H', '1H', '30M','15M','10M','5M', '1M') THEN
        IF nvl(p_calc_method,ec_well_version.calc_sub_day_method(p_curve_object_id, p_daytime, '<=')) = EcDp_Calc_Method.CURVE_LIQUID THEN
          lv2_phase := EcDp_Phase.LIQUID;
        ELSE
          lv2_phase := NULL; -- is not supported, oil cannot be derived from a Gas or Water curve.
        END IF;
      END IF;
    ELSIF (p_phase=EcDp_Phase.GAS and p_curve_purpose=EcDp_Curve_Purpose.PRODUCTION) THEN
      IF ec_well_version.well_meter_freq(p_curve_object_id, p_daytime, '<=') IN ('YR', 'MTH', 'DAY') THEN
        IF nvl(p_calc_method,ec_well_version.calc_gas_method(p_curve_object_id, p_daytime, '<=')) = EcDp_Calc_Method.CURVE_GAS THEN
          lv2_phase := EcDp_Phase.GAS;
        ELSE
          lv2_phase := EcDp_Phase.OIL;
        END IF;
      ELSIF ec_well_version.well_meter_freq(p_curve_object_id, p_daytime, '<=') IN ('2H', '1H', '30M','15M','10M','5M', '1M') THEN
        IF nvl(p_calc_method,ec_well_version.calc_sub_day_gas_method(p_curve_object_id, p_daytime, '<=')) = EcDp_Calc_Method.CURVE_GAS THEN
          lv2_phase := EcDp_Phase.GAS;
        ELSE
          lv2_phase := EcDp_Phase.OIL;
        END IF;
      END IF;
    ELSIF (p_phase=EcDp_Phase.WATER and p_curve_purpose=EcDp_Curve_Purpose.PRODUCTION) THEN
      IF ec_well_version.well_meter_freq(p_curve_object_id, p_daytime, '<=') IN ('YR', 'MTH', 'DAY') THEN
        IF nvl(p_calc_method,ec_well_version.calc_water_method(p_curve_object_id, p_daytime, '<=')) = EcDp_Calc_Method.CURVE_WATER THEN
          lv2_phase := EcDp_Phase.WATER;
        -- getting water from GAS perf curve and WaterGasRatio method, therefore this is to access GAS perf curve.
        ELSIF nvl(p_calc_method,ec_well_version.calc_water_method(p_curve_object_id, p_daytime, '<=')) = EcDp_Calc_Method.GAS_WGR THEN
          lv2_phase := EcDp_Phase.GAS;
        ELSE
          lv2_phase := EcDp_Phase.OIL;
        END IF;
      ELSIF ec_well_version.well_meter_freq(p_curve_object_id, p_daytime, '<=') IN ('2H', '1H', '30M','15M','10M','5M', '1M') THEN
        IF nvl(p_calc_method,ec_well_version.calc_sub_day_water_method(p_curve_object_id, p_daytime, '<=')) = EcDp_Calc_Method.CURVE_WATER THEN
          lv2_phase := EcDp_Phase.WATER;
        -- getting water from GAS perf curve and WaterGasRatio method, therefore this is to access GAS perf curve.
        ELSIF nvl(p_calc_method,ec_well_version.calc_sub_day_water_method(p_curve_object_id, p_daytime, '<=')) = EcDp_Calc_Method.GAS_WGR THEN
          lv2_phase := EcDp_Phase.GAS;
        ELSE
          lv2_phase := EcDp_Phase.OIL;
        END IF;
      END IF;
    ELSIF (p_phase=EcDp_Phase.WATER and p_curve_purpose=EcDp_Curve_Purpose.INJECTION) THEN
      IF nvl(p_calc_method,ec_well_version.calc_water_inj_method(p_curve_object_id, p_daytime, '<=')) = EcDp_Calc_Method.CURVE THEN
        lv2_phase := EcDp_Phase.WATER;
      ELSE
        lv2_phase := NULL; -- is not supported, water injection cannot be derived from another phase.
      END IF;
    ELSIF (p_phase=EcDp_Phase.GAS and p_curve_purpose=EcDp_Curve_Purpose.INJECTION) THEN
       IF nvl(p_calc_method,ec_well_version.calc_inj_method(p_curve_object_id, p_daytime, '<=')) = EcDp_Calc_Method.CURVE THEN
        lv2_phase := EcDp_Phase.GAS;
      ELSE
        lv2_phase := NULL; -- is not supported, gas injection cannot be derived from another phase.
      END IF;
    ELSIF (p_phase=EcDp_Phase.GAS and p_curve_purpose=EcDp_Curve_Purpose.GAS_LIFT) THEN
      IF nvl(p_calc_method,ec_well_version.gas_lift_method(p_curve_object_id, p_daytime, '<=')) = EcDp_Calc_Method.CURVE THEN
        lv2_phase := EcDp_Phase.GAS;
      ELSE
        lv2_phase := NULL; -- is not supported
      END IF;
    ELSE
       lv2_phase := NULL;
    END IF;
  ELSIF ecdp_objects.GetObjClassName(p_curve_object_id) = 'FLOWLINE' THEN
    IF (p_phase=EcDp_Phase.OIL and p_curve_purpose=EcDp_Curve_Purpose.PRODUCTION) THEN
      IF ec_flwl_version.flwl_meter_freq(p_curve_object_id, p_daytime, '<=') IN ('YR', 'MTH', 'DAY') THEN
        IF nvl(p_calc_method,ec_flwl_version.flw_calc_oil_mtd(p_curve_object_id, p_daytime, '<=')) = EcDp_Calc_Method.CURVE THEN
          lv2_phase := EcDp_Phase.OIL;
        ELSE
          lv2_phase := NULL; -- is not supported, oil cannot be derived from a Gas or Water curve.
        END IF;
      ELSIF ec_flwl_version.flwl_meter_freq(p_curve_object_id, p_daytime, '<=') IN ('2H', '1H', '30M','15M','10M','5M', '1M') THEN
        IF nvl(p_calc_method,ec_flwl_version.flw_calc_sub_day_oil_mtd(p_curve_object_id, p_daytime, '<=')) = EcDp_Calc_Method.CURVE THEN
          lv2_phase := EcDp_Phase.OIL;
        ELSE
          lv2_phase := NULL; -- is not supported, oil cannot be derived from a Gas or Water curve.
        END IF;
      END IF;
    ELSIF (p_phase=EcDp_Phase.LIQUID and p_curve_purpose=EcDp_Curve_Purpose.PRODUCTION) THEN
      IF ec_flwl_version.flwl_meter_freq(p_curve_object_id, p_daytime, '<=') IN ('YR', 'MTH', 'DAY') THEN
        IF nvl(p_calc_method,ec_flwl_version.flw_calc_oil_mtd(p_curve_object_id, p_daytime, '<=')) = EcDp_Calc_Method.CURVE_LIQUID THEN
          lv2_phase := EcDp_Phase.LIQUID;
        ELSE
          lv2_phase := NULL; -- is not supported, oil cannot be derived from a Gas or Water curve.
        END IF;
      ELSIF ec_flwl_version.flwl_meter_freq(p_curve_object_id, p_daytime, '<=') IN ('2H', '1H', '30M','15M','10M','5M', '1M') THEN
        IF nvl(p_calc_method,ec_flwl_version.flw_calc_sub_day_oil_mtd(p_curve_object_id, p_daytime, '<=')) = EcDp_Calc_Method.CURVE_LIQUID THEN
          lv2_phase := EcDp_Phase.LIQUID;
        ELSE
          lv2_phase := NULL; -- is not supported, oil cannot be derived from a Gas or Water curve.
        END IF;
      END IF;
    ELSIF (p_phase=EcDp_Phase.GAS and p_curve_purpose=EcDp_Curve_Purpose.PRODUCTION) THEN
      IF ec_flwl_version.flwl_meter_freq(p_curve_object_id, p_daytime, '<=') IN ('YR', 'MTH', 'DAY') THEN
        IF nvl(p_calc_method,ec_flwl_version.flw_calc_gas_mtd(p_curve_object_id, p_daytime, '<=')) = EcDp_Calc_Method.CURVE_GAS THEN
          lv2_phase := EcDp_Phase.GAS;
        ELSE
          lv2_phase := EcDp_Phase.OIL;
        END IF;
      ELSIF ec_flwl_version.flwl_meter_freq(p_curve_object_id, p_daytime, '<=') IN ('2H', '1H', '30M','15M','10M','5M', '1M') THEN
        IF nvl(p_calc_method,ec_flwl_version.flw_calc_sub_day_gas_mtd(p_curve_object_id, p_daytime, '<=')) = EcDp_Calc_Method.CURVE_GAS THEN
          lv2_phase := EcDp_Phase.GAS;
        ELSE
          lv2_phase := EcDp_Phase.OIL;
        END IF;
      END IF;
    ELSIF (p_phase=EcDp_Phase.WATER and p_curve_purpose=EcDp_Curve_Purpose.PRODUCTION) THEN
      IF ec_flwl_version.flwl_meter_freq(p_curve_object_id, p_daytime, '<=') IN ('YR', 'MTH', 'DAY') THEN
        IF nvl(p_calc_method,ec_flwl_version.flw_calc_water_mtd(p_curve_object_id, p_daytime, '<=')) = EcDp_Calc_Method.CURVE_WATER THEN
          lv2_phase := EcDp_Phase.WATER;
        -- getting water from GAS perf curve and WaterGasRatio method, therefore this is to access GAS perf curve.
        ELSIF nvl(p_calc_method,ec_flwl_version.flw_calc_water_mtd(p_curve_object_id, p_daytime, '<=')) = EcDp_Calc_Method.GAS_WGR THEN
          lv2_phase := EcDp_Phase.GAS;
        ELSE
          lv2_phase := EcDp_Phase.OIL;
        END IF;
      ELSIF ec_flwl_version.flwl_meter_freq(p_curve_object_id, p_daytime, '<=') IN ('2H', '1H', '30M','15M','10M','5M', '1M') THEN
        IF nvl(p_calc_method,ec_flwl_version.flw_calc_sub_day_water_mtd(p_curve_object_id, p_daytime, '<=')) = EcDp_Calc_Method.CURVE_WATER THEN
          lv2_phase := EcDp_Phase.WATER;
        -- getting water from GAS perf curve and WaterGasRatio method, therefore this is to access GAS perf curve.
        ELSIF nvl(p_calc_method,ec_flwl_version.flw_calc_sub_day_water_mtd(p_curve_object_id, p_daytime, '<=')) = EcDp_Calc_Method.GAS_WGR THEN
          lv2_phase := EcDp_Phase.GAS;
        ELSE
          lv2_phase := EcDp_Phase.OIL;
        END IF;
      END IF;
	  ELSIF (p_phase=EcDp_Phase.WATER and p_curve_purpose=EcDp_Curve_Purpose.INJECTION) THEN
      IF nvl(p_calc_method,ec_flwl_version.flwl_wat_calc_inj_mtd(p_curve_object_id, p_daytime, '<=')) = EcDp_Calc_Method.CURVE THEN
        lv2_phase := EcDp_Phase.WATER;
      ELSE
        lv2_phase := NULL;
      END IF;
    ELSIF (p_phase=EcDp_Phase.GAS and p_curve_purpose=EcDp_Curve_Purpose.INJECTION) THEN
      IF nvl(p_calc_method,ec_flwl_version.flwl_gas_calc_inj_mtd(p_curve_object_id, p_daytime, '<=')) = EcDp_Calc_Method.CURVE THEN
         lv2_phase := EcDp_Phase.GAS;
      ELSE
        lv2_phase := NULL;
      END IF;
    ELSIF (p_phase=EcDp_Phase.GAS and p_curve_purpose=EcDp_Curve_Purpose.GAS_LIFT) THEN
      IF nvl(p_calc_method,ec_flwl_version.flwl_calc_gas_lift_mtd(p_curve_object_id, p_daytime, '<=')) = EcDp_Calc_Method.CURVE THEN
        lv2_phase := EcDp_Phase.GAS;
      ELSE
        lv2_phase := NULL; -- is not supported
      END IF;
    END IF;
  END IF;

  RETURN lv2_phase;

END getCurveIdPhase;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWellPerformanceCurveId                                                    --
-- Description    : Finds the newest valid performance curve for the given well, daytime and     --
--                  purpose.                                                                     --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : PERFORMANCE_CURVE                                                            --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      : Returns the performance curve with the given well and purpose that has       --
--                  the highest daytime <= the given daytime, or NULL if no such curve can       --
--                  be found.                                                                    --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getWellPerformanceCurveId(
                        p_curve_object_id VARCHAR2,
                        p_daytime DATE,
                        p_curve_purpose VARCHAR2,
                        p_phase VARCHAR2 DEFAULT NULL,
                        p_calc_method VARCHAR2 DEFAULT NULL
) RETURN NUMBER
--</EC-DOC>
IS
   l_id  performance_curve.perf_curve_id%TYPE;
   lv2_phase VARCHAR2(32);
   lv2_calc_method  VARCHAR2(32);

   CURSOR c_PerfCurveId IS
      SELECT pc.perf_curve_id FROM performance_curve pc
      WHERE pc.curve_object_id=p_curve_object_id AND pc.curve_purpose=p_curve_purpose
      AND (pc.perf_curve_status='ACCEPTED' OR pc.perf_curve_status IS NULL)
      AND pc.daytime=(
         SELECT MAX(pc2.daytime) FROM performance_curve pc2
         WHERE pc2.curve_object_id=p_curve_object_id AND pc2.curve_purpose=p_curve_purpose
         AND (pc2.perf_curve_status='ACCEPTED' OR pc2.perf_curve_status IS NULL)
         AND pc2.daytime<=p_daytime
      );

   CURSOR c_NewPerfCurveId(c_phase VARCHAR2) IS
      SELECT pc.perf_curve_id
      FROM performance_curve pc
      WHERE pc.curve_object_id=p_curve_object_id
      AND pc.curve_purpose=p_curve_purpose
      AND pc.phase=c_phase
      AND (pc.perf_curve_status='ACCEPTED' OR pc.perf_curve_status IS NULL)
      AND pc.daytime=(
         SELECT MAX(pc2.daytime)
         FROM performance_curve pc2
         WHERE pc2.curve_object_id=p_curve_object_id
         AND pc2.curve_purpose=p_curve_purpose
         AND pc2.phase=c_phase
         AND (pc2.perf_curve_status='ACCEPTED' OR pc2.perf_curve_status IS NULL)
         AND pc2.daytime<=p_daytime
      );


BEGIN
   l_id:=NULL;
   lv2_calc_method := Nvl(p_calc_method,
                          ec_well_version.calc_method_mass(p_curve_object_id, p_daytime, '<='));

  IF p_phase is NULL OR (substr(lv2_calc_method,1,5) != 'CURVE') then
    FOR r_id IN c_PerfCurveId LOOP
      l_id:=r_id.perf_curve_id;
    END LOOP;
  ELSE
    IF ecdp_objects.GetObjClassName(p_curve_object_id) = 'WELL' THEN
      IF lv2_calc_method = 'CURVE' THEN
        lv2_phase := EcDp_Phase.OIL;
      ELSIF lv2_calc_method = 'CURVE_LIQUID' THEN
        lv2_phase := EcDp_Phase.LIQUID;
	    ELSIF lv2_calc_method = 'CURVE_GAS' or lv2_calc_method ='CURVE_INJ_GAS' or lv2_calc_method ='CURVE_GAS_LIFT' THEN
		    lv2_phase := EcDp_Phase.GAS;
      ELSIF lv2_calc_method = 'CURVE_WATER' or lv2_calc_method ='CURVE_INJ_WATER' THEN
		    lv2_phase := EcDp_Phase.WATER;
      ELSE lv2_phase := getCurveIdPhase(p_curve_object_id,
                                     p_daytime,
                                     p_curve_purpose,
                                     p_phase,
                                     p_calc_method);
      END IF;
    ELSIF ecdp_objects.GetObjClassName(p_curve_object_id) = 'FLOWLINE' THEN
      IF p_calc_method = 'CURVE' THEN
        lv2_phase := EcDp_Phase.OIL;
      ELSIF p_calc_method = 'CURVE_LIQUID' THEN
        lv2_phase := EcDp_Phase.LIQUID;
	    ELSIF p_calc_method = 'CURVE_GAS' or p_calc_method ='CURVE_INJ_GAS' or p_calc_method ='CURVE_GAS_LIFT' THEN
		    lv2_phase := EcDp_Phase.GAS;
      ELSIF p_calc_method = 'CURVE_WATER' or p_calc_method ='CURVE_INJ_WATER' THEN
		    lv2_phase := EcDp_Phase.WATER;
      ELSE lv2_phase := getCurveIdPhase(p_curve_object_id,
                                        p_daytime,
                                        p_curve_purpose,
                                        p_phase,
                                        p_calc_method);
      END IF;
    END IF;
    FOR r_id IN c_NewPerfCurveId(lv2_phase) LOOP
      l_id:=r_id.perf_curve_id;
    END LOOP;
  END IF;

  RETURN l_id;
END getWellPerformanceCurveId;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNextWellPerformanceCurveId                                                --
-- Description    : Finds the first "future" performance curve for the given well, daytime and   --
--                  purpose. (That is the first curve that is not yet valid).                    --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : PERFORMANCE_CURVE                                                            --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      : Returns the performance curve with the given well and purpose that has       --
--                  the lowest daytime >= the given daytime, or NULL if no such curve can        --
--                  be found.                                                                    --
--                  Note the use of >=, which means that both this function and                  --
--                  getWellPerformanceCurveId will return the same curve if there is a           --
--                  curve that excatly matches the given daytime. This is by design to           --
--                  aid business functions in interpolating curves in time.                      --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getNextWellPerformanceCurveId(
                        p_curve_object_id VARCHAR2,
                        p_daytime DATE,
                        p_curve_purpose VARCHAR2,
                        p_phase VARCHAR2 DEFAULT NULL,
                        p_calc_method VARCHAR2 DEFAULT NULL
) RETURN NUMBER
--</EC-DOC>
IS
   l_id  performance_curve.perf_curve_id%TYPE;
   lv2_phase VARCHAR2(32);
   lv2_calc_method  VARCHAR2(32);

   CURSOR c_PerfCurveId IS
      SELECT pc.perf_curve_id FROM performance_curve pc
      WHERE pc.curve_object_id=p_curve_object_id AND pc.curve_purpose=p_curve_purpose
      AND (pc.perf_curve_status='ACCEPTED' OR pc.perf_curve_status IS NULL)
      AND pc.daytime=(
         SELECT MIN(pc2.daytime) FROM performance_curve pc2
         WHERE pc2.curve_object_id=p_curve_object_id AND pc2.curve_purpose=p_curve_purpose
         AND (pc2.perf_curve_status='ACCEPTED' OR pc2.perf_curve_status IS NULL)
         AND pc2.daytime>=p_daytime
      );

   CURSOR c_NewPerfCurveId(c_phase VARCHAR2) IS
      SELECT pc.perf_curve_id
      FROM performance_curve pc
      WHERE pc.curve_object_id=p_curve_object_id
      AND pc.curve_purpose=p_curve_purpose
      AND pc.phase=c_phase
      AND (pc.perf_curve_status='ACCEPTED' OR pc.perf_curve_status IS NULL)
      AND pc.daytime=(
         SELECT MIN(pc2.daytime)
         FROM performance_curve pc2
         WHERE pc2.curve_object_id=p_curve_object_id
         AND pc2.curve_purpose=p_curve_purpose
         AND pc2.phase=c_phase
         AND (pc2.perf_curve_status='ACCEPTED' OR pc2.perf_curve_status IS NULL)
         AND pc2.daytime>=p_daytime
      );

BEGIN
   l_id:=NULL;
   lv2_calc_method := Nvl(p_calc_method,
                          ec_well_version.calc_method_mass(p_curve_object_id, p_daytime, '<='));

  IF p_phase is NULL OR (substr(lv2_calc_method,1,5) != 'CURVE') THEN
    FOR r_id IN c_PerfCurveId LOOP
        l_id:=r_id.perf_curve_id;
    END LOOP;
  ELSE
    IF ecdp_objects.GetObjClassName(p_curve_object_id) = 'WELL' THEN
      IF lv2_calc_method = 'CURVE' THEN
        lv2_phase := EcDp_Phase.OIL;
      ELSIF lv2_calc_method = 'CURVE_LIQUID' THEN
        lv2_phase := EcDp_Phase.LIQUID;
      ELSIF lv2_calc_method = 'CURVE_GAS' or lv2_calc_method ='CURVE_INJ_GAS' or lv2_calc_method ='CURVE_GAS_LIFT' THEN
        lv2_phase := EcDp_Phase.GAS;
      ELSIF lv2_calc_method = 'CURVE_WATER' or lv2_calc_method ='CURVE_INJ_WATER' THEN
        lv2_phase := EcDp_Phase.WATER;
      ELSE lv2_phase := getCurveIdPhase(p_curve_object_id,
                                     p_daytime,
                                     p_curve_purpose,
                                     p_phase,
                                     p_calc_method);
      END IF;
    ELSIF ecdp_objects.GetObjClassName(p_curve_object_id) = 'FLOWLINE' THEN
      IF p_calc_method = 'CURVE' THEN
        lv2_phase := EcDp_Phase.OIL;
      ELSIF p_calc_method = 'CURVE_LIQUID' THEN
        lv2_phase := EcDp_Phase.LIQUID;
	    ELSIF p_calc_method = 'CURVE_GAS' or p_calc_method ='CURVE_INJ_GAS' or p_calc_method ='CURVE_GAS_LIFT' THEN
		    lv2_phase := EcDp_Phase.GAS;
      ELSIF p_calc_method = 'CURVE_WATER' or p_calc_method ='CURVE_INJ_WATER' THEN
		    lv2_phase := EcDp_Phase.WATER;
      ELSE lv2_phase := getCurveIdPhase(p_curve_object_id,
                                        p_daytime,
                                        p_curve_purpose,
                                        p_phase,
                                        p_calc_method);
      END IF;
    END IF;
    FOR r_id IN c_NewPerfCurveId(lv2_phase)  LOOP
      l_id:=r_id.perf_curve_id;
    END LOOP;
  END IF;

  RETURN l_id;
END getNextWellPerformanceCurveId;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getPrevWellPerformanceCurveId
-- Description    : Finds the first "previous" performance curve for the given well, daytime and
--                  purpose.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PERFORMANCE_CURVE
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the performance curve with the given well and purpose that has
--                  the highest daytime < the given daytime, or NULL if no such curve can
--                  be found.
--
---------------------------------------------------------------------------------------------------
FUNCTION getPrevWellPerformanceCurveId(
                        p_curve_object_id VARCHAR2,
                        p_daytime DATE,
                        p_curve_purpose VARCHAR2,
                        p_phase VARCHAR2  DEFAULT NULL,
                        p_calc_method VARCHAR2 DEFAULT NULL
) RETURN NUMBER
--</EC-DOC>
IS
   l_id  performance_curve.perf_curve_id%TYPE;
   lv2_phase VARCHAR2(32);
   lv2_calc_method  VARCHAR2(32);

   CURSOR c_PerfCurveId IS
      SELECT pc.perf_curve_id FROM performance_curve pc
      WHERE pc.curve_object_id=p_curve_object_id AND pc.curve_purpose=p_curve_purpose
      AND (pc.perf_curve_status='ACCEPTED' OR pc.perf_curve_status IS NULL)
      AND pc.daytime=(
         SELECT MAX(pc2.daytime) FROM performance_curve pc2
         WHERE pc2.curve_object_id=p_curve_object_id AND pc2.curve_purpose=p_curve_purpose
         AND (pc2.perf_curve_status='ACCEPTED' OR pc2.perf_curve_status IS NULL)
         AND pc2.daytime < p_daytime
      );

   CURSOR c_NewPerfCurveId(c_phase VARCHAR2) IS
      SELECT pc.perf_curve_id
      FROM performance_curve pc
      WHERE pc.curve_object_id=p_curve_object_id
      AND pc.curve_purpose=p_curve_purpose
      AND pc.phase=c_phase
      AND (pc.perf_curve_status='ACCEPTED' OR pc.perf_curve_status IS NULL)
      AND pc.daytime=(
         SELECT MAX(pc2.daytime)
         FROM performance_curve pc2
         WHERE pc2.curve_object_id=p_curve_object_id
         AND pc2.curve_purpose=p_curve_purpose
         AND pc2.phase=c_phase
         AND (pc2.perf_curve_status='ACCEPTED' OR pc2.perf_curve_status IS NULL)
         AND pc2.daytime < p_daytime
      );

BEGIN
   l_id:=NULL;
   lv2_calc_method := Nvl(p_calc_method,
                          ec_well_version.calc_method_mass(p_curve_object_id, p_daytime, '<='));

  IF p_phase is NULL OR (substr(lv2_calc_method,1,5) != 'CURVE') THEN
    FOR r_id IN c_PerfCurveId LOOP
      l_id:=r_id.perf_curve_id;
    END LOOP;
  ELSE
    IF ecdp_objects.GetObjClassName(p_curve_object_id) = 'WELL' THEN
      IF lv2_calc_method = 'CURVE' THEN
        lv2_phase := EcDp_Phase.OIL;
      ELSIF lv2_calc_method = 'CURVE_LIQUID' THEN
        lv2_phase := EcDp_Phase.LIQUID;
      ELSIF lv2_calc_method = 'CURVE_GAS' or lv2_calc_method ='CURVE_INJ_GAS' or lv2_calc_method ='CURVE_GAS_LIFT' THEN
        lv2_phase := EcDp_Phase.GAS;
      ELSIF lv2_calc_method = 'CURVE_WATER' or lv2_calc_method ='CURVE_INJ_WATER' THEN
        lv2_phase := EcDp_Phase.WATER;
      ELSE lv2_phase := getCurveIdPhase(p_curve_object_id,
                                     p_daytime,
                                     p_curve_purpose,
                                     p_phase,
                                     p_calc_method);
      END IF;
    ELSIF ecdp_objects.GetObjClassName(p_curve_object_id) = 'FLOWLINE' THEN
      IF p_calc_method = 'CURVE' THEN
        lv2_phase := EcDp_Phase.OIL;
      ELSIF p_calc_method = 'CURVE_LIQUID' THEN
        lv2_phase := EcDp_Phase.LIQUID;
	    ELSIF p_calc_method = 'CURVE_GAS' or p_calc_method ='CURVE_INJ_GAS' or p_calc_method ='CURVE_GAS_LIFT' THEN
		    lv2_phase := EcDp_Phase.GAS;
      ELSIF p_calc_method = 'CURVE_WATER' or p_calc_method ='CURVE_INJ_WATER' THEN
		    lv2_phase := EcDp_Phase.WATER;
      ELSE lv2_phase := getCurveIdPhase(p_curve_object_id,
                                        p_daytime,
                                        p_curve_purpose,
                                        p_phase,
                                        p_calc_method);
      END IF;
    END IF;
    FOR r_id IN c_NewPerfCurveId(lv2_phase) LOOP
      l_id:=r_id.perf_curve_id;
    END LOOP;
  END IF;

  RETURN l_id;
END getPrevWellPerformanceCurveId;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getStdRateFromParamValue                                                     --
-- Description    : Calculates the rate from the parameter and third axis values using the       --
--                  given performance curve. The result is converted to the requested phase      --
--                  as needed.                                                                   --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : CURVE                                                                        --
--                  PERFORMANCE_CURVE                                                            --
--                                                                                               --
-- Using functions: EcDp_Curve.getYFrom
--                  EcDp_Curve.getConversionConstantfromX                                        --
--                  EcBp_MathLib.interpolateLinearBoundary                                       --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      : Calculates the rate with the following steps:                                --
--                    1. Locates the two curves that have a Z_VALUE nearest to the given         --
--                       third axis value. (There is special handling to use only one curve      --
--                       if the given value is 0, this is to improve performance when the        --
--                       third axis is not being used).                                          --
--                    2. Calculates the rate for each of the two curves and interpolates         --
--                       based on z to find the "raw" rate.                                      --
--                       If there was an exact match on a z value then no interpolation          --
--                       is done. For boundary value cases, the single nearest curve is used.    --
--                       Negative x and/or y values will be set to 0 before any calculations     --
--                       to compensate for inaccurate measurements and/or deviances between      --
--                       the curve and the real values.                                          --
--                    3. If the curve's phase differ from the requested phase then the           --
--                       raw rate is converted using GOR, WC, CGR or WGR. These are stored on    --
--                       curve points. To get a constant that is not exactly on a curve point,   --
--                       curve point interpolation is being used. Also, to get a constant that   --
--                       is not exactly on a third axis, interpolation is being used.
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getStdRateFromParamValue(
                        p_perf_curve_id NUMBER,
                        p_phase VARCHAR2,
                        p_param_value NUMBER,
                        p_third_axis_value NUMBER
) RETURN NUMBER
--</EC-DOC>
IS
   lv2_curve_phase  curve.phase%TYPE;
   ln_curve_id1 NUMBER;
   ln_curve_id2 NUMBER;
   ln_y1 NUMBER;
   ln_y2 NUMBER;
   ln_z1 NUMBER;
   ln_z2 NUMBER;
   ln_value NUMBER;
   ln_param_value NUMBER;

   ln_gor1 NUMBER;
   ln_cgr1 NUMBER;
   ln_wgr1 NUMBER;
   ln_watercut_pct1 NUMBER;

   ln_gor2 NUMBER;
   ln_cgr2 NUMBER;
   ln_wgr2 NUMBER;
   ln_watercut_pct2 NUMBER;

   ln_gor NUMBER;
   ln_cgr NUMBER;
   ln_wgr NUMBER;
   ln_watercut_pct NUMBER;


   CURSOR c_curve_phase IS
      SELECT DISTINCT phase FROM curve WHERE perf_curve_id=p_perf_curve_id;

   CURSOR c_first_lower_z (p_src_phase IN curve.phase%TYPE) IS
      SELECT curve_id,z_value
      FROM curve
      WHERE perf_curve_id=p_perf_curve_id
      AND phase=p_src_phase
      AND z_value=
      (
         SELECT MAX(z_value)
         FROM curve
         WHERE perf_curve_id=p_perf_curve_id
         AND phase=p_src_phase
         AND z_value<=p_third_axis_value
      );

   CURSOR c_first_higher_z (p_src_phase IN curve.phase%TYPE) IS
      SELECT curve_id,z_value
      FROM curve
      WHERE perf_curve_id=p_perf_curve_id
      AND phase=p_src_phase
      AND z_value=
      (
         SELECT MIN(z_value)
         FROM curve
         WHERE perf_curve_id=p_perf_curve_id
         AND phase=p_src_phase
         AND z_value>=p_third_axis_value
      );
BEGIN
   -- Validate inputs
   ln_param_value:=p_param_value;
   IF ln_param_value IS NULL THEN
      RETURN NULL;
   END IF;
   IF ln_param_value<0 THEN
      ln_param_value:=0;
   END IF;
   IF p_phase IS NULL OR NOT p_phase IN (EcDp_Phase.OIL,EcDp_Phase.GAS,EcDp_Phase.WATER,EcDp_Phase.CONDENSATE,EcDp_Phase.LIQUID) THEN
      -- Unknown destination phase
      RETURN NULL;
   END IF;

   -- Find the source phase to use
   -- This is were multi-phase logic must be placed!
   FOR r_curve_phase IN c_curve_phase LOOP
      lv2_curve_phase:=r_curve_phase.phase;
   END LOOP;
   IF lv2_curve_phase IS NULL OR NOT lv2_curve_phase IN (EcDp_Phase.OIL,EcDp_Phase.GAS,EcDp_Phase.WATER,EcDp_Phase.LIQUID) THEN
      -- Unknown curve phase
      RETURN NULL;
   END IF;

   -- Then get the two nearest curves and find z and y from them
   IF p_third_axis_value>0 THEN  -- Just to avoid extra logic for single-curve systems
      FOR r_lower_z IN c_first_lower_z(lv2_curve_phase) LOOP
         ln_curve_id1:=r_lower_z.curve_id;
         ln_z1:=r_lower_z.z_value;
         ln_y1:=EcDp_Curve.getYFromX(ln_curve_id1,ln_param_value);
         IF lv2_curve_phase!=p_phase OR lv2_curve_phase = 'LIQ' THEN
            ln_gor1 := EcDp_Curve.getRatioOrWcfromX(ln_curve_id1,ln_param_value,'GOR');
            ln_cgr1 := EcDp_Curve.getRatioOrWcfromX(ln_curve_id1,ln_param_value,'CGR');
            ln_wgr1 := EcDp_Curve.getRatioOrWcfromX(ln_curve_id1,ln_param_value,'WGR');
            ln_watercut_pct1 := EcDp_Curve.getRatioOrWcfromX(ln_curve_id1,ln_param_value,'WATERCUT_PCT');
         END IF;
      IF ln_y1<0 THEN
         ln_y1:=0;
      END IF;
      END LOOP;
   END IF;
   FOR r_higher_z IN c_first_higher_z(lv2_curve_phase) LOOP
      ln_curve_id2:=r_higher_z.curve_id;
      ln_z2:=r_higher_z.z_value;
      ln_y2:=EcDp_Curve.getYFromX(ln_curve_id2,ln_param_value);
      IF lv2_curve_phase!=p_phase OR lv2_curve_phase = 'LIQ' THEN
         ln_gor2 := EcDp_Curve.getRatioOrWcfromX(ln_curve_id2,ln_param_value,'GOR');
         ln_cgr2 := EcDp_Curve.getRatioOrWcfromX(ln_curve_id2,ln_param_value,'CGR');
         ln_wgr2 := EcDp_Curve.getRatioOrWcfromX(ln_curve_id2,ln_param_value,'WGR');
         ln_watercut_pct2 := EcDp_Curve.getRatioOrWcfromX(ln_curve_id2,ln_param_value,'WATERCUT_PCT');
      END IF;
      IF ln_y2<0 THEN
         ln_y2:=0;
      END IF;
   END LOOP;

   -- Find the raw value from boundary/interpolation techniques
   ln_value:=EcBp_MathLib.interpolateLinearBoundary(p_third_axis_value,ln_z1,ln_y1,ln_z2,ln_y2);
   IF ln_value IS NULL THEN
      RETURN NULL;
   END IF;


   -- Convert value to the requested phase if neccessary
   -- For GP wells we have WGR and CGR: W=G*WGR  O=G*CGR
   -- For OP wells we have WC and GOR: W=WC/(1-WC)*O  G=O*GOR     (WC=WATERCUT_PCT/100)
   -- For other wells we don't have any of these, however the same formulas are used
   -- anyway to support any future extensions.

   IF lv2_curve_phase!=p_phase THEN
      -- Find phase constants from boundary/interpolation techniques
      ln_gor:=EcBp_MathLib.interpolateLinearBoundary(p_third_axis_value,ln_z1,ln_gor1,ln_z2,ln_gor2);
      ln_cgr:=EcBp_MathLib.interpolateLinearBoundary(p_third_axis_value,ln_z1,ln_cgr1,ln_z2,ln_cgr2);
      ln_wgr:=EcBp_MathLib.interpolateLinearBoundary(p_third_axis_value,ln_z1,ln_wgr1,ln_z2,ln_wgr2);
      ln_watercut_pct :=EcBp_MathLib.interpolateLinearBoundary(p_third_axis_value,ln_z1,ln_watercut_pct1,ln_z2,ln_watercut_pct2);


   -- Convert to the requested phase

      -- Requested phase value is GAS
      IF p_phase=EcDp_Phase.GAS THEN
         IF lv2_curve_phase=EcDp_Phase.OIL THEN
            -- OIL -> GAS : Use GOR
            ln_value:=ln_value*ln_gor;
         ELSIF lv2_curve_phase=EcDp_Phase.LIQUID THEN
            -- LIQUID -> GAS : Use GOR and WC
            ln_value:=ln_value*((100-ln_watercut_pct)/100)*ln_gor;
         ELSIF lv2_curve_phase=EcDp_Phase.WATER THEN
            -- WATER -> GAS : Not supported by the GUI, we use WGR anyway
            ln_value:=ln_value/ln_wgr;
         END IF;

      -- Requested phase value is OIL
      ELSIF p_phase=EcDp_Phase.OIL THEN
         IF lv2_curve_phase=EcDp_Phase.WATER THEN
            -- WATER -> OIL : Not supported by the GUI, we use WC anyway
            IF ln_watercut_pct=0 THEN
               -- All the water is oil...
               ln_value:=ln_value;
            ELSIF ln_watercut_pct>0 AND ln_watercut_pct<=100 THEN
               ln_value:=ln_value*(100-ln_watercut_pct)/ln_watercut_pct;
            ELSE
               ln_value:=NULL;
            END IF;
         ELSIF lv2_curve_phase=EcDp_Phase.LIQUID THEN
            -- LIQUID -> OIL : Use WC
            ln_value:=ln_value*(100-ln_watercut_pct)/100;
         ELSIF lv2_curve_phase=EcDp_Phase.GAS THEN
            -- This supports situations where condensate is handled as oil in the system
            IF ln_cgr>=0 THEN
               ln_value:=ln_value*ln_cgr;
            ELSE
               ln_value:=NULL;
            END IF;
         END IF;

      -- Requested phase value is COND
      ELSIF p_phase=EcDp_Phase.CONDENSATE THEN
         IF lv2_curve_phase=EcDp_Phase.GAS THEN
            -- GAS -> COND : Use CGR
            IF ln_cgr>=0 THEN
               ln_value:=ln_value*ln_cgr;
            ELSE
               ln_value:=NULL;
            END IF;
         END IF;

      -- Requested phase value is WATER
      ELSIF p_phase=EcDp_Phase.WATER THEN
         IF lv2_curve_phase=EcDp_Phase.OIL THEN
            -- OIL -> WATER : Use WC
            IF ln_watercut_pct=100 THEN
               -- All the oil is water...
               ln_value:=ln_value;
            ELSIF ln_watercut_pct>=0 AND ln_watercut_pct<100 THEN
               ln_value:=ln_value*ln_watercut_pct/(100-ln_watercut_pct);
            ELSE
               ln_value:=NULL;
            END IF;
         ELSIF lv2_curve_phase=EcDp_Phase.LIQUID THEN
            -- LIQUID -> WATER : Use WC
            ln_value:=ln_value*(ln_watercut_pct/100);
         ELSIF lv2_curve_phase=EcDp_Phase.GAS THEN
            -- GAS -> WATER : Use WGR
            IF ln_wgr>=0 THEN
               ln_value:=ln_value*ln_wgr;
            ELSE
               ln_value:=NULL;
            END IF;
         END IF;
      END IF;
    ELSIF lv2_curve_phase = p_phase  and p_phase = EcDp_Phase.LIQUID  THEN
     -- Find phase constants from boundary/interpolation techniques
      ln_watercut_pct :=EcBp_MathLib.interpolateLinearBoundary(p_third_axis_value,ln_z1,ln_watercut_pct1,ln_z2,ln_watercut_pct2);
      ln_value:=ln_value*(1-ln_watercut_pct/100);
    END IF; -- same phase

   IF ln_value<0 THEN
      ln_value:=0;
   END IF;
   RETURN ln_value;
END getStdRateFromParamValue;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : copyPerformanceCurve                                                         --
-- Description    : Performs a "deep copy" of a performance curve and sets the daytime of the    --
--                  copy to the current date and time.                                           --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : PERFORMANCE_CURVE                                                            --
--                  CURVE                                                                        --
--                  CURVE_POINT                                                                  --
--                                                                                               --
-- Using functions: EcDp_System_Key.assignNextNumber                                           --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
PROCEDURE copyPerformanceCurve(p_src_perf_curve_id NUMBER,
                               p_phase VARCHAR2 DEFAULT NULL
)
--</EC-DOC>
IS
   ln_dest_perf_curve_id NUMBER;
   ln_dest_curve_id      NUMBER;
   ld_daytime            DATE;
   n_lock_columns        EcDp_Month_lock.column_list;
   lr_performance_curve  PERFORMANCE_CURVE%ROWTYPE;


   CURSOR c_curves IS
      SELECT curve_id,y_valid_from,y_valid_to FROM curve WHERE perf_curve_id=p_src_perf_curve_id;
BEGIN

   ld_daytime:=trunc(Ecdp_Timestamp.getCurrentSysdate,'dd');

   -- Lock check
   lr_performance_curve := EC_performance_curve.row_by_pk(p_src_perf_curve_id);

    EcDp_month_lock.AddParameterToList(n_lock_columns,'CLASS_NAME','PERFORMANCE_CURVE','STRING',NULL,NULL,NULL);
    EcDp_month_lock.AddParameterToList(n_lock_columns,'TABLE_NAME','V_PERFORMANCE_CURVE','STRING',NULL,NULL,NULL);
    EcDp_month_lock.AddParameterToList(n_lock_columns,'DAYTIME','DAYTIME','DATE','N',EcDp_month_lock.isUpdating(UPDATING('DAYTIME')),anydata.Convertdate(ld_DAYTIME));
    EcDp_month_lock.AddParameterToList(n_lock_columns,'CURVE_PURPOSE','CURVE_PURPOSE','STRING','N',EcDp_month_lock.isUpdating(UPDATING('CURVE_PURPOSE')),anydata.ConvertVarChar2(lr_performance_curve.CURVE_PURPOSE));
    EcDp_month_lock.AddParameterToList(n_lock_columns,'CURVE_OBJECT_ID','CURVE_OBJECT_ID','STRING','N',EcDp_month_lock.isUpdating(UPDATING('CURVE_OBJECT_ID')),anydata.ConvertVarChar2(lr_performance_curve.CURVE_OBJECT_ID));
    EcDp_month_lock.AddParameterToList(n_lock_columns,'PERF_CURVE_ID','PERF_CURVE_ID','NUMBER','Y',EcDp_month_lock.isUpdating(UPDATING('PERF_CURVE_ID')),anydata.ConvertNumber(lr_performance_curve.PERF_CURVE_ID));

    EcDp_Performance_lock.CheckLockPerformanceCurve('INSERTING',n_lock_columns,n_lock_columns);


   EcDp_System_Key.assignNextNumber('PERFORMANCE_CURVE', ln_dest_perf_curve_id);

    -- Copy the performance curve itself

    if p_phase is NULL then
      INSERT INTO performance_curve (perf_curve_id,daytime,curve_object_id,curve_purpose,curve_parameter_code,plane_intersect_code,class_name)
      (
          SELECT ln_dest_perf_curve_id,ld_daytime AS daytime,curve_object_id,curve_purpose,curve_parameter_code,plane_intersect_code,class_name
          FROM performance_curve
          WHERE perf_curve_id=p_src_perf_curve_id
      );
    else
      INSERT INTO performance_curve (perf_curve_id,daytime,curve_object_id,curve_purpose,curve_parameter_code,plane_intersect_code,class_name,phase,formula_type)
      (
          SELECT ln_dest_perf_curve_id,ld_daytime AS daytime,curve_object_id,curve_purpose,curve_parameter_code,plane_intersect_code,class_name,phase,formula_type
          FROM performance_curve
          WHERE perf_curve_id=p_src_perf_curve_id
      );
    end if;

   -- Copy all curves
   FOR r_curve IN c_curves LOOP

      EcDp_System_Key.assignNextNumber('CURVE', ln_dest_curve_id);

      -- Copy the curve itself
      INSERT INTO curve (curve_id,perf_curve_id,formula_type,phase,z_value,c0,c1,c2,c3,c4,y_valid_from,y_valid_to)
      (
         SELECT ln_dest_curve_id,ln_dest_perf_curve_id,formula_type,phase,z_value,c0,c1,c2,c3,c4,y_valid_from,y_valid_to
         FROM curve
         WHERE curve_id=r_curve.curve_id
      );
      -- Copy all points
      INSERT INTO curve_point(curve_id,seq,x_value,y_value,gor,cgr,wgr,watercut_pct,repr_point)
      (
         SELECT ln_dest_curve_id,seq,x_value,y_value,gor,cgr,wgr,watercut_pct,repr_point
         FROM curve_point
         WHERE curve_id=r_curve.curve_id
      );
      -- Touch the Y_VALID_FROM / Y_VALID_TO since these might have been changed by trigger logic
      -- (since the curve must be copied before the points...)
      UPDATE curve SET
         y_valid_from=r_curve.y_valid_from,
         y_valid_to=r_curve.y_valid_to
      WHERE curve_id=ln_dest_curve_id;
   END LOOP;
EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN  -- Ignore if group entry already exists
      RAISE_APPLICATION_ERROR(-20000,'A performance curve already exists with start date '||to_char(ld_daytime,'yyyy-mm-dd')||'.');
END copyPerformanceCurve;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : perfCurveStatusUpdate                                                        --
-- Description    : To handle the perf Curve Status update for NEW, ACCEPTED and REJECTED        --
--                  and update the record_status to 'P', 'A' and 'V'                             --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : PERFORMANCE_CURVE                                                            --
--                  CURVE                                                                        --
--                  CURVE_POINT                                                                  --
--                                                                                               --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
PROCEDURE perfCurveStatusUpdate(p_curve_object_id     VARCHAR2,
                                p_daytime             DATE,
                                p_curve_purpose       VARCHAR2,
                                p_phase               VARCHAR2,
                                p_user_id             VARCHAR2 DEFAULT NULL
)
IS
  n_lock_columns          EcDp_Month_lock.column_list;
  lr_performance_curve    PERFORMANCE_CURVE%ROWTYPE;
  lv2_record_status       PROSTY_CODES.ALT_CODE%TYPE;

  CURSOR c_perf_curve_row IS
  SELECT *
  FROM PERFORMANCE_CURVE
  WHERE curve_object_id = p_curve_object_id
  AND daytime = p_daytime
  AND curve_purpose = p_curve_purpose
  AND phase = p_phase;

BEGIN
  FOR mycur IN c_perf_curve_row LOOP
     lr_performance_curve  := mycur;
  END LOOP;

  IF lr_performance_curve.PERF_CURVE_ID IS NOT NULL THEN
    EcDp_month_lock.AddParameterToList(n_lock_columns,'CLASS_NAME','PERFORMANCE_CURVE','STRING',NULL,NULL,NULL);
    EcDp_month_lock.AddParameterToList(n_lock_columns,'TABLE_NAME','V_PERFORMANCE_CURVE','STRING',NULL,NULL,NULL);
    EcDp_month_lock.AddParameterToList(n_lock_columns,'DAYTIME','DAYTIME','DATE','N',EcDp_month_lock.isUpdating(UPDATING('DAYTIME')),anydata.Convertdate(lr_performance_curve.DAYTIME));
    EcDp_month_lock.AddParameterToList(n_lock_columns,'CURVE_PURPOSE','CURVE_PURPOSE','STRING','N',EcDp_month_lock.isUpdating(UPDATING('CURVE_PURPOSE')),anydata.ConvertVarChar2(lr_performance_curve.CURVE_PURPOSE));
    EcDp_month_lock.AddParameterToList(n_lock_columns,'CURVE_OBJECT_ID','CURVE_OBJECT_ID','STRING','N',EcDp_month_lock.isUpdating(UPDATING('CURVE_OBJECT_ID')),anydata.ConvertVarChar2(lr_performance_curve.CURVE_OBJECT_ID));
    EcDp_month_lock.AddParameterToList(n_lock_columns,'PERF_CURVE_ID','PERF_CURVE_ID','NUMBER','Y',EcDp_month_lock.isUpdating(UPDATING('PERF_CURVE_ID')),anydata.ConvertNumber(lr_performance_curve.PERF_CURVE_ID));
    EcDp_Performance_lock.CheckLockPerformanceCurve('UPDATING',n_lock_columns,n_lock_columns);
    -- Once the performance curve lock check is checked to proceed further, no need to do the lock check on the related child tables of CURVE and CURVE_POINT.
  END IF;

  lv2_record_status := ec_prosty_codes.alt_code(lr_performance_curve.perf_curve_status,'PERF_CURVE_STATUS');

  IF lr_performance_curve.record_status <> lv2_record_status THEN
    UPDATE PERFORMANCE_CURVE pc
    SET pc.record_status = lv2_record_status, pc.last_updated_by = Nvl(p_user_id, USER), pc.last_updated_date = Ecdp_Timestamp.getCurrentSysdate
    WHERE pc.perf_curve_id = lr_performance_curve.perf_curve_id;

    UPDATE CURVE c
    SET c.record_status =  lv2_record_status, c.last_updated_by = Nvl(p_user_id, USER), c.last_updated_date = Ecdp_Timestamp.getCurrentSysdate
    WHERE c.perf_curve_id = lr_performance_curve.perf_curve_id;

    UPDATE CURVE_POINT cp
    SET cp.record_status = lv2_record_status, cp.last_updated_by = Nvl(p_user_id, USER), cp.last_updated_date = Ecdp_Timestamp.getCurrentSysdate
    WHERE EXISTS (SELECT 1
                  FROM CURVE c
                  WHERE c.curve_id = cp.curve_id
                  AND EXISTS (SELECT 1
                              FROM PERFORMANCE_CURVE pc
                              WHERE pc.perf_curve_id = lr_performance_curve.perf_curve_id
                              AND pc.perf_curve_id = c.perf_curve_id));
  END IF;

END perfCurveStatusUpdate;

END EcDp_Performance_Curve;