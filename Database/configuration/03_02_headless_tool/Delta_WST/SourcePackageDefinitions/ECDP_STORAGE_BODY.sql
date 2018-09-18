CREATE OR REPLACE PACKAGE BODY EcDp_Storage IS

/****************************************************************
** Package        :  EcDp_Storage, body part
**
** $Revision: 1.1 $
**
** Purpose        :  Support functions for Storage class
**
** Documentation  :  www.energy-components.com
**
** Created  : 05.04.2005  Arild Vervik
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ----------  ----- --------------------------------------
*****************************************************************/

FUNCTION isTankRelated(p_storage_id STORAGE.OBJECT_ID%TYPE,
                       p_tank_object_id TANK.OBJECT_ID%TYPE)
RETURN VARCHAR2

IS

  CURSOR c_storage_parent IS
  SELECT 1 AS test
  FROM stor_version s, tank_version t
  WHERE Nvl(s.OP_PU_ID,'X') = Nvl(t.OP_PU_ID,'X')
  AND   Nvl(s.OP_SUB_PU_ID,'X') = Nvl(t.OP_SUB_PU_ID,Nvl(s.OP_SUB_PU_ID,'X'))
  AND   Nvl(s.OP_AREA_ID,'X') = Nvl(t.OP_AREA_ID,Nvl(s.OP_AREA_ID,'X'))
  AND   Nvl(s.OP_SUB_AREA_ID,'X') = Nvl(t.OP_SUB_AREA_ID,Nvl(s.OP_SUB_AREA_ID,'X'))
  AND   Nvl(s.OP_FCTY_CLASS_2_ID,'X') = Nvl(t.OP_FCTY_CLASS_2_ID,Nvl(s.OP_FCTY_CLASS_2_ID,'X'))
  AND   Nvl(s.OP_FCTY_CLASS_1_ID,'X') = Nvl(t.OP_FCTY_CLASS_1_ID,Nvl(s.OP_FCTY_CLASS_1_ID,'X'))
  AND   s.object_id = p_storage_id
  AND   t.object_id = p_tank_object_id;


  lv2_is_related VARCHAR2(1) := 'N';

BEGIN

  FOR cur IN c_storage_parent LOOP

     lv2_is_related := 'Y';

  END LOOP;

  RETURN lv2_is_related;

END isTankRelated;


END EcDp_Storage;