define ctrl_pinc_entry = 'Post_Scripts' 
Prompt Loading Operation Parameters
@"C:\EnergyComponents\CVX_2019\EC198392_WAOIL\Database\08_EC12_1_Scripts\02_Post_Scripts\operation_parameters.sql";
Prompt Connected to the database &database_name with user eckernel_&operation
CONNECT eckernel_&operation/&ec_schema_password@&database_name
set verify off
set termout off
COLUMN a new_val thisuser noprint
COLUMN b new_val thisdb noprint
COLUMN c new_val todaysdate noprint
select USER a, nvl(substr(global_name, 0, instr(global_name, '.')-1), global_name) b, TO_CHAR(SYSdate, 'YYYYmmdd_HH24MI') c from global_name;
column fname new_value fname noprint
SELECT 'log_Post_Scripts_&thisuser._&thisdb._&todaysdate..log' fname FROM dual;
set termout on
set serveroutput on format wrapped
set sqlblanklines on
spool &fname
Prompt ==================================================================
Prompt Start loading database changes 
Prompt ==================================================================
Prompt Connected to the database &database_name with user eckernel_&operation
Prompt ==================================================================
@.\01_Utility_File\check_operation_parameters.sql
@.\01_Utility_File\start_ctrl_pinc.sql
PROMPT Next File: 001_ectp_well_1036.sql 
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK 
@.\02_Post_Fixes\001_ectp_well_1036.sql;
commit;
PROMPT Next File: 002_upgcvx_1036.sql 
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK 
@.\02_Post_Fixes\002_upgcvx_1036.sql;
commit;
PROMPT Next File: 003_upgcvx-1084_ecdp_synchronise.sql 
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK 
@.\02_Post_Fixes\003_upgcvx-1084_ecdp_synchronise.sql;
commit;
Prompt Compile Schema for Invalid Objects
execute dbms_utility.compile_schema(user,false);
@.\01_Utility_File\end_ctrl_pinc.sql
Prompt -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
Prompt Creating missing synonyms
Prompt -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@@.\01_Utility_File\Synonyms\Synonyms.sql
Prompt ==================================================================
Prompt End loading database changes 
Prompt ==================================================================
set define on
spool off
exit
