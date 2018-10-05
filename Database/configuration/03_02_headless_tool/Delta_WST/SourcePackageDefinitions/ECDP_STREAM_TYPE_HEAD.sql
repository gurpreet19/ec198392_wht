CREATE OR REPLACE PACKAGE EcDp_Stream_Type IS

/****************************************************************
** Package        :  EcDp_Stream_Type, header part
**
** $Revision: 1.1.1.1 $
**
** Purpose        :  Defines stream types.
**
** Documentation  :  www.energy-components.com
**
** Created  : 18.01.2000  Carl-Fredrik S?sen
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
** 1.0      18.01.00  CFS   Initial version
** x.x		13.07.00  ?    Added function for stream_category (OIL_EXPORT etc)
*****************************************************************/

--

FUNCTION CALCULATED
RETURN VARCHAR2;

--

FUNCTION DERIVED
RETURN VARCHAR2;

--

FUNCTION FLOWLINE
RETURN VARCHAR2;

--

FUNCTION MEASURED
RETURN VARCHAR2;

--

FUNCTION QUALITY
RETURN VARCHAR2;

--

FUNCTION THEORETICAL
RETURN VARCHAR2;

--

FUNCTION WELL
RETURN VARCHAR2;

--

FUNCTION GAS_EXPORT
RETURN VARCHAR2;

--

FUNCTION GAS_FUEL
RETURN VARCHAR2;

--

FUNCTION GAS_FLARE
RETURN VARCHAR2;

--

FUNCTION GAS_LOSS
RETURN VARCHAR2;

--

FUNCTION OIL_EXPORT
RETURN VARCHAR2;

--

FUNCTION OIL_LOSS
RETURN VARCHAR2;


END EcDp_Stream_Type;