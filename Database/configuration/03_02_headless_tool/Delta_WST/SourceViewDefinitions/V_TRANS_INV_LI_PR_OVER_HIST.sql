CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_TRANS_INV_LI_PR_OVER_HIST" ("SOURCE", "PRORATE_LINE", "PRORATE_IND", "PROJECT", "OBJECT_ID", "LINE_TAG", "PERIOD", "PRODUCT_GROUP_ID", "PRODUCT_ID", "COST_TYPE", "PROD_SET_ITEM_ID", "SORT_ORDER", "PRICE_COLUMN", "PRODUCT_COLUMN", "COUNTER_PRODUCT_IND", "REBAL_PRODUCT_IND", "SUM_COST_IND", "DAYTIME", "END_DATE", "DESCRIPTION", "SEQ_NO", "EXEC_ORDER", "VAL_EXEC_ORDER", "QUANTITY_SOURCE_METHOD", "VALUE_METHOD", "TRANS_DEF_DIMENSION", "PRICE_INDEX_ID", "VAL_EXTRACT_TAG", "QTY_EXTRACT_TAG", "VAL_EXTRACT_TYPE", "QTY_EXTRACT_TYPE", "EXTR_VAL_NET_ZERO", "EXTRACT_REVRS_VAL", "EXTRACT_REVRS_QTY", "PRORATE_DIM_TO_PROD_ID", "ID", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "JN_DATETIME_1") AS 
  SELECT DISTINCT 'PRODUCT_OVERRIDE' SOURCE,
       tilpo.PRORATE_LINE,
       nvl(tilpo.PRORATE_IND,'N') PRORATE_IND,
       tilpo.contract_id       project,
       tip.inventory_id    object_id,
       tilpo.TAG            line_tag,
       tilo.period,
       pgs.object_id PRODUCT_GROUP_ID,
       pgs.product_id              PRODUCT_ID,
       cost_type,
       pgs.product_id ||'|PRODUCT' PROD_SET_ITEM_ID,
       pgs.sort_order,
       pgs.price_column,
       pgs.product_column,
       pgs.counter_product_ind,
       pgs.rebal_product_ind,
       null sum_cost_ind,
       tilpo.daytime,
       tilpo.end_Date,
       tilpo.description,
       tilpo.seq_no,
       tilpo.qty_exec_order EXEC_ORDER,
       tilpo.exec_order VAL_EXEC_ORDER,
       tilpo.QTY_SOURCE_METHOD QUANTITY_SOURCE_METHOD,
       tilpo.VALUE_METHOD,
       tilpo.TRANS_DEF_DIMENSION,
       tilpo.PRICE_INDEX PRICE_INDEX_ID,
       tilpo.VAL_EXTRACT_TAG,
       tilpo.QTY_EXTRACT_TAG,
       tilpo.VAL_EXTRACT_TYPE,
       tilpo.QTY_EXTRACT_TYPE,
       tilpo.EXTR_VAL_NET_ZERO,
     tilpo.EXTRACT_REVRS_VAL,
     tilpo.EXTRACT_REVRS_QTY,
       tilpo.prorate_dim_to_prod_id,
       'OVERRIDE|' || tilpo.id || '|'||pgs.product_id ID,
       tilpo.RECORD_STATUS,
       tilpo.CREATED_BY ,
       tilpo.CREATED_DATE ,
       tilpo.LAST_UPDATED_BY ,
       tilpo.LAST_UPDATED_DATE  ,
       tilpo.REV_NO  ,
       tilpo.REV_TEXT,
     tilpo.jn_datetime jn_datetime_1
FROM
       V_TRANS_INV_LINE_OVER_HIST tilo,
       V_PRODUCT_GROUP_SETUP_HIST pgs,
       contract_attribute ca,
       v_trans_inv_prod_stream_hist tip,
       v_trans_inv_li_pr_over_h tilpo,
       v_trans_inventory_history t
