CREATE OR REPLACE EDITIONABLE TRIGGER "IU_FCTY_ASSET_ANALYSIS" 
BEFORE INSERT OR UPDATE ON FCTY_ASSET_ANALYSIS
FOR EACH ROW
BEGIN
    -- Common
    IF Inserting THEN
      :new.record_status := nvl(:new.record_status, 'P');

       IF :new.daytime IS NULL THEN
         IF :new.sample_daytime IS NOT NULL THEN
            :new.daytime := :new.sample_daytime;
         END IF;
       END IF;

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
