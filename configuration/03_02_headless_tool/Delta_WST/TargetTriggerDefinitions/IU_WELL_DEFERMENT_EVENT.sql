CREATE OR REPLACE TRIGGER "IU_WELL_DEFERMENT_EVENT" 
BEFORE INSERT OR UPDATE ON well_deferment_event
FOR EACH ROW
DECLARE
	lv_pday_object_id  VARCHAR2(32);
BEGIN
    -- $Revision: 1.10 $
    -- Common
    IF Inserting THEN

    	lv_pday_object_id := EcDp_ProductionDay.findProductionDayDefinition(NULL, :NEW.object_id, :NEW.daytime);

      :NEW.record_status := NVL(:NEW.record_status,'P');

      IF :NEW.day IS NULL THEN
         :new.day := EcDp_ProductionDay.getProductionDay('WELL',:NEW.object_id, :NEW.daytime, :NEW.summer_time);
      END IF;

      IF :NEW.summer_time IS NULL THEN
         :new.summer_time := ecdp_date_time.summertime_flag(:NEW.daytime, NULL, lv_pday_object_id);
      END IF;

      IF :NEW.end_day IS NULL AND :NEW.end_date IS NOT NULL THEN
         :new.end_day := EcDp_ProductionDay.getProductionDay('WELL',:NEW.object_id, :NEW.end_date, :NEW.summer_time);
      END IF;

      IF :new.wde_no IS NULL THEN
         EcDp_System_Key.assignNextNumber('WELL_DEFERMENT_EVENT', :new.wde_no);
      END IF;

      IF :new.created_by IS NULL THEN
         :new.created_by := User;
      END IF;

      IF :new.created_date IS NULL THEN
         :new.created_date := EcDp_Date_Time.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;
    ELSE
      IF UPDATING('DAYTIME') OR UPDATING('SUMMER_TIME') THEN
         :new.day := EcDp_ProductionDay.getProductionDay('WELL',:NEW.object_id, :NEW.daytime, :NEW.summer_time);
      END IF;

      IF UPDATING('END_DATE') THEN
         IF :NEW.end_date IS NOT NULL THEN
            :new.end_day := EcDp_ProductionDay.getProductionDay('WELL',:NEW.object_id, :NEW.end_date);
         ELSE
            :new.end_day := null;
         END IF;
      END IF;

      IF UPDATING('DAYTIME') AND :new.DAYTIME > NVL(:old.DAYTIME, :new.DAYTIME + 1) THEN
         DELETE WELL_DAY_DEFERMENT_ALLOC T WHERE T.WDE_NO=:new.WDE_NO and t.object_id = :new.OBJECT_ID
                and DAYTIME < :new.DAY;
      END IF;

      IF UPDATING('END_DATE') AND :new.END_DATE < NVL(:old.END_DATE, :new.END_DATE + 1) THEN
        DELETE WELL_DAY_DEFERMENT_ALLOC T WHERE T.WDE_NO=:new.WDE_NO and t.object_id = :new.OBJECT_ID
               and DAYTIME >= :new.END_DAY;
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

