CREATE OR REPLACE TRIGGER "IU_WELL_EVENT" 
BEFORE INSERT OR UPDATE ON well_event
FOR EACH ROW

DECLARE
  lv2_facility production_facility.object_id%TYPE;
  lv_pday_object_id VARCHAR2(32);
BEGIN
    -- $Revision: 1.5 $
    -- Basis
    IF Inserting THEN
      :NEW.record_status := NVL(:NEW.record_status,'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := User;
      END IF;

      IF :new.created_date IS NULL THEN
         :new.created_date := EcDp_Date_Time.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;

	  lv_pday_object_id := EcDp_ProductionDay.findProductionDayDefinition(NULL, :new.object_id, :new.daytime);

      IF EcDp_Date_Time.interceptsWinterAndSummerTime(:NEW.daytime, lv_pday_object_id) = 'N' OR :NEW.summer_time IS NULL THEN
         :new.summer_time := EcDp_Date_Time.summertime_flag(:NEW.daytime, NULL, lv_pday_object_id);
      END IF;

	  --setting rate_source for selected classes
      If :new.avg_inj_rate IS NOT NULL AND :new.event_type = 'IWEL_EVENT_GAS' THEN
	     :new.rate_source := 'MANUAL';
	  END IF;

	  If :new.avg_inj_rate IS NOT NULL AND :new.event_type = 'IWEL_EVENT_STEAM' THEN
	     :new.rate_source := 'MANUAL';
	  END IF;

	  If :new.avg_inj_rate IS NOT NULL AND :new.event_type = 'IWEL_EVENT_WATER' THEN
	     :new.rate_source := 'MANUAL';
	  END IF;

      IF :NEW.EVENT_DAY IS NULL THEN
        :NEW.EVENT_DAY := EcDp_ProductionDay.getProductionDay('WELL',:NEW.object_id,:NEW.daytime);
      END IF;


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

