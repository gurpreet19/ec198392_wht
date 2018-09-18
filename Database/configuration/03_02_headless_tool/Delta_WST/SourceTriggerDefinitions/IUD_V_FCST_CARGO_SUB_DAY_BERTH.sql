CREATE OR REPLACE EDITIONABLE TRIGGER "IUD_V_FCST_CARGO_SUB_DAY_BERTH" 
  INSTEAD OF INSERT OR UPDATE OR DELETE ON V_FCST_CARGO_SUB_DAY_BERTH
  FOR EACH ROW

  -- $Revision: 1.1 $
  -- Common

BEGIN

  IF UPDATING THEN

    IF (:OLD.CLASS = 'STOR_FCST_SUB_DAY_LIFT_NOM') THEN
        --Update new CHART_END_DATE to the sub daily data
        UPDATE stor_fcst_sub_day_lift_nom
           SET daytime           =  trunc(:NEW.CHART_END_DATE, 'HH24'),
               LAST_UPDATED_BY   =  :NEW.last_updated_by,
               REV_NO	         =  :NEW.rev_no,
               REV_TEXT          =  :NEW.rev_text,
               LAST_UPDATED_DATE =  :NEW.last_updated_date,
               RECORD_STATUS     =  :NEW.record_status
         WHERE forecast_id = :OLD.forecast_id
           AND parcel_no = :OLD.PARCEL_NO
		       AND daytime = :OLD.CHART_END_DATE
           AND summer_time = :OLD.SUMMER_TIME;

        UPDATE STOR_FCST_LIFT_NOM
        --Update new CHART_START_DATE to the main data
           SET nom_firm_date     =  trunc(:NEW.CHART_START_DATE, 'HH24'),
               start_lifting_date=  trunc(:NEW.CHART_START_DATE, 'HH24'),
               LAST_UPDATED_BY   =  :NEW.last_updated_by,
               REV_NO	           =  :NEW.rev_no,
               REV_TEXT          =  :NEW.rev_text,
               LAST_UPDATED_DATE =  :NEW.last_updated_date,
               RECORD_STATUS     =  :NEW.record_status
         WHERE forecast_id = :OLD.forecast_id
           AND parcel_no = :OLD.PARCEL_NO;

        UPDATE CARGO_FCST_TRANSPORT
           SET BERTH_ID          =  :NEW.BERTH_ID,
               LAST_UPDATED_BY   =  :NEW.last_updated_by,
               REV_NO	           =  :NEW.rev_no,
               REV_TEXT          =  :NEW.rev_text,
               LAST_UPDATED_DATE =  :NEW.last_updated_date,
               RECORD_STATUS     =  :NEW.record_status
         WHERE CARGO_NO = :OLD.CARGO_NO
           AND FORECAST_ID = :OLD.FORECAST_ID;

    ELSIF (:OLD.CLASS = 'FCST_OPRES_PERIOD_RESTR') THEN
        UPDATE FCST_OPLOC_PERIOD_RESTR
           SET START_DATE        =  trunc(:NEW.CHART_START_DATE, 'HH24'),
               END_DATE          =  trunc(:NEW.CHART_START_DATE, 'HH24'),
               OBJECT_ID         =  :NEW.BERTH_ID,
               LAST_UPDATED_BY   =  :NEW.last_updated_by,
               REV_NO	           =  :NEW.rev_no,
               REV_TEXT          =  :NEW.rev_text,
               LAST_UPDATED_DATE =  :NEW.last_updated_date,
               RECORD_STATUS     =  :NEW.record_status
         WHERE START_DATE = :OLD.CHART_START_DATE
           AND OBJECT_ID = :OLD.BERTH_ID
           AND FORECAST_ID = :OLD.FORECAST_ID;
    END IF;

  END IF;

END;
