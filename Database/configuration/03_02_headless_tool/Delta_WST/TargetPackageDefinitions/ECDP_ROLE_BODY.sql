CREATE OR REPLACE PACKAGE BODY EcDp_Role IS
/***********************************************************************************
** Package   :  EcDp_Role
** $Revision: 1.1 $
**
** Purpose   :  Role management
**
** General Logic:
**
** Created:      28.04.05  Toha
**
**
** Modification history:
**
**
** Date:			Whom:	Change description:
** ----------	-----	----------------------------------------------------------------
** 28.04.2005   Toha    Initial version to add copy role (TI #1619)
**************************************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copyRole                                                                     --
-- Description    : This procedure copies all access granted to role p_from_role_id              --
--                  to the target role    							 --
-- Postconditions : The target role has the same set of granted access as p_from_role		 --
--                                                                                               --
-- Using tables   : t_basis_access                                                               --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :
---------------------------------------------------------------------------------------------------

PROCEDURE copyRole(p_from_role_id VARCHAR2,
		   p_to_role_id   VARCHAR2,
		   p_app_id	  NUMBER)
--</EC-DOC>
IS

BEGIN

    IF (p_to_role_id is null) THEN
        RAISE_APPLICATION_ERROR (-20999, 'Copy From Role is not set');
    END IF;

    INSERT INTO t_basis_access (role_id,
                                app_id,
                                level_id,
                                object_id,
                                class_name,
                                record_status_level)
        (SELECT p_to_role_id,
                app_id,
                level_id,
                object_id,
                class_name,
                record_status_level
             FROM t_basis_access
             WHERE role_id = p_from_role_id
                 AND app_id = p_app_id);
END copyRole;

END EcDp_Role;