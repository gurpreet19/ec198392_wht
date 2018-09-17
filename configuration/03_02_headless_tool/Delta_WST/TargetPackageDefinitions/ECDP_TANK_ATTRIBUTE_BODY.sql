CREATE OR REPLACE PACKAGE BODY EcDp_Tank_Attribute IS
/****************************************************************
** Package        :  EcDp_Tank_Attribute, body part
**
** $Revision: 1.5 $
**
** Purpose        :  This package returns constants used in tank attribute.
**
** Documentation  :  www.energy-components.com
**
** Created  : 29.04.2004  Frode Barstad
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ----------  ----- --------------------------------------
** 1.0      29.04.2004  FBa   Initial version
*****************************************************************/


FUNCTION DUAL_DIP
RETURN VARCHAR2 IS
BEGIN
   RETURN 'DUAL_DIP';
END DUAL_DIP;

--

FUNCTION DEADSTOCK_VOL
RETURN VARCHAR2 IS
BEGIN
   RETURN 'DEADSTOCK_VOL';
END DEADSTOCK_VOL;

--

FUNCTION DEADSTOCK_MASS
RETURN VARCHAR2 IS
BEGIN
   RETURN 'DEADSTOCK_MASS';
END DEADSTOCK_MASS;

--

FUNCTION MIN_DIP_LEVEL
RETURN VARCHAR2 IS
BEGIN
   RETURN 'MIN_DIP_LEVEL';
END MIN_DIP_LEVEL;

--

FUNCTION BF_USAGE
RETURN VARCHAR2 IS
BEGIN
   RETURN 'BF_USAGE';
END BF_USAGE;

--

FUNCTION STRAP_LEVEL_UOM
RETURN VARCHAR2 IS
BEGIN
   RETURN 'STRAP_LEVEL_UOM';
END STRAP_LEVEL_UOM;

--

FUNCTION STRAP_VALUE_TYPE
RETURN VARCHAR2 IS
BEGIN
   RETURN 'STRAP_VALUE_TYPE';
END STRAP_VALUE_TYPE;

--

FUNCTION VAL_PER_DIP_FACT
RETURN VARCHAR2 IS
BEGIN
   RETURN 'VAL_PER_DIP_FACT';
END VAL_PER_DIP_FACT;

--

FUNCTION VCF_METHOD
RETURN VARCHAR2 IS
BEGIN
   RETURN 'VCF_METHOD';
END VCF_METHOD;

--

FUNCTION ROOF_DISP_METHOD
RETURN VARCHAR2 IS
BEGIN
   RETURN 'ROOF_DISP_METHOD';
END ROOF_DISP_METHOD;

--

FUNCTION STRAPPING_METHOD
RETURN VARCHAR2 IS
BEGIN
   RETURN 'STRAPPING_METHOD';
END STRAPPING_METHOD;

--

FUNCTION GRS_VOL_METHOD
RETURN VARCHAR2 IS
BEGIN
   RETURN 'GRS_VOL_METHOD';
END GRS_VOL_METHOD;

--

FUNCTION NET_VOL_METHOD
RETURN VARCHAR2 IS
BEGIN
   RETURN 'NET_VOL_METHOD';
END NET_VOL_METHOD;

--

FUNCTION BSW_VOL_METHOD
RETURN VARCHAR2 IS
BEGIN
   RETURN 'BSW_VOL_METHOD';
END BSW_VOL_METHOD;

--

FUNCTION BSW_WT_METHOD
RETURN VARCHAR2 IS
BEGIN
   RETURN 'BSW_WT_METHOD';
END BSW_WT_METHOD;

--

FUNCTION FREE_WAT_VOL_MET
RETURN VARCHAR2 IS
BEGIN
   RETURN 'FREE_WAT_VOL_MET';
END FREE_WAT_VOL_MET;

--

FUNCTION WATER_VOL_METHOD
RETURN VARCHAR2 IS
BEGIN
   RETURN 'WATER_VOL_METHOD';
END WATER_VOL_METHOD;

--

FUNCTION STD_DENS_METHOD
RETURN VARCHAR2 IS
BEGIN
   RETURN 'STD_DENS_METHOD';
END STD_DENS_METHOD;

--

FUNCTION OBS_DENS_METHOD
RETURN VARCHAR2 IS
BEGIN
   RETURN 'OBS_DENS_METHOD';
END OBS_DENS_METHOD;

--

FUNCTION GRS_MASS_METHOD
RETURN VARCHAR2 IS
BEGIN
   RETURN 'GRS_MASS_METHOD';
END GRS_MASS_METHOD;

--

FUNCTION NET_MASS_METHOD
RETURN VARCHAR2 IS
BEGIN
   RETURN 'NET_MASS_METHOD';
END NET_MASS_METHOD;

--

END EcDp_Tank_Attribute;