CREATE OR REPLACE TRIGGER "IU_PRICE_INDEX_SUB_DAY_VALUE" 
BEFORE INSERT OR UPDATE ON PRICE_INDEX_SUB_DAY_VALUE
FOR EACH ROW

BEGIN
    -- Common
    IF Inserting THEN

      IF EcDp_Date_Time.interceptsWinterAndSummerTime(:NEW.daytime) = 'N' OR :NEW.summer_time IS NULL THEN
        :new.summer_time := EcDp_Date_Time.summertime_flag(:NEW.daytime);
      END IF;

      IF :new.production_day IS NULL THEN
         :new.production_day := EcDp_ContractDay.getProductionDay(NULL,:NEW.object_id, :NEW.daytime);
      END IF;

      :new.record_status := nvl(:new.record_status, 'P');
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

