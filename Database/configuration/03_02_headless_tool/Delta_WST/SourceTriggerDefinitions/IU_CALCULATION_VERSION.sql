CREATE OR REPLACE EDITIONABLE TRIGGER "IU_CALCULATION_VERSION" 
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