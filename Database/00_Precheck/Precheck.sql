Prompt Loading Operation Parameters
@"C:\Users\agarwnik\Documents\test\Upgrade_Scripts\Upgrade_Scripts\configuration\operation_parameters.sql";
Prompt Connected to the database &database_name with user ECKERNEL_&operation
CONNECT eckernel_&operation/&ec_schema_password@&database_name
set long 9999
set heading off
set verify off
set feedback off
set echo off
set pagesize 9999
set linesize 220
set trimspool on
@.\01_Utility_File\check_operation_parameters.sql;
spool Prechecklog.csv
Prompt Connected to the database &database_name with user eckernel_&operation
@.\01_Utility_File\Precheckscript.sql;
set define on
spool off
set heading on
set verify on
set feedback on
exit;