WHERE  t.object_id = tip.inventory_id
       and t.object_id = tilo.OBJECT_ID
       and tip.object_id = tilo.CONTRACT_ID
       and tip.object_id = tilpo.CONTRACT_ID
       AND tilpo.product_id = pgs.product_id
       AND tilpo.tag = tilo.TAG
       AND tilpo.daytime <= tilo.period
       and cost_type = 'PRODUCT'
       and tilpo.object_id = t.object_id
       and nvl(tilpo.end_Date,tilo.period+1) > tilo.period
       AND ca.daytime <= tilo.period
       and nvl(ca.end_Date,tilo.period+1) > tilo.period
       AND pgs.daytime <= tilo.period
       and nvl(pgs.end_Date,tilo.period+1) > tilo.period
       AND tip.daytime <= tilo.period
       and nvl(tip.end_Date,tilo.period+1) > tilo.period
       and ca.attribute_name = 'TRANS_INV_PROD_GROUP'
       AND ca.object_id = tip.object_id
       AND ca.attribute_string = pgs.object_id
UNION ALL
-- Costs with override
SELECT DISTINCT 'COST_OVERRIDE' SOURCE,
       tilpo.PRORATE_LINE,
       nvl(tilpo.PRORATE_IND,'N') ,
       tip.object_id project_id,
       tip.inventory_id,
       tilo.TAG,
       tilo.period,
       pgs.object_id /*TRANS_PROD_SET_id*/PRODUCT_GROUP_ID,
       pgs.product_id,
       pgc.cost_type,
       pgs.product_id ||'|' || tilpo.cost_type PROD_SET_ITEM_ID,
       pgc.sort_order,
       pgs.price_column,
       pgc.cost_column,
       null,
       null,
       pgc.sum_value_cost_ind,
       tilpo.daytime,
       tilpo.end_Date,
       tilpo.description       ,
       tilpo.seq_no,
       tilpo.qty_exec_order,
       tilpo.exec_order ,
       tilpo.QTY_SOURCE_METHOD,
       tilpo.VALUE_METHOD,
       tilpo.TRANS_DEF_DIMENSION,
       tilpo.PRICE_INDEX,
       tilpo.VAL_EXTRACT_TAG,
       tilpo.QTY_EXTRACT_TAG,
       tilpo.VAL_EXTRACT_TYPE,
       tilpo.QTY_EXTRACT_TYPE,
       tilpo.EXTR_VAL_NET_ZERO,
     tilpo.EXTRACT_REVRS_VAL,
     tilpo.EXTRACT_REVRS_QTY,
       tilpo.prorate_dim_to_prod_id,
       'OVERRIDE|' || tilpo.id  || '|'||pgs.product_id ||'|'|| pgc.cost_type,
       tilpo.RECORD_STATUS,
       tilpo.CREATED_BY ,
       tilpo.CREATED_DATE ,
       tilpo.LAST_UPDATED_BY ,
       tilpo.LAST_UPDATED_DATE  ,
       tilpo.REV_NO  ,
       tilpo.REV_TEXT,
     tilpo.jn_datetime jn_datetime_1
  FROM
       V_TRANS_INV_LINE_OVER_HIST tilo,
       V_PRODUCT_GROUP_SETUP_HIST pgs,
       contract_attribute ca,
       v_trans_inv_prod_stream_hist tip,
       V_PRODUCT_GROUP_COST_HIST pgc,
       v_trans_inv_li_pr_over_h tilpo,
       v_trans_inventory_history t
