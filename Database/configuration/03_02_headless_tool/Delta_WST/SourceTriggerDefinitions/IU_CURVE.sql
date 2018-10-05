CREATE OR REPLACE EDITIONABLE TRIGGER "IU_CURVE" 
BEFORE INSERT OR UPDATE ON CURVE
FOR EACH ROW
DECLARE
   ln_y_minmax NUMBER;
   ln_num_below NUMBER;
   ln_num_above NUMBER;
   lv2_measurementtype_y VARCHAR2(32);
   lv2_dbunit_y VARCHAR2(16);
   lv2_screenunit_y VARCHAR2(16);

   CURSOR c_formula_type IS
      SELECT DISTINCT formula_type FROM curve WHERE perf_curve_id=:NEW.perf_curve_id;
   CURSOR c_phase IS
      SELECT DISTINCT phase FROM curve WHERE perf_curve_id=:NEW.perf_curve_id;

BEGIN
    -- $Revision: 1.8 $
    -- Common
    IF Inserting THEN
      :NEW.record_status := NVL(:NEW.record_status,ec_performance_curve.record_status(:NEW.perf_curve_id));
      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;

      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;

      IF :new.curve_id IS NULL THEN
         EcDp_System_Key.assignNextNumber('CURVE', :new.curve_id);
      END IF;

      IF :NEW.formula_type IS NULL THEN
         FOR r_formula_type IN c_formula_type LOOP
            :NEW.formula_type:=r_formula_type.formula_type;
         END LOOP;
      END IF;
      IF :NEW.phase IS NULL THEN
         FOR r_phase IN c_phase LOOP
            :NEW.phase:=r_phase.phase;
         END LOOP;
      END IF;

    ELSE
      IF Nvl(:new.record_status,'P') = Nvl(:old.record_status,'P') THEN
         IF NOT UPDATING('LAST_UPDATED_BY') THEN
            :new.last_updated_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
         END IF;
         IF NOT UPDATING('LAST_UPDATED_DATE') THEN
           :new.last_updated_date := Ecdp_Timestamp.getCurrentSysdate;
         END IF;

      END IF;
    END IF;

   --
   -- Clear out any unused coefficients (depends on formula type)
   --
   IF :NEW.formula_type = EcDp_Curve_Constant.CURVE_POINT THEN
      :NEW.C4:=NULL;
      :NEW.C3:=NULL;
      :NEW.C2:=NULL;
      :NEW.C1:=NULL;
      :NEW.C0:=NULL;
   ELSIF :NEW.formula_type = EcDp_Curve_Constant.LINEAR THEN
      :NEW.C4:=NULL;
      :NEW.C3:=NULL;
      :NEW.C2:=NULL;
   ELSIF :NEW.formula_type = EcDp_Curve_Constant.INV_POLYNOM_2 THEN
      :NEW.C4:=NULL;
      :NEW.C3:=NULL;
   ELSIF :NEW.formula_type = EcDp_Curve_Constant.POLYNOM_2 THEN
      :NEW.C4:=NULL;
      :NEW.C3:=NULL;
   ELSIF :NEW.formula_type = EcDp_Curve_Constant.POLYNOM_3 THEN
      :NEW.C4:=NULL;
   END IF;

   -- to get the measurement type if formula type=INV_POLYNOM2 for Y axis in order to do the conversion
   -- or else it'll draw incorectly
   IF :NEW.phase = ecdp_phase.OIL then
      lv2_measurementtype_y := 'STD_OIL_RATE';
   ELSIF :NEW.phase=ecdp_phase.GAS then
      lv2_measurementtype_y := 'STD_GAS_RATE';
   ELSIF :NEW.phase=ecdp_phase.WATER then
      lv2_measurementtype_y := EcDp_Ctrl_Property.getSystemProperty('DEFAULT_WATER_RATE_UOM');
   ELSIF:NEW.phase=ecdp_phase.LIQUID then
      lv2_measurementtype_y := 'STD_LIQ_VOL_RATE';
   END IF;

   -- get the dbunit and screenunit for Y axis
   lv2_dbunit_y:=ecdp_unit.GetUnitFromLogical(lv2_measurementtype_y);
   lv2_screenunit_y:=ecdp_unit.GetViewUnitFromLogical(lv2_measurementtype_y);

   --
   -- Handle Y_VALID_FROM and Y_VALID_TO.
   -- For inverse polynoms with multiple solutions, one must be the min/max point.
   -- Otherwise, Y_VALID_FROM is 0 and Y_VALID_TO is NULL.
   --
   IF :NEW.formula_type=EcDp_Curve_Constant.INV_POLYNOM_2 AND ((:NEW.c2>0 AND :NEW.c1<0) OR (:NEW.c2<0 AND :NEW.c1>0)) THEN
      -- This curve can have more than one solution for y=f(x) in Q1, find y bounds
      -- This is the min/max point. We know that this is larger than 0, so it must be a boundary:
      ln_y_minmax:=-:NEW.c1/(2*:NEW.c2);
      -- We check whether this should be the lower or higher boundary by checking where the samples are...
	  -- have to do conversion for y_value below or else it'll draw incorectly
      SELECT COUNT(*) INTO ln_num_below FROM curve_point WHERE curve_id=:NEW.curve_id AND ecdp_unit.convertValue(y_value,lv2_dbunit_y,lv2_screenunit_y)<ln_y_minmax;
      SELECT COUNT(*) INTO ln_num_above FROM curve_point WHERE curve_id=:NEW.curve_id AND ecdp_unit.convertValue(y_value,lv2_dbunit_y,lv2_screenunit_y)>ln_y_minmax;

      IF ln_num_below>=ln_num_above THEN
         -- The samples are at lower y, use as high boundary
         :NEW.y_valid_from:=NULL;
         :NEW.y_valid_to:=ln_y_minmax;
      ELSE
         -- The samples are not at lower y, use as low boundary
         :NEW.y_valid_from:=ln_y_minmax;
         :NEW.y_valid_to:=NULL;
      END IF;
   ELSE
      :NEW.y_valid_from:=NULL;
      :NEW.y_valid_to:=NULL;
   END IF;

END;
