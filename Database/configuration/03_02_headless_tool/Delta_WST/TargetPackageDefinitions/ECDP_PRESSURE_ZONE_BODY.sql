CREATE OR REPLACE PACKAGE BODY EcDp_pressure_zone IS

/****************************************************************
** Package        :  EcDp_pressure_zone, header part
**
** $Revision: 1.2 $
**
** Purpose        :  Definition of Pressure zones
**
** Documentation  :  www.energy-components.com
**
** Created  : 10.05.2000  Arild Vervik
**
** Modification history:
**
** Date        Whom  Change description:
** ---------   ----- -----------------------------------
** 03.12.2004  DN    TI 1823: Removed dummy package constructor.
*****************************************************************/



FUNCTION NORMAL
RETURN VARCHAR2 IS

BEGIN

   RETURN 'NORMAL';

END NORMAL;


FUNCTION LOW
RETURN VARCHAR2 IS

BEGIN

   RETURN 'LOW';

END LOW;

FUNCTION HIGH
RETURN VARCHAR2 IS

BEGIN

   RETURN 'HIGH';

END HIGH;


END;