CREATE OR REPLACE PACKAGE BODY EcDp_Context_User IS

/****************************************************************
** Package        :  EcDp_Context_User, header part
**
** $Revision: 1.1 $
**
** Purpose        :  Application context manipulation package
**
** Documentation  :  www.energy-components.com
**
** Created  : 11-May-2007
**
** Modification history:
**
** Date     Whom   description:
** -------  ------ --------------------------------------
** 11.05.07 OLN    Initial version of package

*****************************************************************/

-- Procedure for Logon triggers to set the session context based on global context info.
PROCEDURE setAppUser(p_user_id VARCHAR2)
IS
BEGIN
IF p_user_id = USER THEN
	ECDP_CONTEXT.SETAPPUSER(USER);
ELSE
	IF UPPER(substr(p_user_id,1,7))!='ENERGYX' THEN
	RAISE_APPLICATION_ERROR(-20000, 'The user id cannot be set to anything other than your oracle user' );
	END IF;
END IF;
END;

END EcDp_Context_User;
