CREATE OR REPLACE EDITIONABLE TRIGGER "IU_ITST_RESULT" 
BEFORE INSERT OR UPDATE ON ITST_RESULT
FOR EACH ROW
BEGIN
    -- Common
    IF Inserting THEN

      EcDp_Timestamp_Utils.syncUtcDate(NVL(:NEW.facility_id,:NEW.collection_point_id), :NEW.utc_daytime, :NEW.daytime);
      :NEW.production_day := EcDp_Timestamp.getProductionDayFromLocal(NVL(:NEW.facility_id,:NEW.collection_point_id), :NEW.daytime);

      EcDp_Timestamp_Utils.syncUtcDate(NVL(:NEW.facility_id,:NEW.collection_point_id), :NEW.utc_end_date, :NEW.end_date);
      :NEW.end_day := EcDp_Timestamp.getProductionDayFromLocal(NVL(:NEW.facility_id,:NEW.collection_point_id), :NEW.end_date);

      EcDp_Timestamp_Utils.syncUtcDate(NVL(:NEW.facility_id,:NEW.collection_point_id), :NEW.valid_from_utc_date, :NEW.valid_from_date);
      :NEW.valid_from_day := EcDp_Timestamp.getProductionDayFromLocal(NVL(:NEW.facility_id,:NEW.collection_point_id), :NEW.valid_from_date);

      :new.record_status := nvl(:new.record_status, 'P');
      IF :new.created_by IS NULL THEN
        :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;
      IF :new.result_no IS NULL THEN

        EcDp_System_Key.assignNextNumber('ITST_RESULT', :new.result_no);

      END IF;
      IF :new.created_date IS NULL THEN
        :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;
    ELSE

      EcDp_Timestamp_Utils.updateUtcAndDaytime(NVL(:NEW.facility_id,:NEW.collection_point_id), :OLD.utc_daytime, :NEW.utc_daytime, :OLD.daytime, :NEW.daytime);
      :NEW.production_day := EcDp_Timestamp.getProductionDayFromLocal(NVL(:NEW.facility_id,:NEW.collection_point_id), :NEW.daytime);

      EcDp_Timestamp_Utils.updateUtcAndDaytime(NVL(:NEW.facility_id,:NEW.collection_point_id), :OLD.utc_end_date, :NEW.utc_end_date, :OLD.end_date, :NEW.end_date);
      :NEW.end_day := EcDp_Timestamp.getProductionDayFromLocal(NVL(:NEW.facility_id,:NEW.collection_point_id), :NEW.end_date);

      EcDp_Timestamp_Utils.updateUtcAndDaytime(NVL(:NEW.facility_id,:NEW.collection_point_id), :OLD.valid_from_utc_date, :NEW.valid_from_utc_date, :OLD.valid_from_date, :NEW.valid_from_date);
      :NEW.valid_from_day := EcDp_Timestamp.getProductionDayFromLocal(NVL(:NEW.facility_id,:NEW.collection_point_id), :NEW.valid_from_date);

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
