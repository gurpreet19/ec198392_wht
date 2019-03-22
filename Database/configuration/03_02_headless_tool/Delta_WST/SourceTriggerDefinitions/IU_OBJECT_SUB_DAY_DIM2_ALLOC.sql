CREATE OR REPLACE EDITIONABLE TRIGGER "IU_OBJECT_SUB_DAY_DIM2_ALLOC" 
BEFORE INSERT OR UPDATE ON OBJECT_SUB_DAY_DIM2_ALLOC
FOR EACH ROW
BEGIN
    -- Basis
    IF Inserting THEN

      :new.record_status := nvl(:new.record_status, 'P');
      EcDp_Timestamp_Utils.syncUtcDate(:NEW.object_id, :NEW.utc_daytime, :NEW.daytime);
      :NEW.production_day := EcDp_Timestamp.getProductionDayFromLocal(:NEW.object_id, :NEW.daytime);

      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;
      IF :new.created_date IS NULL THEN
         :new.created_date := EcDp_Timestamp.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;
    ELSE 
      EcDp_Timestamp_Utils.updateUtcAndDaytime(:NEW.object_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.daytime, :NEW.daytime);
      :NEW.production_day := EcDp_Timestamp.getProductionDayFromLocal(:NEW.object_id, :NEW.daytime);

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
