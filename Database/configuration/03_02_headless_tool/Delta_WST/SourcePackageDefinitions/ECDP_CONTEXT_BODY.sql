CREATE OR REPLACE PACKAGE BODY EcDp_Context IS

/****************************************************************
** Package        :  EcDp_Context, body part
**
** $Revision: 1.19 $
**
** Purpose        :  Application context manipulation package
**
** Documentation  :  www.energy-components.com
**
** Created  : 13-Mar-2007
**
** Modification history:
**
**  Date     Whom  Change description:
**  ------   ----- --------------------------------------
** 20.03.07 OLN    Initial version of package
** 21.03.07 OLN     Modified the refresh procedure
** 26.04.07 HUS    Added FUNCTION getAppUser
** 02.05.07 HUS    Added isDirtyAppUser and setDirtyAppUser.
** 11.05.07 OLN    Added private Function IsInitialised
** 13.06.07 OLN    ADDED procedure SetDirtyGlobalContext
** 03.05.11 RJE    ECPD-16506
** 30.06.16 CGR    ECPD-37437 Use native Oracle/JDBC meta data to set app user from AppServer.18
** 05.08.16 HUS    ECPD-37437 Refactor and simplify.
** 18.10.16 HUS    ECPD-40424 Re-introduce setAppUser and provide REPORTING user exit
** 28.10.16 HUS    ECPD-40424 Introduce isAppUserRole for improved ringfencing predicate
** 06.02.18 Zho    ECPD-52253 Introduce Oracle result cache to get user roles, together with code refactor
****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : setAppUser (###DEPRECATED### Use dbms_session.set_identifier instead)
-- Description    : Sets current user
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
-- Set current user
PROCEDURE setAppUser(p_user_id IN VARCHAR2)
IS
--</EC-DOC>
BEGIN
      dbms_session.set_identifier(p_user_id);
END setAppUser;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAppUser
-- Description    : Gets current user from session context
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getAppUser
RETURN VARCHAR2
IS
--</EC-DOC>
BEGIN
   IF substr(user, 1, 8) IN ('ECKERNEL', 'ENERGYX_') OR ue_ringfencing.allowAccessToGlobalContext THEN
      RETURN sys_context('USERENV', 'CLIENT_IDENTIFIER');
   END IF;
   RETURN user;
END getAppUser;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getUserRoles
-- Description    : Return user roles as List
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------

FUNCTION getUserRoles
RETURN Varchar32L_t
--</EC-DOC>
IS
   lv2_roleset Varchar32L_t;
BEGIN
   IF substr(user, 1, 8) IN ('ECKERNEL', 'ENERGYX_') OR ue_ringfencing.allowAccessToGlobalContext THEN
      lv2_roleset := getCachedUserRoles(getAppUser());
   END IF;
   RETURN lv2_roleset;
END getUserRoles;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getCachedUserRoles
-- Description    : get role list for current user from Oracle result cache.
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------

FUNCTION getCachedUserRoles(
   p_user_id IN VARCHAR2
)
RETURN Varchar32L_t RESULT_CACHE
--</EC-DOC>
IS
   lv2l_cached_roles Varchar32L_t;
BEGIN
  IF p_user_id IS NOT NULL THEN
      SELECT DISTINCT r.role_id
      BULK COLLECT INTO lv2l_cached_roles
      FROM   t_basis_userrole u
      ,      t_basis_role r
      ,      t_basis_access a
      WHERE  a.class_name is not null
      AND    a.role_id = u.role_id
      AND    u.user_id = p_user_id
      AND    u.role_id = r.role_id;
   END IF;

   RETURN lv2l_cached_roles;
END getCachedUserRoles;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isAppUserRole
-- Description    : Returns 1 if the current app user has the given role. Otherwise return 0.

-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
FUNCTION isAppUserRole(p_role_id IN VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
   lv2l_session_roles Varchar32L_t := getUserRoles();
BEGIN
   IF p_role_id member of lv2l_session_roles THEN
      RETURN 1;
   END IF;
   RETURN 0;
END isAppUserRole;

END EcDp_Context;