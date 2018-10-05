CREATE OR REPLACE PACKAGE EcDp_Lock_Module IS
/****************************************************************
** Package        :  EcDp_Lock_Module, header part
**
** $Revision: 1.1 $
**
** Purpose        :  Provide functionality to lock and unlock modules.
**
** Documentation  :  www.energy-components.com
**
** Created  : 27.01.2005 Trond-Arne Brattli
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
*****************************************************************/

PROCEDURE LockModule (
    p_module_code VARCHAR2,
    p_user        VARCHAR2
);

PROCEDURE UnlockModule (
    p_module_code VARCHAR2,
    p_user        VARCHAR2
);

END EcDp_Lock_Module;