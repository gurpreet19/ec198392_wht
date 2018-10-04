CREATE OR REPLACE PACKAGE BODY EcDp_STATUS_PROCESS IS
/****************************************************************
** Package        :  EcDp_STATUS_PROCESS, body part
**
** $Revision      :
**
** Purpose        :  Delete child records.
**
** Documentation  :  www.energy-components.com
**
** Created  : 31.05.2011  Georg H?
**
** Modification history:
**
** Version  Date         Whom          Change description:
** -------  ----------   -----------   --------------------------------------
** 1.0      31.05.2011   Georg H?   Initial version
/****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkAndDeleteChildren
-- Description    : To check if this status process has chils processes. In that case, raise an application error and inform the user.
--                  If no child processes, then delete child records.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : STATUS_PROCESS, ALLOC_JOB_STATUS_PROCESS, STAT_PROCESS_TASK, STAT_PROCESS_ROLE, STAT_PROCESS_STATUS
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkAndDeleteChildren(p_process_id VARCHAR2)
--</EC-DOC>

IS

  -- Looking for child processes
  CURSOR c_status_process IS
     SELECT process_id
     FROM status_process
     WHERE parent_process_id = p_process_id;

  lv_status_process_list VARCHAR2(1000) := NULL;

BEGIN
  -- Making a list of child processes
  FOR cur_status_process IN c_status_process() LOOP
    IF lv_status_process_list IS NOT NULL THEN
      lv_status_process_list := lv_status_process_list || ', ';
    END IF;

    lv_status_process_list := lv_status_process_list || cur_status_process.process_id;
  END LOOP;

  -- If any child processes, inform the user and abort.
  IF lv_status_process_list IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20623, 'This status process can not be deleted because it has child processes (' || lv_status_process_list || ').');
  END IF;

  -- Deleting child records from Alloc Job Status Process
  DELETE FROM ALLOC_JOB_STATUS_PROCESS
  WHERE PROCESS_ID = p_process_id;

  -- Deleting child records from Process Tasks
  DELETE FROM STAT_PROCESS_TASK
  WHERE PROCESS_ID = p_process_id;

  -- Deleting child records from Process Roles
  DELETE FROM STAT_PROCESS_ROLE
  WHERE PROCESS_ID = p_process_id;

  -- Deleting child records from Process Status
  DELETE FROM STAT_PROCESS_STATUS
  WHERE PROCESS_ID = p_process_id;
END checkAndDeleteChildren;

END EcDp_STATUS_PROCESS;