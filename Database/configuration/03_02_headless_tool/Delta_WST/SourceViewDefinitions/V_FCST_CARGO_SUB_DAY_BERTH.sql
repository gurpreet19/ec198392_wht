CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_CARGO_SUB_DAY_BERTH" ("DAYTIME", "CHART_START_DATE", "CHART_END_DATE", "PRODUCTION_DAY", "SUMMER_TIME", "BERTH_ID", "FORECAST_ID", "LIFTING_ACCOUNT_ID", "CLASS", "PARCEL_NO", "CARGO_NO", "OBJECT_ID", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
/**************************************************************
** Script:	v_fcst_cargo_sub_day_berth.SQL
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
-- 11.02.2016 sharawan ECPD-33109: New version for sub daily Berth Overview
-- 16.03.2016 sharawan ECPD-34277: Modify the view for code cleanup
-- 31.03.2016 sharawan ECPD-34226: Modify column used for CHART_END_DATE
-- 17.05.2016 thotesan ECPD-35637: Error on saving Gantt chart changes in sub daily section FCST_MANAGER
-- 05.10.2016 baratmah ECPD-36184: Modified table name STORAGE_BERTH to STORAGE_PORT_RESOURCE and related column
-- 24.03.2017 sharawan ECPD-42257: Modified the production_day and summer_time to get it from the subdaily table
**************************************************************/
SELECT
     -- For getting the Restrictions detail for a specific Berth
    R.START_DATE AS DAYTIME
  , R.START_DATE AS CHART_START_DATE
  , R.END_DATE AS CHART_END_DATE
  , to_date(null) as production_day
  , to_char(null) as summer_time
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
    n.nom_firm_date AS DAYTIME
  , n.start_lifting_date AS CHART_START_DATE
  , (SELECT max(snd.daytime) as end_date
           FROM STOR_FCST_SUB_DAY_LIFT_NOM snd
           where snd.parcel_no = n.parcel_no
           and snd.forecast_id = n.forecast_id
           and snd.object_id = n.object_id) AS CHART_END_DATE
  , EcDp_ProductionDay.getProductionDay('STORAGE', n.OBJECT_ID, n.Nom_Firm_Date) as production_day
  , (SELECT max(snd.summer_time) as summer_time
           FROM STOR_FCST_SUB_DAY_LIFT_NOM snd
           where snd.parcel_no = n.parcel_no
           and snd.forecast_id = n.forecast_id
           and snd.object_id = n.object_id) AS SUMMER_TIME
  , ct.berth_id as BERTH_ID
  , n.FORECAST_ID as FORECAST_ID
  , n.lifting_account_id as LIFTING_ACCOUNT_ID
  , 'STOR_FCST_SUB_DAY_LIFT_NOM' CLASS
  , n.PARCEL_NO PARCEL_NO
  , ct.cargo_no CARGO_NO
  , n.OBJECT_ID OBJECT_ID
  , n.RECORD_STATUS AS RECORD_STATUS
  , n.CREATED_BY AS CREATED_BY
  , n.CREATED_DATE AS CREATED_DATE
  , n.LAST_UPDATED_BY AS LAST_UPDATED_BY
  , n.LAST_UPDATED_DATE AS LAST_UPDATED_DATE
  , n.REV_NO AS REV_NO
  , n.REV_TEXT AS REV_TEXT
   FROM CARGO_FCST_TRANSPORT ct, STOR_FCST_LIFT_NOM n, STORAGE_PORT_RESOURCE B,CARGO_STATUS_MAPPING  CMAP
   where ct.cargo_no = n.cargo_no
   AND ct.forecast_id = n.forecast_id
   and ct.berth_id = b.port_resource_id
   and ct.cargo_status = cmap.cargo_status
   and cmap.ec_cargo_status != 'D'
   and nvl(n.DELETED_IND, 'N') <> 'Y'
)