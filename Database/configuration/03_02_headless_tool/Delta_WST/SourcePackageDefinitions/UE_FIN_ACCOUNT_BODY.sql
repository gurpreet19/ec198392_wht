CREATE OR REPLACE PACKAGE BODY ue_Fin_Account IS
/**************************************************************************************************
** Package        :  ue_Fin_Account, body part
**
** $Revision: 1.5 $
**
** Purpose        :  Provide special functions on Financials Accounts for interfacing with Finance applications
**
** Documentation  :  www.energy-components.com
**
** Created  : 22.11.2007  EnergyComponents Team
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
** 1.1      22.11.2007 SRA  Initial version
**************************************************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetAccntMappingObjID
-- Description    : Determines if any FIN_ACCOUNT_OBJECT match the criterias in the arguments.
--                  See description in ecdp_fin_account_mapping for details.
--                  If any match, the object is returned by this function.
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
---------------------------------------------------------------------------------------------------
FUNCTION GetAccntMappingObjID(
   p_case VARCHAR2, -- Financial code
   p_comp_categ VARCHAR2, -- ALL / 3P / IC
   p_status VARCHAR2, -- ACCRUAL / FINAL
   p_li_type VARCHAR2, -- PROD/MRKTFEE/ADJ_SALE/etc
   p_accnt_class VARCHAR2, -- CREDIT/DEBIT/AP_CREDIT/AP_DEBIT
   p_acct_category VARCHAR2,
   p_product_code VARCHAR2, -- 1501/1502/etc
   p_company_code VARCHAR2,
   p_customer_id VARCHAR2,
   p_vendor_id VARCHAR2,
   p_daytime   DATE,
   p_dist_obj_id VARCHAR2,  --Object id of the field
   p_line_item_key VARCHAR2 DEFAULT NULL,
   p_inventory_id VARCHAR2 DEFAULT NULL
)

RETURN fin_account_mapping.object_id%TYPE

IS

BEGIN

    RETURN NULL;

END GetAccntMappingObjID;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GenFinPostingData
-- Description    : Instead-of user exit for generating posting data.
-- Preconditions  : isGenFinPostingDateUEEnabled = 'TRUE'
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
---------------------------------------------------------------------------------------------------
PROCEDURE GenFinPostingData(p_object_id VARCHAR2,
                           p_document_id VARCHAR2,
                           p_fin_code VARCHAR2,
                           p_status VARCHAR2,
                           p_doc_total NUMBER,
                           p_company_obj_id VARCHAR2,
                           p_daytime   DATE,
                           p_user      VARCHAR2
                           )
IS
BEGIN
    RETURN;
END GenFinPostingData;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GenFinPostingDataPre
-- Description    : PRE user exit for generating posting data.
-- Preconditions  : isGenFinPostingDateUEEnabled = 'TRUE'
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
---------------------------------------------------------------------------------------------------
PROCEDURE GenFinPostingDataPre(p_object_id VARCHAR2,
                           p_document_id VARCHAR2,
                           p_fin_code VARCHAR2,
                           p_status VARCHAR2,
                           p_doc_total NUMBER,
                           p_company_obj_id VARCHAR2,
                           p_daytime   DATE,
                           p_user      VARCHAR2
                           )
IS
BEGIN
    RETURN;
END GenFinPostingDataPre;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GenFinPostingDataPost
-- Description    : POST user exit for generating posting data.
-- Preconditions  : isGenFinPostingDateUEEnabled = 'TRUE'
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
---------------------------------------------------------------------------------------------------
PROCEDURE GenFinPostingDataPost(p_object_id VARCHAR2,
                           p_document_id VARCHAR2,
                           p_fin_code VARCHAR2,
                           p_status VARCHAR2,
                           p_doc_total NUMBER,
                           p_company_obj_id VARCHAR2,
                           p_daytime   DATE,
                           p_user      VARCHAR2
                           )
IS
BEGIN
    RETURN;
END GenFinPostingDataPost;


END ue_Fin_Account;