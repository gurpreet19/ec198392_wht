CREATE OR REPLACE PACKAGE EcDp_Deferment IS

/****************************************************************
** Package        :  EcDp_Deferment, header part
**
** $Revision: 1.1 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Deferment PD.0020 and Deferment Day PD.0023.
** Documentation  :  www.energy-components.com
**
** Created  : 24.06.2014  Wong Kai Chun
**
** Modification history:
**
** Version  Date     	Whom  	 Change description:
** -------  ----------  -------- --------------------------------------
**	        24-06-2014	wonggkai ECPD-28018: Create trigger to populate wells
**          24-07-2014  deshpadi ECDP-26044: Create approveWellDeferment function.
**          24-07-2014  deshpadi ECDP-26044: Create verifyWellDeferment
**          24-07-2014  deshpadi ECDP-26044: Create setLossRate
**          24-07-2014  deshpadi ECDP-26044: Create updateReasonCodeForChildEvent
**          24-07-2014  deshpadi ECDP-26044: Create updateEndDateForChildEvent
**          25-07-2014  deshpadi ECDP-26044: Create allocateGroupRateToWells
**          25-07-2014  deshpadi ECDP-26044: Create sumFromWells
**          25-07-2014  deshpadi ECDP-26044: Create updateStartDateForChildEvent
**          30-07-2014  wonggkai ECPD-25669: Create insertTempWellDefermntAlloc and deleteTempWellDefermntAlloc for records in temp table TEMP_WELL_DEFERMENT_ALLOC
**          26-08-2014  wonggkai ECPD-25669: Add parameter p_group_event_no to insertWells()
**          28-07-2014  leongwen ECDP-28035: Added procedure allocWellDeferredVolume
**          09-11-2014  deshpadi ECDP-26044: Added procedure updateEventTypeForChildEvent, so that child event has the same event type as that of parent.
**          09-09-2014  leongwen ECDP-28035: Added procedure calcDeferments
**          09-10-2014  deshpadi ECPD-28986: Added procedure updateScheduledForChildEvent, so that child event has the same scheduled value as that of parent.
**          16-10-2014  leongwen ECDP-28993: Modified procedure insertTempWellDefermntAlloc to add parameter iud_action and removed the procedure deleteTempWellDefermntAlloc
**          29-10-2014  kumarsur ECDP-29026: Added procedure checkLockInd.
**          01-04-2015  kumarsur ECPD-29729: Add prev_equal_eventday.
**          20-04-2015  abdulmaw ECPD-29729: Support for Swing Well Scenario
**          20-01-2015  dhavaalo ECPD-30842: Link to Event/Equipment doesn't show Group Events in Well Deferment by Well
**          30-05-2016  shindani ECPD-34950: Modified procedure CalcDeferments to support calculation for wells available under selected facility.
**          20-03-2017  dhavaalo ECPD-42995: Deferment: Remove reference to PD.0020 in order to run calculation.Modified calcDeferments and reCalcDeferments
**          18-05-2017  leongwen ECPD-43801: Modified procedures calcDeferments and reCalcDeferments to perform the calculations that the navigation can stop at any level in the navigator.
**          01.09.2017  dhavaalo ECPD-48425: Modified fun_Constraint_hrs to findConstraintHrs.
**          12.10.2017  leongwen ECPD-49613: Added procedure verifyDefermentDayEvent and approveDefermentDayEvent
**          27-10-2017 kashisag ECPD-50026: Modified procedures and functions that are using the condition check with deferment_event table with extra condition to check with class_name is equal to WELL_DEFERMENT , WELL_DEFERMENT_CHILD.
**          16-01-2018  singishi ECPD-47302: Renamed all instances of table Well_deferment to deferment_event
**          09-02-2018  leongwen ECPD-52636: Moved procedures changeDefermentDay, deleteDefermentDay and AddRowsAtDefDayTable and function getSumLossMassDefDay from old EcDp_Deferment_Event package to this package.
**          29-04-2018  leongwen ECPD-55161: Modified updateEndDateForChildEvent and updateStartDateForChildEvent with additional parameters to support deferment recalculation.
*****************************************************************/

TYPE t_object_id                    IS TABLE OF deferment_event.OBJECT_ID%TYPE;
TYPE t_object_type                  IS TABLE OF deferment_event.OBJECT_TYPE%TYPE;
TYPE t_parent_event_no              IS TABLE OF deferment_event.PARENT_EVENT_NO%TYPE;
TYPE t_parent_object_id             IS TABLE OF deferment_event.PARENT_OBJECT_ID%TYPE;
TYPE t_parent_daytime               IS TABLE OF deferment_event.PARENT_DAYTIME%TYPE;
TYPE t_daytime                      IS TABLE OF deferment_event.DAYTIME%TYPE;
TYPE t_end_date                     IS TABLE OF deferment_event.END_DATE%TYPE;
TYPE t_event_type                   IS TABLE OF deferment_event.EVENT_TYPE%TYPE;
TYPE t_deferment_type               IS TABLE OF deferment_event.DEFERMENT_TYPE%TYPE;
TYPE t_created_by                   IS TABLE OF deferment_event.CREATED_BY%TYPE;

