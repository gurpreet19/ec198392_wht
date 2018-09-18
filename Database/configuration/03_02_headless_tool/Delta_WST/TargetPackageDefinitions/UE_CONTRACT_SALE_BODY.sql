CREATE OR REPLACE PACKAGE BODY ue_Contract_Sale IS
/****************************************************************
** Package        :  ue_Contract_Sale; body part
**
** $Revision: 1.2 $
**
** Purpose        :  User exit package for sale releated functionality on contracts
**				  :  Any implementation found here is considered an example implementaiont.
**				  :	 Project may override and adjust this ue package
**
** Documentation  :  www.energy-components.com
**
** Created        :  03.02.2009	Kari Sandvik
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
**************************************************************************************************/
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : genContractParcelCodes
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE amendContract(p_new_object_id VARCHAR2, p_from_object_id VARCHAR2, p_user VARCHAR2 DEFAULT NULL)
--<EC-DOC>
IS

BEGIN
	-- Call user exit in transport for copying transport specific data
	ue_contract_tran.amendContract(p_new_object_id, p_from_object_id, p_user);

END amendContract;


END ue_Contract_Sale;