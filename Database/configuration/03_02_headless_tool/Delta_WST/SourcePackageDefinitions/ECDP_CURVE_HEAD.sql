CREATE OR REPLACE PACKAGE EcDp_Curve IS
/****************************************************************
** Package        :  EcDp_Curve, header part
**
** $Revision: 1.18 $
**
** Purpose        :  Provide basic functions on curves
**
** Documentation  :  www.energy-components.com
**
** Created  : 01.05.2000  Arild Vervik
**
** Modification history:
**
** Version  Date     Whom  	Change description:
** -------  ------   ----- 	--------------------------------------
** 4.1      22.06.00 AV    	Added support for Polynomial curves of order 2
** 4.1.     14.07.00 AV    	Added function calculateFormula
** 4.1      22.09.00 CFS   	Moved all constant functions to EcDp_Curve_Constant
** 								Changed functions to procedures where no functional
**                         	logic is performed.
** 4.2      12.12.00 PGI   	Added function getPointNo
** 4.3      14.12.01 SVN   	Added function CurveFit3Point
**          08.01.04 BIH   	Added procedure curveFitLinearLS
**          08.01.04 BIH   	Added procedure curveFitPoly2LS
**          05.03.04 BIH   	Moved curveFitLinearLS and curveFitPoly2LS to EcBp_Mathlib
**                         	! Cleared package !
**                         	Added procedure curveFit and function getYfromX that supports new database model
**                         	(from EnergyX 7.3)
**          05.04.04 BIH   	Fixed bug where the wrong y was selected for inverse polynomial curves with c2<0 (#994)
**          16.04.04 BIH   	Curve point formula type extrapolates values beyond the first and last points (tracker 989)
**          24.08.06 MOT   	Added getRatioOrWcfromX to get GOR, WC etc from the curve (tracker 1597)
**	    31.08.10 madondin	Added 1 new function getMeasurementType to get x and y measurement type
**          15.08.11 rajarsar ECPD:18305-Added parameter phase for getPreviousPerfCurve
**			21.09.11 madondin ECPD:18467 added new function getYfromXGraph for rendering graph with conversion from dbunit to screenunit
**							  and revert the getYfromX to use the old one which without conversion in order to get correct Volume  in Daily well
*****************************************************************/

PROCEDURE curveFit(p_curve_id NUMBER);

PROCEDURE moveCurvePoints(p_curve_id NUMBER, p_x NUMBER, p_y NUMBER);

PROCEDURE moveCurve(p_curve_id NUMBER, p_x NUMBER, p_y NUMBER);

PROCEDURE addCurvePoint(p_curve_id NUMBER, p_x NUMBER, p_y NUMBER, p_gor NUMBER, p_cgr NUMBER, p_wgr NUMBER, p_watercut_pct NUMBER);

FUNCTION getYfromX(p_curve_id NUMBER, p_x_value NUMBER) RETURN NUMBER;

FUNCTION getYfromXGraph(p_curve_id NUMBER, p_x_value NUMBER) RETURN NUMBER;

FUNCTION getRatioOrWcfromX(p_curve_id NUMBER, p_x_value NUMBER, p_constant_type VARCHAR2) RETURN NUMBER;
--

FUNCTION getPreviousPerfCurve(p_perf_curve_id NUMBER, p_phase VARCHAR2 DEFAULT NULL) RETURN NUMBER;

--
FUNCTION getMeasurementType(p_curve_id NUMBER, p_curve_axis VARCHAR2) RETURN VARCHAR2;

--



END EcDp_Curve;