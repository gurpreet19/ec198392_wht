CREATE OR REPLACE PACKAGE BODY ecdp_ctrl_property IS
/****************************************************************
** Package        :  ecbp_ctrl_property
**
**
**
** Purpose        : Basic Functions for ctrl_property
**
** Documentation  :  www.energy-components.com
**
** Created  : 31.08.2006 Siah Chio Hwi
**
** Modification history:
**
** Date         Whom  	 		      Change description:
** ----------   ----- 			      --------------------------------------
** 2011.02.22   Dagfinn Rosnes    Added function getUserProperty to support user/role level properties
******************************************************************/



------------------------------------------------------------------
-- Function   : getSystemProperty
-- Description: Returns ctrl property value based on key and daytime.
--
------------------------------------------------------------------


FUNCTION getSystemProperty(p_key VARCHAR2, p_daytime DATE DEFAULT NULL)
RETURN VARCHAR2
  --</EC-DOC>
  IS

  lr_fields varchar2(300);
  ld_date date;

  CURSOR c_ctrl_property (
           cp_key VARCHAR2,
           cp_daytime DATE) IS
  SELECT VALUE_STRING
  FROM CTRL_PROPERTY
  WHERE key = cp_key
  AND daytime =
     (SELECT max(daytime)
      FROM CTRL_PROPERTY
  WHERE key = p_key
  AND daytime <= cp_daytime);

  CURSOR c_ctrl_property_meta (cp_key VARCHAR2)
  IS
  SELECT DEFAULT_VALUE_STRING
  FROM CTRL_PROPERTY_META
  WHERE key = cp_key
  AND version_type = 'SYSTEM';

BEGIN
   lr_fields := null;

   IF p_daytime is null THEN
      ld_date := Ecdp_Timestamp.getCurrentSysdate();
   ELSE
      ld_date := p_daytime;
   END IF;

   FOR cur_row IN c_ctrl_property(
      p_key,
      ld_date) LOOP
      lr_fields:= cur_row.VALUE_STRING;
   END LOOP;

   IF lr_fields IS NULL THEN
     FOR cur_row IN c_ctrl_property_meta(p_key) LOOP
        lr_fields:= cur_row.DEFAULT_VALUE_STRING;
     END LOOP;
   END IF;

  RETURN lr_fields;
  END getSystemProperty;


-----------------------------------------------------------------------------------------------------------------------------

-- Return property value based on user
-- If no user is specified, use context user
-- User value is precedent over role value

FUNCTION getUserProperty(p_key     VARCHAR2,
                         p_user_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
IS

  CURSOR c_user_prop(cp_key VARCHAR2, cp_user_id VARCHAR2) IS
  SELECT p.value_string
    FROM ctrl_property p
   WHERE p.key = cp_key
     AND p.user_id = cp_user_id;

  CURSOR c_role_prop(cp_key VARCHAR2, cp_user_id VARCHAR2) IS
  SELECT p.value_string
    FROM ctrl_property p, t_basis_userrole u
   WHERE p.key = cp_key
     AND p.role_id = u.role_id
     AND u.user_id = cp_user_id;

  CURSOR c_ctrl_property_meta (cp_key VARCHAR2) IS
  SELECT default_value_string
    FROM ctrl_property_meta
   WHERE key = cp_key
     AND version_type = 'USER';

  lv2_user_id    t_basis_user.user_id%TYPE       := NULL;
  lv2_prop_value ctrl_property.value_string%TYPE := NULL;

BEGIN

  -- Set user to get property for
  lv2_user_id := NVL(p_user_id, ecdp_context.getAppUser);

  -- First attempt: get user value
  FOR rs_User IN c_user_prop(p_key, lv2_user_id) LOOP
    lv2_prop_value := rs_User.value_string;
  END LOOP;

  -- Second attempt: get role value
  IF lv2_prop_value IS NULL THEN

    FOR rs_Role IN c_role_prop(p_key, lv2_user_id) LOOP
      lv2_prop_value := rs_Role.value_string;
    END LOOP;

  END IF;

  -- Third attempt: Get default value
  IF lv2_prop_value IS NULL THEN

    FOR rs_Default IN c_ctrl_property_meta(p_key) LOOP
      lv2_prop_value := rs_Default.default_value_string;
    END LOOP;

  END IF;

  RETURN lv2_prop_value;

END getUserProperty;


END ecdp_ctrl_property;