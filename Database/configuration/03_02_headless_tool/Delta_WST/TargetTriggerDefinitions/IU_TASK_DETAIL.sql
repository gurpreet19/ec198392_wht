CREATE OR REPLACE TRIGGER "IU_TASK_DETAIL" 
BEFORE INSERT OR UPDATE ON TASK_DETAIL
FOR EACH ROW

DECLARE

lv2_user VARCHAR2(30);

BEGIN
    -- $Revision: 1.2 $
    -- Common
    IF Inserting THEN
      :NEW.record_status := NVL(:NEW.record_status,'P');
      IF :new.created_by IS NULL THEN
         lv2_user := ecdp_context.getAppUser();
         IF lv2_user IS NOT NULL THEN
           :new.created_by := lv2_user;
         ELSE
           :new.created_by := User;
         END IF;
      END IF;

      IF :new.created_date IS NULL THEN
         :new.created_date := EcDp_Date_Time.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;
    ELSE
      IF Nvl(:new.record_status,'P') = Nvl(:old.record_status,'P') THEN
         IF NOT UPDATING('LAST_UPDATED_BY') THEN
           lv2_user := ecdp_context.getAppUser();
           IF lv2_user IS NOT NULL THEN
             :new.last_updated_by := lv2_user;
           ELSE
             :new.last_updated_by := User;
           END IF;
         END IF;
         IF NOT UPDATING('LAST_UPDATED_DATE') THEN
           :new.last_updated_date := EcDp_Date_Time.getCurrentSysdate;
         END IF;
      END IF;
    END IF;
END;

