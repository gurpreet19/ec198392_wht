DECLARE
  sqlQuery clob := 'UPDATE STATUS_PROCESS A SET A.REVERSE_FLAG=''N'' WHERE A.REVERSE_FLAG IS NULL';
  HASENTRY NUMBER;
BEGIN
  SELECT COUNT(*)
    INTO HASENTRY
    FROM USER_TRIGGERS
   WHERE TRIGGER_NAME = 'IU_STATUS_PROCESS';
  IF HASENTRY > 0 THEN
    EXECUTE IMMEDIATE 'ALTER TRIGGER IU_STATUS_PROCESS DISABLE';
  END IF;
  EXECUTE IMMEDIATE sqlQuery;
  IF HASENTRY > 0 THEN
    EXECUTE IMMEDIATE 'ALTER TRIGGER IU_STATUS_PROCESS ENABLE';
  END IF;
  dbms_output.put_line('SUCCESS: ' || sqlQuery);
EXCEPTION
  WHEN OTHERS THEN
  IF HASENTRY > 0 THEN
    EXECUTE IMMEDIATE 'ALTER TRIGGER IU_STATUS_PROCESS ENABLE';
  END IF;
    --UPDATE_MILESTONE_WITH_ERROR('post_add_table_column');
    raise_application_error(-20000, 'FATAL  ERROR: ' || sqlerrm);
END;
--~^UTDELIM^~--
