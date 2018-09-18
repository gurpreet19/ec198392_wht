CREATE OR REPLACE PACKAGE EcBp_Chem_Inj_Point IS
/***********************************************************************************************************************************************
** Package  :  EcBp_Chem_Inj_Point, header part
**
** $Revision: 1.3 $
**
** Purpose  :  Business functions related to chemical injection point
**
** Created  :  20.01.2010 Annida Farhana
**
** How-To   :  Se www.energy-components.com for full version
**
** Modification history:
**
** Date:      Revision: Whom:  Change description:
** ---------- --------- -----  --------------------------------------------
** 20.01.2010 1.0       farhaann    Initial version

***********************************************************************************************************************************************/

FUNCTION getChemDosage(p_object_id VARCHAR2, p_daytime DATE)  RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getChemDosage, WNDS, WNPS, RNPS);

FUNCTION getChemVolPpm(p_object_id VARCHAR2, p_daytime DATE)  RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getChemVolPpm, WNDS, WNPS, RNPS);

FUNCTION calcRecomVolume(p_object_id VARCHAR2, p_daytime DATE)  RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(calcRecomVolume, WNDS, WNPS, RNPS);

FUNCTION getLastNotNullInjVolDate(p_object_id VARCHAR2, p_daytime DATE)  RETURN DATE;
PRAGMA RESTRICT_REFERENCES (getLastNotNullInjVolDate, WNDS, WNPS, RNPS);

END;