WHERE  t.object_id = tip.inventory_id
       and t.object_id = tilo.OBJECT_ID
       and tip.object_id = tilo.CONTRACT_ID
       and tip.object_id = tilpo.CONTRACT_ID
       and t.object_id = tilpo.object_id
       AND tilpo.product_id = pgs.product_id
       AND tilpo.tag = tilo.TAG
       and pgc.cost_type = tilpo.cost_type
       AND tilpo.daytime <= tilo.period
       AND pgc.daytime <= tilo.period
       and nvl(pgc.end_Date,tilo.period+1) > tilo.period
       and nvl(tilpo.end_Date,tilo.period+1) > tilo.period
       AND ca.daytime <= tilo.period
       and nvl(ca.end_Date,tilo.period+1) > tilo.period
       AND pgs.daytime <= tilo.period
       and nvl(pgs.end_Date,tilo.period+1) > tilo.period
       AND tip.daytime <= tilo.period
       and nvl(tip.end_Date,tilo.period+1) > tilo.period
       and ca.attribute_name = 'TRANS_INV_PROD_GROUP'
       AND ca.object_id = tip.object_id
       AND ca.attribute_string = pgs.object_id
       AND pgc.cost_type != 'PRODUCT'
       AND pgs.object_id = pgc.object_id
       AND pgs.product_id = pgc.product_id
UNION ALL
-- Products without override
SELECT DISTINCT 'PRODUCT_TEMPLATE' SOURCE,
       tilp.PRORATE_LINE,
      nvl(tilp.PRORATE_IND,'N') ,
       tip.object_id project_id,
       tip.inventory_id object_id,
       --tilo.object_id trans_inventory_id,
       tilo.TAG,
       tilo.period,
       pgs.object_id /*TRANS_PROD_SET_id*/PRODUCT_GROUP_ID,
       pgs.product_id,
       cost_type,
       pgs.product_id ||'|PRODUCT' PROD_SET_ITEM_ID,
       pgs.sort_order,
       pgs.price_column,
       pgs.product_column,
       pgs.counter_product_ind,
       pgs.rebal_product_ind,
       null sum_cost_ind,
       tilp.daytime,
       tilp.end_Date,
       tilo.description,
       pgs.sort_order seq_no,
       tilp.exec_order,
       tilp.val_exec_order,
       tilp.quantity_source_method,
       tilp.VALUE_METHOD,
       tilo.trans_DEF_DIMENSION,
       tilp.PRICE_INDEX_id,
       tilp.VAL_EXTRACT_TAG,
       tilp.QTY_EXTRACT_TAG,
       tilp.VAL_EXTRACT_TYPE,
       tilp.QTY_EXTRACT_TYPE,
       tilp.EXTR_VAL_NET_ZERO,
       tilp.extract_revrs_val,
       tilp.extract_revrs_qty,
       tilp.prorate_dim_to_prod_id,
       'TEMPLATE|' || tilp.id  || '|'||pgs.product_id ,
       tilp.RECORD_STATUS,
       tilp.CREATED_BY ,
       tilp.CREATED_DATE ,
       tilp.LAST_UPDATED_BY ,
       tilp.LAST_UPDATED_DATE  ,
       tilp.REV_NO  ,
       tilp.REV_TEXT,
     tilp.jn_datetime jn_datetime_1
FROM V_TRANS_INV_LINE_OVER_HIST tilo,
      V_PRODUCT_GROUP_SETUP_HIST pgs,
      contract_attribute ca,
      v_trans_inv_prod_stream_hist tip,
      v_trans_inv_li_product_hist tilp,
      v_trans_inventory_history t
