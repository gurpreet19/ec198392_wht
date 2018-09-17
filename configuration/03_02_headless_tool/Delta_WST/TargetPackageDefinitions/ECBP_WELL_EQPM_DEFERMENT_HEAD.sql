CREATE OR REPLACE PACKAGE EcBp_Well_Eqpm_Deferment IS

/****************************************************************
** Package        :  EcBp_Well_Eqpm_Deferment, header part
**
** $Revision: 1.14.2.3 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Equipment and Well Deferment.
** Documentation  :  www.energy-components.com
**
** Created  : 11.07.2007  Sarojini Rajaretnam
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 10.10.2007 rajarsar ECPD-6313: Added calcWellProdLossDay
** 18.04.2008 rajarsar ECPD-7828: Added getParentEventLossRate
** 02.05.2008 rajarsar ECPD-7828: Updated parameter in getParentEventLossRate
** 21.05.2008 oonnnng  ECPD-7878: Add deleteChildEvent procedure and countChildEvent function.
** 24.10.2011 rajarsar ECPD-18545: Added getPlannedVolumes, getActualVolumes, getActualProducedVolumes and getAssignedDeferVolumes.
** 24.10.2011 abdulmaw ECPD-18546: Added calcWellEqpmActionVolume and VerifyActionsWellEqpm
** 27.10.2011 rajarsar ECPD-17492: Updated getEventLossRate, getPotentialRate, checkIfChildEventExists, checkValidChildPeriod, getParentEventLossRate, deleteChildEvent,countChildEvent to support new PK which is EVENT_NO.
** 22-11-2013 leongwen ECPD-26096: Added lock check chkDowntimeConstraintLock for Well Downtime, Well Downtime by Well and Well Constraints screens.
** 19-12-2013 kumarsur ECPD-26357: Modified checkIfEventOverlaps to include event_no.
** 03-01-2014 kumarsur ECPD-26357: Add checkChildEndDate procedure.
*****************************************************************/

FUNCTION getEventLossRate (
	p_event_no NUMBER,
	p_event_attribute VARCHAR2)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getEventLossRate, WNDS, WNPS, RNPS);

FUNCTION getPotentialRate (
	p_event_no NUMBER,
	p_potential_attribute VARCHAR2)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getPotentialRate, WNDS, WNPS, RNPS);

PROCEDURE checkIfChildEventExists(p_event_no NUMBER);

PROCEDURE checkIfEventOverlaps(p_object_id VARCHAR2, p_daytime DATE, p_end_date DATE,  p_downtime_categ VARCHAR2, p_event_no NUMBER);

PROCEDURE checkValidChildPeriod(p_parent_event_no NUMBER, p_daytime DATE);

FUNCTION calcWellProdLossDay(p_object_id VARCHAR2, p_daytime DATE, p_phase VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcWellProdLossDay, WNDS, WNPS, RNPS);

FUNCTION getParentEventLossRate (
	p_event_no NUMBER,
	p_event_attribute VARCHAR2,
   p_downtime_type VARCHAR2)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getParentEventLossRate, WNDS, WNPS, RNPS);

PROCEDURE deleteChildEvent(p_event_no NUMBER);

FUNCTION countChildEvent(p_event_no NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (countChildEvent, WNDS, WNPS, RNPS);

FUNCTION getPlannedVolumes(p_object_id VARCHAR2, p_phase VARCHAR2, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getPlannedVolumes, WNDS, WNPS, RNPS);

FUNCTION getActualVolumes(p_object_id VARCHAR2, p_phase VARCHAR2, p_daytime DATE) RETURN NUMBER;

FUNCTION getActualProducedVolumes(p_object_id VARCHAR2, p_strm_set VARCHAR2, p_daytime DATE) RETURN NUMBER;

FUNCTION getAssignedDeferVolumes(p_object_id VARCHAR2, p_phase VARCHAR2, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getAssignedDeferVolumes, WNDS, WNPS, RNPS);

FUNCTION calcWellEqpmActionVolume(p_event_no NUMBER, p_daytime DATE, p_end_date DATE, p_event_attribute VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcWellEqpmActionVolume, WNDS, WNPS, RNPS);

PROCEDURE VerifyActionsWellEqpm(p_event_no NUMBER, p_daytime DATE, p_end_date DATE, p_action VARCHAR2);

PROCEDURE chkDowntimeConstraintLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list);

PROCEDURE checkChildEndDate(p_parent_event_no NUMBER, p_daytime DATE);

END  EcBp_Well_Eqpm_Deferment;