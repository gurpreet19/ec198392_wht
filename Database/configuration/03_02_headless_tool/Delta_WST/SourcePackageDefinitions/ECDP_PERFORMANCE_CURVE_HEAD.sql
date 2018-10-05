CREATE OR REPLACE PACKAGE EcDp_Performance_Curve IS
/****************************************************************
** Package        :  EcDp_Performance_Curve, header part
**
** $Revision: 1.10 $
**
** Purpose        :  Provide service layer for Performance curves
**
** Documentation  :  www.energy-components.com
**
** Created  : 28.04.2000  Arild vervik
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
**  4.1     07.07.00 AV    Added functions UpdateCurveSegment,
**                         InsertCurvesegment and delete curvesegment
**  4.1     14.07.00 AV    Added function OverruleCurvePhase
**                         Introduced curve_parameter_axis as a new column in performance_curve
**                         NB! Database change for this must be in place for this package to compile
**  4.2     10.08.00 AV    Extended InsertCurvePoint to allow several X-axis
**                         for a performance curve. That means several
**                         physicla curves for one logical performance curve
**          16.08.00 AV    Added function InsertFlowlineCurve
**  4.2     22.09.00 CFS   Moved all constant functions to EcDp_Curve_Constant.
**  4.3     03.10.00 DN    3 new subprocedures to maintain well_perf_curve_table. Forced revision to match body.
**  4.4     09.11.00 BF    Added procedures: deleteFlowlineCurve, updateFlowlineCurve.
***********
**          05.03.04 BIH   ! Cleared package !
**                         Added getWellPerformanceCurveId, getNextWellPerformanceCurveId,
**                         getStdRateFromParamValue and copyPerformanceCurve that supports new database model
**                         (from EnergyX 7.3)
**
**          23.12.05       AV    Tracker 2288, Added new support function getPrevWellPerformanceCurveId
**          29-12-10       Leongwen ecpd-11637 Well Performance Curve should accept more than one curve pr Valid From date
**     	    02.09.2011 	   rajarsar ECPD-18018: Updated getWellPerformanceCurveId,getNextWellPerformanceCurveId,getPrevWellPerformanceCurveId and getCurveStdRate to add p_calc_method as passing parameter.
**          03.08.2017     leongwen ECPD-46335: Added procedure perfCurveStatusUpdate to update the 'record status' of performance curve, curve and curve_point tables after changing the 'perf curve status' at performance curve.
*****************************************************************/

FUNCTION getWellPerformanceCurveId(
                        p_curve_object_id VARCHAR2,
                        p_daytime DATE,
                        p_curve_purpose VARCHAR2,
                        p_phase VARCHAR2 DEFAULT NULL,
                        p_calc_method VARCHAR2 DEFAULT NULL
) RETURN NUMBER;

--

FUNCTION getNextWellPerformanceCurveId(
                        p_curve_object_id VARCHAR2,
                        p_daytime DATE,
                        p_curve_purpose VARCHAR2,
                        p_phase VARCHAR2 DEFAULT NULL,
                        p_calc_method VARCHAR2 DEFAULT NULL
) RETURN NUMBER;

--
FUNCTION getPrevWellPerformanceCurveId(
                        p_curve_object_id VARCHAR2,
                        p_daytime DATE,
                        p_curve_purpose VARCHAR2,
                        p_phase VARCHAR2 DEFAULT NULL,
                        p_calc_method VARCHAR2 DEFAULT NULL
) RETURN NUMBER;
--



FUNCTION getStdRateFromParamValue(
                        p_perf_curve_id NUMBER,
                        p_phase VARCHAR2,
                        p_param_value NUMBER,
                        p_third_axis_value NUMBER
) RETURN NUMBER;

--

FUNCTION getCurveIdPhase(
                        p_curve_object_id VARCHAR2,
                        p_daytime DATE,
                        p_curve_purpose VARCHAR2,
                        p_phase VARCHAR2,
                        p_calc_method VARCHAR2 DEFAULT NULL
) RETURN VARCHAR2;

--


PROCEDURE copyPerformanceCurve(p_src_perf_curve_id NUMBER, p_phase VARCHAR2 DEFAULT NULL);

--

PROCEDURE perfCurveStatusUpdate(p_curve_object_id     VARCHAR2,
                                p_daytime             DATE,
                                p_curve_purpose       VARCHAR2,
                                p_phase               VARCHAR2,
                                p_user_id             VARCHAR2 DEFAULT NULL);

END EcDp_Performance_Curve;