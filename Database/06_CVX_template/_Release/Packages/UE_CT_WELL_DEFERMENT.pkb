create or replace PACKAGE BODY UE_CT_WELL_DEFERMENT IS
/***************************************************************
** Package:                UE_WELL_DEFERMENT
**
** Revision :              $Revision: 1.18.2.2 $
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
**               Extended logic to handle new column for CONDENSATE for calcLossByDayFromChildren, calcLossByDay function and
**               Aggregate_Volume_To_Parent procedure
** 20050427 DN         Bug in parameter order in call to EcDp_Groups.
** 20040603 ROV        Tracker #1822: Renamed calcWellLossDay -> calcWellProdLossDay and modified implementation due to error in business logic
** 20050617 DN         TD4022: Rewrote odd cursor in calcWellProdLossDay.
** 20051025 Darren     TI#2982 Rewrite function calcWellProdLossDay to solve performance problem when theoretical calculation method = potential-deferred
** 20060118 DN         Procedure Aggregate_Volume_To_Parent: Added lock testing.
** 20060210 DN         TI3308: Performance improvement for well class in function calcLossByDay.
** 20070906 rajarsar   ECPD-6264 Added new function calcWellProdLossDayMass
** 20080313 ismaiime   ECDP-7810 Enhancement to function calcEventDurationDay(). Call production offset before calculate duration.
** 20080507 HNKO      Changed the package to point to the new deferment table well_equip_downtime in 9.3
** 20160524 SRXT      Changed the package to point to the new deferment table well_deferment in 11.1 and added water loss rate
***************************************************************/
--<EC-DOC>
FUNCTION calcLossByDayFromChildren(p_event_no VARCHAR2,
                                   p_start_date  DATE,
                                   p_daytime DATE,
                                   p_phase    VARCHAR2,
                                   p_prod_inj   VARCHAR2) RETURN NUMBER
--</EC-DOC>
IS
CURSOR c_Objects_Deferment_Event IS
SELECT
  SUM(
    Decode(SubStr(p_prod_inj,1,1),'P', Decode(p_phase,EcDp_Phase.OIL, o.oil_loss_rate,EcDp_Phase.GAS, o.gas_loss_rate,EcDp_Phase.CONDENSATE, o.cond_loss_rate)
     ,'I', Decode(p_phase,EcDp_Phase.GAS, o.gas_inj_loss_rate,EcDp_Phase.WATER, o.water_inj_loss_rate))
    * EcDp_Objects_Deferment_Event.calcEventDurationDay(o.daytime, o.end_date, (p_daytime + EcDp_Productionday.getProductionDayOffset(o.object_type,o.object_id,p_start_date)/24), o.object_id)
    /24) day_loss
FROM system_days x, deferment_event o
WHERE o.parent_event_no = p_event_no
AND o.parent_daytime = p_start_date
AND x.daytime = ecdp_productionday.getproductionday(o.object_type, o.object_id, p_start_date);
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
FUNCTION calcLossByDay(p_event_no VARCHAR2,
                       p_start_date DATE,
                       p_daytime  DATE,
                       p_phase    VARCHAR2,
                       p_prod_inj VARCHAR2) RETURN NUMBER
--</EC-DOC>
IS
  ln_retval        NUMBER;
  ln_durationfrac  number;
  lr_event         deferment_event%ROWTYPE;
  ld_daytime       DATE;
