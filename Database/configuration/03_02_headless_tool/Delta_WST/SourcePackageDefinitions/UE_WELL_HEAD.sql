CREATE OR REPLACE PACKAGE Ue_Well IS

/****************************************************************
** Package        :  Ue_Well
**
** Modification history:
**
** Date        Whom     Change description:
** ---------   -------- --------------------------------------
** 21.04.2010  oonnnng  ECPD-14199: Add getPwelOnStreamHrs() and getIwelOnStreamHrs() function.
****************************************************************/

FUNCTION getPwelOnStreamHrs(
         p_object_id well.object_id%TYPE,
         p_daytime DATE)
RETURN NUMBER;


FUNCTION getIwelOnStreamHrs(
         p_object_id well.object_id%TYPE,
         p_inj_type VARCHAR2,
         p_daytime DATE)
RETURN NUMBER;

END Ue_Well;