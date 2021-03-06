CREATE OR REPLACE EDITIONABLE TRIGGER "IU_DEFER_LOSS_ACC_EVENT" 
BEFORE INSERT OR UPDATE ON DEFER_LOSS_ACC_EVENT
FOR EACH ROW
BEGIN
    -- Common
    IF Inserting THEN
      :new.record_status := nvl(:new.record_status, 'P');
      --new event_no will be assigned to DEFER_LOSS_ACC_EVENT
      IF :new.event_no IS NULL THEN
         EcDp_System_Key.assignNextNumber('DEFER_LOSS_ACC_EVENT', :new.event_no);
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
