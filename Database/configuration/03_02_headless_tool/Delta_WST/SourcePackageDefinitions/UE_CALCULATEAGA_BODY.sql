CREATE OR REPLACE PACKAGE BODY Ue_CalculateAGA AS
/****************************************************************
** Package        :  Ue_CalculateAGA, body part.
**
** $Revision:
**
** Purpose        :  Customer specific implementation for AGA3
**
** Documentation  :  www.energy-components.com
**
** Created  : 14.03.2016  shindani
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 16.12.2016  shindani  Initial version

*****************************************************************/
---------------------------------------------------------------------------------------------------
-- Function       : calculateTdevFlowDensity
-- Description    :returns gas density at flowing condition.
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
FUNCTION calculateTdevFlowDensity(
   p_object_id       VARCHAR2,    --
   p_daytime         DATE,
   p_static_pressure NUMBER, --flowing pressure in KPAA
   p_temp            NUMBER, --flowing temperature in Celsius
   p_compress        NUMBER, --Can be null if there is no input value or calculation method was selected
   p_grs             NUMBER,
   p_class_name      VARCHAR2
   )
RETURN NUMBER

IS
  ln_density                NUMBER; -- calculated in kg/sm3
  ln_tf                     Number; -- Flowing temperature in Rankin
  ln_aga3Rhotp              NUMBER;
  ln_conver_factor          NUMBER := 459.67; --unit conversion factor(absolute temperature)
  ln_molar_mass             NUMBER := 28.9;
  ln_universal_gas_constant NUMBER := 10.73;
  ln_static_pressure_read   NUMBER;

BEGIN

   RETURN NULL;

END calculateTdevFlowDensity;
---------------------------------------------------------------------------------------------------
-- Function       : calculateTdevStdDensity
-- Description    :returns gas density at standard condition.
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
FUNCTION calculateTdevStdDensity(
   p_object_id  VARCHAR2,
   p_daytime    DATE,
   p_pressure   NUMBER, --standard pressure in KPAA
   p_temp       NUMBER, --standard temperature in Celsius
   p_compress   NUMBER, --Can be null if there is no input value or calculation method was selected
   p_grs        NUMBER
   )
RETURN NUMBER

IS
  ln_density                NUMBER; -- calculated in kg/sm3
  ln_ts                     NUMBER;
  ln_aga3Rhos               NUMBER;
  ln_std_press              NUMBER := 14.73;
  ln_molar_mass             NUMBER := 28.9;
  ln_universal_gas_constant NUMBER := 10.73;


BEGIN

RETURN NULL;

END calculateTdevStdDensity;
-------------------------------------------------------------------------------------------------------

END Ue_CalculateAGA;