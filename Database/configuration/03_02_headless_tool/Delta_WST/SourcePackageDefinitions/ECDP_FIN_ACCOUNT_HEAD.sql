CREATE OR REPLACE PACKAGE EcDp_Fin_Account IS
/****************************************************************
** Package        :  EcDp_Fin_Account, header part
**
** $Revision: 1.20 $
**
** Purpose        :  Provide special functions on Financials Accounts for interfacing with Finance applications
**
** Documentation  :  www.energy-components.com
**
** Created  : 01.10.2002  Henning Stokke
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
** 1.4	    24.03.2004 GD  Added function GetAcctMappingType
*****************************************************************/

FUNCTION GetAccntMappingObjID(
   p_financial_code VARCHAR2, -- Financial code
   p_comp_categ VARCHAR2, -- ALL / 3P / IC
   p_status VARCHAR2, -- ACCRUAL / FINAL
   p_li_type VARCHAR2, -- PROD/MRKTFEE/ADJ_SALE/etc
   p_accnt_class VARCHAR2, -- CREDIT/DEBIT/AP_CREDIT/AP_DEBIT
   p_accnt_category VARCHAR2,
   p_product_code VARCHAR2, -- 1501/1502/etc
   p_company_code VARCHAR2,
   p_customer_id VARCHAR2,
   p_vendor_id VARCHAR2,
   p_daytime   DATE,
   p_dist_obj_id VARCHAR2,
   p_line_item_key VARCHAR2 DEFAULT NULL,
   p_inventory_id VARCHAR2 DEFAULT NULL
)
RETURN fin_account_mapping.object_id%TYPE;

FUNCTION GetAccntNo(
   p_object_id VARCHAR2,
   p_target_obj_id VARCHAR2, -- customer id
   p_daytime   DATE
)

RETURN VARCHAR2;

FUNCTION GetFinAccntMappingType(
   p_account VARCHAR2,
   p_daytime DATE
)

RETURN VARCHAR2;

FUNCTION GetAccntMappingObjIdTable(
   p_financial_code                 VARCHAR2, -- Financial code
   p_comp_categ                     VARCHAR2, -- ALL / 3P / IC
   p_status                         VARCHAR2, -- ACCRUAL / FINAL
   p_li_type                        VARCHAR2, -- PROD/MRKTFEE/ADJ_SALE/etc
   p_accnt_class                    VARCHAR2, -- CREDIT/DEBIT/AP_CREDIT/AP_DEBIT
   p_accnt_category                 VARCHAR2,
   p_product_code                    VARCHAR2, -- 1501/1502/etc
   p_company_code                     VARCHAR2,
   p_daytime                        DATE
)
RETURN T_TABLE_MIXED_DATA;

END EcDp_Fin_Account;