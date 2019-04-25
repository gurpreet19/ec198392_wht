CREATE OR REPLACE EDITIONABLE TRIGGER "IUD_METER_DAY_COMPOSITION" 
 INSTEAD OF INSERT OR UPDATE OR DELETE ON DV_METER_DAY_COMPOSITION
 FOR EACH ROW
-- Generated by ecdp_viewlayer

DECLARE
  n_class_name         VARCHAR2(30) := EcDB_Utils.ConditionNVL(NOT Updating('CLASS_NAME'),:NEW.CLASS_NAME,:OLD.CLASS_NAME);
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
  n_ANALYSIS_NO NUMBER  := EcDB_Utils.ConditionNVL(NOT Updating('ANALYSIS_NO'),:NEW.ANALYSIS_NO,:OLD.ANALYSIS_NO);
  o_ANALYSIS_NO NUMBER  := :OLD.ANALYSIS_NO;
  n_OBJECT_ID VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('OBJECT_ID'),:NEW.OBJECT_ID,:OLD.OBJECT_ID);
  n_object_code VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('OBJECT_CODE'),:NEW.object_code,:OLD.object_code);
  n_ANALYSIS_STATUS VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('ANALYSIS_STATUS'),:NEW.ANALYSIS_STATUS,:OLD.ANALYSIS_STATUS);
  n_COMPONENT_ID VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('COMPONENT_ID'),:NEW.COMPONENT_ID,:OLD.COMPONENT_ID);
  o_COMPONENT_ID VARCHAR2(4000) := :OLD.COMPONENT_ID;
  n_COMPONENT_LABEL VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('COMPONENT_LABEL'),:NEW.COMPONENT_LABEL,:OLD.COMPONENT_LABEL);
  n_COMPONENT_VALUE NUMBER  := EcDB_Utils.ConditionNVL(NOT Updating('COMPONENT_VALUE'),:NEW.COMPONENT_VALUE,:OLD.COMPONENT_VALUE);
  n_COMPONENT_SORT_ORDER NUMBER  := EcDB_Utils.ConditionNVL(NOT Updating('COMPONENT_SORT_ORDER'),:NEW.COMPONENT_SORT_ORDER,:OLD.COMPONENT_SORT_ORDER);
  n_ANALYSIS_TYPE VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('ANALYSIS_TYPE'),:NEW.ANALYSIS_TYPE,:OLD.ANALYSIS_TYPE);
  n_daytime  DATE := EcDB_Utils.ConditionNVL(NOT Updating('DAYTIME'),:NEW.DAYTIME,:OLD.DAYTIME);

