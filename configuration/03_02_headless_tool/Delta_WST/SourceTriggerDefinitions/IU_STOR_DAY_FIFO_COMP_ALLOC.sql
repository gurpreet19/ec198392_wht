CREATE OR REPLACE EDITIONABLE TRIGGER "IU_STOR_DAY_FIFO_COMP_ALLOC" 
BEFORE INSERT OR UPDATE ON STOR_DAY_FIFO_COMP_ALLOC
FOR EACH ROW
BEGIN
    -- $Revision: 1.3 $
    -- Common
    IF Inserting THEN

      IF :new.fifo_no IS NULL THEN

         EcDp_System_Key.assignNextNumber('STOR_DAY_FIFO_COMP_ALLOC', :new.fifo_no);

      END IF;

      :new.daytime := trunc(:new.daytime,'DD');
      :NEW.record_status := NVL(:NEW.record_status,'P');
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
