CREATE OR REPLACE PACKAGE EcBp_Lift_Acc_Balance IS
/****************************************************************
** Package        :  EcBp_Lift_Acc_Balance; head part
**
** $Revision: 1.11 $
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
** 22.08.2013  leeeewei		ECPD-12789: Make ecbp_lift_acc_balance.isCargosClosed function visible outside the package
** 26.05.2015  sharawan     ECPD-19047: Added parameter p_ignore_cache to calcEstClosingBalanceDay and calcEstClosingBalanceSubDay
*****************************************************************/

FUNCTION getOpeningBalanceMth (p_object_id	VARCHAR2, p_daytime	DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

FUNCTION calcEstOpeningBalanceMth (p_object_id	VARCHAR2, p_daytime	DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;
--

FUNCTION isLiftingAccountClosed (p_object_id VARCHAR2, p_daytime DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN VARCHAR2;

FUNCTION calcClosingBalanceMth(p_object_id	VARCHAR2, p_daytime	DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;
--

FUNCTION calcEstClosingBalanceMth(p_object_id	VARCHAR2, p_daytime	DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;
--

FUNCTION calcEstClosingBalanceDay(p_object_id	VARCHAR2, p_daytime	DATE, p_xtra_qty NUMBER DEFAULT 0, p_ignore_cache VARCHAR2 DEFAULT 'N') RETURN NUMBER;
--

FUNCTION calcAggrEstClosingBalanceDay(p_object_id VARCHAR2, p_daytime	DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;
--

FUNCTION calcEstClosingBalanceSubDay(p_object_id	VARCHAR2, p_daytime	DATE, p_summer_time VARCHAR2, p_xtra_qty NUMBER DEFAULT 0, p_ignore_cache VARCHAR2 DEFAULT 'N') RETURN NUMBER;
--

FUNCTION getAdjustmentsMth(p_object_id	VARCHAR2, p_daytime	DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

FUNCTION getAdjustmentsDay(p_object_id	VARCHAR2, p_daytime	DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

FUNCTION getAdjustmentsSubDay(p_object_id	VARCHAR2, p_from_date DATE, p_to_date DATE, p_xtra_qty NUMBER DEFAULT 0) RETURN NUMBER;

FUNCTION IsCargosClosed(p_lifting_account_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;

PROCEDURE valInsertInitBalance(p_object_id VARCHAR2);

PROCEDURE valUpdateInitBalance(p_object_id VARCHAR2, p_daytime DATE);

PROCEDURE setClosingBalance(p_object_id	VARCHAR2, p_daytime DATE, p_balance NUMBER, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE openNextMonthRecord(p_object_id VARCHAR2, p_daytime DATE);

END EcBp_Lift_Acc_Balance;