CREATE OR REPLACE PACKAGE BODY ue_carrier_cooldown IS
/******************************************************************************
** Package        :  ue_carrier_cooldown, body part
**
** $Revision: 1.1.2.1 $
**
** Purpose        :  Includes user-exit functionality for carrier cooldown
**
** Documentation  :  www.energy-components.com
**
** Created  : 10.12.2012 Lee Wei Yap
**
** Modification history:
**
** Date   		Whom  	  Change description:
** -----  		----- 	  -----------------------------------------------------------------------------------------------
** 10.12.2012 	leeeewei  Added initiateCarrierTank,initializeTemp,copyCooldown,deleteCarrierTank
*/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : initiateCarrierTank
-- Description    : Initiate empty rows for all tanks for the selected vessels
--
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
PROCEDURE initiateCarrierTank (p_carrier_id VARCHAR2)
--</EC-DOC>
IS

BEGIN

	EcBp_Carrier_Cooldown.initiateCarrierTank(p_carrier_id);

END initiateCarrierTank;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : initializeTemp
-- Description    : initialize temperature for a given carrier
--
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
PROCEDURE initializeTemp (p_carrier_id VARCHAR2,p_tank_no NUMBER)
--</EC-DOC>
IS

BEGIN

	EcBp_Carrier_Cooldown.initializeTemp(p_carrier_id,p_tank_no);

END initializeTemp;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copyCooldown
-- Description    : Calculate unload value
--
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
PROCEDURE copyCooldown(p_from_carrier_id VARCHAR2,
                       p_to_carrier_id   VARCHAR2)
--</EC-DOC>
 IS
BEGIN

	EcBp_Carrier_Cooldown.copyCooldown(p_from_carrier_id, p_to_carrier_id);

END copyCooldown;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : deleteCarrierTank
-- Description    : Delete carrier tank will also delete its child record (cooldown)
--
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
PROCEDURE deleteCarrierTank (p_carrier_id VARCHAR2, p_tank_no NUMBER)
--</EC-DOC>
IS

BEGIN

	EcBp_Carrier_Cooldown.deleteCarrierTank (p_carrier_id, p_tank_no);

END deleteCarrierTank;

END ue_carrier_cooldown;