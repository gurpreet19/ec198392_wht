CREATE OR REPLACE EDITIONABLE TRIGGER "IU_ALLOC_JOB_LOG" 
BEFORE INSERT OR UPDATE ON alloc_job_log
FOR EACH ROW
DECLARE
    lb_tmp  BLOB;
BEGIN
    -- $Revision: 1.3 $
    -- Common
    IF Inserting THEN
      :NEW.record_status := NVL(:NEW.record_status,'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;

      IF :new.run_no IS NULL THEN
         EcDp_System_Key.assignNextNumber('ALLOC_JOB_LOG', :new.run_no);
      END IF;
      IF :new.detail_binary_log IS NULL THEN
         dbms_lob.createtemporary(lb_tmp,true,dbms_lob.session);
         :new.detail_binary_log := lb_tmp;
      END IF;
      IF :new.log_summary IS NULL THEN
         dbms_lob.createtemporary(lb_tmp,true,dbms_lob.session);
         :new.log_summary := lb_tmp;
      END IF;
      IF :new.detail_log_block_index IS NULL THEN
         dbms_lob.createtemporary(lb_tmp,true,dbms_lob.session);
         :new.detail_log_block_index := lb_tmp;
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
