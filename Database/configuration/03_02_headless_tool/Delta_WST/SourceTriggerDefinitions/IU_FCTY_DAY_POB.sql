CREATE OR REPLACE EDITIONABLE TRIGGER "IU_FCTY_DAY_POB" 
BEFORE INSERT OR UPDATE ON fcty_day_pob
FOR EACH ROW
BEGIN
    -- $Revision: 1.6 $
    -- COMMON
    IF Inserting THEN

      :NEW.record_status := NVL(:NEW.record_status,'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;

      IF :NEW.seq_number IS NULL THEN
          EcDp_System_Key.assignNextNumber('FCTY_DAY_POB', :new.seq_number);
      END IF;

      IF :NEW.name IS NOT NULL THEN
	  IF :NEW.to_date = :NEW.daytime THEN
	      :NEW.head_count := 0;
	  END IF;

	  IF :NEW.to_date <> :NEW.daytime OR :NEW.to_date IS NULL THEN
	      :NEW.head_count := 1;
	  END IF;
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
