CREATE OR REPLACE EDITIONABLE TRIGGER "IU_STIM_MTH_REPORTED" 
BEFORE INSERT OR UPDATE ON STIM_MTH_REPORTED
FOR EACH ROW

DECLARE

BEGIN
    -- $Revision: 1.4 $
    -- Basis
    IF Inserting THEN

       :new.year := to_char(:new.daytime,'yyyy');
       :new.month_no := to_char(:new.daytime,'yyyy/mm');

      :new.record_status := 'P';
      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;
      :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      :new.rev_no := 0;

    ELSE

    	 IF :New.last_updated_by <> 'REPLICATE' THEN


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



      ELSE  -- :New.last_updated_by = 'REPLICATE'

         :New.last_updated_by := :Old.last_updated_by; -- set to old, do not want to change this when replicating code values

       END IF; -- :New.last_updated_by <> 'REPLICATE'


    END IF;

     -- YTD Update
      -- initialise first one first time use
      IF EcTrgPck_stim_mth_reported.ptab IS NULL THEN

         EcTrgPck_stim_mth_reported.ptab := EcTrgPck_stim_mth_reported.t_tab();

      END IF;

      EcTrgPck_stim_mth_reported.ptab.EXTEND;
      EcTrgPck_stim_mth_reported.ptab(EcTrgPck_stim_mth_reported.ptab.LAST).object_id := :New.object_id;
      EcTrgPck_stim_mth_reported.ptab(EcTrgPck_stim_mth_reported.ptab.LAST).daytime := :New.daytime;
      EcTrgPck_stim_mth_reported.ptab(EcTrgPck_stim_mth_reported.ptab.LAST).production_period := :New.production_period;

END;
