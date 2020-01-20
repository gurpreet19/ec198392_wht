----------------------------------------------------------------------------------------------
-- recreating job 61
----------------------------------------------------------------------------------------------
DECLARE
  user_name varchar2(30);
  BEGIN
    select user into user_name from dual;
    execute immediate 'alter session set current_schema = ' || user_name;
    BEGIN
      SYS.DBMS_JOB.REMOVE(61);
      execute immediate 'alter session set current_schema = ' || user_name;
    EXCEPTION
      WHEN OTHERS THEN
        execute immediate 'alter session set current_schema = ' || user_name;
        RAISE;
  END;
  COMMIT;
END;
/

DECLARE
  x NUMBER;
  user_name varchar2(30);
BEGIN
  select user into  user_name from dual;
  execute immediate 'alter session set current_schema = ' || user_name;
  BEGIN
  sys.dbms_job.submit(job => x,
                      what => 'ec_Bs_Instantiate.new_day_start(trunc(EcDp_Date_Time.getCurrentSysdate));',
                      next_date => trunc(sysdate) + 1,
                      interval => 'trunc(sysdate) + 1',
					  no_parse  => FALSE);
  commit;
    SYS.DBMS_OUTPUT.PUT_LINE('Job Number is: ' || to_char(x));
    execute immediate 'alter session set current_schema = ' || user_name;
  EXCEPTION
    WHEN OTHERS THEN
      execute immediate 'alter session set current_schema = ' || user_name;
      RAISE;
  END;
  COMMIT;
END;
/
----------------------------------------------------------------------------------------------
-- recreating job 62 
----------------------------------------------------------------------------------------------
DECLARE
  user_name varchar2(30);
  BEGIN
    select user into user_name from dual;
    execute immediate 'alter session set current_schema = ' || user_name;
    BEGIN
      SYS.DBMS_JOB.REMOVE(62);
      execute immediate 'alter session set current_schema = ' || user_name;
    EXCEPTION
      WHEN OTHERS THEN
        execute immediate 'alter session set current_schema = ' || user_name;
        RAISE;
  END;
  COMMIT;
END;
/

DECLARE
  x NUMBER;
  user_name varchar2(30);
BEGIN
  select user into  user_name from dual;
  execute immediate 'alter session set current_schema = ' || user_name;
  BEGIN
  sys.dbms_job.submit(job => x,
                      what => 'ec_Bs_Instantiate.new_day_end(trunc(EcDp_Date_Time.getCurrentSysdate));',
                      next_date => trunc(sysdate+1)+23/24 + 50/24/60,
                      interval => 'trunc(sysdate+1)+23/24 + 50/24/60',
					  no_parse  => FALSE);
  commit;
    SYS.DBMS_OUTPUT.PUT_LINE('Job Number is: ' || to_char(x));
    execute immediate 'alter session set current_schema = ' || user_name;
  EXCEPTION
    WHEN OTHERS THEN
      execute immediate 'alter session set current_schema = ' || user_name;
      RAISE;
  END;
  COMMIT;
END;
/

----------------------------------------------------------------------------------------------
-- recreating job 63 
----------------------------------------------------------------------------------------------
DECLARE
  user_name varchar2(30);
  BEGIN
    select user into user_name from dual;
    execute immediate 'alter session set current_schema = ' || user_name;
    BEGIN
      SYS.DBMS_JOB.REMOVE(63);
      execute immediate 'alter session set current_schema = ' || user_name;
    EXCEPTION
      WHEN OTHERS THEN
        execute immediate 'alter session set current_schema = ' || user_name;
        RAISE;
  END;
  COMMIT;
END;
/

DECLARE
  x NUMBER;
  user_name varchar2(30);
BEGIN
  select user into  user_name from dual;
  execute immediate 'alter session set current_schema = ' || user_name;
  BEGIN
  sys.dbms_job.submit(job => x,
                      what => 'ue_bs_instantiate.new_day_end(trunc(EcDp_Date_Time.getCurrentSysdate));',
                      next_date => trunc(sysdate +1)+23/24 + 51/24/60,
                      interval => 'trunc(sysdate +1)+23/24 + 51/24/60',
					  no_parse  => FALSE);
  commit;
    SYS.DBMS_OUTPUT.PUT_LINE('Job Number is: ' || to_char(x));
    execute immediate 'alter session set current_schema = ' || user_name;
  EXCEPTION
    WHEN OTHERS THEN
      execute immediate 'alter session set current_schema = ' || user_name;
      RAISE;
  END;
  COMMIT;
END;
/
----------------------------------------------------------------------------------------------
-- recreating job 101 
----------------------------------------------------------------------------------------------
DECLARE
  user_name varchar2(30);
  BEGIN
    select user into user_name from dual;
    execute immediate 'alter session set current_schema = ' || user_name;
    BEGIN
      SYS.DBMS_JOB.REMOVE(101);
      execute immediate 'alter session set current_schema = ' || user_name;
    EXCEPTION
      WHEN OTHERS THEN
        execute immediate 'alter session set current_schema = ' || user_name;
        RAISE;
  END;
  COMMIT;
END;
/

DECLARE
  x NUMBER;
  user_name varchar2(30);
BEGIN
  select user into  user_name from dual;
  execute immediate 'alter session set current_schema = ' || user_name;
  BEGIN
  sys.dbms_job.submit(job => x,
                      what => 'UE_CT_BS_INSTANTIATE.new_day_start(trunc(EcDp_Date_Time.getCurrentSysdate));',
                      next_date => trunc(sysdate +1)+5/24/60,
                      interval => 'trunc(sysdate +1)+5/24/60',
					  no_parse  => FALSE);

  commit;
    SYS.DBMS_OUTPUT.PUT_LINE('Job Number is: ' || to_char(x));
    execute immediate 'alter session set current_schema = ' || user_name;
  EXCEPTION
    WHEN OTHERS THEN
      execute immediate 'alter session set current_schema = ' || user_name;
      RAISE;
  END;
  COMMIT;
END;
/
