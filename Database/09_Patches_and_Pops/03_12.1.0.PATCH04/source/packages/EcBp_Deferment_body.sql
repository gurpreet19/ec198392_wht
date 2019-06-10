CREATE OR REPLACE PACKAGE BODY EcBp_Deferment IS

/****************************************************************
** Package        :  EcBp_Deferment, body part
**
** $Revision: 1.1 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Equipment and Well Deferment.
** Documentation  :  www.energy-components.com
**
** Created  : 01.07.2014  Wong Kai Chun
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 24-06-2014 wonggkai ECPD-28018: Create checkIfEventOverlaps.
** 21-07-2014 deshpadi ECPD-26044: Create checkValidChildPeriod
** 21-07-2014 deshpadi ECPD-26044: Create getEventLossRate
** 21-07-2014 deshpadi ECPD-26044: Create getPotentialRate
** 21-07-2014 deshpadi ECPD-26044: Create getParentEventLossRate
** 21-07-2014 deshpadi ECPD-26044: Create deleteChildEvent
** 21-07-2014 deshpadi ECPD-26044: Create countChildEvent
** 21-07-2014 deshpadi ECPD-26044: Create checkChildEndDate
** 25-07-2014 wonggkai ECPD-26559: Add checking on ctrl_property_meta and ctrl_property.
** 27-08-2014 leongwen ECPD-28035: Modified getEventLossRate, getPotentialRate
** 09-09-2014 kumarsur ECPD-28473: Modified getEventLossRate to getEventLossVolume.
** 30-09-2014 wonggkai ECPD-28719: Modified checkIfEventOverlaps to returns single row record.
** 10-10-2014 kumarsur ECPD-28473: Modified getEventLossVolume.
** 13-10-2014 choooshu ECPD-28958: Optimize countChildEvent by not using cursor.
** 16-10-2014 shindani ECPD-28601: Added getPlannedVolumes,getActualVolumes,getActualProducedVolumes,getAssignedDeferVolumes functions.
** 28-10-2014 kumarsur ECPD-29026: Create chkDefermentConstraintLock.
** 14-11-2014 wonggkai ECPD-28911: Added getCommonReasonCodeSetting.
** 26-11-2014 abdulmaw ECPD-29389: Create calcWellProdLossDay to calculate Loss Volume per day for a well when Deferment version is PD.0020
** 03-12-2014 dhavaalo ECPD-29569: Modified getAssignedDeferVolumes to fetch data on basis of p_object_id
** 06-01-2015 abdulmaw ECPD-29236: Modified chkDefermentConstraintLock to support production day offset locking
** 22-01-2015 kumarsur ECPD-29407: Modified checkIfEventOverlaps to check only for event type = DOWN.
** 03-02-2015 dhavaalo ECPD-29754: Create calcWellCorrActionVolume to calculate corrective action volume for Deferment version[PD.0020]
** 09-03-2015 dhavaalo ECPD-29807: Changes to improve Well Deferment Performance. Code Formatting done
** 20-04-2015 choooshu ECPD-29830: Modified getPlannedVolumes,getActualVolumes,getActualProducedVolumes,getAssignedDeferVolumes functions to support end date.
** 20-04-2015 choooshu ECPD-29830: Added getMthPlannedVolumes,getMthActualVolumes,getMthAssignedDeferVolumes,getScheduledDeferVolumes for monthly deferment graph.
** 21-04-2015 deshpadi ECPD-30358: Modified getPotentialRate to get the potential rates for the GROUP_CHILD events. 
** 25-09-2015 kumarsur ECPD-31862: Modified getPlannedVolumes.
** 29-04-2016 chaudgau ECPD-28571: Modified chkDefermentConstraintLock to permit change of end_date unless defined end date value falls in locked month
** 05-10-2016 dhavaalo ECPD-30185: New function added getEventLossVolume to calculate event loss for deferment event.
** 05-10-2016 dhavaalo ECPD-30185: New function added getEventLossRate to calculate event loss rate for deferment event.
** 05-10-2016 dhavaalo ECPD-30185: Modified function calcWellCorrActionVolume
** 05-10-2016 dhavaalo ECPD-30185: Modified getPlannedVolumes to support DILUENT and GAS_LIFT
** 05-10-2016 dhavaalo ECPD-31944: Modified getEventLossVolume to retrun loss volume if available.
** 25-10-2016 dhavaalo ECPD-31944: New function added getEventLossNoChildEvent to calculate event loss volume for deferment event.
** 12-05-2017 jainnraj ECPD-42563: Renamed function call getProdForecastId to getProdScenarioId.
** 07.08.2017 jainnraj ECPD-46835: Modified procedure checkIfEventOverlaps,checkValidChildPeriod,getEventLossVolume,getPotentialRate,calcWellCorrActionVolume to correct the error message.
** 04-08-2017 dhavaalo ECPD-40228: Modified checkIfEventOverlaps.
** 21-08-2017 dhavaalo ECPD-48376: Modified getEventLossNoChildEvent.The Event Loss Volume calculation for open ended event should take production day into consideration.
** 01-09-2017 dhavaalo ECPD-48425: Modified getEventLossNoChildEvent.
** 11-10-2017 leongwen ECPD-49613: New procedure chkDefermentDayLock for Deferment Day
** 27-10-2017 kashisag ECPD-50026: Modified procedures and functions that are using the condition check with well_deferment table with extra condition to check with class_name is equal to WELL_DEFERMENT , WELL_DEFERMENT_CHILD. 
** 30-10-2017 leongwen ECPD-50026: created new procedure checkIfEventDayOverlaps for PD.0023 Deferment Day screen use.
** 08-11-2017 dhavaalo ECPD-50429: checkIfEventOverlaps new default input parameter added.
** 17-11-2017 dhavaalo ECPD-45043: Remove reference of well_equip_downtime table. Removed un-used variables.
** 28-12-2017 jainnraj ECPD-31884: Removed all the calls where potential_method is Ecdp_Calc_Method.FORECAST and modified getPlannedVolumes to remove call of Ecbp_Productionforecast.getRecentProdForecastNo
** 17-01-2018 singishi ECPD-47302: Rename table well_deferment to deferment_event
** 12.02.2018 leongwen ECPD-52636: Moved function deduct1secondYn to package EcBp_Deferment here.
** 28.02.2018 leongwen ECPD-45873: Added function getParentEventLossMassRate, getEventLossMassRate, getParentEventLossMass, getEventLossMass, getEventLossMassNoChildEvent and getPotentialMassRate.
** 21.03.2018 leongwen ECPD-45873: Modified function getEventLossMass and getEventLossMassNoChildEvent to maintain the logic for oil, gas, cond and water phase only.
** 02.05.2018 shindani ECPD-54698: Modified function getPotentialRate,getPotentialMassRate to show correct potential rate based on ditsinct object_id and parent_daytime. 
** 03.05.2018 jainnraj ECPD-54031: Modified procedure checkIfEventOverlaps to check for overlapping records, if the record is added from database. 
** 17.05.2018 leongwen ECPD-55952: Modified procedure chkDefermentConstraintLock and chkDefermentDayLock to pass in the right type of date value to EcDp_ProductionDay.getProductionDayOffset based on p_operation type value check
** 20.08.2018 khatrnit ECPD-53583: Added function getParentComment to get parent comment for the child deferment event.
** 19.10.2018 kaushaak ECPD-59504: Modified getPotentialRate.
** 11.04.2019 leongwen ECPD-65918: Modified function getPotentialRate to use variable ld_day to hold the wed_1.day column value instead of ld_daytime.
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      :checkIfEventOverlaps
-- Description    : Checks if overlapping event exists.
--Customer Scenario
--Value to Configure
--1.CONSTRAINT
-- Allow Constraints overlapping only. 
-- Overlapping between down events are not allowed.
-- Overlapping between down and constraint events are not allowed. 
--2.DOWN_CONSTRAINT
-- Allow overlapping between down-Constraints events. 
-- Allow overlapping between Constraints overlapping. 
-- Don't allow overlapping between down-down events
--3. Y
--Allow all types of overlapping
--4. N
--Do not allow types of overlapping
--
--
-- Preconditions  :
-- Postconditions : Raises an application error if overlapping event exists.
--
-- Using tables   : WELL_DEFERMENT
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
PROCEDURE  checkIfEventOverlaps(p_object_id VARCHAR2, p_daytime DATE, p_end_date DATE, p_event_type VARCHAR2, p_event_no NUMBER, p_parent_event_no NUMBER DEFAULT 1)
--</EC-DOC>
IS
  v_count NUMBER :=0;
  lv_default_value VARCHAR2(30);
  p_parent_event_type VARCHAR2(10);

BEGIN
  IF p_event_type IS NULL THEN
    p_parent_event_type:= ec_Deferment_event.event_type(p_parent_event_no);
  END IF;
  
  BEGIN
    select default_value
    into lv_default_value
    from (select default_value
          from (select default_value_string default_value,to_date('01-01-1990', 'DD-MM-YYYY') daytime
                FROM ctrl_property_meta
                where key = 'DEFERMENT_OVERLAP'
                UNION ALL
                select value_string, daytime
                from ctrl_property
                where key = 'DEFERMENT_OVERLAP')
          where daytime <= p_daytime
          order by daytime desc)
    where rownum < 2;
  EXCEPTION
    WHEN OTHERS THEN
       NULL;
  END;

  IF lv_default_value = 'CONSTRAINT' THEN
    
    IF NVL(p_event_type,p_parent_event_type) = 'CONSTRAINT' THEN
         SELECT COUNT(*) INTO v_count
         FROM DEFERMENT_EVENT wd
         WHERE wd.object_id = p_object_id
         AND (wd.event_no <> p_event_no OR p_event_no IS NULL)
         AND  wd.event_type ='DOWN'
         AND (wd.end_date > p_daytime OR wd.end_date IS NULL)
         AND  (wd.daytime < p_end_date OR p_end_date IS NULL)
         AND wd.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');
    ELSIF NVL(p_event_type,p_parent_event_type) = 'DOWN' THEN
       SELECT COUNT(*) INTO v_count
         FROM DEFERMENT_EVENT wd
         WHERE wd.object_id = p_object_id
         AND (wd.event_no <> p_event_no OR p_event_no IS NULL)
         AND  wd.event_type IN ('DOWN','CONSTRAINT')
         AND (wd.end_date > p_daytime OR wd.end_date IS NULL)
         AND  (wd.daytime < p_end_date OR p_end_date IS NULL)
         AND wd.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');       
    END IF;
       
  ELSIF(lv_default_value = 'DOWN_CONSTRAINT') THEN
  
    IF NVL(p_event_type,p_parent_event_type)='DOWN' THEN
      SELECT COUNT(*) INTO v_count
      FROM DEFERMENT_EVENT wd
      WHERE wd.object_id = p_object_id
      AND (wd.event_no <> p_event_no OR p_event_no IS NULL)
      AND  wd.event_type ='DOWN'
      AND (wd.end_date > p_daytime OR wd.end_date IS NULL)
      AND  (wd.daytime < p_end_date OR p_end_date IS NULL)
      AND wd.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');
    END IF;
  
    ELSIF(lv_default_value = 'N') THEN

      SELECT COUNT(*) INTO v_count
      FROM DEFERMENT_EVENT wd
      WHERE wd.object_id = p_object_id
      AND (wd.event_no <> p_event_no OR p_event_no IS NULL)
      AND  wd.event_type  IN ('DOWN','CONSTRAINT')
      AND (wd.end_date > p_daytime OR wd.end_date IS NULL)
      AND  (wd.daytime < p_end_date OR p_end_date IS NULL)
      AND wd.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');

  END IF;
  
  IF(v_count>0) THEN
    RAISE_APPLICATION_ERROR(-20226, 'An event must not overlap with existing event period.');
  END IF;
END checkIfEventOverlaps;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      :checkIfEventDayOverlaps
-- Description    : Checks if overlapping event exists in PD.0023 Deferment Day
--Customer Scenario
--Value to Configure
--1.CONSTRAINT
-- Allow Constraints overlapping only. 
-- Overlapping between down events are not allowed.
-- Overlapping between down and constraint events are not allowed. 
--2.DOWN_CONSTRAINT
-- Allow overlapping between down-Constraints events. 
-- Allow overlapping between Constraints overlapping. 
-- Don't allow overlapping between down-down events
--3. Y
--Allow all types of overlapping
--4. N
--Do not allow types of overlapping
--
--
-- Preconditions  :
-- Postconditions : Raises an application error if overlapping event exists.
--
-- Using tables   : WELL_DEFERMENT
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
PROCEDURE  checkIfEventDayOverlaps(p_object_id VARCHAR2, p_daytime DATE, p_end_date DATE, p_event_type VARCHAR2, p_event_no NUMBER)
--</EC-DOC>
IS
  v_count NUMBER :=0;
  lv_default_value VARCHAR2(30);

BEGIN
  
  BEGIN
    select default_value
    into lv_default_value
    from (select default_value
          from (select default_value_string default_value,to_date('01-01-1990', 'DD-MM-YYYY') daytime
                FROM ctrl_property_meta
                where key = 'DEFERMENT_OVERLAP'
                UNION ALL
                select value_string, daytime
                from ctrl_property
                where key = 'DEFERMENT_OVERLAP')
          where daytime <= p_daytime
          order by daytime desc)
    where rownum < 2;
  EXCEPTION
    WHEN OTHERS THEN
	    NULL;
  END;

  IF lv_default_value = 'CONSTRAINT' THEN
    
    IF p_event_type = 'CONSTRAINT' THEN
      SELECT COUNT(*) INTO v_count
      FROM DEFERMENT_EVENT wd
      WHERE wd.object_id = p_object_id
      AND wd.event_no <> p_event_no
      AND  wd.event_type ='DOWN'
      AND (wd.end_date > p_daytime OR wd.end_date IS NULL)
      AND  (wd.daytime < p_end_date OR p_end_date IS NULL)
      AND wd.class_name IN ('DEFERMENT_EVENT');
    ELSIF p_event_type = 'DOWN' THEN
      SELECT COUNT(*) INTO v_count
      FROM DEFERMENT_EVENT wd
      WHERE wd.object_id = p_object_id
      AND wd.event_no <> p_event_no
      AND  wd.event_type IN ('DOWN','CONSTRAINT')
      AND (wd.end_date > p_daytime OR wd.end_date IS NULL)
      AND  (wd.daytime < p_end_date OR p_end_date IS NULL)
      AND wd.class_name IN ('DEFERMENT_EVENT');       
    END IF;
       
  ELSIF(lv_default_value = 'DOWN_CONSTRAINT') THEN
  
    IF p_event_type='DOWN' THEN
      SELECT COUNT(*) INTO v_count
      FROM DEFERMENT_EVENT wd
      WHERE wd.object_id = p_object_id
      AND wd.event_no <> p_event_no
      AND  wd.event_type ='DOWN'
      AND (wd.end_date > p_daytime OR wd.end_date IS NULL)
      AND  (wd.daytime < p_end_date OR p_end_date IS NULL)
      AND wd.class_name IN ('DEFERMENT_EVENT');
    END IF;
  
  ELSIF(lv_default_value = 'N') THEN

    SELECT COUNT(*) INTO v_count
    FROM DEFERMENT_EVENT wd
    WHERE wd.object_id = p_object_id
    AND wd.event_no <> p_event_no
    AND  wd.event_type  IN ('DOWN','CONSTRAINT')
    AND (wd.end_date > p_daytime OR wd.end_date IS NULL)
    AND  (wd.daytime < p_end_date OR p_end_date IS NULL)
    AND wd.class_name IN ('DEFERMENT_EVENT');

  END IF;
  
  IF(v_count>0) THEN
    RAISE_APPLICATION_ERROR(-20226, 'An event must not overlap with existing event period.');
  END IF;
END checkIfEventDayOverlaps;
  
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkValidChildPeriod
-- Description    : Checks if child period are valid based on the Parent Start date/time and End Date/Tie
--
--
-- Preconditions  :
-- Postconditions : Raises an application error if child's period is not valid.
--
-- Using tables   : deferment_event
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
PROCEDURE checkValidChildPeriod(p_parent_event_no NUMBER ,p_daytime DATE )
--</EC-DOC>
IS

  v_count NUMBER;

  BEGIN
    SELECT count(*) into v_count
    FROM DEFERMENT_EVENT wed
    WHERE (wed.daytime > p_daytime
    OR wed.end_date < p_daytime)
    AND wed.event_no = p_parent_event_no
    AND wed.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');

    IF v_count > 0 THEN
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
-- Using tables   : well_deferment
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
  p_phase VARCHAR2,
  p_object_id   VARCHAR2 DEFAULT NULL,
  p_child_count NUMBER DEFAULT 1)

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
      'GAS_LIFT',sum(deferred_gl_vol)) sum_vol
    FROM well_day_defer_alloc
    WHERE object_id = cp_object_id and event_no = p_event_no;

BEGIN

  ln_return_val := Ue_Deferment.getEventLossVolume(p_event_no,p_phase,p_object_id);
  lv2_object_id := p_object_id;

  IF ln_return_val IS NULL THEN
    IF p_object_id IS NULL THEN
      BEGIN
        SELECT wed.object_id
        INTO lv2_object_id
        FROM DEFERMENT_EVENT wed
        WHERE wed.event_no  = p_event_no
        AND wed.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');
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
            'GAS_LIFT',GAS_LIFT_LOSS_VOLUME) LOSS_VOLUME
      INTO ln_loss_volume
      FROM DEFERMENT_EVENT
      WHERE event_no  = p_event_no
      AND class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');
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
  lv2_scenario_id       VARCHAR2(32);
  lv2_potential_method  VARCHAR2(32);
  lr_fcty_version       FCTY_VERSION%ROWTYPE;
  lv2_class_name        VARCHAR2(32);

  CURSOR c_fcst_fcty_vol(cp_forecast_id VARCHAR2) IS
    SELECT DECODE(p_phase,
      'OIL', ec_fcst_fcty_day.net_oil_rate(p_object_id,p_daytime,cp_forecast_id,'<='),
      'GAS', ec_fcst_fcty_day.gas_rate(p_object_id,p_daytime,cp_forecast_id,'<='),
      'WATER', ec_fcst_fcty_day.water_rate(p_object_id,p_daytime,cp_forecast_id,'<='),
      'COND', ec_fcst_fcty_day.cond_rate(p_object_id,p_daytime,cp_forecast_id,'<='),
      'WAT_INJ', ec_fcst_fcty_day.water_inj_rate(p_object_id,p_daytime,cp_forecast_id,'<='),
      'GAS_INJ', ec_fcst_fcty_day.gas_inj_rate(p_object_id,p_daytime,cp_forecast_id,'<='),
      'STEAM_INJ', ec_fcst_fcty_day.steam_inj_rate(p_object_id,p_daytime,cp_forecast_id,'<=')) planned_vol
    FROM dual;

  CURSOR c_plan_fcty_vol(cp_class_name VARCHAR2) IS
    SELECT DECODE(p_phase,
      'OIL', ec_object_plan.oil_rate(p_object_id,p_daytime,cp_class_name,'<='),
      'GAS', ec_object_plan.gas_rate(p_object_id,p_daytime,cp_class_name,'<='),
      'WATER', ec_object_plan.water_rate(p_object_id,p_daytime,cp_class_name,'<='),
      'COND', ec_object_plan.cond_rate(p_object_id,p_daytime,cp_class_name,'<='),
      'WAT_INJ', ec_object_plan.wat_inj_rate(p_object_id,p_daytime,cp_class_name,'<='),
      'GAS_INJ', ec_object_plan.gas_inj_rate(p_object_id,p_daytime,cp_class_name,'<='),
      'STEAM_INJ', ec_object_plan.steam_inj_rate(p_object_id,p_daytime,cp_class_name,'<='),
      'DILUENT', ec_object_plan.diluent_rate(p_object_id,p_daytime,cp_class_name,'<='),
      'GAS_LIFT', ec_object_plan.gas_lift_Rate(p_object_id,p_daytime,cp_class_name,'<=')) planned_vol
    FROM dual;

BEGIN
  lv2_scenario_id := ecbp_forecast_prod.getProdScenarioId(p_object_id,p_daytime);
  lv2_class_name := EcDp_Objects.getObjClassName(p_object_id);
  IF lv2_class_name IN ('FCTY_CLASS_1','FCTY_CLASS_2') THEN
    lr_fcty_version      := ec_fcty_version.row_by_pk(p_object_id, p_daytime, '<=');
    lv2_potential_method := lr_fcty_version.prod_plan_method;

    IF (lv2_potential_method = Ecdp_Calc_Method.FORECAST_PROD) THEN
      FOR mycur IN c_fcst_fcty_vol(lv2_scenario_id) LOOP
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
FUNCTION getActualVolumes(p_object_id VARCHAR2, p_phase VARCHAR2, p_daytime DATE, p_enddate DATE DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

  ln_actual_volume NUMBER;
  lv2_strm_set VARCHAR2(32);
  ld_enddate DATE;

BEGIN
  
  ld_enddate := nvl(p_enddate, p_daytime);

  IF p_phase = 'OIL' THEN
    lv2_strm_set := 'PD.0005_04';
    ln_actual_volume := getActualProducedVolumes(p_object_id, lv2_strm_set, p_daytime, ld_enddate);

  ELSIF p_phase = 'GAS' THEN
    lv2_strm_set := 'PD.0005_02';
    ln_actual_volume := getActualProducedVolumes(p_object_id, lv2_strm_set, p_daytime, ld_enddate);

  ELSIF p_phase = 'COND' THEN
    lv2_strm_set := 'PD.0005';
    ln_actual_volume := getActualProducedVolumes(p_object_id, lv2_strm_set, p_daytime, ld_enddate);

  ELSIF p_phase = 'WAT_INJ' THEN
    lv2_strm_set := 'PD.0005_06';
    ln_actual_volume := getActualProducedVolumes(p_object_id, lv2_strm_set, p_daytime, ld_enddate);

  ELSIF p_phase = 'GAS_INJ' THEN
    lv2_strm_set := 'PD.0005_03';
    ln_actual_volume := getActualProducedVolumes(p_object_id, lv2_strm_set, p_daytime, ld_enddate);

  ELSIF p_phase = 'STEAM_INJ' THEN
    lv2_strm_set := 'PD.0005_05';
    ln_actual_volume := getActualProducedVolumes(p_object_id, lv2_strm_set, p_daytime, ld_enddate);

  ELSIF p_phase = 'WATER' THEN
    lv2_strm_set := 'PD.0005_07';
    ln_actual_volume := getActualProducedVolumes(p_object_id, lv2_strm_set, p_daytime, ld_enddate);
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
FUNCTION getActualProducedVolumes(p_object_id VARCHAR2, p_strm_set VARCHAR2, p_daytime DATE, p_enddate DATE DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

  ln_actual_prod_volume NUMBER;
  lv2_class_name VARCHAR2(32);
  ld_enddate DATE;

BEGIN
  lv2_class_name := EcDp_Objects.getObjClassName(p_object_id);
  ld_enddate := nvl(p_enddate, p_daytime);


  SELECT SUM(EcBp_Stream_Fluid.findNetStdVol(sv.object_id,p_daytime,p_enddate)) prod_vol INTO ln_actual_prod_volume
  FROM strm_set_list ssl, strm_version sv
  WHERE DECODE(lv2_class_name,'FCTY_CLASS_1',sv.op_fcty_class_1_id
                             ,'FCTY_CLASS_2',sv.op_fcty_class_2_id
                              ,NULL)    = p_object_id
  AND ld_enddate >= ssl.from_date AND (p_daytime < ssl.end_date OR ssl.end_date IS NULL)
  AND ld_enddate >= sv.daytime AND (p_daytime < sv.end_date OR sv.end_date IS NULL)
  AND ssl.stream_set = p_strm_set
  AND sv.object_id = ssl.object_id;

  RETURN ln_actual_prod_volume;

END getActualProducedVolumes;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getAssignedDeferVolumes                                                   --
-- Description    : Returns Assigned Defer Volumes which was assigned.
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : well_day_defer_alloc
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
FUNCTION getAssignedDeferVolumes(p_object_id VARCHAR2, p_phase VARCHAR2, p_daytime DATE, p_enddate DATE DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

  ln_return NUMBER;
  ld_enddate DATE;

  CURSOR c_well_day_defer_alloc IS
    SELECT NVL(wv.end_date, p_daytime+1) end_date,
    DECODE(p_phase,
      'OIL',DEFERRED_NET_OIL_VOL,
      'GAS',DEFERRED_GAS_VOL,
      'COND',DEFERRED_COND_VOL,
      'WATER',DEFERRED_WATER_VOL,
      'WAT_INJ',DEFERRED_WATER_INJ_VOL,
      'GAS_INJ',DEFERRED_GAS_INJ_VOL,
      'STEAM_INJ',DEFERRED_STEAM_INJ_VOL) loss_rate
    FROM well_day_defer_alloc wd, well_version wv
    WHERE wv.daytime < ld_enddate
    AND NVL(wv.end_date, ld_enddate) > p_daytime
    AND wd.daytime >= p_daytime
    AND wd.daytime < ld_enddate
    AND wv.op_fcty_class_1_id = p_object_id
    AND wd.object_id = wv.object_id;

BEGIN

  ln_return := 0;
  ld_enddate := nvl(p_enddate, p_daytime + 1);
  FOR mycur IN c_well_day_defer_alloc LOOP
    ln_return := mycur.loss_rate + ln_return;
  END LOOP;
  RETURN ln_return;
END getAssignedDeferVolumes;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getPotentialRate                                                   --
-- Description    : Returns Potential Rate
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : well_deferment
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
    'OIL',decode(ecdp_well.isWellPhaseActiveStatus(dev.object_id,null,'OPEN',dev.parent_daytime), 'Y', ecbp_well_potential.findOilProductionPotential(dev.object_id, dev.parent_daytime), null),
    'GAS',decode(ecdp_well.isWellPhaseActiveStatus(dev.object_id,null,'OPEN',dev.parent_daytime), 'Y', ecbp_well_potential.findGasProductionPotential(dev.object_id, dev.parent_daytime), null),
    'COND',decode(ecdp_well.isWellPhaseActiveStatus(dev.object_id,null,'OPEN',dev.parent_daytime), 'Y', ecbp_well_potential.findConProductionPotential(dev.object_id, dev.parent_daytime), null),
    'WATER',decode(ecdp_well.isWellPhaseActiveStatus(dev.object_id,null,'OPEN',dev.parent_daytime), 'Y', ecbp_well_potential.findWatProductionPotential(dev.object_id, dev.parent_daytime), null),
    'WAT_INJ', decode(ecdp_well.isWellPhaseActiveStatus(dev.object_id,'WI','OPEN',dev.parent_daytime), 'Y', ecbp_well_potential.findWatInjectionPotential(dev.object_id, dev.parent_daytime), null),
    'STEAM_INJ', decode(ecdp_well.isWellPhaseActiveStatus(dev.object_id,'SI','OPEN',dev.parent_daytime), 'Y', ecbp_well_potential.findSteamInjectionPotential(dev.object_id, dev.parent_daytime), null),
    'GAS_INJ', decode(ecdp_well.isWellPhaseActiveStatus(dev.object_id,'GI','OPEN',dev.parent_daytime), 'Y', ecbp_well_potential.findGasInjectionPotential(dev.object_id, dev.parent_daytime), null),
    'DILUENT',decode(ecdp_well.isWellPhaseActiveStatus(dev.object_id,null,'OPEN',dev.parent_daytime), 'Y', ecbp_well_potential.findDiluentPotential(dev.object_id, dev.parent_daytime), null),
    'GAS_LIFT',decode(ecdp_well.isWellPhaseActiveStatus(dev.object_id,null,'OPEN',dev.parent_daytime), 'Y', ecbp_well_potential.findGasLiftPotential(dev.object_id, dev.parent_daytime), null))) sum_vol
    FROM (SELECT DISTINCT(object_id),parent_daytime
      FROM DEFERMENT_EVENT dev2
      WHERE dev2.parent_event_no = p_event_no
      AND dev2.deferment_type = 'GROUP_CHILD'
      AND dev2.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD')
    )dev;

  lv2_deferment_type VARCHAR2(32);
  lv2_parent_object_id VARCHAR2(32);
  ld_parent_daytime DATE;
  lv2_object_id VARCHAR2(32);
  ld_day DATE;

BEGIN

  BEGIN
    SELECT wed_1.object_id, wed_1.day, wed_1.deferment_type, wed_1.parent_object_id, wed_1.parent_daytime
    INTO lv2_object_id,ld_day,lv2_deferment_type,lv2_parent_object_id,ld_parent_daytime
    FROM DEFERMENT_EVENT wed_1
    WHERE wed_1.event_no  = p_event_no
    AND wed_1.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20226, 'An error occurred while fetching data for event no- '||p_event_no);
  END;

  IF lv2_deferment_type ='SINGLE' or lv2_deferment_type ='GROUP_CHILD' THEN
    IF p_potential_attribute = 'OIL' then
      IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN', ld_day) = 'Y' THEN
        ln_return_val := ecbp_well_potential.findOilProductionPotential(lv2_object_id,ld_day);
      END IF;
    ELSIF  p_potential_attribute = 'GAS' then
      IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN', ld_day) = 'Y' THEN
        ln_return_val := ecbp_well_potential.findGasProductionPotential(lv2_object_id,ld_day);
      END IF;
    ELSIF p_potential_attribute = 'WAT_INJ' then
      IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,'WI','OPEN',ld_day) = 'Y' THEN
        ln_return_val := ecbp_well_potential.findWatInjectionPotential(lv2_object_id,ld_day);
      END IF;
    ELSIF p_potential_attribute = 'STEAM_INJ' then
      IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,'SI','OPEN',ld_day) = 'Y' THEN
        ln_return_val := ecbp_well_potential.findSteamInjectionPotential(lv2_object_id,ld_day);
      END IF;
    ELSIF  p_potential_attribute = 'COND' then
      IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN',ld_day) = 'Y' THEN
        ln_return_val := ecbp_well_potential.findConProductionPotential(lv2_object_id,ld_day);
      END IF;
    ELSIF p_potential_attribute = 'GAS_INJ' then
      IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,'GI','OPEN',ld_day) = 'Y' THEN
        ln_return_val := ecbp_well_potential.findGasInjectionPotential(lv2_object_id,ld_day);
      END IF;
    ELSIF  p_potential_attribute = 'WATER' then
      IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN', ld_day) = 'Y' THEN
        ln_return_val := ecbp_well_potential.findWatProductionPotential(lv2_object_id,ld_day);
      END IF;
    ELSIF  p_potential_attribute = 'DILUENT' then
      IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN', ld_day) = 'Y' THEN
        ln_return_val := ecbp_well_potential.findDiluentPotential(lv2_object_id,ld_day);
      END IF;
    ELSIF  p_potential_attribute = 'GAS_LIFT' then
      IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN', ld_day) = 'Y' THEN
        ln_return_val := ecbp_well_potential.findGasLiftPotential(lv2_object_id,ld_day);
      END IF;
    END IF;
  ELSIF  lv2_deferment_type  ='GROUP' THEN
  
    ln_return_val := Ue_Deferment.getPotentialRate(p_event_no, p_potential_attribute);

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
-- Function       : getParentEventLossVolume                                                   --
-- Description    : Returns Parent Event Loss Volume
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : well_deferment
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
  p_event_no NUMBER,
  p_event_attribute   VARCHAR2,
  p_deferment_type     VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS

  ln_return_val         NUMBER;
  ln_child_count        NUMBER;
  ln_Loss_Vol          NUMBER;
  ln_TotEventLossVolume   NUMBER;

  CURSOR c_well_deferment  IS
    SELECT wed.object_id,wed.event_no
    FROM DEFERMENT_EVENT wed
    WHERE wed.parent_event_no = p_event_no
    AND wed.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');

BEGIN

  ln_child_count := countChildEvent(p_event_no);
  IF  p_deferment_type  = 'GROUP' THEN
    --not with child
    IF ln_child_count = 0 THEN
      ln_Loss_Vol       := getEventLossVolume(p_event_no, p_event_attribute, NULL, ln_child_count);
      IF ln_Loss_Vol IS NOT NULL THEN
        ln_TotEventLossVolume := nvl(ln_TotEventLossVolume,0) + ln_Loss_Vol;
      END IF;
    END IF;

    --with child
    IF ln_child_count > 0 THEN
      FOR r_wed_child_event IN c_well_deferment  LOOP
        ln_Loss_Vol       := getEventLossVolume(r_wed_child_event.event_no, p_event_attribute, NULL, 1);
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

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getParentEventLossRate                                                   --
-- Description    : Returns Parent Event Loss Rate
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : well_deferment
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

  CURSOR c_well_deferment  IS
    SELECT wd.event_no
    FROM DEFERMENT_EVENT wd
    WHERE wd.parent_event_no = p_event_no
    AND wd.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');

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
      FOR r_wd_child_event IN c_well_deferment  LOOP
          ln_RateOrVol       := getEventLossRate(r_wd_child_event.event_no, p_event_attribute);
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
-- Using tables   : DEFERMENT_EVENT
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

  CURSOR c_well_deferment (cp_event_no NUMBER)  IS
    SELECT wd.daytime, wd.end_date, wd.oil_loss_rate, wd.gas_loss_rate, wd.cond_loss_rate, wd.water_inj_loss_rate,
    wd.gas_inj_loss_rate, wd.steam_inj_loss_rate,
    wd.oil_loss_volume, wd.gas_loss_volume, wd.cond_loss_volume, wd.water_inj_loss_volume,
    wd.gas_inj_loss_volume, wd.steam_inj_loss_volume,
    wd.water_loss_volume,wd.water_loss_rate,wd.diluent_loss_volume,wd.diluent_loss_rate,wd.gas_lift_loss_volume,wd.gas_lift_loss_Rate
    FROM DEFERMENT_EVENT wd
    WHERE event_no = cp_event_no
    AND class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');

BEGIN
    ln_diff := NULL;
    ln_return_val := Ue_Deferment.getEventLossRate(p_event_no,p_event_attribute);
    IF ln_return_val IS NULL THEN
      FOR r_wd_event_loss_rate IN c_well_deferment(p_event_no) LOOP
        IF r_wd_event_loss_rate.end_date IS NOT NULL then
          ln_diff := abs(r_wd_event_loss_rate.end_date- r_wd_event_loss_rate.daytime);

          IF p_event_attribute = 'OIL' and r_wd_event_loss_rate.oil_loss_volume IS NOT NULL THEN
            ln_return_val := r_wd_event_loss_rate.oil_loss_volume;
          ELSIF p_event_attribute = 'OIL' THEN
            ln_return_val := ln_diff *  nvl(r_wd_event_loss_rate.oil_loss_rate,getPotentialRate(p_event_no, p_event_attribute));
          END IF;

          IF p_event_attribute = 'GAS' and r_wd_event_loss_rate.gas_loss_volume IS NOT NULL THEN
            ln_return_val := r_wd_event_loss_rate.gas_loss_volume;
          ELSIF p_event_attribute = 'GAS' THEN
            ln_return_val := ln_diff *  nvl(r_wd_event_loss_rate.gas_loss_rate,getPotentialRate(p_event_no, p_event_attribute));
          END IF;

          IF p_event_attribute = 'WAT_INJ' and r_wd_event_loss_rate.water_inj_loss_volume IS NOT NULL THEN
            ln_return_val := r_wd_event_loss_rate.water_inj_loss_volume;
          ELSIF  p_event_attribute = 'WAT_INJ' THEN
            ln_return_val := ln_diff *  nvl(r_wd_event_loss_rate.water_inj_loss_rate,getPotentialRate(p_event_no, p_event_attribute));
          END IF;

          IF p_event_attribute = 'STEAM_INJ' and r_wd_event_loss_rate.steam_inj_loss_volume IS NOT NULL THEN
            ln_return_val := r_wd_event_loss_rate.steam_inj_loss_volume;
          ELSIF  p_event_attribute = 'STEAM_INJ' THEN
            ln_return_val := ln_diff *  nvl(r_wd_event_loss_rate.steam_inj_loss_rate,getPotentialRate(p_event_no, p_event_attribute));
          END IF;

          IF  p_event_attribute = 'COND' and r_wd_event_loss_rate.cond_loss_volume IS NOT NULL THEN
            ln_return_val := r_wd_event_loss_rate.cond_loss_volume;
          ELSIF  p_event_attribute = 'COND' THEN
            ln_return_val := ln_diff *  nvl(r_wd_event_loss_rate.cond_loss_rate,getPotentialRate(p_event_no, p_event_attribute));
          END IF;

          IF  p_event_attribute = 'GAS_INJ' and r_wd_event_loss_rate.gas_inj_loss_volume IS NOT NULL THEN
            ln_return_val := r_wd_event_loss_rate.gas_inj_loss_volume;
          ELSIF  p_event_attribute = 'GAS_INJ' THEN
            ln_return_val := ln_diff *  nvl(r_wd_event_loss_rate.gas_inj_loss_rate,getPotentialRate(p_event_no, p_event_attribute));
          END IF;
          IF p_event_attribute = 'WATER' and r_wd_event_loss_rate.water_loss_volume IS NOT NULL THEN
            ln_return_val := r_wd_event_loss_rate.water_loss_volume;
          ELSIF p_event_attribute = 'WATER' THEN
            ln_return_val := ln_diff *  nvl(r_wd_event_loss_rate.water_loss_rate,getPotentialRate(p_event_no, p_event_attribute));
          END IF;
          IF  p_event_attribute = 'DILUENT' and r_wd_event_loss_rate.diluent_loss_volume IS NOT NULL THEN
            ln_return_val := r_wd_event_loss_rate.diluent_loss_volume;
          ELSIF  p_event_attribute = 'DILUENT' THEN
            ln_return_val := ln_diff *  nvl(r_wd_event_loss_rate.diluent_loss_rate,getPotentialRate(p_event_no, p_event_attribute));
          END IF;
          IF  p_event_attribute = 'GAS_LIFT' and r_wd_event_loss_rate.gas_lift_loss_volume IS NOT NULL THEN
            ln_return_val := r_wd_event_loss_rate.gas_lift_loss_volume;
          ELSIF  p_event_attribute = 'GAS_LIFT' THEN
            ln_return_val := ln_diff *  nvl(r_wd_event_loss_rate.gas_lift_loss_Rate,getPotentialRate(p_event_no, p_event_attribute));
          END IF;
        END IF;
      END LOOP;
    END IF;

  RETURN ln_return_val;
END getEventLossRate;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getEventLossNoChildEvent                                                   --
-- Description    : Returns Event Loss Volume for without Child records.
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : well_deferment
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
FUNCTION getEventLossNoChildEvent (
  p_event_no      NUMBER,
  p_event_attribute VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS

  ln_diff     NUMBER := 0;
  ln_return_val NUMBER;

  CURSOR c_well_deferment (cp_event_no NUMBER)  IS
    SELECT wd.daytime, wd.end_date, wd.oil_loss_rate, wd.gas_loss_rate, wd.cond_loss_rate, wd.water_inj_loss_rate,
    wd.gas_inj_loss_rate, wd.steam_inj_loss_rate,
    wd.water_loss_rate,wd.diluent_loss_rate,wd.gas_lift_loss_Rate,wd.object_type,wd.object_id
    FROM DEFERMENT_EVENT wd
    WHERE wd.event_no = cp_event_no
    AND wd.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');
    
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
  
  FOR r_wd_event_loss_rate IN c_well_deferment(p_event_no) LOOP
  
    ld_trunc_daytime:= TRUNC(r_wd_event_loss_rate.daytime);
    ld_nvl_end_date := COALESCE(r_wd_event_loss_rate.end_date,
                                Ecdp_Productionday.getProductionDayStart(r_wd_event_loss_rate.object_type,
                                                                         r_wd_event_loss_rate.object_id,
                                                                         TRUNC(Ecdp_Timestamp.getCurrentSysdate,'DD') - 1));
    --Check daylight saving is available for deferment event date.
    SELECT COUNT(*) INTO ln_daylight_present
    FROM pday_dst
    WHERE daytime BETWEEN ld_trunc_daytime AND TRUNC(ld_nvl_end_date) ;
    
    IF lv2_open_end_event='Y' THEN--A
      --if daylight data is present in pday_dst for deferment event , then calculate maximum hrs for deferment event daytime.
      IF ln_daylight_present<>0 THEN--D
        BEGIN
            
          SELECT Daytime,MaxOnHrs INTO ld_day_light_start_date,ln_MaxOnHrs
          FROM (
                SELECT Ecdp_Timestamp.getNumHours(r_wd_event_loss_rate.object_type,r_wd_event_loss_rate.object_id, ld_trunc_daytime+LEVEL-1) MaxOnHrs,
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
          ld_day_light_start_date := ld_day_light_start_date + (ecdp_productionday.getproductiondayoffset(r_wd_event_loss_rate.object_type,r_wd_event_loss_rate.object_id,ld_day_light_start_date))/24;
          ld_day_light_end_date := ld_day_light_start_date+1;                      
                
          SELECT COUNT(*) INTO ln_COUNT
          FROM CTRL_DB_VERSION
          WHERE DB_VERSION=1 AND ld_day_light_start_date BETWEEN r_wd_event_loss_rate.daytime AND ld_nvl_end_date 
          AND ld_day_light_end_date BETWEEN r_wd_event_loss_rate.daytime AND ld_nvl_end_date ;
                
          IF ln_COUNT=1 THEN--B
            ln_diff_hours:=(24-ln_MaxOnHrs)/24;
          END IF;--B
        END IF;--C
      END IF;--D      
      ln_diff := ABS(ld_nvl_end_date- r_wd_event_loss_rate.daytime)-ln_diff_hours;
       
    ELSE--A
      IF ln_daylight_present<>0 THEN--D
        BEGIN
            
          SELECT Daytime,MaxOnHrs INTO ld_day_light_start_date,ln_MaxOnHrs
          FROM (
                SELECT Ecdp_Timestamp.getNumHours(r_wd_event_loss_rate.object_type,r_wd_event_loss_rate.object_id, ld_trunc_daytime+LEVEL-1) MaxOnHrs,
                     ld_trunc_daytime+LEVEL-1 Daytime
                FROM CTRL_DB_VERSION WHERE DB_VERSION=1 
                CONNECT BY LEVEL <= TRUNC(r_wd_event_loss_rate.end_date) - ld_trunc_daytime +1     
                ) 
          WHERE MaxOnHrs<>24;    
            
        EXCEPTION 
          WHEN OTHERS THEN
            ld_day_light_start_date:=NULL;
        END;
          
        IF (ld_day_light_start_date IS NOT NULL) THEN--C
          ld_day_light_start_date := ld_day_light_start_date+(ecdp_productionday.getproductiondayoffset(r_wd_event_loss_rate.object_type,r_wd_event_loss_rate.object_id,ld_day_light_start_date))/24;
          ld_day_light_end_date := ld_day_light_start_date+1;
            
          SELECT COUNT(*) INTO ln_COUNT
          FROM CTRL_DB_VERSION
          WHERE DB_VERSION=1 AND ld_day_light_start_date BETWEEN r_wd_event_loss_rate.daytime AND r_wd_event_loss_rate.end_date 
          AND ld_day_light_end_date BETWEEN r_wd_event_loss_rate.daytime AND r_wd_event_loss_rate.end_date ;
            
          IF ln_COUNT=1 THEN--B
            ln_diff_hours:=(24-ln_MaxOnHrs)/24;
          END IF;--B
        
        END IF;--C
      END IF;--D    
        
        ln_diff := ABS(r_wd_event_loss_rate.end_date- r_wd_event_loss_rate.daytime)-ln_diff_hours;
           
    END IF;--A
    
    IF p_event_attribute = 'OIL' THEN
      ln_return_val := ln_diff *  r_wd_event_loss_rate.oil_loss_rate;
    END IF;
    
    IF p_event_attribute = 'GAS' THEN
      ln_return_val := ln_diff *  r_wd_event_loss_rate.gas_loss_rate;
    END IF;
    
    IF p_event_attribute = 'WAT_INJ' THEN
      ln_return_val := ln_diff * r_wd_event_loss_rate.water_inj_loss_rate;
    END IF;
    
    IF p_event_attribute = 'STEAM_INJ' THEN
      ln_return_val := ln_diff *  r_wd_event_loss_rate.steam_inj_loss_rate;
    END IF;
    
    IF  p_event_attribute = 'COND' THEN
      ln_return_val := ln_diff * r_wd_event_loss_rate.cond_loss_rate;
    END IF;
    
    IF  p_event_attribute = 'GAS_INJ' THEN
      ln_return_val := ln_diff *  r_wd_event_loss_rate.gas_inj_loss_rate;
    END IF;
    
    IF p_event_attribute = 'WATER' THEN
      ln_return_val := ln_diff * r_wd_event_loss_rate.water_loss_rate;
    END IF;
    
    IF  p_event_attribute = 'DILUENT' THEN
      ln_return_val := ln_diff * r_wd_event_loss_rate.diluent_loss_rate;
    END IF;
    
    IF  p_event_attribute = 'GAS_LIFT' THEN
      ln_return_val := ln_diff * r_wd_event_loss_rate.gas_lift_loss_Rate;
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
-- Using tables   : well_deferment
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

  DELETE FROM DEFERMENT_EVENT
  WHERE parent_event_no = p_event_no
  AND class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');

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
-- Using tables   : well_deferment
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
  SELECT count(wde.object_id) INTO ln_child_record
  FROM DEFERMENT_EVENT wde
  WHERE wde.parent_event_no = p_event_no
  AND wde.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');

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
-- Using tables   : well_deferment
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
  FROM DEFERMENT_EVENT wed
  WHERE wed.parent_event_no = p_parent_event_no
  AND wed.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');

  IF ld_chk_child < p_daytime THEN
     RAISE_APPLICATION_ERROR(-20667, 'Parent event start date is invalid as it is after child event end date.');
  END IF;

END  checkChildEndDate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : chkDefermentConstraintLock
-- Description    :
--
-- Preconditions  : Checks whether a last dated Well Deferment and Well Deferment by Well record affects a locked month.
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
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
PROCEDURE chkDefermentConstraintLock(p_operation VARCHAR2, p_new_lock_columns  IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns  IN OUT EcDp_Month_Lock.column_list)
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
lv2_object_class_name VARCHAR2(32);
ln_prod_day_offset NUMBER;
lv2_asset_id VARCHAR2(32);

BEGIN

  ld_new_daytime := p_new_lock_columns('DAYTIME').column_data.AccessDate;
  ld_old_daytime := p_old_lock_columns('DAYTIME').column_data.AccessDate;
  ld_new_end_date := p_new_lock_columns('END_DATE').column_data.AccessDate;
  ld_old_end_date := p_old_lock_columns('END_DATE').column_data.AccessDate;

  IF p_old_lock_columns.EXISTS('OBJECT_ID')  THEN
    lv2_o_obj_id := p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
    lv2_asset_id := lv2_o_obj_id;
  END IF;
  IF p_new_lock_columns.EXISTS('OBJECT_ID')  THEN
    lv2_n_obj_id := p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
    lv2_asset_id := lv2_n_obj_id;
  END IF;

  lv2_object_class_name := ecdp_objects.GetObjClassName(lv2_asset_id);
  
  IF p_operation = 'DELETING' THEN
    ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset(lv2_object_class_name,lv2_asset_id, ld_old_daytime)/24;
  ELSE
    ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset(lv2_object_class_name,lv2_asset_id, ld_new_daytime)/24;  
  END IF;  

  ld_new_daytime := ld_new_daytime - ln_prod_day_offset;
  ld_old_daytime := ld_old_daytime - ln_prod_day_offset;
  ld_new_end_date := ld_new_end_date - ln_prod_day_offset;
  ld_old_end_date := ld_old_end_date - ln_prod_day_offset;

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
    
    IF NVL(ld_new_end_date,TO_DATE('01-01-0001','DD-MM-YYYY')) <> NVL(ld_old_end_date,TO_DATE('01-01-0001','DD-MM-YYYY')) THEN
      IF ld_new_end_date IS NOT NULL THEN
        EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_new_end_date, ld_new_end_date, lv2_id, lv2_o_obj_id);
      END IF;
      IF ld_old_end_date IS NOT NULL THEN
        EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_old_end_date, ld_old_end_date, lv2_id, lv2_o_obj_id);
      END IF;
    ELSE
      EcDp_Month_Lock.checkUpdateEventForLock(ld_new_daytime,
                                              ld_old_daytime,
                                              ld_new_end_date,
                                              ld_old_end_date,
                                              lv2_columns_updated,
                                              lv2_id,
                                              lv2_n_obj_id);
    END IF;
  ELSIF p_operation = 'DELETING' THEN -- Only when deleting a valid analysis
    lv2_id := EcDp_Month_Lock.buildIdentifierString(p_old_lock_columns);
    EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_old_daytime, ld_old_end_date, lv2_id, lv2_o_obj_id);
  END IF;

END chkDefermentConstraintLock;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getCommonReasonCodeSetting
-- Description    :
--
-- Preconditions  : To get Common Reason Code setting from ctrl_property_meta and ctrl_property.
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
---------------------------------------------------------------------------------------------------
FUNCTION getCommonReasonCodeSetting(p_key VARCHAR2)
--</EC-DOC>

RETURN CTRL_PROPERTY_META.DEFAULT_VALUE_STRING%TYPE IS
  v_return_val CTRL_PROPERTY_META.DEFAULT_VALUE_STRING%TYPE ;

BEGIN

  select default_value into v_return_val from (
    select default_value from (
      select default_value_string default_value, to_date('01-01-1900', 'DD-MM-YYYY') daytime FROM ctrl_property_meta where key = p_key
      UNION ALL
      select value_string, daytime from ctrl_property where key = p_key
    ) order by daytime desc
  ) where rownum < 2;

   RETURN v_return_val;
END getCommonReasonCodeSetting;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : calcWellProdLossDay                                                   --
-- Description    : Returns loss rate based on phase and well off time duration
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : well_day_defer_alloc
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

  ln_defered_volume NUMBER := NULL;

BEGIN

  IF p_phase = EcDp_Phase.Oil THEN
    select sum(DEFERRED_NET_OIL_VOL) into ln_defered_volume FROM well_day_defer_alloc WHERE daytime = p_daytime and object_id = p_object_id;
  ELSIF p_phase = EcDp_Phase.CONDENSATE THEN
    select sum(DEFERRED_COND_VOL) into ln_defered_volume FROM well_day_defer_alloc WHERE daytime = p_daytime and object_id = p_object_id;
  ELSIF p_phase = 'GAS_INJ'  THEN
    select sum(DEFERRED_GAS_INJ_VOL) into ln_defered_volume FROM well_day_defer_alloc WHERE daytime = p_daytime and object_id = p_object_id;
  ELSIF p_phase = EcDp_Phase.GAS       THEN
    select sum(DEFERRED_GAS_VOL) into ln_defered_volume FROM well_day_defer_alloc WHERE daytime = p_daytime and object_id = p_object_id;
  ELSIF p_phase = 'WAT_INJ'  THEN
    select sum(DEFERRED_WATER_INJ_VOL) into ln_defered_volume FROM well_day_defer_alloc WHERE daytime = p_daytime and object_id = p_object_id;
  ELSIF p_phase = EcDp_Phase.WATER     THEN
    select sum(DEFERRED_WATER_VOL) into ln_defered_volume FROM well_day_defer_alloc WHERE daytime = p_daytime and object_id = p_object_id;
  ELSIF p_phase = 'DILUENT'   THEN
    select sum(DEFERRED_DILUENT_VOL) into ln_defered_volume FROM well_day_defer_alloc WHERE daytime = p_daytime and object_id = p_object_id;
  ELSIF p_phase = 'GAS_LIFT'  THEN
    select sum(DEFERRED_GL_VOL) into ln_defered_volume FROM well_day_defer_alloc WHERE daytime = p_daytime and object_id = p_object_id;
  ELSIF p_phase = Ecdp_Phase.STEAM THEN
    select sum(DEFERRED_STEAM_INJ_VOL) into ln_defered_volume FROM well_day_defer_alloc WHERE daytime = p_daytime and object_id = p_object_id;
  END IF;

  return nvl(ln_defered_volume,0);

END calcWellProdLossDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calcWellCorrActionVolume
-- Description    : This function finds the deffered volume for the given corrective action period
--                  For Deferment version PD.00020
--
-- Preconditions  :
-- Postconditions : .
--
-- Using tables   : well_deferment,well_day_defer_alloc
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

FUNCTION calcWellCorrActionVolume(
  p_event_no NUMBER,
  p_daytime DATE,
  p_end_date DATE,
  p_event_attribute VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS

  ln_return NUMBER;
  ln_tot_event_loss_vol NUMBER;
  ln_duration NUMBER;
  ln_corr_action_duration NUMBER;
  lv_downtime_type VARCHAR2(50);
  ld_daytime DATE;
  ld_end_date DATE;

BEGIN

  BEGIN
    SELECT deferment_type,daytime,end_date
    INTO lv_downtime_type,ld_daytime,ld_end_date
    FROM DEFERMENT_EVENT
    WHERE event_no  = p_event_no
    AND class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20226, 'An error occurred while fetching data for event no- '||p_event_no);
  END;

  --duration from parent
  ln_duration := ld_end_date - ld_daytime;
  --duration from child
  ln_corr_action_duration := p_end_date - p_daytime;

  ln_tot_event_loss_vol := getParentEventLossVolume (p_event_no, p_event_attribute, lv_downtime_type);

  IF ln_tot_event_loss_vol IS NOT NULL THEN
    ln_return := ln_tot_event_loss_vol / ln_duration * ln_corr_action_duration;
  END IF;

  RETURN ln_return;

END calcWellCorrActionVolume;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getMthPlannedVolumes                                                   --
-- Description    : Returns Planned Volumes based on Month
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
FUNCTION getMthPlannedVolumes(p_object_id VARCHAR2, p_phase VARCHAR2, p_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS

  ln_planned_volume NUMBER;
  ld_first_day      DATE;
  ld_last_day        DATE;
  ln_duration       NUMBER;

BEGIN
  ld_first_day      := trunc(p_daytime,'MON');
  ld_last_day       := last_day(p_daytime);
  ln_duration       := ld_last_day - ld_first_day + 1;
  
  ln_planned_volume := getPlannedVolumes(p_object_id, p_phase, p_daytime) * ln_duration;

  RETURN ln_planned_volume;

END getMthPlannedVolumes;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getMthActualVolumes                                                   --
-- Description    : Returns Actual Volumes based on Month
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
FUNCTION getMthActualVolumes(p_object_id VARCHAR2, p_phase VARCHAR2, p_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS

  ln_actual_volume  NUMBER;
  ld_first_day      DATE;
  ld_last_day       DATE;

BEGIN
  ld_first_day      := trunc(p_daytime,'MON');
  ld_last_day       := last_day(p_daytime);
  
  ln_actual_volume := getActualVolumes(p_object_id, p_phase, ld_first_day, ld_last_day);

  RETURN ln_actual_volume;

END getMthActualVolumes;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getMthAssignedDeferVolumes                                                   --
-- Description    : Returns Assigned Deferred Volumes based on Month
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
FUNCTION getMthAssignedDeferVolumes(p_object_id VARCHAR2, p_phase VARCHAR2, p_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS

  ln_defer_volume 	NUMBER;
  ld_first_day      DATE;
  ld_last_day	    DATE;

BEGIN
  ld_first_day      := trunc(p_daytime,'MON');
  ld_last_day       := last_day(p_daytime);
  
  ln_defer_volume := getAssignedDeferVolumes(p_object_id, p_phase, ld_first_day, ld_last_day);

  RETURN ln_defer_volume;

END getMthAssignedDeferVolumes;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getScheduledDeferVolumes                                                   	   --
-- Description    : Returns Scheduled Deferment Volumes based on Month
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : well_deferment
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                           		   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION getScheduledDeferVolumes(
    p_object_id VARCHAR2, 
    p_phase VARCHAR2,
    p_daytime DATE,
    p_scheduled VARCHAR2) 

RETURN NUMBER
--</EC-DOC>
IS

  -- fetch records that are involved in the current production day and well.
  CURSOR c_well_deferment (cp_start_day DATE, cp_end_day DATE) IS
  SELECT wd.daytime,
         wd.end_date,
         wd.event_no,
         wd.parent_event_no,
         wd.deferment_type,
         decode(p_phase, 'OIL', wa.deferred_net_oil_vol, 'GAS', wa.deferred_gas_vol, 'COND', wa.deferred_cond_vol) as deferred_vol,
         wd.day,
         wd.end_day
  FROM well_day_defer_alloc wa, deferment_event wd, well_version wv
  WHERE wd.object_id = wv.object_id
  AND wd.event_no = wa.event_no
  AND wv.daytime = ec_well_version.prev_equal_daytime(wv.object_id, cp_start_day)  
  AND wv.op_fcty_class_1_id = p_object_id
  AND wd.scheduled = p_scheduled
  AND wd.day <= cp_end_day AND (wd.end_day IS NULL OR wd.end_day >= cp_start_day)
  AND wd.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD'); 

  ln_total NUMBER;
  ld_first_day  DATE;
  ld_last_day   DATE;
  ld_start_date DATE;

BEGIN
  ld_first_day      := trunc(p_daytime,'MON');
  ld_last_day       := last_day(p_daytime);
  ln_total          := 0;
  
  FOR cur_defer IN c_well_deferment(ld_first_day, ld_last_day) LOOP   		
    ln_total := ln_total + cur_defer.deferred_vol;
  END LOOP;
    
  RETURN ln_total;

END getScheduledDeferVolumes;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : chkDefermentDayLock
-- Description    :
--
-- Preconditions  : Checks whether a last dated Deferment Day record affects a locked month.
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
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
PROCEDURE chkDefermentDayLock(p_operation VARCHAR2, p_new_lock_columns  IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns  IN OUT EcDp_Month_Lock.column_list)
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
  lv2_object_class_name VARCHAR2(32);
  ln_prod_day_offset NUMBER;
  lv2_asset_id VARCHAR2(32);

BEGIN

  ld_new_daytime := p_new_lock_columns('DAYTIME').column_data.AccessDate;
  ld_old_daytime := p_old_lock_columns('DAYTIME').column_data.AccessDate;
  
  IF p_old_lock_columns.EXISTS('END_DATE')  THEN
    ld_old_end_date := p_old_lock_columns('END_DATE').column_data.AccessDate;
  END IF;
  IF p_new_lock_columns.EXISTS('END_DATE')  THEN
    ld_new_end_date := p_new_lock_columns('END_DATE').column_data.AccessDate;
  END IF;

  IF p_old_lock_columns.EXISTS('DEFER_OBJECT_ID')  THEN
    lv2_o_obj_id := p_old_lock_columns('DEFER_OBJECT_ID').column_data.AccessVarchar2;
    lv2_asset_id := lv2_o_obj_id;
  END IF;
  IF p_new_lock_columns.EXISTS('DEFER_OBJECT_ID')  THEN
    lv2_n_obj_id := p_new_lock_columns('DEFER_OBJECT_ID').column_data.AccessVarchar2;
    lv2_asset_id := lv2_n_obj_id;
  END IF;

  lv2_object_class_name := ecdp_objects.GetObjClassName(lv2_asset_id);
  
  IF p_operation = 'DELETING' THEN
    ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset(lv2_object_class_name,lv2_asset_id, ld_old_daytime)/24;
  ELSE
    ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset(lv2_object_class_name,lv2_asset_id, ld_new_daytime)/24;
  END IF;  

  ld_new_daytime := ld_new_daytime - ln_prod_day_offset;
  ld_old_daytime := ld_old_daytime - ln_prod_day_offset;
  ld_new_end_date := ld_new_end_date - ln_prod_day_offset;
  ld_old_end_date := ld_old_end_date - ln_prod_day_offset;

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
    
    IF NVL(ld_new_end_date,TO_DATE('01-01-0001','DD-MM-YYYY')) <> NVL(ld_old_end_date,TO_DATE('01-01-0001','DD-MM-YYYY')) THEN
      IF ld_new_end_date IS NOT NULL THEN
        EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_new_end_date, ld_new_end_date, lv2_id, lv2_o_obj_id);
      END IF;
      IF ld_old_end_date IS NOT NULL THEN
        EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_old_end_date, ld_old_end_date, lv2_id, lv2_o_obj_id);
      END IF;
    ELSE
      EcDp_Month_Lock.checkUpdateEventForLock(ld_new_daytime,
                                              ld_old_daytime,
                                              ld_new_end_date,
                                              ld_old_end_date,
                                              lv2_columns_updated,
                                              lv2_id,
                                              lv2_n_obj_id);
    END IF;
  ELSIF p_operation = 'DELETING' THEN -- Only when deleting a valid analysis
    lv2_id := EcDp_Month_Lock.buildIdentifierString(p_old_lock_columns);
    EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_old_daytime, ld_old_end_date, lv2_id, lv2_o_obj_id);
  END IF;

END chkDefermentDayLock;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : deduct1secondYn
-- Description    : Function to check the passed in daytime is 06:00 which is matching the offset 06:00
--                : to indicate to reduce 1 second for date check. 
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
FUNCTION deduct1secondYn(p_object_id VARCHAR2, p_daytime DATE) 
RETURN VARCHAR2
IS
  ln_prod_day_offset  NUMBER;
  deduct1secYn        VARCHAR2(1) := 'N';
BEGIN
  ln_prod_day_offset := Ecdp_Productionday.getProductionDayOffset(null, p_object_id, p_daytime)/24;  
  IF ln_prod_day_offset < 0 THEN
    IF p_daytime - TRUNC(p_daytime) = (1 - abs(ln_prod_day_offset)) THEN
      deduct1secYn := 'Y';
    END IF;
  ELSE
    IF p_daytime - TRUNC(p_daytime) = ln_prod_day_offset THEN
      deduct1secYn := 'Y';
    END IF;
  END IF;
  RETURN deduct1secYn;  
END deduct1secondYn;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getParentEventLossMassRate                                                     --
-- Description    : Returns Parent Event Loss Mass Rate
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : deferment_event
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      : It is used by the procedure in EcDp_Deferment.sumFromWells                     --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION getParentEventLossMassRate (
  p_event_no NUMBER,
  p_event_attribute   VARCHAR2,
  p_deferment_type     VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS
  ln_return_val        NUMBER;
  ln_child_count       NUMBER;
  ln_MassRateOrMass    NUMBER;
  ln_TotEventLossMass  NUMBER;
  CURSOR c_well_deferment  IS
    SELECT wd.event_no
    FROM DEFERMENT_EVENT wd
    WHERE wd.parent_event_no = p_event_no
    AND wd.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');
BEGIN
  ln_child_count := countChildEvent(p_event_no);
  IF  p_deferment_type  = 'GROUP' THEN
    --not with child
    IF ln_child_count = 0 THEN
      ln_MassRateOrMass := getEventLossMassRate(p_event_no, p_event_attribute);                   
      IF ln_MassRateOrMass IS NOT NULL THEN
        ln_TotEventLossMass := nvl(ln_TotEventLossMass,0) + ln_MassRateOrMass;
      END IF;
    END IF;

    --with child
    IF ln_child_count > 0 THEN
      FOR r_wd_child_event IN c_well_deferment  LOOP
        ln_MassRateOrMass       := getEventLossMassRate(r_wd_child_event.event_no, p_event_attribute);
        IF ln_MassRateOrMass IS NOT NULL THEN
          ln_TotEventLossMass := nvl(ln_TotEventLossMass,0) + ln_MassRateOrMass;
        END IF;
      END LOOP;
    END IF;
    ln_return_val := ln_TotEventLossMass;
  ELSE
    ln_return_val := getEventLossMassRate(p_event_no, p_event_attribute);
  END IF;

  RETURN ln_return_val;
END getParentEventLossMassRate;  

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getEventLossMassRate                                                           --
-- Description    : Returns Event Loss Mass Rate
-- Preconditions  : 
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : DEFERMENT_EVENT
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :  It is used by the procedure in EcDp_Deferment.sumFromWells                    --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION getEventLossMassRate (
  p_event_no        NUMBER,
  p_event_attribute VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS
  ln_diff       NUMBER;
  ln_return_val NUMBER;
  CURSOR c_well_deferment (cp_event_no NUMBER)  IS
  SELECT wd.daytime, wd.end_date, 
         wd.oil_loss_mass_rate, wd.gas_loss_mass_rate, wd.cond_loss_mass_rate, wd.water_loss_mass_rate,
         wd.oil_loss_mass, wd.gas_loss_mass, wd.cond_loss_mass, wd.water_loss_mass
  FROM DEFERMENT_EVENT wd
  WHERE event_no = cp_event_no
  AND class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');
BEGIN
  ln_return_val := Ue_Deferment.getEventLossMassRate(p_event_no,p_event_attribute);
  IF ln_return_val IS NULL THEN
    FOR r_wd_event_loss_mass IN c_well_deferment(p_event_no) LOOP
      IF r_wd_event_loss_mass.end_date IS NOT NULL then
        ln_diff := abs(r_wd_event_loss_mass.end_date - r_wd_event_loss_mass.daytime);
        IF p_event_attribute = 'OIL' and r_wd_event_loss_mass.oil_loss_mass IS NOT NULL THEN
          ln_return_val := r_wd_event_loss_mass.oil_loss_mass;
        ELSIF p_event_attribute = 'OIL' THEN
          ln_return_val := ln_diff *  nvl(r_wd_event_loss_mass.oil_loss_mass_rate, getPotentialMassRate(p_event_no, p_event_attribute));                 
        END IF;
        IF p_event_attribute = 'GAS' and r_wd_event_loss_mass.gas_loss_mass IS NOT NULL THEN
          ln_return_val := r_wd_event_loss_mass.gas_loss_mass;
        ELSIF p_event_attribute = 'GAS' THEN
          ln_return_val := ln_diff *  nvl(r_wd_event_loss_mass.gas_loss_mass_rate, getPotentialMassRate(p_event_no, p_event_attribute));                 
        END IF;
        IF p_event_attribute = 'COND' and r_wd_event_loss_mass.cond_loss_mass IS NOT NULL THEN
          ln_return_val := r_wd_event_loss_mass.cond_loss_mass;
        ELSIF p_event_attribute = 'COND' THEN
          ln_return_val := ln_diff *  nvl(r_wd_event_loss_mass.cond_loss_mass_rate, getPotentialMassRate(p_event_no, p_event_attribute));                 
        END IF;
        IF p_event_attribute = 'WATER' and r_wd_event_loss_mass.water_loss_mass IS NOT NULL THEN
          ln_return_val := r_wd_event_loss_mass.water_loss_mass;
        ELSIF p_event_attribute = 'WATER' THEN
          ln_return_val := ln_diff *  nvl(r_wd_event_loss_mass.water_loss_mass_rate, getPotentialMassRate(p_event_no, p_event_attribute));                 
        END IF;
      END IF;  
    END LOOP;
  END IF;

  RETURN ln_return_val;
END getEventLossMassRate;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getParentEventLossMass                                                         --
-- Description    : Returns Parent Event Loss Mass
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : DEFERMENT_EVENT
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :  It is used by the function attributes XXXXX_EVENT_LOSS_MASS at WELL_DEFERMENT --
--                   class.                                                                        --
--                   XXXXX = OIL, GAS, COND and WATER                                              --
-----------------------------------------------------------------------------------------------------
FUNCTION getParentEventLossMass (
  p_event_no NUMBER,
  p_event_attribute   VARCHAR2,
  p_deferment_type     VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
  ln_return_val           NUMBER;
  ln_child_count          NUMBER;
  ln_Loss_Mass            NUMBER;
  ln_TotEventLossMass     NUMBER;
  
  CURSOR c_well_deferment  IS
    SELECT wed.object_id,wed.event_no
    FROM DEFERMENT_EVENT wed
    WHERE wed.parent_event_no = p_event_no
    AND wed.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');
    
BEGIN

  ln_child_count := countChildEvent(p_event_no);
  IF  p_deferment_type  = 'GROUP' THEN
    --not with child
    IF ln_child_count = 0 THEN
      ln_Loss_Mass       := getEventLossMass(p_event_no, p_event_attribute, NULL, ln_child_count);
      IF ln_Loss_Mass IS NOT NULL THEN
        ln_TotEventLossMass := nvl(ln_TotEventLossMass,0) + ln_Loss_Mass;
      END IF;
    END IF;

    --with child
    IF ln_child_count > 0 THEN
      FOR r_wed_child_event IN c_well_deferment  LOOP
        ln_Loss_Mass       := getEventLossMass(r_wed_child_event.event_no, p_event_attribute, NULL, 1);
        IF ln_Loss_Mass IS NOT NULL THEN
          ln_TotEventLossMass := nvl(ln_TotEventLossMass,0) + ln_Loss_Mass;
        END IF;
      END LOOP;
    END IF;
    ln_return_val := ln_TotEventLossMass;
  ELSE
    ln_return_val := getEventLossMass(p_event_no, p_event_attribute,NULL, 1);
  END IF;

  RETURN ln_return_val;
END getParentEventLossMass;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getEventLossMass                                                               --
-- Description    : Returns Event Loss Mass
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : DEFERMENT_EVENT
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :  It is used by the function attributes XXXXX_EVENT_LOSS_MASS at WELL_DEFERMENT --
--                   class.                                                                        --
--                   XXXXX = OIL, GAS, COND and WATER                                              --
-----------------------------------------------------------------------------------------------------
FUNCTION getEventLossMass (
  p_event_no      NUMBER,
  p_phase         VARCHAR2,
  p_object_id     VARCHAR2 DEFAULT NULL,
  p_child_count   NUMBER DEFAULT 1)

RETURN NUMBER
--</EC-DOC>
IS

  ln_return_val NUMBER;
  ln_loss_mass  NUMBER;
  lv2_object_id VARCHAR2(32);

  CURSOR c_deferred (cp_object_id VARCHAR2) IS
    SELECT DECODE(p_phase,
      'OIL',sum(deferred_net_oil_mass),
      'GAS',sum(deferred_gas_mass),
      'COND',sum(deferred_cond_mass),
      'WATER',sum(deferred_water_mass)) sum_mass
    FROM well_day_defer_alloc
    WHERE object_id = cp_object_id and event_no = p_event_no;

BEGIN
  ln_return_val := Ue_Deferment.getEventLossMass(p_event_no,p_phase,p_object_id);
  lv2_object_id := p_object_id;

  IF ln_return_val IS NULL THEN
    IF p_object_id IS NULL THEN
      BEGIN
        SELECT wed.object_id
        INTO lv2_object_id
        FROM DEFERMENT_EVENT wed
        WHERE wed.event_no  = p_event_no
        AND wed.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20226, 'An error occurred while fetching data for event no- '||p_event_no);
      END;
    END IF;
    
    FOR mycur IN c_deferred(lv2_object_id) LOOP
      ln_return_val := mycur.sum_mass;
    END LOOP;

    BEGIN 
      SELECT DECODE(p_phase,
            'OIL',OIL_LOSS_MASS,
            'GAS',GAS_LOSS_MASS,
            'COND',COND_LOSS_MASS,
            'WATER',WATER_LOSS_MASS) LOSS_MASS
      INTO ln_loss_mass
      FROM DEFERMENT_EVENT
      WHERE event_no  = p_event_no
      AND class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');
    EXCEPTION
      WHEN OTHERS THEN
        ln_loss_mass:=NULL;
    END;
  
    IF (ln_loss_mass IS NULL AND p_child_count = 0) THEN
      ln_return_val:=getEventLossMassNoChildEvent(p_event_no,p_phase);
    END IF;
  END IF;

  RETURN NVL(ln_loss_mass,ln_return_val);
END getEventLossMass;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getEventLossMassNoChildEvent                                                   --
-- Description    : Returns Event Loss Mass for without Child records.
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : DEFERMENT_EVENT
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :  It is used by the function attributes XXXXX_EVENT_LOSS_MASS at WELL_DEFERMENT --
--                   class.                                                                        --
--                   XXXXX = OIL, GAS, COND and WATER                                              --
-----------------------------------------------------------------------------------------------------
FUNCTION getEventLossMassNoChildEvent (
  p_event_no      NUMBER,
  p_event_attribute VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS

  ln_diff     NUMBER := 0;
  ln_return_val NUMBER;

  CURSOR c_deferment_event (cp_event_no NUMBER)  IS
    SELECT wd.daytime, wd.end_date, wd.oil_loss_mass_rate, wd.gas_loss_mass_rate, wd.cond_loss_mass_rate, wd.water_loss_mass_rate, wd.object_type, wd.object_id
    FROM DEFERMENT_EVENT wd
    WHERE wd.event_no = cp_event_no
    AND wd.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');
    
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
  
  FOR r_deferment_event IN c_deferment_event(p_event_no) LOOP
  
    ld_trunc_daytime:= TRUNC(r_deferment_event.daytime);
    ld_nvl_end_date := COALESCE(r_deferment_event.end_date,
                                Ecdp_Productionday.getProductionDayStart(r_deferment_event.object_type,
                                                                         r_deferment_event.object_id,
                                                                         TRUNC(Ecdp_Timestamp.getCurrentSysdate,'DD') - 1));
    --Check daylight saving is available for deferment event date.
    SELECT COUNT(*) INTO ln_daylight_present
    FROM pday_dst
    WHERE daytime BETWEEN ld_trunc_daytime AND TRUNC(ld_nvl_end_date) ;
    
    IF lv2_open_end_event ='Y' THEN--A
      --if daylight data is present in pday_dst for deferment event , then calculate maximum hrs for deferment event daytime.
      IF ln_daylight_present<>0 THEN--D
        BEGIN
            
          SELECT Daytime,MaxOnHrs INTO ld_day_light_start_date,ln_MaxOnHrs
          FROM (
                SELECT Ecdp_Timestamp.getNumHours(r_deferment_event.object_type,r_deferment_event.object_id, ld_trunc_daytime+LEVEL-1) MaxOnHrs,
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
          ld_day_light_start_date := ld_day_light_start_date + (ecdp_productionday.getproductiondayoffset(r_deferment_event.object_type,r_deferment_event.object_id,ld_day_light_start_date))/24;
          ld_day_light_end_date := ld_day_light_start_date+1;                      
                
          SELECT COUNT(*) INTO ln_COUNT
          FROM CTRL_DB_VERSION
          WHERE DB_VERSION=1 AND ld_day_light_start_date BETWEEN r_deferment_event.daytime AND ld_nvl_end_date 
          AND ld_day_light_end_date BETWEEN r_deferment_event.daytime AND ld_nvl_end_date ;
                
          IF ln_COUNT=1 THEN--B
            ln_diff_hours:=(24-ln_MaxOnHrs)/24;
          END IF;--B
        END IF;--C
      END IF;--D      
      ln_diff := ABS(ld_nvl_end_date- r_deferment_event.daytime)-ln_diff_hours;
       
    ELSE--A
      IF ln_daylight_present<>0 THEN--D
        BEGIN
            
          SELECT Daytime,MaxOnHrs INTO ld_day_light_start_date,ln_MaxOnHrs
          FROM (
                SELECT Ecdp_Timestamp.getNumHours(r_deferment_event.object_type,r_deferment_event.object_id, ld_trunc_daytime+LEVEL-1) MaxOnHrs,
                     ld_trunc_daytime+LEVEL-1 Daytime
                FROM CTRL_DB_VERSION WHERE DB_VERSION=1 
                CONNECT BY LEVEL <= TRUNC(r_deferment_event.end_date) - ld_trunc_daytime +1     
                ) 
          WHERE MaxOnHrs<>24;    
            
        EXCEPTION 
          WHEN OTHERS THEN
            ld_day_light_start_date:=NULL;
        END;
          
        IF (ld_day_light_start_date IS NOT NULL) THEN--C
          ld_day_light_start_date := ld_day_light_start_date+(ecdp_productionday.getproductiondayoffset(r_deferment_event.object_type,r_deferment_event.object_id,ld_day_light_start_date))/24;
          ld_day_light_end_date := ld_day_light_start_date+1;
            
          SELECT COUNT(*) INTO ln_COUNT
          FROM CTRL_DB_VERSION
          WHERE DB_VERSION=1 AND ld_day_light_start_date BETWEEN r_deferment_event.daytime AND r_deferment_event.end_date 
          AND ld_day_light_end_date BETWEEN r_deferment_event.daytime AND r_deferment_event.end_date ;
            
          IF ln_COUNT=1 THEN--B
            ln_diff_hours:=(24-ln_MaxOnHrs)/24;
          END IF;--B
        
        END IF;--C
      END IF;--D    
        
        ln_diff := ABS(r_deferment_event.end_date- r_deferment_event.daytime)-ln_diff_hours;
           
    END IF;--A
    
    IF p_event_attribute = 'OIL' THEN
      ln_return_val := ln_diff *  r_deferment_event.oil_loss_mass_rate;
    END IF;
    
    IF p_event_attribute = 'GAS' THEN
      ln_return_val := ln_diff *  r_deferment_event.gas_loss_mass_rate;
    END IF;
    
    IF  p_event_attribute = 'COND' THEN
      ln_return_val := ln_diff * r_deferment_event.cond_loss_mass_rate;
    END IF;
    
    IF p_event_attribute = 'WATER' THEN
      ln_return_val := ln_diff * r_deferment_event.water_loss_mass_rate;
    END IF;
    
  END LOOP;

  RETURN ln_return_val;
END getEventLossMassNoChildEvent;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getPotentialMassRate                                                           --
-- Description    : Returns Potential Mass Rate
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : DEFERMENT_EVENT
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
FUNCTION getPotentialMassRate (
  p_event_no NUMBER,
  p_potential_attribute VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS

  ln_return_val NUMBER;

  CURSOR c_group_potential_mass_rate IS
    SELECT sum(DECODE(p_potential_attribute,
    'OIL',decode(ecdp_well.isWellPhaseActiveStatus(dev.object_id,null,'OPEN',dev.parent_daytime), 'Y', ecbp_well_potential.findOilMassProdPotential(dev.object_id, dev.parent_daytime), null),
    'GAS',decode(ecdp_well.isWellPhaseActiveStatus(dev.object_id,null,'OPEN',dev.parent_daytime), 'Y', ecbp_well_potential.findGasMassProdPotential(dev.object_id, dev.parent_daytime), null),
    'COND',decode(ecdp_well.isWellPhaseActiveStatus(dev.object_id,null,'OPEN',dev.parent_daytime), 'Y', ecbp_well_potential.findCondMassProdPotential(dev.object_id, dev.parent_daytime), null),
    'WATER',decode(ecdp_well.isWellPhaseActiveStatus(dev.object_id,null,'OPEN',dev.parent_daytime), 'Y', ecbp_well_potential.findWaterMassProdPotential(dev.object_id, dev.parent_daytime), null))) sum_vol
    FROM (SELECT DISTINCT(object_id),parent_daytime
      FROM DEFERMENT_EVENT dev2
      WHERE dev2.parent_event_no = p_event_no
      AND dev2.deferment_type = 'GROUP_CHILD'
      AND dev2.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD')
    )dev;

  lv2_deferment_type VARCHAR2(32);
  lv2_parent_object_id VARCHAR2(32);
  ld_parent_daytime DATE;
  lv2_object_id VARCHAR2(32);
  ld_daytime DATE;

BEGIN

  BEGIN
    SELECT wed_1.object_id, wed_1.daytime, wed_1.deferment_type, wed_1.parent_object_id, wed_1.parent_daytime
    INTO lv2_object_id,ld_daytime,lv2_deferment_type,lv2_parent_object_id,ld_parent_daytime
    FROM DEFERMENT_EVENT wed_1
    WHERE wed_1.event_no  = p_event_no
    AND wed_1.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20226, 'An error occurred while fetching data for event no- '||p_event_no);
  END;

  IF lv2_deferment_type ='SINGLE' or lv2_deferment_type ='GROUP_CHILD' THEN
    IF p_potential_attribute = 'OIL' then
      IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN', ld_daytime) = 'Y' THEN
        ln_return_val := ecbp_well_potential.findOilMassProdPotential(lv2_object_id,ld_daytime);
      END IF;
    ELSIF  p_potential_attribute = 'GAS' then
      IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN', ld_daytime) = 'Y' THEN
        ln_return_val := ecbp_well_potential.findGasMassProdPotential(lv2_object_id,ld_daytime);
      END IF;
    ELSIF  p_potential_attribute = 'COND' then
      IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN',ld_daytime) = 'Y' THEN
        ln_return_val := ecbp_well_potential.findCondMassProdPotential(lv2_object_id,ld_daytime);
      END IF;
    ELSIF  p_potential_attribute = 'WATER' then
      IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN', ld_daytime) = 'Y' THEN
        ln_return_val := ecbp_well_potential.findWaterMassProdPotential(lv2_object_id,ld_daytime);
      END IF;
    END IF;
  ELSIF  lv2_deferment_type  ='GROUP' THEN
  
    ln_return_val := Ue_Deferment.getPotentialMassRate(p_event_no, p_potential_attribute);

    IF ln_return_val is NULL THEN
      FOR cur_group_potential_rate in c_group_potential_mass_rate LOOP
        ln_return_val := cur_group_potential_rate.sum_vol;
      END LOOP;
    END IF;

  END IF;

  RETURN ln_return_val;
END getPotentialMassRate;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getParentComment                                                               --
-- Description    : Returns Parent Comment for the child deferment event                           --
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : deferment_event
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
FUNCTION getParentComment(p_event_no NUMBER)
RETURN VARCHAR2
--</EC-DOC>
IS
  lv_parent_comment VARCHAR2(2000);

BEGIN
  SELECT b.comments INTO lv_parent_comment
  FROM deferment_event a
  INNER JOIN deferment_event b 
  ON a.parent_event_no = b.event_no
  WHERE a.event_no = p_event_no;

  RETURN lv_parent_comment;
END getParentComment;  

END  EcBp_Deferment;
/