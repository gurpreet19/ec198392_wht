CREATE OR REPLACE PACKAGE EcDp_pressure_zone IS

/****************************************************************
** Package        :  EcDp_pressure_zone, header part
**
** $Revision: 1.1.1.1 $
**
** Purpose        :  Definition of Pressure zones
**
** Documentation  :  www.energy-components.com
**
** Created  : 10.05.2000  Arild Vervik
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ------      ----- -----------------------------------
*****************************************************************/



FUNCTION NORMAL
RETURN VARCHAR2;

--

FUNCTION LOW
RETURN VARCHAR2;

--

FUNCTION HIGH
RETURN VARCHAR2;


END;