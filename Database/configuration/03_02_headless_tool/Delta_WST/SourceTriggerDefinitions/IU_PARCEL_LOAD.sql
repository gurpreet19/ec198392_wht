CREATE OR REPLACE EDITIONABLE TRIGGER "IU_PARCEL_LOAD" 
BEFORE INSERT OR UPDATE ON PARCEL_LOAD
FOR EACH ROW

DECLARE

lv2_company_no parcel_nomination.company_id%TYPE;
ln_parcel_no parcel_nomination.parcel_no%TYPE;
ln_return NUMBER;
ln_vol_nominated NUMBER;

BEGIN

    IF Inserting THEN
      :NEW.record_status := NVL(:NEW.record_status,'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;

      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;

      :new.rev_no := 0;

    ELSE -- UPDATING
      IF Nvl(:new.record_status,'P') = Nvl(:old.record_status,'P') THEN
         IF NOT UPDATING('LAST_UPDATED_BY') THEN
            :new.last_updated_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
         END IF;

         IF NOT UPDATING('LAST_UPDATED_DATE') THEN
           :new.last_updated_date := Ecdp_Timestamp.getCurrentSysdate;
         END IF;


         IF lv2_company_no IS NOT NULL THEN
           -- credit any previous transactions
           IF ec_ctrl_system_attribute.attribute_text(
            Ecdp_Timestamp.getCurrentSysdate,'UOM','<=') = 'SI' THEN
              EcBp_Transaction.transaction(
                           ec_parcel_nomination.company_id(:NEW.parcel_load_no),
                           :New.storage_id ,
                           :New.bl_date,
                           :NEW.parcel_load_no,
                           :New.parcel_load_no,
                           :New.net_vol ,
                           'LIFTED',
                           ln_return);
           ELSE
              EcBp_Transaction.transaction(ec_parcel_nomination.company_id(:NEW.parcel_load_no),
                           :New.storage_id ,
                           :New.bl_date,
                           :NEW.parcel_load_no,
                           :New.parcel_load_no,
                           :New.net_vol_bbls ,
                           'LIFTED',
                           ln_return);
           END IF;
         END IF;
      END IF;
    END IF;

END;
