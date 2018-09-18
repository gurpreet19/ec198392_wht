CREATE OR REPLACE PACKAGE BODY EcDp_Stream_DPT_Value IS

/****************************************************************
** Package        :  EcDp_Stream_DPT_Value (BODY)
**
** $Revision: 1.4 $
**
** Purpose        :  This package provide data access service to:
**                   - STRM_DPT_CONVERSION table
**
** Documentation  :  www.energy-components.com
**
** Created  : 08.01.2008  Arief Zaki
**
** Modification history:
**
** Date        Whom     Change description:
** ------      ----     --------------------------------------
** 08.01.2008  zakiiari ECPD-7226: Initial version
** 14.05.09    oonnnng  ECPD-11791: Added copyToNewDaytime() function.
** 03.08.09    embonhaf ECPD-11153 Added interpolation calculation support for VCF.
*****************************************************************/

FUNCTION COL_BO
RETURN VARCHAR2
IS
BEGIN
  RETURN 'BO';
END COL_BO;

FUNCTION COL_BW
RETURN VARCHAR2
IS
BEGIN
  RETURN 'BW';
END COL_BW;

FUNCTION COL_BG
RETURN VARCHAR2
IS
BEGIN
  RETURN 'BG';
END COL_BG;

FUNCTION COL_RS
RETURN VARCHAR2
IS
BEGIN
  RETURN 'RS';
END COL_RS;

FUNCTION COL_SP_GRAV
RETURN VARCHAR2
IS
BEGIN
  RETURN 'SP_GRAV';
END COL_SP_GRAV;

FUNCTION COL_VCF
RETURN VARCHAR2
IS
BEGIN
  RETURN 'VCF';
END COL_VCF;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDensityAbove (Local function)
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :  - STRM_DPT_CONVERSION
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getDensityAbove(p_object_id STREAM.OBJECT_ID%TYPE, p_daytime DATE, p_density NUMBER)
RETURN NUMBER
--</EC-DOC>
IS
  ln_retval           NUMBER;

  CURSOR cur_density_above(cp_object_id VARCHAR2, cp_daytime DATE, cp_density NUMBER) IS
    SELECT MIN(sdc.density) AS dens_above
    FROM strm_dpt_conversion sdc
    WHERE sdc.object_id = cp_object_id AND
          sdc.density >= cp_density AND
          sdc.daytime <= cp_daytime; -- get values that are earlier than the caller's daytime
BEGIN
  FOR c_upper IN cur_density_above(p_object_id, p_daytime, p_density) LOOP
    ln_retval := c_upper.dens_above;
  END LOOP;

  RETURN ln_retval;

END getDensityAbove;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDensityBelow (Local function)
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :  - STRM_DPT_CONVERSION
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getDensityBelow(p_object_id STREAM.OBJECT_ID%TYPE, p_daytime DATE, p_density NUMBER)
RETURN NUMBER
--</EC-DOC>
IS
  ln_retval           NUMBER;

  CURSOR cur_density_below(cp_object_id VARCHAR2, cp_daytime DATE, cp_density NUMBER) IS
    SELECT MAX(sdc.density) AS dens_below
    FROM strm_dpt_conversion sdc
    WHERE sdc.object_id = cp_object_id AND
          sdc.density <= cp_density AND
          sdc.daytime <= cp_daytime; -- get values that are earlier than the caller's daytime
BEGIN
  FOR c_lower IN cur_density_below(p_object_id, p_daytime, p_density) LOOP
    ln_retval := c_lower.dens_below;
  END LOOP;

  RETURN ln_retval;
END getDensityBelow;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getPressAbove (Local function)
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :  - STRM_DPT_CONVERSION
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getPressAbove(p_object_id STREAM.OBJECT_ID%TYPE, p_daytime DATE, p_density NUMBER, p_pressure NUMBER)
RETURN NUMBER
--</EC-DOC>
IS
  ln_retval           NUMBER;

  CURSOR cur_press_above(cp_object_id VARCHAR2, cp_daytime DATE, cp_density NUMBER, cp_pressure NUMBER) IS
    SELECT MIN(sdc.press) AS press_above
    FROM strm_dpt_conversion sdc
    WHERE sdc.object_id = cp_object_id AND
          sdc.density = cp_density AND
          sdc.press >= cp_pressure AND
          sdc.daytime <= cp_daytime; -- get values that are earlier than the caller's daytime
BEGIN
  FOR c_upper IN cur_press_above(p_object_id, p_daytime, p_density, p_pressure) LOOP
    ln_retval := c_upper.press_above;
  END LOOP;

  RETURN ln_retval;

