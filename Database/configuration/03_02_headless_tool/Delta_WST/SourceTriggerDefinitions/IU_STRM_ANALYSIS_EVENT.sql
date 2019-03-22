CREATE OR REPLACE EDITIONABLE TRIGGER "IU_STRM_ANALYSIS_EVENT" 
BEFORE INSERT OR UPDATE ON strm_analysis_event
FOR EACH ROW
BEGIN
    -- $Revision: 1.5 $
    -- Common
    IF Inserting THEN

      :NEW.record_status := NVL(:NEW.record_status,'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;

      EcDp_Timestamp_Utils.syncUtcDate(:NEW.object_id, :NEW.utc_daytime, :NEW.daytime, :NEW.daytime_summer_time);
      EcDp_Timestamp_Utils.setProductionDay(:NEW.object_id, :NEW.utc_daytime, :NEW.production_day);

      IF :new.analysis_no IS NULL THEN

         EcDp_System_Key.assignNextNumber('STRM_ANALYSIS_EVENT', :new.analysis_no);

      END IF;

      IF :NEW.valid_from_date IS NULL THEN
         :NEW.valid_from_date := :NEW.production_day;
      END IF;

      EcDp_Timestamp_Utils.syncUtcDate(:NEW.object_id, :NEW.valid_from_utc_date, :NEW.valid_from_date, :NEW.valid_from_summer_time);
      EcDp_Timestamp_Utils.syncUtcDate(:NEW.object_id, :NEW.valid_to_utc_date, :NEW.valid_to_date, :NEW.valid_to_summer_time);

      EcDp_Timestamp_Utils.setProductionDay(:NEW.object_id, :NEW.valid_from_utc_date, :NEW.valid_from_day);
      EcDp_Timestamp_Utils.setProductionDay(:NEW.object_id, :NEW.valid_to_utc_date, :NEW.valid_to_day);

      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;
    ELSE
      EcDp_Timestamp_Utils.updateUtcAndDaytime(:NEW.object_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.daytime, :NEW.daytime, :OLD.daytime_summer_time, :NEW.daytime_summer_time);
      EcDp_Timestamp_Utils.updateProductionDay(:NEW.object_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.production_day, :NEW.production_day);

      EcDp_Timestamp_Utils.updateUtcAndDaytime(:NEW.object_id, :OLD.valid_from_utc_date, :NEW.valid_from_utc_date, :OLD.valid_from_date, :NEW.valid_from_date, :OLD.valid_from_summer_time, :NEW.valid_from_summer_time);
      EcDp_Timestamp_Utils.updateProductionDay(:NEW.object_id, :OLD.valid_from_utc_date, :NEW.valid_from_utc_date, :OLD.valid_from_day, :NEW.valid_from_day);

      EcDp_Timestamp_Utils.updateUtcAndDaytime(:NEW.object_id, :OLD.valid_to_utc_date, :NEW.valid_to_utc_date, :OLD.valid_to_date, :NEW.valid_to_date, :OLD.valid_to_summer_time, :NEW.valid_to_summer_time);
      EcDp_Timestamp_Utils.updateProductionDay(:NEW.object_id, :OLD.valid_to_utc_date, :NEW.valid_to_utc_date, :OLD.valid_to_day, :NEW.valid_to_day);

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
