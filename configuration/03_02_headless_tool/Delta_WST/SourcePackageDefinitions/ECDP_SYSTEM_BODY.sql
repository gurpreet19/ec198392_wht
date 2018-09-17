CREATE OR REPLACE PACKAGE BODY EcDp_System IS
/****************************************************************
** Package        :  EcDp_System, header part
**
** $Revision: 1.10 $
**
** Purpose        :  Finds production system properties.
**
** Documentation  :  www.energy-components.com
**
** Created  : 17.01.2000  Carl-Fredrik S?sen
**
** Modification history:
**
** Date     Whom  Change description:
** -------- ----- --------------------------------------
** 17.01.00  CFS   Initial version
** 11.04.00  DN    New function getSystemName.
** 04.04.01  KEJ   Documented functions and procedures.
** 14.05.01  DN    getAttributeText RETURN directly without local variable setting.
** 17.09.01  DN    getProductionDay: gas production day set correctly.
** 13.05.02  FBa   Added function getDefaultCompanyNo
** 05.09.02  DN    Removed obsolete procedure updateWellDowntime.
** 01.12.03  DN    Added assignNextNumber.
** 17.04.04  DN    Moved assignNextNumber to EcDp_System_key.
** 27.05.04  HNE   Added two new functions - getAirDensity and getWaterDensity
** 28.05.04  FBa   Removed function getProductionDay and getStartTimeOfProductionDay. Moved to EcDp_Facility.
** 28.05.04  DN    Added getDependentCode.
** 10.08.04  Toha  Removed sysnam from code.
** 10.10.06  DN    Added getCurrentGasYear from EC Revenue migration. Formatted code.
** 03.08.09  embonhaf ECPD-11153 Added getPressureBase, getTemperatureBase, getSiteAtmPressure
** 04.08.16  singishi ECPD-37768 Modified getWaterDensity() method.
** 18.07.17  kashisag ECPD-45817: Replaced sysdate with Ecdp_Timestamp.getCurrentSysdate
*****************************************************************/


CURSOR c_preference (p_pref_id IN VARCHAR2) IS
SELECT pref_verdi
FROM t_preferanse
WHERE pref_id = p_pref_id;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAttributeText
-- Description    : Returns attribute text for given production system,
--                  day, type
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions: ec_ctrl_system_attribute.attribute_text
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getAttributeText(
        p_daytime        DATE,
        p_attribute_type VARCHAR2)

RETURN VARCHAR2
--</EC-DOC>
IS


BEGIN

   RETURN  ec_ctrl_system_attribute.attribute_text(p_daytime, p_attribute_type,  '<=');

