CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_RR_CONTRACT_DOCDATE" ("OBJECT_ID", "OBJ_CODE", "CLASS_NAME", "DOCUMENT_KEY", "TRANSACTION_KEY", "LINE_ITEM_KEY", "VENDOR_ID", "PC_ID", "REC_ID", "REV_NO", "PRODUCT_ID", "DIST_ID", "COMPANY_ID", "LINE_ITEM_TYPE", "PRICE_CONCEPT_CODE", "PRICE_ELEMENT_CODE", "LINE_ITEM_VALUE", "QTY1", "QTY2", "QTY3", "QTY4", "PRICING_VALUE", "PRICING_VAT_VALUE", "PRICING_TOTAL", "MEMO_VALUE", "MEMO_VAT_VALUE", "MEMO_TOTAL", "BOOKING_VALUE", "BOOKING_VAT_VALUE", "BOOKING_TOTAL", "DAYTIME", "REPORT_REF_TYPE", "REF_TAG", "REPORT_REF_CONN_ID", "REPORT_REF_ID", "CT_TEXT_1", "CT_TEXT_2", "CT_TEXT_3", "CT_TEXT_4", "LT_TEXT_1", "LT_TEXT_2", "LT_TEXT_3", "LT_TEXT_4", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_BY", "APPROVAL_DATE", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "RECORD_STATUS") AS 
  select cd.object_id,
       Ec_Line_Item_Template.object_code(rrc.report_ref_conn_id) obj_code,
       'LINE_ITEM' AS class_name,
       cd.document_key,
       ct.transaction_key,
       ltd.line_item_key,
       ltd.vendor_id,
       ltd.dist_id as pc_id,
       ltd.rec_id,
       ltd.rev_no,
       ct.product_id product_id,
       ltd.dist_id dist_id,
       ltd.company_stream_item_id company_id,
       ltd.Line_Item_Type,
       ltd.Price_Concept_Code,
       ltd.Price_Element_Code,
       (ltd.line_item_value) * decode(rrc.reverse_ind,'Y',-1,1)  as line_item_value,
       (ltd.qty1) * decode(rrc.reverse_ind,'Y',-1,1)  as qty1,
       (ltd.qty2) * decode(rrc.reverse_ind,'Y',-1,1)  as qty2,
       (ltd.qty3) * decode(rrc.reverse_ind,'Y',-1,1)  as qty3,
       (ltd.qty4) * decode(rrc.reverse_ind,'Y',-1,1)  as qty4 ,
       (ltd.pricing_value) * decode(rrc.reverse_ind,'Y',-1,1)  pricing_value,
       (ltd.pricing_vat_value) * decode(rrc.reverse_ind,'Y',-1,1)  pricing_vat_value,
       (ltd.Pricing_Total) * decode(rrc.reverse_ind,'Y',-1,1)  pricing_TOTAL,
       (ltd.memo_value) * decode(rrc.reverse_ind,'Y',-1,1)  memo_value,
       (ltd.memo_vat_value) * decode(rrc.reverse_ind,'Y',-1,1)  memo_vat_value,
       (ltd.memo_total) * decode(rrc.reverse_ind,'Y',-1,1)  memo_total,
       (ltd.booking_value) * decode(rrc.reverse_ind,'Y',-1,1)  booking_value,
       (ltd.booking_vat_value) * decode(rrc.reverse_ind,'Y',-1,1)  booking_vat_value,
       (ltd.booking_total) * decode(rrc.reverse_ind,'Y',-1,1)  booking_total,
       cd.document_date as daytime,
       rrv.dataset as report_ref_type ,
       rrv.report_reference_tag as ref_tag ,
       rrc.report_ref_conn_id,
       rrc.report_ref_id,
       ct.text_1 ct_text_1,
       ct.text_2 ct_text_2,
       ct.text_3 ct_text_3,
       ct.text_4 ct_text_4,
       lt.text_1 lt_text_1,
       lt.text_2 lt_text_2,
       lt.text_3 lt_text_3,
       lt.text_4 lt_text_4,
       null rev_text,
       null approval_state,
       null approval_by,
       null approval_date,
       null created_by,
       null created_date,
       null last_updated_by,
       null last_updated_date,
       null record_status
from cont_li_dist_company ltd,
     cont_line_item lt,
     cont_transaction ct,
     cont_document cd,
     report_ref_connection rrc,
     report_reference rr ,
     report_reference_version rrv
