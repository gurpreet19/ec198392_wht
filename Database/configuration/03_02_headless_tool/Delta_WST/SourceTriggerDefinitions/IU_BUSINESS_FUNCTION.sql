CREATE OR REPLACE EDITIONABLE TRIGGER "IU_BUSINESS_FUNCTION" 
BEFORE INSERT OR UPDATE ON BUSINESS_FUNCTION
FOR EACH ROW
BEGIN
    -- $Revision: 1.2 $
    -- Common
    IF Inserting THEN

      IF :NEW.BUSINESS_FUNCTION_NO IS NULL THEN

          EcDp_System_Key.assignNextNumber('BUSINESS_FUNCTION', :new.BUSINESS_FUNCTION_NO);

      END IF;


      :new.record_status := 'P';
      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;
      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;

    ELSIF UPDATING THEN

      IF Nvl(:new.record_status,'P') = Nvl(:old.record_status,'P') THEN
         IF NOT UPDATING('LAST_UPDATED_BY') THEN
            :new.last_updated_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
         END IF;
         IF NOT UPDATING('LAST_UPDATED_DATE') THEN
           :new.last_updated_date := Ecdp_Timestamp.getCurrentSysdate;
         END IF;
      END IF;

      -- NB CODE ASSUMING THAT BF_CODE IS NOT NULL
      IF :NEW.BF_CODE <> :OLD.BF_CODE THEN
        EcDp_Business_function.AddBFList(:NEW.BF_CODE,:OLD.BF_CODE);
      END IF;

    END IF;
END;
