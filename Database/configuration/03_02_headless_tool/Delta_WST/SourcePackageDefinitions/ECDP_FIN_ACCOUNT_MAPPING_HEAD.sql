CREATE OR REPLACE PACKAGE EcDp_Fin_Account_Mapping is
/****************************************************************
** Package        :  EcDp_Fin_Account_Mapping, body part
**
** $Revision: 1.4 $
**
** Purpose        :  Provide procedure to validate financial account mappings
**                :  Provide special functionality for fin_account_mapping objects.
**
** Documentation  :  www.energy-components.com
**
** Created  : 17.03.2004 14:34:57  TRA
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------

************************************************************************************************************************************************************/
FUNCTION ValidateAccounts (
          p_object_id VARCHAR2,
          p_daytime DATE,
          p_product_id VARCHAR2,
          p_line_item_type VARCHAR2,
          p_fin_code VARCHAR2,
          p_company_id VARCHAR2
)
RETURN VARCHAR2;

END EcDp_Fin_Account_Mapping;