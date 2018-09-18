CREATE OR REPLACE PACKAGE EcDp_Document IS
    --*********************************************************************
    --* This package provides special functions on Document.
    --*********************************************************************

    -----------------------------------------------------------------------
    -- Fills the given document with information from interface.
    ----+----------------------------------+-------------------------------
    PROCEDURE fill_by_ifac_period_i(
        p_context                          IN OUT NOCOPY t_revn_doc_op_context
       ,p_document_key                     VARCHAR2
    );
    -----------------------------------------------------------------------
    -- Fills the given document with information from interface.
    ----+----------------------------------+-------------------------------
    PROCEDURE fill_by_ifac_cargo_i(
        p_context                          IN OUT NOCOPY t_revn_doc_op_context
       ,p_document_key                     VARCHAR2
    );


-- Global cursor to identify transactions on a document to be valid preceding transactions on a dependent document
CURSOR gc_transactions(cp_document_key       VARCHAR2,
                       cp_document_concept   VARCHAR2,
                       cp_stream_item_id     VARCHAR2,
                       cp_price_concept_code VARCHAR2,
                       cp_product_id         VARCHAR2,
                       cp_entry_point_id     VARCHAR2,
                       cp_transaction_scope  VARCHAR2,
                       cp_transaction_type   VARCHAR2,
                       cp_dist_code          VARCHAR2 default null,
                       cp_dist_object_type   VARCHAR2 default null) IS
