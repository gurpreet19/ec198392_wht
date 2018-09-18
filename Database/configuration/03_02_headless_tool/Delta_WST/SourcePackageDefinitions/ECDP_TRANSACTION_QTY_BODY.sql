CREATE OR REPLACE PACKAGE BODY Ecdp_Transaction_Qty IS
/****************************************************************
** Package        :  Ecdp_Transaction_Qty, body part
**
** $Revision: 1.106 $
**
** Purpose        :  Provide special functions on Transactions.
**
** Documentation  :  www.energy-components.com
**
** Created  : 07.12.2006
**
** Modification history:
**
** Version  Date        Whom        Change description:
** -------  ----------  ----        --------------------------------------
**  1.0     07.12.2006  SRA          Initial version
**  1.20    18.10.2007  SSK          Cleanup of comments and avoid source split usage when dist shares exist during qty pickup.
**
**
*******************************************************************************************************************************************************/

    -- Boolean variable in use when evaluating if source split shares should be retrieved or not.
    lv2_skip_fetch_src_split VARCHAR2(1);


-----------------------------------------------------------------------------------------------------------------------------
-- Handle price object from interface to transaction
PROCEDURE SetTransPriceObject(p_transaction_key      VARCHAR2,
                              p_price_object_id      VARCHAR2,
                              p_user                 VARCHAR2,
                              p_qty_type_fallback    VARCHAR2 DEFAULT NULL)
IS

BEGIN


       UPDATE cont_transaction ctr
          SET ctr.price_object_id    = p_price_object_id,
              ctr.product_id         = ec_product_price.product_id(p_price_object_id),
              ctr.product_code         = ec_product.object_code(ec_product_price.product_id(p_price_object_id)),
              ctr.price_concept_code = ec_product_price.price_concept_code(p_price_object_id),
              ctr.qty_type           = NVL(ec_product_price_version.quantity_status(p_price_object_id,nvl(bl_Date,supply_from_date),'<='), p_qty_type_fallback),
              ctr.last_updated_by    = p_user
        WHERE ctr.transaction_key = p_transaction_key;