WHERE  t.object_id = tip.inventory_id -- prod stream connected to  non-template
       and t.object_id = tilo.object_id   -- tilo has already converted template to non
       AND t.object_id= tilp.OBJECT_ID --product is unknown if template or not
       AND ca.daytime <= tilo.period
       and nvl(ca.end_Date,tilo.period+1) > tilo.period
       AND pgs.daytime <= tilo.period
       and nvl(pgs.end_Date,tilo.period+1) > tilo.period
       AND tip.daytime <= tilo.period
       and nvl(tip.end_Date,tilo.period+1) > tilo.period
       AND tilp.daytime <= tilo.period
       and nvl(tilp.end_Date,tilo.period+1) > tilo.period
       and ca.attribute_name = 'TRANS_INV_PROD_GROUP'
       AND ca.object_id = tip.object_id
       AND tilp.cost_type = 'PRODUCT'
       AND ca.attribute_string = pgs.object_id
       AND tilo.CONTRACT_ID = ca.object_id
       AND tilp.product_id = pgs.product_id
       AND tilp.line_tag = tilo.TAG
       AND tilp.daytime <= tilo.period
       and nvl(tilp.end_Date,tilo.period+1) > tilo.period
       and not exists (
           select object_id from trans_inv_li_pr_over tilpo
                            where tilpo.contract_id = tip.object_id
                              and tilpo.tag = tilp.line_tag
                              and (tilpo.object_id = tip.inventory_id OR t.CONFIG_TEMPLATE=tilpo.object_id)
                              and tilpo.product_id = PGS.PRODUCT_ID
                              and tilpo.cost_type = 'PRODUCT'
                              AND tilpo.daytime <= tilo.period
                              AND tilpo.contract_id = tilo.CONTRACT_ID
                              and nvl(tilpo.end_Date,tilo.period+1) >= tilo.period)
UNION ALL
-- Costs Without Override
SELECT DISTINCT 'COST_TEMPLATE' SOURCE,
       tilp.PRORATE_LINE,
       nvl(tilp.PRORATE_IND,'N') ,
       tip.object_id project_id,
       tip.inventory_id object_id,
       tilo.TAG,
       tilo.period,
       pgs.object_id /*TRANS_PROD_SET_id*/PRODUCT_GROUP_ID,
       pgs.product_id,
       pgc.cost_type,
       pgs.product_id ||'|' || pgc.cost_type PROD_SET_ITEM_ID,
       pgc.sort_order,
       pgs.price_column,
       pgc.cost_column,
       null,
       null,
       pgc.sum_value_cost_ind       ,
       tilp.daytime,
       tilp.end_Date,
       tilp.description,
       pgs.sort_order + pgc.sort_order/1000 seq_no,
       tilp.exec_order,
       tilp.val_exec_order,
       tilp.quantity_source_method,
       tilp.VALUE_METHOD,
       tilo.TRANS_DEF_DIMENSION,
       tilp.PRICE_INDEX_id,
       tilp.VAL_EXTRACT_TAG,
       tilp.QTY_EXTRACT_TAG,
       tilp.VAL_EXTRACT_TYPE,
       tilp.QTY_EXTRACT_TYPE,
       tilp.EXTR_VAL_NET_ZERO,
     tilp.EXTRACT_REVRS_VAL,
     tilp.EXTRACT_REVRS_QTY,
       tilp.prorate_dim_to_prod_id,
       'TEMPLATE|' || tilp.id  || '|'||pgs.product_id ||'|'|| pgc.cost_type,
       tilp.RECORD_STATUS,
       tilp.CREATED_BY ,
       tilp.CREATED_DATE ,
       tilp.LAST_UPDATED_BY ,
       tilp.LAST_UPDATED_DATE  ,
       tilp.REV_NO  ,
       tilp.REV_TEXT,
       tilp.JN_DATETIME jn_datetime_1
FROM
       V_TRANS_INV_LINE_OVER_HIST tilo,
       v_PRODUCT_GROUP_SETUP_HIST pgs,
       contract_attribute ca,
       v_trans_inv_prod_stream_hist tip,
       V_PRODUCT_GROUP_COST_HIST pgc,
       v_trans_inv_li_product_hist tilp,
      v_trans_inventory_history t
