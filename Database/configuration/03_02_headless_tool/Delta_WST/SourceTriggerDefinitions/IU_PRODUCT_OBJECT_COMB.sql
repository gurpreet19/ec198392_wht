CREATE OR REPLACE EDITIONABLE TRIGGER "IU_PRODUCT_OBJECT_COMB" 
BEFORE INSERT OR UPDATE ON PRODUCT_OBJECT_COMB
FOR EACH ROW
BEGIN

    -- $Revision: 1.11 $
    -- Common

    IF Inserting THEN

      :NEW.record_status := NVL(:NEW.record_status,'P');

      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;

      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;

      :new.rev_no := 0;

      IF :new.conn_object_id IS NULL THEN
         :NEW.conn_object_id := SYS_GUID();
      END IF;

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
