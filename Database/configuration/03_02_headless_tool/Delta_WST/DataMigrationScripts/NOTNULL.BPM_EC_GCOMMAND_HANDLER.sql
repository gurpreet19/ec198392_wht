--First Update all records with sort_order null to have value 0
DECLARE
  HASENTRY NUMBER;
  sqlQuery clob := 'UPDATE BPM_EC_GCOMMAND_HANDLER SET SORT_ORDER = 0 WHERE SORT_ORDER IS NULL';
BEGIN
  SELECT COUNT(*)
    INTO HASENTRY
    FROM USER_TRIGGERS
   WHERE TRIGGER_NAME = 'IU_BPM_EC_GCOMMAND_HANDLER';
  IF HASENTRY > 0 THEN
    EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_EC_GCOMMAND_HANDLER DISABLE';
  END IF;
  EXECUTE IMMEDIATE sqlQuery;
  dbms_output.put_line('SUCCESS: ' || sqlQuery);
  dbms_output.put_line('No of Rows Updated:' || sql%rowcount);
  IF HASENTRY > 0 THEN
    EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_EC_GCOMMAND_HANDLER ENABLE';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF HASENTRY > 0 THEN
    EXECUTE IMMEDIATE 'ALTER TRIGGER IU_BPM_EC_GCOMMAND_HANDLER ENABLE';
  END IF;
    --UPDATE_MILESTONE_WITH_ERROR('pre_table_column_not_null');
    raise_application_error(-20000, 'FATAL  ERROR: ' || sqlerrm);
END;
--~^UTDELIM^~--