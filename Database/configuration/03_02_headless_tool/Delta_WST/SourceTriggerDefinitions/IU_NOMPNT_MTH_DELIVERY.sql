CREATE OR REPLACE EDITIONABLE TRIGGER "IU_NOMPNT_MTH_DELIVERY" 
BEFORE INSERT OR UPDATE ON NOMPNT_MTH_DELIVERY
FOR EACH ROW
BEGIN
    -- Basis
    IF Inserting THEN
      :new.daytime := trunc(:new.daytime,'MM');
      :new.record_status := nvl(:new.record_status, 'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;
      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;

      IF :new.NOMINATION_SEQ IS NULL THEN
         EcDp_System_Key.assignNextNumber('NOMPNT_MTH_DELIVERY', :new.NOMINATION_SEQ);
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
