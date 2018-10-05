CREATE OR REPLACE PACKAGE BODY EcDp_Objects_Deferment_Event IS
/***************************************************************
** Package:                EcDp_Objects_Deferment_Event
**
** Revision :              $Revision: 1.22 $
**
** Purpose:
**
** Documentation:          www.energy-components.no
**
** Modification history:
**
** Date:    Whom:      Change description:
** -------- -----      --------------------------------------------
** 20050310 SRA        Initial version based onf EcDp_Objects_Event
** 20050330 SRA        Deferment has been removed from groups model. SQLs refering to group model rewritten.
** 20050422 kaurrnar   Added new function calcWellLossDay.
**		       Extended logic to handle new column for CONDENSATE for calcLossByDayFromChildren, calcLossByDay function and
**		       Aggregate_Volume_To_Parent procedure
** 20050427 DN         Bug in parameter order in call to EcDp_Groups.
** 20040603 ROV        Tracker #1822: Renamed calcWellLossDay -> calcWellProdLossDay and modified implementation due to error in business logic
** 20050617 DN         TD4022: Rewrote odd cursor in calcWellProdLossDay.
** 20051025 Darren     TI#2982 Rewrite function calcWellProdLossDay to solve performance problem when theoretical calculation method = potential-deferred
** 20060118 DN         Procedure Aggregate_Volume_To_Parent: Added lock testing.
** 20060210 DN         TI3308: Performance improvement for well class in function calcLossByDay.
** 20070906 rajarsar   ECPD-6264 Added new function calcWellProdLossDayMass
** 20080313 ismaiime   ECDP-6128 Enhancement to function calcEventDurationDay(). Call production offset before calculate duration.
** 20080401 rajarsar   ECPD-7844 Updated calcLossByDay to replace getNumHours with 24
** 24.06.2011 sharawan  ECPD-15883 Modified Aggregate_Volume_To_Parent to do simple sum up event rates from the well rates.
** 22.08.2016 shindani  ECPD-38708 Company name references removed.
***************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- FUNCTION calcEventDurationDay
---------------------------------------------------------------------------------------------------------
FUNCTION calcEventDurationDay(p_event_start_daytime DATE,
                              p_event_end_daytime   DATE,
                              p_day                 DATE,
                              p_object_id VARCHAR2) RETURN NUMBER
--</EC-DOC>
IS
  ln_retval NUMBER;
  ld_prod_day_start DATE;

BEGIN

  ld_prod_day_start := p_day + EcDp_ProductionDay.getProductionDayOffset(NULL,p_object_id,p_day)/24;

  ln_retval := (LEAST(Nvl(p_event_end_daytime, ld_prod_day_start+1), ld_prod_day_start+1) - GREATEST(p_event_start_daytime, ld_prod_day_start) ) * 24;

  RETURN GREATEST(ln_retval,0);  -- Negative duration not allowed

END calcEventDurationDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- FUNCTION calcLossByDayFromChilds
---------------------------------------------------------------------------------------------------------
FUNCTION calcLossByDayFromChildren(p_event_id VARCHAR2,
                                   p_daytime  DATE,
                                   p_phase    VARCHAR2,
                                   p_prod_inj   VARCHAR2) RETURN NUMBER
--</EC-DOC>
IS
CURSOR c_Objects_Deferment_Event IS
SELECT
  SUM(
    Decode(SubStr(p_prod_inj,1,1)
     ,'P', Decode(p_phase
        ,EcDp_Phase.OIL, o.oil_prod_loss
        ,EcDp_Phase.GAS, o.gas_prod_loss
        ,EcDp_Phase.CONDENSATE, o.cond_prod_loss
        ,EcDp_Phase.WATER, o.water_prod_loss
        )
     ,'I', Decode(p_phase
        ,EcDp_Phase.GAS, o.gas_inj_loss
        ,EcDp_Phase.WATER, o.water_inj_loss
        )
     )
    * calcEventDurationDay(o.daytime, o.end_date, o.production_day, o.object_id)
    /24) day_loss
FROM system_days x, Objects_Deferment_Event o
WHERE o.parent_event_id = p_event_id
AND x.daytime = EcDp_Objects_Deferment_Event.getProductionDay(o.event_id, o.event_type, o.object_id,o.object_type, p_daytime);

ln_return NUMBER;

BEGIN
  FOR mycur IN c_Objects_Deferment_Event LOOP
    ln_return := mycur.day_loss;
  END LOOP;

  RETURN ln_return;
END calcLossByDayFromChildren;

--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- FUNCTION calcLossByDay
---------------------------------------------------------------------------------------------------------
FUNCTION calcLossByDay(p_event_id VARCHAR2,
                       p_daytime  DATE,
                       p_phase    VARCHAR2,
                       p_prod_inj VARCHAR2) RETURN NUMBER
--</EC-DOC>
IS
  ln_retval        NUMBER;
  ln_durationfrac  NUMBER;
  lr_event         Objects_Deferment_Event%ROWTYPE;
  ld_daytime       DATE;

BEGIN

  lr_event := ec_Objects_Deferment_Event.row_by_pk(p_event_id);

  IF lr_event.end_date IS NULL AND lr_event.object_type <> 'WELL' THEN
    -- Open-ended parent events must always be calculated from children's rates
    ln_retval := calcLossByDayFromChildren(p_event_id, p_daytime, p_phase, p_prod_inj);
  ELSE
     -- Find how big part of the total event this day and taking into account production day start
     -- replaced getNumHours with 24
    ld_daytime := p_daytime +
                  (getProductionDayOffset(lr_event.event_id, lr_event.event_type, lr_event.object_id, lr_event.object_type, p_daytime)
                                /24);

    IF(lr_event.end_date IS NULL) THEN
      lr_event.end_date := ld_daytime + 1;
    END IF;

    IF (lr_event.daytime > ld_daytime + 1) OR (lr_event.end_date <= ld_daytime) OR (lr_event.end_date = lr_event.daytime) THEN
      ln_durationfrac := 0;
    ELSE
      ln_durationfrac := Least(lr_event.end_date, ld_daytime+1) - Greatest(lr_event.daytime, ld_daytime);
    END IF;

    -- Handle different combinations of injectors/producers and phases
    IF SubStr(p_prod_inj,1,1) = 'P' AND p_phase = EcDp_Phase.Oil THEN

        ln_retval := lr_event.oil_prod_loss * ln_durationfrac;

    ELSIF SubStr(p_prod_inj,1,1) = 'P' AND p_phase = EcDp_Phase.Gas THEN

        ln_retval := lr_event.gas_prod_loss * ln_durationfrac;

    ELSIF SubStr(p_prod_inj,1,1) = 'P' AND p_phase = EcDp_Phase.Condensate THEN

        ln_retval := lr_event.cond_prod_loss * ln_durationfrac;

    ELSIF SubStr(p_prod_inj,1,1) = 'P' AND p_phase = EcDp_Phase.Water THEN

        ln_retval := lr_event.water_prod_loss * ln_durationfrac;

    ELSIF SubStr(p_prod_inj,1,1) = 'I' AND p_phase = EcDp_Phase.Gas THEN

        ln_retval := lr_event.gas_inj_loss * ln_durationfrac;

    ELSIF SubStr(p_prod_inj,1,1) = 'I' AND p_phase = EcDp_Phase.Water THEN

        ln_retval := lr_event.water_inj_loss * ln_durationfrac;

    END IF;
    --
  END IF;

  RETURN ln_retval;
END calcLossByDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- PROCEDURE Create_Objects_Event_Detail
---------------------------------------------------------------------------------------------------------
PROCEDURE Create_Objects_Event_Detail (p_event_id VARCHAR2,
                                       p_group_type VARCHAR2)
--</EC-DOC>
IS

-- get objects that are connected via groups
CURSOR cur_conn_objects(cp_daytime DATE, cp_end_date DATE, cp_parent_object_id VARCHAR2, cp_parent_object_type VARCHAR2) IS
SELECT g.object_type, g.object_Id
FROM DEFERMENT_GROUPS g
WHERE g.parent_group_type = p_group_type
AND g.parent_object_type = cp_parent_object_type
AND g.parent_object_id = cp_parent_object_id
AND g.object_type='WELL'
AND cp_daytime BETWEEN g.daytime AND nvl(g.end_date, cp_daytime)
MINUS -- deduct objects that are already part of this event
SELECT o.object_type, o.object_Id
FROM Objects_Deferment_Event o
WHERE o.object_type = 'WELL'
AND o.parent_event_id = p_event_id
;

CURSOR cur_Objects_Deferment_Event IS
SELECT *
FROM Objects_Deferment_Event
WHERE event_id = p_event_id;

ld_daytime DATE;
ld_end_date DATE;


BEGIN
   FOR thisevent IN cur_Objects_Deferment_Event LOOP
      FOR thisobject IN cur_conn_objects(thisevent.daytime, thisevent.end_date, thisevent.object_id, thisevent.object_type) LOOP
          -- set correct start date for each individual well.
          SELECT max(o.end_date)
          INTO ld_daytime
          FROM Objects_Deferment_Event o
          WHERE o.object_id = thisobject.object_id
          AND o.parent_event_id = thisevent.event_id  -- New due to overlapping events
          AND thisevent.daytime BETWEEN o.daytime AND o.end_date;

          IF ld_daytime IS NULL THEN
             ld_daytime := thisevent.daytime;
          END IF;

          -- set correct end date for each individual well. Normally NULL, but if future events exists end date must be set
          SELECT MIN(o.daytime)
          INTO ld_end_date
          FROM Objects_Deferment_Event o
          WHERE o.object_id = thisobject.object_id
          AND o.parent_event_id = thisevent.event_id  -- New due to overlapping events
          AND o.daytime > thisevent.daytime;

          IF ld_end_date IS NULL THEN
             ld_end_date := thisevent.end_date; -- parent_end_Date
          ELSIF ld_end_date > thisevent.end_Date THEN
             ld_end_date := thisevent.end_date; -- If future start date is larger that parent end date, use parent end date
          END IF;

          -- Lock test

          EcDp_Production_Lock.validateProdDayPeriodForLock('INSERTING',
                                       ld_daytime,
                                       ld_end_date,
                                       thisobject.object_id,
                                       thisobject.object_type,
                                       'EcDp_Objects_Deferment_event.Create_objects_event_detail: can not create in locked period');

          INSERT INTO Objects_Deferment_Event(daytime, end_date, event_type, object_id, object_type, parent_event_id)
          VALUES (ld_daytime, ld_end_date, thisevent.event_type, thisobject.object_id, thisobject.object_type, p_event_id);

      END LOOP;
   END LOOP;
END Create_Objects_Event_Detail;

--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- PROCEDURE Aggregate_Volume_To_Parent
---------------------------------------------------------------------------------------------------------
PROCEDURE Aggregate_Volume_To_Parent(p_event_id VARCHAR2,
                                     p_desimal NUMBER DEFAULT 0)
--</EC-DOC>
IS

-- daily loss rate * duration is lost volume for the well. end_date must be set.
CURSOR cur_childs (cp_event_type VARCHAR2) IS
SELECT nvl(oil_prod_loss,0) oil_prod_loss,
       nvl(gas_prod_loss,0) gas_prod_loss,
       nvl(water_prod_loss,0) water_prod_loss,
       nvl(cond_prod_loss,0) cond_prod_loss,
       nvl(gas_inj_loss,0) gas_inj_loss,
       nvl(water_inj_loss,0) water_inj_loss
FROM Objects_Deferment_Event
WHERE ((parent_event_id = p_event_id)
     OR
     (object_type = 'WELL' and event_id = p_event_id)  /* handle single event */
    )
