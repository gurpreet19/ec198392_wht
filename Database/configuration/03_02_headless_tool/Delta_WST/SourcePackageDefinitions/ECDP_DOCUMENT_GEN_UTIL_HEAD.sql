CREATE OR REPLACE PACKAGE EcDp_Document_Gen_Util IS
    -----------------------------------------------------------------------
    -- About this Package
    -- ------------------
    -- Provides help functions on Cargo and Period based Document
    -- Generation.
    --
    -- Logic for processing and manipulate data is still to be persisted
    -- in EcDp_Document_Gen.
    --
    -- This package is mainly for lookup functions.
    ----+----------------------------------+-------------------------------

    -----------------------------------------------------------------------
    -- Gets the preceding line item key of given interface- Period
    ----+----------------------------------+-------------------------------
    FUNCTION find_preceding_li_i(
        p_ifac_rec                         IN OUT NOCOPY t_ifac_sales_qty
    )
    RETURN cont_line_item.line_item_key%TYPE;

    ----------------------------------------------------------------------
    -- Gets the preceding line item key of given interface - Cargo
    ----+----------------------------------+-------------------------------
    FUNCTION find_preceding_li_i(
        p_ifac_rec                         IN OUT NOCOPY t_ifac_cargo_value
    )
    RETURN cont_line_item.line_item_key%TYPE;

FUNCTION GetCargoDocDate
  (p_contract_id VARCHAR2,
   p_cargo_no VARCHAR2,
   p_qty_type VARCHAR2,
   p_alloc_no NUMBER,
   p_point_of_sale_date DATE,
   p_doc_setup_id VARCHAR2,
   p_customer_id VARCHAR2,
   p_doc_date DATE DEFAULT NULL,
   p_doc_key VARCHAR2 DEFAULT NULL
   )
RETURN DATE;
------------------------------------------------------------------------------------------------------------

FUNCTION GetCargoDocAction
  (p_contract_id      VARCHAR2,
   p_cargo_no         VARCHAR2,
   p_parcel_no        VARCHAR2,
   p_qty_type         VARCHAR2,
   p_daytime          DATE,
   p_doc_setup_id     VARCHAR2,
   p_ifac_tt_conn_code VARCHAR2,
   p_customer_id      VARCHAR2)
RETURN VARCHAR2;

------------------------------------------------------------------------------------------------------------

FUNCTION GetPeriodDocAction
  (p_contract_id VARCHAR2,
   p_contract_doc_id VARCHAR2,
   p_customer_id VARCHAR2,
   p_processing_period DATE,
   p_preceding_doc_key VARCHAR2 DEFAULT NULL,
   p_doc_status        VARCHAR2 DEFAULT 'FINAL'
  )
RETURN VARCHAR2;

------------------------------------------------------------------------------------------------------------

