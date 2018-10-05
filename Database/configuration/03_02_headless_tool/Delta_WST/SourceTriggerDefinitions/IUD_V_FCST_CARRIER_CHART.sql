CREATE OR REPLACE EDITIONABLE TRIGGER "IUD_V_FCST_CARRIER_CHART" 
  INSTEAD OF INSERT OR UPDATE OR DELETE ON V_FCST_CARRIER_CHART
  FOR EACH ROW

  -- $Revision: 1.1 $
  -- Common

BEGIN

  IF UPDATING THEN

    IF (:OLD.CLASS = 'CARRIER_PORT_ACC') THEN
        UPDATE STOR_FCST_LIFT_NOM
           SET nom_firm_date     = :NEW.CHART_START_DATE,
               carrier_id        = ecdp_carrier_fcst.get_carrier_id(:NEW.carrier_name),
			   start_lifting_date= :NEW.CHART_START_DATE,
               rev_no            = :NEW.rev_no,
               rev_text          = :NEW.rev_text,
               record_status     = :NEW.record_status
         WHERE forecast_id = :OLD.forecast_id
           AND parcel_no = :OLD.PARCEL_NO;


    ELSIF (:OLD.CLASS = 'FCST_OPRES_PERIOD_RESTR') THEN
        UPDATE FCST_OPLOC_PERIOD_RESTR
           SET START_DATE        = :NEW.CHART_START_DATE,
               END_DATE          = :NEW.CHART_END_DATE,
               OBJECT_ID         = :NEW.OBJECT_ID,
               rev_no            = :NEW.rev_no,
               rev_text          = :NEW.rev_text,
               record_status     = :NEW.record_status
         WHERE START_DATE = :OLD.CHART_START_DATE
           AND OBJECT_ID = :OLD.OBJECT_ID
           AND FORECAST_ID = :OLD.FORECAST_ID;
     END IF;

	 UPDATE CARGO_fcst_TRANSPORT
           SET carrier_id        =  ecdp_carrier_fcst.get_carrier_id(:NEW.carrier_name),
               rev_no            = :NEW.rev_no,
               rev_text          = :NEW.rev_text,
               record_status     = :NEW.record_status
         WHERE CARGO_NO = ec_stor_fcst_lift_nom.cargo_no(:OLD.parcel_no,:OLD.forecast_id);

  END IF;

END;