END getAttributeText;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAttributeValue
-- Description    : Returns attribute value for given production system,
--                  day, type
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions: EC_CTRL_SYSTEM_ATTRIBUTE.ATTRIBUTE_VALUE
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getAttributeValue(
        p_daytime        DATE,
        p_attribute_type VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS

ln_retval NUMBER;

BEGIN

   ln_retval := ec_ctrl_system_attribute.attribute_value(p_daytime, p_attribute_type, '<=');

   RETURN ln_retval;

END getAttributeValue;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSystemStartDate
-- Description    : Returns current system name from system preferences.
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : system_days
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSystemStartDate
RETURN DATE
--</EC-DOC>
IS

CURSOR c_system_days IS
SELECT MIN(daytime) min_daytime
FROM system_days;

ld_fromday DATE;

BEGIN

   FOR mycur IN c_system_days LOOP

      ld_fromday := mycur.min_daytime;

   END LOOP;

   RETURN ld_fromday;

END getSystemStartDate;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDefaultCompanyNo
-- Description    : Returns current dafault company_no from system preferences.
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : t_preferanse
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getDefaultCompanyNo
RETURN VARCHAR2
--</EC-DOC>
IS

lv2_return_id t_preferanse.pref_id%TYPE;

BEGIN

   FOR lr_current IN c_preference('DEFAULT_COMPANY') LOOP

        lv2_return_id := lr_current.pref_verdi;

   END LOOP;

   RETURN lv2_return_id;

END getDefaultCompanyNo;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDependentCode
-- Description    : Returns a dependent code given by a cross reference mapping between code types.
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : CTRL_CODE_DEPENDENCY
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : code_type_1 is considered the parent code type.
--
---------------------------------------------------------------------------------------------------
FUNCTION getDependentCode(p_code_type_1 VARCHAR2, p_code_type_2 VARCHAR2, p_code_2 VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_code_dep(cp_code_type_1 VARCHAR2, cp_code_type_2 VARCHAR2, cp_code_2 VARCHAR2) IS
SELECT code1
FROM ctrl_code_dependency
WHERE code_type1 = cp_code_type_1
AND code_type2 = cp_code_type_2
AND code2 = cp_code_2
;

lv2_parent_code VARCHAR2(32);

BEGIN

   FOR cur_rec IN c_code_dep(p_code_type_1, p_code_type_2, p_code_2) LOOP

      lv2_parent_code := cur_rec.code1;

   END LOOP;

   RETURN lv2_parent_code;

END getDependentCode;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAirDensity
-- Description    : Returns air density from an equation. If parameters are null
--                  input values are taken from ctrl_system_attributes
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : ctrl_system_attribute
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getAirDensity(
   p_air_temperature NUMBER DEFAULT NULL,
        p_air_pressure_abs NUMBER DEFAULT NULL,
   p_relative_humidity_pct NUMBER DEFAULT NULL,
   p_daytime DATE DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
ln_temp NUMBER;
ln_press NUMBER;
ln_humidity NUMBER;
ln_density NUMBER;
lv_gas_dens VARCHAR2(16);
ld_date DATE;

CURSOR cur_ctrl_uom_setup(p_parameter VARCHAR2, p_unit VARCHAR2,ld_date DATE) IS
SELECT decode(MAX(unit)
         ,p_unit,p_parameter
         ,EcDp_Unit.convertValue(--EcDp_System.getSystemName,
                                p_parameter,
                                MAX(unit),
                                p_unit,
                                ld_date)) corr_parameter
FROM ctrl_uom_setup
WHERE measurement_type=decode(p_unit,'C','TEMP','MBAR','PRESS_ABS')
AND db_unit_ind = 'Y';

CURSOR cur_ctrl_uom_gas_dens IS
SELECT MAX(unit) gas_db_dens
FROM ctrl_uom_setup
WHERE measurement_type='STD_GAS_DENS'
AND db_unit_ind = 'Y';

BEGIN
   -- set correct date
   IF p_daytime IS NULL THEN
      ld_date := trunc(Ecdp_Timestamp.getCurrentSysdate,'DD');
   ELSE
      ld_Date := p_daytime;
   END IF;

   -- get temperature and correct unit of temperature if needed
   IF p_air_temperature IS NULL THEN
      ln_temp := EcDp_System.getAttributeValue(--EcDp_System.getSystemName,
                                        ld_date,
                                        'REF_AIR_TEMP');
   ELSE
      FOR mycur IN cur_ctrl_uom_setup(p_air_temperature, 'C', ld_date) LOOP
         ln_temp := mycur.corr_parameter;
      END LOOP;
   END IF;

   -- get pressure and correct unit of pressure if needed
   IF p_air_pressure_abs IS NULL THEN
      ln_press := EcDp_System.getAttributeValue(--EcDp_System.getSystemName,
                                        ld_date,
                                        'REF_AIR_PRESS');
   ELSE
      FOR mycur IN cur_ctrl_uom_setup(p_air_pressure_abs, 'MBAR', ld_date) LOOP
         ln_press := mycur.corr_parameter;
      END LOOP;
   END IF;

   -- get relative humidity pct
   IF p_relative_humidity_pct IS NULL THEN
      ln_humidity := EcDp_System.getAttributeValue(--EcDp_System.getSystemName,
                                                ld_date,
                                                'REF_REL_HUMIDITY');
   ELSE
      ln_humidity := p_relative_humidity_pct;
   END IF;

   -- Taken from http://www.npl.co.uk/mass/guidance/buoycornote.pdf
   -- density = (A*p+rh*(B*t-C))/(273.15+t)
   -- Discrepancy: 4 parts pr. 10000 over the range 1.2kg/m? +-10%
   IF ln_temp<>273.15 THEN

      ln_density := ((0.348444*ln_press) +
                    (ln_humidity*((0.00252*ln_temp)-0.020582)))
                    / (273.15+ln_temp);
   ELSE
      ln_density := NULL;
   END IF;

   -- find gas density used in the database.
   FOR mycur IN cur_ctrl_uom_gas_dens LOOP
      lv_gas_dens := mycur.gas_db_dens;
   END LOOP;

   RETURN EcDp_Unit.convertValue(--EcDp_System.getSystemName,
                                ln_density,
                                'KGPERSM3',
                                lv_gas_dens,
                                ld_date);

   RETURN ln_density;
END getAirDensity;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWaterDensity
-- Description    : Returns water density from an equation. If parameters are null
--                  input values are taken from ctrl_system_attributes
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : t_preferanse
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getWaterDensity (
   p_water_temperature NUMBER DEFAULT NULL,
   p_daytime DATE DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
ln_temp NUMBER;
ln_density NUMBER;
lv_water_dens VARCHAR2(16);
ld_date DATE;

CURSOR cur_ctrl_uom_setup(ld_date DATE) IS
SELECT decode(MAX(unit)
         ,'C',p_water_temperature
         ,EcDp_Unit.convertValue(--EcDp_System.getSystemName,
                                p_water_temperature,
                                MAX(unit),
                                'C',
                                ld_date)) temp
FROM ctrl_uom_setup
WHERE measurement_type='TEMP'
AND db_unit_ind = 'Y';

CURSOR cur_ctrl_uom_water_dens IS
SELECT MAX(unit) water_db_dens
FROM ctrl_uom_setup
WHERE measurement_type='WATER_DENS'
AND db_unit_ind = 'Y';

BEGIN
   -- set correct date
   IF p_daytime IS NULL THEN
      ld_date := trunc(Ecdp_Timestamp.getCurrentSysdate,'DD');
   ELSE
      ld_Date := p_daytime;
   END IF;

   -- get temperature and correct unit of temperature if needed
   IF p_water_temperature IS NULL THEN
      ln_temp := EcDp_System.getAttributeValue(--EcDp_System.getSystemName,
                                                ld_date,
                                                'REF_WATER_TEMP');
   ELSE
      FOR mycur IN cur_ctrl_uom_setup(ld_date) LOOP
         ln_temp := mycur.temp;
      END LOOP;
   END IF;

   -- this equation is verified against www.gaussian.com/gchem/waterd.htm.
   -- Discrepancy is less than 0.03% within 0-50 deg C
   ln_density := 999.840281167 +
                 (0.0673268037314 * ln_temp) +
                 (-0.00894484552601 * power(ln_temp,2)) +
                 (0.00008784628665 * power(ln_temp,3)) +
                 (-0.000000662139792627 * power(ln_temp,4));

   -- find water density used in the database.
   FOR mycur IN cur_ctrl_uom_water_dens LOOP
      lv_water_dens := mycur.water_db_dens;
   END LOOP;

   RETURN EcDp_Unit.convertValue(--EcDp_System.getSystemName,
                                ln_density,
                                'KGPERM3',
                                lv_water_dens,
                                ld_date);

END getWaterDensity;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCurrentGasYear
-- Description    : Returns the start date of a gas year.
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getCurrentGasYear(p_daytime DATE)
RETURN DATE
--</EC-DOC>
IS

ld_return_val DATE;

BEGIN

  IF p_daytime BETWEEN to_date(to_char(p_daytime,'YYYY') || '1001','YYYYMMDD') AND to_date(to_char(p_daytime,'YYYY') || '1231','YYYYMMDD')+1 THEN

    ld_return_val := add_months(trunc(ADD_MONTHS(p_daytime,12),'YYYY'),-3);

  ELSE

    ld_return_val := add_months(trunc(p_daytime,'YYYY'),-3);

  END IF;

  RETURN ld_return_val;

END getCurrentGasYear;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getPressureBase
-- Description    : Returns the pressure base value.
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : GEOGR_AREA_VERSION
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getPressureBase(p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;

BEGIN

   -- Get STATE pressure_base. If null, get default value from system attribute REF_PRESS_BASE
   ln_return_val := nvl(ec_geogr_area_version.pressure_base(p_object_id, p_daytime, '<='), Ecdp_System.getAttributeValue(p_daytime, 'REF_PRESS_BASE'));

   RETURN ln_return_val;

END getPressureBase;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTemperatureBase
-- Description    : Returns the temperature base value.
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : GEOGR_AREA_VERSION
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTemperatureBase(p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;

BEGIN

   -- Get STATE temperature_base. If null, get default value from system attribute REF_TEMP_BASE
   ln_return_val := nvl(ec_geogr_area_version.temperature_base(p_object_id, p_daytime, '<='), Ecdp_System.getAttributeValue(p_daytime, 'REF_TEMP_BASE'));

   RETURN ln_return_val;

END getTemperatureBase;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSiteAtmPressure
-- Description    : Returns the Site Atm Pressure value.
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : FCTY_VERSION
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSiteAtmPressure(p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;

BEGIN

   -- Get Facility site_atm_pressure. If null, get default value from system attribute REF_SITE_ATM_PRESS
   ln_return_val := nvl(ec_fcty_version.site_atm_pressure(p_object_id, p_daytime, '<='), Ecdp_System.getAttributeValue(p_daytime, 'REF_SITE_ATM_PRESS'));

   RETURN ln_return_val;

END getSiteAtmPressure;

END EcDp_System;