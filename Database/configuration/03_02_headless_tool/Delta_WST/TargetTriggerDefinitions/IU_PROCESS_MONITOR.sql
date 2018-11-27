CREATE OR REPLACE TRIGGER "IU_PROCESS_MONITOR" 
BEFORE INSERT OR UPDATE ON PROCESS_MONITOR
FOR EACH ROW
BEGIN
    -- Common
    IF Inserting THEN
      IF :new.PROCESS_MONITOR_NO IS NULL THEN
        :new.PROCESS_MONITOR_NO:=
         EcDp_System_key.assignNextKeyValue('PROCESS_MONITOR');
      END IF;
      :new.record_status := nvl(:new.record_status, 'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := User;
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

