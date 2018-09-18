CREATE OR REPLACE PACKAGE BODY ue_Contract_Revn IS
/****************************************************************
** Package        :  ue_Contract_Revn; body part
**
** $Revision: 1.5 $
**
** Purpose        :  User exit package for revenue releated functionality on contracts
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
** 14/02/2014  Khairul Affendi  Comment on the ue_contract_sale to prevent error due to new updated parameter. Please refer JIRA ECPD-17240
**************************************************************************************************/

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  copyContract
-- Description    :	This user exit is used when a contract is copied.
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:	Ecdp_Contract_Setup.GenContractCopy, ue_contract_sale.amendContract
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION copyContract(
   p_object_id VARCHAR2, -- to copy from
   p_code      VARCHAR2,
   p_user      VARCHAR2,
   p_cntr_type VARCHAR2 DEFAULT NULL,--to indicate the copy will be Deal contract (D) or Contract Template (T)
   p_new_startdate DATE DEFAULT NULL,
   p_new_enddate DATE DEFAULT NULL)

RETURN VARCHAR2 -- new contract code
--</EC-DOC>
IS
	lv_new_object_id VARCHAR2(32);
	lv_new_code VARCHAR2(32);

BEGIN
	-- Call ecdp function in revenue to create the contract and all its children objects
	-- Note that the ecdp function return the object code and not the object id. The code may NOT be the same as the code sent to the function
	lv_new_code := Ecdp_Contract_Setup.GenContractCopy(p_object_id, p_code, p_user, p_cntr_type, p_new_startdate, p_new_enddate);
	lv_new_object_id := ecdp_objects.GetObjIDFromCode('CONTRACT', lv_new_code);

	-- Call user exit in sale for copying sale specific data (Transport will be called from sale)
	-- ue_contract_sale.amendContract(lv_new_object_id, p_object_id, p_user);


	-- This is to synchronise the ecdp_nav_model_obj_relation nav_model
	ecdp_nav_model_obj_relation.Syncronize_model('TRAN_COMMERCIAL');

	RETURN lv_new_code;

END copyContract;

END ue_Contract_Revn;