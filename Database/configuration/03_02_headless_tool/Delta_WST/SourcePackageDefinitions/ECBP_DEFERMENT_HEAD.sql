CREATE OR REPLACE PACKAGE EcBp_Deferment IS

/****************************************************************
** Package        :  EcBp_Deferment, header part
**
** $Revision: 1.1 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Equipment and Well Deferment.
** Documentation  :  www.energy-components.com
**
** Created  : 01.07.2014  Wong Kai Chun
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 24-06-2014 wonggkai ECPD-28018: Create checkIfEventOverlaps.
** 21-07-2014 deshpadi ECPD-26044: Create checkValidChildPeriod
** 21-07-2014 deshpadi ECPD-26044: Create getEventLossRate
** 21-07-2014 deshpadi ECPD-26044: Create getPotentialRate
** 21-07-2014 deshpadi ECPD-26044: Create getParentEventLossRate
** 21-07-2014 deshpadi ECPD-26044: Create deleteChildEvent
** 21-07-2014 deshpadi ECPD-26044: Create countChildEvent
** 21-07-2014 deshpadi ECPD-26044: Create checkChildEndDate
** 09-09-2014 kumarsur ECPD-28473: Modified getEventLossRate to getEventLossVolume.
** 10-10-2014 kumarsur ECPD-28473: Modified getEventLossVolume.
** 16-10-2014 shindani ECPD-28601: Added getPlannedVolumes,getActualVolumes,getActualProducedVolumes,getAssignedDeferVolumes functions.
** 28-10-2014 kumarsur ECPD-29026: Create chkDefermentConstraintLock.
** 14-11-2014 wonggkai ECPD-28911: Added getCommonReasonCodeSetting.
** 26-11-2014 abdulmaw ECPD-29389: Create calcWellProdLossDay to calculate Loss Volume per day for a well when Deferment version is PD.0020
** 03-02-2015 dhavaalo ECPD-29754: Create calcWellCorrActionVolume to calculate corrective action volume for Deferment version[PD.0020]
** 09-03-2015 dhavaalo ECPD-29807: Changes to improve Well Deferment Performance. And code formatting done.
** 05-10-2016 dhavaalo ECPD-30185: New function added getEventLossVolume to calculate event loss for deferment event.
** 05-10-2016 dhavaalo ECPD-30185: New function added getEventLossRate to calculate event loss rate for deferment event.
** 25-10-2016 dhavaalo ECPD-31944: New function added getEventLossNoChildEvent to calculate event loss rate for deferment event.
** 11-10-2017 leongwen ECPD-49613: New procedure chkDefermentDayLock for Deferment Day
** 27-10-2017 kashisag ECPD-50026: Modified procedures and functions that are using the condition check with well_deferment table with extra condition to check with class_name is equal to WELL_DEFERMENT , WELL_DEFERMENT_CHILD.
** 30-10-2017 leongwen ECPD-50026: created new procedure checkIfEventDayOverlaps for PD.0023 Deferment Day screen use.
** 08-11-2017 dhavaalo ECPD-50429: checkIfEventOverlaps new default input parameter added.
** 12.02.2018 leongwen ECPD-52636: Moved function deduct1secondYn to package EcBp_Deferment here.
** 28.02.2018 leongwen ECPD-45873: Added function getParentEventLossMassRate, getEventLossMassRate, getParentEventLossMass, getEventLossMass, getEventLossMassNoChildEvent and getPotentialMassRate.
** 20.08.2018 khatrnit ECPD-53583: Added function getParentComment to get parent comment for the child deferment event.
*****************************************************************/

PROCEDURE checkIfEventOverlaps(p_object_id VARCHAR2, p_daytime DATE, p_end_date DATE,  p_event_type VARCHAR2, p_event_no NUMBER,p_parent_event_no NUMBER DEFAULT 1);

PROCEDURE checkIfEventDayOverlaps(p_object_id VARCHAR2, p_daytime DATE, p_end_date DATE,  p_event_type VARCHAR2, p_event_no NUMBER);

PROCEDURE checkValidChildPeriod(p_parent_event_no NUMBER ,p_daytime DATE);

FUNCTION getEventLossVolume (p_event_no NUMBER,p_phase VARCHAR2,p_object_id VARCHAR2 DEFAULT NULL,p_child_count NUMBER DEFAULT 1)
RETURN NUMBER;

