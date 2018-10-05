CREATE OR REPLACE EDITIONABLE TRIGGER "IUD_V_TRNP_DAY_NOM_PATH_MATRIX" 
  INSTEAD OF INSERT OR UPDATE OR DELETE ON V_TRNP_DAY_NOM_PATH_MATRIX
  FOR EACH ROW

  -- $Revision: 1.1 $
  -- $Author: Sandeep Thote

DECLARE
BEGIN

  IF UPDATING AND :NEW.REQUESTED_QTY <> :OLD.REQUESTED_QTY THEN
    UPDATE NOMPNT_NP_DAY_NOMINATION
       SET REQUESTED_QTY     = :NEW.REQUESTED_QTY,
           LAST_UPDATED_BY   = :NEW.last_updated_by,
           REV_NO	           = :NEW.rev_no,
           REV_TEXT          = :NEW.rev_text,
           LAST_UPDATED_DATE = :NEW.last_updated_date,
           RECORD_STATUS     = :NEW.record_status
     WHERE OBJECT_ID = :NEW.OBJECT_ID
       AND DAYTIME = :NEW.DAYTIME
       AND TO_NOMPNT_ID = :NEW.TO_NOMPNT_ID;
  END IF;

END;
