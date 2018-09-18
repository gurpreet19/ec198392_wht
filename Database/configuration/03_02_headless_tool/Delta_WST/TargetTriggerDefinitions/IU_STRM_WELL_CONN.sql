CREATE OR REPLACE TRIGGER "IU_STRM_WELL_CONN" 
BEFORE INSERT OR UPDATE ON STRM_WELL_CONN
FOR EACH ROW
DECLARE
lc_pday_object_id  VARCHAR2(32);

BEGIN
  -- Common
  lc_pday_object_id := EcDp_ProductionDay.findProductionDayDefinition(NULL, :new.OBJECT_ID, :new.DAYTIME);

  IF Inserting THEN

    :new.record_status := 'P';
    IF :new.created_by IS NULL THEN
       :new.created_by := User;
    END IF;
    IF :new.created_date IS NULL THEN
       :new.created_date := EcDp_Date_Time.getCurrentSysdate;
    END IF;
    :new.rev_no := 0;

    -- summertime flag can be set by the client
    IF :new.SUMMERTIME_DAYTIME IS NULL THEN
      -- calculate summertime flag if its null from client.
      :new.SUMMERTIME_DAYTIME := ecdp_date_time.summertime_flag(ecdp_date_time.local2utc(:new.DAYTIME, NULL, lc_pday_object_id), NULL, lc_pday_object_id);
    END IF;
    :new.PRODUCTION_DAY := EcDp_ProductionDay.getProductionDay('STREAM', :new.OBJECT_ID, :new.DAYTIME, :new.SUMMERTIME_DAYTIME);


    IF (:new.END_DATE IS NOT NULL AND :new.SUMMERTIME_END_DATE IS NULL) THEN
      :new.SUMMERTIME_END_DATE := ecdp_date_time.summertime_flag(ecdp_date_time.local2utc(:new.END_DATE, NULL, lc_pday_object_id), NULL, lc_pday_object_id);
      :new.PRODUCTION_DAY_END := EcDp_ProductionDay.getProductionDay('STREAM', :new.OBJECT_ID, :new.END_DATE, :new.SUMMERTIME_END_DATE);
    END IF;

  ELSE

    IF (:new.END_DATE <> :old.END_DATE OR
       (:new.end_date IS NOT NULL and :old.END_DATE IS NULL) OR
        :new.SUMMERTIME_END_DATE IS NULL OR
        :new.SUMMERTIME_DAYTIME IS NULL) THEN

      IF :new.SUMMERTIME_END_DATE IS NULL and :new.END_DATE IS NOT NULL THEN
        :new.SUMMERTIME_END_DATE := ecdp_date_time.summertime_flag(ecdp_date_time.local2utc(:new.END_DATE, NULL, lc_pday_object_id), NULL, lc_pday_object_id);
        :new.PRODUCTION_DAY_END := EcDp_ProductionDay.getProductionDay('STREAM', :new.OBJECT_ID, :new.END_DATE, :new.SUMMERTIME_END_DATE);
      END IF;

      IF :new.SUMMERTIME_DAYTIME IS NULL THEN
      	lc_pday_object_id := EcDp_ProductionDay.findProductionDayDefinition(NULL, :NEW.OBJECT_ID, :old.DAYTIME);
        :new.SUMMERTIME_DAYTIME := ecdp_date_time.summertime_flag(ecdp_date_time.local2utc(:old.DAYTIME, NULL, lc_pday_object_id), NULL, lc_pday_object_id);
      END IF;

    END IF;

    IF :new.END_DATE IS NULL THEN
      :new.SUMMERTIME_END_DATE := NULL;
      :new.PRODUCTION_DAY_END  := NULL;
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