AND event_type = cp_event_type
AND end_date IS NOT NULL
;

    CURSOR c_updateable_child(cp_parent_event_id VARCHAR2, cp_event_type VARCHAR2) IS
    SELECT *
    FROM Objects_Deferment_Event
    WHERE parent_event_id = cp_parent_event_id
    AND event_type = cp_event_type
    AND end_date IS NULL;

ln_total_vol_oil       NUMBER := 0;
ln_total_vol_gas       NUMBER := 0;
ln_total_vol_water     NUMBER := 0;
ln_total_vol_cond      NUMBER := 0;
ln_total_vol_gas_inj   NUMBER := 0;
ln_total_vol_water_inj NUMBER := 0;

lv_event_type VARCHAR2(16);
ld_end_date DATE;
lr_event    Objects_Deferment_Event%ROWTYPE;

BEGIN
   -- parent and childs have always the same event_type.
   lv_event_type := ec_Objects_Deferment_Event.event_type(p_event_id);
   ld_end_date := ec_Objects_Deferment_Event.end_date(p_event_id);

   FOR cur_rec IN c_updateable_child(p_event_id, lv_event_type) LOOP

      EcDp_Production_Lock.validateProdDayPeriodForLock('UPDATING',
                                       cur_rec.daytime,
                                       cur_rec.end_date,
                                       cur_rec.object_id,
                                       cur_rec.object_type,
                                       'EcDp_Objects_Event_Raw.CheckAndAggregate: Cannot do this for child event in a locked period.');
   END LOOP;

   -- set parent end date to childs that does not have an end date
   UPDATE Objects_Deferment_Event o
   SET o.end_date = ld_end_date
   WHERE o.parent_event_id = p_event_id
   AND o.event_type = lv_event_type
   AND o.end_date IS NULL;

   IF ld_end_date IS NOT NULL THEN

      FOR thisrow IN cur_childs(lv_event_type) LOOP
          ln_total_vol_oil := ln_total_vol_oil + thisrow.oil_prod_loss;
          ln_total_vol_gas := ln_total_vol_gas + thisrow.gas_prod_loss;
          ln_total_vol_water := ln_total_vol_water + thisrow.water_prod_loss;
          ln_total_vol_cond := ln_total_vol_cond + thisrow.cond_prod_loss;
          ln_total_vol_gas_inj := ln_total_vol_gas_inj + thisrow.gas_inj_loss;
          ln_total_vol_water_inj := ln_total_vol_water_inj + thisrow.water_inj_loss;
      END LOOP;

      lr_event := EC_Objects_Deferment_Event.row_by_pk(p_event_id);

      IF (ln_total_vol_oil       IS NOT NULL) OR
         (ln_total_vol_gas       IS NOT NULL) OR
         (ln_total_vol_water     IS NOT NULL) OR
         (ln_total_vol_cond      IS NOT NULL) OR
         (ln_total_vol_gas_inj   IS NOT NULL) OR
         (ln_total_vol_water_inj IS NOT NULL)

      THEN

         -- Lock test check if parent event overlaps with locked period
