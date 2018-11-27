CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_AREA_DASHBRD" ("OBJECT_ID", "DAYTIME", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: V_AREA_DASHBRD.sql
-- View name: V_AREA_DASHBRD
--
-- $Revision: 1.2 $
--
-- Purpose  : Active Area's for the particular day.
--
-- Modification history:
--
-- Date       Whom  	Change description:
-- ---------- ----  	--------------------------------------------------------------------------------
-- 27.10.2015 kashisag  ECPD-32498:Intial version
----------------------------------------------------------------------------------------------------
SELECT oa.OBJECT_ID,
       s.DAYTIME,
       to_char(null) record_status,
       to_char(null) created_by,
       to_date(null) created_date,
       to_char(null) last_updated_by,
       to_date(null) last_updated_date,
       to_number(null) rev_no,
       to_char(null) rev_text
FROM   system_days s, geogr_area_version oa
WHERE   oa.daytime <= s.daytime
AND NVL(oa.end_date,s.daytime+1) > s.daytime
)