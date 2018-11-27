CREATE OR REPLACE PACKAGE EcDp_Stream_Attribute IS

/****************************************************************
** Package        :  EcDp_Stream_Attribute, header part
**
** $Revision: 1.2 $
**
** Purpose        :  Definition of stream reference attributes
**
** Documentation  :  www.energy-components.com
**
** Created  : 27.12.1999  Carl-Fredrik S�sen
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ------      ----- -----------------------------------
** 1.0      27.12.1999  CFS   Initial version
** 3.1      14.11.2000  �    Changed return value on SHIP_CVOL_METHOD to return the
**                            string SHIP_CVOL_METHOD instead of SHIP_COMP_VOL_METHOD beacuse of a
**                            limitation in the database field (16 characters)
** 3.2      14.11.2000  �    Added this comment in header.
** 3.3      17.08.2001  HNE   New function Salt_method
** 3.4	    04.03.2005 kaurrnar	Removed comp_vol_method and salt_method function.
*****************************************************************/


FUNCTION BSW_VOL_METHOD
RETURN VARCHAR2;

--

FUNCTION BSW_WT_METHOD
RETURN VARCHAR2;

--

FUNCTION GRS_MASS_METHOD
RETURN VARCHAR2;

--

FUNCTION GRS_VOL_METHOD
RETURN VARCHAR2;

--

FUNCTION NET_MASS_METHOD
RETURN VARCHAR2;

--

FUNCTION NET_VOL_METHOD
RETURN VARCHAR2;

--

FUNCTION SEP_DENSITY_METHOD
RETURN VARCHAR2;

--

FUNCTION SHIP_CVOL_METHOD
RETURN VARCHAR2;

--

FUNCTION SHIP_VOL_METHOD
RETURN VARCHAR2;

--

FUNCTION STD_DENSITY_METHOD
RETURN VARCHAR2;

--

FUNCTION WAT_MASS_METHOD
RETURN VARCHAR2;

--

FUNCTION WAT_VOL_METHOD
RETURN VARCHAR2;


END;