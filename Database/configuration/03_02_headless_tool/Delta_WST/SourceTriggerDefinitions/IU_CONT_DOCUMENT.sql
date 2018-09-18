CREATE OR REPLACE EDITIONABLE TRIGGER "IU_CONT_DOCUMENT" 
BEFORE INSERT OR UPDATE ON CONT_DOCUMENT
FOR EACH ROW

DECLARE

invalid_level_change EXCEPTION;
invalid_document_date EXCEPTION;
invalid_exchange_rate EXCEPTION;
invalid_booking_period EXCEPTION;
missing_booking_period EXCEPTION;
new_source_split_share EXCEPTION;
tracing_document  EXCEPTION;


CURSOR c_Tracing_Docs is
   SELECT TO_TYPE type,
          TO_REFERENCE_ID reference_id
     FROM DATASET_FLOW_DOC_CONN
                        WHERE from_reference_id = :new.document_key
                          AND from_type = 'CONT_DOCUMENT';

CURSOR c_document_vendor(pc_object_id VARCHAR2, pc_document_id VARCHAR2) IS
   SELECT cdc.* FROM cont_document_company cdc, company c
   WHERE cdc.object_id = pc_object_id
   AND document_key = pc_document_id
   AND cdc.company_id = c.object_id
   AND c.class_name = 'VENDOR';

CURSOR c_document_vendor2(pc_object_id VARCHAR2, pc_document_id VARCHAR2) IS
   SELECT cdc.* FROM cont_document_company cdc, company c
   WHERE cdc.object_id = pc_object_id
   AND document_key = pc_document_id
   AND cdc.company_id = c.object_id
   AND c.class_name = 'VENDOR';

CURSOR c_document_customer(pc_object_id VARCHAR2, pc_document_id VARCHAR2) IS
   SELECT cdc.* FROM cont_document_company cdc, company c
   WHERE cdc.object_id = pc_object_id
   AND document_key = pc_document_id
   AND cdc.company_id = c.object_id
   AND c.class_name = 'CUSTOMER';

lv2_payment_scheme_id   VARCHAR2(32);
lv2_customer_id         VARCHAR2(32);
lv2_vendor_id           VARCHAR2(32);
lv2_inv_string          VARCHAR2(2000);
lv2_user                VARCHAR2(32);
lv2_tmp                 BOOLEAN;
lv2_ifac_doc_status     VARCHAR2(32);
lv2_reversal_recreation VARCHAR2(32);

ln_payment       NUMBER;
ln_payment_total NUMBER;
lv_msg           VARCHAR2(4000);

lv2_system_attribute    VARCHAR2(32);
lv2_new_status          VARCHAR2(32);
v_T_TABLE_CONT_DOCUMENT T_TABLE_CONT_DOCUMENT;

TYPE t_status_list IS TABLE OF VARCHAR2(32);
ltab_status_list t_status_list := t_status_list('OPEN', 'VALID1', 'VALID2', 'TRANSFER', 'BOOKED');

ld_contract_date DATE := ec_contract.start_date(:New.object_id);
lb_set_to_next   BOOLEAN := false;