/*
         EcDp_Production_Lock.validateProdDayPeriodForLock('UPDATING',
                                       lr_event.daytime,
                                       lr_event.end_date,
                                       lr_event.object_id,
                                       lr_event.object_type,
                                       'EcDp_Objects_Deferment_event.Aggregate_Volume_To_Parent: can not aggregate in locked period');

*/
         -- Update parent record, set group loss as sum loss of childs
         UPDATE objects_deferment_event
         SET grp_oil_prod_loss   = Nvl(Round(ln_total_vol_oil,p_desimal)  , grp_oil_prod_loss),
             grp_gas_prod_loss   = Nvl(Round(ln_total_vol_gas,p_desimal)  , grp_gas_prod_loss),
             grp_water_prod_loss = Nvl(Round(ln_total_vol_water,p_desimal)  , grp_water_prod_loss),
             grp_cond_prod_loss  = Nvl(Round(ln_total_vol_cond,p_desimal)  , grp_cond_prod_loss),
             grp_gas_inj_loss    = Nvl(Round(ln_total_vol_gas_inj,p_desimal)  , grp_gas_inj_loss),
             grp_water_inj_loss  = Nvl(Round(ln_total_vol_water_inj,p_desimal)  , grp_water_inj_loss)
         WHERE event_id = p_event_id;

      END IF;

   ELSE
      RAISE_APPLICATION_ERROR(-20000,'End date/time for parent event must be set.');
   END IF;