FUNCTION GetHoldFinalWhenAclInd(p_doc_setup_id VARCHAR2,
                                p_daytime DATE,
                                p_contract_hold_final_ind VARCHAR2 DEFAULT NULL,
                                p_sys_att_hold_final_ind VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

------------------------------------------------------------------------------------------------------------

FUNCTION SkipIfacQtyRecForUpdateCheck(p_ifac_doc_status VARCHAR2,
                                        p_doc_setup_id VARCHAR2,
                                        p_customer_id VARCHAR2,
                                        p_processing_period DATE,
                                        p_contract_hold_final_ind VARCHAR2 DEFAULT NULL,
                                        p_sys_att_hold_final_ind VARCHAR2 DEFAULT NULL,
                                        p_updating_doc_status VARCHAR2 DEFAULT NULL,
                                        p_non_booked_accrual_found VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

------------------------------------------------------------------------------------------------------------
PROCEDURE GetDocumentRecActionCode(p_document_key VARCHAR2,
                                   p_val_msg  OUT VARCHAR2,
                                   p_val_code OUT VARCHAR2);

-----------------------------------------------------------------------------------------------------------------------------
FUNCTION GetERPDocumentRecActionCode(p_document_key VARCHAR2
) RETURN VARCHAR2;
-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE GetERPDocumentRecActionCode(p_document_key VARCHAR2,
                                      p_val_msg  OUT VARCHAR2,
                                      p_val_code OUT VARCHAR2);
------------------------------------------------------------------------------------------------------------

FUNCTION GetPeriodPrecedingDocKey(p_contract_id        VARCHAR2,
                                  p_processing_period  DATE,
                                  p_supply_from_date   DATE,
                                  p_price_concept_code VARCHAR2,
                                  p_delivery_point_id  VARCHAR2,
                                  p_product_id         VARCHAR2,
                                  p_customer_id        VARCHAR2,
                                  p_unique_key_1       VARCHAR2,
                                  p_unique_key_2       VARCHAR2,
                                  p_prec_doc_key       VARCHAR2,
                                  p_ifac_tt_conn_code  VARCHAR2,
                                  p_appending_doc_id   VARCHAR2 DEFAULT NULL,
                                  p_Qty_Status         VARCHAR2 DEFAULT NULL,
                                  p_Price_Status         VARCHAR2 DEFAULT NULL,
                                  p_uom1_code          VARCHAR2 DEFAULT NULL,
                                  p_price_object_id    VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;
-----------------------------------------------------------------------------------------------------------------------------

    FUNCTION GetPeriodPrecedingDocKeyMPD(
        p_contract_doc_id               VARCHAR2,
        p_customer_id                   VARCHAR2,
        p_doc_status                    VARCHAR2,
        p_processing_period             DATE DEFAULT NULL)
    RETURN VARCHAR2;
-----------------------------------------------------------------------------------------------------------------------------
FUNCTION GetIfacPrecedingTransKey(pRec IN OUT NOCOPY T_IFAC_SALES_QTY)
RETURN VARCHAR2;
-----------------------------------------------------------------------------------------------------------------------------
FUNCTION GetIfacPrecedingTransKey(pRec IN OUT NOCOPY T_IFAC_CARGO_VALUE)
RETURN VARCHAR2;
------------------------------------------------------------------------------------------------------------
FUNCTION GetCargoPrecedingDocKey(p_contract_id  VARCHAR2,
                                 p_cargo_no     VARCHAR2,
                                 p_parcel_no    VARCHAR2,
                                 p_doc_key      VARCHAR2,
                                 p_pos_date     DATE,
                                 p_ifac_tt_conn_code VARCHAR2,
                                 p_customer_id  VARCHAR2,
                                 p_prec_doc_key VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;
------------------------------------------------------------------------------------------------------------
FUNCTION isDocumentQtyInterfaced (
                                 p_document_key VARCHAR2)
RETURN VARCHAR2;
------------------------------------------------------------------------------------------------------------
FUNCTION GetDocUOMInd(p_document_key VARCHAR2,
                      p_uom_col VARCHAR2)
RETURN VARCHAR2;
------------------------------------------------------------------------------------------------------------
FUNCTION GetDocumentCargoName(
         p_document_key VARCHAR2
) RETURN VARCHAR2;
-----------------------------------------------------------------------------------------------------------------------------
FUNCTION isERPDocEditable(
               p_erp_doc_key VARCHAR2)
RETURN VARCHAR2;
-----------------------------------------------------------------------------------------------------------------------------
FUNCTION isERPPostingEditable(
               p_erp_rec_key VARCHAR2)
RETURN VARCHAR2;

FUNCTION GetERPPrecedingDocKey(p_contract_id       VARCHAR2,
                               p_production_period DATE)

RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------
FUNCTION CountDocNonRevTrans(p_Document_Key VARCHAR2)
RETURN NUMBER;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION GetTheLastMPDDoc(p_contract_doc_id VARCHAR2, p_customer_id VARCHAR2)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION HasNotReversedAccrualDoc(p_contract_doc_id VARCHAR2, p_customer_id VARCHAR2, p_period DATE)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION GetParcelNo(p_parcel_no  VARCHAR2, p_doc_setup_id VARCHAR2,
                     p_point_of_Sale_date DATE)
RETURN VARCHAR2;

-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION isNewTransactionInterfaced(p_object_id VARCHAR2,
                                    p_document_key VARCHAR2,
                                    p_doc_date DATE DEFAULT NULL,
                                    p_doc_scope VARCHAR2,
                                    p_Level_code VARCHAR2,
                                    p_contract_doc_id VARCHAR2)
RETURN VARCHAR2;
-------------------------------------------------------------------------------------------------------------

END EcDp_Document_Gen_Util;