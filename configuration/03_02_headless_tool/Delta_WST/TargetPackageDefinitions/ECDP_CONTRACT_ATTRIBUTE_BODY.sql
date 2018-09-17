CREATE OR REPLACE PACKAGE BODY EcDp_Contract_Attribute IS
/****************************************************************
** Package        :  EcBp_Contract; body part
**
** $Revision: 1.15.14.3 $
**
** Purpose        :  Enables the retreival of contract attribute values.
**           The functions will alwasy return a value based on the contract template
**
** Documentation  :  www.energy-components.com
**
** Created        :  08.12.2005  Kari Sandvik
**
** Modification history:
**
** Date        Whom    Change description:
** ----------  -----   -------------------------------------------
** 14-Jan-2009 oonnnng ECPD-9827: Update the ecdp_date_time.getCurrentSysdate with p_daytime for lv_attribute_type = 'OBJECT' in getAttributeValueAsString function.
** 04-Feb-2009 oonnnng ECPD-9219: Remove those lines that find the format mask if the data type is number, in getAttributeValueAsString() function.
                                  Replace format mask if the data type is date with 'yyyy-mm-dd hh24:mi:ss' , in getAttributeValueAsString() function.
** 05.05.2009 leeeewei ECPD-11287: Added new procedure validateContractAttributeDate to validate daytime of contract attributes against the start and end date of contract
** 10.08.2012 farhaann ECPD-21665: Added new parameter p_object_ec_code in getAttributeString, getAttributeDate and getAttributeNumber
**                               : Modified getAttributeValueAsString to have checking for user exit
** 28.02.2013 sharawan ECPD-23454: Add support in getAttributeString, getAttributeDate and getAttributeNumber function for retrieving values for DIMENSIONED attributes
**                                 other than USER_EXIT.
** 14.08.2013 leeeewei ECPD-25045: Added new function getSumCntrQty
**************************************************************************************************/

CURSOR c_template_attribute(cp_contract_id VARCHAR2, cp_attribute_name VARCHAR2)  IS
SELECT  a.attribute_type, a.data_type, a.attribute_syntax, a.dimension_type, ec_prosty_codes.CODE_TEXT(a.format_mask, 'CNTR_FORMAT_MASK' ) format_mask, Nvl(a.time_span, 'DAY') time_span, c.start_year
FROM    cntr_template_attribute a, contract c
WHERE   c.object_id = cp_contract_id
        AND c.template_code = a.template_code
        AND a.attribute_name = cp_attribute_name;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAttributeDaytime
-- Description    : Determines the actual daytime to use for attribute lookup if we're looking for
--                  the value for a given contract day, month or year.
--
-- Preconditions  : The time span parameter should reflect the nature of the attribute and is used
--                  to find the correct contract day / year offsets to apply. Valid values are DAY, MTH or YR.
--                  The input date must have a format that corresponds to the time span, so if for example the time span
--                  is YEAR then the input date must represent a logical contract year (zero month/day/hour/minute/seconds).
--                  Assumes that the contract attributes all have daytimes that are whole days (zero hour/minute/seconds).
--                  Assumes that there the contract day offset is never negative.
-- Postconditions :
--
-- Using tables   : contract
--
-- Using functions: getContractYearStartDate
--
-- Configuration
-- required       :
--
-- Behaviour      : The p_time_span parameter is used to determine the correct daytime to use
--                  in the attribute table. If the contract start within the period, then the
--                  contract start date is used. Otherwise the period start is used.
--
---------------------------------------------------------------------------------------------------
FUNCTION getAttributeDaytime (
  p_object_id     VARCHAR2,
  p_date          DATE,
  p_time_span     VARCHAR2
)
RETURN DATE
--</EC-DOC>
IS
   CURSOR c_contract IS
   SELECT start_year
   FROM contract
   WHERE object_id = p_object_id;

   -- ld_contract_start DATE;
   ln_start_start    NUMBER;

