CREATE OR REPLACE PACKAGE EcDp_Context IS

/****************************************************************
** Package        :  EcDp_Context, header part
**
** $Revision: 1.10 $
**
** Purpose        :  Application context manipulation package
**
** Documentation  :  www.energy-components.com
**
** Created  : 13-Mar-2007
**
** Modification history:
**
** Date     Whom   description:
** -------  ------ --------------------------------------
** 20.03.07 OLN    Initial versio of package
** 26.04.07 HUS    Added FUNCTION getAppUser
** 02.05.07 HUS    Added PROCEDURE setDirtyAppUser.
** 06.06.07 OLN    Added PROCEDURE genViewLayerUpddateACL.
** 13.06.07 OLN    ADDED procedure SetDirtyGlobalContext
*****************************************************************/

-- Refresh global context info for all user
PROCEDURE refresh;

-- Refresh global context info for given user
PROCEDURE refreshAppUser(p_user_id VARCHAR2);

-- Initialise session context for given user using global context info
PROCEDURE setAppUser(p_user_id VARCHAR2);

-- Get current user from session context
FUNCTION getAppUser RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getAppUser, WNDS);

--Clears the session context
PROCEDURE clearAppuser;

-- Flags p_user_id as dirty. Called from T_BASIS_USERROLE trigger on insert and delete.
PROCEDURE setDirtyAppUser(p_user_id VARCHAR2);

-- Flags initialised as dirty. Called from T_BASIS_ACCESS trigger on insert and delete.
PROCEDURE setDirtyGlobalContext;

-- Return session context name
FUNCTION getSessionContextName RETURN VARCHAR2;


-- Return Maximum role count
FUNCTION getMaxRoleCount RETURN INTEGER;


END EcDp_Context;
