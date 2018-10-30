create or replace PACKAGE EcDp_Objects_Partition IS

/****************************************************************
** Package        :  EcDp_Objects_Partition, body part
**
** $Revision: 1.5 $
**
** Purpose        :  Provide basic functions on objects
**
** Documentation  :  www.energy-components.com
**
** Created  : 22.07.2005  Tor-Erik Hauge
**
** Modification history:
**
**  Date     Whom                Change description:
**  ------   -----             --------------------------------------
**  24.07.2013 Mawaddah 	     Add new function finderObjectPartition
**  05.08.2013 Lim Chun Guan 	 Modified finderObjectPartition
****************************************************************/

PROCEDURE validatePartition(p_T_BASIS_ACCESS_ID NUMBER, P_ATTRIBUTE_NAME VARCHAR2);

FUNCTION hasDirectObjectAccess(p_user_id VARCHAR2,p_object_id VARCHAR2, p_class_name VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

END EcDp_Objects_Partition;
/

create or replace PACKAGE BODY EcDp_Objects_Partition IS

/****************************************************************
** Package        :  EcDp_Objects_Partition, body part
**
** $Revision: 1.8 $
**
** Purpose        :  Provide basic functions on objects
**
** Documentation  :  www.energy-components.com
**
** Created  : 19.01.2004  Sven Harald Nilsen
**
** Modification history:
**
**  Date       Whom  		Change description:
**  ------     ----- 		--------------------------------------
**  19.03.2004 SHN   		Added procedure ValidateValues
**  09.11.2005 AV  			Changed references to WriteTempText from EcDp_genClasscode to EcDp_DynSQL (code cleanup)
**  24.07.2013 Mawaddah 	Add new function finderObjectPartition
**  05.08.2013 Lim Chun Guan 	Modified finderObjectPartition
**  22.10.2013 abdulmaw 	ECPD-25799: Modified finderObjectPartition
****************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Prcedure       : validatePartition                                                                 --
-- Description    :                                                                              --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
PROCEDURE validatePartition(p_T_BASIS_ACCESS_ID NUMBER, P_ATTRIBUTE_NAME VARCHAR2)
--<EC-DOC>
IS
CURSOR c (cp_T_BASIS_ACCESS_ID NUMBER, cP_ATTRIBUTE_NAME VARCHAR2) IS
SELECT operator, ROWNUM
FROM t_basis_object_partition
WHERE t_basis_access_id = cp_T_BASIS_ACCESS_ID
	AND ATTRIBUTE_NAME = cP_ATTRIBUTE_NAME;

	lv_all	BOOLEAN := FALSE;

BEGIN
	FOR cur IN c (p_T_BASIS_ACCESS_ID, P_ATTRIBUTE_NAME) LOOP
		IF (cur.operator = 'ALL') THEN
			lv_all := TRUE;
		END IF;

		IF (lv_all AND cur.ROWNUM > 1) THEN
			Raise_Application_Error(-20000,'No more partitions can be added for the attribute ('||P_ATTRIBUTE_NAME||') when there exist an ALL operator');
		END IF;
	END LOOP;

END validatePartition;

FUNCTION hasDirectObjectAccess(p_user_id VARCHAR2,p_object_id VARCHAR2, p_class_name VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
--</EC-DOC>
IS

   	CURSOR c_exists_limits(p_class_name VARCHAR2) IS
	  SELECT 1
    FROM t_basis_object_partition op, t_basis_access a,  t_basis_userrole ur
    WHERE op.t_basis_access_id = a.t_basis_access_id
    AND   a.role_id = ur.role_id
    AND   ur.user_id = p_user_id
    AND   a.class_name = p_class_name;

   	CURSOR c_access_all(p_class_name VARCHAR2) IS
	  SELECT 1
    FROM t_basis_object_partition op, t_basis_access a,  t_basis_userrole ur
    WHERE op.t_basis_access_id = a.t_basis_access_id
    AND   a.role_id = ur.role_id
    AND   ur.user_id = p_user_id
    AND   a.class_name = p_class_name
    AND   op.operator = 'ALL';

   	CURSOR c_access_in(p_class_name VARCHAR2) IS
	  SELECT 1
    FROM t_basis_object_partition op, t_basis_access a,  t_basis_userrole ur
    WHERE op.t_basis_access_id = a.t_basis_access_id
    AND   a.role_id = ur.role_id
    AND   ur.user_id = p_user_id
    AND   a.class_name = p_class_name
    AND   op.operator = 'IN'
    AND   op.ATTRIBUTE_TEXT LIKE '%'||p_object_id||'%';

   	CURSOR c_access_not_in(p_class_name VARCHAR2) IS
	  SELECT 1
    FROM t_basis_object_partition op, t_basis_access a,  t_basis_userrole ur
    WHERE op.t_basis_access_id = a.t_basis_access_id
    AND   a.role_id = ur.role_id
    AND   ur.user_id = p_user_id
    AND   a.class_name = p_class_name
    AND   op.operator = 'NOT IN'
    AND   NOT (op.ATTRIBUTE_TEXT LIKE '%'||p_object_id||'%');


    lv2_haveaccess VARCHAR2(1) := 'Y';
    lv2_class_name CLASS.CLASS_NAME%TYPE;

BEGIN

  lv2_class_name := Nvl(p_class_name,ecdp_objects.GetObjClassName(p_object_id));

  -- Check if user is assosiated with any roles where there are object partioning for this class
  FOR curUA IN c_exists_limits(lv2_class_name) LOOP
    lv2_haveaccess := 'N';
    EXIT;
  END LOOP;

  IF lv2_haveaccess = 'N' THEN -- There are limitation on functional area for roles assosiated with given user

    FOR curUA_All IN c_access_all(lv2_class_name) LOOP
      lv2_haveaccess := 'Y';
      EXIT;
    END LOOP;

    IF lv2_haveaccess = 'N' THEN -- Need to find if user have access through IN list

      FOR curUA_in IN c_access_in(lv2_class_name) LOOP
        lv2_haveaccess := 'Y';
        EXIT;
      END LOOP;

      IF lv2_haveaccess = 'N' THEN -- Need to find if user have access based on NOT IN list.

        FOR curUA_All IN c_access_not_in(lv2_class_name) LOOP
          lv2_haveaccess := 'Y';
          EXIT;
        END LOOP;

      END IF; -- NOT IN Check


    END IF;  -- IN Check

  END IF;  -- ALL check;

  RETURN lv2_haveaccess;


END;

END EcDp_Objects_Partition;
/