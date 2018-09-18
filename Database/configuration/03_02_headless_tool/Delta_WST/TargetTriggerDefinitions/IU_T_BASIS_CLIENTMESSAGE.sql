CREATE OR REPLACE TRIGGER "IU_T_BASIS_CLIENTMESSAGE" 
BEFORE INSERT OR UPDATE ON t_basis_clientmessage
FOR EACH ROW
DECLARE
 ln_seq NUMBER;
BEGIN
    -- $Revision: 1.4 $
    -- Basis
    IF Inserting THEN
      :NEW.record_status := NVL(:NEW.record_status,'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := User;
      END IF;

      IF :new.MESSAGECODE IS NULL THEN
         select seq_MessageCode.nextval INTO ln_seq FROM DUAL;

         :new.MESSAGECODE := ltrim(to_char(ln_seq,'0000'));
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

