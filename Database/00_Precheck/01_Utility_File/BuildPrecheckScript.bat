@echo off

set FILENAME=Prechecklog
set NLM=^
set NL=^^^%NLM%%NLM%^%NLM%%NLM%

rem Load operations parameters and connect to the DB
echo Prompt Loading Operation Parameters
cd..
echo @"%cd%\configuration\operation_parameters.sql";
cd "00_Precheck"
echo Prompt Connected to the database ^&database_name with user ECKERNEL_^&operation
echo CONNECT eckernel_^&operation/^&ec_schema_password@^&database_name

echo set long 9999
echo set heading off
echo set verify off
echo set feedback off
echo set echo off
echo set pagesize 9999
echo set linesize 220
echo set trimspool on

echo @.\01_Utility_File\check_operation_parameters.sql;

echo spool %FILENAME%.csv

echo Prompt Connected to the database ^&database_name with user eckernel_^&operation

echo @.\01_Utility_File\Precheckscript.sql;

echo set define on
echo spool off
echo set heading on
echo set verify on
echo set feedback on

echo exit;