CREATE OR REPLACE PACKAGE ec_class_rel_db_mapping IS
------------------------------------------------------------------------------------
-- Package: ec_class_rel_db_mapping
-- Generated by EC_GENERATE.

-- DO NOT MODIFY THIS PACKAGE! Changes will be lost when the package is regenerated.
-- Packages named pck_<component> will hold all manual written common code.
-- Packages named <sysnam>_<component> will hold all code not beeing common.
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
FUNCTION db_mapping_type(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_REL_DB_MAPPING.DB_MAPPING_TYPE%TYPE ;
------------------------------------------------------------------------------------
FUNCTION db_sql_syntax(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_REL_DB_MAPPING.DB_SQL_SYNTAX%TYPE ;
------------------------------------------------------------------------------------
FUNCTION sort_order(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_REL_DB_MAPPING.SORT_ORDER%TYPE ;
------------------------------------------------------------------------------------
FUNCTION record_status(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_REL_DB_MAPPING.RECORD_STATUS%TYPE ;
------------------------------------------------------------------------------------
FUNCTION approval_state(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_REL_DB_MAPPING.APPROVAL_STATE%TYPE ;
------------------------------------------------------------------------------------
FUNCTION approval_by(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_REL_DB_MAPPING.APPROVAL_BY%TYPE ;
------------------------------------------------------------------------------------
FUNCTION approval_date(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_REL_DB_MAPPING.APPROVAL_DATE%TYPE ;
------------------------------------------------------------------------------------
FUNCTION rec_id(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_REL_DB_MAPPING.REC_ID%TYPE ;
------------------------------------------------------------------------------------
FUNCTION row_by_pk (
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_REL_DB_MAPPING%ROWTYPE;

END ec_class_rel_db_mapping;
/
CREATE OR REPLACE PACKAGE BODY ec_class_rel_db_mapping IS
------------------------------------------------------------------------------------
-- Package body: ec_class_rel_db_mapping
-- Generated by EC_GENERATE.
------------------------------------------------------------------------------------















------------------------------------------------------------------------------------
FUNCTION db_mapping_type(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2)
RETURN CLASS_REL_DB_MAPPING.DB_MAPPING_TYPE%TYPE  IS
   v_return_val CLASS_REL_DB_MAPPING.DB_MAPPING_TYPE%TYPE ;
   CURSOR c_col_val IS
   SELECT db_mapping_type col
   FROM CLASS_REL_DB_MAPPING
WHERE from_class_name = p_from_class_name
AND to_class_name = p_to_class_name
AND role_name = p_role_name;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END db_mapping_type;

------------------------------------------------------------------------------------
FUNCTION db_sql_syntax(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2)
RETURN CLASS_REL_DB_MAPPING.DB_SQL_SYNTAX%TYPE  IS
   v_return_val CLASS_REL_DB_MAPPING.DB_SQL_SYNTAX%TYPE ;
   CURSOR c_col_val IS
   SELECT db_sql_syntax col
   FROM CLASS_REL_DB_MAPPING
WHERE from_class_name = p_from_class_name
AND to_class_name = p_to_class_name
AND role_name = p_role_name;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END db_sql_syntax;

------------------------------------------------------------------------------------
FUNCTION sort_order(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2)
RETURN CLASS_REL_DB_MAPPING.SORT_ORDER%TYPE  IS
   v_return_val CLASS_REL_DB_MAPPING.SORT_ORDER%TYPE ;
   CURSOR c_col_val IS
   SELECT sort_order col
   FROM CLASS_REL_DB_MAPPING
WHERE from_class_name = p_from_class_name
AND to_class_name = p_to_class_name
AND role_name = p_role_name;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END sort_order;

------------------------------------------------------------------------------------
FUNCTION record_status(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2)
RETURN CLASS_REL_DB_MAPPING.RECORD_STATUS%TYPE  IS
   v_return_val CLASS_REL_DB_MAPPING.RECORD_STATUS%TYPE ;
   CURSOR c_col_val IS
   SELECT record_status col
   FROM CLASS_REL_DB_MAPPING
WHERE from_class_name = p_from_class_name
AND to_class_name = p_to_class_name
AND role_name = p_role_name;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END record_status;

------------------------------------------------------------------------------------
FUNCTION approval_state(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2)
RETURN CLASS_REL_DB_MAPPING.APPROVAL_STATE%TYPE  IS
   v_return_val CLASS_REL_DB_MAPPING.APPROVAL_STATE%TYPE ;
   CURSOR c_col_val IS
   SELECT approval_state col
   FROM CLASS_REL_DB_MAPPING
WHERE from_class_name = p_from_class_name
AND to_class_name = p_to_class_name
AND role_name = p_role_name;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END approval_state;

------------------------------------------------------------------------------------
FUNCTION approval_by(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2)
RETURN CLASS_REL_DB_MAPPING.APPROVAL_BY%TYPE  IS
   v_return_val CLASS_REL_DB_MAPPING.APPROVAL_BY%TYPE ;
   CURSOR c_col_val IS
   SELECT approval_by col
   FROM CLASS_REL_DB_MAPPING
WHERE from_class_name = p_from_class_name
AND to_class_name = p_to_class_name
AND role_name = p_role_name;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END approval_by;

------------------------------------------------------------------------------------
FUNCTION approval_date(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2)
RETURN CLASS_REL_DB_MAPPING.APPROVAL_DATE%TYPE  IS
   v_return_val CLASS_REL_DB_MAPPING.APPROVAL_DATE%TYPE ;
   CURSOR c_col_val IS
   SELECT approval_date col
   FROM CLASS_REL_DB_MAPPING
WHERE from_class_name = p_from_class_name
AND to_class_name = p_to_class_name
AND role_name = p_role_name;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END approval_date;

------------------------------------------------------------------------------------
FUNCTION rec_id(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2)
RETURN CLASS_REL_DB_MAPPING.REC_ID%TYPE  IS
   v_return_val CLASS_REL_DB_MAPPING.REC_ID%TYPE ;
   CURSOR c_col_val IS
   SELECT rec_id col
   FROM CLASS_REL_DB_MAPPING
WHERE from_class_name = p_from_class_name
AND to_class_name = p_to_class_name
AND role_name = p_role_name;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END rec_id;


------------------------------------------------------------------------------------
FUNCTION row_by_pk (
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2)
RETURN CLASS_REL_DB_MAPPING%ROWTYPE IS
   v_return_rec CLASS_REL_DB_MAPPING%ROWTYPE;
   CURSOR c_read_row IS
   SELECT *
   FROM CLASS_REL_DB_MAPPING
WHERE from_class_name = p_from_class_name
AND to_class_name = p_to_class_name
AND role_name = p_role_name;
BEGIN
   FOR cur_rec IN c_read_row LOOP
      v_return_rec := cur_rec;
   END LOOP;
   RETURN v_return_rec;
END row_by_pk;



END ec_class_rel_db_mapping;
/
