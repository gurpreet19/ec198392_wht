CREATE OR REPLACE PACKAGE BODY EcDp_Stream_Attribute IS

/****************************************************************
** Package        :  EcDp_Stream_Attribute, body part
**
** $Revision: 1.3 $
**
** Purpose        :  Definition of stream attributes
**
** Documentation  :  www.energy-components.com
**
** Created  : 22.12.1999  Carl-Fredrik Sørensen
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ------      ----- -----------------------------------
** 3.0      30.05.2000  CFS   Changed return value on WAT_MASS_METHOD to return
**                            the string WAT_MASS_METHOD instead of WATER_MASS_METHOD
**                            beacuse of a limitation in the database field (16 characters)
** 3.1      14.11.2000  ØJ    Changed return value on SHIP_CVOL_METHOD to return the
**                            string SHIP_CVOL_METHOD instead of SHIP_COMP_VOL_METHOD beacuse of a
**                            limitation in the database field (16 characters)
** 3.2      14.11.2000  ØJ    Added this comment in header.
** 3.3      17.08.2001  HNE   New function Salt_method
**          03.12.2004  DN    TI 1823: Removed dummy package constructor.
** 3.4	    04.03.2005 kaurrnar	Removed comp_vol_method and salt_method function.
*****************************************************************/

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

FUNCTION GRS_MASS_METHOD
RETURN VARCHAR2 IS

BEGIN

   RETURN 'GRS_MASS_METHOD';

END GRS_MASS_METHOD;

--

FUNCTION GRS_VOL_METHOD
RETURN VARCHAR2 IS

BEGIN

   RETURN 'GRS_VOL_METHOD';

END GRS_VOL_METHOD;

--

FUNCTION NET_MASS_METHOD
RETURN VARCHAR2 IS

BEGIN

   RETURN 'NET_MASS_METHOD';

END NET_MASS_METHOD;

--

FUNCTION NET_VOL_METHOD
RETURN VARCHAR2 IS

BEGIN

   RETURN 'NET_VOL_METHOD';

END NET_VOL_METHOD;

--

FUNCTION SEP_DENSITY_METHOD
RETURN VARCHAR2 IS

BEGIN

   RETURN 'SEP_DENS_METHOD';

END SEP_DENSITY_METHOD;

--

FUNCTION SHIP_CVOL_METHOD
RETURN VARCHAR2 IS

BEGIN

   RETURN 'SHIP_CVOL_METHOD';

END SHIP_CVOL_METHOD;

--

FUNCTION SHIP_VOL_METHOD
RETURN VARCHAR2 IS

BEGIN

   RETURN 'SHIP_VOL_METHOD';

END SHIP_VOL_METHOD;

--

FUNCTION STD_DENSITY_METHOD
RETURN VARCHAR2 IS

BEGIN

   RETURN 'STD_DENS_METHOD';

END STD_DENSITY_METHOD;

--

FUNCTION WAT_MASS_METHOD
RETURN VARCHAR2 IS

BEGIN

   RETURN 'WAT_MASS_METHOD';

END WAT_MASS_METHOD;

--

FUNCTION WAT_VOL_METHOD
RETURN VARCHAR2 IS

BEGIN

   RETURN 'WATER_VOL_METHOD';

END WAT_VOL_METHOD;


END;