WHERE  t.object_id = tip.inventory_id -- prod stream connected to  non-template
       AND t.object_id = tilo.object_id   -- tilo has already converted template to non
       AND t.object_id = tilp.OBJECT_ID --product is unknown if template or not
	   AND  ca.daytime <= tilo.period
	   AND nvl(ca.end_Date,tilo.period+1) > tilo.period
       AND pgs.daytime <= tilo.period
       and nvl(pgs.end_Date,tilo.period+1) > tilo.period
       AND pgc.daytime <= tilo.period
       and nvl(pgc.end_Date,tilo.period+1) > tilo.period
       AND tip.daytime <= tilo.period
       and nvl(tip.end_Date,tilo.period+1) > tilo.period
       AND tilp.daytime <= tilo.period
       and nvl(tilp.end_Date,tilo.period+1) > tilo.period
       AND pgc.cost_type != 'PRODUCT'
       and ca.attribute_name = 'TRANS_INV_PROD_GROUP'
       AND ca.attribute_string = pgs.object_id
       AND ca.object_id = tip.object_id
       AND tilo.CONTRACT_ID = ca.object_id
       AND pgs.object_id = pgc.object_id
       AND pgs.product_id = pgc.product_id
       AND pgc.cost_type = tilp.cost_type
       AND tilp.product_id = pgs.product_id
       AND tilp.line_tag = tilo.TAG
       AND tilp.daytime <= tilo.period
       and nvl(tilp.end_Date,tilo.period+1) > tilo.period
       and not exists (
           select object_id from trans_inv_li_pr_over tilpo
                            where tilpo.contract_id = tip.object_id
                              and tilpo.tag = tilp.line_tag
                              and (tilpo.object_id = tip.inventory_id OR t.CONFIG_TEMPLATE=tilpo.object_id)
                              and tilpo.product_id = PGS.PRODUCT_ID
                              and tilpo.cost_type = pgc.cost_type
                              AND tilpo.daytime <= tilo.period
                              AND tilpo.contract_id = tilo.CONTRACT_ID
                              and nvl(tilpo.end_Date,tilo.period+1) >= tilo.period)
UNION ALL
--Default
SELECT DISTINCT 'PRODUCT_DEFAULT' SOURCE,
       tilo.PRORATE_LINE,
       'N',
       tip.object_id project_id,
       --tilo.OBJECT_ID trans_inventory_id,
       tip.inventory_id object_id,
       tilo.TAG,
       tilo.period,
       pgs.object_id /*TRANS_PROD_SET_id*/PRODUCT_GROUP_ID,
       pgs.product_id,
       'PRODUCT' cost_type,
       pgs.product_id ||'|PRODUCT' PROD_SET_ITEM_ID,
       pgs.sort_order,
       pgs.price_column,
       pgs.product_column,
       pgs.counter_product_ind,
       pgs.rebal_product_ind,
       null sum_cost_ind,
       tilo.daytime,
       tilo.end_Date,
       tilo.description,
       pgs.sort_order,
       pgs.sort_order,
       pgs.sort_order,
       ecdp_trans_inventory.getdefaultQtyMtd(tilo.TYPE,tilo.PRORATE_LINE,tilo.PRODUCT_SOURCE_METHOD,pgs.object_id,pgs.product_id,pgs.counter_product_ind,pgs.master_ind,'PRODUCT','N'), --need Logic qty method
       ecdp_trans_inventory.getdefaultValMtd(tilo.TYPE,tilo.PRORATE_LINE,tilo.PRODUCT_SOURCE_METHOD,pgs.object_id,pgs.product_id,pgs.counter_product_ind,pgs.master_ind,'PRODUCT','N',tilo.TYPE),  --need Logic value method
       tilo.TRANS_DEF_DIMENSION,
       null,
       null,
       null,
       'REVN_PROD_STREAM',
       'REVN_PROD_STREAM',
       null,
       NULL,
       NULL,
       ecdp_trans_inventory.getdefaultProRateProduct(tilo.TYPE,tilo.PRORATE_LINE,tilo.PRODUCT_SOURCE_METHOD,pgs.object_id,pgs.product_id,PGS.COUNTER_PRODUCT_IND,'PRODUCT',NULL,mp.product_id),
       'DEFAULT|' || tip.object_id||'|'||tilo.tag ||'|'||tilo.object_id||'|'||PGS.PRODUCT_ID||'|'||'PRODUCT'||'-'||PERIOD id,
       tilo.RECORD_STATUS,
       tilo.CREATED_BY ,
       tilo.CREATED_DATE ,
       tilo.LAST_UPDATED_BY ,
       tilo.LAST_UPDATED_DATE  ,
       tilo.REV_NO  ,
       tilo.REV_TEXT,
     tilo.over_jn_datetime jn_datetime_1
 FROM  V_TRANS_INV_LINE_OVER_HIST tilo,
       V_PRODUCT_GROUP_SETUP_HIST pgs,
       contract_attribute ca,
       v_trans_inv_prod_stream_hist tip,
 v_trans_inventory_history t,
       V_PRODUCT_GROUP_SETUP_HIST mp
