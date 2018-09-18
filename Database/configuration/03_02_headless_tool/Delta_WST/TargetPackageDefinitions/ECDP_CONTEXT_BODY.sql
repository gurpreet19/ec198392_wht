CREATE OR REPLACE PACKAGE BODY EcDp_Context IS

/****************************************************************
** Package        :  EcDp_Context, body part
**
** $Revision: 1.18.4.1 $
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
** 21.03.07 OLN	   Modified the refresh procedure
** 26.04.07 HUS    Added FUNCTION getAppUser
** 02.05.07 HUS    Added isDirtyAppUser and setDirtyAppUser.
** 11.05.07 OLN    Added private Function IsInitialised
** 13.06.07 OLN    ADDED procedure SetDirtyGlobalContext
** 03.05.11 RJE    ECPD-16506
****************************************************************/

-- Global context name
lv_global_context VARCHAR2(30):='ECGC_USERROLES_'||ec_t_preferanse.pref_verdi('OPERATION');
lv_global_dirty_context VARCHAR2(30):='ECGC_DIRTY_'||ec_t_preferanse.pref_verdi('OPERATION');

-- Session context name
lv_session_context VARCHAR2(30):='ECSC_USERROLES_'||ec_t_preferanse.pref_verdi('OPERATION');

-- Maximum number of roles per user.
ln_max_role_count INTEGER:=50;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : refreshAppUser
-- Description    : Refresh global context info for given user.
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
PROCEDURE refreshAppUser(
   p_user_id       VARCHAR2
)
--</EC-DOC>
IS
  CURSOR c_user_role(p_user_id VARCHAR2) IS
    SELECT DISTINCT u.*
    FROM   t_basis_userrole u
    ,      t_basis_role r
    ,      t_basis_access a
    WHERE  a.role_id=u.role_id
    AND    a.class_name is not null
    AND    u.user_id=p_user_id
    AND    u.role_id=r.role_id
    ORDER BY u.role_id ASC;


  lv_role_list VARCHAR2(4000);
  ln_count INTEGER;
BEGIN

     ln_count:=0;
     lv_role_list:='';
     FOR cur_role IN c_user_role(p_user_id) LOOP
        IF ln_count>0 THEN
            lv_role_list:=lv_role_list||',';
        END IF;
        lv_role_list:=lv_role_list||cur_role.role_id;
        ln_count:=ln_count+1;
     END LOOP;
     dbms_session.set_context(lv_global_context, p_user_id, lv_role_list);
     dbms_session.set_context(lv_global_dirty_context, p_user_id, 'FALSE');
--     IF ln_count > ln_max_role_count THEN
--        RAISE_APPLICATION_ERROR(-20000, 'The ' ||p_user_id|| ' user has too many roles. Maximum '||ln_max_role_count||' roles pr user. ' );
--     END IF;
END refreshAppUser;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : setDirtyGlobalContext
-- Description    : Flags global Context as dirty. Called from T_BASIS_ACCESS insert, Update and delete trigger.
--                  Calling refreshAppUser from the insert/
--                  delete trigger on T_BASIS_ACCESS will give:
--
--                          ORA-04091: table ECKERNEL_BM4DB.T_BASIS_USERROLE is mutating,
--                                     trigger/function may not see it
--
--
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
PROCEDURE setDirtyGlobalContext
--</EC-DOC>
IS
BEGIN
  dbms_session.set_context(lv_global_context, 'INITIALISE_FLAG','FALSE');
END setDirtyGlobalContext;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : setDirtyAppUser
-- Description    : Flags p_user_id as dirty. Called from T_BASIS_USERROLE insert and delete trigger.
--                  refreshAppUser queries T_BASIS_USERROLE. Calling refreshAppUser from the insert/
--                  delete trigger on T_BASIS_USERROLE will give:
--
--                          ORA-04091: table ECKERNEL_BM4DB.T_BASIS_USERROLE is mutating,
--                                     trigger/function may not see it
--
--
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
PROCEDURE setDirtyAppUser(
   p_user_id       VARCHAR2
)
--</EC-DOC>
IS
BEGIN
  dbms_session.set_context(lv_global_dirty_context, p_user_id, 'TRUE');
