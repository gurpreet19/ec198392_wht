CREATE OR REPLACE PACKAGE UE_CT_WELL_DEFERMENT IS
/***************************************************************
** Package:                EcDp_Objects_Deferment_Event
**
** Revision :              $Revision: 1.4.2.1 $
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
FUNCTION calcLossByDay(p_event_no   VARCHAR2,
                       p_start_date DATE,
                       p_daytime    DATE,
                       p_phase      VARCHAR2,
                       p_prod_inj   VARCHAR2) RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (calcLossByDay, WNDS, WNPS, RNPS);

FUNCTION calcLossByDayFromChildren(p_event_no VARCHAR2,
                                   p_start_date  DATE,
                                   p_daytime DATE,
                                   p_phase    VARCHAR2,
                                   p_prod_inj   VARCHAR2) RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (calcLossByDayFromChildren, WNDS, WNPS, RNPS);
END;
/