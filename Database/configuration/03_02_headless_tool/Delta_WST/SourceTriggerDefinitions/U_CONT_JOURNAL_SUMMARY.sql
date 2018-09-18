CREATE OR REPLACE EDITIONABLE TRIGGER "U_CONT_JOURNAL_SUMMARY" 
 INSTEAD OF UPDATE ON V_CONT_JOURNAL_SUMMARY
 FOR EACH ROW

DECLARE

BEGIN

  IF Updating('FORECAST_AMOUNT') OR Updating('FORECAST_QTY_1') OR Updating('COMMENTS') THEN

     UPDATE CONT_JOURNAL_SUMMARY js
            SET js.forecast_amount = :New.FORECAST_AMOUNT,
                js.forecast_qty_1  = :New.FORECAST_QTY_1,
                js.comments        = :New.COMMENTS
      WHERE js.object_id = :New.OBJECT_ID
        AND js.period = :New.period
        AND js.document_key = :New.Document_key
        AND js.summary_setup_id = :New.summary_setup_id
        AND js.tag = :New.tag;

  END IF;

END;
