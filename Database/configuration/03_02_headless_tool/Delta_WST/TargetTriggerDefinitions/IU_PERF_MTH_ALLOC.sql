CREATE OR REPLACE TRIGGER "IU_PERF_MTH_ALLOC" 
BEFORE INSERT OR UPDATE ON PERF_MTH_ALLOC
FOR EACH ROW
DECLARE


BEGIN
    -- Common
    IF Inserting THEN
      :new.daytime := trunc(:new.daytime,'MM');
      :new.record_status := nvl(:new.record_status, 'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := User;
      END IF;
      IF :new.created_date IS NULL THEN
         :new.created_date := EcDp_Date_Time.getCurrentSysdate;
      END IF;
      IF :NEW.well_id IS NULL THEN -- inserting well_id
         :NEW.well_id:=ec_perf_interval.well_id(:NEW.object_id);
      END IF;
      IF :NEW.rbf_id IS NULL THEN -- inserting rbf_id
         :NEW.rbf_id:=ec_perf_interval.resv_block_formation_id(:NEW.object_id);
      END IF;
      :new.rev_no := 0;
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
