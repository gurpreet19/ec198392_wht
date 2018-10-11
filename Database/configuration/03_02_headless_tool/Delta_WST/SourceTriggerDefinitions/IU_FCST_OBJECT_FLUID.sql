CREATE OR REPLACE EDITIONABLE TRIGGER "IU_FCST_OBJECT_FLUID" 
BEFORE INSERT OR UPDATE ON fcst_object_fluid
FOR EACH ROW
BEGIN
    -- $Revision: 1.0 $
    -- Common
    IF Inserting THEN
      :NEW.record_status := NVL(:NEW.record_status,'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;
     IF :new.analysis_no IS NULL THEN

         EcDp_System_Key.assignNextNumber('FCST_OBJECT_FLUID',:new.analysis_no);

      END IF;

     IF :NEW.production_day IS NULL THEN
        :new.production_day := EcDp_ProductionDay.getProductionDay(NULL,:NEW.object_id, :NEW.daytime);
     END IF;


     IF :NEW.object_class_name IS NULL THEN
        :NEW.object_class_name := Ecdp_Objects.GetObjClassName(:NEW.object_id);
     END IF;

	IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;
    ELSE

     IF :NEW.daytime <> :OLD.daytime THEN
         :new.production_day := Ecdp_Productionday.getProductionDay(NULL, :NEW.object_id, :NEW.daytime);
     END IF;

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