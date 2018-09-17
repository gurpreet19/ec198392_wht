CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CARGO_SUB_DAY_BERTH" ("DAYTIME", "CHART_START_DATE", "CHART_END_DATE", "PRODUCTION_DAY", "SUMMER_TIME", "OBJECT_ID", "STORAGE_ID", "LIFTING_ACCOUNT_ID", "CLASS", "PARCEL_NO", "CARGO_NO", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
/**************************************************************
** Script:	v_cargo_sub_day_berth.SQL
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
-- 09.03.2017 sharawan ECPD-43320: New version for CP.0072 - Schedule Lifting Overview
-- 21.03.2017 sharawan ECPD-44077: Modified the OBJECT_ID to get Berth object instead of Storage
-- 24.03.2017 sharawan ECPD-42257: Modified the production_day and summer_time to get it from the subdaily table
-- 07.04.2017 sharawan ECPD-44777: Modified the CHART_START_DATE to get start_lifting_date to fix the gantt chart start date showing correct time
**************************************************************/
SELECT
     -- For getting the Restrictions detail for a specific Berth
    R.START_DATE AS DAYTIME
  , R.START_DATE AS CHART_START_DATE
  , R.END_DATE AS CHART_END_DATE
  , to_date(null) as production_day
  , to_char(null) as summer_time
  , B.OBJECT_ID as OBJECT_ID
  , to_char(null) STORAGE_ID
  , to_char(null) as LIFTING_ACCOUNT_ID
  , 'OPRES_PERIOD_RESTR' CLASS
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
    n.nom_firm_date AS DAYTIME
  , n.start_lifting_date AS CHART_START_DATE
  , (SELECT max(snd.daytime) as end_date
           FROM STOR_SUB_DAY_LIFT_NOM snd
           where snd.parcel_no = n.parcel_no
           and snd.object_id = n.object_id) AS CHART_END_DATE
  , EcDp_ProductionDay.getProductionDay('STORAGE', n.OBJECT_ID, n.Nom_Firm_Date) as production_day
  , (SELECT max(snd.summer_time) as summer_time
           FROM STOR_SUB_DAY_LIFT_NOM snd
           where snd.parcel_no = n.parcel_no
           and snd.object_id = n.object_id) AS SUMMER_TIME
  , ct.berth_id as OBJECT_ID
  , n.OBJECT_ID STORAGE_ID
  , n.lifting_account_id as LIFTING_ACCOUNT_ID
  , 'STOR_SUB_DAY_LIFT_NOM' CLASS
  , n.PARCEL_NO PARCEL_NO
  , ct.cargo_no CARGO_NO
  , n.RECORD_STATUS AS RECORD_STATUS
  , n.CREATED_BY AS CREATED_BY
  , n.CREATED_DATE AS CREATED_DATE
  , n.LAST_UPDATED_BY AS LAST_UPDATED_BY
  , n.LAST_UPDATED_DATE AS LAST_UPDATED_DATE
  , n.REV_NO AS REV_NO
  , n.REV_TEXT AS REV_TEXT
   FROM CARGO_TRANSPORT ct, STORAGE_LIFT_NOMINATION n, CARGO_STATUS_MAPPING  CMAP, BERTH_VERSION B
   where ct.cargo_no = n.cargo_no
   and ct.cargo_status = cmap.cargo_status
   and cmap.ec_cargo_status != 'D'
   and ct.berth_id = B.OBJECT_ID
)