PROCEDURE insertWells(p_group_event_no NUMBER, p_event_type VARCHAR2, p_object_typ VARCHAR2, p_object_id VARCHAR2, p_daytime DATE, p_end_date DATE DEFAULT NULL, p_username VARCHAR2 );

PROCEDURE approveWellDeferment(p_event_no NUMBER,p_user_name VARCHAR2 );

PROCEDURE approveWellDefermentbyWell(p_event_no NUMBER, p_user_name VARCHAR2 );

PROCEDURE verifyWellDeferment(p_event_no NUMBER,p_user_name VARCHAR2 );

PROCEDURE verifyWellDefermentbyWell(p_event_no NUMBER, p_user_name VARCHAR2 );

PROCEDURE setLossRate (p_event_no NUMBER,p_user VARCHAR2 );

PROCEDURE updateReasonCodeForChildEvent(p_event_no NUMBER,p_user VARCHAR2,p_last_updated_date DATE);

PROCEDURE updateScheduledForChildEvent(p_event_no NUMBER,p_user VARCHAR2,p_last_updated_date DATE);

PROCEDURE updateEventTypeForChildEvent(p_event_no NUMBER,p_user VARCHAR2,p_last_updated_date DATE);

PROCEDURE updateEndDateForChildEvent(p_event_no NUMBER,
                                     p_n_daytime DATE DEFAULT NULL,
                                     p_o_daytime DATE DEFAULT NULL,
                                     p_n_end_date DATE,
                                     p_o_end_date DATE,
                                     p_iud_action VARCHAR2,
                                     p_user VARCHAR2,
                                     p_last_updated_date DATE);

PROCEDURE allocateGroupRateToWells(p_event_no NUMBER,p_user_name VARCHAR2);

PROCEDURE sumFromWells(p_event_no NUMBER, p_user_name VARCHAR2);

PROCEDURE updateStartDateForChildEvent(p_event_no NUMBER,
                                       p_n_start_date DATE,
                                       p_o_start_date DATE,
                                       p_n_end_date DATE DEFAULT NULL,
                                       p_o_end_date DATE DEFAULT NULL,
                                       p_iud_action VARCHAR2,
                                       p_user VARCHAR2,
                                       p_last_updated_date DATE);

PROCEDURE insertTempWellDefermntAlloc(p_event_no NUMBER, p_parent_event_no NUMBER DEFAULT NULL, p_n_daytime DATE, p_o_daytime DATE DEFAULT NULL, p_n_end_date DATE DEFAULT NULL, p_o_end_date DATE DEFAULT NULL, p_iud_action VARCHAR2, p_user_name VARCHAR2, p_last_updated_date date);

PROCEDURE reCalcDeferments(p_object_id VARCHAR2 DEFAULT NULL,p_nav_group_type VARCHAR2 DEFAULT NULL,p_nav_parent_class_name VARCHAR2 DEFAULT NULL,p_deferment_version VARCHAR2 DEFAULT NULL);

PROCEDURE calcDeferments(p_event_no VARCHAR2, p_asset_id VARCHAR2 DEFAULT NULL, p_from_date DATE DEFAULT NULL, p_to_date DATE DEFAULT NULL,p_object_id VARCHAR2 DEFAULT NULL,p_deferment_version VARCHAR2 DEFAULT NULL,p_nav_group_type VARCHAR2 DEFAULT NULL,p_nav_classname VARCHAR2 DEFAULT NULL);

PROCEDURE allocWellDeferredVolume(p_object_id VARCHAR2, p_from_date DATE, p_to_date DATE);

PROCEDURE checkLockInd(p_result_no NUMBER, p_daytime DATE, p_end_date DATE, p_object_id VARCHAR2);

FUNCTION prev_equal_eventday(p_object_id VARCHAR2, p_daytime DATE, p_num_rows NUMBER DEFAULT 1) RETURN DATE;

FUNCTION checkSwingWell(p_swing VARCHAR2, p_event VARCHAR2, p_well VARCHAR2, p_daytime DATE, p_fcty_id VARCHAR2, p_group_type VARCHAR2,p_class_name VARCHAR2, p_parent_type VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

PROCEDURE updateEventEqpmForChild(p_event_no NUMBER,p_user VARCHAR2,p_last_updated_date DATE);

FUNCTION findConstraintHrs(cp_day DATE, cp_start_daytime DATE,p_object_id VARCHAR2,p_temp_end_Date date,p_temp_start_Date date,p_open_end_event VARCHAR2) RETURN NUMBER;

PROCEDURE verifyDefermentDayEvent(p_event_no NUMBER,p_user_name VARCHAR2);

PROCEDURE approveDefermentDayEvent(p_event_no NUMBER,p_user_name VARCHAR2);

PROCEDURE changeDefermentDay(p_change_type VARCHAR2, p_object_id VARCHAR2, p_event_no NUMBER, p_daytime DATE, p_end_daytime DATE DEFAULT NULL, p_user VARCHAR2);

PROCEDURE deleteDefermentDay(p_event_no NUMBER);

FUNCTION getSumLossMassDefDay(p_attribute VARCHAR2, p_event_no NUMBER) RETURN NUMBER;

PROCEDURE AddRowsAtDefDayTable(p_event_no NUMBER, p_object_id VARCHAR2, p_stDate DATE, p_endDate DATE, p_user VARCHAR2);

END  EcDp_Deferment;