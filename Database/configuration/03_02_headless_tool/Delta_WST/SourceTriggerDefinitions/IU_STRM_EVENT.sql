CREATE OR REPLACE EDITIONABLE TRIGGER "IU_STRM_EVENT" 
BEFORE INSERT OR UPDATE ON strm_event
FOR EACH ROW

DECLARE
  lv2_facility production_facility.object_id%TYPE;

BEGIN
    -- $Revision: 1.7 $
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

      IF :NEW.EVENT_DAY IS NULL AND :new.event_type <> 'TANK_DUAL_DIP' THEN  -- The list here is not complete

         :NEW.EVENT_DAY := EcDp_ProductionDay.getProductionDay('STREAM',:NEW.object_id,:NEW.daytime);

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
