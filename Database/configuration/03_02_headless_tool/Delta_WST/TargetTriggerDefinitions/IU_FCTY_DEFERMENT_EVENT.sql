CREATE OR REPLACE TRIGGER "IU_FCTY_DEFERMENT_EVENT" 
BEFORE INSERT OR UPDATE ON FCTY_DEFERMENT_EVENT
FOR EACH ROW
BEGIN
    -- $Revision: 1.5 $
    -- Common
    IF Inserting THEN

      IF :NEW.day IS NULL THEN
         :new.day := EcDp_ProductionDay.getProductionDay('FCTY_CLASS_1',:NEW.object_id, :NEW.daytime, :NEW.summer_time);
      END IF;

      IF :new.created_by IS NULL THEN
         :new.created_by := User;
      END IF;

      IF :new.event_no IS NULL THEN
         EcDp_System_Key.assignNextNumber('FCTY_DEFERMENT_EVENT', :new.event_no);
      END IF;

      IF :new.created_date IS NULL THEN
         :new.created_date := EcDp_Date_Time.getCurrentSysdate;
      END IF;

      IF :new.original_def_type IS NULL THEN
         :new.original_def_type := :new.current_def_type;
      END IF;

      :new.rev_no := 0;
      :NEW.record_status := NVL(:NEW.record_status,'P');

    ELSE

      IF Updating and :NEW.daytime <> :OLD.daytime THEN
         :new.day := EcDp_ProductionDay.getProductionDay('FCTY_CLASS_1',:NEW.object_id, :NEW.daytime, :NEW.summer_time);
      END IF;

      IF Nvl(:new.record_status,'P') = Nvl(:old.record_status,'P') THEN

         IF NOT UPDATING('LAST_UPDATED_BY') THEN
            :new.last_updated_by := User;
         END IF;
         IF NOT UPDATING('LAST_UPDATED_DATE') THEN
           :new.last_updated_date := EcDp_Date_Time.getCurrentSysdate;
         END IF;

      END IF;
    END IF;

END;

