CREATE OR REPLACE EDITIONABLE TRIGGER "IUD_V_FCST_CARGO_BERTH_CHART" 
  INSTEAD OF INSERT OR UPDATE OR DELETE ON V_FCST_CARGO_BERTH_CHART
  FOR EACH ROW

  -- $Revision: 1.1 $
  -- Common

BEGIN

  IF UPDATING THEN

    IF (:OLD.CLASS = 'FCST_STOR_LIFT_NOM_SCHED') THEN
        UPDATE STOR_FCST_LIFT_NOM
           SET nom_firm_date     = :NEW.CHART_START_DATE,
               start_lifting_date= :NEW.CHART_START_DATE,
               rev_no            = :NEW.rev_no,
               rev_text          = :NEW.rev_text,
               record_status     = :NEW.record_status
         WHERE nom_firm_date = :OLD.CHART_START_DATE
           AND forecast_id = :OLD.forecast_id
           AND parcel_no = :OLD.PARCEL_NO;

        UPDATE CARGO_FCST_TRANSPORT
           SET BERTH_ID          = :NEW.BERTH_ID,
               rev_no            = :NEW.rev_no,
               rev_text          = :NEW.rev_text,
               record_status     = :NEW.record_status
         WHERE CARGO_NO = :OLD.CARGO_NO
           AND FORECAST_ID = :OLD.FORECAST_ID;

    ELSIF (:OLD.CLASS = 'FCST_OPRES_PERIOD_RESTR') THEN
        UPDATE FCST_OPLOC_PERIOD_RESTR
           SET START_DATE        = :NEW.CHART_START_DATE,
               END_DATE          = :NEW.CHART_END_DATE,
               OBJECT_ID         = :NEW.BERTH_ID,
               rev_no            = :NEW.rev_no,
               rev_text          = :NEW.rev_text,
               record_status     = :NEW.record_status
         WHERE START_DATE = :OLD.CHART_START_DATE
           AND OBJECT_ID = :OLD.BERTH_ID
           AND FORECAST_ID = :OLD.FORECAST_ID;
     END IF;

  END IF;

END;
