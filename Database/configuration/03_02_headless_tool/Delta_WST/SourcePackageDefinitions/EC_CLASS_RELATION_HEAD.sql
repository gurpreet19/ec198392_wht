CREATE OR REPLACE PACKAGE ec_class_relation IS
------------------------------------------------------------------------------------
-- Package: ec_class_relation
-- Generated by EC_GENERATE.

-- DO NOT MODIFY THIS PACKAGE! Changes will be lost when the package is regenerated.
-- Packages named pck_<component> will hold all manual written common code.
-- Packages named <sysnam>_<component> will hold all code not beeing common.
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
FUNCTION name(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_RELATION.NAME%TYPE ;
------------------------------------------------------------------------------------
FUNCTION is_key(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_RELATION.IS_KEY%TYPE ;
------------------------------------------------------------------------------------
FUNCTION is_mandatory(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_RELATION.IS_MANDATORY%TYPE ;
------------------------------------------------------------------------------------
FUNCTION is_bidirectional(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_RELATION.IS_BIDIRECTIONAL%TYPE ;
------------------------------------------------------------------------------------
FUNCTION context_code(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_RELATION.CONTEXT_CODE%TYPE ;
------------------------------------------------------------------------------------
FUNCTION group_type(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_RELATION.GROUP_TYPE%TYPE ;
------------------------------------------------------------------------------------
FUNCTION multiplicity(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_RELATION.MULTIPLICITY%TYPE ;
------------------------------------------------------------------------------------
FUNCTION disabled_ind(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_RELATION.DISABLED_IND%TYPE ;
------------------------------------------------------------------------------------
FUNCTION report_only_ind(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_RELATION.REPORT_ONLY_IND%TYPE ;
------------------------------------------------------------------------------------
FUNCTION access_control_method(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_RELATION.ACCESS_CONTROL_METHOD%TYPE ;
------------------------------------------------------------------------------------
FUNCTION alloc_priority(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_RELATION.ALLOC_PRIORITY%TYPE ;
------------------------------------------------------------------------------------
FUNCTION calc_mapping_syntax(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_RELATION.CALC_MAPPING_SYNTAX%TYPE ;
------------------------------------------------------------------------------------
FUNCTION description(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_RELATION.DESCRIPTION%TYPE ;
------------------------------------------------------------------------------------
FUNCTION record_status(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_RELATION.RECORD_STATUS%TYPE ;
------------------------------------------------------------------------------------
FUNCTION reverse_approval_ind(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_RELATION.REVERSE_APPROVAL_IND%TYPE ;
------------------------------------------------------------------------------------
FUNCTION approval_ind(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_RELATION.APPROVAL_IND%TYPE ;
------------------------------------------------------------------------------------
FUNCTION approval_state(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_RELATION.APPROVAL_STATE%TYPE ;
------------------------------------------------------------------------------------
FUNCTION approval_by(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_RELATION.APPROVAL_BY%TYPE ;
------------------------------------------------------------------------------------
FUNCTION approval_date(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_RELATION.APPROVAL_DATE%TYPE ;
------------------------------------------------------------------------------------
FUNCTION rec_id(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_RELATION.REC_ID%TYPE ;
------------------------------------------------------------------------------------
FUNCTION row_by_pk (
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_RELATION%ROWTYPE;

END ec_class_relation;