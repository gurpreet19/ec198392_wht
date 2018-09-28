CREATE OR REPLACE PACKAGE ec_class_rel_presentation IS
------------------------------------------------------------------------------------
-- Package: ec_class_rel_presentation
-- Generated by EC_GENERATE.

-- DO NOT MODIFY THIS PACKAGE! Changes will be lost when the package is regenerated.
-- Packages named pck_<component> will hold all manual written common code.
-- Packages named <sysnam>_<component> will hold all code not beeing common.
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
FUNCTION static_presentation_syntax(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_REL_PRESENTATION.STATIC_PRESENTATION_SYNTAX%TYPE ;
------------------------------------------------------------------------------------
FUNCTION presentation_syntax(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_REL_PRESENTATION.PRESENTATION_SYNTAX%TYPE ;
------------------------------------------------------------------------------------
FUNCTION db_pres_syntax(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_REL_PRESENTATION.DB_PRES_SYNTAX%TYPE ;
------------------------------------------------------------------------------------
FUNCTION label(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_REL_PRESENTATION.LABEL%TYPE ;
------------------------------------------------------------------------------------
FUNCTION record_status(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_REL_PRESENTATION.RECORD_STATUS%TYPE ;
------------------------------------------------------------------------------------
FUNCTION approval_state(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_REL_PRESENTATION.APPROVAL_STATE%TYPE ;
------------------------------------------------------------------------------------
FUNCTION approval_by(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_REL_PRESENTATION.APPROVAL_BY%TYPE ;
------------------------------------------------------------------------------------
FUNCTION approval_date(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_REL_PRESENTATION.APPROVAL_DATE%TYPE ;
------------------------------------------------------------------------------------
FUNCTION rec_id(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_REL_PRESENTATION.REC_ID%TYPE ;
------------------------------------------------------------------------------------
FUNCTION row_by_pk (
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2) RETURN CLASS_REL_PRESENTATION%ROWTYPE;

END ec_class_rel_presentation;
/
CREATE OR REPLACE PACKAGE BODY ec_class_rel_presentation IS
------------------------------------------------------------------------------------
-- Package body: ec_class_rel_presentation
-- Generated by EC_GENERATE.
------------------------------------------------------------------------------------















------------------------------------------------------------------------------------
FUNCTION static_presentation_syntax(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2)
RETURN CLASS_REL_PRESENTATION.STATIC_PRESENTATION_SYNTAX%TYPE  IS
   v_return_val CLASS_REL_PRESENTATION.STATIC_PRESENTATION_SYNTAX%TYPE ;
   CURSOR c_col_val IS
   SELECT static_presentation_syntax col
   FROM CLASS_REL_PRESENTATION
WHERE from_class_name = p_from_class_name
AND to_class_name = p_to_class_name
AND role_name = p_role_name;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END static_presentation_syntax;

------------------------------------------------------------------------------------
FUNCTION presentation_syntax(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2)
RETURN CLASS_REL_PRESENTATION.PRESENTATION_SYNTAX%TYPE  IS
   v_return_val CLASS_REL_PRESENTATION.PRESENTATION_SYNTAX%TYPE ;
   CURSOR c_col_val IS
   SELECT presentation_syntax col
   FROM CLASS_REL_PRESENTATION
WHERE from_class_name = p_from_class_name
AND to_class_name = p_to_class_name
AND role_name = p_role_name;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END presentation_syntax;

------------------------------------------------------------------------------------
FUNCTION db_pres_syntax(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2)
RETURN CLASS_REL_PRESENTATION.DB_PRES_SYNTAX%TYPE  IS
   v_return_val CLASS_REL_PRESENTATION.DB_PRES_SYNTAX%TYPE ;
   CURSOR c_col_val IS
   SELECT db_pres_syntax col
   FROM CLASS_REL_PRESENTATION
WHERE from_class_name = p_from_class_name
AND to_class_name = p_to_class_name
AND role_name = p_role_name;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END db_pres_syntax;

------------------------------------------------------------------------------------
FUNCTION label(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2)
RETURN CLASS_REL_PRESENTATION.LABEL%TYPE  IS
   v_return_val CLASS_REL_PRESENTATION.LABEL%TYPE ;
   CURSOR c_col_val IS
   SELECT label col
   FROM CLASS_REL_PRESENTATION
WHERE from_class_name = p_from_class_name
AND to_class_name = p_to_class_name
AND role_name = p_role_name;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END label;

------------------------------------------------------------------------------------
FUNCTION record_status(
         p_from_class_name VARCHAR2,
         p_to_class_name VARCHAR2,
         p_role_name VARCHAR2)
RETURN CLASS_REL_PRESENTATION.RECORD_STATUS%TYPE  IS
   v_return_val CLASS_REL_PRESENTATION.RECORD_STATUS%TYPE ;
   CURSOR c_col_val IS
   SELECT record_status col
   FROM CLASS_REL_PRESENTATION
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
RETURN CLASS_REL_PRESENTATION.APPROVAL_STATE%TYPE  IS
   v_return_val CLASS_REL_PRESENTATION.APPROVAL_STATE%TYPE ;
   CURSOR c_col_val IS
   SELECT approval_state col
   FROM CLASS_REL_PRESENTATION
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
RETURN CLASS_REL_PRESENTATION.APPROVAL_BY%TYPE  IS
   v_return_val CLASS_REL_PRESENTATION.APPROVAL_BY%TYPE ;
   CURSOR c_col_val IS
   SELECT approval_by col
   FROM CLASS_REL_PRESENTATION
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
RETURN CLASS_REL_PRESENTATION.APPROVAL_DATE%TYPE  IS
   v_return_val CLASS_REL_PRESENTATION.APPROVAL_DATE%TYPE ;
   CURSOR c_col_val IS
   SELECT approval_date col
   FROM CLASS_REL_PRESENTATION
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
RETURN CLASS_REL_PRESENTATION.REC_ID%TYPE  IS
   v_return_val CLASS_REL_PRESENTATION.REC_ID%TYPE ;
   CURSOR c_col_val IS
   SELECT rec_id col
   FROM CLASS_REL_PRESENTATION
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
RETURN CLASS_REL_PRESENTATION%ROWTYPE IS
   v_return_rec CLASS_REL_PRESENTATION%ROWTYPE;
   CURSOR c_read_row IS
   SELECT *
   FROM CLASS_REL_PRESENTATION
WHERE from_class_name = p_from_class_name
AND to_class_name = p_to_class_name
AND role_name = p_role_name;
BEGIN
   FOR cur_rec IN c_read_row LOOP
      v_return_rec := cur_rec;
   END LOOP;
   RETURN v_return_rec;
END row_by_pk;



END ec_class_rel_presentation;
/
