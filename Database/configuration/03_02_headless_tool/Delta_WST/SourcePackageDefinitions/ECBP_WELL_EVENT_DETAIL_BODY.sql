CREATE OR REPLACE PACKAGE BODY EcBp_Well_Event_Detail IS

/****************************************************************
** Package        :  EcBp_Well_Event_Detail, header part
**
** $Revision: 1.11 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Event Injections Well Data.
** Documentation  :  www.energy-components.com
**
** Created  : 31.07.2007  Sarojini Rajaretnam
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
**16.11.07   rajarsar  ECPD-6834: Updated function getDuration, calcInjectionRate, calcInjectionVolume and added getLastClosingDaytime,getLastNotNullClosingReading
**25.01.08   rajarsar  ECPD-6783: Updated Added getLastClosingDaytime and getLastNotNullClosingReading
**13.02.08   rajarsar  ECPD-6783: Updated Added getLastClosingDaytime and getLastNotNullClosingReading
**26.05.08   oonnnng   ECPD-8471: Replace USER_EXIT test statements with [ (substr(lv2_gas_lift_method,1,9) = EcDp_Calc_Method.USER_EXIT) ].
**28.10.09   oonnnng   ECPD-12971: Updated calcInjectionVolume() function to use both opening and opening_override for METER_READING calculation.
**02.05.10  aliassit  ECPD-14539: Modified function calcInjectionRate() to check for no divide by zero for rate_calc_method='VOLUME_DURATION'
**01.03.11   madondin  ECPD-16316: Updated calcInjectionVolume() function to check if ln_opening_override is null
**28.05.15   abdulmaw  ECPD-30716: Updated calcInjectionVolume and calcInjectionRate
*****************************************************************/


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getDuration                                                   --
-- Description    : Returns duration if rate calc method is METER_READING
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : well_event_detail
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
FUNCTION getDuration(
  p_object_id       well.object_id%TYPE,
  p_daytime DATE
  )

RETURN NUMBER
--</EC-DOC>
IS

ln_return_val       NUMBER;

CURSOR c_well_event_detail IS
SELECT (end_date - opening_daytime) as duration
FROM well_event_detail
WHERE object_id = p_object_id
AND daytime = p_daytime;




BEGIN

  ln_return_val := null;

   FOR cur_well_event_detail IN c_well_event_detail LOOP
     ln_return_val := cur_well_event_detail.duration;
   END LOOP;


  RETURN ln_return_val;
END getDuration;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : calcInjectionRate                                                   --
-- Description    : Returns calculated Injection Rate
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : well_event_detail
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
FUNCTION calcInjectionRate(
  p_object_id        VARCHAR2,
  p_daytime DATE,
  p_rate_calc_method VARCHAR2,
  p_event_type VARCHAR2 )

RETURN NUMBER
--</EC-DOC>
IS


ln_net_vol          NUMBER;
ln_rate             NUMBER;
ln_volume           NUMBER;
ln_duration         NUMBER;
ln_return_val       NUMBER;


CURSOR c_well_event_detail IS
SELECT *
FROM well_event_detail
WHERE object_id = p_object_id
AND daytime = p_daytime;



