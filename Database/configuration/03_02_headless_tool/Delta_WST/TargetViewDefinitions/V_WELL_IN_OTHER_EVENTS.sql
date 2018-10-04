CREATE OR REPLACE FORCE VIEW "V_WELL_IN_OTHER_EVENTS" ("OBJECT_ID", "DAYTIME", "END_DATE", "EVENT_NO", "EVENT_TYPE", "CURRENT_DEF_TYPE", "GRP_DEF_RATE_TYPE", "DEFERRED_OIL_RATE", "DEFERRED_GAS_RATE", "DEFERRED_WATER_RATE", "DEFERRED_DILUENT_RATE", "DEFERRED_COND_RATE", "DEFERRED_GAS_LIFT_RATE", "DEFERRED_GAS_INJ_RATE", "DEFERRED_WATER_INJ_RATE", "DEFERRED_STEAM_INJ_RATE", "DEF_MASS_OIL_RATE", "DEF_MASS_GAS_RATE", "DEF_MASS_WATER_RATE", "DEF_MASS_COND_RATE", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_DATE", "LAST_UPDATED_BY", "REV_NO", "REV_TEXT") AS 
  (
-------------------------------------------------------------------------------------
--  v_well_in_other_events
--
-- $Revision: 1.6 $
--
--  Purpose:   Used by deferment screens to select well in other events
--
--  Note:
--
--  Created by: Magnus Otterå 24.03.2006
-------------------------------------------------------------------------------------
SELECT aw.object_id,
                aw.daytime,
                aw.end_date,
                e.event_no,
                e.event_type,
                e.current_def_type,
                e.grp_def_rate_type,
                decode(e.event_Type,'OFF',ecbp_well_potential.findOilProductionPotential(aw.object_id,aw.daytime),aw.deferred_oil_rate) deferred_oil_rate,
                decode(e.event_Type,'OFF',ecbp_well_potential.findGasProductionPotential(aw.object_id,aw.daytime),aw.deferred_gas_rate) deferred_gas_rate,
                decode(e.event_Type,'OFF',ecbp_well_potential.findWatProductionPotential(aw.object_id,aw.daytime),aw.deferred_water_rate) deferred_water_rate,
                decode(e.event_Type,'OFF',ecbp_well_potential.findDiluentPotential(aw.object_id,aw.daytime),aw.deferred_diluent_rate) deferred_diluent_rate,
                decode(e.event_Type,'OFF',ecbp_well_potential.findConProductionPotential(aw.object_id,aw.daytime),aw.deferred_cond_rate) deferred_cond_rate,
                decode(e.event_Type,'OFF',ecbp_well_potential.findGasLiftPotential(aw.object_id,aw.daytime),aw.deferred_gas_lift_rate) deferred_gas_lift_rate,
                decode(e.event_Type,'OFF',ecbp_well_potential.findGasInjectionPotential(aw.object_id,aw.daytime),aw.deferred_gas_inj_rate) deferred_gas_inj_rate,
                decode(e.event_Type,'OFF',ecbp_well_potential.findWatInjectionPotential(aw.object_id,aw.daytime),aw.deferred_water_inj_rate) deferred_water_inj_rate,
                decode(e.event_Type,'OFF',ecbp_well_potential.findSteamInjectionPotential(aw.object_id,aw.daytime),aw.deferred_steam_inj_rate) deferred_steam_inj_rate,
                decode(e.event_Type,'OFF',ecbp_well_potential.findOilMassProdPotential(aw.object_id,aw.daytime),aw.def_mass_oil_rate) def_mass_oil_rate,
                decode(e.event_Type,'OFF',ecbp_well_potential.findGasMassProdPotential(aw.object_id,aw.daytime),aw.def_mass_gas_rate) def_mass_gas_rate,
                decode(e.event_Type,'OFF',ecbp_well_potential.findWaterMassProdPotential(aw.object_id,aw.daytime),aw.def_mass_water_rate) def_mass_water_rate,
                decode(e.event_Type,'OFF',ecbp_well_potential.findCondMassProdPotential(aw.object_id,aw.daytime),aw.def_mass_cond_rate) def_mass_cond_rate,
                aw.record_status,
                aw.created_by,
                aw.created_date,
                aw.last_updated_date,
                aw.last_updated_by,
                aw.rev_no,
                aw.rev_text
FROM fcty_deferment_event e, well_deferment_event aw
WHERE aw.event_no = e.event_no
)