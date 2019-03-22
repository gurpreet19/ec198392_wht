CREATE OR REPLACE PACKAGE EcDp_Well IS

/****************************************************************
** Package        :  EcDp_Well, header part
**
** $Revision: 1.47 $
**
** Purpose        :  Finds well properties.
**
** Documentation  :  www.energy-components.com
**
** Created  : 17.01.2000  Carl-Fredrik S�sen
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
**          18.12.2013 Leongwen  ECPD-24994: Added procedure chkDeferEventWhenWellClosed() to prevent user to change well status to "closed" or "closed-LT" when it is part of Deferment Event.
**                                           It will be used on the Maintain Production Well Status and Production Active Well Status screens.
**          07.01.2014 kumarsur  ECPD-21804: Added new functions deleteInjectionSide, deleteProductionSide,checkInjectionSide and  checkProductionSide.
**          28.11.2014 leongwen  ECPD-29390: Added new function getDailyWellDownHrs to calculate the daily well DOWN deferment event hours
**          08.01.2015 dhavaalo  ECPD-25537: Added new function getPwelEventOnStreamsHrs()
**          05.11.2015 chaudgau  ECPD-19093: Added new procedure updateopfctyidOnConnObjects() to update the op_fcty_class_1_id of child objects
**          15.06.2016 shindani  ECPD-22520: Added new funtion getWellSleeveUOM to get sleeve UOM from well configuration screen.Used under well bore interval status screens.
**          19.07.2016 aaaaasho  ECPD-36549: Added new function wellOnTest to keep track if well is on test.
**          22.12.2017 singishi  ECPD-51137 removed all the instances of well_deferment_event table.
**          02-04-2018 kaushaak  ECPD-53796: Modified getDailyWellDownHrs
**          19-04-2018 abdulmaw  ECPD-55145: Modified getDailyWellDownHrs to support 2 injection type well
**          10.09.2018 solibhar ECPD-58838: Added new function IsPlannedWell()
*****************************************************************/

FUNCTION calcWellTypeFracDay(
       p_object_id well.object_id%TYPE,
       p_daytime DATE,
       p_well_type VARCHAR2)

RETURN NUMBER;

--

FUNCTION findSplitFactor(
  p_object_id  well.object_id%TYPE,
  p_daytime         DATE,
  p_phase           VARCHAR2,
  p_target_facility_id production_facility.object_id%TYPE,
  p_target_flowline_id flowline.object_id%TYPE)

RETURN NUMBER;

--

FUNCTION getCurrentFlowlineId(p_well_id VARCHAR2, p_flowline_type VARCHAR2, p_daytime DATE)
RETURN VARCHAR2;


FUNCTION getFlowline(
   p_object_id    well.object_id%TYPE,
   p_daytime        DATE)

RETURN VARCHAR2;

--

FUNCTION getWellType (
   p_object_id  well.object_id%TYPE,
   p_daytime  DATE)

RETURN VARCHAR2;

--

FUNCTION getWellClass(
  p_object_id  well.object_id%TYPE,
  p_daytime  DATE)

RETURN VARCHAR2;

--

FUNCTION getWellConnectedFacility(
  p_object_id  well.object_id%TYPE,
  p_daytime  DATE)

RETURN VARCHAR2;

--

FUNCTION getWellEquipment(
   p_object_id  well.object_id%TYPE,
   p_daytime        DATE,
   p_class_name VARCHAR2)

RETURN equipment.object_id%TYPE;

--

FUNCTION getWellSleeveUOM(
  p_object_id  well.object_id%TYPE,
  p_daytime  DATE)

RETURN VARCHAR2;
--

FUNCTION countProducingDays(
   p_object_id  well.object_id%TYPE,
   p_from_daytime DATE,
   p_to_daytime DATE)

RETURN NUMBER;
--

FUNCTION getFieldFromWebo(
   p_object_id  well.object_id%TYPE,
   p_daytime DATE)

RETURN field.object_id%TYPE;

--

FUNCTION getFieldFromNode(
   p_object_id  well.object_id%TYPE,
   p_daytime DATE)

RETURN field.object_id%TYPE;

FUNCTION isWellProducer(
  p_object_id  well.object_id%TYPE,
  p_daytime DATE)
RETURN VARCHAR2;

FUNCTION isWellInjector(
  p_object_id  well.object_id%TYPE,
  p_daytime DATE)
RETURN VARCHAR2;

FUNCTION getWell(
  p_object_id  well.object_id%TYPE,
  p_daytime  DATE)
RETURN WELL%ROWTYPE;