END getPressAbove;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getPressBelow (Local function)
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :  - STRM_DPT_CONVERSION
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getPressBelow(p_object_id STREAM.OBJECT_ID%TYPE, p_daytime DATE, p_density NUMBER, p_pressure NUMBER)
RETURN NUMBER
--</EC-DOC>
IS
  ln_retval           NUMBER;

  CURSOR cur_press_below(cp_object_id VARCHAR2, cp_daytime DATE, cp_density NUMBER, cp_pressure NUMBER) IS
    SELECT MAX(sdc.press) AS press_below
    FROM strm_dpt_conversion sdc
    WHERE sdc.object_id = cp_object_id AND
          sdc.density = cp_density AND
          sdc.press <= cp_pressure AND
          sdc.daytime <= cp_daytime; -- get values that are earlier than the caller's daytime
BEGIN
  FOR c_lower IN cur_press_below(p_object_id, p_daytime, p_density, p_pressure) LOOP
    ln_retval := c_lower.press_below;
  END LOOP;

  RETURN ln_retval;
END getPressBelow;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTempAbove (Local function)
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :  - STRM_DPT_CONVERSION
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getTempAbove(p_object_id STREAM.OBJECT_ID%TYPE, p_daytime DATE, p_density NUMBER, p_pressure NUMBER, p_temperature NUMBER)
RETURN NUMBER
--</EC-DOC>
IS
  ln_retval           NUMBER;

  CURSOR cur_temp_above(cp_object_id VARCHAR2, cp_daytime DATE, cp_density NUMBER, cp_pressure NUMBER, cp_temperature NUMBER) IS
    SELECT MIN(sdc.temp) AS temp_above
    FROM strm_dpt_conversion sdc
    WHERE sdc.object_id = cp_object_id AND
          sdc.density = cp_density AND
          sdc.press = cp_pressure AND
          sdc.temp >= cp_temperature AND
          sdc.daytime <= cp_daytime; -- get values that are earlier than the caller's daytime
BEGIN
  FOR c_upper IN cur_temp_above(p_object_id, p_daytime, p_density, p_pressure, p_temperature) LOOP
    ln_retval := c_upper.temp_above;
  END LOOP;

  RETURN ln_retval;
END getTempAbove;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTempBelow (Local function)
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :  - STRM_DPT_CONVERSION
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getTempBelow(p_object_id STREAM.OBJECT_ID%TYPE, p_daytime DATE, p_density NUMBER, p_pressure NUMBER, p_temperature NUMBER)
RETURN NUMBER
--</EC-DOC>
IS
  ln_retval           NUMBER;

  CURSOR cur_temp_below(cp_object_id VARCHAR2, cp_daytime DATE, cp_density NUMBER, cp_pressure NUMBER, cp_temperature NUMBER) IS
    SELECT MAX(sdc.temp) AS temp_below
    FROM strm_dpt_conversion sdc
    WHERE sdc.object_id = cp_object_id AND
          sdc.density = cp_density AND
          sdc.press = cp_pressure AND
          sdc.temp <= cp_temperature AND
          sdc.daytime <= cp_daytime; -- get values that are earlier than the caller's daytime
BEGIN
  FOR c_lower IN cur_temp_below(p_object_id, p_daytime, p_density, p_pressure, p_temperature) LOOP
    ln_retval := c_lower.temp_below;
  END LOOP;

  RETURN ln_retval;
END getTempBelow;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getInvertedFactor (Local function)
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :  - STRM_DPT_CONVERSION
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getInvertedFactor(p_object_id STREAM.OBJECT_ID%TYPE,
                            p_daytime DATE,
                            p_density NUMBER,
                            p_pressure NUMBER,
                            p_temperature NUMBER,
                            p_inv_factor_col_name VARCHAR2)        -- BO / BG / BW / RS / SP_GRAV / VCF
RETURN NUMBER
--</EC-DOC>

IS
  ln_retvalue       NUMBER;

