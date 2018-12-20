CREATE OR REPLACE EDITIONABLE TRIGGER "IUD_CNTR_INV_DAY_OPER_MATRIX" 
 INSTEAD OF INSERT OR UPDATE OR DELETE ON DV_CNTR_INV_DAY_OPER_MATRIX
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
  n_TRANSACTION_SEQ NUMBER  := EcDB_Utils.ConditionNVL(NOT Updating('TRANSACTION_SEQ'),:NEW.TRANSACTION_SEQ,:OLD.TRANSACTION_SEQ);
  n_CONTRACT_ID VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('CONTRACT_ID'),:NEW.CONTRACT_ID,:OLD.CONTRACT_ID);
  o_CONTRACT_ID VARCHAR2(4000) := :OLD.CONTRACT_ID;
  n_LOCATION_ID VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('LOCATION_ID'),:NEW.LOCATION_ID,:OLD.LOCATION_ID);
  o_LOCATION_ID VARCHAR2(4000) := :OLD.LOCATION_ID;
  n_INVENTORY_TYPE VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('INVENTORY_TYPE'),:NEW.INVENTORY_TYPE,:OLD.INVENTORY_TYPE);
  o_INVENTORY_TYPE VARCHAR2(4000) := :OLD.INVENTORY_TYPE;
  n_OBJECT_ID VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('OBJECT_ID'),:NEW.OBJECT_ID,:OLD.OBJECT_ID);
  n_object_code VARCHAR2(4000) := EcDB_Utils.ConditionNVL(NOT Updating('OBJECT_CODE'),:NEW.object_code,:OLD.object_code);
  n_DEBIT_QTY NUMBER  := EcDB_Utils.ConditionNVL(NOT Updating('DEBIT_QTY'),:NEW.DEBIT_QTY,:OLD.DEBIT_QTY);
  n_CREDIT_QTY NUMBER  := EcDB_Utils.ConditionNVL(NOT Updating('CREDIT_QTY'),:NEW.CREDIT_QTY,:OLD.CREDIT_QTY);
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
      n_object_id := EcDp_Objects.GetObjIDFromCode('CONTRACT_INVENTORY',n_object_code);
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

 IF UPDATING THEN 

