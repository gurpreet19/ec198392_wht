CREATE OR REPLACE TRIGGER "IU_CALCULATION_VERSION" 
BEFORE INSERT OR UPDATE ON CALCULATION_VERSION
FOR EACH ROW
DECLARE
    lb_xls_template  BLOB;
BEGIN
    -- Custom
    IF Inserting THEN
      IF :new.xls_template IS NULL THEN
        lb_xls_template := EcDp_LOB.getBlobTemplate('XLS_CALCULATION','DEFAULT');
        :new.xls_template := lb_xls_template;
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

