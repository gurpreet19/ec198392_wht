CREATE OR REPLACE PACKAGE BODY ec_class_property_codes IS
------------------------------------------------------------------------------------
-- Package body: ec_class_property_codes
-- Generated by EC_GENERATE.
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
TYPE row_cache IS TABLE OF CLASS_PROPERTY_CODES%ROWTYPE INDEX BY VARCHAR2(4000);
sg_row_cache row_cache;
------------------------------------------------------------------------------------
FUNCTION override_allowed_ind(
         p_property_table_name VARCHAR2,
         p_property_code VARCHAR2,
         p_property_type VARCHAR2)
RETURN CLASS_PROPERTY_CODES.OVERRIDE_ALLOWED_IND%TYPE IS
   v_return_val CLASS_PROPERTY_CODES.OVERRIDE_ALLOWED_IND%TYPE;
CURSOR c_col_val IS
   SELECT override_allowed_ind col
FROM CLASS_PROPERTY_CODES
   WHERE property_table_name = p_property_table_name
AND property_code = p_property_code
AND property_type = p_property_type;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END override_allowed_ind;
------------------------------------------------------------------------------------
FUNCTION protected_ind(
         p_property_table_name VARCHAR2,
         p_property_code VARCHAR2,
         p_property_type VARCHAR2)
RETURN CLASS_PROPERTY_CODES.PROTECTED_IND%TYPE IS
   v_return_val CLASS_PROPERTY_CODES.PROTECTED_IND%TYPE;
CURSOR c_col_val IS
   SELECT protected_ind col
FROM CLASS_PROPERTY_CODES
   WHERE property_table_name = p_property_table_name
AND property_code = p_property_code
AND property_type = p_property_type;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END protected_ind;
------------------------------------------------------------------------------------
FUNCTION data_type(
         p_property_table_name VARCHAR2,
         p_property_code VARCHAR2,
         p_property_type VARCHAR2)
RETURN CLASS_PROPERTY_CODES.DATA_TYPE%TYPE IS
   v_return_val CLASS_PROPERTY_CODES.DATA_TYPE%TYPE;
CURSOR c_col_val IS
   SELECT data_type col
FROM CLASS_PROPERTY_CODES
   WHERE property_table_name = p_property_table_name
AND property_code = p_property_code
AND property_type = p_property_type;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END data_type;
------------------------------------------------------------------------------------
FUNCTION presentation_cntx_regexp(
         p_property_table_name VARCHAR2,
         p_property_code VARCHAR2,
         p_property_type VARCHAR2)
RETURN CLASS_PROPERTY_CODES.PRESENTATION_CNTX_REGEXP%TYPE IS
   v_return_val CLASS_PROPERTY_CODES.PRESENTATION_CNTX_REGEXP%TYPE;
CURSOR c_col_val IS
   SELECT presentation_cntx_regexp col
FROM CLASS_PROPERTY_CODES
   WHERE property_table_name = p_property_table_name
AND property_code = p_property_code
AND property_type = p_property_type;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END presentation_cntx_regexp;
------------------------------------------------------------------------------------
FUNCTION sort_order(
         p_property_table_name VARCHAR2,
         p_property_code VARCHAR2,
         p_property_type VARCHAR2)
RETURN CLASS_PROPERTY_CODES.SORT_ORDER%TYPE IS
   v_return_val CLASS_PROPERTY_CODES.SORT_ORDER%TYPE;
CURSOR c_col_val IS
   SELECT sort_order col
FROM CLASS_PROPERTY_CODES
   WHERE property_table_name = p_property_table_name
AND property_code = p_property_code
AND property_type = p_property_type;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END sort_order;
------------------------------------------------------------------------------------
FUNCTION record_status(
         p_property_table_name VARCHAR2,
         p_property_code VARCHAR2,
         p_property_type VARCHAR2)
RETURN CLASS_PROPERTY_CODES.RECORD_STATUS%TYPE IS
   v_return_val CLASS_PROPERTY_CODES.RECORD_STATUS%TYPE;
