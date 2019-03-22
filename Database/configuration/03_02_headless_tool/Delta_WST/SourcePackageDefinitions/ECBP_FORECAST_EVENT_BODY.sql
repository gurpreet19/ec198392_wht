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
** Date        Whom      Change description:
** ------      --------  --------------------------------------
** 19-05-2016  kumarsur  Initial Version
** 26-09-2016  jainnraj  ECPD-39068 Modified getEventLossVolume,getPotentialRate to add support for Co2 Injection
** 18-10-2016  abdulmaw  ECPD-34304: Added function isAssociatedWithGroup to check which reason group associated with the selected reason code
** 07.08.2017  jainnraj  ECPD-46835: Modified procedure checkIfEventOverlaps,checkValidChildPeriod,getEventLossVolume,getPotentialRate to correct the error message.
** 08-12-2017  kashisag  ECPD-40487: Corrected local variables naming convention.
** 05.07.2018  kashisag  ECPD-56795: Changed objectid to scenario id
** 21-12-2018  leongwen  ECPD-56158: Implement the similar Deferment Calculation Logic from PD.0020 to Forecast Event PP.0047
**                                   Modified procedure checkIfEventOverlaps
**                                   Modified Function getEventLossVolume, getPotentialRate, getParentEventLossRate
**                                   Added FUNCTION getEventLossRate, getEventLossNoChildEvent and getParentEventLossVolume
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
PROCEDURE checkIfEventOverlaps(p_object_id VARCHAR2, p_daytime DATE, p_end_date DATE, p_event_type VARCHAR2, p_event_no NUMBER, p_parent_event_no NUMBER DEFAULT 1)
--</EC-DOC>
IS
  -- overlapping period can't exist in well downtime and eqpm downtime
  ln_count NUMBER;
  lv2_default_value VARCHAR2(2000);
  p_parent_event_type VARCHAR2(10);
BEGIN

  IF p_event_type IS NULL THEN
    p_parent_event_type:= ec_fcst_well_event.event_type(p_parent_event_no);
  END IF;

  BEGIN
    SELECT default_value
    INTO   lv2_default_value
    FROM  (SELECT default_value
           FROM ( SELECT default_value_string default_value, TO_DATE('01-01-1900', 'DD-MM-YYYY') daytime
                  FROM ctrl_property_meta
                  WHERE KEY = 'DEFERMENT_OVERLAP'
                  UNION ALL
                  SELECT value_string, daytime
                  FROM ctrl_property
                  WHERE KEY = 'DEFERMENT_OVERLAP')
           ORDER BY daytime DESC)
    WHERE ROWNUM < 2;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  IF lv2_default_value = 'CONSTRAINT' THEN
    IF NVL(p_event_type,p_parent_event_type) = 'CONSTRAINT' THEN
      SELECT COUNT(*) INTO ln_count
      FROM FCST_WELL_EVENT fwe
      WHERE fwe.event_id = p_object_id
      AND fwe.event_no <> p_event_no
      AND fwe.event_type ='DOWN'
      AND (fwe.end_date > p_daytime  OR fwe.end_date IS null)
      AND (fwe.daytime  < p_end_date OR p_end_date   IS NULL);
    ELSIF NVL(p_event_type,p_parent_event_type) = 'DOWN' THEN
      SELECT COUNT(*) INTO ln_count
      FROM FCST_WELL_EVENT fwe
      WHERE fwe.event_id = p_object_id
      AND fwe.event_no <> p_event_no
      AND fwe.event_type IN ('DOWN','CONSTRAINT')
      AND (fwe.end_date > p_daytime  OR fwe.end_date IS NULL)
      AND (fwe.daytime  < p_end_date OR p_end_date   IS NULL);
    END IF;
  ELSIF(lv2_default_value = 'DOWN_CONSTRAINT') THEN
    IF NVL(p_event_type,p_parent_event_type) = 'DOWN' THEN
      SELECT COUNT(*) INTO ln_count
      FROM FCST_WELL_EVENT fwe
      WHERE fwe.event_id = p_object_id
      AND fwe.event_no <> p_event_no
      AND fwe.event_type ='DOWN'
      AND (fwe.end_date > p_daytime  OR fwe.end_date IS NULL)
      AND (fwe.daytime  < p_end_date OR p_end_date   IS NULL);
    END IF;
  ELSIF(lv2_default_value = 'N') THEN
    SELECT COUNT(*) INTO ln_count
    FROM FCST_WELL_EVENT fwe
    WHERE fwe.event_id = p_object_id
    AND fwe.event_no <> p_event_no
    AND fwe.event_type IN ('DOWN','CONSTRAINT')
    AND (fwe.end_date > p_daytime  OR fwe.end_date IS NULL)
    AND (fwe.daytime  < p_end_date OR p_end_date   IS NULL);
  END IF;

  IF(ln_count>0) THEN
    RAISE_APPLICATION_ERROR(-20226, 'An event must not overlap with the existing event period.');
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
  p_object_id     VARCHAR2 DEFAULT NULL,
  p_child_count   NUMBER DEFAULT 1)

