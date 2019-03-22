CREATE OR REPLACE EDITIONABLE TRIGGER "IU_PERF_PERIOD_STATUS" 
BEFORE INSERT OR UPDATE ON PERF_PERIOD_STATUS
FOR EACH ROW
BEGIN
    -- $Revision: 1.1 $
    -- Common
    IF Inserting THEN

      :NEW.record_status := NVL(:NEW.record_status,'P');

      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;
      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;

      EcDp_Timestamp_Utils.syncUtcDate(:NEW.object_id, :NEW.utc_daytime, :NEW.daytime, :NEW.summer_time);
      EcDp_Timestamp_Utils.setProductionDay(:NEW.object_id, :NEW.utc_daytime, :NEW.day);

      IF :NEW.active_perf_status IS NULL THEN
         :NEW.active_perf_status := EcDp_System.getDependentCode('ACTIVE_PERF_STATUS', 'PERF_STATUS', :NEW.perf_status);
      END IF;

    ELSIF Updating('PERF_STATUS') THEN
      :NEW.active_perf_status := EcDp_System.getDependentCode('ACTIVE_PERF_STATUS', 'PERF_STATUS', :NEW.perf_status);

    ELSE
      EcDp_Timestamp_Utils.updateUtcAndDaytime(:NEW.object_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.daytime, :NEW.daytime, :OLD.summer_time, :NEW.summer_time);
      EcDp_Timestamp_Utils.updateProductionDay(:NEW.object_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.day, :NEW.day);

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
