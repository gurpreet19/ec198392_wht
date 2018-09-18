CREATE OR REPLACE PACKAGE BODY Ue_Trans_Tagname IS
/****************************************************************
** Package        :  Ue_Trans_Tagname, body part
**
** This package is used to generate new tag numbers for new mappings which were copied from existing mappings
** Upgrade processes will never replace this package.
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCalcTagId
-- Description    : Returns calculated Tag Id
---------------------------------------------------------------------------------------------------
FUNCTION getCalcTagId(
   p_mapping_no  NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getCalcTagId;

END Ue_Trans_Tagname;