END SetTransPriceObject;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetTransPriceObject
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION GetTransPriceObject(p_tran_po_id  VARCHAR2,
                             p_ifac_po_id  VARCHAR2,
                             p_daytime     DATE,
                             p_silence_ind VARCHAR2 DEFAULT 'N',
                             p_doc_concept VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
--</EC-DOC>
IS

  lv2_err_msg VARCHAR2(1000);
  lv2_ret_po_id VARCHAR2(32);

BEGIN

  -- Transaction has no price object
  IF p_tran_po_id IS NULL THEN

    -- If MULTI_PERIOD, the interfaced PO should always be used. MULTI_PERIOD doc setups are always "reduced config"
    IF NVL(p_doc_concept,'X') = 'MULTI_PERIOD' THEN

      lv2_ret_po_id := p_ifac_po_id;

    ELSE

      -- Interfaced cargo has got price object. Reference this on the transaction.
      IF p_ifac_po_id IS NOT NULL THEN

        lv2_ret_po_id := p_ifac_po_id;

      -- No price object found on either transaction or interface record.
      ELSE

        IF p_silence_ind = 'N' THEN
          lv2_err_msg := 'No Price Object could be found on either transaction or interfaced record.';
          RAISE_APPLICATION_ERROR(-20000, lv2_err_msg);
        ELSE
          lv2_ret_po_id := 'X1';
        END IF;

      END IF;

      END IF;

    -- Transaction has got a price object
    ELSE

      -- Interfaced cargo has also got a price object. Test if there is a conflict.
      IF p_ifac_po_id IS NOT NULL THEN

         IF p_tran_po_id != p_ifac_po_id THEN

            IF p_silence_ind = 'N' THEN
              lv2_err_msg := 'Price Object difference between interfaced Price Object (' ||
                             ec_product_price.object_code(p_ifac_po_id) || ' - ' ||
                             ec_product_price_version.name(p_ifac_po_id, p_Daytime, '<=') || ' - ' ||
                             ec_product_version.name(ec_product_price.product_id(p_ifac_po_id), p_daytime, '<=') || ') ' ||
                            'and corresponding Transaction Template Price Object (' ||
                             ec_product_price.object_code(p_tran_po_id) || ' - ' ||
                             ec_product_price_version.name(p_tran_po_id, p_Daytime, '<=') || ' - ' ||
                             ec_product_version.name(ec_product_price.product_id(p_tran_po_id), p_daytime, '<=') || '). ' ||
                            'Reconfigure Transaction Template or change interfaced Price Object.';

              RAISE_APPLICATION_ERROR(-20000, lv2_err_msg);
            ELSE

              lv2_ret_po_id := 'X2';

            END IF;

         ELSE

           lv2_ret_po_id := p_tran_po_id;

         END IF;

      ELSE

         -- Current transaction price object is good.
         lv2_ret_po_id := p_tran_po_id;

      END IF;

    END IF;

  RETURN lv2_ret_po_id;

END GetTransPriceObject;




-----------------------------------------------------------------------------------------------------------------------------

-- If SourceEntryNo exists in ltab, this function returns 'Y'
FUNCTION SourceEntryNoExists(
          source_entry_no NUMBER,
          ltab t_table_number
          )
RETURN VARCHAR2
IS
  lv2_found VARCHAR2(1) := 'N';
BEGIN

  IF ltab IS NOT NULL AND ltab.count > 0 THEN
    FOR i IN ltab.FIRST..ltab.LAST LOOP

      IF source_entry_no IS NULL OR ltab(i) = source_entry_no THEN

          lv2_found := 'Y';

      END IF;

    END LOOP;
  END IF;

  RETURN lv2_found;

END SourceEntryNoExists;




    -----------------------------------------------------------------------
    -- Finds index of the line item level ifac record from given collection
    -- which matches given attributes.
    --
    -- Returns: The index of matched line item level record.
    ----+----------------------------------+-------------------------------
    FUNCTION find_li_from_ifac_p (
        p_ifac                             IN OUT NOCOPY t_table_ifac_sales_qty
       ,p_contract_id                      objects.object_id%TYPE
       ,p_price_concept_code               price_concept.price_concept_code%TYPE
       ,p_price_object_id                  objects.object_id%TYPE
       ,p_product_id                       objects.object_id%TYPE
       ,p_delivery_point_id                objects.object_id%TYPE
       ,p_customer_id                      objects.object_id%TYPE
       ,p_qty_status                       Transaction_Tmpl_Version.Req_Qty_Type%TYPE
       ,p_doc_status_code                  cont_document.status_code%TYPE
       ,p_period_start_date                DATE
       ,p_period_end_date                  DATE
       ,p_uom1_code                        VARCHAR2
       ,p_ct_uk1                           VARCHAR2
       ,p_ct_uk2                           VARCHAR2
       ,p_if_tt_conn_code                  VARCHAR2
       ,p_processing_period                DATE
       ,p_transaction_template_id          VARCHAR2
       ,p_line_item_based_type             VARCHAR2 DEFAULT 'QTY'
       ,p_line_item_type                   VARCHAR2 DEFAULT NULL
       ,p_line_item_code                   VARCHAR2 DEFAULT NULL
       )
    RETURN NUMBER
    IS
        ifac_record t_ifac_sales_qty;
    BEGIN
        FOR idx IN p_ifac.first..p_ifac.last LOOP
            ifac_record := p_ifac(idx);

            IF ifac_record.INTERFACE_LEVEL <> ecdp_revn_ifac_wrapper.gconst_level_line_item THEN
                continue;
            END IF;

            IF ifac_record.contract_id = p_contract_id
                AND ifac_record.period_start_date = p_period_start_date
                AND ifac_record.period_end_date = nvl(p_period_end_date, last_day(ifac_record.period_start_date))
                AND ecdp_revn_common.Equals(p_product_id, ifac_record.product_id, TRUE)
                AND ifac_record.delivery_point_id = p_delivery_point_id
                AND ifac_record.customer_id = p_customer_id
                AND ecdp_revn_common.Equals(p_price_concept_code, ifac_record.price_concept_code, TRUE)
                AND (ifac_record.qty_status = 'PPA' OR ecdp_revn_common.Equals(p_qty_status, ifac_record.qty_status, TRUE))
                AND ecdp_revn_common.Equals(p_uom1_code, ifac_record.uom1_code, TRUE)
                AND ecdp_revn_common.Equals(p_price_object_id, ifac_record.price_object_id, TRUE)
                AND ecdp_revn_common.Equals(p_doc_status_code, ifac_record.doc_status, FALSE)
                AND ecdp_revn_common.Equals(p_ct_uk1, ifac_record.unique_key_1, FALSE)
                AND ecdp_revn_common.Equals(p_ct_uk2, ifac_record.unique_key_2, FALSE)
                AND ecdp_revn_common.Equals(p_if_tt_conn_code, ifac_record.ifac_tt_conn_code, FALSE)
                AND ecdp_revn_common.Equals(p_processing_period, ifac_record.processing_period, TRUE)
                AND ifac_record.trans_temp_id = p_transaction_template_id
                AND ifac_record.line_item_based_type = NVL(p_line_item_based_type,'QTY')
                AND ecdp_revn_common.Equals(p_line_item_type, ifac_record.line_item_type, TRUE)
                AND ecdp_revn_common.Equals(p_line_item_code, ifac_record.line_item_code, TRUE) THEN
                RETURN idx;
            END IF;
        END LOOP;

        RETURN NULL;
    END;




    -----------------------------------------------------------------------
    -- Finds index of the line item level ifac record from given collection
    -- which matches given attributes.
    --
    -- Returns: The index of matched line item level record.
    ----+----------------------------------+-------------------------------
    FUNCTION find_li_from_ifac_p (
        p_ifac                             IN OUT NOCOPY t_table_ifac_cargo_value
       ,p_contract_id                      objects.object_id%TYPE
       ,p_price_concept_code               price_concept.price_concept_code%TYPE
       ,p_price_object_id                  objects.object_id%TYPE
       ,p_product_id                       objects.object_id%TYPE
       ,p_delivery_point_id                objects.object_id%TYPE
       ,p_customer_id                      objects.object_id%TYPE
       ,p_qty_status                       Transaction_Tmpl_Version.Req_Qty_Type%TYPE
       ,p_doc_status_code                  cont_document.status_code%TYPE
       ,p_period_start_date                DATE
       ,p_period_end_date                  DATE
       ,p_uom1_code                        VARCHAR2
       ,p_ct_uk1                           VARCHAR2
       ,p_ct_uk2                           VARCHAR2
       ,p_if_tt_conn_code                  VARCHAR2
       ,p_processing_period                DATE
       ,p_transaction_template_id          VARCHAR2
       ,p_line_item_based_type             VARCHAR2 DEFAULT 'QTY'
       ,p_line_item_type                   VARCHAR2 DEFAULT NULL
       ,p_line_item_code                   VARCHAR2 DEFAULT NULL
       ,p_parcel_no		            VARCHAR2 DEFAULT NULL
       )
    RETURN NUMBER
    IS
        ifac_record t_ifac_cargo_value;
    BEGIN
        FOR idx IN p_ifac.first..p_ifac.last LOOP
            ifac_record := p_ifac(idx);

            IF ifac_record.INTERFACE_LEVEL <> ecdp_revn_ifac_wrapper.gconst_level_line_item THEN
                continue;
            END IF;

            IF ifac_record.contract_id = p_contract_id
         --       AND ifac_record.period_start_date = p_period_start_date
           --     AND ifac_record.period_end_date = nvl(p_period_end_date, last_day(ifac_record.period_start_date))
                AND ecdp_revn_common.Equals(p_product_id, ifac_record.product_id, TRUE)
           --     AND ifac_record.delivery_point_id = p_delivery_point_id
                AND ifac_record.customer_id = p_customer_id
                AND ecdp_revn_common.Equals(p_price_concept_code, ifac_record.price_concept_code, TRUE)
               -- AND (ifac_record.STATUS = 'PPA' OR ecdp_revn_common.Equals(p_qty_status, ifac_record.status, TRUE))
                AND ecdp_revn_common.Equals(p_uom1_code, ifac_record.uom1_code, TRUE)
                AND ecdp_revn_common.Equals(p_price_object_id, ifac_record.price_object_id, TRUE)
                AND ecdp_revn_common.Equals(p_doc_status_code, ifac_record.doc_status, FALSE)
               -- AND ecdp_revn_common.Equals(p_ct_uk1, ifac_record.unique_key_1, FALSE)
               -- AND ecdp_revn_common.Equals(p_ct_uk2, ifac_record.unique_key_2, FALSE)
                AND ecdp_revn_common.Equals(p_if_tt_conn_code, ifac_record.ifac_tt_conn_code, FALSE)
          --      AND ecdp_revn_common.Equals(p_processing_period, ifac_record.processing_period, TRUE)
                AND ifac_record.trans_temp_id = p_transaction_template_id
                AND ifac_record.line_item_based_type = NVL(p_line_item_based_type,'QTY')
                AND ecdp_revn_common.Equals(p_line_item_type, ifac_record.line_item_type, TRUE)
                AND ecdp_revn_common.Equals(p_line_item_code, ifac_record.line_item_code, TRUE)
                AND NVL(ifac_record.PARCEL_NO,'XX') = CASE WHEN ifac_record.PARCEL_NO IS NULL THEN NVL(p_parcel_no,'XX')
                                                      ELSE NVL(p_parcel_no,ifac_record.PARCEL_NO) END THEN
                RETURN idx;
            END IF;
        END LOOP;

        RETURN NULL;
    END;

    -----------------------------------------------------------------------
    -- Prepares context with ifac data for processing a quantity line item.
    --
    -- Parameters:
    --     p_ifac_li_idx: (Output) The line item level ifac record index.
    --     p_ifac_pc_idxes: (Output) The profit center level ifac record
    --         indexes.
    --     p_ifac_vend_idxes: (Output) The vendor level ifac record
    --         indexes.
    --     p_context: (Might be modified) The operation context. The attribute
    --         ifac_period will be modified if no ifac records is provided.
    --     p_qty_line_item_key: The quantity line item to pull values to.
    --     p_document_rec: The cached document record.
    --     p_transaction_rec: The cached transaction record.
    --     p_transaction_qty_rec: The cached transaction quantity record.
    --     p_transaction_tmpl_rec: The cached transaction template version
    --         record.
    --
    -- Notes:
    --     Although some parameters are sent in as IN OUT NOCOPY, only
    --     following will be modified by this function:
    --     * p_context
    --
    -- Returns: true if context has been updated.
    ----+----------------------------------+-------------------------------
    FUNCTION prep_cntx_ifac_qty_li_period_p(
        p_ifac_li_idx                      OUT NUMBER
       ,p_ifac_pc_idxes                    OUT t_table_number
       ,p_ifac_vend_idxes                  OUT t_table_number
       ,p_context                          IN OUT NOCOPY T_REVN_DOC_OP_CONTEXT
       ,p_document_rec                     IN OUT NOCOPY cont_document%ROWTYPE
       ,p_transaction_rec                  IN OUT NOCOPY cont_transaction%ROWTYPE
       ,p_transaction_qty_rec              IN OUT NOCOPY cont_transaction_qty%ROWTYPE
       ,p_transaction_tmpl_rec             IN OUT NOCOPY transaction_tmpl_version%ROWTYPE
       )
    RETURN BOOLEAN
    IS
        l_ifac_all                         t_table_ifac_sales_qty;
        l_ifac_li                          t_ifac_sales_qty;
        l_use_price_object                 VARCHAR2(32);
        l_use_product_id                   VARCHAR2(32);
        l_use_price_concept_code           VARCHAR2(32);
        l_generated_ifac_from_context      BOOLEAN;
    BEGIN
        p_ifac_li_idx := NULL;
        p_ifac_pc_idxes := t_table_number();
        p_ifac_vend_idxes := t_table_number();
        l_generated_ifac_from_context := FALSE;

        -- determain price info
        IF p_transaction_rec.price_object_id IS NOT NULL
        THEN
            l_use_price_object := p_transaction_rec.price_object_id;
            l_use_product_id := ec_product_price.product_id(l_use_price_object);
            l_use_price_concept_code := ec_product_price.price_concept_code(l_use_price_object);
        END IF;

        -- query ifac if not provided
        IF p_context.IS_EMPTY_PERIOD_IFAC_DATA THEN
            p_context.ifac_period := ecdp_revn_ifac_wrapper_period.GetIfacForDocument(
                p_document_rec.object_id,
                p_document_rec.contract_doc_id,
                p_document_rec.processing_period,
                p_document_rec.customer_id,
                p_document_rec.status_code);

            l_generated_ifac_from_context := TRUE;
        END IF;

        IF p_context.IS_EMPTY_PERIOD_IFAC_DATA THEN
            RETURN FALSE;
        END IF;

        -- generates a local copy of the ifac table
        l_ifac_all := p_context.ifac_period;

        -- finds the line item to process
        p_ifac_li_idx := find_li_from_ifac_p(
            l_ifac_all, p_document_rec.object_id, l_use_price_concept_code,
            l_use_price_object, l_use_product_id, p_transaction_rec.delivery_point_id,
            p_document_rec.customer_id,
            p_transaction_tmpl_rec.req_qty_type, p_document_rec.status_code, p_transaction_rec.supply_from_date,
            p_transaction_rec.supply_to_date, p_transaction_qty_rec.uom1_code, p_transaction_rec.ifac_unique_key_1,
            p_transaction_rec.ifac_unique_key_2, p_transaction_rec.ifac_tt_conn_code,
            p_document_rec.processing_period, p_transaction_rec.trans_template_id, 'QTY', NULL, NULL);

        IF p_ifac_li_idx IS NOT NULL THEN
            l_ifac_li := l_ifac_all(p_ifac_li_idx);

            p_ifac_pc_idxes := ecdp_revn_ifac_wrapper_period.Find(
                p_ifac => l_ifac_all,
                p_level => ecdp_revn_ifac_wrapper.gconst_level_profit_center,
                p_trans_id => l_ifac_li.TRANS_ID,
                p_li_id => l_ifac_li.LI_ID);

            p_ifac_vend_idxes := ecdp_revn_ifac_wrapper_period.Find(
                p_ifac => l_ifac_all,
                p_level => ecdp_revn_ifac_wrapper.gconst_level_vendor,
                p_trans_id => l_ifac_li.TRANS_ID,
                p_li_id => l_ifac_li.LI_ID);
        END IF;

        RETURN l_generated_ifac_from_context;
    END;


 -----------------------------------------------------------------------
    -- Prepares context with ifac data for processing a quantity line item.
    --
    -- Parameters:
    --     p_ifac_li_idx: (Output) The line item level ifac record index.
    --     p_ifac_pc_idxes: (Output) The profit center level ifac record
    --         indexes.
    --     p_ifac_vend_idxes: (Output) The vendor level ifac record
    --         indexes.
    --     p_context: (Might be modified) The operation context. The attribute
    --         ifac_period will be modified if no ifac records is provided.
    --     p_qty_line_item_key: The quantity line item to pull values to.
    --     p_document_rec: The cached document record.
    --     p_transaction_rec: The cached transaction record.
    --     p_transaction_qty_rec: The cached transaction quantity record.
    --     p_transaction_tmpl_rec: The cached transaction template version
    --         record.
    --
    -- Notes:
    --     Although some parameters are sent in as IN OUT NOCOPY, only
    --     following will be modified by this function:
    --     * p_context
    --
    -- Returns: true if context has been updated.
    ----+----------------------------------+-------------------------------
    FUNCTION prep_cntx_ifac_qty_li_cargo_p(
        p_ifac_li_idx                      OUT NUMBER
       ,p_ifac_pc_idxes                    OUT t_table_number
       ,p_ifac_vend_idxes                  OUT t_table_number
       ,p_context                          IN OUT NOCOPY T_REVN_DOC_OP_CONTEXT
       ,p_document_rec                     IN OUT NOCOPY cont_document%ROWTYPE
       ,p_transaction_rec                  IN OUT NOCOPY cont_transaction%ROWTYPE
       ,p_transaction_qty_rec              IN OUT NOCOPY cont_transaction_qty%ROWTYPE
       ,p_transaction_tmpl_rec             IN OUT NOCOPY transaction_tmpl_version%ROWTYPE
       )
    RETURN BOOLEAN
    IS
        l_ifac_all                         t_table_ifac_cargo_value;
        l_ifac_li                          t_ifac_cargo_value;
        l_use_price_object                 VARCHAR2(32);
        l_use_product_id                   VARCHAR2(32);
        l_use_price_concept_code           VARCHAR2(32);
        l_generated_ifac_from_context      BOOLEAN;
    BEGIN
        p_ifac_li_idx := NULL;
        p_ifac_pc_idxes := t_table_number();
        p_ifac_vend_idxes := t_table_number();
        l_generated_ifac_from_context := FALSE;

        -- determain price info
        IF p_transaction_rec.price_object_id IS NOT NULL
        THEN
            l_use_price_object := p_transaction_rec.price_object_id;
            l_use_product_id := ec_product_price.product_id(l_use_price_object);
            l_use_price_concept_code := ec_product_price.price_concept_code(l_use_price_object);
        END IF;

        -- query ifac if not provided
        IF p_context.IS_EMPTY_cargo_IFAC_DATA THEN
            p_context.ifac_cargo := ecdp_revn_ifac_wrapper_cargo.GetIfacForDocument(
                p_document_rec.object_id,
                p_transaction_rec.cargo_name,
                null,
                p_document_rec.daytime,
                p_document_rec.contract_doc_id,
                p_document_rec.customer_id);

            l_generated_ifac_from_context := TRUE;
        END IF;

        IF p_context.IS_EMPTY_cargo_IFAC_DATA THEN
            RETURN FALSE;
        END IF;

        -- generates a local copy of the ifac table
        l_ifac_all := p_context.ifac_cargo;

        -- finds the line item to process
        p_ifac_li_idx := find_li_from_ifac_p(
            l_ifac_all, p_document_rec.object_id, l_use_price_concept_code,
            l_use_price_object, l_use_product_id, p_transaction_rec.delivery_point_id,
            p_document_rec.customer_id,
            p_transaction_tmpl_rec.req_qty_type, p_document_rec.status_code, p_transaction_rec.supply_from_date,
            p_transaction_rec.supply_to_date, p_transaction_qty_rec.uom1_code, p_transaction_rec.ifac_unique_key_1,
            p_transaction_rec.ifac_unique_key_2, p_transaction_rec.ifac_tt_conn_code,
            p_document_rec.processing_period, p_transaction_rec.trans_template_id, 'QTY', NULL, NULL,p_transaction_rec.parcel_name);

        IF p_ifac_li_idx IS NOT NULL THEN
            l_ifac_li := l_ifac_all(p_ifac_li_idx);

            p_ifac_pc_idxes := ecdp_revn_ifac_wrapper_cargo.Find(
                p_ifac => l_ifac_all,
                p_level => ecdp_revn_ifac_wrapper.gconst_level_profit_center,
                p_trans_id => l_ifac_li.TRANS_ID,
                p_li_id => l_ifac_li.LI_ID);

            p_ifac_vend_idxes := ecdp_revn_ifac_wrapper_cargo.Find(
                p_ifac => l_ifac_all,
                p_level => ecdp_revn_ifac_wrapper.gconst_level_vendor,
                p_trans_id => l_ifac_li.TRANS_ID,
                p_li_id => l_ifac_li.LI_ID);
        END IF;

        RETURN l_generated_ifac_from_context;
    END;

    -----------------------------------------------------------------------
    -- Applys transaction quantity changes to cont_transaction_qty.
    ----+----------------------------------+-------------------------------
    PROCEDURE apply_trans_quantity_p(
        p_transaction_qty_rec              cont_transaction_qty%ROWTYPE
       ,p_transaction_rec                  cont_transaction%ROWTYPE
       ,p_preced_transaction_qty_rec       cont_transaction_qty%ROWTYPE
        )
    IS
        l_net_grs_indicator                cont_transaction_qty.net_grs_indicator%TYPE;
    BEGIN

        l_net_grs_indicator := ecdp_transaction.GetNetGrsIndicator(p_transaction_rec.object_id, p_transaction_rec.transaction_key);

        IF p_transaction_rec.preceding_trans_key IS NOT NULL AND p_transaction_qty_rec.pre_net_qty1 IS NULL THEN
            -- updates quantities and preceding quantities
            -- uses user 'system' to avoid revision for this temporary update
            UPDATE cont_transaction_qty
            SET last_updated_by   = ecdp_revn_common.gv2_user_system,
                net_grs_indicator = nvl(net_grs_indicator, l_net_grs_indicator),
                net_qty1 = p_transaction_qty_rec.net_qty1,
                net_qty2 = p_transaction_qty_rec.net_qty2,
                net_qty3 = p_transaction_qty_rec.net_qty3,
                net_qty4 = p_transaction_qty_rec.net_qty4,
                pre_net_qty1 = p_preced_transaction_qty_rec.net_qty1,
                pre_net_qty2 = p_preced_transaction_qty_rec.net_qty2,
                pre_net_qty3 = p_preced_transaction_qty_rec.net_qty3,
                pre_net_qty4 = p_preced_transaction_qty_rec.net_qty4
            WHERE object_id = p_transaction_rec.object_id
            AND transaction_key = p_transaction_rec.transaction_key;
        ELSE
            -- updates quantities and preceding quantities
            -- uses user 'system' to avoid revision for this temporary update
            UPDATE cont_transaction_qty
            SET last_updated_by   = ecdp_revn_common.gv2_user_system,
                net_grs_indicator = nvl(net_grs_indicator, l_net_grs_indicator),
                net_qty1 = p_transaction_qty_rec.net_qty1,
                net_qty2 = p_transaction_qty_rec.net_qty2,
                net_qty3 = p_transaction_qty_rec.net_qty3,
                net_qty4 = p_transaction_qty_rec.net_qty4
            WHERE object_id = p_transaction_rec.object_id
            AND transaction_key = p_transaction_rec.transaction_key;
        END IF;
    END;

    -----------------------------------------------------------------------
    -- Sets transaction quantities from given ifac data.
    --
    -- Parameters:
    --     p_transaction_qty_rec: The transaction quantity record where
    --         updates will apply.
    --     p_transaction_rec: The transaction record whose quantity is going
    --         to be updated.
    --     p_ifac_li_level: The ifac record holds quantities to be updated.
    --         This should be the line item level record.
    --
    -- Parameters to modify:
    --    p_transaction_qty_rec
    ----+----------------------------------+-------------------------------
    PROCEDURE set_trans_net_qty_from_ifac_p(
        p_transaction_qty_rec              IN OUT NOCOPY cont_transaction_qty%ROWTYPE
       ,p_transaction_rec                  IN OUT NOCOPY cont_transaction%ROWTYPE
       ,p_ifac_li_level                    IN OUT NOCOPY t_ifac_sales_qty
       )
    IS
        l_uom_set                          EcDp_Unit.t_uomtable;
    BEGIN
        l_uom_set := EcDp_Unit.t_uomtable();

        EcDp_Unit.GenQtyUOMSet(l_uom_set
            ,p_ifac_li_level.qty1, p_ifac_li_level.uom1_code
            ,p_ifac_li_level.qty2, p_ifac_li_level.uom2_code
            ,p_ifac_li_level.qty3, p_ifac_li_level.uom3_code
            ,p_ifac_li_level.qty4, p_ifac_li_level.uom4_code);

        -- Pick correct figures for each starting with UOM1
        p_transaction_qty_rec.net_qty1 := EcDp_Revn_Unit.GetUOMSetQty(
            l_uom_set, p_transaction_qty_rec.UOM1_CODE, p_transaction_rec.supply_from_date, p_transaction_rec.stream_item_id);

        IF p_transaction_qty_rec.UOM2_CODE IS NOT NULL THEN
            p_transaction_qty_rec.net_qty2 := EcDp_Revn_Unit.GetUOMSetQty(
                l_uom_set, p_transaction_qty_rec.UOM2_CODE, p_transaction_rec.supply_from_date, p_transaction_rec.stream_item_id);
        END IF;

        IF p_transaction_qty_rec.UOM3_CODE IS NOT NULL THEN
            p_transaction_qty_rec.net_qty3 := EcDp_Revn_Unit.GetUOMSetQty(
                l_uom_set, p_transaction_qty_rec.UOM3_CODE, p_transaction_rec.supply_from_date, p_transaction_rec.stream_item_id);
        END IF;

        IF p_transaction_qty_rec.UOM4_CODE IS NOT NULL THEN
            p_transaction_qty_rec.net_qty4 := EcDp_Revn_Unit.GetUOMSetQty(
                l_uom_set, p_transaction_qty_rec.UOM4_CODE, p_transaction_rec.supply_from_date, p_transaction_rec.stream_item_id);
        END IF;
    END;

   -----------------------------------------------------------------------
    -- Sets transaction quantities from given ifac data.
    --
    -- Parameters:
    --     p_transaction_qty_rec: The transaction quantity record where
    --         updates will apply.
    --     p_transaction_rec: The transaction record whose quantity is going
    --         to be updated.
    --     p_ifac_li_level: The ifac record holds quantities to be updated.
    --         This should be the line item level record.
    --
    -- Parameters to modify:
    --    p_transaction_qty_rec
    ----+----------------------------------+-------------------------------
    PROCEDURE set_trans_net_qty_from_ifac_p(
        p_transaction_qty_rec              IN OUT NOCOPY cont_transaction_qty%ROWTYPE
       ,p_transaction_rec                  IN OUT NOCOPY cont_transaction%ROWTYPE
       ,p_ifac_li_level                    IN OUT NOCOPY t_ifac_cargo_value
       )
    IS
        l_uom_set                          EcDp_Unit.t_uomtable;
    BEGIN
        l_uom_set := EcDp_Unit.t_uomtable();

        EcDp_Unit.GenQtyUOMSet(l_uom_set
            ,p_ifac_li_level.NET_QTY1, p_ifac_li_level.uom1_code
            ,p_ifac_li_level.NET_QTY2, p_ifac_li_level.uom2_code
            ,p_ifac_li_level.NET_QTY3, p_ifac_li_level.uom3_code
            ,p_ifac_li_level.NET_QTY4, p_ifac_li_level.uom4_code);

        -- Pick correct figures for each starting with UOM1
        p_transaction_qty_rec.net_qty1 := EcDp_Revn_Unit.GetUOMSetQty(
            l_uom_set, p_transaction_qty_rec.UOM1_CODE, p_transaction_rec.supply_from_date, p_transaction_rec.stream_item_id);

        IF p_transaction_qty_rec.UOM2_CODE IS NOT NULL THEN
            p_transaction_qty_rec.net_qty2 := EcDp_Revn_Unit.GetUOMSetQty(
                l_uom_set, p_transaction_qty_rec.UOM2_CODE, p_transaction_rec.supply_from_date, p_transaction_rec.stream_item_id);
        END IF;

        IF p_transaction_qty_rec.UOM3_CODE IS NOT NULL THEN
            p_transaction_qty_rec.net_qty3 := EcDp_Revn_Unit.GetUOMSetQty(
                l_uom_set, p_transaction_qty_rec.UOM3_CODE, p_transaction_rec.supply_from_date, p_transaction_rec.stream_item_id);
        END IF;

        IF p_transaction_qty_rec.UOM4_CODE IS NOT NULL THEN
            p_transaction_qty_rec.net_qty4 := EcDp_Revn_Unit.GetUOMSetQty(
                l_uom_set, p_transaction_qty_rec.UOM4_CODE, p_transaction_rec.supply_from_date, p_transaction_rec.stream_item_id);
        END IF;
    END;

    -----------------------------------------------------------------------
    -- Asserts the transaction distribution summary consistency.
    --
    -- Parameters:
    --     p_transaction_key: The transaction key.
    ----+----------------------------------+-------------------------------
    PROCEDURE assert_dist_consistency_p(
        p_transaction_key                  cont_transaction.transaction_key%TYPE
        )
    IS
        CURSOR c_sum_vend_level(
            cp_transaction_key             cont_transaction.transaction_key%TYPE
        ) IS
            SELECT sum(qty1) as vend_qty1,
                sum(qty2) as vend_qty2,
                sum(qty3) as vend_qty3,
                sum(qty4) as vend_qty4
            FROM
            (
                SELECT DISTINCT sum(clidc.qty1) as qty1, sum(clidc.qty2) as qty2, sum(clidc.qty3) as qty3, sum(clidc.qty4) as qty4
                FROM cont_li_dist_company clidc
                WHERE clidc.transaction_key = cp_transaction_key
                AND clidc.line_item_based_type != 'QTY'
                GROUP BY clidc.line_item_key
                UNION
                SELECT DISTINCT sum(clidc.qty1), sum(clidc.qty2), sum(clidc.qty3), sum(clidc.qty4)
                FROM cont_li_dist_company clidc
                WHERE clidc.transaction_key = cp_transaction_key
                AND clidc.line_item_based_type = 'QTY'
                GROUP BY clidc.line_item_key
            );

        CURSOR c_sum_pc_level(
            cp_transaction_key             cont_transaction.transaction_key%TYPE
        ) IS
            SELECT sum(qty1) as pc_qty1,
                sum(qty2) as pc_qty2,
                sum(qty3) as pc_qty3,
                sum(qty4) as pc_qty4
            FROM (
                SELECT DISTINCT clid.qty1, clid.qty2, clid.qty3, clid.qty4
                FROM cont_line_item_dist clid
                WHERE clid.transaction_key = cp_transaction_key
                AND clid.line_item_based_type != 'QTY'
                UNION ALL
                SELECT DISTINCT clid.qty1, clid.qty2, clid.qty3, clid.qty4
                FROM cont_line_item_dist clid
                WHERE clid.transaction_key = cp_transaction_key
                AND clid.line_item_based_type = 'QTY'
            );

        CURSOR c_sum_tran_level(
            cp_transaction_key             cont_transaction.transaction_key%TYPE
        ) IS
            SELECT sum(ct.net_qty1) as tran_qty1,
                sum(ct.net_qty2) as tran_qty2,
                sum(ct.net_qty3) as tran_qty3,
                sum(ct.net_qty4) as tran_qty4
            FROM cont_transaction_qty ct
            WHERE ct.transaction_key = cp_transaction_key;

        sum_qty1_tran_level                NUMBER := 0;
        sum_qty2_tran_level                NUMBER := 0;
        sum_qty3_tran_level                NUMBER := 0;
        sum_qty4_tran_level                NUMBER := 0;
        sum_qty1_pc_level                  NUMBER := 0;
        sum_qty2_pc_level                  NUMBER := 0;
        sum_qty3_pc_level                  NUMBER := 0;
        sum_qty4_pc_level                  NUMBER := 0;
        sum_qty1_vend_level                NUMBER := 0;
        sum_qty2_vend_level                NUMBER := 0;
        sum_qty3_vend_level                NUMBER := 0;
        sum_qty4_vend_level                NUMBER := 0;
    BEGIN
        -- checks if the values at profit centre and transaction and vendor level match
        FOR c_vend IN c_sum_vend_level(p_transaction_key) LOOP
            sum_qty1_vend_level := c_vend.vend_qty1;
            sum_qty2_vend_level := c_vend.vend_qty2;
            sum_qty3_vend_level := c_vend.vend_qty3;
            sum_qty4_vend_level := c_vend.vend_qty4;
        END LOOP;

        FOR c_pc IN c_sum_pc_level(p_transaction_key) LOOP
            sum_qty1_pc_level := c_pc.pc_qty1;
            sum_qty2_pc_level := c_pc.pc_qty2;
            sum_qty3_pc_level := c_pc.pc_qty3;
            sum_qty4_pc_level := c_pc.pc_qty4;
        END LOOP;

        FOR c_tran IN c_sum_tran_level(p_transaction_key) LOOP
            sum_qty1_tran_level := c_tran.tran_qty1;
            sum_qty2_tran_level := c_tran.tran_qty2;
            sum_qty3_tran_level := c_tran.tran_qty3;
            sum_qty4_tran_level := c_tran.tran_qty4;
        END LOOP;

        IF ((sum_qty1_vend_level != sum_qty1_pc_level)
            OR (sum_qty2_vend_level != sum_qty2_pc_level)
            OR (sum_qty3_vend_level != sum_qty3_pc_level)
            OR (sum_qty4_vend_level != sum_qty4_pc_level)) THEN
            RAISE ECDP_REVN_FT_ERROR.invalid_ifac_vendor_not_add_up;
        END IF;

        IF((sum_qty1_tran_level != sum_qty1_pc_level)
            OR (sum_qty2_tran_level != sum_qty2_pc_level)
            OR (sum_qty3_tran_level != sum_qty3_pc_level)
            OR (sum_qty4_tran_level != sum_qty4_pc_level)) THEN
            RAISE ECDP_REVN_FT_ERROR.invalid_ifac_pc_not_add_up;
        END IF;
    END;


    -----------------------------------------------------------------------
    -- Fill transaction quantity values from ifac.
    -- This procedure is for period-based transactions.
    --
    -- Parameters:
    --
    -- Parameters to modify:
    ----+----------------------------------+-------------------------------
    PROCEDURE fill_qty_tr_from_ifac_period_p(
        p_context                          IN OUT NOCOPY t_revn_doc_op_context
       ,p_document_rec                     IN OUT NOCOPY cont_document%ROWTYPE
       ,p_transaction_rec                  IN OUT NOCOPY cont_transaction%ROWTYPE
       ,p_transaction_qty_rec              IN OUT NOCOPY cont_transaction_qty%ROWTYPE
       ,p_transaction_qty_prec_rec         IN OUT NOCOPY cont_transaction_qty%ROWTYPE
       ,p_ifac_li_level_idx                NUMBER
       ,p_user                             VARCHAR2
       )
    IS
        l_ifac_all                         t_table_ifac_sales_qty;
        l_ifac_li                          t_ifac_sales_qty;
    BEGIN
        l_ifac_all := p_context.ifac_period;
        l_ifac_li := l_ifac_all(p_ifac_li_level_idx);

        SetTransVAT(p_transaction_rec.transaction_key, l_ifac_li.vat_code, p_user);
        ecdp_transaction.resetlineitemshares(p_transaction_rec.transaction_key);

        -- TODO: limit the update to only once
        -- Set status code from interface if not set already (applies to manual created
        -- document and quantities from interface)
        IF p_document_rec.status_code IS NULL AND l_ifac_li.doc_status IS NOT NULL THEN
            UPDATE cont_document
            SET status_code = l_ifac_li.doc_status
            WHERE document_key = p_document_rec.document_key;
        END IF;

        set_trans_net_qty_from_ifac_p(p_transaction_qty_rec, p_transaction_rec, l_ifac_li);
        apply_trans_quantity_p(p_transaction_qty_rec, p_transaction_rec, p_transaction_qty_prec_rec);

        -- generates distribution for reduced config
        IF ecdp_transaction.IsReducedConfig(
            NULL, NULL, p_transaction_rec.trans_template_id, p_transaction_rec.transaction_key, p_transaction_rec.daytime) THEN
            -- Reference interface price object on transaction
            SetTransPriceObject(
                p_transaction_rec.transaction_key,
                GetTransPriceObject(
                    p_transaction_rec.price_object_id,
                    l_ifac_li.Price_Object_Id,
                    p_transaction_rec.daytime,
                    'N',
                    ec_contract_doc_version.doc_concept_code(l_ifac_li.doc_setup_id, p_transaction_rec.daytime, '<=')),
                p_user,
                l_ifac_li.qty_status);
            ecdp_transaction.SetTransStreamItem(p_transaction_rec.transaction_key, p_user, l_ifac_li.source_node_id, l_ifac_li.uom1_code);
        END IF;
    END;




    -----------------------------------------------------------------------
    -- Fill transaction quantity values from ifac.
    -- This procedure is for cargo-based transactions.
    --
    -- Parameters:
    --
    -- Parameters to modify:
    ----+----------------------------------+-------------------------------
    PROCEDURE fill_qty_tr_from_ifac_cargo_p(
        p_context                          IN OUT NOCOPY t_revn_doc_op_context
       ,p_document_rec                     IN OUT NOCOPY cont_document%ROWTYPE
       ,p_transaction_rec                  IN OUT NOCOPY cont_transaction%ROWTYPE
       ,p_transaction_qty_rec              IN OUT NOCOPY cont_transaction_qty%ROWTYPE
       ,p_transaction_qty_prec_rec         IN OUT NOCOPY cont_transaction_qty%ROWTYPE
       ,p_ifac_li_level_idx                NUMBER
       ,p_user                             VARCHAR2
       )
    IS
        l_ifac_all                         t_table_ifac_cargo_value;
        l_ifac_li                          t_ifac_cargo_value;
    BEGIN
        l_ifac_all := p_context.ifac_cargo;
        l_ifac_li := l_ifac_all(p_ifac_li_level_idx);

        SetTransVAT(p_transaction_rec.transaction_key, l_ifac_li.vat_code, p_user);
        ecdp_transaction.resetlineitemshares(p_transaction_rec.transaction_key);

        -- TODO: limit the update to only once
        -- Set status code from interface if not set already (applies to manual created
        -- document and quantities from interface)
        IF p_document_rec.status_code IS NULL AND l_ifac_li.doc_status IS NOT NULL THEN
            UPDATE cont_document
            SET status_code = l_ifac_li.doc_status
            WHERE document_key = p_document_rec.document_key;
        END IF;

        set_trans_net_qty_from_ifac_p(p_transaction_qty_rec, p_transaction_rec, l_ifac_li);
        apply_trans_quantity_p(p_transaction_qty_rec, p_transaction_rec, p_transaction_qty_prec_rec);

        -- generates distribution for reduced config
        IF ecdp_transaction.IsReducedConfig(
            NULL, NULL, p_transaction_rec.trans_template_id, p_transaction_rec.transaction_key, p_transaction_rec.daytime) THEN
            -- Reference interface price object on transaction
            SetTransPriceObject(
                p_transaction_rec.transaction_key,
                GetTransPriceObject(
                    p_transaction_rec.price_object_id,
                    l_ifac_li.Price_Object_Id,
                    p_transaction_rec.daytime,
                    'N',
                    ec_contract_doc_version.doc_concept_code(l_ifac_li.doc_setup_id, p_transaction_rec.daytime, '<=')),
                p_user,
                l_ifac_li.status);
            ecdp_transaction.SetTransStreamItem(p_transaction_rec.transaction_key, p_user, l_ifac_li.source_node_id, l_ifac_li.uom1_code);
        END IF;
    END;

    -----------------------------------------------------------------------
    -- Fill quantity line item values and distributions from ifac.
    -- This procedure is for line items in period-based transactions.
    --
    -- Returns: true if quantities found from ifac else false.
    ----+----------------------------------+-------------------------------
    FUNCTION fill_qty_from_ifac_period_p(
        p_transaction_key                  VARCHAR2
       ,p_user                             VARCHAR2
       ,p_context                          IN OUT NOCOPY T_REVN_DOC_OP_CONTEXT
       ,p_force_update                     BOOLEAN DEFAULT FALSE
    )
    RETURN BOOLEAN
    IS
        already_processed                  EXCEPTION;
        no_uom                             EXCEPTION;

        lrec_tran_qty                      cont_transaction_qty%ROWTYPE;
        lrec_tran                          cont_transaction%ROWTYPE;
        lrec_pre_tran_qty                  cont_transaction_qty%ROWTYPE;
        lrec_tt                            transaction_tmpl_version%ROWTYPE;
        lrec_doc                           cont_document%ROWTYPE;

        generated_ifac_from_context        BOOLEAN;
        l_last_processed_li_key            cont_line_item.line_item_key%TYPE;
        l_ifac_li                          t_ifac_sales_qty;
        ifac_li_idx                        NUMBER;
        ifac_pc_idxes                      t_table_number;
        ifac_vend_idxes                    t_table_number;
        l_li_filled                        BOOLEAN;
    BEGIN
        generated_ifac_from_context := FALSE;
        lrec_tran_qty := ec_cont_transaction_qty.row_by_pk(p_transaction_key);

        if lrec_tran_qty.transaction_key is null then
            RETURN FALSE;
        end if;

        IF (lrec_tran_qty.NET_QTY1 IS NOT NULL AND p_force_update = FALSE) THEN
           RAISE already_processed;
        END IF;

        -- Must have at least one UOM
        IF lrec_tran_qty.UOM1_CODE IS NULL THEN
           RAISE no_uom;
        END IF;

        lrec_tran := ec_cont_transaction.row_by_pk(p_transaction_key);
        lrec_pre_tran_qty := ec_cont_transaction_qty.row_by_pk(lrec_tran.preceding_trans_key);
        lrec_tt := ec_transaction_tmpl_version.row_by_pk(lrec_tran.trans_template_id, lrec_tran.daytime, '<=');
        lrec_doc := ec_cont_document.row_by_pk(lrec_tran.document_key);

        -- TODO: move this up to the API
        generated_ifac_from_context := prep_cntx_ifac_qty_li_period_p(
            ifac_li_idx, ifac_pc_idxes, ifac_vend_idxes, p_context,
            lrec_doc, lrec_tran, lrec_tran_qty, lrec_tt);

        IF ifac_li_idx IS NULL THEN
            RETURN FALSE;
        END IF;

        fill_qty_tr_from_ifac_period_p(
            p_context, lrec_doc, lrec_tran, lrec_tran_qty, lrec_pre_tran_qty,
            ifac_li_idx, p_user);

        -- Add in qty line items for all related price concept elements. Valid for reduced config only.
        IF ecdp_transaction.IsReducedConfig(NULL, NULL, lrec_tran.trans_template_id, p_transaction_key, lrec_tran.daytime) THEN
            create_missing_qty_li_by_pel_i(lrec_tran.transaction_key);
        END IF;

        -- refresh transaction record
        lrec_tran := ec_cont_transaction.row_by_pk(p_transaction_key);
        l_ifac_li := p_context.get_ifac_period(ifac_li_idx);

        FOR qty_li IN ecdp_line_item.c_qty_lines(p_transaction_key) LOOP
            l_last_processed_li_key := qty_li.line_item_key;

            -- Update values picked up in interface
            p_context.update_ifac_keys_period(
                l_ifac_li.trans_id, lrec_tran.transaction_key, l_ifac_li.li_id, qty_li.line_item_key);
            p_context.update_all_ifac_doc_key_period(lrec_tran.document_key);

            l_li_filled := ecdp_line_item.fill_by_ifac_i(p_context, qty_li.line_item_key);
        END LOOP;

        assert_dist_consistency_p(p_transaction_key);

        IF l_last_processed_li_key IS NULL THEN
            RETURN FALSE;
        END IF;

        p_context.apply_ifac_period_keys(l_ifac_li.trans_id, l_ifac_li.li_id);

        IF generated_ifac_from_context THEN
            p_context.ifac_period := NULL;
        END IF;

        RETURN TRUE;

    EXCEPTION
         WHEN already_processed THEN
             RETURN FALSE;
         WHEN no_uom THEN
             Raise_Application_Error(-20000,'No UOM1 supplied for contract: '
                 || Nvl(ec_contract.object_code(lrec_tran.object_id),' ') || ' - '
                 || Nvl(ec_contract_version.name(lrec_tran.object_id, lrec_tran.supply_from_date, '<='),' '));
         WHEN ecdp_revn_ft_error.no_vendor_dist_config_found THEN
             ecdp_revn_ft_error.r_no_vendor_dist_config_found;
         WHEN ecdp_revn_ft_error.invalid_ifac_vendor_not_add_up THEN
             ecdp_revn_ft_error.r_invalid_ifac_vendor_not_ad__;
         WHEN ecdp_revn_ft_error.invalid_ifac_pc_not_add_up THEN
             ecdp_revn_ft_error.r_invalid_ifac_pc_not_add_up;
    END;


  -----------------------------------------------------------------------
    -- Fill quantity line item values and distributions from ifac.
    -- This procedure is for line items in cargo-based transactions.
    --
    -- Returns: true if quantities found from ifac else false.
    ----+----------------------------------+-------------------------------
    FUNCTION fill_qty_from_ifac_cargo_p(
        p_transaction_key                  VARCHAR2
       ,p_user                             VARCHAR2
       ,p_context                          IN OUT NOCOPY T_REVN_DOC_OP_CONTEXT
       ,p_force_update                     BOOLEAN DEFAULT FALSE
    )
    RETURN BOOLEAN
    IS
        already_processed                  EXCEPTION;
        no_uom                             EXCEPTION;

        lrec_tran_qty                      cont_transaction_qty%ROWTYPE;
        lrec_tran                          cont_transaction%ROWTYPE;
        lrec_pre_tran_qty                  cont_transaction_qty%ROWTYPE;
        lrec_tt                            transaction_tmpl_version%ROWTYPE;
        lrec_doc                           cont_document%ROWTYPE;

        generated_ifac_from_context        BOOLEAN;
        l_last_processed_li_key            cont_line_item.line_item_key%TYPE;
        l_ifac_li                          t_ifac_cargo_value;
        ifac_li_idx                        NUMBER;
        ifac_pc_idxes                      t_table_number;
        ifac_vend_idxes                    t_table_number;
        l_li_filled                        BOOLEAN;
    BEGIN
        generated_ifac_from_context := FALSE;
        lrec_tran_qty := ec_cont_transaction_qty.row_by_pk(p_transaction_key);

        if lrec_tran_qty.transaction_key is null then
            RETURN FALSE;
        end if;

        IF (lrec_tran_qty.NET_QTY1 IS NOT NULL AND p_force_update = FALSE) THEN
           RAISE already_processed;
        END IF;

        -- Must have at least one UOM
        IF lrec_tran_qty.UOM1_CODE IS NULL THEN
           RAISE no_uom;
        END IF;

        lrec_tran := ec_cont_transaction.row_by_pk(p_transaction_key);
        lrec_pre_tran_qty := ec_cont_transaction_qty.row_by_pk(lrec_tran.preceding_trans_key);
        lrec_tt := ec_transaction_tmpl_version.row_by_pk(lrec_tran.trans_template_id, lrec_tran.daytime, '<=');
        lrec_doc := ec_cont_document.row_by_pk(lrec_tran.document_key);

        -- TODO: move this up to the API
        generated_ifac_from_context := prep_cntx_ifac_qty_li_cargo_p(
            ifac_li_idx, ifac_pc_idxes, ifac_vend_idxes, p_context,
            lrec_doc, lrec_tran, lrec_tran_qty, lrec_tt);

        IF ifac_li_idx IS NULL THEN
            RETURN FALSE;
        END IF;

        fill_qty_tr_from_ifac_cargo_p(
            p_context, lrec_doc, lrec_tran, lrec_tran_qty, lrec_pre_tran_qty,
            ifac_li_idx, p_user);

        -- Add in qty line items for all related price concept elements. Valid for reduced config only.
        IF ecdp_transaction.IsReducedConfig(NULL, NULL, lrec_tran.trans_template_id, p_transaction_key, lrec_tran.daytime) THEN
            create_missing_qty_li_by_pel_i(lrec_tran.transaction_key);
        END IF;

        -- refresh transaction record
        lrec_tran := ec_cont_transaction.row_by_pk(p_transaction_key);
        l_ifac_li := p_context.get_ifac_cargo(ifac_li_idx);

        FOR qty_li IN ecdp_line_item.c_qty_lines(p_transaction_key) LOOP
            l_last_processed_li_key := qty_li.line_item_key;

            -- Update values picked up in interface
            p_context.update_ifac_keys_cargo(
                l_ifac_li.trans_id, lrec_tran.transaction_key, l_ifac_li.li_id, qty_li.line_item_key);
            p_context.update_all_ifac_doc_key_cargo(lrec_tran.document_key);

            l_li_filled := ecdp_line_item.fill_by_ifac_i(p_context, qty_li.line_item_key);
        END LOOP;

        assert_dist_consistency_p(p_transaction_key);

        IF l_last_processed_li_key IS NULL THEN
            RETURN FALSE;
        END IF;

        p_context.apply_ifac_cargo_keys(l_ifac_li.trans_id, l_ifac_li.li_id);

        IF generated_ifac_from_context THEN
            p_context.ifac_period := NULL;
        END IF;

        RETURN TRUE;

    EXCEPTION
         WHEN already_processed THEN
             RETURN FALSE;
         WHEN no_uom THEN
             Raise_Application_Error(-20000,'No UOM1 supplied for contract: '
                 || Nvl(ec_contract.object_code(lrec_tran.object_id),' ') || ' - '
                 || Nvl(ec_contract_version.name(lrec_tran.object_id, lrec_tran.supply_from_date, '<='),' '));
         WHEN ecdp_revn_ft_error.no_vendor_dist_config_found THEN
             ecdp_revn_ft_error.r_no_vendor_dist_config_found;
         WHEN ecdp_revn_ft_error.invalid_ifac_vendor_not_add_up THEN
             ecdp_revn_ft_error.r_invalid_ifac_vendor_not_ad__;
         WHEN ecdp_revn_ft_error.invalid_ifac_pc_not_add_up THEN
             ecdp_revn_ft_error.r_invalid_ifac_pc_not_add_up;
    END;





--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  GenTranQtyFromDayVO
-- Description    :
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------
FUNCTION GenTransQtyFromDayVO_P(p_object_id      VARCHAR2,
                             p_transaction_id VARCHAR2,
                             p_start_date     DATE,
                             p_end_date       DATE,
                             p_status         VARCHAR2 -- FINAL or ACCRUAL
                             )
RETURN BOOLEAN
--</EC-DOC>
IS
/**/
CURSOR c_sdv(pc_si_id  objects.object_id%TYPE, pc_status VARCHAR2) IS
SELECT *
FROM stim_day_value
WHERE object_id = pc_si_id
  AND (daytime >= p_start_date AND daytime <= p_end_date)
  AND (status = 'FINAL' OR status = pc_status)
  AND nvl(calc_method,'NA') != 'SP'; -- Using NA because Calc method on object will never be OW/SP

already_processed EXCEPTION;
no_uom EXCEPTION;

ib_found BOOLEAN := FALSE;
ln_day_count NUMBER := 0;

ltab_uom_set EcDp_Unit.t_uomtable := EcDp_Unit.t_uomtable();
lrec_tran_qty cont_transaction_qty%ROWTYPE := ec_cont_transaction_qty.row_by_pk(p_transaction_id);
lrec_tran cont_transaction%ROWTYPE := ec_cont_transaction.row_by_pk(p_transaction_id);
lrec_pre_tran_qty cont_transaction_qty%ROWTYPE := ec_cont_transaction_qty.row_by_pk(lrec_tran.preceding_trans_key);
/**/
BEGIN

      ----------------------------------------------------------------------------
      -- Check for Daily STIM_DAY_VALUE figures
      IF NOT ib_found THEN

        -- need to sum over all days in period
        lrec_tran_qty.net_qty1 := 0;
        lrec_tran_qty.net_qty2 := 0;
        lrec_tran_qty.net_qty3 := 0;
        lrec_tran_qty.net_qty4 := 0;

--        FOR SDVCur IN c_sdv(lrec_tran.stream_item_object_id, p_status) LOOP
        FOR SDVCur IN c_sdv(lrec_tran.stream_item_id, p_status) LOOP

            ln_day_count := ln_day_count + 1;

            -- copy figures
            EcDp_Unit.GenQtyUOMSet(ltab_uom_set
                                   ,SDVCur.net_volume_value, SDVCur.volume_uom_code
                                   ,SDVCur.net_mass_value, SDVCur.mass_uom_code
                                   ,SDVCur.net_energy_value, SDVCur.energy_uom_code
                                   ,SDVCur.net_extra1_value, SDVCur.extra1_uom_code
                                   ,SDVCur.net_extra2_value, SDVCur.extra2_uom_code
                                   ,SDVCur.net_extra3_value, SDVCur.extra3_uom_code
                                   );

            IF lrec_tran_qty.UOM1_CODE IS NULL THEN

               -- must have at least one UOM
               RAISE no_uom;

            END IF;

            -- add up over all days
            lrec_tran_qty.net_qty1 := lrec_tran_qty.net_qty1 + EcDp_Revn_Unit.GetUOMSetQty(ltab_uom_set,lrec_tran_qty.UOM1_CODE,p_start_date, SDVCur.Object_Id);

            IF lrec_tran_qty.UOM2_CODE IS NOT NULL THEN
               lrec_tran_qty.net_qty2 := lrec_tran_qty.net_qty2 + EcDp_Revn_Unit.GetUOMSetQty(ltab_uom_set,lrec_tran_qty.UOM2_CODE,p_start_date, SDVCur.Object_Id);
            END IF;

            IF lrec_tran_qty.UOM3_CODE IS NOT NULL THEN
               lrec_tran_qty.net_qty3 := lrec_tran_qty.net_qty3 + EcDp_Revn_Unit.GetUOMSetQty(ltab_uom_set,lrec_tran_qty.UOM3_CODE,p_start_date, SDVCur.Object_Id);
            END IF;

            IF lrec_tran_qty.UOM4_CODE IS NOT NULL THEN
               lrec_tran_qty.net_qty4 := lrec_tran_qty.net_qty4 + EcDp_Revn_Unit.GetUOMSetQty(ltab_uom_set,lrec_tran_qty.UOM4_CODE,p_start_date, SDVCur.Object_Id);
            END IF;


        END LOOP;

        IF ln_day_count = (p_end_date - p_start_date + 1) THEN

          ib_found := TRUE;

          -- no marking of daily records

        END IF;

      END IF;

      IF ib_found THEN

          -- update transaction_qty with new numbers
          UPDATE cont_transaction_qty
             SET last_updated_by = 'SYSTEM' -- avoid revision for this temporary update
                ,
                 net_qty1        = lrec_tran_qty.net_qty1,
                 net_qty2        = lrec_tran_qty.net_qty2,
                 net_qty3        = lrec_tran_qty.net_qty3,
                 net_qty4        = lrec_tran_qty.net_qty4
           WHERE object_id = p_object_id
             AND transaction_key = p_transaction_id;

        IF lrec_tran.preceding_trans_key IS NOT NULL AND lrec_tran_qty.pre_net_qty1 IS NULL THEN

           -- Updating the preceding quantity
           UPDATE cont_transaction_qty
              SET last_updated_by = 'SYSTEM', -- avoid revision for this temporary update
                  pre_net_qty1    = lrec_pre_tran_qty.net_qty1,
                  pre_net_qty2    = lrec_pre_tran_qty.net_qty2,
                  pre_net_qty3    = lrec_pre_tran_qty.net_qty3,
                  pre_net_qty4    = lrec_pre_tran_qty.net_qty4
            WHERE object_id = p_object_id
              AND transaction_key = p_transaction_id;

        END IF;

      END IF;

   RETURN ib_found;

EXCEPTION
     WHEN already_processed THEN
              -- Do not raise application error, normal exit of procedure
              RETURN ib_found;
     WHEN no_uom THEN
              Raise_Application_Error(-20000,'No UOM1 supplied for contract: ' || Nvl(ec_contract.object_code(p_object_id),' ') || ' - ' || Nvl(ec_contract_version.name(p_object_id, p_start_date, '<='),' ') );

END GenTransQtyFromDayVO_P;



------------------------+-----------------------------------+------------------------------------+---------------------------
-- Fill quantity line item values and distributions from ifac.
-- This procedure is for line items in cargo-based transactions.
--
-- Returns: true if quantities found from ifac else false.
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GenTransQtyFromIfac_Cargo_P(p_contract_id      VARCHAR2,
                             p_transaction_key VARCHAR2,
                             p_daytime        DATE, -- can be NULL if hit on cargo / parcel in i/f table
                             p_cargo_no       VARCHAR2,
                             p_parcel_no      VARCHAR2,
                             p_qty_type       VARCHAR2,
                             p_status_code    VARCHAR2, -- FINAL or ACCRUAL
                             p_user           VARCHAR2,
                             p_ifac_tt_conn_code VARCHAR2)
RETURN BOOLEAN
IS

-- FIELD level. All stream items for a given transaction
CURSOR c_field_si(cp_transaction_key VARCHAR2) IS
  SELECT DISTINCT clid.stream_item_id, clid.line_item_key, clid.dist_id
    FROM cont_line_item_dist clid
   WHERE clid.transaction_key = cp_transaction_key;

CURSOR c_field_li(cp_transaction_key VARCHAR2, cp_dist_id VARCHAR2) IS
SELECT d.*
  FROM cont_line_item_dist d
 WHERE d.transaction_key = cp_transaction_key
   AND d.dist_id = cp_dist_id
   AND d.line_item_based_type = 'QTY';

-- COMPANY level. All stream items for a given transaction and stream item
CURSOR c_field_company_si(cp_transaction_key VARCHAR2, cp_line_item_key VARCHAR2, cp_dist_id VARCHAR2) IS
SELECT DISTINCT clidc.company_stream_item_id,
                clidc.stream_item_id,
                clidc.dist_id,
                clidc.line_item_key,
                clidc.vendor_id,
                clidc.customer_id
  FROM cont_li_dist_company clidc
 WHERE clidc.transaction_key = cp_transaction_key
   AND clidc.line_item_key = cp_line_item_key
   AND clidc.dist_id = cp_dist_id;

CURSOR c_field_company_li(cp_transaction_key VARCHAR2, cp_dist_id VARCHAR2, cp_vendor_id VARCHAR2, cp_customer_id VARCHAR2) IS
  SELECT clidc.line_item_key
    FROM cont_li_dist_company clidc
   WHERE clidc.transaction_key = cp_transaction_key
     AND clidc.dist_id = cp_dist_id
     AND clidc.vendor_id = cp_vendor_id
     AND clidc.customer_id = cp_customer_id;

  CURSOR c_ts(cp_transaction_key VARCHAR2, cp_contract_composition VARCHAR2) IS
    SELECT smcv.*
    FROM ifac_cargo_value smcv
   WHERE transaction_key = cp_transaction_key
     AND ecdp_revn_ifac_wrapper.GetIfacRecordLevel_I(smcv.profit_center_code, smcv.vendor_code,object_type) = ecdp_revn_ifac_wrapper.gconst_level_line_item
     AND alloc_no_max_ind = 'Y';


CURSOR c_sum_vend_level(
                cp_transaction_key    VARCHAR2
) IS
SELECT sum(qty1) as vend_qty1 ,sum(qty2) as vend_qty2 , sum(qty3) as vend_qty3, sum(qty4) as vend_qty4
FROM
(
    SELECT DISTINCT sum(clidc.qty1) as qty1, sum(clidc.qty2) as qty2, sum(clidc.qty3) as qty3, sum(clidc.qty4) as qty4
    FROM cont_li_dist_company clidc
    WHERE clidc.transaction_key = cp_transaction_key
    AND clidc.line_item_based_type != 'QTY'
    GROUP BY clidc.line_item_key
    UNION
    SELECT DISTINCT sum(clidc.qty1), sum(clidc.qty2), sum(clidc.qty3), sum(clidc.qty4)
    FROM cont_li_dist_company clidc
    WHERE clidc.transaction_key = cp_transaction_key
    AND clidc.line_item_based_type = 'QTY'
    GROUP BY clidc.line_item_key
);

CURSOR c_sum_pc_level(
                cp_transaction_key    VARCHAR2
) IS
SELECT sum(qty1) as pc_qty1 ,sum(qty2) as pc_qty2 , sum(qty3) as pc_qty3, sum(qty4) as pc_qty4
FROM (
    SELECT DISTINCT clid.qty1, clid.qty2, clid.qty3, clid.qty4
    FROM cont_line_item_dist clid
    WHERE clid.transaction_key = cp_transaction_key
    AND clid.line_item_based_type != 'QTY'
    UNION ALL
    SELECT DISTINCT clid.qty1, clid.qty2, clid.qty3, clid.qty4
    FROM cont_line_item_dist clid
    WHERE clid.transaction_key = cp_transaction_key
    AND clid.line_item_based_type = 'QTY'
);

CURSOR c_sum_tran_level(
                cp_transaction_key    VARCHAR2
) IS
SELECT sum(ct.net_qty1) as tran_qty1 ,sum(ct.net_qty2) as tran_qty2 , sum(ct.net_qty3) as tran_qty3,
sum(ct.net_qty4) as tran_qty4
FROM cont_transaction_qty ct
WHERE ct.transaction_key = cp_transaction_key;


  already_processed          EXCEPTION;
  no_uom                     EXCEPTION;
  incrct_ifac_data_vend_pc_level   EXCEPTION;
  incrct_ifac_data_tran_pc_level   EXCEPTION;
  no_vendor_dist_config_found      EXCEPTION;

  ib_found                   BOOLEAN := FALSE;
  ln_share                   NUMBER;
  lv2_zero_field_qty_ind     VARCHAR2(1);
  lv2_zero_company_qty_ind   VARCHAR2(1);
  ltab_uom_set               EcDp_Unit.t_uomtable := EcDp_Unit.t_uomtable();
  lrec_tran_qty              cont_transaction_qty%ROWTYPE := ec_cont_transaction_qty.row_by_pk(p_transaction_key);
  lrec_tran                  cont_transaction%ROWTYPE := ec_cont_transaction.row_by_pk(p_transaction_key);
  lrec_tt                    transaction_tmpl_version%ROWTYPE := ec_transaction_tmpl_version.row_by_pk(lrec_tran.trans_template_id, lrec_tran.daytime, '<=');
  lrec_doc                   cont_document%ROWTYPE := ec_cont_document.row_by_pk(lrec_tran.document_key);
  lrec_pre_tran_qty          cont_transaction_qty%ROWTYPE := ec_cont_transaction_qty.row_by_pk(lrec_tran.preceding_trans_key);
  lrec_ifac_cargo_value      ifac_cargo_value%ROWTYPE;
  ln_f_qty2_share            NUMBER;
  ln_f_qty3_share            NUMBER;
  ln_f_qty4_share            NUMBER;
  ln_fc_qty2_share           NUMBER;
  ln_fc_qty3_share           NUMBER;
  ln_fc_qty4_share           NUMBER;
  p_qty_pc_share             T_TABLE_REVN_DIST_INFO;
  ld_daytime                 DATE;
  lv2_contract_composition   VARCHAR2(4) := EcDp_Contract_Setup.GetContractComposition(p_contract_id,ec_cont_transaction.trans_template_id(p_transaction_key), p_daytime);  -- Get the contract composition of vendors and fields
  lv2_use_vendor_id          VARCHAR2(32);
  lv2_use_field_id           VARCHAR2(32);
  ltab_source_entry          t_table_number := t_table_number();
  ln_ifac_trans_count        NUMBER := 0;
  ln_field_count             NUMBER := 1;
  ln_abs_field_qty           number;

  lt_t_ifac                  t_table_ifac_cargo_value;
  lt_t_transactions          t_table_ifac_cargo_value;
  lt_t_profit_centre         t_table_ifac_cargo_value;
  lt_c_profit_centre         t_table_ifac_cargo_value;
  lt_t_vendors               t_table_ifac_cargo_value;
  lv2_use_price_object       VARCHAR2(32);
  lv2_use_price_concept_code VARCHAR2(32);
  lv2_use_product_id         VARCHAR2(32);
  lv2_source_entry_no        VARCHAR2(32);
  sum_qty1_tran_level        NUMBER := 0;
  sum_qty2_tran_level        NUMBER := 0;
  sum_qty3_tran_level        NUMBER := 0;
  sum_qty4_tran_level        NUMBER := 0;
  sum_qty1_pc_level          NUMBER := 0;
  sum_qty2_pc_level          NUMBER := 0;
  sum_qty3_pc_level          NUMBER := 0;
  sum_qty4_pc_level          NUMBER := 0;
  sum_qty1_vend_level        NUMBER := 0;
  sum_qty2_vend_level        NUMBER := 0;
  sum_qty3_vend_level        NUMBER := 0;
  sum_qty4_vend_level        NUMBER := 0;
  vendor_count               NUMBER := 0; --Store matched vendor count
BEGIN

     ltab_source_entry.delete;

     if lrec_tran_qty.transaction_key is null then
       return ib_found;
     end if;
     -- Find transaction level cargo record
     FOR rsTS IN c_ts(p_transaction_key, lv2_contract_composition) LOOP

        lrec_ifac_cargo_value := rsTS;

     END LOOP;

     --=========================================================================
     -- Detach previous cargo if cargo details have changed on the transaction
     --=========================================================================


     IF (lrec_ifac_cargo_value.contract_id IS NOT NULL) THEN

         IF (lrec_ifac_cargo_value.cargo_no <> p_cargo_no OR
             lrec_ifac_cargo_value.parcel_no <> p_parcel_no OR
             lrec_ifac_cargo_value.qty_type <> p_qty_type) THEN

            -- Unmark the cargo
            UPDATE ifac_cargo_value
               SET transaction_key = NULL,
                  trans_key_set_ind = 'N',
                  last_updated_by = 'SYSTEM'
            WHERE cargo_no = lrec_ifac_cargo_value.cargo_no
              AND parcel_no = lrec_ifac_cargo_value.parcel_no
              AND qty_type = lrec_ifac_cargo_value.qty_type
              AND alloc_no = lrec_ifac_cargo_value.alloc_no   -- DRO: Shouldn't all cargo records belonging to this transaction be detatched?
              AND profit_center_id = lrec_ifac_cargo_value.profit_center_id;

              -- Force the logic to search for new cargo
              lrec_tran_qty.net_qty1 := NULL;

         -- Update QTYs if new ALLOC_NO has arrived, old one will still have the TRANS_ID set
         ELSIF (lrec_ifac_cargo_value.cargo_no = p_cargo_no AND
                lrec_ifac_cargo_value.parcel_no = p_parcel_no AND
                lrec_ifac_cargo_value.qty_type = p_qty_type) THEN

              lrec_tran_qty.net_qty1 := NULL;
         END IF;

     END IF;
     -- ECPD-13138: Ensure updated QTY is picked up from stim by setting existing qty to Null.
     IF lrec_tran_qty.NET_QTY1 IS NOT NULL                        -- Qty has been copied from preceding transaction
        AND lrec_tran.reversal_ind = 'N'                          -- This is not a reversal but a normal transaction
        AND lrec_tran.preceding_trans_key IS NOT NULL             -- This is a transaction that has a preceding transaction
        AND lrec_ifac_cargo_value.contract_id IS NULL THEN    -- The cargo record has not been picked, the lrec is empty...

        -- Force the pickup of new qtys on this dependent transaction
        lrec_tran_qty.net_qty1 := NULL;

     END IF;

     --==================================
     -- Could not detach, hence returning
     --==================================
     IF lrec_tran_qty.NET_QTY1 IS NOT NULL AND lrec_ifac_cargo_value.transaction_key IS NOT NULL THEN
        RETURN true;
     END IF;

     -- Determine company to use when finding qtys
     IF lv2_contract_composition IN ('MVMF','MVSF') THEN
        lv2_use_vendor_id := ec_company.object_id_by_uk(GetFullCompanyFromContract(p_contract_id, lrec_tran.daytime), 'VENDOR'); -- Full Company Code is: <COUNTRY_CODE>_FULL
     ELSIF lv2_contract_composition IN ('SVMF','SVSF') THEN
        lv2_use_vendor_id := NULL;
     END IF;

     -- Determine field to use when finding qtys
     IF lv2_contract_composition IN ('SVSF','MVSF') THEN
        lv2_use_field_id := NULL;
     ELSIF lv2_contract_composition IN ('MVMF','SVMF') THEN
        lv2_use_field_id := ec_field.object_id_by_uk('SUM', 'FIELD');
     END IF;
      --========================================
      -- TRANS / LINE ITEM LEVEL
      --========================================

     IF lrec_tran.price_object_id IS NOT NULL
     THEN
         lv2_use_price_object := lrec_tran.price_object_id;
         lv2_use_product_id := ec_product_price.product_id(lv2_use_price_object);
         lv2_use_price_concept_code := ec_product_price.price_concept_code(lv2_use_price_object);
     END IF;




      -- Loop should only run one time per transasction.
      -- Query may return more than one record if there are no price objects on the transaction.
     lt_t_ifac := ecdp_revn_ifac_wrapper_cargo.GetIfacForLineItem(
                                                       p_contract_id
                                                      ,lrec_doc.customer_id
                                                      ,p_cargo_no
                                                      ,p_parcel_no
                                                      ,lrec_tran_qty.uom1_code
                                                      ,p_status_code
                                                      ,null
                                                      ,null
                                                      ,p_ifac_tt_conn_code
                                                      ,null
                                                      ,lv2_use_price_concept_code
                                                      ,lv2_use_price_object
                                                      ,lrec_tran.trans_template_id
                                                      ,p_qty_pc_share
                                                      );


      lt_t_transactions := ecdp_revn_ifac_wrapper_cargo.GetTransactionLevelIfacRecords(lt_t_ifac);


     -- Loop should only run one time per transasction.
     -- Query may return more than one record if there are no price objects on the transaction.
      IF lt_t_transactions.COUNT > 0 THEN
      FOR n_trans_idx IN lt_t_transactions.first .. lt_t_transactions.last LOOP
            ln_ifac_trans_count := ln_ifac_trans_count + 1;

            -- Get source entry number
            lv2_source_entry_no := nvl(lt_t_transactions(n_trans_idx).Source_Entry_No,0);

            -- If transaction level lv2_source_entry_no is null then it will take from PC level
            IF (lv2_source_entry_no = 0) THEN
                lt_t_profit_centre := ecdp_revn_ifac_wrapper_cargo.GetPCLevelIfacRecords(
                                                     lt_t_ifac,
                                                     lt_t_transactions(n_trans_idx),
                                                     null);
                 FOR rsValField IN lt_t_profit_centre.first .. lt_t_profit_centre.last LOOP
                       lv2_source_entry_no := nvl(lt_t_profit_centre(rsValField).Source_Entry_No,0);

                       -- If transaction level and PC level lv2_source_entry_no is null then it will take from vendor level
                          IF (lv2_source_entry_no = 0) THEN
                            lt_c_profit_centre := ecdp_revn_ifac_wrapper_cargo.GetVendorLevelIfacRecords(
                                                         lt_t_ifac,
                                                         lt_t_profit_centre(rsValField),
                                                         null);
                             FOR CurTotComp IN lt_c_profit_centre.first .. lt_c_profit_centre.last LOOP
                                   lv2_source_entry_no := lt_c_profit_centre(CurTotComp).Source_Entry_No;
                              END LOOP;
                         END IF;
                  END LOOP;
               END IF;


            IF ln_ifac_trans_count = 1 THEN -- only allowing one run per transaction.

              SetTransVAT(p_transaction_key,lt_t_transactions(n_trans_idx).Vat_Code,p_user);

              IF ib_found = FALSE THEN
                ecdp_transaction.resetlineitemshares(p_transaction_key);
              END IF;
              ib_found := TRUE;


              -- Set status code from interface if not set already (applies to manual created document and quantities from interface)
              IF lrec_doc.status_code IS NULL AND lt_t_transactions(n_trans_idx).doc_status IS NOT NULL THEN
                UPDATE cont_document SET
                   status_code = lt_t_transactions(n_trans_idx).doc_status
                 WHERE document_key = lrec_doc.document_key;
              END IF;


              -- copy figures to table
              EcDp_Unit.GenQtyUOMSet(ltab_uom_set, lt_t_transactions(n_trans_idx).Net_Qty1, lt_t_transactions(n_trans_idx).uom1_code
                                     ,lt_t_transactions(n_trans_idx).Net_Qty2, lt_t_transactions(n_trans_idx).uom2_code
                                     ,lt_t_transactions(n_trans_idx).Net_Qty3, lt_t_transactions(n_trans_idx).uom3_code
                                     ,lt_t_transactions(n_trans_idx).Net_Qty4, lt_t_transactions(n_trans_idx).uom4_code);

              -- pick correct figures for each starting with UOM1

              IF lrec_tran_qty.UOM1_CODE IS NULL THEN
                 -- must have at least one UOM
                 RAISE no_uom;
              END IF;

              IF (p_daytime IS NULL) THEN
                   ld_daytime := lt_t_transactions(n_trans_idx).Point_Of_Sale_Date;
              ELSE
                   ld_daytime := p_daytime;
              END IF;

              lrec_tran_qty.net_qty1 := EcDp_Revn_Unit.GetUOMSetQty(ltab_uom_set,lrec_tran_qty.UOM1_CODE, ld_daytime, lrec_tran.stream_item_id);

              IF lrec_tran_qty.UOM2_CODE IS NOT NULL THEN
                 lrec_tran_qty.net_qty2 := EcDp_Revn_Unit.GetUOMSetQty(ltab_uom_set,lrec_tran_qty.UOM2_CODE, ld_daytime, lrec_tran.stream_item_id);
              END IF;
              IF lrec_tran_qty.UOM3_CODE IS NOT NULL THEN
                 lrec_tran_qty.net_qty3 := EcDp_Revn_Unit.GetUOMSetQty(ltab_uom_set,lrec_tran_qty.UOM3_CODE, ld_daytime, lrec_tran.stream_item_id);
              END IF;
              IF lrec_tran_qty.UOM4_CODE IS NOT NULL THEN
                 lrec_tran_qty.net_qty4 := EcDp_Revn_Unit.GetUOMSetQty(ltab_uom_set,lrec_tran_qty.UOM4_CODE, ld_daytime, lrec_tran.stream_item_id);
              END IF;


              IF ecdp_transaction.IsReducedConfig(NULL, NULL, lrec_tran.trans_template_id, p_transaction_key, ld_daytime) THEN

                -- Reference interface price object on transaction
                SetTransPriceObject(p_transaction_key, GetTransPriceObject(lrec_tran.price_object_id, lt_t_transactions(n_trans_idx).Price_Object_Id, ld_daytime),p_user,lt_t_transactions(n_trans_idx).qty_type);
                ecdp_transaction.SetTransStreamItem(p_transaction_key,p_user,lt_t_transactions(n_trans_idx).source_node_id,lt_t_transactions(n_trans_idx).uom1_code);
                create_missing_qty_li_by_pel_i(p_transaction_key);

                -- Deleting records
                IF UPPER(lrec_tt.use_stream_items_ind) = 'N' THEN
                          DELETE FROM cont_line_item_dist WHERE transaction_key = lrec_tran.transaction_key;
                          DELETE FROM cont_li_dist_company WHERE transaction_key = lrec_tran.transaction_key;
                END IF;

                FOR c_l IN ecdp_transaction.gc_line_item(p_transaction_key) LOOP

                  IF UPPER(lrec_tt.use_stream_items_ind) = 'Y' THEN
                    ecdp_line_item.gen_dist_party_f_conf_field(c_l.line_item_key,NULL,p_user,lt_t_transactions(n_trans_idx).uom1_code);
                  ELSE IF UPPER(lrec_tt.use_stream_items_ind) = 'N' THEN



                          lt_t_profit_centre := ecdp_revn_ifac_wrapper_cargo.GetPCLevelIfacRecords(
                                                 lt_t_ifac,
                                                 lt_t_transactions(n_trans_idx),
                                                 null);

                          FOR n_pc_idx IN lt_t_profit_centre.first .. lt_t_profit_centre.last LOOP
                                ecdp_line_item.gen_dist_party_f_given(c_l.line_item_key,NULL,p_user,lt_t_transactions(n_trans_idx).uom1_code,lt_t_profit_centre(n_pc_idx).PROFIT_CENTER_ID,lt_t_profit_centre(n_pc_idx).POINT_OF_SALE_DATE);
                          END LOOP;

                       END IF;
                  END IF;
                END LOOP;

                -- Transaction has been updated - Fetch latest attributes
                lrec_tran := ec_cont_transaction.row_by_pk(p_transaction_key);

              END IF;

              UPDATE cont_transaction_qty
                 SET last_updated_by   = 'SYSTEM', -- avoid revision for this temporary update
                     net_grs_indicator = nvl(net_grs_indicator,
                                             ecdp_transaction.GetNetGrsIndicator(p_contract_id,
                                                                                 p_transaction_key)),
                     net_qty1          = lrec_tran_qty.net_qty1,
                     net_qty2          = lrec_tran_qty.net_qty2,
                     net_qty3          = lrec_tran_qty.net_qty3,
                     net_qty4          = lrec_tran_qty.net_qty4
               WHERE object_id = p_contract_id
                 AND transaction_key = p_transaction_key;

              IF lrec_tran.preceding_trans_key IS NOT NULL AND lrec_tran_qty.pre_net_qty1 IS NULL THEN

                 -- Updating the preceding quantity
                 UPDATE cont_transaction_qty
                    SET last_updated_by = 'SYSTEM', -- avoid revision for this temporary update
                        pre_net_qty1    = lrec_pre_tran_qty.net_qty1,
                        pre_net_qty2    = lrec_pre_tran_qty.net_qty2,
                        pre_net_qty3    = lrec_pre_tran_qty.net_qty3,
                        pre_net_qty4    = lrec_pre_tran_qty.net_qty4
                  WHERE object_id = p_contract_id
                    AND transaction_key = p_transaction_key;

              END IF;


              -- copy figures to table
              EcDp_Unit.GenQtyUOMSet(ltab_uom_set,
                                      lt_t_transactions(n_trans_idx).net_qty1, lt_t_transactions(n_trans_idx).uom1_code
                                     ,lt_t_transactions(n_trans_idx).net_qty2, lt_t_transactions(n_trans_idx).uom2_code
                                     ,lt_t_transactions(n_trans_idx).net_qty3, lt_t_transactions(n_trans_idx).uom3_code
                                     ,lt_t_transactions(n_trans_idx).net_qty4, lt_t_transactions(n_trans_idx).uom4_code);

              -- copy over any additional interface data
              UPDATE cont_transaction t
                 SET loading_date_completed    = lt_t_transactions(n_trans_idx).loading_date
                    ,t.loading_date_commenced  = lt_t_transactions(n_trans_idx).loading_comm_date
                    ,t.transaction_date        = lt_t_transactions(n_trans_idx).Point_Of_Sale_Date
                    ,t.delivery_date_completed = lt_t_transactions(n_trans_idx).delivery_date
                    ,t.delivery_date_commenced = lt_t_transactions(n_trans_idx).delivery_comm_date
                    ,t.bl_date                 = lt_t_transactions(n_trans_idx).bl_date
                    ,t.price_date              = lt_t_transactions(n_trans_idx).price_date
                    ,t.discharge_port_id       = lt_t_transactions(n_trans_idx).discharge_port_id
                    ,t.loading_port_id         = lt_t_transactions(n_trans_idx).loading_port_id
                    ,t.sales_order             = nvl(lt_t_transactions(n_trans_idx).product_sales_order_code, t.sales_order)
                    ,t.carrier_id              = lt_t_transactions(n_trans_idx).carrier_id
                    ,t.consignor               = ec_company_version.name(lt_t_transactions(n_trans_idx).Consignor_Id, ld_daytime, '<=')
                    ,t.consignee               = ec_company_version.name(lt_t_transactions(n_trans_idx).Consignee_Id, ld_daytime, '<=')
                    ,t.last_updated_by         = p_user
               WHERE object_id = p_contract_id
                 AND transaction_key = p_transaction_key;

              -- Insert into temporary table for update after loop
              IF SourceEntryNoExists(lt_t_transactions(n_trans_idx).Source_Entry_No, ltab_source_entry) = 'N' THEN
                ltab_source_entry.extend;
                ltab_source_entry(ltab_source_entry.last) := lt_t_transactions(n_trans_idx).Source_Entry_No;

              END IF;


              --========================================
              -- FIELD LEVEL
              --========================================

              lv2_zero_field_qty_ind := 'Y';

              ln_abs_field_qty := 0; -- Reset

              -- Check the qty records to see if all fields have zero quantity
              ln_abs_field_qty := ln_abs_field_qty + abs(ec_ifac_sales_qty.qty1(lv2_source_entry_no));
              IF NVL(ec_ifac_cargo_value.net_qty1(lv2_source_entry_no),0) != 0 THEN

      lv2_zero_field_qty_ind := 'N';

              END IF;

              --Get the number of fields to distribute to to be used when creating
              --the 'artificial' split shares when all quantites are zero
              SELECT COUNT(d.line_item_key)
                INTO ln_field_count
                FROM cont_line_item_dist d
               WHERE d.transaction_key = p_transaction_key
                 AND d.line_item_based_type = 'QTY';

              --make sure we don't divide by 0
              IF ln_field_count = 0 THEN
                 ln_field_count := 1;
              END IF;

              -- First all line items - cont_line_item_dist
              FOR CurCFields IN c_field_si(lrec_tran.transaction_key) LOOP


                -- Determine company to use when finding qtys
                IF lv2_contract_composition IN ('MVMF','MVSF') THEN
                  lv2_use_vendor_id := ec_company.object_id_by_uk(GetFullCompanyFromContract(p_contract_id, ld_daytime), 'VENDOR'); -- Full Company Code is: <COUNTRY_CODE>_FULL
                ELSIF lv2_contract_composition IN ('SVMF','SVSF') THEN
                  lv2_use_vendor_id := NULL;
                END IF;

                -- Determine field to use when finding qtys.
                lv2_use_field_id := CurCFields.Dist_Id;

                lt_t_profit_centre := ecdp_revn_ifac_wrapper_cargo.GetPCLevelIfacRecords(
                                                 lt_t_ifac,
                                                 lt_t_transactions(n_trans_idx),
                                                 lv2_use_field_id);

                IF (lt_t_profit_centre IS NOT NULL) AND (lt_t_profit_centre.count > 0) THEN
                   FOR n_pc_idx IN lt_t_profit_centre.first .. lt_t_profit_centre.last LOOP
                        ln_share := CASE
                                      --total transaction qty is 0 and all fields are 0:
                                      --Use field dist from Transaction Distribution Setup
                                      WHEN nvl(lrec_tran_qty.net_qty1,0) = 0 and lv2_zero_field_qty_ind = 'Y'
                                        THEN nvl(GetFieldShare(lrec_tran.trans_template_id, lrec_tran.daytime, lv2_use_field_id),0)
                                      --total transaction qty is 0 and one or more fields are non-zero and this field is 0:
                                      WHEN nvl(lrec_tran_qty.net_qty1,0) = 0 and lv2_zero_field_qty_ind = 'N' AND nvl(lt_t_profit_centre(n_pc_idx).Net_Qty1,0) = 0
                                        THEN 0
                                      --total transaction qty is 0 and one or more fields are non-zero and this field is non-zero:
                                      WHEN nvl(lrec_tran_qty.net_qty1,0) = 0 and lv2_zero_field_qty_ind = 'N' AND nvl(lt_t_profit_centre(n_pc_idx).Net_Qty1,0) <> 0
                                        THEN SIGN(nvl(lt_t_profit_centre(n_pc_idx).Net_Qty1,0))*(1+2*(nvl(lt_t_profit_centre(n_pc_idx).Net_Qty1,0)/ln_abs_field_qty))
                                      -- total transaction is not 0 and this field is 0:
                                      WHEN nvl(lrec_tran_qty.net_qty1,0) <> 0 AND nvl(lt_t_profit_centre(n_pc_idx).Net_Qty1,0) = 0
                                        THEN 0
                                      -- total transaction is not 0 and this field is not 0:
                                      WHEN nvl(lrec_tran_qty.net_qty1,0) <> 0 AND nvl(lt_t_profit_centre(n_pc_idx).Net_Qty1,0) <> 0
                                        THEN (nvl(lt_t_profit_centre(n_pc_idx).Net_Qty1,0) / lrec_tran_qty.net_qty1)
                                      ELSE
                                        (nvl(lt_t_profit_centre(n_pc_idx).Net_Qty1,0) / lrec_tran_qty.net_qty1)
                                      END;

                        FOR k IN c_field_li(lrec_tran.transaction_key,CurCFields.Dist_Id) LOOP

                          -- Update qty line items
                          UPDATE cont_line_item_dist
                             SET split_value = lt_t_profit_centre(n_pc_idx).Net_Qty1,
                                 split_share = CASE WHEN lv2_zero_field_qty_ind = 'N' THEN ln_share
                                                    WHEN lv2_zero_field_qty_ind = 'Y' THEN 1/ln_field_count
                                                    ELSE split_share END,
                                 qty1        = lt_t_profit_centre(n_pc_idx).Net_Qty1,
                                 qty2        = lt_t_profit_centre(n_pc_idx).Net_Qty2,
                                 qty3        = lt_t_profit_centre(n_pc_idx).Net_Qty3,
                                 qty4        = lt_t_profit_centre(n_pc_idx).Net_Qty4
                           WHERE line_item_key = k.line_item_key
                             AND dist_id = lv2_use_field_id;


                             -- Share is determined from table cont_line_item_dist as qty1-qty4 might have individual shares (ECPD-11824)
                             ln_f_qty2_share := ecdp_line_item.getFieldqty2share(k.line_item_key,CurCFields.Stream_Item_Id,lv2_use_field_id);--CurCFields.Dist_Id);
                             ln_f_qty3_share := ecdp_line_item.getFieldQty3share(k.line_item_key,CurCFields.Stream_Item_Id,lv2_use_field_id);--CurCFields.Dist_Id);
                             ln_f_qty4_share := ecdp_line_item.getFieldQty4share(k.line_item_key,CurCFields.Stream_Item_Id,lv2_use_field_id);--CurCFields.Dist_Id);

                             -- Applying individual shares
                             UPDATE cont_line_item_dist
                                SET split_share_qty2 = ln_f_qty2_share,
                                    split_share_qty3 = ln_f_qty3_share,
                                    split_share_qty4 = ln_f_qty4_share
                              WHERE line_item_key = k.line_item_key
                                AND dist_id = lv2_use_field_id;


                         END LOOP;

                        -- Update non qty line items
                        UPDATE cont_line_item_dist lid
                           SET lid.split_share = CASE WHEN lv2_zero_field_qty_ind = 'N' THEN ln_share
                                                 WHEN lv2_zero_field_qty_ind = 'Y' THEN 1/ln_field_count
                                                 ELSE split_share END,
                               lid.split_share_qty2 = decode(lv2_zero_field_qty_ind,'N',ln_f_qty2_share,lid.split_share_qty2),
                               lid.split_share_qty3 = decode(lv2_zero_field_qty_ind,'N',ln_f_qty3_share,lid.split_share_qty3),
                               lid.split_share_qty4 = decode(lv2_zero_field_qty_ind,'N',ln_f_qty4_share,lid.split_share_qty4)
                         WHERE lid.transaction_key = lrec_tran.transaction_key
                           AND lid.line_item_based_type != 'QTY'
                           AND lid.dist_id = lv2_use_field_id;

                          -- Kick off so value will get new distribution
                          UPDATE CONT_LINE_ITEM
                          SET LAST_UPDATED_DATE = Ecdp_Timestamp.getCurrentSysdate
                          WHERE transaction_key = lrec_tran.transaction_key
                          AND line_item_based_type != 'QTY';

                      -- Insert into temporary table for update after loop
                      IF SourceEntryNoExists(lt_t_profit_centre(n_pc_idx).Source_Entry_No, ltab_source_entry) = 'N' THEN
                        ltab_source_entry.extend;
                        ltab_source_entry(ltab_source_entry.last) := lt_t_profit_centre(n_pc_idx).Source_Entry_No;
                      END IF;


                      --========================================
                      -- COMPANY LEVEL
                      --========================================

                      lv2_zero_company_qty_ind := 'Y';

                      -- Check the qty records to see if all companies (vendors) have zero quantity

                           IF NVL(ec_ifac_cargo_value.net_qty1(lv2_source_entry_no),0) != 0 THEN

                               lv2_zero_company_qty_ind := 'N';

                            END IF;
                      -- First all line items
                      FOR CurFieldsCompany IN c_field_company_si(lrec_tran.transaction_key,
                                                                  CurCFields.line_item_key,
                                                                  lv2_use_field_id) LOOP

                        lt_t_vendors := ecdp_revn_ifac_wrapper_cargo.GetVendorLevelIfacRecords(lt_t_ifac,lt_t_profit_centre(n_pc_idx), CurFieldsCompany.vendor_id);
                        vendor_count := vendor_count + 1; --vendor_count stores number of vendor found/matched
                        IF (lt_t_vendors IS NOT NULL) AND (lt_t_vendors.count > 0) THEN
                          FOR n_vendor_idx IN lt_t_vendors.first .. lt_t_vendors.last LOOP
                                ln_share := CASE WHEN lt_t_vendors(n_vendor_idx).Net_Qty1 = 0 AND lt_t_profit_centre(n_pc_idx).Net_Qty1 = 0 THEN 0
                                                 WHEN lt_t_profit_centre(n_pc_idx).Net_Qty1 = 0 THEN 0
                                                 ELSE (lt_t_vendors(n_vendor_idx).Net_Qty1 / lt_t_profit_centre(n_pc_idx).Net_Qty1)
                                                 END;

                                 -- Update qty line items
                                   UPDATE cont_li_dist_company
                                   SET split_value = lt_t_vendors(n_vendor_idx).Net_Qty1,
                                       vendor_share = CASE WHEN lv2_zero_company_qty_ind = 'Y' and lv2_contract_composition IN ('SVMF','SVSF') THEN 1
                                             WHEN lv2_zero_company_qty_ind = 'Y' and lv2_contract_composition IN ('MVMF','MVSF') THEN NVL(GetCompanyShare(lrec_tran.trans_template_id, lrec_tran.daytime, lv2_use_field_id, ec_company.company_id(lt_t_vendors(n_vendor_idx).Vendor_Id)), EC_CONTRACT_PARTY_SHARE.party_share(p_contract_id ,lt_t_vendors(n_vendor_idx).Vendor_Id , 'VENDOR' , lrec_tran.daytime, '<=')/100)
                                                           ELSE ln_share END,
                                       split_share = CASE lv2_zero_company_qty_ind WHEN 'N' THEN (ln_share * customer_share) ELSE split_share END,
                                       qty1 = lt_t_vendors(n_vendor_idx).Net_Qty1,
                                       qty2 = lt_t_vendors(n_vendor_idx).Net_Qty2,
                                       qty3 = lt_t_vendors(n_vendor_idx).Net_Qty3,
                                       qty4 = lt_t_vendors(n_vendor_idx).Net_Qty4
                                   WHERE transaction_key = lrec_tran.transaction_key
                                   AND line_item_based_type = 'QTY'
                                   AND dist_id = lv2_use_field_id
                                   AND vendor_id = lt_t_vendors(n_vendor_idx).Vendor_Id;

                                   FOR c_fc IN c_field_company_li(lrec_tran.transaction_key,
                                                           CurFieldsCompany.dist_id,
                                                           lt_t_vendors(n_vendor_idx).Vendor_Id,
                                                           CurFieldsCompany.Customer_Id) LOOP

                                      -- Share is determined from table cont_line_item_dist as qty1-qty4 might have individual shares (ECPD-11824)
                                     ln_fc_qty2_share := ecdp_line_item.getFieldCompanyQty2Share(c_fc.line_item_key,
                                                                                             CurFieldsCompany.Stream_Item_Id,
                                                                                             CurFieldsCompany.dist_id,
                                                                                             lt_t_vendors(n_vendor_idx).Vendor_Id,
                                                                                             CurFieldsCompany.Customer_Id);

                                     ln_fc_qty3_share := ecdp_line_item.getFieldCompanyQty3Share(c_fc.line_item_key,
                                                                                             CurFieldsCompany.Stream_Item_Id,
                                                                                             CurFieldsCompany.dist_id,
                                                                                             lt_t_vendors(n_vendor_idx).Vendor_Id,
                                                                                             CurFieldsCompany.Customer_Id);

                                     ln_fc_qty4_share := ecdp_line_item.getFieldCompanyQty4Share(c_fc.line_item_key,
                                                                                             CurFieldsCompany.Stream_Item_Id,
                                                                                             CurFieldsCompany.dist_id,
                                                                                             lt_t_vendors(n_vendor_idx).Vendor_Id,
                                                                                             CurFieldsCompany.Customer_Id);


                                      UPDATE cont_li_dist_company c
                                         SET c.vendor_share_qty2 = ln_fc_qty2_share,
                                             c.vendor_share_qty3 = ln_fc_qty3_share,
                                             c.vendor_share_qty4 = ln_fc_qty4_share
                                       WHERE c.line_item_key = c_fc.line_item_key
                                         AND c.dist_id = lv2_use_field_id
                                         AND c.vendor_id = lt_t_vendors(n_vendor_idx).Vendor_Id
                                         AND c.customer_id = CurFieldsCompany.Customer_Id;
                                   END LOOP;

                                  -- Update non qty line items
                                  UPDATE cont_li_dist_company
                                     SET vendor_share = CASE lv2_zero_company_qty_ind WHEN 'N' THEN ln_share ELSE vendor_share END,
                                         split_share = CASE lv2_zero_company_qty_ind WHEN 'N' THEN (ln_share * customer_share) ELSE split_share END
                                   WHERE transaction_key = lrec_tran.transaction_key
                                     AND line_item_based_type != 'QTY'
                                     AND dist_id = lv2_use_field_id
                                     AND vendor_id = lt_t_vendors(n_vendor_idx).Vendor_Id;

                                  -- Insert into temporary table for update after loop
                                  IF SourceEntryNoExists(lt_t_vendors(n_vendor_idx).Source_Entry_No, ltab_source_entry) = 'N'
                                     OR SourceEntryNoExists(lt_t_profit_centre(n_pc_idx).Source_Entry_No, ltab_source_entry) = 'N' THEN
                                    ltab_source_entry.extend;
                                    ltab_source_entry(ltab_source_entry.last) := NVL(lt_t_vendors(n_vendor_idx).Source_Entry_No, lt_t_profit_centre(n_pc_idx).Source_Entry_No);
                                  END IF;
                              END LOOP; -- Cargo Field / Company
                         ELSE
                           RAISE no_vendor_dist_config_found;
                         END IF;
                         IF vendor_count = 0 THEN --When interfacing Period document using vendor which is not added in the Transaction distribution throw an exception
                            RAISE no_vendor_dist_config_found;
                         END IF;

                     END LOOP; -- COMPANY
                END LOOP; -- Cargo Field

               ELSE
                   ecdp_line_item.del_dist_by_pc_i(CurCFields.line_item_key, lv2_use_field_id);
               END IF;
              END LOOP; -- FIELD


          END IF; -- ifac trans count


      END LOOP; -- Trans / Line Item Level
      END IF;

      --=====================================
      -- checks if the values at profit centre and transaction and vendor level match
      -- =====================================
      FOR c_vend IN c_sum_vend_level(p_transaction_key) LOOP
      sum_qty1_vend_level := c_vend.vend_qty1;
      sum_qty2_vend_level := c_vend.vend_qty2;
      sum_qty3_vend_level := c_vend.vend_qty3;
      sum_qty4_vend_level := c_vend.vend_qty4;
      END LOOP;

      FOR c_pc IN c_sum_pc_level(p_transaction_key) LOOP
      sum_qty1_pc_level   := c_pc.pc_qty1;
      sum_qty2_pc_level   := c_pc.pc_qty2;
      sum_qty3_pc_level   := c_pc.pc_qty3;
      sum_qty4_pc_level   := c_pc.pc_qty4;
      END LOOP;

      FOR c_tran IN c_sum_tran_level(p_transaction_key) LOOP
      sum_qty1_tran_level := c_tran.tran_qty1;
      sum_qty2_tran_level := c_tran.tran_qty2;
      sum_qty3_tran_level := c_tran.tran_qty3;
      sum_qty4_tran_level := c_tran.tran_qty4;
      END LOOP;


     IF((sum_qty1_vend_level != sum_qty1_pc_level) OR (sum_qty2_vend_level != sum_qty2_pc_level) OR (sum_qty3_vend_level != sum_qty3_pc_level) OR (sum_qty4_vend_level != sum_qty4_pc_level))
                        THEN
                        RAISE incrct_ifac_data_vend_pc_level;
                        END IF;

     IF((sum_qty1_tran_level != sum_qty1_pc_level) OR (sum_qty2_tran_level != sum_qty2_pc_level) OR (sum_qty3_tran_level != sum_qty3_pc_level) OR (sum_qty4_tran_level != sum_qty4_pc_level))
                        THEN
                        RAISE incrct_ifac_data_tran_pc_level;
                        END IF;


      --=====================================
      -- Update values picked up in interface
      --=====================================
      IF ltab_source_entry IS NOT NULL AND ltab_source_entry.count > 0 THEN
          FOR i IN ltab_source_entry.FIRST..ltab_source_entry.LAST LOOP

              -- mark use
              UPDATE ifac_cargo_value smcv
                 SET contract_id = p_contract_id,
                     transaction_key = p_transaction_key,
                     trans_key_set_ind = 'Y',
                     document_key = ec_cont_transaction.document_key(p_transaction_key),
                     last_updated_by = 'SYSTEM'
              WHERE smcv.source_entry_no = ltab_source_entry(i)
              AND trans_key_set_ind = 'N';

          END LOOP;
      END IF;

   RETURN ib_found;

