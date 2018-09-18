CREATE OR REPLACE PACKAGE BODY EcDp_Defer_Master_Event IS
/****************************************************************
** Package        :  EcDp_Defer_Master_Event
**
** $Revision: 1.2 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Daily Deferment.
**
** Documentation  :  www.energy-components.com
**
** Created  : 26.12.2006  Sarojini Rajaretnam
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 01.04.08   RAJARSAR ECPD-7844 Replaced getNumHours with 24 at calcEventDuration
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : createSummaryRecordsDefermentEvent
-- Description    : This procedure inserts a new record in DEF_DAY_SUMMARY_EVENTS based on insertion of a new record in
--                  DEF_DAY_DEFERMENT_EVENT in the Daily Deferment Master screen.
-- Preconditions  :
--
-- Postconditions :
-- Using tables   : DEF_DAY_SUMMARY_EVENTS
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
PROCEDURE createSummaryRecords(p_defer_level_object_id VARCHAR2, p_deferment_event_no NUMBER)
IS

CURSOR summary_exists (cp_defer_level_object_id VARCHAR2, cp_deferment_event_no NUMBER, cp_start_daytime DATE) IS
SELECT daytime
FROM def_day_summary_event
WHERE defer_level_object_id = p_defer_level_object_id
AND deferment_event_no = p_deferment_event_no
AND daytime = cp_start_daytime;

ld_deferment_start_daytime DATE;
ld_def_summary_daytime DATE;

BEGIN

  ld_deferment_start_daytime := ec_def_day_deferment_event.daytime(p_deferment_event_no);

  -- To get the Production day the event belongs to.
  IF ecdp_objects.GetObjClassName(p_defer_level_object_id) = 'SUB_AREA' THEN
    ld_def_summary_daytime := EcDp_ProductionDay.getProductionDay('EC_DEFAULT', p_defer_level_object_id, ld_deferment_start_daytime);
  ELSE
    ld_def_summary_daytime := EcDp_ProductionDay.getProductionDay(NULL, p_defer_level_object_id, ld_deferment_start_daytime);
  END IF ;

  FOR one IN summary_exists (p_defer_level_object_id, p_deferment_event_no, ld_def_summary_daytime) LOOP
    EXIT;
  END LOOP;

  -- Inserts the initial record into DEF_DAY_SUMMARY_EVENTS.
  INSERT INTO DEF_DAY_SUMMARY_EVENT
  (defer_level_object_id, daytime, deferment_event_no, def_oil_vol, def_gas_vol, def_water_inj_vol, def_gas_inj_vol, def_water_vol, def_cond_vol, def_steam_inj_vol)
  SELECT p_defer_level_object_id, ld_def_summary_daytime, p_deferment_event_no, initial_def_oil_vol, initial_def_gas_vol, initial_def_water_inj_vol, initial_def_gas_inj_vol, initial_def_water_vol,initial_def_cond_vol, initial_def_steam_inj_vol
  FROM def_day_deferment_event WHERE deferment_event_no = p_deferment_event_no;

END createSummaryRecords;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcEventDuration
-- Description    :
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   : DEF_DAY_SUMMARY_EVENTS
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
FUNCTION calcEventDuration(p_event_start_daytime DATE,
                              p_event_end_daytime   DATE,
                              p_day                 DATE) RETURN NUMBER
--</EC-DOC>
IS
ln_retval NUMBER;

BEGIN

  ln_retval := (LEAST(Nvl(p_event_end_daytime, p_day+1), p_day+1) - GREATEST(p_event_start_daytime, p_day) ) * 24;

  RETURN Nvl(ln_retval,0);
END calcEventDuration;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcDuration
-- Description    : Calculates hours during the production day, the event is part of the loss event.
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
FUNCTION calcDuration(p_deferment_no NUMBER,
                              p_summary_daytime DATE
) RETURN NUMBER
--</EC-DOC>
IS

lv2_daily_def_level_class VARCHAR2(32);
lr_deferment_event  Def_Day_Deferment_Event%ROWTYPE;
ln_durationfrac  NUMBER;

BEGIN

  lr_deferment_event := ec_def_day_deferment_event.row_by_pk(p_deferment_no);
  lv2_daily_def_level_class := EcDp_Objects.getObjClassName(lr_deferment_event.defer_level_object_id);

  IF lv2_daily_def_level_class = 'SUB_AREA' THEN

    ln_durationfrac := calcEventDuration(lr_deferment_event.daytime, lr_deferment_event.end_date,
                           (p_summary_daytime + EcDp_ProductionDay.getProductionDayOffset('EC_DEFAULT', lr_deferment_event.defer_level_object_id, p_summary_daytime)/24)
                           );
  ELSE
    ln_durationfrac := calcEventDuration(lr_deferment_event.daytime, lr_deferment_event.end_date,
                           (p_summary_daytime + EcDp_ProductionDay.getProductionDayOffset(NULL, lr_deferment_event.defer_level_object_id, p_summary_daytime)/24)
                           );
  END IF;

  RETURN ln_durationfrac;
END calcDuration;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : verifyEvents
-- Description    : The Procedure verifies Deferment Events based on defer level object id and From Date in the navigator in the screen Deferment master in particular
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : def_day_deferment_event
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
PROCEDURE verifyEvents(p_deferment_event_no NUMBER)
--</EC-DOC>
IS


BEGIN
  UPDATE def_day_deferment_event SET status='Verified',record_status='V'
  WHERE deferment_event_no = p_deferment_event_no
  AND end_date IS NOT NULL;

END verifyEvents;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : approveEvents
-- Description    : The Procedure approve Deferment Events based on defer level object id and From Date in the navigator in the screen Deferment master in particular
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : def_day_master_event, def_day_deferment_event
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
PROCEDURE approveEvents(p_incident_no	NUMBER)
--</EC-DOC>
IS


BEGIN

  UPDATE def_day_master_event SET status='Approved', record_status='A'
  WHERE incident_no = p_incident_no
  AND end_date IS NOT NULL ;


  UPDATE def_day_deferment_event SET status = 'Approved', record_status ='A'
  WHERE incident_no in
  (SELECT incident_no FROM def_day_master_event WHERE end_date IS NOT NULL);

END approveEvents;


END EcDp_Defer_Master_Event;