begin
  lr_event := ec_deferment_event.row_by_pk(p_event_no);

  IF lr_event.end_date IS NULL AND lr_event.object_type <> 'WELL' THEN
    -- Open-ended parent events must always be calculated from children's rates
    ln_retval := calcLossByDayFromChildren(p_event_no, p_start_date, p_daytime, p_phase, p_prod_inj);
  ELSE
     -- Find how big part of the total event this day and taking into account production day start
    ld_daytime := p_daytime +
                  (Ecdp_Productionday.getProductionDayOffset(lr_event.object_type,lr_event.object_id,p_daytime)
                                /ecdp_date_time.getNumHours(lr_event.object_type,lr_event.object_id,p_daytime));
    IF(lr_event.end_date IS NULL) THEN
      lr_event.end_date := ld_daytime + 1;
    END IF;

   -- Custom code by CVX to seperate well events from parent events
      IF lr_event.object_type = 'WELL'
      THEN
         -- End Change

    IF (lr_event.daytime > ld_daytime + 1) OR (lr_event.end_date <= ld_daytime) OR (lr_event.end_date = lr_event.daytime) THEN
      ln_durationfrac := 0;
    ELSE
      ln_durationfrac := Least(lr_event.end_date, ld_daytime+1) - Greatest(lr_event.daytime, ld_daytime);
    END IF;

    -- Handle different combinations of injectors/producers and phases
    IF SubStr(p_prod_inj,1,1) = 'P' AND p_phase = EcDp_Phase.Oil THEN
        ln_retval := lr_event.oil_loss_rate * ln_durationfrac;
    ELSIF SubStr(p_prod_inj,1,1) = 'P' AND p_phase = EcDp_Phase.Gas THEN
        ln_retval := lr_event.gas_loss_rate * ln_durationfrac;
    ELSIF SubStr(p_prod_inj,1,1) = 'P' AND p_phase = EcDp_Phase.Water THEN
        ln_retval := lr_event.water_loss_rate * ln_durationfrac;
    ELSIF SubStr(p_prod_inj,1,1) = 'P' AND p_phase = EcDp_Phase.Condensate THEN
        ln_retval := lr_event.cond_loss_rate * ln_durationfrac;
    ELSIF SubStr(p_prod_inj,1,1) = 'I' AND p_phase = EcDp_Phase.Gas THEN
        ln_retval := lr_event.gas_inj_loss_rate * ln_durationfrac;
    ELSIF SubStr(p_prod_inj,1,1) = 'I' AND p_phase = EcDp_Phase.Water THEN
        ln_retval := lr_event.water_inj_loss_rate * ln_durationfrac;
    END IF;
    -- CVX Change
  -- Hnadlw non-well events
  ELSE
     IF    (lr_event.daytime > ld_daytime + 1)
            OR (lr_event.end_date <= ld_daytime)
            OR (lr_event.end_date = lr_event.daytime)
         THEN
            ln_durationfrac := 0;
         ELSE
   --  Calculate current day as fraction of total incident
            ln_durationfrac :=
                 (  LEAST (lr_event.end_date, ld_daytime + 1)
                  - GREATEST (lr_event.daytime, ld_daytime)
                 )
               / (lr_event.end_date - lr_event.daytime);
         END IF;
   -- Handle different combinations of injectors/producers and phases
         IF SUBSTR (p_prod_inj, 1, 1) = 'P' AND p_phase = ecdp_phase.oil
         THEN
            ln_retval := (ecbp_deferment.getparenteventlossrate
                                          (p_event_no,
                                           'OIL',
                                           'SINGLE'
                                          )) * ln_durationfrac;
         ELSIF SUBSTR (p_prod_inj, 1, 1) = 'P' AND p_phase = ecdp_phase.gas
         THEN
            ln_retval := (ecbp_deferment.getparenteventlossrate
                                          (p_event_no,
                                           'GAS',
                                           'SINGLE'
                                          )) * ln_durationfrac;
         ELSIF     SUBSTR (p_prod_inj, 1, 1) = 'P'
               AND p_phase = ecdp_phase.condensate
         THEN
            ln_retval := (ecbp_deferment.getparenteventlossrate
                                         (p_event_no,
                                          'COND',
                                           'SINGLE'
                                         )) * ln_durationfrac;
         ELSIF SUBSTR (p_prod_inj, 1, 1) = 'I' AND p_phase = ecdp_phase.gas
         THEN
            ln_retval := (ecbp_deferment.getparenteventlossrate
                                    (p_event_no,
                                     'GAS_INJ',
                                           'SINGLE'
                                    )) * ln_durationfrac;
         ELSIF SUBSTR (p_prod_inj, 1, 1) = 'I' AND p_phase = ecdp_phase.water
         THEN
            ln_retval := (ecbp_deferment.getparenteventlossrate
                                      (p_event_no,
                                       'WAT_INJ',
                                           'SINGLE'
                                      )) * ln_durationfrac;
          ELSIF SUBSTR (p_prod_inj, 1, 1) = 'P' AND p_phase = ecdp_phase.water
         THEN
            ln_retval := (ecbp_deferment.getparenteventlossrate
                                      (p_event_no,
                                       'WAT',
                                           'SINGLE'
                                      )) * ln_durationfrac;
         END IF;
      END IF;
   --  CVX CHange end
  END IF;
  RETURN ln_retval;
END calcLossByDay;
END UE_CT_WELL_DEFERMENT;
/