EXCEPTION
     WHEN already_processed THEN
              -- Do not raise application error, normal exit of procedure
              RETURN ib_found;
     WHEN no_uom THEN
              Raise_Application_Error(-20000,'No UOM supplied for UOM1 for contract: ' || Nvl(ec_contract.object_code(p_contract_id),' ') || ' - ' || Nvl(ec_contract_version.name(p_contract_id, ld_daytime, '<='),' ') );

     WHEN no_vendor_dist_config_found THEN
              Raise_Application_Error(-20000,'Vendor configuration not found in the transaction distribution setup');

     WHEN incrct_ifac_data_vend_pc_level THEN
              Raise_Application_Error(-20000,'The vendor level qty does not add up to match the profit center level qty');

     WHEN incrct_ifac_data_tran_pc_level THEN
              Raise_Application_Error(-20000,'The profit center level qty does not add up to match the transaction level qty');

END;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  GenTranQtyFromMthVO
-- Description    :
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION GenTransQtyFromMthVO_P(p_object_id      VARCHAR2,
                             p_transaction_id VARCHAR2,
                             p_daytime        DATE,
                             p_status         VARCHAR2, -- FINAL or ACCRUAL
                             p_user           VARCHAR2)
RETURN BOOLEAN
--<EC-DOC>
IS