where ct.document_key = cd.document_key
  and rrc.report_ref_conn_id = lt.line_item_template_id
  and rr.object_id=rrc.report_ref_id
  and DECODE(
      cd.document_level_code,'OPEN',1,'VALID1',2,'VALID2',3,'TRANSFER',4,'BOOKED',5)
       >= decode(nvl(rrc.document_level,
                                          'OPEN'),'OPEN',1,'VALID1',2,'VALID2',3,'TRANSFER',4,'BOOKED',5)
  and rrv.object_id = rr.object_id
  and ct.transaction_key = ltd.transaction_key
  and lt.line_item_key = ltd.line_item_key
  and ltd.document_key = ct.document_key
  and ct.product_id = nvl(rrc.product_id,ct.product_id)
  and lt.line_item_type = nvl(rrc.line_item_type,lt.line_item_type)
  and lt.price_concept_code = nvl(rrc.price_concept_code,lt.price_concept_code)
  and lt.price_element_code = nvl(rrc.price_element_code,lt.price_element_code)
  and nvl(ltd.profit_centre_id,ltd.dist_id) = nvl(rrc.profit_centre_id,nvl(ltd.profit_centre_id,ltd.dist_id))
  and ltd.vendor_id = nvl(rrc.company_id,ltd.vendor_id)
UNION ALL
-- Pulls Transaction Report references
select cd.object_id,
       Ec_TRANSACTION_Template.object_code(rrc.report_ref_conn_id) obj_code,
       'TRANSACTION' AS class_name,
       cd.document_key,
       ct.transaction_key,
       ltd.line_item_key,
       ltd.vendor_id,
       ltd.dist_id as pc_id,
       ltd.rec_id,
       ltd.rev_no,
       ct.product_id product_id,
       ltd.dist_id dist_id,
       ltd.company_stream_item_id company_id,
       ltd.Line_Item_Type,
       ltd.Price_Concept_Code,
       ltd.Price_Element_Code,
       (ltd.line_item_value) * decode(rrc.reverse_ind,'Y',-1,1)  as line_item_value,
       (ltd.qty1) * decode(rrc.reverse_ind,'Y',-1,1)  as qty1,
       (ltd.qty2) * decode(rrc.reverse_ind,'Y',-1,1)  as qty2,
       (ltd.qty3) * decode(rrc.reverse_ind,'Y',-1,1)  as qty3,
       (ltd.qty4) * decode(rrc.reverse_ind,'Y',-1,1)  as qty4 ,
       (ltd.pricing_value) * decode(rrc.reverse_ind,'Y',-1,1)  pricing_value,
       (ltd.pricing_vat_value) * decode(rrc.reverse_ind,'Y',-1,1)  pricing_vat_value,
       (ltd.Pricing_Total) * decode(rrc.reverse_ind,'Y',-1,1)  pricing_TOTAL,
       (ltd.memo_value) * decode(rrc.reverse_ind,'Y',-1,1)  memo_value,
       (ltd.memo_vat_value) * decode(rrc.reverse_ind,'Y',-1,1)  memo_vat_value,
       (ltd.memo_total) * decode(rrc.reverse_ind,'Y',-1,1)  memo_total,
       (ltd.booking_value) * decode(rrc.reverse_ind,'Y',-1,1)  booking_value,
       (ltd.booking_vat_value) * decode(rrc.reverse_ind,'Y',-1,1)  booking_vat_value,
       (ltd.booking_total) * decode(rrc.reverse_ind,'Y',-1,1)  booking_vat_total,
       cd.document_date as daytime,
       rrv.dataset as report_ref_type ,
       rrv.report_reference_tag as ref_tag ,
       rrc.report_ref_conn_id,
       rrc.report_ref_id,
       ct.text_1 ct_text_1,
       ct.text_2 ct_text_2,
       ct.text_3 ct_text_3,
       ct.text_4 ct_text_4,
       lt.text_1 lt_text_1,
       lt.text_2 lt_text_2,
       lt.text_3 lt_text_3,
       lt.text_4 lt_text_4,
       null rev_text,
       null approval_state,
       null approval_by,
       null approval_date,
       null created_by,
       null created_date,
       null last_updated_by,
       null last_updated_date,
       null record_status
from cont_li_dist_company ltd,
     cont_line_item lt,
     cont_transaction ct,
     cont_document cd,
     report_ref_connection rrc,
     report_reference rr ,
     report_reference_version rrv
