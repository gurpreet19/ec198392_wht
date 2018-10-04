CREATE OR REPLACE PACKAGE Ue_Forecast_Event IS
/******************************************************************************
** Package        :  Ue_Forecast_Event, head part
**
** $Revision:
**
** Purpose        :
**
** Documentation  :
**
** Created        :  19.05.2016 Suresh Kumar
**
** Modification history:
**
** Date        Whom        Change description:
** ------      --------    -----------------------------------------------------------------------------------------------
** 19-05-16    kumarsur    Initial Version
** 18-07-16    abdulmaw    ECPD-37247: Added procedure calcDeferments
** 18-10-16    abdulmaw    ECPD-34304: Added function isAssociatedWithGroup
********************************************************************/

PROCEDURE sumFromWells(
   p_event_no NUMBER,
   p_user_name VARCHAR2);

FUNCTION getEventLossVolume (
   p_event_no NUMBER,
   p_event_attribute VARCHAR2,
   p_object_id VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION getPotentialRate(
   p_event_no           NUMBER,
   p_potential_attribute VARCHAR2)
RETURN NUMBER;

PROCEDURE insertWells(
   p_group_event_no NUMBER,
   p_forecast_id VARCHAR2,
   p_scenario_id VARCHAR2,
   p_event_type VARCHAR2,
   p_object_typ VARCHAR2,
   p_object_id VARCHAR2,
   p_daytime DATE,
   p_end_date DATE DEFAULT NULL,
   p_username VARCHAR2,
   ue_flag OUT CHAR);

FUNCTION isAssociatedWithGroup(
   p_reason_group VARCHAR2,
   p_reason_code VARCHAR2)
RETURN VARCHAR2;

PROCEDURE calcDeferments(
   p_event_no VARCHAR2,
   p_from_date DATE DEFAULT NULL,
   p_to_date DATE DEFAULT NULL,
   ue_flag OUT CHAR);

END Ue_Forecast_Event;