CURSOR c_smv(pc_si_id  objects.object_id%TYPE, pc_status VARCHAR2) IS
SELECT *
FROM stim_mth_value
WHERE object_id = pc_si_id
  AND daytime = Trunc(p_daytime,'MM')
  AND ( status = 'FINAL' OR status = pc_status OR status IS NULL) -- a final doc can take FINAL doc or NULL, an ACCRUAL doc NULL, ACCRUAL or FINAL
  AND nvl(calc_method,'NA') != 'SP'; -- Using NA because Calc method on object will never be OW/SP

CURSOR c_li_dist(cp_transaction_key VARCHAR2, cp_daytime DATE) IS
 SELECT clid.stream_item_id
   FROM cont_line_item_dist clid, stim_mth_value smv
  WHERE clid.stream_item_id = smv.object_id
    AND clid.transaction_key = cp_transaction_key
    AND smv.daytime = Trunc(cp_daytime, 'MM')
    AND nvl(smv.calc_method,'NA') != 'SP';

CURSOR c_li_dist_comp(cp_transaction_key VARCHAR2, cp_daytime DATE) IS
 SELECT clic.company_stream_item_id
   FROM cont_li_dist_company clic, stim_mth_value smv
  WHERE clic.company_stream_item_id = smv.object_id
    AND clic.transaction_key = cp_transaction_key
    AND smv.daytime = Trunc(cp_daytime, 'MM')
    AND nvl(smv.calc_method,'NA') != 'SP';

