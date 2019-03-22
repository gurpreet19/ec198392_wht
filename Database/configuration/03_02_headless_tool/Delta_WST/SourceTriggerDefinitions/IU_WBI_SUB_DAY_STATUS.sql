CREATE OR REPLACE EDITIONABLE TRIGGER "IU_WBI_SUB_DAY_STATUS" 
BEFORE INSERT OR UPDATE ON wbi_sub_day_status
FOR EACH ROW

DECLARE

CURSOR c_get_well(cp_wbi_object_id VARCHAR2) IS
SELECT w.object_id
FROM webo_interval wbi, webo_bore wb, well w
WHERE wbi.well_bore_id = wb.object_id
AND wb.well_id = w.object_id
AND wbi.object_id = cp_wbi_object_id;

BEGIN
    -- $Revision: 1.5 $
    -- Common
    IF Inserting THEN

      FOR cur_rec IN c_get_well(:NEW.object_id) LOOP

         EcDp_Timestamp_Utils.syncUtcDate(cur_rec.object_id, :NEW.utc_daytime, :NEW.daytime, :NEW.summer_time);
         EcDp_Timestamp_Utils.setProductionDay(cur_rec.object_id, :NEW.utc_daytime, :NEW.production_day);

      END LOOP;


      :NEW.record_status := NVL(:NEW.record_status,'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;
      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;
    ELSE
      IF UPDATING THEN
         FOR cur_rec IN c_get_well(:NEW.object_id) LOOP
            EcDp_Timestamp_Utils.updateUtcAndDaytime(cur_rec.object_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.daytime, :NEW.daytime, :OLD.summer_time, :NEW.summer_time);
            EcDp_Timestamp_Utils.updateProductionDay(cur_rec.object_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.production_day, :NEW.production_day);
         END LOOP;
      END IF;

      IF Nvl(:new.record_status,'P') = Nvl(:old.record_status,'P') THEN
         IF NOT UPDATING('LAST_UPDATED_BY') THEN
            :new.last_updated_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
         END IF;
         IF NOT UPDATING('LAST_UPDATED_DATE') THEN
           :new.last_updated_date := Ecdp_Timestamp.getCurrentSysdate;
         END IF;
      END IF;
    END IF;
END;
