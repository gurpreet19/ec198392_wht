CREATE OR REPLACE PACKAGE BODY EcBp_Staging_Document IS

/*  -- Private type declarations
  type <TypeName> is <Datatype>;

  -- Private constant declarations
  <ConstantName> constant <Datatype> := <Value>;

  -- Private variable declarations
  <VariableName> <Datatype>;
*/

rec_doc_gen_log t_doc_gen_log;

TYPE rec_object_id IS RECORD
  (
   object_id  objects.object_id%TYPE,
   class_name objects.class_name%TYPE,
   obj_from   VARCHAR2(32) -- CONFIG or STAGING
  );



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GenDistFromStaging
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE GenDistFromStaging(p_transaction_no NUMBER,
                             p_line_item_no NUMBER,
                             p_line_item_key VARCHAR2,
                             p_user VARCHAR2)

--</EC-DOC>
IS

  lrec_cli   cont_line_item%ROWTYPE := ec_cont_line_item.row_by_pk(p_line_item_key);
  lrec_clid  cont_line_item_dist%ROWTYPE;
  lrec_clidc cont_li_dist_company%ROWTYPE;
  ltab_uom_set EcDp_Unit.t_uomtable     := EcDp_Unit.t_uomtable();
  ld_transaction_date DATE;
  lrec_ttv   transaction_tmpl_version%ROWTYPE := ec_transaction_tmpl_version.row_by_pk(ec_cont_transaction.trans_template_id(lrec_cli.transaction_key),lrec_cli.daytime,'<=');
  lrec_sks   split_key_setup%ROWTYPE := ec_split_key_setup.row_by_pk(lrec_ttv.split_key_id, lrec_ttv.stream_item_id, lrec_ttv.daytime, '<=');

BEGIN

  ld_transaction_date                   := ec_cont_transaction.transaction_date(lrec_cli.transaction_key);

  -- Loop over staging line item distribution
  FOR rsLID IN ecdp_staging_document.gc_staging_li_dist_list(p_transaction_no, p_line_item_no) LOOP

    -- Populate clid record based on cli and staging
    lrec_clid.object_id                := lrec_cli.Object_Id;
    lrec_clid.line_item_key            := lrec_cli.Line_Item_Key;
    lrec_clid.document_key             := lrec_cli.Document_Key;
    lrec_clid.transaction_key          := lrec_cli.Transaction_Key;
    lrec_clid.daytime                  := lrec_cli.daytime;
    lrec_clid.dist_id                  := rsLID.dist_id;
    lrec_clid.stream_item_id           := rsLID.stream_item_id;
    lrec_clid.node_id                  := rsLID.Node_Id;
    lrec_clid.name                     := lrec_cli.Name;
    lrec_clid.description              := lrec_cli.Description;
    lrec_clid.line_item_type           := lrec_cli.line_item_type;
    lrec_clid.line_item_based_type     := lrec_cli.line_item_based_type;
    lrec_clid.value_adjustment         := lrec_cli.Value_Adjustment;
    lrec_clid.price_concept_code       := lrec_cli.price_concept_code;
    lrec_clid.price_element_code       := lrec_cli.price_element_code;
    lrec_clid.stim_value_category_code := lrec_cli.stim_value_category_code;
    lrec_clid.sort_order               := NVL(rsLID.sort_order, lrec_cli.sort_order);
    lrec_clid.report_category_code     := lrec_cli.report_category_code;
    lrec_clid.move_qty_to_vo_ind       := lrec_cli.move_qty_to_vo_ind;
    lrec_clid.contribution_factor      := lrec_cli.contribution_factor;
    lrec_clid.uom1_code                := lrec_cli.uom1_code;
    lrec_clid.uom2_code                := lrec_cli.uom2_code;
    lrec_clid.uom3_code                := lrec_cli.uom3_code;
    lrec_clid.uom4_code                := lrec_cli.uom4_code;
    lrec_clid.qty1                     := rsLID.qty1;
    lrec_clid.qty2                     := rsLID.qty2;
    lrec_clid.qty3                     := rsLID.qty3;
    lrec_clid.qty4                     := rsLID.qty4;
    lrec_clid.split_share              := rsLID.split_share; --  Ecdp_split_key.GetSplitShareMth(lv2_split_key_id, LIVFCur.id, NVL(ld_transaction_date, ld_daytime), lv2_uom_code, 'SP_SPLIT_KEY');
    lrec_clid.alloc_stream_item_id     := rsLID.alloc_stream_item_id;
    lrec_clid.vat_code                 := lrec_cli.vat_code;
    lrec_clid.vat_rate                 := lrec_cli.vat_rate;
    lrec_clid.jv_billable              := CASE WHEN ec_contract_version.bank_details_level_code(lrec_cli.Object_Id, lrec_cli.daytime, '<=') = 'JV_BILLABLE' THEN 'JV_BILLABLE' ELSE NULL END;
    lrec_clid.comments                 := rsLID.comments;
    lrec_clid.profit_centre_id         := lrec_sks.profit_centre_id;


    INSERT INTO cont_line_item_dist VALUES lrec_clid;

    -- Re-fetch record if table trigger has done something smart
    lrec_clid := ec_cont_line_item_dist.row_by_pk(lrec_cli.Line_Item_Key,rsLID.dist_id,lrec_cli.stream_item_id);

    -- Loop over staging line item distribution
    FOR rsLIDC IN ecdp_staging_document.gc_staging_lid_comp_list(p_transaction_no, rsLID.dist_id, p_line_item_no) LOOP

        lrec_clidc.object_id                := lrec_clid.object_id;
        lrec_clidc.line_item_key            := lrec_clid.line_item_key;
        lrec_clidc.daytime                  := lrec_clid.daytime;
        lrec_clidc.stream_item_id           := lrec_clid.stream_item_id;
        lrec_clidc.dist_id                  := lrec_clid.dist_id;
        lrec_clidc.document_key             := lrec_clid.document_key;
        lrec_clidc.transaction_key          := lrec_clid.transaction_key;
        lrec_clidc.node_id                  := lrec_clid.node_id;
        lrec_clidc.name                     := lrec_clid.name;
        lrec_clidc.description              := lrec_clid.description;
        lrec_clidc.comments                 := lrec_clid.comments;
        lrec_clidc.vendor_id                := rsLIDC.vendor_id;
        lrec_clidc.vendor_share             := rsLIDC.vendor_share;
        lrec_clidc.customer_id              := rsLIDC.customer_id;
        lrec_clidc.customer_share           := rsLIDC.customer_share;
        lrec_clidc.split_share              := rsLIDC.split_share;
        lrec_clidc.sort_order               := lrec_clid.sort_order;
        lrec_clidc.report_category_code     := lrec_clid.report_category_code;
        lrec_clidc.value_adjustment         := lrec_clid.value_adjustment;
        lrec_clidc.uom1_code                := lrec_clid.uom1_code;
        lrec_clidc.uom2_code                := lrec_clid.uom2_code;
        lrec_clidc.uom3_code                := lrec_clid.uom3_code;
        lrec_clidc.uom4_code                := lrec_clid.uom4_code;
        lrec_clidc.qty1                     := rsLIDC.qty1;
        lrec_clidc.qty2                     := rsLIDC.qty2;
        lrec_clidc.qty3                     := rsLIDC.qty3;
        lrec_clidc.qty4                     := rsLIDC.qty4;
        lrec_clidc.price_concept_code       := lrec_clid.price_concept_code;
        lrec_clidc.price_element_code       := lrec_clid.price_element_code;
        lrec_clidc.stim_value_category_code := lrec_clid.stim_value_category_code;
        lrec_clidc.line_item_type           := lrec_clid.line_item_type;
        lrec_clidc.line_item_based_type     := lrec_clid.line_item_based_type;
        lrec_clidc.company_stream_item_id   := rsLIDC.company_stream_item_id;
        lrec_clidc.move_qty_to_vo_ind       := lrec_clid.move_qty_to_vo_ind;
        lrec_clidc.contribution_factor      := lrec_clid.contribution_factor;
        lrec_clidc.profit_centre_id         := lrec_clid.profit_centre_id;


        INSERT INTO cont_li_dist_company VALUES lrec_clidc;

    END LOOP; -- Insert li company distribution

  END LOOP; -- Insert li distribution



  IF (ec_cont_transaction.dist_split_type(lrec_cli.transaction_key) = 'SOURCE_SPLIT' AND ld_transaction_date IS NOT NULL) THEN
      Ecdp_Transaction.UpdTransSourceSplitShare(lrec_cli.transaction_key
                ,ec_cont_transaction_qty.net_qty1(lrec_cli.transaction_key)
                ,ec_cont_transaction_qty.uom1_code(lrec_cli.transaction_key)
                ,ld_transaction_date);
  END IF;