SELECT t.transaction_key,
       t.name,
       t.stream_item_id,
       t.price_concept_code,
       t.product_id,
       t.transaction_scope,
       t.transaction_type,
       t.pricing_currency_id,
       t.supply_from_date,
       t.supply_to_date,
       t.ifac_unique_key_1,
       t.ifac_unique_key_2,
       t.delivery_point_id,
       t.vat_code
  FROM cont_transaction t
 WHERE document_key = cp_document_key
       AND NVL(t.stream_item_id, '$NULL$') = nvl(cp_stream_item_id, nvl(t.stream_item_id, '$NULL$'))
       AND t.price_concept_code = nvl(cp_price_concept_code,t.price_concept_code)
       AND t.product_id = nvl(cp_product_id,t.product_id)
       AND NVL(t.entry_point_id, '$NULL$') = nvl(cp_entry_point_id, nvl(t.entry_point_id, '$NULL$'))
       AND t.transaction_scope = cp_transaction_scope
       AND cp_transaction_type LIKE decode(cp_document_concept,'DEPENDENT_PREV_MTH_CORR','%FIN%',cp_transaction_type) -- This is to support this particular document concept which earlier used another cursor
       AND t.reversed_trans_key IS NULL
       AND t.dist_code = nvl(cp_dist_code,t.dist_code)
       AND t.dist_object_type = nvl(cp_dist_object_type, t.dist_object_type)
       AND nvl(t.preceding_trans_key,'NA') = decode(cp_document_concept,'DEPENDENT_PREV_MTH_CORR','NA',nvl(t.preceding_trans_key,'NA'))
       AND NOT EXISTS
       ( -- Exclude transactions that are already being referenced as preceding.
           SELECT 1
             FROM cont_transaction ctr
            WHERE ctr.preceding_trans_key = t.transaction_key
              AND cp_document_concept <> 'DEPENDENT_WITHOUT_REVERSAL' -- TODO (skjorsti/09032010: Verify if this is a valid condition for DEPENDENT_PREV_MTH_CORR
              AND ctr.ppa_trans_code<>'PPA_PRICE'
              AND (SELECT COUNT(*)
                     FROM cont_document cd
                    WHERE preceding_document_key = ctr.document_key
                      AND document_level_code = 'BOOKED'
                      AND ec_cont_document.reversal_ind(cd.document_key) = 'Y') = 0
       );


-- Global cursor for transaction templates on document setup
CURSOR gc_transaction_templates (cp_contract_doc_id contract_doc.object_id%type, cp_daytime DATE) IS
SELECT tt.object_id id,
       ttv.transaction_type,
       ttv.transaction_scope,
       ttv.stream_item_id,
       ttv.price_concept_code,
       ttv.product_id,
       ttv.entry_point_id,
       ttv.dist_code,
       ttv.dist_object_type
  FROM transaction_template tt, transaction_tmpl_version ttv
 WHERE tt.contract_doc_id = cp_contract_doc_id
   AND cp_daytime >= ttv.daytime
   AND cp_daytime < Nvl(ttv.end_date, cp_daytime + 1)
   AND ttv.object_id = tt.object_id
 ORDER BY tt.sort_order;

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE upddocumentpricingtotal(p_object_id VARCHAR2,
                                  p_doc_id    VARCHAR2,
                                  p_user      VARCHAR2);

-----------------------------------------------------------------------------------------------------------------------------

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
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

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
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION GetDocBookExRate(p_object_id         VARCHAR2,
                          p_document_id       VARCHAR2,
                          p_daytime           DATE,
                          p_type              VARCHAR2, -- 'LOCAL' or 'GROUP' are valid choices
                          p_pricing_curr_code VARCHAR2,
                          p_memo_curr_code    VARCHAR2)
RETURN NUMBER;

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE InsNewDocumentCustomer(
    p_object_id                     VARCHAR2,
    p_doc_setup_id                  VARCHAR2,
    p_doc_id                        VARCHAR2,
    p_customer_id                   VARCHAR2,
    p_user                          VARCHAR2,
    p_d_doc_date                    VARCHAR2 DEFAULT NULL,
    p_d_booking_currency_id         VARCHAR2 DEFAULT NULL
);

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION IsDocRateEditable(p_object_id   VARCHAR2,
                           p_document_id VARCHAR2,
                           p_type        VARCHAR2) -- 'LOCAL' or 'GROUP' are valid choices
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION isPurchase(p_object_id VARCHAR2, p_document_id VARCHAR2)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION isSale(p_object_id VARCHAR2, p_document_id VARCHAR2)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION getDocumentVendorShareActual(p_document_key VARCHAR2,
                                      p_vendor_id    VARCHAR2)
RETURN NUMBER;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION concatVendorNames(p_document_key VARCHAR2, p_type VARCHAR2)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

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
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE DelDocument(p_object_id     VARCHAR2,
                      p_document_id   VARCHAR2);

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION int2words(number_in NUMBER)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION isMultiVendorDocument(p_document_key VARCHAR2)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION ConvertAmountToWords(p_amount        NUMBER,
                              p_currency_code VARCHAR2,
                              p_daytime       DATE)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION GetDocumentListBankInfo(p_object_id VARCHAR2, p_doc_id VARCHAR2)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION GenReverseDocument(p_object_id       VARCHAR2,
                            p_reverse_doc_key VARCHAR2,
                            p_user            VARCHAR2,
                            p_force_reversal  VARCHAR2 DEFAULT 'N',
                            p_new_rev_doc_key VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION GenReverseDocument(p_object_id       VARCHAR2,
                            p_reverse_doc_key VARCHAR2,
                            p_log_item_no     IN OUT NUMBER,
                            p_user            VARCHAR2,
                            p_force_reversal  VARCHAR2 DEFAULT 'N',
                            p_new_rev_doc_key VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION IsIfacUpdated(p_document_key                 VARCHAR2, -- may be set to null if only transaction_key is set
                       p_transaction_key              VARCHAR2,
                       p_err_ind                      VARCHAR2, -- Override exception raise
                       p_contract_doc_id              VARCHAR2,
                       p_doc_level                    VARCHAR2,
                       p_ori_doc_status               VARCHAR2,
                       p_non_booked_accrual_found     VARCHAR2 DEFAULT NULL,
                       p_check_new_trans              VARCHAR2 DEFAULT 'N',
                       p_doc_date                     DATE     DEFAULT NULL,
                       p_doc_scope                    VARCHAR2 DEFAULT NULL,
                       p_doc_status                   OUT VARCHAR2,
                       p_allow_future_proc_period_ind VARCHAR2 DEFAULT 'N',
                       p_allow_alt_qty_Status_ind     VARCHAR2 DEFAULT 'N' )

RETURN BOOLEAN;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION IsIfacDependentAvailable(p_document_key        VARCHAR2,
                                  p_transaction_Key     VARCHAR2,
                                  p_doc_status      OUT VARCHAR2)
RETURN BOOLEAN;

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE SetDocumentComments(p_object_id   VARCHAR2,
                              p_document_id VARCHAR2,
                              p_key         VARCHAR2,
                              p_comments    VARCHAR2,
                              p_user        VARCHAR2,
                              p_rev_text    VARCHAR2 DEFAULT NULL);

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION GetDocumentComments(p_object_id   VARCHAR2,
                             p_document_id VARCHAR2,
                             p_key         VARCHAR2)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION GetFirstPreceedingDocId(p_object_id VARCHAR2,
                                 p_doc_id VARCHAR2)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION GetConcatBankDetails(p_bank_account_id VARCHAR2,
                              p_document_key    VARCHAR2)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE UpdIntBaseAmountFromApp(p_object_id       VARCHAR2,
                                  p_document_key    VARCHAR2,
                                  p_transaction_key VARCHAR2,
                                  p_base_rate       NUMBER,
                                  p_user            VARCHAR2);

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION GenContractDocCopy(p_doc_id      VARCHAR2,
                            p_contract_id VARCHAR2,
                            p_code        VARCHAR2,
                            p_name        VARCHAR2,
                            p_user        VARCHAR2,
                            p_start_date  DATE DEFAULT NULL,
                            P_end_date    DATE DEFAULT NULL)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE ValidateSplitShare(p_object_id VARCHAR2,
                             p_doc_id    VARCHAR2,
                             p_daytime   DATE);

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE ConfigureReport(p_contract_id          VARCHAR2,
                          p_document_key         VARCHAR2,
                          p_report_definition_no NUMBER,
                          p_user_id              VARCHAR2);

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE UpdateDocumentReport(p_report_no            VARCHAR2,
                               p_document_id          VARCHAR2,
                               p_document_date        VARCHAR2,
                               p_report_definition_no VARCHAR2);

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE SetDocumentType(p_document_key VARCHAR2);

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION getDistinctTransType(p_document_key VARCHAR2)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION getLocalCurrency(p_object_id VARCHAR2)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION getTradingPartner(p_document_key VARCHAR2)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE UpdDocumentVat(p_document_key VARCHAR2,
                         p_daytime      VARCHAR2,
                         p_user         VARCHAR2 DEFAULT NULL);

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE ValidateDocument(p_document_key VARCHAR2,
                           p_val_msg OUT VARCHAR2,
                           p_val_code OUT VARCHAR2,
                           p_silent_ind VARCHAR2);

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE ValidateERPDocument(p_document_key VARCHAR2,
                              p_val_msg OUT VARCHAR2,
                              p_val_code OUT VARCHAR2,
                              p_silent_ind VARCHAR2 DEFAULT 'N');

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION checkDefaultReport(p_doc_template_id VARCHAR2,
                            p_daytime DATE)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION getRepDefNo(p_doc_template_id VARCHAR2,
                     p_daytime DATE)
RETURN NUMBER;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION getRepURL(p_doc_template_id VARCHAR2,
                   p_daytime DATE)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION getRepName(p_doc_template_id VARCHAR2,
                    p_daytime DATE)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION GetNextDocumentKey(p_object_id VARCHAR2,
                            p_daytime DATE)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION GetNextERPDocumentKey(p_object_id VARCHAR2,
                               p_daytime DATE)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION isPreceding(p_document_key VARCHAR2)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION HasReversedDependentDoc(p_document_key VARCHAR2)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION HasBookedDependentDoc(p_document_key VARCHAR2)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION GetReversalDoc(p_document_key VARCHAR2)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION isDocumentEditable(p_document_key VARCHAR2)
RETURN VARCHAR2;

------------------------+-----------------------------------+------------------------------------+---------------------------
-- Fills quantities on transactions in the specified document.
--
-- p_document_key: the document to fill.
-- p_user: the id of user triggered this action.
--
-- Usage: ExecuteUserAction, GenCargoDocument, GenPeriodDocument
------------------------+-----------------------------------+------------------------------------+---------------------------
PROCEDURE FillDocumentQuantity(
                         p_document_key                     VARCHAR2
                        ,p_user                             VARCHAR2
                        ,p_context                          T_REVN_DOC_OP_CONTEXT DEFAULT NULL
);

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE FillDocumentPrice(p_document_key VARCHAR2,
                            p_user VARCHAR2);

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION isDocSourceSplitShareUpdated(p_document_key VARCHAR2)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE recalcSourceSplit(p_document_key VARCHAR2,
                            p_user_id VARCHAR2);

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE ValidateContractDocForERP(p_contract_doc_id VARCHAR2,
                                    p_daytime DATE);

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE InsVendorCustomer(p_document_key VARCHAR2,
                            p_daytime      DATE,
                            p_user_id      VARCHAR2);

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION GetDocumentDaytime(p_contract_id VARCHAR2,
                            p_contract_doc_id VARCHAR2,
                            p_document_date DATE)
RETURN DATE;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION IsDocLevelLocked(p_document_key VARCHAR2)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE ValidateDocumentStatus(p_document_key VARCHAR2,
                                 p_val_msg OUT VARCHAR2,
                                 p_val_code OUT VARCHAR2,
                                 p_silent_ind VARCHAR2); -- if 'N': Raise exeptions, if 'Y': continue and return code/msg

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE ValidateDocumentStatus(p_document_rec CONT_DOCUMENT%ROWTYPE,
                                 p_val_msg OUT VARCHAR2,
                                 p_val_code OUT VARCHAR2,
                                 p_silent_ind VARCHAR2); -- if 'N': Raise exeptions, if 'Y': continue and return code/msg

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION GetDocumentBusinessUnitID(p_document_key VARCHAR2)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION getMPDPrecDoc(p_document_key VARCHAR2)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION GetDocumentVendor(p_object_id     VARCHAR2,
                           p_document_key  VARCHAR2,
                           p_daytime       DATE,
                           p_d_document_fin_code      VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE updateDocumentCustomer(
    p_document_key                  VARCHAR2,
    p_contract_id                   VARCHAR2,
    p_user                          VARCHAR2,
    p_customer_id                   VARCHAR2,
    p_update_cont_document          BOOLEAN DEFAULT TRUE,
    p_force_update                  BOOLEAN DEFAULT FALSE);

-----------------------------------------------------------------------------------------------------------------------------

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
    p_force_update                  BOOLEAN DEFAULT FALSE);

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE UpdLineItemCustomer(p_document_key VARCHAR2,
                              p_user VARCHAR2,
                              p_d_object_id VARCHAR2 DEFAULT NULL,
                              p_d_customer_id VARCHAR2 DEFAULT NULL,
                              p_exclude_preceding VARCHAR2 DEFAULT 'N');

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION IsUpdatingCustomerAllowed(
    p_document_key                  VARCHAR2,
    p_allow_alt_cust_ind            VARCHAR2,
    p_contract_doc_concept_code     VARCHAR2,
    p_cont_document_level_code      VARCHAR2,
    p_is_interfaced_document        BOOLEAN,
    p_reason_message                OUT VARCHAR2)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION IsUpdatingCustomerAllowed(
    p_document_key                  VARCHAR2)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION isDocumentInterfaced(
    p_document_key                  VARCHAR2)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION isCompanyOnInvoiceTitlePage(
    p_document_key                  VARCHAR2,
    p_vendor_id                     VARCHAR2,
    p_customer_id                   VARCHAR2,
    p_financial_code                VARCHAR2)
RETURN VARCHAR2;
-----------------------------------------------------------------------------------------------------------------------------
FUNCTION GetNonPPADocumentKey(
    p_transactio_key                  VARCHAR2)
RETURN VARCHAR2;
-----------------------------------------------------------------------------------------------------------------------------
FUNCTION IsPPADocument(
    p_document_key                VARCHAR2)
RETURN VARCHAR2;
-----------------------------------------------------------------------------------------------------------------------------
FUNCTION IsPrecedingReverseDocOpen(
    p_transaction_key                VARCHAR2)
RETURN VARCHAR2;
-----------------------------------------------------------------------------------------------------------------------------
FUNCTION GetReportRunableNoByDefinition(
    p_report_definition_no           VARCHAR2)
RETURN VARCHAR2;
-----------------------------------------------------------------------------------------------------------------------------
FUNCTION ValidateReportBeforeView(p_status VARCHAR2)
RETURN VARCHAR2;
-----------------------------------------------------------------------------------------------------------------------------
FUNCTION GetLastGeneratedReportNo(p_document_id   VARCHAR2,
                                  p_document_date VARCHAR2)
RETURN VARCHAR2;
-----------------------------------------------------------------------------------------------------------------------------
FUNCTION DeleteDocumentReport(p_report_no VARCHAR2) RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION GetLastGeneratedDocumentKey(p_user_id VARCHAR2)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

END EcDp_Document;