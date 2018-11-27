CREATE OR REPLACE EDITIONABLE TRIGGER "IU_CONT_TRANSACTION_QTY" 
BEFORE INSERT OR UPDATE ON CONT_TRANSACTION_QTY
FOR EACH ROW


DECLARE
ln_sign NUMBER := 0;
BEGIN
    -- $Revision: 1.5 $
    -- Basis
    IF Inserting THEN
      :new.record_status := 'P';
      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;
      :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      :new.rev_no := 0;

    ELSE
    	 IF :New.last_updated_by = 'SYSTEM' THEN
          -- do not create new revision
          :New.last_updated_by := :Old.last_updated_by; -- set to old, assuming that this update is part of a sequence of updates
       ELSE
          :new.rev_no := :old.rev_no + 1;
       END IF;

       IF NOT UPDATING('LAST_UPDATED_BY') THEN
          :new.last_updated_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
       END IF;

       IF NOT UPDATING('LAST_UPDATED_DATE') THEN
             :new.last_updated_date := Ecdp_Timestamp.getCurrentSysdate;
       END IF;
    END IF;

END;