END GenDistFromStaging;

-----------------------------------------------------------------------------------------------------------------------------

/*
<EC-DOC>
-----------------------------------------------------------------------------------------------------------------------------
 Function       : OverrideDocument
 Description    : Overrides the newly created document with values from the staging document table, if they are set.
 Behaviour      :
 Called from    : GenerateDocument
----------------------------------------------------------------------------------------------------------------------------- */
PROCEDURE OverrideDocument(
          p_document_key VARCHAR2,
          p_rec_doc ft_st_document%ROWTYPE
)--</EC-DOC>
IS
BEGIN

  UPDATE cont_document cd SET
    cd.production_period = NVL(p_rec_doc.production_period, cd.production_period),
--    cd.period_start_date = p_rec_doc.period_start_date
--    cd.period_end_date = p_rec_doc.period_end_date
--    cd.calculation_key = p_rec_doc.calculation_key
    cd.status_code = p_rec_doc.status_code
  WHERE cd.document_key = p_document_key;

END OverrideDocument;

/*
<EC-DOC>
-----------------------------------------------------------------------------------------------------------------------------
 Function       : OverrideTransaction
 Description    : Overrides the newly created transaction with values from the staging transaction table, if they are set.
 Behaviour      :
 Called from    : GenerateDocument
----------------------------------------------------------------------------------------------------------------------------- */
PROCEDURE OverrideTransaction(
          p_transaction_key VARCHAR2,
          p_rec_trans ft_st_transaction%ROWTYPE
)--</EC-DOC>
IS

  ltab_uom_set EcDp_Unit.t_uomtable     := EcDp_Unit.t_uomtable();
  lrec_ct  cont_transaction%ROWTYPE;
  lrec_ctq cont_transaction_qty%ROWTYPE := ec_cont_transaction_qty.row_by_pk(p_transaction_key);

BEGIN

  UPDATE cont_transaction ct SET
    ct.Product_Id                   = NVL(p_rec_trans.Product_Id, ct.Product_Id),
    ct.Stream_Item_Id               = NVL(p_rec_trans.Stream_Item_Id, ct.Stream_Item_Id),
    ct.Price_Concept_Code           = NVL(p_rec_trans.Price_Concept_Code, ct.Price_Concept_Code),
--    ct.Profit_Center_Id             = NVL(p_rec_trans.Profit_Center_Id, ct.Profit_Center_Id ),
    ct.Loading_Date_Commenced       = NVL(p_rec_trans.Loading_Date_Commenced, ct.Loading_Date_Commenced),
    ct.Loading_Port_Id              = NVL(p_rec_trans.Loading_Port_Id, ct.Loading_Port_Id),
    ct.Delivery_Point_Id            = NVL(p_rec_trans.Delivery_Point_Id, ct.Delivery_Point_Id),
    ct.Delivery_Date_Commenced      = NVL(p_rec_trans.Delivery_Date_Commenced, ct.Delivery_Date_Commenced),
    ct.Discharge_Port_Id            = NVL(p_rec_trans.Discharge_Port_Id, ct.Discharge_Port_Id),
    ct.Consignee                    = NVL(p_rec_trans.Consignee_Code, ct.Consignee),
    ct.Consignor                    = NVL(p_rec_trans.Consignor_Code, ct.Consignor),
    ct.Cargo_No                     = NVL(p_rec_trans.Cargo_No, ct.Cargo_No),
    ct.Parcel_No                    = NVL(p_rec_trans.Parcel_No, ct.Parcel_No),
    ct.Carrier_Id                   = NVL(p_rec_trans.Carrier_Id, ct.Carrier_Id),
    ct.Qty_Type                     = NVL(p_rec_trans.Qty_Type, ct.Qty_Type),
    ct.Sales_Order                  = NVL(p_rec_trans.Sales_Order, ct.Sales_Order),
