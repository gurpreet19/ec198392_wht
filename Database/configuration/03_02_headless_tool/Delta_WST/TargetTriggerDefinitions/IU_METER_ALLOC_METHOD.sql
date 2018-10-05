CREATE OR REPLACE TRIGGER "IU_METER_ALLOC_METHOD" 
BEFORE INSERT OR UPDATE ON METER_ALLOC_METHOD
FOR EACH ROW
BEGIN
    -- Common
    IF Inserting THEN
      :new.record_status := nvl(:new.record_status, 'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := User;
      END IF;
	  IF :new.ALLOC_METHOD_SEQ IS NULL THEN
         EcDp_System_Key.assignNextNumber('METER_ALLOC_METHOD', :new.ALLOC_METHOD_SEQ);
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

