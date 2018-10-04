CREATE OR REPLACE TRIGGER "IU_NOMPNT_SUB_DAY_NOMINATION" 
BEFORE INSERT OR UPDATE ON NOMPNT_SUB_DAY_NOMINATION
FOR EACH ROW
DECLARE
    lv_pday_object_id VARCHAR2(32);
BEGIN
    -- Common
    -- $Revision: 1.3 $
    -- $Author:
    IF Inserting THEN

        :NEW.record_status := NVL(:NEW.record_status, 'P');
        IF :new.created_by IS NULL THEN
            :new.created_by := User;
        END IF;

        IF :new.NOMINATION_SEQ IS NULL THEN
            EcDp_System_Key.assignNextNumber('NOMPNT_SUB_DAY_NOMINATION', :new.NOMINATION_SEQ);
        END IF;

        :NEW.CONTRACT_ID       := EC_NOMINATION_POINT.CONTRACT_ID(:NEW.object_id);
        :NEW.ENTRY_LOCATION_ID := EC_NOMINATION_POINT.ENTRY_LOCATION_ID(:NEW.object_id);
        :NEW.EXIT_LOCATION_ID  := EC_NOMINATION_POINT.EXIT_LOCATION_ID(:NEW.object_id);

        lv_pday_object_id := EcDp_ContractDay.findProductionDayDefinition('CONTRACT',:NEW.CONTRACT_ID, :new.daytime);

        IF EcDp_Date_Time.interceptsWinterAndSummerTime(:NEW.daytime, lv_pday_object_id) = 'N' OR
           :NEW.summer_time IS NULL THEN
            :new.summer_time := EcDp_Date_Time.summertime_flag(:NEW.daytime, NULL, lv_pday_object_id);
        END IF;

        IF :new.production_day IS NULL THEN
            :new.production_day := EcDp_ContractDay.getProductionDay('CONTRACT',:NEW.CONTRACT_ID, :NEW.daytime, :NEW.summer_time);
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

        -- Make sure that no one updated contract and locations
        IF (:NEW.CONTRACT_ID IS NOT NULL AND :NEW.CONTRACT_ID <> :OLD.CONTRACT_ID) THEN
            Raise_Application_Error(-20000, 'Not allowed to update contract');
        END IF;

        IF (:NEW.ENTRY_LOCATION_ID IS NOT NULL AND :NEW.ENTRY_LOCATION_ID <> :OLD.ENTRY_LOCATION_ID) THEN
            Raise_Application_Error(-20000, 'Not allowed to update entry location');
        END IF;

        IF (:NEW.EXIT_LOCATION_ID IS NOT NULL AND :NEW.EXIT_LOCATION_ID <> :OLD.EXIT_LOCATION_ID) THEN
            Raise_Application_Error(-20000, 'Not allowed to update exit location');
        END IF;
    END IF;
END;