BEGIN

   -- Assumptions:
   --  1) All config done on day level (no time stamp on attribute or object daytimes)
   --  2) No negative contract day offsets
   --  3) getContractYearStartDate handles this itself so that we can use it from here...

   -- Assumption 1+2 means that it is correct to return the contract day itself for daily timespans
   IF p_time_span IS NULL OR p_time_span = 'DAY' THEN
      RETURN p_date;
   END IF;

   -- We need the contract start date. Assume p_object_id is a valid contract (available in SALE)
   FOR cur_Contract IN c_contract LOOP
     ln_start_start := cur_Contract.start_year;
   END LOOP;

   IF p_time_span = 'MTH' THEN
      RETURN p_date;
   END IF;

   IF p_time_span = 'YR' THEN

      -- Logic change,
      RETURN TRUNC(ADD_MONTHS(p_date,ln_start_start));

   END IF;

END getAttributeDaytime;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getAttributeString
-- Description    : Returns a string value for requested attribute, Uses contract template for the attribute definition
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
FUNCTION getAttributeString (p_contract_id VARCHAR2,
              p_attribute_name VARCHAR2,
              p_daytime DATE,
              p_is_contract_date VARCHAR2 DEFAULT 'N',
              p_object_ec_code VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
--</EC-DOC>
IS
  lv_value  VARCHAR2(240);
  lv_attribute_type  VARCHAR2(32);
  lv2_time_span  VARCHAR2(32);
  ld_daytime  DATE;
  ln_year_start NUMBER;

BEGIN
  ld_daytime := p_daytime;
  -- get attribute definition
  FOR curTempAttr IN c_template_attribute (p_contract_id, p_attribute_name) LOOP
    lv_attribute_type := curTempAttr.attribute_type;
    lv2_time_span := curTempAttr.time_span;
    ln_year_start := curTempAttr.start_year;
  END LOOP;

  IF p_is_contract_date = 'Y' AND lv2_time_span = 'YR' THEN
	ld_daytime := TRUNC(ADD_MONTHS(p_daytime,ln_year_start));
  END IF;

  IF lv_attribute_type = 'USER_EXIT' THEN
	lv_value := ue_contract_attribute.getAttributeString(p_contract_id, p_attribute_name, ld_daytime, p_object_ec_code);
  ELSE
    IF p_object_ec_code IS NULL THEN
       lv_value := ec_contract_attribute.attribute_string(p_contract_id, p_attribute_name, ld_daytime, '<=');
    ELSE
       lv_value := ec_cntr_attr_dimension.attribute_string(p_contract_id, p_attribute_name, p_object_ec_code, ld_daytime, '<=');
    END IF;
  END IF;

  RETURN lv_value;
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
              p_is_contract_date VARCHAR2 DEFAULT 'N',
              p_object_ec_code VARCHAR2 DEFAULT NULL)
RETURN DATE
--</EC-DOC>
IS

  ld_value  DATE;
  lv_attribute_type  VARCHAR2(32);
  lv2_time_span  VARCHAR2(32);
  ld_daytime  DATE;
  ln_year_start NUMBER;

BEGIN
  -- get attribute definition
  ld_daytime := p_daytime;

  FOR curTempAttr IN c_template_attribute (p_contract_id, p_attribute_name) LOOP
    lv_attribute_type := curTempAttr.attribute_type;
    lv2_time_span := curTempAttr.time_span;
    ln_year_start := curTempAttr.start_year;
  END LOOP;

  IF p_is_contract_date = 'Y' AND lv2_time_span = 'YR' THEN
	ld_daytime := TRUNC(ADD_MONTHS(p_daytime,ln_year_start));
  END IF;

  IF lv_attribute_type = 'USER_EXIT' THEN
    ld_value := ue_contract_attribute.getAttributeDate(p_contract_id, p_attribute_name, ld_daytime, p_object_ec_code);
  ELSE
    IF p_object_ec_code IS NULL THEN
       ld_value := ec_contract_attribute.attribute_date(p_contract_id, p_attribute_name, ld_daytime, '<=');
    ELSE
       ld_value := ec_cntr_attr_dimension.attribute_date(p_contract_id, p_attribute_name, p_object_ec_code, ld_daytime, '<=');
    END IF;
  END IF;

  RETURN ld_value;
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
              p_is_contract_date VARCHAR2 DEFAULT 'N',
              p_object_ec_code VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  ln_value  NUMBER;
  lv_attribute_type  VARCHAR2(32);
  lv2_time_span  VARCHAR2(32);
  ld_daytime  DATE;
  ln_year_start NUMBER;

