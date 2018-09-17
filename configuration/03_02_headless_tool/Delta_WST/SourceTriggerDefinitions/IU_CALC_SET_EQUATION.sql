CREATE OR REPLACE EDITIONABLE TRIGGER "IU_CALC_SET_EQUATION" 
BEFORE INSERT OR UPDATE ON CALC_SET_EQUATION
FOR EACH ROW
DECLARE
    lc_iterations  CLOB;
    lc_condition   CLOB;
    lc_equation    CLOB;
    lc_description CLOB;
BEGIN
    -- Custom
    IF Inserting THEN
      IF :new.seq_no IS NULL THEN
         EcDp_System_Key.assignNextNumber('CALC_SET_EQUATION', :new.seq_no);
      END IF;
      -- Initialise CLOBs
      IF :new.iterations IS NULL THEN
         dbms_lob.createtemporary(lc_iterations,true,dbms_lob.session);
         :new.iterations := lc_iterations;
      END IF;
      IF :new.condition IS NULL THEN
         dbms_lob.createtemporary(lc_condition,true,dbms_lob.session);
         :new.condition := lc_condition;
      END IF;
      IF :new.equation IS NULL THEN
         dbms_lob.createtemporary(lc_equation,true,dbms_lob.session);
         :new.equation := lc_equation;
      END IF;
      IF :new.description IS NULL THEN
         dbms_lob.createtemporary(lc_description,true,dbms_lob.session);
         :new.description := lc_description;
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
