CREATE OR REPLACE EDITIONABLE TRIGGER "IU_PRODUCTION_DAY_VERSION" 
BEFORE INSERT OR UPDATE ON PRODUCTION_DAY_VERSION
FOR EACH ROW
DECLARE
  ln_offset  NUMBER;
BEGIN
    -- Common
    -- $Revision: 1.2 $
    IF not Deleting THEN  -- validate Offset

      -- Expect an offset on the format '06:00' or '-02:00

      ln_offset := ecdp_timestamp_utils.timeOffsetToHrs(:NEW.offset);

      IF ln_offset IS NULL THEN
        RAISE_APPLICATION_ERROR(-20000,'ProductionDay offset must be a valid timestamp on the format ''hh:mi'' or ''-hh:mi''.');
      END IF;

      :NEW.production_day_offset_hrs := ln_offset;
    END IF;

    IF Inserting THEN
      :new.daytime := trunc(:new.daytime,'DD');
      :NEW.record_status := NVL(:NEW.record_status,'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;
      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
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
