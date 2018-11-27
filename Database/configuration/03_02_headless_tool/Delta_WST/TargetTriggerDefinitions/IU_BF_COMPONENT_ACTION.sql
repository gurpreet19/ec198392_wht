CREATE OR REPLACE TRIGGER "IU_BF_COMPONENT_ACTION" 
BEFORE INSERT OR UPDATE ON BF_COMPONENT_ACTION
FOR EACH ROW
BEGIN
    -- $Revision: 1.2 $
    -- Common
    IF Inserting THEN

      IF :NEW.BF_COMPONENT_ACTION_NO IS NULL THEN

          EcDp_System_Key.assignNextNumber('BF_COMPONENT_ACTION', :new.BF_COMPONENT_ACTION_NO);

      END IF;


      :new.record_status := 'P';
      IF :new.created_by IS NULL THEN
         :new.created_by := User;
      END IF;
      IF :new.created_date IS NULL THEN
         :new.created_date := EcDp_Date_Time.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;
    ELSE
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