where ct.document_key = cd.document_key
  and rrc.report_ref_conn_id = ct.trans_template_id
  and rr.object_id=rrc.report_ref_id
  and DECODE(
      cd.document_level_code,'OPEN',1,'VALID1',2,'VALID2',3,'TRANSFER',4,'BOOKED',5)
       >= decode(nvl(rrc.document_level,
                                          'OPEN'),'OPEN',1,'VALID1',2,'VALID2',3,'TRANSFER',4,'BOOKED',5)
  and rrv.object_id = rr.object_id
  and ct.transaction_key = ltd.transaction_key
  and lt.line_item_key = ltd.line_item_key
  and ltd.document_key = ct.document_key
  and ct.product_id = nvl(rrc.product_id,ct.product_id)
  and lt.line_item_type = nvl(rrc.line_item_type,lt.line_item_type)
  and lt.price_concept_code = nvl(rrc.price_concept_code,lt.price_concept_code)
  and lt.price_element_code = nvl(rrc.price_element_code,lt.price_element_code)
  and nvl(ltd.profit_centre_id,ltd.dist_id) = nvl(rrc.profit_centre_id,nvl(ltd.profit_centre_id,ltd.dist_id))
  and ltd.vendor_id = nvl(rrc.company_id,ltd.vendor_id)
UNION ALL
-- Pulls Document Report References
select cd.object_id,
       Ec_contract_doc.object_code(rrc.report_ref_conn_id) object_code,
       'DOCUMENT' AS class_name,
       cd.document_key,
       ct.transaction_key,
       ltd.line_item_key,
       ltd.vendor_id,
       ltd.dist_id as pc_id,
       ltd.rec_id,
       ltd.rev_no,
       ct.product_id product_id,
       ltd.dist_id dist_id,
       ltd.company_stream_item_id company_id,
       ltd.Line_Item_Type,
       ltd.Price_Concept_Code,
       ltd.Price_Element_Code,
       (ltd.line_item_value) * decode(rrc.reverse_ind,'Y',-1,1)  as line_item_value,
       (ltd.qty1) * decode(rrc.reverse_ind,'Y',-1,1)  as qty1,
       (ltd.qty2) * decode(rrc.reverse_ind,'Y',-1,1)  as qty2,
       (ltd.qty3) * decode(rrc.reverse_ind,'Y',-1,1)  as qty3,
       (ltd.qty4) * decode(rrc.reverse_ind,'Y',-1,1)  as qty4 ,
       (ltd.pricing_value) * decode(rrc.reverse_ind,'Y',-1,1)  pricing_value,
       (ltd.pricing_vat_value) * decode(rrc.reverse_ind,'Y',-1,1)  pricing_vat_value,
       (ltd.Pricing_Total) * decode(rrc.reverse_ind,'Y',-1,1)  pricing_TOTAL,
       (ltd.memo_value) * decode(rrc.reverse_ind,'Y',-1,1)  memo_value,
       (ltd.memo_vat_value) * decode(rrc.reverse_ind,'Y',-1,1)  memo_vat_value,
       (ltd.memo_total) * decode(rrc.reverse_ind,'Y',-1,1)  memo_total,
       (ltd.booking_value) * decode(rrc.reverse_ind,'Y',-1,1)  booking_value,
       (ltd.booking_vat_value) * decode(rrc.reverse_ind,'Y',-1,1)  booking_vat_value,
       (ltd.booking_total) * decode(rrc.reverse_ind,'Y',-1,1)  booking_total,
       cd.document_date as daytime,
       rrv.dataset as report_ref_type ,
       rrv.report_reference_tag as ref_tag ,
       rrc.report_ref_conn_id,
       rrc.report_ref_id,
       ct.text_1 ct_text_1,
       ct.text_2 ct_text_2,
       ct.text_3 ct_text_3,
       ct.text_4 ct_text_4,
       lt.text_1 lt_text_1,
       lt.text_2 lt_text_2,
       lt.text_3 lt_text_3,
       lt.text_4 lt_text_4,
       null rev_text,
       null approval_state,
       null approval_by,
       null approval_date,
       null created_by,
       null created_date,
       null last_updated_by,
       null last_updated_date,
       null record_status
from cont_li_dist_company ltd,
     cont_line_item lt,
     cont_transaction ct,
     cont_document cd,
     report_ref_connection rrc,
     report_reference rr ,
     report_reference_version rrv
where ct.document_key = cd.document_key
  and rrc.report_ref_conn_id = cd.contract_doc_id
  and rr.object_id=rrc.report_ref_id
  and DECODE(
      cd.document_level_code,'OPEN',1,'VALID1',2,'VALID2',3,'TRANSFER',4,'BOOKED',5)
       >= decode(nvl(rrc.document_level,
                                          'OPEN'),'OPEN',1,'VALID1',2,'VALID2',3,'TRANSFER',4,'BOOKED',5)
  and rrv.object_id = rr.object_id
  and ct.transaction_key = ltd.transaction_key
  and lt.line_item_key = ltd.line_item_key
  and ltd.document_key = ct.document_key
  and ct.product_id = nvl(rrc.product_id,ct.product_id)
  and lt.line_item_type = nvl(rrc.line_item_type,lt.line_item_type)
  and lt.price_concept_code = nvl(rrc.price_concept_code,lt.price_concept_code)
  and lt.price_element_code = nvl(rrc.price_element_code,lt.price_element_code)
  and nvl(ltd.profit_centre_id,ltd.dist_id) = nvl(rrc.profit_centre_id,nvl(ltd.profit_centre_id,ltd.dist_id))
  and ltd.vendor_id = nvl(rrc.company_id,ltd.vendor_id)
