CREATE OR REPLACE EDITIONABLE TRIGGER "IU_OBJECT_SUB_DAY_DIM2_ALLOC" 
BEFORE INSERT OR UPDATE ON object_sub_day_dim2_alloc
FOR EACH ROW
BEGIN
    -- Common
    IF Inserting THEN

      EcDp_Timestamp_Utils.syncUtcDate(NULL, :NEW.object_id, :NEW.utc_daytime, :NEW.time_zone, :NEW.daytime, :NEW.summertime);
      EcDp_Timestamp_Utils.setProductionDay(NULL, :NEW.object_id, :NEW.utc_daytime, :NEW.production_day);

      :NEW.record_status := NVL(:NEW.record_status,'P');

      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;

      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;
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
END;