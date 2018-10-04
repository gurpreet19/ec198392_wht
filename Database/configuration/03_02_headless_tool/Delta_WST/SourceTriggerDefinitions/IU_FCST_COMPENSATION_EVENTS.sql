CREATE OR REPLACE EDITIONABLE TRIGGER "IU_FCST_COMPENSATION_EVENTS" 
BEFORE INSERT OR UPDATE ON FCST_COMPENSATION_EVENTS
FOR EACH ROW
DECLARE
  lv_pday_object_id  VARCHAR2(32);
  ld_prod_offset     DATE;
BEGIN
    -- Basis
    IF Inserting THEN

      lv_pday_object_id := EcDp_ProductionDay.findProductionDayDefinition(NULL, :NEW.object_id, :NEW.daytime);

      :new.record_status := nvl(:new.record_status, 'P');

      EcDp_Timestamp_Utils.syncUtcDate(NULL, :NEW.object_id, :NEW.utc_daytime, :NEW.time_zone, :NEW.daytime, :NEW.summer_time);
      EcDp_Timestamp_Utils.setProductionDay(NULL, :NEW.object_id, :NEW.utc_daytime, :NEW.day);

      IF :NEW.end_day IS NULL AND :NEW.end_date IS NOT NULL THEN
         EcDp_Timestamp_Utils.syncUtcDate(NULL, :NEW.object_id, :NEW.utc_end_date, :NEW.end_time_zone, :NEW.end_date, :NEW.end_summer_time);
         EcDp_Timestamp_Utils.setProductionDay(NULL, :NEW.object_id, :NEW.utc_end_date, :NEW.end_day);
         ld_prod_offset := :NEW.end_day + Ecdp_Productionday.getProductionDayOffset(null, :NEW.object_id, :NEW.end_date, :NEW.end_summer_time) / 24;
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

      IF UPDATING('DAYTIME') OR UPDATING('SUMMER_TIME') THEN
         EcDp_Timestamp_Utils.updateUtcDate(NULL, :NEW.object_id, :NEW.daytime, :NEW.summer_time, :NEW.utc_daytime);
         EcDp_Timestamp_Utils.updateProductionDay(NULL, :NEW.object_id, :NEW.utc_daytime, :NEW.day);
      END IF;

      IF UPDATING('END_DATE') THEN
         IF :NEW.end_date IS NOT NULL THEN
            -- TODO check if utc date is null
            :NEW.utc_end_date := NULL;
            EcDp_Timestamp_Utils.updateUtcDate(NULL, :NEW.object_id, :NEW.end_date, :NEW.end_summer_time, :NEW.utc_end_date);
            EcDp_Timestamp_Utils.updateProductionDay(NULL, :NEW.object_id, :NEW.utc_end_date, :NEW.end_day);
            ld_prod_offset := :NEW.end_day + Ecdp_Productionday.getProductionDayOffset(null, :NEW.object_id, :NEW.end_date, :NEW.end_summer_time) / 24;
            IF :NEW.end_date = ld_prod_offset THEN
               :NEW.end_day := :NEW.end_day - 1;
            END IF;
         ELSE
            :NEW.end_day := NULL;
            :NEW.utc_end_date := NULL;
            :NEW.end_time_zone := NULL;
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
