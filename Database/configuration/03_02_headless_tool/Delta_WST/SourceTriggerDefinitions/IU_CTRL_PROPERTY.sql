CREATE OR REPLACE EDITIONABLE TRIGGER "IU_CTRL_PROPERTY" 
BEFORE INSERT OR UPDATE ON ctrl_property
FOR EACH ROW
BEGIN
    -- $Revision: 1.2 $
    -- Common
    IF Inserting THEN
      :NEW.record_status := NVL(:NEW.record_status,'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;

      IF :NEW.property_no IS NULL THEN

         EcDp_System_key.assignNextNumber('CTRL_PROPERTY',:NEW.property_no);

      END IF;


      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;
    END IF;
END;
