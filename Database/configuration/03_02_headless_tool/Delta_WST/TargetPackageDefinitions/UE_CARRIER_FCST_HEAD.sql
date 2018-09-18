CREATE OR REPLACE PACKAGE ue_carrier_fcst IS

/******************************************************************************
** Package        :  ue_carrier_fcst, header part
**
** $Revision: 1.1.2.1 $
**
** Purpose        :  Includes user-exit functionality for carrier cooldown
**
** Documentation  :  www.energy-components.com
**
** Created  : 31.01.2013 hassakha
**
** Modification history:
**
** Date:        Whom:       Rev.  Change description:
** ----------  	-----       ----  ------------------------------------------------------------------------
*/

-- Public function and procedure declarations
FUNCTION isUnavailable (p_carrier_id VARCHAR2, p_daytime DATE, p_forecast_id VARCHAR2) RETURN VARCHAR2;
FUNCTION getUnavailableReason (p_carrier_id VARCHAR2,p_daytime DATE,p_forecast_id VARCHAR2) RETURN VARCHAR2;
FUNCTION getNextAvailDate(p_carrier_id VARCHAR2, p_daytime DATE, p_forecast_id VARCHAR2) RETURN DATE;

END ue_carrier_fcst;