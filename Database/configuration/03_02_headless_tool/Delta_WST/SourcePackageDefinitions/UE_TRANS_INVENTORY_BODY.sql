CREATE OR REPLACE PACKAGE BODY ue_Trans_Inventory IS
/****************************************************************
** Package        :  ue_Trans_Inventory, body part
**
** $Revision: 1.1 $
**
** Purpose        :  Provide special functions on Inventory. Use EcDp_Objects for basis functions
**
** Documentation  :  www.energy-components.com
**
** erd  : 23.02.2014 Brandon Lewis
**
** Modification history:
**
** Date       Whom  Change description:
** ---------- ----- --------------------------------------

*****************************************************************/

FUNCTION SkipInventory(p_contract_id VARCHAR2,p_object_id VARCHAR2,p_daytime DATE)  RETURN VARCHAR IS
  lv2_return VARCHAR2(3) DEFAULT 'NO';
BEGIN
  RETURN  lv2_return;
END SkipInventory;

FUNCTION SkipLine(p_contract_id VARCHAR2,p_object_id VARCHAR2,p_daytime DATE,p_line_tag VARCHAR2)  RETURN VARCHAR IS
  lv2_return VARCHAR2(3) DEFAULT 'NO';


BEGIN

  RETURN lv2_return;
END SkipLine;

FUNCTION SkipProduct(p_contract_id VARCHAR2,p_object_id VARCHAR2,p_daytime DATE,p_product_id VARCHAR2,p_cost_type varchar2,p_line_tag VARCHAR2)  RETURN VARCHAR IS
  lv2_return VARCHAR2(3) DEFAULT 'NO';

BEGIN

  RETURN lv2_return;
END SkipProduct;

FUNCTION SkipVariable(p_contract_id VARCHAR2,p_object_id VARCHAR2,p_daytime DATE,p_product_id VARCHAR2,p_cost_type varchar2,
  p_line_tag VARCHAR2,p_exec_order number,config_variable varchar2)  RETURN VARCHAR IS
  lv2_return VARCHAR2(3) DEFAULT 'NO';
  lv2_object varchar2(32);

BEGIN


  RETURN lv2_return;
END SkipVariable;


FUNCTION SkipAllDim(p_contract_id VARCHAR2,p_object_id VARCHAR2,p_daytime DATE,p_product_id VARCHAR2,p_cost_type varchar2, p_line_tag VARCHAR2,p_dimension_id VARCHAR2)     RETURN VARCHAR IS
  lv2_return VARCHAR2(3) DEFAULT 'NO';
BEGIN
  RETURN lv2_return;
END SkipAllDIM;

END ue_Trans_Inventory;