BEGIN
  IF p_inv_factor_col_name = EcDp_Stream_DPT_Value.COL_BO THEN
    ln_retvalue := ec_strm_dpt_conversion.bo(p_object_id,p_density,p_pressure,p_temperature,p_daytime,'<=');

  ELSIF p_inv_factor_col_name = EcDp_Stream_DPT_Value.COL_BG THEN
    ln_retvalue := ec_strm_dpt_conversion.bg(p_object_id,p_density,p_pressure,p_temperature,p_daytime,'<=');

  ELSIF p_inv_factor_col_name = EcDp_Stream_DPT_Value.COL_BW THEN
    ln_retvalue := ec_strm_dpt_conversion.bw(p_object_id,p_density,p_pressure,p_temperature,p_daytime,'<=');

  ELSIF p_inv_factor_col_name = EcDp_Stream_DPT_Value.COL_RS THEN
    ln_retvalue := ec_strm_dpt_conversion.rs(p_object_id,p_density,p_pressure,p_temperature,p_daytime,'<=');

  ELSIF p_inv_factor_col_name = EcDp_Stream_DPT_Value.COL_SP_GRAV THEN
    ln_retvalue := ec_strm_dpt_conversion.sp_grav(p_object_id,p_density,p_pressure,p_temperature,p_daytime,'<=');

  ELSIF p_inv_factor_col_name = EcDp_Stream_DPT_Value.COL_VCF THEN
    ln_retvalue := ec_strm_dpt_conversion.vcf(p_object_id,p_density,p_pressure,p_temperature,p_daytime,'<=');

  ELSE
    ln_retvalue := NULL;
  END IF;

  RETURN ln_retvalue;
END getInvertedFactor;


FUNCTION findInvertedFactorFromDPT(p_object_id STREAM.OBJECT_ID%TYPE,
                                    p_daytime DATE,
                                    p_density NUMBER,
                                    p_pressure NUMBER,
                                    p_temperature NUMBER,
                                    p_inv_factor_col_name VARCHAR2)        -- BO / BG / BW / RS / SP_GRAV / VCF
RETURN NUMBER
IS
  ln_upper_dens            NUMBER;
  ln_lower_dens            NUMBER;
  ln_upper_press           NUMBER;
  ln_lower_press           NUMBER;
  ln_upper_temp            NUMBER;
  ln_lower_temp            NUMBER;
  ln_upper_factor          NUMBER;
  ln_lower_factor          NUMBER;

  ln_interp_0              NUMBER;
  ln_interp_1              NUMBER;
  ln_interp_2              NUMBER;
  ln_interp_3              NUMBER;
  ln_interp_01             NUMBER;
  ln_interp_23             NUMBER;
  ln_interp_final          NUMBER;

