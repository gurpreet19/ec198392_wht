CREATE OR REPLACE PACKAGE BODY EcDp_Contract_Availability IS
/****************************************************************
** Package        :  EcDp_Contract_Availability
**
** $Revision: 1.1 $
**
** Purpose        :  Retrieves the calculated quantity with UOM corresponding to available quantity attribute/column
**
** Documentation  :  www.energy-components.com
**
** Created  : 22.12.2005  Stian Skjørestad
**
** Modification history:
**
** Date       Whom  	 Change description:
** --------   ----- 	--------------------------------------

******************************************************************/




--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Function	      : getCalculatedQty
-- Description    : Retrieves value from either vol-, mass- or energy-qty columns if uom is the same as uom from argument.
--				  : If neither is, a lookup in table ctrl_unit_conversion is done to see if any of the uom's present can be converted to this uom.
--				  :	In that case, the corresponding value is converted and returned.
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : cntr_day_dp_availability,
--					ctrl_unit_conversion
--
-- Using functions: ecdp_contract_attribute.getAttributeString
--				  :	ecdp_unit.convertValue
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--------------------------------------------------------------------------------------------------

FUNCTION getCalculatedQty(
	p_object_id			VARCHAR2,
	p_delivery_point_id	VARCHAR2,
	p_daytime			DATE,
	p_comparator_uom	VARCHAR2
	)
RETURN NUMBER
--</EC-DOC>
IS

ln_vol_uom		VARCHAR2(32);
ln_mass_uom		VARCHAR2(32);
ln_energy_uom	VARCHAR2(32);

ln_vol_qty		NUMBER;
ln_mass_qty		NUMBER;
ln_energy_qty	NUMBER;
ln_result		NUMBER	:=-1;


CURSOR 	c_values IS
SELECT	calc_vol_qty, calc_mass_qty, calc_energy_qty
FROM	cntr_day_dp_availability
WHERE 	object_id = p_object_id					AND
		delivery_point_id = p_delivery_point_id	AND
		daytime = p_daytime;

CURSOR	c_conversions(cp_to_unit VARCHAR2) IS
SELECT	from_unit
FROM	ctrl_unit_conversion
WHERE 	to_unit = cp_to_unit;


BEGIN
-- Retrieving all UOM's
ln_vol_uom 		:=	ecdp_contract_attribute.getAttributeString(p_object_id,'DEL_VOL_UOM',p_daytime);
ln_mass_uom 	:=	ecdp_contract_attribute.getAttributeString(p_object_id,'DEL_MASS_UOM',p_daytime);
ln_energy_uom	:=	ecdp_contract_attribute.getAttributeString(p_object_id,'DEL_ENERGY_UOM',p_daytime);


-- Retrieving values
FOR 	x_value IN c_values LOOP
		ln_vol_qty 		:= x_value.calc_vol_qty;
		ln_mass_qty		:= x_value.calc_mass_qty;
		ln_energy_qty	:= x_value.calc_energy_qty;
END LOOP;

-- See if argument uom is present on any calculated value
IF 			p_comparator_uom = ln_vol_uom THEN
			ln_result := ln_vol_qty;
ELSE IF 	p_comparator_uom = ln_mass_uom THEN
			ln_result := ln_mass_qty;
ELSE IF 	p_comparator_uom = ln_energy_uom THEN
			ln_result := ln_energy_qty;
		END IF;
	END IF;
END IF;

IF ln_result != -1 THEN
RETURN ln_result;
END IF;

-- Argument uom not present in calculated values -> Retrieves conversions if available
FOR 		x_conv IN c_conversions(p_comparator_uom) LOOP
IF 			x_conv.from_unit = ln_vol_uom	THEN
			ln_result := ecdp_unit.convertValue(ln_vol_qty,ln_vol_uom,p_comparator_uom);
ELSE IF		x_conv.from_unit = ln_mass_uom	THEN
			ln_result := ecdp_unit.convertValue(ln_mass_qty,ln_mass_uom,p_comparator_uom);
ELSE IF		x_conv.from_unit = ln_energy_uom	THEN
			ln_result := ecdp_unit.convertValue(ln_energy_qty,ln_energy_uom,p_comparator_uom);
		END IF;
	END IF;
END IF;
END LOOP;

IF ln_result = -1 THEN
RETURN NULL;
ELSE
RETURN ln_result;
END IF;

END getCalculatedQty;



END EcDp_Contract_Availability;