CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_TRANS_INV_LINE_OVERRIDE" ("SOURCE", "DISABLED_IND", "OBJECT_ID", "DAYTIME", "END_DATE", "LABEL", "NAME", "EXEC_ORDER", "VAL_EXEC_ORDER", "SEQ_NO", "DIMENSION_OVER_MONTH_IND", "ROUND_TRANSACTION_IND", "ROUND_VALUE_IND", "TYPE", "CURRENT_PERIOD_ONLY_IND", "PRORATE_LINE", "REBALANCE_METHOD", "XFER_IN_TRANS_ID", "XFER_IN_LINE", "TAG", "PRODUCT_SOURCE_METHOD", "POST_PROCESS_IND", "TRANS_DEF_DIMENSION", "CONTRACT_ID", "DESCRIPTION", "SRC_PROD_STREAM_ID", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "PERIOD", "PERIOD_END", "ORIG_DAYTIME") AS 
  (-------------------------------------------------------------------------------------
--  V_TRANS_INV_LINE_OVERRIDE
--
-- $Revision: 0.1 $
--
--  Purpose: Source view for TRANS_INV_LINE_OVERRIDE class which is used as input to the transactional inventory calculation.
--
--
-- Modification history:
--
-- Date        		Whom            Change description:
-- ------      		-----           ---------------------------------------------------
-- 15-MAR-2016 	  Simen Holvik    Added condition to only retrieve REVN_PROD_STREAM objects (CONTRACT objects with financial code set to REVENUE_STREAM, projects)
-- 06-OCT-2016 	  Simen Holvik    Columns for Post processing indicator flag (POST_PROCESSING_IND) added. [ref. ECPD-33886]
--
-------------------------------------------------------------------------------------
select
'OVERRIDE' as SOURCE,
    NVL(tilo.disabled_ind,'N') disabled_ind,
    tilo.OBJECT_ID,
    tilo.DAYTIME,
    tilo.END_DATE,
    ecdp_trans_inventory.GetLineLabel(tilo.OBJECT_ID,NVL(tilo.src_prod_stream_id,CONTRACT_ID),tilo.TAG,sm.DAYTIME)LABEL,
    til.NAME,
    tilo.EXEC_ORDER,
    tilo.VAL_EXEC_ORDER,
    til.SEQ_NO,
    tilo.DIMENSION_OVER_MONTH_IND,
    tilo.ROUND_TRANSACTION_IND,
    tilo.ROUND_VALUE_IND,
    til.TYPE,
    tilo.CURRENT_PERIOD_ONLY_IND,
    tilo.PRORATE_LINE,
    til.REBALANCE_METHOD,
    tilo.Xfer_In_Trans_Id,
    tilo.XFER_IN_LINE,
    tilo.TAG,
    tilo.PRODUCT_SOURCE_METHOD,
    NVL(tilo.POST_PROCESS_IND,'N') POST_PROCESS_IND,
    tilo.TRANS_DEF_DIMENSION,
    CONTRACT_ID,
    tilo.description,
    NVL(tilo.src_prod_stream_id,CONTRACT_ID) src_prod_stream_id,
    tilo.record_status,
    tilo.created_by,
    tilo.created_date,
    tilo.last_updated_by,
    tilo.last_updated_date,
    tilo.rev_no,
    tilo.rev_text,
    sm.daytime PERIOD,
    ADD_MONTHS(sm.daytime,1) PERIOD_END,
    tilo.DAYTIME ORIG_DAYTIME
from
    trans_inv_line til,
    TRANS_INV_LINE_OVERRIDE tilo,
    (SELECT DISTINCT DAYTIME FROM SYSTEM_MTH_STATUS
       union SELECT DAYTIME FROM TRANS_INV_LINE) sm,
       trans_inv_prod_stream tips,
       trans_inventory_version tiv
WHERE
    tiv.object_id = tips.inventory_id
    and nvl(tiv.config_template,tiv.object_id) = til.object_id
    and tips.inventory_id = tilo.object_id
    AND til.tag = tilo.tag
    AND tips.object_id = tilo.contract_id
    AND sm.daytime >= tips.daytime
    AND sm.daytime < nvl(tips.end_Date,sm.daytime+1)
    AND sm.daytime >= tilo.daytime
    AND sm.DAYTIME < nvl(tilo.end_Date,sm.daytime+1)
    AND sm.daytime >= tiv.daytime
    AND sm.DAYTIME < nvl(tiv.end_Date,sm.daytime+1)
        AND sm.daytime >= til.daytime
    AND sm.DAYTIME < nvl(til.end_Date,sm.daytime+1)
UNION ALL
select
    'TEMPLATE',
    decode(til.TYPE, 'XFER_IN', 'Y', 'N'),
    --til.OBJECT_ID,
    t.object_id,
    til.DAYTIME,
    til.END_DATE,
    ecdp_trans_inventory.GetLineLabel(t.OBJECT_ID,c.objecT_ID,til.TAG,sm.DAYTIME),
    til.NAME,
    til.EXEC_ORDER,
    til.VAL_EXEC_ORDER,
    til.SEQ_NO,
    til.DIMENSION_OVER_MONTH_IND,
    til.ROUND_TRANSACTION_IND,
    til.ROUND_VALUE_IND,
    til.TYPE,
    til.CURRENT_PERIOD_ONLY_IND,
    til.PRORATE_LINE,
    til.REBALANCE_METHOD,
    til.Xfer_In_Trans_Id,
    til.XFER_IN_LINE,
    til.TAG,
    til.PRODUCT_SOURCE_METHOD,
    NVL(til.POST_PROCESS_IND,'N') POST_PROCESS_IND,
    til.TRANS_DEF_DIMENSION,
    c.object_id,
    til.DESCRIPTION,
    c.object_id,
    til.record_status,
    til.created_by,
    til.created_date,
    til.last_updated_by,
    til.last_updated_date,
    til.rev_no,
    til.rev_text,
    sm.daytime PERIOD,
    ADD_MONTHS(sm.daytime,1) PERIOD_END,
    til.DAYTIME ORIG_DAYTIME
from
    trans_inv_line til,
    (SELECT DISTINCT DAYTIME FROM SYSTEM_MTH_STATUS
       union SELECT DAYTIME FROM TRANS_INV_LINE) sm,
       CONTRACT c,
       TRANS_INV_PROD_STREAM tips,
       trans_inventory_version t
WHERE t.object_id = tips.inventory_id
    AND nvl(t.config_template,t.object_id) = til.object_id
    --tips.inventory_id = til.object_id
    AND  sm.daytime >= til.daytime
    AND sm.daytime < nvl(til.end_Date,sm.daytime+1)
    and sm.daytime >= c.start_Date
    AND sm.daytime < nvl(c.end_Date,sm.daytime+1)
    and sm.daytime >= tips.daytime
    AND sm.daytime < nvl(tips.end_Date,sm.daytime+1)
    AND tips.object_id =c.object_id
    AND ec_contract_version.financial_code(c.object_id,sm.daytime,'<=') = 'REVENUE_STREAM'
    AND NOT EXISTS (SELECT OBJECT_ID FROM
            TRANS_INV_LINE_OVERRIDE where
            tips.inventory_id = object_id
            AND til.tag = tag
            AND contract_id = c.object_id
            AND sm.daytime >= daytime
            AND sm.daytime < nvl(end_Date,sm.daytime+1) )
            )