UNION ALL
-- Pulls Contract Report References
select cd.object_id,
       ec_contract.object_code(cd.object_id) object_code,
       'CONTRACT' AS class_name,
       cd.document_key,
       ct.transaction_key,
       ltd.line_item_key,
       ltd.vendor_id,
       ltd.dist_id as pc_id,
       ltd.rec_id,
       ltd.rev_no,
       ct.product_id product_id,
       ltd.dist_id dist_id,
       ltd.company_stream_item_id company_id,
       ltd.Line_Item_Type,
       ltd.Price_Concept_Code,
       ltd.Price_Element_Code,
       (ltd.line_item_value) * decode(rrc.reverse_ind,'Y',-1,1)  as line_item_value,
       (ltd.qty1) * decode(rrc.reverse_ind,'Y',-1,1)  as qty1,
       (ltd.qty2) * decode(rrc.reverse_ind,'Y',-1,1)  as qty2,
       (ltd.qty3) * decode(rrc.reverse_ind,'Y',-1,1)  as qty3,
       (ltd.qty4) * decode(rrc.reverse_ind,'Y',-1,1)  as qty4 ,
       (ltd.pricing_value) * decode(rrc.reverse_ind,'Y',-1,1)  pricing_value,
       (ltd.pricing_vat_value) * decode(rrc.reverse_ind,'Y',-1,1)  pricing_vat_value,
       (ltd.Pricing_Total) * decode(rrc.reverse_ind,'Y',-1,1)  pricing_TOTAL,
       (ltd.memo_value) * decode(rrc.reverse_ind,'Y',-1,1)  memo_value,
       (ltd.memo_vat_value) * decode(rrc.reverse_ind,'Y',-1,1)  memo_vat_value,
       (ltd.memo_total) * decode(rrc.reverse_ind,'Y',-1,1)  memo_total,
       (ltd.booking_value) * decode(rrc.reverse_ind,'Y',-1,1)  booking_value,
       (ltd.booking_vat_value) * decode(rrc.reverse_ind,'Y',-1,1)  booking_vat_value,
       (ltd.booking_total) * decode(rrc.reverse_ind,'Y',-1,1)  booking_total,
       cd.document_date as daytime,
       rrv.dataset as report_ref_type ,
       rrv.report_reference_tag as ref_tag ,
       rrc.report_ref_conn_id,
	   rrc.report_ref_id,
       ct.text_1 ct_text_1,
       ct.text_2 ct_text_2,
       ct.text_3 ct_text_3,
       ct.text_4 ct_text_4,
       lt.text_1 lt_text_1,
       lt.text_2 lt_text_2,
       lt.text_3 lt_text_3,
       lt.text_4 lt_text_4,
       null rev_text,
       null approval_state,
       null approval_by,
       null approval_date,
       null created_by,
       null created_date,
       null last_updated_by,
       null last_updated_date,
       null record_status
from cont_li_dist_company ltd,
     cont_line_item lt,
     cont_transaction ct,
     cont_document cd,
     report_ref_connection rrc,
     report_reference rr ,
     report_reference_version rrv
where ct.document_key = cd.document_key
  and rrc.report_ref_conn_id = cd.object_id
  and rr.object_id=rrc.report_ref_id
  and DECODE(
      cd.document_level_code,'OPEN',1,'VALID1',2,'VALID2',3,'TRANSFER',4,'BOOKED',5)
       >= decode(nvl(rrc.document_level,
                                          'OPEN'),'OPEN',1,'VALID1',2,'VALID2',3,'TRANSFER',4,'BOOKED',5)
  and rrv.object_id = rr.object_id
  and ct.transaction_key = ltd.transaction_key
  and lt.line_item_key = ltd.line_item_key
  and ltd.document_key = ct.document_key
  and ct.product_id = nvl(rrc.product_id,ct.product_id)
  and lt.line_item_type = nvl(rrc.line_item_type,lt.line_item_type)
  and lt.price_concept_code = nvl(rrc.price_concept_code,lt.price_concept_code)
  and lt.price_element_code = nvl(rrc.price_element_code,lt.price_element_code)
  and nvl(ltd.profit_centre_id,ltd.dist_id) = nvl(rrc.profit_centre_id,nvl(ltd.profit_centre_id,ltd.dist_id))
  and ltd.vendor_id = nvl(rrc.company_id,ltd.vendor_id)