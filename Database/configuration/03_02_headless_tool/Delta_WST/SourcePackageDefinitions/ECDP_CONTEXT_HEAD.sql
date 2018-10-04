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
** 18.10.16 HUS    ECPD-40424 Re-introduce setAppUser
** 28.10.16 HUS    ECPD-40424 Introduce isAppUserRole for improved ringfencing predicate
** 06.02.18 Zho    ECPD-52253 Introduce Oracle result cache to get user roles, together with code refactor
*****************************************************************/

TYPE Varchar32L_t IS TABLE OF VARCHAR2(32) NOT NULL;

-- Get current user
FUNCTION getAppUser RETURN VARCHAR2;

-- ###DEPRECATED###: Use dbms_session.set_identifier instead
PROCEDURE setAppUser(p_user_id IN VARCHAR2);

-- Returns roles list for current user (i.e. EcDp_Context.getAppUser).
FUNCTION getUserRoles RETURN Varchar32L_t;

-- Return Cached UserRoles for the given user
FUNCTION getCachedUserRoles(p_user_id IN VARCHAR2) RETURN Varchar32L_t RESULT_CACHE;

-- Returns 1 if the current app user has the given role. Otherwise return 0.
FUNCTION isAppUserRole(p_role_id IN VARCHAR2) RETURN NUMBER;

END EcDp_Context;