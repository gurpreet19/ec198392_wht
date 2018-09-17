CREATE OR REPLACE PACKAGE BODY EcDp_Flowline_Attribute IS

/****************************************************************
** Package        :  EcDp_Flowline_Attribute, body part
**
** $Revision: 1.2 $
**
** Purpose        :  Definition of well attributes
**
** Documentation  :  www.energy-components.com
**
** Created  : 17.01.2000  Carl-Fredrik S?sen
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ------      ----- -----------------------------------
** 1.0      17.01.2000  CFS   Initial version
**          03.12.2004  DN    TI 1823: Removed dummy package constructor.
*****************************************************************/

--

FUNCTION CALC_METHOD
RETURN VARCHAR2 IS

BEGIN

   RETURN 'CALC_METHOD';

END CALC_METHOD;

--

FUNCTION FLOWLINE_GOR
RETURN VARCHAR2 IS

BEGIN

   RETURN 'FLWL_GOR';

END FLOWLINE_GOR;

--

FUNCTION FLOWLINE_TYPE
RETURN VARCHAR2 IS

BEGIN

   RETURN 'FLOWLINE_TYPE';

END FLOWLINE_TYPE;

--

FUNCTION GAS_METHOD
RETURN VARCHAR2 IS

BEGIN

   RETURN 'GAS_METHOD';

END GAS_METHOD;

END;