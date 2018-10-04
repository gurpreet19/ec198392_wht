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
** Created  : 17.01.2000  Carl-Fredrik Sørensen
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

PRAGMA RESTRICT_REFERENCES(DOWNTIME_METHOD, WNDS, WNPS, RNPS);

--

FUNCTION TSEP_APPR_GEN_PC
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(TSEP_APPR_GEN_PC, WNDS, WNPS, RNPS);

--

FUNCTION TSEP_APPR_GEN_VT
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(TSEP_APPR_GEN_VT, WNDS, WNPS, RNPS);


--

FUNCTION UNIT_CONVERSION_MPM
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(UNIT_CONVERSION_MPM, WNDS, WNPS, RNPS);

--

FUNCTION WAG_INSTANT
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(WAG_INSTANT, WNDS, WNPS, RNPS);

--



END EcDp_System_Attribute;