CREATE OR REPLACE EDITIONABLE TRIGGER "IU_FLOWLINE_SUB_WELL_CONN" 
BEFORE INSERT OR UPDATE ON FLOWLINE_SUB_WELL_CONN
FOR EACH ROW
DECLARE
BEGIN
  -- Common
  IF Inserting THEN
    :new.record_status := nvl(:new.record_status, 'P');
    IF :new.created_by IS NULL THEN
       :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
    END IF;
    IF :new.created_date IS NULL THEN
       :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
    END IF;
    :new.rev_no := 0;
    EcDp_Timestamp_Utils.syncUtcDate(:NEW.object_id, :NEW.utc_daytime, :NEW.daytime);
    EcDp_Timestamp_Utils.setProductionDay(:NEW.object_id, :NEW.utc_daytime, :NEW.production_day);

    EcDp_Timestamp_Utils.syncUtcDate(:NEW.object_id, :NEW.utc_end_date, :NEW.end_date);
    EcDp_Timestamp_Utils.setProductionDay(:NEW.object_id, :NEW.utc_end_date, :NEW.production_day_end);

  ELSE
    EcDp_Timestamp_Utils.updateUtcAndDaytime(:NEW.object_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.daytime, :NEW.daytime);
    EcDp_Timestamp_Utils.updateProductionDay(:NEW.object_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.production_day, :NEW.production_day);

    EcDp_Timestamp_Utils.updateUtcAndDaytime(:NEW.object_id, :OLD.utc_end_date, :NEW.utc_end_date, :OLD.end_date, :NEW.end_date);
    EcDp_Timestamp_Utils.updateProductionDay(:NEW.object_id, :OLD.utc_end_date, :NEW.utc_end_date, :OLD.production_day_end, :NEW.production_day_end);

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
