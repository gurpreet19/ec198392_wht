CREATE OR REPLACE EDITIONABLE TRIGGER "IU_SUMMARY_SETUP_LIST" 
BEFORE INSERT OR UPDATE ON SUMMARY_SETUP_LIST
FOR EACH ROW
BEGIN
    -- Basis
    IF Inserting THEN

      :new.record_status := nvl(:new.record_status, 'P');
      :NEW.LIST_ITEM_KEY := 'LK:' || ecdp_system_key.assignNextNumber('SUMMARY_SETUP_LIST');

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
