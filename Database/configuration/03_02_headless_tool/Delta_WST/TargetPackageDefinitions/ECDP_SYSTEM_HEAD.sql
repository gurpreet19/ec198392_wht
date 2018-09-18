CREATE OR REPLACE PACKAGE EcDp_System IS

/****************************************************************
** Package        :  EcDp_System, header part
**
** $Revision: 1.11 $
**
** Purpose        :  Finds production system properties.
**
** Documentation  :  www.energy-components.com
**
** Created  : 17.01.2000  Carl-Fredrik Sørensen
**
** Modification history:
**
** Date      Whom  Change description:
** ------    ----- --------------------------------------
** 17.01.00  CFS   Initial version
** 11.04.00  DN    New function getSystemName.
** 13.05.02  FBa   Added function getDefaultCompanyNo
** 05.09.02  DN    Removed obsolete procedure updateWellDowntime.
** 01.12.03  DN    Added assignNextNumber.
** 17.04.04  DN    Moved assignNextNumber to EcDp_System_key.
** 27.05.04  HNE   Added two new functions - getAirDensity and getWaterDensity
** 28.05.04  FBa   Removed function getProductionDay and getStartTimeOfProductionDay. Moved to EcDp_Facility.
** 28.05.04  DN    Added getDependentCode.
** 10.08.04  Toha  Removed function getSystemName since its no longer valid.
**                 Removed sysnam from function's signatures.
** 10.10.06  DN    Added getCurrentGasYear from EC Revenue migration. Formatted code.
** 03.08.09  embonhaf ECPD-11153 Added getPressureBase, getTemperatureBase, getSiteAtmPressure
*****************************************************************/

FUNCTION getCurrentGasYear(p_daytime DATE)
RETURN DATE;

PRAGMA RESTRICT_REFERENCES(getCurrentGasYear, WNDS, WNPS, RNPS);


FUNCTION getDefaultCompanyNo
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(getDefaultCompanyNo, WNDS, WNPS, RNPS);

--

FUNCTION getAttributeText (
	p_daytime        DATE,
	p_attribute_type VARCHAR2)

RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(getAttributeText, WNDS, WNPS, RNPS);

--

FUNCTION getAttributeValue (
   p_daytime        DATE,
   p_attribute_type VARCHAR2)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getAttributeValue, WNDS, WNPS, RNPS);

--

FUNCTION getSystemStartDate

RETURN DATE;

PRAGMA RESTRICT_REFERENCES(getSystemStartDate, WNDS, WNPS, RNPS);

--

FUNCTION getDependentCode(p_code_type_1 VARCHAR2, p_code_type_2 VARCHAR2, p_code_2 VARCHAR2)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(getDependentCode, WNDS, WNPS, RNPS);

--

FUNCTION getAirDensity(
   p_air_temperature NUMBER DEFAULT NULL,
	p_air_pressure_abs NUMBER DEFAULT NULL,
   p_relative_humidity_pct NUMBER DEFAULT NULL,
   p_daytime DATE DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getAirDensity, WNDS, WNPS, RNPS);

--

FUNCTION getWaterDensity (
   p_water_temperature NUMBER DEFAULT NULL,
   p_daytime DATE DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getWaterDensity, WNDS, WNPS, RNPS);

--

FUNCTION getPressureBase(p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getPressureBase, WNDS, WNPS, RNPS);

--

FUNCTION getTemperatureBase(p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getTemperatureBase, WNDS, WNPS, RNPS);

--

FUNCTION getSiteAtmPressure(p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getSiteAtmPressure, WNDS, WNPS, RNPS);


END EcDp_System;