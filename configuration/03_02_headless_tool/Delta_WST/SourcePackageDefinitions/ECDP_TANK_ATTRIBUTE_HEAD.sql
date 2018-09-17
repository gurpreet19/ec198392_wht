CREATE OR REPLACE PACKAGE EcDp_Tank_Attribute IS

/****************************************************************
** Package        :  EcDp_Tank_Attribute, header part
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
RETURN VARCHAR2;

--

FUNCTION DEADSTOCK_VOL
RETURN VARCHAR2;

--

FUNCTION DEADSTOCK_MASS
RETURN VARCHAR2;

--

FUNCTION MIN_DIP_LEVEL
RETURN VARCHAR2;

--

FUNCTION BF_USAGE
RETURN VARCHAR2;

--

FUNCTION STRAP_LEVEL_UOM
RETURN VARCHAR2;

--

FUNCTION STRAP_VALUE_TYPE
RETURN VARCHAR2;

--

FUNCTION VAL_PER_DIP_FACT
RETURN VARCHAR2;

--

FUNCTION VCF_METHOD
RETURN VARCHAR2;

--

FUNCTION ROOF_DISP_METHOD
RETURN VARCHAR2;

--

FUNCTION STRAPPING_METHOD
RETURN VARCHAR2 ;

--

FUNCTION GRS_VOL_METHOD
RETURN VARCHAR2;

--

FUNCTION NET_VOL_METHOD
RETURN VARCHAR2;

--

FUNCTION BSW_VOL_METHOD
RETURN VARCHAR2;

--

FUNCTION BSW_WT_METHOD
RETURN VARCHAR2;

--

FUNCTION FREE_WAT_VOL_MET
RETURN VARCHAR2;

--

FUNCTION WATER_VOL_METHOD
RETURN VARCHAR2;

--

FUNCTION STD_DENS_METHOD
RETURN VARCHAR2;

--

FUNCTION OBS_DENS_METHOD
RETURN VARCHAR2;

--

FUNCTION GRS_MASS_METHOD
RETURN VARCHAR2;

--

FUNCTION NET_MASS_METHOD
RETURN VARCHAR2;


END EcDp_Tank_Attribute;