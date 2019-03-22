CREATE OR REPLACE PACKAGE ue_cont_document IS
/****************************************************************
** Package        :  ue_cont_document, header part
**
** $Revision: 1.30.2.3 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created  : 02.06.2008 Stian Skjoerestad
**
** Modification history:
**
** Version  Date         Whom   Change description:
** -------  ------       -----  --------------------------------------
******************************************************************/

isValidateDocumentUEEnabled VARCHAR2(32) := 'FALSE';
isValidateDocPostUEEnabled VARCHAR2(32) := 'FALSE';
isConcatBankDetailsUEEnabled VARCHAR2(32) := 'FALSE';
isUpdateDocumentCustomerUEE VARCHAR2(32) := 'FALSE';
isExecUserActionPreUEEnabled VARCHAR2(32) := 'FALSE';
isExecUserActionPostUEEnabled VARCHAR2(32) := 'FALSE';
isGetDocRecActionCodeUEEnabled VARCHAR2(32) := 'FALSE';
isValid1Valid2UEEnabled VARCHAR2(32) := 'FALSE';
isSetPPAInterestUEEnabled VARCHAR2(32) := 'FALSE';
isFillDocumentUEEnabled VARCHAR2(32) := 'FALSE';
isFillDocumentQtyUEEnabled VARCHAR2(32) := 'FALSE';
isFillDocumentLIUEEnabled VARCHAR2(32) := 'FALSE';
isFillDocumentPriceUEEnabled VARCHAR2(32) := 'FALSE';
isFillDocPostUEEnabled VARCHAR2(32) := 'FALSE';
isFillDocQtyPostUEEnabled VARCHAR2(32) := 'FALSE';
isFillDocLIPostUEEnabled VARCHAR2(32) := 'FALSE';
isFillDocPricePostUEEnabled VARCHAR2(32) := 'FALSE';
isGenReverseDocumentUEEnabled VARCHAR2(32) := 'FALSE';
isDocLevelLockedUEEnabled VARCHAR2(32) := 'FALSE';
isGetRepURLUEEnabled VARCHAR2(32) := 'FALSE';
isGetRepNameUEEnabled VARCHAR2(32) := 'FALSE';
isUpdIntBaseAmtPreUEEnabled VARCHAR2(32) := 'FALSE';
isUpdIntBaseAmtUEEnabled VARCHAR2(32) := 'FALSE';
isUpdIntBaseAmtPostUEEnabled VARCHAR2(32) := 'FALSE';
isGetPeriodDocActUEEnabled VARCHAR2(32) := 'FALSE';
isGetPeriodDocActPreUEEnabled VARCHAR2(32) := 'FALSE';
isGetPeriodDocActPostUEEnabled VARCHAR2(32) := 'FALSE';
isGetCargoDocActUEEnabled VARCHAR2(32) := 'FALSE';
isGetCargoDocActPreUEEnabled VARCHAR2(32) := 'FALSE';
isGetCargoDocActPostUEEnabled VARCHAR2(32) := 'FALSE';
isGenPeriodDocUEEnabled VARCHAR(32) := 'FALSE';
isGenPeriodDocUEPreEnabled VARCHAR(32) := 'FALSE';
isGenPeriodDocUEPostEnabled VARCHAR(32) := 'FALSE';
isGenCargoDocUEEnabled VARCHAR(32) := 'FALSE';
isGenCargoDocUEPreEnabled VARCHAR(32) := 'FALSE';
isGenCargoDocUEPostEnabled VARCHAR(32) := 'FALSE';
isUpdLineItemCustomerUEEnabled VARCHAR2(32) := 'FALSE';
isReversedProcPeriodUEEnabled VARCHAR2(32) := 'FALSE';
isTransferUEEnabled VARCHAR2(32) := 'FALSE';
isIsInsTransAllowedUEE VARCHAR(32) := 'FALSE';
isIsInsTransAllowedPreUEE VARCHAR(32) := 'FALSE';
isIsInsTransAllowedPostUEE VARCHAR(32) := 'FALSE';


PROCEDURE FillDocument(p_document_key VARCHAR2, p_user VARCHAR2);

PROCEDURE FillDocumentQuantity(p_document_key VARCHAR2, p_user VARCHAR2);

PROCEDURE FillDocumentLine(p_document_key VARCHAR2, p_user VARCHAR2);

