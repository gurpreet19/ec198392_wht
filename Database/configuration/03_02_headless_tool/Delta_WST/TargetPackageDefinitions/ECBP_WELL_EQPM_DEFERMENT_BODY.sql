CREATE OR REPLACE PACKAGE BODY EcBp_Well_Eqpm_Deferment IS

/****************************************************************
** Package        :  EcBp_Well_Eqpm_Deferment, header part
**
** $Revision: 1.27.2.10 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Equipment and Well Deferment.
** Documentation  :  www.energy-components.com
**
** Created  : 11.07.2007  Sarojini Rajaretnam
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 27.08.2007 leong    ECPD-3696 Modified function getPotentialRate to support steam
** 10.10.2007 rajarsar ECPD-6313: Added calcWellProdLossDay
** 15.04.2008 oonnnng  ECPD-7825: Add SteamInj in getEventLossRate function.
** 18.04.2008 rajarsar ECPD-7828: Updated raise error message from 20602 to 20546 as it overlaps with another error message.
** 18.04.2008 rajarsar ECPD-7828: Added getParentEventLossRate
** 21.04.2008 rajarsar ECPD-7828: Updated getEventLossRate and getParentEventLossRate
** 02.05.2008 rajarsar ECPD-7828: Updated parameter in getParentEventLossRate
** 21.05.2008 oonnnng  ECPD-7878: Add deleteChildEvent procedure and countChildEvent function.
** 11-06-2008 oonnnng  ECPD-8621: Add checking of ecdp_well.isWellPhaseActiveStatus() in getPotentialRate function.
** 03.07.2008 rajarsar ECPD-8939: Updated raise error message from 20546 to 20226 as it might overlap with another error message.
** 31.12.2008 sharawan ECPD-10416:Replaced all references to EcDp_Type.pb_comp_number%TYPE with NUMBER in functions
**                     getEventLossRate, getPotentialRate.
** 11.09.2009 lauuufus ECPD-11390: Add another cursor in getParentEventLossRate() to get the loss rate of the parent which does not have child record.
** 28-12-2009 leongwen ECPD-13176 Enhancement to Equipment Off deferment screen
** 29-04-2010 rajarsar ECPD-14460:Updated checkIfEventOverlaps
** 24-08-2010 oonnnng ECPD-14744: The overflow problem in EcBp_Well_Eqpm_Deferment.checkIfEventOverlaps() function has been fixed.
** 24.10.2011 rajarsar ECPD-18545: Added getPlannedVolumes, getActualVolumes,getActualProducedVolumes and getAssignedDeferVolumes.
** 24.10.2011 abdulmaw ECPD-18546: Added calcWellEqpmActionVolume and VerifyActionsWellEqpm.
** 27.10.2011 rajarsar ECPD-17492: Updated getEventLossRate, getPotentialRate, checkIfChildEventExists, checkValidChildPeriod, getParentEventLossRate, deleteChildEvent,countChildEvent to support new PK which is EVENT_NO.
** 25-02-2013 leongwen ECPD-23416: Modified getEventLossRate
** 11-07-2013 leongwen ECPD-24671: Modified getEventLossRate
** 16-07-2013 wonggkai ECPD-24868: Modified getPotentialRate to suppport USER EXIT feature.
** 26-07-2013 wonggkai ECPD-24868: Modified getPotentialRate, add p_potential_attribute as parameter to Ue_Well_Eqpm_Deferment.getPotentialRate()
** 17-09-2013 abdulmaw ECPD-24671: Modified getEventLossRate to suppport USER EXIT feature.
** 20-09-2013 kumarsur ECPD-25484: Modified getEventLossRate if loss rate is empty then use potential rate.
** 22-11-2013 leongwen ECPD-26096: Added lock check chkDowntimeConstraintLock for Well Downtime, Well Downtime by Well and Well Constraints screens.
** 19-12-2013 kumarsur ECPD-26357: Modified checkIfEventOverlaps to include event_no.
** 03-01-2014 kumarsur ECPD-26357: Add checkChildEndDate procedure.
** 14-04-2014 dhavaalo ECPD-27361: Well Equpment Downtime Event doen't include water loss rate
*****************************************************************/


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getEventLossRate                                                   --
-- Description    : Returns Event Loss Rate
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : well_equip_downtime
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
FUNCTION getEventLossRate (
  p_event_no      NUMBER,
   p_event_attribute VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS

  ln_diff     NUMBER := 0;
  ln_return_val NUMBER;

  CURSOR c_well_equip_downtime (cp_event_no NUMBER) IS
    SELECT wed.daytime, wed.end_date, wed.oil_loss_rate, wed.gas_loss_rate, wed.cond_loss_rate, wed.water_inj_loss_rate,
    wed.gas_inj_loss_rate, wed.steam_inj_loss_rate,
    wed.oil_loss_volume, wed.gas_loss_volume, wed.cond_loss_volume, wed.water_inj_loss_volume,
    wed.gas_inj_loss_volume, wed.steam_inj_loss_volume,
	wed.water_loss_volume,wed.water_loss_rate
  FROM well_equip_downtime wed
  WHERE event_no = cp_event_no;

BEGIN
	ln_diff := NULL;
	ln_return_val := Ue_Well_Eqpm_Deferment.getEventLossRate(p_event_no,p_event_attribute);
	IF ln_return_val IS NULL THEN
	  FOR r_wed_event_loss_rate IN c_well_equip_downtime(p_event_no) LOOP
		IF r_wed_event_loss_rate.end_date IS NOT NULL then
		  ln_diff := abs(r_wed_event_loss_rate.end_date- r_wed_event_loss_rate.daytime);

		  IF p_event_attribute = 'OIL' and r_wed_event_loss_rate.oil_loss_volume IS NOT NULL THEN
			ln_return_val := r_wed_event_loss_rate.oil_loss_volume;
		  ELSIF p_event_attribute = 'OIL' THEN
			ln_return_val := ln_diff *  nvl(r_wed_event_loss_rate.oil_loss_rate,getPotentialRate(p_event_no, p_event_attribute));
		  END IF;

		  IF p_event_attribute = 'GAS' and r_wed_event_loss_rate.gas_loss_volume IS NOT NULL THEN
			ln_return_val := r_wed_event_loss_rate.gas_loss_volume;
		  ELSIF p_event_attribute = 'GAS' THEN
			ln_return_val := ln_diff *  nvl(r_wed_event_loss_rate.gas_loss_rate,getPotentialRate(p_event_no, p_event_attribute));
		  END IF;

		  IF p_event_attribute = 'WAT_INJ' and r_wed_event_loss_rate.water_inj_loss_volume IS NOT NULL THEN
			ln_return_val := r_wed_event_loss_rate.water_inj_loss_volume;
		  ELSIF  p_event_attribute = 'WAT_INJ' THEN
			ln_return_val := ln_diff *  nvl(r_wed_event_loss_rate.water_inj_loss_rate,getPotentialRate(p_event_no, p_event_attribute));
		  END IF;

		  IF p_event_attribute = 'STEAM_INJ' and r_wed_event_loss_rate.steam_inj_loss_volume IS NOT NULL THEN
			ln_return_val := r_wed_event_loss_rate.steam_inj_loss_volume;
		  ELSIF  p_event_attribute = 'STEAM_INJ' THEN
			ln_return_val := ln_diff *  nvl(r_wed_event_loss_rate.steam_inj_loss_rate,getPotentialRate(p_event_no, p_event_attribute));
		  END IF;

		  IF  p_event_attribute = 'COND' and r_wed_event_loss_rate.cond_loss_volume IS NOT NULL THEN
			ln_return_val := r_wed_event_loss_rate.cond_loss_volume;
		  ELSIF  p_event_attribute = 'COND' THEN
			ln_return_val := ln_diff *  nvl(r_wed_event_loss_rate.cond_loss_rate,getPotentialRate(p_event_no, p_event_attribute));
		  END IF;

		  IF  p_event_attribute = 'GAS_INJ' and r_wed_event_loss_rate.gas_inj_loss_volume IS NOT NULL THEN
			ln_return_val := r_wed_event_loss_rate.gas_inj_loss_volume;
		  ELSIF  p_event_attribute = 'GAS_INJ' THEN
			ln_return_val := ln_diff *  nvl(r_wed_event_loss_rate.gas_inj_loss_rate,getPotentialRate(p_event_no, p_event_attribute));
		  END IF;

		   IF p_event_attribute = 'WATER' and r_wed_event_loss_rate.water_loss_volume IS NOT NULL THEN
			ln_return_val := r_wed_event_loss_rate.water_loss_volume;
		  ELSIF p_event_attribute = 'WATER' THEN
			ln_return_val := ln_diff *  nvl(r_wed_event_loss_rate.water_loss_rate,getPotentialRate(p_event_no, p_event_attribute));
		  END IF;

		END IF;
	  END LOOP;
	END IF;

  RETURN ln_return_val;
END getEventLossRate;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getPotentialRate                                                   --
-- Description    : Returns Potential Rate
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : well_equip_downtime
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
FUNCTION getPotentialRate (
   p_event_no NUMBER,
  p_potential_attribute VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS

  ln_return_val NUMBER;

  CURSOR c_well_eqpm_downtime  IS
    SELECT wed_1.object_id, wed_1.daytime, wed_1.downtime_type, wed_1.master_event_id, wed_1.parent_object_id, wed_1.parent_daytime
    FROM well_equip_downtime wed_1
    WHERE event_no  = p_event_no;


  CURSOR c_group_potential_rate IS
    SELECT sum(DECODE(p_potential_attribute,
    'OIL',decode(ecdp_well.isWellPhaseActiveStatus(wed.object_id,null,'OPEN',wed.daytime), 'Y', ecbp_well_potential.findOilProductionPotential(wed.object_id, wed.daytime), null),
    'GAS',decode(ecdp_well.isWellPhaseActiveStatus(wed.object_id,null,'OPEN',wed.daytime), 'Y', ecbp_well_potential.findGasProductionPotential(wed.object_id, wed.daytime), null),
	'WATER',decode(ecdp_well.isWellPhaseActiveStatus(wed.object_id,null,'OPEN',wed.daytime), 'Y', ecbp_well_potential.findWatProductionPotential(wed.object_id, wed.daytime), null),
    'COND',decode(ecdp_well.isWellPhaseActiveStatus(wed.object_id,null,'OPEN',wed.daytime), 'Y', ecbp_well_potential.findConProductionPotential(wed.object_id, wed.daytime), null),
    'WAT_INJ', decode(ecdp_well.isWellPhaseActiveStatus(wed.object_id,'WI','OPEN',wed.daytime), 'Y', ecbp_well_potential.findWatInjectionPotential(wed.object_id, wed.daytime), null),
    'STEAM_INJ', decode(ecdp_well.isWellPhaseActiveStatus(wed.object_id,'SI','OPEN',wed.daytime), 'Y', ecbp_well_potential.findSteamInjectionPotential(wed.object_id, wed.daytime), null),
    'GAS_INJ', decode(ecdp_well.isWellPhaseActiveStatus(wed.object_id,'GI','OPEN',wed.daytime), 'Y', ecbp_well_potential.findGasInjectionPotential(wed.object_id, wed.daytime), null))) sum_vol
    FROM well_equip_downtime wed
    WHERE wed.parent_event_no = p_event_no
    AND wed.downtime_class_type = 'GROUP_CHILD';

  lv2_downtime_type VARCHAR2(32);
  lv2_parent_object_id VARCHAR2(32);
  ld_parent_daytime DATE;
  lv2_object_id VARCHAR2(32);
  ld_daytime DATE;

BEGIN

    FOR c_wed_event_potential IN c_well_eqpm_downtime LOOP
      lv2_object_id := c_wed_event_potential.object_id;
      ld_daytime   := c_wed_event_potential.daytime;
      lv2_downtime_type := c_wed_event_potential.downtime_type;
      lv2_parent_object_id :=  c_wed_event_potential.parent_object_id;
      ld_parent_daytime :=  c_wed_event_potential.parent_daytime;
    END LOOP;
    IF lv2_downtime_type ='WELL_DT' THEN
      IF p_potential_attribute = 'OIL' then
        IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN', ld_daytime) = 'Y' THEN
           ln_return_val := ecbp_well_potential.findOilProductionPotential(lv2_object_id,ld_daytime);
        END IF;
      ELSIF  p_potential_attribute = 'GAS' then
        IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN', ld_daytime) = 'Y' THEN
            ln_return_val := ecbp_well_potential.findGasProductionPotential(lv2_object_id,ld_daytime);
        END IF;
      ELSIF p_potential_attribute = 'WAT_INJ' then
        IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,'WI','OPEN',ld_daytime) = 'Y' THEN
           ln_return_val := ecbp_well_potential.findWatInjectionPotential(lv2_object_id,ld_daytime);
        END IF;
      ELSIF p_potential_attribute = 'STEAM_INJ' then
        IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,'SI','OPEN',ld_daytime) = 'Y' THEN
           ln_return_val := ecbp_well_potential.findSteamInjectionPotential(lv2_object_id,ld_daytime);
        END IF;
      ELSIF  p_potential_attribute = 'COND' then
        IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN',ld_daytime) = 'Y' THEN
           ln_return_val := ecbp_well_potential.findConProductionPotential(lv2_object_id,ld_daytime);
        END IF;
      ELSIF p_potential_attribute = 'GAS_INJ' then
        IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,'GI','OPEN',ld_daytime) = 'Y' THEN
           ln_return_val := ecbp_well_potential.findGasInjectionPotential(lv2_object_id,ld_daytime);
        END IF;
      ELSIF  p_potential_attribute = 'WATER' then
		IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN', ld_daytime) = 'Y' THEN
			ln_return_val := ecbp_well_potential.findWatProductionPotential(lv2_object_id,ld_daytime);
		END IF;
      END IF;

    ELSIF  lv2_downtime_type  ='GROUP_DT' THEN

      ln_return_val := Ue_Well_Eqpm_Deferment.getPotentialRate(p_event_no, p_potential_attribute);

      IF ln_return_val is NULL THEN
      FOR cur_group_potential_rate in c_group_potential_rate LOOP
        ln_return_val := cur_group_potential_rate.sum_vol;
      END LOOP;
      END IF;

    END IF;

  RETURN ln_return_val;
