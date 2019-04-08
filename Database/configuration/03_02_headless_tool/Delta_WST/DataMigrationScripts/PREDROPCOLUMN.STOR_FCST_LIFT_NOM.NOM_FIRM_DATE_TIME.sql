-- ECPD22923_STOR_FCST_LIFT_NOM_1...
CREATE TABLE STOR_FCST_LIFT_NOM_BCKP AS SELECT * FROM STOR_FCST_LIFT_NOM
--~^UTDELIM^~--

ALTER TABLE STOR_FCST_LIFT_NOM DISABLE ALL TRIGGERS
--~^UTDELIM^~--
 
BEGIN
     
	UPDATE STOR_FCST_LIFT_NOM SET START_LIFTING_DATE = NOM_FIRM_DATE_TIME;
	 
END;
--~^UTDELIM^~--

ALTER TABLE STOR_FCST_LIFT_NOM ENABLE ALL TRIGGERS
--~^UTDELIM^~--