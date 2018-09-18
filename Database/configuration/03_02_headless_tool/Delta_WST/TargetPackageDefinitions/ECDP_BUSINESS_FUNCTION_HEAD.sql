CREATE OR REPLACE PACKAGE EcDp_Business_Function IS
/***********************************************************************
** Package            :  EcDp_Business_Function
**
** $Revision: 1.2 $
**
** Purpose            :  Support function around Business functions tables
**                       used for trigger alignement for old key structure
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

TYPE t_bf_list IS TABLE OF BUSINESS_FUNCTION.BF_CODE%TYPE;
TYPE t_bc_list IS TABLE OF BF_COMPONENT.COMP_CODE%TYPE;

-- Public session variables

l_new_bf_list  t_bf_list;
l_old_bf_list  t_bf_list;

l_new_bc_list  t_bc_list;
l_old_bc_list  t_bc_list;


PROCEDURE AddBFList(p_new_bf_code VARCHAR2,
                    p_old_bf_code VARCHAR2);

PROCEDURE AddBCList(p_new_bf_code VARCHAR2,
                    p_old_bf_code VARCHAR2,
                    p_new_comp_code VARCHAR2,
                    p_old_comp_code VARCHAR2);

FUNCTION getBusinessFunctionNo(p_bf_code VARCHAR2)
RETURN NUMBER;

FUNCTION getBF_ComponentNo(p_bf_code VARCHAR2, p_comp_code VARCHAR2)
RETURN NUMBER;


FUNCTION createBFComponentAction(p_bf_code    VARCHAR2,
                                 p_comp_code  VARCHAR2,
                                 p_item_code  VARCHAR2)
RETURN NUMBER;


FUNCTION getBFCodefromBFCA(p_bf_component_action_no NUMBER)
RETURN VARCHAR2;

FUNCTION getCompCodefromBFCA(p_bf_component_action_no NUMBER)
RETURN VARCHAR2;

FUNCTION getCMI_BFComponentAction(p_bf_code    VARCHAR2,
                                 p_comp_code  VARCHAR2,
                                 p_item_code  VARCHAR2)
RETURN NUMBER;

END EcDp_Business_Function;