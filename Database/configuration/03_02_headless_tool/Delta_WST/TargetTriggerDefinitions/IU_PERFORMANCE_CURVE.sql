CREATE OR REPLACE TRIGGER "IU_PERFORMANCE_CURVE" 
BEFORE INSERT OR UPDATE ON performance_curve
FOR EACH ROW
BEGIN
    -- $Revision: 1.5.46.1 $
    -- Common
    IF Inserting THEN
      :NEW.record_status := NVL(:NEW.record_status,'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := User;
      END IF;

      IF :new.created_date IS NULL THEN
         :new.created_date := EcDp_Date_Time.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;

      IF :new.perf_curve_id IS NULL THEN
         EcDp_System_Key.assignNextNumber('PERFORMANCE_CURVE', :new.perf_curve_id);
      END IF;

      IF :new.perf_curve_status IS NULL THEN
         :new.perf_curve_status := 'NEW';
      END IF;

    ELSE
      IF Nvl(:new.record_status,'P') = Nvl(:old.record_status,'P') THEN
         IF NOT UPDATING('LAST_UPDATED_BY') THEN
            :new.last_updated_by := User;
         END IF;
         IF NOT UPDATING('LAST_UPDATED_DATE') THEN
           :new.last_updated_date := EcDp_Date_Time.getCurrentSysdate;
         END IF;

      END IF;
    END IF;
END;

