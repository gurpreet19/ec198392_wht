CREATE OR REPLACE EDITIONABLE TRIGGER "IU_CHEM_TANK_PRODUCT" 
BEFORE INSERT OR UPDATE ON CHEM_TANK_PRODUCT
FOR EACH ROW
DECLARE
   ld_chem_product_end_date   DATE;
BEGIN
    -- $Revision: 1.12 $
    -- Common
    IF Inserting THEN
      :NEW.record_status := NVL(:NEW.record_status,'P');
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


   ld_chem_product_end_date := ec_chem_product.end_date(:NEW.chem_product_id);

   -- Daytime cannot be prior chemical product's object_start_date.
   IF :NEW.daytime < ec_chem_product.start_date(:NEW.chem_product_id) THEN
      Raise_Application_Error(-20104,'Daytime cannot be set prior to chemical products start date.');
   END IF;

   -- Daytime cannot be after chemical product's object_end_date.
   IF :NEW.daytime > Nvl(ld_chem_product_end_date,:NEW.daytime + 1) THEN
      Raise_Application_Error(-20104,'Daytime cannot be greater than chemical products end date.');
   END IF;

END;
