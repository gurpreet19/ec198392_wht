CREATE OR REPLACE PACKAGE EcDp_Well_Decline IS
/******************************************************************************
** Package        :  EcDp_Well_Decline, header part
**
** $Revision: 1.2 $
**
** Purpose        :  Business logic for well decline for the PT module.
**
** Documentation  :  www.energy-components.com
**
** Created        : 24.05.2010 madondin
**
** Modification history:
**
**  Date     Whom         Change description:
** ------    -------     -------------------------------------------
** 24.05.10  madondin    ECPD-13374: - Added new function getYfromX,getProductionRate and getCurveExp
**
********************************************************************/

FUNCTION getYfromX(p_x_value NUMBER, p_c0 NUMBER, p_c1 NUMBER, p_trend_method VARCHAR2, p_c2 NUMBER DEFAULT NULL) RETURN NUMBER;

FUNCTION getProductionRate(p_object_id        well.object_id%TYPE,
   p_daytime                          DATE,
   p_trend_parameter                  VARCHAR2) RETURN NUMBER;

FUNCTION getCurveExp(p_object_id        well.object_id%TYPE,
   p_daytime                          DATE,
   p_trend_parameter                  VARCHAR2) RETURN NUMBER;


END EcDp_Well_Decline;