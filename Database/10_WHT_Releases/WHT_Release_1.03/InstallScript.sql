define ctrl_pinc_entry = 'WHT_Release_1.01' 
Prompt Loading Operation Parameters
@"C:\Users\kulkagay\Documents\Chevron 2019\WHT\Database\10_WHT_Releases\WHT_Release_1.01\operation_parameters.sql";
Prompt Connected to the database &database_name with user eckernel_&operation
CONNECT eckernel_&operation/&ec_schema_password@&database_name
set verify off
set termout off
COLUMN a new_val thisuser noprint
COLUMN b new_val thisdb noprint
COLUMN c new_val todaysdate noprint
select USER a, nvl(substr(global_name, 0, instr(global_name, '.')-1), global_name) b, TO_CHAR(SYSdate, 'YYYYmmdd_HH24MI') c from global_name;
column fname new_value fname noprint
SELECT 'log_WHT_Release_1.01_&thisuser._&thisdb._&todaysdate..log' fname FROM dual;
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
PROMPT Next File: 001_upgcvx-1417_kckernel.sql 
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK 
@.\02_Defect_fixes\001_upgcvx-1417_kckernel.sql;
commit;
PROMPT Next File: 002_zp_login_event.sql 
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK 
@.\02_Defect_fixes\002_zp_login_event.sql;
commit;
PROMPT Next File: 003_zv_login_event.sql 
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK 
@.\02_Defect_fixes\003_zv_login_event.sql;
commit;
PROMPT Next File: 004_zv_audit_login_report.sql 
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK 
@.\02_Defect_fixes\004_zv_audit_login_report.sql;
commit;
PROMPT Next File: 005_drop_materialized_view.sql 
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK 
@.\02_Defect_fixes\005_drop_materialized_view.sql;
commit;
PROMPT Next File: 006_v_trans_config.sql 
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK 
@.\02_Defect_fixes\006_v_trans_config.sql;
commit;
PROMPT Next File: 007_z_cdb_chem_inj_point.sql 
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK 
@.\02_Defect_fixes\007_z_cdb_chem_inj_point.sql;
commit;
PROMPT Next File: 008_invalid_object_fix.sql 
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK 
@.\02_Defect_fixes\008_invalid_object_fix.sql;
commit;
PROMPT Next File: 009_rv_ct_contract_capacity.sql 
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK 
@.\02_Defect_fixes\009_rv_ct_contract_capacity.sql;
commit;
PROMPT Next File: 010_upgcvx_1886.sql 
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK 
@.\02_Defect_fixes\010_upgcvx_1886.sql;
commit;
PROMPT Next File: 011_upgcvx_1888.sql 
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK 
@.\02_Defect_fixes\011_upgcvx_1888.sql;
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
