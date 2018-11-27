CREATE OR REPLACE PACKAGE EcDp_Context_User IS

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
PROCEDURE setAppUser(p_user_id VARCHAR2);

END EcDp_Context_User;