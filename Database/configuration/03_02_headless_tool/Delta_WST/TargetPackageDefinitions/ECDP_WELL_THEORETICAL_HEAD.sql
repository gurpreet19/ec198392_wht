CREATE OR REPLACE PACKAGE EcDp_Well_Theoretical IS

/****************************************************************
** Package        :  EcDp_Well_Theoretical, header part
**
** $Revision: 1.21.2.4 $
**
** Purpose        :  Calculates theoretical well values (rates etc)
**
** Documentation  :  www.energy-components.com
**
** Created  : 02.03.2000  Dagfinn Nj?
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
** 1.1      09.05.00 AV    Added new function getPreformanceCurveId
** 4.1      13.09.00 DN    Removed obsolete function findIndicatedCurveValue.
** 4.2      17.10.00 TeJ   Added function findRepresentativeBhp
** 4.3      18.09.00 GNO   New function findRepresentativeDSCPress
** 4.3      26.09.00 ØJ	   Added : findRepresentativeChokeSizeNat
** 4.4      26.11.01 DN    New function getNextWellPerformanceCurve.
******
*           05.03.04 BIH   Rewrote getPerformanceCurveId to use new EcDp_Performance_Curve
*                          Rewrote getNextWellPerformanceCurve and renamed it to getNextPerformanceCurveId
*                          Removed getLastPerformanceCurve since it was a duplicate of getPerformanceCurveId
*                          Renamed getWaterGasRatio to getGasWaterRatio to match new database model
*                          Added getCurveStdRate and getCurveParamValue
*                          Added type PerfCurveParamRec
*                          Removed code for features that are no longer supported by the performance curves
*                          (trying to use this code now throws an exception).
*                          Removed getCurveChokeFromStdRate and getCurveWhpFromStdRate
*                           removed sysnam and update as necessary
*	    04.03.05 kaurrnar	Removed findRepresentativeGasStdRate, getGasOilRatio and getCurveStdRate function
*	    07.03.05 kaurrnar	Added getGasOilRatio and getCurveStdRate function
*      22.03.2005 DN       Removed obsolete function getOilStdQtyDayValidTest
**     29.03.2005 SHN      Removed obsolete functions: findRepresentativeOilStdRate,findRepresentativeDSCPress,
**									findRepresentativeChokeSize,findRepresentativeOilStdRate,findRepresentativeValidDate
**									findRepresentativeWatStdRate,findRepresentativeWhp,findRepresentativeBhp
**     18.04.2005 Toha     TI 1940: added avg_gl_diff_press to record PerfCurveParamRec
**     05.04.2006 johanein T#3670.  PrefCurveParamRec expanded inorder to cater for new curve input parameters
**     29.08.2006 ottermag Tracker1597: Rename findGasCondRatio to findCondGasRatio.
**     29.08.2006 ottermag Tracker #1597: Remove interpolateGasOilRatio (not used).
**	   03.12.2007 oonnnng  ECPD-6541: Add avg_flow_mass attribute to record variable PerfCurveParamRec.
**     23-12-2010 leongwen ECDP-11637: Well Performance Curve should accept more than one curve.
**     02.09.2011 rajarsar ECPD-18018: Updated getPerformanceCurveId,getNextPerformanceCurveId and getCurveStdRate to add p_calc_method as passing parameter.
**     17-11-2011 leongwen ECPD-18170: Updated getCondensateGasRatio, getCondensateGasRatio, getGasOilRatio, getWaterCutPct, getWaterGasRatio
**                                     with new parameters of p_phase and p_calc_method.
**     19-01-2012 rajarsar ECPD-19447: Updated getWaterOilRatio with new parameters of p_phase and p_calc_method.
**	   08-10-2012 kumarsur ECPD-22074: Added populateCurveParameterValues
**     28-06-2013 musthram ECPD-24533: Modified function populateCurveParameterValues, getWaterCutPct, getGasOilRatio
** 	   22.11.2013 kumarsur ECPD-26104: Modified PerfCurveParamRec added phase_current,ac_frequency and intake_press.
** 	   02.12.2013 makkkkam ECPD-25991: Modified PerfCurveParamRec added mpm_oil_rate,mpm_gas_rate,mpm_water_rate and mpm_cond_rate.
*****************************************************************/

--

