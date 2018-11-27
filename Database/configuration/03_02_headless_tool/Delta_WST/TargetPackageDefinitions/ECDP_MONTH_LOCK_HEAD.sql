CREATE OR REPLACE PACKAGE EcDp_Month_Lock IS

/****************************************************************
** Package        :  EcDp_Month_Lock, header part
**
** $Revision: 1.8 $
**
** Purpose        :  Provides an interface with methods and structures used checking  monthly locks.
**
** Documentation  :  www.energy-components.com
**
** Created  : 05.12.2005  Arild Vervik
**
** Modification history:
**
**  Date     Whom  Change description:
**  ------   ----- --------------------------------------
**  20-Nov-2008  oonnnng  Added localLockedMonthAffected, localWithinLockedMonth, localBuildIdentifierString,
                          localRaiseValidationError, localValidPeriodForLockOverlap, localCheckUpdateOfLDOForLock,
                          and localCheckUpdateEventForLock functions.
**  17-Feb-2009  oonnnng  Removed localValidPeriodForLockOverlap, localCheckUpdateOfLDOForLock,
                          and localCheckUpdateEventForLock functions.
                          Added 2 localLockCheck() function.
                          Add new parameter p_object_id to validatePeriodForLockOverlap, checkUpdateOfLDOForLock() and checkUpdateEventForLock() functions.
**  10-April-2009  oonnnng  Update localLockCheck() function with return DATE.
**
****************************************************************/


TYPE column_record IS RECORD(
    column_name  VARCHAR2(100),
    data_type    VARCHAR2(30),
    is_key       VARCHAR2(1),
    is_checked   VARCHAR2(1),
    is_changed   VARCHAR2(1),
    column_data  ANYDATA
    );

TYPE column_list IS TABLE OF column_record INDEX BY VARCHAR2(64);

FUNCTION lockedMonthAffected(p_from_daytime DATE, p_to_daytime DATE) RETURN DATE;
PRAGMA RESTRICT_REFERENCES(lockedMonthAffected, WNDS, WNPS, RNPS);

FUNCTION localLockedMonthAffected(p_local_lock_level VARCHAR2, p_object_id VARCHAR2, p_from_daytime DATE, p_to_daytime DATE) RETURN DATE;
PRAGMA RESTRICT_REFERENCES(localLockedMonthAffected, WNDS, WNPS, RNPS);

FUNCTION isUpdating(p_updating BOOLEAN) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(isUpdating, WNDS, WNPS, RNPS);

FUNCTION withinLockedMonth(p_daytime DATE) RETURN DATE;
PRAGMA RESTRICT_REFERENCES(withinLockedMonth, WNDS, WNPS, RNPS);

FUNCTION localWithinLockedMonth(p_local_lock_level VARCHAR2, p_object_id VARCHAR2, p_daytime DATE) RETURN DATE;
PRAGMA RESTRICT_REFERENCES(localWithinLockedMonth, WNDS, WNPS, RNPS);

FUNCTION checkIfColumnsUpdated(p_col_list EcDp_month_lock.column_list) RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(checkIfColumnsUpdated, WNDS, WNPS, RNPS);

FUNCTION buildIdentifierString(p_col_list EcDp_month_lock.column_list) RETURN VARCHAR2;

FUNCTION localBuildIdentifierString(p_obj_id VARCHAR2, p_msg VARCHAR2) RETURN VARCHAR2;

PROCEDURE addParameterToList(
    p_update_list       IN OUT  column_list,
    p_id                VARCHAR2,
    p_column_name       VARCHAR2,
    p_data_type         VARCHAR2,
    p_is_key            VARCHAR2,
    p_is_changed        VARCHAR2,
    p_column_data       ANYDATA
);

PROCEDURE raiseValidationError(p_operation VARCHAR2, p_from_daytime DATE, p_to_daytime DATE, p_locked_month DATE, p_id VARCHAR2);

PROCEDURE localRaiseValidationError(p_object_id VARCHAR2, p_operation VARCHAR2, p_from_daytime DATE, p_to_daytime DATE, p_locked_month DATE, p_id VARCHAR2);

PROCEDURE validatePeriodForLockOverlap(p_operation VARCHAR2,
                                       p_from_daytime DATE,
                                       p_to_daytime DATE,
                                       p_id VARCHAR2,
                                       p_object_id VARCHAR2 DEFAULT NULL);

PROCEDURE checkUpdateOfLDOForLock(p_new_current_valid DATE,
                                  p_old_current_valid DATE,
                                  p_new_next_valid DATE,
                                  p_old_next_valid DATE,
                                  p_old_prev_valid DATE,
                                  p_columns_updated VARCHAR,
                                  p_id VARCHAR2,
                                  p_object_id VARCHAR2 DEFAULT NULL);

PROCEDURE checkUpdateEventForLock(p_new_daytime     DATE,
                                  p_old_daytime     DATE,
                                  p_new_end_date    DATE,
                                  p_old_end_date    DATE,
                                  p_columns_updated VARCHAR,
                                  p_id              VARCHAR2,
                                  p_object_id VARCHAR2 DEFAULT NULL);

PROCEDURE localLockCheck(p_call_func    VARCHAR2,
                         p_object_id    VARCHAR2,
                         p_fromdate     DATE,
                         p_todate       DATE,
                         p_operation    VARCHAR2,
                         p_msg          VARCHAR2 DEFAULT NULL);

FUNCTION localLockCheck(p_call_func    VARCHAR2,
                        p_object_id    VARCHAR2,
                        p_fromdate     DATE,
                        p_todate       DATE)
RETURN DATE;

END EcDp_Month_Lock;