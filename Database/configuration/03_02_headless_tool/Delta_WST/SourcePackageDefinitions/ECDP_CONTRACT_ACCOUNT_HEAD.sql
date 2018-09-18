CREATE OR REPLACE PACKAGE EcDp_Contract_Account IS
/****************************************************************
** Package        :  EcDp_Contract_Account; head part
**
** $Revision:  $
**
** Purpose        :  Encapsulates functionality and values that stem from contract accounts
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

END EcDp_Contract_Account;