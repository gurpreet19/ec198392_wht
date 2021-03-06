CREATE OR REPLACE EDITIONABLE TRIGGER "IU_BPM_EC_EVENT_INBOUND" 
BEFORE INSERT OR UPDATE ON BPM_EC_EVENT_INBOUND
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

      IF :new.ID IS NULL THEN
         EcDp_System_Key.assignNextNumber('BPM_EC_EVENT_INBOUND', :new.ID);
      END IF;

      IF :new.Time IS NULL THEN
         :new.Time := Ecdp_Timestamp.getCurrentSysdate;
      END IF;

      :new.State := 0;

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
