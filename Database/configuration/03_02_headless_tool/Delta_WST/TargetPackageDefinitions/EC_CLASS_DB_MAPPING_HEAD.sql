CREATE OR REPLACE PACKAGE ec_class_db_mapping IS
------------------------------------------------------------------------------------
-- Package: ec_class_db_mapping
-- Generated by EC_GENERATE.

-- DO NOT MODIFY THIS PACKAGE! Changes will be lost when the package is regenerated.
-- Packages named pck_<component> will hold all manual written common code.
-- Packages named <sysnam>_<component> will hold all code not beeing common.
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
FUNCTION db_object_type(
         p_class_name VARCHAR2) RETURN CLASS_DB_MAPPING.DB_OBJECT_TYPE%TYPE ;
------------------------------------------------------------------------------------
FUNCTION db_object_owner(
         p_class_name VARCHAR2) RETURN CLASS_DB_MAPPING.DB_OBJECT_OWNER%TYPE ;
------------------------------------------------------------------------------------
FUNCTION db_object_name(
         p_class_name VARCHAR2) RETURN CLASS_DB_MAPPING.DB_OBJECT_NAME%TYPE ;
------------------------------------------------------------------------------------
FUNCTION db_object_attribute(
         p_class_name VARCHAR2) RETURN CLASS_DB_MAPPING.DB_OBJECT_ATTRIBUTE%TYPE ;
------------------------------------------------------------------------------------
FUNCTION db_where_condition(
         p_class_name VARCHAR2) RETURN CLASS_DB_MAPPING.DB_WHERE_CONDITION%TYPE ;
------------------------------------------------------------------------------------
FUNCTION record_status(
         p_class_name VARCHAR2) RETURN CLASS_DB_MAPPING.RECORD_STATUS%TYPE ;
------------------------------------------------------------------------------------
FUNCTION approval_state(
         p_class_name VARCHAR2) RETURN CLASS_DB_MAPPING.APPROVAL_STATE%TYPE ;
------------------------------------------------------------------------------------
FUNCTION approval_by(
         p_class_name VARCHAR2) RETURN CLASS_DB_MAPPING.APPROVAL_BY%TYPE ;
------------------------------------------------------------------------------------
FUNCTION approval_date(
         p_class_name VARCHAR2) RETURN CLASS_DB_MAPPING.APPROVAL_DATE%TYPE ;
------------------------------------------------------------------------------------
FUNCTION rec_id(
         p_class_name VARCHAR2) RETURN CLASS_DB_MAPPING.REC_ID%TYPE ;
------------------------------------------------------------------------------------
FUNCTION row_by_pk (
         p_class_name VARCHAR2) RETURN CLASS_DB_MAPPING%ROWTYPE;

END ec_class_db_mapping;