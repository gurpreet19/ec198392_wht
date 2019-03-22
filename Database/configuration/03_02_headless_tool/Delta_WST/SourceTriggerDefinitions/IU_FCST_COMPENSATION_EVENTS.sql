CREATE OR REPLACE EDITIONABLE TRIGGER "IU_FCST_COMPENSATION_EVENTS" 
BEFORE INSERT OR UPDATE ON FCST_COMPENSATION_EVENTS
FOR EACH ROW
DECLARE
  ld_prod_offset     DATE;
BEGIN
    -- Common
    IF Inserting THEN

      :new.record_status := nvl(:new.record_status, 'P');

      EcDp_Timestamp_Utils.syncUtcDate(:NEW.object_id, :NEW.utc_daytime, :NEW.daytime, :NEW.summer_time);
      EcDp_Timestamp_Utils.setProductionDay(:NEW.object_id, :NEW.utc_daytime, :NEW.day);

      EcDp_Timestamp_Utils.syncUtcDate(:NEW.object_id, :NEW.utc_end_date, :NEW.end_date, :NEW.end_summer_time);
      EcDp_Timestamp_Utils.setProductionDay(:NEW.object_id, :NEW.utc_end_date, :NEW.end_day);

      IF :NEW.end_day IS NULL AND :NEW.end_date IS NOT NULL THEN
         ld_prod_offset := :NEW.end_day + Ecdp_Productionday.getProductionDayOffset(null, :NEW.object_id, :NEW.end_date) / 24;
         IF :NEW.end_date = ld_prod_offset THEN
            :NEW.end_day := :NEW.end_day - 1;
         END IF;
      END IF;

      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;

      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;
    ELSE

      EcDp_Timestamp_Utils.updateUtcAndDaytime(:NEW.object_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.daytime, :NEW.daytime, :OLD.summer_time, :NEW.summer_time);
      EcDp_Timestamp_Utils.updateProductionDay(:NEW.object_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.day, :NEW.day);

      EcDp_Timestamp_Utils.updateUtcAndDaytime(:NEW.object_id, :OLD.utc_end_date, :NEW.utc_end_date, :OLD.end_date, :NEW.end_date, :OLD.end_summer_time, :NEW.end_summer_time);
      EcDp_Timestamp_Utils.updateProductionDay(:NEW.object_id, :OLD.utc_end_date, :NEW.utc_end_date, :OLD.end_day, :NEW.end_day);

      IF UPDATING('END_DATE') THEN
         IF :NEW.end_date IS NOT NULL THEN
            -- TODO check if utc date is null
            ld_prod_offset := :NEW.end_day + Ecdp_Productionday.getProductionDayOffset(null, :NEW.object_id, :NEW.end_date) / 24;
            IF :NEW.end_date = ld_prod_offset THEN
               :NEW.end_day := :NEW.end_day - 1;
            END IF;
         ELSE
            :NEW.end_day := NULL;
            :NEW.utc_end_date := NULL;
         END IF;
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
