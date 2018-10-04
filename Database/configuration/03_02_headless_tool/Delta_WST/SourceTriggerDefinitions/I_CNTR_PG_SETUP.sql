CREATE OR REPLACE EDITIONABLE TRIGGER "I_CNTR_PG_SETUP" 
  INSTEAD OF UPDATE ON V_CNTR_PG_SETUP
  FOR EACH ROW

-- $Revision: 1.1 $
-- $Author: Kenneth Masamba

DECLARE


BEGIN



  IF UPDATING THEN

    ECDP_ROYALTY_CONTRACT.updateProducts(:NEW.daytime, :NEW.object_id, :NEW.contract_id, :NEW.rty_base_volume, :NEW.use_ind);
  END IF;

END;

