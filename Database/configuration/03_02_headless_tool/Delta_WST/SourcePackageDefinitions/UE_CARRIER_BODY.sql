CREATE OR REPLACE PACKAGE BODY ue_carrier IS
/******************************************************************************
** Package        :  ue_carrier, body part
**
** $Revision: 1.1 $
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
-- Function       : isUnavailable
-- Description    : returns the template name based on the template type
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
FUNCTION isUnavailable( p_carrier_id VARCHAR2,
						p_daytime DATE)
RETURN VARCHAR2
--</EC-DOC>
IS

lv_ind VARCHAR2(1);
BEGIN

  lv_ind := ecdp_carrier.isUnavailable(p_carrier_id,p_daytime);

  RETURN lv_ind;

 END isUnavailable;

  --<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getUnavailableReason
-- Description    : returns the template name based on the template type
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
FUNCTION getUnavailableReason(p_carrier_id VARCHAR2, p_daytime DATE)
  RETURN VARCHAR2
--</EC-DOC>
 IS

  lv_reason VARCHAR2(300);

BEGIN

  lv_reason := ecdp_carrier.getUnavailableReason(p_carrier_id, p_daytime);

  RETURN lv_reason;

END getUnavailableReason;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getUnavailableReason
-- Description    : returns the template name based on the template type
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
FUNCTION getNextAvailDate(p_carrier_id VARCHAR2, p_daytime DATE)
  RETURN DATE
--</EC-DOC>
 IS
	ld_avail_date DATE;
BEGIN

	ld_avail_date:= ecdp_carrier.getNextAvailDate(p_carrier_id,p_daytime);

  RETURN ld_avail_date;

END getNextAvailDate;

END ue_carrier;