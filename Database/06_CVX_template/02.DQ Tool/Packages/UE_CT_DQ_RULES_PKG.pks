CREATE OR REPLACE PACKAGE UE_CT_DQ_RULES_PKG AS

--- functions to buiild dynamic sql

FUNCTION convert_rule_to_sql(
        p_rule_id integer, p_start_date date, p_end_date date) return varchar2;


FUNCTION convert_to_single_sql(
        p_sql_stmt varchar2, p_object_id varchar2, p_daytime date, p_alt_unique_key varchar2) return varchar2;


FUNCTION convert_to_date_range_sql(
        p_sql_stmt varchar2, p_start_date date, p_end_date date) return varchar2;


FUNCTION build_object_sql(
        p_object_type varchar2) return varchar2;


FUNCTION combine_with_object_sql(
        p_sql_stmt varchar2, p_object_sql_stmt varchar2, p_nav_class_name varchar2, p_nav_object_id varchar2, p_group_type varchar2) return varchar2;

---- procedures for running checks against all data

PROCEDURE batch_load_dq_results(p_rule_group_code varchar2, p_rule_id integer, p_user varchar2, p_start_date date, p_end_date date);

PROCEDURE batch_load_dq_results_hier(p_nav_class_name varchar2, p_nav_object_id varchar2, p_group_type varchar2, p_user varchar2);

PROCEDURE batch_load_dq_results_single(p_rule_id integer, p_object_id varchar2, p_daytime date, p_alt_unique_key varchar2, p_user varchar2);

---- procedures for rerunning errors only

PROCEDURE batch_reload_single_result(p_result_id integer, p_user varchar2);

PROCEDURE batch_reload_result_group(p_rule_id integer, p_nav_class_name varchar2, p_nav_object_id varchar2, p_start_date date, p_end_date date, p_user varchar2, p_group_type varchar2);

----  common processing logic procedures

PROCEDURE execute_sql_stmt(p_run_id integer, p_run_date date, p_sql_stmt varchar2, p_rule_id integer, p_rule_group_id integer, p_user varchar2);

PROCEDURE process_sql_stmt(p_run_id integer, p_run_date date, p_rule_id integer, p_rule_group_id integer, p_user varchar2, p_OBJECT_ID varchar2, p_DAYTIME date, p_ALT_UNIQUE_KEY varchar2, p_SQL_FLD_1 varchar2, p_SQL_FLD_2 varchar2, p_SQL_FLD_3 varchar2, p_SQL_FLD_4 varchar2, p_SQL_FLD_5 varchar2, p_ADDNL_INFO varchar2, 
p_OP_PU_ID varchar2, p_OP_SUB_PU_ID varchar2, p_OP_AREA_ID varchar2, p_OP_SUB_AREA_ID varchar2, p_OP_FCTY_CLASS_2_ID varchar2, p_OP_FCTY_CLASS_1_ID varchar2,p_OP_WELL_HOOKUP_ID varchar2, p_CP_PU_ID varchar2, p_CP_SUB_PU_ID varchar2, p_CP_AREA_ID varchar2, p_CP_SUB_AREA_ID varchar2, p_CP_OPERATOR_ROUTE_ID varchar2, p_CP_COL_POINT_ID varchar2,p_GEO_AREA_ID varchar2, p_GEO_SUB_AREA_ID varchar2, p_GEO_FIELD_ID varchar2, p_GEO_SUB_FIELD_ID varchar2, p_GROUP_REF_ID_1 varchar2, p_GROUP_REF_ID_2 varchar2, p_GROUP_REF_ID_3 varchar2, p_GROUP_REF_ID_4 varchar2, p_GROUP_REF_ID_5 varchar2, p_GROUP_REF_ID_6 varchar2, p_GROUP_REF_ID_7 varchar2, p_GROUP_REF_ID_8 varchar2, p_GROUP_REF_ID_9 varchar2, p_GROUP_REF_ID_10 varchar2);

PROCEDURE PostRuleResultLog(p_run_id integer, p_rule_id integer, p_rule_started_date date, p_delete_sql_from_stmt varchar2, p_result_retention_days integer, p_user varchar2);

----- misc functions

FUNCTION get_max_rule_run_created_date(
        p_run_id integer, p_rule_group_id integer, p_rule_id integer, p_run_date date) return date;

FUNCTION get_rule_group_rule_count(
        p_rule_group_id integer) return number;

FUNCTION get_date_from_date_source(
        p_date_source varchar2) return date;

FUNCTION get_sql_attribute_name(
        p_db_sql_syntax varchar2) return varchar2;

PROCEDURE validate_dynamic_sql(p_rule_id integer);

PROCEDURE validate_date_source(p_date_source varchar2);

PROCEDURE CreateRunLog(p_run_id integer, p_run_type varchar2, p_rule_group_id integer, p_rule_id integer, p_hier_group_type varchar2, p_hier_object_id varchar2, p_rec_object_id varchar2, p_rec_daytime date, p_rec_alt_unique_key varchar2, p_run_date date, p_user varchar2);

PROCEDURE UpdateRunLogParmDates(p_run_id integer, p_parm_start_date date, p_parm_end_date date);

PROCEDURE UpdateRunLog(p_run_id integer, p_error_message varchar2, p_status varchar2, p_user varchar2);

END UE_CT_DQ_RULES_PKG;
/