CREATE OR REPLACE PACKAGE Ue_Tank_Strapping IS
/****************************************************************
** Package        :  Ue_Tank_Strapping
**
** Modification history:
**
** Date        Whom     Change description:
** ---------   -------- --------------------------------------
** 25.08.2014  hismahas  ECPD-28265: Add a user exit for Object Tank, Strapping Method.
** 31.08.2017  kaushaak  ECPD-48150: Removed Pragma restrict_references.
****************************************************************/

FUNCTION findValueFromDip(
       p_tank_object_id    TANK.OBJECT_ID%TYPE,
       p_dip_level          NUMBER,
       p_daytime           DATE,
       p_strap_value_type  VARCHAR2        -- 'VOLUME' or 'MASS'
	   )
RETURN NUMBER;
END Ue_Tank_Strapping;