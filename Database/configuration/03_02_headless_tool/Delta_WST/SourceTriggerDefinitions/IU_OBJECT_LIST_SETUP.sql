CREATE OR REPLACE EDITIONABLE TRIGGER "IU_OBJECT_LIST_SETUP" 
BEFORE INSERT OR UPDATE ON OBJECT_LIST_SETUP
FOR EACH ROW
BEGIN
    -- Basis
    IF Inserting THEN
      :new.record_status := nvl(:new.record_status, 'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;
      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;
      :new.gen_rel_obj_code := nvl(:new.generic_object_code, 'NULL') || '$' || nvl(:new.relational_obj_code, 'NULL');
    ELSE
      IF Nvl(:new.record_status,'P') = Nvl(:old.record_status,'P') THEN
         IF NOT UPDATING('LAST_UPDATED_BY') THEN
            :new.last_updated_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
         END IF;
         IF NOT UPDATING('LAST_UPDATED_DATE') THEN
            :new.last_updated_date := Ecdp_Timestamp.getCurrentSysdate;
         END IF;
      END IF;
      IF UPDATING('GENERIC_OBJECT_CODE') OR UPDATING('RELATIONAL_OBJ_CODE') THEN
         :new.gen_rel_obj_code := nvl(:new.generic_object_code, 'NULL') || '$' || nvl(:new.relational_obj_code, 'NULL');
      END IF;
    END IF;
END;
