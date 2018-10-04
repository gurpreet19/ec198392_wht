CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_FCST_CARRIER_DAY" ("DAYTIME", "CLASS_NAME", "FORECAST_ID", "OBJECT_CODE", "OBJECT_ID", "CARRIER_CODE", "PRODUCT_GROUP", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID", "RECORD_STATUS") AS 
  (
/**************************************************************
** Script:	v_fcst_carrier_day.sql
**
** $Revision: 1.1 $
**
** Purpose:
**
** General Logic:
**
** Created:   16.01.2013  Andy
**
-- Modification history:
--
-- Date       Whom  Change description:
-- ---------- ----  --------------------------------------------------------------------------------
**************************************************************/
 SELECT
 distinct(f.daytime),
 fc.class_name,
 fc.object_id as forecast_id,
 fc.object_code as object_code,
 c.OBJECT_ID as object_id,
 c.object_code as carrier_code,
 ec_carrier_version.product_group(c.OBJECT_ID, f.daytime, '<=') as product_group,
 NULL as created_by,
 NULL as created_date,
 NULL as last_updated_by,
 NULL as last_updated_date,
 NULL as rev_no,
 NULL as rev_text,
 NULL as approval_by,
 NULL as approval_date,
 NULL as approval_state,
 NULL as rec_id,
 NULL as record_status
 FROM stor_day_fcst_fcast f,carrier c,FORECAST fc
 where fc.start_date>=c.start_date
 and c.start_date<=f.daytime
 and f.daytime>=fc.start_date
 and f.daytime<fc.end_date
 )
  order by daytime, object_code,carrier_code asc