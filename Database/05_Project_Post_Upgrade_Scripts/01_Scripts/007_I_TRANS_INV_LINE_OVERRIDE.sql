CREATE OR REPLACE TRIGGER "I_TRANS_INV_LINE_OVERRIDE" 
INSTEAD OF UPDATE ON Dv_TRANS_INV_LINE_OVERRIDE
FOR EACH ROW

DECLARE

  lrec V_TRANS_INV_LINE_OVERRIDE%ROWTYPE;

BEGIN

if (:new.end_date IS NULL AND :old.end_date IS NOT NULL )
   OR (:new.end_date IS NOT NULL AND :old.end_date IS NULL)
   OR :new.end_date != :old.end_date THEN
    update trans_inv_line_override set end_date=:new.end_date where daytime = :new.daytime and tag = :new.tag and :new.contract_id = contract_id and :new.object_id=object_id; END IF;

if nvl(:new.description,'x')!=nvl(:old.description,'x') then update trans_inv_line_override set description=:new.description where daytime = :new.daytime and tag = :new.tag and :new.contract_id = contract_id and :new.object_id=object_id; END IF;
if (:new.exec_order IS NOT NULL AND :old.exec_order IS NULL)
   OR :new.exec_order != :old.exec_order
    then update trans_inv_line_override set exec_order=:new.exec_order where daytime = :new.daytime and tag = :new.tag and :new.contract_id = contract_id and :new.object_id=object_id; END IF;
if nvl(:new.DIMENSION_OVER_MONTH_IND,'x')!=nvl(:old.DIMENSION_OVER_MONTH_IND,'x') then update trans_inv_line_override set DIMENSION_OVER_MONTH_IND=:new.DIMENSION_OVER_MONTH_IND where daytime = :new.daytime and tag = :new.tag and :new.contract_id = contract_id and :new.object_id=object_id; END IF;
if nvl(:new.ROUND_TRANSACTION_IND,'x')!=nvl(:old.ROUND_TRANSACTION_IND,'x') then update trans_inv_line_override set ROUND_TRANSACTION_IND=:new.ROUND_TRANSACTION_IND where daytime = :new.daytime and tag = :new.tag and :new.contract_id = contract_id and :new.object_id=object_id; END IF;
if nvl(:new.XFER_IN_LINE,'x')!=nvl(:old.XFER_IN_LINE,'x') then update trans_inv_line_override set XFER_IN_LINE=:new.XFER_IN_LINE where daytime = :new.daytime and tag = :new.tag and :new.contract_id = contract_id and :new.object_id=object_id; END IF;
if nvl(:new.PRORATE_LINE,'x')!=nvl(:old.PRORATE_LINE,'x') then update trans_inv_line_override set PRORATE_LINE=:new.PRORATE_LINE where daytime = :new.daytime and tag = :new.tag and :new.contract_id = contract_id and :new.object_id=object_id; END IF;
if nvl(:new.CURRENT_PERIOD_ONLY,'x')!=nvl(:old.CURRENT_PERIOD_ONLY,'x') then update trans_inv_line_override set CURRENT_PERIOD_ONLY_IND=:new.CURRENT_PERIOD_ONLY where daytime = :new.daytime and tag = :new.tag and :new.contract_id = contract_id and :new.object_id=object_id; END IF;
if nvl(:new.ROUND_VALUE_IND,'x')!=nvl(:old.ROUND_VALUE_IND,'x') then update trans_inv_line_override set ROUND_VALUE_IND=:new.ROUND_VALUE_IND where daytime = :new.daytime and tag = :new.tag and :new.contract_id = contract_id and :new.object_id=object_id; END IF;
if nvl(:new.TRANS_DEF_DIMENSION,'x')!=nvl(:old.TRANS_DEF_DIMENSION,'x') then update trans_inv_line_override set TRANS_DEF_DIMENSION=:new.TRANS_DEF_DIMENSION where daytime = :new.daytime and tag = :new.tag and :new.contract_id = contract_id and :new.object_id=object_id; END IF;

END;
/