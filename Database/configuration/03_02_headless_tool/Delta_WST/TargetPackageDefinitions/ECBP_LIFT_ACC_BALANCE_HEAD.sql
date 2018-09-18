CREATE OR REPLACE PACKAGE EcBp_Lift_Acc_Balance IS
/****************************************************************
** Package        :  EcBp_Lift_Acc_Balance; head part
**
** $Revision: 1.9.4.1 $
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
** 10.02.2012  sharawan     ECPD-19573 : Add function calcAggrEstClosingBalanceDay to sum the lifting account balance
**                          for lifting agreement lifting accounts.
*****************************************************************/

FUNCTION getOpeningBalanceMth (p_object_id	VARCHAR2, p_daytime	DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getOpeningBalanceMth, WNDS, WNPS, RNPS);

FUNCTION calcEstOpeningBalanceMth (p_object_id	VARCHAR2, p_daytime	DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (calcEstOpeningBalanceMth, WNDS, WNPS, RNPS);

FUNCTION isLiftingAccountClosed (p_object_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (isLiftingAccountClosed, WNDS, WNPS, RNPS);

FUNCTION calcClosingBalanceMth(p_object_id	VARCHAR2, p_daytime	DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (calcClosingBalanceMth, WNDS, WNPS, RNPS);

FUNCTION calcEstClosingBalanceMth(p_object_id	VARCHAR2, p_daytime	DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (calcEstClosingBalanceMth, WNDS, WNPS, RNPS);

FUNCTION calcEstClosingBalanceDay(p_object_id	VARCHAR2, p_daytime	DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (calcEstClosingBalanceDay, WNDS);

FUNCTION calcAggrEstClosingBalanceDay(p_object_id VARCHAR2, p_daytime	DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (calcAggrEstClosingBalanceDay, WNDS);

FUNCTION calcEstClosingBalanceSubDay(p_object_id	VARCHAR2, p_daytime	DATE, p_summer_time VARCHAR2, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (calcEstClosingBalanceSubDay, WNDS);

FUNCTION getAdjustmentsMth(p_object_id	VARCHAR2, p_daytime	DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getAdjustmentsMth, WNDS, WNPS, RNPS);

FUNCTION getAdjustmentsDay(p_object_id	VARCHAR2, p_daytime	DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getAdjustmentsDay, WNDS, WNPS, RNPS);

FUNCTION getAdjustmentsSubDay(p_object_id	VARCHAR2, p_from_date DATE, p_to_date DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getAdjustmentsSubDay, WNDS, WNPS, RNPS);

PROCEDURE valInsertInitBalance(p_object_id VARCHAR2);

PROCEDURE valUpdateInitBalance(p_object_id VARCHAR2, p_daytime DATE);

PROCEDURE setClosingBalance(p_object_id	VARCHAR2, p_daytime DATE, p_balance NUMBER, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE openNextMonthRecord(p_object_id VARCHAR2, p_daytime DATE);

END EcBp_Lift_Acc_Balance;