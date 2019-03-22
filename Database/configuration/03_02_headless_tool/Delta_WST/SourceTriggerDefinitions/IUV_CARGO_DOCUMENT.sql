CREATE OR REPLACE EDITIONABLE TRIGGER "IUV_CARGO_DOCUMENT" 
 INSTEAD OF INSERT OR UPDATE OR DELETE ON TV_CARGO_DOCUMENT
FOR EACH ROW
-- Generated by ecdp_viewlayer
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
  n_REPORT_NO VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('REPORT_NO'),:NEW.REPORT_NO,:OLD.REPORT_NO);
  o_REPORT_NO VARCHAR2(4000) := :OLD.REPORT_NO;
  n_PARCEL_NO VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('PARCEL_NO'),:NEW.PARCEL_NO,:OLD.PARCEL_NO);
  n_DOC_CODE VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('DOC_CODE'),:NEW.DOC_CODE,:OLD.DOC_CODE);
  n_RECEIVER VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('RECEIVER'),:NEW.RECEIVER,:OLD.RECEIVER);
  n_ORIGINAL VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('ORIGINAL'),:NEW.ORIGINAL,:OLD.ORIGINAL);
  n_RUN_DATE DATE := EcDB_Utils.ConditionNVL(NOT Updating('RUN_DATE'),:NEW.RUN_DATE,:OLD.RUN_DATE);
  n_UPLOAD VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('UPLOAD'),:NEW.UPLOAD,:OLD.UPLOAD);
  o_UPLOAD VARCHAR2(4000) := :OLD.UPLOAD;
  n_FORMAT_CODE VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('FORMAT_CODE'),:NEW.FORMAT_CODE,:OLD.FORMAT_CODE);
BEGIN

   --*************************************************************************************
   -- Start Trigger Action block
   -- Any code block defined as a BEFORE trigger-type in table CLASS_TRIGGER_ACTION will be put here
   --
   -- end Trigger Action block Class_trigger_actions before
   --*************************************************************************************

   -- Attributes check
  IF n_REPORT_NO IS NULL THEN Raise_Application_Error(-20103,'Missing value for REPORT_NO'); END IF;
  IF n_DOC_CODE IS NULL THEN Raise_Application_Error(-20103,'Missing value for DOC_CODE'); END IF;

   IF INSERTING THEN

      INSERT INTO ECKERNEL_EC.V_CARGO_DOCUMENT(REPORT_NO, PARCEL_NO, DOC_CODE, RECEIVER, ORIGINAL, RUN_DATE, UPLOAD, FORMAT_CODE, CREATED_BY, CREATED_DATE, LAST_UPDATED_BY, LAST_UPDATED_DATE, REV_NO, REV_TEXT, RECORD_STATUS)
      VALUES(n_REPORT_NO, n_PARCEL_NO, n_DOC_CODE, n_RECEIVER, n_ORIGINAL, n_RUN_DATE, n_UPLOAD, n_FORMAT_CODE, n_CREATED_BY, n_CREATED_DATE, n_LAST_UPDATED_BY, n_LAST_UPDATED_DATE, n_REV_NO, n_REV_TEXT, n_RECORD_STATUS);
   ELSIF UPDATING THEN

   IF FALSE
   THEN
      n_rev_no := n_rev_no + 1;
   END IF;


      IF  NOT UPDATING('LAST_UPDATED_BY') OR n_last_updated_by IS NULL THEN  n_last_updated_by := USER;  END IF;
      IF  NOT UPDATING('LAST_UPDATED_DATE') OR n_last_updated_date IS NULL THEN  n_last_updated_date := Ecdp_Timestamp.getCurrentSysdate;  END IF;

      UPDATE ECKERNEL_EC.V_CARGO_DOCUMENT
      SET REPORT_NO = n_REPORT_NO, PARCEL_NO = n_PARCEL_NO, DOC_CODE = n_DOC_CODE, RECEIVER = n_RECEIVER, ORIGINAL = n_ORIGINAL, RUN_DATE = n_RUN_DATE, UPLOAD = n_UPLOAD, FORMAT_CODE = n_FORMAT_CODE, CREATED_BY = n_CREATED_BY, CREATED_DATE = n_CREATED_DATE , LAST_UPDATED_BY = n_LAST_UPDATED_BY,LAST_UPDATED_DATE = n_LAST_UPDATED_DATE ,REV_NO = n_rev_no, REV_TEXT = n_REV_TEXT,RECORD_STATUS = n_RECORD_STATUS
      WHERE REPORT_NO= o_REPORT_NO AND UPLOAD= o_UPLOAD;

   ELSE -- deleting

     DELETE FROM ECKERNEL_EC.V_CARGO_DOCUMENT
     WHERE REPORT_NO= o_REPORT_NO AND UPLOAD= o_UPLOAD;

   END IF; -- Inserting

--*************************************************************************************
-- Start Trigger Action block
-- Any code block defined as a AFTER trigger-type in table CLASS_TRIGGER_ACTION will be put here
--
-- end Trigger Action block Class_trigger_actions after
--*************************************************************************************

END;

