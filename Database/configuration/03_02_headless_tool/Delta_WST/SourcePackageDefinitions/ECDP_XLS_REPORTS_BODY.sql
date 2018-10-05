CREATE OR REPLACE PACKAGE BODY EcDp_XLS_Reports IS
/****************************************************************
** Package        :  EcDp_XLS_Reports, body part
**
** $Revision: 1.2 $
**
** Purpose        :  Support functions for Excel based calculations.
**
** Documentation  :  www.energy-components.com
**
** Created  : 17.02.2009  Bent Ivar Helland
**
** Modification history:
**
** Date        Who  Change description:
** ----------  ---- --------------------------------------
** 2009-02-17  BIH  Initial version
*****************************************************************/


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getObjectTypeLabel
-- Description    : Returns the label for a given Object Type.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: ec_rept_object_type.row_by_pk, ec_class.label
--
-- Configuration
-- required       :
--
-- Behaviour      : Tries to determine the label to use in the following order:
--                  1) If the object type has a label_override then that is used
--                  2) If the object type is a database object type, and the corresponding
--                     class has a label, then that is used
--                  3) If none of the above was found then the object type code is used
--
-----------------------------------------------------------------------------------------------------
FUNCTION getObjectTypeLabel (
   p_object_id                      VARCHAR2,
   p_object_type_code               VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>
IS
   lr_obj_type   REPT_OBJECT_TYPE%ROWTYPE;
BEGIN
   lr_obj_type := ec_rept_object_type.row_by_pk(p_object_id, p_object_type_code);
   IF lr_obj_type.REPT_OBJ_TYPE_CATEGORY = 'DB' THEN
      RETURN NVL(lr_obj_type.label_override, NVL(EcDp_ClassMeta_Cnfg.getLabel(p_object_type_code), p_object_type_code));
   END IF;
   RETURN NVL(lr_obj_type.label_override, p_object_type_code);
END getObjectTypeLabel;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getSetDescription
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : rept_set_condition, rept_set_combination,
--
-- Using functions: getObjectTypeLabel, ec_prosty_codes.code_text
--
-- Configuration
-- required       : Relevant EC codes must be configured and their text must be formulated to fit
--                  with the way the description is built.
--                  (REPT_SET_FILTER_OPERATOR, REPT_SET_FILTER_OPERAND_TYPE, REPT_SET_ORDER_TYPE)
--
-- Behaviour      : Builds a textual description of a set based on the set configuration and any
--                  conditions or combination records.
--                  The description will include the text for some EC codes, so if these texts are changed
--                  then the descriptions would be affected.
--
-----------------------------------------------------------------------------------------------------
FUNCTION getSetDescription(
   p_rept_context_id   VARCHAR2,
   p_set_name          VARCHAR2,
   p_object_type_code  VARCHAR2,
   p_set_type          VARCHAR2,
   p_set_op_name       VARCHAR2,
   p_order_dir         VARCHAR2,
   p_order_by          VARCHAR2,
   p_desc_override     VARCHAR2,

   p_operator          VARCHAR2,
   p_element_time_scope_code VARCHAR2,
   p_set_time_scope_code     VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>
IS
   CURSOR c_set_cons IS
     SELECT sc.rept_obj_attr_sql_syntax as op1_sql_syntax,
            sc.rept_set_cond_operator as operator,
            sc.rept_set_cond_type as op2_set_cond_type,
            sc.rept_set_cond_value as op2_set_cond_value
     FROM rept_set_condition sc
     WHERE sc.object_id = p_rept_context_id
     AND sc.name = p_set_name
     ORDER BY sc.seq_no;

   CURSOR c_set_combination IS
      SELECT sc.seq_no, sc.op_rept_set_name
      FROM rept_set_combination sc
      WHERE sc.object_id = p_rept_context_id
      AND sc.name = p_set_name
      ORDER BY sc.seq_no;

 lv2_retval  VARCHAR2(4000);
 ln_num_rows INTEGER := 0;
 ln_row_num  INTEGER := 0;

 BEGIN
    -- Things that are unique to each type
    IF (p_set_type = 'DB_OBJECT_TYPE') THEN
       lv2_retval := 'Objects of type ' ||  getObjectTypeLabel(p_rept_context_id, p_object_type_code);
    ELSIF (p_set_type = 'DAYTIME_SET') THEN
       lv2_retval := 'All daytimes of type '
                  || ec_prosty_codes.code_text(p_element_time_scope_code, 'METER_FREQ')
                  || ' in the current '
                  || ec_prosty_codes.code_text(p_set_time_scope_code, 'METER_FREQ');
    ELSIF (p_set_type = 'COMBINED_SET') THEN
      lv2_retval := 'Objects in set ' || p_set_op_name;
      IF p_operator = 'UNION' THEN
         lv2_retval := lv2_retval || ', ';
      ELSIF p_operator = 'MINUSUNION' THEN
         lv2_retval := lv2_retval || ' but not in ';
      ELSIF p_operator = 'INTERSECT' THEN
         lv2_retval := lv2_retval || ' that are also in ';
      END IF;
      FOR cur_set_combination IN c_set_combination LOOP
          ln_num_rows := ln_num_rows + 1;
      END LOOP;
      FOR cur_set_combination IN c_set_combination LOOP
          lv2_retval := lv2_retval || cur_set_combination.op_rept_set_name;
          IF p_operator IN ('UNION', 'MINUSUNION') AND ln_row_num=(ln_num_rows-2) THEN
             lv2_retval := lv2_retval || ' or ';
          ELSIF ln_row_num=(ln_num_rows-2) THEN
             lv2_retval := lv2_retval || ' and ';
          ELSIF ln_row_num<(ln_num_rows-2) THEN
             lv2_retval := lv2_retval || ', ';
          END IF;
          ln_row_num := ln_row_num + 1;
      END LOOP;
    ELSIF (p_set_type = 'FILTERED_SET') THEN
       lv2_retval := 'All ' || p_set_op_name;
    END IF;

   -- Filtering (DB Objects and Filtered)
   IF (p_set_type IN ('DB_OBJECT_TYPE', 'FILTERED_SET')) AND p_operator IS NOT NULL THEN
      lv2_retval := lv2_retval || ' where ';
      FOR cur_set_cons IN c_set_cons LOOP
          ln_num_rows := ln_num_rows + 1;
      END LOOP;
      FOR cur_set_cons IN c_set_cons LOOP
          IF cur_set_cons.op2_set_cond_type = 'PARAMETER' THEN
             lv2_retval := lv2_retval || cur_set_cons.op1_sql_syntax || ' ' ||ec_prosty_codes.code_text(cur_set_cons.operator, 'REPT_SET_FILTER_OPERATOR') || ' (' || ec_prosty_codes.code_text(cur_set_cons.op2_set_cond_type, 'REPT_SET_FILTER_OPERAND_TYPE') ||') "' || cur_set_cons.op2_set_cond_value || '"';
          ELSE
             lv2_retval := lv2_retval || cur_set_cons.op1_sql_syntax || ' ' ||ec_prosty_codes.code_text(cur_set_cons.operator, 'REPT_SET_FILTER_OPERATOR') || ' "' || cur_set_cons.op2_set_cond_value || '"';
          END IF;
          IF p_operator = 'ALL' AND ln_row_num=(ln_num_rows-2) THEN
             lv2_retval := lv2_retval || ' and ';
          ELSIF p_operator = 'ALL' AND ln_row_num<(ln_num_rows-2) THEN
             lv2_retval := lv2_retval || ', ';
          ELSIF p_operator = 'ONE' AND ln_row_num<=(ln_num_rows-2) THEN
             lv2_retval := lv2_retval || ' or ';
          END IF;
          ln_row_num := ln_row_num + 1;
      END LOOP;
    END IF;

    -- Sorting (all types)
    IF (p_order_dir IS NOT NULL) THEN
       lv2_retval := lv2_retval || ' sorted ' || ec_prosty_codes.code_text(p_order_dir, 'REPT_SET_ORDER_TYPE')  || ' by ' || p_order_by;
    END IF;

   RETURN lv2_retval;
END getSetDescription;

END EcDp_XLS_Reports;