CREATE OR REPLACE TRIGGER "IU_SAILING_ADVICE_MESSAGE" 
BEFORE INSERT OR UPDATE ON SAILING_ADVICE_MESSAGE
FOR EACH ROW
BEGIN
    -- Basis
    -- Common
    IF Inserting THEN
      :NEW.record_status := nvl(:NEW.record_status, 'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := User;
      END IF;

      IF :new.sailing_message_no  IS NULL THEN
         EcDp_System_Key.assignNextNumber('SAILING_ADVICE_MESSAGE', :new.sailing_message_no);
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

