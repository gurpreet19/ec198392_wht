CREATE OR REPLACE EDITIONABLE TRIGGER "IU_LIFT_ACC_SUB_DAY_OFFICIAL" 
BEFORE INSERT OR UPDATE ON LIFT_ACC_SUB_DAY_OFFICIAL
FOR EACH ROW
DECLARE
    lv_storage_id VARCHAR2(32);
BEGIN
    -- $Revision: 1.1 $
    -- Common
    IF Inserting THEN
        lv_storage_id := ec_lifting_account.storage_id(:NEW.object_id);

        EcDp_Timestamp_Utils.syncUtcDate('STORAGE', lv_storage_id, :NEW.utc_daytime, :NEW.time_zone, :NEW.daytime, :NEW.summer_time);
        EcDp_Timestamp_Utils.setProductionDay('STORAGE', lv_storage_id, :NEW.utc_daytime, :NEW.production_day);

        :NEW.record_status := NVL(:NEW.record_status, 'P');
        IF :new.created_by IS NULL THEN
            :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
        END IF;
        IF :new.created_date IS NULL THEN
            :new.created_date := EcDp_Timestamp.getCurrentSysdate;
        END IF;
        :new.rev_no := 0;
    ELSE
        IF Nvl(:new.record_status, 'P') = Nvl(:old.record_status, 'P') THEN
            IF NOT UPDATING('LAST_UPDATED_BY') THEN
                :new.last_updated_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
            END IF;
            IF NOT UPDATING('LAST_UPDATED_DATE') THEN
                :new.last_updated_date := EcDp_Timestamp.getCurrentSysdate;
            END IF;
        END IF;
    END IF;
END;