--    ct.Unit_Price                   = NVL(p_rec_trans.Unit_Price, ct.Unit_Price),
    ct.Bl_Date                      = NVL(p_rec_trans.Bl_Date, ct.Bl_Date),
    ct.Price_Date                   = NVL(p_rec_trans.Price_Date, ct.Price_Date),
    ct.Price_Object_Id              = NVL(p_rec_trans.Price_Object_Id, ct.Price_Object_Id),
    ct.Transaction_Type             = NVL(p_rec_trans.Transaction_Type, ct.Transaction_Type),
    ct.Ifac_Unique_Key_1            = NVL(p_rec_trans.Unique_Key_1, ct.Ifac_Unique_Key_1),
    ct.Ifac_Unique_Key_2            = NVL(p_rec_trans.Unique_Key_2, ct.Ifac_Unique_Key_2),
    ct.ifac_tt_conn_code	  		= NVL(p_rec_trans.Ifac_tt_conn_code, ct.Ifac_tt_conn_code),
    ct.supply_from_date             = NVL(p_rec_trans.Period_Start_Date, ct.supply_from_date),
    ct.supply_to_date               = NVL(p_rec_trans.Period_To_Date, ct.supply_to_date),
    ct.Value_1                      = NVL(p_rec_trans.Value_1, ct.Value_1),
    ct.Value_2                      = NVL(p_rec_trans.Value_2, ct.Value_2),
    ct.Value_3                      = NVL(p_rec_trans.Value_3, ct.Value_3),
    ct.Value_4                      = NVL(p_rec_trans.Value_4, ct.Value_4),
    ct.Value_5                      = NVL(p_rec_trans.Value_5, ct.Value_5),
    ct.Value_6                      = NVL(p_rec_trans.Value_6, ct.Value_6),
    ct.Value_7                      = NVL(p_rec_trans.Value_7, ct.Value_7),
    ct.Value_8                      = NVL(p_rec_trans.Value_8, ct.Value_8),
    ct.Value_9                      = NVL(p_rec_trans.Value_9, ct.Value_9),
    ct.Value_10                     = NVL(p_rec_trans.Value_10, ct.Value_10),
    ct.Text_1                       = NVL(p_rec_trans.Text_1,  ct.Text_1),
    ct.Text_2                       = NVL(p_rec_trans.Text_2,  ct.Text_2),
    ct.Text_3                       = NVL(p_rec_trans.Text_3,  ct.Text_3),
    ct.Text_4                       = NVL(p_rec_trans.Text_4,  ct.Text_4),
    ct.Text_5                       = NVL(p_rec_trans.Text_5,  ct.Text_5),
    ct.Text_6                       = NVL(p_rec_trans.Text_6,  ct.Text_6),
    ct.Text_7                       = NVL(p_rec_trans.Text_7,  ct.Text_7),
    ct.Text_8                       = NVL(p_rec_trans.Text_8,  ct.Text_8),
    ct.Text_9                       = NVL(p_rec_trans.Text_9,  ct.Text_9),
    ct.Text_10                      = NVL(p_rec_trans.Text_10, ct.Text_10),
    ct.Date_1                       = NVL(p_rec_trans.Date_1,  ct.Date_1),
    ct.Date_2                       = NVL(p_rec_trans.Date_2,  ct.Date_2),
    ct.Date_3                       = NVL(p_rec_trans.Date_3,  ct.Date_3),
    ct.Date_4                       = NVL(p_rec_trans.Date_4,  ct.Date_4),
    ct.Date_5                       = NVL(p_rec_trans.Date_5,  ct.Date_5)
/*    ct.Date_6                       = NVL(p_rec_trans.Date_6,  ct.Date_6),
    ct.Date_7                       = NVL(p_rec_trans.Date_7,  ct.Date_7),
    ct.Date_8                       = NVL(p_rec_trans.Date_8,  ct.Date_8),
    ct.Date_9                       = NVL(p_rec_trans.Date_9,  ct.Date_9),
    ct.Date_10                      = NVL(p_rec_trans.Date_10, ct.Date_10)  */
  WHERE ct.transaction_key = p_transaction_key;

  -- Re-fetch the transaction
  lrec_ct := ec_cont_transaction.row_by_pk(p_transaction_key);

  -- Copy figures to table
  EcDp_Unit.GenQtyUOMSet(ltab_uom_set, p_rec_trans.net_qty1, p_rec_trans.uom1_code
                                      ,p_rec_trans.net_qty2, p_rec_trans.uom2_code
                                      ,p_rec_trans.net_qty3, p_rec_trans.uom3_code
                                      ,p_rec_trans.net_qty4, p_rec_trans.uom4_code);

  -- Get the converted values from uom set
  lrec_ctq.net_qty1 := EcDp_Revn_Unit.GetUOMSetQty(ltab_uom_set, lrec_ctq.UOM1_CODE, lrec_ct.daytime, lrec_ct.stream_item_id);

  IF lrec_ctq.UOM2_CODE IS NOT NULL THEN
     lrec_ctq.net_qty2 := EcDp_Revn_Unit.GetUOMSetQty(ltab_uom_set, lrec_ctq.UOM2_CODE, lrec_ct.daytime, lrec_ct.stream_item_id);
  END IF;
  IF lrec_ctq.UOM3_CODE IS NOT NULL THEN
     lrec_ctq.net_qty3 := EcDp_Revn_Unit.GetUOMSetQty(ltab_uom_set, lrec_ctq.UOM3_CODE, lrec_ct.daytime, lrec_ct.stream_item_id);
  END IF;
  IF lrec_ctq.UOM4_CODE IS NOT NULL THEN
     lrec_ctq.net_qty4 := EcDp_Revn_Unit.GetUOMSetQty(ltab_uom_set, lrec_ctq.UOM4_CODE, lrec_ct.daytime, lrec_ct.stream_item_id);
  END IF;

  UPDATE cont_transaction_qty
     SET last_updated_by   = 'SYSTEM', -- avoid revision for this temporary update
         net_grs_indicator = nvl(p_rec_trans.Net_Grs_Indicator, ecdp_transaction.GetNetGrsIndicator(p_rec_trans.object_id, p_transaction_key)),
         net_qty1          = lrec_ctq.net_qty1,
         net_qty2          = lrec_ctq.net_qty2,
         net_qty3          = lrec_ctq.net_qty3,
         net_qty4          = lrec_ctq.net_qty4
   WHERE transaction_key = p_transaction_key;

END OverrideTransaction;

/*
<EC-DOC>
-----------------------------------------------------------------------------------------------------------------------------
 Function       : OverrideLineItem
 Description    : Overrides the newly created line item with values from the staging line item table, if they are set.
 Behaviour      :
 Called from    : GenerateDocument
----------------------------------------------------------------------------------------------------------------------------- */
PROCEDURE OverrideLineItem(
          p_line_item_key VARCHAR2,
          p_rec_li ft_st_line_item%ROWTYPE
)--</EC-DOC>
IS
BEGIN


  UPDATE cont_line_item cli SET
    cli.price_object_id          = NVL(p_rec_li.price_object_id,cli.price_object_id),
    cli.stream_item_id           = NVL(p_rec_li.stream_item_id,cli.stream_item_id),
    cli.name                     = NVL(p_rec_li.name,cli.name),
--    cli.calculation_id           = NVL(p_rec_li.calculation_id,cli.calculation_id),
    cli.price_concept_code       = NVL(p_rec_li.price_concept_code,cli.price_concept_code),
    cli.price_element_code       = NVL(p_rec_li.price_element_code,cli.price_element_code),
    cli.stim_value_category_code = NVL(p_rec_li.stim_value_category_code,cli.stim_value_category_code),
--    cli.report_category_code     = NVL(p_rec_li.report_category_code,cli.report_category_code),
    cli.line_item_value          = NVL(p_rec_li.line_item_value,cli.line_item_value),
    cli.unit_price               = NVL(p_rec_li.unit_price,cli.unit_price),
    cli.unit_price_unit          = NVL(p_rec_li.unit_price_unit,cli.unit_price_unit),
    cli.free_unit_qty            = NVL(p_rec_li.free_unit_qty,cli.free_unit_qty),
