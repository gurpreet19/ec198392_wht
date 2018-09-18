CREATE OR REPLACE PACKAGE EcDp_Performance_Lock IS
/****************************************************************
** Package        :  EcDp_Performance_Lock, head part
**
** $Revision: 1.5 $
**
** Purpose        :  Locking procedures for Performace Test classes
**
** Documentation  :  www.energy-components.com
**
** Created  : 14.12.2005 Arild Vervik
**
** Modification history:
**
** Date     	Whom  	Change description:
** ------   	----- 	---------------------------------------------------------------------
**
*************************************************************************************************/

--

-- FUNCTION prodTestApproachMethod(p_result_no NUMBER, p_valid_from_date DATE) RETURN  VARCHAR2;


PROCEDURE  CheckLockProductionTest(p_operation VARCHAR2, l_new IN OUT EcDp_month_lock.column_list, l_old IN OUT EcDp_month_lock.column_list);

PROCEDURE  CheckLockPerformanceCurve(p_operation VARCHAR2, l_new IN OUT EcDp_month_lock.column_list, l_old IN OUT EcDp_month_lock.column_list);

PROCEDURE  CheckResultNoLock(p_result_no NUMBER);

PROCEDURE  CheckLockProdTestAllStatus(p_operation VARCHAR2, l_new IN OUT EcDp_month_lock.column_list, l_old IN OUT EcDp_month_lock.column_list);


END EcDp_Performance_Lock;