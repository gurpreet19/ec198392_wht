CREATE OR REPLACE PACKAGE ue_Contract_Account IS
/****************************************************************
** Package        :  ue_Contract_Account; head part
**
** $Revision:  $
**
** Purpose        :  Special package for Contract Account that are customer specific
**
** Documentation  :  www.energy-components.com
**
** Created        :  21.08.2015	sharawan
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
** 21.08.2015	sharawan	ECPD-31682: Initial Version - Added validation logic procedure for Contract Account screen
**************************************************************************************************/

PROCEDURE validate(p_contract_id VARCHAR2, p_account_code VARCHAR2);

END ue_Contract_Account;