CREATE OR REPLACE PACKAGE BODY EcBp_Defer_Master_Event IS
/****************************************************************
** Package        :  EcBp_Defer_Master_Event
**
** $Revision: 1.8 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Daily Deferment Master.
**
** Documentation  :  www.energy-components.com
**
** Created  : 20.12.2006  Sarojini Rajaretnam
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 15.02.2008 kaurrjes ECPD-6544: Modified aggregrateDayDeferredVolume and aggregrateMasterDeferredVolume functions.
** 27.06.2008 farhaann ECPD-8939: Updated ORA number for error messages
** 03.03.2009 madondin ECPD-11094:Added missing assigning value for lv2_defer_level_objectid
** 08.09.2009 amirrasn ECPD-12536:Modified procedure verifyDefermentEvent to enhance deletion of record in Daily Deferment Summary
** 07.07.2010 rajarsar ECPD-14223:Modified procedure verifyDefermentEvent to use defer_level_object_id from def_day_master_event instead of def_day_deferment_event
** 20.10.2011 abdulmaw ECPD-18546:Added function calcDefDailyActionVolume and procedure VerifyActionsDefDaily
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : verifyDefermentEvent
-- Description    : This procedure checks valid rules for Daily Deferment Event data section in Daily Deferment Master before inserting and updating records.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions: def_day_master_event, def_day_summary_events
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
PROCEDURE verifyDefermentEvent(p_deferment_no NUMBER, p_incident_no NUMBER, p_daytime DATE, p_end_date DATE)

IS

ln_linkmaster_record_count INTEGER;
ld_def_day_def_prod_daytime DATE;
ld_def_day_def_prod_end_date DATE;
lv2_defer_level_objectid VARCHAR2(32);

CURSOR c_validate1
IS
SELECT daytime, end_date, defer_level_object_id
FROM def_day_master_event
WHERE incident_no = p_incident_no;

CURSOR c_validate2
IS
SELECT *
FROM def_day_summary_event
WHERE deferment_event_no = p_deferment_no;


BEGIN

 lv2_defer_level_objectid := ec_def_day_deferment_event.defer_level_object_id(p_incident_no);

  IF (lv2_defer_level_objectid IS NULL) THEN
  	lv2_defer_level_objectid := ec_def_day_master_event.defer_level_object_id(p_incident_no);
  END IF;

  -- Get the production day of the deferment event daytime as it can start at different hours of the day
  ld_def_day_def_prod_daytime := ecdp_productionday.getProductionDay(NULL, lv2_defer_level_objectid, p_daytime);

  -- Get the production day of the deferment event end_date as it can start at different hours of the day
  ld_def_day_def_prod_end_date := ecdp_productionday.getProductionDay(NULL, lv2_defer_level_objectid, p_end_date);


  ln_linkmaster_record_count := 0;
  SELECT COUNT(*)
  INTO ln_linkmaster_record_count
  FROM def_day_master_event
	WHERE  incident_no = p_incident_no;

  -- Check that the Deferment Dates are within the dates for the linked Master Event.
  IF p_incident_no is NOT NULL THEN
    FOR cur_Validate1 IN c_validate1 LOOP
      -- check for daytime
      IF (ld_def_day_def_prod_daytime < cur_Validate1.daytime) THEN
        Raise_Application_Error(-20215,'Start DayTime must be after Start Day of the Linked Master Event.');
      END IF;
      --- check for end_date
		  IF cur_Validate1.end_date IS NOT NULL THEN
        IF (ld_def_day_def_prod_end_date IS NOT NULL AND ld_def_day_def_prod_end_date > cur_Validate1.end_date) THEN
			    Raise_Application_Error(-20211,'End DayTime must be before End Day of the Linked Master Event.');
        END IF;
      END IF;
		END LOOP;
  END IF;

  -- Check for invalid Incident No (doesn't exist at all.)
  IF p_incident_no is NOT NULL AND ln_linkmaster_record_count = 0 THEN
	  RAISE_APPLICATION_ERROR(-20210,'Linked Master Incident No is invalid.');
  END IF;

END verifyDefermentEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : verifyMasterDefermentEvent
-- Description    : This procedure checks valid rules for Master Deferment Events in Daily Deferment Master screen before updating.
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

PROCEDURE verifyMasterDefermentEvent(p_incident_no NUMBER, p_end_date DATE)

IS
ld_def_day_mst_prod_end_date DATE;
lv2_defer_level_objectid VARCHAR2(32);

CURSOR c_validate1
IS
SELECT *
FROM def_day_deferment_event
WHERE  incident_no = p_incident_no;

BEGIN

  lv2_defer_level_objectid := ec_def_day_master_event.defer_level_object_id(p_incident_no);

  IF p_incident_no IS NOT NULL AND p_end_date IS NOT NULL THEN
    FOR cur_Validate1 IN c_validate1 LOOP
	    IF cur_Validate1.end_date IS NOT NULL THEN
        -- Get the production day of the deferment event end_date as it can start at different hours of the day
        ld_def_day_mst_prod_end_date := ecdp_productionday.getProductionDay (NULL, lv2_defer_level_objectid, cur_Validate1.end_date);
        IF ld_def_day_mst_prod_end_date > p_end_date THEN
		      Raise_Application_Error(-20212,'End Day must be after End DayTime of the Linked Deferment Event.');
		    END IF;
      END IF;
  END LOOP;
END IF;

END verifyMasterDefermentEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : verifyDelMasterDefermentEvent
-- Description    : This procedure checks if there is linked Deferment Events before deleting the record in Master Deferment Event in Daily Deferment Screen.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   : def_day_deferment_event
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
PROCEDURE verifyDelMasterDefermentEvent(p_incident_no NUMBER)

IS
ln_link_def_event_record_count	INTEGER;

BEGIN

  ln_link_def_event_record_count := 0;

  SELECT COUNT(*)
	INTO 	ln_link_def_event_record_count
  FROM def_day_deferment_event
	WHERE  incident_no = p_incident_no;

  IF p_incident_no is NOT NULL and ln_link_def_event_record_count > 0 THEN
	  RAISE_APPLICATION_ERROR(-20213,'Delete cannot be performed on Master Event with Incident No linked to Deferment Events.');
  END IF;

END verifyDelMasterDefermentEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : verifyDelDefermentEvent
-- Description    : This procedure checks if there is Daily Deferment Summary records before deleting the record in Deferment Event in Daily Deferment Master Screen.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   : def_day_deferment_event
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
PROCEDURE verifyDelDefermentEvent(p_deferment_event_no NUMBER)

IS
ln_def_event_summary_count	INTEGER;

BEGIN

  ln_def_event_summary_count := 0;

  SELECT COUNT(*)
	INTO 	ln_def_event_summary_count
  FROM def_day_summary_event
	WHERE  deferment_event_no = p_deferment_event_no;


  IF p_deferment_event_no IS NOT NULL and ln_def_event_summary_count > 0 THEN
	  Raise_Application_Error(-20214,'Records in Daily Deferment Summary must be deleted first.');
  END IF;

END verifyDelDefermentEvent;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAsset
-- Description    : Returns the deferment Asset if exists to the Daily Deferment Summary Screen.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : def_day_deferment_event
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the deferment Asset if exists
--
---------------------------------------------------------------------------------------------------
FUNCTION getAsset(
   p_deferment_no	NUMBER
)
RETURN VARCHAR2
--</EC-DOC>
IS

lv2_def_asset VARCHAR2(32);
ld_def_start_day DATE;
lv2_asset VARCHAR2(240);

CURSOR c_def_asset (p_deferment_no NUMBER)IS
SELECT asset_id, daytime
FROM def_day_master_event
WHERE incident_no in (SELECT incident_no
FROM def_day_deferment_event
WHERE deferment_event_no = p_deferment_no);

BEGIN
  FOR curDefAsset IN c_def_asset(p_deferment_no) LOOP
    lv2_def_asset:= curDefAsset.asset_id;
    ld_def_start_day := curDefAsset.daytime;
  END LOOP;

  IF lv2_def_asset IS NOT NULL AND ld_def_start_day IS NOT NULL THEN
    lv2_asset :=ecdp_objects.getobjname(lv2_def_asset, ld_def_start_day);
  END IF;
  RETURN lv2_asset;
END getAsset;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : aggregrateDayDeferredVolume                                                   --
-- Description    : Aggregrates Volumes based on phase and returns the value to Deferment Events.
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : DEF_DAY_DEFERMENT_EVENT, DEF_DAY_SUMMARY_EVENTS
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

FUNCTION aggregrateDayDeferredVolume(p_deferment_no NUMBER, p_phase VARCHAR2) RETURN NUMBER
--</EC-DOC>
IS

ln_deferred_day_volume NUMBER;

CURSOR c_def_day_summary_events IS
SELECT DECODE(p_phase,
  'OIL',sum(ddse.def_oil_vol),
  'GAS',sum(ddse.def_gas_vol),
  'COND',sum(ddse.def_cond_vol),
  'WATER',sum(ddse.def_water_vol),
  'WATER_INJ',sum(ddse.def_water_inj_vol),
  'GAS_INJ',sum(ddse.def_gas_inj_vol),
  'OIL_MASS',sum(ddse.def_oil_mass),
  'GAS_MASS', sum(ddse.def_gas_mass),
  'WATER_INJ_MASS',sum(ddse.def_water_inj_mass),
  'GAS_INJ_MASS',sum(ddse.def_gas_inj_mass),
  'WATER_MASS',sum(ddse.def_water_mass),
  'COND_MASS',sum(ddse.def_cond_mass),
  'STEAM_INJ_MASS',sum(ddse.def_steam_inj_mass),
  'GAS_ENERGY',sum(ddse.def_gas_energy),
  'STEAM_INJ',sum(ddse.def_steam_inj_vol)) sum_vol
FROM def_day_deferment_event ddde, def_day_summary_event ddse
WHERE ddse.deferment_event_no = ddde.deferment_event_no
AND ddde.deferment_event_no = p_deferment_no;

BEGIN
  FOR mycur IN c_def_day_summary_events LOOP
    ln_deferred_day_volume := mycur.sum_vol;
  END LOOP;

  RETURN nvl(ln_deferred_day_volume,0);

END aggregrateDayDeferredVolume;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : aggregrateMasterDeferredVolume                                                   --
-- Description    : Aggregrates Volumes based on phase and returns the value to Master Deferment Events.
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : DEF_DAY_DEFERMENT_EVENT, DEF_DAY_MASTER_EVENTS
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

FUNCTION aggregrateMasterDeferredVolume(p_incident_no NUMBER, p_phase VARCHAR2) RETURN NUMBER
--</EC-DOC>
IS

ln_deferred_master_volume  NUMBER;

CURSOR c_def_day_summary_events IS
SELECT DECODE(p_phase,
  'OIL',sum(ddse.def_oil_vol),
  'GAS',sum(ddse.def_gas_vol),
  'COND',sum(ddse.def_cond_vol),
  'WATER',sum(ddse.def_water_vol),
  'WATER_INJ',sum(ddse.def_water_inj_vol),
  'GAS_INJ',sum(ddse.def_gas_inj_vol),
  'OIL_MASS',sum(ddse.def_oil_mass),
  'GAS_MASS', sum(ddse.def_gas_mass),
  'WATER_INJ_MASS',sum(ddse.def_water_inj_mass),
  'GAS_INJ_MASS',sum(ddse.def_gas_inj_mass),
  'WATER_MASS',sum(ddse.def_water_mass),
  'COND_MASS',sum(ddse.def_cond_mass),
  'STEAM_INJ_MASS',sum(ddse.def_steam_inj_mass),
  'GAS_ENERGY',sum(ddse.def_gas_energy),
  'STEAM_INJ',sum(ddse.def_steam_inj_vol)) sum_vol
FROM def_day_master_event ddme, def_day_deferment_event ddde, def_day_summary_event ddse
WHERE ddse.deferment_event_no = ddde.deferment_event_no
AND ddde.incident_no = ddme.incident_no
AND ddme.incident_no = p_incident_no;

BEGIN
  FOR mycur IN c_def_day_summary_events LOOP
    ln_deferred_master_volume := mycur.sum_vol;
  END LOOP;

  RETURN nvl(ln_deferred_master_volume,0);

END aggregrateMasterDeferredVolume;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : CalcDefDailyActionVolume
-- Description    : This function finds the deffered volume for the given corrective action period
--                  for daily deferment master.
--                  volume =  event grp volume * corr action period/event period
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : DEF_DAY_DEFERMENT_EVENT, DEF_DAY_MASTER_EVENTS
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION calcDefDailyActionVolume(p_incident_no NUMBER, p_daytime DATE, p_end_date DATE, p_phase VARCHAR2) RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_event_def_daily_qty IS
  SELECT ddme.daytime,
         ddme.end_date,
    sum(ddse.def_oil_vol) oil_vol,
    sum(ddse.def_gas_vol) gas_vol,
    sum(ddse.def_cond_vol) cond_vol,
    sum(ddse.def_water_vol) water_vol,
    sum(ddse.def_water_inj_vol) water_inj_vol,
    sum(ddse.def_gas_inj_vol) gas_inj_vol,
    sum(ddse.def_steam_inj_vol) steam_inj_vol
  FROM def_day_master_event ddme, def_day_deferment_event ddde, def_day_summary_event ddse
  WHERE ddse.deferment_event_no = ddde.deferment_event_no
  AND ddde.incident_no = ddme.incident_no
  AND ddme.incident_no = p_incident_no
  GROUP BY ddme.daytime,ddme.end_date;
  ln_return NUMBER;
  ln_event_qty NUMBER;
  ln_duration NUMBER;
  ln_corr_action_duration NUMBER;

BEGIN

  ln_return := 0;
  FOR cur_event IN c_event_def_daily_qty LOOP

    ln_duration := cur_event.end_date - cur_event.daytime;
    ln_corr_action_duration := p_end_date - p_daytime;

    IF p_phase = 'OIL' THEN
      ln_event_qty := cur_event.oil_vol;
    ELSIF p_phase = 'GAS' THEN
      ln_event_qty := cur_event.gas_vol;
    ELSIF p_phase = 'COND' THEN
      ln_event_qty := cur_event.cond_vol;
    ELSIF p_phase = 'WATER' THEN
      ln_event_qty := cur_event.water_vol;
    ELSIF p_phase = 'WATER_INJ' THEN
      ln_event_qty := cur_event.water_inj_vol;
    ELSIF p_phase = 'GAS_INJ' THEN
      ln_event_qty := cur_event.gas_inj_vol;
    ELSIF p_phase = 'STEAM_INJ' THEN
      ln_event_qty := cur_event.steam_inj_vol;
    END IF;

    IF ln_duration <> 0 THEN
      ln_return := ln_event_qty / ln_duration * ln_corr_action_duration;
    END IF;

  END LOOP;

  RETURN ln_return;

END CalcDefDailyActionVolume;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : VerifyActionsDefDaily
-- Description    : This procedure checks that we don't have any overlapping actions on events for Daily Deferment Masters
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
PROCEDURE VerifyActionsDefDaily(p_event_no NUMBER, p_daytime DATE, p_end_date DATE, p_action VARCHAR2)

IS
	CURSOR c_overlapping_actions  IS
		SELECT *
		FROM DEFERMENT_CORR_ACTION  dca
		WHERE (dca.end_date > p_daytime OR dca.end_date IS NULL)
    AND (dca.daytime < p_end_date OR p_end_date IS NULL)
    AND dca.event_no = p_event_no
    AND dca.action != p_action;


  CURSOR c_outside_event  IS
		SELECT *
		FROM DEF_DAY_MASTER_EVENT  ddme
		WHERE (ddme.daytime > p_daytime
    OR ddme.end_date < p_daytime
    OR ddme.end_date < p_end_date)
    AND ddme.incident_no = p_event_no;

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
    RAISE_APPLICATION_ERROR(-20625, 'This action overlaps with existing action');
  END IF;

  FOR cur_outside_event IN c_outside_event LOOP
    lv_outside_message := lv_outside_message || cur_outside_event.incident_no || ' ';
  END LOOP;

  IF lv_outside_message is not null THEN
    -- TODO: Get the right error code
    RAISE_APPLICATION_ERROR(-20626, 'This action time period are outside event time period.');
  END IF;
END VerifyActionsDefDaily;

END EcBp_Defer_Master_Event;