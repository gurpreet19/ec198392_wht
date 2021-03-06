CREATE OR REPLACE EDITIONABLE TRIGGER "IU_TANK_MEASUREMENT" 
BEFORE INSERT OR UPDATE ON tank_measurement
FOR EACH ROW

BEGIN
   -- $Revision: 1.16 $
   -- Common
   IF Inserting THEN
      :NEW.record_status := NVL(:NEW.record_status,'P');
      EcDp_Timestamp_Utils.syncUtcDate(:NEW.object_id, :NEW.utc_daytime, :NEW.daytime);

      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;

      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;

      :new.rev_no := 0;

      IF :new.measurement_event_type IS NULL THEN

         :new.measurement_event_type := 'DAY_CLOSING';

      END IF;

      IF :new.event_day IS NULL AND :new.measurement_event_type IN ('DUAL_DIP_OPENING','DUAL_DIP_CLOSING','EVENT_CLOSING') THEN

           EcDp_Timestamp_Utils.setProductionDay(:NEW.object_id, :NEW.utc_daytime, :NEW.event_day);

     ELSIF :new.event_day IS NULL THEN

           :NEW.EVENT_DAY := TRUNC(:NEW.daytime);

     END IF;

    ELSE
      EcDp_Timestamp_Utils.updateUtcAndDaytime(:NEW.object_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.daytime, :NEW.daytime);
      EcDp_Timestamp_Utils.updateProductionDay(:NEW.object_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.event_day, :NEW.event_day);

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
