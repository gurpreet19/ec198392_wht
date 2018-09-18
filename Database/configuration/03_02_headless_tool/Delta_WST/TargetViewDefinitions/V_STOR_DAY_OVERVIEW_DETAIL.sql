CREATE OR REPLACE FORCE VIEW "V_STOR_DAY_OVERVIEW_DETAIL" ("OBJECT_ID", "STORAGE_ID", "DAYTIME", "VOLUME", "DENSITY", "MASS", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: V_STOR_DAY_OVERVIEW_DETAIL.sql
-- View name: V_STOR_DAY_OVERVIEW_DETAIL
--
-- $Revision: 1.1 $
--
-- Purpose  :
--
-- Modification history:
--
-- Date       Whom      Change description:
-- ---------- --------  ----------------------------------------------------------------------------
-- 24.01.2011 rajarsar  Initial version
----------------------------------------------------------------------------------------------------
SELECT
(tu.tank_id) object_id,
(tu.object_id) storage_id,
sd.daytime DAYTIME,
ecdp_tank_measurement.getGrsVol(tu.tank_id,'DAY_CLOSING',sd.daytime) VOLUME,
ecdp_tank_measurement.getStdDens(tu.tank_id,'DAY_CLOSING',sd.daytime) DENSITY,
ecdp_tank_measurement.getGrsMass(tu.tank_id,'DAY_CLOSING',sd.daytime) MASS,
'P' AS RECORD_STATUS,
USER AS CREATED_BY,
SYSDATE AS CREATED_DATE,
USER AS LAST_UPDATED_BY,
SYSDATE AS LAST_UPDATED_DATE,
NULL AS REV_NO,
NULL AS REV_TEXT
FROM system_days sd, tank_usage tu
WHERE tu.daytime <= sd.daytime
AND  nvl(tu.end_date, sd.daytime+1) > sd.daytime
)
order by sd.daytime desc