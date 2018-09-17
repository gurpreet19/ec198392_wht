CREATE OR REPLACE EDITIONABLE TRIGGER "IU_V_PERFORMANCE_CURVE" 
INSTEAD OF INSERT OR UPDATE OR DELETE ON V_PERFORMANCE_CURVE
FOR EACH ROW
DECLARE
   ln_cnt NUMBER;
   ln_id performance_curve.perf_curve_id%TYPE;
   lv2_jn_operation char(3);
   lv2_jn_last_updated_by VARCHAR2(30);
BEGIN
   -- $Revision: 1.12 $
   -- Common

   IF INSERTING THEN

      INSERT INTO performance_curve
      (
         curve_object_id,
         class_name,
         daytime,
         curve_purpose,
         curve_parameter_code,
         plane_intersect_code,
	 	     poten_2nd_value,
	       poten_3rd_value,
         min_allow_wh_press,
         max_allow_wh_press,
         gor,
         watercut_pct,
         cgr,
         wgr,
         perf_curve_status,
         phase,
         formula_type,
         comments,
         record_status,
         created_by,
         created_date,
         last_updated_by,
         last_updated_date,
         rev_no,
         rev_text
      ) VALUES (
         :NEW.curve_object_id,
         :NEW.class_name,
         :NEW.daytime,
         :NEW.curve_purpose,
         :NEW.curve_parameter_code,
         :NEW.plane_intersect_code,
	       :NEW.poten_2nd_value,
	       :NEW.poten_3rd_value,
         :NEW.min_allow_wh_press,
         :NEW.max_allow_wh_press,
         :NEW.gor,
         :NEW.watercut_pct,
         :NEW.cgr,
         :NEW.wgr,
         :NEW.perf_curve_status,
         :NEW.phase,
         :NEW.formula_type,
         :NEW.comments,
         :NEW.record_status,
         :NEW.created_by,
         :NEW.created_date,
         :NEW.last_updated_by,
         :NEW.last_updated_date,
         :NEW.rev_no,
         :NEW.rev_text
      ) RETURNING perf_curve_id INTO ln_id;

   ELSIF DELETING THEN

      DELETE FROM PERFORMANCE_CURVE WHERE perf_curve_id = :OLD.perf_curve_id;

   ELSE

      ln_id := :NEW.perf_curve_id;

      UPDATE performance_curve SET
         perf_curve_id = ln_id,
         curve_object_id=:NEW.curve_object_id,
         daytime=:NEW.daytime,
         curve_purpose=:NEW.curve_purpose,
         curve_parameter_code=:NEW.curve_parameter_code,
         plane_intersect_code=:NEW.plane_intersect_code,
         poten_2nd_value=:NEW.poten_2nd_value,
	       poten_3rd_value=:NEW.poten_3rd_value,
         min_allow_wh_press=:NEW.min_allow_wh_press,
         max_allow_wh_press=:NEW.max_allow_wh_press,
         gor=:NEW.gor,
         watercut_pct =:NEW.watercut_pct,
         cgr =:NEW.cgr,
         wgr =:NEW.wgr,
         perf_curve_status =:NEW.perf_curve_status,
         phase =:NEW.phase,
         formula_type =:NEW.formula_type,
         comments=:NEW.comments,
         record_status=:NEW.record_status,
         created_by=:NEW.created_by,
         created_date=:NEW.created_date,
         last_updated_by=:NEW.last_updated_by,
         last_updated_date=:NEW.last_updated_date,
         rev_no=:NEW.rev_no,
         rev_text=:NEW.rev_text
      WHERE perf_curve_id = :OLD.perf_curve_id;

   END IF;

   -- There must always be at least one curve, and all curves should have the same phase and formula type --
   IF NOT DELETING THEN
      SELECT COUNT(*) INTO ln_cnt FROM curve WHERE perf_curve_id=ln_id;
      IF ln_cnt=0 THEN
         INSERT INTO curve (perf_curve_id,formula_type,phase,z_value,created_by,created_date)
         VALUES (ln_id,:NEW.formula_type,:NEW.phase,0,:NEW.last_updated_by,:NEW.last_updated_date);
      ELSE
         UPDATE curve SET phase=:NEW.phase,formula_type=:NEW.formula_type
         WHERE perf_curve_id=ln_id;
      END IF;
   END IF;

   -- Update journal table
   IF UPDATING OR DELETING THEN
      IF Deleting THEN
        lv2_jn_operation := 'DEL';
        lv2_jn_last_updated_by := Nvl(EcDp_User_Session.getUserSessionParameter('USERNAME'), User);
      ELSE
        lv2_jn_operation := 'UPD';
        lv2_jn_last_updated_by := :new.last_updated_by;
      END IF;

   	INSERT INTO v_performance_curve_JN
      (jn_operation, jn_oracle_user, jn_datetime
       ,PERF_CURVE_ID
       ,CURVE_OBJECT_ID
       ,CLASS_NAME
       ,DAYTIME
       ,CURVE_PURPOSE
       ,CURVE_PARAMETER_CODE
       ,PLANE_INTERSECT_CODE
       ,POTEN_2ND_VALUE
       ,POTEN_3RD_VALUE
       ,MIN_ALLOW_WH_PRESS
       ,MAX_ALLOW_WH_PRESS
       ,GOR
       ,WATERCUT_PCT
       ,CGR
       ,WGR
       ,PERF_CURVE_STATUS
       ,COMMENTS
       ,FORMULA_TYPE
       ,PHASE
       ,RECORD_STATUS
       ,CREATED_BY
       ,CREATED_DATE
       ,LAST_UPDATED_BY
       ,LAST_UPDATED_DATE
       ,REV_NO
       ,REV_TEXT
      )
      VALUES
      (lv2_jn_operation, lv2_jn_last_updated_by, Ecdp_Timestamp.getCurrentSysdate
       ,:old.PERF_CURVE_ID
       ,:old.CURVE_OBJECT_ID
       ,:old.CLASS_NAME
       ,:old.DAYTIME
       ,:old.CURVE_PURPOSE
       ,:old.CURVE_PARAMETER_CODE
       ,:old.PLANE_INTERSECT_CODE
       ,:old.POTEN_2ND_VALUE
       ,:old.POTEN_3RD_VALUE
       ,:old.MIN_ALLOW_WH_PRESS
       ,:old.MAX_ALLOW_WH_PRESS
       ,:old.GOR
       ,:old.WATERCUT_PCT
       ,:old.CGR
       ,:old.WGR
       ,:old.PERF_CURVE_STATUS
       ,:old.COMMENTS
       ,:old.FORMULA_TYPE
       ,:old.PHASE
       ,:old.RECORD_STATUS
       ,:old.CREATED_BY
       ,:old.CREATED_DATE
       ,:old.LAST_UPDATED_BY
       ,:old.LAST_UPDATED_DATE
       ,:old.REV_NO
       ,:old.REV_TEXT
      );
   END IF; -- Updating or Deleting (JN ??)
END;
