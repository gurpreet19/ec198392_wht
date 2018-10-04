CREATE OR REPLACE FORCE EDITIONABLE VIEW "RV_INV_BOOK_CTRL_REP_GROUP" ("OBJECT_ID", "DAYTIME", "YEAR_CODE", "PK", "ACCT", "COSTOBJECT", "PRODUCT", "ACCT_DESC", "DR_BOOKING_VALUE", "CR_BOOKING_VALUE", "DR_LOCAL", "CR_LOCAL", "DR_GROUP", "CR_GROUP") AS 
  (
SELECT tbl.object_id,
       tbl.daytime,
       tbl.year_code,
       tbl.pk,
       tbl.acct,
       tbl.costobject,
       tbl.product,
       tbl.acct_desc,
       abs(sum(tbl.dr_booking_value)) dr_booking_value,
       abs(sum(tbl.cr_booking_value)) cr_booking_value,
       abs(sum(tbl.dr_local)) dr_local,
       abs(sum(tbl.cr_local)) cr_local,
       abs(sum(tbl.dr_group)) dr_group,
       abs(sum(tbl.cr_group)) cr_group
  from rv_inv_book_ctrl_rep_full tbl
 where NVL(ec_ctrl_system_attribute.attribute_text(daytime, 'CUST_IN_BOOK_REPORT', '<='), 'XXX') <> 'CUSTOM'
 group by tbl.object_id,
          tbl.daytime,
          tbl.year_code,
          tbl.product,
          tbl.acct_desc,
          tbl.acct,
          tbl.pk,
          tbl.costobject
UNION ALL
SELECT "OBJECT_ID","DAYTIME","YEAR_CODE","PK","ACCT","COSTOBJECT","PRODUCT","ACCT_DESC","DR_BOOKING_VALUE","CR_BOOKING_VALUE","DR_LOCAL","CR_LOCAL","DR_GROUP","CR_GROUP" FROM Z_RV_INV_BOOK_CTRL_REP_GROUP
)
 order by acct, costobject, pk desc