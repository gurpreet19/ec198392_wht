CREATE OR REPLACE EDITIONABLE TRIGGER "IUD_V_CURVE" 
 INSTEAD OF INSERT OR UPDATE OR DELETE ON v_curve
FOR EACH ROW

DECLARE
-- Variables for storing temporary values
   ln_perf_curve_id NUMBER;
   ln_count NUMBER := 0;

BEGIN

-- INSERT BLOCK
IF INSERTING THEN

  -- Check whether new data to be inserted has already exist in performance_curve (check for duplicate entries)
   SELECT COUNT(*) INTO ln_count
     FROM performance_curve pc
    WHERE pc.CURVE_OBJECT_ID = :New.CURVE_OBJECT_ID
     AND pc.DAYTIME = :New.DAYTIME
     AND pc.CURVE_PURPOSE = :New.CURVE_PURPOSE;

  -- If no duplicates, create a parent and child entry
  IF ln_count = 0 THEN

      INSERT INTO v_performance_curve (
        perf_curve_id,
        curve_object_id,
        daytime,
        curve_purpose,
        curve_parameter_code,
        perf_curve_status,
        plane_intersect_code,
        poten_2nd_value,
        poten_3rd_value,
        comments,
        cgr,
        gor,
        max_allow_wh_press,
        min_allow_wh_press,
        wgr,
        watercut_pct,
        class_name,
        formula_type,
        phase,
        record_status,
        last_updated_by,
        last_updated_date,
        rev_no,
        rev_text
       ) VALUES (
        :new.perf_curve_id,
        :new.curve_object_id,
        :new.daytime,
        :new.curve_purpose,
        :new.curve_parameter_code,
        :new.perf_curve_status,
        :new.plane_intersect_code,
        :new.poten_2nd_value,
        :new.poten_3rd_value,
        :new.comments,
        :new.cgr,
        :new.gor,
        :new.max_allow_wh_press,
        :new.min_allow_wh_press,
        :new.wgr,
        :new.watercut_pct,
        :new.class_name,
        :new.curve_formula_type,
        :new.curve_phase,
        :new.record_status,
        :new.last_updated_by,
        :new.last_updated_date,
        :new.rev_no,
        :new.rev_text
       );

   -- Get perf_curve_id from parent in order to insert into child
   SELECT perf_curve_id into ln_perf_curve_id
     FROM performance_curve pc
    where pc.curve_object_id = :new.curve_object_id
     and pc.daytime = :new.daytime
     and pc.curve_purpose = :new.curve_purpose;

  -- Child will have some data upon inserting into parent, therefore must update child table instead of inserting
    UPDATE curve
     SET
      z_value = :new.curve_z_value,
      c0 = :new.curve_c0,
      c1 = :new.curve_c1,
      c2 = :new.curve_c2,
      c3 = :new.curve_c3,
      c4 = :new.curve_c4,
      y_valid_from = :new.curve_y_valid_from,
      y_valid_to = :new.curve_y_valid_to,
      comments = :new.comments,
      value_1 = :new.curve_value_1,
      value_2 = :new.curve_value_2,
      value_3 = :new.curve_value_3,
      value_4 = :new.curve_value_4,
      value_5 = :new.curve_value_5,
      value_6 = :new.curve_value_6,
      value_7 = :new.curve_value_7,
      value_8 = :new.curve_value_8,
      value_9 = :new.curve_value_9,
      value_10 = :new.curve_value_10,
      text_1 = :new.curve_text_1,
      text_2 = :new.curve_text_2,
      text_3 = :new.curve_text_3,
      text_4 = :new.curve_text_4,
      record_status = :new.curve_record_status,
      last_updated_by = :new.curve_last_updated_by,
      last_updated_date = :new.curve_last_updated_date,
      rev_no = :new.curve_rev_no,
      rev_text = :new.curve_rev_text,
      approval_by = :new.curve_approval_by,
      approval_date = :new.curve_approval_date,
      approval_state = :new.curve_approval_state,
      rec_id = :new.curve_rec_id
    where
      perf_curve_id = ln_perf_curve_id;

  END IF;

END IF;