END setDirtyAppUser;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : isInitialised
-- Description    : Returns wether the global context is initialised or not
--
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
FUNCTION isInitialised
RETURN BOOLEAN
--</EC-DOC>
IS
BEGIN
 IF sys_context(lv_global_context, 'INITIALISE_FLAG')='TRUE' THEN
  return TRUE;
  ELSE
  return FALSE;
  END IF;
END isInitialised;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : isDirtyAppUser
-- Description    : Returns TRUE if p_user_id is flagged as dirty.
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
FUNCTION isDirtyAppUser(
   p_user_id       VARCHAR2
)
RETURN BOOLEAN
--</EC-DOC>
IS
BEGIN
  RETURN sys_context(lv_global_dirty_context, p_user_id)='TRUE';
END isDirtyAppUser;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : refresh
-- Description    : Refresh global context info for all user.
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :t_basis_userrole,t_basis_role,t_basis_access a
--
-- Using functions: refreshAppUser
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE refresh
--</EC-DOC>
IS
  CURSOR c_user IS
    SELECT *
    FROM t_basis_user;


BEGIN
     dbms_session.set_context(lv_global_context, 'INITIALISE_FLAG','TRUE');
     FOR cur_user IN c_user LOOP
         refreshAppUser(cur_user.user_id);
     END LOOP;

END refresh;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : setAppUser
-- Description    : Initialise session context for given user using information cached in global context.
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
PROCEDURE setAppUser(
   p_user_id       VARCHAR2
)
--</EC-DOC>
IS
  lv_string VARCHAR2(4000);
  lv_role_list VARCHAR2(4000);
  ln_pos INTEGER;
  ln_cnt INTEGER;
BEGIN
      IF isInitialised=FALSE THEN
         refresh;
      ELSIF isDirtyAppUser(p_user_id)=TRUE THEN
         refreshAppUser(p_user_id);
      END IF;

      lv_role_list:=sys_context(lv_global_context, p_user_id, 4000);
      lv_string:=lv_role_list;
      ln_cnt:=1;
      ln_pos:=instr(lv_string,',');
      WHILE ln_pos>0 LOOP
            dbms_session.set_context(lv_session_context, 'ROLE_'||ln_cnt, substr(lv_string,1,ln_pos-1));
          lv_string:=substr(lv_string,ln_pos+1);
          ln_cnt:=ln_cnt+1;
          ln_pos:=instr(lv_string,',');
      END LOOP;
      dbms_session.set_context(lv_session_context, 'ROLE_'||ln_cnt, lv_string);
      dbms_session.set_context(lv_session_context, 'USER_ID', p_user_id);

      --Clear roles that are over the max flag.
      IF ln_cnt>ln_max_role_count then
      FOR i IN (ln_max_role_count+1)..ln_cnt LOOP
          dbms_session.set_context(lv_session_context, 'ROLE_'||i, null);
      END LOOP;
      ELSE
      FOR i IN (ln_cnt+1)..ln_max_role_count LOOP
          dbms_session.set_context(lv_session_context, 'ROLE_'||i, null);
      END LOOP;
      END IF;

      IF ln_cnt > ln_max_role_count THEN
        RAISE_APPLICATION_ERROR(-20000, 'The ' ||p_user_id|| ' user has too many roles. Maximum '||ln_max_role_count||' roles pr user.');
     END IF;

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
   RETURN sys_context(lv_session_context, 'USER_ID');
END getAppUser;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function      : clearAppuser
-- Description    : Clears the Session context
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
procedure clearAppuser
--</EC-DOC>

IS
ln_cnt INTEGER;
BEGIN

ln_cnt:= 1;
FOR i in ln_cnt..ln_max_role_count LOOP
    dbms_session.set_context(lv_session_context, 'ROLE_'||i, null);
    END LOOP;
END clearAppuser;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function      : getSessionContextName
-- Description    : Return session context name
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
FUNCTION getSessionContextName
--</EC-DOC>
RETURN VARCHAR2
IS
BEGIN
   RETURN lv_session_context;
END getSessionContextName;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function      : getMaxRoleCount
-- Description    : Return Maximum role count
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
FUNCTION getMaxRoleCount
--</EC-DOC>
RETURN INTEGER
IS
BEGIN
   RETURN ln_max_role_count;
END getMaxRoleCount;


END EcDp_Context;
