CREATE OR REPLACE TRIGGER "IU_REPORT_TEMPLATE" 
BEFORE INSERT OR UPDATE ON REPORT_TEMPLATE
FOR EACH ROW
DECLARE
    lb_template_blob BLOB;
BEGIN
    -- $Revision: 1.2 $
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

      -- Initialise BLOBs
      IF :new.template_blob IS NULL THEN
         dbms_lob.createtemporary(lb_template_blob,true,dbms_lob.session);
         :new.template_blob := lb_template_blob;
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
END;

