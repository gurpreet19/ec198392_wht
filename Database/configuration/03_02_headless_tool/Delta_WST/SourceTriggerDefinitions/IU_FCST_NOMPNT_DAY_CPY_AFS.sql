CREATE OR REPLACE EDITIONABLE TRIGGER "IU_FCST_NOMPNT_DAY_CPY_AFS" 
BEFORE INSERT OR UPDATE ON FCST_NOMPNT_DAY_CPY_AFS
FOR EACH ROW
BEGIN
	-- $Revision: 1.0 $
    -- Common
    IF Inserting THEN

	  -- Start : Manual code for primary key AFS_SEQ
      IF :new.AFS_SEQ IS NULL THEN
         EcDp_System_Key.assignNextNumber('FCST_NOMPNT_DAY_CPY_AFS', :new.AFS_SEQ);
      END IF;
      -- End : Manual code for primary key AFS_SEQ

      :new.daytime := trunc(:new.daytime,'DD');
      :new.record_status := nvl(:new.record_status, 'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;
      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;
    ELSE
      IF Nvl(:new.record_status,'P') = Nvl(:old.record_status,'P') THEN
         IF NOT UPDATING('LAST_UPDATED_BY') THEN
            :new.last_updated_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
         END IF;
         IF NOT UPDATING('LAST_UPDATED_DATE') THEN
           :new.last_updated_date := Ecdp_Timestamp.getCurrentSysdate;
         END IF;
      END IF;
    END IF;
END;
