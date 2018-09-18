CREATE OR REPLACE EDITIONABLE TRIGGER "IU_CNTR_ATTR_DIMENSION" 
  BEFORE INSERT OR UPDATE ON CNTR_ATTR_DIMENSION
  FOR EACH ROW
DECLARE
  lv_max_daytime DATE;
BEGIN
  -- Basis
  IF Inserting THEN
    SELECT MAX(DAYTIME)
      INTO lv_max_daytime
      FROM CNTR_ATTR_DIMENSION
     WHERE OBJECT_ID = :NEW.OBJECT_ID
       AND ATTRIBUTE_NAME = :NEW.ATTRIBUTE_NAME
       AND DIM_CODE = :NEW.DIM_CODE;

    :new.record_status := nvl(:new.record_status, 'P');
    IF :NEW.DAYTIME < lv_max_daytime THEN
      :NEW.END_DATE := lv_max_daytime;
    END IF;
    IF :new.created_by IS NULL THEN
      :new.created_by := COALESCE(SYS_CONTEXT('USERENV',
                                              'CLIENT_IDENTIFIER'),
                                  USER);
    END IF;
    IF :new.created_date IS NULL THEN
      :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
    END IF;
    :new.rev_no := 0;
  ELSE
    IF Nvl(:new.record_status, 'P') = Nvl(:old.record_status, 'P') THEN
      IF NOT UPDATING('LAST_UPDATED_BY') THEN
        :new.last_updated_by := COALESCE(SYS_CONTEXT('USERENV',
                                                     'CLIENT_IDENTIFIER'),
                                         USER);
      END IF;
      IF NOT UPDATING('LAST_UPDATED_DATE') THEN
        :new.last_updated_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;
    END IF;
  END IF;
END;