ltab_uom_set EcDp_Unit.t_uomtable := EcDp_Unit.t_uomtable();

lrec_tran_qty cont_transaction_qty%ROWTYPE := ec_cont_transaction_qty.row_by_pk(p_transaction_id);
lrec_tran cont_transaction%ROWTYPE := ec_cont_transaction.row_by_pk(p_transaction_id);
lrec_pre_tran_qty cont_transaction_qty%ROWTYPE := ec_cont_transaction_qty.row_by_pk(lrec_tran.preceding_trans_key);

ib_found BOOLEAN := FALSE;

already_processed EXCEPTION;
no_uom EXCEPTION;

BEGIN

     IF lrec_tran_qty.NET_QTY1 IS NOT NULL THEN

        RAISE already_processed;

     END IF;

   IF (p_daytime IS NOT NULL and lrec_tran_qty.transaction_key is not null) THEN
        ----------------------------------------------------------------------------
        -- Check for Monthly STIM_MTH_VALUE figures - only possible if a date is supplied


        FOR SMVCur IN c_smv(lrec_tran.stream_item_id, p_status) LOOP

            ib_found := TRUE;


            EcDp_Unit.GenQtyUOMSet(ltab_uom_set
                                   ,SMVCur.net_volume_value, SMVCur.volume_uom_code
                                   ,SMVCur.net_mass_value, SMVCur.mass_uom_code
                                   ,SMVCur.net_energy_value, SMVCur.energy_uom_code
                                   ,SMVCur.net_extra1_value, SMVCur.extra1_uom_code
                                   ,SMVCur.net_extra2_value, SMVCur.extra2_uom_code
                                   ,SMVCur.net_extra3_value, SMVCur.extra3_uom_code
                                   );

          IF lrec_tran_qty.UOM1_CODE IS NULL THEN

             -- must have at least one UOM
             RAISE no_uom;

          END IF;


          lrec_tran_qty.net_qty1 := EcDp_Revn_Unit.GetUOMSetQty(ltab_uom_set,lrec_tran_qty.UOM1_CODE,p_daytime, SMVCur.object_id);

          IF lrec_tran_qty.UOM2_CODE IS NOT NULL THEN
             lrec_tran_qty.net_qty2 := EcDp_Revn_Unit.GetUOMSetQty(ltab_uom_set,lrec_tran_qty.UOM2_CODE,p_daytime, SMVCur.Object_Id);
          END IF;

          IF lrec_tran_qty.UOM3_CODE IS NOT NULL THEN
             lrec_tran_qty.net_qty3 := EcDp_Revn_Unit.GetUOMSetQty(ltab_uom_set,lrec_tran_qty.UOM3_CODE,p_daytime, SMVCur.Object_Id);
          END IF;

          IF lrec_tran_qty.UOM4_CODE IS NOT NULL THEN
             lrec_tran_qty.net_qty4 := EcDp_Revn_Unit.GetUOMSetQty(ltab_uom_set,lrec_tran_qty.UOM4_CODE,p_daytime, SMVCur.Object_Id);
          END IF;
                EcDp_VOQty.StoreVOQty(p_object_id,
                                      p_transaction_id,
                                      lrec_tran.stream_item_id,
                                      ec_cont_transaction.transaction_date(p_transaction_id),
                                      p_user);
            UPDATE stim_mth_value smv
               SET smv.transaction_key = p_transaction_id,
                   net_volume_value    = decode(volume_uom_code,null,null,0),
                   net_mass_value      = decode(mass_uom_code,null,null,0),
                   net_energy_value    = decode(energy_uom_code,null,null,0),
                   calc_method         = 'SP', -- use this to indicate that value will be updated from SP
                   last_updated_by     = p_user
             WHERE object_id = lrec_tran.stream_item_id
               AND daytime = Trunc(p_daytime, 'MM');


          -- update distribution stream items to be null and contain SP.
          FOR cont_line_item_streams in c_li_dist(p_transaction_id, p_daytime) LOOP

              EcDp_VOQty.StoreVOQty(p_object_id,
                                    p_transaction_id,
                                    cont_line_item_streams.stream_item_id,
                                    ec_cont_transaction.transaction_date(p_transaction_id),
                                    p_user);

              UPDATE stim_mth_value smv
                 SET smv.transaction_key = p_transaction_id,
                     net_volume_value    = decode(volume_uom_code,null,null,0),
                     net_mass_value      = decode(mass_uom_code,null,null,0),
                     net_energy_value    = decode(energy_uom_code,null,null,0),
                     calc_method         = 'SP', -- use this to indicate that value will be updated from SP
                     last_updated_by     = p_user
               WHERE object_id = cont_line_item_streams.stream_item_id
                 AND daytime = Trunc(p_daytime, 'MM');

          END LOOP;

          -- update company distribution stream items to be null and contain SP.
          FOR cont_li_comp IN c_li_dist_comp(p_transaction_id, p_daytime) LOOP

              EcDp_VOQty.StoreVOQty(p_object_id,
                                    p_transaction_id,
                                    cont_li_comp.company_stream_item_id,
                                    ec_cont_transaction.transaction_date(p_transaction_id),
                                    p_user);

              UPDATE stim_mth_value smv
                 SET smv.transaction_key = p_transaction_id,
                     net_volume_value    = decode(volume_uom_code,null,null,0),
                     net_mass_value      = decode(mass_uom_code,null,null,0),
                     net_energy_value    = decode(energy_uom_code,null,null,0),
                     calc_method         = 'SP', -- use this to indicate that value will be updated from SP
                     last_updated_by     = p_user
               WHERE object_id = cont_li_comp.company_stream_item_id
                 AND daytime = Trunc(p_daytime, 'MM');

          END LOOP;


        END LOOP;

        IF ib_found THEN

            -- update transaction_qty with new numbers
            UPDATE cont_transaction_qty
            SET last_updated_by = 'SYSTEM' -- avoid revision for this temporary update
                ,net_qty1 = lrec_tran_qty.net_qty1
                ,net_qty2 = lrec_tran_qty.net_qty2
                ,net_qty3 = lrec_tran_qty.net_qty3
                ,net_qty4 = lrec_tran_qty.net_qty4
            WHERE object_id = p_object_id
              AND transaction_key = p_transaction_id;


          IF lrec_tran.preceding_trans_key IS NOT NULL AND lrec_tran_qty.pre_net_qty1 IS NULL THEN

             -- Updating the preceding quantity
             UPDATE cont_transaction_qty
                SET last_updated_by = 'SYSTEM', -- avoid revision for this temporary update
                    pre_net_qty1    = lrec_pre_tran_qty.net_qty1,
                    pre_net_qty2    = lrec_pre_tran_qty.net_qty2,
                    pre_net_qty3    = lrec_pre_tran_qty.net_qty3,
                    pre_net_qty4    = lrec_pre_tran_qty.net_qty4
              WHERE object_id = p_object_id
                AND transaction_key = p_transaction_id;

          END IF;



       END IF;

   END IF; -- daytime is null

   RETURN ib_found;

