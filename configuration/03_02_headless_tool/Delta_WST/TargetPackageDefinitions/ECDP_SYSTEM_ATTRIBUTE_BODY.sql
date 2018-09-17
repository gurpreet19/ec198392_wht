CREATE OR REPLACE PACKAGE BODY EcDp_System_Attribute IS

/****************************************************************
** Package        :  EcDp_System_Attribute, body part
**
** $Revision: 1.3 $
**
** Purpose        :  Definition of system attributes
**
** Documentation  :  www.energy-components.com
**
** Created  : 17.01.2000  Carl-Fredrik Sørensen
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ------      ----- -----------------------------------
** 3.1      09.06.2000  CFS   Added new functions TSEP_APPR_GEN_VT,
**										TSEP_APPR_GEN_PC, UNIT_CONVERSION_MPM
**          03.12.04  DN     TI 1823: Removed dummy package constructor.
*****************************************************************/

--

FUNCTION DOWNTIME_METHOD
RETURN VARCHAR2 IS

BEGIN

   RETURN 'DOWNTIME_METHOD';

END DOWNTIME_METHOD;

--


FUNCTION TSEP_APPR_GEN_VT
RETURN VARCHAR2 IS

BEGIN

   RETURN 'TSEP_APPR_GEN_VT';

END TSEP_APPR_GEN_VT;

--

FUNCTION TSEP_APPR_GEN_PC
RETURN VARCHAR2 IS

BEGIN

   RETURN 'TSEP_APPR_GEN_PC';

END TSEP_APPR_GEN_PC;

--

FUNCTION UNIT_CONVERSION_MPM
RETURN VARCHAR2 IS

BEGIN

   RETURN 'UNIT_MPM';

END UNIT_CONVERSION_MPM;

--

FUNCTION WAG_INSTANT
RETURN VARCHAR2 IS

BEGIN

   RETURN 'WAG_INSTANT';

END WAG_INSTANT;

END;