CREATE OR REPLACE PACKAGE BODY ue_contract_inventory IS
/****************************************************************
** Package        :  ue_contract_inventory; body part
**
** $Revision: 1.1.2.1 $
**
** Purpose        :  Handles contract inventory operations
**
** Documentation  :  www.energy-components.com
**
** Created        :  10.08.2012 Lee Wei Yap
**
** Modification history:
**
** Date        Whom    Change description:
** ----------  -------- -------------------------------------------
** 10.08.2012  leeeewei	Added getTransactionType and getRemCap
**************************************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTransactionType
-- Description    : Return transaction type of a contract inventory
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
FUNCTION getTransactionType
RETURN VARCHAR2
--</EC-DOC>
IS

BEGIN

	RETURN NULL;

END getTransactionType;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getRemCap
-- Description    : Return remaining capacity of a contract inventory
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
FUNCTION getRemCap(p_object_id VARCHAR2,p_daytime DATE, p_inventory_type VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN

	RETURN NULL;

END getRemCap;

END ue_contract_inventory;