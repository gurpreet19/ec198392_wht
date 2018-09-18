CREATE OR REPLACE PACKAGE EcDp_Deferment_Event IS
/****************************************************************
** Package        :  EcDp_Deferment_Event
**
** $Revision: 1.10.24.2 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to deferment.
**
** Documentation  :  www.energy-components.com
**
** Created  : 23.12.2005  Dagfinn Njå
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 13.11.2006	siahohwi Added function updateEndDateForWellDeferment
** 06.09.2007	rajarsar ECPD-6264: Added function calculateDeferedGrpMass, calculateDeferedMass, calcWellProdLossDayMass
** 29.11.2007 leongsei ECPD-7076: modified function updateEndDateForWellDeferment to update end daytime if is null or equal to parent old end date value
**                                added function updateStartDateForWellDefermnt
**
** 16.06.2008 rajarsar ECPD-6880: Updated moveEvent
** 16.07.2009 aliassit ECPD-11997 Added procedure setParentEndDate
** 03.04.2012 limmmchu ECPD-20473 Added procedure updateDateForWellDefermnt, deleted procedure updateStartDateForWellDefermnt
** 28.10.2013 choooshu ECPD-25727: Added function countChildEvent and deleteChildEvent
*****************************************************************/

-- Lock check procedures
PROCEDURE moveEvent(p_eventNo NUMBER,p_def_type VARCHAR2, p_daytime DATE DEFAULT NULL, p_end_date DATE DEFAULT NULL);
PROCEDURE insertAffectedWells(p_event_no NUMBER);
PROCEDURE moveShortToLong;

PROCEDURE deleteCalcData(p_wde_no NUMBER);
PROCEDURE deleteCalcDataOutsideTimeSpan(p_wde_no NUMBER,p_object_id VARCHAR2,p_new_daytime DATE, p_new_end_date DATE, p_old_daytime DATE, p_old_end_date DATE);
PROCEDURE updateEndDateForWellDeferment(p_event_no NUMBER,p_end_date DATE, p_parent_old_end_date DATE);
PROCEDURE updateDateForWellDefermnt(p_event_no NUMBER,p_start_date DATE, p_end_date DATE, p_parent_old_start_date DATE, p_parent_old_end_date DATE);

FUNCTION calculateDeferedGrpVolume(p_event_no NUMBER, p_phase VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calculateDeferedGrpVolume, WNDS, WNPS, RNPS);

FUNCTION calculateDeferedVolume(p_wde_no NUMBER, p_phase VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calculateDeferedVolume, WNDS, WNPS, RNPS);

FUNCTION calculateDeferedGrpMass(p_event_no NUMBER, p_phase VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calculateDeferedGrpMass, WNDS, WNPS, RNPS);

FUNCTION calculateDeferedMass(p_wde_no NUMBER, p_phase VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calculateDeferedMass, WNDS, WNPS, RNPS);

FUNCTION calcWellProdLossDay(p_object_id VARCHAR2, p_daytime DATE, p_phase VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcWellProdLossDay, WNDS, WNPS, RNPS);

FUNCTION calcWellProdLossDayMass(p_object_id VARCHAR2, p_daytime DATE, p_phase VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcWellProdLossDayMass, WNDS, WNPS, RNPS);

PROCEDURE setParentEndDate (p_event_no NUMBER);

FUNCTION countChildEvent(p_event_no NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (countChildEvent, WNDS, WNPS, RNPS);

PROCEDURE deleteChildEvent(p_event_no NUMBER);

END EcDp_Deferment_Event;