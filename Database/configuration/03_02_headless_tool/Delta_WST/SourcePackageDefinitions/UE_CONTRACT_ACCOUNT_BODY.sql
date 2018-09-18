CREATE OR REPLACE PACKAGE BODY ue_Contract_Account IS
/****************************************************************
** Package        :  ue_Contract_Account; body part
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

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validate
-- Description    : Validation logic that will be called upon save on CONTRACT_ACCOUNT class
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE validate(p_contract_id VARCHAR2,
				   p_account_code VARCHAR2)
--</EC-DOC>
IS
BEGIN
	EcDp_Contract_Account.validate(p_contract_id, p_account_code);
END validate;

END ue_Contract_Account;