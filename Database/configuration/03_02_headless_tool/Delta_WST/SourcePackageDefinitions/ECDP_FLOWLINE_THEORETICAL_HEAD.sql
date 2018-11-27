CREATE OR REPLACE PACKAGE EcDp_Flowline_Theoretical IS

/****************************************************************
** Package        :  EcDp_Flowline_Theoretical, header part
**
** $Revision: 1.8 $
**
** Purpose        :  Calculates theoretical flowline values (rates etc)
**
** Documentation  :  www.energy-components.com
**
** Created  :
**
** Modification history:
**
** Version  Date       Whom     Change description:
** -------  ------     -----    --------------------------------------
**          28-01-2011 leongwen ECDP-16729: To correct and enhance the screens which are affected by the changes made in ECPD-16525.
**          14-04-2014 leongwen ECDP-22866: Applied the calculation methods for multiple phases Flowline Performance Curve based on the similar logic from Well Performance Curve.
*****************************************************************/

--

-- Used to pass paremeters to getCurveStdRate and getCurveParamValue
TYPE PerfCurveParamRec IS RECORD (
	choke_size 		  NUMBER,
	flwl_press 		  NUMBER,
	flwl_temp 		  NUMBER,
	flwl_usc_press 	NUMBER,
	flwl_usc_temp 	NUMBER,
	flwl_dsc_press 	NUMBER,
	flwl_dsc_temp 	NUMBER,
	mpm_oil_rate 	  NUMBER,
	mpm_gas_rate 	  NUMBER,
	mpm_water_rate 	NUMBER,
	mpm_cond_rate 	NUMBER
);


FUNCTION getCondensateGasRatio(
  p_object_id               flowline.object_id%TYPE,
  p_daytime                 DATE,
  p_phase                   VARCHAR2,
  p_calc_method             VARCHAR2,
  p_class_name              VARCHAR2  DEFAULT NULL)

RETURN NUMBER;

--

FUNCTION getGasOilRatio(
  p_object_id flowline.object_id%TYPE,
  p_daytime  DATE,
  p_phase VARCHAR2,
  p_calc_method VARCHAR2,
  p_class_name VARCHAR2 DEFAULT NULL,
  p_result_no NUMBER DEFAULT NULL)

RETURN NUMBER;

--

FUNCTION getLowPressureGasOilRatio(
  p_object_id flowline.object_id%TYPE,
	p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION getPerformanceCurveId(
        p_object_id flowline.object_id%TYPE,
        p_daytime  DATE,
        p_curve_purpose VARCHAR2,
        p_phase VARCHAR2,
        p_calc_method VARCHAR2 DEFAULT NULL) RETURN NUMBER;

--

FUNCTION getNextPerformanceCurveId(
        p_object_id flowline.object_id%TYPE,
        p_daytime  DATE,
        p_curve_purpose VARCHAR2,
        p_phase VARCHAR2,
        p_calc_method VARCHAR2 DEFAULT NULL) RETURN NUMBER;
--

FUNCTION getWaterCutPct(
  p_object_id flowline.object_id%TYPE,
  p_daytime	 DATE,
  p_phase VARCHAR2,
  p_calc_method VARCHAR2,
  p_class_name VARCHAR2 DEFAULT NULL,
  p_result_no NUMBER DEFAULT NULL)

RETURN NUMBER;

--

FUNCTION getWaterGasRatio(
  p_object_id flowline.object_id%TYPE,
  p_daytime	 DATE,
  p_phase VARCHAR2,
  p_calc_method VARCHAR2,
  p_class_name VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

--

FUNCTION getflowlineCurveParameterCode(
  p_object_id flowline.object_id%TYPE,
  p_daytime    DATE,
  p_phase VARCHAR2 DEFAULT 'OIL') RETURN VARCHAR2;

--

FUNCTION getCurveParamValue(
   p_object_id flowline.object_id%TYPE,
   p_daytime        DATE,
   p_param_code     VARCHAR2,
   p_param_values   PerfCurveParamRec
)
RETURN NUMBER;

--

FUNCTION getCurveStdRate(
   p_object_id flowline.object_id%TYPE,
   p_daytime        DATE,
   p_curve_purpose  VARCHAR2,
   p_phase          VARCHAR2,
   p_param_values   PerfCurveParamRec,
   p_calc_method VARCHAR2 DEFAULT NULL
) RETURN NUMBER;

--

PROCEDURE populateCurveParameterValues (
 p_object_id VARCHAR2,
 p_daytime DATE,
 p_class_name VARCHAR2,
 p_param_values OUT PerfCurveParamRec,
 p_result_no NUMBER DEFAULT NULL
);


END EcDp_Flowline_Theoretical;