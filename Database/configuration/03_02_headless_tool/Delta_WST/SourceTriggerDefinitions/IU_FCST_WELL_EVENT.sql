CREATE OR REPLACE EDITIONABLE TRIGGER "IU_FCST_WELL_EVENT" 
BEFORE INSERT OR UPDATE ON FCST_WELL_EVENT
FOR EACH ROW
DECLARE
  ld_prod_offset     DATE;
BEGIN
    -- Common
    IF Inserting THEN

      :new.record_status := nvl(:new.record_status, 'P');

      EcDp_Timestamp_Utils.syncUtcDate(:NEW.event_id, :NEW.utc_daytime, :NEW.daytime, :NEW.summer_time);
      EcDp_Timestamp_Utils.setProductionDay(:NEW.event_id, :NEW.utc_daytime, :NEW.day);

      IF :NEW.end_day IS NULL AND :NEW.end_date IS NOT NULL THEN
        EcDp_Timestamp_Utils.syncUtcDate(:NEW.event_id, :NEW.utc_end_date, :NEW.end_date, :NEW.end_summer_time);
        EcDp_Timestamp_Utils.setProductionDay(:NEW.event_id, :NEW.utc_end_date, :NEW.end_day);
        ld_prod_offset := :NEW.end_day + Ecdp_Productionday.getProductionDayOffset(null, :NEW.event_id, :NEW.utc_end_date) / 24;
        IF :NEW.end_date = ld_prod_offset THEN
           :NEW.end_day := :NEW.end_day - 1;
        END IF;
      END IF;

       --new event_no will be assigned to FCST_WELL_EVENT
      IF :new.event_no IS NULL THEN
         EcDp_System_Key.assignNextNumber('FCST_WELL_EVENT', :new.event_no);
      END IF;

      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;

      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;
    ELSE

      EcDp_Timestamp_Utils.updateUtcAndDaytime(:NEW.event_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.daytime, :NEW.daytime, :OLD.summer_time, :NEW.summer_time);
      EcDp_Timestamp_Utils.updateProductionDay(:NEW.event_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.day, :NEW.day);


      IF UPDATING('END_DATE') THEN
         IF :NEW.end_date IS NOT NULL THEN
            -- TODO check if utc date is null
            EcDp_Timestamp_Utils.updateUtcAndDaytime(:NEW.event_id, :OLD.utc_end_date, :NEW.utc_end_date, :OLD.end_date, :NEW.end_date, :OLD.end_summer_time, :NEW.end_summer_time);
            EcDp_Timestamp_Utils.updateProductionDay(:NEW.event_id, :OLD.utc_end_date, :NEW.utc_end_date, :OLD.end_day, :NEW.end_day);
            ld_prod_offset := :NEW.end_day + Ecdp_Productionday.getProductionDayOffset(null, :NEW.event_id, :NEW.utc_end_date) / 24;
            IF :NEW.end_date = ld_prod_offset THEN
               :NEW.end_day := :NEW.end_day - 1;
            END IF;
         ELSE
            :NEW.end_day := NULL;
            :NEW.utc_end_date := NULL;
         END IF;
      END IF;

      IF ecdp_objects.GetObjClassName(:NEW.EVENT_ID) = 'WELL' THEN
        IF UPDATING('DAYTIME') AND :new.DAYTIME > NVL(:old.DAYTIME, :new.DAYTIME + 1) THEN
          DELETE FCST_WELL_EVENT_ALLOC T WHERE T.EVENT_NO=:new.EVENT_NO and t.object_id = :new.EVENT_ID
                  and DAYTIME < :new.DAY;
        END IF;

        IF UPDATING('END_DATE') AND :new.END_DATE < NVL(:old.END_DATE, :new.END_DATE + 1) THEN
          DELETE FCST_WELL_EVENT_ALLOC T WHERE T.EVENT_NO=:new.EVENT_NO and t.object_id = :new.EVENT_ID
                and DAYTIME >= :new.END_DAY;
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
