-- ECPD22650_qbl_export_query_default_record...
-- PROMPT This Jira requires all queries to be named. All previously created queries will be assigned to Default name.
-- PROMPT This script attempts to create the Default record. IF the record is already there (qbl_export_query_no=1), 
-- PROMPT this record will be assumed to be Default.

BEGIN
	INSERT INTO QBL_EXPORT_QUERY (QBL_EXPORT_QUERY_NO, QUERY_NAME, GLOBAL_IND, REPORT_VIEW, OWNER_ID, CREATED_BY, CREATED_DATE)
	SELECT ECDP_SYSTEM_KEY.ASSIGNNEXTNUMBER('QBL_EXPORT_QUERY'), 'Default', 'Y', OBJECT_ID,	 'sysadmin' , NVL(ECDP_PINC.getInstallModeTag(), USER), TRUNC(SYSDATE)
	FROM QBL_EXPORT_WHERE_COND
	WHERE QBL_EXPORT_QUERY_NO IS NULL
	GROUP BY OBJECT_ID;
END;
--~^UTDELIM^~--
