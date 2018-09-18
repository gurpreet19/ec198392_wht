CREATE OR REPLACE PACKAGE BODY ECDP_REVN_FT_DEBUG IS

    TYPE type_cursor IS REF CURSOR;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    PROCEDURE write_ft_line_item_dist_p(
        p_line_item_key                    cont_line_item.line_item_key%TYPE
       ,p_indentation                      NUMBER
    )
    IS
        lc_li_dist_pc                      type_cursor;
        lc_li_dist_vendor                  type_cursor;

        ln_indentation                     NUMBER;
        l_li_split_share_pc                NUMBER;
        l_li_dist_pc                       VARCHAR2(32);
        l_li_dist_id_pc                    VARCHAR2(32);
        l_li_split_share_vendor            NUMBER;
        l_li_vendor_share_vendor           NUMBER;
        l_li_dist_vendor                   VARCHAR2(32);
        l_li_dist_customer                 VARCHAR2(32);
        l_li_dist_vendor_qty1              NUMBER;
        l_li_dist_vendor_pricing_value     NUMBER;
        l_li_dist_customer_qty1            NUMBER;
        l_li_dist_customer_pricing_val     NUMBER;
    BEGIN
        ln_indentation := p_indentation;
        ecdp_revn_debug.write_i('Distributions', ln_indentation);

        OPEN lc_li_dist_pc FOR
            SELECT pc.split_share, ecdp_objects.GetObjCode(pc.dist_id) dist_code, pc.dist_id dist_id, pc.qty1, pc.pricing_value
            FROM cont_line_item_dist pc
            WHERE pc.line_item_key = p_line_item_key
            ORDER BY pc.sort_order, pc.dist_id;
        LOOP
            FETCH lc_li_dist_pc
            INTO l_li_split_share_pc, l_li_dist_pc, l_li_dist_id_pc,
                l_li_dist_vendor_qty1, l_li_dist_vendor_pricing_value;
            EXIT WHEN lc_li_dist_pc%NOTFOUND;

            ln_indentation := ln_indentation + 1;
            ecdp_revn_debug.write_i(l_li_dist_pc || ' - '
                || 'split_share:' || l_li_split_share_pc
                || ', qty1:' || l_li_dist_vendor_qty1
                || ', pricing_value:' || l_li_dist_vendor_pricing_value
                , ln_indentation);

            OPEN lc_li_dist_vendor FOR
                SELECT ecdp_objects.GetObjCode(vendor.vendor_id), ecdp_objects.GetObjCode(vendor.customer_id),
                    vendor.split_share, vendor.vendor_share, vendor.qty1, vendor.pricing_value
                FROM cont_li_dist_company vendor
                WHERE vendor.line_item_key = p_line_item_key
                    AND vendor.dist_id = l_li_dist_id_pc
                ORDER BY vendor.sort_order, vendor.vendor_id, vendor.customer_id;
            LOOP
                fetch lc_li_dist_vendor
                INTO l_li_dist_vendor, l_li_dist_customer, l_li_split_share_vendor,
                    l_li_vendor_share_vendor, l_li_dist_customer_qty1, l_li_dist_customer_pricing_val;
                EXIT WHEN lc_li_dist_vendor%NOTFOUND;

                ln_indentation := ln_indentation + 1;
                ecdp_revn_debug.write_i(l_li_dist_vendor || '|' || l_li_dist_customer || ' - '
                    || 'split_share:' || l_li_split_share_vendor
                    || ', vendor_share:' || l_li_vendor_share_vendor
                    || ', qty1:' || l_li_dist_customer_qty1
                    || ', pricing_value:' || l_li_dist_customer_pricing_val
                    , ln_indentation);

                ln_indentation := ln_indentation - 1;
            END LOOP;

            ln_indentation := ln_indentation - 1;
        END LOOP;
    END;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE write_ifac_rec_as_common(
        p_ifac_rec                         t_ifac_sales_qty
       ,p_indentation                      NUMBER
       )
    IS
    BEGIN
        IF p_ifac_rec.INTERFACE_LEVEL = ecdp_revn_ifac_wrapper.gconst_level_line_item THEN
            ecdp_revn_debug.write_i('line_item_type', p_ifac_rec.line_item_type, p_indentation);
            ecdp_revn_debug.write_i('dist_method', p_ifac_rec.li_dist_method, p_indentation);
            ecdp_revn_debug.write_i('doc_setup', ec_contract_doc.object_code(p_ifac_rec.doc_setup_id), p_indentation);
        ELSIF p_ifac_rec.INTERFACE_LEVEL = ecdp_revn_ifac_wrapper.gconst_level_profit_center THEN
            ecdp_revn_debug.write_i('profit_center', ecdp_objects.getobjcode(p_ifac_rec.PROFIT_CENTER_ID), p_indentation);
        END IF;
    END;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE write_ifac_rec_as_qty(
        p_ifac_rec                         t_ifac_sales_qty
       ,p_indentation                      NUMBER
       )
    IS
    BEGIN
        IF p_ifac_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_quantity THEN
            RETURN;
        END IF;

        ecdp_revn_debug.write_i('qty1', p_ifac_rec.qty1, p_indentation);
    END;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE write_ifac_rec_as_funit_p(
        p_ifac_rec                         t_ifac_sales_qty
       ,p_indentation                      NUMBER
       )
    IS
    BEGIN
        IF p_ifac_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_free_unit THEN
            RETURN;
        END IF;

        ecdp_revn_debug.write_i('qty1', p_ifac_rec.qty1, p_indentation);

        IF p_ifac_rec.INTERFACE_LEVEL = ecdp_revn_ifac_wrapper.gconst_level_line_item THEN
            ecdp_revn_debug.write_i('unit_price', p_ifac_rec.unit_price, p_indentation);
            ecdp_revn_debug.write_i('unit_price_unit', p_ifac_rec.unit_price_unit, p_indentation);
        END IF;
    END;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE write_ifac_rec_as_fixed_val_p(
        p_ifac_rec                         t_ifac_sales_qty
       ,p_indentation                      NUMBER
       )
    IS
    BEGIN
        IF p_ifac_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_fixed_value THEN
            RETURN;
        END IF;

        ecdp_revn_debug.write_i('pricing_value', p_ifac_rec.pricing_value, p_indentation);
    END;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE write_ifac_rec_as_perc_all_p(
        p_ifac_rec                         t_ifac_sales_qty
       ,p_indentation                      NUMBER
       )
    IS
    BEGIN
        IF p_ifac_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_percentage_all THEN
            RETURN;
        END IF;

        IF p_ifac_rec.INTERFACE_LEVEL = ecdp_revn_ifac_wrapper.gconst_level_line_item THEN
            ecdp_revn_debug.write_i('percentage_value', p_ifac_rec.percentage_value, p_indentation);
        END IF;
    END;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE write_ifac_rec_as_perc_qty_p(
        p_ifac_rec                         t_ifac_sales_qty
       ,p_indentation                      NUMBER
       )
    IS
    BEGIN
        IF p_ifac_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_percentage_qty THEN
            RETURN;
        END IF;

        IF p_ifac_rec.INTERFACE_LEVEL = ecdp_revn_ifac_wrapper.gconst_level_line_item THEN
            ecdp_revn_debug.write_i('percentage_value', p_ifac_rec.percentage_value, p_indentation);
        END IF;
    END;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE write_ifac_rec_as_perc_man_p(
        p_ifac_rec                         t_ifac_sales_qty
       ,p_indentation                      NUMBER
       )
    IS
    BEGIN
        IF p_ifac_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_percentage_manual THEN
            RETURN;
        END IF;

        IF p_ifac_rec.INTERFACE_LEVEL = ecdp_revn_ifac_wrapper.gconst_level_line_item THEN
            ecdp_revn_debug.write_i('percentage_value', p_ifac_rec.percentage_value, p_indentation);
        END IF;
        ecdp_revn_debug.write_i('percentage_base_amount', p_ifac_rec.percentage_base_amount, p_indentation);
    END;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE write_ifac_rec_as_interest_p(
        p_ifac_rec                         t_ifac_sales_qty
       ,p_indentation                      NUMBER
       )
    IS
    BEGIN
        IF p_ifac_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_interest THEN
            RETURN;
        END IF;

        IF p_ifac_rec.INTERFACE_LEVEL = ecdp_revn_ifac_wrapper.gconst_level_line_item THEN
            ecdp_revn_debug.write_i('int_type',               p_ifac_rec.int_type,               p_indentation);
            ecdp_revn_debug.write_i('int_rate_offset',        p_ifac_rec.int_rate_offset,        p_indentation);
            ecdp_revn_debug.write_i('int_compounding_period', p_ifac_rec.int_compounding_period, p_indentation);
            ecdp_revn_debug.write_i('int_from_date',          p_ifac_rec.int_from_date,          p_indentation);
            ecdp_revn_debug.write_i('int_to_date',            p_ifac_rec.int_to_date,            p_indentation);
            ecdp_revn_debug.write_i('int_base_rate',          p_ifac_rec.int_base_rate,          p_indentation);
            ecdp_revn_debug.write_i('int_base_amount',        p_ifac_rec.int_base_amount,        p_indentation);
        END IF;
    END;


    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE write_ifac_rec_p(
        p_ifac_rec                         t_ifac_sales_qty
       ,p_indentation                      NUMBER
    )
    IS
        l_message                          VARCHAR2(1000);
    BEGIN
        l_message := (CASE p_ifac_rec.creation_type
                WHEN ecdp_revn_ifac_wrapper.gconst_creation_type_interface THEN ' '
                WHEN ecdp_revn_ifac_wrapper.gconst_creation_type_auto_gen THEN '+'
                ELSE '?' END)
            || '[' || p_ifac_rec.INTERFACE_LEVEL || ',' || p_ifac_rec.TRANS_ID || ',' || p_ifac_rec.LI_ID || ']'
            || ' - ' || p_ifac_rec.line_item_based_type
            || ', Keys={' || p_ifac_rec.DOCUMENT_KEY
            || ', ' || p_ifac_rec.TRANSACTION_KEY
            || ', ' || p_ifac_rec.line_item_key || '}'
            || ', SourceNo=' || p_ifac_rec.SOURCE_ENTRY_NO
            || ' ';
        ecdp_revn_debug.write_i(l_message, p_indentation);

        IF p_ifac_rec.INTERFACE_LEVEL = ecdp_revn_ifac_wrapper.gconst_level_transaction THEN
            RETURN;
        END IF;

        write_ifac_rec_as_common(p_ifac_rec, p_indentation + 1);
        write_ifac_rec_as_qty(p_ifac_rec, p_indentation + 1);
        write_ifac_rec_as_fixed_val_p(p_ifac_rec, p_indentation + 1);
        write_ifac_rec_as_funit_p(p_ifac_rec, p_indentation + 1);
        write_ifac_rec_as_perc_all_p(p_ifac_rec, p_indentation + 1);
        write_ifac_rec_as_perc_man_p(p_ifac_rec, p_indentation + 1);
        write_ifac_rec_as_perc_qty_p(p_ifac_rec, p_indentation + 1);
        write_ifac_rec_as_interest_p(p_ifac_rec, p_indentation + 1);
    END;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE write_line_item_as_common(
        p_line_item_rec                    cont_line_item%ROWTYPE
       ,p_indentation                      NUMBER
       )
    IS
    BEGIN
        ecdp_revn_debug.write_i('line_item_type', p_line_item_rec.line_item_type, p_indentation);
        ecdp_revn_debug.write_i('line_item_template',
            ec_line_item_template.object_code(p_line_item_rec.line_item_template_id), p_indentation);
        ecdp_revn_debug.write_i('pricing_value', p_line_item_rec.pricing_value, p_indentation);
        ecdp_revn_debug.write_i('creation_method', p_line_item_rec.creation_method, p_indentation);
        ecdp_revn_debug.write_i('dist_method', p_line_item_rec.dist_method, p_indentation);
    END;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE write_line_item_as_qty(
        p_line_item_rec                    cont_line_item%ROWTYPE
       ,p_indentation                      NUMBER
       )
    IS
    BEGIN
        IF p_line_item_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_quantity THEN
            RETURN;
        END IF;

        ecdp_revn_debug.write_i('qty1', p_line_item_rec.qty1, p_indentation);
        ecdp_revn_debug.write_i('uom1_code', p_line_item_rec.uom1_code, p_indentation);
        ecdp_revn_debug.write_i('qty2', p_line_item_rec.qty2, p_indentation);
        ecdp_revn_debug.write_i('uom2_code', p_line_item_rec.uom2_code, p_indentation);
        ecdp_revn_debug.write_i('qty3', p_line_item_rec.qty3, p_indentation);
        ecdp_revn_debug.write_i('uom3_code', p_line_item_rec.uom3_code, p_indentation);
        ecdp_revn_debug.write_i('qty4', p_line_item_rec.qty4, p_indentation);
        ecdp_revn_debug.write_i('uom4_code', p_line_item_rec.uom4_code, p_indentation);
    END;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE write_line_item_as_funit_p(
        p_line_item_rec                    cont_line_item%ROWTYPE
       ,p_indentation                      NUMBER
       )
    IS
    BEGIN
        IF p_line_item_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_free_unit THEN
            RETURN;
        END IF;

        ecdp_revn_debug.write_i('qty1', p_line_item_rec.qty1, p_indentation);
        ecdp_revn_debug.write_i('uom1_code', p_line_item_rec.uom1_code, p_indentation);
        ecdp_revn_debug.write_i('free_unit_qty', p_line_item_rec.free_unit_qty, p_indentation);
        ecdp_revn_debug.write_i('unit_price', p_line_item_rec.unit_price, p_indentation);
        ecdp_revn_debug.write_i('unit_price_unit', p_line_item_rec.unit_price_unit, p_indentation);
    END;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE write_line_item_as_fixed_val_p(
        p_line_item_rec                    cont_line_item%ROWTYPE
       ,p_indentation                      NUMBER
       )
    IS
    BEGIN
        IF p_line_item_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_fixed_value THEN
            RETURN;
        END IF;
    END;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE write_line_item_as_perc_all_p(
        p_line_item_rec                    cont_line_item%ROWTYPE
       ,p_indentation                      NUMBER
       )
    IS
    BEGIN
        IF p_line_item_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_percentage_all THEN
            RETURN;
        END IF;

        ecdp_revn_debug.write_i('percentage_value', p_line_item_rec.percentage_value, p_indentation);
    END;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE write_line_item_as_perc_qty_p(
        p_line_item_rec                    cont_line_item%ROWTYPE
       ,p_indentation                      NUMBER
       )
    IS
    BEGIN
        IF p_line_item_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_percentage_qty THEN
            RETURN;
        END IF;

        ecdp_revn_debug.write_i('percentage_value', p_line_item_rec.percentage_value, p_indentation);
    END;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE write_line_item_as_perc_man_p(
        p_line_item_rec                    cont_line_item%ROWTYPE
       ,p_indentation                      NUMBER
       )
    IS
    BEGIN
        IF p_line_item_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_percentage_manual THEN
            RETURN;
        END IF;

        ecdp_revn_debug.write_i('percentage_value', p_line_item_rec.percentage_value, p_indentation);
        ecdp_revn_debug.write_i('percentage_base_amount', p_line_item_rec.percentage_base_amount, p_indentation);
    END;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE write_line_item_as_interest_p(
        p_line_item_rec                    cont_line_item%ROWTYPE
       ,p_indentation                      NUMBER
       )
    IS
    BEGIN
        IF p_line_item_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_interest THEN
            RETURN;
        END IF;

        ecdp_revn_debug.write_i('interest_group', p_line_item_rec.interest_group, p_indentation);
        ecdp_revn_debug.write_i('interest_type', p_line_item_rec.interest_type, p_indentation);
        ecdp_revn_debug.write_i('rate_offset', p_line_item_rec.rate_offset, p_indentation);
        ecdp_revn_debug.write_i('compounding_period', p_line_item_rec.compounding_period, p_indentation);
        ecdp_revn_debug.write_i('interest_from_date', p_line_item_rec.interest_from_date, p_indentation);
        ecdp_revn_debug.write_i('interest_to_date', p_line_item_rec.interest_to_date, p_indentation);
        ecdp_revn_debug.write_i('base_rate', p_line_item_rec.base_rate, p_indentation);
        ecdp_revn_debug.write_i('rate_days', p_line_item_rec.rate_days, p_indentation);
        ecdp_revn_debug.write_i('interest_num_days', p_line_item_rec.interest_num_days, p_indentation);
        ecdp_revn_debug.write_i('interest_base_amount', p_line_item_rec.interest_base_amount, p_indentation);
    END;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE write_line_item_p(
        p_line_item_key                    cont_line_item.line_item_key%TYPE
       ,p_indentation                      NUMBER
    )
    IS
        l_c                                type_cursor;
        l_line_item                        cont_line_item%ROWTYPE;
    BEGIN
        OPEN l_c FOR
            SELECT * FROM cont_line_item
            WHERE line_item_key = p_line_item_key
            ORDER BY cont_line_item.line_item_key;
        LOOP
            FETCH l_c INTO l_line_item;
            EXIT WHEN l_c%NOTFOUND;

            ecdp_revn_debug.write_i('[' || l_line_item.line_item_based_type || '] '
                || l_line_item.line_item_key || ' - ' || l_line_item.name, p_indentation);

            write_line_item_as_common(l_line_item, p_indentation + 1);
            write_line_item_as_qty(l_line_item, p_indentation + 1);
            write_line_item_as_funit_p(l_line_item, p_indentation + 1);
            write_line_item_as_fixed_val_p(l_line_item, p_indentation + 1);
            write_line_item_as_perc_all_p(l_line_item, p_indentation + 1);
            write_line_item_as_perc_qty_p(l_line_item, p_indentation + 1);
            write_line_item_as_perc_man_p(l_line_item, p_indentation + 1);
            write_line_item_as_interest_p(l_line_item, p_indentation + 1);
        END LOOP;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    PROCEDURE write_doc(
        p_title                            VARCHAR2
       ,p_document_key                     cont_document.document_key%TYPE
        )
    IS
        lc                                type_cursor;
        lc_line_item                      type_cursor;

        lv2_transaction_key               varchar2(32);
        lv2_line_item_key                 varchar2(32);
        lv2_name                          varchar2(240);
        ln_indentation                    NUMBER;
        l_transaction_qty1                NUMBER;
    BEGIN
        ecdp_revn_debug.write_header_i('Document ' || p_document_key, p_title);
        ln_indentation := 0;

        OPEN lc FOR
            SELECT cont_transaction.transaction_key, cont_transaction.name, cont_transaction_qty.net_qty1
            FROM cont_transaction, cont_transaction_qty
            WHERE document_key = p_document_key
                AND cont_transaction.transaction_key = cont_transaction_qty.transaction_key
            ORDER BY cont_transaction.transaction_key;
        LOOP
            FETCH lc INTO lv2_transaction_key, lv2_name, l_transaction_qty1;
            EXIT WHEN lc%NOTFOUND;

            ln_indentation := ln_indentation + 1;
            ecdp_revn_debug.write_i('Transaction ' || lv2_transaction_key || ' - ' || lv2_name || ', net_qty1=' || l_transaction_qty1, 1);

            open lc_line_item for
                select line_item_key
                from cont_line_item l
                where transaction_key = lv2_transaction_key
                ORDER BY l.line_item_key;
            LOOP
                FETCH lc_line_item INTO lv2_line_item_key;
                EXIT WHEN lc_line_item%notfound;

                write_line_item_p(lv2_line_item_key, ln_indentation + 1);
                write_ft_line_item_dist_p(lv2_line_item_key, ln_indentation + 2);
            end loop;
            close lc_line_item;
            ecdp_revn_debug.write;
            ln_indentation := ln_indentation - 1;

        END LOOP;
        CLOSE lc;

        ecdp_revn_debug.write;
    END;


    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    PROCEDURE write(
        p_title                            VARCHAR2
       ,p_ifac_collection                  t_table_ifac_sales_qty
       ,p_indentation                      NUMBER DEFAULT 0
        )
    IS
        l_indentation                      NUMBER;
    BEGIN
        l_indentation := nvl(p_indentation, 0);
        ecdp_revn_debug.write_header_i('Period Ifac Content', p_title, p_indentation);

        IF p_ifac_collection IS NULL THEN
            ecdp_revn_debug.write_i('(collection is null)', l_indentation + 1);
        END IF;

        IF p_ifac_collection.count = 0 THEN
            ecdp_revn_debug.write_i('(collection is empty)', l_indentation + 1);
        END IF;

        FOR idx IN 1..p_ifac_collection.count LOOP
            write_ifac_rec_p(p_ifac_collection(idx), l_indentation + 1);
        END LOOP;

        ecdp_revn_debug.write;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    PROCEDURE write_new_ifac_period(
        p_title                            VARCHAR2
        )
    IS
        CURSOR c_ifac_doc IS
            SELECT *
            FROM v_period_document_process;

        t_ifac                             t_table_ifac_sales_qty;
        l_indentation                      NUMBER;
        l_doc_count                        NUMBER;
    BEGIN
        ecdp_revn_debug.write_header_i('Pending FT Period Interface', p_title);
        l_indentation := 0;
        l_doc_count := 0;

        FOR ifac_doc IN c_ifac_doc LOOP
            l_indentation := l_indentation + 1;
            l_doc_count := l_doc_count + 1;
            t_ifac := ecdp_revn_ifac_wrapper_period.GetIfacForDocument(
                ifac_doc.contract_id, ifac_doc.doc_setup_id, ifac_doc.processing_period, ifac_doc.customer_id, ifac_doc.doc_status);
            write('[DOC ' || l_doc_count || ']', t_ifac, l_indentation);
            ecdp_revn_debug.write_seperator(l_indentation);
            l_indentation := l_indentation - 1;
        END LOOP;
    END;

END ECDP_REVN_FT_DEBUG;