BEGIN

   v_T_TABLE_CONT_DOCUMENT := T_TABLE_CONT_DOCUMENT();

   lv2_user := ecdp_context.getAppUser();

   IF Inserting THEN

      IF Inserting THEN
        :new.record_status := 'P';
        IF :new.created_by IS NULL THEN
           :new.created_by := lv2_user;
           :new.open_user_id := lv2_user;
        END IF;
        :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
        :new.rev_no := 0;

       END IF;

    ELSIF Updating THEN

         IF :New.last_updated_by = 'SYSTEM' THEN
            lv2_user := :Old.last_updated_by; -- set to old
         ELSE
            lv2_user := nvl(:New.last_updated_by,lv2_user); -- set to new
         END IF;

         IF nvl(:New.Document_Level_Code,'xx') != nvl(:old.Document_Level_Code,'xx')  THEN
            IF :New.Document_Level_Code = 'OPEN' and :Old.document_level_code !='VALID1' then
              RAISE_APPLICATION_ERROR(-20001, 'Can not set the document to Open unless it is at level Valid 1. It is currently' || ec_prosty_codes.code_text(:old.document_level_code,'DOCUMENT_LEVEL_CODE'));
            ELSIF :New.Document_Level_Code = 'VALID1' and :Old.document_level_code !='OPEN' then
              RAISE_APPLICATION_ERROR(-20001,'Can not set the document to Valid 1 because it is ' || ec_prosty_codes.code_text(:old.document_level_code,'DOCUMENT_LEVEL_CODE') || ', not Open.');
            END IF;
         END IF;

         -- to allow updateing from ecdp_sap_interface package after transfer
         IF (NOT Updating('FIN_INTERFACE_IND')) AND (NOT Updating('TRANSFER_DATE')) THEN

               IF (Updating('DOC_BOOKING_TOTAL') and :New.AMOUNT_IN_WORDS_IND = 'Y') THEN

                  :New.AMOUNT_IN_WORDS := Ecdp_Document.ConvertAmountToWords(:New.DOC_BOOKING_TOTAL,:New.BOOKING_CURRENCY_CODE,:New.DAYTIME);

               END IF;

               -- Check that documents will be set both forward and back...
               IF (Updating('SET_TO_PREV_IND') AND Updating('SET_TO_NEXT_IND')) THEN
                    IF (:New.SET_TO_PREV_IND = 'Y' AND :New.SET_TO_NEXT_IND = 'Y') THEN
                         Raise invalid_level_change;
                    END IF;
               END IF;

               -- setting level downwards
               IF Updating('SET_TO_PREV_IND') AND :New.SET_TO_PREV_IND = 'Y' THEN

                  FOR ln_cnt IN 1..(ltab_status_list.COUNT) LOOP

                      IF ltab_status_list(ln_cnt) = :Old.document_level_code THEN


                         IF ln_cnt = 2 THEN

                            :New.document_level_code := ltab_status_list(ln_cnt - 1);

                            -- Reset all processing columns...
                            :New.VALID1_USER_ID := NULL;


                         ELSIF ln_cnt = 3 THEN -- special case for VALID2

                            -- straight back to open
                            :New.document_level_code := ltab_status_list(1);

                            -- Reset all processing columns...
                            :New.VALID2_USER_ID := NULL;
                            :New.VALID1_USER_ID := NULL;


                         ELSIF ln_cnt = 4 THEN -- special case for TRANSFER

                            :New.document_level_code := ltab_status_list(1);

                            -- Reset all processing columns...
                            :New.valid1_user_id := NULL;
                            :New.valid2_user_id := NULL;
                            :New.transfer_user_id := NULL;
                            :New.transfer_date := NULL;
                            :New.fin_interface_file := NULL;
                            :New.booking_date := NULL;
                            :New.booking_period := NULL;

                            IF :New.status_code = 'ACCRUAL' THEN
                                 :New.reversal_code := NULL;
                                 :New.reversal_date := NULL;
                            END IF;

                         END IF;

                      END IF;

                 END LOOP;



                 -- Whenever setting document back to OPEN, records in CONT_PAY_TRACKING must be deleted
                 DELETE FROM cont_pay_tracking_item
                 WHERE document_key = :New.document_key;

                 DELETE FROM cont_pay_tracking
                 WHERE document_key = :New.document_key;

                 -- Whenever setting document back to OPEN, records in CONT_POSTINGS must be deleted
                 DELETE FROM cont_postings
                 WHERE document_key = :New.document_key;

                 DELETE FROM cont_postings_aggregated
                 WHERE document_key = :New.document_key;


                 -- reset, no need to store
                 :New.SET_TO_PREV_IND := NULL;

               ELSIF Updating('SET_TO_NEXT_IND') AND :New.SET_TO_NEXT_IND = 'Y' THEN

                  FOR ln_cnt IN 1..(ltab_status_list.COUNT) LOOP

                      IF ltab_status_list(ln_cnt) = :Old.document_level_code THEN

                         IF ln_cnt < ltab_status_list.COUNT THEN

                            :New.document_level_code := ltab_status_list(ln_cnt + 1);
                            :New.SET_TO_NEXT_IND := NULL;
                            lb_set_to_next := true;

                         END IF;

                      END IF;

                  END LOOP;


               END IF;

              IF Updating('PAY_DATE') THEN

                         UPDATE cont_document_company cdv
                        SET    due_date = :New.PAY_DATE
                               ,last_updated_by = 'SYSTEM'
                        WHERE  object_id = :New.object_id
                        AND    document_key = :New.document_key;

               END IF;

               IF Updating('DAYTIME') THEN

                         UPDATE cont_li_dist_company
                         SET     daytime = :New.daytime
                                 ,last_updated_by = 'SYSTEM'
                         WHERE  object_id = :New.object_id
                         AND    document_key = :New.document_key;

               END IF;

               -- correct level change ?
              IF Nvl(:Old.DOCUMENT_LEVEL_CODE,'XXX') <> Nvl(:New.DOCUMENT_LEVEL_CODE,'XXX') THEN

                      FOR ln_cnt IN 1..(ltab_status_list.COUNT) LOOP

                          IF ltab_status_list(ln_cnt) = :Old.document_level_code THEN

                             IF ln_cnt = 1 THEN

                                IF NOT ltab_status_list(ln_cnt + 1) = :New.document_level_code THEN

                                  RAISE invalid_level_change;

                                END IF;

                             ELSIF ln_cnt < ltab_status_list.COUNT THEN

                                IF  ( ltab_status_list(ln_cnt + 1) = :New.document_level_code )
                                    OR ( ltab_status_list(ln_cnt - 1) = :New.document_level_code AND :New.SET_TO_PREV_IND = 'Y')
                                    OR (ln_cnt <= 4 AND :New.document_level_code = ltab_status_list(1) ) THEN

                                    NULL; -- valid change

                                ELSE

                                  RAISE invalid_level_change;

                                END IF;

                             ELSE

                                RAISE invalid_level_change; -- cannot change from highest

                             END IF;

                          END IF;

                      END LOOP;

                     -- update reallocation no 0 to previous level before document level change is done
                     IF UPDATING ('SET_TO_PREV_IND') OR :New.DOCUMENT_LEVEL_CODE = 'OPEN' THEN
                        -- reset, no need to store
                        :New.SET_TO_PREV_IND := NULL;

                     END IF;

                     -- This check will raise an error if new qtys in interface tables has arrived
                     IF (:New.DOCUMENT_LEVEL_CODE IN ('VALID1','VALID2','TRANSFER')
                         AND (lb_set_to_next OR (:Old.DOCUMENT_LEVEL_CODE = 'OPEN' AND :New.DOCUMENT_LEVEL_CODE = 'VALID1'))) THEN
                         IF NOT(:old.DOCUMENT_LEVEL_CODE='TRANSFER' AND :old.FIN_INTERFACE_FILE IS NOT NULL) THEN

                            lv2_tmp := EcDp_Document.IsIfacUpdated(:New.document_key,
                                                                   NULL,
                                                                   'Y',
                                                                   :New.contract_doc_id,
                                                                   :New.document_level_code,
                                                                   :New.status_code,
                                                                   'Y', -- Set the non_booked_accrual_found to 'Y' since we are changing its status
                                                                   'Y',
                                                                   :New.daytime,
                                                                   :New.doc_scope,
                                                                   lv2_ifac_doc_status);
                         END IF;
                     END IF;


                     IF UPDATING ('DOCUMENT_LEVEL_CODE') AND :New.DOCUMENT_LEVEL_CODE IN ('OPEN','VALID1') THEN
                        -- Deleting pay tracking items
                        DELETE cont_pay_tracking_item pi
                         WHERE pi.object_id = :New.object_id
                           AND pi.document_key = :New.document_key; /* OHA MVS
                           AND pi.customer_id = :New.customer_id; */

                        DELETE cont_pay_tracking p
                        WHERE p.object_id = :New.object_id
                           AND p.document_key = :New.document_key; /* OHA MVS
                           AND p.customer_id = :New.customer_id;*/
                     END IF;


                     IF UPDATING ('DOCUMENT_LEVEL_CODE') AND :New.DOCUMENT_LEVEL_CODE IN ('OPEN') THEN

                      IF :Old.DOCUMENT_LEVEL_CODE = 'BOOKED' THEN

                         lv_msg := ecdp_dataset_flow.UpdateDocFlowStatus('CONT_DOCUMENT',:new.document_key,'P',lv2_user,true,'A');

                      ELSE

                         lv_msg := ecdp_dataset_flow.UpdateDocFlowStatus('CONT_DOCUMENT',:new.document_key,'P',lv2_user,true,'V');

                      END IF;

                      IF lv_msg IS NOT NULL THEN
                        RAISE tracing_document;
                      END IF;


                       DELETE FROM cont_postings
                       WHERE document_key = :New.document_key;

                       DELETE FROM cont_postings_aggregated
                       WHERE document_key = :New.document_key;

                     END IF;

                     -- Validate Split Shares, the can not be null
                     -- Write Payment Tracking Items based on configured Payment Scheme on Document Setup
                     IF :New.DOCUMENT_LEVEL_CODE = 'VALID1' THEN

                         lv_msg := ecdp_dataset_flow.UpdateDocFlowStatus('CONT_DOCUMENT',:new.document_key,'V',lv2_user,true, 'P');

                         IF  lv_msg IS NOT NULL THEN
                           RAISE tracing_document;
                         END IF;

                         EcDp_Document.ValidateSplitShare(:New.object_id, :New.document_key, :New.daytime);

                         -- Check if new splits are available:
                         IF EcDp_Document.isDocSourceSplitShareUpdated(:New.document_key) = 'Y' THEN
                           RAISE new_source_split_share;
                         END IF;

                         IF ue_cont_document.isUpdateDocumentCustomerUEE = 'TRUE' THEN

                            ue_cont_document.ValidateDocumentCustomer(:new.document_key);

                         END IF;

                     END IF;

                     IF (:New.DOCUMENT_LEVEL_CODE = 'VALID1' AND :New.status_code = 'FINAL' AND :New.actual_reversal_date IS NULL) THEN

                        IF :New.Financial_code IN ('SALE','TA_INCOME','JOU_ENT') THEN
                             BEGIN
                                select company_id into lv2_vendor_id from cont_document_company
                                   where document_key = :New.document_key
                                   and company_role = 'VENDOR'
                                   and ec_company.company_id(company_id) = :New.owner_company_id;
                             EXCEPTION
                               WHEN NO_DATA_FOUND THEN
                                  -- When the contract owner company vendor is not found in document,
                                  -- use the first vendor found in document as fallback
                                  select MAX(company_id) into lv2_vendor_id from cont_document_company
                                     where document_key = :New.document_key
                                     and company_role = 'VENDOR';
                             END;

                            FOR CurDocCust In c_document_customer(:New.object_id, :New.document_key) LOOP

                              lv2_payment_scheme_id := ec_cont_document_company.payment_scheme_id(:new.document_key, lv2_vendor_id);

                              ln_payment_total := 0;

                              FOR CurDocVend IN c_document_vendor(:New.object_id, :New.document_key) LOOP
                                  IF CurDocVend.exvat_receiver_id = lv2_vendor_id THEN
                                     select sum(ll.booking_value) into ln_payment
                                     from cont_li_dist_company ll
                                     where ll.document_key = :New.document_key and ll.vendor_id = CurDocVend.company_id and ll.customer_id = CurDocCust.company_id;
                                     ln_payment_total := nvl(ln_payment_total,0) + nvl(ln_payment,0);
                                  END IF;
                                  IF CurDocVend.vat_receiver_id = lv2_vendor_id THEN

                                     select sum(ll.booking_vat_value) into ln_payment
                                     from cont_li_dist_company ll
                                     where ll.document_key = :New.document_key and ll.vendor_id = CurDocVend.company_id and ll.customer_id = CurDocCust.company_id;
                                     ln_payment_total := nvl(ln_payment_total,0) + nvl(ln_payment,0);
                                  END IF;
                              END LOOP;

                              EcDp_Payment_Scheme.WritePayTrackItems(:new.object_id,
                                                                      :new.document_key,
                                                                      lv2_payment_scheme_id,
                                                                      :new.document_type,
                                                                      :new.valid1_user_id,
                                                                      :new.owner_company_id,
                                                                      CurDocCust.company_id,
                                                                      lv2_vendor_id,
                                                                      :new.booking_currency_id,
                                                                      ln_payment_total,
                                                                      :new.contract_reference,
                                                                      :new.daytime);

                            END LOOP;
                         ELSE
                              -- Purchases must also be able to read the payment scheme and have multiple vendors

                              FOR CurDocCust In c_document_customer(:New.object_id, :New.document_key) LOOP

                                FOR CurDocVend IN c_document_vendor(:New.object_id, :New.document_key) LOOP

                                    lv2_vendor_id := CurDocVend.Company_Id;

                                    lv2_payment_scheme_id := null;

                                    lv2_payment_scheme_id := ec_cont_document_company.payment_scheme_id(:new.document_key, lv2_vendor_id);

                                    ln_payment_total := 0;

                                    FOR CurDocVend2 IN c_document_vendor2(:New.object_id, :New.document_key) LOOP

                                          IF CurDocVend2.exvat_receiver_id = lv2_vendor_id THEN

                                             select sum(ll.booking_value) into ln_payment
                                             from cont_li_dist_company ll
                                             where ll.document_key = :New.document_key and ll.vendor_id = CurDocVend2.company_id and ll.customer_id = CurDocCust.company_id;
                                             ln_payment_total := nvl(ln_payment_total,0) + nvl(ln_payment,0);
                                          END IF;
                                          IF CurDocVend2.vat_receiver_id = lv2_vendor_id  THEN

                                             select sum(ll.booking_vat_value) into ln_payment
                                             from cont_li_dist_company ll
                                             where ll.document_key = :New.document_key and ll.vendor_id = CurDocVend2.company_id and ll.customer_id = CurDocCust.company_id;
                                             ln_payment_total := nvl(ln_payment_total,0) + nvl(ln_payment,0);
                                          END IF;
                                    END LOOP;

                                    IF ln_payment_total <> 0 THEN
                                    EcDp_Payment_Scheme.WritePayTrackItems(:new.object_id,
                                                                      :new.document_key,
                                                                      lv2_payment_scheme_id,
                                                                      :new.document_type,
                                                                      :new.valid1_user_id,
                                                                      :new.owner_company_id,
                                                                      lv2_vendor_id,
                                                                      CurDocCust.company_id,
                                                                      :new.booking_currency_id,
                                                                      ln_payment_total,
                                                                      :new.contract_reference,
                                                                      :new.daytime);
                                    END IF;
                                END LOOP;
                              END LOOP;
                         END IF;

                     END IF;


                     IF :New.DOCUMENT_LEVEL_CODE = 'VALID1' THEN

                        -- NOTE! Main validation of document is performed upon save in Process - Document General,
                        -- BA DocumentGeneralBusinessAction is calling ecdp_document.ValidateDocument.
                        -- This is done AFTER updating cont_document table (and running this trigger).

                        :New.VALID1_USER_ID := lv2_user;

                        -- set all financial data for transfer to accounting system
                        IF (:New.book_document_ind = 'Y') OR (ec_ctrl_system_attribute.attribute_text(:New.daytime,'ALWAYS_GEN_POSTING','<=') = 'Y') THEN -- Book to financial system must be set to Yes
                           EcDp_Contract_Setup.GenFinPostingData(
                             :New.object_id,
                             :New.document_key,
                             :New.financial_code,
                             :New.status_code,
                             :New.doc_booking_total,
                             :New.owner_company_id,
                             :New.daytime,
                             :New.last_updated_by);


                           IF UE_AGGREGATE_FIN_POSTING.isUserExitEnabled = 'TRUE' THEN
                             Ue_Aggregate_Fin_Posting.AggregateFinPostingData(
                                 :New.object_id,
                                 :New.document_key,
                                 :New.document_concept,
                                 :New.financial_code,
                                 :New.status_code,
                                 :New.doc_booking_total,
                                 :New.owner_company_id,
                                 :New.daytime,
                                 :New.document_date,
                                 :New.last_updated_by);
                           ELSE
                             EcDp_Contract_Setup.AggregateFinPostingData(
                                 :New.object_id,
                                 :New.document_key,
                                 :New.document_concept,
                                 :New.financial_code,
                                 :New.status_code,
                                 :New.doc_booking_total,
                                 :New.owner_company_id,
                                 :New.daytime,
                                 :New.document_date,
                                 :New.last_updated_by);
                           END IF;

                         END IF; -- Book to financial system ?

                     END IF; -- VALID1


                     IF :New.DOCUMENT_LEVEL_CODE IN ('VALID2') THEN
                        -- Assign document_no based on string on document_setup
                           IF (:New.status_code = 'FINAL') THEN
                                lv2_inv_string := :New.doc_number_format_final;
                          ELSIF (:New.status_code = 'ACCRUAL') THEN
                                lv2_inv_string := :New.doc_number_format_accrual;
                          END IF;


                          IF (INSTR(lv2_inv_string, '$MANUAL') > 0 ) THEN

                             IF (lv2_inv_string <> '$MANUAL') THEN
                                 Raise_Application_Error(-20000,'$MANUAL invoice number cannot be combined with additional info at the invoice number setup.');
                             END IF;

                          ELSIF :New.document_number  IS NULL THEN

                             :New.document_number := Ecdp_Document.GetInvoiceNo( :New.document_key,
                                                                      :New.daytime,
                                                                      :New.document_date,
                                                                      :New.status_code,
                                                                      :New.owner_company_id,
                                                                      :New.doc_sequence_final_id,
                                                                      :New.doc_sequence_accrual_id,
                                                                      :New.doc_number_format_final,
                                                                      :New.doc_number_format_accrual,
                                                                      :New.financial_code);
                        END IF;

                        -- determine booking period
                        IF ec_ctrl_system_attribute.attribute_text(:New.DAYTIME,'SELECT_BOOKING_PERIOD','<=') = 'Y' THEN
                            -- take current open period
                           :New.BOOKING_PERIOD := EcDp_Fin_Period.GetCurrOpenPeriodByObject(:New.object_id, :New.daytime, ec_contract_version.financial_code(:New.object_id, :New.daytime, '<='),'BOOKING',:New.document_key,:New.Document_Date);

                           IF ec_ctrl_system_attribute.attribute_text(:New.DAYTIME,'DEFAULT_BOOKING_PERIOD','<=') = 'BY_DOC_DATE' THEN

                               IF :New.BOOKING_PERIOD <= trunc(:New.document_date,'month') THEN
                                 IF EcDp_Fin_Period.chkPeriodExistByObject(:New.object_id, :New.daytime, :New.document_date, ec_contract_version.financial_code(:New.object_id, :New.daytime, '<=')) IS NOT NULL THEN
                                    :New.BOOKING_PERIOD := trunc(:New.document_date,'month');
                                 END IF;
                              END IF;
                           END IF;
                        END IF;

                        :New.VALID2_USER_ID := lv2_user;


                        IF Ue_Cont_Document.isValid1Valid2UEEnabled = 'TRUE' THEN
                             ue_cont_document.valid1valid2(:New.object_id,
                                                       :New.document_key,
                                                       :New.financial_code,
                                                       :New.status_code,
                                                       :New.owner_company_id,
                                                       :New.Document_Date,
                                                       :New.Daytime,
                                                       lv2_user);
                        END IF;

                     END IF; -- valid 2


                     IF :New.DOCUMENT_LEVEL_CODE IN ('TRANSFER') THEN

                        -- determine booking period
                        IF :New.BOOKING_PERIOD IS NULL THEN

                           -- take current open period
                           :New.BOOKING_PERIOD := EcDp_Fin_Period.GetCurrOpenPeriodByObject(:New.object_id, :New.daytime, ec_contract_version.financial_code(:New.object_id, :New.daytime, '<='),'BOOKING',:new.document_key,:new.document_date);
                           IF :New.BOOKING_PERIOD IS NULL THEN  --no booking period was found!
                             RAISE missing_booking_period;
                           END IF;

                        --check for preset booking period, if it is closed, raise error
                        ELSIF :New.BOOKING_PERIOD < EcDp_Fin_Period.GetCurrOpenPeriodByObject(:New.object_id, :New.daytime, ec_contract_version.financial_code(:New.object_id, :New.daytime, '<='),'BOOKING',:new.document_key,:new.document_date) THEN

                            RAISE invalid_booking_period;

                        END IF;

                        -- set transfer to last date in open period if older
                        IF Trunc(Ecdp_Timestamp.getCurrentSysdate,'MM') >  :New.BOOKING_PERIOD THEN

                            :New.BOOKING_DATE := Last_Day(:New.BOOKING_PERIOD);

                        ELSIF (Trunc(Ecdp_Timestamp.getCurrentSysdate,'MM') <  :New.BOOKING_PERIOD) THEN

                            :New.BOOKING_DATE := Trunc(:New.BOOKING_PERIOD, 'MM');

                        ELSE

                            :New.BOOKING_DATE := Trunc(Ecdp_Timestamp.getCurrentSysdate);

                        END IF;

                        -- set revseral info for accrual doc
                        IF :New.status_code = 'ACCRUAL' THEN
                             :New.reversal_code := ec_ctrl_system_attribute.attribute_text(:NEW.DAYTIME, 'DEFAULT_REVERSAL_CODE', '<=');
                             :New.reversal_date := Last_Day(:New.BOOKING_DATE) + ec_ctrl_system_attribute.attribute_value(:NEW.DAYTIME, 'DEFAULT_REVERSAL_DATE', '<=');
                        END IF;

                        -- call user exit validation to get  a new status.
                        :New.TRANSFER_USER_ID := lv2_user;
                        lv2_new_status := NULL;
                        v_T_TABLE_CONT_DOCUMENT.extend;
                        v_T_TABLE_CONT_DOCUMENT(1) := T_CONT_DOCUMENT(
                                                        :New.OBJECT_ID
                                                        ,:New.DAYTIME
                                                        ,:New.DOCUMENT_DATE
                                                        ,:New.DOCUMENT_KEY
                                                        ,:New.CONTRACT_DOC_ID
                                                        ,:New.DOCUMENT_TYPE
                                                        ,:New.PRECEDING_DOCUMENT_KEY
                                                        ,:New.PARENT_DOCUMENT_KEY
                                                        ,:New.OPEN_USER_ID
                                                        ,:New.VALID1_USER_ID
                                                        ,:New.VALID2_USER_ID
                                                        ,:New.TRANSFER_USER_ID
                                                        ,:New.BOOKED_USER_ID
                                                        ,:New.REVERSAL_CODE
                                                        ,:New.PERFORM_CALC_IND
                                                        ,:New.REVERSAL_DATE
                                                        ,:New.TRANSFER_DATE
                                                        ,:New.BOOKING_DATE
                                                        ,:New.REV_ACCRUAL_DATE
                                                        ,:New.SET_TO_BOOKED_DATE
                                                        ,:New.ACTUAL_REVERSAL_DATE
                                                        ,:New.DOCUMENT_NUMBER
                                                        ,:New.BOOK_DOCUMENT_IND
                                                        ,:New.DOCUMENT_LEVEL_CODE
                                                        ,:New.STATUS_CODE
                                                        ,:New.CONTRACT_AREA_CODE
                                                        ,:New.CONTRACT_GROUP_CODE
                                                        ,:New.CONTRACT_TERM_CODE
                                                        ,:New.OWNER_COMPANY_ID
                                                        ,:New.BOOKING_CURRENCY_ID
                                                        ,:New.MEMO_CURRENCY_ID
                                                        ,:New.PRICE_BASIS
                                                        ,:New.DOC_BOOKING_TOTAL
                                                        ,:New.DOC_MEMO_TOTAL
                                                        ,:New.PAY_DATE
                                                        ,:New.FINANCIAL_CODE
                                                        ,:New.FIN_INTERFACE_FILE
                                                        ,:New.BOOKING_PERIOD
                                                        ,:New.TAXABLE_IND
                                                        ,:New.INT_BASE_AMOUNT_SRC
                                                        ,:New.DOCUMENT_CONCEPT
                                                        ,:New.DOCUMENT_RECEIVED_DATE
                                                        ,:New.DOC_RECEIVED_BASE_DATE
                                                        ,:New.DOC_GROUP_TOTAL
                                                        ,:New.DOC_LOCAL_TOTAL
                                                        ,:New.REVERSAL_IND
                                                        ,:New.PAYMENT_SCHEME_ID
                                                        ,:New.ERP_FEEDBACK_DATE
                                                        ,:New.ERP_FEEDBACK_ERROR_MESS
                                                        ,:New.ERP_FEEDBACK_REF
                                                        ,:New.ERP_FEEDBACK_STATUS
                                                        ,:New.EXT_DOCUMENT_KEY
                                                        ,:New.PRODUCTION_PERIOD
                                                        ,:New.PROCESSING_PERIOD
                                                        ,:New.SINGLE_PARCEL_DOC_IND
                                                        ,:New.DOC_SCOPE
                                                        ,:New.CUSTOMER_ID
                                                   );

                        IF (Ue_Cont_Document.isTransferUEEnabled = 'TRUE' AND lb_set_to_next ) THEN
                             lv2_new_status := ue_cont_document.GetNewStatus(v_T_TABLE_CONT_DOCUMENT);

                            IF lv2_new_status is NOT NULL THEN
                              IF lv2_new_status IN ('OPEN', 'VALID1', 'VALID2', 'TRANSFER', 'BOOKED') THEN
                                :New.DOCUMENT_LEVEL_CODE := lv2_new_status;
                              ELSE
                                raise invalid_level_change;
                              END IF;
                            END IF;
                        END IF;

                     END IF; -- transfer


                     IF :New.DOCUMENT_LEVEL_CODE IN ('BOOKED') THEN

                        lv_msg := ecdp_dataset_flow.UpdateDocFlowStatus('CONT_DOCUMENT',:new.document_key,'A',lv2_user,true, 'V');

                        if lv_msg is not null then
                          raise tracing_document;
                        end if;

                        :New.BOOKED_USER_ID := lv2_user;
                        :New.SET_TO_BOOKED_DATE := Ecdp_Timestamp.getCurrentSysdate;

                        SELECT attribute_text INTO lv2_system_attribute FROM ctrl_system_attribute
                        WHERE attribute_type ='VO_STIM_CASCADE_TABLE';

                        -- update VO Stream item values
                        IF :NEW.ERP_FEEDBACK_REF IS NOT NULL AND lv2_system_attribute = 'STIM_CASCADE_ASYNCH' THEN
                            EcDp_Transaction.UpdTransQtyInVO(:New.object_id, :New.document_key, :New.last_updated_by, :New.document_type, 1, :New.status_code, 'Y');
                        ELSE
                            EcDp_Transaction.UpdTransQtyInVO(:New.object_id, :New.document_key, :New.last_updated_by, :New.document_type, 1, :New.status_code, 'N');
                        END IF;

                       END IF;



                     -- update reallocation no 0 to next level after document level change is done
                     IF Updating('SET_TO_NEXT_IND') OR Updating('DOCUMENT_LEVEL_CODE') THEN

                        -- reset, no need to store
                        :New.SET_TO_NEXT_IND := NULL;
                        lb_set_to_next := true;

                     END IF;


               END IF; -- level change


               -- do this always

               -- SSK MVS
               IF Updating('PAY_DATE') THEN

                        -- Update any customer/vendor pay amounts - very consistent
                        UPDATE cont_document_company cdv
                        SET    pay_date = :New.PAY_DATE
                               ,last_updated_by = 'SYSTEM'
                        WHERE  object_id = :New.object_id
                        AND    document_key = :New.document_key
                        AND    ec_company.company_id(company_id) = :new.owner_company_id;

               END IF;

               IF Updating('PAYMENT_DUE_BASE_DATE') THEN

                        -- Update any customer/vendor pay amounts - very consistent
                        UPDATE cont_document_company cdv
                        SET    payment_due_base_date = :New.PAYMENT_DUE_BASE_DATE
                               ,last_updated_by = 'SYSTEM'
                        WHERE  object_id = :New.object_id
                        AND    document_key = :New.document_key
                        AND    ec_company.company_id(company_id) = :new.owner_company_id;

               END IF;

               IF UPDATING('CUSTOMER_ID') AND NVL(:NEW.customer_id, '$NULL$') <> NVL(:OLD.customer_id, '$NULL$')
               THEN
                       -- For the last parameter: We cannot let the updateDocumentCustomer to
                       -- update customer_id on cont_document, this trigger will do the job.
                       EcDp_Document.updateDocumentCustomer(
                           :NEW.document_key,
                           :NEW.object_id,
                           :NEW.contract_doc_id,
                           NVL(:NEW.document_level_code,'OPEN'),
                           :NEW.daytime,
                           :NEW.BOOKING_CURRENCY_ID,
                           'SYSTEM',
                           :NEW.customer_id,
                           FALSE,
                           TRUE  );
               END IF;

               -- set debit / credit indicator
               IF :New.FINANCIAL_CODE IN ('SALE','TA_INCOME','JOU_ENT') THEN

                  IF :New.DOC_BOOKING_TOTAL >= 0 THEN

                     :New.debit_credit_ind := 'D';
                     :New.cur_doc_template_name := :New.doc_template_name;

                  ELSE

                     :New.debit_credit_ind := 'C';
                     :New.cur_doc_template_name := :New.inv_doc_template_name;

                  END IF;

               ELSIF :New.FINANCIAL_CODE IN ('PURCHASE','TA_COST') THEN

                  IF :New.DOC_BOOKING_TOTAL >= 0 THEN

                     :New.debit_credit_ind := 'C';
                     :New.cur_doc_template_name := :New.doc_template_name;

                  ELSE

                     :New.debit_credit_ind := 'D';
                     :New.cur_doc_template_name := :New.inv_doc_template_name;

                  END IF;

               END IF;


               -- Any other change only when level is open

               IF Nvl(:Old.DOCUMENT_LEVEL_CODE,'XXX') = Nvl(:New.DOCUMENT_LEVEL_CODE,'XXX') THEN -- allow level changes

                  IF :New.DOCUMENT_LEVEL_CODE <> ltab_status_list(1) THEN -- document not open

                    IF
                       Updating('REVERSAL_DATE') OR
                       Updating('REVERSAL_CODE') THEN

                       NULL; -- OK

                    END IF;

                  ELSE -- do further processing

                     IF Updating('DOCUMENT_DATE') THEN
                       IF (nvl(:New.DOCUMENT_DATE, ld_contract_date) < ld_contract_date) THEN
                           RAISE invalid_document_date;
                       END IF;
                     END IF;

                     IF Updating('DOC_BOOKING_TOTAL') THEN

                        IF :New.FINANCIAL_CODE IN ('SALE','TA_INCOME','JOU_ENT') THEN

                            FOR CurDocVend IN c_document_vendor(:New.object_id, :New.document_key) LOOP
                              UPDATE cont_document_company cdv
                              SET    amount =  (select sum(ll.booking_value)+ sum(ll.booking_vat_value)
                                                                      from cont_li_dist_company ll
                                                                       where ll.document_key = CurDocVend.document_key and vendor_id = CurDocVend.company_id )
                                     --,due_date = :New.PAY_DATE
                                     ,last_updated_by = 'SYSTEM'
                              WHERE  object_id = CurDocVend.object_id
                              AND    document_key = CurDocVend.document_key
                              AND    company_id = CurDocVend.company_id;

                            END LOOP;

                            FOR CurDocCust IN c_document_customer(:New.object_id, :New.document_key) LOOP
                                 -- Update any customer amounts - very consistent
                               -- Changed from :New.DOC_PRICING_TOTAL to :New.DOC_BOOKING_TOTAL
                                UPDATE cont_document_company cdr
                                SET    amount =  cdr.split_share * :New.DOC_BOOKING_TOTAL /100
                                       --,due_date = :New.PAY_DATE
                                       ,last_updated_by = 'SYSTEM'
                                WHERE  object_id = CurDocCust.object_id
                                AND    document_key = CurDocCust.document_key
                                AND    company_id = CurDocCust.company_id;

                            END LOOP;
                         ELSE
                            FOR CurDocCust IN c_document_customer(:New.object_id, :New.document_key) LOOP
                              UPDATE cont_document_company cdv
                              SET    amount =  (select sum(ll.booking_value) + sum(ll.booking_vat_value)
                                                                      from cont_li_dist_company ll
                                                                       where ll.document_key = CurDocCust.document_key and customer_id = CurDocCust.company_id )
                                     --,due_date = :New.PAY_DATE
                                     ,last_updated_by = 'SYSTEM'
                              WHERE  object_id = CurDocCust.object_id
                              AND    document_key = CurDocCust.document_key
                              AND    company_id = CurDocCust.company_id;

                            END LOOP;

                            FOR CurDocVend IN c_document_vendor(:New.object_id, :New.document_key) LOOP
                                UPDATE cont_document_company cdr
                                SET    amount =  cdr.split_share * :New.DOC_BOOKING_TOTAL / 100
                                       --,due_date = :New.PAY_DATE
                                       ,last_updated_by = 'SYSTEM'
                                WHERE  object_id = CurDocVend.object_id
                                AND    document_key = CurDocVend.document_key
                                AND    company_id = CurDocVend.company_id;

                            END LOOP;

                         END IF;
                     END IF;

                  END IF;
               END IF;
         END IF; -- Check on FIN_INTERFACE_IND

         IF NOT UPDATING('LAST_UPDATED_BY') THEN
             :new.last_updated_by := lv2_user;
         END IF;

         -- avoid increment during loading ???
         IF :New.last_updated_by = 'SYSTEM' THEN
            -- do not create new revision
            :New.last_updated_by := :Old.last_updated_by; -- set to old, assuming that this update is part of a sequence of updates
         ELSE
            :new.rev_no := :old.rev_no + 1;
         END IF;

         :new.last_updated_date := Ecdp_Timestamp.getCurrentSysdate;

		 IF  (:NEW.DOCUMENT_LEVEL_CODE <> :OLD.DOCUMENT_LEVEL_CODE) THEN
              :NEW.REPORT_ACTION_CODE := :OLD.DOCUMENT_LEVEL_CODE ||';'||:NEW.DOCUMENT_LEVEL_CODE ;
         END IF;

     END IF;


