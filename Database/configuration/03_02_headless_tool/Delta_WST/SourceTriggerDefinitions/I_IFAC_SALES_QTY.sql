CREATE OR REPLACE EDITIONABLE TRIGGER "I_IFAC_SALES_QTY" 
INSTEAD OF INSERT ON v_IFAC_SALES_QTY
FOR EACH ROW

DECLARE

  lrec IFAC_SALES_QTY%ROWTYPE;

BEGIN

  lrec.contract_id := :New.contract_id;
  lrec.contract_code := :New.contract_code;
  lrec.profit_center_id := :New.profit_center_id;
  lrec.profit_center_code := :New.profit_center_code;
  lrec.delivery_point_id := :New.delivery_point_id;
  lrec.delivery_point_code := :New.delivery_point_code;
  lrec.product_id := :New.product_id;
  lrec.product_code := :New.product_code;
  lrec.vendor_id := :New.vendor_id;
  lrec.vendor_code := :New.vendor_code;
  lrec.customer_id := :New.customer_id;
  lrec.customer_code := :New.customer_code;
  lrec.price_concept_code := :New.price_concept_code;
  lrec.price_status := :New.price_status;
  lrec.alloc_no := :new.alloc_no;
  lrec.alloc_no_max_ind := :new.alloc_no_max_ind;
  lrec.processing_period := :New.processing_period;
  lrec.period_start_date := :New.period_start_date;
  lrec.period_end_date := :New.period_end_date;
  lrec.unique_key_1 := :New.unique_key_1;
  lrec.unique_key_2 := :New.unique_key_2;
  lrec.li_unique_key_1 := :New.li_unique_key_1;
  lrec.li_unique_key_2 := :New.li_unique_key_2;
  lrec.transaction_key := :New.transaction_key;
  lrec.trans_key_set_ind := :New.trans_key_set_ind;
  lrec.qty1 := :New.qty1;
  lrec.uom1_code := :New.uom1_code;
  lrec.qty2 := :New.qty2;
  lrec.uom2_code := :New.uom2_code;
  lrec.qty3 := :New.qty3;
  lrec.uom3_code := :New.uom3_code;
  lrec.qty4 := :New.qty4;
  lrec.uom4_code := :New.uom4_code;
  lrec.qty5 := :New.qty5;
  lrec.uom5_code := :New.uom5_code;
  lrec.qty6 := :New.qty6;
  lrec.uom6_code := :New.uom6_code;
  lrec.doc_setup_id := :New.doc_setup_id;
  lrec.doc_setup_code := :New.doc_setup_code;
  lrec.trans_temp_id := :New.trans_temp_id;
  lrec.trans_temp_code := :New.trans_temp_code;
  lrec.ignore_ind := :New.ignore_ind;
  lrec.preceding_doc_key := :New.preceding_doc_key;
  lrec.price_date := :New.price_date;
  lrec.sales_order := :New.sales_order;
  lrec.unit_price := :New.unit_price;
  lrec.status := :New.status;
  lrec.qty_status := :New.qty_status;
  lrec.doc_status := :New.doc_status;
  lrec.price_object_id := :New.price_object_id;
  lrec.price_object_code := :New.price_object_code;
  lrec.source_node_id := :New.source_node_id;
  lrec.source_node_code := :New.source_node_code;
  lrec.description := :New.description;
  lrec.vat_code := :New.vat_code;
  lrec.ifac_tt_conn_code := :New.ifac_tt_conn_code;
  lrec.date_1 := :New.date_1;
  lrec.date_2 := :New.date_2;
  lrec.date_3 := :New.date_3;
  lrec.date_4 := :New.date_4;
  lrec.date_5 := :New.date_5;
  lrec.date_6 := :New.date_6;
  lrec.date_7 := :New.date_7;
  lrec.date_8 := :New.date_8;
  lrec.date_9 := :New.date_9;
  lrec.date_10 := :New.date_10;
  lrec.text_1 := :New.text_1;
  lrec.text_2 := :New.text_2;
  lrec.text_3 := :New.text_3;
  lrec.text_4 := :New.text_4;
  lrec.text_5 := :New.text_5;
  lrec.text_6 := :New.text_6;
  lrec.text_7 := :New.text_7;
  lrec.text_8 := :New.text_8;
  lrec.text_9 := :New.text_9;
  lrec.text_10 := :New.text_10;
  lrec.value_1 := :New.value_1;
  lrec.value_2 := :New.value_2;
  lrec.value_3 := :New.value_3;
  lrec.value_4 := :New.value_4;
  lrec.value_5 := :New.value_5;
  lrec.value_6 := :New.value_6;
  lrec.value_7 := :New.value_7;
  lrec.value_8 := :New.value_8;
  lrec.value_9 := :New.value_9;
  lrec.value_10 := :New.value_10;
  lrec.ref_object_id_1 := :New.ref_object_id_1;
  lrec.ref_object_id_2 := :New.ref_object_id_2;
  lrec.ref_object_id_3 := :New.ref_object_id_3;
  lrec.ref_object_id_4 := :New.ref_object_id_4;
  lrec.ref_object_id_5 := :New.ref_object_id_5;
  lrec.ref_object_id_6 := :New.ref_object_id_6;
  lrec.ref_object_id_7 := :New.ref_object_id_7;
  lrec.ref_object_id_8 := :New.ref_object_id_8;
  lrec.ref_object_id_9 := :New.ref_object_id_9;
  lrec.ref_object_id_10 := :New.ref_object_id_10;
  lrec.object_type := :New.object_type;
  lrec.dist_type := :New.dist_type;
  lrec.line_item_based_type := :new.line_item_based_type;
  lrec.pricing_value := :New.pricing_value;
  lrec.line_item_type := :new.line_item_type;
  lrec.int_from_date := :new.int_from_date;
  lrec.int_to_date := :new.int_to_date;
  lrec.percentage_value := :new.percentage_value;
  lrec.percentage_base_amount := :new.percentage_base_amount;
  lrec.int_base_rate := :new.int_base_rate;
  lrec.int_rate_offset := :new.int_rate_offset;
  lrec.unit_price_unit := :new.unit_price_unit;
  lrec.int_type := :new.int_type;
  lrec.int_base_amount := :new.int_base_amount;
  lrec.int_compounding_period := :new.int_compounding_period;
  lrec.ifac_li_conn_code := :new.ifac_li_conn_code;
  lrec.li_price_object_code := :new.li_price_object_code;
  lrec.Calc_Run_No := :New.Calc_Run_No;
  lrec.Contract_Account_Class := :New.Contract_Account_Class;
  lrec.CONTRACT_ACCOUNT := :New.CONTRACT_ACCOUNT;

  Ecdp_Inbound_Interface.ReceiveSalesQtyRecord(
    lrec,
    Ecdp_Context.getAppUser,
    NVL(trunc(lrec.processing_period,'MM'), nvl(trunc(lrec.period_start_date,'MM'), Ecdp_Timestamp.getCurrentSysdate)));

END;
