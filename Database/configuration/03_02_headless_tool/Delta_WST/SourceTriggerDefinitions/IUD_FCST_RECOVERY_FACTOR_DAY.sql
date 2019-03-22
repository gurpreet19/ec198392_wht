CREATE OR REPLACE EDITIONABLE TRIGGER "IUD_FCST_RECOVERY_FACTOR_DAY" 
 INSTEAD OF INSERT OR UPDATE OR DELETE ON DV_FCST_RECOVERY_FACTOR_DAY
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
  n_CLASS_NAME VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('CLASS_NAME'),:NEW.CLASS_NAME,:OLD.CLASS_NAME);
  o_CLASS_NAME VARCHAR2(4000) := :OLD.CLASS_NAME;
  n_NOM_LOC_ID VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('NOM_LOC_ID'),:NEW.NOM_LOC_ID,:OLD.NOM_LOC_ID);
  n_FORECAST_ID VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('FORECAST_ID'),:NEW.FORECAST_ID,:OLD.FORECAST_ID);
  o_FORECAST_ID VARCHAR2(4000) := :OLD.FORECAST_ID;
  n_daytime  DATE := EcDB_Utils.ConditionNVL(NOT Updating('DAYTIME'),:NEW.DAYTIME,:OLD.DAYTIME);
  o_daytime  DATE := :OLD.DAYTIME;

  n_rec_id  VARCHAR2(32) := :NEW.rec_id;

BEGIN

 --------------------------------------------------------------------------
 -- Start Before Trigger action block
 -- Need to find object_ids for foreign references given by code before we leave the control to user exit
 -- Also set record status columns in this section to allow user exits to overule them later

 IF INSERTING THEN -- set any default values from CLASS_ATTRIBUTE.DEFAULT_VALUE 

    NULL; -- In case there are no default values 

 END IF;  -- set any default values  

 IF INSERTING OR UPDATING THEN 


   IF TRUE
   THEN
      n_rev_no := n_rev_no + 1;
   END IF;


   IF INSERTING THEN
     n_created_by :=  Nvl(n_created_by,user);
     n_created_date := Nvl(n_created_date,Ecdp_Timestamp.getCurrentSysdate);
     n_RECORD_STATUS := Nvl(n_RECORD_STATUS,'P');
   ELSE  -- UPDATING
     IF  NOT UPDATING('LAST_UPDATED_BY') OR n_last_updated_by IS NULL THEN  n_last_updated_by := USER;  END IF;
     IF  NOT UPDATING('LAST_UPDATED_DATE') OR n_last_updated_date IS NULL THEN  n_last_updated_date := Ecdp_Timestamp.getCurrentSysdate;  END IF;
   END IF;  -- IF INSERTING

 END IF;  -- INSERTING OR UPDATING

 -- End Before Trigger Action block -------------------------------------------------
 -------------------------------------------------------------------------------

 --*************************************************************************************
 -- Start Trigger Action block
 -- Any code block defined as a BEFORE trigger-type in table CLASS_TRIGGER_ACTION will be put here

 --
 -- end Trigger Action block Class_trigger_actions before
 --*************************************************************************************

 IF INSERTING THEN

    -- Start Insert check block ---------------------------------------
    IF n_DAYTIME IS NULL THEN Raise_Application_Error(-20103,'Missing value for DAYTIME'); END IF;
    IF n_DAYTIME < EcDp_System_Constants.Earliest_date THEN  Raise_Application_Error(-20104,'Cannot set DAYTIME before system earliest date: 01.01.1900'); END IF;
    IF n_CLASS_NAME IS NULL THEN Raise_Application_Error(-20103,'Missing value for CLASS_NAME'); END IF;
    IF n_FORECAST_ID IS NULL THEN Raise_Application_Error(-20103,'Missing value for FORECAST_ID'); END IF;
    -- End Insert check block ---------------------------------------

  -- Start Insert relation block ---------------------------------------
    -- End Insert relation block ---------------------------------------
    INSERT INTO ECKERNEL_EC.V_FCST_RECOVERY_FACTOR(DAYTIME, CLASS_NAME, OBJECT_ID, FORECAST_ID,  CREATED_BY, CREATED_DATE, LAST_UPDATED_BY, LAST_UPDATED_DATE, REV_NO, REV_TEXT, RECORD_STATUS, REC_ID)
    VALUES(n_DAYTIME, n_CLASS_NAME, n_NOM_LOC_ID, n_FORECAST_ID,  n_CREATED_BY,n_CREATED_DATE, n_LAST_UPDATED_BY, n_LAST_UPDATED_DATE, n_REV_NO, n_REV_TEXT, n_RECORD_STATUS, n_rec_id) ;

  ELSIF UPDATING THEN 

    -- Start Update check block ---------------------------------------
    IF n_DAYTIME IS NULL THEN Raise_Application_Error(-20103,'Missing value for DAYTIME'); END IF;
    IF n_DAYTIME < EcDp_System_Constants.Earliest_date THEN  Raise_Application_Error(-20104,'Cannot set DAYTIME before system earliest date: 01.01.1900'); END IF;
    IF n_CLASS_NAME IS NULL THEN Raise_Application_Error(-20103,'Missing value for CLASS_NAME'); END IF;
    IF n_FORECAST_ID IS NULL THEN Raise_Application_Error(-20103,'Missing value for FORECAST_ID'); END IF;
    -- Start Update relation block
    -- End Update relation block
    UPDATE ECKERNEL_EC.V_FCST_RECOVERY_FACTOR SET DAYTIME = n_DAYTIME, CLASS_NAME = n_CLASS_NAME, OBJECT_ID = n_NOM_LOC_ID, FORECAST_ID = n_FORECAST_ID, CREATED_BY = n_CREATED_BY, CREATED_DATE = n_CREATED_DATE , LAST_UPDATED_BY = n_LAST_UPDATED_BY,LAST_UPDATED_DATE = n_LAST_UPDATED_DATE ,REV_NO = n_rev_no, REV_TEXT = n_REV_TEXT, RECORD_STATUS = n_RECORD_STATUS, REC_ID = n_rec_id
    WHERE DAYTIME= o_DAYTIME AND CLASS_NAME= o_CLASS_NAME AND FORECAST_ID= o_FORECAST_ID;

  ELSE -- Deleting 

     DELETE FROM ECKERNEL_EC.V_FCST_RECOVERY_FACTOR
     WHERE DAYTIME= o_DAYTIME AND CLASS_NAME= o_CLASS_NAME AND FORECAST_ID= o_FORECAST_ID;

  END IF; -- IF INSERTING  

 --*************************************************************************************
 -- Start Trigger action block
 -- Any code block defined as a AFTER trigger-type in table CLASS_TRIGGER_ACTION will be put here

 --
 -- end user exit block Class_trigger_actions after
 --*************************************************************************************

  END; -- TRIGGER IUD_FCST_RECOVERY_FACTOR_DAY

