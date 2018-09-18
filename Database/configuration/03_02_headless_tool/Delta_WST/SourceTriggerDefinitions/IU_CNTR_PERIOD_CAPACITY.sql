CREATE OR REPLACE EDITIONABLE TRIGGER "IU_CNTR_PERIOD_CAPACITY" 
BEFORE INSERT OR UPDATE ON CNTR_PERIOD_CAPACITY
FOR EACH ROW
BEGIN
    -- Common
    IF Inserting THEN
	  --Generate sequence number for the contract capacity
      IF :new.PERIOD_CAPACITY_NO IS NULL THEN
         EcDp_System_Key.assignNextNumber('CNTR_PERIOD_CAPACITY', :new.PERIOD_CAPACITY_NO);
      END IF;

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