--    cli.contribution_factor      = NVL(p_rec_li.contribution_factor,cli.contribution_factor),
    cli.move_qty_to_vo_ind       = NVL(p_rec_li.move_qty_to_vo_ind,cli.move_qty_to_vo_ind),
    cli.value_adjustment         = NVL(p_rec_li.value_adjustment,cli.value_adjustment),
    cli.qty1                     = NVL(p_rec_li.qty1,cli.qty1),
--    cli.uom1_code                = NVL(p_rec_li.uom1_code,cli.uom1_code),
    cli.qty2                     = NVL(p_rec_li.qty2,cli.qty2),
--    cli.uom2_code                = NVL(p_rec_li.uom2_code,cli.uom2_code),
    cli.qty3                     = NVL(p_rec_li.qty3,cli.qty3),
--    cli.uom3_code                = NVL(p_rec_li.uom3_code,cli.uom3_code),
    cli.qty4                     = NVL(p_rec_li.qty4,cli.qty4),
--    cli.uom4_code                = NVL(p_rec_li.uom4_code,cli.uom4_code),
    cli.non_adjusted_value       = NVL(p_rec_li.non_adjusted_value,cli.non_adjusted_value),
    cli.pricing_value            = NVL(p_rec_li.pricing_value,cli.pricing_value),
    cli.pricing_vat_value        = NVL(p_rec_li.pricing_vat_value,cli.pricing_vat_value),
--    cli.booking_value            = NVL(p_rec_li.booking_value,cli.booking_value),
--    cli.booking_vat_value        = NVL(p_rec_li.booking_vat_value,cli.booking_vat_value),
--    cli.booking_total            = NVL(p_rec_li.booking_total,cli.booking_total),
--    cli.memo_value               = NVL(p_rec_li.memo_value,cli.memo_value),
--    cli.memo_vat_value           = NVL(p_rec_li.memo_vat_value,cli.memo_vat_value),
    cli.line_item_based_type     = NVL(p_rec_li.line_item_based_type,cli.line_item_based_type),
    cli.line_item_type           = NVL(p_rec_li.line_item_type,cli.line_item_type),
--    cli.vat_rate                 = NVL(p_rec_li.vat_rate,cli.vat_rate),
    cli.node_id                  = NVL(p_rec_li.node_id,cli.node_id),
    cli.interest_line_item_key   = NVL(p_rec_li.interest_line_item_key,cli.interest_line_item_key),
    cli.interest_base_amount     = NVL(p_rec_li.interest_base_amount,cli.interest_base_amount),
    cli.interest_type            = NVL(p_rec_li.interest_type,cli.interest_type),
    cli.interest_group           = NVL(p_rec_li.interest_group,cli.interest_group),
    cli.base_rate                = NVL(p_rec_li.base_rate,cli.base_rate),
    cli.rate_offset              = NVL(p_rec_li.rate_offset,cli.rate_offset),
    cli.gross_rate               = NVL(p_rec_li.gross_rate,cli.gross_rate),
    cli.interest_from_date       = NVL(p_rec_li.interest_from_date,cli.interest_from_date),
    cli.interest_to_date         = NVL(p_rec_li.interest_to_date,cli.interest_to_date),
    cli.interest_num_days        = NVL(p_rec_li.interest_num_days,cli.interest_num_days),
    cli.percentage_base_amount   = NVL(p_rec_li.percentage_base_amount,cli.percentage_base_amount),
    cli.percentage_value         = NVL(p_rec_li.percentage_value,cli.percentage_value),
    cli.rate_days                = NVL(p_rec_li.rate_days,cli.rate_days),
    cli.compounding_period       = NVL(p_rec_li.compounding_period,cli.compounding_period),
    cli.group_ind                = NVL(p_rec_li.group_ind,cli.group_ind),
    cli.source_line_item_key     = NVL(p_rec_li.source_line_item_key,cli.source_line_item_key),
--    cli.group_total              = NVL(p_rec_li.group_total,cli.group_total),
--    cli.group_value              = NVL(p_rec_li.group_value,cli.group_value),
--    cli.group_vat_value          = NVL(p_rec_li.group_vat_value,cli.group_vat_value),
--    cli.local_total              = NVL(p_rec_li.local_total,cli.local_total),
--    cli.local_value              = NVL(p_rec_li.local_value,cli.local_value),
--    cli.local_vat_value          = NVL(p_rec_li.local_vat_value,cli.local_vat_value),
--    cli.memo_total               = NVL(p_rec_li.memo_total,cli.memo_total),
    cli.pricing_total            = NVL(p_rec_li.pricing_total,cli.pricing_total),
    cli.sort_order               = NVL(p_rec_li.sort_order,cli.sort_order),
--    cli.description              = NVL(p_rec_li.description,cli.description),
--    cli.comments                 = NVL(p_rec_li.comments,cli.comments),
    cli.value_1                  = NVL(p_rec_li.value_1,cli.value_1),
    cli.value_2                  = NVL(p_rec_li.value_2,cli.value_2),
    cli.value_3                  = NVL(p_rec_li.value_3,cli.value_3),
    cli.value_4                  = NVL(p_rec_li.value_4,cli.value_4),
    cli.value_5                  = NVL(p_rec_li.value_5,cli.value_5),
    cli.value_6                  = NVL(p_rec_li.value_6,cli.value_6),
    cli.value_7                  = NVL(p_rec_li.value_7,cli.value_7),
    cli.value_8                  = NVL(p_rec_li.value_8,cli.value_8),
    cli.value_9                  = NVL(p_rec_li.value_9,cli.value_9),
    cli.value_10                 = NVL(p_rec_li.value_10,cli.value_10),
    cli.text_1                   = NVL(p_rec_li.text_1,cli.text_1),
    cli.text_2                   = NVL(p_rec_li.text_2,cli.text_2),
    cli.text_3                   = NVL(p_rec_li.text_3,cli.text_3),
    cli.text_4                   = NVL(p_rec_li.text_4,cli.text_4),
    cli.date_1                   = NVL(p_rec_li.date_1,cli.date_1),
    cli.date_2                   = NVL(p_rec_li.date_2,cli.date_2),
    cli.date_3                   = NVL(p_rec_li.date_3,cli.date_3),
    cli.date_4                   = NVL(p_rec_li.date_4,cli.date_4),
    cli.date_5                   = NVL(p_rec_li.date_5,cli.date_5)
  WHERE cli.line_item_key = p_line_item_key;

END OverrideLineItem;


/*
<EC-DOC>
-----------------------------------------------------------------------------------------------------------------------------
 Function       : GenerateDocument
 Description    : Reads data from staging table and creates documents based on the result.
 Behaviour      :
 Called from    :
----------------------------------------------------------------------------------------------------------------------------- */
FUNCTION GenerateDocument(p_contract_id     VARCHAR2,
                          p_contract_doc_id VARCHAR2,
                          p_daytime         DATE,
                          p_log_item_no     NUMBER)