-- Used to pass paremeters to getCurveStdRate and getCurveParamValue
TYPE PerfCurveParamRec IS RECORD (
   choke_size          NUMBER,
   wh_press            NUMBER,
   wh_temp             NUMBER,
   bh_press            NUMBER,
   annulus_press       NUMBER,
   wh_usc_press        NUMBER,
   wh_dsc_press        NUMBER,
   bs_w                NUMBER,
   dh_pump_rpm         NUMBER,
   gl_choke            NUMBER,
   gl_press            NUMBER,
   gl_rate             NUMBER,
   gl_diff_press       NUMBER,
   avg_flow_mass       NUMBER,
   phase_current       NUMBER,
   ac_frequency       NUMBER,
   intake_press        NUMBER,
   mpm_oil_rate	       NUMBER,
   mpm_gas_rate	       NUMBER,
   mpm_water_rate	   NUMBER,
   mpm_cond_rate	   NUMBER
);


FUNCTION getCondensateGasRatio(
  p_object_id well.object_id%TYPE,
	p_daytime  DATE,
  p_phase VARCHAR2,
  p_calc_method VARCHAR2,
  p_class_name VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getCondensateGasRatio, WNDS, WNPS, RNPS);

--

FUNCTION getGasOilRatio(
  p_object_id well.object_id%TYPE,
	p_daytime  DATE,
  p_phase VARCHAR2,
  p_calc_method VARCHAR2,
  p_class_name VARCHAR2 DEFAULT NULL,
  p_result_no NUMBER DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getGasOilRatio, WNDS, WNPS, RNPS);

--
FUNCTION getWaterOilRatio(
  p_object_id well.object_id%TYPE,
  p_daytime  DATE,
  p_phase VARCHAR2,
  p_calc_method VARCHAR2,
  p_class_name VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getWaterOilRatio, WNDS, WNPS, RNPS);

--

FUNCTION getLowPressureGasOilRatio(
  p_object_id well.object_id%TYPE,
	p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getLowPressureGasOilRatio, WNDS, WNPS, RNPS);

--


FUNCTION getPerformanceCurveId(
        p_object_id well.object_id%TYPE,
        p_daytime  DATE,
        p_curve_purpose VARCHAR2,
        p_phase VARCHAR2,
        p_calc_method VARCHAR2 DEFAULT NULL) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getPerformanceCurveId, WNDS, WNPS, RNPS);

--

FUNCTION getNextPerformanceCurveId(
        p_object_id well.object_id%TYPE,
        p_daytime  DATE,
        p_curve_purpose VARCHAR2,
        p_phase VARCHAR2,
        p_calc_method VARCHAR2 DEFAULT NULL) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getNextPerformanceCurveId, WNDS, WNPS, RNPS);

--

FUNCTION getWaterCutPct(
  p_object_id well.object_id%TYPE,
  p_daytime	 DATE,
  p_phase VARCHAR2,
  p_calc_method VARCHAR2,
  p_class_name VARCHAR2 DEFAULT NULL,
  p_result_no NUMBER DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getWaterCutPct, WNDS, WNPS, RNPS);

--

FUNCTION getWaterGasRatio(
  p_object_id well.object_id%TYPE,
	p_daytime	 DATE,
  p_phase VARCHAR2,
  p_calc_method VARCHAR2,
  p_class_name VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getWaterGasRatio, WNDS, WNPS, RNPS);

--

FUNCTION getWellCurveParameterCode(
  p_object_id well.object_id%TYPE,
	p_daytime    DATE,
  p_phase VARCHAR2 DEFAULT 'OIL') RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (getWellCurveParameterCode, WNDS,WNPS, RNPS);

--

FUNCTION getCurveParamValue(
   p_object_id well.object_id%TYPE,
   p_daytime        DATE,
   p_param_code     VARCHAR2,
   p_param_values   PerfCurveParamRec
)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getCurveParamValue, WNDS,WNPS, RNPS);

--

FUNCTION getCurveStdRate(
   p_object_id well.object_id%TYPE,
   p_daytime        DATE,
   p_curve_purpose  VARCHAR2,
   p_phase          VARCHAR2,
   p_param_values   PerfCurveParamRec,
   p_calc_method VARCHAR2 DEFAULT NULL
) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getCurveStdRate, WNDS, WNPS, RNPS);

--

PROCEDURE populateCurveParameterValues (
 p_object_id VARCHAR2,
 p_daytime DATE,
 p_class_name VARCHAR2,
 p_param_values OUT PerfCurveParamRec,
 p_result_no NUMBER DEFAULT NULL
);
PRAGMA RESTRICT_REFERENCES (populateCurveParameterValues, WNDS, WNPS, RNPS);


END EcDp_Well_Theoretical;