@echo off

set FILENAME=WHT_Release_1.06
set NLM=^
set NL=^^^%NLM%%NLM%^%NLM%%NLM%

rem Set release description from folder name of parent directory name
rem for %%* in (.) do echo define release_desc = '%%~n*'

rem set ctrl_pinc_entry: release description - script name.sql
for %%* in (.) do echo define ctrl_pinc_entry = '%FILENAME%' 


rem Load operations parameters and connect to the DB
echo Prompt Loading Operation Parameters

echo @"%cd%\operation_parameters.sql";

echo Prompt Connected to the database ^&database_name with user eckernel_^&operation
echo CONNECT eckernel_^&operation/^&ec_schema_password@^&database_name


rem Build log file name (need to be after the connect statement)
echo set verify off
echo set termout off
echo COLUMN a new_val thisuser noprint
echo COLUMN b new_val thisdb noprint
echo COLUMN c new_val todaysdate noprint
echo select USER a, nvl(substr(global_name, 0, instr(global_name, '.')-1), global_name) b, TO_CHAR(SYSdate, 'YYYYmmdd_HH24MI') c from global_name;
echo column fname new_value fname noprint
echo SELECT 'log_%FILENAME%_^&thisuser._^&thisdb._^&todaysdate..log' fname FROM dual;
echo set termout on
echo set serveroutput on format wrapped
echo set sqlblanklines on
echo spool ^&fname

echo Prompt ==================================================================
echo Prompt Start loading database changes 
echo Prompt ==================================================================
echo Prompt Connected to the database ^&database_name with user eckernel_^&operation
echo Prompt ==================================================================

echo @.\01_Utility_File\check_operation_parameters.sql
echo @.\01_Utility_File\start_ctrl_pinc.sql

for /F %%i in ('dir /b /a-d /on /l .\02_Defect_fixes\*.sql') do ( 
echo PROMPT Next File: %%i 
echo WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK 
echo @.\02_Defect_fixes\%%i;
echo commit;
)

echo Prompt Compile Schema for Invalid Objects
echo execute dbms_utility.compile_schema(user,false);

echo @.\01_Utility_File\end_ctrl_pinc.sql
echo Prompt -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
echo Prompt Creating missing synonyms
echo Prompt -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
echo @@.\01_Utility_File\Synonyms\Synonyms.sql
echo Prompt ==================================================================
echo Prompt End loading database changes 
echo Prompt ==================================================================
echo set define on
echo spool off
echo exit