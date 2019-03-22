CREATE OR REPLACE PACKAGE BODY EcDp_Forecast_Curve IS
/****************************************************************
** Package        :  EcDp_Forecast_Curve
**
** $Revision: 1.27 $
**
** Purpose        : This package is responsible for supporting business functions
**                   related to Well Production Curves and Scenario Curves.
** Documentation  :  www.energy-components.com
**
** Created  : 04.01.2018  Mawaddah Abdul Latif
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 04.01.2018	abdulmaw ECDP-51518: Initial version
** 04.02.2018	solibhar ECDP-52028: getWellProduct function added which used in ForecastScenariosCurvesHelper.java
** 22.02.2018   kashisag ECDP-51518: Added support for Cond Producer Well in sorting function
** 28.02.2018   kashisag ECDP-53209: Added new procedure for parameter validation
** 12.03.2018   kashisag ECDP-53209: Added new procedure for deleting segments
** 12.03.2018   kashisag ECDP-53209: Updated segment logic
** 21.03.2018   kashisag ECPD-40985: Added new procedure for forecast volume calculation
** 26.03.2018   kashisag ECPD-40985: updated procedure for forecast volume calculation
** 04.04.2018   kashisag ECPD-40985: updated procedure for change in compensation event logic
** 23.04.2018   kashisag ECPD-55121: Updated end date logic for forecast volume calculation
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getSegmentNo
-- Description    : Set segment based on phase and fcst_curve_id
--
--
-- Preconditions  :
-- Postconditions : .
--
-- Using tables   :
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSegmentNo(p_fcst_curve_id NUMBER,
                      p_phase VARCHAR2)
RETURN NUMBER
  --</EC-DOC>

 IS

  CURSOR c_segmentNo(cp_fcst_curve_id VARCHAR2, cp_phase VARCHAR2) IS
    SELECT max(segment) segment
    FROM FCST_PROD_CURVES_SEGMENT
    WHERE fcst_curve_id = cp_fcst_curve_id
    AND phase = cp_phase;

  ln_segment NUMBER;
  ln_return_val NUMBER;

BEGIN

  FOR cur_segmentNo IN c_segmentNo(p_fcst_curve_id, p_phase) LOOP
    ln_segment := cur_segmentNo.segment;
  END LOOP;

  ln_return_val := nvl(ln_segment,0) + 1;

  RETURN ln_return_val;

END getSegmentNo;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : segmentDaytime
-- Description    : daytime for segment
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
FUNCTION segmentDaytime(p_fcst_curve_id NUMBER,
                        p_phase VARCHAR2,
                        p_segment NUMBER)
RETURN DATE
  --</EC-DOC>

 IS

  CURSOR c_curveStartDate(cp_fcst_curve_id VARCHAR2) IS
    SELECT daytime
      FROM FCST_PROD_CURVES
    WHERE fcst_curve_id = cp_fcst_curve_id;

  CURSOR c_segment(cp_fcst_curve_id VARCHAR2, cp_phase VARCHAR2) IS
    SELECT SEGMENT, INPUT_TF
      FROM FCST_PROD_CURVES_SEGMENT
    WHERE fcst_curve_id = cp_fcst_curve_id
      AND phase = cp_phase
      ORDER BY SEGMENT;

  ld_return_val      DATE;
  ln_tf              NUMBER;

BEGIN

  ln_tf := 0;

  FOR cur_segment IN c_segment(p_fcst_curve_id, p_phase) LOOP
    IF cur_segment.segment < p_segment THEN
      ln_tf := ln_tf + cur_segment.input_tf;
    END IF;
  END LOOP;

  FOR cur_curveStartDate IN c_curveStartDate(p_fcst_curve_id) LOOP
    IF ln_tf = 0 THEN
      ld_return_val := cur_curveStartDate.daytime;
    ELSE
      ld_return_val := cur_curveStartDate.daytime + ln_tf - 1;
    END IF;
  END LOOP;

  RETURN ld_return_val;

END segmentDaytime;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : segmentEndDate
-- Description    : end date for segment
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
FUNCTION segmentEndDate(p_fcst_curve_id NUMBER,
                        p_phase VARCHAR2,
                        p_segment NUMBER)
RETURN DATE
  --</EC-DOC>

 IS

  CURSOR c_curveStartDate(cp_fcst_curve_id VARCHAR2) IS
    SELECT DAYTIME, END_DATE, FORECAST_ID
      FROM FCST_PROD_CURVES
    WHERE fcst_curve_id = cp_fcst_curve_id;

  CURSOR c_segment(cp_fcst_curve_id VARCHAR2, cp_phase VARCHAR2) IS
    SELECT SEGMENT, INPUT_TF
      FROM FCST_PROD_CURVES_SEGMENT
    WHERE fcst_curve_id = cp_fcst_curve_id
      AND phase = cp_phase
      ORDER BY SEGMENT;

  ld_return_val      DATE;
  ln_tf              NUMBER;

BEGIN

  ln_tf := 0;

  FOR cur_segment IN c_segment(p_fcst_curve_id, p_phase) LOOP
    IF cur_segment.segment <= p_segment THEN
      ln_tf := ln_tf + cur_segment.input_tf;
    END IF;
  END LOOP;

  FOR cur_curveStartDate IN c_curveStartDate(p_fcst_curve_id) LOOP
    IF ln_tf IS NOT NULL THEN
      ld_return_val := cur_curveStartDate.daytime + ln_tf - 1;
    ELSE
      IF cur_curveStartDate.end_date IS NOT NULL THEN
        ld_return_val := cur_curveStartDate.end_date;
      ELSE
        ld_return_val := ec_forecast_group.end_date(cur_curveStartDate.forecast_id);
      END IF;
    END IF;
  END LOOP;

  RETURN ld_return_val;

END segmentEndDate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkMandatoryTf
-- Description    : check Tf should be mandatory or optional
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
FUNCTION checkMandatoryTf(p_fcst_curve_id NUMBER,
                          p_phase VARCHAR2)
return NUMBER
  --</EC-DOC>

 IS

  CURSOR c_segment(cp_fcst_curve_id VARCHAR2, cp_phase VARCHAR2) IS
    SELECT fcst_segment_id, INPUT_TF, segment
      FROM FCST_PROD_CURVES_SEGMENT
    WHERE fcst_curve_id = cp_fcst_curve_id
      AND phase = cp_phase
      ORDER BY SEGMENT;

  ln_return_val NUMBER;

BEGIN

  ln_return_val := 0;

  FOR cur_segment IN c_segment(p_fcst_curve_id, p_phase) LOOP
    IF cur_segment.INPUT_TF IS NULL THEN
      ln_return_val := cur_segment.fcst_segment_id;
    END IF;
  END LOOP;

  RETURN ln_return_val;

END checkMandatoryTf;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : setSegmentNo
-- Description    : set segment when previous record deleted
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE setSegmentNo(p_fcst_curve_id NUMBER,
                      p_phase VARCHAR2,
                      p_segment NUMBER,
                      p_user VARCHAR2)
  --</EC-DOC>

 IS

  CURSOR c_segment(cp_fcst_curve_id VARCHAR2, cp_phase VARCHAR2) IS
    SELECT fcst_segment_id, segment
      FROM FCST_PROD_CURVES_SEGMENT
    WHERE fcst_curve_id = cp_fcst_curve_id
      AND phase = cp_phase
      ORDER BY SEGMENT;

  ln_newSegment       NUMBER;

BEGIN

  FOR cur_segment IN c_segment(p_fcst_curve_id, p_phase) LOOP
    IF cur_segment.segment > p_segment THEN
      ln_newSegment := cur_segment.segment - 1;
      UPDATE FCST_PROD_CURVES_SEGMENT
      SET segment = ln_newSegment,
          last_updated_by = p_user
      WHERE fcst_segment_id = cur_segment.fcst_segment_id;
    END IF;
  END LOOP;

END setSegmentNo;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : isEditableQi
-- Description    : check Qi is vieweditable false or true
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
FUNCTION isEditableQi(p_fcst_curve_id NUMBER,
                       p_phase VARCHAR2,
                       p_segment NUMBER,
                       p_curve_shape VARCHAR2)
RETURN VARCHAR2
  --</EC-DOC>

 IS

  CURSOR c_segment(cp_fcst_curve_id VARCHAR2, cp_phase VARCHAR2) IS
    SELECT segment
      FROM FCST_PROD_CURVES_SEGMENT
    WHERE fcst_curve_id = cp_fcst_curve_id
      AND phase = cp_phase
      ORDER BY SEGMENT;

  lv2_return_val      VARCHAR2(16);

BEGIN

  FOR cur_segment IN c_segment(p_fcst_curve_id, p_phase) LOOP
    IF p_segment = 1 AND p_curve_shape != 'RATIO' THEN
      lv2_return_val := 'true';
    ELSE
      lv2_return_val := 'false';
    END IF;
  END LOOP;

  RETURN lv2_return_val;

END isEditableQi;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : setB
-- Description    : set B based on the curve method
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE setB(p_fcst_segment_id NUMBER,
               p_user VARCHAR2)
  --</EC-DOC>

 IS

  CURSOR c_segment(cp_fcst_segment_id VARCHAR2) IS
    SELECT CURVE_SHAPE
      FROM FCST_PROD_CURVES_SEGMENT
    WHERE fcst_segment_id = cp_fcst_segment_id;

BEGIN

  FOR cur_segment IN c_segment(p_fcst_segment_id) LOOP
    IF cur_segment.curve_shape = 'HARMONIC' THEN
      UPDATE FCST_PROD_CURVES_SEGMENT
      SET INPUT_B = 1,
          last_updated_by = p_user
      WHERE fcst_segment_id = p_fcst_segment_id;
    ELSIF cur_segment.curve_shape = 'EXPONENTIAL' THEN
      UPDATE FCST_PROD_CURVES_SEGMENT
      SET INPUT_B = 0,
          last_updated_by = p_user
      WHERE fcst_segment_id = p_fcst_segment_id;
    ELSE
      UPDATE FCST_PROD_CURVES_SEGMENT
      SET INPUT_B = NULL,
          last_updated_by = p_user
      WHERE fcst_segment_id = p_fcst_segment_id;
    END IF;
  END LOOP;

END setB;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getSortOrder
-- Description    : get sort order based on the producer. Primary phase for the producer will be sorted first (E.g Oil be will be 1st in order for Oil Producer)
--
--
-- Preconditions  :
-- Postconditions : .
--
-- Using tables   :
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSortOrder(p_fcst_curve_id NUMBER, p_fcst_segment_id NUMBER)
RETURN NUMBER
  --</EC-DOC>

 IS

  CURSOR c_segment(cp_fcst_segment_id VARCHAR2) IS
    SELECT phase
    FROM FCST_PROD_CURVES_SEGMENT
    WHERE fcst_segment_id = cp_fcst_segment_id;

  lv2_well_type         VARCHAR2(16);
  ln_return_val         NUMBER;

BEGIN

  BEGIN
    SELECT Ec_well_version.well_type(FCST_PROD_CURVES.WELL_ID,FCST_PROD_CURVES.DAYTIME,'<=') AS WELL_TYPE
      INTO lv2_well_type
      FROM FCST_PROD_CURVES
     WHERE fcst_curve_id = p_fcst_curve_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      lv2_well_type := null;
  END;

  FOR cur_segment IN c_segment(p_fcst_segment_id) LOOP
    IF lv2_well_type like 'OP%' THEN
      IF cur_segment.phase = 'OIL' THEN
        ln_return_val := 1;
      ELSIF cur_segment.phase = 'GAS' THEN
        ln_return_val := 2;
      ELSIF cur_segment.phase = 'WAT' THEN
        ln_return_val := 3;
      ELSE
        ln_return_val := 4;
      END IF;

    ELSIF lv2_well_type like 'GP%' THEN
      IF cur_segment.phase = 'GAS' THEN
        ln_return_val := 1;
      ELSIF cur_segment.phase = 'OIL' THEN
        ln_return_val := 2;
      ELSIF cur_segment.phase = 'COND' THEN
        ln_return_val := 3;
      ELSIF cur_segment.phase = 'WAT' THEN
        ln_return_val := 4;
      ELSE
        ln_return_val := 5;
      END IF;

    ELSIF lv2_well_type like 'WP%' THEN
      IF cur_segment.phase = 'WAT' THEN
        ln_return_val := 1;
      ELSIF cur_segment.phase = 'GAS' THEN
        ln_return_val := 2;
      ELSE
        ln_return_val := 3;
      END IF;
	ELSIF lv2_well_type like 'CP%' THEN
	  IF cur_segment.phase = 'COND' THEN
        ln_return_val := 1;
      ELSIF cur_segment.phase = 'GAS' THEN
        ln_return_val := 2;
      ELSE
        ln_return_val := 3;
      END IF;
    END IF;
  END LOOP;

  RETURN ln_return_val;

END getSortOrder;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateSegmentEndDate
-- Description    : Segment End Date have to be before Curve End Date
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateSegmentEndDate(p_fcst_curve_id NUMBER,
                                 p_phase VARCHAR2,
                                 p_segment VARCHAR2,
                                 p_tf NUMBER)
  --</EC-DOC>
IS

 CURSOR c_curve(cp_fcst_curve_id VARCHAR2) IS
    SELECT DAYTIME, END_DATE
      FROM FCST_PROD_CURVES
    WHERE fcst_curve_id = cp_fcst_curve_id;

 CURSOR c_segment(cp_fcst_curve_id VARCHAR2, cp_phase VARCHAR2) IS
    SELECT INPUT_TF, SEGMENT
      FROM FCST_PROD_CURVES_SEGMENT
     WHERE fcst_curve_id = cp_fcst_curve_id
      AND phase = cp_phase
      ORDER BY SEGMENT;

  ld_segment_end_date   DATE;
  ld_phase_end_date     DATE;
  ln_segment            NUMBER;
  ln_tf                 NUMBER;
  ln_tf_all             NUMBER;
  ln_tf_segment         NUMBER;

BEGIN

  ln_tf_all := 0;

  IF p_segment IS NULL THEN -- new segment
    ln_segment := getSegmentNo(p_fcst_curve_id, p_phase);
    ld_segment_end_date := segmentEndDate(p_fcst_curve_id, p_phase, ln_segment) + p_tf;
  ELSE -- existing segment
    FOR cur_segment IN c_segment(p_fcst_curve_id, p_phase) LOOP
      ln_tf_all := ln_tf_all + nvl(cur_segment.INPUT_TF,0);
      IF p_segment = cur_segment.SEGMENT THEN
         ln_tf := nvl(cur_segment.INPUT_TF,0);
      ELSIF cur_segment.SEGMENT <= p_segment THEN
         ln_tf_segment := ln_tf_segment + cur_segment.input_tf;
      END IF;
    END LOOP;
  END IF;

  FOR cur_curve IN c_curve(p_fcst_curve_id) LOOP
    ld_segment_end_date := cur_curve.daytime + ln_tf_segment - ln_tf + p_tf - 1;
    IF ld_segment_end_date > cur_curve.end_date THEN
      RAISE_APPLICATION_ERROR(-20470,'Segment End Date must be less then or equal to Curve End Date. Please update the Input Tf accordingly.');
    END IF;

    ld_phase_end_date := cur_curve.daytime + ln_tf_all - ln_tf + p_tf - 1;
    IF ld_phase_end_date > cur_curve.end_date THEN
      RAISE_APPLICATION_ERROR(-20470,'Segment End Date must be less then or equal to Curve End Date. Please update the Input Tf accordingly.');
    END IF;
  END LOOP;

END validateSegmentEndDate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateCurveEndDate
-- Description    : Segment End Date have to be before Curve End Date
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateCurveEndDate(p_fcst_curve_id NUMBER,
                               p_curve_end_date DATE)
  --</EC-DOC>
IS

 CURSOR c_segment(cp_fcst_curve_id VARCHAR2) IS
    SELECT count(SEGMENT) as SEGMENT, PHASE
      FROM FCST_PROD_CURVES_SEGMENT
     WHERE fcst_curve_id = cp_fcst_curve_id
       AND INPUT_TF IS NOT NULL
      GROUP BY PHASE;

  ld_segment_end_date      DATE;
  ld_max_segment_end_date  DATE;

BEGIN

  FOR cur_segment IN c_segment(p_fcst_curve_id) LOOP
    ld_segment_end_date := segmentEndDate(p_fcst_curve_id, cur_segment.PHASE, cur_segment.SEGMENT);
    IF ld_max_segment_end_date IS NULL THEN
      ld_max_segment_end_date := ld_segment_end_date;
    ELSIF ld_segment_end_date > ld_max_segment_end_date THEN
      ld_max_segment_end_date := ld_segment_end_date;
    END IF;
  END LOOP;

  IF p_curve_end_date < ld_max_segment_end_date THEN
    RAISE_APPLICATION_ERROR(-20470,'Segment End Date must be less then or equal to Curve End Date. Please update the Input Tf accordingly.');
  END IF;

END validateCurveEndDate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getWellProduct
-- Description    : get well product based on the producer. (E.g OP% for Oil, GP% for GAS, WP% for Water).
--					This function used in ForecastScenariosCurvesHelper.java to get Well Product based on Well Type.
--
--
-- Preconditions  :
-- Postconditions : .
--
-- Using tables   :
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
FUNCTION getWellProduct(p_fcst_curve_id NUMBER)
RETURN VARCHAR2
  --</EC-DOC>
 IS

  lv2_well_type         VARCHAR2(16);
  lv2_return_val        VARCHAR2(16);

BEGIN

  BEGIN
    SELECT WELL_TYPE
      INTO lv2_well_type
      FROM DV_FCST_CURVE
     WHERE fcst_curve_id = p_fcst_curve_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      lv2_well_type := null;
  END;


	IF lv2_well_type like 'OP%' THEN
	  lv2_return_val := 'OIL';
	ELSIF lv2_well_type like 'GP%' THEN
	  lv2_return_val := 'GAS';
	ELSIF lv2_well_type like 'WP%' THEN
	  lv2_return_val := 'WAT';
	END IF;

  RETURN lv2_return_val;

END getWellProduct;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateCurveParameter
-- Description    : Procedure for parameter validation
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateCurveParameter(p_segment NUMBER,
                               p_fcst_curve_id NUMBER,
                               p_curve_shape VARCHAR2,
                               p_phase       VARCHAR2,
                               p_input_qi    NUMBER,
                               p_input_b    NUMBER,
                               p_input_di    NUMBER,
                               p_input_ratio    NUMBER)
  --</EC-DOC>
IS

 ln_segment NUMBER;

BEGIN


    IF ( p_input_qi IS NULL AND p_segment = 1 AND p_curve_shape != 'RATIO')
    THEN Raise_Application_Error(-20471,'The value for curve parameter Qi is missing.');
    END IF;

    IF ( p_curve_shape = 'HYPERBOLIC' AND p_input_b IS NULL)
    THEN Raise_Application_Error(-20472,'The value for curve parameter B is missing.');
    END IF;

    IF ( p_curve_shape != 'RATIO' AND p_input_di IS NULL)
    THEN Raise_Application_Error(-20473,'The value for curve parameter Di is missing.');
    END IF;

    IF ( p_curve_shape = 'RATIO' AND p_input_ratio IS NULL)
    THEN Raise_Application_Error(-20476,'The value for curve parameter Ratio is missing.');
    END IF;


END validateCurveParameter;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : deleteChildSegments
-- Description    : Delete child events.
--
--
-- Preconditions  :
-- Postconditions : .
--
-- Using tables   : FCST_PROD_CURVES_SEGMENT
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE deleteChildSegments(p_fcst_curve_id NUMBER)
--</EC-DOC>
 IS

BEGIN

    DELETE FROM FCST_PROD_CURVES_SEGMENT WHERE fcst_curve_id = p_fcst_curve_id;

END deleteChildSegments;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calcForecastVolume
-- Description    : Calculate forecast volume
--
--
-- Preconditions  :
-- Postconditions : .
--
-- Using tables   : FCST_WELL_POTENTIAL, FCST_WELL_EVENT_ALLOC, FCST_SHORTFALL_OVERRIDES, FCST_SHORTFALL_FACTORS, FCST_COMPENSATION_EVENTS, FCST_PWEL_DAY
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------

PROCEDURE calcForecastVolume(p_object_id VARCHAR2,
                      p_start_daytime DATE,
                      p_end_daytime DATE,
                      p_forecast_id VARCHAR2,
                      p_scenario_id VARCHAR2)
IS

 CURSOR c_well_potential( cp_daytime DATE )
 IS
   SELECT OIL_BASE,
          OIL_CONSTRAINT,
          GAS_BASE,
          GAS_CONSTRAINT,
          WAT_BASE,
          WAT_CONSTRAINT,
          COND_BASE,
          COND_CONSTRAINT
   FROM FCST_WELL_POTENTIAL
  WHERE DAYTIME = cp_daytime
    AND OBJECT_ID = p_object_id
    AND FORECAST_ID = p_forecast_id
    AND SCENARIO_ID = p_scenario_id;


 CURSOR c_well_event_alloc ( cp_daytime DATE )
 IS
   SELECT  DEFERRED_NET_OIL_VOL ,
           DEFERRED_GAS_VOL ,
           DEFERRED_WATER_VOL ,
           DEFERRED_COND_VOL
    FROM FCST_WELL_EVENT_ALLOC
   WHERE trunc(DAYTIME) = cp_daytime
     AND OBJECT_ID = p_object_id
     AND EVENT_NO IN (  SELECT EVENT_NO
                          FROM FCST_WELL_EVENT
                         WHERE EVENT_ID = p_object_id
                           AND trunc(DAYTIME) = cp_daytime
                           AND FORECAST_ID = p_forecast_id
                           AND OBJECT_ID = p_scenario_id);

 CURSOR c_well_shortfall_over ( cp_daytime DATE )
 IS
   SELECT OIL_S1P_FACTOR,
          OIL_S1U_FACTOR,
          OIL_S2_FACTOR,
          GAS_S1P_FACTOR,
          GAS_S1U_FACTOR,
          GAS_S2_FACTOR,
          WAT_S1P_FACTOR,
          WAT_S1U_FACTOR,
          WAT_S2_FACTOR,
          COND_S1P_FACTOR,
          COND_S1U_FACTOR,
          COND_S2_FACTOR
     FROM FCST_SHORTFALL_OVERRIDES
    WHERE (DAYTIME <= cp_daytime  AND VALID_TO >= cp_daytime)
      AND OBJECT_ID = p_object_id
      AND FORECAST_ID = p_forecast_id
      AND SCENARIO_ID = p_scenario_id;

CURSOR c_well_shortfall_factor ( cp_daytime DATE )
 IS
   SELECT OIL_S1P_FACTOR,
          OIL_S1U_FACTOR,
          OIL_S2_FACTOR,
          GAS_S1P_FACTOR,
          GAS_S1U_FACTOR,
          GAS_S2_FACTOR,
          WAT_S1P_FACTOR,
          WAT_S1U_FACTOR,
          WAT_S2_FACTOR,
          COND_S1P_FACTOR,
          COND_S1U_FACTOR,
          COND_S2_FACTOR
     FROM FCST_SHORTFALL_FACTORS
    WHERE FORECAST_ID = p_forecast_id
      AND SCENARIO_ID = p_scenario_id
      AND ( FACTOR_ID = ecdp_groups.findParentObjectId('FCTY_CLASS_1','operational','WELL',p_object_id,cp_daytime) OR FACTOR_ID = ecdp_groups.findParentObjectId('FIELD','geographical','WELL',p_object_id,cp_daytime))
      AND DAYTIME = (SELECT max(daytime)
                       FROM FCST_SHORTFALL_FACTORS
                      WHERE (FACTOR_ID = ecdp_groups.findParentObjectId('FCTY_CLASS_1','operational','WELL',p_object_id,cp_daytime) OR FACTOR_ID = ecdp_groups.findParentObjectId('FIELD','geographical','WELL',p_object_id,cp_daytime))
                        AND SCENARIO_ID =  p_scenario_id
                        AND daytime <= cp_daytime);


 CURSOR c_well_compensation ( cp_daytime DATE)
 IS
  SELECT DAYTIME,
          END_DATE,
          OIL_COMP_RATE ,
          OIL_COMP_VOLUME,
          GAS_COMP_RATE,
          GAS_COMP_VOLUME,
          COND_COMP_RATE,
          COND_COMP_VOLUME,
          WATER_COMP_RATE,
          WATER_COMP_VOLUME
   FROM FCST_COMPENSATION_EVENTS
  WHERE OBJECT_ID = p_object_id
    AND FORECAST_ID = p_forecast_id
    AND SCENARIO_ID = p_scenario_id
	AND (DAY = cp_daytime OR (DAY < cp_daytime AND NVL( END_DAY, cp_daytime) >= cp_daytime ) )
    AND NVL(end_date,Ecdp_Productionday.getProductionDayStart('WELL',p_object_id,cp_daytime)+1) <> Ecdp_Productionday.getProductionDayStart('WELL',p_object_id,cp_daytime) 	;


    -- variable declarations
    ln_oil_vol   NUMBER ;
    ln_gas_vol   NUMBER ;
    ln_cond_vol  NUMBER ;
    ln_wat_vol   NUMBER ;
    ln_oil_pot   NUMBER ;
    ln_gas_pot   NUMBER ;
    ln_wat_pot   NUMBER ;
    ln_cond_pot  NUMBER ;
    ln_oil_s1p   NUMBER := 0;
    ln_oil_s1u   NUMBER := 0;
    ln_oil_s2    NUMBER := 0;
    ln_gas_s1p   NUMBER := 0;
    ln_gas_s1u   NUMBER := 0;
    ln_gas_s2    NUMBER := 0;
    ln_wat_s1p   NUMBER := 0;
    ln_wat_s1u   NUMBER := 0;
    ln_wat_s2    NUMBER := 0;
    ln_cond_s1p  NUMBER := 0;
    ln_cond_s1u  NUMBER := 0;
    ln_cond_s2   NUMBER := 0;
    ln_duration  NUMBER := 0;
    ln_oil_comp  NUMBER := 0;
    ln_gas_comp  NUMBER := 0;
    ln_wat_comp  NUMBER := 0;
    ln_cond_comp NUMBER := 0;
    ln_count     NUMBER := 0;
    cur_date     DATE;
    cur_end_date DATE;

BEGIN

    cur_date := p_start_daytime - 1;
    cur_end_date := NVL(p_end_daytime,ec_forecast_group.end_date(p_forecast_id));

    FOR i IN 1..(cur_end_date - cur_date)+1
    LOOP

      FOR well_pot IN c_well_potential(cur_date) -- potential for loop start
      LOOP

        IF well_pot.OIL_CONSTRAINT IS NULL THEN
          ln_oil_pot  := well_pot.OIL_BASE;
        ELSE
          ln_oil_pot  := LEAST(well_pot.OIL_BASE, well_pot.OIL_CONSTRAINT);
        END IF;

        IF well_pot.GAS_CONSTRAINT IS NULL THEN
          ln_gas_pot  := well_pot.GAS_BASE;
        ELSE
          ln_gas_pot  := LEAST(well_pot.GAS_BASE, well_pot.GAS_CONSTRAINT);
        END IF;

        IF well_pot.WAT_CONSTRAINT IS NULL THEN
          ln_wat_pot  := well_pot.WAT_BASE;
        ELSE
          ln_wat_pot  := LEAST(well_pot.WAT_BASE, well_pot.WAT_CONSTRAINT);
        END IF;

        IF well_pot.COND_CONSTRAINT IS NULL THEN
          ln_cond_pot := well_pot.COND_BASE;
        ELSE
          ln_cond_pot := LEAST(well_pot.COND_BASE, well_pot.COND_CONSTRAINT);
        END IF;

        EXIT WHEN c_well_potential%NOTFOUND;

      END LOOP; -- potential for loop end

      IF (ln_oil_pot > 0 OR  ln_gas_pot > 0 OR ln_wat_pot > 0 OR ln_cond_pot > 0 ) THEN  -- potential value check

          SELECT COUNT(*)
            INTO ln_count
            FROM FCST_WELL_EVENT_ALLOC
           WHERE OBJECT_ID = p_object_id
             AND trunc(DAYTIME) = cur_date
             AND EVENT_NO IN (  SELECT EVENT_NO
                                  FROM FCST_WELL_EVENT
                                 WHERE EVENT_ID = p_object_id
                                   AND trunc(DAYTIME) = cur_date
                                   AND FORECAST_ID = p_forecast_id
                                   AND SCENARIO_ID = p_scenario_id);

          IF ln_count > 0 THEN                                                      -- SHORTFALL IF START
            FOR well_event IN c_well_event_alloc(cur_date)                          -- event allocation for loop start
            LOOP
                ln_oil_s1p   := ln_oil_s1p  + well_event.DEFERRED_NET_OIL_VOL;
                ln_gas_s1p   := ln_gas_s1p  + well_event.DEFERRED_GAS_VOL;
                ln_wat_s1p   := ln_wat_s1p  + well_event.DEFERRED_WATER_VOL;
                ln_cond_s1p  := ln_cond_s1p + well_event.DEFERRED_COND_VOL;
                EXIT WHEN c_well_event_alloc%NOTFOUND;
            END LOOP;                                                               -- event allocation for loop end

          ELSE
            ln_count := 0;

            SELECT COUNT(*)
              INTO ln_count
              FROM FCST_SHORTFALL_OVERRIDES
             WHERE OBJECT_ID = p_object_id
               AND (DAYTIME <= cur_date  AND VALID_TO >= cur_date)
               AND FORECAST_ID = p_forecast_id
               AND SCENARIO_ID = p_scenario_id;

            IF ln_count > 0 THEN
                FOR well_shortfall IN c_well_shortfall_over(cur_date)                  --shortfall override for loop start
                LOOP
                    ln_oil_s1p :=  ln_oil_s1p + ln_oil_pot * well_shortfall.OIL_S1P_FACTOR /100 ;
                    ln_oil_s1u :=  ln_oil_s1u + ln_oil_pot * well_shortfall.OIL_S1U_FACTOR /100 ;
                    ln_oil_s2  :=  ln_oil_s2  + ln_oil_pot * well_shortfall.OIL_S2_FACTOR /100  ;
                    ln_gas_s1p :=  ln_gas_s1p + ln_gas_pot * well_shortfall.GAS_S1P_FACTOR /100 ;
                    ln_gas_s1u :=  ln_gas_s1u + ln_gas_pot * well_shortfall.GAS_S1U_FACTOR /100 ;
                    ln_gas_s2  :=  ln_gas_s2  + ln_gas_pot * well_shortfall.GAS_S2_FACTOR /100  ;
                    ln_wat_s1p :=  ln_wat_s1p + ln_wat_pot * well_shortfall.WAT_S1P_FACTOR /100 ;
                    ln_wat_s1u :=  ln_wat_s1u + ln_wat_pot * well_shortfall.WAT_S1U_FACTOR /100 ;
                    ln_wat_s2  :=  ln_wat_s2  + ln_wat_pot * well_shortfall.WAT_S2_FACTOR /100  ;
                    ln_cond_s1p:=  ln_cond_s1p+ ln_cond_pot * well_shortfall.COND_S1P_FACTOR/100;
                    ln_cond_s1u:=  ln_cond_s1u+ ln_cond_pot * well_shortfall.COND_S1U_FACTOR /100;
                    ln_cond_s2 :=  ln_cond_s2 + ln_cond_pot * well_shortfall.COND_S2_FACTOR /100;
                    EXIT WHEN c_well_shortfall_over%NOTFOUND;
                 END LOOP;                                                               --shortfall override for loop end
            ELSE
                FOR well_shortfall_factor IN c_well_shortfall_factor(cur_date)          --shortfall factor loop start
                LOOP
                    ln_oil_s1p :=  ln_oil_pot * well_shortfall_factor.OIL_S1P_FACTOR /100 ;
                    ln_oil_s1u :=  ln_oil_pot * well_shortfall_factor.OIL_S1U_FACTOR /100 ;
                    ln_oil_s2  :=  ln_oil_pot * well_shortfall_factor.OIL_S2_FACTOR /100  ;
                    ln_gas_s1p :=  ln_gas_pot * well_shortfall_factor.GAS_S1P_FACTOR /100 ;
                    ln_gas_s1u :=  ln_gas_pot * well_shortfall_factor.GAS_S1U_FACTOR /100 ;
                    ln_gas_s2  :=  ln_gas_pot * well_shortfall_factor.GAS_S2_FACTOR /100  ;
                    ln_wat_s1p :=  ln_wat_pot * well_shortfall_factor.WAT_S1P_FACTOR /100 ;
                    ln_wat_s1u :=  ln_wat_pot * well_shortfall_factor.WAT_S1U_FACTOR /100 ;
                    ln_wat_s2  :=  ln_wat_pot * well_shortfall_factor.WAT_S2_FACTOR /100  ;
                    ln_cond_s1p:=  ln_cond_pot * well_shortfall_factor.COND_S1P_FACTOR/100;
                    ln_cond_s1u:=  ln_cond_pot * well_shortfall_factor.COND_S1U_FACTOR /100;
                    ln_cond_s2 :=  ln_cond_pot * well_shortfall_factor.COND_S2_FACTOR /100;
                    EXIT WHEN c_well_shortfall_factor%NOTFOUND;
                END LOOP;                                                                --shortfall factor loop end
            END IF;
          END IF;                                                                        -- SHORTFALL If END

          FOR well_comp IN c_well_compensation(cur_date) -- for loop compensation start
          LOOP
                ln_duration := NVL(well_comp.END_DATE,EcDp_Date_Time.getCurrentSysdate + EcDp_ProductionDay.getProductionDayOffset(ecdp_objects.GetObjClassName(p_object_id), p_object_id, cur_date)/24) - well_comp.DAYTIME;

                IF ln_duration > 0 THEN
                    IF well_comp.OIL_COMP_VOLUME > 0 THEN
                    ln_oil_comp := ln_oil_comp + well_comp.OIL_COMP_VOLUME/ln_duration;
                    ELSE
                      ln_oil_comp := ln_oil_comp + well_comp.OIL_COMP_RATE;
                    END IF;

                    IF well_comp.GAS_COMP_VOLUME > 0 THEN
                      ln_gas_comp := ln_gas_comp + well_comp.GAS_COMP_VOLUME/ln_duration;
                    ELSE
                      ln_gas_comp := ln_gas_comp + well_comp.GAS_COMP_RATE;
                    END IF;

                    IF well_comp.WATER_COMP_VOLUME > 0 THEN
                      ln_wat_comp := ln_wat_comp + well_comp.WATER_COMP_VOLUME/ln_duration;
                    ELSE
                      ln_wat_comp := ln_wat_comp + well_comp.WATER_COMP_RATE;
                    END IF;

                     IF well_comp.COND_COMP_VOLUME > 0 THEN
                      ln_cond_comp := ln_cond_comp + well_comp.COND_COMP_VOLUME/ln_duration;
                    ELSE
                      ln_cond_comp := ln_cond_comp + well_comp.COND_COMP_RATE;
                    END IF;
                 END IF;
                EXIT WHEN c_well_compensation%NOTFOUND;
           END LOOP;  -- for loop compensation end

        END IF ; -- potential value check

        ln_count := 0;  -- reset value

        SELECT COUNT(*)
        INTO   ln_count
        FROM   FCST_PWEL_DAY
        WHERE  OBJECT_ID   = p_object_id
        AND    DAYTIME     = cur_date
        AND    FORECAST_ID = p_forecast_id
        AND    SCENARIO_ID = p_scenario_id;

        ln_oil_vol := ln_oil_pot  - NVL(ln_oil_s1p,0)  - NVL(ln_oil_s1u,0)  - NVL(ln_oil_s2,0)  + NVL(ln_oil_comp,0) ;
        ln_gas_vol := ln_gas_pot  - NVL(ln_gas_s1p,0)  - NVL(ln_gas_s1u,0)  - NVL(ln_gas_s2,0)  + NVL(ln_gas_comp,0) ;
        ln_wat_vol := ln_wat_pot  - NVL(ln_wat_s1p,0)  - NVL(ln_wat_s1u,0)  - NVL(ln_wat_s2,0)  + NVL(ln_wat_comp,0) ;
        ln_cond_vol:= ln_cond_pot - NVL(ln_cond_s1p,0) - NVL(ln_cond_s1u,0) - NVL(ln_cond_s2,0) + NVL(ln_cond_comp,0);

        IF ln_count > 0 THEN
            UPDATE FCST_PWEL_DAY
            SET    NET_OIL_RATE = ln_oil_vol,
                   GAS_RATE     = ln_gas_vol,
                   COND_RATE    = ln_cond_vol,
                   WATER_RATE   = ln_wat_vol,
                   LAST_UPDATED_BY   = NVL(ECDP_CONTEXT.getAppUser(),USER),
                   LAST_UPDATED_DATE = ECDP_DATE_TIME.getCurrentSysdate()
            WHERE  OBJECT_ID = p_object_id
            AND    DAYTIME = cur_date
            AND    FORECAST_ID = p_forecast_id
            AND    SCENARIO_ID = p_scenario_id;
        ELSE
            INSERT INTO FCST_PWEL_DAY(OBJECT_ID, DAYTIME, FORECAST_ID, SCENARIO_ID, NET_OIL_RATE, GAS_RATE, WATER_RATE, COND_RATE, CREATED_BY, CREATED_DATE)
            VALUES (p_object_id, cur_date, p_forecast_id, p_scenario_id, ln_oil_vol, ln_gas_vol, ln_wat_vol, ln_cond_vol,NVL(ecdp_context.getAppUser(),USER), ECDP_DATE_TIME.getCurrentSysdate());
        END IF;

        cur_date      := cur_date + 1;
        ln_oil_vol    := NULL;
        ln_gas_vol    := NULL;
        ln_cond_vol   := NULL;
        ln_wat_vol    := NULL;
        ln_oil_pot    := NULL;
        ln_gas_pot    := NULL;
        ln_wat_pot    := NULL;
        ln_cond_pot   := NULL;
        ln_oil_s1p    := 0;
        ln_oil_s1u    := 0;
        ln_oil_s2     := 0;
        ln_gas_s1p    := 0;
        ln_gas_s1u    := 0;
        ln_gas_s2     := 0;
        ln_wat_s1p    := 0;
        ln_wat_s1u    := 0;
        ln_wat_s2     := 0;
        ln_cond_s1p   := 0;
        ln_cond_s1u   := 0;
        ln_cond_s2    := 0;
        ln_duration   := 0;
        ln_oil_comp   := 0;
        ln_gas_comp   := 0;
        ln_wat_comp   := 0;
        ln_cond_comp  := 0;
        ln_count      := 0;

    END LOOP; -- end of date range loop

EXCEPTION
        WHEN OTHERS
               THEN RAISE_APPLICATION_ERROR(-20482,'The error occured in Forecast Volume Calculation due to incomplete data.');

END calcForecastVolume  ; -- END OF procedure

END EcDp_Forecast_Curve;