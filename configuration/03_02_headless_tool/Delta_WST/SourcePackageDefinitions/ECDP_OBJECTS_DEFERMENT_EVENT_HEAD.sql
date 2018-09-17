CREATE OR REPLACE PACKAGE EcDp_Objects_Deferment_Event IS
/***************************************************************
** Package:                EcDp_Objects_Deferment_Event
**
** Revision :              $Revision: 1.5 $
**
** Purpose:
**
** Documentation:          www.energy-components.no
**
** Modification history:
**
** Date:    Whom:      Change description:
** -------- -----      --------------------------------------------
** 20050310 SRA        Initial version based onf EcDp_Objects_Event
** 20050415 kaurrnar   Added new function calcWellLossDay
** 20050603 ROV        Renamed calcWellLossDay -> calcWellProdLossDay
** 20070906 rajarsar   ECPD-6264 Added new function calcWellProdLossDayMass
** 20080317 ismaiime   ECPD-7810 Added p_object_id as parameter in calcEventDurationDay
***************************************************************/

PROCEDURE Create_Objects_Event_Detail (p_event_id VARCHAR2,
                                       p_group_type VARCHAR2);

PROCEDURE Aggregate_Volume_To_Parent(p_event_id VARCHAR2,
                                     p_desimal NUMBER DEFAULT 0);

PROCEDURE Copy_Deferred_To_Idle(p_from_event_type VARCHAR2,
                                p_to_event_type VARCHAR2,
                                p_daytime DATE);

PROCEDURE Create_And_Link_Idle_Event(p_from_event_type VARCHAR2,
                                     p_to_event_type VARCHAR2,
                                     p_event_id VARCHAR2);

FUNCTION calcLossByDay(p_event_id   VARCHAR2,
                       p_daytime    DATE,
                       p_phase      VARCHAR2,
                       p_prod_inj   VARCHAR2) RETURN NUMBER;

FUNCTION calcLossByDayFromChildren(p_event_id VARCHAR2,
                                   p_daytime  DATE,
                                   p_phase    VARCHAR2,
                                   p_prod_inj   VARCHAR2) RETURN NUMBER;

FUNCTION calcEventDurationDay(p_event_start_daytime DATE,
                              p_event_end_daytime   DATE,
                              p_day                 DATE,
                              p_object_id	    VARCHAR2) RETURN NUMBER;


FUNCTION getProductionDayOffset(
                          p_event_id    VARCHAR2,
                          p_event_type  VARCHAR2,
                          p_object_id   VARCHAR2,
                          p_object_type VARCHAR2,
                          p_daytime     DATE)
RETURN NUMBER;


FUNCTION getProductionDay(
                          p_event_id    VARCHAR2,
                          p_event_type  VARCHAR2,
                          p_object_id   VARCHAR2,
                          p_object_type VARCHAR2,
                          p_daytime     DATE)
RETURN DATE;

FUNCTION calcWellProdLossDay(
			p_object_id   VARCHAR2,
			p_daytime    DATE,
			p_phase      VARCHAR2
			)
RETURN NUMBER;

FUNCTION calcWellProdLossDayMass(
			p_object_id   VARCHAR2,
			p_daytime    DATE,
			p_phase      VARCHAR2
			)
RETURN NUMBER;


TYPE t_event_id IS TABLE OF Objects_Deferment_Event.event_id%TYPE INDEX BY BINARY_INTEGER;
TYPE t_daytime IS TABLE OF Objects_Deferment_Event.daytime%TYPE INDEX BY BINARY_INTEGER;
TYPE t_end_date IS TABLE OF Objects_Deferment_Event.end_date%TYPE INDEX BY BINARY_INTEGER;
TYPE t_object_id IS TABLE OF Objects_Deferment_Event.object_id%TYPE INDEX BY BINARY_INTEGER;
TYPE t_object_type IS TABLE OF Objects_Deferment_Event.object_type%TYPE INDEX BY BINARY_INTEGER;
TYPE t_parent_event_id IS TABLE OF Objects_Deferment_Event.parent_event_id%TYPE INDEX BY BINARY_INTEGER;

v_event_ids t_event_id;
v_daytimes t_daytime;
v_end_dates t_end_date;
v_object_ids t_object_id;
v_object_types t_object_type;
v_parent_event_ids t_parent_event_id;
v_Num_Rows BINARY_INTEGER :=0;

END;