WHERE  t.object_id = tip.inventory_id
       AND t.object_id = tilo.OBJECT_ID
	   AND ca.attribute_name = 'TRANS_INV_PROD_GROUP'
       AND ca.object_id = tip.object_id
       AND ca.attribute_string = pgs.object_id
       AND ca.object_id = tilo.CONTRACT_ID
       AND ca.daytime <= tilo.period
       and nvl(ca.end_Date,tilo.period+1) > tilo.period
       AND pgs.daytime <= tilo.period
       and nvl(pgs.end_Date,tilo.period+1) > tilo.period
       AND tip.daytime <= tilo.period
       and nvl(tip.end_Date,tilo.period+1) > tilo.period
       AND mp.master_ind(+) = 'Y'
       AND mp.object_id(+) = pgs.object_id
       and not exists (
           select object_id from trans_inv_li_pr_over tilpo
                            where tilpo.contract_id = tip.object_id
                              and tilpo.tag = tilo.tag
                              and tilpo.object_id = tip.inventory_id
                              and tilpo.product_id = PGS.PRODUCT_ID
                              and tilpo.cost_type = 'PRODUCT'
                              AND tilpo.CONTRACT_ID = tilo.contract_id
                              AND tilpo.daytime <= tilo.period
                              and nvl(tilpo.end_Date,tilo.period+1) > tilo.period)
       and not exists (
           select object_id from trans_inv_li_product tilp
                            where tilo.tag = tilp.line_tag
                              and nvl(t.config_template,t.object_id) = tilp.object_id
                              and tilp.product_id = PGS.PRODUCT_ID
                              and cost_type = 'PRODUCT'
                              AND tilp.daytime <= tilo.period
                              and nvl(tilp.end_Date,tilo.period+1) > tilo.period)