BEGIN

 --------------------------------------------------------------------------
 -- Start Before Trigger action block
 -- Need to find object_ids for foreign references given by code before we leave the control to user exit
 -- Also set record status columns in this section to allow user exits to overule them later

 IF INSERTING THEN -- set any default values from CLASS_ATTRIBUTE.DEFAULT_VALUE 

    NULL; -- In case there are no default values 

 END IF;  -- set any default values  

 IF INSERTING OR UPDATING THEN 

   -- Get object_id given object_code
   IF n_object_id IS NULL AND n_object_code IS NOT NULL THEN
      n_object_id := EcDp_Objects.GetObjIDFromCode('METER',n_object_code);
   END IF;

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
    IF n_Object_id IS NULL THEN Raise_Application_Error(-20103,'Missing value for object_id/object code'); END IF;
    IF n_DAYTIME IS NULL THEN Raise_Application_Error(-20103,'Missing value for DAYTIME'); END IF;
    IF n_DAYTIME < EcDp_System_Constants.Earliest_date THEN  Raise_Application_Error(-20104,'Cannot set DAYTIME before system earliest date: 01.01.1900'); END IF;
    IF n_ANALYSIS_STATUS IS NULL THEN Raise_Application_Error(-20103,'Missing value for ANALYSIS_STATUS'); END IF;
    IF n_COMPONENT_ID IS NULL THEN Raise_Application_Error(-20103,'Missing value for COMPONENT_ID'); END IF;
    IF n_COMPONENT_LABEL IS NULL THEN Raise_Application_Error(-20103,'Missing value for COMPONENT_LABEL'); END IF;
    IF n_COMPONENT_SORT_ORDER IS NULL THEN Raise_Application_Error(-20103,'Missing value for COMPONENT_SORT_ORDER'); END IF;
    -- End Insert check block ---------------------------------------

  -- Start Insert relation block ---------------------------------------
    IF ecdp_objects.isValidOwnerReference('METER_DAY_COMPOSITION',n_OBJECT_ID) = 'N'  THEN 
      Raise_Application_Error(-20106,'Given object id is not of the same class as the owner class for this data class.') ;
    END IF;

    -- End Insert relation block ---------------------------------------
    INSERT INTO  V_METER_COMPOSITION(ANALYSIS_NO, OBJECT_ID, DAYTIME, ANALYSIS_STATUS, COMPONENT_NO, COMPONENT_NAME, WT_PCT, SORT_ORDER, ANALYSIS_TYPE,  CREATED_BY, CREATED_DATE, LAST_UPDATED_BY, LAST_UPDATED_DATE, REV_NO, REV_TEXT, RECORD_STATUS)
    VALUES(n_ANALYSIS_NO, n_OBJECT_ID, n_DAYTIME, n_ANALYSIS_STATUS, n_COMPONENT_ID, n_COMPONENT_LABEL, n_COMPONENT_VALUE, n_COMPONENT_SORT_ORDER, n_ANALYSIS_TYPE,  n_CREATED_BY,n_CREATED_DATE, n_LAST_UPDATED_BY, n_LAST_UPDATED_DATE, n_REV_NO, n_REV_TEXT, n_RECORD_STATUS) ;

  ELSIF UPDATING THEN 

    -- Start Update check block ---------------------------------------
    IF n_DAYTIME IS NULL THEN Raise_Application_Error(-20103,'Missing value for DAYTIME'); END IF;
    IF n_DAYTIME < EcDp_System_Constants.Earliest_date THEN  Raise_Application_Error(-20104,'Cannot set DAYTIME before system earliest date: 01.01.1900'); END IF;
    IF n_ANALYSIS_STATUS IS NULL THEN Raise_Application_Error(-20103,'Missing value for ANALYSIS_STATUS'); END IF;
    IF n_COMPONENT_ID IS NULL THEN Raise_Application_Error(-20103,'Missing value for COMPONENT_ID'); END IF;
    IF n_COMPONENT_LABEL IS NULL THEN Raise_Application_Error(-20103,'Missing value for COMPONENT_LABEL'); END IF;
    IF n_COMPONENT_SORT_ORDER IS NULL THEN Raise_Application_Error(-20103,'Missing value for COMPONENT_SORT_ORDER'); END IF;
    -- Start Update relation block
      IF Updating('OBJECT_ID') THEN
          IF NOT (Nvl(:NEW.object_id,'NULL') = :OLD.object_id) THEN
             Raise_Application_Error(-20101,'Cannot update object_id ');
          END IF;
      END IF;
    -- End Update relation block
    UPDATE  V_METER_COMPOSITION SET ANALYSIS_NO = n_ANALYSIS_NO, OBJECT_ID = n_OBJECT_ID, DAYTIME = n_DAYTIME, ANALYSIS_STATUS = n_ANALYSIS_STATUS, COMPONENT_NO = n_COMPONENT_ID, COMPONENT_NAME = n_COMPONENT_LABEL, WT_PCT = n_COMPONENT_VALUE, SORT_ORDER = n_COMPONENT_SORT_ORDER, ANALYSIS_TYPE = n_ANALYSIS_TYPE, CREATED_BY = n_CREATED_BY, CREATED_DATE = n_CREATED_DATE , LAST_UPDATED_BY = n_LAST_UPDATED_BY,LAST_UPDATED_DATE = n_LAST_UPDATED_DATE ,REV_NO = n_rev_no, REV_TEXT = n_REV_TEXT, RECORD_STATUS = n_RECORD_STATUS
    WHERE ANALYSIS_NO= o_ANALYSIS_NO AND COMPONENT_NO= o_COMPONENT_ID;

  ELSE -- Deleting 

     DELETE FROM  V_METER_COMPOSITION
     WHERE ANALYSIS_NO= o_ANALYSIS_NO AND COMPONENT_NO= o_COMPONENT_ID;

  END IF; -- IF INSERTING  

 --*************************************************************************************
 -- Start Trigger action block
 -- Any code block defined as a AFTER trigger-type in table CLASS_TRIGGER_ACTION will be put here

 IF UPDATING THEN 

ecdp_meter_measurement.setMeterCompStatus(n_analysis_no,n_last_updated_by);

 END IF;

 --
 -- end user exit block Class_trigger_actions after
 --*************************************************************************************

  END; -- TRIGGER IUD_METER_DAY_COMPOSITION

