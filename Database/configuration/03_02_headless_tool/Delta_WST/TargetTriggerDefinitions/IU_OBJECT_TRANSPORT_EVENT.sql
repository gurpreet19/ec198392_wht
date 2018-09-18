CREATE OR REPLACE TRIGGER "IU_OBJECT_TRANSPORT_EVENT" 
BEFORE INSERT OR UPDATE ON object_transport_event
FOR EACH ROW

DECLARE

BEGIN
    -- $Revision: 1.3.12.2 $
    -- Common
    IF Inserting THEN
      :NEW.record_status := NVL(:NEW.record_status,'P');

      IF :new.event_no IS NULL THEN

         EcDp_System_Key.assignNextNumber('STRM_TRANSPORT_EVENT', :new.event_no);

      END IF;

      IF :NEW.production_day IS NULL THEN

         :NEW.production_day := EcDp_ProductionDay.getProductionDay(:NEW.object_type,:NEW.object_id,:NEW.daytime);

      END IF;

      IF :new.created_by IS NULL THEN
         :new.created_by := User;
      END IF;

      IF :new.created_date IS NULL THEN
         :new.created_date := EcDp_Date_Time.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;
    ELSE
	  IF UPDATING('DAYTIME') THEN
         :new.production_day := EcDp_ProductionDay.getProductionDay(:NEW.object_type,:NEW.object_id,:NEW.daytime);
      END IF;

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

