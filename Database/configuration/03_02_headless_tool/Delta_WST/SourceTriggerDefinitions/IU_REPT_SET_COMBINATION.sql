CREATE OR REPLACE EDITIONABLE TRIGGER "IU_REPT_SET_COMBINATION" 
BEFORE INSERT OR UPDATE ON REPT_SET_COMBINATION
FOR EACH ROW
BEGIN
    -- Custom
    IF Inserting THEN
      IF :new.seq_no IS NULL THEN
         EcDp_System_Key.assignNextNumber('REPT_SET_COMBINATION', :new.seq_no);
      END IF;
    END IF;
    -- Basis
    IF Inserting THEN
      :new.record_status := nvl(:new.record_status, 'P');
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