END Aggregate_Volume_To_Parent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- PROCEDURE Copy_Deferred_To_Idle
---------------------------------------------------------------------------------------------------------
PROCEDURE Copy_Deferred_To_Idle(p_from_event_type VARCHAR2,
                                p_to_event_type VARCHAR2,
                                p_daytime DATE)
--</EC-DOC>
IS

-- find all events having been deferred for more than X days. Those will be set to Idle.
CURSOR cur_events IS
SELECT *
FROM Objects_Deferment_Event
WHERE event_type = p_from_event_type
AND end_date IS NULL
AND p_daytime >= daytime + ec_ctrl_system_attribute.attribute_value(p_daytime, 'DAYS_IDLE_WELL', '<=')
;

BEGIN

  FOR thisrow IN cur_events LOOP

     -- close event_type=p_from_event_type
     UPDATE Objects_Deferment_Event
     SET end_date = p_daytime
     WHERE event_type = p_from_event_type
     AND event_id = thisrow.event_id;

     -- open new event where event_type=p_to_event_type
     INSERT INTO Objects_Deferment_Event(daytime, event_type, object_id, object_type, linked_event_id)
     VALUES (p_daytime, p_to_event_type, thisrow.object_id, thisrow.object_type, thisrow.event_id);

  END LOOP;

