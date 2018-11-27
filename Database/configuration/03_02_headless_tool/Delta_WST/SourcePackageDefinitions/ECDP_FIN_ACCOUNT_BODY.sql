CREATE OR REPLACE PACKAGE BODY EcDp_Fin_Account IS
/****************************************************************
** Package        :  EcDp_Fin_Account, body part
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
**     1.6  12042005 SRA   Added function to get accnt for BW interface
**     1.4  07042006 SSK   Modified function GetAccntMappingObjID -> LINE_ITEM_TYPE and PRODUCT_CODE allows value 'ALL'.
                           The "least general" object is returned (TD 5867).
************************************************************************************************************************************************************/




--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Cursor         :   Global cursor to select Accounts
-- Description    :   selects FIN_ACCOUNT_OBJECT that match the criterias in the arguments.
--                    See description in ecdp_fin_account_mapping for details.
--
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
-------------------------------------------------------------------------------------------------------------------------------------------
CURSOR c_obj (cp_daytime DATE, cp_financial_code VARCHAR2, cp_comp_categ VARCHAR2, cp_status VARCHAR2, cp_li_type VARCHAR2, cp_accnt_class VARCHAR2, cp_accnt_category VARCHAR2,cp_product_code VARCHAR2, cp_company_code VARCHAR2) IS
  SELECT
         f.object_id id,
         f.object_code  account_mapping_code,
         decode(fv.company_id, '', 1, NULL, 1, 0)      company_code, --to get match on Company
         decode(fv.product_id, '', 1, NULL, 1, 0)      product_code,
         decode(fv.status_code, 'ALL', 1, 0)           status_code,
         decode(fv.company_category_code, 'ALL', 1, 0) company_category,
         decode(fv.line_item_type, 'ALL', 1, 0)        line_item_type,
         fav.Gl_Account gl_account,
         ec_fin_account.object_code(fav.object_id) as account_code,
         fv.account_class_code acount_class,
         fav.name name1,
         fv.company_id company_id,
         fv.product_id product_id,
         fv.status_code status_code2,
         fv.company_category_code company_category2,
         fv.line_item_type line_item_type2,
         nvl(fav.fin_account_cat_code,fv.fin_account_category) fin_acct_category ,
         fav.fin_cost_object_type cost_obj_type,
         fv.fin_debit_posting_key debit_posting_key,
         fv.fin_credit_posting_key credit_posting_key,
         f.description description,
         fv.financial_code financial_code
    FROM fin_account_mapping     f,
         fin_acc_mapping_version fv,
         fin_account_version     fav
   WHERE f.object_id = fv.object_id
     AND cp_daytime >= fv.daytime
     AND cp_daytime < nvl(fv.end_date, cp_daytime + 1)
     AND cp_daytime >= nvl(f.start_date, cp_daytime - 1)
     AND cp_daytime < nvl(f.end_date, cp_daytime + 1)
     AND fv.fin_account_id = fav.object_id
     AND cp_daytime >= fav.daytime
     AND cp_daytime < nvl(fav.end_date, cp_daytime + 1)
     AND DECODE(cp_financial_code, 'ALL',cp_financial_code,fv.financial_code) =cp_financial_code
     AND DECODE(cp_comp_categ,'ALL',cp_comp_categ,
         DECODE(fv.company_category_code, 'ALL', cp_comp_categ, fv.company_category_code)) = cp_comp_categ
     AND DECODE(cp_status,'ALL',cp_status,
         DECODE(fv.status_code, 'ALL', cp_status, fv.status_code)) = cp_status
     AND DECODE(cp_li_type,'ALL',cp_li_type,
         DECODE(fv.line_item_type, 'ALL', cp_li_type, fv.line_item_type)) = cp_li_type
     AND DECODE(cp_accnt_class, 'ALL',cp_accnt_class,fv.account_class_code) = cp_accnt_class
     AND  decode(cp_accnt_category,'ALL',cp_accnt_category,
         nvl(fav.fin_account_cat_code,fv.fin_account_category)) = nvl(cp_accnt_category, nvl(fav.fin_account_cat_code,fv.fin_account_category))
     AND decode(cp_company_code ,'ALL' ,cp_company_code,'NULL',cp_company_code,' ',cp_company_code,nvl(ec_company.object_code(fv.company_id),cp_company_code)) = cp_company_code
     AND decode(cp_product_code ,'ALL' ,cp_product_code,'NULL',cp_product_code,' ',cp_product_code,nvl(ec_product.object_code(fv.product_id),cp_product_code)) = cp_product_code
    ORDER BY company_code, product_code, line_item_type, company_category, status_code;





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
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetAccntMappingObjID(
   p_financial_code                 VARCHAR2, -- Financial code
   p_comp_categ                     VARCHAR2, -- ALL / 3P / IC
   p_status                         VARCHAR2, -- ACCRUAL / FINAL
   p_li_type                        VARCHAR2, -- PROD/MRKTFEE/ADJ_SALE/etc
   p_accnt_class                    VARCHAR2, -- CREDIT/DEBIT/AP_CREDIT/AP_DEBIT
   p_accnt_category                 VARCHAR2,
   p_product_code                   VARCHAR2, -- 1501/1502/etc
   p_company_code                   VARCHAR2,
   p_customer_id                    VARCHAR2,
   p_vendor_id                      VARCHAR2,
   p_daytime                        DATE,
   p_dist_obj_id                    VARCHAR2,
   p_line_item_key                  VARCHAR2 DEFAULT NULL,
   p_inventory_id                   VARCHAR2 DEFAULT NULL
)

