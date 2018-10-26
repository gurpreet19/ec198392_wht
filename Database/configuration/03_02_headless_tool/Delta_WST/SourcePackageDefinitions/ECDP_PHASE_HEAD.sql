CREATE OR REPLACE PACKAGE EcDp_Phase IS
/****************************************************************
** Package        :  EcDp_Phase, header part
**
** $Revision: 1.6 $
**
** Purpose        :  Definition of phase constants
**
** Documentation  :  www.energy-components.com
**
** Created  : 06.03.2000  Dagfinn Nj�
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ------      ----- -----------------------------------
** 3.1      16.08.2001  HNE   Added NGL
** 3.2	    20.08.2001 ATL    Added DIESEL
** 3.3      27.08.2001 ATL    Added CRUDE
** 3.4      28.11.2005 ROV    Added STEAM
** 3.5      03.04.2006 EJJ    Added LIQUID
** 3.6      06.09.2007 RAJARSAR ECPD-6264 - Added OIL_MASS, GAS_MASS, WATER_MASS, CONDENSATE_MASS
** 3.7      11.08.2008 OONNNNG  ECPD-8760: Added WAT_INJ and GAS_INJ functions.
** 3.8      24.01.2013 WONGGKAI ECPD-23348: Added GAS_LIFT function.
** 3.9      27.09.2016 KESKAASH ECPD-35756: Added HC function.
*****************************************************************/

FUNCTION CRUDE
RETURN VARCHAR2;

--

FUNCTION DIESEL
RETURN VARCHAR2;

--

FUNCTION NGL
RETURN VARCHAR2;

--

FUNCTION OIL
RETURN VARCHAR2;

--

FUNCTION GAS
RETURN VARCHAR2;

--

FUNCTION WATER
RETURN VARCHAR2;

--

FUNCTION CONDENSATE
RETURN VARCHAR2;

--

FUNCTION STEAM
RETURN VARCHAR2;

--

FUNCTION LIQUID
RETURN VARCHAR2;

--

FUNCTION OIL_MASS
RETURN VARCHAR2;

--

FUNCTION GAS_MASS
RETURN VARCHAR2;

--

FUNCTION WATER_MASS
RETURN VARCHAR2;

--

FUNCTION CONDENSATE_MASS
RETURN VARCHAR2;

--

FUNCTION GAS_INJ
RETURN VARCHAR2;


--

FUNCTION WAT_INJ
RETURN VARCHAR2;

--

FUNCTION GAS_LIFT
RETURN VARCHAR2;

--

FUNCTION HC
RETURN VARCHAR2;


END;