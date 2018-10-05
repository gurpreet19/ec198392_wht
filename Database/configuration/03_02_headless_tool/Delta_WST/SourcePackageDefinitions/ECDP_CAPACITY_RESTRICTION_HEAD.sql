CREATE OR REPLACE PACKAGE EcDp_Capacity_Restriction IS
/****************************************************************
** Package        :  EcDp_Capacity_Restriction; head part
**
** $Revision: 1.3 $
**
** Purpose        :  Handles capacity restriction operations
**
** Documentation  :  www.energy-components.com
**
** Created        :  09.04.2008 Arief Zaki
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
** 2008-04-09  zakiiari  ECPD-7663: Initial version
** 2012-06-13  sharawan  ECPD-19476: Added new functions getRateSchedVolPrLoc, getSubDayRateSchedVolPrLoc, getRestrictedCapacity,
**                       getSubDayRestrictedCapacity for GD.0062-Sub Daily Nomination Location Capacity.
** 2016-03-31  sharawan  ECPD-34226: Added procedure deleteDailyRestrictionFcst to handle deletion of daily data for period data deleted.
** 2017-03-16  sharawan  ECPD-44077: Added procedure deleteDailyRestriction to handle deletion of daily data for period data deleted.
**************************************************************************************************/

FUNCTION getCapacityUom(p_object_id    VARCHAR2,
						p_daytime      DATE,
						p_compare_oper VARCHAR2 DEFAULT '=') RETURN VARCHAR2;

FUNCTION getDesignCapacity(p_object_id    VARCHAR2,
						   p_daytime      DATE,
						   p_compare_oper VARCHAR2 DEFAULT '=') RETURN NUMBER;
FUNCTION getRateSchedVolPrLoc(p_location_id    VARCHAR2,
						   p_daytime                       DATE,
               p_rate_schedule                 VARCHAR2,
               p_class_name                    VARCHAR2) RETURN NUMBER;

FUNCTION getSubDayRateSchedVolPrLoc(p_location_id    VARCHAR2,
						   p_daytime                       DATE,
               p_rate_schedule                 VARCHAR2,
               p_class_name                    VARCHAR2) RETURN NUMBER;

FUNCTION getRestrictedCapacity(p_object_id    VARCHAR2,
						   p_daytime      DATE,
						   p_compare_oper VARCHAR2 DEFAULT '=') RETURN NUMBER;

FUNCTION getSubDayRestrictedCapacity(p_object_id    VARCHAR2,
						   p_daytime      DATE,
						   p_compare_oper VARCHAR2 DEFAULT '=') RETURN NUMBER;

PROCEDURE updateDailyRestriction(p_object_id      VARCHAR2,
								 p_old_start_date DATE,
								 p_new_start_date DATE,
								 p_old_end_date   DATE,
								 p_new_end_date   DATE);

PROCEDURE updateDailyRestrictionFcst(p_object_id      VARCHAR2,
									 p_forecast_id    VARCHAR2,
									 p_old_start_date DATE,
									 p_new_start_date DATE,
									 p_old_end_date   DATE,
									 p_new_end_date   DATE);

PROCEDURE deleteDailyRestriction(p_object_id      VARCHAR2,
									 p_old_start_date DATE,
									 p_old_end_date   DATE);

PROCEDURE deleteDailyRestrictionFcst(p_object_id      VARCHAR2,
									 p_forecast_id    VARCHAR2,
									 p_old_start_date DATE,
									 p_old_end_date   DATE);

PROCEDURE validateOverlappingPeriod(p_object_id      VARCHAR2,
									p_old_start_date DATE,
									p_new_start_date DATE,
									p_old_end_date   DATE,
									p_new_end_date   DATE);

PROCEDURE validateOverlappingPeriodFcst(p_object_id      VARCHAR2,
										p_forecast_id    VARCHAR2,
										p_old_start_date DATE,
										p_new_start_date DATE,
										p_old_end_date   DATE,
										p_new_end_date   DATE);

END EcDp_Capacity_Restriction;