END Copy_Deferred_To_Idle;


--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- PROCEDURE Create_And_Link_Idle_Event
---------------------------------------------------------------------------------------------------------
PROCEDURE Create_And_Link_Idle_Event(p_from_event_type VARCHAR2,
                                     p_to_event_type VARCHAR2,
                                     p_event_id VARCHAR2)
--</EC-DOC>
IS

ld_end_date Objects_Deferment_Event.end_date%TYPE;

-- find event with given event_id.
CURSOR cur_events IS
SELECT *
FROM Objects_Deferment_Event
WHERE event_type = p_from_event_type
AND event_id = p_event_id;

BEGIN
  -- Get current END_DATE
  ld_end_date:=ec_Objects_Deferment_Event.end_date(p_event_id);
  IF ld_end_date IS NULL THEN
    -- Give an error message
      RAISE_APPLICATION_ERROR(-20000,'End date/time for parent event must be set.');
  END IF;

  FOR thisrow IN cur_events LOOP

     -- Lock test

     EcDp_Production_Lock.validateProdDayPeriodForLock('INSERTING',
                                       ld_end_date,
                                       NULL,
                                       thisrow.object_id,
                                       thisrow.object_type,
                                       'EcDp_Objects_Deferment_event.Create_And_Link_Idle_Event: can not do this for a locked period');

     -- open new event where event_type=p_to_event_type. The new event should start when the existing event ends.
     INSERT INTO Objects_Deferment_Event(daytime, event_type, object_id, object_type, linked_event_id)
     VALUES (ld_end_date, p_to_event_type, thisrow.object_id, thisrow.object_type, thisrow.event_id);

  END LOOP;
  Aggregate_Volume_To_Parent(p_event_id);

END Create_And_Link_Idle_Event;


--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- FUNCTION getProductionDay
---------------------------------------------------------------------------------------------------------
FUNCTION getProductionDayOffset(
                          p_event_id    VARCHAR2,
                          p_event_type  VARCHAR2,
                          p_object_id   VARCHAR2,
                          p_object_type VARCHAR2,
                          p_daytime     DATE) RETURN NUMBER
--</EC-DOC>
IS


BEGIN


   RETURN EcDp_ProductionDay.getProductionDayOffset(p_object_type,p_object_id,p_daytime);

   -- removed fallback logic here, handled by EcDp_ProductionDay



END getProductionDayOffset;



--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- FUNCTION getProductionDay
---------------------------------------------------------------------------------------------------------
FUNCTION getProductionDay(
                          p_event_id    VARCHAR2,
                          p_event_type  VARCHAR2,
                          p_object_id   VARCHAR2,
                          p_object_type VARCHAR2,
                          p_daytime     DATE) RETURN DATE
--</EC-DOC>
IS



  lv2_facility     objects.object_id%TYPE;
  ld_prod_day           DATE;
  lv2_offset       VARCHAR2(8);
  ln_day_offset    NUMBER;

BEGIN

   RETURN ecdp_productionday.getproductionday(p_object_type, p_object_id, p_daytime);

   -- Removed fallback logic handled by ecdp_productionday



END getProductionDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- FUNCTION calcWellProdLossDay
---------------------------------------------------------------------------------------------------------
FUNCTION calcWellProdLossDay(
			p_object_id VARCHAR2,
			p_daytime   DATE,
			p_phase     VARCHAR2
			)
RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_objects_deferment_event (cp_object_id VARCHAR2, cp_daytime DATE) IS
SELECT event_id,
       daytime,
       Nvl(end_date, cp_daytime+1) end_date,
       oil_prod_loss,
       gas_prod_loss,
       cond_prod_loss,
       water_prod_loss
FROM objects_deferment_event o
WHERE o.daytime < cp_daytime + 1
AND nvl(o.end_date, cp_daytime + 1) > cp_daytime
AND o.object_type = 'WELL'
AND o.object_id = cp_object_id;

ln_return	NUMBER;
ln_loss		NUMBER;
lv2_fcty_id     production_facility.object_id%TYPE;
ld_daytime      DATE;
ln_durationfrac NUMBER;

