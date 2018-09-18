CREATE OR REPLACE PACKAGE EcDp_Storage_Official IS
/****************************************************************
** Package        :  EcDp_Storage_Official; head part
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
** 18.12.2013  leeeewei	ECPD-25944: Added new function getStorDayAverage
*****************************************************************/

FUNCTION getDay(p_object_id VARCHAR2, p_daytime DATE, p_official_type VARCHAR2 DEFAULT NULL) RETURN NUMBER;

FUNCTION getTotalMonth(p_object_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0,p_official_type VARCHAR2 DEFAULT NULL) RETURN NUMBER;

PROCEDURE aggregateSubDay(p_object_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0);

FUNCTION getStorDayAverage(p_storage_id VARCHAR2,p_first_of_month DATE,p_xtra_qty NUMBER DEFAULT 0,p_official_type VARCHAR2 DEFAULT NULL) RETURN NUMBER;

END EcDp_Storage_Official;