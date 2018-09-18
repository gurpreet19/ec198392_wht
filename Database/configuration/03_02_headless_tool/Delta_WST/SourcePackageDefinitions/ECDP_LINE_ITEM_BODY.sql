CREATE OR REPLACE PACKAGE BODY EcDp_Line_Item IS
    --*********************************************************************
    --* Provides functionality connected to Line Items.
    --*
    --* Created on 28.04.2006
    --*********************************************************************


    -----------------------------------------------------------------------
    -- Cursor that returns price element records from given price concept.
    ----+----------------------------------+-------------------------------
    CURSOR c_get_price_element_rec (
        p_price_concept_code price_concept_element.price_concept_code%TYPE
    ) IS
        SELECT pce.price_element_code,
            pce.price_concept_code,
            pce.name,
            pce.line_item_type
        FROM price_concept_element pce
        WHERE pce.price_concept_code = p_price_concept_code;

    -----------------------------------------------------------------------
    -- Cursor that returns all free unit line items belong to the same set
    -- as provided main line item.
    ----+----------------------------------+-------------------------------
    CURSOR c_get_auto_gen_freeunit_po_li(
        p_parent_line_item_key             VARCHAR2
    ) IS
        SELECT child.line_item_key
        FROM cont_line_item child, cont_line_item par
        WHERE child.transaction_key = par.transaction_key
            AND par.line_item_key = p_parent_line_item_key
            AND child.line_item_key != par.line_item_key
            AND child.creation_method = ecdp_revn_ft_constants.c_mtd_auto_gen
            AND child.price_object_id = par.price_object_id
            AND child.price_concept_code = par.price_concept_code
            AND child.line_item_based_type = ecdp_revn_ft_constants.li_btype_free_unit_po
            AND child.line_item_type = par.line_item_type
            AND child.ifac_li_conn_code = par.ifac_li_conn_code
            AND ((child.line_item_template_id IS NULL AND par.line_item_template_id IS NULL)
                OR child.line_item_template_id = par.line_item_template_id);

    -----------------------------------------------------------------------
    -- Deletes the specified profit center distribution from a line item.
    ----+----------------------------------+-------------------------------
    PROCEDURE del_dist_by_pc_i(
        p_line_item_key                    cont_line_item.line_item_key%TYPE
       ,p_profit_center_id                 cont_line_item_dist.dist_id%TYPE
       )
    IS
    BEGIN
        DELETE FROM cont_li_dist_company
        WHERE line_item_key = p_line_item_key
              AND dist_id = p_profit_center_id;

        DELETE FROM cont_line_item_dist
        WHERE line_item_key = p_line_item_key
              AND dist_id = p_profit_center_id;
    END;

    -----------------------------------------------------------------------
-- Deletes the specified vendor distribution from a line item.
-----------------------------------------------------------------
PROCEDURE del_dist_by_pc_vd_i(p_line_item_key    cont_line_item.line_item_key%TYPE,
                              p_profit_center_id cont_line_item_dist.dist_id%TYPE,
                              p_vendor_id        cont_li_dist_company.vendor_id%TYPE) IS
BEGIN
  DELETE FROM cont_li_dist_company
   WHERE line_item_key = p_line_item_key
     AND dist_id = p_profit_center_id
     and vendor_id = p_vendor_id;
END;

    -----------------------------------------------------------------------
    -- Deletes distribution from a line item.
    ----+----------------------------------+-------------------------------
    PROCEDURE del_dist_i(
        p_line_item_key                    cont_line_item.line_item_key%TYPE
        )
    IS
    BEGIN
        DELETE FROM cont_li_dist_company
        WHERE line_item_key = p_line_item_key;

        DELETE FROM cont_line_item_dist
        WHERE line_item_key = p_line_item_key;
    END;

    -----------------------------------------------------------------------
    -- Deletes line item UOM records.
    ----+----------------------------------+-------------------------------
    PROCEDURE del_uom_rec_p(
        p_line_item_key                    cont_line_item.line_item_key%TYPE
        )
    IS
    BEGIN
        DELETE FROM cont_line_item_uom
        WHERE line_item_key = p_line_item_key;
    END;

    -----------------------------------------------------------------------
    -- Deletes line item record.
    ----+----------------------------------+-------------------------------
    PROCEDURE del_li_rec_p(
        p_line_item_key                    cont_line_item.line_item_key%TYPE
        )
    IS
    BEGIN
        DELETE FROM cont_line_item
        WHERE line_item_key = p_line_item_key;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    PROCEDURE upd_creation_method(
        p_line_item_keys                   t_table_varchar2
       ,p_creation_method                  ecdp_revn_ft_constants.T_IFAC_CTYPE
       )
    IS
    BEGIN
        UPDATE cont_line_item
        SET creation_method = p_creation_method
        WHERE line_item_key IN (SELECT column_value FROM TABLE(p_line_item_keys));
    END;

    -----------------------------------------------------------------------
    -- Inserts an interest line item
    ----+----------------------------------+-------------------------------
    FUNCTION InsInterestLineItem (
        p_object_id            VARCHAR2,
        p_transaction_key      VARCHAR2,
        p_li_template_id       VARCHAR2, -- could be null
        p_interest_from_date   DATE,
        p_interest_to_date     DATE,
        p_base_amt             NUMBER, -- in pricing currency
        p_base_rate            NUMBER,
        p_parent_line_item_key VARCHAR2,
        p_interest_type        VARCHAR2,
        p_name                 VARCHAR2,
        p_rate_offset          NUMBER,
        p_compounding_period   NUMBER,
        p_interest_group       VARCHAR2,
        p_number_of_days       NUMBER,
        p_user                 VARCHAR2,
        p_line_item_type       VARCHAR2,
        p_comment              VARCHAR2 DEFAULT NULL,
        p_sort_order           NUMBER DEFAULT NULL,
        p_creation_method      ecdp_revn_ft_constants.t_c_mtd DEFAULT ecdp_revn_ft_constants.c_mtd_manual
        )
    RETURN VARCHAR2
    IS

      lv2_line_item_key cont_line_item.line_item_key%TYPE;

      lv2_document_key cont_document.document_key%TYPE;
      lrec_li cont_line_item%ROWTYPE;
      ld_daytime DATE;
      ln_precision NUMBER := NVL(ec_ctrl_system_attribute.attribute_value(p_interest_from_date, 'EX_VAT_PRECISION', '<='), 2);
      ln_date_diff NUMBER;
      lv2_interest_group cont_line_item.interest_group%TYPE;
      ln_number_of_days NUMBER;
      lrec_undefined_customer contract_party_share%rowtype;
      lv2_customer_id company.object_id%type;
      l_creation_method ecdp_revn_ft_constants.t_c_mtd;

    BEGIN
        l_creation_method := nvl(p_creation_method, ecdp_revn_ft_constants.c_mtd_manual);
        -- Recursive call might include last argument -> If inserting several line items considered part of the same interest_group
        -- Returns interest group line_item_id.

        IF (p_number_of_days IS NULL) THEN
            ln_number_of_days := 365;
        ELSE
            ln_number_of_days := p_number_of_days;
        END IF;

        lv2_document_key := ec_cont_transaction.document_key(p_transaction_key);
        ld_daytime := ec_cont_document.daytime(lv2_document_key);
        lrec_undefined_customer := ec_contract_party_share.row_by_pk(p_object_id,ec_company.object_id_by_uk('UNDEFINED','CUSTOMER'),'CUSTOMER',ld_daytime,'<=');

        IF lrec_undefined_customer.company_id IS NOT NULL THEN
            lv2_customer_id := ecdp_contract_setup.GetDocCustomerId(lv2_document_key);
        END IF;

        -- 1. Insert line item
        lv2_line_item_key := InsNewLineItem(p_object_id,
                                            ld_daytime,
                                            lv2_document_key,
                                            p_transaction_key,
                                            p_li_template_id,
                                            p_user,
                                            NULL,
                                            nvl(p_line_item_type,'INTEREST'),
                                            'INTEREST',
                                            TO_NUMBER(NULL),
                                            TO_NUMBER(NULL),
                                            TO_NUMBER(NULL),
                                            NULL,
                                            TO_NUMBER(NULL),
                                            TO_NUMBER(NULL),
                                            p_name,
                                            NULL,
                                            NULL,
                                            lv2_customer_id,
                                            NULL,
                                            p_sort_order,
                                            p_creation_method => l_creation_method);

        lrec_li := ec_cont_line_item.row_by_pk(lv2_line_item_key);

        -- 2. Calculate gross rate
        lrec_li.gross_rate := p_base_rate + p_rate_offset;

        -- 3. Calculate rate_days and interest_to_date
        ln_date_diff := p_interest_to_date-p_interest_from_date;
        lrec_li.rate_days := LEAST(nvl(p_compounding_period,ln_date_diff+1),ln_date_diff);
        lrec_li.interest_to_date := p_interest_from_date + lrec_li.rate_days;

        -- 4. Calcuate interest pricing_value (booking and other are calcuated by IUD_CONT_LINE_ITEM on update)
        lrec_li.pricing_value := ROUND(p_base_amt * nvl(lrec_li.gross_rate,0)/100 * nvl(lrec_li.rate_days,0)/ln_number_of_days , ln_precision);

        -- 5. Add 'compound' to name if the new li is a child
        IF p_parent_line_item_key IS NOT NULL THEN
            lrec_li.name := p_name ||' - Compound';
        ELSE
            lrec_li.name := p_name;
        END IF;

        -- set interest group
        IF p_interest_group IS NULL THEN
            lrec_li.interest_group := lv2_line_item_key;
        ELSE
            lrec_li.interest_group := p_interest_group;
        END IF;

        -- 6. Do the update
        UPDATE cont_line_item
           SET name = lrec_li.name
              ,interest_type = p_interest_type
              ,rate_days = lrec_li.rate_days
              ,interest_from_date = p_interest_from_date
              ,interest_to_date = lrec_li.interest_to_date
              ,interest_base_amount = p_base_amt
              ,interest_line_item_key = p_parent_line_item_key
              ,interest_group = lrec_li.interest_group
              ,base_rate = p_base_rate
              ,interest_num_days = ln_number_of_days
              ,rate_offset = p_rate_offset
              ,gross_rate = lrec_li.gross_rate
              ,pricing_value = lrec_li.pricing_value
              ,compounding_period = p_compounding_period
              ,last_updated_by = p_user
              ,comments = p_comment
        WHERE object_id = p_object_id
        AND line_item_key = lv2_line_item_key;

        -- 7. Check if period between interest_from_date and interest_to_date is greater than compounding_period
        --    Insert another interest line item if so.
        IF ln_date_diff > nvl(p_compounding_period,ln_date_diff+1) THEN

            lv2_interest_group := InsInterestLineItem(p_object_id,
                                                      p_transaction_key,
                                                      p_li_template_id,
                                                      lrec_li.interest_to_date,
                                                      p_interest_to_date,
                                                      p_base_amt+lrec_li.pricing_value,
                                                      p_base_rate,
                                                      lv2_line_item_key,
                                                      p_interest_type,
                                                      p_name,
                                                      p_rate_offset,
                                                      p_compounding_period,
                                                      lrec_li.interest_group,
                                                      p_number_of_days,
                                                      p_user,
                                                      p_line_item_type,
                                                      p_comment,
                                                      p_sort_order,
                                                      p_creation_method => ecdp_revn_ft_constants.c_mtd_auto_gen);

        END IF;

        RETURN lrec_li.interest_group;

    END InsInterestLineItem;

    -----------------------------------------------------------------------
    -- Remove interest line items from table, and then generates line
    -- items from scratch distribution from the quantity line item.
    ----+----------------------------------+-------------------------------
    FUNCTION GenInterestLineItemSet_I (
        p_object_id                        VARCHAR2,
        p_transaction_key                  VARCHAR2,
        p_line_item_key      VARCHAR2,
        p_interest_from_date DATE,
        p_interest_to_date   DATE,
        p_base_amt           NUMBER, -- in pricing currency
        p_base_rate          NUMBER,
        p_interest_type      VARCHAR2,
        p_name               VARCHAR2,
        p_rate_offset        NUMBER,
        p_compounding_period NUMBER,
        p_interest_group     VARCHAR2,
        p_number_of_days     NUMBER,
        p_user               VARCHAR2,
        p_line_item_type     VARCHAR2 DEFAULT NULL,
        p_comment            VARCHAR2 DEFAULT NULL,
        p_sort_order         NUMBER DEFAULT NULL,
        p_creation_method    ecdp_revn_ft_constants.t_c_mtd DEFAULT ecdp_revn_ft_constants.c_mtd_manual
    )
    RETURN cont_line_item.interest_group%TYPE
    --</EC-DOC>
    IS

      CURSOR c_li(cp_interest_group VARCHAR2, cp_document_key VARCHAR2) IS
        SELECT line_item_key id
          FROM cont_line_item
         WHERE document_key = cp_document_key
           AND interest_group = cp_interest_group
           AND line_item_based_type = 'INTEREST'
         ORDER BY line_item_key;

      TYPE t_li_rec IS RECORD (
          old_line_item_id cont_line_item.line_item_key%TYPE
         ,new_line_item_id cont_line_item.line_item_key%TYPE
      );
      TYPE t_li_table IS TABLE OF t_li_rec;
      ltab_li_mapping t_li_table := t_li_table();

      lv2_li_templ_object_id VARCHAR2(32);
      lv2_new_interest_group cont_line_item.interest_group%TYPE;
      lv2_document_key cont_document.document_key%TYPE;
      ln_cnt NUMBER := 1;

      invalid_timespan EXCEPTION;
      missing_from_date EXCEPTION;
      missing_base_amt EXCEPTION;
      missing_base_rate EXCEPTION;

    BEGIN

        IF p_interest_from_date IS NULL THEN
            RAISE missing_from_date;
        END IF;

        IF p_interest_to_date < p_interest_from_date THEN
            RAISE invalid_timespan;
        END IF;

        IF p_base_amt IS NULL THEN
            RAISE missing_base_amt;
        END IF;

        IF p_base_rate IS NULL THEN
            RAISE missing_base_rate;
        END IF;

        IF p_interest_to_date IS NULL THEN
           RETURN NULL;
        END IF;

        IF p_line_item_key IS NOT NULL THEN
            lv2_li_templ_object_id := ec_cont_line_item.line_item_template_id(p_line_item_key);
        END IF;


        lv2_document_key := ec_cont_transaction.document_key(p_transaction_key);

        IF p_interest_group IS NOT NULL THEN
            -- store all line_item_ids from this interest group because any rec comments must be copied after the regeneration
            FOR Li IN c_li(p_interest_group, lv2_document_key) LOOP
                ltab_li_mapping.EXTEND;
                ltab_li_mapping(ltab_li_mapping.LAST).old_line_item_id := Li.id;
            END LOOP;

            IF ltab_li_mapping.count > 0 THEN
                -- remove all "child" line items
                FOR idx IN ltab_li_mapping.first..ltab_li_mapping.last LOOP
                    DelLineItem(p_object_id, ltab_li_mapping(idx).old_line_item_id);
                END LOOP;
            END IF;

        END IF;

        -- generate from scratch
        lv2_new_interest_group := InsInterestLineItem(p_object_id,
                                                      p_transaction_key,
                                                      lv2_li_templ_object_id,
                                                      p_interest_from_date,
                                                      p_interest_to_date,
                                                      p_base_amt,
                                                      p_base_rate,
                                                      NULL,
                                                      p_interest_type,
                                                      p_name,
                                                      p_rate_offset,
                                                      p_compounding_period,
                                                      NULL,
                                                      p_number_of_days,
                                                      p_user,
                                                      nvl(p_line_item_type,'INTEREST'),
                                                      p_comment,
                                                      p_sort_order,
                                                      p_creation_method
                                                      );

        -- finally, try to copy any rec comments
        IF p_interest_group IS NOT NULL THEN
            FOR LiNew IN c_li(lv2_new_interest_group, lv2_document_key) LOOP
                IF ln_cnt > ltab_li_mapping.COUNT THEN
                    EXIT;
                END IF;
                ltab_li_mapping(ln_cnt).new_line_item_id := LiNew.id;
                ln_cnt := ln_cnt+1;
            END LOOP;

            FOR i IN 1..ltab_li_mapping.COUNT LOOP
                IF ltab_li_mapping(i).new_line_item_id IS NULL OR ltab_li_mapping(i).old_line_item_id IS NULL THEN
                    EXIT;
                END IF;

                UPDATE cont_document_comment
                   SET comment_key = REPLACE(comment_key,ltab_li_mapping(i).old_line_item_id,ltab_li_mapping(i).new_line_item_id)
                      ,last_updated_by = p_user
                WHERE object_id = p_object_id
                AND document_key = lv2_document_key
                AND INSTR(comment_key,ltab_li_mapping(i).old_line_item_id) = 1;
            END LOOP;
        END IF;

    ecdp_transaction.UpdPercentageLineItem(p_transaction_key, p_user);

    RETURN lv2_new_interest_group;
    EXCEPTION

        WHEN invalid_timespan THEN

            RAISE_APPLICATION_ERROR(-20000,'Date To cannot be less than Date From.');

        WHEN missing_from_date THEN

            RAISE_APPLICATION_ERROR(-20000,'Interest From Date is missing.');

        WHEN missing_base_amt THEN

            RAISE_APPLICATION_ERROR(-20000,'Base Amount cannot be empty.');

        WHEN missing_base_rate THEN

            RAISE_APPLICATION_ERROR(-20000,'Base Rate cannot be empty.');

    END GenInterestLineItemSet_I;


    -----------------------------------------------------------------------
    -- Gets quantity line item key in given transaction. This function
    -- returns the first quantity line item from database.
    --
    -- Note:
    --     Only one quantity line item is allowed per transaction.
    --
    -- Paramters:
    --     p_transaction_key: transaction key.
    ----+----------------------------------+-------------------------------
    FUNCTION get_first_qty_li_key(
        p_transaction_key                  cont_transaction.transaction_key%TYPE
        )
    RETURN cont_line_item.line_item_key%TYPE
    IS
        CURSOR c_qty_line_item_key(cp_transaction_key cont_transaction.transaction_key%TYPE) IS
            SELECT line_item_key
            FROM cont_line_item
            WHERE transaction_key = cp_transaction_key
                AND line_item_based_type = ecdp_revn_ft_constants.li_btype_quantity
            ORDER BY line_item_key;

        lv2_key cont_line_item.line_item_key%TYPE;
    BEGIN
        FOR ic IN c_qty_line_item_key(p_transaction_key) LOOP
            lv2_key := ic.line_item_key;
            EXIT;
        END LOOP;

        RETURN lv2_key;
    END;

    -----------------------------------------------------------------------
    -- Returns company level distribution info on given line item
    ----+----------------------------------+-------------------------------
    PROCEDURE get_company_dists(
        p_result_collection               IN OUT NOCOPY t_table_li_company_dist
       ,p_transaction_key                 VARCHAR2
       ,p_line_item_key                   VARCHAR2
       ,p_dist_id                         VARCHAR2
       )
    IS
    BEGIN
        IF p_result_collection IS NULL THEN
            RETURN;
        END IF;

        OPEN c_company_dists(p_transaction_key, p_line_item_key, p_dist_id);
        FETCH c_company_dists BULK COLLECT INTO p_result_collection;
        CLOSE c_company_dists;
    END;

    -----------------------------------------------------------------------
    -- Returns profit center level distribution info on given line item
    ----+----------------------------------+-------------------------------
    PROCEDURE get_pc_dists(
        p_result_collection               IN OUT NOCOPY t_table_li_pc_dist
       ,p_transaction_key                 VARCHAR2
       ,p_line_item_key                   VARCHAR2
       )
    IS
    BEGIN
        IF p_result_collection IS NULL THEN
            RETURN;
        END IF;

        OPEN c_pc_dists(p_transaction_key, p_line_item_key);
        FETCH c_pc_dists BULK COLLECT INTO p_result_collection;
        CLOSE c_pc_dists;
    END;

    -----------------------------------------------------------------------
    -- Removes all distributions from given line item.
    ----+----------------------------------+-------------------------------
    PROCEDURE remove_dist_p(
        p_line_item_key                    cont_line_item.line_item_key%TYPE
        )
    IS
    BEGIN
        DELETE FROM cont_line_item_dist
        WHERE line_item_key = p_line_item_key;

        DELETE FROM cont_li_dist_company
        WHERE line_item_key = p_line_item_key;
    END;


    -----------------------------------------------------------------------
    -- Generates line item distributions from split key configuration.
    ----+----------------------------------+-------------------------------
    PROCEDURE gen_dist_party_f_sk_p(p_line_item_key VARCHAR2,
                      p_customer_id   VARCHAR2,
                      p_user          VARCHAR2)

    --</EC-DOC>
    IS


    lv2_contract_id                VARCHAR2(32);
    lv2_document_key               VARCHAR2(32);
    lv_transaction_key             VARCHAR2(32);
    lv2_transaction_template_id    VARCHAR2(32);
    lv2_split_key_id               VARCHAR2(32);
    lv2_dist_object_id             VARCHAR2(32);
    lv2_uom_code                   VARCHAR2(32);
    ld_daytime                     DATE;
    lv2_alloc_stream_item_id       VARCHAR2(32);
    lv2_child_split_key_id         VARCHAR2(32);
    ld_transaction_date            DATE;
    lv2_fin_code contract_version.financial_code%type;
    lv2_doc_customer_id            VARCHAR2(32);

    lv2_stream_item_id          VARCHAR2(32);
    lv2_use_si_ind              VARCHAR2(32);
    lv2_node_id                 VARCHAR2(32);
    lv2_profit_centre_id        VARCHAR2(32);
    lv2_company_stream_item_id      VARCHAR2(32);
    lrec_ttv                    transaction_tmpl_version%ROWTYPE;
    lrec_sks                    split_key_setup%ROWTYPE;


    BEGIN


    lv2_contract_id                       := ec_cont_line_item.object_id(p_line_item_key);
    ld_daytime                            := ec_cont_line_item.daytime(p_line_item_key);
    lv2_document_key                      := ec_cont_line_item.document_key(p_line_item_key);
    lv2_uom_code                          := ec_transaction_tmpl_version.uom1_code(lv2_transaction_template_id,ld_daytime);
    lv2_fin_code                          := ec_contract_version.financial_code(lv2_contract_id,ld_daytime,'<=');
    lv_transaction_key                    := ec_cont_line_item.transaction_key(p_line_item_key);
    ld_transaction_date                   := ec_cont_transaction.transaction_date(lv_transaction_key);
    lv2_transaction_template_id           := ec_cont_transaction.trans_template_id(lv_transaction_key);
    lrec_ttv                              := ec_transaction_tmpl_version.row_by_pk(lv2_transaction_template_id, ld_daytime, '<=');
    lv2_split_key_id                      := ec_transaction_tmpl_version.split_key_id(lv2_transaction_template_id, ld_daytime, '<=');
    lv2_dist_object_id                    := ec_stream_item_version.field_id(ec_cont_transaction.stream_item_id(lv_transaction_key), ld_daytime, '<=');
    lv2_doc_customer_id                   := NVL(p_customer_id, ecdp_contract_setup.GetDocCustomerId(lv2_document_key));

    lv2_use_si_ind                        := lrec_ttv.use_stream_items_ind;

          FOR LIVFCur IN gc_split_key_setup(lv2_split_key_id,ld_daytime) LOOP

              lv2_alloc_stream_item_id := LIVFCur.source_member_id;
              lrec_sks:= ec_split_key_setup.row_by_pk(lv2_split_key_id,LIVFCur.id, ld_daytime, '<=');
              lv2_child_split_key_id := lrec_sks.child_split_key_id;

               IF lv2_use_si_ind = 'N' THEN
                   lv2_profit_centre_id := lrec_sks.profit_centre_id;
                   lv2_node_id := NULL;
                   lv2_dist_object_id := lv2_profit_centre_id;
                   lv2_stream_item_id := lv2_profit_centre_id;

                 ELSE
                    lv2_stream_item_id := LIVFCur.id;
                    select DECODE(ec_stream_item_version.value_point(lv2_stream_item_id, ld_daytime, '<='),'TO_NODE'
                        ,ec_strm_version.to_node_id(ec_stream_item.stream_id(lv2_stream_item_id), ld_daytime, '<=')
                        ,'FROM_NODE'
                        ,ec_strm_version.from_node_id(ec_stream_item.stream_id(lv2_stream_item_id), ld_daytime, '<=')
                        ,NULL) INTO lv2_node_id FROM cont_line_item WHERE line_item_key = p_line_item_key;
                     lv2_dist_object_id := ec_stream_item_version.field_id(lv2_stream_item_id,ld_daytime, '<='); -- Field_id

                  END IF;

              -- not yet, check if valid field
              INSERT INTO cont_line_item_dist
                  (object_id,
                  line_item_key,
                  document_key,
                  transaction_key,
                  STREAM_ITEM_ID,
                  DIST_ID,
                  NODE_ID,
                  name,
                  description,
                  value_adjustment,
                  PRICE_CONCEPT_CODE ,
                  PRICE_ELEMENT_CODE  ,
                  LINE_ITEM_TYPE  ,
                  STIM_VALUE_CATEGORY_CODE  ,
                  SORT_ORDER  ,
                  REPORT_CATEGORY_CODE  ,
                  MOVE_QTY_TO_VO_IND,
                  CONTRIBUTION_FACTOR,
                  UOM1_CODE  ,
                  UOM2_CODE  ,
                  UOM3_CODE  ,
                  UOM4_CODE  ,
                  SPLIT_SHARE,
                  ALLOC_STREAM_ITEM_ID,
                  DAYTIME,
                  LINE_ITEM_BASED_TYPE,
                  VAT_CODE,
                  VAT_RATE,
                  JV_BILLABLE,
                  comments,
                  created_by,
                  created_date,
                  record_status,
                  profit_centre_id
              )
              SELECT
                  object_id,
                  line_item_key,
                  document_key,
                  transaction_key,
                  lv2_stream_item_id, -- take to_object from split key
                  lv2_dist_object_id,
                  lv2_node_id,
                  name,
                  description,
                  value_adjustment,
                  PRICE_CONCEPT_CODE ,
                  PRICE_ELEMENT_CODE  ,
                  LINE_ITEM_TYPE  ,
                  STIM_VALUE_CATEGORY_CODE  ,
                  SORT_ORDER  ,
                  REPORT_CATEGORY_CODE  ,
                  MOVE_QTY_TO_VO_IND,
                  CONTRIBUTION_FACTOR,
                  UOM1_CODE  ,
                  UOM2_CODE  ,
                  UOM3_CODE  ,
                  UOM4_CODE  ,
                  Ecdp_split_key.GetSplitShareMth(lv2_split_key_id,LIVFCur.id, NVL(ld_transaction_date, ld_daytime), lv2_uom_code, 'SP_SPLIT_KEY'), -- pick share
                  lv2_alloc_stream_item_id,
                  ld_daytime,
                  LINE_ITEM_BASED_TYPE,
                  VAT_CODE,
                  VAT_RATE,
                  decode(ec_contract_version.bank_details_level_code(lv2_contract_id, ld_daytime, '<='),'JV_BILLABLE','JV_BILLABLE',null),
                  LIVFCur.comments_mth,
                  created_by,
                  created_date,
                  'P',
                  lv2_profit_centre_id
              FROM cont_line_item
              WHERE line_item_key = p_line_item_key;

              IF (ec_cont_transaction.dist_split_type(lv_transaction_key) = 'SOURCE_SPLIT' AND ld_transaction_date IS NOT NULL) THEN
                  Ecdp_Transaction.UpdTransSourceSplitShare(lv_transaction_key
                            ,ec_cont_transaction_qty.net_qty1(lv_transaction_key)
                            ,ec_cont_transaction_qty.uom1_code(lv_transaction_key)
                            ,ld_transaction_date);
              END IF;

              FOR SplitCur IN gc_split_key_setup_company(lv2_child_split_key_id, lv2_contract_id,lv2_doc_customer_id, lv2_fin_code, ld_daytime) LOOP



                      INSERT INTO cont_li_dist_company (
                          object_id
                          ,line_item_key
                          ,daytime
                          ,stream_item_id
                          ,dist_id
                          ,document_key
                          ,transaction_key
                          ,node_id
                          ,name
                          ,description
                          ,comments
                          ,vendor_id
                          ,vendor_share
                          ,customer_id
                          ,customer_share
                          ,split_share
                          ,sort_order
                          ,report_category_code
                          ,value_adjustment
                          ,uom1_code
                          ,uom2_code
                          ,uom3_code
                          ,uom4_code
                          ,price_concept_code
                          ,price_element_code
                          ,stim_value_category_code
                          ,line_item_type
                          ,line_item_based_type
                          ,company_stream_item_id
                          ,move_qty_to_vo_ind
                          ,contribution_factor
                          ,profit_centre_id
                          )
                      SELECT
                          d.Object_id,
                          d.Line_item_key,
                          d.Daytime,
                          d.stream_item_id,
                          d.dist_id,
                          d.document_key,
                          d.transaction_key,
                          d.node_id,
                          '' ,
                          '' ,
                          SplitCur.comments_mth,
                          SplitCur.vendor_id,
                          SplitCur.vendor_share,
                          SplitCur.customer_id,
                          SplitCur.customer_share,
                          SplitCur.vendor_share * SplitCur.customer_share,
                          d.sort_order,
                          d.report_category_code,
                          d.value_adjustment,
                          d.uom1_code,
                          d.uom2_code,
                          d.uom3_code,
                          d.uom4_code,
                          d.price_concept_code,
                          d.price_element_code,
                          d.stim_value_category_code,
                          d.line_item_type,
                          d.line_item_based_type,
                          SplitCur.split_member_id,
                          d.move_qty_to_vo_ind,
                          d.contribution_factor,
                          d.profit_centre_id
                      FROM
                          cont_line_item_dist d
                      WHERE line_item_key = p_line_item_key
                        AND d.dist_id = lv2_dist_object_id;


              END LOOP;

          END LOOP;

    END;


    -----------------------------------------------------------------------
    -- Refreshes line item distribution from system configuration.
    --
    -- Parameters:
    --     p_overwrite_customer_id: The customer to use on company dist
    --         record. This is optional, if not given, the configured one
    --         on document setup will be used.
    ----+----------------------------------+-------------------------------
    PROCEDURE gen_dist_party_f_conf_p(
        p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
       ,p_transaction_tmpl_version_rec     IN OUT NOCOPY transaction_tmpl_version%ROWTYPE
       ,p_overwrite_customer_id            IN VARCHAR2
       ,p_user                             IN VARCHAR2
       )
    IS
    BEGIN
        remove_dist_p(p_line_item_rec.line_item_key);

        -- If distribution configuration is present then proceed with standard logic to persist distriubtion
        -- Else, distribution is done after quantities and other information has been retrieved from I/F (ECPD-14958)
        IF NOT ecdp_transaction.IsReducedConfig(
            NULL, NULL, p_transaction_tmpl_version_rec.object_id,
            p_line_item_rec.transaction_key, p_line_item_rec.daytime) THEN
            gen_dist_party_f_sk_p(p_line_item_rec.line_item_key,p_overwrite_customer_id,p_user);
        ELSE
            -- Distribution of quantity line items are handled outside of this function.
            -- Non-qty line items added on reduced config transaction need distribution set
            -- by using the code below.
            IF p_line_item_rec.line_item_based_type <> ecdp_revn_ft_constants.li_btype_quantity THEN
                IF UPPER(p_transaction_tmpl_version_rec.use_stream_items_ind) = 'Y' THEN
                    gen_dist_party_f_conf_field(
                        p_line_item_rec.line_item_key,NULL,p_user, p_transaction_tmpl_version_rec.uom1_code);
                ELSE
                    gen_dist_party_f_conf_pc(
                        p_line_item_rec.line_item_key,NULL,p_user, p_transaction_tmpl_version_rec.uom1_code);
                END IF;
            END IF;
        END IF;
    END;


    -----------------------------------------------------------------------
    -- Refreshes line item distribution from system configuration.
    --
    -- Parameters:
    --     p_overwrite_customer_id: The customer to use on company dist
    --         record. This is optional, if not given, the configured one
    --         on document setup will be used.
    ----+----------------------------------+-------------------------------
    PROCEDURE gen_dist_f_conf_p(
        p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
       ,p_transaction_tmpl_version_rec     IN OUT NOCOPY transaction_tmpl_version%ROWTYPE
       ,p_overwrite_customer_id            IN VARCHAR2
       ,p_user                             IN VARCHAR2
       )
    IS
    BEGIN
        gen_dist_party_f_conf_p(
            p_line_item_rec, p_transaction_tmpl_version_rec, p_overwrite_customer_id, p_user);

        IF p_line_item_rec.line_item_based_type <> ecdp_revn_ft_constants.li_btype_quantity THEN
            FOR i IN gc_transaction_qty_line_item(p_line_item_rec.transaction_key) LOOP
                UPDATE cont_line_item_dist f
                SET f.split_share      = i.split_share,
                    f.split_share_qty2 = i.split_share_qty2,
                    f.split_share_qty3 = i.split_share_qty3,
                    f.split_share_qty4 = i.split_share_qty4
                WHERE f.line_item_key = p_line_item_rec.line_item_key
                    AND f.dist_id = i.dist_id;
            END LOOP;

            FOR i IN gc_transaction_qty_li_dist(p_line_item_rec.transaction_key) LOOP
                UPDATE cont_li_dist_company f
                SET f.split_share      = i.split_share,
                    f.vendor_share      = i.vendor_share,
                    f.vendor_share_qty2 = i.vendor_share_qty2,
                    f.vendor_share_qty3 = i.vendor_share_qty3,
                    f.vendor_share_qty4 = i.vendor_share_qty4,
                    f.customer_share = i.customer_share
                WHERE f.line_item_key = p_line_item_rec.line_item_key
                    AND f.vendor_id = i.vendor_id
                    AND f.dist_id = i.dist_id;
            END LOOP;
        END IF;

        -- To calculate the different attributes in CONT_LINE_ITEM
        IF p_line_item_rec.line_item_based_type <> 'FREE_UNIT' THEN
            UPDATE cont_line_item
            SET pricing_value = pricing_value, last_updated_by = 'SYSTEM'
            WHERE line_item_key = p_line_item_rec.line_item_key;
        ELSE
            UPDATE cont_line_item
            SET free_unit_qty = free_unit_qty, last_updated_by = 'SYSTEM'
            WHERE line_item_key = p_line_item_rec.line_item_key;
        END IF;
    END;

    -----------------------------------------------------------------------
    -- Refreshes line item distribution from system configuration.
    ----+----------------------------------+-------------------------------
    PROCEDURE gen_dist_f_conf_p(
        p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
       ,p_user                             IN VARCHAR2
       )
    IS
        l_transaction_tmpl_id              transaction_tmpl_version.object_id%TYPE;
        l_transaction_tmpl_version_rec     transaction_tmpl_version%ROWTYPE;
    BEGIN
        l_transaction_tmpl_id :=
            ec_transaction_template.object_id_by_uk(p_line_item_rec.transaction_key);
        l_transaction_tmpl_version_rec :=
            ec_transaction_tmpl_version.row_by_pk(l_transaction_tmpl_id, p_line_item_rec.daytime, '<=');
        gen_dist_f_conf_p(
            p_line_item_rec, l_transaction_tmpl_version_rec, NULL, p_user);
    END;


    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE gen_dist_party_f_ifac_period_p(
        p_context                          IN OUT NOCOPY t_revn_doc_op_context
       ,p_line_item_key                    cont_line_item.line_item_key%TYPE
       ,p_transaction_rec                  IN OUT NOCOPY cont_transaction%ROWTYPE
       ,p_transaction_version_rec          IN OUT NOCOPY transaction_tmpl_version%ROWTYPE
       ,p_ifac_li_level_idx                NUMBER
       ,p_ifac_pc_idxes                    IN OUT NOCOPY t_table_number
    )
    IS
        l_ifac_all                         t_table_ifac_sales_qty;
        l_ifac_li                          t_ifac_sales_qty;
    BEGIN
        l_ifac_all := p_context.ifac_period;
        l_ifac_li := l_ifac_all(p_ifac_li_level_idx);

        -- generates distribution for reduced config
        IF ecdp_transaction.IsReducedConfig(
            NULL,
            NULL,
            p_transaction_rec.trans_template_id,
            p_transaction_rec.transaction_key,
            p_transaction_rec.supply_from_date) THEN

            -- Deletes existing distributions
            IF UPPER(p_transaction_version_rec.use_stream_items_ind) = 'N' THEN
                remove_dist_p(p_line_item_key);
            END IF;

            IF UPPER(p_transaction_version_rec.use_stream_items_ind) = 'Y' THEN
                gen_dist_party_f_conf_field(
                    p_line_item_key, NULL, p_context.user_id, l_ifac_li.uom1_code);
            ELSE
                FOR idx_pc IN p_ifac_pc_idxes.first .. p_ifac_pc_idxes.last LOOP
                    gen_dist_party_f_given(
                        p_line_item_key,
                        NULL,
                        p_context.user_id,
                        l_ifac_li.uom1_code,
                        l_ifac_all(p_ifac_pc_idxes(idx_pc)).PROFIT_CENTER_ID,
                        l_ifac_all(p_ifac_pc_idxes(idx_pc)).PERIOD_START_DATE);
                END LOOP;
            END IF;
        END IF;
    END;



    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE gen_dist_party_f_ifac_cargo_p(
        p_context                          IN OUT NOCOPY t_revn_doc_op_context
       ,p_line_item_key                    cont_line_item.line_item_key%TYPE
       ,p_transaction_rec                  IN OUT NOCOPY cont_transaction%ROWTYPE
       ,p_transaction_version_rec          IN OUT NOCOPY transaction_tmpl_version%ROWTYPE
       ,p_ifac_li_level_idx                NUMBER
       ,p_ifac_pc_idxes                    IN OUT NOCOPY t_table_number
    )
    IS
        l_ifac_all                         t_table_ifac_cargo_value;
        l_ifac_li                          t_ifac_cargo_value;
    BEGIN
        l_ifac_all := p_context.ifac_cargo;
        l_ifac_li := l_ifac_all(p_ifac_li_level_idx);

        -- generates distribution for reduced config
        IF ecdp_transaction.IsReducedConfig(
            NULL,
            NULL,
            p_transaction_rec.trans_template_id,
            p_transaction_rec.transaction_key,
            p_transaction_rec.daytime) THEN

            -- Deletes existing distributions
            IF UPPER(p_transaction_version_rec.use_stream_items_ind) = 'N' THEN
                remove_dist_p(p_line_item_key);
            END IF;

            IF UPPER(p_transaction_version_rec.use_stream_items_ind) = 'Y' THEN
                gen_dist_party_f_conf_field(
                    p_line_item_key, NULL, p_context.user_id, l_ifac_li.uom1_code);
            ELSE
                FOR idx_pc IN p_ifac_pc_idxes.first .. p_ifac_pc_idxes.last LOOP
                    gen_dist_party_f_given(
                        p_line_item_key,
                        NULL,
                        p_context.user_id,
                        l_ifac_li.uom1_code,
                        l_ifac_all(p_ifac_pc_idxes(idx_pc)).PROFIT_CENTER_ID,
                        l_ifac_all(p_ifac_pc_idxes(idx_pc)).POINT_OF_SALE_DATE);
                END LOOP;
            END IF;
        END IF;
    END;


    -----------------------------------------------------------------------
    -- Gets a boolean value indicating if all split source value on given
    -- ifac records are null or zero.
    --
    -- Parameters:
    --     p_ifac: The ifac record collection to check.
    --     p_range: The collection of indexes of p_ifac items to check.
    --         If null is given, all items are checked.
    ----+----------------------------------+-------------------------------
    FUNCTION get_if_split_src_zero_p(
        p_ifac                             IN OUT NOCOPY t_table_ifac_sales_qty
       ,p_range                            IN OUT NOCOPY t_table_number
       )
    RETURN BOOLEAN
    IS
        l_range                            t_table_number;
    BEGIN
        IF p_ifac IS NULL OR p_ifac.count = 0 THEN
            RETURN TRUE;
        END IF;

        l_range := p_range;
        IF l_range IS NULL THEN
            l_range := ecdp_revn_common.GetNumbers(p_ifac.count);
        END IF;

        IF l_range.count = 0 THEN
            RETURN TRUE;
        END IF;

        FOR idx IN l_range.first..l_range.last LOOP
            IF NVL(p_ifac(l_range(idx)).get_split_source_value, 0) <> 0 THEN
                RETURN FALSE;
            END IF;
        END LOOP;

        RETURN TRUE;
    END;

    -----------------------------------------------------------------------
    -- Gets a boolean value indicating if all split source value on given
    -- ifac records are null or zero.
    --
    -- Parameters:
    --     p_ifac: The ifac record collection to check.
    --     p_range: The collection of indexes of p_ifac items to check.
    --         If null is given, all items are checked.
    ----+----------------------------------+-------------------------------
    FUNCTION get_if_split_src_zero_p(
        p_ifac                             IN OUT NOCOPY t_table_ifac_cargo_value
       ,p_range                            IN OUT NOCOPY t_table_number
       )
    RETURN BOOLEAN
    IS
        l_range                            t_table_number;
    BEGIN
        IF p_ifac IS NULL OR p_ifac.count = 0 THEN
            RETURN TRUE;
        END IF;

        l_range := p_range;
        IF l_range IS NULL THEN
            l_range := ecdp_revn_common.GetNumbers(p_ifac.count);
        END IF;

        IF l_range.count = 0 THEN
            RETURN TRUE;
        END IF;

        FOR idx IN l_range.first..l_range.last LOOP
            IF NVL(p_ifac(l_range(idx)).get_split_source_value, 0) <> 0 THEN
                RETURN FALSE;
            END IF;
        END LOOP;

        RETURN TRUE;
    END;



    FUNCTION get_company_split_share_p(
        p_vendor_share                     NUMBER
       ,p_company_share                    NUMBER
       )
    RETURN NUMBER
    IS
    BEGIN
        RETURN NVL(p_vendor_share, 0) * NVL(p_company_share, 1);
    END;


    PROCEDURE set_split_source_value_p(
        p_line_item_company_dist_rec       IN OUT NOCOPY cont_li_dist_company%ROWTYPE
       ,p_value                            NUMBER
       )
    IS
    BEGIN
        CASE p_line_item_company_dist_rec.line_item_based_type
        WHEN 'QTY' THEN
            p_line_item_company_dist_rec.qty1 := p_value;
        WHEN 'FREE_UNIT' THEN
            p_line_item_company_dist_rec.qty1 := p_value;
        WHEN 'FREE_UNIT_PRICE_OBJECT' THEN
            p_line_item_company_dist_rec.qty1 := p_value;
        WHEN 'FIXED_VALUE' THEN
            p_line_item_company_dist_rec.pricing_value := p_value;
        WHEN 'PERCENTAGE_ALL' THEN
            NULL;
        WHEN 'PERCENTAGE_QTY' THEN
            NULL;
        WHEN 'PERCENTAGE_MANUAL' THEN
            NULL;
        WHEN 'INTEREST' THEN
            NULL;
        ELSE
            p_line_item_company_dist_rec.qty1 := p_value;
        END CASE;
    END;

    PROCEDURE set_split_source_value_p(
        p_line_item_pc_dist_rec            IN OUT NOCOPY cont_line_item_dist%ROWTYPE
       ,p_value                            NUMBER
       )
    IS
    BEGIN
        CASE p_line_item_pc_dist_rec.line_item_based_type
        WHEN 'QTY' THEN
            p_line_item_pc_dist_rec.qty1 := p_value;
        WHEN 'FREE_UNIT' THEN
            p_line_item_pc_dist_rec.qty1 := p_value;
        WHEN 'FREE_UNIT_PRICE_OBJECT' THEN
            p_line_item_pc_dist_rec.qty1 := p_value;
        WHEN 'FIXED_VALUE' THEN
            p_line_item_pc_dist_rec.pricing_value := p_value;
        WHEN 'PERCENTAGE_ALL' THEN
            NULL;
        WHEN 'PERCENTAGE_QTY' THEN
            NULL;
        WHEN 'PERCENTAGE_MANUAL' THEN
            NULL;
        WHEN 'INTEREST' THEN
            NULL;
        ELSE
            p_line_item_pc_dist_rec.qty1 := p_value;
        END CASE;
    END;

    -----------------------------------------------------------------------
    -- Sets company level distribution values on a line item from given
    -- ifac data.
    --
    -- Parameters:
    --     p_line_item_company_dist_rec: The company level distribution
    --         record where updates will be applied.
    --     p_transaction_rec: The record of the transaction which owns
    --         the processing line item.
    --     p_ifac: All ifac records.
    --     p_ifac_pc_level_idx: The index of profit center level ifac record
    --         to process.
    --     p_ifac_vend_level_idx: The index of venfor level ifac record to
    --         process.
    --     p_ifac_pc_vendor_level_idxes: The indexes of all vendor level ifac
    --         records under given profit center level ifac.
    --
    -- Parameters to modify:
    --    p_line_item_company_dist_rec
    ----+----------------------------------+-------------------------------
    PROCEDURE set_li_dist_comp_from_ifac_p(
        p_line_item_company_dist_rec       IN OUT NOCOPY cont_li_dist_company%ROWTYPE
       ,p_line_item_dist_rec               IN OUT NOCOPY cont_line_item_dist%ROWTYPE
       ,p_transaction_rec                  IN OUT NOCOPY cont_transaction%ROWTYPE
       ,p_ifac                             IN OUT NOCOPY t_table_ifac_sales_qty
       ,p_ifac_pc_level_idx                NUMBER
       ,p_ifac_vend_level_idx              NUMBER
       ,p_ifac_pc_vendor_level_idxes       IN OUT NOCOPY t_table_number
       )
    IS
        l_company_qty1_all_zero	           BOOLEAN;
        l_share                            NUMBER;
        l_ifac_vendor_level                t_ifac_sales_qty;
        l_ifac_pc_level                    t_ifac_sales_qty;
        l_vendor_split_source_value        NUMBER;
        l_pc_split_source_value            NUMBER;
    BEGIN
        l_company_qty1_all_zero := get_if_split_src_zero_p(p_ifac, p_ifac_pc_vendor_level_idxes);
        l_ifac_vendor_level := p_ifac(p_ifac_vend_level_idx);
        l_ifac_pc_level := p_ifac(p_ifac_pc_level_idx);
        l_vendor_split_source_value := nvl(l_ifac_vendor_level.get_split_source_value, 0);
        l_pc_split_source_value := nvl(l_ifac_pc_level.get_split_source_value, 0);

        -- Share is determined from table cont_line_item_dist as qty1-qty4
        -- might have individual shares (ECPD-11824)
        l_share := CASE
            WHEN l_vendor_split_source_value = 0 AND l_pc_split_source_value = 0 THEN
                0
            WHEN l_pc_split_source_value = 0 THEN
                0
            ELSE
                l_vendor_split_source_value / l_pc_split_source_value
            END;

        p_line_item_company_dist_rec.vendor_share :=
            CASE
                WHEN l_company_qty1_all_zero and p_ifac_pc_vendor_level_idxes.count = 1 THEN
                    1
                WHEN l_company_qty1_all_zero and p_ifac_pc_vendor_level_idxes.count > 1 THEN
                    NVL(ecdp_transaction_qty.GetCompanyShare(
                            p_transaction_rec.trans_template_id,
                            p_transaction_rec.daytime,
                            l_ifac_pc_level.profit_center_id,
                            ec_company.company_id(l_ifac_vendor_level.Vendor_Id)),
                        EC_CONTRACT_PARTY_SHARE.party_share(
                            p_transaction_rec.object_id,
                            l_ifac_vendor_level.Vendor_Id,
                            'VENDOR',
                            p_transaction_rec.daytime, '<=')/100)
                ELSE
                    l_share
            END;

        p_line_item_company_dist_rec.qty1 := l_ifac_vendor_level.qty1;
        p_line_item_company_dist_rec.qty2 := l_ifac_vendor_level.qty2;
        p_line_item_company_dist_rec.qty3 := l_ifac_vendor_level.qty3;
        p_line_item_company_dist_rec.qty4 := l_ifac_vendor_level.qty4;

        set_split_source_value_p(p_line_item_company_dist_rec, l_vendor_split_source_value);
        p_line_item_company_dist_rec.split_value := l_vendor_split_source_value;
        p_line_item_company_dist_rec.split_share := get_company_split_share_p(
            p_line_item_company_dist_rec.vendor_share, p_line_item_company_dist_rec.customer_share);

        p_line_item_company_dist_rec.vendor_share_qty2 := ecdp_revn_common.get_ratio(
            p_line_item_company_dist_rec.qty2, p_line_item_dist_rec.qty2);
        p_line_item_company_dist_rec.vendor_share_qty3 := ecdp_revn_common.get_ratio(
            p_line_item_company_dist_rec.qty3, p_line_item_dist_rec.qty3);
        p_line_item_company_dist_rec.vendor_share_qty4 := ecdp_revn_common.get_ratio(
            p_line_item_company_dist_rec.qty4, p_line_item_dist_rec.qty4);
    END;


   -----------------------------------------------------------------------
    -- Sets company level distribution values on a line item from given
    -- ifac data.
    --
    -- Parameters:
    --     p_line_item_company_dist_rec: The company level distribution
    --         record where updates will be applied.
    --     p_transaction_rec: The record of the transaction which owns
    --         the processing line item.
    --     p_ifac: All ifac records.
    --     p_ifac_pc_level_idx: The index of profit center level ifac record
    --         to process.
    --     p_ifac_vend_level_idx: The index of venfor level ifac record to
    --         process.
    --     p_ifac_pc_vendor_level_idxes: The indexes of all vendor level ifac
    --         records under given profit center level ifac.
    --
    -- Parameters to modify:
    --    p_line_item_company_dist_rec
    ----+----------------------------------+-------------------------------
    PROCEDURE set_li_dist_comp_from_ifac_p(
        p_line_item_company_dist_rec       IN OUT NOCOPY cont_li_dist_company%ROWTYPE
       ,p_line_item_dist_rec               IN OUT NOCOPY cont_line_item_dist%ROWTYPE
       ,p_transaction_rec                  IN OUT NOCOPY cont_transaction%ROWTYPE
       ,p_ifac                             IN OUT NOCOPY t_table_ifac_cargo_value
       ,p_ifac_pc_level_idx                NUMBER
       ,p_ifac_vend_level_idx              NUMBER
       ,p_ifac_pc_vendor_level_idxes       IN OUT NOCOPY t_table_number
       )
    IS
        l_company_qty1_all_zero	           BOOLEAN;
        l_share                            NUMBER;
        l_ifac_vendor_level                t_ifac_cargo_value;
        l_ifac_pc_level                    t_ifac_cargo_value;
        l_vendor_split_source_value        NUMBER;
        l_pc_split_source_value            NUMBER;
    BEGIN
        l_company_qty1_all_zero := get_if_split_src_zero_p(p_ifac, p_ifac_pc_vendor_level_idxes);
        l_ifac_vendor_level := p_ifac(p_ifac_vend_level_idx);
        l_ifac_pc_level := p_ifac(p_ifac_pc_level_idx);
        l_vendor_split_source_value := nvl(l_ifac_vendor_level.get_split_source_value, 0);
        l_pc_split_source_value := nvl(l_ifac_pc_level.get_split_source_value, 0);

        -- Share is determined from table cont_line_item_dist as qty1-qty4
        -- might have individual shares (ECPD-11824)
        l_share := CASE
            WHEN l_vendor_split_source_value = 0 AND l_pc_split_source_value = 0 THEN
                0
            WHEN l_pc_split_source_value = 0 THEN
                0
            ELSE
                l_vendor_split_source_value / l_pc_split_source_value
            END;

        p_line_item_company_dist_rec.vendor_share :=
            CASE
                WHEN l_company_qty1_all_zero and p_ifac_pc_vendor_level_idxes.count = 1 THEN
                    1
                WHEN l_company_qty1_all_zero and p_ifac_pc_vendor_level_idxes.count > 1 THEN
                    NVL(ecdp_transaction_qty.GetCompanyShare(
                            p_transaction_rec.trans_template_id,
                            p_transaction_rec.daytime,
                            l_ifac_pc_level.profit_center_id,
                            ec_company.company_id(l_ifac_vendor_level.Vendor_Id)),
                        EC_CONTRACT_PARTY_SHARE.party_share(
                            p_transaction_rec.object_id,
                            l_ifac_vendor_level.Vendor_Id,
                            'VENDOR',
                            p_transaction_rec.daytime, '<=')/100)
                ELSE
                    l_share
            END;

        p_line_item_company_dist_rec.qty1 := l_ifac_vendor_level.NET_QTY1;
        p_line_item_company_dist_rec.qty2 := l_ifac_vendor_level.NET_QTY2;
        p_line_item_company_dist_rec.qty3 := l_ifac_vendor_level.NET_QTY3;
        p_line_item_company_dist_rec.qty4 := l_ifac_vendor_level.NET_QTY4;

        set_split_source_value_p(p_line_item_company_dist_rec, l_vendor_split_source_value);
        p_line_item_company_dist_rec.split_value := l_vendor_split_source_value;
        p_line_item_company_dist_rec.split_share := get_company_split_share_p(
            p_line_item_company_dist_rec.vendor_share, p_line_item_company_dist_rec.customer_share);

        p_line_item_company_dist_rec.vendor_share_qty2 := ecdp_revn_common.get_ratio(
            p_line_item_company_dist_rec.qty2, p_line_item_dist_rec.qty2);
        p_line_item_company_dist_rec.vendor_share_qty3 := ecdp_revn_common.get_ratio(
            p_line_item_company_dist_rec.qty3, p_line_item_dist_rec.qty3);
        p_line_item_company_dist_rec.vendor_share_qty4 := ecdp_revn_common.get_ratio(
            p_line_item_company_dist_rec.qty4, p_line_item_dist_rec.qty4);
    END;
    -----------------------------------------------------------------------
    -- Sets profit center level distribution values on a line item from
    -- given ifac data.
    --
    -- Parameters:
    --     p_line_item_pc_dist_rec: The profit center level distribution
    --         record where updates will be applied.
    --     p_transaction_rec: The record of the transaction which owns
    --         the processing line item.
    --     p_ifac: All ifac records.
    --     p_ifac_pc_level_idx: The index of profit center level ifac
    --         record to process.
    --     p_ifac_all_pc_level_idxes: All indexes of profit center level
    --        ifac records on the processing line item.
    --
    -- Parameters to modify:
    --    p_line_item_pc_dist_rec
    ----+----------------------------------+-------------------------------
    PROCEDURE set_li_dist_pc_from_ifac_p(
        p_line_item_pc_dist_rec            IN OUT NOCOPY cont_line_item_dist%ROWTYPE
       ,p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
       ,p_transaction_rec                  IN OUT NOCOPY cont_transaction%ROWTYPE
       ,p_transaction_qty_rec              IN OUT NOCOPY cont_transaction_qty%ROWTYPE
       ,p_ifac                             IN OUT NOCOPY t_table_ifac_sales_qty
       ,p_ifac_pc_level_idx                NUMBER
       ,p_ifac_all_pc_level_idxes          IN OUT NOCOPY t_table_number
       )
    IS
        l_pc_split_source_all_zero	       BOOLEAN;
        l_qty1_share                       NUMBER;
        l_abs_field_qty                    NUMBER;
        l_field_count                      NUMBER;
        l_ifac_pc_level                    t_ifac_sales_qty;
        l_split_source                     NUMBER;
    BEGIN
        l_pc_split_source_all_zero := get_if_split_src_zero_p(p_ifac, p_ifac_all_pc_level_idxes);
        l_ifac_pc_level := p_ifac(p_ifac_pc_level_idx);
        l_split_source := nvl(l_ifac_pc_level.get_split_source_value, 0);

        l_abs_field_qty := 0;

        FOR idx IN p_ifac_all_pc_level_idxes.first..p_ifac_all_pc_level_idxes.last LOOP
            l_abs_field_qty := l_abs_field_qty + abs(p_ifac(p_ifac_all_pc_level_idxes(idx)).get_split_source_value);
        END LOOP;

        -- Get the number of fields to distribute to to be used when creating
        -- the 'artificial' split shares when all quantites are zero
        SELECT COUNT(d.line_item_key)
        INTO l_field_count
        FROM cont_line_item_dist d
        WHERE d.transaction_key = p_line_item_pc_dist_rec.transaction_key
            AND d.line_item_key = p_line_item_pc_dist_rec.line_item_key;

        -- make sure we don't divide by 0
        IF l_field_count = 0 THEN
            l_field_count := 1;
        END IF;

        IF p_line_item_rec.line_item_based_type = ecdp_revn_ft_constants.li_btype_quantity THEN
            -- Get the atual share based on quantities
            l_qty1_share :=
                CASE
                --total transaction qty is 0 and all fields are 0:
                --Use field dist from Transaction Distribution Setup
                WHEN nvl(p_transaction_qty_rec.net_qty1,0) = 0 and l_pc_split_source_all_zero
                    THEN nvl(ecdp_transaction_qty.GetFieldShare(
                        p_transaction_rec.trans_template_id, p_transaction_rec.daytime, p_line_item_pc_dist_rec.Dist_Id),0)
                --total transaction qty is 0 and one or more fields are non-zero and this field is 0:
                WHEN nvl(p_transaction_qty_rec.net_qty1,0) = 0 and (NOT l_pc_split_source_all_zero) AND l_split_source = 0
                    THEN 0
                --total transaction qty is 0 and one or more fields are non-zero and this field is non-zero:
                WHEN nvl(p_transaction_qty_rec.net_qty1,0) = 0 and (NOT l_pc_split_source_all_zero) AND l_split_source <> 0
                    THEN SIGN(l_split_source)*(1+2*(l_split_source/l_abs_field_qty))
                -- total transaction is not 0 and this field is 0:
                WHEN nvl(p_transaction_qty_rec.net_qty1,0) <> 0 AND l_split_source = 0
                    THEN 0
                -- total transaction is not 0 and this field is not 0:
                WHEN nvl(p_transaction_qty_rec.net_qty1,0) <> 0 AND l_split_source <> 0
                    THEN (l_split_source/p_transaction_qty_rec.net_qty1)
                ELSE
                    (l_split_source/p_transaction_qty_rec.net_qty1)
                END;
        ELSE
            IF l_pc_split_source_all_zero THEN
                -- Use field dist from Transaction Distribution Setup, if not found,
                -- to cater for line items that doesn't have any quantities,
                -- use shares genreated before as fallback
                l_qty1_share := nvl(
                    ecdp_transaction_qty.GetFieldShare(
                        p_transaction_rec.trans_template_id, p_transaction_rec.daytime, p_line_item_pc_dist_rec.Dist_Id),
                        nvl(p_line_item_pc_dist_rec.split_share, 0));
            ELSE
                l_qty1_share := l_split_source/l_abs_field_qty;
            END IF;
        END IF;

        p_line_item_pc_dist_rec.qty1 := l_ifac_pc_level.Qty1;
        p_line_item_pc_dist_rec.qty2 := l_ifac_pc_level.Qty2;
        p_line_item_pc_dist_rec.qty3 := l_ifac_pc_level.Qty3;
        p_line_item_pc_dist_rec.qty4 := l_ifac_pc_level.Qty4;

        -- Share is determined from table cont_line_item_dist as qty1-qty4 might have individual shares (ECPD-11824)
        p_line_item_pc_dist_rec.split_share_qty2 := ecdp_revn_common.get_ratio(l_ifac_pc_level.Qty2, p_transaction_qty_rec.net_qty2);
        p_line_item_pc_dist_rec.split_share_qty3 := ecdp_revn_common.get_ratio(l_ifac_pc_level.Qty3, p_transaction_qty_rec.net_qty3);
        p_line_item_pc_dist_rec.split_share_qty4 := ecdp_revn_common.get_ratio(l_ifac_pc_level.Qty4, p_transaction_qty_rec.net_qty4);

        set_split_source_value_p(p_line_item_pc_dist_rec, l_split_source);
        p_line_item_pc_dist_rec.split_value := l_split_source;
        p_line_item_pc_dist_rec.split_share := l_qty1_share;
    END;


-----------------------------------------------------------------------
    -- Sets profit center level distribution values on a line item from
    -- given ifac data.
    --
    -- Parameters:
    --     p_line_item_pc_dist_rec: The profit center level distribution
    --         record where updates will be applied.
    --     p_transaction_rec: The record of the transaction which owns
    --         the processing line item.
    --     p_ifac: All ifac records.
    --     p_ifac_pc_level_idx: The index of profit center level ifac
    --         record to process.
    --     p_ifac_all_pc_level_idxes: All indexes of profit center level
    --        ifac records on the processing line item.
    --
    -- Parameters to modify:
    --    p_line_item_pc_dist_rec
    ----+----------------------------------+-------------------------------
    PROCEDURE set_li_dist_pc_from_ifac_p(
        p_line_item_pc_dist_rec            IN OUT NOCOPY cont_line_item_dist%ROWTYPE
       ,p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
       ,p_transaction_rec                  IN OUT NOCOPY cont_transaction%ROWTYPE
       ,p_transaction_qty_rec              IN OUT NOCOPY cont_transaction_qty%ROWTYPE
       ,p_ifac                             IN OUT NOCOPY t_table_ifac_cargo_value
       ,p_ifac_pc_level_idx                NUMBER
       ,p_ifac_all_pc_level_idxes          IN OUT NOCOPY t_table_number
       )
    IS
        l_pc_split_source_all_zero	       BOOLEAN;
        l_qty1_share                       NUMBER;
        l_abs_field_qty                    NUMBER;
        l_field_count                      NUMBER;
        l_ifac_pc_level                    t_ifac_cargo_value;
        l_split_source                     NUMBER;
    BEGIN
        l_pc_split_source_all_zero := get_if_split_src_zero_p(p_ifac, p_ifac_all_pc_level_idxes);
        l_ifac_pc_level := p_ifac(p_ifac_pc_level_idx);
        l_split_source := nvl(l_ifac_pc_level.get_split_source_value, 0);

        l_abs_field_qty := 0;

        FOR idx IN p_ifac_all_pc_level_idxes.first..p_ifac_all_pc_level_idxes.last LOOP
            l_abs_field_qty := l_abs_field_qty + abs(p_ifac(p_ifac_all_pc_level_idxes(idx)).get_split_source_value);
        END LOOP;

        -- Get the number of fields to distribute to to be used when creating
        -- the 'artificial' split shares when all quantites are zero
        SELECT COUNT(d.line_item_key)
        INTO l_field_count
        FROM cont_line_item_dist d
        WHERE d.transaction_key = p_line_item_pc_dist_rec.transaction_key
            AND d.line_item_key = p_line_item_pc_dist_rec.line_item_key;

        -- make sure we don't divide by 0
        IF l_field_count = 0 THEN
            l_field_count := 1;
        END IF;

        IF p_line_item_rec.line_item_based_type = ecdp_revn_ft_constants.li_btype_quantity THEN
            -- Get the atual share based on quantities
            l_qty1_share :=
                CASE
                --total transaction qty is 0 and all fields are 0:
                --Use field dist from Transaction Distribution Setup
                WHEN nvl(p_transaction_qty_rec.net_qty1,0) = 0 and l_pc_split_source_all_zero
                    THEN nvl(ecdp_transaction_qty.GetFieldShare(
                        p_transaction_rec.trans_template_id, p_transaction_rec.daytime, p_line_item_pc_dist_rec.Dist_Id),0)
                --total transaction qty is 0 and one or more fields are non-zero and this field is 0:
                WHEN nvl(p_transaction_qty_rec.net_qty1,0) = 0 and (NOT l_pc_split_source_all_zero) AND l_split_source = 0
                    THEN 0
                --total transaction qty is 0 and one or more fields are non-zero and this field is non-zero:
                WHEN nvl(p_transaction_qty_rec.net_qty1,0) = 0 and (NOT l_pc_split_source_all_zero) AND l_split_source <> 0
                    THEN SIGN(l_split_source)*(1+2*(l_split_source/l_abs_field_qty))
                -- total transaction is not 0 and this field is 0:
                WHEN nvl(p_transaction_qty_rec.net_qty1,0) <> 0 AND l_split_source = 0
                    THEN 0
                -- total transaction is not 0 and this field is not 0:
                WHEN nvl(p_transaction_qty_rec.net_qty1,0) <> 0 AND l_split_source <> 0
                    THEN (l_split_source/p_transaction_qty_rec.net_qty1)
                ELSE
                    (l_split_source/p_transaction_qty_rec.net_qty1)
                END;
        ELSE
            IF l_pc_split_source_all_zero THEN
                -- Use field dist from Transaction Distribution Setup, if not found,
                -- to cater for line items that doesn't have any quantities,
                -- use shares genreated before as fallback
                l_qty1_share := nvl(
                    ecdp_transaction_qty.GetFieldShare(
                        p_transaction_rec.trans_template_id, p_transaction_rec.daytime, p_line_item_pc_dist_rec.Dist_Id),
                        nvl(p_line_item_pc_dist_rec.split_share, 0));
            ELSE
                l_qty1_share := l_split_source/l_abs_field_qty;
            END IF;
        END IF;

        p_line_item_pc_dist_rec.qty1 := l_ifac_pc_level.NET_QTY1;
        p_line_item_pc_dist_rec.qty2 := l_ifac_pc_level.NET_QTY2;
        p_line_item_pc_dist_rec.qty3 := l_ifac_pc_level.NET_QTY3;
        p_line_item_pc_dist_rec.qty4 := l_ifac_pc_level.NET_QTY4;

        -- Share is determined from table cont_line_item_dist as qty1-qty4 might have individual shares (ECPD-11824)
        p_line_item_pc_dist_rec.split_share_qty2 := ecdp_revn_common.get_ratio(l_ifac_pc_level.NET_QTY2, p_transaction_qty_rec.net_qty2);
        p_line_item_pc_dist_rec.split_share_qty3 := ecdp_revn_common.get_ratio(l_ifac_pc_level.NET_QTY3, p_transaction_qty_rec.net_qty3);
        p_line_item_pc_dist_rec.split_share_qty4 := ecdp_revn_common.get_ratio(l_ifac_pc_level.NET_QTY4, p_transaction_qty_rec.net_qty4);

        set_split_source_value_p(p_line_item_pc_dist_rec, l_split_source);
        p_line_item_pc_dist_rec.split_value := l_split_source;
        p_line_item_pc_dist_rec.split_share := l_qty1_share;
    END;
    -----------------------------------------------------------------------
    -- Sets profit center level distribution values on a line item from
    -- the given line item.
    ----+----------------------------------+-------------------------------
    PROCEDURE set_li_dist_pc_from_li_p(
        p_line_item_pc_dist_rec            IN OUT NOCOPY cont_line_item_dist%ROWTYPE
       ,p_line_item_pc_dist_source_rec     IN OUT NOCOPY cont_line_item_dist%ROWTYPE
       ,p_set_secondary_qty_shares         BOOLEAN
    )
    IS
    BEGIN
        p_line_item_pc_dist_rec.split_share := p_line_item_pc_dist_source_rec.split_share;

        IF nvl(p_set_secondary_qty_shares, TRUE) THEN
            p_line_item_pc_dist_rec.split_share_qty2 := p_line_item_pc_dist_source_rec.split_share_qty2;
            p_line_item_pc_dist_rec.split_share_qty3 := p_line_item_pc_dist_source_rec.split_share_qty3;
            p_line_item_pc_dist_rec.split_share_qty4 := p_line_item_pc_dist_source_rec.split_share_qty4;
        END IF;
    END;


    -----------------------------------------------------------------------
    -- Sets vendor level distribution values on a line item from
    -- the given line item.
    ----+----------------------------------+-------------------------------
    PROCEDURE set_li_dist_comp_from_li_p(
        p_line_item_comp_dist_rec          IN OUT NOCOPY cont_li_dist_company%ROWTYPE
       ,p_line_item_comp_dist_src_rec      IN OUT NOCOPY cont_li_dist_company%ROWTYPE
       ,p_set_secondary_qty_shares         BOOLEAN
    )
    IS
    BEGIN
        p_line_item_comp_dist_rec.split_value := p_line_item_comp_dist_src_rec.split_value;
        p_line_item_comp_dist_rec.vendor_share := p_line_item_comp_dist_src_rec.vendor_share;

        IF nvl(p_set_secondary_qty_shares, TRUE) THEN
            p_line_item_comp_dist_rec.vendor_share_qty2 := p_line_item_comp_dist_src_rec.vendor_share_qty2;
            p_line_item_comp_dist_rec.vendor_share_qty3 := p_line_item_comp_dist_src_rec.vendor_share_qty3;
            p_line_item_comp_dist_rec.vendor_share_qty4 := p_line_item_comp_dist_src_rec.vendor_share_qty4;
        END IF;
    END;

    -----------------------------------------------------------------------
    -- Applys line item company dist changes to cont_li_dist_company
    ----+----------------------------------+-------------------------------
    PROCEDURE apply_shares_p(
        p_li_dist_company_rec              IN OUT NOCOPY cont_li_dist_company%ROWTYPE
        )
    IS
    BEGIN
        UPDATE cont_li_dist_company c
        SET c.split_value = p_li_dist_company_rec.split_value,
            c.split_share = p_li_dist_company_rec.split_share,
            c.vendor_share = p_li_dist_company_rec.vendor_share,
            c.vendor_share_qty2 = p_li_dist_company_rec.vendor_share_qty2,
            c.vendor_share_qty3 = p_li_dist_company_rec.vendor_share_qty3,
            c.vendor_share_qty4 = p_li_dist_company_rec.vendor_share_qty4,
            c.qty1 = p_li_dist_company_rec.qty1,
            c.qty2 = p_li_dist_company_rec.qty2,
            c.qty3 = p_li_dist_company_rec.qty3,
            c.qty4 = p_li_dist_company_rec.qty4
        WHERE line_item_key = p_li_dist_company_rec.line_item_key
            AND dist_id = p_li_dist_company_rec.dist_id
            AND vendor_id = p_li_dist_company_rec.vendor_Id
            AND customer_id = p_li_dist_company_rec.customer_Id
            AND stream_item_id = p_li_dist_company_rec.stream_item_id;
    END;

    -----------------------------------------------------------------------
    -- Applys line item profit center dist changes to cont_line_item_dist
    ----+----------------------------------+-------------------------------
    PROCEDURE apply_shares_p(
        p_li_dist_pc_rec                   IN OUT NOCOPY cont_line_item_dist%ROWTYPE
        )
    IS
    BEGIN
        UPDATE cont_line_item_dist c
        SET c.split_value = p_li_dist_pc_rec.split_value,
            c.split_share = p_li_dist_pc_rec.split_share,
            c.split_share_qty2 = p_li_dist_pc_rec.split_share_qty2,
            c.split_share_qty3 = p_li_dist_pc_rec.split_share_qty3,
            c.split_share_qty4 = p_li_dist_pc_rec.split_share_qty4,
            c.qty1 = p_li_dist_pc_rec.qty1,
            c.qty2 = p_li_dist_pc_rec.qty2,
            c.qty3 = p_li_dist_pc_rec.qty3,
            c.qty4 = p_li_dist_pc_rec.qty4,
            c.pricing_value = p_li_dist_pc_rec.pricing_value
        WHERE line_item_key = p_li_dist_pc_rec.line_item_key
            AND dist_id = p_li_dist_pc_rec.dist_id
            AND stream_item_id = p_li_dist_pc_rec.stream_item_id;
    END;


    -----------------------------------------------------------------------
    -- Applys line item price element changes to cont_line_item
    ----+----------------------------------+-------------------------------
    PROCEDURE apply_price_element_p(
        p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
       )
    IS
    BEGIN
        UPDATE cont_line_item li
        SET li.price_element_code = p_line_item_rec.price_element_code,
            li.price_concept_code = p_line_item_rec.price_concept_code
        WHERE li.line_item_key = p_line_item_rec.line_item_key;
    END;

    -----------------------------------------------------------------------
    -- Applys line item dist method changes to cont_line_item
    ----+----------------------------------+-------------------------------
    PROCEDURE apply_dist_method_p(
        p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
        )
    IS
    BEGIN
        UPDATE cont_line_item
        SET dist_method = p_line_item_rec.dist_method
        WHERE line_item_key = p_line_item_rec.line_item_key;
    END;

    -----------------------------------------------------------------------
    -- Fill line item values and distributions from ifac.
    -- This procedure is for line items in period-based transactions.
    --
    -- Parameters:
    --
    -- Parameters to modify:
    ----+----------------------------------+-------------------------------
    PROCEDURE gen_dist_f_ifac_period_p(
        p_context                          IN OUT NOCOPY t_revn_doc_op_context
       ,p_transaction_rec                  IN OUT NOCOPY cont_transaction%ROWTYPE
       ,p_transaction_qty_rec              IN OUT NOCOPY cont_transaction_qty%ROWTYPE
       ,p_transaction_version_rec          IN OUT NOCOPY transaction_tmpl_version%ROWTYPE
       ,p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
       ,p_ifac_li_level_idx                NUMBER
       ,p_ifac_pc_idxes                    IN OUT NOCOPY t_table_number
       ,p_ifac_vend_idxes                  IN OUT NOCOPY t_table_number
       )
    IS
        l_ifac_li                          t_ifac_sales_qty;
        l_ifac_all                         t_table_ifac_sales_qty;
        ifac_pc_idx                        NUMBER;
        ifac_pc_vend_idxes                 t_table_number;
        ifac_vend_idx                      NUMBER;
    BEGIN
        l_ifac_all := p_context.ifac_period;
        l_ifac_li := p_context.get_ifac_period(p_ifac_li_level_idx);
        p_line_item_rec.dist_method := l_ifac_li.li_dist_method;

        gen_dist_party_f_ifac_period_p(
            p_context, p_line_item_rec.line_item_key, p_transaction_rec, p_transaction_version_rec,
            p_ifac_li_level_idx, p_ifac_pc_idxes);

        -- loop through all profit center level dist
        FOR profit_center_dist IN c_pc_dists(
                p_transaction_rec.transaction_key, p_line_item_rec.line_item_key) LOOP
            -- find the interfaced record for the profit center (pc level)
            ifac_pc_idx := ecdp_revn_ifac_wrapper_period.Find_One(
                p_ifac => l_ifac_all,
                p_range => p_ifac_pc_idxes,
                p_profit_center_id => profit_center_dist.Dist_Id);

            IF ifac_pc_idx IS NULL THEN
                del_dist_by_pc_i(p_line_item_rec.line_item_key, profit_center_dist.Dist_Id);
                continue;
            END IF;

            set_li_dist_pc_from_ifac_p(
                profit_center_dist, p_line_item_rec, p_transaction_rec, p_transaction_qty_rec,
                l_ifac_all, ifac_pc_idx, p_ifac_pc_idxes);
            apply_shares_p(profit_center_dist);

            -- find the interfaced records for the profit center (vendor level)
            ifac_pc_vend_idxes := ecdp_revn_ifac_wrapper_period.Find(
                p_ifac => l_ifac_all,
                p_range => p_ifac_vend_idxes,
                p_profit_center_id => profit_center_dist.Dist_Id);

            FOR line_item_company_dist IN c_company_dists(
                p_transaction_rec.transaction_key, p_line_item_rec.line_item_key, profit_center_dist.Dist_Id) LOOP

                -- find the interfaced record for the vendor (vendor level)
                ifac_vend_idx := ecdp_revn_ifac_wrapper_period.find_one(
                    p_ifac => l_ifac_all,
                    p_range => ifac_pc_vend_idxes,
                    p_profit_center_id => profit_center_dist.Dist_Id,
                    p_vendor_id => line_item_company_dist.vendor_id);

                IF ifac_vend_idx IS NULL THEN
                    del_dist_by_pc_vd_i(p_line_item_rec.line_item_key, profit_center_dist.Dist_Id,line_item_company_dist.vendor_id);
                    continue;
                END IF;

                set_li_dist_comp_from_ifac_p(
                    line_item_company_dist, profit_center_dist, p_transaction_rec, l_ifac_all,
                    ifac_pc_idx, ifac_vend_idx, ifac_pc_vend_idxes);
                apply_shares_p(line_item_company_dist);
            END LOOP;
        END LOOP;

        apply_dist_method_p(p_line_item_rec);
    END;



    -----------------------------------------------------------------------
    -- Fill line item values and distributions from ifac.
    -- This procedure is for line items in period-based transactions.
    --
    -- Parameters:
    --
    -- Parameters to modify:
    ----+----------------------------------+-------------------------------
    PROCEDURE gen_dist_f_ifac_cargo_p(
        p_context                          IN OUT NOCOPY t_revn_doc_op_context
       ,p_transaction_rec                  IN OUT NOCOPY cont_transaction%ROWTYPE
       ,p_transaction_qty_rec              IN OUT NOCOPY cont_transaction_qty%ROWTYPE
       ,p_transaction_version_rec          IN OUT NOCOPY transaction_tmpl_version%ROWTYPE
       ,p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
       ,p_ifac_li_level_idx                NUMBER
       ,p_ifac_pc_idxes                    IN OUT NOCOPY t_table_number
       ,p_ifac_vend_idxes                  IN OUT NOCOPY t_table_number
       )
    IS
        l_ifac_li                          t_ifac_cargo_value;
        l_ifac_all                         t_table_ifac_cargo_value;
        ifac_pc_idx                        NUMBER;
        ifac_pc_vend_idxes                 t_table_number;
        ifac_vend_idx                      NUMBER;
    BEGIN
        l_ifac_all := p_context.ifac_cargo;
        l_ifac_li := p_context.get_ifac_cargo(p_ifac_li_level_idx);
        p_line_item_rec.dist_method := l_ifac_li.li_dist_method;

        gen_dist_party_f_ifac_cargo_p(
            p_context, p_line_item_rec.line_item_key, p_transaction_rec, p_transaction_version_rec,
            p_ifac_li_level_idx, p_ifac_pc_idxes);

        -- loop through all profit center level dist
        FOR profit_center_dist IN c_pc_dists(
                p_transaction_rec.transaction_key, p_line_item_rec.line_item_key) LOOP
            -- find the interfaced record for the profit center (pc level)
            ifac_pc_idx := ecdp_revn_ifac_wrapper_cargo.Find_One(
                p_ifac => l_ifac_all,
                p_range => p_ifac_pc_idxes,
                p_profit_center_id => profit_center_dist.Dist_Id);

            IF ifac_pc_idx IS NULL THEN
                del_dist_by_pc_i(p_line_item_rec.line_item_key, profit_center_dist.Dist_Id);
                continue;
            END IF;

            set_li_dist_pc_from_ifac_p(
                profit_center_dist, p_line_item_rec, p_transaction_rec, p_transaction_qty_rec,
                l_ifac_all, ifac_pc_idx, p_ifac_pc_idxes);
            apply_shares_p(profit_center_dist);

            -- find the interfaced records for the profit center (vendor level)
            ifac_pc_vend_idxes := ecdp_revn_ifac_wrapper_cargo.Find(
                p_ifac => l_ifac_all,
                p_range => p_ifac_vend_idxes,
                p_profit_center_id => profit_center_dist.Dist_Id);

            FOR line_item_company_dist IN c_company_dists(
                p_transaction_rec.transaction_key, p_line_item_rec.line_item_key, profit_center_dist.Dist_Id) LOOP

                -- find the interfaced record for the vendor (vendor level)
                ifac_vend_idx := ecdp_revn_ifac_wrapper_cargo.find_one(
                    p_ifac => l_ifac_all,
                    p_range => ifac_pc_vend_idxes,
                    p_profit_center_id => profit_center_dist.Dist_Id,
                    p_vendor_id => line_item_company_dist.vendor_id);

                IF ifac_vend_idx IS NULL THEN
                    del_dist_by_pc_vd_i(p_line_item_rec.line_item_key, profit_center_dist.Dist_Id,line_item_company_dist.vendor_id);
                    continue;
                END IF;

                set_li_dist_comp_from_ifac_p(
                    line_item_company_dist, profit_center_dist, p_transaction_rec, l_ifac_all,
                    ifac_pc_idx, ifac_vend_idx, ifac_pc_vend_idxes);
                apply_shares_p(line_item_company_dist);
            END LOOP;
        END LOOP;

        apply_dist_method_p(p_line_item_rec);
    END;

    -----------------------------------------------------------------------
    -- Generates values for percentage line item.
    ----+----------------------------------+-------------------------------
    PROCEDURE fill_li_val_perc(
        p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
       ,p_user                             VARCHAR2
        )
    IS
        --cursor for percentage_all
        CURSOR c_all_line_item(
            cp_transaction_key             cont_transaction.transaction_key%TYPE
            )
        IS
           SELECT t.pricing_value,
                  t.pricing_vat_value,
                  t.booking_value,
                  t.booking_vat_value,
                  t.memo_value,
                  t.memo_vat_value
             FROM cont_line_item t
            WHERE t.line_item_based_type NOT IN ('PERCENTAGE_ALL') --take all except percentage type line items
              AND t.transaction_key = cp_transaction_key;

        --cursor for percentage_qty
        CURSOR c_qty_line_item(
            cp_transaction_key             cont_transaction.transaction_key%TYPE
            )
        IS
           SELECT t.pricing_value,
                  t.pricing_vat_value,
                  t.booking_value,
                  t.booking_vat_value,
                  t.memo_value,
                  t.memo_vat_value
             FROM cont_line_item t
            WHERE t.line_item_based_type = 'QTY' --only take all QTY line items
              AND t.transaction_key = cp_transaction_key;

        lrec_cont_line_item_sum cont_line_item%ROWTYPE;
    BEGIN
        -- Loop through all line items and sum them up
        FOR LineItemAllCur IN c_all_line_item(p_line_item_rec.transaction_key) LOOP
            lrec_cont_line_item_sum.pricing_value := NVL(lrec_cont_line_item_sum.pricing_value, 0) + NVL(LineItemAllCur.pricing_value, 0);
        END LOOP;

        -- update percentage_all line item
        UPDATE cont_line_item t
        SET t.percentage_base_amount = lrec_cont_line_item_sum.pricing_value,
            t.pricing_value          = CASE WHEN t.percentage_value IS NULL THEN NULL WHEN t.percentage_value IS NOT NULL THEN lrec_cont_line_item_sum.pricing_value * t.percentage_value END,
            t.last_updated_by        = p_user
        WHERE t.line_item_key = p_line_item_rec.line_item_key
        AND t.line_item_based_type = 'PERCENTAGE_ALL';

        lrec_cont_line_item_sum.pricing_value := 0; --reset it to zero before next loop

        -- Loop through all line items and sum them up
        FOR LineItemQtyCur IN c_qty_line_item(p_line_item_rec.transaction_key) LOOP
        lrec_cont_line_item_sum.pricing_value := NVL(lrec_cont_line_item_sum.pricing_value, 0) + NVL(LineItemQtyCur.pricing_value, 0);
        END LOOP;

        -- update percentage_qty line item
        UPDATE cont_line_item t
        SET t.percentage_base_amount = lrec_cont_line_item_sum.pricing_value,
            t.pricing_value          = CASE WHEN t.percentage_value IS NULL THEN NULL WHEN t.percentage_value IS NOT NULL THEN lrec_cont_line_item_sum.pricing_value * t.percentage_value END,
            t.last_updated_by        = p_user
        WHERE t.line_item_key = p_line_item_rec.line_item_key
        AND t.line_item_based_type = 'PERCENTAGE_QTY';


        lrec_cont_line_item_sum.pricing_value := 0; --reset it to zero before next loop

        -- update percentage_manual line item
        UPDATE cont_line_item t
        SET t.pricing_value   = CASE WHEN t.percentage_value IS NULL THEN NULL WHEN t.percentage_value IS NOT NULL THEN t.percentage_base_amount * t.percentage_value END,
            t.last_updated_by = p_user
        WHERE t.line_item_key = p_line_item_rec.line_item_key
        AND t.line_item_based_type = 'PERCENTAGE_MANUAL';

        gen_dist_f_conf_p(p_line_item_rec, p_user);
    END;


    -----------------------------------------------------------------------
    -- Gets a boolean value indicating whether the line item with given
    -- attributes is using shares interfaced in.
    ----+----------------------------------+-------------------------------
    FUNCTION get_using_interfaced_share_p(
        p_line_item_type                   ecdp_revn_ft_constants.T_LI_BTYPE
       ,p_line_item_creation_method        ecdp_revn_ft_constants.T_C_MTD
       ,p_dist_method                      ecdp_revn_ft_constants.t_li_dist_mtd
        )
    RETURN BOOLEAN
    IS
        l_base_priority                    NUMBER;
    BEGIN
        IF p_line_item_creation_method != ecdp_revn_ft_constants.c_mtd_interface THEN
            RETURN FALSE;
        END IF;

        l_base_priority :=
                ecdp_revn_ft_constants.li_dist_mtd_priority(ecdp_revn_ft_constants.li_dist_mtd_ifac);
        RETURN l_base_priority > ecdp_revn_ft_constants.li_dist_mtd_priority(p_dist_method);
    END;

    -----------------------------------------------------------------------
    -- Asserts when updating or inserting a quantity line item to an
    -- existing transactin, there should be no existing line items that was
    -- interfaced using fallbacked shares.
    --
    -- Exceptions
    --     ecdp_revn_ft_error.li_dist_ref_exists: when assert fails
    ----+----------------------------------+-------------------------------
    PROCEDURE assert_no_share_ref_ifac_qty_p(
        p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
        )
    IS
    BEGIN
        IF p_line_item_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_quantity THEN
            RETURN;
        END IF;

        FOR li_meta IN c_get_li_meta(p_line_item_rec.transaction_key) LOOP
            IF li_meta.line_item_based_type != ecdp_revn_ft_constants.li_btype_quantity
                AND li_meta.creation_method = ecdp_revn_ft_constants.c_mtd_interface
                AND NOT get_using_interfaced_share_p(
                    li_meta.line_item_based_type, li_meta.creation_method, li_meta.dist_method)
            THEN
                RAISE ecdp_revn_ft_error.li_dist_ref_exists;
            END IF;
        END LOOP;
    END;

    -----------------------------------------------------------------------
    -- Sets value to the given line item by provided values.
    -- This procedure is common for all line items.
    ----+----------------------------------+-------------------------------
    FUNCTION set_li_val_common_p(
        p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
       ,p_vat_code                         cont_line_item.vat_code%TYPE
        )
    RETURN BOOLEAN
    IS
        l_handled                          BOOLEAN;

    BEGIN
        l_handled := FALSE;

        IF p_vat_code IS NOT NULL THEN
            p_line_item_rec.vat_code := p_vat_code;
            p_line_item_rec.ifac_vat_code_ind := 'Y';
            l_handled := TRUE;
        END IF;

        RETURN l_handled;
    END;

    -----------------------------------------------------------------------
    -- Applies values on given line item back to db table cont_line_item.
    -- This procedure is common for all line items.
    ----+----------------------------------+-------------------------------
    FUNCTION apply_li_val_common_p(
        p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
        )
    RETURN BOOLEAN
    IS
        l_handled                          BOOLEAN;

    BEGIN
        l_handled := FALSE;

        IF nvl(p_line_item_rec.ifac_vat_code_ind,'N') = 'Y' THEN
            UPDATE cont_line_item
            SET vat_code = p_line_item_rec.vat_code
               ,vat_rate = ec_vat_code_version.rate(ec_vat_code.object_id_by_uk(p_line_item_rec.vat_code), p_line_item_rec.daytime, '<=')
               ,ifac_vat_code_ind = 'Y'
            WHERE line_item_key = p_line_item_rec.line_item_key;
            l_handled := TRUE;
        END IF;

        RETURN l_handled;
    END;

    -----------------------------------------------------------------------
    -- Sets value to the given line item by provided values.
    -- This procedure is for quantity line items.
    ----+----------------------------------+-------------------------------
    FUNCTION set_li_val_qty_p(
        p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
       ,p_qty1                             cont_line_item.qty1%TYPE
       ,p_qty2                             cont_line_item.qty2%TYPE
       ,p_qty3                             cont_line_item.qty3%TYPE
       ,p_qty4                             cont_line_item.qty4%TYPE
       ,p_qty1_uom                         cont_line_item.uom1_code%TYPE
       ,p_qty2_uom                         cont_line_item.uom2_code%TYPE
       ,p_qty3_uom                         cont_line_item.uom3_code%TYPE
       ,p_qty4_uom                         cont_line_item.uom4_code%TYPE
        )
    RETURN BOOLEAN
    IS
    BEGIN
        IF p_line_item_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_quantity THEN
            RETURN FALSE;
        END IF;

        p_line_item_rec.qty1 := p_qty1;
        p_line_item_rec.qty2 := p_qty2;
        p_line_item_rec.qty3 := p_qty3;
        p_line_item_rec.qty4 := p_qty4;
        p_line_item_rec.uom1_code := p_qty1_uom;
        p_line_item_rec.uom2_code := p_qty2_uom;
        p_line_item_rec.uom3_code := p_qty3_uom;
        p_line_item_rec.uom4_code := p_qty4_uom;
        RETURN TRUE;
    END;

    -----------------------------------------------------------------------
    -- Applies values on given line item back to db table cont_line_item.
    -- This procedure is for quantity line items.
    ----+----------------------------------+-------------------------------
    FUNCTION apply_li_val_qty_p(
        p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
        )
    RETURN BOOLEAN
    IS
    BEGIN
        IF p_line_item_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_quantity THEN
            RETURN FALSE;
        END IF;

        UPDATE cont_line_item
        SET qty1 = p_line_item_rec.qty1
           ,qty2 = p_line_item_rec.qty2
           ,qty3 = p_line_item_rec.qty3
           ,qty4 = p_line_item_rec.qty4
           ,uom1_code = p_line_item_rec.uom1_code
           ,uom2_code = p_line_item_rec.uom2_code
           ,uom3_code = p_line_item_rec.uom3_code
           ,uom4_code = p_line_item_rec.uom4_code
        WHERE line_item_key = p_line_item_rec.line_item_key;

        RETURN TRUE;
    END;

    -----------------------------------------------------------------------
    -- Sets value to the given line item by provided values.
    -- This procedure is for free unit line items.
    ----+----------------------------------+-------------------------------
    FUNCTION set_li_val_free_unit_p(
        p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
       ,p_qty                              cont_line_item.free_unit_qty%TYPE
       ,p_unit_price                       cont_line_item.unit_price%TYPE
       ,p_unit_price_unit                  cont_line_item.unit_price_unit%TYPE
        )
    RETURN BOOLEAN
    IS
    BEGIN
        IF p_line_item_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_free_unit THEN
            RETURN FALSE;
        END IF;

        p_line_item_rec.free_unit_qty := p_qty;
        p_line_item_rec.unit_price := p_unit_price;
        p_line_item_rec.unit_price_unit := p_unit_price_unit;
        p_line_item_rec.uom1_code := NULL;
        p_line_item_rec.uom2_code := NULL;
        p_line_item_rec.uom3_code := NULL;
        p_line_item_rec.uom4_code := NULL;
        p_line_item_rec.qty1 := NULL;
        p_line_item_rec.qty2 := NULL;
        p_line_item_rec.qty3 := NULL;
        p_line_item_rec.qty4 := NULL;
        RETURN TRUE;
    END;

    -----------------------------------------------------------------------
    -- Applies values on given line item back to db table cont_line_item.
    -- This procedure is for free unit line items.
    ----+----------------------------------+-------------------------------
    FUNCTION apply_li_val_free_unit_p(
        p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
        )
    RETURN BOOLEAN
    IS
    BEGIN
        IF p_line_item_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_free_unit THEN
            RETURN FALSE;
        END IF;

        UPDATE cont_line_item
        SET free_unit_qty = p_line_item_rec.free_unit_qty
           ,unit_price = p_line_item_rec.unit_price
           ,unit_price_unit = p_line_item_rec.unit_price_unit
           ,uom1_code = NULL
           ,uom2_code = NULL
           ,uom3_code = NULL
           ,uom4_code = NULL
           ,qty1 = NULL
           ,qty2 = NULL
           ,qty3 = NULL
           ,qty4 = NULL
        WHERE line_item_key = p_line_item_rec.line_item_key;

        RETURN TRUE;
    END;

    -----------------------------------------------------------------------
    -- Sets value to the given line item by provided values.
    -- This procedure is for free unit with price object line items.
    ----+----------------------------------+-------------------------------
    FUNCTION set_li_val_free_unit_po_p(
        p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
       ,p_qty                              cont_line_item.free_unit_qty%TYPE
       ,p_unit_price                       cont_line_item.unit_price%TYPE
       ,p_unit_price_unit                  cont_line_item.unit_price_unit%TYPE
       ,p_price_object                     product_price.object_id%TYPE
       ,p_price_concept                    price_concept.price_concept_code%TYPE
       ,p_price_element                    price_concept_element.price_element_code%TYPE
       )
    RETURN BOOLEAN
    IS
        l_price_object_unit                product_price_version.uom%TYPE;
        l_price_concept_element_rec        price_concept_element%ROWTYPE;
    BEGIN
        IF p_line_item_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_free_unit_po THEN
            RETURN FALSE;
        END IF;

        l_price_object_unit := p_unit_price_unit;

        IF l_price_object_unit IS NULL THEN
            l_price_object_unit := ec_product_price_version.uom(p_price_object, p_line_item_rec.daytime, '<=');
        END IF;

        l_price_concept_element_rec := ec_price_concept_element.row_by_pk(p_price_concept, p_price_element);

        p_line_item_rec.free_unit_qty := p_qty;
        p_line_item_rec.unit_price := p_unit_price;
        p_line_item_rec.unit_price_unit := l_price_object_unit;
        p_line_item_rec.price_object_id := p_price_object;
        p_line_item_rec.price_concept_code := p_price_concept;
        p_line_item_rec.price_element_code := p_price_element;

        IF p_line_item_rec.line_item_type IS NULL THEN
            p_line_item_rec.line_item_type := l_price_concept_element_rec.line_item_type;
        END IF;

        IF p_line_item_rec.name IS NULL THEN
            p_line_item_rec.name := l_price_concept_element_rec.name;
        END IF;

        IF p_line_item_rec.description IS NULL THEN
            p_line_item_rec.description := l_price_concept_element_rec.name;
        END IF;

        p_line_item_rec.uom1_code := NULL;
        p_line_item_rec.uom2_code := NULL;
        p_line_item_rec.uom3_code := NULL;
        p_line_item_rec.uom4_code := NULL;
        p_line_item_rec.qty1 := NULL;
        p_line_item_rec.qty2 := NULL;
        p_line_item_rec.qty3 := NULL;
        p_line_item_rec.qty4 := NULL;

/*        IF lrec_cont_trans.transaction_date IS NOT NULL THEN
                lrec_li.unit_price := ecdp_transaction.GetQtyPrice(p_object_id, lv2_liv_id, NULL, p_transaction_key, lrec_cont_document.daytime, p_line_item_based_type ,p_price_object_id,lrec_li.price_element_code, 'Y');
        END IF;*/

        RETURN TRUE;
    END;

    -----------------------------------------------------------------------
    -- Applies values on given line item back to db table cont_line_item.
    -- This procedure is for free unit with price object line items.
    ----+----------------------------------+-------------------------------
    FUNCTION apply_li_val_free_unit_po_p(
        p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
        )
    RETURN BOOLEAN
    IS
    BEGIN
        IF p_line_item_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_free_unit_po THEN
            RETURN FALSE;
        END IF;

        UPDATE cont_line_item
        SET free_unit_qty = p_line_item_rec.free_unit_qty
           ,unit_price = p_line_item_rec.unit_price
           ,unit_price_unit = p_line_item_rec.unit_price_unit
           ,price_object_id = p_line_item_rec.price_object_id
           ,price_concept_code = p_line_item_rec.price_concept_code
           ,price_element_code = p_line_item_rec.price_element_code
           ,line_item_type = p_line_item_rec.line_item_type
           ,name = p_line_item_rec.name
           ,description = p_line_item_rec.description
           ,uom1_code = NULL
           ,uom2_code = NULL
           ,uom3_code = NULL
           ,uom4_code = NULL
           ,qty1 = NULL
           ,qty2 = NULL
           ,qty3 = NULL
           ,qty4 = NULL
        WHERE line_item_key = p_line_item_rec.line_item_key;

        RETURN TRUE;
    END;

    -----------------------------------------------------------------------
    -- Sets value to the given line item by provided values.
    -- This procedure is for fixed value line items.
    ----+----------------------------------+-------------------------------
    FUNCTION set_li_val_fixed_value_p(
        p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
       ,p_pricing_value                    cont_line_item.pricing_value%TYPE
       )
    RETURN BOOLEAN
    IS
    BEGIN
        IF p_line_item_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_fixed_value THEN
            RETURN FALSE;
        END IF;

        -- TODO: ADD LINE ITEM VALUE (optional)
        p_line_item_rec.pricing_value := p_pricing_value;
        p_line_item_rec.uom1_code := NULL;
        p_line_item_rec.uom2_code := NULL;
        p_line_item_rec.uom3_code := NULL;
        p_line_item_rec.uom4_code := NULL;
        p_line_item_rec.qty1 := NULL;
        p_line_item_rec.qty2 := NULL;
        p_line_item_rec.qty3 := NULL;
        p_line_item_rec.qty4 := NULL;

        RETURN TRUE;
    END;

    -----------------------------------------------------------------------
    -- Applies values on given line item back to db table cont_line_item.
    -- This procedure is for fixed value line items.
    ----+----------------------------------+-------------------------------
    FUNCTION apply_li_val_fixed_value_p(
        p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
        )
    RETURN BOOLEAN
    IS
    BEGIN
        IF p_line_item_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_fixed_value THEN
            RETURN FALSE;
        END IF;

        UPDATE cont_line_item
        SET pricing_value = p_line_item_rec.pricing_value
           ,uom1_code = NULL
           ,uom2_code = NULL
           ,uom3_code = NULL
           ,uom4_code = NULL
           ,qty1 = NULL
           ,qty2 = NULL
           ,qty3 = NULL
           ,qty4 = NULL
        WHERE line_item_key = p_line_item_rec.line_item_key;

        RETURN TRUE;
    END;

    -----------------------------------------------------------------------
    -- Sets value to the given line item by provided values.
    -- This procedure is for percentage all line items.
    ----+----------------------------------+-------------------------------
    FUNCTION set_li_val_perc_all_p(
        p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
       ,p_percentage_value                 cont_line_item.percentage_value%TYPE
       )
    RETURN BOOLEAN
    IS
    BEGIN
        IF p_line_item_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_percentage_all THEN
            RETURN FALSE;
        END IF;

        p_line_item_rec.percentage_value := p_percentage_value;
        p_line_item_rec.pricing_value := p_line_item_rec.unit_price * p_line_item_rec.percentage_value;
        p_line_item_rec.uom1_code := NULL;
        p_line_item_rec.uom2_code := NULL;
        p_line_item_rec.uom3_code := NULL;
        p_line_item_rec.uom4_code := NULL;
        p_line_item_rec.qty1 := NULL;
        p_line_item_rec.qty2 := NULL;
        p_line_item_rec.qty3 := NULL;
        p_line_item_rec.qty4 := NULL;

        RETURN TRUE;
    END;

    -----------------------------------------------------------------------
    -- Applies values on given line item back to db table cont_line_item.
    -- This procedure is for percentage all line items.
    ----+----------------------------------+-------------------------------
    FUNCTION apply_li_val_perc_all_p(
        p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
        )
    RETURN BOOLEAN
    IS
    BEGIN
        IF p_line_item_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_percentage_all THEN
            RETURN FALSE;
        END IF;

        UPDATE cont_line_item
        SET pricing_value = p_line_item_rec.pricing_value
           ,percentage_value = p_line_item_rec.percentage_value
           ,uom1_code = NULL
           ,uom2_code = NULL
           ,uom3_code = NULL
           ,uom4_code = NULL
           ,qty1 = NULL
           ,qty2 = NULL
           ,qty3 = NULL
           ,qty4 = NULL
        WHERE line_item_key = p_line_item_rec.line_item_key;

        RETURN TRUE;
    END;

    -----------------------------------------------------------------------
    -- Sets value to the given line item by provided values.
    -- This procedure is for percentage quantity line items.
    ----+----------------------------------+-------------------------------
    FUNCTION set_li_val_perc_qty_p(
        p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
       ,p_percentage_value                 cont_line_item.percentage_value%TYPE
       )
    RETURN BOOLEAN
    IS
    BEGIN
        IF p_line_item_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_percentage_qty THEN
            RETURN FALSE;
        END IF;

        p_line_item_rec.percentage_value := p_percentage_value;
        p_line_item_rec.pricing_value := p_line_item_rec.unit_price * p_line_item_rec.percentage_value;
        p_line_item_rec.uom1_code := NULL;
        p_line_item_rec.uom2_code := NULL;
        p_line_item_rec.uom3_code := NULL;
        p_line_item_rec.uom4_code := NULL;
        p_line_item_rec.qty1 := NULL;
        p_line_item_rec.qty2 := NULL;
        p_line_item_rec.qty3 := NULL;
        p_line_item_rec.qty4 := NULL;

        RETURN TRUE;
    END;

    -----------------------------------------------------------------------
    -- Applies values on given line item back to db table cont_line_item.
    -- This procedure is for percentage quantity line items.
    ----+----------------------------------+-------------------------------
    FUNCTION apply_li_val_perc_qty_p(
        p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
        )
    RETURN BOOLEAN
    IS
    BEGIN
        IF p_line_item_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_percentage_qty THEN
            RETURN FALSE;
        END IF;

        UPDATE cont_line_item
        SET pricing_value = p_line_item_rec.pricing_value
           ,percentage_value = p_line_item_rec.percentage_value
           ,uom1_code = NULL
           ,uom2_code = NULL
           ,uom3_code = NULL
           ,uom4_code = NULL
           ,qty1 = NULL
           ,qty2 = NULL
           ,qty3 = NULL
           ,qty4 = NULL
        WHERE line_item_key = p_line_item_rec.line_item_key;

        RETURN TRUE;
    END;

    -----------------------------------------------------------------------
    -- Sets value to the given line item by provided values.
    -- This procedure is for percentage manual line items.
    ----+----------------------------------+-------------------------------
    FUNCTION set_li_val_perc_man_p(
        p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
       ,p_percentage_value                 cont_line_item.percentage_value%TYPE
       ,p_percentage_base_amount           cont_line_item.percentage_base_amount%TYPE
       )
    RETURN BOOLEAN
    IS
    BEGIN
        IF p_line_item_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_percentage_manual THEN
            RETURN FALSE;
        END IF;

        p_line_item_rec.percentage_value := p_percentage_value;
        p_line_item_rec.percentage_base_amount := p_percentage_base_amount;
        p_line_item_rec.pricing_value := p_line_item_rec.unit_price * p_line_item_rec.percentage_value;
        p_line_item_rec.uom1_code := NULL;
        p_line_item_rec.uom2_code := NULL;
        p_line_item_rec.uom3_code := NULL;
        p_line_item_rec.uom4_code := NULL;
        p_line_item_rec.qty1 := NULL;
        p_line_item_rec.qty2 := NULL;
        p_line_item_rec.qty3 := NULL;
        p_line_item_rec.qty4 := NULL;

        RETURN TRUE;
    END;

    -----------------------------------------------------------------------
    -- Applies values on given line item back to db table cont_line_item.
    -- This procedure is for percentage manual line items.
    ----+----------------------------------+-------------------------------
    FUNCTION apply_li_val_perc_man_p(
        p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
        )
    RETURN BOOLEAN
    IS
    BEGIN
        IF p_line_item_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_percentage_manual THEN
            RETURN FALSE;
        END IF;

        UPDATE cont_line_item
        SET pricing_value = p_line_item_rec.pricing_value
           ,percentage_value = p_line_item_rec.percentage_value
           ,percentage_base_amount = p_line_item_rec.percentage_base_amount
           ,uom1_code = NULL
           ,uom2_code = NULL
           ,uom3_code = NULL
           ,uom4_code = NULL
           ,qty1 = NULL
           ,qty2 = NULL
           ,qty3 = NULL
           ,qty4 = NULL
        WHERE line_item_key = p_line_item_rec.line_item_key;

        RETURN TRUE;
    END;

    -----------------------------------------------------------------------
    -- Sets value to the given line item by provided values.
    -- This procedure is for interest line items.
    ----+----------------------------------+-------------------------------
    FUNCTION set_li_val_interest_p(
        p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
       ,p_interest_type                    cont_line_item.interest_type%TYPE
       ,p_compounding_period               cont_line_item.compounding_period%TYPE
       ,p_interest_form_date               cont_line_item.interest_from_date%TYPE
       ,p_interest_to_date                 cont_line_item.interest_to_date%TYPE
       ,p_base_rate                        cont_line_item.base_rate%TYPE
       ,p_rate_days                        cont_line_item.rate_days%TYPE
       ,p_rate_offset                      cont_line_item.rate_offset%TYPE
       ,p_interest_num_days                cont_line_item.interest_num_days%TYPE
       ,p_interests_group                  cont_line_item.interest_group%TYPE
       ,p_interest_base_amount             cont_line_item.interest_base_amount%TYPE
       )
    RETURN BOOLEAN
    IS
    BEGIN
        IF p_line_item_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_interest THEN
            RETURN FALSE;
        END IF;

        p_line_item_rec.interest_type := p_interest_type;
        p_line_item_rec.rate_offset := p_rate_offset;
        p_line_item_rec.compounding_period := p_compounding_period;
        p_line_item_rec.interest_from_date := p_interest_form_date;
        p_line_item_rec.interest_to_date := p_interest_to_date;
        p_line_item_rec.base_rate := p_base_rate;
        p_line_item_rec.rate_days := p_rate_days;
        p_line_item_rec.interest_num_days := p_interest_num_days;
        p_line_item_rec.interest_base_amount := p_interest_base_amount;

        -- interest group by default is the line item key if not given
        p_line_item_rec.interest_group := nvl(p_interests_group, p_line_item_rec.line_item_key);

        p_line_item_rec.uom1_code := NULL;
        p_line_item_rec.uom2_code := NULL;
        p_line_item_rec.uom3_code := NULL;
        p_line_item_rec.uom4_code := NULL;
        p_line_item_rec.qty1 := NULL;
        p_line_item_rec.qty2 := NULL;
        p_line_item_rec.qty3 := NULL;
        p_line_item_rec.qty4 := NULL;

        RETURN TRUE;
    END;

    -----------------------------------------------------------------------
    -- Applies values on given line item back to db table cont_line_item.
    -- This procedure is for interest line items.
    ----+----------------------------------+-------------------------------
    FUNCTION apply_li_val_interest_p(
        p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
       ,p_user                             VARCHAR2
        )
    RETURN BOOLEAN
    IS
    BEGIN
        IF p_line_item_rec.line_item_based_type != ecdp_revn_ft_constants.li_btype_interest THEN
            RETURN FALSE;
        END IF;

        UPDATE cont_line_item
        SET interest_type = p_line_item_rec.interest_type
           ,rate_offset = p_line_item_rec.rate_offset
           ,compounding_period = p_line_item_rec.compounding_period
           ,interest_from_date = p_line_item_rec.interest_from_date
           ,interest_to_date = p_line_item_rec.interest_to_date
           ,base_rate = p_line_item_rec.base_rate
           ,rate_days = p_line_item_rec.rate_days
           ,interest_num_days = p_line_item_rec.interest_num_days
           ,interest_base_amount = p_line_item_rec.interest_base_amount
           ,interest_group = p_line_item_rec.interest_group
           ,uom1_code = NULL
           ,uom2_code = NULL
           ,uom3_code = NULL
           ,uom4_code = NULL
           ,qty1 = NULL
           ,qty2 = NULL
           ,qty3 = NULL
           ,qty4 = NULL
        WHERE line_item_key = p_line_item_rec.line_item_key;

        RETURN TRUE;
    END;


    -----------------------------------------------------------------------
    -- Applies values on given line item back to db table cont_line_item.
    ----+----------------------------------+-------------------------------
    FUNCTION apply_li_val_p(
        p_context                          IN OUT NOCOPY t_revn_doc_op_context
       ,p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
        )
    RETURN BOOLEAN
    IS
        l_handled                          BOOLEAN;
    BEGIN
        l_handled := FALSE;

        -- handle common values for all line item types
        l_handled := apply_li_val_common_p(p_line_item_rec) OR l_handled;

        -- handle different line item types
        l_handled := apply_li_val_qty_p(p_line_item_rec) OR l_handled;
        l_handled := apply_li_val_free_unit_p(p_line_item_rec) OR l_handled;
        l_handled := apply_li_val_free_unit_po_p(p_line_item_rec) OR l_handled;
        l_handled := apply_li_val_fixed_value_p(p_line_item_rec) OR l_handled;
        l_handled := apply_li_val_perc_all_p(p_line_item_rec) OR l_handled;
        l_handled := apply_li_val_perc_qty_p(p_line_item_rec) OR l_handled;
        l_handled := apply_li_val_perc_man_p(p_line_item_rec) OR l_handled;
        l_handled := apply_li_val_interest_p(p_line_item_rec, p_context.user_id) OR l_handled;

        RETURN l_handled;
    END;

    -----------------------------------------------------------------------
    -- Sets value to the given line item by provided ifac data.
    ----+----------------------------------+-------------------------------
    FUNCTION set_li_val_by_ifac_period_p(
        p_context                          IN OUT NOCOPY t_revn_doc_op_context
       ,p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
       ,p_ifac_li_index                    NUMBER
        )
    RETURN BOOLEAN
    IS
        l_ifac_li                          t_ifac_sales_qty;
        l_handled                          BOOLEAN;
        l_int_num_of_days                  cont_line_item.interest_num_days%TYPE;
        l_document_setup_id                cont_document.document_key%TYPE;
        l_price_concept_code               product_price.price_concept_code%TYPE;

    BEGIN
        l_handled := FALSE;
        l_ifac_li := p_context.get_ifac_period(p_ifac_li_index);
        l_document_setup_id := ec_cont_document.contract_doc_id(p_line_item_rec.document_key);
        l_int_num_of_days := ec_contract_doc_version.int_num_days(l_document_setup_id, p_line_item_rec.daytime, '<=');
        l_price_concept_code := ec_product_price.price_concept_code(l_ifac_li.li_price_object_id);

        -- handle common values for all line item types
        l_handled := set_li_val_common_p(
                p_line_item_rec, l_ifac_li.vat_code) OR l_handled;

        -- handle different line item types
        l_handled := set_li_val_qty_p(
                p_line_item_rec,
                l_ifac_li.qty1, l_ifac_li.qty2, l_ifac_li.qty3, l_ifac_li.qty4,
                l_ifac_li.uom1_code, l_ifac_li.uom2_code, l_ifac_li.uom3_code, l_ifac_li.uom4_code) OR l_handled;
        l_handled := set_li_val_free_unit_p(
                p_line_item_rec, l_ifac_li.qty1, l_ifac_li.unit_price, l_ifac_li.unit_price_unit) OR l_handled;
        l_handled := set_li_val_free_unit_po_p(
                p_line_item_rec, l_ifac_li.qty1, l_ifac_li.unit_price, l_ifac_li.unit_price_unit,
                l_ifac_li.li_price_object_id, l_price_concept_code, NULL) OR l_handled;
        l_handled := set_li_val_fixed_value_p(
                p_line_item_rec, l_ifac_li.pricing_value) OR l_handled;
        l_handled := set_li_val_perc_all_p(
                p_line_item_rec, l_ifac_li.percentage_value) OR l_handled;
        l_handled := set_li_val_perc_qty_p(
                p_line_item_rec, l_ifac_li.percentage_value) OR l_handled;
        l_handled := set_li_val_perc_man_p(
                p_line_item_rec, l_ifac_li.percentage_value, l_ifac_li.percentage_base_amount) OR l_handled;
        l_handled := set_li_val_interest_p(
                p_line_item_rec, l_ifac_li.INT_TYPE, l_ifac_li.int_compounding_period,
                l_ifac_li.int_from_date, l_ifac_li.int_to_date, l_ifac_li.int_base_rate, 0,
                l_ifac_li.int_rate_offset, l_int_num_of_days, p_line_item_rec.line_item_key,
                l_ifac_li.int_base_amount) OR l_handled;

        RETURN l_handled;
    END;

  -----------------------------------------------------------------------
    -- Sets value to the given line item by provided ifac data.
    ----+----------------------------------+-------------------------------
    FUNCTION set_li_val_by_ifac_cargo_p(
        p_context                          IN OUT NOCOPY t_revn_doc_op_context
       ,p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
       ,p_ifac_li_index                    NUMBER
        )
    RETURN BOOLEAN
    IS
        l_ifac_li                          t_ifac_cargo_value;
        l_handled                          BOOLEAN;
        l_int_num_of_days                  cont_line_item.interest_num_days%TYPE;
        l_document_setup_id                cont_document.document_key%TYPE;
        l_price_concept_code               product_price.price_concept_code%TYPE;

    BEGIN
        l_handled := FALSE;
        l_ifac_li := p_context.get_ifac_cargo(p_ifac_li_index);
        l_document_setup_id := ec_cont_document.contract_doc_id(p_line_item_rec.document_key);
        l_int_num_of_days := ec_contract_doc_version.int_num_days(l_document_setup_id, p_line_item_rec.daytime, '<=');
        l_price_concept_code := ec_product_price.price_concept_code(l_ifac_li.li_price_object_id);

        -- handle common values for all line item types
        l_handled := set_li_val_common_p(
                p_line_item_rec, l_ifac_li.vat_code) OR l_handled;

        -- handle different line item types
        l_handled := set_li_val_qty_p(
                p_line_item_rec,
                l_ifac_li.NET_QTY1, l_ifac_li.NET_QTY2, l_ifac_li.NET_QTY3, l_ifac_li.NET_QTY4,
                l_ifac_li.uom1_code, l_ifac_li.uom2_code, l_ifac_li.uom3_code, l_ifac_li.uom4_code) OR l_handled;
        l_handled := set_li_val_free_unit_p(
                p_line_item_rec, l_ifac_li.NET_QTY1, l_ifac_li.unit_price, l_ifac_li.unit_price_unit) OR l_handled;
        l_handled := set_li_val_free_unit_po_p(
                p_line_item_rec, l_ifac_li.NET_QTY1, l_ifac_li.unit_price, l_ifac_li.unit_price_unit,
                l_ifac_li.li_price_object_id, l_price_concept_code, NULL) OR l_handled;
        l_handled := set_li_val_fixed_value_p(
                p_line_item_rec, l_ifac_li.pricing_value) OR l_handled;
        l_handled := set_li_val_perc_all_p(
                p_line_item_rec, l_ifac_li.percentage_value) OR l_handled;
        l_handled := set_li_val_perc_qty_p(
                p_line_item_rec, l_ifac_li.percentage_value) OR l_handled;
        l_handled := set_li_val_perc_man_p(
                p_line_item_rec, l_ifac_li.percentage_value, l_ifac_li.percentage_base_amount) OR l_handled;
        l_handled := set_li_val_interest_p(
                p_line_item_rec, l_ifac_li.INT_TYPE, l_ifac_li.int_compounding_period,
                l_ifac_li.int_from_date, l_ifac_li.int_to_date, l_ifac_li.int_base_rate, 0,
                l_ifac_li.int_rate_offset, l_int_num_of_days, p_line_item_rec.line_item_key,
                l_ifac_li.int_base_amount) OR l_handled;

        RETURN l_handled;
    END;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION get_main_interest_li_p(
        p_transaction_key                  cont_transaction.transaction_key%TYPE
       ,p_interest_group                   cont_line_item.interest_group%TYPE
        )
    RETURN cont_line_item%ROWTYPE
    IS
        CURSOR c_main_interest_li_key(
            cp_transaction_key             cont_transaction.transaction_key%TYPE
           ,cp_interest_group              cont_line_item.interest_group%TYPE
           )
        IS
            SELECT *
            FROM cont_line_item
            WHERE transaction_key = cp_transaction_key
                AND interest_group = cp_interest_group
                AND interest_line_item_key IS NULL;
    BEGIN
        FOR line_item IN c_main_interest_li_key(p_transaction_key, p_interest_group) LOOP
            RETURN line_item;
        END LOOP;

        RETURN NULL;
    END;


    -----------------------------------------------------------------------
    -- Deletes line item and its child records.
    -- This procedure does not maintain value consistency across the
    -- FT transaction.
    ----+----------------------------------+-------------------------------
    PROCEDURE del_ic_p(
        p_line_item_key                    cont_line_item.line_item_key%TYPE
        )
    IS
    BEGIN
        del_dist_i(p_line_item_key);
        del_uom_rec_p(p_line_item_key);
        del_li_rec_p(p_line_item_key);
    END;

    -----------------------------------------------------------------------
    -- Deletes componding (child) interest line items of a
    -- given interest line item.
    ----+----------------------------------+-------------------------------
    PROCEDURE del_componding_interests_li_p(
        p_main_line_item_key               cont_line_item.line_item_key%TYPE
        )
    IS
        l_li_interest_group                cont_line_item.interest_group%TYPE;
    BEGIN
        l_li_interest_group := ec_cont_line_item.interest_group(p_main_line_item_key);

        FOR val IN c_get_componding_interest_li(l_li_interest_group, p_main_line_item_key) LOOP
            del_ic_p(val.line_item_key);
        END LOOP;
    END;

    -----------------------------------------------------------------------
    -- Deletes the automatically genereated (by gen_li_set_free_unit_po_p)
    -- free unit price object line items.
    ----+----------------------------------+-------------------------------
    PROCEDURE del_auto_gen_freeunit_po_li_p(
        p_main_line_item_key               cont_line_item.line_item_key%TYPE
        )
    IS
    BEGIN
        FOR val IN c_get_auto_gen_freeunit_po_li(p_main_line_item_key) LOOP
            del_ic_p(val.line_item_key);
        END LOOP;
    END;

    -----------------------------------------------------------------------
    -- Deletes specified line item, with data consistency.
    ----+----------------------------------+-------------------------------
    PROCEDURE del_p(
        p_line_item_key                    cont_line_item.line_item_key%TYPE
        )
    IS
        l_transaction_key                  cont_transaction.transaction_key%TYPE;
    BEGIN
        del_componding_interests_li_p(p_line_item_key);
        del_ic_p(p_line_item_key);

        l_transaction_key := ec_cont_line_item.transaction_key(p_line_item_key);
        ecdp_transaction.UpdPercentageLineItem(l_transaction_key, 'SYSTEM');
    END;

    -----------------------------------------------------------------------
    -- Deletes specified line items, with data consistency.
    ----+----------------------------------+-------------------------------
    PROCEDURE del_p(
        p_line_item_keys                   t_table_varchar2
        )
    IS
    BEGIN
        FOR idx IN p_line_item_keys.first..p_line_item_keys.last LOOP
            del_p(p_line_item_keys(idx));
        END LOOP;
    END;

    -----------------------------------------------------------------------
    -- Generates free unit price object line item set, the set contains
    -- one line item per price element.
    ----+----------------------------------+-------------------------------
    FUNCTION gen_li_set_free_unit_po_p(
        p_based_line_item_rec              IN OUT NOCOPY cont_line_item%ROWTYPE
       ,p_user                             VARCHAR2
        )
    RETURN t_table_varchar2
    IS
        l_new_li_key                       cont_line_item.line_item_key%TYPE;
        l_new_li_keys                      t_table_varchar2;
        l_is_first                         BOOLEAN;
    BEGIN
        l_new_li_keys := t_table_varchar2();
        l_is_first := TRUE;
        del_auto_gen_freeunit_po_li_p(p_based_line_item_rec.line_item_key);

        FOR c_val IN c_get_price_element_rec(
            ec_product_price.price_concept_code(p_based_line_item_rec.price_object_id))
        LOOP
            IF l_is_first THEN
                p_based_line_item_rec.price_concept_code := c_val.price_concept_code;
                p_based_line_item_rec.price_element_code := c_val.price_element_code;
                apply_price_element_p(p_based_line_item_rec);
                l_is_first := FALSE;
            ELSE
                l_new_li_key := InsNewLineItem(
                    p_based_line_item_rec.object_id,
                    p_based_line_item_rec.daytime,
                    p_based_line_item_rec.document_key,
                    p_based_line_item_rec.transaction_key,
                    p_based_line_item_rec.line_item_template_id,
                    p_user,
                    NULL,
                    p_based_line_item_rec.line_item_type,
                    p_based_line_item_rec.line_item_based_type,
                    p_based_line_item_rec.percentage_base_amount,
                    p_based_line_item_rec.percentage_value,
                    p_based_line_item_rec.unit_price,
                    p_based_line_item_rec.unit_price_unit,
                    p_based_line_item_rec.free_unit_qty,
                    p_based_line_item_rec.pricing_value,
                    p_based_line_item_rec.description,
                    p_based_line_item_rec.price_object_id,
                    p_based_line_item_rec.price_element_code,
                    NULL,
                    NULL,
                    p_based_line_item_rec.sort_order,
                    ecdp_revn_ft_constants.c_mtd_auto_gen,
                    p_based_line_item_rec.ifac_li_conn_code);

                ecdp_revn_common.append(l_new_li_keys, l_new_li_key);
            END IF;
        END LOOP;

        RETURN l_new_li_keys;
    END;

    -----------------------------------------------------------------------
    -- A handler procedure which is called when value on a line item was
    -- updated.
    ----+----------------------------------+-------------------------------
    FUNCTION on_li_val_updated_p(
        p_context                          IN OUT NOCOPY t_revn_doc_op_context
       ,p_line_item_rec                    IN OUT NOCOPY cont_line_item%ROWTYPE
       )
    RETURN cont_line_item%ROWTYPE
    IS
        l_new_interest_group               cont_line_item.interest_group%TYPE;
        l_new_line_items                   t_table_varchar2;
        l_logger                           t_revn_logger;
    BEGIN
        p_context.get_or_create_logger(l_logger);

        CASE p_line_item_rec.line_item_based_type
/*            WHEN ecdp_revn_ft_constants.li_btype_percentage_all THEN
                fill_li_val_perc(p_line_item_rec, p_user);
            WHEN ecdp_revn_ft_constants.li_btype_percentage_qty THEN
                fill_li_val_perc(p_line_item_rec, p_user);
            WHEN ecdp_revn_ft_constants.li_btype_percentage_manual THEN
                fill_li_val_perc(p_line_item_rec, p_user);*/
            WHEN ecdp_revn_ft_constants.li_btype_free_unit_po THEN
                l_logger.debug('Free Unit with Price Object line item updated, now re-generating child line items for each price element.');
                l_new_line_items := gen_li_set_free_unit_po_p(p_line_item_rec, p_context.user_id);
                RETURN NULL;
            WHEN ecdp_revn_ft_constants.li_btype_interest THEN
                l_logger.debug('Interest line item updated, now re-generating the interest line item group ' || p_line_item_rec.interest_group || '.');
                l_new_interest_group := GenInterestLineItemSet_I(
                    p_line_item_rec.object_id, p_line_item_rec.transaction_key, p_line_item_rec.line_item_key,
                    p_line_item_rec.interest_from_date, p_line_item_rec.interest_to_date,
                    p_line_item_rec.interest_base_amount, p_line_item_rec.base_rate,
                    p_line_item_rec.interest_type, p_line_item_rec.name, p_line_item_rec.rate_offset,
                    p_line_item_rec.compounding_period, p_line_item_rec.interest_group,
                    p_line_item_rec.interest_num_days, p_context.user_id,
                    p_creation_method => p_line_item_rec.creation_method);
                DelLineItem(p_line_item_rec.object_id, p_line_item_rec.line_item_key);

                RETURN get_main_interest_li_p(p_line_item_rec.transaction_key, l_new_interest_group);
            ELSE
                RETURN NULL;
        END CASE;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    FUNCTION fill_by_ifac_i(
        p_context                          IN OUT NOCOPY t_revn_doc_op_context
       ,p_line_item_key                    cont_line_item.line_item_key%TYPE
       )
    RETURN BOOLEAN
    IS
        l_transaction_rec                  cont_transaction%ROWTYPE;
        l_transaction_qty_rec              cont_transaction_qty%ROWTYPE;
        l_transaction_version_rec          transaction_tmpl_version%ROWTYPE;
        l_line_item_rec                    cont_line_item%ROWTYPE;
        l_new_line_item_rec                cont_line_item%ROWTYPE;
        l_ifac_li_level_idx                NUMBER;
        l_ifac_pc_idxes                    t_table_number;
        l_ifac_vend_idxes                  t_table_number;
        l_all_ifac_period                  t_table_ifac_sales_qty;
        l_ifac_li_period                   t_ifac_sales_qty;
        l_all_ifac_cargo                   t_table_ifac_cargo_value;
        l_ifac_li_cargo                    t_ifac_cargo_value;
        l_all_ifac_for_li_idxes            t_table_number;
        l_value_sat                        BOOLEAN;
        l_logger                           t_revn_logger;
    BEGIN

    l_line_item_rec := ec_cont_line_item.row_by_pk(p_line_item_key);
    l_transaction_rec := ec_cont_transaction.row_by_pk(l_line_item_rec.transaction_key);

    IF (l_transaction_rec.transaction_scope = 'PERIOD_BASED') THEN
     -- validations
        IF p_context.is_empty_period_ifac_data THEN
            RETURN FALSE;
        END IF;

        p_context.get_or_create_logger(l_logger);
        l_logger.debug('Generating/updating values on line item ' || p_line_item_key || ' from interfaced value...');

        IF p_line_item_key IS NULL THEN
            RAISE ecdp_revn_ft_error.invalid_line_item_key;
        END IF;

        l_line_item_rec := ec_cont_line_item.row_by_pk(p_line_item_key);
        IF l_line_item_rec.line_item_key IS NULL THEN
            RAISE ecdp_revn_ft_error.invalid_line_item_key;
        END IF;

        assert_no_share_ref_ifac_qty_p(l_line_item_rec);

        -- prepares records
        l_transaction_rec := ec_cont_transaction.row_by_pk(l_line_item_rec.transaction_key);
        l_transaction_qty_rec := ec_cont_transaction_qty.row_by_pk(l_line_item_rec.transaction_key);
        l_transaction_version_rec := ec_transaction_tmpl_version.row_by_pk(l_transaction_rec.trans_template_id, l_transaction_rec.daytime, '<=');
        l_all_ifac_period := p_context.ifac_period;

        -- finds ifac records for the line item to process
        l_all_ifac_for_li_idxes := ecdp_revn_ifac_wrapper_period.find(
            p_ifac => l_all_ifac_period,
            p_transaction_key => l_transaction_rec.transaction_key,
            p_line_item_key => l_line_item_rec.line_item_key);
        l_ifac_li_level_idx := ecdp_revn_ifac_wrapper_period.find_one(
            p_ifac => l_all_ifac_period,
            p_range => l_all_ifac_for_li_idxes,
            p_level => ecdp_revn_ifac_wrapper.gconst_level_line_item);

        IF l_ifac_li_level_idx IS NULL THEN
            RETURN FALSE;
        END IF;

        l_ifac_pc_idxes := ecdp_revn_ifac_wrapper_period.find(
            p_ifac => l_all_ifac_period,
            p_range => l_all_ifac_for_li_idxes,
            p_level => ecdp_revn_ifac_wrapper.gconst_level_profit_center);
        l_ifac_vend_idxes := ecdp_revn_ifac_wrapper_period.find(
            p_ifac => l_all_ifac_period,
            p_range => l_all_ifac_for_li_idxes,
            p_level => ecdp_revn_ifac_wrapper.gconst_level_vendor);

        -- set line item values
        l_value_sat := set_li_val_by_ifac_period_p(p_context, l_line_item_rec, l_ifac_li_level_idx);
        IF l_value_sat THEN
            l_value_sat := apply_li_val_p(p_context, l_line_item_rec);
            l_logger.debug('Line item value updated.');
        ELSE
            l_logger.debug('No interface value found for the Line item.');
        END IF;

        -- set line item distributions
        CASE l_transaction_rec.transaction_scope
            WHEN EcDp_REVN_FT_CONSTANTS.trans_scope_period THEN
                gen_dist_f_ifac_period_p(
                    p_context, l_transaction_rec, l_transaction_qty_rec, l_transaction_version_rec,
                    l_line_item_rec, l_ifac_li_level_idx, l_ifac_pc_idxes, l_ifac_vend_idxes);

            ELSE
                RAISE ECDP_REVN_FT_ERROR.invalid_trans_scope;
        END CASE;

        l_new_line_item_rec := on_li_val_updated_p(p_context, l_line_item_rec);

        IF l_new_line_item_rec.line_item_key IS NOT NULL THEN
            -- line item has been updated to a new one
            -- need to update the ifac accordingly
            l_ifac_li_period := p_context.get_ifac_period(l_ifac_li_level_idx);
            p_context.update_ifac_keys_period(
                l_ifac_li_period.TRANS_ID, l_ifac_li_period.TRANSACTION_KEY,
                l_ifac_li_period.LI_ID, l_new_line_item_rec.line_item_key);
        END IF;

        RETURN TRUE;
        END IF;

     IF (l_transaction_rec.transaction_scope = 'CARGO_BASED') THEN
     -- validations
        IF p_context.is_empty_cargo_ifac_data THEN
            RETURN FALSE;
        END IF;

        p_context.get_or_create_logger(l_logger);
        l_logger.debug('Generating/updating values on line item ' || p_line_item_key || ' from interfaced value...');

        IF p_line_item_key IS NULL THEN
            RAISE ecdp_revn_ft_error.invalid_line_item_key;
        END IF;

        l_line_item_rec := ec_cont_line_item.row_by_pk(p_line_item_key);
        IF l_line_item_rec.line_item_key IS NULL THEN
            RAISE ecdp_revn_ft_error.invalid_line_item_key;
        END IF;

        assert_no_share_ref_ifac_qty_p(l_line_item_rec);

        -- prepares records
        l_transaction_rec := ec_cont_transaction.row_by_pk(l_line_item_rec.transaction_key);
        l_transaction_qty_rec := ec_cont_transaction_qty.row_by_pk(l_line_item_rec.transaction_key);
        l_transaction_version_rec := ec_transaction_tmpl_version.row_by_pk(l_transaction_rec.trans_template_id, l_transaction_rec.daytime, '<=');
        l_all_ifac_cargo := p_context.ifac_cargo;

        -- finds ifac records for the line item to process
        l_all_ifac_for_li_idxes := ecdp_revn_ifac_wrapper_cargo.find(
            p_ifac => l_all_ifac_cargo,
            p_transaction_key => l_transaction_rec.transaction_key,
            p_line_item_key => l_line_item_rec.line_item_key);
        l_ifac_li_level_idx := ecdp_revn_ifac_wrapper_cargo.find_one(
            p_ifac => l_all_ifac_cargo,
            p_range => l_all_ifac_for_li_idxes,
            p_level => ecdp_revn_ifac_wrapper.gconst_level_line_item);

        IF l_ifac_li_level_idx IS NULL THEN
            RETURN FALSE;
        END IF;

        l_ifac_pc_idxes := ecdp_revn_ifac_wrapper_cargo.find(
            p_ifac => l_all_ifac_cargo,
            p_range => l_all_ifac_for_li_idxes,
            p_level => ecdp_revn_ifac_wrapper.gconst_level_profit_center);
        l_ifac_vend_idxes := ecdp_revn_ifac_wrapper_cargo.find(
            p_ifac => l_all_ifac_cargo,
            p_range => l_all_ifac_for_li_idxes,
            p_level => ecdp_revn_ifac_wrapper.gconst_level_vendor);

        -- set line item values
        l_value_sat := set_li_val_by_ifac_cargo_p(p_context, l_line_item_rec, l_ifac_li_level_idx);
        IF l_value_sat THEN
            l_value_sat := apply_li_val_p(p_context, l_line_item_rec);
            l_logger.debug('Line item value updated.');
        ELSE
            l_logger.debug('No interface value found for the Line item.');
        END IF;

        -- set line item distributions
        CASE l_transaction_rec.transaction_scope
            WHEN EcDp_REVN_FT_CONSTANTS.trans_scope_cargo THEN
                gen_dist_f_ifac_cargo_p(
                    p_context, l_transaction_rec, l_transaction_qty_rec, l_transaction_version_rec,
                    l_line_item_rec, l_ifac_li_level_idx, l_ifac_pc_idxes, l_ifac_vend_idxes);
            ELSE
                RAISE ECDP_REVN_FT_ERROR.invalid_trans_scope;
        END CASE;

        l_new_line_item_rec := on_li_val_updated_p(p_context, l_line_item_rec);

        IF l_new_line_item_rec.line_item_key IS NOT NULL THEN
            -- line item has been updated to a new one
            -- need to update the ifac accordingly
            l_ifac_li_cargo := p_context.get_ifac_cargo(l_ifac_li_level_idx);
            p_context.update_ifac_keys_cargo(
                l_ifac_li_cargo.TRANS_ID, l_ifac_li_cargo.TRANSACTION_KEY,
                l_ifac_li_cargo.LI_ID, l_new_line_item_rec.line_item_key);
        END IF;

        RETURN TRUE;
        END IF;
    EXCEPTION
        WHEN ecdp_revn_ft_error.li_dist_ref_exists THEN
            ecdp_revn_ft_error.r_li_dist_ref_exists(p_line_item_key);


    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    PROCEDURE sync_dist_from_qty_i(
        p_transaction_key                  cont_transaction.transaction_key%TYPE
        )
    IS
        l_qty_li_key                       cont_line_item.line_item_key%TYPE;
        l_li_dist_rec                      cont_line_item_dist%ROWTYPE;
        l_li_dist_company_rec              cont_li_dist_company%ROWTYPE;
        l_qty_li_dists                     t_table_li_pc_dist;
        l_qty_li_company_dists             t_table_li_company_dist;
    BEGIN
        l_qty_li_key := get_first_qty_li_key(p_transaction_key);
        get_pc_dists(l_qty_li_dists, p_transaction_key, l_qty_li_key);

        FOR key IN c_keys_of_dist_method(p_transaction_key, ecdp_revn_ft_constants.li_dist_mtd_qty_li) LOOP
            IF l_qty_li_dists IS NOT NULL THEN
                FOR pc_dist_idx IN l_qty_li_dists.first..l_qty_li_dists.last LOOP
                    l_li_dist_rec := ec_cont_line_item_dist.row_by_pk(
                        key.line_item_key,
                        l_qty_li_dists(pc_dist_idx).dist_id,
                        l_qty_li_dists(pc_dist_idx).stream_item_id);
                    set_li_dist_pc_from_li_p(l_li_dist_rec, l_qty_li_dists(pc_dist_idx), TRUE);
                    apply_shares_p(l_li_dist_rec);

                    get_company_dists(l_qty_li_company_dists, p_transaction_key, l_qty_li_key, l_qty_li_dists(pc_dist_idx).dist_id);

                    FOR comp_dist_idx IN l_qty_li_company_dists.first..l_qty_li_company_dists.last LOOP
                        l_li_dist_company_rec := ec_cont_li_dist_company.row_by_pk(
                            key.line_item_key,
                            l_qty_li_company_dists(comp_dist_idx).dist_id,
                            l_qty_li_company_dists(comp_dist_idx).vendor_id,
                            l_qty_li_company_dists(comp_dist_idx).customer_id,
                            l_qty_li_company_dists(comp_dist_idx).stream_item_id);
                        set_li_dist_comp_from_li_p(l_li_dist_company_rec, l_qty_li_company_dists(comp_dist_idx), FALSE);
                        apply_shares_p(l_li_dist_company_rec);
                    END LOOP;
                END LOOP;
            END IF;
        END LOOP;
    END;


------------------------+-----------------------------------+------------------------------------+---------------------------
-- Generates profit center distribution for reduced configured line items with
-- stream item enabled. Existing distributions will not be deleted or overwritten.u
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE gen_dist_party_f_conf_field(p_line_item_key VARCHAR2,
                               p_customer_id   VARCHAR2,
                               p_user          VARCHAR2,
                               p_uom_code      VARCHAR2 DEFAULT NULL)
IS

    lv2_override_customer_id       VARCHAR2(32);

    lrec_cont_line_item            CONT_LINE_ITEM%ROWTYPE;
    lrec_cont_transaction          CONT_TRANSACTION%ROWTYPE;
    lt_pc_dist_info                ECDP_TRANSACTION.T_TABLE_PC_DIST_INFO;
    lt_company_dist_info           ECDP_TRANSACTION.T_TABLE_COMPANY_DIST_INFO;
    lo_current_pc_dist_info        ECDP_TRANSACTION.T_PC_DIST_INFO;
    lo_current_company_dist_info   ECDP_TRANSACTION.T_COMPANY_DIST_INFO;
    lo_get_dist_info_param         ECDP_TRANSACTION.T_PARAM_GetDistInfoRC;

BEGIN
    lrec_cont_line_item := ec_cont_line_item.row_by_pk(p_line_item_key);
    lrec_cont_transaction := ec_cont_transaction.row_by_pk(lrec_cont_line_item.transaction_key);

    lo_get_dist_info_param := ECDP_TRANSACTION.GenParam_GetDistInfoRC(
                                lrec_cont_transaction
                               ,p_uom_code);

    lt_pc_dist_info := ECDP_TRANSACTION.GetDistInfoRC_ProfitCenter(
                                lo_get_dist_info_param
                               ,FALSE
                               );

    IF lt_pc_dist_info.COUNT > 0
    THEN
        IF (p_customer_id IS NULL OR UPPER(p_customer_id) = 'NULL') THEN
            lv2_override_customer_id := ecdp_contract_setup.GetDocCustomerId(lrec_cont_line_item.document_key);
            IF lv2_override_customer_id IS NULL THEN
              SELECT MAX(company_id) INTO lv2_override_customer_id
                FROM contract_party_share cps
               WHERE object_id = lrec_cont_line_item.Object_Id
                 AND party_role = 'CUSTOMER'
                 AND cps.daytime <= lrec_cont_line_item.daytime
                 AND nvl(END_DATE,lrec_cont_line_item.daytime+1)>lrec_cont_line_item.daytime;

            END IF;
        ELSE
            lv2_override_customer_id := p_customer_id;
        END IF;

        FOR i_pc_dist IN lt_pc_dist_info.FIRST .. lt_pc_dist_info.LAST
        LOOP
            lo_current_pc_dist_info := lt_pc_dist_info(i_pc_dist);

            INSERT INTO cont_line_item_dist(
                 object_id
                ,line_item_key
                ,document_key
                ,transaction_key
                ,STREAM_ITEM_ID
                ,DIST_ID
                ,NODE_ID
                ,NAME
                ,description
                ,value_adjustment
                ,PRICE_CONCEPT_CODE
                ,PRICE_ELEMENT_CODE
                ,LINE_ITEM_TYPE
                ,STIM_VALUE_CATEGORY_CODE
                ,SORT_ORDER
                ,REPORT_CATEGORY_CODE
                ,MOVE_QTY_TO_VO_IND
                ,CONTRIBUTION_FACTOR
                ,UOM1_CODE
                ,UOM2_CODE
                ,UOM3_CODE
                ,UOM4_CODE
                ,SPLIT_SHARE
                ,DAYTIME
                ,LINE_ITEM_BASED_TYPE
                ,VAT_CODE
                ,VAT_RATE
                ,JV_BILLABLE
                ,created_by
                ,created_date
                ,record_status
                )
                SELECT
                     object_id
                    ,line_item_key
                    ,document_key
                    ,transaction_key
                    ,lo_current_pc_dist_info.STREAM_ITEM_ID -- take to_object from split key
                    ,lo_current_pc_dist_info.PROFIT_CENTER_ID
                    ,DECODE(ec_stream_item_version.value_point(lo_current_pc_dist_info.STREAM_ITEM_ID, lrec_cont_line_item.daytime, '<='),'TO_NODE'
                          ,ec_strm_version.to_node_id(ec_stream_item.stream_id(lo_current_pc_dist_info.STREAM_ITEM_ID), lrec_cont_line_item.daytime, '<=')
                          ,'FROM_NODE'
                          ,ec_strm_version.from_node_id(ec_stream_item.stream_id(lo_current_pc_dist_info.STREAM_ITEM_ID), lrec_cont_line_item.daytime, '<=')
                          ,NULL)
                    ,NAME
                    ,description
                    ,value_adjustment
                    ,PRICE_CONCEPT_CODE
                    ,PRICE_ELEMENT_CODE
                    ,LINE_ITEM_TYPE
                    ,STIM_VALUE_CATEGORY_CODE
                    ,SORT_ORDER
                    ,REPORT_CATEGORY_CODE
                    ,MOVE_QTY_TO_VO_IND
                    ,CONTRIBUTION_FACTOR
                    ,UOM1_CODE
                    ,UOM2_CODE
                    ,UOM3_CODE
                    ,UOM4_CODE
                    ,lo_current_pc_dist_info.PROFIT_CENTER_SHARE -- pick share
                    ,lrec_cont_line_item.daytime
                    ,LINE_ITEM_BASED_TYPE
                    ,VAT_CODE
                    ,VAT_RATE
                    ,decode(ec_contract_version.bank_details_level_code(lrec_cont_line_item.object_id, lrec_cont_line_item.daytime, '<='),'JV_BILLABLE','JV_BILLABLE',null)
                    ,created_by
                    ,created_date
                    ,'P'
                FROM cont_line_item cli
                WHERE cli.line_item_key = p_line_item_key
                    AND NOT EXISTS (SELECT 'X'
                                    FROM cont_line_item_dist clid
                                   WHERE clid.line_item_key = cli.line_item_key
                                     AND clid.dist_id = lo_current_pc_dist_info.PROFIT_CENTER_ID);

            IF (ec_cont_transaction.dist_split_type(lrec_cont_line_item.transaction_key) = 'SOURCE_SPLIT'
                AND lrec_cont_transaction.transaction_date IS NOT NULL)
            THEN
                Ecdp_Transaction.UpdTransSourceSplitShare(
                                     lrec_cont_line_item.transaction_key
                                    ,ec_cont_transaction_qty.net_qty1(lrec_cont_line_item.transaction_key)
                                    ,ec_cont_transaction_qty.uom1_code(lrec_cont_line_item.transaction_key)
                                    ,lrec_cont_transaction.transaction_date
                                    );
            END IF;

            lt_company_dist_info := ECDP_TRANSACTION.GetDistInfoRC_Company(
                                         lo_get_dist_info_param
                                        ,lo_current_pc_dist_info.PROFIT_CENTER_ID
                                        ,FALSE
                                        );

            IF lt_company_dist_info.COUNT > 0
            THEN
                FOR i_company_dist IN lt_company_dist_info.FIRST .. lt_company_dist_info.LAST
                LOOP
                    lo_current_company_dist_info := lt_company_dist_info(i_company_dist);

                    INSERT INTO cont_li_dist_company(
                         object_id
                        ,line_item_key
                        ,daytime
                        ,stream_item_id
                        ,dist_id
                        ,document_key
                        ,transaction_key
                        ,node_id
                        ,NAME
                        ,description
                        ,vendor_id
                        ,vendor_share
                        ,customer_id
                        ,customer_share
                        ,split_share
                        ,sort_order
                        ,report_category_code
                        ,value_adjustment
                        ,uom1_code
                        ,uom2_code
                        ,uom3_code
                        ,uom4_code
                        ,price_concept_code
                        ,price_element_code
                        ,stim_value_category_code
                        ,line_item_type
                        ,line_item_based_type
                        ,company_stream_item_id
                        ,move_qty_to_vo_ind)
                        SELECT
                             d.Object_id
                            ,d.Line_item_key
                            ,d.Daytime
                            ,d.stream_item_id
                            ,d.dist_id
                            ,d.document_key
                            ,d.transaction_key
                            ,d.node_id
                            ,''
                            ,''
                            ,lo_current_company_dist_info.vendor_id
                            ,lo_current_company_dist_info.vendor_share
                            ,NVL(lv2_override_customer_id, lo_current_company_dist_info.CUSTOMER_ID)
                            ,lo_current_company_dist_info.customer_share
                            ,lo_current_company_dist_info.vendor_share * lo_current_company_dist_info.customer_share
                            ,d.sort_order
                            ,d.report_category_code
                            ,d.value_adjustment
                            ,d.uom1_code
                            ,d.uom2_code
                            ,d.uom3_code
                            ,d.uom4_code
                            ,d.price_concept_code
                            ,d.price_element_code
                            ,d.stim_value_category_code
                            ,d.line_item_type
                            ,d.line_item_based_type
                            ,lo_current_company_dist_info.STREAM_ITEM_ID
                            ,d.move_qty_to_vo_ind
                        FROM cont_line_item_dist d
                        WHERE line_item_key = p_line_item_key
                            AND d.dist_id = lo_current_pc_dist_info.PROFIT_CENTER_ID
                            AND NOT EXISTS (SELECT 'X'
                                               FROM cont_li_dist_company clidc
                                              WHERE clidc.line_item_key = d.line_item_key
                                                AND clidc.dist_id = d.dist_id
                                                AND clidc.vendor_id = lo_current_company_dist_info.vendor_id
                                                AND clidc.customer_id = NVL(lv2_override_customer_id, lo_current_company_dist_info.CUSTOMER_ID));
                END LOOP;
            END IF;
        END LOOP;
    END IF;

END gen_dist_party_f_conf_field;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Generates profit center distribution for reduced configured line items with
-- stream item disabled. Existing distributions will not be deleted or overwritten.
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE gen_dist_party_f_conf_pc(p_line_item_key VARCHAR2,
                               p_customer_id   VARCHAR2,
                               p_user          VARCHAR2,
                               p_uom_code      VARCHAR2 DEFAULT NULL)
IS



    lv2_override_customer_id       VARCHAR2(32);

    lrec_cont_line_item            CONT_LINE_ITEM%ROWTYPE;
    lrec_cont_transaction          CONT_TRANSACTION%ROWTYPE;
    lt_pc_dist_info                ECDP_TRANSACTION.T_TABLE_PC_DIST_INFO;
    lt_company_dist_info           ECDP_TRANSACTION.T_TABLE_COMPANY_DIST_INFO;
    lo_current_pc_dist_info        ECDP_TRANSACTION.T_PC_DIST_INFO;
    lo_current_company_dist_info   ECDP_TRANSACTION.T_COMPANY_DIST_INFO;
    lo_get_dist_info_param         ECDP_TRANSACTION.T_PARAM_GetDistInfoRC;
    lt_pc_id_info                  ECDP_TRANSACTION.T_TABLE_PROFIT_CENTRE_ID;
    lt_vendor_dist_info            ECDP_TRANSACTION.T_TABLE_PC_VENDOR_ID;

    lrec_ttv                       transaction_tmpl_version%ROWTYPE;
    lrec_sks                       split_key_setup%ROWTYPE;


    lv2_stream_item_id      VARCHAR2(32);
    lv2_company_stream_item_id      VARCHAR2(32);
    lv2_use_si_ind          VARCHAR2(32);
    lv2_node_id             VARCHAR2(32);
    lv2_profit_centre_id    VARCHAR2(32);
    lv2_dist_object_id      VARCHAR2(32);
    lv2_pc_split_share      NUMBER;
    lv2_company_share       NUMBER;
    lv2_contract_id         VARCHAR2(32);
    lv2_daytime             DATE;
    lv2_Financial_code      VARCHAR2(32);

    e_no_records            EXCEPTION;
    lv_exception_text       VARCHAR2(1000);

BEGIN

    lrec_cont_line_item := ec_cont_line_item.row_by_pk(p_line_item_key);
    lrec_cont_transaction := ec_cont_transaction.row_by_pk(lrec_cont_line_item.transaction_key);
    lv2_Financial_code := ec_cont_document.financial_code(lrec_cont_transaction.document_key);
    lrec_ttv := ec_transaction_tmpl_version.row_by_pk(lrec_cont_transaction.trans_template_id, lrec_cont_transaction.daytime, '<=');
    lv2_contract_id := ec_contract_doc.contract_id(ec_transaction_template.contract_doc_id(lrec_ttv.object_id));

    IF (p_customer_id IS NULL OR UPPER(p_customer_id) = 'NULL') THEN
            lv2_override_customer_id := ecdp_contract_setup.GetDocCustomerId(lrec_cont_line_item.document_key);
            IF lv2_override_customer_id IS NULL THEN
              SELECT company_id INTO lv2_override_customer_id
                FROM contract_party_share cps
               WHERE object_id = lrec_cont_line_item.Object_Id
                 AND party_role = 'CUSTOMER'
                 AND cps.daytime <= lrec_cont_line_item.daytime
                 AND nvl(END_DATE,lrec_cont_line_item.daytime+1)>lrec_cont_line_item.daytime;

            END IF;
    ELSE
            lv2_override_customer_id := p_customer_id;
    END IF;

    lv2_company_share:=1;




    IF UPPER(lrec_ttv.dist_type) = 'OBJECT_LIST' THEN

      lt_pc_id_info:=ECDP_TRANSACTION.GetPCInfoRC(lrec_ttv.dist_code,'OBJECT_LIST',lrec_ttv.dist_object_type, lrec_cont_transaction.daytime);

      IF lt_pc_id_info.count = 0 THEN
        lv_exception_text := 'No valid objects for document date '
                                ||  lrec_cont_transaction.daytime
                                || ' in the defined object list. Please adjust configuration.' || CHR(10);
        RAISE e_no_records;
      END IF;

      FOR pc_dist IN lt_pc_id_info.FIRST..lt_pc_id_info.LAST
        LOOP

        INSERT INTO cont_line_item_dist(
                 object_id
                ,line_item_key
                ,document_key
                ,transaction_key
                ,STREAM_ITEM_ID
                ,DIST_ID
                ,NODE_ID
                ,NAME
                ,description
                ,value_adjustment
                ,PRICE_CONCEPT_CODE
                ,PRICE_ELEMENT_CODE
                ,LINE_ITEM_TYPE
                ,STIM_VALUE_CATEGORY_CODE
                ,SORT_ORDER
                ,REPORT_CATEGORY_CODE
                ,MOVE_QTY_TO_VO_IND
                ,CONTRIBUTION_FACTOR
                ,UOM1_CODE
                ,UOM2_CODE
                ,UOM3_CODE
                ,UOM4_CODE
                ,SPLIT_SHARE
                ,DAYTIME
                ,LINE_ITEM_BASED_TYPE
                ,VAT_CODE
                ,VAT_RATE
                ,JV_BILLABLE
                ,created_by
                ,created_date
                ,record_status
                ,profit_centre_id
                )
                SELECT
                     object_id
                    ,line_item_key
                    ,document_key
                    ,transaction_key
                    ,lt_pc_id_info(pc_dist).PROFIT_CENTRE_ID
                    ,lt_pc_id_info(pc_dist).PROFIT_CENTRE_ID
                    ,NULL
                    ,NAME
                    ,description
                    ,value_adjustment
                    ,PRICE_CONCEPT_CODE
                    ,PRICE_ELEMENT_CODE
                    ,LINE_ITEM_TYPE
                    ,STIM_VALUE_CATEGORY_CODE
                    ,SORT_ORDER
                    ,REPORT_CATEGORY_CODE
                    ,MOVE_QTY_TO_VO_IND
                    ,CONTRIBUTION_FACTOR
                    ,UOM1_CODE
                    ,UOM2_CODE
                    ,UOM3_CODE
                    ,UOM4_CODE
                    ,lt_pc_id_info(pc_dist).split_share
                    ,lrec_cont_line_item.daytime
                    ,LINE_ITEM_BASED_TYPE
                    ,VAT_CODE
                    ,VAT_RATE
                    ,decode(ec_contract_version.bank_details_level_code(lrec_cont_line_item.object_id, lrec_cont_line_item.daytime, '<='),'JV_BILLABLE','JV_BILLABLE',null)
                    ,created_by
                    ,created_date
                    ,'P'
                    ,lt_pc_id_info(pc_dist).PROFIT_CENTRE_ID
                FROM cont_line_item cli
                WHERE cli.line_item_key = p_line_item_key
                    AND NOT EXISTS (SELECT 'X'
                                    FROM cont_line_item_dist clid
                                   WHERE clid.line_item_key = cli.line_item_key
                                     AND clid.dist_id =lt_pc_id_info(pc_dist).PROFIT_CENTRE_ID);



      IF (ec_cont_transaction.dist_split_type(lrec_cont_line_item.transaction_key) = 'SOURCE_SPLIT'
                                              AND lrec_cont_transaction.transaction_date IS NOT NULL)
      THEN
                Ecdp_Transaction.UpdTransSourceSplitShare(
                                     lrec_cont_line_item.transaction_key
                                    ,ec_cont_transaction_qty.net_qty1(lrec_cont_line_item.transaction_key)
                                    ,ec_cont_transaction_qty.uom1_code(lrec_cont_line_item.transaction_key)
                                    ,lrec_cont_transaction.transaction_date
                                    );
            END IF;
       lt_vendor_dist_info:=ECDP_TRANSACTION.GetPCInfoRC_Vendor(lv2_contract_id,lrec_cont_transaction.daytime);
       FOR i_company_dist IN lt_vendor_dist_info.FIRST..lt_vendor_dist_info.LAST
         LOOP
               IF lv2_Financial_code in ('PURCHASE','TA_COST') THEN
                  lv2_company_stream_item_id := lv2_override_customer_id;
               ELSE
                  lv2_company_stream_item_id := lt_vendor_dist_info(i_company_dist).company_id;
               END IF;

                    INSERT INTO cont_li_dist_company(
                         object_id
                        ,line_item_key
                        ,daytime
                        ,stream_item_id
                        ,dist_id
                        ,document_key
                        ,transaction_key
                        ,node_id
                        ,NAME
                        ,description
                        ,vendor_id
                        ,vendor_share
                        ,customer_id
                        ,customer_share
                        ,split_share
                        ,sort_order
                        ,report_category_code
                        ,value_adjustment
                        ,uom1_code
                        ,uom2_code
                        ,uom3_code
                        ,uom4_code
                        ,price_concept_code
                        ,price_element_code
                        ,stim_value_category_code
                        ,line_item_type
                        ,line_item_based_type
                        ,company_stream_item_id
                        ,move_qty_to_vo_ind
                        ,profit_centre_id)
                        SELECT
                             d.Object_id
                            ,d.Line_item_key
                            ,d.Daytime
                            ,d.stream_item_id
                            ,d.dist_id
                            ,d.document_key
                            ,d.transaction_key
                            ,d.node_id
                            ,''
                            ,''
                            ,lt_vendor_dist_info(i_company_dist).company_id
                            ,lt_vendor_dist_info(i_company_dist).party_share / 100
                            ,lv2_override_customer_id
                            ,lv2_company_share
                            ,(lt_vendor_dist_info(i_company_dist).party_share / 100) * lv2_company_share
                            ,d.sort_order
                            ,d.report_category_code
                            ,d.value_adjustment
                            ,d.uom1_code
                            ,d.uom2_code
                            ,d.uom3_code
                            ,d.uom4_code
                            ,d.price_concept_code
                            ,d.price_element_code
                            ,d.stim_value_category_code
                            ,d.line_item_type
                            ,d.line_item_based_type
                            ,lv2_company_stream_item_id
                            ,d.move_qty_to_vo_ind
                            ,d.profit_centre_id
                        FROM cont_line_item_dist d
                        WHERE line_item_key = p_line_item_key
                            AND d.dist_id = lt_pc_id_info(pc_dist).PROFIT_CENTRE_ID
                            AND NOT EXISTS (SELECT 'X'
                                               FROM cont_li_dist_company clidc
                                              WHERE clidc.line_item_key = d.line_item_key
                                                AND clidc.dist_id = d.dist_id
                                                AND clidc.vendor_id = lt_vendor_dist_info(i_company_dist).company_id
                                                AND clidc.customer_id = NVL(lv2_override_customer_id, lo_current_company_dist_info.CUSTOMER_ID));
                END LOOP;

      END LOOP;

    END IF;

    IF UPPER(lrec_ttv.dist_type) = 'OBJECT' THEN

      SELECT object_id INTO lv2_profit_centre_id FROM iv_profit_centre WHERE code = lrec_ttv.dist_code  and lrec_ttv.dist_object_type = class_name;
        INSERT INTO cont_line_item_dist(
                 object_id
                ,line_item_key
                ,document_key
                ,transaction_key
                ,STREAM_ITEM_ID
                ,DIST_ID
                ,NODE_ID
                ,NAME
                ,description
                ,value_adjustment
                ,PRICE_CONCEPT_CODE
                ,PRICE_ELEMENT_CODE
                ,LINE_ITEM_TYPE
                ,STIM_VALUE_CATEGORY_CODE
                ,SORT_ORDER
                ,REPORT_CATEGORY_CODE
                ,MOVE_QTY_TO_VO_IND
                ,CONTRIBUTION_FACTOR
                ,UOM1_CODE
                ,UOM2_CODE
                ,UOM3_CODE
                ,UOM4_CODE
                ,SPLIT_SHARE
                ,DAYTIME
                ,LINE_ITEM_BASED_TYPE
                ,VAT_CODE
                ,VAT_RATE
                ,JV_BILLABLE
                ,created_by
                ,created_date
                ,record_status
                ,profit_centre_id
                )
                SELECT
                     object_id
                    ,line_item_key
                    ,document_key
                    ,transaction_key
                    ,lv2_profit_centre_id
                    ,lv2_profit_centre_id
                    ,NULL
                    ,NAME
                    ,description
                    ,value_adjustment
                    ,PRICE_CONCEPT_CODE
                    ,PRICE_ELEMENT_CODE
                    ,LINE_ITEM_TYPE
                    ,STIM_VALUE_CATEGORY_CODE
                    ,SORT_ORDER
                    ,REPORT_CATEGORY_CODE
                    ,MOVE_QTY_TO_VO_IND
                    ,CONTRIBUTION_FACTOR
                    ,UOM1_CODE
                    ,UOM2_CODE
                    ,UOM3_CODE
                    ,UOM4_CODE
                    ,1
                    ,lrec_cont_line_item.daytime
                    ,LINE_ITEM_BASED_TYPE
                    ,VAT_CODE
                    ,VAT_RATE
                    ,decode(ec_contract_version.bank_details_level_code(lrec_cont_line_item.object_id, lrec_cont_line_item.daytime, '<='),'JV_BILLABLE','JV_BILLABLE',null)
                    ,created_by
                    ,created_date
                    ,'P'
                    ,lv2_profit_centre_id
                FROM cont_line_item cli
                WHERE cli.line_item_key = p_line_item_key
                    AND NOT EXISTS (SELECT 'X'
                                    FROM cont_line_item_dist clid
                                   WHERE clid.line_item_key = cli.line_item_key
                                     AND clid.dist_id = lv2_profit_centre_id);

      IF (ec_cont_transaction.dist_split_type(lrec_cont_line_item.transaction_key) = 'SOURCE_SPLIT'
                AND lrec_cont_transaction.transaction_date IS NOT NULL) THEN

                Ecdp_Transaction.UpdTransSourceSplitShare(
                                     lrec_cont_line_item.transaction_key
                                    ,ec_cont_transaction_qty.net_qty1(lrec_cont_line_item.transaction_key)
                                    ,ec_cont_transaction_qty.uom1_code(lrec_cont_line_item.transaction_key)
                                    ,lrec_cont_transaction.transaction_date
                                    );
      END IF;

      lt_vendor_dist_info:=ECDP_TRANSACTION.GetPCInfoRC_Vendor(lv2_contract_id,Ecdp_Timestamp.getCurrentSysdate);
       FOR i_company_dist IN lt_vendor_dist_info.FIRST..lt_vendor_dist_info.LAST
         LOOP

               IF lv2_Financial_code in ('PURCHASE','TA_COST') THEN
                  lv2_company_stream_item_id := lv2_override_customer_id;
               ELSE
                  lv2_company_stream_item_id := lt_vendor_dist_info(i_company_dist).company_id;
               END IF;

                      INSERT INTO cont_li_dist_company(
                         object_id
                        ,line_item_key
                        ,daytime
                        ,stream_item_id
                        ,dist_id
                        ,document_key
                        ,transaction_key
                        ,node_id
                        ,NAME
                        ,description
                        ,vendor_id
                        ,vendor_share
                        ,customer_id
                        ,customer_share
                        ,split_share
                        ,sort_order
                        ,report_category_code
                        ,value_adjustment
                        ,uom1_code
                        ,uom2_code
                        ,uom3_code
                        ,uom4_code
                        ,price_concept_code
                        ,price_element_code
                        ,stim_value_category_code
                        ,line_item_type
                        ,line_item_based_type
                        ,company_stream_item_id
                        ,move_qty_to_vo_ind
                        ,profit_centre_id)
                        SELECT
                             d.Object_id
                            ,d.Line_item_key
                            ,d.Daytime
                            ,d.stream_item_id
                            ,d.dist_id
                            ,d.document_key
                            ,d.transaction_key
                            ,d.node_id
                            ,''
                            ,''
                            ,lt_vendor_dist_info(i_company_dist).company_id
                            ,lt_vendor_dist_info(i_company_dist).party_share / 100
                            ,lv2_override_customer_id
                            ,lv2_company_share
                            ,(lt_vendor_dist_info(i_company_dist).party_share / 100) * lv2_company_share
                            ,d.sort_order
                            ,d.report_category_code
                            ,d.value_adjustment
                            ,d.uom1_code
                            ,d.uom2_code
                            ,d.uom3_code
                            ,d.uom4_code
                            ,d.price_concept_code
                            ,d.price_element_code
                            ,d.stim_value_category_code
                            ,d.line_item_type
                            ,d.line_item_based_type
                            ,lv2_company_stream_item_id
                            ,d.move_qty_to_vo_ind
                            ,d.profit_centre_id
                        FROM cont_line_item_dist d
                        WHERE line_item_key = p_line_item_key
                            AND d.dist_id = lv2_profit_centre_id
                            AND NOT EXISTS (SELECT 'X'
                                               FROM cont_li_dist_company clidc
                                              WHERE clidc.line_item_key = d.line_item_key
                                                AND clidc.dist_id = d.dist_id
                                                AND clidc.vendor_id = lt_vendor_dist_info(i_company_dist).company_id
                                                AND clidc.customer_id = lv2_override_customer_id);
                END LOOP;

    END IF;

EXCEPTION
   WHEN e_no_records THEN
        Raise_Application_Error(-20000,lv_exception_text);

   WHEN OTHERS THEN
        Raise_Application_Error(-20000, 'There was an error performing the requested operation ' || SQLCODE || ' '|| SUBSTR(SQLERRM, 1, 240) );

END gen_dist_party_f_conf_pc;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Generates profit center distribution for reduced configured line items.
-- Existing distributions will not be deleted or overwritten.
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE gen_dist_party_f_given(p_line_item_key VARCHAR2,
                               p_customer_id       VARCHAR2,
                               p_user              VARCHAR2,
                               p_uom_code          VARCHAR2 DEFAULT NULL,
                               p_profit_centre_id  VARCHAR2,
                               p_daytime           DATE)
IS


    lv2_override_customer_id       VARCHAR2(32);

    lrec_cont_line_item            CONT_LINE_ITEM%ROWTYPE;
    lrec_cont_transaction          CONT_TRANSACTION%ROWTYPE;
    lt_pc_dist_info                ECDP_TRANSACTION.T_TABLE_PC_DIST_INFO;
    lt_company_dist_info           ECDP_TRANSACTION.T_TABLE_COMPANY_DIST_INFO;
    lo_current_pc_dist_info        ECDP_TRANSACTION.T_PC_DIST_INFO;
    lo_current_company_dist_info   ECDP_TRANSACTION.T_COMPANY_DIST_INFO;
    lo_get_dist_info_param         ECDP_TRANSACTION.T_PARAM_GetDistInfoRC;
    lrec_ttv                       transaction_tmpl_version%ROWTYPE;
    lrec_sks                       split_key_setup%ROWTYPE;
    lt_vendor_dist_info            ECDP_TRANSACTION.T_TABLE_PC_VENDOR_ID;


    lv2_stream_item_id      VARCHAR2(32);
    lv2_company_stream_item_id      VARCHAR2(32);
    lv2_use_si_ind          VARCHAR2(32);
    lv2_node_id             VARCHAR2(32);
    lv2_profit_centre_id    VARCHAR2(32);
    lv2_dist_object_id      VARCHAR2(32);
    lv2_contract_id         VARCHAR2(32);
    lv2_company_share       NUMBER;
    lv2_Financial_code      VARCHAR2(32);

BEGIN
    lrec_cont_line_item := ec_cont_line_item.row_by_pk(p_line_item_key);
    lrec_cont_transaction := ec_cont_transaction.row_by_pk(lrec_cont_line_item.transaction_key);
    lv2_Financial_code := ec_cont_document.financial_code(lrec_cont_transaction.document_key);
    lrec_ttv := ec_transaction_tmpl_version.row_by_pk(lrec_cont_transaction.trans_template_id, lrec_cont_transaction.daytime, '<=');
    lv2_contract_id := ec_contract_doc.contract_id(ec_transaction_template.contract_doc_id(lrec_ttv.object_id));

    IF (p_customer_id IS NULL OR UPPER(p_customer_id) = 'NULL') THEN
            lv2_override_customer_id := ecdp_contract_setup.GetDocCustomerId(lrec_cont_line_item.document_key);
    ELSE
            lv2_override_customer_id := p_customer_id;
    END IF;

    -- Calculating customer share
    SELECT (1 / count(company_id))
      INTO lv2_company_share
      FROM contract_party_share
     WHERE object_id = lv2_contract_id
       AND party_role = 'CUSTOMER'
       AND daytime <= p_daytime
       AND nvl(end_date,p_daytime+1) > p_daytime;

            INSERT INTO cont_line_item_dist(
                 object_id
                ,line_item_key
                ,document_key
                ,transaction_key
                ,STREAM_ITEM_ID
                ,DIST_ID
                ,NODE_ID
                ,NAME
                ,description
                ,value_adjustment
                ,PRICE_CONCEPT_CODE
                ,PRICE_ELEMENT_CODE
                ,LINE_ITEM_TYPE
                ,STIM_VALUE_CATEGORY_CODE
                ,SORT_ORDER
                ,REPORT_CATEGORY_CODE
                ,MOVE_QTY_TO_VO_IND
                ,CONTRIBUTION_FACTOR
                ,UOM1_CODE
                ,UOM2_CODE
                ,UOM3_CODE
                ,UOM4_CODE
                ,SPLIT_SHARE
                ,DAYTIME
                ,LINE_ITEM_BASED_TYPE
                ,VAT_CODE
                ,VAT_RATE
                ,JV_BILLABLE
                ,created_by
                ,created_date
                ,record_status
                ,profit_centre_id
                )
                SELECT
                     object_id
                    ,line_item_key
                    ,document_key
                    ,transaction_key
                    ,p_profit_centre_id
                    ,p_profit_centre_id
                    ,NULL
                    ,NAME
                    ,description
                    ,value_adjustment
                    ,PRICE_CONCEPT_CODE
                    ,PRICE_ELEMENT_CODE
                    ,LINE_ITEM_TYPE
                    ,STIM_VALUE_CATEGORY_CODE
                    ,SORT_ORDER
                    ,REPORT_CATEGORY_CODE
                    ,MOVE_QTY_TO_VO_IND
                    ,CONTRIBUTION_FACTOR
                    ,UOM1_CODE
                    ,UOM2_CODE
                    ,UOM3_CODE
                    ,UOM4_CODE
                    ,NULL
                    ,lrec_cont_line_item.daytime
                    ,LINE_ITEM_BASED_TYPE
                    ,VAT_CODE
                    ,VAT_RATE
                    ,decode(ec_contract_version.bank_details_level_code(lrec_cont_line_item.object_id, lrec_cont_line_item.daytime, '<='),'JV_BILLABLE','JV_BILLABLE',null)
                    ,created_by
                    ,created_date
                    ,'P'
                    ,p_profit_centre_id
                FROM cont_line_item cli
                WHERE cli.line_item_key = p_line_item_key
                    AND NOT EXISTS (SELECT 'X'
                                    FROM cont_line_item_dist clid
                                   WHERE clid.line_item_key = cli.line_item_key
                                     AND clid.dist_id = p_profit_centre_id);


            IF (ec_cont_transaction.dist_split_type(lrec_cont_line_item.transaction_key) = 'SOURCE_SPLIT'
                AND lrec_cont_transaction.transaction_date IS NOT NULL)
            THEN
                Ecdp_Transaction.UpdTransSourceSplitShare(
                                     lrec_cont_line_item.transaction_key
                                    ,ec_cont_transaction_qty.net_qty1(lrec_cont_line_item.transaction_key)
                                    ,ec_cont_transaction_qty.uom1_code(lrec_cont_line_item.transaction_key)
                                    ,lrec_cont_transaction.transaction_date
                                    );
            END IF;

            lt_vendor_dist_info:=ECDP_TRANSACTION.GetPCInfoRC_Vendor(lv2_contract_id,P_daytime);
            FOR i_company_dist IN lt_vendor_dist_info.FIRST..lt_vendor_dist_info.LAST
              LOOP
               IF lv2_Financial_code in ('PURCHASE','TA_COST') THEN
                  lv2_company_stream_item_id := lv2_override_customer_id;
               ELSE
                  lv2_company_stream_item_id := lt_vendor_dist_info(i_company_dist).company_id;
               END IF;

                    INSERT INTO cont_li_dist_company(
                         object_id
                        ,line_item_key
                        ,daytime
                        ,stream_item_id
                        ,company_stream_item_id
                        ,dist_id
                        ,document_key
                        ,transaction_key
                        ,node_id
                        ,NAME
                        ,description
                        ,vendor_id
                        ,vendor_share
                        ,customer_id
                        ,customer_share
                        ,split_share
                        ,sort_order
                        ,report_category_code
                        ,value_adjustment
                        ,uom1_code
                        ,uom2_code
                        ,uom3_code
                        ,uom4_code
                        ,price_concept_code
                        ,price_element_code
                        ,stim_value_category_code
                        ,line_item_type
                        ,line_item_based_type
                        ,move_qty_to_vo_ind
                        ,profit_centre_id)
                        SELECT
                             d.Object_id
                            ,d.Line_item_key
                            ,d.Daytime
                            ,d.stream_item_id
                            ,lv2_company_stream_item_id
                            ,d.dist_id
                            ,d.document_key
                            ,d.transaction_key
                            ,d.node_id
                            ,''
                            ,''
                            ,lt_vendor_dist_info(i_company_dist).company_id
                            ,lt_vendor_dist_info(i_company_dist).party_share / 100
                            ,lv2_override_customer_id
                            ,lv2_company_share
                            ,(lt_vendor_dist_info(i_company_dist).party_share / 100) * lv2_company_share
                            ,d.sort_order
                            ,d.report_category_code
                            ,d.value_adjustment
                            ,d.uom1_code
                            ,d.uom2_code
                            ,d.uom3_code
                            ,d.uom4_code
                            ,d.price_concept_code
                            ,d.price_element_code
                            ,d.stim_value_category_code
                            ,d.line_item_type
                            ,d.line_item_based_type
                            ,d.move_qty_to_vo_ind
                            ,d.profit_centre_id
                        FROM cont_line_item_dist d
                        WHERE line_item_key = p_line_item_key
                            AND d.dist_id = p_profit_centre_id
                            AND NOT EXISTS (SELECT 'X'
                                               FROM cont_li_dist_company clidc
                                              WHERE clidc.line_item_key = d.line_item_key
                                                AND clidc.dist_id = d.dist_id
                                                AND clidc.vendor_id = lt_vendor_dist_info(i_company_dist).company_id
                                                AND clidc.customer_id = lv2_override_customer_id);
                END LOOP;

END gen_dist_party_f_given;



FUNCTION CopyLineItem
(  p_object_id VARCHAR2,
   p_line_item_id VARCHAR2,
   p_daytime DATE,
   p_target_transaction_id VARCHAR2
)
RETURN VARCHAR2
IS

CURSOR c_livf(pc_split_key_id split_key.object_id%TYPE,pc_daytime DATE) IS
SELECT split_member_id id,
       source_member_id,
       comments_mth
FROM split_key_setup
WHERE object_id = pc_split_key_id
  AND pc_daytime >= Nvl(daytime, pc_daytime)
  AND pc_daytime < Nvl(ec_split_key_version.next_daytime(object_id, daytime, 1), pc_daytime + 1)
;

CURSOR c_li_dist_company(cp_split_key_id VARCHAR2, cp_contract_id VARCHAR2) IS
SELECT
     sks.split_member_id,
     vendor.company_id vendor_id,
     customer.company_id customer_id,
     nvl(sks.split_share_mth, vendor.party_share / 100) vendor_share,
     customer.party_share/100 customer_share,
     sks.comments_mth
FROM
     split_key_setup sks,
     contract_party_share vendor,
     contract_party_share customer
WHERE sks.object_id = cp_split_key_id
      AND p_daytime >= Nvl(sks.daytime, p_daytime)
      AND p_daytime < Nvl(ec_split_key_version.next_daytime(sks.object_id, sks.daytime, 1), p_daytime + 1)
      AND vendor.object_id  =  cp_contract_id
      AND customer.object_id = cp_contract_id
      AND ec_company.company_id(vendor.company_id) =  (ec_stream_item_version.company_id(sks.split_member_id , p_daytime, '<='))
      AND vendor.party_role = 'VENDOR'
      AND customer.party_role = 'CUSTOMER'
      AND customer.daytime <= p_daytime
      AND nvl(customer.end_date, p_daytime + 1) > p_daytime
      AND vendor.daytime <= p_daytime
      AND nvl(vendor.end_date, p_daytime + 1) > p_daytime
UNION
SELECT
     sks.split_member_id,
     vendor.company_id vendor_id,
     customer.company_id customer_id,
     vendor.party_share/100 vendor_share,
     nvl(sks.split_share_mth, customer.party_share/ 100 ) customer_share,
     sks.comments_mth
FROM
     split_key_setup sks,
     contract_party_share vendor,
     contract_party_share customer
WHERE sks.object_id = cp_split_key_id
      AND p_daytime >= Nvl(sks.daytime,p_daytime)
      AND p_daytime < Nvl(ec_split_key_version.next_daytime(sks.object_id, sks.daytime, 1), p_daytime + 1)
      AND vendor.object_id  =  cp_contract_id
      AND customer.object_id = cp_contract_id
      AND ec_company.company_id(customer.company_id) = (ec_stream_item_version.company_id(sks.split_member_id , p_daytime, '<='))
      AND vendor.party_role = 'VENDOR'
      AND customer.party_role = 'CUSTOMER'
      AND customer.daytime <= p_daytime
      AND nvl(customer.end_date, p_daytime + 1) > p_daytime
      AND vendor.daytime <= p_daytime
      AND nvl(vendor.end_date, p_daytime + 1) > p_daytime
UNION
SELECT sks.split_member_id,
           vendor.company_id vendor_id,
           customer.company_id customer_id,
           nvl(sks.split_share_mth, vendor.party_share / 100) vendor_share,
           customer.party_share / 100 customer_share,
           sks.comments_mth
  FROM split_key_setup sks, contract_party_share vendor, contract_party_share customer
     WHERE sks.object_id =cp_split_key_id
       AND p_daytime >= sks.daytime
  AND p_daytime < Nvl(ec_split_key_version.next_daytime(sks.object_id, sks.daytime, 1), p_daytime + 1)
       AND vendor.object_id =cp_contract_id
       AND customer.object_id =cp_contract_id
       AND vendor.party_role = 'VENDOR'
       AND customer.party_role = 'CUSTOMER'
       AND vendor.company_id=sks.split_member_id
       AND customer.daytime <= p_daytime
       AND nvl(customer.end_date, p_daytime + 1) > p_daytime
       AND vendor.daytime <= p_daytime
       AND nvl(vendor.end_date, p_daytime + 1) > p_daytime

;

lv2_split_key_id VARCHAR2(32);
lv2_new_line_item_id  VARCHAR2(32);
lv2_dist_object_id VARCHAR2(32);
lv2_liv_id VARCHAR2(200);
lrec_line_item CONT_LINE_ITEM%ROWTYPE;
lrec_target_trans CONT_TRANSACTION%ROWTYPE := ec_cont_transaction.row_by_pk(p_target_transaction_id);
lv2_trans_templ VARCHAR2(32);
lv2_child_split_key_id VARCHAR2(32);
lrec_trans_ver TRANSACTION_TMPL_VERSION%ROWTYPE := ec_transaction_tmpl_version.row_by_pk(lrec_target_trans.trans_template_id, lrec_target_trans.daytime, '<=');

lv2_stream_item_id      	VARCHAR2(32);
lv2_stim_val_cat        	VARCHAR2(32);
lv2_mv_qty_to_vo_ind    	VARCHAR2(32);
lv2_node_id             	VARCHAR2(32);
lv2_use_si_ind          	VARCHAR2(32);
lv2_dist_stream_item_id 	VARCHAR2(32);
lv2_profit_centre_id    	VARCHAR2(32);
lv2_company_stream_item_id      VARCHAR2(32);
lrec_sks                	split_key_setup%ROWTYPE;
lrec_csks               	split_key_setup%ROWTYPE;

BEGIN

    lv2_use_si_ind := lrec_trans_ver.use_stream_items_ind;

    lrec_line_item := ec_cont_line_item.row_by_pk(p_line_item_id);
    lrec_target_trans := ec_cont_transaction.row_by_pk(p_target_transaction_id);

    -- insert line item, pick id from sequence
    Ecdp_System_Key.assignNextNumber('CONT_LINE_ITEM', lv2_new_line_item_id);
    SELECT 'LI:' || to_char(lv2_new_line_item_id)
    INTO lv2_liv_id
    FROM DUAL;

    IF lv2_use_si_ind ='N' THEN
      lrec_sks:= ec_split_key_setup.row_by_pk(lrec_trans_ver.split_key_id, ecdp_objects.GetObjIDFromCode('OBJECT_LIST',lrec_trans_ver.dist_code), p_daytime, '<=' );
      lv2_stim_val_cat := NULL;
      lv2_stream_item_id := lrec_sks.profit_centre_id;
      lv2_mv_qty_to_vo_ind := 'N';
    ELSE
      lv2_stim_val_cat :=  lrec_line_item.stim_value_category_code;
      lv2_stream_item_id := lrec_target_trans.stream_item_id;
      lv2_mv_qty_to_vo_ind := lrec_line_item.move_qty_to_vo_ind;
    END IF;


    INSERT INTO CONT_LINE_ITEM
        (object_id,
        line_item_key,
        transaction_key,
        document_key,
        LINE_ITEM_TEMPLATE_ID,
        STREAM_ITEM_ID,
        PRICE_CONCEPT_CODE,
        PRICE_ELEMENT_CODE	,
        NAME,
        DESCRIPTION,
        LINE_ITEM_BASED_TYPE,
        LINE_ITEM_TYPE	,
        STIM_VALUE_CATEGORY_CODE	,
        SORT_ORDER	,
        REPORT_CATEGORY_CODE	,
        CONTRIBUTION_FACTOR,
        MOVE_QTY_TO_VO_IND,
        VALUE_ADJUSTMENT,
        UOM1_CODE	,
        UOM2_CODE	,
        UOM3_CODE	,
        UOM4_CODE	,
        VAT_CODE,
        VAT_RATE,
        UNIT_PRICE,
        UNIT_PRICE_UNIT,
        PERCENTAGE_BASE_AMOUNT,
        PERCENTAGE_VALUE,
        FREE_UNIT_QTY,
        PRICING_VALUE,
        INTEREST_BASE_AMOUNT,
        INTEREST_TYPE,
        INTEREST_GROUP,
        RATE_OFFSET,
        COMPOUNDING_PERIOD,
        INTEREST_FROM_DATE,
        INTEREST_TO_DATE,
        RATE_DAYS,
        DAYTIME,
        PRICE_OBJECT_ID,
        GROUP_IND,
        calculation_id,
        ifac_li_conn_code,
        dist_method,
        creation_method,
        created_by,
        created_date,
        record_status
    ) VALUES (
        lrec_line_item.object_id
        ,lv2_liv_id
        ,p_target_transaction_id
        ,lrec_target_trans.document_key
        ,NULL
        ,lv2_stream_item_id
        ,lrec_line_item.price_concept_code
        ,lrec_line_item.price_element_code
        ,lrec_line_item.name
        ,lrec_line_item.description
        ,lrec_line_item.line_item_based_type
        ,lrec_line_item.line_item_type
        ,lv2_stim_val_cat
        ,lrec_line_item.sort_order
        ,lrec_line_item.report_category_code
        ,lrec_line_item.contribution_factor
        ,lv2_mv_qty_to_vo_ind
        ,lrec_line_item.value_adjustment
        ,lrec_line_item.uom1_code
        ,lrec_line_item.uom2_code
        ,lrec_line_item.uom3_code
        ,lrec_line_item.uom4_code
        ,lrec_line_item.vat_code
        ,lrec_line_item.vat_rate
        ,lrec_line_item.unit_price
        ,lrec_line_item.unit_price_unit
        ,lrec_line_item.percentage_base_amount
        ,lrec_line_item.percentage_value
        ,lrec_line_item.free_unit_qty
        ,lrec_line_item.pricing_value
        ,lrec_line_item.interest_base_amount
        ,lrec_line_item.interest_type
        ,lrec_line_item.interest_group
        ,lrec_line_item.rate_offset
        ,lrec_line_item.compounding_period
        ,lrec_line_item.interest_from_date
        ,lrec_line_item.interest_to_date
        ,lrec_line_item.rate_days
        ,lrec_line_item.daytime
        ,lrec_line_item.price_object_id
        ,lrec_line_item.group_ind
        ,lrec_line_item.calculation_id
        ,lrec_line_item.ifac_li_conn_code
        ,lrec_line_item.dist_method
        ,ecdp_revn_ft_constants.c_mtd_auto_gen
        ,lrec_line_item.created_by
        ,lrec_line_item.created_date
        ,lrec_line_item.record_status
        );

    lv2_trans_templ    := ec_cont_transaction.trans_template_id(p_target_transaction_id);
    lv2_split_key_id   := ec_transaction_tmpl_version.split_key_id(lv2_trans_templ, p_daytime, '<=');


    lv2_dist_object_id := ec_stream_item_version.field_id(ec_cont_transaction.stream_item_id(p_target_transaction_id), p_daytime, '<=');

        FOR LIVFCur IN c_livf(lv2_split_key_id,p_daytime) LOOP


            lv2_child_split_key_id := ec_split_key_setup.child_split_key_id(lv2_split_key_id, LIVFCur.id, p_daytime, '<=');
            lrec_csks:= ec_split_key_setup.row_by_pk(lrec_trans_ver.split_key_id, LIVFCur.id, p_daytime, '<=' );
             IF lv2_use_si_ind = 'N' THEN
                lv2_profit_centre_id := lrec_csks.profit_centre_id;
                lv2_dist_stream_item_id :=lv2_profit_centre_id;
                lv2_node_id := NULL;
                lv2_dist_object_id := lv2_profit_centre_id;
             ELSE
                lv2_dist_stream_item_id := LIVFCur.id;
                select DECODE(ec_stream_item_version.value_point(lv2_dist_stream_item_id, p_daytime, '<='),'TO_NODE'
                          ,ec_strm_version.to_node_id(ec_stream_item.stream_id(lv2_dist_stream_item_id), p_daytime, '<=')
                          ,'FROM_NODE'
                          ,ec_strm_version.from_node_id(ec_stream_item.stream_id(lv2_dist_stream_item_id), p_daytime, '<=')
                          ,NULL) INTO lv2_node_id FROM cont_line_item WHERE line_item_key = lv2_liv_id;
                lv2_dist_object_id := CASE ecdp_objects.GetObjClassName(LIVFCur.id)
                                     WHEN 'FIELD' THEN LIVFCur.id
                                     WHEN 'STREAM_ITEM' THEN ec_stream_item_version.field_id(LIVFCur.id, p_daytime, '<=') END;

             END IF;

            INSERT INTO cont_line_item_dist
                (object_id,
                line_item_key,
                document_key,
                transaction_key,
                STREAM_ITEM_ID,
                DIST_ID,
                NODE_ID,
                name,
                description,
                PRICE_CONCEPT_CODE,
                PRICE_ELEMENT_CODE	,
                LINE_ITEM_TYPE	,
                STIM_VALUE_CATEGORY_CODE	,
                SORT_ORDER	,
                REPORT_CATEGORY_CODE	,
                MOVE_QTY_TO_VO_IND,
                CONTRIBUTION_FACTOR,
                UOM1_CODE	,
                UOM2_CODE	,
                UOM3_CODE	,
                UOM4_CODE	,
                SPLIT_SHARE,
                ALLOC_STREAM_ITEM_ID,
                DAYTIME,
                LINE_ITEM_BASED_TYPE,
                VAT_CODE,
                VAT_RATE,
                JV_BILLABLE,
                comments,
                created_by,
                created_date,
                record_status,
                profit_centre_id
            )
            SELECT
                object_id,
                line_item_key,
                document_key,
                transaction_key,
                lv2_dist_stream_item_id, -- take to_object from split key
                lv2_dist_object_id,
                lv2_node_id,
                name,
                description,
                PRICE_CONCEPT_CODE	,
                PRICE_ELEMENT_CODE	,
                LINE_ITEM_TYPE	,
                STIM_VALUE_CATEGORY_CODE	,
                SORT_ORDER	,
                REPORT_CATEGORY_CODE	,
                MOVE_QTY_TO_VO_IND,
                CONTRIBUTION_FACTOR,
                UOM1_CODE	,
                UOM2_CODE	,
                UOM3_CODE	,
                UOM4_CODE	,
                Ecdp_split_key.GetSplitShareMth(lv2_split_key_id,LIVFCur.id,p_daytime, lrec_line_item.uom1_code, 'SP_SPLIT_KEY'), -- pick share
                LIVFCur.source_member_id,
                p_daytime,
                LINE_ITEM_BASED_TYPE,
                VAT_CODE,
                VAT_RATE,
                decode(ec_contract_version.bank_details_level_code(p_object_id, p_daytime, '<='),'JV_BILLABLE','JV_BILLABLE',null),
                LIVFCur.comments_mth,
                created_by,
                created_date,
                'P',
                lv2_profit_centre_id
            FROM cont_line_item
            WHERE object_id = p_object_id
              AND line_item_key = lv2_liv_id;


              FOR SplitCur IN c_li_dist_company(lv2_child_split_key_id, p_object_id) LOOP

                    INSERT INTO cont_li_dist_company (
                        object_id
                        ,line_item_key
                        ,daytime
                        ,stream_item_id
                        ,dist_id
                        ,document_key
                        ,transaction_key
                        ,node_id
                        ,name
                        ,description
                        ,comments
                        ,vendor_id
                        ,vendor_share
                        ,customer_id
                        ,customer_share
                        ,split_share
                        ,sort_order
                        ,report_category_code
                        ,value_adjustment
                        ,uom1_code
                        ,uom2_code
                        ,uom3_code
                        ,uom4_code
                        ,price_concept_code
                        ,price_element_code
                        ,stim_value_category_code
                        ,line_item_type
                        ,line_item_based_type
                        ,company_stream_item_id
                        ,profit_centre_id
                        )
                    SELECT
                        d.Object_id,
                        d.Line_item_key,
                        d.Daytime,
                        d.stream_item_id,
                        d.dist_id,
                        d.document_key,
                        d.transaction_key,
                        d.node_id,
                        '' ,
                        '' ,
                        SplitCur.comments_mth,
                        SplitCur.vendor_id,
                        SplitCur.vendor_share,
                        SplitCur.customer_id,
                        SplitCur.customer_share,
                        SplitCur.vendor_share * SplitCur.customer_share,
                        d.sort_order,
                        d.report_category_code,
                        d.value_adjustment,
                        d.uom1_code,
                        d.uom2_code,
                        d.uom3_code,
                        d.uom4_code,
                        d.price_concept_code,
                        d.price_element_code,
                        d.stim_value_category_code,
                        d.line_item_type,
                        d.line_item_based_type,
                        SplitCur.split_member_id,
                        d.profit_centre_id
                    FROM
                        cont_line_item_dist d
                    WHERE line_item_key = lv2_liv_id
                      AND d.dist_id = lv2_dist_object_id;

            END LOOP;

        END LOOP;

    -- This update is to perform monetary updates
    UPDATE CONT_LINE_ITEM
    SET PRICING_VALUE = PRICING_VALUE
        ,last_updated_by = 'SYSTEM' -- part of insert operation
    WHERE object_id = p_object_id
    AND document_key = lrec_target_trans.document_key
    AND transaction_key = p_target_transaction_id
    AND line_item_key = lv2_liv_id;

    RETURN lv2_liv_id;

END CopyLineItem;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : DelLineItem
-- Description    : used to delete Line Items selected in screen 'Process Transaction Values'
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : cont_line_item, cont_line_item_uom, cont_line_item_dist
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE DelLineItem(
        p_object_id VARCHAR2,
        p_line_item_id VARCHAR2
)
--</EC-DOC>

IS
BEGIN
    del_p(p_line_item_id);

END DelLineItem;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : InsNewLineItem
-- Description    : Inserts a new line item
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : cont_line_item
--
-- Using functions: InsInterestLineItem (recursively)
-- Configuration
-- required       :
--
-- Behaviour      : Recursive call might include last argument -> If inserting several line items considered part of the same interest_group
-------------------------------------------------------------------------------------------------------------------------------------------

FUNCTION InsNewLineItem(p_object_id             VARCHAR2,
                        p_daytime               DATE,
                        p_document_id           VARCHAR2,
                        p_transaction_key       VARCHAR2,
                        p_li_template_id        VARCHAR2,
                        p_user                  VARCHAR2,
                        p_line_item_id          VARCHAR2 DEFAULT NULL,
                        p_line_item_type        VARCHAR2 DEFAULT NULL,
                        p_line_item_based_type  VARCHAR2 DEFAULT NULL,
                        p_pct_base_amount       NUMBER DEFAULT NULL,
                        p_percentage_value      NUMBER DEFAULT NULL,
                        p_unit_price            NUMBER DEFAULT NULL,
                        p_unit_price_unit       VARCHAR2 DEFAULT NULL,
                        p_free_unit_qty         NUMBER DEFAULT NULL,
                        p_pricing_value         NUMBER DEFAULT NULL,
                        p_description           VARCHAR2 DEFAULT NULL,
                        p_price_object_id       VARCHAR2 DEFAULT NULL,
                        p_price_element_code    VARCHAR2 DEFAULT NULL,
                        p_customer_id           VARCHAR2 DEFAULT NULL,
                        p_insert_dist_ind       VARCHAR2 DEFAULT 'Y',
                        p_sort_order            NUMBER DEFAULT NULL,
                        p_creation_method       ecdp_revn_ft_constants.t_c_mtd DEFAULT ecdp_revn_ft_constants.c_mtd_manual,
                        p_ifac_li_conn_code     cont_line_item.ifac_li_conn_code%TYPE DEFAULT NULL,
                        p_li_unique_key_1       VARCHAR2 DEFAULT NULL,
                        p_li_unique_key_2       VARCHAR2 DEFAULT NULL
                        )

RETURN VARCHAR2
--</EC-DOC>
IS



lv2_liv_id              VARCHAR2(32);
lv2_new_line_item_id    VARCHAR2(32);
lrec_cont_document      cont_document%ROWTYPE := Ec_Cont_Document.row_by_pk(p_document_id);
lrec_cont_trans         cont_transaction%ROWTYPE := ec_cont_transaction.row_by_pk(p_transaction_key);
lrec_li                 cont_line_item%ROWTYPE := NULL;
lrec_ttv                transaction_tmpl_version%ROWTYPE := ec_transaction_tmpl_version.row_by_pk(lrec_cont_trans.trans_template_id, lrec_cont_trans.daytime, '<=');
ln_sort_order           NUMBER;
lv2_tt_id               VARCHAR2(32);
lv2_vat_code            VARCHAR2(32);
ln_vat_rate             NUMBER;
lv2_stream_item_id      VARCHAR2(32);
lv2_stim_val_cat        VARCHAR2(32);
lv2_mv_qty_to_vo_ind    VARCHAR2(32);
lv2_use_si_ind          VARCHAR2(32);
lrec_sks                split_key_setup%ROWTYPE:=ec_split_key_setup.row_by_pk(lrec_ttv.split_key_id, ecdp_objects.GetObjIDFromCode('OBJECT_LIST',lrec_ttv.dist_code), p_daytime, '<=' );
l_line_item_tmpl_ver_rec    line_item_tmpl_version%ROWTYPE;
l_document_setup_rec        contract_doc_version%ROWTYPE;
l_free_unit_unit_price      cont_line_item.unit_price%TYPE;
l_value_sat                 BOOLEAN;

BEGIN

    lv2_use_si_ind := lrec_ttv.use_stream_items_ind;

    IF lv2_use_si_ind = 'N' THEN
       lv2_stim_val_cat := 'NET_CURRENT';
       lv2_mv_qty_to_vo_ind := 'N';
    ELSE
      -- TODO for issue (ECPD-14958) this column is currently defaulted. Is that ok?
      lv2_stim_val_cat :=  nvl(lrec_li.stim_value_category_code,'NET_CURRENT');
      lv2_mv_qty_to_vo_ind := lrec_li.move_qty_to_vo_ind;
    END IF;

    lv2_tt_id := lrec_cont_trans.trans_template_id;

    IF (p_price_object_id IS NULL AND p_line_item_based_type = ecdp_revn_ft_constants.li_btype_quantity)  THEN
       RAISE_APPLICATION_ERROR(-20000, 'Can not add quantity line items without a price object.');
    END IF;

    IF p_daytime is NULL THEN
       raise_application_error(-20000, 'Daytime is null, contact system supervisor');
    END IF;

    IF (p_line_item_id IS NOT NULL) THEN
       lv2_liv_id := p_line_item_id;
    ELSE
        -- insert line item, pick id from sequence
        Ecdp_System_Key.assignNextNumber('CONT_LINE_ITEM', lv2_new_line_item_id);
        SELECT 'LI:' || to_char(lv2_new_line_item_id)
        INTO lv2_liv_id
        FROM DUAL;
    END IF;

    lrec_li.line_item_key := lv2_liv_id;
    lrec_li.creation_method := nvl(p_creation_method, ecdp_revn_ft_constants.c_mtd_manual);
    l_document_setup_rec := ec_contract_doc_version.row_by_pk(lrec_cont_document.contract_doc_id, p_daytime, '<=');

    -- this means that insert is done directly on transaction, and NOT when contract was processed
    IF p_li_template_id IS NULL THEN

          lrec_li.ifac_li_conn_code := p_ifac_li_conn_code;
          lrec_li.daytime := lrec_cont_document.daytime;
          lrec_li.line_item_type := p_line_item_type;
          lrec_li.line_item_based_type := p_line_item_based_type;
          lrec_li.price_concept_code := ec_product_price.price_concept_code(p_price_object_id);
          lrec_li.price_element_code := p_price_element_code;
          lrec_li.unit_price := p_unit_price;
          lrec_li.unit_price_unit := p_unit_price_unit;
          lrec_li.percentage_base_amount := p_pct_base_amount;
          lrec_li.percentage_value := p_percentage_value/100;
          lrec_li.free_unit_qty := p_free_unit_qty;
          lrec_li.pricing_value := p_pricing_value;
          lrec_li.description := p_description;
          lrec_li.group_ind := ec_price_concept_element.group_ind(lrec_li.price_concept_code,p_price_element_code);
          lrec_li.sort_order := NVL(p_sort_order,99);


          l_free_unit_unit_price := p_unit_price;
        IF lrec_cont_trans.transaction_date IS NOT NULL THEN
         l_free_unit_unit_price := ecdp_transaction.GetQtyPrice(p_object_id, lv2_liv_id, NULL, p_transaction_key, lrec_cont_document.daytime, p_line_item_based_type ,p_price_object_id,lrec_li.price_element_code, 'Y');
        END IF;

            l_value_sat := set_li_val_qty_p(
                lrec_li,
                NULL, NULL, NULL, NULL,
                lrec_ttv.uom1_code,
                lrec_ttv.uom2_code,
                lrec_ttv.uom3_code,
                lrec_ttv.uom4_code);

            l_value_sat := set_li_val_free_unit_p(lrec_li, p_free_unit_qty, l_free_unit_unit_price, p_unit_price_unit);
            l_value_sat := set_li_val_free_unit_po_p(
                lrec_li, p_free_unit_qty, l_free_unit_unit_price, p_unit_price_unit,
                p_price_object_id, ec_product_price.price_concept_code(p_price_object_id), p_price_element_code);
            l_value_sat := set_li_val_perc_all_p(lrec_li, p_percentage_value/100);
            l_value_sat := set_li_val_perc_qty_p(lrec_li, p_percentage_value/100);
            l_value_sat := set_li_val_perc_man_p(lrec_li, p_percentage_value/100, p_pct_base_amount);
            l_value_sat := set_li_val_fixed_value_p(lrec_li, p_pricing_value);
            l_value_sat := set_li_val_interest_p(
                lrec_li,
                l_document_setup_rec.int_type,
                l_document_setup_rec.int_compounding_period,
                lrec_cont_document.daytime,
                lrec_cont_document.daytime,
                ec_price_in_item_value.index_value(ec_price_input_item.object_id_by_uk(
                        lrec_li.interest_type,'PRICE_INDEX'),
                        lrec_cont_document.daytime,
                        ec_price_input_item.class_name(ec_price_input_item.object_id_by_uk(lrec_li.interest_type,'PRICE_INDEX')) || '_DAY_VALUE', '<='),
                0,
                l_document_setup_rec.int_offset,
                l_document_setup_rec.int_num_days,
                lv2_liv_id,
                NULL);

        -- Applies to line items added based on I/F data rather than line item templates ECPD-14958)
        -- When price object is passed from interface, quantity line items can still be present without a line item template
          IF ecdp_transaction.IsReducedConfig(NULL, NULL, lv2_tt_id, p_transaction_key, p_daytime) THEN


             lrec_li.sort_order := NVL(p_sort_order,99);
             lrec_li.contribution_factor := 1;
             lrec_li.move_qty_to_vo_ind := ec_price_concept_element.move_qty_to_vo_ind(lrec_li.price_concept_code, lrec_li.price_element_code);
             lrec_li.value_adjustment := lrec_ttv.value_adjustment;
             lrec_li.name := nvl(ec_price_concept_element.name(lrec_li.price_concept_code,lrec_li.price_element_code),p_description);
             lrec_li.description := lrec_li.name;



         -- Applies to line items added on an existing document
          ELSE

            lrec_li.name := p_description;
            lrec_li.sort_order := NVL(p_sort_order,99);
            lrec_li.price_object_id := p_price_object_id;

            END IF;

    ELSE -- ie. there is a line item template
        l_line_item_tmpl_ver_rec := ec_line_item_tmpl_version.row_by_pk(p_li_template_id, p_daytime, '<=');

        lrec_li.ifac_li_conn_code := l_line_item_tmpl_ver_rec.ifac_li_conn_code;
        lrec_li.daytime := p_daytime;
        lrec_li.line_item_type := nvl(p_line_item_type, l_line_item_tmpl_ver_rec.line_item_type);
        lrec_li.line_item_based_type := l_line_item_tmpl_ver_rec.line_item_based_type;
        lrec_li.price_concept_code := l_line_item_tmpl_ver_rec.price_concept_code;
        lrec_li.price_element_code := l_line_item_tmpl_ver_rec.price_element_code;
        lrec_li.price_object_id := l_line_item_tmpl_ver_rec.price_object_id;
        lrec_li.percentage_value := l_line_item_tmpl_ver_rec.percentage_value;
        lrec_li.calculation_id := l_line_item_tmpl_ver_rec.calculation_id;
        lrec_li.pricing_value := l_line_item_tmpl_ver_rec.line_item_value * 1;
        lrec_li.group_ind := l_line_item_tmpl_ver_rec.group_ind;

        -- special handling on name for interest line items
        IF lrec_li.line_item_based_type <> ecdp_revn_ft_constants.li_btype_quantity THEN
            lrec_li.name := Nvl(ec_line_item_template.description(p_li_template_id), l_line_item_tmpl_ver_rec.name);
        ELSE
            lrec_li.name := l_line_item_tmpl_ver_rec.name;
        END IF;

        lrec_li.description := ec_line_item_template.description(p_li_template_id);
        lrec_li.stim_value_category_code := l_line_item_tmpl_ver_rec.stim_value_category_code;
        lrec_li.sort_order := ec_line_item_template.sort_order(p_li_template_id);
        lrec_li.contribution_factor := 1;

        lrec_li.move_qty_to_vo_ind := ec_price_concept_element.move_qty_to_vo_ind(l_line_item_tmpl_ver_rec.price_concept_code, l_line_item_tmpl_ver_rec.price_element_code);
        lrec_li.value_adjustment := lrec_ttv.value_adjustment;

        IF (lrec_li.price_concept_code IS NOT NULL AND lrec_li.price_element_code IS NOT NULL) THEN
             lrec_li.line_item_type := nvl(lrec_li.line_item_type, ec_price_concept_element.line_item_type(lrec_li.price_concept_code,lrec_li.price_element_code));
        END IF;

        l_value_sat := set_li_val_qty_p(
            lrec_li,
            NULL, NULL, NULL, NULL,
            lrec_ttv.uom1_code,
            lrec_ttv.uom2_code,
            lrec_ttv.uom3_code,
            lrec_ttv.uom4_code);

        l_value_sat := set_li_val_free_unit_p(
            lrec_li,
            NULL,
            nvl(p_unit_price, l_line_item_tmpl_ver_rec.unit_price),
            nvl(p_unit_price_unit, l_line_item_tmpl_ver_rec.unit_price_unit));

        l_value_sat := set_li_val_free_unit_po_p(
            lrec_li,
            NULL,
            nvl(p_unit_price, l_line_item_tmpl_ver_rec.unit_price),
            nvl(p_unit_price_unit, l_line_item_tmpl_ver_rec.unit_price_unit),
            nvl(p_price_object_id, l_line_item_tmpl_ver_rec.price_object_id),
            l_line_item_tmpl_ver_rec.price_concept_code,
            l_line_item_tmpl_ver_rec.price_element_code);

        l_value_sat := set_li_val_perc_all_p(lrec_li, l_line_item_tmpl_ver_rec.percentage_value);
        l_value_sat := set_li_val_perc_qty_p(lrec_li, l_line_item_tmpl_ver_rec.percentage_value);
        l_value_sat := set_li_val_perc_man_p(lrec_li, l_line_item_tmpl_ver_rec.percentage_value, p_pct_base_amount);
        l_value_sat := set_li_val_fixed_value_p(lrec_li, l_line_item_tmpl_ver_rec.line_item_value * 1);

        l_value_sat := set_li_val_interest_p(
            lrec_li,
            l_document_setup_rec.int_type,
            l_document_setup_rec.int_compounding_period,
            lrec_cont_document.daytime,
            lrec_cont_document.daytime,
            ec_price_in_item_value.index_value(ec_price_input_item.object_id_by_uk(
                    lrec_li.interest_type,'PRICE_INDEX'),
                    lrec_cont_document.daytime,
                    ec_price_input_item.class_name(ec_price_input_item.object_id_by_uk(lrec_li.interest_type,'PRICE_INDEX')) || '_DAY_VALUE', '<='),
            0,
            l_document_setup_rec.int_offset,
            l_document_setup_rec.int_num_days,
            lv2_liv_id,
            NULL);

            -- TODO: verify following is not needed - HANYI
/*        -- special handling for percentage line items
        IF lrec_li.line_item_based_type = 'PERCENTAGE_ALL' OR lrec_li.line_item_based_type = 'PERCENTAGE_QTY' OR lrec_li.line_item_based_type = 'PERCENTAGE_MANUAL' THEN
           lrec_li.pricing_value := nvl(p_pricing_value, lrec_li.percentage_base_amount *  lrec_li.percentage_value);
        END IF;*/
    END IF;

    IF lrec_li.name IS NULL THEN
       lrec_li.name := ec_prosty_codes.code_text(lrec_li.line_item_based_type, 'LINE_ITEM_BASED_TYPE')
           || ' - ' || nvl(ec_prosty_codes.code_text(lrec_li.line_item_type, 'LINE_ITEM_TYPE'), lrec_li.line_item_type);
    END IF;

    -- Retrieve VAT_CODE and VAT_RATE
    IF p_li_template_id IS NOT NULL THEN
            -- Retrieve form Line Item Template (only if not UNDEFINED)
           lv2_vat_code := ec_line_item_tmpl_version.vat_code_1(p_li_template_id, lrec_li.daytime, '<=');
        ln_vat_rate := ec_vat_code_version.rate(ec_vat_code.object_id_by_uk(lv2_vat_code), lrec_li.daytime, '<=');
        IF lv2_vat_code = 'UNDEFINED' THEN
          lv2_vat_code := null;
          ln_vat_rate := null;
        END IF;

        IF lv2_vat_code IS NULL THEN
          -- If Line Item Template does not have VAT_RATE, retieve from the level above (transaction)
          lv2_vat_code := lrec_cont_trans.vat_code;
          ln_vat_rate := lrec_cont_trans.vat_rate;
        END IF;
    ELSE
        -- If no li_template_id, retieve both from the level above (transaction)
        lv2_vat_code := lrec_cont_trans.vat_code;
        ln_vat_rate := lrec_cont_trans.vat_rate;
    END IF;

    -- TODO for issue (ECPD-14958) this column is currently defaulted. Is that ok?
    lrec_li.stim_value_category_code := nvl(lrec_li.stim_value_category_code,'NET_CURRENT');
    lrec_li.object_id := p_object_id;
    lrec_li.line_item_key := lv2_liv_id;
    lrec_li.transaction_key := p_transaction_key;
    lrec_li.document_key := p_document_id;
    lrec_li.line_item_template_id := p_li_template_id;
    lrec_li.stream_item_id := lrec_cont_trans.stream_item_id;
    lrec_li.vat_code := lv2_vat_code;
    lrec_li.vat_rate := ln_vat_rate;

    --The unique keys are for OLI's only
    IF lrec_li.line_item_based_type != ecdp_revn_ft_constants.li_btype_quantity THEN
        lrec_li.li_unique_key_1 := p_li_unique_key_1;
        lrec_li.li_unique_key_2 := p_li_unique_key_2;
    END IF;

    INSERT INTO CONT_LINE_ITEM
        (object_id,
        line_item_key,
        transaction_key,
        document_key,
        LINE_ITEM_TEMPLATE_ID,
        STREAM_ITEM_ID,
        PRICE_CONCEPT_CODE	,
        PRICE_ELEMENT_CODE	,
        NAME,
        DESCRIPTION,
        LINE_ITEM_BASED_TYPE,
        LINE_ITEM_TYPE	,
        STIM_VALUE_CATEGORY_CODE	,
        SORT_ORDER	,
        REPORT_CATEGORY_CODE	,
        CONTRIBUTION_FACTOR,
        MOVE_QTY_TO_VO_IND,
        VALUE_ADJUSTMENT,
        UOM1_CODE	,
        UOM2_CODE	,
        UOM3_CODE	,
        UOM4_CODE	,
        VAT_CODE,
        VAT_RATE,
        UNIT_PRICE,
        UNIT_PRICE_UNIT,
        PERCENTAGE_BASE_AMOUNT,
        PERCENTAGE_VALUE,
        FREE_UNIT_QTY,
        PRICING_VALUE,
        INTEREST_BASE_AMOUNT,
        INTEREST_TYPE,
        INTEREST_GROUP,
        RATE_OFFSET,
        COMPOUNDING_PERIOD,
        INTEREST_FROM_DATE,
        INTEREST_TO_DATE,
        INTEREST_NUM_DAYS,
        RATE_DAYS,
        DAYTIME,
        PRICE_OBJECT_ID,
        GROUP_IND,
        ifac_li_conn_code,
        calculation_id,
        creation_method,
        li_unique_key_1,
        li_unique_key_2,
        created_by,
        created_date,
        record_status
    )
    SELECT
        lrec_li.object_id,
        lrec_li.line_item_key,
        lrec_li.transaction_key,
        lrec_li.document_key,
        lrec_li.line_item_template_id,
        lrec_li.stream_item_id,
        lrec_li.price_concept_code,
        lrec_li.price_element_code,
        lrec_li.name,
        lrec_li.description,
        lrec_li.line_item_based_type,
        lrec_li.line_item_type,
        lrec_li.stim_value_category_code,
        lrec_li.sort_order,
        lrec_li.report_category_code,
        lrec_li.contribution_factor,
        lrec_li.move_qty_to_vo_ind,
        lrec_li.value_adjustment,
        lrec_li.uom1_code,
        lrec_li.uom2_code,
        lrec_li.uom3_code,
        lrec_li.uom4_code,
        lrec_li.vat_code,
        lrec_li.vat_rate,
        lrec_li.unit_price,
        lrec_li.unit_price_unit,
        lrec_li.percentage_base_amount,
        lrec_li.percentage_value,
        lrec_li.free_unit_qty,
        lrec_li.pricing_value,
        lrec_li.interest_base_amount,
        lrec_li.interest_type,
        lrec_li.interest_group,
        lrec_li.rate_offset,
        lrec_li.compounding_period,
        NULL,
        NULL,
        lrec_li.interest_num_days,
        lrec_li.rate_days,
        lrec_li.daytime,
        lrec_li.price_object_id,
        lrec_li.group_ind,
        lrec_li.ifac_li_conn_code,
        lrec_li.calculation_id,
        lrec_li.creation_method,
        lrec_li.li_unique_key_1,
        lrec_li.li_unique_key_2,
        p_user,
        Ecdp_Timestamp.getCurrentSysdate,
        'P'
    FROM cont_document
    WHERE object_id = lrec_li.object_id
    AND document_key = lrec_li.document_key;

    IF (lrec_li.daytime IS NULL) THEN
        RAISE_APPLICATION_ERROR(-20000,'Can not insert new line item since date is missing.');
    END IF;



    IF NVL(p_insert_dist_ind,'Y') = 'Y' THEN

      gen_dist_f_conf_p(lrec_li, lrec_ttv, p_customer_id, p_user);

   END IF; -- Insert dist?

   ecdp_transaction.UpdPercentageLineItem(p_transaction_key, p_user);

   RETURN lv2_liv_id;

END InsNewLineItem;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : InsNewProcessLineItem
-- Description    : Will prepare the arguments from the screen Process Transaction Values before the procedure InsNewLineItem is called
--                  This procedure does not seem to handle quantity line items
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
FUNCTION InsNewLineItemFromApp
(  p_object_id VARCHAR2,
   p_daytime   DATE,
   p_document_id VARCHAR2,
   p_transaction_id VARCHAR2,
   p_li_template_id VARCHAR2,
   p_user      VARCHAR2,
   p_line_item_id VARCHAR2 DEFAULT NULL,
   p_line_item_type VARCHAR2 DEFAULT NULL,
   p_line_item_based_type VARCHAR2 DEFAULT NULL,
   p_pct_base_amount NUMBER DEFAULT NULL,
   p_percentage_value NUMBER DEFAULT NULL,
   p_unit_price    NUMBER DEFAULT NULL,
   p_unit_price_unit    VARCHAR2 DEFAULT NULL,
   p_free_unit_qty      NUMBER DEFAULT NULL,
   p_pricing_value      NUMBER DEFAULT NULL,
   p_description VARCHAR2 DEFAULT NULL,
   p_price_object_id VARCHAR2 DEFAULT NULL,
   p_sort_order NUMBER DEFAULT NULL
)
RETURN VARCHAR2

IS

lv2_final_li         VARCHAR2(32);
ld_daytime DATE;
lrec_undefined_customer contract_party_share%rowtype;
lv2_customer_id company.object_id%type;
require_po              EXCEPTION;

BEGIN


ld_daytime := nvl(p_daytime, ec_cont_transaction.daytime(p_transaction_id));
lrec_undefined_customer := ec_contract_party_share.row_by_pk(p_object_id,ec_company.object_id_by_uk('UNDEFINED','CUSTOMER'),'CUSTOMER',ld_daytime,'<=');

IF lrec_undefined_customer.company_id IS NOT NULL THEN
   lv2_customer_id := ecdp_contract_setup.GetDocCustomerId(p_document_id);
END IF;

IF p_li_template_id IS NULL THEN

IF p_line_item_based_type = 'FREE_UNIT_PRICE_OBJECT' THEN

   IF p_price_object_id IS NULL THEN
      RAISE require_po ;
   END IF;

   FOR c_val IN c_get_price_element_rec(ec_product_price.price_concept_code(p_price_object_id)) LOOP

      lv2_final_li := InsNewLineItem(p_object_id,
                                     ld_daytime,
                                     p_document_id,
                                     p_transaction_id,
                                     p_li_template_id,
                                     p_user,
                                     p_line_item_id,
                                     p_line_item_type,
                                     p_line_item_based_type,
                                     p_pct_base_amount,
                                     p_percentage_value,
                                     p_unit_price,
                                     p_unit_price_unit,
                                     p_free_unit_qty,
                                     p_pricing_value,
                                     p_description,
                                     p_price_object_id,
                                     c_val.price_element_code,
                                     lv2_customer_id,
                                     NULL,
                                     p_sort_order,
                                     p_creation_method => ecdp_revn_ft_constants.c_mtd_manual);
   END LOOP;

   ELSE

       lv2_final_li := InsNewLineItem(p_object_id,
                                     ld_daytime,
                                     p_document_id,
                                     p_transaction_id,
                                     p_li_template_id,
                                     p_user,
                                     p_line_item_id,
                                     p_line_item_type,
                                     p_line_item_based_type,
                                     p_pct_base_amount,
                                     p_percentage_value,
                                     p_unit_price,
                                     p_unit_price_unit,
                                     p_free_unit_qty,
                                     p_pricing_value,
                                     p_description,
                                     p_price_object_id,
                                     NULL,
                                     lv2_customer_id,
                                     NULL,
                                     p_sort_order,
                                     p_creation_method => ecdp_revn_ft_constants.c_mtd_manual);



   END IF;

END IF;

RETURN lv2_final_li;

EXCEPTION

    WHEN require_po THEN

        RAISE_APPLICATION_ERROR(-20000,'No Price Object was given but is required');


END InsNewLineItemFromApp;






--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GenInterestLineItemSet
-- Description    : Remove interest line items from table, and then generates line items from scratch
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : cont_line_item
--
-- Using functions: InsInterestLineItem
-- Configuration
-- required       :
--
-- Behaviour      : Remove interest line items from table, and then generates line items from scratch.
--                  If line items does not have a line_item_template, i.e. created in screen - > Process Transaction Values,
--                  when deletion is done, new column cont_line_item.interest_group replaces line_item_template as where-clause.
--                  Cont_line_item.interest_group must be set on all interest_line_items.
-------------------------------------------------------------------------------------------------------------------------------
PROCEDURE GenInterestLineItemSetFromApp (
    p_object_id          VARCHAR2,
    p_transaction_key    VARCHAR2,
    p_line_item_key      VARCHAR2,
    p_interest_from_date DATE,
    p_interest_to_date   DATE,
    p_base_amt           NUMBER, -- in pricing currency
    p_base_rate          NUMBER,
    p_interest_type      VARCHAR2,
    p_name               VARCHAR2,
    p_rate_offset        NUMBER,
    p_compounding_period NUMBER,
    p_interest_group     VARCHAR2,
    p_number_of_days     NUMBER,
    p_user               VARCHAR2,
    p_line_item_type     VARCHAR2 DEFAULT NULL,
    p_comment            VARCHAR2 DEFAULT NULL,
    p_sort_order         NUMBER DEFAULT NULL

)
--</EC-DOC>
IS

  l_new_interest_group cont_line_item.interest_group%TYPE;
BEGIN
   l_new_interest_group := GenInterestLineItemSet_I(
       p_object_id
       ,p_transaction_key
       ,p_line_item_key
       ,p_interest_from_date
       ,p_interest_to_date
       ,p_base_amt
       ,p_base_rate
       ,p_interest_type
       ,p_name
       ,p_rate_offset
       ,p_compounding_period
       ,p_interest_group
       ,p_number_of_days
       ,p_user
       ,p_line_item_type
       ,p_comment
       ,p_sort_order
       ,ecdp_revn_ft_constants.c_mtd_manual);

END GenInterestLineItemSetFromApp;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : UpdIntBaseAmount
-- Description    : Will set interest base amount value, interest from date and interest to date  on DEPENDENT document
--                  if one and only one interest line item exists for a given transaction.
--
-- Preconditions  : Attribute INTEREST_BASE_AMOUNT_SOURCE on class CONTRACT_DOC must be either PRECEEDING_DOC or CURRENT_DOC
--                  Must be a DEPENDENT document
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
---------------------------------------------------------------------------------------------------
PROCEDURE UpdIntBaseAmount (
    p_object_id VARCHAR2,
    p_document_id VARCHAR2,
    p_first_preceeding_doc VARCHAR2,
    p_base_rate NUMBER DEFAULT NULL
)
--</EC-DOC>
IS

lv2_doc_concept VARCHAR2(32);
lv2_int_base_amount_src VARCHAR2(32);
ln_li_interest_count NUMBER := 0;
ln_base_amount       cont_line_item.interest_base_amount%TYPE;
lv2_preceeding_doc_id cont_document.document_key%TYPE;
lv2_customer_object_id cont_document_company.company_id%TYPE;
lv2_price_index_id contract_doc_version.int_type_id%TYPE;
ld_from_date DATE;
ln_base_rate NUMBER;
ln_booking_pricing_conv_fac NUMBER;
ln_curr_value               NUMBER := 0;
ln_rev_value                NUMBER := 0;

lrec_cont_pay_tr cont_pay_tracking%ROWTYPE;
ld_interest_from_date DATE;
ld_interest_to_date DATE;

ln_sum_pay_received  NUMBER;
ln_initial_diff      NUMBER;
ln_payment_short     NUMBER;
ln_latest_item_no    NUMBER;
ln_days_late_count   NUMBER;
ln_init_sum_paid     NUMBER;
ln_cont_pay_track_item_count NUMBER;
ln_doc_booking_total NUMBER;

CURSOR c_trans(cp_object_id VARCHAR2,cp_document_id VARCHAR2) IS
SELECT *
FROM   cont_transaction ct
WHERE  ct.object_id = cp_object_id AND
       ct.document_key = cp_document_id;

CURSOR c_line_item(cp_object_id VARCHAR2,cp_document_id VARCHAR2, cp_transaction_id VARCHAR2) IS
SELECT *
FROM   cont_line_item cli
WHERE  cli.object_id = cp_object_id AND
       cli.document_key = cp_document_id AND
       cli.transaction_key = cp_transaction_id AND
       cli.line_item_based_type = 'INTEREST' AND
       cli.interest_line_item_key IS NULL AND
       cli.line_item_template_id IS NOT NULL;


CURSOR c_li_interest_count(cp_object_id VARCHAR2,cp_document_id VARCHAR2, cp_transaction_id VARCHAR2) IS
SELECT count(*) num
FROM   cont_line_item cli
WHERE  cli.object_id = cp_object_id AND
       cli.document_key = cp_document_id AND
       cli.transaction_key = cp_transaction_id AND
       cli.line_item_based_type = 'INTEREST' AND
       cli.interest_line_item_key IS NULL AND
       cli.line_item_template_id IS NOT NULL;

CURSOR c_curr(cp_object_id VARCHAR2,cp_document_id VARCHAR2) IS
SELECT t.transaction_key--sum(t.trans_pricing_total) total
FROM cont_transaction t
WHERE t.object_id = cp_object_id AND
      t.document_key = cp_document_id AND
      t.preceding_trans_key IS NOT NULL AND
      t.reversal_ind = 'N';

CURSOR c_curr_corr(cp_object_id VARCHAR2,cp_document_id VARCHAR2, cp_trans_key VARCHAR2) IS
SELECT t.transaction_key--sum(t.trans_pricing_total) total
FROM cont_transaction t
WHERE t.object_id = cp_object_id AND
      t.document_key = cp_document_id AND
      t.transaction_key = cp_trans_key AND
      t.preceding_trans_key IS NOT NULL AND
      t.reversal_ind = 'N';

CURSOR C_rev(cp_object_id VARCHAR2,cp_document_id VARCHAR2) IS
SELECT sum(t.trans_pricing_value) total -- this column does not include VAT
FROM cont_transaction t
WHERE t.object_id = cp_object_id AND
      t.document_key = cp_document_id AND
      t.reversed_trans_key IS NOT NULL AND
      t.reversal_ind = 'Y';

CURSOR C_rev_corr(cp_object_id VARCHAR2,cp_document_id VARCHAR2, cp_trans_key VARCHAR2) IS
SELECT sum(t.trans_pricing_value) total -- this column does not include VAT
FROM cont_transaction t
WHERE t.object_id = cp_object_id AND
      t.reversed_trans_key IS NOT NULL AND
      t.reversal_ind = 'Y' AND
      t.document_key = cp_document_id AND
      t.reversed_trans_key = (select tp.preceding_trans_key from cont_Transaction tp
      where tp.transaction_key = cp_trans_key and
      tp.object_id = t.object_id and
      tp.document_key = t.document_key);

CURSOR c_li_curr(cp_object_id VARCHAR2,cp_document_id VARCHAR2, cp_transaction_id VARCHAR2) IS
SELECT sum(pricing_value) total
FROM   cont_line_item cli
WHERE  cli.object_id = cp_object_id AND
       cli.document_key = cp_document_id AND
       cli.transaction_key = cp_transaction_id AND
       cli.line_item_key NOT IN
       (
       SELECT cli2.line_item_key
       FROM   cont_line_item cli2
       WHERE  cli2.object_id = cp_object_id AND
              cli2.document_key = cp_document_id AND
              cli2.transaction_key = cp_transaction_id AND
              cli.line_item_based_type = 'INTEREST' AND
              cli.line_item_template_id IS NOT NULL
        );

BEGIN

lv2_doc_concept := ec_cont_document.document_concept(p_document_id);
lv2_int_base_amount_src := ec_cont_document.int_base_amount_src(p_document_id);
lv2_preceeding_doc_id := ec_cont_document.preceding_document_key(p_document_id);
lv2_customer_object_id := ecdp_contract_setup.GetDocCustomerId(p_document_id);
ln_doc_booking_total := ec_cont_document.doc_booking_total(lv2_preceeding_doc_id);
ld_from_date := ec_cont_document.pay_date(lv2_preceeding_doc_id);
lv2_price_index_id := ec_contract_doc_version.int_type_id(ec_cont_document.contract_doc_id(p_document_id), ld_from_date, '<=');
ln_base_rate := ec_price_in_item_value.index_value(lv2_price_index_id, ld_from_date, ec_price_input_item.class_name( lv2_price_index_id)||'_DAY_VALUE', '<=');



IF ln_doc_booking_total = 0 THEN -- Avoiding divide by zero
   ln_doc_booking_total :=1;
END IF;

ln_booking_pricing_conv_fac := nvl(ecdp_transaction.GetSumTransPricingTotal(lv2_preceeding_doc_id),0)/nvl(ln_doc_booking_total,1); -- Avoiding divide by zero

IF lv2_doc_concept NOT LIKE 'DEPENDENT%' AND lv2_doc_concept NOT IN ('REALLOCATION','MULTI_PERIOD') THEN
   RETURN;
END IF;

IF lv2_int_base_amount_src = 'PRECEDING_DOC' THEN -- Interest Base Amount from Preceding Document

  FOR c_val_t IN c_trans(p_object_id,p_document_id) LOOP       -- Looping through transactions..

      -- not doing anything for reversal line item
      IF c_val_t.reversal_ind = 'Y' AND c_val_t.preceding_trans_key IS NOT NULL THEN
         RETURN;
      END IF;

      FOR c_val_li_interest IN c_li_interest_count(p_object_id,p_document_id,c_val_t.transaction_key) LOOP     -- Counting interest line items connected to the
      ln_li_interest_count := c_val_li_interest.num;                                                           -- current document and transaction
      END LOOP;

      IF ln_li_interest_count = 1 THEN
        FOR c_val_li in c_line_item(p_object_id,p_document_id,c_val_t.transaction_key) LOOP                    -- One interest line item -> Continuing..

        IF c_val_li.source_line_item_key IS NOT NULL THEN
           RETURN; -- do nothing cause this is a regenerated line item based on preceding document
        END IF;

            IF c_val_li.line_item_based_type = 'INTEREST' THEN
               -- Setting variables from cont_pay_tracking
               lrec_cont_pay_tr := ec_cont_pay_tracking.row_by_pk(lv2_preceeding_doc_id,lv2_customer_object_id);

               -- Getting the greatest and latest tracking item number
               SELECT MAX(i.item_no)
                 INTO ln_latest_item_no
                 FROM cont_pay_tracking_item i
                WHERE i.object_id = lrec_cont_pay_tr.object_id
                  AND i.document_key = lrec_cont_pay_tr.document_key
                  AND i.customer_id = lrec_cont_pay_tr.customer_id;

               SELECT SUM(nvl(i.pay_received, 0))
                 INTO ln_sum_pay_received
                 FROM cont_pay_tracking_item i
                WHERE i.object_id = lrec_cont_pay_tr.object_id
                  AND i.document_key = lrec_cont_pay_tr.document_key
                  AND i.customer_id = lrec_cont_pay_tr.customer_id;

               SELECT COUNT(*)
                 INTO ln_cont_pay_track_item_count
                 FROM cont_pay_tracking_item i
                WHERE i.object_id = lrec_cont_pay_tr.object_id
                  AND i.document_key = lrec_cont_pay_tr.document_key
                  AND i.customer_id = lrec_cont_pay_tr.customer_id
                  AND i.pay_received_date <= ec_cont_pay_tracking_item.pay_received_date(ln_latest_item_no)
                  AND i.item_no <> ln_latest_item_no;

               IF ln_cont_pay_track_item_count = 0 THEN -- only got one payment tracking item
                  SELECT SUM(nvl(i.pay_received, 0))
                    INTO ln_init_sum_paid
                    FROM cont_pay_tracking_item i
                   WHERE i.object_id = lrec_cont_pay_tr.object_id
                     AND i.document_key = lrec_cont_pay_tr.document_key
                     AND i.customer_id = lrec_cont_pay_tr.customer_id
                     AND i.pay_received_date <= ec_cont_pay_tracking_item.pay_received_date(ln_latest_item_no);
               ELSE                                     -- got more than one payment tracking item
                  SELECT SUM(nvl(i.pay_received, 0))
                    INTO ln_init_sum_paid
                    FROM cont_pay_tracking_item i
                   WHERE i.object_id = lrec_cont_pay_tr.object_id
                     AND i.document_key = lrec_cont_pay_tr.document_key
                     AND i.customer_id = lrec_cont_pay_tr.customer_id
                     AND i.pay_received_date <= ec_cont_pay_tracking_item.pay_received_date(ln_latest_item_no)
                     AND i.item_no <> ln_latest_item_no;
               END IF;

               ln_initial_diff := nvl(lrec_cont_pay_tr.invoiced_amount,0) - ln_init_sum_paid;
               ln_payment_short := nvl(lrec_cont_pay_tr.invoiced_amount, 0) - nvl(ln_sum_pay_received, 0);
               ln_days_late_count := nvl(ec_cont_pay_tracking_item.pay_received_date(ln_latest_item_no) - ec_cont_pay_tracking_item.pay_date(ln_latest_item_no),0);
              ln_days_late_count := nvl(nvl(ec_cont_pay_tracking_item.pay_received_date(ln_latest_item_no), ec_cont_document.pay_date(p_document_id)) -
                                        nvl(ec_cont_pay_tracking_item.pay_date(ln_latest_item_no),ec_cont_document.pay_date(p_first_preceeding_doc))
                                        ,0);

               -- Determine if payment is not short and not late
               IF nvl(ln_payment_short, 0) = 0 AND nvl(ln_days_late_count, 0) <= 0 THEN
                  RETURN; -- do nothing
               END IF;

               -- Paid more regardless of payment date
               IF nvl(ln_payment_short, 0) < 0 THEN
                  RETURN; -- do nothing
               END IF;

               -- later than payment date
               IF ln_days_late_count > 0  THEN
                  IF ln_cont_pay_track_item_count = 0 THEN -- only gotone payment tracking item
                     ln_base_amount := nvl(lrec_cont_pay_tr.invoiced_amount,0) * ln_booking_pricing_conv_fac;
                  ELSE -- got more than one payment tracking item, base amount is sum of overdue payment tracking items
                     ln_base_amount := ln_initial_diff * ln_booking_pricing_conv_fac;
                  END IF;
                  ld_interest_from_date := nvl(ec_cont_pay_tracking_item.pay_date(ln_latest_item_no), ec_cont_document.pay_date(p_first_preceeding_doc));
                  ld_interest_to_date := nvl(ec_cont_pay_tracking_item.pay_received_date(ln_latest_item_no), ec_cont_document.pay_date(p_document_id));
               END IF;

               UPDATE cont_line_item cli -- Updating line item..
                  SET cli.interest_base_amount = ln_base_amount,
                      cli.base_rate = nvl(ln_base_rate,nvl(p_base_rate, 0)),
                      cli.interest_from_date = ld_interest_from_date,
                      cli.interest_to_date = ld_interest_to_date,
                      cli.pricing_value = 0
                WHERE cli.object_id = p_object_id
                  AND cli.line_item_key = c_val_li.line_item_key;

            END IF;

        END LOOP;
      END IF;

  END LOOP;

END IF; -- Interest Base Amount from Preceding Document

IF lv2_int_base_amount_src = 'CURRENT_DOC' THEN -- Interest Base Amount from Preceeding Document

  FOR c_val_t IN c_trans(p_object_id,p_document_id) LOOP       -- Looping through transactions..

      -- Determininng which values are added and which are reversed
      -- Added values..
      FOR c_val_curr IN c_curr(p_object_id,p_document_id) LOOP
            FOR c_li_val IN c_li_curr (p_object_id,p_document_id, c_val_curr.transaction_key) LOOP
                ln_curr_value := nvl(c_li_val.total,0); -- Excluding current line item from this sum
            END LOOP;
      END LOOP;

      -- Reversed values..
      FOR c_val_rev IN c_rev(p_object_id,p_document_id) LOOP
            ln_rev_value := nvl(c_val_rev.total,0);
      END LOOP;

        -- Interest Line Item Count
        FOR c_val_li_interest IN c_li_interest_count(p_object_id,p_document_id,c_val_t.transaction_key) LOOP     -- Counting interest line items connected to the
        ln_li_interest_count := c_val_li_interest.num;                                                           -- current document and transaction
        END LOOP;

      IF ln_li_interest_count = 1 THEN

        -- Updating Line Items
        FOR c_val_li in c_line_item(p_object_id,p_document_id,c_val_t.transaction_key) LOOP                    -- One interest line item -> Continuing..

            UPDATE         cont_line_item cli
            SET            cli.interest_base_amount = (ln_curr_value)+(ln_rev_value),
                           cli.base_rate = nvl(ln_base_rate,nvl(p_base_rate, 0)),
                           cli.interest_from_date = ec_cont_document.pay_date(p_first_preceeding_doc),
                           cli.interest_to_date = ec_cont_document.pay_date(p_document_id)
            WHERE          cli.object_id = p_object_id
            AND            cli.line_item_key = c_val_li.line_item_key;

        END LOOP;
      END IF;

  END LOOP;

END IF; -- Interest Base Amount from Current Document (Transactions)

IF lv2_int_base_amount_src = 'CORRECTION_INV_INTEREST' THEN
   -- Interest Base Amount: Pricing Values in current transaction
   -- Interest From Date: Due date from Preceding Document
   -- Interest To Date: Due date at current document
  FOR c_val_t IN c_trans(p_object_id,p_document_id) LOOP       -- Looping through transactions..

      -- Determininng which values are added and which are reversed
      -- Added values..
            FOR c_val_curr IN c_curr_corr(p_object_id,p_document_id,c_val_t.transaction_key) LOOP
            FOR c_li_val IN c_li_curr (p_object_id,p_document_id, c_val_curr.transaction_key) LOOP
                ln_curr_value := nvl(c_li_val.total,0); -- Excluding current line item from this sum
            END LOOP;
      END LOOP;

      -- Reversed values..
      FOR c_val_rev IN c_rev_corr(p_object_id,p_document_id, c_val_t.transaction_key) LOOP
            ln_rev_value := nvl(c_val_rev.total,0);
      END LOOP;

        -- Interest Line Item Count
        FOR c_val_li_interest IN c_li_interest_count(p_object_id,p_document_id,c_val_t.transaction_key) LOOP     -- Counting interest line items connected to the
        ln_li_interest_count := c_val_li_interest.num;                                                           -- current document and transaction
        END LOOP;

      IF ln_li_interest_count = 1 THEN

        -- Updating Line Items
        FOR c_val_li in c_line_item(p_object_id,p_document_id,c_val_t.transaction_key) LOOP                    -- One interest line item -> Continuing..

            UPDATE cont_line_item cli
               SET cli.interest_base_amount = (ln_curr_value) +
                                              (ln_rev_value),
                   cli.base_rate            = nvl(ln_base_rate,nvl(p_base_rate, 0)),
                   cli.interest_from_date   = ld_from_date,
                   cli.interest_to_date     = ec_cont_document.pay_date(p_document_id)
             WHERE cli.object_id = p_object_id
               AND cli.line_item_key = c_val_li.line_item_key;

        END LOOP;
      END IF;

  END LOOP;

END IF; -- Interest Base Amount from Current Document (Transactions)

END UpdIntBaseAmount;

PROCEDURE DelAllLineItemTemplates(
   p_trans_object_id VARCHAR2 -- TransactionTemplate Object_id
   )
IS
BEGIN
     -- Delete from version table first
     DELETE FROM line_item_tmpl_version litv
     WHERE litv.object_id IN
     (SELECT lit.object_id FROM line_item_template lit
         WHERE lit.transaction_template_id = p_trans_object_id);

     -- Delete from table
     DELETE FROM line_item_template lit
     WHERE lit.transaction_template_id = p_trans_object_id;
END DelAllLineItemTemplates;


PROCEDURE DelLineItemTemplate(
   p_line_item_id    VARCHAR2
   )
IS


CURSOR c_4e_litv(cp_line_item_id VARCHAR2) IS
  SELECT daytime, approval_state, rec_id
  FROM line_item_tmpl_version
  WHERE object_id = cp_line_item_id;
-- ** END 4-eyes approval stuff ** --

BEGIN

    -- Remove Referenced Line Items
    UPDATE cont_line_item SET
                    line_item_template_id = NULL,
                    last_updated_by = Nvl(EcDp_Context.getAppUser,User),
                    last_updated_date = Ecdp_Timestamp.getCurrentSysdate
    WHERE line_item_template_id = p_line_item_id;


    -- ** 4-eyes approval logic - Controlling DELETE ** --
    IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('LINE_ITEM_TEMPLATE'),'N') = 'Y' THEN

      -- Check status of deletion records and take appropriate action.
      FOR rs4e IN c_4e_litv(p_line_item_id) LOOP

          -- Updated or Official - Delete must be approved
          IF rs4e.approval_state IN ('U','O') THEN

             -- Set approval info on record
             UPDATE line_item_tmpl_version
                SET last_updated_by = Nvl(EcDp_Context.getAppUser,User),
                    last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
                    approval_state = 'D',
                    approval_by = null,
                    approval_date = null,
                    rec_id = rs4e.rec_id,
                    rev_no = (nvl(rev_no,0) + 1)
              WHERE object_id = p_line_item_id
                AND daytime = rs4e.daytime;

             -- Prepare record for approval
             Ecdp_Approval.registerTaskDetail(rs4e.rec_id,
                                              'LINE_ITEM_TEMPLATE',
                                              Nvl(EcDp_Context.getAppUser,User));
          ELSE
              -- Delete from version table first, then from main table
              DELETE FROM line_item_tmpl_version litv WHERE litv.object_id = p_line_item_id;
              DELETE FROM line_item_template lit WHERE lit.object_id = p_line_item_id;

              -- Updating ACL for if ringfencing is enabled
              IF (NVL(EcDp_ClassMeta_Cnfg.getAccessControlInd('LINE_ITEM_TEMPLATE'),'N') = 'Y') THEN
                 EcDp_Acl.RefreshObject(p_line_item_id, 'LINE_ITEM_TEMPLATE', 'DELETING');
              END IF;
          END IF;
      END LOOP;

      -- ** END 4-eyes approval ** --

    ELSE
        -- Delete from version table first, then from main table
        DELETE FROM line_item_tmpl_version litv WHERE litv.object_id = p_line_item_id;
        DELETE FROM line_item_template lit WHERE lit.object_id = p_line_item_id;

        -- Updating ACL for if ringfencing is enabled
        IF (NVL(EcDp_ClassMeta_Cnfg.getAccessControlInd('LINE_ITEM_TEMPLATE'),'N') = 'Y') THEN
           EcDp_Acl.RefreshObject(p_line_item_id, 'LINE_ITEM_TEMPLATE', 'DELETING');
        END IF;
    END IF;


END DelLineItemTemplate;




----------------------------------------------------------------------------------------------------

PROCEDURE GenLItemplateFromTransTempl(p_object_id         VARCHAR2,
                                      p_line_item_code    VARCHAR2,
                                      p_sort_order        VARCHAR2,
                                      p_trans_templ_id    VARCHAR2,
                                      p_stim_val_cat_code VARCHAR2,
                                      p_vat_code          VARCHAR2,
                                      p_daytime           DATE,
                                      p_user              VARCHAR2 DEFAULT NULL)

IS

-- select all price lemenets which shall have values entered to them
CURSOR c_price_elem(pc_price_concept_code VARCHAR2) IS
SELECT
     pce.price_concept_code
    ,pce.price_element_code
    ,pce.name
    ,pce.sort_order
    ,pce.line_item_type
    ,pce.group_ind
FROM price_concept_element pce, price_concept pc
WHERE
    pce.price_concept_code = pc.price_concept_code
    AND pc.price_concept_code = pc_price_concept_code
  AND NOT EXISTS -- any line items
      (SELECT 'x' FROM line_item_template r,line_item_tmpl_version rv
        WHERE r.transaction_template_id = p_trans_templ_id
        AND p_daytime >= Nvl(r.start_date,p_daytime-1)
        AND p_daytime < Nvl(r.end_date,p_daytime+1)
        AND r.object_id = rv.object_id
        AND p_daytime >= Nvl(rv.daytime,p_daytime-1)
        AND p_daytime < Nvl(rv.end_date,p_daytime+1)
        AND rv.line_item_based_type = ecdp_revn_ft_constants.li_btype_quantity
        AND rv.price_concept_code = pc.price_concept_code
        AND rv.price_element_code = pce.price_element_code
      )
ORDER BY sort_order;

CURSOR c_count IS
  SELECT COUNT(*) cnt
    FROM line_item_template lit, line_item_tmpl_version litv
   WHERE lit.transaction_template_id = p_trans_templ_id
     AND lit.object_id = litv.object_id
     AND litv.daytime <= p_daytime
     AND NVL(litv.end_date, p_daytime + 1) > p_daytime
     AND litv.line_item_based_type = ecdp_revn_ft_constants.li_btype_quantity;

CURSOR c_last_sort_order IS
  SELECT MAX(NVL(lit.sort_order, 0)) as sort_order
    FROM line_item_template lit, line_item_tmpl_version litv
   WHERE lit.transaction_template_id = p_trans_templ_id
     AND lit.object_id = litv.object_id
     AND litv.daytime <= p_daytime
     AND NVL(litv.end_date, p_daytime + 1) > p_daytime
     AND litv.line_item_based_type = ecdp_revn_ft_constants.li_btype_quantity;

lv2_price_object_id VARCHAR2(32) := ec_transaction_tmpl_version.price_object_id(p_trans_templ_id, p_daytime, '<=');
lv2_price_concept_code VARCHAR2(32) := ec_product_price.price_concept_code(lv2_price_object_id);
lv2_li_templ_id VARCHAR2(32) := NULL;
lv2_product_group_code VARCHAR2(32) := ec_contract_version.product_type(p_object_id, p_daytime, '<=');
lv_stim_value_cat_code VARCHAR2(32) := NULL;
ln_sort_order NUMBER;
lv2_code NUMBER;
lv2_full_code VARCHAR2(32);
lv_count_lit NUMBER ;
too_many_qty_line_items EXCEPTION;
no_available_price_elements EXCEPTION;
qty_line_item_already_exists EXCEPTION;

-- ** 4-eyes approval stuff ** --
lv2_4e_recid VARCHAR2(32);
-- ** END 4-eyes approval stuff ** --

BEGIN

     -- If transaction is set up with price src type = PRICING VALUE, do not allow more than one qty line item.
     -- When calculating new unit price from transaction level it will not be possible to split the new unit price to several line items.
     IF ec_transaction_tmpl_version.price_src_type(p_trans_templ_id, p_daytime, '<=') = 'PRICING_VALUE' THEN
       FOR rsC IN c_count LOOP

         IF rsC.Cnt > 0 THEN

           RAISE too_many_qty_line_items;

         END IF;

       END LOOP;
     END IF;

     -- if product group is 200 (gas), STIM_VALUE_CATEGORY_CODE is defaulted to 'NET'
     IF lv2_product_group_code = '200' THEN
        lv_stim_value_cat_code := 'NET_CURRENT';
     ELSE
        lv_stim_value_cat_code := p_stim_val_cat_code;
     END IF;

     -- If there is already a CALC_QTY_VALUE line item present then do not allow to insert a new QTY line item
     SELECT
           count(1)
     INTO  lv_count_lit
     FROM
         line_item_template lit, line_item_tmpl_version litv
     WHERE
         lit.transaction_template_id = p_trans_templ_id
         AND lit.object_id = litv.object_id
         AND litv.daytime <= p_daytime
         AND NVL(litv.end_date, p_daytime + 1) > p_daytime
         AND litv.line_item_based_type = 'CALC_QTY_VALUE' ;

     IF lv_count_lit > 0  THEN

         RAISE qty_line_item_already_exists ;
     END IF ;

     -- Generate sort order
     ln_sort_order := 10; --Default sort order starting point
     IF p_sort_order IS NOT NULL THEN
       --Sort order is given by the user
       ln_sort_order := p_sort_order;
     ELSE
       --Get the next sort order from the database
       FOR rsC IN c_last_sort_order LOOP
         IF rsC.sort_order > 0 THEN
           ln_sort_order := rsC.sort_order + 1;
         END IF;
       END LOOP;
     END IF;

     -- No price object on TT
     IF (lv2_price_object_id IS NULL) THEN

          -- Generate Object_Code for Line Item Template
          IF p_line_item_code IS NOT NULL THEN
            lv2_full_code := p_line_item_code;
          ELSE
            lv2_full_code := 'LIT:'||to_char(ECDP_system_key.AssignNextUniqueNumber('LINE_ITEM_TEMPLATE', 'OBJECT_CODE', 'LIT:'));
          END IF;

          INSERT INTO line_item_template
            (object_code,
             start_date,
             end_date,
             transaction_template_id,
             sort_order,
             created_by)
          VALUES
            (lv2_full_code,
             p_daytime,
             ec_transaction_tmpl_version.end_date(p_trans_templ_id, p_daytime, '<='),
             p_trans_templ_id,
             ln_sort_order,
             p_user)
          RETURNING object_id INTO lv2_li_templ_id;


          INSERT INTO line_item_tmpl_version
            (object_id,
             name,
             line_item_based_type,
             stim_value_category_code,
             vat_code_1,
             daytime,
             end_date,
             created_by)
          VALUES
            (lv2_li_templ_id,
             lv2_full_code,
             ecdp_revn_ft_constants.li_btype_quantity,
             lv_stim_value_cat_code,
             p_vat_code,
             p_daytime,
             ec_transaction_tmpl_version.end_date(p_trans_templ_id, p_daytime, '<='),
             p_user);


          -- ** 4-eyes approval logic ** --
          IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('LINE_ITEM_TEMPLATE'),'N') = 'Y' THEN

            -- Generate rec_id for the new version record
            lv2_4e_recid := SYS_GUID();

            -- Set approval info on version record. PS! Never do this on a main object table. Approval is only intended for the version attributes.
            UPDATE line_item_tmpl_version
            SET last_updated_by = Nvl(EcDp_Context.getAppUser,User),
                last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
                approval_state = 'N',
                rec_id = lv2_4e_recid,
                rev_no = (nvl(rev_no,0) + 1)
            WHERE object_id = lv2_li_templ_id
            AND daytime = p_daytime;

            -- Register version record for approval
            Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                              'LINE_ITEM_TEMPLATE',
                                              Nvl(EcDp_Context.getAppUser,User));
          END IF;
          -- ** END 4-eyes approval ** --

          --Updaing ACL for if ringfencing is enabled
          IF (NVL(EcDp_ClassMeta_Cnfg.getAccessControlInd('LINE_ITEM_TEMPLATE'),'N') = 'Y') THEN
          -- Update ACL
              EcDp_Acl.RefreshObject(lv2_li_templ_id, 'LINE_ITEM_TEMPLATE', 'INSERTING');
          END IF;


       ELSE

         FOR PRCLCur IN c_price_elem(lv2_price_concept_code) LOOP

              -- Generate Object_Code for Line Item Template
              IF (p_line_item_code IS NOT NULL) AND (lv2_full_code IS NULL) THEN
                lv2_full_code := p_line_item_code;
              ELSE
                lv2_full_code := 'LIT:'||to_char(ECDP_system_key.AssignNextUniqueNumber('LINE_ITEM_TEMPLATE', 'OBJECT_CODE', 'LIT:'));
              END IF;

              INSERT INTO line_item_template
                (object_code,
                 start_date,
                 transaction_template_id,
                 description,
                 sort_order,
                 created_by)
              VALUES
                (lv2_full_code,
                 p_daytime,
                 p_trans_templ_id,
                 PRCLCur.name,
                 ln_sort_order,
                 p_user)
              RETURNING object_id INTO lv2_li_templ_id;


              INSERT INTO line_item_tmpl_version
                (object_id,
                 name,
                 line_item_based_type,
                 line_item_type,
                 price_element_code,
                 price_concept_code,
                 group_ind,
                 stim_value_category_code,
                 vat_code_1,
                 daytime,
                 created_by)
              VALUES
                (lv2_li_templ_id,
                 PRCLCur.name,
                 ecdp_revn_ft_constants.li_btype_quantity,
                 PRCLCur.Line_Item_Type,
                 PRCLCur.Price_Element_Code,
                 lv2_price_concept_code,
                 PRCLCur.Group_Ind,
                 lv_stim_value_cat_code,
                 p_vat_code,
                 p_daytime,
                 p_user);


              -- ** 4-eyes approval logic ** --
              IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('LINE_ITEM_TEMPLATE'),'N') = 'Y' THEN

                -- Generate rec_id for the new version record
                lv2_4e_recid := SYS_GUID();

                -- Set approval info on version record. PS! Never do this on a main object table. Approval is only intended for the version attributes.
                UPDATE line_item_tmpl_version
                SET last_updated_by = Nvl(EcDp_Context.getAppUser,User),
                    last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
                    approval_state = 'N',
                    rec_id = lv2_4e_recid,
                    rev_no = (nvl(rev_no,0) + 1)
                WHERE object_id = lv2_li_templ_id
                AND daytime = p_daytime;

                -- Register version record for approval
                Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                                  'LINE_ITEM_TEMPLATE',
                                                  Nvl(EcDp_Context.getAppUser,User));
              END IF;
              -- ** END 4-eyes approval ** --

              --Updaing ACL for if ringfencing is enabled
              IF (NVL(EcDp_ClassMeta_Cnfg.getAccessControlInd('LINE_ITEM_TEMPLATE'),'N') = 'Y') THEN
              -- Update ACL
                  EcDp_Acl.RefreshObject(lv2_li_templ_id, 'LINE_ITEM_TEMPLATE', 'INSERTING');
              END IF;

              -- Increase sort order
              ln_sort_order := ln_sort_order + 1;

         END LOOP;

     END IF;


     -- If price element was not found for this line item, let the user know why his new row will not be stored.
     IF lv2_li_templ_id IS NULL THEN

        RAISE no_available_price_elements;

     END IF;

EXCEPTION
  WHEN too_many_qty_line_items THEN
      RAISE_APPLICATION_ERROR(-20000, 'Can not insert new quantity line item.\n\nOnly one Quantity Line Item allowed when Transaction \nPrice Source Type is based on Pricing Value.');

  WHEN no_available_price_elements THEN
      RAISE_APPLICATION_ERROR(-20000, 'Can not insert new quantity line item.\n\nNo available price element for price concept ' || lv2_price_concept_code || '.');

  WHEN qty_line_item_already_exists THEN
      RAISE_APPLICATION_ERROR(-20000, 'Not allowed to add a ''Quantity Based'' (QTY) type of line item template if one or more ''Calculate Qty and Pricing Value'' (CALC_QTY_VALUE) line item templates already exists on the same transaction template.');


END GenLItemplateFromTransTempl;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : InsNewLITemplate
-- Description    : Inserts a new line item template
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : line_item_template, line_item_tmpl_version
--
-- Using functions: InsInterestLineItem
-- Configuration
-- required       :
--
-- Behaviour      : Called from the screen Contract Transaction Mapping.
-------------------------------------------------------------------------------------------------------------------------------
PROCEDURE InsNewLITemplateFromApp
( p_trans_templ_id VARCHAR2,
  p_line_item_code VARCHAR2,
  p_sort_order     NUMBER,
  p_li_based_type  VARCHAR2,
  p_li_type        VARCHAR2,
  p_name           VARCHAR2,
  p_pct_value      NUMBER,
  p_li_value       NUMBER,
  p_unit_prc       NUMBER,
  p_unit_prc_unit  VARCHAR2,
  p_vat_code       VARCHAR2,
  p_daytime        DATE,   -- Versioning will be aligned with the transaction template
  p_user           VARCHAR2 DEFAULT NULL,
  p_calculation_id VARCHAR2 DEFAULT NULL,
  p_price_object_id VARCHAR2 DEFAULT NULL,
  p_ifac_li_conn_code VARCHAR2 DEFAULT NULL
)
--</EC-DOC>
IS
lv2_obj_id                   VARCHAR2(32);
ln_int_num_days              NUMBER;
lv2_code                     VARCHAR2(32);
lv2_price_concept_code       VARCHAR2(32);
ln_sort_order                NUMBER;

CURSOR c_qty_li_template (cp_transaction_template_id VARCHAR2) IS
  SELECT l.object_id
    FROM line_item_template l, line_item_tmpl_version lv
   WHERE l.transaction_template_id = cp_transaction_template_id
     AND lv.line_item_based_type = ecdp_revn_ft_constants.li_btype_quantity
     AND l.object_id = lv.object_id
     AND l.start_date <= p_daytime
     AND p_daytime < nvl(l.end_date, p_daytime + 1)
     AND p_daytime <= lv.daytime;

CURSOR c_price_elem_rec (cp_price_concept_code VARCHAR2) IS
  SELECT pce.price_element_code,
         pce.price_concept_code,
         pce.name,
         pce.line_item_type
    FROM price_concept_element pce
   WHERE pce.price_concept_code = cp_price_concept_code;

CURSOR c_price_elem_exist (cp_price_concept_code VARCHAR2) IS
  SELECT COUNT(pce.price_element_code) n
    FROM price_concept_element pce
   WHERE pce.price_concept_code = cp_price_concept_code;

CURSOR c_last_sort_order IS
  SELECT MAX(NVL(lit.sort_order, 0)) as sort_order
    FROM line_item_template lit, line_item_tmpl_version litv
   WHERE lit.transaction_template_id = p_trans_templ_id
     AND lit.object_id = litv.object_id
     AND litv.daytime <= p_daytime
     AND NVL(litv.end_date, p_daytime + 1) > p_daytime
     AND (litv.line_item_based_type IS NULL OR litv.line_item_based_type <> ecdp_revn_ft_constants.li_btype_quantity);

CURSOR c_exist_free_unit_po (cp_transaction_template_id VARCHAR2, p_price_object_id VARCHAR2) IS
  SELECT l.object_id
    FROM line_item_template l, line_item_tmpl_version lv
   WHERE l.transaction_template_id = cp_transaction_template_id
     AND lv.line_item_based_type = 'FREE_UNIT_PRICE_OBJECT'
     AND lv.price_object_id = p_price_object_id
     AND l.object_id = lv.object_id
     AND l.start_date <= p_daytime
     AND p_daytime < nvl(l.end_date, p_daytime + 1)
     AND p_daytime <= lv.daytime;

-- ** 4-eyes approval stuff ** --
lv2_4e_recid                    VARCHAR2(32);
-- ** END 4-eyes approval stuff ** --

P_LI_BASED_TYPE_EMPTY_EX        EXCEPTION;
P_LI_TYPE_EMPTY_EX              EXCEPTION;
P_LI_PRICE_OBJECT_EMPTY_EX      EXCEPTION;
P_LI_PRICE_OBJECT_EXISTS        EXCEPTION;

BEGIN

  -- Check mandatory parameters
  IF p_li_based_type IS NULL THEN
      RAISE P_LI_BASED_TYPE_EMPTY_EX;
  END IF;

  -- Non-Quantity line item templates have to have line
  -- item type set
  IF p_li_type IS NULL AND p_li_based_type not in (ecdp_revn_ft_constants.li_btype_quantity,'FREE_UNIT_PRICE_OBJECT') THEN
      RAISE P_LI_TYPE_EMPTY_EX;
  END IF;

  -- FREE_UNIT_PRICE_OBJECT must have a price object
  IF p_li_based_type = 'FREE_UNIT_PRICE_OBJECT' AND p_price_object_id IS NULL THEN
      RAISE P_LI_PRICE_OBJECT_EMPTY_EX;
  END IF;

-- FREE_UNIT_PRICE_OBJECT cant use the same price object more than once
  IF p_li_based_type = 'FREE_UNIT_PRICE_OBJECT' AND p_price_object_id IS NOT NULL THEN
      --Check if this price object is there already
      for x in c_exist_free_unit_po(p_trans_templ_id, p_price_object_id) loop
          RAISE P_LI_PRICE_OBJECT_EXISTS;
      end loop;
  END IF;

  -- Generate sort order
  ln_sort_order := 50; --Default sort order starting point
  IF p_sort_order IS NOT NULL THEN
    --Sort order is given by the user
    ln_sort_order := p_sort_order;
  ELSE
    --Get the next sort order from the database
    FOR rsC IN c_last_sort_order LOOP
      IF rsC.sort_order > 0 THEN
        ln_sort_order := rsC.sort_order + 1;
      END IF;
    END LOOP;
  END IF;

  -- Not allowed to add a calculation rule or a calculation sequence number to a non-calculated line item
  IF p_li_based_type NOT IN ('CALC_VALUE','CALC_QTY_VALUE') THEN

    IF p_calculation_id IS NOT NULL THEN
       RAISE_APPLICATION_ERROR(-20000,'Not allowed to add a calculation to a non-calculated line item.');
    END IF;

  END IF;

  -- Not allowed to add a CALC_QTY_VALUE calculation rule if quantity based line item templates already exist on current transaction template
  IF p_li_based_type = 'CALC_QTY_VALUE' THEN

     FOR v IN c_qty_li_template (p_trans_templ_id) LOOP
         RAISE_APPLICATION_ERROR(-20000,'Not allowed to add a CALC_QTY_VALUE line item if one or more quantity based line item templates already exists on the same transaction template.');
     END LOOP;

  END IF;
  If p_li_based_type = 'INTEREST' THEN
     ln_int_num_days := ec_contract_doc_version.int_num_days(ec_transaction_template.contract_doc_id(p_trans_templ_id), p_daytime, '<=');
  ELSE
     ln_int_num_days := null;
  END IF;

  lv2_price_concept_code := ec_product_price.price_concept_code(p_price_object_id);

  IF p_price_object_id IS NOT NULL THEN

   IF p_li_based_type <> 'FREE_UNIT_PRICE_OBJECT' THEN
      RAISE_APPLICATION_ERROR(-20000,'Not allowed to add a price object on this line item based type');
   END IF;


   -- Not allowed to continue if price object is selected, but no price elements are found.
   FOR c_pce_rec_ex IN c_price_elem_exist (lv2_price_concept_code) LOOP
            IF c_pce_rec_ex.n = 0 THEN
               RAISE_APPLICATION_ERROR(-20000,'No price element(s) found on selected price object.');
            END IF;
        END LOOP;


    -- This loop will make sure one line item template is inserted for each price element that exists on the price concept in use.
    FOR c_pce_rec IN c_price_elem_rec (lv2_price_concept_code) LOOP

      -- Generate Object_Code for Line Item Template
      IF p_line_item_code IS NOT NULL THEN
        lv2_code := p_line_item_code;
      ELSE
        lv2_code := 'LIT:' || to_char(ECDP_system_key.AssignNextUniqueNumber('LINE_ITEM_TEMPLATE', 'OBJECT_CODE', 'LIT:'));
      END IF;

      -- insert into main object table
      INSERT INTO line_item_template
        (object_code,
         start_date,
         end_date,
         transaction_template_id,
         sort_order,
         description,
         created_by)
      VALUES
        (lv2_code,
         p_daytime,
         ec_transaction_tmpl_version.end_date(p_trans_templ_id, p_daytime, '<='),
         p_trans_templ_id,
         ln_sort_order,
         c_pce_rec.name,
         p_user)
      RETURNING object_id INTO lv2_obj_id;

      -- insert into object version table
      INSERT INTO line_item_tmpl_version
        (object_id,
         line_item_based_type,
         line_item_type,
         percentage_value,
         line_item_value,
         unit_price,
         unit_price_unit,
         vat_code_1,
         interest_num_days,
         calculation_id,
         price_object_id,
         price_concept_code,
         price_element_code,
         ifac_li_conn_code,
         name, -- Required for approval
         daytime,
         end_date,
         created_by)
      VALUES
        (lv2_obj_id,
         p_li_based_type,
         c_pce_rec.line_item_type,
         p_pct_value/100,
         p_li_value,
         p_unit_prc,
         p_unit_prc_unit,
         p_vat_code,
         ln_int_num_days,
         p_calculation_id,
         p_price_object_id,
         c_pce_rec.price_concept_code,
         c_pce_rec.price_element_code,
         p_ifac_li_conn_code,
         c_pce_rec.name, -- Price element name as name for line item template
         p_daytime,
         ec_transaction_tmpl_version.end_date(p_trans_templ_id, p_daytime, '<='),
         p_user);


      -- ** 4-eyes approval logic ** --
      IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('LINE_ITEM_TEMPLATE'),'N') = 'Y' THEN

        -- Generate rec_id for the new version record
        lv2_4e_recid := SYS_GUID();

        -- Set approval info on version record. PS! Never do this on a main object table. Approval is only intended for the version attributes.
        UPDATE line_item_tmpl_version
        SET last_updated_by = Nvl(EcDp_Context.getAppUser,User),
            last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
            approval_state = 'N',
            rec_id = lv2_4e_recid,
            rev_no = (nvl(rev_no,0) + 1)
        WHERE object_id = lv2_obj_id
        AND daytime = p_daytime;

        -- Register version record for approval
        Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                          'LINE_ITEM_TEMPLATE',
                                          Nvl(EcDp_Context.getAppUser,User));
      END IF;
      -- ** END 4-eyes approval ** --


      --Updaing ACL for if ringfencing is enabled
      IF (NVL(EcDp_ClassMeta_Cnfg.getAccessControlInd('LINE_ITEM_TEMPLATE'),'N') = 'Y') THEN
      -- Update ACL
              EcDp_Acl.RefreshObject(lv2_obj_id, 'LINE_ITEM_TEMPLATE', 'INSERTING');
      END IF;

      -- Cleanup
      lv2_obj_id := NULL;
      ln_sort_order := ln_sort_order + 1;

    END LOOP;

ELSE

      -- Generate Object_Code for Line Item Template
      IF p_line_item_code IS NOT NULL THEN
        lv2_code := p_line_item_code;
      ELSE
        lv2_code := 'LIT:' ||to_char(ECDP_system_key.AssignNextUniqueNumber('LINE_ITEM_TEMPLATE', 'OBJECT_CODE', 'LIT:'));
      END IF;

      -- insert into main object table
      INSERT INTO line_item_template
        (object_code,
         start_date,
         transaction_template_id,
         sort_order,
         created_by)
      VALUES
        (lv2_code,
         p_daytime,
         p_trans_templ_id,
         ln_sort_order,
         p_user)
      RETURNING object_id INTO lv2_obj_id;

      -- insert into object version table
      INSERT INTO line_item_tmpl_version
        (object_id,
         line_item_based_type,
         line_item_type,
         percentage_value,
         line_item_value,
         unit_price,
         unit_price_unit,
         vat_code_1,
         interest_num_days,
         calculation_id,
         ifac_li_conn_code,
         name, -- Required for approval
         daytime,
         end_date,
         created_by)
      VALUES
        (lv2_obj_id,
         p_li_based_type,
         p_li_type,
         p_pct_value/100,
         p_li_value,
         p_unit_prc,
         p_unit_prc_unit,
         p_vat_code,
         ln_int_num_days,
         p_calculation_id,
         p_ifac_li_conn_code,
         p_name,
         p_daytime,
         ec_transaction_tmpl_version.end_date(p_trans_templ_id, p_daytime, '<='),
         p_user);


      -- ** 4-eyes approval logic ** --
      IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('LINE_ITEM_TEMPLATE'),'N') = 'Y' THEN

        -- Generate rec_id for the new version record
        lv2_4e_recid := SYS_GUID();

        -- Set approval info on version record. PS! Never do this on a main object table. Approval is only intended for the version attributes.
        UPDATE line_item_tmpl_version
        SET last_updated_by = Nvl(EcDp_Context.getAppUser,User),
            last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
            approval_state = 'N',
            rec_id = lv2_4e_recid,
            rev_no = (nvl(rev_no,0) + 1)
        WHERE object_id = lv2_obj_id
        AND daytime = p_daytime;

        -- Register version record for approval
        Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                          'LINE_ITEM_TEMPLATE',
                                          Nvl(EcDp_Context.getAppUser,User));
      END IF;
      -- ** END 4-eyes approval ** --


      --Updaing ACL for if ringfencing is enabled
      IF (NVL(EcDp_ClassMeta_Cnfg.getAccessControlInd('LINE_ITEM_TEMPLATE'),'N') = 'Y') THEN
      -- Update ACL
              EcDp_Acl.RefreshObject(lv2_obj_id, 'LINE_ITEM_TEMPLATE', 'INSERTING');
      END IF;


END IF;

EXCEPTION
  WHEN P_LI_BASED_TYPE_EMPTY_EX THEN
    Raise_Application_Error(-20000,'Line Item Concept does not have a value.');

  WHEN P_LI_TYPE_EMPTY_EX THEN
    Raise_Application_Error(-20000,'Line Item Type does not have a value.');

  WHEN P_LI_PRICE_OBJECT_EMPTY_EX THEN
    Raise_Application_Error(-20000,'Price Object does not have a value for the Free Unit Price Object line.');

  WHEN P_LI_PRICE_OBJECT_EXISTS THEN
    Raise_Application_Error(-20000,'Not allowed to use the same Price Object for two separate Free Unit Price Object Line Item Templates.');

END InsNewLITemplateFromApp;




PROCEDURE UpdLineItemTemplateFromApp(p_li_templ_id             VARCHAR2,
                              p_sort_order              NUMBER,
                              p_li_based_type           VARCHAR2,
                              p_li_type                 VARCHAR2,
                              p_name                    VARCHAR2,
                              p_pct_value               NUMBER,
                              p_li_value                NUMBER,
                              p_unit_prc                NUMBER,
                              p_unit_prc_unit           VARCHAR2,
                              p_vat_code                VARCHAR2,
                              p_daytime                 DATE,
                              p_user                    VARCHAR2 DEFAULT NULL,
                              p_calculation_id          VARCHAR2 DEFAULT NULL,
                              p_price_object_id         VARCHAR2 DEFAULT NULL,
                              p_line_item_template_code VARCHAR2 DEFAULT NULL,
                              p_ifac_li_conn_code       VARCHAR2 DEFAULT NULL)
IS

lv_transaction_template_id    VARCHAR2(32);
lv2_old_price_object_id       VARCHAR2(32);
ln_int_num_days               NUMBER;
lv_calculation_id             VARCHAR2(32);

CURSOR c_qty_li_template (cp_transaction_template_id VARCHAR2) IS
  SELECT l.object_id
    FROM line_item_template l, line_item_tmpl_version lv
   WHERE l.transaction_template_id = cp_transaction_template_id
     AND lv.line_item_based_type = ecdp_revn_ft_constants.li_btype_quantity
     AND l.object_id = lv.object_id
     AND l.start_date <= p_daytime
     AND p_daytime < nvl(l.end_date, p_daytime + 1)
     AND p_daytime <= lv.daytime;

--Cursor for deleting Line Item Templates for FREE_UNIT_PRICE_OBJECT:
CURSOR c_del_price_elem_lit (cp_transaction_template_id VARCHAR2, cp_old_price_object_id VARCHAR2, cp_daytime DATE ) IS
SELECT l.object_id
    FROM line_item_template l, line_item_tmpl_version lv
   WHERE l.transaction_template_id = cp_transaction_template_id
     AND lv.line_item_based_type = 'FREE_UNIT_PRICE_OBJECT'
     AND lv.price_object_id = cp_old_price_object_id
     AND l.object_id = lv.object_id
     AND l.start_date <= cp_daytime
     AND cp_daytime < nvl(l.end_date, cp_daytime + 1)
     AND cp_daytime <= lv.daytime;

-- ** 4-eyes approval stuff ** --
CURSOR c_4e_litv(cp_line_item_id VARCHAR2, cp_daytime DATE) IS
  SELECT approval_state, rec_id
  FROM line_item_tmpl_version
  WHERE object_id = cp_line_item_id
  AND daytime = cp_daytime;
-- ** END 4-eyes approval stuff ** --

P_LI_BASED_TYPE_EMPTY_EX EXCEPTION;
P_LI_TYPE_EMPTY_EX EXCEPTION;

BEGIN

  -- Check mandatory parameters
  IF p_li_based_type IS NULL THEN
      RAISE P_LI_BASED_TYPE_EMPTY_EX;
  END IF;

  -- Non-Quantity line item templates have to have line
  -- item type set
  IF p_li_type IS NULL AND p_li_based_type not in (ecdp_revn_ft_constants.li_btype_quantity,'FREE_UNIT_PRICE_OBJECT') THEN
      RAISE P_LI_TYPE_EMPTY_EX;
  END IF;


  lv_transaction_template_id := ec_line_item_template.transaction_template_id(p_li_templ_id);
  lv2_old_price_object_id := ec_line_item_tmpl_version.price_object_id(p_li_templ_id,p_daytime,'<=');

  -- Not allowed to add a calculation rule or a calculation sequence number to a non-calculated line item
  IF p_li_based_type NOT IN ('CALC_VALUE','CALC_QTY_VALUE') THEN

    lv_calculation_id := null;
  ELSE
    lv_calculation_id := p_calculation_id;

  END IF;

  -- Not allowed to add a CALC_QTY_VALUE calculation rule if quantity based line item templates already exist on current transaction template
  IF p_li_based_type = 'CALC_QTY_VALUE' THEN

     FOR v IN c_qty_li_template (lv_transaction_template_id) LOOP
         RAISE_APPLICATION_ERROR(-20000,'Not allowed to add a CALC_QTY_VALUE calculation rule if one or more quantity based line item templates already exists on the same transaction template.');
     END LOOP;

  END IF;

  If p_li_based_type = 'INTEREST' THEN
     ln_int_num_days := ec_contract_doc_version.int_num_days(ec_transaction_template.contract_doc_id(lv_transaction_template_id), p_daytime, '<=');
  ELSE
     ln_int_num_days := null;
  END IF;

  IF p_li_based_type = 'FREE_UNIT_PRICE_OBJECT' THEN


        IF lv2_old_price_object_id <> p_price_object_id THEN
          --old price object id is held by lv2_price_object_id
          --delete old LIT entries for the 'other' price elements of the price concept
          for x in c_del_price_elem_lit(lv_transaction_template_id, lv2_old_price_object_id, p_daytime) loop
            DelLineItemTemplate(x.object_id);
          end loop;
          --Insert new LITs for the new Price Object:
          InsNewLITemplateFromApp(lv_transaction_template_id,
                                  null, --p_line_item_code,
                                  p_sort_order,
                                  'FREE_UNIT_PRICE_OBJECT', --p_li_based_type,
                                  p_li_type,
                                  p_name,
                                  null, --p_pct_value,
                                  null, --p_li_value,
                                  null, --p_unit_prc,
                                  p_unit_prc_unit,
                                  p_vat_code,
                                  p_daytime,
                                  p_user,
                                  null, --p_calculation_id,
                                  p_price_object_id,
                                  p_ifac_li_conn_code);
        END IF;

  END IF;



    -- update main object table
    UPDATE line_item_template
       SET object_code = nvl(p_line_item_template_code, object_code),
           sort_order = p_sort_order
     WHERE object_id = p_li_templ_id;

    -- update object version table
    UPDATE line_item_tmpl_version
       SET line_item_based_type = p_li_based_type,
           line_item_type       = p_li_type,
           percentage_value     = p_pct_value / 100,
           line_item_value      = p_li_value,
           interest_num_days    = ln_int_num_days,
           unit_price           = DECODE(p_li_based_type,
                                         'FREE_UNIT_PRICE_OBJECT',
                                         NULL,
                                         p_unit_prc),
           unit_price_unit      = p_unit_prc_unit,
           vat_code_1           = p_vat_code,
           calculation_id       = lv_calculation_id, --p_calculation_id,
           price_object_id      = p_price_object_id,
           name                 = p_name,
           ifac_li_conn_code    = p_ifac_li_conn_code,
           end_date             = ec_transaction_tmpl_version.end_date(lv_transaction_template_id, p_daytime, '<='),
           last_updated_by      = p_user,
           last_updated_date    = Ecdp_Timestamp.getCurrentSysdate
     WHERE object_id = p_li_templ_id
       AND daytime = p_daytime;


  -- ** 4-eyes approval logic ** --
  IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('LINE_ITEM_TEMPLATE'),'N') = 'Y' THEN

     FOR rs4e IN c_4e_litv(p_li_templ_id,p_daytime) LOOP

        -- Only demand approval if a record is in Official state
        IF rs4e.approval_state = 'O' THEN

           -- Set approval info on record
           UPDATE line_item_tmpl_version
           SET last_updated_by = Nvl(EcDp_Context.getAppUser,User),
               last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
               approval_state = 'U',
               approval_by = null,
               approval_date = null,
               rev_no = (nvl(rev_no,0) + 1)
           WHERE rec_id = rs4e.rec_id;

           -- Prepare record for approval
           Ecdp_Approval.registerTaskDetail(rs4e.rec_id,
                                            'LINE_ITEM_TEMPLATE',
                                            Nvl(EcDp_Context.getAppUser,User));
        END IF;
     END LOOP;
  END IF;
  -- ** END 4-eyes approval ** --

EXCEPTION
  WHEN P_LI_BASED_TYPE_EMPTY_EX THEN
    Raise_Application_Error(-20000,'Line Item Concept Type does not have a value.');

  WHEN P_LI_TYPE_EMPTY_EX THEN
    Raise_Application_Error(-20000,'Line Item Type does not have a value.');

END UpdLineItemTemplateFromApp;



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  GenLITemplateCopy
-- Description    :
--
-- Preconditions  : Used from the function ecdp_contract_setup.GenContractCopy. Creating copies of line item templates based on the items found on
--                  transactions on the contract that is being copied.
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
FUNCTION GenLITemplateCopy
( p_LI_id                 VARCHAR2, -- Copy from
  p_trans_templ_id        VARCHAR2,
  p_code                  VARCHAR2,
  p_name                  VARCHAR2,
  p_user                  VARCHAR2,
  p_start_date            DATE default NULL,
  P_end_date              DATE default NULL,
  p_skip_cont_setup       VARCHAR2 DEFAULT 'N'
)
RETURN VARCHAR2
IS

lrec_lit line_item_template%ROWTYPE;
lrec_lit_version line_item_tmpl_version%ROWTYPE;
lv2_lit line_item_template.object_id%TYPE;
lv2_price_object_id VARCHAR2(32) := NULL;

  -- ** 4-eyes approval stuff ** --
  lv2_4e_recid VARCHAR2(32);
  -- ** END 4-eyes approval stuff ** --

BEGIN

lrec_lit := ec_line_item_template.row_by_pk(p_LI_id);
lrec_lit_version := ec_line_item_tmpl_version.row_by_pk(p_LI_id,lrec_lit.start_date,'<=');

    IF p_skip_cont_setup = 'N' THEN
        FOR i IN 1..Ecdp_Contract_Setup.tab_price_object.count LOOP
             IF (Ecdp_Contract_Setup.tab_price_object(i).old_object_id = lrec_lit_version.price_object_id) THEN
                 lv2_price_object_id := Ecdp_Contract_Setup.tab_price_object(i).new_object_id;
             END IF;
        END LOOP;
    END IF;

INSERT INTO line_item_template
  (object_code,
   start_date,
   end_date,
   transaction_template_id,
   description,
   sort_order,
   created_by)
VALUES
  (p_code,
  NVL(p_start_date, lrec_lit.start_date),
  decode(lrec_lit.end_date,to_date(NULL),to_date(NULL),nvl(P_end_date,lrec_lit.end_date)),
  p_trans_templ_id,
  lrec_lit.description,
  lrec_lit.sort_order,
  p_user)
RETURNING object_id INTO lv2_lit;


INSERT INTO line_item_tmpl_version
  (object_id,
   daytime,
   end_date,
   name,
   interest_num_days,
   line_item_based_type,
   line_item_type,
   percentage_value,
   line_item_value,
   stim_value_category_code,
   unit_price,
   unit_price_unit,
   price_concept_code,
   price_element_code,
   price_object_id,
   group_ind,
   calculation_id,
   comments,
   vat_code_1,
   vat_code_2,
   created_by)
VALUES
  (lv2_lit,
   NVL(p_start_date, lrec_lit_version.daytime),
   decode(lrec_lit_version.end_date,to_date(NULL),to_date(NULL),nvl(P_end_date,lrec_lit_version.end_date)),
   lrec_lit_version.name,
   lrec_lit_version.interest_num_days,
   lrec_lit_version.line_item_based_type,
   lrec_lit_version.line_item_type,
   lrec_lit_version.percentage_value,
   lrec_lit_version.line_item_value,
   lrec_lit_version.stim_value_category_code,
   lrec_lit_version.unit_price,
   lrec_lit_version.unit_price_unit,
   lrec_lit_version.price_concept_code,
   lrec_lit_version.price_element_code,
   NVL(lv2_price_object_id, lrec_lit_version.price_object_id),
   lrec_lit_version.group_ind,
   lrec_lit_version.calculation_id,
   lrec_lit_version.comments,
   lrec_lit_version.vat_code_1,
   lrec_lit_version.vat_code_2,
   p_user);

   -- ** 4-eyes approval logic ** --
    IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('LINE_ITEM_TEMPLATE'),'N') = 'Y' THEN

      -- Generate rec_id for the new record
      lv2_4e_recid := SYS_GUID();

      -- Set approval info on new record.
      UPDATE line_item_tmpl_version
      SET last_updated_by = Nvl(EcDp_Context.getAppUser,User),
          last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
          approval_state = 'N',
          rec_id = lv2_4e_recid,
          rev_no = (nvl(rev_no,0) + 1)
      WHERE object_id = lv2_lit
      AND daytime = NVL(p_start_date, lrec_lit_version.daytime);

      -- Register new record for approval
      Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                        'LINE_ITEM_TEMPLATE',
                                        Nvl(EcDp_Context.getAppUser,User));
    END IF;
    -- ** END 4-eyes approval ** --

   --Updating ACL for if ringfencing is enabled
   IF (NVL(EcDp_ClassMeta_Cnfg.getAccessControlInd('LINE_ITEM_TEMPLATE'),'N') = 'Y') THEN
          EcDp_Acl.RefreshObject(lv2_lit, 'LINE_ITEM_TEMPLATE', 'INSERTING');
   END IF;

RETURN lv2_lit;

END GenLITemplateCopy;

PROCEDURE InsNewLITemplateForTT(
                               p_trans_templ_id VARCHAR2,
                               p_line_item_id   VARCHAR2,
                               p_prev_daytime   DATE,
                               p_daytime        DATE,   -- Versioning will be aligned with the transaction template
                               p_end_date       DATE,
                               p_name           VARCHAR2,
                               p_user           VARCHAR2
                               )
IS
    lv2_code VARCHAR2(32);
    lv2_lit line_item_template.object_id%TYPE;
BEGIN

    lv2_code := 'LIT:'||to_char(ECDP_system_key.AssignNextUniqueNumber('LINE_ITEM_TEMPLATE', 'OBJECT_CODE', 'LIT:'));

    lv2_lit := EcDp_Line_Item.GenLITemplateCopy(
          p_line_item_id, -- Copy from
          p_trans_templ_id,
          lv2_code,
          p_name,
          p_user,
          p_daytime,
          p_end_date,
          'Y'
          );

    --Set object_end_date of line item
    UPDATE line_item_template
       SET end_date = p_daytime
     WHERE object_id = p_line_item_id
       AND start_date = p_prev_daytime;

    UPDATE line_item_tmpl_version
       SET end_date = p_daytime
     WHERE object_id = p_line_item_id
       AND daytime = p_prev_daytime;

END InsNewLITemplateForTT;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetLatestCompound
-- Description    : Returns the line_item_key for the latest compound
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
FUNCTION GetLatestCompound(p_line_item_key VARCHAR2)
RETURN NUMBER
--</EC-DOC>


IS

lv_transaction_key cont_transaction.transaction_key%TYPE := ec_cont_line_item.transaction_key(p_line_item_key);
lv_object_id contract.object_id%TYPE := ec_cont_line_item.object_id(p_line_item_key);
lv_interest_group VARCHAR2(32) := ec_cont_line_item.interest_group(p_line_item_key);


CURSOR c_latest IS
SELECT c.line_item_key
  FROM cont_line_item c
 WHERE c.object_id = lv_object_id
   AND c.transaction_key = lv_transaction_key
   AND c.name LIKE '%Compound'
   AND c.interest_group = lv_interest_group
   AND c.interest_from_date =
       (SELECT MAX(cli.interest_from_date)
          FROM cont_line_item cli
         WHERE cli.object_id = lv_object_id
           AND cli.transaction_key = lv_transaction_key
           AND cli.interest_group = lv_interest_group);

ln_check NUMBER := 1;

BEGIN

FOR c_val IN c_latest LOOP

    IF c_val.line_item_key = p_line_item_key THEN
       ln_check := 1;
     ELSE
         ln_check := 0;
     END IF;

END LOOP;

RETURN ln_check;

END GetLatestCompound;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetLineItemLocalValue
-- Description    : Returns the value on the line item in local currency specified on either preceeding (#1) or current document (#2)
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
FUNCTION GetLineItemLocalValue(p_line_item_key VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS

lrec_li cont_line_item%rowtype := ec_cont_line_item.row_by_pk(p_line_item_key);
ln_value_local NUMBER;
ln_ex_local NUMBER;

BEGIN

-- Using local exchange rate from preceeding document if exists
IF ec_cont_transaction.reversed_trans_key(lrec_li.transaction_key) IS NULL THEN
   ln_ex_local := ec_cont_transaction.ex_booking_local(lrec_li.transaction_key);
   ELSE
      ln_ex_local := ec_cont_transaction.ex_booking_local(ec_cont_transaction.reversed_trans_key(lrec_li.transaction_key));

END IF;

ln_value_local := ROUND(nvl(lrec_li.booking_value,0) * nvl(ln_ex_local,0),2);

RETURN ln_value_local;

END GetLineItemLocalValue;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : DelLineItemChildRecords
-- Description    : Before deletion of a record in cont_line_item_dist, this procedure make sure all child records in child tables are deleted
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : cont_line_item_dist_uom,
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      : Called from d_cont_line_item_dist
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE DelLineItemChildRecords(p_line_item_id   VARCHAR2,
                                  p_dist_id        VARCHAR2)
--</EC-DOC>
IS

BEGIN

-- deleting from cont_li_dist_company
DELETE FROM cont_li_dist_company d
 WHERE d.line_item_key = p_line_item_id
   AND d.dist_id = p_dist_id;

-- deleting from cont_line_item_dist_uom
DELETE FROM cont_line_item_dist_uom d
 WHERE d.line_item_key = p_line_item_id
   AND d.dist_id = p_dist_id;

END DelLineItemChildRecords;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : ValidateCalcQtyValueLI
-- Description    : Called from class transaction template.
--                  If the line item based type equals CALC_QTY_VALUE for the line item template that is being validated,
--                  then record is only allowed to be inserted if there exist no quantity line item templates on the transaction
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
PROCEDURE ValidateCalcQtyValueLI(p_transaction_template_id VARCHAR2,
                                 p_li_based_type          VARCHAR2,
                                 p_daytime                DATE)

--</EC-DOC>
IS

lv_result VARCHAR2(32);

CURSOR c_qty_li (cp_transaction_template_id VARCHAR2, cp_daytime DATE) IS
SELECT l.object_id
  FROM line_item_template l, line_item_tmpl_version lv
 WHERE l.transaction_template_id = cp_transaction_template_id
   AND lv.line_item_based_type = ecdp_revn_ft_constants.li_btype_quantity
   AND l.object_id = lv.object_id
   AND lv.daytime < nvl(l.end_date, lv.daytime + 1)
   AND lv.daytime <= cp_daytime;

BEGIN


FOR v IN c_qty_li (p_transaction_template_id, p_daytime) LOOP

   IF lv_result IS NULL THEN
       lv_result := v.object_id;
    END IF;
END LOOP;

IF lv_result IS NOT NULL THEN
   RAISE_APPLICATION_ERROR(-20000,'A CALC_QTY_VALUE based-type line item template can not be placed on a transaction that has quantity line item templates');
END IF;



END ValidateCalcQtyValueLI;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetInterestBaseRate
-- Description    :
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

FUNCTION GetInterestBaseRate (
         p_daytime DATE,
         p_frequency VARCHAR2,
         p_unit VARCHAR2,
         p_rate_type_code VARCHAR2 -- Check if input Rate Type is matching a price index code. Also check on NAME?
         )
RETURN NUMBER
--</EC-DOC>
IS

  CURSOR c_PI(cp_daytime DATE, cp_frequency VARCHAR2, cp_unit VARCHAR2, cp_rate_type_code VARCHAR2) IS
    SELECT p.object_code, piv.*
    FROM price_input_item p, price_in_item_version pv, price_in_item_value piv
    WHERE p.object_id = pv.object_id
    AND pv.daytime = (SELECT MAX(daytime) FROM price_in_item_version WHERE object_id = p.object_id AND daytime <= cp_daytime)
    AND piv.object_id = p.object_id
    AND piv.daytime = cp_daytime
    AND pv.frequency = cp_frequency
    AND pv.unit = cp_unit
    AND p.object_code = cp_rate_type_code;

  ln_ret_base_rate NUMBER := NULL;

BEGIN

  FOR rsPI IN c_PI(p_daytime, p_frequency, p_unit, p_rate_type_code) LOOP
    ln_ret_base_rate := rsPI.Index_Value;
  END LOOP;

  RETURN ln_ret_base_rate;

END GetInterestBaseRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : updLITName
-- Description    :
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
PROCEDURE updLITName
( p_object_id         VARCHAR2,
  p_daytime           DATE,
  p_user              VARCHAR2 DEFAULT NULL
)

IS

lv2_desc line_item_template.description%TYPE;

BEGIN

lv2_desc := ec_line_item_template.description(p_object_id);

UPDATE line_item_tmpl_version l
   SET l.name = nvl(lv2_desc,l.name), l.last_updated_by = NVL(p_user,l.last_updated_by)
 WHERE l.object_id = p_object_id
   AND l.daytime = p_daytime;

END updLITName;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : UpdateLineItemShares
-- Description    :
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

PROCEDURE UpdateLineItemShares
(  p_transaction_key VARCHAR2,
   p_preceeding_transaction_key VARCHAR2
)
IS

CURSOR c_transactional_distribution IS
(select dist_id, 'D' origin
  from cont_line_item_dist
 where transaction_key = p_transaction_key
minus
select dist_id, 'D' origin
  from cont_line_item_dist
 where transaction_key = p_preceeding_transaction_key)
union
(select dist_id, 'P' origin
  from cont_line_item_dist
 where transaction_key = p_preceeding_transaction_key
minus
select dist_id, 'P' origin
  from cont_line_item_dist
 where transaction_key = p_transaction_key)
ORDER BY origin DESC;

  CURSOR c_cont_line_item_dist (cp_transaction_key VARCHAR2) IS
    SELECT transaction_key,line_item_based_type
      FROM cont_line_item_dist
    WHERE transaction_key = cp_transaction_key
 GROUP BY transaction_key,line_item_based_type;

  CURSOR c_cont_li_dist_company (cp_transaction_key VARCHAR2) IS
    SELECT transaction_key,line_item_based_type,dist_id
      FROM cont_li_dist_company
    WHERE transaction_key = cp_transaction_key
 GROUP BY transaction_key,line_item_based_type,dist_id;

ln_si_diff NUMBER;
lv2_dist_source_code VARCHAR2(1);

BEGIN

FOR v IN c_transactional_distribution LOOP
       lv2_dist_source_code := v.origin;

       EXIT WHEN lv2_dist_source_code = 'P';
END LOOP;




     IF NVL(lv2_dist_source_code,'N/A') <> 'P' THEN
       FOR clid in c_cont_line_item_dist(p_transaction_key) LOOP
        UPDATE cont_line_item_dist n_di
           set n_di.split_share      = NVL((SELECT max(o_di.split_share)
                                             from cont_line_item_dist o_di
                                            where o_di.transaction_key =
                                                  p_preceeding_transaction_key
                                              and line_item_based_type =  n_di.line_item_based_type
                                              and o_di.dist_id =
                                                  n_di.dist_id),
                                           0),
               n_di.split_share_qty2 =
               (select max(o_di.split_share_qty2)
                  from cont_line_item_dist o_di
                 where o_di.transaction_key = p_preceeding_transaction_key
                                           and o_di.dist_id = n_di.dist_id
                   and line_item_based_type =  n_di.line_item_based_type
                   and o_di.split_share_qty2 IS NOT NULL),
               n_di.split_share_qty3 =
               (select max(o_di.split_share_qty3)
                  from cont_line_item_dist o_di
                 where o_di.transaction_key = p_preceeding_transaction_key
                                           and o_di.dist_id = n_di.dist_id
                   and line_item_based_type =  n_di.line_item_based_type
                   and o_di.split_share_qty3 IS NOT NULL),
               n_di.split_share_qty4 =
               (select max(o_di.split_share_qty4)
                  from cont_line_item_dist o_di
                 where o_di.transaction_key = p_preceeding_transaction_key
                   and line_item_based_type =  n_di.line_item_based_type
                                           and o_di.dist_id = n_di.dist_id
                   and o_di.split_share_qty4 IS NOT NULL)
         WHERE n_di.transaction_key = clid.transaction_key
           AND n_di.line_item_based_type = clid.line_item_based_type;
       END LOOP;
     END IF;

    select count(*)
      into ln_si_diff
      from ((select company_stream_item_id
               from cont_li_dist_company
              where transaction_key = p_transaction_key
             minus
             select company_stream_item_id
               from cont_li_dist_company
              where transaction_key = p_preceeding_transaction_key) union
            (select company_stream_item_id
               from cont_li_dist_company
              where transaction_key = p_preceeding_transaction_key
             minus
             select company_stream_item_id
               from cont_li_dist_company
              where transaction_key = p_transaction_key)) sis;

     IF ln_si_diff = 0 THEN
       FOR clidc in c_cont_li_dist_company(p_transaction_key) LOOP
        UPDATE cont_li_dist_company n_di
           set n_di.vendor_share     =
               (select max( o_di.vendor_share)
                  from cont_li_dist_company o_di
                 where o_di.transaction_key = p_preceeding_transaction_key
                   and o_di.stream_item_id = n_di.stream_item_id
                   and line_item_based_type = n_di.line_item_based_type
                   and dist_id = n_di.dist_id
                   and o_di.company_stream_item_id =
                       n_di.company_stream_item_id),
               n_di.customer_share   = 1,
               n_di.split_share      =
               (select max( o_di.split_share)
                  from cont_li_dist_company o_di
                 where o_di.transaction_key = p_preceeding_transaction_key
                   and o_di.stream_item_id = n_di.stream_item_id
                   and line_item_based_type =  n_di.line_item_based_type
                   and dist_id = n_di.dist_id
                   and o_di.company_stream_item_id =
                       n_di.company_stream_item_id),
               n_di.vendor_share_qty2 =
               (select max( o_di.vendor_share_qty2)
                  from cont_li_dist_company o_di
                 where o_di.transaction_key = p_preceeding_transaction_key
                   and o_di.stream_item_id = n_di.stream_item_id
                   and line_item_based_type =  n_di.line_item_based_type
                   and dist_id = n_di.dist_id
                   and o_di.company_stream_item_id =
                       n_di.company_stream_item_id
                   and o_di.vendor_share_qty2 IS NOT NULL),
               n_di.vendor_share_qty3 =
               (select max( o_di.vendor_share_qty3)
                  from cont_li_dist_company o_di
                 where o_di.transaction_key = p_preceeding_transaction_key
                   and o_di.stream_item_id = n_di.stream_item_id
                   and line_item_based_type =  n_di.line_item_based_type
                   and dist_id = n_di.dist_id
                   and o_di.company_stream_item_id =
                       n_di.company_stream_item_id
                   and o_di.vendor_share_qty3 IS NOT NULL),
               n_di.vendor_share_qty4 =
               (select max( o_di.vendor_share_qty4)
                  from cont_li_dist_company o_di
                 where o_di.transaction_key = p_preceeding_transaction_key
                   and o_di.stream_item_id = n_di.stream_item_id
                   and line_item_based_type =  n_di.line_item_based_type
                   and dist_id = n_di.dist_id
                   and o_di.company_stream_item_id =
                       n_di.company_stream_item_id
                   and o_di.vendor_share_qty4 IS NOT NULL)
         WHERE n_di.transaction_key = p_transaction_key
           AND n_di.line_item_based_type = clidc.line_item_based_type
           AND n_di.dist_id = clidc.dist_id;
      END LOOP;

     END IF;



END UpdateLineItemShares;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getFieldQty2Share
-- Description    :
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
FUNCTION getFieldQty2Share(p_line_item_key  VARCHAR2,
                           p_stream_item VARCHAR2,
                           p_dist_id VARCHAR2) RETURN NUMBER
--</EC-DOC>
IS

ln_trans_net_qty2 NUMBER;
ln_li_dist_qty2   NUMBER;
ln_share          NUMBER;

BEGIN

-- alternative
ln_trans_net_qty2 := nvl(ec_cont_transaction_qty.net_qty2(ec_cont_line_item.transaction_key(p_line_item_key)),0);
ln_li_dist_qty2 := nvl(ec_cont_line_item_dist.qty2(p_line_item_key,p_dist_id,p_stream_item),0);

IF (ln_trans_net_qty2 = 0 AND ln_li_dist_qty2 = 0) OR ln_trans_net_qty2 = 0 THEN


   ln_share := NULL;
 ELSE
   ln_share := ln_li_dist_qty2/ln_trans_net_qty2;
END IF;

RETURN ln_share;

END getFieldQty2Share;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getFieldQty3Share
-- Description    :
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
FUNCTION getFieldQty3Share(p_line_item_key VARCHAR2,
                           p_stream_item VARCHAR2,
                           p_dist_id VARCHAR2)
  RETURN NUMBER
--</EC-DOC>
IS

ln_trans_net_qty3 NUMBER;
ln_li_dist_qty3   NUMBER;
ln_share          NUMBER;

BEGIN


ln_trans_net_qty3 := nvl(ec_cont_transaction_qty.net_qty3(ec_cont_line_item.transaction_key(p_line_item_key)),0);
ln_li_dist_qty3 := nvl(ec_cont_line_item_dist.qty3(p_line_item_key,p_dist_id,p_stream_item),0);


IF (ln_trans_net_qty3 = 0 AND ln_li_dist_qty3 = 0) OR ln_trans_net_qty3 = 0 THEN
   ln_share := NULL;
 ELSE
   ln_share := ln_li_dist_qty3/ln_trans_net_qty3;
END IF;

RETURN ln_share;

END getFieldQty3Share;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getFieldQty4Share
-- Description    :
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
FUNCTION getFieldQty4Share(p_line_item_key VARCHAR2,
                           p_stream_item VARCHAR2,
                           p_dist_id VARCHAR2)
  RETURN NUMBER
--</EC-DOC>
IS

ln_trans_net_qty4 NUMBER;
ln_li_dist_qty4   NUMBER;
ln_share          NUMBER;

BEGIN


ln_trans_net_qty4 := nvl(ec_cont_transaction_qty.net_qty4(ec_cont_line_item.transaction_key(p_line_item_key)),0);
ln_li_dist_qty4 := nvl(ec_cont_line_item_dist.qty4(p_line_item_key,p_dist_id,p_stream_item),0);


IF (ln_trans_net_qty4 = 0 AND ln_li_dist_qty4 = 0) OR ln_trans_net_qty4 = 0 THEN
   ln_share := NULL;
 ELSE
   ln_share := ln_li_dist_qty4/ln_trans_net_qty4;
END IF;

RETURN ln_share;

END getFieldQty4Share;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getFieldCompanyQty2Share
-- Description    :
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
FUNCTION getFieldCompanyQty2Share(p_line_item_key VARCHAR2,
                                  p_stream_item   VARCHAR2,
                                  p_dist_id       VARCHAR2,
                                  p_vendor_id     VARCHAR2,
                                  p_customer_id   VARCHAR2) RETURN NUMBER
--</EC-DOC>
IS

ln_f_qty2  NUMBER;
ln_fc_qty2 NUMBER;
ln_share   NUMBER;

BEGIN

ln_f_qty2 := ec_cont_line_item_dist.qty2(p_line_item_key,p_dist_id,p_stream_item);
ln_fc_qty2 := nvl(ec_cont_li_dist_company.qty2(p_line_item_key,p_dist_id,p_vendor_id,p_customer_id,p_stream_item),0);


IF (ln_f_qty2 = 0 AND ln_fc_qty2 = 0) OR ln_f_qty2 = 0 THEN
   ln_share := NULL;
 ELSE
   ln_share := ln_fc_qty2/ln_f_qty2;
END IF;

RETURN ln_share;

END getFieldCompanyQty2Share;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getFieldCompanyQty3Share
-- Description    :
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
FUNCTION getFieldCompanyQty3Share(p_line_item_key VARCHAR2,
                                  p_stream_item   VARCHAR2,
                                  p_dist_id       VARCHAR2,
                                  p_vendor_id     VARCHAR2,
                                  p_customer_id   VARCHAR2) RETURN NUMBER
--</EC-DOC>
IS

ln_f_qty3  NUMBER;
ln_fc_qty3 NUMBER;
ln_share   NUMBER;

BEGIN


ln_f_qty3 := ec_cont_line_item_dist.qty3(p_line_item_key,p_dist_id,p_stream_item);
ln_fc_qty3 := nvl(ec_cont_li_dist_company.qty3(p_line_item_key,p_dist_id,p_vendor_id,p_customer_id,p_stream_item),0);


IF (ln_f_qty3 = 0 AND ln_fc_qty3 = 0) OR ln_f_qty3 = 0 THEN
   ln_share := NULL;
 ELSE
   ln_share := ln_fc_qty3/ln_f_qty3;
END IF;

RETURN ln_share;

END getFieldCompanyQty3Share;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getFieldCompanyQty4Share
-- Description    :
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
FUNCTION getFieldCompanyQty4Share(p_line_item_key VARCHAR2,
                                  p_stream_item   VARCHAR2,
                                  p_dist_id       VARCHAR2,
                                  p_vendor_id     VARCHAR2,
                                  p_customer_id   VARCHAR2) RETURN NUMBER
--</EC-DOC>
IS

ln_f_qty4  NUMBER;
ln_fc_qty4 NUMBER;
ln_share   NUMBER;

BEGIN


ln_f_qty4 := ec_cont_line_item_dist.qty4(p_line_item_key,p_dist_id,p_stream_item);
ln_fc_qty4 := nvl(ec_cont_li_dist_company.qty4(p_line_item_key,p_dist_id,p_vendor_id,p_customer_id,p_stream_item),0);


IF (ln_f_qty4 = 0 AND ln_fc_qty4 = 0) OR ln_f_qty4 = 0 THEN
   ln_share := NULL;
 ELSE
   ln_share := ln_fc_qty4/ln_f_qty4;
END IF;

RETURN ln_share;

END getFieldCompanyQty4Share;


PROCEDURE DelEmptyLineItems(
        p_transaction_key VARCHAR2
)
IS

  CURSOR c_LI(cp_transaction_key VARCHAR2) IS
    SELECT li.*
      FROM cont_line_item li
     WHERE li.transaction_key = cp_transaction_key;

  lrec_trans cont_transaction%ROWTYPE := ec_cont_transaction.row_by_pk(p_transaction_key);
  lb_del_LI BOOLEAN := FALSE;

BEGIN

  -- Try to delete the whole transaction if all line items are empty
  IF NOT ecdp_transaction.DelEmptyTransaction(p_transaction_key) THEN

    -- The transaction was not entirely empty. Delete only the empty line items.
    FOR rsLI IN c_li(p_transaction_key) LOOP

      IF IsLineItemEmpty(rsLI.Line_Item_Key) THEN

        DelLineItem(rsLI.object_id, rsLI.line_item_key);
        lb_del_LI := TRUE;

      END IF;

    END LOOP;

    IF lb_del_LI THEN

      -- Update VAT country and NO for document
      EcDp_Document.UpdDocumentVat(lrec_trans.document_key, ec_cont_document.daytime(lrec_trans.document_key), NULL);

    END IF;


  END IF;

END DelEmptyLineItems;


------------------------+-----------------------------------+------------------------------------+---------------------------
-- Deletes the empty line items from cont line item which have matching interface line item for teh transaction
------------------------+-----------------------------------+--------

PROCEDURE DelEmptyLineItemsFromTemp(
        p_document_key VARCHAR2
)
IS


  CURSOR cur_ct(cp_document_key VARCHAR2) IS
    SELECT ct.object_id, ct.transaction_key, ct.document_key
      FROM cont_transaction ct
     WHERE ct.document_key = cp_document_key
       AND nvl(ct.reversal_ind,'N') = 'N';

  CURSOR c_li(cp_transaction_key VARCHAR2) IS
  SELECT cli.line_item_template_id,cli.line_item_based_type,cli.line_item_type,cli.ifac_li_conn_code,cli.pricing_value,cli.qty1
  ,cli.creation_method,cli.line_item_key
    FROM cont_line_item cli
  WHERE cli.transaction_key = cp_transaction_key
    and ((cli.creation_method='INTERFACE')
         OR (cli.creation_method ='AUTO_GENERATED'
            AND cli.line_item_based_type = 'QTY'
            AND cli.qty1 is null))
         ;


  CURSOR c_li_temp(li_temp_id VARCHAR2, li_transaction_key VARCHAR2, li_key varchar2) IS
  SELECT *
    FROM cont_line_item cli
   WHERE cli.transaction_key = li_transaction_key
     AND NVL(cli.line_item_template_id,'XX') = nvl(li_temp_id,'XX')
     AND cli.name not like '%Compound'
     AND (cli.creation_method ='AUTO_GENERATED'
         or line_item_key = li_key);

  ln_cnt NUMBER;
  lb_deleted BOOLEAN := FALSE;
  p_transaction_key varchar2(32);
  p_li_temp_id varchar2(32);

BEGIN

   FOR cTrans in cur_ct(p_document_key) LOOP
     p_transaction_key := cTrans.transaction_key;
       FOR rsLI IN c_li(p_transaction_key) LOOP
         p_li_temp_id := rsli.line_item_template_id;
            FOR rsLITemp IN c_li_temp(p_li_temp_id, p_transaction_key,rsLI.line_item_based_type) LOOP
                IF IsLineItemEmpty(RSLITEMP.LINE_ITEM_KEY) THEN
                   DelLineItem(rsLITemp.object_id, rsLITemp.line_item_key);
                END IF;
            END LOOP;
        END LOOP;
   END LOOP;

END DelEmptyLineItemsFromTemp;


FUNCTION IsLineItemEmpty(
               p_line_item_key VARCHAR2
)
RETURN BOOLEAN
IS

  lrec_li cont_line_item%ROWTYPE := ec_cont_line_item.row_by_pk(p_line_item_key);
  lb_ret_val BOOLEAN;

BEGIN

   IF (lrec_li.line_item_based_type = ecdp_revn_ft_constants.li_btype_quantity AND lrec_li.QTY1 IS NOT NULL) OR
      (lrec_li.line_item_based_type = 'CALC_QTY_VALUE'         AND lrec_li.QTY1 IS NOT NULL) OR
      (lrec_li.line_item_based_type = 'FREE_UNIT_PRICE_OBJECT' AND lrec_li.price_object_id IS NOT NULL) OR
      (lrec_li.line_item_based_type = 'FREE_UNIT'              AND lrec_li.FREE_UNIT_QTY IS NOT NULL) OR
      (lrec_li.line_item_based_type = 'PERCENTAGE_QTY'         AND lrec_li.Percentage_Value IS NOT NULL) OR
      (lrec_li.line_item_based_type = 'PERCENTAGE_MANUAL'      AND lrec_li.Percentage_Value IS NOT NULL) OR
      (lrec_li.line_item_based_type = 'PERCENTAGE_ALL'         AND lrec_li.Percentage_Value IS NOT NULL) OR
      (lrec_li.line_item_based_type = 'INTEREST'               AND lrec_li.PRICING_VALUE IS NOT NULL AND lrec_li.interest_type IS NOT NULL) OR
      (lrec_li.line_item_based_type = 'FIXED_VALUE'            AND lrec_li.line_item_value IS NOT NULL OR lrec_li.pricing_value IS NOT NULL) OR
      (lrec_li.line_item_based_type = 'CALC_VALUE'             AND lrec_li.calculation_id IS NOT NULL) THEN

      -- TODO: OLII Han Yi - should remove lrec_li.line_item_value from FIXED_VALUE case?

      lb_ret_val := FALSE;

   ELSE

      lb_ret_val := TRUE;

   END IF;

   RETURN lb_ret_val;

END IsLineItemEmpty;




--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : InsPPATransIntLineItem
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions: InsInterestLineItem
-- Configuration
-- required       :
-- Behaviour      :
--  Status per 09.02.2012:
--   To be able to create a interest line item on a PPA Transaction you will need to add a line item template of base type INTEREST and type PPA_INTEREST.
--   Then the system will create a interest line item for each transaction that has a preceding transaction.
--   From date is payment due date on preceding document, To date is due date on this document.
--   Base rate is picked up based on payment due date on preceding document.
--   Description (name) of line item given in Transaction Mapping will be applied to all the interest line items.
--   No need to have a quantity line item to have an interest line item.
--
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE InsPPATransIntLineItem(p_document_key varchar2,
                                 p_user VARCHAR2,
                                 p_transaction_key VARCHAR2 DEFAULT NULL)
--</EC-DOC>

IS

/* t      : THIS transaction
   pt     : PRECEDING transaction
   pd     : PRECEDING document
*/

  CURSOR c_transactions(cp_document_key VARCHAR2,
                        cp_transaction_key VARCHAR2 DEFAULT NULL) IS
    SELECT transaction_key
      FROM cont_transaction ct
     WHERE document_key = cp_document_key
      AND transaction_key = nvl(cp_transaction_key,ct.transaction_key);

    CURSOR c_LI_template(cp_trans_template_id VARCHAR2,
                         cp_daytime           VARCHAR2) IS
    SELECT lit.object_id AS line_item_template_id
      FROM line_item_template lit,
           line_item_tmpl_version litv
     WHERE lit.transaction_template_id = cp_trans_template_id
       AND litv.line_item_based_type = 'INTEREST'
       AND lit.object_id = litv.object_id
       AND litv.daytime =
           (SELECT max(daytime)
              FROM line_item_tmpl_version
              WHERE object_id = lit.object_id
               AND daytime <= cp_daytime);

  CURSOR c_int_LI(cp_transaction_key VARCHAR2) IS
    SELECT cli.interest_base_amount,
           cli.line_item_key,
           cli.object_id
      FROM cont_line_item cli
     WHERE cli.transaction_key = cp_transaction_key
       AND cli.line_item_based_type = 'INTEREST'; -- get the main line item, not compounding. Should return only one row.


CURSOR c_Child_Transactions(cp_transaction_key VARCHAR2) IS
  SELECT MAX(ct.document_key) first_doc
    FROM cont_transaction ct
   WHERE ct.preceding_trans_key = cp_transaction_key
   HAVING COUNT(*)>0;


  lrec_trans cont_transaction%ROWTYPE;
  lrec_document cont_document%ROWTYPE;
  lrec_cdv contract_doc_version%ROWTYPE;
  lrec_lit line_item_tmpl_version%ROWTYPE;
  ln_val                            NUMBER;
  lv2_line_item_key                 VARCHAR2(32);
  ln_base_rate                      NUMBER;
  ln_prec_base_amt                  NUMBER;
  ln_from_date                      DATE;
  lv2_child_doc                     VARCHAR2(32);
  child_exists                      EXCEPTION;
BEGIN

  lrec_document := ec_cont_document.row_by_pk(p_document_key);

  FOR tran IN c_transactions(p_document_key,p_transaction_key) LOOP
    ln_from_date := null;

    IF lrec_document.document_concept = 'MULTI_PERIOD' OR ec_cont_transaction.ppa_trans_code(tran.transaction_key) = 'PPA_PRICE' THEN

      lrec_trans := ec_cont_transaction.row_by_pk(tran.transaction_key);

      FOR LI_template IN c_LI_template(lrec_trans.trans_template_id,
                                       lrec_trans.daytime)  LOOP

        IF ue_cont_line_item.isInsPPATransIntLIUEE = 'TRUE' THEN
          ue_cont_line_item.InsPPATransIntLineItem(lrec_trans.transaction_key, LI_template.line_item_template_id, p_user);
        ELSE

          IF ue_cont_line_item.isInsPPATransIntLIPreUEE = 'TRUE' THEN
            ue_cont_line_item.InsPPATransIntLineItemPre(lrec_trans.transaction_key, LI_template.line_item_template_id, p_user);
          END IF;

          FOR child IN c_Child_Transactions(lrec_trans.transaction_key) LOOP

              lv2_child_doc := child.First_Doc;
              RAISE child_exists;

          END LOOP;

          IF lrec_trans.preceding_trans_key IS NOT NULL THEN

            lrec_document := ec_cont_document.row_by_pk(lrec_trans.document_key);
            lrec_cdv      := ec_contract_doc_version.row_by_pk(lrec_document.contract_doc_id,lrec_document.daytime,'<=');
            lrec_lit      := ec_line_item_tmpl_version.row_by_pk(LI_template.line_item_template_id,lrec_document.daytime,'<=');


            -- Need to remove any previously existing interest lines
            FOR existing_li IN c_int_LI(lrec_trans.transaction_key) LOOP

                DelLineItem(existing_li.object_id,
                            existing_li.line_item_key);

            END LOOP;

            ln_val := getPPAIntBaseAmount(lrec_trans,ln_from_date);

            ln_base_rate := ec_price_in_item_value.index_value(lrec_cdv.int_type_id, ln_from_date, ec_price_input_item.class_name( lrec_cdv.int_type_id)||'_DAY_VALUE', '<=');


  /*
    EcDp_DynSql.WriteTempText('ROSNEDAG', 'Inserting interest line item: ' ||
            lrec_document.object_id || ', ' ||
            lrec_trans.transaction_key || ', ' ||
            LI_template.line_item_template_id
             || ', ' ||
            LI_template.line_item_template_id || ', ' ||
            lrec_document.pay_date || ', ' ||
            ln_val || ', ' ||
            ln_base_rate || ', ' ||
            lrec_cdv.int_type || ', ' ||
            'PPA Interest [' || lrec_trans.preceding_trans_key || ']' || ', ' ||
             lrec_cdv.int_offset || ', ' ||
             lrec_cdv.int_compounding_period || ', ' ||
             lrec_cdv.int_num_days || ', ' ||
             p_user || ', ' ||
             lrec_lit.line_item_type || ', ' ||
             lrec_lit.comments);
        */
          lv2_line_item_key := InsInterestLineItem(lrec_document.object_id,
                                                          lrec_trans.transaction_key,
                                                          LI_template.line_item_template_id,
                                                          ln_from_date,
                                                          lrec_document.pay_date,
                                                          ln_val,
                                                          ln_base_rate,
                                                          NULL,
                                                          lrec_cdv.int_type,
                                                          lrec_lit.name || ' [' || lrec_trans.preceding_trans_key || ']',
                                                          lrec_cdv.int_offset,
                                                          lrec_cdv.int_compounding_period,
                                                          NULL,
                                                          lrec_cdv.int_num_days,
                                                          p_user,
                                                          lrec_lit.line_item_type,
                                                          lrec_lit.comments,
                                                          p_creation_method => ecdp_revn_ft_constants.c_mtd_auto_gen);

            END IF; -- preceding trans?

            IF ue_cont_line_item.isInsPPATransIntLIPostUEE = 'TRUE' THEN
              ue_cont_line_item.InsPPATransIntLineItemPost(p_transaction_key, LI_template.line_item_template_id, p_user);
            END IF;

          END IF; -- User Exit?
        END LOOP; -- li template loop
      END IF;
    END LOOP; --transaction

EXCEPTION
  WHEN child_exists THEN

          Raise_Application_Error(-20000,'A Transaction on this Document is used on document: ' || lv2_child_doc || '. In order to complete the current change the child document must be deleted (delete and recreate)' );

END InsPPATransIntLineItem;

-----------------------------------------------------------------------------------------------------------------------------
-- Getting BaseAmount for PPA document as well as the from date
FUNCTION getPPAIntBaseAmount( lrec_trans cont_transaction%ROWTYPE,
                            p_from_date       IN OUT DATE) RETURN NUMBER
IS


 CURSOR c_add(cp_trans_key VARCHAR2) IS
  SELECT pt.transaction_key prec_trans_key,
         MAX(pd.pay_date) fromdate,
         SUM(cli.pricing_value) plus
    FROM cont_document    pd,
         cont_transaction t,
         cont_transaction pt,
         cont_line_item   cli
   WHERE t.transaction_key = cp_trans_key
     AND t.document_key = t.document_key
     AND pt.document_key = pd.document_key
     AND t.preceding_trans_key = pt.transaction_key
     AND cli.transaction_key = t.transaction_key
     AND nvl(t.reversal_ind, 'N') = 'N'
     AND cli.line_item_based_type != 'INTEREST'
   GROUP BY pt.transaction_key;

  CURSOR c_sub(cp_prec_trans_key VARCHAR2) IS
  SELECT SUM(cli.pricing_value) subtract
    FROM cont_transaction t, cont_line_item cli
   WHERE t.transaction_key = cp_prec_trans_key
     AND cli.line_item_based_type != 'INTEREST'
     AND cli.transaction_key = t.transaction_key;

  CURSOR c_int_LI(cp_transaction_key VARCHAR2) IS
    SELECT cli.interest_base_amount,
           cli.line_item_key,
           cli.object_id,
           cli.interest_from_date
      FROM cont_line_item cli
     WHERE cli.transaction_key = cp_transaction_key
       AND cli.line_item_based_type = 'INTEREST'
       AND cli.interest_line_item_key IS NULL; -- get the main line item, not compounding. Should return only one row.

       ln_prec_base_amt               NUMBER;
       ln_val                         NUMBER;
BEGIN

     FOR rsPLI IN c_int_LI(lrec_trans.preceding_trans_key) LOOP

        p_from_date := rsPLI.Interest_From_Date;
        ln_prec_base_amt := rsPLI.Interest_Base_Amount;

      END LOOP;


      FOR rsAdd IN c_add(lrec_trans.transaction_key) LOOP

        FOR rsSub IN c_sub(rsAdd.prec_trans_key) LOOP

          ln_val := NVL(ln_prec_base_amt,0) + abs(nvl(rsAdd.plus,0)) - abs(nvl(rsSub.subtract,0));  -- abs on ln_prec_base_amt?

        END LOOP;

      END LOOP;

      -- if no preceding interests were found, so from_date should be sat to pay_date for previous document

      p_from_date := nvl(p_from_date,ec_cont_document.pay_date(ec_cont_transaction.document_key(lrec_trans.preceding_trans_key)));

  RETURN ln_val;

END getPPAIntBaseAmount;

---------------------------------------------------------------------------------------------------
-- Function      : split_share_rebalance
-- Description    : Rebalances line item dist if it does not equal 100% due to rounding
--
--
---------------------------------------------------------------------------------------------------

FUNCTION split_share_rebalance(p_qty_no  number,
                               p_line_item_key VARCHAR2,
                               p_field_id VARCHAR2,
                               p_share_value NUMBER,
                               p_vendor_id VARCHAR2 DEFAULT NULL)
                               RETURN VARCHAR2
         IS
  ln_return NUMBER;
  ln_total NUMBER;
  max_dist_id                  VARCHAR2(32);
  max_vendor_id                VARCHAR2(32);
  ln_precision                 NUMBER;
  BEGIN

  ln_precision := nvl(ec_ctrl_unit_conversion.precision('PCT','FRAC',ec_cont_line_item.daytime(p_line_item_key),'<='),5) + 2;

  IF p_vendor_id IS NULL THEN

    SELECT nvl(SUM(nvl(round(
                     decode(p_qty_no,
                         1,split_share,
                         2,split_share_qty2,
                         3,split_share_qty3,
                         4,split_share_qty4),ln_precision),0)),0) INTO ln_total
      FROM cont_line_item_dist ctlid
     WHERE ctlid.line_item_key = p_line_item_key;


  ELSE
      SELECT nvl(SUM(nvl(round(
                       decode(p_qty_no,
                         1,vendor_share,
                         2,vendor_share_qty2,
                         3,vendor_share_qty3,
                         4,vendor_share_qty4),ln_precision),0)),0) INTO ln_total
        FROM cont_li_dist_company ctlidc
       WHERE ctlidc.line_item_key = p_line_item_key
         AND dist_id = p_field_id;



  END IF;

  ln_return := ROUND(p_share_value,ln_precision);


  IF ln_total <> 1 AND ln_total > 0.99 THEN

    IF p_vendor_id IS NULL THEN
        SELECT max(dist_id) INTO max_dist_id
          FROM cont_line_item_dist ctlid
         WHERE ctlid.line_item_key = p_line_item_key;

         IF p_field_id = max_dist_id THEN
           ln_return :=  ln_return + 1 - ln_total;
         END IF;

     ELSE
         SELECT MAX(vendor_id) INTO max_vendor_id
          FROM cont_li_dist_company ctlidc
         WHERE ctlidc.line_item_key = p_line_item_key
           AND ctlidc.dist_id = dist_id;

         IF  max_vendor_id = p_vendor_id THEN
           ln_return :=  ln_return + 1 - ln_total;
         END IF;

     END IF;
 END IF;


    RETURN ln_return;
END  split_share_rebalance;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : RoundDistLevel
-- Description    : This procedure sets the distribution level and does the rounding incase uneven.
--
-- Preconditions  :
-- Postconditions :
-- Using tables   : cont_line_item_dist
-- Using functions:
-- Configuration  :
-- required       : line_item_key, dist_id
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------


PROCEDURE RoundDistLevel(
               p_line_item_key              VARCHAR2
               ,p_qty1                      NUMBER
               ,p_qty2                      NUMBER
               ,p_qty3                      NUMBER
               ,p_qty4                      NUMBER
               ,p_NON_ADJUSTED_VALUE        NUMBER
               ,p_PRICING_VALUE             NUMBER
               ,p_PRICING_VAT_VALUE         NUMBER
               ,p_MEMO_VALUE                NUMBER
               ,p_MEMO_VAT_VALUE            NUMBER
               ,p_BOOKING_VALUE             NUMBER
               ,p_BOOKING_VAT_VALUE         NUMBER
               ,p_LOCAL_VALUE               NUMBER
               ,p_LOCAL_VAT_VALUE           NUMBER
               ,p_GROUP_VALUE               NUMBER
               ,p_GROUP_VAT_VALUE           NUMBER
               ,p_precision                 NUMBER
               ,p_vat_precision             NUMBER
)

IS

    lv2_where VARCHAR2(4000);

BEGIN
    UPDATE cont_line_item_dist d
       SET d.QTY1 = p_qty1 * split_share
          ,d.QTY2 = p_qty2 * nvl(d.split_share_qty2,split_share)
          ,d.QTY3 = p_qty3 * nvl(d.split_share_qty3,split_share)
          ,d.QTY4 = p_qty4 * nvl(d.split_share_qty4,split_share)
          ,d.last_updated_by = nvl(ecdp_context.getAppUser(),d.last_updated_by)
    WHERE  d.line_item_key = p_line_item_key;

    -- perform line item dist monetary updates
    UPDATE cont_line_item_dist
        SET
            NON_ADJUSTED_VALUE = Round(p_NON_ADJUSTED_VALUE * SPLIT_SHARE, p_precision)
           ,PRICING_VALUE = Round(p_PRICING_VALUE * SPLIT_SHARE, p_precision)
           ,PRICING_VAT_VALUE = Round(p_PRICING_VAT_VALUE * SPLIT_SHARE, p_vat_precision)
           ,MEMO_VALUE = Round(p_MEMO_VALUE * SPLIT_SHARE, p_precision)
           ,MEMO_VAT_VALUE = Round(p_MEMO_VAT_VALUE * SPLIT_SHARE, p_vat_precision)
           ,BOOKING_VALUE = Round(p_BOOKING_VALUE * SPLIT_SHARE, p_precision)
           ,BOOKING_VAT_VALUE = Round(p_BOOKING_VAT_VALUE * SPLIT_SHARE, p_vat_precision)
           ,LOCAL_VALUE = Round(p_LOCAL_VALUE * SPLIT_SHARE, p_precision)
           ,LOCAL_VAT_VALUE = Round(p_LOCAL_VAT_VALUE * SPLIT_SHARE, p_vat_precision)
           ,GROUP_VALUE = Round(p_GROUP_VALUE * SPLIT_SHARE, p_precision)
           ,GROUP_VAT_VALUE = Round(p_GROUP_VAT_VALUE * SPLIT_SHARE, p_vat_precision)
           ,last_updated_by = 'SYSTEM'
        WHERE
            line_item_key = p_line_item_key;

    -- now perform proper rounding on these numbers
    lv2_where := '  LINE_ITEM_KEY = ''' || p_line_item_key || '''';
    EcDp_Contract_Setup.GenericRounding('CONT_LINE_ITEM_DIST','NON_ADJUSTED_VALUE',p_NON_ADJUSTED_VALUE,lv2_where);
    EcDp_Contract_Setup.GenericRounding('CONT_LINE_ITEM_DIST','PRICING_VALUE',p_PRICING_VALUE,lv2_where);
    EcDp_Contract_Setup.GenericRounding('CONT_LINE_ITEM_DIST','PRICING_VAT_VALUE',p_PRICING_VAT_VALUE,lv2_where);
    EcDp_Contract_Setup.GenericRounding('CONT_LINE_ITEM_DIST','MEMO_VALUE',p_MEMO_VALUE,lv2_where);
    EcDp_Contract_Setup.GenericRounding('CONT_LINE_ITEM_DIST','MEMO_VAT_VALUE',p_MEMO_VAT_VALUE,lv2_where);
    EcDp_Contract_Setup.GenericRounding('CONT_LINE_ITEM_DIST','BOOKING_VALUE',p_BOOKING_VALUE,lv2_where);
    EcDp_Contract_Setup.GenericRounding('CONT_LINE_ITEM_DIST','BOOKING_VAT_VALUE',p_BOOKING_VAT_VALUE,lv2_where);
    EcDp_Contract_Setup.GenericRounding('CONT_LINE_ITEM_DIST','LOCAL_VALUE',p_LOCAL_VALUE,lv2_where);
    EcDp_Contract_Setup.GenericRounding('CONT_LINE_ITEM_DIST','LOCAL_VAT_VALUE',p_LOCAL_VAT_VALUE,lv2_where);
    EcDp_Contract_Setup.GenericRounding('CONT_LINE_ITEM_DIST','GROUP_VALUE',p_GROUP_VALUE,lv2_where);
    EcDp_Contract_Setup.GenericRounding('CONT_LINE_ITEM_DIST','GROUP_VAT_VALUE',p_GROUP_VAT_VALUE,lv2_where);

    -- now perform proper rounding on these numbers
    lv2_where :=  '  LINE_ITEM_KEY = ''' || p_line_item_key || '''';
    EcDp_Contract_Setup.GenericRounding('CONT_LINE_ITEM_DIST','QTY1',p_QTY1 ,lv2_where);
    EcDp_Contract_Setup.GenericRounding('CONT_LINE_ITEM_DIST','QTY2',p_QTY2 ,lv2_where);
    EcDp_Contract_Setup.GenericRounding('CONT_LINE_ITEM_DIST','QTY3',p_QTY3 ,lv2_where);
    EcDp_Contract_Setup.GenericRounding('CONT_LINE_ITEM_DIST','QTY4',p_QTY4 ,lv2_where);

END RoundDistLevel;

PROCEDURE RoundDistLevel(
               p_line_item_key              VARCHAR2
) is
      li cont_line_item%rowtype;

      CURSOR c_livf(cp_line_item VARCHAR2) IS
      SELECT *
      FROM cont_line_item_dist
      WHERE line_item_key  = cp_line_item;

ln_precision NUMBER := NVL(ec_ctrl_system_attribute.attribute_value(ec_cont_line_item.daytime(p_line_item_key), 'EX_VAT_PRECISION', '<='), 2);
ln_vat_precision NUMBER:=NVL(ec_ctrl_system_attribute.attribute_value(
               ec_cont_line_item.daytime(p_line_item_key), 'VAT_PRECISION', '<='), ln_precision);

begin

    li :=   ec_cont_line_item.row_by_pk(p_line_item_key);
           RoundDistLevel(
               p_line_item_key
               ,li.qty1
               ,li.qty2
               ,li.qty3
               ,li.qty4
               ,li.NON_ADJUSTED_VALUE
               ,li.PRICING_VALUE
               ,li.PRICING_VAT_VALUE
               ,li.MEMO_VALUE
               ,li.MEMO_VAT_VALUE
               ,li.BOOKING_VALUE
               ,li.BOOKING_VAT_VALUE
               ,li.LOCAL_VALUE
               ,li.LOCAL_VAT_VALUE
               ,li.GROUP_VALUE
               ,li.GROUP_VAT_VALUE
               ,ln_precision
               ,ln_vat_precision);

END RoundDistLevel;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : InsNewLITemplate
-- Description    : Inserts a new line item template
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : line_item_template, line_item_tmpl_version
--
-- Using functions: InsInterestLineItem
-- Configuration
-- required       :
--
-- Behaviour      : Called from the screen Contract Transaction Mapping.
-------------------------------------------------------------------------------------------------------------------------------
PROCEDURE InsNewLITemplate
( p_trans_templ_id VARCHAR2,
  p_line_item_code VARCHAR2,
  p_sort_order     NUMBER,
  p_li_based_type  VARCHAR2,
  p_li_type        VARCHAR2,
  p_name           VARCHAR2,
  p_pct_value      NUMBER,
  p_li_value       NUMBER,
  p_unit_prc       NUMBER,
  p_unit_prc_unit  VARCHAR2,
  p_vat_code       VARCHAR2,
  p_daytime        DATE,   -- Versioning will be aligned with the transaction template
  p_user           VARCHAR2 DEFAULT NULL,
  p_calculation_id VARCHAR2 DEFAULT NULL,
  p_price_object_id VARCHAR2 DEFAULT NULL
)
--</EC-DOC>
IS
lv2_obj_id                   VARCHAR2(32);
ln_int_num_days              NUMBER;
lv2_code                     VARCHAR2(32);
lv2_price_concept_code       VARCHAR2(32);
ln_sort_order                NUMBER;

CURSOR c_qty_li_template (cp_transaction_template_id VARCHAR2) IS
  SELECT l.object_id
    FROM line_item_template l, line_item_tmpl_version lv
   WHERE l.transaction_template_id = cp_transaction_template_id
     AND lv.line_item_based_type = 'QTY'
     AND l.object_id = lv.object_id
     AND l.start_date <= p_daytime
     AND p_daytime < nvl(l.end_date, p_daytime + 1)
     AND p_daytime <= lv.daytime;

CURSOR c_price_elem_rec (cp_price_concept_code VARCHAR2) IS
  SELECT pce.price_element_code,
         pce.price_concept_code,
         pce.name,
         pce.line_item_type
    FROM price_concept_element pce
   WHERE pce.price_concept_code = cp_price_concept_code;

CURSOR c_price_elem_exist (cp_price_concept_code VARCHAR2) IS
  SELECT COUNT(pce.price_element_code) n
    FROM price_concept_element pce
   WHERE pce.price_concept_code = cp_price_concept_code;

CURSOR c_last_sort_order IS
  SELECT MAX(NVL(lit.sort_order, 0)) as sort_order
    FROM line_item_template lit, line_item_tmpl_version litv
   WHERE lit.transaction_template_id = p_trans_templ_id
     AND lit.object_id = litv.object_id
     AND litv.daytime <= p_daytime
     AND NVL(litv.end_date, p_daytime + 1) > p_daytime
     AND (litv.line_item_based_type IS NULL OR litv.line_item_based_type <> 'QTY');

CURSOR c_exist_free_unit_po (cp_transaction_template_id VARCHAR2, p_price_object_id VARCHAR2) IS
  SELECT l.object_id
    FROM line_item_template l, line_item_tmpl_version lv
   WHERE l.transaction_template_id = cp_transaction_template_id
     AND lv.line_item_based_type = 'FREE_UNIT_PRICE_OBJECT'
     AND lv.price_object_id = p_price_object_id
     AND l.object_id = lv.object_id
     AND l.start_date <= p_daytime
     AND p_daytime < nvl(l.end_date, p_daytime + 1)
     AND p_daytime <= lv.daytime;

-- ** 4-eyes approval stuff ** --
lv2_4e_recid                    VARCHAR2(32);
-- ** END 4-eyes approval stuff ** --

P_LI_BASED_TYPE_EMPTY_EX        EXCEPTION;
P_LI_TYPE_EMPTY_EX              EXCEPTION;
P_LI_PRICE_OBJECT_EMPTY_EX      EXCEPTION;
P_LI_PRICE_OBJECT_EXISTS        EXCEPTION;

BEGIN

  -- Check mandatory parameters
  IF p_li_based_type IS NULL THEN
      RAISE P_LI_BASED_TYPE_EMPTY_EX;
  END IF;

  -- Non-Quantity line item templates have to have line
  -- item type set
  IF p_li_type IS NULL AND p_li_based_type not in ('QTY','FREE_UNIT_PRICE_OBJECT') THEN
      RAISE P_LI_TYPE_EMPTY_EX;
  END IF;

  -- FREE_UNIT_PRICE_OBJECT must have a price object
  IF p_li_based_type = 'FREE_UNIT_PRICE_OBJECT' AND p_price_object_id IS NULL THEN
      RAISE P_LI_PRICE_OBJECT_EMPTY_EX;
  END IF;

-- FREE_UNIT_PRICE_OBJECT cant use the same price object more than once
  IF p_li_based_type = 'FREE_UNIT_PRICE_OBJECT' AND p_price_object_id IS NOT NULL THEN
      --Check if this price object is there already
      for x in c_exist_free_unit_po(p_trans_templ_id, p_price_object_id) loop
          RAISE P_LI_PRICE_OBJECT_EXISTS;
      end loop;
  END IF;

  -- Generate sort order
  ln_sort_order := 50; --Default sort order starting point
  IF p_sort_order IS NOT NULL THEN
    --Sort order is given by the user
    ln_sort_order := p_sort_order;
  ELSE
    --Get the next sort order from the database
    FOR rsC IN c_last_sort_order LOOP
      IF rsC.sort_order > 0 THEN
        ln_sort_order := rsC.sort_order + 1;
      END IF;
    END LOOP;
  END IF;

  -- Not allowed to add a calculation rule or a calculation sequence number to a non-calculated line item
  IF p_li_based_type NOT IN ('CALC_VALUE','CALC_QTY_VALUE') THEN

    IF p_calculation_id IS NOT NULL THEN
       RAISE_APPLICATION_ERROR(-20000,'Not allowed to add a calculation to a non-calculated line item.');
    END IF;

  END IF;

  -- Not allowed to add a CALC_QTY_VALUE calculation rule if quantity based line item templates already exist on current transaction template
  IF p_li_based_type = 'CALC_QTY_VALUE' THEN

     FOR v IN c_qty_li_template (p_trans_templ_id) LOOP
         RAISE_APPLICATION_ERROR(-20000,'Not allowed to add a CALC_QTY_VALUE line item if one or more quantity based line item templates already exists on the same transaction template.');
     END LOOP;

  END IF;
  If p_li_based_type = 'INTEREST' THEN
     ln_int_num_days := ec_contract_doc_version.int_num_days(ec_transaction_template.contract_doc_id(p_trans_templ_id), p_daytime, '<=');
  ELSE
     ln_int_num_days := null;
  END IF;

  lv2_price_concept_code := ec_product_price.price_concept_code(p_price_object_id);

  IF p_price_object_id IS NOT NULL THEN

   IF p_li_based_type <> 'FREE_UNIT_PRICE_OBJECT' THEN
      RAISE_APPLICATION_ERROR(-20000,'Not allowed to add a price object on this line item based type');
   END IF;


   -- Not allowed to continue if price object is selected, but no price elements are found.
   FOR c_pce_rec_ex IN c_price_elem_exist (lv2_price_concept_code) LOOP
            IF c_pce_rec_ex.n = 0 THEN
               RAISE_APPLICATION_ERROR(-20000,'No price element(s) found on selected price object.');
            END IF;
        END LOOP;


    -- This loop will make sure one line item template is inserted for each price element that exists on the price concept in use.
    FOR c_pce_rec IN c_price_elem_rec (lv2_price_concept_code) LOOP

      -- Generate Object_Code for Line Item Template
      IF p_line_item_code IS NOT NULL THEN
        lv2_code := p_line_item_code;
      ELSE
        lv2_code := 'LIT:' || to_char(ECDP_system_key.AssignNextUniqueNumber('LINE_ITEM_TEMPLATE', 'OBJECT_CODE', 'LIT:'));
      END IF;

      -- insert into main object table
      INSERT INTO line_item_template
        (object_code,
         start_date,
         end_date,
         transaction_template_id,
         sort_order,
         description,
         created_by)
      VALUES
        (lv2_code,
         p_daytime,
         ec_transaction_tmpl_version.end_date(p_trans_templ_id, p_daytime, '<='),
         p_trans_templ_id,
         ln_sort_order,
         c_pce_rec.name,
         p_user)
      RETURNING object_id INTO lv2_obj_id;

      -- insert into object version table
      INSERT INTO line_item_tmpl_version
        (object_id,
         line_item_based_type,
         line_item_type,
         percentage_value,
         line_item_value,
         unit_price,
         unit_price_unit,
         vat_code_1,
         interest_num_days,
         calculation_id,
         price_object_id,
         price_concept_code,
         price_element_code,
         name, -- Required for approval
         daytime,
         end_date,
         created_by)
      VALUES
        (lv2_obj_id,
         p_li_based_type,
         c_pce_rec.line_item_type,
         p_pct_value/100,
         p_li_value,
         p_unit_prc,
         p_unit_prc_unit,
         p_vat_code,
         ln_int_num_days,
         p_calculation_id,
         p_price_object_id,
         c_pce_rec.price_concept_code,
         c_pce_rec.price_element_code,
         c_pce_rec.name, -- Price element name as name for line item template
         p_daytime,
         ec_transaction_tmpl_version.end_date(p_trans_templ_id, p_daytime, '<='),
         p_user);


      -- ** 4-eyes approval logic ** --
      IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('LINE_ITEM_TEMPLATE'),'N') = 'Y' THEN

        -- Generate rec_id for the new version record
        lv2_4e_recid := SYS_GUID();

        -- Set approval info on version record. PS! Never do this on a main object table. Approval is only intended for the version attributes.
        UPDATE line_item_tmpl_version
        SET last_updated_by = Nvl(EcDp_Context.getAppUser,User),
            last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
            approval_state = 'N',
            rec_id = lv2_4e_recid,
            rev_no = (nvl(rev_no,0) + 1)
        WHERE object_id = lv2_obj_id
        AND daytime = p_daytime;

        -- Register version record for approval
        Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                          'LINE_ITEM_TEMPLATE',
                                          Nvl(EcDp_Context.getAppUser,User));
      END IF;
      -- ** END 4-eyes approval ** --


      --Updaing ACL for if ringfencing is enabled
      IF (NVL(EcDp_ClassMeta_Cnfg.getAccessControlInd('LINE_ITEM_TEMPLATE'),'N') = 'Y') THEN
      -- Update ACL
              EcDp_Acl.RefreshObject(lv2_obj_id, 'LINE_ITEM_TEMPLATE', 'INSERTING');
      END IF;

      -- Cleanup
      lv2_obj_id := NULL;
      ln_sort_order := ln_sort_order + 1;

    END LOOP;

ELSE

      -- Generate Object_Code for Line Item Template
      IF p_line_item_code IS NOT NULL THEN
        lv2_code := p_line_item_code;
      ELSE
        lv2_code := 'LIT:' ||to_char(ECDP_system_key.AssignNextUniqueNumber('LINE_ITEM_TEMPLATE', 'OBJECT_CODE', 'LIT:'));
      END IF;

      -- insert into main object table
      INSERT INTO line_item_template
        (object_code,
         start_date,
         transaction_template_id,
         sort_order,
         created_by)
      VALUES
        (lv2_code,
         p_daytime,
         p_trans_templ_id,
         ln_sort_order,
         p_user)
      RETURNING object_id INTO lv2_obj_id;

      -- insert into object version table
      INSERT INTO line_item_tmpl_version
        (object_id,
         line_item_based_type,
         line_item_type,
         percentage_value,
         line_item_value,
         unit_price,
         unit_price_unit,
         vat_code_1,
         interest_num_days,
         calculation_id,
         name, -- Required for approval
         daytime,
         end_date,
         created_by)
      VALUES
        (lv2_obj_id,
         p_li_based_type,
         p_li_type,
         p_pct_value/100,
         p_li_value,
         p_unit_prc,
         p_unit_prc_unit,
         p_vat_code,
         ln_int_num_days,
         p_calculation_id,
         p_name,
         p_daytime,
         ec_transaction_tmpl_version.end_date(p_trans_templ_id, p_daytime, '<='),
         p_user);


      -- ** 4-eyes approval logic ** --
      IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('LINE_ITEM_TEMPLATE'),'N') = 'Y' THEN

        -- Generate rec_id for the new version record
        lv2_4e_recid := SYS_GUID();

        -- Set approval info on version record. PS! Never do this on a main object table. Approval is only intended for the version attributes.
        UPDATE line_item_tmpl_version
        SET last_updated_by = Nvl(EcDp_Context.getAppUser,User),
            last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
            approval_state = 'N',
            rec_id = lv2_4e_recid,
            rev_no = (nvl(rev_no,0) + 1)
        WHERE object_id = lv2_obj_id
        AND daytime = p_daytime;

        -- Register version record for approval
        Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                          'LINE_ITEM_TEMPLATE',
                                          Nvl(EcDp_Context.getAppUser,User));
      END IF;
      -- ** END 4-eyes approval ** --


      --Updaing ACL for if ringfencing is enabled
      IF (NVL(EcDp_ClassMeta_Cnfg.getAccessControlInd('LINE_ITEM_TEMPLATE'),'N') = 'Y') THEN
      -- Update ACL
              EcDp_Acl.RefreshObject(lv2_obj_id, 'LINE_ITEM_TEMPLATE', 'INSERTING');
      END IF;


END IF;

EXCEPTION
  WHEN P_LI_BASED_TYPE_EMPTY_EX THEN
    Raise_Application_Error(-20000,'Line Item Concept does not have a value.');

  WHEN P_LI_TYPE_EMPTY_EX THEN
    Raise_Application_Error(-20000,'Line Item Type does not have a value.');

  WHEN P_LI_PRICE_OBJECT_EMPTY_EX THEN
    Raise_Application_Error(-20000,'Price Object does not have a value for the Free Unit Price Object line.');

  WHEN P_LI_PRICE_OBJECT_EXISTS THEN
    Raise_Application_Error(-20000,'Not allowed to use the same Price Object for two separate Free Unit Price Object Line Item Templates.');

END InsNewLITemplate;




PROCEDURE UpdLineItemTemplate(p_li_templ_id             VARCHAR2,
                              p_sort_order              NUMBER,
                              p_li_based_type           VARCHAR2,
                              p_li_type                 VARCHAR2,
                              p_name                    VARCHAR2,
                              p_pct_value               NUMBER,
                              p_li_value                NUMBER,
                              p_unit_prc                NUMBER,
                              p_unit_prc_unit           VARCHAR2,
                              p_vat_code                VARCHAR2,
                              p_daytime                 DATE,
                              p_user                    VARCHAR2 DEFAULT NULL,
                              p_calculation_id          VARCHAR2 DEFAULT NULL,
                              p_price_object_id         VARCHAR2 DEFAULT NULL,
                              p_line_item_template_code VARCHAR2 DEFAULT NULL)
IS

lv_transaction_template_id    VARCHAR2(32);
lv2_old_price_object_id       VARCHAR2(32);
ln_int_num_days               NUMBER;
lv_calculation_id             VARCHAR2(32);

CURSOR c_qty_li_template (cp_transaction_template_id VARCHAR2) IS
  SELECT l.object_id
    FROM line_item_template l, line_item_tmpl_version lv
   WHERE l.transaction_template_id = cp_transaction_template_id
     AND lv.line_item_based_type = 'QTY'
     AND l.object_id = lv.object_id
     AND l.start_date <= p_daytime
     AND p_daytime < nvl(l.end_date, p_daytime + 1)
     AND p_daytime <= lv.daytime;

--Cursor for deleting Line Item Templates for FREE_UNIT_PRICE_OBJECT:
CURSOR c_del_price_elem_lit (cp_transaction_template_id VARCHAR2, cp_old_price_object_id VARCHAR2, cp_daytime DATE ) IS
SELECT l.object_id
    FROM line_item_template l, line_item_tmpl_version lv
   WHERE l.transaction_template_id = cp_transaction_template_id
     AND lv.line_item_based_type = 'FREE_UNIT_PRICE_OBJECT'
     AND lv.price_object_id = cp_old_price_object_id
     AND l.object_id = lv.object_id
     AND l.start_date <= cp_daytime
     AND cp_daytime < nvl(l.end_date, cp_daytime + 1)
     AND cp_daytime <= lv.daytime;

-- ** 4-eyes approval stuff ** --
CURSOR c_4e_litv(cp_line_item_id VARCHAR2, cp_daytime DATE) IS
  SELECT approval_state, rec_id
  FROM line_item_tmpl_version
  WHERE object_id = cp_line_item_id
  AND daytime = cp_daytime;
-- ** END 4-eyes approval stuff ** --

P_LI_BASED_TYPE_EMPTY_EX EXCEPTION;
P_LI_TYPE_EMPTY_EX EXCEPTION;

BEGIN

  -- Check mandatory parameters
  IF p_li_based_type IS NULL THEN
      RAISE P_LI_BASED_TYPE_EMPTY_EX;
  END IF;

  -- Non-Quantity line item templates have to have line
  -- item type set
  IF p_li_type IS NULL AND p_li_based_type not in ('QTY','FREE_UNIT_PRICE_OBJECT') THEN
      RAISE P_LI_TYPE_EMPTY_EX;
  END IF;


  lv_transaction_template_id := ec_line_item_template.transaction_template_id(p_li_templ_id);
  lv2_old_price_object_id := ec_line_item_tmpl_version.price_object_id(p_li_templ_id,p_daytime,'<=');

  -- Not allowed to add a calculation rule or a calculation sequence number to a non-calculated line item
  IF p_li_based_type NOT IN ('CALC_VALUE','CALC_QTY_VALUE') THEN

    lv_calculation_id := null;
  ELSE
    lv_calculation_id := p_calculation_id;

  END IF;

  -- Not allowed to add a CALC_QTY_VALUE calculation rule if quantity based line item templates already exist on current transaction template
  IF p_li_based_type = 'CALC_QTY_VALUE' THEN

     FOR v IN c_qty_li_template (lv_transaction_template_id) LOOP
         RAISE_APPLICATION_ERROR(-20000,'Not allowed to add a CALC_QTY_VALUE calculation rule if one or more quantity based line item templates already exists on the same transaction template.');
     END LOOP;

  END IF;

  If p_li_based_type = 'INTEREST' THEN
     ln_int_num_days := ec_contract_doc_version.int_num_days(ec_transaction_template.contract_doc_id(lv_transaction_template_id), p_daytime, '<=');
  ELSE
     ln_int_num_days := null;
  END IF;

  IF p_li_based_type = 'FREE_UNIT_PRICE_OBJECT' THEN


        IF lv2_old_price_object_id <> p_price_object_id THEN
          --old price object id is held by lv2_price_object_id
          --delete old LIT entries for the 'other' price elements of the price concept
          for x in c_del_price_elem_lit(lv_transaction_template_id, lv2_old_price_object_id, p_daytime) loop
            DelLineItemTemplate(x.object_id);
          end loop;
          --Insert new LITs for the new Price Object:
          InsNewLITemplate(lv_transaction_template_id,
                                  null, --p_line_item_code,
                                  p_sort_order,
                                  'FREE_UNIT_PRICE_OBJECT', --p_li_based_type,
                                  p_li_type,
                                  p_name,
                                  null, --p_pct_value,
                                  null, --p_li_value,
                                  null, --p_unit_prc,
                                  p_unit_prc_unit,
                                  p_vat_code,
                                  p_daytime,
                                  p_user,
                                  null, --p_calculation_id,
                                  p_price_object_id);
        END IF;

  END IF;



    -- update main object table
    UPDATE line_item_template
       SET object_code = nvl(p_line_item_template_code, object_code),
           sort_order = p_sort_order
     WHERE object_id = p_li_templ_id;

    -- update object version table
    UPDATE line_item_tmpl_version
       SET line_item_based_type = p_li_based_type,
           line_item_type       = p_li_type,
           percentage_value     = p_pct_value / 100,
           line_item_value      = p_li_value,
           interest_num_days    = ln_int_num_days,
           unit_price           = DECODE(p_li_based_type,
                                         'FREE_UNIT_PRICE_OBJECT',
                                         NULL,
                                         p_unit_prc),
           unit_price_unit      = p_unit_prc_unit,
           vat_code_1           = p_vat_code,
           calculation_id       = lv_calculation_id, --p_calculation_id,
           price_object_id      = p_price_object_id,
           name                 = p_name,
           end_date             = ec_transaction_tmpl_version.end_date(lv_transaction_template_id, p_daytime, '<='),
           last_updated_by      = p_user,
           last_updated_date    = Ecdp_Timestamp.getCurrentSysdate
     WHERE object_id = p_li_templ_id
       AND daytime = p_daytime;


  -- ** 4-eyes approval logic ** --
  IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('LINE_ITEM_TEMPLATE'),'N') = 'Y' THEN

     FOR rs4e IN c_4e_litv(p_li_templ_id,p_daytime) LOOP

        -- Only demand approval if a record is in Official state
        IF rs4e.approval_state = 'O' THEN

           -- Set approval info on record
           UPDATE line_item_tmpl_version
           SET last_updated_by = Nvl(EcDp_Context.getAppUser,User),
               last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
               approval_state = 'U',
               approval_by = null,
               approval_date = null,
               rev_no = (nvl(rev_no,0) + 1)
           WHERE rec_id = rs4e.rec_id;

           -- Prepare record for approval
           Ecdp_Approval.registerTaskDetail(rs4e.rec_id,
                                            'LINE_ITEM_TEMPLATE',
                                            Nvl(EcDp_Context.getAppUser,User));
        END IF;
     END LOOP;
  END IF;
  -- ** END 4-eyes approval ** --

EXCEPTION
  WHEN P_LI_BASED_TYPE_EMPTY_EX THEN
    Raise_Application_Error(-20000,'Line Item Concept Type does not have a value.');

  WHEN P_LI_TYPE_EMPTY_EX THEN
    Raise_Application_Error(-20000,'Line Item Type does not have a value.');

END UpdLineItemTemplate;


FUNCTION HasNonQtyLineItemTmpl
(
    p_tt_object_id VARCHAR2,
    p_daytime date
)
return ecdp_revn_common.T_BOOLEAN_STR
IS
    ln_count number;
BEGIN
    SELECT COUNT(li_ver.object_id) into ln_count
    FROM line_item_tmpl_version li_ver, line_item_template li
    WHERE li_ver.object_id = li.object_id
          AND li_ver.daytime <= p_daytime
          AND nvl(li_ver.end_date, p_daytime + 1) > p_daytime
          AND li.transaction_template_id = p_tt_object_id
          AND li_ver.line_item_based_type <> 'QTY';

    return (
       case when ln_count = 0 then ecdp_revn_common.gv2_false
            else ecdp_revn_common.gv2_true
        end);
END;


END ECDP_LINE_ITEM;