EXCEPTION
     WHEN already_processed THEN
              -- Do not raise application error, normal exit of procedure
              RETURN ib_found;
     WHEN no_uom THEN
              Raise_Application_Error(-20000,'No UOM supplied for UOM1 for contract: ' || Nvl(ec_contract.object_code(p_object_id),' ') || ' - ' || Nvl(ec_contract_version.name(p_object_id, p_daytime, '<='),' ') );

END GenTransQtyFromMthVO_P;



------------------------+-----------------------------------+------------------------------------+---------------------------
-- (See header)
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GenTransQty_I(
                         p_object_id                        VARCHAR2
                        ,p_transaction_id                   VARCHAR2
                        ,p_user                             VARCHAR2
                        ,p_context                          IN OUT NOCOPY T_REVN_DOC_OP_CONTEXT
                        ,p_force_update                     BOOLEAN DEFAULT FALSE
)
RETURN BOOLEAN
IS

no_transaction_date EXCEPTION;

lrec_trans cont_transaction%ROWTYPE := ec_cont_transaction.row_by_pk(p_transaction_id);
lrec_tran_qty cont_transaction_qty%ROWTYPE := ec_cont_transaction_qty.row_by_pk(p_transaction_id);
lrec_doc cont_document%ROWTYPE;
lb_found BOOLEAN := false;

