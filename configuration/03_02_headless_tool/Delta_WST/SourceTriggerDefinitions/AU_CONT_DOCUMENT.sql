CREATE OR REPLACE EDITIONABLE TRIGGER "AU_CONT_DOCUMENT" 
  AFTER UPDATE ON CONT_DOCUMENT
  FOR EACH ROW

DECLARE

lb_tmp boolean;
lv2_reversal_recreation VARCHAR2(32);
lv2_ifac_doc_status VARCHAR2(32);

o_doc_level              VARCHAR2(32);
n_doc_level              VARCHAR2(32);
n_rev_ind                VARCHAR2(32);
n_cont_group_code        VARCHAR2(32);
n_doc_key                VARCHAR2(32);
n_doc_prec_key           VARCHAR2(32);
n_object_id              VARCHAR2(32);
n_doc_status             VARCHAR2(32);
n_doc_scope              VARCHAR2(32);
n_proc_period            date        ;
n_daytime                date        ;
n_contract_doc_id        VARCHAR2(32);

BEGIN

o_doc_level               := :OLD.DOCUMENT_LEVEL_CODE;
n_doc_level               := :NEW.DOCUMENT_LEVEL_CODE;
n_rev_ind                 := :NEW.reversal_ind;
n_cont_group_code         := :New.contract_group_code;
n_doc_key                 := :new.document_key;
n_doc_prec_key            := :new.preceding_document_key;
n_object_id               := :new.object_id;
n_doc_status              := :New.status_code;
n_proc_period             := :new.processing_period;
n_daytime                 := :New.daytime;
n_contract_doc_id         := :New.contract_doc_id;
lv2_reversal_recreation   := nvl(ec_contract_doc_version.reversal_recreation(:new.contract_doc_id, :new.daytime, '<='), 'ALL');
n_doc_scope               := :New.doc_scope;


