CREATE OR REPLACE EDITIONABLE TRIGGER "IUD_V_CARGO_BERTH_CHART" 
  INSTEAD OF INSERT OR UPDATE OR DELETE ON V_CARGO_BERTH_CHART
  FOR EACH ROW

  -- $Revision: 1.0 $
  -- Common

BEGIN

  IF UPDATING THEN

    IF (:OLD.CLASS = 'STORAGE_LIFT_NOM_SCHED') THEN
        UPDATE STORAGE_LIFT_NOMINATION
           SET nom_firm_date     = :NEW.CHART_START_DATE,
               start_lifting_date= :NEW.CHART_START_DATE,
               rev_no            = :NEW.rev_no,
               rev_text          = :NEW.rev_text,
               record_status     = :NEW.record_status
         WHERE nom_firm_date = :OLD.CHART_START_DATE
           AND parcel_no = :OLD.PARCEL_NO;

        UPDATE CARGO_TRANSPORT
           SET BERTH_ID          = :NEW.OBJECT_ID,
               rev_no            = :NEW.rev_no,
               rev_text          = :NEW.rev_text,
               record_status     = :NEW.record_status
         WHERE CARGO_NO = :OLD.CARGO_NO;

    ELSIF (:OLD.CLASS = 'OPRES_PERIOD_RESTRICTION') THEN
        UPDATE OPLOC_PERIOD_RESTRICTION
           SET START_DATE        = :NEW.CHART_START_DATE,
               END_DATE          = :NEW.CHART_END_DATE,
               OBJECT_ID         = :NEW.OBJECT_ID,
               rev_no            = :NEW.rev_no,
               rev_text          = :NEW.rev_text,
               record_status     = :NEW.record_status
         WHERE START_DATE = :OLD.CHART_START_DATE
           AND OBJECT_ID = :OLD.OBJECT_ID;
     END IF;

  END IF;

END;
