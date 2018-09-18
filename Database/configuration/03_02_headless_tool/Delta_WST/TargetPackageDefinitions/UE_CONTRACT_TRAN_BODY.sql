CREATE OR REPLACE PACKAGE BODY ue_Contract_Tran IS
/****************************************************************
** Package        :  ue_Contract_Tran; body part
**
** $Revision: 1.4 $
**
** Purpose        :  User exit package for transport releated functionality on contracts
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
-- Procedure      : amendContract
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
	NULL;

END amendContract;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : createPrepareContract
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
PROCEDURE createPrepareContract(p_PREPARE_NO NUMBER, p_user VARCHAR2 DEFAULT NULL)
--<EC-DOC>
IS
	lv_new_object_code VARCHAR2(32);
	lv_object_id	VARCHAR2(32);
BEGIN
	-- Vallidations?

	-- If available, it is recommended to use EC Revenue function for copy contract
	-- This will further call revenue, sale and transport copy functions
	-- Additional amendments should be done after

	--lv_new_object_code := ue_Contract_Revn.copyContract(ec_contract_prepare.ref_contract_id(p_PREPARE_NO), ec_contract_prepare.code(p_PREPARE_NO), nvl(p_user, ecdp_context.getAppUser), NULL, ec_contract_prepare.daytime(p_PREPARE_NO), ec_contract_prepare.end_date(p_PREPARE_NO));
	--lv_object_id := ecdp_objects.GetObjIDFromCode('CONTRACT', lv_new_object_code);

	-- Delete prepare contract so that it doesn't show anymore
	-- Or create a status field and update status

	--DELETE contract_prepare where PREPARE_NO = p_PREPARE_NO;

	NULL;

END createPrepareContract;

END ue_Contract_Tran;