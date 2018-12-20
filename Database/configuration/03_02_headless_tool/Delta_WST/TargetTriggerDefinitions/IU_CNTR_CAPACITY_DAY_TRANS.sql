CREATE OR REPLACE TRIGGER "IU_CNTR_CAPACITY_DAY_TRANS" 
BEFORE INSERT OR UPDATE ON CNTR_CAPACITY_DAY_TRANS
FOR EACH ROW
BEGIN
    -- Basis
    IF Inserting THEN
      :new.daytime := trunc(:new.daytime,'DD');
      :new.record_status := nvl(:new.record_status, 'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := User;
      END IF;

	  	IF :new.TRANSACTION_SEQ IS NULL THEN
         EcDp_System_Key.assignNextNumber('CNTR_CAPACITY_DAY_TRANS', :new.TRANSACTION_SEQ);
      END IF;

      IF :new.created_date IS NULL THEN
         :new.created_date := EcDp_Date_Time.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;
    ELSE
      IF Nvl(:new.record_status,'P') = Nvl(:old.record_status,'P') THEN
         IF NOT UPDATING('LAST_UPDATED_BY') THEN
            :new.last_updated_by := User;
         END IF;
         IF NOT UPDATING('LAST_UPDATED_DATE') THEN
           :new.last_updated_date := EcDp_Date_Time.getCurrentSysdate;
         END IF;
      END IF;
    END IF;
END;
