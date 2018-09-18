CREATE OR REPLACE PACKAGE BODY ue_Fin_Cost_Object IS
/****************************************************************
** Package        :  ue_Fin_Cost_Object, body part
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
** 1.1	    22.11.2007 SRA  Initial version
************************************************************************************************************************************************************/

FUNCTION GetCostObjID(
   p_type VARCHAR2,
   p_company_id VARCHAR2,
   p_dist_id VARCHAR2,
   p_node_id VARCHAR2,
   p_line_item_type VARCHAR2,
   p_product_id VARCHAR2,
   p_daytime   DATE,
   p_line_item_key VARCHAR2 DEFAULT NULL,
   p_inventory_id VARCHAR2 DEFAULT NULL
)

RETURN fin_cost_object.object_id%TYPE
IS
BEGIN
    RETURN NULL;
END GetCostObjID;

FUNCTION GetCostObjSearchCriteria(
          p_daytime                              DATE,
          p_contract_id                          VARCHAR2,
          p_transaction_template_id              varchar2,
          p_price_object_id                      VARCHAR2,
          p_line_item_id                         VARCHAR2,
          p_product_id                           VARCHAR2,
          p_line_item_type                       VARCHAR2,
          p_profit_center_id                     VARCHAR2,
          p_account_id                           VARCHAR2
          )
RETURN T_TABLE_MIXED_DATA
IS
BEGIN
    RETURN NULL;
END GetCostObjSearchCriteria;

END ue_Fin_Cost_Object;