EXCEPTION

    WHEN invalid_exchange_rate THEN

         RAISE_APPLICATION_ERROR(-20000,'Invalid exchange rate, cannot be negative for: ' || Nvl(Ec_Contract.object_code(:New.object_id) , ' ') || '    ' || Nvl( Ec_Contract_Version.name(:New.object_id,:New.Daytime,'<='), ' ')  || '  ' || Nvl(:New.document_key,' ') ) ;

     WHEN invalid_document_date THEN

         RAISE_APPLICATION_ERROR(-20000,'Invalid document date, must be equal or greater than contract start date : ' || Nvl(Ec_Contract.object_code(:New.object_id) , ' ') || '    ' || Nvl( Ec_Contract_Version.name(:New.object_id,:New.Daytime,'<='), ' ')  || '  ' || Nvl(:New.document_key,' ') ) ;

     WHEN invalid_level_change THEN

         RAISE_APPLICATION_ERROR(-20000,'Not a valid change of document levels for: ' || Nvl(Ec_Contract.object_code(:New.object_id) , ' ') || '    ' || Nvl( Ec_Contract_Version.name(:New.object_id,:New.Daytime,'<='), ' ')  || '  ' || Nvl(:New.document_key,' ') ) ;

    WHEN missing_booking_period THEN

        RAISE_APPLICATION_ERROR(-20000,'No open booking period found for Contract/Document: ' || Nvl(Ec_Contract.object_code(:New.object_id) , ' ') || '    ' || Nvl( Ec_Contract_Version.name(:New.object_id,:New.Daytime,'<='), ' ')  || '  ' || Nvl(:New.document_key,' ') ) ;

    WHEN invalid_booking_period THEN

        RAISE_APPLICATION_ERROR(-20000,'Invalid booking period, the booking period in document is closed for : ' || Nvl(Ec_Contract.object_code(:New.object_id) , ' ') || '    ' || Nvl( Ec_Contract_Version.name(:New.object_id,:New.Daytime,'<='), ' ')  || '  ' || Nvl(:New.document_key,' ') ) ;

    WHEN new_source_split_share THEN

        RAISE_APPLICATION_ERROR(-20000,'New source split exists for document, please update : ' || Nvl(Ec_Contract.object_code(:New.object_id) , ' ') || '    ' || Nvl( Ec_Contract_Version.name(:New.object_id,:New.Daytime,'<='), ' ')  || '  ' || Nvl(:New.document_key,' ') ) ;

    WHEN tracing_document THEN

        RAISE_APPLICATION_ERROR(-20000,lv_msg) ;

END;
