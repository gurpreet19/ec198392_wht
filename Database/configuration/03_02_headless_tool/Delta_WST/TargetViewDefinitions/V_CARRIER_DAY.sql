CREATE OR REPLACE FORCE VIEW "V_CARRIER_DAY" ("DAYTIME", "OBJECT_ID", "PRODUCT_GROUP", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_BY", "APPROVAL_DATE", "APPROVAL_STATE", "REC_ID", "RECORD_STATUS") AS 
  (
/**************************************************************
** Script:	v_carrier_day.sql
**
** $Revision: 1.1.2.2 $
**
** Purpose:
**
** General Logic:
**
** Created:   07.01.2013  Lee Wei Yap
**
-- Modification history:
--
-- Date       Whom     Change description:
-- ---------- ----     --------------------------------------------------------------------------------
** 31.01.2013 leeeewei	Added product group
**************************************************************/
 SELECT distinct(f.DAYTIME),
 c.OBJECT_ID,
 ec_carrier_version.product_group(c.object_id,f.daytime,'<=')PRODUCT_GROUP,
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
 FROM stor_day_forecast f,carrier c
 )
 order by daytime ASC