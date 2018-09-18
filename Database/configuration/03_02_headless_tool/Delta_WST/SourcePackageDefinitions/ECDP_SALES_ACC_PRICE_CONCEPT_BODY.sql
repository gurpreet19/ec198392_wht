CREATE OR REPLACE PACKAGE BODY EcDp_Sales_Acc_Price_Concept IS
/******************************************************************************
** Package        :  EcDp_Sales_Acc_Price_Concept, body part
**
** $Revision: 1.1 $
**
** Purpose        :  Contains constants for Sales Account Price Concepts. Replace package EcDp_Sales_Account_Category
**
** Documentation  :  www.energy-components.com
**
** Created  : 06.12.2005 Stian Skj?tad
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------

******************************************************************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : NORMAL_GAS
-- Description    : Returns the account category code for Normal Gas calculations
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
-- Behaviour      : Returns the constant 'NORMAL_GAS'
--
---------------------------------------------------------------------------------------------------
FUNCTION NORMAL_GAS
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
   RETURN 'NORMAL_GAS';
END NORMAL_GAS;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : OFF_SPEC_GAS
-- Description    : Returns the account category code for Off-spec Gas calculations
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
-- Behaviour      : Returns the constant 'OFF_SPEC_GAS'
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
-- Function       : TOTAL_DELIVERED_GAS
-- Description    : Returns the account category code for Total Delivered Gas calculations
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
-- Behaviour      : Returns the constant 'TOTAL_DELIVERED_GAS'
--
---------------------------------------------------------------------------------------------------
FUNCTION TOTAL_DELIVERED_GAS
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
   RETURN 'TOTAL_DELIVERED_GAS';
END TOTAL_DELIVERED_GAS;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : TAKE_OR_PAY_PENALTY
-- Description    : Returns the account category code for Take-or-Pay Penalty calculations
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
-- Behaviour      : Returns the constant 'TAKE_OR_PAY_PENALTY'
--
---------------------------------------------------------------------------------------------------
FUNCTION TAKE_OR_PAY_PENALTY
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
   RETURN 'TAKE_OR_PAY_PENALTY';
END TAKE_OR_PAY_PENALTY;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : INVOICE_TOTAL
-- Description    : Returns the account category code for Invoice Total calculations
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
-- Behaviour      : Returns the constant 'INVOICE_TOTAL'
--
---------------------------------------------------------------------------------------------------
FUNCTION INVOICE_TOTAL
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
   RETURN 'INVOICE_TOTAL';
END INVOICE_TOTAL;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : ADJUSTMENT
-- Description    : Returns the account category code for Adjustment accounts
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
-- Behaviour      : Returns the constant 'ADJUSTMENT'
--
---------------------------------------------------------------------------------------------------
FUNCTION ADJUSTMENT
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
   RETURN 'ADJUSTMENT';
END ADJUSTMENT;


END EcDp_Sales_Acc_Price_Concept;