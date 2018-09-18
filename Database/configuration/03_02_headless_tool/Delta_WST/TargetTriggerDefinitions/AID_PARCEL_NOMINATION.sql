CREATE OR REPLACE TRIGGER "AID_PARCEL_NOMINATION" 
AFTER INSERT OR UPDATE OR DELETE ON PARCEL_NOMINATION
FOR EACH ROW

DECLARE
 ln_return number;
 ld_est_arrival DATE;

BEGIN
  -- $Revision: 1.4 $
  -- Special
  IF Deleting THEN
   NULL;
  ELSIF UPDATING THEN
   IF (:NEW.STORAGE_ID <> :OLD.STORAGE_ID) THEN
      UPDATE parcel_load SET storage_id = :NEW.STORAGE_ID WHERE cargo_no = :OLD.cargo_no AND parcel_load_no = :OLD.parcel_no;
   END IF;
  ELSE
      -- insert parcel_load
      INSERT INTO parcel_load (--sysnam, cargo_no, parcel_load_no, storage_code, terminal_code)
      		cargo_no, parcel_load_no, storage_id)
      VALUES (--:NEW.sysnam, :NEW.cargo_no, :NEW.parcel_no, :NEW.storage_code, 'NA');
		:NEW.cargo_no, :NEW.parcel_no, :NEW.storage_id);

      SELECT Nvl(est_arrival,TRUNC(EcDp_Date_Time.getCurrentSysdate,'DD'))
      INTO ld_est_arrival
      FROM cargo
      WHERE cargo_no = :NEW.cargo_no;
--      AND sysnam = :NEW.sysnam;

      -- insert parcel_analysis
      INSERT INTO parcel_analysis (--sysnam,
      			cargo_no, parcel_load_no, daytime, analysis_no, analysis_type, sampling_method)
      VALUES (--:NEW.sysnam,
      			:NEW.cargo_no, :NEW.parcel_no, ld_est_arrival, 1, 'AUTO', 'AUTO');

      -- insert parcel_discharge
      INSERT INTO parcel_discharge (--sysnam,
      		cargo_no, parcel_load_no, discharge_no)
      VALUES (--:NEW.sysnam,
      		:NEW.cargo_no, :NEW.parcel_no, 1);


      -- insert transactions
      EcBp_Transaction.transaction(--:New.sysnam,
                      :New.company_id,
                      :New.storage_id ,
                      ld_est_arrival,
                      :New.parcel_no,
                      :New.parcel_no,
                      :New.grs_vol_nominated ,
                      'PLANNED',
                      ln_return);

   END IF;
END;

