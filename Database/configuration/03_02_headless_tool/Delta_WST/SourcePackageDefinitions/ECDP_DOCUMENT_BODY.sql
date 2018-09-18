CREATE OR REPLACE PACKAGE BODY EcDp_Document IS
    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    PROCEDURE fill_by_ifac_period_i(
        p_context                          IN OUT NOCOPY t_revn_doc_op_context
       ,p_document_key                     VARCHAR2
    )
    IS
        CURSOR c_transactions IS
        SELECT tx.transaction_key, tx.transaction_date
          FROM cont_transaction tx
         WHERE tx.document_key = p_document_key
           AND tx.reversal_ind = 'N';

        transaction_ifac_ids T_TABLE_NUMBER;
    BEGIN
        IF ue_cont_document.isFillDocumentUEEnabled = 'TRUE' THEN
            ue_cont_document.FillDocument(p_document_key, p_context.user_id);
        ELSE
            IF p_context.is_empty_period_ifac_data THEN
                RETURN;
            END IF;

            FOR vt IN c_transactions LOOP
                -- find the transaction from ifac
                transaction_ifac_ids := ecdp_revn_ifac_wrapper_period.find(
                    p_context.ifac_period,
                    p_level => ecdp_revn_ifac_wrapper.gconst_level_transaction,
                    p_transaction_key => vt.transaction_key);

                if transaction_ifac_ids.count > 0 then
                    ecdp_transaction.fill_transaction_i(
                        p_context, vt.transaction_key, vt.transaction_date);
                end if;
            END LOOP;
        END IF;

        IF ue_cont_document.isFillDocPostUEEnabled = 'TRUE' THEN
            ue_cont_document.FillDocPost(p_document_key, p_context.user_id);
        END IF;
    END;


 -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    PROCEDURE fill_by_ifac_cargo_i(
        p_context                          IN OUT NOCOPY t_revn_doc_op_context
       ,p_document_key                     VARCHAR2
    )
    IS
        CURSOR c_transactions IS
        SELECT tx.transaction_key, tx.transaction_date
          FROM cont_transaction tx
         WHERE tx.document_key = p_document_key
           AND tx.reversal_ind = 'N';

        transaction_ifac_ids T_TABLE_NUMBER;
    BEGIN
        IF ue_cont_document.isFillDocumentUEEnabled = 'TRUE' THEN
            ue_cont_document.FillDocument(p_document_key, p_context.user_id);
        ELSE
            IF p_context.is_empty_cargo_ifac_data THEN
                RETURN;
            END IF;

            FOR vt IN c_transactions LOOP
                -- find the transaction from ifac
                transaction_ifac_ids := ecdp_revn_ifac_wrapper_cargo.find(
                    p_context.ifac_cargo,
                    p_level => ecdp_revn_ifac_wrapper.gconst_level_line_item,
                    p_transaction_key => vt.transaction_key);

                if transaction_ifac_ids.count > 0 then
                    ecdp_transaction.fill_transaction_i(
                        p_context, vt.transaction_key, vt.transaction_date);
                end if;
            END LOOP;
        END IF;

        IF ue_cont_document.isFillDocPostUEEnabled = 'TRUE' THEN
            ue_cont_document.FillDocPost(p_document_key, p_context.user_id);
        END IF;
   END;

PROCEDURE UpdDocumentPricingTotal
 (p_object_id VARCHAR2,
  p_doc_id VARCHAR2,
  p_user VARCHAR2
)
IS
BEGIN
     -- dummy update - just to make the trigger run
     UPDATE cont_document t
     SET    t.last_updated_by = p_user
     WHERE  t.object_id = p_object_id
       AND  t.document_key = p_doc_id;

END UpdDocumentPricingTotal;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : InsNewDocument
-- Description    : Inserts a new document using a document type
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
FUNCTION InsNewDocument_p(
   p_context                 IN OUT NOCOPY t_revn_doc_op_context,
   p_object_id               VARCHAR2,
   p_contract_doc_object_id  VARCHAR2,
   p_daytime                 DATE,
   p_document_date           DATE,
   p_document_type           VARCHAR2,
   p_preceding_doc_id        VARCHAR2,
   p_parent_doc_id           VARCHAR2,
   p_doc_id                  VARCHAR2 DEFAULT NULL,
   p_dg_doc_key              VARCHAR2 DEFAULT NULL, -- Document key set from Period/Cargo Document Generation. To use for delete if GenNewDoc fails.
   p_insert_transactions_ind VARCHAR2 DEFAULT 'Y')
RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_pre_qty_trans(p_document_id VARCHAR2) IS
SELECT transaction_key id
  FROM cont_transaction t
 WHERE t.document_key = p_document_id
   AND t.reversed_trans_key IS NULL
   AND EXISTS (SELECT 1
          FROM cont_line_item cli
         WHERE cli.transaction_key = t.transaction_key
           AND cli.line_item_based_type = 'QTY');


CURSOR c_pre_trans(p_document_id VARCHAR2) IS
SELECT transaction_key id
  FROM cont_transaction t
 WHERE t.document_key = p_document_id
   AND t.reversed_trans_key IS NULL;





CURSOR c_pre_trans_prov(p_document_id VARCHAR2) IS
SELECT transaction_key id
  FROM cont_transaction t
 WHERE t.document_key = p_document_id
   AND t.transaction_type NOT LIKE '%FINAL%'
   AND t.reversed_trans_key IS NULL;

CURSOR c_text_item IS
SELECT  cti.object_id                object_id
       ,ctiv.column_1                COLUMN1
       ,ctiv.column_2                COLUMN2
       ,ctiv.column_3                COLUMN3
       ,cti.description              DESCRIPTION
       ,ctiv.comments                COMMENTS
       ,cti.sort_order               SORT_ORDER
       ,ctiv.text_item_type          TEXT_ITEM_TYPE
       ,ctiv.text_item_column_type   TEXT_ITEM_COLUMN_TYPE
       ,rownum
FROM contract_text_item cti, cntr_text_item_version ctiv
WHERE cti.contract_doc_id = p_contract_doc_object_id
AND cti.object_id = ctiv.object_id
AND p_daytime >= ctiv.daytime AND p_daytime < Nvl(ctiv.end_date, p_daytime+1)
;

-- Get Contract owner vendor
CURSOR c_co_vend IS
   SELECT object_id FROM company c
   WHERE class_name = 'VENDOR'
   AND c.company_id = ec_contract_version.company_id(p_object_id, p_daytime, '<=');

-- Get Contract Vendors
CURSOR c_vend IS
   SELECT ps.company_id FROM contract_party_share ps
   WHERE ps.party_role = 'VENDOR'
   AND ps.object_id = p_object_id;

lv2_doc_id VARCHAR2(32);
lv2_trans_id VARCHAR2(32);
lv2_fin_code VARCHAR2(32);
lv2_vendor_id VARCHAR2(32);
lv2_our_contact VARCHAR2(40);
lv2_our_phone VARCHAR2(40);

lv2_preceding_doc_id cont_document.document_key%TYPE := p_preceding_doc_id; -- set to null if STANDALONE
lrec_preceding_doc cont_document%ROWTYPE := ec_cont_document.row_by_pk(p_preceding_doc_id);
lrec_contract_doc_version contract_doc_version%rowtype;
ln_cnt NUMBER;
lv2_tmp_var VARCHAR2(32);
l_logger t_revn_logger;

BEGIN
    p_context.get_or_create_logger(l_logger);
    lrec_contract_doc_version := ec_contract_doc_version.row_by_pk(p_contract_doc_object_id, p_daytime, '<=');

    IF lrec_contract_doc_version.doc_concept_code = 'STANDALONE' THEN
            lv2_preceding_doc_id := NULL;
    END IF;

    -- check against proccessable code
    --lv2_processable_code := ec_contract_version.processable_code(p_object_id, p_daytime, '<=');
    IF  ec_contract_version.processable_code(p_object_id, p_daytime, '<=') = 'N' THEN
           Raise_Application_Error(-20000,'The document of this contract could not be processed!');
    END IF;

    -- Get the financial code for this contract
    lv2_fin_code := ec_contract_version.financial_code(p_object_id, p_daytime, '<=');


    IF (p_doc_id IS NOT NULL) THEN
       lv2_doc_id := p_doc_id;
    ELSE
       IF p_dg_doc_key IS NOT NULL THEN
          lv2_doc_id := p_dg_doc_key;
       ELSE
          lv2_doc_id := GetNextDocumentKey(p_object_id, p_daytime);
       END IF;
    END IF;

    -- Finds user information from T_BASIS_USER
    lv2_our_contact := ec_t_basis_user.given_name(ec_contract_version.system_owner(p_object_id, p_daytime, '<=')) || ' ' || ec_t_basis_user.surname(ec_contract_version.system_owner(p_object_id, p_daytime, '<='));
    lv2_our_phone := ec_t_basis_user.phone(ec_contract_version.system_owner(p_object_id, p_daytime, '<='));

    -- Determine Vendor for this document, for getting correct payment info
    lv2_vendor_id := EcDp_Document.GetDocumentVendor(p_object_id, lv2_doc_id, p_daytime, lv2_fin_code);

    l_logger.info('Creating new document ['||lv2_doc_id||']');
    INSERT INTO CONT_DOCUMENT
        (object_id,
         contract_doc_id,
         document_key,
         daytime,
         document_date,
         doc_date_calendar_coll_id,
         doc_rec_calendar_coll_id,
         payment_calendar_coll_id,
         document_type,
         preceding_document_key,
         parent_document_key,
         open_user_id,
         booking_currency_code,
         booking_currency_id,
         book_document_ind,
         memo_currency_code,
         memo_currency_id,
         price_basis,
         contract_name,
         contract_reference,
         contract_group_code,
         doc_scope,
         owner_company_id,
         doc_date_term_id,
         doc_received_base_code,
         doc_received_base_date,
         doc_received_term_id,
         document_received_date,
         payment_term_base_code,
         payment_due_base_date,
         payment_term_name,
         pay_date,
         payment_term_id,
         amount_in_words_ind,
         use_currency_100_ind,
         document_level_code,
         financial_code,
         taxable_ind,
         doc_template_id,
         inv_doc_template_id,
         doc_template_name,
         inv_doc_template_name,
         our_contact,
         our_contact_phone,
         cur_doc_template_name,
         fin_interface_file,
         send_unit_price_ind,
         bank_details_level_code,
         document_concept,
         reversal_ind,
         int_base_amount_src,
         contract_term_code,
         doc_sequence_accrual_id,--New Doc Sequence Attributes
         doc_sequence_final_id,
         doc_number_format_accrual,
         doc_number_format_final,
         payment_scheme_id,
         contract_area_code,
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
         date_6,
         date_7,
         date_8,
         date_9,
         date_10,
         single_parcel_doc_ind,
         created_by
    )
    SELECT
         object_id,
         p_contract_doc_object_id,
         lv2_doc_id,
         p_daytime,
         Ecdp_Contract_Setup.getDocDate(p_object_id, lv2_doc_id, p_daytime, p_document_date, p_contract_doc_object_id),
         lrec_contract_doc_version.doc_date_calendar_coll_id,
         lrec_contract_doc_version.doc_rec_calendar_coll_id,
         lrec_contract_doc_version.payment_calendar_coll_id,
         p_document_type,
         lv2_preceding_doc_id,
         p_parent_doc_id,
         p_context.user_id,
         ec_currency.object_code(ec_contract_doc_version.booking_currency_id(p_contract_doc_object_id, p_daytime, '<=')),-- booking_currency_code
         lrec_contract_doc_version.booking_currency_id,
         lrec_contract_doc_version.book_document_code,
         ec_currency.object_code(ec_contract_doc_version.memo_currency_id(p_contract_doc_object_id, p_daytime, '<=')),--memo_currency_code
         lrec_contract_doc_version.memo_currency_id,
         lrec_contract_doc_version.price_basis,
         ec_contract_version.name(p_object_id, p_daytime, '<='), -- contract_name
         ec_contract.object_code(p_object_id), -- contract_reference
         ec_contract_version.contract_group_code(p_object_id, p_daytime, '<='),
         lrec_contract_doc_version.doc_scope,
         ec_contract_version.company_id(p_object_id, p_daytime, '<='),
         lrec_contract_doc_version.doc_date_term_id,
         lrec_contract_doc_version.doc_received_base_code,
         Ecdp_Contract_Setup.getBaseDate(p_object_id, lv2_doc_id, p_daytime, 'DOC_RECEIVED', p_contract_doc_object_id), -- doc_received_base_date may return null
         lrec_contract_doc_version.doc_received_term_id,
         Ecdp_Contract_Setup.getDueDate(p_object_id, lv2_doc_id, p_daytime, 'DOC_RECEIVED', p_contract_doc_object_id), -- document_received_date may return null
         lrec_contract_doc_version.payment_term_base_code,
         Ecdp_Contract_Setup.getBaseDate(p_object_id, lv2_doc_id, p_daytime, 'PAYMENT', p_contract_doc_object_id, lv2_vendor_id), -- payment_term_base_date may return null
         ec_payment_term_version.name(ec_contract_doc_version.payment_term_id(p_contract_doc_object_id, p_daytime, '<='), p_daytime, '<='), --payment_term_name
         Ecdp_Contract_Setup.getDueDate(p_object_id, lv2_doc_id, p_daytime, 'PAYMENT', p_contract_doc_object_id, lv2_vendor_id),  -- pay_date may return null
         lrec_contract_doc_version.payment_term_id,
         lrec_contract_doc_version.amount_in_words,
         lrec_contract_doc_version.use_currency_100_ind,
         'OPEN', -- set document level to open initially
         lv2_fin_code,
         'N', -- Taxable always set to N initally
         lrec_contract_doc_version.doc_template_id,
         lrec_contract_doc_version.inv_doc_template_id,
         ec_doc_template_version.name(lrec_contract_doc_version.doc_template_id,p_daytime,'<='), -- doc templ code
         ec_doc_template_version.name(lrec_contract_doc_version.inv_doc_template_id,p_daytime,'<='), -- inv doc templ code
         lv2_our_contact,
         lv2_our_phone,
         ec_doc_template_version.name(lrec_contract_doc_version.doc_template_id,p_daytime,'<='), -- current_document_template
         NULL, -- fin_interface_ind
         lrec_contract_doc_version.send_unit_price_ind,
         ec_contract_version.bank_details_level_code(p_object_id, p_daytime, '<='),
         lrec_contract_doc_version.doc_concept_code,
         'N',
         lrec_contract_doc_version.int_base_amount_source,
         ec_contract_version.contract_term_code(p_object_id, p_daytime, '<='),
         lrec_contract_doc_version.doc_sequence_accrual_id,
         lrec_contract_doc_version.doc_sequence_final_id,
         lrec_contract_doc_version.doc_number_format_accrual,
         lrec_contract_doc_version.doc_number_format_final,
         lrec_contract_doc_version.payment_scheme_id,
         ec_contract_area.object_code(ec_contract_version.contract_area_id(ec_contract_doc.contract_id(p_contract_doc_object_id),p_daytime,'<=')),
         ec_contract_version.value_1(p_object_id, p_daytime, '<='),
         ec_contract_version.value_2(p_object_id, p_daytime, '<='),
         ec_contract_version.value_3(p_object_id, p_daytime, '<='),
         ec_contract_version.value_4(p_object_id, p_daytime, '<='),
         ec_contract_version.value_5(p_object_id, p_daytime, '<='),
         lrec_contract_doc_version.value_6,
         lrec_contract_doc_version.value_7,
         lrec_contract_doc_version.value_8,
         lrec_contract_doc_version.value_9,
         lrec_contract_doc_version.value_10,
         ec_contract_version.text_1(p_object_id, p_daytime, '<='),
         ec_contract_version.text_2(p_object_id, p_daytime, '<='),
         ec_contract_version.text_3(p_object_id, p_daytime, '<='),
         ec_contract_version.text_4(p_object_id, p_daytime, '<='),
         ec_contract_version.text_5(p_object_id, p_daytime, '<='),
         lrec_contract_doc_version.text_6,
         lrec_contract_doc_version.text_7,
         lrec_contract_doc_version.text_8,
         lrec_contract_doc_version.text_9,
         lrec_contract_doc_version.text_10,
         ec_contract_version.date_1(p_object_id, p_daytime, '<='),
         ec_contract_version.date_2(p_object_id, p_daytime, '<='),
         ec_contract_version.date_3(p_object_id, p_daytime, '<='),
         ec_contract_version.date_4(p_object_id, p_daytime, '<='),
         ec_contract_version.date_5(p_object_id, p_daytime, '<='),
         lrec_contract_doc_version.date_6,
         lrec_contract_doc_version.date_7,
         lrec_contract_doc_version.date_8,
         lrec_contract_doc_version.date_9,
         lrec_contract_doc_version.date_10,
         lrec_contract_doc_version.single_parcel_doc_ind,
         p_context.user_id
    FROM contract
    WHERE object_id = p_object_id;

    -- ECPD-5705; Document type is updated using a qualified validation
    SetDocumentType(lv2_doc_id);

    IF (lrec_contract_doc_version.doc_concept_code LIKE 'DEPENDENT%' OR lrec_contract_doc_version.doc_concept_code = 'REALLOCATION') AND lv2_preceding_doc_id IS NOT NULL THEN

    /* TD6784 - Evaluating currencies on preceding document against the configured currencies for the new document
       All three currencies must match in order to continue successfully
     */
     IF ( ec_cont_document.booking_currency_id(lv2_doc_id) <> ec_cont_document.booking_currency_id(lv2_preceding_doc_id) OR
        nvl(ec_cont_document.memo_currency_id(lv2_doc_id),'XXX') <> nvl(ec_cont_document.memo_currency_id(lv2_preceding_doc_id),'XXX'))
        THEN
        Raise_Application_Error(-20000,'New document '||lv2_doc_id||', and preceding document '||lv2_preceding_doc_id||' are configured with different currencies');

     END IF;

    END IF;

    -- insert into CONT_DOCUMENT_TEXT_ITEM
    FOR TextItemCur IN c_text_item LOOP

        INSERT INTO cont_document_text_item
            (object_id
            ,document_key
            ,text_item_id
            ,text_item_type
            ,text_item_column_type
            ,sort_order
            ,column_1
            ,column_2
            ,column_3
            ,created_date
            ,created_by
            ,record_status )
        VALUES
            (p_object_id
            ,lv2_doc_id
            ,TextItemCur.object_id
            ,TextItemCur.text_item_type
            ,TextItemCur.text_item_column_type
            ,TextItemCur.sort_order
            ,TextItemCur.column1
            ,TextItemCur.column2
            ,TextItemCur.column3
            ,Ecdp_Timestamp.getCurrentSysdate
            ,p_context.user_id
            ,'P');

    END LOOP;


    -- Verify that currencies are the same on both documents
    IF (lrec_contract_doc_version.doc_concept_code LIKE 'DEPENDENT%' OR lrec_contract_doc_version.doc_concept_code = 'REALLOCATION') AND lv2_preceding_doc_id IS NOT NULL THEN
        IF (ec_cont_document.booking_currency_code(lv2_preceding_doc_id) <>
          ec_currency.object_code(ec_contract_doc_version.booking_currency_id(p_contract_doc_object_id, p_daytime, '<='))
          OR ec_cont_document.memo_currency_code(lv2_preceding_doc_id) <>
          ec_currency.object_code(ec_contract_doc_version.memo_currency_id(p_contract_doc_object_id, p_daytime, '<='))
          ) THEN
              Raise_Application_Error(-20000, 'Can not create dependent document based on a document with different pricing, booking or memo currency. Please update document setup and rerun.');
        END IF;
    END IF;



    IF (p_doc_id IS NULL) THEN

        -- Reverse Transactions from Preceding Document
        IF lrec_contract_doc_version.doc_concept_code IN ('DEPENDENT','DEPENDENT_PARTIALLY_REVERSAL','REALLOCATION') AND lv2_preceding_doc_id IS NOT NULL THEN
            FOR PreTransCur IN c_pre_trans(lv2_preceding_doc_id) LOOP

            lv2_tmp_var := ecdp_transaction.getDependentTransaction(PreTransCur.Id);

                 IF lv2_tmp_var is NOT NULL AND IsPrecedingReverseDocOpen(PreTransCur.Id)<>'N' THEN
                         Raise_Application_Error(-20000,'Reversal Document is not booked. Document: '||IsPrecedingReverseDocOpen(PreTransCur.Id));
                   END IF;
                 IF  lv2_tmp_var is NOT NULL  AND ec_cont_transaction.ppa_trans_code(lv2_tmp_var)='PPA_PRICE' THEN

                  lv2_tmp_var  :=Ecdp_Transaction.GetLatestnGreatestTran(PreTransCur.Id);
                  lv2_trans_id := EcDp_Transaction.ReverseTransaction(p_object_id, p_daytime, lv2_doc_id, lv2_tmp_var, p_context.user_id, 'Reversal of: ');


                ELSIF  lv2_tmp_var is NOT NULL AND ecdp_transaction.GetReversalTransaction(lv2_tmp_var) is NULL  THEN
                   l_logger.warning(PreTransCur.Id|| ' is excluded from reversal because it is preceding for ['||ec_cont_transaction.document_key(lv2_tmp_var)||' / '||lv2_tmp_var||']');
                   ELSE
                    lv2_trans_id := EcDp_Transaction.ReverseTransaction(p_object_id, p_daytime, lv2_doc_id, PreTransCur.id, p_context.user_id, 'Reversal of: ');
                END IF;
            END LOOP;
        END IF;

        -- Reverse Transactions from Preceding Document. This section is for depemdent previous month correction documents only
        -- Make sure only relevant transactions are reversed.
        IF lrec_contract_doc_version.doc_concept_code = 'DEPENDENT_PREV_MTH_CORR' AND lv2_preceding_doc_id IS NOT NULL THEN
            FOR PreTransCur IN c_pre_trans_prov(lv2_preceding_doc_id) LOOP

            lv2_tmp_var := ecdp_transaction.getDependentTransaction(PreTransCur.Id);
                  IF lv2_tmp_var is NOT NULL AND IsPrecedingReverseDocOpen(PreTransCur.Id)<>'N' THEN
                         Raise_Application_Error(-20000,'Reversal Document is not booked. Document: '||IsPrecedingReverseDocOpen(PreTransCur.Id));
                   END IF;

                 IF  lv2_tmp_var is NOT NULL  AND ec_cont_transaction.ppa_trans_code(lv2_tmp_var)='PPA_PRICE' THEN

                  lv2_tmp_var  :=Ecdp_Transaction.GetLatestnGreatestTran(PreTransCur.Id);
                  lv2_trans_id := EcDp_Transaction.ReverseTransaction(p_object_id, p_daytime, lv2_doc_id, lv2_tmp_var, p_context.user_id, 'Reversal of: ');


                ELSIF  lv2_tmp_var is NOT NULL AND ecdp_transaction.GetReversalTransaction(lv2_tmp_var) is NULL  THEN
                   l_logger.warning(PreTransCur.Id|| ' is excluded from reversal because it is preceding for ['||ec_cont_transaction.document_key(lv2_tmp_var)||' / '||lv2_tmp_var||']');
                   ELSE
                     lv2_trans_id := EcDp_Transaction.ReverseTransaction(p_object_id, p_daytime, lv2_doc_id, PreTransCur.id, p_context.user_id, 'Reversal of: ');
                END IF;
            END LOOP;
        END IF;

        -- Reverse Transactions from Preceding Document which has QTY based line items
        IF lrec_contract_doc_version.doc_concept_code IN ('DEPENDENT_ONLY_QTY_REVERSAL') AND lv2_preceding_doc_id IS NOT NULL THEN
            FOR PreQtyTransCur IN c_pre_qty_trans(lv2_preceding_doc_id) LOOP

            lv2_tmp_var := ecdp_transaction.getDependentTransaction(PreQtyTransCur.Id);

                  IF lv2_tmp_var is NOT NULL AND IsPrecedingReverseDocOpen(PreQtyTransCur.Id)<>'N' THEN
                         Raise_Application_Error(-20000,'Reversal Document is not booked. Document: '||IsPrecedingReverseDocOpen(PreQtyTransCur.Id));
                   END IF;

                IF  lv2_tmp_var is NOT NULL  AND ec_cont_transaction.ppa_trans_code(lv2_tmp_var)='PPA_PRICE' THEN

                  lv2_tmp_var  :=Ecdp_Transaction.GetLatestnGreatestTran(PreQtyTransCur.Id);
                  lv2_trans_id := EcDp_Transaction.ReverseTransaction(p_object_id, p_daytime, lv2_doc_id, lv2_tmp_var, p_context.user_id, 'Reversal of: ');


                ELSIF  lv2_tmp_var is NOT NULL AND ecdp_transaction.GetReversalTransaction(lv2_tmp_var) is NULL  THEN
                   l_logger.warning(PreQtyTransCur.Id|| ' is excluded from reversal because it is preceding for ['||ec_cont_transaction.document_key(lv2_tmp_var)||' / '||lv2_tmp_var||']');
                   ELSE
                   lv2_trans_id := EcDp_Transaction.ReverseTransaction(p_object_id, p_daytime, lv2_doc_id, PreQtyTransCur.id, p_context.user_id, 'Reversal of: ');
                     END IF;
            END LOOP;
        END IF;

        -- insert any transactions from transaction_template
        --  ECPD-5705; We want a transaction for each transasction template defined.
        --  The user will have to delete manually the transaction that does not fit his/her need.
        ln_cnt := 0;

        IF p_insert_transactions_ind = 'N' THEN

           /* ECPD-13449:
              When quantities are based on interface records, transactions will be created based on a when-needed policy
              i.e when actual interface records are being resolved for a particular contract.
           */

           NULL;

        ELSE

           -- Loop through available transaction templates for the given document setup
           FOR templates IN gc_transaction_templates (p_contract_doc_object_id, p_daytime) LOOP

               -- Clean up reference
               lv2_trans_id := NULL;

              -- Loop through all possible preceding transactions that fit the current transaction template
              FOR transactions IN gc_transactions(lv2_preceding_doc_id,
                                                  lrec_contract_doc_version.doc_concept_code,
                                                  templates.stream_item_id,
                                                  templates.price_concept_code,
                                                  templates.product_id,
                                                  templates.entry_point_id,
                                                  templates.transaction_scope,
                                                  templates.transaction_type,
                                                  templates.dist_code,
                                                  templates.dist_object_type) LOOP


                  -- Creating a new transaction based on transaction template / preceding transaction
                  lv2_trans_id := EcDp_Transaction.InsNewTransaction(p_object_id,
                                                                     p_daytime,
                                                                     lv2_doc_id,
                                                                     templates.transaction_type,
                                                                     templates.id,
                                                                     p_context.user_id,
                                                                     NULL,
                                                                     NVL(Ecdp_transaction.GetLatestnGreatestTran(transactions.transaction_key), transactions.transaction_key),
                                                                     transactions.ifac_unique_key_1,
                                                                     transactions.ifac_unique_key_2,
                                                                     transactions.supply_from_date,
                                                                     transactions.supply_to_date,
                                                                     transactions.delivery_point_id,
                                                                     'Y',
                                                                     transactions.vat_code);


              END LOOP;

              -- If no match with preceding is found - creating standard transaction based on template
              IF lv2_trans_id IS NULL THEN
                 lv2_trans_id := EcDp_Transaction.InsNewTransaction(p_object_id, p_daytime, lv2_doc_id, templates.transaction_type, templates.id, p_context.user_id);
              END IF;


              -- Setting parcel name based on sort order on transaction template. Only for new cargo transaction which are not reversals or dependent.
              IF lv2_trans_id IS NOT NULL
              AND ec_cont_transaction.transaction_scope(lv2_trans_id) = 'CARGO_BASED'
              AND ec_cont_transaction.reversal_ind(lv2_trans_id) = 'N'
              AND ec_cont_transaction.preceding_trans_key(lv2_trans_id) IS NULL THEN

                  ln_cnt := ln_cnt + 1;
                  UPDATE CONT_TRANSACTION ct
                  SET PARCEL_NAME = ln_cnt
                  WHERE ct.transaction_key = lv2_trans_id;
              END IF;

        END LOOP;

     END IF;

     END IF;

    IF (lrec_contract_doc_version.doc_concept_code LIKE 'DEPENDENT%' OR lrec_contract_doc_version.doc_concept_code = 'REALLOCATION') AND lv2_preceding_doc_id IS NOT NULL THEN
    -- one of those should be enough, but check both anyway.

        UPDATE cont_document SET

            last_updated_by = p_context.user_id

            -- Update custom attributes from preceding doc if they are empty
            ,value_1 =  (CASE WHEN lrec_preceding_doc.value_1  IS NOT NULL AND value_1  IS NULL THEN lrec_preceding_doc.value_1  ELSE value_1  END)
            ,value_2 =  (CASE WHEN lrec_preceding_doc.value_2  IS NOT NULL AND value_2  IS NULL THEN lrec_preceding_doc.value_2  ELSE value_2  END)
            ,value_3 =  (CASE WHEN lrec_preceding_doc.value_3  IS NOT NULL AND value_3  IS NULL THEN lrec_preceding_doc.value_3  ELSE value_3  END)
            ,value_4 =  (CASE WHEN lrec_preceding_doc.value_4  IS NOT NULL AND value_4  IS NULL THEN lrec_preceding_doc.value_4  ELSE value_4  END)
            ,value_5 =  (CASE WHEN lrec_preceding_doc.value_5  IS NOT NULL AND value_5  IS NULL THEN lrec_preceding_doc.value_5  ELSE value_5  END)
            ,value_6 =  (CASE WHEN lrec_preceding_doc.value_6  IS NOT NULL AND value_6  IS NULL THEN lrec_preceding_doc.value_6  ELSE value_6  END)
            ,value_7 =  (CASE WHEN lrec_preceding_doc.value_7  IS NOT NULL AND value_7  IS NULL THEN lrec_preceding_doc.value_7  ELSE value_7  END)
            ,value_8 =  (CASE WHEN lrec_preceding_doc.value_8  IS NOT NULL AND value_8  IS NULL THEN lrec_preceding_doc.value_8  ELSE value_8  END)
            ,value_9 =  (CASE WHEN lrec_preceding_doc.value_9  IS NOT NULL AND value_9  IS NULL THEN lrec_preceding_doc.value_9  ELSE value_9  END)
            ,value_10 = (CASE WHEN lrec_preceding_doc.value_10 IS NOT NULL AND value_10 IS NULL THEN lrec_preceding_doc.value_10 ELSE value_10 END)
            ,text_1 =   (CASE WHEN lrec_preceding_doc.text_1   IS NOT NULL AND text_1   IS NULL THEN lrec_preceding_doc.text_1   ELSE text_1   END)
            ,text_2 =   (CASE WHEN lrec_preceding_doc.text_2   IS NOT NULL AND text_2   IS NULL THEN lrec_preceding_doc.text_2   ELSE text_2   END)
            ,text_3 =   (CASE WHEN lrec_preceding_doc.text_3   IS NOT NULL AND text_3   IS NULL THEN lrec_preceding_doc.text_3   ELSE text_3   END)
            ,text_4 =   (CASE WHEN lrec_preceding_doc.text_4   IS NOT NULL AND text_4   IS NULL THEN lrec_preceding_doc.text_4   ELSE text_4   END)
            ,text_5 =   (CASE WHEN lrec_preceding_doc.text_5   IS NOT NULL AND text_5   IS NULL THEN lrec_preceding_doc.text_5   ELSE text_5   END)
            ,text_6 =   (CASE WHEN lrec_preceding_doc.text_6   IS NOT NULL AND text_6   IS NULL THEN lrec_preceding_doc.text_6   ELSE text_6   END)
            ,text_7 =   (CASE WHEN lrec_preceding_doc.text_7   IS NOT NULL AND text_7   IS NULL THEN lrec_preceding_doc.text_7   ELSE text_7   END)
            ,text_8 =   (CASE WHEN lrec_preceding_doc.text_8   IS NOT NULL AND text_8   IS NULL THEN lrec_preceding_doc.text_8   ELSE text_8   END)
            ,text_9 =   (CASE WHEN lrec_preceding_doc.text_9   IS NOT NULL AND text_9   IS NULL THEN lrec_preceding_doc.text_9   ELSE text_9   END)
            ,text_10 =  (CASE WHEN lrec_preceding_doc.text_10  IS NOT NULL AND text_10  IS NULL THEN lrec_preceding_doc.text_10  ELSE text_10  END)
            ,date_1 =   (CASE WHEN lrec_preceding_doc.date_1   IS NOT NULL AND date_1   IS NULL THEN lrec_preceding_doc.date_1   ELSE date_1   END)
            ,date_2 =   (CASE WHEN lrec_preceding_doc.date_2   IS NOT NULL AND date_2   IS NULL THEN lrec_preceding_doc.date_2   ELSE date_2   END)
            ,date_3 =   (CASE WHEN lrec_preceding_doc.date_3   IS NOT NULL AND date_3   IS NULL THEN lrec_preceding_doc.date_3   ELSE date_3   END)
            ,date_4 =   (CASE WHEN lrec_preceding_doc.date_4   IS NOT NULL AND date_4   IS NULL THEN lrec_preceding_doc.date_4   ELSE date_4   END)
            ,date_5 =   (CASE WHEN lrec_preceding_doc.date_5   IS NOT NULL AND date_5   IS NULL THEN lrec_preceding_doc.date_5   ELSE date_5   END)
            ,date_6 =   (CASE WHEN lrec_preceding_doc.date_6   IS NOT NULL AND date_6   IS NULL THEN lrec_preceding_doc.date_6   ELSE date_6   END)
            ,date_7 =   (CASE WHEN lrec_preceding_doc.date_7   IS NOT NULL AND date_7   IS NULL THEN lrec_preceding_doc.date_7   ELSE date_7   END)
            ,date_8 =   (CASE WHEN lrec_preceding_doc.date_8   IS NOT NULL AND date_8   IS NULL THEN lrec_preceding_doc.date_8   ELSE date_8   END)
            ,date_9 =   (CASE WHEN lrec_preceding_doc.date_9   IS NOT NULL AND date_9   IS NULL THEN lrec_preceding_doc.date_9   ELSE date_9   END)
            ,date_10 =  (CASE WHEN lrec_preceding_doc.date_10  IS NOT NULL AND date_10  IS NULL THEN lrec_preceding_doc.date_10  ELSE date_10  END)

         WHERE object_id = p_object_id
        AND document_key = lv2_doc_id;

    END IF;

    -- Specific copy from preceding for REALLOCATION documents
    IF lrec_contract_doc_version.doc_concept_code = 'REALLOCATION' AND lv2_preceding_doc_id IS NOT NULL THEN

        UPDATE cont_document cd SET
          cd.status_code = lrec_preceding_doc.status_code
        WHERE object_id = p_object_id
        AND document_key = lv2_doc_id;

    END IF;

    EcDp_Line_Item.UpdIntBaseAmount(p_object_id,lv2_doc_id,GetFirstPreceedingDocId(p_object_id,lv2_doc_id)); -- Updating interest base amount / interest from data /interest to date

    RETURN lv2_doc_id;

