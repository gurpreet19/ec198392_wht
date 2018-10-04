CREATE OR REPLACE TRIGGER "IU_T_BASIS_OBJECT" 
BEFORE INSERT OR UPDATE ON T_BASIS_OBJECT
FOR EACH ROW
BEGIN
    -- $Revision: 1.9 $
    -- Common
    IF Inserting THEN
      :NEW.record_status := NVL(:NEW.record_status,'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := User;
      END IF;

      IF :NEW.object_id IS NULL THEN

         EcDp_System_key.assignNextNumber('T_BASIS_OBJECT',:NEW.object_id);

      END IF;


      IF :new.created_date IS NULL THEN
         :new.created_date := EcDp_Date_Time.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;
    ELSE
      IF Nvl(:new.record_status,'P') = Nvl(:old.record_status,'P') THEN
         IF NOT UPDATING('LAST_UPDATED_BY') THEN
            :new.last_updated_by := User;
         END IF;
         IF NOT UPDATING('LAST_UPDATED_DATE') THEN
           :new.last_updated_date := EcDp_Date_Time.getCurrentSysdate;
         END IF;



      END IF;
    END IF;
END;

