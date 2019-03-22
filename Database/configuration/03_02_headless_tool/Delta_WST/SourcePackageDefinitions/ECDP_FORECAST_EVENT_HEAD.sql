CREATE OR REPLACE PACKAGE EcDp_Forecast_Event IS

/****************************************************************
** Package        :  EcDp_Forecast_Event, header part
**
** $Revision: 1.1 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Forecast Event.
** Documentation  :  www.energy-components.com
**
** Created  : 19.05.2016 Suresh Kumar
**
** Modification history:
**
**   Date      Whom        Change description:
** ----------  ----------  ----------------------------------------------
** 19-05-2016  kumarsur    Initial Version
** 25-07-2016  abdulmaw    ECPD-37247: Added reCalcDeferments, calcDeferments and allocWellDeferredVolume to support calculate forecast event
** 28.06.2018  kashisag    ECPD-56997: Added custom parameter to reCalcDeferments
** 26.07.2018  kashisag    ECPD-56795: Changed objectid to scenario id
** 07.12.2018  leongwen    ECPD-56158: Applied the logic from Well Deferment PD.0020 overlapping events recalculation to Forecast Event Deferment Calculation PP.0047
**                                     Modified procedure updateEndDateForChildEvent, updateStartDateForChildEvent.
**                                     Added procedure reUseOverlappedRecords.
*****************************************************************/

TYPE t_object_id                    IS TABLE OF FCST_WELL_EVENT.EVENT_ID%TYPE;
TYPE t_object_type                  IS TABLE OF FCST_WELL_EVENT.OBJECT_TYPE%TYPE;
TYPE t_forecast_id                  IS TABLE OF FCST_WELL_EVENT.FORECAST_ID%TYPE;
TYPE t_scenario_id                  IS TABLE OF FCST_WELL_EVENT.SCENARIO_ID%TYPE;
TYPE t_parent_event_no              IS TABLE OF FCST_WELL_EVENT.PARENT_EVENT_NO%TYPE;
TYPE t_parent_object_id             IS TABLE OF FCST_WELL_EVENT.PARENT_OBJECT_ID%TYPE;
TYPE t_parent_daytime               IS TABLE OF FCST_WELL_EVENT.PARENT_DAYTIME%TYPE;
TYPE t_daytime                      IS TABLE OF FCST_WELL_EVENT.DAYTIME%TYPE;
TYPE t_end_date                     IS TABLE OF FCST_WELL_EVENT.END_DATE%TYPE;
TYPE t_event_type                   IS TABLE OF FCST_WELL_EVENT.EVENT_TYPE%TYPE;
TYPE t_deferment_type               IS TABLE OF FCST_WELL_EVENT.DEFERMENT_TYPE%TYPE;
TYPE t_created_by                   IS TABLE OF FCST_WELL_EVENT.CREATED_BY%TYPE;

TYPE t_sourceEventNoforReCalc       IS TABLE OF FCST_WELL_EVENT.EVENT_NO%TYPE;
TYPE t_sourceEventID                IS TABLE OF FCST_WELL_EVENT.EVENT_ID%TYPE;
TYPE t_sourceEventDaytime           IS TABLE OF FCST_WELL_EVENT.DAYTIME%TYPE;
TYPE t_sourceEventEnd_date          IS TABLE OF FCST_WELL_EVENT.END_DATE%TYPE;
TYPE t_targetEventNoforReCalc       IS TABLE OF FCST_WELL_EVENT.EVENT_NO%TYPE;
TYPE t_targetParentENoforReCalc     IS TABLE OF FCST_WELL_EVENT.EVENT_NO%TYPE;
TYPE t_targetDaytimeforReCalc       IS TABLE OF FCST_WELL_EVENT.DAYTIME%TYPE;
TYPE t_targetEnd_dateforReCalc      IS TABLE OF FCST_WELL_EVENT.END_DATE%TYPE;

PROCEDURE allocateGroupRateToWells(p_event_no NUMBER,p_user_name VARCHAR2);

PROCEDURE checkLockInd(p_result_no NUMBER, p_daytime DATE, p_end_date DATE, p_object_id VARCHAR2);

PROCEDURE sumFromWells(p_event_no NUMBER, p_user_name VARCHAR2);

PROCEDURE insertWells(p_group_event_no NUMBER,
                      p_forecast_id VARCHAR2,
                      p_scenario_id VARCHAR2,
                      p_event_type VARCHAR2,
                      p_object_typ VARCHAR2,
                      p_object_id VARCHAR2,
                      p_daytime DATE,
                      p_end_date DATE DEFAULT NULL,
                      p_username VARCHAR2);

PROCEDURE setLossRate (p_event_no NUMBER,
                       p_user VARCHAR2);

PROCEDURE updateReasonCodeForChildEvent(p_event_no NUMBER,
                                        p_user VARCHAR2,
                                        p_last_updated_date DATE);

PROCEDURE updateScheduledForChildEvent(p_event_no NUMBER,
                                       p_user VARCHAR2,
                                       p_last_updated_date DATE);

PROCEDURE updateEventTypeForChildEvent(p_event_no NUMBER,
                                       p_user VARCHAR2,
                                       p_last_updated_date DATE);

PROCEDURE updateEndDateForChildEvent(p_event_no NUMBER,
                                     p_n_daytime DATE DEFAULT NULL,
                                     p_o_daytime DATE DEFAULT NULL,
                                     p_n_end_date DATE,
                                     p_o_end_date DATE,
                                     p_iud_action VARCHAR2,
                                     p_user VARCHAR2,
                                     p_last_updated_date DATE);

PROCEDURE updateStartDateForChildEvent(p_event_no NUMBER,
                                       p_n_start_date DATE,
                                       p_o_start_date DATE,
                                       p_n_end_date DATE DEFAULT NULL,
                                       p_o_end_date DATE DEFAULT NULL,
                                       p_iud_action VARCHAR2,
                                       p_user VARCHAR2,
                                       p_last_updated_date DATE);

PROCEDURE insertTempFcstWellEventAlloc(p_event_no NUMBER,
                                       p_parent_event_no NUMBER DEFAULT NULL,
                                       p_n_daytime DATE,
                                       p_o_daytime DATE DEFAULT NULL,
                                       p_n_end_date DATE DEFAULT NULL,
                                       p_o_end_date DATE DEFAULT NULL,
                                       p_iud_action VARCHAR2,
                                       p_user_name VARCHAR2,
                                       p_last_updated_date date);

PROCEDURE updateEventEqpmForChild(p_event_no NUMBER,
                                  p_user VARCHAR2,
                                  p_last_updated_date DATE);

PROCEDURE reCalcDeferments(p_scenario_id VARCHAR2 DEFAULT NULL, p_custom_param VARCHAR2 DEFAULT NULL);

PROCEDURE calcDeferments(p_event_no VARCHAR2,
                         p_from_date DATE DEFAULT NULL,
                         p_to_date DATE DEFAULT NULL,
                         p_scenario_id VARCHAR2 DEFAULT NULL);

PROCEDURE allocWellDeferredVolume(p_event_id VARCHAR2,
                                  p_from_date DATE,
                                  p_to_date DATE);

PROCEDURE reUseOverlappedRecords(p_event_no NUMBER, p_event_id VARCHAR2, p_daytime DATE, p_end_date DATE DEFAULT NULL, p_object_type VARCHAR2, p_deferment_type VARCHAR2, p_user VARCHAR2, p_last_updated_date DATE);

END  EcDp_Forecast_Event;