CREATE OR REPLACE FORCE VIEW "V_WELL_EVENT_DAY_COMBINATION" ("WDE_NO", "EVENT_NO", "OBJECT_ID", "DAYTIME", "END_DATE", "DEFERRED_OIL_RATE", "DEFERRED_GAS_RATE", "DEFERRED_WATER_RATE", "DEFERRED_COND_RATE", "DEFERRED_DILUENT_RATE", "DEFERRED_GAS_LIFT_RATE", "DEFERRED_GAS_INJ_RATE", "DEFERRED_WATER_INJ_RATE", "DEFERRED_STEAM_INJ_RATE", "DEF_MASS_OIL_RATE", "DEF_MASS_GAS_RATE", "DEF_MASS_WATER_RATE", "DEF_MASS_COND_RATE", "VALUE_1", "VALUE_2", "VALUE_3", "VALUE_4", "VALUE_5", "VALUE_6", "VALUE_7", "VALUE_8", "VALUE_9", "VALUE_10", "TEXT_1", "TEXT_2", "TEXT_3", "TEXT_4", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "DAY", "SUMMER_TIME", "END_DAY", "PRODUCTION_DAY", "PRODUCTION_DAY_START", "PRODUCTION_DAY_END") AS 
  (
-------------------------------------------------------------------------------------
--  v_well_event_day_combination
--
-- $Revision: 1.6 $
--
--  Purpose: Get all combinations of well_deferment_event and system_days.
--           Needed to simplify deferment equations.
--
--  Note:
-------------------------------------------------------------------------------------
select
       e.wde_no
,      e.event_no
,      e.object_id
,      e.daytime
,      nvl(e.end_date,sysdate) as end_date
,      e.deferred_oil_rate
,      e.deferred_gas_rate
,      e.deferred_water_rate
,      e.deferred_cond_rate
,      e.deferred_diluent_rate
,      e.deferred_gas_lift_rate
,      e.deferred_gas_inj_rate
,      e.deferred_water_inj_rate
,      e.deferred_steam_inj_rate
,      e.def_mass_oil_rate
,      e.def_mass_gas_rate
,      e.def_mass_water_rate
,      e.def_mass_cond_rate
,      e.value_1
,      e.value_2
,      e.value_3
,      e.value_4
,      e.value_5
,      e.value_6
,      e.value_7
,      e.value_8
,      e.value_9
,      e.value_10
,      e.text_1
,      e.text_2
,      e.text_3
,      e.text_4
,      e.record_status
,      e.created_by
,      e.created_date
,      e.last_updated_by
,      e.last_updated_date
,      e.rev_no
,      e.rev_text
,      e.day
,      e.summer_time
,      e.end_day
,      d.daytime as production_day
,      EcDp_ProductionDay.getProductionDayStart(null,e.object_id,d.daytime) as production_day_start
,      EcDp_ProductionDay.getProductionDayStart(null,e.object_id,d.daytime+1) as production_day_end
from   well_deferment_event e
,      system_days d
where  e.day<=d.daytime and nvl(e.end_day,d.daytime+1)>=d.daytime
and    (e.end_date!=EcDp_ProductionDay.getProductionDayStart('WELL',e.object_id,d.daytime) OR e.end_date IS NULL)
)