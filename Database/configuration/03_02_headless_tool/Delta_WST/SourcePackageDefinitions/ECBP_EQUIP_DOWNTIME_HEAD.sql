CREATE OR REPLACE PACKAGE EcBp_Equip_Downtime IS
/****************************************************************
** Package        :  EcBp_Equip_Downtime, header part
**
** $Revision: 1.1 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Equipment downtime.
** Documentation  :  www.energy-components.com
**
** Created  : 21.04.2017  chaudgau
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 21.04.2017 chaudgau ECPD-44611: Inital version
*****************************************************************/

PROCEDURE checkIfChildEventExists(p_event_no NUMBER);

PROCEDURE checkIfEventOverlaps(p_object_id VARCHAR2, p_daytime DATE, p_end_date DATE, p_event_no NUMBER);

PROCEDURE checkValidChildPeriod(p_parent_event_no NUMBER, p_daytime DATE);

PROCEDURE deleteChildEvent(p_event_no NUMBER);

FUNCTION countChildEvent(p_event_no NUMBER) RETURN NUMBER;

PROCEDURE VerifyActionsEquip(p_event_no NUMBER, p_daytime DATE, p_end_date DATE, p_action VARCHAR2);

PROCEDURE chkDowntimeConstraintLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list);

PROCEDURE checkChildEndDate(p_parent_event_no NUMBER, p_daytime DATE);

END EcBp_Equip_Downtime;