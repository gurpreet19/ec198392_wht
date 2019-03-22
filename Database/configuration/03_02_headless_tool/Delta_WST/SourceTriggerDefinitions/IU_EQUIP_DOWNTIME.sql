CREATE OR REPLACE EDITIONABLE TRIGGER "IU_EQUIP_DOWNTIME" 
BEFORE INSERT OR UPDATE ON EQUIP_DOWNTIME
FOR EACH ROW
DECLARE
    ld_prod_offset     DATE;
BEGIN
    -- Common
    IF Inserting THEN

      EcDp_Timestamp_Utils.syncUtcDate(:NEW.object_id, :NEW.utc_daytime, :NEW.daytime);
      EcDp_Timestamp_Utils.setProductionDay(:NEW.object_id, :NEW.utc_daytime, :NEW.day);

      EcDp_Timestamp_Utils.syncUtcDate(:NEW.object_id, :NEW.utc_end_date, :NEW.end_date);
      EcDp_Timestamp_Utils.setProductionDay(:NEW.object_id, :NEW.utc_end_date, :NEW.end_day);


      IF :NEW.end_day IS NULL AND :NEW.end_date IS NOT NULL THEN

         ld_prod_offset := :NEW.end_day + Ecdp_Productionday.getProductionDayOffset(null, :NEW.object_id, :NEW.utc_end_date) / 24;
         IF :NEW.end_date = ld_prod_offset THEN
            :NEW.end_day := :NEW.end_day - 1;
         END IF;
      END IF;

      :NEW.record_status := NVL(:NEW.record_status, 'P');
      IF :NEW.event_no IS NULL THEN
         EcDp_System_Key.assignNextNumber('EQUIP_DOWNTIME', :NEW.event_no);
      END IF;
      IF :NEW.created_by IS NULL THEN
         :NEW.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;
      IF :NEW.created_date IS NULL THEN
         :NEW.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;
      :NEW.rev_no := 0;

    ELSE

      EcDp_Timestamp_Utils.updateUtcAndDaytime(:NEW.object_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.daytime, :NEW.daytime);
      EcDp_Timestamp_Utils.updateProductionDay(:NEW.object_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.day, :NEW.day);

      EcDp_Timestamp_Utils.updateUtcAndDaytime(:NEW.object_id, :OLD.utc_end_date, :NEW.utc_end_date, :OLD.end_date, :NEW.end_date);
      EcDp_Timestamp_Utils.updateProductionDay(:NEW.object_id, :OLD.utc_end_date, :NEW.utc_end_date, :OLD.end_day, :NEW.end_day);

      IF UPDATING('END_DATE') THEN
         IF :NEW.end_date IS NOT NULL THEN
            ld_prod_offset := :NEW.end_day + Ecdp_Productionday.getProductionDayOffset(null, :NEW.object_id, :NEW.utc_end_date) / 24;
            IF :NEW.end_date = ld_prod_offset THEN
               :NEW.end_day := :NEW.end_day - 1;
            END IF;
         ELSE
            :NEW.end_day := null;
            :NEW.utc_end_date := NULL;
         END IF;
      END IF;

      IF NVL(:NEW.record_status,'P') = NVL(:OLD.record_status,'P') THEN
         IF NOT UPDATING('LAST_UPDATED_BY') THEN
            :NEW.last_updated_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
         END IF;
         IF NOT UPDATING('LAST_UPDATED_DATE') THEN
           :NEW.last_updated_date := Ecdp_Timestamp.getCurrentSysdate;
         END IF;
      END IF;
    END IF;
END;
