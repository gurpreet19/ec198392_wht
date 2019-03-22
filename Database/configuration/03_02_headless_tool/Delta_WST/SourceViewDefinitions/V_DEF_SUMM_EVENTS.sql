CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DEF_SUMM_EVENTS" ("DAYTIME", "PARENT_EVENT_NO", "OIL_VOL", "GAS_VOL", "WATER_VOL", "COND_VOL", "GL_VOL", "DILUENT_VOL", "STEAM_INJ_VOL", "GAS_INJ_VOL", "WATER_INJ_VOL") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: V_DEF_SUMM_EVENTS.sql
-- View name: V_DEF_SUMM_EVENTS
--
-- $Revision: 1.0 $
--
-- Purpose  : This view is used in Deferment Summary (PD.0016) to display daily aggregated loss volumes for Group Events
--
-- Modification history:
--
-- Date       	Whom  		Change description:
-- ---------- 	----  		--------------------------------------------------------------------------------
-- 31.10.2018   khatrnit  	ECPD-58811: View created for used in Deferment Summary (PD.0016) to display daily aggregated loss volumes for Group Events
----------------------------------------------------------------------------------------------------
SELECT
  wd.daytime as daytime,
  de.parent_event_no as parent_event_no,
  SUM(wd.deferred_net_oil_vol) AS oil_vol,
  SUM(wd.deferred_gas_vol) AS gas_vol,
  SUM(wd.deferred_water_vol) AS water_vol,
  SUM(wd.deferred_cond_vol) AS cond_vol,
  SUM(wd.deferred_gl_vol) AS gl_vol,
  SUM(wd.deferred_diluent_vol) AS diluent_vol,
  SUM(wd.deferred_steam_inj_vol) AS steam_inj_vol,
  SUM(wd.deferred_gas_inj_vol) AS gas_inj_vol,
  SUM(wd.deferred_water_inj_vol) AS water_inj_vol
FROM well_day_defer_alloc wd
INNER JOIN deferment_event de ON wd.event_no = de.event_no
WHERE de.deferment_type='GROUP_CHILD'
GROUP BY wd.daytime, de.parent_event_no
)