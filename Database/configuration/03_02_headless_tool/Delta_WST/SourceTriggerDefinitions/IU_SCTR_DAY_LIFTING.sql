CREATE OR REPLACE EDITIONABLE TRIGGER "IU_SCTR_DAY_LIFTING" 
BEFORE INSERT OR UPDATE ON SCTR_DAY_LIFTING
FOR EACH ROW
BEGIN
    -- Common
    IF Inserting THEN
      :new.daytime := trunc(:new.daytime,'DD');
      :new.record_status := 'P';
      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;

      IF :new.SEQ_NO IS NULL THEN
         EcDp_System_Key.assignNextNumber('SCTR_DAY_LIFTING', :new.SEQ_NO);
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
