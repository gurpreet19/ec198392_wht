CREATE OR REPLACE PACKAGE EcDp_Well_Event_Detail IS

/****************************************************************
** Package        :  EcDp_Well_Event_Detail, header part
**
** $Revision: 1.2 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Event Injections Well Data.
** Documentation  :  www.energy-components.com
**
** Created  : 31.07.2007  Sarojini Rajaretnam
**
** Modification history:
**
** Version  Date       Whom      Change description:
** -------  --------   ----      --------------------------------------
**          13.02.08   rajarsar  Updated saveAndCalcInjRate
*****************************************************************/

PROCEDURE saveAndCalcInjRate(p_object_id VARCHAR2,
                             p_daytime DATE,
                             p_event_type VARCHAR2,
                             p_rate_calc_method VARCHAR2,
                             p_user VARCHAR2);


END  EcDp_Well_Event_Detail;