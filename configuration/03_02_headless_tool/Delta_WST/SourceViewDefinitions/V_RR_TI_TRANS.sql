CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_RR_TI_TRANS" ("LAYER_MONTH", "DAYTIME", "TRANS_INV_CODE", "OBJECT_ID", "REF_TAG", "OBJ_CODE", "CLASS_NAME", "TRANS_INV_ID", "TRANSACTION_TAG", "PROD_STREAM_ID", "DIMENSION_TAG", "CALC_RUN_NO", "ACCEPT_STATUS", "QTY_1", "QTY_2", "QTY_3", "QTY_4", "QTY_5", "QTY_6", "QTY_7", "QTY_8", "QTY_9", "QTY_10", "VALUE_1", "VALUE_2", "VALUE_3", "VALUE_4", "VALUE_5", "VALUE_6", "VALUE_7", "VALUE_8", "VALUE_9", "VALUE_10", "COST_1", "COST_2", "COST_3", "COST_4", "COST_5", "COST_6", "COST_7", "COST_8", "COST_9", "COST_10", "COST_11", "COST_12", "COST_13", "COST_14", "COST_15", "COST_16", "COST_17", "COST_18", "COST_19", "COST_20", "COST_21", "COST_22", "COST_23", "COST_24", "COST_25", "COST_26", "COST_27", "COST_28", "COST_29", "COST_30", "REPORT_REF_CONN_ID", "REPORT_REF_ID", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REC_ID", "REV_NO", "RECORD_STATUS") AS 
  SELECT tt.layer_month,
       tt.daytime ,
       ti.object_code trans_inv_code,
       tips.object_id object_id,
       rrv.report_reference_tag ref_tag,
       ec_contract.object_code(tips.object_id) obj_code,
       'CONTRACT' AS class_name,
       tt.object_id trans_inv_id,
       tt.Transaction_Tag   transaction_tag,
       tt.prod_stream_id prod_stream_id,
       tt.dimension_tag dimension_tag,
	   tt.calc_run_no,
	   nvl(cr.accept_status,'P') ACCEPT_STATUS,
       tt.qty_1* decode(rrc.reverse_ind,'Y',-1,1) qty_1,
       tt.qty_2* decode(rrc.reverse_ind,'Y',-1,1)  qty_2,
       tt.qty_3* decode(rrc.reverse_ind,'Y',-1,1)  qty_3,
       tt.qty_4* decode(rrc.reverse_ind,'Y',-1,1)  qty_4,
       tt.qty_5* decode(rrc.reverse_ind,'Y',-1,1)  qty_5,
       tt.qty_6* decode(rrc.reverse_ind,'Y',-1,1)  qty_6,
       tt.qty_7* decode(rrc.reverse_ind,'Y',-1,1)  qty_7,
       tt.qty_8* decode(rrc.reverse_ind,'Y',-1,1)  qty_8,
       tt.qty_9* decode(rrc.reverse_ind,'Y',-1,1)  qty_9,
       tt.qty_10* decode(rrc.reverse_ind,'Y',-1,1)  qty_10,
       tt.value_1* decode(rrc.reverse_ind,'Y',-1,1)  value_1,
       tt.value_2* decode(rrc.reverse_ind,'Y',-1,1)  value_2,
       tt.value_3* decode(rrc.reverse_ind,'Y',-1,1)  value_3,
       tt.value_4* decode(rrc.reverse_ind,'Y',-1,1)  value_4,
       tt.value_5* decode(rrc.reverse_ind,'Y',-1,1)  value_5,
       tt.value_6* decode(rrc.reverse_ind,'Y',-1,1)  value_6,
       tt.value_7* decode(rrc.reverse_ind,'Y',-1,1)  value_7,
       tt.value_8* decode(rrc.reverse_ind,'Y',-1,1)  value_8,
       tt.value_9* decode(rrc.reverse_ind,'Y',-1,1)  value_9,
       tt.value_10* decode(rrc.reverse_ind,'Y',-1,1)  value_10,
       tt.cost_1* decode(rrc.reverse_ind,'Y',-1,1)  cost_1,
       tt.cost_2* decode(rrc.reverse_ind,'Y',-1,1)  cost_2,
       tt.cost_3* decode(rrc.reverse_ind,'Y',-1,1)  cost_3,
       tt.cost_4* decode(rrc.reverse_ind,'Y',-1,1)  cost_4,
       tt.cost_5* decode(rrc.reverse_ind,'Y',-1,1)  cost_5,
       tt.cost_6* decode(rrc.reverse_ind,'Y',-1,1)  cost_6,
       tt.cost_7* decode(rrc.reverse_ind,'Y',-1,1)  cost_7,
       tt.cost_8* decode(rrc.reverse_ind,'Y',-1,1)  cost_8,
       tt.cost_9* decode(rrc.reverse_ind,'Y',-1,1)  cost_9,
       tt.cost_10* decode(rrc.reverse_ind,'Y',-1,1)  cost_10,
       tt.cost_11* decode(rrc.reverse_ind,'Y',-1,1)  cost_11,
       tt.cost_12* decode(rrc.reverse_ind,'Y',-1,1)  cost_12,
       tt.cost_13* decode(rrc.reverse_ind,'Y',-1,1)  cost_13,
       tt.cost_14* decode(rrc.reverse_ind,'Y',-1,1)  cost_14,
       tt.cost_15* decode(rrc.reverse_ind,'Y',-1,1)  cost_15,
       tt.cost_16* decode(rrc.reverse_ind,'Y',-1,1)  cost_16,
       tt.cost_17* decode(rrc.reverse_ind,'Y',-1,1)  cost_17,
       tt.cost_18* decode(rrc.reverse_ind,'Y',-1,1)  cost_18,
       tt.cost_19* decode(rrc.reverse_ind,'Y',-1,1)  cost_19,
       tt.cost_20* decode(rrc.reverse_ind,'Y',-1,1)  cost_20,
	   tt.cost_21* decode(rrc.reverse_ind,'Y',-1,1)  cost_21,
       tt.cost_22* decode(rrc.reverse_ind,'Y',-1,1)  cost_22,
       tt.cost_23* decode(rrc.reverse_ind,'Y',-1,1)  cost_23,
       tt.cost_24* decode(rrc.reverse_ind,'Y',-1,1)  cost_24,
       tt.cost_25* decode(rrc.reverse_ind,'Y',-1,1)  cost_25,
       tt.cost_26* decode(rrc.reverse_ind,'Y',-1,1)  cost_26,
       tt.cost_27* decode(rrc.reverse_ind,'Y',-1,1)  cost_27,
       tt.cost_28* decode(rrc.reverse_ind,'Y',-1,1)  cost_28,
       tt.cost_29* decode(rrc.reverse_ind,'Y',-1,1)  cost_29,
       tt.cost_20* decode(rrc.reverse_ind,'Y',-1,1)  cost_30,
       rrc.report_ref_conn_id,
       rrc.report_ref_id,
       null rev_text,
       null approval_state,
       null approval_by,
       null approval_date,
       null created_by,
       null created_date,
       null last_updated_by,
       null last_updated_date,
       rrc.rec_id,
       rrc.rev_no,
       cr.record_status
   FROM TRANS_INVENTORY_TRANS tt,
       TRANS_INVENTORY_VERSION tiv,
       REPORT_REF_CONNECTION rrc,
       REPORT_REFERENCE_VERSION rrv,
       TRANS_INV_PROD_STREAM tips,
       TRANS_INVENTORY ti,
       CALC_REFERENCE   cr
 WHERE ti.object_id = tiv.object_id
   AND tips.inventory_id = tiv.object_id
   and tt.object_id = tips.inventory_id
   AND tiv.object_id = tt.object_id
   AND rrc.report_ref_id = rrv.object_id
   AND tt.prod_stream_id = tips.object_id
   AND tt.transaction_tag = rrc.line_item_type