UNION ALL
-- Costs Without Override
SELECT DISTINCT 'COST_DEFAULT' SOURCE,
      tilo.PRORATE_LINE,
      'N',
       tip.object_id project_id,
       tip.inventory_id object_id,
       --tilo.OBJECT_ID trans_inventory_id,
       tilo.TAG,
       tilo.period,
       pgs.object_id /*TRANS_PROD_SET_id*/PRODUCT_GROUP_ID,
       pgs.product_id,
       pgc.cost_type,
       pgs.product_id ||'|' || cost_type PROD_SET_ITEM_ID,
       pgc.sort_order,
       pgs.price_column,
       pgc.cost_column,
       null,
       null,
       pgc.sum_value_cost_ind       ,
       tilo.daytime,
       tilo.end_Date,
       'Default Logic',
       pgs.sort_order + pgc.sort_order/1000 sort_order,
       pgc.sort_order,
       pgc.sort_order,
       ecdp_trans_inventory.getdefaultQtyMtd(tilo.TYPE,tilo.PRORATE_LINE,tilo.PRODUCT_SOURCE_METHOD,pgs.object_id,pgs.product_id,pgs.counter_product_ind,pgs.master_ind,pgc.cost_type,pgc.sum_value_cost_ind), --need Logic qty method
       ecdp_trans_inventory.getdefaultValMtd(tilo.TYPE,tilo.PRORATE_LINE,tilo.PRODUCT_SOURCE_METHOD,pgs.object_id,pgs.product_id,pgs.counter_product_ind,pgs.master_ind,pgc.cost_type,pgc.sum_value_cost_ind,tilo.TYPE),  --need Logic value method
       tilo.TRANS_DEF_DIMENSION,
       null,
       null,
       null,
       'REVN_PROD_STREAM',
       'REVN_PROD_STREAM',
       NULL,
       NULL,
       NULL,
       ecdp_trans_inventory.getdefaultProRateProduct(tilo.TYPE,tilo.PRORATE_LINE,tilo.PRODUCT_SOURCE_METHOD,pgs.object_id,pgs.product_id,pgs.counter_product_ind,COST_TYPE,pgc.sum_value_cost_ind,mp.product_id), --need Logic prorate line
       'DEFAULT|' || tip.object_id||'|'||tilo.tag ||'|'||tip.inventory_id||'|'||PGS.PRODUCT_ID||'|'||pgc.cost_type||'-'||PERIOD id ,
       tilo.RECORD_STATUS,
       tilo.CREATED_BY ,
       tilo.CREATED_DATE ,
       tilo.LAST_UPDATED_BY ,
       tilo.LAST_UPDATED_DATE  ,
       tilo.REV_NO  ,
       tilo.REV_TEXT,
     tilo.over_jn_datetime jn_datetime_1
 FROM
       V_TRANS_INV_LINE_OVER_HIST tilo,
       V_PRODUCT_GROUP_SETUP_HIST pgs,
       contract_attribute ca,
       v_trans_inv_prod_stream_hist tip,
       V_PRODUCT_GROUP_COST_HIST pgc,
 v_trans_inventory_history t,
       V_PRODUCT_GROUP_SETUP_HIST mp
WHERE  t.object_id = tip.inventory_id
       and t.object_id = tilo.OBJECT_ID
	   AND ca.daytime <= tilo.period
       and nvl(ca.end_Date,tilo.period+1) > tilo.period
       AND pgs.daytime <= tilo.period
       and nvl(pgs.end_Date,tilo.period+1) > tilo.period
       AND pgc.daytime <= tilo.period
       and nvl(pgc.end_Date,tilo.period+1) > tilo.period
       AND tip.daytime <= tilo.period
       and nvl(tip.end_Date,tilo.period+1) > tilo.period
       and ca.attribute_name = 'TRANS_INV_PROD_GROUP'
       AND pgc.cost_type != 'PRODUCT'
       AND ca.object_id = tip.object_id
       AND ca.attribute_string = pgs.object_id
       AND pgs.object_id = pgc.object_id
       AND pgs.product_id = pgc.product_id
       AND tilo.CONTRACT_ID = ca.object_id
       AND mp.master_ind(+) = 'Y'
       AND mp.object_id(+) = pgs.object_id
       and not exists (
           select object_id from trans_inv_li_pr_over tilpo
                            where tilpo.contract_id = tip.object_id
                              and tilpo.tag = tilo.tag
                              and tilpo.object_id = tip.inventory_id
                              and tilpo.product_id = PGS.PRODUCT_ID
                              and tilpo.cost_type = pgc.cost_type
                              AND tilpo.daytime <= tilo.period
                              AND tilpo.CONTRACT_ID = tilo.contract_id
                              and nvl(tilpo.end_Date,tilo.period+1) > tilo.period)
       and not exists (
           select object_id from trans_inv_li_product tilp
                            where tilp.line_tag = tilo.tag
                              and tilp.object_id = nvl(t.config_template,t.object_id)
                              and tilp.product_id = pgs.product_id
                              and tilp.cost_type = pgc.cost_type
                              AND tilp.daytime <= tilo.period
                              and nvl(tilp.end_Date,tilo.period+1) > tilo.period)