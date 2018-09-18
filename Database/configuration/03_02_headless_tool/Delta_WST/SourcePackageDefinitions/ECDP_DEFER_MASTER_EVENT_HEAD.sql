CREATE OR REPLACE PACKAGE EcDp_Defer_Master_Event IS
/****************************************************************
** Package        :  EcDp_Defer_Master_Event
**
** $Revision: 1.1 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Daily Deferment.
**
** Documentation  :  www.energy-components.com
**
** Created  : 26.12.2006  Sarojini Rajaretnam
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
**
*****************************************************************/

PROCEDURE createSummaryRecords(p_defer_level_object_id VARCHAR2, p_deferment_event_no NUMBER);

FUNCTION calcEventDuration(p_event_start_daytime DATE, p_event_end_daytime DATE, p_day DATE) RETURN NUMBER;

FUNCTION calcDuration(p_deferment_no NUMBER,p_summary_daytime DATE) RETURN NUMBER;

PROCEDURE verifyEvents(p_deferment_event_no NUMBER);

PROCEDURE approveEvents(p_incident_no NUMBER);


END EcDp_Defer_Master_Event;