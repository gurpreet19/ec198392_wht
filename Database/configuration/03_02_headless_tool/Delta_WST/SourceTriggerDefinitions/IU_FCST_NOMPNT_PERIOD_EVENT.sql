CREATE OR REPLACE EDITIONABLE TRIGGER "IU_FCST_NOMPNT_PERIOD_EVENT" 
BEFORE INSERT OR UPDATE ON FCST_NOMPNT_PERIOD_EVENT
FOR EACH ROW
BEGIN
    -- Common
    IF Inserting THEN

      :new.record_status := nvl(:new.record_status, 'P');
      EcDp_Timestamp_Utils.syncUtcDate(:NEW.object_id, :NEW.utc_daytime, :NEW.daytime);
      EcDp_Timestamp_Utils.setProductionDay(:NEW.object_id, :NEW.utc_daytime, :NEW.production_day);

      EcDp_Timestamp_Utils.syncUtcDate(:NEW.object_id, :NEW.utc_end_date, :NEW.end_date);
      EcDp_Timestamp_Utils.setProductionDay(:NEW.object_id, :NEW.utc_end_date, :NEW.end_day);

      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;

	  IF :new.EVENT_SEQ IS NULL THEN
         EcDp_System_Key.assignNextNumber('NOMPNT_PERIOD_EVENT', :new.EVENT_SEQ);
      END IF;

      IF :new.created_date IS NULL THEN
         :new.created_date := EcDp_Timestamp.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;
    ELSE
      EcDp_Timestamp_Utils.updateUtcAndDaytime(:NEW.object_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.daytime, :NEW.daytime);
      EcDp_Timestamp_Utils.updateProductionDay(:NEW.object_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.production_day, :NEW.production_day);

      EcDp_Timestamp_Utils.updateUtcAndDaytime(:NEW.object_id, :OLD.utc_end_date, :NEW.utc_end_date, :OLD.end_date, :NEW.end_date);
      EcDp_Timestamp_Utils.updateProductionDay(:NEW.object_id, :OLD.utc_end_date, :NEW.utc_end_date, :OLD.end_day, :NEW.end_day);

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
