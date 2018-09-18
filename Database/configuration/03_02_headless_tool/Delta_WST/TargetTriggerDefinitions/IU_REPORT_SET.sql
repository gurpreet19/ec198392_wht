CREATE OR REPLACE TRIGGER "IU_REPORT_SET" 
BEFORE INSERT OR UPDATE ON report_set
FOR EACH ROW
BEGIN
    -- $Revision: 1.2 $
    -- Common
    IF Inserting THEN
      :new.record_status := 'P';
      IF :new.created_by IS NULL THEN
         :new.created_by := User;
      END IF;

      IF :new.report_set_no IS NULL THEN
         EcDp_System_Key.assignNextNumber('REPORT_SET', :new.report_set_no);
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

