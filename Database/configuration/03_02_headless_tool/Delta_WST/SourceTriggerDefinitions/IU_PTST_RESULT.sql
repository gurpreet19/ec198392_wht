CREATE OR REPLACE EDITIONABLE TRIGGER "IU_PTST_RESULT" 
BEFORE INSERT OR UPDATE ON ptst_result
FOR EACH ROW
BEGIN
    -- $Revision: 1.5 $
    -- Common
    IF Inserting THEN

      -- TODO object_id should be test_device from ecdp_performance_test.getTestDeviceIDFromResult
      EcDp_Timestamp_Utils.syncUtcDate(NULL, :NEW.utc_daytime, :NEW.daytime);
      EcDp_Timestamp_Utils.setProductionDay(NULL, :NEW.utc_daytime, :NEW.production_day);

      EcDp_Timestamp_Utils.syncUtcDate(NULL, :NEW.utc_end_date, :NEW.end_date);
      EcDp_Timestamp_Utils.setProductionDay(NULL, :NEW.utc_end_date, :NEW.end_day);

      EcDp_Timestamp_Utils.syncUtcDate(NULL, :NEW.valid_from_utc_date, :NEW.valid_from_date);
      EcDp_Timestamp_Utils.setProductionDay(NULL, :NEW.valid_from_utc_date, :NEW.valid_from_day);

      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;

      IF :new.result_no IS NULL THEN

         EcDp_System_Key.assignNextNumber('PTST_RESULT', :new.result_no);

      END IF;

      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;

      :new.rev_no := 0;
      :NEW.record_status := NVL(:NEW.record_status,'P');

    ELSE
      EcDp_Timestamp_Utils.updateUtcAndDaytime(NULL, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.daytime, :NEW.daytime);
      EcDp_Timestamp_Utils.updateProductionDay(NULL, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.production_day, :NEW.production_day);

      EcDp_Timestamp_Utils.updateUtcAndDaytime(NULL, :OLD.utc_end_date, :NEW.utc_end_date, :OLD.end_date, :NEW.end_date);
      EcDp_Timestamp_Utils.updateProductionDay(NULL, :OLD.utc_end_date, :NEW.utc_end_date, :OLD.end_day, :NEW.end_day);

      EcDp_Timestamp_Utils.updateUtcAndDaytime(NULL, :OLD.valid_from_utc_date, :NEW.valid_from_utc_date, :OLD.valid_from_date, :NEW.valid_from_date);
      EcDp_Timestamp_Utils.updateProductionDay(NULL, :OLD.valid_from_utc_date, :NEW.valid_from_utc_date, :OLD.valid_from_day, :NEW.valid_from_day);

      IF Nvl(:new.record_status,'P') = Nvl(:old.record_status,'P') THEN

         IF NOT UPDATING('LAST_UPDATED_BY') THEN
            :new.last_updated_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
         END IF;
         IF NOT UPDATING('LAST_UPDATED_DATE') THEN
           :new.last_updated_date := Ecdp_Timestamp.getCurrentSysdate;
         END IF;

      END IF;
    END IF;

    IF :NEW.USE_CALC = 'Y' AND :NEW.STATUS = 'ACCEPTED' THEN
      :NEW.ACCEPTED_DATE := Ecdp_Timestamp.getCurrentSysdate;
    ELSE
      :NEW.ACCEPTED_DATE := NULL;
    END IF;

END;
