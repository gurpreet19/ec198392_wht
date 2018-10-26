CREATE OR REPLACE PACKAGE BODY EcDp_Stream_Type IS

/****************************************************************
** Package        :  EcDp_Stream_Type, body part
**
** $Revision: 1.2 $
**
** Purpose        :  Defines stream types.
**
** Documentation  :  www.energy-components.com
**
** Created  : 17.01.2000  Carl-Fredrik S�sen
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
** 1.0   	17.01.00  CFS   Initial version
** x.x		13.07.00  �    Added function for stream_category (OIL_EXPORT etc)
**          03.12.04  DN     TI 1823: Removed dummy package constructor.
*****************************************************************/


FUNCTION CALCULATED
RETURN VARCHAR2 IS

BEGIN

   RETURN 'C';

END CALCULATED;

--

FUNCTION DERIVED
RETURN VARCHAR2 IS

BEGIN

   RETURN 'D';

END DERIVED;

--

FUNCTION FLOWLINE
RETURN VARCHAR2 IS

BEGIN

   RETURN 'F';

END FLOWLINE;

--

FUNCTION MEASURED
RETURN VARCHAR2 IS

BEGIN

   RETURN 'M';

END MEASURED;

--
FUNCTION QUALITY
RETURN VARCHAR2 IS

BEGIN

   RETURN 'Q';

END QUALITY;

--

FUNCTION THEORETICAL
RETURN VARCHAR2 IS

BEGIN

   RETURN 'X';

END THEORETICAL;

--

FUNCTION WELL
RETURN VARCHAR2 IS

BEGIN

   RETURN 'W';

END WELL;

--

FUNCTION GAS_EXPORT
RETURN VARCHAR2 IS

BEGIN

   RETURN 'GAS_EXPORT';

END GAS_EXPORT;

--

FUNCTION GAS_FUEL
RETURN VARCHAR2 IS

BEGIN

   RETURN 'GAS_FUEL';

END GAS_FUEL;

--

FUNCTION GAS_FLARE
RETURN VARCHAR2 IS

BEGIN

   RETURN 'GAS_FLARE';

END GAS_FLARE;

--

FUNCTION GAS_LOSS
RETURN VARCHAR2 IS

BEGIN

   RETURN 'GAS_LOSS';

END GAS_LOSS;

--

FUNCTION OIL_EXPORT
RETURN VARCHAR2 IS

BEGIN

   RETURN 'OIL_EXPORT';

END OIL_EXPORT;

--

FUNCTION OIL_LOSS
RETURN VARCHAR2 IS

BEGIN

   RETURN 'OIL_LOSS';

END OIL_LOSS;

END;