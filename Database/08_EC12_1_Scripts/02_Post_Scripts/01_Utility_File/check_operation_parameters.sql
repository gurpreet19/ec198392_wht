Prompt Starting check_operation_parameters.sql, arg1: &&operation
-- Validates the operation parameters entered by the user on installation time.
-- Should be able to run it connected as SYSTEM or ECKERNEL users.

-- Validates the operation parameters entered by the user on installation time.
-- Should be able to run it connected as SYSTEM or ECKERNEL users.

WHENEVER SQLERROR EXIT SQL.SQLCODE;

DECLARE
 lv2_operation varchar2(32) := RTRIM('&operation');
 ln_count NUMBER;
BEGIN

  IF rtrim(lv2_operation) IS NULL THEN
     RAISE_APPLICATION_ERROR( -20000, 'The entered value for the operation must be an upper case short code without whitespaces.');
  END IF;
  
  IF lv2_operation <> UPPER(LTRIM(lv2_operation)) THEN
     RAISE_APPLICATION_ERROR( -20000, 'The entered value for the operation must be an upper case short code without whitespaces.');
  END IF;

  SELECT count(*)
  INTO ln_count
  FROM user_tablespaces
  WHERE tablespace_name = UPPER('&ts_data');
  
  IF ln_count = 0 THEN
     RAISE_APPLICATION_ERROR( -20000, 'The entered data tablespace ts_data=''&ts_data'' was not found.');
  END IF;

  SELECT count(*)
  INTO ln_count
  FROM user_tablespaces
  WHERE tablespace_name = UPPER('&ts_index');
  
  IF ln_count = 0 THEN
     RAISE_APPLICATION_ERROR( -20000, 'The entered index tablespace ts_index=''&ts_index'' was not found.');
  END IF;

END;
/

WHENEVER SQLERROR CONTINUE;
