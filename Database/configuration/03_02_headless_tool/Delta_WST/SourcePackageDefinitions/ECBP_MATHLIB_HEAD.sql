CREATE OR REPLACE PACKAGE EcBp_Mathlib IS
/***********************************************************************
** Package	      :  EcBp_Mathlib
**
** $Revision: 1.6 $
**
** Purpose	      :  Provide functions related mathematical calculations
**
**
** Documentation  :  www.energy-components.com
**
** Created  : 21.01.2000  Carl-Fredrik S?sen
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
** 1.0   	21.01.00  CFS   Initial version
** 3.0      09.10.00  DN   Added linear regression procedure.
*******
**          04.02.04  BIH  Added least squares curve fit procedures (curveFitLinearLS and curveFitPoly2LS)
**          11.02.04  BIH  Added function interpolateLinearBoundary
**        02.10.2007  zakiiari  ECPD-5765: Added procedure calcCorrelationCoefficient
**        20.05.2010  Toha  ECPD-13372: Added generic 2 dimensional array. Added curveFitPoly3LS
**        23.02.2017  choooshu  ECPD-32359: Added curveFitPoly4LS to support 4th order polynomial calculation
***************************************************************************/

TYPE Ec_point IS RECORD (
x NUMBER,
y NUMBER);

TYPE Ec_two_points IS RECORD (
p1 Ec_point,
p2 Ec_point);

TYPE Ec_discrete_func_type IS TABLE OF Ec_point
    INDEX BY BINARY_INTEGER;

TYPE PointRec IS RECORD (x NUMBER,y NUMBER);    -- TODO: Can use Ec_point instead (This was originally from another package)
TYPE PointCursor IS REF CURSOR RETURN PointRec;

TYPE t_matrix IS TABLE OF DBMS_SQL.Number_Table INDEX BY PLS_INTEGER;

PROCEDURE curveFitLinearLS(
	p_points PointCursor,
	p_c0     OUT NUMBER,
	p_c1     OUT NUMBER,
	p_error  OUT INTEGER
);

PROCEDURE curveFitPoly2LS(
	p_points PointCursor,
	p_c0     OUT NUMBER,
	p_c1     OUT NUMBER,
	p_c2     OUT NUMBER,
	p_error  OUT INTEGER
);

PROCEDURE curveFitPoly3LS(
	p_points PointCursor,
	p_c0     OUT NUMBER,
	p_c1     OUT NUMBER,
	p_c2     OUT NUMBER,
	p_c3     OUT NUMBER,
	p_error  OUT INTEGER
);

PROCEDURE curveFitPoly4LS(
    p_points PointCursor,
    p_c0     OUT NUMBER,
    p_c1     OUT NUMBER,
    p_c2     OUT NUMBER,
    p_c3     OUT NUMBER,
    p_c4     OUT NUMBER,
    p_error  OUT INTEGER
);

FUNCTION interpolateLinearBoundary(p_x_value NUMBER,p_x1 NUMBER,p_y1 NUMBER,p_x2 NUMBER,p_y2 NUMBER) RETURN NUMBER;


PROCEDURE calcLinearRegression(p_point_list  Ec_discrete_func_type,
                               b OUT NUMBER,
                               a OUT NUMBER);


PROCEDURE calcCorrelationCoefficient(p_point_list  Ec_discrete_func_type,
                                     r OUT NUMBER);


FUNCTION findFunctionValueFromCurve(
	p_func_list  Ec_discrete_func_type,
	p_list_size  BINARY_INTEGER,
	p_lookup_val NUMBER)

RETURN NUMBER;

--

FUNCTION interpolateLinear(
	p_lookup_val NUMBER,
	xMin         NUMBER,
	xMax         NUMBER,
	yMin         NUMBER,
	yMax         NUMBER)

RETURN NUMBER;

--

FUNCTION quadraticCurve(
	p_whp           NUMBER,
	p_choke_mm      NUMBER,
	p_test_whp      NUMBER,
	p_test_choke_mm NUMBER,
	p_test_qty      NUMBER)

RETURN NUMBER;


FUNCTION  getYFromXPolynom2(p_x NUMBER,
                            p_c2 NUMBER,
                            p_c1 NUMBER,
                            p_c0 NUMBER)
RETURN NUMBER;



FUNCTION  getYFromXPolynom2Inv(p_x NUMBER,
                               p_c2 NUMBER,
                               p_c1 NUMBER,
                               p_c0 NUMBER,
                               p_ymin NUMBER default 0,    -- for graph purposes we are usually interested in Q1, thus the default value
                               p_ymax NUMBER default NULL) -- if the invers function has more than 1 solution in given y-range this function will return NULL as undefined
RETURN NUMBER;


END EcBp_Mathlib;