BEGIN

   lv2_skip_fetch_src_split := 'N';

   IF (lrec_tran_qty.net_qty1 IS NOT NULL AND p_force_update = FALSE) THEN
      RETURN FALSE;
   END IF;

   lrec_doc := ec_cont_document.row_by_pk(lrec_trans.document_key);

   -- Only non detail documents should be run...
   IF (lrec_doc.parent_document_key IS NULL) THEN

      IF (lrec_trans.transaction_scope = 'CARGO_BASED') THEN
         lb_found := fill_qty_from_ifac_cargo_p(
               p_transaction_id,
               p_user,
               p_context,
               p_force_update);

         lrec_trans := ec_cont_transaction.row_by_pk(p_transaction_id);

         IF (lrec_trans.transaction_date IS NULL) THEN
            RAISE no_transaction_date;
         END IF;

         IF lb_found = FALSE THEN
            lb_found := GenTransQtyFromMthVO_P(p_object_id, p_transaction_id , Trunc(lrec_trans.transaction_date,'MM'),ec_cont_document.status_code(lrec_trans.document_key),p_user);
         END IF;

      ELSIF (lrec_trans.transaction_scope = 'PERIOD_BASED') THEN
         -- Second attempt is to look in ifac tables for quantities
         IF lb_found = FALSE THEN
            lb_found := fill_qty_from_ifac_period_p(
               p_transaction_id,
               p_user,
               p_context,
               p_force_update);
         END IF;

         lrec_trans := ec_cont_transaction.row_by_pk(p_transaction_id);

         IF (ec_cont_transaction.transaction_date(p_transaction_id) IS NULL) THEN
            RAISE no_transaction_date;
         END IF;

         -- Third attempt is to look in VO/Quantity for quantities
         IF lb_found = FALSE THEN
            IF (lrec_trans.supply_from_date = Trunc(lrec_trans.supply_from_date,'MM') AND lrec_trans.supply_to_date = Last_Day(lrec_trans.supply_from_date)) THEN
               lb_found := GenTransQtyFromMthVO_P(p_object_id, p_transaction_id , Trunc(lrec_trans.supply_from_date,'MM'), ec_cont_document.status_code(lrec_trans.document_key), p_user);
            ELSE
               lb_found := GenTransQtyFromDayVO_P(p_object_id, p_transaction_id, lrec_trans.supply_from_date, lrec_trans.supply_to_date, ec_cont_document.status_code(lrec_trans.document_key));
            END IF;
         END IF;
      END IF;

      -- Update source split if it is in use
      -- Note: We don't want this to be done if shares are already found at dist level
      IF (lrec_trans.split_method = 'SOURCE_SPLIT') THEN

          IF (lrec_trans.transaction_date IS NOT NULL AND nvl(lv2_skip_fetch_src_split,'N') = 'N') THEN

              Ecdp_Transaction.UpdTransSourceSplitShare(lrec_trans.transaction_key,
                                                        lrec_tran_qty.net_qty1, lrec_tran_qty.uom1_code, lrec_trans.transaction_date);
          END IF;

      END IF;

   END IF;

   RETURN lb_found;

EXCEPTION

     WHEN no_transaction_date THEN
              Raise_Application_Error(-20000,'Can not assign quantities since Point Of Sale date is not supplied. Please supply date and rerun.' );

END GenTransQty_I;

FUNCTION GetFullCompanyFromContract(
  p_contract_id VARCHAR2,
  p_daytime DATE)
RETURN VARCHAR2
IS
  lv2_full_comp_code VARCHAR2(32) := NULL;
BEGIN

  -- Returns [Country_code]_FULL for a given contract
  lv2_full_comp_code := ec_geographical_area.object_code(ec_company_version.country_id(ec_contract_version.company_id(p_contract_id, p_daytime, '<='), p_daytime, '<=')) || '_FULL';

  RETURN lv2_full_comp_code;

END GetFullCompanyFromContract;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : SetTransVAT
-- Description    : Apply transaction distribution
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
PROCEDURE SetTransVAT(p_transaction_key varchar2,p_vat_code varchar2 default null,p_user varchar2)

IS

lrec_ct      cont_transaction%ROWTYPE;
lv2_vat_id   VARCHAR2(32);

BEGIN

   lrec_ct := ec_cont_transaction.row_by_pk(p_transaction_key);
   lv2_vat_id := ec_vat_code.object_id_by_uk(p_vat_code);

   IF lv2_vat_id is not null THEN
      update cont_transaction set vat_code = p_vat_code,
          vat_rate = ec_vat_code_version.rate(lv2_vat_id, cont_transaction.daytime, '<='),
          vat_description = ec_vat_code_version.comments(lv2_vat_id, cont_transaction.daytime, '<='),
          vat_legal_text = ec_vat_code_version.legal_text(lv2_vat_id, cont_transaction.daytime, '<=')
          where transaction_key = p_transaction_key;

      -- Also update all quantity line items for this transaction.
      update cont_line_item
         set vat_code = p_vat_code,
             vat_rate = ec_vat_code_version.rate(lv2_vat_id, lrec_ct.daytime, '<=')
       where transaction_key = p_transaction_key
         and line_item_based_type = 'QTY';
    END IF;

END SetTransVAT;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    PROCEDURE create_missing_qty_li_by_pel_i(
        p_transaction_key                  VARCHAR2
       )
    IS
        lv2_li_key VARCHAR2(32);
        lrec_ct cont_transaction%ROWTYPE;

        CURSOR c_price_elem_rec (cp_price_concept_code VARCHAR2, cp_transaction_key VARCHAR2) IS
            SELECT pce.price_element_code,
                   pce.line_item_type
              FROM price_concept_element pce
             WHERE pce.price_concept_code = cp_price_concept_code
               AND NOT EXISTS
               (
                   SELECT 'x' FROM cont_line_item cli
                    WHERE cli.transaction_key = cp_transaction_key
                      AND cli.price_concept_code = pce.price_concept_code
                      AND cli.price_element_code = pce.price_element_code
                      AND cli.line_item_based_type = 'QTY'
               )
             ORDER BY sort_order;
    BEGIN
        lrec_ct := ec_cont_transaction.row_by_pk(p_transaction_key);

        -- Generate Qty Line Items if not present on transaction
        FOR rsPE IN c_price_elem_rec(ec_product_price.price_concept_code(lrec_ct.price_object_id), p_transaction_key) LOOP
            lv2_li_key := EcDp_Line_Item.InsNewLineItem(lrec_ct.object_id,
                lrec_ct.daytime,
                lrec_ct.document_key,
                lrec_ct.transaction_key,
                NULL, -- Line Item Template - not applicable
                ecdp_context.getAppUser,
                NULL, -- p_line_item_id
                rsPE.Line_Item_Type, -- p_line_item_type
                'QTY', -- p_line_item_based_type
                NULL, -- p_pct_base_amount
                NULL, -- p_percentage_value
                NULL, -- p_unit_price
                NULL, -- p_unit_price_unit
                NULL, -- p_free_unit_qty
                NULL, -- p_pricing_value
                'Generated based on interfaced price object.' , -- p_description
                lrec_ct.price_object_id, --  p_price_object_id
                rsPE.Price_Element_Code, --  p_price_element_code
                NULL, -- p_customer_id
                p_creation_method => ecdp_revn_ft_constants.c_mtd_auto_gen,
                p_ifac_li_conn_code => NULL
        );
        END LOOP;
    END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GenTranQtyFromStaging
