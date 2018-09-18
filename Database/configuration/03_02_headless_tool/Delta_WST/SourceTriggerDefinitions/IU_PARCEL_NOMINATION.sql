CREATE OR REPLACE EDITIONABLE TRIGGER "IU_PARCEL_NOMINATION" 
BEFORE INSERT OR UPDATE ON PARCEL_NOMINATION
FOR EACH ROW

DECLARE

ln_return NUMBER;
ld_est_arrival DATE;

BEGIN

  -- $Revision: 1.12 $
  -- Common

    IF Inserting THEN

      :NEW.record_status := NVL(:NEW.record_status,'P');

      IF :new.parcel_no IS NULL THEN

         EcDp_System_Key.assignNextNumber('PARCEL_NOMINATION', :new.parcel_no);

      END IF;

      IF :new.parcel_code IS NULL THEN

         :new.parcel_code := :new.parcel_no;

      END IF;

      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;

      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;

      :new.rev_no := 0;

    ELSE -- updating

      IF Nvl(:new.record_status,'P') = Nvl(:old.record_status,'P') THEN
        IF NOT UPDATING('LAST_UPDATED_BY') THEN
           :new.last_updated_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
        END IF;

         IF NOT UPDATING('LAST_UPDATED_DATE') THEN
           :new.last_updated_date := Ecdp_Timestamp.getCurrentSysdate;
         END IF;



        IF Nvl(:New.Company_id,'XXX') <> Nvl(:Old.company_id,'XXX') THEN

           -- clean up
           EcBp_Transaction.delete_parcel_trans(
                              :New.storage_id ,
                              :New.parcel_no,
                               ln_return);

           -- update transactions
           EcBp_Transaction.transaction(
                              :New.company_id,
                              :New.storage_id ,
                              ec_cargo.est_arrival(
                              			:New.cargo_no),
                              :New.parcel_no,
                              :New.parcel_no,
                              :New.grs_vol_nominated ,
                              'PLANNED',
                              ln_return);

        ELSE

           -- update transactions
           EcBp_Transaction.transaction(
                              :New.company_id,
                              :New.storage_id ,
                              ec_cargo.est_arrival(
                              			:New.cargo_no),
                              :New.parcel_no,
                              :New.parcel_no,
                              :New.grs_vol_nominated ,
                              'PLANNED',
                              ln_return);

        END IF;
      END IF;

    END IF;

END;
