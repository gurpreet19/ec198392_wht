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

FUNCTION getChemVolPpm(p_object_id VARCHAR2, p_daytime DATE)  RETURN NUMBER;

FUNCTION calcRecomVolume(p_object_id VARCHAR2, p_daytime DATE)  RETURN NUMBER;

FUNCTION getLastNotNullInjVolDate(p_object_id VARCHAR2, p_daytime DATE)  RETURN DATE;

END;