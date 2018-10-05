CREATE OR REPLACE EDITIONABLE TRIGGER "IU_CURRENCY_EXCHANGE" 
BEFORE INSERT OR UPDATE ON currency_exchange
FOR EACH ROW
BEGIN
    -- $Revision: 1.3 $
    -- Common
    IF Inserting THEN
      EcBp_Currency.validateInsert(:NEW.daytime,:New.object_id,:New.currency_id, :new.time_scope, :new.forex_source_id);
      :NEW.record_status := NVL(:NEW.record_status,'P');
      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;

      IF :new.created_date IS NULL THEN
         :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;
    ELSE
      IF Nvl(:new.record_status,'P') = Nvl(:old.record_status,'P') THEN
         IF NOT UPDATING('LAST_UPDATED_BY') THEN
            :new.last_updated_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
         END IF;
         IF NOT UPDATING('LAST_UPDATED_DATE') THEN
           :new.last_updated_date := Ecdp_Timestamp.getCurrentSysdate;
         END IF;

      END IF;
    END IF;
END;
