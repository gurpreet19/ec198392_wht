CREATE OR REPLACE PACKAGE BODY EcDp_Delivery_Event_Type IS
/******************************************************************************
** Package        :  EcDp_Delivery_Event_Type, body part
**
** $Revision: 1.1 $
**
** Purpose        :  Contains constants for Delivery Event Type codes.
**
** Documentation  :  www.energy-components.com
**
** Created        :  16.12.2004 Bent Ivar Helland
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
** 22.12.2004  BIH   Initial version (first build / handover to test)
** 11.01.2005  BIH   Added / cleaned up documentation
** 09.08.2005 kaurrnar	Added Renomination function
********************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : OFF_SPEC_GAS
-- Description    : Returns the Delivery Event Type code for off-spec gas events
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
-- Behaviour      : Returns 'OFF_SPEC_GAS'
--
---------------------------------------------------------------------------------------------------
FUNCTION OFF_SPEC_GAS
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
   RETURN 'OFF_SPEC_GAS';
END OFF_SPEC_GAS;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : RENOMINATION
-- Description    : Returns the Delivery Event Type code for renomination events
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
-- Behaviour      : Returns 'RENOMINATION'
--
---------------------------------------------------------------------------------------------------
FUNCTION RENOMINATION
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
   RETURN 'RENOMINATION';
END RENOMINATION;




--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : QUANTITY
-- Description    : Returns the Delivery Event Type code for quantity gas events
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
-- Behaviour      : Returns 'QTY'
--
---------------------------------------------------------------------------------------------------
FUNCTION QTY
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
   RETURN 'QTY';
END QTY;

END EcDp_Delivery_Event_Type;
