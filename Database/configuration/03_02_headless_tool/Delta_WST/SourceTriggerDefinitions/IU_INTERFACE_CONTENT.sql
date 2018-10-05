CREATE OR REPLACE EDITIONABLE TRIGGER "IU_INTERFACE_CONTENT" 
BEFORE INSERT OR UPDATE ON interface_content
FOR EACH ROW
BEGIN
    -- Common
    IF Inserting THEN
      :new.record_status := 'P';
      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;
      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;

      IF :new.interface_no IS NULL THEN
         EcDp_System_Key.assignNextNumber('INTERFACE_CONTENT', :new.interface_no);
      END IF;

      -- Resolve business unit id and code
      IF :new.BUSINESS_UNIT_ID IS NOT NULL THEN
         :new.BUSINESS_UNIT_CODE := ec_business_unit.object_code(:new.BUSINESS_UNIT_ID);
      ELSIF :new.BUSINESS_UNIT_CODE IS NOT NULL THEN
         :new.BUSINESS_UNIT_ID := ec_business_unit.object_id_by_uk(:new.BUSINESS_UNIT_CODE);
      END IF;

    ELSE
      IF Nvl(:new.record_status,'P') = Nvl(:old.record_status,'P') THEN
         IF NOT UPDATING('LAST_UPDATED_BY') THEN
            :new.last_updated_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
         END IF;
         IF NOT UPDATING('LAST_UPDATED_DATE') THEN
           :new.last_updated_date := Ecdp_Timestamp.getCurrentSysdate;
         END IF;
      END IF;

      -- Resolve business unit id and code
      IF UPDATING('BUSINESS_UNIT_ID') THEN
         :new.BUSINESS_UNIT_CODE := ec_business_unit.object_code(:new.BUSINESS_UNIT_ID);
      ELSIF UPDATING('BUSINESS_UNIT_CODE') THEN
         :new.BUSINESS_UNIT_ID := ec_business_unit.object_id_by_uk(:new.BUSINESS_UNIT_CODE);
      END IF;

    END IF;

END;