END InsNewDocument_p;

PROCEDURE InsNewDocumentVendor
(   p_object_id VARCHAR2,
    p_doc_setup_id VARCHAR2,
    p_doc_id VARCHAR2,
    p_vendor_id VARCHAR2,
    p_user VARCHAR2
)

IS

lv2_vat_reg_no VARCHAR2(200);
ld_doc_date DATE := ec_cont_document.daytime(p_doc_id);
lv2_country_id VARCHAR2(32);
lv2_vendor_vat_reg_no_own VARCHAR2(200);
lv2_vendor_vat_reg_no_final VARCHAR2(200);
lv2_vendor_country_id VARCHAR2(32);
lv2_vendor_country_id_final VARCHAR2(32);
lv2_booking_currency_id VARCHAR2(32);
lrec_bank_details EcDp_Contract_Setup.t_bank_details;


BEGIN
    lv2_booking_currency_id := ec_cont_document.booking_currency_id(p_doc_id);
    lrec_bank_details := EcDp_Contract_Setup.GetCompBankDetails(p_object_id, p_vendor_id, 'VENDOR', lv2_booking_currency_id, ld_doc_date, p_doc_setup_id);
    lv2_country_id := Ecdp_Transaction.GetDestinationCountryId(p_doc_id);

    IF lv2_country_id IS NOT NULL THEN
       lv2_vendor_country_id_final := lv2_country_id;
       lv2_vat_reg_no := ec_company_country_setup.VAT_REG_NO(p_vendor_id, lv2_country_id, ld_doc_date, '<=');
       lv2_vendor_vat_reg_no_final := lv2_vat_reg_no;

       IF lv2_vat_reg_no IS NULL THEN
          lv2_vendor_country_id := ec_company_version.country_id(p_vendor_id, ld_doc_date, '<=');
          lv2_vendor_vat_reg_no_own := ec_company_country_setup.VAT_REG_NO(p_vendor_id, lv2_vendor_country_id, ld_doc_date, '<=');
          lv2_vendor_vat_reg_no_final := lv2_vendor_vat_reg_no_own;
          lv2_vendor_country_id_final := lv2_vendor_country_id;
       END IF;
    ELSE
       lv2_vendor_country_id := ec_company_version.country_id(p_vendor_id, ld_doc_date, '<=');
       lv2_vendor_vat_reg_no_own := ec_company_country_setup.VAT_REG_NO(p_vendor_id, lv2_vendor_country_id, ld_doc_date, '<=');
       lv2_vendor_vat_reg_no_final := lv2_vendor_vat_reg_no_own;
       lv2_vendor_country_id_final := lv2_vendor_country_id;
    END IF;

    INSERT INTO cont_document_company
        (OBJECT_ID,
        DOCUMENT_KEY,
        COMPANY_ID,
        COMPANY_CATEGORY_CODE,
        BANK_ACCOUNT_ID,
        BANK_INFO,
        BANK_ACCOUNT_INFO,
        VAT_REG_NO,
        EXVAT_RECEIVER_ID,
        VAT_RECEIVER_ID,
        PAYMENT_SCHEME_ID,
        COUNTRY_ID,
        PAYMENT_CALENDAR_COLL_ID,
        PAYMENT_TERM_BASE_CODE,
        PAYMENT_TERM_ID,
        PAY_DATE,
        PAYMENT_DUE_BASE_DATE,
        COMPANY_ROLE,
        SPLIT_SHARE,
        CREATED_BY,
        RECORD_STATUS)
    VALUES
        (p_object_id,
        p_doc_id,
        p_vendor_id,
        ec_prosty_codes.alt_code(ec_company_version.group_code(p_vendor_id, ld_doc_date, '<='),'VENDOR_GROUP_CODE'),
        --ec_cont_document.pay_date(p_doc_id),
        lrec_bank_details.bank_account_id,
        lrec_bank_details.bank_info,
        lrec_bank_details.bank_account_info,
        lv2_vendor_vat_reg_no_final,
        ec_contract_party_share.exvat_receiver_id(p_object_id, p_vendor_id, 'VENDOR', ld_doc_date, '<='),
        ec_contract_party_share.vat_receiver_id(p_object_id, p_vendor_id, 'VENDOR', ld_doc_date, '<='),
        ec_contract_doc_company.payment_scheme_id(p_doc_setup_id, p_vendor_id, 'VENDOR', ld_doc_date, '<='),
        lv2_vendor_country_id_final,
        ec_contract_doc_company.payment_calendar_coll_id(p_doc_setup_id, p_vendor_id, 'VENDOR', ld_doc_date, '<='),
        ec_contract_doc_company.payment_term_base_code(p_doc_setup_id, p_vendor_id, 'VENDOR', ld_doc_date, '<='),
        ec_contract_doc_company.payment_term_id(p_doc_setup_id, p_vendor_id, 'VENDOR', ld_doc_date, '<='),
        Ecdp_Contract_Setup.getDueDate(p_object_id, p_doc_id, ld_doc_date, 'PAYMENT', p_doc_setup_id, p_vendor_id),
        Ecdp_Contract_Setup.getBaseDate(p_object_id, p_doc_id, ld_doc_date, 'PAYMENT', p_doc_setup_id, p_vendor_id),
        'VENDOR',
        ec_contract_party_share.party_share(p_object_id, p_vendor_id, 'VENDOR', ld_doc_date, '<='),
        p_user,
        'P');


END InsNewDocumentVendor;

PROCEDURE InsNewDocumentCustomer(
    p_object_id                     VARCHAR2,
    p_doc_setup_id                  VARCHAR2,
    p_doc_id                        VARCHAR2,
    p_customer_id                   VARCHAR2,
    p_user                          VARCHAR2,
    p_d_doc_date                    VARCHAR2 DEFAULT NULL,
    p_d_booking_currency_id         VARCHAR2 DEFAULT NULL
)
IS

    ld_doc_date                     DATE;
    lv2_vat_reg_no                  VARCHAR2(200);
    lv2_country_id                  VARCHAR2(32);
    lv2_customer_vat_reg_no_own     VARCHAR2(200);
    lv2_customer_vat_reg_no_final   VARCHAR2(200);
    lv2_customer_country_id         VARCHAR2(32);
    lv2_customer_country_id_final   VARCHAR2(32);
    lv2_booking_currency_id         VARCHAR2(32);
    lrec_bank_details               EcDp_Contract_Setup.t_bank_details;

BEGIN

    IF p_d_doc_date IS NOT NULL
    THEN
        ld_doc_date := p_d_doc_date;
    ELSE
        ld_doc_date := ec_cont_document.daytime(p_doc_id);
    END IF;

    IF p_d_booking_currency_id IS NOT NULL
    THEN
        lv2_booking_currency_id := p_d_booking_currency_id;
    ELSE
        lv2_booking_currency_id := ec_cont_document.booking_currency_id(p_doc_id);
    END IF;

    lrec_bank_details := EcDp_Contract_Setup.GetCompBankDetails(
        p_object_id,
        p_customer_id,
        'CUSTOMER',
        lv2_booking_currency_id,
        ld_doc_date);

    lv2_country_id := Ecdp_Transaction.GetDestinationCountryId(p_doc_id);

    IF lv2_country_id IS NOT NULL
    THEN
       lv2_customer_country_id_final := lv2_country_id;
       lv2_vat_reg_no := ec_company_country_setup.VAT_REG_NO(p_customer_id, lv2_country_id, ld_doc_date, '<=');
       lv2_customer_vat_reg_no_final := lv2_vat_reg_no;

       IF lv2_vat_reg_no IS NULL
       THEN
          lv2_customer_country_id := ec_company_version.country_id(p_customer_id, ld_doc_date, '<=');
          lv2_customer_vat_reg_no_own := ec_company_country_setup.VAT_REG_NO(p_customer_id, lv2_customer_country_id, ld_doc_date, '<=');
          lv2_customer_vat_reg_no_final := lv2_customer_vat_reg_no_own;
          lv2_customer_country_id_final := lv2_customer_country_id;
       END IF;
    END IF;


    INSERT INTO cont_document_company (
        OBJECT_ID,
        DOCUMENT_KEY,
        COMPANY_ID,
        COMPANY_CATEGORY_CODE,
        BANK_ACCOUNT_ID,
        BANK_INFO,
        BANK_ACCOUNT_INFO,
        VAT_REG_NO,
        EXVAT_RECEIVER_ID,
        VAT_RECEIVER_ID,
        PAYMENT_SCHEME_ID,
        COUNTRY_ID,
        COMPANY_ROLE,
        SPLIT_SHARE,
        CREATED_BY,
        RECORD_STATUS)
    VALUES (
        p_object_id,
        p_doc_id,
        p_customer_id,
        ec_prosty_codes.alt_code(ec_company_version.group_code(p_customer_id, ld_doc_date, '<='),'CUSTOMER_GROUP_CODE'),
        --ec_cont_document.pay_date(p_doc_id),
        lrec_bank_details.bank_account_id,
        lrec_bank_details.bank_info,
        lrec_bank_details.bank_account_info,
        lv2_customer_vat_reg_no_final,
        ec_contract_party_share.exvat_receiver_id(p_object_id, p_customer_id, 'CUSTOMER', ld_doc_date, '<='),
        ec_contract_party_share.vat_receiver_id(p_object_id, p_customer_id, 'CUSTOMER', ld_doc_date, '<='),
        ec_contract_doc_company.payment_scheme_id(p_doc_setup_id, p_customer_id, 'CUSTOMER', ld_doc_date, '<='),
        lv2_customer_country_id_final,
        'CUSTOMER',
        ec_contract_party_share.party_share(p_object_id, p_customer_id, 'CUSTOMER', ld_doc_date, '<='),
        p_user,
        'P');

END InsNewDocumentCustomer;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  GenDocumentSet_app
-- Description    : Called from Process Document General -> Create Document button.
--                  Creates a new Document based on Contract and selected Document Setup
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
FUNCTION GenDocumentSet_app(p_object_id           VARCHAR2,
                        p_contract_doc_object_id  VARCHAR2,
                        p_preceding_doc_id        VARCHAR2,
                        p_daytime                 DATE,
                        p_document_date           DATE,
                        p_log_item_no             NUMBER,
                        p_user                    VARCHAR2,
                        p_doc_id                  VARCHAR2 DEFAULT NULL, -- This is to load existing data, child logic disabled
                        p_dg_doc_key              VARCHAR2 DEFAULT NULL, -- Document key set from Period/Cargo Document Generation. To use for delete if GenNewDoc fails.
                        p_insert_transactions_ind VARCHAR2 DEFAULT 'Y',
                        p_is_PPA                  VARCHAR2 DEFAULT 'N')
RETURN VARCHAR2
IS
    l_context t_revn_doc_op_context;
BEGIN
    l_context := t_revn_doc_op_context;
    l_context.config_logger(p_log_item_no, 'PERIOD_DG');
    l_context.user_id := p_user;

    RETURN GenDocumentSet_I(
        l_context,
        p_object_id, p_contract_doc_object_id, p_preceding_doc_id, p_daytime,
        p_document_date, p_doc_id, p_dg_doc_key, p_insert_transactions_ind, p_is_PPA);
END GenDocumentSet_app;



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  GenDocumentSet_I
-- Description    : Called from GenDocumentSet_app, it is for internal use (inside the DB).
--                  Creates a new Document based on Contract and selected Document Setup
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
FUNCTION GenDocumentSet_I(p_context               IN OUT NOCOPY t_revn_doc_op_context,
                        p_object_id               VARCHAR2,
                        p_contract_doc_object_id  VARCHAR2,
                        p_preceding_doc_id        VARCHAR2,
                        p_daytime                 DATE,
                        p_document_date           DATE,
                        p_doc_id                  VARCHAR2 DEFAULT NULL, -- This is to load existing data, child logic disabled
                        p_dg_doc_key              VARCHAR2 DEFAULT NULL, -- Document key set from Period/Cargo Document Generation. To use for delete if GenNewDoc fails.
                        p_insert_transactions_ind VARCHAR2 DEFAULT 'Y',
                        p_is_PPA                  VARCHAR2 DEFAULT 'N')
  RETURN VARCHAR2

IS

  CURSOR c_preceding_doc(pc_doc_id VARCHAR2) IS
  SELECT *
    FROM cont_document
   WHERE object_id = p_object_id
     AND document_key = pc_doc_id; -- the preceding document id

  CURSOR c_dependent_docs(pc_pre_doc_id VARCHAR2) IS
  SELECT cd.document_key
    FROM cont_document cd
   WHERE cd.preceding_document_key = pc_pre_doc_id;


  CURSOR c_reversal_doc(pc_doc_id VARCHAR2) IS -- check if pc_doc_id is a reversal
  SELECT *
    FROM cont_document c
   WHERE c.object_id = p_object_id
     AND c.document_key = pc_doc_id
     AND c.preceding_document_key IS NOT NULL
     AND EXISTS (
          SELECT 'x'
            FROM cont_document c2
           WHERE c2.object_id = c.object_id
             AND c2.document_key = c.preceding_document_key
             AND c2.actual_reversal_date IS NOT NULL);


  combination_not_use     EXCEPTION;
  invalid_combination     EXCEPTION;
  missing_vend_cust       EXCEPTION;
  no_document_concept     EXCEPTION;
  no_preceding_doc        EXCEPTION;
  is_reversed             EXCEPTION;
  is_reversal             EXCEPTION;
  dependent_exists        EXCEPTION;
  is_not_booked           EXCEPTION;
  invalid_realloc_balance EXCEPTION;
  not_processable         EXCEPTION;

  ln_customer_cnt           NUMBER;
  ln_vendor_cnt             NUMBER;
  lv2_doc_concept_code      VARCHAR2(240);
  lv2_prev_doc_concept_code VARCHAR2(240);
  lv2_doc_id                VARCHAR2(32);
  lv2_msg                   VARCHAR2(240);
  ld_daytime                DATE;
  c_val SYS_REFCURSOR;
  l_nav_selection ecdp_document_gen.t_nav;
  ln_count                  NUMBER;
  l_logger                  t_revn_logger;

BEGIN
    p_context.get_or_create_logger(l_logger);

     -- Validate if this is a valid action to make
    ecdp_document_gen.q_NavParam(c_val, p_object_id);

    LOOP
      FETCH c_val INTO l_nav_selection;
      EXIT WHEN c_val%NOTFOUND;

    END LOOP;
    CLOSE c_val;


    l_logger.update_overall_state(ec_business_unit_version.name(l_nav_selection.business_unit_id,p_daytime,'<=') || '/' ||
                                                ec_contract_area_version.name(l_nav_selection.contract_area_id,p_daytime,'<=') || '/' ||
                                                ec_contract_version.name(l_nav_selection.contract_id,p_daytime,'<='), NULL);


  -- must have contract_doc as source
    IF p_contract_doc_object_id IS NULL THEN
        RAISE no_document_concept;
    END IF;

    ld_daytime := getDocumentDaytime(p_object_id, p_contract_doc_object_id, p_document_date);

    ln_customer_cnt := EcDp_Contract_Setup.GetCustomerCnt(p_object_id, ld_daytime);
    ln_vendor_cnt   := EcDp_Contract_Setup.GetVendorCnt(p_object_id, ld_daytime);

    -- check against processable code
    IF ec_contract_version.processable_code(p_object_id, ld_daytime, '<=') = 'N' THEN
        RAISE not_processable;
    END IF;



    lv2_doc_concept_code := ec_contract_doc_version.doc_concept_code(p_contract_doc_object_id, ld_daytime, '<=');

    -- if dependent, validation must be done
    IF (lv2_doc_concept_code LIKE 'DEPENDENT%' OR lv2_doc_concept_code = 'REALLOCATION') THEN

        -- cannot make a dependent if no preceding is chosen
        IF (p_preceding_doc_id IS NULL AND lv2_doc_concept_code <> 'DEPENDENT_PREV_MTH_CORR' AND p_is_PPA ='N') THEN
            RAISE no_preceding_doc;
        END IF;

        -- checks on source document
        FOR PreDoc IN c_preceding_doc(p_preceding_doc_id) LOOP
            -- is the source document booked
            IF PreDoc.document_level_code <> 'BOOKED' THEN
                RAISE is_not_booked;
            END IF;
            -- is the source document reversed
            IF PreDoc.actual_reversal_date IS NOT NULL AND lv2_doc_concept_code <> 'DEPENDENT_WITHOUT_REVERSAL' THEN
                RAISE is_reversed;
            END IF;
        END LOOP;

        -- is the source document already the preceding of another document which is not reversed
        -- ECPD-5705; Rule still applies on doc_concept_code = DEPENDENT_PREV_MTH_CORR
        --            Preceding document cannot have another dependent document, but might itself be a dependent document
        FOR DepDoc IN c_dependent_docs(p_preceding_doc_id) LOOP

            lv2_prev_doc_concept_code := ec_contract_doc_version.doc_concept_code(ec_cont_document.contract_doc_id(DepDoc.Document_Key),ec_cont_document.daytime(DepDoc.Document_Key),'<=');

            IF HasReversedDependentDoc(p_preceding_doc_id) = 'N'
              AND lv2_doc_concept_code NOT IN('DEPENDENT_WITHOUT_REVERSAL','REALLOCATION')
              AND lv2_prev_doc_concept_code <> 'DEPENDENT_WITHOUT_REVERSAL' THEN -- ECPD-16461
                RAISE dependent_exists;
            END IF;
        END LOOP;

        -- is the source document a reversal of another document
        FOR RevDoc IN c_reversal_doc(p_preceding_doc_id) LOOP
            RAISE is_reversal;
        END LOOP;

    END IF;

    IF ln_vendor_cnt = 0  OR ln_customer_cnt = 0  THEN
       -- Missing vendor and customer
		   RAISE missing_vend_cust;
    END IF;


   -- Only allow multiple customer or multiple vendors
   IF (ln_customer_cnt = 1 OR ln_vendor_cnt = 1) THEN

     -- create single document same as contract type
      lv2_doc_id := InsNewDocument_p(p_context,
                                   p_object_id,
                                   p_contract_doc_object_id,
                                   ld_daytime,
                                   p_document_date,
                                   NULL, -- document_type
                                   p_preceding_doc_id,
                                   NULL, -- parent_doc_id
                                   p_doc_id,
                                   p_dg_doc_key,
                                   p_insert_transactions_ind);

      -- update document vendor table and document customer
      IF lv2_doc_id IS NOT NULL THEN
         InsVendorCustomer(lv2_doc_id,ld_daytime, p_context.user_id);
      END IF;

    ELSE -- Not a valid comination, should never get here - should be prevented in company splits logic
        RAISE invalid_combination;
    END IF;

    -- Recalculate the All Document Level Dates and Transaction level, if those dates are depending on transaction level Dates
    EcDp_Contract_Setup.updateAllDocumentDates(p_object_id,
                                               lv2_doc_id,
                                               ld_daytime,
                                               p_document_date,
                                               p_context.user_id,
                                               5);

    -- Deleting empty transaction in case the reallocation document was made to fit different preceding documents
    IF ec_cont_document.document_concept(lv2_doc_id) = 'REALLOCATION' THEN

       Ecdp_Transaction.DelEmptyTransactions(lv2_doc_id);

       -- Deleting transactions that does not have a preceding transaction
       Ecdp_Transaction.DelNewTransactions(lv2_doc_id);


    END IF;



    -- To force the trigger to update document_vendor
    UpdDocumentPricingTotal(p_object_id, lv2_doc_id, 'SYSTEM');

    -- Updating Recommended System Action on the new document and any preceding document in use
    Ecdp_Document_Gen.SetDocumentRecActionCode(lv2_doc_id);
    IF p_preceding_doc_id IS NOT NULL THEN
       Ecdp_Document_Gen.SetDocumentRecActionCode(p_preceding_doc_id);
    END IF;

    SELECT COUNT(transaction_key) INTO ln_count FROM cont_transaction
        WHERE document_key=lv2_doc_id
        AND ec_cont_transaction.document_key(preceding_trans_key)<>ec_cont_document.preceding_document_key(lv2_doc_id);


        IF (ln_count >0) THEN
          UPDATE Cont_Document cd SET cd.comments='Document has updates from transactions on PPA document(s)' WHERE cd.document_key=lv2_doc_id;
        END IF;

    RETURN lv2_doc_id;

EXCEPTION

     WHEN missing_vend_cust THEN

              Raise_Application_Error(-20000, 'Either customer or vendor is missing. Not able to create document for contract: ' || Nvl(ec_contract.object_code(p_object_id),' ') || ' - ' || Nvl(ec_contract_version.name(p_object_id,ld_daytime,'<='),' '));

     WHEN combination_not_use THEN

                 Raise_Application_Error(-20000, 'Combination of vendors / customers and create document indicator is not in use for contract: ' || Nvl(ec_contract.object_code(p_object_id),' ') || ' - ' || Nvl(ec_contract_version.name(p_object_id,ld_daytime,'<='),' '));

     WHEN invalid_combination THEN

                 Raise_Application_Error(-20000, 'Combination of multiple vendors and multiple customers is not allowed. Contract: ' || Nvl(ec_contract.object_code(p_object_id),' ') || ' - ' || Nvl(ec_contract_version.name(p_object_id,ld_daytime,'<='),' '));

     WHEN no_document_concept THEN

                 Raise_Application_Error(-20000, 'Please select a Document Setup before creating document.');

     WHEN no_preceding_doc THEN

                 Raise_Application_Error(-20000, 'Cannot create a dependent document without choosing a preceding document.');

     WHEN is_reversed THEN

                 Raise_Application_Error(-20000, 'Cannot create a dependent document - the source document has been reversed.');

     WHEN is_reversal THEN

                 Raise_Application_Error(-20000, 'Cannot create a dependent document - the source document is a reversal of another document.');

     WHEN dependent_exists THEN

                 Raise_Application_Error(-20000, 'Cannot create a dependent document - the source document has already a dependent document.');

    WHEN is_not_booked THEN

                 Raise_Application_Error(-20000, 'Cannot create a dependent document - the source document has not been booked.');

    WHEN invalid_realloc_balance THEN

                 Raise_Application_Error(-20000, 'Cannot create a reallocation document. ' || lv2_msg);

    WHEN not_processable THEN

                 Raise_Application_Error(-20000,'The document of this contract could not be processed!');


END GenDocumentSet_I;

FUNCTION GetDocBookExRate (
    p_object_id VARCHAR2,
    p_document_id VARCHAR2,
    p_daytime DATE,
    p_type VARCHAR2, -- 'LOCAL' or 'GROUP' are valid choices
    p_pricing_curr_code VARCHAR2,
    p_memo_curr_code VARCHAR2
    )
RETURN NUMBER

IS

    CURSOR c_trans_price_by_book IS
    SELECT sum(trans_pricing_value) / DECODE(SUM(trans_booking_value), 0, 1, SUM(trans_booking_value)) RATE
    FROM cont_transaction
    WHERE object_id = p_object_id
    AND document_key = p_document_id;

    CURSOR c_trans_other_by_book IS
    SELECT sum(trans_memo_value) / DECODE(SUM(trans_booking_value), 0, 1, SUM(trans_booking_value)) RATE
    FROM cont_transaction
    WHERE object_id = p_object_id
    AND document_key = p_document_id;

    lv2_local_curr_code VARCHAR2(32);
    lv2_group_curr_code VARCHAR2(32);

    ln_ret_val NUMBER;
    ln_trans_booking_value NUMBER;

BEGIN

    -- First a check to make sure cursors above is not dividing by zero.
    -- If so, return -1 (is ignored in IUD_CONT_DOCUMENT which uses this function.)

    SELECT sum(trans_booking_value)
    INTO ln_trans_booking_value
    FROM cont_transaction
    WHERE object_id = p_object_id
    AND document_key = p_document_id;

    IF ln_trans_booking_value = 0 THEN

        ln_ret_val := -1;

    ELSIF p_type = 'LOCAL' THEN

        lv2_local_curr_code := EcDp_Contract_Setup.GetLocalCurrencyCode(p_object_id,p_daytime);

        IF p_pricing_curr_code = lv2_local_curr_code THEN

            FOR PLTrans IN c_trans_price_by_book LOOP

                ln_ret_val := PLTrans.rate;

            END LOOP;

        ELSIF Nvl(p_memo_curr_code,'XXXX') = lv2_local_curr_code THEN

            FOR OLTrans IN c_trans_other_by_book LOOP

                ln_ret_val := OLTrans.rate;

            END LOOP;

        ELSE

            --ln_ret_val := lrec_document.ex_booking_local;
            ln_ret_val := -1;

        END IF;

    ELSIF p_type = 'GROUP' THEN

        lv2_group_curr_code := ec_ctrl_system_attribute.attribute_text(p_daytime, 'GROUP_CURRENCY_CODE', '<=');

        IF p_pricing_curr_code = lv2_group_curr_code THEN

            FOR PGTrans IN c_trans_price_by_book LOOP

                ln_ret_val := PGTrans.rate;

            END LOOP;

        ELSIF Nvl(p_memo_curr_code,'XXXX') = lv2_group_curr_code THEN

            FOR OGTrans IN c_trans_other_by_book LOOP

                ln_ret_val := OGTrans.rate;

            END LOOP;

        ELSE

            --ln_ret_val := lrec_document.ex_booking_group;
            ln_ret_val := -1;

        END IF;

    ELSE

        ln_ret_val := -1; -- should never get here. just a dummy rate value

    END IF;

    RETURN ln_ret_val;

END GetDocBookExRate;

-- Returns either 'false' or 'true' if book -> local / group is editable or not
-- Example booking -> local:
-- If booking curr = local curr => 'false'
-- If local curr = pricing curr => 'false'
-- If local curr = other curr => 'false'
-- Otherwise => 'true'
-- NB: Returned value must be lowercase
FUNCTION IsDocRateEditable (
    p_object_id VARCHAR2,
    p_document_id VARCHAR2,
    p_type VARCHAR2 -- 'LOCAL' or 'GROUP' are valid choices
    )
RETURN VARCHAR2

IS

    lrec_document cont_document%ROWTYPE := ec_cont_document.row_by_pk(p_document_id);
    lv2_local_curr_code VARCHAR2(32);
    lv2_group_curr_code VARCHAR2(32);

BEGIN

    IF p_type = 'LOCAL' THEN

        lv2_local_curr_code := EcDp_Contract_Setup.GetLocalCurrencyCode(p_object_id,lrec_document.daytime);

        IF lrec_document.booking_currency_code = lv2_local_curr_code THEN

            RETURN 'false';

        ELSIF lv2_local_curr_code = Nvl('XXX',lrec_document.memo_currency_code) THEN

            RETURN 'false';

        ELSE

            RETURN 'true';

        END IF;

    ELSIF p_type = 'GROUP' THEN

        lv2_group_curr_code := ec_ctrl_system_attribute.attribute_text(lrec_document.daytime, 'GROUP_CURRENCY_CODE', '<=');

        IF lrec_document.booking_currency_code = lv2_group_curr_code THEN

            RETURN 'false';

        ELSIF lv2_group_curr_code = Nvl('XXX',lrec_document.memo_currency_code) THEN

            RETURN 'false';

        ELSE

            RETURN 'true';

        END IF;

    ELSE -- should never get here

        RETURN 'UNDEFINED';

    END IF;

