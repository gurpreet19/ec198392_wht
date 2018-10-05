CREATE OR REPLACE PACKAGE BODY EcDp_Fin_Account_Mapping IS
/****************************************************************
** Package        :  EcDp_Fin_Account_Mapping, body part
**
** $Revision: 1.4 $
**
** Purpose        :  Provide procedure to validate financial account mappings
**
** Documentation  :  www.energy-components.com
**
** Created  : 01.10.2002  Henning Stokke
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
**     1.4  11042006 SSK   Modified procedure Validate -> LINE_ITEM_TYPE and PRODUCT_CODE allows value 'ALL'.
                           Less objects are needed for positive validation (TD 5867).
**     1.1  10112006 SSK   Updated package to fit new datamodel due to EC Revenue database migration (TI 4665)
************************************************************************************************************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function      : Validate
-- Description    : Determines if enough financial account objects match the criterias in the arguments.
--                  See comments in validate procedure for details.
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
FUNCTION ValidateAccounts (
          p_object_id VARCHAR2,
          p_daytime DATE,
          p_product_id VARCHAR2,
          p_line_item_type VARCHAR2,
          p_fin_code VARCHAR2,
          p_company_id VARCHAR2
)
RETURN VARCHAR2
IS


CURSOR c_account_class IS
  SELECT DISTINCT o.object_id, oa.account_class_code
   FROM  fin_account_mapping o, fin_acc_mapping_version oa
   WHERE o.object_id = oa.object_id
     AND oa.financial_code = p_fin_code
  INTERSECT
         (SELECT o.object_id, oa.account_class_code
          FROM   fin_account_mapping o, fin_acc_mapping_version oa
          WHERE  o.object_id = oa.object_id
          AND    oa.line_item_type IN (p_line_item_type,decode(p_line_item_type, 'ALL', oa.line_item_type, 'XXX')))
  INTERSECT
         (SELECT o.object_id, oa.account_class_code
          FROM   fin_account_mapping o, fin_acc_mapping_version oa
          WHERE  o.object_id = oa.object_id
          AND    NVL(oa.product_id,'ALL') IN (NVL(p_product_id,'ALL')))
   INTERSECT
         (SELECT o.object_id, oa.account_class_code
          FROM   fin_account_mapping o, fin_acc_mapping_version oa
          WHERE  o.object_id = oa.object_id
          AND    NVL(oa.company_id,'ALL') IN (NVL(p_company_id,'ALL')));

CURSOR c_status_code(cp_account_class VARCHAR2) IS
SELECT DISTINCT oa.status_code
FROM   fin_account_mapping o, fin_acc_mapping_version oa
WHERE  o.object_id = oa.object_id
   AND oa.financial_code = p_fin_code
   AND oa.line_item_type IN (p_line_item_type,decode(p_line_item_type, 'ALL', oa.line_item_type, 'XXX'))
   AND NVL(oa.product_id,'ALL') IN (NVL(p_product_id,'ALL'))
   AND oa.account_class_code = cp_account_class
   AND NVL(oa.company_id,'ALL') IN (NVL(p_company_id,'ALL'));




CURSOR c_company_category(cp_account_class VARCHAR2, cp_status_code VARCHAR2) IS
SELECT DISTINCT o.object_id, oa.company_category_code
  FROM fin_account_mapping o, fin_acc_mapping_version oa
 WHERE o.object_id = oa.object_id
   AND oa.financial_code = p_fin_code
INTERSECT (SELECT o.object_id, oa.company_category_code
             FROM fin_account_mapping o, fin_acc_mapping_version oa
            WHERE o.object_id = oa.object_id
              AND oa.line_item_type IN
                  (p_line_item_type,
                   decode(p_line_item_type, 'ALL', oa.line_item_type, 'XXX'))
           INTERSECT (SELECT o.object_id, oa.company_category_code
                       FROM fin_account_mapping     o,
                            fin_acc_mapping_version oa
                      WHERE o.object_id = oa.object_id
                        AND NVL(oa.product_id,'ALL') IN
                            (NVL(p_product_id,'ALL'))
                        AND NVL(oa.company_id,'ALL') IN
                            (NVL(p_company_id,'ALL'))
                     INTERSECT (SELECT o.object_id, oa.company_category_code
                                 FROM fin_account_mapping     o,
                                      fin_acc_mapping_version oa
                                WHERE o.object_id = oa.object_id
                                  AND oa.account_class_code =
                                      cp_account_class)
                     INTERSECT (SELECT o.object_id, oa.company_category_code
                                 FROM fin_account_mapping     o,
                                      fin_acc_mapping_version oa
                                WHERE o.object_id = oa.object_id
                                  AND oa.status_code = cp_status_code)))
;




missing_account_class EXCEPTION;
missing_status_code EXCEPTION;
missing_company_category EXCEPTION;

lv2_call varchar2(200);
lv2_ng varchar2(200);
lv2_ig varchar2(200);
lv2_jv varchar2(200);

lv2_sall varchar2(200);
lv2_accrual varchar2(200);
lv2_final varchar2(200);

lv2_credit varchar2(200);
lv2_debit varchar2(200);
lv2_ap_credit varchar2(200);
lv2_ap_debit varchar2(200);
lv2_return VARCHAR2(200) := 'Validated - OK';

BEGIN

/**

1.	For the selected Line Item Type / Product, check that objects for CREDIT, DEBIT, AP_CREDIT, and AP_DEBIT Account Class Codes are present.
2.	For each Line Item Type / Product / Account Class Code combination, both ACCRUAL and FINAL Status code objects must exist; or one with the ALL Status code.
3.	For each Line Item Type / Product / Account Class Code / Status code combination, both IC and 3P Company Category code objects must exist; or one with the ALL Company Category code.

*/


     FOR CurAcctClass IN c_account_class LOOP
        FOR CurStatus IN c_status_code(CurAcctClass.Account_Class_Code) LOOP
           FOR CurComp IN c_company_category(CurAcctClass.Account_Class_Code, CurStatus.Status_Code) LOOP
              IF (CurComp.Company_Category_Code = 'ALL') THEN lv2_call := 'ALL'; END IF;
              IF (CurComp.Company_Category_Code = 'NG') THEN lv2_ng := 'NG'; END IF;
              IF (CurComp.Company_Category_Code = 'IG') THEN lv2_ig := 'IG'; END IF;
              IF (CurComp.Company_Category_Code = 'JV') THEN lv2_jv := 'JV'; END IF;
           END LOOP;
           IF (lv2_call IS NULL AND (lv2_ng IS NULL OR lv2_ig IS NULL OR lv2_jv IS NULL) ) THEN
              RAISE missing_company_category;
           END IF;

           IF (CurStatus.Status_Code = 'ALL') THEN lv2_sall := 'ALL'; END IF;
           IF (CurStatus.Status_Code = 'ACCRUAL') THEN lv2_accrual := 'ACCRUAL'; END IF;
           IF (CurStatus.Status_Code = 'FINAL') THEN lv2_final := 'FINAL'; END IF;
        END LOOP;
        IF (lv2_sall IS NULL AND (lv2_accrual IS NULL OR lv2_final IS NULL) ) THEN
           RAISE missing_status_code;
        END IF;

        IF (CurAcctClass.Account_Class_Code = 'CREDIT') THEN lv2_credit := 'CREDIT'; END IF;
        IF (CurAcctClass.Account_Class_Code = 'DEBIT') THEN lv2_debit := 'DEBIT'; END IF;
     END LOOP;
     IF (lv2_credit IS NULL or lv2_debit IS NULL) THEN
        RAISE missing_account_class;
     END IF;

 RETURN 'Account Mapping Complete';

EXCEPTION

   WHEN missing_account_class THEN
        RETURN 'Account Mapping Not Complete - Missing account classes';


   WHEN missing_status_code THEN
        RETURN 'Account Mapping Not Complete - Missing Status Code';

   WHEN missing_company_category THEN
        RETURN 'Account Mapping Not Complete - Missing Company Category';



END ValidateAccounts;

END EcDp_Fin_Account_Mapping;