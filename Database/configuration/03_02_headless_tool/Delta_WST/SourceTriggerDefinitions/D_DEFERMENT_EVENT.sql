CREATE OR REPLACE EDITIONABLE TRIGGER "D_DEFERMENT_EVENT" 
BEFORE DELETE ON DEFERMENT_EVENT
FOR EACH ROW
DECLARE
BEGIN
  -- $Revision: 1.2 $
     DELETE FROM well_day_defer_alloc
     WHERE event_no = :old.event_no;
     DELETE FROM temp_well_deferment_alloc
     WHERE event_no = :old.event_no;
END;