IF o_doc_level = 'TRANSFER' AND n_doc_level = 'BOOKED' THEN

                        -- Release Cargo relation
                        IF n_rev_ind = 'Y' AND n_doc_scope = 'CARGO_BASED' THEN



                               lb_tmp := EcDp_Document.IsIfacUpdated(n_doc_key,
                                                                                                 NULL,
                                                                                                 'N',
                                                                                                 n_contract_doc_id,
                                                                                                 n_doc_level,
                                                                                                 n_doc_status,
                                                                                                 'Y', -- Set the non_booked_accrual_found to 'Y' since we are changing its status
                                                                                                 'Y',
                                                                                                 n_daytime,
                                                                                                 n_doc_scope,
                                                                                                 lv2_ifac_doc_status,
                                                                                                 'Y',
                                                                                                 'Y');

                             IF NOT lb_tmp THEN

                             -- Cargo is attached to the document being reversed. Release the cargo now that the reversal is booked.
                             -- If this document has no transaction reference in smcv table (cargo is referenced by a preceding doc), then no reference will be removed.
                                IF nvl(n_doc_status,'NULL') = 'ACCRUAL' THEN
                                    lv2_reversal_recreation := nvl(ec_contract_doc_version.reversal_recreation(n_contract_doc_id, n_daytime, '<='), 'ALL');

                                --Spesial for ACCRUAL
                                    UPDATE ifac_cargo_value smcv
                                       SET smcv.transaction_key    = NULL,
                                           smcv.trans_key_set_ind  = 'N',
                                           smcv.ignore_ind         = decode(lv2_reversal_recreation, 'NONE', 'Y', 'N'),
                                           smcv.doc_status         = decode(lv2_reversal_recreation, 'ACCRUAL', 'ACCRUAL', 'FINAL', 'FINAL', smcv.doc_status),
                                           smcv.original_ifac_data = decode(lv2_reversal_recreation, 'ACCRUAL', replace(smcv.original_ifac_data, '$FINAL$', '$ACCRUAL$'), 'FINAL', replace(smcv.original_ifac_data, '$ACCRUAL$', '$FINAL$'), smcv.original_ifac_data),
                                           smcv.last_updated_by    = 'SYSTEM'
                                     WHERE smcv.transaction_key IN
                                           (SELECT transaction_key
                                              FROM cont_transaction
                                             WHERE document_key = n_doc_prec_key
                                               AND cargo_name IS NOT NULL);
                                ELSE
                                    UPDATE ifac_cargo_value smcv
                                       SET smcv.transaction_key   = NULL,
                                           smcv.trans_key_set_ind = 'N',
                                           smcv.ignore_ind        = 'N',
                                           smcv.last_updated_by   = 'SYSTEM'
                                     WHERE smcv.transaction_key IN
                                           (SELECT transaction_key
                                              FROM cont_transaction
                                             WHERE document_key = n_doc_prec_key
                                               AND cargo_name IS NOT NULL);
                                END IF;
                                INSERT INTO ACCRUALS_FOR_REANALYSE (document_key,processing_period) VALUES (n_doc_key,n_daytime);
                            ELSE
                                UPDATE ifac_cargo_value smcv
                                   SET smcv.transaction_key   = NULL,
                                       smcv.trans_key_set_ind = 'N',
                                       smcv.ignore_ind        = 'N',
                                       smcv.last_updated_by   = 'SYSTEM',
                                       smcV.Alloc_No_Max_Ind  = 'N'
                                 WHERE smcv.transaction_key IN
                                       (SELECT transaction_key
                                          FROM cont_transaction
                                         WHERE document_key = n_doc_prec_key
                                           AND cargo_name IS NOT NULL);
                            END IF;
                        END IF;


                        -- Release Period record relation
                        IF n_rev_ind = 'Y' AND n_doc_scope = 'PERIOD_BASED' THEN


                               lb_tmp := EcDp_Document.IsIfacUpdated(n_doc_prec_key,
                                                                                                 NULL,
                                                                                                 'N',
                                                                                                 n_contract_doc_id,
                                                                                                 n_doc_level,
                                                                                                 n_doc_status,
                                                                                                 'Y', -- Set the non_booked_accrual_found to 'Y' since we are changing its status
                                                                                                 'Y',
                                                                                                 n_daytime,
                                                                                                 n_doc_scope,
                                                                                                 lv2_ifac_doc_status,
                                                                                                 'Y',
                                                                                                 'Y');
                -- If there are newer record in future period then the accrual will not be sat to recreate
                          IF NOT lb_tmp THEN

                            -- Period record is attached to the document being reversed. Release the Period record now that the reversal is booked.
                            -- If this document has no transaction reference in smcv table (Period record is referenced by a preceding doc), then no reference will be removed.
                            IF nvl(n_doc_status,'NULL') = 'ACCRUAL' THEN
                                lv2_reversal_recreation := nvl(ec_contract_doc_version.reversal_recreation(n_contract_doc_id, n_daytime, '<='), 'ALL');
                                  --Spesial for ACCRUAL
                                    UPDATE ifac_sales_qty isq
                                       SET isq.transaction_key    = NULL,
                                           isq.trans_key_set_ind  = 'N',
                                           isq.ignore_ind         = decode(lv2_reversal_recreation, 'NONE', 'Y', 'N'),
                                           isq.doc_status         = decode(lv2_reversal_recreation, 'ACCRUAL', 'ACCRUAL', 'FINAL', 'FINAL', isq.doc_status),
                                           isq.original_ifac_data = decode(lv2_reversal_recreation, 'ACCRUAL', replace(isq.original_ifac_data, '$FINAL$', '$ACCRUAL$'), 'FINAL', replace(isq.original_ifac_data, '$ACCRUAL$', '$FINAL$'), isq.original_ifac_data),
                                           last_updated_by        = 'SYSTEM'
                                     WHERE transaction_key IN
                                           (SELECT ct.transaction_key
                                              FROM cont_transaction ct
                                             WHERE ct.document_key = n_doc_prec_key);
                                ELSE
                                    UPDATE ifac_sales_qty isq
                                       SET isq.transaction_key    = NULL,
                                           isq.trans_key_set_ind  = 'N',
                                           isq.ignore_ind         = 'N',
                                           last_updated_by        = 'SYSTEM'
                                     WHERE transaction_key IN
                                           (SELECT ct.transaction_key
                                              FROM cont_transaction ct
                                             WHERE ct.document_key = n_doc_prec_key);
                              END IF;
                                INSERT INTO ACCRUALS_FOR_REANALYSE (document_key,processing_period) VALUES (n_doc_key,n_proc_period);
                          ELSE
                              UPDATE ifac_sales_qty isq
                                 SET isq.transaction_key    = NULL,
                                     isq.trans_key_set_ind  = 'N',
                                     isq.ignore_ind         = 'N',
                                     last_updated_by        = 'SYSTEM',
                                     isq.alloc_no_max_ind   = 'N'
                               WHERE transaction_key IN
                                     (SELECT ct.transaction_key
                                        FROM cont_transaction ct
                                       WHERE ct.document_key = n_doc_prec_key);
                          END IF;
                       END IF;
END IF;
END;
