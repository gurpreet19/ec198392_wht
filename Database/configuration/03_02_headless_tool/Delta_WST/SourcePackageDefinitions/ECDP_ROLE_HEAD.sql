CREATE OR REPLACE PACKAGE EcDp_Role IS
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

PROCEDURE copyRole(p_from_role_id VARCHAR2,
		   p_to_role_id   VARCHAR2,
		   p_app_id       NUMBER);

END EcDp_Role;