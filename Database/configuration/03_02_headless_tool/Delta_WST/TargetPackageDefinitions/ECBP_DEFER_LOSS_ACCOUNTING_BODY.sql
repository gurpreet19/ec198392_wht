CREATE OR REPLACE PACKAGE BODY EcBp_Defer_Loss_Accounting IS
/****************************************************************
** Package        :  EcBp_Defer_Loss_Accounting
**
** $Revision: 1.7.2.2 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Daily Facility and Field Loss Accounting.
**
** Documentation  :  www.energy-components.com
**
** Created  : 17.11.2011  Sarojini Rajaretnam
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
**21.11.2011  rajarsar ECPD-18825:Added getRateUom
**12.12.2011  rajarsar ECPD-19175:Added calcDailyVolLoss,calcDailyMassLoss,calcProdEff and calcOpEff
**30.12.2011  rajarsar ECPD-19698:Updated calcProdEff,calcOpEff and getTotalOELosses
**05.01.2012  rajarsar ECPD-19701:Added calcDailyVariance and updated calcProdEff,calcOpEff and getTotalOELosses
**17.01.2012  rajarsar ECPD-19804:Updated calcDailyVolLoss,calcDailyMassLoss and getTotalOELosses to support absolute value
**15.02.2012  abdulmaw ECPD-19811:Added getTotalPotentialBudgetkboe and getTotalActualkboe
**08.08.2012  makkkkam ECPD-21684:Added getEventNo and getPlannedVol.
*****************************************************************/
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getRateUom
-- Description    : Returns the UOM of planned rate for a stream based on phase of the stream.
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
FUNCTION getRateUom(p_object_id VARCHAR2,
                  p_daytime DATE,
                  p_rate_type VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_phase VARCHAR(32);
  lv2_uom VARCHAR2(32);

BEGIN

  lv2_phase := ec_strm_version.stream_phase(p_object_id,p_daytime,'<=');
  IF p_rate_type = 'VOLUME' THEN
    lv2_uom := ec_class_attr_presentation.uom_code('STRM_PLAN_BUDGET','VOLUME_RATE');
    IF lv2_uom IS NULL THEN
      IF lv2_phase IN ('OIL','COND','STEAM') THEN
        lv2_uom := 'STD_LIQ_VOL_RATE';
      ELSIF lv2_phase = 'WAT' THEN
        lv2_uom := 'STD_WATER_RATE';
      ELSIF lv2_phase = 'GAS' THEN
        lv2_uom := 'STD_GAS_RATE';
      ELSE
        lv2_uom := 'STD_LIQ_VOL_RATE';
      END IF;
    END IF;
  ELSE -- mass
    lv2_uom := ec_class_attr_presentation.uom_code('STRM_PLAN_BUDGET','MASS_RATE');
    IF lv2_uom IS NULL THEN
      IF lv2_phase IN ('OIL','COND','STEAM','WAT') THEN
        lv2_uom := 'LIQ_MASS_RATE';
      ELSIF lv2_phase = 'GAS' THEN
        lv2_uom := 'GAS_MASS_RATE';
      ELSE
        lv2_uom := 'LIQ_MASS_RATE';
      END IF;
    END IF;
END IF;
RETURN lv2_uom;
END getRateUom;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcDailyVolLoss
-- Description    : This is to calculate total volume losses per stream, per day.
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
FUNCTION calcDailyVolLoss(p_object_id VARCHAR2,p_stream_id VARCHAR2, p_type VARCHAR2,
p_daytime DATE) RETURN NUMBER
--</EC-DOC>
IS
  CURSOR c_defer_loss_strm_event IS
  SELECT sum(net_vol) total_loss
  FROM defer_loss_strm_event dlf, defer_loss_acc_event dlae
  WHERE dlae.object_id = p_object_id
  AND dlae.event_no = dlf.event_no
  AND dlf.object_id = p_stream_id
  AND dlf.daytime = p_daytime
  AND dlae.type = p_type;

  ln_retval  NUMBER;

BEGIN

  FOR c_total_vol_loss IN c_defer_loss_strm_event LOOP
    ln_retval := abs(c_total_vol_loss.total_loss);
  END LOOP;

RETURN ln_retval;
END calcDailyVolLoss;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcDailyMassLoss
-- Description    : This is to calculate total mass losses per stream, per day.
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
FUNCTION calcDailyMassLoss(p_object_id VARCHAR2,p_stream_id VARCHAR2, p_type VARCHAR2,
p_daytime DATE) RETURN NUMBER
--</EC-DOC>
IS
  CURSOR c_defer_loss_strm_event IS
  SELECT sum(net_mass) total_loss
  FROM defer_loss_strm_event dlf, defer_loss_acc_event dlae
  WHERE dlae.object_id = p_object_id
  AND dlae.event_no = dlf.event_no
  AND dlf.object_id = p_stream_id
  AND dlf.daytime = p_daytime
  AND dlae.type = p_type;

  ln_retval       NUMBER;

BEGIN
  FOR c_total_vol_loss IN c_defer_loss_strm_event LOOP
    ln_retval := abs(c_total_vol_loss.total_loss);
  END LOOP;

RETURN ln_retval;

END calcDailyMassLoss;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcProdEff
-- Description    : This is to calculate production efficiency per facility/field,per day
--
-- Preconditions  : Sub chokes linked to the facility/field must have contrib_to_eff_calc = Y.
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
FUNCTION calcProdEff(p_object_id VARCHAR2,p_daytime DATE) RETURN NUMBER
--</EC-DOC>
IS

  ln_retval       NUMBER;
  ln_potential    NUMBER;
  ln_actual       NUMBER;
  ln_total_actual NUMBER :=0;
  ln_chokeBoeConstant  NUMBER;
  ln_strmBoeconstant NUMBER;
  lv2_db_unit     VARCHAR2(16);
  ln_total_potential NUMBER := 0;

 CURSOR cur_db_unit(c_uom_meas_type VARCHAR2) IS
   SELECT unit
   FROM ctrl_uom_setup cus
   WHERE cus.measurement_type = c_uom_meas_type
   AND cus.db_unit_ind = 'Y';

 CURSOR cur_strm_losses IS
   SELECT  dlse.object_id stream_id, dlse.choke_model_id, cmv.uom,cmv.condition
   FROM defer_loss_acc_event dlae, defer_loss_strm_event dlse,choke_model_version cmv
   WHERE dlae.object_id = p_object_id
   AND dlse.daytime = p_daytime
   AND dlae.event_no = dlse.event_no
   AND dlse.choke_model_id = cmv.object_id
   AND cmv.daytime <= p_daytime
   AND nvl(cmv.end_date,p_daytime+1) > p_daytime
   AND cmv.contrib_to_eff_calc = 'Y'
   AND dlae.type = 'POTENTIAL'
   GROUP BY dlse.object_id, dlse.choke_model_id, cmv.uom,cmv.condition;

BEGIN

  FOR c_strm_losses IN cur_strm_losses LOOP
    IF c_strm_losses.uom IN ('STD_GAS_VOL', 'STD_OIL_VOL') THEN
      ln_actual := EcBp_Stream_Fluid.findNetStdVol(c_strm_losses.stream_id, p_daytime);
    ELSE
      ln_actual := EcBp_Stream_Fluid.findNetStdMass(c_strm_losses.stream_id, p_daytime);
    END IF;
    FOR c_db_unit IN cur_db_unit(c_strm_losses.uom) LOOP
      lv2_db_unit := c_db_unit.unit;
    END LOOP;
    ln_strmBoeConstant := ue_defer_loss_accounting.getStrmBoeConstant(c_strm_losses.stream_id,p_daytime,lv2_db_unit);
    ln_actual        := ln_actual * nvl(ln_strmBoeConstant,0);
    ln_total_actual := ln_total_actual + nvl(ln_actual,0);
    -- get the boeConstant. This is the constant for choke model to convert values in boe
    IF (c_strm_losses.condition = 'STABLE_LIQ') THEN
      ln_chokeBoeConstant := ec_choke_model_ref_value.stable_liq_to_boe(c_strm_losses.choke_model_id, p_daytime,'<=');
    ELSIF (c_strm_losses.condition = 'UNSTABLE_LIQ') THEN
      ln_chokeBoeConstant := ec_choke_model_ref_value.unstable_liq_to_boe(c_strm_losses.choke_model_id, p_daytime,'<=');
    ELSIF (c_strm_losses.condition = 'GAS') THEN
      ln_chokeBoeConstant := ec_choke_model_ref_value.gas_to_boe(c_strm_losses.choke_model_id, p_daytime,'<=');
    END IF;
    ln_potential :=  ecbp_choke_model.calcTotalMppLip(c_strm_losses.choke_model_id,p_daytime,'CHOKE_MODEL_MPP');
    ln_potential := ln_potential * nvl(ln_chokeBoeConstant,0);
    ln_total_potential := ln_total_potential + nvl(ln_potential,0);
  END LOOP;
  IF ln_total_potential > 0 THEN
    ln_retval := ln_total_actual/ln_total_potential *100;
  ELSE
    ln_retval := 0;
  END IF;

RETURN ln_retval;
END calcProdEff;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcOpEff
-- Description    : This is to calculate operation efficiency per facility/field,per day
--
-- Preconditions  : Sub chokes linked to the facility/field must have contrib_to_eff_calc = Y. Losses will be
--                  added to the calculation if include_in_oe = Y for the event.
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
FUNCTION calcOpEff(p_object_id VARCHAR2,p_daytime DATE) RETURN NUMBER
--</EC-DOC>
IS
  ln_retval       NUMBER;
  ln_potential    NUMBER;
  ln_actual       NUMBER;
  ln_total_actual NUMBER :=0;
  ln_chokeBoeConstant  NUMBER;
  ln_strmBoeconstant NUMBER;
  lv2_db_unit     VARCHAR2(16);
  ln_total_potential NUMBER := 0;
  ln_total_loss NUMBER := 0;

  CURSOR cur_db_unit(c_uom_meas_type VARCHAR2) IS
    SELECT unit
    FROM ctrl_uom_setup cus
    WHERE cus.measurement_type = c_uom_meas_type
    AND cus.db_unit_ind = 'Y';

 CURSOR cur_strm_losses IS
   SELECT  dlse.object_id stream_id, dlse.choke_model_id, cmv.uom,cmv.condition
   FROM defer_loss_acc_event dlae, defer_loss_strm_event dlse,choke_model_version cmv
   WHERE dlae.object_id = p_object_id
   AND dlse.daytime = p_daytime
   AND dlae.event_no = dlse.event_no
   AND dlse.choke_model_id = cmv.object_id
   AND cmv.daytime <= p_daytime
   AND nvl(cmv.end_date,p_daytime+1) > p_daytime
   AND cmv.contrib_to_eff_calc = 'Y'
   AND dlae.type = 'POTENTIAL'
   GROUP BY dlse.object_id, dlse.choke_model_id, cmv.uom,cmv.condition;

BEGIN

  FOR c_strm_losses IN cur_strm_losses LOOP
    IF c_strm_losses.uom IN ('STD_GAS_VOL', 'STD_OIL_VOL') THEN
      ln_actual := EcBp_Stream_Fluid.findNetStdVol(c_strm_losses.stream_id, p_daytime);
    ELSE
      ln_actual := EcBp_Stream_Fluid.findNetStdMass(c_strm_losses.stream_id, p_daytime);
    END IF;
    FOR c_db_unit IN cur_db_unit(c_strm_losses.uom) LOOP
      lv2_db_unit := c_db_unit.unit;
    END LOOP;
    ln_strmBoeConstant := ue_defer_loss_accounting.getStrmBoeConstant(c_strm_losses.stream_id,p_daytime,lv2_db_unit);
    ln_actual        := ln_actual * nvl(ln_strmBoeConstant,0);
    ln_total_actual := ln_total_actual + nvl(ln_actual,0);
    -- get the boeConstant. This is the constant for choke model to convert values in boe
    IF (c_strm_losses.condition = 'STABLE_LIQ') THEN
      ln_chokeBoeConstant := ec_choke_model_ref_value.stable_liq_to_boe(c_strm_losses.choke_model_id, p_daytime,'<=');
    ELSIF (c_strm_losses.condition = 'UNSTABLE_LIQ') THEN
      ln_chokeBoeConstant := ec_choke_model_ref_value.unstable_liq_to_boe(c_strm_losses.choke_model_id, p_daytime,'<=');
    ELSIF (c_strm_losses.condition = 'GAS') THEN
      ln_chokeBoeConstant := ec_choke_model_ref_value.gas_to_boe(c_strm_losses.choke_model_id, p_daytime,'<=');
    END IF;
    ln_potential :=  ecbp_choke_model.calcTotalMppLip(c_strm_losses.choke_model_id,p_daytime,'CHOKE_MODEL_MPP');
    ln_potential := ln_potential * nvl(ln_chokeBoeConstant,0);
    ln_total_potential := ln_total_potential + nvl(ln_potential,0);
  END LOOP;
  ln_total_loss := getTotalOELosses(p_object_id,p_daytime);
  IF ln_total_potential > 0 THEN
    ln_retval := (ln_total_actual + nvl(ln_total_loss,0))/ln_total_potential *100;
  ELSE
    ln_retval := 0;
  END IF;

 RETURN ln_retval;

END calcOpEff;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalOELosses
-- Description    : Returns the Total Losses per facility/per field when the an event has include_in_oe = Y.
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
FUNCTION getTotalOELosses(p_object_id VARCHAR2,p_daytime DATE) RETURN NUMBER
--</EC-DOC>
IS

  CURSOR cur_defer_event_oe IS
    SELECT  dlse.net_mass,dlse.net_vol,cmv.uom,cmv.condition, dlse.choke_model_id
    FROM defer_loss_strm_event dlse, defer_loss_acc_event dlae, choke_model_version cmv
    WHERE dlse.daytime = p_daytime
    AND dlse.event_no = dlae.event_no
    AND dlae.object_id = p_object_id
    AND dlae.include_in_oe = 'Y'
    AND dlse.choke_model_id = cmv.object_id
    AND cmv.daytime <= p_daytime
    AND nvl(cmv.end_date,p_daytime+1) > p_daytime
    AND cmv.contrib_to_eff_calc = 'Y'
    AND dlae.type = 'POTENTIAL';

  ln_loss NUMBER;
  ln_chokeBoeConstant  NUMBER;
  ln_total_loss NUMBER := 0 ;

BEGIN
  FOR c_defer_event_oe IN cur_defer_event_oe LOOP
    IF c_defer_event_oe.uom IN ('STD_GAS_VOL', 'STD_OIL_VOL') THEN
      ln_loss := c_defer_event_oe.net_vol;
    ELSE
      ln_loss := c_defer_event_oe.net_mass;
    END IF;
     -- get the boeConstant. This is the constant for choke model to convert values in boe
     IF (c_defer_event_oe.condition = 'STABLE_LIQ') THEN
       ln_chokeBoeConstant := ec_choke_model_ref_value.stable_liq_to_boe(c_defer_event_oe.choke_model_id, p_daytime,'<=');
     ELSIF (c_defer_event_oe.condition = 'UNSTABLE_LIQ') THEN
       ln_chokeBoeConstant := ec_choke_model_ref_value.unstable_liq_to_boe(c_defer_event_oe.choke_model_id, p_daytime,'<=');
     ELSIF (c_defer_event_oe.condition = 'GAS') THEN
       ln_chokeBoeConstant := ec_choke_model_ref_value.gas_to_boe(c_defer_event_oe.choke_model_id, p_daytime,'<=');
     END IF;
     ln_loss := ln_loss * nvl(ln_chokeBoeConstant,0);
     ln_total_loss := ln_total_loss + nvl(ln_loss,0);
  END LOOP;

RETURN abs(ln_total_loss);

END getTotalOELosses;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcDailyVariance
-- Description    : This is to calculate total losses for the stream in a day in kboe.
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
FUNCTION calcDailyVariance(p_object_id VARCHAR2,p_strm_object_id  VARCHAR2,p_type  VARCHAR2, p_daytime DATE) RETURN NUMBER
--</EC-DOC>
IS

  CURSOR cur_strm_variance IS
    SELECT  dlse.net_mass,dlse.net_vol, dlse.choke_model_id, dlse.object_id,cmv.uom,cmv.condition
    FROM defer_loss_strm_event dlse, defer_loss_acc_event dlae, choke_model_version cmv
    WHERE dlse.daytime = p_daytime
    AND dlae.object_id = p_object_id
    AND dlse.event_no = dlae.event_no
    AND dlse.object_id = p_strm_object_id
    AND dlae.type = p_type
    AND dlse.choke_model_id = cmv.object_id
    AND cmv.daytime <= p_daytime
    AND nvl(cmv.end_date,p_daytime+1) > p_daytime;

    ln_loss NUMBER;
    ln_chokeBoeConstant  NUMBER;
    ln_total_loss NUMBER := 0 ;
    ln_retval NUMBER;

BEGIN

  FOR c_strm_variance IN cur_strm_variance LOOP
    IF c_strm_variance.uom IN ('STD_GAS_VOL', 'STD_OIL_VOL') THEN
      ln_loss := c_strm_variance.net_vol;
    ELSE
      ln_loss := c_strm_variance.net_mass;
    END IF;
    -- get the boeConstant. This is the constant for choke model to convert values in boe
    IF (c_strm_variance.condition = 'STABLE_LIQ') THEN
      ln_chokeBoeConstant := ec_choke_model_ref_value.stable_liq_to_boe(c_strm_variance.choke_model_id, p_daytime,'<=');
    ELSIF (c_strm_variance.condition = 'UNSTABLE_LIQ') THEN
      ln_chokeBoeConstant := ec_choke_model_ref_value.unstable_liq_to_boe(c_strm_variance.choke_model_id, p_daytime,'<=');
    ELSIF (c_strm_variance.condition = 'GAS') THEN
      ln_chokeBoeConstant := ec_choke_model_ref_value.gas_to_boe(c_strm_variance.choke_model_id, p_daytime,'<=');
    END IF;
    ln_loss := ln_loss * nvl(ln_chokeBoeConstant,0);
    ln_total_loss := ln_total_loss + nvl(ln_loss,0);
  END LOOP;
  ln_retval := ln_total_loss;
  IF ln_retval IS NOT NULL THEN
    ln_retval := Ecdp_Unit.convertValue(ln_retval,
                                                'BOE',
                                                'KBOE',
                                                p_daytime);
  END IF;
RETURN ln_retval;

END calcDailyVariance;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalPotentialBudgetkboe
-- Description    : Returns the Total Potential or Budget in kboe for facility or field per day.
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
FUNCTION getTotalPotentialBudgetkboe(p_object_id VARCHAR2,p_daytime DATE, p_type VARCHAR2) RETURN NUMBER
--</EC-DOC>
IS

 CURSOR cur_defer_event IS
   SELECT DISTINCT dlse.object_id, dlse.choke_model_id, cmv.uom, cmv.condition
   FROM defer_loss_strm_event dlse, defer_loss_acc_event dlae, choke_model_version cmv
   WHERE dlse.daytime = p_daytime
   AND dlse.event_no = dlae.event_no
   AND dlae.object_id = p_object_id
   AND dlae.type = p_type
   AND dlse.choke_model_id = cmv.object_id
   AND cmv.daytime <= p_daytime
   AND nvl(cmv.end_date,p_daytime+1) > p_daytime;

 CURSOR cur_db_unit(c_uom_meas_type VARCHAR2) IS
   SELECT unit
   FROM ctrl_uom_setup cus
   WHERE cus.measurement_type = c_uom_meas_type
   AND cus.db_unit_ind = 'Y';

  ln_planned NUMBER;
  ln_total_planned NUMBER :=0;
  ln_chokeBoeConstant  NUMBER;
  lv2_strm_uom VARCHAR2(32);
  lv2_db_unit VARCHAR2(16);
  ln_strmBoeConstant NUMBER;

BEGIN

  IF p_type = 'BUDGET' THEN
    FOR c_defer_event IN cur_defer_event LOOP
      IF c_defer_event.uom IN ('STD_GAS_VOL', 'STD_OIL_VOL') THEN
        ln_planned := ec_object_plan.volume_rate(c_defer_event.object_id,p_daytime,'STRM_PLAN_BUDGET');
        lv2_strm_uom := ecbp_defer_loss_accounting.getRateUom(c_defer_event.object_id, p_daytime,'VOLUME');
      ELSE
        ln_planned := ec_object_plan.mass_rate(c_defer_event.object_id,p_daytime,'STRM_PLAN_BUDGET');
        lv2_strm_uom := ecbp_defer_loss_accounting.getRateUom(c_defer_event.object_id, p_daytime,'MASS');
      END IF;
      FOR c_db_unit IN cur_db_unit(lv2_strm_uom) LOOP
        lv2_db_unit := c_db_unit.unit;
      END LOOP;
      -- get the boeConstant. This is the constant for stream to convert values into boe
      ln_strmBoeConstant := ue_defer_loss_accounting.getStrmBoeConstant(c_defer_event.object_id,p_daytime,lv2_db_unit);
      ln_planned   := ln_planned * nvl(ln_strmBoeConstant,0);
      ln_total_planned := ln_total_planned + nvl(ln_planned,0);
    END LOOP;
  ELSIF p_type = 'POTENTIAL' THEN
    FOR c_defer_event IN cur_defer_event LOOP
      -- get the boeConstant. This is the constant for choke model to convert values in boe
      IF (c_defer_event.condition = 'STABLE_LIQ') THEN
        ln_chokeBoeConstant := ec_choke_model_ref_value.stable_liq_to_boe(c_defer_event.choke_model_id, p_daytime,'<=');
      ELSIF (c_defer_event.condition = 'UNSTABLE_LIQ') THEN
        ln_chokeBoeConstant := ec_choke_model_ref_value.unstable_liq_to_boe(c_defer_event.choke_model_id, p_daytime,'<=');
      ELSIF (c_defer_event.condition = 'GAS') THEN
        ln_chokeBoeConstant := ec_choke_model_ref_value.gas_to_boe(c_defer_event.choke_model_id, p_daytime,'<=');
      END IF;
      ln_planned :=  ecbp_choke_model.calcTotalMppLip(c_defer_event.choke_model_id,p_daytime,'CHOKE_MODEL_MPP');
      ln_planned :=  ln_planned * nvl(ln_chokeBoeConstant,0);
      ln_total_planned :=  ln_total_planned + nvl(ln_planned,0);
    END LOOP;
  END IF;

  IF ln_total_planned IS NOT NULL THEN
    ln_total_planned := ecdp_unit.convertValue(ln_total_planned,'BOE','KBOE',p_daytime);
  END IF;

RETURN ln_total_planned ;
END getTotalPotentialBudgetkboe;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTotalActualkboe
-- Description    : Returns the Total actual in kboe for facility/field per day.
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
FUNCTION getTotalActualkboe(p_object_id VARCHAR2,p_daytime DATE, p_type VARCHAR2) RETURN NUMBER
--</EC-DOC>
IS

 CURSOR cur_defer_event IS
   SELECT DISTINCT dlse.object_id, dlse.choke_model_id, cmv.uom, cmv.condition
   FROM defer_loss_strm_event dlse, defer_loss_acc_event dlae, choke_model_version cmv
   WHERE dlse.daytime = p_daytime
   AND dlse.event_no = dlae.event_no
   AND dlae.object_id = p_object_id
   AND dlae.type = p_type
   AND dlse.choke_model_id = cmv.object_id
   AND cmv.daytime <= p_daytime
   AND nvl(cmv.end_date,p_daytime+1) > p_daytime;

 CURSOR cur_db_unit(c_uom_meas_type VARCHAR2) IS
   SELECT unit
   FROM ctrl_uom_setup cus
   WHERE cus.measurement_type = c_uom_meas_type
   AND cus.db_unit_ind = 'Y';

  ln_actual NUMBER;
  ln_total_actual NUMBER :=0;
  lv2_db_unit VARCHAR2(16);
  ln_strmBoeConstant NUMBER;

BEGIN

    FOR c_defer_event IN cur_defer_event LOOP
      IF c_defer_event.uom IN ('STD_GAS_VOL', 'STD_OIL_VOL') THEN
        ln_actual :=  EcBp_Stream_Fluid.findNetStdVol(c_defer_event.object_id,p_daytime);
      ELSE
        ln_actual := EcBp_Stream_Fluid.findNetStdMass(c_defer_event.object_id,p_daytime);
      END IF;
      FOR c_db_unit IN cur_db_unit(c_defer_event.uom) LOOP
        lv2_db_unit := c_db_unit.unit;
      END LOOP;
      -- get the boeConstant. This is the constant for stream to convert values into boe
      ln_strmBoeConstant := ue_defer_loss_accounting.getStrmBoeConstant(c_defer_event.object_id,p_daytime,lv2_db_unit);
      ln_actual   := ln_actual * nvl(ln_strmBoeConstant,0);
      ln_total_actual:= ln_total_actual + nvl(ln_actual,0);
    END LOOP;
    IF ln_total_actual IS NOT NULL THEN
      ln_total_actual := ecdp_unit.convertValue(ln_total_actual,'BOE','KBOE',p_daytime);
    END IF;

RETURN ln_total_actual;
END getTotalActualkboe;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       :  getEventNo
-- Description    : This is to get the event_no for the daytime which is generated during instantiation.
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
FUNCTION getEventNo(p_object_id VARCHAR2,p_daytime DATE) RETURN NUMBER
--</EC-DOC>
IS
  CURSOR c_defer_loss_acc_event IS
  SELECT  dlae.event_no
  FROM defer_loss_acc_event dlae
  WHERE dlae.object_id = ecdp_groups.findParentObjectId('FCTY_CLASS_1','operational','STREAM',p_object_id,p_daytime)
  AND dlae.daytime = p_daytime
  AND dlae.type is NULL;

  ln_retval  NUMBER;

BEGIN

  FOR c_event_no IN c_defer_loss_acc_event LOOP
    ln_retval := c_event_no.event_no;
  END LOOP;

  IF ln_retval IS NULL THEN
    ln_retval := EcDp_System_Key.assignNextNumber('DEFER_LOSS_ACC_EVENT');
  END IF;

RETURN ln_retval;
END  getEventNo;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getPlannedVol
-- Description    : This is to return planned vol for a stream.
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
FUNCTION getPlannedVol(p_object_id VARCHAR2,p_daytime DATE,p_class_name VARCHAR2) RETURN NUMBER
--</EC-DOC>
IS

  ln_retval  NUMBER;

BEGIN

  ln_retval := ue_defer_loss_accounting.getPlannedVol(p_object_id,p_daytime);
  IF ln_retval IS NULL THEN
    ln_retval := ec_object_plan.volume_rate(p_object_id,p_daytime,p_class_name,'<=');
  END IF;

RETURN ln_retval;
END  getPlannedVol;

END EcBp_Defer_Loss_Accounting;