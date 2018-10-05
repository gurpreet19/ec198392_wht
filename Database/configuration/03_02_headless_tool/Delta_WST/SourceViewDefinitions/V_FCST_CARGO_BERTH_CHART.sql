CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_CARGO_BERTH_CHART" ("DAYTIME", "CHART_START_DATE", "CHART_END_DATE", "BERTH_ID", "FORECAST_ID", "LIFTING_ACCOUNT_ID", "CLASS", "PARCEL_NO", "CARGO_NO", "OBJECT_ID", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
/**************************************************************
** Script:	v_fcst_cargo_berth_chart.SQL
**
** $Revision: 1.0 $
**
** Purpose:
**
** General Logic:
**
** Created:   21.01.2016  Wan Shara
**
**
-- Modification history:
--
-- Date       Whom     Change description:
-- ---------- -------  --------------------------------------------------------------------------------
-- 21.01.2016 sharawan ECPD-33109: New version for daily Berth Overview
-- 31.03.2016 sharawan ECPD-34226: Code cleanup for daily Berth Overview
-- 05.10.2016 baratmah ECPD-36184: Modified table name STORAGE_BERTH to STORAGE_PORT_RESOURCE and related column
**************************************************************/
SELECT
     -- For getting the Restrictions detail for a specific Berth
    R.START_DATE AS DAYTIME
  , R.START_DATE AS CHART_START_DATE
  , R.END_DATE AS CHART_END_DATE
  , R.OBJECT_ID as BERTH_ID
  , R.FORECAST_ID as FORECAST_ID
  , to_char(null) as LIFTING_ACCOUNT_ID
  , 'FCST_OPRES_PERIOD_RESTR' CLASS
  , 0 PARCEL_NO
  , 0 CARGO_NO
  , S.OBJECT_ID OBJECT_ID
  , R.RECORD_STATUS AS RECORD_STATUS
  , R.CREATED_BY AS CREATED_BY
  , R.CREATED_DATE AS CREATED_DATE
  , R.LAST_UPDATED_BY AS LAST_UPDATED_BY
  , R.LAST_UPDATED_DATE AS LAST_UPDATED_DATE
  , R.REV_NO AS REV_NO
  , R.REV_TEXT AS REV_TEXT
   FROM FCST_OPLOC_PERIOD_RESTR R, STORAGE_PORT_RESOURCE S
   WHERE S.PORT_RESOURCE_ID = R.OBJECT_ID
    and r.START_DATE >= s.daytime
    and r.END_DATE <= nvl(s.end_date, r.END_DATE)
UNION
SELECT
  -- For getting the detail with Berth id
    n.nom_firm_date AS DAYTIME
  , N.nom_firm_date AS CHART_START_DATE
  , N.nom_firm_date AS CHART_END_DATE
  , CT.BERTH_ID as BERTH_ID
  , N.FORECAST_ID as FORECAST_ID
  , n.lifting_account_id as LIFTING_ACCOUNT_ID
  , 'FCST_STOR_LIFT_NOM_SCHED' CLASS
  , N.PARCEL_NO PARCEL_NO
  , CT.CARGO_NO CARGO_NO
  , N.OBJECT_ID OBJECT_ID
  , N.RECORD_STATUS AS RECORD_STATUS
  , N.CREATED_BY AS CREATED_BY
  , N.CREATED_DATE AS CREATED_DATE
  , N.LAST_UPDATED_BY AS LAST_UPDATED_BY
  , N.LAST_UPDATED_DATE AS LAST_UPDATED_DATE
  , N.REV_NO AS REV_NO
  , N.REV_TEXT AS REV_TEXT
   FROM STOR_FCST_LIFT_NOM N,
   cargo_fcst_transport  CT,
   STORAGE_PORT_RESOURCE S,
   CARGO_STATUS_MAPPING  CMAP
   where n.forecast_id = ct.forecast_id
   and n.cargo_no = ct.cargo_no
   and s.port_resource_id = ct.berth_id
   and ct.cargo_status = cmap.cargo_status
   and cmap.ec_cargo_status != 'D'
   and nvl(n.DELETED_IND, 'N') <> 'Y'
)