END getPotentialRate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkIfChildEventExists
-- Description    : Checks if child events exist for the parent event id when deleteing.
--
--
-- Preconditions  :
-- Postconditions : Raises an application error if child records found when deleting a parent.
--
-- Using tables   : well_equip_fcty_deferment_event
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
PROCEDURE checkIfChildEventExists(p_event_no NUMBER)
--</EC-DOC>
IS

  CURSOR c_child_event  IS
    SELECT count(object_id) totalrecord
    FROM well_equip_downtime wde
    WHERE parent_event_no = p_event_no;


 ln_child_record NUMBER;

BEGIN
   ln_child_record := 0;

  FOR cur_child_event IN c_child_event LOOP
    ln_child_record := cur_child_event.totalrecord ;
  END LOOP;

  IF p_event_no IS NOT NULL and ln_child_record > 0   THEN
    RAISE_APPLICATION_ERROR(-20216, 'It was attempted to delete a row that has child records. In order to delete this row, all child records must be deleted first.');
  END IF;

END checkIfChildEventExists;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      :checkIfEventOverlaps
-- Description    : Checks if overlapping event exists.
--
--
-- Preconditions  :
-- Postconditions : Raises an application error if overlapping event exists.
--
-- Using tables   : well_equip_downtime
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
PROCEDURE  checkIfEventOverlaps(p_object_id VARCHAR2, p_daytime DATE, p_end_date DATE, p_downtime_categ VARCHAR2, p_event_no NUMBER)
--</EC-DOC>
IS
  -- overlapping period can't exist in well downtime and eqpm downtime
  CURSOR c_well_equip_dt_event  IS
    SELECT *
    FROM well_equip_downtime wde
    WHERE wde.object_id = p_object_id
    AND wde.event_no <> p_event_no
    AND  wde.downtime_categ = p_downtime_categ
    AND (wde.end_date > p_daytime OR wde.end_date is null)
    AND  (wde.daytime < p_end_date OR p_end_date IS NULL);

    lv_message VARCHAR2(4000);

