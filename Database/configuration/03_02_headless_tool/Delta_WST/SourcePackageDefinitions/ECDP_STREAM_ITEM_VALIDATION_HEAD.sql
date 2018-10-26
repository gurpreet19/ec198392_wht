CREATE OR REPLACE PACKAGE EcDp_Stream_Item_Validation IS
/********************************************************************************************************************************
** Package        :  EcDp_Stream_Item_Validation, header part
**
** $Revision: 1.4 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created  : 27.07.2008  EnergyX Team
**
** Modification history:
**
** Date         Whom  Change description:
** ----------   ----- --------------------------------------
** 27.01.2008   sra   Initial version on 9.1
*********************************************************************************************************************************/


PROCEDURE RunValidation(
  p_type VARCHAR2,
  p_daytime DATE,
  p_check_group VARCHAR2,
  p_user VARCHAR2
  );

PROCEDURE DeleteValidationLists(
  p_daytime DATE
  );

END EcDp_Stream_Item_Validation;