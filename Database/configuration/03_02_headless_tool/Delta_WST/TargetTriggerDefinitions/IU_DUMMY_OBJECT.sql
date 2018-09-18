CREATE OR REPLACE TRIGGER "IU_DUMMY_OBJECT" 
BEFORE INSERT OR UPDATE ON DUMMY_OBJECT
FOR EACH ROW
BEGIN
    -- $Revision: 1.1.2.1 $
    -- Common
    IF Inserting THEN
      IF :new.dummy_type IS NULL THEN
         :new.dummy_type := 'DUMMY_TAG_EVENT';
      END IF;
      :new.record_status := nvl(:new.record_status, 'P');
      IF :new.object_id IS NULL THEN
         :new.object_id := SYS_GUID();
      END IF;
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

