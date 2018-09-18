CREATE OR REPLACE EDITIONABLE TRIGGER "IUD_V_CNTR_INV_OPER_MATRIX" 
  INSTEAD OF INSERT OR UPDATE OR DELETE ON v_cntr_inv_oper_matrix
  FOR EACH ROW

-- $Revision: 1.3 $
-- $Author: Lee Wei Yap

DECLARE

  -- Count if record exists in contract inventory location table

  ln_count    NUMBER;

BEGIN

  SELECT COUNT(*)
    INTO ln_count
    FROM cntr_day_loc_inventory loc_inv, cntr_day_loc_inv_trans tran
   WHERE loc_inv.object_id = :NEW.object_id
     AND tran.object_id = loc_inv.object_id
     AND loc_inv.daytime = :NEW.daytime
     AND tran.daytime = loc_inv.daytime
	 AND tran.transaction_type = ue_contract_inventory.getTransactionType;

  IF INSERTING THEN
    RAISE_APPLICATION_ERROR(-20573,'Inserting not supported. Insertion can be done in Daily Contract Inventory Location');
  END IF;

  IF UPDATING THEN

    IF ln_count = 0 THEN
      INSERT INTO cntr_day_loc_inv_trans
        (daytime,
         object_id,
         debit_qty,
         credit_qty,
         transaction_type,
         created_date,
         created_by,
         record_status,
         rev_no,
         rev_text,
		 last_updated_date,
         last_updated_by)
      VALUES
        (:NEW.daytime,
         :NEW.object_id,
         :NEW.debit_qty,
         :NEW.credit_qty,
         ue_contract_inventory.getTransactionType,
         :NEW.created_date,
         :NEW.created_by,
         'P',
         :NEW.rev_no,
         :NEW.rev_text,
		 :NEW.last_updated_date,
         :NEW.last_updated_by);
    ELSE

      UPDATE cntr_day_loc_inv_trans
         SET debit_qty         = :NEW.debit_qty,
             credit_qty        = :NEW.credit_qty,
             last_updated_by   = :NEW.last_updated_by,
             last_updated_date = :NEW.last_updated_date,
             record_status     = :NEW.record_status,
             rev_no            = :NEW.rev_no,
             rev_text          = :NEW.rev_text
       WHERE daytime = :NEW.daytime
         AND object_id = :NEW.object_id
		 AND transaction_type = ue_contract_inventory.getTransactionType;

    END IF;
  END IF;

  IF DELETING THEN
    RAISE_APPLICATION_ERROR(-20574,'Deleting not supported. Deletion of transaction can be done in Daily Contract Inventory Location');
  END IF;
END;