-- Description    : Apply transaction and distribution quantities
-- Preconditions  : All transactions for staging document should at this point be in place.
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
/*FUNCTION GenTranQtyFromStaging(p_contract_id     VARCHAR2,
                               p_transaction_key VARCHAR2,
                               p_start_date      DATE,
                               p_end_date        DATE,
                               p_status_code     VARCHAR2, -- FINAL or ACCRUAL
                               p_user            VARCHAR2,
                               p_force_update    BOOLEAN DEFAULT FALSE)
--</EC-DOC>
RETURN BOOLEAN
IS
  lrec_ct   cont_transaction%ROWTYPE         := ec_cont_transaction.row_by_pk(p_transaction_key);
  lrec_ctq  cont_transaction_qty%ROWTYPE     := ec_cont_transaction_qty.row_by_pk(p_transaction_key);
  lrec_ctqp cont_transaction_qty%ROWTYPE     := ec_cont_transaction_qty.row_by_pk(lrec_ct.preceding_trans_key);

  ltab_uom_set EcDp_Unit.t_uomtable := EcDp_Unit.t_uomtable();

  ln_share NUMBER;
  lb_found BOOLEAN := FALSE;
  lv2_zero_field_quantity VARCHAR2(1);
  lv2_zero_company_quantity VARCHAR2(1);
  ln_f_qty2_share NUMBER;
  ln_f_qty3_share NUMBER;
  ln_f_qty4_share NUMBER;
  ln_fc_qty2_share NUMBER;
  ln_fc_qty3_share NUMBER;
  ln_fc_qty4_share NUMBER;

  no_uom EXCEPTION;

BEGIN


   -- Query staging transaction table for quantities for this transactions.
   FOR rsST IN ecdp_staging_document.gc_staging_transaction(lrec_ct.trans_template_id,
                                                            lrec_ct.product_id,
                                                            lrec_ct.price_concept_code,
                                                            lrec_ct.delivery_point_id,
                                                            ec_stream_item_version.field_id(lrec_ct.stream_item_id, lrec_ct.daytime, '<='),
                                                            lrec_ct.qty_type
                                                            ) LOOP

      -- Query the qty line items for this transaction
      FOR rsSL IN ecdp_staging_document.gc_staging_line_item_list(rsST.ft_st_transaction_no, 'QTY') LOOP


          -- If transaction level record was found, return TRUE. The system will then NOT look for qtys in VO.
          lb_found := TRUE;

          -- Set transaction quantity
          -- Copy figures to table
          EcDp_Unit.GenQtyUOMSet(ltab_uom_set, rsSL.qty1, rsST.uom1_code
                                              ,rsSL.qty2, rsST.uom2_code
                                              ,rsSL.qty3, rsST.uom3_code
                                              ,rsSL.qty4, rsST.uom4_code);

          -- Pick correct figures for each starting with UOM1
          IF lrec_ctq.UOM1_CODE IS NULL THEN
             -- Must have at least one UOM
             RAISE no_uom;
          END IF;

          lrec_ctq.net_qty1 := EcDp_Revn_Unit.GetUOMSetQty(ltab_uom_set, lrec_ctq.UOM1_CODE, p_start_date, lrec_ct.stream_item_id);

          IF lrec_ctq.UOM2_CODE IS NOT NULL THEN
             lrec_ctq.net_qty2 := EcDp_Revn_Unit.GetUOMSetQty(ltab_uom_set, lrec_ctq.UOM2_CODE,p_start_date, lrec_ct.stream_item_id);
          END IF;
          IF lrec_ctq.UOM3_CODE IS NOT NULL THEN
             lrec_ctq.net_qty3 := EcDp_Revn_Unit.GetUOMSetQty(ltab_uom_set, lrec_ctq.UOM3_CODE,p_start_date, lrec_ct.stream_item_id);
          END IF;
          IF lrec_ctq.UOM4_CODE IS NOT NULL THEN
             lrec_ctq.net_qty4 := EcDp_Revn_Unit.GetUOMSetQty(ltab_uom_set, lrec_ctq.UOM4_CODE,p_start_date, lrec_ct.stream_item_id);
          END IF;

          IF ecdp_transaction.IsReducedConfig(p_transaction_key) THEN

              -- Reference interface price object on transaction
              SetTransPriceObject(p_transaction_key, GetTransPriceObject(lrec_ct.price_object_id, rsST.Price_Object_Id, p_start_date), p_user);
              SetTransStreamItem(p_transaction_key, p_user);
              SetTransDistribution(p_transaction_key, p_user);

              FOR c_l IN ecdp_transaction.gc_line_item(p_transaction_key) LOOP
                  ecdp_line_item.GenDistReducedConfig(c_l.line_item_key,NULL,p_user,lrec_ctq.UOM1_CODE);
              END LOOP;

              -- Transaction has been updated - Fetch latest attributes
              lrec_ct := ec_cont_transaction.row_by_pk(p_transaction_key);

          END IF;



          UPDATE cont_transaction_qty
             SET last_updated_by   = 'SYSTEM', -- avoid revision for this temporary update
                 net_grs_indicator = nvl(net_grs_indicator, ecdp_transaction.GetNetGrsIndicator(p_contract_id, p_transaction_key)),
                 net_qty1          = lrec_ctq.net_qty1,
                 net_qty2          = lrec_ctq.net_qty2,
                 net_qty3          = lrec_ctq.net_qty3,
                 net_qty4          = lrec_ctq.net_qty4
           WHERE object_id = p_contract_id
             AND transaction_key = p_transaction_key;


          IF lrec_ct.preceding_trans_key IS NOT NULL AND lrec_ctq.pre_net_qty1 IS NULL THEN

             -- Updating the preceding quantity
             UPDATE cont_transaction_qty
                SET last_updated_by = 'SYSTEM', -- avoid revision for this temporary update
                    pre_net_qty1    = lrec_ctqp.net_qty1,
                    pre_net_qty2    = lrec_ctqp.net_qty2,
                    pre_net_qty3    = lrec_ctqp.net_qty3,
                    pre_net_qty4    = lrec_ctqp.net_qty4
              WHERE object_id = p_contract_id
                AND transaction_key = p_transaction_key;

          END IF;

-----------------------------------------------------------------------------------------------------------------------------
-- FIELD LEVEL QUANTITIES --
-----------------------------------------------------------------------------------------------------------------------------

          -- Loop over cont_line_item_dist to find field distribution. Expecting dist to exist. No split key setup lookup.
          FOR rsCLID IN ecdp_staging_document.gc_cont_li_dist(p_transaction_key) LOOP

             -- TODO: How to handle two stream items using the same field (dist_id) ?

             -- Query staging line item dist table for quantity for this field distribution
             FOR rsSLID IN ecdp_staging_document.gc_staging_li_dist_item(rsST.ft_st_transaction_no, rsSL.ft_st_line_item_no, rsCLID.dist_id) LOOP

                lv2_zero_field_quantity := 'N'; -- temp value

               \* lv2_zero_field_quantity := 'Y'; -- Reset

                -- Check the qty records to see if all fields have zero quantity
                FOR rsValField IN c_val_field_qty(lrec_tran.price_concept_code,
                                                  lrec_tran.product_id,
                                                  lv2_trans_del_point_id,
                                                  p_start_date,
                                                  lv2_ct_uk1,
                                                  lv2_ct_uk2) LOOP

                      IF NVL(rsValField.Qty1,0) != 0 THEN

                         lv2_zero_field_quantity := 'N';

                      END IF;
                END LOOP;*\

\*                --Get the number of fields to distribute to to be used when creating
                --the 'artificial' split shares when all quantites are zero
                SELECT COUNT(d.line_item_key)
                  INTO ln_field_count
                  FROM cont_line_item_dist d
                 WHERE d.transaction_key = p_transaction_key
                   AND d.line_item_based_type = 'QTY';

                --make sure we don't divide by 0
                IF ln_field_count = 0 THEN
                   ln_field_count := 1;
                END IF;*\



                -- Get the atual share based on quantities
                ln_share := CASE WHEN nvl(lrec_ctq.net_qty1,0) = 0 AND nvl(rsSLID.Qty1,0) = 0 THEN 0
                                 WHEN nvl(lrec_ctq.net_qty1,0) = 0 THEN 0
                                 ELSE (nvl(rsSLID.Qty1,0) / lrec_ctq.net_qty1) END;

                 -- Share is determined from table cont_line_item_dist as qty1-qty4 might have individual shares (ECPD-11824)
                 ln_f_qty2_share := ecdp_line_item.getFieldqty2share(rsCLID.line_item_key, rsCLID.dist_id);
                 ln_f_qty3_share := ecdp_line_item.getFieldQty3share(rsCLID.line_item_key, rsCLID.dist_id);
                 ln_f_qty4_share := ecdp_line_item.getFieldQty4share(rsCLID.line_item_key, rsCLID.dist_id);

                 -- Set field quantity
                 UPDATE cont_line_item_dist
                    SET split_value = rsSLID.Qty1,
\*                       split_share = CASE WHEN lv2_zero_field_quantity = 'N' THEN ln_share
                                          WHEN lv2_zero_field_quantity = 'Y' THEN 1/ln_field_count
                                          ELSE split_share END,*\
                        split_share      = ln_share,
                        split_share_qty2 = ln_f_qty2_share,
                        split_share_qty3 = ln_f_qty3_share,
                        split_share_qty4 = ln_f_qty4_share,
                        qty1             = rsSLID.Qty1,
                        qty2             = rsSLID.Qty2,
                        qty3             = rsSLID.Qty3,
                        qty4             = rsSLID.Qty4
                  WHERE line_item_key = rsCLID.line_item_key
                    AND line_item_based_type = 'QTY'
                    AND dist_id = rsCLID.dist_id;

                 -- Update non qty line items with new split share only
                 UPDATE cont_line_item_dist lid
                    \*SET lid.split_share = CASE WHEN lv2_zero_field_quantity = 'N' THEN ln_share
                                          WHEN lv2_zero_field_quantity = 'Y' THEN 1/ln_field_count
                                          ELSE split_share END,*\
                    SET lid.split_share = ln_share,
                        lid.split_share_qty2 = decode(lv2_zero_field_quantity,'N',ln_f_qty2_share,lid.split_share_qty2),
                        lid.split_share_qty3 = decode(lv2_zero_field_quantity,'N',ln_f_qty3_share,lid.split_share_qty3),
                        lid.split_share_qty4 = decode(lv2_zero_field_quantity,'N',ln_f_qty4_share,lid.split_share_qty4)
                  WHERE lid.transaction_key = lrec_ct.transaction_key
                    AND lid.line_item_based_type != 'QTY'
                    AND lid.dist_id = rsCLID.dist_id;


-----------------------------------------------------------------------------------------------------------------------------
-- COMPANY LEVEL QUANTITIES --
-----------------------------------------------------------------------------------------------------------------------------

                  lv2_zero_company_quantity := 'N'; -- temp value

\*                lv2_zero_company_quantity := 'Y'; -- Reset

                  -- Check the qty records to see if all companies (vendors) have zero quantity
                  FOR CurTotComp IN c_val_company_qty(lrec_tran.price_concept_code,
                                                      lrec_tran.product_id,
                                                      lv2_trans_del_point_id,
                                                      lv2_use_field_id,
                                                      lrec_tt.req_qty_type,
                                                      p_start_date,
                                                      lv2_ct_uk1,
                                                      lv2_ct_uk2) LOOP

                        IF NVL(CurTotComp.Qty1,0) != 0 THEN

                           lv2_zero_company_quantity := 'N';

                        END IF;
                  END LOOP;*\


                  -- Loop over cont_li_dist_company to find company distribution
                  FOR rsCLIDC IN ecdp_staging_document.gc_cont_li_dist_comp(lrec_ct.transaction_key, rsCLID.line_item_key, rsCLID.dist_id) LOOP


                     -- Query staging li dist company table for quantity for this company distribution
                     FOR rsSLIDC IN ecdp_staging_document.gc_staging_lid_comp_item(rsST.ft_st_transaction_no, rsSL.ft_st_line_item_no, rsCLID.dist_id, rsCLIDC.vendor_id) LOOP

                         ln_share := CASE WHEN rsSLIDC.Qty1 = 0 AND rsSLID.Qty1 = 0 THEN 0
                                          WHEN rsSLID.Qty1 = 0 THEN 0
                                          ELSE (rsSLIDC.Qty1 / rsSLID.Qty1) END;

                         -- Share is determined from table cont_line_item_dist as qty1-qty4 might have individual shares (ECPD-11824)
                         ln_fc_qty2_share := ecdp_line_item.getFieldCompanyQty2Share(rsCLID.line_item_key,rsCLIDC.dist_id,rsCLIDC.Vendor_Id,rsCLIDC.Customer_Id);
                         ln_fc_qty3_share := ecdp_line_item.getFieldCompanyQty3Share(rsCLID.line_item_key,rsCLIDC.dist_id,rsCLIDC.Vendor_Id,rsCLIDC.Customer_Id);
                         ln_fc_qty4_share := ecdp_line_item.getFieldCompanyQty4Share(rsCLID.line_item_key,rsCLIDC.dist_id,rsCLIDC.Vendor_Id,rsCLIDC.Customer_Id);

                          -- Set company quantity
                          -- Update qty line items
                          UPDATE cont_li_dist_company
                             SET split_value = rsSLIDC.Qty1,
                                 vendor_share = CASE lv2_zero_company_quantity WHEN 'N' THEN ln_share ELSE vendor_share END,
                                 split_share = CASE lv2_zero_company_quantity WHEN 'N' THEN (ln_share * customer_share) ELSE split_share END,
                                 vendor_share_qty2 = ln_fc_qty2_share,
                                 vendor_share_qty3 = ln_fc_qty3_share,
                                 vendor_share_qty4 = ln_fc_qty4_share,
                                 qty1 = rsSLIDC.Qty1,
                                 qty2 = rsSLIDC.Qty2,
                                 qty3 = rsSLIDC.Qty3,
                                 qty4 = rsSLIDC.Qty4
                           WHERE line_item_key = rsCLID.line_item_key
                             AND line_item_based_type = 'QTY'
                             AND dist_id = rsCLID.dist_id
                             AND vendor_id = rsCLIDC.Vendor_Id;

                          -- Update non qty line items with vendor share only
                          UPDATE cont_li_dist_company
                             SET vendor_share = CASE lv2_zero_company_quantity WHEN 'N' THEN ln_share ELSE vendor_share END,
                                 split_share = CASE lv2_zero_company_quantity WHEN 'N' THEN (ln_share * customer_share) ELSE split_share END
                           WHERE transaction_key = lrec_ct.transaction_key
                             AND line_item_based_type != 'QTY'
                             AND dist_id = rsCLID.dist_id
                             AND vendor_id = rsCLIDC.Vendor_Id;

                     END LOOP; -- staging li dist company

                  END LOOP; -- cont li dist company

             END LOOP; -- staging li dist

          END LOOP; -- cont li dist

      END LOOP; -- staging line items

   END LOOP; -- transaction loop

   RETURN lb_found;

EXCEPTION

     WHEN no_uom THEN
          Raise_Application_Error(-20000,'No UOM1 supplied for contract: ' || Nvl(ec_contract.object_code(p_contract_id),' ') || ' - ' || Nvl(ec_contract_version.name(p_contract_id,p_start_date,'<='),' ') );

END GenTranQtyFromStaging;*/

FUNCTION VerifyVatCodeCountry (p_object_id varchar2, p_vat_code varchar2, p_daytime date,p_financial_code varchar2 ) return VARCHAR2
IS

  CURSOR verify_vat(cp_vat_code varchar2, cp_daytime date, cp_financial_code varchar2, cp_object_id varchar2) is
       SELECT vcv.object_id
         FROM vat_code_version vcv
        WHERE vcv.vat_type = CASE cp_financial_code
                WHEN 'SALE' THEN 'I'
                WHEN 'TA_INCOME' THEN 'I'
                WHEN 'PURCHASE' THEN 'C'
                WHEN 'TA_COST' THEN 'C'
                WHEN 'JOU_ENT' THEN 'I'
                ELSE vat_type
              END
          AND vcv.country_id = ec_company_version.country_id(ec_contract_version.company_id(cp_object_id, cp_daytime, '<='), cp_daytime, '<=')
          AND ec_vat_code.object_id_by_uk(cp_vat_code) = vcv.object_id
          AND vcv.daytime <= cp_daytime
          AND nvl(vcv.end_date, cp_daytime + 1) > cp_daytime;

   lv2_return_val VARCHAR2(1) := 'N';

BEGIN

  FOR vat in verify_vat (p_vat_code,p_daytime,p_financial_code,p_object_id) LOOP
    lv2_return_val := 'Y';
  END LOOP;

  RETURN lv2_return_val;

END VerifyVatCodeCountry;

FUNCTION GetFieldShare(
    p_transaction_tmpl_id                   VARCHAR2,
    p_daytime                               DATE,
    p_dist_id                               VARCHAR2)
RETURN NUMBER
IS
    CURSOR c_query_share(
        cp_transaction_tmpl_id              VARCHAR2,
        cp_daytime                          DATE,
        cp_dist_id                          VARCHAR2)
    IS
        SELECT FIELD_SPLITS.SPLIT_SHARE_MTH SHARE_VALUE
          FROM TRANSACTION_TMPL_VERSION   TEMPLATES,
               SPLIT_KEY_SETUP            FIELD_SPLITS,
               STREAM_ITEM_VERSION        STREAM_ITEM
         WHERE TEMPLATES.OBJECT_ID = cp_transaction_tmpl_id
           AND TEMPLATES.DAYTIME <= cp_daytime
           AND NVL(TEMPLATES.END_DATE, cp_daytime + 1) > cp_daytime
           AND FIELD_SPLITS.OBJECT_ID = TEMPLATES.SPLIT_KEY_ID
           AND FIELD_SPLITS.DAYTIME = TEMPLATES.DAYTIME
           AND STREAM_ITEM.OBJECT_ID = FIELD_SPLITS.SPLIT_MEMBER_ID
           AND STREAM_ITEM.DAYTIME <= FIELD_SPLITS.DAYTIME
           AND NVL(STREAM_ITEM.END_DATE, FIELD_SPLITS.DAYTIME + 1) > FIELD_SPLITS.DAYTIME
           AND STREAM_ITEM.FIELD_ID = cp_dist_id;

    ln_result NUMBER;
BEGIN
    FOR li_share IN c_query_share(p_transaction_tmpl_id, p_daytime, p_dist_id)
    LOOP
        ln_result := li_share.SHARE_VALUE;
        EXIT;
    END LOOP;

    RETURN ln_result;
END GetFieldShare;


FUNCTION GetCompanyShare(
    p_transaction_tmpl_id                   VARCHAR2,
    p_daytime                               DATE,
    p_field_id                              VARCHAR2,
    p_company_id                            VARCHAR2)
RETURN NUMBER
IS
    ln_result NUMBER;
BEGIN
    FOR li_share IN gc_tt_company_share(p_transaction_tmpl_id, p_daytime, p_field_id, p_company_id)
    LOOP
        ln_result := li_share.SHARE_VALUE;
        EXIT;
    END LOOP;

    RETURN ln_result;
END GetCompanyShare;





END Ecdp_Transaction_Qty;