PROCEDURE FillDocumentPrice(p_document_key VARCHAR2, p_user VARCHAR2);

PROCEDURE FillDocPost(p_document_key VARCHAR2, p_user VARCHAR2);

PROCEDURE FillDocQuantityPost(p_document_key VARCHAR2, p_user VARCHAR2);

PROCEDURE FillDocLinePost(p_document_key VARCHAR2, p_user VARCHAR2);

PROCEDURE FillDocPricePost(p_document_key VARCHAR2, p_user VARCHAR2);

FUNCTION GetInvoiceNo(p_document_key              VARCHAR2,
                      p_daytime                   DATE,
                      p_document_date             DATE,
                      p_status_code               VARCHAR2,
                      p_owner_company_id          VARCHAR2,
                      p_doc_seq_final_id          VARCHAR2,
                      p_doc_seq_accrual_id        VARCHAR2,
                      p_doc_number_format_final   VARCHAR2,
                      p_doc_number_format_accrual VARCHAR2,
                      p_financial_code            VARCHAR2)

RETURN VARCHAR2;

PROCEDURE ValidateDocument(
            p_rec_doc cont_document%ROWTYPE,
            p_val_msg OUT VARCHAR2,
            p_val_code OUT VARCHAR2,
            p_silent_ind VARCHAR2); -- if 'N': Raise exeptions, if 'Y': continue and return code/msg

PROCEDURE ValidateDocumentPost(
            p_rec_doc cont_document%ROWTYPE,
            p_val_msg IN OUT VARCHAR2,
            p_val_code IN OUT VARCHAR2,
            p_silent_ind VARCHAR2); -- if 'N': Raise exeptions, if 'Y': continue and return code/msg

PROCEDURE ValidateDocumentCustomer(p_document_key VARCHAR2);

PROCEDURE updateDocumentCustomer(p_document_key VARCHAR2,
                              p_contract_id VARCHAR2,
                              p_contract_doc_id VARCHAR2,
                              p_document_level_code VARCHAR2,
                              p_document_daytime DATE,
                              p_document_booking_currency_id  VARCHAR2,
                              p_user VARCHAR2,
                              p_customer_id VARCHAR2,
                              p_update_cont_document BOOLEAN);


PROCEDURE UpdLineItemCustomer(p_document_key   VARCHAR2,
                            p_user             VARCHAR2,
                            p_d_object_id      VARCHAR2 DEFAULT NULL,
                            p_d_customer_id    VARCHAR2 DEFAULT NULL);

FUNCTION GetConcatBankDetails
(
   p_bank_account_id VARCHAR2,
   p_document_key VARCHAR2
   )
RETURN VARCHAR2;

FUNCTION ExecuteUserActionPre(p_document_key     VARCHAR2,
                              p_user_action_code VARCHAR2,
                              p_output_msg       IN OUT VARCHAR2)
  RETURN VARCHAR2;


PROCEDURE ExecuteUserActionPost(p_document_key     VARCHAR2,
                                p_user_action_code VARCHAR2);



FUNCTION GetDocumentRecActionCode(p_document_key VARCHAR2) RETURN VARCHAR2;


PROCEDURE Valid1Valid2(p_object_id               VARCHAR2,
                       p_document_key            VARCHAR2,
                       p_financial_code          VARCHAR2,
                       p_status_code             VARCHAR2,
                       p_owner_company_id        VARCHAR2,
                       p_Document_Date           DATE,
                       p_Daytime                 DATE,
                       p_user                    VARCHAR2);

PROCEDURE SetPPAInterest(p_document_key VARCHAR2, p_user VARCHAR2);

PROCEDURE GenReverseDocumentUE(p_document_key VARCHAR2);

FUNCTION IsDocLevelLocked(p_document_key VARCHAR2) RETURN VARCHAR2;

FUNCTION isInsertingTransAllowed(
         p_document_key VARCHAR2,
         p_msg OUT VARCHAR2)
RETURN VARCHAR2;

FUNCTION isInsertingTransAllowedPre(
         p_document_key VARCHAR2,
         p_msg OUT VARCHAR2)
RETURN VARCHAR2;

FUNCTION isInsertingTransAllowedPost(
         p_document_key VARCHAR2,
         p_status VARCHAR2,
         p_msg OUT VARCHAR2)
RETURN VARCHAR2;

