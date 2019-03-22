CREATE OR REPLACE PACKAGE BODY Ecdp_Transaction IS
/****************************************************************
** Package        :  Ecdp_Transaction, body part
**
** $Revision: 1.247 $
**
** Purpose        :  Provide special functions on Transactions.
**
** Documentation  :  www.energy-components.com
**
** Created  : 29.11.2005 Trond-Arne Brattli
**
** Modification history:
**
*******************************************************************************************************************************************************/

    -----------------------------------------------------------------------
    -- Gets meta of transactions under given document.
    ----+----------------------------------+-------------------------------
    CURSOR c_get_trans_meta_by_doc(
        p_document_key             cont_transaction.transaction_key%TYPE
    )
    IS
        SELECT trans.transaction_key
              ,trans.daytime
              ,trans.reversed_trans_key
              ,trans.reversal_ind
              ,trans.preceding_trans_key
              ,trans.object_id
        FROM cont_transaction trans
        WHERE document_key = p_document_key;

    -----------------------------------------------------------------------
    -- Gets meta of a transaction.
    ----+----------------------------------+-------------------------------
    CURSOR c_get_trans_meta(
        p_transaction_key          cont_transaction.transaction_key%TYPE
    )
    IS
        SELECT trans.transaction_key
              ,trans.daytime
              ,trans.reversed_trans_key
              ,trans.reversal_ind
              ,trans.preceding_trans_key
              ,trans.object_id
        FROM cont_transaction trans
        WHERE transaction_key = p_transaction_key;


-- This cursor is used to determine if a price has/can be(en) picked from the interface
CURSOR gc_IfacQtyPrice (cp_contract_id         VARCHAR2,
                        cp_Processing_Period   DATE,
                        cp_period_start_date   DATE,
                        cp_period_end_date     DATE,
                        cp_price_concept_code  VARCHAR2,
                        cp_delivery_point_id   VARCHAR2,
                        cp_product_id          VARCHAR2,
                        cp_customer_id         VARCHAR2,
                        cp_qty_status          VARCHAR2,
                        cp_uom1_code           VARCHAR2,
                        cp_price_object_id     VARCHAR2,
                        cp_ifac_uk1            VARCHAR2,
                        cp_ifac_uk2            VARCHAR2,
                        cp_ifac_tt_conn_code   VARCHAR2) IS
   SELECT i.qty1, i.unit_price, i.pricing_value
    FROM ifac_sales_qty i
    WHERE i.contract_id = cp_contract_id
      AND i.Processing_Period = cp_Processing_Period
      AND i.period_start_date = cp_period_start_date
      AND i.period_end_date = nvl(cp_period_end_date,i.period_end_date)
      AND i.price_concept_code = cp_price_concept_code
      AND i.delivery_point_id = cp_delivery_point_id
      AND i.product_id = cp_product_id
      AND i.customer_id = cp_customer_id
      AND i.qty_status = cp_qty_status
      AND i.uom1_code = cp_uom1_code
      AND i.alloc_no_max_ind = 'Y'
      AND (i.line_item_based_type ='QTY' or i.line_item_based_type is null)
      AND NVL(i.price_object_id,'X') = NVL(cp_price_object_id,'X')
      AND nvl(i.unique_key_1, 'NA') = nvl(cp_ifac_uk1, 'NA')
      AND nvl(i.unique_key_2, 'NA') = nvl(cp_ifac_uk2, 'NA')
      AND nvl(i.ifac_tt_conn_code, 'NA') = nvl(cp_ifac_tt_conn_code, 'NA')
      AND i.unit_price IS NOT NULL;


-- This cursor is used to determine if a price has/can be(en) picked from the interface
CURSOR gc_IfacQtyPriceOli (cp_contract_id          VARCHAR2,
                           cp_Processing_Period    DATE,
                           cp_period_start_date    DATE,
                           cp_period_end_date      DATE,
                           cp_price_concept_code   VARCHAR2,
                           cp_delivery_point_id    VARCHAR2,
                           cp_product_id           VARCHAR2,
                           cp_customer_id          VARCHAR2,
                           cp_qty_status           VARCHAR2,
                           cp_uom1_code            VARCHAR2,
                           cp_price_object_id      VARCHAR2,
                           cp_ifac_uk1             VARCHAR2,
                           cp_ifac_uk2             VARCHAR2,
                           cp_ifac_tt_conn_code    VARCHAR2,
                           cp_line_item_based_type VARCHAR2,
                           cp_line_item_type       VARCHAR2,
                           cp_ifac_li_conn_code    VARCHAR2) IS
   SELECT i.qty1, i.unit_price, i.pricing_value
    FROM ifac_sales_qty i
    WHERE i.contract_id = cp_contract_id
      AND i.period_start_date = cp_period_start_date
      AND i.period_end_date = nvl(cp_period_end_date,i.period_end_date)
      AND i.price_concept_code = cp_price_concept_code
      AND i.delivery_point_id = cp_delivery_point_id
      AND i.product_id = cp_product_id
      AND i.customer_id = cp_customer_id
      AND i.qty_status = cp_qty_status
      AND i.uom1_code = cp_uom1_code
      AND i.alloc_no_max_ind = 'Y'
      AND i.line_item_based_type = cp_line_item_based_type
      AND nvl(i.line_item_type,'X') = NVL(cp_line_item_type,'X')
      AND nvl(i.ifac_li_conn_code,'X') =  nvl(cp_ifac_li_conn_code,'X')
      AND NVL(i.price_object_id,'X') = NVL(cp_price_object_id,'X')
      AND nvl(i.unique_key_1, 'NA') = nvl(cp_ifac_uk1, 'NA')
      AND nvl(i.unique_key_2, 'NA') = nvl(cp_ifac_uk2, 'NA')
      AND nvl(i.ifac_tt_conn_code, 'NA') = nvl(cp_ifac_tt_conn_code, 'NA')
      AND i.unit_price IS NOT NULL;


CURSOR  gc_IfacCargoPrice(cp_contract_id        VARCHAR2,
                          cp_cargo_no           VARCHAR2,
                          cp_parcel_no          VARCHAR2,
                          cp_qty_type           VARCHAR2,
                          cp_price_object_id    VARCHAR2,
                          cp_price_concept_code VARCHAR2,
                          cp_product_id         VARCHAR2,
                          cp_customer_id        VARCHAR2,
                          cp_uom1_code          VARCHAR2,
                          cp_if_tt_conn_code    VARCHAR2) IS
  SELECT sm.net_qty1, sm.unit_price, sm.pricing_value
    FROM ifac_cargo_value sm
   WHERE sm.alloc_no_max_ind = 'Y'
     AND sm.ignore_ind = 'N'
     AND sm.contract_id = cp_contract_id
     AND sm.cargo_no = cp_cargo_no
     AND sm.parcel_no = cp_parcel_no
     AND sm.qty_type = cp_qty_type
     AND sm.uom1_code = cp_uom1_code
     AND sm.product_id = cp_product_id
     AND sm.customer_id = cp_customer_id
     AND sm.price_concept_code = cp_price_concept_code
     AND NVL(sm.price_object_id,'X') = NVL(cp_price_object_id,'X')
     AND nvl(sm.ifac_tt_conn_code,'NA') = nvl(cp_if_tt_conn_code,'NA')
     AND (sm.line_item_based_type ='QTY' or sm.line_item_based_type is null)
     AND sm.unit_price IS NOT NULL;


CURSOR  gc_IfacCargoPriceOli(cp_contract_id          VARCHAR2,
                             cp_cargo_no             VARCHAR2,
                             cp_parcel_no            VARCHAR2,
                             cp_qty_type             VARCHAR2,
                             cp_price_object_id      VARCHAR2,
                             cp_price_concept_code   VARCHAR2,
                             cp_product_id           VARCHAR2,
                             cp_customer_id          VARCHAR2,
                             cp_uom1_code            VARCHAR2,
                             cp_if_tt_conn_code      VARCHAR2,
                             cp_line_item_based_type VARCHAR2,
                             cp_line_item_type       VARCHAR2,
                             cp_ifac_li_conn_code    VARCHAR2) IS
  SELECT sm.net_qty1, sm.unit_price, sm.pricing_value
    FROM ifac_cargo_value sm
   WHERE sm.alloc_no_max_ind = 'Y'
     AND sm.ignore_ind = 'N'
     AND sm.contract_id = cp_contract_id
     AND sm.cargo_no = cp_cargo_no
     AND sm.parcel_no = cp_parcel_no
     AND sm.qty_type = cp_qty_type
     AND sm.uom1_code = cp_uom1_code
     AND sm.product_id = cp_product_id
     AND sm.customer_id = cp_customer_id
     AND sm.price_concept_code = cp_price_concept_code
     AND NVL(sm.price_object_id,'X') = NVL(cp_price_object_id,'X')
     AND nvl(sm.ifac_tt_conn_code,'NA') = nvl(cp_if_tt_conn_code,'NA')
     AND sm.line_item_based_type = cp_line_item_based_type
     AND nvl(sm.line_item_type,'X') = NVL(cp_line_item_type,'X')
     AND nvl(sm.ifac_li_conn_code ,'X') =  nvl(cp_ifac_li_conn_code,'X')
     AND sm.unit_price IS NOT NULL;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Returns a value indicating if the given transaction has quantity line items.
--
-- p_transaction_key: the key of transaction to generate lines for.
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION has_qty_li_p(
                         p_transaction_key                  VARCHAR2
)
RETURN BOOLEAN
IS
    ln_count NUMBER;
BEGIN
    SELECT COUNT(line_item_key) INTO ln_count
    FROM cont_line_item
    WHERE transaction_key = p_transaction_key
        AND line_item_based_type = 'QTY';

    RETURN (ln_count > 0);
END;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- (See header)
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION get_qty_li_keys(
                         p_transaction_key                  VARCHAR2
)
RETURN t_table_varchar2
IS
    lo_keys t_table_varchar2;
BEGIN
    SELECT line_item_key
    BULK COLLECT INTO lo_keys
    FROM cont_line_item
    WHERE transaction_key = p_transaction_key
        AND line_item_based_type = 'QTY';

    RETURN lo_keys;
END;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Fills values on other line items on the given transaction, with given context.
--
-- p_target_transaction_key: key of the transaction which to fill other lines on.
-- p_user: the id of user triggered this action.
-- p_context: the operation context.
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION fill_non_qty_lines_p(
                         p_context                          IN OUT NOCOPY T_REVN_DOC_OP_CONTEXT
                        ,p_target_transaction_key           cont_transaction.transaction_key%type
)
RETURN BOOLEAN
IS
    lo_other_li_ifac_idx t_table_number;
    lo_ifac_li_level_period t_ifac_sales_qty;
    lo_ifac_li_level_cargo t_ifac_cargo_value;

    lrec_tran cont_transaction%ROWTYPE;
    lrec_doc cont_document%ROWTYPE;
    l_value_found BOOLEAN;
BEGIN
    l_value_found := FALSE;

    IF ue_cont_transaction.isFillTransLIUEEnabled = 'TRUE' THEN
        ue_cont_transaction.FillTransactionOLI(p_target_transaction_key, p_context.user_id);
    ELSE
        lrec_tran := ec_cont_transaction.row_by_pk(p_target_transaction_key);

/*        IF lrec_tran.transaction_date IS NULL THEN
            RAISE missing_transaction_date;
        END IF;*/

        lrec_doc := ec_cont_document.row_by_pk(lrec_tran.document_key);

        IF (lrec_doc.parent_document_key IS NULL) THEN
            IF (lrec_tran.transaction_scope = 'PERIOD_BASED') THEN
                -- get all line item level ifac from processing transaction
                lo_other_li_ifac_idx := ecdp_revn_ifac_wrapper_period.Find(
                    p_context.ifac_period,
                    p_level => ecdp_revn_ifac_wrapper.gconst_level_line_item,
                    p_transaction_key => p_target_transaction_key);

                IF lo_other_li_ifac_idx.count > 0 THEN
                    FOR i IN 1..lo_other_li_ifac_idx.count LOOP
                        lo_ifac_li_level_period := p_context.ifac_period(lo_other_li_ifac_idx(i));

                        -- only non-qty line items are handled
                        IF lo_ifac_li_level_period.line_item_based_type = 'QTY' THEN
                            continue;
                        END IF;

                        IF lo_ifac_li_level_period.line_item_key IS NULL THEN
                            continue;
                        END IF;

                        l_value_found := ecdp_line_item.fill_by_ifac_i(p_context, lo_ifac_li_level_period.line_item_key) OR l_value_found;
                        IF (l_value_found) THEN
                            EcDp_Transaction_Qty.SetTransPriceObject(p_target_transaction_key,
                                                                     lo_ifac_li_level_period.PRICE_OBJECT_ID,
                                                                     p_context.user_id,
                                                                     lo_ifac_li_level_period.QTY_STATUS);

                            fillTransactionPriceOli(p_target_transaction_key,
                                                    lo_ifac_li_level_period.PROCESSING_PERIOD,
                                                    p_context.user_id,
                                                    lo_ifac_li_level_period.LINE_ITEM_KEY,
                                                    lo_ifac_li_level_period.LINE_ITEM_BASED_TYPE,
                                                    lo_ifac_li_level_period.LINE_ITEM_TYPE,
                                                    lo_ifac_li_level_period.IFAC_LI_CONN_CODE);
                        END IF;
                    END LOOP;
                END IF;

            ELSIF (lrec_tran.transaction_scope = 'CARGO_BASED') THEN
                   -- get all line item level ifac from processing transaction
                lo_other_li_ifac_idx := ecdp_revn_ifac_wrapper_cargo.Find(
                    p_context.ifac_cargo,
                    p_level => ecdp_revn_ifac_wrapper.gconst_level_line_item,
                    p_transaction_key => p_target_transaction_key);

                IF lo_other_li_ifac_idx.count > 0 THEN
                    FOR i IN 1..lo_other_li_ifac_idx.count LOOP
                        lo_ifac_li_level_cargo := p_context.ifac_cargo(lo_other_li_ifac_idx(i));

                        -- only non-qty line items are handled
                        IF lo_ifac_li_level_cargo.line_item_based_type = 'QTY' THEN
                            continue;
                        END IF;

                        IF lo_ifac_li_level_cargo.line_item_key IS NULL THEN
                            continue;
                        END IF;

                        l_value_found := ecdp_line_item.fill_by_ifac_i(p_context, lo_ifac_li_level_cargo.line_item_key) OR l_value_found;
                        IF (l_value_found) THEN
                            fillTransactionPriceOli(p_target_transaction_key,
                                                    lo_ifac_li_level_cargo.POINT_OF_SALE_DATE,
                                                    p_context.user_id,
                                                    lo_ifac_li_level_cargo.LINE_ITEM_KEY,
                                                    lo_ifac_li_level_cargo.LINE_ITEM_BASED_TYPE,
                                                    lo_ifac_li_level_cargo.LINE_ITEM_TYPE,
                                                    lo_ifac_li_level_cargo.IFAC_LI_CONN_CODE);
                        END IF;
                    END LOOP;
                END IF;
            END IF;
        END IF;
    END IF;

    IF ue_cont_transaction.isFillTransLIPostUEEnabled = 'TRUE' THEN
        ue_cont_transaction.FillTransLIPost(p_target_transaction_key, p_context.user_id);
    END IF;

    RETURN l_value_found;
END;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Removes given line item and its distribution.
--
-- p_line_item_key: the line item key.
------------------------+-----------------------------------+------------------------------------+---------------------------
procedure remove_line_item_p(p_line_item_key varchar2)
is
begin
    DELETE cont_li_dist_company WHERE line_item_key = p_line_item_key;
    DELETE cont_line_item_dist WHERE line_item_key = p_line_item_key;
    DELETE cont_line_item_uom WHERE line_item_key = p_line_item_key;
    DELETE cont_line_item WHERE line_item_key = p_line_item_key;
end;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Removes line items in given transaction and its distribution. If base type is given, only items of the specified type
-- will be removed.
--
-- p_transaction_key: the transaction key.
-- p_line_item_base_type: (optional) the base type of line items to be removed.
------------------------+-----------------------------------+------------------------------------+---------------------------
procedure remove_line_items_p(p_transaction_key varchar2, p_line_item_base_type varchar2 default null)
is
begin
    FOR line_item IN ecdp_transaction.gc_line_item(p_transaction_key) LOOP
        IF line_item.line_item_based_type = nvl(p_line_item_base_type, line_item.line_item_based_type) THEN
            remove_line_item_p(line_item.line_item_key);
        END IF;
    END LOOP;
end;


------------------------+-----------------------------------+------------------------------------+---------------------------
-- Apply price object on given reduced config transaction. Stream item and distribution will be re-generated.
--
-- p_transaction_key: the transaction key.
-- p_price_object_id: the price object id.
-- p_user_id: the user id.
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE apply_po_on_trans_rc_p(
                         p_transaction_key VARCHAR2
                        ,p_price_object_id VARCHAR2
                        ,p_user_id VARCHAR2
                        )
IS
    lb_use_si boolean;
    lrec_cont_trans cont_transaction%ROWTYPE := ec_cont_transaction.row_by_pk(p_transaction_key);
BEGIN
    -- only handle reduced config transactions
    IF NOT IsReducedConfig(NULL, NULL, NULL, p_transaction_key, lrec_cont_trans.daytime) THEN
       RETURN;
    END IF;

    -- remove quantity line item
    remove_line_items_p(p_transaction_key, 'QTY');

    -- clean out the stream item id
    UPDATE cont_transaction
       SET stream_item_id = NULL, last_updated_by = p_user_id
     WHERE transaction_key = p_transaction_key;

    lb_use_si := ecdp_revn_common.TranslateToBoolean(
        UPPER(ec_transaction_tmpl_version.use_stream_items_ind(lrec_cont_trans.trans_template_id, lrec_cont_trans.daytime, '<=')));

    IF p_price_object_id IS not NULL THEN
        -- Deploy transaction stream item
        IF lb_use_si THEN
            SetTransStreamItem(p_transaction_key,p_user_id);
        END IF;

        -- Deploy transaction level line item
        ecdp_transaction_qty.create_missing_qty_li_by_pel_i(p_transaction_key);

        -- Deploy transaction, field and company level line item
        FOR c_l IN ecdp_transaction.gc_line_item(p_transaction_key) LOOP
            IF lb_use_si THEN
                ecdp_line_item.gen_dist_party_f_conf_field(
                    c_l.line_item_key,
                    NULL,
                    p_user_id,
                    ec_cont_transaction_qty.uom1_code(p_transaction_key));
            ELSE
                ecdp_line_item.gen_dist_party_f_conf_pc(
                    c_l.line_item_key,
                    NULL,
                    p_user_id,
                    ec_cont_transaction_qty.uom1_code(p_transaction_key));
            END IF;
        END LOOP;

        UPDATE cont_transaction_qty
        SET net_grs_indicator = nvl(net_grs_indicator,ecdp_transaction.GetNetGrsIndicator(object_id,transaction_key))
        WHERE transaction_key = p_transaction_key;
    END IF;

    triggerIULogic(ec_cont_transaction.document_key(p_transaction_key),p_user_id,'NA',p_transaction_key);
END;


FUNCTION getParcelNoPerTransaction(p_transaction_key VARCHAR2, p_daytime DATE) RETURN VARCHAR2
 IS

cursor cargo_transport (cp_cargo_name VARCHAR2) is
select cargo_no
  from cargo_transport x
 where x.cargo_name = cp_cargo_name;

cursor storage_lift_nom (cp_cargo_no NUMBER, cp_parcel_name_as_num NUMBER) is
select x.parcel_no
  from storage_lift_nomination x
 where x.cargo_no = cp_cargo_no
  and x.nom_sequence = cp_parcel_name_as_num;


lv2_parcel_key VARCHAR2(240);
lv2_cargo_name VARCHAR2(240);
lv2_parcel_name VARCHAR2(240);
lv2_pracel_no_method VARCHAR2(240);
lv2_price_src_type VARCHAR2(240);
ln_cargo_no NUMBER;
ln_parcel_name_as_num NUMBER;



BEGIN
    lv2_price_src_type := NVL(ec_cont_transaction.price_src_type(p_transaction_key),'XXX');
    IF lv2_price_src_type = 'CARGO_BASED' THEN
      --check if it is the NOM_SEQUENCE number or PARCEL_NO that is being used as Parcel No:
      -- System attribute 'PARCEL_NO_MENTOD possible values:
      --   'PARCEL_NO' for using the real Parcel Number (unique)
      --   'NOM_SEQUENCE' for using the Nom Sequence number, like '1', '2'
      -- Fallback value is 'PARCEL_NO' if the system attribute is missing
      lv2_pracel_no_method := nvl(ec_ctrl_system_attribute.attribute_text(p_daytime,  'PARCEL_NO_METHOD', '<='),'PARCEL_NO');
      IF lv2_pracel_no_method = 'PARCEL_NO' THEN
        --The 'real' parcel number is directly at the CONT_TRANSACTION.PARCEL_NAME
        lv2_parcel_key := ec_cont_transaction.parcel_name(p_transaction_key);
      ELSIF lv2_pracel_no_method = 'NOM_SEQUENCE' THEN
        --We must find the real Parcel No through the NOM_SEQUENCE number and Cargo Number...
       --find Cargo Name and parcel_name
        lv2_cargo_name := ec_cont_transaction.cargo_name(p_transaction_key);
        lv2_parcel_name := ec_cont_transaction.parcel_name(p_transaction_key);
        if lv2_cargo_name is null then
          --error: Missing cargo name
          RETURN 'NA';
        end if;
        if lv2_parcel_name is null then
         --error: Missing parcel name
          RETURN 'NA';
        end if;
        --convert from string to number
        --NB Need error handling here in case the lv2_parcel_name is not a number
        BEGIN
             ln_parcel_name_as_num := to_number(lv2_parcel_name);
        EXCEPTION
          WHEN VALUE_ERROR THEN
            RETURN 'NA';
        END;
        --find cargo_no from cargo name
        for c in cargo_transport(lv2_cargo_name) loop
          ln_cargo_no := c.cargo_no;
        end loop;
        if ln_cargo_no is null then
          --error
          RETURN 'NA';
        end if;
        --find parcel_no from cargo_no and parcel_name:
        for cc in storage_lift_nom (ln_cargo_no, ln_parcel_name_as_num) loop
          lv2_parcel_key := to_char(cc.parcel_no);
        end loop;
        if lv2_parcel_key is null then
          --error
          RETURN 'NA';
        end if;
      ELSE
       --non-supported value for system attribute 'PARCEL_NO_METHOD'
        RETURN 'NA';
      END IF;
    ELSE
      --Not cargo-based price
      return null;
    END IF;
    return lv2_parcel_key;

END getParcelNoPerTransaction;



FUNCTION GetQtyPrice(
   p_contract_id VARCHAR2,
   p_line_item_id VARCHAR2,
   p_line_item_template_object_id VARCHAR2,
   p_transaction_key VARCHAR2,
   p_daytime DATE,
   p_line_item_based_type VARCHAR2 DEFAULT 'QTY',
   p_price_object_id VARCHAR2 DEFAULT NULL,
   p_price_element_code VARCHAR2 DEFAULT NULL,
   p_silent VARCHAR2 DEFAULT 'N' -- Y/N
) RETURN NUMBER

IS

lv2_price_object_id VARCHAR2(32);

CURSOR c_price (cp_product_object_id VARCHAR2, cp_price_date DATE, cp_parcel_key VARCHAR2, cp_price_object_id VARCHAR2) IS
SELECT Ecdp_Contract_Setup.GetPriceElemDate(p_contract_id,
                                            nvl(nvl(litv.price_object_id,ttv.price_object_id),cp_price_object_id),
                                            litv.price_element_code,
                                            cp_product_object_id,
                                            ttv.pricing_currency_id,
                                            cp_price_date,
                                            cp_parcel_key) daytime,
       Ecdp_Contract_Setup.GetPriceElemVal(p_contract_id,
                                           nvl(nvl(litv.price_object_id,ttv.price_object_id),cp_price_object_id),
                                           litv.price_element_code,
                                           cp_product_object_id,
                                           ttv.pricing_currency_id,
                                           cp_price_date,
                                           cp_parcel_key) price_value,
       ttv.name trans_templ_name,
       litv.name line_item_name
  FROM line_item_template       lit,
       line_item_tmpl_version   litv,
       transaction_template     tt,
       transaction_tmpl_version ttv
 WHERE lit.object_id = litv.object_id
   AND lit.object_id = p_line_item_template_object_id
   AND lit.transaction_template_id = tt.object_id
   AND tt.start_date =
       (SELECT MAX(start_date)
          FROM transaction_template tt2
         WHERE tt2.object_id = tt.object_id
           AND tt2.start_date <= cp_price_date)
   AND tt.object_id = ttv.object_id
   AND ttv.daytime = (SELECT MAX(daytime)
                        FROM transaction_tmpl_version ttv2
                       WHERE ttv2.object_id = ttv.object_id
                         AND ttv2.daytime <= cp_price_date)
   AND nvl(ttv.product_id,cp_product_object_id) = cp_product_object_id -- Other types of line item might have line item template however transaction template might still not have price ojbect, product, price concept
   AND litv.daytime <= cp_price_date
   AND litv.daytime = (SELECT MAX(daytime)
                         FROM line_item_tmpl_version litv2
                        WHERE litv2.object_id = litv.object_id
                          AND litv2.daytime <= cp_price_date);



CURSOR c_price_no_lit (cp_product_object_id VARCHAR2, cp_price_object_id VARCHAR2, cp_price_date DATE, cp_parcel_key VARCHAR2) IS
SELECT Ecdp_Contract_Setup.GetPriceElemDate(p_contract_id,
                                            cp_price_object_id,
                                            p_price_element_code,
                                            cp_product_object_id,
                                            ttv.pricing_currency_id,
                                            cp_price_date,
                                            cp_parcel_key) daytime,
       Ecdp_Contract_Setup.GetPriceElemVal(p_contract_id,
                                           cp_price_object_id,
                                           p_price_element_code,
                                           cp_product_object_id,
                                           ttv.pricing_currency_id,
                                           cp_price_date,
                                           cp_parcel_key) price_value
  FROM transaction_template tt, transaction_tmpl_version ttv
 WHERE ec_cont_transaction.trans_template_id(p_transaction_key) =
       tt.object_id
   AND tt.start_date =
       (SELECT MAX(start_date)
          FROM transaction_template tt2
         WHERE tt2.object_id = tt.object_id
           AND tt2.start_date <= cp_price_date)
   AND tt.object_id = ttv.object_id
   AND ttv.daytime = (SELECT MAX(daytime)
                        FROM transaction_tmpl_version ttv2
                       WHERE ttv2.object_id = ttv.object_id
                         AND ttv2.daytime <= cp_price_date)
   AND nvl(ttv.product_id,cp_product_object_id) = cp_product_object_id;

  missing_transaction_date EXCEPTION;
  missing_price_date EXCEPTION;
  missing_review_period EXCEPTION;
  missing_price_value EXCEPTION;
  price_not_exist EXCEPTION;
  prices_too_old EXCEPTION;
  price_date_not_exist EXCEPTION;

  lv2_document_id cont_document.document_key%TYPE;
  lv2_product_object_id cont_transaction.product_id%TYPE;
  ld_price_date DATE;
  ln_review_period NUMBER;
  lv2_review_period_unit VARCHAR2(32);
  lv2_contract_doc_object_id VARCHAR2(32);
  lv2_parcel_key VARCHAR2(32);
  lv2_price_src_type VARCHAR2(32);
  ln_pricing_value NUMBER;
  ln_qty1 NUMBER;
  ln_unit_price NUMBER;
  lv2_info VARCHAR2(320);

BEGIN

  lv2_document_id := ec_cont_transaction.document_key(p_transaction_key);
  lv2_contract_doc_object_id := ec_cont_document.contract_doc_id(lv2_document_id);
  lv2_product_object_id := ec_cont_transaction.product_id(p_transaction_key);
  ld_price_date := nvl(ec_cont_transaction.price_date(p_transaction_key),p_daytime);
  ln_review_period := ec_contract_doc_version.review_period(lv2_contract_doc_object_id, ec_cont_document.daytime(lv2_document_id), '<=');
  lv2_review_period_unit := ec_contract_doc_version.review_period_unit_code(lv2_contract_doc_object_id, ec_cont_document.daytime(lv2_document_id), '<=');
  lv2_price_src_type := NVL(ec_cont_transaction.price_src_type(p_transaction_key),'XXX');
  lv2_price_object_id := nvl(p_price_object_id,ec_cont_transaction.price_object_id(p_transaction_key));

  IF lv2_price_src_type = 'CARGO_BASED' THEN

      lv2_parcel_key := getParcelNoPerTransaction(p_transaction_key, p_daytime);

     if nvl(lv2_parcel_key,'NA') = 'NA' THEN
        --Could not find parcel key - will not pick price becasue it will give a contract-specific price when Parcel key is null!
        --Reason for getParcelNoPerTransaction() returning NA:
        -- Missing Cargo Name and/or Parcel Name if system attribute 'PARCEL_NO_METHOD' = 'NOM_SEQUENCE'
        -- Missing Parcel Name if system attribute 'PARCEL_NO_METHOD' = 'PARCEL_NO'
        return null;
     END IF;
  ELSE

      lv2_parcel_key := NULL;

  END IF;



  IF lv2_price_src_type = 'PRICING_VALUE' THEN

     ln_pricing_value := ec_cont_transaction.qty_pricing_value(p_transaction_key);
     ln_qty1 := ec_cont_transaction_qty.net_qty1(p_transaction_key);

     IF ln_qty1 IS NOT NULL AND ln_qty1 <> 0 THEN

        ln_unit_price := ln_pricing_value / ln_qty1;

        RETURN ln_unit_price;

     ELSE

        RETURN 0;

     END IF;


  ELSE

  IF ld_price_date is null THEN

     IF p_silent = 'N' THEN
        RAISE missing_price_date;
     END IF;

  END IF;

  IF ln_review_period is null THEN

     IF p_silent = 'N' THEN
        RAISE missing_review_period;
     END IF;

  END IF;

  IF p_line_item_based_type = 'QTY' THEN

  IF p_line_item_template_object_id IS NOT NULL THEN

    FOR pcur IN c_price (lv2_product_object_id, ld_price_date, lv2_parcel_key,lv2_price_object_id) LOOP


       IF pcur.price_value is null then

          IF p_silent = 'N' THEN
             RAISE missing_price_value;
          END IF;

       ELSE
          IF lv2_price_src_type = 'CARGO_BASED' THEN

            RETURN pcur.price_value;

          ELSIF (lv2_review_period_unit = 'MONTHS' AND ld_price_date between pcur.daytime AND Add_Months(pcur.daytime, ln_review_period) - 1) OR
             (lv2_review_period_unit = 'DAYS' AND ld_price_date between pcur.daytime AND pcur.daytime + ln_review_period - 1)  THEN

             RETURN pcur.price_value;

          ELSIF pcur.daytime > ld_price_date THEN

             IF p_silent = 'N' THEN
                RAISE price_date_not_exist;
             END IF;

          ELSE

             IF p_silent = 'N' THEN
                RAISE prices_too_old;
             END IF;

          END IF;

       END IF;



    END LOOP; -- pcur

    ELSE
       FOR pcur_nolit IN c_price_no_lit (lv2_product_object_id, lv2_price_object_id, ld_price_date, lv2_parcel_key) LOOP
         IF pcur_nolit.price_value is null then

          IF p_silent = 'N' THEN
             RAISE missing_price_value;
          END IF;

       ELSE

          IF lv2_price_src_type = 'CARGO_BASED' THEN

            RETURN pcur_nolit.price_value;

          ELSIF (lv2_review_period_unit = 'MONTHS' AND ld_price_date between pcur_nolit.daytime AND Add_Months(pcur_nolit.daytime, ln_review_period) - 1) OR
             (lv2_review_period_unit = 'DAYS' AND ld_price_date between pcur_nolit.daytime AND pcur_nolit.daytime + ln_review_period - 1)  THEN

             RETURN pcur_nolit.price_value;

          ELSIF pcur_nolit.daytime > ld_price_date THEN

             IF p_silent = 'N' THEN
                RAISE price_date_not_exist;
             END IF;

          ELSE

             IF p_silent = 'N' THEN
                RAISE prices_too_old;
             END IF;

          END IF;

       END IF;
         END LOOP;


    END IF;

  ELSIF p_line_item_based_type = 'FREE_UNIT_PRICE_OBJECT' THEN

    IF p_line_item_template_object_id IS NULL THEN

        FOR pcur_nolit IN c_price_no_lit (lv2_product_object_id, lv2_price_object_id, ld_price_date, lv2_parcel_key) LOOP

           IF pcur_nolit.price_value is null then

              IF p_silent = 'N' THEN
                 RAISE missing_price_value;
              END IF;

           ELSE

              IF lv2_price_src_type = 'CARGO_BASED' THEN

                 RETURN pcur_nolit.price_value;

              ELSIF (lv2_review_period_unit = 'MONTHS' AND ld_price_date between pcur_nolit.daytime AND Add_Months(pcur_nolit.daytime, ln_review_period) - 1) OR
                 (lv2_review_period_unit = 'DAYS' AND ld_price_date between pcur_nolit.daytime AND pcur_nolit.daytime + ln_review_period - 1)  THEN

                 RETURN pcur_nolit.price_value;

              ELSIF pcur_nolit.daytime > ld_price_date THEN

                 IF p_silent = 'N' THEN
                    RAISE price_date_not_exist;
                 END IF;

              ELSE

                 IF p_silent = 'N' THEN
                    RAISE prices_too_old;
                 END IF;

              END IF;

           END IF;



        END LOOP; -- pcur

      ELSE

        FOR pcur2 IN c_price (lv2_product_object_id, ld_price_date, lv2_parcel_key,lv2_price_object_id) LOOP

           IF pcur2.price_value is null then

              IF p_silent = 'N' THEN
                 lv2_info := 'Transaction: ' || pcur2.trans_templ_name || ', Line Item: ' || pcur2.line_item_name;
                 RAISE missing_price_value;
              END IF;

           ELSE
              IF lv2_price_src_type = 'CARGO_BASED' THEN

                 RETURN pcur2.price_value;

              ELSIF (lv2_review_period_unit = 'MONTHS' AND ld_price_date between pcur2.daytime AND Add_Months(pcur2.daytime, ln_review_period) - 1) OR
                 (lv2_review_period_unit = 'DAYS' AND ld_price_date between pcur2.daytime AND pcur2.daytime + ln_review_period - 1)  THEN

                 RETURN pcur2.price_value;

              ELSIF pcur2.daytime > ld_price_date THEN

                 IF p_silent = 'N' THEN
                    RAISE price_date_not_exist;
                 END IF;

              ELSE

                 IF p_silent = 'N' THEN
                    RAISE prices_too_old;
                 END IF;

              END IF;

           END IF;

        END LOOP; -- pcur

      END IF;

  END IF;

  END IF; -- Price Src Type

  IF p_silent = 'N' THEN
     RAISE price_not_exist;
  END IF;

  RETURN NULL;

EXCEPTION

     WHEN missing_transaction_date THEN

          Raise_Application_Error(-20000,'Point of sale date is missing: ' || p_transaction_key );

     WHEN missing_review_period THEN

          Raise_Application_Error(-20000,'Review period is missing in contract: ' || Nvl(ec_contract.object_code(p_contract_id),' ') || ' - ' || Nvl(ec_contract_version.name(p_contract_id,ec_cont_document.daytime(lv2_document_id),'<='),' ') );

     WHEN missing_price_value THEN

          Raise_Application_Error(-20000,'No price value was found on one or more price elements. ' || lv2_info || ' Contract: ' || Nvl(ec_contract.object_code(p_contract_id),' ') || ' - ' || Nvl(ec_contract_version.name(p_contract_id,ec_cont_document.daytime(lv2_document_id),'<='),' ') );

     WHEN prices_too_old THEN

          Raise_Application_Error(-20000,'Prices are too old.\nPrice date is: ' || ld_price_date || '. \n\nUpdate prices for contract: ' || Nvl(ec_contract.object_code(p_contract_id),' ') || ' - ' || Nvl(ec_contract_version.name(p_contract_id,ec_cont_document.daytime(lv2_document_id),'<='),' ') );

     WHEN price_date_not_exist THEN

          Raise_Application_Error(-20000,'Prices does not exist for this date. Create prices for contract: ' || Nvl(ec_contract.object_code(p_contract_id),' ') || ' - ' || Nvl(ec_contract_version.name(p_contract_id,ec_cont_document.daytime(lv2_document_id),'<='),' ') );

     WHEN price_not_exist THEN

          Raise_Application_Error(-20000,'Prices does not exist. Create prices for contract: ' || Nvl(ec_contract.object_code(p_contract_id),' ') || ' - ' || Nvl(ec_contract_version.name(p_contract_id,ec_cont_document.daytime(lv2_document_id),'<='),' ') );

END GetQtyPrice;




FUNCTION IsQtyTransaction(
   p_object_id VARCHAR2,
   p_trans_id    VARCHAR2
)
RETURN BOOLEAN
IS
BEGIN
    RETURN has_qty_li_p(p_trans_id);
END IsQtyTransaction;

FUNCTION GetNetGrsIndicator(
   p_object_id VARCHAR2,
   p_transaction_id VARCHAR2
)

RETURN VARCHAR2

IS

CURSOR c_li IS
    SELECT stim_value_category_code, line_item_based_type
    FROM   cont_line_item
    WHERE  object_id = p_object_id
    AND    transaction_key = p_transaction_id;

    ln_ant_net       NUMBER;
    ln_ant_grs       NUMBER;
    ln_sum_net_grs   NUMBER;

BEGIN

    ln_ant_net := 0;
    ln_ant_grs := 0;

    FOR l_rec IN c_li LOOP

        IF l_rec.STIM_VALUE_CATEGORY_CODE = 'NET_CURRENT' AND l_rec.LINE_ITEM_BASED_TYPE = 'QTY' THEN
            ln_ant_net := 1;
        ELSIF l_rec.STIM_VALUE_CATEGORY_CODE = 'GRS_CURRENT' AND l_rec.LINE_ITEM_BASED_TYPE = 'QTY' THEN
            ln_ant_grs := 2;
        END IF;

    END LOOP;  -- l_rec

    ln_sum_net_grs := ln_ant_net + ln_ant_grs;

    IF ln_sum_net_grs = 1 THEN
        RETURN 'NET';
    ELSIF ln_sum_net_grs = 2 THEN
        RETURN 'GRS';
    ELSIF ln_sum_net_grs = 3 THEN
        RETURN 'BOTH';
    ELSE
        RETURN null;
    END IF;

END GetNetGrsIndicator;


------------------------+-----------------------------------+------------------------------------+---------------------------
-- Inserts a new transaction.
-- p_vat_code: only used when vat is undefined and not interfaced in
-- p_ppa_trans_ind: indicates if this is a ppa transaction, and should allow updates from preceding transaction
-- p_li_based_type_filter: a collection of line base types indicating which line item to create.
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION InsNewTransaction(
                         p_object_id                        VARCHAR2
                        ,p_daytime                          DATE
                        ,p_document_id                      VARCHAR2
                        ,p_document_type                    VARCHAR2
                        ,p_trans_template_id                VARCHAR2
                        ,p_user                             VARCHAR2
                        ,p_trans_id                         VARCHAR2 DEFAULT NULL
                        ,p_preceding_trans_key              VARCHAR2 DEFAULT NULL
                        ,p_ifac_unique_key_1                VARCHAR2 DEFAULT NULL
                        ,p_ifac_unique_key_2                VARCHAR2 DEFAULT NULL
                        ,p_supply_from_date                 DATE DEFAULT NULL
                        ,p_supply_to_date                   DATE DEFAULT NULL
                        ,p_delivery_point_id                VARCHAR2 DEFAULT NULL
                        ,p_insert_line_items_ind            VARCHAR2 DEFAULT 'Y'
                        ,p_vat_code                         VARCHAR2 DEFAULT NULL
                        ,p_ppa_trans_ind                    VARCHAR2 DEFAULT NULL
                        ,p_ifac_price_object_id             VARCHAR2 DEFAULT NULL
                        ,p_insert_qty_line_items_only       VARCHAR2 DEFAULT 'N'
                        ,p_sales_order                      VARCHAR2 DEFAULT NULL
                     )
RETURN VARCHAR2
IS

CURSOR c_preceding_liv(cp_transaction_id VARCHAR2) IS
SELECT *
FROM cont_line_item
WHERE transaction_key = cp_transaction_id
AND line_item_based_type <> 'QTY'
AND interest_line_item_key IS NULL;

CURSOR c_liv IS
SELECT lit.object_id, litv.line_item_based_type
  FROM line_item_template lit, line_item_tmpl_version litv
 WHERE lit.object_id = litv.object_id
   AND lit.transaction_template_id = p_trans_template_id
   AND litv.daytime <= p_daytime
   AND nvl(litv.end_date, p_daytime + 1) > p_daytime
   AND EXISTS
       (SELECT 'x'
          FROM transaction_tmpl_version ttv
         WHERE ttv.object_id = lit.transaction_template_id
           AND (nvl(ttv.transaction_type, p_document_type) = p_document_type
                OR nvl(p_ppa_trans_ind,'N') = 'Y') -- if using a PPA Price they do not have to match
           AND ttv.daytime <= p_daytime
           AND nvl(ttv.end_date, p_daytime + 1) > p_daytime)
   --AND (p_li_based_type_filter is null or litv.line_item_based_type in (select column_value from table(p_li_based_type_filter)));
   AND (NVL(p_insert_qty_line_items_only, 'N') = 'N' or litv.line_item_based_type = 'QTY');


CURSOR c_doc IS
SELECT document_type, document_concept, preceding_document_key, contract_doc_id
  FROM cont_document
 WHERE document_key = p_document_id;

CURSOR c_party_company (cp_contract_id VARCHAR, cp_daytime DATE, cp_party_role VARCHAR) IS
  SELECT ps.company_id
  FROM CONTRACT_PARTY_SHARE ps
  WHERE ps.object_id = cp_contract_id
  AND ps.daytime <= cp_daytime
  AND PARTY_ROLE = cp_party_role;

CURSOR c_vendor_sale_income (cp_contract_id VARCHAR, cp_daytime DATE) IS
  SELECT object_id
  FROM company where class_name='VENDOR'
  AND company_id IN
  (SELECT company_id
  FROM contract_version
  WHERE object_id = cp_contract_id
  and daytime <= cp_daytime);

CURSOR c_vendor_purchase_cost (cp_contract_id VARCHAR, cp_daytime DATE, cp_party_role VARCHAR) IS
  SELECT ps.company_id
  FROM CONTRACT_PARTY_SHARE ps
  WHERE ps.object_id = cp_contract_id
  AND ps.daytime <= cp_daytime
  AND PARTY_ROLE = cp_party_role
  ORDER BY ec_company_version.name(ps.Company_Id, cp_daytime, '<=');

ln_cnt NUMBER;

lv2_text_line VARCHAR2(2000);
lv2_line_type VARCHAR2(32);
lv2_net_grs_ind VARCHAR2(32);

ltab_textline EcDp_Contract_Setup.t_TextLineTable := EcDp_Contract_Setup.t_TextLineTable();

lv2_trans_id VARCHAR2(32);
lv2_temp_key VARCHAR2(32);
lv2_liv_id VARCHAR2(32);
lv2_vat_id objects.object_id%TYPE;
lv2_vat_code objects.code%TYPE;

lv2_document_type VARCHAR2(200);
lv2_contract_doc_id VARCHAR2(32);
lv2_document_concept VARCHAR2(200);
lv2_preceding_doc_id VARCHAR2(200);
lv2_consignor cont_transaction.consignor%TYPE;
lv2_consignee cont_transaction.consignee%TYPE;
lrec_t cont_transaction%rowtype;
lrec_tt transaction_tmpl_version%rowtype;
lv2_price_object_id varchar2(32);
l_temp_new_li_key   VARCHAR2(32);

BEGIN

    -- Determine VAT Code
    lv2_vat_code := ec_transaction_tmpl_version.vat_code_1(p_trans_template_id, p_daytime, '<=');

    FOR Doc IN c_doc LOOP
        lv2_document_type := Doc.document_type;
        lv2_document_concept := Doc.document_concept;
        lv2_preceding_doc_id := Doc.preceding_document_key;
        lv2_contract_doc_id :=  Doc.Contract_Doc_Id;
    END LOOP;

    IF (lv2_vat_code IS NOT NULL) THEN
        lv2_vat_id := ecdp_objects.GetObjIDFromCode('VAT_CODE',lv2_vat_code);
    END IF;

    IF (p_trans_id IS NOT NULL) THEN
        lv2_trans_id := p_trans_id;
    ELSE
        Ecdp_System_Key.assignNextNumber('CONT_TRANSACTION', lv2_temp_key);
        -- insert transaction, pick id from sequence
        SELECT 'TRANS:' || to_char(lv2_temp_key)
        INTO lv2_trans_id
        FROM DUAL;
    END IF;


    -- Get Default Consignor / Consignee
    IF ec_contract_version.financial_code(p_object_id, p_daytime, '<=') IN ('SALE','TA_INCOME','JOU_ENT') THEN
       FOR rsPS IN c_vendor_sale_income(p_object_id, p_daytime) LOOP
       lv2_consignor := ec_company_version.name(rsPS.object_Id, p_daytime, '<=');
       END LOOP;
    END IF;

    IF ec_contract_version.financial_code(p_object_id, p_daytime, '<=') IN ('PURCHASE','TA_COST') THEN
       FOR rsPS IN c_vendor_purchase_cost(p_object_id, p_daytime,'VENDOR') LOOP
       lv2_consignor := ec_company_version.name(rsPS.Company_Id, p_daytime, '<=');
       EXIT;
       END LOOP;
    END IF;

    FOR rsPS IN c_party_company(p_object_id, p_daytime, 'CUSTOMER') LOOP
      lv2_consignee := ec_company_version.name(rsPS.Company_Id, p_daytime, '<=');
    END LOOP;


    lrec_tt := ec_transaction_tmpl_version.row_by_pk(p_trans_template_id, p_daytime, '<=');
    lv2_price_object_id := nvl(lrec_tt.price_object_id, p_ifac_price_object_id);

   INSERT INTO cont_transaction
     (object_id,
      transaction_key,
      preceding_trans_key,
      document_key,
      trans_template_id,
      price_object_id,
      price_concept_code,
      product_id,
      product_code,
      stream_item_id,
      dist_code,
      dist_type,
      dist_object_type,
      vat_code,
      vat_rate,
      vat_description,
      vat_legal_text,
      value_adjustment,
      name,
      description,
      ex_pricing_booking,
      ex_inv_pricing_booking,
      ex_pricing_memo,
      ex_inv_pricing_memo,
      ex_booking_local,
      ex_booking_group,
      ex_inv_booking_local,
      ex_inv_booking_group,
      ex_pricing_booking_date,
      ex_pricing_memo_date,
      ex_booking_local_date,
      ex_booking_group_date,
      product_description,
      product_node_item_id,
      destination_country_id,
      origin_country_id,
      sort_order,
      transaction_type,
      transaction_scope,
      dist_split_type,
      split_method,
      SOURCE_SPLIT_METHOD,
      loading_port_id,
      loading_port_code,
      discharge_port_id,
      discharge_port_code,
      delivery_point_id,
      delivery_point_code,
      entry_point_id,
      entry_point_code,
      supply_from_date,
      supply_to_date,
      loading_date_commenced,
      loading_date_completed,
      delivery_date_commenced,
      delivery_date_completed,
      posd_base_code,
      price_date_base_code,
      bl_date_base_code,
      daytime,
      price_src_type,
      consignor,
      consignee,
      qty_type,
      ppa_trans_code,
      uom1_print_decimals,
      uom2_print_decimals,
      uom3_print_decimals,
      uom4_print_decimals,
      pricing_currency_id,
      pricing_currency_code,
      ex_pricing_booking_id,
      ex_pricing_booking_ts,
      ex_pricing_booking_dbc,
      ex_pricing_memo_id,
      ex_pricing_memo_ts,
      ex_pricing_memo_dbc,
      ex_booking_local_id,
      ex_booking_local_ts,
      ex_booking_local_dbc,
      ex_booking_group_id,
      ex_booking_group_ts,
      ex_booking_group_dbc,
      ifac_unique_key_1,
      ifac_unique_key_2,
      ifac_tt_conn_code,
      sales_order,
      pricing_booking_label_1,
      pricing_memo_label_1,
      booking_local_label_1,
      booking_group_label_1,
      pricing_booking_label_2,
      booking_local_label_2,
      booking_group_label_2,
      pricing_memo_label_2,
      value_1,
      value_2,
      value_3,
      value_4,
      value_5,
      value_6,
      value_7,
      value_8,
      value_9,
      value_10,
      text_1,
      text_2,
      text_3,
      text_4,
      text_5,
      text_6,
      text_7,
      text_8,
      text_9,
      text_10,
      date_1,
      date_2,
      date_3,
      date_4,
      date_5,
      created_by)
   VALUES
     (p_object_id,
      lv2_trans_id,
      p_preceding_trans_key,
      p_document_id,
      p_trans_template_id,
      lv2_price_object_id,
      nvl(lrec_tt.price_concept_code, ec_product_price.price_concept_code(p_ifac_price_object_id)),
      nvl(lrec_tt.product_id, ec_product_price.product_id(p_ifac_price_object_id)),
      ec_product.object_code(nvl(lrec_tt.product_id, ec_product_price.product_id(p_ifac_price_object_id))),
      lrec_tt.stream_item_id,
      decode(lrec_tt.use_si_ind,'Y',NULL,lrec_tt.Dist_Code),
      decode(lrec_tt.use_si_ind,'Y',NULL,lrec_tt.dist_type),
      decode(lrec_tt.use_si_ind,'Y',NULL,lrec_tt.dist_object_type),
      lv2_vat_code,
      ec_vat_code_version.rate(lv2_vat_id, p_daytime, '<='),
      ec_vat_code_version.comments(lv2_vat_id, p_daytime, '<='),
      ec_vat_code_version.legal_text(lv2_vat_id, p_daytime, '<='),
      lrec_tt.value_adjustment,
      lrec_tt.name,
      ec_transaction_template.description(p_trans_template_id),
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      ec_product_nodeitem_version.name(lrec_tt.product_node_item_id,p_daytime,'<='),
      lrec_tt.product_node_item_id,
      nvl(lrec_tt.country_id, GetDestinationCountryForTrans(p_object_id, lv2_trans_id, lrec_tt.transaction_scope, NVL(p_delivery_point_id,lrec_tt.delivery_point_id), lrec_tt.discharge_port_id, p_daytime)), -- export country id
      nvl(lrec_tt.origin_country_id, GetOriginCountryForTrans(p_object_id, lv2_trans_id, lrec_tt.transaction_scope, NVL(p_delivery_point_id,lrec_tt.delivery_point_id), lrec_tt.loading_port_id, p_daytime)), -- origin country id
      ec_transaction_template.sort_order(p_trans_template_id),
      lrec_tt.transaction_type,
      lrec_tt.transaction_scope,
      lrec_tt.dist_split_type,
      lrec_tt.dist_split_type,
      lrec_tt.SOURCE_SPLIT_METHOD,
      lrec_tt.loading_port_id,
      ec_port.object_code(lrec_tt.loading_port_id),
      lrec_tt.discharge_port_id,
      ec_port.object_code(lrec_tt.discharge_port_id),
      NVL(p_delivery_point_id,lrec_tt.delivery_point_id),
      ec_delivery_point.object_code(NVL(p_delivery_point_id,lrec_tt.delivery_point_id)),
      lrec_tt.entry_point_id,
      ec_delivery_point.object_code(lrec_tt.entry_point_id),
      p_supply_from_date,
      p_supply_to_date,
      NULL,
      NULL,
      NULL,
      NULL,
      lrec_tt.posd_base_code,
      lrec_tt.price_date_base_code,
      lrec_tt.bl_date_base_code,
      p_daytime,
      lrec_tt.price_src_type,
      lv2_consignor,
      lv2_consignee,
      lrec_tt.req_qty_type,
      CASE WHEN NVL(p_ppa_trans_ind,'N') = 'Y' THEN 'PPA_QTY' END,
      lrec_tt.uom1_print_decimals,
      lrec_tt.uom2_print_decimals,
      lrec_tt.uom3_print_decimals,
      lrec_tt.uom4_print_decimals,
      lrec_tt.pricing_currency_id,
      ec_currency.object_code(lrec_tt.pricing_currency_id), --pricing_currency_code
      lrec_tt.ex_pricing_booking_id,
      lrec_tt.ex_pricing_booking_TS,
      lrec_tt.ex_pricing_booking_DBC,
      lrec_tt.ex_pricing_memo_id,
      lrec_tt.ex_pricing_memo_TS,
      lrec_tt.ex_pricing_memo_DBC,
      lrec_tt.ex_booking_local_id,
      lrec_tt.ex_booking_local_TS,
      lrec_tt.ex_booking_local_DBC,
      lrec_tt.ex_booking_group_id,
      lrec_tt.ex_booking_group_TS,
      lrec_tt.ex_booking_group_DBC,
      p_ifac_unique_key_1,
      p_ifac_unique_key_2,
      lrec_tt.ifac_tt_conn_code,
      p_sales_order,
      GetPricingBookingLabel(p_document_id, p_daytime, p_trans_template_id),
      GetPricingMemoLabel(p_document_id, p_daytime, p_trans_template_id),
      GetBookingLocalLabel(p_document_id, p_daytime),
      GetBookingGroupLabel(p_document_id, p_daytime),
      GetPricingBookingCode(p_document_id, p_daytime, p_trans_template_id),
	  GetBookingLocalCode(p_document_id, p_daytime),
	  GetBookingGroupCode(p_document_id, p_daytime),
      GetPricingMemoCode(p_document_id, p_daytime, p_trans_template_id),
      lrec_tt.value_1,
      lrec_tt.value_2,
      lrec_tt.value_3,
      lrec_tt.value_4,
      lrec_tt.value_5,
      lrec_tt.value_6,
      lrec_tt.value_7,
      lrec_tt.value_8,
      lrec_tt.value_9,
      lrec_tt.value_10,
      lrec_tt.text_1,
      lrec_tt.text_2,
      lrec_tt.text_3,
      lrec_tt.text_4,
      lrec_tt.text_5,
      lrec_tt.text_6,
      lrec_tt.text_7,
      lrec_tt.text_8,
      lrec_tt.text_9,
      lrec_tt.text_10,
      lrec_tt.date_1,
      lrec_tt.date_2,
      lrec_tt.date_3,
      lrec_tt.date_4,
      lrec_tt.date_5,
      p_user);


    lrec_t := ec_cont_transaction.row_by_pk(lv2_trans_id);
    --Set Transaction Sort Order for the newly created Transaction
    SetTransSortOrder(lrec_t, TRUE, p_user);
    --Set the Transaction Name for the newly created Transaction
    SetTransactionName(lrec_t,p_user,NULL);

    lv2_text_line := ec_transaction_tmpl_version.trans_text_before(p_trans_template_id, p_daytime, '<=');
    lv2_line_type := 'TRANS_TEXT_BEFORE';
    IF lv2_text_line IS NOT NULL THEN
        -- this call will return the text string in proper columns and lines
        ltab_textline := EcDp_Contract_Setup.GetTextLineTableFromText(lv2_text_line);

        FOR ln_cnt IN 1..ltab_textline.last LOOP
            INSERT INTO cont_trans_comments
              (object_id,transaction_key,trans_comments_id,cont_trans_comments_type,sort_order,column_1,created_date,created_by,record_status)
            VALUES
              (p_object_id,lv2_trans_id,Substr(lv2_trans_id || 'TRANS_T_B_' || to_char(ln_cnt),1,30),lv2_line_type,ln_cnt * 100,ltab_textline(ln_cnt).col_1_text,Ecdp_Timestamp.getCurrentSysdate,p_user,'P');
        END LOOP;
    END IF;

    lv2_text_line := ec_transaction_tmpl_version.trans_text_after(p_trans_template_id, p_daytime, '<=');
    lv2_line_type := 'TRANS_TEXT_AFTER';
    IF lv2_text_line IS NOT NULL THEN
        -- this call will return the text string in proper columns and lines
        ltab_textline := EcDp_Contract_Setup.GetTextLineTableFromText(lv2_text_line);

        FOR ln_cnt IN 1..ltab_textline.last LOOP
            INSERT INTO cont_trans_comments
              (object_id,transaction_key,trans_comments_id,cont_trans_comments_type,sort_order,column_1,created_date,created_by,record_status)
            VALUES
              (p_object_id,lv2_trans_id,Substr(lv2_trans_id || 'TRANS_T_A_' || to_char(ln_cnt),1,30),lv2_line_type,ln_cnt * 100,ltab_textline(ln_cnt).col_1_text,Ecdp_Timestamp.getCurrentSysdate,p_user,'P');
        END LOOP;
    END IF;

    IF nvl(p_insert_line_items_ind,'Y') = 'Y' THEN -- defaults to Y, must be explicitly set to N to disable line item insert
      IF (p_trans_id IS NULL) THEN
          -- insert any line items from line_item_template
          FOR LIVCur IN c_liv LOOP

              IF (NVL(p_ppa_trans_ind,'N') = 'Y' AND LIVCur.line_item_based_type = 'INTEREST') THEN -- interest line items for PPA transactions are handled specifically in EcDp_PPA_Price and EcDp_Document_Gen.
                NULL;
              ELSE
                lv2_liv_id := EcDp_Line_Item.InsNewLineItem(
                    p_object_id, p_daytime, p_document_id, lv2_trans_id, LIVCur.object_id, p_user, p_creation_method => ecdp_revn_ft_constants.c_mtd_auto_gen);
              END IF;
          END LOOP;

          -- This procedure is used to generate distribution for reduced config
          apply_po_on_trans_rc_p(lv2_trans_id, lv2_price_object_id, p_user);
      END IF;
    END IF;


    -- Create Trans Qty rows if this is a transaction template set up with price object AND there are Qty line item templates
    -- Create Trans Qty rows if this is a transaction template set up without price object.
    --   (Qty line items will then be created based on price concept's price elements.)
    IF (IsQtyTransaction(p_object_id, lv2_trans_id) AND lrec_tt.price_object_id IS NOT NULL) OR
        IsReducedConfig(NULL, NULL, lrec_tt.object_id, lrec_t.transaction_key, lrec_t.daytime) THEN

        lv2_net_grs_ind := GetNetGrsIndicator(p_object_id , lv2_trans_id);

        INSERT INTO cont_transaction_qty
          (object_id,
           transaction_key,
           daytime,
           net_grs_indicator,
           report_net_ind,
           report_grs_ind,
           uom1_code,
           uom2_code,
           uom3_code,
           uom4_code,
           created_by)
        VALUES
          (p_object_id,
           lv2_trans_id,
           lrec_t.daytime,
           lv2_net_grs_ind,
           decode(lv2_net_grs_ind, 'BOTH', 'Y', 'NET', 'Y', 'N'),
           decode(lv2_net_grs_ind, 'BOTH', 'Y', 'GRS', 'Y', 'N'),
           lrec_tt.uom1_code,
           lrec_tt.uom2_code,
           lrec_tt.uom3_code,
           lrec_tt.uom4_code,
           p_user);

    END IF;

    -- update if this transaction is part of a dependent document
    IF lv2_document_concept LIKE 'DEPENDENT%'
        OR lv2_document_concept IN ('REALLOCATION','MULTI_PERIOD','RECONCILIATION')
        OR NVL(p_ppa_trans_ind,'N') = 'Y' THEN

        IF lrec_t.preceding_trans_key IS NOT NULL THEN
           UpdFromPrecedingTrans(lrec_t.preceding_trans_key,lv2_trans_id,p_user);

             -- Don't want to copy non-qty line items for PPA transactions
             IF (lv2_document_concept IN ('DEPENDENT','REALLOCATION','DEPENDENT_PREV_MTH_CORR')
                 --AND p_insert_qty_line_items_only != 'Y' -- this is only used for processing non-qty ifacs
                 ) THEN
                 -- Loop line items
                 FOR LineItems IN c_preceding_liv(lrec_t.preceding_trans_key) LOOP
                     -- Insert the "old" lineitems as normal lineitems on the new transaction
                     lv2_liv_id := EcDp_Line_Item.CopyLineItem(p_object_id, LineItems.Line_Item_key, p_daytime, lv2_trans_id);

                     -- insert compounding lines
                     IF LineItems.Line_Item_Based_Type = ecdp_revn_ft_constants.li_btype_interest THEN
                         FOR line_item_meta IN ecdp_line_item.c_get_componding_interest_li(LineItems.Interest_Group, LineItems.Line_Item_key) LOOP
                             l_temp_new_li_key := EcDp_Line_Item.CopyLineItem(p_object_id, line_item_meta.Line_Item_key, p_daytime, lv2_trans_id);

                             UPDATE cont_line_item
                             SET interest_line_item_key = lv2_liv_id
                             WHERE line_item_key = l_temp_new_li_key;
                         END LOOP;
                     END IF;
                 END LOOP;
             END IF;
        END IF;
    END IF;

    UpdPercentageLineItem(lv2_trans_id, p_user);

    RETURN lv2_trans_id;

END InsNewTransaction;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION ReverseTransaction
(   p_object_id VARCHAR2,
    p_daytime DATE,
    p_document_id VARCHAR2, -- the new document
    p_transaction_id VARCHAR2, -- the transaction to reverse
    p_user VARCHAR2,
    p_name_prefix VARCHAR2 DEFAULT 'Reversal of: ',
    p_force_reversal VARCHAR2 DEFAULT 'N'
) RETURN VARCHAR2 -- returns the transaction_id of the reversal

IS

CURSOR c_li_qty(pc_transaction_id VARCHAR2) IS
SELECT *
FROM cont_line_item
WHERE transaction_key = pc_transaction_id
AND line_item_based_type = 'QTY'
;

CURSOR c_li_interest(pc_transaction_id VARCHAR2) IS
SELECT *
FROM cont_line_item
WHERE transaction_key = pc_transaction_id
AND line_item_based_type = 'INTEREST'
;

CURSOR c_li_other(pc_transaction_id VARCHAR2) IS
SELECT *
FROM cont_line_item
WHERE  transaction_key = pc_transaction_id
AND line_item_based_type NOT IN ('QTY','INTEREST')
ORDER BY line_item_key
;

CURSOR c_li_dist(pc_line_item_key VARCHAR2) IS
SELECT clid.*
FROM cont_line_item_dist clid
WHERE clid.object_id = p_object_id
AND clid.line_item_key = pc_line_item_key;


lrec_trans 		cont_transaction%ROWTYPE;
lrec_doc 		cont_document%ROWTYPE;
lrec_trans_qty 		cont_transaction_qty%ROWTYPE;
lv2_new_trans_id 	cont_transaction.transaction_key%TYPE;
lv2_temp_key 		VARCHAR2(32);
lv2_new_liv_id 		cont_line_item.line_item_key%TYPE;
lv2_prev_li_int_group 	cont_line_item.interest_group%TYPE;
lv2_curr_li_int_group 	cont_line_item.interest_group%TYPE;
lv2_interest_parent_li 	cont_line_item.line_item_key%TYPE;
lv2_doc_concept_new 	VARCHAR2(32);
lv2_ignore_vat      	VARCHAR2(1) := 'N';

BEGIN
    lrec_trans := ec_cont_transaction.row_by_pk(p_transaction_id);
    lrec_doc := ec_cont_document.row_by_pk(lrec_trans.document_key);
    -- Preceeding Document
    lv2_doc_concept_new := ec_cont_document.document_concept(p_document_id);

    lrec_trans_qty := ec_cont_transaction_qty.row_by_pk(p_transaction_id);

    IF ec_ctrl_system_attribute.attribute_text(p_daytime,'VAT_ON_ACCRUALS','<=') = 'N' AND
       lrec_doc.status_code = 'FINAL' AND
       ec_cont_document.status_code(p_document_id) = 'ACCRUAL' THEN
       lv2_ignore_vat := 'Y';
    END IF;

    IF (lrec_doc.document_level_code <> 'BOOKED') AND ec_contract_doc_version.doc_concept_code(lrec_doc.contract_doc_id,p_daytime,'<=') != 'MULTI_PERIOD' THEN
          Raise_Application_Error(-20000,'Can not reverse a transaction for a document which is not booked. Transaction : ' || p_transaction_id);
    END IF;


    -- We will not reverse a transaction which is already a reversal
    IF (lrec_trans.reversal_ind = 'Y' AND p_force_reversal <> 'Y') THEN
       RETURN NULL;
    END IF;

    Ecdp_System_Key.assignNextNumber('CONT_TRANSACTION', lv2_temp_key);
    SELECT 'TRANS:' || to_char(lv2_temp_key)
    INTO lv2_new_trans_id
    FROM DUAL;


    INSERT INTO cont_transaction (
         OBJECT_ID
        ,TRANSACTION_KEY
        ,DAYTIME
        ,DOCUMENT_KEY
        ,PRECEDING_TRANS_KEY
        ,REVERSED_TRANS_KEY
        ,REVERSAL_IND
        ,PRODUCT_ID
        ,PRODUCT_CODE
        ,PRODUCT_DESCRIPTION
        ,STREAM_ITEM_ID
        ,PRICE_CONCEPT_CODE
        ,PRICE_OBJECT_ID
        ,SORT_ORDER
        ,SOURCE_SPLIT_METHOD
        ,LOADING_PORT_ID
        ,DISCHARGE_PORT_ID
        ,DELIVERY_POINT_ID
        ,DESTINATION_COUNTRY_ID
        ,ORIGIN_COUNTRY_ID
        ,ENTRY_POINT_ID
        ,VALUE_ADJUSTMENT
        ,NAME
        ,DESCRIPTION
        ,COMMENTS
        ,LOADING_DATE_COMMENCED
        ,LOADING_DATE_COMPLETED
        ,DELIVERY_DATE_COMMENCED
        ,DELIVERY_DATE_COMPLETED
        ,POSD_BASE_CODE
        ,CONSIGNEE
        ,DELIVERY_PLANT_ID
        ,DELIVERY_PLANT_CODE
        ,CONSIGNOR
        ,CARGO_NO
        ,CARGO_NAME
        ,PARCEL_NO
        ,PARCEL_NAME
        ,QTY_TYPE
        ,SALES_ORDER
        ,API
        ,RVP
        ,BS_W
        ,SALT
        ,GCV
        ,WOBBE
        ,EX_PRICING_BOOKING
        ,EX_PRICING_MEMO
        ,EX_INV_PRICING_BOOKING
        ,EX_INV_PRICING_MEMO
        ,EX_BOOKING_LOCAL
        ,EX_BOOKING_GROUP
        ,EX_INV_BOOKING_LOCAL
        ,EX_INV_BOOKING_GROUP
        ,EX_PRICING_BOOKING_DATE
        ,EX_PRICING_MEMO_DATE
        ,EX_BOOKING_LOCAL_DATE
        ,EX_BOOKING_GROUP_DATE
        ,UNIT_PRICE_BOOKING
        ,SUPPLY_FROM_DATE
        ,SUPPLY_TO_DATE
        ,VAT_CODE
        ,VAT_RATE
        ,VAT_DESCRIPTION
        ,VAT_LEGAL_TEXT
        ,TRANSACTION_DATE
        ,TRANSACTION_TYPE
        ,DIST_SPLIT_TYPE
        ,CARRIER_ID
        ,PRODUCT_NODE_ITEM_ID
        ,PRICING_CURRENCY_ID
        ,PRICING_CURRENCY_CODE
        ,PRICING_PERIOD_FROM_DATE
        ,PRICING_PERIOD_TO_DATE
        ,TRANS_TEMPLATE_ID
        ,CONTRACT_DATE
        ,TRANSACTION_SCOPE
        ,CNTR_DURATION_FROM_DATE
        ,CNTR_DURATION_TO_DATE
        ,PRICE_SRC_TYPE
        ,PRICE_DATE
        ,BL_DATE
        ,uom1_print_Decimals
        ,uom2_print_Decimals
        ,uom3_print_Decimals
        ,uom4_print_Decimals
        ,EX_PRICING_BOOKING_ID
        ,EX_PRICING_BOOKING_TS
        ,EX_PRICING_BOOKING_DBC
        ,EX_PRICING_MEMO_ID
        ,EX_PRICING_MEMO_TS
        ,EX_PRICING_MEMO_DBC
        ,EX_BOOKING_LOCAL_ID
        ,EX_BOOKING_LOCAL_TS
        ,EX_BOOKING_LOCAL_DBC
        ,EX_BOOKING_GROUP_ID
        ,EX_BOOKING_GROUP_TS
        ,EX_BOOKING_GROUP_DBC
        ,IFAC_UNIQUE_KEY_1
        ,IFAC_UNIQUE_KEY_2
        ,IFAC_TT_CONN_CODE
        ,price_date_base_code
        ,split_method
        ,dist_code
        ,dist_type
        ,dist_object_type
        ,pricing_booking_label_1
        ,pricing_memo_label_1
        ,booking_local_label_1
        ,booking_group_label_1
        ,pricing_booking_label_2
        ,booking_local_label_2
        ,booking_group_label_2
        ,pricing_memo_label_2
        ,date_1
        ,date_2
        ,date_3
        ,date_4
        ,date_5
        ,value_1
        ,value_2
        ,value_3
        ,value_4
        ,value_5
        ,value_6
        ,value_7
        ,value_8
        ,value_9
        ,value_10
        ,text_1
        ,text_2
        ,text_3
        ,text_4
        ,text_5
        ,text_6
        ,text_7
        ,text_8
        ,text_9
        ,text_10
        ,CREATED_BY
    ) VALUES (
         p_object_id
        ,lv2_new_trans_id                         -- the new transaction
        ,p_daytime
        ,p_document_id                            -- the new document
        ,NULL -- Preceding must be set to NULL for reversal transactions
        ,p_transaction_id                         -- the old transaction as reversed
        ,'Y'
        ,lrec_trans.product_id
        ,lrec_trans.product_code
        ,lrec_trans.product_description
        ,lrec_trans.stream_item_id
        ,lrec_trans.price_concept_code
        ,lrec_trans.price_object_id
        ,NVL(lrec_trans.sort_order,0) + 1
        ,lrec_trans.SOURCE_SPLIT_METHOD
        ,lrec_trans.loading_port_id
        ,lrec_trans.discharge_port_id
        ,lrec_trans.delivery_point_id
        ,lrec_trans.destination_country_id
        ,lrec_trans.origin_country_id
        ,lrec_trans.entry_point_id
        ,lrec_trans.value_adjustment
        ,p_name_prefix || lrec_trans.name
        ,lrec_trans.description
        ,lrec_trans.comments
        ,lrec_trans.loading_date_commenced
        ,lrec_trans.loading_date_completed
        ,lrec_trans.delivery_date_commenced
        ,lrec_trans.delivery_date_completed
        ,lrec_trans.posd_base_code
        ,lrec_trans.consignee
        ,lrec_trans.delivery_plant_id
        ,lrec_trans.delivery_plant_code
        ,lrec_trans.consignor
        ,lrec_trans.cargo_no
        ,lrec_trans.cargo_name
        ,lrec_trans.parcel_no
        ,lrec_trans.parcel_name
        ,lrec_trans.qty_type
        ,lrec_trans.sales_order
        ,lrec_trans.api
        ,lrec_trans.rvp
        ,lrec_trans.bs_w
        ,lrec_trans.salt
        ,lrec_trans.gcv
        ,lrec_trans.wobbe
        ,lrec_trans.ex_pricing_booking
        ,lrec_trans.ex_pricing_memo
        ,lrec_trans.ex_inv_pricing_booking
        ,lrec_trans.ex_inv_pricing_memo
        ,lrec_trans.ex_booking_local
        ,lrec_trans.ex_booking_group
        ,lrec_trans.ex_inv_booking_local
        ,lrec_trans.ex_inv_booking_group
        ,lrec_trans.ex_pricing_booking_date
        ,lrec_trans.ex_pricing_memo_date
        ,lrec_trans.ex_booking_local_date
        ,lrec_trans.ex_booking_group_date
        ,lrec_trans.unit_price_booking
        ,lrec_trans.supply_from_date
        ,lrec_trans.supply_to_date
        ,case lv2_ignore_vat when 'N' then lrec_trans.vat_code else null end
        ,case lv2_ignore_vat when 'N' then lrec_trans.vat_rate else 0 end
        ,lrec_trans.vat_description
        ,lrec_trans.vat_legal_text
        ,lrec_trans.transaction_date
        ,lrec_trans.transaction_type
        ,lrec_trans.dist_split_type
        ,lrec_trans.carrier_id
        ,lrec_trans.product_node_item_id
        ,lrec_trans.pricing_currency_id
        ,lrec_trans.pricing_currency_code
        ,lrec_trans.pricing_period_from_date
        ,lrec_trans.pricing_period_to_date
        ,lrec_trans.trans_template_id
        ,lrec_trans.contract_date
        ,lrec_trans.transaction_scope
        ,lrec_trans.cntr_duration_from_date
        ,lrec_trans.cntr_duration_to_date
        ,lrec_trans.Price_Src_Type
        ,lrec_trans.price_date
        ,lrec_trans.bl_date
        ,lrec_trans.uom1_print_decimals
        ,lrec_trans.uom2_print_decimals
        ,lrec_trans.uom3_print_decimals
        ,lrec_trans.uom4_print_decimals
        ,lrec_trans.ex_pricing_booking_id
        ,lrec_trans.ex_pricing_booking_ts
        ,lrec_trans.ex_pricing_booking_dbc
        ,lrec_trans.ex_pricing_memo_id
        ,lrec_trans.ex_pricing_memo_ts
        ,lrec_trans.ex_pricing_memo_dbc
        ,lrec_trans.ex_booking_local_id
        ,lrec_trans.ex_booking_local_ts
        ,lrec_trans.ex_booking_local_dbc
        ,lrec_trans.ex_booking_group_id
        ,lrec_trans.ex_booking_group_ts
        ,lrec_trans.ex_booking_group_dbc
        ,lrec_trans.ifac_unique_key_1
        ,lrec_trans.ifac_unique_key_2
        ,lrec_trans.ifac_tt_conn_code
        ,lrec_trans.price_date_base_code
        ,lrec_trans.split_method
        ,lrec_trans.dist_code
        ,lrec_trans.dist_type
        ,lrec_trans.dist_object_type
        ,GetPricingBookingLabel(p_document_id, p_daytime, lrec_trans.trans_template_id)
        ,GetPricingMemoLabel(p_document_id, p_daytime, lrec_trans.trans_template_id)
        ,GetBookingLocalLabel(p_document_id, p_daytime)
        ,GetBookingGroupLabel(p_document_id, p_daytime)
        ,GetPricingBookingCode(p_document_id, p_daytime, lrec_trans.trans_template_id)
        ,GetBookingLocalCode(p_document_id, p_daytime)
        ,GetBookingGroupCode(p_document_id, p_daytime)
        ,GetPricingMemoCode(p_document_id, p_daytime, lrec_trans.trans_template_id)
        ,lrec_trans.date_1
        ,lrec_trans.date_2
        ,lrec_trans.date_3
        ,lrec_trans.date_4
        ,lrec_trans.date_5
        ,lrec_trans.value_1
        ,lrec_trans.value_2
        ,lrec_trans.value_3
        ,lrec_trans.value_4
        ,lrec_trans.value_5
        ,lrec_trans.value_6
        ,lrec_trans.value_7
        ,lrec_trans.value_8
        ,lrec_trans.value_9
        ,lrec_trans.value_10
        ,lrec_trans.text_1
        ,lrec_trans.text_2
        ,lrec_trans.text_3
        ,lrec_trans.text_4
        ,lrec_trans.text_5
        ,lrec_trans.text_6
        ,lrec_trans.text_7
        ,lrec_trans.text_8
        ,lrec_trans.text_9
        ,lrec_trans.text_10
        ,p_user
    );

    -- insert into CONT_TRANS_COMMENTS
    INSERT INTO cont_trans_comments (
        object_id,
        transaction_key,
        trans_comments_id,
        cont_trans_comments_type,
        sort_order,
        column_1,
        created_by)
    SELECT
        object_id,
        lv2_new_trans_id,
        REPLACE(trans_comments_id,p_transaction_id,lv2_new_trans_id),
        cont_trans_comments_type,
        sort_order,
        column_1,
        p_user
    FROM cont_trans_comments
    WHERE object_id = p_object_id
    AND transaction_key = p_transaction_id;

    -- records for qty
    INSERT INTO cont_transaction_qty
        (object_id
        ,transaction_key
        ,daytime
        ,net_grs_indicator
        ,report_net_ind
        ,report_grs_ind
        ,uom1_code
        ,uom2_code
        ,uom3_code
        ,uom4_code
        ,pre_uom1_code
        ,pre_uom2_code
        ,pre_uom3_code
        ,pre_uom4_code
        ,created_by)
    SELECT
         p_object_id
        ,lv2_new_trans_id
        ,ec_cont_transaction.daytime(lv2_new_trans_id)
        ,net_grs_indicator
        ,report_net_ind
        ,report_grs_ind
        ,uom1_code
        ,uom2_code
        ,uom3_code
        ,uom4_code
        ,pre_uom1_code
        ,pre_uom2_code
        ,pre_uom3_code
        ,pre_uom4_code
        ,p_user
    FROM cont_transaction_qty
    WHERE object_id = p_object_id
    AND transaction_key = p_transaction_id;


    -- insert any qty based line item.
    FOR LIQTY IN c_li_qty(p_transaction_id) LOOP
        Ecdp_System_Key.assignNextNumber('CONT_LINE_ITEM', lv2_temp_key);
        SELECT 'LI:' || to_char(lv2_temp_key)
        INTO lv2_new_liv_id
        FROM DUAL;

        INSERT INTO cont_line_item (
             object_id
            ,line_item_key
            ,daytime
            ,transaction_key
            ,name
            ,description
            ,comments
            ,price_concept_code
            ,price_element_code
            ,price_object_id
            ,stream_item_id
            ,stim_value_category_code
            ,sort_order
            ,report_category_code
            ,line_item_value
            ,unit_price
            ,unit_price_unit
            ,free_unit_qty
            ,contribution_factor
            ,move_qty_to_vo_ind
            ,value_adjustment
            ,uom1_code
            ,uom2_code
            ,uom3_code
            ,uom4_code
            ,document_key
            ,line_item_based_type
            ,line_item_type
            ,vat_code
            ,vat_rate
            ,node_id
            ,source_line_item_key
            ,line_item_template_id
            ,dist_method
            ,creation_method
            ,ifac_li_conn_code
            ,created_by
        ) VALUES (
             LIQTY.object_id
            ,lv2_new_liv_id             -- new line item id
            ,p_daytime
            ,lv2_new_trans_id           -- new transaction_id
            ,p_name_prefix || LIQTY.name
            ,LIQTY.description
            ,LIQTY.comments
            ,LIQTY.price_concept_code
            ,LIQTY.price_element_code
            ,LIQTY.price_object_id
            ,LIQTY.stream_item_id
            ,LIQTY.stim_value_category_code
            ,LIQTY.sort_order
            ,LIQTY.report_category_code
            ,LIQTY.line_item_value
            ,LIQTY.unit_price
            ,LIQTY.unit_price_unit
            ,LIQTY.free_unit_qty
            ,LIQTY.contribution_factor
            ,LIQTY.move_qty_to_vo_ind
            ,LIQTY.value_adjustment
            ,LIQTY.uom1_code
            ,LIQTY.uom2_code
            ,LIQTY.uom3_code
            ,LIQTY.uom4_code
            ,p_document_id                  -- new document id
            ,LIQTY.line_item_based_type
            ,LIQTY.line_item_type
            ,case lv2_ignore_vat when 'N' then LIQTY.vat_code else NULL end
            ,case lv2_ignore_vat when 'N' then LIQTY.vat_rate else 0 end
            ,LIQTY.node_id
            ,LIQTY.line_item_key            -- the old one as source
            ,LIQTY.line_item_template_id
            ,LIQTY.dist_method
            ,ecdp_revn_ft_constants.c_mtd_auto_gen
            ,LIQTY.ifac_li_conn_code
            ,p_user                      -- new user
        );


        FOR LiDi IN c_li_dist(LIQTY.line_item_key) LOOP


            INSERT INTO cont_line_item_dist (
                 object_id
                ,line_item_key
                ,dist_id
                ,daytime
                ,stream_item_id
                ,node_id
                ,name
                ,description
                ,comments
                ,sort_order
                ,report_category_code
                ,line_item_value
                ,value_adjustment
                ,contribution_factor
                ,move_qty_to_vo_ind
                ,uom1_code
                ,uom2_code
                ,uom3_code
                ,uom4_code
                ,created_by
                ,document_key
                ,transaction_key
                ,split_share
                ,split_share_qty2
                ,split_share_qty3
                ,split_share_qty4
                ,alloc_stream_item_id
                ,price_concept_code
                ,price_element_code
                ,stim_value_category_code
                ,line_item_type
                ,line_item_based_type
                ,vat_code
                ,vat_rate
                ,profit_centre_id
            ) SELECT
                 object_id
                ,lv2_new_liv_id          -- new line item id
                ,dist_id
                ,p_daytime
                ,stream_item_id
                ,node_id
                ,name
                ,description
                ,comments
                ,sort_order
                ,report_category_code
                ,line_item_value
                ,value_adjustment
                ,contribution_factor
                ,move_qty_to_vo_ind
                ,uom1_code
                ,uom2_code
                ,uom3_code
                ,uom4_code
                ,p_user                   -- the user
                ,p_document_id            -- new doc id
                ,lv2_new_trans_id         -- new trans id
                ,split_share
                ,split_share_qty2
                ,split_share_qty3
                ,split_share_qty4
                ,alloc_stream_item_id
                ,price_concept_code
                ,price_element_code
                ,stim_value_category_code
                ,line_item_type
                ,line_item_based_type
                ,case lv2_ignore_vat when 'N' then vat_code else NULL end
                ,case lv2_ignore_vat when 'N' then vat_rate else 0 end
                ,profit_centre_id
            FROM  cont_line_item_dist clid
            WHERE clid.line_item_key = LiDi.line_item_key
            AND   clid.dist_id = LiDi.Dist_Id
            ;


             -- Insert records for Company split
            INSERT INTO cont_li_dist_company (
                   object_id
                   ,line_item_key
                   ,stream_item_id
                   ,vendor_id
                   ,customer_id
                   ,daytime
                   ,name
                   ,dist_id
                   ,node_id
                   ,created_by
                   ,document_key
                   ,transaction_key
                   ,vendor_share
                   ,vendor_share_qty2
                   ,vendor_share_qty3
                   ,vendor_share_qty4
                   ,customer_share
                   ,report_category_code
                   ,line_item_value
                   ,value_adjustment
                   ,contribution_factor
                   ,move_qty_to_vo_ind
                   ,uom1_code
                   ,uom2_code
                   ,uom3_code
                   ,uom4_code
                   ,split_share
                   ,price_concept_code
                   ,price_element_code
                   ,stim_value_category_code
                   ,line_item_type
                   ,line_item_based_type
                   ,vat_rate
                   ,vat_code
                   ,company_stream_item_id
                   ,comments
                   ,description
                   ,sort_order
                   ,profit_centre_id
                   )
              SELECT cc.object_id
                   ,lv2_new_liv_id
                   ,cc.stream_item_id
                   ,cc.vendor_id
                   ,cc.customer_id
                   ,p_daytime
                   ,cc.name
                   ,cc.dist_id
                   ,cc.node_id
                   ,p_user
                   ,p_document_id
                   ,lv2_new_trans_id
                   ,cc.vendor_share
                   ,cc.vendor_share_qty2
                   ,cc.vendor_share_qty3
                   ,cc.vendor_share_qty4
                   ,cc.customer_share
                   ,cc.report_category_code
                   ,cc.line_item_value
                   ,cc.value_adjustment
                   ,cc.contribution_factor
                   ,cc.move_qty_to_vo_ind
                   ,cc.uom1_code
                   ,cc.uom2_code
                   ,cc.uom3_code
                   ,cc.uom4_code
                   ,cc.split_share
                   ,cc.price_concept_code
                   ,cc.price_element_code
                   ,cc.stim_value_category_code
                   ,cc.line_item_type
                   ,cc.line_item_based_type
                   ,case lv2_ignore_vat when 'N' then cc.vat_rate else 0 end
                   ,case lv2_ignore_vat when 'N' then cc.vat_code else null end
                   ,cc.company_stream_item_id
                   ,cc.comments
                   ,cc.description
                   ,cc.sort_order
                   ,cc.profit_centre_id
                FROM cont_li_dist_company cc
               WHERE cc.line_item_key = LiDi.line_item_key
                 AND cc.dist_id = LiDi.Dist_Id
                 ;


        END LOOP; -- Line item dist

        -- This update is to perform monetary updates
        UPDATE CONT_LINE_ITEM
        SET PRICING_VALUE = PRICING_VALUE
            ,last_updated_by = 'SYSTEM' -- part of insert operation
        WHERE object_id = p_object_id
        AND document_key = p_document_id
        AND transaction_key = lv2_new_trans_id
        AND line_item_key = lv2_new_liv_id;

    END LOOP;

    UPDATE cont_transaction_qty
       SET net_grs_indicator = lrec_trans_qty.net_grs_indicator
          ,report_net_ind        = lrec_trans_qty.report_net_ind
          ,report_grs_ind        = lrec_trans_qty.report_grs_ind
          ,net_qty1          = lrec_trans_qty.net_qty1 * -1 -- invert
          ,net_qty2          = lrec_trans_qty.net_qty2 * -1 -- invert
          ,net_qty3          = lrec_trans_qty.net_qty3 * -1 -- invert
          ,net_qty4          = lrec_trans_qty.net_qty4 * -1 -- invert
          ,grs_qty1          = lrec_trans_qty.grs_qty1 * -1 -- invert
          ,grs_qty2          = lrec_trans_qty.grs_qty2 * -1 -- invert
          ,grs_qty3          = lrec_trans_qty.grs_qty3 * -1 -- invert
          ,grs_qty4          = lrec_trans_qty.grs_qty4 * -1 -- invert
          ,pre_net_qty1      = lrec_trans_qty.pre_net_qty1 * -1 -- invert
          ,pre_net_qty2      = lrec_trans_qty.pre_net_qty2 * -1 -- invert
          ,pre_net_qty3      = lrec_trans_qty.pre_net_qty3 * -1 -- invert
          ,pre_net_qty4      = lrec_trans_qty.pre_net_qty4 * -1 -- invert
          ,pre_grs_qty1      = lrec_trans_qty.pre_grs_qty1 * -1 -- invert
          ,pre_grs_qty2      = lrec_trans_qty.pre_grs_qty2 * -1 -- invert
          ,pre_grs_qty3      = lrec_trans_qty.pre_grs_qty3 * -1 -- invert
          ,pre_grs_qty4      = lrec_trans_qty.pre_grs_qty4 * -1 -- invert
          ,last_updated_by   = p_user
    WHERE object_id = p_object_id
    AND transaction_key = lv2_new_trans_id;


    IF (lv2_doc_concept_new <> 'DEPENDENT_ONLY_QTY_REVERSAL' OR
        ec_cont_document.reversal_ind(p_document_id) = 'Y' ) THEN

        -- insert any non-qty line items
        FOR LIVOTH IN c_li_other(p_transaction_id) LOOP
            Ecdp_System_Key.assignNextNumber('CONT_LINE_ITEM', lv2_temp_key);
            SELECT 'LI:' || to_char(lv2_temp_key)
            INTO lv2_new_liv_id
            FROM DUAL;

            INSERT INTO cont_line_item (
                 object_id
                ,line_item_key
                ,daytime
                ,transaction_key
                ,name
                ,description
                ,comments
                ,price_concept_code
                ,price_element_code
                ,price_object_id
                ,stream_item_id
                ,stim_value_category_code
                ,sort_order
                ,report_category_code
                ,line_item_value
                ,unit_price
                ,unit_price_unit
                ,free_unit_qty
                ,value_adjustment
                ,pricing_value
                ,pricing_vat_value
                ,document_key
                ,line_item_based_type
                ,line_item_type
                ,vat_code
                ,vat_rate
                ,node_id
                ,source_line_item_key
                ,line_item_template_id
                ,percentage_base_amount
                ,percentage_value
                ,dist_method
                ,creation_method
                ,ifac_li_conn_code
                ,li_unique_key_1
                ,li_unique_key_2
                ,created_by
            ) VALUES (
                 LIVOTH.object_id
                ,lv2_new_liv_id
                ,p_daytime
                ,lv2_new_trans_id
                ,p_name_prefix || LIVOTH.name
                ,LIVOTH.description
                ,LIVOTH.comments
                ,LIVOTH.price_concept_code
                ,LIVOTH.price_element_code
                ,LIVOTH.price_object_id
                ,LIVOTH.stream_item_id
                ,LIVOTH.stim_value_category_code
                ,LIVOTH.sort_order
                ,LIVOTH.report_category_code
                ,LIVOTH.line_item_value    * -1
                ,LIVOTH.unit_price
                ,LIVOTH.unit_price_unit
                ,LIVOTH.free_unit_qty      * -1
                ,LIVOTH.value_adjustment
                ,LIVOTH.pricing_value      * -1
                ,case lv2_ignore_vat when 'N' then LIVOTH.pricing_vat_value  * -1 else 0 end
                ,p_document_id
                ,LIVOTH.line_item_based_type
                ,LIVOTH.line_item_type
                ,case lv2_ignore_vat when 'N' then LIVOTH.vat_code else null end
                ,case lv2_ignore_vat when 'N' then LIVOTH.vat_rate else 0 end
                ,LIVOTH.node_id
                ,LIVOTH.line_item_key
                ,LIVOTH.line_item_template_id
                ,LIVOTH.percentage_base_amount * -1
                ,LIVOTH.percentage_value
                ,LIVOTH.dist_method
                ,ecdp_revn_ft_constants.c_mtd_auto_gen
                ,LIVOTH.ifac_li_conn_code
                ,LIVOTH.li_unique_key_1
                ,LIVOTH.li_unique_key_2
                ,p_user
            );

            FOR LiDiOt IN c_li_dist(LIVOTH.line_item_key) LOOP


                INSERT INTO cont_line_item_dist (
                    object_id
                    ,line_item_key
                    ,dist_id
                    ,daytime
                    ,stream_item_id
                    ,node_id
                    ,name
                    ,description
                    ,comments
                    ,sort_order
                    ,report_category_code
                    ,line_item_value
                    ,value_adjustment
                    ,non_adjusted_value
                    ,pricing_value
                    ,pricing_vat_value
                    ,created_by
                    ,document_key
                    ,transaction_key
                    ,split_share
                    ,split_share_qty2
                    ,split_share_qty3
                    ,split_share_qty4
                    ,price_concept_code
                    ,price_element_code
                    ,stim_value_category_code
                    ,line_item_type
                    ,line_item_based_type
                    ,vat_code
                    ,vat_rate
                    ,profit_centre_id
                ) SELECT
                    object_id
                    ,lv2_new_liv_id
                    ,dist_id
                    ,daytime
                    ,stream_item_id
                    ,node_id
                    ,name
                    ,description
                    ,comments
                    ,sort_order
                    ,report_category_code
                    ,line_item_value     * -1
                    ,value_adjustment
                    ,non_adjusted_value  * -1
                    ,pricing_value       * -1
                    ,case lv2_ignore_vat when 'N' then pricing_vat_value   * -1 else 0 end
                    ,p_user
                    ,p_document_id
                    ,lv2_new_trans_id
                    ,split_share
                    ,split_share_qty2
                    ,split_share_qty3
                    ,split_share_qty4
                    ,price_concept_code
                    ,price_element_code
                    ,stim_value_category_code
                    ,line_item_type
                    ,line_item_based_type
                    ,case lv2_ignore_vat when 'N' then vat_code   else null end vat_code
		    ,case lv2_ignore_vat when 'N' then vat_rate   else 0 end vat_rate
                    ,profit_centre_id
                FROM cont_line_item_dist clid
                WHERE clid.line_item_key = LiDiOt.line_item_key
            AND   clid.dist_id = LiDiOt.Dist_Id
            ;

                -- Insert records for Company split
                INSERT INTO cont_li_dist_company (
                       object_id
                       ,line_item_key
                       ,stream_item_id
                       ,vendor_id
                       ,customer_id
                       ,daytime
                       ,name
                       ,dist_id
                       ,node_id
                       ,created_by
                       ,document_key
                       ,transaction_key
                       ,vendor_share
                       ,vendor_share_qty2
                       ,vendor_share_qty3
                       ,vendor_share_qty4
                       ,customer_share
                       ,report_category_code
                       ,line_item_value
                       ,value_adjustment
                       ,non_adjusted_value
                       ,pricing_value
                       ,pricing_vat_value
                       ,contribution_factor
                       ,move_qty_to_vo_ind
                       ,uom1_code
                       ,uom2_code
                       ,uom3_code
                       ,uom4_code
                       ,split_share
                       ,price_concept_code
                       ,price_element_code
                       ,stim_value_category_code
                       ,line_item_type
                       ,line_item_based_type
                       ,vat_rate
                       ,vat_code
                       ,company_stream_item_id
                       ,comments
                       ,description
                       ,sort_order
                       ,profit_centre_id
                       )
                  SELECT cc.object_id
                       ,lv2_new_liv_id
                       ,cc.stream_item_id
                       ,cc.vendor_id
                       ,cc.customer_id
                       ,p_daytime
                       ,cc.name
                       ,cc.dist_id
                       ,cc.node_id
                       ,p_user
                       ,p_document_id
                       ,lv2_new_trans_id
                       ,cc.vendor_share
                       ,cc.vendor_share_qty2
                       ,cc.vendor_share_qty3
                       ,cc.vendor_share_qty4
                       ,cc.customer_share
                       ,cc.report_category_code
                       ,cc.line_item_value     * -1
                       ,cc.value_adjustment
                       ,cc.non_adjusted_value  * -1
                       ,cc.pricing_value       * -1
                       ,case lv2_ignore_vat when 'N' then cc.pricing_vat_value   * -1 else 0 end
                       ,cc.contribution_factor
                       ,cc.move_qty_to_vo_ind
                       ,cc.uom1_code
                       ,cc.uom2_code
                       ,cc.uom3_code
                       ,cc.uom4_code
                       ,cc.split_share
                       ,cc.price_concept_code
                       ,cc.price_element_code
                       ,cc.stim_value_category_code
                       ,cc.line_item_type
                       ,cc.line_item_based_type
                       ,case lv2_ignore_vat when 'N' then cc.vat_rate  else 0 end
                       ,case lv2_ignore_vat when 'N' then cc.vat_code else null end
                       ,cc.company_stream_item_id
                       ,cc.comments
                       ,cc.description
                       ,cc.sort_order
                       ,cc.profit_centre_id
                    FROM cont_li_dist_company cc
                   WHERE cc.line_item_key = LiDiOt.line_item_key
                 AND cc.dist_id = LiDiOt.Dist_Id
                 ;

            END LOOP; -- Line item dist

            -- This update is to perform monetary updates
            UPDATE CONT_LINE_ITEM
            SET PRICING_VALUE = PRICING_VALUE
                ,last_updated_by = 'SYSTEM' -- part of insert operation
            WHERE object_id = p_object_id
            AND document_key = p_document_id
            AND transaction_key = lv2_new_trans_id
            AND line_item_key = lv2_new_liv_id;

        END LOOP; -- insert other line items


        -- Finally, take any interest line items.
        FOR LIVINT IN c_li_interest(p_transaction_id) LOOP

            IF Nvl(lv2_prev_li_int_group,'XXX') <> LIVINT.interest_group THEN -- new interest li set
                lv2_curr_li_int_group := NULL;
                lv2_interest_parent_li := NULL;
                lv2_prev_li_int_group := LIVINT.interest_group;
            ELSE
                lv2_interest_parent_li := lv2_new_liv_id;
            END IF;
            Ecdp_System_Key.assignNextNumber('CONT_LINE_ITEM', lv2_temp_key);
            -- insert line item, pick id from sequence
            SELECT 'LI:' || to_char(lv2_temp_key)
            INTO lv2_new_liv_id
            FROM DUAL;

            IF lv2_curr_li_int_group IS NULL THEN
                lv2_curr_li_int_group := lv2_new_liv_id;
            END IF;

            INSERT INTO cont_line_item (
                OBJECT_ID,
                LINE_ITEM_KEY,
                DOCUMENT_KEY,
                TRANSACTION_KEY,
                DAYTIME,
                LINE_ITEM_TEMPLATE_ID,
                INTEREST_GROUP,
                COMMENTS,
                DESCRIPTION,
                LINE_ITEM_BASED_TYPE,
                LINE_ITEM_TYPE,
                NAME,
                NODE_ID,
                PRICE_CONCEPT_CODE,
                PRICE_ELEMENT_CODE,
                PRICE_OBJECT_ID,
                REPORT_CATEGORY_CODE,
                SORT_ORDER,
                STIM_VALUE_CATEGORY_CODE,
                STREAM_ITEM_ID,
                UOM1_CODE,
                UOM2_CODE,
                UOM3_CODE,
                UOM4_CODE,
                VALUE_ADJUSTMENT,
                VAT_CODE,
                VAT_RATE,
                INTEREST_LINE_ITEM_KEY,
                INTEREST_BASE_AMOUNT,
                INTEREST_TYPE,
                BASE_RATE,
                RATE_OFFSET,
                GROSS_RATE,
                INTEREST_FROM_DATE,
                INTEREST_TO_DATE,
                RATE_DAYS,
                COMPOUNDING_PERIOD,
                PRICING_VALUE,
                PRICING_VAT_VALUE,
                SOURCE_LINE_ITEM_KEY,
                dist_method,
                creation_method,
                ifac_li_conn_code,
                CREATED_BY
            )
            SELECT
                OBJECT_ID,
                lv2_new_liv_id, -- new id
                p_document_id,
                lv2_new_trans_id,
                p_daytime,
                LINE_ITEM_TEMPLATE_ID,
                lv2_curr_li_int_group,
                COMMENTS,
                DESCRIPTION,
                LINE_ITEM_BASED_TYPE,
                LINE_ITEM_TYPE,
                p_name_prefix ||NAME,
                NODE_ID,
                PRICE_CONCEPT_CODE,
                PRICE_ELEMENT_CODE,
                PRICE_OBJECT_ID,
                REPORT_CATEGORY_CODE,
                SORT_ORDER,
                STIM_VALUE_CATEGORY_CODE,
                STREAM_ITEM_ID,
                UOM1_CODE,
                UOM2_CODE,
                UOM3_CODE,
                UOM4_CODE,
                VALUE_ADJUSTMENT,
                case lv2_ignore_vat when 'N' then VAT_CODE else null end  ,
                case lv2_ignore_vat when 'N' then VAT_RATE else 0 end  ,
                lv2_interest_parent_li,
                INTEREST_BASE_AMOUNT * -1,
                INTEREST_TYPE,
                BASE_RATE,
                RATE_OFFSET,
                GROSS_RATE,
                INTEREST_FROM_DATE,
                INTEREST_TO_DATE,
                RATE_DAYS,
                COMPOUNDING_PERIOD,
                PRICING_VALUE *-1,
                 case lv2_ignore_vat when 'N' then PRICING_VAT_VALUE *-1 else 0 end ,
                LINE_ITEM_KEY,
                dist_method,
                ecdp_revn_ft_constants.c_mtd_auto_gen,
                ifac_li_conn_code,
                p_user
            FROM cont_line_item
            WHERE object_id = p_object_id
            AND line_item_key = LIVINT.line_item_key;

            FOR LiDiIt IN c_li_dist(LIVINT.line_item_key) LOOP


                INSERT INTO cont_line_item_dist
                  (object_id,
                   line_item_key,
                   document_key,
                   transaction_key,
                   daytime,
                   comments,
                   description,
                   dist_id,
                   line_item_based_type,
                   line_item_type,
                   line_item_value,
                   name,
                   node_id,
                   price_concept_code,
                   price_element_code,
                   report_category_code,
                   sort_order,
                   split_share,
                   split_share_qty2,
                   split_share_qty3,
                   split_share_qty4,
                   stim_value_category_code,
                   stream_item_id,
                   uom1_code,
                   uom2_code,
                   uom3_code,
                   uom4_code,
                   value_adjustment,
                   vat_code,
                   vat_rate,
                   created_by,
                   profit_centre_id)
                  SELECT object_id,
                         lv2_new_liv_id, -- new id
                         p_document_id,
                         lv2_new_trans_id,
                         p_daytime,
                         comments,
                         description,
                         dist_id,
                         line_item_based_type,
                         line_item_type,
                         line_item_value,
                         name,
                         node_id,
                         price_concept_code,
                         price_element_code,
                         report_category_code,
                         sort_order,
                         split_share,
                         split_share_qty2,
                         split_share_qty3,
                         split_share_qty4,
                         stim_value_category_code,
                         stream_item_id,
                         uom1_code,
                         uom2_code,
                         uom3_code,
                         uom4_code,
                         value_adjustment,
                         case lv2_ignore_vat when 'N' then vat_code else null end  ,
                         case lv2_ignore_vat when 'N' then VAT_RATE else 0 end  ,
                         p_user,
                         profit_centre_id
                    FROM cont_line_item_dist clid
                   WHERE clid.line_item_key = LiDiIt.line_item_key
                     AND clid.dist_id = LiDiIt.Dist_Id;

                -- Insert records for Company split
                INSERT INTO cont_li_dist_company
                  (object_id,
                   line_item_key,
                   stream_item_id,
                   vendor_id,
                   customer_id,
                   daytime,
                   name,
                   dist_id,
                   node_id,
                   created_by,
                   document_key,
                   transaction_key,
                   vendor_share,
                   vendor_share_qty2,
                   vendor_share_qty3,
                   vendor_share_qty4,
                   customer_share,
                   report_category_code,
                   line_item_value,
                   value_adjustment,
                   contribution_factor,
                   move_qty_to_vo_ind,
                   uom1_code,
                   uom2_code,
                   uom3_code,
                   uom4_code,
                   split_share,
                   price_concept_code,
                   price_element_code,
                   stim_value_category_code,
                   line_item_type,
                   line_item_based_type,
                   vat_rate,
                   vat_code,
                   company_stream_item_id,
                   comments,
                   description,
                   sort_order,
                   profit_centre_id)
                  SELECT cc.object_id,
                         lv2_new_liv_id,
                         cc.stream_item_id,
                         cc.vendor_id,
                         cc.customer_id,
                         p_daytime,
                         cc.name,
                         cc.dist_id,
                         cc.node_id,
                         p_user,
                         p_document_id,
                         lv2_new_trans_id,
                         cc.vendor_share,
                         cc.vendor_share_qty2,
                         cc.vendor_share_qty3,
                         cc.vendor_share_qty4,
                         cc.customer_share,
                         cc.report_category_code,
                         cc.line_item_value,
                         cc.value_adjustment,
                         cc.contribution_factor,
                         cc.move_qty_to_vo_ind,
                         cc.uom1_code,
                         cc.uom2_code,
                         cc.uom3_code,
                         cc.uom4_code,
                         cc.split_share,
                         cc.price_concept_code,
                         cc.price_element_code,
                         cc.stim_value_category_code,
                         cc.line_item_type,
                         cc.line_item_based_type,
                         case lv2_ignore_vat when 'N' then cc.vat_rate else 0 end ,
                         case lv2_ignore_vat when 'N' then cc.vat_code else null end ,
                         cc.company_stream_item_id,
                         cc.comments,
                         cc.description,
                         cc.sort_order,
                         cc.profit_centre_id
                    FROM cont_li_dist_company cc
                   WHERE cc.line_item_key = LiDiIt.line_item_key
                     AND cc.dist_id = LiDiIt.Dist_Id;

            END LOOP; -- line item dist

            -- This update is to perform monetary updates
            UPDATE CONT_LINE_ITEM
            SET PRICING_VALUE = PRICING_VALUE
                ,last_updated_by = 'SYSTEM' -- part of insert operation
            WHERE object_id = p_object_id
            AND document_key = p_document_id
            AND transaction_key = lv2_new_trans_id
            AND line_item_key = lv2_new_liv_id;

        END LOOP;     -- End LIVINT

        -- overwrite with value from table (to get possible user override in original document)

        UPDATE cont_transaction
        SET trans_pricing_vat        =  case lv2_ignore_vat when 'N' then lrec_trans.trans_pricing_vat * -1 else 0 end
            ,trans_pricing_total     =  lrec_trans.trans_pricing_total * -1 + case lv2_ignore_vat when 'Y' then lrec_trans.trans_pricing_vat else 0 end
            ,trans_memo_vat          =  case lv2_ignore_vat when 'N' then lrec_trans.trans_memo_vat * -1 else 0 end
            ,trans_memo_total        =  lrec_trans.trans_memo_total * -1 + case lv2_ignore_vat when 'Y' then lrec_trans.trans_memo_vat else 0 end
            ,trans_booking_vat       =  case lv2_ignore_vat when 'N' then lrec_trans.trans_booking_vat * -1 else 0 end
            ,trans_booking_total     =  lrec_trans.trans_booking_total * -1 + case lv2_ignore_vat when 'Y' then lrec_trans.trans_booking_vat else 0 end
            ,last_updated_by = 'SYSTEM'
        WHERE transaction_key = lv2_new_trans_id;

    END IF; -- Different from DEPENDENT_ONLY_QTY_REVERSAL




    RETURN lv2_new_trans_id;

END ReverseTransaction;


/*FUNCTION  GetConstrainedConvFactors (
          p_object_id VARCHAR2,
          p_transaction_id VARCHAR2,
          p_daytime DATE
          )

RETURN t_constrained_factor_table

IS
  cursor c_split(cp_transaction_key VARCHAR2) IS
    SELECT distinct clid.stream_item_id split_member_id,
                    clid.split_share,
                    clid.split_share_qty2,
                    clid.split_share_qty3,
                    clid.split_share_qty4
      FROM cont_line_item_dist clid
 WHERE clid.transaction_key = cp_transaction_key
   AND 'CALCULATED' NOT IN
       (select DISTINCT ec_stream_item_version.conversion_method(f.stream_item_id,f.daytime,'<=')
          FROM cont_line_item_dist f
         WHERE f.transaction_key = clid.transaction_key);




  -- table to return. three cols; one for qty2, qty3, qty4 respectively
  -- as many records as there are members of split, plus one to hold the sum.
  ltab_factors t_constrained_factor_table := t_constrained_factor_table();

  lv2_uom1_group VARCHAR2(32);
  lv2_uom2_group VARCHAR2(32);
  lv2_uom3_group VARCHAR2(32);
  lv2_uom4_group VARCHAR2(32);

  lb_apply_to_qty2 BOOLEAN;
  lb_apply_to_qty3 BOOLEAN;
  lb_apply_to_qty4 BOOLEAN;

  ln_factor2_sum NUMBER := 0;
  ln_factor3_sum NUMBER := 0;
  ln_factor4_sum NUMBER := 0;
  ln_temp_factor2 NUMBER := 0;
  ln_temp_factor3 NUMBER := 0;
  ln_temp_factor4 NUMBER := 0;


  --lrec_livf cont_line_item_dist%ROWTYPE;
  lrec_smv stim_mth_value%ROWTYPE;
  lrec_trans cont_transaction%ROWTYPE;
  lrec_ttv transaction_tmpl_version%ROWTYPE;

BEGIN

    lrec_trans := ec_cont_transaction.row_by_pk(p_transaction_id);
    lrec_ttv := ec_transaction_tmpl_version.row_by_pk(ec_cont_transaction.trans_template_id(p_transaction_id), p_daytime, '<=');


    FOR Split in c_split(lrec_trans.transaction_key) LOOP

       IF lrec_ttv.UOM2_CODE is not null OR lrec_ttv.UOM3_CODE is not null OR lrec_ttv.UOM4_CODE is not null THEN

         lv2_uom1_group := ec_ctrl_unit.uom_group(lrec_ttv.UOM1_CODE);

        IF lrec_ttv.UOM2_CODE IS NOT NULL THEN

            lv2_uom2_group := ec_ctrl_unit.uom_group(lrec_ttv.UOM2_CODE);

         END IF;

         IF lrec_ttv.UOM3_CODE IS NOT NULL THEN

            lv2_uom3_group := ec_ctrl_unit.uom_group(lrec_ttv.UOM3_CODE);

         END IF;

         IF lrec_ttv.UOM4_CODE IS NOT NULL THEN

            lv2_uom4_group := ec_ctrl_unit.uom_group(lrec_ttv.UOM4_CODE);

         END IF;

         IF lv2_uom2_group <> lv2_uom1_group OR lv2_uom3_group <> lv2_uom1_group OR lv2_uom4_group <> lv2_uom1_group THEN


             ltab_factors.extend;

             -- store stream_item_object_id, to know for which record in clif to apply to
             ltab_factors(ltab_factors.last).stream_item_object_id := Split.split_member_id;

             lrec_smv := ec_stim_mth_value.row_by_pk(Split.split_member_id,trunc(lrec_trans.transaction_date,'MM'));

             -- Find out which uoms to apply to
             IF lrec_ttv.UOM2_CODE is not null AND lv2_uom2_group <> lv2_uom1_group THEN
                lb_apply_to_qty2 := TRUE;
             ELSE
                lb_apply_to_qty2 := FALSE;
             END IF;

             IF lrec_ttv.UOM3_CODE is not null AND lv2_uom3_group <> lv2_uom1_group THEN
                lb_apply_to_qty3 := TRUE;
             ELSE
                lb_apply_to_qty3 := FALSE;
             END IF;

             IF lrec_ttv.UOM4_CODE is not null AND lv2_uom4_group <> lv2_uom1_group THEN
                lb_apply_to_qty4 := TRUE;
             ELSE
                lb_apply_to_qty4 := FALSE;
             END IF;


             IF lv2_uom1_group = 'M' THEN

                IF lb_apply_to_qty2 THEN

                  IF lv2_uom2_group = 'V' THEN

                     -- density
                     -- convert mass_uom, then volume_uom
                     ln_temp_factor2 := lrec_smv.density * Ecdp_Unit.convertValue(1, lrec_smv.density_mass_uom, lrec_ttv.UOM1_CODE, p_daytime);
                     ln_temp_factor2 := ln_temp_factor2 / Ecdp_Unit.convertValue(1, lrec_smv.density_volume_uom, lrec_ttv.UOM2_CODE, p_daytime);

                  ELSE -- i.e. lv2_uom2_group = 'E'

                     -- inverse MCV
                     -- convert energy_uom, then mass_uom, finally invert
                     ln_temp_factor2 := lrec_smv.mcv * Ecdp_Unit.convertValue(1, lrec_smv.mcv_energy_uom, lrec_ttv.UOM2_CODE, p_daytime);
                     ln_temp_factor2 := ln_temp_factor2 / Ecdp_Unit.convertValue(1, lrec_smv.mcv_mass_uom, lrec_ttv.UOM1_CODE, p_daytime);

                     ln_temp_factor2 := 1 / ln_temp_factor2;

                  END IF;

                END IF;

               IF lb_apply_to_qty3 THEN

                  IF lv2_uom3_group = 'V' THEN

                     -- density
                     -- convert mass_uom, then volume_uom
                     ln_temp_factor3 := lrec_smv.density * Ecdp_Unit.convertValue(1, lrec_smv.density_mass_uom, lrec_ttv.UOM1_CODE, p_daytime);
                     ln_temp_factor3 := ln_temp_factor3 / Ecdp_Unit.convertValue(1, lrec_smv.density_volume_uom, lrec_ttv.UOM3_CODE, p_daytime);

                  ELSE -- i.e. lv2_uom2_group = 'E'

                     -- inverse MCV
                     -- convert energy_uom, then mass_uom, finally invert
                     ln_temp_factor3 := lrec_smv.mcv * Ecdp_Unit.convertValue(1, lrec_smv.mcv_energy_uom, lrec_ttv.UOM3_CODE, p_daytime);
                     ln_temp_factor3 := ln_temp_factor3 / Ecdp_Unit.convertValue(1, lrec_smv.mcv_mass_uom, lrec_ttv.UOM1_CODE, p_daytime);

                     ln_temp_factor3 := 1 / ln_temp_factor3;

                  END IF;

                END IF;

                IF lb_apply_to_qty4 THEN

                  IF lv2_uom3_group = 'V' THEN

                     -- density
                     -- convert mass_uom, then volume_uom
                     ln_temp_factor4 := lrec_smv.density * Ecdp_Unit.convertValue(1, lrec_smv.density_mass_uom, lrec_ttv.UOM1_CODE, p_daytime);
                     ln_temp_factor4 := ln_temp_factor4 / Ecdp_Unit.convertValue(1, lrec_smv.density_volume_uom, lrec_ttv.UOM4_CODE, p_daytime);

                  ELSE -- i.e. lv2_uom2_group = 'E'

                     -- inverse MCV
                     -- convert energy_uom, then mass_uom, finally invert
                     ln_temp_factor4 := lrec_smv.mcv * Ecdp_Unit.convertValue(1, lrec_smv.mcv_energy_uom, lrec_ttv.UOM4_CODE, p_daytime);
                     ln_temp_factor4 := ln_temp_factor4 / Ecdp_Unit.convertValue(1, lrec_smv.mcv_mass_uom, lrec_ttv.UOM1_CODE, p_daytime);

                     ln_temp_factor4 := 1 / ln_temp_factor4;

                  END IF;

                END IF;

             ELSIF lv2_uom1_group = 'V' THEN

                IF lb_apply_to_qty2 THEN

                  IF lv2_uom2_group = 'M' THEN

                     -- inverse density
                     -- convert mass_uom, then volume_uom, finally invert
                     ln_temp_factor2 := lrec_smv.density * Ecdp_Unit.convertValue(1, lrec_smv.density_mass_uom, lrec_ttv.UOM2_CODE, p_daytime);
                     ln_temp_factor2 := ln_temp_factor2 / Ecdp_Unit.convertValue(1, lrec_smv.density_volume_uom, lrec_ttv.UOM1_CODE, p_daytime);

                     ln_temp_factor2 := 1 / ln_temp_factor2;

                  ELSE -- i.e. lv2_uom2_group = 'E'

                     -- inverse GCV
                     -- convert energy_uom, then volume_uom, finally invert
                     ln_temp_factor2 := lrec_smv.gcv * Ecdp_Unit.convertValue(1, lrec_smv.gcv_energy_uom, lrec_ttv.UOM2_CODE, p_daytime);
                     ln_temp_factor2 := ln_temp_factor2 / Ecdp_Unit.convertValue(1, lrec_smv.gcv_volume_uom, lrec_ttv.UOM1_CODE, p_daytime);

                     ln_temp_factor2 := 1 / ln_temp_factor2;

                  END IF;

                END IF;

                IF lb_apply_to_qty3 THEN

                  IF lv2_uom3_group = 'M' THEN

                     -- inverse density
                     -- convert mass_uom, then volume_uom, finally invert
                     ln_temp_factor3 := lrec_smv.density * Ecdp_Unit.convertValue(1, lrec_smv.density_mass_uom, lrec_ttv.UOM3_CODE, p_daytime);
                     ln_temp_factor3 := ln_temp_factor3 / Ecdp_Unit.convertValue(1, lrec_smv.density_volume_uom, lrec_ttv.UOM1_CODE, p_daytime);

                     ln_temp_factor3 := 1 / ln_temp_factor3;

                  ELSE -- i.e. lv2_uom3_group = 'E'

                     -- inverse GCV
                     -- convert energy_uom, then volume_uom, finally invert
                     ln_temp_factor3 := lrec_smv.gcv * Ecdp_Unit.convertValue(1, lrec_smv.gcv_energy_uom, lrec_ttv.UOM3_CODE, p_daytime);
                     ln_temp_factor3 := ln_temp_factor3 / Ecdp_Unit.convertValue(1, lrec_smv.gcv_volume_uom, lrec_ttv.UOM1_CODE, p_daytime);

                     ln_temp_factor3 := 1 / ln_temp_factor3;

                  END IF;

                END IF;

                IF lb_apply_to_qty4 THEN

                  IF lv2_uom4_group = 'M' THEN

                     -- inverse density
                     -- convert mass_uom, then volume_uom, finally invert
                     ln_temp_factor4 := lrec_smv.density * Ecdp_Unit.convertValue(1, lrec_smv.density_mass_uom, lrec_ttv.UOM4_CODE, p_daytime);
                     ln_temp_factor4 := ln_temp_factor4 / Ecdp_Unit.convertValue(1, lrec_smv.density_volume_uom, lrec_ttv.UOM1_CODE, p_daytime);

                     ln_temp_factor4 := 1 / ln_temp_factor4;

                  ELSE -- i.e. lv2_uom4_group = 'E'

                     -- inverse GCV
                     -- convert energy_uom, then volume_uom, finally invert
                     ln_temp_factor4 := lrec_smv.gcv * Ecdp_Unit.convertValue(1, lrec_smv.gcv_energy_uom, lrec_ttv.UOM4_CODE, p_daytime);
                     ln_temp_factor4 := ln_temp_factor4 / Ecdp_Unit.convertValue(1, lrec_smv.gcv_volume_uom, lrec_ttv.UOM1_CODE, p_daytime);

                     ln_temp_factor4 := 1 / ln_temp_factor4;

                  END IF;

                END IF;

             ELSE -- i.e. lv2_uom1_group = 'E'

                IF lb_apply_to_qty2 THEN

                  IF lv2_uom2_group = 'M' THEN

                     -- MCV
                     -- convert energy_uom, then mass_uom
                     ln_temp_factor2 := lrec_smv.mcv * Ecdp_Unit.convertValue(1, lrec_smv.mcv_energy_uom, lrec_ttv.UOM1_CODE, p_daytime);
                     ln_temp_factor2 := ln_temp_factor2 / Ecdp_Unit.convertValue(1, lrec_smv.mcv_mass_uom, lrec_ttv.UOM2_CODE, p_daytime);

                  ELSE -- i.e. lv2_uom2_group = 'V'

                     -- GCV
                     -- convert energy_uom, then volume_uom, finally invert
                     ln_temp_factor2 := lrec_smv.gcv * Ecdp_Unit.convertValue(1, lrec_smv.gcv_energy_uom, lrec_ttv.UOM1_CODE, p_daytime);
                     ln_temp_factor2 := ln_temp_factor2 / Ecdp_Unit.convertValue(1, lrec_smv.gcv_volume_uom, lrec_ttv.UOM2_CODE, p_daytime);

                     ln_temp_factor2 := 1 / ln_temp_factor2;

                  END IF;

                END IF;

                IF lb_apply_to_qty3 THEN

                  IF lv2_uom3_group = 'M' THEN

                     -- MCV
                     -- convert energy_uom, then mass_uom
                     ln_temp_factor3 := lrec_smv.mcv * Ecdp_Unit.convertValue(1, lrec_smv.mcv_energy_uom, lrec_ttv.UOM1_CODE, p_daytime);
                     ln_temp_factor3 := ln_temp_factor3 / Ecdp_Unit.convertValue(1, lrec_smv.mcv_mass_uom, lrec_ttv.UOM3_CODE, p_daytime);

                  ELSE -- i.e. lv2_uom3_group = 'V'

                     -- GCV
                     -- convert energy_uom, then volume_uom, finally invert
                     ln_temp_factor3 := lrec_smv.gcv * Ecdp_Unit.convertValue(1, lrec_smv.gcv_energy_uom, lrec_ttv.UOM1_CODE, p_daytime);
                     ln_temp_factor3 := ln_temp_factor3 / Ecdp_Unit.convertValue(1, lrec_smv.gcv_volume_uom, lrec_ttv.UOM3_CODE, p_daytime);

                     ln_temp_factor3 := 1 / ln_temp_factor3;

                  END IF;

                END IF;

                IF lb_apply_to_qty4 THEN

                  IF lv2_uom4_group = 'M' THEN

                     -- MCV
                     -- convert energy_uom, then mass_uom
                     ln_temp_factor4 := lrec_smv.mcv * Ecdp_Unit.convertValue(1, lrec_smv.mcv_energy_uom, lrec_ttv.UOM1_CODE, p_daytime);
                     ln_temp_factor4 := ln_temp_factor4 / Ecdp_Unit.convertValue(1, lrec_smv.mcv_mass_uom, lrec_ttv.UOM4_CODE, p_daytime);

                  ELSE -- i.e. lv2_uom3_group = 'V'

                     -- GCV
                     -- convert energy_uom, then volume_uom, finally invert
                     ln_temp_factor4 := lrec_smv.gcv * Ecdp_Unit.convertValue(1, lrec_smv.gcv_energy_uom, lrec_ttv.UOM1_CODE, p_daytime);
                     ln_temp_factor4 := ln_temp_factor4 / Ecdp_Unit.convertValue(1, lrec_smv.gcv_volume_uom, lrec_ttv.UOM4_CODE, p_daytime);

                     ln_temp_factor4 := 1 / ln_temp_factor4;

                  END IF;

                END IF;

             END IF; -- lv2_uom1_group

             -- update conv factor ltab.
             IF lb_apply_to_qty2 THEN
                ln_temp_factor2 := ln_temp_factor2 * nvl(Split.split_share_qty2,Split.Split_Share);
                ltab_factors(ltab_factors.last).uom2_factor := ln_temp_factor2;
                ln_factor2_sum := ln_factor2_sum + ln_temp_factor2;
             END IF;

             IF lb_apply_to_qty3 THEN
                ln_temp_factor3 := ln_temp_factor3 * nvl(Split.split_share_qty3,Split.Split_Share);
                ltab_factors(ltab_factors.last).uom3_factor := ln_temp_factor3;
                ln_factor3_sum := ln_factor3_sum + ln_temp_factor3;
             END IF;

             IF lb_apply_to_qty4 THEN
                ln_temp_factor4 := ln_temp_factor4 * nvl(Split.split_share_qty4,Split.Split_Share);
                ltab_factors(ltab_factors.last).uom4_factor := ln_temp_factor4;
                ln_factor4_sum := ln_factor4_sum + ln_temp_factor4;
             END IF;


          END IF; -- if any uomx_group <> uom1_group

       END IF;  -- if any uom_code is not null

     END LOOP;

     -- if there are rows in table,
     -- add extra row to hold sums of each column
     IF ltab_factors.COUNT > 0 THEN

        ltab_factors.extend;

        IF NVL(ln_factor2_sum,0) = 0 THEN
           ln_factor2_sum := 1;
         END IF;

         IF NVL(ln_factor3_sum,0) = 0 THEN
           ln_factor3_sum := 1;
         END IF;

         IF NVL(ln_factor4_sum,0) = 0 THEN
           ln_factor4_sum := 1;
         END IF;


        ltab_factors(ltab_factors.last).uom2_factor := ln_factor2_sum;
        ltab_factors(ltab_factors.last).uom3_factor := ln_factor3_sum;
        ltab_factors(ltab_factors.last).uom4_factor := ln_factor4_sum;

     END IF;

   RETURN ltab_factors;

END GetConstrainedConvFactors;*/

FUNCTION IsAllUOMPresent(
   p_object_id VARCHAR2,
   p_doc_id    VARCHAR2
)

RETURN BOOLEAN

IS

ln_count NUMBER;

BEGIN

   SELECT Count(*)
   INTO ln_count
   FROM cont_line_item
   WHERE object_id = p_object_id
      AND document_key = p_doc_id
      AND ( (QTY1 IS NULL) OR
           (QTY2 IS NULL AND UOM2_CODE IS NOT NULL) OR
           (QTY3 IS NULL AND UOM3_CODE IS NOT NULL) OR
           (QTY4 IS NULL AND UOM4_CODE IS NOT NULL) )
      AND line_item_based_type = 'QTY';

   RETURN (ln_count = 0);

END IsAllUOMPresent;

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE ValidateTransactions (
    p_document_key VARCHAR2,
    p_val_msg  OUT VARCHAR2,
    p_val_code OUT VARCHAR2,
    p_silent_ind   VARCHAR2
)
IS

CURSOR c_trans IS
  SELECT *
    FROM cont_transaction ct
   WHERE ct.document_key = p_document_key;

CURSOR c_qtyli(cp_transaction_key VARCHAR2) IS
    SELECT count(*) num
    FROM cont_line_item cli
    WHERE cli.transaction_key = cp_transaction_key
    AND cli.line_item_based_type = 'QTY';    -- only if QTY line item(s) exist

CURSOR c_line_item_dist(cp_li_key VARCHAR2) IS
  SELECT count(*) dist_count
  FROM cont_line_item_dist
  WHERE line_item_key = cp_li_key;

CURSOR c_li_dist_company(cp_li_key VARCHAR2) IS
  SELECT count(*) company_count
  FROM cont_li_dist_company
  WHERE line_item_key = cp_li_key;

CURSOR c_li(cp_transaction_key VARCHAR2) IS
  SELECT *
    FROM cont_line_item
   WHERE transaction_key = cp_transaction_key;

  validation_exception EXCEPTION;

  lrec_doc               cont_document%ROWTYPE := ec_cont_document.row_by_pk(p_document_key);
  lv2_transaction_key    cont_transaction.transaction_key%TYPE;
  ln_count               NUMBER;
  ln_price               NUMBER;
  lb_ifac_price BOOLEAN;
  lrec_reversed_trans    cont_transaction%ROWTYPE ;
  lrec_trans_qty         cont_transaction_Qty%ROWTYPE ;
  lrec_rev_trans_qty     cont_transaction_Qty%ROWTYPE ;
  lv2_ignore_vat  VARCHAR2(1) := 'N';
  lb_transaction_found BOOLEAN := FALSE;
BEGIN

  IF Ue_Cont_Transaction.isValidateTransactionUEE = 'TRUE' THEN

     Ue_Cont_Transaction.ValidateTransactions(lrec_doc, p_val_msg, p_val_code, p_silent_ind);

  ELSE

    -- All UOMs must be completed
    IF NOT IsAllUOMPresent(lrec_doc.object_id, lrec_doc.document_key) THEN

         p_val_msg := 'Missing quantities for one or more of the supplied UOMs on quantity line items.';
         p_val_code := 'QTY_UOM';
         RAISE validation_exception;

    END IF;


    FOR Trans IN c_trans LOOP


        lv2_transaction_key := Trans.transaction_key;
        lb_transaction_found := TRUE;

        IF trans.Reversed_Trans_Key IS NOT NULL THEN

           lrec_reversed_trans := ec_cont_transaction.row_by_pk(trans.reversed_trans_key);
           lrec_rev_trans_qty := ec_cont_transaction_qty.row_by_pk(trans.transaction_key);
           lrec_trans_qty := ec_cont_transaction_qty.row_by_pk(lrec_reversed_trans.transaction_key);

          IF ec_ctrl_system_attribute.attribute_text(trans.daytime,'VAT_ON_ACCRUALS','<=') = 'N' AND
             lrec_doc.status_code = 'ACCRUAL' AND
             ec_cont_document.status_code(lrec_reversed_trans.document_key) = 'FINAL' THEN
             lv2_ignore_vat := 'Y';
          ELSE
             lv2_ignore_vat := 'N';
          END IF;

           -- Verify that the preceeding document has not changed
           IF lrec_reversed_trans.discharge_port_id != trans.discharge_port_id OR
              lrec_reversed_trans.product_id != trans.product_id OR
              lrec_reversed_trans.price_concept_code != trans.price_concept_code OR
              lrec_reversed_trans.entry_point_id != trans.entry_point_id OR
              lrec_reversed_trans.destination_country_id != trans.destination_country_id OR
              lrec_reversed_trans.origin_country_id != trans.origin_country_id OR
              lrec_reversed_trans.supply_from_date != trans.supply_from_date OR
              lrec_reversed_trans.supply_to_date != trans.supply_to_date OR
              lrec_reversed_trans.price_object_id != trans.price_object_id  OR
              (lrec_reversed_trans.vat_rate != trans.vat_rate AND lv2_ignore_vat = 'N') OR
              lrec_rev_trans_qty.net_qty1 *-1 != lrec_trans_qty.net_qty1 OR
              lrec_rev_trans_qty.net_qty2 *-1 != lrec_trans_qty.net_qty2 OR
              lrec_rev_trans_qty.net_qty3 *-1 != lrec_trans_qty.net_qty3 OR
              lrec_rev_trans_qty.net_qty4 *-1 != lrec_trans_qty.net_qty4 OR

                (ec_contract_doc_version.doc_concept_code(lrec_doc.contract_doc_id,trans.daytime,'<=') NOT IN (
                                                                                                   'DEPENDENT_ONLY_QTY_REVERSAL',
                                                                                                   'DEPENDENT_PARTIALLY_REVERSAL',
                                                                                                   'DEPENDENT_WITHOUT_REVERSAL')  AND
              (  (lrec_reversed_trans.trans_pricing_value != trans.trans_pricing_value*-1 OR
              lrec_reversed_trans.trans_pricing_total != trans.trans_pricing_total*-1 OR
              lrec_reversed_trans.trans_booking_value != trans.trans_booking_value*-1 OR
              lrec_reversed_trans.trans_booking_total != trans.trans_booking_total*-1  OR
              lrec_reversed_trans.trans_memo_value != trans.trans_memo_value *-1 OR
              lrec_reversed_trans.trans_memo_total != trans.trans_memo_total *-1)
              AND (lv2_ignore_vat = 'N'))) THEN
              p_val_msg := 'A preceding transaction has updated values, delete and recreate (' || lrec_reversed_trans.document_key ||')';
              p_val_code := 'UPDATED_PRECEDING';
              RAISE validation_exception;

            END IF;


           -- Verify that the new document status does not conflict with any reversals

           IF ec_cont_document.status_code(lrec_reversed_trans.document_key) = 'ACCRUAL' AND
              ec_cont_document.status_code(p_document_key) = 'FINAL' THEN

              p_val_msg := 'Can not have a Final Document where one transaction is on an Accrual Document (' || lrec_reversed_trans.document_key ||')';
              p_val_code := 'ACCRUAL_FINAL_DEP_ERR';
              RAISE validation_exception;

            END IF;
        END IF;
        -- all transactions must have transaction_date (point of sale date)
        IF Trans.Transaction_Date IS NULL THEN

          p_val_msg := 'Missing Point of Sale Date.';
          p_val_code := 'POSD_DATE';
          RAISE validation_exception;

        END IF;

        IF trans.trans_pricing_total IS NULL THEN
          p_val_msg := 'Missing Transaction Pricing Total Value.';
          p_val_code := 'TRANS_PRICING_TOTAL_VALUE';
          RAISE validation_exception;
        END IF;

        IF trans.trans_pricing_value IS NULL THEN
          p_val_msg := 'Missing Transaction Pricing Value.';
          p_val_code := 'TRANS_PRICING_VALUE';
          RAISE validation_exception;
        END IF;

        IF trans.trans_pricing_vat IS NULL THEN
          p_val_msg := 'Missing Transaction Pricing VAT Value.';
          p_val_code := 'TRANS_PRICING_VAT_VALUE';
          RAISE validation_exception;
        END IF;


        -- Check transaction ex-rates, regardless of line item based type
        IF Trans.ex_pricing_booking IS NULL OR Trans.ex_inv_pricing_booking IS NULL THEN

            p_val_msg := 'Missing required Pricing to Booking exchange rate';
            p_val_code := 'EX_PRICING_BOOKING';
            RAISE validation_exception;

        END IF;

        IF Trans.product_id IS NULL THEN
            p_val_msg := 'Missing Transaction Product.';
            p_val_code := 'TRANS_MISSING_PRODUCT';
            RAISE validation_exception;
        END IF;

        IF lrec_doc.memo_currency_code IS NOT NULL THEN
            IF Trans.ex_pricing_memo IS NULL OR Trans.ex_inv_pricing_memo IS NULL THEN

                p_val_msg := 'Missing required Pricing to Memo exchange rate';
                p_val_code := 'EX_PRICING_MEMO';
                RAISE validation_exception;

            END IF;
        END IF;

        IF EcDp_Contract_Setup.GetLocalCurrencyCode(lrec_doc.object_id, Trans.daytime) IS NOT NULL THEN
            IF Trans.ex_booking_local IS NULL OR Trans.ex_inv_booking_local IS NULL THEN

                p_val_msg := 'Missing required Booking to Local exchange rate';
                p_val_code := 'EX_BOOKING_LOCAL';
                RAISE validation_exception;

            END IF;
        END IF;

        IF ec_ctrl_system_attribute.attribute_text(Trans.daytime, 'GROUP_CURRENCY_CODE', '<=') IS NOT NULL THEN
            IF Trans.ex_booking_group IS NULL OR Trans.ex_inv_booking_group IS NULL THEN

                p_val_msg := 'Missing required Booking to Group exchange rate';
                p_val_code := 'EX_BOOKING_GROUP';
                RAISE validation_exception;

            END IF;
        END IF;

        FOR rsC IN c_qtyli(Trans.transaction_key) LOOP
            ln_count := rsC.Num;
        END LOOP;

        IF ln_count > 0 THEN -- If trans has qty line items

          -- Validate price object
          IF Trans.Price_Object_Id IS NULL THEN

              p_val_msg := 'Missing Price Object.';
              p_val_code := 'PRICE_OBJECT';
              RAISE validation_exception;

          END IF;

          IF trans.destination_country_id IS NULL
             AND NVL(ec_ctrl_system_attribute.attribute_text(Ecdp_Timestamp.getCurrentSysdate, 'DEST_COUNTRY_AT_TRANS', '<='), 'Y') = 'Y' THEN
              p_val_msg := 'Missing Destination Country.';
              p_val_code := 'DESTINATION_COUNTRY';
              RAISE validation_exception;

          END IF;

          IF trans.origin_country_id IS NULL
             AND NVL(ec_ctrl_system_attribute.attribute_text(Ecdp_Timestamp.getCurrentSysdate, 'ORIG_COUNTRY_AT_TRANS', '<='), 'Y') = 'Y' THEN
              p_val_msg := 'Missing Origin Country.';
              p_val_code := 'ORIGIN_COUNTRY';
              RAISE validation_exception;

          END IF;

          -- if period based, validate supply from and to date
          IF Trans.transaction_scope = 'PERIOD_BASED' THEN

              IF Trans.supply_from_date IS NULL THEN
                p_val_msg := 'Missing Supply From date.';
                p_val_code := 'SUPPLY_FROM_DATE';
                RAISE validation_exception;
              END IF;

              IF Trans.supply_to_date IS NULL THEN
                p_val_msg := 'Missing Supply To date.';
                p_val_code := 'SUPPLY_TO_DATE';
                RAISE validation_exception;
              END IF;

/*              IF Trans.entry_point_id IS NULL THEN
                p_val_msg := 'Missing Entry point.';
                p_val_code := 'ENTRY_POINT';
                RAISE validation_exception;
              END IF;*/

              IF Trans.delivery_point_id IS NULL THEN
                p_val_msg := 'Missing Delivery point.';
                p_val_code := 'DELIVERY_POINT';
                RAISE validation_exception;
              END IF;

          -- if cargo based, validate the date required by the price concept
          ELSIF Trans.transaction_scope = 'CARGO_BASED' THEN

              IF Trans.cargo_name IS NULL THEN
                p_val_msg := 'Missing Cargo Name.';
                p_val_code := 'CARGO';
                RAISE validation_exception;
              END IF;

              IF Trans.parcel_name IS NULL THEN
                p_val_msg := 'Missing Parcel Name.';
                p_val_code := 'PARCEL';
                RAISE validation_exception;
              END IF;

              IF Trans.qty_type IS NULL THEN
                p_val_msg := 'Missing Quantity Type.';
                p_val_code := 'QTY_TYPE';
                RAISE validation_exception;
              END IF;

              IF Trans.consignor IS NULL THEN
                p_val_msg := 'Missing Consignor.';
                p_val_code := 'CONSIGNOR';
                RAISE validation_exception;
              END IF;

              IF Trans.consignee IS NULL THEN
                p_val_msg := 'Missing Consignee.';
                p_val_code := 'CONSIGNEE';
                RAISE validation_exception;
              END IF;

              IF Trans.Carrier_Id IS NULL THEN
                p_val_msg := 'Missing Carrier.';
                p_val_code := 'VESSEL';
                RAISE validation_exception;
              END IF;

              IF Trans.Bl_Date IS NULL THEN
                p_val_msg := 'Missing BL Date.';
                p_val_code := 'BL_DATE';
                RAISE validation_exception;
              END IF;


              IF Trans.posd_base_code = 'DELIVERY_COMMENCED_DATE' THEN

                  IF Trans.delivery_date_commenced IS NULL THEN
                      p_val_msg := 'Missing Delivery Date Commenced.';
                      p_val_code := 'DEL_DATE_COMMENCED';
                      RAISE validation_exception;
                  END IF;

                  IF Trans.discharge_port_id IS NULL THEN
                      p_val_msg := 'Missing Discharge Port.';
                      p_val_code := 'DISCHARGE_PORT';
                      RAISE validation_exception;
                  END IF;

              END IF;

              IF Trans.posd_base_code = 'DELIVERY_COMPLETED_DATE' THEN

                  IF Trans.delivery_date_completed IS NULL THEN
                      p_val_msg := 'Missing Delivery Date Completed.';
                      p_val_code := 'DEL_DATE_COMPLETED';
                      RAISE validation_exception;
                  END IF;

                  IF Trans.discharge_port_id IS NULL THEN
                      p_val_msg := 'Missing Discharge Port.';
                      p_val_code := 'DISCHARGE_PORT';
                      RAISE validation_exception;
                  END IF;

              END IF;

              IF Trans.posd_base_code = 'LOADING_COMMENCED_DATE' THEN

                  IF Trans.loading_date_commenced IS NULL THEN
                      p_val_msg := 'Missing Loading Date Commenced.';
                      p_val_code := 'LOAD_DATE_COMMENCED';
                      RAISE validation_exception;
                  END IF;

                  IF Trans.loading_port_id IS NULL THEN
                      p_val_msg := 'Missing Loading Port.';
                      p_val_code := 'LOADING_PORT';
                      RAISE validation_exception;
                  END IF;

              END IF;

              IF Trans.posd_base_code = 'LOADING_COMPLETED_DATE' THEN

                  IF Trans.loading_date_completed IS NULL THEN
                      p_val_msg := 'Missing Loading Date Completed.';
                      p_val_code := 'LOAD_DATE_COMPLETED';
                      RAISE validation_exception;
                  END IF;

                  IF Trans.loading_port_id IS NULL THEN
                      p_val_msg := 'Missing Loading Port.';
                      p_val_code := 'LOADING_PORT';
                      RAISE validation_exception;
                  END IF;
              END IF;
         END IF; -- cargo based
       END IF; -- Count qty line items > 0


       lb_ifac_price := IsIfacQtyPrice(Trans.transaction_key);


       -- Line Item Validation
       FOR LIcur IN c_li(Trans.transaction_key) LOOP

          -- Check qty line item unit price
          IF (LIcur.line_item_based_type = 'QTY' AND LIcur.Unit_Price IS NULL) THEN
             p_val_msg := 'Missing Quantity Line Item Unit Price.';
             p_val_code := 'LI_UNIT_PRICE';
             RAISE validation_exception;
          END IF;

          -- General check on all line item's Pricing_value, Pricing_vat_value and Pricing_total
          IF LIcur.pricing_value IS NULL THEN
             p_val_msg := 'Missing ' || ec_prosty_codes.code_text(LIcur.line_item_based_type, 'LINE_ITEM_BASED_TYPE') || ' Line Item Pricing Value.' ;
             p_val_code := 'LI_PRICING_VALUE';
             RAISE validation_exception;
          END IF;

          IF LIcur.pricing_vat_value IS NULL THEN
             p_val_msg := 'Missing ' || ec_prosty_codes.code_text(LIcur.line_item_based_type, 'LINE_ITEM_BASED_TYPE') || ' Line Item Pricing VAT Value.';
             p_val_code := 'LI_PRICING_VAT_VALUE';
             RAISE validation_exception;
          END IF;

          IF LIcur.pricing_total IS NULL THEN
             p_val_msg := 'Missing ' || ec_prosty_codes.code_text(LIcur.line_item_based_type, 'LINE_ITEM_BASED_TYPE') || ' Line Item Pricing Total Value.';
             p_val_code := 'LI_PRICING_TOTAL_VALUE';
             RAISE validation_exception;
          END IF;


          IF LIcur.line_item_based_type like 'PERCENTAGE%' THEN

             IF LIcur.percentage_value IS NULL THEN
                p_val_msg := 'Missing Percentage Line Item Percent Rate.';
                p_val_code := 'PCT_RATE';
                RAISE validation_exception;
                  END IF;

             IF LIcur.percentage_base_amount IS NULL THEN
                p_val_msg := 'Missing Percentage Line Item Percent Base Amount.';
                p_val_code := 'PCT_BASE_AMOUNT';
                RAISE validation_exception;
             END IF;

          END IF;

          IF LIcur.line_item_based_type = 'FIXED_VALUE' THEN
             NULL;
          END IF;

          IF LIcur.line_item_based_type = 'FREE_UNIT' THEN

             IF LIcur.Uom1_Code IS NOT NULL AND LIcur.Qty1 IS NULL THEN
                p_val_msg := 'Missing Free Unit Line Item Quantity 1.';
                p_val_code := 'FREE_QTY1';
                RAISE validation_exception;
             END IF;

             IF LIcur.Uom2_Code IS NOT NULL AND LIcur.Qty2 IS NULL THEN
                p_val_msg := 'Missing Free Unit Line Item Quantity 2.';
                p_val_code := 'FREE_QTY2';
                RAISE validation_exception;
          END IF;

             IF LIcur.Uom3_Code IS NOT NULL AND LIcur.Qty3 IS NULL THEN
                p_val_msg := 'Missing Free Unit Line Item Quantity 3.';
                p_val_code := 'FREE_QTY3';
                RAISE validation_exception;
             END IF;

             IF LIcur.Uom4_Code IS NOT NULL AND LIcur.Qty4 IS NULL THEN
                p_val_msg := 'Missing Free Unit Line Item Quantity 4.';
                p_val_code := 'FREE_QTY4';
                RAISE validation_exception;
             END IF;
          END IF;

          IF LIcur.line_item_based_type = 'INTEREST' THEN

             IF LIcur.interest_type IS NULL THEN
                p_val_msg := 'Missing Interest Line Item Rate Type.';
                p_val_code := 'INTEREST_RATE_TYPE';
                RAISE validation_exception;
             END IF;

             IF LIcur.interest_base_amount IS NULL THEN
                p_val_msg := 'Missing Interest Line Item Base Amount.';
                p_val_code := 'INTEREST_BASE_AMOUNT';
                RAISE validation_exception;
             END IF;

             IF LIcur.rate_offset IS NULL THEN
                p_val_msg := 'Missing Interest Line Item Rate Offset.';
                p_val_code := 'INTEREST_RATE_OFFSET';
                RAISE validation_exception;
             END IF;

             IF LIcur.compounding_period IS NULL THEN
                p_val_msg := 'Missing Interest Line Item Compounding Period.';
                p_val_code := 'INTEREST_COMPOUNDING_PERIOD';
                RAISE validation_exception;
             END IF;

             IF LIcur.interest_from_date IS NULL THEN
                p_val_msg := 'Missing Interest Line Item From Date.';
                p_val_code := 'INTEREST_FROM_DATE';
                RAISE validation_exception;
             END IF;

             IF LIcur.interest_to_date IS NULL THEN
                p_val_msg := 'Missing Interest Line Item To Date.';
                p_val_code := 'INTEREST_TO_DATE';
                RAISE validation_exception;
             END IF;

             IF LIcur.line_item_type IS NULL THEN
                p_val_msg := 'Missing Interest Line Item Type.';
                p_val_code := 'INTEREST_LINE_ITEM_TYPE';
                RAISE validation_exception;
             END IF;
          END IF;



          -- check for field distribution setup
          FOR cur IN c_line_item_dist (LICur.Line_Item_Key) LOOP
             IF cur.dist_count = 0 THEN
                p_val_msg := 'Missing distribution to field level. for line item ['||LICur.Line_Item_Key||'] '||
                             'Verify that there are field level Stream Items defined in the ' ||
                             'Transaction Distribution Setup screen for the transaction template being basis for this transaction';
                p_val_code := 'FIELD_DIST';
                RAISE validation_exception;
             END IF;
          END LOOP;

          -- check for company distribution setup
          FOR cur IN c_li_dist_company (LICur.Line_Item_Key) LOOP
             IF cur.company_count = 0 THEN
                p_val_msg := 'Missing distribution to company level. ' ||
                             'Verify that there are company level Stream Items defined in the ' ||
                             'Transaction Distribution Setup screen for the transaction template being basis for this transaction';
                p_val_code := 'COMPANY_DIST';
                RAISE validation_exception;
             END IF;
          END LOOP;



          -- Check prices
          IF LICur.Line_Item_Based_Type IN ('QTY','FREE_UNIT_PRICE_OBJECT') THEN

              IF ec_cont_document.document_concept(ec_cont_transaction.document_key(Trans.transaction_key)) = 'REALLOCATION' OR
                 ec_cont_transaction.reversal_ind(Trans.transaction_key) = 'Y' OR
                 lb_ifac_price THEN

                 -- If reallocation document or reversal transaction, use the same prices as preceding
                 NULL;

              ELSE

                 BEGIN
                   -- Get price in non-silent mode. Will raise exceptions if price can not be found.
                   ln_price := GetQtyPrice(LIcur.object_id,
                                           LIcur.line_item_key,
                                           LIcur.line_item_template_id,
                                           Trans.transaction_key,
                                           Trans.Price_Date,
                                           LIcur.Line_Item_Based_Type,
                                           LIcur.Price_Object_Id,
                                           LIcur.Price_Element_Code,
                                           'N');
                 EXCEPTION
                    WHEN OTHERS THEN
                      p_val_msg := SUBSTR(SQLERRM, 1, 240);
                      p_val_code := 'QTY_PRICE_VAL';
                      RAISE validation_exception;
                 END;

                 -- Now check if the newest price is in use ono the line item
                 IF ln_price IS NOT NULL THEN
                   IF LICur.Unit_Price != ln_price THEN
                      p_val_msg := 'Unit Price for Line Item ' || LIcur.Name || ' ['||LICur.Line_Item_Key||'] has expired. Please Update Prices. Old: ' || LICur.Unit_Price || ' New: ' || ln_price;
                      p_val_code := 'UNIT_PRICE_EXPIRED';
                      RAISE validation_exception;
                   END IF;
                 END IF;
             END IF;
         END IF;
      END LOOP; -- Line items loop

    -- If MPD can have preceding open transactions.

        IF trans.Reversed_Trans_Key IS NOT NULL THEN
           IF ec_cont_document.document_level_code(lrec_reversed_trans.document_key) != 'BOOKED' THEN

              p_val_msg := 'Preceding Transactions on Document '|| lrec_reversed_trans.document_key || ' are not Booked';
              p_val_code := 'BOOK_PRECEDING';
              RAISE validation_exception;

            END IF;
        END IF;


    END LOOP; -- Transactions
    IF NOT lb_transaction_found THEN
        p_val_code := 'TRANS_MISSING';
        p_val_msg := ec_prosty_codes.code_text(p_val_code, 'COMPLETE_DOC_ACTION');
        lv2_transaction_key := 'null';
        RAISE validation_exception;
    END IF;
   END IF;

EXCEPTION
  WHEN validation_exception THEN
    IF p_silent_ind = 'N' THEN
       RAISE_APPLICATION_ERROR(-20000, 'Validation failed for transaction: ' || lv2_transaction_key ||
                                       ', document: ' || p_document_key ||
                                       ', contract: ' || Ec_Contract.object_code(lrec_doc.object_id) || ' (' || Nvl(lrec_doc.contract_name, ' ') || ').' ||
                                       '\n\n' || p_val_msg);
    END IF;
END ValidateTransactions;

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE ValidateDocQtyValue (
    p_object_id VARCHAR2,
    p_document_id VARCHAR2
)

IS

CURSOR c_trans IS
SELECT transaction_key id
FROM cont_transaction
WHERE object_id = p_object_id
AND document_key = p_document_id
;

CURSOR c_line_item(pc_transaction_id VARCHAR2) IS
SELECT NVL(name,'<No name supplied>') LI_NAME, line_item_key, ec_prosty_codes.code_text(line_item_based_type, 'LINE_ITEM_BASED_TYPE') LI_TYPE
FROM cont_line_item
WHERE object_id = p_object_id
AND transaction_key = pc_transaction_id
AND pricing_value IS NULL;

lv2_err_msg VARCHAR2(200);
error EXCEPTION;

BEGIN

    FOR Trans IN c_trans LOOP
        lv2_err_msg := NULL;
        FOR LineItem IN c_line_item(Trans.id) LOOP

            lv2_err_msg := 'Missing value for Line Item "' || LineItem.LI_name || '" (Based Type: ' || LineItem.Li_Type || ') in Transaction "'|| Trans.Id ||'". Please correct.';
            RAISE error;

        END LOOP;

    END LOOP;

EXCEPTION

    WHEN error THEN

        RAISE_APPLICATION_ERROR(-20000,lv2_err_msg);

END ValidateDocQtyValue;


PROCEDURE ValidateNumberOfQtyLI(
          p_trans_tmpl_id VARCHAR2,
          p_daytime DATE
          )
IS

  CURSOR c_count(cp_trans_tmpl_id VARCHAR2, cp_daytime DATE) IS
  SELECT COUNT(*) cnt
    FROM line_item_template lit, line_item_tmpl_version litv
   WHERE lit.transaction_template_id = cp_trans_tmpl_id
     AND lit.object_id = litv.object_id
     AND cp_daytime >= Nvl(lit.start_date,cp_daytime-1)
     AND cp_daytime < Nvl(lit.end_date,cp_daytime+1)
     AND cp_daytime >= Nvl(litv.daytime,cp_daytime-1)
     AND cp_daytime < Nvl(litv.end_date,cp_daytime+1)
     AND litv.line_item_based_type = 'QTY';

  lrec_trans transaction_tmpl_version%ROWTYPE := ec_transaction_tmpl_version.row_by_pk(p_trans_tmpl_id, p_daytime, '<=');
  too_many_qty_line_items EXCEPTION;

BEGIN

  IF lrec_trans.price_src_type = 'PRICING_VALUE' THEN

    FOR rsC IN c_count(p_trans_tmpl_id, p_daytime) LOOP

       IF rsC.cnt > 1 THEN

         RAISE too_many_qty_line_items;

       END IF;


    END LOOP;


  END IF;

EXCEPTION
  WHEN too_many_qty_line_items THEN
    RAISE_APPLICATION_ERROR(-20000, 'This transaction template can not be set up with Price Source Type Pricing Value.\n It has previously been mapped against more than one quantity line item.\n\nWhen calculating unit price based on Pricing Value it will not be possible to determine what line item to update.');


END ValidateNumberOfQtyLI;


PROCEDURE UpdTransQtyInVO
 (p_object_id VARCHAR2,
  p_doc_id VARCHAR2,
  p_user VARCHAR2,
  p_document_type VARCHAR2,
  p_reverse_factor NUMBER DEFAULT 1, -- multiply qty with this factor
  p_document_status             VARCHAR2 DEFAULT NULL,
  p_is_cascade_scheduled        VARCHAR2 DEFAULT 'N'
  )

IS

CURSOR c_trans IS
SELECT *
FROM cont_transaction
WHERE object_id = p_object_id
AND document_key = p_doc_id;

CURSOR c_liv(pc_transaction_id VARCHAR2) IS
SELECT *
FROM cont_line_item x
WHERE object_id = p_object_id
AND   document_key = p_doc_id
AND   transaction_key = pc_transaction_id
AND line_item_based_type = 'QTY'
AND move_qty_to_vo_ind = 'Y'
;

CURSOR c_livf (pc_transaction_id VARCHAR2) IS
SELECT *
FROM cont_line_item_dist clid
WHERE object_id = p_object_id
AND transaction_key = pc_transaction_id
AND document_key = p_doc_id
AND line_item_based_type = 'QTY'
AND move_qty_to_vo_ind = 'Y';

CURSOR c_livfc (cp_line_item_key VARCHAR2, cp_dist_id VARCHAR2) IS
SELECT *
  FROM cont_li_dist_company clidc
 WHERE object_id = p_object_id
   AND line_item_key = cp_line_item_key
   AND clidc.dist_id = cp_dist_id
   AND document_key = p_doc_id
   AND line_item_based_type = 'QTY'
   AND move_qty_to_vo_ind = 'Y';


lv2_use_si_ind          	VARCHAR2(32);
lrec_ttv                	transaction_tmpl_version%ROWTYPE;

ltab_uom_set EcDp_Unit.t_uomtable;

BEGIN

      FOR Trans IN c_trans LOOP
          lrec_ttv := ec_transaction_tmpl_version.row_by_pk(Trans.Trans_Template_Id, Trans.Daytime, '<=');
          lv2_use_si_ind := lrec_ttv.use_stream_items_ind;

          FOR Liv IN c_liv(Trans.transaction_key) LOOP

              -- update SI in VO at transaction level, always pass UOM1
              ltab_uom_set := EcDp_Unit.t_uomtable();


          EcDp_Unit.GenQtyUOMSet(ltab_uom_set
                                 ,Liv.qty1 * p_reverse_factor, Liv.uom1_code
                                 ,Liv.qty2 * p_reverse_factor, Liv.uom2_code
                                 ,Liv.qty3 * p_reverse_factor, Liv.uom3_code
                                 ,Liv.qty4 * p_reverse_factor, Liv.uom4_code
                                 );

              IF ltab_uom_set.EXISTS(1) THEN

                  -- mark use
                  UPDATE stim_mth_value
                      SET transaction_key = Trans.transaction_key
                         ,last_updated_by = 'SYSTEM'
                      WHERE object_id = Trans.stream_item_id
                      AND daytime = trunc(Trans.transaction_date,'MM');

                  -- update stream item
                  IF UPPER(lv2_use_si_ind) = 'Y' THEN
                     EcDp_Stream_Item.UpdAddToSIValueMth(Trans.stream_item_id,
                                                      Trans.transaction_date,
                                                      ltab_uom_set,
                                                      p_document_status,
                                                      p_user,
                                                      'ADD_INCR',
                                                      p_reverse_factor,
                                                      false,
                                                      p_is_cascade_scheduled => p_is_cascade_scheduled);
                  END IF;
                  EcDp_VOQty.CleanUp(Trans.stream_item_id,trunc(Trans.transaction_date,'MM'));

              END IF;

          END LOOP; -- line_items

          -- then loop through any dist split
          FOR Livf IN c_livf(Trans.transaction_key) LOOP

              IF Livf.stream_item_id <> Trans.stream_item_id THEN -- avoid situation where 100% dist split

                  -- update SI in VO at field level, always pass UOM1
                  ltab_uom_set := EcDp_Unit.t_uomtable();

                  EcDp_Unit.GenQtyUOMSet(ltab_uom_set
                                         ,Livf.qty1 * p_reverse_factor, Livf.uom1_code
                                         ,Livf.qty2 * p_reverse_factor, Livf.uom2_code
                                         ,Livf.qty3 * p_reverse_factor, Livf.uom3_code
                                         ,Livf.qty4 * p_reverse_factor, Livf.uom4_code
                                         );

                  IF ltab_uom_set.EXISTS(1) THEN

                      -- mark use
                      UPDATE stim_mth_value
                      SET transaction_key = Livf.transaction_key
                         ,last_updated_by = 'SYSTEM'
                      WHERE object_id = Livf.stream_item_id
                      AND daytime = trunc(Trans.transaction_date,'MM');

                      -- update stream item
                      IF UPPER(lv2_use_si_ind) = 'Y' THEN
                         EcDp_Stream_Item.UpdAddToSIValueMth(Livf.stream_item_id,
                                                           Trans.transaction_date,
                                                           ltab_uom_set,
                                                           p_document_status,
                                                           p_user,
                                                           'ADD_INCR',
                                                           p_reverse_factor,
                                                           false,
                                                           p_is_cascade_scheduled => p_is_cascade_scheduled);
                      END IF;
                      EcDp_VOQty.CleanUp(livf.stream_item_id, trunc(Trans.transaction_date,'MM')); -- DRO

                  END IF;

              END IF;

              -- then loop through any company split for line_item/stream item combination
              FOR Livfc IN c_livfc(livf.line_item_key, livf.dist_id) LOOP

                  IF Livfc.Company_Stream_Item_Id <> Trans.stream_item_id  AND
                     Livfc.Company_Stream_Item_Id <> livf.stream_item_id  THEN -- avoid situation where 100% dist split and 100% company_split

                      -- update SI in VO at field level, always pass UOM1
                      ltab_uom_set := EcDp_Unit.t_uomtable();

                      EcDp_Unit.GenQtyUOMSet(ltab_uom_set
                                             ,Livfc.qty1 * p_reverse_factor, Livfc.uom1_code
                                             ,Livfc.qty2 * p_reverse_factor, Livfc.uom2_code
                                             ,Livfc.qty3 * p_reverse_factor, Livfc.uom3_code
                                             ,Livfc.qty4 * p_reverse_factor, Livfc.uom4_code
                                             );

                      IF ltab_uom_set.EXISTS(1) THEN

                          -- mark use
                          UPDATE stim_mth_value
                          SET transaction_key = Livfc.transaction_key
                             ,last_updated_by = 'SYSTEM'
                          WHERE object_id = Livfc.Company_Stream_Item_Id
                          AND daytime = trunc(Trans.transaction_date,'MM');

                          -- update stream item
                          IF UPPER(lv2_use_si_ind) = 'Y' THEN
                             EcDp_Stream_Item.UpdAddToSIValueMth(Livfc.Company_Stream_Item_Id,
                                                               Trans.transaction_date,
                                                               ltab_uom_set,
                                                               p_document_status,
                                                               p_user,
                                                               'ADD_INCR',
                                                               p_reverse_factor,
                                                               false,
                                                               p_is_cascade_scheduled => p_is_cascade_scheduled);
                           END IF;

                      END IF;

                  END IF;

              END LOOP; -- company split



          END LOOP; -- dist split

      END LOOP; -- transactions

END UpdTransQtyInVO;



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  UpdFromTransactionGeneral
-- Description    : Called on save-service from process transaction general (using a business action)
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
PROCEDURE UpdFromTransactionGeneral
 (p_object_id VARCHAR2,
  p_doc_id VARCHAR2,
  p_trans_id VARCHAR2,
  p_daytime DATE,
  p_user VARCHAR2
)
IS

lv2_cont_master_uom VARCHAR2(32) := NULL;
lrec_tran cont_transaction%ROWTYPE := ec_cont_transaction.row_by_pk(p_trans_id);
lrec_tran_qty cont_transaction_qty%ROWTYPE := ec_cont_transaction_qty.row_by_pk(p_trans_id);

BEGIN

    lv2_cont_master_uom := ec_ctrl_unit.uom_group(ec_transaction_tmpl_version.uom1_code(lrec_tran.trans_template_id, p_daytime, '<='));

    -- This function picks quantities from VO / Cargo Interface / Period Interface
    FillTransaction(p_trans_id, lrec_tran.price_date, p_user);

    -- Check if UOM match on contract and in VO
    IF (lrec_tran.transaction_date IS NOT NULL AND lv2_cont_master_uom IS NOT NULL AND lrec_tran.Stream_Item_Id IS NOT NULL) THEN
       ValidateUOMs(p_object_id,p_trans_id, lrec_tran.transaction_date);
    END IF;

    -- Transaction Date might have been set since last read
    lrec_tran.transaction_date := ec_cont_transaction.transaction_date(p_trans_id);

    -- Check if UOM match on contract and in VO
    IF lv2_cont_master_uom IS NOT NULL AND lrec_tran.Stream_Item_Id IS NOT NULL THEN
       ValidateUOMs(p_object_id,p_trans_id, lrec_tran.transaction_date);
    END IF;

    -- Update percentage line item
    Updpercentagelineitem(p_trans_id,p_user);

    IF (lrec_tran.dist_split_type = 'SOURCE_SPLIT' AND lrec_tran.transaction_date IS NOT NULL) THEN
        Ecdp_Transaction.UpdTransSourceSplitShare(p_trans_id
                                                 ,lrec_tran_qty.net_qty1
                                                 ,lrec_tran_qty.uom1_code
                                                 ,lrec_tran.transaction_date);
    END IF;


END UpdFromTransactionGeneral;

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE ValidateUOMs (
    p_object_id             VARCHAR2,
    p_transaction_id        VARCHAR2,
    p_daytime               DATE    -- Point of sale date (transaction_date)
)
IS

CURSOR c_split(pc_transaction_key VARCHAR2) IS
  SELECT DISTINCT clid.stream_item_id id, dist_id
    FROM cont_line_item_dist clid
   WHERE clid.transaction_key = pc_transaction_key;

CURSOR c_company(cp_transaction_key VARCHAR2, cp_dist_id VARCHAR2) IS
  SELECT DISTINCT clidc.company_stream_item_id
    FROM cont_li_dist_company clidc
   WHERE clidc.transaction_key = cp_transaction_key
     AND clidc.dist_id = cp_dist_id;

lv2_uom VARCHAR2(32);
lv2_uom1 VARCHAR2(32);
lv2_uom2 VARCHAR2(32);
lv2_uom3 VARCHAR2(32);
lv2_uom4 VARCHAR2(32);
lv2_uom_group VARCHAR2(32);

lv2_vo_row stim_mth_value%ROWTYPE;

lv2_stream_item_id VARCHAR2(32);

no_uom_match EXCEPTION;
no_uom_on_contract EXCEPTION;
no_vo_number EXCEPTION;
no_pos_date EXCEPTION;

ltab_uom_set EcDp_Unit.t_uomtable;

BEGIN

    IF IsQtyTransaction(p_object_id,p_transaction_id) THEN -- only do this if we have QTY line items


       IF p_daytime IS NULL THEN

         RAISE no_pos_date;

       END IF;

       lv2_stream_item_id := ec_cont_transaction.stream_item_id(p_transaction_id);

       ltab_uom_set := EcDp_Unit.t_uomtable();

       lv2_uom1 := ec_transaction_tmpl_version.uom1_code(ec_cont_transaction.trans_template_id(p_transaction_id), p_daytime, '<=');
       lv2_uom2 := ec_transaction_tmpl_version.uom2_code(ec_cont_transaction.trans_template_id(p_transaction_id), p_daytime, '<=');
       lv2_uom3 := ec_transaction_tmpl_version.uom3_code(ec_cont_transaction.trans_template_id(p_transaction_id), p_daytime, '<=');
       lv2_uom4 := ec_transaction_tmpl_version.uom4_code(ec_cont_transaction.trans_template_id(p_transaction_id), p_daytime, '<=');

       EcDp_Unit.GenQtyUOMSet(ltab_uom_set
                               ,1, lv2_uom1
                               ,1, lv2_uom2
                               ,1, lv2_uom3
                               ,1, lv2_uom4
                               );


       IF ltab_uom_set.EXISTS(1) THEN

          -- attempt a conversion against SI master

          lv2_uom_group := ec_stream_item_version.master_uom_group(lv2_stream_item_id, p_daytime, '<=');

          lv2_vo_row := NULL;
          lv2_vo_row := ec_stim_mth_value.row_by_pk(lv2_stream_item_id, TRUNC(p_daytime,'MM'));
          IF (lv2_vo_row.object_id IS NULL) THEN
             RAISE no_vo_number;
          END IF;

          IF lv2_uom_group = 'V' THEN

             lv2_uom := ec_stim_mth_value.volume_uom_code(lv2_stream_item_id, TRUNC(p_daytime,'MM'));

          ELSIF lv2_uom_group = 'M' THEN

             lv2_uom := ec_stim_mth_value.mass_uom_code(lv2_stream_item_id, TRUNC(p_daytime,'MM'));

          ELSIF lv2_uom_group = 'E' THEN

             lv2_uom := ec_stim_mth_value.energy_uom_code(lv2_stream_item_id, TRUNC(p_daytime,'MM'));

          END IF;


          IF EcDp_Revn_Unit.GetUOMSetQty(ltab_uom_set, lv2_uom, p_daytime, lv2_stream_item_id) IS NULL THEN

             RAISE no_uom_match;

          END IF;

       ELSE
           -- if no UOMs, then certainly no match...
             RAISE no_uom_on_contract;

       END IF;


       -- check that any transfer to VO is ok wrt UOMS
       FOR SplitSICur IN c_split(p_transaction_id) LOOP

           ltab_uom_set := EcDp_Unit.t_uomtable();
           lv2_stream_item_id := SplitSICur.id;

           lv2_uom1 := ec_transaction_tmpl_version.uom1_code(ec_cont_transaction.trans_template_id(p_transaction_id), p_daytime, '<=');
           lv2_uom2 := ec_transaction_tmpl_version.uom2_code(ec_cont_transaction.trans_template_id(p_transaction_id), p_daytime, '<=');
           lv2_uom3 := ec_transaction_tmpl_version.uom3_code(ec_cont_transaction.trans_template_id(p_transaction_id), p_daytime, '<=');
           lv2_uom4 := ec_transaction_tmpl_version.uom4_code(ec_cont_transaction.trans_template_id(p_transaction_id), p_daytime, '<=');

            EcDp_Unit.GenQtyUOMSet(ltab_uom_set
                                   ,1, lv2_uom1
                                   ,1, lv2_uom2
                                   ,1, lv2_uom3
                                   ,1, lv2_uom4
                                   );

           IF ltab_uom_set.EXISTS(1) and lv2_stream_item_id IS NOT NULL THEN

              -- attempt a conversion against SI master
              lv2_vo_row := NULL;
              lv2_vo_row := ec_stim_mth_value.row_by_pk(lv2_stream_item_id, TRUNC(p_daytime,'MM'));
              IF (lv2_vo_row.object_id IS NULL) THEN
                 RAISE no_vo_number;
              END IF;

              lv2_uom_group := ec_stream_item_version.master_uom_group(lv2_stream_item_id, p_daytime, '<=');

              IF lv2_uom_group = 'V' THEN

                 lv2_uom := ec_stim_mth_value.volume_uom_code(lv2_stream_item_id, TRUNC(p_daytime,'MM'));

              ELSIF lv2_uom_group = 'M' THEN

                 lv2_uom := ec_stim_mth_value.mass_uom_code(lv2_stream_item_id, TRUNC(p_daytime,'MM'));

              ELSIF lv2_uom_group = 'E' THEN

                 lv2_uom := ec_stim_mth_value.energy_uom_code(lv2_stream_item_id, TRUNC(p_daytime,'MM'));

              END IF;


              IF EcDp_Revn_Unit.GetUOMSetQty(ltab_uom_set, lv2_uom, p_daytime, lv2_stream_item_id) IS NULL THEN

                 RAISE no_uom_match;

              END IF;

            END IF;


            -- Validate SI UOMs for company level
            FOR rsC IN c_company(p_transaction_id, SplitSICur.dist_id) LOOP

               ltab_uom_set := EcDp_Unit.t_uomtable();
               lv2_stream_item_id := rsC.company_stream_item_id;

               EcDp_Unit.GenQtyUOMSet(ltab_uom_set
                                       ,1, lv2_uom1
                                       ,1, lv2_uom2
                                       ,1, lv2_uom3
                                       ,1, lv2_uom4);

               IF ltab_uom_set.EXISTS(1) AND lv2_stream_item_id IS NOT NULL THEN

                  -- attempt a conversion against SI master
                  lv2_vo_row := NULL;
                  lv2_vo_row := ec_stim_mth_value.row_by_pk(lv2_stream_item_id, TRUNC(p_daytime,'MM'));
                  IF (lv2_vo_row.object_id IS NULL) THEN
                     RAISE no_vo_number;
                  END IF;

                  lv2_uom_group := ec_stream_item_version.master_uom_group(lv2_stream_item_id, p_daytime, '<=');

                  IF lv2_uom_group = 'V' THEN

                     lv2_uom := ec_stim_mth_value.volume_uom_code(lv2_stream_item_id, TRUNC(p_daytime,'MM'));

                  ELSIF lv2_uom_group = 'M' THEN

                     lv2_uom := ec_stim_mth_value.mass_uom_code(lv2_stream_item_id, TRUNC(p_daytime,'MM'));

                  ELSIF lv2_uom_group = 'E' THEN

                     lv2_uom := ec_stim_mth_value.energy_uom_code(lv2_stream_item_id, TRUNC(p_daytime,'MM'));

                  END IF;


                  IF EcDp_Revn_Unit.GetUOMSetQty(ltab_uom_set, lv2_uom, p_daytime, lv2_stream_item_id) IS NULL THEN

                     RAISE no_uom_match;

                  END IF;

               END IF;

            END LOOP;

         END LOOP;

    END IF;

EXCEPTION

   WHEN no_uom_match THEN

        Raise_Application_Error(-20000,'No correspondance between contract UOMs and transaction stream item master UOM for transaction ' ||  p_transaction_id || ' on entered Point of Sale Date '||to_char(p_daytime,'dd-Mon-yyyy')||'.');

   WHEN no_uom_on_contract THEN

        Raise_Application_Error(-20000,'No UOMs on this Contract for transaction : ' ||  p_transaction_id);

   WHEN no_vo_number THEN

        Raise_Application_Error(-20000,'Quantity records (VO) have not been instantiated for \n\n- Stream Item: ' || ec_stream_item.object_code(lv2_stream_item_id) || ' (' || ec_stream_item_version.name(lv2_stream_item_id, p_daytime, '<=') || ') \n- Month: ' || TRUNC(p_daytime,'MM') || ' \n- Transaction: ' ||  p_transaction_id);

   WHEN no_pos_date THEN

        Raise_Application_Error(-20000,'Point Of Sale Date is not set on transaction ' ||  p_transaction_id || '. \n\nPlease provide and try again.');

END ValidateUOMs;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION DelTransaction(
   p_transaction_key VARCHAR2,
   p_child_only VARCHAR2 DEFAULT 'N'
   ) RETURN VARCHAR2
IS
    lrec_trans              cont_transaction%ROWTYPE    := ec_cont_transaction.row_by_pk(p_transaction_key);
    lrec_doc                cont_document%ROWTYPE       := ec_cont_document.row_by_pk(lrec_trans.document_key);
    lb_msg_ind              BOOLEAN                     := TRUE;
    lv2_isDeletable         VARCHAR2(300);
    ln_transaction_count    NUMBER;

BEGIN
    lv2_isDeletable := isTransactionDeletable(p_transaction_key, p_msg_ind => 'Y');
    IF lv2_isDeletable <> 'Y' THEN
        -- Transaction cannot be deleted
        RETURN lv2_isDeletable;
    ELSE
        -- Delete transaction and subelements:

        -- Delete from cont_line_item_dist_uom, since these are "detail" records of transaction
        DELETE FROM cont_line_item_dist_uom t
         WHERE t.line_item_key IN
               (SELECT t2.line_item_key
                  FROM cont_line_item_dist t2
                 WHERE t2.transaction_key = lrec_trans.transaction_key);

        -- Delete from cont_line_item_dist, since these are "detail" records of transaction
        DELETE FROM cont_line_item_dist t
         WHERE t.transaction_key = lrec_trans.transaction_key;

        -- Delete from cont_line_item, since these are "detail" records of transaction
        DELETE FROM cont_line_item_uom t
         WHERE t.line_item_key IN
               (SELECT t2.line_item_key
                  FROM cont_line_item t2
                 WHERE t2.transaction_key = lrec_trans.transaction_key);
        -- Delete from cont_line_item, since these are "detail" records of transaction
        DELETE FROM cont_line_item t
         WHERE t.transaction_key = lrec_trans.transaction_key;

        -- Delete from cont_transaction_qty, since these are "attached" records of transaction
        DELETE FROM cont_transaction_qty_uom t
         WHERE t.transaction_key = lrec_trans.transaction_key;

        -- Delete from cont_transaction_qty, since these are "attached" records of transaction
        DELETE FROM cont_transaction_qty t
         WHERE t.transaction_key = lrec_trans.transaction_key;

        -- Delete from cont_trans_comments, since there are "attached" records of the transaction
        DELETE FROM cont_trans_comments t
         WHERE t.transaction_key = lrec_trans.transaction_key;

         UPDATE ifac_sales_qty
            SET transaction_key = NULL,
                trans_key_set_ind = 'N',
                ignore_ind = 'Y'
          WHERE transaction_key = lrec_trans.transaction_key
            AND contract_id = lrec_trans.object_id;

         UPDATE ifac_cargo_value
            SET transaction_key = NULL,
                trans_key_set_ind = 'N',
                ignore_ind = 'Y'
          WHERE transaction_key = lrec_trans.transaction_key
            AND contract_id = lrec_trans.object_id;

        -- Delete from cont_transaction, since this are the one to be deleted
        IF (p_child_only = 'N') THEN
            DELETE FROM cont_transaction t WHERE t.transaction_key = lrec_trans.transaction_key;
        END IF;
    END IF;

    RETURN lv2_isDeletable;
END DelTransaction;

PROCEDURE DelEmptyTransactions (
   p_document_key VARCHAR2
   )
IS

  CURSOR cur_ct(cp_document_key VARCHAR2) IS
    SELECT ct.object_id, ct.transaction_key, ct.document_key
      FROM cont_transaction ct
     WHERE ct.document_key = cp_document_key
       AND nvl(ct.reversal_ind,'N') = 'N';

  ltab_trans t_trans_table := t_trans_table();
  ln_cnt NUMBER;
  lb_deleted BOOLEAN := FALSE;

BEGIN

   -- Find transaction which will be deleted and put them into a table
   FOR cTrans in cur_ct(p_document_key) LOOP

      IF IsTransactionEmpty(cTrans.transaction_key) THEN
         ltab_trans.extend;
         ltab_trans(ltab_trans.last).object_id := cTrans.object_id;
         ltab_trans(ltab_trans.last).document_key := cTrans.document_key;
         ltab_trans(ltab_trans.last).transaction_key := cTrans.transaction_key;
       END IF;
   END LOOP;


    IF (ltab_trans.count > 0) THEN
        -- Delete the transactions
        FOR ln_cnt IN 1..ltab_trans.count LOOP

          lb_deleted := DelEmptyTransaction(ltab_trans(ln_cnt).transaction_key);
            --DelTransaction(ltab_trans(ln_cnt).object_id, ltab_trans(ln_cnt).transaction_key);
        END LOOP;
    END IF;

    -- Empty the package table
    IF lb_deleted THEN
       ltab_trans.delete;
    END IF;

    -- Update VAT country and NO for document
    EcDp_Document.UpdDocumentVat(p_document_key, ec_cont_document.daytime(p_document_key), NULL);

END DelEmptyTransactions;


-- delete single transaction. return true/false indicating if it has been deleted or not.
FUNCTION DelEmptyTransaction (
   p_transaction_key VARCHAR2
   )
RETURN BOOLEAN
IS
  lrec_tran cont_transaction%ROWTYPE    := ec_cont_transaction.row_by_pk(p_transaction_key);
  lb_deleted    BOOLEAN                 := FALSE;
  lv2_feedback  VARCHAR2(300);
BEGIN
    IF lrec_tran.object_id IS NOT NULL THEN
        IF IsTransactionEmpty(lrec_tran.transaction_key) THEN
            lv2_feedback := DelTransaction(lrec_tran.transaction_key);

            IF (lv2_feedback = 'Y') THEN
                lb_deleted := TRUE;
                -- Update VAT country and NO for document
                EcDp_Document.UpdDocumentVat(lrec_tran.document_key, ec_cont_document.daytime(lrec_tran.document_key), NULL);
            ELSE
                Raise_Application_Error(-20000, lv2_feedback);
            END IF;
        END IF;
    ELSE
        lb_deleted := TRUE; -- gone missing..?
    END IF;
    RETURN lb_deleted;
END DelEmptyTransaction;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : DelNewTransactions
-- Description    : Deletes new transactions in the given document.
-- Using tables   : cont_transaction, cont_line_item
-- Using functions: EcDp_Transaction.DelTransaction
-- Behaviour      : For a dependent or reveral document, a transaction is "new" when it has no relationship
--                  with the preceding document (i.e. not a reversal nor a dependent transaction).
--                  For a new document, all transactions are "new" transactions.
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE DelNewTransactions(
   p_document_key VARCHAR2
   )
--</EC-DOC>
IS
    CURSOR c_new_transactions(cp_document_key VARCHAR2) IS
    SELECT ct.object_id, ct.transaction_key
      FROM cont_transaction ct
     WHERE ct.document_key = cp_document_key
       AND ct.preceding_trans_key IS NULL
       AND ct.reversed_trans_key IS NULL;

    lv2_feedback VARCHAR(300);
BEGIN
    FOR i_trans IN c_new_transactions(p_document_key) LOOP
        lv2_feedback := DelTransaction(i_trans.transaction_key);
        IF lv2_feedback <> 'Y' THEN
            Raise_Application_Error(-20000, lv2_feedback);
        END IF;
    END LOOP;
END DelNewTransactions;



FUNCTION IsTransactionEmpty(
             p_transaction_key VARCHAR2
) RETURN BOOLEAN
IS

  CURSOR c_li(cp_transaction_key VARCHAR2) IS
  SELECT cli.line_item_key
    FROM cont_line_item cli
   WHERE cli.transaction_key = cp_transaction_key;

  lb_ret_val BOOLEAN := TRUE;

BEGIN

  FOR rsLI IN c_li(p_transaction_key) LOOP

      IF NOT EcDp_Line_Item.IsLineItemEmpty(rsLI.Line_Item_Key) THEN

        lb_ret_val := FALSE;
        EXIT;

      END IF;

  END LOOP;

  RETURN lb_ret_val;

END IsTransactionEmpty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- FUNCTION       : UpdTransExRate
-- Description    : This  will update all the exchange rates for selected transaction from exchange
--                  rate table
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : cont_transaction,cont_line_item
--
-- Using functions: EcDp_Currency.GetExRate
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION UpdTransExRate
 (p_transaction_key VARCHAR2,
  p_user VARCHAR2,
  p_pick_ex_rates_from_trans VARCHAR2 DEFAULT 'N'
  )
RETURN VARCHAR2

IS

lrec_cont_transaction cont_transaction%ROWTYPE;

lv2_booking_curr VARCHAR2(32);
lv2_memo_curr VARCHAR2(32);
lv2_local_curr VARCHAR2(32);
lv2_group_curr VARCHAR2(32);
ln_ex_pricing_booking NUMBER;
ln_ex_pricing_memo NUMBER;
ln_ex_booking_local NUMBER;
ln_ex_booking_group NUMBER;
lv_end_user_message   VARCHAR2(1024);
TYPE ln_rec IS RECORD (
                       ex_pric_book VARCHAR2(100),
                       ex_pric_memo VARCHAR2(100),
                       ex_book_local VARCHAR2(100),
                       ex_book_group VARCHAR2(100)
                       );
ln_rec_selected     ln_rec;

BEGIN

lrec_cont_transaction := ec_cont_transaction.row_by_pk(p_transaction_key);


lv2_booking_curr := ec_cont_document.booking_currency_code(lrec_cont_transaction.document_key);
lv2_memo_curr := ec_cont_document.memo_currency_code(lrec_cont_transaction.document_key);
lv2_local_curr := EcDp_Contract_Setup.GetLocalCurrencyCode(ec_cont_transaction.object_id(p_transaction_key), lrec_cont_transaction.daytime);
lv2_group_curr := ec_ctrl_system_attribute.attribute_text(lrec_cont_transaction.daytime, 'GROUP_CURRENCY_CODE', '<=');

     -- Bail out if reallocation. Gets exrates from preceding doc.
    IF ec_cont_document.document_concept(ec_cont_transaction.document_key(p_transaction_key)) != 'REALLOCATION' THEN

     IF (p_pick_ex_rates_from_trans = 'N') THEN

       ln_ex_pricing_booking := ecdp_currency.GetExRateViaCurrency(lrec_cont_transaction.pricing_currency_code,
                                                                      lv2_booking_curr,
                                                                      null,
                                                                      lrec_cont_transaction.ex_pricing_booking_date,
                                                                      lrec_cont_transaction.ex_pricing_booking_id,
                                                                      lrec_cont_transaction.ex_pricing_booking_ts);
       ln_ex_pricing_memo := ecdp_currency.GetExRateViaCurrency(lrec_cont_transaction.pricing_currency_code,
                                                                      lv2_memo_curr,
                                                                      null,
                                                                      lrec_cont_transaction.ex_pricing_memo_date,
                                                                      lrec_cont_transaction.ex_pricing_memo_id,
                                                                      lrec_cont_transaction.ex_pricing_memo_ts);
       ln_ex_booking_local := ecdp_currency.GetExRateViaCurrency(lv2_booking_curr,
                                                                      lv2_local_curr,
                                                                      null,
                                                                      lrec_cont_transaction.ex_booking_local_date,
                                                                      lrec_cont_transaction.ex_booking_local_id,
                                                                      lrec_cont_transaction.ex_booking_local_ts);
       ln_ex_booking_group := ecdp_currency.GetExRateViaCurrency(lv2_booking_curr,
                                                                      lv2_group_curr,
                                                                      null,
                                                                      lrec_cont_transaction.ex_booking_group_date,
                                                                      lrec_cont_transaction.ex_booking_group_id,
                                                                      lrec_cont_transaction.ex_booking_group_ts);
  --Selecting no of rows to be updated.
    BEGIN
     SELECT ex_pricing_booking,
            ex_pricing_memo,
            ex_booking_local,
            ex_booking_group
      INTO ln_rec_selected
      FROM cont_transaction
      WHERE transaction_key = p_transaction_key;

	  EXCEPTION
        WHEN OTHERS THEN
          ln_rec_selected.ex_pric_book := NULL;
          ln_rec_selected.ex_pric_memo := NULL;
          ln_rec_selected.ex_book_local := NULL;
          ln_rec_selected.ex_book_group := NULL;
       END;


     -- update with new currency data
       UPDATE cont_transaction
          SET ex_pricing_booking = CASE WHEN ln_ex_pricing_booking IS NOT NULL THEN ln_ex_pricing_booking ELSE ex_pricing_booking END,
              ex_pricing_memo    = CASE WHEN ln_ex_pricing_memo    IS NOT NULL THEN ln_ex_pricing_memo    ELSE ex_pricing_memo    END,
              ex_booking_local   = CASE WHEN ln_ex_booking_local   IS NOT NULL THEN ln_ex_booking_local   ELSE ex_booking_local   END,
              ex_booking_group   = CASE WHEN ln_ex_booking_group   IS NOT NULL THEN ln_ex_booking_group   ELSE ex_booking_group   END,
              last_updated_by    = p_user
        WHERE transaction_key = p_transaction_key;


     END IF;

     -- force recalculation of curr change
     UPDATE cont_line_item
     SET    rev_text = 'Recalculation due to new exchange rates'
            ,last_updated_by = p_user
     WHERE  transaction_key = p_transaction_key;

      IF ln_ex_pricing_booking != NVL(ln_rec_selected.ex_pric_book,0) OR ln_ex_pricing_memo !=  NVL(ln_rec_selected.ex_pric_memo,0) OR
        ln_ex_booking_local != NVL(ln_rec_selected.ex_book_local,0) OR ln_ex_booking_group !=  NVL(ln_rec_selected.ex_book_group,0) THEN

      lv_end_user_message := 'Success.!'||chr(10)||'Rates updated for transaction key '|| p_transaction_key;

     ELSE

      lv_end_user_message := 'All rates are up to date.';

      END IF;

       RETURN lv_end_user_message;

     ELSE RETURN NULL;

     END IF;

END UpdTransExRate;

--</EC-DOC>
---------------------------------------------------------------------------------------------------
-- FUNCTION       : UpdTransAllExRate
-- Description    : Updates all the exchange rates for all transaction from exchnage rate table within a particular document.
--
-- Using tables   : cont_transaction,cont_line_item
--
-- Using functions: EcDp_Currency.GetExRate
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION UpdTransAllExRate(p_doc_key                  VARCHAR2,
                           p_user                     VARCHAR2,
                           p_pick_ex_rates_from_trans VARCHAR2 DEFAULT 'N')
  RETURN VARCHAR2
--</EC-DOC>
 IS

  TYPE cont_doc_trans IS TABLE OF cont_transaction%ROWTYPE INDEX BY PLS_INTEGER;

  lrec_cont_transaction cont_doc_trans;
  lv2_booking_curr      CONT_DOCUMENT.BOOKING_CURRENCY_CODE%TYPE;
  lv2_memo_curr         CONT_DOCUMENT.MEMO_CURRENCY_CODE%TYPE;
  lv2_group_curr        CTRL_SYSTEM_ATTRIBUTE.ATTRIBUTE_TEXT%TYPE;
  lv2_local_curr        VARCHAR2(32);
  lv_end_user_message   VARCHAR2(1024);
  ln_ex_pricing_booking NUMBER;
  ln_ex_pricing_memo    NUMBER;
  ln_ex_booking_local   NUMBER;
  ln_ex_booking_group   NUMBER;

BEGIN

  SELECT * BULK COLLECT
    INTO lrec_cont_transaction
    FROM cont_transaction
   WHERE document_key = p_doc_key;


  FOR i IN lrec_cont_transaction.first .. lrec_cont_transaction.last LOOP

    -- Bail out if reallocation. Gets exrates from preceding doc.

    IF ec_cont_document.document_concept(ec_cont_transaction.document_key(lrec_cont_transaction(i).transaction_key)) !='REALLOCATION' THEN

      IF (p_pick_ex_rates_from_trans = 'N') THEN

        lv2_booking_curr := ec_cont_document.booking_currency_code(lrec_cont_transaction(i).document_key);
        lv2_memo_curr    := ec_cont_document.memo_currency_code(lrec_cont_transaction(i).document_key);
        lv2_local_curr   := EcDp_Contract_Setup.GetLocalCurrencyCode(ec_cont_transaction.object_id(lrec_cont_transaction(i).TRANSACTION_KEY),lrec_cont_transaction(i).daytime);
        lv2_group_curr   := ec_ctrl_system_attribute.attribute_text(lrec_cont_transaction(i).daytime,'GROUP_CURRENCY_CODE','<=');

        ln_ex_pricing_booking := ecdp_currency.GetExRateViaCurrency(lrec_cont_transaction(i).pricing_currency_code,
                                                                    lv2_booking_curr,
                                                                    null,
                                                                    lrec_cont_transaction(i).ex_pricing_booking_date,
                                                                    lrec_cont_transaction(i).ex_pricing_booking_id,
                                                                    lrec_cont_transaction(i).ex_pricing_booking_ts);

        ln_ex_pricing_memo := ecdp_currency.GetExRateViaCurrency(lrec_cont_transaction(i).pricing_currency_code,
                                                                 lv2_memo_curr,
                                                                 null,
                                                                 lrec_cont_transaction(i).ex_pricing_memo_date,
                                                                 lrec_cont_transaction(i).ex_pricing_memo_id,
                                                                 lrec_cont_transaction(i).ex_pricing_memo_ts);

        ln_ex_booking_local := ecdp_currency.GetExRateViaCurrency(lv2_booking_curr,
                                                                  lv2_local_curr,
                                                                  null,
                                                                  lrec_cont_transaction(i).ex_booking_local_date,
                                                                  lrec_cont_transaction(i).ex_booking_local_id,
                                                                  lrec_cont_transaction(i).ex_booking_local_ts);

        ln_ex_booking_group := ecdp_currency.GetExRateViaCurrency(lv2_booking_curr,
                                                                  lv2_group_curr,
                                                                  null,
                                                                  lrec_cont_transaction(i).ex_booking_group_date,
                                                                  lrec_cont_transaction(i).ex_booking_group_id,
                                                                  lrec_cont_transaction(i).ex_booking_group_ts);

      IF NVL(lrec_cont_transaction(i).ex_pricing_booking,0) != ln_ex_pricing_booking OR NVL(lrec_cont_transaction(i).ex_pricing_memo,0) != ln_ex_pricing_memo OR
        NVL(lrec_cont_transaction(i).ex_booking_local,0) != ln_ex_booking_local OR NVL(lrec_cont_transaction(i).ex_booking_group,0) != ln_ex_booking_group THEN

              -- update with new currency data
              UPDATE cont_transaction
                 SET ex_pricing_booking = CASE WHEN ln_ex_pricing_booking IS NOT NULL THEN ln_ex_pricing_booking ELSE lrec_cont_transaction(i).ex_pricing_booking END,
                     ex_pricing_memo =    CASE WHEN ln_ex_pricing_memo    IS NOT NULL THEN ln_ex_pricing_memo    ELSE lrec_cont_transaction(i).ex_pricing_memo    END,
                     ex_booking_local =   CASE WHEN ln_ex_booking_local   IS NOT NULL THEN ln_ex_booking_local   ELSE lrec_cont_transaction(i).ex_booking_local   END,
                     ex_booking_group =   CASE WHEN ln_ex_booking_group   IS NOT NULL THEN ln_ex_booking_group   ELSE lrec_cont_transaction(i).ex_booking_group   END,
                     last_updated_by  = p_user
               WHERE document_key = p_doc_key
               AND transaction_key = lrec_cont_transaction(i).transaction_key;

               lv_end_user_message := 'Success.!'||chr(10)||'Rates Updated for all transactions of ' || p_doc_key;

        ELSIF  lv_end_user_message IS NULL THEN

          lv_end_user_message := 'All rates are up to date.';

        END IF;

      END IF;

      -- force recalculation of curr change
      UPDATE cont_line_item
         SET rev_text        = 'Recalculation due to new exchange rates',
             last_updated_by = p_user
       WHERE document_key = p_doc_key
       AND transaction_key = lrec_cont_transaction(i).transaction_key;

    ELSE RETURN NULL;

    END IF;

  END LOOP;

RETURN lv_end_user_message;

END UpdTransAllExRate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- FUNCTION       : UpdSelectedTransExRate
-- Description    : Updates selected exchnage rate for selected transaction from exchnage rate table within document.
--
-- Using tables   : cont_transaction,cont_line_item.
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION UpdSelectedTransExRate
 (p_transaction_key VARCHAR2,
  p_curr_from_to VARCHAR2,
  p_user VARCHAR2,
  p_pick_ex_rates_from_trans VARCHAR2 DEFAULT 'N'
  ) RETURN VARCHAR2

IS

lrec_cont_transaction cont_transaction%ROWTYPE;

lv2_booking_curr VARCHAR2(32);
lv2_memo_curr VARCHAR2(32);
lv2_local_curr VARCHAR2(32);
lv2_group_curr VARCHAR2(32);
ln_ex_pricing_booking NUMBER;
ln_ex_pricing_memo NUMBER;
ln_ex_booking_local NUMBER;
ln_ex_booking_group NUMBER;
lv_end_user_message   VARCHAR2(1024);

BEGIN

lrec_cont_transaction := ec_cont_transaction.row_by_pk(p_transaction_key);


lv2_booking_curr := ec_cont_document.booking_currency_code(lrec_cont_transaction.document_key);
lv2_memo_curr := ec_cont_document.memo_currency_code(lrec_cont_transaction.document_key);
lv2_local_curr := EcDp_Contract_Setup.GetLocalCurrencyCode(ec_cont_transaction.object_id(p_transaction_key), lrec_cont_transaction.daytime);
lv2_group_curr := ec_ctrl_system_attribute.attribute_text(lrec_cont_transaction.daytime, 'GROUP_CURRENCY_CODE', '<=');

     -- Bail out if reallocation. Gets exrates from preceding doc.
    IF ec_cont_document.document_concept(ec_cont_transaction.document_key(p_transaction_key)) != 'REALLOCATION' THEN

      IF (p_pick_ex_rates_from_trans = 'N') THEN

       ln_ex_pricing_booking := ecdp_currency.GetExRateViaCurrency(lrec_cont_transaction.pricing_currency_code,
                                                                      lv2_booking_curr,
                                                                      null,
                                                                      lrec_cont_transaction.ex_pricing_booking_date,
                                                                      lrec_cont_transaction.ex_pricing_booking_id,
                                                                      lrec_cont_transaction.ex_pricing_booking_ts);
       ln_ex_pricing_memo := ecdp_currency.GetExRateViaCurrency(lrec_cont_transaction.pricing_currency_code,
                                                                      lv2_memo_curr,
                                                                      null,
                                                                      lrec_cont_transaction.ex_pricing_memo_date,
                                                                      lrec_cont_transaction.ex_pricing_memo_id,
                                                                      lrec_cont_transaction.ex_pricing_memo_ts);
       ln_ex_booking_local := ecdp_currency.GetExRateViaCurrency(lv2_booking_curr,
                                                                      lv2_local_curr,
                                                                      null,
                                                                      lrec_cont_transaction.ex_booking_local_date,
                                                                      lrec_cont_transaction.ex_booking_local_id,
                                                                      lrec_cont_transaction.ex_booking_local_ts);
       ln_ex_booking_group := ecdp_currency.GetExRateViaCurrency(lv2_booking_curr,
                                                                      lv2_group_curr,
                                                                      null,
                                                                      lrec_cont_transaction.ex_booking_group_date,
                                                                      lrec_cont_transaction.ex_booking_group_id,
                                                                      lrec_cont_transaction.ex_booking_group_ts);

     -- update with new currency data

    IF (p_curr_from_to LIKE 'Pricing%to Booking%') AND (ln_ex_pricing_booking != NVL(lrec_cont_transaction.ex_pricing_booking,0))  THEN

      UPDATE cont_transaction
        SET ex_pricing_booking = CASE WHEN ln_ex_pricing_booking IS NOT NULL THEN ln_ex_pricing_booking ELSE ex_pricing_booking END
        WHERE transaction_key = p_transaction_key;

      lv_end_user_message :='Success.!' ||chr(10)|| p_curr_from_to || ' Rate Updated for Transaction Key '|| p_transaction_key;

    ELSIF (p_curr_from_to LIKE 'Pricing%to Memo%') AND (ln_ex_pricing_memo != NVL(lrec_cont_transaction.Ex_Pricing_Memo,0)) THEN

      UPDATE cont_transaction
         SET ex_pricing_memo = CASE WHEN ln_ex_pricing_memo IS NOT NULL THEN ln_ex_pricing_memo ELSE ex_pricing_memo END
         WHERE transaction_key = p_transaction_key;

        lv_end_user_message :='Success.!' ||chr(10)|| p_curr_from_to || ' Rate Updated for Transaction Key '|| p_transaction_key;

     ELSIF (p_curr_from_to LIKE 'Booking%to Local%') AND (ln_ex_booking_local != NVL(lrec_cont_transaction.Ex_Booking_Local,0)) THEN

      UPDATE cont_transaction
         SET ex_booking_local = CASE WHEN ln_ex_booking_local IS NOT NULL THEN ln_ex_booking_local ELSE ex_booking_local END
         WHERE transaction_key = p_transaction_key;

     lv_end_user_message :='Success.!' ||chr(10)|| p_curr_from_to || ' Rate Updated for Transaction Key '|| p_transaction_key;

    ELSIF(p_curr_from_to LIKE 'Booking%to Group%') AND (ln_ex_booking_group != NVL(lrec_cont_transaction.Ex_Booking_Group,0)) THEN

      UPDATE cont_transaction
         SET ex_booking_group = CASE WHEN ln_ex_booking_group IS NOT NULL THEN ln_ex_booking_group ELSE ex_booking_group END
         WHERE transaction_key = p_transaction_key;

    lv_end_user_message :='Success.!' ||chr(10)|| p_curr_from_to || ' Rate Updated for Transaction Key '|| p_transaction_key;

    ELSIF lv_end_user_message IS NULL THEN

    lv_end_user_message :='All rates are up to date.';

    END IF;

   END IF;


     -- force recalculation of curr change
     UPDATE cont_line_item
     SET    rev_text = 'Recalculation due to new exchange rates'
            ,last_updated_by = p_user
     WHERE  transaction_key = p_transaction_key;

     RETURN lv_end_user_message;

       ELSE RETURN NULL;

   END IF;

END UpdSelectedTransExRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- FUNCTION       : CopyTransExRate
-- Description    : Copies all four exchange rates from selected transaction to all other transaction
--                  within document on period document screen.
--
-- Using tables   : cont_transaction,cont_line_item.
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION CopyTransExRate
 (p_transaction_key VARCHAR2,
  p_user VARCHAR2
  )
  RETURN VARCHAR2

IS

lrec_cont_transaction cont_transaction%ROWTYPE;

ln_ex_pricing_booking NUMBER := 0;
ln_ex_pricing_memo NUMBER := 0;
ln_ex_booking_local NUMBER := 0;
ln_ex_booking_group NUMBER := 0;
lv_end_user_message   VARCHAR2(1024);

CURSOR c_allTrans(cp_document_key VARCHAR2, cp_transaction_key VARCHAR2) IS
      SELECT *
      FROM cont_transaction ct
      WHERE ct.document_key = cp_document_key
      AND ct.transaction_key <> cp_transaction_key
      AND ct.preceding_trans_key IS NULL
      AND ct.reversed_trans_key IS NULL;

BEGIN

lrec_cont_transaction := ec_cont_transaction.row_by_pk(p_transaction_key);

FOR rec IN c_allTrans(lrec_cont_transaction.document_key, p_transaction_key) LOOP

    --reset all these to null for each transaction
    ln_ex_pricing_booking := NULL;
    ln_ex_pricing_memo := NULL;
    ln_ex_booking_local := NULL;
    ln_ex_booking_group := NULL;

    --verify transactions having the same Pricing Currency / Forex Source / Forex Time Scope / Forex Date Base Code
    IF lrec_cont_transaction.pricing_currency_code = rec.pricing_currency_code AND
    lrec_cont_transaction.ex_pricing_booking_date = rec.ex_pricing_booking_date AND
    lrec_cont_transaction.ex_pricing_booking_ts = rec.ex_pricing_booking_ts AND
    lrec_cont_transaction.ex_pricing_booking_dbc = rec.ex_pricing_booking_dbc  THEN

       ln_ex_pricing_booking := lrec_cont_transaction.ex_pricing_booking;

    END IF;

    --verify transactions having the same Pricing Currency / Forex Source / Forex Time Scope / Forex Date Base Code
    IF lrec_cont_transaction.pricing_currency_code = rec.pricing_currency_code AND
    lrec_cont_transaction.ex_pricing_memo_date = rec.ex_pricing_memo_date AND
    lrec_cont_transaction.ex_pricing_memo_ts = rec.ex_pricing_memo_ts AND
    lrec_cont_transaction.ex_pricing_memo_dbc = rec.ex_pricing_memo_dbc  THEN

       ln_ex_pricing_memo := lrec_cont_transaction.ex_pricing_memo;

    END IF;

     --verify transactions having the same Forex Source / Forex Time Scope / Forex Date Base Code
    IF lrec_cont_transaction.ex_booking_local_date = rec.ex_booking_local_date AND
    lrec_cont_transaction.ex_booking_local_ts = rec.ex_booking_local_ts AND
    lrec_cont_transaction.ex_booking_local_dbc = rec.ex_booking_local_dbc  THEN

       ln_ex_booking_local := lrec_cont_transaction.ex_booking_local ;

    END IF;

     --verify transactions having the same Forex Source / Forex Time Scope / Forex Date Base Code
    IF lrec_cont_transaction.ex_booking_group_date = rec.ex_booking_group_date AND
    lrec_cont_transaction.ex_booking_group_ts = rec.ex_booking_group_ts AND
    lrec_cont_transaction.ex_booking_group_dbc = rec.ex_booking_group_dbc  THEN

       ln_ex_booking_group := lrec_cont_transaction.ex_booking_group;

    END IF;

    IF   (ln_ex_pricing_booking IS NOT NULL AND ln_ex_pricing_booking != nvl(rec.ex_pricing_booking,0))
      OR (ln_ex_pricing_memo IS NOT NULL AND ln_ex_pricing_memo != nvl(rec.ex_pricing_memo,0))
      OR (ln_ex_booking_local IS NOT NULL AND ln_ex_booking_local != nvl(rec.ex_booking_local,0))
      OR (ln_ex_booking_group IS NOT NULL  AND ln_ex_booking_group != nvl(rec.ex_booking_group,0)) THEN

        UPDATE cont_transaction
          SET ex_pricing_booking = NVL(ln_ex_pricing_booking, ex_pricing_booking),
              ex_pricing_memo   = NVL(ln_ex_pricing_memo, ex_pricing_memo),
              ex_booking_local   = NVL(ln_ex_booking_local, ex_booking_local),
              ex_booking_group   = NVL(ln_ex_booking_group, ex_booking_group),
              last_updated_by    = p_user
         WHERE transaction_key = rec.transaction_key;

        -- force recalculation of curr change
         UPDATE cont_line_item
         SET    rev_text = 'Recalculation due to new exchange rates'
                ,last_updated_by = p_user
         WHERE transaction_key = rec.transaction_key;

         lv_end_user_message := 'Success.!'||chr(10)|| 'All Rates of transaction key '|| p_transaction_key ||' copied to all other transactions.';

     ELSIF lv_end_user_message IS NULL THEN

         lv_end_user_message:= 'All rates are up to date.';

     END IF;

   END LOOP;

     RETURN lv_end_user_message;

END CopyTransExRate;


--<EC-DOC>
-------------------------------------------------------------------------------------
-- FUNCTION       : CopyRateOtherTrans
-- Description    : Copies Selected exchange(pricing to booking/pricing to memo/booking to local
--                  /booking to group) rate of transaction to all other transaction in document.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : cont_transaction,cont_line_item.
-- Configuration
-- required       :
--
-- Behaviour      :

--------------------------------------------------------------------------------------
FUNCTION CopyRateOtherTrans (
   p_transaction_key VARCHAR2,
   p_curr_from_to    VARCHAR2,
   p_user            VARCHAR2
   )RETURN VARCHAR2
IS

lrec_cont_transaction cont_transaction%ROWTYPE;

ln_ex_pricing_booking NUMBER := 0;
ln_ex_pricing_memo NUMBER := 0;
ln_ex_booking_local NUMBER := 0;
ln_ex_booking_group NUMBER := 0;
lv_end_user_message VARCHAR2(2000);

CURSOR c_allTrans(cp_document_key VARCHAR2, cp_transaction_key VARCHAR2) IS

      SELECT *
      FROM cont_transaction ct
      WHERE ct.document_key = cp_document_key
      AND ct.transaction_key <> cp_transaction_key
      AND ct.preceding_trans_key IS NULL
      AND ct.reversed_trans_key IS NULL;

BEGIN

  lrec_cont_transaction := ec_cont_transaction.row_by_pk(p_transaction_key);

  FOR rec IN c_allTrans(lrec_cont_transaction.document_key, p_transaction_key) LOOP

     IF p_curr_from_to LIKE 'Pricing%to Booking%' THEN

       --reset all these to null for each transaction
       ln_ex_pricing_booking := NULL;

       --verify transactions having the same Pricing Currency / Forex Source / Forex Time Scope / Forex Date Base Code
       IF lrec_cont_transaction.pricing_currency_code = rec.pricing_currency_code AND
          lrec_cont_transaction.ex_pricing_booking_date = rec.ex_pricing_booking_date AND
          lrec_cont_transaction.ex_pricing_booking_ts = rec.ex_pricing_booking_ts AND
          lrec_cont_transaction.ex_pricing_booking_dbc = rec.ex_pricing_booking_dbc  THEN

           ln_ex_pricing_booking := lrec_cont_transaction.ex_pricing_booking;

       END IF;

       IF ln_ex_pricing_booking IS NOT NULL AND nvl(rec.ex_pricing_booking,0) != ln_ex_pricing_booking THEN

          UPDATE cont_transaction
            SET ex_pricing_booking = NVL(ln_ex_pricing_booking, ex_pricing_booking),
                last_updated_by    = p_user
           WHERE transaction_key = rec.transaction_key;

          -- force recalculation of curr change
           UPDATE cont_line_item
           SET    rev_text = 'Recalculation due to new exchange rates'
                  ,last_updated_by = p_user
           WHERE transaction_key = rec.transaction_key;

           lv_end_user_message := 'Success.!'||chr(10)||p_curr_from_to || ' Rate of transactions key '|| p_transaction_key || ' is Copied to all other transactions';

       END IF;

      END IF;


      IF p_curr_from_to LIKE  'Pricing%to Memo%' THEN

       --reset all these to null for each transaction
       ln_ex_pricing_booking := NULL;

       --verify transactions having the same Pricing Currency / Forex Source / Forex Time Scope / Forex Date Base Code
       IF lrec_cont_transaction.pricing_currency_code = rec.pricing_currency_code AND
          lrec_cont_transaction.ex_pricing_memo_date = rec.ex_pricing_memo_date AND
          lrec_cont_transaction.ex_pricing_memo_ts = rec.ex_pricing_memo_ts AND
          lrec_cont_transaction.ex_pricing_memo_dbc = rec.ex_pricing_memo_dbc  THEN

           ln_ex_pricing_memo := lrec_cont_transaction.ex_pricing_memo;

       END IF;

       IF ln_ex_pricing_memo IS NOT NULL AND nvl(rec.ex_pricing_memo,0) != ln_ex_pricing_memo THEN

          UPDATE cont_transaction
            SET ex_pricing_memo = NVL(ln_ex_pricing_memo, ex_pricing_memo),
                last_updated_by    = p_user
           WHERE transaction_key = rec.transaction_key;

          -- force recalculation of curr change
           UPDATE cont_line_item
           SET    rev_text = 'Recalculation due to new exchange rates'
                  ,last_updated_by = p_user
           WHERE transaction_key = rec.transaction_key;

           lv_end_user_message := 'Success.!'||chr(10)||p_curr_from_to || ' Rate of transactions key '|| p_transaction_key || ' is Copied to all other transactions';

       END IF;

      END IF;

      IF p_curr_from_to LIKE  'Booking%to Local%' THEN

       --reset all these to null for each transaction
       ln_ex_booking_local := NULL;

       --verify transactions having the same Pricing Currency / Forex Source / Forex Time Scope / Forex Date Base Code
       IF lrec_cont_transaction.pricing_currency_code = rec.pricing_currency_code AND
          lrec_cont_transaction.ex_booking_local_date = rec.ex_booking_local_date AND
          lrec_cont_transaction.ex_booking_local_ts = rec.ex_booking_local_ts AND
          lrec_cont_transaction.ex_booking_local_dbc = rec.ex_booking_local_dbc  THEN

           ln_ex_booking_local := lrec_cont_transaction.ex_booking_local;

       END IF;

       IF ln_ex_booking_local IS NOT NULL AND nvl(rec.ex_booking_local,0) != ln_ex_booking_local THEN

          UPDATE cont_transaction
            SET ex_booking_local = NVL(ln_ex_booking_local, ex_booking_local),
                last_updated_by    = p_user
           WHERE transaction_key = rec.transaction_key;

          -- force recalculation of curr change
           UPDATE cont_line_item
           SET    rev_text = 'Recalculation due to new exchange rates'
                  ,last_updated_by = p_user
           WHERE transaction_key = rec.transaction_key;

           lv_end_user_message := 'Success.!'||chr(10)||p_curr_from_to || ' Rate of transactions key '|| p_transaction_key || ' is Copied to all other transactions';

       END IF;

      END IF;

      IF p_curr_from_to LIKE  'Booking%to Group%' THEN

       --reset all these to null for each transaction
       ln_ex_booking_group := NULL;

       --verify transactions having the same Pricing Currency / Forex Source / Forex Time Scope / Forex Date Base Code
       IF lrec_cont_transaction.pricing_currency_code = rec.pricing_currency_code AND
          lrec_cont_transaction.ex_booking_group_date = rec.ex_booking_group_date AND
          lrec_cont_transaction.ex_booking_group_ts = rec.ex_booking_group_ts AND
          lrec_cont_transaction.ex_booking_group_dbc = rec.ex_booking_group_dbc  THEN

           ln_ex_booking_group := lrec_cont_transaction.ex_booking_group;

       END IF;

       IF ln_ex_booking_group IS NOT NULL AND nvl(rec.ex_booking_group,0) != ln_ex_booking_group THEN

          UPDATE cont_transaction
            SET ex_booking_group = NVL(ln_ex_booking_group, ex_booking_group),
                last_updated_by    = p_user
           WHERE transaction_key = rec.transaction_key;

          -- force recalculation of curr change
           UPDATE cont_line_item
           SET    rev_text = 'Recalculation due to new exchange rates'
                  ,last_updated_by = p_user
           WHERE transaction_key = rec.transaction_key;

           lv_end_user_message := 'Success.!'||chr(10)||p_curr_from_to || ' Rate of transactions key '|| p_transaction_key || ' is Copied to all other transactions';

       END IF;

      END IF;

      IF lv_end_user_message IS NULL THEN

           lv_end_user_message := 'All rates are up to date.';

      END IF;

  END LOOP;

     RETURN lv_end_user_message;

END CopyRateOtherTrans;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : UpdFromPrecedingTrans
-- Description    : Procedure used to copy from one transaction to another when having dependent document set
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE UpdFromPrecedingTrans(p_preceding_trans_id VARCHAR2,
                                p_target_trans_id    VARCHAR2,
                                p_user               VARCHAR2)

IS

-- cursor used to copy from preceding transaction
CURSOR c_trans IS
SELECT ct.transaction_key,
       ct.loading_date_commenced,
       ct.loading_date_completed,
       ct.delivery_date_commenced,
       ct.delivery_date_completed,
       ct.posd_base_code,
       ct.transaction_date,
       ct.contract_date,
       ct.sales_order,
       ct.api,
       ct.cargo_no,
       ct.cargo_name,
       ct.consignee,
       ct.consignor,
       ct.delivery_plant_id,
       ct.delivery_plant_code,
       ct.delivery_point_id,
       ct.entry_point_id,
       ct.price_object_id,
       ct.product_id,
       ct.price_concept_code,
       ct.gcv,
       ct.loading_port_id,
       ct.discharge_port_id,
       ct.parcel_no,
       ct.parcel_name,
       ct.qty_type,
       ct.pricing_period_from_date,
       ct.pricing_period_to_date,
       ct.rvp,
       ct.salt,
       ct.carrier_id,
       ct.wobbe,
       ct.stream_item_id, -- use stream item find match in dependent transaction
       ctq.net_qty1,
       ctq.net_qty2,
       ctq.net_qty3,
       ctq.net_qty4,
       ctq.grs_qty1,
       ctq.grs_qty2,
       ctq.grs_qty3,
       ctq.grs_qty4,
       ctq.uom1_code,
       ctq.uom2_code,
       ctq.uom3_code,
       ctq.uom4_code,
       ct.cntr_duration_from_date,
       ct.cntr_duration_to_date,
       ct.bs_w,
       ct.ex_pricing_booking,
       ct.ex_inv_pricing_booking,
       ct.ex_pricing_memo,
       ct.ex_inv_pricing_memo,
       ct.price_src_type,
       ct.bl_date,
       ct.supply_from_date,
       ct.supply_to_date,
       ct.price_date,
       ct.destination_country_id,
       ct.destination_country_code,
       ct.origin_country_id,
       ct.origin_country_code,
       ct.pricing_currency_id,
       ct.pricing_currency_code,
       ct.ex_booking_local,
       ct.ex_booking_group,
       ct.ex_inv_booking_local,
       ct.ex_inv_booking_group,
       ct.ex_pricing_booking_id,
       ct.ex_pricing_memo_id,
       ct.ex_booking_local_id,
       ct.ex_booking_group_id,
       ct.ex_pricing_booking_ts,
       ct.ex_pricing_memo_ts,
       ct.ex_booking_local_ts,
       ct.ex_booking_group_ts,
       ct.ex_pricing_booking_date,
       ct.ex_pricing_memo_date,
       ct.ex_booking_local_date,
       ct.ex_booking_group_date,
        ct.value_1,
       ct.value_2,
       ct.value_3,
       ct.value_4,
       ct.value_5,
       ct.value_6,
       ct.value_7,
       ct.value_8,
       ct.value_9,
       ct.value_10,
       ct.text_1,
       ct.text_2,
       ct.text_3,
       ct.text_4,
       ct.text_5,
       ct.text_6,
       ct.text_7,
       ct.text_8,
       ct.text_9,
       ct.text_10,
       ct.date_1,
       ct.date_2,
       ct.date_3,
       ct.date_4,
       ct.date_5
  FROM cont_transaction ct, cont_transaction_qty ctq
 WHERE ct.transaction_key = p_preceding_trans_id
   AND ctq.transaction_key(+) = ct.transaction_key; -- outer join needed if non-qty transaction


  lrec_pre_trans cont_transaction%ROWTYPE := ec_cont_transaction.row_by_pk(p_preceding_trans_id);
  lrec_new_trans cont_transaction%ROWTYPE;
  lrec_new_trans_qty cont_transaction_qty%ROWTYPE;
  lrec_new_doc cont_document%ROWTYPE;

BEGIN


    FOR UpdTrans IN c_trans LOOP


     UPDATE cont_transaction
        SET loading_date_commenced   = UpdTrans.loading_date_commenced,
            loading_date_completed   = UpdTrans.loading_date_completed,
            delivery_date_commenced  = UpdTrans.delivery_date_commenced,
            delivery_date_completed  = UpdTrans.delivery_date_completed,
            posd_base_code           = UpdTrans.posd_base_code,
            transaction_date         = UpdTrans.transaction_date,
            contract_date            = UpdTrans.contract_date,
            sales_order              = UpdTrans.sales_order,
            api                      = UpdTrans.api,
            cargo_no                 = UpdTrans.cargo_no,
            cargo_name               = UpdTrans.cargo_name,
            parcel_no                = UpdTrans.parcel_no,
            parcel_name              = UpdTrans.parcel_name,
            qty_type                 = NVL(qty_type,UPdTrans.Qty_Type),
            bl_date                  = UPdTrans.Bl_Date,
            price_date               = UPdTrans.Price_Date,
            consignee                = UpdTrans.consignee,
            consignor                = UpdTrans.consignor,
            delivery_plant_id        = UpdTrans.delivery_plant_id,
            delivery_plant_code      = UpdTrans.delivery_plant_code,
            delivery_point_id        = UpdTrans.delivery_point_id,
            entry_point_id           = UpdTrans.entry_point_id,
            gcv                      = UpdTrans.gcv,
            loading_port_id          = UpdTrans.loading_port_id,
            discharge_port_id        = UpdTrans.discharge_port_id,
            pricing_period_from_date = UpdTrans.pricing_period_from_date,
            pricing_period_to_date   = UpdTrans.pricing_period_to_date,
            rvp                      = UpdTrans.rvp,
            salt                     = UpdTrans.salt,
            carrier_id               = UpdTrans.carrier_id,
            wobbe                    = UpdTrans.wobbe,
            cntr_duration_from_date  = UPdTrans.Cntr_Duration_From_Date,
            cntr_duration_to_date    = UPdTrans.Cntr_Duration_To_Date,
            bs_w                     = UPdTrans.Bs_w,
            destination_country_id   = UPdTrans.destination_country_id,
            destination_country_code = UPdTrans.destination_country_code,
            origin_country_id        = UPdTrans.Origin_Country_Id,
            origin_country_code      = UPdTrans.Origin_Country_Code,
            pricing_currency_id      = UPdTrans.Pricing_Currency_Id,
            pricing_currency_code    = UPdTrans.Pricing_Currency_Code,
            Value_1                  = NVL(Value_1, UPdTrans.Value_1),
            Value_2                  = NVL(Value_2, UPdTrans.Value_2),
            Value_3                  = NVL(Value_3, UPdTrans.Value_3),
            Value_4                  = NVL(Value_4, UPdTrans.Value_4),
            Value_5                  = NVL(Value_5, UPdTrans.Value_5),
            Value_6                  = NVL(Value_6, UPdTrans.Value_6),
            Value_7                  = NVL(Value_7, UPdTrans.Value_7),
            Value_8                  = NVL(Value_8, UPdTrans.Value_8),
            Value_9                  = NVL(Value_9, UPdTrans.Value_9),
            Value_10                 = NVL(Value_10, UPdTrans.Value_10),
            Text_1                   = NVL(Text_1, UPdTrans.Text_1),
            Text_2                   = NVL(Text_2, UPdTrans.Text_2),
            Text_3                   = NVL(Text_3, UPdTrans.Text_3),
            Text_4                   = NVL(Text_4, UPdTrans.Text_4),
            Text_5                   = NVL(Text_5, UPdTrans.Text_5),
            Text_6                   = NVL(Text_6, UPdTrans.Text_6),
            Text_7                   = NVL(Text_7, UPdTrans.Text_7),
            Text_8                   = NVL(Text_8, UPdTrans.Text_8),
            Text_9                   = NVL(Text_9, UPdTrans.Text_9),
            Text_10                  = NVL(Text_10, UPdTrans.Text_10),
            Date_1                   = NVL(Date_1, UPdTrans.Date_1),
            Date_2                   = NVL(Date_2, UPdTrans.Date_2),
            Date_3                   = NVL(Date_3, UPdTrans.Date_3),
            Date_4                   = NVL(Date_4, UPdTrans.Date_4),
            Date_5                   = NVL(Date_5, UPdTrans.Date_5),
            last_updated_by          = p_user
      WHERE transaction_key = p_target_trans_id;



       lrec_new_trans := ec_cont_transaction.row_by_pk(p_target_trans_id);
       lrec_new_trans_qty := ec_cont_transaction_qty.row_by_pk(p_target_trans_id);
       lrec_new_doc := ec_cont_document.row_by_pk(lrec_new_trans.document_key);

       --handling forex date and ex rates logics
       IF lrec_new_trans.ex_pricing_booking_dbc = 'PRECEDING_FOREX_DATE' OR
          lrec_new_doc.document_concept = 'REALLOCATION' THEN

             UPDATE cont_transaction
                SET ex_pricing_booking_date = UPdTrans.ex_pricing_booking_date,
                    ex_pricing_booking      = UPdTrans.ex_pricing_booking,
                    ex_inv_pricing_booking  = UPdTrans.ex_inv_pricing_booking,
                    ex_pricing_booking_id   = UPdTrans.ex_pricing_booking_id,
                    ex_pricing_booking_ts   = UPdTrans.ex_pricing_booking_ts,
                    last_updated_by         = p_user
              WHERE transaction_key = p_target_trans_id;

       END IF;

       IF lrec_new_trans.ex_pricing_memo_dbc = 'PRECEDING_FOREX_DATE' OR
          lrec_new_doc.document_concept = 'REALLOCATION' THEN

             UPDATE cont_transaction
                SET ex_pricing_memo_date = UPdTrans.ex_pricing_memo_date,
                    ex_pricing_memo      = UPdTrans.ex_pricing_memo,
                    ex_inv_pricing_memo  = UPdTrans.ex_inv_pricing_memo,
                    ex_pricing_memo_id   = UPdTrans.ex_pricing_memo_id,
                    ex_pricing_memo_ts   = UPdTrans.ex_pricing_memo_ts,
                    last_updated_by      = p_user
              WHERE transaction_key = p_target_trans_id;

       END IF;

       IF lrec_new_trans.ex_booking_local_dbc = 'PRECEDING_FOREX_DATE' OR
          lrec_new_doc.document_concept = 'REALLOCATION' THEN

             UPDATE cont_transaction
                SET ex_booking_local_date = UPdTrans.ex_booking_local_date,
                    ex_booking_local      = UPdTrans.ex_booking_local,
                    ex_inv_booking_local  = UPdTrans.ex_inv_booking_local,
                    ex_booking_local_id   = UPdTrans.ex_booking_local_id,
                    ex_booking_local_ts   = UPdTrans.ex_booking_local_ts,
                    last_updated_by       = p_user
              WHERE transaction_key = p_target_trans_id;

       END IF;

       IF lrec_new_trans.ex_booking_group_dbc = 'PRECEDING_FOREX_DATE' OR
          lrec_new_doc.document_concept = 'REALLOCATION' THEN

             UPDATE cont_transaction
                SET ex_booking_group_date = UPdTrans.ex_booking_group_date,
                    ex_booking_group      = UPdTrans.ex_booking_group,
                    ex_inv_booking_group  = UPdTrans.ex_inv_booking_group,
                    ex_booking_group_id   = UPdTrans.ex_booking_group_id,
                    ex_booking_group_ts   = UPdTrans.ex_booking_group_ts,
                    last_updated_by       = p_user
              WHERE transaction_key = p_target_trans_id;

       END IF;

       EcDp_Line_Item.UpdateLineItemShares(p_target_trans_id, p_preceding_trans_id);



       -- Update the Source Split if present
       IF lrec_new_trans.split_method = 'SOURCE_SPLIT' THEN
          UpdTransSourceSplitShare(p_target_trans_id
                      ,ec_cont_transaction_qty.net_qty1(p_target_trans_id)
                      ,ec_cont_transaction_qty.uom1_code(p_target_trans_id)
                      ,ec_cont_transaction.transaction_date(p_target_trans_id));
       END IF;


       IF IsReducedConfig(NULL, NULL, NULL, p_target_trans_id, ec_cont_transaction.daytime(p_target_trans_id)) THEN


           -- If Price object is still not set, try to resolve from preceding
           IF ec_cont_transaction.price_object_id(p_target_trans_id) IS NULL THEN
             UpdFromPrecedingTransFinal(p_preceding_trans_id, p_target_trans_id, p_user);
           END IF;

           -- This was added for the purpose of ECPD-17028 - PPA document
           -- When a PPA transaction based on a reduced config template is being updated from a preceding document
           -- It need additional information about price ojbect, product, price concept and supply dates
           -- Hence an update of stream item and line item distribution is required afterwards.
           apply_po_on_trans_rc_p(p_target_trans_id, UpdTrans.price_object_id, p_user);

           -- Get quantities for transaction
           FillTransaction(p_target_trans_id, lrec_new_trans.price_date, p_user);

           -- Update distribution based on quantities
           EcDp_Line_Item.UpdateLineItemShares(p_target_trans_id, p_preceding_trans_id);

       ELSE
           -- Full config, expecting price object to be in place.
           FillTransaction(p_target_trans_id,lrec_new_trans.price_date,p_user);
       END IF;

       -- If the supply dates have not been set yet, they are copied from preceding here (happens with PPA Price documents)
       lrec_new_trans := ec_cont_transaction.row_by_pk(p_target_trans_id); -- refresh
       IF lrec_new_trans.supply_from_date IS NULL OR lrec_new_trans.supply_to_date IS NULL THEN

         UPDATE cont_transaction ct SET
           ct.supply_from_date = lrec_pre_trans.supply_from_date,
           ct.supply_to_date = lrec_pre_trans.supply_to_date,
           ct.last_updated_by = p_user
         WHERE ct.transaction_key = p_target_trans_id;

       END IF;

    END LOOP;

END UpdFromPrecedingTrans;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : UpdFromPrecedingTransFinal
-- Description    : Procedure used to copy from one transaction to another when having dependent document set
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE UpdFromPrecedingTransFinal(p_preceding_trans_id VARCHAR2,
                                     p_target_trans_id    VARCHAR2,
                                     p_user               VARCHAR2)

IS

-- cursor used to copy from preceding transaction
CURSOR c_trans IS
SELECT ct.transaction_key,
       ct.price_object_id,
       ct.product_id,
       ct.price_concept_code,
       ct.supply_from_date,
       ct.supply_to_date
  FROM cont_transaction ct, cont_transaction_qty ctq
 WHERE ct.transaction_key = p_preceding_trans_id
   AND ctq.transaction_key(+) = ct.transaction_key; -- outer join needed if non-qty transaction

BEGIN


    FOR UpdTrans IN c_trans LOOP


     UPDATE cont_transaction
        SET price_object_id    = nvl(price_object_id, UpdTrans.Price_Object_Id),
            product_id         = nvl(product_id, UpdTrans.Product_Id),
            price_concept_code = nvl(price_concept_code, UpdTrans.Price_Concept_Code),
            supply_from_date   = nvl(supply_from_date, UpdTrans.Supply_From_Date),
            supply_to_date     = nvl(supply_to_date, UpdTrans.Supply_to_Date),
            last_updated_by    = p_user
      WHERE transaction_key = p_target_trans_id;





    END LOOP;

END UpdFromPrecedingTransFinal;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : UpdDocPrice
-- Description    : This procedure is run from button in Transaction Values panel.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : cont_line_item
--
-- Using functions: UpdLineItemUnitPrice, UpdLineItemMaster, UpdTransactionMaster
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
/*PROCEDURE UpdDocPrice (
    p_object_id VARCHAR2,
    p_transaction_id VARCHAR2,
    p_daytime DATE,
    p_user VARCHAR2,
    p_line_item_based_type VARCHAR2 DEFAULT NULL
)
--<EC-DOC>
IS

lrec_cont_transaction cont_transaction%ROWTYPE := ec_cont_transaction.row_by_pk(p_transaction_id);
BEGIN

    IF p_line_item_based_type IS NULL THEN
       EcDp_Line_Item.UpdLineItemUnitPrice(p_transaction_id, lrec_cont_transaction.price_date,p_user,'QTY');
       EcDp_Line_Item.UpdLineItemUnitPrice(p_transaction_id, lrec_cont_transaction.price_date,p_user,'FREE_UNIT_PRICE_OBJECT');
    ELSE
       EcDp_Line_Item.UpdLineItemUnitPrice(p_transaction_id, lrec_cont_transaction.price_date,p_user,p_line_item_based_type);
    END IF;

END UpdDocPrice;*/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : UpdDocPriceAll
-- Description    : This procedure is run from button in Transaction Rec Values panel.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : cont_transaction
--
-- Using functions: UpdDocPrice
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
/*PROCEDURE UpdDocPriceAll (
    p_object_id VARCHAR2,
    p_document_id VARCHAR2,
    p_user VARCHAR2,
    p_line_item_based_type VARCHAR2 default NULL
)
--</EC-DOC>
IS

CURSOR c_trans IS
SELECT transaction_key id
      ,transaction_date
FROM   cont_transaction
WHERE  object_id = p_object_id
AND    document_key = p_document_id
AND    reversed_trans_key IS NULL;  -- Only transactions that are not reversed

BEGIN

    FOR Trans IN c_trans LOOP

        UpdDocPrice(p_object_id,Trans.id,Trans.Transaction_Date,p_user, p_line_item_based_type);

    END LOOP;

END UpdDocPriceAll;*/

-- Returns either 'false' or 'true' if pricing -> booking / memo is editable or not
-- Example pricing -> memo:
-- If memo curr is null => 'false'
-- If pricing curr = memo curr => 'false'
-- Otherwise => 'true'
-- NB: Returned value must be lowercase
FUNCTION IsTransRateEditable (
    p_object_id VARCHAR2,
    p_document_id VARCHAR2,
    p_transaction_key VARCHAR2,
    p_type VARCHAR2 -- 'BOOKING' or 'MEMO' are valid choices
    )
RETURN VARCHAR2

IS

    lrec_document cont_document%ROWTYPE := ec_cont_document.row_by_pk(p_document_id);

BEGIN

    IF lrec_document.document_level_code <> 'OPEN' THEN

        RETURN 'false';

    ELSIF lrec_document.reversal_ind = 'Y' THEN

        RETURN 'false';

    ELSIF lrec_document.DOCUMENT_CONCEPT = 'REALLOCATION' THEN

        RETURN 'false';

    ELSIF p_type = 'BOOKING' THEN

        IF ec_cont_transaction.pricing_currency_code(p_transaction_key) = lrec_document.booking_currency_code THEN

            RETURN 'false';

        ELSE

            RETURN 'true';

        END IF;

    ELSIF p_type = 'MEMO' THEN

        IF lrec_document.memo_currency_code IS NULL THEN

            RETURN 'false';

        ELSIF ec_cont_transaction.pricing_currency_code(p_transaction_key) = lrec_document.memo_currency_code THEN

            RETURN 'false';

        ELSE

            RETURN 'true';

        END IF;

     ELSIF p_type = 'LOCAL' THEN

        IF EcDp_Contract_Setup.GetLocalCurrencyCode(p_object_id, ec_cont_transaction.daytime(p_transaction_key)) IS NULL THEN

            RETURN 'false';

        ELSIF lrec_document.booking_currency_code = EcDp_Contract_Setup.GetLocalCurrencyCode(p_object_id, ec_cont_transaction.daytime(p_transaction_key)) THEN

            RETURN 'false';

        ELSE

            RETURN 'true';

        END IF;

    ELSIF p_type = 'GROUP' THEN

           IF ec_ctrl_system_attribute.attribute_text(ec_cont_transaction.daytime(p_transaction_key), 'GROUP_CURRENCY_CODE', '<=') IS NULL THEN

            RETURN 'false';

        ELSIF lrec_document.booking_currency_code = ec_ctrl_system_attribute.attribute_text(ec_cont_transaction.daytime(p_transaction_key), 'GROUP_CURRENCY_CODE', '<=') THEN

            RETURN 'false';

        ELSE

            RETURN 'true';

        END IF;

    ELSE -- should never get here

        RETURN 'UNDEFINED';

    END IF;

END IsTransRateEditable;


PROCEDURE InsNewAllocSplit(
   p_object_id VARCHAR2, -- SplitKey Object Id
   p_target_id VARCHAR2, -- Result SI Id
   p_target_source_id VARCHAR2, -- Alloc SI Id
   p_daytime   DATE,
   p_user      VARCHAR2,
   p_role_name VARCHAR2 DEFAULT 'SPLIT_KEY' -- SP_SPLIT_KEY
)
IS

   lv2_result VARCHAR2(200);

BEGIN

   lv2_result := InsNewAllocSplit(p_object_id, p_target_id, p_target_source_id, p_daytime, p_user, p_role_name);

END InsNewAllocSplit;

FUNCTION InsNewAllocSplit(
   p_object_id VARCHAR2,
   p_target_id VARCHAR2,
   p_target_source_id VARCHAR2,
   p_daytime   DATE,
   p_user      VARCHAR2,
   p_role_name VARCHAR2 DEFAULT 'SPLIT_KEY'
)

RETURN VARCHAR2

IS


BEGIN
     INSERT INTO split_key_setup (object_id, split_member_id, source_member_id, class_name, daytime)
     VALUES (p_object_id, p_target_id, p_target_source_id, 'STREAM_ITEM', p_daytime);

     RETURN NULL;

END InsNewAllocSplit;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : InsTransTemplSplitKey
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE InsTransTemplSplitKey(p_object_id VARCHAR2, -- TT object_id
                                p_daytime DATE,
                                p_user VARCHAR2)
--</EC-DOC>
IS
    lv2_temp_key VARCHAR2(32);
    lv2_trans_id VARCHAR2(32);
    lv2_sk_method VARCHAR2(32);
    lv2_dist_type transaction_tmpl_version.dist_split_type%TYPE;
    lv2_dist_object_type transaction_tmpl_version.dist_object_type%TYPE;

-- ** 4-eyes approval stuff ** --
  CURSOR c_4e_ttv(cp_transaction_template_id VARCHAR2, cp_daytime DATE) IS
    SELECT ttv.rec_id, ttv.approval_state
    FROM transaction_tmpl_version ttv
    WHERE ttv.object_id = cp_transaction_template_id
    AND ttv.daytime = cp_daytime;
-- ** END 4-eyes approval stuff ** --

BEGIN
        Ecdp_System_Key.assignNextNumber('TRANSACTION_TEMPLATE_SK', lv2_temp_key);
        -- insert transaction, pick id from sequence
        SELECT 'TT:' || to_char(lv2_temp_key)
        INTO lv2_trans_id
        FROM DUAL;

        lv2_dist_object_type := ec_transaction_tmpl_version.dist_object_type(p_object_id, p_daytime, '<=');
        lv2_temp_key := Ecdp_Split_Key.InsNewSplitKey(null, lv2_trans_id, p_daytime, null, p_user, null, lv2_dist_object_type);

        -- Set the split_key method, split type and purpose
        UPDATE split_key_version skv SET
               skv.split_key_method = ec_transaction_tmpl_version.dist_split_type(p_object_id, p_daytime, '<='),
               skv.split_type = 'STREAM_ITEM',
               skv.purpose = 'SP'
        WHERE skv.object_id = lv2_temp_key
        AND skv.daytime = p_daytime;

        -- ** NO NEED TO DO 4-EYES-CHECK FOR UPDATED SPLIT_KEY RECORD ABOVE. RECORD HAS JUST BEEN INSERTED ** --

        lv2_dist_type := ec_transaction_tmpl_version.dist_type(p_object_id, p_daytime, '<=');



        UPDATE transaction_tmpl_version ttv SET
               ttv.split_key_id = lv2_temp_key,
               ttv.dist_split_type = decode(lv2_dist_type,'OBJECT','PERCENTAGE','OBJECT_LIST',ttv.dist_split_type),
               ttv.last_updated_by = p_user
        WHERE ttv.object_id = p_object_id
        AND ttv.daytime = p_daytime;

        -- ** 4-eyes approval logic ** --
        IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('TRANSACTION_TEMPLATE'),'N') = 'Y' THEN

           FOR rs4e IN c_4e_ttv(p_object_id, p_daytime) LOOP

              -- Only demand approval if a record is in Official state
              IF rs4e.approval_state = 'O' THEN

                 -- Set approval info on record
                 UPDATE transaction_tmpl_version
                 SET last_updated_by = Nvl(EcDp_Context.getAppUser,User),
                     last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
                     approval_state = 'U',
                     approval_by = null,
                     approval_date = null,
                     rev_no = (nvl(rev_no,0) + 1)
                 WHERE rec_id = rs4e.rec_id;

                 -- Prepare record for approval
                 Ecdp_Approval.registerTaskDetail(rs4e.rec_id,
                                                  'TRANSACTION_TEMPLATE',
                                                  Nvl(EcDp_Context.getAppUser,User));
              END IF;
           END LOOP;
        END IF;
        -- ** END 4-eyes approval ** --

        --get dist_split_type from transaction template
        SELECT ttv.dist_split_type
        INTO lv2_sk_method
        FROM transaction_tmpl_version ttv
        WHERE ttv.object_id = p_object_id;

        --insert dist_split_type from transaction template into split_key_method in split_key_version
        UPDATE split_key_version skv SET
            skv.split_key_method = lv2_sk_method,
            skv.last_updated_by = p_user
        WHERE skv.object_id = lv2_temp_key;

        -- ** NO NEED TO DO 4-EYES-CHECK FOR UPDATED SPLIT_KEY RECORD ABOVE. RECORD HAS JUST BEEN INSERTED ** --

END InsTransTemplSplitKey;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : UpdTransTemplSplitKey
-- Description    : If the distribution split type has changed on the transaction template, this procedure updates the split key.
--                  If Single Field Contract and stream item is set, insert one 100% share in split_key_setup
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      : Runs as an after update trigger on class TRANSACTION_TEMPLATE
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE UpdTransTemplSplitKey(p_object_id VARCHAR2, -- TT object_id
                                p_daytime DATE,
                                p_user VARCHAR2)
--</EC-DOC>

IS

lv2_sk_method                   VARCHAR2(32);
lv2_tt_dist_split_type          VARCHAR2(32);
lv2_split_key_id                VARCHAR2(32);
ln_count                        NUMBER := 0;
lv2_sks_si_id                   VARCHAR2(32);
lv2_split_member_id             stream_item.object_id%TYPE;
lv2_dist_type                   transaction_tmpl_version.dist_split_type%TYPE;

CURSOR c_SK(cp_split_key_id VARCHAR2) IS
  SELECT * FROM split_key_setup WHERE object_id = cp_split_key_id;

BEGIN

lv2_split_key_id                := ec_transaction_tmpl_version.split_key_id(p_object_id,p_daytime,'<=');
lv2_sk_method                   := ec_split_key_version.split_key_method(lv2_split_key_id,p_daytime,'<=');
lv2_tt_dist_split_type          := ec_transaction_tmpl_version.dist_split_type(p_object_id,p_daytime,'<=');
lv2_split_member_id             := ec_transaction_tmpl_version.stream_item_id(p_object_id, p_daytime, '<=');
lv2_dist_type                   := ec_transaction_tmpl_version.dist_type(p_object_id, p_daytime, '<=');

  IF nvl(lv2_sk_method,'XXX') <> nvl(lv2_tt_dist_split_type,'ZZZ') THEN

        -- Updating dist_split_type from transaction template into split_key_method in split_key_version
        UPDATE split_key_version skv
           SET skv.split_key_method = lv2_tt_dist_split_type,
               skv.last_updated_by  = p_user
         WHERE skv.object_id = lv2_split_key_id;

  END IF;

  -- If Single Field Contract and stream item is set, insert one 100% record in split_key_setup
  IF lv2_dist_type = 'OBJECT' AND lv2_split_member_id IS NOT NULL THEN
    -- Find existing split_key_setup, if any. Should never be more than one record here.
    FOR rsSK IN c_SK(lv2_split_key_id) LOOP
      lv2_sks_si_id := rsSK.Split_Member_Id;
      ln_count := ln_count + 1;
    END LOOP;

    IF ln_count = 0 THEN
      -- Insert the new 100% record
      INSERT INTO split_key_setup
        (object_id, split_member_id, class_name, daytime, split_share_mth)
      VALUES
        (lv2_split_key_id,
         lv2_split_member_id,
         'SPLIT_KEY_SETUP_SP',
         p_daytime,
         1);

     ELSIF ln_count = 1 THEN

       IF lv2_sks_si_id != lv2_split_member_id THEN

           -- Update the existing record with new stream item
           UPDATE split_key_setup
              SET split_member_id = lv2_split_member_id
            WHERE object_id = lv2_split_key_id;

       END IF;
     END IF;

         -- Need the child split setup at company level for defaulted split key setups
         ecdp_split_key.insnewchildsplitkey(lv2_split_key_id,lv2_split_member_id,'COMPANY','PERCENTAGE',p_daytime);

  END IF;

END UpdTransTemplSplitKey;


PROCEDURE UpdTransSourceSplitShare
 (p_transaction_key VARCHAR2,
  p_qty NUMBER,
  p_uom VARCHAR2,
  p_daytime DATE)
IS

CURSOR sis_source(pc_transaction_key VARCHAR2) IS
  SELECT distinct
         clid.dist_id,
         clid.stream_item_id split_member_id,
         clid.alloc_stream_item_id source_member_id
    FROM cont_line_item_dist clid
   WHERE clid.transaction_key = pc_transaction_key;


CURSOR res_sis(pc_transaction_key VARCHAR2) IS
  SELECT distinct
         clid.alloc_stream_item_id source_member_id
    FROM cont_line_item_dist clid
   WHERE clid.transaction_key = pc_transaction_key;


ln_sum NUMBER;
ln_value NUMBER;
ln_share NUMBER;
lv2_alloc_object_id VARCHAR2(32);
lrec_trans CONT_TRANSACTION%ROWTYPE := ec_cont_transaction.row_by_pk(p_transaction_key);
lv2_uom_2 VARCHAR2(32);
lv2_master_group VARCHAR2(32);

BEGIN
     -- Moved to cursor
     IF (lrec_trans.split_method <> 'SOURCE_SPLIT') THEN
        RETURN;
     END IF;


      ln_sum := 0;
      -- First loop through all allocation basis SIs and find the Total Sum in the specified UOM
      FOR Sis IN res_sis(p_transaction_key) LOOP
         IF (Sis.source_member_id IS NULL) THEN
             RETURN;
         END IF;

         --if split source used and no transation quantity uom (other line items only) then uom sat to the master of first source stream
         -- do the same when the "Stream Item Source Split UOM" on transaction is set to always use "Stream Item Master UOM"
         IF lv2_uom_2 IS NULL THEN
           IF (NVL(p_qty,0) = 0 AND NVL(LENGTH(P_UOM),0) = 0) OR (lrec_trans.SOURCE_SPLIT_METHOD = 'MASTER_UOM') THEN
              lv2_master_group := ec_stream_item_version.master_uom_group(Sis.source_member_id, TRUNC(ec_cont_transaction.transaction_date(p_transaction_key),'MM'),'<=');
              IF lv2_master_group = 'M' THEN
                 lv2_uom_2 :=   ec_stream_item_version.default_uom_mass(Sis.source_member_id, TRUNC(ec_cont_transaction.transaction_date(p_transaction_key),'MM'),'<=');
              ELSIF lv2_master_group =  'V' THEN
                 lv2_uom_2 :=   ec_stream_item_version.default_uom_volume(Sis.source_member_id, TRUNC(ec_cont_transaction.transaction_date(p_transaction_key),'MM'),'<=');
              ELSIF lv2_master_group =  'E' THEN
                 lv2_uom_2 :=   ec_stream_item_version.default_uom_energy(Sis.source_member_id, TRUNC(ec_cont_transaction.transaction_date(p_transaction_key),'MM'),'<=');
              END IF;
           ELSE
              lv2_uom_2 := p_uom;
           END IF;
         END IF;

         ln_sum := ln_sum + NVL(Ecdp_Stream_Item.GetMthQtyByUOM(Sis.source_member_id, lv2_uom_2, TRUNC(ec_cont_transaction.transaction_date(p_transaction_key),'MM')), 0);
      END LOOP;

      -- Loop through again to calculate the share and the value in the specified UOM
      FOR SisCalc IN sis_source(p_transaction_key) LOOP
          -- Find the Allocation Basis SI object_id
          lv2_alloc_object_id := SisCalc.source_member_id;

          -- Calculate the share
          IF (ln_sum <> 0) THEN
              ln_share := NVL(Ecdp_Stream_Item.GetMthQtyByUOM(lv2_alloc_object_id, lv2_uom_2, TRUNC(ec_cont_transaction.transaction_date(p_transaction_key),'MM')), 0) / ln_sum;
          ELSE
              ln_share := 0;
          END IF;

          -- Calculate the value
          ln_value := NVL(Ecdp_Stream_Item.GetMthQtyByUOM(lv2_alloc_object_id, lv2_uom_2, TRUNC(ec_cont_transaction.transaction_date(p_transaction_key),'MM')), 0);-- / ln_sum * p_qty;


          -- Update CONT_LINE_ITEM_DIST with the correct share
          UPDATE cont_line_item_dist clid
          SET clid.split_share = ln_share
              ,clid.qty1 = ec_cont_line_item.qty1(clid.line_item_key) * ln_share
          WHERE clid.transaction_key = lrec_trans.transaction_key
          AND clid.dist_id = SisCalc.Dist_Id;

      END LOOP;

      RoundDistLevel(p_transaction_key);

END UpdTransSourceSplitShare;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : CopyFieldSplit
-- Description    : Used to a copy field split from one transaction template to another.
--                  This procedure stores the user_id and split_key_object_id in a table.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------
PROCEDURE CopyFieldSplit (
    p_user_id               VARCHAR2,
    p_split_key_object_id   VARCHAR2,
    p_daytime               DATE
)
--</EC-DOC>
IS

BEGIN

    DELETE FROM split_key_copy where user_id = p_user_id;

    INSERT INTO split_key_copy
      (user_id, object_id, split_key_daytime, created_by)
    VALUES
      (p_user_id, p_split_key_object_id, p_daytime, p_user_id);

 EXCEPTION

    WHEN DUP_VAL_ON_INDEX THEN

        UPDATE split_key_copy
           SET object_id       = p_split_key_object_id,
               last_updated_by = p_user_id
         WHERE user_id = p_user_id;


END CopyFieldSplit;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : PasteFieldSplit
-- Description    : Used to paste field split into a transaction template
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------
PROCEDURE PasteFieldSplit (
    p_user_id                 VARCHAR2,
    p_trans_templ_object_id   VARCHAR2,
    p_daytime                 DATE
)
--</EC-DOC>
IS

CURSOR c_fs IS
SELECT split_key_copy.object_id, split_key_copy.split_key_daytime FROM split_key_copy WHERE user_id = p_user_id;

CURSOR c_tt(pc_sk_object_id VARCHAR2) IS
SELECT ttv.object_id tt_object_id
  FROM transaction_template tt, transaction_tmpl_version ttv
 WHERE tt.object_id = ttv.object_id
   AND ttv.split_key_id = pc_sk_object_id;

CURSOR c_sk(pc_tt_object_id VARCHAR2) IS
SELECT ttv.split_key_id split_key_id
  FROM transaction_tmpl_version ttv
 WHERE ttv.object_id = pc_tt_object_id;

CURSOR c_split_setup(pc_split_key_id VARCHAR2, pc_split_key_daytime DATE) IS
SELECT *
  FROM split_key_setup
 WHERE object_id = pc_split_key_id
     AND daytime = pc_split_key_daytime;


lv2_source_sk_object_id VARCHAR2(32);
lv2_source_sk_daytime DATE;
lv2_source_tt_object_id VARCHAR2(32);
ld_source_date DATE;
ld_target_start_date DATE;
ld_target_end_date DATE;
lv2_source_trans_type VARCHAR2(240);
lv2_target_trans_type VARCHAR2(240);
lv2_source_split_type VARCHAR2(240);
lv2_target_split_type VARCHAR2(240);
lv2_source_product_id VARCHAR2(32);
lv2_target_product_id VARCHAR2(32);
lv2_source_fg_code VARCHAR2(240);
lv2_target_fg_code VARCHAR2(240);

lv2_target_sk_id VARCHAR2(32);
lv2_old_child_split_key_id VARCHAR2(32);
lv2_new_child_split_key_id VARCHAR2(32);

lv2_exception_text VARCHAR2(1000);

generic_exception EXCEPTION;

BEGIN

    -- get the split key from the copy table.
    FOR FS IN c_fs LOOP

        lv2_source_sk_object_id := FS.object_id;
        lv2_source_sk_daytime := FS.SPLIT_KEY_DAYTIME;

    END LOOP;

    -- raise exception if not found
    IF lv2_source_sk_object_id IS NULL THEN

        lv2_exception_text := 'Cannot paste - no field split found for user '||p_user_id||'.';
        RAISE generic_exception;

    END IF;

    -- get the transaction template to which the split key belong
    FOR TT IN c_tt(lv2_source_sk_object_id) LOOP

        lv2_source_tt_object_id := TT.TT_OBJECT_ID;

    END LOOP;

    -- check if a transaction template was found (if not, something is very wrong - a sk in this table will always belong to a transaction template)
    IF lv2_source_tt_object_id IS NULL THEN

        lv2_exception_text := 'Could not find a transaction template to validate against. Please copy the field split again.';
        RAISE generic_exception;

    -- check if source and target is the same object
    ELSIF lv2_source_tt_object_id = p_trans_templ_object_id
        AND TRUNC(lv2_source_sk_daytime, 'DD') = TRUNC(p_daytime, 'DD') THEN

        lv2_exception_text := 'The target field split is the same as the source. Cannot paste.';
        RAISE generic_exception;

    END IF;

    -- Use these dates to get the attributes from the source and target obeject, respectively
    --ld_source_date := ec_transaction_template.start_date(lv2_source_tt_object_id);
    --ld_target_start_date := ec_transaction_template.start_date(p_trans_templ_object_id);
    ld_target_end_date := ec_transaction_template.end_date(p_trans_templ_object_id);

    -- Use transaction type to check financial code - must be the same.
    lv2_source_trans_type := ec_transaction_tmpl_version.transaction_type(lv2_source_tt_object_id, lv2_source_sk_daytime, '<=');
    lv2_target_trans_type := ec_transaction_tmpl_version.transaction_type(p_trans_templ_object_id, p_daytime, '<=');

    IF SUBSTR(lv2_source_trans_type,length(lv2_source_trans_type)-2) <> SUBSTR(lv2_target_trans_type,length(lv2_target_trans_type)-2) THEN

        lv2_exception_text := 'Cannot insert a split from a '||lv2_source_trans_type||' transaction template into a '||lv2_target_trans_type||' transaction template.';
        RAISE generic_exception;

    END IF;

    -- Check if field split type match
    lv2_source_split_type := ec_transaction_tmpl_version.dist_split_type(lv2_source_tt_object_id, lv2_source_sk_daytime, '<=');
    lv2_target_split_type := ec_transaction_tmpl_version.dist_split_type(p_trans_templ_object_id, p_daytime, '<=');

    IF Nvl(lv2_source_split_type,'X') <> Nvl(lv2_target_split_type,'Y') THEN

        lv2_exception_text := 'The Dist. Split Types do not match - source is '||lv2_source_split_type||' and target is '||lv2_target_split_type||'.';
        RAISE generic_exception;

    END IF;

    -- Check if product match
    lv2_source_product_id := ec_transaction_tmpl_version.product_id(lv2_source_tt_object_id, lv2_source_sk_daytime, '<=');
    lv2_target_product_id := ec_transaction_tmpl_version.product_id(p_trans_templ_object_id, p_daytime, '<=');

    IF Nvl(lv2_source_product_id,'X') <> Nvl(lv2_target_product_id,'Y') THEN

        lv2_exception_text := 'Product mismatch. Product of source template is '||ec_product.object_code(lv2_source_product_id)||' - '||ec_product_version.name(lv2_source_product_id, ld_source_date, '<=')||'. Product of target template is '||ec_product.object_code(lv2_target_product_id)||' - '||ec_product_version.name(lv2_target_product_id, ld_target_start_date, '<=')||'.';
        RAISE generic_exception;

    END IF;

    -- Check if field group match
    lv2_source_fg_code := ec_transaction_tmpl_version.dist_code(lv2_source_tt_object_id, lv2_source_sk_daytime, '<=');
    lv2_target_fg_code := ec_transaction_tmpl_version.dist_code(p_trans_templ_object_id, p_daytime, '<=');

    IF Nvl(lv2_source_fg_code,'X') <> Nvl(lv2_target_fg_code,'Y') THEN

        lv2_exception_text := 'Distribution mismatch. Distribution of source template is '||lv2_source_fg_code||' - Distribution of target template is '||lv2_target_fg_code||'.';
        RAISE generic_exception;

    END IF;

    -- By now all validation is done, and the split can be copied into the target transaction template.

    -- First get the target split key
    FOR SK IN c_sk(p_trans_templ_object_id) LOOP

        lv2_target_sk_id := SK.SPLIT_KEY_ID;

    END LOOP;


-- PS! This delete statement is AUTO APPROVED! NOT necessary to approve, because INSERT BELOW HAS APPROVAL. To approve both simultaneously is not supported. DRO:14.04.2008
    -- Then delete all existing members of the target split key
    DELETE FROM split_key_setup WHERE object_id = lv2_target_sk_id AND daytime = p_daytime;

    -- And finally insert the new members
    Ecdp_Split_Key.CopySplitKeyMembers(lv2_source_sk_object_id, lv2_target_sk_id, p_daytime, p_user_id, lv2_source_sk_daytime);

    -- Copy child split keys
    FOR r_split_setup IN c_split_setup(lv2_source_sk_object_id, lv2_source_sk_daytime) LOOP
        lv2_old_child_split_key_id := r_split_setup.child_split_key_id;

        -- Copy the child split key to target transaction template,
        -- note that only the first version is copied
        lv2_new_child_split_key_id := EcDp_split_key.InsNewSplitKeyCopy(
                                           lv2_old_child_split_key_id,
                                           'CSK:' || Ecdp_System_Key.assignNextKeyValue('SPLIT_KEY_CHILD'),
                                           p_daytime,
                                           ld_target_end_date,
                                           p_user_id,
                                           TRUE);

        Ecdp_Split_Key.CopySplitKeyMembers(lv2_old_child_split_key_id, lv2_new_child_split_key_id, p_daytime, p_user_id, lv2_source_sk_daytime);

        UPDATE split_key_setup
        set child_split_key_id = lv2_new_child_split_key_id
        where object_id = lv2_target_sk_id
            and split_member_id = r_split_setup.split_member_id
            AND daytime = p_daytime;

    END LOOP;

EXCEPTION

    WHEN generic_exception THEN

       RAISE_APPLICATION_ERROR(-20000,lv2_exception_text);


END PasteFieldSplit;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : InitSplitKeyVerForAllTTVer
-- Description    : Copy split key setup from first transaction template version to all its newer
--                  versions. Existing split key versions other than the first version are deleted.
---------------------------------------------------------------------------------------------------
PROCEDURE InitSplitKeyVerForAllTTVer(p_user_id VARCHAR2, p_trans_templ_object_id VARCHAR2)
--</EC-DOC>
IS
    CURSOR c_transaction_tmpl_versions(cp_tt_id VARCHAR2) IS
        SELECT transaction_tmpl_version.daytime, transaction_tmpl_version.end_date
        FROM transaction_tmpl_version
        WHERE transaction_tmpl_version.object_id = cp_tt_id
        ORDER BY daytime;

    lv2_first_TT_version DATE := ec_transaction_template.start_date(p_trans_templ_object_id);
    lv2_split_key_id VARCHAR2(32) := ec_transaction_tmpl_version.split_key_id(p_trans_templ_object_id, lv2_first_TT_version);
BEGIN
    -- Delete all split key versions except the first one
    Ecdp_Split_Key.DelNewerSplitKeyVersions(lv2_split_key_id, lv2_first_TT_version);

    -- Loop through all TT versions except the first one,
    -- since it already have the first version of split
    -- key
    FOR tt_ver IN c_transaction_tmpl_versions(p_trans_templ_object_id) LOOP
        IF tt_ver.daytime <> lv2_first_TT_version THEN
            -- Create a split version based on previous version
            Ecdp_Split_Key.InsNewSplitKeyVersionWithChild(
                lv2_split_key_id, tt_ver.daytime, NULL, tt_ver.end_date, p_user_id);
        END IF;
    END LOOP;
END InitSplitKeyVerForAllTTVer;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  GenTransTemplateCopy
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
-- Behaviour      :  Called from ecdp_contract_setup.genContracyCopy. As part of the contract copy,
--                   contract document objects are created here
--
-------------------------------------------------------------------------------------------------
FUNCTION GenTransTemplateCopy
 (p_trans_temp_id           VARCHAR2, -- Copy from
  p_contract_doc_id         VARCHAR2,
  p_contract_id             VARCHAR2,
  p_code                    VARCHAR2,
  p_name                    VARCHAR2,
  p_user                    VARCHAR2,
  p_copy_doc_setup_ind      VARCHAR2,
  p_start_date              DATE default NULL,
  p_end_date                DATE default NULL
  )
--</EC-DOC>
RETURN VARCHAR2
IS

CURSOR c_sort_order(pc_contract_doc_id VARCHAR2) IS
SELECT MAX(t.sort_order) max_sort_order
  FROM transaction_template t
 WHERE t.contract_doc_id = pc_contract_doc_id
   AND t.sort_order IS NOT NULL;

-- Cursor to copy splits from the transaction that are being copied.
-- The records will be identical except for a new split key ID and a new daytime
CURSOR c_splits (cp_object_id VARCHAR2, cp_daytime DATE) IS
SELECT sks.*
  FROM split_key_setup sks
 WHERE sks.object_id = cp_object_id
   AND sks.daytime = cp_daytime;


lv2_new_price_object_id VARCHAR2(32);

lrec_prev transaction_template%ROWTYPE;
lrec_prev_version transaction_tmpl_version%ROWTYPE;
lv2_transaction_id VARCHAR2(32);
ln_sort_order NUMBER := 0;
lv2_new_split_key_id VARCHAR2(32);
lv2_child_object_code VARCHAR2(32);
lv2_child_split_key_id VARCHAR2(32);
lv2_lid_split_key_id VARCHAR2(32);

-- ** 4-eyes approval stuff ** --
lv2_4e_recid VARCHAR2(32);

BEGIN

IF p_trans_temp_id IS NOT NULL THEN

  lrec_prev := ec_transaction_template.row_by_pk(p_trans_temp_id);
  lrec_prev_version := ec_transaction_tmpl_version.row_by_pk(lrec_prev.object_id, NVL(p_start_date, Lrec_Prev.Start_Date),'<=');


  -- Set sort order
  IF p_copy_doc_setup_ind = 'Y' THEN

    -- If copying all transaction templates of a document setup, use the previous object's sort order.
    ln_sort_order := lrec_prev.sort_order;

  ELSE

    -- If copying from one transaction template to an other, use the next available sort order.
    FOR c_val IN c_sort_order(p_contract_doc_id) LOOP
        ln_sort_order := c_val.max_sort_order;
    END LOOP;

    IF ln_sort_order <= 0 THEN
       ln_sort_order := 100;
    ELSE
       ln_sort_order := ln_sort_order + 100;
    END IF;

  END IF;

  -- Inserting into main table
  INSERT INTO transaction_template
    (Object_Code, Start_Date, end_date, Contract_Doc_Id, Description, sort_order, Created_By)
  VALUES
    (P_Code,
     NVL(p_start_date, Lrec_Prev.Start_Date),
     decode(Lrec_Prev.End_Date,to_date(NULL),to_date(NULL),nvl(p_end_date,Lrec_Prev.End_Date)),
     P_Contract_Doc_Id,
     Lrec_Prev.Description,
     ln_sort_order,
     P_User)
  RETURNING object_id INTO lv2_transaction_id;

  --this is to copy the report references linked to a particular transaction template when a transaction template is copied
  --lv2_transaction_id is the new trans_templ_id created and p_trans_temp_id is teh templ id which is being copied
   InsNewReportRef(p_start_date, p_user,lv2_transaction_id,p_trans_temp_id ,lrec_prev_version.daytime);

      lv2_new_price_object_id := lrec_prev_version.price_object_id;

      -- If copy contract/doc setup, read price object mapping from ecdp_contract_setup.tab_price_object
      FOR i IN 1..Ecdp_Contract_Setup.tab_price_object.count LOOP
           IF (Ecdp_Contract_Setup.tab_price_object(i).old_object_id = lrec_prev_version.price_object_id) THEN
               lv2_new_price_object_id := Ecdp_Contract_Setup.tab_price_object(i).new_object_id;
           END IF;
      END LOOP;

     -- If copy trans templ only
      IF ECDP_CONTRACT_SETUP.tab_price_object.count = 0 OR lv2_new_price_object_id IS NULL THEN
         lv2_new_price_object_id := lrec_prev_version.price_object_id;
      END IF;

  -- Inserting into version table
  INSERT INTO transaction_tmpl_version
    (object_id,
     daytime,
     end_date,
     name,
     delivery_point_id,
     entry_point_id,
     loading_port_id,
     discharge_port_id,
     dist_type,
     dist_object_type,
     dist_code,
     dist_split_type,
     USE_STREAM_ITEMS_IND,
     SOURCE_SPLIT_METHOD,
     transaction_scope,
     transaction_type,
     trans_text_after,
     trans_text_before,
     value_adjustment,
     country_id,
     origin_country_id,
     pricing_currency_id,
     price_concept_code,
     product_id,
     stream_item_id,
     vat_code_1,
     posd_base_code,
     price_date_base_code,
     bl_date_base_code,
     price_object_id,
     price_src_type,
     uom1_code,
     uom2_code,
     uom3_code,
     uom4_code,
     uom1_print_decimals,
     uom2_print_decimals,
     uom3_print_decimals,
     uom4_print_decimals,
     ex_pricing_booking_id,
     ex_pricing_memo_id,
     ex_booking_local_id,
     ex_booking_group_id,
     ex_pricing_booking_ts, --time scope
     ex_pricing_memo_ts, --time scope
     ex_booking_local_ts, --time scope
     ex_booking_group_ts, --time scope
     ex_pricing_booking_dbc, --date base code
     ex_pricing_memo_dbc, --date base code
     ex_booking_local_dbc, --date base code
     ex_booking_group_dbc, --date base code
     ifac_tt_conn_code,
     comments,
     text_1,
     text_2,
     text_3,
     text_4,
     text_5,
     text_6,
     text_7,
     text_8,
     text_9,
     text_10,
     value_1,
     value_2,
     value_3,
     value_4,
     value_5,
     date_1,
     date_2,
     date_3,
     date_4,
     date_5,
     ref_object_id_1,
     ref_object_id_2,
     ref_object_id_3,
     ref_object_id_4,
     ref_object_id_5,
     created_by,
     product_node_item_id,
     req_qty_type,
     req_price_status,
     cont_trans_name_format)
  VALUES
    (lv2_transaction_id,
     NVL(p_start_date, lrec_prev_version.daytime),
     NULL,
     p_name,
     lrec_prev_version.delivery_point_id,
     lrec_prev_version.entry_point_id,
     lrec_prev_version.loading_port_id,
     lrec_prev_version.discharge_port_id,
     lrec_prev_version.dist_type,
     lrec_prev_version.dist_object_type,
     lrec_prev_version.dist_code,
     lrec_prev_version.dist_split_type,
     lrec_prev_version.USE_STREAM_ITEMS_IND,
     lrec_prev_version.SOURCE_SPLIT_METHOD,
     lrec_prev_version.transaction_scope,
     lrec_prev_version.transaction_type,
     lrec_prev_version.trans_text_after,
     lrec_prev_version.trans_text_before,
     lrec_prev_version.value_adjustment,
     lrec_prev_version.country_id,
     lrec_prev_version.origin_country_id,
     lrec_prev_version.pricing_currency_id,
     lrec_prev_version.price_concept_code,
     lrec_prev_version.product_id,
     lrec_prev_version.stream_item_id,
     lrec_prev_version.vat_code_1,
     lrec_prev_version.posd_base_code,
     lrec_prev_version.price_date_base_code,
     lrec_prev_version.bl_date_base_code,
     lv2_new_price_object_id,
     lrec_prev_version.price_src_type,
     lrec_prev_version.uom1_code,
     lrec_prev_version.uom2_code,
     lrec_prev_version.uom3_code,
     lrec_prev_version.uom4_code,
     lrec_prev_version.uom1_print_decimals,
     lrec_prev_version.uom2_print_decimals,
     lrec_prev_version.uom3_print_decimals,
     lrec_prev_version.uom4_print_decimals,
     lrec_prev_version.ex_pricing_booking_id,
     lrec_prev_version.ex_pricing_memo_id,
     lrec_prev_version.ex_booking_local_id,
     lrec_prev_version.ex_booking_group_id,
     lrec_prev_version.ex_pricing_booking_ts, --time scope
     lrec_prev_version.ex_pricing_memo_ts, --time scope
     lrec_prev_version.ex_booking_local_ts, --time scope
     lrec_prev_version.ex_booking_group_ts, --time scope
     lrec_prev_version.ex_pricing_booking_dbc, --base date code
     lrec_prev_version.ex_pricing_memo_dbc, --base date code
     lrec_prev_version.ex_booking_local_dbc, --base date code
     lrec_prev_version.ex_booking_group_dbc, --base date code
     lrec_prev_version.ifac_tt_conn_code,
     lrec_prev_version.comments,
     lrec_prev_version.text_1,
     lrec_prev_version.text_2,
     lrec_prev_version.text_3,
     lrec_prev_version.text_4,
     lrec_prev_version.text_5,
     lrec_prev_version.text_6,
     lrec_prev_version.text_7,
     lrec_prev_version.text_8,
     lrec_prev_version.text_9,
     lrec_prev_version.text_10,
     lrec_prev_version.value_1,
     lrec_prev_version.value_2,
     lrec_prev_version.value_3,
     lrec_prev_version.value_4,
     lrec_prev_version.value_5,
     lrec_prev_version.date_1,
     lrec_prev_version.date_2,
     lrec_prev_version.date_3,
     lrec_prev_version.date_4,
     lrec_prev_version.date_5,
     lrec_prev_version.ref_object_id_1,
     lrec_prev_version.ref_object_id_2,
     lrec_prev_version.ref_object_id_3,
     lrec_prev_version.ref_object_id_4,
     lrec_prev_version.ref_object_id_5,
     p_user,
     lrec_prev_version.product_node_item_id,
     lrec_prev_version.req_qty_type,
     lrec_prev_version.req_price_status,
     lrec_prev_version.cont_trans_name_format
     );


    -- ** 4-eyes approval logic ** --
    IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('TRANSACTION_TEMPLATE'),'N') = 'Y' THEN

      -- Generate rec_id for the new record
      lv2_4e_recid := SYS_GUID();

      -- Set approval info on new record.
      UPDATE transaction_tmpl_version
      SET last_updated_by = Nvl(EcDp_Context.getAppUser,User),
          last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
          approval_state = 'N',
          rec_id = lv2_4e_recid,
          rev_no = (nvl(rev_no,0) + 1)
      WHERE object_id = lv2_transaction_id
      AND daytime = NVL(p_start_date, lrec_prev_version.daytime);

      -- Register new record for approval
      Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                        'TRANSACTION_TEMPLATE',
                                        Nvl(EcDp_Context.getAppUser,User));
    END IF;
    -- ** END 4-eyes approval ** --


   -- Updaing ACL for if ringfencing is enabled
   IF NVL(EcDp_ClassMeta_Cnfg.getAccessControlInd('TRANSACTION_TEMPLATE'),'N') = 'Y' THEN
     --Update ACL
    EcDp_Acl.RefreshObject(lv2_transaction_id, 'TRANSACTION_TEMPLATE', 'INSERTING');
   END IF;


   -- preparing a new split key for the new transaction template
   InsTransTemplSplitKey(lv2_transaction_id,NVL(p_start_date, lrec_prev_version.daytime),p_user);

   -- Retrieving the new split_key_id
   lv2_new_split_key_id := ec_transaction_tmpl_version.split_key_id(lv2_transaction_id,NVL(p_start_date, lrec_prev_version.daytime),'<=');

   -- Using the new split_key_id and the correct daytime to create a new record for each record
   -- found in split_key_setup for transaction template being copied.
   FOR c_s IN c_splits (lrec_prev_version.split_key_id, lrec_prev_version.daytime) LOOP

        lv2_child_object_code := 'CSK:' || Ecdp_System_Key.assignNextKeyValue('SPLIT_KEY_CHILD');

        lv2_child_split_key_id := ec_split_key_setup.child_split_key_id(lrec_prev_version.split_key_id, c_s.split_member_id, NVL(p_start_date, lrec_prev_version.daytime), '<=');

        lv2_lid_split_key_id := Ecdp_Split_Key.InsNewSplitKeyCopy(lv2_child_split_key_id,
                                                                  lv2_child_object_code,
                                                                  NVL(p_start_date, lrec_prev_version.daytime),
                                                                  NVL(p_end_date, lrec_prev_version.end_date),
                                                                  p_user,TRUE);


        -- copy also all members of the split key
        Ecdp_Split_Key.CopySplitKeyMembers(lv2_child_split_key_id, lv2_lid_split_key_id , NVL(p_start_date, lrec_prev_version.daytime), p_user, p_end_date); -- WYH add p_end_date


        INSERT INTO split_key_setup
          (object_id,
           split_member_id,
           class_name,
           daytime,
           split_share_mth,
           split_value_mth,
           comments_mth,
           split_share_day,
           split_value_day,
           profit_centre_id,
           source_member_id,
           child_split_key_id,
           child_split_key_method,
           comments_day,
           comments,
           value_1,
           value_2,
           value_3,
           value_4,
           value_5,
           value_6,
           value_7,
           value_8,
           value_9,
           value_10,
           text_1,
           text_2,
           text_3,
           text_4,
           date_1,
           date_2,
           date_3,
           date_4,
           date_5,
           created_by)
        VALUES
          (lv2_new_split_key_id,
           c_s.split_member_id,
           c_s.class_name,
           NVL(p_start_date, lrec_prev_version.daytime),
           c_s.split_share_mth,
           c_s.split_value_mth,
           c_s.comments_mth,
           c_s.split_share_day,
           c_s.split_value_day,
           c_s.profit_centre_id,
           c_s.source_member_id,
           lv2_lid_split_key_id,
           c_s.child_split_key_method,
           c_s.comments_day,
           c_s.comments,
           c_s.value_1,
           c_s.value_2,
           c_s.value_3,
           c_s.value_4,
           c_s.value_5,
           c_s.value_6,
           c_s.value_7,
           c_s.value_8,
           c_s.value_9,
           c_s.value_10,
           c_s.text_1,
           c_s.text_2,
           c_s.text_3,
           c_s.text_4,
           c_s.date_1,
           c_s.date_2,
           c_s.date_3,
           c_s.date_4,
           c_s.date_5,
           p_user);

        -- ** 4-eyes approval logic ** --
        IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('SPLIT_KEY_SETUP'),'N') = 'Y' THEN

          -- Generate rec_id for the new record
          lv2_4e_recid := SYS_GUID();

          -- Set approval info on new record.
          UPDATE split_key_setup
          SET last_updated_by = Nvl(EcDp_Context.getAppUser,User),
              last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
              approval_state = 'N',
              rec_id = lv2_4e_recid,
              rev_no = (nvl(rev_no,0) + 1)
          WHERE object_id = lv2_new_split_key_id
          AND daytime = NVL(p_start_date, lrec_prev_version.daytime)
          AND split_member_id = c_s.split_member_id;

          -- Register new record for approval
          Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                           c_s.class_name,--use class-name of insert into SPLIT_KEY_SETUP table
                                            Nvl(EcDp_Context.getAppUser,User));
        END IF;
        -- ** END 4-eyes approval ** --


   END LOOP;

END IF;

   RETURN lv2_transaction_id;

END GenTransTemplateCopy;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : InsNewCarrier
-- Description    : Jira Issue ECPD-4977;
--                  This procedure inserts values that are manually entered into popups in BF Process Transaction General
--                  As the values are manually entered, there is no matching object in the class which hence must be inserted.
--                  Current type is
--                  CARRIER,
--
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE InsNewCarrier(p_transaction_key VARCHAR2,
                        p_user_id         VARCHAR2,
                        p_daytime         DATE,
                        p_carrier         VARCHAR2)
IS
lv2_object_id           VARCHAR2(32) := NULL;
lv2_object_code         VARCHAR2(32) := NULL; -- actual object_code
lv2_object_name         carrier_version.name%type;
lv2_carrier_code        VARCHAR2(32) := NULL; -- generated code
ld_object_start_date    DATE;

CURSOR c_ins(cp_carrier VARCHAR2, cp_carrier_code VARCHAR2, cp_daytime DATE) IS
     SELECT c.object_id, c.object_code,cv.name
       FROM carrier_version cv, carrier c
      WHERE c.object_id = cv.object_id
        AND cv.daytime = (SELECT MAX(daytime) FROM carrier_version WHERE object_id = c.object_id AND daytime <= cp_daytime)
        AND (c.object_code = cp_carrier_code
            OR REPLACE(UPPER(c.object_code),' ', '_') = cp_carrier_code
            OR upper(cv.name) = upper(cp_carrier));

CURSOR c_min_carrier IS
     SELECT min(start_date) start_date FROM carrier;

CURSOR c_min_contract IS
     SELECT min(start_date) start_date FROM contract;

BEGIN

  IF p_carrier IS NOT NULL THEN

     lv2_carrier_code := REPLACE(UPPER(SUBSTR(p_carrier,1,32)),' ', '_');

     FOR rsIns IN c_ins(p_carrier, lv2_carrier_code, p_daytime) LOOP
        lv2_object_id := rsIns.Object_Id;
        lv2_object_code := rsIns.Object_Code;
        lv2_object_name := rsIns.Name;
     END LOOP;

     IF lv2_object_id IS NULL THEN

            FOR rsmin_carrier IN c_min_carrier LOOP
            ld_object_start_date := rsmin_carrier.start_date;
        END LOOP;

        IF ld_object_start_date IS NULL THEN
           FOR rsmin_contract IN c_min_contract LOOP
               ld_object_start_date := rsmin_contract.start_date;
           END LOOP;
        END IF;

        INSERT INTO carrier
          (object_code, start_date, created_by, created_date)
        VALUES
          (lv2_carrier_code, NVL(ld_object_start_date,to_date('1900-01-01','YYYY-MM-DD')), p_user_id, p_daytime)
        RETURNING object_id INTO lv2_object_id;

        INSERT INTO carrier_version
          (object_id, daytime, name, created_by, created_date)
        VALUES
          (lv2_object_id, NVL(ld_object_start_date,to_date('1900-01-01','YYYY-MM-DD')), p_carrier, p_user_id, p_daytime);

          UPDATE cont_transaction t
             SET t.carrier_code = ec_carrier.object_code(lv2_object_id),
                 t.carrier_id   = lv2_object_id
           WHERE t.transaction_key = p_transaction_key;

     ELSE

           -- If transaction value is different from parameter value, set parameter value.
           IF nvl(ec_cont_transaction.carrier_id(p_transaction_key),'XXX') != nvl(lv2_object_id,'XXX') THEN
              UPDATE cont_transaction SET
                     carrier_id = lv2_object_id,
                     carrier_code = lv2_object_code
              WHERE transaction_key = p_transaction_key;
           END IF;

           --update name of carrier if it has changed (uppercase/lowercase changes
           IF p_carrier <> lv2_object_name THEN
               UPDATE carrier_version cv SET
                      cv.name = p_carrier
               WHERE cv.object_id = lv2_object_id
               AND cv.daytime = (SELECT MAX(daytime) FROM carrier_version WHERE object_id = cv.object_id AND daytime <= p_daytime);
           END IF;

     END IF;

  END IF;

END InsNewCarrier;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : InsNewDeliveryPoint
-- Description    : Jira Issue ECPD-4977;
--                  This procedure inserts values that are manually entered into popups in BF Process Transaction General
--                  As the values are manually entered, there is no matching object in the class which hence must be inserted.
--                  Current type is;
--                  DELIVERY_POINT (Delivery Point)
--
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE InsNewDeliveryPoint(p_transaction_key VARCHAR2,
                              p_user_id         VARCHAR2,
                              p_daytime         DATE,
                              p_delivery_point  VARCHAR2,
                              p_destination_country_id VARCHAR2 DEFAULT NULL,
                              p_origin_country_id VARCHAR2 DEFAULT NULL)
IS
  lv2_object_id           VARCHAR2(32) := NULL;
  lv2_object_code         VARCHAR2(32) := NULL; -- actual object_code
  lv2_delivery_point_code VARCHAR2(32) := NULL; -- generated code
  ld_object_start_date    DATE;
  missing_country         EXCEPTION;
  lb_point_updated        BOOLEAN := FALSE;
  lv2_business_unit_id    VARCHAR2(32) := NULL;
  lv2_document_key        VARCHAR2(32) := NULL;
  lv2_document_date       DATE;

  CURSOR c_ins(cp_code_or_name VARCHAR2, cp_code VARCHAR2, cp_daytime DATE) IS
     SELECT c.object_id, c.object_code
       FROM delpnt_version cv, delivery_point c
      WHERE c.object_id = cv.object_id
        AND cv.daytime = (SELECT MAX(daytime) FROM delpnt_version WHERE object_id = c.object_id AND daytime <= cp_daytime)
        AND (c.object_code = cp_code
            OR REPLACE(UPPER(c.object_code),' ', '_') = cp_code
            OR cv.name = cp_code_or_name);

CURSOR c_min_DP (cp_business_unit_id VARCHAR2) IS
     SELECT min(daytime) start_date FROM DELPNT_VERSION WHERE business_unit_id=cp_business_unit_id;

CURSOR c_min_contract IS
     SELECT min(start_date) start_date FROM contract;

BEGIN

  IF p_delivery_point IS NOT NULL THEN

    lv2_document_key := ec_cont_transaction.document_key(p_transaction_key);

    lv2_document_date := ec_cont_document.document_date(ec_cont_transaction.document_key(p_transaction_key));

    lv2_business_unit_id := ec_contract_area_version.business_unit_id(ec_contract_area.object_id_by_uk(ec_CONT_DOCUMENT.contract_area_code(lv2_document_key)),lv2_document_date,'<=');

    lv2_delivery_point_code := REPLACE(UPPER(SUBSTR(p_delivery_point,1,32)),' ', '_');

    FOR rsIns IN c_ins(p_delivery_point, lv2_delivery_point_code, p_daytime) LOOP
        lv2_object_id := rsIns.Object_Id;
        lv2_object_code := rsIns.Object_Code;
    END LOOP;


    IF lv2_object_id IS NULL THEN

        FOR rsmin_DP IN c_min_DP(lv2_business_unit_id) LOOP
            ld_object_start_date := rsmin_DP.start_date;
        END LOOP;

        IF ld_object_start_date IS NULL THEN
           FOR rsmin_contract IN c_min_contract LOOP
               ld_object_start_date := rsmin_contract.start_date;
           END LOOP;
        END IF;

        ld_object_start_date := NVL(ld_object_start_date,to_date('1900-01-01','YYYY-MM-DD'));

        INSERT INTO delivery_point
          (object_code, start_date, created_by, created_date)
        VALUES
          (lv2_delivery_point_code, ld_object_start_date, p_user_id, ecdp_date_time.getCurrentsysdate)
        RETURNING object_id INTO lv2_object_id;

        INSERT INTO delpnt_version
          (object_id, daytime, name, country_id, business_unit_id, created_by, created_date)
        VALUES
          (lv2_object_id, ld_object_start_date, p_delivery_point, p_destination_country_id, lv2_business_unit_id, p_user_id, ecdp_date_time.getCurrentsysdate);

        EcDp_nav_model_obj_relation.Syncronize(
           'INSERTING',
           'BUSINESS_UNIT',
           'DELIVERY_POINT',
           'BUSINESS_UNIT',
           lv2_business_unit_id,
           NULL,
           lv2_object_id,
           ld_object_start_date,
           ld_object_start_date,
           ld_object_start_date,
           ld_object_start_date);

          UPDATE cont_transaction t
             SET t.delivery_point_code = ec_delivery_point.object_code(lv2_object_id),
               t.delivery_point_id   = lv2_object_id
         WHERE t.transaction_key = p_transaction_key;

        lb_point_updated := TRUE;

      ELSE

           -- If transaction value is different from parameter value, set parameter value.
           IF ec_cont_transaction.delivery_point_id(p_transaction_key) != lv2_object_id THEN

                -- Check if country is set on the delivery point
                IF ec_delpnt_version.country_id(lv2_object_id, p_daytime, '<=') IS NULL THEN
                   RAISE missing_country;
                END IF;

                UPDATE cont_transaction SET
                       delivery_point_id = lv2_object_id,
                       delivery_point_code = lv2_object_code
                WHERE transaction_key = p_transaction_key;

                lb_point_updated := TRUE;

             END IF;


             --update NAME if it has changed (uppercase/lowercase changes)
             IF p_delivery_point <> lv2_object_code THEN
                 UPDATE delpnt_version cv SET
                        cv.name = p_delivery_point
                 WHERE cv.object_id = lv2_object_id
                 AND cv.daytime = (SELECT MAX(daytime) FROM delpnt_version WHERE object_id = cv.object_id AND daytime <= p_daytime);
             END IF;

      END IF;


      IF lb_point_updated THEN
          -- update the origin/destination country using the new delivery point
          UPDATE cont_transaction t
             SET origin_country_id = GetOriginCountryForTrans(object_id, transaction_key, transaction_scope, delivery_point_id, loading_port_id, p_daytime),
                 destination_country_id = GetDestinationCountryForTrans(object_id, transaction_key, transaction_scope, delivery_point_id, discharge_port_id, p_daytime)
           WHERE t.transaction_key = p_transaction_key;

      END IF;

    END IF;


EXCEPTION
  WHEN missing_country THEN
       RAISE_APPLICATION_ERROR(-20000, 'Selected Delivery Point [' || p_delivery_point || '] is not connected to a country. Please connect this delivery point to a country before using it.');

END InsNewDeliveryPoint;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : InsNewDeliveryPlant
-- Description    : Jira Issue ECPD-4977;
--                  This procedure inserts values that are manually entered into popups in BF Process Transaction General
--                  As the values are manually entered, there is no matching object in the class which hence must be inserted.
--                  Current type is;
--                  DELIVERY_PLANT (Delivery Plant)
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      : Note that the p_delivery_plant parameter can be both the CODE and the NAME. It is CODE when selecting from the popup
--                  It is NAME when typing into the popup - either for entering a new object or modifying uppercase/lowercase
--                  letters of the name of an existing object
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE InsNewDeliveryPlant(p_transaction_key VARCHAR2,
                              p_user_id         VARCHAR2,
                              p_daytime         DATE,
                              p_delivery_plant  VARCHAR2)
IS
  lv2_object_id           VARCHAR2(32) := NULL;
  lv2_object_code         VARCHAR2(32) := NULL; -- actual object_code
  lv2_delivery_plant_code VARCHAR2(32) := NULL; -- generated code
  ld_object_start_date    DATE;

  CURSOR c_ins(cp_code_or_name VARCHAR2, cp_code VARCHAR2, cp_daytime DATE) IS
     SELECT c.object_id, c.object_code
       FROM delpnt_version cv, delivery_point c
      WHERE c.object_id = cv.object_id
        AND cv.daytime = (SELECT MAX(daytime) FROM delpnt_version WHERE object_id = c.object_id AND daytime <= cp_daytime)
        AND (c.object_code = cp_code
            OR REPLACE(UPPER(c.object_code),' ', '_') = cp_code
            OR cv.name = cp_code_or_name);

  CURSOR c_min_DP IS
     SELECT min(start_date) start_date FROM delivery_point;

  CURSOR c_min_contract IS
     SELECT min(start_date) start_date FROM contract;


BEGIN

  IF p_delivery_plant IS NOT NULL THEN

    lv2_delivery_plant_code := REPLACE(UPPER(SUBSTR(p_delivery_plant,1,32)),' ', '_');

    FOR rsIns IN c_ins(p_delivery_plant, lv2_delivery_plant_code, p_daytime) LOOP
        lv2_object_id := rsIns.Object_Id;
        lv2_object_code := rsIns.Object_Code;
    END LOOP;

    IF lv2_object_id IS NULL THEN

         FOR rsmin_DP IN c_min_DP LOOP
        ld_object_start_date := rsmin_DP.start_date;
      END LOOP;

      IF ld_object_start_date IS NULL THEN
         FOR rsmin_contract IN c_min_contract LOOP
             ld_object_start_date := rsmin_contract.start_date;
         END LOOP;
      END IF;

      INSERT INTO delivery_point
        (object_code, start_date, created_by, created_date)
      VALUES
        (lv2_delivery_plant_code, NVL(ld_object_start_date,to_date('1900-01-01','YYYY-MM-DD')), p_user_id, p_daytime)
      RETURNING object_id INTO lv2_object_id;

      INSERT INTO delpnt_version
        (object_id, daytime, name, created_by, created_date)
      VALUES
        (lv2_object_id, NVL(ld_object_start_date,to_date('1900-01-01','YYYY-MM-DD')), p_delivery_plant, p_user_id, p_daytime);

        UPDATE cont_transaction t
           SET t.delivery_plant_code = ec_delivery_point.object_code(lv2_object_id),
               t.delivery_plant_id   = lv2_object_id
         WHERE t.transaction_key = p_transaction_key;

      ELSE
           -- If transaction value is different from parameter value, set parameter value.
           IF ec_cont_transaction.delivery_plant_id(p_transaction_key) != lv2_object_id THEN
              UPDATE cont_transaction SET
                     delivery_plant_id = lv2_object_id,
                     delivery_plant_code = lv2_object_code
              WHERE transaction_key = p_transaction_key;
           END IF;

           --update NAME if it has changed (uppercase/lowercase changes)
           IF p_delivery_plant <> lv2_object_code THEN
               UPDATE delpnt_version cv SET
                      cv.name = p_delivery_plant
               WHERE cv.object_id = lv2_object_id
               AND cv.daytime = (SELECT MAX(daytime) FROM delpnt_version WHERE object_id = cv.object_id AND daytime <= p_daytime);
           END IF;

    END IF;

  END IF;

END InsNewDeliveryPlant;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : InsNewLoadingPoint
-- Description    : Jira Issue ECPD-8547;
--                  This procedure inserts values that are manually entered into popups in BF Process Transaction General
--                  As the values are manually entered, there is no matching object in the class which hence must be inserted.
--                  Current type is;
--                  LOADING_POINT (Loading Point)
--
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      : Note that the p_loading_point parameter can be both the CODE and the NAME. It is CODE when selecting from the popup
--                  It is NAME when typing into the popup - either for entering a new object or modifying uppercase/lowercase
--                  letters of the name of an existing object
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE InsNewPort(p_transaction_key VARCHAR2,
                    p_user_id        VARCHAR2,
                    p_daytime        DATE,
                    p_port           VARCHAR2,
                    p_type           VARCHAR2, -- L for loading, D for discharge
                    p_destination_country_id VARCHAR2 DEFAULT NULL,
                    p_origin_country_id VARCHAR2 DEFAULT NULL)

IS
  lv2_object_id           VARCHAR2(32) := NULL;
  lv2_object_code         VARCHAR2(32) := NULL; -- actual object_code
  lv2_port_code           VARCHAR2(32) := NULL; -- generated code
  ld_object_start_date    DATE;
  missing_country         EXCEPTION;
  lb_port_updated         BOOLEAN := FALSE;

  CURSOR c_ins(cp_code_or_name VARCHAR2, cp_code VARCHAR2, cp_daytime DATE) IS
     SELECT c.object_id, c.object_code
       FROM port_version cv, port c
      WHERE c.object_id = cv.object_id
        AND cv.daytime = (SELECT MAX(daytime) FROM port_version WHERE object_id = c.object_id AND daytime <= cp_daytime)
        AND (c.object_code = cp_code
            OR REPLACE(UPPER(c.object_code),' ', '_') = cp_code
            OR cv.name = cp_code_or_name);

 CURSOR c_min_port IS
     SELECT min(start_date) start_date FROM port;

CURSOR c_min_contract IS
     SELECT min(start_date) start_date FROM contract;

BEGIN

  IF p_port IS NOT NULL THEN

    lv2_port_code := REPLACE(UPPER(SUBSTR(p_port,1,32)),' ', '_');

    FOR rsIns IN c_ins(p_port, lv2_port_code, p_daytime) LOOP
        lv2_object_id := rsIns.Object_Id;
        lv2_object_code := rsIns.Object_Code;
    END LOOP;

    IF lv2_object_id IS NULL THEN

      FOR rsmin_port IN c_min_port LOOP
        ld_object_start_date := rsmin_port.start_date;
      END LOOP;

      IF ld_object_start_date IS NULL THEN
         FOR rsmin_contract IN c_min_contract LOOP
             ld_object_start_date := rsmin_contract.start_date;
         END LOOP;
      END IF;

      INSERT INTO port
        (object_code, start_date, created_by, created_date)
      VALUES
        (lv2_port_code, NVL(ld_object_start_date,to_date('1900-01-01','YYYY-MM-DD')), p_user_id, p_daytime)
      RETURNING object_id INTO lv2_object_id;

      IF p_type = 'L' THEN

          INSERT INTO port_version
            (object_id, daytime, name, country_id, created_by, created_date)
          VALUES
            (lv2_object_id, NVL(ld_object_start_date,to_date('1900-01-01','YYYY-MM-DD')), p_port, p_origin_country_id, p_user_id, p_daytime);

      ELSIF p_type = 'D' THEN

      INSERT INTO port_version
        (object_id, daytime, name, country_id, created_by, created_date)
      VALUES
        (lv2_object_id, NVL(ld_object_start_date,to_date('1900-01-01','YYYY-MM-DD')), p_port, p_destination_country_id, p_user_id, p_daytime);

      END IF;

      IF p_type = 'L' THEN

        UPDATE cont_transaction t
           SET t.loading_port_code = ec_port.object_code(lv2_object_id),
               t.loading_port_id   = lv2_object_id
         WHERE t.transaction_key = p_transaction_key;

      ELSIF p_type = 'D' THEN

        UPDATE cont_transaction t
           SET t.discharge_port_code = ec_port.object_code(lv2_object_id),
               t.discharge_port_id   = lv2_object_id
         WHERE t.transaction_key = p_transaction_key;
      END IF;

      lb_port_updated := TRUE;

    ELSE

      -- If transaction value is different from parameter value, set parameter value.
      IF p_type = 'L' THEN
         IF ec_cont_transaction.loading_port_id(p_transaction_key) != lv2_object_id THEN
            UPDATE cont_transaction SET
                   loading_port_id = lv2_object_id,
                   loading_port_code = lv2_object_code
            WHERE transaction_key = p_transaction_key;

            lb_port_updated := TRUE;

         END IF;
      ELSIF p_type = 'D' THEN
         IF ec_cont_transaction.discharge_port_id(p_transaction_key) != lv2_object_id THEN

            -- Check if country is set on the discharge port
            IF ec_port_version.country_id(lv2_object_id, p_daytime, '<=') IS NULL THEN
               RAISE missing_country;
            END IF;

            UPDATE cont_transaction SET
                   discharge_port_id = lv2_object_id,
                   discharge_port_code = lv2_object_code
            WHERE transaction_key = p_transaction_key;

            lb_port_updated := TRUE;

         END IF;
      END IF;

       --update NAME if it has changed (uppercase/lowercase changes)
       IF p_port <> lv2_object_code THEN
           UPDATE port_version cv SET
                  cv.name = p_port
           WHERE cv.object_id = lv2_object_id
           AND cv.daytime = (SELECT MAX(daytime) FROM port_version WHERE object_id = cv.object_id AND daytime <= p_daytime);
       END IF;

    END IF;


    IF lb_port_updated THEN
        -- update the origin/export country id
        UPDATE cont_transaction SET
               origin_country_id = GetOriginCountryForTrans(object_id, transaction_key, transaction_scope, delivery_point_id, loading_port_id, p_daytime),
               destination_country_id = GetDestinationCountryForTrans(object_id, transaction_key, transaction_scope, delivery_point_id, discharge_port_id, p_daytime)
        WHERE transaction_key = p_transaction_key;

    END IF;

  END IF;


EXCEPTION
  WHEN missing_country THEN
       RAISE_APPLICATION_ERROR(-20000, 'Selected Discharge Port [' || p_port || '] is not connected to a country. Please connect this port to a country before using it.');

END InsNewPort;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : InsNewEntryPoint
-- Description    : Jira Issue ECPD-8547;
--                  This procedure inserts values that are manually entered into popups in BF Process Transaction General
--                  As the values are manually entered, there is no matching object in the class which hence must be inserted.
--                  Current type is;
--                  ENTRY_POINT (Entry Point)
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      : Note that the p_entry_point parameter can be both the CODE and the NAME. It is CODE when selecting from the popup
--                  It is NAME when typing into the popup - either for entering a new object or modifying uppercase/lowercase
--                  letters of the name of an existing object
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE InsNewEntryPoint(p_transaction_key VARCHAR2,
                              p_user_id         VARCHAR2,
                              p_daytime         DATE,
                              p_entry_point  VARCHAR2)


IS
  lv2_object_id           VARCHAR2(32) := NULL;
  lv2_object_code         VARCHAR2(32) := NULL; -- actual object_code
  lv2_entry_point_code    VARCHAR2(32) := NULL; -- generated code
  ld_object_start_date    DATE;

  CURSOR c_ins(cp_code_or_name VARCHAR2, cp_code VARCHAR2, cp_daytime DATE) IS
     SELECT c.object_id, c.object_code
       FROM delpnt_version cv, delivery_point c
      WHERE c.object_id = cv.object_id
        AND cv.daytime = (SELECT MAX(daytime) FROM delpnt_version WHERE object_id = c.object_id AND daytime <= cp_daytime)
        AND (c.object_code = cp_code
            OR REPLACE(UPPER(c.object_code),' ', '_') = cp_code
            OR cv.name = cp_code_or_name);

  CURSOR c_min_DP IS
     SELECT min(start_date) start_date FROM delivery_point;

  CURSOR c_min_contract IS
     SELECT min(start_date) start_date FROM contract;

BEGIN

  IF p_entry_point IS NOT NULL THEN

    lv2_entry_point_code := REPLACE(UPPER(SUBSTR(p_entry_point,1,32)),' ', '_');

    FOR rsIns IN c_ins(p_entry_point, lv2_entry_point_code, p_daytime) LOOP
        lv2_object_id := rsIns.Object_Id;
        lv2_object_code := rsIns.Object_Code;
    END LOOP;

    IF lv2_object_id IS NULL THEN

         FOR rsmin_DP IN c_min_DP LOOP
        ld_object_start_date := rsmin_DP.start_date;
      END LOOP;

      IF ld_object_start_date IS NULL THEN
           FOR rsmin_contract IN c_min_contract LOOP
               ld_object_start_date := rsmin_contract.start_date;
           END LOOP;
      END IF;

      INSERT INTO delivery_point
        (object_code, start_date, created_by, created_date)
      VALUES
        (lv2_entry_point_code, NVL(ld_object_start_date,to_date('1900-01-01','YYYY-MM-DD')), p_user_id, p_daytime)
      RETURNING object_id INTO lv2_object_id;

      INSERT INTO delpnt_version
        (object_id, daytime, name, created_by, created_date)
      VALUES
        (lv2_object_id, NVL(ld_object_start_date,to_date('1900-01-01','YYYY-MM-DD')), p_entry_point, p_user_id, p_daytime);

        UPDATE cont_transaction t
           SET t.entry_point_code = ec_delivery_point.object_code(lv2_object_id),
               t.entry_point_id   = lv2_object_id
         WHERE t.transaction_key = p_transaction_key;

     ELSE

           -- If transaction value is different from parameter value, set parameter value.
           IF ec_cont_transaction.entry_point_id(p_transaction_key) != lv2_object_id THEN
              UPDATE cont_transaction SET
                     entry_point_id = lv2_object_id,
                     entry_point_code = lv2_object_code
              WHERE transaction_key = p_transaction_key;
           END IF;

           --update NAME if it has changed (uppercase/lowercase changes)
           IF p_entry_point <> lv2_object_code THEN
               UPDATE delpnt_version cv SET
                      cv.name = p_entry_point
               WHERE cv.object_id = lv2_object_id
               AND cv.daytime = (SELECT MAX(daytime) FROM delpnt_version WHERE object_id = cv.object_id AND daytime <= p_daytime);
           END IF;

    END IF;

  END IF;

END InsNewEntryPoint;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetReversalTransaction
-- Description    : Returns the transaction that reverse the input transaction
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetReversalTransaction(p_transaction_key VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS

lv2_key VARCHAR2(32);

CURSOR c_reversal IS
SELECT ct.transaction_key
  FROM cont_transaction ct
 WHERE ct.reversed_trans_key = p_transaction_key;

BEGIN

FOR c_rev IN c_reversal LOOP
    lv2_key := c_rev.transaction_key;
END LOOP;


RETURN lv2_key;


END GetReversalTransaction;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetDestinationCountryId
-- Description    : Returns a proper Destination Country ID from multiple Transactions
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetDestinationCountryId(p_document_key VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS

lv2_destination_country_id cont_transaction.destination_country_id%TYPE;

CURSOR c_ct(cp_document_key VARCHAR2) IS
SELECT DISTINCT ct.destination_country_id
  FROM cont_transaction ct
 WHERE ct.document_key = cp_document_key;

ln_count NUMBER := 0;

BEGIN

  FOR c_rev IN c_ct(p_document_key) LOOP
      lv2_destination_country_id := c_rev.destination_country_id;
      ln_count := ln_count + 1;
  END LOOP;

  IF ln_count = 1 THEN
     RETURN lv2_destination_country_id;
  ELSE
     RETURN NULL;
  END IF;

RETURN lv2_destination_country_id;

END GetDestinationCountryId;



FUNCTION GetOriginCountryForTrans(
            p_trans_tmpl_obj_id     VARCHAR2,
            p_transaction_key       VARCHAR2,
            p_transaction_scope     VARCHAR2 DEFAULT NULL,
            p_delivery_point_id     VARCHAR2 DEFAULT NULL,
            p_loading_port_id       VARCHAR2 DEFAULT NULL,
            p_daytime               DATE DEFAULT NULL)
RETURN VARCHAR2
IS
    lv2_result                  VARCHAR2(32);

BEGIN
    IF UE_CONT_TRANSACTION.isGetOrigCountryForTransUEE = 'TRUE' THEN
        lv2_result := UE_CONT_TRANSACTION.GetOriginCountryForTrans(p_trans_tmpl_obj_id,
                                                                   p_transaction_key,
                                                                   p_transaction_scope,
                                                                   p_delivery_point_id,
                                                                   p_loading_port_id,
                                                                   p_daytime);

    ELSE

        -- NOTE: when changing the logic below, please also make sure
        -- when related columns in class CONT_TRANSACTION, FIN_PERIOD_DOC_TRANS,
        -- FIN_CARGO_DOC_TRANS are updated, the origin_country_id/destination_country_id
        -- also gets updated
        IF p_transaction_scope = 'PERIOD_BASED' THEN
            lv2_result := ec_delpnt_version.country_id(p_delivery_point_id, p_daytime, '<=');
        ELSIF p_transaction_scope = 'CARGO_BASED' THEN
            lv2_result := ec_port_version.country_id(p_loading_port_id, p_daytime, '<=');
        END IF;

    END IF;

    RETURN lv2_result;

END GetOriginCountryForTrans;


FUNCTION GetDestinationCountryForTrans(
            p_trans_tmpl_obj_id     VARCHAR2,
            p_transaction_key       VARCHAR2,
            p_transaction_scope     VARCHAR2 DEFAULT NULL,
            p_delivery_point_id     VARCHAR2 DEFAULT NULL,
            p_discharge_port_id     VARCHAR2 DEFAULT NULL,
            p_daytime               DATE DEFAULT NULL)
RETURN VARCHAR2
IS
    lv2_result                  VARCHAR2(32);

BEGIN

    IF UE_CONT_TRANSACTION.isGetDestCountryForTransUEE = 'TRUE' THEN
        lv2_result := UE_CONT_TRANSACTION.GetDestinationCountryForTrans(p_trans_tmpl_obj_id,
                                                                        p_transaction_key,
                                                                        p_transaction_scope,
                                                                        p_delivery_point_id,
                                                                        p_discharge_port_id,
                                                                        p_daytime);

    ELSE

        -- NOTE: when changing the logic below, please also make sure
        -- when related columns in class CONT_TRANSACTION, FIN_PERIOD_DOC_TRANS,
        -- FIN_CARGO_DOC_TRANS are updated, the origin_country_id/destination_country_id
        -- also gets updated
        IF p_transaction_scope = 'PERIOD_BASED' THEN
            lv2_result := ec_delpnt_version.country_id(p_delivery_point_id, p_daytime, '<=');
        ELSIF p_transaction_scope = 'CARGO_BASED' THEN
            lv2_result := ec_port_version.country_id(p_discharge_port_id, p_daytime, '<=');
        END IF;

    END IF;

    RETURN lv2_result;

END GetDestinationCountryForTrans;


PROCEDURE SetOriginCountryForTT(
            p_trans_tmpl_obj_id     VARCHAR2,
            p_transaction_scope     VARCHAR2 DEFAULT NULL,
            p_delivery_point_id     VARCHAR2 DEFAULT NULL,
            p_loading_port_id       VARCHAR2 DEFAULT NULL,
            p_daytime               DATE)
IS
BEGIN
    UPDATE transaction_tmpl_version
    SET origin_country_id = GetOriginCountryForTrans(p_trans_tmpl_obj_id,
                                                     NULL,
                                                     p_transaction_scope,
                                                     p_delivery_point_id,
                                                     p_loading_port_id,
                                                     p_daytime)
    WHERE object_id = p_trans_tmpl_obj_id
      AND daytime = p_daytime;

END SetOriginCountryForTT;



PROCEDURE SetDestinationCountryForTT(
            p_trans_tmpl_obj_id     VARCHAR2,
            p_transaction_scope     VARCHAR2 DEFAULT NULL,
            p_delivery_point_id     VARCHAR2 DEFAULT NULL,
            p_discharge_port_id     VARCHAR2 DEFAULT NULL,
            p_daytime               DATE)
IS
BEGIN
    UPDATE transaction_tmpl_version
    SET country_id = GetDestinationCountryForTrans(p_trans_tmpl_obj_id,
                                                   NULL,
                                                   p_transaction_scope,
                                                   p_delivery_point_id,
                                                   p_discharge_port_id,
                                                   p_daytime)
    WHERE object_id = p_trans_tmpl_obj_id
      AND daytime = p_daytime;

END SetDestinationCountryForTT;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetGargoInfo
-- Description    : Returns a concatenated list of unique cargo numbers from the transactions
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetCargoList(p_document_key VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_ct(cp_document_key VARCHAR2) IS
SELECT DISTINCT ct.cargo_name
  FROM cont_transaction ct
 WHERE ct.document_key = cp_document_key
 and ct.cargo_name IS NOT NULL;

lv2_cargoList VARCHAR2(200) := null;

BEGIN

  FOR c_rev IN c_ct(p_document_key) LOOP
       lv2_cargoList := lv2_cargoList || c_rev.cargo_name || '/';
  END LOOP;

  --remove the last '/' if it has info
  IF lv2_cargoList IS NOT NULL THEN
   lv2_cargoList := substr(lv2_cargoList,1,length(lv2_cargoList)-1);
  END IF;

RETURN lv2_cargoList;

END GetCargoList;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : RefreshDistSplitType
-- Description    : Refresh the information stored in the Transasction Distribution Setup BF when changing the distribution split type
--                  on the transaction template.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE RefreshDistSplitType(p_split_key_id VARCHAR2, p_old_dist_split_type VARCHAR2, p_new_dist_split_type VARCHAR2)


IS

BEGIN

IF p_new_dist_split_type IS NULL OR p_old_dist_split_type IS NULL THEN
   RETURN;
END IF;

IF p_new_dist_split_type <> p_old_dist_split_type THEN

  IF p_new_dist_split_type = 'PERCENTAGE' THEN

     UPDATE split_key_setup sks
     SET    sks.source_member_id = NULL
     WHERE  sks.object_id = p_split_key_id;

  ELSIF p_new_dist_split_type = 'SOURCE_SPLIT' THEN

     UPDATE split_key_setup sks
     SET    sks.split_share_mth  = NULL,
            sks.split_value_mth  = NULL,
            sks.split_share_day  = NULL,
            sks.split_value_day  = NULL
     WHERE  sks.object_id = p_split_key_id;

  END IF;
END IF;


END RefreshDistSplitType;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetTransactionPeriod
-- Description    : Returns a range of Period for all period type Transactions
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetTransactionPeriod(p_document_key VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS

  CURSOR c_ct(cp_document_key VARCHAR2) IS
    SELECT MIN(ct.SUPPLY_FROM_DATE) as MIN_DATE,
           MAX(ct.SUPPLY_TO_DATE)   as MAX_DATE
      FROM cont_transaction ct
     WHERE ct.document_key = cp_document_key
       AND ct.transaction_scope = 'PERIOD_BASED';

  CURSOR c_cgo(cp_document_key VARCHAR2) IS
    SELECT MIN(ct.transaction_date) AS POS_DATE
      FROM cont_transaction ct
     WHERE ct.document_key = cp_document_key
       AND ct.transaction_scope = 'CARGO_BASED';

ld_min_date DATE := NULL;
ld_max_date DATE := NULL;
lv2_document_scope VARCHAR2(32) := ec_cont_document.doc_scope(p_document_key);

BEGIN

  IF lv2_document_scope = 'PERIOD_BASED' THEN

    FOR c_rev IN c_ct(p_document_key) LOOP
       ld_min_date := c_rev.MIN_DATE;
       ld_max_date := c_rev.MAX_DATE;
    END LOOP;

    IF ld_min_date IS NOT NULL AND ld_min_date IS NOT NULL THEN
       RETURN to_char(ld_min_date,'YYYY-MM-DD') || ' - ' || to_char(ld_max_date,'YYYY-MM-DD');
    END IF;

  ELSIF lv2_document_scope = 'CARGO_BASED' THEN

    FOR rsCgo IN c_cgo(p_document_key) LOOP
      ld_min_date := rsCgo.Pos_Date;
    END LOOP;

    IF ld_min_date IS NOT NULL THEN
       RETURN to_char(ld_min_date,'YYYY-MM-DD');
    END IF;

  END IF;

  RETURN NULL;

END GetTransactionPeriod;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetBLDateList
-- Description    : Returns a concatenated list of unique BL dates for all cargo type Transactions
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetBLDateList(p_document_key VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_ct(cp_document_key VARCHAR2) IS
SELECT DISTINCT ct.bl_date
  FROM cont_transaction ct
 WHERE ct.document_key = cp_document_key
 and ct.bl_date IS NOT NULL
 order by ct.bl_date ASC;

lv2_BLDateList VARCHAR2(200) := null;

BEGIN

  FOR c_rev IN c_ct(p_document_key) LOOP
       lv2_BLDateList := lv2_BLDateList || to_char(c_rev.bl_date,'YYYY-MM-DD') || ' / ';
  END LOOP;

  --remove the last '/' if it has info
  IF lv2_BLDateList IS NOT NULL THEN
   lv2_BLDateList := substr(lv2_BLDateList,1,length(lv2_BLDateList)-3);
  END IF;

  RETURN lv2_BLDateList;

END GetBLDateList;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetSumTransPricingTotal
-- Description    : Returns a SUM of pricing total from all transaction based on document key
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetSumTransPricingTotal(p_document_key VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_ct(cp_document_key VARCHAR2) IS
SELECT count(*) as NUM FROM (
SELECT distinct ct.pricing_currency_id, ct.document_key
  FROM cont_transaction ct
  WHERE ct.document_key = p_document_key);

CURSOR c_ct2(cp_document_key VARCHAR2) IS
SELECT SUM(trans_pricing_total) as SUM_PRICING_TOTAL
 FROM cont_transaction ct
 WHERE ct.document_key = p_document_key;

BEGIN

  FOR c_rev IN c_ct(p_document_key) LOOP

    IF c_rev.NUM = 1 THEN

       FOR c_rev2 IN c_ct2(p_document_key) LOOP
           RETURN c_rev2.SUM_PRICING_TOTAL;
       END LOOP;

    ELSE
      RETURN NULL;
    END IF;

  END LOOP;

END GetSumTransPricingTotal;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetSumTransPricingValue
-- Description    : Returns a SUM of pricing value from all transaction based on document key
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetSumTransPricingValue(p_document_key VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_ct(cp_document_key VARCHAR2) IS
SELECT count(*) as NUM FROM (
SELECT distinct ct.pricing_currency_id, ct.document_key
  FROM cont_transaction ct
  WHERE ct.document_key = p_document_key);

CURSOR c_ct2(cp_document_key VARCHAR2) IS
SELECT SUM(trans_pricing_value) as SUM_PRICING_VALUE
 FROM cont_transaction ct
 WHERE ct.document_key = p_document_key;

BEGIN

  FOR c_rev IN c_ct(p_document_key) LOOP

    IF c_rev.NUM = 1 THEN

       FOR c_rev2 IN c_ct2(p_document_key) LOOP
           RETURN c_rev2.SUM_PRICING_VALUE;
       END LOOP;

    ELSE
      RETURN NULL;
    END IF;

  END LOOP;

END GetSumTransPricingValue;





--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetTransLocalValue
-- Description    : Returns the value (ex VAT) on the transaction in local currency specified on either preceeding (#1) or current document (#2)
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetTransLocalValue(p_transaction_key VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS

lrec_ct cont_transaction%rowtype := ec_cont_transaction.row_by_pk(p_transaction_key);
ln_value_local NUMBER;
ln_ex_local NUMBER;

BEGIN

-- Using local exchange rate from preceeding document if exists
IF lrec_ct.reversed_trans_key IS NULL THEN
   ln_ex_local := lrec_ct.ex_booking_local;
   ELSE
      ln_ex_local := ec_cont_transaction.ex_booking_local(lrec_ct.reversed_trans_key);

END IF;

ln_value_local := ROUND(nvl(lrec_ct.trans_booking_value,0) * nvl(ln_ex_local,0),2);

RETURN ln_value_local;


END GetTransLocalValue;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetTransLocalVatValue
-- Description    : Returns the vat value on the transaction in local currency specified on either preceeding (#1) or current document (#2)
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetTransLocalVatValue(p_transaction_key VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS

lrec_ct cont_transaction%rowtype := ec_cont_transaction.row_by_pk(p_transaction_key);
ln_vat_value_local NUMBER;
ln_ex_local NUMBER;

BEGIN

-- Using local exchange rate from preceeding document if exists
IF lrec_ct.reversed_trans_key IS NULL THEN
   ln_ex_local := lrec_ct.ex_booking_local;
   ELSE
      ln_ex_local := ec_cont_transaction.ex_booking_local(lrec_ct.reversed_trans_key);

END IF;

ln_vat_value_local := ROUND(nvl(lrec_ct.trans_booking_vat,0) * nvl(ln_ex_local,0),2);

RETURN ln_vat_value_local;


END GetTransLocalVatValue;

PROCEDURE UpdTransTemplForexSetup(p_contract_doc_id VARCHAR2, p_daytime DATE, p_user VARCHAR2, p_memo_curr_id VARCHAR2, p_booking_curr_id VARCHAR2)
IS

CURSOR c_trans_templ (cp_contract_doc_id VARCHAR2) IS
SELECT o.object_id, oa.daytime
FROM TRANSACTION_TMPL_VERSION oa, TRANSACTION_TEMPLATE o
WHERE oa.object_id = o.object_id
AND contract_doc_id = p_contract_doc_id;

BEGIN

    FOR rec_tt IN c_trans_templ (p_contract_doc_id) LOOP

        IF p_booking_curr_id =
          ec_transaction_tmpl_version.pricing_currency_id(rec_tt.object_id, rec_tt.daytime, '<=')THEN

            UPDATE transaction_tmpl_version ttv SET
            ttv.ex_pricing_booking_id = NULL,
            ttv.ex_pricing_booking_dbc = NULL,
            ttv.ex_pricing_booking_ts = NULL,
            ttv.last_updated_by = p_user
            WHERE object_id = rec_tt.object_id
            AND daytime = rec_tt.daytime;

        END IF;

        IF p_memo_curr_id =
          ec_transaction_tmpl_version.pricing_currency_id(rec_tt.object_id, rec_tt.daytime, '<=')THEN

            UPDATE transaction_tmpl_version ttv SET
            ttv.ex_pricing_memo_id = NULL,
            ttv.ex_pricing_memo_dbc = NULL,
            ttv.ex_pricing_memo_ts = NULL,
            ttv.last_updated_by = p_user
            WHERE object_id = rec_tt.object_id
            AND daytime = rec_tt.daytime;

         END IF;

     END LOOP;

     IF ec_currency.object_code(p_booking_curr_id) =
        EcDp_Contract_Setup.GetLocalCurrencyCode(ec_contract_doc.contract_id(p_contract_doc_id), p_daytime) THEN

        FOR rec_tt IN c_trans_templ (p_contract_doc_id) LOOP

          UPDATE transaction_tmpl_version ttv SET
          ttv.ex_booking_local_id = NULL,
          ttv.ex_booking_local_dbc = NULL,
          ttv.ex_booking_local_ts = NULL,
          ttv.last_updated_by = p_user
          WHERE object_id = rec_tt.object_id
          AND daytime = rec_tt.daytime;

       END LOOP;

     END IF;

     IF ec_currency.object_code(p_booking_curr_id) =
        ec_ctrl_system_attribute.attribute_text(p_daytime, 'GROUP_CURRENCY_CODE', '<=') THEN

        FOR rec_tt IN c_trans_templ (p_contract_doc_id) LOOP

          UPDATE transaction_tmpl_version ttv SET
          ttv.ex_booking_group_id = NULL,
          ttv.ex_booking_group_dbc = NULL,
          ttv.ex_booking_group_ts = NULL,
          ttv.last_updated_by = p_user
          WHERE object_id = rec_tt.object_id
          AND daytime = rec_tt.daytime;
         END LOOP;

      END IF;

END UpdTransTemplForexSetup;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetVatCode
-- Description    : Step 1: Get VAT_CODE from interface, if exists.
--                  Step 2: If no VAT_CODE from step 1 then get VAT_CODE from template.
--                  Step 3: Return the VAT_CODE
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetTransVatCode(p_transaction_key VARCHAR2, p_trans_template_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2
--</EC-DOC>
IS

  lv2_vat_code VARCHAR2(32);
  lrec_tt transaction_tmpl_version%ROWTYPE;

  CURSOR c_isq IS
    SELECT vat_code
      FROM ifac_sales_qty
     WHERE transaction_key = p_transaction_key
       AND vat_code is not null;

BEGIN
  -- Step 1: Get VAT_CODE from interface, if exists.
  FOR c_row IN c_isq LOOP
    lv2_vat_code := c_row.vat_code;
    EXIT;
  END LOOP;
  -- Verify VAT_CODE from interface
  IF ec_vat_code.object_id_by_uk(lv2_vat_code) IS NULL THEN
    lv2_vat_code := NULL;
  END IF;

  -- Step 2: If no VAT_CODE from step 1 then get VAT_CODE from template.
  IF lv2_vat_code IS NULL THEN
    lrec_tt := ec_transaction_tmpl_version.row_by_pk(p_trans_template_id, p_daytime, '<=');
    lv2_vat_code := lrec_tt.vat_code_1;
  END IF;

  -- Step 3: Return the VAT_CODE
  RETURN lv2_vat_code;
END GetTransVatCode;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : resetLineItemShares
-- Description    : The procedure will reset the share information on field and vendor level.
--                  This is used during fetch of interface numbers where the share applied from the config is not really being considered.
--                  And in some cases, the shares applied from config might actually cause some troubles when distributing the numbers.
--
--
-- Preconditions  :
-- Postconditions : Should only be used when numbers are distributed from interface.
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE resetLineItemShares(p_transaction_key VARCHAR2)
IS

BEGIN


UPDATE CONT_LI_DIST_COMPANY c
   SET c.vendor_share = 0, c.Split_Share = 0, c.split_value = 0
   WHERE c.transaction_key = p_transaction_key;

UPDATE CONT_LINE_ITEM_DIST d
   SET d.Split_Share = 0, d.split_value = 0
 WHERE d.transaction_key = p_transaction_key;


END resetLineItemShares;


PROCEDURE triggerIULogic
(  p_document_key VARCHAR2,
   p_user VARCHAR2,
   p_status_code VARCHAR2,
   p_transaction_key VARCHAR2 DEFAULT NULL
)

IS
lv2_status_code VARCHAR2(32);
BEGIN

  lv2_status_code:= ec_cont_document.status_code(p_document_key);

  -- Check whether there is update on document status
  IF  NVL(p_status_code,'NULL') <> NVL(lv2_status_code,'NULL') THEN

     UPDATE CONT_TRANSACTION
        SET last_updated_by = p_user
      WHERE document_key = p_document_key
        AND transaction_key = nvl(p_transaction_key, transaction_key);

     UPDATE CONT_LINE_ITEM
        SET last_updated_by = p_user
      WHERE transaction_key IN (SELECT transaction_key
                                  FROM cont_transaction
                                 WHERE document_key = p_document_key
                                   AND transaction_key = nvl(p_transaction_key, transaction_key));

     UPDATE CONT_LINE_ITEM_DIST
        SET last_updated_by = p_user
      WHERE transaction_key IN (SELECT transaction_key
                                  FROM cont_transaction
                                 WHERE document_key = p_document_key
                                   AND transaction_key = nvl(p_transaction_key, transaction_key));

     UPDATE CONT_LI_DIST_COMPANY
        SET last_updated_by = p_user
      WHERE transaction_key IN (SELECT transaction_key
                                  FROM cont_transaction
                                 WHERE document_key = p_document_key
                                   AND transaction_key = nvl(p_transaction_key, transaction_key));
  END IF;

END triggerIULogic;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isTransEditableOrDeletable
-- Description    : Function to return whether a transaction is editable or deletable (Y or N).
--
-- Preconditions  : Transaction key must be provided.
-- Postconditions :
--
-- Using tables   : cont_transaction
--
-- Using packages : ec_cont_transaction, ecdp_document, ec_cont_document, ec_ctrl_system_attribute, ue_cont_transaction.
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION isTransEditableOrDeletable(
    p_operation         VARCHAR2,
    p_transaction_key   VARCHAR2,
    p_level             VARCHAR2,
    p_msg           OUT VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
    CURSOR c_trans_count IS
    SELECT count(*) cnt
      FROM cont_transaction t
     WHERE t.document_key = ec_cont_transaction.document_key(p_transaction_key);

    lv2_flag        VARCHAR2(1)     := 'Y';
    lrec_ct         cont_transaction%rowtype := ec_cont_transaction.row_by_pk(p_transaction_key);
    lv2_op_txt      VARCHAR2(10);
    lv2_msg         VARCHAR2(200)   := 'Transaction can be deleted.';
    lv2_msg_ue_pre  VARCHAR2(200);
    lv2_msg_ue_post VARCHAR2(200);
    ln_cnt          NUMBER;
BEGIN

    lv2_op_txt :=
        CASE p_operation
            WHEN 'EDIT'     THEN 'edited'
            WHEN 'DELETE'   THEN 'deleted'
        END;
    --
    -- RULES HIERARCHY PROCESSING -> Trying to oppose editable/deletable:
    IF lv2_flag = 'Y' THEN
        -- Preprocessing User-exit has returned TRUE - continue...
        IF ecdp_document.isDocumentEditable(lrec_ct.document_key) = 'N' THEN
            -- If the document is not editable then the transaction inherits this
            -- If Document or Transaction is reversed => Document/Transaction is NOT open => Not editable/deletable
            lv2_flag := 'N';
            lv2_msg  := 'The parent document is not open hence the transaction cannot be ' || lv2_op_txt || '.';

        ELSIF lrec_ct.reversal_ind = 'Y' THEN
            -- The transaction is a reversal => Not editable/deletable
            lv2_flag := 'N';
            lv2_msg  := 'This transaction is a Reversal and cannot be ' || lv2_op_txt || '.';

        ELSIF (lrec_ct.ppa_trans_code IS NOT NULL) THEN
            -- If transaction is used for Prior Period Price Adjustments => Not editable/deletable
            lv2_flag := 'N';
            lv2_msg  := 'This transaction is used for a Prior Period Price Adjustments and cannot be ' || lv2_op_txt || '.';

        ELSIF p_operation = 'EDIT'
            AND isTransactionInterfaced(p_transaction_key) = 'Y'
            AND NVL(ec_ctrl_system_attribute.attribute_text(lrec_ct.daytime,'EDIT_INTERFACED_DOCS','<='),'N') != 'Y' THEN
            -- If operation is E AND transaction is interfaced AND system attribute EDIT_INTERFACED_DOCS is NOT Y => Not editable/deletable
            lv2_flag := 'N';
            lv2_msg  := 'This is an interfaced transaction and cannot be ' || lv2_op_txt || '.';

        ELSIF p_operation = 'DELETE'
            AND isTransactionInterfaced(p_transaction_key) = 'Y' THEN
            -- If transaction is interfaced => Not editable/deletable
            lv2_flag := 'N';
            lv2_msg  := 'This is an interfaced transaction and cannot be ' || lv2_op_txt || '.';

        ELSIF ec_cont_document.document_concept(lrec_ct.document_key) = 'REALLOCATION' THEN
             -- Reallocations are not editable on transaction level, only on field and company level
            IF p_level = 'TRANS' THEN
                lv2_flag := 'N';
                lv2_msg  := 'Reallocations cannot be ' || lv2_op_txt || ' on Transaction level, only on Field/Profit Center level';

            ELSIF p_level = 'COMPANY' THEN
                lv2_flag := 'N';
                lv2_msg  := 'Reallocations cannot be ' || lv2_op_txt || ' on Company level, only on Field/Profit Center level';
            --ELSIF p_level = 'FIELD' THEN
            --    lv2_flag := 'Y';
            END IF;

        ELSIF p_operation = 'DELETE' THEN
            -- A Document must have at least one transaction i.e. the last transaction cannot be deleted
            -- (This rule is moved in here from DelTransaction)
            FOR rec IN c_trans_count LOOP
                ln_cnt := rec.cnt;
            END LOOP ;
            IF ln_cnt < 2 THEN
                lv2_flag := 'N';
                lv2_msg  := 'The last transaction on a document cannot be ' || lv2_op_txt || '.';
            END IF;

        ELSE
            NULL; -- lv2_flag is already initialized to Y
        END IF;
    END IF;

    -- Finalize
    p_msg := lv2_msg; -- Set OUT parameter
    RETURN lv2_flag;

END isTransEditableOrDeletable;


---------------------------------------------------------------------------------------------------
FUNCTION isTransactionInterfaced(p_transaction_key VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR c_Ifac IS
    SELECT transaction_key FROM ifac_sales_qty WHERE transaction_key = p_transaction_key
    UNION
    SELECT transaction_key FROM ifac_cargo_value WHERE transaction_key = p_transaction_key;

  lv2_found VARCHAR2(1) := 'N';

BEGIN

  FOR rsIF IN c_Ifac LOOP
    lv2_found := 'Y';
  END LOOP;

  RETURN lv2_found;

END isTransactionInterfaced;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isTransactionEditable
-- Description    : Function to return whether a transaction is editable or not (Y or N)
--                  If p_msg_ind is 'Y' then a user friendly message is returned instead of N.
--                  Use arrow notation to set the p_msg_ind if p_level is to use the default value:
--                  isTransactionEditable ('SomeTransKey', p_msg_ind => 'Y')
--
-- Preconditions  : Transaction key must be provided.
-- Postconditions :
--
-- Using tables   : cont_transaction
--
-- Using functions: ec_cont_transaction.
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION isTransactionEditable(
        p_transaction_key VARCHAR2,
        p_level VARCHAR2 DEFAULT 'TRANS',   -- Alternatively FIELD or COMPANY
        p_msg_ind VARCHAR2 DEFAULT 'N')     -- When 'Y' => Returns user friendly message instead of 'N' when result is false ('N')
RETURN VARCHAR2
--</EC-DOC>
IS
    lv2_flag        VARCHAR2(1)     := 'Y';
    lv2_op          VARCHAR2(10)    := 'EDIT';
    lv2_op_txt      VARCHAR2(10)    := 'edited';
    lv2_msg         VARCHAR2(200);
    lv2_msg_ue      VARCHAR2(200);
    lv2_msg_ue_pre  VARCHAR2(200);
    lv2_msg_main    VARCHAR2(1000);
    lv2_msg_ue_post VARCHAR2(200);
    lv2_retval      VARCHAR2(200);
BEGIN
    IF ue_cont_transaction.isIsTransEditableUEE = 'TRUE' THEN
        -- Run insteadOf-UserExit
        lv2_flag := ue_cont_transaction.isTransactionEditable(p_transaction_key, p_level, lv2_msg_ue);
        -- Set default or custom message
        IF p_msg_ind = 'Y' AND lv2_flag = 'N' THEN
            lv2_msg := NVL(lv2_msg_ue,'This transaction is evaluated by an InsteadOf User-exit and the result is that the transaction cannot be ' || lv2_op_txt || '. ');
        END IF;
    ELSE
        IF ue_cont_transaction.isIsTransEditablePreUEE = 'TRUE' THEN
            -- Run PRE-processing-UserExit
            lv2_flag := ue_cont_transaction.isTransactionEditablePre(p_transaction_key, p_level, lv2_msg_ue_pre);
            -- Set default or custom message
            IF p_msg_ind = 'Y' AND lv2_flag = 'N' THEN
                lv2_msg := NVL(lv2_msg_ue_pre,'This transaction is evaluated by a Preprocessing User-exit and the result is that the transaction cannot be ' || lv2_op_txt || '. ');
            END IF;
        END IF;
        --
        IF lv2_flag = 'Y' THEN
            -- Run SHARED rules between Editable and Deletable
            lv2_flag := isTransEditableOrDeletable (lv2_op, p_transaction_key, p_level, lv2_msg_main);
            lv2_msg  := lv2_msg_main;
        END IF;
        --
        IF ue_cont_transaction.isIsTransEditablePostUEE = 'TRUE' THEN
            -- Run POST-processing-UserExit
            lv2_flag := ue_cont_transaction.isTransactionEditablePost(p_transaction_key, p_level, lv2_flag, lv2_msg_ue_post);
            -- Set default or custom message
            IF p_msg_ind = 'Y' AND lv2_flag = 'N' THEN
                lv2_msg := NVL(lv2_msg_ue_pre,'This transaction is evaluated by a Postprocessing User-exit and the result is that the transaction cannot be ' || lv2_op_txt || '. ');
            END IF;
        END IF;
    END IF;

    -- Evaluate and set the return value
    lv2_retval :=
        CASE
            WHEN lv2_flag = 'Y' AND p_msg_ind <> 'Y' THEN lv2_flag
            WHEN lv2_flag = 'Y'                      THEN ''
            WHEN lv2_flag = 'N' AND p_msg_ind <> 'Y' THEN lv2_flag
            ELSE                                          '[ErrMsg]' || lv2_msg
        END;
    RETURN lv2_retval;
END isTransactionEditable;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isTransactionDeletable
-- Description    : Function to return whether a transaction is deletable or not (Y or N)
--                  If p_msg_ind is 'Y' then a user friendly message is returned instead of N.
--                  Use arrow notation to set the p_msg_ind if p_level is to use the default value:
--                  isTransactionEditable ('SomeTransKey', p_msg_ind => 'Y')
--
-- Preconditions  : Transaction key must be provided.
-- Postconditions :
--
-- Using tables   : cont_transaction
--
-- Using functions: ec_cont_transaction.
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION isTransactionDeletable(
        p_transaction_key VARCHAR2,
        p_level VARCHAR2 DEFAULT 'TRANS',   -- Alternatively FIELD or COMPANY
        p_msg_ind VARCHAR2 DEFAULT 'N')     -- When 'Y' => Returns user friendly message instead of 'N' when result is false ('N')
RETURN VARCHAR2
--</EC-DOC>
IS
    lv2_flag        VARCHAR2(1)     := 'Y';
    lv2_op          VARCHAR2(10)    := 'DELETE';
    lv2_op_txt      VARCHAR2(10)    := 'deleted';
    lv2_msg         VARCHAR2(200);
    lv2_msg_ue      VARCHAR2(200);
    lv2_msg_ue_pre  VARCHAR2(200);
    lv2_msg_main    VARCHAR2(1000);
    lv2_msg_ue_post VARCHAR2(200);
    lv2_retval      VARCHAR2(200);
BEGIN
    IF ue_cont_transaction.isIsTransDeletableUEE = 'TRUE' THEN
        -- Run insteadOf-UserExit
        lv2_flag := ue_cont_transaction.isTransactionDeletable(p_transaction_key, p_level, lv2_msg_ue);
        -- Set default or custom message
        IF p_msg_ind = 'Y' AND lv2_flag = 'N' THEN
            lv2_msg := NVL(lv2_msg_ue,'This transaction is evaluated by an InsteadOf User-exit and the result is that the transaction cannot be ' || lv2_op_txt || '.');
        END IF;
    ELSE
        IF ue_cont_transaction.isIsTransDeletablePreUEE = 'TRUE' THEN
            -- Run PRE-processing-UserExit
            lv2_flag := ue_cont_transaction.isTransactionDeletablePre(p_transaction_key, p_level, lv2_msg_ue_pre);
            -- Set default or custom message
            IF p_msg_ind = 'Y' AND lv2_flag = 'N' THEN
                lv2_msg := NVL(lv2_msg_ue_pre,'This transaction is evaluated by a Preprocessing User-exit and the result is that the transaction cannot be ' || lv2_op_txt || '.');
            END IF;
        END IF;
        --
        IF lv2_flag = 'Y' THEN
            -- Run SHARED rules between Editable and Deletable
            lv2_flag := isTransEditableOrDeletable (lv2_op, p_transaction_key, p_level, lv2_msg_main);
            lv2_msg  := lv2_msg_main;
        END IF;
        --
        IF ue_cont_transaction.isIsTransDeletablePostUEE = 'TRUE' THEN
            -- Run POST-processing-UserExit
            lv2_flag := ue_cont_transaction.isTransactionDeletablePost(p_transaction_key, p_level, lv2_flag, lv2_msg_ue_post);
            -- Set default or custom message
            IF p_msg_ind = 'Y' AND lv2_flag = 'N' THEN
                lv2_msg := NVL(lv2_msg_ue_post,'This transaction is evaluated by a Postprocessing User-exit and the result is that the transaction cannot be ' || lv2_op_txt || '.');
            END IF;
        END IF;
    END IF;

    -- Evaluate and set the return value
    lv2_retval :=
        CASE
            WHEN lv2_flag = 'Y' AND p_msg_ind <> 'Y' THEN lv2_flag
            WHEN lv2_flag = 'Y'                      THEN ''
            WHEN lv2_flag = 'N' AND p_msg_ind <> 'Y' THEN lv2_flag
            ELSE                                          '[ErrMsg]' || lv2_msg
        END;
    RETURN lv2_retval;
END isTransactionDeletable;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : AggregateLineItemValues
-- Description    : Procedure aggregates all line items monetary values up to transaction level.
--                  This functionality is also available in iu_cont_line_item. Monetary values are overridden by
--                  Cargo/Period Documents screens transaction level class upon save.
--
-- Preconditions  : Transaction key must be provided.
-- Postconditions :
--
-- Using tables   : cont_transaction
--
-- Using functions: ec_cont_transaction_qty.
--
-- In use in      : class trigger action in FIN_PERIOD_DOC_TRANS and FIN_CARGO_DOC_TRANS
--
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE AggregateLineItemValues (
          p_transaction_key VARCHAR2)
--</EC-DOC>
IS

  CURSOR c_AggAll(cp_transaction_key VARCHAR2) IS
      SELECT SUM(cli.pricing_value)     pricing_value,
             SUM(cli.pricing_vat_value) pricing_vat_value,
             SUM(cli.memo_value)        memo_value,
             SUM(cli.memo_vat_value)    memo_vat_value,
             SUM(cli.booking_value)     booking_value,
             SUM(cli.booking_vat_value) booking_vat_value,
             SUM(cli.group_value)       group_value,
             SUM(cli.group_vat_value)   group_vat_value,
             SUM(cli.local_value)       local_value,
             SUM(cli.local_vat_value)   local_vat_value
      FROM cont_line_item cli
      WHERE cli.transaction_key = cp_transaction_key;

  CURSOR c_AggNonQty(cp_transaction_key VARCHAR2) IS
      SELECT SUM(cli.pricing_value)     pricing_value,
             SUM(cli.pricing_vat_value) pricing_vat_value,
             SUM(cli.memo_value)        memo_value,
             SUM(cli.memo_vat_value)    memo_vat_value,
             SUM(cli.booking_value)     booking_value,
             SUM(cli.booking_vat_value) booking_vat_value
      FROM cont_line_item cli
      WHERE cli.transaction_key = cp_transaction_key
      AND cli.line_item_based_type != 'QTY';

  CURSOR c_AggQty(cp_transaction_key VARCHAR2) IS
      SELECT SUM(cli.pricing_value)     pricing_value,
             SUM(cli.pricing_vat_value) pricing_vat_value,
             SUM(cli.memo_value)        memo_value,
             SUM(cli.memo_vat_value)    memo_vat_value,
             SUM(cli.booking_value)     booking_value,
             SUM(cli.booking_vat_value) booking_vat_value
      FROM cont_line_item cli
      WHERE cli.transaction_key = cp_transaction_key
      AND cli.line_item_based_type = 'QTY';

BEGIN

  FOR rsLI IN c_AggQty(p_transaction_key) LOOP

    -- qty based line items
    UPDATE cont_transaction
     SET qty_pricing_value = rsLI.Pricing_Value,
         qty_pricing_vat   = rsLI.Pricing_Vat_Value,
         qty_memo_value    = rsLI.Memo_Value,
         qty_memo_vat      = rsLI.Memo_Vat_Value,
         qty_booking_value = rsLI.Booking_Value,
         qty_booking_vat   = rsLI.Booking_Vat_Value,
         last_updated_by   = 'SYSTEM'
     WHERE transaction_key = p_transaction_key;

  END LOOP;


  FOR rsLI IN c_AggNonQty(p_transaction_key) LOOP

    -- other based line items
    UPDATE cont_transaction
     SET other_pricing_value = rsLI.Pricing_Value,
         other_pricing_vat   = rsLI.Pricing_Vat_Value,
         other_memo_value    = rsLI.Memo_Value,
         other_memo_vat      = rsLI.Memo_Vat_Value,
         other_booking_value = rsLI.Booking_Value,
         other_booking_vat   = rsLI.Booking_Vat_Value,
         last_updated_by   = 'SYSTEM'
     WHERE transaction_key = p_transaction_key;

  END LOOP;


  FOR rsLI IN c_AggAll(p_transaction_key) LOOP

    -- transaction total
    UPDATE cont_transaction
     SET trans_pricing_value = rsLI.Pricing_Value,
         trans_pricing_vat   = rsLI.Pricing_Vat_Value,
         trans_memo_value    = rsLI.Memo_Value,
         trans_memo_vat      = rsLI.Memo_Vat_Value,
         trans_booking_value = rsLI.Booking_Value,
         trans_booking_vat   = rsLI.Booking_Vat_Value,
         trans_local_value   = rsLI.Local_Value,
         trans_local_vat     = rsLI.Local_Vat_Value,
         trans_group_value   = rsLI.Group_Value,
         trans_group_vat     = rsLI.Group_Vat_Value,
         last_updated_by = 'SYSTEM'
    WHERE transaction_key = p_transaction_key;

  END LOOP;


END AggregateLineItemValues;

PROCEDURE populateOtherTrans (
          p_document_key VARCHAR,
          p_transaction_key VARCHAR2,
          p_user VARCHAR2)
--</EC-DOC>
IS

  lb_upd_trans_cargo BOOLEAN;
  lb_upd_trans_dates BOOLEAN;
  lb_trans_found BOOLEAN;
  lb_cargo_exists BOOLEAN;
  lb_update BOOLEAN := FALSE;
  lv2_sql VARCHAR2(32000);
  lrec_trans cont_transaction%ROWTYPE := ec_cont_transaction.row_by_pk(p_transaction_key);

  CURSOR c_allTrans(cp_document_key VARCHAR2, cp_transaction_key VARCHAR2) IS
  SELECT *
    FROM cont_transaction ct
   WHERE ct.document_key = cp_document_key
     AND ct.transaction_key <> cp_transaction_key;

  CURSOR c_cargoTransFound(cp_transaction_key VARCHAR2) IS
  SELECT cargo_no cargo_name
    FROM ifac_cargo_value cv
   WHERE cv.transaction_key = cp_transaction_key
     AND rownum = 1;

CURSOR c_cargoExists(cp_cargo_no VARCHAR2,cp_parcel_no VARCHAR2,cp_qty_type VARCHAR2) IS
  SELECT 1
    FROM ifac_cargo_value cv
   WHERE cv.cargo_no = cp_cargo_no
     AND cv.parcel_no = cp_parcel_no
     AND cv.qty_type = cp_qty_type
     AND cv.trans_key_set_ind = 'N'
     AND cv.alloc_no_max_ind = 'Y'
     AND rownum = 1;

BEGIN



  FOR rec IN c_allTrans(p_document_key, p_transaction_key) LOOP

    lv2_sql := NULL;
    lb_upd_trans_cargo := FALSE;
    lb_upd_trans_dates := FALSE;
    lb_trans_found := FALSE;
    lb_cargo_exists  := FALSE;
    lb_update := FALSE;

    IF rec.CNTR_DURATION_FROM_DATE IS NULL AND lrec_trans.CNTR_DURATION_FROM_DATE IS NOT NULL THEN
       IF lv2_sql IS NOT NULL THEN lv2_sql := lv2_sql || ','; END IF;
       lv2_sql := lv2_sql || ' CNTR_DURATION_FROM_DATE=to_date('''|| lrec_trans.CNTR_DURATION_FROM_DATE || ''',''DD-MM-RRRR'')';
    END IF;

    IF rec.CNTR_DURATION_TO_DATE IS NULL AND lrec_trans.CNTR_DURATION_TO_DATE IS NOT NULL THEN
       IF lv2_sql IS NOT NULL THEN lv2_sql := lv2_sql || ','; END IF;
       lv2_sql := lv2_sql || ' CNTR_DURATION_TO_DATE=to_date('''|| lrec_trans.CNTR_DURATION_TO_DATE || ''',''DD-MM-RRRR'')';
    END IF;

    IF rec.CONTRACT_DATE IS NULL AND lrec_trans.CONTRACT_DATE IS NOT NULL THEN
       IF lv2_sql IS NOT NULL THEN lv2_sql := lv2_sql || ','; END IF;
       lv2_sql := lv2_sql || ' CONTRACT_DATE=to_date('''|| lrec_trans.CONTRACT_DATE || ''',''DD-MM-RRRR'')';
    END IF;

    IF rec.PRICING_PERIOD_FROM_DATE IS NULL AND lrec_trans.PRICING_PERIOD_FROM_DATE IS NOT NULL THEN
       IF lv2_sql IS NOT NULL THEN lv2_sql := lv2_sql || ','; END IF;
       lv2_sql := lv2_sql || ' PRICING_PERIOD_FROM_DATE=to_date('''|| lrec_trans.PRICING_PERIOD_FROM_DATE || ''',''DD-MM-RRRR'')';
    END IF;

    IF rec.PRICING_PERIOD_TO_DATE IS NULL AND lrec_trans.PRICING_PERIOD_TO_DATE IS NOT NULL THEN
       IF lv2_sql IS NOT NULL THEN lv2_sql := lv2_sql || ','; END IF;
       lv2_sql := lv2_sql || ' PRICING_PERIOD_TO_DATE=to_date('''|| lrec_trans.PRICING_PERIOD_TO_DATE || ''',''DD-MM-RRRR'')';
    END IF;

    IF rec.SALES_ORDER IS NULL AND lrec_trans.SALES_ORDER IS NOT NULL THEN
       IF lv2_sql IS NOT NULL THEN lv2_sql := lv2_sql || ','; END IF;
       lv2_sql := lv2_sql || ' SALES_ORDER='''|| lrec_trans.SALES_ORDER || '''';
    END IF;

    IF rec.PRICE_DATE IS NULL AND lrec_trans.PRICE_DATE IS NOT NULL THEN
       IF lv2_sql IS NOT NULL THEN lv2_sql := lv2_sql || ','; END IF;
       lv2_sql := lv2_sql || ' PRICE_DATE=to_date('''|| lrec_trans.PRICE_DATE || ''',''DD-MM-RRRR'')';
       lb_upd_trans_dates := TRUE;
    END IF;

    IF rec.DESTINATION_COUNTRY_CODE IS NULL AND lrec_trans.DESTINATION_COUNTRY_CODE IS NOT NULL THEN
       IF lv2_sql IS NOT NULL THEN lv2_sql := lv2_sql || ','; END IF;
       lv2_sql := lv2_sql || ' COUNTRY_CODE='''|| lrec_trans.DESTINATION_COUNTRY_CODE || '''';
    END IF;

  IF lrec_trans.transaction_scope = 'CARGO_BASED' THEN

    IF rec.CARGO_NAME IS NULL AND lrec_trans.CARGO_NAME IS NOT NULL THEN
       IF lv2_sql IS NOT NULL THEN lv2_sql := lv2_sql || ','; END IF;
       lv2_sql := lv2_sql || ' CARGO_NAME=''' || lrec_trans.CARGO_NAME  ||'''';
       lb_upd_trans_cargo := TRUE;
    END IF;

    IF rec.CARGO_NO IS NULL AND lrec_trans.CARGO_NO IS NOT NULL THEN
       IF lv2_sql IS NOT NULL THEN lv2_sql := lv2_sql || ','; END IF;
       lv2_sql := lv2_sql || ' CARGO_NO='''|| lrec_trans.CARGO_NO  ||'''';
    END IF;

    IF rec.CONSIGNEE IS NULL AND lrec_trans.CONSIGNEE IS NOT NULL THEN
       IF lv2_sql IS NOT NULL THEN lv2_sql := lv2_sql || ','; END IF;
       lv2_sql := lv2_sql || ' CONSIGNEE='''|| lrec_trans.CONSIGNEE ||'''';
    END IF;

    IF rec.CONSIGNOR IS NULL AND lrec_trans.CONSIGNOR IS NOT NULL THEN
       IF lv2_sql IS NOT NULL THEN lv2_sql := lv2_sql || ','; END IF;
       lv2_sql := lv2_sql || ' CONSIGNOR='''|| lrec_trans.CONSIGNOR  ||'''';
    END IF;

    IF rec.CARRIER_CODE IS NULL AND lrec_trans.CARRIER_CODE IS NOT NULL THEN
       IF lv2_sql IS NOT NULL THEN lv2_sql := lv2_sql || ','; END IF;
       lv2_sql := lv2_sql || ' CARRIER_CODE='''|| lrec_trans.CARRIER_CODE  ||'''';
    END IF;

    IF rec.LOADING_PORT_CODE IS NULL AND lrec_trans.LOADING_PORT_CODE IS NOT NULL THEN
       IF lv2_sql IS NOT NULL THEN lv2_sql := lv2_sql || ','; END IF;
       lv2_sql := lv2_sql || ' LOADING_PORT_CODE='''|| lrec_trans.LOADING_PORT_CODE  ||'''';
    END IF;

    IF rec.DISCHARGE_PORT_CODE IS NULL AND lrec_trans.DISCHARGE_PORT_CODE IS NOT NULL THEN
       IF lv2_sql IS NOT NULL THEN lv2_sql := lv2_sql || ','; END IF;
       lv2_sql := lv2_sql || ' DISCHARGE_PORT_CODE='''|| lrec_trans.DISCHARGE_PORT_CODE ||'''';
    END IF;

    IF rec.LOADING_DATE_COMMENCED IS NULL AND lrec_trans.LOADING_DATE_COMMENCED IS NOT NULL THEN
       IF lv2_sql IS NOT NULL THEN lv2_sql := lv2_sql || ','; END IF;
       lv2_sql := lv2_sql || ' LOADING_DATE_COMMENCED=to_date('''|| lrec_trans.LOADING_DATE_COMMENCED || ''',''DD-MM-RRRR'')';
       lb_upd_trans_dates := TRUE;
    END IF;

    IF rec.LOADING_DATE_COMPLETED IS NULL AND lrec_trans.LOADING_DATE_COMPLETED IS NOT NULL THEN
       IF lv2_sql IS NOT NULL THEN lv2_sql := lv2_sql || ','; END IF;
       lv2_sql := lv2_sql || ' LOADING_DATE_COMPLETED=to_date('''|| lrec_trans.LOADING_DATE_COMPLETED || ''',''DD-MM-RRRR'')';
       lb_upd_trans_dates := TRUE;
    END IF;

    IF rec.DELIVERY_DATE_COMMENCED IS NULL AND lrec_trans.DELIVERY_DATE_COMMENCED IS NOT NULL THEN
       IF lv2_sql IS NOT NULL THEN lv2_sql := lv2_sql || ','; END IF;
       lv2_sql := lv2_sql || ' DELIVERY_DATE_COMMENCED=to_date('''|| lrec_trans.DELIVERY_DATE_COMMENCED || ''',''DD-MM-RRRR'')';
       lb_upd_trans_dates := TRUE;
    END IF;

    IF rec.DELIVERY_DATE_COMPLETED IS NULL AND lrec_trans.DELIVERY_DATE_COMPLETED IS NOT NULL THEN
       IF lv2_sql IS NOT NULL THEN lv2_sql := lv2_sql || ','; END IF;
       lv2_sql := lv2_sql || ' DELIVERY_DATE_COMPLETED=to_date('''|| lrec_trans.DELIVERY_DATE_COMPLETED || ''',''DD-MM-RRRR'')';
       lb_upd_trans_dates := TRUE;
    END IF;

    IF rec.BL_DATE IS NULL AND lrec_trans.BL_DATE IS NOT NULL THEN
       IF lv2_sql IS NOT NULL THEN lv2_sql := lv2_sql || ','; END IF;
       lv2_sql := lv2_sql || ' BL_DATE=to_date('''|| lrec_trans.BL_DATE || ''',''DD-MM-RRRR'')';
       lb_upd_trans_dates := TRUE;
    END IF;

  END IF;


  IF lrec_trans.transaction_scope = 'PERIOD_BASED' THEN

    IF rec.SUPPLY_FROM_DATE IS NULL AND lrec_trans.SUPPLY_FROM_DATE IS NOT NULL THEN
       IF lv2_sql IS NOT NULL THEN lv2_sql := lv2_sql || ','; END IF;
       lv2_sql := lv2_sql || ' SUPPLY_FROM_DATE=to_date('''|| lrec_trans.SUPPLY_FROM_DATE || ''',''DD-MM-RRRR'')';
       lb_upd_trans_dates := TRUE;
    END IF;

    IF rec.SUPPLY_TO_DATE IS NULL AND lrec_trans.SUPPLY_TO_DATE IS NOT NULL THEN
       IF lv2_sql IS NOT NULL THEN lv2_sql := lv2_sql || ','; END IF;
       lv2_sql := lv2_sql || ' SUPPLY_TO_DATE=to_date('''|| lrec_trans.SUPPLY_TO_DATE || ''',''DD-MM-RRRR'')';
       lb_upd_trans_dates := TRUE;
    END IF;

     IF rec.DELIVERY_POINT_CODE IS NULL AND lrec_trans.DELIVERY_POINT_CODE IS NOT NULL THEN
       IF lv2_sql IS NOT NULL THEN lv2_sql := lv2_sql || ','; END IF;
       lv2_sql := lv2_sql || ' DELIVERY_POINT_CODE='''|| lrec_trans.DELIVERY_POINT_CODE ||'''';
    END IF;

    IF rec.DELIVERY_PLANT_CODE IS NULL AND lrec_trans.DELIVERY_PLANT_CODE IS NOT NULL THEN
       IF lv2_sql IS NOT NULL THEN lv2_sql := lv2_sql || ','; END IF;
       lv2_sql := lv2_sql || ' DELIVERY_PLANT_CODE='''|| lrec_trans.DELIVERY_PLANT_CODE ||'''';
    END IF;

    IF rec.ENTRY_POINT_CODE IS NULL AND lrec_trans.ENTRY_POINT_CODE IS NOT NULL THEN
       IF lv2_sql IS NOT NULL THEN lv2_sql := lv2_sql || ','; END IF;
       lv2_sql := lv2_sql || ' ENTRY_POINT_CODE='''|| lrec_trans.ENTRY_POINT_CODE ||'''';
    END IF;

    IF rec.ENTRY_POINT_ID IS NULL AND lrec_trans.ENTRY_POINT_ID IS NOT NULL THEN
       IF lv2_sql IS NOT NULL THEN lv2_sql := lv2_sql || ','; END IF;
       lv2_sql := lv2_sql || ' ENTRY_POINT_ID='''|| lrec_trans.ENTRY_POINT_ID ||'''';

    END IF;

  END IF;

  IF lv2_sql IS NOT NULL OR lv2_sql != '' THEN
    --update the transaction
    lv2_sql := 'UPDATE DV_CONT_TRANSACTION SET ' || lv2_sql || ' WHERE TRANSACTION_KEY = ''' || rec.transaction_key || '''';

    EXECUTE IMMEDIATE lv2_sql;

    lb_update := TRUE;

    IF lb_upd_trans_cargo = TRUE THEN

     -- Cargo handling (changed cargo, parcel or qty type)

     -- Release cargo from transaction
     FOR cur in c_cargoTransFound(rec.transaction_key) LOOP
         lb_trans_found := TRUE;
     END LOOP;

     -- Resetting line item quantities. Will enable EcDp_Transaction_Qty.GenQtyForTransaction to fetch any cargo quantities
     -- Delete "old" cargo qty if "new" cargo is selected
     FOR cur in c_cargoExists(rec.cargo_name,rec.parcel_name,rec.qty_type) LOOP
         lb_cargo_exists := TRUE;
     END LOOP;

     -- If going from an existing cargo on transaction to a non-existing: Release cargo from transaction. Keep quantities on line items.
     IF lb_trans_found = TRUE AND lb_cargo_exists = FALSE THEN

        UPDATE ifac_cargo_value
           SET transaction_key = NULL,
               trans_key_set_ind = 'N'
         WHERE transaction_key = rec.transaction_key;

     END IF;

     -- If going from an existing cargo on transaction to an new existing cargo: Release cargo from transaction and retrieve new cargo qtys
     IF lb_trans_found = TRUE AND lb_cargo_exists = TRUE THEN

        --reset
        UPDATE cont_transaction_qty ctq SET
            ctq.net_qty1 = NULL,
            ctq.net_qty2 = NULL,
            ctq.net_qty3 = NULL,
            ctq.net_qty4 = NULL,
            ctq.grs_qty1 = NULL,
            ctq.grs_qty2 = NULL,
            ctq.grs_qty3 = NULL,
            ctq.grs_qty4 = NULL
          WHERE ctq.transaction_key = rec.transaction_key;

         --release
         UPDATE ifac_cargo_value
            SET transaction_key = NULL,
                trans_key_set_ind = 'N'
          WHERE transaction_key = rec.transaction_key;

     END IF;

     -- If going from a non-existing cargo on transaction to an existing: Run logic to set cargo qty on transaction
     IF lb_trans_found = FALSE AND lb_cargo_exists = TRUE THEN

        --reset
        UPDATE cont_transaction_qty ctq SET
            ctq.net_qty1 = NULL,
            ctq.net_qty2 = NULL,
            ctq.net_qty3 = NULL,
            ctq.net_qty4 = NULL,
            ctq.grs_qty1 = NULL,
            ctq.grs_qty2 = NULL,
            ctq.grs_qty3 = NULL,
            ctq.grs_qty4 = NULL
          WHERE ctq.transaction_key = rec.transaction_key;

     END IF;

  END IF;

     -- Now performs update:
     UpdFromTransactionGeneral(rec.object_id, rec.document_key, rec.transaction_key, rec.daytime, p_user);

     -- Any dates has been manually modified
     IF lb_upd_trans_dates = TRUE THEN

        EcDp_Contract_Setup.UpdateAllDocumentDates(rec.object_id, rec.document_key, rec.daytime, ec_cont_document.document_date(rec.document_key), p_user);

        -- Now performs update Prices
        EcDp_Document.Filldocumentprice(rec.document_key, p_user);

        UPDATE cont_line_item SET
               rev_text = 'Recalculation due to new exchange rates',
                last_updated_by    = p_user
              WHERE object_id = rec.object_id AND transaction_key = rec.transaction_key;

     END IF;

     END IF;

END LOOP;

  IF lb_update = TRUE THEN
   -- Now performs update Vendor/Customer Country and VAT NO:
   EcDp_Document.UpdDocumentVat(p_document_key, ec_cont_transaction.daytime(p_transaction_key), p_user);

  END IF;

END populateOtherTrans;

FUNCTION isEmptyTrans(p_transaction_key VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR cur_cli(cp_transaction_key VARCHAR2) IS
  SELECT * FROM CONT_LINE_ITEM cli
  WHERE  cli.TRANSACTION_KEY=cp_transaction_key AND (
  (cli.line_item_based_type = 'QTY'AND cli.QTY1 IS NOT NULL) OR
  (cli.line_item_based_type = 'CALC_QTY_VALUE'AND cli.QTY1 IS NOT NULL) OR
  (cli.line_item_based_type = 'FREE_UNIT_PRICE_OBJECT'AND cli.FREE_UNIT_QTY IS NOT NULL) OR
  (cli.line_item_based_type = 'FREE_UNIT'AND cli.FREE_UNIT_QTY IS NOT NULL) OR
  (cli.line_item_based_type = 'PERCENTAGE_QTY'AND cli.PRICING_VALUE IS NOT NULL) OR
  (cli.line_item_based_type = 'PERCENTAGE_MANUAL'AND cli.PRICING_VALUE IS NOT NULL) OR
  (cli.line_item_based_type = 'PERCENTAGE_ALL'AND cli.PRICING_VALUE IS NOT NULL) OR
  (cli.line_item_based_type = 'INTEREST'AND cli.PRICING_VALUE IS NOT NULL) OR
  (cli.line_item_based_type = 'FIXED_VALUE'AND cli.PRICING_VALUE IS NOT NULL) OR
  (cli.line_item_based_type = 'CALC_VALUE'AND cli.PRICING_VALUE IS NOT NULL))
  ;
BEGIN

 FOR rec IN cur_cli(p_transaction_key) LOOP
     RETURN 'N';
 END LOOP;

 RETURN 'Y';

END isEmptyTrans;


    -----------------------------------------------------------------------
    -- Sets quantities based on another transaction's quantity values.
    ----+----------------------------------+-------------------------------
    PROCEDURE set_qty_by_another_p(
        p_quantity_rec                     IN OUT NOCOPY cont_transaction_qty%ROWTYPE
       ,p_source_quantity_rec              IN OUT NOCOPY cont_transaction_qty%ROWTYPE
       ,p_overwrite_null_values_only       BOOLEAN
       ,p_context                          IN OUT NOCOPY T_REVN_DOC_OP_CONTEXT
    )
    IS
    BEGIN
        IF ((p_quantity_rec.uom1_code = p_source_quantity_rec.uom1_code)
             AND (p_quantity_rec.net_qty1 IS NULL OR NOT p_overwrite_null_values_only)) THEN
            p_quantity_rec.net_qty1        := p_source_quantity_rec.net_qty1;
            p_quantity_rec.grs_qty1        := p_source_quantity_rec.grs_qty1;
            p_quantity_rec.uom1_code       := p_source_quantity_rec.uom1_code;
            p_quantity_rec.pre_net_qty1    := p_source_quantity_rec.net_qty1;
            p_quantity_rec.pre_grs_qty1    := p_source_quantity_rec.grs_qty1;
            p_quantity_rec.pre_uom1_code   := p_source_quantity_rec.uom1_code;
        END IF;

        IF ((p_quantity_rec.uom2_code = p_source_quantity_rec.uom2_code)
             AND (p_quantity_rec.net_qty2 IS NULL OR NOT p_overwrite_null_values_only)) THEN
            p_quantity_rec.net_qty2        := p_source_quantity_rec.net_qty2;
            p_quantity_rec.grs_qty2        := p_source_quantity_rec.grs_qty2;
            p_quantity_rec.uom2_code       := p_source_quantity_rec.uom2_code;
            p_quantity_rec.pre_net_qty2    := p_source_quantity_rec.net_qty2;
            p_quantity_rec.pre_grs_qty2    := p_source_quantity_rec.grs_qty2;
            p_quantity_rec.pre_uom2_code   := p_source_quantity_rec.uom2_code;
        END IF;

        IF ((p_quantity_rec.uom3_code = p_source_quantity_rec.uom3_code)
             AND (p_quantity_rec.net_qty3 IS NULL OR NOT p_overwrite_null_values_only)) THEN
            p_quantity_rec.net_qty3        := p_source_quantity_rec.net_qty3;
            p_quantity_rec.grs_qty3        := p_source_quantity_rec.grs_qty3;
            p_quantity_rec.uom3_code       := p_source_quantity_rec.uom3_code;
            p_quantity_rec.pre_net_qty3    := p_source_quantity_rec.net_qty3;
            p_quantity_rec.pre_grs_qty3    := p_source_quantity_rec.grs_qty3;
            p_quantity_rec.pre_uom3_code   := p_source_quantity_rec.uom3_code;
        END IF;

        IF ((p_quantity_rec.uom4_code = p_source_quantity_rec.uom4_code)
             AND (p_quantity_rec.net_qty4 IS NULL OR NOT p_overwrite_null_values_only)) THEN
            p_quantity_rec.net_qty4        := p_source_quantity_rec.net_qty4;
            p_quantity_rec.grs_qty4        := p_source_quantity_rec.grs_qty4;
            p_quantity_rec.uom4_code       := p_source_quantity_rec.uom4_code;
            p_quantity_rec.pre_net_qty4    := p_source_quantity_rec.net_qty4;
            p_quantity_rec.pre_grs_qty4    := p_source_quantity_rec.grs_qty4;
            p_quantity_rec.pre_uom4_code   := p_source_quantity_rec.uom4_code;
        END IF;
    END;

    -----------------------------------------------------------------------
    -- Applys changes to transaction quantity record back to
    -- cont_transaction_qty table.
    ----+----------------------------------+-------------------------------
    PROCEDURE apply_p(
        p_context                          IN OUT NOCOPY T_REVN_DOC_OP_CONTEXT
       ,p_quantity_rec                     IN OUT NOCOPY cont_transaction_qty%ROWTYPE
    )
    IS
    BEGIN
        UPDATE cont_transaction_qty
        SET last_updated_by = p_context.user_id
           ,net_qty1        = p_quantity_rec.net_qty1
           ,grs_qty1        = p_quantity_rec.grs_qty1
           ,uom1_code       = p_quantity_rec.uom1_code
           ,pre_net_qty1    = p_quantity_rec.net_qty1
           ,pre_grs_qty1    = p_quantity_rec.grs_qty1
           ,pre_uom1_code   = p_quantity_rec.uom1_code
           ,net_qty2        = p_quantity_rec.net_qty2
           ,grs_qty2        = p_quantity_rec.grs_qty2
           ,uom2_code       = p_quantity_rec.uom2_code
           ,pre_net_qty2    = p_quantity_rec.net_qty2
           ,pre_grs_qty2    = p_quantity_rec.grs_qty2
           ,pre_uom2_code   = p_quantity_rec.uom2_code
           ,net_qty3        = p_quantity_rec.net_qty3
           ,grs_qty3        = p_quantity_rec.grs_qty3
           ,uom3_code       = p_quantity_rec.uom3_code
           ,pre_net_qty3    = p_quantity_rec.net_qty3
           ,pre_grs_qty3    = p_quantity_rec.grs_qty3
           ,pre_uom3_code   = p_quantity_rec.uom3_code
           ,net_qty4        = p_quantity_rec.net_qty4
           ,grs_qty4        = p_quantity_rec.grs_qty4
           ,uom4_code       = p_quantity_rec.uom4_code
           ,pre_net_qty4    = p_quantity_rec.net_qty4
           ,pre_grs_qty4    = p_quantity_rec.grs_qty4
           ,pre_uom4_code   = p_quantity_rec.uom4_code
        WHERE transaction_key = p_quantity_rec.transaction_key;
    END;


------------------------+-----------------------------------+------------------------------------+---------------------------
-- (see header)
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION fill_qty_line_n_quantity_i(
                         p_context                          IN OUT NOCOPY T_REVN_DOC_OP_CONTEXT
                        ,p_transaction_key                  VARCHAR2
)
RETURN BOOLEAN
IS

lrec_tran                 cont_transaction%ROWTYPE := ec_cont_transaction.row_by_pk(p_transaction_key);
lrec_cont_transaction_qty cont_transaction_qty%rowtype;
lrec_preceeding_ctq       cont_transaction_qty%rowtype;
lv2_contract_id           contract.object_id%type;
lv2_document_key          cont_document.document_key%type;
lv2_document_status       cont_document.status_code%type;
lv2_preceding_trans_key   cont_transaction.transaction_key%type;
lv2_transaction_date      cont_transaction.transaction_date%type;
l_qty_updated             BOOLEAN;
--missing_transaction_date EXCEPTION;


BEGIN

  IF ue_cont_transaction.isFillTransQtyUEEnabled = 'TRUE' THEN
    ue_cont_transaction.FillTransactionQuantity(p_transaction_key, p_context.user_id);
  ELSE

    lv2_transaction_date := ec_cont_transaction.transaction_date(p_transaction_key);
    lv2_preceding_trans_key := ec_cont_transaction.preceding_trans_key(p_transaction_key);
    lv2_contract_id := ec_cont_transaction.object_id(p_transaction_key);

    IF lv2_transaction_date IS NOT NULL THEN
--        RAISE missing_transaction_date;

        lv2_document_key := ec_cont_transaction.document_key(p_transaction_key);
        lv2_document_status := ec_cont_document.status_code(lv2_document_key);
        lrec_preceeding_ctq := ec_cont_transaction_qty.row_by_pk(lv2_preceding_trans_key);

        -- Generates quantities and distibutions
        l_qty_updated := EcDp_Transaction_Qty.GenTransQty_I(
            lv2_contract_id, p_transaction_key, p_context.user_id,p_context, TRUE);

        IF l_qty_updated THEN
            -- Updates percentage line items
            UpdPercentageLineItem(p_transaction_key, p_context.user_id);
        END IF;

        -- Get cont transaction qty record, which may now have been populated with qtys
        lrec_cont_transaction_qty := Ec_Cont_Transaction_Qty.row_by_pk(p_transaction_key);

        -- Pick QTY from provisional transaction if no new value present from interfaces
        IF (lrec_preceeding_ctq.transaction_key IS NOT NULL AND lrec_cont_transaction_qty.net_qty1 IS NULL) THEN
           set_qty_by_another_p(lrec_cont_transaction_qty, lrec_preceeding_ctq, TRUE, p_context);
           apply_p(p_context, lrec_cont_transaction_qty);
        END IF;

    END IF;
  END IF;

  IF ue_cont_transaction.isFillTransQtyPostUEEnabled = 'TRUE' THEN
    ue_cont_transaction.FillTransQtyPost(p_transaction_key, p_context.user_id);
  END IF;

  RETURN TRUE;
END;


------------------------+-----------------------------------+------------------------------------+---------------------------
-- (see header)
------------------------+-----------------------------------+------------------------------------+---------------------------
procedure fill_transaction_i(
                         p_context                          IN OUT NOCOPY T_REVN_DOC_OP_CONTEXT
                        ,p_transaction_key                  VARCHAR2
                        ,p_daytime                          DATE
                        )
is
    lrec_transaction CONT_TRANSACTION%ROWTYPE;
    l_updated BOOLEAN;
    l_logger t_revn_logger;
BEGIN
    l_updated := FALSE;
    p_context.get_or_create_logger(l_logger);

    l_logger.debug('Start generating values for transaction ' || p_transaction_key || '...');

    IF ue_cont_transaction.isFillTransUEEnabled = 'TRUE' THEN
        ue_cont_transaction.FillTransaction(p_transaction_key, p_daytime, p_context.user_id);
        return;
    end if;

    lrec_transaction := ec_cont_transaction.row_by_pk(p_transaction_key);

    l_updated := fill_qty_line_n_quantity_i(p_context, p_transaction_key);
    l_updated := fill_non_qty_lines_p(p_context, p_transaction_key) OR l_updated;

    IF l_updated THEN
        ecdp_line_item.sync_dist_from_qty_i(p_transaction_key);
        FillTransactionPrice(p_transaction_key,p_daytime,p_context.user_id,'QTY');
        UpdPercentageLineItem(p_transaction_key, p_context.user_id);
    END IF;

    SetTransSortOrder(lrec_transaction, TRUE, p_context.user_id);
    SetTransactionName(lrec_transaction, p_context.user_id, NULL);

    IF ue_cont_transaction.isFillTransPostUEEnabled = 'TRUE' THEN
        ue_cont_transaction.FillTransPost(p_transaction_key, p_daytime, p_context.user_id);
    END IF;

    l_logger.debug('Transaction values generated.');
end;



------------------------+-----------------------------------+------------------------------------+---------------------------
-- (See header)
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE FillTransaction(
                         p_transaction_key                  VARCHAR2
                        ,p_daytime                          DATE
                        ,p_user                             VARCHAR2
)
IS
    lo_context T_REVN_DOC_OP_CONTEXT := T_REVN_DOC_OP_CONTEXT();
BEGIN
    lo_context.user_id := p_user;
    lo_context.config_logger(NULL, 'REVN_FT_DOC_ACTION');

    fill_transaction_i(lo_context, p_transaction_key, p_daytime);
END FillTransaction;


PROCEDURE SetTransactionName(p_transaction CONT_TRANSACTION%ROWTYPE, p_user VARCHAR2, p_size_limit NUMBER DEFAULT 240)
IS
 lv2_trans_name VARCHAR2(240);
BEGIN
  lv2_trans_name := getTransactionName(p_transaction, p_size_limit);

  --If the name still contains a '$' sign we assume the replace failed - then we use the original name:
  if INSTR(lv2_trans_name, '$') > 0 THEN
     lv2_trans_name := p_transaction.name;
  end if;

  update cont_transaction t
   set t.name = lv2_trans_name,
   t.last_updated_by = p_user,
   t.last_updated_date = Ecdp_Timestamp.getCurrentSysdate
   where t.transaction_key = p_transaction.transaction_key;
END SetTransactionName;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : FillTransactionPrice
-- Description    : Procedure will handle new prices related to the given transaction only for Qty Line item
-- Preconditions  :
-- Postconditions :
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      : Handle new prices
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE FillTransactionPrice(p_transaction_key      VARCHAR2,
                               p_daytime              DATE,
                               p_user                 VARCHAR2,
                               p_line_item_based_type VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS


CURSOR c_li IS
  select object_id,
         line_item_key,
         line_item_based_type,
         line_item_template_id,
         price_object_id,
         price_element_code,
         price_concept_code
    from cont_line_item
   where transaction_key = p_transaction_key
     --AND line_item_based_type is null or line_item_based_type ='QTY';
     AND line_item_based_type IN ('FREE_UNIT_PRICE_OBJECT', 'QTY')
     AND line_item_based_type = NVL(p_line_item_based_type, line_item_based_type);


CURSOR c_pli(cp_preceding_trans_key VARCHAR2, cp_line_item_based_type VARCHAR2, cp_price_concept_code VARCHAR2, cp_price_element_code VARCHAR2) IS
  SELECT *
   FROM cont_line_item cli
  WHERE cli.transaction_key = cp_preceding_trans_key
    -- AND cli.line_item_based_type is null or line_item_based_type ='QTY'
    AND cli.line_item_based_type IN ('FREE_UNIT_PRICE_OBJECT', 'QTY')
    AND cli.line_item_based_type = NVL(cp_line_item_based_type, cli.line_item_based_type)
    AND cli.price_concept_code = cp_price_concept_code
    AND cli.price_element_code = cp_price_element_code;


lrec_cont_transaction cont_transaction%ROWTYPE;
lv2_document_concept_code cont_document.document_concept%type;
lb_check VARCHAR2(1) := 'N';
ln_ifacQtyPrice NUMBER;
--ln_ifacFreeUnitPrice NUMBER;

BEGIN

  IF ue_cont_transaction.isFillTransPriceUEEnabled = 'TRUE' THEN
    ue_cont_transaction.FillTransactionPrice(p_transaction_key, p_daytime, p_user,p_line_item_based_type);
  ELSE

    lrec_cont_transaction := Ec_Cont_Transaction.row_by_pk(p_transaction_key);
    lv2_document_concept_code := ec_cont_document.document_concept(lrec_cont_transaction.document_key);

    ln_ifacQtyPrice := GetIfacQtyPrice(p_transaction_key);
    /*if(p_line_item_based_type = 'FREE_UNIT_PRICE_OBJECT' or p_line_item_based_type ='FREE_UNIT') then
    ln_ifacFreeUnitPrice := GetIfacFreeUnitPrice(p_transaction_key,p_line_item_based_type);
    end if;*/

    -- Need to determine if price has been exposed in interface.
    -- In that case this will override the price values on all line items on the given transaction

    IF ln_ifacQtyPrice IS NOT NULL THEN

        UPDATE cont_line_item
           SET unit_price = ln_ifacQtyPrice, last_updated_by = p_user
         WHERE transaction_key = p_transaction_key;-- and line_item_based_type='QTY';

        lb_check := 'Y';

    END IF;
    /* IF ln_ifacFreeUnitPrice IS NOT NULL  and (p_line_item_based_type = 'FREE_UNIT_PRICE_OBJECT' or p_line_item_based_type ='FREE_UNIT') THEN

        UPDATE cont_line_item
           SET unit_price = ln_ifacFreeUnitPrice, last_updated_by = p_user
         WHERE transaction_key = p_transaction_key and line_item_based_type =p_line_item_based_type ;

        lb_check := 'Y';

    END IF;*/



    IF lb_check = 'N' THEN

      FOR LIcur IN c_li LOOP

          IF lv2_document_concept_code = 'REALLOCATION' THEN

             -- If reallocation, use the same prices as preceding
             FOR rsPLI IN c_pli(lrec_cont_transaction.preceding_trans_key, LIcur.line_item_based_type, LIcur.Price_Concept_Code, LIcur.Price_Element_Code) LOOP

                UPDATE cont_line_item
                   SET unit_price      = rsPLI.Unit_Price,
                       last_updated_by = p_user
                 WHERE line_item_key = LIcur.line_item_key;-- and line_item_based_type='QTY';

             END LOOP;

          ELSE

              -- update with new unit_price
              IF p_daytime IS NULL THEN

                UPDATE cont_line_item
                   SET unit_price = NULL, last_updated_by = p_user
                 WHERE line_item_key = LIcur.line_item_key;

              ELSE

                UPDATE cont_line_item
                   SET unit_price      = GetQtyPrice(LIcur.object_id,
                                                                      LIcur.line_item_key,
                                                                      LIcur.line_item_template_id,
                                                                      p_transaction_key,
                                                                      p_daytime,
                                                                      LIcur.line_item_based_type,
                                                                      LIcur.Price_Object_Id,
                                                                      LIcur.Price_Element_Code,
                                                                      'Y'),
                       last_updated_by = p_user
                 WHERE line_item_key = LIcur.line_item_key;

              END IF;

          END IF;

      END LOOP;

    END IF;


    -- Updating precentage line items
    updpercentagelineitem(p_transaction_key,p_user);

  END IF;

  IF ue_cont_transaction.isFillTransPricePostUEEnabled = 'TRUE' THEN
    ue_cont_transaction.FillTransPricePost(p_transaction_key, p_daytime, p_user,p_line_item_based_type);
  END IF;
END FillTransactionPrice;




--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : FillTransactionPriceOli
-- Description    : Procedure will handle new prices related to the given transaction for OLi
-- Preconditions  :
-- Postconditions :
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      : Handle new prices
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE FillTransactionPriceOli(p_transaction_key      VARCHAR2,
                                  p_daytime              DATE,
                                  p_user                 VARCHAR2,
                                  p_line_item_key        VARCHAR2,
                                  p_line_item_based_type VARCHAR2 DEFAULT NULL,
                                  p_line_item_type       VARCHAR2 DEFAULT NULL,
                                  p_ifac_li_conn_code    VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

CURSOR c_li IS
  select object_id,
         line_item_key,
         line_item_based_type,
         line_item_template_id,
         price_object_id,
         price_element_code,
         price_concept_code
    from cont_line_item
   where transaction_key = p_transaction_key
     --AND line_item_based_type is null or line_item_based_type ='QTY';
     AND line_item_based_type = NVL(p_line_item_based_type, line_item_based_type)
     AND line_item_type = nvl(p_line_item_type, line_item_type)
     AND ifac_li_conn_code = nvl(p_ifac_li_conn_code, ifac_li_conn_code);


CURSOR c_pli(cp_preceding_trans_key VARCHAR2, cp_line_item_based_type VARCHAR2, cp_price_concept_code VARCHAR2, cp_price_element_code VARCHAR2) IS
  SELECT *
   FROM cont_line_item cli
  WHERE cli.transaction_key = cp_preceding_trans_key
   -- AND cli.line_item_based_type is null or line_item_based_type ='QTY'
    AND cli.line_item_based_type = NVL(cp_line_item_based_type, cli.line_item_based_type)
    AND cli.line_item_type = nvl(p_line_item_type, line_item_type)
    AND cli.ifac_li_conn_code = nvl(p_ifac_li_conn_code, ifac_li_conn_code)
    AND cli.price_concept_code = cp_price_concept_code
    AND cli.price_element_code = cp_price_element_code;


lrec_cont_transaction cont_transaction%ROWTYPE;
lv2_document_concept_code cont_document.document_concept%type;
lb_check VARCHAR2(1) := 'N';
ln_ifacOliPrice NUMBER;
--ln_ifacFreeUnitPrice NUMBER;

BEGIN

  IF ue_cont_transaction.isFillTransPriceUEEnabled = 'TRUE' THEN
    null;
   -- ue_cont_transaction.FillTransactionPrice(p_transaction_key, p_daytime, p_user,p_line_item_based_type);
  ELSE

    lrec_cont_transaction := Ec_Cont_Transaction.row_by_pk(p_transaction_key);
    lv2_document_concept_code := ec_cont_document.document_concept(lrec_cont_transaction.document_key);

    -- ln_ifacQtyPrice := GetIfacQtyPrice(p_transaction_key);

    ln_ifacOliPrice := GetIfacOliPrice(p_transaction_key, p_line_item_based_type, p_line_item_type, p_ifac_li_conn_code);

    -- Need to determine if price has been exposed in interface.
    -- In that case this will override the price values on all line items on the given transaction

    IF ln_ifacOliPrice IS NOT NULL THEN
        UPDATE cont_line_item
           SET unit_price = ln_ifacOliPrice, last_updated_by = p_user
         WHERE transaction_key = p_transaction_key
           AND line_item_based_type = p_line_item_based_type
           AND nvl(line_item_type,'X') = nvl(p_line_item_type,'X')
           AND nvl(ifac_li_conn_code,'X') = nvl(p_ifac_li_conn_code,'X');

        lb_check := 'Y';

    END IF;


    IF lb_check = 'N' THEN

              -- update with new unit_price
              IF p_daytime IS NULL THEN

                UPDATE cont_line_item
                   SET unit_price = NULL, last_updated_by = p_user
                 WHERE line_item_key = p_line_item_key;

              ELSE
                  ln_ifacOliPrice := GetQtyPrice(ec_cont_transaction.object_id(p_transaction_key),
                                                 p_line_item_key,
                                                 ec_cont_line_item.line_item_template_id(p_line_item_key),
                                                 p_transaction_key,
                                                 p_daytime,
                                                 p_line_item_based_type,
                                                 ec_cont_line_item.price_object_id(p_line_item_key),
                                                 ec_cont_line_item.price_concept_code(p_line_item_key),
                                                 'Y');

                UPDATE cont_line_item
                   SET unit_price      = ln_ifacOliPrice,
                       last_updated_by = p_user
                 WHERE line_item_key = p_line_item_key
                   AND line_item_based_type = p_line_item_based_type
                   AND nvl(line_item_type,'X') = nvl(p_line_item_type,'X')
                   AND nvl(ifac_li_conn_code,'X') = nvl(p_ifac_li_conn_code,'X');

              END IF;
    END IF;


    -- Updating precentage line items
    updpercentagelineitem(p_transaction_key,p_user);

  END IF;

  IF ue_cont_transaction.isFillTransPricePostUEEnabled = 'TRUE' THEN
    ue_cont_transaction.FillTransPricePost(p_transaction_key, p_daytime, p_user, p_line_item_based_type);
  END IF;
END FillTransactionPriceOli;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : UpdPercentageLineItem
-- Description    : Updates all percentage line_items.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : cont_line_item
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE UpdPercentageLineItem
 (p_transaction_key VARCHAR2,
  p_user VARCHAR2
)
--</EC-DOC>
IS
--main cursor
CURSOR c_line_item IS
SELECT t.*
  FROM cont_line_item t
 WHERE t.transaction_key = p_transaction_key
   AND t.line_item_based_type IN
       ('PERCENTAGE_ALL', 'PERCENTAGE_QTY', 'PERCENTAGE_MANUAL') --take all percentage type line items
 ORDER BY t.line_item_based_type DESC --  PERCENTAGE_ALL needs to be done last to get updated baseamount from other LI
;

BEGIN
 IF( ec_cont_document.document_level_code(ec_cont_transaction.document_key(p_transaction_key)) = 'OPEN') THEN

   FOR LineItemCur IN c_line_item LOOP
       ecdp_line_item.fill_li_val_perc(LineItemCur, p_user);

   END LOOP;
END IF;
END UpdPercentageLineItem;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : IsIfacQtyPrice
-- Description    :  Returns true if a unit price is found in the quantity interface for the given transaction. False otherwise
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION IsIfacQtyPrice(p_transaction_key VARCHAR2)
RETURN BOOLEAN
IS

  lrec_d cont_document%rowtype;
  lrec_t cont_transaction%rowtype;
  lrec_tq  cont_transaction_qty%ROWTYPE;
  lb_found BOOLEAN := FALSE;

BEGIN

  lrec_t := ec_cont_transaction.row_by_pk(p_transaction_key);
  lrec_tq := ec_cont_transaction_qty.row_by_pk(p_transaction_key);
  lrec_d := ec_cont_document.row_by_pk(lrec_t.document_key);

  IF lrec_t.transaction_scope = 'PERIOD_BASED' THEN
    -- PERIOD_BASED
  FOR v IN gc_IfacQtyPrice (lrec_t.object_id,
                            trunc(lrec_t.transaction_date,'MM'),
                            lrec_t.supply_from_date,
                            lrec_t.supply_to_date,
                            lrec_t.price_concept_code,
                            lrec_t.delivery_point_id,
                            lrec_t.product_id,
                            lrec_d.customer_id,
                            lrec_t.qty_type,
                            lrec_tq.uom1_code,
                            lrec_t.price_object_id,
                            lrec_t.ifac_unique_key_1,
                            lrec_t.ifac_unique_key_2,
                            lrec_t.ifac_tt_conn_code) LOOP

      IF v.unit_price IS NOT NULL THEN
        lb_found := TRUE;
        EXIT;
      END IF;
    END LOOP;
  ELSE
    -- CARGO_BASED
    FOR v IN gc_IfacCargoPrice(lrec_t.object_id,
                               lrec_t.cargo_name,
                               lrec_t.parcel_name,
                               lrec_t.qty_type,
                               lrec_t.price_object_id,
                               lrec_t.price_concept_code,
                               lrec_t.product_id,
                               lrec_d.customer_id,
                               lrec_tq.uom1_code,
                               lrec_t.ifac_tt_conn_code) LOOP

      IF v.unit_price IS NOT NULL THEN
        lb_found := TRUE;
        EXIT;
      END IF;
  END LOOP;
  END IF;

  RETURN lb_found;

END IsIfacQtyPrice;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : GetUnitPriceByPriceSrcType
-- Description    : Returns the unit price based on price_src_type specified in the given transaction.
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetUnitPriceByPriceSrcType(
                         p_transaction_key                  VARCHAR
                        ,p_qty                              NUMBER DEFAULT NULL
                        ,p_unit_price                       NUMBER DEFAULT NULL
                        ,p_pricing_value                    NUMBER DEFAULT NULL)
RETURN NUMBER
IS
  lv_price_src_type VARCHAR(32);
  ln_unit_price     NUMBER;
BEGIN
  lv_price_src_type := ec_cont_transaction.price_src_type(p_transaction_key);
  IF lv_price_src_type = 'PRICING_VALUE' THEN
    ln_unit_price := nvl(p_pricing_value,0) / (case nvl(p_qty,0) when 0 then 1 else p_qty end);
  ELSE
    ln_unit_price := nvl(p_unit_price,0);
  END IF;

  RETURN ln_unit_price;
END GetUnitPriceByPriceSrcType;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : GetIfacQtyPrice
-- Description    :  Returns the unit price found in the quantity interface for the given transaction.
--                   Returns null if no price is found.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetIfacQtyPrice(p_transaction_key VARCHAR2)
RETURN NUMBER
IS

  lrec_d cont_document%rowtype;
  lrec_t cont_transaction%ROWTYPE;
  lrec_tq cont_transaction_qty%ROWTYPE;
  ln_unit_price NUMBER;

BEGIN

  lrec_t := ec_cont_transaction.row_by_pk(p_transaction_key);
  lrec_tq := ec_cont_transaction_qty.row_by_pk(p_transaction_key);
  lrec_d := ec_cont_document.row_by_pk(lrec_t.document_key);

  IF lrec_t.transaction_scope = 'PERIOD_BASED' THEN
    -- PERIOD_BASED
    FOR v IN gc_IfacQtyPrice(lrec_t.object_id,
                             lrec_d.processing_period,
                             lrec_t.supply_from_date,
                             lrec_t.supply_to_date,
                             lrec_t.price_concept_code,
                             lrec_t.delivery_point_id,
                             lrec_t.product_id,
                             lrec_d.customer_id,
                             lrec_t.qty_type,
                             lrec_tq.uom1_code,
                             lrec_t.price_object_id,
                             lrec_t.ifac_unique_key_1,
                             lrec_t.ifac_unique_key_2,
                             lrec_t.ifac_tt_conn_code) LOOP

      ln_unit_price := GetUnitPriceByPriceSrcType(p_transaction_key, v.qty1, v.unit_price, v.pricing_value);
      EXIT;
    END LOOP;
  ELSE
    -- CARGO_BASED
    FOR v IN gc_IfacCargoPrice(lrec_t.object_id,
                               lrec_t.cargo_name,
                               lrec_t.parcel_name,
                               lrec_t.qty_type,
                               lrec_t.price_object_id,
                               lrec_t.price_concept_code,
                               lrec_t.product_id,
                               lrec_d.customer_id,
                               lrec_tq.uom1_code,
                               lrec_t.ifac_tt_conn_code) LOOP

      ln_unit_price := GetUnitPriceByPriceSrcType(p_transaction_key, v.net_qty1, v.unit_price, v.pricing_value);
      EXIT;
    END LOOP;
  END IF;

  RETURN ln_unit_price;

END GetIfacQtyPrice;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : GetIfacFreeUnitPrice
-- Description    :  Returns the unit price found in the free unit interface for the given transaction.
--                   Returns null if no price is found.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetIfacOliPrice(p_transaction_key      VARCHAR2,
                         p_line_item_based_type VARCHAR2 DEFAULT NULL,
                         p_line_item_type       VARCHAR2 DEFAULT NULL,
                         p_ifac_li_conn_code    VARCHAR2 DEFAULT NULL)
RETURN NUMBER
IS

  lrec_d cont_document%rowtype;
  lrec_t cont_transaction%ROWTYPE;
  lrec_tq cont_transaction_qty%ROWTYPE;
  ln_unit_price NUMBER;

BEGIN

  lrec_t := ec_cont_transaction.row_by_pk(p_transaction_key);
  lrec_tq := ec_cont_transaction_qty.row_by_pk(p_transaction_key);
  lrec_d := ec_cont_document.row_by_pk(lrec_t.document_key);

  IF lrec_t.transaction_scope = 'PERIOD_BASED' THEN
    -- PERIOD_BASED
    FOR v IN gc_IfacQtyPriceOli(lrec_t.object_id,
                                trunc(lrec_t.transaction_date,'MM'),
                                lrec_t.supply_from_date,
                                lrec_t.supply_to_date,
                                lrec_t.price_concept_code,
                                lrec_t.delivery_point_id,
                                lrec_t.product_id,
                                lrec_d.customer_id,
                                lrec_t.qty_type,
                                lrec_tq.uom1_code,
                                lrec_t.price_object_id,
                                lrec_t.ifac_unique_key_1,
                                lrec_t.ifac_unique_key_2,
                                lrec_t.ifac_tt_conn_code,
                                p_line_item_based_type,
                                p_line_item_type,
                                p_ifac_li_conn_code) LOOP

      ln_unit_price := GetUnitPriceByPriceSrcType(p_transaction_key, v.qty1, v.unit_price, v.pricing_value);
      EXIT;
    END LOOP;
  ELSE
    -- CARGO_BASED
    FOR v IN gc_IfacCargoPriceOli(lrec_t.object_id,
                                  lrec_t.cargo_name,
                                  lrec_t.parcel_name,
                                  lrec_t.qty_type,
                                  lrec_t.price_object_id,
                                  lrec_t.price_concept_code,
                                  lrec_t.product_id,
                                  lrec_d.customer_id,
                                  lrec_tq.uom1_code,
                                  lrec_t.ifac_tt_conn_code,
                                  p_line_item_based_type,
                                  p_line_item_type,
                                  p_ifac_li_conn_code) LOOP

      ln_unit_price := GetUnitPriceByPriceSrcType(p_transaction_key, v.net_qty1, v.unit_price, v.pricing_value);
      EXIT;
    END LOOP;
  END IF;

  RETURN ln_unit_price;

END GetIfacOliPrice;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isTransSourceSplitShareUpdated
-- Description    : Function to return whether the source split of a document is updated or not (Y or N)
--
-- Preconditions  : Transaction key must be provided.
-- Postconditions :
--
-- Using tables   : cont_line_item_dist
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION isTransSourceSplitShareUpdated(p_transaction_key VARCHAR2)
  RETURN VARCHAR2
--</EC-DOC>
IS

  CURSOR sis_source(pc_transaction_key VARCHAR2) IS
    SELECT --distinct
     clid.stream_item_id split_member_id,
     clid.alloc_stream_item_id source_member_id,
     clid.split_share -- share to compare with
      FROM cont_line_item_dist clid
     WHERE clid.transaction_key = pc_transaction_key;

  CURSOR res_sis(pc_transaction_key VARCHAR2) IS
    SELECT distinct clid.alloc_stream_item_id source_member_id
      FROM cont_line_item_dist clid
     WHERE clid.transaction_key = pc_transaction_key;

  ln_sum              NUMBER;
  ln_share            NUMBER;
  lv2_alloc_object_id VARCHAR2(32);
  lrec_trans          CONT_TRANSACTION%ROWTYPE := ec_cont_transaction.row_by_pk(p_transaction_key);
  lrec_tran_qty       CONT_TRANSACTION_QTY%ROWTYPE := ec_cont_transaction_qty.row_by_pk(p_transaction_key);
  lv2_uom_2           VARCHAR2(32);
  lv2_master_group    VARCHAR2(32);

BEGIN

  -- Moved to cursor
  IF (lrec_trans.split_method <> 'SOURCE_SPLIT') THEN
    RETURN 'N';
  END IF;

  IF (lrec_trans.transaction_date IS NULL) THEN
    RETURN 'N';
  END IF;

  ln_sum := 0;
  -- First loop through all allocation basis SIs and find the Total Sum in the specified UOM
  FOR Sis IN res_sis(p_transaction_key) LOOP
    IF (Sis.source_member_id IS NULL) THEN
      RETURN 'N';
    END IF;

    IF lv2_uom_2 IS NULL THEN
      IF (NVL(lrec_tran_qty.net_qty1,0) = 0 AND NVL(LENGTH(lrec_tran_qty.uom1_code),0) = 0) OR (lrec_trans.SOURCE_SPLIT_METHOD = 'MASTER_UOM') THEN
        lv2_master_group := ec_stream_item_version.master_uom_group(Sis.source_member_id, TRUNC(ec_cont_transaction.transaction_date(p_transaction_key),'MM'),'<=');
        IF lv2_master_group = 'M' THEN
          lv2_uom_2 :=   ec_stream_item_version.default_uom_mass(Sis.source_member_id, TRUNC(ec_cont_transaction.transaction_date(p_transaction_key),'MM'),'<=');
        ELSIF lv2_master_group =  'V' THEN
          lv2_uom_2 :=   ec_stream_item_version.default_uom_volume(Sis.source_member_id, TRUNC(ec_cont_transaction.transaction_date(p_transaction_key),'MM'),'<=');
        ELSIF lv2_master_group =  'E' THEN
          lv2_uom_2 :=   ec_stream_item_version.default_uom_energy(Sis.source_member_id, TRUNC(ec_cont_transaction.transaction_date(p_transaction_key),'MM'),'<=');
        END IF;
      ELSE
        lv2_uom_2 := lrec_tran_qty.uom1_code;
      END IF;
    END IF;

    ln_sum := ln_sum + NVL(Ecdp_Stream_Item.GetMthQtyByUOM(Sis.source_member_id, lv2_uom_2, TRUNC(ec_cont_transaction.transaction_date(p_transaction_key),'MM')), 0);

  END LOOP;

  -- Loop through again to calculate the share and the value in the specified UOM
  FOR SisCalc IN sis_source(p_transaction_key) LOOP
    -- Find the Allocation Basis SI object_id
    lv2_alloc_object_id := SisCalc.source_member_id;

    -- Calculate the share
    IF (ln_sum <> 0) THEN
      ln_share := NVL(Ecdp_Stream_Item.GetMthQtyByUOM(lv2_alloc_object_id, lv2_uom_2, TRUNC(ec_cont_transaction.transaction_date(p_transaction_key),'MM')), 0) / ln_sum;
    ELSE
      ln_share := 0;
    END IF;

    IF nvl(SisCalc.Split_Share, 0) <> ln_share THEN
      RETURN 'Y';
    END IF;

  END LOOP;

  RETURN 'N';

END isTransSourceSplitShareUpdated;

-- Used to set the country reference to the delivery port or discharge port
-- when creating new objects in popups in the period/cargo document screens.
PROCEDURE SetPointPortCountry(
   p_object_id VARCHAR2, -- Delivery Point or Discharge Port object
   p_daytime DATE,
   p_class_name VARCHAR2, -- DELIVERY_POINT or PORT
   p_country_id VARCHAR2) -- Country relation to set on the object above
IS

BEGIN

  IF p_class_name = 'DELIVERY_POINT' THEN

    UPDATE delpnt_version SET
       country_id = p_country_id
     WHERE object_id = p_object_id
       AND daytime <= p_daytime
       AND nvl(end_date, p_daytime + 1) > p_daytime
       AND country_id IS NULL;

  ELSIF p_class_name = 'PORT' THEN

    UPDATE port_version SET
       country_id = p_country_id
     WHERE object_id = p_object_id
       AND daytime <= p_daytime
       AND nvl(end_date, p_daytime + 1) > p_daytime
       AND country_id IS NULL;

  END IF;

END SetPointPortCountry;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : UpdateManualPriceValue
-- Description    : This procedure is called from FIN_PERIOD_DOC_TRANS and FIN_CARGO_DOC_TRANS classes as a AFTER UPDATE statement
--                  to store the edited pricing value to line item level.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : cont_line_item
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE UpdateManualPriceValue(
          p_transaction_key VARCHAR2,
          p_daytime VARCHAR2,
          p_price_value NUMBER)
--</EC-DOC>
IS

  lv2_user VARCHAR2(32) := ecdp_context.getAppUser;

BEGIN

     UPDATE cont_line_item cli
            SET cli.pricing_value = p_price_value
      WHERE cli.transaction_key = p_transaction_key
        AND cli.line_item_based_type = 'QTY';

     FillTransactionPrice(p_transaction_key, p_daytime, lv2_user);

END UpdateManualPriceValue;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetQtyLICount
-- Description    : This function is used from the transaction level query in Period/Cargo Document screens to make
--                  sure that the transaction level is  only displayed if there are more than one QTY line item.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : cont_line_item
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION GetQtyLICount(
         p_transaction_key VARCHAR2
) RETURN NUMBER
IS

  CURSOR c_count(cp_transaction_key VARCHAR2) IS
    SELECT COUNT(*) num
      FROM cont_line_item cli
     WHERE cli.transaction_key = cp_transaction_key
       AND cli.line_item_based_type = 'QTY';

  ln_count NUMBER := NULL;

BEGIN

   FOR rsC IN c_count(p_transaction_key) LOOP
       ln_count := rsC.Num;
   END LOOP;

   RETURN ln_count;

END GetQtyLICount;





--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : IsReducedConfig
-- Description    : Returns true if transaction is set up with no price object
--
--
-- Preconditions  : One of the parameters must be set
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION IsReducedConfig(p_contract_id     VARCHAR2,
                         p_contract_doc_id VARCHAR2,
                         p_trans_temp_id   VARCHAR2,
                         p_transaction_key VARCHAR2,
                         p_daytime         DATE,
                         p_dist_only       BOOLEAN DEFAULT FALSE
  )
RETURN BOOLEAN
--</EC-DOC>
IS

lrec_ttv transaction_tmpl_version%ROWTYPE  := ec_transaction_tmpl_version.row_by_pk(p_trans_temp_id, p_daytime, '<=');
lrec_ct  cont_transaction%ROWTYPE          := ec_cont_transaction.row_by_pk(p_transaction_key);

lb_ret_val BOOLEAN := TRUE;
ln_distribution_count NUMBER;

  CURSOR c_cdv IS
    SELECT cd.object_id
      FROM contract_doc cd, contract_doc_version cdv
     WHERE cdv.object_id = cd.object_id
       AND cdv.daytime <= p_daytime
       AND nvl(cdv.end_date, p_daytime + 1) > p_daytime
       AND cd.contract_id = p_contract_id;

  CURSOR c_ttv IS
    SELECT tt.object_id
      FROM transaction_template tt, transaction_tmpl_version ttv
     WHERE ttv.object_id = tt.object_id
       AND ttv.daytime <= p_daytime
       AND nvl(ttv.end_date, p_daytime + 1) > p_daytime
       AND tt.contract_doc_id = p_contract_doc_id;

  CURSOR c_count(cp_split_key_id VARCHAR2) IS
  SELECT COUNT(s.split_member_id) split_count
    FROM split_key_setup s
   WHERE s.object_id = cp_split_key_id;

BEGIN

  -- Start with lowest level
  IF p_transaction_key IS NOT NULL OR p_trans_temp_id IS NOT NULL THEN

    IF lrec_ttv.object_id IS NULL THEN
      lrec_ttv := ec_transaction_tmpl_version.row_by_pk(lrec_ct.trans_template_id, p_daytime, '<=');
    END IF;


    FOR rsC IN c_count(lrec_ttv.split_key_id) LOOP
      ln_distribution_count := rsC.split_count;
    END LOOP;

    -- Will return FALSE if either distibution is found or price object has been set.
    lb_ret_val := (ln_distribution_count = 0) OR (lrec_ttv.price_object_id IS NULL and p_dist_only = false);

  -- transaction or trans template was not set, try with doc setup
  ELSIF p_contract_doc_id IS NOT NULL THEN

    -- If one or more Transaction Templates are reduced in config, then the doc setup is considered reduced config
    FOR rsTTV IN c_ttv LOOP

      -- Run recusively with TRANSACTION_TEMPLATE level
      lb_ret_val := IsReducedConfig(NULL, NULL, rsTTV.object_id, NULL, p_daytime, p_dist_only);

      EXIT WHEN lb_ret_val;

    END LOOP;

  -- doc setup was not set either, try with contract
  ELSIF p_contract_id IS NOT NULL THEN

    FOR rsCDV IN c_cdv LOOP

      -- Run recusively with CONTRACT_DOC level
      lb_ret_val := IsReducedConfig(NULL, rsCDV.object_id, NULL, NULL, p_daytime, p_dist_only);

      EXIT WHEN lb_ret_val;

    END LOOP;
  END IF;

  RETURN lb_ret_val;

END IsReducedConfig;


FUNCTION IsReducedConfig(p_contract_id     VARCHAR2,
                         p_contract_doc_id VARCHAR2,
                         p_trans_temp_id   VARCHAR2,
                         p_daytime         DATE,
                         p_dist_only       BOOLEAN DEFAULT FALSE
  ) RETURN VARCHAR2
IS
  lv2_ret_val VARCHAR2(1) := 'N';
BEGIN

  IF IsReducedConfig(p_contract_id, p_contract_doc_id, p_trans_temp_id, NULL, p_daytime, p_dist_only) THEN
    lv2_ret_val := 'Y';
  END IF;

  RETURN lv2_ret_val;
END IsReducedConfig;


------------------------+-----------------------------------+------------------------------------+---------------------------
-- Apply field and company distribution to transaction whose price object was updated from BF.
--
-- p_transaction_key: the transaction key.
-- p_user_id: the user id.
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE UpdPriceObject(p_transaction_key VARCHAR2, p_user_id VARCHAR2)
IS
    lrec_cont_trans cont_transaction%ROWTYPE := ec_cont_transaction.row_by_pk(p_transaction_key);
BEGIN
    apply_po_on_trans_rc_p(p_transaction_key, lrec_cont_trans.price_object_id, p_user_id);
END UpdPriceObject;
------------------------+-----------------------------------+------------------------------------+---------------------------
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : isPreceding
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      : Run after saved changes on price object from pdg/cdg.
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION isPreceding(p_transaction_key VARCHAR2, p_document_key VARCHAR2 DEFAULT NULL) RETURN BOOLEAN
--<EC-DOC>
IS

lb_result BOOLEAN := FALSE;

  -- Get all documents having this document as preceding
  CURSOR c_preceding(cp_transaction_key VARCHAR2,cp_document_key VARCHAR2) IS
    SELECT 1
      FROM cont_transaction t
     WHERE t.preceding_trans_key = cp_transaction_key
     AND t.document_key = nvl(cp_document_key,t.document_key)
     and t.document_key NOT IN
     (SELECT dd.preceding_document_key --- Exclude if dependent exists
              FROM cont_document dd
             WHERE dd.document_key NOT IN
                   (SELECT ddd.preceding_document_key -- ... which is not reversed
                      FROM cont_document ddd
                     WHERE ddd.reversal_ind = 'Y'
                       AND nvl(ddd.document_level_code, 'OPEN') = 'BOOKED'));

BEGIN

  FOR R IN c_preceding(p_transaction_key,p_document_key) LOOP

      lb_result := TRUE;
      EXIT;

  END LOOP;

  RETURN lb_result;

END isPreceding;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : Simple getDependentTransaction that does not consider document that transaction belongs to (document level code etc.)
-- Description    : Return the dependent transaction key
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION getDependentTransaction(p_transaction_key VARCHAR2) RETURN VARCHAR2
--<EC-DOC>
IS

lv2_result VARCHAR2(32);

  -- Get all documents having this document as preceding
  CURSOR c_preceding(cp_transaction_key VARCHAR2) IS
    SELECT t.transaction_key
      FROM cont_transaction t
     WHERE t.preceding_trans_key = cp_transaction_key;


BEGIN

  FOR R IN c_preceding(p_transaction_key) LOOP

      lv2_result := R.TRANSACTION_KEY;
      EXIT;

  END LOOP;

  RETURN lv2_result;

END getDependentTransaction;


---------------------------------------------------------------------------------------------------
-- Procedure      : Checks to see that VAT has been set when the UNDEFINED VAT was used on the template
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE ValidateDocVAT (
    p_document_key VARCHAR2,
    p_val_msg OUT VARCHAR2,
    p_val_code OUT VARCHAR2,
    p_silent_ind VARCHAR2 -- if 'N': Raise exeptions, if 'Y': continue and return code/msg
)
IS

  CURSOR c_trans IS
  SELECT t.*,
         ec_vat_code.object_id_by_uk(t.vat_code) vat_id
    FROM cont_transaction t
   WHERE t.document_key = p_document_key;

  CURSOR c_line_item(cp_transaction_key VARCHAR2) IS
  SELECT transaction_key,
         line_item_key id,
         vat_code,
         ec_vat_code.object_id_by_uk(vat_code) vat_id
    FROM cont_line_item
   WHERE transaction_key = cp_transaction_key;

  CURSOR c_party(cp_document_key VARCHAR2, cp_daytime DATE, cp_fin_code VARCHAR2) IS
  SELECT cdc.company_role,
         cdc.company_id,
         cve.name company_name,
         cve.country_id,
         ec_geogr_area_version.name(cve.country_id, cp_daytime, '<=') country_name
    FROM cont_document_company cdc, company_version cve
   WHERE cdc.company_id = cve.object_id
     AND cdc.document_key= cp_document_key
     AND cve.daytime <= cp_daytime
     AND NVL(cve.end_date, cp_daytime + 1) > cp_daytime
     AND cdc.company_role = CASE WHEN cp_fin_code IN ('PURCHASE','TA_COST') THEN 'VENDOR'
                               WHEN cp_fin_code IN ('SALE','TA_INCOME') THEN 'CUSTOMER' END;

  CURSOR c_vat_cc_setup(cp_vat_code_id VARCHAR2, cp_daytime DATE) IS
  SELECT vccs.object_id vat_code_id,
         vccs.country_id,
         vccs.setup_type,
         vccs.daytime
    FROM vat_code_country_setup vccs
   WHERE vccs.object_id = cp_vat_code_id
     AND vccs.daytime = (SELECT max(vccs2.daytime)
                           FROM vat_code_country_setup vccs2
                          WHERE vccs2.object_id = vccs.object_id
                            AND vccs2.country_id = vccs.country_id
                            AND vccs2.setup_type = vccs.setup_type
                            AND vccs2.daytime <= cp_daytime);

  lrec_vat_code               vat_code_version%ROWTYPE;
  lrec_document               cont_document%ROWTYPE := ec_cont_document.row_by_pk(p_document_key);
  lrec_contract               contract_version%ROWTYPE := ec_contract_version.row_by_pk(lrec_document.object_id, lrec_document.daytime, '<=');
  lrec_company                company_version%ROWTYPE := ec_company_version.row_by_pk(lrec_contract.company_id, lrec_document.daytime, '<=');
  lv2_vat_country_name        geogr_area_version.name%TYPE;
  lv2_comp_country_name       geogr_area_version.name%TYPE;
  lv2_setup_type              vat_code_country_setup.setup_type%TYPE;
  lv2_any_country_id          geographical_area.object_id%TYPE := ec_geographical_area.object_id_by_uk('COUNTRY','ANY');
  la_cont_comp                gt_ArrTable := gt_ArrTable();
  lb_destination_country_pass BOOLEAN;
  lb_origin_country_pass      BOOLEAN;
  lb_vendor_country_pass      BOOLEAN;
  lb_customer_country_pass    BOOLEAN;

  lv2_orig_country_at_trans   VARCHAR2(1) := ec_ctrl_system_attribute.attribute_text(Ecdp_Timestamp.getCurrentSysdate(), 'ORIG_COUNTRY_AT_TRANS', '<=');
  lv2_dest_country_at_trans   VARCHAR2(1) := ec_ctrl_system_attribute.attribute_text(Ecdp_Timestamp.getCurrentSysdate(), 'DEST_COUNTRY_AT_TRANS', '<=');
  error EXCEPTION;

BEGIN

  p_val_msg := NULL;

  IF ue_cont_transaction.isValidateDocVATUEE = 'TRUE' THEN -- Instead-of UE
    ue_cont_transaction.ValidateDocVAT(p_document_key);

  ELSE

    IF ue_cont_transaction.isValidateDocVATPreUEE = 'TRUE' THEN -- Pre UE
      ue_cont_transaction.ValidateDocVATPre(p_document_key);
    END IF;

    --Temp table containing the contract parties.
    FOR party IN c_party(p_document_key, lrec_document.document_date, lrec_contract.financial_code) LOOP

      IF party.country_id IS NULL THEN
        p_val_msg := party.company_role || ' is missing country for ' || party.country_name;
        p_val_code := party.company_role || '_COUNTRY_MISSING';
        RAISE error;
      END IF;

      la_cont_comp.EXTEND;
      la_cont_comp(la_cont_comp.LAST).str1 := party.company_role;
      la_cont_comp(la_cont_comp.LAST).str2 := party.company_id;
      la_cont_comp(la_cont_comp.LAST).str3 := party.country_id;
      la_cont_comp(la_cont_comp.LAST).str4 := party.company_name;
      la_cont_comp(la_cont_comp.LAST).str5 := party.country_name;
    END LOOP;
    IF lrec_company.country_id is NULL THEN
      p_val_msg := 'Country of the Contract Owner Company (' || lrec_company.name || ') has not been set.';
      p_val_code := 'CONT_COMP_COUNTRY_MISSING';
      RAISE error;
    END IF;


    -- Iterate through Transactions and Transaction Line Items
    FOR Trans IN c_trans LOOP
      FOR TransLi IN c_Line_Item(Trans.transaction_key) LOOP
        IF (TransLi.Vat_Code IS NULL OR TransLi.Vat_Code = 'UNDEFINED') AND
           (Trans.Vat_Code IS NULL OR Trans.Vat_Code = 'UNDEFINED') THEN
          p_val_msg := 'Missing VAT Code for "' || Trans.transaction_key ||'-'|| TransLi.Id || '". Please select a valid VAT Code on the Line Item.';
          p_val_code := 'T_LI_MISSING_VAT_CODE';
          RAISE error;
        ELSE
          lrec_vat_code := ec_vat_code_version.row_by_pk(nvl(TransLi.vat_id,Trans.vat_id),Trans.daytime,'<=');

          IF lrec_vat_code.country_validation_ind = 'Y' AND (lrec_vat_code.country_id != lv2_any_country_id) THEN
            lv2_vat_country_name := ec_geogr_area_version.name(lrec_vat_code.country_id, Trans.daytime,'<=');
            lv2_comp_country_name := ec_geogr_area_version.name(lrec_company.country_id, Trans.daytime,'<=');

            IF lrec_company.country_id != lrec_vat_code.country_id AND lrec_vat_code.country_id != lv2_any_country_id THEN
              p_val_msg := 'Country of the Contract Owner Company (' || lrec_company.name || '/' || lv2_comp_country_name || ') does not match the Country of the VAT object (' || lrec_vat_code.name || '/' || lv2_vat_country_name || ').';
              p_val_code := 'CONT_COMP_CTRY_NOMATCH_VAT_CTRY';
              RAISE error;
            END IF;

            IF lv2_orig_country_at_trans = 'Y' AND Trans.origin_Country_id IS NULL THEN
              IF ue_cont_transaction.isGetOrigCountryForTransUEE = 'TRUE' THEN
                p_val_msg := 'The Transaction(' || Trans.transaction_key || ')''s Origin Country might be set using the USER EXIT';
                p_val_code := 'TRANS_MISSING_ORIG_COUNTRY_UE';
                RAISE error;
              ELSE
                p_val_msg := 'The Transaction(' || Trans.transaction_key || ')''s Origin Country is empty and is needed since the System Attribute ''ORIG_COUNTRY_AT_TRANS'' is set to ''Y''.';
                p_val_code := 'TRANS_MISSING_ORIG_COUNTRY';
                RAISE error;
              END IF;
            END IF;

            IF lv2_dest_country_at_trans = 'Y' AND Trans.destination_Country_id IS NULL THEN
              IF ue_cont_transaction.isGetDestCountryForTransUEE = 'TRUE' THEN
                p_val_msg := 'The Transaction(' || Trans.transaction_key || ')''s Destination Country might be set using the USER EXIT';
                p_val_code := 'TRANS_MISSING_DEST_COUNTRY_UE';
                RAISE error;
              ELSE
                p_val_msg := 'The Transaction(' || Trans.transaction_key || ')''s Destination Country is empty and is needed since the System Attribute ''DEST_COUNTRY_AT_TRANS'' is set to ''Y''.';
                p_val_code := 'TRANS_MISSING_DEST_COUNTRY';
                RAISE error;
              END IF;
            END IF;

            --Check for Origin country
            --Check for Destination country
            --Check for Vendor and Customer country
            lb_destination_country_pass := false;
            lb_origin_country_pass := false;
            lb_customer_country_pass := false;
            lb_vendor_country_pass := false;

            --Iterate through ever VAT_CODE_COUNTRY_SETUP and check agains every CUSTOMER/VENDOR and TRANSACTION.Destination_COUNTRY and ORIGIN_COUNTRY
            FOR vccs IN c_vat_cc_setup(lrec_vat_code.object_id, Trans.Daytime) LOOP

              IF vccs.setup_type IN ('CUSTOMER_COUNTRY', 'VENDOR_COUNTRY') THEN
                FOR i IN 1..la_cont_comp.COUNT LOOP
                  --Get Vendor or Customer
                  IF la_cont_comp(i).str1 = 'VENDOR' AND vccs.setup_type = 'VENDOR_COUNTRY' THEN
                    lb_customer_country_pass := TRUE;

                    IF lv2_any_country_id = vccs.country_id
                      OR la_cont_comp(i).str3 = vccs.country_id THEN
                      lb_vendor_country_pass := true;
                    END IF;

                  ELSIF la_cont_comp(i).str1 = 'CUSTOMER' AND vccs.setup_type = 'CUSTOMER_COUNTRY' THEN
                    lb_vendor_country_pass := TRUE;
                    IF lv2_any_country_id = vccs.country_id
                      OR la_cont_comp(i).str3 = vccs.country_id THEN
                      lb_customer_country_pass := true;
                    END IF;

                  END IF;
                END LOOP;
              END IF;

              IF vccs.setup_type = 'DESTINATION_COUNTRY' THEN
                IF vccs.country_id = lv2_any_country_id
                  OR trans.destination_country_id  = vccs.country_id THEN
                  lb_destination_country_pass := true;
                END IF;
              END IF;

              IF vccs.setup_type = 'ORIGIN_COUNTRY' THEN
                IF vccs.country_id = lv2_any_country_id
                  OR trans.origin_Country_id = vccs.country_id THEN
                  lb_origin_country_pass := true;
                END IF;
              END IF;
            END LOOP;--Iterate through ever VAT_CODE_COUNTRY_SETUP and check agains every CUSTOMER/VENDOR and TRANSACTION.Destination_COUNTRY And ORIGIN_COUNTRY


            -- CHECK IF ANY COUNTRY
            IF trans.destination_country_id = lrec_vat_code.country_id
              OR trans.destination_country_id = lv2_any_country_id
              OR lv2_dest_country_at_trans = 'N' THEN
              lb_destination_country_pass := true;
            END IF;

            IF trans.origin_country_id = lrec_vat_code.country_id
              OR trans.origin_country_id = lv2_any_country_id
              OR lv2_orig_country_at_trans = 'N' THEN
              lb_origin_country_pass := true;
            END IF;

            -- LOOP CHECK FOR ANY COUNTRY
            FOR i IN 1..la_cont_comp.COUNT LOOP
              --Get Vendor or Customer
              IF la_cont_comp(i).str1 = 'VENDOR' THEN
                lb_customer_country_pass := TRUE;
                IF la_cont_comp(i).str3 = lv2_any_country_id
                  OR la_cont_comp(i).str3 = lrec_vat_code.country_id THEN
                  lb_vendor_country_pass := TRUE;
                END IF;

              ELSIF la_cont_comp(i).str1 = 'CUSTOMER' THEN
                lb_vendor_country_pass := TRUE;
                IF la_cont_comp(i).str3 = lv2_any_country_id
                  OR la_cont_comp(i).str3 = lrec_vat_code.country_id THEN
                  lb_customer_country_pass := TRUE;
                END IF;

              END IF;
            END LOOP;-- LOOP CHECK FOR ANY COUNTRY

            IF NOT lb_vendor_country_pass THEN
              p_val_msg := 'No valid Vendor Country in Vat Code Setup for Transaction ' || Trans.transaction_key ||'.';
              p_val_code := 'NO_VALID_VENDOR_VCCS';
              RAISE error;
            END IF;

            IF NOT lb_customer_country_pass THEN
              p_val_msg := 'No valid Customer Country in Vat Code Setup for Transaction ' || Trans.transaction_key ||'.';
              p_val_code := 'NO_VALID_CUSTOMER_VCCS';
              RAISE error;
            END IF;

            IF NOT lb_destination_country_pass THEN
              p_val_msg := 'Missing Destination Country in Vat Code Setup for Transaction ' || Trans.transaction_key ||'.';
              p_val_code := 'NO_VALID_DESTINATION_CNTY_VCCS';
              RAISE error;
            END IF;

            IF NOT lb_origin_country_pass THEN
              p_val_msg := 'Missing Origin Country in Vat Code Setup for Transaction ' || Trans.transaction_key ||'.';
              p_val_code := 'NO_VALID_ORIGIN_CNTY_VCCS';
              RAISE error;
            END IF;

          END IF;
        END IF;
      END LOOP;
    END LOOP;

    IF ue_cont_transaction.isValidateDocVATPostUEE = 'TRUE' THEN -- Post UE
      ue_cont_transaction.ValidateDocVATPost(p_document_key);
    END IF;

  END IF;

EXCEPTION
    WHEN error THEN
      IF p_silent_ind = 'N' THEN
        RAISE_APPLICATION_ERROR(-20000, p_val_msg);
      END IF;
END ValidateDocVAT;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetTransSortOrder
-- Description    : Gets the Sort Order for a transaciton in a document.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION GetTransSortOrder(p_transaction CONT_TRANSACTION%ROWTYPE, p_recalculate_sort_order BOOLEAN DEFAULT TRUE)
RETURN NUMBER
--<EC-DOC>
IS
    ln_sort_order NUMBER;

BEGIN
    IF ue_cont_transaction.isGetTransSortOrderUEE = 'TRUE' THEN
        ln_sort_order := ue_cont_transaction.GetTransSortOrder(p_transaction);

    ELSE
        ln_sort_order := 0;

        IF ue_cont_transaction.isGetTransSortOrderPreUEE = 'TRUE' THEN
            ln_sort_order := NVL(ue_cont_transaction.GetTransSortOrderPre(p_transaction), 0);
        END IF;

        IF p_recalculate_sort_order THEN
            -- Recalculate the sort order if needed
            FOR cr_trans IN gc_all_sorted_transactions(p_transaction.document_key) LOOP
                ln_sort_order := ln_sort_order + 1;

                IF p_transaction.transaction_key = cr_trans.transaction_key THEN
                    ln_sort_order := ln_sort_order * 100;
                    EXIT;

                END IF;

            END LOOP;

            IF ln_sort_order = 0 THEN
                ln_sort_order := 100;
            END IF;

        ELSE
            -- Use the sort order on input record if no recalculation required
            ln_sort_order := p_transaction.sort_order;
        END IF;

        IF ue_cont_transaction.isGetTransSortOrderPostUEE = 'TRUE' THEN
            ln_sort_order := ue_cont_transaction.GetTransSortOrderPost(p_transaction, ln_sort_order);
        END IF;

    END IF; -- Instead-Of user exit

    RETURN ln_sort_order;

END GetTransSortOrder;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : SetTransSortOrder
-- Description    : Sets the Sort Order for the given transaciton.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
PROCEDURE SetTransSortOrder(p_transaction CONT_TRANSACTION%ROWTYPE, p_recalculate_sort_order BOOLEAN, p_user VARCHAR2)
--<EC-DOC>
IS
  ln_trans_sort_order NUMBER := 0;
BEGIN
  IF ue_cont_transaction.isSetTransSortOrderUEE = 'TRUE' THEN
    ue_cont_transaction.SetTransSortOrder(p_transaction, p_recalculate_sort_order, p_user);

  ELSE
    IF ue_cont_transaction.isSetTransSortOrderPreUEE = 'TRUE' THEN
      ue_cont_transaction.SetTransSortOrderPre(p_transaction, p_recalculate_sort_order, p_user);
    END IF;

    ln_trans_sort_order := nvl(GetTransSortOrder(p_transaction, p_recalculate_sort_order), 100);

    UPDATE cont_transaction t
      SET t.sort_order = ln_trans_sort_order,
          t.last_updated_by = p_user,
          t.last_updated_date = Ecdp_Timestamp.getCurrentSysdate
    WHERE t.transaction_key = p_transaction.transaction_key;

    IF ue_cont_transaction.isSetTransSortOrderPostUEE = 'TRUE' THEN
      ue_cont_transaction.SetTransSortOrderPost(p_transaction, p_recalculate_sort_order, p_user, ln_trans_sort_order);
    END IF;

  END IF;
END SetTransSortOrder;



--<EC-DOC>
-------------------------------------------------------------------------------------------------------------------------------------------
-- Procedure      : SetAllTransSortOrder
-- Description    : Resorts the document's transactions. Allows having many transactions with the same transaction template
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE SetAllTransSortOrder(p_document_key VARCHAR2)
--<EC-DOC>
IS

  ln_order_number NUMBER := 0;
  lr_transaction  CONT_TRANSACTION%ROWTYPE;

BEGIN

  IF ue_cont_transaction.isSetAllTransSortOrderUEE = 'TRUE' THEN

    ue_cont_transaction.SetAllTransSortOrder(p_document_key);

  ELSE

    FOR cr_trans IN gc_all_sorted_transactions(p_document_key) LOOP

      ln_order_number := ln_order_number + 1;

      lr_transaction := ec_cont_transaction.row_by_pk(cr_trans.transaction_key);
      lr_transaction.sort_order := ln_order_number * 100;

      SetTransSortOrder(lr_transaction, FALSE, ecdp_context.getAppUser);

    END LOOP;

  END IF;

END SetAllTransSortOrder;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : HasReversedDependentTrans
-- Description    : Returns Y if a dependent transaction can be created based on the current transaction.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION HasReversedDependentTrans(p_transaction_key VARCHAR2)
RETURN VARCHAR2
--<EC-DOC>
IS

CURSOR c_RevTrans IS

SELECT DECODE((SELECT COUNT(pt.preceding_trans_key) + COUNT(pt.transaction_key)
                 FROM cont_transaction pt, cont_document pd
                WHERE pt.document_key = pd.document_key
                  AND pt.reversal_ind = 'Y'
                  AND nvl(pd.document_level_code, 'OPEN') = 'BOOKED'
                  AND (pt.preceding_trans_key = t.transaction_key
                      OR pt.reversed_trans_key = t.transaction_key)),
              0,
              'N',
              'Y') reversed
  FROM cont_transaction t, cont_document d
 WHERE t.document_key = d.document_key
   AND nvl(d.document_level_code, 'OPEN') = 'BOOKED'
   AND t.preceding_trans_key = p_transaction_key
 ORDER BY t.created_date DESC;

  lv2_result VARCHAR2(1) := 'N';

BEGIN

  FOR rsRT IN c_RevTrans LOOP

    lv2_result := rsRT.reversed;
    EXIT;

  END LOOP;

  RETURN lv2_result;

END HasReversedDependentTrans;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getTransactionName
-- Description    : Generates the transaction name according to its values and template configuration.
--                  placeholders in transaction template name are supported. Placeholders should
--                  start with a '$' symbol. Only suportted placeholders will be resolved, or it
--                  will be there as it is as well as the '$'s.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION getTransactionName(
  p_transaction CONT_TRANSACTION%ROWTYPE,
  -- p_daytime DATE,
  p_size_limit NUMBER DEFAULT 240
) RETURN CONT_TRANSACTION.NAME%TYPE
--<EC-DOC>
IS

  lrec_transaction_version TRANSACTION_TMPL_VERSION%ROWTYPE;
  lv_transaction_template_name TRANSACTION_TMPL_VERSION.NAME%TYPE;
  lv_placeholder_value VARCHAR2(240);
  lv_result CONT_TRANSACTION.NAME%TYPE;
BEGIN
  IF ue_cont_transaction.isGetTransNameUEE = 'TRUE' THEN
      -- Call instead-of user exit
      lv_result := ue_cont_transaction.GetTransactionName(p_transaction, p_size_limit);
  ELSE
      IF ue_cont_transaction.isGetTransNamePreUEE = 'TRUE' THEN
          -- Call PRE user exit
          lv_result := ue_cont_transaction.GetTransactionNamePre(p_transaction, p_size_limit);
      END IF;

      -- Find the name format for the transaction
      lrec_transaction_version := ec_transaction_tmpl_version.row_by_pk(p_transaction.TRANS_TEMPLATE_ID, p_transaction.DAYTIME, '<=');
      IF lrec_transaction_version.CONT_TRANS_NAME_FORMAT IS NOT NULL THEN --Do placeholder replacement
        lv_result := lrec_transaction_version.CONT_TRANS_NAME_FORMAT;

        IF (INSTR(lv_result, '$PRODUCT_NAME') > 0 ) THEN
          lv_placeholder_value := resolveNamePlaceholderValue('PRODUCT_NAME', p_transaction);
          lv_result := REPLACE(lv_result, '$PRODUCT_NAME', lv_placeholder_value);
        END IF;

        IF (INSTR(lv_result, '$PRICE_OBJECT_NAME') > 0 ) THEN
          lv_placeholder_value := resolveNamePlaceholderValue('PRICE_OBJECT_NAME', p_transaction);
          lv_result := REPLACE(lv_result, '$PRICE_OBJECT_NAME', lv_placeholder_value);
        END IF;

        IF (INSTR(lv_result, '$DELIVERY_POINT_NAME') > 0 ) THEN
          lv_placeholder_value := resolveNamePlaceholderValue('DELIVERY_POINT_NAME', p_transaction);
          lv_result := REPLACE(lv_result, '$DELIVERY_POINT_NAME', lv_placeholder_value);
        END IF;

        IF (INSTR(lv_result, '$PRICE_CONCEPT') > 0 ) THEN
          lv_placeholder_value := resolveNamePlaceholderValue('PRICE_CONCEPT', p_transaction);
          lv_result := REPLACE(lv_result, '$PRICE_CONCEPT', lv_placeholder_value);
        END IF;

        IF (INSTR(lv_result, '$DISCHARGE_PORT_NAME') > 0 ) THEN
          lv_placeholder_value := resolveNamePlaceholderValue('DISCHARGE_PORT_NAME', p_transaction);
          lv_result := REPLACE(lv_result, '$DISCHARGE_PORT_NAME', lv_placeholder_value);
        END IF;

        IF (INSTR(lv_result, '$QTY_TYPE') > 0 ) THEN
          lv_placeholder_value := resolveNamePlaceholderValue('QTY_TYPE', p_transaction);
          lv_result := REPLACE(lv_result, '$QTY_TYPE', lv_placeholder_value);
        END IF;

      ELSE --No Transaction Name format defined
        lv_result := p_transaction.name;
        IF lv_result = null THEN --use name from Transaction Template
          lv_result := lrec_transaction_version.NAME;
        END IF;
     END IF;
      IF ue_cont_transaction.isGetTransNamePostUEE = 'TRUE' THEN
          -- Call POST user exit
          lv_result := ue_cont_transaction.GetTransactionNamePost(p_transaction, lv_result, p_size_limit);
      END IF;

  END IF; -- Instead-of user exit enabled?

  RETURN lv_result;
END getTransactionName;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : resolveNamePlaceholderValue
-- Description    : Resolves the value of a transaction template placeholder. NULL will be returned
--                  if the placeholder is not supported.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION resolveNamePlaceholderValue(
  p_placeholder_name  VARCHAR2,
  p_transaction CONT_TRANSACTION%ROWTYPE
  --p_daytime DATE
) RETURN VARCHAR2
--<EC-DOC>
IS
  lv_result VARCHAR2(240);
BEGIN
  IF ue_cont_transaction.isResolveTransNamePHUEE = 'TRUE' THEN
      -- Call Instead_of user exit
      lv_result := ue_cont_transaction.ResolveTransNamePH(p_placeholder_name, p_transaction);
  ELSE
      IF UPPER(p_placeholder_name) = 'PRODUCT_NAME' THEN
        -- get the product name
        lv_result := ec_product_version.name(p_transaction.product_id, p_transaction.daytime, '<=');
      ELSIF UPPER(p_placeholder_name) = 'PRICE_OBJECT_NAME' THEN
        -- get the price object name
        lv_result := ec_product_price_version.name(p_transaction.Price_Object_Id, p_transaction.daytime, '<=');
      ELSIF UPPER(p_placeholder_name) = 'DELIVERY_POINT_NAME' THEN
        -- get the delivery point name
        lv_result := ec_delpnt_version.name(p_transaction.Delivery_Point_Id, p_transaction.daytime, '<=');
      ELSIF UPPER(p_placeholder_name) = 'PRICE_CONCEPT' THEN
        -- get the price concept name
        lv_result := ec_price_concept.name(p_transaction.price_concept_code);
      ELSIF UPPER(p_placeholder_name) = 'DISCHARGE_PORT_NAME' THEN
        -- get the discharge port code
        lv_result := ec_port_version.name(p_transaction.DISCHARGE_PORT_ID, p_transaction.daytime, '<=');
      ELSIF UPPER(p_placeholder_name) = 'QTY_TYPE' THEN
        -- get the quantity type
        lv_result := ec_prosty_codes.code_text(p_transaction.QTY_TYPE, 'QTY_TYPE');
      END IF;
  END IF; -- Instead-Of user exit?

  -- return null if the placeholder is not supported
  RETURN lv_result;
END resolveNamePlaceholderValue;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : InitNewTransactionTmplVersion
-- Description    : Init the new transaction template version. Creates new split key versions and
--                  line item template version if needed.
---------------------------------------------------------------------------------------------------
PROCEDURE InitNewTransactionTmplVersion(
    p_user VARCHAR2,
    p_transaction_tmpl_id VARCHAR2,
    p_daytime DATE)
--</EC-DOC>
IS
    CURSOR c_li_template_id(cp_transaction_temp_id VARCHAR2, cp_daytime DATE) IS
        SELECT line_item_template.object_id object_id
              ,line_item_template.object_code code
              ,line_item_tmpl_version.name NAME
        FROM line_item_template, line_item_tmpl_version
        WHERE line_item_template.object_id = line_item_tmpl_version.object_id
            AND line_item_template.transaction_template_id = cp_transaction_temp_id
            AND line_item_tmpl_version.daytime = cp_daytime;


    -- The new transaction template version
    lrec_trans_ver TRANSACTION_TMPL_VERSION%ROWTYPE := ec_transaction_tmpl_version.row_by_pk(p_transaction_tmpl_id, p_daytime, '<=');
    -- The previous transaction template version
    lrec_trans_prev_ver TRANSACTION_TMPL_VERSION%ROWTYPE := ec_transaction_tmpl_version.row_by_pk(p_transaction_tmpl_id, lrec_trans_ver.daytime, '<');
    ld_trans_next_ver DATE := ec_transaction_tmpl_version.next_daytime(p_transaction_tmpl_id, p_daytime, '1');


    tt_not_found EXCEPTION;
BEGIN
    IF lrec_trans_ver.object_id IS NULL THEN
        RAISE tt_not_found;
    END IF;

    Ecdp_Split_Key.InsNewSplitKeyVersionWithChild(
        lrec_trans_ver.split_key_id, p_daytime, lrec_trans_prev_ver.daytime, ld_trans_next_ver, p_user);


    -- Generate new line item versions
    FOR li_t IN c_li_template_id(lrec_trans_ver.object_id, lrec_trans_prev_ver.daytime) LOOP
        ecdp_line_item.InsNewLITemplateForTT(
            lrec_trans_ver.object_id
           ,li_t.object_id
           ,lrec_trans_prev_ver.daytime
           ,lrec_trans_ver.daytime
           ,lrec_trans_ver.end_date
           ,li_t.name
           ,p_user);
    END LOOP;


    /* Inserts Report refrences connected to prev versions to the newly created version */
    InsNewReportRef(p_daytime, p_user,p_transaction_tmpl_id,lrec_trans_prev_ver.object_id ,lrec_trans_prev_ver.daytime);

EXCEPTION
     WHEN tt_not_found THEN
         Raise_Application_Error(-20000,'Transaction template (OBJECT_ID: ''' || p_transaction_tmpl_id || ''') cannot be found.');

END InitNewTransactionTmplVersion;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : InsNewReportRef
-- Description    : Inserts Report refrences connected to prev versions to the newly created version
---------------------------------------------------------------------------------------------------
PROCEDURE InsNewReportRef(p_daytime DATE, p_user VARCHAR2 , p_transaction_tmpl_id VARCHAR2,prev_tt_id VARCHAR2, prev_daytime DATE)
--</EC-DOC>
IS

    CURSOR c_select(prev_tt_id VARCHAR2, prev_daytime DATE) IS
      SELECT ec_report_reference_version.report_reference_tag(rr.report_ref_id,daytime,'<=') ref_tag,
             report_ref_id,
             document_level,
             end_date
        FROM REPORT_REF_CONNECTION rr
       WHERE rr.REPORT_REF_CONN_ID = prev_tt_id
       AND rr.daytime = prev_daytime;

       tt_id_not_provided EXCEPTION;

BEGIN
     IF p_transaction_tmpl_id IS NULL THEN
      RAISE tt_id_not_provided ;
    END IF;
     FOR report_ref_copy IN c_select(prev_tt_id, prev_daytime) LOOP
      -- DATASET --
      INSERT INTO REPORT_REF_CONNECTION
        (REPORT_REF_CONN_ID,
         REPORT_REF_ID,
         DAYTIME,
         END_DATE,
         DOCUMENT_LEVEL,
         CREATED_DATE,
         CREATED_BY)
      VALUES
        (p_transaction_tmpl_id,
         report_ref_copy.report_ref_id,
         p_daytime,
         report_ref_copy.end_date,
         report_ref_copy.document_level,
         Ecdp_Timestamp.getCurrentSysdate,
         p_user
         );
    END LOOP;



     EXCEPTION
    WHEN tt_id_not_provided THEN
      RAISE_APPLICATION_ERROR(-20000,
                              'Target Transaction Template ID is not provided.');
END InsNewReportRef;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : DelTranTmplVerSplitKeySetups
-- Description    : Deletes split key setups that belongs the the specified transaction template
--                  version. Note that child split keys and their split key setups will not be
--                  deleted (those setups become orphan if no other objects use them).
---------------------------------------------------------------------------------------------------
PROCEDURE DelTranTmplVerSplitKeySetups(p_tt_object_id VARCHAR2, p_daytime VARCHAR2)
--</EC-DOC>
IS
    lrec_tran_tmpl_version transaction_tmpl_version%ROWTYPE := ec_transaction_tmpl_version.row_by_pk(p_tt_object_id, p_daytime);
BEGIN
    DELETE FROM split_key_setup
    WHERE split_key_setup.object_id = lrec_tran_tmpl_version.SPLIT_KEY_ID
        AND split_key_setup.daytime >= lrec_tran_tmpl_version.daytime
        AND split_key_setup.daytime < NVL(lrec_tran_tmpl_version.end_date, split_key_setup.daytime + 1);
END DelTranTmplVerSplitKeySetups;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : ClearTranTmplVerSourceSplitMtd
-- Description    : Clears the Source Split Method from a transaction template version.
---------------------------------------------------------------------------------------------------
PROCEDURE ClearTranTmplVerSourceSplitMtd(p_tt_object_id VARCHAR2, p_daytime VARCHAR2)
--</EC-DOC>
IS
    lrec_tran_tmpl_version transaction_tmpl_version%ROWTYPE := ec_transaction_tmpl_version.row_by_pk(p_tt_object_id, p_daytime);
BEGIN
    UPDATE transaction_tmpl_version
        SET SOURCE_SPLIT_METHOD = NULL
        WHERE OBJECT_ID = p_tt_object_id
            AND DAYTIME = p_daytime;
END ClearTranTmplVerSourceSplitMtd;

--<EC-DOC>
--------------------------------------------------------------------------------------------------------------------------
-- Procedure      : ClearProductDescription
-- Description    : Clears the ClearProduct Description when removing stream item code from a transaction template version.
--------------------------------------------------------------------------------------------------------------------------
PROCEDURE ClearProductDescription(p_tt_object_id VARCHAR2, p_daytime VARCHAR2)
--</EC-DOC>
IS
    lrec_tran_tmpl_version transaction_tmpl_version%ROWTYPE := ec_transaction_tmpl_version.row_by_pk(p_tt_object_id, p_daytime);
BEGIN
    UPDATE transaction_tmpl_version
        SET  PRODUCT_NODE_ITEM_ID = NULL
        WHERE OBJECT_ID = p_tt_object_id
            AND DAYTIME = p_daytime;

END ClearProductDescription;

-- Will be used by future JIRAs
/*
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : RemoveLITmplFromTTVersion
-- Description    : Removes a line item template from the given transaction template version. Note
--                  that the line item template version on the given transaction template version
--                  have to be the last version in order for it to be removed.
---------------------------------------------------------------------------------------------------
PROCEDURE RemoveLITmplFromTTVersion(p_user VARCHAR2, p_line_item_id VARCHAR2, p_daytime DATE)
--</EC-DOC>
IS
    newer_line_item_version_found EXCEPTION;
BEGIN
    -- Check if the deleting line item has a newer version,
    -- Only when the deleting version is the latest version the
    -- line item can be removed from the specified transaction
    -- template.
    IF NOT ecdp_line_item.IsLastLITemplateVersion(p_line_item_id, p_daytime) THEN
        RAISE newer_line_item_version_found;
    END IF;

    ecdp_line_item.RemoveLastLITemplateVersion(p_line_item_id, TRUE);

EXCEPTION
     WHEN newer_line_item_version_found THEN
         Raise_Application_Error(-20000,'Newer version(s) found on line item template (CODE: ''' || ecdp_objects.GetObjCode(p_line_item_id) || ''', OBJECT_ID: ''' || p_line_item_id || ''').');
END RemoveLITmplFromTTVersion;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : AlignNewLITmplToTTVersion
-- Description    : Algins the new line item template with its connected template template version.
--                  p_applyToAllNewerVersions should be set to TRUE if the line item template is
--                  avaliable for all newer transaction template versions, new version will be created
--                  for each newer TT version. Or FALSE, if it is only avaliable for the TT version it
--                  is created on, then its end_date and object_end_date will be set to the end_date
--                  of the TT version.
---------------------------------------------------------------------------------------------------
PROCEDURE AlignNewLITmplToTTVersion(p_user VARCHAR2, p_line_item_id VARCHAR2, p_applyToAllNewerVersions BOOLEAN DEFAULT FALSE)
--</EC-DOC>
IS
    CURSOR li_versions(cp_line_item_id VARCHAR2) IS
        SELECT MAX(LINE_ITEM_TMPL_VERSION.DAYTIME) max_version, COUNT(LINE_ITEM_TMPL_VERSION.OBJECT_ID) version_count
        FROM LINE_ITEM_TMPL_VERSION
        WHERE LINE_ITEM_TMPL_VERSION.OBJECT_ID = cp_line_item_id;

    CURSOR tt_versions(cp_transaction_temp_id VARCHAR2) IS
        SELECT TRANSACTION_TMPL_VERSION.Daytime ver_Daytime,
            Transaction_Tmpl_Version.End_Date ver_End_Date,
            Transaction_Template.Start_Date obj_Start_Date,
            Transaction_Template.End_Date obj_End_Date,
            (CASE WHEN (Transaction_Tmpl_Version.End_Date IS NULL OR Transaction_Tmpl_Version.End_Date = Transaction_Template.End_Date) THEN 1 ELSE 0 END) is_last_version
        FROM TRANSACTION_TMPL_VERSION, TRANSACTION_TEMPLATE
        WHERE TRANSACTION_TMPL_VERSION.Object_Id = cp_transaction_temp_id
            AND TRANSACTION_TMPL_VERSION.OBJECT_ID = TRANSACTION_TEMPLATE.OBJECT_ID
        ORDER BY TRANSACTION_TMPL_VERSION.Daytime;

    lrec_line_item_template LINE_ITEM_TEMPLATE%ROWTYPE := ec_line_item_template.row_by_object_id(p_line_item_id);
    lrec_line_item_template_ver LINE_ITEM_TMPL_VERSION%ROWTYPE;
    lrec_transction_template_ver TRANSACTION_TMPL_VERSION%ROWTYPE;
    ln_line_item_template_ver_num NUMBER;
    lv2_line_item_template_version DATE;
    lv2_new_line_item_obj_end_date DATE;
    ld_max_line_item_version DATE;

    line_item_has_no_version EXCEPTION;
    line_item_has_multiple_ver EXCEPTION;
    line_item_no_connected_tt_tmpl EXCEPTION;
BEGIN

    FOR li_ver IN li_versions(p_line_item_id) LOOP
        ln_line_item_template_ver_num := li_ver.version_count;
        lv2_line_item_template_version := li_ver.max_version;
        EXIT;
    END LOOP;

    IF ln_line_item_template_ver_num IS NULL THEN
        RAISE line_item_has_no_version;
    ELSIF ln_line_item_template_ver_num > 1 THEN
        RAISE line_item_has_multiple_ver;
    END IF;

    lrec_line_item_template_ver := ec_line_item_tmpl_version.row_by_pk(p_line_item_id, lv2_line_item_template_version, '=');

    IF lrec_line_item_template.transaction_template_id IS NULL THEN
        RAISE line_item_no_connected_tt_tmpl;
    END IF;

    IF p_applyToAllNewerVersions THEN
        -- The new line item object is avaliable for the transaction template version it
        -- is created on (with same daytime) and all newer versions. Create a new version
        -- for each TT template version and set the object_end_date if necessary.
        FOR tt_ver IN tt_versions(lrec_line_item_template.transaction_template_id) LOOP
            -- Create a new version if it is not the first (since first version already exists)
            IF tt_ver.ver_Daytime > lrec_line_item_template_ver.daytime THEN
                ecdp_line_item.genNewLITemplateVersion(p_user, lrec_line_item_template.object_id, tt_ver.ver_Daytime);
            END IF;

            -- For the last version, the object_end_date and end_date need to be decided (by
            -- the transaction template version)
            IF tt_ver.is_last_version = 1 THEN
                ld_max_line_item_version := tt_ver.ver_Daytime;
                lv2_new_line_item_obj_end_date := tt_ver.obj_End_Date;
            END IF;
        END LOOP;
    ELSE
        -- The new line item object is only avaliable for one transaction template version
        -- so that the end_date of the object should be the same as the one of TT template.
        -- The object_end_date of LI template should be the same as TT template also.
        lrec_transction_template_ver :=
            ec_transaction_tmpl_version.row_by_pk(lrec_line_item_template.transaction_template_id, lrec_line_item_template_ver.daytime, '=');
        ld_max_line_item_version := lrec_line_item_template_ver.daytime;
        lv2_new_line_item_obj_end_date := lrec_transction_template_ver.end_date;
    END IF;

    -- Update the last line item version end_date and object_end_date
    UPDATE LINE_ITEM_TMPL_VERSION
    SET LINE_ITEM_TMPL_VERSION.End_Date = lv2_new_line_item_obj_end_date
    WHERE LINE_ITEM_TMPL_VERSION.DAYTIME = ld_max_line_item_version;

    UPDATE LINE_ITEM_TEMPLATE
    SET LINE_ITEM_TEMPLATE.END_DATE = lv2_new_line_item_obj_end_date
    WHERE LINE_ITEM_TEMPLATE.OBJECT_ID = lrec_line_item_template.Object_Id;

    EXCEPTION
        WHEN line_item_has_no_version THEN
            Raise_Application_Error(-20000,'Line Item Template (CODE: ''' || ecdp_objects.GetObjCode(p_line_item_id) || ''', OBJECT_ID: ''' || p_line_item_id || ''') doesn''t have a version.');
        WHEN line_item_has_multiple_ver THEN
            Raise_Application_Error(-20001,'Line Item Template (CODE: ''' || ecdp_objects.GetObjCode(p_line_item_id) || ''', OBJECT_ID: ''' || p_line_item_id || ''') has more than one versions.');
        WHEN line_item_no_connected_tt_tmpl THEN
            Raise_Application_Error(-20002,'Line Item Template (CODE: ''' || ecdp_objects.GetObjCode(p_line_item_id) || ''', OBJECT_ID: ''' || p_line_item_id || ''') doesn''t connect to a transaction template.');
END AlignNewLITmplToTTVersion;

*/

PROCEDURE ClearStreamItemInfo(p_transaction_template_id VARCHAR2, p_daytime DATE)
IS
v_split_key_id                 VARCHAR2(32);
BEGIN
    UPDATE TRANSACTION_TMPL_VERSION
    SET TRANSACTION_TMPL_VERSION.Stream_Item_Id = NULL,
        TRANSACTION_TMPL_VERSION.PRODUCT_NODE_ITEM_ID = NULL
    WHERE TRANSACTION_TMPL_VERSION.OBJECT_ID = p_transaction_template_id
        AND TRANSACTION_TMPL_VERSION.Daytime <= p_daytime
        AND NVL(TRANSACTION_TMPL_VERSION.End_Date, p_daytime + 1) > p_daytime;

    v_split_key_id:=ec_transaction_tmpl_version.split_key_id(p_transaction_template_id,p_daytime, '<=');


    DELETE FROM SPLIT_KEY_SETUP sks
    WHERE object_id IN(SELECT  child_split_key_id
                       FROM SPLIT_KEY_SETUP
                       WHERE object_id=v_split_key_id);


    DELETE FROM SPLIT_KEY_SETUP WHERE object_id=v_split_key_id;


END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetTransStreamItem
-- Description    : Evaluates the configuration for a stream item at transaction_level
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION GetTransStreamItem(p_transaction_key               VARCHAR2,
                             p_user                         VARCHAR2,
                             p_source_node_id               VARCHAR2 DEFAULT NULL,
                             p_silent_mode_ind              VARCHAR2 DEFAULT 'N',
                             p_message                      IN OUT VARCHAR2,
                             p_trans_tmpl_id                VARCHAR2 DEFAULT NULL,
                             p_daytime                      DATE DEFAULT NULL,
                             p_uom_code                     VARCHAR2 DEFAULT NULL,
                             p_product_id                   VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
--</EC-DOC>
IS

lrec_t                        cont_transaction%rowtype;
lrec_ttv                      transaction_tmpl_version%rowtype;
lrec_contract_version         contract_version%rowtype;
lv2_dist_type                 VARCHAR2(32);
lv2_dist_id                   VARCHAR2(32);
lv2_object_list_id            VARCHAR2(32);
lv2_financial_code            VARCHAR2(32);
lv2_contract_comp             VARCHAR2(32);
lv2_contract_company_code     VARCHAR2(32);
lv2_stream_item_id            VARCHAR2(32);
lv2_stream_item_tmp_id        VARCHAR2(32);
lv2_stream_item_fb_id         VARCHAR2(32);
lv2_contract_group_code       VARCHAR2(32);
lv2_doc_scope                 VARCHAR2(32);
lv2_conflicting_si            VARCHAR2(32);
ln_cnt_from_node_to_node      NUMBER := 0;
ln_cnt_to_node                NUMBER := 0;
ln_cnt_from_node              NUMBER := 0;
ln_cnt_fallback               NUMBER := 0;

ln_matchlvl_from_node_to_node NUMBER := 0;
ln_matchlvl_to_node           NUMBER := 0;
ln_matchlvl_from_node         NUMBER := 0;
ln_matchlvl_fallback          NUMBER := 0;

lv2_uom_code                  VARCHAR2(10);

lv2_config                    VARCHAR2(10000);
e                             EXCEPTION;
e_no_stream_item              EXCEPTION;
ld_daytime                    DATE;
lv2_contract_id               VARCHAR2(32);
lv2_delivery_point            VARCHAR2(32);
lv2_loading_port              VARCHAR2(32);
lv2_product_id                VARCHAR2(32);

cursor csi(cp_daytime                date,
           cp_financial_code         varchar2,
           cp_dist_type              varchar2,
           cp_dist_id                varchar2,
           cp_product_id             varchar2,
           cp_contract_comp          varchar2,
           cp_contract_company_code  varchar2,
           cp_uom_code               VARCHAR2)  is
select t.*,
       DECODE(cp_uom_code,uom_code,1,
       DECODE(ecdp_unit.GetUOMGroup(cp_uom_code),master_uom_group,2,3)) match_level
  from v_transaction_distribution t
 where t.product_id = cp_product_id
   and t.financial_code = cp_financial_code
   and t.daytime <= cp_daytime
   and field_id =
       decode(cp_dist_type,
              'OBJECT',
              cp_dist_id,
              'OBJECT_LIST',
              ec_field.object_id_by_uk('SUM', 'FIELD'),
              NULL)
   and ec_company.object_code(company_id) like
       decode(substr(cp_contract_comp, 0, 2),
              'MV',
              '%_FULL',
              cp_contract_company_code)
 order by
   match_level,
   t.object_code;


BEGIN


  lrec_t := ec_cont_transaction.row_by_pk(p_transaction_key);

  IF lrec_t.Transaction_Key IS NOT NULL THEN

        lv2_contract_id := lrec_t.object_id;
        lrec_ttv := ec_transaction_tmpl_version.row_by_pk(lrec_t.trans_template_id,lrec_t.daytime,'<=');

        --pulls from the cont_transaction instead of the template
        ld_daytime :=  lrec_t.daytime;
        lv2_delivery_point := lrec_t.delivery_point_id;
        lv2_loading_port := lrec_t.loading_port_id;
        lv2_product_id := NVL(p_product_id, lrec_t.product_id);

  ELSIF p_trans_tmpl_id IS NOT NULL THEN --if based off transaction template instead

        lv2_contract_id := ec_contract_doc.contract_id(ec_transaction_template.contract_doc_id(p_trans_tmpl_id));
        lrec_ttv := ec_transaction_tmpl_version.row_by_pk(p_trans_tmpl_id,p_daytime,'<=');
        lv2_delivery_point := lrec_ttv.delivery_point_id;
        lv2_loading_port := lrec_ttv.loading_port_id;
        lv2_product_id := NVL(p_product_id, lrec_ttv.product_id);
        ld_daytime := p_Daytime;

  END IF;

lv2_object_list_id := ec_object_list.object_id_by_uk(lrec_ttv.dist_code);
lv2_dist_id := ecdp_objects.GetObjIDFromCode(lrec_ttv.dist_object_type, lrec_ttv.dist_code);
lv2_uom_code:=nvl(p_uom_code,lrec_ttv.uom1_code);

lrec_contract_version := ec_contract_version.row_by_pk(lv2_contract_id,ld_daytime,'<=');
lv2_financial_code := ec_contract_version.financial_code(lv2_contract_id,ld_daytime,'<=');
lv2_contract_group_code := lrec_contract_version.contract_group_code;
lv2_doc_scope := ec_contract_doc_version.doc_scope(ec_transaction_template.CONTRACT_DOC_ID(lrec_ttv.object_id),ld_daytime,'<=');
lv2_contract_comp := ecdp_contract_setup.getcontractcomposition(lv2_contract_id,ec_cont_transaction.trans_template_id(p_transaction_key),ld_daytime);
lv2_contract_company_code := ec_company.object_code(lrec_contract_version.company_id);

lv2_dist_type := lrec_ttv.dist_type;

-- Error message output
lv2_config := CHR(10)||CHR(10)||
               'Daytime'||CHR(10)||ld_daytime||CHR(10)||CHR(10)||
              'Financial Code'||CHR(10)||lv2_financial_code||CHR(10)||CHR(10)||
              'Use Stream Indicator'||CHR(10)||lrec_ttv.use_stream_items_ind||CHR(10)||CHR(10)||
              'Dist Type'||CHR(10)||lv2_dist_type||CHR(10)||CHR(10)||
              'Dist Object Type'||CHR(10)||lrec_ttv.dist_object_type||CHR(10)||CHR(10)||
              'Dist Object (Object/Object List)'||CHR(10)||ecdp_objects.GetObjCode(nvl(lv2_dist_id,lv2_object_list_id))||CHR(10)||CHR(10)||
              'Product'||CHR(10)||ec_product_version.name(lv2_product_id,ld_daytime,'<=')||CHR(10)||CHR(10)||
              'Contract comp'||CHR(10)||lv2_contract_comp||CHR(10)||CHR(10)||
              'Contract Company'||CHR(10)||lv2_contract_company_code||CHR(10)||CHR(10);

-- Return NULL if DIST_OBJECT_TYPE is NULL or USE_STREAM_ITEM_IND is set to 'N'
IF lrec_ttv.dist_object_type IS NULL OR lrec_ttv.dist_object_type <> 'FIELD' OR NVL(lrec_ttv.USE_STREAM_ITEMS_IND, 'N') = 'N' THEN
   RETURN NULL;
END IF;


-- Starts to find a best match stream item
for v in csi(
    ld_daytime,
    lv2_financial_code,
    lv2_dist_type,
    lv2_dist_id,
    lv2_product_id,
    lv2_contract_comp,
    lv2_contract_company_code,
    lv2_uom_code
    ) loop


    IF (v.to_node_id =  CASE WHEN lv2_doc_scope = 'CARGO_BASED' then lv2_loading_port
                            WHEN lv2_doc_scope = 'PERIOD_BASED' then lv2_delivery_point END) THEN


           IF v.from_node_id = p_source_node_id THEN
             IF ln_matchlvl_from_node_to_node = 0 OR ln_matchlvl_from_node_to_node = v.match_level THEN
               IF lv2_stream_item_id IS NOT NULL AND ln_cnt_from_node_to_node > 0 THEN
                  lv2_conflicting_si := lv2_stream_item_id;
               END IF;
              lv2_stream_item_id := v.object_id; -- Full match
             ln_cnt_from_node_to_node := ln_cnt_from_node_to_node + 1;
               ln_matchlvl_from_node_to_node := v.match_level;
             END IF;
          END IF;

          IF lv2_stream_item_id IS NULL OR ln_matchlvl_from_node_to_node = 0 THEN
             IF ln_matchlvl_to_node = 0 OR ln_matchlvl_to_node = v.match_level THEN
                IF lv2_stream_item_id IS NOT NULL AND ln_cnt_from_node_to_node = 0
                   AND ln_cnt_to_node > 0 THEN
                   lv2_conflicting_si :=lv2_stream_item_id;
                END IF;
              lv2_stream_item_id := v.object_id;
              ln_cnt_to_node := ln_cnt_to_node + 1;
              ln_matchlvl_to_node := v.match_level;
             END IF;
          END IF;

      END IF;

      IF v.from_node_id = p_source_node_id THEN
         IF ln_matchlvl_from_node = 0 OR ln_matchlvl_from_node = v.match_level THEN
            IF lv2_stream_item_id IS NULL AND lv2_stream_item_tmp_id IS not NULL THEN
              lv2_conflicting_si := lv2_stream_item_tmp_id;
            END IF;
              lv2_stream_item_tmp_id := v.object_id;
              ln_cnt_from_node := ln_cnt_from_node + 1;
            ln_matchlvl_from_node := v.match_level;
         END IF;
          END IF;

     IF lv2_stream_item_tmp_id IS NULL OR ln_matchlvl_from_node = 0 THEN
         IF ln_matchlvl_fallback = 0 OR ln_matchlvl_fallback = v.match_level THEN
             IF lv2_stream_item_id IS NULL AND lv2_stream_item_fb_id IS not NULL THEN
                lv2_conflicting_si := lv2_stream_item_fb_id;
             END IF;
          lv2_stream_item_fb_id := v.object_id;
          ln_cnt_fallback := ln_cnt_fallback + 1;
             ln_matchlvl_fallback := v.match_level;
          END IF;
              END IF;


END LOOP;

-- First check tmp stream item
IF lv2_stream_item_id IS NULL THEN
  lv2_stream_item_id := lv2_stream_item_tmp_id;
  END IF;

 -- If still null, use fallback stream item
 IF lv2_stream_item_id IS NULL THEN
    lv2_stream_item_id := lv2_stream_item_fb_id;
 END IF;




      IF ln_cnt_from_node_to_node >= 1  THEN

           IF ln_cnt_from_node_to_node > 1 THEN
              p_message := 'More than one stream item found having match on from node and to node. (' || ec_stream_item.object_code(lv2_stream_item_id) ||' & '|| ec_stream_item.object_code(lv2_conflicting_si) ||' ) Please adjust configuration.'||CHR(10)||
                        'Current configuration:'||CHR(10);
              IF p_silent_mode_ind = 'N' THEN
                  RAISE e;
                END IF;
          END IF;

      ELSIF ln_cnt_to_node >= 1 THEN

          IF ln_cnt_to_node > 1 THEN
             p_message := 'More than one stream item found having match on to node.(' || ec_stream_item.object_code(lv2_stream_item_id) ||' & '|| ec_stream_item.object_code(lv2_conflicting_si) ||' ) Please adjust configuration.'||CHR(10)||
                          'Current configuration:'||CHR(10);
            IF p_silent_mode_ind = 'N' THEN
                  RAISE e;
                END IF;
          END IF;

      ELSIF ln_cnt_from_node >= 1 THEN

        IF ln_cnt_from_node > 1 THEN
            p_message := 'More than one stream item found having match on from node. Please adjust configuration.'||CHR(10)||
                      'Current configuration:'||CHR(10);
            IF p_silent_mode_ind = 'N' THEN
              RAISE e;
            END IF;
        END IF;
      ELSIF ln_cnt_fallback >= 1 THEN

       IF ln_cnt_fallback > 1  THEN
            p_message := 'More than one stream item found. Please adjust configuration.'||CHR(10)||
                      'Current configuration:'||CHR(10);
          IF p_silent_mode_ind = 'N' THEN
                  RAISE e;
          END IF;
        END IF;
      END IF;



  IF lv2_stream_item_id IS NULL THEN
     p_message := 'No stream item match at transaction level. Please adjust configuration.'||CHR(10)||
                  'Current configuration:'||CHR(10);
      IF p_silent_mode_ind = 'N' THEN
        RAISE e;
      END IF;
 END IF;

RETURN lv2_stream_item_id;

EXCEPTION

     WHEN e THEN

          Raise_Application_Error(-20000,p_message||lv2_config);


     WHEN e_no_stream_item THEN

          Raise_Application_Error(-20000,p_message||lv2_config);

END GetTransStreamItem;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : SetTransStreamItem
-- Description    : Evaluates the configuration and set a stream item at transaction_level
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
PROCEDURE SetTransStreamItem(p_transaction_key VARCHAR2,
                             p_user            VARCHAR2,
                             p_source_node_id  VARCHAR2 DEFAULT NULL,
                             p_uom_code        VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

lv2_stream_item_id                VARCHAR2(32);
e_no_stream_item                  EXCEPTION;
lv2_argument                      VARCHAR2(4000);

BEGIN

lv2_stream_item_id := GetTransStreamItem(p_transaction_key,p_user,p_source_node_id,'N',lv2_argument);

IF lv2_stream_item_id IS NOT NULL THEN
  UPDATE cont_transaction t
     SET t.stream_item_id = lv2_stream_item_id, last_updated_by = p_user
   WHERE t.transaction_key = p_transaction_key;
END IF;


END SetTransStreamItem;



------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GenParam_GetDistInfoRC(
                         p_cont_transaction                 CONT_TRANSACTION%ROWTYPE
                        ,p_overwrite_uom_code               VARCHAR2
                        )
RETURN T_PARAM_GetDistInfoRC
IS
    lv2_contract_id                      VARCHAR2(32);
    lv2_distribution_obj_id              VARCHAR2(32);
    lv2_contract_comp                    VARCHAR2(32);
    lv2_contract_company_code            VARCHAR2(32);
    lv2_stream_id                        VARCHAR2(32);
    lv2_uom_code                         VARCHAR2(32);
    ld_daytime                           DATE;
    lrec_transaction_tmpl_version        TRANSACTION_TMPL_VERSION%ROWTYPE;
    lrec_contract_version                CONTRACT_VERSION%ROWTYPE;
    lo_param                             T_PARAM_GetDistInfoRC;
BEGIN
    ld_daytime := p_cont_transaction.daytime;
    lv2_contract_id := p_cont_transaction.object_id;
    lrec_transaction_tmpl_version := ec_transaction_tmpl_version.row_by_pk(p_cont_transaction.trans_template_id, ld_daytime, '<=');
    lrec_contract_version := ec_contract_version.row_by_pk(lv2_contract_id, ld_daytime, '<=');

    lv2_contract_comp := ecdp_contract_setup.getcontractcomposition(lv2_contract_id,p_cont_transaction.trans_template_id, ld_daytime);
    lv2_distribution_obj_id := GetDistObjectID(lv2_contract_comp, lrec_transaction_tmpl_version.dist_code, lrec_transaction_tmpl_version.dist_object_type);
    lv2_contract_company_code := ec_company.object_code(lrec_contract_version.company_id);
    lv2_stream_id := ec_stream_item.stream_id(p_cont_transaction.stream_item_id);
    lv2_uom_code := nvl(p_overwrite_uom_code, lrec_transaction_tmpl_version.uom1_code);

    lo_param.daytime               := ld_daytime;
    lo_param.financial_code        := lrec_contract_version.financial_code;
    lo_param.transaction_dist_object_id := lv2_distribution_obj_id;
    lo_param.transaction_dist_type :=lrec_transaction_tmpl_version.dist_type;
    lo_param.product_id            := p_cont_transaction.product_id;
    lo_param.contract_id           := lv2_contract_id;
    lo_param.contract_comp         := lv2_contract_comp;
    lo_param.contract_company_code := lv2_contract_company_code;
    lo_param.stream_id             := lv2_stream_id;
    lo_param.split_key_id          := lrec_transaction_tmpl_version.split_key_id;
    lo_param.uom_code              := lv2_uom_code;

    RETURN lo_param;

END GenParam_GetDistInfoRC;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GenParam_GetDistInfoRC(
                         p_transaction_template_id          VARCHAR2
                        ,p_product_id                       VARCHAR2
                        ,p_stream_id                        VARCHAR2
                        ,p_daytime                          DATE
                        )
RETURN T_PARAM_GetDistInfoRC
IS
    lv2_contract_doc_id                  VARCHAR2(32);
    lv2_contract_id                      VARCHAR2(32);
    lv2_distribution_obj_id              VARCHAR2(32);
    lv2_contract_comp                    VARCHAR2(32);
    lv2_contract_company_code            VARCHAR2(32);
    lrec_transaction_tmpl_version        TRANSACTION_TMPL_VERSION%ROWTYPE;
    lrec_contract_version                CONTRACT_VERSION%ROWTYPE;
    lo_param                             T_PARAM_GetDistInfoRC;
BEGIN
    lv2_contract_doc_id := ec_transaction_template.contract_doc_id(p_transaction_template_id);
    lv2_contract_id := ec_contract_doc.contract_id(lv2_contract_doc_id);
    lrec_transaction_tmpl_version := ec_transaction_tmpl_version.row_by_pk(p_transaction_template_id, p_daytime, '<=');
    lrec_contract_version := ec_contract_version.row_by_pk(lv2_contract_id, p_daytime, '<=');

    lv2_contract_comp := ecdp_contract_setup.getcontractcomposition(lv2_contract_id,p_transaction_template_id, p_daytime);
    lv2_distribution_obj_id := GetDistObjectID(lv2_contract_comp, lrec_transaction_tmpl_version.dist_code, lrec_transaction_tmpl_version.dist_object_type);
    lv2_contract_company_code := ec_company.object_code(lrec_contract_version.company_id);


    lo_param.daytime               := p_daytime;
    lo_param.financial_code        := lrec_contract_version.financial_code;
    lo_param.transaction_dist_object_id := lv2_distribution_obj_id;
    lo_param.transaction_dist_type :=lrec_transaction_tmpl_version.dist_type;
    lo_param.contract_id           := lv2_contract_id;
    lo_param.product_id            := p_product_id;
    lo_param.contract_comp         := lv2_contract_comp;
    lo_param.contract_company_code := lv2_contract_company_code;
    lo_param.stream_id             := p_stream_id;
    lo_param.split_key_id          := lrec_transaction_tmpl_version.split_key_id;
    lo_param.uom_code              := lrec_transaction_tmpl_version.uom1_code;

    RETURN lo_param;

END GenParam_GetDistInfoRC;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetPCShare(
                         p_profit_centre_id                  iv_profit_centre.object_id%TYPE
                        ,p_split_key_id                      ov_split_key.OBJECT_ID%TYPE
                        ,p_object_list_id                    ov_object_list.OBJECT_ID%TYPE
                        ,p_daytime                           ov_object_list.DAYTIME%TYPE
                        ,p_uom_code                          VARCHAR2
                        ,p_sp_role_name                      VARCHAR2
                        ,p_use_obj_list_share                ecdp_revn_common.T_BOOLEAN_STR
                        )
RETURN NUMBER
IS
   ln_return_share      NUMBER;
   lv2_gen_rel_obj_code VARCHAR2(32);
BEGIN
   -- Try to get split key share
   IF p_use_obj_list_share = ecdp_revn_common.gv2_false THEN
       ln_return_share := Ecdp_split_key.GetSplitShareMth(p_split_key_id,p_profit_centre_id, p_daytime, p_uom_code, p_sp_role_name);
   ELSE
       lv2_gen_rel_obj_code := ecdp_objects.GetObjCode(p_profit_centre_id)||'$NULL';
       -- If no split key share, try to get object_list share
       ln_return_share := ec_object_list_setup.split_share(p_object_list_id, p_daytime, ecdp_objects.GetObjCode(p_profit_centre_id), lv2_gen_rel_obj_code,'<=')/100;
   END IF;
   RETURN ln_return_share;

END GetPCShare;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetDistInfoRC_ProfitCenter(
                         p_common_param                     T_PARAM_GetDistInfoRC
                        ,p_skip_validation                  BOOLEAN
                        )
RETURN T_TABLE_PC_DIST_INFO
IS
    CURSOR c_dist_list (
               cp_daytime                              DATE,
               cp_financial_code                    VARCHAR2,
               cp_dist_id                           VARCHAR2,
               cp_product_id                        VARCHAR2,
               cp_contract_comp                     VARCHAR2,
               cp_contract_company_code             VARCHAR2,
               cp_stream_id                         VARCHAR2,
               cp_uom_code                             VARCHAR2 DEFAULT NULL)
    IS
        SELECT t.*,
               DECODE(cp_uom_code,uom_code,1,
               DECODE(ecdp_unit.GetUOMGroup(cp_uom_code),master_uom_group,2,3)) match_level
              FROM v_transaction_distribution t
             WHERE t.product_id = cp_product_id
               AND t.stream_id = cp_stream_id
               AND t.financial_code = cp_financial_code
               AND t.daytime <= cp_daytime
           AND t.field_id IN (SELECT ecdp_objects.GetObjIDFromCode(GENERIC_CLASS_NAME, object_list_setup.GENERIC_OBJECT_CODE)
                                FROM object_list_setup
                               WHERE object_list_setup.object_id = cp_dist_id
                                 AND daytime <= cp_daytime
                                 AND nvl(end_date, cp_daytime + 1) > cp_daytime
                                  UNION ALL
                                  SELECT f.object_id
                                    FROM field f
                                   WHERE f.object_id = cp_dist_id
                                     AND f.object_code <> 'SUM')
               AND ec_company.object_code(company_id) LIKE
                   decode(substr(cp_contract_comp, 0, 2),
                          'MV',
                          '%_FULL',
                          cp_contract_company_code)
             ORDER BY t.field_id, --sorted by field id so fields come consecutivly
                      match_level,
                      t.object_code;

    CURSOR c_object_list_setup (
               cp_daytime          DATE,
               cp_dist_id          VARCHAR2)
    IS
        SELECT obj_id, generic_object_code, ecdp_objects.GetObjName(obj_id,daytime) generic_object_name
          FROM dv_object_list_setup
         WHERE object_id = cp_dist_id
           AND daytime <= cp_daytime
           AND nvl(end_date, cp_daytime + 1) > cp_daytime
      ORDER BY generic_object_code;

    lv2_dist_object_id             VARCHAR2(32);
    lv2_prev_field                 VARCHAR2(32);
    lv2_argument                   VARCHAR2(4000);
    lv2_prev_field_ml              VARCHAR2(32);
    lv2_prev_fsi                   VARCHAR2(32);
    lv2_count                      NUMBER;
    lt_dist_info                   T_TABLE_PC_DIST_INFO;
    lb_dist_info_missing           BOOLEAN;
    lb_add_current_dist            BOOLEAN;
    lb_use_obj_list_share          ecdp_revn_common.T_BOOLEAN_STR;
    lv_count_cur_rows              NUMBER:=0;

    e_too_many_stream_items        EXCEPTION;
    e_no_stream_item               EXCEPTION;
    e_dist_info_missing            EXCEPTION;
    e_no_valid_profit_center       EXCEPTION;
BEGIN
    lt_dist_info := T_TABLE_PC_DIST_INFO();

    lb_use_obj_list_share := ecdp_object_list.VerifySplitShare(p_common_param.transaction_dist_object_id, p_common_param.daytime);

    IF  lb_use_obj_list_share = 'N' AND  ecdp_objects.GetObjClassName(p_common_param.transaction_dist_object_id)='OBJECT_LIST'  THEN

        lv2_argument := ec_field_version.name(p_common_param.transaction_dist_object_id, p_common_param.daytime,'<=')   || ' No valid objects for document date '
                        || p_common_param.daytime
                        || ' in the defined object list. Please adjust configuration. ' || CHR(10);

        RAISE e_no_valid_profit_center ;
    END IF;

    FOR i_dist IN c_dist_list(
                          p_common_param.daytime
                         ,p_common_param.financial_code
                         ,p_common_param.transaction_dist_object_id
                         ,p_common_param.product_id
                         ,p_common_param.contract_comp
                         ,p_common_param.contract_company_code
                         ,p_common_param.stream_id
                         ,p_common_param.uom_code
                         )
    LOOP
        lb_add_current_dist := TRUE;
        lv2_dist_object_id := i_dist.FIELD_ID;

        IF NOT p_skip_validation
        THEN
            --verify no duplicate fields in same level
            IF nvl(lv2_prev_field,'xx') = lv2_dist_object_id AND lv2_prev_field_ml = i_dist.Match_Level THEN
                lv2_argument := 'More than one matching stream item found on Field '
                                || ec_field_version.name(lv2_dist_object_id,p_common_param.daytime,'<=')
                                || ' (' || lv2_prev_fsi || ' & ' || i_dist.object_code
                                || '). Please adjust configuration.' || CHR(10)
                                ||'Current configuration:'||CHR(10);
                RAISE e_too_many_stream_items;

            ELSIF nvl(lv2_prev_field,lv2_dist_object_id) <> lv2_dist_object_id AND i_dist.Match_Level = 3 THEN
                lv2_argument := 'No stream item found having a matching uom on Field '
                                || ec_field_version.name(lv2_dist_object_id,p_common_param.daytime,'<=')
                                || '. Please adjust configuration.' || CHR(10)
                                || 'Current configuration:'||CHR(10);
                RAISE e_no_stream_item;

            ELSIF nvl(lv2_prev_field,'xx') = lv2_dist_object_id AND lv2_prev_field_ml < i_dist.Match_Level THEN
                --match already found
                lb_add_current_dist := FALSE;
            END IF;
        END IF;

        IF lb_add_current_dist
        THEN
             lv2_prev_field := lv2_dist_object_id;
             lv2_prev_field_ml := i_dist.Match_Level;
             lv2_prev_fsi := i_dist.object_code;

            lt_dist_info.EXTEND(1);
            lt_dist_info(lt_dist_info.LAST).STREAM_ITEM_ID := i_dist.OBJECT_ID;
            lt_dist_info(lt_dist_info.LAST).STREAM_ITEM_CODE := i_dist.OBJECT_CODE;
            lt_dist_info(lt_dist_info.LAST).PROFIT_CENTER_ID := i_dist.FIELD_ID;
            lt_dist_info(lt_dist_info.LAST).CHILD_SPLIT_KEY_ID :=
                                                ec_split_key_setup.child_split_key_id(p_common_param.split_key_id, i_dist.object_id, p_common_param.daytime, '<=');
            lt_dist_info(lt_dist_info.LAST).PROFIT_CENTER_SHARE :=
                                                CASE WHEN p_common_param.transaction_dist_type='OBJECT' THEN 1 ELSE GetPCShare(i_dist.FIELD_ID, p_common_param.split_key_id, p_common_param.transaction_dist_object_id, p_common_param.daytime, p_common_param.uom_code, 'SP_SPLIT_KEY', lb_use_obj_list_share) END;
            lt_dist_info(lt_dist_info.LAST).MATCH_LEVEL := i_dist.MATCH_LEVEL;
        END IF;
    END LOOP;

    --Check: All valid objects from object_list_setup needs to be included in the return value
    IF p_common_param.daytime IS NOT NULL
        AND p_common_param.financial_code IS NOT NULL
        AND p_common_param.transaction_dist_object_id IS NOT NULL
        AND p_common_param.product_id IS NOT NULL
        AND p_common_param.contract_comp IS NOT NULL
        AND p_common_param.contract_company_code IS NOT NULL
        AND p_common_param.stream_id IS NOT NULL
        AND p_common_param.uom_code IS NOT NULL
    THEN
        lv2_argument := NULL;
        lv2_count := 0;
        FOR i_ols IN c_object_list_setup(
                          p_common_param.daytime
                         ,p_common_param.transaction_dist_object_id)
        LOOP
            lb_dist_info_missing  := TRUE;
            IF lt_dist_info.COUNT > 0 THEN
                FOR i_dist_info IN lt_dist_info.FIRST .. lt_dist_info.LAST
                LOOP
                    IF (lt_dist_info(i_dist_info).PROFIT_CENTER_ID = i_ols.obj_id) AND lb_dist_info_missing THEN
                        lb_dist_info_missing := FALSE;
                    END IF;
                END LOOP;
            END IF;

            IF lb_dist_info_missing THEN
                lv2_argument := lv2_argument || ' * ''' || i_ols.generic_object_name || '''   -   (' || i_ols.generic_object_code || ')' || chr(13) || chr(10);
                lv2_count := lv2_count + 1;
            END IF;
        END LOOP;

        --Prepare feedback to end user.
        IF lv2_argument IS NOT NULL THEN
            lv2_argument := 'Configuration mismatch.' || chr(13) || chr(10) ||
                            'This document is using object list ''' || ecdp_objects.GetObjName(p_common_param.transaction_dist_object_id,p_common_param.daytime) || ''' (' || ecdp_objects.GetObjCode(p_common_param.transaction_dist_object_id) || ') for profit center distribution. ' ||
                            (case lv2_count when 1 then 'This profit center has' else 'These profit centers have' end) || ' no stream items defined for product ''' || ecdp_objects.GetObjName(p_common_param.product_id,p_common_param.daytime) || ''':' || chr(13) || chr(10) ||
                            lv2_argument || chr(13) || chr(10);
            RAISE e_dist_info_missing;
        END IF;
    END IF;

    RETURN lt_dist_info;
EXCEPTION
    WHEN e_too_many_stream_items THEN
        Raise_Application_Error(-20000,lv2_argument);

    WHEN e_no_stream_item THEN
        Raise_Application_Error(-20000,lv2_argument);

    WHEN e_dist_info_missing THEN
        Raise_Application_Error(-20000,lv2_argument);

    WHEN e_no_valid_profit_center  THEN
        Raise_Application_Error(-20000,lv2_argument);

    WHEN OTHERS THEN
        Raise_Application_Error(-20000, 'There was an error performing the requested operation ' || SQLCODE || ' '|| SUBSTR(SQLERRM, 1, 240) );

END GetDistInfoRC_ProfitCenter;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetDistInfoRC_Company(
                         p_common_param                     T_PARAM_GetDistInfoRC
                        ,p_profit_center_id                 VARCHAR2
                        ,p_skip_validation                  BOOLEAN
                        )
RETURN T_TABLE_COMPANY_DIST_INFO
IS
    CURSOR c_dist_list(
               cp_daytime              DATE,
               cp_financial_code       VARCHAR2,
               cp_dist_id              VARCHAR2,
               cp_product_id           VARCHAR2,
               cp_contract_id          VARCHAR2,
               cp_stream_id            VARCHAR2,
               cp_uom_code             VARCHAR2 DEFAULT NULL)
    IS
      SELECT t.object_id split_member_id,
             t.object_code,
             vendor.company_id vendor_id,
             --nvl(cp_customer_id, customer.company_id) cust_id,
             customer.company_id cust_id,
             ec_stream_item_version.company_id(t.object_id,cp_daytime,'<=') comp_id,
             vendor.party_share / 100 vendor_share,
             customer.party_share / 100 customer_share,
             DECODE(cp_uom_code,uom_code,1,
                     DECODE(ecdp_unit.GetUOMGroup(cp_uom_code),master_uom_group,2,3)) match_level
      FROM v_transaction_distribution t,
             contract_party_share       vendor,
             contract_party_share       customer
      WHERE t.product_id = cp_product_id
            AND t.stream_id = cp_stream_id
            AND t.financial_code = cp_financial_code
            AND t.daytime <= cp_daytime
            AND field_id = cp_dist_id -- This should never be SUM. Outer loop prevents that.
            AND vendor.object_id = cp_contract_id
            AND customer.object_id = cp_contract_id
            AND ec_company.company_id(vendor.company_id) = t.company_id
            AND cp_financial_code IN ('SALE', 'TA_INCOME', 'JOU_ENT')
            AND vendor.party_role = 'VENDOR'
            AND customer.party_role = 'CUSTOMER'
            AND customer.daytime <= cp_daytime
            AND nvl(customer.end_date, cp_daytime + 1) > cp_daytime
            AND vendor.daytime <= cp_daytime
            AND nvl(vendor.end_date, cp_daytime + 1) > cp_daytime
    UNION
      SELECT t.object_id split_member_id,
             t.object_code,
             vendor.company_id vendor_id,
             --nvl(cp_customer_id, customer.company_id) cust_id,
             customer.company_id cust_id,
             ec_stream_item_version.company_id(t.object_id,cp_daytime,'<=') comp_id,
             vendor.party_share / 100 vendor_share,
             customer.party_share / 100 customer_share,
             DECODE(cp_uom_code,uom_code,1,
                      DECODE(ecdp_unit.GetUOMGroup(cp_uom_code),master_uom_group,2,3)) match_level
      FROM v_transaction_distribution t,
             contract_party_share       vendor,
             contract_party_share       customer
      WHERE t.product_id = cp_product_id
             AND t.financial_code = cp_financial_code
             AND t.daytime <= cp_daytime
             AND field_id = cp_dist_id -- This should never be SUM. Outer loop prevents that.
             AND vendor.object_id = cp_contract_id
             AND customer.object_id = cp_contract_id
             AND (ec_company.company_id(vendor.company_id) = t.company_id OR
                  ec_company.company_id(customer.company_id) = t.company_id)
             AND cp_financial_code IN ('PURCHASE', 'TA_COST')
             AND vendor.party_role = 'VENDOR'
             AND customer.party_role = 'CUSTOMER'
             AND customer.daytime <= cp_daytime
             AND nvl(customer.end_date, cp_daytime + 1) > cp_daytime
             AND vendor.daytime <= cp_daytime
             AND nvl(vendor.end_date, cp_daytime + 1) > cp_daytime
    ORDER BY comp_id --sorted by company id so companies come consecutivly
             ,match_level
             ,vendor_id
             ,object_code;

    lv2_company_id                 VARCHAR2(32);
    lv2_vendor_id                  VARCHAR2(32);
    lt_dist_info                   T_TABLE_COMPANY_DIST_INFO;
    lv2_prev_Company               VARCHAR2(32);
    lv2_prev_vendor                VARCHAR2(32);
    lv2_prev_company_ml            NUMBER;
    lv2_prev_si                    VARCHAR2(32);
    lv2_argument                   VARCHAR2(4000);
    lb_add_current_dist            BOOLEAN;

    e_too_many_stream_items        EXCEPTION;
    e_no_stream_item               EXCEPTION;
BEGIN
    lt_dist_info := T_TABLE_COMPANY_DIST_INFO();

    FOR i_dist IN c_dist_list(
                           p_common_param.daytime
                          ,p_common_param.financial_code
                          ,p_profit_center_id
                          ,p_common_param.product_id
                          ,p_common_param.contract_id
                          ,p_common_param.stream_id
                          ,p_common_param.uom_code
                          )
    LOOP
        lb_add_current_dist := TRUE;

        lv2_company_id := ec_stream_item_version.company_id(i_dist.split_member_id, p_common_param.daytime,'<=');
        lv2_vendor_id := i_dist.vendor_id;

        IF NOT p_skip_validation
        THEN
            IF nvl(lv2_prev_Company,'xx') = lv2_company_id
                AND p_common_param.financial_code in ('PURCHASE','TA_COST')
                AND nvl(lv2_prev_vendor,'xx') = lv2_vendor_id
                AND lv2_prev_company_ml = i_dist.Match_Level
            THEN
                lv2_argument := 'More than one stream item found having match on Field/Company/Vendor '
                                || ec_field_version.name(p_profit_center_id, p_common_param.daytime,'<=') || '/'
                                || ec_company_version.name(lv2_company_id,p_common_param.daytime,'<=')
                                ||' (' || lv2_prev_si || ' & ' || i_dist.object_code
                                || ').. Please adjust configuration.' || CHR(10)
                                || 'Current configuration:' || CHR(10);
                RAISE e_too_many_stream_items;

            ELSIF nvl(lv2_prev_Company,'xx') = lv2_company_id
                AND p_common_param.financial_code in ('SALE','TA_INCOME','JOU_ENT')
                AND lv2_prev_company_ml = i_dist.Match_Level
            THEN
                lv2_argument := 'More than one stream item found having match on Field/Company/Vendor '
                                || ec_field_version.name(p_profit_center_id,p_common_param.daytime,'<=') || '/'
                                || ec_company_version.name(lv2_company_id,p_common_param.daytime,'<=')
                                ||' (' || lv2_prev_si || ' & ' || i_dist.object_code
                                || ').. Please adjust configuration.' || CHR(10)
                                || 'Current configuration:' || CHR(10);
                RAISE e_too_many_stream_items;

            ELSIF nvl(lv2_prev_Company, lv2_company_id) <> lv2_company_id AND i_dist.Match_Level = 3 THEN
                lv2_argument := 'No stream item found having matching master uom on Field/Company '
                                || ec_field_version.name(p_profit_center_id,p_common_param.daytime,'<=') || '/'
                                || ec_company_version.name(lv2_company_id,p_common_param.daytime,'<=')
                                ||'. Please adjust configuration.' || CHR(10)
                                || 'Current configuration:' || CHR(10);
                RAISE e_no_stream_item;

            ELSIF nvl(lv2_prev_Company,'xx') = lv2_company_id AND lv2_prev_company_ml < i_dist.Match_Level THEN
                --match already found
                lb_add_current_dist := FALSE;
            END IF;
        END IF;

        IF lb_add_current_dist THEN
            lv2_prev_Company := lv2_company_id;
            lv2_prev_vendor := lv2_vendor_id;
            lv2_prev_company_ml := i_dist.Match_Level;
            lv2_prev_si := i_dist.object_code;

            lt_dist_info.EXTEND(1);
            lt_dist_info(lt_dist_info.LAST).STREAM_ITEM_ID   := i_dist.SPLIT_MEMBER_ID;
            lt_dist_info(lt_dist_info.LAST).STREAM_ITEM_CODE := i_dist.OBJECT_CODE;
            lt_dist_info(lt_dist_info.LAST).VENDOR_ID        := i_dist.VENDOR_ID;
            lt_dist_info(lt_dist_info.LAST).VENDOR_SHARE     := i_dist.VENDOR_SHARE;
            lt_dist_info(lt_dist_info.LAST).CUSTOMER_ID      := i_dist.CUST_ID;
            lt_dist_info(lt_dist_info.LAST).CUSTOMER_SHARE   := i_dist.CUSTOMER_SHARE;
            lt_dist_info(lt_dist_info.LAST).MATCH_LEVEL      := i_dist.MATCH_LEVEL;
        END IF;
    END LOOP;

    RETURN lt_dist_info;

EXCEPTION
    WHEN e_too_many_stream_items THEN
        Raise_Application_Error(-20000,lv2_argument);

    WHEN e_no_stream_item THEN
        Raise_Application_Error(-20000,lv2_argument);
END GetDistInfoRC_Company;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetDistObjectID(p_contract_composition             VARCHAR2
                        ,p_dist_object_code                 VARCHAR2
                        ,p_dist_object_type                 VARCHAR2
                        )
RETURN VARCHAR2
IS
    lv2_dist_object_id VARCHAR2(32);
BEGIN
    IF SUBSTR(p_contract_composition, 3) = 'SF' THEN
        lv2_dist_object_id := ecdp_objects.GetObjIDFromCode(p_dist_object_type, p_dist_object_code);
    ELSE
        lv2_dist_object_id := EC_OBJECT_LIST.object_id_by_uk(p_dist_object_code);
    END IF;

    RETURN lv2_dist_object_id;
END GetDistObjectID;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetDistObjectName
-- Description    : Resolves the name from the distribution object at transaction level
-- Using tables   : cont_transaction
-- Using functions: ecdp_contract_setup.getcontractcomposition, GetDistObjectID, ecdp_objects.getobjname
-- Behaviour      : Called from classes cont_line_item, cont_transaction_qty, trans_detail_*
-----------------------------------------------------------------------------------------------------------
FUNCTION GetDistObjectName(p_transaction_key VARCHAR2)
RETURN VARCHAR2
IS
--<EC-DOC>
    lv2_contract_comp  VARCHAR2(32);
    lrec_t             cont_transaction%rowtype;
    lv2_dist_id        VARCHAR2(32);
    lv2_dist_name      VARCHAR2(1000);
BEGIN
   lrec_t              := ec_cont_transaction.row_by_pk(p_transaction_key);
   lv2_contract_comp   := ecdp_contract_setup.getcontractcomposition(lrec_t.object_id,lrec_t.trans_template_id,lrec_t.daytime);
   lv2_dist_id         := GetDistObjectID(lv2_contract_comp,lrec_t.dist_code,lrec_t.dist_object_type);
   lv2_dist_name       := ecdp_objects.getobjname(lv2_dist_id,lrec_t.daytime);

    RETURN lv2_dist_name;
END GetDistObjectName;

------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetDistObjectTypeName(
                         p_transaction_key                  VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
IS
    lv2_dist_obj_name    VARCHAR2(1000);
BEGIN
    lv2_dist_obj_name := Ec_Class_Property_Cnfg.property_value(
        Ec_Cont_Transaction.dist_object_type(p_transaction_key),
        'LABEL', 'APPLICATION', 0, '/EC');

    RETURN lv2_dist_obj_name;
END GetDistObjectTypeName;

------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION FindPrecedingTransKeys(
                         p_document_key                     VARCHAR2
                        ,p_document_concept                 VARCHAR2
                        ,p_stream_item_id                   VARCHAR2
                        ,p_price_concept_code               VARCHAR2
                        ,p_product_id                       VARCHAR2
                        ,p_entry_point_id                   VARCHAR2
                        ,p_transaction_scope                VARCHAR2
                        ,p_transaction_type                 VARCHAR2
                        )
RETURN T_TABLE_MIXED_DATA
IS
    lt_transaction_keys T_TABLE_MIXED_DATA;
BEGIN
    lt_transaction_keys := T_TABLE_MIXED_DATA();

    FOR i_transaction IN ecdp_document.gc_transactions(
                              p_document_key
                             ,p_document_concept
                             ,p_stream_item_id
                             ,p_price_concept_code
                             ,p_product_id
                             ,p_entry_point_id
                             ,p_transaction_scope
                             ,p_transaction_type
                             )
    LOOP
        lt_transaction_keys.EXTEND(1);
        lt_transaction_keys(lt_transaction_keys.LAST) := T_MIXED_DATA(i_transaction.transaction_key, i_transaction.name);
    END LOOP;

    RETURN lt_transaction_keys;
END FindPrecedingTransKeys;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION FindPrecedingTransKeys(
                         p_transaction_key                  VARCHAR2
                        )
RETURN T_TABLE_MIXED_DATA
IS
    lrec_cont_transaction CONT_TRANSACTION%ROWTYPE;
    lrec_cont_document    CONT_DOCUMENT%ROWTYPE;
BEGIN
    lrec_cont_transaction := ec_cont_transaction.row_by_pk(p_transaction_key);
    lrec_cont_document := ec_cont_document.row_by_pk(lrec_cont_transaction.document_key);

    RETURN FindPrecedingTransKeys(
               lrec_cont_document.preceding_document_key
              ,ec_contract_doc_version.doc_concept_code(lrec_cont_document.contract_doc_id, lrec_cont_transaction.daytime, '<=')
              ,lrec_cont_transaction.stream_item_id
              ,lrec_cont_transaction.price_concept_code
              ,lrec_cont_transaction.product_id
              ,lrec_cont_transaction.entry_point_id
              ,lrec_cont_transaction.transaction_scope
              ,lrec_cont_transaction.transaction_type
              );
END FindPrecedingTransKeys;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : AutoPopulateDistSplit
-- Description    : Auto populate Profit Cetre and Vendor details.
-- Using tables   : SPLIT_KEY_SETUP.
-- Using functions: EcDp_Split_Key.InsNewChildSplitKey
-- Behaviour      : Called from Auto Populate Dist.Split button of Transaction Distribution Setup Screen.
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE AutoPopulateDistSplit( p_transaction_template_id VARCHAR2,
                                 p_daytime                 DATE)
IS
--<EC-DOC>

lv_dist_code                     VARCHAR2(240);
lv_dist_type                     VARCHAR2(32);
lv_dist_object_type              VARCHAR2(32);
lv_object_id                     VARCHAR2(32);
lv_split_key_id                  VARCHAR2(32);
lv2_contract_id                  VARCHAR2(32);
lv2_financial_code               VARCHAR2(32);
lv_child_split_key               VARCHAR2(32);
lv_skv_count                     NUMBER;
lt_pc_id_info                    ECDP_TRANSACTION.T_TABLE_PROFIT_CENTRE_ID;
lt_pc_vendor_dist_info           ECDP_TRANSACTION.T_TABLE_PC_VENDOR_ID;
lv_pc_count                      NUMBER;
lv_counter                       NUMBER;


CURSOR c_vendor_split (cp_split_key VARCHAR2) IS
SELECT sks1.child_split_key_id,COUNT(sks2.object_id) cnt FROM split_key_setup sks1,split_key_setup sks2
WHERE sks1.object_id=cp_split_key
AND sks1.child_split_key_id=sks2.object_id(+)
AND SKS1.daytime = p_daytime
GROUP BY (sks2.object_id,sks1.child_split_key_id);




BEGIN

     IF p_transaction_template_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20000, 'Transaction is not selected.');
     END IF;


     lv_dist_type:=ec_transaction_tmpl_version.dist_type(p_transaction_template_id,p_daytime,'<=');

     IF lv_dist_type IS NULL THEN
        RAISE_APPLICATION_ERROR(-20000, 'Distribution Type is not selected.');
     END IF;

     lv_dist_object_type:=ec_transaction_tmpl_version.dist_object_type(p_transaction_template_id,p_daytime,'<=');

     IF lv_dist_object_type IS NULL THEN
        RAISE_APPLICATION_ERROR(-20000, 'Distribution Object Type is not selected.');
     END IF;


     lv_dist_code:=ec_transaction_tmpl_version.dist_code(p_transaction_template_id,p_daytime, '<=');

     IF lv_dist_code IS NULL THEN
        RAISE_APPLICATION_ERROR(-20000, 'Distribution Object Code is not selected.');
     END IF;

     lv_split_key_id:=ec_transaction_tmpl_version.split_key_id(p_transaction_template_id,p_daytime, '<=');

     lv2_contract_id := ec_contract_doc.contract_id(ec_transaction_template.contract_doc_id(p_transaction_template_id));

     lv2_financial_code := ec_contract_version.financial_code(lv2_contract_id,p_daytime,'<=');


     SELECT COUNT(object_id) INTO lv_skv_count FROM Split_Key_Version WHERE OBJECT_ID=lv_split_key_id AND daytime=p_daytime;

     IF lv_skv_count=0 THEN
        INSERT INTO Split_Key_Version (OBJECT_ID,daytime)
        VALUES (lv_split_key_id,p_daytime);
     END IF;

      SELECT COUNT(object_id) INTO lv_pc_count FROM split_key_setup WHERE object_id=lv_split_key_id AND daytime = p_daytime;

     IF lv_pc_count = 0 THEN

        lt_pc_id_info:=ECDP_TRANSACTION.GetPCInfoRC(lv_dist_code,lv_dist_type,lv_dist_object_type, p_daytime);
        FOR pc_id IN lt_pc_id_info.FIRST..lt_pc_id_info.LAST
            LOOP
            BEGIN

                  BEGIN

                       INSERT INTO SPLIT_KEY_SETUP
                      (OBJECT_ID,split_member_id,CLASS_NAME,DAYTIME,PROFIT_CENTRE_ID,SPLIT_SHARE_DAY,SPLIT_SHARE_MTH)
                    VALUES
                      (
                        lv_split_key_id,
                       lt_pc_id_info(pc_id).PROFIT_CENTRE_ID,
                        'SPLIT_KEY_SETUP_SP',
                        p_daytime,
                        lt_pc_id_info(pc_id).PROFIT_CENTRE_ID,
                        lt_pc_id_info(pc_id).split_share,
                        lt_pc_id_info(pc_id).split_share
                      ) ;

                      EcDp_Split_Key.InsNewChildSplitKey(lv_split_key_id,
                     					 lt_pc_id_info(pc_id).PROFIT_CENTRE_ID,
                      					 'COMPANY','PERCENT', p_daytime);


                      lv_child_split_key:= EC_SPLIT_KEY_SETUP.child_split_key_id(lv_split_key_id ,
                                                                                 lt_pc_id_info(pc_id).PROFIT_CENTRE_ID,
                                                                                 p_daytime ,
                                                                                 '<=');
                     IF (UPPER(lv_dist_type)='OBJECT_LIST' AND  ecdp_object_list.VerifySplitShare(ec_object_list.object_id_by_uk(lv_dist_code),p_daytime)='N')  THEN


                         IF pc_id =1 THEN
                             UPDATE SPLIT_KEY_SETUP SET SPLIT_SHARE_DAY=1,SPLIT_SHARE_MTH=1
                             WHERE OBJECT_ID=lv_split_key_id
                             AND split_member_id=lt_pc_id_info(pc_id).PROFIT_CENTRE_ID
                             AND CLASS_NAME='SPLIT_KEY_SETUP_SP'
                             AND DAYTIME=p_daytime
                             AND PROFIT_CENTRE_ID=lt_pc_id_info(pc_id).PROFIT_CENTRE_ID;

                             ELSE
                                 UPDATE SPLIT_KEY_SETUP SET SPLIT_SHARE_DAY=0,SPLIT_SHARE_MTH=0
                             WHERE OBJECT_ID=lv_split_key_id
                             AND split_member_id=lt_pc_id_info(pc_id).PROFIT_CENTRE_ID
                             AND CLASS_NAME='SPLIT_KEY_SETUP_SP'
                             AND DAYTIME=p_daytime
                             AND PROFIT_CENTRE_ID=lt_pc_id_info(pc_id).PROFIT_CENTRE_ID;
                          END IF;
                      END IF;

                      EXCEPTION
                       WHEN OTHERS THEN
                       RAISE_APPLICATION_ERROR(-20000, 'Error while Auto populating Transaction Distribution. Deatils: '||SQLERRM);
                  END;


                  lt_pc_vendor_dist_info:=ECDP_TRANSACTION.GetPCInfoRC_Vendor(lv2_contract_id,p_daytime);
                  FOR c_vendor_id IN lt_pc_vendor_dist_info.FIRST..lt_pc_vendor_dist_info.LAST
                     LOOP
                      BEGIN


                           INSERT INTO SPLIT_KEY_SETUP
                           (OBJECT_ID,split_member_id,CLASS_NAME,DAYTIME,PROFIT_CENTRE_ID,SPLIT_SHARE_DAY,SPLIT_SHARE_MTH)
                         VALUES
                           (
                             lv_child_split_key ,
                             lt_pc_vendor_dist_info(c_vendor_id).company_id,
                             'SPLIT_KEY_SETUP_COMPANY',
                             p_daytime,
                             lt_pc_vendor_dist_info(c_vendor_id).company_id,
                             lt_pc_vendor_dist_info(c_vendor_id).party_share/100,
                             lt_pc_vendor_dist_info(c_vendor_id).party_share/100);

                      END;
                    END LOOP;
       END;
       END LOOP;

       ELSE
          lv_counter:=0;
          FOR c IN c_vendor_split(lv_split_key_id)
            LOOP
            IF c.cnt = 0 THEN
                  lt_pc_vendor_dist_info:=ECDP_TRANSACTION.GetPCInfoRC_Vendor(lv2_contract_id,p_daytime);
                  FOR c_vendor_id IN lt_pc_vendor_dist_info.FIRST..lt_pc_vendor_dist_info.LAST
                     LOOP
                      BEGIN


                           INSERT INTO SPLIT_KEY_SETUP
                           (OBJECT_ID,split_member_id,CLASS_NAME,DAYTIME,PROFIT_CENTRE_ID,SPLIT_SHARE_DAY,SPLIT_SHARE_MTH)
                           VALUES
                           (
                             c.child_split_key_id ,
                             lt_pc_vendor_dist_info(c_vendor_id).company_id,
                             'SPLIT_KEY_SETUP_COMPANY',
                             p_daytime,
                             lt_pc_vendor_dist_info(c_vendor_id).company_id,
                             lt_pc_vendor_dist_info(c_vendor_id).party_share/100,
                             lt_pc_vendor_dist_info(c_vendor_id).party_share/100);

                      END;
                    END LOOP;
              lv_counter:=lv_counter+1;
              END IF;
            END LOOP;

            IF lv_counter=0 THEN
             Raise_Application_Error(-20000,'Profit Centre and respective vendor splits already exist.' );
            END IF;

     END IF;


 END AutoPopulateDistSplit;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : DelTransactionDist
-- Description    : Deletes Profit Cetre and Vendor details.
-- Using tables   : SPLIT_KEY_SETUP.
-- Behaviour      : Called when USE Stream Item Config is set to Y in  Transaction Template Screen.
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE DelTransactionDist(p_transaction_template_id VARCHAR2,
                             p_daytime                 DATE)

--</EC-DOC>
IS
v_split_key_id VARCHAR2(32);

BEGIN
  v_split_key_id:=ec_transaction_tmpl_version.split_key_id(p_transaction_template_id,p_daytime, '<=');


  DELETE FROM SPLIT_KEY_SETUP sks
  WHERE object_id IN(SELECT  child_split_key_id
                     FROM SPLIT_KEY_SETUP
                     WHERE object_id=v_split_key_id);


  DELETE FROM SPLIT_KEY_SETUP WHERE object_id=v_split_key_id;

END DelTransactionDist;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetPCInfoRC(    p_dist_code                        VARCHAR2
                        ,p_dist_type                        VARCHAR2
                        ,p_dist_object_type                 VARCHAR2
                        ,p_daytime                          DATE
                        )

RETURN T_TABLE_PROFIT_CENTRE_ID
IS
      CURSOR C_PC (cp_dist_code VARCHAR2)IS
          SELECT v.object_id, ols.split_share
            FROM OBJECT_LIST ol,OBJECT_LIST_SETUP ols,IV_PROFIT_CENTRE v
           WHERE ol.object_code=cp_dist_code
             AND ol.object_id=ols.object_id
             AND v.code=ols.generic_object_code
             AND v.class_name=p_dist_object_type
             AND UPPER(p_dist_type)='OBJECT_LIST'
             AND ols.daytime <= p_daytime
             AND nvl(ols.end_date, p_daytime+1) > p_daytime
           UNION
          SELECT v.object_id, 100
            FROM IV_PROFIT_CENTRE v
           WHERE v.code=cp_dist_code
             AND v.class_name=p_dist_object_type
             AND UPPER(p_dist_type)='OBJECT'
             AND daytime <= p_daytime
             AND nvl(end_date, p_daytime+1) > p_daytime;

      lt_pc_dist_info                   T_TABLE_PROFIT_CENTRE_ID;
      lv_object_id                      VARCHAR2(32);
      ln_split_share                    NUMBER;
      lv_pc_count                       NUMBER;
      lb_obs_split_share_ind            ecdp_revn_common.T_BOOLEAN_STR;


BEGIN

  lt_pc_dist_info := T_TABLE_PROFIT_CENTRE_ID();
  lb_obs_split_share_ind := ecdp_object_list.VerifySplitShare(ec_object_list.object_id_by_uk(p_dist_code), p_daytime);
  OPEN C_PC(p_dist_code);
  LOOP
  FETCH C_PC INTO lv_object_id, ln_split_share;
  EXIT WHEN C_PC%NOTFOUND;
            lt_pc_dist_info.EXTEND(1);
            lt_pc_dist_info(lt_pc_dist_info.LAST).PROFIT_CENTRE_ID   := lv_object_id;
            lt_pc_dist_info(lt_pc_dist_info.last).SPLIT_SHARE        := NVL(ln_split_share,0)/100;
  END LOOP;
  CLOSE C_PC;

  RETURN lt_pc_dist_info;
END GetPCInfoRC;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetPCInfoRC_Vendor(p_contract_id                      VARCHAR2,
                            p_daytime                          DATE         )

RETURN T_TABLE_PC_VENDOR_ID
IS
      CURSOR c_Cont_share(cp_object_id VARCHAR2,cp_daytime DATE) IS
      SELECT company_id,party_share FROM contract_party_share
      WHERE object_id=cp_object_id
      AND party_role ='VENDOR'
      AND daytime <= cp_daytime
                        AND nvl(end_date,cp_daytime+1 ) > cp_daytime ;

      lt_vendor_dist_info               T_TABLE_PC_VENDOR_ID;
      lv_company_id                     VARCHAR2(32);
      lv_party_share                    NUMBER;


BEGIN
  lt_vendor_dist_info := T_TABLE_PC_VENDOR_ID();

  OPEN c_Cont_share(p_contract_id,p_daytime);
  LOOP
  FETCH c_Cont_share INTO lv_company_id,lv_party_share;
  EXIT WHEN c_Cont_share%NOTFOUND;
            lt_vendor_dist_info.EXTEND(1);
            lt_vendor_dist_info(lt_vendor_dist_info.LAST).company_id   := lv_company_id;
            lt_vendor_dist_info(lt_vendor_dist_info.LAST).party_share  := lv_party_share;
  END LOOP;
  CLOSE c_Cont_share;

  RETURN lt_vendor_dist_info;
END GetPCInfoRC_Vendor;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------

Procedure RoundDistLevel(p_transaction_key VARCHAR2) IS
  cursor cr_line_items is
     SELECT line_item_key
        FROM cont_line_item
      WHERE transaction_key = p_transaction_key;

BEGIN
      FOR li in cr_line_items LOOP
          ecdp_line_item.RoundDistLevel(li.line_item_key);
      END LOOP;
END RoundDistLevel;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
-- Procedure      : DeletePPATransactionTmpl
-- Description    : Deletes Transaction Template.
-- Using tables   : TRANSACTION_TEMPLATE.
-- Behaviour      : Called when Document Concept is set to 'PPA' in  Document Properties screen.
-------------------------------------------------------------------------------------------------------------------------------------------

Procedure DeletePPATransactionTmpl(p_object_id VARCHAR2) IS
BEGIN
      UPDATE TRANSACTION_TEMPLATE SET end_date=start_date WHERE contract_doc_id=p_object_id;
END DeletePPATransactionTmpl;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
-- FUNCTION       : GetLatestnGreatestTran
-- Description    : Get Latest and Grestest Transaction.
-- Behaviour      : When Dependent document is being created by interface,it will take NO-PPA and non-reversal document as preceding document key.
--                  This function will check for latest transaction.It will exclude transactions on reversal document and document reversed.
-------------------------------------------------------------------------------------------------------------------------------------------

FUNCTION GetLatestnGreatestTran(p_transaction_key                      VARCHAR2)
RETURN VARCHAR2 IS
CURSOR c_trans  IS
SELECT LEVEL priority,ct.transaction_key ,ct.preceding_trans_key ,ct.ppa_trans_code,cd.document_key,cd.actual_reversal_date
               FROM cont_transaction ct,cont_document cd
                WHERE ct.document_key = cd.document_key
                AND cd.document_concept != 'DEPENDENT_WITHOUT_REVERSAL'
               START WITH ct.transaction_key=p_transaction_key
               CONNECT BY prior ct.transaction_key=ct.preceding_trans_key
               ORDER BY LEVEL DESC;



lv_transaction_key VARCHAR2(32);
BEGIN
FOR res IN c_trans
  LOOP


    IF(res.actual_reversal_date IS NULL) THEN
    lv_transaction_key:=res.transaction_key;
    EXIT;

    END IF;

  END LOOP;

    RETURN NVL(lv_transaction_key,p_transaction_key);
END GetLatestnGreatestTran;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- PROCEDURE       : updContTransactionConsignee
-- Description    : Updates the Cont transaction consignee with the same customer as Cont_document
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------


PROCEDURE updContTransactionConsignee(
          p_document_key VARCHAR2,
          p_user VARCHAR2)
IS

	lv2_customer_id company.object_id%TYPE;
	lv2_customer     varchar2(240);

BEGIN

	lv2_customer_id := ec_cont_document.customer_id(p_document_key);
	lv2_customer := ec_company_version.name(lv2_customer_id,Ecdp_Timestamp.getCurrentSysdate,'<=');

	UPDATE cont_transaction c
	SET c.consignee     = lv2_customer,
	c.last_updated_by = p_user
	WHERE c.document_key = p_document_key ;

END updContTransactionConsignee;


------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION doc_key_from_trans_templ_id(
         p_trans_temp_id VARCHAR2)
RETURN CONT_TRANSACTION.Document_Key%TYPE IS
   v_document_key CONT_TRANSACTION.Document_Key%TYPE;
   CURSOR c_col_val IS
   SELECT DISTINCT(document_key) col
   FROM CONT_TRANSACTION c
   WHERE c.trans_template_id = p_trans_temp_id;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_document_key := cur_row.col;
   END LOOP;
   RETURN v_document_key;

END doc_key_from_trans_templ_id;
------------------------------------------------------------------------------------

PROCEDURE updTotPriceNotRounded(p_price_concept_code VARCHAR2,
                                p_contract_id VARCHAR2,
                                p_trans_key Varchar2)
IS
  CURSOR c_all_price IS
        SELECT nvl(ppv.ADJ_PRICE_VALUE, ppv.calc_price_value) as price_value
        FROM PRODUCT_PRICE_VALUE ppv, PRODUCT_PRICE pp
        WHERE ppv.price_concept_code = p_price_concept_code AND
              ppv.object_id = pp.object_id AND
              pp.contract_id = p_contract_id AND
              pp.object_id = ec_cont_transaction.price_object_id(p_trans_key);

  lv2_tot_price NUMBER := 0;
  lv2_transaction_id Varchar2(32);

BEGIN
  -- sum total price for all price element under single price concept
  lv2_tot_price := 0;
   FOR cur_row IN c_all_price LOOP
      lv2_tot_price := lv2_tot_price + cur_row.price_value;
   END LOOP;

   -- update total price in CONT_TRANSACTION table
   UPDATE CONT_TRANSACTION
   SET TOT_PRICE_NOT_ROUNDED = lv2_tot_price
   WHERE TRANSACTION_KEY = p_trans_key; --Transaction_key

END updTotPriceNotRounded;

------------------------+-----------------------------------+------------------------------------+---------------------------


FUNCTION TransactionLevelVatCode(p_transaction_key VARCHAR2) RETURN VARCHAR2
  IS
  lv_return varchar2(32) DEFAULT 'MULTIPLE';
  CURSOR distcodes is
  select distinct VAT_CODE
   FROM CONT_LINE_ITEM WHERE TRANSACTION_KEY = p_transaction_key;

   ln_count number :=0;
BEGIN

   FOR vat in distcodes loop
     IF ln_count > 0 THEN
       lv_return :=  'MULTIPLE';
       EXIT;
     ELSE
       lv_return :=  VAT.VAT_CODE;
     END IF;
     ln_count := ln_count+1;
   END LOOP;


  RETURN lv_return;
end  TransactionLevelVatCode;


------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------


FUNCTION TransactionLevelVatRate(p_transaction_key VARCHAR2) RETURN NUMBER
    IS
  lv_return NUMBER;

  CURSOR distcodes is
  select distinct VAT_RATE
   FROM CONT_LINE_ITEM WHERE TRANSACTION_KEY = p_transaction_key;

   ln_count number :=0;

BEGIN

   FOR vat in distcodes loop
     IF ln_count > 0 THEN
       lv_return :=  NULL;
       EXIT;
     ELSE
       lv_return :=  VAT.VAT_RATE;

     END IF;

     ln_count := ln_count+1;
   END LOOP;

  RETURN lv_return;
end  TransactionLevelVatRate;

FUNCTION GetPricingBookingLabel(p_document_key      VARCHAR2,
                                p_daytime           DATE,
                                p_trans_template_id VARCHAR2)
  RETURN VARCHAR2 IS
  lv_booking_currency_id       cont_document.booking_currency_id%TYPE;
  lv_pricing_currency_id       TRANSACTION_TMPL_VERSION.Pricing_Currency_Id%TYPE;
  lv_pricing_currency_name     currency_version.name%TYPE;
  lv_booking_currency_name     currency_version.name%TYPE;
  lv_get_pricing_booking_label VARCHAR2(4000);

BEGIN

  lv_pricing_currency_id   := ec_transaction_tmpl_version.pricing_currency_id(p_trans_template_id,
                                                                              p_daytime,
                                                                              '<=');
  lv_pricing_currency_name := ec_currency_version.name(lv_pricing_currency_id,
                                                       p_daytime,
                                                       '<=');
  lv_booking_currency_id   := ec_cont_document.booking_currency_id(p_document_key);
  lv_booking_currency_name := ec_currency_version.name(lv_booking_currency_id,
                                                       p_daytime,
                                                       '<=');

  IF lv_booking_currency_name is NULL THEN
    lv_get_pricing_booking_label := NULL;
  ELSE
    lv_get_pricing_booking_label := 'Pricing (' || lv_pricing_currency_name || ')' ||
                                    ' to Booking (' ||
                                    lv_booking_currency_name || ')';
  END IF;
  RETURN lv_get_pricing_booking_label;
END GetPricingBookingLabel;
------------------------+-----------------------------------+------------------------------------+---------------------------

FUNCTION GetPricingMemoLabel(p_document_key      VARCHAR2,
                             p_daytime           DATE,
                             p_trans_template_id VARCHAR2) RETURN VARCHAR2 IS
  lv_memo_currency_id       cont_document.memo_currency_id%TYPE;
  lv_memo_currency_name     currency_version.name%TYPE;
  lv_pricing_currency_id    TRANSACTION_TMPL_VERSION.Pricing_Currency_Id%TYPE;
  lv_pricing_currency_name  currency_version.name%TYPE;
  lv_get_pricing_memo_label VARCHAR2(4000);

BEGIN

  lv_pricing_currency_id   := ec_transaction_tmpl_version.pricing_currency_id(p_trans_template_id,
                                                                              p_daytime,
                                                                              '<=');
  lv_pricing_currency_name := ec_currency_version.name(lv_pricing_currency_id,
                                                       p_daytime,
                                                       '<=');
  lv_memo_currency_id      := ec_cont_document.memo_currency_id(p_document_key);
  lv_memo_currency_name    := ec_currency_version.name(lv_memo_currency_id,
                                                       p_daytime,
                                                       '<=');

  IF lv_memo_currency_name is NULL THEN
    lv_get_pricing_memo_label := NULL;
  ELSE
    lv_get_pricing_memo_label := 'Pricing (' || lv_pricing_currency_name || ')' ||
                                 ' to Memo (' || lv_memo_currency_name || ')';
  END IF;

  RETURN lv_get_pricing_memo_label;

END GetPricingMemoLabel;
------------------------+-----------------------------------+------------------------------------+---------------------------

FUNCTION GetBookingLocalLabel(p_document_key    VARCHAR2,
                              p_daytime         DATE) RETURN VARCHAR2 IS
  lv_booking_currency_id     cont_document.booking_currency_id%TYPE;
  lv_booking_currency_name   currency_version.name%TYPE;
  lv_owner_company_id        CONT_DOCUMENT.OWNER_COMPANY_ID%TYPE;
  lv_local_currency_id       COMPANY_VERSION.LOCAL_CURRENCY_ID%TYPE;
  lv_local_currency_name     currency_version.name%TYPE;
  lv_get_booking_local_label VARCHAR2(4000);

BEGIN
  lv_booking_currency_id   := ec_cont_document.booking_currency_id(p_document_key);
  lv_booking_currency_name := ec_currency_version.name(lv_booking_currency_id,
                                                       p_daytime,
                                                       '<=');
  lv_owner_company_id      := ec_cont_document.owner_company_id(p_document_key);
  lv_local_currency_id     := ec_company_version.local_currency_id(lv_owner_company_id,
                                                                   p_daytime,
                                                                   '<=');
  lv_local_currency_name   := ec_currency_version.name(lv_local_currency_id,
                                                       p_daytime,
                                                       '<=');
  IF lv_local_currency_name IS NULL THEN
    lv_get_booking_local_label := NULL;
  ELSE
    lv_get_booking_local_label := 'Booking (' || lv_booking_currency_name || ')' ||
                                  ' to Local (' || lv_local_currency_name || ')';
  END IF;
  RETURN lv_get_booking_local_label;

END GetBookingLocalLabel;
------------------------+-----------------------------------+------------------------------------+---------------------------

FUNCTION GetBookingGroupLabel(p_document_key    VARCHAR2,
                              p_daytime         DATE) RETURN VARCHAR2 IS
  lv_booking_currency_id     cont_document.booking_currency_id%TYPE;
  lv_booking_currency_name   currency_version.name%TYPE;
  lv_group_currency_code     currency.object_code%TYPE;
  lv_group_currency_id       cont_document.memo_currency_id%TYPE;
  lv_group_currency_name     currency_version.name%TYPE;
  lv_get_booking_group_label VARCHAR2(4000);
  invalid_currency EXCEPTION;

BEGIN
  lv_booking_currency_id   := ec_cont_document.booking_currency_id(p_document_key);
  lv_booking_currency_name := ec_currency_version.name(lv_booking_currency_id,
                                                       p_daytime,
                                                       '<=');
  lv_group_currency_code   := ec_ctrl_system_attribute.attribute_text(P_DAYTIME,
                                                                      'GROUP_CURRENCY_CODE',
                                                                      '<=');
  IF lv_group_currency_code IS NULL THEN
    lv_get_booking_group_label := null;
  ELSE
    lv_group_currency_id := ecdp_objects.GetObjIDFromCode('CURRENCY',
                                                          lv_group_currency_code);

    IF lv_group_currency_id IS NULL THEN
      RAISE invalid_currency;
    END IF;

    lv_group_currency_name := ec_currency_version.name(lv_group_currency_id,
                                                       p_daytime,
                                                       '<=');

    IF lv_group_currency_name IS NULL THEN
      lv_get_booking_group_label := NULL;
    ELSE
      lv_get_booking_group_label := 'Booking (' || lv_booking_currency_name || ')' ||
                                    ' to Group (' || lv_group_currency_name || ')';
    END IF;
  END IF;
  RETURN lv_get_booking_group_label;

EXCEPTION
  WHEN invalid_currency THEN

    Raise_Application_Error(-20000,
                            'The currency defined as Group Currency - ' ||
                            lv_group_currency_code ||
                            '- in System Attribute GROUP_CURRENCY_CODE is not a valid currency code');
END GetBookingGroupLabel;
------------------------+-----------------------------------+------------------------------------+---------------------------
FUNCTION GetPricingBookingCode(p_document_key      VARCHAR2,
                               p_daytime           DATE,
                               p_trans_template_id VARCHAR2)
  RETURN VARCHAR2 IS
  lv_booking_currency_id   cont_document.booking_currency_id%TYPE;
  lv_pricing_currency_id   transaction_tmpl_version.pricing_currency_id%TYPE;
  lv_pricing_currency_name currency_version.name%TYPE;
  lv_booking_currency_name currency_version.name%TYPE;
  lv_GetPricingBookingCode VARCHAR2(4000);

BEGIN

  lv_pricing_currency_id   := ec_transaction_tmpl_version.pricing_currency_id(p_trans_template_id,
                                                                              p_daytime,
                                                                              '<=');
  lv_pricing_currency_name := ec_currency_version.name(lv_pricing_currency_id,
                                                       p_daytime,
                                                       '<=');
  lv_booking_currency_id   := ec_cont_document.booking_currency_id(p_document_key);
  lv_booking_currency_name := ec_currency_version.name(lv_booking_currency_id,
                                                       p_daytime,
                                                       '<=');
  IF lv_booking_currency_name is NULL THEN
    lv_GetPricingBookingCode := NULL;
  ELSE
    lv_GetPricingBookingCode := lv_pricing_currency_name || ' to ' ||
                                lv_booking_currency_name;
  END IF;
  RETURN lv_GetPricingBookingCode;
END GetPricingBookingCode;
------------------------+-----------------------------------+------------------------------------+---------------------------

FUNCTION GetPricingMemoCode(p_document_key      VARCHAR2,
                            p_daytime           DATE,
                            p_trans_template_id VARCHAR2) RETURN VARCHAR2 IS
  lv_pricing_currency_id   transaction_tmpl_version.pricing_currency_id%TYPE;
  lv_memo_currency_id      cont_document.memo_currency_id%TYPE;
  lv_pricing_currency_name currency_version.name%TYPE;
  lv_memo_currency_name    currency_version.name%TYPE;
  lv_get_pricing_memo_code VARCHAR2(4000);

BEGIN

  lv_pricing_currency_id   := ec_transaction_tmpl_version.pricing_currency_id(p_trans_template_id,
                                                                              p_daytime,
                                                                              '<=');
  lv_pricing_currency_name := ec_currency_version.name(lv_pricing_currency_id,
                                                       p_daytime,
                                                       '<=');

  lv_memo_currency_id   := ec_cont_document.memo_currency_id(p_document_key);
  lv_memo_currency_name := ec_currency_version.name(lv_memo_currency_id,
                                                    p_daytime,
                                                    '<=');

  IF lv_memo_currency_name IS NULL THEN
    lv_get_pricing_memo_code := NULL;
  ELSE
    lv_get_pricing_memo_code := lv_pricing_currency_name || ' to ' ||
                                lv_memo_currency_name;
  END IF;

  RETURN lv_get_pricing_memo_code;

END GetPricingMemoCode;
------------------------+-----------------------------------+------------------------------------+---------------------------

FUNCTION GetBookingLocalCode(p_document_key    VARCHAR2,
                             p_daytime         DATE) RETURN VARCHAR2 IS
  lv_booking_currency_id    cont_document.booking_currency_id%TYPE;
  lv_booking_currency_name  currency_version.name%TYPE;
  lv_owner_company_id       cont_document.owner_company_id%TYPE;
  lv_local_currency_id      company_version.local_currency_id%TYPE;
  lv_local_currency_name    currency_version.name%TYPE;
  lv_get_booking_local_code VARCHAR2(4000);

BEGIN
  lv_booking_currency_id   := ec_cont_document.booking_currency_id(p_document_key);
  lv_booking_currency_name := ec_currency_version.name(lv_booking_currency_id,
                                                       p_daytime,
                                                       '<=');
  lv_owner_company_id      := ec_cont_document.owner_company_id(p_document_key);
  lv_local_currency_id     := EC_COMPANY_VERSION.local_currency_id(lv_owner_company_id,
                                                                   p_daytime,
                                                                   '<=');
  lv_local_currency_name   := ec_currency_version.name(lv_local_currency_id,
                                                       p_daytime,
                                                       '<=');
  IF lv_local_currency_name IS NULL THEN
    lv_get_booking_local_code := NULL;
  ELSE
    lv_get_booking_local_code := lv_booking_currency_name || ' to ' ||
                                 lv_local_currency_name;
  END IF;

  RETURN lv_get_booking_local_code;

END GetBookingLocalCode;
------------------------+-----------------------------------+------------------------------------+---------------------------

FUNCTION GetBookingGroupCode(p_document_key    VARCHAR2,
                             p_daytime         DATE) RETURN VARCHAR2 IS
  lv_booking_currency_id    cont_document.booking_currency_id%TYPE;
  lv_booking_currency_name  currency_version.name%TYPE;
  lv_group_currency_code    currency.object_code%TYPE;
  lv_group_currency_id      cont_document.memo_currency_id%TYPE;
  lv_group_currency_name    currency_version.name%TYPE;
  lv_get_booking_group_code VARCHAR2(4000);
  invalid_currency EXCEPTION;

BEGIN
  lv_booking_currency_id   := ec_cont_document.booking_currency_id(p_document_key);
  lv_booking_currency_name := ec_currency_version.name(lv_booking_currency_id,
                                                       p_daytime,
                                                       '<=');
  lv_group_currency_code   := ec_ctrl_system_attribute.attribute_text(P_DAYTIME,
                                                                      'GROUP_CURRENCY_CODE',
                                                                      '<=');
  IF lv_group_currency_code IS NULL THEN
    lv_get_booking_group_code := NULL;
  ELSE
    lv_group_currency_id := ecdp_objects.GetObjIDFromCode('CURRENCY',
                                                          lv_group_currency_code);

    IF lv_group_currency_id IS NULL THEN
      RAISE invalid_currency;
    END IF;

    lv_group_currency_name := ec_currency_version.name(lv_group_currency_id,
                                                       p_daytime,
                                                       '<=');

    IF lv_group_currency_name IS NULL THEN
      lv_get_booking_group_code := NULL;
    ELSE
      lv_get_booking_group_code := lv_booking_currency_name || ' to ' ||
                                   lv_group_currency_name;
    END IF;
  END IF;

  RETURN lv_get_booking_group_code;
EXCEPTION
  WHEN invalid_currency THEN
    Raise_Application_Error(-20000,
                            'The currency defined as Group Currency - ' ||
                            lv_group_currency_code ||
                            '- in System Attribute GROUP_CURRENCY_CODE is not a valid currency code');
END GetBookingGroupCode;

END Ecdp_Transaction;