CREATE OR REPLACE PACKAGE ue_carrier IS

/******************************************************************************
** Package        :  ue_carrier, header part
**
** $Revision: 1.1 $
**
** Purpose        :  Includes user-exit functionality for carrier cooldown
**
** Documentation  :  www.energy-components.com
**
** Created  : 10.12.2012 Lee Wei Yap
**
** Modification history:
**
** Date        Whom     Change description:
** -------     ------   -----------------------------------------------
** 10.12.2012 leeeewei	Added initiateCarrierTank,initializeTemp,copyCooldown,deleteCarrierTank
*/

-- Public function and procedure declarations
FUNCTION isUnavailable (p_carrier_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;
FUNCTION getUnavailableReason (p_carrier_id VARCHAR2,p_daytime DATE) RETURN VARCHAR2;
FUNCTION getNextAvailDate(p_carrier_id VARCHAR2, p_daytime DATE) RETURN DATE;

END ue_carrier;