CREATE OR REPLACE PACKAGE BODY EcBp_Deferment_Event IS
/****************************************************************
** Package        :  EcBp_Deferment_Event
**
** $Revision: 1.56 $
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
** 17.01.2006 DN       Bug fixes in procedure checkDefermentEventLock.
** 06.06.2006 AV       Changed resolution of productionday for new Deferment cases
** 12.07.2007 SIAH     Added loadSummaryEvents
** 12.09.2007 rajarsar ECPD-6264:Updated allocateGroupRateToWells
** 21.11.2007 LIZ      new functions verifyDeferment,approveDeferment,copyNewRec,SumDailyDeferredQty
** 15.01.2008 LIZ      new functions SumPeriodDeferredQty
** 15.02.2008 kaurrjes ECPD-6544: Modified procedure loadSummaryEvents.
** 05.03.2008 kaurrjes ECPD-7785: Modified procedure copyNewRec.
** 18.04.2008 leeeewei ECPD-8201: Set ln_part to 0 if current potential is 0 in procedure allocateGroupRateToWells
** 29.05.2008 leeeewei ECPD-7281: Added procedure compareLowAndPotentialRate
** 27.06.2008 farhaann ECPD-8939: Updated ORA number for error messages
** 25.11.2008 oonnnng  ECPD-6067: Added local month lock checking in checkDefermentEventLock function.
** 17.02.2009 leongsei ECPD-6067: Modified function checkDefermentEventLock, to add extra parameter p_local_lock_level when calling function localWithinLockedMonth
**                                Modified function checkDefermentEventLock, to add p_object_id when calling EcDp_Month_Lock.validatePeriodForLockOverlap, EcDp_Month_Lock.checkUpdateEventForLock
** 17.03.2009 lauuufus ECPD-11238: Under procedure compareLowAndPotentialRate -
**                                 Remove default value for Potential Rate in cursor and re-structure the codes to re-use same error message
** 10.04.2009 leongsei ECPD-6067: Modified function allocateGroupRateToWells for lock checking
** 20.04.2009 oonnnng  ECPD-6067: Removed some lines in checkDefermentEventLock() function.
** 23.04.2009 leongsei ECPD-6067: Modified function copyNewRec to add lock checking
** 25.05.2009 leongsei ECPD-11700: Added procedure checkPeriodDefertCalcLock for monthly locking
** 29.08.2011 rajarsar ECPD-17050: Updated allocateGroupRateToWells to ensure correct allocation of rates for phase which is open when a well is a producer and injector.
** 24.10.2011 rajarsar ECPD-18545: Added getPlannedVolumes, getActualVolumes, getActualProducedVolumes and getAssignedDeferVolumes.
** 18.06.2012 Leongwen ECPD-20245: Added calcDeferments and calcDefermentForAsset.
** 24.08.2012 limmmchu ECPD-21639: Modified calcDefermentForAsset to support journal update.
** 29.11.2012 makkkkam ECPD-22231: Modified calcDefermentForAsset: Moved REV_NO to the right place so that correct values to get journaled. Added Nvl(EcDp_Context.getAppUser,USER) to get right user.
** 10.09.2013 limmmchu ECPD-21436: Modified copyNewRec to insert by using generic column
** 08.10.2014 sohalran ECPD-27402: Remove Commit statement from calcDefermentForAsset procedure.
** 17.04.2015 dhavaalo ECPD-29587: Modified calcDefermentForAsset to include month lock check.
** 09.06.2017 khatrnit ECPD-45823: Modified getPlannedVolumes to add logic for FORECAST_PROD plan method
** 18.07.2017 kashisag ECPD-45817: Replaced sysdate with Ecdp_Timestamp.getCurrentSysdate
** 16.10.2017 bintjnor ECPD-47324: Updated cursor c_wells in calcDeferments to include multiple well versions within the period
** 21.10.2017 Leongwen ECPD-49613: Added function deduct1secondYn for deferment day java pre-save class use.
** 30.10.2017 bintjnor ECPD-44006: Updated cursor c_start_end_dates in calcDefermentForAsset to correctly calculate deferments when end_date is empty.
** 13.12.2017 singishi ECPD-51137: Removed procedure/function: checkDefermentEventLock, allocateGroupRateToWells, checkIfEventExists, checkIfAffectedWellsOverlap, verifyDeferment, approveDeferment, copyNewRec, SumDailyDeferredQty, SumPeriodDeferredQty, compareLowAndPotentialRate,getPlannedVolumes, getActualProducedVolumes, getAssignedDeferVolumes,calcDeferments,calcDefermentForAsset,CalcDeferredActionVolume,VerifyActions
** 12.02.2018 leongwen ECPD-52636: Moved function deduct1secondYn to package EcBp_Deferment.
*****************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetCurrentAction
-- Description    : Get last action for the given event.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
---------------------------------------------------------------------------------------------------
FUNCTION GetCurrentAction(p_event_no  NUMBER)
RETURN VARCHAR2
--</EC-DOC>
IS

   CURSOR c_action IS
    SELECT *
    FROM deferment_corr_action
    WHERE event_no = p_event_no
    AND daytime =
     (SELECT MAX(daytime)
      FROM deferment_corr_action
      WHERE event_no = p_event_no);

   lv_return  deferment_corr_action.action%TYPE;

BEGIN

   FOR curAction IN c_action LOOP
      lv_return := curAction.action;
   END LOOP;

   RETURN lv_return;

END GetCurrentAction;


PROCEDURE loadSummaryEvents (
   p_deferment_event_no      NUMBER,
   p_old_end_date            DATE DEFAULT NULL
)
IS

   lr_deferment_event  Def_Day_Deferment_Event%ROWTYPE;
   tmpvar                  NUMBER;
   ln_def_oil_vol          NUMBER;
   ln_def_gas_vol          NUMBER;
   ln_def_water_inj_vol    NUMBER;
   ln_def_cond_vol         NUMBER;
   ln_def_gas_inj_vol      NUMBER;
   ln_def_water_vol        NUMBER;
   ln_def_steam_inj_vol    NUMBER;
   ln_def_oil_mass         NUMBER;
   ln_def_gas_mass         NUMBER;
   ln_def_water_inj_mass   NUMBER;
   ln_def_gas_inj_mass     NUMBER;
   ln_def_water_mass       NUMBER;
   ln_def_cond_mass        NUMBER;
   ln_def_steam_inj_mass   NUMBER;
   ln_def_gas_energy       NUMBER;
   ln_durationformula      NUMBER;

   ln_initialdayduration   NUMBER;
   ln_summarydayduration   NUMBER;
   ln_current_rec_date     DATE;
   ln_summaryenddate       DATE;
   ln_production_day       DATE;
   ln_sysdate              DATE;
   ld_def_summary_daytime  DATE;
   ld_new_summary_daytime  DATE;

BEGIN

   lr_deferment_event := ec_def_day_deferment_event.row_by_pk(p_deferment_event_no);

  -- To get the Production day the event belongs to.
  IF ecdp_objects.GetObjClassName(lr_deferment_event.defer_level_object_id) = 'SUB_AREA' THEN
    ld_def_summary_daytime := EcDp_ProductionDay.getProductionDay('EC_DEFAULT', lr_deferment_event.defer_level_object_id, lr_deferment_event.daytime);
  ELSE
    ld_def_summary_daytime := EcDp_ProductionDay.getProductionDay(NULL,lr_deferment_event.defer_level_object_id, lr_deferment_event.daytime);
  END IF;

   ln_initialdayduration := ecdp_defer_master_event.calcduration(p_deferment_event_no,ld_def_summary_daytime);

   -- Iniatialize ln_current_rec_date to production day function of daytime + 1
   IF p_old_end_date IS NULL THEN -- insert new deferment record
      ln_current_rec_date := ld_def_summary_daytime + 1;
   ELSE
      IF p_old_end_date < lr_deferment_event.end_date THEN -- update end_date

        IF ecdp_objects.GetObjClassName(lr_deferment_event.defer_level_object_id) = 'SUB_AREA' THEN
          ld_new_summary_daytime := EcDp_ProductionDay.getProductionDay('EC_DEFAULT', lr_deferment_event.defer_level_object_id, p_old_end_date);
        ELSE
          ld_new_summary_daytime := EcDp_ProductionDay.getProductionDay(NULL,lr_deferment_event.defer_level_object_id, lr_deferment_event.daytime);
        END IF;
         ln_current_rec_date := ld_new_summary_daytime;
      END IF;
   END IF;

   -- Set production date function of sysdate
   ln_sysdate := trunc(Ecdp_Timestamp.getCurrentSysdate);

   -- For losses that are still open and those which are future dated,create summary event
   -- till current date else create summary events till deferment end date .
   IF lr_deferment_event.end_date IS NULL THEN
      ln_summaryenddate := ln_sysdate - 1;
   ELSE
      IF lr_deferment_event.end_date < ln_sysdate THEN
         ln_summaryenddate := lr_deferment_event.end_date;
      ELSE
         ln_summaryenddate := ln_sysdate - 1;
      END IF;
   END IF;

   WHILE ln_current_rec_date < ln_summaryenddate + 1 LOOP

   	  -- Calculate current day (ln_current_rec_date) duration.
      ln_production_day := trunc(ln_current_rec_date);
	    ln_summarydayduration := ecdp_defer_master_event.calcduration(p_deferment_event_no,ln_production_day);

      IF ln_initialdayduration > 0 AND ln_summarydayduration > 0 THEN

      	-- Calculating volumes of Oil,gas,water and condensation lost for current date
	-- based on first day loss and current day duration.
         ln_durationformula := ln_summarydayduration / ln_initialdayduration;

         ln_def_oil_vol := lr_deferment_event.initial_def_oil_vol * ln_durationformula;
         ln_def_gas_vol := lr_deferment_event.initial_def_gas_vol * ln_durationformula;
         ln_def_water_inj_vol := lr_deferment_event.initial_def_water_inj_vol * ln_durationformula;
         ln_def_gas_inj_vol := lr_deferment_event.initial_def_gas_inj_vol * ln_durationformula;
         ln_def_cond_vol := lr_deferment_event.initial_def_cond_vol * ln_durationformula;
         ln_def_water_vol := lr_deferment_event.initial_def_water_vol * ln_durationformula;
         ln_def_steam_inj_vol := lr_deferment_event.initial_def_steam_inj_vol * ln_durationformula;
         ln_def_oil_mass := lr_deferment_event.initial_def_oil_mass * ln_durationformula;
         ln_def_gas_mass := lr_deferment_event.initial_def_gas_mass * ln_durationformula;
         ln_def_water_inj_mass := lr_deferment_event.initial_def_wat_inj_mass * ln_durationformula;
         ln_def_gas_inj_mass := lr_deferment_event.initial_def_gas_inj_mass * ln_durationformula;
         ln_def_water_mass := lr_deferment_event.initial_def_water_mass * ln_durationformula;
         ln_def_cond_mass := lr_deferment_event.initial_def_cond_mass * ln_durationformula;
         ln_def_steam_inj_mass := lr_deferment_event.initial_def_stm_inj_mass * ln_durationformula;
         ln_def_gas_energy := lr_deferment_event.initial_def_gas_energy * ln_durationformula;

         BEGIN
           INSERT INTO DEF_DAY_SUMMARY_EVENT
           (defer_level_object_id, daytime, deferment_event_no, def_oil_vol, def_gas_vol, def_water_inj_vol, def_gas_inj_vol, def_water_vol, def_cond_vol, def_steam_inj_vol, def_oil_mass, def_gas_mass, def_water_inj_mass, def_gas_inj_mass, def_water_mass, def_cond_mass, def_steam_inj_mass, def_gas_energy)
           VALUES (lr_deferment_event.defer_level_object_id,ln_current_rec_date, p_deferment_event_no, ln_def_oil_vol, ln_def_gas_vol,ln_def_water_inj_vol, ln_def_gas_inj_vol, ln_def_water_vol, ln_def_cond_vol,ln_def_steam_inj_vol, ln_def_oil_mass, ln_def_gas_mass, ln_def_water_inj_mass, ln_def_gas_inj_mass, ln_def_water_mass, ln_def_cond_mass, ln_def_steam_inj_mass, ln_def_gas_energy);
         EXCEPTION
         WHEN OTHERS THEN
         NULL;
         END;
    END IF;
      ln_current_rec_date := ln_current_rec_date + 1;
   END LOOP;
END loadSummaryEvents;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkPeriodDeferCalcLock
-- Description    : Checks whether a deferment record affects a locked month.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions: EcDp_Month_Lock.buildIdentifierString,
--                  EcDp_Month_Lock.validatePeriodForLockOverlap,
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkPeriodDeferCalcLock(p_operation VARCHAR2, p_new_lock_columns  IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list)
--</EC-DOC>
IS

  ld_new_daytime DATE;
  ld_old_daytime DATE;
  lv2_o_obj_id       VARCHAR2(32);
  lv2_n_obj_id       VARCHAR2(32);
  lv2_id VARCHAR2(2000);

BEGIN

  ld_new_daytime := p_new_lock_columns('DAYTIME').column_data.AccessDate;
  ld_old_daytime := p_old_lock_columns('DAYTIME').column_data.AccessDate;

  IF p_new_lock_columns.EXISTS('OBJECT_ID')  THEN
    lv2_n_obj_id := p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
    lv2_o_obj_id := p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
  END IF;

  lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

  EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_new_daytime, ld_new_daytime, lv2_id, lv2_n_obj_id);

END checkPeriodDeferCalcLock;

END EcBp_Deferment_Event;