BEGIN
  -- get attribute definition
  ld_daytime := p_daytime;

  FOR curTempAttr IN c_template_attribute (p_contract_id, p_attribute_name) LOOP
    lv_attribute_type := curTempAttr.attribute_type;
    lv2_time_span := curTempAttr.time_span;
    ln_year_start := curTempAttr.start_year;
  END LOOP;

  IF p_is_contract_date = 'Y' AND lv2_time_span = 'YR' THEN
      ld_daytime := TRUNC(ADD_MONTHS(p_daytime,ln_year_start));
  END IF;

  IF lv_attribute_type = 'USER_EXIT' THEN
    ln_value := ue_contract_attribute.getAttributeNumber(p_contract_id, p_attribute_name, ld_daytime, p_object_ec_code);
  ELSE
    IF p_object_ec_code IS NULL THEN
       ln_value := ec_contract_attribute.attribute_number(p_contract_id, p_attribute_name, ld_daytime, '<=');
    ELSE
       ln_value := ec_cntr_attr_dimension.attribute_number(p_contract_id, p_attribute_name, p_object_ec_code, ld_daytime, '<=');
    END IF;
  END IF;

  RETURN ln_value;
END getAttributeNumber;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getAttributeValueAsString
-- Description    : Returns a string value for requested attribute, Uses contract template for the attribute definition
--          		It also returns the 'nice' value if the attribute type is EC_CODE, OBJECT, or UOM
--					If a boolean data type and value is null, N is returned
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
FUNCTION getAttributeValueAsString (p_contract_id VARCHAR2,
              p_attribute_name VARCHAR2,
              p_daytime DATE,
              p_object_ec_code VARCHAR2 default NULL)
RETURN VARCHAR2
--</EC-DOC>
IS
  lv_value  VARCHAR2(240);
  ln_value  NUMBER;
  lv_data_type VARCHAR2(32);
  lv_attribute_type  VARCHAR2(32);
  lv_attribute_syntax  VARCHAR2(240);
  lv_dimension_type VARCHAR2(240);
  lv_format_mask  VARCHAR2(32);
  lv_dec_sep  VARCHAR2(32);
  lv_group_sep  VARCHAR2(32);

BEGIN
  -- get attribute definition
  FOR curTempAttr IN c_template_attribute (p_contract_id, p_attribute_name) LOOP
    lv_data_type := curTempAttr.data_type;
    lv_attribute_type := curTempAttr.attribute_type;
    lv_attribute_syntax := curTempAttr.attribute_syntax;
    lv_format_mask := curTempAttr.format_mask;
    lv_dimension_type := curTempAttr.dimension_type;
  END LOOP;

  IF lv_data_type = 'NUMBER' THEN
    IF lv_dimension_type is null then
		ln_value := ecdp_contract_attribute.getAttributeNumber(p_contract_id, p_attribute_name, p_daytime);
    ELSE
		IF lv_attribute_type = 'USER_EXIT' THEN
			ln_value := ue_cntr_attr_dimension.getAttributeNumber(p_contract_id, p_attribute_name, p_daytime, p_object_ec_code);
		ELSE
			ln_value := ec_cntr_attr_dimension.attribute_number(p_contract_id, p_attribute_name, p_object_ec_code, p_daytime, '<=');
		END IF;
    END IF;

    IF ln_value IS NOT NULL THEN
		lv_value := ln_value;
    END IF;

  ELSIF lv_data_type = 'DATE' THEN
    IF lv_format_mask IS NULL THEN
		lv_format_mask := 'yyyy-mm-dd';
    END IF;

	IF lv_dimension_type is null then
       lv_value := TO_CHAR(ecdp_contract_attribute.getAttributeDate(p_contract_id, p_attribute_name, p_daytime), 'yyyy-mm-dd hh24:mi:ss');
    ELSE
		IF lv_attribute_type = 'USER_EXIT' THEN
			lv_value := TO_CHAR(ue_cntr_attr_dimension.getAttributeDate(p_contract_id, p_attribute_name, p_daytime, p_object_ec_code),  'yyyy-mm-dd hh24:mi:ss');
		ELSE
			lv_value := TO_CHAR(ec_cntr_attr_dimension.attribute_date(p_contract_id, p_attribute_name, p_object_ec_code, p_daytime, '<='),  'yyyy-mm-dd hh24:mi:ss');
		END IF;
    END IF;

  ELSIF lv_data_type = 'BOOLEAN' THEN
	IF lv_dimension_type is null THEN
		lv_value := ecdp_contract_attribute.getAttributeString(p_contract_id, p_attribute_name, p_daytime);
	ELSE
		IF lv_attribute_type = 'USER_EXIT' THEN
			lv_value := ue_cntr_attr_dimension.getAttributeString(p_contract_id, p_attribute_name, p_daytime, p_object_ec_code);
		ELSE
			lv_value := ec_cntr_attr_dimension.attribute_string(p_contract_id, p_attribute_name, p_object_ec_code, p_daytime, '<=');
		END IF;
	END IF;

	IF (lv_value IS NULL) THEN
		lv_value := 'N';
	END IF;

  ELSE
    IF lv_dimension_type is null THEN
        lv_value := ecdp_contract_attribute.getAttributeString(p_contract_id, p_attribute_name, p_daytime);
    ELSE
		IF lv_attribute_type = 'USER_EXIT' THEN
			lv_value := ue_cntr_attr_dimension.getAttributeString(p_contract_id, p_attribute_name, p_daytime, p_object_ec_code);
		ELSE
			lv_value := ec_cntr_attr_dimension.attribute_string(p_contract_id, p_attribute_name, p_object_ec_code, p_daytime, '<=');
		END IF;
    END IF;

    IF lv_attribute_type = 'EC_CODE' THEN
      lv_value := ec_prosty_codes.code_text(lv_value, lv_attribute_syntax);
    ELSIF lv_attribute_type = 'OBJECT' THEN
      lv_value := ecdp_objects.GetObjName(lv_value, p_daytime);
    ELSIF lv_attribute_type = 'UOM' THEN
      lv_value := ecdp_unit.GetUnitLabel(lv_value);
    END IF;

  END IF;

  RETURN lv_value;
