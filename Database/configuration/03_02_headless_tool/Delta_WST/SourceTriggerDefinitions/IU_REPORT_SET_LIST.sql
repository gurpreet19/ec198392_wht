CREATE OR REPLACE EDITIONABLE TRIGGER "IU_REPORT_SET_LIST" 
BEFORE INSERT OR UPDATE ON report_set_list
FOR EACH ROW

DECLARE
 v_new_ref_no number;

BEGIN

    IF Inserting THEN

        SELECT max(REF_NO) into v_new_ref_no
        FROM REPORT_SET_LIST
        WHERE REPORT_SET_NO = :new.REPORT_SET_NO;

        IF v_new_ref_no IS NULL THEN
          v_new_ref_no := 0;
        END IF;

        IF :new.ref_no IS NULL THEN
           :new.ref_no := v_new_ref_No+1;
        END IF;

        :new.record_status := 'P';
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
