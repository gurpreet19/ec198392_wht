BEGIN
 
		
--Updating SPLIT_NO column of table STORAGE_LIFT_NOM_SPLIT_JN 
UPDATE STORAGE_LIFT_NOM_SPLIT_JN J
   SET split_no = 
       (select split_no
          from STORAGE_LIFT_NOM_SPLIT
         where PARCEL_NO = J.PARCEL_NO
           and COMPANY_ID = J.COMPANY_ID
           and LIFTING_ACCOUNT_ID = J.LIFTING_ACCOUNT_ID)
 WHERE (PARCEL_NO, COMPANY_ID, LIFTING_ACCOUNT_ID) IN
       (select PARCEL_NO, COMPANY_ID, LIFTING_ACCOUNT_ID
          from STORAGE_LIFT_NOM_SPLIT
         where PARCEL_NO = J.PARCEL_NO
           and COMPANY_ID = J.COMPANY_ID
           and LIFTING_ACCOUNT_ID = J.LIFTING_ACCOUNT_ID);

END;
--~^UTDELIM^~--

