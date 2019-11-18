/********************************************************************************/
/* "ORA-00904: "NOM"."BL_DATE_TIME": invalid identifier                         */
/* "ORA-00904: "NOM_FIRM_DATE_TIME": invalid identifier                         */
/********************************************************************************/ 

-- ADD 2 COLUMNS IN STOR_FCST_LIFT_NOM
--ALTER TABLE STOR_FCST_LIFT_NOM ADD (DATE_8 DATE, DATE_9 DATE);
--ALTER TABLE STOR_FCST_LIFT_NOM_JN ADD (DATE_8 DATE, DATE_9 DATE);
-- removed DATE_8 after new dump received
ALTER TABLE STOR_FCST_LIFT_NOM ADD (DATE_9 DATE);
ALTER TABLE STOR_FCST_LIFT_NOM_JN ADD (DATE_9 DATE);


--ALTER TABLE STORAGE_LIFT_NOMINATION ADD (DATE_8 DATE, DATE_9 DATE);
--ALTER TABLE STORAGE_LIFT_NOMINATION_JN ADD (DATE_8 DATE, DATE_9 DATE);
-- removed DATE_8 after new dump received
ALTER TABLE STORAGE_LIFT_NOMINATION ADD (DATE_9 DATE);
ALTER TABLE STORAGE_LIFT_NOMINATION_JN ADD (DATE_9 DATE);

EXECUTE ec_generate.basicIUTriggers('STORAGE_LIFT_NOMINATION');
execute EC_GENERATE.GENERATEPACKAGES('STORAGE_LIFT_NOMINATION');
EXECUTE ec_generate.journalTriggers('STORAGE_LIFT_NOMINATION');

EXECUTE ec_generate.basicIUTriggers('STORAGE_LIFT_NOMINATION_JN');
execute EC_GENERATE.GENERATEPACKAGES('STORAGE_LIFT_NOMINATION_JN');
EXECUTE ec_generate.journalTriggers('STORAGE_LIFT_NOMINATION_JN');

-- MOVE DATA 

update STOR_FCST_LIFT_NOM
  set DATE_8 = NOM_FIRM_DATE_TIME,
      DATE_9 = BL_DATE_TIME;

update STOR_FCST_LIFT_NOM_JN
  set DATE_8 = NOM_FIRM_DATE_TIME,
      DATE_9 = BL_DATE_TIME;
	  
update STORAGE_LIFT_NOMINATION
  set DATE_8 = NOM_FIRM_DATE_TIME,
      DATE_9 = BL_DATE_TIME;

update STORAGE_LIFT_NOMINATION_JN
  set DATE_8 = NOM_FIRM_DATE_TIME,
      DATE_9 = BL_DATE_TIME;

/********************************************************************************/