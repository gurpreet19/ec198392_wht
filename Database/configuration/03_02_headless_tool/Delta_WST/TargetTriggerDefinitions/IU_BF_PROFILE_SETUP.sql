CREATE OR REPLACE TRIGGER "IU_BF_PROFILE_SETUP" 
BEFORE INSERT OR UPDATE ON BF_PROFILE_SETUP
FOR EACH ROW
BEGIN
    -- $Revision: 1.2 $
    -- Common
    IF Inserting THEN

      IF :NEW.BUSINESS_FUNCTION_NO IS NULL THEN

         :new.BUSINESS_FUNCTION_NO := ecdp_business_function.getBusinessFunctionNo(:NEW.BF_CODE);

      ELSE -- Make sure the BF_CODE reflects the BUSINESS_FUNCTION_NO

         :NEW.BF_CODE := ec_business_function.bf_code(:new.BUSINESS_FUNCTION_NO);

      END IF;

      :new.record_status := 'P';
      IF :new.created_by IS NULL THEN
         :new.created_by := User;
      END IF;
      IF :new.created_date IS NULL THEN
         :new.created_date := EcDp_Date_Time.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;

    ELSIF UPDATING THEN

      IF Nvl(:new.record_status,'P') = Nvl(:old.record_status,'P') THEN
         IF NOT UPDATING('LAST_UPDATED_BY') THEN
            :new.last_updated_by := User;
         END IF;
         IF NOT UPDATING('LAST_UPDATED_DATE') THEN
           :new.last_updated_date := EcDp_Date_Time.getCurrentSysdate;
         END IF;
      END IF;

      -- Lets do any syncronisation fix for this row first
      -- NOTE IF updating both BUSINESS_FUNCTION_NO and bf_code then BUSINESS_FUNCTION_NO takes presidence.

      IF Nvl(:NEW.BUSINESS_FUNCTION_NO,0) <> Nvl(:OLD.BUSINESS_FUNCTION_NO,0)  THEN

        -- need to adjust BF_CODE
        :NEW.BF_CODE := ec_business_function.bf_code(:new.BUSINESS_FUNCTION_NO);

      ELSIF Nvl(:NEW.BF_CODE,'NULL') <> Nvl(:OLD.BF_CODE,'NULL') THEN

         :new.BUSINESS_FUNCTION_NO := ecdp_business_function.getBusinessFunctionNo(:NEW.BF_CODE);

      END IF;


    END IF;

END;

