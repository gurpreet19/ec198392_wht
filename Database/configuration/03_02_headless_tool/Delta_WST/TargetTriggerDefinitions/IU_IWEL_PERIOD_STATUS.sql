CREATE OR REPLACE TRIGGER "IU_IWEL_PERIOD_STATUS" 
BEFORE INSERT OR UPDATE ON IWEL_PERIOD_STATUS
FOR EACH ROW
DECLARE
lr_well well%ROWTYPE;
lv_pday_object_id VARCHAR2(32);
BEGIN
    -- $Revision: 1.14 $
    -- Common
    IF Inserting THEN

			lv_pday_object_id := EcDp_ProductionDay.findProductionDayDefinition(NULL, :new.object_id, :new.daytime);

      :NEW.record_status := NVL(:NEW.record_status,'P');

      IF :new.created_by IS NULL THEN
         :new.created_by := User;
      END IF;
      IF :new.created_date IS NULL THEN
         :new.created_date := EcDp_Date_Time.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;

      IF EcDp_Date_Time.interceptsWinterAndSummerTime(:NEW.daytime, lv_pday_object_id) = 'N' OR :NEW.summer_time IS NULL THEN
         :new.summer_time := EcDp_Date_Time.summertime_flag(:NEW.daytime, NULL, lv_pday_object_id);
      END IF;

      IF :NEW.day IS NULL THEN
         :new.day := EcDp_ProductionDay.getProductionDay('WELL',:NEW.object_id, :NEW.daytime, :NEW.summer_time);
      END IF;

      IF :NEW.active_well_status IS NULL THEN
         :NEW.active_well_status := EcDp_System.getDependentCode('ACTIVE_WELL_STATUS', 'WELL_STATUS', :NEW.well_status);
      END IF;

      IF :NEW.active_well_status <> 'OPEN' THEN
        IF EcDp_Well.IsDeferred(:NEW.object_id, :NEW.daytime) = 'Y' THEN
          Raise_Application_Error('-20000', 'Well is deferred, not allowed to perform operation.');
        END IF;
      END IF;

    ELSIF Updating('WELL_STATUS') THEN
      :NEW.active_well_status := EcDp_System.getDependentCode('ACTIVE_WELL_STATUS', 'WELL_STATUS', :NEW.well_status);

      IF :NEW.active_well_status <> 'OPEN' THEN
        IF EcDp_Well.IsDeferred(:NEW.object_id, :NEW.daytime) = 'Y' THEN
          Raise_Application_Error('-20000', 'Well is deferred, not allowed to perform operation.');
        END IF;
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

