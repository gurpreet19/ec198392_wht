CREATE OR REPLACE PACKAGE EcDp_Stream_Event IS

/****************************************************************
** Package        :  EcDp_Stream_Event
**
** $Revision: 1.7 $
**
** Purpose        :  This package is responsible for stream event data access
**
** Documentation  :  www.energy-components.com
**
** Created  : 26.02.2007 Arief Zaki
**
** Modification history:
**
** Date        Whom      Change description:
** ----------  --------  --------------------------------------
** 26.02.2007  zakiiari    First version
** 08.08.2008  chongviv	   ECPD-6170: Added both approve/verify period totalizer procedures
*****************************************************************/

PROCEDURE validateOverlappingPeriod (
   p_object_id       IN strm_event.object_id%TYPE,
   p_event_type      IN strm_event.event_type%TYPE,
   p_opening_daytime IN strm_event.daytime%TYPE,
   p_closing_daytime IN strm_event.end_date%TYPE)
;
PRAGMA RESTRICT_REFERENCES (validateOverlappingPeriod, WNDS, WNPS, RNPS);

FUNCTION getLastClosingDaytime (
   p_object_id       IN strm_event.object_id%TYPE,
   p_event_type      IN strm_event.event_type%TYPE,
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

FUNCTION getOverrideValue(p_object_id strm_event.object_id%TYPE,
                         p_att_name VARCHAR2,
                         p_event_type VARCHAR2,
                         p_end_date DATE)
RETURN NUMBER;

END EcDp_Stream_Event;