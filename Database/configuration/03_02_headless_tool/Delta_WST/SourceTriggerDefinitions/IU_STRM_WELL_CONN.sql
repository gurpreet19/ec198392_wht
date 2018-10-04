CREATE OR REPLACE EDITIONABLE TRIGGER "IU_STRM_WELL_CONN" 
BEFORE INSERT OR UPDATE ON STRM_WELL_CONN
FOR EACH ROW

BEGIN
  -- Common
  IF Inserting THEN

    :new.record_status := 'P';
    IF :new.created_by IS NULL THEN
       :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
    END IF;
    IF :new.created_date IS NULL THEN
       :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
    END IF;
    :new.rev_no := 0;

    EcDp_Timestamp_Utils.syncUtcDate('STREAM', :NEW.object_id, :NEW.utc_daytime, :NEW.time_zone, :NEW.daytime, :NEW.summertime_daytime);
    EcDp_Timestamp_Utils.setProductionDay('STREAM', :NEW.object_id, :NEW.utc_daytime, :NEW.production_day);

    IF (:new.END_DATE IS NOT NULL AND :new.SUMMERTIME_END_DATE IS NULL) THEN
      EcDp_Timestamp_Utils.syncUtcDate('STREAM', :NEW.object_id, :NEW.utc_end_date, :NEW.end_time_zone, :NEW.end_date, :NEW.summertime_end_date);
      EcDp_Timestamp_Utils.setProductionDay('STREAM', :NEW.object_id, :NEW.utc_end_date, :NEW.production_day_end);

    END IF;

  ELSE

    IF (:new.END_DATE <> :old.END_DATE OR
       (:new.end_date IS NOT NULL and :old.END_DATE IS NULL) OR
        :new.SUMMERTIME_END_DATE IS NULL OR
        :new.SUMMERTIME_DAYTIME IS NULL) THEN

      IF :new.SUMMERTIME_END_DATE IS NULL and :new.END_DATE IS NOT NULL THEN
        EcDp_Timestamp_Utils.updateUtcDate('STREAM', :NEW.object_id, :NEW.end_date, :NEW.summertime_end_date, :NEW.utc_end_date);
        EcDp_Timestamp_Utils.updateProductionDay('STREAM', :NEW.object_id, :NEW.utc_end_date, :NEW.production_day_end);
      END IF;
    END IF;

    IF :new.END_DATE IS NULL THEN
      :new.SUMMERTIME_END_DATE := NULL;
      :new.PRODUCTION_DAY_END  := NULL;
      :NEW.utc_end_date := NULL;
      :NEW.end_time_zone := NULL;
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