RETURN fin_account_mapping.object_id%TYPE
IS

lv2_object_id fin_account_mapping.object_id%TYPE;

BEGIN

     IF (ue_Fin_Account.isUserExitEnabled = 'TRUE') THEN
         lv2_object_id := ue_Fin_Account.GetAccntMappingObjID(p_financial_code, -- Financial code
                                                              p_comp_categ, -- ALL / 3P / IC
                                                              p_status, -- ACCRUAL / FINAL
                                                              p_li_type, -- PROD/MRKTFEE/ADJ_SALE/etc
                                                              p_accnt_class, -- CREDIT/DEBIT/AP_CREDIT/AP_DEBIT
                                                              p_accnt_category,
                                                              p_product_code,
                                                              p_company_code,
                                                              p_customer_id,
                                                              p_vendor_id,
                                                              p_daytime,
                                                              p_dist_obj_id,
                                                              p_line_item_key,
                                                              p_inventory_id);
     ELSE

         -- All returned objects
         FOR ObjCur IN c_obj (p_daytime, p_financial_code, p_comp_categ, p_status, p_li_type, p_accnt_class,p_accnt_category, p_product_code, p_company_code) LOOP
            lv2_object_id := ObjCur.id; -- Assinging the "least general" object to the variable
            EXIT;
         END LOOP;
     END IF;

    RETURN lv2_object_id;

END GetAccntMappingObjID;

-----------------------------------------------------------------------------------------------------------------------------

FUNCTION GetAccntNo(
   p_object_id VARCHAR2, -- for the account mapping object
   p_target_obj_id VARCHAR2,
   p_daytime   DATE
)

RETURN VARCHAR2

IS

lv2_return_val VARCHAR2(32);

BEGIN

     lv2_return_val := ec_fin_acc_mapping_version.fin_account_id(p_object_id, p_daytime, '<=');
     lv2_return_val := ec_fin_account_version.gl_account(lv2_return_val, p_daytime, '<=');

     IF lv2_return_val = 'CUST_ACCT' THEN

          lv2_return_val := ec_company_version.fin_code(p_target_obj_id, p_daytime, '<=');

     ELSIF lv2_return_val = 'VEND_ACCT' THEN

          lv2_return_val := ec_company_version.fin_code(p_target_obj_id, p_daytime, '<=');

     END IF;

     RETURN lv2_return_val;

END GetAccntNo;



FUNCTION GetFinAccntMappingType(
   p_account VARCHAR2,
   p_daytime DATE
)

RETURN VARCHAR2

IS

  lv2_account_type VARCHAR2(15);

BEGIN

  IF ec_fin_acc_mapping_version.fin_account_id(
             ecdp_objects.GetObjIDFromCode(
                   'FIN_ACCOUNT',
                   p_account),
             p_daytime,
             '<=')is not null THEN
        lv2_account_type := 'REVENUE';
      ELSE
        lv2_account_type := 'CUSTOMER';
      END IF;

      RETURN lv2_account_type;

END GetFinAccntMappingType;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetAccntMappingObjIdTable for Account Mapping assistance Screen
-- Description    : Determines if any FIN_ACCOUNT_OBJECT match the criterias in the arguments.
--                  See description in ecdp_fin_account_mapping for details.
--                  If any match, the objects are returned by this function.
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
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetAccntMappingObjIdTable(
   p_financial_code                 VARCHAR2, -- Financial code
   p_comp_categ                     VARCHAR2, -- ALL / 3P / IC
   p_status                         VARCHAR2, -- ACCRUAL / FINAL
   p_li_type                        VARCHAR2, -- PROD/MRKTFEE/ADJ_SALE/etc
   p_accnt_class                    VARCHAR2, -- CREDIT/DEBIT/AP_CREDIT/AP_DEBIT
   p_accnt_category                 VARCHAR2,
   p_product_code                   VARCHAR2, -- 1501/1502/etc
   p_company_code                   VARCHAR2,
   p_daytime                        DATE
)

