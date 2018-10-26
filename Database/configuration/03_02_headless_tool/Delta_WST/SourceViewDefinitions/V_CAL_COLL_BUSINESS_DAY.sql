CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CAL_COLL_BUSINESS_DAY" ("OBJECT_ID", "DAYTIME", "OFFSET", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_calendar_coll_business_day.sql
-- View name: v_calendar_coll_business_day
--
-- $Revision: 1.1 $
--
-- Purpose  : To Prepare the information in use by the calculation engine when calculating payment due date for EC Revenue invoices.
--
-- Modification history:
--
-- Date       Whom  Change description:
-- ---------- ----  --------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
  SELECT t.calendar_collection_id as object_id
  ,      t.daytime
  ,      t.offset
  ,      'P'                      record_status
  ,      NULL                     created_by
  ,      NULL                     created_date
  ,      NULL                     last_updated_by
  ,      NULL                     last_updated_date
  ,      NULL                     rev_no
  ,      NULL                     rev_text
  FROM   (
         SELECT DISTINCT cs.calendar_collection_id,
                         co.offset,
                         cd.daytime
           FROM calendar_coll_setup cs, calendar_offset co, calendar_day cd
          WHERE cd.object_id = cs.object_id
  ) t
)