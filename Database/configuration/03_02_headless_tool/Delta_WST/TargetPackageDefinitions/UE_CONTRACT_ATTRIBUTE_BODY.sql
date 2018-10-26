CREATE OR REPLACE PACKAGE BODY ue_Contract_Attribute IS
/****************************************************************
** Package        :  ue_Contract_Attribute; body part
**
** $Revision: 1.1.92.1 $
**
** Purpose        :  Special package for attributes that are customer specific
**
** Documentation  :  www.energy-components.com
**
** Created        :  13.12.2005	Kari Sandvik
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
** 10.08.2012 farhaann ECPD-21665: Added new parameter p_object_ec_code in getAttributeString, getAttributeDate and getAttributeNumber
**************************************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function	      : getAttributeString
-- Description    :
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
							 p_object_ec_code VARCHAR2 DEFAULT NULL)
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
-- Description    : Returns a date value for requested attribute, Uses contract template for the attribute definition
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : contract_account, contract_template_attribute
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
						   p_object_ec_code VARCHAR2 DEFAULT NULL)
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
-- Description    : Returns a number value for requested attribute, Uses contract template for the attribute definition
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : contract_account, contract_template_attribute
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
						     p_object_ec_code VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
	ln_value	NUMBER;

BEGIN
	RETURN NULL;
END getAttributeNumber;

END ue_Contract_Attribute;