RETURN T_TABLE_MIXED_DATA
IS

lo_acct_mapping_obj_table T_TABLE_MIXED_DATA;
lv2_product_id VARCHAR2(51);
lv2_company_id VARCHAR2(51);
lv2_priority    NUMBER;

BEGIN



        lo_acct_mapping_obj_table := T_TABLE_MIXED_DATA();
        lv2_priority := 1;

         -- All returned table of account
         FOR ObjCur IN c_obj (p_daytime, p_financial_code, p_comp_categ, p_status, p_li_type, p_accnt_class,p_accnt_category, p_product_code, p_company_code) LOOP

                  lo_acct_mapping_obj_table.EXTEND(1);
                  lo_acct_mapping_obj_table(lo_acct_mapping_obj_table.LAST) := T_MIXED_DATA(ObjCur.id, NULL);
                  lo_acct_mapping_obj_table(lo_acct_mapping_obj_table.LAST).TEXT_1 :=lv2_priority;
                  lo_acct_mapping_obj_table(lo_acct_mapping_obj_table.LAST).TEXT_2 :=ObjCur.gl_account;
                  lo_acct_mapping_obj_table(lo_acct_mapping_obj_table.LAST).TEXT_3 :=ObjCur.account_mapping_code;
                  lo_acct_mapping_obj_table(lo_acct_mapping_obj_table.LAST).TEXT_4 :=ObjCur.account_code;
                  lo_acct_mapping_obj_table(lo_acct_mapping_obj_table.LAST).TEXT_5 :=ObjCur.acount_class;
                  lo_acct_mapping_obj_table(lo_acct_mapping_obj_table.LAST).TEXT_6 :=ObjCur.name1;
                  lo_acct_mapping_obj_table(lo_acct_mapping_obj_table.LAST).TEXT_7 :=ObjCur.status_code2;
                  lo_acct_mapping_obj_table(lo_acct_mapping_obj_table.LAST).TEXT_8 :=ecdp_objects.GetObjName(ObjCur.company_id,p_daytime);
                  lo_acct_mapping_obj_table(lo_acct_mapping_obj_table.LAST).TEXT_9 :=ecdp_objects.GetObjName(ObjCur.product_id,p_daytime);
                  lo_acct_mapping_obj_table(lo_acct_mapping_obj_table.LAST).TEXT_10 :=EC_PROSTY_CODES.code_text(ObjCur.line_item_type2,'LINE_ITEM_TYPE');
                  lo_acct_mapping_obj_table(lo_acct_mapping_obj_table.LAST).TEXT_11 :=EC_PROSTY_CODES.code_text(ObjCur.company_category2,'COMPANY_CATEGORY_CODE');
                  lo_acct_mapping_obj_table(lo_acct_mapping_obj_table.LAST).TEXT_12 :=EC_PROSTY_CODES.code_text(ObjCur.fin_acct_category,'FIN_ACCOUNT_CATEGORY_CODE');
                  lo_acct_mapping_obj_table(lo_acct_mapping_obj_table.LAST).TEXT_13 :=EC_PROSTY_CODES.code_text(ObjCur.cost_obj_type,'FIN_COST_OBJECT_TYPE');
                  lo_acct_mapping_obj_table(lo_acct_mapping_obj_table.LAST).TEXT_14 :=ObjCur.debit_posting_key ;
                  lo_acct_mapping_obj_table(lo_acct_mapping_obj_table.LAST).TEXT_15 :=ObjCur.credit_posting_key;
                  lo_acct_mapping_obj_table(lo_acct_mapping_obj_table.LAST).TEXT_16 :=ObjCur.description;
                  lo_acct_mapping_obj_table(lo_acct_mapping_obj_table.LAST).TEXT_17 :=ObjCur.id;
                  lo_acct_mapping_obj_table(lo_acct_mapping_obj_table.LAST).TEXT_18 :=EC_PROSTY_CODES.code_text(ObjCur.financial_code,'FINANCIAL_CODE');
                  lo_acct_mapping_obj_table(lo_acct_mapping_obj_table.LAST).TEXT_19 :=ObjCur.company_id;
                  lo_acct_mapping_obj_table(lo_acct_mapping_obj_table.LAST).TEXT_20 :=ObjCur.cost_obj_type;
                  lv2_priority := lv2_priority + 1;
         END LOOP;

    RETURN lo_acct_mapping_obj_table;
END GetAccntMappingObjIdTable;

END EcDp_Fin_Account;