CREATE OR REPLACE EDITIONABLE TRIGGER "IU_STRM_EVENT" 
BEFORE INSERT OR UPDATE ON strm_event
FOR EACH ROW

BEGIN
    -- $Revision: 1.7 $
    -- Common
    -- TODO original code has a check : :new.event_type <> 'TANK_DUAL_DIP' before setting the event_day
    -- removing that check will reduce this trigger to basic
    IF Inserting THEN
      :NEW.record_status := NVL(:NEW.record_status,'P');
      EcDp_Timestamp_Utils.syncUtcDate(:NEW.object_id, :NEW.utc_daytime, :NEW.daytime);
      EcDp_Timestamp_Utils.setProductionDay(:NEW.object_id, :NEW.utc_daytime, :NEW.event_day);

      EcDp_Timestamp_Utils.syncUtcDate(:NEW.object_id, :NEW.utc_end_date, :NEW.end_date);
      EcDp_Timestamp_Utils.setProductionDay(:NEW.object_id, :NEW.utc_end_date, :NEW.end_day);

      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;

      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;

    ELSE
      EcDp_Timestamp_Utils.updateUtcAndDaytime(:NEW.object_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.daytime, :NEW.daytime);
      EcDp_Timestamp_Utils.updateProductionDay(:NEW.object_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.event_day, :NEW.event_day);

      EcDp_Timestamp_Utils.updateUtcAndDaytime(:NEW.object_id, :OLD.utc_end_date, :NEW.utc_end_date, :OLD.end_date, :NEW.end_date);
      EcDp_Timestamp_Utils.updateProductionDay(:NEW.object_id, :OLD.utc_end_date, :NEW.utc_end_date, :OLD.end_day, :NEW.end_day);

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
