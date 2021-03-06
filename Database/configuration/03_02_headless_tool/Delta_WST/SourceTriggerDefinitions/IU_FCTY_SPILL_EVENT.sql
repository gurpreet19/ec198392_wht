CREATE OR REPLACE EDITIONABLE TRIGGER "IU_FCTY_SPILL_EVENT" 
BEFORE INSERT OR UPDATE ON FCTY_SPILL_EVENT
FOR EACH ROW
DECLARE
lr_facility production_facility%ROWTYPE;
BEGIN
    -- $Revision: 1.7 $
    -- Common
    IF Inserting THEN

      IF :NEW.production_day IS NULL THEN
         :new.production_day := EcDp_ProductionDay.getProductionDay('FCTY_CLASS_1',:NEW.object_id, :NEW.daytime);
      END IF;

      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;

      :NEW.record_status := NVL(:NEW.record_status,'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
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
