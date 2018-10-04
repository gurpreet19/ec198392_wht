CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_TRANSACTION_DISTRIBUTION" ("OBJECT_ID", "OBJECT_CODE", "DAYTIME", "FIELD_ID", "STREAM_ID", "FROM_NODE_ID", "TO_NODE_ID", "FINANCIAL_CODE", "PRODUCT_ID", "COMPANY_ID", "MASTER_UOM_GROUP", "UOM_CODE") AS 
  (
----------------------------------------------------------------------------------------------------
--
-- File name: v_transaction_distribution.sql
-- View name: v_transaction_distribution
--
-- $Revision: 1.4 $
--
-- Purpose  : This view is used when transaction distribution is needed but there's no split key setup available to determine distribution from
--            The view should be used at transaction level, field level and company level by applying the proper were-clause.
--
-- Modification history:
--
-- Version  Date        Whom    Change description:
-----------------------------------------------------------------------------------------------------------------------------------
--         09.11.2010 SSK   Initial version
-----------------------------------------------------------------------------------------------------------------------------------
select si.object_id,
       si.object_code,
       siv.daytime,
       siv.field_id,
       s.object_id stream_id,
       sv.from_node_id,
       sv.to_node_id,
       pc.code financial_code,
       siv.product_id,
       siv.company_id,
       siv.master_uom_group,
       DECODE(siv.master_uom_group,
               'M',siv.default_uom_mass,
               'E',siv.default_uom_energy,
               'V',siv.default_uom_volume) uom_code
  from stream_item             si,
       stream_item_version     siv,
       stream                  s,
       strm_version            sv,
       stream_category         sc,
       stream_category_version scv,
       prosty_codes            pc
 where si.object_id = siv.object_id
   and nvl(siv.excl_trans_dist_ind,'N') = 'N'
   and siv.daytime = (select max(siv_sub.daytime)
                        from stream_item_version siv_sub
                       where siv_sub.object_id = siv.object_id
                         and siv_sub.daytime <= siv.daytime)
   and s.object_id = si.stream_id
   and sv.object_id = s.object_id
   and sv.daytime =
       (select max(sv_sub.daytime)
          from strm_version sv_sub
         where sv_sub.object_id = sv.object_id
           and sv_sub.daytime <= siv.daytime
           and sv.daytime < nvl(sv_sub.end_date, sv.daytime + 1))
   and pc.code_type = 'FINANCIAL_CODE'
   and sc.object_id = scv.object_id
   and scv.daytime =
       (select max(scv_sub.daytime)
          from stream_category_version scv_sub
         where scv_sub.object_id = scv.object_id
           and scv_sub.daytime <= scv.daytime
           and scv.daytime < nvl(scv_sub.end_date, scv.daytime + 1))
   and sv.stream_category_id = sc.object_id
   and ('Y' = decode(pc.code, 'SALE', scv.revn_sales_ind) or
       'Y' = decode(pc.code, 'PURCHASE', scv.revn_purchases_ind) or
       'Y' = decode(pc.code, 'TA_INCOME', scv.revn_ta_income_ind) or
       'Y' = decode(pc.code, 'TA_COST', scv.revn_ta_cost_ind) or
       'Y' = decode(pc.code, 'JOU_ENT', scv.revn_jou_ent_ind))
   and nvl(siv.parent_field_type, 'x') NOT IN ('PARENT'))