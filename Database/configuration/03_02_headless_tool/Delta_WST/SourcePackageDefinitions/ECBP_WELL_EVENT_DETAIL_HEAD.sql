CREATE OR REPLACE PACKAGE EcBp_Well_Event_Detail IS

/****************************************************************
** Package        :  EcBp_Well_Event_Detail, header part
**
** $Revision: 1.3 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Event Injections Well Data.
** Documentation  :  www.energy-components.com
**
** Created  : 31.07.2007  Sarojini Rajaretnam
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
**16.11.07 	rajarsar  ECPD-6834: Added getLastClosingDaytime and getLastNotNullClosingReading
**25.01.08 	rajarsar  ECPD-6783: Updated Added getLastClosingDaytime and getLastNotNullClosingReading
**28.05.15  abdulmaw  ECPD-30716: Updated calcInjectionVolume and calcInjectionRate
*****************************************************************/

FUNCTION getDuration(
  p_object_id   well.object_id%TYPE,
  p_daytime DATE)
RETURN NUMBER;

FUNCTION calcInjectionRate(
  p_object_id   VARCHAR2,
  p_daytime DATE,
  p_rate_calc_method VARCHAR2,
  p_event_type VARCHAR2)
 RETURN NUMBER;

FUNCTION calcInjectionVolume(
  p_object_id        VARCHAR2,
	p_daytime DATE,
  p_rate_calc_method VARCHAR2,
  p_event_type VARCHAR2)
RETURN NUMBER;

FUNCTION getLastClosingDaytime(
  p_object_id   VARCHAR2,
  p_class_name VARCHAR2,
  p_daytime DATE)
RETURN DATE;

FUNCTION getLastNotNullClosingReading(
  p_object_id        VARCHAR2,
  p_class_name       VARCHAR2,
  p_daytime DATE)
RETURN NUMBER;



END  EcBp_Well_Event_Detail;