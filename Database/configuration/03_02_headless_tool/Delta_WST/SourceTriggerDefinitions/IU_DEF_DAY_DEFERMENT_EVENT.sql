CREATE OR REPLACE EDITIONABLE TRIGGER "IU_DEF_DAY_DEFERMENT_EVENT" 
BEFORE INSERT OR UPDATE ON DEF_DAY_DEFERMENT_EVENT
FOR EACH ROW
DECLARE
  lv_summary_event_count NUMBER:=0;
BEGIN
     -- $Revision: 1.4 $
    -- Common
    IF Inserting THEN
      :NEW.record_status := NVL(:NEW.record_status,'P');
      :new.status := 'Provisional';


      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;

      IF :NEW.deferment_event_no IS NULL THEN
          EcDp_System_Key.assignNextNumber('DEF_DAY_DEFERMENT_EVENT', :new.deferment_event_no);
      END IF;

      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;

      EcDp_Timestamp_Utils.syncUtcDate(:NEW.defer_level_object_id, :NEW.utc_daytime, :NEW.daytime);
      EcDp_Timestamp_Utils.syncUtcDate(:NEW.defer_level_object_id, :NEW.utc_end_date, :NEW.end_date);
      EcDp_Timestamp_Utils.setProductionDay(:NEW.defer_level_object_id, :NEW.utc_daytime, :NEW.day);
      EcDp_Timestamp_Utils.setProductionDay(:NEW.defer_level_object_id, :NEW.utc_end_date, :NEW.end_day);

    ELSE

      EcDp_Timestamp_Utils.updateUtcAndDaytime(:NEW.defer_level_object_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.daytime, :NEW.daytime);
      EcDp_Timestamp_Utils.updateProductionDay(:NEW.defer_level_object_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.day, :NEW.day);

      EcDp_Timestamp_Utils.updateUtcAndDaytime(:NEW.defer_level_object_id, :OLD.utc_end_date, :NEW.utc_end_date, :OLD.end_date, :NEW.end_date);
      EcDp_Timestamp_Utils.updateProductionDay(:NEW.defer_level_object_id, :OLD.utc_end_date, :NEW.utc_end_date, :OLD.end_day, :NEW.end_day);

	  IF :NEW.delete_newer_child='Y' AND :NEW.end_date IS NOT NULL THEN
	    UPDATE def_day_summary_event
		SET REV_TEXT='automatically deleted from Deferment Master BF.'
		WHERE deferment_event_no = :new.deferment_event_no
		AND daytime > :NEW.end_date;

		DELETE FROM  def_day_summary_event
		WHERE deferment_event_no = :new.deferment_event_no
		AND daytime > :NEW.end_date;

	  ELSIF (:NEW.delete_newer_child='N' OR :NEW.delete_newer_child IS NULL) AND :NEW.end_date IS NOT NULL THEN
		SELECT COUNT(*)
		INTO lv_summary_event_count
		FROM def_day_summary_event
		WHERE deferment_event_no = :new.deferment_event_no
		AND daytime > :NEW.end_date;

		IF lv_summary_event_count <> 0 THEN
			RAISE_APPLICATION_ERROR(-20609, 'Please check Del children checkbox first.');
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
