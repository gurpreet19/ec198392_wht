CREATE OR REPLACE PACKAGE ue_Storage_Balance IS
/****************************************************************
** Package        :  ue_Storage_Balance; head part
**
** $Revision: 1.2.58.2 $
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
** 08.03.2013  sharawan     ECPD-23324: Add new function getForecastCargo, getCargoParcel to populate the tooltip in the graph component.
** 22.01.2015  farhaann     ECPD-29806: Add new function getStorageDipDate to get the latest tank dip date
*****************************************************************/

FUNCTION getStorageDip(p_storage_id VARCHAR2, p_daytime DATE, p_condition VARCHAR2, p_group VARCHAR2, p_type VARCHAR, p_dip NUMBER) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getStorageDip, WNDS, WNPS, RNPS);

FUNCTION getMaxVolLevel(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getMaxVolLevel, WNDS, WNPS, RNPS);

FUNCTION getMinVolLevel(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getMinVolLevel, WNDS, WNPS, RNPS);

FUNCTION getMinSafeLimitVolLevel(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getMinSafeLimitVolLevel, WNDS, WNPS, RNPS);

FUNCTION getMaxSafeLimitVolLevel(p_storage_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getMaxSafeLimitVolLevel, WNDS, WNPS, RNPS);

FUNCTION getForecastCargo(p_storage_id VARCHAR2, p_forecast_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;

FUNCTION getCargoParcel(p_storage_id VARCHAR2, p_forecast_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;

FUNCTION getStorageDipDate(p_daytime DATE, p_event_type VARCHAR2, p_last_dip DATE) RETURN DATE;

END ue_Storage_Balance;