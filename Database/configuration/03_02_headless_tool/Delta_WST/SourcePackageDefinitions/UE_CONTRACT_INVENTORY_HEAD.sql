CREATE OR REPLACE PACKAGE ue_contract_inventory IS
/****************************************************************
** Package        :  ue_contract_inventory; head part
**
** $Revision: 1.1 $
**
** Purpose        :  Handles contract inventory operations
**
** Documentation  :  www.energy-components.com
**
** Created        :  20.07.2012 Lee Wei Yap
**
** Modification history:
**
** Date        Whom  	Change description:
** ----------  -------- -------------------------------------------
** 20.07.2012  leeeewei Added function getTransactionType and getRemCap
******************************************************************************************************/

FUNCTION getTransactionType RETURN VARCHAR2;
FUNCTION getRemCap(p_object_id VARCHAR2,p_daytime DATE, p_inventory_type VARCHAR2) RETURN NUMBER;

END ue_contract_inventory;