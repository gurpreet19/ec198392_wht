CREATE OR REPLACE PACKAGE BODY ue_Inventory IS
/****************************************************************
** Package        :  ue_Inventory, body part
**
** $Revision: 1.3 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created  : 11.05.2009
**
** Modification history:
**
** Version  Date         Whom   Change description:
** -------  ------       -----  --------------------------------------
******************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GenMthBookingData
-- Description    : Support project specific account assignment
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
---------------------------------------------------------------------------------------------------
PROCEDURE GenMthBookingData(p_object_id VARCHAR2
       ,p_daytime   DATE
       ,p_user      VARCHAR2)
IS

BEGIN

    RETURN;

END GenMthBookingData;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : CalcPricingValue
-- Description    : Support project specific pricingvalue calculation
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
---------------------------------------------------------------------------------------------------
PROCEDURE CalcPricingValue(p_object_id VARCHAR2, p_daytime DATE, p_user VARCHAR2)
IS

BEGIN

    RETURN;

END CalcPricingValue;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : CalcCurrencyValues
-- Description    : Support project specific currency calculation
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
---------------------------------------------------------------------------------------------------
PROCEDURE CalcCurrencyValues(p_object_id VARCHAR2, p_daytime DATE, p_user VARCHAR2)
IS

BEGIN

    RETURN;

END CalcCurrencyValues;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : ValidateInventory User Exits
-- Description    : Supports project specific validation on inventory valuation upon setting it to VALID1.
-- Preconditions  : Inventory valuation must be at level OPEN. Pre and Post UE can not be combined with the Instead Of UE.
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
-----------------------------------------------------------------------------------------------------
PROCEDURE ValidateInventoryPre(p_object_id VARCHAR2,
                               p_daytime DATE)
IS
BEGIN
  NULL;
END ValidateInventoryPre;

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE ValidateInventory(p_object_id VARCHAR2,
                            p_daytime DATE)
IS
BEGIN
  NULL;
END ValidateInventory;

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE ValidateInventoryPost(p_object_id VARCHAR2,
                                p_daytime DATE)
IS
BEGIN
  NULL;
END ValidateInventoryPost;

END ue_Inventory;