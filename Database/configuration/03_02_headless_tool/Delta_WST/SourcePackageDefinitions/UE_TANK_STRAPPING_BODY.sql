CREATE OR REPLACE PACKAGE BODY Ue_Tank_Strapping IS
/****************************************************************
** Package        :  Ue_Tank_Strapping, body part
**
** Purpose        :  This package is used to program theoretical calculation when a predefined method supplied by EC does not cover the requirements.
**                   Upgrade processes will never replace this package.
**
** Modification history:
**
** Date        Whom     Change description:
** ---------   -------- --------------------------------------
** 25.08.2014  hismahas  ECPD-28265: Add a user exit for Object Tank, Strapping Method.
** 31.08.2017  kaushaak  ECPD-48150: Updated the Description.
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findValueFromDip
-- Description    : Returns the value matching the dip level
---------------------------------------------------------------------------------------------------
FUNCTION findValueFromDip(
       p_tank_object_id    TANK.OBJECT_ID%TYPE,
       p_dip_level          NUMBER,
       p_daytime           DATE,
       p_strap_value_type  VARCHAR2        -- 'VOLUME' or 'MASS'
       )
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
   RETURN NULL;
END findValueFromDip;

END Ue_Tank_Strapping;