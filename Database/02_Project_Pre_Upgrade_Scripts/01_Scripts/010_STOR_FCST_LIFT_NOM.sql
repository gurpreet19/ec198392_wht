 
--TO CHANGE THE DATATYPE FOR VALUE_11 COLUMN, IT  MUST BE EMPTY. SO MIGRATING TO TEXT_1, IN POST-SCRIPTS MOVING BACK TO VALUE_11 COLUMN.

ALTER TABLE STOR_FCST_LIFT_NOM
DISABLE ALL TRIGGERS;

UPDATE STOR_FCST_LIFT_NOM
SET TEXT_1 = VALUE_11;
  
UPDATE STOR_FCST_LIFT_NOM_JN
SET TEXT_1 = VALUE_11;

UPDATE STOR_FCST_LIFT_NOM
SET VALUE_11 = '';

UPDATE STOR_FCST_LIFT_NOM_JN
SET VALUE_11 = '';

ALTER TABLE STOR_FCST_LIFT_NOM
ENABLE ALL TRIGGERS; 




 