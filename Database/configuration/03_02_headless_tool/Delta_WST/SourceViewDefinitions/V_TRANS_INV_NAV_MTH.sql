CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_TRANS_INV_NAV_MTH" ("DAYTIME", "PREV_MONTH", "NEXT_MONTH", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT") AS 
  select DISTINCT DAYTIME,
       ADD_MONTHS(trunc(daytime,'MM'),-1) PREV_MONTH,
       ADD_MONTHS(trunc(daytime,'MM'),1) NEXT_MONTH,
       NULL RECORD_STATUS,
       NULL CREATED_BY ,
       NULL CREATED_DATE ,
       NULL LAST_UPDATED_BY ,
       NULL LAST_UPDATED_DATE  ,
       NULL REV_NO  ,
       NULL REV_TEXT
  FROM system_mth_status
 WHERE BOOKING_AREA_CODE = 'INVENTORY'