END getAttributeValueAsString;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validateContractAttributeDate
-- Description    : Check if daytime of contract attribute is within the start date and end date of a contract
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
-- Behaviour      : Validates the contract attribute against the start date and end date of a contract.
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateContractAttributeDate(p_object_id VARCHAR2,
										p_attribute_name VARCHAR2,
										p_daytime DATE)

--</EC-DOC>
IS
BEGIN

IF (ec_cntr_template_attribute.time_span(ec_contract.template_code(p_object_id),p_attribute_name) = 'YR' AND
    TRUNC(EcDp_Objects.getOBjStartDate(p_object_id), 'YYYY') > p_daytime) OR
   (ec_cntr_template_attribute.time_span(ec_contract.template_code(p_object_id),p_attribute_name) = 'MTH' AND
    TRUNC(EcDp_Objects.getOBjStartDate(p_object_id), 'MM') > p_daytime) OR
   (ec_cntr_template_attribute.time_span(ec_contract.template_code(p_object_id),p_attribute_name) = 'DAY' AND
    TRUNC(EcDp_Objects.getOBjStartDate(p_object_id)) > p_daytime)

THEN

       RAISE_APPLICATION_ERROR(-20109,'Daytime is less than owner objects start date: ' || EcDp_Objects.getOBjStartDate(p_object_id));

END IF;

IF p_daytime >= nvl(EcDp_Objects.getObjEndDate(p_object_id),p_daytime + 1) THEN

       Raise_Application_Error(-20109,'Daytime must be less than owner objects end date: ' || EcDp_Objects.getObjEndDate(p_object_id));

END IF;

END  validateContractAttributeDate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSumCntrQty
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CONTRACT_SEASONALITY
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Sum contract quantities in contract seasonality
--
---------------------------------------------------------------------------------------------------
FUNCTION getSumCntrQty(p_object_id VARCHAR2, p_contract_year DATE)
  --</EC-DOC>
 RETURN NUMBER IS

  ln_sum NUMBER := 0;

  cursor c_sum is
    select sum(c.qty) sumvalue
      from contract_seasonality c
     where c.object_id = p_object_id
       and c.contract_year = p_contract_year;

BEGIN

  for cur_sum in c_sum loop
    ln_sum := cur_sum.sumvalue;
  end loop;

  return ln_sum;

END getSumCntrQty;

END EcDp_Contract_Attribute;