CREATE OR REPLACE EDITIONABLE TRIGGER "IU_CONT_LI_DIST_COMPANY" 
BEFORE INSERT OR UPDATE ON CONT_LI_DIST_COMPANY
FOR EACH ROW
DECLARE
ln_precision NUMBER := NVL(ec_ctrl_system_attribute.attribute_value(:NEW.DAYTIME, 'EX_VAT_PRECISION', '<='), 2);

BEGIN

  IF Inserting THEN

    IF Inserting THEN
      :new.record_status := 'P';
      IF :new.created_by IS NULL THEN
        :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;
      :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      :new.rev_no       := 0;

    END IF;

  ELSIF Updating THEN

    IF NOT UPDATING('LAST_UPDATED_BY') THEN
      :new.last_updated_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
    END IF;

    -- avoid increment during loading ???
    IF :New.last_updated_by = 'SYSTEM' THEN
      -- do not create new revision
      :New.last_updated_by := :Old.last_updated_by; -- set to old, assuming that this update is part of a sequence of updates
    ELSE
      :new.rev_no := :old.rev_no + 1;
    END IF;

    IF NOT UPDATING('LAST_UPDATED_DATE') THEN
        :new.last_updated_date := Ecdp_Timestamp.getCurrentSysdate;
    END IF;

    IF UPDATING ('BOOKING_VALUE') or UPDATING('BOOKING_VAT_VALUE') THEN
        UPDATE cont_document_company cdv
           SET cdv.amount = nvl(cdv.amount,0) + nvl(:new.booking_value,0) + nvl(:new.booking_vat_value,0)
                               - nvl(:old.booking_value,0) - nvl(:old.booking_vat_value,0),
               cdv.last_updated_by = 'SYSTEM'
         WHERE cdv.object_id = :new.object_id
           AND cdv.document_key = :new.document_key
           AND cdv.company_id = :new.vendor_id;
    END IF;

    IF UPDATING ('PRICING_VALUE') or UPDATING('PRICING_VAT_VALUE') THEN
       :new.PRICING_TOTAL :=Round((:new.PRICING_VALUE + :new.PRICING_VAT_VALUE),ln_precision);
    END IF;
    IF UPDATING ('BOOKING_VALUE') or UPDATING('BOOKING_VAT_VALUE') THEN
       :new.BOOKING_TOTAL :=Round((:new.BOOKING_VALUE + :new.BOOKING_VAT_VALUE),ln_precision);
    END IF;
    IF UPDATING ('MEMO_VALUE') or UPDATING('MEMO_VAT_VALUE') THEN
       :new.MEMO_TOTAL :=Round((:new.MEMO_VALUE + :new.MEMO_VAT_VALUE),ln_precision);
    END IF;
    IF UPDATING ('LOCAL_VALUE') or UPDATING('LOCAL_VAT_VALUE') THEN
       :new.LOCAL_TOTAL :=Round((:new.LOCAL_VALUE + :new.LOCAL_VAT_VALUE),ln_precision);
    END IF;
    IF UPDATING ('GROUP_VALUE') or UPDATING('GROUP_VAT_VALUE') THEN
       :new.GROUP_TOTAL :=Round((:new.GROUP_VALUE + :new.GROUP_VAT_VALUE),ln_precision);
    END IF;
  END IF;


END;
