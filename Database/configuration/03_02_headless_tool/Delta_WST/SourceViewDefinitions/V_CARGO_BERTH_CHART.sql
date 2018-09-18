CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CARGO_BERTH_CHART" ("DAYTIME", "CHART_START_DATE", "CHART_END_DATE", "OBJECT_ID", "STORAGE_ID", "LIFTING_ACCOUNT_ID", "CLASS", "PARCEL_NO", "CARGO_NO", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
---------------------------------------------------------------------------------------------------
-- File name v_cargo_berth_chart.sql
-- View name v_cargo_berth_chart
--
-- $Revision: 1.2 $
--
-- Purpose
-- Will show allocation of cargoes on berth.
--
-- Modification history
--
-- Date       Whom      Change description
-- ---------- --------  ----------------------------------------------------------------------------
-- 03 Mar 2017 thotesan	ECPD-43320: New Business Function: CP.0072: Schedule Lifting Overview
-- 21 Mar 2017 sharawan ECPD-44077: Modified the OBJECT_ID to get Berth object instead of Storage
----------------------------------------------------------------------------------------------------
SELECT
     -- Getting the Restrictions detail for a specific Berth
    R.START_DATE AS DAYTIME
  , R.START_DATE AS CHART_START_DATE
  , R.END_DATE AS CHART_END_DATE
  , B.OBJECT_ID as OBJECT_ID
  , to_char(null) as STORAGE_ID
  , to_char(null) as LIFTING_ACCOUNT_ID
  , 'OPRES_PERIOD_RESTRICTION' CLASS
  , 0 PARCEL_NO
  , 0 CARGO_NO
  , R.RECORD_STATUS AS RECORD_STATUS
  , R.CREATED_BY AS CREATED_BY
  , R.CREATED_DATE AS CREATED_DATE
  , R.LAST_UPDATED_BY AS LAST_UPDATED_BY
  , R.LAST_UPDATED_DATE AS LAST_UPDATED_DATE
  , R.REV_NO AS REV_NO
  , R.REV_TEXT AS REV_TEXT
   FROM OPLOC_PERIOD_RESTRICTION R, BERTH_VERSION B
   WHERE B.OBJECT_ID = R.OBJECT_ID
    and r.START_DATE >= B.DAYTIME
    and r.END_DATE <= nvl(B.END_DATE, r.END_DATE)
UNION
SELECT
  -- Getting the detail with Berth id
    N.nom_firm_date AS DAYTIME
  , N.nom_firm_date AS CHART_START_DATE
  , N.nom_firm_date AS CHART_END_DATE
  , CT.BERTH_ID as OBJECT_ID
  , n.OBJECT_ID STORAGE_ID
  , N.lifting_account_id as LIFTING_ACCOUNT_ID
  , 'STORAGE_LIFT_NOM_SCHED' CLASS
  , N.PARCEL_NO PARCEL_NO
  , CT.CARGO_NO CARGO_NO
  , N.RECORD_STATUS AS RECORD_STATUS
  , N.CREATED_BY AS CREATED_BY
  , N.CREATED_DATE AS CREATED_DATE
  , N.LAST_UPDATED_BY AS LAST_UPDATED_BY
  , N.LAST_UPDATED_DATE AS LAST_UPDATED_DATE
  , N.REV_NO AS REV_NO
  , N.REV_TEXT AS REV_TEXT
   FROM STORAGE_LIFT_NOMINATION N,
   cargo_transport CT,
   CARGO_STATUS_MAPPING  CMAP,
   BERTH_VERSION B
   where N.cargo_no = CT.cargo_no
   and CT.cargo_status = CMAP.cargo_status
   and cmap.ec_cargo_status != 'D'
   and ct.berth_id = B.OBJECT_ID
)