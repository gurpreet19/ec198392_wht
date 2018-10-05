CREATE OR REPLACE EDITIONABLE TRIGGER "IU_BF_COMPONENT_ACTION" 
BEFORE INSERT OR UPDATE ON BF_COMPONENT_ACTION
FOR EACH ROW
BEGIN
    -- $Revision: 1.2 $
    -- Common
    IF Inserting THEN

      IF :NEW.BF_COMPONENT_ACTION_NO IS NULL THEN

          EcDp_System_Key.assignNextNumber('BF_COMPONENT_ACTION', :new.BF_COMPONENT_ACTION_NO);

      END IF;


      :new.record_status := 'P';
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
