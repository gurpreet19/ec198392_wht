CREATE OR REPLACE TRIGGER "IU_PRODUCTION_DAY_VERSION" 
BEFORE INSERT OR UPDATE ON PRODUCTION_DAY_VERSION
FOR EACH ROW

DECLARE
  lv2_offset VARCHAR2(10);
  ln_offset  NUMBER;

BEGIN


    -- Common
    -- $Revision: 1.2 $
    IF not Deleting THEN  -- validate Offset

      -- Expect an offset on the format '06:00' or '-02:00

      lv2_offset := :NEW.offset;


      IF(SUBSTR(lv2_offset,1,1)= '-') THEN

          lv2_offset := SUBSTR(lv2_offset,2);

      END IF;

      IF SUBSTR(lv2_offset,3,1) = ':' THEN

        ln_offset  := TO_NUMBER(SUBSTR(lv2_offset,1,2));
        IF ln_offset > 23 OR ln_offset < 0 THEN

            RAISE_APPLICATION_ERROR(-20000,'ProductionDay offset hours must be between 0 and 23.');

        END IF;

        ln_offset  := TO_NUMBER(SUBSTR(lv2_offset,4,2));
        IF ln_offset > 59 OR ln_offset < 0 THEN

            RAISE_APPLICATION_ERROR(-20000,'ProductionDay offset minutes must be between 0 and 59.');

        END IF;


      ELSE

        RAISE_APPLICATION_ERROR(-20000,'ProductionDay offset must be on the format ''hh:mi'' or ''-hh:mi'' .');


      END IF;



    END IF;

    IF Inserting THEN
      :new.daytime := trunc(:new.daytime,'DD');
      :NEW.record_status := NVL(:NEW.record_status,'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := User;
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

