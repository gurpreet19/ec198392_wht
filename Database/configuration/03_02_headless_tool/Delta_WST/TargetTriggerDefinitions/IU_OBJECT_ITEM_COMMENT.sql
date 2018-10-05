CREATE OR REPLACE TRIGGER "IU_OBJECT_ITEM_COMMENT" 
BEFORE INSERT OR UPDATE ON object_item_comment
FOR EACH ROW
BEGIN
    -- $Revision: 1.11 $
    -- COMMON
    IF Inserting THEN

      IF :NEW.production_day IS NULL THEN
         :new.production_day := Nvl(EcDp_ProductionDay.getProductionDay(:NEW.object_type, :NEW.object_id, :NEW.daytime), TRUNC(:NEW.daytime,'DD'));
      END IF;

      :NEW.record_status := NVL(:NEW.record_status,'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := User;
      END IF;

      IF :new.comment_id IS NULL THEN

          EcDp_System_Key.assignNextNumber('OBJECT_ITEM_COMMENT', :new.comment_id);

      END IF;

      IF :new.object_type IS NULL THEN
      	:new.object_type :=  ecdp_objects.getobjclassname(:new.object_id);
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

