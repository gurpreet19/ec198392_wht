CREATE OR REPLACE EDITIONABLE TRIGGER "IU_NOMPNT_SUB_DAY_NOMINATION" 
BEFORE INSERT OR UPDATE ON NOMPNT_SUB_DAY_NOMINATION
FOR EACH ROW
BEGIN
    -- Common
    -- $Revision: 1.3 $
    -- $Author:
    IF Inserting THEN

        :NEW.record_status := NVL(:NEW.record_status, 'P');
        IF :new.created_by IS NULL THEN
            :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
        END IF;

        IF :new.NOMINATION_SEQ IS NULL THEN
            EcDp_System_Key.assignNextNumber('NOMPNT_SUB_DAY_NOMINATION', :new.NOMINATION_SEQ);
        END IF;

        :NEW.CONTRACT_ID       := EC_NOMINATION_POINT.CONTRACT_ID(:NEW.object_id);
        :NEW.ENTRY_LOCATION_ID := EC_NOMINATION_POINT.ENTRY_LOCATION_ID(:NEW.object_id);
        :NEW.EXIT_LOCATION_ID  := EC_NOMINATION_POINT.EXIT_LOCATION_ID(:NEW.object_id);

        EcDp_Timestamp_Utils.syncUtcDate(:NEW.contract_id, :NEW.utc_daytime, :NEW.daytime, :NEW.summer_time);
        EcDp_Timestamp_Utils.setProductionDay(:NEW.contract_id, :NEW.utc_daytime, :NEW.production_day);

        IF :new.created_date IS NULL THEN
            :new.created_date := EcDp_Timestamp.getCurrentSysdate;
        END IF;
        :new.rev_no := 0;
    ELSE
        EcDp_Timestamp_Utils.updateUtcAndDaytime(:NEW.contract_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.daytime, :NEW.daytime, :OLD.summer_time, :NEW.summer_time);
        EcDp_Timestamp_Utils.updateProductionDay(:NEW.contract_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.production_day, :NEW.production_day);

        IF Nvl(:new.record_status, 'P') = Nvl(:old.record_status, 'P') THEN
            IF NOT UPDATING('LAST_UPDATED_BY') THEN
                :new.last_updated_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
            END IF;
            IF NOT UPDATING('LAST_UPDATED_DATE') THEN
                :new.last_updated_date := EcDp_Timestamp.getCurrentSysdate;
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