FUNCTION getFacility(p_object_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2;

FUNCTION getPwelOnStreamHrs(
         p_object_id well.object_id%TYPE,
         p_daytime DATE,
         p_on_strm_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION getIwelOnStreamHrs(
         p_object_id well.object_id%TYPE,
         p_inj_type VARCHAR2,
         p_daytime DATE,
         p_on_strm_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION getPwelPeriodOnStrmFromStatus(
  p_object_id well.object_id%TYPE,
        p_start_daytime DATE,
        p_end_daytime DATE)
RETURN NUMBER;

FUNCTION getIwelPeriodOnStrmFromStatus(
  p_object_id well.object_id%TYPE,
    p_inj_type VARCHAR2,
        p_start_daytime DATE,
        p_end_daytime DATE)
RETURN NUMBER;

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

FUNCTION calcOnStrmDaysInMonth(
   p_object_id well.object_id%TYPE,
   p_inj_type VARCHAR2,
   p_daytime DATE,
   p_on_strm_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION IsWellOpen(p_object_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2;

FUNCTION IsDeferred(p_object_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2;

FUNCTION IsWellNotClosedLT(p_object_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2;

PROCEDURE IUAllowWellClosedLT(p_object_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_status VARCHAR2);

PROCEDURE AllowWellClosedLT(p_object_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_status VARCHAR2);

PROCEDURE DelAllowWellClosedLT(p_object_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_status VARCHAR2);

PROCEDURE IUAllowInjWellClosedLT(p_object_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_status VARCHAR2, p_inj_type VARCHAR2);

PROCEDURE AllowInjWellClosedLT(p_object_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_status VARCHAR2, p_inj_type VARCHAR2);

PROCEDURE DelAllowInjWellClosedLT(p_object_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_status VARCHAR2, p_inj_type VARCHAR2);

FUNCTION IsWellActiveStatus(p_object_id VARCHAR2, p_active_status VARCHAR2, p_daytime DATE)
RETURN VARCHAR2;

FUNCTION IsWellPhaseActiveStatus(p_object_id VARCHAR2, p_inj_phase VARCHAR2, p_active_status VARCHAR2, p_daytime DATE)
RETURN VARCHAR2;

PROCEDURE checkOtherSide(
    p_object_id            VARCHAR2,
    p_daytime              DATE,
    p_inj_phase            VARCHAR2,
    p_new_status		   VARCHAR2
);

PROCEDURE checkProductionSide(
    p_object_id            VARCHAR2,
    p_daytime              DATE,
    p_new_status		   VARCHAR2
);


PROCEDURE checkInjectionSide(
    p_object_id            VARCHAR2,
    p_daytime              DATE,
	p_well_type       VARCHAR2,
    p_new_status		   VARCHAR2
);


PROCEDURE deleteOtherSide(
    p_object_id            VARCHAR2,
    p_daytime              DATE,
    p_inj_phase            VARCHAR2
);

PROCEDURE deleteProductionSide(
    p_object_id            VARCHAR2,
    p_daytime              DATE
);

PROCEDURE deleteInjectionSide(
    p_object_id            VARCHAR2,
    p_daytime              DATE,
	p_well_type       VARCHAR2
);

FUNCTION ActivePhases(p_object_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2;

FUNCTION checkClosedWellWithinPeriod(p_object_id VARCHAR2, p_daytime DATE, p_end_date DATE)
RETURN VARCHAR2;

FUNCTION getPwelFracToStrmToNode(p_object_id VARCHAR2, p_stream_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;

FUNCTION getPwelFlowDirection(
   p_object_id    well.object_id%TYPE,
   p_daytime        DATE)
RETURN VARCHAR2;

FUNCTION prev_equal_daytime(
         p_object_id VARCHAR2,
         p_daytime DATE,
         p_num_rows NUMBER DEFAULT 1) RETURN DATE;

PROCEDURE chkDeferEventWhenWellClosed(p_action VARCHAR2, p_object_id VARCHAR2, p_daytime DATE, p_well_status VARCHAR2, p_time_span VARCHAR2 DEFAULT NULL, p_summer_time VARCHAR2 DEFAULT NULL, p_inj_type VARCHAR2 DEFAULT NULL);

FUNCTION getDailyWellDownHrs(p_object_id VARCHAR2, p_daytime DATE, p_inj_type VARCHAR2 DEFAULT NULL) RETURN NUMBER;

FUNCTION getPwelEventOnStreamsHrs(
         p_object_id well.object_id%TYPE,
         p_daytime DATE,
         p_on_strm_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

PROCEDURE updateopfctyidOnConnObjects(
    p_op_fcty_class_1_id VARCHAR2,
	p_daytime DATE,
	p_object_id VARCHAR2);

FUNCTION wellOnTest(p_well_id VARCHAR2,
                    p_daytime DATE)
RETURN VARCHAR2;

FUNCTION IsPlannedWell(p_object_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2;

END EcDp_Well;