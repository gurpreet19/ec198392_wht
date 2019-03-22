CREATE OR REPLACE EDITIONABLE TRIGGER "IU_WELL_EVENT" 
BEFORE INSERT OR UPDATE ON well_event
FOR EACH ROW
BEGIN
    -- $Revision: 1.5 $
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
      EcDp_Timestamp_Utils.setProductionDay(:NEW.object_id, :NEW.utc_daytime, :NEW.event_day);

    --setting rate_source for selected classes
      If :new.avg_inj_rate IS NOT NULL AND :new.event_type = 'IWEL_EVENT_GAS' THEN
       :new.rate_source := 'MANUAL';
    END IF;

    If :new.avg_inj_rate IS NOT NULL AND :new.event_type = 'IWEL_EVENT_STEAM' THEN
       :new.rate_source := 'MANUAL';
    END IF;

    If :new.avg_inj_rate IS NOT NULL AND :new.event_type = 'IWEL_EVENT_WATER' THEN
       :new.rate_source := 'MANUAL';
    END IF;



    ELSE
      IF UPDATING THEN
         EcDp_Timestamp_Utils.updateUtcAndDaytime(:NEW.object_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.daytime, :NEW.daytime, :OLD.summer_time, :NEW.summer_time);
         EcDp_Timestamp_Utils.updateProductionDay(:NEW.object_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.event_day, :NEW.event_day);
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