RETURN VARCHAR2
--</EC-DOC>
IS

  lv2_NewDocKey VARCHAR2(32) := NULL;
  lv2_NewTransKey VARCHAR2(32) := NULL;
  lv2_NewLineItemKey VARCHAR2(32) := NULL;
  ln_log_item_no NUMBER := p_log_item_no;
  ln_TransCounter NUMBER;
  ln_TransTotalCounter NUMBER;
  lv2_user cont_document.created_by%TYPE;
  ld_document_date DATE := trunc(Ecdp_Timestamp.getCurrentSysdate(),'DD'); -- initial document_date

BEGIN


  -- TEST PURPOSES ONLY ! --
  IF ecdp_context.getAppUser IS NULL THEN
    dbms_session.set_identifier('sysadmin');
  END IF;

  -- Get the user
  lv2_user := ecdp_context.getAppUser;

  -- Retrieve all documents ready for generation
  FOR rsDoc IN ecdp_staging_document.gc_staging_doc_list('READY') LOOP

     WriteLog('DEBUG','Staging Document Action: ' || rsDoc.system_action_code, ln_log_item_no);

     IF rsDoc.system_action_code IN ('CREATE_INVOICE','CREATE_DEPENDENT') THEN

       -- Generate a new document key
       lv2_NewDocKey := EcDp_Document.GetNextDocumentKey(rsDoc.object_id, rsDoc.daytime);

       WriteLog('DEBUG','Preparing to create document: ' || lv2_NewDocKey, ln_log_item_no);

       BEGIN


         -- TODO: Custom InsDocument for Staging, with all values from staging table, and if null, pick from doc setup?
         --CreateDocumentFromStaging(rsDoc);


         -- Create an empty document
         lv2_NewDocKey := ecdp_document.GenDocumentSet_app(rsDoc.object_id,
                                                       rsDoc.contract_doc_id,
                                                       rsDoc.preceding_document_key,
                                                       rsDoc.daytime,
                                                       ld_document_date,
                                                       ln_log_item_no,
                                                       lv2_user,
                                                       NULL, -- p_doc_id
                                                       lv2_NewDocKey,
                                                       'N');

         -- Set values from staging document on actual document
         OverrideDocument(lv2_NewDocKey, rsDoc);

         WriteLog('INFO','Document Created: ' || lv2_NewDocKey, ln_log_item_no);

         -- Let log record remember the document
         rec_doc_gen_log.document_key := lv2_NewDocKey;

         -- Reset
         ln_TransCounter := 0;
         ln_TransTotalCounter := 0;

         -- Loop over staging transactions
         FOR rsTrans IN ecdp_staging_document.gc_staging_trans_list(rsDoc.contract_doc_id) LOOP

           lv2_NewTransKey := NULL;
           ln_TransTotalCounter := ln_TransTotalCounter + 1;

           lv2_NewTransKey := EcDp_Transaction.InsNewTransaction(rsDoc.object_id,
                                                                 rsDoc.daytime,
                                                                 lv2_NewDocKey,
                                                                 rsTrans.transaction_type,
                                                                 rsTrans.trans_template_id,
                                                                 lv2_user,
                                                                 NULL, -- Trans Id
                                                                 NULL, -- No preceding transaction
                                                                 rsTrans.unique_key_1,
                                                                 rsTrans.unique_key_2,
                                                                 rsTrans.period_start_date,
                                                                 rsTrans.period_to_date,
                                                                 rsTrans.delivery_point_id,
                                                                 'N' -- do not create line items
                                                                 );

            IF lv2_NewTransKey IS NOT NULL THEN

              -- Set values from staging transaction on actual transaction
              OverrideTransaction(lv2_NewTransKey, rsTrans);

              ln_TransCounter := ln_TransCounter + 1;

              WriteLog( 'INFO','Created transaction for Price Concept [' || rsTrans.Price_Concept_Code || '], '
                                       || 'Delivery Point [' || ec_delivery_point.object_code(rsTrans.Delivery_point_id) || '], '
                                       || 'Product [' || ec_product.object_code(rsTrans.Product_Id) || '], '
                                       || 'Field [' || ec_field.object_code(rsTrans.profit_center_id) || '] '
                                       , ln_log_item_no);
            ELSE
              WriteLog( 'INFO','Could not create transaction for Price Concept [' || rsTrans.Price_Concept_Code || '], '
                                       || 'Delivery Point [' || ec_delivery_point.object_code(rsTrans.Delivery_point_id) || '], '
                                       || 'Product [' || ec_product.object_code(rsTrans.Product_Id) || '], '
                                       || 'Field [' || ec_field.object_code(rsTrans.profit_center_id) || '] '
                                       , ln_log_item_no);
            END IF;



            -- Loop over staging line items
            FOR rsLI IN ecdp_staging_document.gc_staging_line_item_list(rsTrans.ft_st_transaction_no, NULL) LOOP

                lv2_NewLineItemKey := ecdp_line_item.InsNewLineItem(
                                              rsDoc.object_id,
                                              rsDoc.daytime,
                                              lv2_NewDocKey,
                                              lv2_NewTransKey,
                                              rsLI.line_item_template_id,
                                              lv2_user,
                                              NULL, -- line item key is generated
                                              rsLI.line_item_type, -- p_line_item_type
                                              rsLI.line_item_based_type, -- p_line_item_based_type
                                              rsLI.percentage_base_amount, -- p_pct_base_amount
                                              rsLI.percentage_value, -- p_percentage_value
                                              rsLI.unit_price, -- p_unit_price =>
                                              rsLI.unit_price_unit, -- p_unit_price_unit =>
                                              rsLI.free_unit_qty, -- p_free_unit_qty =>
                                              rsLI.pricing_value, -- p_pricing_value =>
                                              rsLI.name, -- p_description =>
                                              rsLI.price_object_id, -- p_price_object_id =>
                                              rsLI.price_element_code, -- p_price_element_code =>
                                              NULL, -- p_customer_id =>
                                              'N', -- Do not create distribution
                                              p_creation_method => ecdp_revn_ft_constants.c_mtd_auto_gen);

                -- Set values from staging line item on actual line item
                OverrideLineItem(lv2_NewLineItemKey, rsLI);

                -- Do the distribution magic
                GenDistFromStaging(rsTrans.ft_st_transaction_no,
                                     rsLI.ft_st_line_item_no,
                                     lv2_NewLineItemKey,
                                     lv2_user);

            END LOOP; -- Insert line item

         END LOOP; -- Insert transactions

         WriteLog('INFO', 'Processed ' || ln_TransCounter || ' of ' || ln_TransTotalCounter || ' transaction records.', ln_log_item_no);


         WriteLog('INFO', 'Updating document dates.', ln_log_item_no);
         EcDp_Contract_Setup.updateAllDocumentDates(rsDoc.object_id, lv2_NewDocKey, rsDoc.daytime, ld_document_date, lv2_user);


         WriteLog('INFO', 'Deleting empty transactions.', ln_log_item_no);
         EcDp_Transaction.DelEmptyTransactions(lv2_NewDocKey);


         WriteLog('INFO', 'Setting recommended action.', ln_log_item_no);
         EcDp_Document_Gen.SetDocumentRecActionCode(lv2_NewDocKey);


       EXCEPTION
           WHEN OTHERS THEN
               ExceptionHandler(p_contract_id, lv2_NewDocKey, SQLCODE, SUBSTR(SQLERRM, 1, 240), 'ERROR', 'Y', ln_log_item_no);
               RETURN 'ERROR';
       END;

     END IF; -- Action

  END LOOP; -- Document loop

  RETURN lv2_NewDocKey;