BEGIN

  lv_message := null;

  FOR cur_well_equip_dt_event IN c_well_equip_dt_event LOOP
    lv_message := cur_well_equip_dt_event.object_id;
  END LOOP;

  IF lv_message is not null THEN
    RAISE_APPLICATION_ERROR(-20226, 'An event must not overlaps with existing event period.');
  END IF;

  END checkIfEventOverlaps;

  --<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkValidChildPeriod
-- Description    : Checks if child period are valid based on the Parent Start date/time and End Date/Tie
--
--
-- Preconditions  :
-- Postconditions : Raises an application error if child's period is not valid.
--
-- Using tables   : well_equip_downtime
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
PROCEDURE checkValidChildPeriod(p_parent_event_no NUMBER ,p_daytime DATE)
--</EC-DOC>
IS

   CURSOR c_outside_event_wed  IS
    SELECT *
    FROM well_equip_downtime wed
    WHERE (wed.daytime > p_daytime
    OR wed.end_date < p_daytime)
    AND wed.event_no = p_parent_event_no;

    lv_outside_message VARCHAR2(4000);

  BEGIN

  lv_outside_message := null;

  FOR cur_outside_event_wed IN c_outside_event_wed LOOP
    lv_outside_message := lv_outside_message || cur_outside_event_wed.object_id || ' ';
  END LOOP;

  IF lv_outside_message is not null THEN
    RAISE_APPLICATION_ERROR(-20222, 'This time period are outside the parent event period.');
  END IF;

  END  checkValidChildPeriod;
