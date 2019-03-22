CREATE OR REPLACE EDITIONABLE TRIGGER "IUD_STRM_COMP_ANALYSIS" 
 INSTEAD OF INSERT OR UPDATE OR DELETE ON DV_STRM_COMP_ANALYSIS
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
  n_OBJECT_ID VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('OBJECT_ID'),:NEW.OBJECT_ID,:OLD.OBJECT_ID);
  n_object_code VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('OBJECT_CODE'),:NEW.object_code,:OLD.object_code);
  o_OBJECT_ID VARCHAR2(4000) := :OLD.OBJECT_ID;
  n_ANALYSIS_TYPE VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('ANALYSIS_TYPE'),:NEW.ANALYSIS_TYPE,:OLD.ANALYSIS_TYPE);
  o_ANALYSIS_TYPE VARCHAR2(4000) := :OLD.ANALYSIS_TYPE;
  n_SAMPLING_METHOD VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('SAMPLING_METHOD'),:NEW.SAMPLING_METHOD,:OLD.SAMPLING_METHOD);
  o_SAMPLING_METHOD VARCHAR2(4000) := :OLD.SAMPLING_METHOD;
  n_PHASE VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('PHASE'),:NEW.PHASE,:OLD.PHASE);
  o_PHASE VARCHAR2(4000) := :OLD.PHASE;
  n_ANALYSIS_NO NUMBER  := EcDB_Utils.ConditionNVL(NOT Updating('ANALYSIS_NO'),:NEW.ANALYSIS_NO,:OLD.ANALYSIS_NO);
  n_OBJECT_CLASS_NAME VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('OBJECT_CLASS_NAME'),:NEW.OBJECT_CLASS_NAME,:OLD.OBJECT_CLASS_NAME);
  n_WT_PCT NUMBER  := EcDB_Utils.ConditionNVL(NOT Updating('WT_PCT'),:NEW.WT_PCT,:OLD.WT_PCT);
  n_MOL_PCT NUMBER  := EcDB_Utils.ConditionNVL(NOT Updating('MOL_PCT'),:NEW.MOL_PCT,:OLD.MOL_PCT);
  n_COMPONENT_NO VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('COMPONENT_NO'),:NEW.COMPONENT_NO,:OLD.COMPONENT_NO);
  o_COMPONENT_NO VARCHAR2(4000) := :OLD.COMPONENT_NO;
  n_MOL_WT NUMBER  := EcDB_Utils.ConditionNVL(NOT Updating('MOL_WT'),:NEW.MOL_WT,:OLD.MOL_WT);
  n_DENSITY NUMBER  := EcDB_Utils.ConditionNVL(NOT Updating('DENSITY'),:NEW.DENSITY,:OLD.DENSITY);
  n_daytime  DATE := EcDB_Utils.ConditionNVL(NOT Updating('DAYTIME'),:NEW.DAYTIME,:OLD.DAYTIME);
  o_daytime  DATE := :OLD.DAYTIME;


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
      n_object_id := EcDp_Objects.GetObjIDFromCode('STREAM',n_object_code);
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
    IF n_ANALYSIS_TYPE IS NULL THEN Raise_Application_Error(-20103,'Missing value for ANALYSIS_TYPE'); END IF;
    IF n_SAMPLING_METHOD IS NULL THEN Raise_Application_Error(-20103,'Missing value for SAMPLING_METHOD'); END IF;
    IF n_PHASE IS NULL THEN Raise_Application_Error(-20103,'Missing value for PHASE'); END IF;
    IF n_COMPONENT_NO IS NULL THEN Raise_Application_Error(-20103,'Missing value for COMPONENT_NO'); END IF;
    -- End Insert check block ---------------------------------------

  -- Start Insert relation block ---------------------------------------
    IF ecdp_objects.isValidOwnerReference('STRM_COMP_ANALYSIS',n_OBJECT_ID) = 'N'  THEN 
      Raise_Application_Error(-20106,'Given object id is not of the same class as the owner class for this data class.') ;
    END IF;

    IF TRUNC(EcDp_Objects.getOBjStartDate(n_object_id)) > n_daytime THEN
       RAISE_APPLICATION_ERROR(-20128,'Daytime is less than owner object start date.');
    END IF;

    IF n_Daytime >= nvl(EcDp_Objects.getObjEndDate(n_object_id),n_Daytime + 1) THEN
       Raise_Application_Error(-20129,'Daytime must be less than owner object end date.');
    END IF;

    -- End Insert relation block ---------------------------------------
    INSERT INTO ECKERNEL_EC.V_FLUID_ANALYSIS_COMP(OBJECT_ID, DAYTIME, ANALYSIS_TYPE, SAMPLING_METHOD, PHASE, ANALYSIS_NO, OBJECT_CLASS_NAME, WT_PCT, MOL_PCT, COMPONENT_NO, MOL_WT, DENSITY,  CREATED_BY, CREATED_DATE, LAST_UPDATED_BY, LAST_UPDATED_DATE, REV_NO, REV_TEXT, RECORD_STATUS)
    VALUES(n_OBJECT_ID, n_DAYTIME, n_ANALYSIS_TYPE, n_SAMPLING_METHOD, n_PHASE, n_ANALYSIS_NO, n_OBJECT_CLASS_NAME, n_WT_PCT, n_MOL_PCT, n_COMPONENT_NO, n_MOL_WT, n_DENSITY,  n_CREATED_BY,n_CREATED_DATE, n_LAST_UPDATED_BY, n_LAST_UPDATED_DATE, n_REV_NO, n_REV_TEXT, n_RECORD_STATUS) ;

  ELSIF UPDATING THEN 

    -- Start Update check block ---------------------------------------
    IF n_DAYTIME IS NULL THEN Raise_Application_Error(-20103,'Missing value for DAYTIME'); END IF;
    IF n_DAYTIME < EcDp_System_Constants.Earliest_date THEN  Raise_Application_Error(-20104,'Cannot set DAYTIME before system earliest date: 01.01.1900'); END IF;
    IF n_ANALYSIS_TYPE IS NULL THEN Raise_Application_Error(-20103,'Missing value for ANALYSIS_TYPE'); END IF;
    IF n_SAMPLING_METHOD IS NULL THEN Raise_Application_Error(-20103,'Missing value for SAMPLING_METHOD'); END IF;
    IF n_PHASE IS NULL THEN Raise_Application_Error(-20103,'Missing value for PHASE'); END IF;
    IF n_COMPONENT_NO IS NULL THEN Raise_Application_Error(-20103,'Missing value for COMPONENT_NO'); END IF;
    -- Start Update relation block
      IF Updating('OBJECT_ID') THEN
          IF NOT (Nvl(:NEW.object_id,'NULL') = :OLD.object_id) THEN
             Raise_Application_Error(-20101,'Cannot update object_id ');
          END IF;
      END IF;

    IF Updating('DAYTIME') THEN

       IF TRUNC(EcDp_Objects.getOBjStartDate(n_object_id)) > n_daytime THEN
          RAISE_APPLICATION_ERROR(-20128,'Daytime is less than owner object start date.');
       END IF;

       IF n_Daytime >= nvl(EcDp_Objects.getObjEndDate(n_object_id),n_Daytime + 1) THEN
          Raise_Application_Error(-20129,'Daytime must be less than owner object end date.');
       END IF;

    END IF;

    -- End Update relation block
    UPDATE ECKERNEL_EC.V_FLUID_ANALYSIS_COMP SET OBJECT_ID = n_OBJECT_ID, DAYTIME = n_DAYTIME, ANALYSIS_TYPE = n_ANALYSIS_TYPE, SAMPLING_METHOD = n_SAMPLING_METHOD, PHASE = n_PHASE, ANALYSIS_NO = n_ANALYSIS_NO, OBJECT_CLASS_NAME = n_OBJECT_CLASS_NAME, WT_PCT = n_WT_PCT, MOL_PCT = n_MOL_PCT, COMPONENT_NO = n_COMPONENT_NO, MOL_WT = n_MOL_WT, DENSITY = n_DENSITY, CREATED_BY = n_CREATED_BY, CREATED_DATE = n_CREATED_DATE , LAST_UPDATED_BY = n_LAST_UPDATED_BY,LAST_UPDATED_DATE = n_LAST_UPDATED_DATE ,REV_NO = n_rev_no, REV_TEXT = n_REV_TEXT, RECORD_STATUS = n_RECORD_STATUS
    WHERE OBJECT_ID= o_OBJECT_ID AND DAYTIME= o_DAYTIME AND ANALYSIS_TYPE= o_ANALYSIS_TYPE AND SAMPLING_METHOD= o_SAMPLING_METHOD AND PHASE= o_PHASE AND COMPONENT_NO= o_COMPONENT_NO;

  ELSE -- Deleting 

     DELETE FROM ECKERNEL_EC.V_FLUID_ANALYSIS_COMP
     WHERE OBJECT_ID= o_OBJECT_ID AND DAYTIME= o_DAYTIME AND ANALYSIS_TYPE= o_ANALYSIS_TYPE AND SAMPLING_METHOD= o_SAMPLING_METHOD AND PHASE= o_PHASE AND COMPONENT_NO= o_COMPONENT_NO;

  END IF; -- IF INSERTING  

 --*************************************************************************************
 -- Start Trigger action block
 -- Any code block defined as a AFTER trigger-type in table CLASS_TRIGGER_ACTION will be put here

 --
 -- end user exit block Class_trigger_actions after
 --*************************************************************************************

  END; -- TRIGGER IUD_STRM_COMP_ANALYSIS