END GenerateDocument;





-----------------------------------------------------------------------------------------------------------------------------


/*
<EC-DOC>
-----------------------------------------------------------------------------------------------------------------------------
 Function       : PreProcessDocument
 Description    : Reads and completes data from staging table.
 Behaviour      : If data is missing on distribution levels, this is generated using predefined splits.
                  Analysis : set the appropriate status on the staging documents (Ready, Obsolete etc).
                             - Ready: Identify if the staging document data is ready for generating a financial document.
                             - Obsolete: Identify if the staging document replaces a previous document. Set previous to Obsolete.
                  Analysis : set the system recommended action for the documents (CREATE_INVOICE, CREATE_DEPENDENT etc.)
                  Analysis : validate the staging document structure, and make sure nothing is missing. If data is missing, set status to INVALID.
 Called from    : Contract Calculation
----------------------------------------------------------------------------------------------------------------------------- */
PROCEDURE PreProcessDocument(p_contract_id     VARCHAR2,
                             p_contract_doc_id VARCHAR2,
                             p_daytime         DATE,
                             p_log_item_no     NUMBER)

--</EC-DOC>
IS

BEGIN

    -- Refresh document
    RefreshDocument;


  -- Retrieve all documents ready for generation
  FOR rsDoc IN ecdp_staging_document.gc_staging_doc_list('NEW') LOOP

     -- Find staged transactions for this document
     FOR rsTrans IN ecdp_staging_document.gc_staging_trans_list(rsDoc.contract_doc_id) LOOP

        -- Find staged line items for this transaction
        FOR rsLI IN ecdp_staging_document.gc_staging_line_item_list(rsTrans.ft_st_transaction_no, NULL) LOOP


                InsertFieldSplit(rsLI.ft_st_line_item_no);


           -- Read the field distribution setup
           FOR rsFieldSetup IN ecdp_staging_document.gc_staging_li_dist_list( rsTrans.ft_st_transaction_no,rsLI.ft_st_line_item_no) LOOP

               InsertCompanySplit( rsFieldSetup.ft_st_li_dist_no);

           END LOOP;


        END LOOP;
     END LOOP;
  END LOOP;

  UPDATE ft_st_document d
     SET d.staging_doc_status = 'READY'
   WHERE d.object_id = p_contract_id
     AND d.staging_doc_status = 'NEW'
     AND d.contract_doc_id = p_contract_doc_id
     AND d.daytime = p_daytime;

END PreProcessDocument;


-----------------------------------------------------------------------------------------------------------------------------
/*
<EC-DOC>
-----------------------------------------------------------------------------------------------------------------------------
 Function       : ExceptionHandler
 Description    :
 Behaviour      :
 Called from    :
----------------------------------------------------------------------------------------------------------------------------- */
PROCEDURE ExceptionHandler(p_object_id       VARCHAR2,
                           p_doc_key         VARCHAR2,
                           p_err_code        NUMBER,
                           p_err_msg         VARCHAR2,
                           p_exception_level VARCHAR2 DEFAULT 'ERROR', -- could be set to WARNING
                           p_delete_doc_ind  VARCHAR2 DEFAULT 'Y',
                           p_log_item_no     IN OUT NUMBER)
IS
BEGIN
     WriteLog(p_exception_level, p_err_code || ' - ' || p_err_msg, p_log_item_no);

     IF p_doc_key IS NULL AND p_exception_level = 'ERROR' AND p_delete_doc_ind = 'Y' THEN
        WriteLog('DEBUG','Could not delete document due to missing document key. Parameters recieved: doc key: NULL, exception level: ' || p_exception_level || ', delete: ' || p_delete_doc_ind, p_log_item_no);
     END IF;

     IF p_doc_key IS NOT NULL AND p_exception_level = 'ERROR' AND p_delete_doc_ind = 'Y' THEN
        WriteLog('INFO','Due to generation failure, this document is deleted: ' || p_doc_key, p_log_item_no);
        BEGIN
           EcDp_Document.DelDocument(p_object_id, p_doc_key);
        EXCEPTION
           WHEN OTHERS THEN
           WriteLog(p_exception_level, 'Attempted to delete document ' || p_doc_key || ', but an exception occurred: ' || SQLCODE || ' - ' || SUBSTR(SQLERRM, 1, 240), p_log_item_no);
        END;
     ELSE
        WriteLog('DEBUG','Did not delete document. Parameters recieved: doc key:' || p_doc_key || ', exception level: ' || p_exception_level || ', delete: ' || p_delete_doc_ind, p_log_item_no);
     END IF;

		 SetDocGenStatus(p_log_item_no,p_exception_level);

END ExceptionHandler;

-----------------------------------------------------------------------------------------------------------------------------
/*
<EC-DOC>
-----------------------------------------------------------------------------------------------------------------------------
 Function       : WriteLog
 Description    :
 Behaviour      :
 Called from    :
----------------------------------------------------------------------------------------------------------------------------- */
PROCEDURE WriteLog(p_log_level        VARCHAR2, -- SUMMARY, INFO, WARNING or ERROR
                   p_log_text         VARCHAR2,
                   p_log_item_no      IN OUT NUMBER)
--</EC-DOC>
IS
ln_next_day_run_no NUMBER;
lv2_sys_log_level ctrl_system_attribute.attribute_text%type;

  CURSOR c_Next IS
    SELECT NVL(MAX(VALUE_1), 0) + 1 NewNumber
      FROM REVN_LOG
     WHERE TRUNC(daytime, 'dd') = TRUNC(Ecdp_Timestamp.getCurrentSysdate(), 'dd');


BEGIN

IF rec_doc_gen_log.log_item_no IS NULL THEN


     -- Get the next day run no
     FOR rsNext IN c_Next LOOP
         ln_next_day_run_no := rsNext.NewNumber;
     END LOOP;

     -- Create the log item
     INSERT INTO revn_log
       (category, daytime, value_1, description, status)
     VALUES
       (rec_doc_gen_log.log_type,
        Ecdp_Timestamp.getCurrentSysdate,
        ln_next_day_run_no,
        rec_doc_gen_log.nav_id,
        p_log_level)
     RETURNING log_no INTO p_log_item_no;

     rec_doc_gen_log.log_item_no := p_log_item_no;


