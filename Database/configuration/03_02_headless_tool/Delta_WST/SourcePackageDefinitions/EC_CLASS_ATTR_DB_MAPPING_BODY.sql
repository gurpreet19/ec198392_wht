CREATE OR REPLACE PACKAGE BODY ec_class_attr_db_mapping IS
------------------------------------------------------------------------------------
-- Package body: ec_class_attr_db_mapping
-- Generated by EC_GENERATE.
------------------------------------------------------------------------------------















------------------------------------------------------------------------------------
FUNCTION db_mapping_type(
         p_class_name VARCHAR2,
         p_attribute_name VARCHAR2)
RETURN CLASS_ATTR_DB_MAPPING.DB_MAPPING_TYPE%TYPE  IS
   v_return_val CLASS_ATTR_DB_MAPPING.DB_MAPPING_TYPE%TYPE ;
   CURSOR c_col_val IS
   SELECT db_mapping_type col
   FROM CLASS_ATTR_DB_MAPPING
WHERE class_name = p_class_name
AND attribute_name = p_attribute_name;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END db_mapping_type;

------------------------------------------------------------------------------------
FUNCTION db_sql_syntax(
         p_class_name VARCHAR2,
         p_attribute_name VARCHAR2)
RETURN CLASS_ATTR_DB_MAPPING.DB_SQL_SYNTAX%TYPE  IS
   v_return_val CLASS_ATTR_DB_MAPPING.DB_SQL_SYNTAX%TYPE ;
   CURSOR c_col_val IS
   SELECT db_sql_syntax col
   FROM CLASS_ATTR_DB_MAPPING
WHERE class_name = p_class_name
AND attribute_name = p_attribute_name;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END db_sql_syntax;

------------------------------------------------------------------------------------
FUNCTION sort_order(
         p_class_name VARCHAR2,
         p_attribute_name VARCHAR2)
RETURN CLASS_ATTR_DB_MAPPING.SORT_ORDER%TYPE  IS
   v_return_val CLASS_ATTR_DB_MAPPING.SORT_ORDER%TYPE ;
   CURSOR c_col_val IS
   SELECT sort_order col
   FROM CLASS_ATTR_DB_MAPPING
WHERE class_name = p_class_name
AND attribute_name = p_attribute_name;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END sort_order;

------------------------------------------------------------------------------------
FUNCTION record_status(
         p_class_name VARCHAR2,
         p_attribute_name VARCHAR2)
RETURN CLASS_ATTR_DB_MAPPING.RECORD_STATUS%TYPE  IS
   v_return_val CLASS_ATTR_DB_MAPPING.RECORD_STATUS%TYPE ;
   CURSOR c_col_val IS
   SELECT record_status col
   FROM CLASS_ATTR_DB_MAPPING
WHERE class_name = p_class_name
AND attribute_name = p_attribute_name;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END record_status;

------------------------------------------------------------------------------------
FUNCTION approval_state(
         p_class_name VARCHAR2,
         p_attribute_name VARCHAR2)
RETURN CLASS_ATTR_DB_MAPPING.APPROVAL_STATE%TYPE  IS
   v_return_val CLASS_ATTR_DB_MAPPING.APPROVAL_STATE%TYPE ;
   CURSOR c_col_val IS
   SELECT approval_state col
   FROM CLASS_ATTR_DB_MAPPING
WHERE class_name = p_class_name
AND attribute_name = p_attribute_name;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END approval_state;

------------------------------------------------------------------------------------
FUNCTION approval_by(
         p_class_name VARCHAR2,
         p_attribute_name VARCHAR2)
RETURN CLASS_ATTR_DB_MAPPING.APPROVAL_BY%TYPE  IS
   v_return_val CLASS_ATTR_DB_MAPPING.APPROVAL_BY%TYPE ;
   CURSOR c_col_val IS
   SELECT approval_by col
   FROM CLASS_ATTR_DB_MAPPING
WHERE class_name = p_class_name
AND attribute_name = p_attribute_name;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END approval_by;

------------------------------------------------------------------------------------
FUNCTION approval_date(
         p_class_name VARCHAR2,
         p_attribute_name VARCHAR2)
RETURN CLASS_ATTR_DB_MAPPING.APPROVAL_DATE%TYPE  IS
   v_return_val CLASS_ATTR_DB_MAPPING.APPROVAL_DATE%TYPE ;
   CURSOR c_col_val IS
   SELECT approval_date col
   FROM CLASS_ATTR_DB_MAPPING
WHERE class_name = p_class_name
AND attribute_name = p_attribute_name;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END approval_date;

------------------------------------------------------------------------------------
FUNCTION rec_id(
         p_class_name VARCHAR2,
         p_attribute_name VARCHAR2)
RETURN CLASS_ATTR_DB_MAPPING.REC_ID%TYPE  IS
   v_return_val CLASS_ATTR_DB_MAPPING.REC_ID%TYPE ;
   CURSOR c_col_val IS
   SELECT rec_id col
   FROM CLASS_ATTR_DB_MAPPING
WHERE class_name = p_class_name
AND attribute_name = p_attribute_name;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END rec_id;


------------------------------------------------------------------------------------
FUNCTION row_by_pk (
         p_class_name VARCHAR2,
         p_attribute_name VARCHAR2)
RETURN CLASS_ATTR_DB_MAPPING%ROWTYPE IS
   v_return_rec CLASS_ATTR_DB_MAPPING%ROWTYPE;
   CURSOR c_read_row IS
   SELECT *
   FROM CLASS_ATTR_DB_MAPPING
WHERE class_name = p_class_name
AND attribute_name = p_attribute_name;
BEGIN
   FOR cur_rec IN c_read_row LOOP
      v_return_rec := cur_rec;
   END LOOP;
   RETURN v_return_rec;
END row_by_pk;



END ec_class_attr_db_mapping;