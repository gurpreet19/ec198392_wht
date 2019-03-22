CREATE OR REPLACE EDITIONABLE TRIGGER "IU_PROD_PRICE_SUB_DAY_VALUE" 
BEFORE INSERT OR UPDATE ON PROD_PRICE_SUB_DAY_VALUE
FOR EACH ROW
DECLARE
    lv_contract_id VARCHAR2(32);
BEGIN
  -- $Revision: 1.2 $
    -- Common
    lv_contract_id := ec_product_price.contract_id(:NEW.object_id);
    IF Inserting THEN

      EcDp_Timestamp_Utils.syncUtcDate(lv_contract_id, :NEW.utc_daytime, :NEW.daytime, :NEW.summer_time);
      EcDp_Timestamp_Utils.setProductionDay(lv_contract_id, :NEW.utc_daytime, :NEW.production_day);

      :new.record_status := nvl(:new.record_status, 'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;
      IF :new.created_date IS NULL THEN
         :new.created_date := EcDp_Timestamp.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;
    ELSE
      EcDp_Timestamp_Utils.updateUtcAndDaytime(lv_contract_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.daytime, :NEW.daytime, :OLD.summer_time, :NEW.summer_time);
      EcDp_Timestamp_Utils.updateProductionDay(lv_contract_id, :OLD.utc_daytime, :NEW.utc_daytime, :OLD.production_day, :NEW.production_day);

      IF Nvl(:new.record_status,'P') = Nvl(:old.record_status,'P') THEN
         IF NOT UPDATING('LAST_UPDATED_BY') THEN
            :new.last_updated_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
         END IF;
         IF NOT UPDATING('LAST_UPDATED_DATE') THEN
           :new.last_updated_date := EcDp_Timestamp.getCurrentSysdate;
         END IF;
      END IF;
    END IF;
END;