END IF;


  -- Check settings for logging: DEBUG (shows all), INFO (only Info and Summary), SUMMARY (only Summary)
  IF p_log_level NOT IN ('ERROR','WARNING') THEN -- Errors and warnings are always written to the log.
    lv2_sys_log_level := ec_ctrl_system_attribute.attribute_text(sysdate, 'DOC_GEN_LOG_LEVEL', '<=');
    IF lv2_sys_log_level = 'SUMMARY' AND p_log_level != 'SUMMARY' THEN
      RETURN;
    ELSIF lv2_sys_log_level = 'INFO' AND p_log_level NOT IN ('SUMMARY','INFO') THEN
      RETURN;
    END IF;
  END IF;


  INSERT INTO revn_log_item
    (log_no,
     text_3,
     daytime,
     text_2,
     description,
     text_1,
     status,
     created_by)
  values
    (rec_doc_gen_log.log_item_no,
     rec_doc_gen_log.contract_id,
     rec_doc_gen_log.daytime,
     rec_doc_gen_log.cargo_name,
     p_log_text,
     rec_doc_gen_log.document_key,
     p_log_level,
     rec_doc_gen_log.created_by);

END WriteLog;
-----------------------------------------------------------------------------------------------------------------------------
/*
<EC-DOC>
-----------------------------------------------------------------------------------------------------------------------------
 Function       : WriteLog
 Description    :
 Behaviour      :
 Called from    :
----------------------------------------------------------------------------------------------------------------------------- */
PROCEDURE SetDocGenStatus(
  p_log_item_no NUMBER,
	p_set_status VARCHAR2
	)
IS
BEGIN

  -- Do the update of the log
  UPDATE revn_log SET
    STATUS = DECODE(p_set_status, NULL, STATUS, p_set_status)
  WHERE log_no = p_log_item_no;

END SetDocGenStatus;
-----------------------------------------------------------------------------------------------------------------------------
/*
<EC-DOC>
-----------------------------------------------------------------------------------------------------------------------------
 Function       : SetDocStatusCode
 Description    :
 Behaviour      :
 Called from    :
----------------------------------------------------------------------------------------------------------------------------- */
PROCEDURE SetDocStatusCode(p_document_key VARCHAR2,
                           p_status_code VARCHAR2)
IS
BEGIN

   UPDATE cont_document d
      SET d.status_code = p_status_code
    WHERE d.document_key = p_document_key;

END SetDocStatusCode;




/*
<EC-DOC>
-----------------------------------------------------------------------------------------------------------------------------
 Function       : RefreshNew
 Description    : Set all older than newest NEW document sets that fits current contract doc and daytime to obsolete
 Behaviour      :
 Called from    :
----------------------------------------------------------------------------------------------------------------------------- */
PROCEDURE RefreshDocument

 IS

  CURSOR c IS
    SELECT o.ft_st_document_no
      FROM ft_st_document o
     WHERE o.staging_doc_status = 'NEW'
       AND (o.contract_doc_id, o.daytime, o.staging_doc_status) IN
           (SELECT oo.contract_doc_id, oo.daytime, oo.staging_doc_status
              FROM ft_st_document oo
             WHERE oo.created_date > o.created_date);

BEGIN

  FOR r IN c LOOP
    UPDATE ft_st_document d
       SET d.staging_doc_status = 'OBSOLETE'
     WHERE d.ft_st_document_no = r.ft_st_document_no;

  END LOOP;



/*UPDATE ft_st_document o
   SET o.status_code = 'OBSOLETE'
 WHERE o.status_code = 'NEW'
   AND (o.contract_doc_id, o.daytime, o.status_code) IN
       (SELECT oo.contract_doc_id, oo.daytime, oo.status_code
          FROM ft_st_document oo
         WHERE oo.created_date > o.created_date);*/

  END RefreshDocument;




/*
<EC-DOC>
-----------------------------------------------------------------------------------------------------------------------------
 Function       : RefreshFieldSplit
 Description    : Insert field distribution to staging table if not already existing. Currently assuming config is present.
 Behaviour      :
 Called from    :
----------------------------------------------------------------------------------------------------------------------------- */
PROCEDURE InsertFieldSplit(p_ft_st_line_item_no INTEGER)

IS



CURSOR c_Distribution IS
SELECT 1 FROM ft_st_li_dist f
WHERE f.ft_st_line_item_no = p_ft_st_line_item_no;

lb_distributed                 BOOLEAN := FALSE;
lv2_transaction_template_id    VARCHAR2(32);
lv2_split_key_id               VARCHAR2(32);
lv2_uom_code                   VARCHAR2(32);
lv2_field_id                   VARCHAR2(32);
lrec_l                         ft_st_line_item%ROWTYPE;
lrec_f                         ft_st_li_dist%ROWTYPE;

BEGIN

FOR r IN c_Distribution LOOP
   lb_distributed := TRUE;

   EXIT WHEN lb_distributed = TRUE;
  END LOOP;

  IF lb_distributed THEN

    NULL;

   ELSE
    lrec_l                             := ec_ft_st_line_item.row_by_pk(p_ft_st_line_item_no);
    lv2_transaction_template_id        := ec_ft_st_transaction.trans_template_id(lrec_l.Ft_St_Transaction_No);
    lv2_split_key_id                   := ec_transaction_tmpl_version.split_key_id(lv2_transaction_template_id,lrec_l.daytime,'<=');
    lv2_uom_code                       := ec_transaction_tmpl_version.uom1_code(lv2_transaction_template_id,lrec_l.daytime);


     FOR r IN ecdp_line_item.gc_split_key_setup(lv2_split_key_id,lrec_l.daytime) LOOP



          lv2_field_id := ec_stream_item_version.field_id(R.id,lrec_l.daytime, '<=');

          lrec_f.object_id := lrec_l.object_id;
          lrec_f.ft_st_line_item_no 	        := lrec_l.ft_st_line_item_no;
          lrec_f.ft_st_transaction_no         := lrec_l.ft_st_transaction_no;
          lrec_f.ft_st_document_no            := lrec_l.ft_st_document_no;
          lrec_f.stream_item_id               := r.id;
          lrec_f.dist_id                      := lv2_field_id;
          lrec_f.node_id                      := ecdp_stream_item.getNodeId(r.id,lrec_l.daytime);
        	lrec_f.sort_order                   := lrec_l.sort_order;
          lrec_f.split_share                  := Ecdp_split_key.GetSplitShareMth(lv2_split_key_id,r.id, lrec_l.daytime, lv2_uom_code, 'SP_SPLIT_KEY');
          lrec_f.Alloc_Stream_Item_Id         := r.source_member_id;
          lrec_f.daytime                      := lrec_l.daytime;


          INSERT INTO ft_st_li_dist VALUES lrec_f;

     END LOOP;

      END IF;








  END InsertFieldSplit;


