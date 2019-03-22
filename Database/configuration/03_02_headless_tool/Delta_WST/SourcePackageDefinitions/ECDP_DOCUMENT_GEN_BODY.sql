CREATE OR REPLACE PACKAGE BODY EcDp_Document_Gen IS
/****************************************************************
** Package        :  EcDp_Document_Gen, body part
**
** $Revision: 1.189 $
**
** Purpose        :  Provide special functions on Cargo and Period based Document Generation.
**
** Documentation  :  www.energy-components.com
**
** Created        : 24.05.2007 Dagfinn Rosnes
*****************************************************************/

    -----------------------------------------------------------------------
    -- Prepares interface data for processing period document.
    ----+----------------------------------+-------------------------------
    PROCEDURE prepare_ifac_period_p(
        p_context                          in out NOCOPY t_revn_doc_op_context
       ,p_contract_id                      IN VARCHAR2
       ,p_document_setup_id                IN VARCHAR2
       ,p_processing_period                IN DATE
       ,p_customer_id                      IN VARCHAR2
       ,p_document_status                  IN VARCHAR2
       )
    IS
        l_ifac                             t_table_ifac_sales_qty;
        l_logger                           t_revn_logger;
    BEGIN
        p_context.get_or_create_logger(l_logger);
        l_logger.debug('Querying interface data...');

        -- get all interface data for the processing document,
        -- with proper sorting
        l_ifac := ecdp_revn_ifac_wrapper_period.GetIfacForDocument(
           p_contract_id, p_document_setup_id, p_processing_period, p_customer_id, p_document_status);

        l_ifac := ecdp_revn_ifac_wrapper_period.sort(l_ifac, 'qty_status', '''PROV'',3,''FINAL'',2,''PPA'',1,0');
        p_context.ifac_period := l_ifac;

        l_logger.debug(l_ifac.count || ' records found.');
    END;

    -----------------------------------------------------------------------
    -- Prepares interface data for processing cargo document.
    ----+----------------------------------+-------------------------------
    PROCEDURE prepare_ifac_cargo_p(
        p_context                          in out NOCOPY t_revn_doc_op_context
       ,p_contract_id                      in VARCHAR2
       ,p_document_setup_id                in VARCHAR2
       ,p_cargo_no                         VARCHAR2
       ,p_parcel_no                        VARCHAR2
       ,p_customer_id                      in VARCHAR2
       ,p_point_of_sale_date               IN DATE
       )
    IS
        l_ifac                             t_table_ifac_cargo_value;
        l_logger                           t_revn_logger;
    BEGIN
        p_context.get_or_create_logger(l_logger);
        l_logger.debug('Querying interface data...');

        -- get all interface data for the processing document,
        -- with proper sorting
        l_ifac := ecdp_revn_ifac_wrapper_cargo.GetIfacForDocument(
           p_contract_id, p_cargo_no, p_parcel_no, p_point_of_sale_date, p_document_setup_id, p_customer_id);

        p_context.ifac_cargo := l_ifac;

        l_logger.debug(l_ifac.count || ' records found.');
    END;

    -----------------------------------------------------------------------
    -- Prepares interface data for updating an existing document from ifac.
    ----+----------------------------------+-------------------------------
    PROCEDURE prepare_ifac_for_doc_upd_p(
        p_context                          IN OUT NOCOPY t_revn_doc_op_context
       ,p_document_info                    IN OUT NOCOPY t_revn_ft_doc_info
       )
    IS
    BEGIN
        CASE p_document_info.contract_group
            WHEN ecdp_revn_ft_constants.cont_gup_ALL THEN
                prepare_ifac_period_p(
                    p_context, p_document_info.contract_id, p_document_info.template_id,
                    p_document_info.processing_period, p_document_info.customer_id, p_document_info.status);
                prepare_ifac_cargo_p(
                    p_context, p_document_info.contract_id, p_document_info.template_id,
                    p_context.processing_cargo_name, '',
                    p_document_info.customer_id, p_document_info.daytime);
            WHEN ecdp_revn_ft_constants.cont_gup_ALL_CARGO THEN
                prepare_ifac_cargo_p(
                    p_context, p_document_info.contract_id, p_document_info.template_id,
                    p_context.processing_cargo_name, '',
                    p_document_info.customer_id, p_document_info.daytime);
            WHEN ecdp_revn_ft_constants.cont_gup_ALL_PERIOD THEN
                prepare_ifac_period_p(
                    p_context, p_document_info.contract_id, p_document_info.template_id,
                    p_document_info.processing_period, p_document_info.customer_id, p_document_info.status);
            ELSE
                NULL;
        END CASE;
    END;


    -----------------------------------------------------------------------
    -- Finds preceding keys from given ifac record.
    ----+----------------------------------+-------------------------------
    PROCEDURE find_preceding_keys_p(
        p_ifac_rec                         in out NOCOPY T_IFAC_SALES_QTY
       ,p_preceding_document_key           OUT cont_document.document_key%TYPE
       ,p_preceding_trans_key              out cont_transaction.transaction_key%TYPE
       ,p_preceding_li_key                 out cont_line_item.line_item_key%TYPE
       )
    IS
    BEGIN
        p_preceding_li_key := ecdp_document_gen_util.find_preceding_li_i(p_ifac_rec);

        IF p_preceding_li_key IS NOT NULL THEN
            p_preceding_trans_key := ec_cont_line_item.transaction_key(p_preceding_li_key);
        ELSE
            p_preceding_trans_key := ecdp_document_gen_util.GetIfacPrecedingTransKey(p_ifac_rec);
        END IF;

        p_preceding_document_key := ec_cont_transaction.document_key(p_preceding_trans_key);
    END;
  -----------------------------------------------------------------------
    -- Finds preceding keys from given ifac record.
    ----+----------------------------------+-------------------------------
    PROCEDURE find_preceding_keys_p(
        p_ifac_rec                         in out NOCOPY T_IFAC_CARGO_VALUE
       ,p_preceding_document_key           OUT cont_document.document_key%TYPE
       ,p_preceding_trans_key              out cont_transaction.transaction_key%TYPE
       ,p_preceding_li_key                 out cont_line_item.line_item_key%TYPE
       )
    IS
    BEGIN
        p_preceding_li_key := ecdp_document_gen_util.find_preceding_li_i(p_ifac_rec);

        IF p_preceding_li_key IS NOT NULL THEN
            p_preceding_trans_key := ec_cont_line_item.transaction_key(p_preceding_li_key);
        ELSE
            p_preceding_trans_key := ecdp_document_gen_util.GetIfacPrecedingTransKey(p_ifac_rec);
        END IF;

        p_preceding_document_key := ec_cont_transaction.document_key(p_preceding_trans_key);
    END;


    -----------------------------------------------------------------------
    -- Gets a value indicating whether the given ifac records has been
    -- processed.
    ----+----------------------------------+-------------------------------
    FUNCTION get_is_ifac_processed_p(
        p_ifac_rec                         IN OUT NOCOPY t_ifac_sales_qty
    )
    RETURN BOOLEAN
    IS
    BEGIN
        RETURN p_ifac_rec.line_item_key IS NOT NULL;
    END;

   -----------------------------------------------------------------------
    -- Gets a value indicating whether the given ifac records has been
    -- processed.
    ----+----------------------------------+-------------------------------
    FUNCTION get_is_ifac_processed_p(
        p_ifac_rec                         IN OUT NOCOPY t_ifac_cargo_value
    )
    RETURN BOOLEAN
    IS
    BEGIN
        RETURN p_ifac_rec.line_item_key IS NOT NULL;
    END;


    -----------------------------------------------------------------------
    -- Refreshes preceding keys on ifac records.
    ----+----------------------------------+-------------------------------
    procedure refresh_prec_keys_period_p(
        p_skip_processed_ifac              BOOLEAN
       ,p_context                          IN OUT NOCOPY t_revn_doc_op_context
    )
    IS
        l_ifac_rec                         T_IFAC_SALES_QTY;
        l_preceding_document_key           cont_document.document_key%TYPE;
        l_preceding_li_key                 cont_line_item.line_item_key%TYPE;
        l_preceding_trans_key              cont_transaction.transaction_key%TYPE;
        l_logger                           t_revn_logger;
    BEGIN
        IF p_context.is_empty_period_ifac_data THEN
            RETURN;
        END IF;

        p_context.get_or_create_logger(l_logger);

        FOR idx IN p_context.ifac_period_first..p_context.ifac_period_last LOOP
            l_ifac_rec := p_context.get_ifac_period(idx);
            IF l_ifac_rec.interface_level != ecdp_revn_ifac_wrapper.gconst_level_line_item THEN
                CONTINUE;
            END IF;

            IF p_skip_processed_ifac AND get_is_ifac_processed_p(l_ifac_rec) THEN
                CONTINUE;
            END IF;

            find_preceding_keys_p(
                l_ifac_rec, l_preceding_document_key, l_preceding_trans_key, l_preceding_li_key);

            p_context.update_ifac_prec_keys_period(
                    l_ifac_rec.trans_id, l_preceding_document_key, l_preceding_trans_key, l_ifac_rec.li_id, l_preceding_li_key);

            if l_ifac_rec.Source_Entry_No IS NOT NULL THEN
                l_logger.debug('Ifac record: ' || l_ifac_rec.Source_Entry_No || ' is originally referenced with preceding transaction: ' || l_ifac_rec.Preceding_Trans_Key);

                IF l_preceding_trans_key IS NOT NULL THEN
                    l_logger.debug('Ifac record: ' || l_ifac_rec.Source_Entry_No || ' - found preceding trans: [' || l_preceding_trans_key || ']');
                ELSE
                    l_logger.debug('No preceding transaction found for ifac record: ' || l_ifac_rec.Source_Entry_No);
                END IF;
            END IF;
        END LOOP;
    END;


    -----------------------------------------------------------------------
    -- Refreshes preceding keys on ifac records.
    ----+----------------------------------+-------------------------------
    procedure refresh_prec_keys_cargo_p(
        p_skip_processed_ifac              BOOLEAN
       ,p_context                          IN OUT NOCOPY t_revn_doc_op_context
    )
    IS
        l_ifac_rec                         T_IFAC_CARGO_VALUE;
        l_preceding_document_key           cont_document.document_key%TYPE;
        l_preceding_li_key                 cont_line_item.line_item_key%TYPE;
        l_preceding_trans_key              cont_transaction.transaction_key%TYPE;
        l_logger                           t_revn_logger;
    BEGIN
        IF p_context.is_empty_cargo_ifac_data THEN
            RETURN;
        END IF;

        p_context.get_or_create_logger(l_logger);

        FOR idx IN p_context.ifac_cargo_first..p_context.ifac_cargo_last LOOP
            l_ifac_rec := p_context.get_ifac_cargo(idx);
            IF l_ifac_rec.interface_level != ecdp_revn_ifac_wrapper.gconst_level_line_item THEN
                CONTINUE;
            END IF;

            IF p_skip_processed_ifac AND get_is_ifac_processed_p(l_ifac_rec) THEN
                CONTINUE;
            END IF;

            find_preceding_keys_p(
                l_ifac_rec, l_preceding_document_key, l_preceding_trans_key, l_preceding_li_key);

            p_context.update_ifac_prec_keys_cargo(
                    l_ifac_rec.trans_id, l_preceding_document_key, l_preceding_trans_key, l_ifac_rec.li_id, l_preceding_li_key);

            if l_ifac_rec.Source_Entry_No IS NOT NULL THEN
                l_logger.debug('Ifac record: ' || l_ifac_rec.Source_Entry_No || ' is originally referenced with preceding transaction: ' || l_preceding_trans_key);

                IF l_preceding_trans_key IS NOT NULL THEN
                    l_logger.debug('Ifac record: ' || l_ifac_rec.Source_Entry_No || ' - found preceding trans: [' || l_preceding_trans_key || ']');
                ELSE
                    l_logger.debug('No preceding transaction found for ifac record: ' || l_ifac_rec.Source_Entry_No);
                END IF;
            END IF;
        END LOOP;
    END;

    -----------------------------------------------------------------------
    -- Sets preceding keys as keys on ifac records, where preceding document
    -- key matches the given one.
    ----+----------------------------------+-------------------------------
    PROCEDURE set_prec_keys_as_keys_period_p(
        p_when_preceding_doc_key           cont_document.document_key%TYPE
       ,p_context                          IN OUT NOCOPY t_revn_doc_op_context
       ,p_skip_processed_ifac              BOOLEAN
    )
    IS
        l_ifac_rec                         T_IFAC_SALES_QTY;
    BEGIN
        IF p_context.is_empty_period_ifac_data THEN
            RETURN;
        END IF;

        FOR idx IN p_context.ifac_period_first..p_context.ifac_period_last LOOP
            l_ifac_rec := p_context.get_ifac_period(idx);
            IF l_ifac_rec.interface_level != ecdp_revn_ifac_wrapper.gconst_level_line_item THEN
                CONTINUE;
            END IF;

            IF p_skip_processed_ifac AND get_is_ifac_processed_p(l_ifac_rec) THEN
                CONTINUE;
            END IF;

            IF l_ifac_rec.preceding_doc_key = p_when_preceding_doc_key THEN
                p_context.update_ifac_keys_period(
                    l_ifac_rec.trans_id, l_ifac_rec.preceding_doc_key, l_ifac_rec.preceding_trans_key, l_ifac_rec.li_id, l_ifac_rec.preceding_li_key);
            END IF;
        END LOOP;
    END;


    -----------------------------------------------------------------------
    -- Sets preceding keys as keys on ifac records, where preceding document
    -- key matches the given one.
    ----+----------------------------------+-------------------------------
    PROCEDURE set_prec_keys_as_keys_cargo_p(
        p_when_preceding_doc_key           cont_document.document_key%TYPE
       ,p_context                          IN OUT NOCOPY t_revn_doc_op_context
       ,p_skip_processed_ifac              BOOLEAN
    )
    IS
        l_ifac_rec                         T_IFAC_CARGO_VALUE;
    BEGIN
        IF p_context.is_empty_cargo_ifac_data THEN
            RETURN;
        END IF;

        FOR idx IN p_context.ifac_cargo_first..p_context.ifac_Cargo_last LOOP
            l_ifac_rec := p_context.get_ifac_cargo(idx);
            IF l_ifac_rec.interface_level != ecdp_revn_ifac_wrapper.gconst_level_line_item THEN
                CONTINUE;
            END IF;

            IF p_skip_processed_ifac AND get_is_ifac_processed_p(l_ifac_rec) THEN
                CONTINUE;
            END IF;

            IF l_ifac_rec.preceding_doc_key = p_when_preceding_doc_key THEN
                p_context.update_ifac_keys_cargo(
                    l_ifac_rec.trans_id, l_ifac_rec.preceding_doc_key, l_ifac_rec.preceding_trans_key, l_ifac_rec.li_id, l_ifac_rec.preceding_li_key);
            END IF;
        END LOOP;
    END;

    -----------------------------------------------------------------------
    -- Generates line items from ifac (given in context). This procedure is for period-based transactions.
    --
    -- p_user: the id of user triggered this action.
    -- p_context: the operation context.
    -- p_for_transaction: the key of transaction to generate lines for. If null is given, all line
    --   items in ifac will be generated.
    ----+----------------------------------+-------------------------------
    PROCEDURE gen_li_f_ifac_period_p(
        p_context                          in out nocopy t_revn_doc_op_context
       ,p_document_info                    IN OUT NOCOPY t_revn_ft_doc_info
       ,p_for_transaction                  VARCHAR2 DEFAULT NULL
    )
    IS
        lo_ifac	                           t_ifac_sales_qty;
        lo_qty_keys                        t_table_varchar2;
        lo_processed_trans_idx             t_table_number;
        lv_line_item_key                   cont_line_item.line_item_key%TYPE;
        l_logger                           t_revn_logger;
    BEGIN
        IF p_context.is_empty_period_ifac_data THEN
            RETURN;
        END IF;

        p_context.get_or_create_logger(l_logger);

        FOR idx IN p_context.ifac_period_first..p_context.ifac_period_last LOOP
            lo_ifac := p_context.ifac_period(idx);

            -- skip non-line-item-level records
            IF lo_ifac.INTERFACE_LEVEL <> ecdp_revn_ifac_wrapper.gconst_level_line_item THEN
                continue;
            END IF;

            -- skip ones that have line item generated and belongs to other transactions
            IF lo_ifac.line_item_key IS NOT NULL
                OR NOT ecdp_revn_common.Equals(p_for_transaction, lo_ifac.transaction_key, TRUE) THEN
                continue;
            END IF;

            -- skip generating quantity line item that has already been generated
            IF NVL(lo_ifac.line_item_based_type, 'QTY') = 'QTY' THEN
                lo_qty_keys := ecdp_transaction.get_qty_li_keys(lo_ifac.transaction_key);
                IF lo_qty_keys.count > 0 THEN
                    -- TODO: any validation required?
                    -- apply the line item key
                    lv_line_item_key := lo_qty_keys(1);
                    l_logger.debug('Found line item ' || lv_line_item_key || ' for interfaced quantity.');
                ELSE
                    l_logger.debug('No line item found for interfaced quantity, this interface will be ignored.');
                END IF;
            END IF;

            IF lv_line_item_key IS NULL THEN

                IF lo_ifac.line_item_template_id IS NOT NULL THEN
                    lv_line_item_key := EcDp_Line_Item.InsNewLineItem(
                        lo_ifac.CONTRACT_ID,
                        lo_ifac.processing_period,
                        lo_ifac.document_key,
                        lo_ifac.transaction_key,
                        lo_ifac.line_item_template_id,
                        p_context.user_id,
                        p_creation_method => ecdp_revn_ft_constants.c_mtd_interface,
                        p_ifac_li_conn_code => lo_ifac.ifac_li_conn_code,
                        p_li_unique_key_1 => lo_ifac.li_unique_key_1,
                        p_li_unique_key_2 => lo_ifac.li_unique_key_2);
                ELSE
                    lv_line_item_key := ecdp_line_item.InsNewLineItem(
                        lo_ifac.contract_id,
                        lo_ifac.processing_period,
                        lo_ifac.document_key,
                        lo_ifac.transaction_key,
                        lo_ifac.line_item_template_id,
                        p_context.user_id,
                        null,
                        lo_ifac.line_item_type,
                        lo_ifac.line_item_based_type,
                        null,
                        lo_ifac.percentage_value,
                        lo_ifac.unit_price,
                        lo_ifac.unit_price_unit,
                        lo_ifac.qty1,
                        lo_ifac.pricing_value,
                        lo_ifac.description,
                        NVL(lo_ifac.li_price_object_id, lo_ifac.price_object_id),
                        NULL,
                        lo_ifac.customer_id,
                        p_creation_method => ecdp_revn_ft_constants.c_mtd_interface,
                        p_ifac_li_conn_code => lo_ifac.ifac_li_conn_code,
                        p_li_unique_key_1 => lo_ifac.li_unique_key_1,
                        p_li_unique_key_2 => lo_ifac.li_unique_key_2);
                END IF;

                l_logger.debug('Line item ' || lv_line_item_key || ' created for interfaced ' || lo_ifac.line_item_based_type || ' type values. ');
            END IF;

            -- apply the line item key
            p_context.UPDATE_IFAC_KEYS_PERIOD(
                lo_ifac.TRANS_ID, lo_ifac.transaction_key,
                lo_ifac.LI_ID, lv_line_item_key);
            lv_line_item_key := NULL;
        END LOOP;
    END;


   -----------------------------------------------------------------------
    -- Generates line items from ifac (given in context). This procedure is for cargo-based transactions.
    --
    -- p_user: the id of user triggered this action.
    -- p_context: the operation context.
    -- p_for_transaction: the key of transaction to generate lines for. If null is given, all line
    --   items in ifac will be generated.
    ----+----------------------------------+-------------------------------
    PROCEDURE gen_li_f_ifac_cargo_p(
        p_context                          in out nocopy t_revn_doc_op_context
       ,p_document_info                    IN OUT NOCOPY t_revn_ft_doc_info
       ,p_for_transaction                  VARCHAR2 DEFAULT NULL
    )
    IS
        lo_ifac	                           t_ifac_cargo_value;
        lo_qty_keys                        t_table_varchar2;
        lo_processed_trans_idx             t_table_number;
        lv_line_item_key                   cont_line_item.line_item_key%TYPE;
        l_logger                           t_revn_logger;
    BEGIN
        IF p_context.is_empty_cargo_ifac_data THEN
            RETURN;
        END IF;

        p_context.get_or_create_logger(l_logger);

        FOR idx IN p_context.ifac_cargo_first..p_context.ifac_cargo_last LOOP
            lo_ifac := p_context.ifac_cargo(idx);

            -- skip non-line-item-level records
            IF lo_ifac.INTERFACE_LEVEL <> ecdp_revn_ifac_wrapper.gconst_level_line_item THEN
                continue;
            END IF;

            -- skip ones that have line item generated and belongs to other transactions
            IF lo_ifac.line_item_key IS NOT NULL
                OR NOT ecdp_revn_common.Equals(p_for_transaction, lo_ifac.transaction_key, TRUE) THEN
                continue;
            END IF;

            -- skip generating quantity line item that has already been generated
            IF NVL(lo_ifac.line_item_based_type, 'QTY') = 'QTY' THEN
                lo_qty_keys := ecdp_transaction.get_qty_li_keys(lo_ifac.transaction_key);
                IF lo_qty_keys.count > 0 THEN
                    -- TODO: any validation required?
                    -- apply the line item key
                    lv_line_item_key := lo_qty_keys(1);
                    l_logger.debug('Found line item ' || lv_line_item_key || ' for interfaced quantity.');
                ELSE
                    l_logger.debug('No line item found for interfaced quantity, this interface will be ignored.');
                END IF;
            END IF;

            IF lv_line_item_key IS NULL THEN

                IF lo_ifac.line_item_template_id IS NOT NULL THEN
                    lv_line_item_key := EcDp_Line_Item.InsNewLineItem(
                        lo_ifac.CONTRACT_ID,
                        lo_ifac.POINT_OF_SALE_DATE,
                        lo_ifac.document_key,
                        lo_ifac.transaction_key,
                        lo_ifac.line_item_template_id,
                        p_context.user_id,
                        p_creation_method => ecdp_revn_ft_constants.c_mtd_interface,
                        p_ifac_li_conn_code => lo_ifac.ifac_li_conn_code,
                        p_li_unique_key_1 => lo_ifac.li_unique_key_1,
                        p_li_unique_key_2 => lo_ifac.li_unique_key_2);
                ELSE
                    lv_line_item_key := ecdp_line_item.InsNewLineItem(
                        lo_ifac.contract_id,
                        lo_ifac.POINT_OF_SALE_DATE,
                        lo_ifac.document_key,
                        lo_ifac.transaction_key,
                        lo_ifac.line_item_template_id,
                        p_context.user_id,
                        null,
                        lo_ifac.line_item_type,
                        lo_ifac.line_item_based_type,
                        null,
                        lo_ifac.percentage_value,
                        lo_ifac.unit_price,
                        lo_ifac.unit_price_unit,
                        lo_ifac.NET_QTY1,
                        lo_ifac.pricing_value,
                        lo_ifac.description,
                        NVL(lo_ifac.li_price_object_id, lo_ifac.price_object_id),
                        NULL,
                        lo_ifac.customer_id,
                        p_creation_method => ecdp_revn_ft_constants.c_mtd_interface,
                        p_ifac_li_conn_code => lo_ifac.ifac_li_conn_code,
                        p_li_unique_key_1 => lo_ifac.li_unique_key_1,
                        p_li_unique_key_2 => lo_ifac.li_unique_key_2);
                END IF;

                l_logger.debug('Line item ' || lv_line_item_key || ' created for interfaced ' || lo_ifac.line_item_based_type || ' type values. ');
            END IF;

            -- apply the line item key
            p_context.UPDATE_IFAC_KEYS_CARGO(
                lo_ifac.TRANS_ID, lo_ifac.transaction_key,
                lo_ifac.LI_ID, lv_line_item_key);
            lv_line_item_key := NULL;
        END LOOP;


    END;
    -----------------------------------------------------------------------
    -- Generates non-quantity line items from preceding transaction.
    ----+----------------------------------+-------------------------------
    PROCEDURE gen_li_nq_f_preceding_trans_p(
        p_context                          IN OUT NOCOPY t_revn_doc_op_context
       ,p_transaction_key                  cont_transaction.transaction_key%TYPE
       ,p_line_items_to_exclude            IN OUT NOCOPY t_table_varchar2
    )
    IS
        l_preceding_trans_key              cont_transaction.transaction_key%TYPE;
        l_new_line_item_key                cont_line_item.line_item_key%TYPE;
        l_logger                           t_revn_logger;
    BEGIN
        l_preceding_trans_key := ec_cont_transaction.preceding_trans_key(p_transaction_key);
        IF l_preceding_trans_key IS NULL THEN
            RETURN;
        END IF;

        p_context.get_or_create_logger(l_logger);
        l_logger.debug('Copying line items from preceding transaction...');

        FOR li_meta IN ecdp_line_item.c_get_li_meta(l_preceding_trans_key) LOOP
            IF li_meta.line_item_based_type = ecdp_revn_ft_constants.li_btype_quantity THEN
                CONTINUE;
            END IF;

            IF ecdp_revn_common.contains(p_line_items_to_exclude, li_meta.line_item_key) THEN
                CONTINUE;
            END IF;

            l_new_line_item_key := ecdp_line_item.CopyLineItem(
                li_meta.object_id, li_meta.line_item_key, li_meta.daytime, p_transaction_key);

            l_logger.debug('Copy of preceding Line item ' || li_meta.line_item_key || ' is created as ' || l_new_line_item_key || '. ');
        END LOOP;
    END;


    -----------------------------------------------------------------------
    -- Matches ifac record with existing line items on document.
    ----+----------------------------------+-------------------------------
    PROCEDURE match_ifac_li_on_doc_period_p(
        p_context                          IN OUT NOCOPY t_revn_doc_op_context
       ,p_processing_document              cont_document.document_key%TYPE
       ,p_matched_line_item_keys           IN OUT NOCOPY t_table_varchar2
    )
    IS
        l_preceding_doc_key                cont_document.document_key%TYPE;
        l_preceding_trans_key              cont_transaction.transaction_key%TYPE;
        l_preceding_li_key                 cont_line_item.line_item_key%TYPE;
        l_ifac                             t_ifac_sales_qty;
        l_temp_new_item_idx                NUMBER;
    BEGIN
        FOR idx IN p_context.ifac_period_first..p_context.ifac_period_last LOOP
            l_ifac := p_context.get_ifac_period(idx);

            -- skip non-line-item-level records
            IF l_ifac.INTERFACE_LEVEL <> ecdp_revn_ifac_wrapper.gconst_level_line_item THEN
                continue;
            END IF;

            -- skip ones that have line item generated and belongs to other transactions
            IF l_ifac.line_item_key IS NOT NULL THEN
                continue;
            END IF;

            find_preceding_keys_p(l_ifac, l_preceding_doc_key, l_preceding_trans_key, l_preceding_li_key);
            IF l_preceding_doc_key = p_processing_document
                AND l_preceding_trans_key IS NOT NULL
                AND l_preceding_li_key IS NOT NULL
            THEN
                p_context.update_ifac_keys_period(
                    l_ifac.trans_id, l_preceding_trans_key, l_ifac.li_id, l_preceding_li_key);
                l_temp_new_item_idx := ecdp_revn_common.append(p_matched_line_item_keys, l_preceding_li_key);
            END IF;
        END LOOP;
    END;

-----------------------------------------------------------------------
-- Trace interface document
----+----------------------------------+-------------------------------
PROCEDURE trace(p_context IN OUT NOCOPY t_revn_doc_op_context) IS
  l_ifac_rec       T_IFAC_SALES_QTY;
  v_financial_code contract_version.financial_code%type;
BEGIN
  IF p_context.is_empty_period_ifac_data THEN
    RETURN;
  END IF;

  FOR idx IN p_context.ifac_period_first .. p_context.ifac_period_last LOOP
    l_ifac_rec       := p_context.get_ifac_period(idx);
    v_financial_code := ec_contract_version.financial_code(l_ifac_rec.contract_id,
                                                           l_ifac_rec.period_start_date,
                                                           '<=');
    IF l_ifac_rec.calc_run_no IS NOT NULL THEN

      IF l_ifac_rec.contract_account_class IN
         ('SCTR_ACC_MTH_STATUS', 'SCTR_ACC_YR_STATUS') THEN
        ecdp_dataset_flow.insertifactodoc(l_ifac_rec.calc_run_no,
                                          l_ifac_rec.contract_account_class,
                                          l_ifac_rec.contract_account,
                                          l_ifac_rec.line_item_key,
                                          ecdp_fin_period.getCurrOpenPeriodByObject(l_ifac_rec.contract_id,
                                                                                    l_ifac_rec.period_start_date,
                                                                                    v_financial_code,
                                                                                    'REPORTING'));
      ELSIF l_ifac_rec.contract_account_class IN
            ('SCTR_ACC_MTH_PC_STATUS', 'SCTR_ACC_YR_PC_STATUS') THEN
        ecdp_dataset_flow.insertifactodoc(l_ifac_rec.calc_run_no,
                                          l_ifac_rec.contract_account_class,
                                          l_ifac_rec.contract_account,
                                          l_ifac_rec.line_item_key || '$' ||
                                          l_ifac_rec.profit_center_id,
                                          ecdp_fin_period.getCurrOpenPeriodByObject(l_ifac_rec.contract_id,
                                                                                    l_ifac_rec.period_start_date,
                                                                                    v_financial_code,
                                                                                    'REPORTING'));
      ELSIF l_ifac_rec.contract_account_class IN
            ('SCTR_ACC_MTH_PC_CPY', 'SCTR_ACC_YR_PC_CPY') THEN
        ecdp_dataset_flow.insertifactodoc(l_ifac_rec.calc_run_no,
                                          l_ifac_rec.contract_account_class,
                                          l_ifac_rec.contract_account,
                                          l_ifac_rec.line_item_key || '$' ||
                                          l_ifac_rec.profit_center_id || '$' ||
                                          l_ifac_rec.vendor_id,
                                          ecdp_fin_period.getCurrOpenPeriodByObject(l_ifac_rec.contract_id,
                                                                                    l_ifac_rec.period_start_date,
                                                                                    v_financial_code,
                                                                                    'REPORTING'));
      END IF;
    END IF;

       IF l_ifac_rec.calc_run_no IS NOT NULL THEN
              UPDATE cont_transaction
                SET calc_run_no = l_ifac_rec.calc_run_no,
                    contract_account_class = l_ifac_rec.contract_account_class,
                    contract_account = l_ifac_rec.contract_account
                WHERE transaction_key = l_ifac_rec.transaction_key;
            END IF;

    EXIT;

  END LOOP;
END;



PROCEDURE SetDocumentValidationLevel_P
   (p_doc_key VARCHAR2,
    p_val_level VARCHAR2,
    p_user VARCHAR2
    )
IS

  lv2_val_msg VARCHAR2(240);
  lv2_val_code VARCHAR2(32);

BEGIN

    IF p_val_level = 'OPEN' THEN
       -- Val Level is VALID1, VALID2 or TRANSFER, and must be reset to OPEN.
       UPDATE cont_document cd SET
              cd.set_to_prev_ind = 'Y'
        WHERE cd.document_key = p_doc_key;

    ELSE

       -- Update interest line item
       UpdInterestLineItems(p_doc_key);

       UPDATE cont_document cd SET
              cd.document_level_code = p_val_level,
              cd.valid1_user_id =   DECODE(p_val_level, 'VALID1',   p_user, cd.valid1_user_id),
              cd.valid2_user_id =   DECODE(p_val_level, 'VALID2',   p_user, cd.valid2_user_id),
              cd.transfer_user_id = DECODE(p_val_level, 'TRANSFER', p_user, cd.transfer_user_id),
              cd.booked_user_id =   DECODE(p_val_level, 'BOOKED', p_user, cd.transfer_user_id),
              cd.last_updated_by = p_user
       WHERE cd.document_key = p_doc_key;

       -- Run main validation when moving from OPEN to VALID1
       IF p_val_level = 'VALID1' THEN

          EcDp_Document.ValidateDocument(p_doc_key, lv2_val_msg, lv2_val_code, 'N');

       END IF;

    END IF;

END SetDocumentValidationLevel_P;


-----------------------------------------------------------------------
-- Setting final status on the "Create Document" run.
--
-- The log status may have been set by WriteDocGenLog if any errors or
-- warnings have occurred. It is necessary to verify which status is
-- to be the final one. Run status order: ERROR, WARNING and SUCCESS.
----+----------------------------------+-------------------------------
PROCEDURE FinalDocGenLog(p_logger       IN OUT NOCOPY t_revn_logger,
                         p_final_status VARCHAR2)
IS
    lv2_use_status VARCHAR2(32);
BEGIN
    p_logger.refresh;

    IF p_logger.status = 'ERROR' THEN
        lv2_use_status := p_final_status;
    ELSIF p_final_status = 'WARNING' THEN
        IF p_logger.status != 'ERROR' OR p_logger.status IS NULL THEN
            lv2_use_status := p_final_status;
        ELSE
            lv2_use_status := p_logger.status;
        END IF;
    ELSIF p_final_status = 'SUCCESS' THEN
        IF (p_logger.status != 'ERROR' AND p_logger.status != 'WARNING') OR p_logger.status IS NULL THEN
            lv2_use_status := p_final_status;
        ELSE
            lv2_use_status := p_logger.status;
        END IF;
    END IF;

    p_logger.info(
          'Document processing FINISHED with status [' || p_final_status
          || ']. Overall status is [' || lv2_use_status
          || ']' || CHR(10) || CHR(13));
    p_logger.update_overall_state(NULL, lv2_use_status);

END FinalDocGenLog;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : GenCargoDocument
-- Description    : Function for createing one document based on one cargo
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : stim_mth_cargo_value, cont_transaction
--
-- Using functions: EcDp_Document.WriteDocGenLog
--                  EcDp_Document.GenDocumentSet
--                  EcDp_Document.genNewQTYs
--
-- Configuration
-- required       :
--
-- Behaviour      : Uses existing functionality to create a document, with transactions and line items.
--                  Relates the cargo to the document and uses existing functionality to populate transactions with cargo qtys.
--
-------------------------------------------------------------------------------------------------



FUNCTION GenCargoDocument(p_object_id        VARCHAR2, -- Contract
                          p_cargo_no         VARCHAR2,
                          p_parcel_no        VARCHAR2,
                          p_daytime          DATE,
                          p_action           VARCHAR2,
                          p_contract_doc_id  VARCHAR2,
                          p_validation_level VARCHAR2, -- If new doc, this is requested validation level. If existing doc this is the actual validation level.
                          p_document_date    DATE,
                          p_document_status  VARCHAR2,
                          p_gen_doc_key      VARCHAR2, -- If updating price or qty on existing document. No new doc is created.
                          p_prec_doc_key     VARCHAR2, -- If preceding doc (Booked) and a dependent DS exists, the InsNewDocument will attempt to create reversal transactions in new document.
                                                        -- If there is no Dependent DS, this will contain the document which is used as basis for a Reversal document.
                          p_loading_port_id VARCHAR2,
                          p_customer_id     VARCHAR2,
                          p_source_node_id  VARCHAR2,
                          p_user            VARCHAR2,
                          p_owner           VARCHAR2,
                          p_log_item_no     IN OUT NUMBER, -- Upon first document in current run, this will be set by the WriteDocGenLog.
                          p_new_doc_key     OUT VARCHAR2,
                          p_nav_id          VARCHAR2,
                          p_silent          ecdp_revn_common.T_BOOLEAN_STR DEFAULT ecdp_revn_common.gv2_true) RETURN VARCHAR2
--<EC-DOC>
IS
  -- Copy of the parameters so they can be changed in PRE user exist
  lv2_p_object_id                      VARCHAR2(32) := p_object_id;
  lv2_p_cargo_no                       cont_transaction.cargo_name%TYPE := p_cargo_no;
  lv2_p_parcel_no                      VARCHAR2(32) := p_parcel_no;
  ld_p_daytime                         DATE := p_daytime;
  lv2_p_action                         VARCHAR2(240) := p_action;
  lv2_p_contract_doc_id                VARCHAR2(32) := p_contract_doc_id;
  lv2_p_validation_level               VARCHAR2(200) := p_validation_level;
  ld_p_document_date                   DATE := p_document_date;
  lv2_p_document_status                cont_document.status_code%TYPE := p_document_status;
  lv2_p_gen_doc_key                    VARCHAR2(32) := p_gen_doc_key;
  lv2_p_prec_doc_key                   VARCHAR2(32) := p_prec_doc_key;
  lv2_p_loading_port_id                VARCHAR2(32) := p_loading_port_id;
  lv2_p_source_node_id                 VARCHAR2(32) := p_source_node_id;
  lv2_p_customer_id                    VARCHAR2(32) := p_customer_id;
  lv2_p_user                           VARCHAR2(30) := p_user;
  lv2_p_owner                          VARCHAR2(30) := p_owner;
  lv2_p_nav_id                         VARCHAR2(2000) := p_nav_id;


  lv2_ifac_price_object                VARCHAR2(32) := NULL;
  ln_RecordCounter                     NUMBER := 0;
  lv2_ReturnDocKey                     VARCHAR2(32) := NULL;
  lv2_NewDocKey                        VARCHAR2(32) := NULL;
  lv2_NewRevDocKey                     VARCHAR2(32) := NULL;
  ln_CargoCounter                      NUMBER := 0;
  ln_TranCounter                       NUMBER := 0;
  lv2_RunStatus                        VARCHAR2(32) := NULL; -- ERROR, WARNING or SUCCESS
  lv2_use_doc_key                      VARCHAR2(32) := NULL;
  lv2_cargo_processed_ind              VARCHAR2(1) := 'N';
  lv2_dest_country_id                  VARCHAR2(32) := NULL;
  lv2_origin_country_id                VARCHAR2(32) := NULL;
  generation_error                     EXCEPTION;
  lrec_ttv                             transaction_tmpl_version%rowtype;
  lrec_ctr                             cont_transaction%rowtype;
  lv2_transaction_key                  cont_transaction.transaction_key%TYPE;
  ld_daytime                           DATE;
  ld_p_point_of_sale_date              DATE;
  lb_alternative_customer_set          BOOLEAN;
  lv2_tmp_var                          VARCHAR2(32);
  ln_count                             NUMBER;
  lv2_preceding_trans_key              varchar2(32);
  lv2_ifac_doc_status_filter           varchar2(32);
  lt_ifac_to_process_doc               t_table_ifac_cargo_value;
  lo_ifac_rec                          t_ifac_cargo_value;
  l_context                            t_revn_doc_op_context;
  lt_ifac_to_process_trans             t_table_ifac_cargo_value;
  lo_ifac_li_types                     t_table_varchar2;
  lt_raise_error                       ecdp_revn_common.T_BOOLEAN_STR;
  l_logger                             t_revn_logger;
  lv2_prec_doc_val_level               VARCHAR2(32);
  lv2_reversal_trans_key               cont_transaction.transaction_key%type;
  lv2_loginfo                          VARCHAR2(240);
  lv2_line_item_based_type             VARCHAR2(32);

    CURSOR c_ifac_no_doc_setup(
        cp_contract_id        VARCHAR2,
        cp_doc_status         VARCHAR2,
        cp_customer_id        VARCHAR2,
        cp_cargo_no           VARCHAR2,
        cp_parcel_no          VARCHAR2) IS
        SELECT source_entry_no
          FROM IFAC_CARGO_VALUE i
        WHERE i.contract_id = cp_contract_id
           AND i.customer_id = cp_customer_id
           AND i.cargo_no = cp_cargo_no
           AND i.doc_status = cp_doc_status
           AND i.parcel_no  = cp_parcel_no
           AND i.doc_setup_id is null;

     CURSOR c_processing_records(
        cp_contract_id       VARCHAR2,
        cp_doc_status        VARCHAR2,
        cp_customer_id       VARCHAR2,
        cp_cargo_no             VARCHAR2,
        cp_parcel_no            VARCHAR2) IS
        SELECT *
          FROM v_cargo_document_process pdp
        WHERE pdp.contract_id = cp_contract_id
           AND pdp.doc_status  = cp_doc_status
           AND pdp.customer_id = cp_customer_id
           AND pdp.cargo_no    = cp_cargo_no
           AND pdp.parcel_no   = cp_parcel_no
           AND pdp.saved_doc_setup_id is not null;

    l_use_trans_key        cont_transaction.transaction_key%TYPE;
    lv2_missing_doc_ifac   ifac_cargo_value%rowtype;
    lv2_updated_doc_ifac   ifac_cargo_value%rowtype;
    l_preceding_li_key     cont_line_item.line_item_key%TYPE;
    l_preceding_doc_key    cont_document.document_key%TYPE;
    l_temp_line_item_keys  t_table_varchar2;
    l_document_info        t_revn_ft_doc_info;
    l_preceding_li_keys    t_table_varchar2;

BEGIN

    IF ue_cont_document.isGenCargoDocUEEnabled = 'TRUE' THEN
        -- Instead-of user exit
        RETURN ue_cont_document.GenCargoDocument(lv2_p_object_id,
                                                 lv2_p_cargo_no,
                                                 lv2_p_parcel_no,
                                                 ld_p_daytime,
                                                 lv2_p_action,
                                                 lv2_p_contract_doc_id,
                                                 lv2_p_validation_level,
                                                 ld_p_document_date,
                                                 lv2_p_document_status,
                                                 lv2_p_gen_doc_key,
                                                 lv2_p_prec_doc_key,
                                                 lv2_p_loading_port_id,
                                                 lv2_p_customer_id,
                                                 lv2_p_source_node_id,
                                                 lv2_p_user,
                                                 lv2_p_owner,
                                                 p_log_item_no,
                                                 p_new_doc_key,
                                                 lv2_p_nav_id);
    ELSE
       lt_raise_error := CASE p_silent
            WHEN ecdp_revn_common.gv2_false THEN ecdp_revn_common.gv2_true
            WHEN ecdp_revn_common.gv2_true THEN ecdp_revn_common.gv2_false
            ELSE ecdp_revn_common.gv2_false END;


    l_context := t_revn_doc_op_context();
    l_context.processing_contract_id := lv2_p_object_id;
    l_context.processing_cargo_name := lv2_p_cargo_no;
    l_context.config_logger(p_log_item_no, 'CARGO_DG');
    l_context.user_id := p_user;
    l_context.get_or_create_logger(l_logger);

    l_logger.update_overall_state(lv2_p_nav_id, ecdp_revn_log.LOG_STATUS_RUNNING);
    l_logger.update_overall_data(lv2_p_object_id, NULL, NULL, NULL, NULL, NULL, ld_p_daytime, NULL);
    l_logger.info('Start document processing.');
    p_log_item_no := l_logger.log_no;


  BEGIN
        -- PRE user exit
        IF ue_cont_document.isGenCargoDocUEPreEnabled = 'TRUE' THEN
            ue_cont_document.GenCargoDocumentPre(lv2_p_object_id,
                                                 lv2_p_cargo_no,
                                                 lv2_p_parcel_no,
                                                 ld_p_daytime,
                                                 lv2_p_action,
                                                 lv2_p_contract_doc_id,
                                                 lv2_p_validation_level,
                                                 ld_p_document_date,
                                                 lv2_p_document_status,
                                                 lv2_p_gen_doc_key,
                                                 lv2_p_prec_doc_key,
                                                 lv2_p_loading_port_id,
                                                 lv2_p_customer_id,
                                                 lv2_p_source_node_id,
                                                 lv2_p_user,
                                                 lv2_p_owner,
                                                 p_log_item_no,
                                                 lv2_p_nav_id);
        END IF;

     lb_alternative_customer_set := FALSE;
     IF lv2_p_user <> lv2_p_owner THEN
       l_logger.info('Record(s) are owned by user (' || lv2_p_owner || ')');
       RETURN 'IGNORE';
     END IF;

            -- Check to see if possible new preceding was just created due to new transaction on document
            IF lv2_p_contract_doc_id IS NULL THEN
                l_logger.info('Contract Doc is missing will run reanalysis to see if a new preceding was just created to add this to a dependent');
                FOR missing_doc_setup in c_ifac_no_doc_setup(
                    lv2_p_object_id,
                    lv2_p_document_status,
                    lv2_p_customer_id,
                    lv2_p_cargo_no,
                    lv2_p_parcel_no) LOOP
                    lv2_missing_doc_ifac := ec_ifac_cargo_value.row_by_pk(missing_doc_setup.source_entry_no);
                    lv2_updated_doc_ifac := ecdp_inbound_interface.ReAnalyseCargoRecord(lv2_missing_doc_ifac);
                    ld_p_point_of_sale_date   :=lv2_updated_doc_ifac.point_of_sale_date;
                    IF lv2_updated_doc_ifac.doc_setup_code IS NOT NULL THEN
                        l_logger.info(
                          'A document setup was found (' || lv2_updated_doc_ifac.doc_setup_code
                          || ') and will be used for ifac record:' || missing_doc_setup.Source_Entry_No);

                        UPDATE IFAC_CARGO_VALUE
                        SET ROW = lv2_updated_doc_ifac
                        WHERE Source_Entry_No = missing_doc_setup.Source_Entry_No;
                    END IF;
                END LOOP;
                FOR records in c_processing_records(
                    lv2_p_object_id,
                    lv2_p_document_status,
                    lv2_p_customer_id,
                    lv2_p_cargo_no,
                    lv2_p_parcel_no)
                    LOOP

                    lv2_p_action := records.action;
                    lv2_p_prec_doc_key := records.prec_doc_key;
                    ld_p_document_date := records.doc_date;
                    lv2_p_contract_doc_id := records.saved_doc_setup_id;
                    ld_p_point_of_sale_date := records.daytime;

                    IF lv2_p_contract_doc_id is not null then
                        l_logger.warning('The Reanalysis resulted in multiple new documents. One will be created now, you will need to reprocess to get the additional documents.');
                    END IF;
                END LOOP;
            END IF;
        -- Validate process parameters
           ValidateDocProcessParams(lv2_p_object_id, lv2_p_contract_doc_id, 'EcDp_Document_Gen.GenCargoDocument()');

        -- See if any accrual document in the same processing period and have same document
        -- setup have been reversed and all reversal documents have been booked. If yes
        -- then this ifac record can be processed, skip otherwise.
        IF (EcDp_Document_Gen_Util.GetHoldFinalWhenAclInd(lv2_p_contract_doc_id, ld_p_daytime) = 'Y'
            OR ec_cont_document.status_code(lv2_p_prec_doc_key) = 'ACCRUAL')
                AND lv2_p_document_status = 'FINAL' THEN

            IF(EcDp_Document_Gen_Util.HasNotReversedAccrualDoc(lv2_p_contract_doc_id, lv2_p_customer_id, ld_p_daytime) = 'Y') THEN
                l_logger.warning('Final records found and cannot be processed until accruals are reversed.');
		        l_logger.update_overall_state(lv2_p_nav_id, ecdp_revn_log.log_status_warning);
                RETURN 'IGNORE';
            END IF;

            IF lv2_p_document_status = 'ACCRUAL' AND p_prec_doc_key IS NOT NULL THEN
                l_logger.warning('Booked Accrual document found and new accrual cannot be processed until accruals are reversed.');
                RETURN 'IGNORE';
            END IF;

        END IF;



     -- Resolve Document Version Date (Daytime)
     ld_daytime := EcDp_document.GetDocumentDaytime(lv2_p_object_id, lv2_p_contract_doc_id, ld_p_document_date);


     -- check against proccessable code
     IF  ec_contract_version.contract_stage_code(lv2_p_object_id, ld_daytime, '<=') = 'N' THEN
           Raise_Application_Error(-20000,'The document of this contract could not be processed!');
     END IF;

     -- Get the action that is appropriate for this cargo
     l_logger.debug( 'Action for this cargo is: [' || lv2_p_action || '].');
     l_logger.debug( 'Customer on this cargo value record is: [' || ecdp_objects.getobjcode(lv2_p_customer_id) || '].');

            IF lv2_p_action IN ('CREATE_INVOICE', 'CREATE_DEPENDENT', 'CREATE_REALLOCATION', 'CREATE_REVERSAL', 'APPEND_OR_UPDATE_DOC') THEN
                -- Validate important parameters
                IF lv2_p_contract_doc_id IS NULL THEN
                    GenDocException(lv2_p_object_id, NULL, -20000,
                        'DocProcess Can not create document without a Document Setup. This is missing from interfaced data.',
                        ecdp_revn_log.LOG_STATUS_ITEM_ERROR, 'N', l_logger.log_no, lt_raise_error);
                END IF;

                prepare_ifac_cargo_p(
                    l_context, lv2_p_object_id, lv2_p_contract_doc_id, p_cargo_no,p_parcel_no, lv2_p_customer_id, ld_p_daytime);
            END IF;

            IF lv2_p_action IN ('UPDATE_DOC') THEN
                prepare_ifac_cargo_p(
                    l_context, lv2_p_object_id, lv2_p_contract_doc_id, p_cargo_no,p_parcel_no, lv2_p_customer_id, ld_p_daytime);
            END IF;

            lt_ifac_to_process_doc := l_context.ifac_cargo;




     -- UPDATE_QUANTITY: If new quantity has arrived for a cargo, and previous generated document has not been booked, run "update qty" function.
     -- UPDATE_PRICE: If price has been updated on non-booked doc, no new document should be created, but only run the price update functionality.
     IF lv2_p_action IN ('APPEND_OR_UPDATE_DOC','UPDATE_DOC') THEN
     BEGIN
         lv2_use_doc_key := lv2_p_prec_doc_key;

     IF lv2_p_validation_level IN ('VALID1','VALID2','OPEN') THEN

        l_logger.info('UPDATING DOCUMENT: Document [' || lv2_use_doc_key || '] on Contract [' || ec_contract_version.name(lv2_p_object_id, ld_daytime, '<=') || ']');
        IF lv2_use_doc_key IS NOT NULL THEN
        -- Move the document down to OPEN if validated.
               IF ec_cont_document.document_level_code(lv2_use_doc_key) IN ('VALID1','VALID2') THEN

                       -- Abort if system attribute PROCESS_ONLY_OPEN_DOCS is ON
                       IF upper(ec_ctrl_system_attribute.attribute_text(Ecdp_Timestamp.getCurrentSysdate, 'PROCESS_ONLY_OPEN_DOCS', '<=')) = 'Y' THEN
                           l_logger.info('New quantities or prices have been found for document "' || lv2_use_doc_key || '", but the document will not be updated. The new quantities or prices will be updated in the document if the document is manually set back to Open.');
                           RETURN 'WARNING';
                       END IF;

                       l_logger.debug('Preparing document update. Moving from ' || lv2_p_validation_level || ' to OPEN on Document [' || lv2_use_doc_key || ']');
                       l_logger.debug('Document Level Code BEFORE: ' || ec_cont_document.document_level_code(lv2_use_doc_key));
                       SetDocumentValidationLevel_P(lv2_use_doc_key, 'OPEN', lv2_p_user);
                       l_logger.debug('Document Level Code AFTER: ' || ec_cont_document.document_level_code(lv2_use_doc_key));

               END IF;
               -- Distribute qtys on the different fields according to field splits --
               -- This is done on the preceding document, because this record is a new allocation of the initial processed quantity record.
               l_logger.info('Distributing the Quantities according to field adherence.');
               l_logger.debug('Contract: ' || ec_contract.object_code(lv2_p_object_id) || ', Document: ' || lv2_use_doc_key || ', user: ' || lv2_p_user);

               /*sets the prec doc key , prec trans key and prec li key to l_context*/
               refresh_prec_keys_cargo_p(TRUE, l_context);
               -- copies preceding keys to keys, where preceding doc key is the one being updated
               set_prec_keys_as_keys_cargo_p(lv2_use_doc_key, l_context, TRUE);
               -- applys or updates all this to database
               l_context.apply_ifac_cargo_keys;
               ecdp_document.fill_by_ifac_cargo_i(l_context, lv2_use_doc_key);
               /* removes all the processed records(which are used for append_doc) from context to make it ready for onlyu update*/
               l_context.remove_ifac_has_li_key_cargo;
               lt_ifac_to_process_doc := l_context.ifac_cargo;
        ELSE
               GenDocException(lv2_p_object_id, NULL, -20000, 'Can not update quantity on document. No document available.',  'ERROR', 'N', l_logger.log_no, lt_raise_error);
               RETURN 'ERROR';
        END IF;
        END IF;
        EXCEPTION
        WHEN OTHERS THEN
        GenDocException(lv2_p_object_id, lv2_use_doc_key, SQLCODE, SUBSTR(SQLERRM, 1, 240), 'WARNING', 'N', l_logger.log_no, lt_raise_error);
        RETURN 'WARNING';
       END;

       -- Document is now OPEN and should not be re-validated up to its previous level,
       -- because it is a user process to validate that the new qtys and prices are correct.
       -- Returning updated document_key
       lv2_ReturnDocKey := lv2_use_doc_key;
    END IF;
     -- UPDATE_PRICE: If price has been updated on non-booked doc, no new document should be
            --     created, but only run the price update functionality.
            IF lv2_p_action = 'UPDATE_PRICE' THEN
                BEGIN
                    IF ec_cont_document.document_level_code(lv2_use_doc_key) IN ('VALID1','VALID2','OPEN') THEN
                        -- Generated doc column is used to store doc key that need to be updated with new price
                        lv2_use_doc_key := lv2_p_prec_doc_key;

                        -- Move the document down to OPEN if validated.
                        IF ec_cont_document.document_level_code(lv2_use_doc_key) IN ('VALID1','VALID2') THEN
                            l_logger.info('Preparing price update on document. Moving from '
                                || ec_cont_document.document_level_code(lv2_use_doc_key)
                                || ' to OPEN on Document [' || lv2_use_doc_key || ']');
                            l_logger.debug('Document Level Code BEFORE: '
                                || ec_cont_document.document_level_code(lv2_use_doc_key));

                            SetDocumentValidationLevel_P(lv2_use_doc_key, 'OPEN', lv2_p_user);

                            l_logger.debug('Document Level Code AFTER: '
                                || ec_cont_document.document_level_code(lv2_use_doc_key));
                        END IF;

                        -- Generated doc column is used to store doc key that need to be updated with new price
                        -- Update prices on all transaction in current document
                        l_logger.info('Updating prices on all non-reversal transactions in current document.');
                        l_logger.debug('Contract: ' || ec_contract.object_code(lv2_p_object_id)
                            || ', Document: ' || lv2_use_doc_key
                            || ', user: ' || lv2_p_user);

                        EcDp_Document.FillDocumentPrice(lv2_use_doc_key, lv2_p_user);
                    END IF;
                EXCEPTION
                    WHEN OTHERS THEN
                        GenDocException(lv2_p_object_id, lv2_use_doc_key, SQLCODE,
                            SUBSTR(SQLERRM, 1, 240), 'WARNING', 'N', l_logger.log_no, lt_raise_error);
                        RETURN 'WARNING';
                END;

                -- Document is now OPEN and should not be re-validated up to its previous level,
                -- because it is a user process to validate that the new qtys and prices are correct.
                -- Returning updated document_key
                lv2_ReturnDocKey := lv2_use_doc_key;
       END IF;


     -- REVERSAL DOCUMENT --
     -- If this document is a completely new document, replacing the previous BOOKED document for the same cargo, we need to create a reversal document.
     -- Action for this document was Create Reversal
     -- Generate reversal document with EcDp_Document.GenReverseDocument. If error, do not create new doc.
     -- Validate reversal document to the same level as the new document. If validation of reversal gives error, still create and validate new doc, but give warning.
     IF lv2_p_action = 'CREATE_REVERSAL' AND lv2_p_prec_doc_key IS NOT NULL THEN
         l_logger.info('CREATING NEW REVERSAL DOCUMENT: Cargo [' || lv2_p_cargo_no || '] on Contract [' || ec_contract_version.name(lv2_p_object_id, ld_daytime, '<=') || '] based on Document [' || lv2_p_prec_doc_key || ']');
         l_logger.debug( 'Calling EcDp_Document.GenReverseDocument with contract_id [' || lv2_p_object_id || '], contract_doc_id [' || lv2_p_contract_doc_id || '], preceding_doc_key [' || lv2_p_prec_doc_key || '], and p_user [' || lv2_p_user || '].');
         BEGIN
             -- Generating a new document key so that it can be used to delete document if something fails within EcDp_Document.GenReverseDocument.
             lv2_NewRevDocKey := EcDp_Document.GetNextDocumentKey(lv2_p_object_id, ld_daytime);

             -- Create the reversal
             lv2_NewRevDocKey := EcDp_Document.GenReverseDocument(lv2_p_object_id, lv2_p_prec_doc_key, p_log_item_no, lv2_p_user, 'Y', lv2_NewRevDocKey);

             l_context.processing_document_key := lv2_NewRevDocKey;
             l_context.get_or_create_logger(l_logger);
         EXCEPTION
             WHEN OTHERS THEN
                 GenDocException(lv2_p_object_id, lv2_NewRevDocKey, SQLCODE, SUBSTR(SQLERRM, 1, 240), 'ERROR', 'Y', l_logger.log_no);
                 RETURN 'ERROR';
         END;
         l_logger.info('Reversal Document Created. Key: ' || lv2_NewRevDocKey);

     END IF;

     -- CREATE_INVOICE: Creates a new document
     -- CREATE_DEPENDENT: Creates a dependent document
     -- APPEND_MPD: A MPD document has got pending updates OR appendable transactions in IFAC.
     IF lv2_p_action IN ('CREATE_INVOICE','CREATE_DEPENDENT','CREATE_REVERSAL','CREATE_REALLOCATION', 'APPEND_OR_UPDATE_DOC') THEN
       lv2_use_doc_key := lv2_p_prec_doc_key;
       -- Update preceding transactions in case something has changed
                l_logger.debug('Update preceding transactions in case something has changed');
     BEGIN
               refresh_prec_keys_cargo_p(true, l_context);
               FOR ifac_idx in 1 .. lt_ifac_to_process_doc.count LOOP
                     lo_ifac_rec := lt_ifac_to_process_doc(ifac_idx);

                     IF l_preceding_doc_key IS NOT NULL THEN
                     lv2_use_doc_key := l_preceding_doc_key;
                     EXIT;
                     END IF;
               END LOOP;
    EXCEPTION
    WHEN OTHERS THEN
    GenDocException(lv2_p_object_id, lv2_NewDocKey, SQLCODE, SUBSTR(SQLERRM, 1, 240),  'ERROR', 'Y', l_logger.log_no, lt_raise_error);
    RETURN 'ERROR';
    END;
    lv2_prec_doc_val_level := ec_cont_document.document_level_code(lv2_use_doc_key);

    -- Verify that the preceding document has been booked
    IF lv2_use_doc_key IS NOT NULL AND lv2_prec_doc_val_level != 'BOOKED' AND lv2_p_action NOT IN ('APPEND_OR_UPDATE_DOC') THEN
        GenDocException(lv2_p_object_id, NULL, -20000, 'Can not create a document that depends on preceding document ' || lv2_use_doc_key || '. The preceding document must be booked, but is currently at level ' || lv2_prec_doc_val_level || '.', 'ERROR', 'N', l_logger.log_no, lt_raise_error);
        RETURN 'ERROR';
    END IF;

    -- Do not create new document if this is appending on a MPD document
    IF lv2_p_action in ('APPEND_OR_UPDATE_DOC') THEN
         lv2_NewDocKey := lv2_use_doc_key;
    ELSE

               -- Create a blank document with input document setup. --
                 l_logger.info('Creating Document [' || ec_contract_doc_version.name(lv2_p_contract_doc_id, ld_daytime,'<=') ||
                               '] on Contract [' || ec_contract_version.name(lv2_p_object_id, ld_daytime, '<=') || ']');

                 BEGIN
                   -- Generating a new document key so that it can be used to delete document if something fails within EcDp_Document.InsNewDocument.
                   lv2_NewDocKey := EcDp_Document.GetNextDocumentKey(lv2_p_object_id, ld_daytime);

                   l_context.processing_document_key := lv2_NewDocKey;
                   l_context.get_or_create_logger(l_logger);

                   -- Calling GenDocumentSet with pre-generated document key
                   lv2_NewDocKey := EcDp_Document.GenDocumentSet_I(l_context,
                                                                 lv2_p_object_id,
                                                                 lv2_p_contract_doc_id,
                                                                 lv2_use_doc_key,
                                                                 ld_daytime,
                                                                 ld_p_document_date,
                                                                 NULL,
                                                                 lv2_NewDocKey,
                                                                 'N'); -- Make an empty document with no transactions

                 EXCEPTION
                     WHEN OTHERS THEN
                         GenDocException(lv2_p_object_id, lv2_NewDocKey, SQLCODE, SUBSTR(SQLERRM, 1, 240), 'ERROR', 'Y', l_logger.log_no, lt_raise_error);
                         RETURN 'ERROR';
                 END;
                 l_logger.info('Document Created. Key: ' || lv2_NewDocKey);

              END IF;

              l_context.update_all_ifac_doc_key_cargo(lv2_NewDocKey);
              l_document_info := t_revn_ft_doc_info(lv2_NewDocKey);
              l_document_info.refresh;

               -- If the document we have created is a dependent type document
               -- (except 'Dependent Document without reversal' / 'DEPENDENT_WITHOUT_REVERSAL')
               -- and the document status for the new doc is different from the document status
               -- of the preceding document we can not create a new doc
               IF lv2_NewDocKey is not null THEN
                  IF l_document_info.concept in (
                      'DEPENDENT', 'DEPENDENT_PARTIALLY_REVERSAL', 'DEPENDENT_ONLY_QTY_REVERSAL',
                      'DEPENDENT_PREV_MTH_CORR') THEN

                     IF ec_cont_document.status_code(lv2_p_prec_doc_key) <> lv2_p_document_status THEN
                        GenDocException(lv2_p_object_id, lv2_NewDocKey, -20000, 'Can not create dependent document with a different Document Status (Accrual/Final) that is different from the preceding document.', 'ERROR', 'Y', l_logger.log_no, lt_raise_error);
                        RETURN 'ERROR';
                     END IF;
                  END IF;
               END IF;


               -- Update cont_document set document_status_code = p_document_status --
               l_logger.info('Updating document ' || lv2_NewDocKey || ' - Setting Document Status to: ' || lv2_p_document_status);
               l_document_info.status := lv2_p_document_status;
               UPDATE cont_document
                  SET status_code = l_document_info.status
                WHERE document_key = l_document_info.key;

               IF lv2_p_customer_id IS NOT NULL
                   AND lv2_p_customer_id <> NVL(l_document_info.customer_id, '$NULL$')
               THEN
                   lb_alternative_customer_set := TRUE;
               END IF;

               IF lb_alternative_customer_set
               THEN
                   BEGIN
                       -- Alternative customer id is provided, need to use it to replace the default value
                       -- This has to be done before the document is filled
                       EcDp_Document.updateDocumentCustomer(lv2_NewDocKey,
                                                            lv2_p_object_id,
                                                            lv2_p_contract_doc_id,
                                                            l_document_info.level_code,
                                                            ld_daytime,
                                                            l_document_info.booking_currency_id,
                                                            lv2_p_user,
                                                            lv2_p_customer_id,
                                                            TRUE);
                   EXCEPTION
                       WHEN OTHERS
                       THEN
                           GenDocException(lv2_p_object_id, lv2_NewDocKey, SQLCODE, SUBSTR(SQLERRM, 1, 240), 'ERROR', 'Y', l_logger.log_no, lt_raise_error);
                           RETURN 'ERROR';
                   END;
               END IF;

       -- Update cont_document set document_status_code = p_document_status --
       l_logger.info('Setting Document Status to: ' || lv2_p_document_status);
       UPDATE cont_document
          SET status_code = lv2_p_document_status
       WHERE document_key = lv2_NewDocKey;

        -- process interface records by transacion
       BEGIN
       FOR ifac_idx in 1 .. lt_ifac_to_process_doc.count LOOP
          lo_ifac_rec := lt_ifac_to_process_doc(ifac_idx);

          -- only transaction level is interested now
          IF lo_ifac_rec.INTERFACE_LEVEL <> ecdp_revn_ifac_wrapper.gconst_level_transaction THEN
              continue;
          end if;

          ln_RecordCounter := ln_RecordCounter + 1;
          lv2_transaction_key := NULL;
          lv2_cargo_processed_ind := 'N';

          -- Find Transaction. There must only be one transaction valid --
          lrec_ttv := ec_transaction_tmpl_version.row_by_pk(lo_ifac_rec.Trans_Temp_Id, lo_ifac_rec.Point_Of_Sale_Date,'<=');

          -- Create new transaction with reference to preceding transaction
          FOR rsT IN ecdp_document.gc_transactions(lv2_p_prec_doc_key,
                                                   ec_contract_doc_version.doc_concept_code(lv2_p_contract_doc_id, ld_daytime,'<='),
                                                   lrec_ttv.stream_item_id,
                                                   lrec_ttv.price_concept_code,
                                                   nvl(lrec_ttv.product_id,lo_ifac_rec.Product_Id),
                                                   lrec_ttv.entry_point_id,
                                                   lrec_ttv.transaction_scope,
                                                   lrec_ttv.transaction_type,
                                                   lrec_ttv.dist_code) LOOP

             lv2_tmp_var := ecdp_transaction.getDependentTransaction(rsT.transaction_key);

                IF  lv2_tmp_var is NOT NULL  AND ec_cont_transaction.ppa_trans_code(lv2_tmp_var)='PPA_PRICE' THEN
                    lv2_tmp_var  :=Ecdp_Transaction.GetLatestnGreatestTran(rsT.transaction_key);
                END IF;
             IF lo_ifac_rec.preceding_trans_key IS NOT NULL THEN
              lv2_transaction_key := lo_ifac_rec.preceding_trans_key;
              END iF;
             IF lv2_transaction_key IS NULL THEN
             lv2_transaction_key := ecdp_transaction.insnewtransaction(lv2_p_object_id,
                                                                      ld_daytime,
                                                                      lv2_NewDocKey,
                                                                      lrec_ttv.transaction_type,
                                                                      lo_ifac_rec.trans_temp_id,
                                                                      lv2_p_user,
                                                                      NULL,
                                                                      NVL(lv2_tmp_var,rsT.transaction_key), -- Preceding transaction
                                                                      p_ifac_price_object_id => lo_ifac_rec.price_object_id,
                                                                      p_sales_order => lo_ifac_rec.product_sales_order_code
                                                                      );
              l_logger.debug('New Transaction inserted [' || lv2_transaction_key || ']');
              END IF;
              EXIT WHEN lv2_transaction_key IS NOT NULL;

          END LOOP;
          l_context.update_ifac_keys_cargo(lo_ifac_rec.TRANS_ID, lv2_transaction_key, NULL, NULL);

          IF lv2_transaction_key IS NULL THEN

                  lv2_transaction_key := ecdp_transaction.insnewtransaction(lv2_p_object_id,
                                                                            ld_daytime,
                                                                            lv2_NewDocKey,
                                                                            lrec_ttv.transaction_type,
                                                                            lo_ifac_rec.trans_temp_id,
                                                                            lv2_p_user,
                                                                            NULL,
                                                                            NULL, -- No preceding transaction
                                                                            p_ifac_price_object_id => lo_ifac_rec.price_object_id,
                                                                            p_sales_order => lo_ifac_rec.product_sales_order_code
                                                                            );

          END IF;

          -- Only process one cargo once (on one transaction)
          IF lv2_cargo_processed_ind = 'N' THEN

              lv2_dest_country_id := ecdp_transaction.GetDestinationCountryForTrans(lv2_p_object_id, lv2_transaction_key, 'CARGO_BASED', NULL, lo_ifac_rec.Discharge_Port_Id, ld_daytime);
              lv2_origin_country_id := ecdp_transaction.GetOriginCountryForTrans(lv2_p_object_id, lv2_transaction_key, 'CARGO_BASED', NULL, lo_ifac_rec.Loading_Port_Id, ld_daytime);

              UPDATE cont_transaction ctr SET
                     ctr.cargo_name              = NVL(lo_ifac_rec.Cargo_No, ctr.cargo_name),
                     ctr.parcel_name             = NVL(lo_ifac_rec.Parcel_No, ctr.parcel_name),
                     ctr.loading_date_commenced  = NVL(lo_ifac_rec.Loading_Comm_Date, ctr.loading_date_commenced),
                     ctr.loading_date_completed  = NVL(lo_ifac_rec.Loading_Date, ctr.loading_date_completed),
                     ctr.delivery_date_commenced = NVL(lo_ifac_rec.Delivery_Comm_Date, ctr.delivery_date_commenced),
                     ctr.delivery_date_completed = NVL(lo_ifac_rec.Delivery_Date, ctr.delivery_date_completed),
                     ctr.consignee               = NVL(ec_company_version.name(lo_ifac_rec.Consignee_Id, ld_daytime, '<='), ctr.consignee),
                     ctr.consignor               = NVL(ec_company_version.name(lo_ifac_rec.Consignor_Id, ld_daytime, '<='), ctr.consignor),
                     ctr.loading_port_id         = NVL(lo_ifac_rec.loading_port_id, ctr.loading_port_id),
                     ctr.Discharge_Port_Id       = NVL(lo_ifac_rec.Discharge_Port_Id, ctr.Discharge_Port_Id),
                     ctr.destination_country_id  = NVL(lv2_dest_country_id, ctr.destination_country_id),
                     ctr.origin_country_id       = NVL(lv2_origin_country_id, ctr.origin_country_id),
                     ctr.carrier_id              = NVL(lo_ifac_rec.Carrier_Id, ctr.carrier_id),
                     ctr.transaction_date        = NVL(lo_ifac_rec.Point_Of_Sale_Date, ctr.transaction_date),
                     ctr.price_date              = NVL(lo_ifac_rec.Price_Date, ctr.price_date),
                     ctr.bl_date                 = NVL(lo_ifac_rec.BL_Date, ctr.bl_date),
                     ctr.sales_order             = NVL(lo_ifac_rec.Product_Sales_Order_Id, ctr.sales_order),
                     ctr.price_object_id         = NVL(lo_ifac_rec.Price_Object_Id, ctr.price_object_id),
                     ctr.price_concept_code      = NVL(ec_product_price.price_concept_code(lo_ifac_rec.Price_Object_Id), ctr.price_concept_code),
                     ctr.product_id              = NVL(ec_product_price.product_id(lo_ifac_rec.Price_Object_Id), ctr.product_id)
               WHERE ctr.transaction_key = lv2_transaction_key;

               -- Get cont_transaction record
               lrec_ctr := ec_cont_transaction.row_by_pk(lv2_transaction_key);

               -- Handle price object reference from ifac on transaction
               -- (Handled by FillDocumentQuantity)
--               ecdp_transaction_qty.SetTransPriceObject(lv2_transaction_key, lrec_ctr.price_object_id, rsCargo.Price_Object_Id, p_daytime);

               -- Update/Set prices per transaction --
               /*WriteDocGenLog( 'INFO','Updating prices for transaction ' || lv2_transaction_key || '.', p_log_item_no);*/
               BEGIN
                  EcDp_Transaction.Filltransactionprice(lv2_transaction_key, ld_daytime, lv2_p_user,lo_ifac_rec.LINE_ITEM_BASED_TYPE);
               EXCEPTION
                  WHEN OTHERS THEN
                       GenDocException(lv2_p_object_id, lv2_NewDocKey, SQLCODE, SUBSTR(SQLERRM, 1, 240), 'ERROR', 'Y', p_log_item_no);
                       RETURN 'ERROR';
               END;

              ln_TranCounter := ln_TranCounter + 1;
              lv2_cargo_processed_ind := 'Y';

          END IF;

          -- If no transaction found => ERROR --
          IF ln_TranCounter = 0 THEN
             GenDocException(lv2_p_object_id, lv2_NewDocKey, 20000,
                                         'No Transaction found for Cargo [' || lv2_p_cargo_no ||
                                             '], Parcel [' || lo_ifac_rec.Parcel_No ||
                                             '], Product [' || ec_product.object_code(lo_ifac_rec.Product_Id) ||
                                             '], Field [' || ec_field.object_code(ec_stream_item_version.field_id(lrec_ttv.stream_item_id, ld_daytime, '<=')) ||
                                             ']', 'ERROR', 'Y', p_log_item_no);
             RETURN 'ERROR';
          ELSE
           null;
          END IF;

          ln_CargoCounter := ln_CargoCounter + 1;
            IF(lv2_transaction_key IS NOT NULL) THEN
                l_context.update_ifac_keys_cargo(
                lo_ifac_rec.TRANS_ID, lv2_transaction_key,
                lo_ifac_rec.LI_ID, lo_ifac_rec.LINE_ITEM_KEY);
            END if;

       END LOOP;
       EXCEPTION
           WHEN OTHERS THEN
               GenDocException(lv2_p_object_id, lv2_NewDocKey, SQLCODE, SUBSTR(SQLERRM, 1, 240), 'ERROR', 'Y', p_log_item_no);
               RETURN 'ERROR';
       END;

       IF nvl(EC_CTRL_SYSTEM_ATTRIBUTE.attribute_text(ld_p_document_date,'DEL_EMPTY_LI_ON_DOC_GEN','<='),'Y')='N'THEN
            l_logger.info('Generating additional transactions.');
             FOR ci_missing_trans IN ecdp_transaction.gc_transaction_tmpl_missing(lv2_NewDocKey) LOOP
                 if (ecdp_line_item.HasNonQtyLineItemTmpl(ci_missing_trans.object_id, ld_daytime) = ecdp_revn_common.gv2_true) then
                     lv2_transaction_key := ecdp_transaction.insnewtransaction(
                         p_object_id => lv2_p_object_id,
                         p_daytime => ld_daytime,
                         p_document_id => lv2_NewDocKey,
                         p_document_type => lrec_ttv.transaction_type,
                         p_trans_template_id => ci_missing_trans.object_id,
                         p_user => lv2_p_user,
                         p_trans_id => NULL
                         );
                     ln_TranCounter := ln_TranCounter+1;
                     l_logger.info('Created transaction [' || lv2_transaction_key || ']');
                 end if;
             END LOOP;
             EcDp_Document.UpdDocumentVat(lv2_NewDocKey, ec_cont_document.daytime(lv2_NewDocKey), NULL);
        END IF;

               l_logger.info('Processed ' || ln_TranCounter || ' of ' || ln_RecordCounter
                    || ' interfaced Cargo Quantity (transaction level) Records.');

               BEGIN
                    EcDp_Contract_Setup.updateAllDocumentDates(
                        lv2_p_object_id, lv2_NewDocKey, ld_daytime, ld_p_document_date, lv2_p_user);
               EXCEPTION
                    WHEN OTHERS THEN
                        GenDocException(lv2_p_object_id, lv2_NewDocKey, SQLCODE,
                            SUBSTR(SQLERRM, 1, 240), 'ERROR', 'Y', l_logger.log_no, lt_raise_error);
                        RETURN 'ERROR';
                END;



                l_logger.info('Generating interfaced line items in current document.');
                BEGIN
                    gen_li_f_ifac_cargo_p(l_context, l_document_info);--creates empty line items
                EXCEPTION
                    WHEN OTHERS THEN
                        lv2_loginfo := ' (when executing EcDp_Document_Gen.Gen_Li_F_Ifac_Cargo_P()).';
                        GenDocException(lv2_p_object_id, lv2_NewDocKey, SQLCODE,
                            SUBSTR(SQLERRM||lv2_loginfo, 1, 240), 'ERROR', 'Y', l_logger.log_no, lt_raise_error);
                        RETURN 'ERROR';
                END;

                 -- Updating quantities/prices on all non-reversal transactions in current document.
                l_logger.info('Updating quantities/prices on all non-reversal transactions in current document.');
                BEGIN
                    ecdp_document.fill_by_ifac_cargo_i(l_context, lv2_NewDocKey);
                EXCEPTION
                    WHEN OTHERS THEN
                        lv2_loginfo := ' (when executing EcDp_Document.Fill_By_Ifac_Cargo_I()).';
                        GenDocException(lv2_p_object_id, lv2_NewDocKey, SQLCODE,
                            SUBSTR(SQLERRM||lv2_loginfo, 1, 240), 'ERROR', 'Y', l_logger.log_no, lt_raise_error);
                        RETURN 'ERROR';
                END;

                IF nvl(EC_CTRL_SYSTEM_ATTRIBUTE.attribute_text(ld_p_document_date,'DEL_EMPTY_LI_ON_DOC_GEN','<='),'Y')='Y'THEN
                      -- Delete empty line items/transactions
                      l_logger.info('Deleting empty transactions on current document.');
                      BEGIN
                          Ecdp_Transaction.DelEmptyTransactions(lv2_NewDocKey);
                          ecdp_line_item.DelEmptyLineItemsFromTemp(lv2_NewDocKey);    --deletes empty line item with matched interface data
                      EXCEPTION
                          WHEN OTHERS THEN
                             GenDocException(lv2_p_object_id, lv2_NewDocKey, SQLCODE,
                                 SUBSTR(SQLERRM, 1, 240), 'ERROR', 'Y', l_logger.log_no, lt_raise_error);
                             RETURN 'ERROR';
                      END;
                END IF;

                -- Sort the transactions
                l_logger.info('Sorting transactions.');
                BEGIN
                    Ecdp_Transaction.SetAllTransSortOrder(lv2_NewDocKey);
                EXCEPTION
                    WHEN OTHERS THEN
                        GenDocException(lv2_p_object_id, lv2_NewDocKey, SQLCODE,
                            SUBSTR(SQLERRM, 1, 240), 'ERROR', 'N', l_logger.log_no, lt_raise_error);
                        RETURN 'ERROR';
                END;

                -- Validation of this newly created document will be performed by an separate businessaction,
                -- running after calculation. Returning new document_key.
                lv2_ReturnDocKey := lv2_NewDocKey;
                --l_context.apply_ifac_cargo_keys;
            END IF;
            -- Set status for this document generation
            IF lv2_RunStatus IS NULL OR (lv2_RunStatus NOT IN ('ERROR','WARNING')) THEN
                lv2_RunStatus := 'SUCCESS';
            END IF;
            FinalDocGenLog(l_logger, lv2_RunStatus);

            -- Setting return document key (either new or updated doc)
            p_new_doc_key := lv2_ReturnDocKey;

            -- Setting Recommended Action
            SetDocumentRecActionCode(lv2_ReturnDocKey);

            IF ue_cont_document.isGenCargoDocUEPostEnabled = 'TRUE' THEN
              ue_cont_document.GenCargoDocumentPost(lv2_p_object_id,
                                                 lv2_p_cargo_no,
                                                 lv2_p_parcel_no,
                                                 ld_p_daytime,
                                                 lv2_p_action,
                                                 lv2_p_contract_doc_id,
                                                 lv2_p_validation_level,
                                                 ld_p_document_date,
                                                 lv2_p_document_status,
                                                 lv2_p_gen_doc_key,
                                                 lv2_p_prec_doc_key,
                                                 lv2_p_loading_port_id,
                                                 lv2_p_customer_id,
                                                 lv2_p_source_node_id,
                                                 lv2_p_user,
                                                 lv2_p_owner,
                                                 p_log_item_no,
                                                 p_new_doc_key,
                                                 lv2_p_nav_id,
                                                 lv2_RunStatus);
               END IF;
            SELECT COUNT(transaction_key) INTO ln_count FROM cont_transaction
            WHERE document_key=lv2_NewDocKey
                AND ec_cont_transaction.document_key(preceding_trans_key) <> ec_cont_document.preceding_document_key(lv2_NewDocKey);
            IF (ln_count >0) THEN
                UPDATE Cont_Document cd
                SET cd.comments='Document has updates from transactions on PPA document(s)'
                WHERE cd.document_key=lv2_NewDocKey;
            END IF;
             l_context.apply_ifac_cargo_keys;

    RETURN lv2_RunStatus;
           EXCEPTION
           WHEN OTHERS THEN
         GenDocException(lv2_p_object_id, lv2_NewDocKey, SQLCODE, SUBSTR(SQLERRM, 1, 240), 'ERROR', 'N', l_logger.log_no);
         RETURN 'ERROR';
  END;
    END IF;

END GenCargoDocument;
-------------------------------------------------------------------------------------------------

FUNCTION GenPeriodDocument(p_object_id         VARCHAR2, -- Contract
                           p_processing_period DATE,
                           p_period_from       DATE,
                           p_period_to         DATE,
                           p_action            VARCHAR2,
                           p_contract_doc_id   VARCHAR2,
                           p_document_date     DATE,
                           p_document_status   VARCHAR2,
                           p_prec_doc_key      VARCHAR2, -- Preceding document, either if it is booked (create dependent/reversal/reallocation) or not (update qty)
                           p_delivery_point_id VARCHAR2,
                           p_customer_id       VARCHAR2,
                           p_source_node_id    VARCHAR2,
                           p_user              VARCHAR2,
                           p_owner             VARCHAR2,
                           p_log_item_no       IN OUT NUMBER,
                           p_new_doc_key       IN OUT VARCHAR2,
                           p_nav_id            VARCHAR2, -- For logging purposes
                           p_silent            ecdp_revn_common.T_BOOLEAN_STR DEFAULT ecdp_revn_common.gv2_true
                           ) RETURN VARCHAR2
IS
    -- Copy of parameters so that they can be changed by user exists
    lv2_p_object_id        VARCHAR2(32)  := p_object_id;
    ld_p_processing_period DATE          := p_processing_period;
    ld_p_period_from       DATE          := p_period_from;
    ld_p_period_to         DATE          := p_period_to;
    lv2_p_action           VARCHAR2(100) := p_action;
    lv2_p_contract_doc_id  VARCHAR2(32)  := p_contract_doc_id;
    ld_p_document_date     DATE          := p_document_date;
    lv2_p_document_status  VARCHAR2(100) := p_document_status;
    lv2_p_prec_doc_key     VARCHAR2(100) := p_prec_doc_key;
    lv2_p_delivery_point_id VARCHAR2(32) := p_delivery_point_id;
    lv2_p_customer_id      VARCHAR2(32)  := p_customer_id;
    lv2_p_source_node_id   VARCHAR2(32)  := p_source_node_id;
    lv2_p_user             VARCHAR2(100) := p_user;
    lv2_p_owner            VARCHAR2(100) := p_owner;
    lv2_p_nav_id           VARCHAR2(2000):= p_nav_id;

    lv2_ReturnDocKey       VARCHAR2(32) := NULL;
    lv2_NewDocKey          VARCHAR2(32) := NULL;
    lv2_NewRevDocKey       VARCHAR2(32) := NULL;
    lv2_prec_mpd_doc_key   VARCHAR2(32) := NULL;
    lv2_RunStatus          VARCHAR2(32) := NULL; -- ERROR, WARNING or SUCCESS
    lv2_use_doc_key        VARCHAR2(32) := NULL;
    lv2_loginfo            VARCHAR2(240);
    lv2_prec_doc_val_level VARCHAR2(32);
    lv2_transaction_key    cont_transaction.transaction_key%type;
    lv2_reversal_trans_key cont_transaction.transaction_key%type;
    lv2_ifac_price_object  VARCHAR2(32) := NULL;
    ln_RecordCounter       NUMBER := 0;
    ln_TranCounter         NUMBER := 0;
    ld_daytime             DATE;
    lrec_ttv               transaction_tmpl_version%rowtype;
    lb_alternative_customer_set BOOLEAN;
    generation_error       EXCEPTION;
    lv2_delete_doc         VARCHAR2(1) :='N';
    lv2_mpd_ind            VARCHAR2(1);
    v_check                NUMBER;
    ln_count               NUMBER;
    lv2_preceding_trans_key varchar2(32);
    lv2_ifac_doc_status_filter varchar2(32);
    lt_ifac_to_process_doc T_TABLE_IFAC_SALES_QTY;
    lo_ifac_rec            T_IFAC_SALES_QTY;
    l_context              t_revn_doc_op_context;
    lt_ifac_to_process_trans T_TABLE_IFAC_SALES_QTY;
    lo_ifac_li_types       t_table_varchar2;
    lt_raise_error         ecdp_revn_common.T_BOOLEAN_STR;
    l_logger               t_revn_logger;

    CURSOR c_ifac_no_doc_setup(
        cp_contract_id       VARCHAR2,
        cp_processing_period DATE,
        cp_doc_status        VARCHAR2,
        cp_customer_id       VARCHAR2,
        cp_delivery_point_id VARCHAR2) IS
        SELECT source_entry_no
          FROM IFAC_SALES_QTY i
         WHERE i.contract_id = cp_contract_id
           AND i.processing_period = cp_processing_period
           AND i.customer_id = cp_customer_id
           AND i.doc_status = cp_doc_status
           AND nvl(i.delivery_point_id,'xx') = nvl(cp_delivery_point_id,nvl(i.delivery_point_id,'xx'))
           AND i.doc_setup_id is null;

     CURSOR c_processing_records(
        cp_contract_id       VARCHAR2,
        cp_processing_period DATE,
        cp_doc_status        VARCHAR2,
        cp_customer_id       VARCHAR2,
        cp_delivery_point_id VARCHAR2) IS
        SELECT *
          FROM v_period_document_process pdp
         WHERE pdp.contract_id = cp_contract_id
           AND pdp.processing_period = cp_processing_period
           AND pdp.doc_status = cp_doc_status
           AND pdp.customer_id = cp_customer_id
           AND nvl(pdp.delivery_point_id,'xx') = nvl(cp_delivery_point_id,'xx')
           AND pdp.doc_setup_id is not null;

    l_use_trans_key      cont_transaction.transaction_key%TYPE;
    lv2_missing_doc_ifac ifac_sales_qty%rowtype;
    lv2_updated_doc_ifac ifac_sales_qty%rowtype;
    l_preceding_li_key   cont_line_item.line_item_key%TYPE;
    l_preceding_doc_key  cont_document.document_key%TYPE;
    l_temp_line_item_keys    t_table_varchar2;
    l_document_info          t_revn_ft_doc_info;
    l_preceding_li_keys                t_table_varchar2;
BEGIN
    IF ue_cont_document.isGenPeriodDocUEEnabled = 'TRUE' THEN
        -- INSTEAD-OF user exit
        RETURN ue_cont_document.GenPeriodDocument(lv2_p_object_id,
                                                    ld_p_processing_period,
                                                    ld_p_period_from,
                                                    ld_p_period_to,
                                                    lv2_p_action,
                                                    lv2_p_contract_doc_id,
                                                    ld_p_document_date,
                                                    lv2_p_document_status,
                                                    lv2_p_prec_doc_key,
                                                    lv2_p_delivery_point_id,
                                                    lv2_p_customer_id,
                                                    lv2_p_source_node_id,
                                                    lv2_p_user,
                                                    lv2_p_owner,
                                                    p_log_item_no,
                                                    p_new_doc_key,
                                                    lv2_p_nav_id);
    ELSE
        lt_raise_error := CASE p_silent
            WHEN ecdp_revn_common.gv2_false THEN ecdp_revn_common.gv2_true
            WHEN ecdp_revn_common.gv2_true THEN ecdp_revn_common.gv2_false
            ELSE ecdp_revn_common.gv2_false END;

        l_context := t_revn_doc_op_context();
        l_context.config_logger(p_log_item_no, 'PERIOD_DG');
        l_context.user_id := p_user;
        l_context.processing_contract_id := lv2_p_object_id;
        l_context.get_or_create_logger(l_logger);

        l_logger.update_overall_state(lv2_p_nav_id, ecdp_revn_log.LOG_STATUS_RUNNING);
        l_logger.update_overall_data(lv2_p_object_id, NULL, NULL, NULL, NULL, NULL, ld_p_processing_period, NULL);
        l_logger.info('Start document processing.');
        p_log_item_no := l_logger.log_no;

        BEGIN
            -- PRE user exit
            IF ue_cont_document.isGenPeriodDocUEPreEnabled ='TRUE' THEN
                        ue_cont_document.GenPeriodDocumentPre(lv2_p_object_id,
                                                                ld_p_processing_period,
                                                                ld_p_period_from,
                                                                ld_p_period_to,
                                                                lv2_p_action,
                                                                lv2_p_contract_doc_id,
                                                                ld_p_document_date,
                                                                lv2_p_document_status,
                                                                lv2_p_prec_doc_key,
                                                                lv2_p_delivery_point_id,
                                                                lv2_p_customer_id,
                                                                lv2_p_source_node_id,
                                                                lv2_p_user,
                                                                lv2_p_owner,
                                                                p_log_item_no,
                                                                lv2_p_nav_id);
            END IF;

            lb_alternative_customer_set := FALSE;
            IF lv2_p_user <> lv2_p_owner THEN
               l_logger.info('Record(s) are owned by user (' || lv2_p_owner || ')');
               RETURN 'IGNORE';
            END IF;

            -- Check to see if possible new preceding was just created due to new transaction on document
            IF lv2_p_contract_doc_id IS NULL THEN
                l_logger.info('Contract Doc is missing will run reanalysis to see if a new preceding was just created to add this to a dependent');

                FOR missing_doc_setup in c_ifac_no_doc_setup(
                    lv2_p_object_id,
                    ld_p_processing_period,
                    lv2_p_document_status,
                    lv2_p_customer_id,
                    lv2_p_delivery_point_id) LOOP
                    lv2_missing_doc_ifac := ec_ifac_sales_qty.row_by_pk(missing_doc_setup.source_entry_no);
                    lv2_updated_doc_ifac := ecdp_inbound_interface.ReAnalyseSalesQtyRecord(lv2_missing_doc_ifac);

                    IF lv2_updated_doc_ifac.doc_setup_code IS NOT NULL THEN
                        l_logger.info(
                          'A document setup was found (' || lv2_updated_doc_ifac.doc_setup_code
                          || ') and will be used for ifac record:' || missing_doc_setup.Source_Entry_No);

                        UPDATE IFAC_SALES_QTY
                        SET ROW = lv2_updated_doc_ifac
                        WHERE Source_Entry_No = missing_doc_setup.Source_Entry_No;
                    END IF;
                END LOOP;

                FOR records in c_processing_records(
                    lv2_p_object_id,
                    ld_p_processing_period,
                    lv2_p_document_status,
                    lv2_p_customer_id,
                    lv2_p_delivery_point_id) LOOP

                    lv2_p_action := records.action;
                    lv2_p_prec_doc_key := records.prec_doc_key;
                    ld_p_document_date := records.doc_date;
                    lv2_p_contract_doc_id := records.doc_setup_id;

                    IF lv2_p_contract_doc_id is not null then
                        l_logger.warning('The Reanalysis resulted in multiple new documents. One will be created now, you will need to reprocess to get the additional documents.');
                    END IF;
                END LOOP;
            END IF;

            ValidateDocProcessParams(lv2_p_object_id, lv2_p_contract_doc_id, 'EcDp_Document_Gen.GenPeriodDocument()');

            -- Resolve Document Version Date (Daytime)
            ld_daytime := EcDp_document.GetDocumentDaytime(lv2_p_object_id, lv2_p_contract_doc_id, ld_p_document_date);

            IF lv2_p_prec_doc_key = 'MULTIPLE' THEN
                lv2_prec_mpd_doc_key := ecdp_document_gen_util.GetPeriodPrecedingDocKeyMPD(
                    lv2_p_contract_doc_id, lv2_p_customer_id, lv2_p_document_status, ld_p_processing_period);
                lv2_prec_doc_val_level := ec_cont_document.document_level_code(lv2_prec_mpd_doc_key);
            ELSE
                lv2_prec_doc_val_level := ec_cont_document.document_level_code(lv2_p_prec_doc_key);
            END IF;

            -- See if any accrual document in the same processing period and have same document
            -- setup have been reversed and all reversal documents have been booked. If yes
            -- then this ifac record can be processed, skip otherwise.
            IF (EcDp_Document_Gen_Util.GetHoldFinalWhenAclInd(lv2_p_contract_doc_id, ld_p_processing_period) = 'Y'
                    OR ec_cont_document.status_code(nvl(lv2_prec_mpd_doc_key,lv2_p_prec_doc_key)) = 'ACCRUAL')
                AND lv2_p_document_status = 'FINAL' THEN
                IF EcDp_Document_Gen_Util.HasNotReversedAccrualDoc(
                       lv2_p_contract_doc_id, lv2_p_customer_id, ld_p_processing_period) = 'Y' THEN
                    l_logger.warning('Final records found and cannot be processed until accruals are reversed.');
                    RETURN 'IGNORE';
                END IF;

                IF lv2_p_document_status = 'ACCRUAL' AND p_prec_doc_key IS NOT NULL THEN
                    l_logger.warning('Booked Accrual document found and new accrual cannot be processed until '
                        || 'accruals are reversed.');
                    RETURN 'IGNORE';
                END IF;
            END IF;

            l_logger.debug('Action for this Contract Period Qty record is: [' || lv2_p_action || '].');
            l_logger.debug('Customer on this Period Qty record is: [' || ecdp_objects.getobjcode(lv2_p_customer_id) || '].');

            IF lv2_p_action IN ('CREATE_INVOICE', 'CREATE_DEPENDENT', 'CREATE_REALLOCATION', 'CREATE_REVERSAL',
                            'CREATE_MPD', 'CREATE_RECON', 'APPEND_MPD', 'APPEND_OR_UPDATE_DOC') THEN
                -- Validate important parameters
                IF lv2_p_contract_doc_id IS NULL THEN
                    GenDocException(lv2_p_object_id, NULL, -20000,
                        'DocProcess Can not create document without a Document Setup. This is missing from interfaced data.',
                        ecdp_revn_log.LOG_STATUS_ITEM_ERROR, 'N', l_logger.log_no, lt_raise_error);
                END IF;

                --case when lv2_p_action IN( 'APPEND_MPD','CREATE_MPD') then lv2_p_document_status else NULL end
                prepare_ifac_period_p(
                    l_context, lv2_p_object_id, lv2_p_contract_doc_id, ld_p_processing_period, lv2_p_customer_id, lv2_p_document_status);
            END IF;

            IF lv2_p_action IN ('UPDATE_DOC') THEN
                prepare_ifac_period_p(
                    l_context, lv2_p_object_id, lv2_p_contract_doc_id, ld_p_processing_period, lv2_p_customer_id, lv2_p_document_status);
            END IF;

            lt_ifac_to_process_doc := l_context.ifac_period;

            -- UPDATE_DOC: If a full set of new quantity has arrived for a period, and previous generated
            --     document has not been booked, run "update qty" function.
            -- UPDATE_DOC_PARTIAL: If a partial set of new quantity has arrived for a period, and previous
            --     generated document has not been booked, run "update qty" function.
            -- APPEND_MPD: If a MPD document has got pending updates on existing transactions, it gets action
            --     "Append MPD".
            IF lv2_p_action IN ('APPEND_OR_UPDATE_DOC','UPDATE_DOC','APPEND_MPD') THEN
                BEGIN
                    -- Get the document that is to be updated (using prec_doc_key field).
                    -- Updated qtys has been inserted on a non-booked document.
                    lv2_use_doc_key := lv2_p_prec_doc_key;

                    -- Special handling for Multi Period Document/Reconciliation
                    IF lv2_use_doc_key = 'MULTIPLE' THEN
                        lv2_use_doc_key := lv2_prec_mpd_doc_key;
                    END IF;

                    IF ec_cont_document.document_level_code(lv2_use_doc_key) IN ('VALID1','VALID2','OPEN') THEN
                        IF lv2_use_doc_key IS NOT NULL THEN
                            -- Move the document down to OPEN if validated.
                            IF ec_cont_document.document_level_code(lv2_use_doc_key) IN ('VALID1','VALID2') THEN
                                -- Abort if system attribute PROCESS_ONLY_OPEN_DOCS is ON
                                IF upper(ec_ctrl_system_attribute.attribute_text(Ecdp_Timestamp.getCurrentSysdate, 'PROCESS_ONLY_OPEN_DOCS', '<=')) = 'Y' THEN
                                    l_logger.info('New quantities or prices have been found for document "'
                                        || lv2_use_doc_key || '", but the document will not be updated. The new '
                                        || 'quantities or prices will be updated in the document if the document '
                                        || 'is manually set back to Open.');
                                    RETURN 'WARNING';
                                END IF;

                                l_logger.info('Preparing quantity update on document. Moving from '
                                    || ec_cont_document.document_level_code(lv2_use_doc_key)
                                    || ' to OPEN on Document [' || lv2_use_doc_key || ']');
                                l_logger.debug('Document Level Code BEFORE: ' || ec_cont_document.document_level_code(lv2_use_doc_key));

                                SetDocumentValidationLevel_P(lv2_use_doc_key, 'OPEN', lv2_p_user);

                                l_logger.debug('Document Level Code AFTER: '
                                    || ec_cont_document.document_level_code(lv2_use_doc_key));
                            END IF;

                            -- Distribute qtys on the different fields according to field splits --
                            -- This is done on the preceding document, because this record is a new allocation of the initial processed quantity record.
                            l_logger.info('Distributing the Quantities according to field adherence.');
                            l_logger.debug('Contract: ' || ec_contract.object_code(lv2_p_object_id)
                                || ', Document: ' || lv2_use_doc_key || ', user: ' || lv2_p_user);

                            refresh_prec_keys_period_p(TRUE, l_context);
                            -- copies preceding keys to keys, where preceding doc key is the one being updated
                            set_prec_keys_as_keys_period_p(lv2_use_doc_key, l_context, TRUE);
                            l_context.apply_ifac_period_keys;

                            ecdp_document.fill_by_ifac_period_i(l_context, lv2_use_doc_key);

                            if  lv2_p_action != 'APPEND_MPD' then --Only clean records when they are not for appending an mpd
								l_context.remove_ifac_has_li_key_period;
                            end if;

                            lt_ifac_to_process_doc := l_context.ifac_period;
                        ELSE
                            GenDocException(lv2_p_object_id, NULL, -20000,
                                'Can not update quantity on document. No document available.',
                                'ERROR', 'N', l_logger.log_no, lt_raise_error);
                            RETURN 'ERROR';
                        END IF;
                    END IF;
                EXCEPTION
                    WHEN OTHERS THEN
                        GenDocException(lv2_p_object_id, lv2_use_doc_key, SQLCODE,
                            SUBSTR(SQLERRM, 1, 240), 'WARNING', 'N', l_logger.log_no, lt_raise_error);
                        RETURN 'WARNING';
                END;

                -- Document is now OPEN and should not be re-validated up to its previous level,
                -- because it is a user process to validate that the new qtys and prices are correct.

                -- Returning updated document_key
                lv2_ReturnDocKey := lv2_use_doc_key;
            END IF;

            -- UPDATE_PRICE: If price has been updated on non-booked doc, no new document should be
            --     created, but only run the price update functionality.
            IF lv2_p_action = 'UPDATE_PRICE' THEN
                BEGIN
                    IF ec_cont_document.document_level_code(lv2_use_doc_key) IN ('VALID1','VALID2','OPEN') THEN
                        -- Generated doc column is used to store doc key that need to be updated with new price
                        lv2_use_doc_key := lv2_p_prec_doc_key;

                        -- Special handling for Multi Period Document/Reconciliation
                        IF p_prec_doc_key = 'MULTIPLE' THEN
                            lv2_use_doc_key := lv2_prec_mpd_doc_key;
                        END IF;

                        -- Move the document down to OPEN if validated.
                        IF ec_cont_document.document_level_code(lv2_use_doc_key) IN ('VALID1','VALID2') THEN
                            l_logger.info('Preparing price update on document. Moving from '
                                || ec_cont_document.document_level_code(lv2_use_doc_key)
                                || ' to OPEN on Document [' || lv2_use_doc_key || ']');
                            l_logger.debug('Document Level Code BEFORE: '
                                || ec_cont_document.document_level_code(lv2_use_doc_key));

                            SetDocumentValidationLevel_P(lv2_use_doc_key, 'OPEN', lv2_p_user);

                            l_logger.debug('Document Level Code AFTER: '
                                || ec_cont_document.document_level_code(lv2_use_doc_key));
                        END IF;

                        -- Generated doc column is used to store doc key that need to be updated with new price
                        -- Update prices on all transaction in current document
                        l_logger.info('Updating prices on all non-reversal transactions in current document.');
                        l_logger.debug('Contract: ' || ec_contract.object_code(lv2_p_object_id)
                            || ', Document: ' || lv2_use_doc_key
                            || ', user: ' || lv2_p_user);

                        EcDp_Document.FillDocumentPrice(lv2_use_doc_key, lv2_p_user);
                    END IF;
                EXCEPTION
                    WHEN OTHERS THEN
                        GenDocException(lv2_p_object_id, lv2_use_doc_key, SQLCODE,
                            SUBSTR(SQLERRM, 1, 240), 'WARNING', 'N', l_logger.log_no, lt_raise_error);
                        RETURN 'WARNING';
                END;

                -- Document is now OPEN and should not be re-validated up to its previous level,
                -- because it is a user process to validate that the new qtys and prices are correct.
                -- Returning updated document_key
                lv2_ReturnDocKey := lv2_use_doc_key;
            END IF;

            -- REVERSAL DOCUMENT --
            -- If this document is a completely new document, replacing the previous BOOKED document
            -- for the same period record, we need to create a reversal document.
            --
            -- Action for this document was Create Reversal:
            -- Generate reversal document with EcDp_Document.GenReverseDocument. If error, do not create new doc.
            -- Validate reversal document to the same level as the new document. If validation of reversal gives
            --     error, still create and validate new doc, but give warning.
            IF lv2_p_action = 'CREATE_REVERSAL' AND lv2_p_prec_doc_key IS NOT NULL THEN
                l_logger.info('CREATING NEW REVERSAL DOCUMENT: Period [' || to_char(ld_p_period_from) || '] on Contract [' || ec_contract_version.name(lv2_p_object_id, ld_daytime, '<=') || '] based on Document [' || lv2_p_prec_doc_key || ']');
                l_logger.debug('Calling EcDp_Document.GenReverseDocument with contract_id [' || lv2_p_object_id || '], contract_doc_id [' || lv2_p_contract_doc_id || '], preceding_doc_key [' || lv2_p_prec_doc_key || '], and p_user [' || lv2_p_user || '].');
                BEGIN
                    -- Setting the document key for the reversal in order to support delete if something goes wrong.
                    lv2_NewRevDocKey := EcDp_Document.GetNextDocumentKey(lv2_p_object_id, ld_daytime);

                    -- Create the reversal
                    lv2_NewRevDocKey := EcDp_Document.GenReverseDocument(
                        lv2_p_object_id, lv2_p_prec_doc_key, p_log_item_no,
                        lv2_p_user, 'N', lv2_NewRevDocKey);
                EXCEPTION
                    WHEN OTHERS THEN
                        GenDocException(lv2_p_object_id, lv2_NewRevDocKey, SQLCODE,
                            SUBSTR(SQLERRM, 1, 240), 'ERROR', 'Y', l_logger.log_no, lt_raise_error);
                        RETURN 'ERROR';
                END;
                l_logger.info('Reversal Document Created. Key: ' || lv2_NewRevDocKey);
            END IF;

            -- CREATE_INVOICE: Creates a new document
            -- CREATE_DEPENDENT: Creates a dependent document
            -- APPEND_MPD: A MPD document has got pending updates OR appendable transactions in IFAC.
            IF lv2_p_action IN ('CREATE_INVOICE', 'CREATE_DEPENDENT', 'CREATE_REALLOCATION', 'CREATE_REVERSAL',
                            'CREATE_MPD', 'CREATE_RECON', 'APPEND_MPD', 'APPEND_OR_UPDATE_DOC') THEN
                lv2_use_doc_key := lv2_p_prec_doc_key;

                -- Update preceding transactions in case something has changed
                l_logger.debug('Update preceding transactions in case something has changed');
                BEGIN
                    -- commented out, updating preceding keys will not affect the process
                    -- OR lo_ifac_rec.Doc_Status = lv2_p_document_status

                    refresh_prec_keys_period_p(true, l_context);

                    FOR ifac_idx in 1 .. lt_ifac_to_process_doc.count LOOP
                        lo_ifac_rec := lt_ifac_to_process_doc(ifac_idx);

                        IF l_preceding_doc_key IS NOT NULL THEN
                            lv2_use_doc_key := l_preceding_doc_key;
                            EXIT;
                        END IF;
                    END LOOP;
                EXCEPTION
                    WHEN OTHERS THEN
                        GenDocException(lv2_p_object_id, lv2_NewDocKey, SQLCODE, SUBSTR(SQLERRM, 1, 240),
                            'ERROR', 'Y', l_logger.log_no, lt_raise_error);
                        RETURN 'ERROR';
                END;

                -- Special handling for Multi Period Document/Reconciliation
                IF p_prec_doc_key = 'MULTIPLE' THEN
                    lv2_use_doc_key := lv2_prec_mpd_doc_key;
                END IF;

                lv2_prec_doc_val_level := ec_cont_document.document_level_code(lv2_use_doc_key);

                -- Verify that the preceding document has been booked
                IF lv2_use_doc_key IS NOT NULL AND lv2_prec_doc_val_level != 'BOOKED' AND lv2_p_action NOT IN ( 'APPEND_MPD','APPEND_OR_UPDATE_DOC') THEN
                    GenDocException(lv2_p_object_id, NULL, -20000, 'Can not create a document that depends on preceding document ' || lv2_use_doc_key || '. The preceding document must be booked, but is currently at level ' || lv2_prec_doc_val_level || '.', 'ERROR', 'N', l_logger.log_no, lt_raise_error);
                    RETURN 'ERROR';
                END IF;

                -- Do not create new document if this is appending on a MPD document
                IF lv2_p_action in ('APPEND_MPD','APPEND_OR_UPDATE_DOC') THEN
                    lv2_NewDocKey := lv2_use_doc_key;
                ELSE

               -- Create a blank document with input document setup. --
                 l_logger.info('Creating Document [' || ec_contract_doc_version.name(lv2_p_contract_doc_id, ld_daytime,'<=') ||
                                        '] for period [' || ld_p_period_from ||
                                        '] to [' || ld_p_period_to ||
                                        '] on Contract [' || ec_contract_version.name(lv2_p_object_id, ld_daytime, '<=') || ']');

                 BEGIN
                   -- Generating a new document key so that it can be used to delete document if something fails within EcDp_Document.InsNewDocument.
                   lv2_NewDocKey := EcDp_Document.GetNextDocumentKey(lv2_p_object_id, ld_daytime);

                   l_context.processing_document_key := lv2_NewDocKey;
                   l_context.get_or_create_logger(l_logger);

                   -- Calling GenDocumentSet with pre-generated document key
                   lv2_NewDocKey := EcDp_Document.GenDocumentSet_I(l_context,
                                                                 lv2_p_object_id,
                                                                 lv2_p_contract_doc_id,
                                                                 lv2_use_doc_key,
                                                                 ld_daytime,
                                                                 ld_p_document_date,
                                                                 NULL,
                                                                 lv2_NewDocKey,
                                                                 'N'); -- Make an empty document with no transactions

                 EXCEPTION
                     WHEN OTHERS THEN
                         GenDocException(lv2_p_object_id, lv2_NewDocKey, SQLCODE, SUBSTR(SQLERRM, 1, 240), 'ERROR', 'Y', l_logger.log_no, lt_raise_error);
                         RETURN 'ERROR';
                 END;
                 l_logger.info('Document Created. Key: ' || lv2_NewDocKey);

              END IF;

              l_context.update_all_ifac_doc_key_period(lv2_NewDocKey);
              l_document_info := t_revn_ft_doc_info(lv2_NewDocKey);
              l_document_info.refresh;

               -- If the document we have created is a dependent type document
               -- (except 'Dependent Document without reversal' / 'DEPENDENT_WITHOUT_REVERSAL')
               -- and the document status for the new doc is different from the document status
               -- of the preceding document we can not create a new doc
               IF lv2_NewDocKey is not null THEN
                  IF l_document_info.concept in (
                      'DEPENDENT', 'DEPENDENT_PARTIALLY_REVERSAL', 'DEPENDENT_ONLY_QTY_REVERSAL',
                      'DEPENDENT_PREV_MTH_CORR', 'MPD') THEN

                     IF ec_cont_document.status_code(lv2_p_prec_doc_key) <> lv2_p_document_status THEN
                        GenDocException(lv2_p_object_id, lv2_NewDocKey, -20000, 'Can not create dependent document with a different Document Status (Accrual/Final) that is different from the preceding document.', 'ERROR', 'Y', l_logger.log_no, lt_raise_error);
                        RETURN 'ERROR';
                     END IF;
                  END IF;
               END IF;


               -- Update cont_document set document_status_code = p_document_status --
               l_logger.info('Updating document ' || lv2_NewDocKey || ' - Setting Document Status to: ' || lv2_p_document_status);

               l_document_info.status := lv2_p_document_status;
               l_document_info.processing_period := ld_p_processing_period;

               UPDATE cont_document
                  SET status_code = l_document_info.status,
                      processing_period = l_document_info.processing_period
                WHERE document_key = l_document_info.key;

               IF lv2_p_customer_id IS NOT NULL
                   AND lv2_p_customer_id <> NVL(l_document_info.customer_id, '$NULL$')
                   AND lv2_p_action != 'APPEND_MPD'
               THEN
                   lb_alternative_customer_set := TRUE;
               END IF;

               IF lb_alternative_customer_set
               THEN
                   BEGIN
                       -- Alternative customer id is provided, need to use it to replace the default value
                       -- This has to be done before the document is filled
                       EcDp_Document.updateDocumentCustomer(lv2_NewDocKey,
                                                            lv2_p_object_id,
                                                            lv2_p_contract_doc_id,
                                                            l_document_info.level_code,
                                                            ld_daytime,
                                                            l_document_info.booking_currency_id,
                                                            lv2_p_user,
                                                            lv2_p_customer_id,
                                                            TRUE);
                   EXCEPTION
                       WHEN OTHERS
                       THEN
                           GenDocException(lv2_p_object_id, lv2_NewDocKey, SQLCODE, SUBSTR(SQLERRM, 1, 240), 'ERROR', 'Y', l_logger.log_no, lt_raise_error);
                           RETURN 'ERROR';
                   END;
               END IF;


                if lv2_p_action in ('APPEND_MPD','CREATE_MPD') then
                    lv2_ifac_doc_status_filter := lv2_p_document_status;
                end if;

                -- process interface records by transacion
                FOR ifac_idx in 1 .. lt_ifac_to_process_doc.count LOOP
                    lo_ifac_rec := lt_ifac_to_process_doc(ifac_idx);

                    -- only transaction level is interested now
                    IF lo_ifac_rec.INTERFACE_LEVEL <> ecdp_revn_ifac_wrapper.gconst_level_transaction THEN
                        continue;
                    end if;

                    -- filter the transaction by doc status if required
                    if lv2_ifac_doc_status_filter is not null and lo_ifac_rec.doc_status <> lv2_ifac_doc_status_filter then
                        continue;
                    end if;

                    lt_ifac_to_process_trans := ecdp_revn_ifac_wrapper_period.filter(
                        lt_ifac_to_process_doc,
                        p_trans_id => lo_ifac_rec.trans_id,
                        p_level => NULL,
                        p_li_id => NULL,
                        p_transaction_key => NULL);
                    lo_ifac_li_types := ecdp_revn_ifac_wrapper_period.aggregate(lt_ifac_to_process_trans, 'line_item_based_type');

                    lrec_ttv := ec_transaction_tmpl_version.row_by_pk(lo_ifac_rec.trans_temp_id, ld_daytime,'<=');
                    lv2_transaction_key := NULL;

                    IF lrec_ttv.price_object_id IS NULL THEN
                        lv2_ifac_price_object := lo_ifac_rec.Price_Object_Id;
                    ELSE
                        lv2_ifac_price_object := NULL;
                    END IF;


                    -- Transactions are created from scratch based on interface values and applied to the new document
                    l_logger.info('Processing Transaction: Product: [' || ec_product.object_code(lo_ifac_rec.Product_ID)
                        || '], Price Concept: [' || lo_ifac_rec.Price_Concept_Code
                        || '], Delivery Point: [' || ec_delivery_point.object_code(lo_ifac_rec.Delivery_point_id)
                        ||' ], Qty Status: [' || lo_ifac_rec.Qty_Status || ']');

                    ln_RecordCounter := ln_RecordCounter + 1;

                    IF lv2_p_action != 'CREATE_REVERSAL' THEN
                        -- If Multi Period document, transactions will have got their preceding transactions reference,
                        -- if it is an adjustment quantity, and NO preceding if this is a provisional quantity.
                        -- If Reconciliation, all transactions should have a preceding transaction reference.
                        -- Normally multiple preceding documents, hence the special treatment...
                        IF lv2_p_action IN ('CREATE_MPD','CREATE_RECON','APPEND_MPD','APPEND_OR_UPDATE_DOC') THEN
                            -- If Appending a MPD and the current transaction is already on the document
                            IF lv2_p_action = 'APPEND_MPD'
                                AND lv2_NewDocKey = ec_cont_transaction.document_key(lo_ifac_rec.preceding_trans_key) THEN
                                IF lo_ifac_rec.Qty_Status = ec_cont_transaction.qty_type(lo_ifac_rec.preceding_trans_key)  or
                                  lo_ifac_rec.Qty_Status = 'PPA' then
                                    lv2_transaction_key := lo_ifac_rec.Preceding_Trans_Key;
                                ELSE
                                    GenDocException(lv2_p_object_id, lv2_NewDocKey, SQLCODE,
                                        'Current MPD has records that have qty status changes. Delete and recreate the document.',
                                        'ERROR', 'N', l_logger.log_no, lt_raise_error);
                                    RETURN 'ERROR';
                                END IF;
                            ELSE
                                -- First reverse the preceding transaction. This is done automatically if creating dependent
                                -- document. Now we are creating a "multi dependent document", where we have multiple preceding
                                -- documents. Hence, we must reverse transactions explicitly.
                                IF lo_ifac_rec.preceding_trans_key IS NOT NULL THEN
                                    -- If preceding transaction is on an Accrual document it must first be reversed and the document
                                    -- should be prevented
                                    IF lv2_p_action IN ('CREATE_MPD','APPEND_MPD')
                                        AND ec_cont_document.status_code(ec_cont_transaction.document_key(lo_ifac_rec.preceding_trans_key)) = 'ACCRUAL'THEN
                                        if lv2_p_action = 'CREATE_MPD' THEN
                                            lv2_delete_doc := 'Y';
                                        END IF;

                                        IF lv2_p_document_status = 'FINAL' THEN
                                            GenDocException(lv2_p_object_id, lv2_NewDocKey, null,
                                                'Final records found and cannot be processed until accruals are reversed.',
                                                'ERROR', lv2_delete_doc, l_logger.log_no, lt_raise_error);
                                            RETURN 'ERROR';
                                        END IF;

                                        IF lv2_p_document_status = 'ACCRUAL' THEN
                                            GenDocException(lv2_p_object_id, lv2_NewDocKey, null,
                                                'Booked Accrual document found and new accrual cannot be processed until accruals are reversed.',
                                                'ERROR', lv2_delete_doc, l_logger.log_no, lt_raise_error);
                                            RETURN 'ERROR';
                                        END IF;
                                    END IF;


                                    -- reverse the transaction if the preceding transaction is not the one on updating document
                                    IF ec_cont_transaction.document_key(lo_ifac_rec.preceding_trans_key) != lv2_NewDocKey THEN
                                        l_logger.debug('Reversing preceding transaction [' || lo_ifac_rec.Preceding_Trans_Key || ']');
                                        lv2_reversal_trans_key := ecdp_transaction.ReverseTransaction(
                                            lv2_p_object_id,
                                            ld_daytime,
                                            lv2_NewDocKey,
                                            lo_ifac_rec.preceding_trans_key,
                                            lv2_p_user);
                                    ELSE
                                        lv2_transaction_key := lo_ifac_rec.preceding_trans_key;
                                    END IF;
                                END IF;

                                -- Then create the adjustment transaction or the NEW
                                IF lv2_p_action = 'APPEND_OR_UPDATE_DOC' THEN
                                    lv2_mpd_ind := 'N';
                                ELSE
                                    lv2_mpd_ind := 'Y';
                                END IF;

                                IF lv2_transaction_key IS NULL THEN
                                    lv2_transaction_key := ecdp_transaction.insnewtransaction(
                                        lv2_p_object_id,
                                        ld_daytime,
                                        lv2_NewDocKey,
                                        lrec_ttv.transaction_type,
                                        lo_ifac_rec.trans_temp_id,
                                        lv2_p_user,
                                        NULL,
                                        lo_ifac_rec.preceding_trans_key,
                                        lo_ifac_rec.unique_key_1,
                                        lo_ifac_rec.unique_key_2,
                                        lo_ifac_rec.period_start_date,
                                        lo_ifac_rec.period_end_date,
                                        lo_ifac_rec.delivery_point_id,
                                        NULL,
                                        NULL,
                                        lv2_mpd_ind, -- PPA transaction
                                        lv2_ifac_price_object,
                                        'N',
                                        lo_ifac_rec.sales_order);
                                    l_logger.debug('New Transaction inserted [' || lv2_transaction_key || ']');
                                END IF;

                                l_context.update_ifac_keys_period(
                                    lo_ifac_rec.TRANS_ID, lv2_transaction_key, NULL, NULL);
                            END IF;
                        ELSE
                            -- Get preceding transactions
                            -- When creating transactions based on transaction template and preceding transactions,
                            -- the preceding transactions will determine the amount of transactions, not the templates.
                            -- However when creating transactions based on I/F and preceding transactions, the I/F
                            -- will determine the amount of transactions, not the preceding transactions.
                            lv2_transaction_key := ecdp_transaction.insnewtransaction(
                                lv2_p_object_id,
                                ld_daytime,
                                lv2_NewDocKey,
                                lrec_ttv.transaction_type,
                                lo_ifac_rec.trans_temp_id,
                                lv2_p_user,
                                NULL,
                                lo_ifac_rec.preceding_trans_key,
                                lo_ifac_rec.unique_key_1,
                                lo_ifac_rec.unique_key_2,
                                lo_ifac_rec.period_start_date,
                                lo_ifac_rec.period_end_date,
                                lo_ifac_rec.delivery_point_id,
                                NULL,
                                NULL,
                                'N',
                                lv2_ifac_price_object,
                                p_sales_order => lo_ifac_rec.sales_order);

                           IF lv2_transaction_key IS NULL THEN
                               lv2_transaction_key := ecdp_transaction.insnewtransaction(
                                   lv2_p_object_id,
                                   ld_daytime,
                                   lv2_NewDocKey,
                                   lrec_ttv.transaction_type,
                                   lo_ifac_rec.trans_temp_id,
                                   lv2_p_user,
                                   NULL,
                                   NULL, -- No preceding transaction
                                   lo_ifac_rec.unique_key_1,
                                   lo_ifac_rec.unique_key_2,
                                   lo_ifac_rec.period_start_date,
                                   lo_ifac_rec.period_end_date,
                                   lo_ifac_rec.delivery_point_id,
                                   NULL,
                                   NULL,
                                   'N',
                                   lv2_ifac_price_object,
                                   'Y',
                                   lo_ifac_rec.sales_order);
                           END IF;

                           l_context.update_ifac_keys_period(
                               lo_ifac_rec.TRANS_ID, lv2_transaction_key, NULL, NULL);
                           l_logger.debug('New Transaction inserted [' || lv2_transaction_key || ']');

                           IF lv2_p_action IN ('CREATE_DEPENDENT') THEN
                               l_temp_line_item_keys := t_table_varchar2();
                               match_ifac_li_on_doc_period_p(l_context, lv2_NewDocKey, l_temp_line_item_keys);
                               ecdp_line_item.upd_creation_method(l_temp_line_item_keys, ecdp_revn_ft_constants.ifac_ctype_interface);
                           END IF;
                       END IF;
                    END IF;

                    IF lv2_transaction_key IS NOT NULL THEN
                        ln_TranCounter := ln_TranCounter + 1;
                        -- Update CONT_TRANSACTION
                        -- Trigger logic will populate the rest of the transaction attributes based on these dates.
                        l_logger.debug('Updating transaction with Sales Order: '
                            || (CASE WHEN lo_ifac_rec.Sales_Order IS NULL THEN 'N/A' ELSE lo_ifac_rec.Sales_Order END));

                        UPDATE cont_transaction ctr SET
                            ctr.sales_order = (CASE WHEN lo_ifac_rec.Sales_Order IS NULL THEN 'N/A' ELSE lo_ifac_rec.Sales_Order END),
                            ctr.qty_type = NVL(lo_ifac_rec.Qty_Status, ctr.qty_type)
                        WHERE ctr.transaction_key = lv2_transaction_key;
                    END IF;

                    IF ln_TranCounter = 0 THEN
                        -- Error if no transaction found
                        GenDocException(lv2_p_object_id, lv2_NewDocKey, 20000,
                            'No transaction created for Price Concept [' || lo_ifac_rec.Price_Concept_Code ||
                            '], Delivery Point [' || ec_delivery_point.object_code(lo_ifac_rec.Delivery_point_id) ||
                            '], Product [' || ec_product.object_code(lo_ifac_rec.Product_Id) ||
                            '], Field [' || ec_field.object_code(lo_ifac_rec.profit_center_id) ||
                            ']', 'ERROR', 'Y', l_logger.log_no, lt_raise_error);
                        RETURN 'ERROR';
                    ELSE
                        l_logger.info('Created transaction [' || lv2_transaction_key || '] for ' ||
                            'Price Concept [' || lo_ifac_rec.Price_Concept_Code ||
                            '], Delivery Point [' || ec_delivery_point.object_code(lo_ifac_rec.Delivery_point_id) ||
                            '], Product [' || ec_product.object_code(lo_ifac_rec.Product_Id) ||
                            '], Field [' || ec_field.object_code(lo_ifac_rec.profit_center_id) ||
                            ']');
                    END IF;
                END LOOP;

                l_logger.info('Processed ' || ln_TranCounter || ' of ' || ln_RecordCounter
                    || ' interfaced Period Quantity (transaction level) Records.');

                -- Adding any non-interfaced transactions (typically with only other/non-qty line items)

                -- Add call to function which updates the document dates according to the dates set above.
                l_logger.info('Updating all document dates.');
                IF lv2_p_action IN ('CREATE_MPD','CREATE_RECON','APPEND_MPD')  THEN
                    l_logger.info('Inserting and updating interest line items, if applicable.');
                END IF;

                BEGIN
                    EcDp_Contract_Setup.updateAllDocumentDates(
                        lv2_p_object_id, lv2_NewDocKey, ld_daytime, ld_p_document_date, lv2_p_user);
                EXCEPTION
                    WHEN OTHERS THEN
                        GenDocException(lv2_p_object_id, lv2_NewDocKey, SQLCODE,
                            SUBSTR(SQLERRM, 1, 240), 'ERROR', 'Y', l_logger.log_no, lt_raise_error);
                        RETURN 'ERROR';
                END;


                l_logger.info('Generating interfaced line items in current document.');
                BEGIN
                    gen_li_f_ifac_period_p(l_context, l_document_info);
                EXCEPTION
                    WHEN OTHERS THEN
                        lv2_loginfo := ' (when executing EcDp_Document_Gen.Gen_Li_F_Ifac_Period_P()).';
                        GenDocException(lv2_p_object_id, lv2_NewDocKey, SQLCODE,
                            SUBSTR(SQLERRM||lv2_loginfo, 1, 240), 'ERROR', 'Y', l_logger.log_no, lt_raise_error);
                        RETURN 'ERROR';
                END;

                IF nvl(EC_CTRL_SYSTEM_ATTRIBUTE.attribute_text(ld_p_document_date,'DEL_EMPTY_LI_ON_DOC_GEN','<='),'Y')='N'THEN

                       -- Adding any non-interfaced transactions (typically with only other/non-qty line items)
                       l_logger.info( 'Generating additional transactions.');
                       FOR ci_missing_trans IN ecdp_transaction.gc_transaction_tmpl_missing(lv2_NewDocKey) LOOP
                           if (ecdp_line_item.HasNonQtyLineItemTmpl(ci_missing_trans.object_id, ld_p_processing_period) = ecdp_revn_common.gv2_true) then
                               lv2_transaction_key := ecdp_transaction.insnewtransaction(
                                   p_object_id => lv2_p_object_id,
                                   p_daytime => ld_daytime,
                                   p_document_id => lv2_NewDocKey,
                                   p_document_type => lrec_ttv.transaction_type,
                                   p_trans_template_id => ci_missing_trans.object_id,
                                   p_user => lv2_p_user,
                                   p_supply_from_date => ld_p_period_from,
                                   p_supply_to_date => ld_p_period_to,
                                   p_ppa_trans_ind => 'N',
                                   p_ifac_price_object_id => lv2_ifac_price_object);

                               l_logger.info( 'Created transaction [' || lv2_transaction_key || ']');
                           end if;
                       END LOOP;
                       EcDp_Document.UpdDocumentVat(lv2_NewDocKey, ec_cont_document.daytime(lv2_NewDocKey), NULL);
                END IF;

                -- Updating quantities/prices on all non-reversal transactions in current document.
                l_logger.info('Updating quantities/prices on all non-reversal transactions in current document.');
                BEGIN
                    ecdp_document.fill_by_ifac_period_i(l_context, lv2_NewDocKey);
                EXCEPTION
                    WHEN OTHERS THEN
                        lv2_loginfo := ' (when executing EcDp_Document.Fill_By_Ifac_Period_I()).';
                        GenDocException(lv2_p_object_id, lv2_NewDocKey, SQLCODE,
                            SUBSTR(SQLERRM||lv2_loginfo, 1, 240), 'ERROR', 'Y', l_logger.log_no, lt_raise_error);
                        RETURN 'ERROR';
                END;
                  IF nvl(EC_CTRL_SYSTEM_ATTRIBUTE.attribute_text(ld_p_document_date,'DEL_EMPTY_LI_ON_DOC_GEN','<='),'Y')='Y'THEN
                    -- Delete empty line items/transactions
                    l_logger.info('Deleting empty transactions on current document.');
                    BEGIN
                        Ecdp_Transaction.DelEmptyTransactions(lv2_NewDocKey);
                        ecdp_line_item.DelEmptyLineItemsFromTemp(lv2_NewDocKey);    --deletes empty line item with matched interface data
                    EXCEPTION
                        WHEN OTHERS THEN
                           GenDocException(lv2_p_object_id, lv2_NewDocKey, SQLCODE,
                               SUBSTR(SQLERRM, 1, 240), 'ERROR', 'Y', l_logger.log_no, lt_raise_error);
                           RETURN 'ERROR';
                    END;
                END IF;

                -- Sort the transactions
                l_logger.info('Sorting transactions.');
                BEGIN
                    Ecdp_Transaction.SetAllTransSortOrder(lv2_NewDocKey);
                EXCEPTION
                    WHEN OTHERS THEN
                        GenDocException(lv2_p_object_id, lv2_NewDocKey, SQLCODE,
                            SUBSTR(SQLERRM, 1, 240), 'ERROR', 'N', l_logger.log_no, lt_raise_error);
                        RETURN 'ERROR';
                END;

                -- Validation of this newly created document will be performed by an separate businessaction,
                -- running after calculation. Returning new document_key.
                lv2_ReturnDocKey := lv2_NewDocKey;
                l_context.apply_ifac_period_keys;
            END IF;

            -- Set status for this document generation
            IF lv2_RunStatus IS NULL OR (lv2_RunStatus NOT IN ('ERROR','WARNING')) THEN
                lv2_RunStatus := 'SUCCESS';
            END IF;

            FinalDocGenLog(l_logger, lv2_RunStatus);

            -- Setting return document key (either new or updated doc)
            p_new_doc_key := lv2_ReturnDocKey;

            -- Setting Recommended Action
            SetDocumentRecActionCode(lv2_ReturnDocKey);

            IF ue_cont_document.isGenPeriodDocUEPostEnabled = 'TRUE' THEN
                ue_cont_document.GenPeriodDocumentPost(
                    lv2_p_object_id,
                    ld_p_processing_period,
                    ld_p_period_from,
                    ld_p_period_to,
                    lv2_p_action,
                    lv2_p_contract_doc_id,
                    ld_p_document_date,
                    lv2_p_document_status,
                    lv2_p_prec_doc_key,
                    lv2_p_delivery_point_id,
                    lv2_p_customer_id,
                    lv2_p_source_node_id,
                    lv2_p_user,
                    lv2_p_owner,
                    p_log_item_no,
                    p_new_doc_key,
                    lv2_p_nav_id,
                    lv2_RunStatus);
            END IF;

            SELECT COUNT(transaction_key) INTO ln_count FROM cont_transaction
            WHERE document_key=lv2_NewDocKey
                AND ec_cont_transaction.document_key(preceding_trans_key) <> ec_cont_document.preceding_document_key(lv2_NewDocKey);


            IF (ln_count >0) THEN
                UPDATE Cont_Document cd
                SET cd.comments='Document has updates from transactions on PPA document(s)'
                WHERE cd.document_key=lv2_NewDocKey;
            END IF;


            trace(l_context);

            RETURN lv2_RunStatus;
           EXCEPTION
             WHEN OTHERS THEN
                        v_check:=INSTR(SQLERRM,'No stream item found having a matching uom on Field');
                        IF(v_check<=0) THEN
                            v_check:=INSTR(SQLERRM,'More than one matching stream item found on Field');
                        END IF;
                        IF(v_check<=0) THEN
                            v_check:=INSTR(SQLERRM,'Configuration mismatch');
                        END IF;
                        IF(v_check >0) THEN
                            GenDocException(lv2_p_object_id, lv2_NewDocKey, SQLCODE, SUBSTR(SQLERRM, 1, 240), 'ERROR', 'Y', p_log_item_no);
                        ELSE
                            GenDocException(lv2_p_object_id, lv2_NewDocKey, SQLCODE, SUBSTR(SQLERRM, 1, 240), 'ERROR', 'N', p_log_item_no);
                        END IF;

                 RETURN 'ERROR';

            END;
    END IF;
END GenPeriodDocument;

------------------------------------------------------------------------------------------------------------

PROCEDURE GenDocException(p_object_id       VARCHAR2,
                          p_doc_key         VARCHAR2,
                          p_err_code        NUMBER,
                          p_err_msg         VARCHAR2,
                          p_exception_level VARCHAR2 DEFAULT 'ERROR', -- could be set to WARNING
                          p_delete_doc_ind  VARCHAR2 DEFAULT 'Y',
                          p_log_no          NUMBER,
                          p_raise_error_ind VARCHAR2 DEFAULT 'N')

IS
    l_logger t_revn_logger;
    lv2_logtext VARCHAR2(1000);
BEGIN
    l_logger := t_revn_logger(p_log_no);
    l_logger.init;
    l_logger.log(p_exception_level, p_err_code || ' - ' || p_err_msg);

     IF p_doc_key IS NULL AND p_exception_level = 'ERROR' AND p_delete_doc_ind = 'Y' THEN
        l_logger.debug('Could not delete document due to missing document key. Parameters recieved: doc key: NULL, exception level: ' || p_exception_level || ', delete: ' || p_delete_doc_ind);
     END IF;

    IF p_doc_key IS NOT NULL AND p_exception_level = 'ERROR' AND p_delete_doc_ind = 'Y' THEN
        lv2_logtext := 'Due to generation failure, this document is deleted: ' || p_doc_key;

        BEGIN
            IF Ec_Ctrl_System_Attribute.Attribute_Text(Ecdp_Timestamp.getCurrentSysdate, 'DOC_PROCESS_DEBUG','<=') = 'Y' THEN
                lv2_logtext := 'Due to generation failure, this document would NORMALLY be deleted now (' || p_doc_key ||'). BUT DUE TO DEBUG MODE IN SYSTEM ATTRIBUTES (''DOC_PROCESS_DEBUG'' = ''Y'') THE DOCUMENT IS NOT DELETED';
            ELSE
                EcDp_Document.DelDocument(p_object_id, p_doc_key);
            END IF;
            l_logger.info(lv2_logtext);
        EXCEPTION
            WHEN OTHERS THEN
            l_logger.log(p_exception_level, 'Attempted to delete document ' || p_doc_key || ', but an exception occurred: ' || SQLCODE || ' - ' || SUBSTR(SQLERRM, 1, 240));
        END;
    ELSE
        l_logger.debug('Did not delete document. Parameters recieved: doc key:' || p_doc_key || ', exception level: ' || p_exception_level || ', delete: ' || p_delete_doc_ind);
    END IF;

    l_logger.update_overall_state(NULL, p_exception_level);

    IF p_exception_level = 'ERROR' and p_raise_error_ind = 'Y' THEN
        RAISE_APPLICATION_ERROR(-20000, 'Error during document process (' || p_err_code || '). ' || p_err_msg);
    END IF;
END;

------------------------------------------------------------------------------------------------------------
--Generate Reversal Documets by Job
PROCEDURE genReverseDocuments
IS

-- Retrieves the number of still running instances of the current Business Action and who are younger than one hour.
CURSOR c_RunningBA IS
SELECT COUNT(sl.schedule_no) SL_Count
  FROM schedule sl, action_instance ai, business_action ba, schedule_history sh
 WHERE ai.schedule_no = sl.schedule_no
   AND ba.business_action_no = ai.business_action_no
   AND sh.schedule_no = sl.schedule_no
   AND upper(ba.Name) = upper('REVN_GenReverseDocuments')
   AND sh.to_daytime IS NULL --still running
   AND (Ecdp_Timestamp.getCurrentSysdate() - sh.created_date) < 0.04167; --younger than one hour

   lv2_RunningBA_Status VARCHAR(500);

  CURSOR c_contDoc IS
  SELECT object_id, document_key, last_updated_by, created_by, financial_code, Ext_Document_Key
    FROM cont_document d
   WHERE d.status_code = 'ACCRUAL' --only ACCRUAL documents to be reversed
     AND d.document_level_code = 'BOOKED' --only documents set to BOOKED to be reversed
     AND d.actual_reversal_date IS NULL --only documents that has NOT been reversed to be reversed
     AND d.reversal_ind = 'N' --this is set to Y for the reversal documents themselves - not reverse these
     AND d.booking_period IN
         (SELECT daytime
            FROM system_mth_status s
           WHERE s.closed_book_date IS NOT NULL --only document has closed booking period will be generated
             AND s.booking_area_code = d.financial_code
             AND s.company_id = ec_contract_version.company_id(d.object_id, d.daytime, '<=')
             AND s.country_id = ec_company_version.country_id(ec_contract_version.company_id(d.object_id, d.daytime, '<='), d.daytime, '<='));

  lv2_user VARCHAR2(32) := Ecdp_Context.getAppUser;
  lv2_document_key VARCHAR2(32) := NULL;
  lv2_run_status VARCHAR2(32);
  lv2_run_status_all VARCHAR2(32);
  lv2_validation_level VARCHAR(32);
  lv2_interface_ind VARCHAR(1);
  lv2_interface_no VARCHAR(32);

  ln_num_success NUMBER :=0;
  ln_num_error NUMBER :=0;
  ln_num_warning NUMBER :=0;
  ln_num_total NUMBER :=0;
  lv2_summary VARCHAR2(2000);
  l_logger t_revn_logger;

BEGIN

   l_logger := t_revn_logger('REVERSE_DG');
   l_logger.init;
   l_logger.update_overall_state('Reversing all available booked Accrual documents', ecdp_revn_log.LOG_STATUS_RUNNING);

   --Abort if the Business Action is still running by several schedules (more than the current one)
   FOR curSL IN c_RunningBA LOOP
     IF curSL.SL_Count > 1 THEN
       lv2_RunningBA_Status := 'Procedure aborted. Caused by: Business action REVN_GenReverseDocuments is still running by another scheduler.';
       l_logger.error(lv2_RunningBA_Status);
       Raise_Application_Error(-20000,lv2_RunningBA_Status);
     END IF;
   END LOOP;

   lv2_interface_ind := ec_ctrl_system_attribute.attribute_text(Ecdp_Timestamp.getCurrentSysdate, 'ACC_REV_INTERFACE_IND', '<=');

   --If interface indicator is yes, set the Booked to Transfer
   IF lv2_interface_ind = 'Y' AND
       ec_ctrl_system_attribute.attribute_text(Ecdp_Timestamp.getCurrentSysdate, 'ACC_REV_VALIDATION_LEVEL', '<=') = 'BOOKED' THEN
       lv2_validation_level := 'TRANSFER';
   ELSE
       lv2_validation_level := ec_ctrl_system_attribute.attribute_text(Ecdp_Timestamp.getCurrentSysdate, 'ACC_REV_VALIDATION_LEVEL', '<=');
   END IF;

   --Loop through all documents
   FOR curRow IN c_contDoc LOOP
       -- Keep reversed document key
       -- Keep source entry no for reversed document key ifac records
       -- Loop over source entry no and set ds/tt over again after this loop.
       l_logger.set_log_item_data(p_log_item_text_1 => curRow.Document_Key, p_log_item_text_3 => curRow.Object_Id);
       l_logger.debug('Generating Reversal Document for Document[' || curRow.document_key || '] ');

       BEGIN
            -- generating reversal document
           lv2_document_key := Ecdp_Document.GenReverseDocument(curRow.object_id,
                                                                curRow.document_key,
                                                                l_logger.log_no,
                                                                lv2_user,
                                                                'Y');

       EXCEPTION
           WHEN OTHERS THEN
               GenDocException(curRow.object_id, lv2_document_key, SQLCODE, SUBSTR(SQLERRM, 1, 240), 'ERROR', 'Y', l_logger.log_no);
               lv2_run_status := 'ERROR';
       END;

       l_logger.info('New reversal document was created. Key: [' || lv2_document_key || ']');

         -- Perform Validation on current document if no errors --
         -- If errors during validation, document will NOT be deleted, but a WARNING will be given
         -- If document level was set to OPEN, nothing will be done here, because this is the default value.
       l_logger.info('Setting validation level to [' || lv2_validation_level || '] on this document.');

       BEGIN
         IF lv2_validation_level = 'VALID1' THEN

             l_logger.debug('Moving from OPEN to VALID1 on document [' || lv2_document_key || ']');
             SetDocumentValidationLevel_P(lv2_document_key, 'VALID1', lv2_user);

         ELSIF lv2_validation_level = 'VALID2' THEN

             l_logger.debug('Moving from OPEN to VALID1 on document [' || lv2_document_key || ']');
             SetDocumentValidationLevel_P(lv2_document_key, 'VALID1', lv2_user);

             l_logger.debug('Moving from VALID1 to VALID2 on document [' || lv2_document_key || ']');
             SetDocumentValidationLevel_P(lv2_document_key, 'VALID2', lv2_user);

         ELSIF lv2_validation_level = 'TRANSFER' THEN

             l_logger.debug('Moving from OPEN to VALID1 on document [' || lv2_document_key || ']');
             SetDocumentValidationLevel_P(lv2_document_key, 'VALID1', lv2_user);

             l_logger.debug('Moving from VALID1 to VALID2 on document [' || lv2_document_key || ']');
             SetDocumentValidationLevel_P(lv2_document_key, 'VALID2', lv2_user);

             l_logger.debug('Moving from VALID2 to TRANSFER on document [' || lv2_document_key || ']');
             SetDocumentValidationLevel_P(lv2_document_key, 'TRANSFER', lv2_user);
             if lv2_interface_ind = 'Y' then

                IF curRow.Ext_Document_Key IS NULL THEN -- Ordinary document

                  IF curRow.Financial_Code = 'SALE' THEN
                     lv2_interface_no := ecdp_outbound_interface.TransferSPSales(lv2_document_key);
                  ELSIF curRow.Financial_Code = 'PURCHASE' THEN
                     lv2_interface_no := ecdp_outbound_interface.TransferSPPurchases(lv2_document_key);
                  ELSIF curRow.Financial_Code = 'TA_INCOME' THEN
                     lv2_interface_no := ecdp_outbound_interface.TransferSPTariffIncome(lv2_document_key);
                  ELSIF curRow.Financial_Code = 'TA_COST' THEN
                     lv2_interface_no := ecdp_outbound_interface.TransferSPTariffCost(lv2_document_key);
                  ELSIF curRow.Financial_Code = 'JOU_ENT' THEN
                     lv2_interface_no := ecdp_outbound_interface.TransferSPJournalEntry(lv2_document_key);
                  END IF;

                ELSE -- ERP Document
                   lv2_interface_no := ecdp_outbound_interface.TransferERPDocument(lv2_document_key);
                END IF;

                  l_logger.debug('Interface File is generated. FILE[' || lv2_interface_no || ']');

             END IF;

         ELSIF lv2_validation_level = 'BOOKED' THEN

             l_logger.debug('Moving from OPEN to VALID1 on document [' || lv2_document_key || ']');
             SetDocumentValidationLevel_P(lv2_document_key, 'VALID1', lv2_user);

             l_logger.debug('Moving from VALID1 to VALID2 on document [' || lv2_document_key || ']');
             SetDocumentValidationLevel_P(lv2_document_key, 'VALID2', lv2_user);

             l_logger.debug('Moving from VALID2 to TRANSFER on document [' || lv2_document_key || ']');
             SetDocumentValidationLevel_P(lv2_document_key, 'TRANSFER', lv2_user);

             IF lv2_interface_ind = 'Y' THEN

               IF curRow.Ext_Document_Key IS NULL THEN -- Ordinary document

                  IF curRow.Financial_Code = 'SALE' THEN
                     lv2_interface_no := ecdp_outbound_interface.TransferSPSales(lv2_document_key);
                  ELSIF curRow.Financial_Code = 'PURCHASE' THEN
                     lv2_interface_no := ecdp_outbound_interface.TransferSPPurchases(lv2_document_key);
                  ELSIF curRow.Financial_Code = 'TA_INCOME' THEN
                     lv2_interface_no := ecdp_outbound_interface.TransferSPTariffIncome(lv2_document_key);
                  ELSIF curRow.Financial_Code = 'TA_COST' THEN
                     lv2_interface_no := ecdp_outbound_interface.TransferSPTariffCost(lv2_document_key);
                  ELSIF curRow.Financial_Code = 'JOU_ENT' THEN
                     lv2_interface_no := ecdp_outbound_interface.TransferSPJournalEntry(lv2_document_key);
                  END IF;

                ELSE -- ERP Document
                   lv2_interface_no := ecdp_outbound_interface.TransferERPDocument(lv2_document_key);
                END IF;


                l_logger.debug('Interface File is generated. FILE[' || lv2_interface_no || ']');
             END IF;

             l_logger.debug('Moving from TRANSFER to BOOKED on document [' || lv2_document_key || ']');
             SetDocumentValidationLevel_P(lv2_document_key, 'BOOKED', lv2_user);

         END IF;
       EXCEPTION
           WHEN OTHERS THEN
               GenDocException(curRow.object_id, lv2_document_key, SQLCODE, SUBSTR(SQLERRM, 1, 240), 'WARNING', 'N', l_logger.log_no);
               lv2_run_status := 'WARNING';
       END;

       -- Set status for this document
       IF lv2_run_status IS NULL OR (lv2_run_status NOT IN ('ERROR','WARNING')) THEN
          lv2_run_status := 'SUCCESS';
       END IF;

       IF lv2_run_status = 'ERROR' THEN

          ln_num_error := ln_num_error + 1;
          lv2_run_status_all := lv2_run_status;

       ELSIF lv2_run_status = 'WARNING' THEN

          ln_num_warning := ln_num_warning + 1;

          IF lv2_run_status_all != 'ERROR' THEN
            lv2_run_status_all := lv2_run_status;
          END IF;

       ELSIF lv2_run_status = 'SUCCESS' THEN

          ln_num_success := ln_num_success + 1;

          IF lv2_run_status_all NOT IN ('ERROR','WARNING') THEN
            lv2_run_status_all := lv2_run_status;
          END IF;

       END IF;

  		 ln_num_total := ln_num_total + 1;
       lv2_run_status := NULL;	--set the status back to nothing

       -- Perform analysis on the new reversed doc
       SetDocumentRecActionCode (lv2_document_key) ;

    END LOOP;

    -- Finalizing accrual processing
    FinalDocGenLog(l_logger, NVL(lv2_run_status_all, 'SUCCESS'));

    lv2_summary := ln_num_total || ' documents processed, ' || ln_num_success || ' created successfully, ' || ln_num_warning || ' created with Warning, ' || ln_num_error || ' not created due to Error';

    l_logger.info(lv2_summary);

END genReverseDocuments;

--------------------------------------------------------------------------------------------------
PROCEDURE UpdInterestLineItems
 (
 p_doc_key VARCHAR2
 )
IS

  CURSOR c_line_item(cp_document_id VARCHAR2) IS
    SELECT *
      FROM cont_line_item cli
     WHERE cli.document_key = cp_document_id
       AND cli.line_item_based_type = 'INTEREST'
       AND cli.interest_line_item_key IS NULL
       AND cli.line_item_template_id IS NOT NULL;

  l_new_interest_group cont_line_item.interest_group%TYPE;

BEGIN

  -- Updating the interest line item with the correct interest_to_date
  UPDATE cont_line_item a
  SET a.interest_to_date = ec_cont_document.pay_date(a.document_key)
  WHERE a.document_key = p_doc_key
  AND a.line_item_based_type = 'INTEREST'
  AND a.interest_line_item_key IS NULL
  AND a.line_item_template_id IS NOT NULL;

  -- Calculate interest line item
  EcDp_Line_Item.UpdIntBaseAmount(ec_cont_document.object_id(p_doc_key),
                                  p_doc_key,
                                  ec_cont_document.preceding_document_key(p_doc_key));



  -- Run calculation of compounding
  FOR c_val IN c_line_item(p_doc_key) LOOP

    l_new_interest_group := EcDp_Line_Item.GenInterestLineItemSet_I(
        ec_cont_document.object_id(p_doc_key),
        c_val.transaction_key,
        c_val.line_item_key,
        c_val.interest_from_date,
        c_val.interest_to_date,
        c_val.interest_base_amount,
        c_val.base_rate,
        c_val.interest_type,
        c_val.name,
        c_val.rate_offset,
        c_val.compounding_period,
        c_val.interest_group,
        c_val.interest_num_days,
        'SYSTEM',
        c_val.creation_method);
  END LOOP;

END UpdInterestLineItems;


--<EC-DOC>
-------------------------------------------------------------------------------------------------------------------------------------------
-- Function       : CleanupStimRecords
-- Description    : The procedure apply ignore flag to stim records when period on same financial code and company are going through the closing process
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
PROCEDURE CleanupStimRecords(
    p_company_id     VARCHAR2,
    p_financial_code VARCHAR2,
    p_user           VARCHAR2
    )
IS

  CURSOR c_contract (cp_company_id VARCHAR2, cp_fin_code VARCHAR2) IS
    SELECT c.object_id
      FROM contract_version c
     WHERE c.financial_code = cp_fin_code
       AND c.company_id = cp_company_id;

BEGIN
--System attribute added to ignaore the pending document on closing the period .
IF  NVL(ec_ctrl_system_attribute.attribute_text(Ecdp_Timestamp.getCurrentSysdate,'IGNR_PEND_ON_PRD_CHG','<='),'N')='Y' then
  FOR v_contract IN c_contract(p_company_id, p_financial_code)  LOOP

      UPDATE ifac_sales_qty sv
         SET sv.ignore_ind = 'Y', sv.last_updated_by = p_user
       WHERE sv.contract_id = v_contract.object_id
         AND sv.trans_key_set_ind = 'N'
         AND sv.ignore_ind = 'N';

       UPDATE ifac_cargo_value scv
          SET scv.ignore_ind = 'Y', scv.last_updated_by = p_user
        WHERE scv.contract_id = v_contract.object_id
          AND scv.trans_key_set_ind = 'N'
          AND scv.ignore_ind = 'N';

  END LOOP;
END IF;
END CleanupStimRecords;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : aggregateLevelQty
-- Description    : Function to aggregate qty's from Company level to Profit Centre level
--                  or from Profit Centre level to Line Item level.
-- Preconditions  :
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
---------------------------------------------------------------------------------------------------
PROCEDURE aggregateLevelQty(p_transaction_key VARCHAR2,
                            p_dist_id         VARCHAR2,
                            p_from_level      VARCHAR2, -- COMPANY or PROFIT_CENTRE
                            p_user_id         VARCHAR2
                            )
IS
  -- Get the sum of Profit Centre level qty's
  CURSOR cDistSum(cp_trans_key VARCHAR2) IS
    SELECT SUM(clid.qty1) Qty1,
           SUM(clid.qty2) Qty2,
           SUM(clid.qty3) Qty3,
           SUM(clid.qty4) Qty4
    FROM cont_line_item_dist clid
    WHERE clid.transaction_key = cp_trans_key
    AND clid.line_item_based_type = 'QTY'
    AND sort_order = (SELECT MIN(sort_order)
                        FROM cont_line_item cli
                       WHERE cli.transaction_key = clid.transaction_key
                         AND cli.line_item_based_type = 'QTY');

  -- Get the sum of Company level qty's
  CURSOR cCompSum(cp_trans_key VARCHAR2, cp_dist_id VARCHAR2) IS
    SELECT SUM(clidc.qty1) Qty1,
           SUM(clidc.qty2) Qty2,
           SUM(clidc.qty3) Qty3,
           SUM(clidc.qty4) Qty4
    FROM cont_li_dist_company clidc
    WHERE clidc.transaction_key = cp_trans_key
    AND clidc.dist_id = cp_dist_id
    AND clidc.line_item_based_type = 'QTY'
    AND clidc.sort_order = (SELECT MIN(sort_order)
                              FROM cont_line_item cli
                             WHERE cli.transaction_key = clidc.transaction_key
                               AND cli.line_item_based_type = 'QTY');

  -- Loop over Profit Centre and calculate split share based on new qty's
  CURSOR cDist(cp_trans_key VARCHAR2) IS
    SELECT clid.qty1,
           clid.qty2,
           clid.qty3,
           clid.qty4,
           clid.dist_id
    FROM cont_line_item_dist clid
    WHERE clid.transaction_key = cp_trans_key
    AND clid.line_item_based_type = 'QTY'
    AND sort_order = (SELECT MIN(sort_order)
                        FROM cont_line_item cli
                       WHERE cli.transaction_key = clid.transaction_key
                         AND cli.line_item_based_type = 'QTY');

  ln_field_sum_1 NUMBER;
  ln_field_sum_2 NUMBER;
  ln_field_sum_3 NUMBER;
  ln_field_sum_4 NUMBER;
  invalid_level_error EXCEPTION;

BEGIN
  -- Validate the specified level
  IF (nvl(p_from_level, 'NULL') NOT IN ('COMPANY', 'PROFIT_CENTRE')) THEN
    RAISE invalid_level_error;
  END IF;

  IF p_from_level = 'COMPANY' THEN
    -- Get the qty sum on Company level
    FOR rsT IN cCompSum(p_transaction_key, p_dist_id) LOOP
      -- Recalculate the vendor_share on Company level. This because the Qty's have just been updated.
      UPDATE cont_li_dist_company clidc
         SET clidc.vendor_share = CASE WHEN nvl(rsT.Qty1, 0) <> 0 THEN (nvl(clidc.Qty1, 0) / rsT.Qty1) ELSE 0 END
       WHERE clidc.transaction_key = p_transaction_key
         AND clidc.dist_id = p_dist_id;

      -- Update the Qty's on Profit Centre level
      UPDATE cont_line_item_dist clid
         SET clid.qty1 = rsT.Qty1,
             clid.qty2 = rsT.Qty2,
             clid.qty3 = rsT.Qty3,
             clid.qty4 = rsT.Qty4
       WHERE clid.transaction_key = p_transaction_key
         AND clid.dist_id = p_dist_id;
    END LOOP;
  END IF;

  -- Get sum of all Profit Centre
  FOR rsT IN cDistSum(p_transaction_key) LOOP
      ln_field_sum_1 := rsT.Qty1;
      ln_field_sum_2 := rsT.Qty2;
      ln_field_sum_3 := rsT.Qty3;
      ln_field_sum_4 := rsT.Qty4;
  END LOOP;

  -- Loop over Profit Centre and calculate split share based on new qty's
  FOR rsD IN cDist(p_transaction_key) LOOP
    UPDATE cont_line_item_dist clid
       SET clid.split_share       = (CASE WHEN ln_field_sum_1 <> 0 THEN (NVL(rsD.Qty1,0) / ln_field_sum_1) ELSE 0 END),
           clid.split_share_qty2  = (CASE WHEN ln_field_sum_2 <> 0 THEN (NVL(rsD.Qty2,0) / ln_field_sum_2) ELSE (CASE WHEN clid.uom2_code IS NOT NULL THEN 0 ELSE NULL END) END),
           clid.split_share_qty3  = (CASE WHEN ln_field_sum_3 <> 0 THEN (NVL(rsD.Qty3,0) / ln_field_sum_3) ELSE (CASE WHEN clid.uom3_code IS NOT NULL THEN 0 ELSE NULL END) END),
           clid.split_share_qty4  = (CASE WHEN ln_field_sum_4 <> 0 THEN (NVL(rsD.Qty4,0) / ln_field_sum_4) ELSE (CASE WHEN clid.uom4_code IS NOT NULL THEN 0 ELSE NULL END) END)
     WHERE clid.transaction_key = p_transaction_key
       AND clid.dist_id = rsD.Dist_Id;
  END LOOP;

  -- Write sum of all Profit Centre to Transaction level
  UPDATE cont_transaction_qty ctq
     SET ctq.net_qty1 = ln_field_sum_1,
         ctq.net_qty2 = ln_field_sum_2,
         ctq.net_qty3 = ln_field_sum_3,
         ctq.net_qty4 = ln_field_sum_4
   WHERE ctq.transaction_key = p_transaction_key;

  -- This is a force update to LAST_UPDATED_BY on Transaction level and all levels below.
  ecdp_transaction.triggerIULogic(ec_cont_transaction.document_key(p_transaction_key),p_user_id,'NA');

EXCEPTION
  WHEN invalid_level_error THEN
    RAISE_APPLICATION_ERROR(-20000, 'Failed to execute action. The specified level (' || nvl(p_from_level, 'NULL') || ') is not valid.\n\n');
END aggregateLevelQty;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : executeUserAction
-- Description    : Procedure that executes any required logic based on the selected user action
--
-- Preconditions  :
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
---------------------------------------------------------------------------------------------------
PROCEDURE executeUserAction(
          p_document_key VARCHAR2,
          p_user_action_code VARCHAR2)
IS

  lv2_contract_id      VARCHAR2(32);
  lv2_val_level        VARCHAR2(32);
  lv2_doc_scope        VARCHAR2(32);
  lv2_err_reason       VARCHAR2(500);
  lv2_summary          VARCHAR2(500);
  lv2_user             VARCHAR2(32);
  lv2_prec_doc_key     VARCHAR2(32);
  lv2_rev_doc_key      VARCHAR2(32);
  lv2_rec_action       VARCHAR2(32);
  lv2_ue_output_msg    VARCHAR2(500);
  lv2_val_msg          VARCHAR2(240);
  lv2_val_code         VARCHAR2(32);
  ld_daytime           DATE;
  l_context            t_revn_doc_op_context;
  l_document_info      t_revn_ft_doc_info;
  lv2_message          VARCHAR2(1032);

  lrec_doc cont_document%ROWTYPE := ec_cont_document.row_by_pk(p_document_key);

  user_action_error    EXCEPTION;
  user_action_ue_error EXCEPTION;
  l_logger             t_revn_logger;

BEGIN

  IF p_user_action_code IS NOT NULL THEN

     lv2_user := ecdp_context.getAppUser;
     lv2_contract_id := ec_contract_doc.contract_id(lrec_doc.contract_doc_id);
     lv2_val_level := lrec_doc.document_level_code;
     lv2_doc_scope := lrec_doc.doc_scope;
     lv2_prec_doc_key := lrec_doc.preceding_document_key;
     ld_daytime := lrec_doc.daytime;
     lv2_rec_action := lrec_doc.system_action_code;
     lv2_summary := '\n\n' ||
                    'Contract: ' || lrec_doc.contract_name || '\n' ||
                    'Document: ' || p_document_key  || '\n' ||
                    'Level: ' || ec_prosty_codes.code_text(lv2_val_level, 'DOCUMENT_LEVEL_CODE') || '\n';
     l_context := t_revn_doc_op_context();
     l_document_info := t_revn_ft_doc_info(p_document_key);
     l_document_info.refresh;

     -- User exit
     IF ue_cont_document.isExecUserActionPreUEEnabled = 'TRUE' THEN
         IF ue_cont_document.ExecuteUserActionPre(p_document_key, p_user_action_code, lv2_ue_output_msg) = 'ERROR' THEN
           RAISE user_action_ue_error;
         END IF;
           END IF;


     --**	Follow recommended action **--
     IF p_user_action_code = 'SYSTEM_ACTION' THEN

         -- Recommended action should always have a corresponding user action
         executeUserAction(p_document_key, lv2_rec_action);


     --**	Set to Valid 1 **--
     ELSIF p_user_action_code = 'SET_VALID1' THEN

        IF lv2_val_level = 'OPEN' THEN

           -- Perform the validation
           EcDp_Document.ValidateDocument(p_document_key, lv2_val_msg, lv2_val_code, 'N');

           -- If validation did not fail validation level is set
           UPDATE cont_document cd SET
                  cd.document_level_code = 'VALID1',
                  cd.valid1_user_id = lv2_user,
                  cd.last_updated_by = lv2_user
            WHERE cd.document_key = p_document_key;

        ELSE
           lv2_err_reason := 'Can not set the document to Valid 1 because it is ' || ec_prosty_codes.code_text(lv2_val_level,'DOCUMENT_LEVEL_CODE') || ', not Open.';
           RAISE user_action_error;
        END IF;


     --**	Set back to Open **--
     ELSIF p_user_action_code = 'SET_OPEN' THEN

        IF lv2_val_level = 'VALID1' THEN

           -- Move to Open
           UPDATE cont_document cd SET cd.set_to_prev_ind = 'Y' WHERE cd.document_key = p_document_key;

        ELSIF lv2_val_level IN ('VALID2','TRANSFER','BOOKED') THEN

           lv2_err_reason := 'Can not set the document to Open unless it is at level Valid 1.';
           RAISE user_action_error;
        END IF;


     --**	Update prices **--
     ELSIF p_user_action_code = 'UPDATE_PRICE' THEN

       -- Set document to OPEN before updating price
       IF lv2_val_level IN ('OPEN','VALID1','VALID2','TRANSFER') THEN

         -- Check transfer status
         IF lv2_val_level = 'TRANSFER' AND lrec_doc.fin_interface_file IS NOT NULL THEN
            lv2_err_reason := 'Can not update prices on the document because it has been transferred to financial system.';
            RAISE user_action_error;
         END IF;

         IF lv2_val_level != 'OPEN' THEN
            SetDocumentValidationLevel_P(p_document_key, 'OPEN', lv2_user);
         END IF;

         EcDp_Document.FillDocumentPrice(p_document_key, lv2_user);

         END IF;


     --**	Update from I/F **--
     ELSIF p_user_action_code = 'UPDATE_IFAC' THEN

       -- Create a new logger
       l_context.config_logger(NULL, 'REVN_FT_DOC_ACTION');
       l_context.user_id := ecdp_context.getAppUser;
       l_context.processing_contract_id := lv2_contract_id;
       l_context.get_or_create_logger(l_logger);
       l_logger.debug('Start execution of user action ''' || p_user_action_code || '''.');
       l_logger.debug('Current document level: ' || lv2_val_level);

       -- Set document to OPEN before updating from I/F
       IF lv2_val_level IN ('OPEN','VALID1','VALID2','TRANSFER') THEN

         -- Check transfer status
         IF lv2_val_level = 'TRANSFER' AND lrec_doc.fin_interface_file IS NOT NULL THEN
            lv2_err_reason := 'Can not update quantity on the document because it has been transferred to financial system.';
            l_logger.error(lv2_err_reason);
            RAISE user_action_error;
         END IF;

         IF lv2_val_level != 'OPEN' THEN
            SetDocumentValidationLevel_P(p_document_key, 'OPEN', lv2_user);
            l_logger.debug('Current document level is set to: ' || ec_cont_document.document_level_code(p_document_key));
         END IF;

         -- Get the ifac data and sort it
         prepare_ifac_for_doc_upd_p(l_context, l_document_info);

         -- Period
         -- Copies preceding keys to keys, where preceding doc key is the one being updated
         set_prec_keys_as_keys_period_p(p_document_key, l_context, TRUE);
         l_context.apply_ifac_period_keys;
         -- Updating quantities/prices on all non-reversal transactions in current document.
         ecdp_document.fill_by_ifac_period_i(l_context, p_document_key);

         -- Cargo
         -- Copies preceding keys to keys, where preceding doc key is the one being updated
         set_prec_keys_as_keys_cargo_p(p_document_key, l_context, TRUE);
         l_context.apply_ifac_cargo_keys;
         -- Updating quantities/prices on all non-reversal transactions in current document.
         ecdp_document.fill_by_ifac_cargo_i(l_context, p_document_key);
       END IF;


     --**	Update prices and quantities **--
     ELSIF p_user_action_code = 'UPDATE_PRICE_IFAC' THEN

       executeUserAction(p_document_key, 'UPDATE_PRICE');
       executeUserAction(p_document_key, 'UPDATE_IFAC');


     --**	Update exchange rates **--
     ELSIF p_user_action_code = 'UPDATE_EX_RATES' THEN

        FOR rsT IN gc_DocumentTransactions(p_document_key) LOOP

            lv2_message:= EcDp_Transaction.UpdTransExRate(rsT.Transaction_Key, lv2_user);

       END LOOP;


     --**	Delete (no recreate) **--
     ELSIF p_user_action_code = 'DELETE' THEN

        IF lrec_doc.document_level_code = 'OPEN' THEN

          IF lrec_doc.ext_document_key IS NOT NULL THEN -- ERP-document

             DELETE FROM cont_erp_postings
              WHERE document_key = p_document_key;

             DELETE FROM cont_document_company
              WHERE document_key = p_document_key;

             DELETE FROM ifac_erp_postings
              WHERE ext_doc_key IN (
                    SELECT ext_doc_key
                      FROM ifac_document
                     WHERE document_key = p_document_key);

             DELETE FROM ifac_document
              WHERE document_key = p_document_key;

          ELSE  -- Ordinary document

            IF lv2_doc_scope = 'CARGO_BASED' THEN -- TODO: Necessary to check Transaction Scope? Cargo and Period on same contract?

              -- Set all cargo records to IGNORE, including all allocations
              UPDATE ifac_cargo_value c
                 SET c.ignore_ind = 'Y'
               WHERE c.cargo_no IN
                     (SELECT ct.cargo_name
                        FROM cont_transaction ct
                       WHERE ct.document_key = p_document_key)
                         AND ec_cont_transaction.document_key(c.transaction_key) = p_document_key;

            ELSIF lv2_doc_scope = 'PERIOD_BASED' THEN

              -- Set all period records to IGNORED, including all allocations
              UPDATE ifac_sales_qty isq1
                 SET isq1.ignore_ind = 'Y'
               WHERE isq1.contract_id = lrec_doc.object_id
                 AND isq1.doc_setup_id = ec_cont_document.contract_doc_id(p_document_key)
                 AND isq1.customer_id = ec_cont_document.customer_id(p_document_key)
                 AND isq1.processing_period =
                     (SELECT MAX(isq2.processing_period)
                        FROM ifac_sales_qty isq2
                       WHERE isq2.transaction_key IN
                             (SELECT ct.transaction_key
                                FROM cont_transaction ct
                               WHERE ct.document_key = p_document_key));

            END IF;

          END IF;

          EcDp_Document.DelDocument(lv2_contract_id, p_document_key);

        ELSE
          lv2_err_reason := 'Delete is only allowed on Open documents.';
          RAISE user_action_error;
        END IF;


     --**	Delete (and recreate) **--
     ELSIF p_user_action_code = 'DELETE_RECREATE' THEN

        IF lrec_doc.document_level_code = 'OPEN' THEN

          -- Check if the document is based on interfaced qty
          IF Ecdp_Document_Gen_Util.isDocumentQtyInterfaced(p_document_key) = 'N' THEN

            lv2_err_reason := 'Document is not based on interface and can therefore not be recreated automatically.\nTo delete document choose User Action "Delete (not recreate)"';
            RAISE user_action_error;

            END IF;


          IF lrec_doc.ext_document_key IS NOT NULL THEN -- ERP-document

             DELETE FROM cont_erp_postings
              WHERE document_key = p_document_key;

             DELETE FROM cont_document_company
              WHERE document_key = p_document_key;

             UPDATE ifac_document
                SET document_key = NULL
              WHERE document_key = p_document_key;

          ELSE  -- Ordinary document


            IF lv2_doc_scope = 'CARGO_BASED' THEN -- TODO: Necessary to check Transaction Scope? Cargo and Period on same contract?

              UPDATE ifac_cargo_value c SET
                     c.doc_setup_id = lrec_doc.contract_doc_id,
                     c.doc_setup_code = ec_contract_doc.object_code(lrec_doc.contract_doc_id),
                     c.preceding_doc_key = lv2_prec_doc_key
               WHERE c.transaction_key IN (SELECT t.transaction_key FROM cont_transaction t
                                           WHERE t.document_key = p_document_key);

            ELSIF lv2_doc_scope = 'PERIOD_BASED' THEN

              UPDATE ifac_sales_qty p SET
                     p.doc_setup_id = lrec_doc.contract_doc_id,
                     p.doc_setup_code = ec_contract_doc.object_code(lrec_doc.contract_doc_id),
                     p.preceding_doc_key = lv2_prec_doc_key
              WHERE p.transaction_key IN (SELECT t.transaction_key FROM cont_transaction t
                                          WHERE t.document_key = p_document_key);
            END IF;

          END IF;

          EcDp_Document.DelDocument(lv2_contract_id, p_document_key);

        ELSE
          lv2_err_reason := 'Delete is only allowed on Open documents.';
          RAISE user_action_error;
        END IF;


     --**	Delete empty transactions **--
     ELSIF p_user_action_code = 'DELETE_TRANS' THEN

        EcDp_Transaction.DelEmptyTransactions(p_document_key);


     --**	Delete empty line items **--
     ELSIF p_user_action_code = 'DELETE_LINE_ITEMS' THEN

        FOR rsT IN gc_DocumentTransactions(p_document_key) LOOP

            Ecdp_Line_Item.DelEmptyLineItems(rsT.Transaction_Key);

        END LOOP;


     --**	Create Reversal Document **--
     ELSIF p_user_action_code = 'REVERSE' THEN

        -- Check validation level
       IF lv2_val_level = 'BOOKED' THEN
         l_logger := t_revn_logger(p_user_action_code || '_DG');
         l_logger.init;
         l_logger.update_overall_state('Manual reversal of document ''' || p_document_key || '''.', NULL);

         l_logger.info('Start to manual reverse document ''' || p_document_key || '''.');
         lv2_rev_doc_key := EcDp_Document.GenReverseDocument(lv2_contract_id, p_document_key, l_logger.log_no, lv2_user, 'Y');
         l_logger.info('Reversal document ''' || lv2_rev_doc_key || ''' is generated.');

       ELSE

          lv2_err_reason := 'It is only allowed to reverse booked documents. Document ' || p_document_key || ' is at level ' || ec_prosty_codes.code_text(lv2_val_level, 'DOCUMENT_LEVEL_CODE') || '.';
          RAISE user_action_error;

  	   END IF;

     --** Re-calculate source split **--
     ELSIF p_user_action_code = 'RECALC_SOURCESPLIT' THEN
       IF lv2_val_level = 'OPEN' THEN
         EcDp_document.recalcSourceSplit(p_document_key, lv2_user);
       END IF;




     END IF;


     IF ue_cont_document.isExecUserActionPostUEEnabled = 'TRUE' THEN
         ue_cont_document.ExecuteUserActionPost(p_document_key, p_user_action_code);
     END IF;


     -- Resetting user and recommended action if all went well
     UPDATE cont_document cd SET
            cd.user_action_code = NULL
      WHERE cd.document_key = p_document_key;


     -- Reset the recommended action
     SetDocumentRecActionCode(p_document_key);

  END IF;

EXCEPTION
  WHEN user_action_error THEN
       RAISE_APPLICATION_ERROR(-20000, 'Failed to execute action ''' || p_user_action_code || '''.\n\n' || lv2_err_reason || lv2_summary);
  WHEN user_action_ue_error THEN
        RAISE_APPLICATION_ERROR(-20000, lv2_ue_output_msg);

END executeUserAction;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : SetDocumentRecActionCode
-- Description    : Procedure that sets the recommended action on input document.
--
-- Preconditions  :
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
---------------------------------------------------------------------------------------------------
PROCEDURE SetDocumentRecActionCode(
          p_document_key VARCHAR2,
          p_document_type VARCHAR2 DEFAULT NULL,
          p_include_prec_doc VARCHAR2 DEFAULT 'N') -- Supporting ERP or other document types
IS

  lv2_val_code VARCHAR2(32) := NULL;
  lv2_val_msg VARCHAR2(240) := NULL;

BEGIN
  IF p_document_type IS NULL THEN

     ecdp_document_gen_util.GetDocumentRecActionCode(p_document_key, lv2_val_msg, lv2_val_code);

  ELSIF p_document_type = 'ERP' THEN

     ecdp_document_gen_util.GetERPDocumentRecActionCode(p_document_key, lv2_val_msg, lv2_val_code);

  END IF;

  UPDATE cont_document cd SET
      cd.system_action_code = lv2_val_code
   WHERE cd.document_key = p_document_key;

  -- Recursive call to update the preceding document. Covers only one step back.
  IF p_include_prec_doc = 'Y' THEN
    SetDocumentRecActionCode(ec_cont_document.preceding_document_key(p_document_key), 'N');
  END IF;


END SetDocumentRecActionCode;





--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : DeleteLog
-- Description    : Complete delete of document process log based on passed daytime
--                  which will be transaction period or cargo daytime
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : revn_log, revn_log_item
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE DeleteLog(p_daytime DATE)
--</EC-DOC>
IS

CURSOR c_log IS
  SELECT distinct l.log_no
    FROM revn_log l, revn_log_item li
   WHERE l.log_no = li.log_no(+)
     AND li.daytime < nvl(p_daytime, li.daytime + 1);

BEGIN

  FOR cv IN c_log LOOP

    DELETE revn_log_item i where i.log_no = cv.log_no;
    DELETE revn_log l where l.log_no = cv.log_no;

     END LOOP;

END DeleteLog;


PROCEDURE UpdateManualERPDoc(
          p_document_key VARCHAR2
)
IS

  lrec_doc cont_document%ROWTYPE := ec_cont_document.row_by_pk(p_document_key);
  lv2_val_msg VARCHAR2(240);
  lv2_val_code VARCHAR2(32);

BEGIN



  lrec_doc := PopulateERPDocRecord(lrec_doc.object_id,
                                   lrec_doc.contract_doc_id,
                                   lrec_doc.document_key,
                                   lrec_doc.preceding_document_key,
                                   lrec_doc.daytime,
                                   GetERPDocVendor(lrec_doc.object_id, lrec_doc.daytime),
                                   lrec_doc.status_code,
                                   lrec_doc.document_type,
                                   lrec_doc.ext_document_key,
                                   lrec_doc.document_number,
                                   nvl(lrec_doc.last_updated_by, EcDp_User_Session.getUserSessionParameter('USERNAME')),
                                   'UPDATING');

  UPDATE cont_document cd SET
         cd.document_date                = lrec_doc.document_date
        ,cd.production_period            = lrec_doc.production_period
        ,cd.status_code                  = lrec_doc.status_code
        ,cd.ext_document_key             = lrec_doc.ext_document_key
        ,cd.document_number              = lrec_doc.document_number
        ,cd.doc_date_calendar_coll_id    = lrec_doc.doc_date_calendar_coll_id
        ,cd.doc_rec_calendar_coll_id     = lrec_doc.doc_rec_calendar_coll_id
        ,cd.payment_calendar_coll_id     = lrec_doc.payment_calendar_coll_id
        ,cd.document_type                = lrec_doc.document_type
        ,cd.preceding_document_key       = lrec_doc.preceding_document_key
        ,cd.open_user_id                 = lrec_doc.open_user_id
        ,cd.booking_currency_code        = lrec_doc.booking_currency_code
        ,cd.booking_currency_id          = lrec_doc.booking_currency_id
        ,cd.book_document_ind            = lrec_doc.book_document_ind
        ,cd.memo_currency_code           = lrec_doc.memo_currency_code
        ,cd.memo_currency_id             = lrec_doc.memo_currency_id
        ,cd.price_basis                  = lrec_doc.price_basis
        ,cd.contract_name                = lrec_doc.contract_name
        ,cd.contract_reference           = lrec_doc.contract_reference
        ,cd.contract_group_code          = lrec_doc.contract_group_code
        ,cd.owner_company_id             = lrec_doc.owner_company_id
        ,cd.doc_date_term_id	           = lrec_doc.doc_date_term_id
        ,cd.doc_received_base_code       = lrec_doc.doc_received_base_code
        ,cd.doc_received_base_date       = lrec_doc.doc_received_base_date
        ,cd.doc_received_term_id         = lrec_doc.doc_received_term_id
        ,cd.document_received_date       = lrec_doc.document_received_date
        ,cd.payment_term_base_code       = lrec_doc.payment_term_base_code
        ,cd.payment_due_base_date        = lrec_doc.payment_due_base_date
        ,cd.payment_term_name            = lrec_doc.payment_term_name
        ,cd.pay_date                     = lrec_doc.pay_date
        ,cd.payment_term_id              = lrec_doc.payment_term_id
        ,cd.amount_in_words_ind          = lrec_doc.amount_in_words_ind
        ,cd.use_currency_100_ind         = lrec_doc.use_currency_100_ind
        ,cd.document_level_code          = lrec_doc.document_level_code
        ,cd.financial_code               = lrec_doc.financial_code
        ,cd.taxable_ind                  = lrec_doc.taxable_ind
        ,cd.doc_template_id              = lrec_doc.doc_template_id
        ,cd.inv_doc_template_id          = lrec_doc.inv_doc_template_id
        ,cd.doc_template_name            = lrec_doc.doc_template_name
        ,cd.inv_doc_template_name        = lrec_doc.inv_doc_template_name
        ,cd.our_contact                  = lrec_doc.our_contact
        ,cd.our_contact_phone            = lrec_doc.our_contact_phone
        ,cd.cur_doc_template_name        = lrec_doc.cur_doc_template_name
        ,cd.fin_interface_file           = lrec_doc.fin_interface_file
        ,cd.send_unit_price_ind          = lrec_doc.send_unit_price_ind
        ,cd.bank_details_level_code      = lrec_doc.bank_details_level_code
        ,cd.document_concept             = lrec_doc.document_concept
        ,cd.reversal_ind                 = lrec_doc.reversal_ind
        ,cd.int_base_amount_src          = lrec_doc.int_base_amount_src
        ,cd.contract_term_code           = lrec_doc.contract_term_code
        ,cd.doc_sequence_accrual_id      = lrec_doc.doc_sequence_accrual_id
        ,cd.doc_sequence_final_id        = lrec_doc.doc_sequence_final_id
        ,cd.doc_number_format_accrual    = lrec_doc.doc_number_format_accrual
        ,cd.doc_number_format_final      = lrec_doc.doc_number_format_final
        ,cd.payment_scheme_id            = lrec_doc.payment_scheme_id
        ,cd.contract_area_code           = lrec_doc.contract_area_code
        ,cd.value_1                      = lrec_doc.value_1
        ,cd.value_2                      = lrec_doc.value_2
        ,cd.value_3                      = lrec_doc.value_3
        ,cd.value_4                      = lrec_doc.value_4
        ,cd.value_5                      = lrec_doc.value_5
        ,cd.value_6                      = lrec_doc.value_6
        ,cd.value_7                      = lrec_doc.value_7
        ,cd.value_8                      = lrec_doc.value_8
        ,cd.value_9                      = lrec_doc.value_9
        ,cd.value_10                     = lrec_doc.value_10
        ,cd.text_1                       = lrec_doc.text_1
        ,cd.text_2	                     = lrec_doc.text_2
        ,cd.text_3                       = lrec_doc.text_3
        ,cd.text_4                       = lrec_doc.text_4
        ,cd.text_5                       = lrec_doc.text_5
        ,cd.text_6                       = lrec_doc.text_6
        ,cd.text_7                       = lrec_doc.text_7
        ,cd.text_8                       = lrec_doc.text_8
        ,cd.text_9                       = lrec_doc.text_9
        ,cd.text_10                      = lrec_doc.text_10
        ,cd.date_1                       = lrec_doc.date_1
        ,cd.date_2                       = lrec_doc.date_2
        ,cd.date_3                       = lrec_doc.date_3
        ,cd.date_4                       = lrec_doc.date_4
        ,cd.date_5                       = lrec_doc.date_5
        ,cd.date_6                       = lrec_doc.date_6
        ,cd.date_7                       = lrec_doc.date_7
        ,cd.date_8                       = lrec_doc.date_8
        ,cd.date_9                       = lrec_doc.date_9
        ,cd.date_10                      = lrec_doc.date_10
        ,cd.last_updated_by              = lrec_doc.last_updated_by
  WHERE cd.document_key = p_document_key;

  -- Get system recommended action for the document
  ecdp_document_gen_util.GetERPDocumentRecActionCode(p_document_key, lv2_val_msg, lv2_val_code);

  UPDATE cont_document cd SET
      cd.system_action_code = lv2_val_code
  WHERE cd.document_key = p_document_key;

  -- Insert vendor and customer
  ecdp_document.InsVendorCustomer(lrec_doc.document_key, lrec_doc.daytime, lrec_doc.last_updated_by);

END UpdateManualERPDoc;


FUNCTION GetERPDocVendor(p_contract_id VARCHAR2,
                         p_daytime DATE
) RETURN VARCHAR2
IS

  -- Get Contract owner vendor
  -- TODO Change cursor in ecdp_document to global cursor and use this one.
  CURSOR c_co_vend IS
     SELECT object_id
       FROM company c
      WHERE class_name = 'VENDOR'
        AND c.company_id = ec_contract_version.company_id(p_contract_id, p_daytime, '<=');

  -- Get Contract Vendors
  CURSOR c_vend IS
     SELECT ps.company_id FROM contract_party_share ps
     WHERE ps.party_role = 'VENDOR'
     AND ps.object_id = p_contract_id;

  lv2_fin_code VARCHAR2(32) := ec_contract_version.financial_code(p_contract_id, p_daytime, '<=');
  lv2_vendor_id VARCHAR2(32);

BEGIN

  -- Determine Vendor for this document, for getting correct payment info
  IF lv2_fin_code IN ('SALE','TA_INCOME','JOU_ENT') THEN
     -- When Sale or Tariff Income; Contract Owner Company is the Vendor to get payment info from
     FOR rsCOV IN c_co_vend LOOP
        lv2_vendor_id := rsCOV.object_id;
     END LOOP;

  ELSIF lv2_fin_code IN ('PURCHASE','TA_COST') THEN
     -- When Purchase or Tariff Cost; The single Vendor is the Vendor to get payment info from
     FOR rsV IN c_vend LOOP
        lv2_vendor_id := rsV.Company_Id;
           END LOOP;
        END IF;

  RETURN lv2_vendor_id;

END GetERPDocVendor;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GenERPDocument
-- Description    : Creates Document from I/F ERP records
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION GenERPDocument(p_object_id              VARCHAR2, -- Contract
                        p_contract_doc_id        VARCHAR2,
                        p_ext_doc_key            VARCHAR2,
                        p_preceding_document_key VARCHAR2,
                        p_daytime                DATE,
                        p_status_code            VARCHAR2,
                        p_document_number        VARCHAR2,
                        p_user                   VARCHAR2,
                        p_log_item_no            IN OUT NUMBER,
                        p_new_doc_key            OUT VARCHAR2,
                        p_nav_id                 VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
IS

  lv2_document_key                 VARCHAR2(32);
  lrec_doc                         cont_document%ROWTYPE;
  lrec_ifac_doc                    ifac_document%ROWTYPE;
  lv2_vendor_id                    VARCHAR2(32);
  lv2_val_msg                      VARCHAR2(240);
  lv2_val_code                     VARCHAR2(32);
  l_logger                         t_revn_logger;

  CURSOR c_postings(cp_ext_doc_key VARCHAR2) IS
  SELECT p.* FROM ifac_erp_postings p WHERE p.ext_doc_key = cp_ext_doc_key;

  c_val SYS_REFCURSOR;
  lv2_exist_doc_key cont_document.document_key%TYPE := NULL;
  ex_document_exists EXCEPTION;

BEGIN

  lrec_ifac_doc          := ec_ifac_document.row_by_pk(p_ext_doc_key);

  /* Persisted common log information */
  IF p_log_item_no IS NULL THEN
      l_logger := t_revn_logger('ERP_DG');
  ELSE
      l_logger := t_revn_logger(p_log_item_no);
  END IF;

  l_logger.init;
  l_logger.update_overall_state(p_nav_id, null);
  l_logger.set_log_item_data(p_log_item_text_3 => p_object_id);
  p_log_item_no := l_logger.log_no;

  l_logger.info(' ');
  l_logger.info('CREATING NEW ERP DOCUMENT: Production Period [' || to_char(lrec_ifac_doc.production_period) || '] on Contract [' || ec_contract_version.name(p_object_id,p_daytime, '<=') || ']');
  BEGIN

    lv2_document_key  := ecdp_document.GetNextDocumentKey(p_object_id,p_daytime);

    lv2_vendor_id := GetERPDocVendor(p_object_id, p_daytime);

    lrec_doc := PopulateERPDocRecord(p_object_id,
                                     p_contract_doc_id,
                                     lv2_document_key,
                                     p_preceding_document_key,
                                     p_daytime,
                                     lv2_vendor_id,
                                     p_status_code,
                                     lrec_ifac_doc.document_type,
                                     p_ext_doc_key,
                                     p_document_number,
                                     p_user,
                                     'INSERTING');

    -- Validate if this is a valid action to make
    q_ERPDocumentValidate(c_val, p_object_id, lrec_doc.document_key, lrec_doc.production_period);

    LOOP
      FETCH c_val INTO lv2_exist_doc_key;
      EXIT WHEN c_val%NOTFOUND;

    END LOOP;
    CLOSE c_val;

    IF lv2_exist_doc_key IS NOT NULL THEN
      RAISE ex_document_exists;
        END IF;


    INSERT INTO cont_document VALUES lrec_doc;

    ecdp_nav_model_obj_relation.Syncronize_model('FINANCIAL');

    -- Applying customer and vendor to the document
    IF lrec_doc.document_key IS not NULL THEN
       ecdp_document.InsVendorCustomer(lrec_doc.document_key,p_daytime,p_user);
           END IF;

  EXCEPTION
     WHEN ex_document_exists THEN
       GenDocException(p_object_id, lv2_document_key, -20000, 'One or more un-booked documents exist for the same contract and production period (found document: ' || lv2_exist_doc_key || ').', 'ERROR', 'Y', l_logger.log_no);
       RETURN 'ERROR';

     WHEN OTHERS THEN
       GenDocException(p_object_id, lv2_document_key, SQLCODE, SUBSTR(SQLERRM, 1, 240), 'ERROR', 'Y', l_logger.log_no);
       RETURN 'ERROR';
  END;
  l_logger.info('New ERP document created: ' || lv2_document_key);




  IF lrec_doc.preceding_document_key IS NOT NULL THEN
    l_logger.info('Applying reversal logic to ERP document ' || lv2_document_key);
BEGIN
      -- Applying reversal logic
      ReverseERPDocumentPostings(lrec_doc.document_key,p_user);
  EXCEPTION
       WHEN OTHERS THEN
         GenDocException(p_object_id, lv2_document_key, SQLCODE, SUBSTR(SQLERRM, 1, 240), 'ERROR', 'Y', l_logger.log_no);
         RETURN 'ERROR';
    END;
    l_logger.info('Reversal postings created for ERP document ' || lv2_document_key);
              END IF;


  l_logger.info('Creating new postings for ERP document ' || lv2_document_key);
BEGIN


    -- Insert postings
    FOR v IN c_postings(p_ext_doc_key) LOOP

          INSERT INTO cont_erp_postings
            (object_id,
             document_key,
             daytime,
             booking_amount,
             booking_currency_code,
             booking_currency_id,
             controling_area,
             doc_header_text,
             fin_account_descr,
             fin_account_type,
             fin_business_area,
             fin_cost_center_id,
             fin_cost_center_code,
             fin_cost_object_id,
             fin_cost_object_code,
             fin_customer_id,
             fin_customer_code,
             fin_debit_credit_code,
             fin_equity_group,
             fin_equity_type,
             fin_fiscal_year,
             fin_gl_account_id,
             fin_gl_account_code,
             fin_joint_venture,
             fin_material,
             fin_revenue_order_id,
             fin_revenue_order_code,
             fin_payment_term_id,
             fin_payment_term_code,
             fin_period,
             fin_plant,
             fin_posting_date,
             fin_posting_key,
             fin_profit_center_id,
             fin_profit_center_code,
             fin_reference,
             fin_vat_id,
             fin_vat_code,
             fin_transaction_type,
             fin_vat_reg_no,
             fin_vendor_id,
             fin_vendor_code,
             fin_wbs_id,
             fin_wbs_code,
             fin_wbs_ref,
             local_amount,
             local_currency_code,
             local_currency_id,
             qty_1,
             uom1_code,
             recovery_ind,
             reversal_date,
             reversal_ind,
             vat_amount,
             vat_local_amount,
             company_code,
             ex_rate,
             group_amount,
             line_item_text,
             trading_partner,
             reason_code,
             joint_venture,
             billing_ind,
             partner,
             curr_translation_date,
             value_date,
             invoice_reference_doc_key,
             invoice_line_item,
             purchasing_doc_number,
             purchasing_doc_line_item,
             withholding_tax_code,
             withholding_tax_base_amount,
             for_payment_country_code,
             for_payment_country_id,
             for_payment_bank_code,
             for_payment_bank_id,
             entry_qty,
             entry_uom,
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
             text_11,
             text_12,
             text_13,
             text_14,
             text_15,
             date_1,
             date_2,
             date_3,
             date_4,
             date_5,
             value_1,
             value_2,
             value_3,
             value_4,
             value_5,
             ref_object_id_1,
             ref_object_id_2,
             ref_object_id_3,
             ref_object_id_4,
             ref_object_id_5)
        VALUES
            (p_object_id,
             lv2_document_key,
             v.daytime,
             v.booking_amount,
             v.booking_currency_code,
             v.booking_currency_id,
             v.controling_area,
             v.doc_header_text,
             v.fin_account_descr,
             v.fin_account_type,
             v.fin_business_area,
             v.fin_cost_center_id,
             v.fin_cost_center_code,
             v.fin_cost_object_id,
             v.fin_cost_object_code,
             v.fin_customer_id,
             v.fin_customer_code,
             v.fin_debit_credit_code,
             v.fin_equity_group,
             v.fin_equity_type,
             v.fin_fiscal_year,
             v.fin_gl_account_id,
             v.fin_gl_account_code,
             v.fin_joint_venture,
             v.fin_material,
             v.fin_revenue_order_id,
             v.fin_revenue_order_code,
             v.fin_payment_term_id,
             v.fin_payment_term_code,
             v.fin_period,
             v.fin_plant,
             v.fin_posting_date,
             v.fin_posting_key,
             v.fin_profit_center_id,
             v.fin_profit_center_code,
             v.fin_reference,
             v.fin_vat_id,
             v.fin_vat_code,
             v.fin_transaction_type,
             v.fin_vat_reg_no,
             v.fin_vendor_id,
             v.fin_vendor_code,
             v.fin_wbs_id,
             v.fin_wbs_code,
             v.fin_wbs_ref,
             v.local_amount,
             v.local_currency_code,
             v.local_currency_id,
             v.qty_1,
             v.uom1_code,
             v.recovery_ind,
             v.reversal_date,
             v.reversal_ind,
             v.vat_amount,
             v.vat_local_amount,
             v.company_code,
             v.ex_rate,
             v.group_amount,
             v.line_item_text,
             v.trading_partner,
             v.reason_code,
             v.joint_venture,
             v.billing_ind,
             v.partner,
             v.curr_translation_date,
             v.value_date,
             v.invoice_reference_doc_key,
             v.invoice_line_item,
             v.purchasing_doc_number,
             v.purchasing_doc_line_item,
             v.withholding_tax_code,
             v.withholding_tax_base_amount,
             v.for_payment_country_code,
             v.for_payment_country_id,
             v.for_payment_bank_code,
             v.for_payment_bank_id,
             v.entry_qty,
             v.entry_uom,
             v.text_1,
             v.text_2,
             v.text_3,
             v.text_4,
             v.text_5,
             v.text_6,
             v.text_7,
             v.text_8,
             v.text_9,
             v.text_10,
             v.text_11,
             v.text_12,
             v.text_13,
             v.text_14,
             v.text_15,
             v.date_1,
             v.date_2,
             v.date_3,
             v.date_4,
             v.date_5,
             v.value_1,
             v.value_2,
             v.value_3,
             v.value_4,
             v.value_5,
             v.ref_object_id_1,
             v.ref_object_id_2,
             v.ref_object_id_3,
             v.ref_object_id_4,
             v.ref_object_id_5);


    END LOOP;
  EXCEPTION
     WHEN OTHERS THEN
       GenDocException(p_object_id, lv2_document_key, SQLCODE, SUBSTR(SQLERRM, 1, 240), 'ERROR', 'Y', l_logger.log_no);
       RETURN 'ERROR';
  END;
  l_logger.info('New postings created for ERP document ' || lv2_document_key);


  l_logger.info('Finalizing ERP document ' || lv2_document_key);
  BEGIN
    UPDATE ifac_document
       SET document_key = lv2_document_key
     WHERE ext_doc_key = p_ext_doc_key;


    -- Get system recommended action for the document
    ecdp_document_gen_util.GetERPDocumentRecActionCode(lv2_document_key, lv2_val_msg, lv2_val_code);

    UPDATE cont_document cd SET
        cd.system_action_code = lv2_val_code
    WHERE cd.document_key = lv2_document_key;



  EXCEPTION
     WHEN OTHERS THEN
       GenDocException(p_object_id, lv2_document_key, SQLCODE, SUBSTR(SQLERRM, 1, 240), 'ERROR', 'Y', l_logger.log_no);
       RETURN 'ERROR';
  END;



  l_logger.info('ERP Document (' || lv2_document_key || ' created successfully.');

  RETURN 'SUCCESS';


END GenERPDocument;

------------------------------------------------------------------------------------------------------------

FUNCTION PopulateERPDocRecord(
  p_object_id         VARCHAR2,
  p_contract_doc_id   VARCHAR2,
  p_document_key      VARCHAR2,
  p_preceding_doc_key VARCHAR2,
                                 p_daytime     DATE,
  p_vendor_id         VARCHAR2,
  p_status_code       VARCHAR2,
  p_document_type     VARCHAR2,
  p_ext_doc_key       VARCHAR2,
  p_document_number   VARCHAR2,
  p_user              VARCHAR2,
  p_operation         VARCHAR2 -- INSERTING / UPDATING
) RETURN cont_document%ROWTYPE
IS

  lrec_doc              cont_document%ROWTYPE := ec_cont_document.row_by_pk(p_document_key);  -- If inserting this will be null, and nvl handling applies
  lrec_ifac_doc         ifac_document%ROWTYPE := ec_ifac_document.row_by_pk(p_ext_doc_key);
  lrec_ds_version       contract_doc_version%ROWTYPE := ec_contract_doc_version.row_by_pk(p_contract_doc_id,p_daytime,'<=');
  lrec_contract         contract%ROWTYPE := ec_contract.row_by_pk(p_object_id);
  lrec_contract_version contract_version%ROWTYPE := ec_contract_version.row_by_pk(p_object_id,p_daytime,'<=');

BEGIN

  lrec_doc.object_id                 := p_object_id;
  lrec_doc.contract_doc_id           := p_contract_doc_id;
  lrec_doc.document_key              := p_document_key;
  lrec_doc.daytime                   := p_daytime;
  lrec_doc.document_date             := Ecdp_Contract_Setup.getDocDate(p_object_id, p_document_key, p_daytime, p_daytime, p_contract_doc_id);
  lrec_doc.production_period         := nvl(lrec_ifac_doc.production_period, lrec_doc.production_period);
  lrec_doc.status_code               := p_status_code;
  lrec_doc.ext_document_key          := p_ext_doc_key;
  lrec_doc.document_number           := p_document_number;
  lrec_doc.doc_date_calendar_coll_id := nvl(lrec_ifac_doc.doc_date_cal_coll_id,lrec_ds_version.doc_date_calendar_coll_id);
  lrec_doc.doc_rec_calendar_coll_id  := nvl(lrec_ifac_doc.doc_rec_cal_coll_id,lrec_ds_version.doc_rec_calendar_coll_id);
  lrec_doc.payment_calendar_coll_id  := nvl(lrec_ifac_doc.payment_cal_coll_id,lrec_ds_version.payment_calendar_coll_id);
  lrec_doc.document_type             := p_document_type;
  lrec_doc.preceding_document_key    := p_preceding_doc_key;
  lrec_doc.open_user_id              := p_user;
  lrec_doc.booking_currency_code     := ec_currency.object_code(nvl(lrec_ifac_doc.booking_currency_id,lrec_ds_version.booking_currency_id));
  lrec_doc.booking_currency_id       := nvl(lrec_ifac_doc.booking_currency_id,lrec_ds_version.booking_currency_id);
  lrec_doc.book_document_ind         := lrec_ds_version.book_document_code;
  lrec_doc.memo_currency_code        := ec_currency.object_code(nvl(lrec_ifac_doc.memo_currency_id,lrec_ds_version.memo_currency_id));
  lrec_doc.memo_currency_id          := nvl(lrec_ifac_doc.memo_currency_id,lrec_ds_version.memo_currency_id);
  lrec_doc.price_basis               := nvl(lrec_ifac_doc.price_basis,lrec_ds_version.price_basis);
  lrec_doc.contract_name             := lrec_contract_version.name; -- contract_name
  lrec_doc.contract_reference        := lrec_contract.object_code;
  lrec_doc.contract_group_code       := lrec_contract_version.contract_group_code;
  lrec_doc.doc_scope                 := lrec_ds_version.doc_scope;
  lrec_doc.owner_company_id          := lrec_contract_version.company_id;
  lrec_doc.doc_date_term_id	         := nvl(lrec_ifac_doc.doc_date_term_id,lrec_ds_version.doc_date_term_id);
  lrec_doc.doc_received_base_code    := nvl(lrec_ifac_doc.doc_received_base_code,lrec_ds_version.doc_received_base_code);
  lrec_doc.doc_received_base_date    := Ecdp_Contract_Setup.getBaseDate(p_object_id, p_document_key, p_daytime, 'DOC_RECEIVED', p_contract_doc_id); -- doc_received_base_date may return null
  lrec_doc.doc_received_term_id      := nvl(lrec_ifac_doc.doc_received_term_id,lrec_ds_version.doc_received_term_id);
  lrec_doc.document_received_date    := Ecdp_Contract_Setup.getDueDate(p_object_id, p_document_key, p_daytime, 'DOC_RECEIVED', p_contract_doc_id); -- document_received_date may return null
  lrec_doc.payment_term_base_code    := nvl(lrec_ifac_doc.payment_term_base_code,lrec_ds_version.payment_term_base_code);
  lrec_doc.payment_due_base_date     := Ecdp_Contract_Setup.getBaseDate(p_object_id, p_document_key, p_daytime, 'PAYMENT', p_contract_doc_id, p_vendor_id); -- payment_term_base_date may return null
  lrec_doc.payment_term_name         := ec_payment_term_version.name(nvl(lrec_ifac_doc.payment_term_id,lrec_ds_version.payment_term_id), p_daytime, '<='); --payment_term_name
  lrec_doc.pay_date                  := Ecdp_Contract_Setup.getDueDate(p_object_id, p_document_key, p_daytime, 'PAYMENT', p_contract_doc_id, p_vendor_id);  -- pay_date may return null
  lrec_doc.payment_term_id           := nvl(lrec_ifac_doc.payment_term_id,lrec_ds_version.payment_term_id);
  lrec_doc.amount_in_words_ind       := nvl(lrec_ifac_doc.amount_in_words,lrec_ds_version.amount_in_words);
  lrec_doc.use_currency_100_ind      := nvl(lrec_ifac_doc.use_currency_100_ind,lrec_ds_version.use_currency_100_ind);
  lrec_doc.document_level_code       := 'OPEN';
  lrec_doc.financial_code            := lrec_contract_version.financial_code;
  lrec_doc.taxable_ind               := 'N';
  lrec_doc.doc_template_id           := nvl(lrec_ifac_doc.doc_template_id,lrec_ds_version.doc_template_id);
  lrec_doc.inv_doc_template_id       := nvl(lrec_ifac_doc.inv_doc_template_id,lrec_ds_version.inv_doc_template_id);
  lrec_doc.doc_template_name         := ec_doc_template_version.name(nvl(lrec_ifac_doc.doc_template_id,lrec_ds_version.doc_template_id),p_daytime,'<='); -- doc templ code
  lrec_doc.inv_doc_template_name     := ec_doc_template_version.name(nvl(lrec_ifac_doc.inv_doc_template_id,lrec_ds_version.inv_doc_template_id),p_daytime,'<='); -- inv doc templ code
  lrec_doc.our_contact               := ec_t_basis_user.given_name(lrec_contract_version.system_owner) || ' ' || ec_t_basis_user.surname(lrec_contract_version.system_owner);
  lrec_doc.our_contact_phone         := ec_t_basis_user.phone(lrec_contract_version.system_owner);
  lrec_doc.cur_doc_template_name     := ec_doc_template_version.name(nvl(lrec_ifac_doc.doc_template_id,lrec_ds_version.doc_template_id),p_daytime,'<='); -- current_document_template
  lrec_doc.fin_interface_file        := NULL;
  lrec_doc.send_unit_price_ind       := nvl(lrec_ifac_doc.send_unit_price_ind,lrec_ds_version.send_unit_price_ind);
  lrec_doc.bank_details_level_code   := lrec_contract_version.bank_details_level_code;
  lrec_doc.document_concept          := lrec_ds_version.doc_concept_code;
  lrec_doc.reversal_ind              := 'N';
  lrec_doc.int_base_amount_src       := nvl(lrec_ifac_doc.int_base_amount_src,lrec_ds_version.int_base_amount_source);
  lrec_doc.contract_term_code        := lrec_contract_version.contract_term_code;
  lrec_doc.doc_sequence_accrual_id   := nvl(lrec_ifac_doc.doc_seq_accrual_id,lrec_ds_version.doc_sequence_accrual_id);
  lrec_doc.doc_sequence_final_id     := nvl(lrec_ifac_doc.doc_seq_final_id,lrec_ds_version.doc_sequence_final_id);
  lrec_doc.doc_number_format_accrual := nvl(lrec_ifac_doc.doc_number_format_accr,lrec_ds_version.doc_number_format_accrual);
  lrec_doc.doc_number_format_final   := nvl(lrec_ifac_doc.doc_number_format_final,lrec_ds_version.doc_number_format_final);
  lrec_doc.payment_scheme_id         := nvl(lrec_ifac_doc.payment_scheme_id,lrec_ds_version.payment_scheme_id);
  lrec_doc.contract_area_code        := ec_contract_area.object_code(lrec_contract_version.contract_area_id);
  lrec_doc.value_1                   := nvl(lrec_ifac_doc.value_1,lrec_contract_version.value_1);
  lrec_doc.value_2                   := nvl(lrec_ifac_doc.value_2,lrec_contract_version.value_2);
  lrec_doc.value_3                   := nvl(lrec_ifac_doc.value_3,lrec_contract_version.value_3);
  lrec_doc.value_4                   := nvl(lrec_ifac_doc.value_4,lrec_contract_version.value_4);
  lrec_doc.value_5                   := nvl(lrec_ifac_doc.value_5,lrec_contract_version.value_5);
  lrec_doc.value_6                   := nvl(lrec_ifac_doc.value_6,lrec_ds_version.value_6);
  lrec_doc.value_7                   := nvl(lrec_ifac_doc.value_7,lrec_ds_version.value_7);
  lrec_doc.value_8                   := nvl(lrec_ifac_doc.value_8,lrec_ds_version.value_8);
  lrec_doc.value_9                   := nvl(lrec_ifac_doc.value_9,lrec_ds_version.value_9);
  lrec_doc.value_10                  := nvl(lrec_ifac_doc.value_10,lrec_ds_version.value_10);
  lrec_doc.text_1                    := nvl(lrec_ifac_doc.text_1,lrec_contract_version.text_1);
  lrec_doc.text_2	                   := nvl(lrec_ifac_doc.text_2,lrec_contract_version.text_2);
  lrec_doc.text_3                    := nvl(lrec_ifac_doc.text_3,lrec_contract_version.text_3);
  lrec_doc.text_4                    := nvl(lrec_ifac_doc.text_4,lrec_contract_version.text_4);
  lrec_doc.text_5                    := nvl(lrec_ifac_doc.text_5,lrec_contract_version.text_5);
  lrec_doc.text_6                    := nvl(lrec_ifac_doc.text_6,lrec_ds_version.text_6);
  lrec_doc.text_7                    := nvl(lrec_ifac_doc.text_7,lrec_ds_version.text_7);
  lrec_doc.text_8                    := nvl(lrec_ifac_doc.text_8,lrec_ds_version.text_8);
  lrec_doc.text_9                    := nvl(lrec_ifac_doc.text_9,lrec_ds_version.text_9);
  lrec_doc.text_10                   := nvl(lrec_ifac_doc.text_10,lrec_ds_version.text_10);
  lrec_doc.date_1                    := nvl(lrec_ifac_doc.date_1,lrec_contract_version.date_1);
  lrec_doc.date_2                    := nvl(lrec_ifac_doc.date_2,lrec_contract_version.date_2);
  lrec_doc.date_3                    := nvl(lrec_ifac_doc.date_3,lrec_contract_version.date_3);
  lrec_doc.date_4                    := nvl(lrec_ifac_doc.date_4,lrec_contract_version.date_4);
  lrec_doc.date_5                    := nvl(lrec_ifac_doc.date_5,lrec_contract_version.date_5);
  lrec_doc.date_6                    := nvl(lrec_ifac_doc.date_6,lrec_ds_version.date_6);
  lrec_doc.date_7                    := nvl(lrec_ifac_doc.date_7,lrec_ds_version.date_7);
  lrec_doc.date_8                    := nvl(lrec_ifac_doc.date_8,lrec_ds_version.date_8);
  lrec_doc.date_9                    := nvl(lrec_ifac_doc.date_9,lrec_ds_version.date_9);
  lrec_doc.date_10                   := nvl(lrec_ifac_doc.date_10,lrec_ds_version.date_10);



  IF p_operation = 'INSERTING' THEN
    lrec_doc.created_by	:= p_user;

  ELSIF p_operation = 'UPDATING' THEN
    lrec_doc.last_updated_by := p_user;

           END IF;

  RETURN lrec_doc;

END PopulateERPDocRecord;

-----------------------------------------------------------------------------------------------------------------------------

/* JDBC query
   Used to determine I/F records subject to period document process.
 */
PROCEDURE q_PeriodDocumentProcess(p_cursor           OUT SYS_REFCURSOR,
                                  p_contract_id      VARCHAR2,
                                  p_contract_area_id VARCHAR2,
                                  p_business_unit_id VARCHAR2,
                                  p_doc_list         VARCHAR2 DEFAULT NULL)

IS

BEGIN

  IF (p_doc_list IS NULL) THEN

      OPEN p_cursor FOR
        SELECT pdp.*
        FROM v_period_document_process pdp
        WHERE pdp.contract_id = nvl(p_contract_id, pdp.contract_id)
        AND pdp.contract_area_id = nvl(p_contract_area_id, pdp.contract_area_id)
        AND pdp.business_unit_id = nvl(p_business_unit_id, pdp.business_unit_id);
  ELSE

      OPEN p_cursor FOR
        SELECT pdp.*
        FROM v_period_document_process pdp
        WHERE pdp.contract_id = nvl(p_contract_id, pdp.contract_id)
        AND pdp.contract_area_id = nvl(p_contract_area_id, pdp.contract_area_id)
        AND pdp.business_unit_id = nvl(p_business_unit_id, pdp.business_unit_id)
        AND (contract_code IN (SELECT generic_object_code
                               FROM dv_OBJECT_LIST_SETUP
                               WHERE relational_obj_code IS NULL
                               AND object_code = p_doc_list)
                               OR
                               ecdp_objects.GetObjCode(DOC_SETUP_ID) IN
                               (SELECT relational_obj_code
                                FROM dv_OBJECT_LIST_SETUP
                                WHERE relational_obj_code IS NOT NULL
                                AND object_code = p_doc_list));
  END IF;

  END q_PeriodDocumentProcess;

-----------------------------------------------------------------------------------------------------------------------------

/* JDBC query
   Used to determine I/F records subject to period document process, Prior Period Adjustments.
*/
/*PROCEDURE q_PeriodDocumentProcessPPA(p_cursor           OUT SYS_REFCURSOR,
                                     p_contract_id      VARCHAR2,
                                     p_contract_area_id VARCHAR2,
                                     p_business_unit_id VARCHAR2)
IS
BEGIN

  OPEN p_cursor FOR
  SELECT isqs.processing_period,
        isqs.period_start_date,
        isqs.period_end_date,
        isqs.contract_id,
        c.code contract_code,
        c.name contract_name,
        isqs.doc_setup_id,
        c.financial_code,
        ca.code contract_area_code,
        ec_business_unit.object_code(ca.business_unit_id) business_unit_code,
        c.pricing_currency_id,
        trunc(Ecdp_Timestamp.getCurrentSysdate, 'DD') doc_date,
        isqs.doc_status,
        'CREATE_PPA' action,
        NULL prec_doc_key,
        NULL delivery_point_id,
        NULL source_node_id
   FROM (
         SELECT DISTINCT isq.contract_id,
                          isq.doc_setup_id,
                          isq.processing_period,
                          MIN(isq.period_start_date) period_start_date,
                          MAX(isq.period_end_date) period_end_date,
                          isq.doc_status
           FROM ifac_sales_qty isq
          WHERE isq.alloc_no_max_ind = 'Y'
            AND isq.ignore_ind = 'N'
            AND isq.qty_status = 'PPA'
            AND isq.preceding_trans_key IS NOT NULL
            AND isq.trans_key_set_ind = 'N'
            AND isq.contract_id IS NOT NULL
            AND isq.doc_setup_id IS NOT NULL
            AND isq.delivery_point_id IS NOT NULL
            AND isq.profit_center_id IS NOT NULL
            AND isq.product_id IS NOT NULL
            AND isq.vendor_id IS NOT NULL
            AND isq.customer_id IS NOT NULL
            GROUP BY isq.contract_id,
                     isq.doc_setup_id,
                     isq.processing_period,
                     isq.doc_status
         ) isqs,
        ov_contract c,
        ov_contract_area ca,
        ov_business_unit bu
   WHERE isqs.contract_id = c.object_id
        -- Resolving contract
     AND c.object_id = nvl(p_contract_id, c.object_id)
     AND c.daytime = (SELECT MAX(daytime)
                        FROM contract_version
                       WHERE object_id = c.object_id
                         AND daytime <= isqs.processing_period)
        -- Resolving contract area
     AND c.contract_area_id = ca.object_id
     AND ca.object_id = nvl(p_contract_area_id, ca.object_id)
     AND ca.daytime =
         (SELECT MAX(daytime)
            FROM contract_area_version
           WHERE object_id = ca.object_id
             AND daytime <= isqs.processing_period)
        -- Resolving business unit
     AND ca.business_unit_id = bu.object_id
     AND bu.object_id = nvl(p_business_unit_id, bu.object_id)
     AND bu.daytime =
         (SELECT MAX(daytime)
            FROM business_unit_version
           WHERE object_id = bu.object_id
             AND daytime <= isqs.processing_period);

  END q_PeriodDocumentProcessPPA;  */


/*
PROCEDURE q_PeriodDocumentProcessRecon(p_cursor           OUT SYS_REFCURSOR,
          p_contract_id VARCHAR2,
                                       p_contract_area_id VARCHAR2,
                                       p_business_unit_id VARCHAR2)
IS
BEGIN

  OPEN p_cursor FOR
  SELECT isqs.processing_period,
        isqs.period_start_date,
        isqs.period_end_date,
        isqs.contract_id,
        c.code contract_code,
        c.name contract_name,
        isqs.doc_setup_id,
        c.financial_code,
        ca.code contract_area_code,
        ec_business_unit.object_code(ca.business_unit_id) business_unit_code,
        c.pricing_currency_id,
        trunc(Ecdp_Timestamp.getCurrentSysdate, 'DD') doc_date,
        isqs.doc_status,
        'CREATE_RECON' action,
        NULL prec_doc_key,
        NULL delivery_point_id,
        NULL source_node_id
   FROM (
          SELECT DISTINCT isq.contract_id,
                          isq.doc_setup_id,
                          MIN(isq.processing_period) processing_period,
                          MIN(isq.period_start_date) period_start_date,
                          MAX(isq.period_end_date)   period_end_date,
                          isq.doc_status
           FROM ifac_sales_qty isq
          WHERE isq.alloc_no_max_ind = 'Y'
            AND isq.ignore_ind = 'N'
            AND isq.qty_status = 'PPA'
            AND ec_contract_doc_version.doc_concept_code(isq.doc_setup_id, isq.period_start_date, '<=') = 'RECONCILIATION'
            AND isq.preceding_trans_key IS NOT NULL
            AND isq.trans_key_set_ind = 'N'
            AND isq.contract_id IS NOT NULL
            AND isq.doc_setup_id IS NOT NULL
            AND isq.delivery_point_id IS NOT NULL
            AND isq.profit_center_id IS NOT NULL
            AND isq.product_id IS NOT NULL
            AND isq.vendor_id IS NOT NULL
            AND isq.customer_id IS NOT NULL
            GROUP BY isq.contract_id,
                     isq.doc_setup_id,
                     isq.processing_period,
                     isq.doc_status
         ) isqs,
        ov_contract c,
        ov_contract_area ca,
        ov_business_unit bu
   WHERE isqs.contract_id = c.object_id
        -- Resolving contract
     AND c.object_id = nvl(p_contract_id, c.object_id)
     AND c.daytime = (SELECT MAX(daytime)
                        FROM contract_version
                       WHERE object_id = c.object_id
                         AND daytime <= isqs.processing_period)
        -- Resolving contract area
     AND c.contract_area_id = ca.object_id
     AND ca.object_id = nvl(p_contract_area_id, ca.object_id)
     AND ca.daytime =
         (SELECT MAX(daytime)
            FROM contract_area_version
           WHERE object_id = ca.object_id
             AND daytime <= isqs.processing_period)
        -- Resolving business unit
     AND ca.business_unit_id = bu.object_id
     AND bu.object_id = nvl(p_business_unit_id, bu.object_id)
     AND bu.daytime =
         (SELECT MAX(daytime)
            FROM business_unit_version
           WHERE object_id = bu.object_id
             AND daytime <= isqs.processing_period);

END q_PeriodDocumentProcessRecon;
*/

/* JDBC query
   Used to determine I/F records subject to cargo document process.
*/
PROCEDURE q_CargoDocumentProcess(p_cursor                    OUT SYS_REFCURSOR,
                                 p_contract_id               VARCHAR2,
                                 p_contract_area_id          VARCHAR2,
                                 p_business_unit_id          VARCHAR2,
                                 p_doc_list                  VARCHAR2 DEFAULT NULL)

IS

BEGIN


  IF (p_doc_list IS NULL) THEN
        OPEN p_cursor FOR
        SELECT * FROM V_CARGO_DOCUMENT_PROCESS
         WHERE contract_id = nvl(p_contract_id, contract_id)
           AND contract_area_id = nvl(p_contract_area_id, contract_area_id)
           AND business_unit_id = nvl(p_business_unit_id, business_unit_id);
  ELSE
         OPEN p_cursor FOR
         SELECT * FROM V_CARGO_DOCUMENT_PROCESS
         WHERE contract_id = nvl(p_contract_id, contract_id)
           AND contract_area_id = nvl(p_contract_area_id, contract_area_id)
           AND business_unit_id = nvl(p_business_unit_id, business_unit_id)
           AND (contract_code IN (SELECT generic_object_code FROM dv_OBJECT_LIST_SETUP
                                  WHERE relational_obj_code IS NULL
                                  AND object_code = p_doc_list)
                                  OR
                                  ecdp_objects.GetObjCode(SAVED_DOC_SETUP_ID) IN
                                  (SELECT relational_obj_code FROM dv_OBJECT_LIST_SETUP
                                  WHERE relational_obj_code IS NOT NULL
                                  AND object_code = p_doc_list));
  END IF;

END q_CargoDocumentProcess;



PROCEDURE q_NavParam(p_cursor OUT SYS_REFCURSOR, p_object_id VARCHAR2) IS

BEGIN

  OPEN p_cursor FOR

    SELECT NULL contract_id, NULL contract_area_id, bu.object_id business_unit_id
      FROM business_unit bu, business_unit_version buv
     WHERE bu.object_id = p_object_id
       AND bu.object_id = buv.object_id
       AND buv.daytime = (SELECT MAX(daytime)
                            FROM business_unit_version
                           WHERE object_id = bu.object_id
                             AND daytime < Ecdp_Timestamp.getCurrentSysdate)
    UNION ALL
    SELECT NULL contract_id, ca.object_id contract_area_id, cav.business_unit_id
      FROM contract_area ca, contract_area_version cav
     WHERE ca.object_id = p_object_id
       AND ca.object_id = cav.object_id
       AND cav.daytime = (SELECT MAX(daytime)
                            FROM contract_area_version
                           WHERE object_id = ca.object_id
                             AND daytime < Ecdp_Timestamp.getCurrentSysdate)
    UNION ALL
    SELECT c.object_id contract_id,
           cvv.contract_area_id contract_area_id,
           ec_contract_area_version.business_unit_id(cvv.contract_area_id, cvv.daytime, '<=') business_unit_id
      FROM contract c, contract_version cvv
     where c.object_id = p_object_id
       AND c.object_id = cvv.object_id
       AND cvv.daytime = (SELECT MAX(daytime)
                            FROM contract_version
                           WHERE object_id = c.object_id
                             AND daytime < Ecdp_Timestamp.getCurrentSysdate);

END q_NavParam;



/* JDBC query
   Used to determine I/F records subject to ERP document process.
 */
PROCEDURE q_ERPDocumentProcess(p_cursor           OUT SYS_REFCURSOR,
                               p_contract_id      VARCHAR2,
                               p_contract_area_id VARCHAR2,
                               p_business_unit_id VARCHAR2)

IS

lv2_contract_code                VARCHAR2(32);

BEGIN

lv2_contract_code := ec_contract.object_code(p_contract_id);

  OPEN p_cursor FOR
SELECT ecdp_document_gen_util.GetERPPrecedingDocKey(d.contract_id,
                                                    d.production_period) preceding_document_key,
       d.contract_id,
       d.contract_doc_id,
       d.ext_doc_key,
       d.document_number,
       d.daytime,
       d.status_code
  FROM ifac_document d
 WHERE d.contract_code = nvl(lv2_contract_code, d.contract_code)
   AND contract_id = nvl(p_contract_id, contract_id)
   AND contract_area_id = nvl(p_contract_area_id, contract_area_id)
   AND d.contract_code IN
       (SELECT c.object_code
          FROM contract c, contract_version cv
         WHERE c.object_id = cv.object_id
           AND cv.contract_area_id =
               nvl(p_contract_area_id, cv.contract_area_id)
           AND ec_contract_area_version.business_unit_id(cv.contract_area_id,
                                                         cv.daytime,
                                                         '<=') =
               nvl(p_business_unit_id,
                   ec_contract_area_version.business_unit_id(cv.contract_area_id,
                                                             cv.daytime,
                                                             '<='))
           AND cv.daytime =
               (SELECT MAX(cv_.daytime)
                  FROM contract_version cv_
                 WHERE cv_.object_id = c.object_id
                   AND cv_.daytime >= c.start_date
                   AND cv_.daytime < nvl(c.end_date, cv_.daytime + 1)
                   AND cv_.daytime < nvl(cv.end_date, cv_.daytime + 1)
                   AND cv_.daytime <= d.daytime))
   AND d.document_key IS NULL;



  END q_ERPDocumentProcess;


/* JDBC query
   Used to validate new or changed erp document.
 */
PROCEDURE q_ERPDocumentValidate(p_cursor            OUT SYS_REFCURSOR,
                                p_contract_id       VARCHAR2,
                                p_document_key      VARCHAR2,
                                p_production_period DATE)

IS

BEGIN

  OPEN p_cursor FOR
SELECT d.document_key
  FROM cont_document d, contract c
 WHERE c.object_id = d.object_id
   AND c.object_id = p_contract_id
   AND d.document_key <> nvl(p_document_key, 'NA')
   AND d.production_period = p_production_period
   AND nvl(d.document_level_code, 'OPEN') <> 'BOOKED';

  END q_ERPDocumentValidate;




PROCEDURE ReverseERPDocumentPostings(p_document_key VARCHAR2,
                                     p_user         VARCHAR2)
IS

  lrec_document cont_document%ROWTYPE;
  ln_num NUMBER := 0;

  CURSOR c_validate (cp_document_key VARCHAR2) IS
    SELECT COUNT(*) num
      FROM cont_erp_postings p
     WHERE p.document_key = cp_document_key
       AND nvl(p.reversal_ind, 'N') = 'Y';

  CURSOR c_preceding_postings(cp_document_key VARCHAR2) IS
    SELECT p.*
      FROM cont_erp_postings p
     WHERE p.document_key = cp_document_key
       AND nvl(p.reversal_ind, 'N') <> 'Y';

BEGIN

  -- Check that there are no reversal records. Reversing should only be done once per document.
  FOR rsVal IN c_validate(p_document_key) LOOP
    ln_num := rsVal.Num;
  END LOOP;

  IF ln_num = 0 THEN

    lrec_document := ec_cont_document.row_by_pk(p_document_key);

    FOR p IN c_preceding_postings(lrec_document.preceding_document_key) LOOP

      INSERT INTO cont_erp_postings
      (object_id,
       document_key,
       daytime,
       booking_amount,
       booking_currency_code,
       booking_currency_id,
       controling_area,
       doc_header_text,
       fin_account_descr,
       fin_account_type,
       fin_business_area,
       fin_cost_center_id,
       fin_cost_center_code,
       fin_cost_object_id,
       fin_cost_object_code,
       fin_customer_id,
       fin_customer_code,
       fin_debit_credit_code,
       fin_equity_group,
       fin_equity_type,
       fin_fiscal_year,
       fin_gl_account_id,
       fin_gl_account_code,
       fin_joint_venture,
       fin_material,
       fin_revenue_order_id,
       fin_revenue_order_code,
       fin_payment_term_id,
       fin_payment_term_code,
       fin_period,
       fin_plant,
       fin_posting_date,
       fin_posting_key,
       fin_profit_center_id,
       fin_profit_center_code,
       fin_reference,
       fin_vat_id,
       fin_vat_code,
       fin_transaction_type,
       fin_vat_reg_no,
       fin_vendor_id,
       fin_vendor_code,
       fin_wbs_id,
       fin_wbs_code,
       fin_wbs_ref,
       local_amount,
       local_currency_code,
       local_currency_id,
       qty_1,
       uom1_code,
       recovery_ind,
       reversal_date,
       reversal_ind,
       vat_amount,
       vat_local_amount,
       company_code,
       ex_rate,
       group_amount,
       line_item_text,
       trading_partner,
       reason_code,
       joint_venture,
       billing_ind,
       partner,
       curr_translation_date,
       value_date,
       invoice_reference_doc_key,
       invoice_line_item,
       purchasing_doc_number,
       purchasing_doc_line_item,
       withholding_tax_code,
       withholding_tax_base_amount,
       for_payment_country_code,
       for_payment_country_id,
       for_payment_bank_code,
       for_payment_bank_id,
       entry_qty,
       entry_uom,
       text_1,
       text_2,
       text_3,
       text_4,
       text_5,
       date_1,
       date_2,
       date_3,
       date_4,
       date_5,
       value_1,
       value_2,
       value_3,
       value_4,
       value_5,
       ref_object_id_1,
       ref_object_id_2,
       ref_object_id_3,
       ref_object_id_4,
       ref_object_id_5,
       created_by)
    VALUES
      (lrec_document.object_id,
       lrec_document.document_key,
       lrec_document.daytime,
       p.booking_amount,
       p.booking_currency_code,
       p.booking_currency_id,
       p.controling_area,
       p.doc_header_text,
       p.fin_account_descr,
       p.fin_account_type,
       p.fin_business_area,
       p.fin_cost_center_id,
       p.fin_cost_center_code,
       p.fin_cost_object_id,
       p.fin_cost_object_code,
       p.fin_customer_id,
       p.fin_customer_code,
       decode(p.fin_debit_credit_code,'DEBIT','CREDIT','CREDIT','DEBIT'),
       p.fin_equity_group,
       p.fin_equity_type,
       p.fin_fiscal_year,
       p.fin_gl_account_id,
       p.fin_gl_account_code,
       p.fin_joint_venture,
       p.fin_material,
       p.fin_revenue_order_id,
       p.fin_revenue_order_code,
       p.fin_payment_term_id,
       p.fin_payment_term_code,
       p.fin_period,
       p.fin_plant,
       p.fin_posting_date,
       p.fin_posting_key,
       p.fin_profit_center_id,
       p.fin_profit_center_code,
       p.fin_reference,
       p.fin_vat_id,
       p.fin_vat_code,
       p.fin_transaction_type,
       p.fin_vat_reg_no,
       p.fin_vendor_id,
       p.fin_vendor_code,
       p.fin_wbs_id,
       p.fin_wbs_code,
       p.fin_wbs_ref,
       p.local_amount,
       p.local_currency_code,
       p.local_currency_id,
       p.qty_1,
       p.uom1_code,
       p.recovery_ind,
       trunc(Ecdp_Timestamp.getCurrentSysdate),
       'Y',
       p.vat_amount,
       p.vat_local_amount,
       p.company_code,
       p.ex_rate,
       p.group_amount,
       p.line_item_text,
       p.trading_partner,
       p.reason_code,
       p.joint_venture,
       p.billing_ind,
       p.partner,
       p.curr_translation_date,
       p.value_date,
       p.invoice_reference_doc_key,
       p.invoice_line_item,
       p.purchasing_doc_number,
       p.purchasing_doc_line_item,
       p.withholding_tax_code,
       p.withholding_tax_base_amount,
       p.for_payment_country_code,
       p.for_payment_country_id,
       p.for_payment_bank_code,
       p.for_payment_bank_id,
       p.entry_qty,
       p.entry_uom,
       p.text_1,
       p.text_2,
       p.text_3,
       p.text_4,
       p.text_5,
       p.date_1,
       p.date_2,
       p.date_3,
       p.date_4,
       p.date_5,
       p.value_1,
       p.value_2,
       p.value_3,
       p.value_4,
       p.value_5,
       p.ref_object_id_1,
       p.ref_object_id_2,
       p.ref_object_id_3,
       p.ref_object_id_4,
       p.ref_object_id_5,
       p_user);

    END LOOP;

    -- Resolve posting key for reversals
    UPDATE cont_erp_postings p1
       SET p1.fin_posting_key =
           (SELECT MAX(p2.fin_posting_key)
              FROM cont_erp_postings p2
             WHERE p2.fin_debit_credit_code <> p1.fin_debit_credit_code
               AND p1.document_key = p2.document_key
               AND nvl(p2.reversal_ind, 'N') = 'Y')
     WHERE p1.document_key = p_document_key
       AND nvl(p1.reversal_ind, 'N') = 'Y';

  END IF; -- already reversed?

END ReverseERPDocumentPostings;







-- Validate parameters for document process
PROCEDURE ValidateDocProcessParams(p_contract_id     VARCHAR2,
                                   p_contract_doc_id VARCHAR2,
                                   p_source          VARCHAR2)

IS

BEGIN

  --Missing Object ID
  IF p_contract_id IS NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'Missing Contract ID when processing documents. Possible reason for this error is no match to any contracts in interfaced data. Source: ' || p_source);
  END IF;

  --Missing Document Setup ID
  IF p_contract_doc_id IS NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'Missing Document Setup ID when processing documents. Possible reason for this error is no match to any document setup in interfaced data. Source: ' || p_source);
  END IF;

END ValidateDocProcessParams;


END EcDp_Document_Gen;