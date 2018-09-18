CREATE OR REPLACE PACKAGE BODY EcDp_Lock_Module IS
/****************************************************************
** Package        :  EcDp_Lock_Module, body part
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
** Version  Date        Whom    Change description:
** -------  ------      -----   --------------------------------------
**  1.1     27.01.2005  TRA     Initial revision
*****************************************************************/


CURSOR c_module(pc_module_code VARCHAR2) IS
SELECT *
FROM module_status
WHERE module_code = pc_module_code;

PROCEDURE LockModule (
    p_module_code VARCHAR2,
    p_user        VARCHAR2
)

IS

already_locked EXCEPTION;

lv2_current_status module_status.status%TYPE;

BEGIN

    FOR Module IN c_module(p_module_code) LOOP

        lv2_current_status := nvl(Module.Status,'XXX');

    END LOOP;

    IF lv2_current_status = 'LOCKED' THEN

       RAISE already_locked;

    END IF;

    UPDATE module_status
    SET status = 'LOCKED',
        locked_date = Ecdp_Timestamp.getCurrentSysdate,
        last_updated_by = p_user
    WHERE module_code = p_module_code;

EXCEPTION

    WHEN already_locked THEN

         RAISE_APPLICATION_ERROR(-20000,'The ' || p_module_code || ' module is already locked.');

END LockModule;

PROCEDURE UnlockModule (
    p_module_code VARCHAR2,
    p_user        VARCHAR2
)

IS

already_open EXCEPTION;

lv2_current_status module_status.status%TYPE;

BEGIN

    FOR Module IN c_module(p_module_code) LOOP

        lv2_current_status := nvl(Module.Status,'XXX');

    END LOOP;

    IF lv2_current_status = 'OPEN' THEN

       RAISE already_open;

    END IF;

    UPDATE module_status
    SET status = 'OPEN',
        locked_date = null,
        last_updated_by = p_user
    WHERE module_code = p_module_code;


EXCEPTION

    WHEN already_open THEN

         RAISE_APPLICATION_ERROR(-20000,'The ' || p_module_code || ' module is already open.');

END UnlockModule;

END EcDp_Lock_Module;