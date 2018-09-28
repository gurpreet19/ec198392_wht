CREATE OR REPLACE PACKAGE ec_class_dependency IS
------------------------------------------------------------------------------------
-- Package: ec_class_dependency
-- Generated by EC_GENERATE.

-- DO NOT MODIFY THIS PACKAGE! Changes will be lost when the package is regenerated.
-- Packages named pck_<component> will hold all manual written common code.
-- Packages named <sysnam>_<component> will hold all code not beeing common.
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
FUNCTION rec_id(
         p_parent_class VARCHAR2,
         p_child_class VARCHAR2,
         p_dependency_type VARCHAR2) RETURN CLASS_DEPENDENCY.REC_ID%TYPE ;
------------------------------------------------------------------------------------
FUNCTION record_status(
         p_parent_class VARCHAR2,
         p_child_class VARCHAR2,
         p_dependency_type VARCHAR2) RETURN CLASS_DEPENDENCY.RECORD_STATUS%TYPE ;
------------------------------------------------------------------------------------
FUNCTION approval_state(
         p_parent_class VARCHAR2,
         p_child_class VARCHAR2,
         p_dependency_type VARCHAR2) RETURN CLASS_DEPENDENCY.APPROVAL_STATE%TYPE ;
------------------------------------------------------------------------------------
FUNCTION approval_by(
         p_parent_class VARCHAR2,
         p_child_class VARCHAR2,
         p_dependency_type VARCHAR2) RETURN CLASS_DEPENDENCY.APPROVAL_BY%TYPE ;
------------------------------------------------------------------------------------
FUNCTION approval_date(
         p_parent_class VARCHAR2,
         p_child_class VARCHAR2,
         p_dependency_type VARCHAR2) RETURN CLASS_DEPENDENCY.APPROVAL_DATE%TYPE ;
------------------------------------------------------------------------------------
FUNCTION row_by_pk (
         p_parent_class VARCHAR2,
         p_child_class VARCHAR2,
         p_dependency_type VARCHAR2) RETURN CLASS_DEPENDENCY%ROWTYPE;

END ec_class_dependency;
/
CREATE OR REPLACE PACKAGE BODY ec_class_dependency IS
------------------------------------------------------------------------------------
-- Package body: ec_class_dependency
-- Generated by EC_GENERATE.
------------------------------------------------------------------------------------















------------------------------------------------------------------------------------
FUNCTION rec_id(
         p_parent_class VARCHAR2,
         p_child_class VARCHAR2,
         p_dependency_type VARCHAR2)
RETURN CLASS_DEPENDENCY.REC_ID%TYPE  IS
   v_return_val CLASS_DEPENDENCY.REC_ID%TYPE ;
   CURSOR c_col_val IS
   SELECT rec_id col
   FROM CLASS_DEPENDENCY
WHERE parent_class = p_parent_class
AND child_class = p_child_class
AND dependency_type = p_dependency_type;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END rec_id;

------------------------------------------------------------------------------------
FUNCTION record_status(
         p_parent_class VARCHAR2,
         p_child_class VARCHAR2,
         p_dependency_type VARCHAR2)
RETURN CLASS_DEPENDENCY.RECORD_STATUS%TYPE  IS
   v_return_val CLASS_DEPENDENCY.RECORD_STATUS%TYPE ;
   CURSOR c_col_val IS
   SELECT record_status col
   FROM CLASS_DEPENDENCY
WHERE parent_class = p_parent_class
AND child_class = p_child_class
AND dependency_type = p_dependency_type;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END record_status;

------------------------------------------------------------------------------------
FUNCTION approval_state(
         p_parent_class VARCHAR2,
         p_child_class VARCHAR2,
         p_dependency_type VARCHAR2)
RETURN CLASS_DEPENDENCY.APPROVAL_STATE%TYPE  IS
   v_return_val CLASS_DEPENDENCY.APPROVAL_STATE%TYPE ;
   CURSOR c_col_val IS
   SELECT approval_state col
   FROM CLASS_DEPENDENCY
WHERE parent_class = p_parent_class
AND child_class = p_child_class
AND dependency_type = p_dependency_type;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END approval_state;

------------------------------------------------------------------------------------
FUNCTION approval_by(
         p_parent_class VARCHAR2,
         p_child_class VARCHAR2,
         p_dependency_type VARCHAR2)
RETURN CLASS_DEPENDENCY.APPROVAL_BY%TYPE  IS
   v_return_val CLASS_DEPENDENCY.APPROVAL_BY%TYPE ;
   CURSOR c_col_val IS
   SELECT approval_by col
   FROM CLASS_DEPENDENCY
WHERE parent_class = p_parent_class
AND child_class = p_child_class
AND dependency_type = p_dependency_type;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END approval_by;

------------------------------------------------------------------------------------
FUNCTION approval_date(
         p_parent_class VARCHAR2,
         p_child_class VARCHAR2,
         p_dependency_type VARCHAR2)
RETURN CLASS_DEPENDENCY.APPROVAL_DATE%TYPE  IS
   v_return_val CLASS_DEPENDENCY.APPROVAL_DATE%TYPE ;
   CURSOR c_col_val IS
   SELECT approval_date col
   FROM CLASS_DEPENDENCY
WHERE parent_class = p_parent_class
AND child_class = p_child_class
AND dependency_type = p_dependency_type;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END approval_date;


------------------------------------------------------------------------------------
FUNCTION row_by_pk (
         p_parent_class VARCHAR2,
         p_child_class VARCHAR2,
         p_dependency_type VARCHAR2)
RETURN CLASS_DEPENDENCY%ROWTYPE IS
   v_return_rec CLASS_DEPENDENCY%ROWTYPE;
   CURSOR c_read_row IS
   SELECT *
   FROM CLASS_DEPENDENCY
WHERE parent_class = p_parent_class
AND child_class = p_child_class
AND dependency_type = p_dependency_type;
BEGIN
   FOR cur_rec IN c_read_row LOOP
      v_return_rec := cur_rec;
   END LOOP;
   RETURN v_return_rec;
END row_by_pk;



END ec_class_dependency;
/
