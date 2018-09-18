CREATE OR REPLACE PACKAGE EcDp_Forecast_Curve IS
/****************************************************************
** Package        :  EcDp_Forecast_Curve
**
** $Revision: 1.14 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Well Production Curves and Scenario Curves.
**
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
** 28.02.2018   kashisag ECDP-53209: Added new procedure for parameter validation
** 12.03.2018   kashisag ECDP-53209: Added new procedure for deleting segments
** 21.03.2018   kashisag ECPD-40985: Added new procedure for forecast volume calculation
*****************************************************************/

FUNCTION getSegmentNo(p_fcst_curve_id NUMBER, p_phase VARCHAR2) RETURN NUMBER;

FUNCTION segmentDaytime(p_fcst_curve_id NUMBER, p_phase VARCHAR2, p_segment NUMBER) RETURN DATE;

FUNCTION segmentEndDate(p_fcst_curve_id NUMBER, p_phase VARCHAR2, p_segment NUMBER) RETURN DATE;

FUNCTION checkMandatoryTf(p_fcst_curve_id NUMBER, p_phase VARCHAR2) RETURN NUMBER;

PROCEDURE setSegmentNo(p_fcst_curve_id NUMBER, p_phase VARCHAR2, p_segment NUMBER, p_user VARCHAR2);

FUNCTION isEditableQi(p_fcst_curve_id NUMBER, p_phase VARCHAR2, p_segment NUMBER, p_curve_shape VARCHAR2) RETURN VARCHAR2;

PROCEDURE setB(p_fcst_segment_id NUMBER, p_user VARCHAR2);

FUNCTION getSortOrder(p_fcst_curve_id NUMBER, p_fcst_segment_id NUMBER) RETURN NUMBER;

PROCEDURE validateSegmentEndDate(p_fcst_curve_id NUMBER, p_phase VARCHAR2, p_segment VARCHAR2, p_tf NUMBER);

PROCEDURE validateCurveEndDate(p_fcst_curve_id NUMBER, p_curve_end_date DATE);

FUNCTION getWellProduct(p_fcst_curve_id NUMBER) RETURN VARCHAR2;

PROCEDURE validateCurveParameter(p_segment NUMBER, p_fcst_curve_id NUMBER, p_curve_shape VARCHAR2, p_phase  VARCHAR2, p_input_qi   NUMBER,  p_input_b  NUMBER, p_input_di  NUMBER, p_input_ratio  NUMBER);

PROCEDURE deleteChildSegments(p_fcst_curve_id NUMBER);

PROCEDURE calcForecastVolume(p_object_id VARCHAR2, p_start_daytime DATE,p_end_daytime DATE,p_forecast_id VARCHAR2, p_scenario_id VARCHAR2);

END EcDp_Forecast_Curve;