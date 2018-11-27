CREATE OR REPLACE PACKAGE EcDp_Well IS

/****************************************************************
** Package        :  EcDp_Well, header part
**
** $Revision: 1.43.24.5 $
**
** Purpose        :  Finds well properties.
**
** Documentation  :  www.energy-components.com
**
** Created  : 17.01.2000  Carl-Fredrik Sørensen
**
** Modification history:
**
** Version  Date       Whom  Change description:
** -------  --------   ----  --------------------------------------
** 1.0      17.01.00   CFS   Initial version
** 1.1      09.05.00   AV    New function findSplitFactor added
** 3.2      07.07.00   RR    New function getWellEquipmentCode added
** 3.3      20.07.00   TEJ   Added three new functions for getting field for well
** 3.3      04.08.00   MAO   Added function countProducingDays
** 3.4      28.08.00   DN    Added function calcWellTypeFracDay
**          07.06.01   KB    Changes made for Phillips (implemented for ATL)
** 3.92      26.07.01   ATL   Added insertPwelOnStrmHrs and insertIwelOnStrmHrs
** 3.9      12.09.01   FBa   Added funtions isWellProducer and isWellInjector
** 3.14     31.10.2001 FBa   Added function getWell
** 3.15    22.11.2001 LKJ   Added functions findPwelLastCompleteHalfHour and findIwelLastCompleteHalfHour
** 3.11     06.03.2002 DN    Added procedure createWellEntry.
** 3.12     16.05.2002 HNE   Added getAttributeTextById
**          2002-07-24 MTa   Changed object_id references to objects.object_id%TYPE
**          2004-04-22 FBa   Removed functions findPwelLastCompleteHalfHour and findIwelLastCompleteHalfHour, phasing out 30min tables.
**          2004-05-28 FBa   Removed function calcShutdownHoursInPeriod
**          2004-06-01 DN    Added getFacility.
**          2004-06-14 DN    Added getCurrentFlowlineId.TI 1402: Added new functions - getPwelOnStreamHrs and getIwelOnStreamHrs
**     2004-06-16 LIB   Expanded getCurrentFlowlineId to have flowline_type as input
**          2004-06-16 HNE   Added getWellNoByObjectId
**          11.08.2004 mazrina    removed sysnam and update as necessary
**          18.02.2005 Hang       Direct call to Constant like EcDp_Well_Type.WATER_GAS_INJECTOR is replaced
**                                with new function of EcDp_Well_Type.isWaterInjector as per enhancement for TI#1874.
**      25.02.2005  kaurrnar  Removed deadcodes.
**          Removed getAttributeText, getAttributeTextById and getAttributeValue function.
**          Removed insertAttribute, setAttribute and updateAttribute procedure.
**      02.03.2005  kaurrnar  Removed createWellEntry, insertWell and insertWellBore entry
**      04.03.2005  kaurrnar  Removed findField, getGasInjectionWatEquivalent, getOfficialName,
**          getWellAlias and getSeparatorTrain function
**      13.07.2005  Nazli   TI 1402: Added new functions - getPwelOnStreamHrs and getIwelOnStreamHrs
**          14.09.2005  ROV     TI 1402: Fixed error in getIwelOnStreamHrs
**          02.11.2005  DN      Replaced objects with well.object_id%TYPE.
**          12.12.2005  ROV     TI2618: Added new method getPwelPeriodOnStreamHrs
**          21.12.2005  Nazli   TI2923: Added new procedure biuCheckDate
**          27.12.2005  Nazli   TI2625: Removed calcPwelUptime, calcIwelUptime, calculatePwelOnStrmHrs, calculateIwelOnStrmHrs, insertPwelOnStrmHrs and insertIwelOnStrmHrs
**          29.12.2005  ROV     TI2618: Renamed getPwelPeriodOnStreamHrs to getPwelPeriodOnStrmFromStatus
**          20.09.2006  MOT     TI2113: Added updateStartDateOnChildObjects, updateEndDateOnChildObjects
**          13.02.2007  LAU     ECPD-3632: Added calcOnStrmHrsMonth and calcOnStrmDaysInMonth
**          17.04.2007  kaurrjes ECPD-5086: Added IsWellOpen and IsDeferred function
**          19.04.2007  LAU     ECPD-5253: Added IsIWellNotClosedLT
**          05.07.2007  IDRUSSAB ECPD-6017: Added getIwelPeriodOnStrmFromStatus
**           10.10.2007   rajarsar ECPD-6313: Updated function getPwelOnStreamHrs, getIwelOnStreamHrs to add support for new deferment version PD.0006
**          07.04.2008  aliassit ECPD-7967: Added new functions 'IsWellActiveStatus' and 'IsWellPhaseActiveStatus'
**                                          Renamed IsIwellNotClosedLT to IsWellNotClosedLt
**          16.04.2008  jailunur ECPD-7884: Added new procedures checkOtherSide and deleteOtherSide.
**          11.06.2008  jailunur ECPD-8667: Added the getWellSecondaryFacility function.
**          12.08.2008  leeeewei ECPD-8510: Added new function checkClosedWellWithinPeriod
**          26.08.2008  aliassit ECPD-9080: Added new functions: getPwelFlowDirection and getPwelFracToStrmToNode
**          30.09.2008  oonnnng  ECPD-9741: Added and modify functions: IUAllowWellClosedLT, AllowWellClosedLT, and DelAllowWellClosedLT.
                                            Added and modify functions: IUAllowInjWellClosedLT, AllowInjWellClosedLT, and DelAllowInjWellClosedLT.
**          24.07.2009  oonnnng  ECPD-12321: Add parameter p_on_strm_method to calcOnStrmHrsMonth() and calcOnStrmDaysInMonth() functions.
**			    11.02.2010 ismaiime  ECPD-13468: Add parameter p_new_status to procedure checkOtherSide
**          18.03.2010 Leongwen  ECPD-11535: Enhance the support for swing wells to support more than two facilities
**          17.12.2013 Leongwen  ECPD-26361: Added procedure chkDeferEventWhenWellClosed() to prevent user to change well status to "closed" or "closed-LT" when it is part of Deferment Event.
**                                           It will be used on the Maintain Production Well Status and Production Active Well Status screens.
** 			14.01.2015 dhavaalo  ECPD-28604: Added new function getPwelEventOnStreamsHrs()
**          04.09.2014 shindani  ECPD-28580: EcDp_Well.IsDeferred doesn't include deferment version PD.0006
*****************************************************************/

