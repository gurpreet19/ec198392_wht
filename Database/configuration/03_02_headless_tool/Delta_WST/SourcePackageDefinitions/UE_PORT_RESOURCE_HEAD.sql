CREATE OR REPLACE PACKAGE UE_PORT_RESOURCE IS

/******************************************************************************
** Package        :  UE_PORT_RESOURCE, header part
**
** $Revision      :  1.1 $
**
** Purpose        :  Includes user-exit functionality for Port Resource Usage screens
**
** Documentation  :  www.energy-components.com
**
** Created        :  06.6.2017 Swinjal Asare
**
** Modification history:
**
** Date        Whom       Change description:
** -------     ------     -----------------------------------------------
** 06-06-2017  asareswi	  ECPD-41986 : Initial Version
** 19-06-2017  farhaann   ECPD-41986 : Added getPortResourceName
** 22-06-2017  sharawan   ECPD-41986 : Added getPlannedEndDate function to calculate End Date
** 22-06-2017  farhaann   ECPD-41986 : Added getAvailableResource, getLastUsageCargo, getLastUsageStartTime, getLastUsageEndTime,
**                                     getNextUsageCargo, getNextUsageStartTime,getNextUsageEndTime
** 10-07-2017  asareswi   ECPD-47288 : Added cargo_no parameter in getPlannedStartTime, getPlannedDuration procedure. Added function getLastTimesheetEntry.
** 18-07-2017  asareswi   ECPD-47474 : Modified getPlannedEndDate input parameters.
** 28-09-2017  baratmah   ECPD-48426 : Added instantiatePortResTemplate.
** 12-10-2017  asareswi   ECPD-49156 : Added procedure updatePortResUsage to update port resource usage details when lifting start date, ETA, ETD is updated in cargo information screen.
*********************************************************************************************/


  -- Public function and procedure declarations
FUNCTION getPlannedStartTime(p_timeline_code VARCHAR2, p_cargo_no NUMBER, p_parcel_no NUMBER, p_start_time DATE DEFAULT NULL) RETURN DATE;

FUNCTION getPlannedDuration(p_duration_code VARCHAR2, p_cargo_no NUMBER, p_parcel_no NUMBER, p_duration NUMBER DEFAULT NULL) RETURN NUMBER;

FUNCTION getPlannedEndDate(p_cargo_no NUMBER, p_parcel_no NUMBER, p_timeline_code VARCHAR2, p_daytime DATE, p_duration_code VARCHAR2, p_duration NUMBER) RETURN DATE;

FUNCTION getPortResourceName(p_class_name VARCHAR2, p_object_id VARCHAR2) RETURN VARCHAR2;

FUNCTION getAvailableResource(p_object_id VARCHAR2, p_cargo_no NUMBER, p_daytime DATE, p_end_date DATE) RETURN VARCHAR2;

FUNCTION getLastUsageCargo(p_object_id VARCHAR2, p_daytime DATE, p_cargo_no VARCHAR2) RETURN VARCHAR2;

FUNCTION getLastUsageStartTime(p_object_id VARCHAR2, p_daytime DATE, p_cargo_no VARCHAR2) RETURN DATE;

FUNCTION getLastUsageEndTime(p_object_id VARCHAR2, p_daytime DATE, p_cargo_no VARCHAR2) RETURN DATE;

FUNCTION getNextUsageCargo(p_object_id VARCHAR2, p_daytime DATE, p_end_date DATE, p_cargo_no NUMBER) RETURN VARCHAR2;

FUNCTION getNextUsageStartTime(p_object_id VARCHAR2, p_daytime DATE, p_end_date DATE, p_cargo_no NUMBER) RETURN DATE;

FUNCTION getNextUsageEndTime(p_object_id VARCHAR2, p_daytime DATE, p_end_date DATE, p_cargo_no NUMBER) RETURN DATE;

FUNCTION getLastTimesheetEntry(p_timeline_code VARCHAR2, p_cargo_no NUMBER, p_product_id VARCHAR2, p_lifting_event VARCHAR2, p_run_no NUMBER DEFAULT 1) RETURN DATE;

PROCEDURE instantiatePortResTemplate(p_cargo_no NUMBER, p_user VARCHAR2);

PROCEDURE updatePortResUsage(p_cargo_no NUMBER, p_parcel_no NUMBER DEFAULT NULL);

END UE_PORT_RESOURCE;