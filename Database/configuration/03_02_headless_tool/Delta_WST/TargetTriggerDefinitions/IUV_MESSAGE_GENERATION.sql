CREATE OR REPLACE TRIGGER "IUV_MESSAGE_GENERATION" 
 INSTEAD OF INSERT OR UPDATE OR DELETE ON TV_MESSAGE_GENERATION
FOR EACH ROW
-- Generated by EcDp_GenClassCode 
DECLARE
  n_record_status      VARCHAR2(1) := EcDB_Utils.ConditionNVL(NOT Updating('RECORD_STATUS'),:NEW.record_status,:OLD.record_status);
  n_rev_no             NUMBER := NVL(:OLD.rev_no,0);
  n_rev_text           VARCHAR2(4000):= EcDB_Utils.ConditionNVL(NOT Updating('REV_TEXT'),:NEW.rev_text,:OLD.rev_text);
  n_created_by         VARCHAR2(30):= EcDB_Utils.ConditionNVL(NOT Updating('CREATED_BY'),to_char(:NEW.created_by),to_char(:OLD.created_by));
  n_created_date       DATE := EcDB_Utils.ConditionNVL(NOT Updating('CREATED_DATE'),:NEW.created_date,:OLD.created_date);
  n_last_updated_by    VARCHAR2(30):= EcDB_Utils.ConditionNVL(NOT Updating('LAST_UPDATED_BY'),to_char(:NEW.last_updated_by),to_char(:OLD.last_updated_by));
  n_last_updated_date  DATE := EcDB_Utils.ConditionNVL(NOT Updating('LAST_UPDATED_DATE'),:NEW.last_updated_date,:OLD.last_updated_date);
  o_created_by         VARCHAR2(30):= :OLD.created_by;
  o_last_updated_by    VARCHAR2(30):= :OLD.last_updated_by;
  n_lock_columns       EcDp_Month_lock.column_list;
  o_lock_columns       EcDp_Month_lock.column_list;
  n_DAYTIME DATE := EcDB_Utils.ConditionNVL(NOT Updating('DAYTIME'),:NEW.DAYTIME,:OLD.DAYTIME);
  n_FREQUENCY VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('FREQUENCY'),:NEW.FREQUENCY,:OLD.FREQUENCY);
  n_MESSAGE_DISTRIBUTION_NO NUMBER  := EcDB_Utils.ConditionNVL(NOT Updating('MESSAGE_DISTRIBUTION_NO'),:NEW.MESSAGE_DISTRIBUTION_NO,:OLD.MESSAGE_DISTRIBUTION_NO);
  n_TO_PARAM_SET VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('TO_PARAM_SET'),:NEW.TO_PARAM_SET,:OLD.TO_PARAM_SET);
  o_TO_PARAM_SET VARCHAR2(4000) := :OLD.TO_PARAM_SET;
  n_MESSAGE_TYPE VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('MESSAGE_TYPE'),:NEW.MESSAGE_TYPE,:OLD.MESSAGE_TYPE);
  n_MSG_TYPE_ID VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('MSG_TYPE_ID'),:NEW.MSG_TYPE_ID,:OLD.MSG_TYPE_ID);
  n_MESSAGE_NAME VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('MESSAGE_NAME'),:NEW.MESSAGE_NAME,:OLD.MESSAGE_NAME);
BEGIN

   --*************************************************************************************
   -- Start Trigger Action block
   -- Any code block defined as a BEFORE trigger-type in table CLASS_TRIGGER_ACTION will be put here
   --
   -- end Trigger Action block Class_trigger_actions before
   --*************************************************************************************

   -- Attributes check
  IF n_DAYTIME < EcDp_System_Constants.Earliest_date THEN  Raise_Application_Error(-20104,'Cannot set DAYTIME before system earliest date: 01.01.1900'); END IF;
  IF n_TO_PARAM_SET IS NULL THEN Raise_Application_Error(-20103,'Missing value for TO_PARAM_SET'); END IF;
  IF n_MESSAGE_TYPE IS NULL THEN Raise_Application_Error(-20103,'Missing value for MESSAGE_TYPE'); END IF;

   IF INSERTING THEN

      INSERT INTO ECKERNEL_WST.V_MSG_GENERATION(DAYTIME,FREQUENCY,MESSAGE_DISTRIBUTION_NO,TO_PARAM_SET,MESSAGE_TYPE,MSG_TYPE_ID,MESSAGE_NAME,CREATED_BY,CREATED_DATE,LAST_UPDATED_BY,LAST_UPDATED_DATE,REV_NO,REV_TEXT,RECORD_STATUS)
      VALUES(n_DAYTIME,n_FREQUENCY,n_MESSAGE_DISTRIBUTION_NO,n_TO_PARAM_SET,n_MESSAGE_TYPE,n_MSG_TYPE_ID,n_MESSAGE_NAME,n_CREATED_BY,n_CREATED_DATE,n_LAST_UPDATED_BY,n_LAST_UPDATED_DATE,n_REV_NO,n_REV_TEXT,n_RECORD_STATUS);
   ELSIF UPDATING THEN

   IF FALSE
   THEN
      n_rev_no := n_rev_no + 1;
   END IF;


      IF  NOT UPDATING('LAST_UPDATED_BY') OR n_last_updated_by IS NULL THEN  n_last_updated_by := USER;  END IF;
      IF  NOT UPDATING('LAST_UPDATED_DATE') OR n_last_updated_date IS NULL THEN  n_last_updated_date := EcDp_Date_Time.getCurrentSysdate;  END IF;

      UPDATE ECKERNEL_WST.V_MSG_GENERATION
      SET DAYTIME = n_DAYTIME,FREQUENCY = n_FREQUENCY,MESSAGE_DISTRIBUTION_NO = n_MESSAGE_DISTRIBUTION_NO,TO_PARAM_SET = n_TO_PARAM_SET,MESSAGE_TYPE = n_MESSAGE_TYPE,MSG_TYPE_ID = n_MSG_TYPE_ID,MESSAGE_NAME = n_MESSAGE_NAME,CREATED_BY = n_CREATED_BY, CREATED_DATE = n_CREATED_DATE , LAST_UPDATED_BY = n_LAST_UPDATED_BY,LAST_UPDATED_DATE = n_LAST_UPDATED_DATE ,REV_NO = n_rev_no, REV_TEXT = n_REV_TEXT,RECORD_STATUS = n_RECORD_STATUS
      WHERE TO_PARAM_SET= o_TO_PARAM_SET;

   ELSE -- deleting

     DELETE FROM ECKERNEL_WST.V_MSG_GENERATION
     WHERE TO_PARAM_SET= o_TO_PARAM_SET;

   END IF; -- Inserting

--*************************************************************************************
-- Start Trigger Action block
-- Any code block defined as a AFTER trigger-type in table CLASS_TRIGGER_ACTION will be put here
--
-- end Trigger Action block Class_trigger_actions after
--*************************************************************************************

END;

