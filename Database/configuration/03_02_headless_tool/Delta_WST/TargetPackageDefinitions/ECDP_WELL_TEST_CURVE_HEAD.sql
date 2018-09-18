CREATE OR REPLACE PACKAGE EcDp_Well_Test_Curve IS
/******************************************************************************
** Package        :  EcDp_Well_Test_Curve, header part
**
** $Revision: 1.5 $
**
** Purpose        :  Business logic for trending curves for well test results for the PT module.
**
** Documentation  :  www.energy-components.com
**
** Created  : 25.08.2005 Ron Boh
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- -------------------------------------------
** 01.10.2007  zakiiari    ECPD-5765: - Added extra parameter to getYfromX
**                                    - Added getTrendSegmentStartDaytime, trendCurveRowCount, copyTrendSegment, convertLnToExp, acceptTestResult, rejectTestResult
********************************************************************/

PROCEDURE analyzeTrend(p_object_id VARCHAR2, p_result_no NUMBER, p_focus_date DATE, p_from_daytime DATE, p_to_daytime DATE, p_user VARCHAR2);

FUNCTION getYfromX(p_x_value NUMBER, p_c0 NUMBER, p_c1 NUMBER, p_trend_method VARCHAR2) RETURN NUMBER;

FUNCTION trendSegmentRowCount(p_object_id VARCHAR2, p_from_daytime DATE, p_to_daytime DATE, p_min_daytime DATE, p_max_daytime DATE) RETURN NUMBER;

PROCEDURE trendSegmentRowCountCheck(p_object_id VARCHAR2, p_focus_date DATE, p_from_daytime DATE, p_to_daytime DATE);

FUNCTION getTrendSegmentStartDaytime(p_object_id VARCHAR2, p_focus_date DATE, p_from_daytime DATE, p_to_daytime DATE) RETURN DATE;
PRAGMA RESTRICT_REFERENCES (getTrendSegmentStartDaytime, WNDS, WNPS, RNPS);

FUNCTION trendCurveRowCount(p_object_id VARCHAR2, p_focus_date DATE, p_from_daytime DATE, p_to_daytime DATE) RETURN NUMBER;

PROCEDURE copyTrendSegment(p_object_id VARCHAR2, p_focus_date DATE, p_from_daytime DATE, p_to_daytime DATE, p_user VARCHAR2);

FUNCTION convertLnToExp(p_point_list Ecbp_Mathlib.Ec_discrete_func_type) RETURN Ecbp_Mathlib.Ec_discrete_func_type;

PROCEDURE acceptTestResult(p_result_no NUMBER, p_user VARCHAR2);

PROCEDURE rejectTestResult(p_result_no NUMBER, p_user VARCHAR2);

END EcDp_Well_Test_Curve;