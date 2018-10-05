CREATE OR REPLACE TRIGGER "IU_CALC_PROC_ELM_ITERATION" 
BEFORE INSERT OR UPDATE ON CALC_PROC_ELM_ITERATION
FOR EACH ROW
BEGIN
    -- Custom
    IF Inserting THEN
      IF :new.seq_no IS NULL THEN
         EcDp_System_Key.assignNextNumber('CALC_PROC_ELM_ITERATION', :new.seq_no);
      END IF;
    END IF;
    -- Basis
    IF Inserting THEN
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

