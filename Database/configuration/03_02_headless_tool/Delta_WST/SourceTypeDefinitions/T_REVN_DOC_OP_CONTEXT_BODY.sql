CREATE OR REPLACE TYPE BODY T_REVN_DOC_OP_CONTEXT AS
    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    CONSTRUCTOR FUNCTION t_revn_doc_op_context
        RETURN SELF AS RESULT
    IS
    BEGIN
        RETURN;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE get_or_create_logger(
        p_logger                           OUT t_revn_logger
        )
    IS
    BEGIN
        IF log_no IS NOT NULL THEN
            p_logger := t_revn_logger(log_no);
        ELSE
            p_logger := t_revn_logger(log_category);
        END IF;

        p_logger.log_level_att := log_level_attribute;
        p_logger.init;
        p_logger.set_log_item_data(
            processing_document_key, processing_cargo_name, processing_contract_id);
        config_logger(p_logger.log_no, p_logger.category);
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE config_logger(
        p_log_no                           NUMBER
       ,p_log_category                     VARCHAR2
       ,p_log_level_attribute              VARCHAR2 DEFAULT 'DOC_GEN_LOG_LEVEL'
    )
    IS
    BEGIN
        log_no := p_log_no;
        log_category := p_log_category;
        log_level_attribute := nvl(p_log_level_attribute, 'DOC_GEN_LOG_LEVEL');
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER FUNCTION is_empty_period_ifac_data
        RETURN BOOLEAN
    IS
    BEGIN
        RETURN (ifac_period IS NULL OR ifac_period.count = 0);
    END;

      -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER FUNCTION is_empty_cargo_ifac_data
        RETURN BOOLEAN
    IS
    BEGIN
        RETURN (ifac_cargo IS NULL OR ifac_cargo.count = 0);
    END;


    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER FUNCTION copy
        RETURN T_REVN_DOC_OP_CONTEXT
    IS
        lo_result T_REVN_DOC_OP_CONTEXT;
    BEGIN
        lo_result := T_REVN_DOC_OP_CONTEXT();
        lo_result.ifac_period := ifac_period;
        lo_result.ifac_cargo  := ifac_cargo;

        RETURN lo_result;
    END;


    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER FUNCTION has_id_ifac_period(
        p_index                            NUMBER
       ,p_transaction_id                   NUMBER
       ,p_li_id                            NUMBER
       )
    RETURN BOOLEAN
    IS
    BEGIN
        RETURN (p_transaction_id IS NULL OR p_transaction_id = ifac_period(p_index).TRANS_ID)
            AND (p_li_id IS NULL OR p_li_id = ifac_period(p_index).LI_ID);
    END;



    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER FUNCTION has_id_ifac_cargo(
        p_index                            NUMBER
       ,p_transaction_id                   NUMBER
       ,p_li_id                            NUMBER
       )
    RETURN BOOLEAN
    IS
    BEGIN
        RETURN (p_transaction_id IS NULL OR p_transaction_id = ifac_cargo(p_index).TRANS_ID)
            AND (p_li_id IS NULL OR p_li_id = ifac_cargo(p_index).LI_ID);
    END;


    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE update_ifac_keys_period(
        p_transaction_id                   NUMBER
       ,p_transaction_key                  VARCHAR
       ,p_li_id                            NUMBER
       ,p_line_item_Key                    VARCHAR
    )
    IS
    BEGIN
        IF IS_EMPTY_PERIOD_IFAC_DATA THEN
            RETURN;
        END IF;

        FOR idx IN ifac_period.first..ifac_period.last LOOP
            IF NOT has_id_ifac_period(idx, p_transaction_id, p_li_id) THEN
                continue;
            END IF;

            ifac_period(idx).transaction_key := p_transaction_key;
            ifac_period(idx).TRANS_KEY_SET_IND := CASE WHEN p_transaction_key IS NULL THEN 'N' ELSE 'Y' END;
            ifac_period(idx).line_item_key := p_line_item_Key;
        END LOOP;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE update_ifac_keys_cargo(
        p_transaction_id                   NUMBER
       ,p_transaction_key                  VARCHAR
       ,p_li_id                            NUMBER
       ,p_line_item_Key                    VARCHAR
    )
    IS
    BEGIN
        IF IS_EMPTY_CARGO_IFAC_DATA THEN
            RETURN;
        END IF;

        FOR idx IN ifac_cargo.first..ifac_cargo.last LOOP
            IF NOT has_id_ifac_cargo(idx, p_transaction_id, p_li_id) THEN
                continue;
            END IF;

            ifac_cargo(idx).transaction_key := p_transaction_key;
            ifac_cargo(idx).TRANS_KEY_SET_IND := CASE WHEN p_transaction_key IS NULL THEN 'N' ELSE 'Y' END;
            ifac_cargo(idx).line_item_key := p_line_item_Key;
        END LOOP;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE update_ifac_keys_period(
        p_transaction_id                   NUMBER
       ,p_document_key                     VARCHAR
       ,p_transaction_key                  VARCHAR
       ,p_li_id                            NUMBER
       ,p_line_item_Key                    VARCHAR
    )
    IS
    BEGIN
        IF IS_EMPTY_PERIOD_IFAC_DATA THEN
            RETURN;
        END IF;

        FOR idx IN ifac_period.first..ifac_period.last LOOP
            IF NOT has_id_ifac_period(idx, p_transaction_id, p_li_id) THEN
                continue;
            END IF;

            ifac_period(idx).document_key := p_document_key;
            ifac_period(idx).transaction_key := p_transaction_key;
            ifac_period(idx).TRANS_KEY_SET_IND := CASE WHEN p_transaction_key IS NULL THEN 'N' ELSE 'Y' END;
            ifac_period(idx).line_item_key := p_line_item_Key;
        END LOOP;
    END;

     -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE update_ifac_keys_cargo(
        p_transaction_id                   NUMBER
       ,p_document_key                     VARCHAR
       ,p_transaction_key                  VARCHAR
       ,p_li_id                            NUMBER
       ,p_line_item_Key                    VARCHAR
    )
    IS
    BEGIN
        IF IS_EMPTY_CARGO_IFAC_DATA THEN
            RETURN;
        END IF;

        FOR idx IN ifac_cargo.first..ifac_cargo.last LOOP
            IF NOT has_id_ifac_cargo(idx, p_transaction_id, p_li_id) THEN
                continue;
            END IF;

            ifac_cargo(idx).document_key := p_document_key;
            ifac_cargo(idx).transaction_key := p_transaction_key;
            ifac_cargo(idx).TRANS_KEY_SET_IND := CASE WHEN p_transaction_key IS NULL THEN 'N' ELSE 'Y' END;
            ifac_cargo(idx).line_item_key := p_line_item_Key;
        END LOOP;
    END;
    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE remove_ifac_has_li_key_period
    IS
        l_new_table                        t_table_ifac_sales_qty;
    BEGIN
        l_new_table := t_table_ifac_sales_qty();

        FOR idx IN ifac_period.first..ifac_period.last LOOP
            IF ifac_period(idx).line_item_key IS NOT NULL THEN
                continue;
            END IF;

            l_new_table.extend(1);
            l_new_table(l_new_table.count) := ifac_period(idx);
        END LOOP;

        ifac_period := l_new_table;
    END;



    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE remove_ifac_has_li_key_cargo
    IS
        l_new_table                        t_table_ifac_cargo_value;
    BEGIN
        l_new_table := t_table_ifac_cargo_value();

        FOR idx IN ifac_cargo.first..ifac_cargo.last LOOP
            IF ifac_cargo(idx).line_item_key IS NOT NULL THEN
                continue;
            END IF;

            l_new_table.extend(1);
            l_new_table(l_new_table.count) := ifac_cargo(idx);
        END LOOP;

        ifac_cargo := l_new_table;
    END;


    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE remove_ifac_period(
        p_transaction_id                   NUMBER
       ,p_li_id                            NUMBER
       )
    IS
        l_new_table                        t_table_ifac_sales_qty;
    BEGIN
        l_new_table := t_table_ifac_sales_qty();

        FOR idx IN ifac_period.first..ifac_period.last LOOP
            IF has_id_ifac_period(idx, p_transaction_id, p_li_id) THEN
                continue;
            END IF;

            l_new_table.extend(1);
            l_new_table(l_new_table.count) := ifac_period(idx);
        END LOOP;

        ifac_period := l_new_table;
    END;


 -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE remove_ifac_cargo(
        p_transaction_id                   NUMBER
       ,p_li_id                            NUMBER
       )
    IS
        l_new_table                        t_table_ifac_cargo_value;
    BEGIN
        l_new_table := t_table_ifac_cargo_value();

        FOR idx IN ifac_cargo.first..ifac_cargo.last LOOP
            IF has_id_ifac_cargo(idx, p_transaction_id, p_li_id) THEN
                continue;
            END IF;

            l_new_table.extend(1);
            l_new_table(l_new_table.count) := ifac_cargo(idx);
        END LOOP;

        ifac_cargo := l_new_table;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE update_ifac_prec_keys_period(
        p_transaction_id                   NUMBER
       ,p_preceding_document_key           VARCHAR
       ,p_preceding_transaction_key        VARCHAR
       ,p_li_id                            NUMBER
       ,p_preceding_li_key                 VARCHAR
    )
    IS
    BEGIN
        IF IS_EMPTY_PERIOD_IFAC_DATA THEN
            RETURN;
        END IF;

        FOR idx IN ifac_period.first..ifac_period.last LOOP
            IF NOT has_id_ifac_period(idx, p_transaction_id, p_li_id) THEN
                continue;
            END IF;

            ifac_period(idx).preceding_li_key := p_preceding_li_key;
            ifac_period(idx).preceding_trans_key := p_preceding_transaction_key;
            ifac_period(idx).preceding_doc_key := p_preceding_document_key;
        END LOOP;
    END;
     -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE update_ifac_prec_keys_cargo(
        p_transaction_id                   NUMBER
       ,p_preceding_document_key           VARCHAR
       ,p_preceding_transaction_key        VARCHAR
       ,p_li_id                            NUMBER
       ,p_preceding_li_key                 VARCHAR
    )
    IS
    BEGIN
        IF IS_EMPTY_CARGO_IFAC_DATA THEN
            RETURN;
        END IF;

        FOR idx IN ifac_cargo.first..ifac_cargo.last LOOP
            IF NOT has_id_ifac_cargo(idx, p_transaction_id, p_li_id) THEN
                continue;
            END IF;

            ifac_cargo(idx).preceding_li_key := p_preceding_li_key;
            ifac_cargo(idx).preceding_trans_key := p_preceding_transaction_key;
            ifac_cargo(idx).preceding_doc_key := p_preceding_document_key;
        END LOOP;
    END;
    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE update_all_ifac_keys_period(
        p_transaction_key                  VARCHAR2
       ,p_line_item_Key                    VARCHAR2
    )
    IS
    BEGIN
        IF IS_EMPTY_PERIOD_IFAC_DATA THEN
            RETURN;
        END IF;

        FOR idx IN ifac_period.first..ifac_period.last LOOP
            ifac_period(idx).transaction_key := p_transaction_key;
            ifac_period(idx).TRANS_KEY_SET_IND := CASE WHEN p_transaction_key IS NULL THEN 'N' ELSE 'Y' END;
            ifac_period(idx).line_item_key := p_line_item_Key;
        END LOOP;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE update_all_ifac_doc_key_period(
        p_document_key                     VARCHAR2
    )
    IS
    BEGIN
        IF IS_EMPTY_PERIOD_IFAC_DATA THEN
            RETURN;
        END IF;

        FOR idx IN ifac_period.first..ifac_period.last LOOP
            ifac_period(idx).document_key := p_document_key;
        END LOOP;
    END;
   -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE update_all_ifac_doc_key_cargo(
        p_document_key                     VARCHAR2
    )
    IS
    BEGIN
        IF IS_EMPTY_CARGO_IFAC_DATA THEN
            RETURN;
        END IF;

        FOR idx IN ifac_cargo.first..ifac_cargo.last LOOP
            ifac_cargo(idx).document_key := p_document_key;
        END LOOP;
    END;
    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER FUNCTION get_ifac_period(
        p_index                            NUMBER
     )
    RETURN t_ifac_sales_qty
    IS
    BEGIN
        IF IS_EMPTY_PERIOD_IFAC_DATA THEN
            RETURN NULL;
        END IF;

        RETURN ifac_period(p_index);
    END;


 -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER FUNCTION get_ifac_cargo(
        p_index                            NUMBER
     )
    RETURN t_ifac_cargo_value
    IS
    BEGIN
        IF IS_EMPTY_CARGO_IFAC_DATA THEN
            RETURN NULL;
        END IF;

        RETURN ifac_cargo(p_index);
    END;
    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER FUNCTION ifac_period_count
    RETURN NUMBER
    IS
    BEGIN
        IF IS_EMPTY_PERIOD_IFAC_DATA THEN
            RETURN 0;
        END IF;

        RETURN ifac_period.count;
    END;


     -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER FUNCTION ifac_cargo_count
    RETURN NUMBER
    IS
    BEGIN
        IF IS_EMPTY_CARGO_IFAC_DATA THEN
            RETURN 0;
        END IF;

        RETURN ifac_cargo.count;
    END;
    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER FUNCTION ifac_period_first
    RETURN NUMBER
    IS
    BEGIN
        IF IS_EMPTY_PERIOD_IFAC_DATA THEN
            RETURN 0;
        END IF;

        RETURN ifac_period.first;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER FUNCTION ifac_period_last
    RETURN NUMBER
    IS
    BEGIN
        IF IS_EMPTY_PERIOD_IFAC_DATA THEN
            RETURN 0;
        END IF;

        RETURN ifac_period.last;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER FUNCTION ifac_cargo_first
    RETURN NUMBER
    IS
    BEGIN
        IF IS_EMPTY_CARGO_IFAC_DATA THEN
            RETURN 0;
        END IF;

        RETURN ifac_cargo.first;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER FUNCTION ifac_cargo_last
    RETURN NUMBER
    IS
    BEGIN
        IF IS_EMPTY_CARGO_IFAC_DATA THEN
            RETURN 0;
        END IF;

        RETURN ifac_cargo.last;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE apply_ifac_period_keys(
        p_index                            NUMBER
    )
    IS
        l_ifac_item                        t_ifac_sales_qty;
    BEGIN
        l_ifac_item := ifac_period(p_index);

        IF l_ifac_item.creation_type <> ecdp_revn_ifac_wrapper.gconst_creation_type_interface THEN
            RETURN;
        END IF;

        UPDATE ifac_sales_qty
        SET transaction_key = l_ifac_item.transaction_key,
            line_item_key = l_ifac_item.line_item_key,
            trans_key_set_ind = CASE
                WHEN l_ifac_item.line_item_key IS NULL THEN
                    ecdp_revn_common.gv2_false
                ELSE
                    ecdp_revn_common.gv2_true
                END,
            document_key = l_ifac_item.document_key,
            preceding_li_key = CASE
                WHEN preceding_li_key=l_ifac_item.line_item_key THEN
                    null
                ELSE
                    preceding_li_key
                END,
            preceding_doc_key= CASE
                WHEN preceding_doc_key=l_ifac_item.document_key THEN
                    null
                ELSE
                    preceding_doc_key
                END,
            preceding_trans_key= CASE
                WHEN preceding_trans_key=l_ifac_item.transaction_key THEN
                    null
                ELSE
                    preceding_trans_key
                END,
            last_updated_by = ECDP_REVN_COMMON.gv2_user_system
        WHERE source_entry_no = l_ifac_item.source_entry_no;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE apply_ifac_period_keys(
        p_indexes                          T_TABLE_NUMBER
    )
    IS
    BEGIN
        IF p_indexes is NULL OR p_indexes.count = 0 THEN
            RETURN;
        END IF;

        FOR idx IN p_indexes.first..p_indexes.last LOOP
            APPLY_IFAC_PERIOD_KEYS(p_indexes(idx));
        END LOOP;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE apply_ifac_period_keys
    IS
        l_indexes                          T_TABLE_NUMBER;
    BEGIN
        IF is_empty_period_ifac_data THEN
            RETURN;
        END IF;

        l_indexes := T_TABLE_NUMBER();

        FOR idx IN ifac_period.first..ifac_period.last LOOP
            l_indexes.extend();
            l_indexes(l_indexes.last) := idx;
        END LOOP;

        apply_ifac_period_keys(l_indexes);
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE apply_ifac_period_keys(
        p_trans_id                         NUMBER
       ,p_li_id                            NUMBER
    )
    IS
        l_range                            t_table_number;
    BEGIN
        IF is_empty_period_ifac_data THEN
            RETURN;
        END IF;

        l_range := t_table_number();

        FOR idx IN ifac_period.first..ifac_period.last LOOP
            IF ifac_period(idx).trans_id = p_trans_id
                AND ifac_period(idx).li_id = p_li_id THEN
                l_range.extend();
                l_range(l_range.last) := idx;
            END IF;
        END LOOP;

        apply_ifac_period_keys(l_range);
    END;

     -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE apply_ifac_cargo_keys(
        p_index                            NUMBER
    )
    IS
        l_ifac_item                        t_ifac_cargo_value;
    BEGIN
        l_ifac_item := ifac_cargo(p_index);

        IF l_ifac_item.creation_type <> ecdp_revn_ifac_wrapper.gconst_creation_type_interface THEN
            RETURN;
        END IF;

        UPDATE ifac_cargo_value
        SET transaction_key = l_ifac_item.transaction_key,
            line_item_key = l_ifac_item.line_item_key,
            trans_key_set_ind = CASE
                WHEN l_ifac_item.line_item_key IS NULL THEN
                    ecdp_revn_common.gv2_false
                ELSE
                    ecdp_revn_common.gv2_true
                END,
            document_key = l_ifac_item.document_key,
            preceding_li_key = CASE
                WHEN preceding_li_key=l_ifac_item.line_item_key THEN
                    null
                ELSE
                    preceding_li_key
                END,
            preceding_doc_key= CASE
                WHEN preceding_doc_key=l_ifac_item.document_key THEN
                    null
                ELSE
                    preceding_doc_key
                END,
            preceding_trans_key= CASE
                WHEN preceding_trans_key=l_ifac_item.transaction_key THEN
                    null
                ELSE
                    preceding_trans_key
                END,
            last_updated_by = ECDP_REVN_COMMON.gv2_user_system
        WHERE source_entry_no = l_ifac_item.source_entry_no;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE apply_ifac_cargo_keys(
        p_indexes                          T_TABLE_NUMBER
    )
    IS
    BEGIN
        IF p_indexes is NULL OR p_indexes.count = 0 THEN
            RETURN;
        END IF;

        FOR idx IN p_indexes.first..p_indexes.last LOOP
            APPLY_IFAC_CARGO_KEYS(p_indexes(idx));
        END LOOP;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE apply_ifac_cargo_keys
    IS
        l_indexes                          T_TABLE_NUMBER;
    BEGIN
        IF is_empty_cargo_ifac_data THEN
            RETURN;
        END IF;

        l_indexes := T_TABLE_NUMBER();

        FOR idx IN ifac_cargo.first..ifac_cargo.last LOOP
            l_indexes.extend();
            l_indexes(l_indexes.last) := idx;
        END LOOP;

        apply_ifac_cargo_keys(l_indexes);
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE apply_ifac_cargo_keys(
        p_trans_id                         NUMBER
       ,p_li_id                            NUMBER
    )
    IS
        l_range                            t_table_number;
    BEGIN
        IF is_empty_cargo_ifac_data THEN
            RETURN;
        END IF;

        l_range := t_table_number();

        FOR idx IN ifac_cargo.first..ifac_cargo.last LOOP
            IF ifac_cargo(idx).trans_id = p_trans_id
                AND ifac_cargo(idx).li_id = p_li_id THEN
                l_range.extend();
                l_range(l_range.last) := idx;
            END IF;
        END LOOP;

        apply_ifac_cargo_keys(l_range);
    END;


    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER FUNCTION get_ifac_prec_li_keys_period
    RETURN t_table_varchar2
    IS
        l_preceding_li_keys                t_table_varchar2;
        l_ifac                             t_ifac_sales_qty;
    BEGIN
        l_preceding_li_keys := t_table_varchar2();
        FOR Idx IN ifac_period_first..ifac_period_last LOOP
            l_ifac := get_ifac_period(Idx);
            IF l_ifac.INTERFACE_LEVEL <> ecdp_revn_ft_constants.ifac_level_line_item THEN
                CONTINUE;
            END IF;

            IF l_ifac.PRECEDING_LI_KEY IS NOT NULL THEN
                ecdp_revn_common.append(l_preceding_li_keys, l_ifac.PRECEDING_LI_KEY);
            END IF;
        END LOOP;

        RETURN l_preceding_li_keys;
    END;

      -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER FUNCTION get_ifac_prec_li_keys_cargo
    RETURN t_table_varchar2
    IS
        l_preceding_li_keys                t_table_varchar2;
        l_ifac                             t_ifac_cargo_value;
    BEGIN
        l_preceding_li_keys := t_table_varchar2();
        FOR Idx IN ifac_cargo_first..ifac_cargo_last LOOP
            l_ifac := get_ifac_cargo(Idx);
            IF l_ifac.INTERFACE_LEVEL <> ecdp_revn_ft_constants.ifac_level_line_item THEN
                CONTINUE;
            END IF;

            IF l_ifac.PRECEDING_LI_KEY IS NOT NULL THEN
                ecdp_revn_common.append(l_preceding_li_keys, l_ifac.PRECEDING_LI_KEY);
            END IF;
        END LOOP;

        RETURN l_preceding_li_keys;
    END;
END;