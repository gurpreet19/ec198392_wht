CREATE OR REPLACE PACKAGE EcBp_Deferment_Event IS
/****************************************************************
** Package        :  EcBp_Deferment_Event
**
** $Revision: 1.19.2.2 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to deferment.
**
** Documentation  :  www.energy-components.com
**
** Created  : 23.12.2005  Dagfinn Njå
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 12.09.2007 rajarsar Updated allocateGroupRateToWells
** 21.11.2007 LIZ      Add new functions verifyDeferment, approveDeferment, copyNewRec, SumDailyDeferredQty
** 15.01.2008 LIZ      new functions SumPeriodDeferredQty
** 29.05.2008 leeeewei Added procedure compareLowAndPotentialRate
** 25.05.2009 leongsei Added procedure checkPeriodDefertCalcLock
** 24.10.2011 rajarsar ECPD-18545: Added getPlannedVolumes, getActualVolumes, getActualProducedVolumes and getAssignedDeferVolumes.
** 18.06.2012 Leongwen ECPD-21351: Added calcDeferments and calcDefermentForAsset.
*****************************************************************/

-- Lock check procedures
PROCEDURE checkDefermentEventLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list);

PROCEDURE allocateGroupRateToWells(p_eventNo NUMBER);

PROCEDURE checkIfEventExists(p_event_no NUMBER, p_object_id VARCHAR2, p_event_type VARCHAR2, p_from_date DATE, p_to_date DATE);
PROCEDURE checkIfAffectedWellsOverlap(p_event_no NUMBER, p_object_id VARCHAR2, p_from_date DATE, p_to_date DATE);

FUNCTION GetCurrentAction(p_event_no NUMBER) return VARCHAR2;
PRAGMA RESTRICT_REFERENCES (GetCurrentAction, WNDS, WNPS, RNPS);

PROCEDURE VerifyActions(p_event_no NUMBER, p_daytime DATE, p_end_date DATE, p_action VARCHAR2);

FUNCTION CalcDeferredActionVolume(p_event_no NUMBER,p_daytime DATE,p_end_date DATE, p_phase VARCHAR2)RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (CalcDeferredActionVolume, WNDS, WNPS, RNPS);

PROCEDURE loadSummaryEvents (p_deferment_event_no NUMBER, p_old_end_date DATE DEFAULT NULL);

PROCEDURE verifyDeferment(p_eventNo NUMBER,p_user VARCHAR2);

PROCEDURE approveDeferment(p_eventNo NUMBER,p_user VARCHAR2);

PROCEDURE copyNewRec(p_eventNo NUMBER,p_user VARCHAR2);

FUNCTION SumDailyDeferredQty(
         p_object_id VARCHAR2,
         p_daytime DATE,
         p_def_event_type VARCHAR2,
         p_def_att VARCHAR2) return NUMBER;
PRAGMA RESTRICT_REFERENCES (SumDailyDeferredQty, WNDS, WNPS, RNPS);

FUNCTION SumPeriodDeferredQty(
         p_object_id VARCHAR2,
         p_from_date DATE,
         p_to_date DATE,
         p_def_event_type VARCHAR2,
         p_def_att VARCHAR2) return NUMBER;
PRAGMA RESTRICT_REFERENCES (SumPeriodDeferredQty, WNDS, WNPS, RNPS);

PROCEDURE compareLowAndPotentialRate(p_event_no NUMBER,p_daytime DATE,p_object_id WELL.OBJECT_ID%TYPE);

PROCEDURE checkPeriodDeferCalcLock(p_operation VARCHAR2, p_new_lock_columns  IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list);

FUNCTION getPlannedVolumes(p_object_id VARCHAR2, p_phase VARCHAR2, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getPlannedVolumes, WNDS, WNPS, RNPS);

FUNCTION getActualVolumes(p_object_id VARCHAR2, p_phase VARCHAR2, p_daytime DATE) RETURN NUMBER;

FUNCTION getActualProducedVolumes(p_object_id VARCHAR2, p_strm_set VARCHAR2, p_daytime DATE) RETURN NUMBER;

FUNCTION getAssignedDeferVolumes(p_object_id VARCHAR2, p_phase VARCHAR2, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getAssignedDeferVolumes, WNDS, WNPS, RNPS);

PROCEDURE calcDeferments(p_event_no VARCHAR2, p_asset_id VARCHAR2 DEFAULT NULL, p_from_date DATE DEFAULT NULL, p_to_date DATE DEFAULT NULL);

PROCEDURE calcDefermentForAsset(p_object_id VARCHAR2, p_from_date DATE, p_to_date DATE);

END EcBp_Deferment_Event;