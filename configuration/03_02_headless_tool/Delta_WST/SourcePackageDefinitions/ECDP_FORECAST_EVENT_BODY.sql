CREATE OR REPLACE PACKAGE BODY EcDp_Forecast_Event IS

/****************************************************************
** Package        :  EcDp_Forecast_Event, body part
**
** $Revision: 1.2 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Forecast Event.
** Documentation  :  www.energy-components.com
**
** Created  : 19.05.2016 Suresh Kumar
**
** Modification history:
**
**   Date     	Whom  	 Change description:
** -------  ----------  ----------------------------------------------
** 19-05-16    kumarsur    Initial Version
** 26-07-16    jainnraj    ECPD-35571: Modified proc updateReasonCodeForChildEvent to remove columns reason_code_2 to 10 and reason_code_type_2 to 10.
** 25-07-16    abdulmaw    ECPD-37247: Added reCalcDeferments, calcDeferments and allocWellDeferredVolume to support calculate forecast event
** 26-09-16    jainnraj    ECPD-39068: Modified allocateGroupRateToWells, sumFromWells, setLossRate and allocWellDeferredVolume to add support for C02.
** 03-01-17    leongwen    ECPD-42319: Modified reCalcDeferments to delete the records in TEMP_FCST_WELL_EVENT_ALLOC where event_no is related to the scenario_id
** 24.01.2017  jainnraj    ECPD-42836: Modified updateStartDateForChildEvent and updateEndDateForChildEvent to update child records startdate/enddate correctly after updating event's startdate/enddate.
** 07.08.2017  jainnraj    ECPD-46835: Modified procedure sumFromWells,setLossRate to correct the error message.
** 08-12-2017 kashisag  ECPD-40487: Corrected local variables naming convention.
****************************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : allocateGroupRateToWells
-- Description    : Allocates the group event deferment rate to all affected wells.
--
--
--
--
-- Preconditions  : Loss rate values from parent are allocated to child wells.
--
-- Postconditions : The loss rates of the child wells are updated.
--
-- Using tables   : fcst_well_event
--
--
--
-- Using functions:
--
-- Configuration
-- required       : -
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE allocateGroupRateToWells(p_event_no NUMBER,
                                   p_user_name VARCHAR2)
--</EC-DOC>
IS
  -- loss rates of parent
  CURSOR c_parent IS
  SELECT * from fcst_well_event w_parent where w_parent.event_no  = p_event_no;

  -- total loss rates of all child that belongs to that parent
  CURSOR c_dt_potential_total IS
    SELECT  sum(OilProductionPotential)   as TotalOilProductionPotential,
            sum(GasProductionPotential)   as TotalGasProductionPotential,
            sum(GasInjectionPotential)    as TotalGasInjectionPotential,
            sum(ConProductionPotential)   as TotalConProductionPotential,
            sum(WaterProductionPotential) as TotalWaterProductionPotential,
            sum(WatInjectionPotential)    as TotalWatInjectionPotential,
            sum(SteamInjectionPotential)  as TotalSteamInjectionPotential,
            sum(DiluentPotential)         as TotalDiluentPotential,
            sum(GasLiftPotential)         as TotalGasLiftPotential,
            sum(Co2InjectionPotential)    as TotalCo2InjectionPotential
    FROM (
      SELECT well_dt.event_id, well_dt.daytime,
            nvl(well_dt.oil_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dt.event_id,null,'OPEN',well_dt.daytime), 'Y', ecbp_well_potential.findOilProductionPotential(well_dt.event_id, well_dt.daytime), null)) as OilProductionPotential,
            nvl(well_dt.gas_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dt.event_id,null,'OPEN',well_dt.daytime), 'Y', ecbp_well_potential.findGasProductionPotential(well_dt.event_id, well_dt.daytime), null)) as GasProductionPotential,
            nvl(well_dt.gas_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dt.event_id,'GI','OPEN',well_dt.daytime), 'Y', ecbp_well_potential.findGasInjectionPotential(well_dt.event_id, well_dt.daytime), null)) as GasInjectionPotential,
            nvl(well_dt.cond_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dt.event_id,null,'OPEN',well_dt.daytime), 'Y', ecbp_well_potential.findConProductionPotential(well_dt.event_id, well_dt.daytime), null)) as ConProductionPotential,
            nvl(well_dt.water_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dt.event_id,null,'OPEN',well_dt.daytime), 'Y', ecbp_well_potential.findWatProductionPotential(well_dt.event_id, well_dt.daytime), null)) as WaterProductionPotential,
            nvl(well_dt.water_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dt.event_id,'WI','OPEN',well_dt.daytime), 'Y', ecbp_well_potential.findWatInjectionPotential(well_dt.event_id, well_dt.daytime), null)) as WatInjectionPotential,
            nvl(well_dt.steam_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dt.event_id,'SI','OPEN',well_dt.daytime), 'Y', ecbp_well_potential.findSteamInjectionPotential(well_dt.event_id, well_dt.daytime), null)) as SteamInjectionPotential,
            nvl(well_dt.diluent_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dt.event_id,null,'OPEN',well_dt.daytime), 'Y', ecbp_well_potential.findDiluentPotential(well_dt.event_id, well_dt.daytime), null)) as DiluentPotential,
            nvl(well_dt.gas_lift_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dt.event_id,null,'OPEN',well_dt.daytime), 'Y', ecbp_well_potential.findGasLiftPotential(well_dt.event_id, well_dt.daytime), null)) as GasLiftPotential,
            nvl(well_dt.co2_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dt.event_id,'CI','OPEN',well_dt.daytime), 'Y', ecbp_well_potential.findCo2InjectionPotential(well_dt.event_id, well_dt.daytime), null)) as Co2InjectionPotential
      FROM fcst_well_event well_dt
      WHERE well_dt.parent_event_no = p_event_no);

  -- Loss rate of each child that belongs to that parent
  CURSOR c_dt_potential IS
    SELECT well_dfmt.event_id, well_dfmt.daytime, well_dfmt.end_date,
           nvl(well_dfmt.oil_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dfmt.event_id,null,'OPEN',well_dfmt.daytime), 'Y', ecbp_well_potential.findOilProductionPotential(well_dfmt.event_id, well_dfmt.daytime), null)) as OilProductionPotential,
           nvl(well_dfmt.gas_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dfmt.event_id,null,'OPEN',well_dfmt.daytime), 'Y', ecbp_well_potential.findGasProductionPotential(well_dfmt.event_id, well_dfmt.daytime), null)) as GasProductionPotential,
           nvl(well_dfmt.gas_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dfmt.event_id,'GI','OPEN',well_dfmt.daytime), 'Y', ecbp_well_potential.findGasInjectionPotential(well_dfmt.event_id, well_dfmt.daytime), null)) as GasInjectionPotential,
           nvl(well_dfmt.cond_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dfmt.event_id,null,'OPEN',well_dfmt.daytime), 'Y', ecbp_well_potential.findConProductionPotential(well_dfmt.event_id, well_dfmt.daytime), null)) as ConProductionPotential,
           nvl(well_dfmt.water_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dfmt.event_id,null,'OPEN',well_dfmt.daytime), 'Y', ecbp_well_potential.findWatProductionPotential(well_dfmt.event_id, well_dfmt.daytime), null)) as WaterProductionPotential,
           nvl(well_dfmt.water_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dfmt.event_id,'WI','OPEN',well_dfmt.daytime), 'Y', ecbp_well_potential.findWatInjectionPotential(well_dfmt.event_id, well_dfmt.daytime), null)) as WatInjectionPotential,
           nvl(well_dfmt.steam_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dfmt.event_id,'SI','OPEN',well_dfmt.daytime), 'Y', ecbp_well_potential.findSteamInjectionPotential(well_dfmt.event_id, well_dfmt.daytime), null)) as SteamInjectionPotential,
           nvl(well_dfmt.diluent_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dfmt.event_id,null,'OPEN',well_dfmt.daytime), 'Y', ecbp_well_potential.findDiluentPotential(well_dfmt.event_id, well_dfmt.daytime), null)) as DiluentPotential,
           nvl(well_dfmt.gas_lift_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dfmt.event_id,null,'OPEN',well_dfmt.daytime), 'Y', ecbp_well_potential.findGasLiftPotential(well_dfmt.event_id, well_dfmt.daytime), null)) as GasLiftPotential,
           nvl(well_dfmt.co2_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dfmt.event_id,'CI','OPEN',well_dfmt.daytime), 'Y', ecbp_well_potential.findCo2InjectionPotential(well_dfmt.event_id, well_dfmt.daytime), null)) as Co2InjectionPotential
    FROM fcst_well_event well_dfmt
    WHERE well_dfmt.parent_event_no = p_event_no;

  ln_well_oil_rate NUMBER;
  ln_well_gas_rate NUMBER;
  ln_well_cond_rate NUMBER;
  ln_well_water_rate NUMBER;
  ln_well_gas_inj_rate NUMBER;
  ln_well_water_inj_rate NUMBER;
  ln_well_steam_inj_rate NUMBER;
  lv2_object_id VARCHAR(32);
  ld_daytime  DATE;
  lv2_last_update_date VARCHAR2(20);
  ln_well_diluent_rate NUMBER;
  ln_well_gas_lift_rate NUMBER;
  ln_well_co2_inj_rate NUMBER;
  ld_valid_from_date DATE;
  ld_valid_to_date DATE;

BEGIN

  lv2_last_update_date := to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS');
  ln_well_oil_rate := NULL;
  ln_well_gas_rate := NULL;
  ln_well_gas_inj_rate := NULL;
  ln_well_cond_rate := NULL;
  ln_well_water_rate :=NULL;
  ln_well_water_inj_rate := NULL;
  ln_well_steam_inj_rate := NULL;
  ln_well_diluent_rate := NULL;
  ln_well_gas_lift_rate := NULL;
  ln_well_co2_inj_rate := NULL;

  lv2_object_id := ec_fcst_well_event.event_id(p_event_no);
  ld_daytime   := ec_fcst_well_event.daytime(p_event_no);

  ld_valid_from_date := ec_fcst_well_event.daytime(p_event_no);
  ld_valid_to_date := ec_fcst_well_event.end_date(p_event_no);


  checkLockInd(p_event_no, ld_valid_from_date, ld_valid_to_date, lv2_object_id);

  FOR cur_parent IN c_parent LOOP
    FOR cur_total IN c_dt_potential_total LOOP
      FOR cur_potential IN c_dt_potential LOOP
        IF cur_total.TotalOilProductionPotential IS NOT NULL AND cur_total.TotalOilProductionPotential != 0 THEN
          IF cur_parent.oil_loss_volume  IS NULL OR cur_parent.end_date  IS NULL THEN
            ln_well_oil_rate := cur_parent.oil_loss_rate  * cur_potential.OilProductionPotential/cur_total.TotalOilProductionPotential;
          ELSE
            ln_well_oil_rate := (cur_parent.oil_loss_volume/((cur_potential.end_date - cur_potential.daytime) * 24) * Ecdp_Timestamp.getNumHours('WELL',  lv2_object_id, ld_daytime)) * cur_potential.OilProductionPotential/cur_total.TotalOilProductionPotential;
          END IF;
        ELSIF cur_total.TotalOilProductionPotential = 0 THEN
          ln_well_oil_rate := 0;
        END IF;
        IF cur_total.TotalGasProductionPotential IS NOT NULL AND cur_total.TotalGasProductionPotential != 0 THEN
          IF cur_parent.gas_loss_volume  IS NULL OR cur_parent.end_date  IS NULL THEN
            ln_well_gas_rate := cur_parent.gas_loss_rate  * cur_potential.GasProductionPotential/cur_total.TotalGasProductionPotential;
          ELSE
            ln_well_gas_rate := (cur_parent.gas_loss_volume/((cur_potential.end_date - cur_potential.daytime) * 24) * Ecdp_Timestamp.getNumHours('WELL',lv2_object_id, ld_daytime)) * cur_potential.GasProductionPotential/cur_total.TotalGasProductionPotential;
          END IF;
        ELSIF cur_total.TotalGasProductionPotential = 0 THEN
          ln_well_gas_rate := 0;
        END IF;
        IF cur_total.TotalGasInjectionPotential IS NOT NULL AND cur_total.TotalGasInjectionPotential != 0 THEN
          IF cur_parent.gas_inj_loss_volume  IS NULL OR cur_parent.end_date  IS NULL THEN
            ln_well_gas_inj_rate := cur_parent.gas_inj_loss_rate  * cur_potential.GasInjectionPotential/cur_total.TotalGasInjectionPotential;
          ELSE
            ln_well_gas_inj_rate := (cur_parent.gas_inj_loss_volume/((cur_potential.end_date - cur_potential.daytime) * 24) * Ecdp_Timestamp.getNumHours('WELL',lv2_object_id, ld_daytime)) * cur_potential.GasInjectionPotential/cur_total.TotalGasInjectionPotential;
          END IF;
        ELSIF cur_total.TotalGasInjectionPotential = 0 THEN
          ln_well_gas_inj_rate := 0;
        END IF;
        IF cur_total.TotalConProductionPotential IS NOT NULL AND cur_total.TotalConProductionPotential != 0 THEN
          IF cur_parent.cond_loss_volume  IS NULL OR cur_parent.end_date  IS NULL THEN
            ln_well_cond_rate:= cur_parent.cond_loss_rate  * cur_potential.ConProductionPotential/cur_total.TotalConProductionPotential;
          ELSE
            ln_well_cond_rate:= (cur_parent.cond_loss_volume/((cur_potential.end_date - cur_potential.daytime) * 24) * Ecdp_Timestamp.getNumHours('WELL',lv2_object_id, ld_daytime)) * cur_potential.ConProductionPotential/cur_total.TotalConProductionPotential;
          END IF;
        ELSIF cur_total.TotalConProductionPotential = 0 THEN
          ln_well_cond_rate := 0;
        END IF;
        IF cur_total.TotalWaterProductionPotential IS NOT NULL AND cur_total.TotalWaterProductionPotential != 0 THEN
          IF cur_parent.water_loss_volume  IS NULL OR cur_parent.end_date  IS NULL THEN
            ln_well_water_rate:= cur_parent.water_loss_rate  * cur_potential.WaterProductionPotential/cur_total.TotalWaterProductionPotential;
          ELSE
            ln_well_water_rate:= (cur_parent.water_loss_volume/((cur_potential.end_date - cur_potential.daytime) * 24) * Ecdp_Timestamp.getNumHours('WELL',lv2_object_id, ld_daytime)) * cur_potential.WaterProductionPotential/cur_total.TotalWaterProductionPotential;
          END IF;
        ELSIF cur_total.TotalWaterProductionPotential = 0 THEN
          ln_well_water_rate := 0;
        END IF;
        IF cur_total.TotalWatInjectionPotential IS NOT NULL AND cur_total.TotalWatInjectionPotential != 0 THEN
          IF cur_parent.water_inj_loss_volume  IS NULL OR cur_parent.end_date  IS NULL THEN
            ln_well_water_inj_rate := cur_parent.water_inj_loss_rate  * cur_potential.WatInjectionPotential/cur_total.TotalWatInjectionPotential;
          ELSE
            ln_well_water_inj_rate := (cur_parent.water_inj_loss_volume/((cur_potential.end_date - cur_potential.daytime) * 24) * Ecdp_Timestamp.getNumHours('WELL',lv2_object_id, ld_daytime)) * cur_potential.WatInjectionPotential/cur_total.TotalWatInjectionPotential;
          END IF;
        ELSIF cur_total.TotalWatInjectionPotential = 0 THEN
          ln_well_water_inj_rate := 0;
        END IF;
        IF cur_total.TotalSteamInjectionPotential IS NOT NULL AND cur_total.TotalSteamInjectionPotential != 0 THEN
          IF cur_parent.steam_inj_loss_volume  IS NULL OR cur_parent.end_date  IS NULL THEN
            ln_well_steam_inj_rate := cur_parent.steam_inj_loss_rate  * cur_potential.SteamInjectionPotential/cur_total.TotalSteamInjectionPotential;
          ELSE
            ln_well_steam_inj_rate := (cur_parent.steam_inj_loss_volume/((cur_potential.end_date - cur_potential.daytime) * 24) * Ecdp_Timestamp.getNumHours('WELL',lv2_object_id, ld_daytime)) * cur_potential.SteamInjectionPotential/cur_total.TotalSteamInjectionPotential;
          END IF;
        ELSIF cur_total.TotalSteamInjectionPotential = 0 THEN
          ln_well_steam_inj_rate := 0;
        END IF;
        IF cur_total.TotalDiluentPotential IS NOT NULL AND cur_total.TotalDiluentPotential != 0 THEN
          IF cur_parent.diluent_loss_volume  IS NULL OR cur_parent.end_date  IS NULL THEN
            ln_well_diluent_rate := cur_parent.diluent_loss_rate  * cur_potential.DiluentPotential/cur_total.TotalDiluentPotential;
          ELSE
            ln_well_diluent_rate := (cur_parent.diluent_loss_volume/((cur_potential.end_date - cur_potential.daytime) * 24) * Ecdp_Timestamp.getNumHours('WELL',  lv2_object_id, ld_daytime)) * cur_potential.DiluentPotential/cur_total.TotalDiluentPotential;
          END IF;
        ELSIF cur_total.TotalDiluentPotential = 0 THEN
          ln_well_diluent_rate := 0;
        END IF;
        IF cur_total.TotalGasLiftPotential IS NOT NULL AND cur_total.TotalGasLiftPotential != 0 THEN
          IF cur_parent.gas_lift_loss_volume  IS NULL OR cur_parent.end_date  IS NULL THEN
            ln_well_gas_lift_rate := cur_parent.gas_lift_loss_rate  * cur_potential.GasLiftPotential/cur_total.TotalGasLiftPotential;
          ELSE
            ln_well_gas_lift_rate := (cur_parent.gas_lift_loss_volume/((cur_potential.end_date - cur_potential.daytime) * 24) * Ecdp_Timestamp.getNumHours('WELL',  lv2_object_id, ld_daytime)) * cur_potential.GasLiftPotential/cur_total.TotalGasLiftPotential;
          END IF;
        ELSIF cur_total.TotalGasLiftPotential = 0 THEN
          ln_well_gas_lift_rate := 0;
        END IF;
         IF cur_total.TotalCo2InjectionPotential IS NOT NULL AND cur_total.TotalCo2InjectionPotential != 0 THEN
          IF cur_parent.co2_inj_loss_volume  IS NULL OR cur_parent.end_date  IS NULL THEN
            ln_well_co2_inj_rate := cur_parent.co2_inj_loss_rate  * cur_potential.Co2InjectionPotential/cur_total.TotalCo2InjectionPotential;
          ELSE
            ln_well_co2_inj_rate := (cur_parent.co2_inj_loss_volume/((cur_potential.end_date - cur_potential.daytime) * 24) * Ecdp_Timestamp.getNumHours('WELL',  lv2_object_id, ld_daytime)) * cur_potential.Co2InjectionPotential/cur_total.TotalCo2InjectionPotential;
          END IF;
        ELSIF cur_total.TotalCo2InjectionPotential = 0 THEN
          ln_well_co2_inj_rate := 0;
        END IF;

        UPDATE fcst_well_event w
        SET w.oil_loss_rate       = ln_well_oil_rate,
            w.gas_loss_rate       = ln_well_gas_rate,
            w.gas_inj_loss_rate   = ln_well_gas_inj_rate,
            w.cond_loss_rate      = ln_well_cond_rate,
            w.water_loss_rate     = ln_well_water_rate,
            w.water_inj_loss_rate = ln_well_water_inj_rate,
            w.steam_inj_loss_rate = ln_well_steam_inj_rate,
            w.diluent_loss_rate   = ln_well_diluent_rate,
            w.gas_lift_loss_rate  = ln_well_gas_lift_rate,
            w.co2_inj_loss_rate   = ln_well_co2_inj_rate,
            w.last_updated_by     = p_user_name,
            w.last_updated_date   = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS')
        WHERE w.parent_event_no = p_event_no
        AND w.parent_object_id =  lv2_object_id
        AND w.parent_daytime = ld_daytime
        AND w.event_id = cur_potential.event_id
        AND w.daytime = cur_potential.daytime;

      END LOOP;
    END LOOP;
  END LOOP;

END allocateGroupRateToWells;

---------------------------------------------------------------------------------------------------
-- Procedure      : checkLockInd
-- Description    : Checks lock indicator from SYSTEM_MONTH, for given daytime value, Returns error if
--                  lock ind = Y
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
PROCEDURE checkLockInd(p_result_no NUMBER, p_daytime DATE, p_end_date DATE, p_object_id VARCHAR2)
IS
lv2_lock_ind VARCHAR(1);
lv2_object_class_name VARCHAR(32);
ln_prod_day_offset NUMBER;
ld_new_daytime DATE;
ld_new_end_date DATE;

BEGIN

  lv2_object_class_name := ecdp_objects.GetObjClassName(p_object_id);
  ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset(lv2_object_class_name,p_object_id, p_daytime)/24;

  ld_new_daytime := p_daytime - ln_prod_day_offset;
  ld_new_end_date := p_end_date - ln_prod_day_offset;

  EcDp_Month_Lock.validatePeriodForLockOverlap('UPDATING', ld_new_daytime, ld_new_end_date,
                                               'Event No:'|| p_result_no, p_object_id);

END checkLockInd;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : sumFromWells
-- Description    : Sums the loss rates from child events and updates the parent.
--
--
--
-- Preconditions  : --
--
-- Postconditions : Loss rates for parent are updated.
--
-- Using tables   : fcst_well_event
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
PROCEDURE sumFromWells(p_event_no NUMBER, p_user_name VARCHAR2)
--</EC-DOC>
IS

  CURSOR c_dt_potential_total IS
  SELECT sum(OilProductionPotential) as TotalOilProductionPotential,
         sum(GasProductionPotential) as TotalGasProductionPotential,
         sum(GasInjectionPotential) as TotalGasInjectionPotential,
         sum(ConProductionPotential) as TotalConProductionPotential,
         sum(WaterProductionPotential) as TotalWaterProductionPotential,
         sum(WatInjectionPotential)  as TotalWatInjectionPotential,
         sum(SteamInjectionPotential)  as TotalSteamInjectionPotential,
         sum(DiluentPotential) as TotalDiluentPotential,
         sum(GasLiftPotential) as TotalGasLiftPotential,
         sum(Co2InjectionPotential) as TotalCo2InjectionPotential
  FROM (
      SELECT well_e_dt.event_id, well_e_dt.daytime,
        nvl(well_e_dt.oil_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.event_id,null,'OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findOilProductionPotential(well_e_dt.event_id, well_e_dt.daytime), null)) as OilProductionPotential,
        nvl(well_e_dt.gas_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.event_id,null,'OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findGasProductionPotential(well_e_dt.event_id, well_e_dt.daytime), null)) as GasProductionPotential,
        nvl(well_e_dt.gas_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.event_id,'GI','OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findGasInjectionPotential(well_e_dt.event_id, well_e_dt.daytime), null)) as GasInjectionPotential,
        nvl(well_e_dt.cond_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.event_id,null,'OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findConProductionPotential(well_e_dt.event_id, well_e_dt.daytime), null)) as ConProductionPotential,
        nvl(well_e_dt.water_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.event_id,null,'OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findWatProductionPotential(well_e_dt.event_id, well_e_dt.daytime), null)) as WaterProductionPotential,
        nvl(well_e_dt.water_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.event_id,'WI','OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findWatInjectionPotential(well_e_dt.event_id, well_e_dt.daytime), null)) as WatInjectionPotential,
        nvl(well_e_dt.steam_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.event_id,'SI','OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findSteamInjectionPotential(well_e_dt.event_id, well_e_dt.daytime), null)) as SteamInjectionPotential,
        nvl(well_e_dt.diluent_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.event_id,null,'OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findDiluentPotential(well_e_dt.event_id, well_e_dt.daytime), null)) as DiluentPotential,
        nvl(well_e_dt.gas_lift_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.event_id,null,'OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findGasLiftPotential(well_e_dt.event_id, well_e_dt.daytime), null)) as GasLiftPotential,
        nvl(well_e_dt.co2_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.event_id,'CI','OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findCo2InjectionPotential(well_e_dt.event_id, well_e_dt.daytime), null)) as Co2InjectionPotential
      FROM fcst_well_event well_e_dt
      WHERE well_e_dt.parent_event_no = p_event_no
      AND  well_e_dt.deferment_type = 'GROUP_CHILD');

  ln_well_oil_rate NUMBER;
  ln_well_gas_rate NUMBER;
  ln_well_cond_rate NUMBER;
  ln_well_water_rate NUMBER;
  ln_well_gas_inj_rate NUMBER;
  ln_well_water_inj_rate NUMBER;
  ln_well_steam_inj_rate NUMBER;
  ln_well_diluent_rate NUMBER;
  ln_well_gas_lift_rate NUMBER;
  ln_well_co2_inj_rate NUMBER;
  lv2_object_id VARCHAR(32);
  ld_daytime  DATE;
  ln_event_loss_oil NUMBER := null;
  ln_event_loss_gas NUMBER := null;
  ln_event_loss_cond NUMBER := null;
  ln_event_loss_water NUMBER := null;
  ln_event_loss_water_inj NUMBER := null;
  ln_event_loss_steam_inj NUMBER := null;
  ln_event_loss_gas_inj NUMBER := null;
  ln_event_loss_diluent NUMBER := null;
  ln_event_loss_gas_lift NUMBER := null;
  ln_event_loss_co2_inj NUMBER := null;
  ln_diff     NUMBER := null;
  ln_chk_child NUMBER := null;
  ld_chk_parent_end_date DATE;
  ld_valid_from_date DATE;
  ld_valid_to_date DATE;
  lv_deferment_type fcst_well_event.deferment_type%TYPE;

BEGIN

  BEGIN
        SELECT event_id,daytime,end_date,deferment_type
        INTO lv2_object_id,ld_valid_from_date,ld_valid_to_date,lv_deferment_type
        FROM fcst_well_event
        WHERE event_no  = p_event_no;
   EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20226, 'An error occurred while fetching data for event no- '||p_event_no);
   END;

  checkLockInd(p_event_no, ld_valid_from_date, ld_valid_to_date, lv2_object_id);

    ln_event_loss_oil := EcBp_Forecast_Event.getParentEventLossRate(p_event_no, 'OIL',lv_deferment_type);
    ln_event_loss_gas := EcBp_Forecast_Event.getParentEventLossRate(p_event_no, 'GAS',lv_deferment_type);
    ln_event_loss_cond := EcBp_Forecast_Event.getParentEventLossRate(p_event_no, 'COND',lv_deferment_type);
    ln_event_loss_water := EcBp_Forecast_Event.getParentEventLossRate(p_event_no, 'WATER',lv_deferment_type);
    ln_event_loss_water_inj := EcBp_Forecast_Event.getParentEventLossRate(p_event_no, 'WAT_INJ',lv_deferment_type);
    ln_event_loss_steam_inj := EcBp_Forecast_Event.getParentEventLossRate(p_event_no, 'STEAM_INJ',lv_deferment_type);
    ln_event_loss_gas_inj := EcBp_Forecast_Event.getParentEventLossRate(p_event_no, 'GAS_INJ',lv_deferment_type);
    ln_event_loss_diluent := EcBp_Forecast_Event.getParentEventLossRate(p_event_no, 'DILUENT',lv_deferment_type);
    ln_event_loss_gas_lift := EcBp_Forecast_Event.getParentEventLossRate(p_event_no, 'GAS_LIFT',lv_deferment_type);
    ln_event_loss_co2_inj := EcBp_Forecast_Event.getParentEventLossRate(p_event_no, 'CO2_INJ',lv_deferment_type);
    ln_diff := abs((ld_valid_to_date - ld_valid_from_date)*24);
    ld_chk_parent_end_date := ld_valid_to_date;

    SELECT COUNT(1) INTO ln_chk_child
    FROM fcst_well_event
    WHERE parent_event_no = p_event_no
    AND deferment_type = 'GROUP_CHILD'
    AND (daytime >= ld_valid_from_date OR (end_date < ld_valid_to_date OR (ld_valid_to_date IS NULL AND end_date IS NOT NULL)));

  FOR cur_potential IN c_dt_potential_total LOOP
    IF (ln_chk_child > 0) AND
        ld_chk_parent_end_date IS NOT NULL THEN

      ln_well_oil_rate := (ln_event_loss_oil * 24/ln_diff);
      ln_well_gas_rate := (ln_event_loss_gas * 24/ln_diff);
      ln_well_gas_inj_rate := (ln_event_loss_gas_inj * 24/ln_diff);
      ln_well_cond_rate := (ln_event_loss_cond * 24/ln_diff);
      ln_well_water_rate := (ln_event_loss_water * 24/ln_diff);
      ln_well_water_inj_rate := (ln_event_loss_water_inj * 24/ln_diff);
      ln_well_steam_inj_rate := (ln_event_loss_steam_inj * 24/ln_diff);
      ln_well_diluent_rate := (ln_event_loss_diluent * 24/ln_diff);
      ln_well_gas_lift_rate := (ln_event_loss_gas_lift * 24/ln_diff);
      ln_well_co2_inj_rate := (ln_event_loss_co2_inj * 24/ln_diff);

    ELSE

      ln_well_oil_rate        := cur_potential.totaloilproductionpotential;
      ln_well_gas_rate        := cur_potential.totalgasproductionpotential;
      ln_well_gas_inj_rate    := cur_potential.totalgasinjectionpotential;
      ln_well_cond_rate       := cur_potential.totalconproductionpotential;
      ln_well_water_rate      := cur_potential.totalwaterproductionpotential;
      ln_well_water_inj_rate  := cur_potential.totalwatinjectionpotential;
      ln_well_steam_inj_rate  := cur_potential.totalsteaminjectionpotential;
      ln_well_diluent_rate    := cur_potential.TotalDiluentPotential;
      ln_well_gas_lift_rate   := cur_potential.TotalGasLiftPotential;
      ln_well_co2_inj_rate    := cur_potential.TotalCo2InjectionPotential;

     END IF;
  END LOOP;

  UPDATE fcst_well_event w
  SET w.oil_loss_rate       = ln_well_oil_rate,
      w.gas_loss_rate       = ln_well_gas_rate,
      w.gas_inj_loss_rate   = ln_well_gas_inj_rate,
      w.cond_loss_rate      = ln_well_cond_rate,
      w.water_loss_rate     = ln_well_water_rate,
      w.water_inj_loss_rate = ln_well_water_inj_rate,
      w.steam_inj_loss_rate = ln_well_steam_inj_rate,
      w.diluent_loss_rate   = ln_well_diluent_rate,
      w.gas_lift_loss_rate  = ln_well_gas_lift_rate,
      w.co2_inj_loss_rate   = ln_well_co2_inj_rate,
      w.last_updated_by     = p_user_name
  WHERE w.event_no = p_event_no;

  Ue_Forecast_Event.sumFromWells(p_event_no, p_user_name);

END sumFromWells;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : insertWells
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
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
PROCEDURE insertWells(p_group_event_no number, p_forecast_id VARCHAR2, p_scenario_id VARCHAR2, p_event_type VARCHAR2, p_object_typ VARCHAR2, p_object_id VARCHAR2, p_daytime DATE, p_end_date DATE DEFAULT NULL, p_username VARCHAR2)
--</EC-DOC>
IS

  lv_defer_overlap_flag         VARCHAR2(2000);
  lv_defer_autoinsert_flag      VARCHAR2(2000);
  ue_flag CHAR;

  CURSOR c1_network IS
  SELECT max(cce.object_id) AS object_id
  FROM calc_collection_element cce, calc_collection c
  WHERE c.object_id = cce.object_id
  AND c.class_name= 'ALLOC_NETWORK'
  AND cce.element_id = p_object_id;

  CURSOR c1_eqpm_network IS
  SELECT max(cce.object_id) AS object_id
  FROM calc_collection_element cce
  INNER JOIN calc_collection c ON c.object_id = cce.object_id
  INNER JOIN ov_eqpm eqpm ON cce.element_id = eqpm.alloc_netw_node_id
  WHERE c.class_name= 'ALLOC_NETWORK'
  AND eqpm.object_id = p_object_id;


  CURSOR c2_getAllWells (cp2_group_event_no VARCHAR2, cp2_object_id VARCHAR2, cp2_daytime DATE, cp2_end_date DATE, cp2_forecast_id VARCHAR2, cp2_scenario_id VARCHAR2, cp2_event_type VARCHAR2, cp2_username VARCHAR2, cp2_alloc_network_id VARCHAR2) IS
  SELECT distinct w.object_id, 'WELL', cp2_group_event_no, cp2_object_id, cp2_daytime, GREATEST(w.start_date, cp2_daytime), LEAST(nvl(w.end_date, cp2_end_date), cp2_end_date),-- 'WELL_DT',
         cp2_forecast_id, cp2_scenario_id, cp2_event_type, 'GROUP_CHILD', cp2_username
  FROM well w, well_version wv
  WHERE w.object_id = wv.object_id
  AND wv.alloc_flag = 'Y' -- only include wells that are part of allocation network
  AND wv.daytime BETWEEN ec_well_version.prev_equal_daytime(wv.object_id, cp2_daytime)
  AND ec_well_version.prev_equal_daytime(wv.object_id, nvl(cp2_end_date, Ecdp_Timestamp.getCurrentSysdate))
  AND ( wv.OP_FCTY_CLASS_1_ID       = cp2_object_id or
        wv.OP_FCTY_CLASS_2_ID       = cp2_object_id or
        wv.OP_WELL_HOOKUP_ID  = cp2_object_id or
        wv.OP_AREA_ID         = cp2_object_id    )
  AND EXISTS (SELECT 1
              FROM calc_collection_element cce, calc_collection c
              WHERE c.object_id = cce.object_id
              AND c.class_name= 'ALLOC_NETWORK'
              AND (wv.op_well_hookup_id = cce.element_id OR wv.op_fcty_class_1_id = cce.element_id OR wv.op_fcty_class_2_id = cce.element_id)
              AND cce.element_id in (SELECT DISTINCT from_node_id FROM ov_stream START WITH from_node_id = cp2_object_id
                                     CONNECT BY NOCYCLE PRIOR from_node_id=to_node_id)
              AND cce.object_id = cp2_alloc_network_id) -- Alloc network id
  AND NOT EXISTS (SELECT fwe.event_id  -- exclude wells already down
                  FROM FCST_WELL_EVENT fwe
                  WHERE fwe.event_id = w.object_id
                  AND   fwe.EVENT_TYPE = 'DOWN'
                  AND cp2_event_type = 'DOWN'
                  AND lv_defer_overlap_flag = 'N'
                  AND cp2_forecast_id = fwe.forecast_id
                  AND cp2_scenario_id = fwe.object_id
                  AND fwe.DEFERMENT_TYPE in ('SINGLE', 'GROUP_CHILD')
                  AND Nvl(fwe.end_date,Ecdp_Timestamp.getCurrentSysdate) >= cp2_daytime AND fwe.daytime <= Nvl(cp2_end_date, Ecdp_Timestamp.getCurrentSysdate))
  ORDER BY w.object_id;


  CURSOR c2_getAllEqpmConnWells (cp2_group_event_no VARCHAR2, cp2_object_id VARCHAR2, cp2_daytime DATE, cp2_end_date DATE, cp2_forecast_id VARCHAR2, cp2_scenario_id VARCHAR2, cp2_event_type VARCHAR2, cp2_username VARCHAR2) IS
  SELECT w.object_id, 'WELL', cp2_group_event_no, cp2_object_id, cp2_daytime, GREATEST(w.start_date, cp2_daytime), LEAST(nvl(w.end_date, cp2_end_date), cp2_end_date),-- 'WELL_DT',
         cp2_forecast_id, cp2_scenario_id, cp2_event_type, 'GROUP_CHILD', cp2_username
  FROM well w, well_version wv
  WHERE w.object_id = wv.object_id
  AND wv.daytime BETWEEN ec_well_version.prev_equal_daytime(wv.object_id, cp2_daytime)
  AND ec_well_version.prev_equal_daytime(wv.object_id, nvl(cp2_end_date, Ecdp_Timestamp.getCurrentSysdate))
  AND EXISTS (SELECT 1 FROM eqpm_conn
                WHERE object_id = cp2_object_id
                AND daytime <= cp2_daytime AND Nvl(end_date,Ecdp_Timestamp.getCurrentSysdate) >= Nvl(cp2_end_date,Ecdp_Timestamp.getCurrentSysdate)
                AND eqpm_conn_name = w.object_id)
  AND NOT EXISTS (SELECT fwe.event_id  -- exclude wells already down
                  FROM FCST_WELL_EVENT fwe
                  WHERE fwe.event_id = w.object_id
                  AND   fwe.EVENT_TYPE = 'DOWN'
                  AND cp2_event_type = 'DOWN'
                  AND lv_defer_overlap_flag = 'N'
                  AND cp2_forecast_id = fwe.forecast_id
                  AND cp2_scenario_id = fwe.object_id
                  AND fwe.DEFERMENT_TYPE in ('SINGLE', 'GROUP_CHILD')
                  AND Nvl(fwe.end_date,Ecdp_Timestamp.getCurrentSysdate) >= cp2_daytime AND fwe.daytime <= Nvl(cp2_end_date, Ecdp_Timestamp.getCurrentSysdate))
  ORDER BY w.object_id;


  CURSOR c2_getAllEpqmWells (cp2_group_event_no VARCHAR2, cp2_op_group_object_id VARCHAR2, cp2_object_id VARCHAR2, cp2_daytime DATE, cp2_end_date DATE, cp2_forecast_id VARCHAR2, cp2_scenario_id VARCHAR2, cp2_event_type VARCHAR2, cp2_username VARCHAR2) IS
  SELECT w.object_id, 'WELL', cp2_group_event_no, cp2_object_id, cp2_daytime, GREATEST(w.start_date, cp2_daytime), LEAST(nvl(w.end_date, cp2_end_date), cp2_end_date),-- 'WELL_DT',
         cp2_forecast_id, cp2_scenario_id, cp2_event_type, 'GROUP_CHILD', cp2_username
  FROM well w, well_version wv
  WHERE w.object_id = wv.object_id
  AND wv.alloc_flag = 'Y' -- only include wells that are part of allocation network
  AND wv.daytime BETWEEN ec_well_version.prev_equal_daytime(wv.object_id, cp2_daytime)
  AND ec_well_version.prev_equal_daytime(wv.object_id, nvl(cp2_end_date, Ecdp_Timestamp.getCurrentSysdate))
  AND EXISTS (SELECT 1
              FROM calc_collection_element cce, calc_collection c
              WHERE c.object_id = cce.object_id
              AND c.class_name= 'ALLOC_NETWORK'
              AND (wv.op_well_hookup_id = cce.element_id OR wv.op_fcty_class_1_id = cce.element_id OR wv.op_fcty_class_2_id = cce.element_id)
              AND cce.element_id in (SELECT DISTINCT from_node_id FROM ov_stream START WITH from_node_id = cp2_op_group_object_id
                                     CONNECT BY NOCYCLE PRIOR from_node_id=to_node_id))
  AND NOT EXISTS (SELECT fwe.event_id  -- exclude wells already down
                  FROM FCST_WELL_EVENT fwe
                  WHERE fwe.event_id = w.object_id
                  AND   fwe.EVENT_TYPE = 'DOWN'
                  AND cp2_event_type = 'DOWN'
                  AND lv_defer_overlap_flag = 'N'
                  AND cp2_forecast_id = fwe.forecast_id
                  AND cp2_scenario_id = fwe.object_id
                  AND fwe.DEFERMENT_TYPE in ('SINGLE', 'GROUP_CHILD')
                  AND Nvl(fwe.end_date,Ecdp_Timestamp.getCurrentSysdate) >= cp2_daytime AND fwe.daytime <= Nvl(cp2_end_date, Ecdp_Timestamp.getCurrentSysdate))
  ORDER BY w.object_id;



  CURSOR c2_getAllTankWells (cp2_group_event_no VARCHAR2, cp2_object_id VARCHAR2, cp2_daytime DATE, cp2_end_date DATE, cp2_forecast_id VARCHAR2, cp2_scenario_id VARCHAR2, cp2_event_type VARCHAR2, cp2_username VARCHAR2) IS
  SELECT w.object_id, 'WELL', cp2_group_event_no, cp2_object_id, cp2_daytime, GREATEST(w.start_date, cp2_daytime), LEAST(nvl(w.end_date, cp2_end_date), cp2_end_date),-- 'WELL_DT',
         cp2_forecast_id, cp2_scenario_id, cp2_event_type, 'GROUP_CHILD', cp2_username
  FROM tank t
  INNER JOIN tank_version tv on tv.object_id = t.object_id
  INNER JOIN well w on w.object_id = tv.tank_well
  INNER JOIN well_version wv on wv.object_id = w.object_id
  WHERE t.object_id = cp2_object_id
  AND wv.daytime BETWEEN ec_well_version.prev_equal_daytime(wv.object_id, cp2_daytime)
  AND ec_well_version.prev_equal_daytime(wv.object_id, nvl(cp2_end_date, Ecdp_Timestamp.getCurrentSysdate))
  AND NOT EXISTS (SELECT fwe.event_id  -- exclude wells already down
                  FROM FCST_WELL_EVENT fwe
                  WHERE fwe.event_id = w.object_id
                  AND   fwe.EVENT_TYPE = 'DOWN'
                  AND cp2_event_type = 'DOWN'
                  AND lv_defer_overlap_flag = 'N'
                  AND cp2_forecast_id = fwe.forecast_id
                  AND cp2_scenario_id = fwe.object_id
                  AND fwe.DEFERMENT_TYPE in ('SINGLE', 'GROUP_CHILD')
                  AND Nvl(fwe.end_date,Ecdp_Timestamp.getCurrentSysdate) >= cp2_daytime AND fwe.daytime <= Nvl(cp2_end_date, Ecdp_Timestamp.getCurrentSysdate))
  ORDER BY w.object_id;



  CURSOR c3_getWellVersions (cp_object_id VARCHAR2, cp3_object_id VARCHAR2, cp3_daytime DATE, cp3_end_date DATE) IS
  SELECT a.daytime, a.end_date
  FROM well_version a
  WHERE a.object_id = cp3_object_id
  AND a.daytime BETWEEN ec_well_version.prev_equal_daytime(a.object_id, cp3_daytime)
  AND ec_well_version.prev_equal_daytime(a.object_id, nvl(cp3_end_date, Ecdp_Timestamp.getCurrentSysdate))
  AND ( a.OP_FCTY_CLASS_1_ID = cp_object_id or
        a.OP_FCTY_CLASS_2_ID = cp_object_id or
        a.OP_WELL_HOOKUP_ID  = cp_object_id or
        a.OP_AREA_ID         = cp_object_id )
  ORDER BY a.daytime;

  ln_group_event_no             NUMBER;
  ln_WellVersions_cnt           NUMBER;
  ln_Rowcnt                     NUMBER;
  lc_eqpm_conn                  CHAR;
  lv2_op_group_object_id        VARCHAR2(32);         -- Variable used for "EQPM" object_type

  lv2_alloc_netwk_id_c1         VARCHAR2(32);                                   -- Variable  used for holding "c1_..." cursor value

  lv2_object_id_c2              FCST_WELL_EVENT.event_id%TYPE;             -- Variables used for holding "c2_..." cursor value
  lv2_object_type_c2            FCST_WELL_EVENT.OBJECT_TYPE%TYPE;
  lv2_forecast_id_c2            FCST_WELL_EVENT.FORECAST_ID%TYPE;
  lv2_scenario_id_c2            FCST_WELL_EVENT.object_id%TYPE;
  ln_parent_event_no_c2         FCST_WELL_EVENT.PARENT_EVENT_NO%TYPE;
  lv2_parent_object_id_c2       FCST_WELL_EVENT.PARENT_OBJECT_ID%TYPE;
  ld_parent_daytime_c2          FCST_WELL_EVENT.PARENT_DAYTIME%TYPE;
  ld_daytime_c2                 FCST_WELL_EVENT.DAYTIME%TYPE;
  ld_end_date_c2                FCST_WELL_EVENT.END_DATE%TYPE;
  lv2_event_type_c2             FCST_WELL_EVENT.EVENT_TYPE%TYPE;
  lv2_deferment_type_c2         FCST_WELL_EVENT.DEFERMENT_TYPE%TYPE;
  lv2_created_by_c2             FCST_WELL_EVENT.CREATED_BY%TYPE;

  ld_daytime_c3                 DATE;                                           -- Variables used for holding "c3_..." cursor value
  ld_end_date_c3                DATE;
  lv2_prev_object_id            VARCHAR2(32);
  ln_tmp_event_no               FCST_WELL_EVENT.EVENT_NO%TYPE;

  typ_object_id                 t_object_id                   := t_object_id();
  typ_object_type               t_object_type                 := t_object_type();
  typ_forecast_id               t_forecast_id                 := t_forecast_id();
  typ_scenario_id               t_scenario_id                 := t_scenario_id();
  typ_parent_event_no           t_parent_event_no             := t_parent_event_no();
  typ_parent_object_id          t_parent_object_id            := t_parent_object_id();
  typ_parent_daytime            t_parent_daytime              := t_parent_daytime();
  typ_daytime                   t_daytime                     := t_daytime();
  typ_end_date                  t_end_date                    := t_end_date();
  typ_event_type                t_event_type                  := t_event_type();
  typ_deferment_type            t_deferment_type              := t_deferment_type();
  typ_created_by                t_created_by                  := t_created_by();
  ln_connection_count      NUMBER:=0;

BEGIN

  Ue_Forecast_Event.insertWells(p_group_event_no, p_forecast_id, p_scenario_id, p_event_type, p_object_typ, p_object_id, p_daytime, p_end_date, p_username, ue_flag);

  IF (upper(ue_flag) = 'N') THEN

    SELECT default_value INTO lv_defer_autoinsert_flag
    FROM (
      SELECT default_value FROM (
        SELECT default_value_string default_value, to_date('01-01-1900', 'DD-MM-YYYY') daytime FROM ctrl_property_meta WHERE key = 'DEFERMENT_AUTOINSERT'
        UNION ALL
        SELECT value_string, daytime FROM ctrl_property WHERE key = 'DEFERMENT_AUTOINSERT' ORDER BY daytime DESC
      )ORDER BY daytime DESC
    ) WHERE rownum < 2;

    IF lv_defer_autoinsert_flag = 'N' THEN
      RETURN;
    END IF;

    SELECT default_value into lv_defer_overlap_flag from (
      SELECT default_value from (
        SELECT default_value_string default_value, to_date('01-01-1900', 'DD-MM-YYYY') daytime FROM ctrl_property_meta where key = 'DEFERMENT_OVERLAP'
        UNION ALL
        SELECT value_string, daytime from ctrl_property where key = 'DEFERMENT_OVERLAP' order by daytime desc
      )ORDER BY daytime desc
    ) WHERE rownum < 2;

    ln_group_event_no := p_group_event_no;

    lc_eqpm_conn := 'N';
    ln_Rowcnt := 0;

    IF p_object_typ = 'EQPM' THEN
        SELECT COUNT(*) INTO ln_connection_count
        FROM EQPM_CONN
        WHERE object_id = p_object_id
        AND eqpm_conn_class = 'WELL'
        AND daytime <= p_daytime AND Nvl(end_date,Ecdp_Timestamp.getCurrentSysdate) >= Nvl(p_end_date,Ecdp_Timestamp.getCurrentSysdate);

        IF (ln_connection_count!=0) THEN
          lc_eqpm_conn := 'Y';
        ELSE
          lc_eqpm_conn := 'N';
        END IF;
    END IF;


    IF p_object_typ = 'FCTY_CLASS_1' OR p_object_typ = 'WELL_HOOKUP' THEN
      FOR mycur IN c1_network LOOP
        lv2_alloc_netwk_id_c1 := mycur.object_id;
      END LOOP;
    ELSIF p_object_typ = 'EQPM' AND lc_eqpm_conn = 'N' THEN

      BEGIN
        SELECT ALLOC_NETW_NODE_ID INTO lv2_op_group_object_id
        FROM (SELECT ALLOC_NETW_NODE_ID
            FROM ov_eqpm
            WHERE object_id = p_object_id
            AND daytime <= p_daytime
            ORDER BY DAYTIME DESC)
        WHERE ROWNUM < 2;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              RETURN;
      END;

      FOR mycur IN c1_eqpm_network LOOP
        lv2_alloc_netwk_id_c1 := mycur.object_id;
      END LOOP;
    END IF;



    IF p_object_typ = 'EQPM' AND lc_eqpm_conn = 'Y' THEN
        OPEN c2_getAllEqpmConnWells(ln_group_event_no, p_object_id, p_daytime, p_end_date, p_forecast_id, p_scenario_id, p_event_type, p_username);

    ELSIF p_object_typ = 'EQPM' THEN
        OPEN c2_getAllEpqmWells(ln_group_event_no, lv2_op_group_object_id, p_object_id, p_daytime, p_end_date, p_forecast_id, p_scenario_id, p_event_type, p_username);

    ELSIF p_object_typ = 'FCTY_CLASS_1' OR p_object_typ = 'WELL_HOOKUP' THEN
        OPEN c2_getAllWells(ln_group_event_no, p_object_id, p_daytime, p_end_date, p_forecast_id, p_scenario_id, p_event_type, p_username, lv2_alloc_netwk_id_c1);

    ELSIF p_object_typ = 'TANK' THEN
        OPEN c2_getAllTankWells(ln_group_event_no, p_object_id, p_daytime, p_end_date, p_forecast_id, p_scenario_id, p_event_type, p_username);
    END IF;


    -- loop for each object type
    -- 1) p_object_typ = 'EQPM' AND lc_eqpm_conn = 'Y'  --
    IF p_object_typ = 'EQPM' AND lc_eqpm_conn = 'Y' THEN
      LOOP
        FETCH c2_getAllEqpmConnWells INTO
          lv2_object_id_c2,
          lv2_object_type_c2,
          ln_parent_event_no_c2,
          lv2_parent_object_id_c2,
          ld_parent_daytime_c2,
          ld_daytime_c2,
          ld_end_date_c2,
          lv2_forecast_id_c2,
          lv2_scenario_id_c2,
          lv2_event_type_c2,
          lv2_deferment_type_c2,
          lv2_created_by_c2;
        EXIT WHEN c2_getAllEqpmConnWells%NOTFOUND;

        IF p_event_type = 'DOWN' THEN
          EcDp_System_Key.assignNextNumber('FCST_WELL_EVENT', ln_tmp_event_no);
        END IF;

        IF ecdp_well.IsWellOpen(lv2_object_id_c2, p_daytime) = 'Y' THEN -- Only include wells that are open

          IF lv2_prev_object_id IS NULL THEN
            lv2_prev_object_id := lv2_object_id_c2;
          ELSE
            IF lv2_prev_object_id = lv2_object_id_c2 THEN
              goto SKIP_LOOP_A; -- skip the same well object id in the loop when the same well object has multiple versions within the date range.
            ELSE
              lv2_prev_object_id := lv2_object_id_c2;
            END IF;
          END IF;
          ln_Rowcnt := ln_Rowcnt + 1;

          ln_WellVersions_cnt := 0;
          OPEN c3_getWellVersions (p_object_id, lv2_object_id_c2, ld_daytime_c2, ld_end_date_c2);
          LOOP
            FETCH c3_getWellVersions INTO ld_daytime_c3, ld_end_date_c3;
            EXIT WHEN c3_getWellVersions%NOTFOUND;

            ln_WellVersions_cnt := ln_WellVersions_cnt + 1;

            -- Check the correct Well Version's start and end date that related to the Deferment's start and end date
            IF c3_getWellVersions%ROWCOUNT > 1 AND ln_WellVersions_cnt > 1 THEN
              goto SKIP_LOOP_B; -- Skip the remaining rows of the well version, because it needs to avoid the same row to insert and hit the UK constraint violation in the DB commit.
            ELSE
              IF ld_end_date_c3 IS NOT NULL THEN
                IF ld_end_date_c3 <=  p_end_date THEN
                  ld_end_date_c2 := ld_end_date_c3;
                END IF;
              END IF;
              IF ld_daytime_c3 >=  p_daytime THEN
                ld_daytime_c2 := ld_daytime_c3;
              END IF;
            END IF;
            <<SKIP_LOOP_B>> NULL;

          END LOOP;
          CLOSE c3_getWellVersions;

          typ_object_id.EXTEND;
          typ_object_type.EXTEND;
          typ_parent_event_no.EXTEND;
          typ_parent_object_id.EXTEND;
          typ_parent_daytime.EXTEND;
          typ_daytime.EXTEND;
          typ_end_date.EXTEND;
          typ_forecast_id.EXTEND;
          typ_scenario_id.EXTEND;
          typ_event_type.EXTEND;
          typ_deferment_type.EXTEND;
          typ_created_by.EXTEND;

          typ_object_id(ln_Rowcnt) :=  lv2_object_id_c2;
          typ_object_type(ln_Rowcnt) := lv2_object_type_c2;
          typ_parent_event_no(ln_Rowcnt) := ln_parent_event_no_c2;
          typ_parent_object_id(ln_Rowcnt) := lv2_parent_object_id_c2;
          typ_parent_daytime(ln_Rowcnt) := ld_parent_daytime_c2;
          typ_daytime(ln_Rowcnt) := ld_daytime_c2;
          typ_end_date(ln_Rowcnt) := ld_end_date_c2;
          typ_forecast_id(ln_Rowcnt) := lv2_forecast_id_c2;
          typ_scenario_id(ln_Rowcnt) := lv2_scenario_id_c2;
          typ_event_type(ln_Rowcnt) := lv2_event_type_c2;
          typ_deferment_type(ln_Rowcnt) := lv2_deferment_type_c2;
          typ_created_by(ln_Rowcnt) := lv2_created_by_c2;
          <<SKIP_LOOP_A>> NULL;

        END IF;

      END LOOP;
      CLOSE c2_getAllEqpmConnWells;

    -- 2) p_object_typ = 'EQPM' --
    ELSIF p_object_typ = 'EQPM' THEN
      LOOP
        FETCH c2_getAllEpqmWells INTO
              lv2_object_id_c2,
              lv2_object_type_c2,
              ln_parent_event_no_c2,
              lv2_parent_object_id_c2,
              ld_parent_daytime_c2,
              ld_daytime_c2,
              ld_end_date_c2,
              lv2_forecast_id_c2,
              lv2_scenario_id_c2,
              lv2_event_type_c2,
              lv2_deferment_type_c2,
              lv2_created_by_c2;
            EXIT WHEN c2_getAllEpqmWells%NOTFOUND;

        IF p_event_type = 'DOWN' THEN
          EcDp_System_Key.assignNextNumber('FCST_WELL_EVENT', ln_tmp_event_no);
        END IF;

        IF ecdp_well.IsWellOpen(lv2_object_id_c2, p_daytime) = 'Y' THEN -- Only include wells that are open

          IF lv2_prev_object_id IS NULL THEN
            lv2_prev_object_id := lv2_object_id_c2;
          ELSE
            IF lv2_prev_object_id = lv2_object_id_c2 THEN
              goto SKIP_LOOP_A; -- skip the same well object id in the loop when the same well object has multiple versions within the date range.
            ELSE
              lv2_prev_object_id := lv2_object_id_c2;
            END IF;
          END IF;
          ln_Rowcnt := ln_Rowcnt + 1;

          ln_WellVersions_cnt := 0;
          OPEN c3_getWellVersions (p_object_id, lv2_object_id_c2, ld_daytime_c2, ld_end_date_c2);
          LOOP
            FETCH c3_getWellVersions INTO ld_daytime_c3, ld_end_date_c3;
            EXIT WHEN c3_getWellVersions%NOTFOUND;

            ln_WellVersions_cnt := ln_WellVersions_cnt + 1;

            -- Check the correct Well Version's start and end date that related to the Deferment's start and end date
            IF c3_getWellVersions%ROWCOUNT > 1 AND ln_WellVersions_cnt > 1 THEN
              goto SKIP_LOOP_B; -- Skip the remaining rows of the well version, because it needs to avoid the same row to insert and hit the UK constraint violation in the DB commit.
            ELSE
              IF ld_end_date_c3 IS NOT NULL THEN
                IF ld_end_date_c3 <=  p_end_date THEN
                  ld_end_date_c2 := ld_end_date_c3;
                END IF;
              END IF;
              IF ld_daytime_c3 >=  p_daytime THEN
                ld_daytime_c2 := ld_daytime_c3;
              END IF;
            END IF;
            <<SKIP_LOOP_B>> NULL;

          END LOOP;
          CLOSE c3_getWellVersions;

          typ_object_id.EXTEND;
          typ_object_type.EXTEND;
          typ_parent_event_no.EXTEND;
          typ_parent_object_id.EXTEND;
          typ_parent_daytime.EXTEND;
          typ_daytime.EXTEND;
          typ_end_date.EXTEND;
          typ_forecast_id.EXTEND;
          typ_scenario_id.EXTEND;
          typ_event_type.EXTEND;
          typ_deferment_type.EXTEND;
          typ_created_by.EXTEND;

          typ_object_id(ln_Rowcnt) :=  lv2_object_id_c2;
          typ_object_type(ln_Rowcnt) := lv2_object_type_c2;
          typ_parent_event_no(ln_Rowcnt) := ln_parent_event_no_c2;
          typ_parent_object_id(ln_Rowcnt) := lv2_parent_object_id_c2;
          typ_parent_daytime(ln_Rowcnt) := ld_parent_daytime_c2;
          typ_daytime(ln_Rowcnt) := ld_daytime_c2;
          typ_end_date(ln_Rowcnt) := ld_end_date_c2;
          typ_forecast_id(ln_Rowcnt) := lv2_forecast_id_c2;
          typ_scenario_id(ln_Rowcnt) := lv2_scenario_id_c2;
          typ_event_type(ln_Rowcnt) := lv2_event_type_c2;
          typ_deferment_type(ln_Rowcnt) := lv2_deferment_type_c2;
          typ_created_by(ln_Rowcnt) := lv2_created_by_c2;
          <<SKIP_LOOP_A>> NULL;

        END IF;

      END LOOP;
      CLOSE c2_getAllEpqmWells;


    -- 3) p_object_typ = 'FCTY_CLASS_1' OR p_object_typ = 'WELL_HOOKUP' --
    ELSIF p_object_typ = 'FCTY_CLASS_1' OR p_object_typ = 'WELL_HOOKUP' THEN
      LOOP
        FETCH c2_getAllWells INTO
          lv2_object_id_c2,
          lv2_object_type_c2,
          ln_parent_event_no_c2,
          lv2_parent_object_id_c2,
          ld_parent_daytime_c2,
          ld_daytime_c2,
          ld_end_date_c2,
          lv2_forecast_id_c2,
          lv2_scenario_id_c2,
          lv2_event_type_c2,
          lv2_deferment_type_c2,
          lv2_created_by_c2;
        EXIT WHEN c2_getAllWells%NOTFOUND;

        IF p_event_type = 'DOWN' THEN
          EcDp_System_Key.assignNextNumber('FCST_WELL_EVENT', ln_tmp_event_no);
        END IF;

        IF ecdp_well.IsWellOpen(lv2_object_id_c2, p_daytime) = 'Y' THEN -- Only include wells that are open

          IF lv2_prev_object_id IS NULL THEN
            lv2_prev_object_id := lv2_object_id_c2;
          ELSE
            IF lv2_prev_object_id = lv2_object_id_c2 THEN
              goto SKIP_LOOP_A; -- skip the same well object id in the loop when the same well object has multiple versions within the date range.
            ELSE
              lv2_prev_object_id := lv2_object_id_c2;
            END IF;
          END IF;
          ln_Rowcnt := ln_Rowcnt + 1;

          ln_WellVersions_cnt := 0;
          OPEN c3_getWellVersions (p_object_id, lv2_object_id_c2, ld_daytime_c2, ld_end_date_c2);
          LOOP
            FETCH c3_getWellVersions INTO ld_daytime_c3, ld_end_date_c3;
            EXIT WHEN c3_getWellVersions%NOTFOUND;

            ln_WellVersions_cnt := ln_WellVersions_cnt + 1;

            -- Check the correct Well Version's start and end date that related to the Deferment's start and end date
            IF c3_getWellVersions%ROWCOUNT > 1 AND ln_WellVersions_cnt > 1 THEN
              goto SKIP_LOOP_B; -- Skip the remaining rows of the well version, because it needs to avoid the same row to insert and hit the UK constraint violation in the DB commit.
            ELSE
              IF ld_end_date_c3 IS NOT NULL THEN
                IF ld_end_date_c3 <=  p_end_date THEN
                  ld_end_date_c2 := ld_end_date_c3;
                END IF;
              END IF;
              IF ld_daytime_c3 >=  p_daytime THEN
                ld_daytime_c2 := ld_daytime_c3;
              END IF;
            END IF;
            <<SKIP_LOOP_B>> NULL;

          END LOOP;
          CLOSE c3_getWellVersions;

          typ_object_id.EXTEND;
          typ_object_type.EXTEND;
          typ_parent_event_no.EXTEND;
          typ_parent_object_id.EXTEND;
          typ_parent_daytime.EXTEND;
          typ_daytime.EXTEND;
          typ_end_date.EXTEND;
          typ_forecast_id.EXTEND;
          typ_scenario_id.EXTEND;
          typ_event_type.EXTEND;
          typ_deferment_type.EXTEND;
          typ_created_by.EXTEND;

          typ_object_id(ln_Rowcnt) :=  lv2_object_id_c2;
          typ_object_type(ln_Rowcnt) := lv2_object_type_c2;
          typ_parent_event_no(ln_Rowcnt) := ln_parent_event_no_c2;
          typ_parent_object_id(ln_Rowcnt) := lv2_parent_object_id_c2;
          typ_parent_daytime(ln_Rowcnt) := ld_parent_daytime_c2;
          typ_daytime(ln_Rowcnt) := ld_daytime_c2;
          typ_end_date(ln_Rowcnt) := ld_end_date_c2;
          typ_forecast_id(ln_Rowcnt) := lv2_forecast_id_c2;
          typ_scenario_id(ln_Rowcnt) := lv2_scenario_id_c2;
          typ_event_type(ln_Rowcnt) := lv2_event_type_c2;
          typ_deferment_type(ln_Rowcnt) := lv2_deferment_type_c2;
          typ_created_by(ln_Rowcnt) := lv2_created_by_c2;
          <<SKIP_LOOP_A>> NULL;
        END IF;
      END LOOP;
      CLOSE c2_getAllWells;


    -- 4) p_object_typ = 'TANK' --
    ELSIF p_object_typ = 'TANK' THEN
      LOOP
        FETCH c2_getAllTankWells INTO
          lv2_object_id_c2,
          lv2_object_type_c2,
          ln_parent_event_no_c2,
          lv2_parent_object_id_c2,
          ld_parent_daytime_c2,
          ld_daytime_c2,
          ld_end_date_c2,
          lv2_forecast_id_c2,
          lv2_scenario_id_c2,
          lv2_event_type_c2,
          lv2_deferment_type_c2,
          lv2_created_by_c2;
        EXIT WHEN c2_getAllTankWells%NOTFOUND;

        IF p_event_type = 'DOWN' THEN
          EcDp_System_Key.assignNextNumber('FCST_WELL_EVENT', ln_tmp_event_no);
        END IF;

        IF ecdp_well.IsWellOpen(lv2_object_id_c2, p_daytime) = 'Y' THEN -- Only include wells that are open

          IF lv2_prev_object_id IS NULL THEN
            lv2_prev_object_id := lv2_object_id_c2;
          ELSE
            IF lv2_prev_object_id = lv2_object_id_c2 THEN
              goto SKIP_LOOP_A; -- skip the same well object id in the loop when the same well object has multiple versions within the date range.
            ELSE
              lv2_prev_object_id := lv2_object_id_c2;
            END IF;
          END IF;
          ln_Rowcnt := ln_Rowcnt + 1;

          ln_WellVersions_cnt := 0;
          OPEN c3_getWellVersions (p_object_id, lv2_object_id_c2, ld_daytime_c2, ld_end_date_c2);
          LOOP
            FETCH c3_getWellVersions INTO ld_daytime_c3, ld_end_date_c3;
            EXIT WHEN c3_getWellVersions%NOTFOUND;

            ln_WellVersions_cnt := ln_WellVersions_cnt + 1;

            -- Check the correct Well Version's start and end date that related to the Deferment's start and end date
            IF c3_getWellVersions%ROWCOUNT > 1 AND ln_WellVersions_cnt > 1 THEN
              goto SKIP_LOOP_B; -- Skip the remaining rows of the well version, because it needs to avoid the same row to insert and hit the UK constraint violation in the DB commit.
            ELSE
              IF ld_end_date_c3 IS NOT NULL THEN
                IF ld_end_date_c3 <=  p_end_date THEN
                  ld_end_date_c2 := ld_end_date_c3;
                END IF;
              END IF;
              IF ld_daytime_c3 >=  p_daytime THEN
                ld_daytime_c2 := ld_daytime_c3;
              END IF;
            END IF;
            <<SKIP_LOOP_B>> NULL;

          END LOOP;
          CLOSE c3_getWellVersions;

          typ_object_id.EXTEND;
          typ_object_type.EXTEND;
          typ_parent_event_no.EXTEND;
          typ_parent_object_id.EXTEND;
          typ_parent_daytime.EXTEND;
          typ_daytime.EXTEND;
          typ_end_date.EXTEND;
          typ_forecast_id.EXTEND;
          typ_scenario_id.EXTEND;
          typ_event_type.EXTEND;
          typ_deferment_type.EXTEND;
          typ_created_by.EXTEND;

          typ_object_id(ln_Rowcnt) :=  lv2_object_id_c2;
          typ_object_type(ln_Rowcnt) := lv2_object_type_c2;
          typ_parent_event_no(ln_Rowcnt) := ln_parent_event_no_c2;
          typ_parent_object_id(ln_Rowcnt) := lv2_parent_object_id_c2;
          typ_parent_daytime(ln_Rowcnt) := ld_parent_daytime_c2;
          typ_daytime(ln_Rowcnt) := ld_daytime_c2;
          typ_end_date(ln_Rowcnt) := ld_end_date_c2;
          typ_forecast_id(ln_Rowcnt) := lv2_forecast_id_c2;
          typ_scenario_id(ln_Rowcnt) := lv2_scenario_id_c2;
          typ_event_type(ln_Rowcnt) := lv2_event_type_c2;
          typ_deferment_type(ln_Rowcnt) := lv2_deferment_type_c2;
          typ_created_by(ln_Rowcnt) := lv2_created_by_c2;
          <<SKIP_LOOP_A>> NULL;
        END IF;
      END LOOP;
      CLOSE c2_getAllTankWells;

    END IF;

    FORALL k IN 1..typ_object_id.COUNT
    INSERT INTO FCST_WELL_EVENT
    (event_id, object_type, parent_event_no, parent_object_id, parent_daytime, daytime, end_date,
     forecast_id, object_id, event_type, deferment_type, created_by)
    VALUES
    (typ_object_id(k), typ_object_type(k), typ_parent_event_no(k), typ_parent_object_id(k), typ_parent_daytime(k), typ_daytime(k), typ_end_date(k),
     typ_forecast_id(k), typ_scenario_id(k), typ_event_type(k), typ_deferment_type(k), typ_created_by(k) );

   END IF;

END insertWells;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : setLossRate                                                   --
-- Description    : Updates Loss Rates
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : FCST_WELL_EVENT
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
PROCEDURE setLossRate (p_event_no        NUMBER,
                       p_user VARCHAR2)
--</EC-DOC>
IS

  CURSOR  c_group_loss  IS
    SELECT
      sum(fwe.oil_loss_rate) tot_oil_loss_rate,
      sum(fwe.gas_loss_rate) tot_gas_loss_rate,
      sum(fwe.cond_loss_rate) tot_cond_loss_rate,
      sum(fwe.water_loss_rate) tot_wat_loss_rate,
      sum(fwe.water_inj_loss_rate) tot_wat_inj_loss_rate,
      sum(fwe.steam_inj_loss_rate) tot_steam_inj_loss_rate,
      sum(fwe.gas_inj_loss_rate) tot_gas_inj_loss_rate,
      sum(fwe.diluent_loss_rate) tot_diluent_loss_rate,
      sum(fwe.gas_lift_loss_rate) tot_gas_lift_loss_rate,
      sum(fwe.co2_inj_loss_rate) tot_co2_inj_loss_rate
    FROM FCST_WELL_EVENT fwe
    WHERE fwe.parent_event_no = p_event_no
    AND fwe.deferment_type = 'GROUP_CHILD';

  ln_oil_loss_rate NUMBER := null;
  ln_gas_loss_rate NUMBER := null;
  ln_gas_inj_loss_rate NUMBER := null;
  ln_cond_loss_rate NUMBER := null;
  ln_wat_loss_rate NUMBER := null;
  ln_wat_inj_loss_rate NUMBER := null;
  ln_steam_inj_loss_rate NUMBER := null;
  ln_diluent_loss_rate NUMBER := null;
  ln_gas_lift_loss_rate NUMBER := null;
  ln_co2_inj_loss_rate NUMBER := null;

  ln_parent_oil_loss_rate NUMBER ;
  ln_parent_gas_loss_rate NUMBER ;
  ln_parent_gas_inj_loss_rate NUMBER ;
  ln_parent_cond_loss_rate NUMBER ;
  ln_parent_wat_loss_rate NUMBER ;
  ln_parent_wat_inj_loss_rate NUMBER ;
  ln_parent_steam_inj_loss_rate NUMBER ;
  ln_parent_diluent_loss_rate NUMBER ;
  ln_parent_gas_lift_loss_rate NUMBER ;
  ln_parent_co2_inj_loss_rate NUMBER ;

  ln_tot_oil_loss_rate NUMBER := null;
  ln_tot_gas_loss_rate NUMBER := null;
  ln_tot_wat_loss_rate NUMBER := null;
  ln_tot_gas_inj_loss_rate NUMBER := null;
  ln_tot_cond_loss_rate NUMBER := null;
  ln_tot_wat_inj_loss_rate NUMBER := null;
  ln_tot_steam_inj_loss_rate NUMBER := null;
  ln_tot_diluent_loss_rate NUMBER := null;
  ln_tot_gas_lift_loss_rate NUMBER := null;
  ln_tot_co2_inj_loss_rate NUMBER := null;

  ln_event_loss_oil NUMBER := null;
  ln_event_loss_gas NUMBER := null;
  ln_event_loss_cond NUMBER := null;
  ln_event_loss_water NUMBER := null;
  ln_event_loss_water_inj NUMBER := null;
  ln_event_loss_steam_inj NUMBER := null;
  ln_event_loss_gas_inj NUMBER := null;
  ln_event_loss_diluent NUMBER := null;
  ln_event_loss_gas_lift NUMBER := null;
  ln_event_loss_co2_inj NUMBER := null;
  ln_diff     NUMBER := null;
  ln_chk_child NUMBER := null;
  lv2_deferment_type VARCHAR2(32);
  lv2_object_id VARCHAR(32);
  ld_daytime  DATE;
  ld_end_date DATE;

BEGIN

   BEGIN
    SELECT event_id,daytime,oil_loss_rate,gas_loss_rate,gas_inj_loss_rate,cond_loss_rate,water_loss_rate,water_inj_loss_rate,steam_inj_loss_rate,
    diluent_loss_rate,gas_lift_loss_rate,co2_inj_loss_rate,deferment_type,end_date
    INTO lv2_object_id,ld_daytime,ln_oil_loss_rate,ln_gas_loss_rate,ln_gas_inj_loss_rate,ln_cond_loss_rate,ln_wat_loss_rate,ln_wat_inj_loss_rate,ln_steam_inj_loss_rate,
    ln_diluent_loss_rate,ln_gas_lift_loss_rate,ln_co2_inj_loss_rate,lv2_deferment_type,ld_end_date
    FROM FCST_WELL_EVENT
    WHERE event_no  = p_event_no;
   EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20226, 'An error occurred while fetching data for event no- '||p_event_no);
   END;

    ln_event_loss_oil := EcBp_Forecast_Event.getParentEventLossRate(p_event_no, 'OIL',lv2_deferment_type);
    ln_event_loss_gas := EcBp_Forecast_Event.getParentEventLossRate(p_event_no, 'GAS',lv2_deferment_type);
    ln_event_loss_cond := EcBp_Forecast_Event.getParentEventLossRate(p_event_no, 'COND',lv2_deferment_type);
    ln_event_loss_water := EcBp_Forecast_Event.getParentEventLossRate(p_event_no, 'WATER',lv2_deferment_type);
    ln_event_loss_water_inj := EcBp_Forecast_Event.getParentEventLossRate(p_event_no, 'WAT_INJ',lv2_deferment_type);
    ln_event_loss_steam_inj := EcBp_Forecast_Event.getParentEventLossRate(p_event_no, 'STEAM_INJ',lv2_deferment_type);
    ln_event_loss_gas_inj := EcBp_Forecast_Event.getParentEventLossRate(p_event_no, 'GAS_INJ',lv2_deferment_type);
    ln_event_loss_diluent := EcBp_Forecast_Event.getParentEventLossRate(p_event_no, 'DILUENT',lv2_deferment_type);
    ln_event_loss_gas_lift := EcBp_Forecast_Event.getParentEventLossRate(p_event_no, 'GAS_LIFT',lv2_deferment_type);
    ln_event_loss_co2_inj := EcBp_Forecast_Event.getParentEventLossRate(p_event_no, 'CO2_INJ',lv2_deferment_type);

    ln_diff := abs((ld_end_date - ld_daytime)*24);

  IF lv2_deferment_type ='SINGLE' THEN

    -- This is to check that when the well is NOT INJECTOR and ISPRODCUCER is closed, then Oil, Gas, and Cond's loss rate value will be set to null
    IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN',ld_daytime) = 'N' then
      ln_oil_loss_rate       := NULL;
      ln_gas_loss_rate       := NULL;
      ln_cond_loss_rate      := NULL;
      ln_wat_loss_rate       := NULL;
      ln_diluent_loss_rate   := NULL;
      ln_gas_lift_loss_rate  := NULL;
    END IF;

    -- This is to check that when the well is Gas Injector is closed, then the Gas Injector's loss rate value will be set to null
    IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,'GI','OPEN',ld_daytime) = 'N' then
      ln_gas_inj_loss_rate := NULL;
    END IF;

    -- This is to check that when the well is Water Injector is closed, then the Water Injector's loss rate value will be set to null
    IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,'WI','OPEN',ld_daytime) = 'N' then
      ln_wat_inj_loss_rate := NULL;
    END IF;

    -- This is to check that when the well is Steam Injector is closed, then the Steam Injector's loss rate value will be set to null
    IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,'SI','OPEN',ld_daytime) = 'N' then
      ln_steam_inj_loss_rate := NULL;
    END IF;

     -- This is to check that when the well is Co2 Injector is closed, then the Co2 Injector's loss rate value will be set to null
    IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,'CI','OPEN',ld_daytime) = 'N' then
      ln_co2_inj_loss_rate := NULL;
    END IF;

    UPDATE FCST_WELL_EVENT
    SET oil_loss_rate = nvl(ln_oil_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN',ld_daytime), 'Y', ecbp_well_potential.findOilProductionPotential(lv2_object_id,ld_daytime),null)),
        gas_loss_rate = nvl(ln_gas_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN',ld_daytime), 'Y', ecbp_well_potential.findGasProductionPotential(lv2_object_id,ld_daytime), null)),
        gas_inj_loss_rate =  nvl(ln_gas_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(lv2_object_id,'GI','OPEN',ld_daytime), 'Y', ecbp_well_potential.findGasInjectionPotential(lv2_object_id,ld_daytime), null)),
        cond_loss_rate = nvl(ln_cond_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN',ld_daytime), 'Y', ecbp_well_potential.findConProductionPotential(lv2_object_id,ld_daytime), null)),
        water_loss_rate = nvl(ln_wat_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN',ld_daytime), 'Y', ecbp_well_potential.findWatProductionPotential(lv2_object_id,ld_daytime), null)),
        water_inj_loss_rate = nvl(ln_wat_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(lv2_object_id,'WI','OPEN',ld_daytime), 'Y', ecbp_well_potential.findWatInjectionPotential(lv2_object_id,ld_daytime), null)),
        steam_inj_loss_rate = nvl(ln_steam_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(lv2_object_id,'SI','OPEN',ld_daytime), 'Y', ecbp_well_potential.findSteamInjectionPotential(lv2_object_id,ld_daytime), null)),
        diluent_loss_rate = nvl(ln_diluent_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN',ld_daytime), 'Y', ecbp_well_potential.findDiluentPotential(lv2_object_id,ld_daytime),null)),
        gas_lift_loss_rate = nvl(ln_gas_lift_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN',ld_daytime), 'Y', ecbp_well_potential.findGasLiftPotential(lv2_object_id,ld_daytime), null)),
        co2_inj_loss_rate = nvl(ln_co2_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(lv2_object_id,'CI','OPEN',ld_daytime), 'Y', ecbp_well_potential.findCo2InjectionPotential(lv2_object_id,ld_daytime), null)),
        last_updated_by = p_user
    WHERE event_no  = p_event_no;

  ELSIF (lv2_deferment_type ='GROUP') THEN
      SELECT count(1) into ln_chk_child FROM FCST_WELL_EVENT WHERE parent_event_no  = p_event_no and (daytime <> ld_daytime or end_date <> ld_end_date);
      ln_parent_oil_loss_rate         := ln_oil_loss_rate;
      ln_parent_gas_loss_rate         := ln_gas_loss_rate;
      ln_parent_gas_inj_loss_rate     := ln_gas_inj_loss_rate;
      ln_parent_cond_loss_rate        := ln_cond_loss_rate;
      ln_parent_wat_loss_rate         := ln_wat_loss_rate;
      ln_parent_wat_inj_loss_rate     := ln_wat_inj_loss_rate;
      ln_parent_steam_inj_loss_rate   := ln_steam_inj_loss_rate;
      ln_parent_diluent_loss_rate     := ln_diluent_loss_rate;
      ln_parent_gas_lift_loss_rate    := ln_gas_lift_loss_rate;
      ln_parent_co2_inj_loss_rate     := ln_co2_inj_loss_rate;

    -- Check total loss rates of all child with the same parent
    FOR c_group_tot_loss IN c_group_loss LOOP
      IF (ln_chk_child > 0) THEN
        ln_tot_oil_loss_rate        := (ln_event_loss_oil * 24/ln_diff);
        ln_tot_gas_loss_rate        := (ln_event_loss_gas * 24/ln_diff);
        ln_tot_gas_inj_loss_rate    := (ln_event_loss_gas_inj * 24/ln_diff);
        ln_tot_cond_loss_rate       := (ln_event_loss_cond * 24/ln_diff);
        ln_tot_wat_loss_rate        := (ln_event_loss_water * 24/ln_diff);
        ln_tot_wat_inj_loss_rate    := (ln_event_loss_water_inj * 24/ln_diff);
        ln_tot_steam_inj_loss_rate  := (ln_event_loss_steam_inj * 24/ln_diff);
        ln_tot_diluent_loss_rate    := (ln_event_loss_diluent * 24/ln_diff);
        ln_tot_gas_lift_loss_rate   := (ln_event_loss_gas_lift * 24/ln_diff);
        ln_tot_co2_inj_loss_rate    := (ln_event_loss_co2_inj * 24/ln_diff);
      ELSE
        ln_tot_oil_loss_rate        :=  c_group_tot_loss.tot_oil_loss_rate;
        ln_tot_gas_loss_rate        :=  c_group_tot_loss.tot_gas_loss_rate;
        ln_tot_gas_inj_loss_rate    :=  c_group_tot_loss.tot_gas_inj_loss_rate;
        ln_tot_cond_loss_rate       :=  c_group_tot_loss.tot_cond_loss_rate;
        ln_tot_wat_loss_rate        :=  c_group_tot_loss.tot_wat_loss_rate;
        ln_tot_wat_inj_loss_rate    :=  c_group_tot_loss.tot_wat_inj_loss_rate;
        ln_tot_steam_inj_loss_rate  :=  c_group_tot_loss.tot_steam_inj_loss_rate;
        ln_tot_diluent_loss_rate    :=  c_group_tot_loss.tot_diluent_loss_rate;
        ln_tot_gas_lift_loss_rate   :=  c_group_tot_loss.tot_gas_lift_loss_rate;
        ln_tot_co2_inj_loss_rate   :=  c_group_tot_loss.tot_co2_inj_loss_rate;
      END IF;
    END LOOP;

    -- Update parent with the value if it's value is not null.
    UPDATE FCST_WELL_EVENT
    SET oil_loss_rate =  nvl(ln_parent_oil_loss_rate, ln_tot_oil_loss_rate),
        gas_loss_rate = nvl(ln_parent_gas_loss_rate, ln_tot_gas_loss_rate),
        gas_inj_loss_rate = nvl(ln_parent_gas_inj_loss_rate, ln_tot_gas_inj_loss_rate),
        cond_loss_rate = nvl(ln_parent_cond_loss_rate, ln_tot_cond_loss_rate),
        water_loss_rate = nvl(ln_parent_wat_loss_rate, ln_tot_wat_loss_rate),
        water_inj_loss_rate = nvl(ln_parent_wat_inj_loss_rate, ln_tot_wat_inj_loss_rate),
        steam_inj_loss_rate = nvl(ln_parent_steam_inj_loss_rate, ln_tot_steam_inj_loss_rate),
        diluent_loss_rate =  nvl(ln_parent_diluent_loss_rate, ln_tot_diluent_loss_rate),
        gas_lift_loss_rate = nvl(ln_parent_gas_lift_loss_rate, ln_tot_gas_lift_loss_rate),
        co2_inj_loss_rate = nvl(ln_parent_co2_inj_loss_rate, ln_tot_co2_inj_loss_rate),
        last_updated_by = p_user
    WHERE event_no = p_event_no;

  END IF;

END setLossRate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- Procedure      : updateReasonCodeForChildEvent
-- Description    : Update Reason Code of child to be same as parent.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCST_WELL_EVENT
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
---------------------------------------------------------------------------------------------------------
PROCEDURE updateReasonCodeForChildEvent(p_event_no NUMBER,
                                        p_user VARCHAR2,
                                        p_last_updated_date DATE)
--</EC-DOC>
IS
  CURSOR c_reason_code IS
  SELECT fwe.reason_code_1,
         fwe.reason_code_type_1
  FROM FCST_WELL_EVENT fwe
  WHERE fwe.event_no = p_event_no;


 BEGIN

   FOR cur_reason_code IN c_reason_code LOOP
       UPDATE FCST_WELL_EVENT
       SET reason_code_1 = cur_reason_code.reason_code_1
           ,reason_code_type_1 = cur_reason_code.reason_code_type_1
           ,last_updated_by =  p_user
           ,last_updated_date = p_last_updated_date
       WHERE deferment_type = 'GROUP_CHILD'
       AND parent_event_no = p_event_no
       AND (
             NVL(reason_code_1,'null') <> NVL(cur_reason_code.reason_code_1,'null')
          );

   END LOOP;

END updateReasonCodeForChildEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- Procedure      : updateScheduledForChildEvent
-- Description    : Update scheduled field of child to be same as parent.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCST_WELL_EVENT
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
---------------------------------------------------------------------------------------------------------
PROCEDURE updateScheduledForChildEvent(p_event_no      NUMBER,
                                       p_user              VARCHAR2,
                                       p_last_updated_date DATE)
--</EC-DOC>
IS

  lv2_scheduled FCST_WELL_EVENT.scheduled%type;

BEGIN

  BEGIN
    SELECT scheduled
    INTO lv2_scheduled
    FROM FCST_WELL_EVENT
    WHERE event_no  = p_event_no;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  UPDATE FCST_WELL_EVENT
  SET scheduled         = lv2_scheduled,
      last_updated_by   = p_user,
      last_updated_date = p_last_updated_date
  WHERE deferment_type = 'GROUP_CHILD'
    AND parent_event_no = p_event_no;

END updateScheduledForChildEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- Procedure      : updateEventTypeForChildEvent
-- Description    : Update Event Type of child to be same as parent.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCST_WELL_EVENT
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
---------------------------------------------------------------------------------------------------------
PROCEDURE updateEventTypeForChildEvent(p_event_no          NUMBER,
                                       p_user              VARCHAR2,
                                       p_last_updated_date DATE)
--</EC-DOC>
 IS

 lv2_event_type FCST_WELL_EVENT.event_type%type;

BEGIN

  BEGIN
        SELECT event_type
        INTO lv2_event_type
        FROM FCST_WELL_EVENT
        WHERE event_no  = p_event_no;
  EXCEPTION
        WHEN OTHERS THEN
          NULL;
  END;

  UPDATE FCST_WELL_EVENT
       SET event_type        = lv2_event_type,
           last_updated_by   = p_user,
           last_updated_date = p_last_updated_date
     WHERE deferment_type = 'GROUP_CHILD'
       AND parent_event_no = p_event_no;

END updateEventTypeForChildEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- Procedure      : updateEndDateForWellDeferment
-- Description    : Update end date of chilf if it is null or empty
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCST_WELL_EVENT
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
---------------------------------------------------------------------------------------------------------
PROCEDURE updateEndDateForChildEvent(p_event_no NUMBER,
                                     p_o_end_date DATE,
                                     p_user VARCHAR2 ,
                                     p_last_updated_date DATE)
--</EC-DOC>
IS

  ld_parent_end_date DATE;

BEGIN

   BEGIN
        SELECT end_date
        INTO ld_parent_end_date
        FROM FCST_WELL_EVENT
        WHERE event_no  = p_event_no;
   EXCEPTION
        WHEN OTHERS THEN
          NULL;
   END;

    UPDATE FCST_WELL_EVENT
    SET end_date = CASE WHEN end_date < ld_parent_end_date THEN end_date ELSE ld_parent_end_date END, last_updated_by =  p_user, last_updated_date = p_last_updated_date
    WHERE parent_event_no = p_event_no
    AND (end_date is null or end_date = '' or end_date <= p_o_end_date );

END updateEndDateForChildEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- Procedure      : updateStartDateForChildEvent
-- Description    : Update start date of child
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCST_WELL_EVENT
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
---------------------------------------------------------------------------------------------------------
PROCEDURE updateStartDateForChildEvent(p_event_no NUMBER,
                                       p_o_start_date DATE,
                                       p_user VARCHAR2 ,
                                       p_last_updated_date DATE )
--</EC-DOC>
IS

 ld_parent_start_date DATE;

BEGIN

   BEGIN
        SELECT daytime
        INTO ld_parent_start_date
        FROM FCST_WELL_EVENT
        WHERE event_no  = p_event_no;
   EXCEPTION
        WHEN OTHERS THEN
          NULL;
   END;

     UPDATE FCST_WELL_EVENT
     SET daytime = CASE WHEN daytime > ld_parent_start_date THEN daytime ELSE ld_parent_start_date END, last_updated_by =  p_user, last_updated_date = p_last_updated_date
     WHERE parent_event_no = p_event_no
        AND (daytime <= p_o_start_date);

END updateStartDateForChildEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- Procedure      : insertTempWellDefermntAlloc
-- Description    : Insert/updated record when record in FCST_WELL_EVENT inserted or updated.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : TEMP_FCST_WELL_EVENT_ALLOC
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
---------------------------------------------------------------------------------------------------------

PROCEDURE insertTempFcstWellEventAlloc(p_event_no NUMBER, p_parent_event_no NUMBER DEFAULT NULL, p_n_daytime DATE, p_o_daytime DATE DEFAULT NULL, p_n_end_date DATE DEFAULT NULL, p_o_end_date DATE DEFAULT NULL, p_iud_action VARCHAR2, p_user_name VARCHAR2, p_last_updated_date date)
--</EC-DOC>
IS
BEGIN

  INSERT INTO TEMP_FCST_WELL_EVENT_ALLOC (event_no, parent_event_no, new_daytime, old_daytime, new_end_date, old_end_date, iud_action, last_updated_by, last_updated_date)
  VALUES (p_event_no, p_parent_event_no, p_n_daytime, p_o_daytime, p_n_end_date, p_o_end_date, p_iud_action, p_user_name, p_last_updated_date);

END insertTempFcstWellEventAlloc;

--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- Procedure      : updateEventEqpmForChild
-- Description    : Update Event,Eqpm link Code of child to be same as parent.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : FCST_WELL_EVENT
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
---------------------------------------------------------------------------------------------------------
PROCEDURE updateEventEqpmForChild(p_event_no NUMBER,
                                  p_user VARCHAR2,
                                  p_last_updated_date DATE)
--</EC-DOC>
IS
  CURSOR c_link_code IS
  SELECT fwe.master_event_id,fwe.equipment_id
  FROM FCST_WELL_EVENT fwe
  WHERE fwe.event_no = p_event_no;


 BEGIN

   FOR cur_link_code IN c_link_code LOOP
       UPDATE FCST_WELL_EVENT
       SET master_event_id=cur_link_code.master_event_id
           ,equipment_id=cur_link_code.equipment_id
           ,last_updated_by =  p_user
           ,last_updated_date = p_last_updated_date
       WHERE deferment_type = 'GROUP_CHILD'
       AND parent_event_no = p_event_no;

   END LOOP;

END updateEventEqpmForChild;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : reCalcDeferments
-- Description    : Procedure used to recalculate the forecast deferment values in allocation table
--
-- Using tables   : FCST_WELL_EVENT (READ), TEMP_FCST_WELL_EVENT_ALLOC (WRITE)
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
--</EC-DOC>
PROCEDURE reCalcDeferments(p_scenario_id VARCHAR2 DEFAULT NULL) IS
  -- Query the TEMP_FCST_WELL_EVENT_ALLOC table for all admendments on FCST_WELL_EVENT table for all IUD actions
  CURSOR c_temp_alloc_recs IS
  SELECT a.event_no,
         LEAST(a.new_daytime, NVL(a.old_daytime, a.new_daytime)) daytime,
         GREATEST(a.new_end_date, NVL(a.old_end_date, a.new_end_date)) end_date
  FROM TEMP_FCST_WELL_EVENT_ALLOC a
  ORDER BY a.event_no ASC;

  CURSOR c_eventNo_toBeRemoved(cp_scenario_id VARCHAR2) IS
  SELECT b.event_no
  FROM temp_fcst_well_event_alloc a, fcst_well_event b
  WHERE a.event_no = b.event_no
  AND b.object_id = cp_scenario_id;

  ln_row NUMBER;
BEGIN
  ln_row := 0;
  FOR mycur IN c_temp_alloc_recs LOOP
    IF mycur.event_no IS NOT NULL THEN
      -- Leave all the validations to be done inside the calcDeferments procedure as a single control area.
      EcDp_Forecast_Event.calcDeferments(mycur.event_no, mycur.daytime, mycur.end_date, p_scenario_id);
      ln_row := ln_row + 1;
    END IF;
  END LOOP;
  IF ln_row > 0 THEN
    -- Clear the temp table once the process is done with records for the same scenario ID.
    FOR rec IN c_eventNo_toBeRemoved(p_scenario_id) LOOP
      DELETE FROM TEMP_FCST_WELL_EVENT_ALLOC WHERE EVENT_NO = rec.event_no;
    END LOOP;
  END IF;
EXCEPTION WHEN OTHERS THEN
  NULL;
END reCalcDeferments;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcDeferments
-- Description    : Procedure used to calculate the forecast deferment values in allocation table
--
-- Using tables   : FCST_WELL_EVENT (READ), TEMP_FCST_WELL_EVENT_ALLOC (WRITE)
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
                         --p_asset_id VARCHAR2 DEFAULT NULL,
                         p_from_date DATE DEFAULT NULL,
                         p_to_date DATE DEFAULT NULL,
                         p_scenario_id VARCHAR2 DEFAULT NULL) IS

  -- get list of wells directly from fcst_well_event event_no
  CURSOR c_fcst_well_event IS
  SELECT event_id, day, end_day
    FROM FCST_WELL_EVENT
   WHERE event_no = p_event_no;

  -- This cursor filters records for selected scenario

  CURSOR c_fcst_well_event_scenario IS
  SELECT fwe.event_id, fwe.day, fwe.end_day
    FROM FCST_WELL_EVENT fwe, WELL_VERSION wv
   WHERE fwe.event_id= wv.object_id AND
         fwe.event_no = p_event_no AND
         fwe.object_id = p_scenario_id;

  lv2_asset_type        VARCHAR2(32);
  ld_start_daytime      DATE;
  ue_flag               CHAR;

BEGIN

  ue_forecast_event.calcDeferments(p_event_no, p_from_date, p_to_date, ue_flag);

  IF (upper(ue_flag) = 'N') THEN

    IF (p_scenario_id IS NOT NULL AND p_event_no IS NOT NULL) THEN
      -- Run for selected scenario
      -- loop all wells available under selected scenario
      FOR mycur IN c_fcst_well_event_scenario LOOP
        ld_start_daytime := Ecdp_Productionday.getProductionDayStart('WELL',mycur.event_id,mycur.day);
        IF EcDp_month_lock.withinLockedMonth(ld_start_daytime) IS NOT NULL THEN
          EcDp_Month_Lock.raiseValidationError('UPDATING', ld_start_daytime, ld_start_daytime, TRUNC(ld_start_daytime,'MONTH'), 'Cannot calculate forecast deferments for a locked month.');
        END IF;
        EcDp_Month_Lock.localLockCheck('withinLockedMonth', mycur.event_id,
                                      ld_start_daytime, ld_start_daytime,
                                      'INSERTING', 'EcDp_Deferment.allocWellDeferredVolume: Cannot update the forecast deferment allocation table in a locked local month.');
        allocWellDeferredVolume(mycur.event_id, mycur.day, NVL(mycur.end_day, (TRUNC(Ecdp_Timestamp.getCurrentSysdate,'DD')-1) )); -- default is until today if event is open
      END LOOP;
    END IF;
  END IF;
END calcDeferments;

--<EC-DOC>
----------------------------------------------------------------------------------------------------------------------------------
-- Procedure      : allocWellDeferredVolume
-- Description    : Procedure used to calculate the deferment values for a well and period and output to the allocation table
--
-- Using tables   : fcst_well_event (READ), fcst_well_event_alloc (WRITE)
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
----------------------------------------------------------------------------------------------------------------------------------
--</EC-DOC>

PROCEDURE allocWellDeferredVolume(p_event_id VARCHAR2, p_from_date DATE, p_to_date DATE) IS

  -- fetch records that are involved in the current production day and well.
  -- fcst_well_event.day and end_day are calculated by triggers upon insert and holds production days for start and end of event.
  CURSOR c_fcst_well_event (cp_day DATE, cp_start_daytime DATE) IS
  SELECT fwe.daytime, -- record start daytime
         greatest(fwe.daytime, cp_start_daytime) start_date, -- start_date is minimum start of production day to calc correct duration
         least(nvl(fwe.end_date,trunc(Ecdp_Timestamp.getCurrentSysdate,'DD')), cp_start_daytime+1) end_date, -- end_date can be maximum end of production day to calc correct duration
         fwe.event_type, -- OFF or LOW events
         decode(ec_fcst_well_event.event_type(fwe.event_no), 'DOWN', 1, 'CONSTRAINT', 2, NULL, 99) sort_event_type,
         decode(ec_fcst_well_event.scheduled(fwe.event_no), 'N', 1, 'Y', 2, NULL, 1) sort_scheduled,
         decode(ec_fcst_well_event.deferment_type(fwe.event_no), 'SINGLE',1, 'GROUP_CHILD',2, 'GROUP',3) sort_deferment_type,
         fwe.event_no,
         fwe.parent_event_no,
         fwe.deferment_type,
         fwe.oil_loss_rate,
         fwe.gas_loss_rate,
         fwe.water_loss_rate,
         fwe.cond_loss_rate,
         fwe.water_inj_loss_rate,
         fwe.gas_inj_loss_rate,
         fwe.steam_inj_loss_rate,
         fwe.diluent_loss_rate,
         fwe.gas_lift_loss_rate,
         fwe.co2_inj_loss_rate,
         fwe.day,
         fwe.end_day
  FROM fcst_well_event fwe
  WHERE fwe.event_id = p_event_id
  AND (fwe.day = cp_day OR
      (fwe.day < cp_day AND (fwe.end_day IS NULL OR fwe.end_day >= cp_day)))
  ORDER BY sort_event_type ASC, start_date ASC, sort_scheduled ASC, sort_deferment_type ASC, event_no ASC; -- Sort_event_type must come first than the asset type because the Downtime/Off events take the precedence!

  CURSOR c_get_off_fcst_cnt (cp_day DATE) IS
  SELECT count(*) as off_fcst_cnt
  FROM fcst_well_event fwe
  WHERE fwe.event_id = p_event_id
  AND (fwe.day = cp_day OR
      (fwe.day < cp_day AND (fwe.end_day IS NULL OR fwe.end_day >= cp_day)))
  AND fwe.event_type = 'DOWN';

  -- get production_days between p_from_date and p_to_date valid for the well in a sorted order
  CURSOR c_production_days IS
  SELECT sd.daytime
  FROM system_days sd, well w
  WHERE w.object_id = p_event_id
  AND sd.daytime >= w.start_date AND sd.daytime < NVL(w.end_date, sd.daytime + 1)
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
                             co2_inj NUMBER
                             );
  TYPE myRec IS RECORD (event_no NUMBER,
                        daytime DATE,
                        end_date DATE,
                        oil_loss_rate NUMBER,
                        gas_loss_rate NUMBER,
                        water_loss_rate NUMBER,
                        cond_loss_rate NUMBER,
                        diluent_loss_rate NUMBER,
                        gas_lift_loss_rate NUMBER,
                        water_inj_loss_rate NUMBER,
                        gas_inj_loss_rate NUMBER,
                        steam_inj_loss_rate NUMBER,
                        co2_inj_loss_rate NUMBER,
                        loss_oil NUMBER,
                        loss_gas NUMBER,
                        loss_water NUMBER,
                        loss_cond NUMBER,
                        loss_diluent NUMBER,
                        loss_gas_lift NUMBER,
                        loss_water_inj NUMBER,
                        loss_gas_inj NUMBER,
                        loss_steam_inj NUMBER,
                        loss_co2_inj NUMBER,
                        event_type VARCHAR2(32)
                        );
  TYPE myTable IS TABLE OF myRec INDEX BY BINARY_INTEGER;

  lr_defer_event myTable;
  lr_potential myProducts;
  lr_remain_pot myProducts;
  lr_remain_qty myProducts;
  lr_well_version WELL_VERSION%ROWTYPE;
  ln_ctrl_duration NUMBER;
  ld_MaxEnd_date DATE;

  ln_off_fcst_cnt NUMBER;
  lb_found_off_fcst BOOLEAN;

  ln_oil_down_duration NUMBER;
  ln_gas_down_duration NUMBER;
  ln_water_down_duration NUMBER;
  ln_cond_down_duration NUMBER;
  ln_diluent_down_duration NUMBER;
  ln_gas_lift_down_duration NUMBER;
  ln_water_inj_down_duration NUMBER;
  ln_gas_inj_down_duration NUMBER;
  ln_steam_inj_down_duration NUMBER;
  ln_co2_inj_down_duration NUMBER;

  ln_oil_const_cnt NUMBER;
  ln_gas_const_cnt NUMBER;
  ln_water_const_cnt NUMBER;
  ln_cond_const_cnt NUMBER;
  ln_diluent_const_cnt NUMBER;
  ln_gas_lift_const_cnt NUMBER;
  ln_water_inj_const_cnt NUMBER;
  ln_gas_inj_const_cnt NUMBER;
  ln_steam_inj_const_cnt NUMBER;
  ln_co2_inj_const_cnt NUMBER;

  ln_oil_const_hrs NUMBER;
  ln_gas_const_hrs NUMBER;
  ln_water_const_hrs NUMBER;
  ln_cond_const_hrs NUMBER;
  ln_diluent_const_hrs NUMBER;
  ln_gas_lift_const_hrs NUMBER;
  ln_water_inj_const_hrs NUMBER;
  ln_gas_inj_const_hrs NUMBER;
  ln_steam_inj_const_hrs NUMBER;
  ln_co2_inj_const_hrs NUMBER;

  ln_ctrl_oil_loss_rate NUMBER;
  ln_ctrl_gas_loss_rate NUMBER;
  ln_ctrl_water_loss_rate NUMBER;
  ln_ctrl_cond_loss_rate NUMBER;
  ln_ctrl_diluent_loss_rate NUMBER;
  ln_ctrl_gas_lift_loss_rate NUMBER;
  ln_ctrl_water_inj_loss_rate NUMBER;
  ln_ctrl_gas_inj_loss_rate NUMBER;
  ln_ctrl_steam_inj_loss_rate NUMBER;
  ln_ctrl_co2_inj_loss_rate NUMBER;

BEGIN
  -- loop all days
  FOR cur_prod_day IN c_production_days LOOP -- this cursor loops all production days for the whole period.
    ld_start_daytime := Ecdp_Productionday.getProductionDayStart('WELL',p_event_id,cur_prod_day.daytime);
    IF EcDp_month_lock.withinLockedMonth(ld_start_daytime) IS NOT NULL THEN
            EcDp_Month_Lock.raiseValidationError('UPDATING', ld_start_daytime, ld_start_daytime, TRUNC(ld_start_daytime,'MONTH'), 'Cannot calculate forecast deferments for a locked month.');
    END IF;
            EcDp_Month_Lock.localLockCheck('withinLockedMonth', p_event_id,
                                     ld_start_daytime, ld_start_daytime,
                                     'INSERTING', 'Cannot update the forecast deferment allocation table in a locked local month.');

    -- before processing new events, set old records to 0 for all records for that day and object.
    UPDATE FCST_WELL_EVENT_ALLOC
    SET deferred_gas_vol = 0,
        deferred_net_oil_vol = 0,
        deferred_water_vol = 0,
        deferred_cond_vol = 0,
        deferred_gl_vol = 0,
        deferred_diluent_vol = 0,
        deferred_steam_inj_vol = 0,
        deferred_gas_inj_vol = 0,
        deferred_water_inj_vol = 0,
        deferred_co2_inj_vol = 0,
        last_updated_by = Nvl(ecdp_context.getAppUser(),USER),
        rev_no = rev_no+1
    WHERE object_id = p_event_id
    AND daytime = cur_prod_day.daytime;

    -- check if there are any deferment event for the production_day. If not, we dont need to access well potential etc.
    SELECT COUNT(*)
    INTO ln_count
    FROM fcst_well_event fwe
    WHERE fwe.event_id = p_event_id
    AND (fwe.day = cur_prod_day.daytime OR
        (fwe.day < cur_prod_day.daytime AND nvl(fwe.end_day, cur_prod_day.daytime) >= cur_prod_day.daytime ) )
    AND nvl(fwe.end_date,ld_start_daytime+1) <> ld_start_daytime; -- exclude events which ends exact at the beginning of the day we calculate. End_daytime is exclusive

    -- only access well potential if there are any deferment records
    IF ln_count > 0 THEN
      lr_well_version := ec_well_version.row_by_rel_operator(p_event_id, cur_prod_day.daytime, '<=');
      -- initialise lr_potential
      lr_potential.oil := NULL;
      lr_potential.gas := NULL;
      lr_potential.water := NULL;
      lr_potential.cond := NULL;
      lr_potential.diluent := NULL;
      lr_potential.gas_lift := NULL;
      lr_potential.water_inj := NULL;
      lr_potential.gas_inj := NULL;
      lr_potential.steam_inj := NULL;
      lr_potential.co2_inj := NULL;
      ln_off_fcst_cnt := NULL;
      lb_found_off_fcst := NULL;

      -- depending on type of well and configuration of well, get well potentials
      -- dont access well potential for a phase that is not configured for performance reasons
      IF lr_well_version.isOilProducer = 'Y' AND lr_well_version.potential_method IS NOT NULL THEN
        lr_potential.oil := ecbp_well_potential.findOilProductionPotential(p_event_id, cur_prod_day.daytime);
        lr_potential.gas := ecbp_well_potential.findGasProductionPotential(p_event_id, cur_prod_day.daytime);
        lr_potential.water := ecbp_well_potential.findWatProductionPotential(p_event_id, cur_prod_day.daytime);
        lr_remain_pot.oil := lr_potential.oil;
        lr_remain_pot.gas := lr_potential.gas;
        lr_remain_pot.water := lr_potential.water;
      END IF;

      IF lr_well_version.isGasProducer = 'Y' AND lr_well_version.potential_method IS NOT NULL THEN
        lr_potential.cond := ecbp_well_potential.findConProductionPotential(p_event_id, cur_prod_day.daytime);
        lr_potential.gas := ecbp_well_potential.findGasProductionPotential(p_event_id, cur_prod_day.daytime);
        lr_potential.water := ecbp_well_potential.findWatProductionPotential(p_event_id, cur_prod_day.daytime);
        lr_remain_pot.cond := lr_potential.cond;
        lr_remain_pot.gas := lr_potential.gas;
        lr_remain_pot.water := lr_potential.water;
      END IF;

      IF lr_well_version.isCondensateProducer = 'Y' AND lr_well_version.potential_method IS NOT NULL THEN
        lr_potential.cond := ecbp_well_potential.findConProductionPotential(p_event_id, cur_prod_day.daytime);
        lr_potential.gas := ecbp_well_potential.findGasProductionPotential(p_event_id, cur_prod_day.daytime);
        lr_potential.water := ecbp_well_potential.findWatProductionPotential(p_event_id, cur_prod_day.daytime);
        lr_remain_pot.cond := lr_potential.cond;
        lr_remain_pot.gas := lr_potential.gas;
        lr_remain_pot.water := lr_potential.water;
      END IF;

      IF lr_well_version.isGasInjector = 'Y' THEN
        lr_potential.gas_inj := ecbp_well_potential.findGasInjectionPotential(p_event_id, cur_prod_day.daytime);
        lr_remain_pot.gas_inj := lr_potential.gas_inj;
      END IF;
      IF lr_well_version.isWaterInjector = 'Y' THEN
        lr_potential.water_inj := ecbp_well_potential.findWatInjectionPotential(p_event_id, cur_prod_day.daytime);
        lr_remain_pot.water_inj := lr_potential.water_inj;
      END IF;
      IF lr_well_version.isSteamInjector = 'Y' THEN
        lr_potential.steam_inj := ecbp_well_potential.findSteamInjectionPotential(p_event_id, cur_prod_day.daytime);
        lr_remain_pot.steam_inj := lr_potential.steam_inj;
      END IF;
      IF lr_well_version.gas_lift_method IS NOT NULL THEN
        lr_potential.gas_lift := ecbp_well_potential.findGasLiftPotential(p_event_id, cur_prod_day.daytime);
        lr_remain_pot.gas_lift := lr_potential.gas_lift;
      END IF;
      IF lr_well_version.diluent_method IS NOT NULL THEN
        lr_potential.diluent := ecbp_well_potential.findDiluentPotential(p_event_id, cur_prod_day.daytime);
        lr_remain_pot.diluent := lr_potential.diluent;
      END IF;
      IF lr_well_version.isco2injector = 'Y' THEN
        lr_potential.co2_inj := ecbp_well_potential.findCo2InjectionPotential(p_event_id, cur_prod_day.daytime);
        lr_remain_pot.co2_inj := lr_potential.co2_inj;
      END IF;

      FOR cur_off_fcst_cnt IN c_get_off_fcst_cnt(cur_prod_day.daytime) LOOP
        ln_off_fcst_cnt := cur_off_fcst_cnt.off_fcst_cnt;
      END LOOP;

      IF ln_off_fcst_cnt > 0 THEN
        lb_found_off_fcst := TRUE;
      END IF;

      ln_ctrl_duration := 1;
      -- Use the control duration as 1 day for 24 hrs.

      ln_oil_down_duration := 0;
      ln_gas_down_duration := 0;
      ln_water_down_duration := 0;
      ln_cond_down_duration := 0;
      ln_diluent_down_duration := 0;
      ln_gas_lift_down_duration := 0;
      ln_water_inj_down_duration := 0;
      ln_gas_inj_down_duration := 0;
      ln_steam_inj_down_duration := 0;
      ln_co2_inj_down_duration := 0;

      ln_oil_const_cnt := 0;
      ln_gas_const_cnt := 0;
      ln_water_const_cnt := 0;
      ln_cond_const_cnt := 0;
      ln_diluent_const_cnt := 0;
      ln_gas_lift_const_cnt := 0;
      ln_water_inj_const_cnt := 0;
      ln_gas_inj_const_cnt := 0;
      ln_steam_inj_const_cnt := 0;
      ln_co2_inj_const_cnt := 0;

      ln_oil_const_hrs := 0;
      ln_gas_const_hrs := 0;
      ln_water_const_hrs := 0;
      ln_cond_const_hrs := 0;
      ln_diluent_const_hrs := 0;
      ln_gas_lift_const_hrs := 0;
      ln_water_inj_const_hrs := 0;
      ln_gas_inj_const_hrs := 0;
      ln_steam_inj_const_hrs := 0;
      ln_co2_inj_const_hrs := 0;

      ln_ctrl_oil_loss_rate := 0;
      ln_ctrl_gas_loss_rate := 0;
      ln_ctrl_water_loss_rate := 0;
      ln_ctrl_cond_loss_rate := 0;
      ln_ctrl_diluent_loss_rate := 0;
      ln_ctrl_gas_lift_loss_rate := 0;
      ln_ctrl_water_inj_loss_rate := 0;
      ln_ctrl_gas_inj_loss_rate := 0;
      ln_ctrl_steam_inj_loss_rate := 0;
      ln_ctrl_co2_inj_loss_rate := 0;

      i:=0;
      FOR cur_fcst IN c_fcst_well_event(cur_prod_day.daytime, ld_start_daytime) LOOP
        i:=i+1;
        lr_defer_event(i).event_no := cur_fcst.event_no;
        lr_defer_event(i).daytime := cur_fcst.start_date;
        lr_defer_event(i).end_date := cur_fcst.end_date;
        lr_defer_event(i).event_type := cur_fcst.event_type;

        IF i = 1 THEN
          ln_duration := cur_fcst.end_date - cur_fcst.start_date;
          ld_MaxEnd_date := cur_fcst.end_date;
        ELSIF i > 1 THEN
          IF lr_defer_event(i-1).event_type = 'DOWN' AND lr_defer_event(i).event_type = 'DOWN' THEN
              ld_MaxEnd_date := greatest(ld_MaxEnd_date, lr_defer_event(i-1).end_date);
            IF lr_defer_event(i).daytime >= lr_defer_event(i-1).daytime AND
              lr_defer_event(i).end_date <= ld_MaxEnd_date THEN
              ln_duration := 0;
            ELSIF lr_defer_event(i).daytime >= ld_MaxEnd_date AND
              lr_defer_event(i).end_date > ld_MaxEnd_date THEN
              ln_duration := lr_defer_event(i).end_date - lr_defer_event(i).daytime;
              ld_MaxEnd_date := lr_defer_event(i).end_date;
            ELSIF lr_defer_event(i).daytime < ld_MaxEnd_date AND
              lr_defer_event(i).end_date > ld_MaxEnd_date THEN
              ln_duration := lr_defer_event(i).end_date - ld_MaxEnd_date;
              ld_MaxEnd_date := lr_defer_event(i).end_date;
            END IF;
          ELSE
            -- Previous row is 'DOWN' AND current = 'CONSTRAINT' -- or -- Previous and current row is 'CONSTRAINT'
            ln_duration := cur_fcst.end_date - cur_fcst.start_date;
          END IF;
        END IF;

        IF lb_found_off_fcst = TRUE THEN
          IF i = 1 THEN
            -- First Row just update the ln_ctrl_duration value
            IF ln_duration > 0 THEN
              ln_ctrl_duration := ln_ctrl_duration - ln_duration;
            END IF;
          ELSE
            -- For second rows onwards, it needs more logic to adjust the remaining ln_duration that must not exist 24 hrs (which is 1 day)
            IF ln_duration > 0 THEN
              IF ln_ctrl_duration = 0 THEN
                ln_duration := ln_ctrl_duration;
              ELSE
                IF ln_duration > ln_ctrl_duration THEN
                  ln_duration := ln_ctrl_duration;
                  ln_ctrl_duration := 0;
                ELSE
                  ln_ctrl_duration := ln_ctrl_duration - ln_duration;
                END IF;
              END IF;
            END IF;
          END IF;
        END IF;

        lr_remain_qty.oil := lr_remain_pot.oil * ln_duration;
        lr_remain_qty.gas := lr_remain_pot.gas * ln_duration;
        lr_remain_qty.water := lr_remain_pot.water * ln_duration;
        lr_remain_qty.cond := lr_remain_pot.cond * ln_duration;
        lr_remain_qty.diluent := lr_remain_pot.diluent * ln_duration;
        lr_remain_qty.gas_lift := lr_remain_pot.gas_lift * ln_duration;
        lr_remain_qty.water_inj := lr_remain_pot.water_inj * ln_duration;
        lr_remain_qty.gas_inj := lr_remain_pot.gas_inj * ln_duration;
        lr_remain_qty.steam_inj := lr_remain_pot.steam_inj * ln_duration;
        lr_remain_qty.co2_inj := lr_remain_pot.co2_inj * ln_duration;

        IF cur_fcst.event_type = 'DOWN' THEN
          lr_defer_event(i).oil_loss_rate := lr_potential.oil;
          lr_defer_event(i).gas_loss_rate := lr_potential.gas;
          lr_defer_event(i).water_loss_rate := lr_potential.water;
          lr_defer_event(i).cond_loss_rate := lr_potential.cond;
          lr_defer_event(i).diluent_loss_rate := lr_potential.diluent;
          lr_defer_event(i).gas_lift_loss_rate := lr_potential.gas_lift;
          lr_defer_event(i).water_inj_loss_rate := lr_potential.water_inj;
          lr_defer_event(i).gas_inj_loss_rate := lr_potential.gas_inj;
          lr_defer_event(i).steam_inj_loss_rate := lr_potential.steam_inj;
          lr_defer_event(i).co2_inj_loss_rate := lr_potential.co2_inj;
        ELSE
          lr_defer_event(i).oil_loss_rate := cur_fcst.oil_loss_rate;
          lr_defer_event(i).gas_loss_rate := cur_fcst.gas_loss_rate;
          lr_defer_event(i).water_loss_rate := cur_fcst.water_loss_rate;
          lr_defer_event(i).cond_loss_rate := cur_fcst.cond_loss_rate;
          lr_defer_event(i).diluent_loss_rate := cur_fcst.diluent_loss_rate;
          lr_defer_event(i).gas_lift_loss_rate := cur_fcst.gas_lift_loss_rate;
          lr_defer_event(i).water_inj_loss_rate := cur_fcst.water_inj_loss_rate;
          lr_defer_event(i).gas_inj_loss_rate := cur_fcst.gas_inj_loss_rate;
          lr_defer_event(i).steam_inj_loss_rate := cur_fcst.steam_inj_loss_rate;
          lr_defer_event(i).co2_inj_loss_rate := cur_fcst.co2_inj_loss_rate;
        END IF;

        -- calculate how much loss the event has for the current period
        -- also check that we dont overallocate loss to the event, max loss = potential

        -- OIL
        IF lb_found_off_fcst = TRUE THEN
          IF lr_defer_event(i).oil_loss_rate IS NULL THEN
            lr_defer_event(i).loss_oil := 0;
          ELSE
            IF cur_fcst.event_type = 'DOWN' THEN
              lr_defer_event(i).loss_oil := lr_defer_event(i).oil_loss_rate * ln_duration;
              ln_oil_down_duration := ln_oil_down_duration + ln_duration;
            ELSE
              IF ln_oil_const_cnt = 0 THEN
                IF round((ln_ctrl_oil_loss_rate + (lr_defer_event(i).oil_loss_rate * (1-ln_oil_down_duration))),2) <= round(lr_potential.oil,2) THEN
                  -- ring-fencing check to prevent calculation more than potential
                  lr_defer_event(i).loss_oil := lr_defer_event(i).oil_loss_rate * (1-ln_oil_down_duration);
                  ln_oil_const_cnt := 1;
                ELSE
                  lr_defer_event(i).loss_oil := 0;
                END IF;
              ELSE
                IF round((ln_ctrl_oil_loss_rate + (((lr_potential.oil-lr_defer_event(i-1).oil_loss_rate)) * (1-ln_oil_down_duration))),2) <= round(lr_potential.oil,2) THEN
                  -- ring-fencing check to prevent calculation more than potential
                  lr_defer_event(i).loss_oil := LEAST(lr_defer_event(i).oil_loss_rate, (lr_potential.oil - lr_defer_event(i-1).oil_loss_rate))* (1-ln_oil_down_duration);
                  -- use the LEAST value to compare the current row oil_loss_rate with the previous row, so that the modified oil_loss_rate will be reflected on this condition check.
                ELSE
                  lr_defer_event(i).loss_oil := 0;
                END IF;
              END IF;
            END IF;
            ln_ctrl_oil_loss_rate := ln_ctrl_oil_loss_rate + lr_defer_event(i).loss_oil;
          END IF;
        ELSE
          IF lr_remain_qty.oil >= (lr_defer_event(i).oil_loss_rate * ln_duration) THEN
            IF ln_oil_const_hrs + (lr_defer_event(i).oil_loss_rate * ln_duration) > lr_potential.oil THEN
              lr_defer_event(i).loss_oil := lr_potential.oil - ln_oil_const_hrs;
            ELSE
              lr_defer_event(i).loss_oil := lr_defer_event(i).oil_loss_rate * ln_duration;
            END IF;
          ELSIF lr_remain_qty.oil > 0 AND lr_defer_event(i).oil_loss_rate > 0 THEN
            lr_defer_event(i).loss_oil := lr_remain_qty.oil;
          ELSE
            lr_defer_event(i).loss_oil := 0;
          END IF;
          lr_remain_qty.oil := lr_remain_qty.oil - lr_defer_event(i).loss_oil;
          ln_oil_const_hrs := ln_oil_const_hrs + lr_defer_event(i).loss_oil;
        END IF;

        -- GAS
        IF lb_found_off_fcst = TRUE THEN
          IF lr_defer_event(i).gas_loss_rate IS NULL THEN
            lr_defer_event(i).loss_gas := 0;
          ELSE
            IF cur_fcst.event_type = 'DOWN' THEN
              lr_defer_event(i).loss_gas := lr_defer_event(i).gas_loss_rate * ln_duration;
              ln_gas_down_duration := ln_gas_down_duration + ln_duration;
            ELSE
              IF ln_gas_const_cnt = 0 THEN
                IF round((ln_ctrl_gas_loss_rate + (lr_defer_event(i).gas_loss_rate * (1-ln_gas_down_duration))),2) <= round(lr_potential.gas,2) THEN
                  lr_defer_event(i).loss_gas := lr_defer_event(i).gas_loss_rate * (1-ln_gas_down_duration);
                  ln_gas_const_cnt := 1;
                ELSE
                  lr_defer_event(i).loss_gas := 0;
                END IF;
              ELSE
                IF round((ln_ctrl_gas_loss_rate + (((lr_potential.gas-lr_defer_event(i-1).gas_loss_rate)) * (1-ln_gas_down_duration))),2) <= round(lr_potential.gas,2) THEN
                  lr_defer_event(i).loss_gas := LEAST(lr_defer_event(i).gas_loss_rate, (lr_potential.gas - lr_defer_event(i-1).gas_loss_rate))* (1-ln_gas_down_duration);
                ELSE
                  lr_defer_event(i).loss_gas := 0;
                END IF;
              END IF;
            END IF;
            ln_ctrl_gas_loss_rate := ln_ctrl_gas_loss_rate + lr_defer_event(i).loss_gas;
          END IF;
        ELSE
          IF lr_remain_qty.gas >= (lr_defer_event(i).gas_loss_rate * ln_duration) THEN
            IF ln_gas_const_hrs + (lr_defer_event(i).gas_loss_rate * ln_duration) > lr_potential.gas THEN
              lr_defer_event(i).loss_gas := lr_potential.gas - ln_gas_const_hrs;
            ELSE
              lr_defer_event(i).loss_gas := lr_defer_event(i).gas_loss_rate * ln_duration;
            END IF;
          ELSIF lr_remain_qty.gas > 0 AND lr_defer_event(i).gas_loss_rate > 0 THEN
            lr_defer_event(i).loss_gas := lr_remain_qty.gas;
          ELSE
            lr_defer_event(i).loss_gas := 0;
          END IF;
          lr_remain_qty.gas := lr_remain_qty.gas - lr_defer_event(i).loss_gas;
          ln_gas_const_hrs := ln_gas_const_hrs + lr_defer_event(i).loss_gas;
        END IF;

        -- WAT
        IF lb_found_off_fcst = TRUE THEN
          IF lr_defer_event(i).water_loss_rate IS NULL THEN
            lr_defer_event(i).loss_water := 0;
          ELSE
            IF cur_fcst.event_type = 'DOWN' THEN
              lr_defer_event(i).loss_water := lr_defer_event(i).water_loss_rate * ln_duration;
              ln_water_down_duration := ln_water_down_duration + ln_duration;
            ELSE
              IF ln_water_const_cnt = 0 THEN
                IF round((ln_ctrl_water_loss_rate + (lr_defer_event(i).water_loss_rate * (1-ln_water_down_duration))),2) <= round(lr_potential.water,2) THEN
                  lr_defer_event(i).loss_water := lr_defer_event(i).water_loss_rate * (1-ln_water_down_duration);
                  ln_water_const_cnt := 1;
                ELSE
                  lr_defer_event(i).loss_water := 0;
                END IF;
              ELSE
                IF round((ln_ctrl_water_loss_rate + (((lr_potential.water-lr_defer_event(i-1).water_loss_rate)) * (1-ln_water_down_duration))),2) <= round(lr_potential.water,2) THEN
                  lr_defer_event(i).loss_water := LEAST(lr_defer_event(i).water_loss_rate, (lr_potential.water - lr_defer_event(i-1).water_loss_rate))* (1-ln_water_down_duration);
                ELSE
                  lr_defer_event(i).loss_water := 0;
                END IF;
              END IF;
            END IF;
            ln_ctrl_water_loss_rate := ln_ctrl_water_loss_rate + lr_defer_event(i).loss_water;
          END IF;
        ELSE
          IF lr_remain_qty.water >= (lr_defer_event(i).water_loss_rate * ln_duration) THEN
            IF ln_water_const_hrs + (lr_defer_event(i).water_loss_rate * ln_duration) > lr_potential.water THEN
              lr_defer_event(i).loss_water := lr_potential.water - ln_water_const_hrs;
            ELSE
              lr_defer_event(i).loss_water := lr_defer_event(i).water_loss_rate * ln_duration;
            END IF;
          ELSIF lr_remain_qty.water > 0 AND lr_defer_event(i).water_loss_rate > 0 THEN
            lr_defer_event(i).loss_water := lr_remain_qty.water;
          ELSE
            lr_defer_event(i).loss_water := 0;
          END IF;
          lr_remain_qty.water := lr_remain_qty.water - lr_defer_event(i).loss_water;
          ln_water_const_hrs := ln_water_const_hrs + lr_defer_event(i).loss_water;
        END IF;

        -- COND
        IF lb_found_off_fcst = TRUE THEN
          IF lr_defer_event(i).cond_loss_rate IS NULL THEN
            lr_defer_event(i).loss_cond := 0;
          ELSE
            IF cur_fcst.event_type = 'DOWN' THEN
              lr_defer_event(i).loss_cond := lr_defer_event(i).cond_loss_rate * ln_duration;
              ln_cond_down_duration := ln_cond_down_duration + ln_duration;
            ELSE
              IF ln_cond_const_cnt = 0 THEN
                IF round((ln_ctrl_cond_loss_rate + (lr_defer_event(i).cond_loss_rate * (1-ln_cond_down_duration))),2) <= round(lr_potential.cond,2) THEN
                  lr_defer_event(i).loss_cond := lr_defer_event(i).cond_loss_rate * (1-ln_cond_down_duration);
                  ln_cond_const_cnt := 1;
                ELSE
                  lr_defer_event(i).loss_cond := 0;
                END IF;
              ELSE
                IF round((ln_ctrl_cond_loss_rate + (((lr_potential.cond-lr_defer_event(i-1).cond_loss_rate)) * (1-ln_cond_down_duration))),2) <= round(lr_potential.cond,2) THEN
                  lr_defer_event(i).loss_cond := LEAST(lr_defer_event(i).cond_loss_rate, (lr_potential.cond - lr_defer_event(i-1).cond_loss_rate))* (1-ln_cond_down_duration);
                ELSE
                  lr_defer_event(i).loss_cond := 0;
                END IF;
              END IF;
            END IF;
            ln_ctrl_cond_loss_rate := ln_ctrl_cond_loss_rate + lr_defer_event(i).loss_cond;
          END IF;
        ELSE
          IF lr_remain_qty.cond >= (lr_defer_event(i).cond_loss_rate * ln_duration) THEN
            IF ln_cond_const_hrs + (lr_defer_event(i).cond_loss_rate * ln_duration) > lr_potential.cond THEN
              lr_defer_event(i).loss_cond := lr_potential.cond - ln_cond_const_hrs;
            ELSE
              lr_defer_event(i).loss_cond := lr_defer_event(i).cond_loss_rate * ln_duration;
            END IF;
          ELSIF lr_remain_qty.cond > 0 AND lr_defer_event(i).cond_loss_rate > 0 THEN
            lr_defer_event(i).loss_cond := lr_remain_qty.cond;
          ELSE
            lr_defer_event(i).loss_cond := 0;
          END IF;
          lr_remain_qty.cond := lr_remain_qty.cond - lr_defer_event(i).loss_cond;
          ln_cond_const_hrs := ln_cond_const_hrs + lr_defer_event(i).loss_cond;
        END IF;

        -- DILUENT
        IF lb_found_off_fcst = TRUE THEN
          IF lr_defer_event(i).diluent_loss_rate IS NULL THEN
            lr_defer_event(i).loss_diluent := 0;
          ELSE
            IF cur_fcst.event_type = 'DOWN' THEN
              lr_defer_event(i).loss_diluent := lr_defer_event(i).diluent_loss_rate * ln_duration;
              ln_diluent_down_duration := ln_diluent_down_duration + ln_duration;
            ELSE
              IF ln_diluent_const_cnt = 0 THEN
                IF round((ln_ctrl_diluent_loss_rate + (lr_defer_event(i).diluent_loss_rate * (1-ln_diluent_down_duration))),2) <= round(lr_potential.diluent,2) THEN
                  lr_defer_event(i).loss_diluent := lr_defer_event(i).diluent_loss_rate * (1-ln_diluent_down_duration);
                  ln_diluent_const_cnt := 1;
                ELSE
                  lr_defer_event(i).loss_diluent := 0;
                END IF;
              ELSE
                IF round((ln_ctrl_diluent_loss_rate + (((lr_potential.diluent-lr_defer_event(i-1).diluent_loss_rate)) * (1-ln_diluent_down_duration))),2) <= round(lr_potential.diluent,2) THEN
                  lr_defer_event(i).loss_diluent := LEAST(lr_defer_event(i).diluent_loss_rate, (lr_potential.diluent - lr_defer_event(i-1).diluent_loss_rate))* (1-ln_diluent_down_duration);
                ELSE
                  lr_defer_event(i).loss_diluent := 0;
                END IF;
              END IF;
            END IF;
            ln_ctrl_diluent_loss_rate := ln_ctrl_diluent_loss_rate + lr_defer_event(i).loss_diluent;
          END IF;
        ELSE
          IF lr_remain_qty.diluent >= (lr_defer_event(i).diluent_loss_rate * ln_duration) THEN
            IF ln_diluent_const_hrs + (lr_defer_event(i).diluent_loss_rate * ln_duration) > lr_potential.diluent THEN
              lr_defer_event(i).loss_diluent := lr_potential.diluent - ln_diluent_const_hrs;
            ELSE
              lr_defer_event(i).loss_diluent := lr_defer_event(i).diluent_loss_rate * ln_duration;
            END IF;
          ELSIF lr_remain_qty.diluent > 0 AND lr_defer_event(i).diluent_loss_rate > 0 THEN
            lr_defer_event(i).loss_diluent := lr_remain_qty.diluent;
          ELSE
            lr_defer_event(i).loss_diluent := 0;
          END IF;
          lr_remain_qty.diluent := lr_remain_qty.diluent - lr_defer_event(i).loss_diluent;
          ln_diluent_const_hrs := ln_diluent_const_hrs + lr_defer_event(i).loss_diluent;
        END IF;

        -- GAS LIFT
        IF lb_found_off_fcst = TRUE THEN
          IF lr_defer_event(i).gas_lift_loss_rate IS NULL THEN
            lr_defer_event(i).loss_gas_lift := 0;
          ELSE
            IF cur_fcst.event_type = 'DOWN' THEN
              lr_defer_event(i).loss_gas_lift := lr_defer_event(i).gas_lift_loss_rate * ln_duration;
              ln_gas_lift_down_duration := ln_gas_lift_down_duration + ln_duration;
            ELSE
              IF ln_gas_lift_const_cnt = 0 THEN
                IF round((ln_ctrl_gas_lift_loss_rate + (lr_defer_event(i).gas_lift_loss_rate * (1-ln_gas_lift_down_duration))),2) <= round(lr_potential.gas_lift,2) THEN
                  lr_defer_event(i).loss_gas_lift := lr_defer_event(i).gas_lift_loss_rate * (1-ln_gas_lift_down_duration);
                  ln_gas_lift_const_cnt := 1;
                ELSE
                  lr_defer_event(i).loss_gas_lift := 0;
                END IF;
              ELSE
                IF round((ln_ctrl_gas_lift_loss_rate + (((lr_potential.gas_lift-lr_defer_event(i-1).gas_lift_loss_rate)) * (1-ln_gas_lift_down_duration))),2) <= round(lr_potential.gas_lift,2) THEN
                  lr_defer_event(i).loss_gas_lift := LEAST(lr_defer_event(i).gas_lift_loss_rate, (lr_potential.gas_lift - lr_defer_event(i-1).gas_lift_loss_rate))* (1-ln_gas_lift_down_duration);
                ELSE
                  lr_defer_event(i).loss_gas_lift := 0;
                END IF;
              END IF;
            END IF;
            ln_ctrl_gas_lift_loss_rate := ln_ctrl_gas_lift_loss_rate + lr_defer_event(i).loss_gas_lift;
          END IF;
        ELSE
          IF lr_remain_qty.gas_lift >= (lr_defer_event(i).gas_lift_loss_rate * ln_duration) THEN
            IF ln_gas_lift_const_hrs + (lr_defer_event(i).gas_lift_loss_rate * ln_duration) > lr_potential.gas_lift THEN
              lr_defer_event(i).loss_gas_lift := lr_potential.gas_lift - ln_gas_lift_const_hrs;
            ELSE
              lr_defer_event(i).loss_gas_lift := lr_defer_event(i).gas_lift_loss_rate * ln_duration;
            END IF;
          ELSIF lr_remain_qty.gas_lift > 0 AND lr_defer_event(i).gas_lift_loss_rate > 0 THEN
            lr_defer_event(i).loss_gas_lift := lr_remain_qty.gas_lift;
          ELSE
            lr_defer_event(i).loss_gas_lift := 0;
          END IF;
          lr_remain_qty.gas_lift := lr_remain_qty.gas_lift - lr_defer_event(i).loss_gas_lift;
          ln_gas_lift_const_hrs := ln_gas_lift_const_hrs + lr_defer_event(i).loss_gas_lift;
        END IF;

        -- WAT INJ
        IF lb_found_off_fcst = TRUE THEN
          IF lr_defer_event(i).water_inj_loss_rate IS NULL THEN
            lr_defer_event(i).loss_water_inj := 0;
          ELSE
            IF cur_fcst.event_type = 'DOWN' THEN
              lr_defer_event(i).loss_water_inj := lr_defer_event(i).water_inj_loss_rate * ln_duration;
              ln_water_inj_down_duration := ln_water_inj_down_duration + ln_duration;
            ELSE
              IF ln_water_inj_const_cnt = 0 THEN
                IF round((ln_ctrl_water_inj_loss_rate + (lr_defer_event(i).water_inj_loss_rate * (1-ln_water_inj_down_duration))),2) <= round(lr_potential.water_inj,2) THEN
                  lr_defer_event(i).loss_water_inj := lr_defer_event(i).water_inj_loss_rate * (1-ln_water_inj_down_duration);
                  ln_water_inj_const_cnt := 1;
                ELSE
                  lr_defer_event(i).loss_water_inj := 0;
                END IF;
              ELSE
                IF round((ln_ctrl_water_inj_loss_rate + (((lr_potential.water_inj-lr_defer_event(i-1).water_inj_loss_rate)) * (1-ln_water_inj_down_duration))),2) <= round(lr_potential.water_inj,2) THEN
                  lr_defer_event(i).loss_water_inj := LEAST(lr_defer_event(i).water_inj_loss_rate, (lr_potential.water_inj - lr_defer_event(i-1).water_inj_loss_rate))* (1-ln_water_inj_down_duration);
                ELSE
                  lr_defer_event(i).loss_water_inj := 0;
                END IF;
              END IF;
            END IF;
            ln_ctrl_water_inj_loss_rate := ln_ctrl_water_inj_loss_rate + lr_defer_event(i).loss_water_inj;
          END IF;
        ELSE
          IF lr_remain_qty.water_inj >= (lr_defer_event(i).water_inj_loss_rate * ln_duration) THEN
            IF ln_water_inj_const_hrs + (lr_defer_event(i).water_inj_loss_rate * ln_duration) > lr_potential.water_inj THEN
              lr_defer_event(i).loss_water_inj := lr_potential.water_inj - ln_water_inj_const_hrs;
            ELSE
              lr_defer_event(i).loss_water_inj := lr_defer_event(i).water_inj_loss_rate * ln_duration;
            END IF;
          ELSIF lr_remain_qty.water_inj > 0 AND lr_defer_event(i).water_inj_loss_rate > 0 THEN
            lr_defer_event(i).loss_water_inj := lr_remain_qty.water_inj;
          ELSE
            lr_defer_event(i).loss_water_inj := 0;
          END IF;
          lr_remain_qty.water_inj := lr_remain_qty.water_inj - lr_defer_event(i).loss_water_inj;
          ln_water_inj_const_hrs := ln_water_inj_const_hrs + lr_defer_event(i).loss_water_inj;
        END IF;

        -- GAS INJ
        IF lb_found_off_fcst = TRUE THEN
          IF lr_defer_event(i).gas_inj_loss_rate IS NULL THEN
            lr_defer_event(i).loss_gas_inj := 0;
          ELSE
            IF cur_fcst.event_type = 'DOWN' THEN
              lr_defer_event(i).loss_gas_inj := lr_defer_event(i).gas_inj_loss_rate * ln_duration;
              ln_gas_inj_down_duration := ln_gas_inj_down_duration + ln_duration;
            ELSE
              IF ln_gas_inj_const_cnt = 0 THEN
                IF round((ln_ctrl_gas_inj_loss_rate + (lr_defer_event(i).gas_inj_loss_rate * (1-ln_gas_inj_down_duration))),2) <= round(lr_potential.gas_inj,2) THEN
                  lr_defer_event(i).loss_gas_inj := lr_defer_event(i).gas_inj_loss_rate * (1-ln_gas_inj_down_duration);
                  ln_gas_inj_const_cnt := 1;
                ELSE
                  lr_defer_event(i).loss_gas_inj := 0;
                END IF;
              ELSE
                IF round((ln_ctrl_gas_inj_loss_rate + (((lr_potential.gas_inj-lr_defer_event(i-1).gas_inj_loss_rate)) * (1-ln_gas_inj_down_duration))),2) <= round(lr_potential.gas_inj,2) THEN
                  lr_defer_event(i).loss_gas_inj := LEAST(lr_defer_event(i).gas_inj_loss_rate, (lr_potential.gas_inj - lr_defer_event(i-1).gas_inj_loss_rate))* (1-ln_gas_inj_down_duration);
                ELSE
                  lr_defer_event(i).loss_gas_inj := 0;
                END IF;
              END IF;
            END IF;
            ln_ctrl_gas_inj_loss_rate := ln_ctrl_gas_inj_loss_rate + lr_defer_event(i).loss_gas_inj;
          END IF;
        ELSE
          IF lr_remain_qty.gas_inj >= (lr_defer_event(i).gas_inj_loss_rate * ln_duration) THEN
            IF ln_gas_inj_const_hrs + (lr_defer_event(i).gas_inj_loss_rate * ln_duration) > lr_potential.gas_inj THEN
              lr_defer_event(i).loss_gas_inj := lr_potential.gas_inj - ln_gas_inj_const_hrs;
            ELSE
              lr_defer_event(i).loss_gas_inj := lr_defer_event(i).gas_inj_loss_rate * ln_duration;
            END IF;
          ELSIF lr_remain_qty.gas_inj > 0 AND lr_defer_event(i).gas_inj_loss_rate > 0 THEN
            lr_defer_event(i).loss_gas_inj := lr_remain_qty.gas_inj;
          ELSE
            lr_defer_event(i).loss_gas_inj := 0;
          END IF;
          lr_remain_qty.gas_inj := lr_remain_qty.gas_inj - lr_defer_event(i).loss_gas_inj;
          ln_gas_inj_const_hrs := ln_gas_inj_const_hrs + lr_defer_event(i).loss_gas_inj;
        END IF;

        -- STEAM INJ
        IF lb_found_off_fcst = TRUE THEN
          IF lr_defer_event(i).steam_inj_loss_rate IS NULL THEN
            lr_defer_event(i).loss_steam_inj := 0;
          ELSE
            IF cur_fcst.event_type = 'DOWN' THEN
              lr_defer_event(i).loss_steam_inj := lr_defer_event(i).steam_inj_loss_rate * ln_duration;
              ln_steam_inj_down_duration := ln_steam_inj_down_duration + ln_duration;
            ELSE
              IF ln_steam_inj_const_cnt = 0 THEN
                IF round((ln_ctrl_steam_inj_loss_rate + (lr_defer_event(i).steam_inj_loss_rate * (1-ln_steam_inj_down_duration))),2) <= round(lr_potential.steam_inj,2) THEN
                  lr_defer_event(i).loss_steam_inj := lr_defer_event(i).steam_inj_loss_rate * (1-ln_steam_inj_down_duration);
                  ln_steam_inj_const_cnt := 1;
                ELSE
                  lr_defer_event(i).loss_steam_inj := 0;
                END IF;
              ELSE
                IF round((ln_ctrl_steam_inj_loss_rate + (((lr_potential.steam_inj-lr_defer_event(i-1).steam_inj_loss_rate)) * (1-ln_steam_inj_down_duration))),2) <= round(lr_potential.steam_inj,2) THEN
                  lr_defer_event(i).loss_steam_inj := LEAST(lr_defer_event(i).steam_inj_loss_rate, (lr_potential.steam_inj - lr_defer_event(i-1).steam_inj_loss_rate))* (1-ln_steam_inj_down_duration);
                ELSE
                  lr_defer_event(i).loss_steam_inj := 0;
                END IF;
              END IF;
            END IF;
            ln_ctrl_steam_inj_loss_rate := ln_ctrl_steam_inj_loss_rate + lr_defer_event(i).loss_steam_inj;
          END IF;
        ELSE
          IF lr_remain_qty.steam_inj >= (lr_defer_event(i).steam_inj_loss_rate * ln_duration) THEN
            IF ln_steam_inj_const_hrs + (lr_defer_event(i).steam_inj_loss_rate * ln_duration) > lr_potential.steam_inj THEN
              lr_defer_event(i).loss_steam_inj := lr_potential.steam_inj - ln_steam_inj_const_hrs;
            ELSE
              lr_defer_event(i).loss_steam_inj := lr_defer_event(i).steam_inj_loss_rate * ln_duration;
            END IF;
          ELSIF lr_remain_qty.steam_inj > 0 AND lr_defer_event(i).steam_inj_loss_rate > 0 THEN
            lr_defer_event(i).loss_steam_inj := lr_remain_qty.steam_inj;
          ELSE
            lr_defer_event(i).loss_steam_inj := 0;
          END IF;
          lr_remain_qty.steam_inj := lr_remain_qty.steam_inj - lr_defer_event(i).loss_steam_inj;
          ln_steam_inj_const_hrs := ln_steam_inj_const_hrs + lr_defer_event(i).loss_steam_inj;
        END IF;

         -- Co2 INJ
        IF lb_found_off_fcst = TRUE THEN
          IF lr_defer_event(i).co2_inj_loss_rate IS NULL THEN
            lr_defer_event(i).loss_co2_inj := 0;
          ELSE
            IF cur_fcst.event_type = 'DOWN' THEN
              lr_defer_event(i).loss_co2_inj := lr_defer_event(i).co2_inj_loss_rate * ln_duration;
              ln_co2_inj_down_duration := ln_co2_inj_down_duration + ln_duration;
            ELSE
              IF ln_co2_inj_const_cnt = 0 THEN
                IF round((ln_ctrl_co2_inj_loss_rate + (lr_defer_event(i).co2_inj_loss_rate * (1-ln_co2_inj_down_duration))),2) <= round(lr_potential.co2_inj,2) THEN
                  lr_defer_event(i).loss_co2_inj := lr_defer_event(i).co2_inj_loss_rate * (1-ln_co2_inj_down_duration);
                  ln_co2_inj_const_cnt := 1;
                ELSE
                  lr_defer_event(i).loss_co2_inj := 0;
                END IF;
              ELSE
                IF round((ln_ctrl_co2_inj_loss_rate + (((lr_potential.co2_inj-lr_defer_event(i-1).co2_inj_loss_rate)) * (1-ln_co2_inj_down_duration))),2) <= round(lr_potential.co2_inj,2) THEN
                  lr_defer_event(i).loss_co2_inj := LEAST(lr_defer_event(i).co2_inj_loss_rate, (lr_potential.co2_inj - lr_defer_event(i-1).co2_inj_loss_rate))* (1-ln_co2_inj_down_duration);
                ELSE
                  lr_defer_event(i).loss_co2_inj := 0;
                END IF;
              END IF;
            END IF;
            ln_ctrl_co2_inj_loss_rate := ln_ctrl_co2_inj_loss_rate + lr_defer_event(i).loss_co2_inj;
          END IF;
        ELSE
          IF lr_remain_qty.co2_inj >= (lr_defer_event(i).co2_inj_loss_rate * ln_duration) THEN
            IF ln_co2_inj_const_hrs + (lr_defer_event(i).co2_inj_loss_rate * ln_duration) > lr_potential.co2_inj THEN
              lr_defer_event(i).loss_co2_inj := lr_potential.co2_inj - ln_co2_inj_const_hrs;
            ELSE
              lr_defer_event(i).loss_co2_inj := lr_defer_event(i).co2_inj_loss_rate * ln_duration;
            END IF;
          ELSIF lr_remain_qty.co2_inj > 0 AND lr_defer_event(i).co2_inj_loss_rate > 0 THEN
            lr_defer_event(i).loss_co2_inj := lr_remain_qty.co2_inj;
          ELSE
            lr_defer_event(i).loss_co2_inj := 0;
          END IF;
          lr_remain_qty.co2_inj := lr_remain_qty.co2_inj - lr_defer_event(i).loss_co2_inj;
          ln_co2_inj_const_hrs := ln_co2_inj_const_hrs + lr_defer_event(i).loss_co2_inj;
        END IF;

        -- Write to database
        SELECT COUNT(*) INTO ln_count
        FROM FCST_WELL_EVENT_ALLOC fwea
        WHERE fwea.object_id=p_event_id
        AND fwea.daytime=cur_prod_day.daytime
        AND fwea.event_no=lr_defer_event(i).event_no;
        -- Insert or update
        IF ln_count=0 THEN
          INSERT INTO FCST_WELL_EVENT_ALLOC
            (object_id, daytime, event_no,
             deferred_gas_vol, deferred_net_oil_vol, deferred_water_vol, deferred_cond_vol,
             deferred_gl_vol, deferred_diluent_vol, deferred_steam_inj_vol, deferred_gas_inj_vol, deferred_water_inj_vol,
             deferred_co2_inj_vol,created_by)
          VALUES
            (p_event_id, cur_prod_day.daytime, lr_defer_event(i).event_no,
             lr_defer_event(i).loss_gas, lr_defer_event(i).loss_oil, lr_defer_event(i).loss_water, lr_defer_event(i).loss_cond,
             lr_defer_event(i).loss_gas_lift, lr_defer_event(i).loss_diluent, lr_defer_event(i).loss_steam_inj, lr_defer_event(i).loss_gas_inj, lr_defer_event(i).loss_water_inj,
             lr_defer_event(i).loss_co2_inj,Nvl(ecdp_context.getAppUser(),USER));
        ELSE
          -- one event is part of several periods, then we have to update existing record for the wde_no and daytime
          UPDATE FCST_WELL_EVENT_ALLOC
          SET deferred_gas_vol = deferred_gas_vol + lr_defer_event(i).loss_gas,
              deferred_net_oil_vol = deferred_net_oil_vol + lr_defer_event(i).loss_oil,
              deferred_water_vol = deferred_water_vol + lr_defer_event(i).loss_water,
              deferred_cond_vol = deferred_cond_vol + lr_defer_event(i).loss_cond,
              deferred_gl_vol = deferred_gl_vol + lr_defer_event(i).loss_gas_lift,
              deferred_diluent_vol = deferred_diluent_vol + lr_defer_event(i).loss_diluent,
              deferred_steam_inj_vol = deferred_steam_inj_vol + lr_defer_event(i).loss_steam_inj,
              deferred_gas_inj_vol = deferred_gas_inj_vol + lr_defer_event(i).loss_gas_inj,
              deferred_water_inj_vol = deferred_water_inj_vol + lr_defer_event(i).loss_water_inj,
              deferred_co2_inj_vol = deferred_co2_inj_vol + lr_defer_event(i).loss_co2_inj,
              last_updated_by = Nvl(EcDp_Context.getAppUser,USER)
          WHERE object_id = p_event_id
          AND daytime = cur_prod_day.daytime
          AND event_no = lr_defer_event(i).event_no;
        END IF;
      END LOOP;
    END IF;
  END LOOP;

END allocWellDeferredVolume;

END  EcDp_Forecast_Event;