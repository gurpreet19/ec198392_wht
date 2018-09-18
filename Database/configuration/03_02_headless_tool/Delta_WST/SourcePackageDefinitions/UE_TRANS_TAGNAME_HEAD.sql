CREATE OR REPLACE PACKAGE Ue_Trans_Tagname IS
/****************************************************************
** Package        :  Ue_Trans_Tagname, header part
*****************************************************************/

FUNCTION getCalcTagId(
   p_mapping_no  NUMBER)
RETURN NUMBER;

END Ue_Trans_Tagname;
