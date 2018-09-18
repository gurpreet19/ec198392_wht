CREATE OR REPLACE PACKAGE BODY EcBp_Choke_Model IS
/***********************************************************************************************************************************************
** Package  :  EcBp_Choke_Model, body part
**
** $Revision: 1.6 $
**
** Purpose  :  Business functions related to Choke Model
**
** Created  :  09.11.2010 Sarojini Rajaretnam
**
** How-To   :  Se www.energy-components.com for full version
**
** Modification history:
**
** Date:      Whom:    Change description:
** ---------- -----    --------------------------------------------
** 12.10.2010 rajarsar Initial version
** 27.12.2010 rajarsar ECPD-16192:Updated convertToStableLiquid and convertToUnStableLiquid
** 24.01.2011 rajarsar ECPD-16192:Added function calcTotalLip
** 07.02.2011 rajarsar ECPD-16192:Added function calcTotalEventLoss
** 12.12.2012 rajarsar ECPD-18891:Removed function calcTotalEventLoss
***********************************************************************************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcTotalMppLip
-- Description    : Calculate Total MPP and LIP.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcTotalMppLip(
         p_object_id VARCHAR2,
         p_daytime     DATE,
         p_class_name VARCHAR2,
         p_condition VARCHAR2 DEFAULT NULL
        )

RETURN NUMBER
--<EC-DOC>
IS

    ln_return_val  NUMBER := NULL;
    ln_mpp_qty NUMBER := NULL;
    ln_change_qty NUMBER := NULL;
    ln_condition VARCHAR2(32);

  CURSOR c_choke_model_mpp_condition  IS
 SELECT sum(cmlc.change_qty) change_qty
  FROM choke_model_lip cml,
       choke_model_lip_child cmlc, choke_model_version cmv
 WHERE cmlc.choke_model_id = p_object_id
   and cml.lip_opp_id = cmlc.lip_opp_id
   and cml.object_id = cmlc.object_id
   AND cml.include_mpp = 'Y'
   AND cmlc.from_day <= p_daytime
   AND nvl(cmlc.to_day, p_daytime + 1) > p_daytime
   AND cmlc.choke_model_id = cmv.object_id
   AND cmv.condition = p_condition;

 CURSOR c_choke_model_mpp  IS
 SELECT sum(cmlc.change_qty) change_qty
  FROM choke_model_lip cml,
       choke_model_lip_child cmlc
 WHERE cmlc.choke_model_id = p_object_id
   and cml.lip_opp_id = cmlc.lip_opp_id
   and cml.object_id = cmlc.object_id
   AND cml.include_mpp = 'Y'
   AND cmlc.from_day <= p_daytime
   AND nvl(cmlc.to_day, p_daytime + 1) > p_daytime;

BEGIN

    ln_mpp_qty := ec_object_potential.mpp_qty(p_object_id, p_daytime,p_class_name,'<=');
    ln_condition := ec_choke_model_version.condition(p_object_id, p_daytime,'<=');

    -- Get the change qty of all sub chokes that belongs to this parent choke
    IF p_condition IS NOT NULL AND p_condition=ln_condition THEN
      FOR cur_row IN c_choke_model_mpp_condition LOOP
        ln_change_qty  :=  cur_row.change_qty;
      END LOOP;
      ln_return_val := nvl(ln_mpp_qty,0) + nvl(ln_change_qty,0);
    ELSIF p_condition IS NOT NULL AND p_condition !=ln_condition THEN
      ln_return_val := NULL;
    ELSE
      FOR cur_row IN c_choke_model_mpp LOOP
        ln_change_qty  :=  cur_row.change_qty;
      END LOOP;
      ln_return_val := nvl(ln_mpp_qty,0) + nvl(ln_change_qty,0);
   END IF;

  RETURN ln_return_val;

END calcTotalMppLip;


---------------------------------------------------------------------------------------------------
-- Function       : calcTotalLip
-- Description    : Calculate Total LIP.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcTotalLip(
         p_object_id VARCHAR2,
         p_daytime     DATE

        )

RETURN NUMBER
--<EC-DOC>
IS

    ln_return_val  NUMBER := NULL;
    ln_change_qty NUMBER := NULL;


  CURSOR c_choke_model_lip_child  IS
 SELECT sum(cmlc.change_qty) change_qty
  FROM choke_model_lip cml,
       choke_model_lip_child cmlc, choke_model_version cmv
 WHERE cmlc.choke_model_id = p_object_id
   and cml.lip_opp_id = cmlc.lip_opp_id
   and cml.object_id = cmlc.object_id
   AND cml.include_mpp = 'Y'
   AND cmlc.from_day <= p_daytime
   AND nvl(cmlc.to_day, p_daytime + 1) > p_daytime
   AND cmlc.choke_model_id = cmv.object_id;

BEGIN

    FOR cur_row IN c_choke_model_lip_child LOOP
       ln_return_val  :=  cur_row.change_qty;
    END LOOP;

  RETURN ln_return_val;

END calcTotalLip;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : convertToStableLiquid
-- Description    : Convert value to Stable Liquid based on reference value from Choke Model Reference Value.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION convertToStableLiquid(
         p_object_id VARCHAR2,
         p_daytime     DATE,
         p_value NUMBER
        )

RETURN NUMBER
--<EC-DOC>
IS

    ln_return_val  NUMBER := NULL;
    lv2_condition VARCHAR2(32);
    ln_convertConstant NUMBER;


BEGIN

    lv2_condition      := ec_choke_model_version.condition(p_object_id, p_daytime,'<=');
    ln_convertConstant := ec_choke_model_ref_value.unstbl_liq_to_stbl_liq(p_object_id, p_daytime,'<=');

    IF (lv2_condition = 'UNSTABLE_LIQ') AND (ln_convertConstant IS NOT NUll) THEN
      ln_return_val := p_value * ln_convertConstant;
    ELSIF  (lv2_condition = 'STABLE_LIQ') THEN
      ln_return_val := p_value;
    END IF;

  RETURN ln_return_val;

END convertToStableLiquid;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : convertToUnstableLiquid
-- Description    : Convert value to Unstable Liquid based on reference value from Choke Model Reference Value.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : choke_model_version, choke_model_ref_value
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION convertToUnstableLiquid(
         p_object_id VARCHAR2,
         p_daytime     DATE,
         p_value NUMBER
        )

RETURN NUMBER
--<EC-DOC>
IS

    ln_return_val  NUMBER := NULL;
    lv2_condition VARCHAR2(32);
    ln_convertConstant NUMBER;


BEGIN

    lv2_condition      := ec_choke_model_version.condition(p_object_id, p_daytime,'<=');
    ln_convertConstant := ec_choke_model_ref_value.stbl_liq_to_unstbl_liq(p_object_id, p_daytime,'<=');

    IF (lv2_condition = 'STABLE_LIQ') AND (ln_convertConstant IS NOT NULL) THEN
      ln_return_val := p_value * ln_convertConstant;
    ELSIF  (lv2_condition = 'UNSTABLE_LIQ') THEN
      ln_return_val := p_value;
    END IF;

  RETURN ln_return_val;

END convertToUnstableLiquid;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : convertToKboe
-- Description    : Convert value to kboe based on reference value from Choke Model Reference Value.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : choke_model_version, choke_model_ref_value, object_potential
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION convertTokboe(
         p_object_id VARCHAR2,
         p_daytime     DATE,
         p_value NUMBER
        )

RETURN NUMBER
--<EC-DOC>
IS

    ln_return_val   NUMBER := NULL;
    ln_child_record NUMBER;
    ln_kboeConstant NUMBER;
    lv2_condition VARCHAR2(32);


   CURSOR c_child_event  IS
    SELECT count(object_id) totalrecord
    FROM choke_model_version cmv
    WHERE cmv.parent_choke_model_id = p_object_id
    AND cmv.daytime <= p_daytime
    AND nvl(cmv.end_date, p_daytime + 1) > p_daytime;

BEGIN

     lv2_condition      := ec_choke_model_version.condition(p_object_id, p_daytime,'<=');
     ln_child_record    := 0;

     IF (lv2_condition = 'STABLE_LIQ') THEN
       ln_kboeconstant := ec_choke_model_ref_value.stable_liq_to_boe(p_object_id, p_daytime,'<=');
     ELSIF (lv2_condition = 'UNSTABLE_LIQ') THEN
       ln_kboeconstant := ec_choke_model_ref_value.unstable_liq_to_boe(p_object_id, p_daytime,'<=');
     ELSIF (lv2_condition = 'GAS') THEN
       ln_kboeconstant := ec_choke_model_ref_value.gas_to_boe(p_object_id, p_daytime,'<=');
     END IF;

    FOR cur_child_event IN c_child_event LOOP
      ln_child_record := cur_child_event.totalrecord ;
    END LOOP;

    IF (ln_kboeconstant IS NOT NUll) THEN
      IF ln_child_record > 0 THEN
        ln_return_val :=calcTotalMppLip(p_object_id,p_daytime,'CHOKE_MODEL_MPP') * ln_kboeConstant;
      ELSE
        ln_return_val := p_value * ln_kboeConstant;
      END IF;
    END IF;

  RETURN ln_return_val;

END convertTokboe;


END EcBp_Choke_Model;