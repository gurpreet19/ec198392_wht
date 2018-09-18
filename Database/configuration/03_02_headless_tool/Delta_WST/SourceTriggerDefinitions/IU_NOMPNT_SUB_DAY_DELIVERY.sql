CREATE OR REPLACE EDITIONABLE TRIGGER "IU_NOMPNT_SUB_DAY_DELIVERY" 
BEFORE INSERT OR UPDATE ON NOMPNT_SUB_DAY_DELIVERY
FOR EACH ROW
DECLARE
    lv_contract_id VARCHAR2(32);
BEGIN
    -- Common
    -- $Revision: 1.3 $
    -- $Author:
    IF Inserting THEN
        lv_contract_id := ec_nomination_point.contract_id(:NEW.object_id);

        EcDp_Timestamp_Utils.syncUtcDate('CONTRACT', lv_contract_id, :NEW.utc_daytime, :NEW.time_zone, :NEW.daytime, :NEW.summer_time);
        EcDp_Timestamp_Utils.setProductionDay('CONTRACT', lv_contract_id, :NEW.utc_daytime, :NEW.production_day);

       :NEW.record_status := NVL(:NEW.record_status, 'P');

        :new.record_status := 'P';
        IF :new.created_by IS NULL THEN
            :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
        END IF;

        IF :new.NOMINATION_SEQ IS NULL THEN
            EcDp_System_Key.assignNextNumber('NOMPNT_SUB_DAY_DELIVERY', :new.NOMINATION_SEQ);
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
