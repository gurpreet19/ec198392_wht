CREATE OR REPLACE EDITIONABLE TRIGGER "UD_V_CARGO_DOCUMENT" 
 INSTEAD OF DELETE OR UPDATE ON v_cargo_document
FOR EACH ROW
-- $Revision: 1.2 $
-- $Author: kallesve
DECLARE

BEGIN

  IF UPDATING THEN
    NULL;
  END IF;

  IF DELETING THEN
    IF :old.PARCEL_NO is not null THEN --Got a ref. to Parcel?
      IF :old.UPLOAD = 'Y' then --Is the document uploaded?
        -- Deleting an uploaded parcel level document
        DELETE cargo_document
         WHERE CARGO_DOCUMENT_NO = :old.REPORT_NO
           AND PARCEL_NO = :old.PARCEL_NO
           AND CARGO_NO is null;
      ELSE
        -- Deleting a generated parcel level document
        DELETE report_param WHERE REPORT_NO = :old.REPORT_NO;
        DELETE report WHERE REPORT_NO = :old.REPORT_NO;
      END IF;
    ELSE
      -- Deleting a cargo level document
      DELETE cargo_document
       WHERE CARGO_DOCUMENT_NO = :old.REPORT_NO
         AND PARCEL_NO is null;
    END IF;
  END IF;
END;
