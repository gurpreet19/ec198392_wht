CREATE OR REPLACE EDITIONABLE TRIGGER "IU_BPM_EC_GCOMMAND_OP" 
BEFORE INSERT OR UPDATE ON BPM_EC_GCOMMAND_OP
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
      :new.rev_no := 0;

      -- Assign next key value for pk column, if not set by insert statement
      IF :new.BPM_EC_GCOMMAND_OP_ID IS NULL THEN
           EcDp_System_Key.assignNextNumber('BPM_EC_GCOMMAND_OP', :new.BPM_EC_GCOMMAND_OP_ID);
      END IF;

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
