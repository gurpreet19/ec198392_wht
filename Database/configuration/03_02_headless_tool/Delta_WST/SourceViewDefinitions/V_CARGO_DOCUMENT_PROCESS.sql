CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CARGO_DOCUMENT_PROCESS" ("DAYTIME", "CONTRACT_ID", "CONTRACT_CODE", "CONTRACT_NAME", "CARGO_NO", "PARCEL_NO", "COMMENTS", "SAVED_DOC_SETUP_ID", "FINANCIAL_CODE", "CONTRACT_AREA_ID", "CONTRACT_AREA_CODE", "PRICING_CURRENCY_ID", "CUSTOMER_ID", "DOC_DATE", "DOC_STATUS", "GEN_DOC_KEY", "ACTION", "PREC_DOC_KEY", "LOADING_PORT_ID", "SOURCE_NODE_ID", "SOURCE_ENTRY_NO", "BUSINESS_UNIT_ID", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE", "REC_ID") AS 
  SELECT DISTINCT trunc(sub3.point_of_sale_date, 'MM') daytime,
                sub3.contract_id contract_id,
                c.code contract_code,
                c.name contract_name,
                sub3.cargo_no cargo_no,
                ecdp_document_gen_util.getparcelno(sub3.parcel_no,
                                                   sub3.doc_setup_id,
                                                   sub3.point_of_sale_date) parcel_no,
                sub3.description comments,
                sub3.doc_setup_id saved_doc_setup_id,
                c.financial_code financial_code,
                c.contract_area_id contract_area_id,
                c.contract_area_code contract_area_code,
                c.pricing_currency_id pricing_currency_id,
                sub3.customer_id customer_id,
                ecdp_document_gen_util.getcargodocdate(sub3.contract_id,
                                                       sub3.cargo_no,
                                                       sub3.qty_type,
                                                       sub3.alloc_no,
                                                       trunc(sub3.point_of_sale_date,
                                                             'MM'),
                                                       sub3.doc_setup_id,
                                                       sub3.customer_id) doc_date,
                sub3.doc_status doc_status,
                NULL gen_doc_key,
                ecdp_document_gen_util.getcargodocaction(sub3.contract_id,
                                                         sub3.cargo_no,
                                                         sub3.parcel_no,
                                                         sub3.qty_type,
                                                         trunc(sub3.point_of_sale_date,
                                                               'MM'),
                                                         sub3.doc_setup_id,
                                                         sub3.ifac_tt_conn_code,
                                                         sub3.customer_id) action,
                ecdp_document_gen_util.getcargoprecedingdockey(sub3.contract_id,
                                                               sub3.cargo_no,
                                                               sub3.parcel_no,
                                                               NULL,
                                                               trunc(sub3.point_of_sale_date,
                                                                     'MM'),
                                                               sub3.ifac_tt_conn_code,
                                                               sub3.customer_id,
                                                               sub3.preceding_doc_key) prec_doc_key,
                sub3.loading_port_id,
                sub3.source_node_id,
                max(sub3.source_entry_no) OVER(PARTITION BY contract_id, cargo_no,DECODE(NVL(ec_contract_doc_version.single_parcel_doc_ind(doc_setup_id,point_of_sale_date,'<='),'N'),'N','X'),customer_id) source_entry_no,
                ca.business_unit_id,
                NULL AS RECORD_STATUS,
                NULL AS CREATED_BY,
                NULL AS CREATED_DATE,
                NULL AS LAST_UPDATED_BY,
                NULL AS LAST_UPDATED_DATE,
                NULL AS REV_NO,
                NULL AS REV_TEXT,
                NULL AS APPROVAL_STATE,
                NULL AS APPROVAL_BY,
                NULL AS APPROVAL_DATE,
                NULL AS REC_ID
  FROM (SELECT DISTINCT contract_id,
                        cargo_no,
                        parcel_no,
                        qty_type,
                        alloc_no,
                        point_of_sale_date,
                        preceding_doc_key,
                        doc_setup_id,
                        doc_status,
                        loading_port_id,
                        source_node_id,
                        source_entry_no,
                        customer_id,
                        description,
                        IFAC_TT_CONN_CODE
          FROM ifac_cargo_value cargo
         WHERE cargo.alloc_no_max_ind = 'Y'
           AND cargo.ignore_ind = 'N'
           AND cargo.trans_key_set_ind = 'N'
           AND cargo.customer_id IS NOT NULL
           AND cargo.point_of_sale_date >=
               add_months(trunc(Ecdp_Timestamp.getCurrentSysdate, 'MM'),
                          (NVL(ec_ctrl_system_attribute.attribute_value(trunc(Ecdp_Timestamp.getCurrentSysdate,
                                                                              'MM'),
                                                                        'DOC_GEN_MONTHS',
                                                                        '<='),
                               120) * -1))) sub3,
       ov_contract c,
       ov_contract_area ca,
       ov_business_unit bu
 WHERE sub3.contract_id = c.object_id
      -- Resolving contract
   AND c.daytime <= sub3.point_of_sale_date
   AND NVL(c.end_date, sub3.point_of_sale_date + 1) >
       sub3.point_of_sale_date
      -- Resolving contract area
   AND c.contract_area_id = ca.object_id
   AND ca.daytime <= sub3.point_of_sale_date
   AND NVL(ca.end_date, sub3.point_of_sale_date + 1) >
       sub3.point_of_sale_date
      -- Resolving business unit
   AND ca.business_unit_id = bu.object_id
   AND bu.daytime <= sub3.point_of_sale_date
   AND NVL(bu.end_date, sub3.point_of_sale_date + 1) >
       sub3.point_of_sale_date