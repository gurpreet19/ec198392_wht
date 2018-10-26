CREATE OR REPLACE PACKAGE ue_Storage_Balance IS
/****************************************************************
** Package        :  ue_Storage_Balance; head part
**
** $Revision: 1.3 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  16.04.2007	Kari Sandvik
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- -------------------------------------------
** 18.02.2013  sharawan     ECPD-20075: Add new function getForecastCargo, getCargoParcel to populate the tooltip in the graph component.
** 22.01.2015  farhaann     ECPD-28605: Add new function getStorageDipDate to get the latest tank dip date
** 23.03.2017  asareswi     ECPD-40299: Added new parameter in getStorageDipDate function.
*****************************************************************/

FUNCTION getStorageDip(p_storage_id VARCHAR2, p_daytime DATE, p_condition VARCHAR2, p_group VARCHAR2, p_type VARCHAR, p_dip NUMBER) RETURN NUMBER;

FUNCTION getMaxVolLevel(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

FUNCTION getMinVolLevel(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

FUNCTION getMinSafeLimitVolLevel(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

FUNCTION getMaxSafeLimitVolLevel(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

FUNCTION getForecastCargo(p_storage_id VARCHAR2, p_forecast_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;

FUNCTION getCargoParcel(p_storage_id VARCHAR2, p_forecast_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;

FUNCTION getStorageDipDate(p_startdate DATE, p_event_type VARCHAR2, p_last_dip DATE, p_daytime DATE, p_storage_id VARCHAR2) RETURN DATE;

END ue_Storage_Balance;