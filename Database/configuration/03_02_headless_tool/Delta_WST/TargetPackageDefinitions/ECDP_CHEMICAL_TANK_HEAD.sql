CREATE OR REPLACE PACKAGE EcDp_Chemical_Tank IS
/***********************************************************************************************************************************************
** Package  :  EcDp_Chemical_Tank, header part
**
** $Revision: 1.13 $
**
** Purpose  :  Business functions related to chemical tanks
**
** Created  :  03.03.2004 Frode Barstad
**
** How-To   :  Se www.energy-components.com for full version
**
** Modification history:
**
** Date:      Revision: Whom:     Change description:
** ---------- --------- -----     --------------------------------------------
** 03.04.2004 1.0       FBa       Initial version
** 26.10.2004 1.1       Chongjer  Added two new functions - getclosingunit and getdailyconsumptionrate, removed p_uom in getconsumedvol
** 02.02.2005 1.2       Darren    Added new procedure - biuSetEndDate
** 13.06.2005 1.3       Chongjer  Added parameter to procedure - biuSetEndDate
** 24.10.2005 1.4 	Rahmanaz  Added parameter to procedure - biuSetEndDate
***********************************************************************************************************************************************/

FUNCTION getDefaultUOM(p_tank_object_id IN VARCHAR2, p_daytime IN DATE DEFAULT NULL) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(getDefaultUOM, WNDS, WNPS, RNPS);

--new added function
FUNCTION getClosingUnit(p_tank_object_id IN VARCHAR2, p_daytime IN DATE DEFAULT NULL) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(getClosingUnit, WNDS, WNPS, RNPS);

FUNCTION getProductId(p_tank_object_id IN VARCHAR2, p_daytime IN DATE DEFAULT NULL) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(getProductId, WNDS, WNPS, RNPS);

FUNCTION getProductCode(p_tank_object_id IN VARCHAR2, p_daytime IN DATE DEFAULT NULL) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(getProductCode, WNDS, WNPS, RNPS);

FUNCTION getProductName(p_tank_object_id IN VARCHAR2, p_daytime IN DATE DEFAULT NULL) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(getProductName, WNDS, WNPS, RNPS);

FUNCTION getClosingVol(p_tank_object_id IN VARCHAR2, p_daytime IN DATE, p_uom IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getClosingVol, WNDS, WNPS, RNPS);

FUNCTION getRealClosingVol(p_tank_object_id IN VARCHAR2, p_daytime IN DATE, p_uom IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getRealClosingVol, WNDS, WNPS, RNPS);

FUNCTION getPrevConnectionDate(p_tank_object_id IN VARCHAR2, p_daytime IN DATE) RETURN DATE;
PRAGMA RESTRICT_REFERENCES(getPrevConnectionDate, WNDS, WNPS, RNPS);

FUNCTION getPrevMeasDate(p_tank_object_id IN VARCHAR2, p_daytime IN DATE ) RETURN DATE;
PRAGMA RESTRICT_REFERENCES(getPrevMeasDate, WNDS, WNPS, RNPS);

FUNCTION getOpeningVol(p_tank_object_id IN VARCHAR2, p_daytime IN DATE, p_uom IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getOpeningVol, WNDS, WNPS, RNPS);

FUNCTION getFilledVol(p_tank_object_id IN VARCHAR2, p_daytime IN DATE, p_uom IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getFilledVol, WNDS, WNPS, RNPS);

FUNCTION getConsumedVol(p_tank_object_id IN VARCHAR2, p_daytime IN DATE, p_uom IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getConsumedVol, WNDS, WNPS, RNPS);

FUNCTION getDailyConsumptionRate(p_tank_object_id IN VARCHAR2, p_daytime IN DATE DEFAULT NULL) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(getDailyConsumptionRate, WNDS, WNPS, RNPS);

PROCEDURE biuSetEndDate(p_object_id VARCHAR2, p_old_daytime DATE, p_daytime DATE, p_end_date DATE, p_chem_product_id VARCHAR2);

END;