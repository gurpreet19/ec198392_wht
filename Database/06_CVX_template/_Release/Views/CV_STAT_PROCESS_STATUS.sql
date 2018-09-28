---------------------------------------------------------------------------------------------------
--  CV_STAT_PROCESS_STATUS
--
--  Purpose:   		View on the STAT_PROCESS_STATUS table, not provided by EC
--
--  Notes:
--
--  	MVAS 08/2006	New
--
----------------------------------------------------------------------------------------------------- 


CREATE OR REPLACE VIEW CV_STAT_PROCESS_STATUS
	AS 
SELECT
	PROCESS_ID,
	RECORD_STATUS_LEVEL,
	DAYTIME,
	RUN_DAYTIME,
	ROWS_UPDATED,
	RECORD_STATUS,
	CREATED_BY,
	CREATED_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATED_DATE,
	REV_NO,
	REV_TEXT
FROM
	STAT_PROCESS_STATUS;

