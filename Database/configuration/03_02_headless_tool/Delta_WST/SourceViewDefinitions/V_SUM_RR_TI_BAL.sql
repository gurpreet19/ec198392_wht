CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_SUM_RR_TI_BAL" ("LAYER_MONTH", "DAYTIME", "TRANS_INV_CODE", "OBJECT_ID", "REF_TAG", "CLASS_NAME", "TRANS_INV_ID", "DIMENSION_TAG", "QTY_1", "QTY_2", "QTY_3", "QTY_4", "QTY_5", "QTY_6", "QTY_7", "QTY_8", "QTY_9", "QTY_10", "VALUE_1", "VALUE_2", "VALUE_3", "VALUE_4", "VALUE_5", "VALUE_6", "VALUE_7", "VALUE_8", "VALUE_9", "VALUE_10", "COST_1", "COST_2", "COST_3", "COST_4", "COST_5", "COST_6", "COST_7", "COST_8", "COST_9", "COST_10", "COST_11", "COST_12", "COST_13", "COST_14", "COST_15", "COST_16", "COST_17", "COST_18", "COST_19", "COST_20", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REC_ID", "REV_NO", "RECORD_STATUS") AS 
  SELECT decode(rrc.layer_ind,'Y',tt.layer_month,tt.daytime) layer_month,
       tt.daytime ,
       decode(rrc.trans_inv_ind,'Y',trans_inv_code,'ALL') trans_inv_code,
       object_id,
       ref_tag,
       'CONTRACT' AS class_name,
       decode(rrc.trans_inv_ind,'Y',trans_inv_id,'ALL') trans_inv_id,
       decode(rrc.dimension_ind,'Y',substr(DIMENSION_TAG,1,decode(instr(DIMENSION_TAG,'|'),0,LENGTH(DIMENSION_TAG),instr(DIMENSION_TAG,'|')-1)),'ALL')|| '|'||--Dimension 1
       decode(rrc.dimension_2_ind,'Y',substr(DIMENSION_TAG,instr(DIMENSION_TAG, '|'), instr(DIMENSION_TAG,'|',instr(DIMENSION_TAG, '|')-instr(DIMENSION_TAG, '|'))) ,'ALL') || '|'||--Dimension 2
       decode(rrc.prod_mth_ind,'Y',DECODE(DIMENSION_TAG,'ALL',to_char(tt.DAYTIME,'YYYY-MM-DD') || 'T00:00:00',decode(dimension_tag,'NA',NULL,substr(dimension_tag,instr(dimension_tag,'|',-1)+1))),to_char(tt.daytime,'YYYY-MM-DD') || 'T00:00:00') -- Prod Month
       dimension_tag,
       SUM(NVL(tt.qty_1,0)) qty_1,
       SUM(NVL(tt.qty_2,0)) as qty_2,
       SUM(NVL(tt.qty_3,0)) as qty_3,
       SUM(NVL(tt.qty_4,0)) as qty_4,
       SUM(NVL(tt.qty_5,0)) as qty_5,
       SUM(NVL(tt.qty_6,0)) as qty_6,
       SUM(NVL(tt.qty_7,0)) as qty_7,
       SUM(NVL(tt.qty_8,0)) as qty_8,
       SUM(NVL(tt.qty_9,0)) as qty_9,
       SUM(NVL(tt.qty_10,0)) as qty_10,
       SUM(NVL(tt.value_1,0)) as value_1,
       SUM(NVL(tt.value_2,0)) as value_2,
       SUM(NVL(tt.value_3,0)) as value_3,
       SUM(NVL(tt.value_4,0)) as value_4,
       SUM(NVL(tt.value_5,0)) as value_5,
       SUM(NVL(tt.value_6,0)) as value_6,
       SUM(NVL(tt.value_7,0)) as value_7,
       SUM(NVL(tt.value_8,0)) as value_8,
       SUM(NVL(tt.value_9,0)) as value_9,
       SUM(NVL(tt.value_10,0)) as value_10,
       SUM(NVL(tt.cost_1,0)) as cost_1,
       SUM(NVL(tt.cost_2,0)) as cost_2,
       SUM(NVL(tt.cost_3,0)) as cost_3,
       SUM(NVL(tt.cost_4,0)) as cost_4,
       SUM(NVL(tt.cost_5,0)) as cost_5,
       SUM(NVL(tt.cost_6,0)) as cost_6,
       SUM(NVL(tt.cost_7,0)) as cost_7,
       SUM(NVL(tt.cost_8,0)) as cost_8,
       SUM(NVL(tt.cost_9,0)) as cost_9,
       SUM(NVL(tt.cost_10,0)) as cost_10,
       SUM(NVL(tt.cost_11,0)) as cost_11,
       SUM(NVL(tt.cost_12,0)) as cost_12,
       SUM(NVL(tt.cost_13,0)) as cost_13,
       SUM(NVL(tt.cost_14,0)) as cost_14,
       SUM(NVL(tt.cost_15,0)) as cost_15,
       SUM(NVL(tt.cost_16,0)) as cost_16,
       SUM(NVL(tt.cost_17,0)) as cost_17,
       SUM(NVL(tt.cost_18,0)) as cost_18,
       SUM(NVL(tt.cost_19,0)) as cost_19,
       SUM(NVL(tt.cost_20,0)) as cost_20,
       null rev_text,
       null approval_state,
       null approval_by,
       null approval_date,
       null created_by,
       null created_date,
       null last_updated_by,
       null last_updated_date,
       null rec_id,
       null rev_no,
       null record_status
  FROM v_rr_ti_bal tt,
       report_ref_connection rrc
  WHERE rrc.report_ref_conn_id = tt.report_ref_conn_id
    AND rrc.report_ref_id = tt.report_ref_id
    AND rrc.alt_key = tt.trans_inv_id
    AND nvl(rrc.line_item_type, 'TRANS_INVENTORY')  = 'TRANS_INVENTORY'
 GROUP BY
      tt.daytime,
      ref_tag,
      object_id,
      decode(rrc.trans_inv_ind,'Y',trans_inv_id,'ALL'),
      decode(rrc.dimension_ind,'Y',substr(DIMENSION_TAG,1,decode(instr(DIMENSION_TAG,'|'),0,LENGTH(DIMENSION_TAG),instr(DIMENSION_TAG,'|')-1)),'ALL')|| '|'||--Dimension 1
      decode(rrc.dimension_2_ind,'Y',substr(DIMENSION_TAG,instr(DIMENSION_TAG, '|'), instr(DIMENSION_TAG,'|',instr(DIMENSION_TAG, '|')-instr(DIMENSION_TAG, '|'))) ,'ALL') || '|'||--Dimension 2
      decode(rrc.prod_mth_ind,'Y',DECODE(DIMENSION_TAG,'ALL',to_char(tt.DAYTIME,'YYYY-MM-DD') || 'T00:00:00',decode(dimension_tag,'NA',NULL,substr(dimension_tag,instr(dimension_tag,'|',-1)+1))),to_char(tt.daytime,'YYYY-MM-DD') || 'T00:00:00'), -- Prod Month
      decode(rrc.layer_ind,'Y',tt.layer_month,tt.daytime),
      decode(rrc.trans_inv_ind,'Y',trans_inv_code,'ALL')