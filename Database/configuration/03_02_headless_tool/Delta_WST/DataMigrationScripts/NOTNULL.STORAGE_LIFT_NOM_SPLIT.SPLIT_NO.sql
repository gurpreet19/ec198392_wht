BEGIN
 
--Updating SPLIT_NO column of table STORAGE_LIFT_NOM_SPLIT 
UPDATE STORAGE_LIFT_NOM_SPLIT 
	SET SPLIT_NO = EcDp_System_Key.assignNextNumber('STORAGE_LIFT_NOM_SPLIT'),
        last_updated_by   = last_updated_by,
        last_updated_date = last_updated_date
WHERE SPLIT_NO IS NULL;

END;
--~^UTDELIM^~--

