CREATE OR REPLACE EDITIONABLE TRIGGER "IU_SPLIT_KEY_SETUP" 
BEFORE INSERT OR UPDATE ON SPLIT_KEY_SETUP
FOR EACH ROW
BEGIN
    -- Basis
    IF Inserting THEN
      :new.record_status := nvl(:new.record_status, 'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;
      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;
      IF :new.daytime >= nvl(ec_split_key.end_date(:new.object_id),:new.daytime+1) THEN
         Raise_Application_Error(-20000,'Daytime not valid for this split key (' || ec_split_key.object_code(:new.object_id)||') having end date equal to '||ec_split_key.end_date(:new.object_id));
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
