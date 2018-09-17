CREATE OR REPLACE EDITIONABLE TRIGGER "IU_REPORT_RUNABLE" 
BEFORE INSERT OR UPDATE ON report_runable
FOR EACH ROW
BEGIN
    -- $Revision: 1.2 $
    -- Common
    IF Inserting THEN
      :NEW.record_status := NVL(:NEW.record_status,'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;

      IF :new.report_runable_no IS NULL THEN
         EcDp_System_Key.assignNextNumber('REPORT_RUNABLE', :new.report_runable_no);
      END IF;

      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;

      IF :new.functional_area_id IS NULL THEN
           :new.functional_area_id := ec_report_definition_group.functional_area_id(:new.rep_group_code);
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
