-- ECPD22923_STORAGE_LIFT_NOMINATION_1...
CREATE TABLE STORAGE_LIFT_NOMINATION_BCKP AS SELECT * FROM STORAGE_LIFT_NOMINATION
--~^UTDELIM^~--

ALTER TABLE STORAGE_LIFT_NOMINATION DISABLE ALL TRIGGERS
--~^UTDELIM^~--

BEGIN
	UPDATE STORAGE_LIFT_NOMINATION SET START_LIFTING_DATE = NOM_FIRM_DATE_TIME;
END;
--~^UTDELIM^~--

ALTER TABLE STORAGE_LIFT_NOMINATION ENABLE ALL TRIGGERS
--~^UTDELIM^~--
