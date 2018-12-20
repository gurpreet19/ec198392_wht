CREATE OR REPLACE PACKAGE EcDp_Chemical_Product IS
/***********************************************************************************************************************************************
** Package  :  EcDp_Chemical_Product, header part
**
** $Revision: 1.12 $
**
** Purpose  :  Business functions related to chemical products
**
** Created  :  03.03.2004 Frode Barstad
**
** How-To   :  Se www.energy-components.com for full version
**
** Modification history:
**
** Date:      Revision: Whom:  Change description:
** ---------- --------- -----  --------------------------------------------
** 03.04.2004 1.0       FBa    Initial version
** 03.02.2005 1.1       Darren Added new procedure biuSetEndDate
** 22.11.2005 1.1	Rob    Added new function get_chem_dosage
** 28.08.2006 1.18	    rajarsar Added new function getChemVolPpm
** 23.02.2007 1.19	    rajarsar Added new functions: calcRecomVolume, getLastNotNullInjVolDate, getAssetVolume
** 04.02.2010           farhaann ECPD-13601: Removed get_chem_dosage, getChemVolPpm, calcRecomVolume and getLastNotNullInjVolDate to Ecbp_Chem_Inj_Point package.
***********************************************************************************************************************************************/

FUNCTION getDefaultUOM(p_product_object_id IN VARCHAR2, p_daytime IN DATE DEFAULT NULL) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(getDefaultUOM, WNDS, WNPS, RNPS);

FUNCTION getProductName(p_product_object_id IN VARCHAR2, p_daytime IN DATE DEFAULT NULL) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(getProductName, WNDS, WNPS, RNPS);

FUNCTION getProductCode(p_product_object_id IN VARCHAR2, p_daytime IN DATE DEFAULT NULL) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(getProductCode, WNDS, WNPS, RNPS);

FUNCTION getClosingVol(p_product_object_id IN VARCHAR2, p_daytime IN DATE, p_uom IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getClosingVol, WNDS, WNPS, RNPS);

FUNCTION getOpeningVol(p_product_object_id IN VARCHAR2, p_daytime IN DATE, p_uom IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getOpeningVol, WNDS, WNPS, RNPS);

FUNCTION getFilledVol(p_product_object_id IN VARCHAR2, p_daytime IN DATE, p_uom IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getFilledVol, WNDS, WNPS, RNPS);

FUNCTION getConsumedVol(p_product_object_id IN VARCHAR2, p_daytime IN DATE, p_uom IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getConsumedVol, WNDS, WNPS, RNPS);

PROCEDURE biuSetEndDate(p_asset_object_id VARCHAR2, p_start_date DATE, p_end_date DATE);

FUNCTION getAssetVolume(p_asset VARCHAR2, p_asset_object_id VARCHAR2, p_rec_dosage_method VARCHAR2, p_daytime DATE)  RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getAssetVolume, WNDS, WNPS, RNPS);

END;