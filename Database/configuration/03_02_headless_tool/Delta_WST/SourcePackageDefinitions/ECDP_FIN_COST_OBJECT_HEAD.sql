CREATE OR REPLACE PACKAGE EcDp_Fin_Cost_Object IS
/****************************************************************
** Package        :  EcDp_Fin_Cost_Object, header part
**
** $Revision: 1.19 $
**
** Purpose        :  Provide special functions on Financials Cost Objects for interfacing with Finance applications
**
** Documentation  :  www.energy-components.com
**
** Created  : 01.10.2002  Henning Stokke
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
**
*****************************************************************/
CURSOR gc_cost_obj(cp_daytime DATE, cp_node_id VARCHAR2, cp_line_item_type VARCHAR2, cp_product_id VARCHAR2,cp_company_id VARCHAR2,cp_dist_id VARCHAR2,cp_type VARCHAR2,cp_dist_object_type VARCHAR2 DEFAULT NULL ) IS
SELECT
row_number() OVER (ORDER BY line_item_type,node_id,fv.product_id) priority,
f.object_id id,
fv.product_id
FROM fin_cost_object f, fin_cost_object_version fv
WHERE f.object_id = fv.object_id
   AND cp_daytime >= fv.daytime
   AND cp_daytime < NVL(fv.end_date, cp_daytime + 1)
   AND cp_daytime >= NVL(f.start_date, cp_daytime - 1)
   AND cp_daytime < NVL(f.end_date, cp_daytime + 1)
   AND fv.fin_cost_object_type= DECODE(cp_type,'ALL',fv.fin_cost_object_type,cp_type)
   AND fv.dist_object_type=NVL(cp_dist_object_type,fv.dist_object_type)
   AND fv.company_id = DECODE(cp_company_id,'ALL',fv.company_id,cp_company_id)
   AND NVL(fv.profit_center_id,'XX') =DECODE(cp_dist_id,NULL,'XX','ALL',fv.profit_center_id,cp_dist_id)
   AND (NVL(fv.node_id,'xx')=DECODE(cp_node_id,NULL,'XX','ALL',fv.node_id,cp_node_id) OR fv.node_id IS NULL )
   AND (NVL(fv.line_item_type,'xx')=DECODE(cp_line_item_type,NULL,'XX','ALL',fv.line_item_type,cp_line_item_type) OR fv.line_item_type IS NULL )
   AND (fv.product_id IS NULL OR NVL(fv.product_id,'XX') = DECODE(cp_product_id,NULL,'XX','ALL',fv.product_id,cp_product_id))
   ORDER BY line_item_type,node_id,fv.product_id;

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
RETURN fin_cost_object.object_id%TYPE;

FUNCTION GetCostObject(p_object_id VARCHAR2, p_daytime DATE)
  RETURN VARCHAR2;

FUNCTION GetExternalRef(p_object_id VARCHAR2, p_daytime DATE)
  RETURN VARCHAR2;


PROCEDURE ValidateField(
          p_field_id                VARCHAR2,
          p_profit_center_id        VARCHAR2
          );

FUNCTION GetCostObjAccounts(
							   p_type                            VARCHAR2,
							   p_company_id                      VARCHAR2,
							   p_dist_type                       VARCHAR2,
							   p_profit_centre_id                VARCHAR2,
							   p_node_id	                     VARCHAR2,
							   p_line_item_type                  VARCHAR2,
							   p_product_id                      VARCHAR2,
							   p_daytime                         DATE
							  )
RETURN T_TABLE_MIXED_DATA;

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
RETURN T_TABLE_MIXED_DATA;


END EcDp_Fin_Cost_Object;