--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : calcWellProdLossDay                                                   --
-- Description    : Returns loss rate based on phase and well off time duration
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : well_equip_downtime
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
FUNCTION calcWellProdLossDay(
      p_object_id VARCHAR2,
      p_daytime   DATE,
      p_phase     VARCHAR2
      )
RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_well_eqpm_deferment(cp_object_id VARCHAR2, cp_daytime DATE) IS
SELECT daytime,
       Nvl(end_date, cp_daytime+1) end_date,
       OIL_LOSS_RATE,
       GAS_LOSS_RATE,
       GAS_INJ_LOSS_RATE,
       COND_LOSS_RATE,
       WATER_INJ_LOSS_RATE
FROM well_equip_downtime w
WHERE w.daytime < cp_daytime + 1
AND nvl(w.end_date, cp_daytime + 1) > cp_daytime
AND w.object_type = 'WELL'
AND w.object_id = cp_object_id
AND w.downtime_categ ='WELL_OFF';

ln_return  NUMBER;
ln_loss    NUMBER;
lv2_fcty_id     production_facility.object_id%TYPE;
ld_daytime      DATE;
ln_durationfrac NUMBER;

BEGIN

  ln_return := 0;

  lv2_fcty_id := ec_well_version.op_fcty_class_1_id(p_object_id, p_daytime, '<=');
  -- Calculate start time of production day
  ld_daytime := p_daytime + (EcDp_ProductionDay.getProductionDayOffset('FCTY_CLASS_1',lv2_fcty_id, p_daytime)/24); -- this is also true if 23 or 25 hours a day.

  FOR mycur IN c_well_eqpm_deferment(p_object_id, ld_daytime) LOOP

       IF (mycur.daytime > ld_daytime + 1)
       OR (mycur.end_date <= ld_daytime)
       OR (mycur.end_date = mycur.daytime) THEN
          ln_durationfrac := 0;
       ELSE
          ln_durationfrac := Least(mycur.end_date, ld_daytime+1) - Greatest(mycur.daytime, ld_daytime);
       END IF;

       -- Handle different combinations of injectors/producers and phases
       IF p_phase = EcDp_Phase.Oil THEN
          ln_loss := mycur.oil_loss_rate * ln_durationfrac;
       ELSIF p_phase = EcDp_Phase.Gas THEN
          IF ec_well_version.isGasInjector(p_object_id,p_daytime,'<=') = ECDP_TYPE.IS_TRUE THEN
            ln_loss := mycur.gas_inj_loss_rate * ln_durationfrac;
          Else
            ln_loss := mycur.gas_loss_rate * ln_durationfrac;
          End IF;
       ELSIF p_phase = EcDp_Phase.Condensate THEN
          ln_loss := mycur.cond_loss_rate * ln_durationfrac;
       ELSIF p_phase = EcDp_Phase.Water THEN
          IF ec_well_version.isWaterInjector(p_object_id,p_daytime,'<=') = ECDP_TYPE.IS_TRUE THEN
            ln_loss := mycur.water_inj_loss_rate * ln_durationfrac;
          ENd IF;
       END IF;

       ln_return := nvl(ln_loss,0) + ln_return;

  END LOOP;

  RETURN ln_return;