--dates
   AND nvl(tips.end_date,tt.daytime+1) > tt.daytime
   AND tips.daytime <= tt.daytime
   AND rrv.daytime <= tt.daytime
   AND nvl(rrv.end_date,tt.daytime+1) > tt.daytime
   AND tiv.daytime <= tt.daytime
   AND nvl(tiv.end_date,tt.daytime+1) > tt.daytime
   AND rrc.daytime <= tt.daytime
   AND nvl(rrc.end_date,tt.daytime+1) > tt.daytime
--handle templating
   AND (
       (rrc.report_ref_conn_id = tt.prod_stream_id
        and rrc.alt_key = tips.inventory_id
        AND nvl(rrc.disabled_ind,'N') = 'N')
       or (rrc.report_ref_conn_id=ec_contract_version.parent_contract_id(tt.prod_stream_id,tt.daytime,'<=')
          AND rrc.alt_key = tiv.config_template
          AND NOT EXISTS (SELECT report_ref_conn_id FROM report_ref_connection where ref_id = rrc.id
        AND nvl(disabled_ind,'N') = 'Y'))
       )
   AND tt.calc_run_no in (select max(run_no) from calc_reference cr1 where cr1.object_id=tt.prod_stream_id and tt.daytime=cr1.daytime and cr1.accept_status in ('A','V')
   group by cr1.accrual_ind)
   AND cr.object_id=tt.prod_stream_id
   AND tips.object_id = cr.object_id
   AND tt.daytime=cr.daytime
   AND cr.run_no=tt.calc_run_no