CREATE OR REPLACE PACKAGE EcDp_Carrier IS
/**************************************************************************************************
** Package  :  EcDp_Carrier
**
** $Revision: 1.1.2.1 $
**
** Purpose  :  This package handles the carrier availability
**
** Created:     03.01.2013 Lee Wei Yap
**
** Modification history:
**
** Date:        Whom:       Rev.  Change description:
** ----------  	-----       ----  ------------------------------------------------------------------------
**
**************************************************************************************************/
FUNCTION isUnavailable(p_carrier_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;
FUNCTION getUnavailableReason(p_carrier_id VARCHAR2, p_daytime DATE)RETURN VARCHAR2;
FUNCTION getNextAvailDate(p_carrier_id VARCHAR2, p_daytime DATE)RETURN DATE;

END EcDp_Carrier;