END calcWellProdLossDay;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getParentEventLossRate                                                   --
-- Description    : Returns Parent Event Loss Rate
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : well_equip_downtime
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
FUNCTION getParentEventLossRate (
  p_event_no NUMBER,
  p_event_attribute   VARCHAR2,
  p_downtime_type     VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS

  ln_return_val         NUMBER;
  ln_child_count        NUMBER;
  ln_RateOrVol          NUMBER;
  ln_TotEventLossRate   NUMBER;

  CURSOR c_well_equip_downtime  IS
    SELECT wed.object_id, wed.daytime, wed.event_no
    FROM well_equip_downtime wed
    WHERE wed.parent_event_no = p_event_no;

    CURSOR c_well_equip_downtime_parent   IS
    SELECT wed.object_id, wed.daytime, wed.event_no
    FROM well_equip_downtime wed
    WHERE wed.event_no = p_event_no;

BEGIN
  ln_child_count := countChildEvent(p_event_no);
  IF  p_downtime_type  = 'GROUP_DT' THEN
    --not with child
    IF ln_child_count = 0 THEN
      FOR r_wed_child_event IN c_well_equip_downtime_parent  LOOP
        ln_RateOrVol       := getEventLossRate(p_event_no, p_event_attribute);
        IF ln_RateOrVol IS NOT NULL THEN
          ln_TotEventLossRate := nvl(ln_TotEventLossRate,0) + ln_RateOrVol;
        END IF;
      END LOOP;
    END IF;

    --with child
    IF ln_child_count > 0 THEN
      FOR r_wed_child_event IN c_well_equip_downtime  LOOP
        ln_RateOrVol       := getEventLossRate(r_wed_child_event.event_no, p_event_attribute);
        IF ln_RateOrVol IS NOT NULL THEN
          ln_TotEventLossRate := nvl(ln_TotEventLossRate,0) + ln_RateOrVol;
        END IF;
      END LOOP;
    END IF;
    ln_return_val := ln_TotEventLossRate;
  ELSE
    ln_return_val := getEventLossRate(p_event_no, p_event_attribute);
  END IF;

  RETURN ln_return_val;
END getParentEventLossRate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : deleteChildEvent
-- Description    : Delete child events.
--
--
-- Preconditions  :
-- Postconditions : .
--
-- Using tables   : well_equip_downtime
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

DELETE FROM well_equip_downtime
WHERE parent_event_no = p_event_no;


END deleteChildEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : countChildEvent
-- Description    : Count child events exist for the parent event id.
--
--
-- Preconditions  :
-- Postconditions : .
--
-- Using tables   : well_equip_downtime
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
    FROM well_equip_downtime wde
    WHERE parent_event_no = p_event_no;


 ln_child_record NUMBER;

BEGIN
   ln_child_record := 0;

  FOR cur_child_event IN c_child_event LOOP
    ln_child_record := cur_child_event.totalrecord ;
  END LOOP;

  return ln_child_record;

END countChildEvent;

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
  'WAT_INJ', ec_prod_fcty_forecast.water_inj_rate(cp_fcst_scen_no,p_object_id,p_daytime,'<='),
  'GAS_INJ', ec_prod_fcty_forecast.gas_inj_rate(cp_fcst_scen_no,p_object_id,p_daytime,'<='),
  'STEAM_INJ', ec_prod_fcty_forecast.steam_inj_rate(cp_fcst_scen_no,p_object_id,p_daytime,'<=')) planned_vol