FUNCTION getParentEventLossVolume (p_event_no NUMBER,p_event_attribute   VARCHAR2,p_deferment_type VARCHAR2)
RETURN NUMBER;

FUNCTION getPlannedVolumes(p_object_id VARCHAR2, p_phase VARCHAR2, p_daytime DATE)
RETURN NUMBER;

FUNCTION getActualVolumes(p_object_id VARCHAR2, p_phase VARCHAR2, p_daytime DATE, p_enddate DATE DEFAULT NULL)
RETURN NUMBER;

FUNCTION getActualProducedVolumes(p_object_id VARCHAR2, p_strm_set VARCHAR2, p_daytime DATE, p_enddate DATE DEFAULT NULL)
RETURN NUMBER;

FUNCTION getAssignedDeferVolumes(p_object_id VARCHAR2, p_phase VARCHAR2, p_daytime DATE, p_enddate DATE DEFAULT NULL)
RETURN NUMBER;

FUNCTION getPotentialRate(p_event_no NUMBER,p_potential_attribute VARCHAR2)
RETURN NUMBER;

FUNCTION getParentEventLossRate (p_event_no NUMBER,p_event_attribute   VARCHAR2,p_deferment_type VARCHAR2)
RETURN NUMBER;

FUNCTION getEventLossRate (p_event_no NUMBER,p_event_attribute VARCHAR2)
RETURN NUMBER;

FUNCTION getEventLossNoChildEvent (p_event_no NUMBER,p_event_attribute VARCHAR2)
RETURN NUMBER;

PROCEDURE deleteChildEvent(p_event_no NUMBER);

FUNCTION countChildEvent(p_event_no NUMBER)
RETURN NUMBER;

PROCEDURE chkDefermentConstraintLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list);

PROCEDURE checkChildEndDate(p_parent_event_no NUMBER ,p_daytime DATE);

FUNCTION getCommonReasonCodeSetting(p_key VARCHAR2)
RETURN CTRL_PROPERTY_META.DEFAULT_VALUE_STRING%TYPE;

FUNCTION calcWellProdLossDay(p_object_id VARCHAR2, p_daytime DATE, p_phase VARCHAR2)
RETURN NUMBER;

FUNCTION calcWellCorrActionVolume(p_event_no NUMBER, p_daytime DATE, p_end_date DATE, p_event_attribute VARCHAR2)
RETURN NUMBER;

FUNCTION getMthPlannedVolumes(p_object_id VARCHAR2, p_phase VARCHAR2, p_daytime DATE)
RETURN NUMBER;

FUNCTION getMthActualVolumes(p_object_id VARCHAR2, p_phase VARCHAR2, p_daytime DATE)
RETURN NUMBER;

FUNCTION getMthAssignedDeferVolumes(p_object_id VARCHAR2, p_phase VARCHAR2, p_daytime DATE)
RETURN NUMBER;

FUNCTION getScheduledDeferVolumes(p_object_id VARCHAR2, p_phase VARCHAR2, p_daytime DATE, p_scheduled VARCHAR2)
RETURN NUMBER;

PROCEDURE chkDefermentDayLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list);

FUNCTION deduct1secondYn(p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;

FUNCTION getParentEventLossMassRate(p_event_no NUMBER, p_event_attribute VARCHAR2, p_deferment_type VARCHAR2) RETURN NUMBER;

FUNCTION getEventLossMassRate(p_event_no NUMBER, p_event_attribute VARCHAR2) RETURN NUMBER;

FUNCTION getParentEventLossMass(p_event_no NUMBER, p_event_attribute VARCHAR2, p_deferment_type VARCHAR2) RETURN NUMBER;

FUNCTION getEventLossMass(p_event_no NUMBER, p_phase VARCHAR2, p_object_id VARCHAR2 DEFAULT NULL, p_child_count NUMBER DEFAULT 1) RETURN NUMBER;

FUNCTION getEventLossMassNoChildEvent(p_event_no NUMBER, p_event_attribute VARCHAR2) RETURN NUMBER;

FUNCTION getPotentialMassRate(p_event_no NUMBER, p_potential_attribute VARCHAR2) RETURN NUMBER;

FUNCTION getParentComment(p_event_no NUMBER) RETURN VARCHAR2;

END EcBp_Deferment;