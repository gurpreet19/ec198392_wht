BEGIN
 
--Updating SPLIT_NO column of table FCST_STOR_LIFT_CPY_SPLIT_JN
UPDATE FCST_STOR_LIFT_CPY_SPLIT_JN J
   SET split_no = 
       (select split_no
          from FCST_STOR_LIFT_CPY_SPLIT
         where FORECAST_ID = J.FORECAST_ID
           and PARCEL_NO = J.PARCEL_NO
           and COMPANY_ID = J.COMPANY_ID
           and LIFTING_ACCOUNT_ID = J.LIFTING_ACCOUNT_ID)
 WHERE (FORECAST_ID, PARCEL_NO, COMPANY_ID, LIFTING_ACCOUNT_ID) IN
       (select FORECAST_ID, PARCEL_NO, COMPANY_ID, LIFTING_ACCOUNT_ID
          from FCST_STOR_LIFT_CPY_SPLIT
         where FORECAST_ID = J.FORECAST_ID
           AND PARCEL_NO = J.PARCEL_NO
           and COMPANY_ID = J.COMPANY_ID
           and LIFTING_ACCOUNT_ID = J.LIFTING_ACCOUNT_ID);

END;
--~^UTDELIM^~--
