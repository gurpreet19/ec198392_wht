CREATE OR REPLACE PACKAGE EcDp_Flowline_Theoretical IS

/****************************************************************
** Package        :  EcDp_Flowline_Theoretical, header part
**
** $Revision: 1.7 $
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
*****************************************************************/

--

-- Used to pass paremeters to getCurveStdRate and getCurveParamValue
TYPE PerfCurveParamRec IS RECORD (
	avg_choke_size 		NUMBER,
	avg_flwl_press 		NUMBER,
	avg_flwl_temp 		NUMBER,
	avg_flwl_usc_press 	NUMBER,
	avg_flwl_usc_temp 	NUMBER,
	avg_flwl_dsc_press 	NUMBER,
	avg_flwl_dsc_temp 	NUMBER,
	avg_mpm_oil_rate 	NUMBER,
	avg_mpm_gas_rate 	NUMBER,
	avg_mpm_water_rate 	NUMBER,
	avg_mpm_cond_rate 	NUMBER
);


FUNCTION getCondensateGasRatio(
  p_object_id flowline.object_id%TYPE,
	p_day DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getCondensateGasRatio, WNDS, WNPS, RNPS);

--

FUNCTION getGasOilRatio(
  p_object_id flowline.object_id%TYPE,
	p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getGasOilRatio, WNDS, WNPS, RNPS);

--

FUNCTION getLowPressureGasOilRatio(
  p_object_id flowline.object_id%TYPE,
	p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getLowPressureGasOilRatio, WNDS, WNPS, RNPS);

--

FUNCTION getPerformanceCurveId(
        p_object_id flowline.object_id%TYPE,
        p_daytime  DATE,
        p_curve_purpose VARCHAR2,
        p_phase VARCHAR2) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getPerformanceCurveId, WNDS, WNPS, RNPS);

--

FUNCTION getNextPerformanceCurveId(
        p_object_id flowline.object_id%TYPE,
        p_daytime  DATE,
        p_curve_purpose VARCHAR2,
        p_phase VARCHAR2) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getNextPerformanceCurveId, WNDS, WNPS, RNPS);
--

FUNCTION getWaterCutPct(
  p_object_id flowline.object_id%TYPE,
	p_daytime	 DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getWaterCutPct, WNDS, WNPS, RNPS);

--

FUNCTION getWaterGasRatio(
  p_object_id flowline.object_id%TYPE,
	p_daytime	 DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getWaterGasRatio, WNDS, WNPS, RNPS);

--

FUNCTION getflowlineCurveParameterCode(
  p_object_id flowline.object_id%TYPE,
	p_daytime    DATE,
  p_phase VARCHAR2 DEFAULT 'OIL') RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (getflowlineCurveParameterCode, WNDS,WNPS, RNPS);

--

FUNCTION getCurveParamValue(
   p_object_id flowline.object_id%TYPE,
   p_daytime        DATE,
   p_param_code     VARCHAR2,
   p_param_values   PerfCurveParamRec
)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getCurveParamValue, WNDS,WNPS, RNPS);

--

FUNCTION getCurveStdRate(
   p_object_id flowline.object_id%TYPE,
   p_daytime        DATE,
   p_curve_purpose  VARCHAR2,
   p_phase          VARCHAR2,
   p_param_values   PerfCurveParamRec
) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getCurveStdRate, WNDS, WNPS, RNPS);

--

END EcDp_Flowline_Theoretical;