FROM dual;

CURSOR c_plan_fcty_vol(cp_class_name VARCHAR2) IS
SELECT DECODE(p_phase,
  'OIL', ec_object_plan.oil_rate(p_object_id,p_daytime,cp_class_name,'<='),
  'GAS', ec_object_plan.gas_rate(p_object_id,p_daytime,cp_class_name,'<='),
  'COND', ec_object_plan.cond_rate(p_object_id,p_daytime,cp_class_name,'<='),
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

  ELSIF p_phase = 'WAT_INJ' THEN
     lv2_strm_set := 'PD.0005_06';
     ln_actual_volume := getActualProducedVolumes(p_object_id, lv2_strm_set, p_daytime);

  ELSIF p_phase = 'GAS_INJ' THEN
     lv2_strm_set := 'PD.0005_03';
     ln_actual_volume := getActualProducedVolumes(p_object_id, lv2_strm_set, p_daytime);

  ELSIF p_phase = 'STEAM_INJ' THEN
     lv2_strm_set := 'PD.0005_05';
     ln_actual_volume := getActualProducedVolumes(p_object_id, lv2_strm_set, p_daytime);

  ELSIF p_phase = 'WATER' THEN
     lv2_strm_set := 'PD.0005_07';
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
-- Using tables   : well_equip_downtime
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

ln_assigned_defer_volume NUMBER;
ln_return NUMBER;
ln_durationfrac NUMBER;
ld_daytime      DATE;
ln_loss NUMBER;

CURSOR c_well_eqpm_deferment IS
SELECT w.daytime,
       Nvl(w.end_date, p_daytime+1) end_date,
      DECODE(p_phase,
     'OIL',OIL_LOSS_RATE,
     'GAS',GAS_LOSS_RATE,
     'COND',COND_LOSS_RATE,
	 'WATER',WATER_LOSS_RATE,
     'WAT_INJ',WATER_INJ_LOSS_RATE,
     'GAS_INJ',GAS_INJ_LOSS_RATE,
     'STEAM_INJ',STEAM_INJ_LOSS_RATE) loss_rate
FROM well_equip_downtime w, well_version wv
WHERE w.daytime < p_daytime + 1
AND nvl(w.end_date, p_daytime + 1) > p_daytime
AND w.object_type = 'WELL'
AND w.object_id = wv.object_id
AND wv.op_fcty_class_1_id = p_object_id
AND w.downtime_categ IN ('WELL_OFF','WELL_LOW');

BEGIN

  ln_return := 0;
  -- Calculate start time of production day
  --ld_daytime := p_daytime + (EcDp_ProductionDay.getProductionDayOffset('FCTY_CLASS_1',p_object_id, p_daytime)/24); -- this is also true if 23 or 25 hours a day.

  FOR mycur IN c_well_eqpm_deferment LOOP
    ln_durationfrac := Least(mycur.end_date, p_daytime+1) - Greatest(mycur.daytime, p_daytime);
    ln_loss := mycur.loss_rate * ln_durationfrac;
    ln_return := nvl(ln_loss,0) + ln_return;
  END LOOP;

  RETURN ln_return;
  END getAssignedDeferVolumes;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calcWellEqpmActionVolume
-- Description    : This function finds the deffered volume for the given corrective action period
--                  in well downtime and well constraints.
--                  volume =  event grp volume * corr action period/event period
-- Preconditions  :
-- Postconditions : .
--
-- Using tables   : well_equip_downtime
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
FUNCTION calcWellEqpmActionVolume(
  p_event_no NUMBER,
  p_daytime DATE,
  p_end_date DATE,
  p_event_attribute VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS

  ln_return NUMBER;
  ln_tot_event_loss_rate NUMBER;
  ln_duration NUMBER;
  ln_corr_action_duration NUMBER;
  lv_object_id VARCHAR2(50);
  lv_downtime_type VARCHAR2(50);
  ld_daytime DATE;

CURSOR c_object_id IS
  SELECT wed.object_id, wed.daytime, wed.downtime_type
    FROM well_equip_downtime wed
    WHERE wed.event_no = p_event_no;

CURSOR c_event_well_eqpm_qty IS
  SELECT wed.object_id,
         wed.daytime,
         wed.end_date
    FROM well_equip_downtime wed
    WHERE wed.event_no = p_event_no;

BEGIN

  FOR cur_object_id IN c_object_id LOOP
    lv_object_id := cur_object_id.object_id;
    lv_downtime_type := cur_object_id.downtime_type;
    ld_daytime := cur_object_id.daytime;
  END LOOP;

  FOR cur_event IN c_event_well_eqpm_qty LOOP
    --duration from parent
    ln_duration := cur_event.end_date - cur_event.daytime;
     --duration from child
    ln_corr_action_duration := p_end_date - p_daytime;

    ln_tot_event_loss_rate := getParentEventLossRate (p_event_no, p_event_attribute, lv_downtime_type);

    IF ln_tot_event_loss_rate IS NOT NULL THEN
      ln_return := ln_tot_event_loss_rate / ln_duration * ln_corr_action_duration;
    END IF;

  END LOOP;

  RETURN ln_return;

END calcWellEqpmActionVolume;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : VerifyActionsWellEqpm
-- Description    : This procedure checks that we don't have any overlapping actions on events for Well Downtime and Well Constraints
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
PROCEDURE VerifyActionsWellEqpm(p_event_no NUMBER, p_daytime DATE, p_end_date DATE, p_action VARCHAR2)

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
		FROM WELL_EQUIP_DOWNTIME  wed
		WHERE (wed.daytime > p_daytime
    OR wed.end_date < p_daytime
    OR wed.end_date < p_end_date)
    AND wed.event_no = p_event_no;

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
    lv_outside_message := lv_outside_message || cur_outside_event.event_no || ' ';
  END LOOP;

  IF lv_outside_message is not null THEN
    -- TODO: Get the right error code
    RAISE_APPLICATION_ERROR(-20626, 'This action time period are outside event time period.');
  END IF;
END VerifyActionsWellEqpm;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : chkDowntimeConstraintLock
-- Description    :
--
-- Preconditions  : Checks whether a last dated Well Downtime, Well Downtime by Well and Well Constraint record affects a locked month.
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: ec_well_equip_downtime,
--                  EcDp_Month_Lock.checkUpdateOfLDOForLock,
--                  EcDp_Month_Lock.buildIdentifierString,
--                  EcDp_Month_Lock.checkIfColumnsUpdated,
--                  EcDp_Month_Lock.validatePeriodForLockOverlap
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE chkDowntimeConstraintLock(p_operation VARCHAR2, p_new_lock_columns  IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns  IN OUT EcDp_Month_Lock.column_list)
--</EC-DOC>
IS

ld_new_daytime DATE;
ld_old_daytime DATE;
ld_new_end_date DATE;
ld_old_end_date DATE;
lv2_id VARCHAR2(2000);
lv2_columns_updated VARCHAR2(1);
lv2_o_obj_id VARCHAR2(32);
lv2_n_obj_id VARCHAR2(32);

BEGIN

  ld_new_daytime := p_new_lock_columns('DAYTIME').column_data.AccessDate;
  ld_old_daytime := p_old_lock_columns('DAYTIME').column_data.AccessDate;
  ld_new_end_date := p_new_lock_columns('END_DATE').column_data.AccessDate;
  ld_old_end_date := p_old_lock_columns('END_DATE').column_data.AccessDate;

   IF p_old_lock_columns.EXISTS('OBJECT_ID')  THEN
      lv2_o_obj_id := p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;
   IF p_new_lock_columns.EXISTS('OBJECT_ID')  THEN
      lv2_n_obj_id := p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;

   IF p_operation = 'INSERTING' THEN -- Only when inserting new valid analysis
      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);
      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_new_daytime, ld_new_end_date, lv2_id, lv2_n_obj_id);
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
                                              lv2_n_obj_id);
   ELSIF p_operation = 'DELETING' THEN -- Only when deleting a valid analysis
      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_old_lock_columns);
      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_old_daytime, ld_old_end_date, lv2_id, lv2_o_obj_id);
   END IF;

END chkDowntimeConstraintLock;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkChildEndDate
-- Description    : Checks child end date
--
--
-- Preconditions  :
-- Postconditions : Raises an application error if new start date exceed child end date.
--
-- Using tables   : well_equip_downtime
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
PROCEDURE checkChildEndDate(p_parent_event_no NUMBER ,p_daytime DATE)
--</EC-DOC>
IS
   ld_chk_child date := null;

  BEGIN

    SELECT min(wed.end_date) into ld_chk_child
    FROM well_equip_downtime wed
    WHERE wed.parent_event_no = p_parent_event_no;

  IF ld_chk_child < p_daytime THEN
       RAISE_APPLICATION_ERROR(-20667, 'Parent event start date is invalid as it is after child event end date.');
  END IF;

  END  checkChildEndDate;

END  EcBp_Well_Eqpm_Deferment;