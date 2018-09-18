CREATE OR REPLACE EDITIONABLE TRIGGER "IU_STIM_DAY_ACTUAL" 
BEFORE INSERT OR UPDATE ON STIM_DAY_ACTUAL
FOR EACH ROW

DECLARE

BEGIN
    -- $Revision: 1.3 $
    -- Basis
    IF Inserting THEN
      :new.record_status := 'P';

      :new.year := to_char(:new.daytime,'yyyy');
      :new.month_no := to_char(:new.daytime,'yyyy/mm');


      -- Replicated code values


      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;
      :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      :new.rev_no := 0;

    ELSE


	   IF :New.last_updated_by != 'REPLICATE' THEN -- No trigger logic when replicating code values


       	 IF :New.last_updated_by = 'SYSTEM' THEN
             -- do not create new revision
             :New.last_updated_by := :Old.last_updated_by; -- set to old, assuming that this update is part of a sequence of updates
          ELSE
             :new.rev_no := :old.rev_no + 1;
          END IF;

          IF NOT UPDATING('LAST_UPDATED_BY') THEN
             :new.last_updated_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
          END IF;

         IF  NOT UPDATING('LAST_UPDATED_DATE') THEN
            :new.last_updated_date := Ecdp_Timestamp.getCurrentSysdate;
         END IF;

       ELSE -- :New.last_updated_by = 'REPLICATE'

          :New.last_updated_by := :Old.last_updated_by; -- set to old, do not want to change this when replicating code values

       END IF; -- :New.last_updated_by != 'REPLICATE'


    END IF;
END;
