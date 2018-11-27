CREATE OR REPLACE PACKAGE BODY EcDp_Well IS
/****************************************************************
** Package        :  EcDp_Well, body part
**
** $Revision: 1.110.2.13 $
**
** Purpose        :  Finds well properties.
**
** Documentation  :  www.energy-components.com
**
** Created  : 17.01.2000  Carl-Fredrik Sørensen
**
** Modification history:
**
** Date       Whom     Change description:
** --------   -------- --------------------------------------
** 17.01.00   CFS      Initial version
** 09.05.00   AV       New function findSplitFactor added
** 07.07.00   RR       New function getWellEquipmentCode added
** 20.07.00   TeJ      Added three new functions for getting field for well
** 04.08.00   MAO      Added function countProducingDays
** 18.08.00   AV       Bugfix in findSplitFactor
** 28.08.00   DN       Added function calcWellTypeFracDay
** 01.10.00   FBa      Bugfix in findSplitFactor, use > not >= on end_date in flwl_sub_well_conn etc.
** 26.09.00   DN       Bugfix in getSeparatorTrain.
** 09.10.00   TeJ      Bugfix in findField
** 05.04.01   KEJ      Documented functions and procedures.
** 07.06.01   KB       Changes made for Phillips (implemented for ATL)
** 26.07.01   ATL      Added insertPwelOnStrmHrs and insertIwelOnStrmHrs
** 12.09.2001 FBa      Added funtions isWellProducer and isWellInjector
** 31.10.2001 FBa      Added function getWell
** 02.11.2001 FBa      Fixed typo in getWell.
** 22.11.01   LKJ      Added functions findPwelLastCompleteHalfHour and findIwelLastCompleteHalfHour.
** 06.03.2002 DN       Added procedure createWellEntry.
** 16.05.2002 HNE      Added getAttributeTextById
** 09.09.2002 FBa      Fixed bug in calcShutdownHoursInPeriod, do -1 in where clause, not 24 (days).
** 2002-07-24 MTa      Changed object_id references to objects.object_id%TYPE
** 2002-09-19 DN       Removed old table reference (WELL_INFORMATION). R. 7.1.
** 2004-01-14 DN       Replaced SPOT with EVENT.
** 2004-03-11 DN       Procedure createWellEntry: Removed obsolete well_id column.
** 2004-04-19 DN       Procedure insertWellBore: Adapted to new table structure of webo_split_factor.
** 2004-04-22 FBa      Removed functions findPwelLastCompleteHalfHour and findIwelLastCompleteHalfHour, phasing out 30min tables.
** 2004-05-14 DN       Modified getWellClass function to derive the well class from well type and cross table mapping.
** 2004-05-28 FBa      Removed function calcShutdownHoursInPeriod
** 2004-06-01 DN       Added getFacility.
** 2004-06-01 DN       Modified function calls to get production day.
** 2004-06-14 DN       Added getCurrentFlowlineId.
** 2004-06-16 LIB       Expanded getCurrentFlowlineId with flowline_type as input
** 2004-06-15 HNE      Added getWellNoByObjectId
** 2004-06-23 LIB       Fixed getCurrentFlowlineId to allow well to be connected after flowline is created.
** 2004-08-11 Toha     Replaced sysnam+facility+well_no with well.object_id and made updates as necessary.
** 2004-08-23 Toha     Removed getWellNoBYObjectId.
**                     Changed signature of createWellEntry
**                     Changed signature of insertWell
**                     Changed name of getWellEquipmentCode to getWellEquipment
** 2004-10-07 DN       TI 1656, manual merge from BASELINE-74: Added column type declaration to the local variables that holds attribute tezt return values.
**                     Removed inactive/comment code.
** 2004-12-14 DN       Removed obsolete procedure EcDp_Well_Node.insertWellNode.
** 2005-02-18 Hang     Direct call to Constant like EcDp_Well_Type.WATER_GAS_INJECTOR is replaced
**                     with new function of EcDp_Well_Type.isWaterInjector as per enhancement for TI#1874.
** 25.02.2005  kaurrnar Removed deadcodes.
**                     Removed getAttributeText, getAttributeTextById and getAttributeValue function.
**                     Removed insertAttribute, setAttribute and updateAttribute procedure.
** 01.03.2005 Darren   Made update to functions those getSeparatorTrain referring to ec_sepa_version
** 02.03.2005 kaurrnar Changed calling statement to ec_sepa_version to previous ecdp_separator_attribute.
**                     Changed the number or arguments being passed to the EcDp_Groups.findParentObjectId function.
** 04.03.2005 kaurrnar Removed findField, getGasInjectionWatEquivalent, getOfficialName
**                     getWellAlias and getSeparatorTrain function
** 27.05.2005 DN       Function getFacility: Replaced EcDp_Groups.findParentObjectID with direct ec-package call.
** 28.04.2005 DN       Bug fix: local variables holding well type must be declared varchar2(32).
** 13.07.2005 Nazli    TI 1402: Added new functions - getPwelOnStreamHrs and getIwelOnStreamHrs
** 25.08.2005 Toha     Fixed getPwelOnStreamHrs, getIwelOnStreamHrs to use correct calculation for deferment
** 14.09.2005 ROV      Fixed error in getIwel/PwelOnStreamHrs part of tracker #1402. Also replaced harcoded 24 with ecdp_date_time.getNumHours(p_daytime)
** 30.09.2005 DN       TD4429: In the functions getPwelOnStreamHrs and getIwelOnStreamHrs a default value for ON_STREAM_METHOD is set to MEASURED
**                     when there are no values provided for the given WELL_VERSION.
** 02.11.2005 DN       Replaced objects with well.object_id%TYPE.
** 15.11.2005 DN       TI2742: Changed cursor in function getFieldFromWebo according to new table structure.
** 18.11.2005 chongjer TI2764: Production day offset is indenpendent of number of hours in the day.
** 12.12.2005 ROV      TI2618: Added new method getPwelPeriodOnStreamHrs
** 21.12.2005 Nazli    TI2923: Added new procedure biuCheckDate
** 27.12.2005 Nazli    TI2625: Removed calcPwelUptime, calcIwelUptime, calculatePwelOnStrmHrs, calculateIwelOnStrmHrs, insertPwelOnStrmHrs and insertIwelOnStrmHrs
** 29.12.2005 ROV      TI2618: Renamed getPwelPeriodOnStreamHrs to getPwelPeriodOnStrmFromStatus
** 11.01.2006 chongjer TI2765: Updated getPwelOnStreamHrs and getIwelOnStreamHrs to return correct on stream hours value
** 16.08.2006 siahohwi TI4004: New on_stream_hrs method for off deferment
** 22.09.2006 ottermag TI2113: Added updateStartDateOnChildObjects
** 08.11.2006 zakiiari TI4512: Updated getFieldFromWebo, updatDateOnConnectedObjects, updateStartDateOnChildObjects, updateEndDateOnChildObjects
** 13.02.2007 LAU      ECPD-3632: Added calcOnStrmHrsMonth and calcOnStrmDaysInMonth
** 13.04.2007 LAU      ECPD-5253: Modified getIwelOnStreamHrs and calcOnStrmHrsMonth
** 17.04.2007 kaurrjes ECPD-5086: Added new function IsWellOpen and IsDeferred
** 19.04.2007 LAU      ECPD-5253: Added IsIWellNotClosedLT and modified IsWellOpen
** 28.06.2007 kaurrjes ECPD-5423: Corrected issue Onstream hours from deferment calculated from header record, not well record
**                     Simplified and corrected cursors cur_iwelOffDefermentEvent and cur_pwelOffDefermentEvent
** 05.07.2007 IDRUSSAB ECPD-6017: Added getIwelPeriodOnStrmFromStatus
** 24.07.2007 rahmanaz ECPD-6028: Modified getPwelOnStreamHrs and getIwelOnStreamHrs to calculate OffStreamSession
** 19.09.2007 leongsei ECPD-6289: Modify function getPwelOnStreamHrs, getIwelOnStreamHrs,
                                                  getPwelPeriodOnStrmFromStatus, getIwelPeriodOnStrmFromStatus,
                                                  calcOnStrmHrsMonth, IsWellOpen, IsIWellNotClosedLT to improve performance
** 10.10.2007 rajarsar ECPD-6313: Updated function getPwelOnStreamHrs, getIwelOnStreamHrs to add support for new deferment version PD.0006
** 18.11.2007 jailunur ECPD-6018: Updated function getPwelOnStreamHrs and getIwelOnStreamHrs to include records from LOW Deferment screen with OFF_INDICATOR flag.
** 06.12.2007 kaurrjes ECPD-6802: Modified getPwelOnStreamHrs and getIwelOnStreamHrs to calculate OffStreamSession.
** 25.01.2008 jailunur ECPD-4848: Modified function getWellClass to directly get from Well_Version and function AllowWellClosedLT to remove cursor
**                                chck_records_pwel and chck_records_iwel
** 01.04.2008 rajarsar ECPD-7844: Updated parameter passings to getNumHours.
** 07.04.2008 aliassit ECPD-7967: Added new functions: 'IsWellActiveStatus' and 'IsWellPhaseActiveStatus'
**                  Renamed IsIwellNotClosedLT to IsWellNotClosedLT
**                                Modified IsWellOpen, IsWellNotClosedLT, isWellProducer, isWellInjector
** 07.04.2008 aliassit ECPD-7967: modified IsWellActiveStatus to support well status = CLOSED_LT
** 16.04.2008 jailunur ECPD-7884: Added new procedures checkOtherSide and deleteOtherSide.
** 07.05.2008 leongsei ECPD-7917: Set object_end_date for well with well hole
** 08.05.2008 embonhaf ECPD-8219  Removed well hole version check in updatDateOnConnectedObjects
** 21.05.2008 oonnnng  ECPD-7878: Add ActivePhases function.
** 11.06.2008 jailunur ECPD-8667: Added the getWellSecondaryFacility function.
** 12.08.2008 leeeewei ECPD-8510: Added new function checkClosedWellWithinPeriod
** 26.08.2008 aliassit ECPD-9080: Added new functions: getPwelFlowDirection and getPwelFracToStrmToNode
** 30.09.2008 oonnnng  ECPD-9741: Added and modify functions: IUAllowWellClosedLT, AllowWellClosedLT, and DelAllowWellClosedLT.
                                  Added and modify functions: IUAllowInjWellClosedLT, AllowInjWellClosedLT, and DelAllowInjWellClosedLT.
** 28-10-2008 oonnnng  ECPD-9741: Amend "EcDp_System.getDependentCode('ACTIVE_WELL_STATUS','WELL_STATUS',ec_pwel_period_status.well_status(p_object_id, p_daytime, 'EVENT', '<='));"
                                  to "ec_pwel_period_status.active_well_status(p_object_id, p_daytime, 'EVENT', '<=');".
** 01.12.2008 leongsei ECPD-10476: Modified function getPwelPeriodOnStrmFromStatus to get the correct calculation of well on stream hours
** 23.12.2008 ismaiime ECPD-10407 Modify function IsDeferred to allow well to be closed at the same time as an OFF deferment ended.
** 31.12.2008 sharawan ECPD-10416:Replaced all references to EcDp_Type.pb_comp_number%TYPE with NUMBER in functions calcWellTypeFracDay, findSplitFactor.
** 08.01.2009 lauuufus ECPD-10679:Set the default_status = CLOSED for function IsWellActiveStatus and IsWellPhaseActiveStatus
** 20.01.2009 embonhaf ECPD-10746: Fixed performance issues caused by IUAllowWellClosedLT, AllowWellClosedLT, DelAllowWellClosedLT, IUAllowInjWellClosedLT, AllowInjWellClosedLT and DelAllowInjWellClosedLT.
** 24.07.2009 oonnnng  ECPD-11735: Add parameter p_on_strm_method to calcOnStrmHrsMonth() and calcOnStrmDaysInMonth() functions.
                                  Revise the calcOnStrmHrsMonth() function to call to getPwelOnStreamHrs() and getIwelOnStreamHrs() functions.
** 11.09.2009 oonnnng  ECPD-12519: Modify function IsDeferred to NOT allow well to be closed at the same time as an deferment well started.
** 11.02.2010 ismaiime ECPD-13468: Modify procedure checkOtherSide to correct the logic when changing status of well with different injection type.
** 18.03.2010 Leongwen ECPD-11535: Enhance the support for swing wells to support more than two facilities
** 21.04.2010 oonnnng  ECPD-14199: Added USER_EXIT method to getPwelOnStreamHrs() and getIwelOnStreamHrs() functions.
** 18.07.2011 madondin ECPD-17761: Modified function updateEndDateOnChildObjects by adding to update webo_version, webo_interval_version and perf_interval_version
** 30.12.2011 rajarsar ECPD-18846: Updated isWellActiveStatus to support CO2 Injection wells.
** 07.05.2012 musthram ECPD-20819: Updated updateEndDateOnChildObjects and updatDateOnConnectedObjects.
** 26.07.2012 rajarsar ECPD-21600: Updated isWellPhaseActiveStatus and activePhases.
** 27.07.2012 makkkkam ECPD-21605: Updated updateEndDateOnChildObjects
** 25.09.2013 makkkkam ECPD-25561: Updated updatDateOnConnectedObjects and updateStartDateOnChildObjects
** 17.12.2013 Leongwen ECPD-26361: Added procedure chkDeferEventWhenWellClosed() to prevent user to change well status to "closed" or "closed-LT" when it is part of Deferment Event.
**                                 It will be used on the Maintain Production Well Status and Production Active Well Status screens.
** 14.01.2015 dhavaalo ECPD-28604: Added new function getPwelEventOnStreamsHrs()
** 04.09.2014 shindani ECPD-28580: EcDp_Well.IsDeferred doesn't include deferment version PD.0006
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcWellTypeFracDay                                                          --
-- Description    : Calculates how long a well was a specific well type during a production day. --
--                  Returns a fraction [0;1]. Null if no configuration at all match requested    --
--                  type.                                                                        --
--                                                                                               --
-- Preconditions  : Changes is configured with WELL_TYPE in table well_version.                  --
-- Postcondition  :                                                                              --
-- Using Tables   : Well_version                                                                 --
--                                                                                               --
-- Using functions: ec_well_version.well_type                                                    --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcWellTypeFracDay(
       p_object_id  well.object_id%TYPE,
       p_daytime   DATE,
       p_well_type VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_changes IS
SELECT *
FROM well_version
WHERE object_id = p_object_id
AND daytime >= p_daytime
AND daytime < p_daytime + 1
ORDER by daytime;

ln_current_type VARCHAR2(32);
ld_last_change DATE;
ln_day_frac NUMBER;
ln_ret_val NUMBER;

BEGIN

   -- Get current configuration at end of day (midnight).

   ln_current_type := ec_well_version.well_type(p_object_id,
            p_daytime + 1,
            '<=');
   IF ln_current_type IS NOT NULL THEN

      -- Get current configuration at beginning of day (midnight).
      ln_current_type := ec_well_version.well_type(p_object_id,
            p_daytime,
            '<=');
      ld_last_change := p_daytime;

      FOR change IN c_changes LOOP

         IF ln_current_type = p_well_type THEN

            ln_day_frac := Nvl(ln_day_frac,0) + (change.daytime - ld_last_change);

         END IF;

         ln_current_type := change.well_type;
         ld_last_change := change.daytime;

      END LOOP;

      IF ld_last_change = p_daytime THEN -- No changes during day

         IF ln_current_type = p_well_type THEN

            ln_day_frac := 1;

         END IF;

      ELSE -- deal with last period until midnight

         IF ln_current_type = p_well_type THEN

            ln_day_frac := Nvl(ln_day_frac,0) + (p_daytime + 1 - ld_last_change);

         END IF;

      END IF;

      ln_ret_val := ln_day_frac;

   END  IF;

   RETURN ln_ret_val;

END calcWellTypeFracDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findSplitFactor                                                              --
-- Description    : This function is used to find the factor of the total                        --
--                  produced by the given well that are flowing to the given                     --
--                  facility and flowline.                                                       --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   : FLOWLINE_SUB_WELL_CONN                                                       --
--                  FLWL_SEP_ASSIGNMENT                                                          --
--                  separator_conn                                                               --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION findSplitFactor(
  p_object_id  well.object_id%TYPE,
  p_daytime         DATE,
  p_phase           VARCHAR2,
  p_target_facility_id  production_facility.object_id%TYPE,
  p_target_flowline_id flowline.object_id%TYPE)

RETURN NUMBER
--</EC-DOC>
IS

ln_total     NUMBER;
ln_on_fcty   NUMBER;  -- counter for flowlines on target facilty
ln_ret_val       NUMBER;


CURSOR c_well_flowline_separator IS
SELECT sc.target_id,
       sc.source_id,
       fs.object_id flowline_id
FROM   FLOWLINE_SUB_WELL_CONN fw, FLWL_SEP_ASSIGNMENT fs, separator_conn sc
WHERE fw.object_id = fs.object_id
AND    fs.separator_id = sc.source_id
AND    fw.daytime <= p_daytime AND Nvl(fw.end_date,p_daytime+1) > p_daytime
AND    fs.daytime <= p_daytime AND Nvl(fs.end_date,p_daytime+1) > p_daytime
AND    sc.daytime <= p_daytime AND Nvl(sc.end_date,p_daytime+1) > p_daytime
AND    fw.well_id = p_object_id;

CURSOR c_well_flowline IS
SELECT fw.object_id flowline_id
FROM   FLOWLINE_SUB_WELL_CONN fw
WHERE  fw.well_id = p_object_id
AND    fw.daytime <= p_daytime AND Nvl(fw.end_date,p_daytime+1) > p_daytime;


BEGIN

   ln_total     := 0;  -- count numbers of target separators
   ln_on_fcty   := 0;  -- count number connected to target facility (using specified flowline if any)

   IF p_target_facility_id IS NOT NULL THEN

     -- Find separators and flowlines connected to well ,
     -- there can be more than one ref. Asgard

     FOR cur_Target IN c_well_flowline_separator LOOP

        ln_total := ln_total + 1;

        IF  ec_separator.prod_fcty_id(cur_target.target_id) = p_target_facility_id
        AND cur_target.flowline_id = NVL(p_target_flowline_id,cur_target.flowline_id) THEN
            ln_on_fcty := ln_on_fcty + 1;

        END IF;

     END LOOP;

     IF NVL(ln_total,0) > 0 THEN   -- well is connected to at least one facility, calculate split

         ln_ret_val := ln_on_fcty/ln_total;

     ELSE  -- well is not connected to any facility, splitfactor = 0

         ln_ret_val := 0;

     END IF;

   ELSE


     -- Find flowlines connected to well ,
     -- there can be more than one ref. Asgard

     FOR cur_Target IN c_well_flowline LOOP

        ln_total := ln_total + 1;

        IF  cur_target.flowline_id = p_target_flowline_id THEN

            ln_on_fcty := ln_on_fcty + 1;

        END IF;

     END LOOP;

     IF NVL(ln_total,0) > 0 THEN   -- well is connected to at least one facility, calculate split

         ln_ret_val := ln_on_fcty/ln_total;

     ELSE  -- well is not connected to any facility, splitfactor = 0

         ln_ret_val := 0;

     END IF;


   END IF;

   RETURN ln_ret_val;

END findSplitFactor;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCurrentFlowlineId
-- Description    : Returns the current flowline of given flowline_type the given well is connected to.
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : flowline_sub_well_conn
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getCurrentFlowlineId(p_well_id VARCHAR2, p_flowline_type VARCHAR2, p_daytime DATE)
RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR cur_flowline IS
SELECT a.object_id
FROM flowline_sub_well_conn a,flowline f
WHERE a.well_id = p_well_id
AND f.object_id = a.object_id
AND ecdp_flowline.getFlowlineType(a.object_id, f.start_date) = p_flowline_type
AND a.daytime  = (
  SELECT Max(b.daytime)
  FROM   flowline_sub_well_conn b
  WHERE  b.object_id = a.object_id
  AND    b.well_id   = a.well_id
  AND    b.daytime <= p_daytime
  AND    Nvl(b.end_date, p_daytime + 1) > p_daytime)
AND (f.end_date is null OR f.end_date >= p_daytime)
;


lv2_flowline_id flowline.object_id%TYPE;

BEGIN

  FOR cur_rec IN cur_flowline LOOP

    lv2_flowline_id := cur_rec.object_id;

  END LOOP;

   RETURN lv2_flowline_id;

END getCurrentFlowlineId;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getFlowline                                                                  --
-- Description    : Returns which flowline are connected to a well at a given time               --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   : FLOWLINE_SUB_WELL_CONN                                                       --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getFlowline(
  p_object_id well.object_id%TYPE,
   p_daytime  DATE)

RETURN VARCHAR2
--</EC-DOC>
IS

lv2_flowline_id VARCHAR2(32);

CURSOR cur_flowline IS
SELECT object_id flowline_id
FROM   FLOWLINE_SUB_WELL_CONN a
WHERE well_id = p_object_id
AND   DAYTIME  = (
  SELECT Max(b.DAYTIME)
  FROM   FLOWLINE_SUB_WELL_CONN b
  WHERE  b.object_id = a.object_id
   AND    b.well_id = a.well_id
  AND    b.DAYTIME <= p_daytime
  AND    Nvl(b.end_date, p_daytime + 1) > p_daytime)
ORDER BY well_id;

BEGIN

  FOR mycur IN cur_flowline LOOP

      lv2_flowline_id := mycur.flowline_id;

    EXIT; -- Leave the loop at the first occurence of flowline

  END LOOP;

  RETURN lv2_flowline_id;

END getFlowline;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWellClass
-- Description    : Returns the valid well class (Injector/Producer/Other) for a given well.
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions: EcDp_Well_Attribute.WELL_CLASS
--                  EcDp_Well_Attribute.WELL_TYPE
--
-- Configuration
-- required       :
--
-- Behaviour      : Retrieves the well type among the well attributes based on the well and daytime given.
--                  Decodes the well type to the proper well class code by using the EC-codes'
--                  dependency mapping outlined in the previous section.
--
---------------------------------------------------------------------------------------------------
FUNCTION getWellClass (
  p_object_id well.object_id%TYPE,
   p_daytime  DATE)

RETURN VARCHAR2
--</EC-DOC>
IS
lv2_well_class VARCHAR2(2);

BEGIN

   lv2_well_class := ec_well_version.well_class(
          p_object_id,
          p_daytime,
          '<=');

   RETURN lv2_well_class;

END getWellClass;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWellType                                                                  --
-- Description    : Returns the valid well type for a given well                                 --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                  ec_well_version....                                                          --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getWellType (
  p_object_id well.object_id%TYPE,
     p_daytime  DATE)

RETURN VARCHAR2
--</EC-DOC>
IS

lv2_well_type VARCHAR2(32);

BEGIN

   lv2_well_type := ec_well_version.well_type(
          p_object_id,
          p_daytime,
          '<=');

   RETURN lv2_well_type;

END getWellType;

--<EC-DOC>
----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Function       : getWellConnectedFacility
-- Description    : Returns the connected Facility Class 1 being defined in Object Group connection for a given 'Swing-well'.
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Retrieves the connected facility class 1 being defined in Object Group connection for a given 'Swing-well' based on daytime given.
--
--
----------------------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION getWellConnectedFacility (
  p_object_id well.object_id%TYPE,
  p_daytime  DATE)
RETURN VARCHAR2
--</EC-DOC>
IS

lv2_asset_name VARCHAR2(200);

CURSOR cur_last_swing_conn(cp_object_id well.object_id%TYPE, cp_daytime date) IS
select w.asset_id
from well_swing_connection w
where w.object_id = cp_object_id
and w.daytime =
  (select max(wsc.daytime)
   from well_swing_connection wsc
   where wsc.object_id = cp_object_id
   AND wsc.daytime < cp_daytime);

lv2_asset_id  production_facility.object_id%TYPE;

BEGIN

  FOR one IN cur_last_swing_conn(p_object_id, p_daytime) LOOP
    lv2_asset_id := one.asset_id;
  END LOOP;

  RETURN lv2_asset_id;

END getWellConnectedFacility;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWellEquipmentCode                                                         --
-- Description    : returns a string containing equipment_code connected to given well/time      --
--                  of type given as input                                                       --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   : EQUIPMENT_WELL_CONN                                                          --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getWellEquipment(
   p_object_id      well.object_id%TYPE,
   p_daytime        DATE,
   p_class_name VARCHAR2)
RETURN equipment.object_id%TYPE
--</EC-DOC>
IS

   CURSOR eqpm_cursor IS
  SELECT a.*, eq.object_id equipment_id
  FROM EQUIPMENT_WELL_CONN a, equipment eq
  WHERE eq.class_name = p_class_name
   AND eq.object_id = a.object_id
  AND well_id = p_object_id
   AND DAYTIME = (
    SELECT Max(b.DAYTIME)
    FROM EQUIPMENT_WELL_CONN b
    WHERE b.well_id = a.well_id
      AND b.object_id = a.object_id
     AND b.DAYTIME <= p_daytime
     AND Nvl(b.end_date, p_daytime + 1) > p_daytime);

    v_equipment_id varchar2(32);

BEGIN

   v_equipment_id := NULL;

   FOR eqpm_rec IN eqpm_cursor LOOP

     IF eqpm_cursor%ROWCOUNT > 1 THEN
         v_equipment_id := NULL;
     ELSE
         v_equipment_id := eqpm_rec.equipment_id;
     END IF;

   END LOOP;

   RETURN v_equipment_id;

END getWellEquipment;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : countProducingDays                                                           --
-- Description    : Counts the number of real days that the well has                             --
--        been producing from p_from_daytime until p_to_daytime                        --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   : pwel_day_status                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION countProducingDays(
   p_object_id well.object_id%TYPE,
   p_from_daytime DATE,
   p_to_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS

ln_retval NUMBER := 0;

CURSOR pwel_status_cur IS
  SELECT count(daytime) days
  FROM pwel_day_status
  WHERE object_id = p_object_id
   AND daytime >= p_from_daytime
  AND daytime <= p_to_daytime
  AND on_stream_hrs > 0;

BEGIN

   FOR my_cur IN pwel_status_cur LOOP
      ln_retval := my_cur.days;
   END LOOP;

   RETURN ln_retval;
END countProducingDays;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getFieldFromWebo                                                             --
-- Description    :                                                                              --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   : webo_bore                                                                    --
--                  webo_interval                                                                --
--                  resv_block_formation                                                         --
--                  commercial_entity                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getFieldFromWebo(
   p_object_id well.object_id%TYPE,
   p_daytime DATE)

RETURN field.object_id%TYPE
--</EC-DOC>
IS

lv2_retval field.object_id%TYPE := ' ';

CURSOR webo_bore_cur IS
   SELECT *
   FROM webo_bore
   WHERE well_id = p_object_id
     AND Nvl(start_date,p_daytime) <= p_daytime
     AND Nvl(end_date, p_daytime+1) > p_daytime;

CURSOR field_cur(cp_wellBoreId VARCHAR2) IS
   SELECT DISTINCT cv.field_id field
   FROM webo_interval wi,
      perf_interval pi,
       resv_block_formation rbf,
                rbf_version rbfv,
       commercial_entity coent,
       coent_version cv,
       webo_bore wb
   WHERE
     --wi.resv_block_formation_id = rbf.object_id
     pi.resv_block_formation_id = rbf.object_id
     AND rbfv.commercial_entity_id = coent.object_id
     AND coent.object_id = cv.object_id
     AND p_daytime >= cv.daytime
     AND p_daytime < nvl(cv.end_date, p_daytime+1)
     AND rbfv.object_id = rbf.object_id
     AND p_daytime >= rbfv.daytime
     AND p_daytime < nvl(rbfv.end_date, p_daytime+1)
     AND wi.well_bore_id = wb.object_id
     AND wi.well_bore_id = cp_wellBoreId
     AND Nvl(wi.start_date,p_daytime) <= p_daytime
     AND Nvl(wi.end_date, p_daytime+1) > p_daytime
     AND pi.webo_interval_id = wi.object_id
     AND Nvl(pi.start_date, p_daytime) <= p_daytime
     AND Nvl(pi.end_date, p_daytime+1) > p_daytime;

BEGIN

   FOR cur_webo IN webo_bore_cur LOOP

      FOR cur_field IN field_cur(cur_webo.object_id) LOOP

         IF field_cur%ROWCOUNT > 1 THEN
            lv2_retval := NULL;
         ELSE
            lv2_retval := cur_field.field;
         END IF;

      END LOOP;

   END LOOP;

   RETURN lv2_retval;

END getFieldFromWebo;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getFieldFromNode                                                             --
-- Description    :                                                                              --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   : node                                                                         --
--                  commercial_entity                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getFieldFromNode(
   p_object_id well.object_id%TYPE,
   p_daytime DATE)
RETURN field.object_id%TYPE
--</EC-DOC>
IS

lv2_retval field.object_id%TYPE := NULL;

CURSOR node_cur IS
   SELECT cv.field_id field
   FROM node n,
     commercial_entity coent,
     coent_version cv
   WHERE n.commercial_entity_id = coent.object_id
     AND coent.object_id = cv.object_id
     AND p_daytime >= cv.daytime
  AND p_daytime < nvl(cv.end_date, p_daytime+1)
     AND n.well_id = p_object_id
     AND Nvl(n.start_date,p_daytime) <= p_daytime
     AND Nvl(n.end_date, p_daytime+1) > p_daytime;

BEGIN

   FOR cur_node IN node_cur LOOP
      lv2_retval := cur_node.field;
   END LOOP;

   RETURN lv2_retval;
END getFieldFromNode;


FUNCTION getOnStreamHrsByDeferment(
  p_object_id well.object_id%TYPE,
        p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

  -- TODO: Only off events should contribute

  CURSOR cur_activeEvent(p_time DATE) IS
    SELECT daytime, end_date
    FROM well_deferment_event e
    WHERE e.daytime <= p_time
    AND (end_date IS NULL OR end_date > p_time)
    AND e.object_id = p_object_id;

  CURSOR cur_nextEvent(p_time DATE, p_end_date DATE) IS
    SELECT daytime, end_date
    FROM well_deferment_event e
    WHERE e.daytime >= p_time
    AND e.daytime < p_end_date
    AND e.object_id = p_object_id;


  ln_prod_day_offset NUMBER := NULL;
  ld_start_day DATE;
  ld_end_day DATE;
  ld_time_pos DATE;
  ld_event_start DATE;
  ld_event_end DATE;

  ln_onStreamHrs NUMBER;
  lv_estart VARCHAR2(50);
  lv_eend VARCHAR2(50);
  lv_time_pos VARCHAR2(50);

  ln_hours_in_day CONSTANT NUMBER := 24;
  ln_hours_in_production_day NUMBER;


BEGIN

    ln_hours_in_production_day := ecdp_date_time.getNumHours('WELL', p_object_id,p_daytime);
    ln_onStreamHrs := ecdp_date_time.getNumHours('WELL', p_object_id,p_daytime);

    ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id, p_daytime)/ln_hours_in_day;
     ld_start_day := TRUNC(p_daytime) + ln_prod_day_offset;
    ld_end_day := ld_start_day + 1;
    ld_time_pos := ld_start_day;

    while ld_time_pos < ld_end_day
    loop

      lv_time_pos := to_char(ld_time_pos, 'yyyy-mm-dd hh24:mi:ss');
      -- Search for an off event contributing at ld_time_pos
      ld_event_start := NULL;
      ld_event_end := NULL;
      FOR c_activeEvent IN cur_activeEvent (ld_time_pos) LOOP
        ld_event_start := c_activeEvent.daytime;
        ld_event_end := Least(ld_end_day, NVL(c_activeEvent.end_date, ld_end_day));
        lv_estart := to_char(ld_event_start, 'yyyy-mm-dd hh24:mi:ss');
        lv_eend := to_char(ld_event_end, 'yyyy-mm-dd hh24:mi:ss');
      END LOOP;

      IF ld_event_start IS NOT NULL THEN
        -- We have an off event at the time position
--        IF ecdp_date_time.getutc2local_timediff(ld_time_pos) = ecdp_date_time.getutc2local_timediff(ld_event_end) THEN
--           ln_onStreamHrs := ln_onStreamHrs - (ld_event_end - ld_time_pos)*ln_hours_in_production_day;
           ln_onStreamHrs := ln_onStreamHrs - (ld_event_end - ld_time_pos)*24;
--        ELSE
--           ln_onStreamHrs := ln_onStreamHrs - (ld_event_end - ld_time_pos)*ln_hours_in_production_day;
--        END IF;
        ld_time_pos := ld_event_end;
      ELSE
        -- We have a gap -> find when the next event starts
        ld_event_start := ld_end_day;
        FOR c_nextEvent IN cur_nextEvent (ld_time_pos, ld_end_day) LOOP
          IF ld_event_start > c_nextEvent.daytime THEN
            ld_event_start := c_nextEvent.daytime;
            lv_estart := to_char(ld_event_start, 'yyyy-mm-dd hh24:mi:ss');
          END IF;
        END LOOP;
        ld_time_pos := ld_event_start;
      END IF;
    end loop;

  return ln_onStreamHrs;

END getOnStreamHrsByDeferment;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getPwelOnStreamHrs
-- Description    : Calculated the number of hours a production well has been flowing based on
--                  what is specified for the well attribute 'ON_STRM_METHOD'
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getPwelOnStreamHrs(
         p_object_id well.object_id%TYPE,
         p_daytime DATE,
         p_on_strm_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

ln_prod_day_offset NUMBER;
ld_start_day DATE;
ld_end_day DATE;

-- Cursor used for calculating onstream based on ACTIVE_STATUS
CURSOR cur_pwelPeriodSample(p_start_day DATE, p_end_day DATE, cp_num_of_hours NUMBER, cp_pwel_period_prev_daytime DATE) IS
SELECT SUM(Least(Nvl((SELECT min(daytime) from pwel_period_status p2 where p2.object_id=pwel_period_status.object_id
                                         and p2.daytime > pwel_period_status.daytime
                                         and p2.daytime <= p_end_day
                                         and p2.time_span='EVENT'),
        p_end_day), p_end_day) -
        Greatest(daytime, p_start_day))* cp_num_of_hours uptime
FROM pwel_period_status
WHERE object_id = p_object_id
AND daytime BETWEEN Nvl(cp_pwel_period_prev_daytime, p_start_day)
AND p_end_day
AND active_well_status = 'OPEN'
AND time_span='EVENT';

-- Cursor when DEFERMENT_VERSION = 'PD.0001' and 'PD.0002' off event only
CURSOR cur_objectsDefermentEvent(cp_start_day DATE, cp_end_day DATE, cp_object_id varchar2, cp_pwel_period_prev_daytime DATE) IS
SELECT daytime AS ChangeDate, nvl(end_date, cp_end_day) as endDay
  FROM objects_deferment_event
 WHERE object_id = cp_object_id
   AND daytime <= cp_end_day
   AND cp_start_day <= nvl(end_date, cp_start_day)
 UNION ALL
SELECT daytime , Nvl((select min(daytime) from pwel_period_status p2 where p2.object_id=pwel_period_status.object_id
                               and p2.daytime > pwel_period_status.daytime
                               and p2.daytime <= cp_end_day
                               and p2.time_span='EVENT')
                               ,cp_end_day)
 FROM pwel_period_status
 WHERE object_id = cp_object_id
 AND daytime BETWEEN Nvl(cp_pwel_period_prev_daytime, cp_start_day) AND cp_end_day
 AND active_well_status <> 'OPEN'
 AND time_span='EVENT'
 ORDER BY 1;

-- Cursor when DEFERMENT_VERSION = 'PD.0002.02' for event changes
CURSOR cur_objectsOffDefermentEvent(cp_start_day DATE, cp_end_day DATE, cp_object_id varchar2, cp_pwel_period_prev_daytime DATE) IS
SELECT w.daytime AS ChangeDate, nvl(w.end_date, cp_end_day) as endDay
  FROM fcty_deferment_event f, well_deferment_event w
 WHERE f.event_no = w.event_no
   AND f.event_type = 'OFF'
   AND w.object_id = cp_object_id
   AND w.daytime <= cp_end_day
   AND cp_start_day <= nvl(w.end_date, cp_start_day)
 UNION ALL
 SELECT w.daytime AS ChangeDate, nvl(w.end_date, cp_end_day) as endDay
  FROM fcty_deferment_event f, well_deferment_event w
 WHERE f.event_no = w.event_no
   AND f.event_type = 'LOW'
   AND w.object_id = cp_object_id
   AND w.off_indicator = 'Y'
   AND w.daytime <= cp_end_day
   AND cp_start_day <= nvl(w.end_date, cp_start_day)
 UNION ALL
SELECT daytime , Nvl((select min(daytime) from pwel_period_status p2 where p2.object_id=pwel_period_status.object_id
                               and p2.daytime > pwel_period_status.daytime
                               and p2.daytime <= cp_end_day
                               and p2.time_span='EVENT')
                               ,cp_end_day)
 FROM pwel_period_status
 WHERE object_id = cp_object_id
 AND daytime BETWEEN Nvl(cp_pwel_period_prev_daytime, cp_start_day) AND cp_end_day
 AND active_well_status <> 'OPEN'
 AND time_span='EVENT'
 ORDER BY 1;


 -- Cursor when DEFERMENT_VERSION = 'PD.0006' for event changes
CURSOR cur_WellDowntime(cp_start_day DATE, cp_end_day DATE, cp_object_id varchar2, cp_pwel_period_prev_daytime DATE) IS
SELECT w.daytime AS ChangeDate, nvl(w.end_date, cp_end_day) as endDay
  FROM well_equip_downtime w
 WHERE w.downtime_categ = 'WELL_OFF'
   AND w.object_id = cp_object_id
   AND w.daytime <= cp_end_day
   AND cp_start_day <= nvl(w.end_date, cp_start_day)
 UNION ALL
SELECT daytime , Nvl((select min(daytime) from pwel_period_status p2 where p2.object_id=pwel_period_status.object_id
                               and p2.daytime > pwel_period_status.daytime
                               and p2.daytime <= cp_end_day
                               and p2.time_span='EVENT')
                               ,cp_end_day)
 FROM pwel_period_status
 WHERE object_id = cp_object_id
 AND daytime BETWEEN Nvl(cp_pwel_period_prev_daytime, cp_start_day) AND cp_end_day
 AND active_well_status <> 'OPEN'
 AND time_span='EVENT'
 ORDER BY 1;



ll_onStreamHrs         NUMBER;
lv2_on_strm_method     VARCHAR2(32);
lv2_def_version        VARCHAR2(32);
aggregated_indicator   NUMBER := 0;
OffStreamDaytimeStart  DATE;
OffStreamDaytimeEnd    DATE;
OffStreamSession       NUMBER := 0;
ln_num_of_hours        NUMBER := 0;
ld_pwel_period_prev_daytime DATE;
ld_def_start_day       DATE := NULL;
ld_def_end_day         DATE := NULL;

BEGIN

  lv2_on_strm_method := Nvl(p_on_strm_method,
                            nvl(ec_well_version.on_strm_method(p_object_id, p_daytime, '<='), 'MEASURED'));

  IF lv2_on_strm_method = 'MEASURED' THEN
    ll_onStreamHrs := ec_pwel_day_status.on_stream_hrs(p_object_id, p_daytime);

  ELSIF lv2_on_strm_method = 'WELL_ACTIVE_STATUS' THEN

     ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id, p_daytime)/24;
    ld_start_day := TRUNC(p_daytime) + ln_prod_day_offset;
    ld_end_day := ld_start_day + 1;
    ln_num_of_hours := ecdp_date_time.getNumHours('WELL', p_object_id,p_daytime);
    ld_pwel_period_prev_daytime := ec_pwel_period_status.prev_equal_daytime(p_object_id,
                                                                 ld_start_day,
                                                                 'EVENT');

        ll_onStreamHrs := 0;

    FOR c IN cur_pwelPeriodSample(ld_start_day, ld_end_day, ln_num_of_hours, ld_pwel_period_prev_daytime) LOOP
      ll_onStreamHrs := Nvl(c.uptime,0);
    END LOOP;

  ELSIF lv2_on_strm_method = 'DEFERMENT_STATUS' THEN

    ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id, p_daytime)/24;
     ld_start_day := TRUNC(p_daytime) + ln_prod_day_offset;
    ld_end_day := ld_start_day + 1;

        lv2_def_version := ec_ctrl_system_attribute.attribute_text(p_daytime, 'DEFERMENT_VERSION', '<=');
        --lv2_event_overlap_flag := ec_ctrl_system_attribute.attribute_text(p_daytime, 'ALLOW_DUP_PROD_DEF_EVENT', '<=');

        IF (lv2_def_version = 'PD.0001' or lv2_def_version = 'PD.0002') THEN
           ll_onStreamHrs := ecdp_date_time.getNumHours('WELL', p_object_id,p_daytime); --assume maximum on stream hours for a day
           ld_pwel_period_prev_daytime := ec_pwel_period_status.prev_equal_daytime(p_object_id,
                                                                 ld_start_day,
                                                                 'EVENT');

           FOR c IN cur_objectsDefermentEvent (ld_start_day, ld_end_day, p_object_id, ld_pwel_period_prev_daytime) LOOP

              IF ld_def_start_day IS NULL AND ld_def_end_day IS NULL THEN
                ld_def_start_day := c.ChangeDate;
                ld_def_end_day   := c.endDay;

              ELSIF c.ChangeDate <= ld_def_end_day THEN
                ld_def_end_day := GREATEST(ld_def_end_day, c.endDay);

              ELSE
                OffStreamSession := (LEAST(ld_def_end_day,ld_end_day) - GREATEST(ld_def_start_day,ld_start_day))* ecdp_date_time.getNumHours('WELL', p_object_id,p_daytime);
                ll_onStreamHrs := ll_onStreamHrs - OffStreamSession;

                ld_def_start_day := c.ChangeDate;
                ld_def_end_day   := c.endDay;

                OffStreamSession := 0;
              END IF;

           END LOOP;

           IF ld_def_start_day IS NOT NULL THEN
             OffStreamSession := (LEAST(ld_def_end_day,ld_end_day) - GREATEST(ld_def_start_day,ld_start_day))* ecdp_date_time.getNumHours('WELL', p_object_id,p_daytime);
             ll_onStreamHrs := ll_onStreamHrs - OffStreamSession;
           END IF;

           IF ll_onStreamHrs < 0 THEN
             ll_onStreamHrs := 0;
           END IF;

        -- off deferment screen
        ELSIF (lv2_def_version = 'PD.0001.02' or lv2_def_version = 'PD.0002.02') THEN
           ll_onStreamHrs := ecdp_date_time.getNumHours('WELL', p_object_id,p_daytime); --assume maximum on stream hours for a day
           ld_pwel_period_prev_daytime := ec_pwel_period_status.prev_equal_daytime(p_object_id,
                                                                 ld_start_day,
                                                                 'EVENT');

           FOR c IN cur_objectsOffDefermentEvent (ld_start_day, ld_end_day, p_object_id, ld_pwel_period_prev_daytime) LOOP
              IF ld_def_start_day IS NULL AND ld_def_end_day IS NULL THEN
                ld_def_start_day := c.ChangeDate;
                ld_def_end_day   := c.endDay;

              ELSIF c.ChangeDate <= ld_def_end_day THEN
                ld_def_end_day := GREATEST(ld_def_end_day, c.endDay);

              ELSE
                OffStreamSession := (LEAST(ld_def_end_day,ld_end_day) - GREATEST(ld_def_start_day,ld_start_day))* ecdp_date_time.getNumHours('WELL', p_object_id,p_daytime);
                ll_onStreamHrs := ll_onStreamHrs - OffStreamSession;

                ld_def_start_day := c.ChangeDate;
                ld_def_end_day   := c.endDay;

                OffStreamSession := 0;
              END IF;

           END LOOP;

           IF ld_def_start_day IS NOT NULL THEN
             OffStreamSession := (LEAST(ld_def_end_day,ld_end_day) - GREATEST(ld_def_start_day,ld_start_day))* ecdp_date_time.getNumHours('WELL', p_object_id,p_daytime);
             ll_onStreamHrs := ll_onStreamHrs - OffStreamSession;
           END IF;

           IF ll_onStreamHrs < 0 THEN
             ll_onStreamHrs := 0;
           END IF;

      -- Data is registered in Well Downtime screen
        ELSIF (lv2_def_version = 'PD.0006') THEN
           ll_onStreamHrs := ecdp_date_time.getNumHours('WELL', p_object_id,p_daytime); --assume maximum on stream hours for a day
           ld_pwel_period_prev_daytime := ec_pwel_period_status.prev_equal_daytime(p_object_id,
                                                                 ld_start_day,
                                                               'EVENT');

           FOR c IN cur_WellDowntime (ld_start_day, ld_end_day, p_object_id, ld_pwel_period_prev_daytime) LOOP
              IF ld_def_start_day IS NULL AND ld_def_end_day IS NULL THEN
                ld_def_start_day := c.ChangeDate;
                ld_def_end_day   := c.endDay;

              ELSIF c.ChangeDate <= ld_def_end_day THEN
                ld_def_end_day := GREATEST(ld_def_end_day, c.endDay);

              ELSE
                OffStreamSession := (LEAST(ld_def_end_day,ld_end_day) - GREATEST(ld_def_start_day,ld_start_day))* ecdp_date_time.getNumHours('WELL', p_object_id,p_daytime);
                ll_onStreamHrs := ll_onStreamHrs - OffStreamSession;

                ld_def_start_day := c.ChangeDate;
                ld_def_end_day   := c.endDay;

                OffStreamSession := 0;
              END IF;

           END LOOP;

           IF ld_def_start_day IS NOT NULL THEN
             OffStreamSession := (LEAST(ld_def_end_day,ld_end_day) - GREATEST(ld_def_start_day,ld_start_day))* ecdp_date_time.getNumHours('WELL', p_object_id,p_daytime);
             ll_onStreamHrs := ll_onStreamHrs - OffStreamSession;
           END IF;

           IF ll_onStreamHrs < 0 THEN
             ll_onStreamHrs := 0;
           END IF;

    END IF;

  ELSIF (substr(lv2_on_strm_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ll_onStreamHrs := Ue_Well.getPwelOnStreamHrs(p_object_id, p_daytime);

  END IF;

  RETURN ll_onStreamHrs;

END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getIwelOnStreamHrs
-- Description    : Calculated the number of hours a injection well has been flowing based on
--                  what is specified for the well attribute 'ON_STRM_METHOD'
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getIwelOnStreamHrs(
         p_object_id well.object_id%TYPE,
         p_inj_type VARCHAR2,
         p_daytime DATE,
         p_on_strm_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

ld_start_day DATE;
ld_end_day DATE;

-- Cursor used for calculating onstream based on ACTIVE_STATUS
CURSOR cur_iwelPeriodSample(p_start_day DATE, p_end_day DATE, cp_num_of_hours NUMBER, cp_iwel_period_prev_daytime DATE) IS
SELECT SUM(Least(Nvl((SELECT MIN(daytime) FROM iwel_period_status p2 WHERE p2.object_id=iwel_period_status.object_id
            AND p2.daytime > iwel_period_status.daytime
            AND p2.daytime <= p_end_day
            AND p2.inj_type = p_inj_type
            AND p2.time_span='EVENT'),
        p_end_day), p_end_day) -
        Greatest(daytime, p_start_day))* cp_num_of_hours uptime
FROM iwel_period_status
WHERE object_id = p_object_id
AND daytime BETWEEN Nvl(cp_iwel_period_prev_daytime,
                         p_start_day)
AND p_end_day
AND active_well_status = 'OPEN'
AND time_span='EVENT'
AND inj_type = p_inj_type;

-- Cursor when DEFERMENT_VERSION = 'PD.0001' for event changes
CURSOR cur_objectsDefermentEvent(cp_start_day DATE, cp_end_day DATE, cp_object_id varchar2, cp_iwel_period_prev_daytime DATE) IS
SELECT daytime AS ChangeDate, nvl(end_date, cp_end_day) as endDay
  FROM objects_deferment_event
 WHERE object_id = cp_object_id
   AND daytime <= cp_end_day
   AND cp_start_day <= nvl(end_date, cp_start_day)
 UNION ALL
SELECT daytime , Nvl((select min(daytime) from iwel_period_status p2 where p2.object_id=iwel_period_status.object_id
                               and p2.daytime > iwel_period_status.daytime
                               AND p2.inj_type = iwel_period_status.inj_type
                               and p2.daytime <= cp_end_day
                               and p2.time_span='EVENT')
                               ,cp_end_day)
 FROM iwel_period_status
 WHERE object_id = cp_object_id
 AND daytime BETWEEN Nvl(cp_iwel_period_prev_daytime, cp_start_day) AND cp_end_day
 AND inj_type = p_inj_type
 AND active_well_status <> 'OPEN'
 AND time_span='EVENT'
 ORDER BY 1;

-- Cursor when DEFERMENT_VERSION = 'PD.0002.02' for event changes
CURSOR cur_iwelOffDefermentEvent(cp_start_day DATE, cp_end_day DATE, cp_object_id varchar2, cp_iwel_period_prev_daytime DATE) IS
SELECT w.daytime AS ChangeDate, nvl(w.end_date, cp_end_day) as endDay
  FROM fcty_deferment_event f, well_deferment_event w
 WHERE f.event_no = w.event_no
   AND f.event_type = 'OFF'
   AND w.object_id = cp_object_id
   AND w.daytime <= cp_end_day
   AND cp_start_day <= nvl(w.end_date, cp_start_day)
 UNION ALL
SELECT w.daytime AS ChangeDate, nvl(w.end_date, cp_end_day) as endDay
  FROM fcty_deferment_event f, well_deferment_event w
 WHERE f.event_no = w.event_no
   AND f.event_type = 'LOW'
   AND w.object_id = cp_object_id
   AND w.off_indicator = 'Y'
   AND w.daytime <= cp_end_day
   AND cp_start_day <= nvl(w.end_date, cp_start_day)
 UNION ALL
SELECT daytime , Nvl((select min(daytime) from iwel_period_status p2 where p2.object_id=iwel_period_status.object_id
                               and p2.daytime > iwel_period_status.daytime
                               AND p2.inj_type = iwel_period_status.inj_type
                               and p2.daytime <= cp_end_day
                               and p2.time_span='EVENT')
                               ,cp_end_day)
 FROM iwel_period_status
 WHERE object_id = cp_object_id
 AND daytime BETWEEN Nvl(cp_iwel_period_prev_daytime, cp_start_day) AND cp_end_day
 AND inj_type = p_inj_type
 AND active_well_status <> 'OPEN'
 AND time_span='EVENT'
 ORDER BY 1;


-- Cursor when DEFERMENT_VERSION = 'PD.0006' for event changes
CURSOR cur_i_WellDowntime(cp_start_day DATE, cp_end_day DATE, cp_object_id varchar2, cp_iwel_period_prev_daytime DATE) IS
SELECT w.daytime AS ChangeDate, nvl(w.end_date, cp_end_day) as endDay
  FROM well_equip_downtime w
 WHERE w.downtime_categ = 'WELL_OFF'
   AND w.object_id = cp_object_id
   AND w.daytime <= cp_end_day
   AND cp_start_day <= nvl(w.end_date, cp_start_day)
 UNION ALL
SELECT daytime , Nvl((select min(daytime) from iwel_period_status p2 where p2.object_id=iwel_period_status.object_id
                               and p2.daytime > iwel_period_status.daytime
                               AND p2.inj_type = iwel_period_status.inj_type
                               and p2.daytime <= cp_end_day
                               and p2.time_span='EVENT')
                               ,cp_end_day)
 FROM iwel_period_status
 WHERE object_id = cp_object_id
 AND daytime BETWEEN Nvl(cp_iwel_period_prev_daytime, cp_start_day) AND cp_end_day
 AND inj_type = p_inj_type
 AND active_well_status <> 'OPEN'
 AND time_span='EVENT'
 ORDER BY 1;



ll_onStreamHrs         NUMBER;
lv2_on_strm_method     VARCHAR2(32);
lv2_def_version        VARCHAR2(32);
ln_prod_day_offset     NUMBER;
aggregated_indicator   NUMBER := 0;
OffStreamDaytimeStart  DATE;
OffStreamDaytimeEnd    DATE;
OffStreamSession       NUMBER := 0;
ln_num_of_hours        NUMBER := 0;
ld_iwel_period_prev_daytime DATE;
ld_def_start_day       DATE := NULL;
ld_def_end_day         DATE := NULL;

BEGIN

  lv2_on_strm_method := Nvl(p_on_strm_method,
                        nvl(ec_well_version.on_strm_method(p_object_id, p_daytime, '<='), 'MEASURED'));


  IF lv2_on_strm_method = 'MEASURED' THEN
    ll_onStreamHrs := ec_iwel_day_status.on_stream_hrs(p_object_id, p_daytime,p_inj_type);

  ELSIF lv2_on_strm_method = 'WELL_ACTIVE_STATUS' THEN

     ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id, p_daytime)/24;
    ld_start_day := TRUNC(p_daytime) + ln_prod_day_offset;
    ld_end_day := ld_start_day + 1;
        ln_num_of_hours := ecdp_date_time.getNumHours('WELL', p_object_id,p_daytime);
        ld_iwel_period_prev_daytime := ec_iwel_period_status.prev_equal_daytime(p_object_id,
                                                                 ld_start_day,
                                                                 p_inj_type,
                                                                 'EVENT');

        ll_onStreamHrs := 0;

    FOR c IN cur_iwelPeriodSample(ld_start_day, ld_end_day, ln_num_of_hours, ld_iwel_period_prev_daytime) LOOP
      ll_onStreamHrs := Nvl(c.uptime,0);
    END LOOP;


  ELSIF lv2_on_strm_method = 'DEFERMENT_STATUS' THEN

     ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id, p_daytime)/24;
     ld_start_day := TRUNC(p_daytime) + ln_prod_day_offset;
    ld_end_day := ld_start_day + 1;

        lv2_def_version := ec_ctrl_system_attribute.attribute_text(p_daytime, 'DEFERMENT_VERSION', '<=');
        --lv2_event_overlap_flag := ec_ctrl_system_attribute.attribute_text(p_daytime, 'ALLOW_DUP_PROD_DEF_EVENT', '<=');

        IF (lv2_def_version = 'PD.0001' or lv2_def_version = 'PD.0002') THEN
           ll_onStreamHrs := ecdp_date_time.getNumHours('WELL', p_object_id,p_daytime); --assume maximum on stream hours for a day
           ld_iwel_period_prev_daytime :=ec_iwel_period_status.prev_equal_daytime(p_object_id, ld_start_day, p_inj_type, 'EVENT');

           FOR c IN cur_objectsDefermentEvent (ld_start_day, ld_end_day, p_object_id, ld_iwel_period_prev_daytime) LOOP
             IF ld_def_start_day IS NULL AND ld_def_end_day IS NULL THEN
               ld_def_start_day := c.ChangeDate;
               ld_def_end_day   := c.endDay;

             ELSIF c.ChangeDate <= ld_def_end_day THEN
               ld_def_end_day := GREATEST(ld_def_end_day, c.endDay);
             ELSE
                OffStreamSession := (LEAST(ld_def_end_day,ld_end_day) - GREATEST(ld_def_start_day,ld_start_day))* ecdp_date_time.getNumHours('WELL', p_object_id,p_daytime);
                ll_onStreamHrs := ll_onStreamHrs - OffStreamSession;

                ld_def_start_day := c.ChangeDate;
                ld_def_end_day   := c.endDay;

                OffStreamSession := 0;
             END IF;
           END LOOP;

           IF ld_def_start_day IS NOT NULL THEN
             OffStreamSession := (LEAST(ld_def_end_day,ld_end_day) - GREATEST(ld_def_start_day,ld_start_day))* ecdp_date_time.getNumHours('WELL', p_object_id,p_daytime);
             ll_onStreamHrs := ll_onStreamHrs - OffStreamSession;
           END IF;

           IF ll_onStreamHrs < 0 THEN
             ll_onStreamHrs := 0;
           END IF;

        -- off deferment screen
        ELSIF (lv2_def_version = 'PD.0001.02' or lv2_def_version = 'PD.0002.02') THEN
           ll_onStreamHrs := ecdp_date_time.getNumHours('WELL', p_object_id,p_daytime); --assume maximum on stream hours for a day
           ld_iwel_period_prev_daytime :=ec_iwel_period_status.prev_equal_daytime(p_object_id, ld_start_day, p_inj_type, 'EVENT');

           FOR c IN cur_iwelOffDefermentEvent (ld_start_day, ld_end_day, p_object_id, ld_iwel_period_prev_daytime) LOOP
             IF ld_def_start_day IS NULL AND ld_def_end_day IS NULL THEN
               ld_def_start_day := c.ChangeDate;
               ld_def_end_day   := c.endDay;

             ELSIF c.ChangeDate <= ld_def_end_day THEN
               ld_def_end_day := GREATEST(ld_def_end_day, c.endDay);
             ELSE
                OffStreamSession := (LEAST(ld_def_end_day,ld_end_day) - GREATEST(ld_def_start_day,ld_start_day))* ecdp_date_time.getNumHours('WELL', p_object_id,p_daytime);
                ll_onStreamHrs := ll_onStreamHrs - OffStreamSession;

                ld_def_start_day := c.ChangeDate;
                ld_def_end_day   := c.endDay;

                OffStreamSession := 0;
             END IF;
           END LOOP;

           IF ld_def_start_day IS NOT NULL THEN
             OffStreamSession := (LEAST(ld_def_end_day,ld_end_day) - GREATEST(ld_def_start_day,ld_start_day))* ecdp_date_time.getNumHours('WELL', p_object_id,p_daytime);
             ll_onStreamHrs := ll_onStreamHrs - OffStreamSession;
           END IF;

           IF ll_onStreamHrs < 0 THEN
             ll_onStreamHrs := 0;
           END IF;

       --ELSIF lv2_def_version = 'PD.0001.02' THEN
       --    ll_onStreamHrs := getOnStreamHrsByDeferment(p_object_id, p_daytime);

    -- Well Off deferment screen
        ELSIF (lv2_def_version = 'PD.0006') THEN
           ll_onStreamHrs := ecdp_date_time.getNumHours('WELL', p_object_id,p_daytime); --assume maximum on stream hours for a day
           ld_iwel_period_prev_daytime :=ec_iwel_period_status.prev_equal_daytime(p_object_id, ld_start_day, p_inj_type, 'EVENT');

           FOR c IN cur_i_WellDowntime (ld_start_day, ld_end_day, p_object_id, ld_iwel_period_prev_daytime) LOOP
             IF ld_def_start_day IS NULL AND ld_def_end_day IS NULL THEN
               ld_def_start_day := c.ChangeDate;
               ld_def_end_day   := c.endDay;

             ELSIF c.ChangeDate <= ld_def_end_day THEN
               ld_def_end_day := GREATEST(ld_def_end_day, c.endDay);
             ELSE
                OffStreamSession := (LEAST(ld_def_end_day,ld_end_day) - GREATEST(ld_def_start_day,ld_start_day))* ecdp_date_time.getNumHours('WELL', p_object_id,p_daytime);
                ll_onStreamHrs := ll_onStreamHrs - OffStreamSession;

                ld_def_start_day := c.ChangeDate;
                ld_def_end_day   := c.endDay;

                OffStreamSession := 0;
             END IF;
           END LOOP;

           IF ld_def_start_day IS NOT NULL THEN
             OffStreamSession := (LEAST(ld_def_end_day,ld_end_day) - GREATEST(ld_def_start_day,ld_start_day))* ecdp_date_time.getNumHours('WELL', p_object_id,p_daytime);
             ll_onStreamHrs := ll_onStreamHrs - OffStreamSession;
           END IF;

           IF ll_onStreamHrs < 0 THEN
             ll_onStreamHrs := 0;
           END IF;

      END IF;

  ELSIF (substr(lv2_on_strm_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ll_onStreamHrs := Ue_Well.getIwelOnStreamHrs(p_object_id, p_inj_type, p_daytime);

  END IF;
  RETURN ll_onStreamHrs;

END;

FUNCTION isWellProducer(
  p_object_id well.object_id%TYPE,
  p_daytime DATE)
RETURN VARCHAR2
IS

lv2_isProducer VARCHAR2(1);

BEGIN

  lv2_isProducer := ec_well_version.isproducer(p_object_id, p_daytime, '<=');

  RETURN lv2_isProducer;

END isWellProducer;

FUNCTION isWellInjector(
  p_object_id well.object_id%TYPE,
  p_daytime DATE)
RETURN VARCHAR2
IS

lv2_isInjector VARCHAR2(1);

BEGIN

  lv2_isInjector := ec_well_version.isinjector(p_object_id, p_daytime, '<=');

  RETURN lv2_isInjector;

END isWellInjector;


--


FUNCTION getWell(
  p_object_id     well.object_id%TYPE,
  p_daytime  DATE)
RETURN WELL%ROWTYPE
IS

lr_well well%ROWTYPE;

BEGIN

   lr_well := ec_well.row_by_pk(p_object_id);

  RETURN lr_well;

END getWell;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getFacility
-- Description    : Finds the current facilty object connection for a well from the group model.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getFacility(p_object_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2
--</EC-DOC>
IS

BEGIN

   RETURN ec_well_version.op_fcty_class_1_id(p_object_id, p_daytime, '<=');

END getFacility;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getPwelPeriodOnStrmFromStatus
-- Description    : Calculated the number of hours a production well has been flowing within the
--                  period given by p_start_daytime and p_end_daytime from well active status ("OPEN/CLOSE")

--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getPwelPeriodOnStrmFromStatus(
  p_object_id well.object_id%TYPE,
        p_start_daytime DATE,
        p_end_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

ll_onStreamHrs NUMBER;
ld_start_day DATE;
ld_end_day DATE;
lv2_on_strm_method VARCHAR2(32);
ln_num_of_hours        NUMBER := 0;
ld_pwel_period_prev_daytime DATE;

-- Cursor used for calculating onstream based on ACTIVE_STATUS
CURSOR cur_pwelPeriodSample (cp_num_of_hours NUMBER, cp_pwel_period_prev_daytime DATE) IS
SELECT SUM(LEAST(Nvl((SELECT MIN(daytime) FROM pwel_period_status p2 WHERE p2.object_id=pwel_period_status.object_id
                                          AND p2.daytime > pwel_period_status.daytime
                                          AND p2.daytime <= p_end_daytime
                                          AND p2.time_span='EVENT'),p_end_daytime), p_end_daytime)
           - GREATEST(daytime, p_start_daytime))
           * cp_num_of_hours uptime
FROM pwel_period_status
WHERE object_id = p_object_id
AND daytime BETWEEN cp_pwel_period_prev_daytime
AND p_end_daytime
AND active_well_status = 'OPEN'
AND time_span='EVENT';

BEGIN

   ll_onStreamHrs:=0;
   ld_pwel_period_prev_daytime := nvl(ec_pwel_period_status.prev_equal_daytime(p_object_id, p_start_daytime, 'EVENT'),p_start_daytime);
   ln_num_of_hours := ecdp_date_time.getNumHours('WELL', p_object_id,TRUNC(p_start_daytime,'DD'));

   FOR c IN cur_pwelPeriodSample (ln_num_of_hours, ld_pwel_period_prev_daytime) LOOP
     ll_onStreamHrs := Nvl(c.uptime,0);
   END LOOP;


  RETURN ll_onStreamHrs;

END getPwelPeriodOnStrmFromStatus;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getIwelPeriodOnStrmFromStatus
-- Description    : Calculated the number of hours a production well has been flowing within the
--                  period given by p_start_daytime and p_end_daytime from well active status ("OPEN/CLOSE")
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getIwelPeriodOnStrmFromStatus(
  p_object_id well.object_id%TYPE,
  p_inj_type VARCHAR2,
        p_start_daytime DATE,
        p_end_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

ll_onStreamHrs NUMBER;
ld_start_day DATE;
ld_end_day DATE;
lv2_on_strm_method VARCHAR2(32);

-- Cursor used for calculating onstream based on ACTIVE_STATUS
CURSOR cur_iwelPeriodSample (cp_num_of_hours NUMBER, cp_iwel_period_prev_daytime DATE) IS
SELECT SUM(LEAST(Nvl((SELECT MIN(daytime) FROM iwel_period_status p2 WHERE p2.object_id=iwel_period_status.object_id
            AND p2.daytime > iwel_period_status.daytime
            AND p2.daytime <= p_end_daytime
            AND p2.inj_type = p_inj_type
            AND p2.time_span='EVENT'),p_end_daytime), p_end_daytime)
           - GREATEST(daytime, p_start_daytime))
           * cp_num_of_hours  uptime
FROM iwel_period_status
WHERE object_id = p_object_id
AND daytime BETWEEN cp_iwel_period_prev_daytime
                 AND p_end_daytime
AND active_well_status = 'OPEN'
AND inj_type = p_inj_type
AND time_span='EVENT';
ln_num_of_hours        NUMBER := 0;
ld_iwel_period_prev_daytime DATE;

BEGIN

   ll_onStreamHrs:=0;
   ln_num_of_hours := ecdp_date_time.getNumHours('WELL', p_object_id,TRUNC(p_start_daytime,'DD'));
   ld_iwel_period_prev_daytime := nvl(ec_iwel_period_status.prev_equal_daytime(p_object_id,
                                                           p_start_daytime,
                                                           p_inj_type,
                                                           'EVENT'), p_start_daytime);

   FOR c IN cur_iwelPeriodSample (ln_num_of_hours, ld_iwel_period_prev_daytime) LOOP
     ll_onStreamHrs := Nvl(c.uptime,0);
   END LOOP;


  RETURN ll_onStreamHrs;

END getIwelPeriodOnStrmFromStatus;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : biuCheckDate
-- Description    : Check for parent's start date must be before child's start date
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : WELL_BORE, WELL_BORE_INTERVAL
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE biuCheckDate(p_object_start_date DATE,
                       p_parent_object_id VARCHAR2
                       ) IS


lv2_parent_start_date DATE;
BEGIN

IF ec_well.start_date(p_parent_object_id) IS NOT NULL THEN -- finding well start date for well bore
   lv2_parent_start_date := ec_well.start_date(p_parent_object_id);
ELSIF ec_webo_bore.start_date(p_parent_object_id) IS NOT NULL THEN -- finding well bore start date for well bore interval
   lv2_parent_start_date := ec_webo_bore.start_date(p_parent_object_id);
END IF;

IF lv2_parent_start_date > p_object_start_date THEN
   Raise_Application_Error(-20512, 'The child''s start date is before the parent''s start date');
END IF;

END biuCheckDate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getErrorMsg
-- Description    : Create a error message based on class and object name.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getErrorMsg(p_object_id VARCHAR2, p_daytime DATE, p_start_or_end_date VARCHAR2,p_type VARCHAR2)
RETURN VARCHAR2

IS

BEGIN

   IF p_start_or_end_date = 'START_DATE' THEN
      IF p_type IS NOT NULL THEN
         RETURN p_type || ' of Well Bore ' || ecdp_objects.GetObjName(p_object_id,p_daytime) || ' and with daytime ' || to_char(p_daytime, 'YYYY-MM-DD') || ' has a end date that is less than given start date on Well.';
      ELSE
         RETURN ecdp_objects.GetObjClassName(p_object_id) || ' ' || ecdp_objects.GetObjName(p_object_id,p_daytime) || ' has a end date that is less than given start date on Well.';
      END IF;
   ELSIF p_start_or_end_date = 'END_DATE' THEN
      IF p_type IS NOT NULL THEN
         RETURN p_type || ' of Well Bore ' || ecdp_objects.GetObjName(p_object_id,p_daytime) || ' and with daytime ' || to_char(p_daytime, 'YYYY-MM-DD') || ' has a daytime that is higher than given end date on Well.';
      ELSE
         RETURN ecdp_objects.GetObjClassName(p_object_id) || ' ' || ecdp_objects.GetObjName(p_object_id,p_daytime) || ' has a daytime that is higher than given end date on Well.';
      END IF;
   END IF;
END getErrorMsg;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      :  updateStartDateOnChildObjects
-- Description    :  Update start date on child objects and well_hole (parent) when moving start date on well and if start date on childs are
--                   before the new start date for the well.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : WEBO_BORE, WELL_BORE_INTERVAL, WELL_HOLE, PERF_INTERVAL
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE  updateStartDateOnChildObjects(p_object_start_date DATE, p_object_id VARCHAR2) IS

-- check if any of the objects that we will update has end_date less than the new start date
-- If yes then prompt error msg.

CURSOR c_verify_well_hole IS
   SELECT wh.object_id, wh.start_date
   FROM well_hole wh, well w
   WHERE w.well_hole_id = wh.object_id
   AND w.object_id = p_object_id
   AND nvl(wh.end_date,p_object_start_date+1) < p_object_start_date;

CURSOR c_verify_well_bore IS
   SELECT wb.object_id, wb.start_date
   FROM webo_bore wb
   WHERE wb.well_id = p_object_id
   AND nvl(wb.end_date,p_object_start_date+1) < p_object_start_date;

CURSOR c_verify_well_bore_split IS
   SELECT wbs.well_bore_id, wbs.daytime
   FROM webo_split_factor wbs
   WHERE wbs.object_id = p_object_id
   AND nvl(wbs.end_date,p_object_start_date+1) < p_object_start_date;

CURSOR c_verify_well_bore_interval IS
   SELECT wbi.object_id, wbi.start_date
   FROM webo_interval wbi, webo_bore wb
   WHERE wbi.well_bore_id = wb.object_id
   AND wb.well_id = p_object_id
   AND nvl(wbi.end_date,p_object_start_date+1) < p_object_start_date;

CURSOR c_verify_well_bore_int_split IS
   SELECT wbis.object_id, wbis.daytime
   FROM webo_interval wbi,webo_interval_gor wbis, webo_bore wb
   WHERE wbis.object_id = wbi.object_id
   AND wbi.well_bore_id = wb.object_id
   AND wb.well_id = p_object_id
   AND (nvl(wbi.end_date,p_object_start_date+1) < p_object_start_date
   OR nvl(wbis.end_date,p_object_start_date+1) < p_object_start_date);

CURSOR c_verify_perf_interval IS
   SELECT pi.object_id, pi.start_date
   FROM perf_interval pi, webo_interval wbi, webo_bore wb
   WHERE pi.webo_interval_id = wbi.object_id
   AND wbi.well_bore_id = wb.object_id
   AND wb.well_id = p_object_id
   AND nvl(pi.end_date,p_object_start_date+1) < p_object_start_date;

CURSOR c_verify_perf_int_split IS
   SELECT pis.object_id, pis.daytime
   FROM perf_interval pi, perf_interval_gor pis, webo_interval wbi, webo_bore wb
   WHERE pis.object_id = pi.object_id
   AND pi.webo_interval_id = wbi.object_id
   AND wbi.well_bore_id = wb.object_id
   AND wb.well_id = p_object_id
   AND (nvl(pi.end_date,p_object_start_date+1) < p_object_start_date
   OR nvl(pis.end_date,p_object_start_date+1) < p_object_start_date);

BEGIN


     FOR c IN c_verify_well_hole LOOP
         -- Since a parent object's end_date cannot be less than it's child's end_date
         -- and the child's end_date cannot be null when setting it's parent's end_date,
         -- this case will never occur. However, if this rule changes, we would like
         -- to have this check.
         Raise_Application_Error(-20654,getErrorMsg(c.object_id,c.start_date,'START_DATE',null));
     END LOOP;

     FOR c IN c_verify_well_bore LOOP
         Raise_Application_Error(-20655,getErrorMsg(c.object_id,c.start_date,'START_DATE',null));
     END LOOP;

     FOR c IN c_verify_well_bore_split LOOP
         Raise_Application_Error(-20656,getErrorMsg(c.well_bore_id,c.daytime,'START_DATE','Well Bore Split'));
     END LOOP;

     FOR c IN c_verify_well_bore_interval LOOP
         Raise_Application_Error(-20657,getErrorMsg(c.object_id,c.start_date,'START_DATE',null));
     END LOOP;

     FOR c IN c_verify_well_bore_int_split LOOP
         Raise_Application_Error(-20658,getErrorMsg(c.object_id,c.daytime,'START_DATE','Well Bore Interval Split'));
     END LOOP;

     FOR c IN c_verify_perf_interval LOOP
         Raise_Application_Error(-20659,getErrorMsg(c.object_id,c.start_date,'START_DATE',null));
     END LOOP;

     FOR c IN c_verify_perf_int_split LOOP
         Raise_Application_Error(-20660,getErrorMsg(c.object_id,c.daytime,'START_DATE','Perforation Interval Split'));
     END LOOP;

     -- First update main table on Well Bore, start_date before well start date
     UPDATE webo_bore wb SET wb.start_date = p_object_start_date
     WHERE wb.well_id = p_object_id
     AND wb.start_date < p_object_start_date;

     -- Then delete version table on Well Bore, end_date before well start date
     DELETE FROM webo_version wbv
     WHERE wbv.object_id IN
             (SELECT object_id
                FROM webo_bore wb
               WHERE wb.well_id = p_object_id
                 AND wbv.object_id = wb.object_id)
     AND wbv.end_date <= p_object_start_date;

     -- Then update version table on Well Bore, MAX(daytime) before well start date
     UPDATE webo_version wbversion
       SET wbversion.daytime = p_object_start_date
     WHERE EXISTS
     (SELECT 1
              FROM (SELECT wbv.object_id, max(wbv.daytime) daytime
                      FROM webo_version wbv
                     INNER JOIN webo_bore wb
                        ON wbv.object_id = wb.object_id
                     WHERE wb.well_id = p_object_id
                       AND wbv.daytime <= p_object_start_date
                     GROUP BY wbv.object_id) v
             WHERE wbversion.object_id = v.object_id
               AND wbversion.daytime = v.daytime);

    -- Update Well Bore Split, dayime before well start date
      UPDATE webo_split_factor wbs
         SET wbs.daytime = p_object_start_date
       WHERE EXISTS (SELECT 1
                FROM webo_split_factor wbs2, webo_bore wb
               WHERE wbs2.well_bore_id = wb.object_id
                 AND wb.well_id = p_object_id
                 AND wbs2.daytime < p_object_start_date
                 AND wbs.object_id = wbs2.object_id
                 AND wbs.well_bore_id = wbs2.well_bore_id
                 AND wbs.daytime = wbs2.daytime);

     -- Update main table on Well Bore Interval, start_date before well start date
      UPDATE webo_interval wbi
         SET wbi.start_date = p_object_start_date
       WHERE wbi.well_id = p_object_id
         AND wbi.start_date < p_object_start_date;

     --Then delete version table on Well Bore Interval, end_date before well start date
      DELETE FROM webo_interval_version wbiv
       WHERE wbiv.object_id IN
             (SELECT object_id
                FROM webo_interval wbi
               WHERE wbi.well_id = p_object_id
                 AND wbiv.object_id = wbi.object_id)
         AND wbiv.end_date <= p_object_start_date;

     -- Then Update version table on Well Bore Interval, MAX(daytime) before well start date
      UPDATE webo_interval_version wbiversion
         SET wbiversion.daytime = p_object_start_date
       WHERE EXISTS
       (select 1
                FROM (SELECT wbiv.object_id, MAX(wbiv.daytime) daytime
                        FROM webo_interval_version wbiv
                       INNER JOIN webo_interval wbi
                          ON wbiv.object_id = wbi.object_id
                       WHERE wbi.well_id = p_object_id
                         AND wbiv.daytime <= p_object_start_date
                       GROUP BY wbiv.object_id) i
               WHERE wbiversion.object_id = i.object_id
                 AND wbiversion.daytime = i.daytime);

     -- Update Well Bore Interval Split, dayime before well start date
      UPDATE webo_interval_gor wbis
         SET wbis.daytime = p_object_start_date
       WHERE EXISTS (SELECT 1
                FROM webo_interval wbi, webo_interval_gor wbis2
               WHERE wbi.well_id = p_object_id
                 AND wbi.object_id = wbis2.object_id
                 AND wbis.object_id = wbis2.object_id
                 AND wbis.daytime = wbis2.daytime
                 AND wbis2.daytime < p_object_start_date);

     -- Update Main table on Peft Interval
      UPDATE perf_interval pi
         SET pi.start_date = p_object_start_date
       WHERE pi.well_id = p_object_id
         AND pi.start_date < p_object_start_date;

     -- Then Delete version table on Perf Interval, end_date before well start date
      DELETE FROM perf_interval_version piv
       WHERE piv.object_id IN
             (SELECT object_id
                FROM perf_interval pi
               WHERE pi.well_id = p_object_id
                 AND pi.object_id = piv.object_id)
         AND piv.end_date <= p_object_start_date;

     -- Then Update version table on Perf Interval, MAX(daytime) before well start date
      UPDATE perf_interval_version piv
         SET piv.daytime = p_object_start_date
       where exists
       (select 1
                from (select piv2.object_id, max(piv2.daytime) daytime
                        FROM perf_interval_version piv2
                       INNER JOIN perf_interval pi
                          ON piv2.object_id = pi.object_id
                       WHERE pi.well_id = p_object_id
                         AND piv2.daytime <= p_object_start_date
                       group by piv2.object_id) v
               where piv.object_id = v.object_id
                 AND piv.daytime = v.daytime);

     -- Update Perf Interval Split, dayime before well start date
      UPDATE perf_interval_gor pis
         SET pis.daytime = p_object_start_date
       WHERE EXISTS
       (SELECT 1
                FROM perf_interval pi, perf_interval_gor pis2
               WHERE pi.well_id = p_object_id
                 AND pi.object_id = pis2.object_id
                 AND pis.object_id = pis2.object_id
                 AND pis.daytime = pis2.daytime
                 AND pis2.daytime < p_object_start_date);

END updateStartDateOnChildObjects;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      :  updateEndDateOnChildObjects
-- Description    :  Update end date on child objects and well_hole (parent) when moving end date on well
--                   End_dates on attributes in version tables that is null will not be affected.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : WEBO_BORE, WELL_BORE_INTERVAL, WELL_HOLE, PERF_INTERVAL
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE  updateEndDateOnChildObjects(p_object_end_date DATE, p_object_id VARCHAR2) IS

-- Check is there any well hole with start date later than well's end date
-- If yes then prompt error msg.
CURSOR c_verify_well_hole IS
   SELECT wh.object_id, wh.start_date
   FROM well_hole wh, well w
   WHERE w.well_hole_id = wh.object_id
   AND w.object_id = p_object_id
   AND wh.start_date > nvl(p_object_end_date,wh.start_date+1);

-- Check is there any well bore with start date later than well's end date OR well bore with end date later than well's end date
-- If either one equal yes then prompt error msg.
CURSOR c_verify_well_bore IS
   SELECT wbv.object_id, wbv.daytime
   FROM webo_bore wb, webo_version wbv
   WHERE wb.well_id = p_object_id
   AND wb.object_id = wbv.object_id
   AND (wbv.daytime > nvl(p_object_end_date,wbv.daytime+1)
		OR (wb.end_date IS NOT NULL AND wb.end_date > nvl(p_object_end_date,wb.end_date+1)));

-- Check is there any splits with daytime later than well's end date OR splits with end date later than well's end date
-- If either one equal yes then prompt error msg.
CURSOR c_verify_well_bore_split IS
   SELECT wbs.well_bore_id, wbs.daytime
   FROM webo_split_factor wbs, well w
   WHERE wbs.object_id = p_object_id
   AND wbs.object_id = w.object_id
   AND (wbs.daytime > nvl(p_object_end_date,wbs.daytime+1)
		OR (wbs.end_date IS NOT NULL AND wbs.end_date > nvl(p_object_end_date,wbs.end_date+1)));

-- Check is there any well bore interval with start date later than well's end date OR well bore interval with end date later than well's end date
-- If either one equal yes then prompt error msg.
CURSOR c_verify_well_bore_interval IS
   SELECT wbiv.object_id, wbiv.daytime
   FROM webo_interval wbi, webo_interval_version wbiv, webo_bore wb
   WHERE wbi.well_bore_id = wb.object_id
   AND wb.well_id = p_object_id
   AND wbi.object_id = wbiv.object_id
   AND (wbiv.daytime > nvl(p_object_end_date,wbiv.daytime+1)
		OR (wbi.end_date IS NOT NULL AND wbi.end_date > nvl(p_object_end_date,wbi.end_date+1)));

-- Check is there any splits with daytime later than well's end date OR splits with end date later than well's end date
-- If either one equal yes then prompt error msg.
CURSOR c_verify_well_bore_int_split IS
   SELECT wbis.object_id, wbis.daytime
   FROM webo_interval wbi,webo_interval_gor wbis, webo_bore wb
   WHERE wbis.object_id = wbi.object_id
   AND wbi.well_bore_id = wb.object_id
   AND wb.well_id = p_object_id
   AND (wbis.daytime > nvl(p_object_end_date,wbis.daytime+1)
		OR (wbis.end_date IS NOT NULL AND wbis.end_date > nvl(p_object_end_date,wbis.end_date+1)));

-- Check is there any perf interval with daytime later than well's end date OR perf interval with end date later than well's end date
-- If either one equal yes then prompt error msg.
CURSOR c_verify_perf_interval IS
   SELECT piv.object_id, piv.daytime
   FROM perf_interval pi, perf_interval_version piv, webo_interval wbi, webo_bore wb
   WHERE pi.webo_interval_id = wbi.object_id
   AND wbi.well_bore_id = wb.object_id
   AND wb.well_id = p_object_id
   AND pi.object_id = piv.object_id
   AND (piv.daytime > nvl(p_object_end_date,piv.daytime+1)
		OR (pi.end_date IS NOT NULL AND pi.end_date > nvl(p_object_end_date,pi.end_date+1)));

-- Check is there any splits with daytime later than well's end date OR splits with end date later than well's end date
-- If either one equal yes then prompt error msg.
CURSOR c_verify_perf_int_split IS
   SELECT pis.object_id, pis.daytime
   FROM perf_interval pi, perf_interval_gor pis, webo_interval wbi, webo_bore wb
   WHERE pis.object_id = pi.object_id
   AND pi.webo_interval_id = wbi.object_id
   AND wbi.well_bore_id = wb.object_id
   AND wb.well_id = p_object_id
   AND (pis.daytime > nvl(p_object_end_date,pis.daytime+1)
		OR (pis.end_date IS NOT NULL AND pis.end_date > nvl(p_object_end_date,pis.end_date+1)));

BEGIN

     FOR c IN c_verify_well_hole LOOP
         Raise_Application_Error(-20640,getErrorMsg(c.object_id,c.start_date,'END_DATE',null));
     END LOOP;

     FOR c IN c_verify_well_bore LOOP
         Raise_Application_Error(-20640,getErrorMsg(c.object_id,c.daytime,'END_DATE',null));
     END LOOP;

     FOR c IN c_verify_well_bore_split LOOP
         Raise_Application_Error(-20640,getErrorMsg(c.well_bore_id,c.daytime,'END_DATE','Well Bore Split'));
     END LOOP;

     FOR c IN c_verify_well_bore_interval LOOP
         Raise_Application_Error(-20640,getErrorMsg(c.object_id,c.daytime,'END_DATE',null));
     END LOOP;

     FOR c IN c_verify_well_bore_int_split LOOP
         Raise_Application_Error(-20640,getErrorMsg(c.object_id,c.daytime,'END_DATE','Well Bore Interval Split'));
     END LOOP;

     FOR c IN c_verify_perf_interval LOOP
         Raise_Application_Error(-20640,getErrorMsg(c.object_id,c.daytime,'END_DATE',null));
     END LOOP;

     FOR c IN c_verify_perf_int_split LOOP
         Raise_Application_Error(-20640,getErrorMsg(c.object_id,c.daytime,'END_DATE','Perforation Interval Split'));
     END LOOP;

     -- Update main table on Well Bore
     UPDATE webo_bore wb SET wb.end_date = p_object_end_date
     WHERE wb.well_id = p_object_id
	 AND wb.end_date IS NULL;

     --Update version table on Well Bore version
     UPDATE webo_version wbv SET wbv.end_date = p_object_end_date
     WHERE wbv.object_id IN (SELECT object_id FROM webo_bore wb
								WHERE wb.well_id = p_object_id
								AND wb.object_id = wbv.object_id
								AND wbv.end_date IS NULL);

     -- Update Well bore Split
     UPDATE webo_split_factor wbs SET wbs.end_date = p_object_end_date
     WHERE EXISTS (SELECT * FROM webo_bore wb
							WHERE wb.well_id = p_object_id
							AND wbs.well_bore_id = wb.object_id
                            AND wbs.end_date IS NULL);

     -- Update main table on Well Bore Interval
     UPDATE webo_interval wbi SET wbi.end_date = p_object_end_date
     WHERE EXISTS (SELECT * FROM webo_bore wb
							WHERE wb.well_id = p_object_id
							AND wbi.well_bore_id = wb.object_id
							AND wbi.end_date IS NULL);

     --Update main table on Well Bore Interval version
     UPDATE webo_interval_version wbiv SET wbiv.end_date = p_object_end_date
     WHERE wbiv.object_id IN (SELECT wbi.object_id
          FROM webo_interval wbi, webo_bore wb
         WHERE wb.well_id = p_object_id
           AND wbi.well_bore_id = wb.object_id
           AND wbi.object_id = wbiv.object_id
           AND wbiv.end_date IS NULL);

     -- Update Well Bore Interval Split
     UPDATE webo_interval_gor wbis SET wbis.end_date = p_object_end_date
     WHERE EXISTS (SELECT * FROM webo_interval wbi,webo_bore wb
                          WHERE wb.well_id = p_object_id
						  AND wbi.well_bore_id = wb.object_id
                          AND wbi.object_id = wbis.object_id
                          AND wbis.end_date IS NULL);

     -- Update main table on Perforation Interval
     UPDATE perf_interval pi SET pi.end_date = p_object_end_date
     WHERE EXISTS (SELECT * FROM webo_interval wbi, webo_bore wb
                          WHERE wb.well_id = p_object_id
						  AND wbi.well_bore_id = wb.object_id
						  AND pi.webo_interval_id = wbi.object_id
						  AND pi.end_date IS NULL);

     --Update main table on Perforation Interval version
     UPDATE perf_interval_version piv SET piv.end_date = p_object_end_date
     WHERE piv.object_id IN (SELECT pi.object_id
          FROM perf_interval pi, webo_interval wbi, webo_bore wb
         WHERE wb.well_id = p_object_id
           AND wbi.well_bore_id = wb.object_id
           AND pi.webo_interval_id = wbi.object_id
           AND pi.object_id = piv.object_id
           AND piv.end_date IS NULL);

     -- Update Perforation Interval Split
     UPDATE perf_interval_gor pis SET pis.end_date = p_object_end_date
     WHERE EXISTS (SELECT * FROM perf_interval pi, webo_interval wbi, webo_bore wb
                          WHERE wb.well_id = p_object_id
                          AND wbi.well_bore_id = wb.object_id
                          AND pi.webo_interval_id = wbi.object_id
                          AND pi.object_id = pis.object_id
                          AND pis.end_date IS NULL);

END updateEndDateOnChildObjects;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      :  updatDateOnConnectedObjects
-- Description    :  This procedure check if any of the connected objects has more than one version of the attributes
--                   before it calls updateEndDateOnChildObjects and updateStartDateOnChildObjects.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions: updateEndDateOnChildObjects, updateStartDateOnChildObjects
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE  updatDateOnConnectedObjects(p_object_start_date DATE,p_object_end_date DATE, p_object_id VARCHAR2) IS

ld_start_date DATE;
ld_end_date DATE;
lv_well_hole_id well.well_hole_id%TYPE;
lv_valid VARCHAR2(1);

ld_well_hole_start_date     DATE;
ld_well_hole_end_date       DATE;

BEGIN
     --If none of the dates have been changed, then return. Also fetching well_hole_id for use later
     SELECT w.start_date, w.end_date, w.well_hole_id INTO ld_start_date, ld_end_date, lv_well_hole_id FROM well w WHERE w.object_id = p_object_id;
     IF ld_start_date = p_object_start_date AND ((ld_end_date = p_object_end_date) OR (ld_end_date IS NULL AND p_object_end_date IS NULL)) THEN
        RETURN;
     END IF;

     -- We need to check well hole explicit because it is a parent and it can have other child objects than this
     IF lv_well_hole_id IS NOT NULL THEN
        SELECT wh.start_date, wh.end_date INTO ld_well_hole_start_date, ld_well_hole_end_date FROM well_hole wh WHERE wh.object_id = lv_well_hole_id;

        -- If well start date before well hole start date OR well end date after well hole end date then it is not valid
        IF p_object_start_date < ld_well_hole_start_date OR p_object_end_date > ld_well_hole_end_date THEN
          lv_valid := 'N';
        END IF;

        IF lv_valid = 'N' THEN
           Raise_Application_Error(-20654,'Well start date/end date not within well hole start date and end date. Not possible to change date.');
        END IF;
     END IF;

     IF (p_object_end_date IS NULL AND ld_end_date IS NOT NULL) OR (p_object_end_date IS NOT NULL AND ld_end_date IS NULL) OR p_object_end_date <> ld_end_date THEN
        updateEndDateOnChildObjects(p_object_end_date, p_object_id);
     END IF;

     IF ld_start_date <> p_object_start_date THEN
        updateStartDateOnChildObjects(p_object_start_date, p_object_id);
     END IF;

END updatDateOnConnectedObjects;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcOnStrmHrsMonth
-- Description    : calculate how many hours wells have been open based on the Active Well Status
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : system_days, iwel_period_status
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcOnStrmHrsMonth(
  p_object_id well.object_id%TYPE,
  p_inj_type VARCHAR2,
  p_daytime DATE,     --1st day of each month
  p_calc_type VARCHAR2,  -- HOURS or DAYS
  p_on_strm_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER IS

ln_sumdaily_onStreamHrs NUMBER := 0;
ln_count_days NUMBER := 0;
ln_well_ontime  NUMBER := 0;
lv2_on_strm_method well_version.on_strm_method%TYPE;

CURSOR c_getdaysmth(cp_daytime DATE) IS
SELECT daytime FROM system_days   -- return each day from the current month
WHERE daytime >= cp_daytime AND daytime <= LAST_DAY(cp_daytime);

BEGIN

    FOR cur_daysmth IN c_getdaysmth(p_daytime) LOOP

      lv2_on_strm_method := Nvl(p_on_strm_method,
                            Nvl(ec_well_version.on_strm_method(p_object_id, cur_daysmth.daytime, '<='), 'MEASURED'));

      IF (p_inj_type IS NOT NULL AND EcDp_Well.isWellInjector(p_object_id, cur_daysmth.daytime)='Y') THEN
           ln_well_ontime := EcDp_Well.getIwelOnStreamHrs(
                             p_object_id ,
                             p_inj_type ,
                             cur_daysmth.daytime,
                             lv2_on_strm_method);
      ELSIF (p_inj_type IS NULL AND EcDp_Well.isWellProducer(p_object_id, cur_daysmth.daytime)='Y') THEN
           ln_well_ontime := EcDp_Well.getPwelOnStreamHrs(
                             p_object_id ,
                             cur_daysmth.daytime,
                             lv2_on_strm_method);
      END IF;

      IF p_calc_type='HOURS' THEN
           ln_sumdaily_onStreamHrs := ln_sumdaily_onStreamHrs + Nvl(ln_well_ontime,0);
      ELSIF p_calc_type='DAYS' AND Nvl(ln_well_ontime,0) > 0 THEN
           ln_count_days := ln_count_days + 1;
      END IF;

    END LOOP;

    IF p_calc_type='DAYS' THEN
       RETURN ln_count_days;
    ELSIF p_calc_type='HOURS' THEN
       RETURN ln_sumdaily_onStreamHrs;
    END IF;

END  calcOnStrmHrsMonth;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcOnStrmDaysInMonth
-- Description    : calculate how many days it has been injecting based on a system_flag ON_STRM_DAYS_METHOD
--                  which can either be HRS_DIV_24 or DAYS_GREAT_0. This will return either total hours injecting
--                  this month divided by 24 or it will return number of days where the well has on time > 0.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: calcOnStrmHrsMonth
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION calcOnStrmDaysInMonth(
  p_object_id well.object_id%TYPE,
  p_inj_type VARCHAR2,
  p_daytime DATE,
  p_on_strm_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER

IS
lv2_on_strms_day_method ctrl_system_attribute.attribute_text%TYPE;
ln_onStreamDays NUMBER := 0;

BEGIN

   lv2_on_strms_day_method := ec_ctrl_system_attribute.attribute_text(p_daytime,'ON_STRM_DAYS_METHOD','<=');

   IF lv2_on_strms_day_method = 'HRS_DIV_24' THEN
         ln_onStreamDays := (calcOnStrmHrsMonth(p_object_id,p_inj_type,p_daytime,'HOURS', p_on_strm_method))/24;
   END IF;

   IF lv2_on_strms_day_method = 'DAYS_GREAT_0' THEN
         ln_onStreamDays := calcOnStrmHrsMonth(p_object_id,p_inj_type,p_daytime,'DAYS', p_on_strm_method);
   END IF;

   RETURN ln_onStreamDays;

END CalcOnStrmDaysInMonth;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : IsWellOpen
-- Description    : Checks for well active status whether it is open or not.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION IsWellOpen(p_object_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2
IS

BEGIN

   RETURN IsWellActiveStatus(p_object_id, 'OPEN', p_daytime);

END IsWellOpen;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : IsDeferred
-- Description    : Checks for well whether it is deferred or not.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION IsDeferred(p_object_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2
IS

lv2_def_version VARCHAR2(32);
ln_counter NUMBER := 0;
lv2_return VARCHAR2(1);

CURSOR well_pd0001 IS
     SELECT 1
       FROM objects_deferment_event ode
      WHERE object_id = p_object_id
        AND p_daytime BETWEEN ode.daytime AND nvl(ode.end_date, to_date('3045-01-01', 'yyyy-mm-dd'));

CURSOR well_pd0002 IS
    SELECT 1 FROM well_deferment_event
      WHERE object_id=p_object_id
      AND p_daytime >= daytime
      AND p_daytime < NVL(end_date, to_date('3045-01-01', 'yyyy-mm-dd'));

CURSOR well_pd0006 IS
	 SELECT 1
	 FROM well_equip_downtime wed
 	 WHERE wed.object_id = p_object_id
	 AND wed.downtime_categ = 'WELL_OFF' --only off events, not LOW events
	 AND p_daytime BETWEEN wed.daytime AND nvl(wed.end_date, p_daytime+1);

BEGIN

  lv2_def_version := ec_ctrl_system_attribute.attribute_text(p_daytime, 'DEFERMENT_VERSION', '<=');

  IF (lv2_def_version = 'PD.0001' or lv2_def_version = 'PD.0002') THEN

     FOR onerow IN well_pd0001 LOOP
       ln_counter :=1;
       EXIT;
     END LOOP;

  ELSIF (lv2_def_version = 'PD.0001.02' OR lv2_def_version = 'PD.0002.02') THEN
     FOR onerow IN well_pd0002 LOOP
       ln_counter :=1;
       EXIT;
     END LOOP;

  ELSIF lv2_def_version = 'PD.0006'  THEN
     FOR onerow IN well_pd0006 LOOP
       ln_counter :=1;
       EXIT;
     END LOOP;
  END IF;

  IF (ln_counter > 0) THEN
    lv2_return := 'Y';
  ELSE
    lv2_return := 'N';
  END IF;

  RETURN lv2_return;

END IsDeferred;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : IsWellNotClosedLT
-- Description    : Checks for well active status which it is not Closed Long Term
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION IsWellNotClosedLT(p_object_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2
IS

lv2_isNotClosedLT VARCHAR2(1);

BEGIN

  IF IsWellActiveStatus(p_object_id, 'CLOSED_LT', p_daytime) = 'Y' THEN
    lv2_isNotClosedLT := 'N';
  ELSE
    lv2_isNotClosedLT := 'Y';
  END IF;

  RETURN lv2_isNotClosedLT;

END IsWellNotClosedLT;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : IUAllowWellClosedLT
-- Description    : This function allowed to set active_well_status to CLOSED_LT.
--

--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE IUAllowWellClosedLT(p_object_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_status VARCHAR2)
IS

   ld_pd_start     DATE;
   ld_daytime      DATE;
   ld_next_daytime DATE;

BEGIN

   -- Conditions to set well_active_status to LT_CLOSED when insert or update

   IF NVL(p_status, 'OPEN') = 'LT_CLOSED' THEN
      ld_pd_start   := ecdp_productionday.getProductionDayStart('WELL', p_object_id, p_daytime);

      IF p_daytime <> ld_pd_start THEN
         RAISE_APPLICATION_ERROR(-20548, 'Cannot set Active Well Status = Closed LT, daytime is not equal start of production day.');
      END IF;

      ld_daytime := ecdp_productionday.getProductionDay('WELL', p_object_id, p_daytime);
      IF ec_pwel_day_status.count_rows(p_object_id, ld_daytime, ld_daytime) > 0 THEN
         RAISE_APPLICATION_ERROR(-20548, 'Cannot set Active Well Status = Closed LT, daytime is in the past and there exist daily records for the well.');
      END IF;

      ld_next_daytime := ec_pwel_period_status.next_daytime(p_object_id, p_daytime, 'EVENT');
      IF ld_next_daytime <> ld_pd_start THEN
         RAISE_APPLICATION_ERROR(-20549, 'Cannot set Active Well Status = Closed LT when the next record does not have daytime=start of production day.');
      END IF;
   END IF;

END IUAllowWellClosedLT;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : AllowWellClosedLT
-- Description    : This function allowed to set active_well_status to CLOSED_LT.
--

--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE AllowWellClosedLT(p_object_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_status VARCHAR2)
IS

   ld_pd_start     DATE;
   ld_prev_row PWEL_PERIOD_STATUS%ROWTYPE;

BEGIN

   ld_pd_start   := ecdp_productionday.getProductionDayStart('WELL', p_object_id, p_daytime);

   -- Check the daytime is start of production day if the last previous record is LT_CLOSED

   ld_prev_row := ec_pwel_period_status.row_by_rel_operator(p_object_id, p_daytime, 'EVENT','<');
   IF ld_prev_row.active_well_status = 'CLOSED_LT' THEN
      IF p_daytime <> ld_pd_start THEN
         RAISE_APPLICATION_ERROR(-20550, 'New record must be for the beginning of a production day when well has Active Well Status = Closed LT.');
      END IF;
   END IF;

END AllowWellClosedLT;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : DelAllowWellClosedLT
-- Description    : This function allowed record to be deleted.
--

--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE DelAllowWellClosedLT(p_object_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_status VARCHAR2)
IS

   ld_pd_start     DATE;
   ld_next_daytime DATE;
   ld_prev_row PWEL_PERIOD_STATUS%ROWTYPE;

BEGIN

   ld_prev_row := ec_pwel_period_status.row_by_rel_operator(p_object_id, p_daytime, 'EVENT','<');
   ld_next_daytime := ec_pwel_period_status.next_daytime(p_object_id, p_daytime, 'EVENT');
   IF ld_prev_row.active_well_status = 'CLOSED_LT' THEN
      ld_pd_start := Ecdp_Productionday.getProductionDayStart('WELL',p_object_id,ld_next_daytime);
      IF ld_pd_start <> ld_next_daytime THEN
         RAISE_APPLICATION_ERROR(-20551, 'Cannot delete record when previous record has Active Well Status = Closed LT, and the next record does not start on a production day.');
      END IF;
   END IF;

END DelAllowWellClosedLT;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : IUAllowInjWellClosedLT
-- Description    : This function allowed to set active_well_status to CLOSED_LT.
--

--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE IUAllowInjWellClosedLT(p_object_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_status VARCHAR2, p_inj_type VARCHAR2)
IS

   ld_pd_start     DATE;
   ld_daytime      DATE;
   ld_next_daytime DATE;

BEGIN

   -- Conditions to set well_active_status to LT_CLOSED when insert or update

   IF NVL(p_status, 'OPEN') = 'LT_CLOSED' THEN
      ld_pd_start   := ecdp_productionday.getProductionDayStart('WELL', p_object_id, p_daytime);

      IF p_daytime <> ld_pd_start THEN
         RAISE_APPLICATION_ERROR(-20548, 'Cannot set Active Well Status = Closed LT, daytime is not equal start of production day.');
      END IF;

      ld_daytime := ecdp_productionday.getProductionDay('WELL', p_object_id, p_daytime);
      IF ec_iwel_day_status.count_rows(p_object_id, p_inj_type, ld_daytime, ld_daytime) > 0 THEN
         RAISE_APPLICATION_ERROR(-20548, 'Cannot set Active Well Status = Closed LT, daytime is in the past and there exist daily records for the well.');
      END IF;

      ld_next_daytime := ec_iwel_period_status.next_daytime(p_object_id, p_daytime, p_inj_type, 'EVENT');
      IF ld_next_daytime <> ld_pd_start THEN
         RAISE_APPLICATION_ERROR(-20549, 'Cannot set Active Well Status = Closed LT when the next record does not have daytime=start of production day.');
      END IF;
   END IF;

END IUAllowInjWellClosedLT;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : AllowInjWellClosedLT
-- Description    : This function allowed to set active_well_status to CLOSED_LT.
--

--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE AllowInjWellClosedLT(p_object_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_status VARCHAR2, p_inj_type VARCHAR2)
IS

   ld_pd_start     DATE;
   ld_prev_row IWEL_PERIOD_STATUS%ROWTYPE;

BEGIN

   ld_pd_start   := ecdp_productionday.getProductionDayStart('WELL', p_object_id, p_daytime);

   -- Check the daytime is start of production day if the last previous record is LT_CLOSED

   ld_prev_row := ec_iwel_period_status.row_by_rel_operator(p_object_id, p_daytime, p_inj_type, 'EVENT','<');
   IF ld_prev_row.active_well_status = 'CLOSED_LT' THEN
      IF p_daytime <> ld_pd_start THEN
         RAISE_APPLICATION_ERROR(-20550, 'New record must be for the beginning of a production day when well has Active Well Status = Closed LT.');
      END IF;
   END IF;

END AllowInjWellClosedLT;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : DelInjAllowWellClosedLT
-- Description    : This function allowed record to be deleted.
--

--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE DelAllowInjWellClosedLT(p_object_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_status VARCHAR2, p_inj_type VARCHAR2)
IS

   ld_pd_start     DATE;
   ld_next_daytime DATE;
   ld_prev_row IWEL_PERIOD_STATUS%ROWTYPE;

BEGIN

   ld_prev_row := ec_iwel_period_status.row_by_rel_operator(p_object_id, p_daytime, p_inj_type, 'EVENT','<');
   ld_next_daytime := ec_iwel_period_status.next_daytime(p_object_id, p_daytime, p_inj_type, 'EVENT');
   IF ld_prev_row.active_well_status = 'CLOSED_LT' THEN
      ld_pd_start := Ecdp_Productionday.getProductionDayStart('WELL',p_object_id,ld_next_daytime);
      IF ld_pd_start <> ld_next_daytime THEN
         RAISE_APPLICATION_ERROR(-20551, 'Cannot delete record when previous record has Active Well Status = Closed LT, and the next record does not start on a production day.');
      END IF;
   END IF;

END DelAllowInjWellClosedLT;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : IsWellActiveStatus
-- Description    : To check is a well has a certain active well status (OPEN/CLOSED/CLOSED_LT)
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :well_version, iwel_period_status, pwel_period_status
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION IsWellActiveStatus(p_object_id VARCHAR2, p_active_status VARCHAR2, p_daytime DATE)
RETURN VARCHAR2
IS

lv2_active_status VARCHAR2(32);
lv2_default_status VARCHAR2(32);
lv2_isActive VARCHAR2(1);
lr_well_version WELL_VERSION%ROWTYPE;

BEGIN

  lr_well_version := ec_well_version.row_by_pk(p_object_id, p_daytime, '<=');
  lv2_default_status := 'CLOSED';
  lv2_active_status := null;

  -- all phases must be tested if not OPEN. Well is only CLOSED if all phases of the well is CLOSED / CLOSED_LT
  IF p_active_status <> 'OPEN' THEN
    IF (lr_well_version.isGasInjector = 'Y' AND p_active_status = nvl(lv2_active_status,p_active_status)) THEN
       lv2_active_status := nvl(ec_iwel_period_status.active_well_status(p_object_id, p_daytime, 'GI', 'EVENT', '<='), lv2_default_status);
    END IF;
    IF (lr_well_version.isCO2Injector = 'Y' AND p_active_status = nvl(lv2_active_status,p_active_status)) THEN
       lv2_active_status := nvl(ec_iwel_period_status.active_well_status(p_object_id, p_daytime, 'CI', 'EVENT', '<='), lv2_default_status);
    END IF;
    IF (lr_well_version.isWaterInjector = 'Y' AND p_active_status = nvl(lv2_active_status,p_active_status)) THEN
       lv2_active_status := nvl(ec_iwel_period_status.active_well_status(p_object_id, p_daytime, 'WI', 'EVENT', '<='), lv2_default_status);
    END IF;
    IF (lr_well_version.isSteamInjector = 'Y' AND p_active_status = nvl(lv2_active_status,p_active_status)) THEN
       lv2_active_status := nvl(ec_iwel_period_status.active_well_status(p_object_id, p_daytime, 'SI', 'EVENT', '<='), lv2_default_status);
    END IF;
    IF (lr_well_version.isAirInjector = 'Y' AND p_active_status = nvl(lv2_active_status,p_active_status)) THEN
       lv2_active_status := nvl(ec_iwel_period_status.active_well_status(p_object_id, p_daytime, 'AI', 'EVENT', '<='), lv2_default_status);
    END IF;
    IF (lr_well_version.isWasteInjector = 'Y' AND p_active_status = nvl(lv2_active_status,p_active_status)) THEN
       lv2_active_status := nvl(ec_iwel_period_status.active_well_status(p_object_id, p_daytime, 'WA', 'EVENT', '<='), lv2_default_status);
    END IF;
    IF (lr_well_version.isProducerOrOther = 'Y' AND p_active_status = nvl(lv2_active_status,p_active_status)) THEN
       lv2_active_status := nvl(ec_pwel_period_status.active_well_status(p_object_id, p_daytime, 'EVENT', '<='), lv2_default_status);
    END IF;

  ELSE -- its enough that one phase is OPEN
    lv2_active_status := 'CLOSED';
    IF (lr_well_version.isGasInjector = 'Y' AND p_active_status <> nvl(lv2_active_status,p_active_status)) THEN
       lv2_active_status := nvl(ec_iwel_period_status.active_well_status(p_object_id, p_daytime, 'GI', 'EVENT', '<='), lv2_default_status);
    END IF;
    IF (lr_well_version.isCO2Injector = 'Y' AND p_active_status <> nvl(lv2_active_status,p_active_status)) THEN
       lv2_active_status := nvl(ec_iwel_period_status.active_well_status(p_object_id, p_daytime, 'CI', 'EVENT', '<='), lv2_default_status);
    END IF;
    IF (lr_well_version.isWaterInjector = 'Y' AND p_active_status <> nvl(lv2_active_status,p_active_status)) THEN
       lv2_active_status := nvl(ec_iwel_period_status.active_well_status(p_object_id, p_daytime, 'WI', 'EVENT', '<='), lv2_default_status);
    END IF;
    IF (lr_well_version.isSteamInjector = 'Y' AND p_active_status <> nvl(lv2_active_status,p_active_status)) THEN
       lv2_active_status := nvl(ec_iwel_period_status.active_well_status(p_object_id, p_daytime, 'SI', 'EVENT', '<='), lv2_default_status);
    END IF;
    IF (lr_well_version.isAirInjector = 'Y' AND p_active_status <> nvl(lv2_active_status,p_active_status)) THEN
       lv2_active_status := nvl(ec_iwel_period_status.active_well_status(p_object_id, p_daytime, 'AI', 'EVENT', '<='), lv2_default_status);
    END IF;
    IF (lr_well_version.isWasteInjector = 'Y' AND p_active_status <> nvl(lv2_active_status,p_active_status)) THEN
       lv2_active_status
       := nvl(ec_iwel_period_status.active_well_status(p_object_id, p_daytime, 'WA', 'EVENT', '<='), lv2_default_status);
    END IF;
    IF (lr_well_version.isProducerOrOther = 'Y' AND p_active_status <> nvl(lv2_active_status,p_active_status)) THEN
       lv2_active_status := nvl(ec_pwel_period_status.active_well_status(p_object_id, p_daytime, 'EVENT', '<='), lv2_default_status);
    END IF;
  END IF;

  IF lv2_active_status = 'CLOSED' THEN
     IF p_active_status = 'CLOSED' THEN
        lv2_isActive := 'Y';
     ELSE
        lv2_isActive := 'N';
     END IF;

  ELSIF lv2_active_status = 'CLOSED_LT' THEN
      IF (p_active_status = 'CLOSED_LT' OR  p_active_status = 'CLOSED') THEN
        lv2_isActive := 'Y';
     ELSE
        lv2_isActive := 'N';
     END IF;

  ELSIF lv2_active_status = 'OPEN' THEN
     IF p_active_status = lv2_active_status THEN
        lv2_isActive := 'Y';
     ELSE
        lv2_isActive := 'N';
     END IF;
  END IF;

  RETURN lv2_isActive;

END IsWellActiveStatus;

 --<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : IsWellPhaseActiveStatus
-- Description    : Same function as IsWellActiveStatus but for one specific phase.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :well_version, iwel_period_status, pwel_period_status
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION IsWellPhaseActiveStatus(p_object_id VARCHAR2, p_inj_phase VARCHAR2, p_active_status VARCHAR2, p_daytime DATE)
RETURN VARCHAR2
IS

lv2_active_status VARCHAR2(32);
lv2_default_status VARCHAR2(32);
lv2_isActive VARCHAR2(1);
lr_well_version WELL_VERSION%ROWTYPE;

BEGIN

  lr_well_version := ec_well_version.row_by_pk(p_object_id, p_daytime, '<=');
  lv2_default_status := 'CLOSED';
  lv2_active_status := null;

  IF (p_inj_phase = 'GI' AND lr_well_version.isGasInjector = 'Y') THEN
    lv2_active_status := nvl(ec_iwel_period_status.active_well_status(p_object_id, p_daytime, p_inj_phase, 'EVENT', '<='),lv2_default_status);
  ELSIF (p_inj_phase = 'WI' AND lr_well_version.isWaterInjector = 'Y') THEN
    lv2_active_status := nvl(ec_iwel_period_status.active_well_status(p_object_id, p_daytime, p_inj_phase, 'EVENT', '<='),lv2_default_status);
  ELSIF (p_inj_phase = 'SI' AND lr_well_version.isSteamInjector = 'Y') THEN
    lv2_active_status := nvl(ec_iwel_period_status.active_well_status(p_object_id, p_daytime, p_inj_phase, 'EVENT', '<='),lv2_default_status);
  ELSIF (p_inj_phase = 'AI' AND lr_well_version.isAirInjector = 'Y') THEN
    lv2_active_status := nvl(ec_iwel_period_status.active_well_status(p_object_id, p_daytime, p_inj_phase, 'EVENT', '<='),lv2_default_status);
  ELSIF (p_inj_phase = 'CI' AND lr_well_version.isCO2Injector = 'Y') THEN
    lv2_active_status := nvl(ec_iwel_period_status.active_well_status(p_object_id, p_daytime, p_inj_phase, 'EVENT', '<='),lv2_default_status);
  ELSIF (p_inj_phase = 'WA' AND lr_well_version.isWasteInjector = 'Y') THEN
    lv2_active_status := nvl(ec_iwel_period_status.active_well_status(p_object_id, p_daytime, p_inj_phase, 'EVENT', '<='),lv2_default_status);
  ELSIF (p_inj_phase IS NULL AND lr_well_version.isProducerOrOther = 'Y') THEN -- Well is producer or Other and no inj_phase is asked for
    lv2_active_status := nvl(ec_pwel_period_status.active_well_status(p_object_id, p_daytime, 'EVENT', '<='),lv2_default_status);
  END IF;

  IF p_active_status <> 'OPEN' THEN
    IF lv2_active_status IN ('CLOSED', 'CLOSED_LT') THEN
      lv2_isActive := 'Y';
    ELSE
      lv2_isActive := 'N';
    END IF;
  End IF;

  IF p_active_status = 'OPEN' THEN
      IF p_active_status = lv2_active_status THEN
        lv2_isActive := 'Y';
      ELSE
      lv2_isActive := 'N';
      END IF;
  END IF;

  RETURN lv2_isActive;

END IsWellPhaseActiveStatus;
 --<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkOtherSide
-- Description    : To check if another side of the well is Open, then follows the following conditions.
--
-- Preconditions  : Upon inserting or updating record in iwel_period_status
-- Postconditions :
--
-- Using tables   :iwel_period_status
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkOtherSide(
   p_object_id       VARCHAR2,
   p_daytime         DATE,
   p_inj_phase       VARCHAR2,
   p_new_status      VARCHAR2
)
--</EC-DOC>

IS

  CURSOR c_iwel_period_status (cp_object_id VARCHAR2, cp_daytime DATE, cp_inj_phase VARCHAR2) IS
     SELECT *
     FROM iwel_period_status
     WHERE object_id = cp_object_id
     AND inj_type <> cp_inj_phase
     AND daytime =
                (SELECT MAX(daytime)
                 FROM iwel_period_status
                 WHERE object_id = cp_object_id
                 AND inj_type <> cp_inj_phase);

lv_active_status VARCHAR2(32);
ld_date          DATE;
lv_inj_type      VARCHAR2(2);
lv_sql           VARCHAR2(3000);
lv_result        VARCHAR2(4000);
ln_cnt           NUMBER := 0;
lv_prev_status   VARCHAR2(32) := NULL;

BEGIN
  FOR cur_iwel_period_status IN c_iwel_period_status (p_object_id, p_daytime, p_inj_phase) LOOP
   lv_active_status := cur_iwel_period_status.active_well_status;
   ld_date := cur_iwel_period_status.daytime;
   lv_inj_type := cur_iwel_period_status.inj_type;

   --check for the same well with different inj phase on the same date
   SELECT count(*) INTO ln_cnt
   FROM iwel_period_status
   WHERE object_id = p_object_id
   AND inj_type <> p_inj_phase
   AND daytime = p_daytime;

   IF ln_cnt = 0 THEN
   --row does not exist, insert new

    IF p_new_status = 'OPEN' THEN
    --insert new row with status SHUT_IN
      lv_sql := 'INSERT INTO iwel_period_status (object_id,daytime,time_span,summer_time,inj_type,well_status)'||
          'VALUES ('''|| p_object_id ||''',to_date('''||to_char(p_daytime,'yyyy-mm-dd hh24:mi:ss')||''',''yyyy-mm-dd hh24:mi:ss''),''EVENT'',''N'','''|| lv_inj_type ||''',''SHUT_IN'')';

    ELSIF p_new_status = 'CLOSED' THEN
    --insert new row with the previous status of the same well and same inj phase.

      --get the previous status
      SELECT well_status INTO lv_prev_status
      FROM iwel_period_status
      WHERE object_id = p_object_id
      AND inj_type = lv_inj_type
      AND daytime =
        (SELECT MAX(daytime)
         FROM iwel_period_status
         WHERE object_id = p_object_id
         AND inj_type = lv_inj_type
         AND daytime < p_daytime);

      lv_sql := 'INSERT INTO iwel_period_status (object_id,daytime,time_span,summer_time,inj_type,well_status)'||
          'VALUES ('''|| p_object_id ||''',to_date('''||to_char(p_daytime,'yyyy-mm-dd hh24:mi:ss')||''',''yyyy-mm-dd hh24:mi:ss''),''EVENT'',''N'','''|| lv_inj_type ||''','''|| lv_prev_status ||''')';
    END IF;
   ELSIF ln_cnt = 1 THEN
   --row already exist, update status

    IF p_new_status = 'OPEN' THEN
    --update status of the other side as SHUT_IN
      lv_sql := 'UPDATE iwel_period_status SET well_status=''SHUT_IN'''||
           'WHERE object_id= '''|| p_object_id ||''''||
           'AND daytime = to_date('''||to_char(p_daytime,'yyyy-mm-dd hh24:mi:ss')||''',''yyyy-mm-dd hh24:mi:ss'')'||
           'AND inj_type = '''|| lv_inj_type ||'''';
    --ELSE DO NOTHING
    END IF;
   ELSE
    RAISE_APPLICATION_ERROR(-20000,'There are more than 1 row for well with the same inj type and daytime');
   END IF;

   IF lv_sql IS NOT NULL THEN
     lv_result := EcDp_Utilities.executeStatement(lv_sql);

     IF lv_result IS NOT NULL THEN
      RAISE_APPLICATION_ERROR(-20000,'Fail inserting or updating record');
     END IF;
   END IF;
  END LOOP;
END checkOtherSide;

 --<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : deleteOtherSide
-- Description    : To check if another side of the well exist for the same date/time, then follows the following conditions.
--
-- Preconditions  : Upon deleting record in iwel_period_status
-- Postconditions :
--
-- Using tables   :iwel_period_status
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE deleteOtherSide(
   p_object_id       VARCHAR2,
   p_daytime         DATE,
   p_inj_phase       VARCHAR2
)
--</EC-DOC>

IS
ln_count        NUMBER;
lv_sql           VARCHAR2(3000);
lv_result        VARCHAR2(4000);


BEGIN
      SELECT COUNT(*) INTO ln_count FROM iwel_period_status
      WHERE object_id = p_object_id
      AND inj_type <> p_inj_phase
      AND daytime = p_daytime;

      IF ln_count > 0 THEN
       lv_sql := 'DELETE FROM iwel_period_status '||
                 'WHERE object_id = '''|| p_object_id ||''''||
                 'AND daytime = to_date('''||to_char(p_daytime,'yyyy-mm-dd hh24:mi:ss')||''',''yyyy-mm-dd hh24:mi:ss'')'||
                 'AND inj_type <> '''|| p_inj_phase ||'''';

        lv_result := EcDp_Utilities.executeStatement(lv_sql);

        IF lv_result IS NOT NULL THEN
           RAISE_APPLICATION_ERROR(-20000,'Fail inserting new record');
        END IF;
      END IF;

END deleteOtherSide;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : ActivePhases
-- Description    : To check if the well phase is active.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : well_version
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION ActivePhases(p_object_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2
IS
--</EC-DOC>

lv2_active_status VARCHAR2(32);
lr_well_version WELL_VERSION%ROWTYPE;

BEGIN

  lr_well_version := ec_well_version.row_by_pk(p_object_id, p_daytime, '<=');
  lv2_active_status := '/';

  IF lr_well_version.isGasInjector = 'Y' THEN
    IF IsWellPhaseActiveStatus(p_object_id, 'GI', 'OPEN', p_daytime) = 'Y' THEN
      lv2_active_status := lv2_active_status || 'GI/';
    END IF;
  END IF;
  IF lr_well_version.isWaterInjector = 'Y' THEN
    IF IsWellPhaseActiveStatus(p_object_id, 'WI', 'OPEN', p_daytime) = 'Y' THEN
      lv2_active_status := lv2_active_status || 'WI/';
    END IF;
  END IF;
  IF lr_well_version.isSteamInjector = 'Y' THEN
    IF IsWellPhaseActiveStatus(p_object_id, 'SI', 'OPEN', p_daytime) = 'Y' THEN
      lv2_active_status := lv2_active_status || 'SI/';
    END IF;
  END IF;
  IF lr_well_version.isAirInjector = 'Y' THEN
    IF IsWellPhaseActiveStatus(p_object_id, 'AI', 'OPEN', p_daytime) = 'Y' THEN
      lv2_active_status := lv2_active_status || 'AI/';
    END IF;
  END IF;
  IF lr_well_version.isWasteInjector = 'Y' THEN
    IF IsWellPhaseActiveStatus(p_object_id, 'WA', 'OPEN', p_daytime) = 'Y' THEN
      lv2_active_status := lv2_active_status || 'WA/';
    END IF;
  END IF;
  IF lr_well_version.isCO2Injector = 'Y' THEN
    IF IsWellPhaseActiveStatus(p_object_id, 'CI', 'OPEN', p_daytime) = 'Y' THEN
      lv2_active_status := lv2_active_status || 'CI/';
    END IF;
  END IF;
  IF lr_well_version.isProducerOrOther = 'Y' THEN -- Well is producer or Other and no inj_phase is asked for
    IF IsWellPhaseActiveStatus(p_object_id, null, 'OPEN', p_daytime) = 'Y' THEN
      lv2_active_status := lv2_active_status || 'PROD/';
    END IF;
  END IF;

  IF length(lv2_active_status) > 2 THEN
    lv2_active_status := substr(lv2_active_status,2,length(lv2_active_status)-2); -- this takes away the first and last '/'
  ELSE
    lv2_active_status := null;
  END IF;

  RETURN lv2_active_status;

END ActivePhases;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkClosedWellWithinPeriod
-- Description    : check if the well status is closed between daytime and end date of deferment event.
--              Use this function if deferment event has a start date and end date
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : pwel_period_status, iwel_period_status
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION checkClosedWellWithinPeriod(p_object_id VARCHAR2, p_daytime DATE, p_end_date DATE)
RETURN VARCHAR2
IS

ln_result VARCHAR2(1) := 'N';
lv2_well_class VARCHAR2(32);
lv2_well_type VARCHAR2(32);

--check closed well period for injector and producer
CURSOR c_pwel_iwel IS
select 1
  from iwel_period_status t1,
       (select daytime,least(nvl(ec_pwel_period_status.next_daytime(object_id,daytime,'EVENT'),p_end_date),p_end_date) end_date
          from pwel_period_status
         where object_id = p_object_id
           and daytime >= nvl(ec_pwel_period_status.prev_equal_daytime(p_object_id,p_daytime,'EVENT'),p_daytime)
           and daytime < p_end_date
           and Nvl(active_well_status,'OPEN') <> 'OPEN'
         order by daytime) t2
 where t1.object_id = p_object_id
   and t1.daytime >= nvl(ec_iwel_period_status.prev_equal_daytime(p_object_id,p_daytime,inj_type,'EVENT'),p_daytime)
   and t1.daytime <  p_end_date
   and active_well_status <> 'OPEN'
   and ( -- actual check
        t1.daytime between t2.daytime and t2.end_date - 1/86400 or
        least(nvl(ec_iwel_period_status.next_daytime(t1.object_id,t1.daytime,t1.inj_type,'EVENT'),p_end_date))
        between greatest(t2.daytime, p_daytime) + 1/86400 and least(t2.end_date, p_end_date));

--check closed well period for producer
CURSOR c_pwel IS
select daytime,least(nvl(ec_pwel_period_status.next_daytime(object_id,daytime,'EVENT'),p_end_date),p_end_date) end_date
          from pwel_period_status
         where object_id = p_object_id
           and daytime >= nvl(ec_pwel_period_status.prev_equal_daytime(p_object_id,p_daytime,'EVENT'),p_daytime)
           and daytime < p_end_date
           and Nvl(active_well_status,'OPEN') <> 'OPEN'
         order by daytime;

--check closed well period for injector
CURSOR c_iwel IS
select daytime,inj_type,least(nvl(ec_iwel_period_status.next_daytime(object_id, daytime,inj_type,'EVENT'),p_end_date),p_end_date) end_date
          from iwel_period_status
         where object_id = p_object_id
           and daytime >= nvl(ec_iwel_period_status.prev_equal_daytime(p_object_id,p_daytime,inj_type,'EVENT'),p_daytime)
           and daytime < p_end_date
           and Nvl(active_well_status,'OPEN') <> 'OPEN'
         order by daytime;

CURSOR c_iwel_WG_WSI (cp_inj_type_1 VARCHAR2, cp_inj_type_2 VARCHAR2) IS
select 1
  from iwel_period_status t1,
       (select daytime,least(nvl(ec_iwel_period_status.next_daytime(object_id,daytime,inj_type,'EVENT'),p_end_date),p_end_date) end_date
          from iwel_period_status
         where object_id = p_object_id
           and daytime >= nvl(ec_iwel_period_status.prev_equal_daytime(p_object_id,p_daytime,inj_type,'EVENT'),p_daytime)
           and daytime < p_end_date
           and inj_type = cp_inj_type_1
           and Nvl(active_well_status,'OPEN') <> 'OPEN'
         order by daytime) t2
 where t1.object_id = p_object_id
   and t1.daytime >= nvl(ec_iwel_period_status.prev_equal_daytime(p_object_id,p_daytime,inj_type,'EVENT'),p_daytime)
   and t1.daytime < p_end_date
   and t1.inj_type = cp_inj_type_2
   and active_well_status <> 'OPEN'
   and ( -- actual check
        t1.daytime between t2.daytime and t2.end_date - 1/86400 or
        least(nvl(ec_iwel_period_status.next_daytime(t1.object_id,t1.daytime,t1.inj_type,'EVENT'),p_end_date), p_end_date)
        between greatest(t2.daytime, p_daytime) + 1/86400 and least(t2.end_date, p_end_date));

BEGIN

lv2_well_type := ec_well_version.well_type(p_object_id, p_daytime, '<=');
lv2_well_class := getWellClass(p_object_id, p_daytime);

-- check closed well within period if well type is producer or injector or both
IF lv2_well_class = 'I' THEN
  IF lv2_well_type = 'WG' OR lv2_well_type = 'SWG' THEN
    FOR one IN c_iwel_WG_WSI('WI','GI') LOOP
      ln_result := 'Y';
      EXIT;
    END LOOP;
  ELSIF lv2_well_type = 'WSI' THEN
    FOR one IN c_iwel_WG_WSI('WI','SI') LOOP
      ln_result := 'Y';
      EXIT;
    END LOOP;
  ELSE
    FOR one IN c_iwel LOOP
        ln_result := 'Y';
        EXIT;
    END LOOP;
  END IF;
ELSIF lv2_well_class = 'P' THEN
  FOR one IN c_pwel LOOP
    ln_result := 'Y';
    EXIT;
  END LOOP;
ELSIF lv2_well_class = 'PI' THEN
  FOR one IN c_pwel_iwel LOOP
    ln_result := 'Y';
    EXIT;
  END LOOP;
END IF;

RETURN ln_result;

END checkClosedWellWithinPeriod;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getPwelFracToStrmToNode
-- Description    : To get fraction of the day if the wells are flowing to the TO_NODE facility
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : pwel_period_status
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getPwelFracToStrmToNode(p_object_id VARCHAR2, p_stream_id VARCHAR2, p_daytime DATE)
  RETURN NUMBER
--</EC-DOC>
  IS

  CURSOR cur_getFracInWellSwingConn(cp_object_id VARCHAR2, cp_stream_to_node VARCHAR2, cp_start_daytime DATE, cp_end_daytime DATE, cp_prev_daytime DATE) IS
  select a.daytime,
         a.asset_id
  from well_swing_connection a
  where a.object_id = cp_object_id
  and a.asset_id = cp_stream_to_node
  and a.daytime BETWEEN Nvl(cp_prev_daytime, cp_start_daytime) AND cp_end_daytime
  order by a.daytime;

  CURSOR cur_getNextTime(cp_object_id VARCHAR2, cp_start_daytime DATE, cp_end_daytime DATE, cp_St_Swing_daytime DATE, cp_prev_daytime DATE) IS
  select min(a.daytime)
  from well_swing_connection a
  where a.object_id = cp_object_id
  and a.daytime BETWEEN Nvl(cp_prev_daytime, cp_start_daytime) AND cp_end_daytime
  and a.daytime > cp_St_Swing_daytime
  order by a.daytime;

  CURSOR cur_ChkOtherSwing(cp_object_id VARCHAR2, cp_start_daytime DATE, cp_end_daytime DATE, cp_prev_daytime DATE) IS
  select count(a.object_id)
  from well_swing_connection a
  where a.object_id = cp_object_id
  and a.daytime BETWEEN Nvl(cp_prev_daytime, cp_start_daytime) AND cp_end_daytime
  order by a.daytime;

  ln_prod_day_offset    NUMBER;
  ld_start_day          DATE;
  ld_end_day            DATE;
  ld_prev_daytime       DATE;
  lv2_stream_to_node    VARCHAR2(32);
  lv2_daytime           DATE;
  lv2_asset_id          Production_Facility.object_id%type;
  lv2_St_Swing_daytime  DATE;
  lv2_End_Swing_daytime DATE;
  lv2_FracDayTime       NUMBER;
  lv2_TotFracDayTime    NUMBER;
  lv2_found_NextTime    NUMBER;
  lv2_Other_SwingCnt    NUMBER;

BEGIN

  ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL', p_object_id, p_daytime) / 24;
  ld_start_day       := TRUNC(p_daytime) + ln_prod_day_offset;
  ld_end_day         := ld_start_day + 1;
  ld_prev_daytime    := EcDp_Well.prev_equal_daytime(p_object_id, ld_start_day);
  lv2_stream_to_node := ec_strm_version.to_node_id(p_stream_id, p_daytime, '<=');
  lv2_Other_SwingCnt := 0;

  --the stream is not connected to any to_node, then we return all wells (compliant with history)
  IF lv2_stream_to_node IS NULL THEN
    lv2_TotFracDayTime := 1;
  ELSE
    OPEN cur_getFracInWellSwingConn(p_object_id, lv2_stream_to_node, ld_start_day, ld_end_day, ld_prev_daytime);
    LOOP
      FETCH cur_getFracInWellSwingConn INTO lv2_daytime, lv2_asset_id;
      EXIT WHEN cur_getFracInWellSwingConn%NOTFOUND;
      IF cur_getFracInWellSwingConn%ROWCOUNT > 0 THEN
        IF lv2_TotFracDayTime IS NULL THEN -- Initialize at the first time
           lv2_TotFracDayTime := 0;
        END IF;
        lv2_FracDayTime := 0;
        lv2_St_Swing_daytime := lv2_daytime;
        lv2_found_NextTime := 0;
        OPEN cur_getNextTime(p_object_id, ld_start_day, ld_end_day, lv2_St_Swing_daytime, ld_prev_daytime);
        LOOP
          FETCH cur_getNextTime INTO lv2_End_Swing_daytime;
          EXIT WHEN cur_getNextTime%NOTFOUND;
          IF cur_getNextTime%ROWCOUNT > 0 THEN
            IF lv2_St_Swing_daytime < ld_start_day THEN
              lv2_FracDayTime := NVL(lv2_End_Swing_daytime,ld_end_day) - ld_start_day;
            ELSE
              lv2_FracDayTime := NVL(lv2_End_Swing_daytime,ld_end_day) - lv2_St_Swing_daytime;
            END IF;
            lv2_found_NextTime := lv2_found_NextTime + 1;
            IF lv2_found_NextTime = 0 THEN
              lv2_FracDayTime := ld_end_day - lv2_St_Swing_daytime;
            END IF;
          END IF;
        END LOOP;
        CLOSE cur_getNextTime;
        lv2_TotFracDayTime := lv2_TotFracDayTime + lv2_FracDayTime;
        lv2_FracDayTime := 0;
      END IF;
    END LOOP;
    CLOSE cur_getFracInWellSwingConn;
    IF lv2_TotFracDayTime IS NULL THEN
      OPEN cur_ChkOtherSwing(p_object_id, ld_start_day, ld_end_day, ld_prev_daytime);
      LOOP
        FETCH cur_ChkOtherSwing INTO lv2_Other_SwingCnt;
        EXIT WHEN cur_ChkOtherSwing%NOTFOUND;
        IF cur_ChkOtherSwing%ROWCOUNT > 0 THEN
          -- found the Well Object ID has other Swing to different Asset on the same Production Day, it will return zero instead of NULL.
          -- Required by Olav A for ECPD-11535. Commented by Leongwen. 23-Mar-2010
          IF lv2_Other_SwingCnt > 0 THEN
            lv2_TotFracDayTime := 0;
          END IF;
        END IF;
      END LOOP;
      CLOSE cur_ChkOtherSwing;
    END IF;
  END IF;
  RETURN lv2_TotFracDayTime;
END getPwelFracToStrmToNode;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getPwelFlowDirection                                                                  --
-- Description    : Returns the last flow direction of that well               --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   : PWEL_PERIOD_STATUS                                                     --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getPwelFlowDirection(
  p_object_id well.object_id%TYPE,
   p_daytime  DATE)

RETURN VARCHAR2
--</EC-DOC>
IS

lv2_flow_direction VARCHAR2(32);
lv2_return VARCHAR2 (32);

CURSOR cur_flowdirection IS
SELECT flow_direction
FROM   PWEL_PERIOD_STATUS a
WHERE object_id = p_object_id
AND   DAYTIME  = (
  SELECT Max(b.DAYTIME)
  FROM   PWEL_PERIOD_STATUS b
  WHERE  b.object_id = a.object_id
  AND    b.DAYTIME >= p_daytime
        AND    b.DAYTIME < p_daytime+1
        OR     b.DAYTIME <= p_daytime AND b.DAYTIME > p_daytime-1)
ORDER BY object_id;

BEGIN

  FOR mycur IN cur_flowdirection LOOP
      lv2_flow_direction := mycur.flow_direction;
    EXIT;
  END LOOP;
  IF lv2_flow_direction is NULL THEN
        lv2_return := 'PRIMARY';
  ELSE
        lv2_return := lv2_flow_direction;
  END IF;
  RETURN lv2_return;

END getPwelFlowDirection;

FUNCTION prev_equal_daytime(
         p_object_id VARCHAR2,
         p_daytime DATE,
         p_num_rows NUMBER DEFAULT 1)
RETURN DATE IS

  CURSOR c_compute IS
  SELECT daytime
  FROM well_swing_connection
  WHERE object_id = p_object_id
  AND daytime <= p_daytime
  ORDER BY daytime DESC;

ld_return_val DATE := NULL;

BEGIN
   IF p_num_rows >= 1 THEN
      FOR cur_rec IN c_compute LOOP
         ld_return_val := cur_rec.daytime;
         IF c_compute%ROWCOUNT = p_num_rows THEN
            EXIT;
         END IF;
      END LOOP;
   END IF;

   RETURN ld_return_val;

END prev_equal_daytime;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : chkDeferEventWhenWellClosed
-- Description    : This function will validate the insert or update of Well Status when there is no
--                  open-ended deferment or in between an deferment event. Otherwise, system will
--                  alert user with error window and stop the entry.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE chkDeferEventWhenWellClosed(p_action VARCHAR2, p_object_id VARCHAR2, p_daytime DATE, p_well_status VARCHAR2, p_time_span VARCHAR2 DEFAULT NULL, p_summer_time VARCHAR2 DEFAULT NULL, p_inj_type VARCHAR2 DEFAULT NULL)
IS

  lv2_deferment_version       VARCHAR2(32);
  ld_OpenedEventStDate        DATE;
  ld_OpenedEventPrevDate      DATE;
  ld_OpenedEventPrevEndDt     DATE;
  ld_chk_stDate               DATE;
  ld_chk_endDate              DATE;
  ld_nextstatusDate           DATE;
  lv2_activeWellStatus        VARCHAR2(32);
  lv2_CurrWellStatus          VARCHAR2(32);
  lv2_status                  VARCHAR2(32);
  lv2_WellStatus2             VARCHAR2(32);
  lv2_WellStatus3             VARCHAR2(32);
  ld_prevstatusDate           DATE;
  lv2_PrevDelWellStatus       VARCHAR2(32);

  CURSOR c_getCurrPWELStatus(cp_object_id varchar2, cp_daytime DATE, cp_time_span varchar2, cp_summer_time varchar2) IS
  SELECT a.well_status
  FROM pwel_period_status a
  WHERE a.object_id = cp_object_id
  AND a.daytime = cp_daytime
  AND a.time_span = cp_time_span
  AND a.summer_time = cp_summer_time;

  CURSOR c_getCurrIWELStatus(cp_object_id varchar2, cp_daytime DATE, cp_inj_type varchar2, cp_time_span varchar2, cp_summer_time varchar2) IS
  SELECT a.well_status
  FROM iwel_period_status a
  WHERE a.object_id = cp_object_id
  AND a.daytime = cp_daytime
  AND a.inj_type = cp_inj_type
  AND a.time_span = cp_time_span
  AND a.summer_time = cp_summer_time;

  -- To find the Active Well Status from Code Dependency.
  CURSOR c_chkWellStatus(cp_well_status VARCHAR2) IS
  SELECT a.code1
  FROM ctrl_code_dependency a
  WHERE a.dependency_type = 'WHATEVER'
  AND a.code_type1 = 'ACTIVE_WELL_STATUS'
  AND a.code_type2 = 'WELL_STATUS'
  AND a.code2 = cp_well_status;

  -- To find any opened event in PD6 (PD.0006 Well Downtime and Well Constraints records)
  CURSOR c_OpenedEvent(cp_object_id varchar2) IS
  SELECT w.daytime
  FROM well_equip_downtime w
  WHERE w.downtime_categ IN ('WELL_OFF', 'WELL_LOW')
  AND w.object_id = cp_object_id
  AND w.daytime IS NOT NULL
  AND w.end_date IS NULL; -- NULL End date is an Opened Event.

  -- To find the start daytime of previous row in Well Downtime and Well Constraints.
  CURSOR c_getPrevRowWellDT(cp_object_id varchar2, cp_OpenedEventStDate DATE) IS
  SELECT max(x.daytime) as maxDaytime
  FROM well_equip_downtime x
  WHERE x.downtime_categ IN ('WELL_OFF', 'WELL_LOW')
  AND x.object_id = cp_object_id
  AND x.daytime < cp_OpenedEventStDate;

  CURSOR c_getPrevRowEndDate(cp_object_id varchar2, cp_OpenedEventStDate DATE) IS
  SELECT max(x1.end_date) as maxEnd_date
  FROM well_equip_downtime x1
  WHERE x1.downtime_categ IN ('WELL_OFF', 'WELL_LOW')
  AND x1.object_id = cp_object_id
  AND x1.daytime = cp_OpenedEventStDate;

  CURSOR c_getDatesBetween(cp_object_id varchar2, cp_daytime DATE) IS
  SELECT y.daytime, y.end_date
  FROM well_equip_downtime y
  WHERE y.downtime_categ IN ('WELL_OFF', 'WELL_LOW')
  AND y.object_id = cp_object_id
  AND cp_daytime BETWEEN y.daytime AND (y.end_date - 1/86400);
  -- 1/86400 = 1 second.

BEGIN
  lv2_deferment_version := ec_ctrl_system_attribute.attribute_text(p_daytime, 'DEFERMENT_VERSION', '<=');
  IF lv2_deferment_version LIKE 'PD.0001%' THEN
    NULL;
  ELSIF lv2_deferment_version LIKE 'PD.0006%' THEN
    IF p_inj_type IS NULL THEN -- This is being called from Production Well Active Status screen
      FOR cur1 IN c_getCurrPWELStatus(p_object_id, p_daytime, p_time_span, p_summer_time) LOOP
        lv2_CurrWellStatus := cur1.well_status;
      END LOOP;
    ELSE -- This is being called from Injection Well Active Status screen
      FOR cur2 IN c_getCurrIWELStatus(p_object_id, p_daytime, p_inj_type, p_time_span, p_summer_time) LOOP
        lv2_CurrWellStatus := cur2.well_status;
      END LOOP;
    END IF;
    IF NVL(lv2_CurrWellStatus,'!@#') <> p_well_status and p_action IN ('INSERT', 'UPDATE') THEN -- Only perform the following if there is a change on Well Status
      -- get the active well status from code dependency for validation.
      FOR cur3 IN c_chkWellStatus(p_well_status) LOOP
        lv2_activeWellStatus := cur3.code1;
      END LOOP;
      IF lv2_activeWellStatus IN ('CLOSED', 'CLOSED_LT') THEN
        -- get deferment version from ctrl_system_attributes
        FOR cur4 IN c_OpenedEvent(p_object_id) LOOP
          ld_OpenedEventStDate  := cur4.daytime;
        END LOOP;
        IF ld_OpenedEventStDate IS NOT NULL THEN
          FOR cur5 IN c_getPrevRowWellDT(p_object_id, ld_OpenedEventStDate) LOOP
            ld_OpenedEventPrevDate := cur5.maxDaytime;
          END LOOP;
          IF ld_OpenedEventPrevDate IS NULL THEN
            IF p_inj_type IS NULL THEN
              ld_nextstatusDate := ec_pwel_period_status.next_equal_daytime(p_object_id, p_daytime, 'EVENT');
            ELSE
              ld_nextstatusDate := ec_iwel_period_status.next_equal_daytime(p_object_id, p_daytime, p_inj_type, 'EVENT');
            END IF;
            IF ld_nextstatusDate IS NOT NULL THEN
              IF p_inj_type IS NULL THEN
                lv2_status := ec_pwel_period_status.well_status(p_object_id, ld_nextstatusDate, 'EVENT');
              ELSE
                lv2_status := ec_iwel_period_status.well_status(p_object_id, ld_nextstatusDate, p_inj_type, 'EVENT');
              END IF;
              FOR cur6 IN c_chkWellStatus(lv2_status) LOOP
                lv2_WellStatus2 := cur6.code1;
              END LOOP;
              IF lv2_WellStatus2 NOT IN ('OPEN') THEN
                RAISE_APPLICATION_ERROR(-20661, 'Inserting or updating a closed well status record is invalid as there is a deferment event registered for that period.');
              END IF;
            ELSE
              RAISE_APPLICATION_ERROR(-20661, 'Inserting or updating a closed well status record is invalid as there is a deferment event registered for that period.');
            END IF;
          ELSE
            FOR cur7 IN c_getPrevRowEndDate(p_object_id, ld_OpenedEventPrevDate) LOOP
              ld_OpenedEventPrevEndDt := cur7.maxEnd_date;
            END LOOP;
            IF p_daytime > ld_OpenedEventStDate THEN
              RAISE_APPLICATION_ERROR(-20661, 'Inserting or updating a closed well status record is invalid as there is a deferment event registered for that period.');
            ELSIF p_daytime BETWEEN ld_OpenedEventPrevDate and ld_OpenedEventPrevEndDt THEN
              RAISE_APPLICATION_ERROR(-20661, 'Inserting or updating a closed well status record is invalid as there is a deferment event registered for that period.');
            ELSIF p_daytime BETWEEN ld_OpenedEventPrevEndDt and ld_OpenedEventStDate THEN
              RAISE_APPLICATION_ERROR(-20661, 'Inserting or updating a closed well status record is invalid as there is a deferment event registered for that period.');
            END IF;
          END IF;
        END IF;
        -- To check if the Well Status date is set in between the start and end date of an PD.0006 Deferment Event.
        FOR cur8 IN c_getDatesBetween(p_object_id, p_daytime) LOOP
          ld_chk_stDate  := cur8.daytime;
          ld_chk_endDate := cur8.end_date;
        END LOOP;
        IF ld_chk_stDate IS NOT NULL and ld_chk_endDate IS NOT NULL THEN
          RAISE_APPLICATION_ERROR(-20661, 'Inserting or updating a closed well status record is invalid as there is a deferment event registered for that period.');
        END IF;
      END IF;
    ELSIF p_action IN ('DELETE') THEN
      IF p_inj_type IS NULL THEN
        ld_prevstatusDate := ec_pwel_period_status.prev_equal_daytime(p_object_id, (p_daytime - 1/86400), 'EVENT');
        lv2_PrevDelWellStatus := ec_pwel_period_status.well_status(p_object_id, ld_prevstatusDate, 'EVENT');
      ELSE
        ld_prevstatusDate := ec_iwel_period_status.prev_equal_daytime(p_object_id, (p_daytime - 1/86400), p_inj_type, 'EVENT');
        lv2_PrevDelWellStatus := ec_iwel_period_status.well_status(p_object_id, ld_prevstatusDate, p_inj_type, 'EVENT');
      END IF;
      FOR cur9 IN c_chkWellStatus(lv2_PrevDelWellStatus) LOOP
        lv2_WellStatus3 := cur9.code1;
      END LOOP;
      IF lv2_WellStatus3 IN ('CLOSED', 'CLOSED_LT') THEN -- check with the previous row is a closed event.
        FOR cur10 IN c_OpenedEvent(p_object_id) LOOP
          ld_OpenedEventStDate  := cur10.daytime;
        END LOOP;
        IF ld_OpenedEventStDate IS NOT NULL THEN
          RAISE_APPLICATION_ERROR(-20662, 'Deleting an open well status record is invalid as there is a deferment event registered for that period.');
        END IF;
      END IF;
    END IF;
  ELSIF lv2_deferment_version IS NULL THEN
    RAISE_APPLICATION_ERROR(-20663, 'Deferment version was configured with null value in System Attributes screen.');
  END IF;

END chkDeferEventWhenWellClosed;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getPwelEventOnStreamsHrs
-- Description    : Calculated the number of hours a production well has been flowing based on
--                  what is specified for the well attribute 'ON_STRM_METHOD'
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getPwelEventOnStreamsHrs(
         p_object_id well.object_id%TYPE,
         p_daytime DATE,
         p_on_strm_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

ln_prod_day_offset NUMBER;
ld_start_day DATE;
ld_end_day DATE;
ld_start_event DATE;
ld_end_event DATE;

-- Cursor used for calculating onstream based on ACTIVE_STATUS
CURSOR cur_pwelPeriodSample(p_start_day DATE, p_end_day DATE, cp_num_of_hours NUMBER, cp_pwel_period_prev_daytime DATE) IS
SELECT SUM(Least(Nvl((SELECT min(daytime) from pwel_period_status p2 where p2.object_id=pwel_period_status.object_id
                                         and p2.daytime > pwel_period_status.daytime
                                         and p2.daytime <= p_end_day
                                         and p2.time_span='EVENT'),
        p_end_day), p_end_day) -
        Greatest(daytime, p_start_day))* cp_num_of_hours uptime
FROM pwel_period_status
WHERE object_id = p_object_id
AND daytime BETWEEN Nvl(cp_pwel_period_prev_daytime, p_start_day)
AND p_end_day
AND active_well_status = 'OPEN'
AND time_span='EVENT';

-- Cursor when DEFERMENT_VERSION = 'PD.0001' and 'PD.0002' off event only
CURSOR cur_objectsDefermentEvent(cp_start_day DATE, cp_end_day DATE, cp_object_id varchar2, cp_pwel_period_prev_daytime DATE) IS
SELECT daytime AS ChangeDate, nvl(end_date, cp_end_day) as endDay
  FROM objects_deferment_event
 WHERE object_id = cp_object_id
   AND daytime <= cp_end_day
   AND cp_start_day <= nvl(end_date, cp_start_day)
 UNION ALL
SELECT daytime , Nvl((select min(daytime) from pwel_period_status p2 where p2.object_id=pwel_period_status.object_id
                               and p2.daytime > pwel_period_status.daytime
                               and p2.daytime <= cp_end_day
                               and p2.time_span='EVENT')
                               ,cp_end_day)
 FROM pwel_period_status
 WHERE object_id = cp_object_id
 AND daytime BETWEEN Nvl(cp_pwel_period_prev_daytime, cp_start_day) AND cp_end_day
 AND active_well_status <> 'OPEN'
 AND time_span='EVENT'
 ORDER BY 1;

-- Cursor when DEFERMENT_VERSION = 'PD.0002.02' for event changes
CURSOR cur_objectsOffDefermentEvent(cp_start_day DATE, cp_end_day DATE, cp_object_id varchar2, cp_pwel_period_prev_daytime DATE) IS
SELECT w.daytime AS ChangeDate, nvl(w.end_date, cp_end_day) as endDay
  FROM fcty_deferment_event f, well_deferment_event w
 WHERE f.event_no = w.event_no
   AND f.event_type = 'OFF'
   AND w.object_id = cp_object_id
   AND w.daytime <= cp_end_day
   AND cp_start_day <= nvl(w.end_date, cp_start_day)
 UNION ALL
 SELECT w.daytime AS ChangeDate, nvl(w.end_date, cp_end_day) as endDay
  FROM fcty_deferment_event f, well_deferment_event w
 WHERE f.event_no = w.event_no
   AND f.event_type = 'LOW'
   AND w.object_id = cp_object_id
   AND w.off_indicator = 'Y'
   AND w.daytime <= cp_end_day
   AND cp_start_day <= nvl(w.end_date, cp_start_day)
 UNION ALL
SELECT daytime , Nvl((select min(daytime) from pwel_period_status p2 where p2.object_id=pwel_period_status.object_id
                               and p2.daytime > pwel_period_status.daytime
                               and p2.daytime <= cp_end_day
                               and p2.time_span='EVENT')
                               ,cp_end_day)
 FROM pwel_period_status
 WHERE object_id = cp_object_id
 AND daytime BETWEEN Nvl(cp_pwel_period_prev_daytime, cp_start_day) AND cp_end_day
 AND active_well_status <> 'OPEN'
 AND time_span='EVENT'
 ORDER BY 1;


 -- Cursor when DEFERMENT_VERSION = 'PD.0006' for event changes
CURSOR cur_WellDowntime(cp_start_day DATE, cp_end_day DATE, cp_object_id varchar2, cp_pwel_period_prev_daytime DATE) IS
SELECT w.daytime AS ChangeDate, nvl(w.end_date, cp_end_day) as endDay
  FROM well_equip_downtime w
 WHERE w.downtime_categ = 'WELL_OFF'
   AND w.object_id = cp_object_id
   AND w.daytime <= cp_end_day
   AND cp_start_day <= nvl(w.end_date, cp_start_day)
 UNION ALL
SELECT daytime , Nvl((select min(daytime) from pwel_period_status p2 where p2.object_id=pwel_period_status.object_id
                               and p2.daytime > pwel_period_status.daytime
                               and p2.daytime <= cp_end_day
                               and p2.time_span='EVENT')
                               ,cp_end_day)
 FROM pwel_period_status
 WHERE object_id = cp_object_id
 AND daytime BETWEEN Nvl(cp_pwel_period_prev_daytime, cp_start_day) AND cp_end_day
 AND active_well_status <> 'OPEN'
 AND time_span='EVENT'
 ORDER BY 1;



ll_onStreamHrs         NUMBER;
lv2_on_strm_method     VARCHAR2(32);
lv2_def_version        VARCHAR2(32);
aggregated_indicator   NUMBER := 0;
OffStreamDaytimeStart  DATE;
OffStreamDaytimeEnd    DATE;
OffStreamSession       NUMBER := 0;
ln_num_of_hours        NUMBER := 0;
ld_pwel_period_prev_daytime DATE;
ld_def_start_day       DATE := NULL;
ld_def_end_day         DATE := NULL;

BEGIN

  lv2_on_strm_method := Nvl(p_on_strm_method,
                            nvl(ec_well_version.on_strm_method(p_object_id, p_daytime, '<='), 'MEASURED'));

  IF lv2_on_strm_method = 'WELL_ACTIVE_STATUS' THEN

    ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id, p_daytime)/24;
    ld_start_day := TRUNC(p_daytime) + ln_prod_day_offset;
    ld_end_day := ld_start_day + 1;

    ld_start_event := nvl(EcDp_Well_Event.getLastWellEventSingleDaytime(p_object_id, p_daytime), ld_start_day);
    ld_end_event := nvl(EcDp_Well_Event.getNextWellEventSingleDaytime(p_object_id, p_daytime), ld_end_day);

    ln_num_of_hours := ecdp_date_time.getNumHours('WELL', p_object_id,p_daytime);
    ld_pwel_period_prev_daytime := ec_pwel_period_status.prev_equal_daytime(p_object_id,
                                                                 ld_start_event,
                                                                 'EVENT');

    ll_onStreamHrs := 0;

    FOR c IN cur_pwelPeriodSample(ld_start_event, ld_end_event, ln_num_of_hours, ld_pwel_period_prev_daytime) LOOP
      ll_onStreamHrs := Nvl(c.uptime,0);
    END LOOP;

  ELSIF lv2_on_strm_method = 'DEFERMENT_STATUS' THEN

    ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_object_id, p_daytime)/24;
     ld_start_day := TRUNC(p_daytime) + ln_prod_day_offset;
    ld_end_day := ld_start_day + 1;

        lv2_def_version := ec_ctrl_system_attribute.attribute_text(p_daytime, 'DEFERMENT_VERSION', '<=');
        --lv2_event_overlap_flag := ec_ctrl_system_attribute.attribute_text(p_daytime, 'ALLOW_DUP_PROD_DEF_EVENT', '<=');

        IF (lv2_def_version = 'PD.0001' or lv2_def_version = 'PD.0002') THEN
           ll_onStreamHrs := ecdp_date_time.getNumHours('WELL', p_object_id,p_daytime); --assume maximum on stream hours for a day
           ld_pwel_period_prev_daytime := ec_pwel_period_status.prev_equal_daytime(p_object_id,
                                                                 ld_start_day,
                                                                 'EVENT');

           FOR c IN cur_objectsDefermentEvent (ld_start_day, ld_end_day, p_object_id, ld_pwel_period_prev_daytime) LOOP

              IF ld_def_start_day IS NULL AND ld_def_end_day IS NULL THEN
                ld_def_start_day := c.ChangeDate;
                ld_def_end_day   := c.endDay;

              ELSIF c.ChangeDate <= ld_def_end_day THEN
                ld_def_end_day := GREATEST(ld_def_end_day, c.endDay);

              ELSE
                OffStreamSession := (LEAST(ld_def_end_day,ld_end_day) - GREATEST(ld_def_start_day,ld_start_day))* ecdp_date_time.getNumHours('WELL', p_object_id,p_daytime);
                ll_onStreamHrs := ll_onStreamHrs - OffStreamSession;

                ld_def_start_day := c.ChangeDate;
                ld_def_end_day   := c.endDay;

                OffStreamSession := 0;
              END IF;

           END LOOP;

           IF ld_def_start_day IS NOT NULL THEN
             OffStreamSession := (LEAST(ld_def_end_day,ld_end_day) - GREATEST(ld_def_start_day,ld_start_day))* ecdp_date_time.getNumHours('WELL', p_object_id,p_daytime);
             ll_onStreamHrs := ll_onStreamHrs - OffStreamSession;
           END IF;

           IF ll_onStreamHrs < 0 THEN
             ll_onStreamHrs := 0;
           END IF;

        -- off deferment screen
        ELSIF (lv2_def_version = 'PD.0001.02' or lv2_def_version = 'PD.0002.02') THEN
           ll_onStreamHrs := ecdp_date_time.getNumHours('WELL', p_object_id,p_daytime); --assume maximum on stream hours for a day
           ld_pwel_period_prev_daytime := ec_pwel_period_status.prev_equal_daytime(p_object_id,
                                                                 ld_start_day,
                                                                 'EVENT');

           FOR c IN cur_objectsOffDefermentEvent (ld_start_day, ld_end_day, p_object_id, ld_pwel_period_prev_daytime) LOOP
              IF ld_def_start_day IS NULL AND ld_def_end_day IS NULL THEN
                ld_def_start_day := c.ChangeDate;
                ld_def_end_day   := c.endDay;

              ELSIF c.ChangeDate <= ld_def_end_day THEN
                ld_def_end_day := GREATEST(ld_def_end_day, c.endDay);

              ELSE
                OffStreamSession := (LEAST(ld_def_end_day,ld_end_day) - GREATEST(ld_def_start_day,ld_start_day))* ecdp_date_time.getNumHours('WELL', p_object_id,p_daytime);
                ll_onStreamHrs := ll_onStreamHrs - OffStreamSession;

                ld_def_start_day := c.ChangeDate;
                ld_def_end_day   := c.endDay;

                OffStreamSession := 0;
              END IF;

           END LOOP;

           IF ld_def_start_day IS NOT NULL THEN
             OffStreamSession := (LEAST(ld_def_end_day,ld_end_day) - GREATEST(ld_def_start_day,ld_start_day))* ecdp_date_time.getNumHours('WELL', p_object_id,p_daytime);
             ll_onStreamHrs := ll_onStreamHrs - OffStreamSession;
           END IF;

           IF ll_onStreamHrs < 0 THEN
             ll_onStreamHrs := 0;
           END IF;

      -- Data is registered in Well Downtime screen
        ELSIF (lv2_def_version = 'PD.0006') THEN

           ld_start_event := nvl(EcDp_Well_Event.getLastWellEventSingleDaytime(p_object_id, p_daytime), ld_start_day);

            if ld_start_event < ld_start_day then
               ld_start_event := ld_start_day;
            end if;

            ld_end_event := nvl(EcDp_Well_Event.getNextWellEventSingleDaytime(p_object_id, p_daytime), ld_end_day);

           --ll_onStreamHrs := ecdp_date_time.getNumHours('WELL', p_object_id,p_daytime); --assume maximum on stream hours for a day
           ll_onStreamHrs := (ld_end_event - ld_start_event)*ecdp_date_time.getNumHours('WELL', p_object_id,p_daytime);
           ld_pwel_period_prev_daytime := ec_pwel_period_status.prev_equal_daytime(p_object_id,
                                                                 ld_start_event,
                                                               'EVENT');

           FOR c IN cur_WellDowntime (ld_start_event, ld_end_event, p_object_id, ld_pwel_period_prev_daytime) LOOP
              IF ld_def_start_day IS NULL AND ld_def_end_day IS NULL THEN
                ld_def_start_day := c.ChangeDate;
                ld_def_end_day   := c.endDay;

              ELSIF c.ChangeDate <= ld_def_end_day THEN
                ld_def_end_day := GREATEST(ld_def_end_day, c.endDay);

              ELSE
                OffStreamSession := (LEAST(ld_def_end_day,ld_end_event) - GREATEST(ld_def_start_day,ld_start_event))* ecdp_date_time.getNumHours('WELL', p_object_id,p_daytime);
                ll_onStreamHrs := ll_onStreamHrs - OffStreamSession;

                ld_def_start_day := c.ChangeDate;
                ld_def_end_day   := c.endDay;

                OffStreamSession := 0;
              END IF;

           END LOOP;

           IF ld_def_start_day IS NOT NULL THEN
             OffStreamSession := (LEAST(ld_def_end_day,ld_end_event) - GREATEST(ld_def_start_day,ld_start_event))* ecdp_date_time.getNumHours('WELL', p_object_id,p_daytime);
             ll_onStreamHrs := ll_onStreamHrs - OffStreamSession;
           END IF;

           IF ll_onStreamHrs < 0 THEN
             ll_onStreamHrs := 0;
           END IF;

    END IF;

  ELSIF (substr(lv2_on_strm_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ll_onStreamHrs := Ue_Well.getPwelOnStreamHrs(p_object_id, p_daytime);

  END IF;

  RETURN ll_onStreamHrs;

END getPwelEventOnStreamsHrs;

END EcDp_Well;