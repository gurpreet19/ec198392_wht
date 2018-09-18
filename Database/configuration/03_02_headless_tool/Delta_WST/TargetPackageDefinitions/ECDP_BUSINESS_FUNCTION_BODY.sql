CREATE OR REPLACE PACKAGE BODY EcDp_Business_Function IS
/***********************************************************************
** Package            :  EcDp_Business_Function
**
** $Revision: 1.2 $
**
** Purpose            :  Data related function around Business functions tableso manage 2 dimensional arrays
**
**
** Documentation  :  www.energy-components.com
**
** Created  : 14.01.2008  Arild Vervik
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ------      ----- --------------------------------------
***************************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : AddBFList
-- Description    : Populate temporary table used to avoid mutating trigger
--
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE AddBFList(p_new_bf_code VARCHAR2, p_old_bf_code VARCHAR2)
--</EC-DOC>

IS

BEGIN

  IF l_new_bf_list IS NULL THEN

    l_new_bf_list := t_bf_list();
    l_old_bf_list := t_bf_list();

  END IF;

  l_new_bf_list.EXTEND;
  l_old_bf_list.EXTEND;

  l_new_bf_list(l_new_bf_list.LAST) := p_new_bf_code;
  l_old_bf_list(l_old_bf_list.LAST) := p_old_bf_code;

END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : AddBCList
-- Description    : Populate temporary table used to avoid mutating trigger
--
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE AddBCList(p_new_bf_code VARCHAR2,
                    p_old_bf_code VARCHAR2,
                    p_new_comp_code VARCHAR2,
                    p_old_comp_code VARCHAR2)
--</EC-DOC>

IS

BEGIN

  IF l_new_bc_list IS NULL THEN

    l_new_bf_list  :=  t_bf_list();
    l_old_bf_list  :=  t_bf_list();
    l_new_bc_list  :=  t_bc_list();
    l_old_bc_list  :=  t_bc_list();

  END IF;

  l_new_bf_list.EXTEND;
  l_old_bf_list.EXTEND;
  l_new_bc_list.EXTEND;
  l_old_bc_list.EXTEND;

  l_new_bf_list(l_new_bf_list.LAST) := p_new_bf_code;
  l_old_bf_list(l_old_bf_list.LAST) := p_old_bf_code;
  l_new_bc_list(l_new_bc_list.LAST) := p_new_comp_code;
  l_old_bc_list(l_old_bc_list.LAST) := p_old_comp_code;

END;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getBusinessFunctionNo
-- Description    : Find Business_Function_No based on BF_CODE (old PK)
--
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getBusinessFunctionNo(p_bf_code VARCHAR2)
RETURN NUMBER
--</EC-DOC>

IS
  CURSOR c_bf IS
  SELECT business_function_no
  FROM business_function
  WHERE bf_code = p_bf_code
  ORDER BY business_function_no;  -- To make it deterministic just in case of duplicates

  ln_business_function_no NUMBER;


BEGIN

  FOR cBF IN c_bf LOOP
     ln_business_function_no := cBF.business_function_no;
     EXIT;
  END LOOP;

  RETURN ln_business_function_no;


END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getBF_ComponentNo
-- Description    : Find BF_COMPONENT_NO based on BF_CODE,COMP_CODE (old PK)
--
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getBF_ComponentNo(p_bf_code VARCHAR2, p_comp_code VARCHAR2)
RETURN NUMBER
--</EC-DOC>

IS
  CURSOR c_bfc IS
  SELECT bf_component_no
  FROM bf_component
  WHERE bf_code = p_bf_code
  AND   comp_code = p_comp_code
  ORDER BY business_function_no;  -- To make it deterministic just in case of duplicates

  ln_bf_component_no NUMBER;


BEGIN

  FOR cBFc IN c_bfc LOOP
     ln_bf_component_no := cBFc.bf_component_no;
     EXIT;
  END LOOP;

  RETURN ln_bf_component_no;


END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : createBFComponentAction
-- Description    : Find or create entry in BF_Component_Action for given BF_CODE,COMP_CODE (old PK)
--
-- Preconditions  : Only relevant from CNTX_MENU_ITEM trigger, when BF_COMPONENT_ACTION
--                  is populated automatically, assumes that BCA.NAME = CMI.ITEM_CODE
-- Postcondition  :
--
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :  Check if row exists, if not create it.
--
---------------------------------------------------------------------------------------------------
FUNCTION createBFComponentAction(p_bf_code    VARCHAR2,
                                 p_comp_code  VARCHAR2,
                                 p_item_code  VARCHAR2)
RETURN NUMBER
--</EC-DOC>

IS
  CURSOR c_bca IS
  SELECT bf_component_action_no
  FROM bf_component_action bca, bf_component bc
  WHERE bca.bf_component_no = bc.bf_component_no
  AND   bc.bf_code = p_bf_code
  AND   bc.comp_code = p_comp_code
  AND   bca.name = p_item_code
  ORDER BY bf_component_action_no;  -- To make it deterministic just in case of duplicates

  ln_bf_component_action_no NUMBER;
  ln_bf_component_no  NUMBER;

BEGIN

  FOR cBca IN c_bca LOOP

     ln_bf_component_action_no := cBca.bf_component_action_no;
     EXIT;

  END LOOP;

  IF ln_bf_component_action_no IS NULL THEN

    ln_bf_component_no := getBF_ComponentNo(p_bf_code, p_comp_code);

    INSERT INTO bf_component_action(bf_component_no,name,url)
    VALUES (ln_bf_component_no,p_item_code,'/'||p_item_code||'MenuBtn')
    RETURNING bf_component_action_no INTO ln_bf_component_action_no;

  END IF;



  RETURN ln_bf_component_action_no;


END;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getBFCodefromBFCA
-- Description    : Find BF_CODE given bf_component_action_no
--
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getBFCodefromBFCA(p_bf_component_action_no NUMBER)
RETURN VARCHAR2
--</EC-DOC>

IS
  CURSOR c_bca IS
  SELECT bc.bf_code
  FROM bf_component_action bca, bf_component bc
  WHERE bca.bf_component_no = bc.bf_component_no
  AND   bca.bf_component_action_no = p_bf_component_action_no;


  lv2_bf_code BUSINESS_FUNCTION.BF_CODE%TYPE;


BEGIN

  FOR cBca IN c_bca LOOP
     lv2_bf_code := cBca.bf_code;
     EXIT;
  END LOOP;

  RETURN lv2_bf_code;


END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getCompCodefromBFCA
-- Description    : Find COMP_CODE given bf_component_action_no
--
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getCompCodefromBFCA(p_bf_component_action_no NUMBER)
RETURN VARCHAR2
--</EC-DOC>

IS
  CURSOR c_bca IS
  SELECT bc.comp_code
  FROM bf_component_action bca, bf_component bc
  WHERE bca.bf_component_no = bc.bf_component_no
  AND   bca.bf_component_action_no = p_bf_component_action_no;


  lv2_comp_code BUSINESS_FUNCTION.BF_CODE%TYPE;


BEGIN

  FOR cBca IN c_bca LOOP
     lv2_comp_code := cBca.comp_code;
     EXIT;
  END LOOP;

  RETURN lv2_comp_code;


END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getCMI_BFComponentAction
-- Description    : Find COMP_CODE given bf_component_action_no
--
-- Preconditions  :
-- Postcondition  :
--
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getCMI_BFComponentAction(p_bf_code    VARCHAR2,
                                 p_comp_code  VARCHAR2,
                                 p_item_code  VARCHAR2)
RETURN NUMBER
--</EC-DOC>


IS
  CURSOR c_cmi IS
  SELECT bf_component_action_no
  FROM cntx_menu_item
  WHERE bf_code = p_bf_code
  AND   comp_code = p_comp_code
  AND   item_code = p_item_code
  ORDER BY bf_component_action_no;  -- To make it deterministic just in case of duplicates

  ln_bf_component_action_no NUMBER;
  ln_bf_component_no  NUMBER;

BEGIN

  FOR cCMI IN c_cmi LOOP

     ln_bf_component_action_no := cCMI.bf_component_action_no;
     EXIT;

  END LOOP;


  RETURN ln_bf_component_action_no;


END;



END EcDp_Business_Function;