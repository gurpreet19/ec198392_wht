CREATE OR REPLACE PACKAGE BODY EcDp_Well_Event_Detail IS

/****************************************************************
** Package        :  EcDp_Well_Event_Detail, body part
**
** $Revision: 1.4.46.1 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Event Injections Well Data.
** Documentation  :  www.energy-components.com
**
** Created  : 31.07.2007  Sarojini Rajaretnam
**
** Modification history:
**
** Version  Date       Whom      Change description:
** -------  --------   ----      --------------------------------------
**          13.02.08   rajarsar  Updated saveAndCalcInjRate
**          26.05.08   oonnnng   ECPD-8471: Replace USER_EXIT test statements with [ (substr(lv2_gas_lift_method,1,9) = EcDp_Calc_Method.USER_EXIT) ].
**          28.05.15   abdulmaw  ECPD-31002: Updated calcInjectionRate
*****************************************************************/
--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : saveAndCalcInjRate                                                   --
-- Description    : updates avg_inj_rate in well_event when the calculate and save button is clicked
--                                                    --
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : well_event
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
PROCEDURE saveAndCalcInjRate(p_object_id VARCHAR2,
                             p_daytime DATE,
                             p_event_type VARCHAR2,
                             p_rate_calc_method VARCHAR2,
                             p_user VARCHAR2)
--</EC-DOC>
IS


  ln_rate NUMBER;



  CURSOR c_well_event_detail IS
  SELECT *
  FROM well_event_detail  WHERE object_id = p_object_id
  AND daytime = p_daytime;



BEGIN

  IF (p_rate_calc_method = 'METER_READING') THEN
      ln_rate := ecbp_well_event_detail.calcInjectionRate(p_object_id,p_daytime,'METER_READING',p_event_type);
  ELSIF (p_rate_calc_method = 'VOLUME_DURATION') THEN
    ln_rate := ecbp_well_event_detail.calcInjectionRate(p_object_id,p_daytime,'VOLUME_DURATION',p_event_type);
  ELSIF (substr(p_rate_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_rate := ecbp_well_event_detail.calcInjectionRate(p_object_id,p_daytime,'USER_EXIT',p_event_type);
  ELSE ln_rate := Null;
  END IF;

  IF (ln_rate IS NOT NULL ) THEN
  -- update avg_inj_rate in well event with the calculated value
    UPDATE well_event set avg_inj_rate = ln_rate, rate_source = 'CALC',
    last_updated_by = p_user
    WHERE object_id = p_object_id
    AND daytime = p_daytime
    AND event_type = p_event_type;
  END IF;

 END saveAndCalcInjRate;

END  EcDp_Well_Event_Detail;