CREATE OR REPLACE PACKAGE BODY ue_cont_document IS
/****************************************************************
** Package        :  ue_cont_document, body part
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

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : FillDocument
-- Description    : Support project specific document manipulation.
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
---------------------------------------------------------------------------------------------------
PROCEDURE FillDocument(p_document_key VARCHAR2, p_user VARCHAR2)
IS

BEGIN
    NULL;
END FillDocument;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : FillDocumentQuantity
-- Description    : Support project specific document manipulation.
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
---------------------------------------------------------------------------------------------------
PROCEDURE FillDocumentQuantity(p_document_key VARCHAR2, p_user VARCHAR2)
IS

BEGIN
    NULL;
END FillDocumentQuantity;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : FillDocumentLine
-- Description    : Support project specific document manipulation.
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
---------------------------------------------------------------------------------------------------
PROCEDURE FillDocumentLine(p_document_key VARCHAR2, p_user VARCHAR2)
IS

BEGIN
    NULL;
END FillDocumentLine;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : FillDocumentPrice
-- Description    : Support project specific document manipulation.
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
---------------------------------------------------------------------------------------------------
PROCEDURE FillDocumentPrice(p_document_key VARCHAR2, p_user VARCHAR2)
IS

BEGIN
    NULL;
END FillDocumentPrice;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : FillDocPost
-- Description    : Support project specific document manipulation.
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
---------------------------------------------------------------------------------------------------
PROCEDURE FillDocPost(p_document_key VARCHAR2, p_user VARCHAR2)
IS

BEGIN
    NULL;
END FillDocPost;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : FillDocQuantityPost
-- Description    : Support project specific document manipulation.
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
---------------------------------------------------------------------------------------------------
PROCEDURE FillDocQuantityPost(p_document_key VARCHAR2, p_user VARCHAR2)
IS

BEGIN
    NULL;
END FillDocQuantityPost;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : FillDocLinePost
-- Description    : Support project specific document manipulation.
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
---------------------------------------------------------------------------------------------------
PROCEDURE FillDocLinePost(p_document_key VARCHAR2, p_user VARCHAR2)
IS

BEGIN
    NULL;
END FillDocLinePost;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : FillDocPricePost
-- Description    : Support project specific document manipulation.
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
---------------------------------------------------------------------------------------------------
PROCEDURE FillDocPricePost(p_document_key VARCHAR2, p_user VARCHAR2)
IS

BEGIN
    NULL;
END FillDocPricePost;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetInvoiceNo
-- Description    : Support project specific invoice number generation
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
-- Behaviour      : If the string $USEREXIT exists in the document format
--                  then this sting is removed and the ordinary function ecdp_document.GetInvoiceNo
--                  is replaced by this one.
---------------------------------------------------------------------------------------------------
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

RETURN VARCHAR2

IS

lv2_doc_num_format_fin VARCHAR2(32);
lv2_doc_num_format_acc VARCHAR2(32);

BEGIN

-- Removing string $USEREXIT from the format
-- The rest should be handled by the project
-- Please use the variables below for format reference (final/accrual)
lv2_doc_num_format_fin := REPLACE(p_doc_number_format_final,'$USEREXIT',NULL);
lv2_doc_num_format_acc := REPLACE(p_doc_number_format_accrual,'$USEREXIT',NULL);




RETURN NULL;

END GetInvoiceNo;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : ValidateDocument
-- Description    : Support project specific document validation, from OPEN to VALID1
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
---------------------------------------------------------------------------------------------------
PROCEDURE ValidateDocument(
            p_rec_doc cont_document%ROWTYPE,
            p_val_msg OUT VARCHAR2,
            p_val_code OUT VARCHAR2,
            p_silent_ind VARCHAR2 -- if 'N': Raise exeptions, if 'Y': continue and return code/msg
)
--</EC-DOC>
IS

  validation_exception EXCEPTION;
  ln_valTest NUMBER := 1; -- example variable
BEGIN

-- Example validation:
  IF ln_valTest = 0 THEN
    p_val_msg := 'Test value can not be zero.'; -- Description of this validation. Will be printed in the error message.
    p_val_code := 'TEST_VAL'; -- Code for this validation. Make sure that this code is present with code and text in tv_ec_codes where code_type = 'COMPLETE_DOC_ACTION'.
    RAISE validation_exception;
  END IF;

-- Generic exception handling. Should not be changed or removed.
EXCEPTION
  WHEN validation_exception THEN
    IF p_silent_ind = 'N' THEN
       RAISE_APPLICATION_ERROR(-20000, 'User Exit Validation failed for document: ' || p_rec_doc.document_key ||
                                       ', contract: ' || Ec_Contract.object_code(p_rec_doc.object_id) || ' (' || Nvl(p_rec_doc.contract_name, ' ') || ').' ||
                                       '\n\n' || p_val_msg);
    END IF;
END ValidateDocument;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : ValidateDocumentPost
-- Description    : Support project specific document validation, from OPEN to VALID1.
--                  Running AFTER the normal validation.
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
---------------------------------------------------------------------------------------------------
PROCEDURE ValidateDocumentPost(
            p_rec_doc cont_document%ROWTYPE,
            p_val_msg IN OUT VARCHAR2,
            p_val_code IN OUT VARCHAR2,
            p_silent_ind VARCHAR2 -- if 'N': Raise exeptions, if 'Y': continue and return code/msg
)
--</EC-DOC>
IS
  validation_exception EXCEPTION;
  ln_valTest NUMBER := 1; -- example variable
BEGIN

-- Example validation:
  IF ln_valTest = 0 THEN
    p_val_msg := 'Test value can not be zero.'; -- Description of this validation. Will be printed in the error message.
    p_val_code := 'TEST_VAL'; -- Code for this validation. Make sure that this code is present with code and text in tv_ec_codes where code_type = 'COMPLETE_DOC_ACTION'.
    RAISE validation_exception;
  END IF;

-- Generic exception handling. Should not be changed or removed.
EXCEPTION
  WHEN validation_exception THEN
    IF p_silent_ind = 'N' THEN
       RAISE_APPLICATION_ERROR(-20000, 'User Exit Post Validation failed for document: ' || p_rec_doc.document_key ||
                                       ', contract: ' || Ec_Contract.object_code(p_rec_doc.object_id) || ' (' || Nvl(p_rec_doc.contract_name, ' ') || ').' ||
                                       '\n\n' || p_val_msg);
    END IF;

END ValidateDocumentPost;


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
IS
BEGIN

  RETURN NULL;

END GetConcatBankDetails;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  updateDocumentCustomer
-- Description    : The Instead-Of user exit for procedure EcDp_Document.updateDocumentCustomer.
--                  Note that this procedure could be called inside a trigger of table
--                  CONT_DOCUMENT. To avoid mutating errors, do not query or update that table.
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
PROCEDURE updateDocumentCustomer(p_document_key VARCHAR2,
                              p_contract_id VARCHAR2,
                              p_contract_doc_id VARCHAR2,
                              p_document_level_code VARCHAR2,
                              p_document_daytime DATE,
                              p_document_booking_currency_id  VARCHAR2,
                              p_user VARCHAR2,
                              p_customer_id VARCHAR2,
                              p_update_cont_document BOOLEAN)
--</EC-DOC>
IS

BEGIN

NULL;

END updateDocumentCustomer;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  UpdLineItemCustomer
-- Description    :  Called from EcDp_Document.UpdLineItemCustomer() and performs INSTEAD-OF user exit to
--                   customer needs.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- Required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
PROCEDURE UpdLineItemCustomer(p_document_key VARCHAR2,
                              p_user VARCHAR2,
                              p_d_object_id VARCHAR2 DEFAULT NULL,
                              p_d_customer_id VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS
BEGIN
    NULL;
END UpdLineItemCustomer;

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
PROCEDURE ValidateDocumentCustomer(p_document_key VARCHAR2)


IS

BEGIN

NULL;

END ValidateDocumentCustomer;






--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  ExecuteUserActionPre
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
FUNCTION ExecuteUserActionPre(p_document_key     VARCHAR2,
                              p_user_action_code VARCHAR2,
                              p_output_msg       IN OUT VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS

BEGIN

RETURN NULL;

END ExecuteUserActionPre;



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  ExecuteUserActionPost
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
PROCEDURE ExecuteUserActionPost(p_document_key     VARCHAR2,
                                p_user_action_code VARCHAR2)
--</EC-DOC>
IS

BEGIN

NULL;


END ExecuteUserActionPost;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  GetDocumentRecActionCode
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
FUNCTION GetDocumentRecActionCode(p_document_key VARCHAR2) RETURN VARCHAR2

   IS

   BEGIN

   RETURN NULL;

END GetDocumentRecActionCode;


-------------------------------------------------------------------------------------------------
-- Procedure      :  Valid1Valid2
-- Description    :  Called from iu_cont_document when moving from VALID1 to VALID2
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
PROCEDURE Valid1Valid2(p_object_id               VARCHAR2,
                       p_document_key            VARCHAR2,
                       p_financial_code          VARCHAR2,
                       p_status_code             VARCHAR2,
                       p_owner_company_id        VARCHAR2,
                       p_Document_Date           DATE,
                       p_Daytime                 DATE,
                       p_user                    VARCHAR2)
--</EC-DOC>
IS


BEGIN

  NULL;

END Valid1Valid2;


-------------------------------------------------------------------------------------------------
-- Procedure      :  SetPPAInterest
-- Description    :  Called from EcDp_PPA_Price.GenPriceAdjustmentDoc and EcDp_Document_Gen.GenPeriodDocument to provide for alternative
--                   approaches to run the interest calculation.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
PROCEDURE SetPPAInterest(p_document_key VARCHAR2, p_user VARCHAR2)
--</EC-DOC>
IS


BEGIN

  NULL;

END SetPPAInterest;



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  GenReverseDocumentUE
-- Description    :  Called from EcDp_Document.GenReverseDocument() and performs user exit to
--                   customer needs.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- Required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
PROCEDURE GenReverseDocumentUE(p_document_key VARCHAR2)
--</EC-DOC>
IS
BEGIN
  NULL;
END GenReverseDocumentUE;



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  IsDocLevelLocked
-- Description    :  Called from EcDp_Document.IsDocLevelLocked() and performs user exit to
--                   customer needs.
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
  RETURN NULL;
END IsDocLevelLocked;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isInsertingTransAllowed
-- Description    : Instead-of-type user exit, REPLACING the product code
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
---------------------------------------------------------------------------------------------------
FUNCTION isInsertingTransAllowed(
         p_document_key VARCHAR2,
         p_msg OUT VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN

  RETURN NULL;

END isInsertingTransAllowed;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isInsertingTransAllowedPre
-- Description    : Pre-type user exit, BEFORE the product code executes
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
---------------------------------------------------------------------------------------------------
FUNCTION isInsertingTransAllowedPre(
         p_document_key VARCHAR2,
         p_msg OUT VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN

  RETURN NULL;

END isInsertingTransAllowedPre;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isInsertingTransAllowedPost
-- Description    : Post-type user exit, AFTER the product code has been executed
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
---------------------------------------------------------------------------------------------------
FUNCTION isInsertingTransAllowedPost(
         p_document_key VARCHAR2,
         p_status VARCHAR2,
         p_msg OUT VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN

  RETURN NULL;

END isInsertingTransAllowedPost;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  GetRepURL
-- Description    :  Called from EcDp_Document.GetRepURL() and performs In_Stead_Of user exit to
--                   customer needs.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- Required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
FUNCTION GetRepURL(p_doc_template_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN NULL;
END GetRepURL;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  GetRepName
-- Description    :  Called from EcDp_Document.getRepName() and performs In_Stead_Of user exit to
--                   customer needs.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- Required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
FUNCTION GetRepName(p_doc_template_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN NULL;
END GetRepName;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  UpdateInterestBaseAmountPre
-- Description    :  Called from EcDp_Document.UpdIntBaseAmountFromApp() and performs PRE user exit to
--                   customer needs.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- Required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
PROCEDURE UpdateInterestBaseAmountPre(p_object_id       VARCHAR2,
                           p_document_key    VARCHAR2,
                           p_transaction_key VARCHAR2,
                           p_base_rate       NUMBER,
                           p_user            VARCHAR2)
--</EC-DOC>
IS
BEGIN
  NULL;
END UpdateInterestBaseAmountPre;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  UpdateInterestBaseAmount
-- Description    :  Called from EcDp_Document.UpdIntBaseAmountFromApp() and performs In_Stead_Of user exit to
--                   customer needs.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- Required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
PROCEDURE UpdateInterestBaseAmount(p_object_id       VARCHAR2,
                           p_document_key    VARCHAR2,
                           p_transaction_key VARCHAR2,
                           p_base_rate       NUMBER,
                           p_user            VARCHAR2)
--</EC-DOC>
IS
BEGIN
  NULL;
END UpdateInterestBaseAmount;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  UpdateInterestBaseAmountPost
-- Description    :  Called from EcDp_Document.UpdIntBaseAmountFromApp() and performs POST user exit to
--                   customer needs.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- Required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
PROCEDURE UpdateInterestBaseAmountPost(p_object_id       VARCHAR2,
                           p_document_key    VARCHAR2,
                           p_transaction_key VARCHAR2,
                           p_base_rate       NUMBER,
                           p_user            VARCHAR2)
--</EC-DOC>
IS
BEGIN
  NULL;
END UpdateInterestBaseAmountPost;



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  GetPeriodDocAction
-- Description    :  Called from EcDp_Document_Gen_Util.GetPeriodDocAction() and performs In_Stead_Of user exit to
--                   customer needs.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- Required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
FUNCTION GetPeriodDocAction(p_contract_id VARCHAR2,
                           p_contract_doc_id VARCHAR2,
                           p_customer_id VARCHAR2,
                           p_processing_period DATE,
                           p_preceding_doc_key VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
    NULL;
END GetPeriodDocAction;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  GetPeriodDocActionPre
-- Description    :  Called from EcDp_Document_Gen_Util.GetPeriodDocAction() and performs PRE user exit to
--                   customer needs.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- Required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
PROCEDURE GetPeriodDocActionPre(p_contract_id VARCHAR2,
                           p_contract_doc_id VARCHAR2,
                           p_customer_id VARCHAR2,
                           p_processing_period DATE,
                           p_preceding_doc_key VARCHAR2)
--</EC-DOC>
IS
BEGIN
    NULL;
END GetPeriodDocActionPre;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  GetPeriodDocActionPost
-- Description    :  Called from EcDp_Document_Gen_Util.GetPeriodDocAction() and performs POST user exit to
--                   customer needs.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- Required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
PROCEDURE GetPeriodDocActionPost(p_contract_id VARCHAR2,
                           p_contract_doc_id VARCHAR2,
                           p_customer_id VARCHAR2,
                           p_processing_period DATE,
                           p_preceding_doc_key VARCHAR2,
                           p_doc_action_code IN OUT VARCHAR2)
--</EC-DOC>
IS
BEGIN
    NULL;
END GetPeriodDocActionPost;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  GetCargoDocAction
-- Description    :  Called from EcDp_Document_Gen_Util.GetCargoDocAction() and performs In_Stead_Of user exit to
--                   customer needs.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- Required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
FUNCTION GetCargoDocAction(p_contract_id       VARCHAR2,
                           p_cargo_no          VARCHAR2,
                           p_qty_type          VARCHAR2,
                           p_daytime           DATE,
                           p_doc_setup_id      VARCHAR2,
                           p_ifac_tt_conn_code VARCHAR2,
                           p_customer          VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
    NULL;
END GetCargoDocAction;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  GetCargoDocActionPre
-- Description    :  Called from EcDp_Document_Gen_Util.GetCargoDocAction() and performs PRE user exit to
--                   customer needs.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- Required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
PROCEDURE GetCargoDocActionPre(p_contract_id   VARCHAR2,
                           p_cargo_no          VARCHAR2,
                           p_qty_type          VARCHAR2,
                           p_daytime           DATE,
                           p_doc_setup_id      VARCHAR2,
                           p_ifac_tt_conn_code VARCHAR2,
                           p_customer          VARCHAR2)
--</EC-DOC>
IS
BEGIN
    NULL;
END GetCargoDocActionPre;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  GetCargoDocActionPost
-- Description    :  Called from EcDp_Document_Gen_Util.GetCargoDocAction() and performs POST user exit to
--                   customer needs.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- Required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
PROCEDURE GetCargoDocActionPost(p_contract_id  VARCHAR2,
                           p_cargo_no          VARCHAR2,
                           p_qty_type          VARCHAR2,
                           p_daytime           DATE,
                           p_doc_setup_id      VARCHAR2,
                           p_ifac_tt_conn_code VARCHAR2,
                           p_customer          VARCHAR2,
                           p_doc_action_code   IN OUT VARCHAR2)
--</EC-DOC>
IS
BEGIN
    NULL;
END GetCargoDocActionPost;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  GenPeriodDocument
-- Description    :  Called from EcDp_Document_Gen.GenPeriodDocument() and performs INSTEAD-OF user exit to
--                   customer needs.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- Required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
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
                            p_nav_id            VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
    NULL;
END GenPeriodDocument;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  GenPeriodDocumentPre
-- Description    :  Called from EcDp_Document_Gen.GenPeriodDocument() and performs PRE user exit to
--                   customer needs.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- Required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
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
                            p_nav_id            IN OUT VARCHAR2)
--</EC-DOC>
IS
BEGIN
    NULL;
END GenPeriodDocumentPre;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  GenPeriodDocumentPost
-- Description    :  Called from EcDp_Document_Gen.GenPeriodDocument() and performs POST user exit to
--                   customer needs.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- Required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
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
                            p_run_status        IN OUT VARCHAR2)
--</EC-DOC>
IS
BEGIN
    NULL;
END GenPeriodDocumentPost;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  GenCargoDocument
-- Description    :  Called from EcDp_Document_Gen.GenCargoDocument() and performs INSTEAD-OF user exit to
--                   customer needs.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- Required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
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
                            p_nav_id           VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
    NULL;
END GenCargoDocument;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  GenCargoDocumentPre
-- Description    :  Called from EcDp_Document_Gen.GenCargoDocument() and performs PRE user exit to
--                   customer needs.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- Required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
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
                            p_nav_id           IN OUT VARCHAR2)
--</EC-DOC>
IS
BEGIN
    NULL;
END GenCargoDocumentPre;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  GenCargoDocumentPost
-- Description    :  Called from EcDp_Document_Gen.GenCargoDocument() and performs POST user exit to
--                   customer needs.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- Required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
PROCEDURE GenCargoDocumentPost(p_object_id      VARCHAR2,
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
                            p_run_status       IN OUT VARCHAR2)
--</EC-DOC>
IS
BEGIN
    NULL;
END GenCargoDocumentPost;





FUNCTION GetRevProcPeriod
                     (p_object_id                 VARCHAR2,
                      p_document_key              VARCHAR2,
                      p_daytime                   DATE)

RETURN DATE IS
   ld_processing_period DATE DEFAULT SYSDATE;
BEGIN
  return ld_processing_period;
END ;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  GetNewStatus
-- Description    :  Called from IU_CONT_DOCUMENT trigger and performs user exit to
--                   to return custom DOCUMENT_LEVEL_CODE as per customer needs.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- Required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
FUNCTION GetNewStatus (v_T_TABLE_CONT_DOCUMENT IN T_TABLE_CONT_DOCUMENT)
RETURN VARCHAR2
--</EC-DOC>
IS
   lv2_new_status VARCHAR2(32);
BEGIN
   lv2_new_status := null;

       /*IF v_T_TABLE_CONT_DOCUMENT(1).BOOK_DOCUMENT_IND = 'N' THEN
         lv2_new_status := 'BOOKED';
       END IF;*/

RETURN lv2_new_status;

END;

END ue_cont_document;