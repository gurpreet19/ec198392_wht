CREATE OR REPLACE PACKAGE EcDp_Lift_Acc_Official IS
/****************************************************************
** Package        :  EcDp_Lift_Acc_Official; head part
**
** $Revision: 1.3 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  07.09.2006	Kari Sandvik
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
*****************************************************************/

FUNCTION getDay(p_object_id VARCHAR2, p_daytime DATE, p_official_type VARCHAR2 DEFAULT NULL) RETURN NUMBER;

FUNCTION getTotalMonth(p_object_id VARCHAR2, p_daytime DATE, p_official_type VARCHAR2 DEFAULT NULL, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

FUNCTION IsMissingOfficialNumbers(p_object_id VARCHAR2,	p_daytime DATE) RETURN VARCHAR2;

PROCEDURE aggregateSubDay(p_object_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0);

END EcDp_Lift_Acc_Official;