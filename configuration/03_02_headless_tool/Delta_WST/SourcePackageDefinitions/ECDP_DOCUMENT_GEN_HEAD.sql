CREATE OR REPLACE PACKAGE EcDp_Document_Gen IS
/****************************************************************
** Package        :  EcDp_Document_Gen, header part
**
** $Revision: 1.189 $
**
** Purpose        :  Provide special functions on Cargo and Period based Document Generation.
**
** Documentation  :  www.energy-components.com
**
** Created        : 24.05.2007 Dagfinn Rosnes
**
** Modification history:
**
** Version  Date        Whom        Change description:
** -------  ----------  ----        --------------------------------------
** 1.0      24.05.2007  DRo         Moved Document generation specific code from EcDp_Document to EcDp_Document_Gen.
** 1.1      22.11.2007  DRo         Merged changes done in 92 SP3 (1.24.2.14) on CargoDocGen to Baseline 93 (1.40.2.2) manually.
**                                  Did not merge any period specific logic from 92 to 93, since 93 has been subject to more development.
*****************************************************************/

TYPE t_ifac_arr IS RECORD
  (
   sen NUMBER,
   ptk VARCHAR2(32)
  );

TYPE t_IfacTable IS TABLE OF t_ifac_arr;


TYPE t_nav IS RECORD
  (
  contract_id VARCHAR2(32),
  contract_area_id VARCHAR2(32),
  business_unit_id VARCHAR2(32)
  );

    CURSOR gc_DocumentTransactions(cp_document_key VARCHAR2) IS
    SELECT t.*
      FROM cont_transaction t
     WHERE t.document_key = cp_document_key
       AND NVL(t.reversal_ind, 'N') = 'N';

------------------------------------------------------------------------------------------------------------
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
                          p_user        VARCHAR2,
                          p_owner       VARCHAR2,
                          p_log_item_no IN OUT NUMBER, -- Upon first document in current run, this will be set by the WriteDocGenLog.
                          p_new_doc_key OUT VARCHAR2,
                          p_nav_id      VARCHAR2,
                          p_silent      ecdp_revn_common.T_BOOLEAN_STR DEFAULT ecdp_revn_common.gv2_true) RETURN VARCHAR2;
------------------------------------------------------------------------------------------------------------
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
                           p_log_item_no       IN OUT NUMBER, -- Upon first document in current run, this will be set by the WriteDocGenLog.
                           p_new_doc_key       IN OUT VARCHAR2,
                           p_nav_id            VARCHAR2, -- For logging purposes
                           p_silent            ecdp_revn_common.T_BOOLEAN_STR DEFAULT ecdp_revn_common.gv2_true
                           ) RETURN VARCHAR2;

------------------------------------------------------------------------------------------------------------
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
                        p_nav_id                 VARCHAR2) RETURN VARCHAR2;

------------------------------------------------------------------------------------------------------------
PROCEDURE GenDocException(p_object_id       VARCHAR2,
                          p_doc_key         VARCHAR2,
                          p_err_code        NUMBER,
                          p_err_msg         VARCHAR2,
                          p_exception_level VARCHAR2 DEFAULT 'ERROR', -- could be set to WARNING
                          p_delete_doc_ind  VARCHAR2 DEFAULT 'Y',
                          p_log_no          NUMBER,
                          p_raise_error_ind VARCHAR2 DEFAULT 'N');
------------------------------------------------------------------------------------------------------------
PROCEDURE genReverseDocuments;
------------------------------------------------------------------------------------------------------------
PROCEDURE UpdInterestLineItems
 (p_doc_key VARCHAR2);
------------------------------------------------------------------------------------------------------------
PROCEDURE CleanupStimRecords(p_company_id     VARCHAR2,
                             p_financial_code VARCHAR2,
                             p_user           VARCHAR2);
------------------------------------------------------------------------------------------------------------
PROCEDURE aggregateLevelQty(p_transaction_key VARCHAR2,
                            p_dist_id         VARCHAR2,
                            p_from_level      VARCHAR2, -- COMPANY or FIELD
                            p_user_id         VARCHAR2);
------------------------------------------------------------------------------------------------------------
PROCEDURE executeUserAction(
          p_document_key VARCHAR2,
          p_user_action_code VARCHAR2);
------------------------------------------------------------------------------------------------------------
PROCEDURE SetDocumentRecActionCode(
          p_document_key VARCHAR2,
          p_document_type VARCHAR2 DEFAULT NULL,
          p_include_prec_doc VARCHAR2 DEFAULT 'N');
------------------------------------------------------------------------------------------------------------
PROCEDURE DeleteLog(p_daytime DATE);
------------------------------------------------------------------------------------------------------------
PROCEDURE q_PeriodDocumentProcess(p_cursor           OUT SYS_REFCURSOR,
                                  p_contract_id      VARCHAR2,
                                  p_contract_area_id VARCHAR2,
                                  p_business_unit_id VARCHAR2,
                                  p_doc_list         VARCHAR2 DEFAULT NULL);
------------------------------------------------------------------------------------------------------------
PROCEDURE q_CargoDocumentProcess(p_cursor                    OUT SYS_REFCURSOR,
                                 p_contract_id               VARCHAR2,
                                 p_contract_area_id          VARCHAR2,
                                 p_business_unit_id          VARCHAR2,
                                 p_doc_list                  VARCHAR2 DEFAULT NULL);
------------------------------------------------------------------------------------------------------------
PROCEDURE q_NavParam(p_cursor OUT SYS_REFCURSOR, p_object_id VARCHAR2);
------------------------------------------------------------------------------------------------------------
PROCEDURE q_ERPDocumentProcess(p_cursor           OUT SYS_REFCURSOR,
                               p_contract_id      VARCHAR2,
                               p_contract_area_id VARCHAR2,
                               p_business_unit_id VARCHAR2);
------------------------------------------------------------------------------------------------------------

FUNCTION GetERPDocVendor(p_contract_id VARCHAR2,
                         p_daytime DATE
) RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION PopulateERPDocRecord(
  p_object_id         VARCHAR2,
  p_contract_doc_id   VARCHAR2,
  p_document_key      VARCHAR2,
  p_preceding_doc_key VARCHAR2,
  p_daytime           DATE,
  p_vendor_id         VARCHAR2,
  p_status_code       VARCHAR2,
  p_document_type     VARCHAR2,
  p_ext_doc_key       VARCHAR2,
  p_document_number   VARCHAR2,
  p_user              VARCHAR2,
  p_operation         VARCHAR2 -- INSERTING / UPDATING
) RETURN cont_document%ROWTYPE;

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE UpdateManualERPDoc(
          p_document_key VARCHAR2);


PROCEDURE q_ERPDocumentValidate(p_cursor            OUT SYS_REFCURSOR,
                                p_contract_id       VARCHAR2,
                                p_document_key      VARCHAR2,
                                p_production_period DATE);





PROCEDURE ReverseERPDocumentPostings(p_document_key VARCHAR2,
                                     p_user         VARCHAR2);



-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE ValidateDocProcessParams(p_contract_id     VARCHAR2,
                                   p_contract_doc_id VARCHAR2,
                                   p_source          VARCHAR2);

PROCEDURE FinalDocGenLog(p_logger       IN OUT NOCOPY t_revn_logger,
                         p_final_status VARCHAR2);

END EcDp_Document_Gen;