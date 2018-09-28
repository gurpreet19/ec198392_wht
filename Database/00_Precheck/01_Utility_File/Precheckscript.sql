Prompt ------------------------------------------------------------

Prompt Step-1 Verify EC Version
Prompt ------------------------------------------------------------

select 'DESCRIPTION' from dual;
select DESCRIPTION from ctrl_db_version;

Prompt 
Prompt ************************************************************
Prompt

Prompt ------------------------------------------------------------

Prompt Step-2 Check invalid object
Prompt ------------------------------------------------------------

select 'OBJECT_NAME' from dual;
select OBJECT_NAME from user_objects where status <> 'VALID';

Prompt 
Prompt ************************************************************
Prompt

Prompt ------------------------------------------------------------

Prompt Step-3 Check users
Prompt ------------------------------------------------------------

select 'USERNAME' from dual;
SELECT USERNAME FROM ALL_USERS WHERE USERNAME LIKE '%'||'&operation'||'%';

Prompt 
Prompt ************************************************************
Prompt

Prompt ------------------------------------------------------------

Prompt Step-4 Check access on V$INSTANCE view
Prompt ------------------------------------------------------------

select rpad('GRANTEE',20,' ')||' '||rpad('OWNER',10,' ')||' '||rpad('TABLE_NAME',15,' ')||' '||rpad('GRANTOR',10,' ')||' '||rpad('PRIVILEGE',10,' ') from dual;
select rpad(GRANTEE,20,' ')||' '||rpad(OWNER,10,' ')||' '||rpad(TABLE_NAME,15,' ')||' '||rpad(GRANTOR,10,' ')||' '||rpad(PRIVILEGE,10,' ') from user_tab_privs where table_name like 'V_$INSTANCE';

Prompt 
Prompt ************************************************************
Prompt

Prompt ------------------------------------------------------------

Prompt Step-5 Check for privileges for creating and dropping materialized views.
Prompt ------------------------------------------------------------

select rpad('USERNAME',20,' ')||' '||rpad('PRIVILEGE',30,' ') from dual;
select rpad(USERNAME,20,' ')||' '||rpad(PRIVILEGE,30,' ') from user_sys_privs where privilege like ('%MATERIALIZED%') ;

Prompt 
Prompt ************************************************************
Prompt

Prompt ------------------------------------------------------------

Prompt Step-6 Check privileges for schema
Prompt ------------------------------------------------------------

select rpad('GRANTEE',22,' ')||' '||rpad('OWNER',17,' ')||' '||rpad('TABLE_NAME',15,' ')||' '||rpad('GRANTOR',18,' ')||' '||rpad('PRIVILEGE',10,' ') from dual;
select rpad(GRANTEE,22,' ')||' '||rpad(OWNER,17,' ')||' '||rpad(TABLE_NAME,15,' ')||' '||rpad(GRANTOR,18,' ')||' '||rpad(PRIVILEGE,10,' ') from USER_TAB_PRIVS where table_name in ('DBMS_RLS','DBMS_SESSION','ECDP_CONTEXT','DBMS_LOCK');

Prompt 
Prompt ************************************************************
Prompt

Prompt ------------------------------------------------------------

Prompt Step-7 Check sys privileges for ECKERNEL.
Prompt ------------------------------------------------------------

select rpad('USERNAME',20,' ')||' '||rpad('PRIVILEGE',25,' ') from dual;
select rpad(USERNAME,20,' ')||' '||rpad(PRIVILEGE,25,' ') from user_sys_privs where privilege in ('CREATE SESSION','CREATE TYPE','CREATE SYNONYM','CREATE TRIGGER') order by username;

Prompt 
Prompt ************************************************************

connect energyx_&operation/&ec_energyx_password@&database_name

Prompt ------------------------------------------------------------

Prompt Step-8 Check sys privileges for ENERGYX.
Prompt ------------------------------------------------------------

select rpad('USERNAME',20,' ')||' '||rpad('PRIVILEGE',25,' ') from dual;
select rpad(USERNAME,20,' ')||' '||rpad(PRIVILEGE,25,' ') from user_sys_privs where privilege in ('CREATE SESSION','CREATE TYPE','CREATE SYNONYM','CREATE TRIGGER') order by username;

Prompt 
Prompt ************************************************************

connect transfer_&operation/&ec_transfer_password@&database_name

Prompt ------------------------------------------------------------

Prompt Step-9 Check sys privileges for TRANSFER.
Prompt ------------------------------------------------------------

select rpad('USERNAME',20,' ')||' '||rpad('PRIVILEGE',25,' ') from dual;
select rpad(USERNAME,20,' ')||' '||rpad(PRIVILEGE,25,' ') from user_sys_privs where privilege in ('CREATE SESSION','CREATE TYPE','CREATE SYNONYM','CREATE TRIGGER') order by username;

Prompt 
Prompt ************************************************************


connect reporting_&operation/&ec_reporting_password@&database_name

Prompt ------------------------------------------------------------

Prompt Step-10 Check sys privileges for REPORTING.
Prompt ------------------------------------------------------------

select rpad('USERNAME',20,' ')||' '||rpad('PRIVILEGE',25,' ') from dual;
select rpad(USERNAME,20,' ')||' '||rpad(PRIVILEGE,25,' ') from user_sys_privs where privilege in ('CREATE SESSION','CREATE TYPE','CREATE SYNONYM','CREATE TRIGGER') order by username;

Prompt 
Prompt ************************************************************