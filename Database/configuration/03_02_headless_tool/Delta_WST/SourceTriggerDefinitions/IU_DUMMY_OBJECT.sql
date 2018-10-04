CREATE OR REPLACE EDITIONABLE TRIGGER "IU_DUMMY_OBJECT" 
BEFORE INSERT OR UPDATE ON DUMMY_OBJECT
FOR EACH ROW
BEGIN
    -- $Revision: 1.2 $
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
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;
      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;
    ELSE
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