BEGIN

    ln_return_val := null;
    ln_rate := null;

    FOR cur_well_event_detail IN c_well_event_detail LOOP
      -- find first and last production date
      ln_volume := cur_well_event_detail.volume;
      ln_duration := cur_well_event_detail.duration_hrs;

    END LOOP;

    IF (p_rate_calc_method = 'METER_READING') THEN
      ln_net_vol := calcInjectionVolume(p_object_id, p_daytime, p_rate_calc_method, p_event_type);
      ln_duration := getDuration(p_object_id,p_daytime);
      If ln_duration > 0 then
        ln_rate := ln_net_vol / ln_duration;
      END IF;

    ELSIF (p_rate_calc_method  = 'VOLUME_DURATION') THEN

      IF ln_volume IS NOT NULL AND ln_duration > 0 THEN
        ln_rate := ln_volume / ln_duration *24;
      END IF;

    ELSIF (substr(p_rate_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_rate :=  ue_well_event_detail.calcInjectionRate(p_object_id,p_daytime,p_event_type);

    END IF;
    ln_return_val := ln_rate;



  RETURN ln_return_val;
END calcInjectionRate;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : calcInjectionVolume                                                   --
-- Description    : Returns calculated Injection Volume
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : well_event_detail
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
FUNCTION calcInjectionVolume(
  p_object_id        VARCHAR2,
  p_daytime DATE,
  p_rate_calc_method VARCHAR2,
  p_event_type VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS


ln_return_val       NUMBER;
ln_closing_reading  NUMBER;
ln_opening_override NUMBER;
ln_opening          NUMBER;
ln_manual_adj       NUMBER;
ln_meter_factor     NUMBER;
ln_conver_factor    NUMBER;
ln_rollover_val     NUMBER;
ln_meter_override   NUMBER;

CURSOR c_well_event_detail IS
SELECT *
FROM well_event_detail
WHERE object_id = p_object_id
AND daytime = p_daytime;


BEGIN

  ln_return_val := 0;
  IF (p_rate_calc_method = 'METER_READING') THEN

      FOR cur_well_event_detail IN c_well_event_detail LOOP
        ln_closing_reading :=  cur_well_event_detail.closing_reading;
        ln_opening_override:=  cur_well_event_detail.opening_override;
        ln_opening         :=  ec_well_event_detail.closing_reading(p_object_id,p_daytime,p_event_type,'<');

        --check if ln_opening_override is null, get from getLastNotNullClosingReading
        IF ln_opening_override IS NULL THEN
           IF ec_well_reference_value.volume_entry_flag(cur_well_event_detail.object_id,cur_well_event_detail.daytime,'<=')='Y' THEN
             ln_opening := 0;
           END IF;
        END IF;


        ln_meter_override  := cur_well_event_detail.meter_override;
        ln_meter_factor    :=  ec_well_reference_value.meter_factor(p_object_id,p_daytime, '<=');
        ln_manual_adj      :=  cur_well_event_detail.adj_vol;
        ln_conver_factor   :=  ec_well_reference_value.conversion_factor(p_object_id,p_daytime, '<=');
        ln_rollover_val    :=  ec_well_reference_value.totalizer_max_count(p_object_id, p_daytime,'<=');

        IF (NVL(ln_opening_override, ln_opening) > ln_closing_reading) THEN
          ln_return_val := ((ln_closing_reading - nvl(ln_opening_override,ln_opening) + ln_rollover_val) * nvl(nvl(ln_meter_override, ln_meter_factor), 1)*  nvl(ln_conver_factor, 1)) + nvl( ln_manual_adj, 0) ;
        ELSE
          ln_return_val := ((ln_closing_reading - nvl(ln_opening_override,ln_opening)) * nvl(nvl(ln_meter_override, ln_meter_factor), 1) *  nvl(ln_conver_factor, 1)) + nvl( ln_manual_adj, 0) ;
        END IF;

      END LOOP;
  END IF;
  RETURN ln_return_val;
END calcInjectionVolume;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getLastClosingDaytime
-- Description    :
--
-- Preconditions  :
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
---------------------------------------------------------------------------------------------------
FUNCTION getLastClosingDaytime (
  p_object_id        VARCHAR2,
  p_class_name       VARCHAR2,
  p_daytime DATE
)

RETURN DATE
--</EC-DOC>
IS
  ld_return          DATE;



CURSOR c_last_closing (cp_object_id VARCHAR2, cp_class_name VARCHAR2, cp_daytime DATE) IS
   SELECT max(se.end_date) max_end_date FROM well_event_detail se
    WHERE se.object_id = cp_object_id AND
          se.class_name = cp_class_name AND
          se.daytime <= cp_daytime;
BEGIN

  FOR cur_closing IN c_last_closing(p_object_id,p_class_name,p_daytime) LOOP
    ld_return := cur_closing.max_end_date;
  END LOOP;

  RETURN ld_return;

END getLastClosingDaytime;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLastNotNullClosingReading
-- Description    : Returns the latest available closing reading
--
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getLastNotNullClosingReading(
   p_object_id        VARCHAR2,
  p_class_name       VARCHAR2,
  p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS


CURSOR c_closing_reading(cp_object_id VARCHAR2, cp_class_name VARCHAR2, cp_daytime DATE) IS
  SELECT closing_reading
  FROM well_event_detail se
  WHERE se.object_id = cp_object_id AND
  se.class_name = cp_class_name
  AND se.daytime = (
  SELECT max(se2.daytime)From well_event_detail se2
  WHERE se2.object_id = cp_object_id AND
  se2.class_name = cp_class_name
  AND se2.closing_reading is not null
  AND se2.daytime < cp_daytime);

  ln_closing_reading  NUMBER;

BEGIN

   FOR curRec IN c_closing_reading(p_object_id, p_class_name,p_daytime) LOOP
     ln_closing_reading := curRec.closing_reading;
   END LOOP;

   RETURN ln_closing_reading;

END getLastNotNullClosingReading;


END  EcBp_Well_Event_Detail;