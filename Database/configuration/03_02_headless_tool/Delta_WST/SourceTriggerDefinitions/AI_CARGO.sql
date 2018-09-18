CREATE OR REPLACE EDITIONABLE TRIGGER "AI_CARGO" 
AFTER INSERT ON cargo
FOR EACH ROW

DECLARE
CURSOR c_activity_codes is
SELECT activity_code, activity_name, sort_order
  FROM cargo_activity_code
 WHERE from_date <= Nvl(:new.start_loading, Ecdp_Timestamp.getCurrentSysdate)
   AND (end_date > Nvl(:new.start_loading, Ecdp_Timestamp.getCurrentSysdate) OR end_date IS NULL);

ln_counter NUMBER;

BEGIN

  --Special trigger for EnergyX IPS template.
  -- $Revision: 1.5 $
  -- Special

  ln_counter := 1 ;

  FOR myCur in  c_activity_codes LOOP
  		INSERT into cargo_activity(cargo_no, activity_code, run_no, event_no, created_by)
  		VALUES
  		(:new.cargo_no, myCur.activity_code, 1, ln_counter,:NEW.Created_by);

		ln_counter := ln_counter +1 ;
  END LOOP;

END;
