CREATE OR REPLACE EDITIONABLE TRIGGER "IU_WBI_INJ_SAMPLE" 
BEFORE INSERT OR UPDATE ON WBI_INJ_SAMPLE
FOR EACH ROW

DECLARE

  CURSOR c_get_well(cp_wbi_object_id VARCHAR2) IS
    SELECT w.object_id
      FROM webo_interval wbi, webo_bore wb, well w
     WHERE wbi.well_bore_id = wb.object_id AND wb.well_id = w.object_id AND
           wbi.object_id = cp_wbi_object_id;

BEGIN
    -- Common
    IF Inserting THEN
      :new.dayhr := trunc(:new.daytime,'HH24');

      :new.record_status := nvl(:new.record_status, 'P');

    FOR cur_rec IN c_get_well(:NEW.object_id) LOOP
      EcDp_Timestamp_Utils.syncUtcDate(cur_rec.object_id, :NEW.utc_daytime, :NEW.daytime, :NEW.summer_time);
      :NEW.production_day := EcDp_Timestamp.getProductionDayFromLocal(cur_rec.object_id, :NEW.daytime);
    END LOOP;

      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;
      IF :new.created_date IS NULL THEN
         :new.created_date := EcDp_Timestamp.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;
    ELSE
      FOR cur_rec IN c_get_well(:NEW.object_id) LOOP
          EcDp_Timestamp_Utils.updateUtcAndDaytime(cur_rec.object_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.daytime, :NEW.daytime, :OLD.summer_time, :NEW.summer_time);
          :NEW.production_day := EcDp_Timestamp.getProductionDayFromLocal(cur_rec.object_id, :NEW.daytime);
      END LOOP;
      IF Nvl(:new.record_status,'P') = Nvl(:old.record_status,'P') THEN
         IF NOT UPDATING('LAST_UPDATED_BY') THEN
            :new.last_updated_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
         END IF;
         IF NOT UPDATING('LAST_UPDATED_DATE') THEN
           :new.last_updated_date := EcDp_Timestamp.getCurrentSysdate;
         END IF;
      END IF;
    END IF;
END;
