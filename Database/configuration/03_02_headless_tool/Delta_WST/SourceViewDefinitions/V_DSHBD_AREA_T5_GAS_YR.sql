CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DSHBD_AREA_T5_GAS_YR" ("YR_FIRST_DAY", "YR_GAS_SUM", "WELL_OBJECT_ID", "OBJECT_ID", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: V_DSHBD_AREA_T5_GAS_YR.sql
-- View name: V_DSHBD_AREA_T5_GAS_YR
--
-- $Revision: 1.3 $
--
-- Purpose  : The yearly top 5 gas producers at area
--
-- Modification history:
--
-- Date       Whom      Change description:
-- ---------- ----      --------------------------------------------------------------------------------
-- 2015-11-03 leongwen  ECPD-26570 : Initial version
----------------------------------------------------------------------------------------------------
SELECT	a.YR_FIRST_DAY 		  AS YR_FIRST_DAY,
				a.YR_GAS_SUM 	      AS YR_GAS_SUM,
				a.OBJECT_ID  				AS WELL_OBJECT_ID,
				ga.OBJECT_ID 				AS OBJECT_ID,
				to_char(null) 			AS record_status,
				to_char(null) 			AS created_by,
				to_date(null) 			AS created_date,
				to_char(null) 			AS last_updated_by,
				to_date(null) 			AS last_updated_date,
				to_number(null) 		AS rev_no,
				to_char(null) 			AS rev_text
FROM V_DAY_ALLOC_GAS_SUM_YR a, WELL_VERSION wv, GEOGRAPHICAL_AREA ga
WHERE a.OBJECT_ID = wv.OBJECT_ID
AND wv.OP_AREA_ID = ga.OBJECT_ID
AND wv.DAYTIME <= a.YR_FIRST_DAY
AND NVL(wv.END_DATE, a.YR_FIRST_DAY+1) > a.YR_FIRST_DAY
) ORDER BY OBJECT_ID,YR_FIRST_DAY,YR_GAS_SUM DESC