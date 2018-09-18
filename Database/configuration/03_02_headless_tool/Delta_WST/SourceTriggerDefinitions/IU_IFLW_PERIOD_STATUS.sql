CREATE OR REPLACE EDITIONABLE TRIGGER "IU_IFLW_PERIOD_STATUS" 
BEFORE INSERT OR UPDATE ON IFLW_PERIOD_STATUS
FOR EACH ROW

BEGIN
    -- Basis
    IF Inserting THEN

      EcDp_Timestamp_Utils.syncUtcDate('FLOWLINE', :NEW.object_id, :NEW.utc_daytime, :NEW.time_zone, :NEW.daytime, :NEW.summer_time);
      EcDp_Timestamp_Utils.setProductionDay('FLOWLINE', :NEW.object_id, :NEW.utc_daytime, :NEW.day);

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
