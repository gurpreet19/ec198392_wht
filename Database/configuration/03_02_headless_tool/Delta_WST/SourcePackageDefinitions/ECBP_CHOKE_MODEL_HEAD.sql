CREATE OR REPLACE PACKAGE EcBp_Choke_Model IS
/***********************************************************************************************************************************************
** Package  :  EcBp_Choke_Model, header part
**
** $Revision: 1.5 $
**
** Purpose  :  Business functions related to chemical injection point
**
** Created  :  09.11.2010 Sarojini Rajaretnam
**
** How-To   :  Se www.energy-components.com for full version
**
** Modification history:
**
** Date:      Revision: Whom:  Change description:
** ---------- --------- -----  --------------------------------------------
** 09.11.2010 1.0       rajarsar    Initial version
** 24.01.2011 1.0       rajarsar    ECPD-16192:Added function calcTotalLip
** 07.02.2011 2.0       rajarsar    ECPD-16192:Added function calcTotalEventLoss
** 12.12.2011 3.0       rajarsar    ECPD-18891:Removed function calcTotalEventLoss
***********************************************************************************************************************************************/

FUNCTION calcTotalMppLip(p_object_id VARCHAR2, p_daytime DATE, p_class_name VARCHAR2, p_condition VARCHAR2 DEFAULT NULL)  RETURN NUMBER;

FUNCTION calcTotalLip(p_object_id VARCHAR2, p_daytime DATE)  RETURN NUMBER;

FUNCTION convertToStableLiquid(p_object_id VARCHAR2, p_daytime DATE, p_value NUMBER)  RETURN NUMBER;

FUNCTION convertToUnStableLiquid(p_object_id VARCHAR2, p_daytime DATE, p_value NUMBER)  RETURN NUMBER;

FUNCTION convertTokboe(p_object_id VARCHAR2, p_daytime DATE, p_value NUMBER)  RETURN NUMBER;

END EcBp_Choke_Model;