CREATE OR REPLACE PACKAGE BODY ue_cntr_attr_dimension IS
/******************************************************************************
** Package        :  ue_cntr_attr_dimension, body part
**
** $Revision: 1.1.2.1 $
**
** Purpose        :  Includes user-exit functionality for contract attributes screen
**
** Documentation  :  www.energy-components.com
**
** Created  : 03.08.2012 Annida Farhana
**
** Modification history:
**
** Date        Whom     Change description:
** ------      -----    -----------------------------------------------------------------------------------------------
** 03.08.2012  farhaann ECPD-21665: Initial version
*/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function	      : getAttributeString
-- Description    : Returns a string value for requested attribute
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
FUNCTION getAttributeString (p_contract_id VARCHAR2,
							 p_attribute_name VARCHAR2,
							 p_daytime DATE,
							 p_object_ec_code VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
lv_value	VARCHAR2(240);

BEGIN
RETURN NULL;
END getAttributeString;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getAttributeDate
-- Description    : Returns a date value for requested attribute
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
FUNCTION getAttributeDate (p_contract_id VARCHAR2,
						   p_attribute_name VARCHAR2,
						   p_daytime DATE,
						   p_object_ec_code VARCHAR2)
RETURN DATE
--</EC-DOC>
IS
ld_value	DATE;

BEGIN
RETURN NULL;
END getAttributeDate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getAttributeNumber
-- Description    : Returns a number value for requested attribute
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
FUNCTION getAttributeNumber (p_contract_id VARCHAR2,
							 p_attribute_name VARCHAR2,
						     p_daytime DATE,
							 p_object_ec_code VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
ln_value	NUMBER;

BEGIN
RETURN NULL;
END getAttributeNumber;

END ue_cntr_attr_dimension;