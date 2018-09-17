CREATE OR REPLACE PACKAGE BODY Ue_Well is
/****************************************************************
** Package        :  Ue_Well, body part
**
** Purpose        :  This package is used to program well calculation when a predefined method supplied by EC does not cover the requirements.
**                   Upgrade processes will never replace this package.
**
** Modification history:
**
** Date        Whom     Change description:
** ---------   -------- --------------------------------------
** 21.04.2010  oonnnng  ECPD-14199: Add getPwelOnStreamHrs() and getIwelOnStreamHrs() function.
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getPwelOnStreamHrs
-- Description    : RCalculated the number of hours a production well has been flowing based on
--                  what is specified for the well attribute 'ON_STRM_METHOD'.
---------------------------------------------------------------------------------------------------
FUNCTION getPwelOnStreamHrs(
         p_object_id well.object_id%TYPE,
         p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getPwelOnStreamHrs;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getIwelOnStreamHrs
-- Description    : Calculated the number of hours a injection well has been flowing based on
--                  what is specified for the well attribute 'ON_STRM_METHOD'.
---------------------------------------------------------------------------------------------------
FUNCTION getIwelOnStreamHrs(
         p_object_id well.object_id%TYPE,
         p_inj_type VARCHAR2,
         p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getIwelOnStreamHrs;

END Ue_Well;