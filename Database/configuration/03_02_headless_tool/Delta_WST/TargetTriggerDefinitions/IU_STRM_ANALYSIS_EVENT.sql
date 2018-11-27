CREATE OR REPLACE TRIGGER "IU_STRM_ANALYSIS_EVENT" 
BEFORE INSERT OR UPDATE ON strm_analysis_event
FOR EACH ROW
DECLARE
	lv_pday_object_id VARCHAR2(32);
BEGIN
    -- $Revision: 1.5 $
    -- Common
    IF Inserting THEN

    	lv_pday_object_id := EcDp_ProductionDay.findProductionDayDefinition(NULL, :new.object_id, :new.daytime);

      :NEW.record_status := NVL(:NEW.record_status,'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := User;
      END IF;

      IF :NEW.production_day IS NULL THEN
		 		:new.production_day := EcDp_ProductionDay.getProductionDay(NULL,:NEW.object_id, :NEW.daytime);
      END IF;

      IF EcDp_Date_Time.interceptsWinterAndSummerTime(:NEW.daytime, lv_pday_object_id) = 'N' OR :NEW.daytime_summer_time IS NULL THEN
         :new.daytime_summer_time := EcDp_Date_Time.summertime_flag(:NEW.daytime, NULL, lv_pday_object_id);
      END IF;

      IF EcDp_Date_Time.interceptsWinterAndSummerTime(:NEW.valid_from_date, lv_pday_object_id) = 'N' OR :NEW.valid_from_summer_time IS NULL THEN
         :new.valid_from_summer_time := EcDp_Date_Time.summertime_flag(:NEW.valid_from_date, NULL, lv_pday_object_id);
      END IF;

      IF EcDp_Date_Time.interceptsWinterAndSummerTime(:NEW.valid_to_date, lv_pday_object_id) = 'N' OR :NEW.valid_to_summer_time IS NULL THEN
         :new.valid_to_summer_time := EcDp_Date_Time.summertime_flag(:NEW.valid_to_date, NULL, lv_pday_object_id);
      END IF;


      IF :new.analysis_no IS NULL THEN

         EcDp_System_Key.assignNextNumber('STRM_ANALYSIS_EVENT', :new.analysis_no);

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

