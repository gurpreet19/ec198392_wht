CREATE OR REPLACE EDITIONABLE TRIGGER "IUD_CALC_OBJECT_FILTER" 
 INSTEAD OF INSERT OR UPDATE OR DELETE ON DV_CALC_OBJECT_FILTER
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
  n_OBJECT_TYPE_CODE VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('OBJECT_TYPE_CODE'),:NEW.OBJECT_TYPE_CODE,:OLD.OBJECT_TYPE_CODE);
  o_OBJECT_TYPE_CODE VARCHAR2(4000) := :OLD.OBJECT_TYPE_CODE;
  n_IMPL_CLASS_NAME VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('IMPL_CLASS_NAME'),:NEW.IMPL_CLASS_NAME,:OLD.IMPL_CLASS_NAME);
  o_IMPL_CLASS_NAME VARCHAR2(4000) := :OLD.IMPL_CLASS_NAME;
  n_SQL_SYNTAX VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('SQL_SYNTAX'),:NEW.SQL_SYNTAX,:OLD.SQL_SYNTAX);
  o_SQL_SYNTAX VARCHAR2(4000) := :OLD.SQL_SYNTAX;
  n_CALC_OBJ_ATTR_FILTER VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('CALC_OBJ_ATTR_FILTER'),:NEW.CALC_OBJ_ATTR_FILTER,:OLD.CALC_OBJ_ATTR_FILTER);
  n_PARAMETER_FILTER VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('PARAMETER_FILTER'),:NEW.PARAMETER_FILTER,:OLD.PARAMETER_FILTER);
  n_daytime  DATE := EcDp_Objects.getObjStartDate(n_object_id);


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
      n_object_id := EcDp_Objects.GetObjIDFromCode('CALC_CONTEXT',n_object_code);
   END IF;

   IF FALSE
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
    -- End Insert check block ---------------------------------------

  -- Start Insert relation block ---------------------------------------
    IF ecdp_objects.isValidOwnerReference('CALC_OBJECT_FILTER',n_OBJECT_ID) = 'N'  THEN 
      Raise_Application_Error(-20106,'Given object id is not of the same class as the owner class for this data class.') ;
    END IF;

    -- End Insert relation block ---------------------------------------
    INSERT INTO ECKERNEL_EC12SRC.V_CALC_OBJECT_FILTER(OBJECT_ID, OBJECT_TYPE_CODE, IMPL_CLASS_NAME, SQL_SYNTAX, CALC_OBJ_ATTR_FILTER, PARAMETER_FILTER,  CREATED_BY, CREATED_DATE, LAST_UPDATED_BY, LAST_UPDATED_DATE, REV_NO, REV_TEXT, RECORD_STATUS)
    VALUES(n_OBJECT_ID, n_OBJECT_TYPE_CODE, n_IMPL_CLASS_NAME, n_SQL_SYNTAX, n_CALC_OBJ_ATTR_FILTER, n_PARAMETER_FILTER,  n_CREATED_BY,n_CREATED_DATE, n_LAST_UPDATED_BY, n_LAST_UPDATED_DATE, n_REV_NO, n_REV_TEXT, n_RECORD_STATUS) ;

  ELSIF UPDATING THEN 

    -- Start Update check block ---------------------------------------
    -- Start Update relation block
      IF Updating('OBJECT_ID') THEN
          IF NOT (Nvl(:NEW.object_id,'NULL') = :OLD.object_id) THEN
             Raise_Application_Error(-20101,'Cannot update object_id ');
          END IF;
      END IF;
    -- End Update relation block
    UPDATE ECKERNEL_EC12SRC.V_CALC_OBJECT_FILTER SET OBJECT_ID = n_OBJECT_ID, OBJECT_TYPE_CODE = n_OBJECT_TYPE_CODE, IMPL_CLASS_NAME = n_IMPL_CLASS_NAME, SQL_SYNTAX = n_SQL_SYNTAX, CALC_OBJ_ATTR_FILTER = n_CALC_OBJ_ATTR_FILTER, PARAMETER_FILTER = n_PARAMETER_FILTER, CREATED_BY = n_CREATED_BY, CREATED_DATE = n_CREATED_DATE , LAST_UPDATED_BY = n_LAST_UPDATED_BY,LAST_UPDATED_DATE = n_LAST_UPDATED_DATE ,REV_NO = n_rev_no, REV_TEXT = n_REV_TEXT, RECORD_STATUS = n_RECORD_STATUS
    WHERE OBJECT_ID= o_OBJECT_ID AND OBJECT_TYPE_CODE= o_OBJECT_TYPE_CODE AND IMPL_CLASS_NAME= o_IMPL_CLASS_NAME AND SQL_SYNTAX= o_SQL_SYNTAX;

  ELSE -- Deleting 

     DELETE FROM ECKERNEL_EC12SRC.V_CALC_OBJECT_FILTER
     WHERE OBJECT_ID= o_OBJECT_ID AND OBJECT_TYPE_CODE= o_OBJECT_TYPE_CODE AND IMPL_CLASS_NAME= o_IMPL_CLASS_NAME AND SQL_SYNTAX= o_SQL_SYNTAX;

  END IF; -- IF INSERTING  

 --*************************************************************************************
 -- Start Trigger action block
 -- Any code block defined as a AFTER trigger-type in table CLASS_TRIGGER_ACTION will be put here

 --
 -- end user exit block Class_trigger_actions after
 --*************************************************************************************

  END; -- TRIGGER IUD_CALC_OBJECT_FILTER

