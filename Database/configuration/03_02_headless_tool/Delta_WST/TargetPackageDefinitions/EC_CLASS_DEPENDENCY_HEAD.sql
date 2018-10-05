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