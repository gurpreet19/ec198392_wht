CREATE OR REPLACE PACKAGE BODY EcBp_Forecast_Event IS

/****************************************************************
** Package        :  EcBp_Forecast_Event, body part
**
** $Revision: 1.1 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Forecast Event.
** Documentation  :  www.energy-components.com
**
** Created  : 19.05.2016 Suresh Kumar
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 19-05-16    kumarsur    Initial Version
** 26-09-16    jainnraj    ECPD-39068 Modified getEventLossVolume,getPotentialRate to add support for Co2 Injection
** 18-10-16    abdulmaw    ECPD-34304: Added function isAssociatedWithGroup to check which reason group associated with the selected reason code
** 07.08.2017  jainnraj    ECPD-46835: Modified procedure checkIfEventOverlaps,checkValidChildPeriod,getEventLossVolume,getPotentialRate to correct the error message.
** 08-12-2017  kashisag  ECPD-40487: Corrected local variables naming convention.
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkIfEventOverlaps
-- Description    : Checks if overlapping event exists.
--
--
-- Preconditions  :
-- Postconditions : Raises an application error if overlapping event exists.
--
-- Using tables   : FCST_WELL_EVENT
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
PROCEDURE  checkIfEventOverlaps(p_object_id VARCHAR2, p_daytime DATE, p_end_date DATE, p_event_type VARCHAR2, p_event_no NUMBER)
--</EC-DOC>
IS
  -- overlapping period can't exist in well downtime and eqpm downtime
    ln_count NUMBER;
    lv2_default_value VARCHAR2(2000);

BEGIN

    SELECT default_value
    INTO   lv2_default_value
    FROM  (select default_value
            from (select default_value_string default_value, to_date('01-01-1900', 'DD-MM-YYYY') daytime
                  FROM ctrl_property_meta
                  where key = 'DEFERMENT_OVERLAP'
                  UNION ALL
                  select value_string, daytime
                  from ctrl_property
                  where key = 'DEFERMENT_OVERLAP')
           order by daytime desc)
   where rownum < 2;


  IF lv2_default_value = 'N' THEN

  SELECT count(*) into ln_count
    FROM FCST_WELL_EVENT fwe
    WHERE fwe.EVENT_ID = p_object_id
    AND fwe.event_no <> p_event_no
    AND  fwe.event_type IN ('DOWN')
    AND  fwe.event_type = p_event_type
    AND (fwe.end_date > p_daytime OR fwe.end_date is null)
    AND  (fwe.daytime < p_end_date OR p_end_date IS NULL);

    IF(ln_count>0) THEN
           RAISE_APPLICATION_ERROR(-20226, 'An event must not overlap with the existing event period.');
    END IF;

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
-- Using tables   : FCST_WELL_EVENT
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

  ln_count NUMBER;

  BEGIN
    SELECT count(*)
	INTO ln_count
    FROM FCST_WELL_EVENT fwe
    WHERE (fwe.daytime > p_daytime
    OR fwe.end_date < p_daytime)
    AND fwe.event_no = p_parent_event_no;

  IF ln_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20222, 'This time period is outside the parent event period.');
  END IF;

END  checkValidChildPeriod;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getEventLossVolume                                                   --
-- Description    : Returns Event Loss Volume
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
FUNCTION getEventLossVolume (
  p_event_no      NUMBER,
  p_phase         VARCHAR2,
  p_object_id     VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

  ln_return_val NUMBER;
  lv2_object_id VARCHAR2(32);

  CURSOR c_deferred (cp_object_id VARCHAR2) IS
    SELECT DECODE(p_phase,
      'OIL',sum(deferred_net_oil_vol),
      'GAS',sum(deferred_gas_vol),
      'COND',sum(deferred_cond_vol),
      'WATER',sum(deferred_water_vol),
      'WAT_INJ',sum(deferred_water_inj_vol),
      'STEAM_INJ',sum(deferred_steam_inj_vol),
      'GAS_INJ',sum(deferred_gas_inj_vol),
      'DILUENT',sum(deferred_diluent_vol),
      'GAS_LIFT',sum(deferred_gl_vol),
      'CO2_INJ',sum(deferred_co2_inj_vol)) sum_vol
    FROM FCST_WELL_EVENT_ALLOC
    WHERE object_id = cp_object_id and event_no = p_event_no;

BEGIN

  ln_return_val := Ue_Forecast_Event.getEventLossVolume(p_event_no,p_phase,p_object_id);
  lv2_object_id := p_object_id;

  IF ln_return_val IS NULL THEN
   IF p_object_id IS NULL THEN
      BEGIN
        SELECT fwe.EVENT_ID
        INTO lv2_object_id
        FROM FCST_WELL_EVENT fwe
        WHERE event_no  = p_event_no;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20226, 'An error occurred while fetching data for event no- '||p_event_no);
      END;
   END IF;

       FOR mycur IN c_deferred(lv2_object_id) LOOP
            ln_return_val := mycur.sum_vol;
       END LOOP;

  END IF;

  RETURN ln_return_val;
END getEventLossVolume;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getPotentialRate                                                   --
-- Description    : Returns Potential Rate
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
FUNCTION getPotentialRate (
  p_event_no NUMBER,
  p_potential_attribute VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS

  ln_return_val NUMBER;

  CURSOR c_group_potential_rate IS
    SELECT sum(DECODE(p_potential_attribute,
    'OIL',decode(ecdp_well.isWellPhaseActiveStatus(wed.object_id,null,'OPEN',wed.daytime), 'Y', ecbp_well_potential.findOilProductionPotential(wed.object_id, wed.daytime), null),
    'GAS',decode(ecdp_well.isWellPhaseActiveStatus(wed.object_id,null,'OPEN',wed.daytime), 'Y', ecbp_well_potential.findGasProductionPotential(wed.object_id, wed.daytime), null),
    'COND',decode(ecdp_well.isWellPhaseActiveStatus(wed.object_id,null,'OPEN',wed.daytime), 'Y', ecbp_well_potential.findConProductionPotential(wed.object_id, wed.daytime), null),
    'WATER',decode(ecdp_well.isWellPhaseActiveStatus(wed.object_id,null,'OPEN',wed.daytime), 'Y', ecbp_well_potential.findWatProductionPotential(wed.object_id, wed.daytime), null),
    'WAT_INJ', decode(ecdp_well.isWellPhaseActiveStatus(wed.object_id,'WI','OPEN',wed.daytime), 'Y', ecbp_well_potential.findWatInjectionPotential(wed.object_id, wed.daytime), null),
    'STEAM_INJ', decode(ecdp_well.isWellPhaseActiveStatus(wed.object_id,'SI','OPEN',wed.daytime), 'Y', ecbp_well_potential.findSteamInjectionPotential(wed.object_id, wed.daytime), null),
    'GAS_INJ', decode(ecdp_well.isWellPhaseActiveStatus(wed.object_id,'GI','OPEN',wed.daytime), 'Y', ecbp_well_potential.findGasInjectionPotential(wed.object_id, wed.daytime), null),
    'DILUENT',decode(ecdp_well.isWellPhaseActiveStatus(wed.object_id,null,'OPEN',wed.daytime), 'Y', ecbp_well_potential.findDiluentPotential(wed.object_id, wed.daytime), null),
    'GAS_LIFT',decode(ecdp_well.isWellPhaseActiveStatus(wed.object_id,null,'OPEN',wed.daytime), 'Y', ecbp_well_potential.findGasLiftPotential(wed.object_id, wed.daytime), null),
    'CO2_INJ',decode(ecdp_well.isWellPhaseActiveStatus(wed.object_id,'CI','OPEN',wed.daytime), 'Y', ecbp_well_potential.findCo2InjectionPotential(wed.object_id, wed.daytime), null))) sum_vol
    FROM fcst_well_event wed
    WHERE wed.parent_event_no = p_event_no
    AND wed.deferment_type = 'GROUP_CHILD';

  lv2_deferment_type VARCHAR2(32);
  lv2_parent_object_id VARCHAR2(32);
  ld_parent_daytime DATE;
  lv2_object_id VARCHAR2(32);
  ld_daytime DATE;

BEGIN

    BEGIN
      SELECT wed_1.EVENT_ID, wed_1.daytime, wed_1.deferment_type, wed_1.parent_object_id, wed_1.parent_daytime
      INTO lv2_object_id,ld_daytime,lv2_deferment_type,lv2_parent_object_id,ld_parent_daytime
      FROM FCST_WELL_EVENT wed_1
      WHERE event_no  = p_event_no;
    EXCEPTION
      WHEN OTHERS THEN
           RAISE_APPLICATION_ERROR(-20226, 'An error occurred while fetching data for event no- '||p_event_no);
    END;

  IF lv2_deferment_type ='SINGLE' or lv2_deferment_type ='GROUP_CHILD' THEN
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
    ELSIF  p_potential_attribute = 'DILUENT' then
      IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN', ld_daytime) = 'Y' THEN
        ln_return_val := ecbp_well_potential.findDiluentPotential(lv2_object_id,ld_daytime);
      END IF;
    ELSIF  p_potential_attribute = 'GAS_LIFT' then
      IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN', ld_daytime) = 'Y' THEN
        ln_return_val := ecbp_well_potential.findGasLiftPotential(lv2_object_id,ld_daytime);
      END IF;
    ELSIF  p_potential_attribute = 'CO2_INJ' then
      IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,'CI','OPEN', ld_daytime) = 'Y' THEN
        ln_return_val := ecbp_well_potential.findCo2InjectionPotential(lv2_object_id,ld_daytime);
      END IF;
    END IF;
  ELSIF  lv2_deferment_type  ='GROUP' THEN

    ln_return_val := Ue_Forecast_Event.getPotentialRate(p_event_no, p_potential_attribute);

    IF ln_return_val is NULL THEN
      FOR cur_group_potential_rate in c_group_potential_rate LOOP
        ln_return_val := cur_group_potential_rate.sum_vol;
      END LOOP;
    END IF;

  END IF;

  RETURN ln_return_val;
END getPotentialRate;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getParentEventLossRate                                                   --
-- Description    : Returns Parent Event Loss Rate
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
FUNCTION getParentEventLossRate (
  p_event_no NUMBER,
  p_event_attribute   VARCHAR2,
  p_deferment_type     VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS

  ln_return_val         NUMBER;
  ln_child_count        NUMBER;
  ln_RateOrVol          NUMBER;
  ln_TotEventLossRate   NUMBER;

  CURSOR c_fcst_event  IS
    SELECT fwe.EVENT_ID, fwe.daytime, fwe.event_no
    FROM FCST_WELL_EVENT fwe
    WHERE fwe.parent_event_no = p_event_no;

BEGIN

  ln_child_count := countChildEvent(p_event_no);
  IF  p_deferment_type  = 'GROUP' THEN
    --not with child
    IF ln_child_count = 0 THEN
        ln_RateOrVol       := getEventLossVolume(p_event_no, p_event_attribute);
        IF ln_RateOrVol IS NOT NULL THEN
          ln_TotEventLossRate := nvl(ln_TotEventLossRate,0) + ln_RateOrVol;
        END IF;
    END IF;

    --with child
    IF ln_child_count > 0 THEN
      FOR r_child_event IN c_fcst_event  LOOP
        ln_RateOrVol       := getEventLossVolume(r_child_event.event_no, p_event_attribute);
        IF ln_RateOrVol IS NOT NULL THEN
          ln_TotEventLossRate := nvl(ln_TotEventLossRate,0) + ln_RateOrVol;
        END IF;
      END LOOP;
    END IF;
    ln_return_val := ln_TotEventLossRate;
  ELSE
    ln_return_val := getEventLossVolume(p_event_no, p_event_attribute);
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
-- Using tables   : FCST_WELL_EVENT
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

DELETE FROM FCST_WELL_EVENT
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
-- Using tables   : FCST_WELL_EVENT
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

 ln_child_record NUMBER;

BEGIN
  SELECT count(fwe.EVENT_ID) INTO ln_child_record
    FROM FCST_WELL_EVENT fwe
    WHERE fwe.parent_event_no = p_event_no;

  return ln_child_record;

END countChildEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkChildEndDate
-- Description    : Checks child end date
--
--
-- Preconditions  :
-- Postconditions : Raises an application error if new start date exceed child end date.
--
-- Using tables   : FCST_WELL_EVENT
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
   ld_chk_child date := NULL;

  BEGIN

    SELECT min(fwe.end_date) into ld_chk_child
    FROM FCST_WELL_EVENT fwe
    WHERE fwe.parent_event_no = p_parent_event_no;

  IF ld_chk_child < p_daytime THEN
       RAISE_APPLICATION_ERROR(-20667, 'Parent event start date is invalid as it is after child event end date.');
  END IF;

  END  checkChildEndDate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : isAssociatedWithGroup
-- Description    : check reason_code associated to which reason group
--
--
-- Preconditions  :
-- Postconditions : .
--
-- Using tables   :
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
FUNCTION isAssociatedWithGroup(p_reason_group VARCHAR2,
                               p_reason_code VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS

 lv2_return_val VARCHAR2(1);

 CURSOR c_associatedGroup (cp_reason_group VARCHAR2, cp_reason_code VARCHAR2) IS
    SELECT code_text
    FROM prosty_codes
    WHERE code_type = 'WELL_DT_REAS_1'
    AND code = cp_reason_code
    AND code in (select code2 from ctrl_code_dependency
                where code_type1 = 'EVENT_REASON_GROUP'
                AND code1 = cp_reason_group);

BEGIN

  lv2_return_val := Ue_Forecast_Event.isAssociatedWithGroup(p_reason_group,p_reason_code);

  IF lv2_return_val IS NULL THEN

     lv2_return_val := 'N';

     FOR cur_associatedGroup in c_associatedGroup(p_reason_group,p_reason_code) LOOP
       lv2_return_val := 'Y';
     END LOOP;
  END IF;

  RETURN lv2_return_val;

END isAssociatedWithGroup;

END EcBp_Forecast_Event;