BEGIN
  -- (1) get lower DENS
  ln_lower_dens := getDensityBelow(p_object_id,p_daytime,p_density);

  -- (1.a) when DENS = ln_lower_dens; find lower PRESS
  ln_lower_press := getPressBelow(p_object_id,p_daytime,ln_lower_dens,p_pressure);

  -- (1.a.i  ) when DENS = ln_lower_dens, PRESS = ln_lower_press; find lower TEMP -> find lower FACTOR
  ln_lower_temp := getTempBelow(p_object_id,p_daytime,ln_lower_dens,ln_lower_press,p_temperature);
  ln_lower_factor := getInvertedFactor(p_object_id,p_daytime,ln_lower_dens,ln_lower_press,ln_lower_temp,p_inv_factor_col_name);

  -- (1.a.ii ) when DENS = ln_lower_dens, PRESS = ln_lower_press; find upper TEMP -> find upper FACTOR
  ln_upper_temp := getTempAbove(p_object_id,p_daytime,ln_lower_dens,ln_lower_press,p_temperature);
  ln_upper_factor := getInvertedFactor(p_object_id,p_daytime,ln_lower_dens,ln_lower_press,ln_upper_temp,p_inv_factor_col_name);

  -- (1.a.iii) interpolate; find I0
  ln_interp_0 := Ecbp_Mathlib.interpolateLinear(p_temperature,ln_lower_temp,ln_upper_temp,ln_lower_factor,ln_upper_factor);

  -- (1.b) when DENS = ln_lower_dens; find upper PRESS
  ln_upper_press := getPressAbove(p_object_id,p_daytime,ln_lower_dens,p_pressure);
  -- (1.b.i  ) when DENS = ln_lower_dens, PRESS = ln_upper_press; find lower TEMP -> find lower FACTOR
  ln_lower_temp := getTempBelow(p_object_id,p_daytime,ln_lower_dens,ln_upper_press,p_temperature);
  ln_lower_factor := getInvertedFactor(p_object_id,p_daytime,ln_lower_dens,ln_upper_press,ln_lower_temp,p_inv_factor_col_name);

  -- (1.b.ii ) when DENS = ln_lower_dens, PRESS = ln_upper_press; find upper TEMP -> find upper FACTOR
  ln_upper_temp := getTempAbove(p_object_id,p_daytime,ln_lower_dens,ln_upper_press,p_temperature);
  ln_upper_factor := getInvertedFactor(p_object_id,p_daytime,ln_lower_dens,ln_upper_press,ln_upper_temp,p_inv_factor_col_name);

  -- (1.b.iii) interpolate; find I1
  ln_interp_1 := Ecbp_Mathlib.interpolateLinear(p_temperature,ln_lower_temp,ln_upper_temp,ln_lower_factor,ln_upper_factor);

  -- (1.c) interpolate; find I01
  ln_interp_01 := Ecbp_Mathlib.interpolateLinear(p_pressure,ln_lower_press,ln_upper_press,ln_interp_0,ln_interp_1);

  -- (2) get upper DENS
  ln_upper_dens := getDensityAbove(p_object_id,p_daytime,p_density);

  -- (2.a) when DENS = ln_upper_dens; find lower PRESS
  ln_lower_press := getPressBelow(p_object_id,p_daytime,ln_upper_dens,p_pressure);

  -- (2.a.i  ) when DENS = ln_upper_dens, PRESS = ln_lower_press; find lower TEMP -> find lower FACTOR
  ln_lower_temp := getTempBelow(p_object_id,p_daytime,ln_upper_dens,ln_lower_press,p_temperature);
  ln_lower_factor := getInvertedFactor(p_object_id,p_daytime,ln_upper_dens,ln_lower_press,ln_lower_temp,p_inv_factor_col_name);

  -- (2.a.ii ) when DENS = ln_upper_dens, PRESS = ln_lower_press; find upper TEMP -> find upper FACTOR
  ln_upper_temp := getTempAbove(p_object_id,p_daytime,ln_upper_dens,ln_lower_press,p_temperature);
  ln_upper_factor := getInvertedFactor(p_object_id,p_daytime,ln_upper_dens,ln_lower_press,ln_upper_temp,p_inv_factor_col_name);

  -- (2.a.iii) interpolate; find I2
  ln_interp_2 := Ecbp_Mathlib.interpolateLinear(p_temperature,ln_lower_temp,ln_upper_temp,ln_lower_factor,ln_upper_factor);

  -- (2.b) when DENS = ln_upper_dens; find upper PRESS
  ln_upper_press := getPressAbove(p_object_id,p_daytime,ln_upper_dens,p_pressure);

  -- (2.b.i  ) when DENS = ln_upper_dens, PRESS = ln_upper_press; find lower TEMP -> find lower FACTOR
  ln_lower_temp := getTempBelow(p_object_id,p_daytime,ln_upper_dens,ln_upper_press,p_temperature);
  ln_lower_factor := getInvertedFactor(p_object_id,p_daytime,ln_upper_dens,ln_upper_press,ln_lower_temp,p_inv_factor_col_name);

  -- (2.b.ii ) when DENS = ln_upper_dens, PRESS = ln_upper_press; find upper TEMP -> find upper FACTOR
  ln_upper_temp := getTempAbove(p_object_id,p_daytime,ln_upper_dens,ln_upper_press,p_temperature);
  ln_upper_factor := getInvertedFactor(p_object_id,p_daytime,ln_upper_dens,ln_upper_press,ln_upper_temp,p_inv_factor_col_name);

  -- (2.b.iii) interpolate; find I3
  ln_interp_3 := Ecbp_Mathlib.interpolateLinear(p_temperature,ln_lower_temp,ln_upper_temp,ln_lower_factor,ln_upper_factor);

  -- (2.c) interpolate; find I23
  ln_interp_23 := Ecbp_Mathlib.interpolateLinear(p_pressure,ln_lower_press,ln_upper_press,ln_interp_2,ln_interp_3);

  -- (3) interpolate; find Ifinal
  ln_interp_final := Ecbp_Mathlib.interpolateLinear(p_density,ln_lower_dens,ln_upper_dens,ln_interp_01,ln_interp_23);

  RETURN ln_interp_final;
END findInvertedFactorFromDPT;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : copyToNewDaytime                                                             --
-- Description    : To check lock on the given period                                            --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
PROCEDURE copyToNewDaytime (
   p_object_id    stream.object_id%TYPE,
   p_daytime      DATE,
   p_density      NUMBER,
   p_press        NUMBER,
   p_temp        	NUMBER)

--</EC-DOC>
IS

BEGIN

   IF EcDp_Month_lock.withinLockedMonth(p_daytime) IS NOT NULL THEN

      EcDp_Month_lock.raiseValidationError('PROCEDURE', p_daytime, p_daytime, trunc(p_daytime,'MONTH'), 'EcDp_Stream_DPT_Value.copyToNewDaytime: Can not do this in a locked month');

   END IF;

   EcDp_Month_Lock.localLockCheck('withinLockedMonth', p_object_id,
                                  p_daytime, p_daytime,
                                  'PROCEDURE', 'EcDp_Stream_DPT_Value.copyToNewDaytime: Can not do this in a local locked month');

END copyToNewDaytime;

END EcDp_Stream_DPT_Value;