CREATE OR REPLACE TRIGGER "IU_CARGO" 
BEFORE INSERT OR UPDATE ON CARGO
FOR EACH ROW

BEGIN
    -- $Revision: 1.9 $
    -- common
    IF Inserting THEN
      :NEW.record_status := NVL(:NEW.record_status,'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := User;
      END IF;

      IF :new.created_date IS NULL THEN
         :new.created_date := EcDp_Date_Time.getCurrentSysdate;
      END IF;

      :new.rev_no := 0;

      IF :new.cargo_no IS NULL THEN

         EcDp_System_Key.assignNextNumber('CARGO', :new.cargo_no);

      END IF;

      IF :new.cargo_code IS NULL THEN
         :new.cargo_code := to_char(:new.cargo_no);
      END IF;

      IF :new.cargo_code_numeric IS NULL THEN
         :new.cargo_code_numeric := :new.cargo_no;
      END IF;

      IF :new.cargo_type IS NULL THEN
         :new.cargo_type := 'CRUDE';
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