END IsDocRateEditable;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  isPurchase
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
FUNCTION isPurchase(
   p_object_id VARCHAR2,
   p_document_id VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS

lv2_return_val VARCHAR2(20) := 'FALSE';
lv2_document_type cont_document.document_type%TYPE := ec_cont_document.document_type(p_document_id);

BEGIN

   IF ((lv2_document_type LIKE '%PUR%') OR (lv2_document_type LIKE '%COST%')) THEN
         lv2_return_val := 'TRUE';
   END IF;
	 RETURN lv2_return_val;

END isPurchase;

FUNCTION isSale(
   p_object_id VARCHAR2,
   p_document_id VARCHAR2)
RETURN VARCHAR2

IS

lv2_return_val VARCHAR2(20) := 'FALSE';
lv2_document_type cont_document.document_type%TYPE := ec_cont_document.document_type(p_document_id);

BEGIN

   IF ((lv2_document_type LIKE '%SAL%') OR (lv2_document_type LIKE '%INCOME%'))  THEN
         lv2_return_val := 'TRUE';
   END IF;
	 RETURN lv2_return_val;

END isSale;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  GetInvoiceNo
-- Description    :  Create and return acorrect invoice number.
--                   The invoice number will be according to document sequence configured on the document setup in use.
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
FUNCTION GetInvoiceNo(p_document_key              VARCHAR2,
                      p_daytime                   DATE,
                      p_document_date             DATE,
                      p_status_code               VARCHAR2,
                      p_owner_company_id          VARCHAR2,
                      p_doc_seq_final_id          VARCHAR2,
                      p_doc_seq_accrual_id        VARCHAR2,
                      p_doc_number_format_final   VARCHAR2,
                      p_doc_number_format_accrual VARCHAR2,
                      p_financial_code            VARCHAR2,
                      p_test                      VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2
--</EC-DOC>
IS

  lv2_inv_string VARCHAR2(2000);
  lv2_neq_seq VARCHAR2(200) := NULL;
  lv2_seq VARCHAR2(200) := NULL;
  lv2_country_id geographical_area.object_id%TYPE;
  lv2_country_code VARCHAR2(200) := NULL;
  lv2_doc_seq_code VARCHAR2(200) := NULL;
  ln_doc_seq_digits NUMBER;
  ld_booking_period DATE;

BEGIN

   IF (p_test IS NULL) THEN
      --ToDo:
      --lv2_inv_string := ec_contract_doc_version.invoice_number(p_contract_doc_object_id, p_daytime, '<=');
      IF (p_status_code = 'FINAL') THEN
         lv2_inv_string := p_doc_number_format_final;
      ELSIF (p_status_code = 'ACCRUAL') THEN
         lv2_inv_string := p_doc_number_format_accrual;
      END IF;
   ELSE
      lv2_inv_string := p_test;
   END IF;

   IF (lv2_inv_string IS NULL) THEN
      RETURN NULL;
   END IF;


   IF (INSTR(lv2_inv_string, '$USEREXIT') > 0 ) THEN
      lv2_inv_string := ue_cont_document.getinvoiceno(p_document_key,
                                                      p_daytime,
                                                      p_document_date,
                                                      p_status_code,
                                                      p_owner_company_id,
                                                      p_doc_seq_final_id,
                                                      p_doc_seq_accrual_id,
                                                      p_doc_number_format_final,
                                                      p_doc_number_format_accrual,
                                                      p_financial_code);
   END IF;





   -- Check on $MANUAL in invoice number
   IF (INSTR(lv2_inv_string, '$MANUAL') > 0 ) THEN
       IF (lv2_inv_string <> '$MANUAL') THEN
           Raise_Application_Error(-20000,'When using the $MANUAL invoice number can you not have additional info the invoice number setup.');
       END IF;
       -- Returns the KEY so the trigger can handle it properly
       RETURN '$MANUAL';

   END IF;



   /***********************
10/01/TEST/$DOC_SEQ_NOP$DDD

10/01/TEST/00001P09

$DOC_SEQ_NO

$COUNTRY_CODE

$DDD - Document Date DAY
$DMM - Document Date MTH
$DYY - Document Date Year
$DYYYY - Document Date Year

$SDD - System Date DAY
$SMM - System Date MTH
$SYY - System Date Year
$SYYYY - System Date Year

   ************************/

   IF (INSTR(lv2_inv_string, '$DOC_SEQ_NO') > 0 ) THEN
      IF (p_status_code = 'FINAL') THEN
         --:ToDo Kheng
         lv2_doc_seq_code := ec_doc_sequence.object_code(p_doc_seq_final_id);
         ln_doc_seq_digits := ec_doc_sequence_version.digits(p_doc_seq_final_id,p_daytime,'<=');
         Ecdp_System_Key.assignNextNumber(lv2_doc_seq_code, lv2_neq_seq, FALSE);

         lv2_seq := lv2_neq_seq;
      ELSIF (p_status_code = 'ACCRUAL') THEN
         --:ToDo Kheng
         lv2_doc_seq_code := ec_doc_sequence.object_code(p_doc_seq_accrual_id);
         ln_doc_seq_digits := ec_doc_sequence_version.digits(p_doc_seq_accrual_id,p_daytime,'<=');
         Ecdp_System_Key.assignNextNumber(lv2_doc_seq_code, lv2_neq_seq, FALSE);

         lv2_seq := lv2_neq_seq;
      END IF;

      -- Preparing padding of sequence based on configuration on the doc sequence object
      IF (ln_doc_seq_digits IS NOT NULL AND lv2_seq IS NOT NULL) THEN

         IF (ln_doc_seq_digits > 0) THEN

            FOR i IN length(lv2_seq)..ln_doc_seq_digits-1 LOOP
                lv2_seq := 0||lv2_seq;
            END LOOP;

         END IF;

      END IF;

      lv2_inv_string := REPLACE(lv2_inv_string, '$DOC_SEQ_NO', lv2_seq);
   END IF;

   lv2_country_id := ec_company_version.country_id(p_owner_company_id, p_daytime, '<=');
   lv2_country_code := ec_geographical_area.object_code(lv2_country_id);
   ld_booking_period := EcDp_Fin_Period.getCurrentOpenPeriod(lv2_country_id, p_owner_company_id, p_financial_code,'BOOKING',p_document_key,p_document_date);

   lv2_inv_string := REPLACE(lv2_inv_string, '$COUNTRY_CODE', lv2_country_code);

   lv2_inv_string := REPLACE(lv2_inv_string, '$DDD', to_char(p_document_date,'DD'));
   lv2_inv_string := REPLACE(lv2_inv_string, '$DMM', to_char(p_document_date,'MM'));
   lv2_inv_string := REPLACE(lv2_inv_string, '$DYYYY', to_char(p_document_date,'YYYY'));
   lv2_inv_string := REPLACE(lv2_inv_string, '$DYY', to_char(p_document_date,'YY'));

   lv2_inv_string := REPLACE(lv2_inv_string, '$SDD', to_char(Ecdp_Timestamp.getCurrentSysdate,'DD'));
   lv2_inv_string := REPLACE(lv2_inv_string, '$SMM', to_char(Ecdp_Timestamp.getCurrentSysdate,'MM'));
   lv2_inv_string := REPLACE(lv2_inv_string, '$SYYYY', to_char(Ecdp_Timestamp.getCurrentSysdate,'YYYY'));
   lv2_inv_string := REPLACE(lv2_inv_string, '$SYY', to_char(Ecdp_Timestamp.getCurrentSysdate,'YY'));

   lv2_inv_string := REPLACE(lv2_inv_string, '$BMM', to_char(ld_booking_period,'MM'));
   lv2_inv_string := REPLACE(lv2_inv_string, '$BYYYY', to_char(ld_booking_period,'YYYY'));
   lv2_inv_string := REPLACE(lv2_inv_string, '$BYY', to_char(ld_booking_period,'YY'));

   RETURN lv2_inv_string;

END GetInvoiceNo;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  DelDocument
-- Description    : Deletes the document and all its child objects
--
-- Preconditions  : Document Level Code is OPEN
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
PROCEDURE DelDocument(
   p_object_id VARCHAR2,
   p_document_id VARCHAR2
   )
--</EC-DOC>
IS

not_open EXCEPTION;
invoice_no_not_null EXCEPTION;
datasetError  EXCEPTION;


lrec_doc cont_document%ROWTYPE := ec_cont_document.row_by_pk(p_document_id);

 lv_DataSetMessage VARCHAR2(4000);
BEGIN

    -- can we delete - only open documents can be deleted?
    IF lrec_doc.document_level_code != 'OPEN' THEN

       RAISE not_open;

    END IF;

    --check if system is allowed to delete a document with invoice number
    IF ec_ctrl_system_attribute.attribute_text(lrec_doc.daytime,'DEL_DOC_W_DOCNUM','<=') = 'N' THEN
      IF lrec_doc.document_number IS NOT NULL THEN

         RAISE invoice_no_not_null;

      END IF;
    END IF;

    -- Remove document reference in period interface table
    UPDATE ifac_sales_qty x
       SET x.transaction_key = NULL,
           x.trans_key_set_ind = 'N',
           x.last_updated_by = 'SYSTEM',
           x.document_key = NULL
     WHERE x.transaction_key IN
           (SELECT t.transaction_key
              FROM cont_transaction t
             WHERE t.document_key = p_document_id);


    -- Remove reference to preceding document if that document is being deleted.
    -- Upon processing the process query will try to find a new preceding doc candidate.
    -- If no candidate is found, processing will potentially fail, since the system may be
    -- trying to create a dependent document WITHOUT a preceding document.
    UPDATE ifac_sales_qty x
       SET x.preceding_doc_key = NULL,
           x.last_updated_by = 'SYSTEM'
     WHERE x.preceding_doc_key = p_document_id;


    -- Remove document reference in cargo interface table
    UPDATE ifac_cargo_value x
       SET x.transaction_key = NULL,
           x.trans_key_set_ind = 'N',
           x.last_updated_by = 'SYSTEM'
     WHERE x.transaction_key IN
           (SELECT t.transaction_key
              FROM cont_transaction t
               WHERE t.document_key = p_document_id);

    -- Remove reference to preceding document if that document is being deleted.
    -- Upon processing the process query will try to find a new preceding doc candidate.
    -- If no candidate is found, processing will potentially fail, since the system may be
    -- trying to create a dependent document WITHOUT a preceding document.
    UPDATE ifac_cargo_value x
       SET x.preceding_doc_key = NULL,
           x.last_updated_by = 'SYSTEM'
     WHERE x.preceding_doc_key = p_document_id;


    -- update of stim_mth_value is handled by EcDp_VoQty, called by iud_cont_transaction on delete.

    IF lrec_doc.preceding_document_key IS NOT NULL THEN

         -- remove possible reversal flags on preceding document
         UPDATE cont_document
            SET reversal_code        = NULL,
                reversal_date        = NULL,
                actual_reversal_date = NULL,
                last_updated_by      = 'SYSTEM'
          WHERE object_id = p_object_id
            AND document_key = lrec_doc.preceding_document_key
            AND (reversal_date IS NOT NULL OR
                actual_reversal_date IS NOT NULL);
     END IF;


    -- delete complete document
     DELETE FROM cont_line_item_dist_uom x
      WHERE object_id = p_object_id
        AND EXISTS (SELECT 'x'
               FROM cont_line_item_dist
              WHERE object_id = x.object_id
                AND line_item_key = x.line_item_key
                AND document_key = p_document_id);

     DELETE FROM cont_line_item_dist
      WHERE object_id = p_object_id
        AND document_key = p_document_id;

     DELETE FROM cont_line_item_uom x
      WHERE object_id = p_object_id
        AND EXISTS (SELECT 'x'
               FROM cont_line_item
              WHERE object_id = x.object_id
                AND line_item_key = x.line_item_key
                AND document_key = p_document_id);

     DELETE FROM cont_line_item
      WHERE object_id = p_object_id
        AND document_key = p_document_id;

     DELETE FROM cont_trans_comments x
      WHERE object_id = p_object_id
        AND EXISTS (SELECT 'x'
               FROM cont_transaction
              WHERE object_id = x.object_id
                AND transaction_key = x.transaction_key
                AND document_key = p_document_id);

     DELETE FROM cont_transaction_qty_uom q
      WHERE (q.object_id, q.transaction_key) IN
            (SELECT object_id, transaction_key
               FROM cont_transaction
              WHERE object_id = p_object_id
                AND document_key = p_document_id);

     DELETE FROM cont_transaction_qty q
      WHERE (q.object_id, q.transaction_key) IN
            (SELECT object_id, transaction_key
               FROM cont_transaction
              WHERE object_id = p_object_id
                AND document_key = p_document_id);

     DELETE FROM cont_transaction
      WHERE object_id = p_object_id
        AND document_key = p_document_id;

     DELETE FROM cont_document_text_item
      WHERE object_id = p_object_id
        AND document_key = p_document_id;

     DELETE FROM cont_document_company
      WHERE object_id = p_object_id
        AND document_key = p_document_id;

     DELETE FROM cont_document_comment
      WHERE object_id = p_object_id
        AND document_key = p_document_id;

     DELETE FROM cont_postings
      WHERE object_id = p_object_id
        AND document_key = p_document_id;

    lv_DataSetMessage := Ecdp_Dataset_Flow.Delete('CONT_DOCUMENT',p_document_id,p_object_id);

     DELETE FROM cont_document
      WHERE object_id = p_object_id
        AND document_key = p_document_id;


    IF lv_DataSetMessage is not null then
       RAISE datasetError;
    END IF;

EXCEPTION

         WHEN not_open THEN

              Raise_Application_Error(-20000,'Cannot delete document unless it has level OPEN');

         WHEN invoice_no_not_null THEN

              Raise_Application_Error(-20000,'Not allowed to delete a document where the Document Number has been set.');

         WHEN datasetError THEN
           Raise_Application_Error(-20000,lv_DataSetMessage);

END DelDocument;

FUNCTION ConvertAmountToWords (p_amount NUMBER,
                               p_currency_code VARCHAR2,
                               p_daytime DATE)
RETURN VARCHAR2

IS

ln_int NUMBER;
ln_decimals NUMBER;

ln_amount NUMBER;

lv2_retval cont_document.amount_in_words%TYPE;

lv2_intinwords VARCHAR2(2000);
lv2_decimalsinwords VARCHAR2(2000);

lv2_curr_name VARCHAR2(240) := ec_currency_version.name(ec_currency.object_id_by_uk(p_currency_code), p_daytime, '<=');
lv2_curr_unit100 VARCHAR2(32) := ec_currency_version.unit100(ec_currency.object_id_by_uk(p_currency_code), p_daytime, '<=');

BEGIN

     ln_amount := abs(p_amount);

     -- 1: Find int and decimals
     ln_int := floor(ln_amount);
     ln_decimals := (ln_amount - ln_int) * 100; -- to make int

     -- 2: Convert each of them to words
     lv2_intinwords := int2words(ln_int);

     IF ln_decimals > 0 THEN

        lv2_decimalsinwords := int2words(ln_decimals);

     END IF;

     -- 3: Concatinate with currency

     -- Checks if plural
     IF ln_int > 1 THEN

        lv2_curr_name := lv2_curr_name || 's';

     END IF;

     IF ln_int > 0 THEN

        lv2_retval := lv2_intinwords || ' ' || lv2_curr_name;

     END IF;

     IF ln_decimals > 0 THEN

        -- Special handling for GBP
        IF p_currency_code = 'GBP' and ln_decimals = 1 THEN

           lv2_curr_unit100 := 'Penny';

        END IF;

        IF ln_decimals > 1 THEN

          IF p_currency_code <> 'GBP' THEN

              lv2_curr_unit100 := lv2_curr_unit100 || 's';

           END IF;

        END IF;

        IF ln_int > 0 THEN

           lv2_retval := lv2_retval || ' and ';

        END IF;

        lv2_retval := lv2_retval || lv2_decimalsinwords || ' ' || lv2_curr_unit100;

     END IF;

     IF ln_int = 0 AND ln_decimals = 0 THEN

        lv2_retval := 'Zero ' || lv2_curr_name || 's';

     END IF;

     lv2_retval := lv2_retval || ' Only';

     RETURN lv2_retval;

END ConvertAmountToWords;

FUNCTION int2words (number_in NUMBER)

RETURN VARCHAR2

   IS

      my_number NUMBER;
      remainder NUMBER;

   BEGIN

      --
      -- Should already be an integer, but just in case!
      --
      my_number := FLOOR (number_in);
      --
      -- Return NULL if zero or negative
      --
      IF my_number <= 0 THEN
         RETURN NULL;
      END IF;

      --
      -- Break down the passed number into its component parts, making recursive calls
      -- to int2words as required.
      --

      /* 1,000,000,000+ */

      IF my_number >= 1000000000 THEN
         -- Break up into two recursive calls to int2words.
         remainder := MOD (my_number, 1000000000);
         IF remainder = 0 THEN
            RETURN int2words (my_number/1000000000) || ' Billion';
         ELSIF remainder BETWEEN 1 AND 99 THEN
            RETURN int2words (my_number/1000000000)||' Billion '||
                   int2words (remainder);
         ELSE
            RETURN int2words (my_number/1000000000)||' Billion '||
                   int2words (remainder);
         END IF;
      END IF;

      /* 1,000,000-999,999,999 */

      IF my_number >= 1000000 THEN
         -- Break up into two recursive calls to int2words.
         remainder := MOD (my_number, 1000000);
         IF remainder = 0 THEN
            RETURN int2words (my_number/1000000) || ' Million';
         ELSIF remainder BETWEEN 1 AND 99 THEN
            RETURN int2words (my_number/1000000)||' Million '||
                   int2words (remainder);
         ELSE
            RETURN int2words (my_number/1000000)||' Million '||
                   int2words (remainder);
         END IF;
      END IF;

      /* 1,000-9,999 */

      IF my_number >= 1000 THEN
         -- Break up into two recursive calls to int2words.
         remainder := MOD (my_number, 1000);
         IF remainder = 0 THEN
            RETURN int2words (my_number/1000) || ' Thousand';
         ELSIF remainder BETWEEN 1 AND 99 THEN
            RETURN int2words (my_number/1000)||' Thousand '||
                   int2words (remainder);
         ELSE
            RETURN int2words (my_number/1000)||' Thousand '||
                   int2words (remainder);
         END IF;
      END IF;

      /* 100-999 */

      IF my_number >= 100 THEN
         -- Break up into two recursive calls to num2words.
         remainder := MOD (my_number, 100);
         IF remainder BETWEEN 1 AND 99 THEN
            RETURN int2words (my_number/100)||' Hundred '||
                   int2words (remainder);
         ELSE
            RETURN int2words (my_number/100) || ' Hundred';
         END IF;
      END IF;

      /* 1-99 (devious use of TO_DATE coming up!)*/

    RETURN TO_CHAR(TO_DATE(TO_CHAR(my_number),'YYYY'),'Year');

END int2words;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  UpdTransactionRate
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
PROCEDURE UpdTransExRateFromDoc
 (p_object_id VARCHAR2,
  p_trans_id VARCHAR2,
  p_daytime DATE,
  p_user VARCHAR2,
  p_doc_id VARCHAR2
  )
--</EC-DOC>
IS

--Collecting currency from Document
lv2_doc_booking_curr VARCHAR2(32) := ec_cont_document.booking_currency_code(p_doc_id);
lv2_doc_local_curr VARCHAR2(32) := EcDp_Contract_Setup.GetLocalCurrencyCode(p_object_id , p_daytime );
lv2_doc_group_curr VARCHAR2(32) := ec_ctrl_system_attribute.attribute_text(p_daytime, 'GROUP_CURRENCY_CODE', '<=');

--Collecting transaction currency
lv2_trans_booking_curr VARCHAR2(32) := ec_cont_document.booking_currency_code(ec_cont_transaction.document_key(p_trans_id) );
lv2_trans_memo_curr VARCHAR2(32) := ec_cont_document.memo_currency_code(ec_cont_transaction.document_key(p_trans_id) );
lv2_trans_pricing_curr VARCHAR2(32) := ec_cont_transaction.pricing_currency_code(p_trans_id);

lrec_cont_document cont_document%ROWTYPE := Ec_Cont_Document.row_by_pk(p_doc_id);
lrec_cont_transaction cont_transaction%ROWTYPE := Ec_Cont_Transaction.row_by_pk(p_trans_id);

ln_ex_pricing_booking NUMBER := 0;
ln_ex_pricing_memo NUMBER := 0;

lv2_change_booking VARCHAR2(1) := 'N';
lv2_change_memo VARCHAR2(1) := 'N';


BEGIN

     -- Exit if reallocation. Should use preceding document ex rates.
     IF lrec_cont_document.document_concept = 'REALLOCATION' THEN
        RETURN;
     END IF;


     -- Checking if document and transaction have same currency and get correct from document

     --Checking if Price/Booking should be changed
     IF (lv2_trans_pricing_curr = lv2_doc_booking_curr AND  lv2_trans_booking_curr = lv2_doc_local_curr) THEN
     	ln_ex_pricing_booking := lrec_cont_transaction.ex_booking_local;
     	lv2_change_booking := 'Y';

     ELSIF (lv2_trans_pricing_curr = lv2_doc_local_curr AND  lv2_trans_booking_curr = lv2_doc_booking_curr) THEN
        ln_ex_pricing_booking := lrec_cont_transaction.ex_inv_booking_local;
     	lv2_change_booking := 'Y';

     ELSIF (lv2_trans_pricing_curr = lv2_doc_booking_curr AND  lv2_trans_booking_curr = lv2_doc_group_curr) THEN
     	ln_ex_pricing_booking := lrec_cont_transaction.ex_booking_group;
     	lv2_change_booking := 'Y';

     ELSIF (lv2_trans_pricing_curr = lv2_doc_group_curr AND  lv2_trans_booking_curr = lv2_doc_booking_curr) THEN
        ln_ex_pricing_booking := lrec_cont_transaction.ex_inv_booking_group;
     	lv2_change_booking := 'Y';
     ELSE
     	lv2_change_booking := 'N';
     END IF;

        --Checking if Price/Memo should be changed
     IF (lv2_trans_pricing_curr = lv2_doc_booking_curr AND  Nvl(lv2_trans_memo_curr,'xxx') = lv2_doc_local_curr) THEN
     	ln_ex_pricing_memo := lrec_cont_transaction.ex_booking_local;
     	lv2_change_memo := 'Y';

     ELSIF (lv2_trans_pricing_curr = lv2_doc_local_curr AND Nvl(lv2_trans_memo_curr,'xxx') = lv2_doc_booking_curr) THEN
        ln_ex_pricing_memo := lrec_cont_transaction.ex_inv_booking_local;
     	lv2_change_memo := 'Y';

     ELSIF (lv2_trans_pricing_curr = lv2_doc_booking_curr AND  Nvl(lv2_trans_memo_curr,'xxx') = lv2_doc_group_curr) THEN
     	ln_ex_pricing_memo := lrec_cont_transaction.ex_booking_group;
     	lv2_change_memo := 'Y';

     ELSIF (lv2_trans_pricing_curr = lv2_doc_group_curr AND  Nvl(lv2_trans_memo_curr,'xxx')= lv2_doc_booking_curr) THEN
        ln_ex_pricing_memo := lrec_cont_transaction.ex_inv_booking_group;
     	lv2_change_memo := 'Y';
     ELSE
     	lv2_change_memo := 'N';
     END IF;

     -- If there have been a match in currency then change the transaction currency
     -- Change both
     IF (lv2_change_booking = 'Y' AND lv2_change_memo = 'Y') THEN

     	UPDATE cont_transaction
     	SET    ex_pricing_booking = ln_ex_pricing_booking
     	       ,ex_pricing_memo = ln_ex_pricing_memo
     	       ,last_updated_by = p_user
     	WHERE  object_id = p_object_id
     	AND    transaction_key = p_trans_id;

     	-- force recalculation of curr change
     	UPDATE cont_line_item
     	SET    rev_text = 'Recalculation due to new exchange rates'
     	       ,last_updated_by = p_user
     	WHERE  object_id = p_object_id
     	AND    transaction_key = p_trans_id;



      -- Only change booking currency
      ELSIF (lv2_change_booking = 'Y' AND lv2_change_memo = 'N') THEN

        UPDATE cont_transaction
     	SET    ex_pricing_booking = ln_ex_pricing_booking
     	       ,last_updated_by = p_user
     	WHERE  object_id = p_object_id
     	AND    transaction_key = p_trans_id;

     	-- force recalculation of curr change
     	UPDATE cont_line_item
     	SET    rev_text = 'Recalculation due to new exchange rates'
     	       ,last_updated_by = p_user
     	WHERE  object_id = p_object_id
     	AND    transaction_key = p_trans_id;

      -- Only change other currency
      ELSIF (lv2_change_booking = 'N' AND lv2_change_memo = 'Y') THEN

        UPDATE cont_transaction
     	SET    ex_pricing_memo = ln_ex_pricing_memo
     	       ,last_updated_by = p_user
     	WHERE  object_id = p_object_id
     	AND    transaction_key = p_trans_id;

     	-- force recalculation of curr change
     	UPDATE cont_line_item
     	SET    rev_text = 'Recalculation due to new exchange rates'
     	       ,last_updated_by = p_user
     	WHERE  object_id = p_object_id
     	AND    transaction_key = p_trans_id;


     END IF;

END UpdTransExRateFromDoc;

FUNCTION GetDocumentListBankInfo(
    p_object_id  VARCHAR2,
    p_doc_id VARCHAR2
   )

RETURN VARCHAR2

IS

CURSOR c_vendor IS
SELECT cdc.*
FROM cont_document_company cdc, company c
WHERE cdc.object_id = p_object_id
  AND cdc.document_key = p_doc_id
  AND cdc.company_id = c.object_id
  AND c.class_name = 'VENDOR';

CURSOR c_customer IS
SELECT cdc.*
FROM cont_document_company cdc, company c
WHERE cdc.object_id = p_object_id
  AND cdc.document_key = p_doc_id
  AND cdc.company_id = c.object_id
  AND c.class_name = 'CUSTOMER';

lv2_return_val VARCHAR2(2000);
ln_pricing_value NUMBER;
lv2_financial_code cont_document.financial_code%TYPE;

BEGIN

    lv2_financial_code := ec_cont_document.financial_code(p_doc_id);
    ln_pricing_value := ecdp_transaction.GetSumTransPricingTotal(p_doc_id);

    IF (lv2_financial_code IN ('SALE','TA_INCOME','JOU_ENT') AND ln_pricing_value >= 0) OR
       (lv2_financial_code IN ('PURCHASE','TA_COST') AND ln_pricing_value < 0) THEN

        FOR VendCur IN c_vendor LOOP
            IF lv2_return_val IS NULL THEN
                lv2_return_val := VendCur.bank_info;
            ELSE
                lv2_return_val := lv2_return_val || ', ' || VendCur.bank_info;
            END IF;
        END LOOP;

    ELSE -- ie sale/tariff-income with negative amount or purchase/tariff-cost with positive amount

        FOR CustCur IN c_customer LOOP
            IF lv2_return_val IS NULL THEN
                lv2_return_val := CustCur.bank_info;
            ELSE
                lv2_return_val := lv2_return_val || ', ' || CustCur.bank_info;
            END IF;
        END LOOP;


    END IF;

    RETURN lv2_return_val;

END GetDocumentListBankInfo;

-----------------------------------------------------------------------------------------------------------------------------
-- Makes it possible to run GenReverseDocument without the IN OUT log parameter.
-- Specifically made for reversing from Document General button, but may also be used elsewhere.
-- Header should always be aligned with the header of GenReverseDocument implementation, except for the IN OUT parameter.
FUNCTION GenReverseDocument(p_object_id       VARCHAR2,
                            p_reverse_doc_key VARCHAR2,
                            p_user            VARCHAR2,
                            p_force_reversal  VARCHAR2 DEFAULT 'N',
                            p_new_rev_doc_key VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
IS
  ln_log_item_no NUMBER;
  lv2_ret_val cont_document.document_key%TYPE;
  l_logger t_revn_logger;
BEGIN
    l_logger := t_revn_logger('REVERSE_DG');
    l_logger.init;
    l_logger.update_overall_state('Manual reversal of document ' || p_reverse_doc_key, ecdp_revn_log.LOG_STATUS_RUNNING);
    ln_log_item_no := l_logger.log_no;

    lv2_ret_val := GenReverseDocument(p_object_id,
                                    p_reverse_doc_key,
                                    ln_log_item_no,
                                    p_user,
                                    p_force_reversal,
                                    p_new_rev_doc_key);

  RETURN lv2_ret_val;

END GenReverseDocument;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION GenReverseDocument(p_object_id       VARCHAR2,
                            p_reverse_doc_key VARCHAR2,
                            p_log_item_no     IN OUT NUMBER,
                            p_user            VARCHAR2,
                            p_force_reversal  VARCHAR2 DEFAULT 'N',
                            p_new_rev_doc_key VARCHAR2 DEFAULT NULL)

RETURN VARCHAR2
IS

  CURSOR c_trans(cp_doc_id VARCHAR2) IS
  SELECT t.*
    FROM cont_transaction t
   WHERE t.document_key = cp_doc_id
     AND (nvl(t.reversal_ind, 'N') <> 'Y' OR p_force_reversal = 'Y');

  CURSOR c_act_rev_date IS
  SELECT actual_reversal_date
    FROM cont_document
   WHERE object_id = p_object_id
     AND document_key = p_reverse_doc_key;

  CURSOR c_dep_docs IS
  SELECT *
    FROM cont_document
   WHERE object_id = p_object_id
     AND preceding_document_key = p_reverse_doc_key
     AND document_concept <> 'DEPENDENT_WITHOUT_REVERSAL';

  no_processable_code EXCEPTION;
  no_reversal EXCEPTION;
  already_reversed EXCEPTION;
  dependents_exist EXCEPTION;

  lv2_document_key VARCHAR2(32);
  lv2_new_trans_id VARCHAR2(32);
  lv2_trans_id VARCHAR2(32);
  ld_actual_rev_date DATE;
  lv2_tmp_var VARCHAR2(32);
  ln_trans_count NUMBER := 0;
  ld_sysdate DATE := Ecdp_Timestamp.getCurrentSysdate;
  lr_rev_doc cont_document%ROWTYPE := ec_cont_document.row_by_pk(p_reverse_doc_key);
  ld_daytime DATE;
  ld_processing_period DATE;
  l_logger t_revn_logger;

BEGIN
    l_logger := t_revn_logger(p_log_item_no);
    l_logger.set_log_item_data(p_log_item_text_3 => p_object_id);
    l_logger.update_overall_state(NULL, ecdp_revn_log.LOG_STATUS_RUNNING);

    -- check against processable code
    IF ec_contract_version.processable_code(p_object_id, ld_sysdate, '<=') = 'N' THEN
        RAISE no_processable_code;
    END IF;

    IF lr_rev_doc.reversal_ind = 'Y' THEN
        RAISE already_reversed;
    END IF;

    FOR ActRev IN c_act_rev_date LOOP

        ld_actual_rev_date := ActRev.actual_reversal_date;

    END LOOP;

    -- cannot reverse a reversed document
    IF ld_actual_rev_date IS NOT NULL THEN
        RAISE already_reversed;
    END IF;

    IF p_force_reversal = 'N' THEN -- Only check for other preceding docs when not forcing the reversal (like when running scheduled reversal of accruals)
      IF HasReversedDependentDoc(p_reverse_doc_key) = 'N' THEN

          FOR DepDocs IN c_dep_docs LOOP

              RAISE dependents_exist;

          END LOOP;

      END IF;
    END IF;

    -- flag previous document
    UPDATE cont_document SET
       actual_reversal_date = ld_sysdate,
       last_updated_by = p_user
     WHERE document_key = p_reverse_doc_key;

    -- insert document, pick id from sequence
    IF p_new_rev_doc_key IS NOT NULL THEN
      lv2_document_key := p_new_rev_doc_key;
    ELSE
      lv2_document_key := EcDp_Document.GetNextDocumentKey(p_object_id, ld_sysdate);
    END IF;

    l_logger.info('The document ' || lv2_document_key  || ' will be used to reverse ' || p_reverse_doc_key || '.');

    ld_daytime := ec_cont_document.daytime(p_reverse_doc_key);

    IF ue_cont_document.isReversedProcPeriodUEEnabled = 'TRUE' THEN
      ld_processing_period := ue_cont_document.GetRevProcPeriod(p_object_id,
                                                                p_reverse_doc_key,
                                                                ld_daytime);

    ELSE
      ld_processing_period := EcDp_Fin_Period.GetCurrOpenPeriodByObject(
                                    p_object_id,
                                    ld_daytime,
                                    ec_contract_version.financial_code(p_object_id,
                                                  ld_daytime));
	   END IF;

   INSERT INTO CONT_DOCUMENT
     (OBJECT_ID,
      CONTRACT_DOC_ID,
      DOCUMENT_KEY,
      DAYTIME,
      PROCESSING_PERIOD,
      DOCUMENT_DATE,
      PRECEDING_DOCUMENT_KEY,
      PARENT_DOCUMENT_KEY,
      OPEN_USER_ID,
      DOC_TEMPLATE_NAME,
      INV_DOC_TEMPLATE_NAME,
      DOC_TEMPLATE_ID,
      INV_DOC_TEMPLATE_ID,
      CUR_DOC_TEMPLATE_NAME,
      doc_date_calendar_coll_id,
      doc_rec_calendar_coll_id,
      payment_calendar_coll_id,
      BOOK_DOCUMENT_IND,
      COMMENTS,
      DOCUMENT_LEVEL_CODE,
      STATUS_CODE,
      REFERENCE,
      CONTRACT_REFERENCE,
      OUR_CONTACT,
      OUR_CONTACT_PHONE,
      YOUR_CONTACT,
      AMOUNT_IN_WORDS_IND,
      AMOUNT_IN_WORDS,
      OWNER_COMPANY_ID,
      BOOKING_CURRENCY_CODE,
      BOOKING_CURRENCY_ID,
      MEMO_CURRENCY_CODE,
      MEMO_CURRENCY_ID,
      PRICE_BASIS,
      CONTRACT_GROUP_CODE,
      DOC_SCOPE,
      USE_CURRENCY_100_IND,
      DOCUMENT_TYPE,
      CONTRACT_NAME,
      doc_received_base_code,
      doc_received_base_date,
      document_received_date,
      payment_term_base_code,
      payment_due_base_date,
      pay_date,
      DOC_DATE_TERM_ID,
      DOC_RECEIVED_TERM_ID,
      PAY_TERM_DAYS,
      PAYMENT_TERM_NAME,
      PAYMENT_TERM_ID,
      FINANCIAL_CODE,
      SEND_UNIT_PRICE_IND,
      TAXABLE_IND,
      BANK_DETAILS_LEVEL_CODE,
      DOCUMENT_CONCEPT,
      REVERSAL_IND,
      DOC_SEQUENCE_ACCRUAL_ID, --new doc seq attributes
      DOC_SEQUENCE_FINAL_ID,
      DOC_NUMBER_FORMAT_ACCRUAL,
      DOC_NUMBER_FORMAT_FINAL,
      CONTRACT_TERM_CODE,
      CONTRACT_AREA_CODE,
      VALUE_1,
      VALUE_2,
      VALUE_3,
      VALUE_4,
      VALUE_5,
      VALUE_6,
      VALUE_7,
      VALUE_8,
      VALUE_9,
      VALUE_10,
      TEXT_1,
      TEXT_2,
      TEXT_3,
      TEXT_4,
      TEXT_5,
      TEXT_6,
      TEXT_7,
      TEXT_8,
      TEXT_9,
      TEXT_10,
      DATE_1,
      DATE_2,
      DATE_3,
      DATE_4,
      DATE_5,
      DATE_6,
      DATE_7,
      DATE_8,
      DATE_9,
      DATE_10,
      REF_OBJECT_ID_1,
      REF_OBJECT_ID_2,
      REF_OBJECT_ID_3,
      REF_OBJECT_ID_4,
      REF_OBJECT_ID_5,
      CREATED_BY)
     SELECT OBJECT_ID,
            CONTRACT_DOC_ID,
            lv2_document_key, -- set to new doc id
            DAYTIME, -- Use the same version date as the preceding
            ld_processing_period ,
            TRUNC(Ecdp_Timestamp.getCurrentSysdate, 'DD'), -- Doc Date is the actual reversal date
            p_reverse_doc_key, -- make this the preceding doc
            NULL,
            p_user,
            DOC_TEMPLATE_NAME,
            INV_DOC_TEMPLATE_NAME,
            DOC_TEMPLATE_ID,
            INV_DOC_TEMPLATE_ID,
            CUR_DOC_TEMPLATE_NAME,
            doc_date_calendar_coll_id,
            doc_rec_calendar_coll_id,
            payment_calendar_coll_id,
            BOOK_DOCUMENT_IND,
            COMMENTS,
            'OPEN', -- set document level to open initially
            STATUS_CODE,
            REFERENCE,
            CONTRACT_REFERENCE,
            OUR_CONTACT,
            OUR_CONTACT_PHONE,
            YOUR_CONTACT,
            AMOUNT_IN_WORDS_IND,
            AMOUNT_IN_WORDS,
            OWNER_COMPANY_ID,
            BOOKING_CURRENCY_CODE,
            BOOKING_CURRENCY_ID,
            MEMO_CURRENCY_CODE,
            MEMO_CURRENCY_ID,
            PRICE_BASIS,
            CONTRACT_GROUP_CODE,
            DOC_SCOPE,
            USE_CURRENCY_100_IND,
            DOCUMENT_TYPE,
            CONTRACT_NAME,
            doc_received_base_code,
            doc_received_base_date,
            document_received_date,
            payment_term_base_code,
            payment_due_base_date,
            pay_date,
            DOC_DATE_TERM_ID,
            DOC_RECEIVED_TERM_ID,
            PAY_TERM_DAYS,
            PAYMENT_TERM_NAME,
            PAYMENT_TERM_ID,
            FINANCIAL_CODE,
            SEND_UNIT_PRICE_IND,
            TAXABLE_IND,
            BANK_DETAILS_LEVEL_CODE,
            DOCUMENT_CONCEPT,
            'Y',
            DOC_SEQUENCE_ACCRUAL_ID, --new doc seq attributes
            DOC_SEQUENCE_FINAL_ID,
            DOC_NUMBER_FORMAT_ACCRUAL,
            DOC_NUMBER_FORMAT_FINAL,
            CONTRACT_TERM_CODE,
            CONTRACT_AREA_CODE,
            VALUE_1,
            VALUE_2,
            VALUE_3,
            VALUE_4,
            VALUE_5,
            VALUE_6,
            VALUE_7,
            VALUE_8,
            VALUE_9,
            VALUE_10,
            TEXT_1,
            TEXT_2,
            TEXT_3,
            TEXT_4,
            TEXT_5,
            TEXT_6,
            TEXT_7,
            TEXT_8,
            TEXT_9,
            TEXT_10,
            DATE_1,
            DATE_2,
            DATE_3,
            DATE_4,
            DATE_5,
            DATE_6,
            DATE_7,
            DATE_8,
            DATE_9,
            DATE_10,
            REF_OBJECT_ID_1,
            REF_OBJECT_ID_2,
            REF_OBJECT_ID_3,
            REF_OBJECT_ID_4,
            REF_OBJECT_ID_5,
            p_user
       FROM cont_document
      WHERE document_key = p_reverse_doc_key
        AND document_level_code = 'BOOKED'; -- only apply for booked documents

    IF SQL%FOUND THEN
    -- only if successful document insert


        INSERT INTO cont_document_text_item
          (OBJECT_ID,
           DOCUMENT_KEY,
           TEXT_ITEM_ID,
           COLUMN_1,
           COLUMN_2,
           COLUMN_3,
           DESCRIPTION,
           COMMENTS,
           SORT_ORDER,
           TEXT_ITEM_TYPE,
           TEXT_ITEM_COLUMN_TYPE,
           created_by)
          SELECT OBJECT_ID,
                 lv2_document_key, -- set to new doc id
                 TEXT_ITEM_ID,
                 COLUMN_1,
                 COLUMN_2,
                 COLUMN_3,
                 DESCRIPTION,
                 COMMENTS,
                 SORT_ORDER,
                 TEXT_ITEM_TYPE,
                 TEXT_ITEM_COLUMN_TYPE,
                 p_user
            FROM cont_document_text_item
           WHERE object_id = p_object_id
             AND document_key = p_reverse_doc_key;

        INSERT INTO cont_document_company
          (OBJECT_ID,
           DOCUMENT_KEY,
           COMPANY_ID,
           BANK_INFO,
           BANK_ACCOUNT_INFO,
           BANK_ACCOUNT_ID,
           AMOUNT,
           VAT_REG_NO,
           COUNTRY_ID,
           COUNTRY_CODE,
           VALUE_1,
           VALUE_2,
           VALUE_3,
           VALUE_4,
           VALUE_5,
           VALUE_6,
           VALUE_7,
           VALUE_8,
           VALUE_9,
           VALUE_10,
           TEXT_1,
           TEXT_2,
           TEXT_3,
           TEXT_4,
           DATE_1,
           DATE_2,
           DATE_3,
           DATE_4,
           DATE_5,
           EXVAT_RECEIVER_ID,
           VAT_RECEIVER_ID,
           PAYMENT_SCHEME_ID,
           COMPANY_CATEGORY_CODE,
           COMPANY_ROLE,
           PAYMENT_TERM_BASE_CODE,
           PAYMENT_TERM_ID,
           PAYMENT_CALENDAR_COLL_ID,
           PAY_TERM_DAYS,
           SPLIT_SHARE,
           CREATED_BY)
          SELECT object_id,
                 lv2_document_key, -- set to new doc id
                 COMPANY_ID,
                 BANK_INFO,
                 BANK_ACCOUNT_INFO,
                 BANK_ACCOUNT_ID,
                 AMOUNT,
                 VAT_REG_NO,
                 COUNTRY_ID,
                 COUNTRY_CODE,
                 VALUE_1,
                 VALUE_2,
                 VALUE_3,
                 VALUE_4,
                 VALUE_5,
                 VALUE_6,
                 VALUE_7,
                 VALUE_8,
                 VALUE_9,
                 VALUE_10,
                 TEXT_1,
                 TEXT_2,
                 TEXT_3,
                 TEXT_4,
                 DATE_1,
                 DATE_2,
                 DATE_3,
                 DATE_4,
                 DATE_5,
                 EXVAT_RECEIVER_ID,
                 VAT_RECEIVER_ID,
                 PAYMENT_SCHEME_ID,
                 COMPANY_CATEGORY_CODE,
                 COMPANY_ROLE,
                 PAYMENT_TERM_BASE_CODE,
                 PAYMENT_TERM_ID,
                 PAYMENT_CALENDAR_COLL_ID,
                 PAY_TERM_DAYS,
                 SPLIT_SHARE,
                 p_user
            FROM cont_document_company
           WHERE object_id = p_object_id
             AND document_key = p_reverse_doc_key;


        -- take all transactions
        FOR TransCur IN c_trans(p_reverse_doc_key) LOOP

            -- Find any transaction that already have reversed this one.
            lv2_tmp_var := ecdp_transaction.getDependentTransaction(TransCur.Transaction_Key);

            IF  lv2_tmp_var is NOT NULL THEN

                l_logger.warning(TransCur.Transaction_Key|| ' is excluded from reversal because it is preceding for ['||ec_cont_transaction.document_key(lv2_tmp_var)||' / '||lv2_tmp_var||']');
                l_logger.update_overall_state(NULL,ecdp_revn_log.LOG_STATUS_WARNING);

            ELSE

                -- copy any transactions, no qtys
                Ecdp_System_Key.assignNextNumber('CONT_TRANSACTION', lv2_new_trans_id);
                lv2_trans_id := 'TRANS:' || to_char(lv2_new_trans_id);

                -- Generate the revesal transaction
                lv2_trans_id := EcDp_Transaction.ReverseTransaction(p_object_id, ld_sysdate, lv2_document_key, TransCur.Transaction_Key, p_user, 'Reversal of: ', 'Y');

                ln_trans_count := ln_trans_count + 1;

            END IF;
        END LOOP;   -- End TransCur

        IF ln_trans_count = 0 THEN

           ecdp_document_gen.GenDocException(p_object_id, lv2_document_key, -20000, 'Reversal document for document ' || lv2_document_key || ' could not be created. No available preceding transactions found. All transactions may have been reversed already.', 'ERROR', 'Y', p_log_item_no);
           RETURN NULL;

        END IF;

        -- All transactions inserted, now set pay date
  	    ecdp_contract_setup.updateAllDocumentDates(p_object_id, lv2_document_key, ec_cont_document.daytime(lv2_document_key), ec_cont_document.document_date(lv2_document_key), p_user, 5);

        ecdp_document.updateDocumentCustomer(lv2_document_key, p_object_id, p_user, lr_rev_doc.customer_id, TRUE, TRUE);

    ELSE

        RAISE no_reversal;

    END IF; -- successful insert

    --Update Analysis field for the newly created reversal document
    ecdp_document_gen.SetDocumentRecActionCode(lv2_document_key);

    l_logger.info('The document ' || lv2_document_key || ' (' || lr_rev_doc.booking_currency_code || ' ' || trim(to_char(ec_cont_document.doc_booking_total(lv2_document_key),'999,999,999.99')) || ') is now reversing ' || p_reverse_doc_key || ' (' || lr_rev_doc.booking_currency_code || ' ' || trim(to_char(lr_rev_doc.doc_booking_total,'999,999,999.99')) || ').');

    -- Calling UserExit if enabled
    IF ue_cont_document.isGenReverseDocumentUEEnabled = 'TRUE' THEN
        ue_cont_document.GenReverseDocumentUE(lv2_document_key);
    END IF;

    IF ec_revn_log.status(p_log_item_no) NOT IN (ecdp_revn_log.LOG_STATUS_WARNING, ecdp_revn_log.LOG_STATUS_ERROR) THEN
        l_logger.update_overall_state(NULL,ecdp_revn_log.LOG_STATUS_SUCCESS);
    END IF;

    RETURN lv2_document_key;

EXCEPTION

        WHEN no_processable_code THEN

            ecdp_document_gen.GenDocException(p_object_id, lv2_document_key, -20000, 'The current contract is not configured for processing. Document ' || p_reverse_doc_key || ' can not be reversed.', 'ERROR', 'N', p_log_item_no, 'Y');
            RETURN NULL;

        WHEN no_reversal THEN

            ecdp_document_gen.GenDocException(p_object_id, lv2_document_key, -20000, 'Document cannot be reversed unless status is BOOKED for: ' || Nvl(ec_contract.object_code(p_object_id),' ') || ' - ' || Nvl(ec_contract_version.name(p_object_id,ld_sysdate,'<='),' '), 'ERROR', 'N', p_log_item_no, 'Y');
            RETURN NULL;

        WHEN already_reversed THEN

            ecdp_document_gen.GenDocException(p_object_id, lv2_document_key, -20000, 'Document cannot be reversed since it is already reversed for: ' || Nvl(ec_contract.object_code(p_object_id),' ') || ' - ' || Nvl(ec_contract_version.name(p_object_id,ld_sysdate,'<='),' '), 'ERROR', 'N', p_log_item_no, 'Y');
            RETURN NULL;

        WHEN dependents_exist THEN

            ecdp_document_gen.GenDocException(p_object_id, lv2_document_key, -20000, 'Document cannot be reversed because documents having this as preceding exist for: ' || Nvl(ec_contract.object_code(p_object_id),' ') || ' - ' || Nvl(ec_contract_version.name(p_object_id,ld_sysdate,'<='),' '), 'ERROR', 'N', p_log_item_no, 'Y');
            RETURN NULL;

END GenReverseDocument;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      : IsIfacUpdated
-- Description    : Finds out wether ifac records that fit this document has been subject to change.
--                  Function does not dinstinguish between quantity, prices or any other possible update.
--
--                  The parameter p_non_booked_accrual_found can be either 'Y' or 'N', it should be
--                  the value got from the function EcDp_Document_Gen_Util.HasNoUnReversedAccrualDoc,
--                  indicating if in the same processing period with same contract doc, there is any
--                  accrual documents that have no reversal doc or the reversal doc has not been booked.
--                  Provide the value if the result is already known before calling this function.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
FUNCTION IsIfacUpdated(p_document_key                 VARCHAR2, -- may be set to null if only transaction_key is set
                       p_transaction_key              VARCHAR2,
                       p_err_ind                      VARCHAR2, -- Override exception raise
                       p_contract_doc_id              VARCHAR2,
                       p_doc_level                    VARCHAR2,
                       p_ori_doc_status               VARCHAR2,
                       p_non_booked_accrual_found     VARCHAR2 DEFAULT NULL,
                       p_check_new_trans              VARCHAR2 DEFAULT 'N', -- Check new transaction
                       p_doc_date                     DATE     DEFAULT NULL,
                       p_doc_scope                    VARCHAR2 DEFAULT NULL,
                       p_doc_status                   OUT VARCHAR2,
                       p_allow_future_proc_period_ind VARCHAR2 DEFAULT 'N',
                       p_allow_alt_qty_Status_ind     VARCHAR2 DEFAULT 'N'
)RETURN BOOLEAN
IS

CURSOR c_trans(cp_document_key VARCHAR2, cp_transaction_key VARCHAR2) IS
    SELECT transaction_key
      FROM cont_transaction
     WHERE document_key = nvl(cp_document_key, document_key)
       AND transaction_key = nvl(cp_transaction_key, transaction_key);

CURSOR c_cargo(cp_transaction_key VARCHAR2, cp_doc_setup_id VARCHAR2, cp_doc_level VARCHAR2) IS
    SELECT alloc_no,
           contract_id,
           cargo_no,
           parcel_no,
           qty_type,
           profit_center_id,
           price_concept_code,
           price_object_id,
           uom1_code,
           vendor_id,
           customer_id,
           product_id,
           point_of_sale_date,
           li_unique_key_1,
           li_unique_key_2,
           ifac_tt_conn_code,
           ifac_li_conn_code,
           line_item_based_type,
           line_item_type,
           transaction_key
      FROM ifac_cargo_value
     WHERE (transaction_key = cp_transaction_key
            AND alloc_no = (SELECT MAX(alloc_no)
                              FROM ifac_cargo_value
                             WHERE transaction_key = cp_transaction_key))
        OR (preceding_trans_key = cp_transaction_key
            AND doc_setup_id = case cp_doc_level when 'BOOKED' then doc_setup_id else cp_doc_setup_id end
            AND alloc_no_max_ind = 'Y'
            AND trans_key_set_ind = 'N');

CURSOR c_sales(cp_transaction_key VARCHAR2, cp_doc_setup_id VARCHAR2, cp_status_code VARCHAR2, cp_doc_level VARCHAR2) IS
    SELECT alloc_no,
           contract_id,
           processing_period,
           product_id,
           price_concept_code,
           price_object_id,
           profit_center_id,
           delivery_point_id,
           vendor_id,
           customer_id,
           qty_status,
           uom1_code,
           unique_key_1,
           unique_key_2,
           li_unique_key_1,
           li_unique_key_2,
           period_start_date,
           period_end_date,
           ifac_tt_conn_code,
           ifac_li_conn_code,
           line_item_based_type,
           line_item_type,
           transaction_key
      FROM ifac_sales_qty
     WHERE (transaction_key = cp_transaction_key
            AND alloc_no = (SELECT MAX(alloc_no)
                              FROM ifac_sales_qty
                             WHERE transaction_key = cp_transaction_key))
        OR (preceding_trans_key = cp_transaction_key
            AND doc_setup_id = case cp_doc_level when 'BOOKED' then doc_setup_id else cp_doc_setup_id end
            AND ifac_sales_qty.doc_status = cp_status_code
            AND alloc_no_max_ind = 'Y'
            AND trans_key_set_ind = 'N');

CURSOR c_max_cargo(cp_contract_id              VARCHAR2,
                   cp_doc_setup_id             VARCHAR2,
                   cp_Processing_Period        DATE,
                   cp_cargo_no                 VARCHAR2,
                   cp_parcel_no                VARCHAR2,
                   cp_qty_type                 VARCHAR2,
                   cp_profit_center_id         VARCHAR2,
                   cp_price_concept_code       VARCHAR2,
                   cp_price_object_id          VARCHAR2,
                   cp_uom1_code                VARCHAR2,
                   cp_vendor_id                VARCHAR2,
                   cp_customer_id              VARCHAR2,
                   cp_product_id               VARCHAR2,
                   cp_li_unique_key_1          VARCHAR2,
                   cp_li_unique_key_2          VARCHAR2,
                   cp_if_tt_conn_code          VARCHAR2,
                   cp_if_li_conn_code          VARCHAR2,
                   cp_if_li_type               VARCHAR2,
                   cp_if_li_based_type         VARCHAR2,
                   cp_doc_status               VARCHAR2 DEFAULT NULL,
                   cp_contract_hold_final_ind  VARCHAR2 DEFAULT NULL,
                   cp_sys_att_hold_final_ind   VARCHAR2 DEFAULT NULL,
                   cp_non_booked_accrual_found VARCHAR2 DEFAULT NULL) IS
  SELECT t.doc_status, t.alloc_no
    FROM ifac_cargo_value t
   WHERE t.contract_id = cp_contract_id
     AND t.cargo_no = cp_Cargo_No
     AND t.parcel_no = cp_Parcel_No
     AND t.qty_type = cp_Qty_Type
     AND ((t.vendor_id = cp_vendor_id
         AND t.profit_center_id = cp_profit_center_id)
         OR EcDp_REVN_IFAC_WRAPPER_CARGO.IfacRecordHasVendorPC(
            source_entry_no,cp_vendor_id,cp_profit_center_id)='Y')
     AND t.price_concept_code = cp_Price_Concept_Code
     AND t.customer_id = cp_customer_id
     AND t.product_id = cp_Product_Id
     AND t.uom1_code = cp_uom1_code
     AND NVL(t.price_object_id, 'X') = NVL(cp_price_object_id, 'X')
     AND t.trans_key_set_ind = 'N'
     AND t.ignore_ind = 'N'
     AND t.alloc_no_max_ind = 'Y'
     AND nvl(ifac_tt_conn_code,'NA') = nvl(cp_if_tt_conn_code,'NA')
     AND t.line_item_based_type = cp_if_li_based_type
     AND nvl(t.line_item_type,'$NULL$') = nvl(cp_if_li_type,'$NULL$')
     AND nvl(t.ifac_li_conn_code,'$NULL$') = nvl(cp_if_li_conn_code,'$NULL$')
     AND ecdp_document_gen_util.SkipIfacQtyRecForUpdateCheck(
                t.doc_status, cp_doc_setup_id, cp_customer_id, cp_processing_period,
                cp_contract_hold_final_ind, cp_sys_att_hold_final_ind,
                cp_doc_status, cp_non_booked_accrual_found) = 'N'
     --Li_Unique_Key 1 and 2 are for other line items only.
     AND nvl(t.Li_Unique_Key_1,'$NULL$') = case t.line_item_based_type when EcDp_REVN_FT_CONSTANTS.li_btype_quantity then nvl(t.Li_Unique_Key_1,'$NULL$') else nvl(cp_li_unique_key_1,'$NULL$') end
     AND nvl(t.Li_Unique_Key_2,'$NULL$') = case t.line_item_based_type when EcDp_REVN_FT_CONSTANTS.li_btype_quantity then nvl(t.Li_Unique_Key_2,'$NULL$') else nvl(cp_li_unique_key_2,'$NULL$') end;

CURSOR c_max_sales(cp_contract_id               VARCHAR2,
                   cp_doc_setup_id              VARCHAR2,
                   cp_Processing_Period         DATE,
                   cp_product_id                VARCHAR2,
                   cp_price_concept_code        VARCHAR2,
                   cp_price_object_id           VARCHAR2,
                   cp_profit_center_id          VARCHAR2,
                   cp_delivery_point_id         VARCHAR2,
                   cp_vendor_id                 VARCHAR2,
                   cp_customer_id               VARCHAR2,
                   cp_qty_status                VARCHAR2,
                   cp_uom1_code                 VARCHAR2,
                   cp_unique_key_1              VARCHAR2,
                   cp_unique_key_2              VARCHAR2,
                   cp_li_unique_key_1           VARCHAR2,
                   cp_li_unique_key_2           VARCHAR2,
                   cp_period_start_date         DATE,
                   cp_period_end_date           DATE,
                   cp_if_tt_conn_code           VARCHAR2,
                   cp_if_li_conn_code           VARCHAR2,
                   cp_if_li_type                VARCHAR2,
                   cp_if_li_based_type          VARCHAR2,
                   cp_doc_status                VARCHAR2 DEFAULT NULL,
                   cp_contract_hold_final_ind   VARCHAR2 DEFAULT NULL,
                   cp_sys_att_hold_final_ind    VARCHAR2 DEFAULT NULL,
                   cp_non_booked_accrual_found  VARCHAR2 DEFAULT NULL,
                   cp_allow_future_proc_per_ind VARCHAR2 DEFAULT 'N',
                   cp_allow_alt_qty_Status_ind  VARCHAR2 DEFAULT 'N') IS
  SELECT t.doc_status, t.alloc_no
    FROM ifac_sales_qty t
   WHERE t.contract_id = cp_contract_id
     AND (t.processing_period = cp_Processing_Period
          OR (cp_allow_future_proc_per_ind = 'Y'
              AND t.processing_period >= cp_Processing_Period))
     AND t.product_id = cp_product_id
     AND t.price_concept_code = cp_price_concept_code
     AND t.delivery_point_id = cp_delivery_point_id
     AND ((t.vendor_id = cp_vendor_id
           AND t.profit_center_id = cp_profit_center_id)
          OR EcDp_REVN_IFAC_WRAPPER_PERIOD.IfacRecordHasVendorPC(
             source_entry_no,cp_vendor_id,cp_profit_center_id)='Y')
     AND t.customer_id = cp_customer_id
     AND (t.qty_status = cp_qty_status
          OR
          (cp_allow_alt_qty_Status_ind = 'Y'
           AND
           ((cp_qty_status = 'PROV' AND t.qty_status = 'FINAL')
            OR
            (cp_qty_status != 'PPA' AND t.qty_status = 'PPA'
             AND cp_Processing_Period < t.processing_period
             AND cp_doc_status = t.doc_status)
           )
          )
         )
     AND t.uom1_code = cp_uom1_code
     AND NVL(t.price_object_id, 'X') = NVL(decode(cp_allow_alt_qty_Status_ind,'Y',t.price_object_id, cp_price_object_id), 'X')
     AND nvl(t.unique_key_1, 'X') = nvl(cp_unique_key_1, 'X')
     AND nvl(t.unique_key_2, 'X') = nvl(cp_unique_key_2, 'X')
     AND nvl(ifac_tt_conn_code,'NA') = nvl(cp_if_tt_conn_code,'NA')
     AND t.period_start_date = cp_period_start_date
     AND t.period_end_date = cp_period_end_date
     AND t.trans_key_set_ind = 'N'
     AND t.ignore_ind = 'N'
     AND t.alloc_no_max_ind = 'Y'
     AND t.line_item_based_type = cp_if_li_based_type
     AND nvl(t.line_item_type,'$NULL$') = nvl(cp_if_li_type,'$NULL$')
     AND nvl(t.ifac_li_conn_code,'$NULL$') = nvl(cp_if_li_conn_code,'$NULL$')
     AND ecdp_document_gen_util.SkipIfacQtyRecForUpdateCheck(
                t.doc_status, cp_doc_setup_id, cp_customer_id, cp_processing_period,
                cp_contract_hold_final_ind, cp_sys_att_hold_final_ind,
                cp_doc_status, cp_non_booked_accrual_found) = 'N'
     --Li_Unique_Key 1 and 2 are for other line items only.
     AND nvl(t.Li_Unique_Key_1,'$NULL$') = case t.line_item_based_type when EcDp_REVN_FT_CONSTANTS.li_btype_quantity then nvl(t.Li_Unique_Key_1,'$NULL$') else nvl(cp_li_unique_key_1,'$NULL$') end
     AND nvl(t.Li_Unique_Key_2,'$NULL$') = case t.line_item_based_type when EcDp_REVN_FT_CONSTANTS.li_btype_quantity then nvl(t.Li_Unique_Key_2,'$NULL$') else nvl(cp_li_unique_key_2,'$NULL$') end;

  ln_alloc_no NUMBER;
  ln_new_alloc_no NUMBER;
  lv2_ret BOOLEAN := FALSE;
  lv2_contract_hold_final_ind VARCHAR2(1) := NULL;
  lv2_sys_att_hold_final_ind VARCHAR2(1) := NULL;
  lv2_is_new_trans VARCHAR(1) := NULL;

BEGIN
    --check for new transaction interfaced
    IF p_check_new_trans = 'Y' THEN
      lv2_is_new_trans := EcDp_Document_Gen_Util.isNewTransactionInterfaced(ec_contract_doc.contract_id(p_contract_doc_id), p_document_key, p_doc_date,p_doc_scope,p_doc_level,
                                                                            p_contract_doc_id);
      IF lv2_is_new_trans = 'Y' THEN
         Raise_Application_Error(-20000,'Delete and re-create to pull new transaction');
      END IF;
    END IF;

    FOR Trans IN c_trans(p_document_key, p_transaction_key) LOOP
        FOR Cargo IN c_cargo(Trans.Transaction_Key, p_contract_doc_id, p_doc_level) LOOP

            ln_alloc_no := Cargo.Alloc_No;
            ln_new_alloc_no := NULL;

            -- Gets the HOLD_FINAL_WHEN_ACL_INDs from the contract_doc
            -- and system attribute
            lv2_contract_hold_final_ind := ec_contract_doc_version.hold_final_when_acl_ind(
                                        p_contract_doc_id, Cargo.Point_Of_Sale_Date, '<=');

            lv2_sys_att_hold_final_ind := NVL(ec_ctrl_system_attribute.attribute_text(
                                        Cargo.Point_Of_Sale_Date, 'HOLD_FINAL_WHEN_ACL_IND', '<='), 'N');

            FOR rsMax IN c_max_cargo(cargo.contract_id,
                                     p_contract_doc_id,
                                     Cargo.Point_Of_Sale_Date,
                                     cargo.cargo_no,
                                     cargo.parcel_no,
                                     cargo.qty_type,
                                     cargo.profit_center_id,
                                     cargo.price_concept_code,
                                     cargo.price_object_id,
                                     cargo.uom1_code,
                                     cargo.vendor_id,
                                     cargo.customer_id,
                                     cargo.product_id,
                                     cargo.li_unique_key_1,
                                     cargo.li_unique_key_2,
                                     cargo.ifac_tt_conn_code,
                                     cargo.ifac_li_conn_code,
                                     cargo.line_item_type,
                                     cargo.line_item_based_type,
                                     p_ori_doc_status,
                                     lv2_contract_hold_final_ind,
                                     lv2_sys_att_hold_final_ind,
                                     p_non_booked_accrual_found) LOOP

                ln_new_alloc_no := rsMax.alloc_no;
                p_doc_status := rsMax.Doc_Status;
            END LOOP;

            IF ln_new_alloc_no IS NOT NULL THEN
              IF (ln_alloc_no < ln_new_alloc_no) OR (cargo.transaction_key IS NULL) THEN
                 lv2_ret := TRUE;

                 IF p_err_ind = 'Y' THEN
                     Raise_Application_Error(-20000,'Updated cargo information is available for transaction :' || Trans.Transaction_Key || '. Please update quantities.');
                 END IF;
              END IF;
            END IF;
        END LOOP;

        FOR Sales IN c_sales(Trans.Transaction_Key, p_contract_doc_id, p_ori_doc_status, p_doc_level) LOOP
            ln_alloc_no := Sales.Alloc_No;
            ln_new_alloc_no := NULL;

            -- Gets the HOLD_FINAL_WHEN_ACL_INDs from the contract_doc
            -- and system attribute
            lv2_contract_hold_final_ind := ec_contract_doc_version.hold_final_when_acl_ind(
                                        p_contract_doc_id, sales.Processing_Period, '<=');

            lv2_sys_att_hold_final_ind := NVL(ec_ctrl_system_attribute.attribute_text(
                                        sales.Processing_Period, 'HOLD_FINAL_WHEN_ACL_IND', '<='), 'N');

            FOR rsMax IN c_max_sales(sales.contract_id,
                                     p_contract_doc_id,
                                     sales.Processing_Period,
                                     sales.product_id,
                                     sales.price_concept_code,
                                     sales.price_object_id,
                                     sales.profit_center_id,
                                     sales.delivery_point_id,
                                     sales.vendor_id,
                                     sales.customer_id,
                                     sales.qty_status,
                                     sales.uom1_code,
                                     sales.unique_key_1,
                                     sales.unique_key_2,
                                     sales.li_unique_key_1,
                                     sales.li_unique_key_2,
                                     sales.period_start_date,
                                     sales.period_end_date,
                                     sales.ifac_tt_conn_code,
                                     sales.ifac_li_conn_code,
                                     sales.line_item_type,
                                     sales.line_item_based_type,
                                     p_ori_doc_status,
                                     lv2_contract_hold_final_ind,
                                     lv2_sys_att_hold_final_ind,
                                     p_non_booked_accrual_found,
                                     p_allow_future_proc_period_ind,
                                     p_allow_alt_qty_Status_ind) LOOP

                ln_new_alloc_no := rsMax.alloc_no;
                p_doc_status := rsMax.Doc_Status;
            END LOOP;

            IF ln_new_alloc_no IS NOT NULL THEN
               IF (ln_alloc_no < ln_new_alloc_no) or (p_allow_future_proc_period_ind = 'Y' or p_allow_alt_qty_Status_ind  = 'Y') or (sales.transaction_key IS NULL) THEN
                 lv2_ret := TRUE;

                 IF p_err_ind = 'Y' THEN
                     Raise_Application_Error(-20000,'New information have arrived for transaction :' || Trans.Transaction_Key || '. Please update and rerun');
                 END IF;
              END IF;
            END IF;
        END LOOP;
    END LOOP;

    RETURN lv2_ret;

END IsIfacUpdated;

-----------------------------------------------------------------------------------------------------------------------------

-- Find out if there has been interfaced records for a Dependent document or a Multi Period document.
-- Qty Status and / or Price Object may therefore not be the same as on the transaction being evaluated.
FUNCTION IsIfacDependentAvailable(p_document_key        VARCHAR2,
                                  p_transaction_Key     VARCHAR2,
                                  p_doc_status      OUT VARCHAR2)
RETURN BOOLEAN
IS

CURSOR c_clidc(cp_document_key VARCHAR2, cp_transaction_key VARCHAR2) IS
   SELECT nvl(cd.processing_period, ct.supply_from_date) processing_period,
          ct.object_id,
          ct.product_id,
          ct.price_concept_code,
          ct.price_object_id,
          clidc.dist_id profit_center_id,
          decode(cd.doc_scope,'CARGO_BASED',ct.discharge_port_id,ct.delivery_point_id) dp_id,
          clidc.vendor_id,
          cd.customer_id,
          ct.qty_type qty_status,
          ct.ifac_unique_key_1,
          ct.ifac_unique_key_2,
          ct.supply_from_date,
          ct.supply_to_date,
          ct.ifac_tt_conn_code,
          nvl(clidc.uom1_code ,ec_cont_transaction_qty.uom1_code(ct.transaction_key)) uom1_code,
          ct.cargo_name,
          cd.status_code
     FROM cont_document cd,
          cont_transaction ct,
          cont_li_dist_company clidc
    WHERE ct.document_key = cd.document_key
      AND clidc.transaction_key = ct.transaction_key
      AND ct.transaction_key = NVL(cp_transaction_key, ct.transaction_key)
      AND cd.document_key = NVL(cp_document_key, cd.document_key);

CURSOR c_new_ifac(cp_contract_id        VARCHAR2,
                   cp_Processing_Period  DATE,
                   cp_product_id         VARCHAR2,
                   cp_price_concept_code VARCHAR2,
                   cp_price_object_id    VARCHAR2,
                   cp_profit_center_id   VARCHAR2,
                   cp_dp_id              VARCHAR2,
                   cp_vendor_id          VARCHAR2,
                   cp_customer_id        VARCHAR2,
                   cp_uom1_code          VARCHAR2,
                   cp_qty_status         VARCHAR2,
                   cp_unique_key_1       VARCHAR2,
                   cp_unique_key_2       VARCHAR2,
                   cp_period_start_date  DATE,
                   cp_period_end_date    DATE,
                   cp_if_tt_conn_code    VARCHAR2,
                   cp_doc_concept        VARCHAR2,
                   cp_doc_setup_id       VARCHAR2,
                   cp_cargo_no           VARCHAR2,
                   cp_doc_status         VARCHAR2) IS
-- Non-Multi Period (Standalone/Dependent), same period, diff qty status and/or price object
  SELECT t.doc_status, MAX(alloc_no)
    FROM ifac_sales_qty t
   WHERE t.contract_id = cp_contract_id
     AND t.processing_period = cp_Processing_Period
     AND t.product_id = cp_product_id
     AND t.price_concept_code = cp_price_concept_code
     AND t.delivery_point_id = cp_dp_id
     AND ((t.vendor_id = cp_vendor_id
         AND t.profit_center_id = cp_profit_center_id)
     OR EcDp_REVN_IFAC_WRAPPER_PERIOD.IfacRecordHasVendorPC(
            source_entry_no,cp_vendor_id,cp_profit_center_id)='Y')
     AND t.customer_id = cp_customer_id
     AND t.uom1_code = cp_uom1_code
     AND t.trans_key_set_ind = 'N'
     AND t.ignore_ind = 'N'
     AND t.alloc_no_max_ind = 'Y'
     AND nvl(t.unique_key_1, 'X') = nvl(cp_unique_key_1, 'X')
     AND nvl(t.unique_key_2, 'X') = nvl(cp_unique_key_2, 'X')
     AND nvl(ifac_tt_conn_code,'NA') = nvl(cp_if_tt_conn_code,'NA')
     AND t.period_start_date = cp_period_start_date
     AND t.period_end_date = cp_period_end_date
     AND (t.qty_status != cp_qty_status OR NVL(t.price_object_id, 'X') != NVL(cp_price_object_id, 'X')) -- if dependent, one of these two will be different.
     AND cp_doc_concept != 'MULTI_PERIOD'
   GROUP BY t.doc_status
   UNION
-- Multi Period, The "same" transaction, same supply period
-- This is the only status where it is ok to state that items for accrual need to be updated with final (otherwise it is a sperate document
   SELECT t.doc_status, MAX(alloc_no)
    FROM ifac_sales_qty t
   WHERE t.contract_id = cp_contract_id
     AND t.processing_period >= cp_Processing_Period
     AND t.period_start_date = cp_period_start_date
     AND t.period_end_date = cp_period_end_date
     AND t.product_id = cp_product_id
     AND t.price_concept_code = cp_price_concept_code
     AND t.delivery_point_id = cp_dp_id
     AND ((t.vendor_id = cp_vendor_id
         AND t.profit_center_id = cp_profit_center_id)
     OR EcDp_REVN_IFAC_WRAPPER_PERIOD.IfacRecordHasVendorPC(
            source_entry_no,cp_vendor_id,cp_profit_center_id)='Y')
     AND t.customer_id = cp_customer_id
     AND t.uom1_code = cp_uom1_code
     AND t.trans_key_set_ind = 'N'
     AND t.ignore_ind = 'N'
     AND t.alloc_no_max_ind = 'Y'
     AND nvl(t.unique_key_1, 'X') = nvl(cp_unique_key_1, 'X')
     AND nvl(t.unique_key_2, 'X') = nvl(cp_unique_key_2, 'X')
     AND nvl(ifac_tt_conn_code,'NA') = nvl(cp_if_tt_conn_code,'NA')
     AND (t.qty_status != cp_qty_status
         OR NVL(t.price_object_id, 'X') != NVL(cp_price_object_id, 'X')
         OR cp_doc_status != t.doc_status) -- if dependent, one of these two will be different.
     AND cp_doc_concept = 'MULTI_PERIOD'
   GROUP BY t.doc_status   UNION
-- Multi Period, The "same" transaction, different supply period
-- Must match Document Status to state update required
   SELECT t.doc_status, MAX(alloc_no)
    FROM ifac_sales_qty t
   WHERE t.contract_id = cp_contract_id
     AND t.doc_status =  cp_doc_status
     AND t.processing_period = cp_Processing_Period
     AND t.product_id = cp_product_id
     AND t.price_concept_code = cp_price_concept_code
     AND t.delivery_point_id = cp_dp_id
     AND ((t.vendor_id = cp_vendor_id
         AND t.profit_center_id = cp_profit_center_id)
     OR EcDp_REVN_IFAC_WRAPPER_PERIOD.IfacRecordHasVendorPC(
            source_entry_no,cp_vendor_id,cp_profit_center_id)='Y')
     AND t.customer_id = cp_customer_id
     AND t.uom1_code = cp_uom1_code
     AND t.trans_key_set_ind = 'N'
     AND t.ignore_ind = 'N'
     AND t.alloc_no_max_ind = 'Y'
     AND nvl(t.unique_key_1, 'X') = nvl(cp_unique_key_1, 'X')
     AND nvl(t.unique_key_2, 'X') = nvl(cp_unique_key_2, 'X')
     AND nvl(ifac_tt_conn_code,'NA') = nvl(cp_if_tt_conn_code,'NA')
     AND (t.qty_status != cp_qty_status OR NVL(t.price_object_id, 'X') != NVL(cp_price_object_id, 'X')) -- if dependent, one of these two will be different.
     AND cp_doc_concept = 'MULTI_PERIOD'
   GROUP BY t.doc_status
   UNION
-- Multi Period, New APPEND transactions, whatever period
   SELECT t.doc_status, MAX(alloc_no)
    FROM ifac_sales_qty t
   WHERE t.contract_id = cp_contract_id
-- Multi Period requires prior to have same document setup
     AND t.doc_setup_id = cp_doc_setup_id
     AND t.doc_status =  cp_doc_status
     AND t.processing_period = cp_Processing_Period
     AND t.customer_id = cp_customer_id
     AND t.trans_key_set_ind = 'N'
     AND t.ignore_ind = 'N'
     AND t.alloc_no_max_ind = 'Y'
     AND cp_doc_concept = 'MULTI_PERIOD'
   GROUP BY t.doc_status
   UNION
   --Cargo
   SELECT icv.doc_status, MAX(alloc_no)
    FROM ifac_cargo_value icv
   WHERE icv.contract_id = cp_contract_id
     AND icv.product_id = cp_product_id
     AND icv.price_concept_code = cp_price_concept_code
     AND icv.discharge_port_id = cp_dp_id
     AND ((icv.vendor_id = cp_vendor_id
         AND icv.profit_center_id = cp_profit_center_id)
     OR EcDp_REVN_IFAC_WRAPPER_CARGO.IfacRecordHasVendorPC(
            source_entry_no,cp_vendor_id,cp_profit_center_id)='Y')
     AND icv.customer_id = cp_customer_id
     AND icv.uom1_code = cp_uom1_code
     AND icv.trans_key_set_ind = 'N'
     AND icv.ignore_ind = 'N'
     AND icv.alloc_no_max_ind = 'Y'
     AND icv.cargo_no = cp_cargo_no
     AND (icv.qty_type!= cp_qty_status OR NVL(icv.price_object_id, 'X') != NVL(cp_price_object_id, 'X')) -- if dependent, one of these two will be different.
   GROUP BY icv.doc_status
   ;

  lv2_doc_concept VARCHAR2(32);
  lv2_doc_setup_id VARCHAR2(32);
  lb_ret BOOLEAN := FALSE;
  lrec_doc CONT_DOCUMENT%ROWTYPE;
BEGIN

  lrec_doc := ec_cont_document.row_by_pk(p_document_key);


  lv2_doc_concept := lrec_doc.document_concept;
  lv2_doc_setup_id :=  lrec_doc.contract_doc_id;

  FOR rsISQ IN c_clidc(p_document_key, p_Transaction_Key) LOOP

      FOR rsNew IN c_new_ifac(rsISQ.object_id,
                              rsISQ.Processing_Period,
                              rsISQ.product_id,
                              rsISQ.price_concept_code,
                              rsISQ.Price_Object_Id,
                              rsISQ.profit_center_id,
                              rsISQ.dp_id,
                              rsISQ.vendor_id,
                              rsISQ.customer_id,
                              rsISQ.uom1_code,
                              rsISQ.Qty_Status,
                              rsISQ.ifac_unique_key_1,
                              rsISQ.ifac_unique_key_2,
                              rsISQ.supply_from_date,
                              rsISQ.supply_to_date,
                              rsISQ.ifac_tt_conn_code,
                              lv2_doc_concept,
                              lv2_doc_setup_id,
                              rsISQ.cargo_name,
                              lrec_doc.status_code) LOOP

            p_doc_status := rsNew.Doc_Status;
            lb_ret := TRUE;

        EXIT;

      END LOOP;

      IF lb_ret THEN
        EXIT;
      END IF;

  END LOOP;

  RETURN lb_ret;

END IsIfacDependentAvailable;



PROCEDURE SetDocumentComments(
    p_object_id VARCHAR2,
    p_document_id VARCHAR2,
    p_key VARCHAR2,
    p_comments VARCHAR2,
    p_user VARCHAR2,
    p_rev_text VARCHAR2 DEFAULT NULL
    )

IS

BEGIN

    BEGIN
        -- try insert
        INSERT INTO cont_document_comment (
            object_id
           ,document_key
           ,comment_key
           ,comments
           ,created_by
           ,rev_text
        ) VALUES (
            p_object_id
           ,p_document_id
           ,p_key
           ,p_comments
           ,p_user
           ,p_rev_text
        );

        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                -- update if already exists
                UPDATE cont_document_comment
                   SET comments = p_comments
                      ,last_updated_by = p_user
                      ,rev_text = p_rev_text
                 WHERE object_id = p_object_id
                   AND document_key = p_document_id
                   AND comment_key = p_key;

    END;

END SetDocumentComments;

FUNCTION GetDocumentComments(
    p_object_id VARCHAR2,
    p_document_id VARCHAR2,
    p_key VARCHAR2
    )
RETURN VARCHAR2

IS

CURSOR c_comments IS
SELECT comments
FROM cont_document_comment
WHERE object_id = p_object_id
AND document_key = p_document_id
AND comment_key = p_key;

lv2_comments cont_document_comment.comments%TYPE;

BEGIN

    FOR CommentCur IN c_comments LOOP

        lv2_comments := CommentCur.comments;

    END LOOP;

    RETURN lv2_comments;

END GetDocumentComments;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetFirstPreceedingDocId
-- Description    : Returns the first of any number of preceeding documents in a row
--
-- Preconditions  :
--
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
FUNCTION GetFirstPreceedingDocId
(  p_object_id VARCHAR2,
   p_doc_id VARCHAR2
)
RETURN VARCHAR2
--<EC-DOC>
IS
lv2_preceeding_doc cont_document.document_key%TYPE;

BEGIN

lv2_preceeding_doc := ec_cont_document.preceding_document_key(p_doc_id);

IF lv2_preceeding_doc IS NOT NULL THEN
   RETURN GetFirstPreceedingDocId(p_object_id,lv2_preceeding_doc);
ELSE
    RETURN p_doc_id;
END IF;

END GetFirstPreceedingDocId;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : HasBookedDependentDoc
-- Description    : Procedure has been enhanced by the fact that a document can play the role as preceding document
--                  for many child documents at the same time. This preocedure will therefore return Y if the
--                  child document with the LAST created date is booked, and this document has not been reversed.
--
-- Preconditions  :
--
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
FUNCTION HasBookedDependentDoc(p_document_key VARCHAR2)
RETURN VARCHAR2
--<EC-DOC>
IS

CURSOR c IS
SELECT nvl(d.document_level_code, 'OPEN') document_level_code
  FROM cont_document d
 WHERE d.preceding_document_key = p_document_key
 ORDER BY d.created_date DESC;

lv2_result VARCHAR2(1) := 'N';

BEGIN

FOR v IN c LOOP

 IF v.document_level_code = 'BOOKED' THEN
    lv2_result := 'Y';
    ELSE
      lv2_result := 'N';
      END IF;
    EXIT;

END LOOP;

RETURN lv2_result;


END HasBookedDependentDoc;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : HasReversedDependentDoc
-- Description    : Returns Y if a dependent doc can be created on the current doc. The explanations can be many.
--
-- Preconditions  :
--
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
FUNCTION HasReversedDependentDoc(p_document_key VARCHAR2)
    RETURN VARCHAR2
--<EC-DOC>
IS

CURSOR c IS
SELECT decode((SELECT dr.preceding_document_key
                FROM cont_document dr
               WHERE dr.reversal_ind = 'Y'
                 AND nvl(dr.document_level_code, 'OPEN') = 'BOOKED'
                 AND dr.preceding_document_key = d.document_key),
              null,
              'N',
              'Y') reversed
  FROM cont_document d
 WHERE nvl(d.document_level_code, 'OPEN') = 'BOOKED'
   AND d.preceding_document_key = p_document_key
 ORDER BY d.created_date DESC;

lv2_result VARCHAR2(1) := 'N';

BEGIN

FOR v IN c LOOP

    lv2_result := v.reversed;
        EXIT;

    END LOOP;

    RETURN lv2_result;


END HasReversedDependentDoc;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetReversedDoc
-- Description    : Returns document key for the last reversal document of the given document.
--
-- Preconditions  :
--
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
FUNCTION GetReversalDoc(p_document_key VARCHAR2)
    RETURN VARCHAR2
--<EC-DOC>
IS

    CURSOR c_reversal_doc(cp_document_key VARCHAR2) IS
        SELECT cont_document.document_key
            FROM cont_document
        WHERE cont_document.preceding_document_key = cp_document_key
            AND cont_document.reversal_ind = 'Y'
        ORDER BY cont_document.created_date DESC;

    lv2_result cont_document.document_key%TYPE;

BEGIN

    FOR ci_document IN c_reversal_doc(p_document_key) LOOP
        lv2_result := ci_document.document_key;
        EXIT;
    END LOOP;

    RETURN lv2_result;

END GetReversalDoc;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  GetConcatBankDetails
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
-- Behaviour      :  Return the concatenation of the BANK.NAME, BANK.CITY, BANK.COUNTRY, and BANK.BANK_SWIFT_CODE
--
-------------------------------------------------------------------------------------------------
FUNCTION GetConcatBankDetails
(
   p_bank_account_id VARCHAR2,
   p_document_key VARCHAR2
   )
RETURN VARCHAR2
--<EC-DOC>
IS
  ln_return_val VARCHAR2(400);
BEGIN

   IF ue_cont_document.isConcatBankDetailsUEEnabled  = 'TRUE' THEN

     ln_return_val:=ue_cont_document.GetConcatBankDetails(p_bank_account_id, p_document_key);

   ELSE

     ln_return_val:=ec_bank_account_version.name(p_bank_account_id,ec_cont_document.daytime(p_document_key),'<=')
     || ' ' ||nvl(''||ec_bank_version.bank_swift_code(ec_bank_account_version.BANK_ID(p_bank_account_id,ec_cont_document.daytime(p_document_key),'<='),ec_cont_document.daytime(p_document_key),'<='),'')
     || ' ' ||nvl(''||ec_bank_account_version.account_number(p_bank_account_id,ec_cont_document.daytime(p_document_key),'<='),'')
     || ' ' ||nvl(''||ec_bank_account_version.account_sort(p_bank_account_id,ec_cont_document.daytime(p_document_key),'<='),'');

   END IF;

   RETURN ln_return_val;

END GetConcatBankDetails;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : UpdIntBaseAmountFromApp
-- Description    : Does the same as the call to Ecdp_transaction.UpdIntBaseAmount, but might be called from the application
--                : In addition the procedure runs EcDp_Transaction.GenInterestLineItemSet for each interest line item on current contract/document/transaction
--                : which is basically the same that is being done on save from screen -> Values are calculated in screen.
--
-- Preconditions  :
--
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
PROCEDURE UpdIntBaseAmountFromApp
 (p_object_id       VARCHAR2,
  p_document_key    VARCHAR2,
  p_transaction_key VARCHAR2,
  p_base_rate       NUMBER,
  p_user            VARCHAR2
 )
--</EC-DOC>
IS

ld_interest_to_date  DATE;

CURSOR c_line_item(cp_transaction_key VARCHAR2) IS
SELECT *
  FROM cont_line_item cli
 WHERE cli.transaction_key = cp_transaction_key
   AND cli.line_item_based_type = 'INTEREST'
   AND cli.interest_line_item_key IS NULL;


CURSOR li_to_date(cp_transaction_key VARCHAR2, cp_line_item_key VARCHAR2) IS
SELECT max(cli.interest_to_date) maxdate
  FROM cont_line_item cli
 WHERE cli.transaction_key = cp_transaction_key
   AND cli.line_item_based_type = 'INTEREST'
   AND cli.interest_group = cp_line_item_key;

BEGIN

  IF ue_cont_document.isUpdIntBaseAmtUEEnabled = 'TRUE' THEN
      -- Call instead-of user exit
      ue_cont_document.UpdateInterestBaseAmount(p_object_id, p_document_key, p_transaction_key, p_base_rate, p_user);
  ELSE
      IF ue_cont_document.isUpdIntBaseAmtPreUEEnabled = 'TRUE' THEN
          -- Call PRE user exit
          ue_cont_document.UpdateInterestBaseAmountPre(p_object_id, p_document_key, p_transaction_key, p_base_rate, p_user);
      END IF;

      -- Updating interest base amount / interest from data /interest to date
      ecdp_Line_Item.UpdIntBaseAmount(p_object_id, p_document_key, GetFirstPreceedingDocId(p_object_id, p_document_key), p_base_rate);

      FOR c_val IN c_line_item(p_transaction_key) LOOP

        FOR d_val IN li_to_date(p_transaction_key, c_val.line_item_key) LOOP
            ld_interest_to_date := d_val.maxdate;
        END LOOP;

        EcDp_Line_Item.GenInterestLineItemSetFromApp(p_object_id,
                                              c_val.transaction_key,
                                              c_val.line_item_key,
                                              c_val.interest_from_date,
                                              nvl(ld_interest_to_date,c_val.interest_to_date),-- If compounds exists, use to_date on the latest one
                                              c_val.interest_base_amount,
                                              c_val.base_rate,
                                              c_val.interest_type,
                                              c_val.name,
                                              c_val.rate_offset,
                                              c_val.compounding_period,
                                              c_val.interest_group,
                                              c_val.interest_num_days,
                                              p_user);
      END LOOP;

      IF ue_cont_document.isUpdIntBaseAmtPostUEEnabled = 'TRUE' THEN
          -- Call POST user exit
          ue_cont_document.UpdateInterestBaseAmountPost(p_object_id, p_document_key, p_transaction_key, p_base_rate, p_user);
      END IF;
  END IF; -- Instead-of user exit enabled?
END UpdIntBaseAmountFromApp;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  GenContractDocCopy
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
FUNCTION GenContractDocCopy
 (p_doc_id                  VARCHAR2, -- Copy from
  p_contract_id             VARCHAR2,
  p_code                    VARCHAR2,
  p_name                    VARCHAR2,
  p_user                    VARCHAR2,
  p_start_date              DATE default NULL,
  P_end_date                DATE default NULL
  )
--</EC-DOC>
RETURN VARCHAR2
IS

lrec_prev contract_doc%ROWTYPE;
lrec_prev_version contract_doc_version%ROWTYPE;
lv2_document_id VARCHAR2(32);

-- ** 4-eyes approval stuff ** --
lv2_4e_recid VARCHAR2(32);
-- ** END 4-eyes approval stuff ** --

BEGIN

IF p_doc_id IS NOT NULL THEN

lrec_prev := ec_contract_doc.row_by_pk(p_doc_id);
lrec_prev_version := ec_contract_doc_version.row_by_pk(lrec_prev.object_id,NVL(p_start_date, Lrec_Prev.Start_Date),'<=');


-- Inserting into main table
INSERT INTO Contract_Doc
  (Object_Code, Start_Date, End_Date, Contract_Id, Description, Created_By)
VALUES
  (P_Code,
   NVL(p_start_date, Lrec_Prev.Start_Date),
   DECODE(Lrec_Prev.End_Date, to_date(NULL), to_date(NULL), NVL(p_end_date, Lrec_Prev.End_Date)),
   P_Contract_Id,
   Lrec_Prev.Description,
   P_User)
RETURNING object_id INTO lv2_document_id;

-- Inserting into version table
INSERT INTO contract_doc_version
  (object_id,
   daytime,
   end_date,
   name,
   amount_in_words,
   book_document_code,
   doc_concept_code,
   doc_scope,
   int_base_amount_source,
   int_compounding_period,
   int_num_days,
   int_offset,
   int_type,
   int_type_id,
   doc_number_format_accrual,
   doc_number_format_final,--replaced invoice number
   payment_term_base_code,
   price_basis,
   review_period,
   review_period_unit_code,
   send_unit_price_ind,
   use_currency_100_ind,
   doc_template_id,
   inv_doc_template_id,
   payment_term_id,
   automation_ind,
   automation_priority,
   doc_sequence_final_id,
   doc_sequence_accrual_id,
   doc_date_term_id,
   doc_date_calendar_coll_id,
   doc_received_term_id,
   doc_received_base_code,
   doc_rec_calendar_coll_id,
   payment_calendar_coll_id,
   pricing_currency_id,
   booking_currency_id,
   memo_currency_id,
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
   value_6,
   value_7,
   value_8,
   value_9,
   value_10,
   date_1,
   date_2,
   date_3,
   date_4,
   date_5,
   date_6,
   date_7,
   date_8,
   date_9,
   date_10,
   created_by,
   single_parcel_doc_ind)
VALUES
  (lv2_document_id,
   NVL(p_start_date, lrec_prev_version.daytime),
   NULL,
   lrec_prev_version.name,
   lrec_prev_version.amount_in_words,
   lrec_prev_version.book_document_code,
   lrec_prev_version.doc_concept_code,
   lrec_prev_version.doc_scope,
   lrec_prev_version.int_base_amount_source,
   lrec_prev_version.int_compounding_period,
   lrec_prev_version.int_num_days,
   lrec_prev_version.int_offset,
   lrec_prev_version.int_type,
   lrec_prev_version.int_type_id,
   lrec_prev_version.doc_number_format_accrual,
   lrec_prev_version.doc_number_format_final,--replaced invoice number
   lrec_prev_version.payment_term_base_code,
   lrec_prev_version.price_basis,
   lrec_prev_version.review_period,
   lrec_prev_version.review_period_unit_code,
   lrec_prev_version.send_unit_price_ind,
   lrec_prev_version.use_currency_100_ind,
   lrec_prev_version.doc_template_id,
   lrec_prev_version.inv_doc_template_id,
   lrec_prev_version.payment_term_id,
   lrec_prev_version.automation_ind,
   lrec_prev_version.automation_priority,
   lrec_prev_version.doc_sequence_final_id,
   lrec_prev_version.doc_sequence_accrual_id,
   lrec_prev_version.doc_date_term_id,
   lrec_prev_version.doc_date_calendar_coll_id,
   lrec_prev_version.doc_received_term_id,
   lrec_prev_version.doc_received_base_code,
   lrec_prev_version.doc_rec_calendar_coll_id,
   lrec_prev_version.payment_calendar_coll_id,
   lrec_prev_version.pricing_currency_id,
   lrec_prev_version.booking_currency_id,
   lrec_prev_version.memo_currency_id,
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
   lrec_prev_version.value_6,
   lrec_prev_version.value_7,
   lrec_prev_version.value_8,
   lrec_prev_version.value_9,
   lrec_prev_version.value_10,
   lrec_prev_version.date_1,
   lrec_prev_version.date_2,
   lrec_prev_version.date_3,
   lrec_prev_version.date_4,
   lrec_prev_version.date_5,
   lrec_prev_version.date_6,
   lrec_prev_version.date_7,
   lrec_prev_version.date_8,
   lrec_prev_version.date_9,
   lrec_prev_version.date_10,
   p_user,
   lrec_prev_version.single_parcel_doc_ind);


    -- ** 4-eyes approval logic ** --
    IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('CONTRACT_DOC'),'N') = 'Y' THEN

      -- Generate rec_id for the new record
      lv2_4e_recid := SYS_GUID();

      -- Set approval info on new record.
      UPDATE contract_doc_version
      SET last_updated_by = Nvl(EcDp_Context.getAppUser,User),
          last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
          approval_state = 'N',
          rec_id = lv2_4e_recid,
          rev_no = (nvl(rev_no,0) + 1)
      WHERE object_id = lv2_document_id
      AND daytime = NVL(p_start_date, lrec_prev_version.daytime);

      -- Register new record for approval
      Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                        'CONTRACT_DOC',
                                        Nvl(EcDp_Context.getAppUser,User));
    END IF;
    -- ** END 4-eyes approval ** --

   -- Updating ACL for if ringfencing is enabled
   IF (NVL(EcDp_ClassMeta_Cnfg.getAccessControlInd('CONTRACT_DOC'),'N') = 'Y') THEN
       EcDp_Acl.RefreshObject(lv2_document_id, 'CONTRACT_DOC', 'INSERTING');
   END IF;

END IF;

RETURN lv2_document_id;

END GenContractDocCopy;

PROCEDURE ValidateSplitShare
 (p_object_id VARCHAR2,
  p_doc_id VARCHAR2,
  p_daytime DATE
 )
IS

CURSOR c_trans IS
    SELECT *
    FROM cont_transaction ct
    WHERE ct.document_key = p_doc_id
    AND ct.object_id = p_object_id;


CURSOR c_splitMembers(cp_transaction_key VARCHAR2) IS
    SELECT clid.split_share
      FROM cont_line_item_dist clid
     WHERE clid.transaction_key = cp_transaction_key;

ln_share NUMBER;
BEGIN

    FOR Trans IN c_trans LOOP
        FOR Split IN c_splitMembers(Trans.Transaction_Key) LOOP
            ln_share := Split.Split_Share;
            IF (ln_share IS NULL) THEN
                Raise_Application_Error(-20000,'Split share is empty for one of the transactions in use, please update and rerun.');
            END IF;
        END LOOP;
    END LOOP;

END ValidateSplitShare;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : GetReportRunableNoByDefinition
-- Description    : This function returns an existing report_runable number based on specified
--                  report_definition_no.
-- Preconditions  : Note: The report_runable should already exists.
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
FUNCTION GetReportRunableNoByDefinition(p_report_definition_no VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
CURSOR c_report_runable(cp_rep_group_code VARCHAR2, cp_name VARCHAR2) IS
    select report_runable_no
      from report_runable
     where rep_group_code = cp_rep_group_code
       and name = cp_name
     order by report_runable_no desc;

lv2_rep_group_code       VARCHAR2(32);
lv2_rep_name             VARCHAR2(240);
ln_report_runable_no     NUMBER := 0;

BEGIN
lv2_rep_group_code := ec_report_definition.rep_group_code(p_report_definition_no);
lv2_rep_name := ec_report_definition_group.name(lv2_rep_group_code);

--Look for existing report_runable_no.
for Runable in c_report_runable(lv2_rep_group_code, lv2_rep_name) loop
    ln_report_runable_no := Runable.report_runable_no;
    exit;
end loop;

  return case ln_report_runable_no when 0 then '' else to_char(ln_report_runable_no) end;
END GetReportRunableNoByDefinition;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : ConfigureReport
-- Description    : Used by the EC Revenue reporting. When Running the report from the business function 'Document General'
--                  This procedure will create a runable report if missing. Else it will update the report parameters based on
--                  existing runable_no and data retrieved from the report selector in the screen.
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : report_runable, report_runable_param
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : If missing, creates a new record in report_runable and one record for each argument on this report in report_runable_param.
--                  If not missing, updates existing parameters with new values.
-------------------------------------------------------------------------------------------------
PROCEDURE ConfigureReport(p_contract_id          VARCHAR2,
                          p_document_key         VARCHAR2,
                          p_report_definition_no NUMBER,
                          p_user_id              VARCHAR2)
--</EC-DOC>
IS

CURSOR c_report_runable(cp_rep_group_code VARCHAR2, cp_name VARCHAR2) IS
    select report_runable_no
      from report_runable
     where rep_group_code = cp_rep_group_code
       and name = cp_name
     order by report_runable_no desc;

CURSOR c_report_runable_param(cp_report_runable_no NUMBER, cp_parameter_name VARCHAR2, cp_parameter_date DATE) IS
    select count(*) param_count
      from report_runable_param
     where report_runable_no = cp_report_runable_no
       and parameter_name = cp_parameter_name
       and daytime = cp_parameter_date;

lv2_rep_group_code       VARCHAR2(32);
lv2_rep_name             VARCHAR2(240);
ln_report_runable_no     NUMBER := 0;
ld_report_daytime        DATE := Ecdp_Timestamp.getCurrentSysdate;
ld_parameter_daytime     DATE;
ln_param_count_1         NUMBER;
ln_param_count_2         NUMBER;

BEGIN
lv2_rep_group_code := ec_report_definition.rep_group_code(p_report_definition_no);
ld_parameter_daytime := ec_report_definition.daytime(p_report_definition_no);
lv2_rep_name := ec_report_definition_group.name(lv2_rep_group_code);

--Look for existing report_runable_no.
for Runable in c_report_runable(lv2_rep_group_code, lv2_rep_name) loop
    ln_report_runable_no := Runable.report_runable_no;
    exit;
end loop;

--Create report_runable if missing.
if ln_report_runable_no = 0 then
    Ecdp_System_Key.assignNextNumber('REPORT_RUNABLE', ln_report_runable_no);

    INSERT INTO tv_report_runable
        (report_runable_no, rep_group_code, name, created_by)
    VALUES
        (ln_report_runable_no,
         lv2_rep_group_code,
         lv2_rep_name,
         p_user_id);
end if;

--Look for existing partameter 1.
for Param in c_report_runable_param(ln_report_runable_no, 'PARAMETER_1', ld_parameter_daytime) loop
    ln_param_count_1 := Param.param_count;
    exit;
end loop;
--Look for existing partameter 2.
for Param in c_report_runable_param(ln_report_runable_no, 'PARAMETER_2', ld_parameter_daytime) loop
    ln_param_count_2 := Param.param_count;
    exit;
end loop;

--Create "PARAMETER_1" if missing. Use contract ID as parameter value.
--Else update the parameter value.
if ln_param_count_1 = 0 then
    INSERT INTO report_runable_param
        (parameter_value,
         parameter_name,
         parameter_type,
         parameter_sub_type,
         report_runable_no,
         daytime,
         created_by)
    VALUES
        (p_contract_id,
         'PARAMETER_1',
         'EC_OBJECT_TYPE',
         'CONTRACT',
         ln_report_runable_no,
         ld_parameter_daytime,
         p_user_id);
else
    UPDATE report_runable_param
       SET parameter_type = 'EC_OBJECT_TYPE',
           parameter_sub_type = 'CONTRACT',
           parameter_value = p_contract_id
     WHERE report_runable_no = ln_report_runable_no
       AND daytime = ld_parameter_daytime
       AND parameter_name = 'PARAMETER_1';
end if;

--Create "PARAMETER_2" if missing. Use document key as parameter value.
--Else update the parameter value.
if ln_param_count_2 = 0 then
    INSERT INTO report_runable_param
        (parameter_value,
         parameter_name,
         parameter_type,
         parameter_sub_type,
         report_runable_no,
         daytime,
         created_by)
    VALUES
        (p_document_key,
         'PARAMETER_2',
         'BASIC_TYPE',
         'STRING',
         ln_report_runable_no,
         ld_parameter_daytime,
         p_user_id);
else
    UPDATE report_runable_param
       SET parameter_type = 'BASIC_TYPE',
           parameter_sub_type = 'STRING',
           parameter_value = p_document_key
     WHERE report_runable_no = ln_report_runable_no
       AND daytime = ld_parameter_daytime
       AND parameter_name = 'PARAMETER_2';
end if;
END ConfigureReport;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : UpdateDocumentReport
-- Description    : Used by the EC Revenue reporting. When generating a new report, more
--                  information is to be added for revenue reports.
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : report, document_report, cont_document, inventory
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------
PROCEDURE UpdateDocumentReport(p_report_no            VARCHAR2,
                               p_document_id          VARCHAR2,
                               p_document_date        VARCHAR2,
                               p_report_definition_no VARCHAR2)
--</EC-DOC>
IS
    CURSOR c_revn_module (cp_document_id VARCHAR2) IS
    SELECT document_id, revn_module
      FROM (SELECT document_key as document_id, 'SP' as revn_module FROM cont_document
            UNION ALL
            SELECT object_id, 'IN' FROM inventory)
     WHERE document_id = cp_document_id;

    CURSOR c_report (cp_report_no VARCHAR2, cp_document_id VARCHAR2, cp_document_date DATE) IS
    SELECT ((floor(nvl(max(dr.sort_order),0) / 10) + 1) * 10) next_sort_order
      FROM report r join document_report dr on dr.report_no = r.report_no
     WHERE dr.document_id = cp_document_id
       AND nvl(dr.document_date, trunc(Ecdp_Timestamp.getCurrentSysdate)) = nvl(cp_document_date, nvl(dr.document_date, trunc(Ecdp_Timestamp.getCurrentSysdate)))
       AND r.report_runable_no = ec_report.report_runable_no(cp_report_no);

    ld_document_date       DATE;
    ln_sort_order          NUMBER := 0;
    lv_revn_module         VARCHAR2(32);
    lv_document_level_code VARCHAR2(32);
BEGIN
    ld_document_date := to_date(p_document_date, 'YYYY-MM-DD"T"HH24:MI:SS');

    --Get current revenue module for specified document id
    FOR cur IN c_revn_module(p_document_id) LOOP
        lv_revn_module := cur.revn_module;
    END LOOP;

    --Get document_level_code for specified document
    lv_document_level_code := CASE nvl(lv_revn_module, 'NULL')
                                WHEN 'SP' THEN Ec_Cont_Document.document_level_code(p_document_id)
                                WHEN 'IN' THEN ec_inv_valuation.document_level_code(p_document_id, ld_document_date, to_char(ld_document_date,'YYYY'), '=')
                                ELSE NULL
                              END;

    --Get the next sort order.
    FOR cur IN c_report(p_report_no, p_document_id, ld_document_date) LOOP
        ln_sort_order := cur.next_sort_order;
    END LOOP;

    --Add a new row to hold more information about revenue reports
    INSERT INTO DOCUMENT_REPORT (
        report_no,
        document_id,
        document_date,
        document_level_code,
        sort_order,
        report_definition_no)
    VALUES (
        to_number(p_report_no),
        p_document_id,
        ld_document_date,
        lv_document_level_code,
        ln_sort_order,
        to_number(p_report_definition_no));

EXCEPTION
    WHEN OTHERS THEN
        Raise_Application_Error(-20000, SQLERRM || '\n\n' || 'Technical:\n');
END UpdateDocumentReport;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : DeleteDocumentReport
-- Description    : Used by the EC Revenue reporting to delete a report.
--
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : report, report_published
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------
FUNCTION  DeleteDocumentReport(p_report_no VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
IS
    CURSOR c_report (p_report_no VARCHAR2) IS
    SELECT *
      FROM report r
     WHERE r.report_no = p_report_no;

    CURSOR c_publish (p_report_no VARCHAR2) IS
    SELECT count(report_published_no) publish_count
      FROM report_published
     WHERE report_no = p_report_no;

    lv_end_user_message VARCHAR2(240);
BEGIN
    --Check if the report is 'Sent' or is 'Approved'. In which case 'Delete' should not be allowed.
    FOR cur IN c_report(p_report_no) LOOP
        IF(cur.accept_status !='P') THEN
            lv_end_user_message :='Warning!' || chr(10) || 'Deletion of approved or verified reports is not allowed.';
        END IF;
    END LOOP;
    IF lv_end_user_message is not null THEN
        RETURN lv_end_user_message;
    END IF;

    --Delete selected report.
    BEGIN
        DELETE FROM TV_REPORT
        WHERE REPORT_NO = p_report_no;
    EXCEPTION
        WHEN OTHERS THEN
            BEGIN
                --The deletion went wrong!!!
                lv_end_user_message := 'Warning!\n' || 'Deletion of Report Id ''' || p_report_no || ''' is not allowed.';

                FOR cur IN c_publish(p_report_no) LOOP
                    IF cur.publish_count > 0 THEN
                        --'Publish' is the problem.
                        lv_end_user_message := lv_end_user_message || ' This is because the report is published.';
                        null;
                    ELSIF SqlCode = -2292 THEN
                        --'Child Record Found' is the problem.
                        lv_end_user_message := lv_end_user_message || ' This is because child records are found.';
                    END IF;
                END LOOP;
            END;
    END;

    IF lv_end_user_message is null THEN
        lv_end_user_message := 'OK!\nPlease press Refresh button to refresh the Reports section' ;
    END IF;
    RETURN lv_end_user_message;

EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Error!\' || SQLERRM;
END DeleteDocumentReport;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : SetDocumentType
-- Description    : The procedure will set the proper document type based on the transactions found on the document
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
-- Behaviour      : If a provisional transaction is found on the document, the document type is considered provisional
--                  Otherwise the document type will be either final or normal based on the transaction type found.
--
-------------------------------------------------------------------------------------------------
PROCEDURE SetDocumentType(p_document_key VARCHAR2)
--</EC-DOC>
IS


lv2_contract_doc_id VARCHAR2(32) := ec_cont_document.contract_doc_id(p_document_key);
lv2_daytime       DATE           := ec_cont_document.daytime(p_document_key);

CURSOR c_trans_type IS
SELECT ttv.transaction_type
  FROM transaction_template tt, transaction_tmpl_version ttv
 WHERE tt.contract_doc_id = lv2_contract_doc_id
   AND tt.object_id = ttv.object_id
   AND tt.start_date <= lv2_daytime
   AND nvl(tt.end_date, lv2_daytime + 1) > lv2_daytime
   AND ttv.daytime <= lv2_daytime
   AND nvl(ttv.end_date, lv2_daytime + 1) > lv2_daytime;

BEGIN

IF (ec_contract_doc_version.doc_concept_code(lv2_contract_doc_id,lv2_daytime,'<=')='PPA' ) THEN
        UPDATE cont_document
          SET document_type = 'PPA'
        WHERE document_key = p_document_key;
END IF;


FOR c_t IN c_trans_type LOOP

    IF c_t.transaction_type like '%PROV%' THEN
       UPDATE cont_document
          SET document_type = c_t.transaction_type
        WHERE document_key = p_document_key;

    ELSIF
        c_t.transaction_type like '%FINAL%' THEN
       UPDATE cont_document
          SET document_type = c_t.transaction_type
        WHERE document_key = p_document_key
          AND document_type IS NULL;

        ELSIF
          c_t.transaction_type like '%NORM%' THEN
         UPDATE cont_document
            SET document_type = c_t.transaction_type
          WHERE document_key = p_document_key
            AND document_type IS NULL;

       END IF;


END LOOP;

END SetDocumentType;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : isMultiVendorDocument
-- Description    : Figure if document is part of a multivendor contract or not
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
FUNCTION isMultiVendorDocument (p_document_key VARCHAR2)
RETURN VARCHAR2

IS

ln_vendors NUMBER;


BEGIN

SELECT count(*)
  INTO ln_vendors
  FROM cont_document_company cdc
 WHERE cdc.document_key = p_document_key
   AND cdc.company_role = 'VENDOR';

IF ln_vendors > 1 THEN
    RETURN 'Y';
ELSE
    RETURN 'N';
END IF;


END isMultiVendorDocument;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : getDocumentVendorShareActual
-- Description    : Evaluates the numbers at the lowest level (cont_li_dist_company) to find the actual share for a given vendor on a given document
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
FUNCTION getDocumentVendorShareActual(
   p_document_key VARCHAR2,
   p_vendor_id VARCHAR2)
RETURN NUMBER

IS

ln_vendor_share_sum NUMBER;
ln_doc_total        NUMBER;
ln_result           NUMBER;


BEGIN

SELECT sum(c.pricing_value)
  INTO ln_vendor_share_sum
  FROM cont_li_dist_company c
 WHERE c.document_key = p_document_key
   AND c.vendor_id = p_vendor_id;

  ln_doc_total := ecdp_transaction.GetSumTransPricingValue(p_document_key);

IF abs(ln_doc_total) > 0 THEN
       ln_result := ln_vendor_share_sum/ln_doc_total;
ELSE
   ln_result := 0;
END IF;


RETURN ln_result;


END getDocumentVendorShareActual;





--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : concatVendorNames
-- Description    : concatenates the vendor names for a multivendor document
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

FUNCTION concatVendorNames(p_document_key VARCHAR2, p_type VARCHAR2)
RETURN varchar2
--</EC-DOC>
IS

 p_object_id VARCHAR2(32767) :='';
 cnt number :=0;
 cursor c_vat is
 SELECT
 distinct( ec_company_version.official_name(company_id, cd.daytime, '<=')) giver
 from cont_document_company cdc, cont_document cd, cont_li_dist_company clic
  where cdc.document_key = cd.document_key
   and cdc.company_role = 'VENDOR'
   and cdc.vat_receiver_id <> company_id
   and clic.document_key = cd.document_key
   and clic.vendor_id = cdc.company_id
   and clic.document_key =p_document_key;

 cursor c_exvat is
    SELECT
    distinct(ec_company_version.official_name(company_id, cd.daytime, '<=')) giver
   from cont_document_company cdc, cont_document cd, cont_li_dist_company clic
   where cdc.document_key = cd.document_key
   and cdc.company_role = 'VENDOR'
   and cdc.exvat_receiver_id <> cdc.company_id
   and clic.document_key = cd.document_key
   and clic.vendor_id = cdc.company_id
   and clic.document_key =p_document_key;

BEGIN
 IF (p_type = 'VAT') THEN
 FOR Trans in c_vat LOOP
 IF cnt >0 THEN
 p_object_id := p_object_id ||' and ' ;
 END IF ;

 p_object_id := p_object_id || trans.giver ;
 cnt:= cnt + 1;
 	END LOOP;

 ELSE
 FOR Trans in c_exvat LOOP
 IF cnt >0 THEN
 p_object_id := p_object_id ||' and ' ;
 END IF ;

 p_object_id := p_object_id || trans.giver ;
 cnt:= cnt + 1;
 END LOOP;

 END if;

  RETURN p_object_id;

END concatVendorNames;



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : getDistinctTransType
-- Description    : Gets the transaction scope for a document
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

FUNCTION getDistinctTransType(p_document_key VARCHAR2)
RETURN VARCHAR2
IS

 lv2_return_value VARCHAR2(100) :='';
 cnt number :=0;

CURSOR c_trans IS
SELECT distinct ct.transaction_scope
FROM cont_transaction ct
WHERE document_key = p_document_key;

BEGIN

    FOR CurTrans IN c_trans LOOP
    -- Verify that only one value is selected
    cnt :=cnt + 1;
    lv2_return_value := CurTrans.Transaction_Scope;
    END LOOP;

    IF cnt = 1 THEN
    RETURN lv2_return_value;
    ELSE
    RETURN 'error' ;
    END IF;

END getDistinctTransType;




--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : getLocalCurrency
-- Description    : Gets the local currency
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

FUNCTION getLocalCurrency(p_object_id VARCHAR2)
RETURN VARCHAR2
IS

 lv2_return_value VARCHAR2(100) :='';
 lv2_value1 VARCHAR(100);


BEGIN

SELECT distinct ct.COMPANY_CODE into lv2_value1
FROM rv_contract ct
WHERE object_id = p_object_id;

    SELECT distinct(local_currency_code)
  INTO lv2_return_value
  FROM rv_company
   WHERE code =lv2_value1;


RETURN lv2_return_value;
END getLocalCurrency;






--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : getTradingPartner
-- Description    : Gets the Trading partner
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

FUNCTION getTradingPartner(p_document_key VARCHAR2)
RETURN VARCHAR2
IS

  lv2_return_value VARCHAR2(100) :='';

  CURSOR c_tp(cp_document_key VARCHAR2) IS
  SELECT DISTINCT ec_company_version.trading_partner(cdc.company_id, ec_cont_document.daytime(cdc.document_key), '<=') AS trading_partner
    FROM cont_document_company cdc
   WHERE cdc.company_role = CASE ec_cont_document.financial_code(cp_document_key)
           WHEN 'SALE'      THEN 'CUSTOMER'
           WHEN 'TA_INCOME' THEN 'CUSTOMER'
           WHEN 'JOU_ENT'   THEN 'CUSTOMER'
           WHEN 'PURCHASE'  THEN 'VENDOR'
           WHEN 'TA_COST'   THEN 'VENDOR'
         END
     AND cdc.document_key = cp_document_key;

BEGIN

  FOR rsTp IN c_tp(p_document_key) LOOP
    lv2_return_value := rsTp.trading_partner;
  END LOOP;

  RETURN lv2_return_value;
END getTradingPartner;





--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      : UpdDocumentVat
-- Description    : The procedure will set the proper document Vat No and Country based on the transactions found on the document
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      : If a provisional transaction is found on the document, the document type is considered provisional
--                  Otherwise the document type will be either final or normal based on the transaction type found.
-------------------------------------------------------------------------------------------------
PROCEDURE UpdDocumentVat
 (p_document_key VARCHAR2,
  p_daytime VARCHAR2,
  p_user VARCHAR2 DEFAULT NULL
)
--</EC-DOC>
IS

CURSOR c_vendor(cp_document_key VARCHAR2) IS
SELECT company_id from cont_document_company where company_role = 'VENDOR' and document_key = cp_document_key;

CURSOR c_customer(cp_document_key VARCHAR2) IS
SELECT company_id from cont_document_company where company_role = 'CUSTOMER' and document_key = cp_document_key;


lv2_country_id VARCHAR2(32);
lv2_vendor_vat_reg_no VARCHAR2(200);
lv2_customer_vat_reg_no VARCHAR2(200);
lv2_vendor_id cont_document_company.company_id%TYPE;
lv2_customer_id cont_document_company.company_id%TYPE;
lv2_vendor_country_id VARCHAR2(32);
lv2_customer_country_id VARCHAR2(32);
lv2_vendor_vat_reg_no_own VARCHAR2(200);
lv2_customer_vat_reg_no_own VARCHAR2(200);
lv2_vendor_vat_reg_no_final VARCHAR2(200);
lv2_vendor_country_id_final VARCHAR2(32);
lv2_customer_vat_reg_no_final VARCHAR2(200);
lv2_customer_country_id_final VARCHAR2(32);

BEGIN

    lv2_country_id := Ecdp_Transaction.GetDestinationCountryId(p_document_key);

    IF lv2_country_id IS NOT NULL THEN
       lv2_vendor_country_id_final := lv2_country_id;
       lv2_customer_country_id_final := lv2_country_id;

       FOR r_vend IN c_vendor(p_document_key) LOOP

           lv2_vendor_id := r_vend.company_id;

       lv2_vendor_vat_reg_no := ec_company_country_setup.VAT_REG_NO(lv2_vendor_id, lv2_country_id, p_daytime, '<=');
       lv2_vendor_vat_reg_no_final := lv2_vendor_vat_reg_no;

       IF lv2_vendor_vat_reg_no IS NULL THEN
          lv2_vendor_country_id := ec_company_version.country_id(lv2_vendor_id, p_daytime, '<=');
          lv2_vendor_vat_reg_no_own := ec_company_country_setup.VAT_REG_NO(lv2_vendor_id, lv2_vendor_country_id, p_daytime, '<=');
          lv2_vendor_vat_reg_no_final := lv2_vendor_vat_reg_no_own;
          lv2_vendor_country_id_final := lv2_vendor_country_id;
       END IF;

                 --updating Vendor Country and VAT REG NO
           UPDATE cont_document_company t
           SET    t.country_id = lv2_vendor_country_id_final
                  ,t.vat_reg_no = lv2_vendor_vat_reg_no_final
                  ,t.last_updated_by = NVL(p_user, t.last_updated_by)
           WHERE  t.document_key = p_document_key
           AND t.company_id = lv2_vendor_id;


       END LOOP;

       FOR r_cust IN c_customer(p_document_key) LOOP

           lv2_customer_id := r_cust.company_id;

       lv2_customer_vat_reg_no := ec_company_country_setup.VAT_REG_NO(lv2_customer_id, lv2_country_id, p_daytime, '<=');
       lv2_customer_vat_reg_no_final := lv2_customer_vat_reg_no;

       IF lv2_customer_vat_reg_no IS NULL THEN
          lv2_customer_country_id := ec_company_version.country_id(lv2_customer_id, p_daytime, '<=');
          lv2_customer_vat_reg_no_own := ec_company_country_setup.VAT_REG_NO(lv2_customer_id, lv2_customer_country_id, p_daytime, '<=');
          lv2_customer_vat_reg_no_final := lv2_customer_vat_reg_no_own;
          lv2_customer_country_id_final := lv2_customer_country_id;
          END IF;

     --updating Customer Country and VAT REG NO
     UPDATE cont_document_company t
     SET    t.country_id = lv2_customer_country_id_final
            ,t.vat_reg_no = lv2_customer_vat_reg_no_final
            ,t.last_updated_by = NVL(p_user, t.last_updated_by)
     WHERE  t.document_key = p_document_key
     AND t.company_id = lv2_customer_id;

     END LOOP;

   ELSE

       FOR r_vend IN c_vendor(p_document_key) LOOP

          lv2_vendor_id := r_vend.company_id;
          lv2_vendor_country_id := ec_company_version.country_id(lv2_vendor_id, p_daytime, '<=');
          lv2_vendor_vat_reg_no_own := ec_company_country_setup.VAT_REG_NO(lv2_vendor_id, lv2_vendor_country_id, p_daytime, '<=');
          lv2_vendor_vat_reg_no_final := lv2_vendor_vat_reg_no_own;
          lv2_vendor_country_id_final := lv2_vendor_country_id;
           --updating Vendor Country and VAT REG NO
           UPDATE cont_document_company t
           SET    t.country_id = lv2_vendor_country_id_final
                  ,t.vat_reg_no = lv2_vendor_vat_reg_no_final
                  ,t.last_updated_by = NVL(p_user, t.last_updated_by)
           WHERE  t.document_key = p_document_key
           AND t.company_id = lv2_vendor_id;


       END LOOP;

       FOR r_cust IN c_customer(p_document_key) LOOP

          lv2_customer_id := r_cust.company_id;
          lv2_customer_country_id := ec_company_version.country_id(lv2_customer_id, p_daytime, '<=');
          lv2_customer_vat_reg_no_own := ec_company_country_setup.VAT_REG_NO(lv2_customer_id, lv2_customer_country_id, p_daytime, '<=');
          lv2_customer_vat_reg_no_final := lv2_customer_vat_reg_no_own;
          lv2_customer_country_id_final := lv2_customer_country_id;
     --updating Customer Country and VAT REG NO
     UPDATE cont_document_company t
     SET    t.country_id = lv2_customer_country_id_final
            ,t.vat_reg_no = lv2_customer_vat_reg_no_final
            ,t.last_updated_by = NVL(p_user, t.last_updated_by)
     WHERE  t.document_key = p_document_key
     AND t.company_id = lv2_customer_id;

     END LOOP;

   END IF;

END UpdDocumentVat;

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE ValidateERPDocument(
            p_document_key VARCHAR2,
            p_val_msg OUT VARCHAR2,
            p_val_code OUT VARCHAR2,
            p_silent_ind VARCHAR2 -- if 'N': Raise exeptions, if 'Y': continue and return code/msg
)
IS

  ln_count NUMBER := 0;
  lrec_doc cont_document%ROWTYPE := ec_cont_document.row_by_pk(p_document_key);
  validation_exception EXCEPTION;

  CURSOR c_postings(cp_document_key VARCHAR2) IS
    SELECT cep.*
      FROM cont_erp_postings cep
     WHERE cep.document_key = cp_document_key;

BEGIN

  IF lrec_doc.production_period IS NULL THEN
    p_val_msg := 'Missing Production Period on ERP document ' || p_document_key;
    p_val_code := 'PRODUCTION_PERIOD';
    RAISE validation_exception;
  END IF;


  FOR rsP IN c_postings(p_document_key) LOOP

    ln_count := ln_count + 1;

    -- Units and quantity
    IF rsP.Uom1_Code IS NULL THEN
      p_val_msg := 'Missing UOM on one or more postings on document ' || p_document_key;
      p_val_code := 'POSTING_UOM';
      RAISE validation_exception;
    END IF;

    IF rsP.Qty_1 IS NULL THEN
      p_val_msg := 'Missing quantity for UOM ' || rsP.Uom1_Code || ' on one or more postings on document ' || p_document_key;
      p_val_code := 'POSTING_QTY';
      RAISE validation_exception;
    END IF;

    -- Amounts and currencies
    IF rsP.Booking_Amount IS NULL THEN
      p_val_msg := 'Missing Booking Amount on one or more postings on document ' || p_document_key;
      p_val_code := 'POSTING_BOOKING_AMOUNT';
      RAISE validation_exception;
    END IF;

    IF rsP.Booking_Currency_Id IS NULL THEN
      p_val_msg := 'Missing Booking Currency on one or more postings on document ' || p_document_key;
      IF rsP.Booking_Currency_Code IS NOT NULL THEN
          p_val_msg := p_val_msg || '. Was not able to resolve Booking Currency Code [' || rsP.Booking_Currency_Code || '] into an EC Currency object.';
      END IF;
      p_val_code := 'POSTING_BOOKING_CURRENCY';
      RAISE validation_exception;
    END IF;

    -- Misc columns
    IF rsP.fin_debit_credit_code IS NULL THEN
      p_val_msg := 'Missing Debit/Credit code on one or more postings on document ' || p_document_key;
      p_val_code := 'POSTING_DEBIT_CREDIT';
      RAISE validation_exception;
    END IF;

    IF rsP.fin_gl_account_code IS NULL THEN
      p_val_msg := 'Missing GL Account code on one or more postings on document ' || p_document_key;
      p_val_code := 'POSTING_GL_ACCOUNT';
      RAISE validation_exception;
    END IF;

    IF rsP.Fin_Posting_Key IS NULL THEN
      p_val_msg := 'Missing Posting Key on one or more postings on document ' || p_document_key;
      p_val_code := 'POSTING_KEY';
      RAISE validation_exception;
    END IF;



   /* IF rsP.Local_Amount IS NULL THEN
      p_val_msg := 'Missing Local Amount on posting key ' || rsP.Fin_Posting_Key;
      p_val_code := 'LOCAL_AMOUNT';
      RAISE validation_exception;
    END IF;

    IF rsP.Local_Currency_Id IS NULL THEN
      p_val_msg := 'Missing Local Currency on posting key ' || rsP.Fin_Posting_Key;
      IF rsP.Local_Currency_Code IS NOT NULL THEN
          p_val_msg := p_val_msg || '. Was not able to resolve Local Currency Code [' || rsP.Local_Currency_Code || '] into an EC Currency object.';
      END IF;
      p_val_code := 'LOCAL_CURRENCY';
      RAISE validation_exception;
    END IF;
        */

  /*  -- Customer/Vendor
    IF rsP.Fin_Customer_Id IS NULL THEN
      p_val_msg := 'Missing Customer on posting key ' || rsP.Fin_Posting_Key;
      IF rsP.Fin_Customer_Code IS not NULL THEN
          p_val_msg := p_val_msg || '. Was not able to resolve Customer Code [' || rsP.Fin_Customer_Code || '] into an EC Customer object.';
      END IF;
      p_val_code := 'CUSTOMER';
      RAISE validation_exception;
    END IF;

    IF rsP.Fin_Vendor_Id IS NULL THEN
      p_val_msg := 'Missing Vendor on posting key ' || rsP.Fin_Posting_Key;
      IF rsP.Fin_Vendor_Code IS not NULL THEN
          p_val_msg := p_val_msg || '. Was not able to resolve Vendor Code [' || rsP.Fin_Vendor_Code || '] into an EC Vendor object.';
      END IF;
      p_val_code := 'VENDOR';
      RAISE validation_exception;
    END IF;
        */
    -- Cost Center / Revenue Order / WBS
  /*  IF rsP.Fin_Cost_Center_Code IS NULL AND
       rsP.Fin_Revenue_Order_Code IS NULL AND
       rsP.Fin_Wbs_Code IS NULL THEN
      p_val_msg := 'Missing value for Cost Center, Revenue Order or WBS on posting key ' || rsP.Fin_Posting_Key;
      p_val_code := 'COST_CENTER';
      RAISE validation_exception;
    END IF;*/



   /* IF rsP.fin_payment_term_code IS NULL THEN
      p_val_msg := 'Missing Payment Term code on posting key ' || rsP.Fin_Posting_Key;
      p_val_code := 'PAYMENT_TERM';
      RAISE validation_exception;
    END IF;*/

   /* IF rsP.fin_period IS NULL THEN
      p_val_msg := 'Missing value for Financial Period on posting key ' || rsP.Fin_Posting_Key;
      p_val_code := 'PERIOD';
      RAISE validation_exception;
    END IF;

    IF rsP.fin_profit_center_code IS NULL THEN
      p_val_msg := 'Missing Profit Center code on posting key ' || rsP.Fin_Posting_Key;
      p_val_code := 'PROFIT_CENTER';
      RAISE validation_exception;
    END IF;

    IF rsP.fin_vat_code IS NULL THEN
      p_val_msg := 'Missing VAT code on posting key ' || rsP.Fin_Posting_Key;
      p_val_code := 'VAT_CODE';
      RAISE validation_exception;
    END IF;*/

  END LOOP;

  -- Validate that det ERP document has one or more postings
  IF ln_count = 0 THEN
    p_val_msg := 'Missing Postings on ERP Document ' || p_document_key;
    p_val_code := 'NO_POSTINGS';
    RAISE validation_exception;
  END IF;



EXCEPTION
  WHEN validation_exception THEN
    IF p_silent_ind = 'N' THEN
       RAISE_APPLICATION_ERROR(-20000, 'Validation failed for ERP document: ' || p_document_key ||
                                       ', contract: ' || Ec_Contract.object_code(lrec_doc.object_id) || ' (' || Nvl(lrec_doc.contract_name, ' ') || ').' ||
                                       '\n\n' || p_val_msg);
    END IF;
END ValidateERPDocument;

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE ValidateDocument(
            p_document_key VARCHAR2,
            p_val_msg OUT VARCHAR2,
            p_val_code OUT VARCHAR2,
            p_silent_ind VARCHAR2 -- if 'N': Raise exeptions, if 'Y': continue and return code/msg
)
IS

  CURSOR c_document_vendor(pc_object_id VARCHAR2, pc_document_id VARCHAR2) IS
     SELECT cdc.*
       FROM cont_document_company cdc, company c
      WHERE cdc.object_id = pc_object_id
        AND document_key = pc_document_id
        AND cdc.company_id = c.object_id
        AND c.class_name = 'VENDOR';

  CURSOR c_balance_qty(cp_new_doc_key VARCHAR2) IS
    SELECT
      (
      NVL((
      SELECT SUM(net_qty1) qty1
      FROM cont_transaction ct, cont_transaction_qty ctq
      WHERE ct.transaction_key = ctq.transaction_key
      AND ct.document_key = cp_new_doc_key
      AND ct.reversal_ind = 'Y'),0)
    +
      (
      NVL((
      SELECT SUM(net_qty1) qty1
      FROM cont_transaction ct, cont_transaction_qty ctq
      WHERE ct.transaction_key = ctq.transaction_key
      AND ct.document_key = cp_new_doc_key
      AND ct.reversal_ind != 'Y'),0)
      )) Balance
    FROM DUAL;

  CURSOR c_balance_vendor(cp_doc_key VARCHAR2, cp_vendor_id VARCHAR2) IS
    SELECT SUM(pricing_value) price_value
      FROM cont_li_dist_company c
     WHERE c.document_key = cp_doc_key
       AND vendor_id = cp_vendor_id;

  CURSOR c_new_tr_val(cp_new_doc_key VARCHAR2) IS
    SELECT ct.*
      FROM cont_transaction ct
     WHERE ct.document_key = cp_new_doc_key
       AND ct.preceding_trans_key IS NOT NULL;

  CURSOR c_sumDoc (cp_doc_key VARCHAR2) IS
    SELECT SUM(ct.trans_pricing_total) tot
      FROM cont_transaction ct
     WHERE ct.document_key = cp_doc_key;

  validation_exception     EXCEPTION;

  lv2_trans_name        VARCHAR2(240);
  ln_count              NUMBER;

  lrec_doc cont_document%ROWTYPE := ec_cont_document.row_by_pk(p_document_key);

BEGIN

  IF Ue_Cont_Document.isValidateDocumentUEEnabled = 'TRUE' THEN

     Ue_Cont_Document.ValidateDocument(lrec_doc, p_val_msg, p_val_code, p_silent_ind);

  ELSE

    -- Common validation for all financial documents (both ERP-type and sale/purchase-type)

    -- Check daytime (document date)
    IF lrec_doc.daytime IS NULL THEN
      p_val_msg := 'Missing Document Date on document ' || p_document_key;
      p_val_code := 'DOCUMENT_DATE';
      RAISE validation_exception;
    END IF;

    IF UPPER(ECDP_OBJECTS.GETOBJCODE(lrec_doc.customer_id)) = 'UNDEFINED' THEN
      p_val_msg := 'Undefined Customer found on document ' || p_document_key;
      p_val_code := 'UNDEFINED_CUSTOMER';
      RAISE validation_exception;
    END IF;

    -- Check document status and number
    IF lrec_doc.status_code = 'ACCRUAL' THEN
       IF (lrec_doc.doc_number_format_accrual = '$MANUAL') THEN
          IF (lrec_doc.document_number IS NULL OR '' = lrec_doc.document_number) THEN
             p_val_msg := 'Document number not supplied. Please enter document number and rerun.';
             p_val_code := 'DOCUMENT_NUMBER';
             RAISE validation_exception;
          END IF;
    END IF;

    ELSIF lrec_doc.status_code = 'FINAL' THEN
      IF (lrec_doc.doc_number_format_final = '$MANUAL') THEN
         IF (lrec_doc.document_number IS NULL OR '' = lrec_doc.document_number) THEN
            p_val_msg := 'Document number not supplied. Please enter document number and rerun.';
            p_val_code := 'DOCUMENT_NUMBER';
            RAISE validation_exception;
          END IF;
       END IF;
    END IF;

    ValidateDocumentStatus(lrec_doc, p_val_msg, p_val_code, p_silent_ind);
    IF p_val_code IS NOT NULL THEN
      RAISE validation_exception;

    END IF;


    -- ERP-document specific validation
    IF lrec_doc.ext_document_key IS NOT NULL THEN

      ValidateERPDocument(p_document_key, p_val_msg, p_val_code, p_silent_ind);

      -- If code was set in erp validation, go to exception handler (end) with the code/msg
      IF p_val_code IS NOT NULL THEN
        RAISE validation_exception;
      END IF;

    ELSE

      -- Non-ERP-document specific validation

      -- Check for payment date
      IF lrec_doc.pay_date IS NULL AND lrec_doc.status_code <> 'ACCRUAL' THEN

         IF Nvl(ec_payment_term_version.payment_term_method(lrec_doc.payment_term_id,lrec_doc.daytime,'<='),'XXX') <> 'NO_DATE' THEN

            p_val_msg := 'Missing payment date.';
            p_val_code := 'PAY_DATE';
            RAISE validation_exception;

         END IF;

      END IF;

      -- Check for Document Received date
      IF lrec_doc.document_received_date IS NULL AND lrec_doc.status_code <> 'ACCRUAL' THEN

         IF lrec_doc.doc_received_base_code <> 'NO_DATE' THEN

            p_val_msg := 'Missing document received date.';
            p_val_code := 'DOCUMENT_RECEIVED_DATE';
            RAISE validation_exception;

         END IF;
      END IF;


      -- IF system attribute VAT_REG_NO_MANDATORY_IND is set to Y
      IF ec_ctrl_system_attribute.attribute_text(lrec_doc.daytime,'VAT_REG_NO_MANDATORY_IND','<=') = 'Y' THEN

         -- Validate Vat Reg No

        ln_count := 0;

        SELECT COUNT(*) INTO ln_count
          FROM cont_document_company c
         WHERE document_key = lrec_doc.document_key
           AND company_role = 'CUSTOMER'
           AND vat_reg_no IS NULL;

        IF ln_count > 0 THEN
           p_val_msg := 'Missing Customer VAT Reg No';
           p_val_code := 'VAT_REG_NO_CUSTOMER';
           RAISE validation_exception;
        END IF;

        ln_count := 0;

        SELECT COUNT(*) INTO ln_count
          FROM cont_document_company
         WHERE document_key = lrec_doc.document_key
           AND company_role = 'VENDOR'
           AND vat_reg_no is null;

        IF ln_count > 0 THEN
           p_val_msg := 'Missing Vendor VAT Reg No';
           p_val_code := 'VAT_REG_NO_VENDOR';
           RAISE validation_exception;
        END IF;

      END IF; -- VAT_REG_NO_MANDATORY_IND



      -- generic validation stuff is done in this procedure
      EcDp_Transaction.ValidateTransactions(lrec_doc.document_key, p_val_msg, p_val_code, p_silent_ind);

      IF p_val_code IS NULL THEN

        IF lrec_doc.DOCUMENT_TYPE not like 'DETAIL%' THEN

            -- Begin/End block to capture exceptions when in silent mode
            BEGIN

               EcDp_Transaction.ValidateDocQtyValue(lrec_doc.object_id,lrec_doc.document_key);

            EXCEPTION
              WHEN OTHERS THEN
                p_val_msg := SUBSTR(SQLERRM, 1, 240);
                p_val_code := 'LI_PRICING_VALUE';
                RAISE validation_exception;
            END;

            IF lrec_doc.status_code <> 'ACCRUAL' or nvl(ec_ctrl_system_attribute.attribute_text(lrec_doc.daytime,'VAT_ON_ACCRUALS','<='),'Y') = 'Y' THEN
              EcDp_Transaction.ValidateDocVAT(lrec_doc.document_key, p_val_msg, p_val_code, p_silent_ind);
            END IF;
        END IF;

        -- Special validation for reallocation document when going from OPEN to VALID1
        IF lrec_doc.document_concept = 'REALLOCATION' THEN

            -- Check that sum of pricing value for all transactions equals 0
            FOR rsD IN c_sumDoc(lrec_doc.document_key) LOOP
                IF rsD.tot <> 0 THEN

                  p_val_msg := 'Pricing Total for a reallocation document must be 0 (zero), but is ' || to_char(rsD.tot) || '.';
                  p_val_code := 'RA_PRICING_TOTAL';
                  RAISE validation_exception;

                END IF;
            END LOOP;

           -- Check that sum of booking value for all transactions equals 0
           IF lrec_doc.doc_booking_total <> 0 THEN

              p_val_msg := 'Booking Total for a reallocation document must be 0 (zero), but is ' || to_char(lrec_doc.doc_booking_total) || '.';
              p_val_code := 'RA_BOOKING_TOTAL';
              RAISE validation_exception;

           END IF;

           -- Check that sum of qty for all transactions equals 0
           FOR rsB IN c_balance_qty(lrec_doc.document_key) LOOP
              IF rsB.Balance <> 0 THEN

                 p_val_msg := 'Total quantity balance for a reallocation document must be 0 (zero), but is ' || to_char(rsB.Balance) || '.';
                 p_val_code := 'RA_QTY_BALANCE';
                 RAISE validation_exception;

              END IF;
           END LOOP;

           -- Check that sum of monetary value per vendor is 0.
           FOR rsV IN c_document_vendor(lrec_doc.object_id, lrec_doc.document_key) LOOP
               FOR rsB IN c_balance_vendor(lrec_doc.document_key, rsV.company_id) LOOP

                   IF rsB.price_value <> 0 THEN

                      p_val_msg := 'Pricing value for Vendor ' || ec_company_version.name(rsV.company_id, lrec_doc.Daytime, '<=') || ' must be 0 (zero) on a reallocation document, but is ' || to_char(rsB.price_value);
                      p_val_code := 'RA_PRICING_VALUE_VENDOR';
                      RAISE validation_exception;

                   END IF;
               END LOOP;
           END LOOP;

           -- Check that status_code is equal (FINAL/ACCURAL).
           IF lrec_doc.status_code <> ec_cont_document.status_code(lrec_doc.preceding_document_key) THEN

               p_val_msg := 'Status code on the reallocation document (' || lrec_doc.status_code || ') differs from the status code on the preceding document (' || ec_cont_document.status_code(lrec_doc.preceding_document_key) || ').';
               p_val_code := 'RA_STATUS_CODE_DIFF';
               RAISE validation_exception;

           END IF;

           -- Check that important dates are the same on New and preceding
           FOR rsT IN c_new_tr_val(lrec_doc.document_key) LOOP

             lv2_trans_name := ec_cont_transaction.name(rsT.transaction_key);

             -- Point of sale date
             IF rsT.transaction_date <> ec_cont_transaction.transaction_date(rsT.preceding_trans_key) THEN

                 p_val_msg := 'Reallocation Transaction [' || lv2_trans_name || '] has a Point Of Sale Date that differs from preceding transaction.';
                 p_val_code := 'RA_POS_DATE_DIFF';
                 RAISE validation_exception;

             END IF;

             -- Price Date
             IF rsT.price_date <> ec_cont_transaction.price_date(rsT.preceding_trans_key) THEN

                 p_val_msg := 'Reallocation Transaction [' || lv2_trans_name || '] has a Price Date that differs from preceding transaction.';
                 p_val_code := 'RA_PRICE_DATE_DIFF';
                 RAISE validation_exception;

             END IF;

             -- Forex date
             IF rsT.Ex_Pricing_Booking_Date <> ec_cont_transaction.Ex_Pricing_Booking_Date(rsT.preceding_trans_key) THEN

                 p_val_msg := 'Reallocation Transaction [' || lv2_trans_name || '] has a Pricing to Booking Forex Date that differs from preceding transaction.';
                 p_val_code := 'RA_PRI_BOOK_EX_DATE_DIFF';
                 RAISE validation_exception;

             END IF;

             IF rsT.Ex_Pricing_Memo_Date <> ec_cont_transaction.Ex_Pricing_Memo_Date(rsT.preceding_trans_key) THEN

                 p_val_msg := 'Reallocation Transaction [' || lv2_trans_name || '] has a Pricing to Memo Forex Date that differs from preceding transaction.';
                 p_val_code := 'RA_PRI_MEMO_EX_DATE_DIFF';
                 RAISE validation_exception;

             END IF;

             IF rsT.Ex_Booking_Local_Date <> ec_cont_transaction.Ex_Booking_Local_Date(rsT.preceding_trans_key) THEN

                 p_val_msg := 'Reallocation Transaction [' || lv2_trans_name || '] has a Booking to Local Forex Date that differs from preceding transaction.';
                 p_val_code := 'RA_BOOK_LOCAL_EX_DATE_DIFF';
                 RAISE validation_exception;

             END IF;

             IF rsT.Ex_Booking_Group_Date <> ec_cont_transaction.Ex_Booking_Group_Date(rsT.preceding_trans_key) THEN

                 p_val_msg := 'Reallocation Transaction [' || lv2_trans_name || '] has a Booking to Group Forex Date that differs from preceding transaction.';
                 p_val_code := 'RA_BOOK_GROUP_EX_DATE_DIFF';
                 RAISE validation_exception;

             END IF;

             -- Period Document Specific
             IF ec_cont_transaction.transaction_scope(rsT.transaction_key) = 'PERIOD_BASED' THEN

               -- Supply from/to date
               IF (rsT.supply_from_date <> ec_cont_transaction.supply_from_date(rsT.preceding_trans_key) OR
                   rsT.supply_to_date <> ec_cont_transaction.supply_to_date(rsT.preceding_trans_key)) THEN

                   p_val_msg := 'Reallocation Transaction [' || lv2_trans_name || '] has Supply From/To Dates that differs from preceding transaction.';
                   p_val_code := 'RA_SUPPLY_DATE_DIFF';
                   RAISE validation_exception;

             END IF;

               END IF;

             -- Cargo Document Specific
             IF ec_cont_transaction.transaction_scope(rsT.transaction_key) = 'CARGO_BASED' THEN
                NULL;
             END IF;

             -- Forex rates
             -- Pricing to booking
             IF rsT.ex_pricing_booking <> ec_cont_transaction.ex_pricing_booking(rsT.preceding_trans_key) THEN

                 p_val_msg := 'Reallocation Transaction [' || lv2_trans_name || '] has a Pricing to Booking Forex Rate that differs from preceding transaction.';
                 p_val_code := 'RA_PRIC_BOOK_EX_DIFF';
                 RAISE validation_exception;

             END IF;

             -- Pricing to memo
             IF NVL(rsT.ex_pricing_memo,0) <> NVL(ec_cont_transaction.ex_pricing_memo(rsT.preceding_trans_key),0) THEN

                 p_val_msg := 'Reallocation Transaction [' || lv2_trans_name || '] has a Pricing to Memo Forex Rate that differs from preceding transaction.';
                 p_val_code := 'RA_PRIC_MEMO_EX_DIFF';
                 RAISE validation_exception;

             END IF;

             -- Booking to Local
             IF NVL(rsT.ex_booking_local,0) <>  NVL(ec_cont_transaction.ex_booking_local(rsT.preceding_trans_key),0) THEN

                 p_val_msg := 'Reallocation Transaction [' || lv2_trans_name || '] has a Booking to Local Exchange Rate that differs from preceding transaction.';
                 p_val_code := 'RA_BOOK_LOCAL_EX_DIFF';
                 RAISE validation_exception;

             END IF;

             -- Booking to Group
             IF NVL(rsT.ex_booking_group,0) <>  NVL(ec_cont_transaction.ex_booking_group(rsT.preceding_trans_key),0) THEN

                 p_val_msg := 'Reallocation Transaction [' || lv2_trans_name || '] has a Booking to Group Exchange Rate that differs from preceding transaction.';
                 p_val_code := 'RA_BOOK_GROUP_EX_DIFF';
                 RAISE validation_exception;

             END IF;

           END LOOP;

        END IF; -- Reallocation
      END IF; -- If p_val_code is null
    END IF; -- ERP Document?
   END IF; -- Replacement User Exit?

   -- Check for POST User Exit
   IF Ue_Cont_Document.isValidateDocPostUEEnabled = 'TRUE' THEN

     Ue_Cont_Document.ValidateDocumentPost(lrec_doc, p_val_msg, p_val_code, p_silent_ind);

   END IF;

EXCEPTION

  WHEN validation_exception THEN
    IF p_silent_ind = 'N' THEN
       RAISE_APPLICATION_ERROR(-20000, 'Validation failed for document: ' || p_document_key ||
                                       ', contract: ' || Ec_Contract.object_code(lrec_doc.object_id) || ' (' || Nvl(lrec_doc.contract_name, ' ') || ').' ||
                                       '\n\n' || p_val_msg);
    END IF;

END ValidateDocument;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION checkDefaultReport
 (p_doc_template_id VARCHAR2,
  p_daytime DATE
 )
RETURN VARCHAR2
IS

CURSOR c_default(cp_doc_template_id VARCHAR2,cp_daytime DATE) IS
SELECT report_definition_no FROM DOC_TEMPL_REPORT_SETUP
WHERE object_id = cp_doc_template_id
AND daytime <= cp_daytime
AND cp_daytime < nvl(end_date, cp_daytime +1)
AND default_report ='Y';

CURSOR c_default_other(cp_doc_template_id VARCHAR2,cp_daytime DATE) IS
SELECT report_definition_no FROM DOC_TEMPL_REPORT_SETUP
WHERE object_id = cp_doc_template_id
AND daytime <= cp_daytime
AND cp_daytime < nvl(end_date, cp_daytime +1)
ORDER BY ec_REPORT_DEFINITION_GROUP.name(ec_report_definition.rep_group_code(report_definition_no));

lv2_default VARCHAR2(240);
BEGIN

     FOR rsD IN c_default(p_doc_template_id,p_daytime) LOOP
         lv2_default := ec_REPORT_DEFINITION_GROUP.name(ec_report_definition.rep_group_code(rsd.report_definition_no));
     END LOOP;

     IF lv2_default IS NULL THEN
         FOR rsDO IN c_default_other(p_doc_template_id,p_daytime) LOOP
             lv2_default := ec_REPORT_DEFINITION_GROUP.name(ec_report_definition.rep_group_code(rsdo.report_definition_no));
              EXIT;
         END LOOP;
     END IF;

     RETURN lv2_default;
END checkDefaultReport;

FUNCTION getRepDefNo
 (p_doc_template_id VARCHAR2,
  p_daytime DATE
 )
RETURN NUMBER
IS
CURSOR c_default(cp_doc_template_id VARCHAR2,cp_daytime DATE) IS
SELECT report_definition_no FROM DOC_TEMPL_REPORT_SETUP
WHERE object_id = cp_doc_template_id
AND daytime <= cp_daytime
AND cp_daytime < nvl(end_date, cp_daytime +1)
AND default_report ='Y';

CURSOR c_default_other(cp_doc_template_id VARCHAR2,cp_daytime DATE) IS
SELECT report_definition_no FROM DOC_TEMPL_REPORT_SETUP
WHERE object_id = cp_doc_template_id
AND daytime <= cp_daytime
AND cp_daytime < nvl(end_date, cp_daytime +1)
ORDER BY ec_REPORT_DEFINITION_GROUP.name(ec_report_definition.rep_group_code(report_definition_no));

ln_RepDefNo NUMBER;
BEGIN

     FOR rsD IN c_default(p_doc_template_id,p_daytime) LOOP
         ln_RepDefNo := rsd.report_definition_no;
     END LOOP;

     IF ln_RepDefNo IS NULL THEN
         FOR rsDO IN c_default_other(p_doc_template_id,p_daytime) LOOP
             ln_RepDefNo := rsdo.report_definition_no;
              EXIT;
         END LOOP;
     END IF;

     RETURN ln_RepDefNo;

END getRepDefNo;

FUNCTION getRepURL
 (p_doc_template_id VARCHAR2,
  p_daytime DATE
 )
RETURN VARCHAR2
IS
CURSOR c_default(cp_doc_template_id VARCHAR2,cp_daytime DATE) IS
SELECT report_definition_no FROM DOC_TEMPL_REPORT_SETUP
WHERE object_id = cp_doc_template_id
AND daytime <= cp_daytime
AND cp_daytime < nvl(end_date, cp_daytime +1)
AND default_report ='Y';

CURSOR c_default_other(cp_doc_template_id VARCHAR2,cp_daytime DATE) IS
SELECT report_definition_no FROM DOC_TEMPL_REPORT_SETUP
WHERE object_id = cp_doc_template_id
AND daytime <= cp_daytime
AND cp_daytime < nvl(end_date, cp_daytime +1)
ORDER BY ec_REPORT_DEFINITION_GROUP.name(ec_report_definition.rep_group_code(report_definition_no));

lv2_RepURL VARCHAR2(240);
BEGIN

  IF ue_cont_document.isGetRepURLUEEnabled = 'TRUE' THEN
    -- User Exit: In_Stead_Of
    lv2_RepURL := ue_cont_document.GetRepURL(p_doc_template_id, p_daytime);
  ELSE

    FOR rsD IN c_default(p_doc_template_id,p_daytime) LOOP
      lv2_RepURL :=to_char('/DownloadService'||ec_report_template_param.parameter_static_value(ec_report_definition.template_code(rsd.report_definition_no),'Template Name'));
    END LOOP;

    IF lv2_RepURL IS NULL THEN
      FOR rsDO IN c_default_other(p_doc_template_id,p_daytime) LOOP
        lv2_RepURL := to_char('/DownloadService'||ec_report_template_param.parameter_static_value(ec_report_definition.template_code(rsdo.report_definition_no),'Template Name'));
        EXIT;
      END LOOP;
    END IF;
  END IF;

  RETURN lv2_RepURL;

END getRepURL;

FUNCTION getRepName
 (p_doc_template_id VARCHAR2,
  p_daytime DATE
 )
RETURN VARCHAR2
IS
CURSOR c_default(cp_doc_template_id VARCHAR2,cp_daytime DATE) IS
SELECT report_definition_no FROM DOC_TEMPL_REPORT_SETUP
WHERE object_id = cp_doc_template_id
AND daytime <= cp_daytime
AND cp_daytime < nvl(end_date, cp_daytime +1)
AND default_report ='Y';

CURSOR c_default_other(cp_doc_template_id VARCHAR2,cp_daytime DATE) IS
SELECT report_definition_no FROM DOC_TEMPL_REPORT_SETUP
WHERE object_id = cp_doc_template_id
AND daytime <= cp_daytime
AND cp_daytime < nvl(end_date, cp_daytime +1)
ORDER BY ec_REPORT_DEFINITION_GROUP.name(ec_report_definition.rep_group_code(report_definition_no));

lv2_RepName VARCHAR2(240);
BEGIN

  IF ue_cont_document.isGetRepNameUEEnabled = 'TRUE' THEN
    -- User Exit: In_Stead_Of
    lv2_RepName := ue_cont_document.GetRepName(p_doc_template_id, p_daytime);
  ELSE

    FOR rsD IN c_default(p_doc_template_id,p_daytime) LOOP
      lv2_RepName :=ec_report_definition_param.parameter_value(rsd.report_definition_no,'JRXML');
    END LOOP;

    IF lv2_RepName IS NULL THEN
      FOR rsDO IN c_default_other(p_doc_template_id,p_daytime) LOOP
        lv2_RepName := ec_report_definition_param.parameter_value(rsdo.report_definition_no,'JRXML');
        EXIT;
      END LOOP;
    END IF;
  END IF;

  RETURN lv2_RepName;

END getRepName;


FUNCTION GetNextDocumentKey(p_object_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2
IS
  lv2_new_doc_key VARCHAR2(32);
  lv2_return_doc_key VARCHAR2(32);
BEGIN

   Ecdp_System_Key.assignNextNumber('CONT_DOCUMENT', lv2_new_doc_key);
   SELECT 'DOC:' || ec_geographical_area.object_code(ec_company_version.country_id(ec_contract_version.company_id(p_object_id, p_daytime, '<='), p_daytime, '<=')) || to_char(lv2_new_doc_key)
   INTO lv2_return_doc_key
   FROM DUAL;

RETURN lv2_return_doc_key;

END GetNextDocumentKey;





FUNCTION GetNextERPDocumentKey(p_object_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2
IS
  lv2_new_doc_key VARCHAR2(32);
  lv2_return_doc_key VARCHAR2(32);
BEGIN

   Ecdp_System_Key.assignNextNumber('CONT_DOC', lv2_new_doc_key);
   SELECT 'DOC:' || ec_geographical_area.object_code(ec_company_version.country_id(ec_contract_version.company_id(p_object_id, p_daytime, '<='), p_daytime, '<=')) || to_char(lv2_new_doc_key)
   INTO lv2_return_doc_key
   FROM DUAL;

RETURN lv2_return_doc_key;

END GetNextERPDocumentKey;





--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : isPreceding
-- Description    : Returns 'Y' or 'N' depending on whether this document is the preceeding document for another one.
--
-- Preconditions  :
--
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
FUNCTION isPreceding(p_document_key VARCHAR2) RETURN VARCHAR2
--<EC-DOC>
IS

  -- Get all documents having this document as preceding
  CURSOR c_prec(cp_prec_doc_key VARCHAR2) IS
    SELECT d.document_key
      FROM cont_document d
     WHERE d.preceding_document_key = cp_prec_doc_key
       AND NOT EXISTS( -- except where these documents have been zeroed out by reversals
               SELECT 'x'
                 FROM cont_document d2
                WHERE d2.document_key = d.preceding_document_key
                  AND ecdp_document.hasreverseddependentdoc(d2.document_key) = 'Y');

  lv2_result VARCHAR2(1) := 'N';

BEGIN

  FOR rsP IN c_prec(p_document_key) LOOP

      lv2_result := 'Y';
      EXIT;

  END LOOP;

  RETURN lv2_result;

END isPreceding;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isDocumentEditable
-- Description    : Function to return whether a document is editable or not (Y or N)
--
-- Preconditions  : Document key must be provided.
-- Postconditions :
--
-- Using tables   : cont_document
--
-- Using functions: ec_cont_document.document_level_code
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION isDocumentEditable(
         p_document_key VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN

  RETURN CASE NVL(ec_cont_document.document_level_code(p_document_key),'X')
         WHEN 'OPEN' THEN 'Y'
         ELSE 'N' END;

END isDocumentEditable;


------------------------+-----------------------------------+------------------------------------+---------------------------
-- (See header)
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE FillDocumentQuantity(
                         p_document_key                     VARCHAR2
                        ,p_user                             VARCHAR2
                        ,p_context                          T_REVN_DOC_OP_CONTEXT DEFAULT NULL
)
IS
    CURSOR t IS
    SELECT tx.transaction_key
      FROM cont_transaction tx
     WHERE tx.document_key = p_document_key
       AND tx.reversal_ind = 'N';

    lo_context T_REVN_DOC_OP_CONTEXT;
    l_updated  BOOLEAN;
BEGIN
    IF ue_cont_document.isFillDocumentQtyUEEnabled = 'TRUE' THEN
        ue_cont_document.FillDocumentQuantity(p_document_key, p_user);
    ELSE
        -- create context if not given
        -- the context is optional as this procedure is a public one
        lo_context := p_context;
        IF p_context IS NULL THEN
            lo_context := T_REVN_DOC_OP_CONTEXT();
        END IF;

        FOR vt IN t LOOP
            l_updated := ecdp_transaction.fill_qty_line_n_quantity_i(lo_context, vt.transaction_key);
        END LOOP;
    END IF;

    IF ue_cont_document.isFillDocQtyPostUEEnabled = 'TRUE' THEN
        ue_cont_document.FillDocQuantityPost(p_document_key, p_user);
    END IF;
END FillDocumentQuantity;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  FillDocumentPrice
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      : Call ecdp_transaction.filltransactionprice on all "legal" transactions on the document
-------------------------------------------------------------------------------------------------
PROCEDURE FillDocumentPrice(p_document_key VARCHAR2, p_user VARCHAR2)
--</EC-DOC>
IS

CURSOR t IS
SELECT tx.transaction_key, tx.transaction_date
  FROM cont_transaction tx
 WHERE tx.document_key = p_document_key
   AND tx.reversal_ind = 'N';



BEGIN

IF ue_cont_document.isFillDocumentPriceUEEnabled = 'TRUE' THEN
    ue_cont_document.FillDocumentPrice(p_document_key, p_user);
ELSE
  FOR vt IN t LOOP
    ecdp_transaction.filltransactionprice(vt.transaction_key,vt.transaction_date,p_user);
  END LOOP;
END IF;

IF ue_cont_document.isFillDocPricePostUEEnabled = 'TRUE' THEN
  ue_cont_document.FillDocPricePost(p_document_key, p_user);
END IF;

END FillDocumentPrice;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isDocSourceSplitShareUpdated
-- Description    : Function to return whether the source split of a document is updated or not (Y or N)
--
-- Preconditions  : Document key must be provided.
-- Postconditions :
--
-- Using tables   : cont_document
--
-- Using functions: ec_cont_document.document_level_code
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION isDocSourceSplitShareUpdated(p_document_key VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
  IS

  CURSOR t IS
  SELECT tx.transaction_key, tx.transaction_date
    FROM cont_transaction tx
   WHERE tx.document_key = p_document_key
     AND tx.reversal_ind = 'N';

BEGIN

  FOR vt IN t LOOP

    IF ecdp_transaction.isTransSourceSplitShareUpdated(vt.transaction_key) = 'Y' THEN
      RETURN 'Y';
    END IF;

  END LOOP;

  RETURN 'N';
END isDocSourceSplitShareUpdated;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  recalcSourceSplit
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      : Call ecdp_transaction.UpdTransSourceSplitShare on applicable transactions on the document
-------------------------------------------------------------------------------------------------
PROCEDURE recalcSourceSplit(p_document_key VARCHAR2, p_user_id VARCHAR2)
--</EC-DOC>
IS

  CURSOR c_ct IS
    select ct.object_id,
           ct.transaction_key,
           ct.transaction_date,
           ct.daytime,
           ec_cont_transaction_qty.uom1_code(ct.transaction_key) as uom1_code,
           ec_cont_transaction_qty.net_qty1(ct.transaction_key) as qty1
      from cont_transaction ct
     where ct.document_key = p_document_key
       AND ct.reversal_ind = 'N';

begin


  IF ec_cont_document.document_level_code(p_document_key) <> 'OPEN' THEN
    RAISE_APPLICATION_ERROR(-20000, 'Split share recalculation can not be performed unless document level is OPEN');
  END IF;

  FOR r_ct IN c_ct LOOP
    ecdp_transaction.UpdTransSourceSplitShare(r_ct.transaction_key, r_ct.qty1, r_ct.uom1_code, r_ct.daytime);

    -- ensure percentage line items are recalculated:
    EcDp_transaction.UpdPercentageLineItem(r_ct.transaction_key, p_user_id);

  END LOOP;

END recalcSourceSplit;

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE ValidateContractDocForERP(p_contract_doc_id VARCHAR2,
                                   p_daytime DATE)
IS

  CURSOR c_tt(cp_contract_doc_id VARCHAR2) IS
    SELECT object_id
      FROM transaction_template tt
     WHERE tt.contract_doc_id = cp_contract_doc_id;

  lb_found BOOLEAN := FALSE;

BEGIN

  FOR rsTT IN c_tt(p_contract_doc_id) LOOP
    lb_found := TRUE;
  END LOOP;

  IF lb_found THEN
    RAISE_APPLICATION_ERROR(-20000, 'Document Setup is referenced by one or more Transaction Templates.\n\nTransaction Templates on ERP Documents is not supported.\n\nDelete Transaction Templates before you make the Document Setup an ERP Document.');
  END IF;

END ValidateContractDocForERP;



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  InsVendorCustomer
-- Description    :  Insert vendor and customer on document. Moved out of procedure gendocumentset for readability and usability issues (needed for ERP docs etc.)
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
PROCEDURE InsVendorCustomer(p_document_key VARCHAR2,
                            p_daytime      DATE,
                            p_user_id      VARCHAR2)
--</EC-DOC>

IS

  lv2_object_id contract.object_id%TYPE;
  lv2_contract_doc_id contract_doc.object_id%TYPE;
  lv2_customer_id company.object_id%TYPE;
  ln_customer_count NUMBER;
  lv2_preceding_document VARCHAR2(32);

CURSOR c_split(cp_contract_id VARCHAR2, cp_class_name VARCHAR2, cp_daytime DATE) IS
SELECT cps.company_id id
  FROM contract_party_share cps
 WHERE cps.object_id = cp_contract_id
   AND cps.party_role = cp_class_name
   AND cp_daytime >= Nvl(daytime, cp_daytime - 1)
   AND cp_daytime < Nvl(end_date, cp_daytime + 1);


CURSOR c_preceding_doc_customers(cp_document_key VARCHAR2,
                                 cp_daytime date)
IS
    SELECT cdc.company_id id
    FROM cont_document_company cdc
    WHERE document_key = cp_document_key
        AND company_role = 'CUSTOMER'
        AND EXISTS
        (SELECT OBJECT_ID FROM
                CONTRACT_PARTY_SHARE cps
                WHERE
                   (COMPANY_ID = cdc.company_id
                   or ec_company.object_code(COMPANY_ID) = 'UNDEFINED')
                AND OBJECT_ID= cdc.object_id
                AND cps.party_role = 'CUSTOMER'
                AND daytime <= cp_daytime
                and nvl(end_Date,cp_daytime+1) > cp_daytime);

 lb_customer_sat BOOLEAN := FALSE;

BEGIN

  lv2_object_id       := ec_cont_document.object_id(p_document_key);
  lv2_contract_doc_id := ec_cont_document.contract_doc_id(p_document_key);
  lv2_preceding_document := ec_cont_document.preceding_document_key(p_document_key);

  FOR VendSplitCur IN c_split(lv2_object_id, 'VENDOR',p_daytime) LOOP
     InsNewDocumentVendor(lv2_object_id, lv2_contract_doc_id, p_document_key, VendSplitCur.id, p_user_id);
  END LOOP;

  ln_customer_count := 0;

  IF lv2_preceding_document IS NOT NULL THEN

      FOR CustSplitCur IN c_preceding_doc_customers(lv2_preceding_document,ec_cont_document.daytime(p_document_key))
      LOOP
          lv2_customer_id := CustSplitCur.id;
          ln_customer_count := ln_customer_count + 1;

          InsNewDocumentCustomer(lv2_object_id, lv2_contract_doc_id, p_document_key, CustSplitCur.id, p_user_id);
          lb_customer_sat := true;
      END LOOP;
  END IF;
  IF lb_customer_sat = FALSE THEN
      FOR CustSplitCur IN c_split(lv2_object_id, 'CUSTOMER',p_daytime)
      LOOP
          lv2_customer_id := CustSplitCur.id;
          ln_customer_count := ln_customer_count + 1;

          InsNewDocumentCustomer(lv2_object_id, lv2_contract_doc_id, p_document_key, CustSplitCur.id, p_user_id);
      END LOOP;
  END IF;

  -- Update the customer id to cont_document table
  -- If multiple customers are found (which is not supported in the product),
  -- NULL will be set.
  IF ln_customer_count > 1 THEN
      lv2_customer_id := NULL;
  END IF;

  UPDATE cont_document
  SET customer_id = lv2_customer_id,
      last_updated_by = p_user_id
  WHERE document_key = p_document_key;

END InsVendorCustomer;

-----------------------------------------------------------------------------------------------------------------------------
-- Decide daytime on cont_xx tables if this is after contract or contract doc lifetime (end_date)
FUNCTION GetDocumentDaytime(
         p_contract_id VARCHAR2,
         p_contract_doc_id VARCHAR2,
         p_document_date DATE
)RETURN DATE
IS

  lr_contract              contract%ROWTYPE := ec_contract.row_by_pk(p_contract_id);
  lr_contract_doc          contract_doc%ROWTYPE := ec_contract_doc.row_by_pk(p_contract_doc_id);
  ld_sysdate               DATE := trunc(Ecdp_Timestamp.getCurrentSysdate(), 'DD');
  ld_daytime               DATE;
  lv2_daytime_base         VARCHAR2(32);
  daytime_not_valid        EXCEPTION;
  missing_contract_doc_id  EXCEPTION;
  lrec_cv                  contract_version%ROWTYPE;
  lrec_cdv                 contract_doc_version%ROWTYPE;

BEGIN

    IF p_contract_doc_id is NULL THEN
       RAISE missing_contract_doc_id;
    END IF;

    -- If the suggested document date is higher than contract end date, use this as the daytime
    IF p_document_date >= nvl(lr_contract.end_date, p_document_date + 1)  THEN
      ld_daytime := lr_contract.end_date - 1; -- Minus one due to end date not being a valid version date.
      lv2_daytime_base := 'Contract End Date';

    ELSE
      -- If the suggested document date is higher than contract doc end date, use this as the daytime
      IF p_document_date >= nvl(lr_contract_doc.end_date, p_document_date + 1)  THEN
        ld_daytime := lr_contract_doc.end_date - 1; -- Minus one due to end date not being a valid version date.
        lv2_daytime_base := 'Document Setup End Date';

      ELSE
        -- The contract and document setup are valid for the document date. Set daytime to be the same as document date
        -- Fallbacks to contract and contract doc start date
        ld_daytime := ecdp_contract_setup.getValidDocDaytime(p_contract_id, p_contract_doc_id, p_document_date);
        lv2_daytime_base := 'Document Date';

      END IF;
    END IF;

    -- Test Daytime on contract and doc setup (if date is valid, ec package should always return the row)
    lrec_cv := ec_contract_version.row_by_pk(p_contract_id, ld_daytime, '<=');
    lrec_cdv := ec_contract_doc_version.row_by_pk(p_contract_doc_id, ld_daytime, '<=');

    IF lrec_cv.object_id IS NULL OR lrec_cdv.object_id IS NULL THEN
       RAISE daytime_not_valid;
    END IF;

    RETURN ld_daytime;

EXCEPTION
    WHEN missing_contract_doc_id THEN
       RAISE_APPLICATION_ERROR(-20000, 'Missing Document Setup when determining Document Daytime. A possible reason: the sales/cargo interface could not determine Document Setup due to configuration mismatch.');

    WHEN daytime_not_valid THEN
       RAISE_APPLICATION_ERROR(-20000, 'Document Version Date (' || ld_daytime || '), based on ' || lv2_daytime_base || ', is not valid for document processing.');

END GetDocumentDaytime;




/*
--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :   IsDocumentValidForPPA
-- Description    :  Returns true if document accepts PPA transactions. False otherwise
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
FUNCTION IsDocumentValidForPPA(p_document_key VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>

IS

lrec_doc cont_document%ROWTYPE;
lv2_ppa_transaction_ind VARCHAR2(1);
lb_result VARCHAR2(32) := 'Y';


BEGIN

  lrec_doc := ec_cont_document.row_by_pk(p_document_key);
  lv2_ppa_transaction_ind := ec_contract_doc_version.ppa_transaction_ind(lrec_doc.contract_doc_id,lrec_doc.daytime,'<=');


IF nvl(lrec_doc.document_level_code,'OPEN') <> 'OPEN' THEN
    lb_result := 'N';
  END IF;

IF nvl(lv2_ppa_transaction_ind,'N') <> 'Y' THEN
    lb_result := 'N';
  END IF;



RETURN lb_result;



END IsDocumentValidForPPA;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :   GetDocumentValidForPPA
-- Description    :  Returns the document key that allows ppa transactions. The most recent one if multiple
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
FUNCTION GetDocumentValidForPPA(p_contract_id VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>

IS

CURSOR doc IS
SELECT d.document_key
    FROM cont_document d
   WHERE nvl(d.document_level_code, 'OPEN') = 'OPEN'
     AND nvl(d.reversal_ind, 'N') = 'N'
     AND d.object_id = p_contract_id
   ORDER BY created_date DESC;

lv2_result cont_document.document_key%TYPE;

BEGIN

FOR r IN doc LOOP

IF IsDocumentValidForPPA(r.document_key) = 'Y' THEN
      lv2_result := r.document_key;
    END IF;


    EXIT WHEN lv2_result IS NOT NULL;

  END LOOP;

RETURN lv2_result;



END GetDocumentValidForPPA;*/





--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  IsDocLevelLocked
-- Description    :  Determains whether the given document is locked. The default implementation
--                   regards documents at BOOKED or TRANSFER level as locked.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- Required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
FUNCTION IsDocLevelLocked(p_document_key VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  IF UE_CONT_DOCUMENT.isDocLevelLockedUEEnabled = 'TRUE' THEN
    RETURN UE_CONT_DOCUMENT.IsDocLevelLocked(p_document_key);
  ELSE
    RETURN CASE
              WHEN ec_cont_document.document_level_code(p_document_key) = 'BOOKED' THEN 'TRUE'
              ELSE 'FALSE'
            END;
  END IF;
END IsDocLevelLocked;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  ValidateDocumentStatus
-- Description    :  Check if the given status is valid for the document.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- Required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
PROCEDURE ValidateDocumentStatus(p_document_key VARCHAR2,
            p_val_msg OUT VARCHAR2,
            p_val_code OUT VARCHAR2,
            p_silent_ind VARCHAR2 -- if 'N': Raise exeptions, if 'Y': continue and return code/msg
            )
--</EC-DOC>
IS
    lrec_document CONT_DOCUMENT%ROWTYPE := ec_cont_document.row_by_pk(p_document_key);
BEGIN
    ValidateDocumentStatus(lrec_document, p_val_msg, p_val_code, p_silent_ind);
END;



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  ValidateDocumentStatus
-- Description    :  Check if the given status is valid for the document.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- Required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
PROCEDURE ValidateDocumentStatus(p_document_rec CONT_DOCUMENT%ROWTYPE,
            p_val_msg OUT VARCHAR2,
            p_val_code OUT VARCHAR2,
            p_silent_ind VARCHAR2 -- if 'N': Raise exeptions, if 'Y': continue and return code/msg
            )
--</EC-DOC>
IS
    lrec_prec_document CONT_DOCUMENT%ROWTYPE := ec_cont_document.row_by_pk(p_document_rec.PRECEDING_DOCUMENT_KEY);
    status_not_the_same EXCEPTION;
    status_null EXCEPTION;
BEGIN
    IF p_document_rec.status_code IS NULL THEN
            p_val_msg := 'Missing document status.';
            p_val_code := 'DOCUMENT_STATUS';
            RAISE status_null;

    ELSIF p_document_rec.PRECEDING_DOCUMENT_KEY IS NOT NULL
        AND p_document_rec.DOCUMENT_CONCEPT <> 'DEPENDENT_WITHOUT_REVERSAL' THEN

        -- Not allowed to change Accrual/Final for a dependent document
        -- such that the new doc status is different from the preceding document
        IF p_document_rec.status_code <> lrec_prec_document.STATUS_CODE
            AND p_document_rec.status_code <> 'ACCRUAL' THEN
                p_val_msg := 'Document Status not aligned with preceding.';
                p_val_code := 'DOCUMENT_STATUS_DEP_DIFF';
                RAISE status_not_the_same;
        END IF;
    END IF;

EXCEPTION
    WHEN status_not_the_same THEN
        IF p_silent_ind = 'N' THEN
            RAISE_APPLICATION_ERROR(-20000, 'Document ' || p_document_rec.DOCUMENT_KEY
                || ' must have the same document status as the preceding document '
                || p_document_rec.PRECEDING_DOCUMENT_KEY || ' ('
                || lrec_prec_document.STATUS_CODE ||').');
        END IF;
    WHEN status_null THEN
        IF p_silent_ind = 'N' THEN
            RAISE_APPLICATION_ERROR(-20000, 'Document ' || p_document_rec.DOCUMENT_KEY || ' does not have document status.');
        END IF;

END ValidateDocumentStatus;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  GetDocumentBusinessUnitID
-- Description    :  Gets the object id of business unit on a document.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- Required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
FUNCTION GetDocumentBusinessUnitID(p_document_key VARCHAR2)
  RETURN VARCHAR2
--</EC-DOC>
IS
  lv_doc_daytime DATE;
  lv_contract_id VARCHAR2(32);
  lv_contract_area_id VARCHAR2(32);
  lv_business_id VARCHAR2(32);
BEGIN
  lv_doc_daytime := ec_cont_document.daytime(p_document_key);
  lv_contract_id := ec_cont_document.object_id(p_document_key);
  lv_contract_area_id := ec_contract_version.contract_area_id(lv_contract_id, lv_doc_daytime, '<=');
  lv_business_id := ec_contract_area_version.business_unit_id(lv_contract_area_id, lv_doc_daytime, '<=');

  RETURN lv_business_id;
END GetDocumentBusinessUnitID;


FUNCTION getMPDPrecDoc(p_document_key VARCHAR2) RETURN VARCHAR2
  IS
  lv2_preceding VARCHAR2(32);
  CURSOR c_preceding(cp_document_key VARCHAR2) IS
       SELECT DISTINCT DOCUMENT_KEY
       FROM CONT_TRANSACTION
      WHERE TRANSACTION_KEY IN
            (SELECT CT.PRECEDING_TRANS_KEY
               FROM CONT_TRANSACTION CT
              WHERE DOCUMENT_KEY = cp_document_key) ;

  BEGIN
    FOR doc IN c_preceding(p_document_key) LOOP
      IF lv2_preceding IS NULL THEN
        lv2_preceding := doc.DOCUMENT_KEY;
      ELSE
        lv2_preceding := 'Multiple';
        EXIT;
      END IF;
    END LOOP;


    RETURN lv2_preceding;

  END getMPDPrecDoc;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetDocumentVendor
-- Description    : Determine Vendor for this document. Currently this returns the vendor whom
--                  the payment info comes from. To extend this function to more scenarios,
--                  add a new parameter "p_purpose" to indicate what kind of vendor should it
--                  return. This parameter is not added for now is because it is not clear
--                  whether currently logic can be used in a general way or not.
--
--                  Parameters "p_d_xxx" are for better performance. When the caller has the
--                  values, it should pass them in so that no extra query will be made.
---------------------------------------------------------------------------------------------------
FUNCTION GetDocumentVendor(p_object_id     VARCHAR2,
                           p_document_key  VARCHAR2,
                           p_daytime       DATE,
                           p_d_document_fin_code      VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
IS
    -- Get Contract owner vendor
    CURSOR c_co_vend (cp_contract_id VARCHAR2, cp_daytime DATE) IS
       SELECT object_id FROM company c
       WHERE class_name = 'VENDOR'
       AND c.company_id = ec_contract_version.company_id(cp_contract_id, cp_daytime, '<=');

    -- Get Contract Vendor for the Contract Owner Company
    CURSOR c_vend_co (cp_contract_id VARCHAR2, cp_co_vend_cust_id VARCHAR2) IS
       SELECT ps.company_id FROM contract_party_share ps
       WHERE ps.party_role = 'VENDOR'
       AND ps.object_id = cp_contract_id
       AND ps.company_id = cp_co_vend_cust_id;

    -- Get Contract Vendors
    CURSOR c_vend (cp_contract_id VARCHAR2) IS
       SELECT ps.company_id FROM contract_party_share ps
       WHERE ps.party_role = 'VENDOR'
       AND ps.object_id = cp_contract_id;

    lv2_fin_code VARCHAR2(32) := NVL(p_d_document_fin_code, ec_contract_version.financial_code(p_object_id, p_daytime, '<='));
    lv2_co_vend_cust_id VARCHAR2(32);
    lv2_vendor_id VARCHAR2(32);
BEGIN
    IF lv2_fin_code IN ('SALE','TA_INCOME','JOU_ENT') THEN
       -- When Sale or Tariff Income; Contract Owner Company is the Vendor to get payment info from
       FOR rsCOV IN c_co_vend(p_object_id, p_daytime) LOOP
          --this gives the object_id of the Vendor of the Contract Owner Company
          lv2_co_vend_cust_id := rsCOV.object_id;
       END LOOP;
       --check if the Contract Owner Company Vendor is a vendor in the contract
       FOR rsCV IN c_vend_co(p_object_id, lv2_co_vend_cust_id) LOOP
          lv2_vendor_id := rsCV.Company_Id;
       END LOOP;
       --check if the Contract Owner Vendor is NULL - in that case it is NOT a vendor in the contract
       if lv2_vendor_id is null THEN
         --The Contract Owner Vendor is not part of the contract
         FOR rsCV2 IN c_vend(p_object_id) LOOP
            lv2_vendor_id := rsCV2.Company_Id;
            EXIT;
         END LOOP;
       end if;
    ELSIF lv2_fin_code IN ('PURCHASE','TA_COST') THEN
       -- When Purchase or Tariff Cost; The single Vendor is the Vendor to get payment info from
       FOR rsV IN c_vend(p_object_id) LOOP
          lv2_vendor_id := rsV.Company_Id;
          EXIT;
       END LOOP;
    END IF;

    RETURN lv2_vendor_id;
END GetDocumentVendor;


PROCEDURE updateDocumentCustomer(
    p_document_key                  VARCHAR2,
    p_contract_id                   VARCHAR2,
    p_user                          VARCHAR2,
    p_customer_id                   VARCHAR2,
    p_update_cont_document          BOOLEAN DEFAULT TRUE,
    p_force_update               BOOLEAN DEFAULT FALSE)
IS
    lrec_cont_document              cont_document%ROWTYPE;
BEGIN
    lrec_cont_document := ec_cont_document.row_by_pk(p_document_key);

    updateDocumentCustomer(
        lrec_cont_document.document_key,
        lrec_cont_document.object_id,
        lrec_cont_document.contract_doc_id,
        lrec_cont_document.document_level_code,
        lrec_cont_document.document_date,
        lrec_cont_document.booking_currency_id,
        p_user,
        p_customer_id,
        p_update_cont_document,
        p_force_update);

END updateDocumentCustomer;


PROCEDURE updateDocumentCustomer(
    p_document_key                  VARCHAR2,
    p_contract_id                   VARCHAR2,
    p_contract_doc_id               VARCHAR2,
    p_document_level_code           VARCHAR2,
    p_document_daytime              DATE,
    p_document_booking_currency_id  VARCHAR2,
    p_user                          VARCHAR2,
    p_customer_id                   VARCHAR2,
    p_update_cont_document          BOOLEAN DEFAULT TRUE,
    p_force_update                  BOOLEAN DEFAULT FALSE)
IS

    lv2_contract_id contract.object_id%TYPE;
    lv2_contract_doc_id contract_doc.object_id%TYPE;
    lv2_document_level_code cont_document.document_level_code%TYPE;
    lv2_current_customer company.object_id%TYPE;
    lv2_alternate_not_allowed_msg VARCHAR(200);

    lrec_cont_doc contract_doc_version%ROWTYPE := ec_contract_doc_version.row_by_pk(p_contract_doc_id, p_document_daytime, '<=');
    lrec_contract contract_version%ROWTYPE := ec_contract_version.row_by_pk(p_contract_id, p_document_daytime, '<=');
    lv_ExcludePreceding VARCHAR2(1);

    -- Exeptions
    customer_not_found EXCEPTION;
    alternating_not_allowed EXCEPTION;

BEGIN

  IF UE_CONT_DOCUMENT.isUpdateDocumentCustomerUEE = 'TRUE'
  THEN
    -- Call instead-of user exits
    UE_CONT_DOCUMENT.updateDocumentCustomer(
        p_document_key,
        p_contract_id,
        p_contract_doc_id,
        p_document_level_code,
        p_document_daytime,
        p_document_booking_currency_id,
        p_user,
        p_customer_id,
        p_update_cont_document);
  ELSE

    ECDP_REVN_ERROR.assert_argument_not_null('p_document_key', p_document_key);

    -- Validating new customer
    IF p_customer_id IS NULL
    THEN
        RAISE customer_not_found;
    END IF;

    lv2_current_customer := EcDp_Contract_Setup.GetDocCustomerId(p_document_key);
    lv2_document_level_code := p_document_level_code;

    IF p_force_update OR NVL(lv2_current_customer, '$NULL$') <> NVL(p_customer_id, '$NULL$')
    THEN
        IF p_force_update = FALSE
            AND IsUpdatingCustomerAllowed(
                p_document_key,
                lrec_contract.ALLOW_ALT_CUST_IND,
                lrec_cont_doc.DOC_CONCEPT_CODE,
                lv2_document_level_code,
                CASE isDocumentInterfaced(p_document_key) WHEN 'Y' THEN TRUE ELSE FALSE END,
                lv2_alternate_not_allowed_msg) = 'N'
        THEN
            RAISE alternating_not_allowed;
        END IF;

        IF p_update_cont_document
        THEN
            UPDATE cont_document
            SET customer_id = p_customer_id,
                last_updated_by = p_user
            WHERE document_key = p_document_key;
        END IF;

        -- Cleanup previous customer
        DELETE cont_document_company c
        WHERE c.document_key = p_document_key
            AND c.COMPANY_ROLE = 'CUSTOMER';

        -- Applying new customer to the document
        InsNewDocumentCustomer(
            p_contract_id,
            p_contract_doc_id,
            p_document_key,
            p_customer_id,
            p_user,
            p_document_daytime,
            p_document_booking_currency_id
            );

        lv_ExcludePreceding :=
          nvl(ec_ctrl_system_attribute.attribute_text(p_document_daytime,'ALLOW_DIFF_CUST_ON_REV','<='),
          'Y');
        -- Updating customer on the line item at dist/company level
        UpdLineItemCustomer(
            p_document_key,
            p_user,
            p_contract_id,
            p_customer_id,
            lv_ExcludePreceding);

      END IF;
  END IF;

EXCEPTION
     WHEN customer_not_found
     THEN
         Raise_Application_Error(-20000, 'Please select a valid customer');
     WHEN alternating_not_allowed
     THEN
         Raise_Application_Error(
            -20000,
            'Updating customer on this document is not allowed. The reason is: '
                || lv2_alternate_not_allowed_msg);

END updateDocumentCustomer;


FUNCTION IsUpdatingCustomerAllowed(
    p_document_key VARCHAR2,
    p_allow_alt_cust_ind VARCHAR2,
    p_contract_doc_concept_code VARCHAR2,
    p_cont_document_level_code VARCHAR2,
    p_is_interfaced_document BOOLEAN,
    p_reason_message OUT VARCHAR2)
RETURN VARCHAR2
IS
BEGIN


    IF p_cont_document_level_code <> 'OPEN'
    THEN
        p_reason_message := 'The document is not OPEN';
        RETURN 'N';
    END IF;

    IF NVL(p_allow_alt_cust_ind, 'N') = 'N'
    THEN
        p_reason_message := 'The contract of the document does not allow Alternative Customer';
        RETURN 'N';
    END IF;


    IF p_is_interfaced_document and NVL(p_allow_alt_cust_ind, 'N') = 'Y'
    THEN
        RETURN 'Y';
    END IF;

    IF p_is_interfaced_document and NVL(p_allow_alt_cust_ind, 'N') = 'N'
    THEN
        p_reason_message := 'The document is not manually created';
        RETURN 'N';
    END IF;

    RETURN 'Y';

END IsUpdatingCustomerAllowed;


FUNCTION IsUpdatingCustomerAllowed(
    p_document_key VARCHAR2)
RETURN VARCHAR2
IS
    lv2_reason_message VARCHAR2(200);

    lrec_cont_document cont_document%ROWTYPE;
    lrec_cont_doc contract_doc_version%ROWTYPE;
    lrec_contract contract_version%ROWTYPE;
BEGIN
    lrec_cont_document := ec_cont_document.row_by_pk(p_document_key);
    lrec_cont_doc := ec_contract_doc_version.row_by_pk(lrec_cont_document.contract_doc_id, lrec_cont_document.daytime, '<=');
    lrec_contract := ec_contract_version.row_by_pk(lrec_cont_document.object_id, lrec_cont_document.daytime, '<=');

    RETURN IsUpdatingCustomerAllowed(
        p_document_key,
        lrec_contract.ALLOW_ALT_CUST_IND,
        lrec_cont_doc.DOC_CONCEPT_CODE,
        lrec_cont_document.document_level_code,
        CASE isDocumentInterfaced(p_document_key) WHEN 'Y' THEN TRUE ELSE FALSE END,
        lv2_reason_message);

END IsUpdatingCustomerAllowed;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  UpdLineItemCustomer
-- Description    : Apply a valid customer to the line item dist/company level
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
PROCEDURE UpdLineItemCustomer(p_document_key VARCHAR2,
                              p_user VARCHAR2,
                              p_d_object_id VARCHAR2 DEFAULT NULL,
                              p_d_customer_id VARCHAR2 DEFAULT NULL,
                              p_exclude_preceding VARCHAR2 DEFAULT 'N')

IS

  lv2_contract_id contract.object_id%TYPE;
  lv2_customer_id company.object_id%TYPE;

BEGIN

  IF UE_CONT_DOCUMENT.isUpdLineItemCustomerUEEnabled = 'TRUE' THEN
    -- Call instead-of user exits
    UE_CONT_DOCUMENT.UpdLineItemCustomer(p_document_key,
                                         p_user,
                                         p_d_object_id,
                                         p_d_customer_id);
  ELSE

      IF p_d_object_id IS NOT NULL THEN
        lv2_contract_id := p_d_object_id;
      ELSE
        lv2_contract_id := ec_cont_document.object_id(p_document_key);
      END IF;

      IF p_d_customer_id IS NOT NULL THEN
        lv2_customer_id := p_d_customer_id;
      ELSE
        lv2_customer_id := ec_cont_document.customer_id(p_document_key);
      END IF;

      UPDATE cont_li_dist_company c
        SET c.customer_id     = lv2_customer_id,
            c.last_updated_by = p_user
        WHERE c.document_key = p_document_key
          AND (ec_cont_transaction.reversed_trans_key(transaction_key)
              is null or
              p_exclude_preceding = 'N');

  END IF;

END UpdLineItemCustomer;


FUNCTION isDocumentInterfaced(p_document_key VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR c_transactions(cp_document_key VARCHAR2)
  IS
    SELECT transaction_key
    FROM cont_transaction
    WHERE document_key = cp_document_key;

  lv2_found VARCHAR2(1);

BEGIN
  lv2_found := 'N';

  FOR i_tran IN c_transactions(p_document_key)
  LOOP
    IF EcDp_transaction.isTransactionInterfaced(i_tran.transaction_key) = 'Y'
    THEN
        lv2_found := 'Y';
        EXIT;
    END IF;
  END LOOP;

  RETURN lv2_found;

END isDocumentInterfaced;


FUNCTION isCompanyOnInvoiceTitlePage(
    p_document_key                  VARCHAR2,
    p_vendor_id                     VARCHAR2,
    p_customer_id                   VARCHAR2,
    p_financial_code                VARCHAR2)
RETURN VARCHAR2
IS
    CURSOR c_owner_company_vendor_id(cp_document_key VARCHAR2)
    IS
        SELECT vendor_comp.object_id AS vendor_id
        FROM company vendor_comp,
             cont_document,
             contract_version
        WHERE cont_document.document_key = cp_document_key
            AND contract_version.object_id = cont_document.object_id
            AND contract_version.daytime <= cont_document.daytime
            AND NVL(contract_version.end_date, cont_document.daytime + 1) > cont_document.daytime
            AND vendor_comp.CLASS_NAME = 'VENDOR'
            AND vendor_comp.company_id = contract_version.company_id;

    CURSOR c_owner_company_customer_id(cp_document_key VARCHAR2)
    IS
        SELECT customer_comp.object_id AS customer_id
        FROM company customer_comp,
             cont_document,
             contract_version
        WHERE cont_document.document_key = cp_document_key
            AND contract_version.object_id = cont_document.object_id
            AND contract_version.daytime <= cont_document.daytime
            AND NVL(contract_version.end_date, cont_document.daytime + 1) > cont_document.daytime
            AND customer_comp.CLASS_NAME = 'CUSTOMER'
            AND customer_comp.company_id = contract_version.company_id;

    CURSOR c_is_receiver(cp_document_key VARCHAR2, cp_vendor_id VARCHAR2)
    IS
        SELECT receiver_id
        FROM rv_inv_pymnt_tracking
        WHERE document_key = cp_document_key
            AND receiver_id = cp_vendor_id;


    lb_is_owner_company BOOLEAN;
    lb_vendor_is_receiver BOOLEAN;
    lb_owner_company_is_receiver BOOLEAN;
    lv2_owner_company VARCHAR2(32);
    lv2_owner_company_vendor_id VARCHAR2(32);
    lv2_owner_company_customer_id VARCHAR2(32);
BEGIN
    lb_is_owner_company := FALSE;
    lb_vendor_is_receiver := FALSE;
    lb_owner_company_is_receiver := FALSE;

    -- RULES:
    -- FOR PURCHASE
    --     is a receiver (vendor)
    --         is owner company (customer) -> Y
    --         not owner company (customer) ->
    --             owner company is a receiver -> N
    --             else -> Y
    --     not a receiver (vendor) -> N
    -- FOR SALES
    --     is a receiver (vendor)
    --         is owner company (vendor) -> Y
    --         not owner company (vendor) ->
    --             owner company is a receiver -> N
    --             else -> Y
    --     not a receiver (vendor) -> N


    -- gets owner company's vendor/customer id
    FOR owner_company_id IN c_owner_company_vendor_id(p_document_key)
    LOOP
        lv2_owner_company_vendor_id := owner_company_id.vendor_id;
        EXIT;
    END LOOP;

    FOR owner_company_id IN c_owner_company_customer_id(p_document_key)
    LOOP
        lv2_owner_company_customer_id := owner_company_id.customer_id;
        EXIT;
    END LOOP;


    -- and check if the given vendor/customer is the owner company
    IF p_financial_code IN ('SALE', 'JOU_ENT', 'TA_INCOME')
    THEN
        -- Sales contract
        -- check if the given vendor/customer is the owner company
        IF p_vendor_id = lv2_owner_company_vendor_id
        THEN
            lb_is_owner_company := TRUE;
        END IF;
    ELSE
        -- purchase contract
        -- check if the given vendor/customer is the owner company
        IF p_customer_id = lv2_owner_company_customer_id
        THEN
            lb_is_owner_company := TRUE;
        END IF;
    END IF;


    -- check if the vendor is a receiver
    FOR is_receiver IN c_is_receiver(p_document_key, p_vendor_id)
    LOOP
        lb_vendor_is_receiver := TRUE;
        EXIT;
    END LOOP;

    IF lb_vendor_is_receiver
    THEN
        -- this vendor is a receiver
        -- check if it is the owner company
        IF lb_is_owner_company
        THEN
            RETURN 'Y';
        ELSE
            -- if not, check if the owner company is receiver
            FOR is_receiver IN c_is_receiver(p_document_key, lv2_owner_company_vendor_id)
            LOOP
                lb_owner_company_is_receiver := TRUE;
                EXIT;
            END LOOP;

            RETURN CASE WHEN lb_owner_company_is_receiver THEN 'N' ELSE 'Y' END;
        END IF;
    ELSE
        RETURN 'N';
    END IF;

END isCompanyOnInvoiceTitlePage;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
-- FUNCTION       : GetNonPPADocumentKey
-- Description    : Get latest non PPA document.
-- Behaviour      : When Dependent document is being created by interface,it will take NO-PPA document as preceding document key.
--                  This function will give that document key.
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetNonPPADocumentKey(
    p_transactio_key                  VARCHAR2)
RETURN VARCHAR2 IS

CURSOR c_trans (cp_transaction_key VARCHAR2) IS
select t.priority,t.transaction_key,t.preceding_trans_key,t.ppa_trans_code
           from
           (select level priority,ct.transaction_key ,ct.preceding_trans_key ,ct.ppa_trans_code from cont_transaction ct
           start with ct.transaction_key=cp_transaction_key
           CONNECT BY prior ct.preceding_trans_key=ct.transaction_key
           ORDER BY level) t
           where ppa_trans_code is null
           ORDER BY  t.priority;

lv_transaction_key VARCHAR2(32);
BEGIN
FOR res IN c_trans(p_transactio_key)
  LOOP
    lv_transaction_key:=res.transaction_key;
    EXIT;
    END LOOP;

    RETURN Ec_Cont_Transaction.document_key(lv_transaction_key);
END GetNonPPADocumentKey;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
-- FUNCTION       : IsPPADocument
-- Description    : Confirms given document is PPA document or not.
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION IsPPADocument(
    p_document_key                VARCHAR2)
RETURN VARCHAR2 IS
ln_cnt NUMBER;
BEGIN
SELECT COUNT(ct.transaction_key) INTO ln_cnt FROM cont_transaction ct
WHERE ct.document_key=p_document_key
AND ct.ppa_trans_code='PPA_PRICE';
IF ln_cnt>0 THEN
  RETURN 'Y';
  ELSE
    RETURN 'N';
    END IF;

END IsPPADocument;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------
-- FUNCTION       : IsPrecedingReverseDocOpen
-- Description    : Confirms is there any reversal document which is open.
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION IsPrecedingReverseDocOpen(
    p_transaction_key                VARCHAR2)
RETURN VARCHAR2 IS
CURSOR c_revtrans IS
SELECT LEVEL priority,ct.transaction_key ,ct.preceding_trans_key ,ct.ppa_trans_code,cd.actual_reversal_date
               FROM cont_transaction ct,cont_document cd
               WHERE ct.document_key = cd.document_key
               START WITH ct.transaction_key=p_transaction_key
               CONNECT BY prior ct.transaction_key=ct.preceding_trans_key
               ORDER BY LEVEL DESC;

lv_document_key  cont_transaction.document_key%type;
BEGIN
 FOR res IN c_revtrans LOOP

   IF (res.actual_reversal_date IS NOT NULL ) THEN
      SELECT document_key INTO lv_document_key FROM cont_transaction WHERE reversed_trans_key=res.transaction_key;
      IF(Ec_Cont_Document.document_level_code(lv_document_key)<>'BOOKED') THEN
      RETURN lv_document_key;
      END IF;
    END IF;
     EXIT;
   END LOOP;

   RETURN 'N';

END IsPrecedingReverseDocOpen;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : ValidateReportBeforeView
-- Description    : Used by the "Period Document" and "Cargo Document" screens to validate
--                  current report before clicking the "View" button.
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : none
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------
FUNCTION ValidateReportBeforeView(p_status VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
    lv_user_feedback VARCHAR2(240) := '';
BEGIN
    --Construct a feedback to the end user.
    IF p_status = 'GENERATED' THEN
        NULL; --No action. All good.
    ELSIF p_status = 'NEW' THEN
        lv_user_feedback :=
            'Error!' || chr(10) ||
            'It is not possible to view the report, because the report is still generating.' || chr(10) ||
            'Please refresh to update the status.';
    ELSIF p_status = 'ERROR' THEN
        lv_user_feedback :=
            'Error!' || chr(10) ||
            'It is not possible to view the report, because the report is generated with ''' || p_status || '''.';
    ELSE
        lv_user_feedback :=
            'Error!' || chr(10) ||
            'Unexpected status of the report: ' || p_status;
    END IF;

    RETURN lv_user_feedback;
END ValidateReportBeforeView;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : GetLastGeneratedReportNo
-- Description    : Used by SP and IN screens to get the last generated report_no when clicking
--                  the "Generate Report" button.
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : document_report
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------
FUNCTION GetLastGeneratedReportNo(p_document_id   VARCHAR2,
                                  p_document_date VARCHAR2)
RETURN VARCHAR2
IS
    CURSOR c_last_report_no(cp_document_id VARCHAR2, cp_document_date DATE) IS
    SELECT nvl(max(report_no),0) report_no
      FROM document_report
     WHERE document_id = cp_document_id
       AND nvl(document_date,trunc(Ecdp_Timestamp.getCurrentSysdate)) = nvl(cp_document_date, nvl(document_date,trunc(Ecdp_Timestamp.getCurrentSysdate)));

    ld_document_date  DATE;
    lv_last_report_no VARCHAR2(32) := '';
BEGIN
    ld_document_date := to_date(p_document_date, 'YYYY-MM-DD"T"HH24:MI:SS');

    FOR cur IN c_last_report_no(p_document_id, ld_document_date) LOOP
        lv_last_report_no := cur.report_no;
    END LOOP;

    RETURN lv_last_report_no;
EXCEPTION
    WHEN OTHERS THEN
        Raise_Application_Error(-20000, SQLERRM || '\n\n' || 'Technical:\n');
END GetLastGeneratedReportNo;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : GetLastGeneratedDocumentKey
-- Description    : Used by the "Document General" screen to get the last generated document key
--                  when clicking the "Create Document" button.
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : cont_document
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Will return the latest generated document_key for current user.
-------------------------------------------------------------------------------------------------
FUNCTION GetLastGeneratedDocumentKey(p_user_id VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
    CURSOR c_last_document_key(cp_user_id VARCHAR2) IS
    SELECT document_key
      FROM (
          SELECT document_key FROM cont_document WHERE created_by = cp_user_id ORDER BY created_date DESC
      )
     WHERE rownum <= 1;

    lv_last_document_key VARCHAR2(32) := '';
BEGIN
    FOR cur IN c_last_document_key(p_user_id) LOOP
        lv_last_document_key := cur.document_key;
    END LOOP;

    RETURN lv_last_document_key;
EXCEPTION
    WHEN OTHERS THEN
        Raise_Application_Error(-20000, SQLERRM || '\n\n' || 'Technical:\n');
END GetLastGeneratedDocumentKey;

END EcDp_Document;