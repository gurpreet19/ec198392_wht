CREATE OR REPLACE EDITIONABLE TRIGGER "IU_FLOWLINE_SUB_WELL_CONN" 
BEFORE INSERT OR UPDATE ON FLOWLINE_SUB_WELL_CONN
FOR EACH ROW
DECLARE
BEGIN
  -- Basis
  IF Inserting THEN
    :new.record_status := nvl(:new.record_status, 'P');
    IF :new.created_by IS NULL THEN
       :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
    END IF;
    IF :new.created_date IS NULL THEN
       :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
    END IF;
    :new.rev_no := 0;
    :new.PRODUCTION_DAY := EcDp_ProductionDay.getProductionDay('FLOWLINE', :new.OBJECT_ID, :new.DAYTIME, NULL);
    IF :new.END_DATE IS NOT NULL THEN
      :new.PRODUCTION_DAY_END := EcDp_ProductionDay.getProductionDay('FLOWLINE', :new.OBJECT_ID, :new.END_DATE, NULL);
    END IF;
  ELSE
    IF :new.END_DATE <> :old.END_DATE OR
      :new.END_DATE IS NOT NULL and :old.END_DATE IS NULL THEN
      IF :new.END_DATE IS NOT NULL THEN
        :new.PRODUCTION_DAY_END := EcDp_ProductionDay.getProductionDay('FLOWLINE', :new.OBJECT_ID, :new.END_DATE, NULL);
      END IF;
    END IF;
    IF :new.END_DATE IS NULL THEN
      :new.PRODUCTION_DAY_END  := NULL;
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
