CREATE OR REPLACE PACKAGE BODY EcDp_Stream_PT_Value IS
/****************************************************************
** Package        :  EcDp_Stream_PT_Value; body part
**
** $Revision: 1.12 $
**
** Purpose        :  This package is responsible for data access to
**                   the strm_pt_conversion table
**
** Documentation  :  www.energy-components.com
**
** Created        :  11.06.01  Carl-Fredrik S?sen
**
** Modification history:
**
** Date      Whom     Change description:
** -------   -----    --------------------------------------
** 11.06.01  CFS      First version.
** 11.06.01  KEJ      Documented functions and procedures.
** 23.07.04  kaurrnar Removed p_sysnam and p_stream_code and update as necessary
** 18.04.05  MOT      Added copyToNewDaytime
** 21.04.05  DN       Removed old functions towards strm_pt_value.
** 21.11.08  oonnnng  ECPD-6067: Added local month lock checking in copyToNewDaytime function.
** 17.02.09  leongsei ECPD-6067: Modified function copyToNewDaytime for new parameter p_local_lock
** 14.05.09  oonnnng  ECPD-11791: Modified copyToNewDaytime() function.
** 03.08.09  embonhaf ECPD-11153 Added interpolation calculation support for VCF.
** 23.02.11  amirrasn ECPD-15842 Added support for more columns when accessing data from strm_pt_conversion.
** 16.10.15  kumarsur ECPD-32229: Modified getPressAbove, getPressBelow, getTempAbove and getTempBelow to use set from last max date.
** 03.08.17  singishi ECPD-42422: Added a procedure(checkPVTInputParameters) to handle error message if values are outside PT table values.
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
-- Function       : getPressAbove (Local function)
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :  - STRM_PT_CONVERSION
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getPressAbove(p_object_id STREAM.OBJECT_ID%TYPE, p_daytime DATE, p_pressure NUMBER)
RETURN NUMBER
--</EC-DOC>
IS
  ln_retval           NUMBER;

  CURSOR cur_press_above(cp_object_id VARCHAR2, cp_daytime DATE, cp_pressure NUMBER) IS
    SELECT MIN(sdc.press) AS press_above
    FROM strm_pt_conversion sdc
    WHERE sdc.object_id = cp_object_id AND
          sdc.press >= cp_pressure AND
          sdc.daytime =
             (SELECT MAX(daytime)
              FROM strm_pt_conversion sdcmax
              WHERE sdcmax.object_id = sdc.object_id
              AND sdcmax.daytime <= cp_daytime);
BEGIN
  FOR c_upper IN cur_press_above(p_object_id, p_daytime, p_pressure) LOOP
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
-- Using tables   :  - STRM_PT_CONVERSION
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getPressBelow(p_object_id STREAM.OBJECT_ID%TYPE, p_daytime DATE, p_pressure NUMBER)
RETURN NUMBER
--</EC-DOC>
IS
  ln_retval           NUMBER;

  CURSOR cur_press_below(cp_object_id VARCHAR2, cp_daytime DATE, cp_pressure NUMBER) IS
    SELECT MAX(sdc.press) AS press_below
    FROM strm_pt_conversion sdc
    WHERE sdc.object_id = cp_object_id AND
          sdc.press <= cp_pressure AND
          sdc.daytime =
             (SELECT MAX(daytime)
              FROM strm_pt_conversion sdcmax
              WHERE sdcmax.object_id = sdc.object_id
              AND sdcmax.daytime <= cp_daytime);
BEGIN
  FOR c_lower IN cur_press_below(p_object_id, p_daytime, p_pressure) LOOP
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
-- Using tables   :  - STRM_PT_CONVERSION
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getTempAbove(p_object_id STREAM.OBJECT_ID%TYPE, p_daytime DATE, p_pressure NUMBER, p_temperature NUMBER)
RETURN NUMBER
--</EC-DOC>
IS
  ln_retval           NUMBER;

  CURSOR cur_temp_above(cp_object_id VARCHAR2, cp_daytime DATE, cp_pressure NUMBER, cp_temperature NUMBER) IS
    SELECT MIN(sdc.temp) AS temp_above
    FROM strm_pt_conversion sdc
    WHERE sdc.object_id = cp_object_id AND
          sdc.press = cp_pressure AND
          sdc.temp >= cp_temperature AND
          sdc.daytime =
             (SELECT MAX(daytime)
              FROM strm_pt_conversion sdcmax
              WHERE sdcmax.object_id = sdc.object_id
              AND sdcmax.daytime <= cp_daytime);
BEGIN
  FOR c_upper IN cur_temp_above(p_object_id, p_daytime, p_pressure, p_temperature) LOOP
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
-- Using tables   :  - STRM_PT_CONVERSION
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getTempBelow(p_object_id STREAM.OBJECT_ID%TYPE, p_daytime DATE, p_pressure NUMBER, p_temperature NUMBER)
RETURN NUMBER
--</EC-DOC>
IS
  ln_retval           NUMBER;

  CURSOR cur_temp_below(cp_object_id VARCHAR2, cp_daytime DATE, cp_pressure NUMBER, cp_temperature NUMBER) IS
    SELECT MAX(sdc.temp) AS temp_below
    FROM strm_pt_conversion sdc
    WHERE sdc.object_id = cp_object_id AND
          sdc.press = cp_pressure AND
          sdc.temp <= cp_temperature AND
          sdc.daytime =
             (SELECT MAX(daytime)
              FROM strm_pt_conversion sdcmax
              WHERE sdcmax.object_id = sdc.object_id
              AND sdcmax.daytime <= cp_daytime);
BEGIN
  FOR c_lower IN cur_temp_below(p_object_id, p_daytime, p_pressure, p_temperature) LOOP
    ln_retval := c_lower.temp_below;
  END LOOP;

  RETURN ln_retval;
END getTempBelow;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getInvertedFactor
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :  - STRM_PT_CONVERSION
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getInvertedFactor(p_object_id STREAM.OBJECT_ID%TYPE,
                            p_daytime DATE,
                            p_pressure NUMBER,
                            p_temperature NUMBER,
                            p_inv_factor_col_name VARCHAR2)        -- VCF
RETURN NUMBER
--</EC-DOC>

IS
  ln_retvalue       NUMBER;

BEGIN
  -- ecpd-16217
  -- support more factors
  IF p_inv_factor_col_name = EcDp_Stream_PT_Value.COL_BO THEN
    ln_retvalue := ec_strm_pt_conversion.bo(p_object_id,p_daytime,p_pressure,p_temperature,'<=');

  ELSIF p_inv_factor_col_name = EcDp_Stream_PT_Value.COL_BG THEN
    ln_retvalue := ec_strm_pt_conversion.bg(p_object_id,p_daytime,p_pressure,p_temperature,'<=');

  ELSIF p_inv_factor_col_name = EcDp_Stream_PT_Value.COL_BW THEN
    ln_retvalue := ec_strm_pt_conversion.bw(p_object_id,p_daytime,p_pressure,p_temperature,'<=');

  ELSIF p_inv_factor_col_name = EcDp_Stream_PT_Value.COL_RS THEN
    ln_retvalue := ec_strm_pt_conversion.rs(p_object_id,p_daytime,p_pressure,p_temperature,'<=');

  ELSIF p_inv_factor_col_name = EcDp_Stream_PT_Value.COL_SP_GRAV THEN
    ln_retvalue := ec_strm_pt_conversion.sp_grav(p_object_id,p_daytime,p_pressure,p_temperature,'<=');

  ELSIF p_inv_factor_col_name = EcDp_Stream_PT_Value.COL_VCF THEN
    ln_retvalue := ec_strm_pt_conversion.vcf(p_object_id,p_daytime,p_pressure,p_temperature,'<=');

  ELSE
    ln_retvalue := NULL;
  END IF;

  RETURN ln_retvalue;
END getInvertedFactor;


FUNCTION findInvertedFactorFromPT(p_object_id STREAM.OBJECT_ID%TYPE,
                                    p_daytime DATE,
                                    p_pressure NUMBER,
                                    p_temperature NUMBER,
                                    p_inv_factor_col_name VARCHAR2)        -- VCF
RETURN NUMBER
IS
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

  -- Validate pressure and temperature in Stream PT conversion table.
  checkPVTInputParameters(p_object_id,p_daytime,p_pressure, p_temperature);

  -- (1.a) find lower PRESS
  ln_lower_press := getPressBelow(p_object_id,p_daytime,p_pressure);

  -- (1.a.i  ) when PRESS = ln_lower_press; find lower TEMP -> find lower FACTOR
  ln_lower_temp := getTempBelow(p_object_id,p_daytime,ln_lower_press,p_temperature);
  ln_lower_factor := getInvertedFactor(p_object_id,p_daytime,ln_lower_press,ln_lower_temp,p_inv_factor_col_name);

  -- (1.a.ii ) when PRESS = ln_lower_press; find upper TEMP -> find upper FACTOR
  ln_upper_temp := getTempAbove(p_object_id,p_daytime,ln_lower_press,p_temperature);
  ln_upper_factor := getInvertedFactor(p_object_id,p_daytime,ln_lower_press,ln_upper_temp,p_inv_factor_col_name);

  -- (1.a.iii) interpolate; find I0
  ln_interp_0 := Ecbp_Mathlib.interpolateLinear(p_temperature,ln_lower_temp,ln_upper_temp,ln_lower_factor,ln_upper_factor);

  -- (1.b) find upper PRESS
  ln_upper_press := getPressAbove(p_object_id,p_daytime,p_pressure);

  -- (1.b.i  ) when PRESS = ln_upper_press; find lower TEMP -> find lower FACTOR
  ln_lower_temp := getTempBelow(p_object_id,p_daytime,ln_upper_press,p_temperature);
  ln_lower_factor := getInvertedFactor(p_object_id,p_daytime,ln_upper_press,ln_lower_temp,p_inv_factor_col_name);

  -- (1.b.ii ) when PRESS = ln_upper_press; find upper TEMP -> find upper FACTOR
  ln_upper_temp := getTempAbove(p_object_id,p_daytime,ln_upper_press,p_temperature);
  ln_upper_factor := getInvertedFactor(p_object_id,p_daytime,ln_upper_press,ln_upper_temp,p_inv_factor_col_name);

  -- (1.b.iii) interpolate; find I1
  ln_interp_1 := Ecbp_Mathlib.interpolateLinear(p_temperature,ln_lower_temp,ln_upper_temp,ln_lower_factor,ln_upper_factor);

  -- (1.c) interpolate; find I01
  ln_interp_01 := Ecbp_Mathlib.interpolateLinear(p_pressure,ln_lower_press,ln_upper_press,ln_interp_0,ln_interp_1);

  -- (2.a) find lower PRESS
  ln_lower_press := getPressBelow(p_object_id,p_daytime,p_pressure);

  -- (2.a.i  ) when PRESS = ln_lower_press; find lower TEMP -> find lower FACTOR
  ln_lower_temp := getTempBelow(p_object_id,p_daytime,ln_lower_press,p_temperature);
  ln_lower_factor := getInvertedFactor(p_object_id,p_daytime,ln_lower_press,ln_lower_temp,p_inv_factor_col_name);

  -- (2.a.ii ) when PRESS = ln_lower_press; find upper TEMP -> find upper FACTOR
  ln_upper_temp := getTempAbove(p_object_id,p_daytime,ln_lower_press,p_temperature);
  ln_upper_factor := getInvertedFactor(p_object_id,p_daytime,ln_lower_press,ln_upper_temp,p_inv_factor_col_name);

  -- (2.a.iii) interpolate; find I2
  ln_interp_2 := Ecbp_Mathlib.interpolateLinear(p_temperature,ln_lower_temp,ln_upper_temp,ln_lower_factor,ln_upper_factor);

  -- (2.b) find upper PRESS
  ln_upper_press := getPressAbove(p_object_id,p_daytime,p_pressure);

  -- (2.b.i  ) when PRESS = ln_upper_press; find lower TEMP -> find lower FACTOR
  ln_lower_temp := getTempBelow(p_object_id,p_daytime,ln_upper_press,p_temperature);
  ln_lower_factor := getInvertedFactor(p_object_id,p_daytime,ln_upper_press,ln_lower_temp,p_inv_factor_col_name);

  -- (2.b.ii ) when PRESS = ln_upper_press; find upper TEMP -> find upper FACTOR
  ln_upper_temp := getTempAbove(p_object_id,p_daytime,ln_upper_press,p_temperature);
  ln_upper_factor := getInvertedFactor(p_object_id,p_daytime,ln_upper_press,ln_upper_temp,p_inv_factor_col_name);

  -- (2.b.iii) interpolate; find I3
  ln_interp_3 := Ecbp_Mathlib.interpolateLinear(p_temperature,ln_lower_temp,ln_upper_temp,ln_lower_factor,ln_upper_factor);

  -- (2.c) interpolate; find I23
  ln_interp_23 := Ecbp_Mathlib.interpolateLinear(p_pressure,ln_lower_press,ln_upper_press,ln_interp_2,ln_interp_3);

  -- (3) interpolate; find Ifinal
  ln_interp_final := Ecbp_Mathlib.interpolateLinear(p_pressure,ln_lower_press,ln_upper_press,ln_interp_01,ln_interp_23);

  RETURN ln_interp_final;
END findInvertedFactorFromPT;

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
   p_press        NUMBER,
   p_temp        	NUMBER)

--</EC-DOC>
IS

BEGIN

   IF EcDp_Month_lock.withinLockedMonth(p_daytime) IS NOT NULL THEN

      EcDp_Month_lock.raiseValidationError('PROCEDURE', p_daytime, p_daytime, trunc(p_daytime,'MONTH'), 'EcDp_Stream_PT_Value.copyToNewDaytime: Can not do this in a locked month');

   END IF;

   EcDp_Month_Lock.localLockCheck('withinLockedMonth', p_object_id,
                                  p_daytime, p_daytime,
                                  'PROCEDURE', 'EcDp_Stream_PT_Value.copyToNewDaytime: Can not do this in a local locked month');

END copyToNewDaytime;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : checkPVTInputParameters                                                      --
-- Description    : To validate temperature and pressure using Stream PT table                   --
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
PROCEDURE checkPVTInputParameters(
   p_object_id     STREAM.OBJECT_ID%TYPE,
   p_daytime       DATE,
   p_press         NUMBER,
   p_temp          NUMBER)

--</EC-DOC>
IS

   ln_maxPress     NUMBER;
   ln_minPress     NUMBER;
   ln_maxTemp      NUMBER;
   ln_minTemp      NUMBER;
   err_msg         VARCHAR2(2000);
   error           BOOLEAN;

BEGIN
   err_msg := '';
   error := false;

    SELECT MAX(sdc.press) AS maxPress, MIN(sdc.press) AS minPress, MAX(sdc.temp) AS maxTemp, MIN(sdc.temp) AS minTemp
    INTO ln_maxPress, ln_minPress, ln_maxTemp, ln_minTemp
    FROM strm_pt_conversion sdc
    WHERE sdc.object_id = p_object_id AND
          sdc.daytime =
             (SELECT MAX(daytime)
              FROM strm_pt_conversion sdcmax
              WHERE sdcmax.object_id = sdc.object_id
              AND sdcmax.daytime <= p_daytime);

    IF (p_press > ln_maxPress) THEN
      error := true;
      err_msg := err_msg || 'Pressure of ' || p_press || ' is above max pressure of ' || ln_maxPress ||' in PT table. ';
    END IF;

    IF (p_press < ln_minPress) THEN
      error := true;
      err_msg := err_msg || 'Pressure of ' || p_press || ' is below min pressure of ' || ln_minPress ||' in PT table. ';
    END IF;

    IF (p_temp > ln_maxTemp) THEN
      error := true;
      err_msg := err_msg || 'Temperature of ' || p_temp || ' is above max temperature of ' || ln_maxTemp ||' in PT table. ';
    END IF;

    IF (p_temp < ln_minTemp) THEN
      error := true;
      err_msg := err_msg || 'Temperature of ' || p_temp || ' is below min temperature of ' || ln_minTemp ||' in PT table. ';
    END IF;

    IF error THEN
      raise_application_error(-20000, err_msg);
    END IF;

END;

END EcDp_Stream_PT_Value;