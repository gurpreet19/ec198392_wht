CREATE OR REPLACE PACKAGE ec_class IS
------------------------------------------------------------------------------------
-- Package: ec_class
-- Generated by EC_GENERATE.

-- DO NOT MODIFY THIS PACKAGE! Changes will be lost when the package is regenerated.
-- Packages named pck_<component> will hold all manual written common code.
-- Packages named <sysnam>_<component> will hold all code not beeing common.
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
FUNCTION super_class(
         p_class_name VARCHAR2) RETURN CLASS.SUPER_CLASS%TYPE ;
------------------------------------------------------------------------------------
FUNCTION class_type(
         p_class_name VARCHAR2) RETURN CLASS.CLASS_TYPE%TYPE ;
------------------------------------------------------------------------------------
FUNCTION app_space_code(
         p_class_name VARCHAR2) RETURN CLASS.APP_SPACE_CODE%TYPE ;
------------------------------------------------------------------------------------
FUNCTION time_scope_code(
         p_class_name VARCHAR2) RETURN CLASS.TIME_SCOPE_CODE%TYPE ;
------------------------------------------------------------------------------------
FUNCTION owner_class_name(
         p_class_name VARCHAR2) RETURN CLASS.OWNER_CLASS_NAME%TYPE ;
------------------------------------------------------------------------------------
FUNCTION class_short_code(
         p_class_name VARCHAR2) RETURN CLASS.CLASS_SHORT_CODE%TYPE ;
------------------------------------------------------------------------------------
FUNCTION class_version(
         p_class_name VARCHAR2) RETURN CLASS.CLASS_VERSION%TYPE ;
------------------------------------------------------------------------------------
FUNCTION label(
         p_class_name VARCHAR2) RETURN CLASS.LABEL%TYPE ;
------------------------------------------------------------------------------------
FUNCTION ensure_rev_text_on_upd(
         p_class_name VARCHAR2) RETURN CLASS.ENSURE_REV_TEXT_ON_UPD%TYPE ;
------------------------------------------------------------------------------------
FUNCTION read_only_ind(
         p_class_name VARCHAR2) RETURN CLASS.READ_ONLY_IND%TYPE ;
------------------------------------------------------------------------------------
FUNCTION include_in_validation(
         p_class_name VARCHAR2) RETURN CLASS.INCLUDE_IN_VALIDATION%TYPE ;
------------------------------------------------------------------------------------
FUNCTION journal_rule_db_syntax(
         p_class_name VARCHAR2) RETURN CLASS.JOURNAL_RULE_DB_SYNTAX%TYPE ;
------------------------------------------------------------------------------------
FUNCTION calc_mapping_syntax(
         p_class_name VARCHAR2) RETURN CLASS.CALC_MAPPING_SYNTAX%TYPE ;
------------------------------------------------------------------------------------
FUNCTION lock_rule(
         p_class_name VARCHAR2) RETURN CLASS.LOCK_RULE%TYPE ;
------------------------------------------------------------------------------------
FUNCTION lock_ind(
         p_class_name VARCHAR2) RETURN CLASS.LOCK_IND%TYPE ;
------------------------------------------------------------------------------------
FUNCTION access_control_ind(
         p_class_name VARCHAR2) RETURN CLASS.ACCESS_CONTROL_IND%TYPE ;
------------------------------------------------------------------------------------
FUNCTION approval_ind(
         p_class_name VARCHAR2) RETURN CLASS.APPROVAL_IND%TYPE ;
------------------------------------------------------------------------------------
FUNCTION skip_trg_check_ind(
         p_class_name VARCHAR2) RETURN CLASS.SKIP_TRG_CHECK_IND%TYPE ;
------------------------------------------------------------------------------------
FUNCTION include_webservice(
         p_class_name VARCHAR2) RETURN CLASS.INCLUDE_WEBSERVICE%TYPE ;
------------------------------------------------------------------------------------
FUNCTION create_ev_ind(
         p_class_name VARCHAR2) RETURN CLASS.CREATE_EV_IND%TYPE ;
------------------------------------------------------------------------------------
FUNCTION description(
         p_class_name VARCHAR2) RETURN CLASS.DESCRIPTION%TYPE ;
------------------------------------------------------------------------------------
FUNCTION record_status(
         p_class_name VARCHAR2) RETURN CLASS.RECORD_STATUS%TYPE ;
------------------------------------------------------------------------------------
FUNCTION approval_state(
         p_class_name VARCHAR2) RETURN CLASS.APPROVAL_STATE%TYPE ;
------------------------------------------------------------------------------------
FUNCTION approval_by(
         p_class_name VARCHAR2) RETURN CLASS.APPROVAL_BY%TYPE ;
------------------------------------------------------------------------------------
FUNCTION approval_date(
         p_class_name VARCHAR2) RETURN CLASS.APPROVAL_DATE%TYPE ;
------------------------------------------------------------------------------------
FUNCTION rec_id(
         p_class_name VARCHAR2) RETURN CLASS.REC_ID%TYPE ;
------------------------------------------------------------------------------------
FUNCTION row_by_pk (
         p_class_name VARCHAR2) RETURN CLASS%ROWTYPE;

END ec_class;