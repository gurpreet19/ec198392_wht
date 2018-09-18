CREATE OR REPLACE PACKAGE BODY ue_Contract_Attribute IS
/****************************************************************
** Package        :  ue_Contract_Attribute; body part
**
** $Revision: 1.4 $
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
** 10.08.2012 farhaann ECPD-21414: Added new parameter p_object_ec_code in getAttributeString, getAttributeDate and getAttributeNumber
** 07.02.2014 farhaann ECPD-26256: Added new function, assignSortOrder
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

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : assignSortOrder
-- Description    : Assign sort order to attribute name if sort order is empty.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : cntr_template_attribute
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION assignSortOrder (p_contract_id VARCHAR2, p_attribute_name VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_max_sort(cp_contract_id VARCHAR2, cp_attribute_name VARCHAR2)  IS
SELECT MAX(sort_order) sort_order
  FROM cntr_template_attribute a
 WHERE template_code = ec_contract.template_code(cp_contract_id)
   AND dimension_type = ec_cntr_template_attribute.dimension_type(ec_contract.template_code(cp_contract_id), cp_attribute_name);

CURSOR c_null_sort(cp_contract_id VARCHAR2, cp_attribute_name VARCHAR2)  IS
SELECT attribute_name
  FROM cntr_template_attribute a
 WHERE template_code = ec_contract.template_code(cp_contract_id)
   AND dimension_type = ec_cntr_template_attribute.dimension_type(ec_contract.template_code(cp_contract_id), cp_attribute_name)
 ORDER BY attribute_name ASC;

ln_max_sort NUMBER;
ln_return_sort NUMBER :=0;

BEGIN

ln_return_sort := ec_cntr_template_attribute.sort_order(ec_contract.template_code(p_contract_id), p_attribute_name);

IF ln_return_sort IS NULL THEN
  FOR cur_max_sort IN c_max_sort(p_contract_id,p_attribute_name) LOOP
       ln_max_sort := nvl(cur_max_sort.sort_order,0);
  END LOOP;
  ln_return_sort:=ln_max_sort;

  FOR cur_null_sort IN c_null_sort(p_contract_id,p_attribute_name) LOOP
    ln_return_sort := ln_return_sort+1;
    IF(p_attribute_name=cur_null_sort.attribute_name) THEN
      EXIT;
    END IF;
  END LOOP;
END IF;
RETURN ln_return_sort;
END assignSortOrder;

END ue_Contract_Attribute;