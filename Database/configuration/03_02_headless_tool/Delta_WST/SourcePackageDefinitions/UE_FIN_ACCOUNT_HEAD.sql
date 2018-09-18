CREATE OR REPLACE PACKAGE ue_Fin_Account IS
/****************************************************************
**
** NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
** NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
** Enable this User Exit by setting variable below "isUserExitEnabled" = 'TRUE'
** NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
** NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
**
** Package        :  EcDp_Fin_Account, header part
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
*****************************************************************/
isUserExitEnabled VARCHAR2(32) := 'FALSE';
isGenFinPostingDataUEE VARCHAR2(32) := 'FALSE';
isGenFinPostingDataPreUEE VARCHAR2(32) := 'FALSE';
isGenFinPostingDataPostUEE VARCHAR2(32) := 'FALSE';

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
RETURN fin_account_mapping.object_id%TYPE;

PROCEDURE GenFinPostingData(p_object_id VARCHAR2,
                           p_document_id VARCHAR2,
                           p_fin_code VARCHAR2,
                           p_status VARCHAR2,
                           p_doc_total NUMBER,
                           p_company_obj_id VARCHAR2,
                           p_daytime   DATE,
                           p_user      VARCHAR2
                           );


PROCEDURE GenFinPostingDataPre(p_object_id VARCHAR2,
                           p_document_id VARCHAR2,
                           p_fin_code VARCHAR2,
                           p_status VARCHAR2,
                           p_doc_total NUMBER,
                           p_company_obj_id VARCHAR2,
                           p_daytime   DATE,
                           p_user      VARCHAR2
                           );


PROCEDURE GenFinPostingDataPost(p_object_id VARCHAR2,
                           p_document_id VARCHAR2,
                           p_fin_code VARCHAR2,
                           p_status VARCHAR2,
                           p_doc_total NUMBER,
                           p_company_obj_id VARCHAR2,
                           p_daytime   DATE,
                           p_user      VARCHAR2
                           );


END ue_Fin_Account;