FUNCTION GetRepURL(p_doc_template_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;

FUNCTION GetRepName(p_doc_template_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;

PROCEDURE UpdateInterestBaseAmountPre(p_object_id       VARCHAR2,
                           p_document_key    VARCHAR2,
                           p_transaction_key VARCHAR2,
                           p_base_rate       NUMBER,
                           p_user            VARCHAR2);

PROCEDURE UpdateInterestBaseAmount(p_object_id       VARCHAR2,
                           p_document_key    VARCHAR2,
                           p_transaction_key VARCHAR2,
                           p_base_rate       NUMBER,
                           p_user            VARCHAR2);

PROCEDURE UpdateInterestBaseAmountPost(p_object_id       VARCHAR2,
                           p_document_key    VARCHAR2,
                           p_transaction_key VARCHAR2,
                           p_base_rate       NUMBER,
                           p_user            VARCHAR2);

FUNCTION GetPeriodDocAction(p_contract_id VARCHAR2,
                           p_contract_doc_id VARCHAR2,
                           p_customer_id VARCHAR2,
                           p_processing_period DATE,
                           p_preceding_doc_key VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

PROCEDURE GetPeriodDocActionPre(p_contract_id VARCHAR2,
                           p_contract_doc_id VARCHAR2,
                           p_customer_id VARCHAR2,
                           p_processing_period DATE,
                           p_preceding_doc_key VARCHAR2);

PROCEDURE GetPeriodDocActionPost(p_contract_id VARCHAR2,
                           p_contract_doc_id VARCHAR2,
                           p_customer_id VARCHAR2,
                           p_processing_period DATE,
                           p_preceding_doc_key VARCHAR2,
                           p_doc_action_code IN OUT VARCHAR2);

FUNCTION GetCargoDocAction(p_contract_id       VARCHAR2,
                           p_cargo_no          VARCHAR2,
                           p_qty_type          VARCHAR2,
                           p_daytime           DATE,
                           p_doc_setup_id      VARCHAR2,
                           p_ifac_tt_conn_code VARCHAR2,
                           p_customer          VARCHAR2) RETURN VARCHAR2;

PROCEDURE GetCargoDocActionPre(p_contract_id   VARCHAR2,
                           p_cargo_no          VARCHAR2,
                           p_qty_type          VARCHAR2,
                           p_daytime           DATE,
                           p_doc_setup_id      VARCHAR2,
                           p_ifac_tt_conn_code VARCHAR2,
                           p_customer          VARCHAR2);

PROCEDURE GetCargoDocActionPost(p_contract_id  VARCHAR2,
                           p_cargo_no          VARCHAR2,
                           p_qty_type          VARCHAR2,
                           p_daytime           DATE,
                           p_doc_setup_id      VARCHAR2,
                           p_ifac_tt_conn_code VARCHAR2,
                           p_customer          VARCHAR2,
                           p_doc_action_code   IN OUT VARCHAR2);

FUNCTION GenPeriodDocument(p_object_id          VARCHAR2,
                            p_processing_period DATE,
                            p_period_from       DATE,
                            p_period_to         DATE,
                            p_action            VARCHAR2,
                            p_contract_doc_id   VARCHAR2,
                            p_document_date     DATE,
                            p_document_status   VARCHAR2,
                            p_prec_doc_key      VARCHAR2,
                            p_delivery_point_id VARCHAR2,
                            p_customer_id       VARCHAR2,
                            p_source_node_id    VARCHAR2,
                            p_user              VARCHAR2,
                            p_owner             VARCHAR2,
                            p_log_item_no       IN OUT NUMBER,
                            p_new_doc_key       OUT VARCHAR2,
                            p_nav_id            VARCHAR2) RETURN VARCHAR2;

PROCEDURE GenPeriodDocumentPre(p_object_id     IN OUT VARCHAR2,
                            p_processing_period IN OUT DATE,
                            p_period_from       IN OUT DATE,
                            p_period_to         IN OUT DATE,
                            p_action            IN OUT VARCHAR2,
                            p_contract_doc_id   IN OUT VARCHAR2,
                            p_document_date     IN OUT DATE,
                            p_document_status   IN OUT VARCHAR2,
                            p_prec_doc_key      IN OUT VARCHAR2,
                            p_delivery_point_id IN OUT VARCHAR2,
                            p_customer_id       IN OUT VARCHAR2,
                            p_source_node_id    IN OUT VARCHAR2,
                            p_user              IN OUT VARCHAR2,
                            p_owner             IN OUT VARCHAR2,
                            p_log_item_no       IN OUT NUMBER,
                            p_nav_id            IN OUT VARCHAR2);

PROCEDURE GenPeriodDocumentPost(p_object_id    VARCHAR2,
                            p_processing_period DATE,
                            p_period_from       DATE,
                            p_period_to         DATE,
                            p_action            VARCHAR2,
                            p_contract_doc_id   VARCHAR2,
                            p_document_date     DATE,
                            p_document_status   VARCHAR2,
                            p_prec_doc_key      VARCHAR2,
                            p_delivery_point_id VARCHAR2,
                            p_customer_id       VARCHAR2,
                            p_source_node_id    VARCHAR2,
                            p_user              VARCHAR2,
                            p_owner             VARCHAR2,
                            p_log_item_no       NUMBER,
                            p_new_doc_key       IN OUT VARCHAR2,
                            p_nav_id            VARCHAR2,
                            p_run_status        IN OUT VARCHAR2);


FUNCTION GenCargoDocument(p_object_id          VARCHAR2,
                            p_cargo_no         VARCHAR2,
                            p_parcel_no        VARCHAR2,
                            p_daytime          DATE,
                            p_action           VARCHAR2,
                            p_contract_doc_id  VARCHAR2,
                            p_validation_level VARCHAR2,
                            p_document_date    DATE,
                            p_document_status  VARCHAR2,
                            p_gen_doc_key      VARCHAR2,
                            p_prec_doc_key     VARCHAR2,
                            p_loading_port_id  VARCHAR2,
                            p_customer_id      VARCHAR2,
                            p_source_node_id   VARCHAR2,
                            p_user             VARCHAR2,
                            p_owner            VARCHAR2,
                            p_log_item_no      IN OUT NUMBER,
                            p_new_doc_key      OUT VARCHAR2,
                            p_nav_id           VARCHAR2) RETURN VARCHAR2;

PROCEDURE GenCargoDocumentPre(p_object_id       IN OUT VARCHAR2,
                            p_cargo_no         IN OUT VARCHAR2,
                            p_parcel_no        IN OUT VARCHAR2,
                            p_daytime          IN OUT DATE,
                            p_action           IN OUT VARCHAR2,
                            p_contract_doc_id  IN OUT VARCHAR2,
                            p_validation_level IN OUT VARCHAR2,
                            p_document_date    IN OUT DATE,
                            p_document_status  IN OUT VARCHAR2,
                            p_gen_doc_key      IN OUT VARCHAR2,
                            p_prec_doc_key     IN OUT VARCHAR2,
                            p_loading_port_id  IN OUT VARCHAR2,
                            p_customer_id      IN OUT VARCHAR2,
                            p_source_node_id   IN OUT VARCHAR2,
                            p_user             IN OUT VARCHAR2,
                            p_owner            IN OUT VARCHAR2,
                            p_log_item_no      IN OUT NUMBER,
                            p_nav_id           IN OUT VARCHAR2);

PROCEDURE GenCargoDocumentPost(p_object_id     VARCHAR2,
                            p_cargo_no         VARCHAR2,
                            p_parcel_no        VARCHAR2,
                            p_daytime          DATE,
                            p_action           VARCHAR2,
                            p_contract_doc_id  VARCHAR2,
                            p_validation_level VARCHAR2,
                            p_document_date    DATE,
                            p_document_status  VARCHAR2,
                            p_gen_doc_key      VARCHAR2,
                            p_prec_doc_key     VARCHAR2,
                            p_loading_port_id  VARCHAR2,
                            p_customer_id      VARCHAR2,
                            p_source_node_id   VARCHAR2,
                            p_user             VARCHAR2,
                            p_owner            VARCHAR2,
                            p_log_item_no      NUMBER,
                            p_new_doc_key      IN OUT VARCHAR2,
                            p_nav_id           VARCHAR2,
                            p_run_status       IN OUT VARCHAR2);


FUNCTION GetRevProcPeriod
                     (p_object_id                 VARCHAR2,
                      p_document_key              VARCHAR2,
                      p_daytime                   DATE)

RETURN DATE;

-- get a new status
FUNCTION GetNewStatus(v_T_TABLE_CONT_DOCUMENT IN T_TABLE_CONT_DOCUMENT)

RETURN VARCHAR2;

END ue_cont_document;