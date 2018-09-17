CREATE OR REPLACE PACKAGE EcDp_Well_Event IS
/**************************************************************
** Package:    EcDp_Well_Event, header part
**
** $Revision: 1.12.24.2 $
**
** Filename:   EcDp_Well_Event_head.sql
**
** Part of :   EC Kernel
**
** Purpose:
**
** General Logic:
**
** Document References:
**
**
** Created:   	15.12.2005  Roar Vika
**
**
** Modification history:
**
**
** Date:       Whom:         Change description:
** --------    -----         --------------------------------------------
** 27.03.2006  Roar Vika     TI 3299: Added new functions getLastPwelEstimateDaytime and
**                           getNextPwelEstimateDaytime. Removed validate_estimate_dates
** 02.08.2007  kaurrnar      ECPD5562: Added insertEventDetail and deleteEventDetail procedure
** 08.08.2007  chongviv      ECPD-6170: Updated both approve/verify period totalizer procedures
** 09.08.2007  rajarsar      ECPD5562: Updated insertEventDetail
** 24.01.2008  oonnnng		 ECPD-6774: Added acceptEventAlloc, acceptEventNoAlloc, and rejectEvent procedures.
** 28.01.2008  rajarsar		 ECPD-6783: Added updateRateSource and getChildClassName, updated insertEventDetail and deleteEventDetail
** 14.01.2015  dhavaalo		 ECPD-28604:Added new functions getLastWellEventSingleDaytime() and getNextWellEventSingleDaytime()
** 28.05.2015  abdulmaw    	 ECPD-31002: Updated getChildClassName
**************************************************************/

FUNCTION getLastPwelEstimateDaytime(
   p_object_id  well.object_id%TYPE,
   p_daytime    DATE)
RETURN DATE;
PRAGMA RESTRICT_REFERENCES (getLastPwelEstimateDaytime, WNDS, WNPS, RNPS);

FUNCTION getNextPwelEstimateDaytime(
   p_object_id  well.object_id%TYPE,
   p_daytime    DATE)
RETURN DATE;
PRAGMA RESTRICT_REFERENCES (getNextPwelEstimateDaytime, WNDS, WNPS, RNPS);

PROCEDURE validateOverlappingPeriod (
   p_object_id       IN well_period_totalizer.object_id%TYPE,
   p_class_name      IN well_period_totalizer.class_name%TYPE,
   p_opening_daytime IN well_period_totalizer.daytime%TYPE,
   p_closing_daytime IN well_period_totalizer.end_date%TYPE)
;
PRAGMA RESTRICT_REFERENCES (validateOverlappingPeriod, WNDS, WNPS, RNPS);

FUNCTION getLastClosingDaytime (
   p_object_id       IN well_period_totalizer.object_id%TYPE,
   p_class_name      IN well_period_totalizer.class_name%TYPE,
   p_to_daytime      IN DATE)
RETURN DATE;
PRAGMA RESTRICT_REFERENCES (getLastClosingDaytime, WNDS, WNPS, RNPS);

PROCEDURE approvePeriodTotalizer(p_object_id well.object_id%TYPE,
                         p_class_name VARCHAR2,
                         p_daytime DATE,
                         p_end_date DATE,
                         p_user VARCHAR2);

PROCEDURE verifyPeriodTotalizer(p_object_id well.object_id%TYPE,
                         p_class_name VARCHAR2,
                         p_daytime DATE,
                         p_end_date DATE,
                         p_user VARCHAR2);

PROCEDURE validatePeriodTotalizer(p_object_id well.object_id%TYPE,
                         p_class_name VARCHAR2,
                         p_daytime DATE,
                         p_end_date DATE);

PROCEDURE validateTotalizerMax(p_object_id well.object_id%TYPE,
                         p_daytime DATE,
                         p_overwrite NUMBER,
                         p_closing NUMBER);

PROCEDURE insertEventDetail(p_object_id well.object_id%TYPE,
                            p_daytime DATE,
                            p_event_type VARCHAR2,
                            p_rate_calc_method VARCHAR2,
                            p_user VARCHAR2,
                            p_operation VARCHAR2
                            );

PROCEDURE deleteEventDetail(p_object_id well.object_id%TYPE,
                            p_daytime DATE,
                            p_event_type VARCHAR2
							);

PROCEDURE acceptEventAlloc(p_object_id well_event.object_id%TYPE,
                         p_daytime DATE,
                         p_event_type well_event.event_type%TYPE,
						 p_summer_time VARCHAR2,
						 p_user_id VARCHAR2 DEFAULT NULL);

PROCEDURE acceptEventNoAlloc(p_object_id well_event.object_id%TYPE,
 	                     p_daytime DATE,
                         p_event_type well_event.event_type%TYPE,
						 p_summer_time VARCHAR2,
						 p_user_id VARCHAR2 DEFAULT NULL);

PROCEDURE rejectEvent(p_object_id well_event.object_id%TYPE,
 	                     p_daytime DATE,
                         p_event_type well_event.event_type%TYPE,
						 p_summer_time VARCHAR2,
						 p_user_id VARCHAR2 DEFAULT NULL);


PROCEDURE updateRateSource(p_object_id well.object_id%TYPE,
                           p_daytime DATE,
                           p_event_type VARCHAR2,
                           p_o_avg_inj_rate NUMBER,p_n_avg_inj_rate NUMBER,
						   p_summer_time VARCHAR2,
                           p_user VARCHAR2,
                           p_operation VARCHAR2
                           );

FUNCTION getLastRateCalcMethod (
   p_object_id       well.object_id%TYPE,
   p_daytime         DATE,
   p_event_type      VARCHAR2)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getLastRateCalcMethod, WNDS, WNPS, RNPS);

FUNCTION getChildClassName(p_object_id VARCHAR2, p_daytime DATE, p_event_type VARCHAR2) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getChildClassName, WNDS, WNPS, RNPS);

FUNCTION getLastWellEventSingleDaytime(
   p_object_id  well.object_id%TYPE,
   p_daytime    DATE)
RETURN DATE;
PRAGMA RESTRICT_REFERENCES (getLastWellEventSingleDaytime, WNDS, WNPS, RNPS);

FUNCTION getNextWellEventSingleDaytime(
   p_object_id  well.object_id%TYPE,
   p_daytime    DATE)
RETURN DATE;
PRAGMA RESTRICT_REFERENCES (getNextWellEventSingleDaytime, WNDS, WNPS, RNPS);

END;