-- UPDATE BLOCK
IF UPDATING THEN

  ln_perf_curve_id := :Old.perf_curve_id;

  -- If perf_curve_id is not provided, then select perf_curve_id from table
  IF ln_perf_curve_id IS NULL THEN

   SELECT perf_curve_id INTO ln_perf_curve_id
    from performance_curve
    where curve_object_id = :old.curve_object_id
    and daytime = :old.daytime
    and curve_purpose = :old.curve_purpose;

  END IF;


  -- Compare new and old values

IF :old.curve_object_id <> :new.curve_object_id
     OR :old.daytime <> :new.daytime
     OR :old.curve_purpose <> :new.curve_purpose

THEN

  -- If not the same values, then check whether new data to be inserted has already exist in performance_curve (check for duplicate entries)

   SELECT COUNT(*) INTO ln_count
     FROM performance_curve pc
    where pc.curve_object_id = :new.curve_object_id
     and pc.daytime = :new.daytime
     and pc.curve_purpose = :new.curve_purpose;

  -- If duplicates, raise error
  IF ln_count > 0  THEN
     RAISE_APPLICATION_ERROR(-20000,'Duplicates Update');
  END IF;

END IF;

   -- Update parent table
      UPDATE v_performance_curve
        SET
        daytime = :new.daytime,
        curve_purpose = :new.curve_purpose,
        curve_parameter_code = :new.curve_parameter_code,
        perf_curve_status = :new.perf_curve_status,
        plane_intersect_code = :new.plane_intersect_code,
        poten_2nd_value = :new.poten_2nd_value,
        poten_3rd_value = :new.poten_3rd_value,
        comments = :new.comments,
        cgr = :new.cgr,
        gor = :new.gor,
        max_allow_wh_press = :new.max_allow_wh_press,
        min_allow_wh_press = :new.min_allow_wh_press,
        wgr = :new.wgr,
        watercut_pct = :new.watercut_pct,
        class_name = :new.class_name,
        formula_type = :new.curve_formula_type,
        phase = :new.curve_phase,
        record_status = :new.record_status,
        last_updated_by = :new.last_updated_by,
        last_updated_date = :new.last_updated_date,
        rev_no = :new.rev_no,
        rev_text = :new.rev_text
       where perf_curve_id = ln_perf_curve_id;

   -- Update child table
    UPDATE curve
     SET
      phase = :new.curve_phase,
      formula_type = :new.curve_formula_type,
      z_value = :new.curve_z_value,
      c0 = :new.curve_c0,
      c1 = :new.curve_c1,
      c2 = :new.curve_c2,
      c3 = :new.curve_c3,
      c4 = :new.curve_c4,
      y_valid_from = :new.curve_y_valid_from,
      y_valid_to = :new.curve_y_valid_to,
      comments = :new.curve_comments,
      value_1 = :new.curve_value_1,
      value_2 = :new.curve_value_2,
      value_3 = :new.curve_value_3,
      value_4 = :new.curve_value_4,
      value_5 = :new.curve_value_5,
      value_6 = :new.curve_value_6,
      value_7 = :new.curve_value_7,
      value_8 = :new.curve_value_8,
      value_9 = :new.curve_value_9,
      value_10 = :new.curve_value_10,
      text_1 = :new.curve_text_1,
      text_2 = :new.curve_text_2,
      text_3 = :new.curve_text_3,
      text_4 = :new.curve_text_4,
      record_status = :new.curve_record_status,
      last_updated_by = :new.curve_last_updated_by,
      last_updated_date = :new.curve_last_updated_date,
      rev_no = :new.curve_rev_no,
      rev_text = :new.curve_rev_text
    WHERE perf_curve_id = ln_perf_curve_id;

END IF;

-- DELETE BLOCK
IF DELETING THEN

  ln_perf_curve_id := :Old.perf_curve_id;

  -- If perf_curve_id is not provided, then select perf_curve_id from table
  IF ln_perf_curve_id IS NULL THEN

   SELECT perf_curve_id INTO ln_perf_curve_id
    FROM performance_curve
    WHERE curve_object_id = :old.curve_object_id
    AND daytime = :old.daytime
    AND curve_purpose = :old.curve_purpose;

  END IF;

  -- Delete child row
  DELETE FROM curve
   WHERE perf_curve_id = ln_perf_curve_id;

  -- Delete parent row
  DELETE FROM v_performance_curve
   WHERE perf_curve_id = ln_perf_curve_id;


END IF;

END;