ecdp_contract_inventory.checkTransSign(n_debit_qty, n_credit_qty);

 END IF;

 --
 -- end Trigger Action block Class_trigger_actions before
 --*************************************************************************************

 IF INSERTING THEN

    -- Start Insert check block ---------------------------------------
    IF n_Object_id IS NULL THEN Raise_Application_Error(-20103,'Missing value for object_id/object code'); END IF;
    IF n_DAYTIME IS NULL THEN Raise_Application_Error(-20103,'Missing value for DAYTIME'); END IF;
    IF n_DAYTIME < EcDp_System_Constants.Earliest_date THEN  Raise_Application_Error(-20104,'Cannot set DAYTIME before system earliest date: 01.01.1900'); END IF;
    IF n_CONTRACT_ID IS NULL THEN Raise_Application_Error(-20103,'Missing value for CONTRACT_ID'); END IF;
    IF n_LOCATION_ID IS NULL THEN Raise_Application_Error(-20103,'Missing value for LOCATION_ID'); END IF;
    IF n_INVENTORY_TYPE IS NULL THEN Raise_Application_Error(-20103,'Missing value for INVENTORY_TYPE'); END IF;
    -- End Insert check block ---------------------------------------

  -- Start Insert relation block ---------------------------------------
    IF ecdp_objects.isValidOwnerReference('CNTR_INV_DAY_OPER_MATRIX',n_OBJECT_ID) = 'N'  THEN 
      Raise_Application_Error(-20106,'Given object id is not of the same class as the owner class for this data class.') ;
    END IF;

    IF TRUNC(EcDp_Objects.getOBjStartDate(n_object_id)) > n_daytime THEN
       RAISE_APPLICATION_ERROR(-20128,'Daytime is less than owner object start date.');
    END IF;

    IF n_Daytime >= nvl(EcDp_Objects.getObjEndDate(n_object_id),n_Daytime + 1) THEN
       Raise_Application_Error(-20129,'Daytime must be less than owner object end date.');
    END IF;

    -- End Insert relation block ---------------------------------------
    INSERT INTO ECKERNEL_EC12SRC.V_CNTR_INV_OPER_MATRIX(TRANSACTION_SEQ, DAYTIME, CONTRACT_ID, LOCATION_ID, INVENTORY_TYPE, OBJECT_ID, DEBIT_QTY, CREDIT_QTY,  CREATED_BY, CREATED_DATE, LAST_UPDATED_BY, LAST_UPDATED_DATE, REV_NO, REV_TEXT, RECORD_STATUS)
    VALUES(n_TRANSACTION_SEQ, n_DAYTIME, n_CONTRACT_ID, n_LOCATION_ID, n_INVENTORY_TYPE, n_OBJECT_ID, n_DEBIT_QTY, n_CREDIT_QTY,  n_CREATED_BY,n_CREATED_DATE, n_LAST_UPDATED_BY, n_LAST_UPDATED_DATE, n_REV_NO, n_REV_TEXT, n_RECORD_STATUS) ;

  ELSIF UPDATING THEN 

    -- Start Update check block ---------------------------------------
    IF n_DAYTIME IS NULL THEN Raise_Application_Error(-20103,'Missing value for DAYTIME'); END IF;
    IF n_DAYTIME < EcDp_System_Constants.Earliest_date THEN  Raise_Application_Error(-20104,'Cannot set DAYTIME before system earliest date: 01.01.1900'); END IF;
    IF n_CONTRACT_ID IS NULL THEN Raise_Application_Error(-20103,'Missing value for CONTRACT_ID'); END IF;
    IF n_LOCATION_ID IS NULL THEN Raise_Application_Error(-20103,'Missing value for LOCATION_ID'); END IF;
    IF n_INVENTORY_TYPE IS NULL THEN Raise_Application_Error(-20103,'Missing value for INVENTORY_TYPE'); END IF;
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
    UPDATE ECKERNEL_EC12SRC.V_CNTR_INV_OPER_MATRIX SET TRANSACTION_SEQ = n_TRANSACTION_SEQ, DAYTIME = n_DAYTIME, CONTRACT_ID = n_CONTRACT_ID, LOCATION_ID = n_LOCATION_ID, INVENTORY_TYPE = n_INVENTORY_TYPE, OBJECT_ID = n_OBJECT_ID, DEBIT_QTY = n_DEBIT_QTY, CREDIT_QTY = n_CREDIT_QTY, CREATED_BY = n_CREATED_BY, CREATED_DATE = n_CREATED_DATE , LAST_UPDATED_BY = n_LAST_UPDATED_BY,LAST_UPDATED_DATE = n_LAST_UPDATED_DATE ,REV_NO = n_rev_no, REV_TEXT = n_REV_TEXT, RECORD_STATUS = n_RECORD_STATUS
    WHERE DAYTIME= o_DAYTIME AND CONTRACT_ID= o_CONTRACT_ID AND LOCATION_ID= o_LOCATION_ID AND INVENTORY_TYPE= o_INVENTORY_TYPE;

  ELSE -- Deleting 

     DELETE FROM ECKERNEL_EC12SRC.V_CNTR_INV_OPER_MATRIX
     WHERE DAYTIME= o_DAYTIME AND CONTRACT_ID= o_CONTRACT_ID AND LOCATION_ID= o_LOCATION_ID AND INVENTORY_TYPE= o_INVENTORY_TYPE;

  END IF; -- IF INSERTING  

 --*************************************************************************************
 -- Start Trigger action block
 -- Any code block defined as a AFTER trigger-type in table CLASS_TRIGGER_ACTION will be put here

 --
 -- end user exit block Class_trigger_actions after
 --*************************************************************************************

  END; -- TRIGGER IUD_CNTR_INV_DAY_OPER_MATRIX
