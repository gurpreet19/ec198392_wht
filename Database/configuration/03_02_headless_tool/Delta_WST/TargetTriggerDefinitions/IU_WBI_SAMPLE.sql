CREATE OR REPLACE TRIGGER "IU_WBI_SAMPLE" 
BEFORE INSERT OR UPDATE ON WBI_SAMPLE
FOR EACH ROW

DECLARE

  CURSOR c_get_well(cp_wbi_object_id VARCHAR2) IS
    SELECT w.object_id
      FROM webo_interval wbi, webo_bore wb, well w
     WHERE wbi.well_bore_id = wb.object_id AND wb.well_id = w.object_id AND
           wbi.object_id = cp_wbi_object_id;

	lv_pday_object_id VARCHAR2(32);

BEGIN
  -- $Revision: 1.6 $
  -- Common
  IF Inserting THEN

  	lv_pday_object_id := EcDp_ProductionDay.findProductionDayDefinition(NULL, :new.object_id, :new.daytime);

    IF EcDp_Date_Time.interceptsWinterAndSummerTime(:NEW.daytime, lv_pday_object_id) = 'N' OR :NEW.summer_time IS NULL THEN
       :new.summer_time := EcDp_Date_Time.summertime_flag(:NEW.daytime, NULL, lv_pday_object_id);
    END IF;

    IF :NEW.production_day IS NULL THEN

      FOR cur_rec IN c_get_well(:NEW.object_id) LOOP

        :new.production_day := EcDp_ProductionDay.getProductionDay('WELL',cur_rec.object_id, :NEW.daytime, :NEW.summer_time);

      END LOOP;

    END IF;

    :NEW.record_status := NVL(:NEW.record_status,'P');
   :new.dayhr :=trunc(:new.daytime,'HH24');
    IF :new.created_by IS NULL THEN
      :new.created_by := User;
    END IF;
    IF :new.created_date IS NULL THEN
      :new.created_date := EcDp_Date_Time.getCurrentSysdate;
    END IF;
    :new.rev_no := 0;
  ELSE
    IF Nvl(:new.record_status, 'P') = Nvl(:old.record_status, 'P') THEN
      IF NOT UPDATING('LAST_UPDATED_BY') THEN
        :new.last_updated_by := User;
      END IF;
      IF NOT UPDATING('LAST_UPDATED_DATE') THEN
        :new.last_updated_date := EcDp_Date_Time.getCurrentSysdate;
      END IF;
    END IF;
  END IF;
END;

