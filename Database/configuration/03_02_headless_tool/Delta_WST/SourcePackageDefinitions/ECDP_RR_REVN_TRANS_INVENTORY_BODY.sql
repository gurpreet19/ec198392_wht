CREATE OR REPLACE PACKAGE BODY EcDp_RR_Revn_Trans_Inventory IS
  /****************************************************************
  ** Package        :  EcDp_RR_Revn_Trans_Inventory, body part
  *****************************************************************/



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copyTemplate
-- Description
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
PROCEDURE copyTemplate(p_template_code VARCHAR2, p_user VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

lv2_new_template_code VARCHAR2(32);

BEGIN

  lv2_new_template_code := Ecdp_Object_Copy.GetCopyObjectCode('TRANS_INVENTORY_TEMPLATE', p_template_code, 'TABLE');

  -- create contract_template
  INSERT INTO trans_inventory_template (template_code, name, created_by)
    (SELECT lv2_new_template_code,
            'Copy of '|| t.name,
            p_user
       FROM trans_inventory_template t
      WHERE template_code = p_template_code);

  --create attributes
  INSERT into trans_inventory_tmpl_attr
    (template_code,
     attribute_name,
     attribute_syntax,
     trans_inventory_scope,
     label_header,
     label,
     uom,
     currency_id,
     format_mask,
     sum_function,
     sort_order,
     created_by)
    SELECT lv2_new_template_code,
           t.attribute_name,
           t.attribute_syntax,
           t.trans_inventory_scope,
           t.label_header,
           t.label,
           t.uom,
           t.currency_id,
           t.format_mask,
           t.sum_function,
           t.sort_order,
           p_user
      FROM trans_inventory_tmpl_attr t
     WHERE t.template_code = p_template_code;

END copyTemplate;


END EcDp_RR_Revn_Trans_Inventory;