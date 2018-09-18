CREATE OR REPLACE PACKAGE BODY EcBp_Deferment_Event IS
/****************************************************************
** Package        :  EcBp_Deferment_Event
**
** $Revision: 1.50.2.6 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to deferment.
**
** Documentation  :  www.energy-components.com
**
** Created  : 23.12.2005  Dagfinn Nj?
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
** 18.06.2012 Leongwen ECPD-21351: Added calcDeferments and calcDefermentForAsset.
** 24.08.2012 limmmchu ECPD-21855: Modified calcDefermentForAsset to support journal update.
** 29.11.2012 makkkkam ECPD-22727: Modified calcDefermentForAsset: Moved REV_NO to the right place so that correct values to get journaled. Added Nvl(EcDp_Context.getAppUser,USER) to get right user.
** 11.09.2013 limmmchu ECPD-25367: Modified copyNewRec to insert by using generic column
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkDefermentEventLock
-- Description    : Checks whether a deferment event record affects a locked month.
--
--
-- Preconditions  : If the class does not have a DAYTIME and END_DATE columns it should not use this procedure
--                  We have tried to make this procedure as general as possible covering known cases, but if you
--                  start using it for a new class, you have to make sure that it does what you want, if not extend it
--                  or create your own.
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions: EcDp_Facility.getParentFacility,
--                  EcDp_Facility.getProductionDayOffset,
--                  EcDp_Month_Lock.checkUpdateEventForLock,
--                  EcDp_Month_Lock.buildIdentifierString,
--                  EcDp_Month_Lock.checkIfColumnsUpdated,
--                  EcDp_Month_Lock.validatePeriodForLockOverlap
--                  ec_objects_event, ec_objects_deferment_event, ec_objects_event_raw
-- Configuration
-- required       :
--
-- Behavior       : Dates will be adjusted for production day.
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkDefermentEventLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list)
--</EC-DOC>
IS

ld_new_daytime DATE;
ld_old_daytime DATE;
ld_new_end_date DATE;
ld_old_end_date DATE;
ln_parent_event_id NUMBER;
lv2_id VARCHAR2(2000);
lv2_columns_updated VARCHAR2(1);
lv2_fcty_id production_facility.object_id%TYPE;
ln_prod_day_offset NUMBER;
lv2_table_name VARCHAR2(64);

--lr_parent_objects_event objects_event%ROWTYPE;
--lr_parent_objects_event_raw objects_event_raw%ROWTYPE;
lr_parent_deferment_event objects_deferment_event%ROWTYPE;

lv2_asset_id VARCHAR2(100);
lv2_object_class_name VARCHAR2(100);
lv2_o_obj_id                  VARCHAR2(32);
lv2_n_obj_id                  VARCHAR2(32);
lv2_class_name                VARCHAR2(32);
lv2_parent_object_id          VARCHAR2(32);
lv2_local_lock                VARCHAR2(32);

BEGIN

   ld_new_daytime := p_new_lock_columns('DAYTIME').column_data.AccessDate;
   ld_old_daytime := p_old_lock_columns('DAYTIME').column_data.AccessDate;

   ld_new_end_date := p_new_lock_columns('END_DATE').column_data.AccessDate;
   ld_old_end_date := p_old_lock_columns('END_DATE').column_data.AccessDate;

   IF p_operation = 'DELETING' THEN

     -- There are a few classes that have both Object_id (Facility) and Asset_id, where these in theory can belong to different production day
     -- but in those cases we have selected to go with the Facilities production day definition. (Not that this will make much of a difference in a locking content).
     -- therefore we first check for the existence of an object_id in the given attribute list.

      IF p_old_lock_columns.exists('OBJECT_ID') THEN
         lv2_asset_id := p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
         lv2_object_class_name := ecdp_objects.GetObjClassName(lv2_asset_id);

      ELSIF p_old_lock_columns.exists('WELL_ID') THEN
         lv2_asset_id := p_old_lock_columns('WELL_ID').column_data.AccessVarchar2;
         lv2_object_class_name := 'WELL';

      ELSIF p_old_lock_columns.exists('ASSET_ID') THEN
         lv2_asset_id := p_old_lock_columns('ASSET_ID').column_data.AccessVarchar2;
         lv2_object_class_name := p_old_lock_columns('ASSET_TYPE').column_data.AccessVarchar2;

      ELSIF p_old_lock_columns.exists('EVENT_NO') THEN
         lv2_asset_id := ec_fcty_deferment_event.object_id(p_old_lock_columns('EVENT_NO').column_data.AccessNumber);
         lv2_object_class_name := ecdp_objects.GetObjClassName(lv2_asset_id);

      END IF;

      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset(lv2_object_class_name,lv2_asset_id, ld_old_daytime)/24;
      lv2_table_name := p_old_lock_columns('TABLE_NAME').column_name;

      IF p_old_lock_columns.exists('PARENT_EVENT_ID') THEN

         ln_parent_event_id := p_old_lock_columns('PARENT_EVENT_ID').column_data.AccessNumber;

      END IF;

   ELSE


      IF p_new_lock_columns.exists('OBJECT_ID') THEN
         lv2_asset_id := p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
         lv2_object_class_name := ecdp_objects.GetObjClassName(lv2_asset_id);

      ELSIF p_new_lock_columns.exists('WELL_ID') THEN
         lv2_asset_id := p_new_lock_columns('WELL_ID').column_data.AccessVarchar2;
         lv2_object_class_name := 'WELL';

      ELSIF p_new_lock_columns.exists('ASSET_ID') THEN
         lv2_asset_id := p_new_lock_columns('ASSET_ID').column_data.AccessVarchar2;
         lv2_object_class_name := p_new_lock_columns('ASSET_TYPE').column_data.AccessVarchar2;

      ELSIF p_old_lock_columns.exists('EVENT_NO') THEN
         lv2_asset_id := ec_fcty_deferment_event.object_id(p_new_lock_columns('EVENT_NO').column_data.AccessNumber);
         lv2_object_class_name := ecdp_objects.GetObjClassName(lv2_asset_id);

      END IF;


      ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset(lv2_object_class_name,lv2_asset_id, ld_new_daytime)/24;

      lv2_table_name := p_new_lock_columns('TABLE_NAME').column_name;

      IF p_new_lock_columns.exists('PARENT_EVENT_ID') THEN

         ln_parent_event_id := p_new_lock_columns('PARENT_EVENT_ID').column_data.AccessNumber;

      END IF;

   END IF;

   ld_new_daytime := ld_new_daytime - ln_prod_day_offset;
   ld_old_daytime := ld_old_daytime - ln_prod_day_offset;

   ld_new_end_date := ld_new_end_date - ln_prod_day_offset;
   ld_old_end_date := ld_old_end_date - ln_prod_day_offset;

   IF p_operation = 'INSERTING' THEN

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_new_daytime, ld_new_end_date, lv2_id, lv2_asset_id);

   ELSIF p_operation = 'UPDATING' THEN

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

      p_old_lock_columns('DAYTIME').is_checked := 'Y';
      p_old_lock_columns('END_DATE').is_checked := 'Y';

      IF EcDp_Month_Lock.checkIfColumnsUpdated(p_old_lock_columns) THEN
         lv2_columns_updated := 'Y';
      ELSE
         lv2_columns_updated := 'N';
      END IF;

      EcDp_Month_Lock.checkUpdateEventForLock(ld_new_daytime,
                                              ld_old_daytime,
                                              ld_new_end_date,
                                              ld_old_end_date,
                                              lv2_columns_updated,
                                              lv2_id,
                                              lv2_asset_id);

   ELSIF p_operation = 'DELETING' THEN

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_old_lock_columns);

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_old_daytime, ld_old_end_date, lv2_id, lv2_asset_id);

   END IF;

   -- Check any associated parent record

   IF ln_parent_event_id IS NOT NULL THEN


      IF lv2_table_name = 'OBJECTS_DEFERMENT_EVENT' THEN

         lr_parent_deferment_event := ec_objects_deferment_event.row_by_pk(ln_parent_event_id);
         ld_old_daytime := lr_parent_deferment_event.daytime - ln_prod_day_offset;
         ld_old_end_date := lr_parent_deferment_event.end_date - ln_prod_day_offset;


           -- TODO: Add logic for FCTY_DEFERMENT_EVENT
      END IF;

      -- Consider as update on the parent record without changing dates.
      EcDp_Month_Lock.checkUpdateEventForLock(ld_old_daytime,
                                              ld_old_daytime,
                                              ld_old_end_date,
                                              ld_old_end_date,
                                              'N',
                                              lv2_id,
                                              lv2_asset_id);

   END IF;

END checkDefermentEventLock;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : allocateGroupRateToWells
-- Description    : Allocates the group event deferment rate to all affected wells.
--                  Note that the algorithm used does not use effective time for the affected wells.
--                  The variation of potentials over time are not evaluated.
--
--
-- Preconditions  : Only the affected wells having a potential method will get a deferment rate allocated.
--
-- Postconditions : The deferred rates of the affected wells are updated.
--
-- Using tables   : FCTY_DEFERMENT_EVENT, WELL_DEFERMENT_EVENT
--
--
--
-- Using functions:
--           ecbp_well_potential.findOilProductionPotential(aw.object_id, aw.daytime) as OilProductionPotential,
--           ecbp_well_potential.findGasProductionPotential(aw.object_id, aw.daytime) as GasProductionPotential,
--           ecbp_well_potential.findWatProductionPotential(aw.object_id, aw.daytime) as WatProductionPotential,
--           ecbp_well_potential.findConProductionPotential(aw.object_id, aw.daytime) as ConProductionPotential,
--           ecbp_well_potential.findDiluentPotential(aw.object_id, aw.daytime) as DiluentPotential,
--           ecbp_well_potential.findGasLiftPotential(aw.object_id, aw.daytime) as GasLiftPotential,
--           ecbp_well_potential.findGasInjectionPotential(aw.object_id, aw.daytime) as GasInjectionPotential,
--           ecbp_well_potential.findWatInjectionPotential(aw.object_id, aw.daytime) as WatInjectionPotential,
--           ecbp_well_potential.findSteamInjectionPotential(aw.object_id, aw.daytime) as SteamInjectionPotential
--
-- Configuration
-- required       : The affected wells should have potential methods.
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE allocateGroupRateToWells(p_eventNo NUMBER)
--</EC-DOC>
IS

  CURSOR c_event IS
    SELECT * from fcty_deferment_event e where e.event_no = p_eventNo;

  CURSOR c_potential_total IS

    SELECT sum(OilProductionPotential)  as TotalOilProductionPotential,
           sum(GasProductionPotential)  as TotalGasProductionPotential,
           sum(WatProductionPotential)  as TotalWatProductionPotential,
           sum(ConProductionPotential)  as TotalConProductionPotential,
           sum(DiluentPotential)        as TotalDiluentPotential,
           sum(GasLiftPotential)        as TotalGasLiftPotential,
           sum(GasInjectionPotential)   as TotalGasInjectionPotential,
           sum(WatInjectionPotential)   as TotalWatInjectionPotential,
           sum(SteamInjectionPotential) as TotalSteamInjectionPotential,
           sum(OilMassProdPotential)    as TotalOilMassProdPotential,
           sum(GasMassProdPotential)    as TotalGasMassProdPotential,
           sum(WatMassProdPotential)    as TotalWatMassProdPotential,
           sum(ConMassProdPotential)    as TotalConMassProdPotential
    FROM (
      SELECT aw.event_no, aw.object_id, aw.daytime,
           ecbp_well_potential.findOilProductionPotential(aw.object_id, aw.day) as OilProductionPotential,
           ecbp_well_potential.findGasProductionPotential(aw.object_id, aw.day) as GasProductionPotential,
           ecbp_well_potential.findWatProductionPotential(aw.object_id, aw.day) as WatProductionPotential,
           ecbp_well_potential.findConProductionPotential(aw.object_id, aw.day) as ConProductionPotential,
           ecbp_well_potential.findDiluentPotential(aw.object_id, aw.day) as DiluentPotential,
           ecbp_well_potential.findGasLiftPotential(aw.object_id, aw.day) as GasLiftPotential,
           ecbp_well_potential.findGasInjectionPotential(aw.object_id, aw.day) as GasInjectionPotential,
           ecbp_well_potential.findWatInjectionPotential(aw.object_id, aw.daytime) as WatInjectionPotential,
           ecbp_well_potential.findSteamInjectionPotential(aw.object_id, aw.daytime) as SteamInjectionPotential,
           ecbp_well_potential.findOilMassProdPotential(aw.object_id, aw.day) as OilMassProdPotential,
           ecbp_well_potential.findGasMassProdPotential(aw.object_id, aw.day) as GasMassProdPotential,
           ecbp_well_potential.findWaterMassProdPotential(aw.object_id, aw.day) as WatMassProdPotential,
           ecbp_well_potential.findCondMassProdPotential(aw.object_id, aw.day) as ConMassProdPotential
      FROM well_deferment_event aw
      WHERE aw.event_no = p_eventNo
    );

  CURSOR c_potential IS
    SELECT aw.wde_no, aw.event_no, aw.object_id, aw.daytime, aw.end_date,
           ecbp_well_potential.findOilProductionPotential(aw.object_id, aw.day) as OilProductionPotential,
           ecbp_well_potential.findGasProductionPotential(aw.object_id, aw.day) as GasProductionPotential,
           ecbp_well_potential.findWatProductionPotential(aw.object_id, aw.day) as WatProductionPotential,
           ecbp_well_potential.findConProductionPotential(aw.object_id, aw.day) as ConProductionPotential,
           ecbp_well_potential.findDiluentPotential(aw.object_id, aw.day)       as DiluentPotential,
           ecbp_well_potential.findGasLiftPotential(aw.object_id, aw.day)       as GasLiftPotential,
           ecbp_well_potential.findGasInjectionPotential(aw.object_id, aw.day)  as GasInjectionPotential,
           ecbp_well_potential.findWatInjectionPotential(aw.object_id, aw.daytime)  as WatInjectionPotential,
           ecbp_well_potential.findSteamInjectionPotential(aw.object_id, aw.daytime) as SteamInjectionPotential,
           ecbp_well_potential.findOilMassProdPotential(aw.object_id, aw.day) as OilMassProdPotential,
           ecbp_well_potential.findGasMassProdPotential(aw.object_id, aw.day) as GasMassProdPotential,
           ecbp_well_potential.findWaterMassProdPotential(aw.object_id, aw.day) as WatMassProdPotential,
           ecbp_well_potential.findCondMassProdPotential(aw.object_id, aw.day) as ConMassProdPotential
    FROM well_deferment_event aw
    WHERE aw.event_no = p_eventNo;

  CURSOR c_getProdWellActiveStatus (cp_object_id VARCHAR2, cp_daytime DATE) IS
    SELECT pwel_period_status.well_status,
           EcDp_System.getDependentCode('ACTIVE_WELL_STATUS','WELL_STATUS',PWEL_PERIOD_STATUS.WELL_STATUS) AS active_status,
           ov_well.well_type
    from pwel_period_status, ov_well
    WHERE pwel_period_status.daytime BETWEEN cp_daytime AND (cp_daytime + 1)
    AND pwel_period_status.daytime <> (cp_daytime + 1)
    AND pwel_period_status.daytime >= ov_well.daytime
    AND pwel_period_status.daytime < nvl(ov_well.end_date, pwel_period_status.daytime + 1)
    AND pwel_period_status.object_id = ov_well.object_id
    AND (ov_well.object_id = cp_object_id);

  CURSOR c_getInjWellActiveStatus (cp_object_id VARCHAR2, cp_daytime DATE) IS
    SELECT iwel_period_status.well_status,
       EcDp_System.getDependentCode('ACTIVE_WELL_STATUS','WELL_STATUS',IWEL_PERIOD_STATUS.WELL_STATUS) AS active_status,
       ecdp_well.getWellType(IWEL_PERIOD_STATUS.OBJECT_ID, IWEL_PERIOD_STATUS.DAY) AS well_type
    FROM iwel_period_status, ov_well
    WHERE iwel_period_status.daytime between cp_daytime and (cp_daytime + 1)
    AND iwel_period_status.daytime <> (cp_daytime + 1)
    AND iwel_period_status.daytime >= ov_well.daytime
    AND iwel_period_status.daytime < nvl(ov_well.end_date, iwel_period_status.daytime + 1)
    AND iwel_period_status.object_id = ov_well.object_id
    AND (ov_well.object_id = cp_object_id);

  ln_well_oil_rate NUMBER;
  ln_well_gas_rate NUMBER;
  ln_well_wat_rate NUMBER;
  ln_well_cond_rate NUMBER;
  ln_well_diluent_rate NUMBER;
  ln_well_gas_lift_rate NUMBER;
  ln_well_gas_inj_rate NUMBER;
  ln_well_water_inj_rate NUMBER;
  ln_well_steam_inj_rate NUMBER;
  ln_well_oil_mass_rate NUMBER;
  ln_well_gas_mass_rate NUMBER;
  ln_well_wat_mass_rate NUMBER;
  ln_well_cond_mass_rate NUMBER;

  lb_only_Prod_open_normal    BOOLEAN;
  lb_only_inj_open_normal     BOOLEAN;
  lb_bothprodinj_open_normal  BOOLEAN;
  lv2_prod_active_status VARCHAR2(16);
  lv2_inj_active_status VARCHAR2(16);
  ln_part NUMBER;
  n_lock_columns EcDp_Month_lock.column_list;

BEGIN

  FOR cur_event IN c_event LOOP
    FOR cur_total IN c_potential_total LOOP
      FOR cur_potential IN c_potential LOOP

        ln_well_oil_rate := NULL;
        ln_well_gas_rate := NULL;
        ln_well_wat_rate := NULL;
        ln_well_cond_rate := NULL;
        ln_well_diluent_rate := NULL;
        ln_well_gas_lift_rate := NULL;
        ln_well_gas_inj_rate := NULL;
        ln_well_water_inj_rate := NULL;
        ln_well_steam_inj_rate := NULL;
        ln_well_oil_mass_rate := NULL;
        ln_well_gas_mass_rate := NULL;
        ln_well_wat_mass_rate := NULL;
        ln_well_cond_mass_rate := NULL;


        IF cur_event.grp_def_rate_type = 'OP' THEN

          IF cur_total.TotalOilProductionPotential IS NOT NULL AND cur_total.TotalOilProductionPotential != 0 THEN
            ln_well_oil_rate := cur_potential.OilProductionPotential/cur_total.TotalOilProductionPotential*cur_event.grp_def_rate;

            IF cur_potential.OilProductionPotential <= 0 THEN
               ln_part := 0;
            ELSE
               ln_part := ln_well_oil_rate/cur_potential.OilProductionPotential;
            END IF;

            ln_well_gas_rate := cur_potential.GasProductionPotential * ln_part;
            ln_well_wat_rate := cur_potential.WatProductionPotential * ln_part;
            ln_well_cond_rate := cur_potential.ConProductionPotential * ln_part;
            ln_well_diluent_rate := cur_potential.DiluentPotential * ln_part;
            ln_well_gas_lift_rate := cur_potential.GasLiftPotential * ln_part;
            ln_well_gas_inj_rate := cur_potential.GasInjectionPotential * ln_part;
            ln_well_water_inj_rate := cur_potential.WatInjectionPotential * ln_part;
            ln_well_steam_inj_rate := cur_potential.SteamInjectionPotential * ln_part;
            ln_well_oil_mass_rate := cur_potential.OilMassProdPotential * ln_part;
            ln_well_gas_mass_rate := cur_potential.GasMassProdPotential * ln_part;
            ln_well_wat_mass_rate := cur_potential.WatMassProdPotential * ln_part;
            ln_well_cond_mass_rate := cur_potential.ConMassProdPotential * ln_part;

          END IF;

        ELSIF cur_event.grp_def_rate_type = 'GP' THEN

          IF cur_total.TotalGasProductionPotential IS NOT NULL AND cur_total.TotalGasProductionPotential != 0 THEN
            ln_well_gas_rate := cur_potential.GasProductionPotential/cur_total.TotalGasProductionPotential*cur_event.grp_def_rate;

            IF cur_potential.GasProductionPotential <= 0 THEN
               ln_part := 0;
            ELSE
               ln_part := ln_well_gas_rate/cur_potential.GasProductionPotential;
            END IF;

            ln_well_oil_rate := cur_potential.OilProductionPotential * ln_part;
            ln_well_wat_rate := cur_potential.WatProductionPotential * ln_part;
            ln_well_cond_rate := cur_potential.ConProductionPotential * ln_part;
            ln_well_diluent_rate := cur_potential.DiluentPotential * ln_part;
            ln_well_gas_lift_rate := cur_potential.GasLiftPotential * ln_part;
            ln_well_gas_inj_rate := cur_potential.GasInjectionPotential * ln_part;
            ln_well_water_inj_rate := cur_potential.WatInjectionPotential * ln_part;
            ln_well_steam_inj_rate := cur_potential.SteamInjectionPotential * ln_part;
            ln_well_oil_mass_rate := cur_potential.OilMassProdPotential * ln_part;
            ln_well_gas_mass_rate := cur_potential.GasMassProdPotential * ln_part;
            ln_well_wat_mass_rate := cur_potential.WatMassProdPotential * ln_part;
            ln_well_cond_mass_rate := cur_potential.ConMassProdPotential * ln_part;


          END IF;

        ELSIF cur_event.grp_def_rate_type = 'GI' THEN

          IF cur_total.TotalGasInjectionPotential IS NOT NULL AND cur_total.TotalGasInjectionPotential != 0 THEN
            ln_well_gas_inj_rate := cur_potential.GasInjectionPotential/cur_total.TotalGasInjectionPotential*cur_event.grp_def_rate;

            IF cur_potential.GasInjectionPotential <= 0 THEN
               ln_part := 0;
            ELSE
               ln_part := ln_well_gas_inj_rate/cur_potential.GasInjectionPotential;
            END IF;

            ln_well_oil_rate := cur_potential.OilProductionPotential * ln_part;
            ln_well_gas_rate := cur_potential.GasProductionPotential * ln_part;
            ln_well_wat_rate := cur_potential.WatProductionPotential * ln_part;
            ln_well_cond_rate := cur_potential.ConProductionPotential * ln_part;
            ln_well_diluent_rate := cur_potential.DiluentPotential * ln_part;
            ln_well_gas_lift_rate := cur_potential.GasLiftPotential * ln_part;
            ln_well_water_inj_rate := cur_potential.WatInjectionPotential * ln_part;
            ln_well_steam_inj_rate := cur_potential.SteamInjectionPotential * ln_part;
            ln_well_oil_mass_rate := cur_potential.OilMassProdPotential * ln_part;
            ln_well_gas_mass_rate := cur_potential.GasMassProdPotential * ln_part;
            ln_well_wat_mass_rate := cur_potential.WatMassProdPotential * ln_part;
            ln_well_cond_mass_rate := cur_potential.ConMassProdPotential * ln_part;

          END IF;

        ELSIF cur_event.grp_def_rate_type = 'WI' THEN

          IF cur_total.TotalWatInjectionPotential IS NOT NULL AND cur_total.TotalWatInjectionPotential != 0 THEN
            ln_well_water_inj_rate := cur_potential.WatInjectionPotential/cur_total.TotalWatInjectionPotential*cur_event.grp_def_rate;

            IF cur_potential.WatInjectionPotential <= 0 THEN
               ln_part := 0;
            ELSE
               ln_part := ln_well_water_inj_rate/cur_potential.WatInjectionPotential;
            END IF;

            ln_well_oil_rate := cur_potential.OilProductionPotential * ln_part;
            ln_well_gas_rate := cur_potential.GasProductionPotential * ln_part;
            ln_well_wat_rate := cur_potential.WatProductionPotential * ln_part;
            ln_well_cond_rate := cur_potential.ConProductionPotential * ln_part;
            ln_well_diluent_rate := cur_potential.DiluentPotential * ln_part;
            ln_well_gas_lift_rate := cur_potential.GasLiftPotential * ln_part;
            ln_well_gas_inj_rate := cur_potential.GasInjectionPotential * ln_part;
            ln_well_water_inj_rate := cur_potential.WatInjectionPotential * ln_part;
            ln_well_steam_inj_rate := cur_potential.SteamInjectionPotential * ln_part;
            ln_well_oil_mass_rate := cur_potential.OilMassProdPotential * ln_part;
            ln_well_gas_mass_rate := cur_potential.GasMassProdPotential * ln_part;
            ln_well_wat_mass_rate := cur_potential.WatMassProdPotential * ln_part;
            ln_well_cond_mass_rate := cur_potential.ConMassProdPotential * ln_part;

          END IF;

        ELSIF cur_event.grp_def_rate_type = 'SI' THEN
          IF cur_total.TotalSteamInjectionPotential IS NOT NULL AND cur_total.TotalSteamInjectionPotential != 0 THEN
            ln_well_steam_inj_rate := cur_potential.SteamInjectionPotential/cur_total.TotalSteamInjectionPotential*cur_event.grp_def_rate;

            IF cur_potential.SteamInjectionPotential <= 0 THEN
               ln_part := 0;
            ELSE
               ln_part := ln_well_steam_inj_rate/cur_potential.SteamInjectionPotential;
            END IF;

            ln_well_oil_rate := cur_potential.OilProductionPotential * ln_part;
            ln_well_gas_rate := cur_potential.GasProductionPotential * ln_part;
            ln_well_wat_rate := cur_potential.WatProductionPotential * ln_part;
            ln_well_cond_rate := cur_potential.ConProductionPotential * ln_part;
            ln_well_diluent_rate := cur_potential.DiluentPotential * ln_part;
            ln_well_gas_lift_rate := cur_potential.GasLiftPotential * ln_part;
            ln_well_gas_inj_rate := cur_potential.GasInjectionPotential * ln_part;
            ln_well_water_inj_rate := cur_potential.WatInjectionPotential * ln_part;
            ln_well_oil_mass_rate := cur_potential.OilMassProdPotential * ln_part;
            ln_well_gas_mass_rate := cur_potential.GasMassProdPotential * ln_part;
            ln_well_wat_mass_rate := cur_potential.WatMassProdPotential * ln_part;
            ln_well_cond_mass_rate := cur_potential.ConMassProdPotential * ln_part;

          END IF;

        ELSIF cur_event.grp_def_rate_type = 'OPM' THEN
          IF cur_total.TotalOilMassProdPotential IS NOT NULL AND cur_total.TotalOilMassProdPotential != 0 THEN
            ln_well_oil_mass_rate := cur_potential.OilMassProdPotential/cur_total.TotalOilMassProdPotential*cur_event.grp_def_rate;

            IF cur_potential.OilMassProdPotential <= 0 THEN
               ln_part := 0;
            ELSE
               ln_part := ln_well_oil_mass_rate/cur_potential.OilMassProdPotential;
            END IF;

            ln_well_oil_rate := cur_potential.OilProductionPotential * ln_part;
            ln_well_gas_rate := cur_potential.GasProductionPotential * ln_part;
            ln_well_wat_rate := cur_potential.WatProductionPotential * ln_part;
            ln_well_cond_rate := cur_potential.ConProductionPotential * ln_part;
            ln_well_diluent_rate := cur_potential.DiluentPotential * ln_part;
            ln_well_gas_lift_rate := cur_potential.GasLiftPotential * ln_part;
            ln_well_gas_inj_rate := cur_potential.GasInjectionPotential * ln_part;
            ln_well_water_inj_rate := cur_potential.WatInjectionPotential * ln_part;
            ln_well_steam_inj_rate := cur_potential.SteamInjectionPotential * ln_part;
            ln_well_gas_mass_rate := cur_potential.GasMassProdPotential * ln_part;
            ln_well_wat_mass_rate := cur_potential.WatMassProdPotential * ln_part;
            ln_well_cond_mass_rate := cur_potential.ConMassProdPotential * ln_part;
          END IF;

        ELSIF cur_event.grp_def_rate_type = 'GPM' THEN
          IF cur_total.TotalGasMassProdPotential IS NOT NULL AND cur_total.TotalGasMassProdPotential != 0 THEN
            ln_well_gas_mass_rate := cur_potential.GasMassProdPotential/cur_total.TotalGasMassProdPotential*cur_event.grp_def_rate;

            IF cur_potential.GasMassProdPotential <= 0 THEN
               ln_part := 0;
            ELSE
               ln_part := ln_well_gas_mass_rate/cur_potential.GasMassProdPotential;
            END IF;

            ln_well_oil_rate := cur_potential.OilProductionPotential * ln_part;
            ln_well_gas_rate := cur_potential.GasProductionPotential * ln_part;
            ln_well_wat_rate := cur_potential.WatProductionPotential * ln_part;
            ln_well_cond_rate := cur_potential.ConProductionPotential * ln_part;
            ln_well_diluent_rate := cur_potential.DiluentPotential * ln_part;
            ln_well_gas_lift_rate := cur_potential.GasLiftPotential * ln_part;
            ln_well_gas_inj_rate := cur_potential.GasInjectionPotential * ln_part;
            ln_well_water_inj_rate := cur_potential.WatInjectionPotential * ln_part;
            ln_well_steam_inj_rate := cur_potential.SteamInjectionPotential * ln_part;
            ln_well_oil_mass_rate := cur_potential.OilMassProdPotential * ln_part;
            ln_well_wat_mass_rate := cur_potential.WatMassProdPotential * ln_part;
            ln_well_cond_mass_rate := cur_potential.ConMassProdPotential * ln_part;
          END IF;

        END IF;

        -- Lock check
        IF cur_event.event_type = 'LOW' AND cur_event.current_def_type = 'SHORT' THEN
          EcDp_month_lock.AddParameterToList(n_lock_columns,'CLASS_NAME','DEFER_LOW_AFF_WELL_SHORT','STRING',NULL,NULL,NULL);
        ELSIF cur_event.event_type = 'LOW' AND cur_event.current_def_type = 'LONG' THEN
          EcDp_month_lock.AddParameterToList(n_lock_columns,'CLASS_NAME','DEFER_LOW_AFF_WELL_LONG','STRING',NULL,NULL,NULL);
        ELSIF cur_event.event_type = 'OFF' AND cur_event.current_def_type = 'SHORT' THEN
          EcDp_month_lock.AddParameterToList(n_lock_columns,'CLASS_NAME','DEFER_OFF_AFF_WELL_SHORT','STRING',NULL,NULL,NULL);
        ELSIF cur_event.event_type = 'OFF' AND cur_event.current_def_type = 'LONG' THEN
          EcDp_month_lock.AddParameterToList(n_lock_columns,'CLASS_NAME','WELL_DEFERMENT_EVENT','STRING',NULL,NULL,NULL);
        END IF;

        EcDp_month_lock.AddParameterToList(n_lock_columns,'TABLE_NAME','WELL_DEFERMENT_EVENT','STRING',NULL,NULL,NULL);
        EcDp_month_lock.AddParameterToList(n_lock_columns,'WDE_NO','WDE_NO','NUMBER','Y',EcDp_month_lock.isUpdating(UPDATING('WDE_NO')),anydata.ConvertNumber(cur_potential.WDE_NO));
        EcDp_month_lock.AddParameterToList(n_lock_columns,'EVENT_NO','EVENT_NO','NUMBER','N',EcDp_month_lock.isUpdating(UPDATING('EVENT_NO')),anydata.ConvertNumber(cur_potential.EVENT_NO));
        EcDp_month_lock.AddParameterToList(n_lock_columns,'OBJECT_ID','OBJECT_ID','STRING','N',EcDp_month_lock.isUpdating(UPDATING('OBJECT_ID')),anydata.ConvertVarChar2(cur_potential.OBJECT_ID));
        EcDp_month_lock.AddParameterToList(n_lock_columns,'DAYTIME','DAYTIME','DATE','N',EcDp_month_lock.isUpdating(UPDATING('DAYTIME')),anydata.Convertdate(cur_potential.DAYTIME));
        EcDp_month_lock.AddParameterToList(n_lock_columns,'END_DATE','END_DATE','DATE','N',EcDp_month_lock.isUpdating(UPDATING('END_DATE')),anydata.Convertdate(cur_potential.END_DATE));

        EcBp_Deferment_event.checkDefermentEventLock('UPDATING',n_lock_columns,n_lock_columns);

        lb_only_prod_open_normal    := FALSE;
        lb_only_inj_open_normal     := FALSE;
        lb_bothprodinj_open_normal  := FALSE;
        -- check is only if the well is a producer or injector
        IF ec_well_version.isinjector(cur_potential.object_id,cur_potential.daytime,'<=') = 'Y' and ec_well_version.isproducer(cur_potential.object_id,cur_potential.daytime,'<=')  = 'Y'  THEN
          FOR cur_ProdWellStatus IN c_getProdWellActiveStatus (cur_potential.object_id, cur_potential.daytime) LOOP
            lv2_Prod_Active_Status := cur_ProdWellStatus.Active_Status;
          END LOOP;
          FOR cur_InjWellStatus IN c_getInjWellActiveStatus (cur_potential.object_id, cur_potential.daytime) LOOP
            lv2_Inj_Active_Status := cur_InjWellStatus.Active_Status;
          END LOOP;

          IF lv2_prod_active_status  = 'OPEN' AND (lv2_inj_active_status IS NULL OR lv2_inj_active_status <> 'OPEN') THEN
            lb_only_prod_open_normal := TRUE;
          ELSIF (lv2_prod_active_status IS NULL OR lv2_prod_active_status <> 'OPEN') AND lv2_inj_active_status = 'OPEN' THEN
            lb_only_inj_open_normal := TRUE;
          ELSIF lv2_prod_active_status  = 'OPEN' AND lv2_inj_active_status  = 'OPEN' THEN
            lb_bothprodinj_open_normal := TRUE;
          END IF;
          IF lb_only_prod_open_normal = TRUE THEN
            UPDATE well_deferment_event w
            SET w.deferred_oil_rate           = nvl(ln_well_oil_rate,         w.deferred_oil_rate),
                w.deferred_gas_rate           = nvl(ln_well_gas_rate,         w.deferred_gas_rate),
                w.deferred_water_rate         = nvl(ln_well_wat_rate,         w.deferred_water_rate),
                w.deferred_cond_rate          = nvl(ln_well_cond_rate,        w.deferred_cond_rate),
                w.deferred_diluent_rate       = nvl(ln_well_diluent_rate,     w.deferred_diluent_rate),
                w.deferred_gas_lift_rate      = nvl(ln_well_gas_lift_rate,    w.deferred_gas_lift_rate),
                w.def_mass_oil_rate      = nvl(ln_well_oil_mass_rate,  w.def_mass_oil_rate),
                w.def_mass_gas_rate   = nvl(ln_well_gas_mass_rate, w.def_mass_gas_rate),
                w.def_mass_water_rate = nvl(ln_well_wat_mass_rate, w.def_mass_water_rate),
                w.def_mass_cond_rate      = nvl(ln_well_cond_mass_rate,  w.def_mass_cond_rate)
            WHERE w.event_no  =  cur_potential.event_no
              AND   w.object_id =  cur_potential.object_id
              AND   w.daytime   =  cur_potential.daytime;
          ELSIF lb_only_inj_open_normal = TRUE THEN
            UPDATE well_deferment_event w
            SET w.deferred_gas_inj_rate       = nvl(ln_well_gas_inj_rate,     w.deferred_gas_inj_rate),
                w.deferred_steam_inj_rate     = nvl(ln_well_steam_inj_rate,   w.deferred_steam_inj_rate),
                w.deferred_water_inj_rate = nvl(ln_well_water_inj_rate, w.deferred_water_inj_rate)
            WHERE w.event_no  =  cur_potential.event_no
            AND   w.object_id =  cur_potential.object_id
            AND   w.daytime   =  cur_potential.daytime;
          ELSIF lb_bothprodinj_open_normal = TRUE THEN
            UPDATE well_deferment_event w
            SET w.deferred_oil_rate           = nvl(ln_well_oil_rate,         w.deferred_oil_rate),
                w.deferred_gas_rate           = nvl(ln_well_gas_rate,         w.deferred_gas_rate),
                w.deferred_water_rate         = nvl(ln_well_wat_rate,         w.deferred_water_rate),
                w.deferred_cond_rate          = nvl(ln_well_cond_rate,        w.deferred_cond_rate),
                w.deferred_diluent_rate       = nvl(ln_well_diluent_rate,     w.deferred_diluent_rate),
                w.deferred_gas_lift_rate      = nvl(ln_well_gas_lift_rate,    w.deferred_gas_lift_rate),
                w.deferred_gas_inj_rate       = nvl(ln_well_gas_inj_rate,     w.deferred_gas_inj_rate),
                w.deferred_water_inj_rate = nvl(ln_well_water_inj_rate, w.deferred_water_inj_rate),
                w.deferred_steam_inj_rate     = nvl(ln_well_steam_inj_rate,   w.deferred_steam_inj_rate),
                w.def_mass_oil_rate      = nvl(ln_well_oil_mass_rate,  w.def_mass_oil_rate),
                w.def_mass_gas_rate   = nvl(ln_well_gas_mass_rate, w.def_mass_gas_rate),
                w.def_mass_water_rate = nvl(ln_well_wat_mass_rate, w.def_mass_water_rate),
                w.def_mass_cond_rate      = nvl(ln_well_cond_mass_rate,  w.def_mass_cond_rate)
            WHERE w.event_no  =  cur_potential.event_no
            AND   w.object_id =  cur_potential.object_id
            AND   w.daytime   =  cur_potential.daytime;
          END IF;
        ELSE
          UPDATE well_deferment_event w
          SET w.deferred_oil_rate       = nvl(ln_well_oil_rate,       w.deferred_oil_rate),
             w.deferred_gas_rate       = nvl(ln_well_gas_rate,       w.deferred_gas_rate),
             w.deferred_water_rate     = nvl(ln_well_wat_rate,       w.deferred_water_rate),
             w.deferred_cond_rate      = nvl(ln_well_cond_rate,      w.deferred_cond_rate),
             w.deferred_diluent_rate   = nvl(ln_well_diluent_rate,   w.deferred_diluent_rate),
             w.deferred_gas_lift_rate  = nvl(ln_well_gas_lift_rate,  w.deferred_gas_lift_rate),
             w.deferred_gas_inj_rate   = nvl(ln_well_gas_inj_rate,   w.deferred_gas_inj_rate),
             w.deferred_water_inj_rate = nvl(ln_well_water_inj_rate, w.deferred_water_inj_rate),
             w.deferred_steam_inj_rate = nvl(ln_well_steam_inj_rate, w.deferred_steam_inj_rate),
             w.def_mass_oil_rate      = nvl(ln_well_oil_mass_rate,  w.def_mass_oil_rate),
             w.def_mass_gas_rate   = nvl(ln_well_gas_mass_rate, w.def_mass_gas_rate),
             w.def_mass_water_rate = nvl(ln_well_wat_mass_rate, w.def_mass_water_rate),
             w.def_mass_cond_rate      = nvl(ln_well_cond_mass_rate,  w.def_mass_cond_rate)
           WHERE w.event_no  =  cur_potential.event_no
           AND   w.object_id =  cur_potential.object_id
           AND   w.daytime   =  cur_potential.daytime;
        END IF;
        ecbp_deferment_event.compareLowAndPotentialRate(cur_potential.event_no, cur_potential.daytime, cur_potential.object_id);

      END LOOP;
    END LOOP;
  END LOOP;

END allocateGroupRateToWells;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkIfEventExists
-- Description    : Checks whether a deferment event already exists.
--
--
-- Preconditions  :
-- Postconditions : Raises an application error if event overlap for the assosiated object.
--
-- Using tables   : fcty_deferment_event
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkIfEventExists(p_event_no NUMBER, p_object_id VARCHAR2, p_event_type VARCHAR2, p_from_date DATE, p_to_date DATE)
--</EC-DOC>
IS

	CURSOR c_overlapping_events  IS
		SELECT *
		FROM fcty_deferment_event de
		WHERE (de.end_date > p_from_date OR de.end_date is null)
		AND   (de.daytime < p_to_date OR p_to_date IS NULL)
    AND   de.event_type = p_event_type
		AND   de.asset_id = p_object_id
    AND   (de.event_no != p_event_no OR p_event_no IS NULL);

    lv_message VARCHAR2(4000);

BEGIN

  lv_message := null;
 	FOR cur_overlapping_event IN c_overlapping_events LOOP
    lv_message := lv_message || cur_overlapping_event.asset_id || ' ';
  END LOOP;

  IF lv_message is not null THEN

    -- TODO: Get the right error code
    RAISE_APPLICATION_ERROR(-20000, 'This event overlaps with existing event');
  END IF;

END checkIfEventExists;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkIfAffectedWellsOverlap
-- Description    : Checks whether a affected well overlaps an already existing well for the given object and period.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : well_deferment_event
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkIfAffectedWellsOverlap(p_event_no NUMBER, p_object_id VARCHAR2, p_from_date DATE, p_to_date DATE)
--</EC-DOC>
IS

	CURSOR c_overlapping_events  IS
		SELECT *
		FROM well_deferment_event aw
		WHERE (aw.end_date > p_from_date OR aw.end_date IS NULL)
		AND   (aw.daytime < p_to_date OR p_to_date IS NULL)
		AND   aw.object_id = p_object_id
		AND   aw.event_no = p_event_no
    AND   aw.daytime != p_from_date;

    lv_message VARCHAR2(4000);

BEGIN

  lv_message := null;
 	FOR cur_overlapping_event IN c_overlapping_events LOOP
    lv_message := lv_message || cur_overlapping_event.object_id || ' ';
  END LOOP;

  IF lv_message is not null THEN
    -- TODO: Get the right error code
    RAISE_APPLICATION_ERROR(-20000, 'This well overlaps with existing well');
  END IF;

END checkIfAffectedWellsOverlap;

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

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : VerifyActions
-- Description    : This procedure checks that we don't have any overlapping actions on events
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
--</EC-DOC>
PROCEDURE VerifyActions(p_event_no NUMBER, p_daytime DATE, p_end_date DATE, p_action VARCHAR2)

IS
	CURSOR c_overlapping_actions  IS
		SELECT *
		FROM deferment_corr_action dca
		WHERE (dca.end_date > p_daytime OR dca.end_date IS NULL)
    AND (dca.daytime < p_end_date OR p_end_date IS NULL)
    AND dca.event_no = p_event_no
    AND dca.action != p_action;


  CURSOR c_outside_event  IS
		SELECT *
		FROM fcty_deferment_event e
		WHERE (e.daytime > p_daytime
    OR e.end_date < p_daytime
    OR e.end_date < p_end_date)
    AND e.event_no = p_event_no;

    lv_overlapping_message VARCHAR2(4000);
    lv_outside_message VARCHAR2(4000);

BEGIN

  lv_overlapping_message := null;
  lv_outside_message := null;

 	FOR cur_overlapping_action IN c_overlapping_actions LOOP
    lv_overlapping_message := lv_overlapping_message || cur_overlapping_action.event_no || ' ';
  END LOOP;

  IF lv_overlapping_message is not null THEN
    -- TODO: Get the right error code
    RAISE_APPLICATION_ERROR(-20000, 'This action overlaps with existing action');
  END IF;

  FOR cur_outside_event IN c_outside_event LOOP
    lv_outside_message := lv_outside_message || cur_outside_event.event_no || ' ';
  END LOOP;

  IF lv_outside_message is not null THEN
    -- TODO: Get the right error code
    RAISE_APPLICATION_ERROR(-20000, 'This action time period are outside event time period ');
  END IF;

END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : CalcDeferredActionVolume
-- Description    : This function finds the deffered volume for the given corrective action period.
--                  volume =  event grp volume * corr action period/event period
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
FUNCTION CalcDeferredActionVolume(p_event_no NUMBER,p_daytime DATE,p_end_date DATE, p_phase VARCHAR2)
--</EC-DOC>
RETURN NUMBER
IS

CURSOR c_event_deferred_qty IS
  select wde.daytime,
         nvl(wde.end_date,EcDp_ProductionDay.getProductionDay('WELL',wde.object_id, sysdate)+1) end_date, -- if null default to end of production day today.
         sum(wdda.deferred_gas_vol) gas_vol,
         sum(wdda.deferred_net_oil_vol) net_oil_vol,
         sum(wdda.deferred_cond_vol) cond_vol,
         sum(wdda.deferred_water_vol) water_vol,
         sum(wdda.deferred_gas_mass) gas_mass,
         sum(wdda.deferred_net_oil_mass) net_oil_mass,
         sum(wdda.deferred_cond_mass) cond_mass,
         sum(wdda.deferred_water_mass) water_mass,
         sum(wdda.deferred_gl_vol) gl_vol,
         sum(wdda.deferred_diluent_vol) diluent_vol,
         sum(wdda.deferred_steam_inj_vol) steam_inj_vol,
         sum(wdda.deferred_gas_inj_vol) gas_inj_vol,
         sum(wdda.deferred_water_inj_vol) water_inj_vol,
         sum(wdda.deferred_gas_inj_mass) gas_inj_mass,
         sum(wdda.deferred_water_inj_mass) water_inj_mass
  from well_day_deferment_alloc wdda,
       well_deferment_event wde
  WHERE wdda.wde_no = wde.wde_no
  AND   wde.event_no = p_event_no
  GROUP BY wde.daytime, nvl(wde.end_date,EcDp_ProductionDay.getProductionDay('WELL',wde.object_id, sysdate)+1)
  ;

  ln_return NUMBER;
  ln_event_qty NUMBER;
  ln_duration NUMBER;
  ln_corr_action_duration NUMBER;

BEGIN

   ln_return := 0;
   FOR cur_event IN c_event_deferred_qty LOOP

     ln_duration := cur_event.end_date - cur_event.daytime;
     ln_corr_action_duration := nvl(p_end_date,trunc(sysdate)) - p_daytime;

     IF p_phase = 'GAS' THEN
        ln_event_qty := cur_event.gas_vol;
     ELSIF p_phase = 'OIL' THEN
        ln_event_qty := cur_event.net_oil_vol;
     ELSIF p_phase = 'COND' THEN
        ln_event_qty := cur_event.cond_vol;
     ELSIF p_phase = 'WATER' THEN
        ln_event_qty := cur_event.water_vol;
     ELSIF p_phase = 'GAS_MASS' THEN
        ln_event_qty := cur_event.gas_mass;
     ELSIF p_phase = 'OIL_MASS' THEN
        ln_event_qty := cur_event.net_oil_mass;
     ELSIF p_phase = 'COND_MASS' THEN
        ln_event_qty := cur_event.cond_mass;
     ELSIF p_phase = 'WATER_MASS' THEN
        ln_event_qty := cur_event.water_mass;
     ELSIF p_phase = 'GAS_LIFT' THEN
        ln_event_qty := cur_event.gl_vol;
     ELSIF p_phase = 'DILUENT' THEN
        ln_event_qty := cur_event.diluent_vol;
     ELSIF p_phase = 'STEAM_INJ' THEN
        ln_event_qty := cur_event.steam_inj_vol;
     ELSIF p_phase = 'GAS_INJ' THEN
        ln_event_qty := cur_event.gas_inj_vol;
     ELSIF p_phase = 'WATER_INJ' THEN
        ln_event_qty := cur_event.water_inj_vol;
     ELSIF p_phase = 'GAS_INJ_MASS' THEN
        ln_event_qty := cur_event.gas_inj_mass;
     ELSIF p_phase = 'WATER_INJ_MASS' THEN
        ln_event_qty := cur_event.water_inj_mass;
     END IF;

     IF ln_duration <> 0 THEN
       ln_return := ln_event_qty / ln_duration * ln_corr_action_duration;
     END IF;

   END LOOP;

   RETURN ln_return;

END CalcDeferredActionVolume;



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
   ln_sysdate := trunc(ecdp_date_time.getcurrentsysdate);

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
-- Procedure      : verifyDeferment
-- Description    : The Procedure verify the period for the selected deferment event
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCTY_DEFERMENT_EVENT, WELL_DEFERMENT_EVENT
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
---------------------------------------------------------------------------------------------------

PROCEDURE verifyDeferment(p_eventNo NUMBER,p_user VARCHAR2)
--</EC-DOC>
IS

ln_exists NUMBER;
ln_exists1 NUMBER;

lv2_last_update_date VARCHAR2(20);

BEGIN
  lv2_last_update_date := to_char(EcDp_Date_Time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')  ;


    SELECT COUNT(*) INTO ln_exists FROM fcty_deferment_event WHERE EVENT_NO = p_eventNo
    AND record_status='A';

    IF ln_exists = 0 THEN
       UPDATE fcty_deferment_event
         SET record_status='V',
             last_updated_by = p_user,
             last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
             rev_text = 'Verified at ' ||  lv2_last_update_date
       WHERE event_no = p_eventNo;

       SELECT COUNT(*) INTO ln_exists1 FROM well_deferment_event WHERE EVENT_NO = p_eventNo;
       IF ln_exists1 > 0 THEN
          UPDATE well_deferment_event
                 SET record_status='V',
                 last_updated_by = p_user,
                 last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
                 rev_text = 'Verified at ' ||  lv2_last_update_date
       WHERE event_no = p_eventNo;
       END IF;
    ELSE
      RAISE_APPLICATION_ERROR('-20223','Record with Approved status cannot be Verified again.');
    END IF;

END verifyDeferment;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : approveDeferment
-- Description    : The Procedure approve the period for the selected deferment event
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCTY_DEFERMENT_EVENT, WELL_DEFERMENT_EVENT
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
---------------------------------------------------------------------------------------------------
PROCEDURE approveDeferment(p_eventNo NUMBER,p_user VARCHAR2)
--</EC-DOC>
IS
ln_exists2 NUMBER;

lv2_last_update_date VARCHAR2(20);

BEGIN
  lv2_last_update_date := to_char(EcDp_Date_Time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')  ;


    UPDATE fcty_deferment_event
       SET record_status='A',
           last_updated_by = p_user,
           last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
           rev_text = 'Approved at ' ||  lv2_last_update_date
    WHERE event_no = p_eventNo;
    SELECT COUNT(*) INTO ln_exists2 FROM well_deferment_event WHERE EVENT_NO = p_eventNo;
       IF ln_exists2 > 0 THEN
          UPDATE well_deferment_event
                 SET record_status='A',
                 last_updated_by = p_user,
                 last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
                 rev_text = 'Approved at ' ||  lv2_last_update_date
       WHERE event_no = p_eventNo;
       END IF;

END approveDeferment;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copyNewRec
-- Description    : This is to copy the parent record plus all the child records into new records.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCTY_DEFERMENT_EVENT, WELL_DEFERMENT_EVENT
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
---------------------------------------------------------------------------------------------------
PROCEDURE copyNewRec(p_eventNo NUMBER,p_user VARCHAR2)
--</EC-DOC>
IS

  CURSOR c_event IS
    SELECT * from fcty_deferment_event e where e.event_no = p_eventNo;

  CURSOR c_potential IS
    SELECT aw.wde_no, aw.event_no, aw.object_id, aw.daytime, aw.end_date
    FROM well_deferment_event aw
    WHERE aw.event_no = p_eventNo;

  TYPE t_fcty_deferment IS TABLE OF FCTY_DEFERMENT_EVENT%ROWTYPE;
    l_fcty_deferment t_fcty_deferment;

  CURSOR c_fcty_defer (cp_eventNo VARCHAR2)
    IS
      SELECT *
      FROM fcty_deferment_event
      WHERE event_no = cp_eventNo;


  ln_exists NUMBER;
  ln_exists1 NUMBER;
  eventNo Number;
  n_lock_columns EcDp_Month_lock.column_list;

BEGIN

  FOR cur_event IN c_event LOOP
    FOR cur_potential IN c_potential LOOP
      -- Lock check
      IF cur_event.event_type = 'LOW' AND cur_event.current_def_type = 'SHORT' THEN
        EcDp_month_lock.AddParameterToList(n_lock_columns,'CLASS_NAME','DEFER_LOW_AFF_WELL_SHORT','STRING',NULL,NULL,NULL);
      ELSIF cur_event.event_type = 'LOW' AND cur_event.current_def_type = 'LONG' THEN
        EcDp_month_lock.AddParameterToList(n_lock_columns,'CLASS_NAME','DEFER_LOW_AFF_WELL_LONG','STRING',NULL,NULL,NULL);
      ELSIF cur_event.event_type = 'OFF' AND cur_event.current_def_type = 'SHORT' THEN
        EcDp_month_lock.AddParameterToList(n_lock_columns,'CLASS_NAME','DEFER_OFF_AFF_WELL_SHORT','STRING',NULL,NULL,NULL);
      ELSIF cur_event.event_type = 'OFF' AND cur_event.current_def_type = 'LONG' THEN
        EcDp_month_lock.AddParameterToList(n_lock_columns,'CLASS_NAME','WELL_DEFERMENT_EVENT','STRING',NULL,NULL,NULL);
      END IF;

      EcDp_month_lock.AddParameterToList(n_lock_columns,'TABLE_NAME','WELL_DEFERMENT_EVENT','STRING',NULL,NULL,NULL);
      EcDp_month_lock.AddParameterToList(n_lock_columns,'WDE_NO','WDE_NO','NUMBER','Y',EcDp_month_lock.isUpdating(UPDATING('WDE_NO')),anydata.ConvertNumber(cur_potential.WDE_NO));
      EcDp_month_lock.AddParameterToList(n_lock_columns,'EVENT_NO','EVENT_NO','NUMBER','N',EcDp_month_lock.isUpdating(UPDATING('EVENT_NO')),anydata.ConvertNumber(cur_potential.EVENT_NO));
      EcDp_month_lock.AddParameterToList(n_lock_columns,'OBJECT_ID','OBJECT_ID','STRING','N',EcDp_month_lock.isUpdating(UPDATING('OBJECT_ID')),anydata.ConvertVarChar2(cur_potential.OBJECT_ID));
      EcDp_month_lock.AddParameterToList(n_lock_columns,'DAYTIME','DAYTIME','DATE','N',EcDp_month_lock.isUpdating(UPDATING('DAYTIME')),anydata.Convertdate(cur_potential.DAYTIME));
      EcDp_month_lock.AddParameterToList(n_lock_columns,'END_DATE','END_DATE','DATE','N',EcDp_month_lock.isUpdating(UPDATING('END_DATE')),anydata.Convertdate(cur_potential.END_DATE));

      EcBp_Deferment_event.checkDefermentEventLock('UPDATING',n_lock_columns,n_lock_columns);

    END LOOP;
  END LOOP;

  EcDp_System_Key.assignNextNumber('FCTY_DEFERMENT_EVENT', eventNo);

  SELECT COUNT(*) INTO ln_exists FROM fcty_deferment_event WHERE EVENT_NO = p_eventNo
  AND end_date is not null;

    IF ln_exists > 0 THEN
      OPEN c_fcty_defer (p_eventNo);
      LOOP
      FETCH c_fcty_defer BULK COLLECT INTO l_fcty_deferment LIMIT 2000;

      FOR i IN 1..l_fcty_deferment.COUNT LOOP
        l_fcty_deferment(i).event_no := eventNo;
        l_fcty_deferment(i).daytime := l_fcty_deferment(i).end_date;
        l_fcty_deferment(i).DAY := EcDp_ProductionDay.getProductionDay(l_fcty_deferment(i).ASSET_TYPE,l_fcty_deferment(i).ASSET_ID,l_fcty_deferment(i).END_DATE,l_fcty_deferment(i).SUMMER_TIME);
        l_fcty_deferment(i).end_date := '';
      END LOOP;

      FORALL i IN 1..l_fcty_deferment.COUNT
        INSERT INTO fcty_deferment_event VALUES l_fcty_deferment(i);

      EXIT WHEN c_fcty_defer%NOTFOUND;

      END LOOP;
    CLOSE c_fcty_defer;

    SELECT COUNT(*) INTO ln_exists1 FROM well_deferment_event WHERE EVENT_NO = p_eventNo;

    IF ln_exists1 > 0 THEN
      INSERT INTO WELL_DEFERMENT_EVENT(EVENT_NO,OBJECT_ID,DAYTIME,END_DATE,DAY,
        END_DAY,SUMMER_TIME,DEFERRED_OIL_RATE,DEFERRED_GAS_RATE,
        DEFERRED_WATER_RATE,DEFERRED_COND_RATE,DEFERRED_DILUENT_RATE,
        DEFERRED_GAS_LIFT_RATE,DEFERRED_GAS_INJ_RATE,
        DEFERRED_WATER_INJ_RATE,DEFERRED_STEAM_INJ_RATE,
        DEF_MASS_COND_RATE,DEF_MASS_GAS_RATE,
        DEF_MASS_OIL_RATE,DEF_MASS_WATER_RATE,VALUE_1,
        VALUE_2,VALUE_3,VALUE_4,VALUE_5,VALUE_6,VALUE_7,
        VALUE_8,VALUE_9,VALUE_10,TEXT_1,TEXT_2,TEXT_3,TEXT_4)
        SELECT eventNo,OBJECT_ID,END_DATE,'',EcDp_ProductionDay.getProductionDay('WELL',OBJECT_ID,END_DATE,SUMMER_TIME),
        END_DAY,SUMMER_TIME,DEFERRED_OIL_RATE,DEFERRED_GAS_RATE,
        DEFERRED_WATER_RATE,DEFERRED_COND_RATE,DEFERRED_DILUENT_RATE,
        DEFERRED_GAS_LIFT_RATE,DEFERRED_GAS_INJ_RATE,
        DEFERRED_WATER_INJ_RATE,DEFERRED_STEAM_INJ_RATE,
        DEF_MASS_COND_RATE,DEF_MASS_GAS_RATE,
        DEF_MASS_OIL_RATE,DEF_MASS_WATER_RATE,VALUE_1,
        VALUE_2,VALUE_3,VALUE_4,VALUE_5,VALUE_6,VALUE_7,
        VALUE_8,VALUE_9,VALUE_10,TEXT_1,TEXT_2,TEXT_3,TEXT_4
        FROM WELL_DEFERMENT_EVENT WHERE EVENT_NO=p_eventNo;
    END IF;

  ELSE
    RAISE_APPLICATION_ERROR(-20000, 'Cannot copy when end date is null.');
  END IF;

END copyNewRec;

---------------------------------------------------------------------------------------------------
-- Procedure      : SumDailyDeferredQty
-- Description    : This function should sum records from well_day_deferment_alloc by object_id, daytime and deferment_event_type.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCTY_DEFERMENT_EVENT, WELL_DEFERMENT_EVENT, WELL_DAY_DEFERMENT_ALLOC
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
---------------------------------------------------------------------------------------------------
FUNCTION SumDailyDeferredQty(p_object_id VARCHAR2,p_daytime DATE,
         p_def_event_type VARCHAR2,
         p_def_att VARCHAR2)
--</EC-DOC>
RETURN NUMBER
IS

ln_sum NUMBER;
lv2_def_version VARCHAR2(32);

BEGIN
     ln_sum := 0;
     lv2_def_version := ec_ctrl_system_attribute.attribute_text(p_daytime, 'DEFERMENT_VERSION', '<=');

    IF lv2_def_version = 'PD.0001.02' THEN
            	SELECT decode(p_def_att,
            	'DEFERRED_GAS_VOL',SUM(a.DEFERRED_GAS_VOL),
            	'DEFERRED_NET_OIL_VOL',SUM(a.DEFERRED_NET_OIL_VOL),
          	  'DEFERRED_COND_VOL',SUM(a.DEFERRED_COND_VOL),
          	  'DEFERRED_WATER_VOL',SUM(a.DEFERRED_WATER_VOL),
          	  'DEFERRED_GAS_MASS',SUM(a.DEFERRED_GAS_MASS),
          	  'DEFERRED_COND_MASS',SUM(a.DEFERRED_COND_MASS),
          	  'DEFERRED_NET_OIL_MASS',SUM(a.DEFERRED_NET_OIL_MASS),
          	  'DEFERRED_WATER_MASS',SUM(a.DEFERRED_WATER_MASS),
              'DEFERRED_GL_VOL',SUM(a.DEFERRED_GL_VOL),
          	  'DEFERRED_DILUENT_VOL',SUM(a.DEFERRED_DILUENT_VOL),
          	  'DEFERRED_STEAM_INJ_VOL',SUM(a.DEFERRED_STEAM_INJ_VOL),
          	  'DEFERRED_GAS_INJ_VOL',SUM(a.DEFERRED_GAS_INJ_VOL),
          	  'DEFERRED_WATER_INJ_VOL',SUM(a.DEFERRED_WATER_INJ_VOL),
          	  'DEFERRED_GAS_INJ_MASS',SUM(a.DEFERRED_GAS_INJ_MASS),
          	  'DEFERRED_WATER_INJ_MASS',SUM(a.DEFERRED_WATER_INJ_MASS))
          	  INTO ln_sum
          	  FROM well_day_deferment_alloc a, fcty_deferment_event b, well_deferment_event c
	            WHERE a.wde_no=c.wde_no and c.event_no=b.event_no
	            AND a.object_id=p_object_id
	            AND a.daytime = p_daytime
	            AND nvl(p_def_event_type,b.event_type) = b.event_type;
    END IF;

 RETURN ln_sum;

END SumDailyDeferredQty;

---------------------------------------------------------------------------------------------------
-- Procedure      : SumPeriodDeferredQty
-- Description    : This function should sum records from well_day_deferment_alloc by object_id, daytime and deferment_event_type.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCTY_DEFERMENT_EVENT, WELL_DEFERMENT_EVENT, WELL_DAY_DEFERMENT_ALLOC
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
---------------------------------------------------------------------------------------------------
FUNCTION SumPeriodDeferredQty(p_object_id VARCHAR2,p_from_date DATE,
         p_to_date DATE,
         p_def_event_type VARCHAR2,
         p_def_att VARCHAR2)


--</EC-DOC>
RETURN NUMBER
IS
ln_sum1 NUMBER;
lv2_def_version VARCHAR2(32);

BEGIN
     ln_sum1 := 0;
     lv2_def_version := ec_ctrl_system_attribute.attribute_text(p_from_date, 'DEFERMENT_VERSION', '<=');

    IF lv2_def_version = 'PD.0001.02' THEN
            	SELECT decode(p_def_att,
            	'DEFERRED_GAS_VOL',SUM(a.DEFERRED_GAS_VOL),
            	'DEFERRED_NET_OIL_VOL',SUM(a.DEFERRED_NET_OIL_VOL),
          	  'DEFERRED_COND_VOL',SUM(a.DEFERRED_COND_VOL),
          	  'DEFERRED_WATER_VOL',SUM(a.DEFERRED_WATER_VOL),
          	  'DEFERRED_GAS_MASS',SUM(a.DEFERRED_GAS_MASS),
          	  'DEFERRED_COND_MASS',SUM(a.DEFERRED_COND_MASS),
          	  'DEFERRED_NET_OIL_MASS',SUM(a.DEFERRED_NET_OIL_MASS),
          	  'DEFERRED_WATER_MASS',SUM(a.DEFERRED_WATER_MASS),
              'DEFERRED_GL_VOL',SUM(a.DEFERRED_GL_VOL),
          	  'DEFERRED_DILUENT_VOL',SUM(a.DEFERRED_DILUENT_VOL),
          	  'DEFERRED_STEAM_INJ_VOL',SUM(a.DEFERRED_STEAM_INJ_VOL),
          	  'DEFERRED_GAS_INJ_VOL',SUM(a.DEFERRED_GAS_INJ_VOL),
          	  'DEFERRED_WATER_INJ_VOL',SUM(a.DEFERRED_WATER_INJ_VOL),
          	  'DEFERRED_GAS_INJ_MASS',SUM(a.DEFERRED_GAS_INJ_MASS),
          	  'DEFERRED_WATER_INJ_MASS',SUM(a.DEFERRED_WATER_INJ_MASS))
          	  INTO ln_sum1
          	  FROM well_day_deferment_alloc a, fcty_deferment_event b, well_deferment_event c
	            WHERE a.wde_no=c.wde_no and c.event_no=b.event_no
	            AND a.object_id=p_object_id
	            AND a.daytime >= p_from_date and a.daytime <= p_to_date
	            AND nvl(p_def_event_type,b.event_type) = b.event_type;
    END IF;

 RETURN ln_sum1;


END SumPeriodDeferredQty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : compareLowAndPotentialRate
-- Description    : Check that the deferred rate of each phase is not greater than the well potential
--                  rate of each phase
--
-- Preconditions  : The deferred rate is not null
--
-- Postconditions :
-- Using tables   : WELL_DEFERMENT_EVENT
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE compareLowAndPotentialRate(p_event_no NUMBER,p_daytime DATE,p_object_id WELL.OBJECT_ID%TYPE)
--</EC-DOC>
IS

CURSOR c_well_info IS
	select  wde.deferred_oil_rate, nvl(Ecbp_well_potential.findOilProductionPotential(wde.OBJECT_ID,wde.DAY),'') potential_oil,
		wde.deferred_gas_rate, nvl(Ecbp_well_potential.findGasProductionPotential(wde.OBJECT_ID,wde.DAY),'') potential_gas,
		wde.deferred_water_rate, nvl(Ecbp_well_potential.findWatProductionPotential(wde.OBJECT_ID,wde.DAY),'') potential_water,
		wde.deferred_diluent_rate, nvl(Ecbp_well_potential.findDiluentPotential(wde.OBJECT_ID,wde.DAY),'') potential_diluent,
		wde.deferred_cond_rate, nvl(Ecbp_well_potential.findConProductionPotential(wde.OBJECT_ID,wde.DAY),'') potential_cond,
		wde.deferred_gas_lift_rate, nvl(Ecbp_well_potential.findGasLiftPotential(wde.OBJECT_ID,wde.DAY),'') potential_gas_lift,
		wde.deferred_gas_inj_rate, nvl(Ecbp_well_potential.findGasInjectionPotential(wde.OBJECT_ID,wde.DAY),'') potential_gas_inj,
		wde.deferred_water_inj_rate, nvl(Ecbp_well_potential.findWatInjectionPotential(wde.OBJECT_ID,wde.DAY),'') potential_water_inj,
		wde.deferred_steam_inj_rate, nvl(Ecbp_well_potential.findSteamInjectionPotential(wde.OBJECT_ID,wde.DAY),'') potential_steam_inj,
		wde.def_mass_oil_rate, nvl(Ecbp_well_potential.findOilMassProdPotential(wde.OBJECT_ID,wde.DAY),'') potential_oil_mass,
		wde.def_mass_gas_rate, nvl(Ecbp_well_potential.findGasMassProdPotential(wde.OBJECT_ID,wde.DAY),'') potential_gas_mass,
		wde.def_mass_water_rate, nvl(Ecbp_well_potential.findWaterMassProdPotential(wde.OBJECT_ID,wde.DAY),'') potential_water_mass,
		wde.def_mass_cond_rate, nvl(Ecbp_well_potential.findCondMassProdPotential(wde.OBJECT_ID,wde.DAY),'') potential_cond_mass
	from    well_deferment_event wde
	where   wde.event_no = p_event_no
	and     wde.daytime = p_daytime
	and     wde.object_id = p_object_id;

BEGIN

	FOR c_a in c_well_info LOOP
	IF
       (c_a.deferred_oil_rate >nvl(c_a.potential_oil,c_a.deferred_oil_rate))OR
       (c_a.deferred_gas_rate >nvl(c_a.potential_gas,c_a.deferred_gas_rate))OR
       (c_a.deferred_water_rate >nvl(c_a.potential_water,c_a.deferred_water_rate))OR
       (c_a.deferred_diluent_rate >nvl(c_a.potential_diluent,c_a.deferred_diluent_rate))OR
       (c_a.deferred_cond_rate >nvl(c_a.potential_cond,c_a.deferred_cond_rate))OR
       (c_a.deferred_gas_lift_rate >nvl(c_a.potential_gas_lift,c_a.deferred_gas_lift_rate))OR
       (c_a.deferred_gas_inj_rate >nvl(c_a.potential_gas_inj,c_a.deferred_gas_inj_rate))OR
       (c_a.deferred_water_inj_rate >nvl(c_a.potential_water_inj,c_a.deferred_water_inj_rate))OR
       (c_a.deferred_steam_inj_rate >nvl(c_a.potential_steam_inj,c_a.deferred_steam_inj_rate))OR
       (c_a.def_mass_oil_rate >nvl(c_a.potential_oil_mass,c_a.def_mass_oil_rate))OR
       (c_a.def_mass_gas_rate >nvl(c_a.potential_gas_mass,c_a.def_mass_gas_rate))OR
       (c_a.def_mass_water_rate >nvl(c_a.potential_water_mass,c_a.def_mass_water_rate))OR
       (c_a.def_mass_cond_rate >nvl(c_a.potential_cond_mass,c_a.def_mass_cond_rate))
     THEN
       raise_application_error(-20000,'Deferred Rate Cannot Be Greater than Potential Rate');
     END IF;
	END LOOP;

end compareLowAndPotentialRate;

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

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getPlannedVolumes                                                   --
-- Description    : Returns Planned Volumes.
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                           --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION getPlannedVolumes(p_object_id VARCHAR2, p_phase VARCHAR2, p_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS

ln_planned_day_volume NUMBER;
ln_fcst_scen_no       NUMBER;
lv2_potential_method  VARCHAR2(32);
lr_fcty_version       FCTY_VERSION%ROWTYPE;
lv2_class_name        VARCHAR2(32);


CURSOR c_forecast_fcty_vol(cp_fcst_scen_no NUMBER) IS
SELECT DECODE(p_phase,
  'OIL', ec_prod_fcty_forecast.net_oil_rate(cp_fcst_scen_no,p_object_id,p_daytime,'<='),
  'GAS', ec_prod_fcty_forecast.gas_rate(cp_fcst_scen_no,p_object_id,p_daytime,'<='),
  'COND', ec_prod_fcty_forecast.cond_rate(cp_fcst_scen_no,p_object_id,p_daytime,'<='),
  'WATER', ec_prod_fcty_forecast.water_rate(cp_fcst_scen_no,p_object_id,p_daytime,'<='),
  'DILUENT', ec_prod_fcty_forecast.diluent_rate(cp_fcst_scen_no,p_object_id,p_daytime,'<='),
  'GAS_LIFT', ec_prod_fcty_forecast.gas_lift_rate(cp_fcst_scen_no,p_object_id,p_daytime,'<='),
  'WAT_INJ', ec_prod_fcty_forecast.water_inj_rate(cp_fcst_scen_no,p_object_id,p_daytime,'<='),
  'GAS_INJ', ec_prod_fcty_forecast.gas_inj_rate(cp_fcst_scen_no,p_object_id,p_daytime,'<='),
  'STEAM_INJ', ec_prod_fcty_forecast.steam_inj_rate(cp_fcst_scen_no,p_object_id,p_daytime,'<=')) planned_vol
FROM dual;

CURSOR c_plan_fcty_vol(cp_class_name VARCHAR2) IS
SELECT DECODE(p_phase,
  'OIL', ec_object_plan.oil_rate(p_object_id,p_daytime,cp_class_name,'<='),
  'GAS', ec_object_plan.gas_rate(p_object_id,p_daytime,cp_class_name,'<='),
  'COND', ec_object_plan.cond_rate(p_object_id,p_daytime,cp_class_name,'<='),
  'WATER', ec_object_plan.water_rate(p_object_id,p_daytime,cp_class_name,'<='),
  'DILUENT', ec_object_plan.diluent_rate(p_object_id,p_daytime,cp_class_name,'<='),
  'GAS_LIFT', ec_object_plan.gas_lift_rate(p_object_id,p_daytime,cp_class_name,'<='),
  'WAT_INJ', ec_object_plan.wat_inj_rate(p_object_id,p_daytime,cp_class_name,'<='),
  'GAS_INJ', ec_object_plan.gas_inj_rate(p_object_id,p_daytime,cp_class_name,'<='),
  'STEAM_INJ', ec_object_plan.steam_inj_rate(p_object_id,p_daytime,cp_class_name,'<=')) planned_vol
FROM dual;

BEGIN


  ln_fcst_scen_no := Ecbp_Productionforecast.getRecentProdForecastNo(p_object_id,p_daytime);
   lv2_class_name := EcDp_Objects.getObjClassName(p_object_id);
  IF lv2_class_name IN ('FCTY_CLASS_1','FCTY_CLASS_2') THEN
   lr_fcty_version      := ec_fcty_version.row_by_pk(p_object_id, p_daytime, '<=');
   lv2_potential_method := lr_fcty_version.prod_plan_method;

    IF (lv2_potential_method = Ecdp_Calc_Method.FORECAST) OR (lv2_potential_method IS NULL) THEN
      FOR mycur IN c_forecast_fcty_vol(ln_fcst_scen_no) LOOP
        ln_planned_day_volume := mycur.planned_vol;
      END LOOP;
    ELSIF (lv2_potential_method = Ecdp_Calc_Method.BUDGET_PLAN) THEN
      FOR mycur IN c_plan_fcty_vol('FCTY_PLAN_BUDGET') LOOP
        ln_planned_day_volume := mycur.planned_vol;
      END LOOP;
    ELSIF (lv2_potential_method = Ecdp_Calc_Method.POTENTIAL_PLAN) THEN
      FOR mycur IN c_plan_fcty_vol('FCTY_PLAN_POTENTIAL') LOOP
        ln_planned_day_volume := mycur.planned_vol;
      END LOOP;
    ELSIF (lv2_potential_method = Ecdp_Calc_Method.TARGET_PLAN) THEN
      FOR mycur IN c_plan_fcty_vol('FCTY_PLAN_TARGET') LOOP
        ln_planned_day_volume := mycur.planned_vol;
      END LOOP;
    ELSIF (lv2_potential_method = Ecdp_Calc_Method.OTHER_PLAN) THEN
      FOR mycur IN c_plan_fcty_vol('FCTY_PLAN_OTHER') LOOP
        ln_planned_day_volume := mycur.planned_vol;
      END LOOP;
    END IF;
 ELSE
    NULL;
  END IF;

  RETURN ln_planned_day_volume;

END getPlannedVolumes;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getActualVolumes                                                   --
-- Description    : Returns Actual Volumes based on phase.
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
--                                                                                                 --
-- Using functions: getActualProducedVolumes
--
--                                                                                                 --
-- Configuration                                                                           --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION getActualVolumes(p_object_id VARCHAR2, p_phase VARCHAR2, p_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS

  ln_actual_volume NUMBER;
  lv2_strm_set VARCHAR(32);

BEGIN

  IF p_phase = 'OIL' THEN
     lv2_strm_set := 'PD.0005_04';
     ln_actual_volume := getActualProducedVolumes(p_object_id, lv2_strm_set, p_daytime);

  ELSIF p_phase = 'GAS' THEN
     lv2_strm_set := 'PD.0005_02';
     ln_actual_volume := getActualProducedVolumes(p_object_id, lv2_strm_set, p_daytime);

  ELSIF p_phase = 'COND' THEN
     lv2_strm_set := 'PD.0005';
     ln_actual_volume := getActualProducedVolumes(p_object_id, lv2_strm_set, p_daytime);

  ELSIF p_phase = 'WATER' THEN
     lv2_strm_set := 'PD.0005_07';
     ln_actual_volume := getActualProducedVolumes(p_object_id, lv2_strm_set, p_daytime);

  ELSIF p_phase = 'DILUENT' THEN
     lv2_strm_set := 'PD.0005_16';
     ln_actual_volume := getActualProducedVolumes(p_object_id, lv2_strm_set, p_daytime);

  ELSIF p_phase = 'GAS_LIFT' THEN
     lv2_strm_set := 'PD.0005_17';
     ln_actual_volume := getActualProducedVolumes(p_object_id, lv2_strm_set, p_daytime);

  ELSIF p_phase = 'WAT_INJ' THEN
     lv2_strm_set := 'PD.0005_06';
     ln_actual_volume := getActualProducedVolumes(p_object_id, lv2_strm_set, p_daytime);

  ELSIF p_phase = 'GAS_INJ' THEN
     lv2_strm_set := 'PD.0005_03';
     ln_actual_volume := getActualProducedVolumes(p_object_id, lv2_strm_set, p_daytime);

  ELSIF p_phase = 'STEAM_INJ' THEN
     lv2_strm_set := 'PD.0005_05';
     ln_actual_volume := getActualProducedVolumes(p_object_id, lv2_strm_set, p_daytime);
  END IF;
  RETURN ln_actual_volume;

END getActualVolumes;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getActualProducedVolumes                                                --
-- Description    : Returns Actual Produced Volumes based on stream set.
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                           --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION getActualProducedVolumes(p_object_id VARCHAR2, p_strm_set VARCHAR2, p_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS

ln_actual_prod_volume NUMBER;
lv2_class_name VARCHAR2(32);

CURSOR c_actual_prod_fcty_1 IS
SELECT SUM(EcBp_Stream_Fluid.findNetStdVol(sv.object_id,p_daytime)) prod_vol
FROM strm_set_list ssl, strm_version sv
WHERE sv.op_fcty_class_1_id = p_object_id
AND p_daytime >= ssl.from_date AND (p_daytime < ssl.end_date OR ssl.end_date IS NULL)
AND p_daytime >= sv.daytime AND (p_daytime < sv.end_date OR sv.end_date IS NULL)
AND ssl.stream_set = p_strm_set
AND sv.object_id = ssl.object_id;

CURSOR c_actual_prod_fcty_2 IS
SELECT SUM(EcBp_Stream_Fluid.findNetStdVol(sv.object_id,p_daytime)) prod_vol
FROM strm_set_list ssl, strm_version sv
WHERE sv.op_fcty_class_2_id = p_object_id
AND p_daytime >= ssl.from_date AND (p_daytime < ssl.end_date OR ssl.end_date IS NULL)
AND p_daytime >= sv.daytime AND (p_daytime < sv.end_date OR sv.end_date IS NULL)
AND ssl.stream_set = p_strm_set
AND sv.object_id = ssl.object_id;

 BEGIN
  lv2_class_name := EcDp_Objects.getObjClassName(p_object_id);

  IF lv2_class_name = 'FCTY_CLASS_1' THEN
    FOR mycur IN c_actual_prod_fcty_1 LOOP
      ln_actual_prod_volume := mycur.prod_vol;
    END LOOP;
  ELSIF lv2_class_name = 'FCTY_CLASS_2' THEN
    FOR mycur IN c_actual_prod_fcty_2 LOOP
      ln_actual_prod_volume := mycur.prod_vol;
    END LOOP;
  ELSE
    NULL;
  END IF;

  RETURN ln_actual_prod_volume;

END getActualProducedVolumes;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getAssignedDeferVolumes                                                   --
-- Description    : Returns Assigned Defer Volumes which was assigned.
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : def_day_summary_events
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                           --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION getAssignedDeferVolumes(p_object_id VARCHAR2, p_phase VARCHAR2, p_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS

ln_return NUMBER;
ln_durationfrac NUMBER;
ld_daytime      DATE;
ln_loss NUMBER;

CURSOR c_def_day_summary_event IS
SELECT wde.daytime,
       Nvl(wde.end_date, p_daytime+1) end_date,
DECODE(p_phase,
  'OIL',DEFERRED_OIL_RATE,
  'GAS',DEFERRED_GAS_RATE,
  'WATER',DEFERRED_WATER_RATE,
  'COND',DEFERRED_COND_RATE,
  'DILUENT',DEFERRED_DILUENT_RATE,
  'GAS_LIFT',DEFERRED_GAS_LIFT_RATE,
  'WAT_INJ',DEFERRED_WATER_INJ_RATE,
  'GAS_INJ',DEFERRED_GAS_INJ_RATE,
  'STEAM_INJ',DEFERRED_STEAM_INJ_RATE) loss_rate
FROM well_deferment_event wde, well_version w, system_days s
WHERE  w.object_id = wde.object_id
AND w.op_fcty_class_1_id = p_object_id
AND s.daytime between wde.daytime and nvl(wde.end_date,p_daytime)
AND s.daytime = p_daytime;

BEGIN
  ln_return := 0;
  FOR mycur IN c_def_day_summary_event LOOP
    ln_durationfrac := Least(mycur.end_date, p_daytime+1) - Greatest(mycur.daytime, p_daytime);
    ln_loss := mycur.loss_rate * ln_durationfrac;
    ln_return := nvl(ln_loss,0) + ln_return;
  END LOOP;
  RETURN ln_return;

END getAssignedDeferVolumes;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcDeferments
-- Description    : Procedure used to calculate the deferment values in allocation table and it replaces
--                  the EC_DEFER_01 calculation.
--
-- Using tables   : well_deferment_event (READ), well_day_deferment_alloc (WRITE)
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
--</EC-DOC>
PROCEDURE calcDeferments(p_event_no VARCHAR2,
                         p_asset_id VARCHAR2 DEFAULT NULL,
                         p_from_date DATE DEFAULT NULL,
                         p_to_date DATE DEFAULT NULL) IS

  -- get list of wells directly from deferment event_no
  CURSOR c_well_deferment_event IS
  SELECT object_id, day, end_day
    FROM well_deferment_event
   WHERE event_no = p_event_no;

  -- maybe this cursor is faster than having one query with a long "OR" for asset_type?
  CURSOR c_wells(cp_asset_type VARCHAR2) IS
  SELECT object_id
    FROM well_version wv
   WHERE p_from_date > wv.daytime AND
         p_to_date < NVL(wv.end_date, p_to_date + 1) AND
         wv.op_pu_id = p_asset_id AND cp_asset_type = 'PRODUCTIONUNIT'
   UNION
  SELECT object_id
    FROM well_version wv
   WHERE p_from_date > wv.daytime AND
         p_to_date < NVL(wv.end_date, p_to_date + 1) AND
         wv.op_sub_pu_id = p_asset_id AND cp_asset_type = 'PROD_SUB_UNIT'
   UNION
  SELECT object_id
    FROM well_version wv
   WHERE p_from_date > wv.daytime AND
         p_to_date < NVL(wv.end_date, p_to_date + 1) AND
         wv.op_area_id = p_asset_id AND cp_asset_type = 'AREA'
   UNION
  SELECT object_id
    FROM well_version wv
   WHERE p_from_date > wv.daytime AND
         p_to_date < NVL(wv.end_date, p_to_date + 1) AND
         wv.op_sub_area_id = p_asset_id AND cp_asset_type = 'SUB_AREA'
   UNION
  SELECT object_id
    FROM well_version wv
   WHERE p_from_date > wv.daytime AND
         p_to_date < NVL(wv.end_date, p_to_date + 1) AND
         wv.op_fcty_class_2_id = p_asset_id AND cp_asset_type = 'FCTY_CLASS_2'
   UNION
  SELECT object_id
    FROM well_version wv
   WHERE p_from_date > wv.daytime AND
         p_to_date < NVL(wv.end_date, p_to_date + 1) AND
         wv.op_fcty_class_1_id = p_asset_id AND cp_asset_type = 'FCTY_CLASS_1'
   UNION
  SELECT object_id
    FROM well_version wv
   WHERE p_from_date > wv.daytime AND
         p_to_date < NVL(wv.end_date, p_to_date + 1) AND
         wv.op_well_hookup_id = p_asset_id AND cp_asset_type = 'WELL_HOOKUP';

  lv2_deferment_version VARCHAR2(32);
  lv2_asset_type        VARCHAR2(32);
  ld_start_daytime      DATE;

BEGIN
  -- get deferment version from ctrl_system_attributes
  lv2_deferment_version := ec_ctrl_system_attribute.attribute_text(nvl(p_from_date, sysdate), 'DEFERMENT_VERSION', '<=');
  IF lv2_deferment_version LIKE 'PD.0001%' THEN
    -- Low and Off Deferment
    -- run for an event or an asset in the operational group model
    IF p_event_no IS NOT NULL THEN
      -- run for an event only
      -- loop all wells for the event_no and calculate deferments for all days between DAY and END_DAY
      FOR mycur IN c_well_deferment_event LOOP
        ld_start_daytime := Ecdp_Productionday.getProductionDayStart('WELL',mycur.object_id,mycur.day);
        IF EcDp_month_lock.withinLockedMonth(ld_start_daytime) IS NOT NULL THEN
            EcDp_Month_Lock.raiseValidationError('UPDATING', ld_start_daytime, ld_start_daytime, TRUNC(ld_start_daytime,'MONTH'), 'Cannot calculate deferments for a locked month.');
        END IF;
        EcDp_Month_Lock.localLockCheck('withinLockedMonth', mycur.object_id,
                                      ld_start_daytime, ld_start_daytime,
                                      'INSERTING', 'EcBp_Well_Deferment.calcDefermentForAsset: Cannot update the deferment allocation table in a locked local month.');
        calcDefermentForAsset(mycur.object_id, mycur.day, NVL(mycur.end_day,TRUNC(SYSDATE,'DD'))); -- default is until today if event is open
      END LOOP;
    ELSIF (p_asset_id IS NOT NULL AND p_from_date IS NOT NULL) THEN
      lv2_asset_type := ecdp_objects.GetObjClassName(p_asset_id);
      FOR mycur IN c_wells(lv2_asset_type) LOOP
        calcDefermentForAsset(mycur.object_id, p_from_date, nvl(p_to_date,p_from_date)); -- default is one day
      END LOOP;
      --
    ELSE
      NULL; -- wrong parameters
    END IF;
  ELSE -- user exit
    ue_deferment_event.calcDeferments(p_event_no, p_asset_id, p_from_date, p_to_date);
  END IF;
END calcDeferments;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : calcDefermentForAsset
-- Description    : Procedure calculating deferment for a well and period
--
-- Using tables   : well_deferment_event (READ), well_day_deferment_alloc (WRITE)
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
-- p_from_date and p_to_date are production days we want to execute.
---------------------------------------------------------------------------------------------------
--</EC-DOC>
PROCEDURE calcDefermentForAsset(p_object_id VARCHAR2, p_from_date DATE, p_to_date DATE) IS

  -- fetch records that are involved in the current production day and well.
  -- well_deferment_event.day and end_day are calculated by triggers upon insert and holds production days for start and end of event.
  CURSOR c_well_deferment_event(cp_start_daytime DATE, cp_end_date DATE) IS
  SELECT daytime, -- record start daytime
         greatest(wde.daytime, cp_start_daytime) start_date, -- start_date is minimum start of production day to calc correct duration
         least(nvl(wde.end_date,trunc(SYSDATE,'DD')), cp_start_daytime+1) end_date, -- end_date can be maximum end of production day to calc correct duration
         ec_fcty_deferment_event.event_type(wde.event_no) event_type, -- OFF or LOW events
         decode(ec_fcty_deferment_event.asset_type(wde.event_no), -- if two events starts at the same time, asset_type determines priority
           'WELL',5,
           'FCTY_CLASS_1',1,
           'FCTY_CLASS_2',1,
           'WELL_HOOKUP',3,
           'DEFERMENT_GROUP',2,
           4) asset_type, -- "4" is all equipment classes. TODO, the hardcoded asset_type sort order could be read from the db somehow to make it configurable?
         wde.wde_no,
         wde.deferred_oil_rate,
         wde.deferred_gas_rate,
         wde.deferred_water_rate,
         wde.deferred_cond_rate,
         wde.deferred_diluent_rate,
         wde.deferred_gas_lift_rate,
         wde.deferred_water_inj_rate,
         wde.deferred_gas_inj_rate,
         wde.deferred_steam_inj_rate,
         wde.def_mass_cond_rate,
         wde.def_mass_gas_rate,
         wde.def_mass_oil_rate,
         wde.def_mass_water_rate
    FROM well_deferment_event wde
   WHERE wde.object_id = p_object_id
     AND wde.daytime<=cp_start_daytime
     AND (wde.end_date>=cp_end_date OR wde.end_date IS NULL)
ORDER BY daytime ASC, asset_type ASC;

  -- get all daytimes and end_dates for the production_day and object as sorted "Daytime". This is used to process all periods in the day.
  CURSOR c_start_end_dates(cp_day DATE, cp_start_daytime DATE) IS
    SELECT DISTINCT greatest(wde.daytime, cp_start_daytime) daytime
      FROM well_deferment_event wde
     WHERE wde.object_id = p_object_id
       AND (wde.day = cp_day OR
           (wde.day < cp_day AND (wde.end_day IS NULL OR wde.end_day >= cp_day)))
     UNION
    SELECT DISTINCT least(nvl(wde.end_date,trunc(SYSDATE,'DD')), cp_start_daytime+1) daytime
      FROM well_deferment_event wde
     WHERE wde.object_id = p_object_id
       AND (wde.day = cp_day OR
           (wde.day < cp_day AND (wde.end_day IS NULL OR wde.end_day >= cp_day)))
  ORDER BY daytime ASC;

  -- get production_days between p_from_date and p_to_date valid for the well in a sorted order
  CURSOR c_production_days IS
    SELECT sd.daytime
      FROM system_days sd, well w
     WHERE w.object_id = p_object_id
       AND sd.daytime > w.start_date AND sd.daytime < NVL(w.end_date, sd.daytime + 1)
       AND sd.daytime >= p_from_date AND sd.daytime <= p_to_date -- p_to_date is inclusive
  ORDER BY sd.daytime ASC;

  ln_count NUMBER;
  i NUMBER;
  ln_duration NUMBER;
  ld_start_daytime DATE;
  TYPE myProducts IS RECORD (oil NUMBER,
                             gas NUMBER,
                             water NUMBER,
                             cond NUMBER,
                             diluent NUMBER,
                             gas_lift NUMBER,
                             water_inj NUMBER,
                             gas_inj NUMBER,
                             steam_inj NUMBER,
                             oil_mass NUMBER,
                             gas_mass NUMBER,
                             water_mass NUMBER,
                             cond_mass NUMBER);
  TYPE myRec IS RECORD (wde_no NUMBER,
                        daytime DATE,
                        end_date DATE,
                        deferred_oil_rate NUMBER,
                        deferred_gas_rate NUMBER,
                        deferred_water_rate NUMBER,
                        deferred_cond_rate NUMBER,
                        deferred_diluent_rate NUMBER,
                        deferred_gas_lift_rate NUMBER,
                        deferred_wat_inj_rate NUMBER,
                        deferred_gas_inj_rate NUMBER,
                        deferred_steam_inj_rate NUMBER,
                        deferred_oil_mass NUMBER,
                        deferred_gas_mass NUMBER,
                        deferred_water_mass NUMBER,
                        deferred_cond_mass NUMBER,
                        loss_oil NUMBER,
                        loss_gas NUMBER,
                        loss_water NUMBER,
                        loss_cond NUMBER,
                        loss_diluent NUMBER,
                        loss_gas_lift NUMBER,
                        loss_water_inj NUMBER,
                        loss_gas_inj NUMBER,
                        loss_steam_inj NUMBER,
                        loss_oil_mass NUMBER,
                        loss_gas_mass NUMBER,
                        loss_water_mass NUMBER,
                        loss_cond_mass NUMBER
                        );
  TYPE myTable IS TABLE OF myRec INDEX BY BINARY_INTEGER;
  TYPE myDates IS TABLE OF DATE INDEX BY BINARY_INTEGER;
  lr_dates myDates;
  lr_defer_event myTable;
  lr_potential myProducts;
  lr_remain_pot myProducts;
  lr_remain_qty myProducts;
  lr_well_version WELL_VERSION%ROWTYPE;

BEGIN
  -- loop all days
  FOR cur_prod_day IN c_production_days LOOP -- this cursor loops all production days for the whole period.
    ld_start_daytime := Ecdp_Productionday.getProductionDayStart('WELL',p_object_id,cur_prod_day.daytime);
    -- before processing new events, set old records to 0 for all records for that day and object.
    UPDATE well_day_deferment_alloc
    SET deferred_gas_vol = 0,
        deferred_net_oil_vol = 0,
        deferred_water_vol = 0,
        deferred_cond_vol = 0,
        deferred_gl_vol = 0,
        deferred_diluent_vol = 0,
        deferred_steam_inj_vol = 0,
        deferred_gas_inj_vol = 0,
        deferred_water_inj_vol = 0,
        deferred_gas_mass = 0,
        deferred_net_oil_mass = 0,
        deferred_water_mass = 0,
        deferred_cond_mass = 0,
        last_updated_by = Nvl(ecdp_context.getAppUser(),USER),
        rev_no = rev_no+1
    WHERE object_id = p_object_id
    AND daytime = cur_prod_day.daytime;

    -- check if there are any deferment event for the production_day. If not, we dont need to access well potential etc.
    SELECT COUNT(*)
    INTO ln_count
    FROM well_deferment_event wde
    WHERE wde.object_id = p_object_id
    AND (wde.day = cur_prod_day.daytime OR
        (wde.day < cur_prod_day.daytime AND nvl(wde.end_day, cur_prod_day.daytime) >= cur_prod_day.daytime ) )
    AND nvl(wde.end_date,ld_start_daytime+1) <> ld_start_daytime; -- exclude events which ends exact at the beginning of the day we calculate. End_daytime is exclusive

    -- only access well potential if there are any deferment records
    IF ln_count > 0 THEN
      lr_well_version := ec_well_version.row_by_rel_operator(p_object_id, cur_prod_day.daytime, '<=');
      -- initialise lr_potential
      lr_potential.oil := NULL; lr_potential.gas := NULL; lr_potential.water := NULL; lr_potential.cond := NULL;
      lr_potential.diluent := NULL; lr_potential.gas_lift := NULL;
      lr_potential.water_inj := NULL; lr_potential.gas_inj := NULL; lr_potential.steam_inj := NULL;
      lr_potential.oil_mass := NULL; lr_potential.gas_mass := NULL; lr_potential.water_mass := NULL; lr_potential.cond_mass := NULL;
      -- depending on type of well and configuration of well, get well potentials
      -- dont access well potential for a phase that is not configured for performance reasons
      IF lr_well_version.isOilProducer = 'Y' AND lr_well_version.potential_method IS NOT NULL THEN
        lr_potential.oil := ecbp_well_potential.findOilProductionPotential(p_object_id, cur_prod_day.daytime);
        lr_potential.gas := ecbp_well_potential.findGasProductionPotential(p_object_id, cur_prod_day.daytime);
        lr_potential.water := ecbp_well_potential.findWatProductionPotential(p_object_id, cur_prod_day.daytime);
        lr_remain_pot.oil := lr_potential.oil;
        lr_remain_pot.gas := lr_potential.gas;
        lr_remain_pot.water := lr_potential.water;
      END IF;
      IF lr_well_version.isOilProducer = 'Y' AND lr_well_version.potential_mass_method IS NOT NULL THEN
        lr_potential.oil_mass := ecbp_well_potential.findOilMassProdPotential(p_object_id, cur_prod_day.daytime);
        lr_potential.gas_mass := ecbp_well_potential.findGasMassProdPotential(p_object_id, cur_prod_day.daytime);
        lr_potential.water_mass := ecbp_well_potential.findWaterMassProdPotential(p_object_id, cur_prod_day.daytime);
        lr_remain_pot.oil_mass := lr_potential.oil_mass;
        lr_remain_pot.gas_mass := lr_potential.gas_mass;
        lr_remain_pot.water_mass := lr_potential.water_mass;
      END IF;
      IF lr_well_version.isGasProducer = 'Y' AND lr_well_version.potential_method IS NOT NULL THEN
        lr_potential.cond := ecbp_well_potential.findConProductionPotential(p_object_id, cur_prod_day.daytime);
        lr_potential.gas := ecbp_well_potential.findGasProductionPotential(p_object_id, cur_prod_day.daytime);
        lr_potential.water := ecbp_well_potential.findWatProductionPotential(p_object_id, cur_prod_day.daytime);
        lr_remain_pot.cond := lr_potential.cond;
        lr_remain_pot.gas := lr_potential.gas;
        lr_remain_pot.water := lr_potential.water;
      END IF;
      IF lr_well_version.isGasProducer = 'Y' AND lr_well_version.potential_mass_method IS NOT NULL  THEN
        lr_potential.cond_mass := ecbp_well_potential.findCondMassProdPotential(p_object_id, cur_prod_day.daytime);
        lr_potential.gas_mass := ecbp_well_potential.findGasMassProdPotential(p_object_id, cur_prod_day.daytime);
        lr_potential.water_mass := ecbp_well_potential.findWaterMassProdPotential(p_object_id, cur_prod_day.daytime);
        lr_remain_pot.cond_mass := lr_potential.cond_mass;
        lr_remain_pot.gas_mass := lr_potential.gas_mass;
        lr_remain_pot.water_mass := lr_potential.water_mass;
      END IF;
      IF lr_well_version.isCondensateProducer = 'Y' AND lr_well_version.potential_method IS NOT NULL THEN
        lr_potential.cond := ecbp_well_potential.findConProductionPotential(p_object_id, cur_prod_day.daytime);
        lr_potential.gas := ecbp_well_potential.findGasProductionPotential(p_object_id, cur_prod_day.daytime);
        lr_potential.water := ecbp_well_potential.findWatProductionPotential(p_object_id, cur_prod_day.daytime);
        lr_remain_pot.cond := lr_potential.cond;
        lr_remain_pot.gas := lr_potential.gas;
        lr_remain_pot.water := lr_potential.water;
      END IF;
      IF lr_well_version.isCondensateProducer = 'Y' AND lr_well_version.potential_mass_method IS NOT NULL  THEN
        lr_potential.cond_mass := ecbp_well_potential.findCondMassProdPotential(p_object_id, cur_prod_day.daytime);
        lr_potential.gas_mass := ecbp_well_potential.findGasMassProdPotential(p_object_id, cur_prod_day.daytime);
        lr_potential.water_mass := ecbp_well_potential.findWaterMassProdPotential(p_object_id, cur_prod_day.daytime);
        lr_remain_pot.cond_mass := lr_potential.cond_mass;
        lr_remain_pot.gas_mass := lr_potential.gas_mass;
        lr_remain_pot.water_mass := lr_potential.water_mass;
      END IF;
      IF lr_well_version.isGasInjector = 'Y' THEN
        lr_potential.gas_inj := ecbp_well_potential.findGasInjectionPotential(p_object_id, cur_prod_day.daytime);
        lr_remain_pot.gas_inj := lr_potential.gas_inj;
      END IF;
      IF lr_well_version.isWaterInjector = 'Y' THEN
        lr_potential.water_inj := ecbp_well_potential.findWatInjectionPotential(p_object_id, cur_prod_day.daytime);
        lr_remain_pot.water_inj := lr_potential.water_inj;
      END IF;
      IF lr_well_version.isSteamInjector = 'Y' THEN
        lr_potential.steam_inj := ecbp_well_potential.findSteamInjectionPotential(p_object_id, cur_prod_day.daytime);
        lr_remain_pot.steam_inj := lr_potential.steam_inj;
      END IF;
      IF lr_well_version.gas_lift_method IS NOT NULL THEN
        lr_potential.gas_lift := ecbp_well_potential.findGasLiftPotential(p_object_id, cur_prod_day.daytime);
        lr_remain_pot.gas_lift := lr_potential.gas_lift;
      END IF;
      IF lr_well_version.diluent_method IS NOT NULL THEN
        lr_potential.diluent := ecbp_well_potential.findDiluentPotential(p_object_id, cur_prod_day.daytime);
        lr_remain_pot.diluent := lr_potential.diluent;
      END IF;

      -- find all start and end_dates for all records involved in production_day and the object
      -- returns sorted list of daytime and end_dates as "daytime"
      i:=0;
      FOR cur_daytime IN c_start_end_dates(cur_prod_day.daytime, ld_start_daytime) LOOP
        i:=i+1;
        lr_dates(i) := cur_daytime.daytime;
      END LOOP;

      -- loop all periods and calculate losses
      -- periods are defined by record 1 and 2, then record 2 and 3 etc
      FOR i_idx IN 1..i-1 LOOP
        -- calculate duration for the period
        ln_duration := lr_dates(i_idx+1) - lr_dates(i_idx);
        -- calculate the potential volume for the duration
        lr_remain_qty.oil := lr_remain_pot.oil * ln_duration;
        lr_remain_qty.gas := lr_remain_pot.gas * ln_duration;
        lr_remain_qty.water := lr_remain_pot.water * ln_duration;
        lr_remain_qty.cond := lr_remain_pot.cond * ln_duration;
        lr_remain_qty.diluent := lr_remain_pot.diluent * ln_duration;
        lr_remain_qty.gas_lift := lr_remain_pot.gas_lift * ln_duration;
        lr_remain_qty.water_inj := lr_remain_pot.water_inj * ln_duration;
        lr_remain_qty.gas_inj := lr_remain_pot.gas_inj * ln_duration;
        lr_remain_qty.steam_inj := lr_remain_pot.steam_inj * ln_duration;
        lr_remain_qty.oil_mass := lr_remain_pot.oil_mass * ln_duration;
        lr_remain_qty.gas_mass := lr_remain_pot.gas_mass * ln_duration;
        lr_remain_qty.water_mass := lr_remain_pot.water_mass * ln_duration;
        lr_remain_qty.cond_mass := lr_remain_pot.cond_mass * ln_duration;
        i:=0;
        -- fetch all records which are part of each period
        FOR cur_def_event IN c_well_deferment_event(lr_dates(i_idx), lr_dates(i_idx+1)) LOOP
          i:=i+1;
          lr_defer_event(i).wde_no := cur_def_event.wde_no;
          lr_defer_event(i).daytime := cur_def_event.start_date;
          lr_defer_event(i).end_date := cur_def_event.end_date;
          IF cur_def_event.event_type = 'OFF' THEN
            lr_defer_event(i).deferred_oil_rate := lr_potential.oil;
            lr_defer_event(i).deferred_gas_rate := lr_potential.gas;
            lr_defer_event(i).deferred_water_rate := lr_potential.water;
            lr_defer_event(i).deferred_cond_rate := lr_potential.cond;
            lr_defer_event(i).deferred_diluent_rate := lr_potential.diluent;
            lr_defer_event(i).deferred_gas_lift_rate := lr_potential.gas_lift;
            lr_defer_event(i).deferred_wat_inj_rate := lr_potential.water_inj;
            lr_defer_event(i).deferred_gas_inj_rate := lr_potential.gas_inj;
            lr_defer_event(i).deferred_steam_inj_rate := lr_potential.steam_inj;
            lr_defer_event(i).deferred_oil_mass := lr_potential.oil_mass;
            lr_defer_event(i).deferred_gas_mass := lr_potential.gas_mass;
            lr_defer_event(i).deferred_water_mass := lr_potential.water_mass;
            lr_defer_event(i).deferred_cond_mass := lr_potential.cond_mass;
          ELSE
            lr_defer_event(i).deferred_oil_rate := cur_def_event.deferred_oil_rate;
            lr_defer_event(i).deferred_gas_rate := cur_def_event.deferred_gas_rate;
            lr_defer_event(i).deferred_water_rate := cur_def_event.deferred_water_rate;
            lr_defer_event(i).deferred_cond_rate := cur_def_event.deferred_cond_rate;
            lr_defer_event(i).deferred_diluent_rate := cur_def_event.deferred_diluent_rate;
            lr_defer_event(i).deferred_gas_lift_rate := cur_def_event.deferred_gas_lift_rate;
            lr_defer_event(i).deferred_wat_inj_rate := cur_def_event.deferred_water_inj_rate;
            lr_defer_event(i).deferred_gas_inj_rate := cur_def_event.deferred_gas_inj_rate;
            lr_defer_event(i).deferred_steam_inj_rate := cur_def_event.deferred_steam_inj_rate;
            lr_defer_event(i).deferred_oil_mass := cur_def_event.def_mass_oil_rate;
            lr_defer_event(i).deferred_gas_mass := cur_def_event.def_mass_gas_rate;
            lr_defer_event(i).deferred_water_mass := cur_def_event.def_mass_water_rate;
            lr_defer_event(i).deferred_cond_mass := cur_def_event.def_mass_cond_rate;
          END IF;
          -- calculate how much loss the event has for the current period
          -- also check that we dont overallocate loss to the event, max loss = potential
          -- OIL
          IF lr_remain_qty.oil > (lr_defer_event(i).deferred_oil_rate * ln_duration) THEN
            lr_defer_event(i).loss_oil := lr_defer_event(i).deferred_oil_rate * ln_duration;
          ELSIF lr_remain_qty.oil > 0 AND lr_defer_event(i).deferred_oil_rate > 0 THEN
            lr_defer_event(i).loss_oil := lr_remain_qty.oil;
          ELSE
            lr_defer_event(i).loss_oil := 0;
          END IF;
          lr_remain_qty.oil := lr_remain_qty.oil - lr_defer_event(i).loss_oil;
          -- GAS
          IF lr_remain_qty.gas > (lr_defer_event(i).deferred_gas_rate * ln_duration) THEN
            lr_defer_event(i).loss_gas := lr_defer_event(i).deferred_gas_rate * ln_duration;
          ELSIF lr_remain_qty.gas > 0 AND lr_defer_event(i).deferred_gas_rate > 0 THEN
            lr_defer_event(i).loss_gas := lr_remain_qty.gas;
          ELSE
            lr_defer_event(i).loss_gas := 0;
          END IF;
          lr_remain_qty.gas := lr_remain_qty.gas - lr_defer_event(i).loss_gas;
          -- WAT
          IF lr_remain_qty.water > (lr_defer_event(i).deferred_water_rate * ln_duration) THEN
            lr_defer_event(i).loss_water := lr_defer_event(i).deferred_water_rate * ln_duration;
          ELSIF lr_remain_qty.water > 0 AND lr_defer_event(i).deferred_water_rate > 0 THEN
            lr_defer_event(i).loss_water := lr_remain_qty.water;
          ELSE
            lr_defer_event(i).loss_water := 0;
          END IF;
          lr_remain_qty.water := lr_remain_qty.water - lr_defer_event(i).loss_water;
          -- COND
          IF lr_remain_qty.cond > (lr_defer_event(i).deferred_cond_rate * ln_duration) THEN
            lr_defer_event(i).loss_cond := lr_defer_event(i).deferred_cond_rate * ln_duration;
          ELSIF lr_remain_qty.cond > 0 AND lr_defer_event(i).deferred_cond_rate > 0 THEN
            lr_defer_event(i).loss_cond := lr_remain_qty.cond;
          ELSE
            lr_defer_event(i).loss_cond := 0;
          END IF;
          lr_remain_qty.cond := lr_remain_qty.cond - lr_defer_event(i).loss_cond;
          -- DILUENT
          IF lr_remain_qty.diluent > (lr_defer_event(i).deferred_diluent_rate * ln_duration) THEN
            lr_defer_event(i).loss_diluent := lr_defer_event(i).deferred_diluent_rate * ln_duration;
          ELSIF lr_remain_qty.diluent > 0 AND lr_defer_event(i).deferred_diluent_rate > 0 THEN
            lr_defer_event(i).loss_diluent := lr_remain_qty.diluent;
          ELSE
            lr_defer_event(i).loss_diluent := 0;
          END IF;
          lr_remain_qty.diluent := lr_remain_qty.diluent - lr_defer_event(i).loss_diluent;
          -- GAS LIFT
          IF lr_remain_qty.gas_lift > (lr_defer_event(i).deferred_gas_lift_rate * ln_duration) THEN
            lr_defer_event(i).loss_gas_lift := lr_defer_event(i).deferred_gas_lift_rate * ln_duration;
          ELSIF lr_remain_qty.gas_lift > 0 AND lr_defer_event(i).deferred_gas_lift_rate > 0 THEN
            lr_defer_event(i).loss_gas_lift := lr_remain_qty.gas_lift;
          ELSE
            lr_defer_event(i).loss_gas_lift := 0;
          END IF;
          lr_remain_qty.gas_lift := lr_remain_qty.gas_lift - lr_defer_event(i).loss_gas_lift;
          -- WAT INJ
          IF lr_remain_qty.water_inj > (lr_defer_event(i).deferred_wat_inj_rate * ln_duration) THEN
            lr_defer_event(i).loss_water_inj := lr_defer_event(i).deferred_wat_inj_rate * ln_duration;
          ELSIF lr_remain_qty.water_inj > 0 AND lr_defer_event(i).deferred_wat_inj_rate > 0 THEN
            lr_defer_event(i).loss_water_inj := lr_remain_qty.water_inj;
          ELSE
            lr_defer_event(i).loss_water_inj := 0;
          END IF;
          lr_remain_qty.water_inj := lr_remain_qty.water_inj - lr_defer_event(i).loss_water_inj;
          -- GAS INJ
          IF lr_remain_qty.gas_inj > (lr_defer_event(i).deferred_gas_inj_rate * ln_duration) THEN
            lr_defer_event(i).loss_gas_inj := lr_defer_event(i).deferred_gas_inj_rate * ln_duration;
          ELSIF lr_remain_qty.gas_inj > 0 AND lr_defer_event(i).deferred_gas_inj_rate > 0 THEN
            lr_defer_event(i).loss_gas_inj := lr_remain_qty.gas_inj;
          ELSE
            lr_defer_event(i).loss_gas_inj := 0;
          END IF;
          lr_remain_qty.gas_inj := lr_remain_qty.gas_inj - lr_defer_event(i).loss_gas_inj;
          -- STEAM INJ
          IF lr_remain_qty.steam_inj > (lr_defer_event(i).deferred_steam_inj_rate * ln_duration) THEN
            lr_defer_event(i).loss_steam_inj := lr_defer_event(i).deferred_steam_inj_rate * ln_duration;
          ELSIF lr_remain_qty.steam_inj > 0 AND lr_defer_event(i).deferred_steam_inj_rate > 0 THEN
            lr_defer_event(i).loss_steam_inj := lr_remain_qty.steam_inj;
          ELSE
            lr_defer_event(i).loss_steam_inj := 0;
          END IF;
          lr_remain_qty.steam_inj := lr_remain_qty.steam_inj - lr_defer_event(i).loss_steam_inj;
          -- OIL MASS
          IF lr_remain_qty.oil_mass > (lr_defer_event(i).deferred_oil_mass * ln_duration) THEN
            lr_defer_event(i).loss_oil_mass := lr_defer_event(i).deferred_oil_mass * ln_duration;
          ELSIF lr_remain_qty.oil_mass > 0 AND lr_defer_event(i).deferred_oil_mass > 0 THEN
            lr_defer_event(i).loss_oil_mass := lr_remain_qty.oil_mass;
          ELSE
            lr_defer_event(i).loss_oil_mass := 0;
          END IF;
          lr_remain_qty.oil_mass := lr_remain_qty.oil_mass - lr_defer_event(i).loss_oil_mass;
          -- GAS MASS
          IF lr_remain_qty.gas_mass > (lr_defer_event(i).deferred_gas_mass * ln_duration) THEN
            lr_defer_event(i).loss_gas_mass := lr_defer_event(i).deferred_gas_mass * ln_duration;
          ELSIF lr_remain_qty.gas_mass > 0 AND lr_defer_event(i).deferred_gas_mass > 0 THEN
            lr_defer_event(i).loss_gas_mass := lr_remain_qty.gas_mass;
          ELSE
            lr_defer_event(i).loss_gas_mass := 0;
          END IF;
          lr_remain_qty.gas_mass := lr_remain_qty.gas_mass - lr_defer_event(i).loss_gas_mass;
          -- WAT MASS
          IF lr_remain_qty.water_mass > (lr_defer_event(i).deferred_water_mass * ln_duration) THEN
            lr_defer_event(i).loss_water_mass := lr_defer_event(i).deferred_water_mass * ln_duration;
          ELSIF lr_remain_qty.water_mass > 0 AND lr_defer_event(i).deferred_water_mass > 0 THEN
            lr_defer_event(i).loss_water_mass := lr_remain_qty.water_mass;
          ELSE
            lr_defer_event(i).loss_water_mass := 0;
          END IF;
          lr_remain_qty.water_mass := lr_remain_qty.water_mass - lr_defer_event(i).loss_water_mass;
          -- COND MASS
          IF lr_remain_qty.cond_mass > (lr_defer_event(i).deferred_cond_mass * ln_duration) THEN
            lr_defer_event(i).loss_cond_mass := lr_defer_event(i).deferred_cond_mass * ln_duration;
          ELSIF lr_remain_qty.cond_mass > 0 AND lr_defer_event(i).deferred_cond_mass > 0 THEN
            lr_defer_event(i).loss_cond_mass := lr_remain_qty.cond_mass;
          ELSE
            lr_defer_event(i).loss_cond_mass := 0;
          END IF;
          lr_remain_qty.cond_mass := lr_remain_qty.cond_mass - lr_defer_event(i).loss_cond_mass;

          -- Write to database
          SELECT COUNT(*) INTO ln_count
          FROM well_day_deferment_alloc wda
          WHERE wda.object_id=p_object_id
          AND wda.daytime=cur_prod_day.daytime
          AND wda.wde_no=lr_defer_event(i).wde_no;
          -- Insert or update?
          IF ln_count=0 THEN
            INSERT INTO well_day_deferment_alloc
              (object_id, daytime, wde_no,
               deferred_gas_vol, deferred_net_oil_vol, deferred_water_vol, deferred_cond_vol,
               deferred_gl_vol, deferred_diluent_vol, deferred_steam_inj_vol, deferred_gas_inj_vol, deferred_water_inj_vol,
               deferred_gas_mass, deferred_net_oil_mass, deferred_water_mass, deferred_cond_mass, created_by)
            VALUES
              (p_object_id, cur_prod_day.daytime, lr_defer_event(i).wde_no,
               lr_defer_event(i).loss_gas, lr_defer_event(i).loss_oil, lr_defer_event(i).loss_water, lr_defer_event(i).loss_cond,
               lr_defer_event(i).loss_gas_lift, lr_defer_event(i).loss_diluent, lr_defer_event(i).loss_steam_inj, lr_defer_event(i).loss_gas_inj, lr_defer_event(i).loss_water_inj,
               lr_defer_event(i).loss_gas_mass, lr_defer_event(i).loss_oil_mass, lr_defer_event(i).loss_water_mass, lr_defer_event(i).loss_cond_mass, Nvl(ecdp_context.getAppUser(),USER));
          ELSE -- one event is part of several periods, then we have to update existing record for the wde_no and daytime
            UPDATE well_day_deferment_alloc
            SET deferred_gas_vol = deferred_gas_vol + lr_defer_event(i).loss_gas,
                deferred_net_oil_vol = deferred_net_oil_vol + lr_defer_event(i).loss_oil,
                deferred_water_vol = deferred_water_vol + lr_defer_event(i).loss_water,
                deferred_cond_vol = deferred_cond_vol + lr_defer_event(i).loss_cond,
                deferred_gl_vol = deferred_gl_vol + lr_defer_event(i).loss_gas_lift,
                deferred_diluent_vol = deferred_diluent_vol + lr_defer_event(i).loss_diluent,
                deferred_steam_inj_vol = deferred_steam_inj_vol + lr_defer_event(i).loss_steam_inj,
                deferred_gas_inj_vol = deferred_gas_inj_vol + lr_defer_event(i).loss_gas_inj,
                deferred_water_inj_vol = deferred_water_inj_vol + lr_defer_event(i).loss_water_inj,
                deferred_gas_mass = deferred_gas_mass + lr_defer_event(i).loss_gas_mass,
                deferred_net_oil_mass = deferred_net_oil_mass + lr_defer_event(i).loss_oil_mass,
                deferred_water_mass = deferred_water_mass + lr_defer_event(i).loss_water_mass,
                deferred_cond_mass = deferred_cond_mass + lr_defer_event(i).loss_cond_mass,
                last_updated_by = Nvl(EcDp_Context.getAppUser,USER)
            WHERE object_id = p_object_id
            AND daytime = cur_prod_day.daytime
            AND wde_no = lr_defer_event(i).wde_no;
          END IF;
        END LOOP; -- end processing all events valid for the period
      END LOOP; -- end processing sorted daytime and end_date records
    END IF; -- if no records exist, we never tryed to access more data, exit.
  END LOOP; -- end looping all production days
  COMMIT;
END calcDefermentForAsset;

END EcBp_Deferment_Event;