RETURN NUMBER
--</EC-DOC>
IS

  ln_return_val NUMBER;
  ln_loss_volume NUMBER;
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

    BEGIN
      SELECT DECODE(p_phase,
            'OIL',OIL_LOSS_VOLUME,
            'GAS',GAS_LOSS_VOLUME,
            'COND',COND_LOSS_VOLUME,
            'WATER',WATER_LOSS_VOLUME,
            'WAT_INJ',WATER_INJ_LOSS_VOLUME,
            'STEAM_INJ',STEAM_INJ_LOSS_VOLUME,
            'GAS_INJ',GAS_INJ_LOSS_VOLUME,
            'DILUENT',DILUENT_LOSS_VOLUME,
            'GAS_LIFT',GAS_LIFT_LOSS_VOLUME,
            'CO2_INJ', CO2_INJ_LOSS_VOLUME) LOSS_VOLUME
      INTO ln_loss_volume
      FROM FCST_WELL_EVENT
      WHERE event_no  = p_event_no;
    EXCEPTION
      WHEN OTHERS THEN
        ln_loss_volume:=NULL;
    END;

    IF (ln_loss_volume IS NULL AND p_child_count = 0) THEN
      ln_return_val:=getEventLossNoChildEvent(p_event_no,p_phase);
    END IF;
  END IF;

  RETURN NVL(ln_loss_volume,ln_return_val);
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
    'OIL',       ecbp_well_potential.findOilProductionPotential(fwe.event_id, fwe.parent_daytime),
    'GAS',       ecbp_well_potential.findGasProductionPotential(fwe.event_id, fwe.parent_daytime),
    'COND',      ecbp_well_potential.findConProductionPotential(fwe.event_id, fwe.parent_daytime),
    'WATER',     ecbp_well_potential.findWatProductionPotential(fwe.event_id, fwe.parent_daytime),
    'WAT_INJ',   ecbp_well_potential.findWatInjectionPotential(fwe.event_id, fwe.parent_daytime),
    'STEAM_INJ', ecbp_well_potential.findSteamInjectionPotential(fwe.event_id, fwe.parent_daytime),
    'GAS_INJ',   ecbp_well_potential.findGasInjectionPotential(fwe.event_id, fwe.parent_daytime),
    'DILUENT',   ecbp_well_potential.findDiluentPotential(fwe.event_id, fwe.parent_daytime),
    'GAS_LIFT',  ecbp_well_potential.findGasLiftPotential(fwe.event_id, fwe.parent_daytime),
    'CO2_INJ',   ecbp_well_potential.findCo2InjectionPotential(fwe.event_id, fwe.parent_daytime))) sum_vol
    FROM (SELECT DISTINCT(event_id),parent_daytime
      FROM fcst_well_event fwe2
      WHERE fwe2.parent_event_no = p_event_no
      AND fwe2.deferment_type = 'GROUP_CHILD'
    )fwe;

  lv2_deferment_type VARCHAR2(32);
  lv2_parent_object_id VARCHAR2(32);
  ld_parent_daytime DATE;
  lv2_object_id VARCHAR2(32);
  ld_daytime DATE;

