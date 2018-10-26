CREATE OR REPLACE PACKAGE BODY EcDp_Deferment_Event IS
/****************************************************************
** Package        :  EcDp_Deferment_Event
**
** $Revision: 1.23.24.2 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to deferment.
**
** Documentation  :  www.energy-components.com
**
** Created  : 10.04.2006  Egil Ølberg
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 11.04.2006 olberegi Added function calcWellProdLossDay.
** 13.11.2006	siahohwi Added function updateEndDateForWellDeferment
** 14.12.2006 Toha     ECPD4569 - Test on WELL_STATUS should be repalce with test on ACTIVE_WELL_STATUS
** 17.04.2007 kaurrjes ECPD-5086: Added a function called IsWellOpen to check if a well is open into procedure insertAffectedWells.
** 25.05.2007 kaurrjes ECPD-5730: Updated updateEndDateForWellDeferment to always set end date for well events (to avoid inconsistencies)
** 06.09.2007 rajarsar ECPD-6264: Added function calculateDeferedGrpMass, calculateDeferedMass, calcWellProdLossDayMass
** 29.11.2007 leongsei ECPD-7076: modified function insertAffectedWells to auto insert all wells belongs to the selected facility
**                                modified function updateEndDateForWellDeferment to update end daytime if is null or equal to parent old end date value
**                                added function updateStartDateForWellDefermnt
** 16.06.2008 rajarsar ECPD-6880: Updated moveEvent and insertAffectedWells
** 08.07.2009 aliassit ECPD-11997 Added procedure setParentEndDate
** 28.07.2009 oonnnng  ECPD-9392: Updated moveEvent() function to copy grp_def_rate_type, grp_def_rate, activity_owner, comments from SHORT event to LONG event.
                                  Updated moveEvent() function to raise error message to stop the operation 'Copy from SHORT to LONG' event', when the daytime is NOT NULL.
** 03.04.2012 limmmchu ECPD-20473 Added procedure updateDateForWellDefermnt, deleted procedure updateStartDateForWellDefermnt
** 28.10.2013 choooshu ECPD-25727: Added function countChildEvent and deleteChildEvent
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : moveEvent
-- Description    : Moves given event between short term and long term
--
-- Preconditions  :
--
-- Postconditions : CURRENT_DEF_TYPE are updated on the given event
--
-- Using tables   : fcty_deferment_event
--
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE moveEvent(p_eventNo NUMBER,p_def_type VARCHAR2, p_daytime DATE, p_end_date DATE)
--</EC-DOC>
IS

CURSOR cur_well_deferment_event IS
SELECT *
FROM well_deferment_event
WHERE event_no = p_eventNo
AND (end_date >=  EcDp_Date_Time.getCurrentSysdate or end_date is null);

CURSOR cur_well_def_event IS
SELECT *
FROM well_deferment_event
WHERE event_no = p_eventNo
AND end_date IS NULL
FOR UPDATE;

   TYPE t_well_deferment_event IS TABLE OF well_deferment_event%ROWTYPE;
   l_data_well_def_event t_well_deferment_event;
   lv2_move_event VARCHAR2(32);
   lv2_sys_date DATE;
   ln_new_event_no NUMBER;


BEGIN

     IF p_def_type = 'SHORT' THEN

        update fcty_deferment_event fde set fde.current_def_type = p_def_type where fde.event_no = p_eventNo;


     ELSE -- when p_def_type = 'LONG' which is for Move to long term,  the behavior is different

        lv2_move_event := nvl(ec_ctrl_system_attribute.attribute_text(p_daytime, 'MOVE_TO_LONG_TERM' ,'<='), 'MOVE_ONLY');
        lv2_sys_date   := EcDp_Date_Time.getCurrentSysdate;


        -- MOVE_ONLY
        IF lv2_move_event = 'MOVE_ONLY' THEN
           update fcty_deferment_event fde set fde.current_def_type = p_def_type where fde.event_no = p_eventNo;

         -- COPY_MOVE
        ELSE

         --set end date for existing record if its end date is null
           IF p_end_date IS NULL THEN

              UPDATE fcty_deferment_event fde
              SET fde.end_date   = lv2_sys_date
              WHERE fde.event_no = p_eventNo;

           END IF;

           EcDp_System_Key.assignNextNumber('FCTY_DEFERMENT_EVENT',ln_new_event_no);

           -- insert a new record into fcty_deferment_event
           INSERT INTO fcty_deferment_event (
             event_no,
             object_id,
             daytime,
             event_type,
             current_def_type,
             original_def_type,
             asset_type,
             asset_id,
             grp_def_rate_type,
             grp_def_rate,
             activity_owner,
             comments)
             SELECT ln_new_event_no, object_id, nvl(p_end_date,lv2_sys_date), event_type, 'LONG', 'SHORT', asset_type, asset_id,
             grp_def_rate_type, grp_def_rate, activity_owner, comments
             FROM fcty_deferment_event
             WHERE event_no = p_eventNo;

           -- insert for well_deferment_event
           OPEN cur_well_deferment_event;
           LOOP
           FETCH cur_well_deferment_event BULK COLLECT INTO  l_data_well_def_event LIMIT 2000;

           IF l_data_well_def_event.COUNT <= 0 THEN
              RAISE_APPLICATION_ERROR(-20000,'The selected event is already end dated, and it cannot be moved to long term.');
           END IF;

           FOR i IN 1..l_data_well_def_event.COUNT LOOP
              l_data_well_def_event(i).wde_no            := NULL;
              l_data_well_def_event(i).daytime           := nvl(p_end_date,lv2_sys_date);
              l_data_well_def_event(i).event_no          := ln_new_event_no;
              l_data_well_def_event(i).original_event_no := p_eventNo;
           END LOOP;

           FORALL i IN 1..l_data_well_def_event.COUNT
              INSERT INTO well_deferment_event VALUES l_data_well_def_event(i);

              EXIT WHEN cur_well_deferment_event%NOTFOUND;
           END LOOP;
           CLOSE cur_well_deferment_event;

            --set end date for existing record if its end date is null
           FOR thisrow  IN cur_well_def_event LOOP

              UPDATE well_deferment_event
              SET end_date = lv2_sys_date
              WHERE CURRENT OF cur_well_def_event;

           END LOOP;

        END IF;
     END IF;

END moveEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : insertAffectedWells
-- Description    : Adds the default affected wells to an event.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
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
PROCEDURE insertAffectedWells(p_event_no NUMBER)
--</EC-DOC>
IS

BEGIN

  INSERT INTO well_deferment_event (event_no, object_id, daytime, end_date)
  select p_event_no,
         w.object_id,
         GREATEST(w.start_date, e.daytime),
         LEAST(nvl(w.end_date, e.end_date), e.end_date)
  from well w,  well_version wv, fcty_deferment_event e
  where

  ecdp_well.IsWellOpen(w.object_id, e.daytime) = 'Y'                            -- ensuring well has ACTIVE_STATUS=OPEN
  AND e.asset_id IN (wv.op_fcty_class_1_id, wv.object_id, wv.op_well_hookup_id)
  AND w.start_date < nvl(e.end_date, w.start_date+1)                            -- obj's start_date has to be before end_date of event
  AND nvl(w.end_date, e.daytime+1) > e.daytime                                  -- obj's end_date has to be after start date of event
  AND w.object_id = wv.object_id
  AND e.daytime >= wv.daytime                                                   -- fetch the correct version from well_version
  AND e.daytime < nvl(wv.end_date, e.daytime+1)                                 -- fetch the correct version from well_version
  AND e.event_no = p_event_no                                                  -- ensuring single record fetched from fcty_def_event

  UNION ALL  -- Wells connected to a deferment group.
  SELECT A.event_no, A.well_id, A.daytime, A.end_date
  FROM (
       SELECT
            p_event_no as event_no,
            dgw.well_id AS well_id,
            GREATEST(dg.start_date, ec_well.start_date(dgw.well_id), e.daytime) AS daytime,
            decode(LEAST(nvl(dg.end_date, ecdp_system_constants.FUTURE_DATE), nvl(ec_well.end_date(dgw.well_id), ecdp_system_constants.FUTURE_DATE), nvl(dg.end_date, ecdp_system_constants.FUTURE_DATE)), ecdp_system_constants.FUTURE_DATE, to_date(NULL), LEAST(nvl(dg.end_date, ecdp_system_constants.FUTURE_DATE), nvl(ec_well.end_date(dgw.well_id), ecdp_system_constants.FUTURE_DATE), nvl(dg.end_date, ecdp_system_constants.FUTURE_DATE))) AS end_date
       FROM deferment_group_well dgw, deferment_group dg, fcty_deferment_event e
       WHERE dgw.object_id = dg.object_id
       AND dg.object_id = e.asset_id
       AND e.event_no = p_event_no
  ) A,
  fcty_deferment_event e
  WHERE
      ecdp_well.IsWellOpen(a.well_id, e.daytime) = 'Y'
      AND a.daytime < nvl(e.end_date, a.daytime+1)                            -- obj's start_date has to be before end_date of event
      AND nvl(a.end_date, e.daytime+1) > e.daytime                            -- obj's end_date has to be after start date of event
      AND e.event_no = p_event_no                                             -- ensuring single record fetched from fcty_def_event

  -- union with objects connected in Object Group Connection
  UNION ALL
  SELECT B.event_no, B.well_id, B.daytime, B.end_date
  FROM (
       SELECT
            p_event_no as event_no,
            ogn.child_obj_id AS well_id,
            GREATEST(og.start_date, ec_well.start_date(ogn.CHILD_OBJ_ID), e.daytime) AS daytime,
            decode(LEAST(nvl(og.end_date, ecdp_system_constants.FUTURE_DATE), nvl(ec_well.end_date(ogn.CHILD_OBJ_ID), ecdp_system_constants.FUTURE_DATE), nvl(og.end_date, ecdp_system_constants.FUTURE_DATE)), ecdp_system_constants.FUTURE_DATE, to_date(NULL), LEAST(nvl(og.end_date, ecdp_system_constants.FUTURE_DATE), nvl(ec_well.end_date(ogn.CHILD_OBJ_ID), ecdp_system_constants.FUTURE_DATE), nvl(og.end_date, ecdp_system_constants.FUTURE_DATE))) AS end_date
         FROM object_group_conn ogn, object_group og, fcty_deferment_event e, well_version wv, well w
         WHERE ogn.object_id = og.object_id
         AND ogn.parent_start_date = og.start_date
         AND ogn.parent_group_type = og.group_type
         AND og.object_id = e.asset_id
         AND e.event_no = p_event_no
         AND ogn.object_class = 'WELL'
         AND og.object_class != 'WELL'
         AND ogn.child_obj_id = wv.object_id
         AND w.start_date < nvl(e.end_date, w.start_date+1)                            -- obj's start_date has to be before end_date of event
         AND nvl(w.end_date, e.daytime+1) > e.daytime                                  -- obj's end_date has to be after start date of event
         AND w.object_id = wv.object_id
         AND ogn.start_date <= e.daytime
         AND nvl(ogn.end_date, e.daytime+1) > e.daytime
         AND e.daytime >= wv.daytime                                                   -- fetch the correct version from well_version
         AND e.daytime < nvl(wv.end_date, e.daytime+1)

  ) B,
  fcty_deferment_event e
  WHERE
      ecdp_well.IsWellOpen(b.well_id, e.daytime) = 'Y'
      AND b.daytime < nvl(e.end_date, b.daytime+1)                            	       -- obj's start_date has to be before end_date of event
      AND nvl(b.end_date, e.daytime+1) > e.daytime                                     -- obj's end_date has to be after start date of event
      AND e.event_no = p_event_no;                                                     -- ensuring single record fetched



END insertAffectedWells;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calculateDeferedGrpVolume
-- Description    : Aggregates the deferred volumes from the affected wells to the event. All phases are
--                  given by ec code GRP_DEF_RATE_TYPE.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : DEFERMENT_WELL_DAY_ALLOC
--
--
--
-- Using functions:
--
-- Configuration
-- required       : The deferment allocation.
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
FUNCTION calculateDeferedGrpVolume(p_event_no NUMBER, p_phase VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS

ln_defered_volume NUMBER := NULL;

BEGIN


  IF p_phase = 'OIL'       THEN
     select sum(DEFERRED_NET_OIL_VOL)  into ln_defered_volume FROM well_day_deferment_alloc wdda, well_deferment_event wde WHERE wde.event_no = p_event_no AND wde.wde_no = wdda.wde_no;
  ELSIF p_phase = 'COND'      THEN
     select sum(DEFERRED_COND_VOL)  into ln_defered_volume FROM well_day_deferment_alloc wdda, well_deferment_event wde WHERE wde.event_no = p_event_no AND wde.wde_no = wdda.wde_no;
  ELSIF p_phase = 'GAS'       THEN
     select sum(DEFERRED_GAS_VOL)  into ln_defered_volume FROM well_day_deferment_alloc wdda, well_deferment_event wde WHERE wde.event_no = p_event_no AND wde.wde_no = wdda.wde_no;
  ELSIF p_phase = 'WATER'     THEN
     select sum(DEFERRED_WATER_VOL)  into ln_defered_volume FROM well_day_deferment_alloc wdda, well_deferment_event wde WHERE wde.event_no = p_event_no AND wde.wde_no = wdda.wde_no;
  ELSIF p_phase = 'DILUENT'   THEN
     select sum(DEFERRED_DILUENT_VOL)  into ln_defered_volume FROM well_day_deferment_alloc wdda, well_deferment_event wde WHERE wde.event_no = p_event_no AND wde.wde_no = wdda.wde_no;
  ELSIF p_phase = 'GAS_LIFT'  THEN
     select sum(DEFERRED_GL_VOL)  into ln_defered_volume FROM well_day_deferment_alloc wdda, well_deferment_event wde WHERE wde.event_no = p_event_no AND wde.wde_no = wdda.wde_no;
  ELSIF p_phase = 'GAS_INJ'   THEN
     select sum(DEFERRED_GAS_INJ_VOL)  into ln_defered_volume FROM well_day_deferment_alloc wdda, well_deferment_event wde WHERE wde.event_no = p_event_no AND wde.wde_no = wdda.wde_no;
  ELSIF p_phase = 'WATER_INJ' THEN
     select sum(DEFERRED_WATER_INJ_VOL)  into ln_defered_volume FROM well_day_deferment_alloc wdda, well_deferment_event wde WHERE wde.event_no = p_event_no AND wde.wde_no = wdda.wde_no;
  ELSIF p_phase = 'STEAM_INJ' THEN
     select sum(DEFERRED_STEAM_INJ_VOL)  into ln_defered_volume FROM well_day_deferment_alloc wdda, well_deferment_event wde WHERE wde.event_no = p_event_no AND wde.wde_no = wdda.wde_no;
  END IF;

  return ln_defered_volume;

END calculateDeferedGrpVolume;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calculateDeferedVolume
-- Description    : Aggregates the deferred volumes from an affected well. All phases are
--                  given by ec code GRP_DEF_RATE_TYPE.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : well_day_deferment_alloc
--
--
--
-- Using functions:
--
-- Configuration
-- required       : The deferment allocation.
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
FUNCTION calculateDeferedVolume(p_wde_no NUMBER, p_phase VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS

  ln_defered_volume NUMBER := NULL;

BEGIN


  IF p_phase = 'OIL'       THEN
     select sum(DEFERRED_NET_OIL_VOL)  into ln_defered_volume from well_day_deferment_alloc wdda
     where wdda.wde_no = p_wde_no;
  ELSIF p_phase = 'COND'      THEN
     select sum(DEFERRED_COND_VOL)  into ln_defered_volume from well_day_deferment_alloc wdda
     where wdda.wde_no = p_wde_no;
  ELSIF p_phase = 'GAS'       THEN
     select sum(DEFERRED_GAS_VOL)  into ln_defered_volume from well_day_deferment_alloc wdda
     where wdda.wde_no = p_wde_no;
  ELSIF p_phase = 'WATER'     THEN
     select sum(DEFERRED_WATER_VOL)  into ln_defered_volume from well_day_deferment_alloc wdda
     where wdda.wde_no = p_wde_no;
  ELSIF p_phase = 'DILUENT'   THEN
     select sum(DEFERRED_DILUENT_VOL)  into ln_defered_volume from well_day_deferment_alloc wdda
     where wdda.wde_no = p_wde_no;
  ELSIF p_phase = 'GAS_LIFT'  THEN
     select sum(DEFERRED_GL_VOL)  into ln_defered_volume from well_day_deferment_alloc wdda
     where wdda.wde_no = p_wde_no;
  ELSIF p_phase = 'GAS_INJ'   THEN
     select sum(DEFERRED_GAS_INJ_VOL)  into ln_defered_volume from well_day_deferment_alloc wdda
     where wdda.wde_no = p_wde_no;
  ELSIF p_phase = 'WATER_INJ' THEN
     select sum(DEFERRED_WATER_INJ_VOL)  into ln_defered_volume from well_day_deferment_alloc wdda
     where wdda.wde_no = p_wde_no;
  ELSIF p_phase = 'STEAM_INJ' THEN
     select sum(DEFERRED_STEAM_INJ_VOL)  into ln_defered_volume from well_day_deferment_alloc wdda
     where wdda.wde_no = p_wde_no;
  END IF;

  return ln_defered_volume;

END calculateDeferedVolume;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calculateDeferedGrpMass
-- Description    : Aggregates the deferred mass from the affected wells to the event. All phases are
--                  given by ec code GRP_DEF_RATE_TYPE.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : DEFERMENT_WELL_DAY_ALLOC
--
--
--
-- Using functions:
--
-- Configuration
-- required       : The deferment allocation.
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
FUNCTION calculateDeferedGrpMass(p_event_no NUMBER, p_phase VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS

ln_defered_mass NUMBER := NULL;

BEGIN

  IF p_phase = 'OIL_MASS' THEN
     select sum(DEFERRED_NET_OIL_MASS)  into ln_defered_mass FROM well_day_deferment_alloc wdda, well_deferment_event wde WHERE wde.event_no = p_event_no AND wde.wde_no = wdda.wde_no;
  ELSIF p_phase = 'COND_MASS'  THEN
     select sum(DEFERRED_COND_MASS)  into ln_defered_mass FROM well_day_deferment_alloc wdda, well_deferment_event wde WHERE wde.event_no = p_event_no AND wde.wde_no = wdda.wde_no;
  ELSIF p_phase = 'GAS_MASS'   THEN
     select sum(DEFERRED_GAS_MASS)  into ln_defered_mass FROM well_day_deferment_alloc wdda, well_deferment_event wde WHERE wde.event_no = p_event_no AND wde.wde_no = wdda.wde_no;
  ELSIF p_phase = 'WATER_MASS' THEN
     select sum(DEFERRED_WATER_MASS)  into ln_defered_mass FROM well_day_deferment_alloc wdda, well_deferment_event wde WHERE wde.event_no = p_event_no AND wde.wde_no = wdda.wde_no;
  END IF;

  return ln_defered_mass;

END calculateDeferedGrpMass;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calculateDeferedMass
-- Description    : Aggregates the deferred mass from an affected well. All phases are
--                  given by ec code GRP_DEF_RATE_TYPE.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : well_day_deferment_alloc
--
--
--
-- Using functions:
--
-- Configuration
-- required       : The deferment allocation.
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
FUNCTION calculateDeferedMass(p_wde_no NUMBER, p_phase VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS

  ln_defered_mass NUMBER := NULL;

BEGIN


  IF p_phase = 'OIL_MASS'  THEN
     select sum(DEFERRED_NET_OIL_MASS)  into ln_defered_mass from well_day_deferment_alloc wdda
     where wdda.wde_no = p_wde_no;
  ELSIF p_phase = 'COND_MASS'  THEN
     select sum(DEFERRED_COND_MASS)  into ln_defered_mass from well_day_deferment_alloc wdda
     where wdda.wde_no = p_wde_no;
  ELSIF p_phase = 'GAS_MASS'  THEN
     select sum(DEFERRED_GAS_MASS)  into ln_defered_mass from well_day_deferment_alloc wdda
     where wdda.wde_no = p_wde_no;
  ELSIF p_phase = 'WATER_MASS' THEN
     select sum(DEFERRED_WATER_MASS)  into ln_defered_mass from well_day_deferment_alloc wdda
     where wdda.wde_no = p_wde_no;
  END IF;

  return ln_defered_mass;

END calculateDeferedMass;




--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calcWellProdLossDay
-- Description    : Aggregates the deferred volumes for an affected well for a given day. Note that
--                  p_daytime is production day.
--
-- Preconditions  : Deferment calculation
-- Postconditions :
--
-- Using tables   : well_day_deferment_alloc
--
--
--
-- Using functions:
--
-- Configuration
-- required       : The deferment allocation.
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcWellProdLossDay(p_object_id VARCHAR2, p_daytime DATE, p_phase VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS

  ln_defered_volume NUMBER := NULL;

BEGIN

  IF p_phase = EcDp_Phase.Oil THEN
     select sum(DEFERRED_NET_OIL_VOL) into ln_defered_volume FROM well_day_deferment_alloc WHERE daytime = p_daytime and object_id = p_object_id;
  ELSIF p_phase = EcDp_Phase.CONDENSATE THEN
     select sum(DEFERRED_COND_VOL) into ln_defered_volume FROM well_day_deferment_alloc WHERE daytime = p_daytime and object_id = p_object_id;
  ELSIF p_phase = 'GAS_INJ'  THEN
     select sum(DEFERRED_GAS_INJ_VOL) into ln_defered_volume FROM well_day_deferment_alloc WHERE daytime = p_daytime and object_id = p_object_id;
  ELSIF p_phase = EcDp_Phase.GAS       THEN
     select sum(DEFERRED_GAS_VOL) into ln_defered_volume FROM well_day_deferment_alloc WHERE daytime = p_daytime and object_id = p_object_id;
  ELSIF p_phase = 'WAT_INJ'  THEN
     select sum(DEFERRED_WATER_INJ_VOL) into ln_defered_volume FROM well_day_deferment_alloc WHERE daytime = p_daytime and object_id = p_object_id;
  ELSIF p_phase = EcDp_Phase.WATER     THEN
     select sum(DEFERRED_WATER_VOL) into ln_defered_volume FROM well_day_deferment_alloc WHERE daytime = p_daytime and object_id = p_object_id;
  ELSIF p_phase = 'DILUENT'   THEN
     select sum(DEFERRED_DILUENT_VOL) into ln_defered_volume FROM well_day_deferment_alloc WHERE daytime = p_daytime and object_id = p_object_id;
  ELSIF p_phase = 'GAS_LIFT'  THEN
     select sum(DEFERRED_GL_VOL) into ln_defered_volume FROM well_day_deferment_alloc WHERE daytime = p_daytime and object_id = p_object_id;
  ELSIF p_phase = Ecdp_Phase.STEAM THEN
     select sum(DEFERRED_STEAM_INJ_VOL) into ln_defered_volume FROM well_day_deferment_alloc WHERE daytime = p_daytime and object_id = p_object_id;
  END IF;

  return nvl(ln_defered_volume,0);

END calcWellProdLossDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calcWellProdLossDayMass
-- Description    : Aggregates the deferred masses for an affected well for a given day. Note that
--                  p_daytime is production day.
--
-- Preconditions  : Deferment calculation
-- Postconditions :
--
-- Using tables   : well_day_deferment_alloc
--
--
--
-- Using functions:
--
-- Configuration
-- required       : The deferment allocation.
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcWellProdLossDayMass(p_object_id VARCHAR2, p_daytime DATE, p_phase VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS

  ln_defered_mass NUMBER := NULL;

BEGIN

  IF p_phase = EcDp_Phase.Oil_MASS THEN
     select sum(DEFERRED_NET_OIL_MASS) into ln_defered_mass FROM well_day_deferment_alloc WHERE daytime = p_daytime and object_id = p_object_id;
  ELSIF p_phase = EcDp_Phase.CONDENSATE_MASS THEN
     select sum(DEFERRED_COND_MASS) into ln_defered_mass FROM well_day_deferment_alloc WHERE daytime = p_daytime and object_id = p_object_id;
  ELSIF p_phase = EcDp_Phase.GAS_MASS THEN
    select sum(DEFERRED_GAS_MASS) into ln_defered_mass FROM well_day_deferment_alloc WHERE daytime = p_daytime and object_id = p_object_id;
  ELSIF p_phase = EcDp_Phase.WATER_MASS THEN
    select sum(DEFERRED_WATER_MASS) into ln_defered_mass FROM well_day_deferment_alloc WHERE daytime = p_daytime and object_id = p_object_id;
  END IF;

  return nvl(ln_defered_mass,0);

END calcWellProdLossDayMass;


--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- Procedure      : moveShortToLong
-- Description    : Moves SHORT deferment events to LONG when the system attribute MAX_SHORT_DAYS are exceeded.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : fcty_deferment_event
--
--
--
-- Using functions:
--
-- Configuration
-- required       : The system attribute MAX_SHORT_DAYS has to be defined.
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------------
PROCEDURE moveShortToLong
--</EC-DOC>
IS

-- find all SHORT events having been deferred for more than X days. Those will be set to LONG.
CURSOR cur_events (p_daytime DATE) IS
SELECT *
FROM fcty_deferment_event
WHERE current_def_type = 'SHORT'
AND end_date IS NULL
AND daytime < p_daytime
FOR UPDATE
;

BEGIN

  FOR thisrow IN cur_events(ecdp_date_time.getCurrentSysdate() - ec_ctrl_system_attribute.attribute_value(ecdp_date_time.getCurrentSysdate(), 'MAX_SHORT_DAYS', '<=')) LOOP

     UPDATE fcty_deferment_event
     SET current_def_type = 'LONG'
     WHERE CURRENT OF cur_events;

  END LOOP;

END moveShortToLong;

--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- Procedure      : deleteCalcData
-- Description    : This procedure deletes any calculated data in the well_day_deferment_alloc table on given wde_no.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : well_day_deferment_alloc
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
PROCEDURE deleteCalcData(p_wde_no NUMBER)
--</EC-DOC>
IS

BEGIN

  DELETE well_day_deferment_alloc WHERE wde_no = p_wde_no;

END deleteCalcData;

--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- Procedure      : deleteCalcDataOutsideTimeSpan
-- Description    : This procedure make sure that we have no calculated date in well_day_deferment_alloc
--                  outside wde_no's time span.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : well_day_deferment_alloc
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
PROCEDURE deleteCalcDataOutsideTimeSpan(p_wde_no NUMBER,p_object_id VARCHAR2,p_new_daytime DATE, p_new_end_date DATE, p_old_daytime DATE, p_old_end_date DATE)
--</EC-DOC>
IS

ld_prod_day DATE;

BEGIN
     IF p_new_daytime != p_old_daytime THEN
        --find prod day for well
        ld_prod_day := ecdp_productionday.getProductionDay('WELL',p_object_id,p_new_daytime);

        --delete all in alloc table before p_new_daytime
        DELETE well_day_deferment_alloc WHERE wde_no = p_wde_no AND daytime < ld_prod_day;
     END IF;

      IF p_old_end_date IS NULL AND p_new_end_date IS NOT NULL THEN
        --find prod day for well
        ld_prod_day := ecdp_productionday.getProductionDay('WELL',p_object_id,p_new_end_date);

        --delete all in alloc table after new end date
        DELETE well_day_deferment_alloc WHERE wde_no = p_wde_no AND daytime > ld_prod_day;
     END IF;

     IF (p_old_end_date IS NOT NULL) AND (p_new_end_date IS NOT NULL) AND (p_new_end_date != p_old_end_date) THEN
        --find prod day for well
        ld_prod_day := ecdp_productionday.getProductionDay('WELL',p_object_id,p_new_end_date);

        --delete all in alloc table after new end date
        DELETE well_day_deferment_alloc WHERE wde_no = p_wde_no AND daytime > ld_prod_day;
     END IF;

END deleteCalcDataOutsideTimeSpan;

--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- Procedure      : updateEndDateForWellDeferment
-- Description    : Update end date if it is null or equal to parent old value
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
---------------------------------------------------------------------------------------------------------
PROCEDURE updateEndDateForWellDeferment(p_event_no NUMBER,p_end_date DATE, p_parent_old_end_date DATE)
--</EC-DOC>
IS

BEGIN

   UPDATE well_deferment_event w
   SET w.end_date = p_end_date
   WHERE w.event_no = p_event_no
   AND  (w.end_date is null
   OR    (p_parent_old_end_date IS NOT NULL AND w.end_date = p_parent_old_end_date))
   AND  Nvl(p_end_date, w.daytime + 1) > w.daytime; -- end_date must be > than daytime



END updateEndDateForWellDeferment;

--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- Procedure      : setParentEndDate
-- Description    : Update end date of parent to max(child end_date) if all end_date is not null
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : well_deferment_event, fcty_deferment_event
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
PROCEDURE setParentEndDate(p_event_no NUMBER)
--</EC-DOC>
IS

BEGIN


   UPDATE fcty_deferment_event f
    SET f.end_date = (SELECT MAX(end_date)
                                 FROM well_deferment_event wde
                                WHERE wde.EVENT_NO = p_event_no
                                  AND NOT EXISTS
                                (SELECT 1
                                         FROM well_deferment_event wd
                                        WHERE wd.EVENT_NO = p_event_no
                                          AND wd.END_DATE is NULL))
    WHERE f.event_no = p_event_no
    AND f.end_date is NULL;


END setParentEndDate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- Procedure      : updateDateForWellDefermnt
-- Description    : Update start date and end date if it is null or equal to parent old value
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
---------------------------------------------------------------------------------------------------------

PROCEDURE updateDateForWellDefermnt(p_event_no NUMBER,p_start_date DATE, p_end_date DATE, p_parent_old_start_date DATE, p_parent_old_end_date DATE)
--</EC-DOC>
IS

BEGIN

   UPDATE well_deferment_event w
   SET w.daytime = p_start_date
   ,w.end_date = p_end_date
   WHERE w.event_no = p_event_no
   AND w.daytime = p_parent_old_start_date
   AND (w.end_date is null
   OR (p_parent_old_end_date IS NOT NULL AND w.end_date = p_parent_old_end_date))
   AND (NVL(p_start_date, w.end_date - 1) < w.end_date
   OR NVL(p_end_date, w.daytime + 1) > w.daytime);

END updateDateForWellDefermnt;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : countChildEvent
-- Description    : Count child events exist for the parent event id.
--
--
-- Preconditions  :
-- Postconditions : .
--
-- Using tables   : well_deferment_event
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
FUNCTION countChildEvent(p_event_no NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

  CURSOR c_child_event  IS
    SELECT count(object_id) totalrecord
    FROM well_deferment_event
    WHERE event_no = p_event_no;


 ln_child_record NUMBER;

BEGIN
   ln_child_record := 0;

  FOR cur_child_event IN c_child_event LOOP
    ln_child_record := cur_child_event.totalrecord ;
  END LOOP;

  return ln_child_record;

END countChildEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : deleteChildEvent
-- Description    : Delete child events. Child table is WELL_DEFERMENT_EVENT, parent table is FCTY_DEFERMENT_EVENT.
--
--
-- Preconditions  : All child records related to the event no will be deleted first.
-- Postconditions : Parent event record will be deleted finally.
--
-- Using tables   : well_deferment_event
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
PROCEDURE deleteChildEvent(p_event_no NUMBER)
--</EC-DOC>
IS

 BEGIN

  DELETE FROM well_deferment_event where event_no = p_event_no;

  END deleteChildEvent;

--<EC-DOC>

END EcDp_Deferment_Event;