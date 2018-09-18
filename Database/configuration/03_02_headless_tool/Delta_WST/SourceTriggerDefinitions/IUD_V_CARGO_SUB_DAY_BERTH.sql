CREATE OR REPLACE EDITIONABLE TRIGGER "IUD_V_CARGO_SUB_DAY_BERTH" 
  INSTEAD OF INSERT OR UPDATE OR DELETE ON V_CARGO_SUB_DAY_BERTH
  FOR EACH ROW

  -- $Revision: 1.1 $
  -- Common

BEGIN

  IF UPDATING THEN

    IF (:OLD.CLASS = 'STOR_SUB_DAY_LIFT_NOM') THEN
        --Update new CHART_END_DATE to the sub daily data
        UPDATE stor_sub_day_lift_nom
           SET daytime           =  trunc(:NEW.CHART_END_DATE, 'HH24'),
               LAST_UPDATED_BY   =  :NEW.last_updated_by,
               REV_NO	           =  :NEW.rev_no,
               REV_TEXT          =  :NEW.rev_text,
               LAST_UPDATED_DATE =  :NEW.last_updated_date,
               RECORD_STATUS     =  :NEW.record_status
         WHERE parcel_no = :OLD.PARCEL_NO
		       AND daytime = :OLD.CHART_END_DATE
           AND summer_time = :OLD.summer_time;

        UPDATE STORAGE_LIFT_NOMINATION
        --Update new CHART_START_DATE to the main data
           SET nom_firm_date     =  trunc(:NEW.CHART_START_DATE, 'HH24'),
               start_lifting_date=  trunc(:NEW.CHART_START_DATE, 'HH24'),
               LAST_UPDATED_BY   =  :NEW.last_updated_by,
               REV_NO	           =  :NEW.rev_no,
               REV_TEXT          =  :NEW.rev_text,
               LAST_UPDATED_DATE =  :NEW.last_updated_date,
               RECORD_STATUS     =  :NEW.record_status
         WHERE parcel_no = :OLD.PARCEL_NO;

        UPDATE CARGO_TRANSPORT
           SET BERTH_ID          =  :NEW.OBJECT_ID,
               LAST_UPDATED_BY   =  :NEW.last_updated_by,
               REV_NO	           =  :NEW.rev_no,
               REV_TEXT          =  :NEW.rev_text,
               LAST_UPDATED_DATE =  :NEW.last_updated_date,
               RECORD_STATUS     =  :NEW.record_status
         WHERE CARGO_NO = :OLD.CARGO_NO;

    ELSIF (:OLD.CLASS = 'OPRES_PERIOD_RESTR') THEN
        UPDATE OPLOC_PERIOD_RESTRICTION
           SET START_DATE        =  trunc(:NEW.CHART_START_DATE, 'HH24'),
               END_DATE          =  trunc(:NEW.CHART_END_DATE, 'HH24'),
               OBJECT_ID         =  :NEW.OBJECT_ID,
               LAST_UPDATED_BY   =  :NEW.last_updated_by,
               REV_NO	           =  :NEW.rev_no,
               REV_TEXT          =  :NEW.rev_text,
               LAST_UPDATED_DATE =  :NEW.last_updated_date,
               RECORD_STATUS     =  :NEW.record_status
         WHERE START_DATE = :OLD.CHART_START_DATE
           AND OBJECT_ID = :OLD.OBJECT_ID;
    END IF;

  END IF;

END;
