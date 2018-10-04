CREATE OR REPLACE PACKAGE EcDp_RR_Revn_Trans_Inventory IS
/****************************************************************
** Package        :  EcDp_RR_Revn_Trans_Inventory, header part
**
** $Revision: 1.3 $
**
** Purpose        :  Provide functionality for regulatory reporting Canada
**
** Documentation  :  http://energyextra.tietoenator.com
**
** Created  : 04.06.2010  Stian Skj?tad
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ------      ----- --------------------------------------
********************************************************************/



PROCEDURE copyTemplate (p_template_code VARCHAR2, p_user VARCHAR2 DEFAULT NULL);

END EcDp_RR_Revn_Trans_Inventory;