CREATE OR REPLACE TRIGGER "IUV_DT_TANK_MTH_INV_OIL" 
 INSTEAD OF INSERT OR UPDATE OR DELETE ON TV_DT_TANK_MTH_INV_OIL
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
  n_ATTRIBUTE VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('ATTRIBUTE'),:NEW.ATTRIBUTE,:OLD.ATTRIBUTE);
  n_DATA_CLASS VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('DATA_CLASS'),:NEW.DATA_CLASS,:OLD.DATA_CLASS);
  n_PK_VAL_1 VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('PK_VAL_1'),:NEW.PK_VAL_1,:OLD.PK_VAL_1);
  n_PK_ATTR_1 VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('PK_ATTR_1'),:NEW.PK_ATTR_1,:OLD.PK_ATTR_1);
  n_MAPPING_NO VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('MAPPING_NO'),:NEW.MAPPING_NO,:OLD.MAPPING_NO);
  o_MAPPING_NO VARCHAR2(4000) := :OLD.MAPPING_NO;
  n_SOURCE_ID VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('SOURCE_ID'),:NEW.SOURCE_ID,:OLD.SOURCE_ID);
  n_TAG_ID VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('TAG_ID'),:NEW.TAG_ID,:OLD.TAG_ID);
  n_TEMPLATE_CODE VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('TEMPLATE_CODE'),:NEW.TEMPLATE_CODE,:OLD.TEMPLATE_CODE);
  n_FROM_UNIT VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('FROM_UNIT'),:NEW.FROM_UNIT,:OLD.FROM_UNIT);
  n_TO_UNIT VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('TO_UNIT'),:NEW.TO_UNIT,:OLD.TO_UNIT);
  n_LAST_TRANSFER DATE := EcDB_Utils.ConditionNVL(NOT Updating('LAST_TRANSFER'),:NEW.LAST_TRANSFER,:OLD.LAST_TRANSFER);
  n_ACTIVE VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('ACTIVE'),:NEW.ACTIVE,:OLD.ACTIVE);
BEGIN

   --*************************************************************************************
   -- Start Trigger Action block
   -- Any code block defined as a BEFORE trigger-type in table CLASS_TRIGGER_ACTION will be put here
   --
   -- end Trigger Action block Class_trigger_actions before
   --*************************************************************************************

   -- Attributes check
  IF n_ATTRIBUTE IS NULL THEN Raise_Application_Error(-20103,'Missing value for ATTRIBUTE'); END IF;
  IF n_DATA_CLASS IS NULL THEN Raise_Application_Error(-20103,'Missing value for DATA_CLASS'); END IF;
  IF n_SOURCE_ID IS NULL THEN Raise_Application_Error(-20103,'Missing value for SOURCE_ID'); END IF;
  IF n_TAG_ID IS NULL THEN Raise_Application_Error(-20103,'Missing value for TAG_ID'); END IF;
  IF n_TEMPLATE_CODE IS NULL THEN Raise_Application_Error(-20103,'Missing value for TEMPLATE_CODE'); END IF;
  IF n_LAST_TRANSFER IS NULL THEN Raise_Application_Error(-20103,'Missing value for LAST_TRANSFER'); END IF;

   IF INSERTING THEN

      INSERT INTO ECKERNEL_WST.V_TRANS_CONFIG(ATTRIBUTE,DATA_CLASS,PK_VAL_1,PK_ATTR_1,MAPPING_NO,SOURCE_ID,TAG_ID,TEMPLATE_CODE,FROM_UNIT,TO_UNIT,LAST_TRANSFER,ACTIVE,CREATED_BY,CREATED_DATE,LAST_UPDATED_BY,LAST_UPDATED_DATE,REV_NO,REV_TEXT,RECORD_STATUS)
      VALUES(n_ATTRIBUTE,n_DATA_CLASS,n_PK_VAL_1,n_PK_ATTR_1,n_MAPPING_NO,n_SOURCE_ID,n_TAG_ID,n_TEMPLATE_CODE,n_FROM_UNIT,n_TO_UNIT,n_LAST_TRANSFER,n_ACTIVE,n_CREATED_BY,n_CREATED_DATE,n_LAST_UPDATED_BY,n_LAST_UPDATED_DATE,n_REV_NO,n_REV_TEXT,n_RECORD_STATUS);
   ELSIF UPDATING THEN


      IF  NOT UPDATING('LAST_UPDATED_BY') OR n_last_updated_by IS NULL THEN  n_last_updated_by := USER;  END IF;
      IF  NOT UPDATING('LAST_UPDATED_DATE') OR n_last_updated_date IS NULL THEN  n_last_updated_date := EcDp_Date_Time.getCurrentSysdate;  END IF;

      UPDATE ECKERNEL_WST.V_TRANS_CONFIG
      SET ATTRIBUTE = n_ATTRIBUTE,DATA_CLASS = n_DATA_CLASS,PK_VAL_1 = n_PK_VAL_1,PK_ATTR_1 = n_PK_ATTR_1,MAPPING_NO = n_MAPPING_NO,SOURCE_ID = n_SOURCE_ID,TAG_ID = n_TAG_ID,TEMPLATE_CODE = n_TEMPLATE_CODE,FROM_UNIT = n_FROM_UNIT,TO_UNIT = n_TO_UNIT,LAST_TRANSFER = n_LAST_TRANSFER,ACTIVE = n_ACTIVE,CREATED_BY = n_CREATED_BY, CREATED_DATE = n_CREATED_DATE , LAST_UPDATED_BY = n_LAST_UPDATED_BY,LAST_UPDATED_DATE = n_LAST_UPDATED_DATE ,REV_NO = n_rev_no, REV_TEXT = n_REV_TEXT,RECORD_STATUS = n_RECORD_STATUS
      WHERE MAPPING_NO= o_MAPPING_NO;

   ELSE -- deleting

     DELETE FROM ECKERNEL_WST.V_TRANS_CONFIG
     WHERE MAPPING_NO= o_MAPPING_NO;

   END IF; -- Inserting

--*************************************************************************************
-- Start Trigger Action block
-- Any code block defined as a AFTER trigger-type in table CLASS_TRIGGER_ACTION will be put here
--
-- end Trigger Action block Class_trigger_actions after
--*************************************************************************************

END;

