CREATE OR REPLACE PACKAGE BODY ue_Cont_Transaction IS
/****************************************************************
** Package        :  ue_cont_document, body part
**
** $Revision:
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created  : 11.12.2009 Kheng
**
** Modification history:
**
** Version  Date         Whom   Change description:
** -------  ------       -----  --------------------------------------
******************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : FillTransaction
-- Description    : Support project specific transaction manipulation.
--                  NOTE that when calling EcDp_Transaction.FillTransaction the procedure
--                  will call FillTransactionPrice and FillTransactionQuantity
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
PROCEDURE FillTransaction(p_transaction_key VARCHAR2, p_daytime DATE, p_user VARCHAR2)
IS

BEGIN
    null;
END FillTransaction;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : FillTransactionQuantity
-- Description    : Support project specific transaction manipulation.
--                  NOTE that when calling EcDp_Transaction.FillTransaction the procedure
--                  will call FillTransactionPrice,FillTransactionLines and FillTransactionQuantity
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
PROCEDURE FillTransactionQuantity(p_transaction_key VARCHAR2,
                                  p_user            VARCHAR2)
IS

BEGIN
    null;
END FillTransactionQuantity;

---------------------------------------------------------------------------------------------------
-- Procedure      : FillTransactionLines
-- Description    : Support project specific transaction manipulation.
--                  NOTE that when calling EcDp_Transaction.FillTransaction the procedure
--                  will call FillTransactionPrice,FillTransactionLines and FillTransactionQuantity
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
PROCEDURE FillTransactionLines(p_transaction_key VARCHAR2,
                                  p_user            VARCHAR2)
IS

BEGIN
    null;
END FillTransactionLines;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : FillTransactionPrice
-- Description    : Support project specific transaction manipulation.
--                  NOTE that when calling EcDp_Transaction.FillTransaction the procedure
--                  will call FillTransactionPrice and FillTransactionQuantity
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
PROCEDURE FillTransactionPrice(p_transaction_key      VARCHAR2,
                               p_daytime              DATE,
                               p_user                 VARCHAR2,
                               p_line_item_based_type VARCHAR2 DEFAULT NULL)
IS

BEGIN
    null;
END FillTransactionPrice;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : FillTransPost
-- Description    : Support project specific transaction manipulation.
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
PROCEDURE FillTransPost(p_transaction_key VARCHAR2, p_daytime DATE, p_user VARCHAR2)
IS

BEGIN
    null;
END FillTransPost;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : FillTransQtyPost
-- Description    : Support project specific transaction manipulation.
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
PROCEDURE FillTransQtyPost(p_transaction_key VARCHAR2,
                           p_user            VARCHAR2)
IS

BEGIN
    null;
END FillTransQtyPost;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : FillTransLIPost
-- Description    : Support project specific transaction manipulation.
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
PROCEDURE FillTransLIPost(p_transaction_key VARCHAR2,
                           p_user            VARCHAR2)
IS

BEGIN
    null;
END FillTransLIPost;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : FillTransPricePost
-- Description    : Support project specific transaction manipulation.
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
PROCEDURE FillTransPricePost(p_transaction_key      VARCHAR2,
                             p_daytime              DATE,
                             p_user                 VARCHAR2,
                             p_line_item_based_type VARCHAR2 DEFAULT NULL)
IS

BEGIN
    null;
END FillTransPricePost;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : ValidateTransactions
-- Description    : Support project specific transaction validation, when moving from OPEN to VALID1
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
PROCEDURE ValidateTransactions(
    p_rec_doc  cont_document%ROWTYPE,
    p_val_msg  OUT VARCHAR2,
    p_val_code OUT VARCHAR2,
    p_silent_ind   VARCHAR2
)
--</EC-DOC>
IS

  validation_exception EXCEPTION;
  ln_valTest NUMBER; -- example variable

BEGIN

  NULL;

  -- Example validation:
  IF ln_valTest = 0 THEN
    p_val_msg := 'Test value can not be zero.'; -- Description of this validation. Will be printed in the error message.
    p_val_code := 'TEST_VAL'; -- Code for this validation. Make sure that this code is present with code and text in tv_ec_codes where code_type = 'DOCUMENT_VALIDATION'.
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
END ValidateTransactions;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetTransactionName
-- Description    : Called from EcDp_Transaction.GetTransactionName(...) and performs Instead-Of
--                  user exit to customer needs.
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
FUNCTION GetTransactionName(
    p_transaction cont_transaction%ROWTYPE,
    p_limit_size NUMBER DEFAULT NULL)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN NULL;

END GetTransactionName;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetTransactionNamePre
-- Description    : Called from EcDp_Transaction.GetTransactionName(...) and performs PRE
--                  user exit to customer needs.
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
FUNCTION GetTransactionNamePre(
    p_transaction cont_transaction%ROWTYPE,
    p_limit_size NUMBER DEFAULT NULL)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN NULL;

END GetTransactionNamePre;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetTransactionNamePost
-- Description    : Called from EcDp_Transaction.GetTransactionName(...) and performs POST
--                  user exit to customer needs.
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
FUNCTION GetTransactionNamePost(
    p_transaction cont_transaction%ROWTYPE,
    p_transaction_name VARCHAR2,
    p_limit_size NUMBER DEFAULT NULL)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN p_transaction_name;

END GetTransactionNamePost;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Procedure      :  ResolveTransNamePH
-- Description    :  Called from EcDp_Transaction.resolveNamePlaceholderValue(...) and performs
--                   Instead-Of user exit to customer needs.
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration  :
-- Required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
FUNCTION ResolveTransNamePH(p_placeholder_name  VARCHAR2,
                            p_transaction CONT_TRANSACTION%ROWTYPE) RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
    NULL;
END ResolveTransNamePH;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isTransactionEditable
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
FUNCTION isTransactionEditable(
         p_transaction_key VARCHAR2,
         p_level VARCHAR2, -- Alternatives: TRANS, FIELD or COMPANY
         p_msg OUT VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN

  RETURN NULL;

END isTransactionEditable;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isTransactionEditablePre
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
FUNCTION isTransactionEditablePre(
         p_transaction_key VARCHAR2,
         p_level VARCHAR2, -- Alternatives: TRANS, FIELD or COMPANY
         p_msg OUT VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN

  RETURN NULL;

END isTransactionEditablePre;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isTransactionEditablePost
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
FUNCTION isTransactionEditablePost(
         p_transaction_key VARCHAR2,
         p_level VARCHAR2, -- Alternatives: TRANS, FIELD or COMPANY
         p_status VARCHAR2,
         p_msg OUT VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN

  RETURN NULL;

END isTransactionEditablePost;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isTransactionDeletable
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
FUNCTION isTransactionDeletable(
         p_transaction_key VARCHAR2,
         p_level VARCHAR2, -- Alternatives: TRANS, FIELD or COMPANY
         p_msg OUT VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN

  RETURN NULL;

END isTransactionDeletable;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isTransactionDeletablePre
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
FUNCTION isTransactionDeletablePre(
         p_transaction_key VARCHAR2,
         p_level VARCHAR2, -- Alternatives: TRANS, FIELD or COMPANY
         p_msg OUT VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN

  RETURN NULL;

END isTransactionDeletablePre;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isTransactionDeletablePost
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
FUNCTION isTransactionDeletablePost(
         p_transaction_key VARCHAR2,
         p_level VARCHAR2, -- Alternatives: TRANS, FIELD or COMPANY
         p_status VARCHAR2,
         p_msg OUT VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN

  RETURN NULL;

END isTransactionDeletablePost;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : SetAllTransSortOrder
-- Description    : Instead-of-type user exit, REPLACING the procedure EcDp_Transaction.SetAllTransSortOrder
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
PROCEDURE SetAllTransSortOrder(p_document_key VARCHAR2)
--</EC-DOC>
IS
BEGIN

  NULL;

END SetAllTransSortOrder;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : SetTransSortOrder
-- Description    : Instead-of-type user exit, REPLACING the procedure EcDp_Transaction.SetTransSortOrder
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
PROCEDURE SetTransSortOrder(p_transaction CONT_TRANSACTION%ROWTYPE,
                            p_recalculate_sort_order BOOLEAN,
                            p_user VARCHAR2)
IS
--</EC-DOC>
BEGIN
    NULL;
END SetTransSortOrder;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : SetTransSortOrderPre
-- Description    : Pre-type user exit, REPLACING the procedure EcDp_Transaction.SetTransSortOrder
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
PROCEDURE SetTransSortOrderPre(p_transaction CONT_TRANSACTION%ROWTYPE,
                               p_recalculate_sort_order BOOLEAN,
                               p_user VARCHAR2)
IS
--</EC-DOC>
BEGIN
    NULL;
END SetTransSortOrderPre;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : SetTransSortOrderPost
-- Description    : Post-type user exit, REPLACING the procedure EcDp_Transaction.SetTransSortOrder
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
PROCEDURE SetTransSortOrderPost(p_transaction CONT_TRANSACTION%ROWTYPE,
                                p_recalculate_sort_order BOOLEAN,
                                p_user VARCHAR2,
                                updated_trans_sort_order NUMBER)
IS
--</EC-DOC>
BEGIN
    NULL;
END SetTransSortOrderPost;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetTransactionSortOrder
-- Description    :
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
FUNCTION GetTransSortOrder(p_transaction CONT_TRANSACTION%ROWTYPE) RETURN NUMBER
--</EC-DOC>
IS
BEGIN

  RETURN NULL;

END GetTransSortOrder;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetTransSortOrderPre
-- Description    :
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
FUNCTION GetTransSortOrderPre(p_transaction CONT_TRANSACTION%ROWTYPE) RETURN NUMBER
--</EC-DOC>
IS
BEGIN

  RETURN NULL;

END GetTransSortOrderPre;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetTransSortOrderPost
-- Description    :
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
FUNCTION GetTransSortOrderPost(p_transaction CONT_TRANSACTION%ROWTYPE, p_sort_order_number NUMBER) RETURN NUMBER
--</EC-DOC>
IS
BEGIN

  RETURN NULL;

END GetTransSortOrderPost;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetTransSortOrderPost
-- Description    :
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
PROCEDURE ValidateDocVAT (
          p_document_key VARCHAR2)
--</EC-DOC>
IS
BEGIN
  NULL;
END ValidateDocVAT;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetTransSortOrderPost
-- Description    :
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
PROCEDURE ValidateDocVATPre (
          p_document_key VARCHAR2)
--</EC-DOC>
IS
BEGIN
  NULL;
END ValidateDocVATPre;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetTransSortOrderPost
-- Description    :
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
PROCEDURE ValidateDocVATPost (
          p_document_key VARCHAR2)
--</EC-DOC>
IS
BEGIN
  NULL;
END ValidateDocVATPost;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetOriginCountryForTrans
-- Description    : Instead-of-type user exit, REPLACING function
--                  EcDp_Transaction.GetOriginCountryForTrans(p_transaction CONT_TRANSACTION%ROWTYPE)
---------------------------------------------------------------------------------------------------
FUNCTION GetOriginCountryForTrans(p_trans_tmpl_obj_id   VARCHAR2,
                                  p_transaction_key     VARCHAR2,
                                  p_transaction_scope   VARCHAR2,
                                  p_delivery_point_id   VARCHAR2,
                                  p_loading_port_id     VARCHAR2,
                                  p_daytime             DATE)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN

  RETURN NULL;

END GetOriginCountryForTrans;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetDestinationCountryForTrans
-- Description    : Instead-of-type user exit, REPLACING function
--                  EcDp_Transaction.GetDestinationCountryForTrans(p_transaction CONT_TRANSACTION%ROWTYPE)
---------------------------------------------------------------------------------------------------
FUNCTION GetDestinationCountryForTrans(p_trans_tmpl_obj_id VARCHAR2,
                                       p_transaction_key   VARCHAR2,
                                       p_transaction_scope VARCHAR2,
                                       p_delivery_point_id VARCHAR2,
                                       p_discharge_port_id VARCHAR2,
                                       p_daytime           DATE)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN

  RETURN NULL;

END GetDestinationCountryForTrans;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : FillTransactionOLI
-- Description    : Support project specific transaction manipulation.
--                  NOTE that when calling EcDp_Transaction.FillTransaction the procedure
--                  will call FillTransactionPrice,FillTransactionLines and FillTransactionOLI
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
PROCEDURE FillTransactionOLI(p_transaction_key VARCHAR2,
                             p_user            VARCHAR2)
IS

BEGIN
    null;
END FillTransactionOLI;

END ue_Cont_Transaction;