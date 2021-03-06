--BELOW UPGRADE SCRIPT WILL BE USED TO INSERT DATA IN NEWLY ADDED COLUMN PRODUCTION DAY BASED ON THE OFFSET_DAY SETTING
DECLARE
  sqlQuery clob := 'UPDATE OBJECT_PLAN  SET PRODUCTION_DAY = ECDP_PRODUCTIONDAY.GETPRODUCTIONDAY(NULL, OBJECT_ID, DAYTIME) WHERE PRODUCTION_DAY IS NULL';
  HASENTRY NUMBER;
BEGIN
  SELECT COUNT(*)
    INTO HASENTRY
    FROM USER_TRIGGERS
   WHERE TRIGGER_NAME = 'IU_OBJECT_PLAN';
  IF HASENTRY > 0 THEN
    EXECUTE IMMEDIATE 'ALTER TRIGGER IU_OBJECT_PLAN DISABLE';
  END IF;
  EXECUTE IMMEDIATE sqlQuery;
  dbms_output.put_line('SUCCESS: ' || sqlQuery);
  IF HASENTRY > 0 THEN
    EXECUTE IMMEDIATE 'ALTER TRIGGER IU_OBJECT_PLAN ENABLE';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF HASENTRY > 0 THEN
    EXECUTE IMMEDIATE 'ALTER TRIGGER IU_OBJECT_PLAN ENABLE';
  END IF;
    --UPDATE_MILESTONE_WITH_ERROR('post_add_table_column');
    raise_application_error(-20000, 'FATAL  ERROR: ' || sqlerrm);
END;
--~^UTDELIM^~--
