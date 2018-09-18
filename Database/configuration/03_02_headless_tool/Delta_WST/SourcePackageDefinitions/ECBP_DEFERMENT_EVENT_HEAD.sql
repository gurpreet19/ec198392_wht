CREATE OR REPLACE PACKAGE EcBp_Deferment_Event IS
/****************************************************************
** Package        :  EcBp_Deferment_Event
**
** $Revision: 1.21 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to deferment.
**
** Documentation  :  www.energy-components.com
**
** Created  : 23.12.2005  Dagfinn Nj?
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
** 18.06.2012 Leongwen ECPD-20245: Added calcDeferments and calcDefermentForAsset.
** 21.10.2017 Leongwen ECPD-49613: Added function deduct1secondYn for deferment day java pre-save class use.
** 13.12.2017 singishi ECPD-51137: Removed procedure/function: checkDefermentEventLock, allocateGroupRateToWells, checkIfEventExists, checkIfAffectedWellsOverlap, verifyDeferment, approveDeferment, copyNewRec, SumDailyDeferredQty, SumPeriodDeferredQty, compareLowAndPotentialRate,getPlannedVolumes, getActualProducedVolumes, getAssignedDeferVolumes,calcDeferments,calcDefermentForAsset,CalcDeferredActionVolume,VerifyActions
** 12.02.2018 leongwen ECPD-52636: Moved function deduct1secondYn to package EcBp_Deferment.
*****************************************************************/

-- Lock check procedures


FUNCTION GetCurrentAction(p_event_no NUMBER) return VARCHAR2;

PROCEDURE loadSummaryEvents (p_deferment_event_no NUMBER, p_old_end_date DATE DEFAULT NULL);

PROCEDURE checkPeriodDeferCalcLock(p_operation VARCHAR2, p_new_lock_columns  IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list);

END EcBp_Deferment_Event;