CURSOR c_col_val IS
   SELECT record_status col
FROM CLASS_PROPERTY_CODES
   WHERE property_table_name = p_property_table_name
AND property_code = p_property_code
AND property_type = p_property_type;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END record_status;
------------------------------------------------------------------------------------
FUNCTION approval_state(
         p_property_table_name VARCHAR2,
         p_property_code VARCHAR2,
         p_property_type VARCHAR2)
RETURN CLASS_PROPERTY_CODES.APPROVAL_STATE%TYPE IS
   v_return_val CLASS_PROPERTY_CODES.APPROVAL_STATE%TYPE;
CURSOR c_col_val IS
   SELECT approval_state col
FROM CLASS_PROPERTY_CODES
   WHERE property_table_name = p_property_table_name
AND property_code = p_property_code
AND property_type = p_property_type;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END approval_state;
------------------------------------------------------------------------------------
FUNCTION approval_by(
         p_property_table_name VARCHAR2,
         p_property_code VARCHAR2,
         p_property_type VARCHAR2)
RETURN CLASS_PROPERTY_CODES.APPROVAL_BY%TYPE IS
   v_return_val CLASS_PROPERTY_CODES.APPROVAL_BY%TYPE;
CURSOR c_col_val IS
   SELECT approval_by col
FROM CLASS_PROPERTY_CODES
   WHERE property_table_name = p_property_table_name
AND property_code = p_property_code
AND property_type = p_property_type;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END approval_by;
------------------------------------------------------------------------------------
FUNCTION approval_date(
         p_property_table_name VARCHAR2,
         p_property_code VARCHAR2,
         p_property_type VARCHAR2)
RETURN CLASS_PROPERTY_CODES.APPROVAL_DATE%TYPE IS
   v_return_val CLASS_PROPERTY_CODES.APPROVAL_DATE%TYPE;
CURSOR c_col_val IS
   SELECT approval_date col
FROM CLASS_PROPERTY_CODES
   WHERE property_table_name = p_property_table_name
AND property_code = p_property_code
AND property_type = p_property_type;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END approval_date;
------------------------------------------------------------------------------------
FUNCTION rec_id(
         p_property_table_name VARCHAR2,
         p_property_code VARCHAR2,
         p_property_type VARCHAR2)
RETURN CLASS_PROPERTY_CODES.REC_ID%TYPE IS
   v_return_val CLASS_PROPERTY_CODES.REC_ID%TYPE;
CURSOR c_col_val IS
   SELECT rec_id col
FROM CLASS_PROPERTY_CODES
   WHERE property_table_name = p_property_table_name
AND property_code = p_property_code
AND property_type = p_property_type;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END rec_id;
------------------------------------------------------------------------------------
FUNCTION row_by_pk(
         p_property_table_name VARCHAR2,
         p_property_code VARCHAR2,
         p_property_type VARCHAR2)
RETURN CLASS_PROPERTY_CODES%ROWTYPE IS
   v_return_rec CLASS_PROPERTY_CODES%ROWTYPE;
   lv2_sc_key VARCHAR2(4000) := 'x'||p_property_table_name||p_property_code||p_property_type;
   CURSOR c_read_row IS
   SELECT *
   FROM CLASS_PROPERTY_CODES
   WHERE property_table_name = p_property_table_name
AND property_code = p_property_code
AND property_type = p_property_type;
BEGIN
   IF NOT sg_row_cache.EXISTS(lv2_sc_key) THEN
      sg_row_cache.DELETE;
   FOR cur_rec IN c_read_row LOOP
      v_return_rec := cur_rec;
   END LOOP;
      sg_row_cache(lv2_sc_key) := v_return_rec;
   END IF;
   RETURN sg_row_cache(lv2_sc_key);
END row_by_pk;

------------------------------------------------------------------------------------
PROCEDURE flush_row_cache IS
BEGIN
   sg_row_cache.DELETE;
END flush_row_cache;

END ec_class_property_codes;