BEGIN

  ln_return := 0;

  lv2_fcty_id := ec_well_version.op_fcty_class_1_id(p_object_id, p_daytime, '<=');
  -- Calculate start time of production day
  ld_daytime := p_daytime + (EcDp_ProductionDay.getProductionDayOffset('FCTY_CLASS_1',lv2_fcty_id, p_daytime)/24); -- this is also true if 23 or 25 hours a day.

  FOR mycur IN c_objects_deferment_event(p_object_id, ld_daytime) LOOP

       IF (mycur.daytime > ld_daytime + 1)
       OR (mycur.end_date <= ld_daytime)
       OR (mycur.end_date = mycur.daytime) THEN
          ln_durationfrac := 0;
       ELSE
          ln_durationfrac := Least(mycur.end_date, ld_daytime+1) - Greatest(mycur.daytime, ld_daytime);
       END IF;

       -- Handle different combinations of injectors/producers and phases
       IF p_phase = EcDp_Phase.Oil THEN
          ln_loss := mycur.oil_prod_loss * ln_durationfrac;
       ELSIF p_phase = EcDp_Phase.Gas THEN
          ln_loss := mycur.gas_prod_loss * ln_durationfrac;
       ELSIF p_phase = EcDp_Phase.Condensate THEN
          ln_loss := mycur.cond_prod_loss * ln_durationfrac;
       ELSIF p_phase = EcDp_Phase.Water THEN
          ln_loss := mycur.water_prod_loss * ln_durationfrac;
       END IF;

       ln_return := nvl(ln_loss,0) + ln_return;

  END LOOP;

  RETURN ln_return;

END calcWellProdLossDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- FUNCTION calcWellProdLossDayMass
---------------------------------------------------------------------------------------------------------
FUNCTION calcWellProdLossDayMass(
			p_object_id VARCHAR2,
			p_daytime   DATE,
			p_phase     VARCHAR2
			)
RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_objects_deferment_event (cp_object_id VARCHAR2, cp_daytime DATE) IS
SELECT event_id,
       daytime,
       Nvl(end_date, cp_daytime+1) end_date,
       oil_prod_loss_mass,
       gas_prod_loss_mass,
       cond_prod_loss_mass,
       water_prod_loss_mass
FROM objects_deferment_event o
WHERE o.daytime < cp_daytime + 1
AND nvl(o.end_date, cp_daytime + 1) > cp_daytime
AND o.object_type = 'WELL'
AND o.object_id = cp_object_id;

ln_return	NUMBER;
ln_loss		NUMBER;
lv2_fcty_id     production_facility.object_id%TYPE;
ld_daytime      DATE;
ln_durationfrac NUMBER;

BEGIN

  ln_return := 0;

  lv2_fcty_id := ec_well_version.op_fcty_class_1_id(p_object_id, p_daytime, '<=');
  -- Calculate start time of production day
  ld_daytime := p_daytime + (EcDp_ProductionDay.getProductionDayOffset('FCTY_CLASS_1',lv2_fcty_id, p_daytime)/24); -- this is also true if 23 or 25 hours a day.

  FOR mycur IN c_objects_deferment_event(p_object_id, ld_daytime) LOOP

       IF (mycur.daytime > ld_daytime + 1)
       OR (mycur.end_date <= ld_daytime)
       OR (mycur.end_date = mycur.daytime) THEN
          ln_durationfrac := 0;
       ELSE
          ln_durationfrac := Least(mycur.end_date, ld_daytime+1) - Greatest(mycur.daytime, ld_daytime);
       END IF;

       -- Handle different combinations of injectors/producers and phases
       IF p_phase = EcDp_Phase.Oil_MASS THEN
          ln_loss := mycur.oil_prod_loss_mass * ln_durationfrac;
       ELSIF p_phase = EcDp_Phase.Gas_MASS THEN
          ln_loss := mycur.gas_prod_loss_mass * ln_durationfrac;
       ELSIF p_phase = EcDp_Phase.Condensate_MASS THEN
          ln_loss := mycur.cond_prod_loss_mass * ln_durationfrac;
       ELSIF p_phase = EcDp_Phase.Water_MASS THEN
          ln_loss := mycur.water_prod_loss_mass * ln_durationfrac;
       END IF;

       ln_return := nvl(ln_loss,0) + ln_return;

  END LOOP;

  RETURN ln_return;

END calcWellProdLossDayMass;


END EcDp_Objects_Deferment_Event;