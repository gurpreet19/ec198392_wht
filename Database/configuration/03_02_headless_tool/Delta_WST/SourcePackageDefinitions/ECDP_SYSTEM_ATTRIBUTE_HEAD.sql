CREATE OR REPLACE PACKAGE EcDp_System_Attribute IS

/****************************************************************
** Package        :  EcDp_System_Attribute, header part
**
** $Revision: 1.2 $
**
** Purpose        :  Definition of system attributes
**
** Documentation  :  www.energy-components.com
**
** Created  : 17.01.2000  Carl-Fredrik S?sen
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ------      ----- -----------------------------------
** 3.1      09.06.2000  CFS   Added new functions TSEP_APPR_GEN_VT,
**										TSEP_APPR_GEN_PC, UNIT_CONVERSION_MPM
*****************************************************************/

--

FUNCTION DOWNTIME_METHOD
RETURN VARCHAR2;

--

FUNCTION TSEP_APPR_GEN_PC
RETURN VARCHAR2;

--

FUNCTION TSEP_APPR_GEN_VT
RETURN VARCHAR2;


--

FUNCTION UNIT_CONVERSION_MPM
RETURN VARCHAR2;

--

FUNCTION WAG_INSTANT
RETURN VARCHAR2;

--



END EcDp_System_Attribute;