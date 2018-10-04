CREATE OR REPLACE PACKAGE BODY EcBp_Price_Value IS
/******************************************************************************
** Package        :  EcBp_Price_Value, body part
**
** $Revision: 1.1 $
**
** Purpose        :  working with price_values
**
** Documentation  :  www.energy-components.com
**
** Created        :  05.12.2005 Jean Ferre
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
** 03.01.06		eideekri	added procedure setPriceConceptCode
********************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : validateDelete
-- Description    : Check if CALC_PRICE_VALUE is null. If null the user is allowed to delete, otherwise a error message should be prompted
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : product_price_value
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE validateDelete(
  	p_object_id   				VARCHAR2,
  	p_price_concept_code   	VARCHAR2,
  	p_price_element_code    VARCHAR2,
	p_daytime					DATE
)
--</EC-DOC>
IS
	ln_price_value    NUMBER;

	CURSOR c_price_value IS
		SELECT calc_price_value
		FROM product_price_value
		WHERE object_id = p_object_id
			AND price_concept_code = p_price_concept_code
			AND price_element_code = p_price_element_code
			AND daytime = p_daytime;
BEGIN
	FOR curValue IN c_price_value LOOP
		ln_price_value := curValue.calc_price_value;
	END LOOP;

	IF ln_price_value IS NOT NULL THEN
		RAISE_APPLICATION_ERROR(-20521,'Not allowed to delete when a calculated price exist');
	END IF;
END validateDelete;

END EcBp_Price_Value;