/*
<EC-DOC>
-----------------------------------------------------------------------------------------------------------------------------
 Function       : RefreshCompanySplit
 Description    : Insert field distribution to staging table if not already existing. Currently assuming config is present.
 Behaviour      :
 Called from    :
----------------------------------------------------------------------------------------------------------------------------- */
PROCEDURE InsertCompanySplit(p_ft_st_li_dist_no INTEGER)

IS



CURSOR c_Distribution IS
SELECT 1 FROM ft_st_li_dist_company c WHERE c.ft_st_li_dist_no = p_ft_st_li_dist_no;


lb_distributed                 BOOLEAN := FALSE;
lv2_transaction_template_id    VARCHAR2(32);
lv2_split_key_id               VARCHAR2(32);
lv2_child_split_key_id         VARCHAR2(32);
lv2_fin_code                   VARCHAR2(32);
lrec_f                         ft_st_li_dist%ROWTYPE;
lrec_c                         ft_st_li_dist_company%ROWTYPE;

BEGIN

FOR r IN c_Distribution LOOP
   lb_distributed := TRUE;

   EXIT WHEN lb_distributed = TRUE;
  END LOOP;

  IF lb_distributed THEN

    NULL;

   ELSE
    lrec_f                                := ec_ft_st_li_dist.row_by_pk(p_ft_st_li_dist_no);
    lv2_transaction_template_id           := ec_ft_st_transaction.trans_template_id(lrec_f.ft_st_transaction_no);
    lv2_split_key_id                      := ec_transaction_tmpl_version.split_key_id(lv2_transaction_template_id,lrec_f.daytime,'<=');

    lv2_child_split_key_id                := ec_split_key_setup.child_split_key_id(lv2_split_key_id, lrec_f.stream_item_id, lrec_f.daytime, '<=');
    lv2_fin_code                          := ec_contract_version.financial_code(lrec_f.object_id,lrec_f.daytime,'<=');




      FOR SplitCur IN ecdp_line_item.gc_split_key_setup_company(lv2_child_split_key_id, lrec_f.object_id,NULL, lv2_fin_code, lrec_f.daytime) LOOP


                   lrec_c.object_id 	    	     := lrec_f.object_id;
                   lrec_c.daytime                := lrec_f.daytime;
                   lrec_c.dist_id                := lrec_f.dist_id;
                   lrec_c.node_id                := lrec_f.node_id;
                   lrec_c.vendor_id              := SplitCur.vendor_id;
                   lrec_c.vendor_share           := SplitCur.vendor_share;
                   lrec_c.customer_id            := SplitCur.customer_id;
                   lrec_c.customer_share     	   := SplitCur.customer_share;
                   lrec_c.split_share        	   := SplitCur.vendor_share*SplitCur.customer_share;
                   lrec_c.company_stream_item_id := SplitCur.split_member_id;
                   lrec_c.ft_st_document_no      := lrec_f.ft_st_document_no;
                   lrec_c.ft_st_transaction_no   := lrec_f.ft_st_transaction_no;
                   lrec_c.ft_st_line_item_no     := lrec_f.ft_st_line_item_no;
                   lrec_c.ft_st_li_dist_no       := lrec_f.ft_st_li_dist_no;

                   INSERT INTO ft_st_li_dist_company VALUES lrec_c;



          END LOOP;

      END IF;

  END InsertCompanySplit;




/*
<EC-DOC>
-----------------------------------------------------------------------------------------------------------------------------
 Function       : InsertFieldSplit
 Description    : Do whatever is needed for a proper field distribution to be present
 Behaviour      :
 Called from    :
----------------------------------------------------------------------------------------------------------------------------- */
PROCEDURE InsertFieldSplit(p_ft_st_transaction_no INTEGER, p_ttv transaction_tmpl_version%ROWTYPE)

IS
BEGIN


UPDATE ft_st_transaction t
   SET t.delivery_point_id  = nvl(t.delivery_point_id, p_ttv.delivery_point_id),
       t.discharge_port_id  = nvl(t.discharge_port_id, p_ttv.discharge_port_id),
       t.loading_port_id    = nvl(t.loading_port_id, p_ttv.loading_port_id),
       t.transaction_type   = nvl(t.transaction_type, p_ttv.transaction_type),
       t.price_concept_code = nvl(t.price_concept_code, p_ttv.price_concept_code),
       t.price_object_id    = nvl(t.price_object_id, p_ttv.price_object_id),
       t.product_id         = nvl(t.product_id, p_ttv.product_id),
       t.stream_item_id     = nvl(t.stream_item_id, p_ttv.stream_item_id),
       t.uom1_code          = nvl(t.uom1_code, p_ttv.uom1_code),
       t.uom2_code          = nvl(t.uom2_code, p_ttv.uom2_code),
       t.uom3_code          = nvl(t.uom3_code, p_ttv.uom3_code),
       t.uom4_code          = nvl(t.uom4_code, p_ttv.uom4_code),
       t.text_1             = nvl(t.text_1, p_ttv.text_1),
       t.text_2             = nvl(t.text_2, p_ttv.text_2),
       t.text_3             = nvl(t.text_3, p_ttv.text_3),
       t.text_4             = nvl(t.text_4, p_ttv.text_4),
       t.text_5             = nvl(t.text_5, p_ttv.text_5),
       t.text_6             = nvl(t.text_6, p_ttv.text_6),
       t.text_7             = nvl(t.text_7, p_ttv.text_7),
       t.text_8             = nvl(t.text_8, p_ttv.text_8),
       t.text_9             = nvl(t.text_9, p_ttv.text_9),
       t.text_10            = nvl(t.text_10, p_ttv.text_10),
       t.value_1            = nvl(t.value_1, p_ttv.value_1),
       t.value_2            = nvl(t.value_2, p_ttv.value_2),
       t.value_3            = nvl(t.value_3, p_ttv.value_3),
       t.value_4            = nvl(t.value_4, p_ttv.value_4),
       t.value_5            = nvl(t.value_5, p_ttv.value_5),
       t.value_6            = nvl(t.value_6, p_ttv.value_6),
       t.value_7            = nvl(t.value_7, p_ttv.value_7),
       t.value_8            = nvl(t.value_8, p_ttv.value_8),
       t.value_9            = nvl(t.value_9, p_ttv.value_9),
       t.value_10           = nvl(t.value_10, p_ttv.value_10),
       t.date_1             = nvl(t.date_1, p_ttv.date_1),
       t.date_2             = nvl(t.date_2, p_ttv.date_2),
       t.date_3             = nvl(t.date_3, p_ttv.date_3),
       t.date_4             = nvl(t.date_4, p_ttv.date_4),
       t.date_5             = nvl(t.date_5, p_ttv.date_5)
 WHERE t.ft_st_transaction_no = p_ft_st_transaction_no;


  END InsertFieldSplit;


----------------------------------------------------------------------------------------------------------------------------- */
END EcBp_Staging_Document;