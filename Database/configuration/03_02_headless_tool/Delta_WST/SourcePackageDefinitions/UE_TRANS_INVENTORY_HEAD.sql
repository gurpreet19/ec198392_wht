CREATE OR REPLACE PACKAGE ue_Trans_Inventory IS
/****************************************************************
** Package        :  ue_Trans_Inventory, header part
**
** $Revision: 1.1 $
**
** Purpose        :  Provide special functions on Inventory handling. Use EcDp_Objects for basis functions
**
** Documentation  :  www.energy-components.com
**
** Created        : 23.02.2014 Brandon Lewis
**
** Modification history:
**
** Date        Whom rec_trans_inv_gen_log Change description:
** ------      ----- --------------------------------------
*****************************************************************/
FUNCTION SkipInventory(p_contract_id VARCHAR2,p_object_id VARCHAR2,p_daytime DATE)  RETURN VARCHAR ;
FUNCTION SkipLine(p_contract_id VARCHAR2,p_object_id VARCHAR2,p_daytime DATE,p_line_tag VARCHAR2)  RETURN VARCHAR ;
FUNCTION SkipProduct(p_contract_id VARCHAR2,p_object_id VARCHAR2,p_daytime DATE,p_product_id VARCHAR2,p_cost_type varchar2,p_line_tag VARCHAR2)  RETURN VARCHAR ;
FUNCTION SkipAllDim(p_contract_id VARCHAR2,p_object_id VARCHAR2,p_daytime DATE,p_product_id VARCHAR2,p_cost_type varchar2,p_line_tag VARCHAR2,p_dimension_id VARCHAR2)     RETURN VARCHAR ;
FUNCTION SkipVariable(p_contract_id VARCHAR2,p_object_id VARCHAR2,p_daytime DATE,p_product_id VARCHAR2,p_cost_type varchar2,p_line_tag VARCHAR2,p_exec_order number,config_variable varchar2)  RETURN VARCHAR;
END ue_Trans_Inventory;