CREATE OR REPLACE PACKAGE EcDp_Stream_Ref_Attribute IS

/****************************************************************
** Package        :  EcDp_Stream_Ref_Attribute, header part
**
** $Revision: 1.1.1.1 $
**
** Purpose        :  Definition of stream reference attributes
**
** Documentation  :  www.energy-components.com
**
** Created  : 27.12.1999  Carl-Fredrik S�rensen
**
** Modification history:
**
** Version  Date      Whom  Change description:
** -------  ------    ----- -----------------------------------
** 3.1      10.05.00  CFS   Added method VA_TRESHOLD_PCT
*****************************************************************/

--

FUNCTION BORG_PRT_TOR_PCT
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (BORG_PRT_TOR_PCT, WNDS, WNPS, RNPS);

--

FUNCTION FLARE_WATER_CONTENT
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (FLARE_WATER_CONTENT, WNDS, WNPS, RNPS);

--

FUNCTION FUEL_HP_SCAV
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (FUEL_HP_SCAV, WNDS, WNPS, RNPS);

--

FUNCTION FUEL_LP_SCAV
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (FUEL_LP_SCAV, WNDS, WNPS, RNPS);

--

FUNCTION GAS_OIL_RATIO
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (GAS_OIL_RATIO, WNDS, WNPS, RNPS);

--

FUNCTION HIGH_GOR_MAX
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (HIGH_GOR_MAX, WNDS, WNPS, RNPS);

--

FUNCTION HIGH_GOR_MIN
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (HIGH_GOR_MIN, WNDS, WNPS, RNPS);

--

FUNCTION N2_RATE
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (N2_RATE, WNDS, WNPS, RNPS);

--

FUNCTION NET_FLARE_FACTOR
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (NET_FLARE_FACTOR, WNDS, WNPS, RNPS);

--

FUNCTION NET_VOL
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (NET_VOL, WNDS, WNPS, RNPS);

--

FUNCTION NET_WATER_CONTENT
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (NET_WATER_CONTENT, WNDS, WNPS, RNPS);

--

FUNCTION PILOT_GAS_RATE
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (PILOT_GAS_RATE, WNDS, WNPS, RNPS);

--

FUNCTION SEP_DENSITY
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (SEP_DENSITY, WNDS, WNPS, RNPS);

--

FUNCTION SR_ADD_CONSTANT
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (SR_ADD_CONSTANT, WNDS, WNPS, RNPS);

--

FUNCTION SR_FACTOR_STATFJORD_NORTH
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (SR_FACTOR_STATFJORD_NORTH, WNDS, WNPS, RNPS);

--

FUNCTION SR_FACTOR_STATFJORD_OST
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (SR_FACTOR_STATFJORD_OST, WNDS, WNPS, RNPS);

--

FUNCTION SR_PRESS_CONSTANT
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (SR_PRESS_CONSTANT, WNDS, WNPS, RNPS);

--

FUNCTION SR_PRESS_FACTOR
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (SR_PRESS_FACTOR, WNDS, WNPS, RNPS);

--

FUNCTION SR_TEMP_CONSTANT
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (SR_TEMP_CONSTANT, WNDS, WNPS, RNPS);

--

FUNCTION STD_DENSITY
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (STD_DENSITY, WNDS, WNPS, RNPS);

--

FUNCTION VA_REMOVE_GAS
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (VA_REMOVE_GAS, WNDS, WNPS, RNPS);

--

FUNCTION VA_TRESHOLD_PCT
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (VA_TRESHOLD_PCT, WNDS, WNPS, RNPS);

--

FUNCTION VENTILE_WATER_CONTENT
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (VENTILE_WATER_CONTENT, WNDS, WNPS, RNPS);

--

FUNCTION WATER_DENSITY
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (WATER_DENSITY, WNDS, WNPS, RNPS);

--

END;