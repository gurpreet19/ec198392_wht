CREATE OR REPLACE EDITIONABLE TRIGGER "IU_TANK_ANALYSIS" 
BEFORE INSERT OR UPDATE ON TANK_ANALYSIS
FOR EACH ROW
BEGIN
    -- Basis
    IF Inserting THEN
      :new.record_status := nvl(:new.record_status, 'P');

	  IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;

      IF :new.analysis_no IS NULL THEN
         EcDp_System_Key.assignNextNumber('TANK_ANALYSIS', :new.analysis_no);
      END IF;

	  IF :NEW.object_class_name IS NULL THEN
        :NEW.object_class_name := Ecdp_Objects.GetObjClassName(:NEW.object_id);
	  END IF;

      EcDp_Timestamp_Utils.syncUtcDate(:NEW.object_id, :NEW.utc_daytime, :NEW.daytime);
      EcDp_Timestamp_Utils.setProductionDay(:NEW.object_id, :NEW.utc_daytime, :NEW.production_day);

	  IF :NEW.valid_from_date IS NULL THEN
        :NEW.valid_from_date := :NEW.production_day;
      END IF;

      IF :new.created_by IS NULL THEN
        :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;

      IF :new.created_date IS NULL THEN
        :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;

      :new.rev_no := 0;
    ELSE

      EcDp_Timestamp_Utils.updateUtcAndDaytime(:NEW.object_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.daytime, :NEW.daytime);
      EcDp_Timestamp_Utils.updateProductionDay(:NEW.object_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.production_day, :NEW.production_day);

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
