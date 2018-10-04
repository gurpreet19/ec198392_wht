CREATE OR REPLACE PACKAGE EcBp_Defer_Master_Event IS
/****************************************************************
** Package        :  EcBp_Defer_Master_Event
**
** $Revision: 1.2 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Daily Deferment.
**
** Documentation  :  www.energy-components.com
**
** Created  : 20.12.2006  Sarojini Rajaretnam
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 20.10.2011 abdulmaw ECPD-18546:Added function calcDefDailyActionVolume and procedure VerifyActionsDefDaily
*****************************************************************/

PROCEDURE verifyDefermentEvent(p_deferment_no NUMBER, p_incident_no NUMBER, p_daytime DATE, p_end_date DATE);

PROCEDURE verifyMasterDefermentEvent(p_incident_no NUMBER, p_end_date DATE);

PROCEDURE verifyDelMasterDefermentEvent(p_incident_no NUMBER);

PROCEDURE verifyDelDefermentEvent(p_deferment_event_no NUMBER);

FUNCTION getAsset(p_deferment_no	NUMBER)  RETURN VARCHAR2;

FUNCTION aggregrateDayDeferredVolume(p_deferment_no NUMBER, p_phase VARCHAR2)  RETURN NUMBER;

FUNCTION aggregrateMasterDeferredVolume(p_incident_no NUMBER, p_phase VARCHAR2)  RETURN NUMBER;

FUNCTION calcDefDailyActionVolume(p_incident_no NUMBER,p_daytime DATE,p_end_date DATE, p_phase VARCHAR2) RETURN NUMBER;

PROCEDURE VerifyActionsDefDaily(p_event_no NUMBER, p_daytime DATE, p_end_date DATE, p_action VARCHAR2);

END EcBp_Defer_Master_Event;