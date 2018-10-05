CREATE OR REPLACE TRIGGER "IU_LIFT_ACC_SUB_DAY_OFFICIAL" 
BEFORE INSERT OR UPDATE ON LIFT_ACC_SUB_DAY_OFFICIAL
FOR EACH ROW
DECLARE
    lv_pday_object_id VARCHAR2(32);
BEGIN
    -- $Revision: 1.1 $
    -- Common
    IF Inserting THEN
        lv_pday_object_id := EcDp_ProductionDay.findProductionDayDefinition(NULL, ec_lifting_account.storage_id(:new.object_id), :new.daytime);

        IF EcDp_Date_Time.interceptsWinterAndSummerTime(:NEW.daytime, lv_pday_object_id) = 'N' OR
           :NEW.summer_time IS NULL THEN
            :new.summer_time := EcDp_Date_Time.summertime_flag(:NEW.daytime, NULL, lv_pday_object_id);
        END IF;

        IF :new.production_day IS NULL THEN
            :new.production_day := EcDp_ProductionDay.getProductionDay('STORAGE',
                                                                       ec_lifting_account.storage_id(:NEW.object_id),
                                                                       :NEW.daytime,
                                                                       :NEW.summer_time);
        END IF;

        :NEW.record_status := NVL(:NEW.record_status, 'P');
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

