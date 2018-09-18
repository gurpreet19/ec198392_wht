CREATE OR REPLACE EDITIONABLE TRIGGER "IU_PTST_RESULT" 
BEFORE INSERT OR UPDATE ON ptst_result
FOR EACH ROW
BEGIN
    -- $Revision: 1.5 $
    -- Common
    IF Inserting THEN

      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;

      IF :new.result_no IS NULL THEN

         EcDp_System_Key.assignNextNumber('PTST_RESULT', :new.result_no);

      END IF;

      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;

      :new.rev_no := 0;
      :NEW.record_status := NVL(:NEW.record_status,'P');

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

    IF :NEW.USE_CALC = 'Y' AND :NEW.STATUS = 'ACCEPTED' THEN
      :NEW.ACCEPTED_DATE := Ecdp_Timestamp.getCurrentSysdate;
    ELSE
      :NEW.ACCEPTED_DATE := NULL;
    END IF;

END;
