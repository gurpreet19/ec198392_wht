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

      EcDp_Timestamp_Utils.syncUtcDate('STREAM', :NEW.object_id, :NEW.utc_daytime, :NEW.time_zone, :NEW.daytime, :NEW.daytime_summer_time);
      EcDp_Timestamp_Utils.syncUtcDate('STREAM', :NEW.object_id, :NEW.valid_from_utc_date, :NEW.valid_from_time_zone, :NEW.valid_from_date, :NEW.valid_from_summer_time);
      EcDp_Timestamp_Utils.syncUtcDate('STREAM', :NEW.object_id, :NEW.valid_to_utc_date, :NEW.valid_to_time_zone, :NEW.valid_to_date, :NEW.valid_to_summer_time);
      EcDp_Timestamp_Utils.setProductionDay('STREAM', :NEW.object_id, :NEW.utc_daytime, :NEW.production_day);

      IF :new.analysis_no IS NULL THEN

         EcDp_System_Key.assignNextNumber('STRM_ANALYSIS_EVENT', :new.analysis_no);

      END IF;

      IF :NEW.production_day IS NULL THEN
         :new.production_day := EcDp_ProductionDay.getProductionDay(NULL,:NEW.object_id, :NEW.daytime);
      END IF;

      IF :NEW.valid_from_date IS NULL THEN
         :NEW.valid_from_date := :NEW.production_day;
      END IF;

      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;
    ELSE

    IF :NEW.daytime <> :OLD.daytime THEN
      EcDp_Timestamp_Utils.updateUtcDate('STREAM', :NEW.object_id, :NEW.daytime, :NEW.daytime_summer_time, :NEW.utc_daytime);
      EcDp_Timestamp_Utils.updateProductionDay('STREAM', :NEW.object_id, :NEW.utc_daytime, :NEW.production_day);
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
