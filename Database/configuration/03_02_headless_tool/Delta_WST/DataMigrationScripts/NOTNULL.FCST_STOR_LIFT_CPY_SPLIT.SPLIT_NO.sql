BEGIN
 
--Updating SPLIT_NO column of table FCST_STOR_LIFT_CPY_SPLIT
UPDATE FCST_STOR_LIFT_CPY_SPLIT 
SET SPLIT_NO = EcDp_System_Key.assignNextNumber('FCST_STOR_LIFT_CPY_SPLIT'),
    last_updated_by   = last_updated_by,
    last_updated_date = last_updated_date
WHERE SPLIT_NO IS NULL;


END;
--~^UTDELIM^~--

