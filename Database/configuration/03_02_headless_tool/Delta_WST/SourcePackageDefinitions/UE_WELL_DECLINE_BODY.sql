CREATE OR REPLACE PACKAGE BODY Ue_Well_Decline is
/****************************************************************
** Package        :  Ue_Well_Decline, body part
**
** Purpose        :  Business logic for well decline for the PT module.
**
** Documentation  :  www.energy-components.com
**
** Created  : 05.04.2012 Lim Chun Guan
**
** Modification history:
**
** Date        Whom     Change description:
** ---------   -------- --------------------------------------
** 05.04.2012  limmmchu  Initial version. ECPD-20155: Added getYfromX() function.
** 30.08.2012  limmmchu  ECPD-21325: Modified getYfromX() function.
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getYfromX
-- Description    : Calculates y from a given x based on formula type and coefficients/points
---------------------------------------------------------------------------------------------------
FUNCTION getYfromX(
   p_x_value NUMBER,
   p_c0 NUMBER,
   p_c1 NUMBER,
   p_trend_method VARCHAR2,
   p_c2 NUMBER DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
	RETURN NULL;
END getYfromX;

END Ue_Well_Decline;