BEGIN

  BEGIN
    SELECT fwe_1.event_id, fwe_1.day, fwe_1.deferment_type, fwe_1.parent_object_id, fwe_1.parent_daytime
    INTO lv2_object_id,ld_daytime,lv2_deferment_type,lv2_parent_object_id,ld_parent_daytime
    FROM FCST_WELL_EVENT fwe_1
    WHERE fwe_1.event_no = p_event_no;
  EXCEPTION
    WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20226, 'An error occurred while fetching data for event no- '||p_event_no);
  END;

  IF lv2_deferment_type ='SINGLE' or lv2_deferment_type ='GROUP_CHILD' THEN
    IF p_potential_attribute = 'OIL' then
      ln_return_val := ecbp_well_potential.findOilProductionPotential(lv2_object_id,ld_daytime);
    ELSIF  p_potential_attribute = 'GAS' then
      ln_return_val := ecbp_well_potential.findGasProductionPotential(lv2_object_id,ld_daytime);
    ELSIF p_potential_attribute = 'WAT_INJ' then
      ln_return_val := ecbp_well_potential.findWatInjectionPotential(lv2_object_id,ld_daytime);
    ELSIF p_potential_attribute = 'STEAM_INJ' then
      ln_return_val := ecbp_well_potential.findSteamInjectionPotential(lv2_object_id,ld_daytime);
    ELSIF  p_potential_attribute = 'COND' then
      ln_return_val := ecbp_well_potential.findConProductionPotential(lv2_object_id,ld_daytime);
    ELSIF p_potential_attribute = 'GAS_INJ' then
      ln_return_val := ecbp_well_potential.findGasInjectionPotential(lv2_object_id,ld_daytime);
    ELSIF  p_potential_attribute = 'WATER' then
      ln_return_val := ecbp_well_potential.findWatProductionPotential(lv2_object_id,ld_daytime);
    ELSIF  p_potential_attribute = 'DILUENT' then
      ln_return_val := ecbp_well_potential.findDiluentPotential(lv2_object_id,ld_daytime);
    ELSIF  p_potential_attribute = 'GAS_LIFT' then
      ln_return_val := ecbp_well_potential.findGasLiftPotential(lv2_object_id,ld_daytime);
    ELSIF  p_potential_attribute = 'CO2_INJ' then
      ln_return_val := ecbp_well_potential.findCo2InjectionPotential(lv2_object_id,ld_daytime);
    END IF;
  ELSIF lv2_deferment_type  ='GROUP' THEN
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
  p_event_no          NUMBER,
  p_event_attribute   VARCHAR2,
  p_deferment_type    VARCHAR2)

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
        ln_RateOrVol       := getEventLossRate(p_event_no, p_event_attribute);
        IF ln_RateOrVol IS NOT NULL THEN
          ln_TotEventLossRate := nvl(ln_TotEventLossRate,0) + ln_RateOrVol;
        END IF;
    END IF;

    --with child
    IF ln_child_count > 0 THEN
      FOR r_child_event IN c_fcst_event  LOOP
        ln_RateOrVol       := getEventLossRate(r_child_event.event_no, p_event_attribute);
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
-----------------------------------------------------------------------------------------------------
-- Function       : getEventLossRate                                                   --
-- Description    : Returns Event Loss Rate
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
FUNCTION getEventLossRate (
  p_event_no        NUMBER,
  p_event_attribute VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS

  ln_diff       NUMBER := 0;
  ln_return_val NUMBER;

  CURSOR c_fcst_deferment_event (cp_event_no NUMBER)  IS
  SELECT fwe.daytime, fwe.end_date, fwe.oil_loss_rate, fwe.gas_loss_rate, fwe.cond_loss_rate, fwe.water_loss_rate, fwe.diluent_loss_rate, fwe.gas_lift_loss_Rate,
  fwe.water_inj_loss_rate, fwe.gas_inj_loss_rate, fwe.steam_inj_loss_rate, fwe.co2_inj_loss_rate,
  fwe.oil_loss_volume, fwe.gas_loss_volume, fwe.cond_loss_volume, fwe.water_loss_volume, fwe.diluent_loss_volume, fwe.gas_lift_loss_volume,
  fwe.water_inj_loss_volume, fwe.gas_inj_loss_volume, fwe.steam_inj_loss_volume, fwe.co2_inj_loss_volume
  FROM fcst_well_event fwe
  WHERE fwe.event_no = cp_event_no;

BEGIN
  ln_diff := NULL;
  ln_return_val := Ue_Deferment.getEventLossRate(p_event_no,p_event_attribute);
  IF ln_return_val IS NULL THEN
    FOR r_fcst_event_loss_rate IN c_fcst_deferment_event(p_event_no) LOOP
      IF r_fcst_event_loss_rate.end_date IS NOT NULL then
        ln_diff := abs(r_fcst_event_loss_rate.end_date- r_fcst_event_loss_rate.daytime);
        IF p_event_attribute = 'OIL' and r_fcst_event_loss_rate.oil_loss_volume IS NOT NULL THEN
          ln_return_val := r_fcst_event_loss_rate.oil_loss_volume;
        ELSIF p_event_attribute = 'OIL' THEN
          ln_return_val := ln_diff *  nvl(r_fcst_event_loss_rate.oil_loss_rate, getPotentialRate(p_event_no, p_event_attribute));
        END IF;
        IF p_event_attribute = 'GAS' and r_fcst_event_loss_rate.gas_loss_volume IS NOT NULL THEN
          ln_return_val := r_fcst_event_loss_rate.gas_loss_volume;
        ELSIF p_event_attribute = 'GAS' THEN
          ln_return_val := ln_diff *  nvl(r_fcst_event_loss_rate.gas_loss_rate, getPotentialRate(p_event_no, p_event_attribute));
        END IF;
        IF  p_event_attribute = 'COND' and r_fcst_event_loss_rate.cond_loss_volume IS NOT NULL THEN
          ln_return_val := r_fcst_event_loss_rate.cond_loss_volume;
        ELSIF  p_event_attribute = 'COND' THEN
          ln_return_val := ln_diff *  nvl(r_fcst_event_loss_rate.cond_loss_rate, getPotentialRate(p_event_no, p_event_attribute));
        END IF;
        IF p_event_attribute = 'WATER' and r_fcst_event_loss_rate.water_loss_volume IS NOT NULL THEN
          ln_return_val := r_fcst_event_loss_rate.water_loss_volume;
        ELSIF p_event_attribute = 'WATER' THEN
          ln_return_val := ln_diff *  nvl(r_fcst_event_loss_rate.water_loss_rate, getPotentialRate(p_event_no, p_event_attribute));
        END IF;
        IF  p_event_attribute = 'DILUENT' and r_fcst_event_loss_rate.diluent_loss_volume IS NOT NULL THEN
          ln_return_val := r_fcst_event_loss_rate.diluent_loss_volume;
        ELSIF  p_event_attribute = 'DILUENT' THEN
          ln_return_val := ln_diff *  nvl(r_fcst_event_loss_rate.diluent_loss_rate, getPotentialRate(p_event_no, p_event_attribute));
        END IF;
        IF  p_event_attribute = 'GAS_LIFT' and r_fcst_event_loss_rate.gas_lift_loss_volume IS NOT NULL THEN
          ln_return_val := r_fcst_event_loss_rate.gas_lift_loss_volume;
        ELSIF  p_event_attribute = 'GAS_LIFT' THEN
          ln_return_val := ln_diff *  nvl(r_fcst_event_loss_rate.gas_lift_loss_Rate, getPotentialRate(p_event_no, p_event_attribute));
        END IF;
        IF p_event_attribute = 'WAT_INJ' and r_fcst_event_loss_rate.water_inj_loss_volume IS NOT NULL THEN
          ln_return_val := r_fcst_event_loss_rate.water_inj_loss_volume;
        ELSIF  p_event_attribute = 'WAT_INJ' THEN
          ln_return_val := ln_diff *  nvl(r_fcst_event_loss_rate.water_inj_loss_rate, getPotentialRate(p_event_no, p_event_attribute));
        END IF;
        IF  p_event_attribute = 'GAS_INJ' and r_fcst_event_loss_rate.gas_inj_loss_volume IS NOT NULL THEN
          ln_return_val := r_fcst_event_loss_rate.gas_inj_loss_volume;
        ELSIF  p_event_attribute = 'GAS_INJ' THEN
          ln_return_val := ln_diff *  nvl(r_fcst_event_loss_rate.gas_inj_loss_rate, getPotentialRate(p_event_no, p_event_attribute));
        END IF;
        IF p_event_attribute = 'STEAM_INJ' and r_fcst_event_loss_rate.steam_inj_loss_volume IS NOT NULL THEN
          ln_return_val := r_fcst_event_loss_rate.steam_inj_loss_volume;
        ELSIF  p_event_attribute = 'STEAM_INJ' THEN
          ln_return_val := ln_diff *  nvl(r_fcst_event_loss_rate.steam_inj_loss_rate, getPotentialRate(p_event_no, p_event_attribute));
        END IF;
        IF p_event_attribute = 'CO2_INJ' and r_fcst_event_loss_rate.co2_inj_loss_volume IS NOT NULL THEN
          ln_return_val := r_fcst_event_loss_rate.co2_inj_loss_volume;
        ELSIF  p_event_attribute = 'CO2_INJ' THEN
          ln_return_val := ln_diff *  nvl(r_fcst_event_loss_rate.co2_inj_loss_rate, getPotentialRate(p_event_no, p_event_attribute));
        END IF;
      END IF;
    END LOOP;
  END IF;
  RETURN ln_return_val;
END getEventLossRate;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getEventLossNoChildEvent                                                       --
-- Description    : Returns Event Loss Volume for without Child records.
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : fcst_well_event
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION getEventLossNoChildEvent (
  p_event_no        NUMBER,
  p_event_attribute VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS

  ln_diff     NUMBER := 0;
  ln_return_val NUMBER;

  CURSOR c_fcst_well_event (cp_event_no NUMBER)  IS
    SELECT fwe.daytime, fwe.end_date, fwe.oil_loss_rate, fwe.gas_loss_rate, fwe.cond_loss_rate, fwe.water_inj_loss_rate,
    fwe.gas_inj_loss_rate, fwe.steam_inj_loss_rate,
    fwe.water_loss_rate,fwe.diluent_loss_rate,fwe.gas_lift_loss_Rate, fwe.co2_inj_loss_rate, fwe.object_type, fwe.event_id
    FROM fcst_well_event fwe
    WHERE event_no = cp_event_no;

  lv2_open_end_event  VARCHAR2(1);
  ld_day_light_start_date DATE;
  ld_day_light_end_date DATE;
  ln_COUNT NUMBER;
  ln_diff_hours NUMBER :=0;
  ln_MaxOnHrs NUMBER;
  ln_daylight_present NUMBER;
  ld_trunc_daytime DATE;
  ld_nvl_end_date DATE;

BEGIN

  lv2_open_end_event:=COALESCE(ecdp_ctrl_property.getSystemProperty('DEFERMENT_OPEN_EVENT_CALC',TRUNC(Ecdp_Timestamp.getCurrentSysdate())),'Y');

  FOR r_fcst_event_loss_rate IN c_fcst_well_event(p_event_no) LOOP

    ld_trunc_daytime:= TRUNC(r_fcst_event_loss_rate.daytime);
    ld_nvl_end_date := COALESCE(r_fcst_event_loss_rate.end_date,
                                Ecdp_Productionday.getProductionDayStart(r_fcst_event_loss_rate.object_type,
                                                                         r_fcst_event_loss_rate.event_id,
                                                                         TRUNC(Ecdp_Timestamp.getCurrentSysdate,'DD') - 1));
    --Check daylight saving is available for deferment event date.
    SELECT COUNT(*) INTO ln_daylight_present
    FROM pday_dst
    WHERE daytime BETWEEN ld_trunc_daytime AND TRUNC(ld_nvl_end_date);

    IF lv2_open_end_event='Y' THEN--A
      --if daylight data is present in pday_dst for deferment event , then calculate maximum hrs for deferment event daytime.
      IF ln_daylight_present<>0 THEN--D
        BEGIN

          SELECT Daytime,MaxOnHrs INTO ld_day_light_start_date,ln_MaxOnHrs
          FROM (
                SELECT Ecdp_Timestamp.getNumHours(r_fcst_event_loss_rate.object_type,r_fcst_event_loss_rate.event_id, ld_trunc_daytime+LEVEL-1) MaxOnHrs,
                      ld_trunc_daytime+LEVEL-1 Daytime
                FROM CTRL_DB_VERSION WHERE DB_VERSION=1
                CONNECT BY LEVEL <=TRUNC(ld_nvl_end_date) - ld_trunc_daytime +1
               )
          WHERE MaxOnHrs<>24;

        EXCEPTION
          WHEN OTHERS THEN
            ld_day_light_start_date:=NULL;
        END;

        IF (ld_day_light_start_date IS NOT NULL) THEN--C
          ld_day_light_start_date := ld_day_light_start_date + (ecdp_productionday.getproductiondayoffset(r_fcst_event_loss_rate.object_type,r_fcst_event_loss_rate.event_id,ld_day_light_start_date))/24;
          ld_day_light_end_date := ld_day_light_start_date+1;

          SELECT COUNT(*) INTO ln_COUNT
          FROM CTRL_DB_VERSION
          WHERE DB_VERSION=1 AND ld_day_light_start_date BETWEEN r_fcst_event_loss_rate.daytime AND ld_nvl_end_date
          AND ld_day_light_end_date BETWEEN r_fcst_event_loss_rate.daytime AND ld_nvl_end_date ;

          IF ln_COUNT=1 THEN--B
            ln_diff_hours:=(24-ln_MaxOnHrs)/24;
          END IF;--B
        END IF;--C
      END IF;--D
      ln_diff := ABS(ld_nvl_end_date- r_fcst_event_loss_rate.daytime)-ln_diff_hours;

    ELSE--A
      IF ln_daylight_present<>0 THEN--D
        BEGIN

          SELECT Daytime,MaxOnHrs INTO ld_day_light_start_date,ln_MaxOnHrs
          FROM (
                SELECT Ecdp_Timestamp.getNumHours(r_fcst_event_loss_rate.object_type,r_fcst_event_loss_rate.event_id, ld_trunc_daytime+LEVEL-1) MaxOnHrs,
                     ld_trunc_daytime+LEVEL-1 Daytime
                FROM CTRL_DB_VERSION WHERE DB_VERSION=1
                CONNECT BY LEVEL <= TRUNC(r_fcst_event_loss_rate.end_date) - ld_trunc_daytime +1
                )
          WHERE MaxOnHrs<>24;

        EXCEPTION
          WHEN OTHERS THEN
            ld_day_light_start_date:=NULL;
        END;

        IF (ld_day_light_start_date IS NOT NULL) THEN--C
          ld_day_light_start_date := ld_day_light_start_date+(ecdp_productionday.getproductiondayoffset(r_fcst_event_loss_rate.object_type,r_fcst_event_loss_rate.event_id,ld_day_light_start_date))/24;
          ld_day_light_end_date := ld_day_light_start_date+1;

          SELECT COUNT(*) INTO ln_COUNT
          FROM CTRL_DB_VERSION
          WHERE DB_VERSION=1 AND ld_day_light_start_date BETWEEN r_fcst_event_loss_rate.daytime AND r_fcst_event_loss_rate.end_date
          AND ld_day_light_end_date BETWEEN r_fcst_event_loss_rate.daytime AND r_fcst_event_loss_rate.end_date ;

          IF ln_COUNT=1 THEN--B
            ln_diff_hours:=(24-ln_MaxOnHrs)/24;
          END IF;--B

        END IF;--C
      END IF;--D

        ln_diff := ABS(r_fcst_event_loss_rate.end_date- r_fcst_event_loss_rate.daytime)-ln_diff_hours;

    END IF;--A

    IF p_event_attribute = 'OIL' THEN
      ln_return_val := ln_diff *  r_fcst_event_loss_rate.oil_loss_rate;
    END IF;

    IF p_event_attribute = 'GAS' THEN
      ln_return_val := ln_diff *  r_fcst_event_loss_rate.gas_loss_rate;
    END IF;

    IF p_event_attribute = 'WAT_INJ' THEN
      ln_return_val := ln_diff * r_fcst_event_loss_rate.water_inj_loss_rate;
    END IF;

    IF p_event_attribute = 'STEAM_INJ' THEN
      ln_return_val := ln_diff *  r_fcst_event_loss_rate.steam_inj_loss_rate;
    END IF;

    IF  p_event_attribute = 'COND' THEN
      ln_return_val := ln_diff * r_fcst_event_loss_rate.cond_loss_rate;
    END IF;

    IF  p_event_attribute = 'GAS_INJ' THEN
      ln_return_val := ln_diff *  r_fcst_event_loss_rate.gas_inj_loss_rate;
    END IF;

    IF p_event_attribute = 'WATER' THEN
      ln_return_val := ln_diff * r_fcst_event_loss_rate.water_loss_rate;
    END IF;

    IF  p_event_attribute = 'DILUENT' THEN
      ln_return_val := ln_diff * r_fcst_event_loss_rate.diluent_loss_rate;
    END IF;

    IF  p_event_attribute = 'GAS_LIFT' THEN
      ln_return_val := ln_diff * r_fcst_event_loss_rate.gas_lift_loss_Rate;
    END IF;

    IF  p_event_attribute = 'CO2_INJ' THEN
      ln_return_val := ln_diff * r_fcst_event_loss_rate.co2_inj_loss_rate;
    END IF;

  END LOOP;

  RETURN ln_return_val;
END getEventLossNoChildEvent;

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

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getParentEventLossVolume                                                   --
-- Description    : Returns Parent Event Loss Volume
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
FUNCTION getParentEventLossVolume (
  p_event_no          NUMBER,
  p_event_attribute   VARCHAR2,
  p_deferment_type    VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS

  ln_return_val           NUMBER;
  ln_child_count          NUMBER;
  ln_Loss_Vol             NUMBER;
  ln_TotEventLossVolume   NUMBER;

  CURSOR c_fcst_well_event  IS
  SELECT fwe.event_id, fwe.event_no
  FROM FCST_WELL_EVENT fwe
  WHERE fwe.parent_event_no = p_event_no;

BEGIN

  ln_child_count := countChildEvent(p_event_no);
  IF  p_deferment_type  = 'GROUP' THEN
    --not with child
    IF ln_child_count = 0 THEN
      ln_Loss_Vol   := getEventLossVolume(p_event_no, p_event_attribute, NULL, ln_child_count);
      IF ln_Loss_Vol IS NOT NULL THEN
        ln_TotEventLossVolume := nvl(ln_TotEventLossVolume,0) + ln_Loss_Vol;
      END IF;
    END IF;

    --with child
    IF ln_child_count > 0 THEN
      FOR r_fwe_child_event IN c_fcst_well_event  LOOP
        ln_Loss_Vol := getEventLossVolume(r_fwe_child_event.event_no, p_event_attribute, NULL, 1);
        IF ln_Loss_Vol IS NOT NULL THEN
          ln_TotEventLossVolume := nvl(ln_TotEventLossVolume,0) + ln_Loss_Vol;
        END IF;
      END LOOP;
    END IF;
    ln_return_val := ln_TotEventLossVolume;
  ELSE
    ln_return_val := getEventLossVolume(p_event_no, p_event_attribute,NULL, 1);
  END IF;

  RETURN ln_return_val;
END getParentEventLossVolume;

END EcBp_Forecast_Event;