CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCTY_DASHBRD_OIL_SUMMARY" ("OBJECT_ID", "DAYTIME", "FCTY_SUMMARY_TYPE", "CODE_TEXT", "SUMMARY_TYPE_VOL", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: V_FCTY_DASHBRD_OIL_SUMMARY.sql
-- View name: V_FCTY_DASHBRD_OIL_SUMMARY
--
-- $Revision: 1.5 $
--
-- Purpose  : The actual, planned, deferred and unassigned deferred volumes for each day for the facility.
--
-- Modification history:
--
-- Date       Whom       Change description:
-- ---------- ----       --------------------------------------------------------------------------------
-- 26.04.2013 rajarsar   ECPD-23618:Intial version
----------------------------------------------------------------------------------------------------
SELECT oa.OBJECT_ID,
       s.DAYTIME,
       p.CODE FCTY_SUMMARY_TYPE,
       p.code_text,
       EcBp_Facility_theoretical. getFacilityPhaseStdVolDay(oa.object_id, s.daytime, p.CODE,'OIL') AS SUMMARY_TYPE_VOL,
       to_char(null) record_status,
       to_char(null) created_by,
       to_date(null) created_date,
       to_char(null) last_updated_by,
       to_date(null) last_updated_date,
       to_number(null) rev_no,
       to_char(null) rev_text
FROM   system_days s, fcty_version oa, prosty_codes p
WHERE  p.code_type = 'FCTY_SUMMARY_TYPE'
AND nvl(p.is_active, 'N') = 'Y'
AND oa.daytime <= s.daytime
AND NVL(oa.end_date,s.daytime+1) > s.daytime
)