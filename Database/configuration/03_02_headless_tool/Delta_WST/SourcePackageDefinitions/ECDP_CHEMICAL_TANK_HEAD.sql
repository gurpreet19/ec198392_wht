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

--new added function
FUNCTION getClosingUnit(p_tank_object_id IN VARCHAR2, p_daytime IN DATE DEFAULT NULL) RETURN VARCHAR2;

FUNCTION getProductId(p_tank_object_id IN VARCHAR2, p_daytime IN DATE DEFAULT NULL) RETURN VARCHAR2;

FUNCTION getProductCode(p_tank_object_id IN VARCHAR2, p_daytime IN DATE DEFAULT NULL) RETURN VARCHAR2;

FUNCTION getProductName(p_tank_object_id IN VARCHAR2, p_daytime IN DATE DEFAULT NULL) RETURN VARCHAR2;

FUNCTION getClosingVol(p_tank_object_id IN VARCHAR2, p_daytime IN DATE, p_uom IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;

FUNCTION getRealClosingVol(p_tank_object_id IN VARCHAR2, p_daytime IN DATE, p_uom IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;

FUNCTION getPrevConnectionDate(p_tank_object_id IN VARCHAR2, p_daytime IN DATE) RETURN DATE;

FUNCTION getPrevMeasDate(p_tank_object_id IN VARCHAR2, p_daytime IN DATE ) RETURN DATE;

FUNCTION getOpeningVol(p_tank_object_id IN VARCHAR2, p_daytime IN DATE, p_uom IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;

FUNCTION getFilledVol(p_tank_object_id IN VARCHAR2, p_daytime IN DATE, p_uom IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;

FUNCTION getConsumedVol(p_tank_object_id IN VARCHAR2, p_daytime IN DATE, p_uom IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;

FUNCTION getDailyConsumptionRate(p_tank_object_id IN VARCHAR2, p_daytime IN DATE DEFAULT NULL) RETURN VARCHAR2;

PROCEDURE biuSetEndDate(p_object_id VARCHAR2, p_old_daytime DATE, p_daytime DATE, p_end_date DATE, p_chem_product_id VARCHAR2);

END;