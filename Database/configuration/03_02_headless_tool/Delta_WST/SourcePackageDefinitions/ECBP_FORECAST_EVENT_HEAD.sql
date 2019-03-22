CREATE OR REPLACE PACKAGE EcBp_Forecast_Event IS

/****************************************************************
** Package        :  EcBp_Forecast_Event, header part
**
** $Revision: 1.1 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Forecast Event.
** Documentation  :  www.energy-components.com
**
** Created  : 19.05.2016 Suresh Kumar
**
** Modification history:
**
** Date       Whom      Change description:
** ------     --------  --------------------------------------
** 19-05-16   kumarsur  Initial Version
** 18-10-16   abdulmaw  ECPD-34304: Added function isAssociatedWithGroup to check which reason group associated with the selected reason code
** 21-12-18   leongwen  ECPD-56158: Implement the similar Deferment Calculation Logic from PD.0020 to Forecast Event PP.0047
**                                  Modified PROCEDURE checkIfEventOverlaps and FUNCTION getEventLossVolume
**                                  Added FUNCTION getEventLossRate, getEventLossNoChildEvent and getParentEventLossVolume
*****************************************************************/

PROCEDURE checkIfEventOverlaps(p_object_id VARCHAR2,
                               p_daytime DATE,
                               p_end_date DATE,
                               p_event_type VARCHAR2,
                               p_event_no NUMBER,
                               p_parent_event_no NUMBER DEFAULT 1);

PROCEDURE checkValidChildPeriod(p_parent_event_no NUMBER ,
                                p_daytime DATE);

FUNCTION getEventLossVolume (p_event_no NUMBER,
                             p_phase VARCHAR2,
                             p_object_id VARCHAR2 DEFAULT NULL,
                             p_child_count NUMBER DEFAULT 1)
RETURN NUMBER;

FUNCTION getPotentialRate(p_event_no NUMBER,
                          p_potential_attribute VARCHAR2)
RETURN NUMBER;

FUNCTION getParentEventLossRate (p_event_no NUMBER,
                                 p_event_attribute   VARCHAR2,
                                 p_deferment_type VARCHAR2)
RETURN NUMBER;

FUNCTION getEventLossRate (p_event_no        NUMBER,
                           p_event_attribute VARCHAR2)
RETURN NUMBER;

FUNCTION getEventLossNoChildEvent (p_event_no NUMBER,p_event_attribute VARCHAR2)
RETURN NUMBER;

PROCEDURE deleteChildEvent(p_event_no NUMBER);

FUNCTION countChildEvent(p_event_no NUMBER)
RETURN NUMBER;

PROCEDURE checkChildEndDate(p_parent_event_no NUMBER ,
                            p_daytime DATE);

FUNCTION isAssociatedWithGroup(p_reason_group VARCHAR2,
                               p_reason_code VARCHAR2)
RETURN VARCHAR2;

FUNCTION getParentEventLossVolume (p_event_no NUMBER,p_event_attribute   VARCHAR2,p_deferment_type VARCHAR2)
RETURN NUMBER;

END EcBp_Forecast_Event;