CREATE OR REPLACE EDITIONABLE TRIGGER "IU_OBJLOC_SUB_DAY_NOMINATION" 
BEFORE INSERT OR UPDATE ON OBJLOC_SUB_DAY_NOMINATION
FOR EACH ROW
BEGIN
    -- Common
    IF Inserting THEN

      --Generate sequence number for the nomination
      IF :new.NOMINATION_SEQ IS NULL THEN
         EcDp_System_Key.assignNextNumber('OBJLOC_SUB_DAY_NOMINATION', :new.NOMINATION_SEQ);
      END IF;

      EcDp_Timestamp_Utils.syncUtcDate(NULL, :NEW.object_id, :NEW.utc_daytime, :NEW.time_zone, :NEW.daytime, :NEW.summer_time);
      EcDp_Timestamp_Utils.setProductionDay(NULL, :NEW.object_id, :NEW.utc_daytime, :NEW.production_day);

      :new.record_status := nvl(:new.record_status, 'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;
      IF :new.created_date IS NULL THEN
         :new.created_date := EcDp_Timestamp.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;
    ELSE
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
