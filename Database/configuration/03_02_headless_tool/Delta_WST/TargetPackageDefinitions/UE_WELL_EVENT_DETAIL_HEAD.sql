CREATE OR REPLACE PACKAGE Ue_Well_Event_Detail IS
/****************************************************************
** Package        :  Ue_Well_Event_Detail
**
** $Revision: 1.2.46.1 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Event Well Injections Data.
**
** Documentation  :  www.energy-components.com
**
** Created  : 06.08.2007  Sarojini Rajaretnam
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
**28.05.15   abdulmaw  ECPD-31002: Updated calcInjectionRate
*****************************************************************/

FUNCTION calcInjectionRate(
  p_object_id   VARCHAR2,
  p_daytime DATE,
  p_event_type VARCHAR2)
 RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcInjectionRate, WNDS, WNPS, RNPS);


END Ue_Well_Event_Detail;