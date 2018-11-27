CREATE OR REPLACE PACKAGE ec_class_property_codes IS
------------------------------------------------------------------------------------
-- Package: ec_class_property_codes
-- Generated by EC_GENERATE.

-- DO NOT MODIFY THIS PACKAGE! Changes will be lost when the package is regenerated.
-- Packages named pck_<component> will hold all manual written common code.
-- Packages named <sysnam>_<component> will hold all code not beeing common.
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
FUNCTION override_allowed_ind(
         p_property_table_name VARCHAR2,
         p_property_code VARCHAR2,
         p_property_type VARCHAR2) RETURN CLASS_PROPERTY_CODES.OVERRIDE_ALLOWED_IND%TYPE;
------------------------------------------------------------------------------------
FUNCTION protected_ind(
         p_property_table_name VARCHAR2,
         p_property_code VARCHAR2,
         p_property_type VARCHAR2) RETURN CLASS_PROPERTY_CODES.PROTECTED_IND%TYPE;
------------------------------------------------------------------------------------
FUNCTION data_type(
         p_property_table_name VARCHAR2,
         p_property_code VARCHAR2,
         p_property_type VARCHAR2) RETURN CLASS_PROPERTY_CODES.DATA_TYPE%TYPE;
------------------------------------------------------------------------------------
FUNCTION presentation_cntx_regexp(
         p_property_table_name VARCHAR2,
         p_property_code VARCHAR2,
         p_property_type VARCHAR2) RETURN CLASS_PROPERTY_CODES.PRESENTATION_CNTX_REGEXP%TYPE;
------------------------------------------------------------------------------------
FUNCTION sort_order(
         p_property_table_name VARCHAR2,
         p_property_code VARCHAR2,
         p_property_type VARCHAR2) RETURN CLASS_PROPERTY_CODES.SORT_ORDER%TYPE;
------------------------------------------------------------------------------------
FUNCTION record_status(
         p_property_table_name VARCHAR2,
         p_property_code VARCHAR2,
         p_property_type VARCHAR2) RETURN CLASS_PROPERTY_CODES.RECORD_STATUS%TYPE;
------------------------------------------------------------------------------------
FUNCTION approval_state(
         p_property_table_name VARCHAR2,
         p_property_code VARCHAR2,
         p_property_type VARCHAR2) RETURN CLASS_PROPERTY_CODES.APPROVAL_STATE%TYPE;
------------------------------------------------------------------------------------
FUNCTION approval_by(
         p_property_table_name VARCHAR2,
         p_property_code VARCHAR2,
         p_property_type VARCHAR2) RETURN CLASS_PROPERTY_CODES.APPROVAL_BY%TYPE;
------------------------------------------------------------------------------------
FUNCTION approval_date(
         p_property_table_name VARCHAR2,
         p_property_code VARCHAR2,
         p_property_type VARCHAR2) RETURN CLASS_PROPERTY_CODES.APPROVAL_DATE%TYPE;
------------------------------------------------------------------------------------
FUNCTION rec_id(
         p_property_table_name VARCHAR2,
         p_property_code VARCHAR2,
         p_property_type VARCHAR2) RETURN CLASS_PROPERTY_CODES.REC_ID%TYPE;
------------------------------------------------------------------------------------
FUNCTION row_by_pk(
         p_property_table_name VARCHAR2,
         p_property_code VARCHAR2,
         p_property_type VARCHAR2) RETURN CLASS_PROPERTY_CODES%ROWTYPE;
------------------------------------------------------------------------------------
PROCEDURE flush_row_cache;


END ec_class_property_codes;