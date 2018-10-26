CREATE OR REPLACE EDITIONABLE TRIGGER "IUD_V_CALC_OBJ_TYPE_IMPL_CLS" 
 INSTEAD OF INSERT OR UPDATE OR DELETE ON v_calc_obj_type_impl_cls
FOR EACH ROW
-- $Revision: 1.1 $
-- $Author: SIAH
DECLARE

v_exp              VARCHAR2(500);
v_new_object_id    VARCHAR2(32);
v_new_obj_type     VARCHAR2(32);
v_new_exc_ind      VARCHAR2(1);
v_cls_name         VARCHAR2(32);

BEGIN


IF UPDATING THEN

  v_new_object_id := trim(:New.object_id);
  v_new_obj_type := trim(:New.object_type_code);
  v_new_exc_ind := trim(:New.excluded_ind);
  v_cls_name := trim(:New.class_name);


   SELECT decode(ot.excl_impl_class_list, null,'-',ot.excl_impl_class_list) INTO v_exp FROM calc_object_type ot
   WHERE ot.object_id = v_new_object_id
   AND ot.object_type_code = v_new_obj_type;

    IF (:New.excluded_ind = 'Y' and v_exp = '-') THEN
       v_exp := v_cls_name;

    ELSIF (:New.excluded_ind = 'Y' and length(v_exp) > 1) THEN
       v_exp := v_exp || ','|| v_cls_name;

    ELSIF (:New.excluded_ind = 'N' and instr(v_exp,',',1,1) < 1) THEN
       v_exp := replace(v_exp , v_cls_name , ''); -- without delimiter

    ELSE
       IF instr(v_exp, v_cls_name,1,1) = 1 THEN
          v_exp := replace(v_exp , v_cls_name || ',', ''); -- located at first position with delimiter
       ELSE
          v_exp := replace(v_exp , ',' ||v_cls_name, ''); -- located at middle or last position with delimeter
       END IF;
    END IF;


    UPDATE CALC_OBJECT_TYPE
    SET excl_impl_class_list = v_exp,
        REV_TEXT = :New.rev_text,
        REV_NO = :New.rev_no,
        RECORD_STATUS = :New.record_status
    WHERE object_id = v_new_object_id
    AND object_type_code = v_new_obj_type;

    IF (v_new_exc_ind = 'Y')  THEN
      DELETE FROM calc_object_filter
      WHERE object_id = v_new_object_id
      AND object_type_code = v_new_obj_type
      AND impl_class_name = v_cls_name;

    END IF;

END IF;

END;