FUNCTION calcWellTypeFracDay(
       p_object_id well.object_id%TYPE,
       p_daytime DATE,
       p_well_type VARCHAR2)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(calcWellTypeFracDay, WNDS, WNPS, RNPS);

--

FUNCTION findSplitFactor(
  p_object_id  well.object_id%TYPE,
  p_daytime         DATE,
  p_phase           VARCHAR2,
  p_target_facility_id production_facility.object_id%TYPE,
  p_target_flowline_id flowline.object_id%TYPE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(findSplitFactor, WNDS, WNPS, RNPS);

--

FUNCTION getCurrentFlowlineId(p_well_id VARCHAR2, p_flowline_type VARCHAR2, p_daytime DATE)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(getCurrentFlowlineId, WNDS, WNPS, RNPS);


FUNCTION getFlowline(
   p_object_id    well.object_id%TYPE,
   p_daytime        DATE)

RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(getFlowline, WNDS, WNPS, RNPS);

--

FUNCTION getWellType (
   p_object_id  well.object_id%TYPE,
   p_daytime  DATE)

RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(getWellType, WNDS, WNPS, RNPS);

--

FUNCTION getWellClass(
  p_object_id  well.object_id%TYPE,
  p_daytime  DATE)

RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(getWellClass, WNDS, WNPS, RNPS);

--

FUNCTION getWellConnectedFacility(
  p_object_id  well.object_id%TYPE,
  p_daytime  DATE)

RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(getWellConnectedFacility, WNDS, WNPS, RNPS);

--

FUNCTION getWellEquipment(
   p_object_id  well.object_id%TYPE,
   p_daytime        DATE,
   p_class_name VARCHAR2)

RETURN equipment.object_id%TYPE;

PRAGMA RESTRICT_REFERENCES(getWellEquipment, WNDS, WNPS, RNPS);

--

FUNCTION countProducingDays(
   p_object_id  well.object_id%TYPE,
   p_from_daytime DATE,
   p_to_daytime DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (countProducingDays, WNDS, WNPS, RNPS);
--

FUNCTION getFieldFromWebo(
   p_object_id  well.object_id%TYPE,
   p_daytime DATE)

RETURN field.object_id%TYPE;

PRAGMA RESTRICT_REFERENCES (getFieldFromWebo, WNDS, WNPS, RNPS);

--

FUNCTION getFieldFromNode(
   p_object_id  well.object_id%TYPE,
   p_daytime DATE)

RETURN field.object_id%TYPE;

PRAGMA RESTRICT_REFERENCES (getFieldFromNode, WNDS, WNPS, RNPS);

FUNCTION isWellProducer(
  p_object_id  well.object_id%TYPE,
  p_daytime DATE)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (isWellProducer, WNPS, RNPS, WNDS);

FUNCTION isWellInjector(
  p_object_id  well.object_id%TYPE,
  p_daytime DATE)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (isWellInjector, WNPS, RNPS, WNDS);

FUNCTION getWell(
  p_object_id  well.object_id%TYPE,
  p_daytime  DATE)
RETURN WELL%ROWTYPE;
PRAGMA RESTRICT_REFERENCES (getWell, WNDS, WNPS, RNPS);

FUNCTION getFacility(p_object_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getFacility, WNDS, WNPS, RNPS);

FUNCTION getPwelOnStreamHrs(
         p_object_id well.object_id%TYPE,
         p_daytime DATE,
         p_on_strm_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getPwelOnStreamHrs, WNDS, WNPS, RNPS);

FUNCTION getIwelOnStreamHrs(
         p_object_id well.object_id%TYPE,
         p_inj_type VARCHAR2,
         p_daytime DATE,
         p_on_strm_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getIwelOnStreamHrs, WNDS, WNPS, RNPS);

FUNCTION getPwelPeriodOnStrmFromStatus(
  p_object_id well.object_id%TYPE,
        p_start_daytime DATE,
        p_end_daytime DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getPwelPeriodOnStrmFromStatus, WNDS, WNPS, RNPS);

FUNCTION getIwelPeriodOnStrmFromStatus(
  p_object_id well.object_id%TYPE,
    p_inj_type VARCHAR2,
        p_start_daytime DATE,
        p_end_daytime DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getIwelPeriodOnStrmFromStatus, WNDS, WNPS, RNPS);

PROCEDURE biuCheckDate(p_object_start_date DATE,
                       p_parent_object_id VARCHAR2
                       );

PROCEDURE updatDateOnConnectedObjects(p_object_start_date DATE,p_object_end_date DATE, p_object_id VARCHAR2);

FUNCTION calcOnStrmHrsMonth(
   p_object_id well.object_id%TYPE,
   p_inj_type VARCHAR2,
   p_daytime DATE,
   p_calc_type VARCHAR2,
   p_on_strm_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcOnStrmHrsMonth, WNDS, WNPS, RNPS);

FUNCTION calcOnStrmDaysInMonth(
   p_object_id well.object_id%TYPE,
   p_inj_type VARCHAR2,
   p_daytime DATE,
   p_on_strm_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcOnStrmDaysInMonth, WNDS, WNPS, RNPS);

FUNCTION IsWellOpen(p_object_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (IsWellOpen, WNPS, RNPS, WNDS);

FUNCTION IsDeferred(p_object_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (IsDeferred, WNPS, RNPS, WNDS);

FUNCTION IsWellNotClosedLT(p_object_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (IsWellNotClosedLT, WNPS, RNPS, WNDS);

PROCEDURE IUAllowWellClosedLT(p_object_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_status VARCHAR2);

PROCEDURE AllowWellClosedLT(p_object_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_status VARCHAR2);

PROCEDURE DelAllowWellClosedLT(p_object_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_status VARCHAR2);

PROCEDURE IUAllowInjWellClosedLT(p_object_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_status VARCHAR2, p_inj_type VARCHAR2);

PROCEDURE AllowInjWellClosedLT(p_object_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_status VARCHAR2, p_inj_type VARCHAR2);

PROCEDURE DelAllowInjWellClosedLT(p_object_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_status VARCHAR2, p_inj_type VARCHAR2);

FUNCTION IsWellActiveStatus(p_object_id VARCHAR2, p_active_status VARCHAR2, p_daytime DATE)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (IsWellActiveStatus, WNPS, RNPS, WNDS);

FUNCTION IsWellPhaseActiveStatus(p_object_id VARCHAR2, p_inj_phase VARCHAR2, p_active_status VARCHAR2, p_daytime DATE)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (IsWellPhaseActiveStatus, WNPS, RNPS, WNDS);

PROCEDURE checkOtherSide(
    p_object_id            VARCHAR2,
    p_daytime              DATE,
    p_inj_phase            VARCHAR2,
    p_new_status		   VARCHAR2
);

PROCEDURE deleteOtherSide(
    p_object_id            VARCHAR2,
    p_daytime              DATE,
    p_inj_phase            VARCHAR2
);

FUNCTION ActivePhases(p_object_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (ActivePhases, WNPS, RNPS, WNDS);

FUNCTION checkClosedWellWithinPeriod(p_object_id VARCHAR2, p_daytime DATE, p_end_date DATE)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (checkClosedWellWithinPeriod, WNPS, RNPS, WNDS);

FUNCTION getPwelFracToStrmToNode(p_object_id VARCHAR2, p_stream_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getPwelFracToStrmToNode, WNPS, RNPS, WNDS);

FUNCTION getPwelFlowDirection(
   p_object_id    well.object_id%TYPE,
   p_daytime        DATE)
RETURN VARCHAR2;

FUNCTION prev_equal_daytime(
         p_object_id VARCHAR2,
         p_daytime DATE,
         p_num_rows NUMBER DEFAULT 1) RETURN DATE;
PRAGMA RESTRICT_REFERENCES (prev_equal_daytime, WNDS, WNPS, RNPS);

PROCEDURE chkDeferEventWhenWellClosed(p_action VARCHAR2, p_object_id VARCHAR2, p_daytime DATE, p_well_status VARCHAR2, p_time_span VARCHAR2 DEFAULT NULL, p_summer_time VARCHAR2 DEFAULT NULL, p_inj_type VARCHAR2 DEFAULT NULL);


FUNCTION getPwelEventOnStreamsHrs(
         p_object_id well.object_id%TYPE,
         p_daytime DATE,
         p_on_strm_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getPwelEventOnStreamsHrs, WNDS, WNPS, RNPS);

END EcDp_Well;