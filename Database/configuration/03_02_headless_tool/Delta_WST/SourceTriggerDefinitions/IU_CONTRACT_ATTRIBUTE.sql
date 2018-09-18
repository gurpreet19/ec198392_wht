CREATE OR REPLACE EDITIONABLE TRIGGER "IU_CONTRACT_ATTRIBUTE" 
BEFORE INSERT OR UPDATE ON CONTRACT_ATTRIBUTE
FOR EACH ROW

DECLARE

  CURSOR c_attr_timescope IS
  SELECT TIME_SPAN, c.start_year, c.start_date
  FROM CONTRACT C, CNTR_TEMPLATE_ATTRIBUTE CTA
  WHERE c.TEMPLATE_CODE = CTA.TEMPLATE_CODE
  AND   c.object_id = :NEW.OBJECT_ID
  AND   cta.ATTRIBUTE_NAME = :NEW.ATTRIBUTE_NAME ;

  lv2_timescope CNTR_TEMPLATE_ATTRIBUTE.TIME_SPAN%TYPE;
  ln_yearoffset  NUMBER;
  ld_cont_start DATE;
  ld_first_year_start DATE;


BEGIN

    -- Logic to truncate daytime in accordance with attribute timscope code
    FOR c_tsc IN c_attr_timescope LOOP
      lv2_timescope := c_tsc.TIME_SPAN;
      ln_yearoffset := c_tsc.start_year;
      ld_cont_start := c_tsc.start_date;
    END LOOP;

    IF lv2_timescope = 'DAY' THEN

       :new.daytime := TRUNC(:new.daytime,'DD');

    ELSIF lv2_timescope = 'YR' THEN

       :new.daytime := TRUNC(:new.daytime,'YEAR');

    ELSIF lv2_timescope = 'MTH' THEN
       :new.daytime := TRUNC(:new.daytime,'MONTH');
    END IF;


    IF Inserting THEN
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
