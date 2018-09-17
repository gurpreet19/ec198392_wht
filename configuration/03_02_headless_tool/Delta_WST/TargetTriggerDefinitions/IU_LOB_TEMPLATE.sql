CREATE OR REPLACE TRIGGER "IU_LOB_TEMPLATE" 
BEFORE INSERT OR UPDATE ON LOB_TEMPLATE
FOR EACH ROW
DECLARE
    lc_clob   CLOB;
    lb_blob   BLOB;
BEGIN
    -- Custom
    IF Inserting THEN
      -- Initialise LOBs
      dbms_lob.createtemporary(lc_clob,true,dbms_lob.session);
      :new.clob_value := lc_clob;
      dbms_lob.createtemporary(lb_blob,true,dbms_lob.session);
      :new.blob_value := lb_blob;
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

