CREATE OR REPLACE FORCE EDITIONABLE VIEW "Z_RV_INV_BOOK_CTRL_REP_FULL" ("NUM", "OBJECT_ID", "DAYTIME", "YEAR_CODE", "PK", "ACCT", "COSTOBJECT", "PRODUCT", "ACCT_DESC", "DR_BOOKING_VALUE", "CR_BOOKING_VALUE", "DR_LOCAL", "CR_LOCAL", "DR_GROUP", "CR_GROUP") AS 
  (
SELECT NULL num,
       NULL object_id,
       NULL daytime,
       NULL year_code,
       NULL pk,
       NULL acct,
       NULL costobject,
       NULL product,
       NULL acct_desc,
       NULL dr_booking_value,
       NULL cr_booking_value,
       NULL dr_local,
       NULL cr_local,
       NULL dr_group,
       NULL cr_group
  FROM ctrl_db_version
 WHERE 1 = 2
)