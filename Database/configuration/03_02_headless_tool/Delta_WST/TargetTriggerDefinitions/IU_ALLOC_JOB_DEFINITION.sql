CREATE OR REPLACE TRIGGER "IU_ALLOC_JOB_DEFINITION" 
BEFORE INSERT OR UPDATE ON alloc_job_definition
FOR EACH ROW

BEGIN
    -- $Revision: 1.4 $
    -- Common
    IF Inserting THEN
      :NEW.record_status := NVL(:NEW.record_status,'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := User;
      END IF;

      IF :new.created_date IS NULL THEN
         :new.created_date := EcDp_Date_Time.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;

      IF :new.job_no IS NULL THEN
         EcDp_System_Key.assignNextNumber('ALLOC_JOB_DEFINITION', :new.job_no);
      END IF;

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

    IF UPDATING THEN
       EcBp_Alloc_Job.budAllocJobDefinition(:OLD.JOB_NO, :OLD.VALID_FROM_DATE);
    END IF;
END;

