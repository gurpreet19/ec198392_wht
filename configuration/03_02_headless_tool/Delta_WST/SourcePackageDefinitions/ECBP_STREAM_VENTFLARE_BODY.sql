CREATE OR REPLACE PACKAGE BODY EcBp_Stream_VentFlare IS
/****************************************************************
** Package        :  EcBp_Stream_VentFlare
**
** $Revision: 1.26 $
**
** Purpose        :  This package is responsible for supporting business functions
**                         related to Daily Gas Stream - Vent and Flare.
**
** Documentation  :  www.energy-components.com
**
** Created  :  17.03.2010  Sarojini Rajaretnam
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 17.03.2010 rajarsar ECPD-4828:Initial version.
** 31.05.2010 rajarsar ECPD-14622:Added function calcEventVol, calcWellDuration and calcWellEventVol
**                     updated calcTotalRelease,calcNormalRelease,calcRunHours,calcNetVol,calcRoutineRunHours,sumNormalRelease calcUpsetRelease and calcNormalMTDAvg
**                     removed calcRecVapours, countRecVapours and sumRecVapours
** 13.08.2010 rajarsar ECPD-15495:Updated calcRoutineRunHours to add a new parameter which is p_asset_id
** 07.10.2010 sharawan ECPD-14866: Change 'vapor' to 'vapour' to standardize the spelling
** 08.10.2010 farhaann ECPD-14042: Added getTheoreticalRate, sumEqpmWellVolTheor, calcWellContribTheor, getTheorGasOilRatio and calcMtd
** 31.01.2011 farhaann ECPD-16411: Changed net to grs in calcMtd. Renamed calcNetVol to calcGrsVol
** 08.02.2011 oonnnng  ECPD-16473: Modified getPotentialRate() function to call getPwelOnStreamHrs() function to retrieve the on stream hours.
** 08.02.2011 farhaann ECPD-16411: Modified calcVaporGenerated to use grs vol instead of net vol.
** 19.04.2011 syazwnur ECPD-16648:Added calcMtdDuration and countMtdRec
** 24.06.2011 sharawan ECPD-17714: Modified error code for calcGrsVol.
** 18.07.2011 rajarsar ECPD-17650: Modified calcRelease and sumNonRouRelease to return correct value when downstream sales/fuel is checked.
** 28.07.2011 rajarsar ECPD-18081: Added recalcGrsVol
** 28.07.2011 rajarsar ECPD-18192: Modified calcMtdDuration
** 16.11.2011 abdulmaw ECPD-18921: Modified calcMtdDuration to return correct values when downstream sales/fuel is checked.
** 21.11.2011 madondin ECPD-18442: Modified calcWellContrib, calcVRUFailure and calcTotalRelease to improve performance
** 13.06.2012 choonshu ECPD-19245: Modified calcWellDuration and calcWellContrib
** 12.09.2012 leongwen ECPD-21534: Removed the p_end_daytime in FUNCTION calcWellContrib and calcWellDuration
** 21.10.2013 genasdev ECPD-25813: Modified calcWellContrib and getPotentialRate function to include Gas_lift.
** 23.01.2014 jainopan ECPD-17961: Modified sumNormalRelease to call ue_stream_ventflare.calcPotensialRelease instead of ue_stream_ventflare.calcNormalRelease
** 14.02.2014 leongwen ECPD-17958: Modified calcWellDuration to include user exit.
** 09.04.2014 kumarsur ECPD-27001: Modified recalcGrsVol and calcGrsVol, rename to recalcGrsVolMass and calcGrsVolMass.
** 31.12.2014 dhavaalo ECPD-29571: Update all reference from EQUIPMENT to EQPM
** 29.01.2015 wonggkai ECPD-29387: Modified calcWellDuration to support PD.0020 Well Deferment screen.
** 26.02.2015 wonggkai ECPD-29387: Modified calcWellDuration to support multiple events from Well Deferment and Well Downtime.
** 18.09.2017 shindani ECPD-44259: Modified calcRunHours and calcRoutineRunHours to support new equipment downtime(PD.0022) screen.
** 06-11-2017 leongwen ECPD-50437: Modified FUNCTION calcWell to include the check on class_name for well_deferment table
** 21.11.2017 dhavaalo ECPD-45043: Remove reference of well_equip_Downtime. Remove un-used variables.
** 16.01.2018 chaudgau ECPD-51616: Modified calcTotalRelease and calcEventVol for performance improvement.
** 17-01-2018 singishi ECPD-47302: Rename table well_deferment to deferment_event
** 23.03.2018 shindani ECPD-44451: Added support to calcNormalRelease,calcPotensialRelease,calcUpsetRelease.
                                   Modified functions sumRoutineRelease,sumNonRouRelease,calcVapourGenerated and calcGrsVolMass.
*****************************************************************/

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getStreamSetCode                                                  --
-- Description    : Returns Stream Set Code for the stream.
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
FUNCTION getStreamSetCode(p_object_id VARCHAR2, p_daytime DATE)

RETURN VARCHAR2
--</EC-DOC>
IS


lv2_strm_set_code VARCHAR2(32);

CURSOR c_strm_set_list IS
SELECT ssl.stream_set
  FROM strm_set_list ssl
 WHERE ssl.object_id = p_object_id
   AND ssl.stream_set in ('PO.0086_VF_R',  'PO.0086_VF_NR')
   AND p_daytime >= ssl.from_date
   AND p_daytime < Nvl(ssl.end_date, p_daytime + 1);

BEGIN

  FOR c_strm_set_code IN c_strm_set_list LOOP
    lv2_strm_set_code:= c_strm_set_code.stream_set;
   END LOOP;

  RETURN lv2_strm_set_code;

END getStreamSetCode;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : calcNormalRelease                                                              --
-- Description    :
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
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
FUNCTION calcNormalRelease(p_object_id VARCHAR2, p_asset_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_vapour_recovery(cp_daytime DATE) IS
SELECT asset_id,
       shares,
       sequence,
       (ec_eqpm_reference_value.normal_rec_cap_rate(asset_id, daytime, '<=') / 24) *
        calcRoutineRunHours(parent_object_id,asset_id, daytime) as adj_cap
       ,calcRoutineAvailVapour(object_id
                             ,asset_id
                             ,parent_object_id
                             ,daytime) as avail
  FROM V_STRM_DAY_ROU_REC_VAP
 WHERE daytime = cp_daytime
   AND object_id = p_object_id
 ORDER BY sequence;

CURSOR c_vapour_release(cp_daytime DATE, cp_start_system_sequence NUMBER, ln_this_sequence NUMBER) IS
SELECT asset_id,
       shares,
       sequence,
       (ec_eqpm_reference_value.normal_rec_cap_rate(asset_id, daytime, '<=') / 24) *
        calcRoutineRunHours(parent_object_id,asset_id, daytime) as adj_cap
       ,calcRoutineAvailVapour(object_id
                             ,asset_id
                             ,parent_object_id
                             ,daytime) as avail
  FROM V_STRM_DAY_ROU_REC_VAP
 WHERE daytime = cp_daytime
   AND object_id = p_object_id
   AND sequence >= cp_start_system_sequence
   AND sequence <= ln_this_sequence;

CURSOR c_next_share (cp_current_sequence NUMBER) IS
SELECT shares
  FROM V_STRM_DAY_ROU_REC_VAP
 WHERE daytime = p_daytime
   AND object_id = p_object_id
   AND sequence = cp_current_sequence + 1;

     ln_calcNormalRelease NUMBER;
     ln_total_release NUMBER;
     ln_individual_avail NUMBER;
     ln_total_individual_avail NUMBER := 0;
     lv2_next_share VARCHAR2(1) := 'Y';
     ln_this_sys_end_seq NUMBER;
     ln_this_sys_start_seq NUMBER;
     ln_no_share_rel NUMBER;

BEGIN

    ln_calcNormalRelease := ue_stream_ventflare.calcNormalRelease(p_object_id, p_asset_id, p_daytime);

    IF ln_calcNormalRelease IS NULL THEN
       SELECT MIN(sequence)
       INTO ln_this_sys_start_seq
       FROM V_STRM_DAY_ROU_REC_VAP
       WHERE object_id = p_object_id
       AND daytime = p_daytime;

       FOR cur_vap_rec IN c_vapour_recovery (p_daytime) LOOP
         lv2_next_share := NULL;
         ln_this_sys_end_seq := cur_vap_rec.sequence;
         FOR cur_next_share IN c_next_share (cur_vap_rec.sequence) LOOP
           lv2_next_share := cur_next_share.shares;
         END LOOP;
         ln_individual_avail := NVL(cur_vap_rec.avail,0) - NVL(cur_vap_rec.adj_cap,0);
         IF ln_individual_avail < 0 THEN
           ln_individual_avail := 0;
         END IF;
         ln_total_individual_avail := ln_total_individual_avail + ln_individual_avail;
         ln_total_release := calcPotensialRelease(p_object_id, cur_vap_rec.asset_id, p_daytime);
         IF NVL(cur_vap_rec.shares,'N') = 'Y' and (lv2_next_share = 'N' OR lv2_next_share IS NULL) THEN
           FOR cur_vap_rel IN c_vapour_release (p_daytime, ln_this_sys_start_seq, ln_this_sys_end_seq) LOOP
             IF p_asset_id = cur_vap_rel.asset_id THEN
               IF NVL(cur_vap_rel.avail,0) - NVL(cur_vap_rel.adj_cap,0) > 0 THEN
                 RETURN (cur_vap_rel.avail - cur_vap_rel.adj_cap) * (ln_total_release / ln_total_individual_avail);
               ELSE
                 RETURN 0;
               END IF;
             END IF;
           END LOOP;
           ln_total_release := 0;
           ln_total_individual_avail := 0;
         ELSIF NVL(cur_vap_rec.shares,'N') = 'N' AND (lv2_next_share = 'N' OR lv2_next_share IS NULL) THEN
           IF p_asset_id = cur_vap_rec.asset_id THEN
             ln_no_share_rel := ln_total_release;
             IF ln_no_share_rel > 0 THEN
               RETURN ln_no_share_rel;
             ELSE
               RETURN 0;
             END IF;
           END IF;
         END IF;
       END LOOP;
      RETURN 0;
    END IF;
   RETURN ln_calcNormalRelease;

END calcNormalRelease;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calcPotensialRelease
-- Description    :
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
FUNCTION calcPotensialRelease(p_object_id VARCHAR2, p_asset_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_vapour_recovery(cp_daytime DATE) IS
SELECT asset_id,
       sequence,
       shares,
       (ec_eqpm_reference_value.normal_rec_cap_rate(asset_id, daytime, '<=') / 24) *
        calcRoutineRunHours(parent_object_id,asset_id, daytime) as adj_cap
       ,calcRoutineAvailVapour(object_id
                             ,asset_id
                             ,parent_object_id
                             ,daytime) as avail
  FROM V_STRM_DAY_ROU_REC_VAP
 WHERE daytime = cp_daytime
   AND object_id = p_object_id
 ORDER BY sequence;

CURSOR c_next_share (cp_current_sequence NUMBER) IS
SELECT shares
  FROM V_STRM_DAY_ROU_REC_VAP
 WHERE daytime = p_daytime
   AND object_id = p_object_id
   AND sequence = cp_current_sequence + 1;

     ln_potensial_rel NUMBER;
     ln_previous_potensial_rel NUMBER := 0;
     ln_current_avail NUMBER;
     ln_current_adj_cap NUMBER;
     lv2_next_share VARCHAR2(1) := 'N';

BEGIN

     ln_potensial_rel := ue_stream_ventflare.calcPotensialRelease(p_object_id, p_asset_id, p_daytime);

     IF ln_potensial_rel IS NULL THEN
       FOR cur_vap_rec IN c_vapour_recovery (p_daytime) LOOP

         lv2_next_share := NULL;

         FOR cur_next_share IN c_next_share (cur_vap_rec.sequence) LOOP
           lv2_next_share := cur_next_share.shares;
         END LOOP;

         ln_current_avail   := nvl(cur_vap_rec.avail,0);
         ln_current_adj_cap := nvl(cur_vap_rec.adj_cap,0);

         IF nvl(cur_vap_rec.shares, 'N') = 'Y' THEN
           ln_potensial_rel := ln_previous_potensial_rel + ln_current_avail - ln_current_adj_cap;
         ELSE
           ln_potensial_rel := ln_current_avail - ln_current_adj_cap;
         END IF;

         IF ln_potensial_rel < 0 THEN
           ln_potensial_rel :=0;
         END IF;

         IF nvl(lv2_next_share,'N') = 'N' THEN
           ln_previous_potensial_rel :=0;
         ELSE
           ln_previous_potensial_rel := ln_potensial_rel;
         END IF;

         IF p_asset_id = cur_vap_rec.asset_id THEN
           RETURN ln_potensial_rel;
         END IF;

       END LOOP;
     END IF;
    RETURN ln_potensial_rel;
END calcPotensialRelease;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : calcUpsetRelease                                                              --
-- Description    :
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
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
FUNCTION calcUpsetRelease(p_object_id VARCHAR2, p_asset_id VARCHAR2, p_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS
    CURSOR c_vapour_release IS
      SELECT (ec_eqpm_reference_value.normal_rec_cap_rate(asset_id, daytime, '<=') / 24) *
             (calcRunHours(p_asset_id, p_daytime) -
              calcRoutineRunHours(parent_object_id,asset_id,p_daytime)) as adj_cap,
             calcUpsetAvailVapour(object_id,
                                  asset_id,
                                  parent_object_id,
                                  daytime) as avail
      FROM V_STRM_DAY_ROU_REC_VAP
      WHERE daytime = p_daytime
      AND object_id = p_object_id
      AND asset_id = p_asset_id
      ORDER BY sequence;

    ln_calcUpsetRelease NUMBER;
    ln_current_avail    NUMBER;
    ln_current_adj_cap  NUMBER;

BEGIN

   ln_calcUpsetRelease := ue_stream_ventflare.calcUpsetRelease(p_object_id, p_asset_id, p_daytime);

    IF ln_calcUpsetRelease IS NULL THEN
     FOR cur_vap_rel IN c_vapour_release LOOP
     ln_current_avail   := nvl(cur_vap_rel.avail,0);
     ln_current_adj_cap := nvl(cur_vap_rel.adj_cap,0);
       IF ln_current_avail > ln_current_adj_cap THEN
         ln_calcUpsetRelease := ln_current_avail - ln_current_adj_cap;
       ELSE
         ln_calcUpsetRelease := 0;
       END IF;
     END LOOP;
    END IF;

   RETURN ln_calcUpsetRelease;

END calcUpsetRelease;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : sumNormalRelease                                                              --
-- Description    :
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
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
FUNCTION sumNormalRelease(p_object_id VARCHAR2, p_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_vapour_release IS
SELECT object_id, asset_id, shares, sequence
  FROM V_STRM_DAY_ROU_REC_VAP
 where daytime = p_daytime
   and object_id = p_object_id;

CURSOR c_next_share (cp_current_sequence NUMBER) IS
select shares
  from V_STRM_DAY_ROU_REC_VAP
 where daytime = p_daytime
   and object_id = p_object_id
   and sequence = cp_current_sequence + 1;

CURSOR c_non_recoverable IS
SELECT EcBp_Stream_VentFlare.calcVapourGenerated(ogc.child_obj_id, p_daytime) AVAIL_VAPOURS
  FROM object_group_conn ogc
 WHERE ogc.parent_group_type = 'VF_NON'
   AND ogc.start_date <= p_daytime
   AND NVL (ogc.end_date, p_daytime + 1) > p_daytime
   AND ogc.object_id IN
       (SELECT object_id
          FROM object_group_conn ogc
         WHERE ogc.child_obj_id = p_object_id
           AND ogc.parent_group_type = 'VF_REL'
           AND ogc.start_date <= p_daytime
           AND NVL (ogc.end_date, p_daytime + 1) > p_daytime);

    ln_ret_val NUMBER := 0;
    lc_next_share VARCHAR2(1) := 'Y';

BEGIN

    FOR cur_rel IN c_vapour_release LOOP
	  lc_next_share := NULL;
      FOR cur_next_share IN c_next_share (cur_rel.sequence) LOOP
          lc_next_share := cur_next_share.shares;
      END LOOP;
      IF cur_rel.shares = 'N' OR lc_next_share = 'N' OR lc_next_share IS NULL THEN
        ln_ret_val := ln_ret_val + calcPotensialRelease(cur_rel.object_id, cur_rel.asset_id, p_daytime);
      END IF;
    END LOOP;

    FOR cur_non_recoverable IN c_non_recoverable LOOP
        ln_ret_val := ln_ret_val + Nvl(cur_non_recoverable.avail_vapours, 0);
    END LOOP;

    RETURN   ln_ret_val;

END sumNormalRelease;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : sumUpsetRelease                                                              --
-- Description    :
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
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
FUNCTION sumUpsetRelease(p_object_id VARCHAR2, p_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_vapour_release IS
SELECT object_id, asset_id, shares, sequence
  FROM V_STRM_DAY_ROU_REC_VAP
 where daytime = p_daytime
   and object_id = p_object_id;

   ln_ret_val NUMBER := 0;

BEGIN

    FOR cur_rel IN c_vapour_release LOOP
        ln_ret_val := ln_ret_val + calcUpsetRelease(cur_rel.object_id, cur_rel.asset_id, p_daytime);
    END LOOP;

  RETURN ln_ret_val;

END sumUpsetRelease;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : calcNormalRelease                                                              --
-- Description    :
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
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
FUNCTION calcRelease(p_object_id VARCHAR2, p_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS
CURSOR c_rel_record  IS
SELECT asset_id, class_name
  FROM strm_day_asset_data sd
 WHERE object_id = p_object_id
   AND daytime <= p_daytime
   AND start_daytime = p_daytime;

  lv2_strm_set_code VARCHAR2(32);
  ln_ret_val NUMBER;

BEGIN

  lv2_strm_set_code := getStreamSetCode(p_object_id,p_daytime);

  IF lv2_strm_set_code =  'PO.0086_VF_R' THEN
    FOR r_rel_record IN c_rel_record LOOP
      ln_ret_val := sumRoutineRelease(p_object_id, r_rel_record.class_name, p_daytime,r_rel_record.asset_id,p_daytime);
    END LOOP;
  ELSE
    ln_ret_val := sumNonRouRelease(p_object_id, p_daytime);
  END IF;

  RETURN ln_ret_val;

END calcRelease;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : calcNormalMTDAvg                                                              --
-- Description    :
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
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
FUNCTION calcNormalMTDAvg(p_object_id VARCHAR2, p_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS

    ln_calcNormalMTDAvg NUMBER;
    ln_dayRel           NUMBER;
    ld_startDate        DATE;

BEGIN

   ln_calcNormalMTDAvg := ue_stream_ventflare.calcNormalMTDAvg(p_object_id, p_daytime);

   IF ln_calcNormalMTDAvg IS NULL THEN
      ld_startDate := trunc(p_daytime, 'MM');
      ln_calcNormalMTDAvg := 0;

      FOR i IN 0 .. p_daytime - ld_startDate LOOP
          SELECT nvl(ROU_REL_OVERRIDE,EcBp_Stream_VentFlare.sumNormalRelease(object_id, daytime))
          INTO ln_dayRel
          FROM strm_day_asset_data
          WHERE class_name = 'STRM_DAY_ROU_REL_SUM'
          AND object_id = p_object_id
          AND daytime = ld_startDate + i;

          ln_calcNormalMTDAvg := ln_calcNormalMTDAvg + ln_dayRel;

      END LOOP;
      ln_calcNormalMTDAvg := ln_calcNormalMTDAvg / ((p_daytime - ld_startDate) + 1);
   END IF;

   RETURN ln_calcNormalMTDAvg;

END calcNormalMTDAvg;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : sumRoutineRelease                                                              --
-- Description    : Get Total Vapours Release in Release Summary tab
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : strm_day_asset_data
--                                                                                                 --
-- Using functions: ue_stream_ventflare
--
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION sumRoutineRelease(p_object_id VARCHAR2,
  p_class_name VARCHAR2,
  p_daytime DATE,
  p_asset_id VARCHAR2,
  p_start_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS

  lr_strm_day_asset_data  STRM_DAY_ASSET_DATA%ROWTYPE;
  ln_nr_over  NUMBER;
  ln_nr  NUMBER;
  ln_rou_over  NUMBER;
  ln_rou_calc  NUMBER;
  ln_rou NUMBER;
  ln_ret_val NUMBER;

BEGIN
  lr_strm_day_asset_data := ec_strm_day_asset_data.row_by_pk(p_object_id,p_class_name, p_daytime,p_asset_id,p_start_daytime, '<=');
  ln_nr_over := lr_strm_day_asset_data.non_rou_rel_override;

  ln_rou_over := lr_strm_day_asset_data.rou_rel_override;

    IF ln_nr_over >= 0 THEN
      ln_nr := ln_nr_over;
    ELSE
      ln_nr := sumUpsetRelease(p_object_id,p_daytime);
    END IF;

    IF ln_rou_over >= 0 THEN
      ln_rou := nvl(ln_rou_over,ln_rou_calc);
    ELSE
      ln_rou := sumNormalRelease(p_object_id,p_daytime);
    END IF;

    ln_ret_val := ln_nr + ln_rou;

  RETURN ln_ret_val;

END sumRoutineRelease;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : sumNonRouRelease                                                              --
-- Description    :
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
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
FUNCTION sumNonRouRelease(p_object_id VARCHAR2, p_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS


CURSOR c_calc_release  IS
SELECT sdad.class_name class_name,
       sdad.non_rou_rel_override,
       sdad.release_method,
       sdad.asset_id,
       sdad.start_daytime,
       sdad.downstream_sales,
       sdad.downstream_fuel
  FROM strm_day_asset_data sdad, strm_day_stream sds, strm_set_list ssl
 WHERE sdad.object_id = p_object_id
   AND sdad.daytime = p_daytime
   AND sdad.object_id = sds.object_id
   AND sdad.daytime = sds.daytime
   AND ssl.object_id = sds.object_id
   AND ssl.stream_set = 'PO.0086_VF_NR'
   AND p_daytime >= ssl.from_date
   AND p_daytime < Nvl(ssl.end_date, p_daytime + 1);


    ln_total_eqpm_rel_vol NUMBER;
    ln_eqpm_rel_vol NUMBER;
    ln_total_well_rel_vol NUMBER;
    ln_well_rel_vol NUMBER;
    ln_total_asset_other_rel_vol NUMBER;
    ln_asset_other_rel_vol NUMBER;
    ln_return_val NUMBER;

BEGIN
   ln_total_eqpm_rel_vol := 0;
   ln_total_well_rel_vol := 0;
   ln_total_asset_other_rel_vol := 0;

   FOR cur_calc_release IN c_calc_release LOOP
      IF cur_calc_release.class_name = 'STRM_DAY_NR_EQPM' THEN
         IF cur_calc_release.non_rou_rel_override >= 0 THEN
            ln_eqpm_rel_vol := cur_calc_release.non_rou_rel_override;
         ELSE
            ln_eqpm_rel_vol := calcTotalRelease(p_object_id,cur_calc_release.class_name, p_daytime, cur_calc_release.asset_id, cur_calc_release.start_daytime);
         END IF;
         ln_total_eqpm_rel_vol := ln_total_eqpm_rel_vol + NVL(ln_eqpm_rel_vol,0);

      ELSIF cur_calc_release.class_name = 'STRM_DAY_NR_WELL' THEN
          IF cur_calc_release.non_rou_rel_override >= 0 THEN
            ln_well_rel_vol := cur_calc_release.non_rou_rel_override;
         ELSE
           ln_well_rel_vol := calcWellContrib(p_object_id, 'STRM_DAY_NR_WELL',p_daytime,cur_calc_release.asset_id, cur_calc_release.start_daytime,cur_calc_release.asset_id);
         END IF;
         ln_total_well_rel_vol := ln_total_well_rel_vol + NVL(ln_well_rel_vol,0);

      ELSIF cur_calc_release.class_name = 'STRM_DAY_NR_OTHER' THEN
          IF cur_calc_release.non_rou_rel_override >= 0 AND (nvl(cur_calc_release.downstream_sales,'N') = 'N' AND  nvl(cur_calc_release.downstream_fuel,'N') = 'N')  THEN
            ln_asset_other_rel_vol := cur_calc_release.non_rou_rel_override;
         ELSE
            ln_asset_other_rel_vol := 0;
         END IF;
         ln_total_asset_other_rel_vol := ln_total_asset_other_rel_vol + NVL(ln_asset_other_rel_vol,0);
      END IF;

   END LOOP;

   ln_return_val := ln_total_eqpm_rel_vol + ln_total_well_rel_vol + ln_total_asset_other_rel_vol;
   RETURN ln_return_val;

END sumNonRouRelease;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getStreamSetCode                                                  --
-- Description    : Returns Stream Set Code for the stream.
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
FUNCTION getDataClass(p_object_id VARCHAR2, p_daytime DATE, p_tab VARCHAR2)

RETURN VARCHAR2
--</EC-DOC>
IS


  lv2_strm_set_code VARCHAR2(32);
  ln_ret_val VARCHAR2(32);

BEGIN

  lv2_strm_set_code := getStreamSetCode(p_object_id,p_daytime);
  IF lv2_strm_set_code =  'PO.0086_VF_R' THEN
  --IF system attribute VF_CALC_TAB is set to Y, Recovered Vapor Tab and Generated Vapor Tab will be disable
     IF ec_ctrl_system_attribute.attribute_text(p_daytime,'VF_ROUTINE_TAB','<=') = 'Y' THEN
        IF p_tab = 'TAB1' THEN
          ln_ret_val := NULL;
        ELSIF p_tab = 'TAB2' THEN
          ln_ret_val := NULL;
        ELSIF p_tab = 'TAB3' THEN
          ln_ret_val := NULL;
        ELSIF p_tab = 'TAB4' THEN
          ln_ret_val := 'STRM_DAY_ROU_REL_SUM';
        ELSIF p_tab = 'TAB5' THEN
          ln_ret_val := 'NULL';
        ELSIF p_tab = 'TAB6' THEN
          ln_ret_val := 'NULL';
        END IF;
    ELSE
      IF p_tab = 'TAB1' THEN
        ln_ret_val := NULL;
      ELSIF p_tab = 'TAB2' THEN
        ln_ret_val := NULL;
      ELSIF p_tab = 'TAB3' THEN
        ln_ret_val := NULL;
      ELSIF p_tab = 'TAB4' THEN
        ln_ret_val := 'STRM_DAY_ROU_REL_SUM';
      ELSIF p_tab = 'TAB5' THEN
        ln_ret_val := 'STRM_DAY_ROU_GEN_VAP';
      ELSIF p_tab = 'TAB6' THEN
        ln_ret_val := 'STRM_DAY_ROU_REC_VAP';
      END IF;
    END IF;
  ELSE
  --when then stm set code is PO.0086_VF_NR
    IF p_tab = 'TAB1' THEN
      ln_ret_val := 'STRM_DAY_NR_EQPM';
    ELSIF p_tab = 'TAB2' THEN
      ln_ret_val := 'STRM_DAY_NR_WELL';
    ELSIF p_tab = 'TAB3' THEN
        ln_ret_val := 'STRM_DAY_NR_OTHER';
    ELSIF p_tab = 'TAB4' THEN
        ln_ret_val := NULL;
    ELSIF p_tab = 'TAB5' THEN
        ln_ret_val := NULL;
    ELSIF p_tab = 'TAB6' THEN
        ln_ret_val := NULL;
    END IF;
  END IF;

  RETURN ln_ret_val;

END getDataClass;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : calcEqpmDuration                                                              --
-- Description    :
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
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
FUNCTION calcEqpmDuration(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS

  ln_ret_val NUMBER;
  ln_num_of_hours  NUMBER := 0;
  ld_day DATE;
  ld_end_daytime DATE;
  lr_strm_day_asset_data  STRM_DAY_ASSET_DATA%ROWTYPE;
  lv2_asset_class VARCHAR2(32);

BEGIN
  lr_strm_day_asset_data := ec_strm_day_asset_data.row_by_pk(p_object_id,p_class_name, p_daytime,p_asset_id,p_start_daytime, '<=');
  lv2_asset_class := ecdp_objects.GetObjClassName(p_asset_id);
  ln_num_of_hours := Ecdp_Timestamp.getNumHours(lv2_asset_class, p_asset_id,TRUNC(p_start_daytime,'DD'));
  ld_day := p_daytime + EcDp_ProductionDay.getProductionDayOffset(lv2_asset_class, p_asset_id, p_daytime)/24;
  ld_end_daytime :=  lr_strm_day_asset_data.end_daytime;
  ln_ret_val := (LEAST(Nvl(ld_end_daytime, ld_day+1),  ld_day+1) - GREATEST( p_start_daytime,  ld_day)) *  ln_num_of_hours;

  RETURN ln_ret_val;

END calcEqpmDuration;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : calcWellDuration                                                             --
-- Description    : calculate on stream hrs for a well on a given start daytime and end daytime
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-- Variables      :                                                                                --
-- p_start_daytime     = eqpm event start daytime                                                  --
-- ld_next_eff_daytime = next effective event start daytime after justify with day offset          --
-- ld_start_daytime    = valid event start daytime after justify with day offset.                  --
-- ld_end_daytime      = valid event end daytime after justify with day offset.                    --
-----------------------------------------------------------------------------------------------------
FUNCTION calcWellDuration(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE, p_well_id VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS

  ln_ret_val NUMBER;
  ld_end_daytime DATE;
  ld_start_daytime DATE;
  lr_strm_day_asset_data  STRM_DAY_ASSET_DATA%ROWTYPE;
  ln_prod_day_offset NUMBER;
  ld_next_eff_daytime DATE;
  ld_def_start_day DATE := NULL;
  ld_def_end_day DATE := NULL;
  ld_start_day DATE;
  ld_end_day DATE;
  ld_pwel_period_prev_daytime DATE;
  ln_off_strm_duration       NUMBER := 0;
  lv2_deferment_version  VARCHAR2(32);
  ld_next_def_end_day DATE;
  ld_off_strm_end_daytime DATE;

  -- Cursor when DEFERMENT_VERSION = 'PD.0020' for event changes
  CURSOR cur_DefermentEvent(cp_start_day DATE, cp_end_day DATE, cp_object_id varchar2, cp_pwel_period_prev_daytime DATE) IS
  SELECT w.daytime AS ChangeDate, nvl(w.end_date, cp_end_day) as endDay
  FROM deferment_event w
  WHERE w.event_type = 'DOWN'
  AND w.object_id = cp_object_id
  AND w.daytime <= cp_end_day
  AND cp_start_day <= nvl(w.end_date, cp_start_day)
  AND w.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD')
  UNION ALL
  SELECT daytime , Nvl((select min(daytime) from pwel_period_status p2 where p2.object_id=pwel_period_status.object_id
                                and p2.daytime > pwel_period_status.daytime
                                and p2.daytime <= cp_end_day
                                and p2.time_span='EVENT')
                                ,cp_end_day)
  FROM pwel_period_status
  WHERE object_id = cp_object_id
  AND daytime BETWEEN Nvl(cp_pwel_period_prev_daytime, cp_start_day) AND cp_end_day
  AND active_well_status <> 'OPEN'
  AND time_span='EVENT'
  ORDER BY 1;

BEGIN
  ln_ret_val := ue_stream_ventflare.calcWellDuration(p_object_id, p_class_name, p_daytime, p_asset_id, p_start_daytime, p_well_id);
  IF ln_ret_val IS NULL THEN
    lr_strm_day_asset_data := ec_strm_day_asset_data.row_by_pk(p_object_id,p_class_name, p_daytime,p_asset_id,p_start_daytime, '=');
    ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset('WELL',p_well_id,p_daytime)/24;

    -- day offset start daytime compare to eqpm event start daytime
    ld_start_daytime := GREATEST(TRUNC(p_daytime) + ln_prod_day_offset, p_start_daytime);
    ld_next_eff_daytime := TRUNC(p_daytime) + ln_prod_day_offset + 1;
    ld_end_daytime := LEAST(lr_strm_day_asset_data.end_daytime, ld_next_eff_daytime) ;

    ln_ret_val  := EcDp_Well.getPwelPeriodOnStrmFromStatus(p_well_id,GREATEST(ld_start_daytime,p_start_daytime),LEAST(ld_next_eff_daytime,nvl(ld_end_daytime,ld_next_eff_daytime)));

    IF ln_ret_val IS NOT NULL THEN

      ld_start_day := TRUNC(p_daytime) + ln_prod_day_offset;
      ld_end_day := ld_start_day + 1;
      ld_pwel_period_prev_daytime := ec_pwel_period_status.prev_equal_daytime(p_well_id, ld_start_day, 'EVENT');

      lv2_deferment_version := ec_ctrl_system_attribute.attribute_text(nvl(p_start_daytime, Ecdp_Timestamp.getCurrentSysdate), 'DEFERMENT_VERSION', '<=');

      IF lv2_deferment_version = 'PD.0020' OR lv2_deferment_version IS NULL THEN
        FOR c IN cur_DefermentEvent (ld_start_day, ld_end_day, p_well_id, ld_pwel_period_prev_daytime) LOOP
          IF (ld_def_start_day IS NULL AND ld_def_end_day IS NULL) OR (c.ChangeDate < ld_end_daytime AND c.ChangeDate > ld_def_end_day AND  c.endDay > ld_off_strm_end_daytime)THEN
            -- non-overlapped duration record
            ld_def_start_day := c.ChangeDate;
            ld_def_end_day   := LEAST(c.endDay,ld_end_daytime);
            ln_off_strm_duration := ln_off_strm_duration + ((ld_def_end_day - GREATEST(ld_def_start_day,ld_start_day))* Ecdp_Timestamp.getNumHours('WELL', p_well_id, p_daytime));
            ld_off_strm_end_daytime := ld_def_end_day;
          ELSIF c.ChangeDate <= ld_def_end_day THEN
            -- next overlapped record
            IF ld_off_strm_end_daytime IS NULL THEN
              ld_next_def_end_day := LEAST(c.endDay, ld_end_daytime);
            ELSE
              ld_next_def_end_day := GREATEST(LEAST(c.endDay, ld_end_daytime), ld_off_strm_end_daytime);
            END IF;

            IF( ld_next_def_end_day > ld_off_strm_end_daytime) THEN
               ln_off_strm_duration := ln_off_strm_duration + ((ld_next_def_end_day - ld_def_end_day)* Ecdp_Timestamp.getNumHours('WELL', p_well_id, p_daytime));
            ld_def_end_day := NVL(c.endDay, ld_end_daytime);
               ld_off_strm_end_daytime := ld_next_def_end_day;
            END IF;

          ELSE
            ld_def_end_day := NVL(c.endDay, ld_end_daytime);
          END IF;
        END LOOP;
      END IF;

      ln_ret_val := ln_ret_val - nvl(ln_off_strm_duration,0);
    END IF;

  END IF;
  RETURN ln_ret_val;
END calcWellDuration;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : calcEqpmNorCapacity                                                              --
-- Description    : Calculate normal capacity of the equipment.
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
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
FUNCTION calcEqpmNorCapacity(p_object_id VARCHAR2,p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS
  ln_ret_val NUMBER;
  ln_normal_cap_rate NUMBER;


BEGIN
    ln_normal_cap_rate := ec_eqpm_reference_value.normal_cap_rate(p_asset_id, p_daytime, '<=');
    ln_ret_val :=  ln_normal_cap_rate * calcEqpmDuration(p_object_id, p_class_name, p_daytime, p_asset_id, p_start_daytime)/24;

  RETURN ln_ret_val;

END calcEqpmNorCapacity;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : calcWellContrib                                                             --
-- Description    :
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
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
FUNCTION calcWellContrib(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE, p_well_id VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS
  ln_ret_val NUMBER;
  ln_gas_rate NUMBER;
  ln_strm_hrs NUMBER;

BEGIN

   ln_strm_hrs := calcWellDuration(p_object_id, p_class_name, p_daytime, p_asset_id, p_start_daytime,p_well_id);
   IF ln_strm_hrs > 0 THEN
     ln_gas_rate := ecbp_stream_ventflare.getPotentialRate(p_well_id,p_daytime,'GAS') + NVL(ecbp_stream_ventflare.getPotentialRate(p_well_id,p_daytime,'GAS_LIFT'),0);
     ln_ret_val := ln_gas_rate * ln_strm_hrs /24;
   END IF;

   RETURN ln_ret_val;

END calcWellContrib;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : calcEqpmRelease                                                            --
-- Description    :
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
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
FUNCTION calcEqpmRelease(p_object_id VARCHAR2,p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS
  ln_ret_val NUMBER;
  lr_strm_day_asset_data  STRM_DAY_ASSET_DATA%ROWTYPE;
  lv2_release_method VARCHAR2(32);

BEGIN

    lr_strm_day_asset_data := ec_strm_day_asset_data.row_by_pk(p_object_id,p_class_name, p_daytime,p_asset_id,p_start_daytime, '<=');
    lv2_release_method := lr_strm_day_asset_data.release_method;

    IF lv2_release_method = 'EQPM_NORM_CAP' THEN
      ln_ret_val := calcEqpmNorCapacity(p_object_id, p_class_name, p_daytime,p_asset_id, p_start_daytime) + (ec_eqpm_reference_value.blow_down_vol(p_asset_id,p_daytime, '<=') * lr_strm_day_asset_data.total_num_occur) ;
    ELSIF  lv2_release_method = 'SUM_WELL_REL' THEN
      ln_ret_val := 0;
    ELSIF  lv2_release_method = 'AVA_VAP_FAILURE' THEN
       ln_ret_val := 0;
    ELSE
      ln_ret_val := NULL;
    END IF;

  RETURN ln_ret_val;

END calcEqpmRelease;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : calcVRUFailure                                                              --
-- Description    : Calculate the failure of available vapours.
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
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
FUNCTION calcVRUFailure(p_object_id VARCHAR2,p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS

  ln_ret_val NUMBER;
  ln_available_vapour NUMBER;
  lv2_proc_unit_id VARCHAR(32);

BEGIN

SELECT max(t.parent_object_id)
  INTO lv2_proc_unit_id
  FROM v_strm_day_rou_rec_vap t
 WHERE asset_id = p_asset_id
   AND daytime = p_daytime;

  IF calcRunHours(lv2_proc_unit_id, p_daytime) = 0 THEN
    ln_ret_val := 0;
  ELSE
    SELECT sum(avail_vapours)
    INTO ln_available_vapour
    FROM v_strm_day_rou_gen_vap
    WHERE prim_rec_sys = p_asset_id
    AND daytime = p_daytime;

    ln_ret_val :=  (ln_available_vapour / calcRunHours(lv2_proc_unit_id, p_daytime)) * calcEqpmDuration(p_object_id,p_class_name,p_daytime,p_asset_id,p_start_daytime);
  END IF;

  RETURN ln_ret_val;

END calcVRUFailure;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : calcVapourGenerated                                                              --
-- Description    : Calculate the vapours generated
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
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
FUNCTION calcVapourGenerated(p_object_id VARCHAR2,
  p_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS

  lv2_phase  VARCHAR2(32);
  ln_grs_vol  NUMBER;
  ln_flash_factor  NUMBER;
  ln_ret_val NUMBER;

BEGIN

  lv2_phase := ec_strm_version.stream_phase(p_object_id, p_daytime, '<=');
  ln_grs_vol := ecbp_stream_fluid.findGrsStdVol(p_object_id, p_daytime, p_daytime);
  ln_flash_factor := ec_strm_reference_value.flash_factor(p_object_id, p_daytime, '<=');
  IF lv2_phase = 'OIL' OR lv2_phase = 'WAT' THEN
    ln_ret_val := ln_grs_vol * (ln_flash_factor / 1000);
  ELSE
    ln_ret_val := ln_grs_vol;
  END IF;
  RETURN ln_ret_val;
END calcVapourGenerated;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : countWellContrib
-- Description    : Count well contribution exist for the equipment tab asset id.
--
--
-- Preconditions  :
-- Postconditions : .
--
-- Using tables   : strm_day_asset_well_data
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
FUNCTION countWellContrib(p_parent_object_id VARCHAR2, p_parent_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

  CURSOR c_well_record  IS
    SELECT count(well_id) totalrecord
    FROM strm_day_asset_well_data wd
    WHERE asset_id = p_parent_object_id
    AND daytime <= p_parent_daytime;

 ln_well_record NUMBER;

BEGIN
   ln_well_record := 0;

  FOR cur_well_record IN c_well_record LOOP
    ln_well_record := cur_well_record.totalrecord ;
  END LOOP;

  return ln_well_record;

END countWellContrib;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : sumEqpmWellVol                                                                 --
-- Description    : get Sum Well Release for Equipment tab
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
--                                                                                                 --
-- Using functions: calcWellContrib, countWellContrib
--
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION sumEqpmWellVol (p_object_id VARCHAR2,
                         p_class_name VARCHAR2,
                         p_daytime DATE,
                         p_asset_id VARCHAR2,
                         p_start_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_well_record  IS
SELECT well_id
  FROM strm_day_asset_well_data wd
 WHERE wd.object_id = p_object_id
   AND wd.class_name = p_class_name
   AND wd.daytime = p_daytime
   AND wd.asset_id = p_asset_id
   AND wd.start_daytime = p_start_daytime;
   ln_total_vol       NUMBER;
   ln_return_val      NUMBER;

BEGIN

     FOR r_well_record IN c_well_record LOOP
        ln_total_vol := nvl(ln_total_vol,0) + nvl(calcWellContrib(p_object_id, p_class_name, p_daytime, p_asset_id, p_start_daytime, r_well_record.well_id),0);
     END LOOP;

     ln_return_val     :=  ln_total_vol ;

RETURN   ln_return_val;

END sumEqpmWellVol;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : calcTotalRelease                                                                 --
-- Description    : calculate Total Release for Equipment tab
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : strm_day_asset_data
--                                                                                                 --
-- Using functions: calcEqpmNorCapacity, sumEqpmWellVol, calcVRUFailure
--
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION calcTotalRelease (p_object_id VARCHAR2,
                         p_class_name VARCHAR2,
                         p_daytime DATE,
                         p_asset_id VARCHAR2,
                         p_start_daytime DATE,
                         p_release_method VARCHAR2 DEFAULT '-1',
                         p_total_num_occur NUMBER DEFAULT -1
                         )

RETURN NUMBER
--</EC-DOC>
IS

  lv2_release_method     VARCHAR2(32) := p_release_method;
  ln_eqpm_nor_capacity   NUMBER;
  ln_eqpm_well_vol       NUMBER;
  ln_eqpm_well_vol_theor NUMBER;
  ln_eqpm_blowdown_vol   NUMBER;
  ln_tot_num_occur       NUMBER := NVL(p_total_num_occur,0);
  ln_vapours_failure     NUMBER;
  ln_return_val          NUMBER;
  lr_strm_day_asset_data STRM_DAY_ASSET_DATA%ROWTYPE;

BEGIN

  IF p_total_num_occur = -1 OR p_release_method = '-1' THEN
    lr_strm_day_asset_data := ec_strm_day_asset_data.row_by_pk(p_object_id,p_class_name,p_daytime,p_asset_id,p_start_daytime,'<=');
    IF p_total_num_occur = -1 THEN
       ln_tot_num_occur     := nvl(lr_strm_day_asset_data.total_num_occur,0);
    END IF;

    IF p_release_method = '-1' THEN
       lv2_release_method   := lr_strm_day_asset_data.release_method;
    END IF;
  END IF;

  ln_eqpm_blowdown_vol := nvl(ec_eqpm_reference_value.blow_down_vol(p_asset_id,p_daytime,'<='),0);

  IF lv2_release_method = 'EQPM_NORM_CAP' THEN
    ln_eqpm_nor_capacity := calcEqpmNorCapacity(p_object_id,p_class_name,p_daytime,p_asset_id,p_start_daytime);
    ln_return_val := ln_eqpm_nor_capacity + (ln_eqpm_blowdown_vol * ln_tot_num_occur);

  ELSIF  lv2_release_method = 'SUM_WELL_REL' THEN
    ln_eqpm_well_vol     := sumEqpmWellVol(p_object_id,p_class_name,p_daytime,p_asset_id,p_start_daytime);
    ln_return_val := ln_eqpm_well_vol + (ln_eqpm_blowdown_vol * ln_tot_num_occur);

  ELSIF  lv2_release_method = 'AVAIL_VAPOURS' THEN
    ln_vapours_failure    := calcVRUFailure(p_object_id,p_class_name,p_daytime,p_asset_id,p_start_daytime);
    ln_return_val := (ln_eqpm_blowdown_vol * ln_tot_num_occur) + ln_vapours_failure;

  ELSIF  lv2_release_method = 'SUM_WELL_REL_THEOR' THEN
    ln_eqpm_well_vol_theor := sumEqpmWellVolTheor(p_object_id,p_class_name,p_daytime,p_asset_id,p_start_daytime);
    ln_return_val := ln_eqpm_well_vol_theor + (ln_eqpm_blowdown_vol * ln_tot_num_occur);

  ELSIF (substr(lv2_release_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_return_val := ue_stream_ventflare.calcNonRoutineEqpmFailure(p_object_id, p_class_name, p_daytime, p_asset_id, p_start_daytime) + (ln_eqpm_blowdown_vol * ln_tot_num_occur);
  ELSE
    ln_return_val := 0;
  END IF;

RETURN ln_return_val;

END calcTotalRelease;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : countGenVapours
-- Description    : Count vapours generated exist in Generated Vapours tab
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
FUNCTION countGenVapours(p_object_id VARCHAR2,
p_asset_id VARCHAR2,
                       p_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_gen_vap_record  IS
select count(gv.flash_factor) totalrecord
  FROM V_STRM_DAY_ROU_GEN_VAP gv
 WHERE gv.object_id = p_object_id
   AND gv.EQPM_ID = p_asset_id
   AND gv.DAYTIME = p_daytime;

 ln_gen_vap_record NUMBER;

BEGIN
  ln_gen_vap_record := 0;

  FOR cur_gen_vap_record IN c_gen_vap_record LOOP
    ln_gen_vap_record := cur_gen_vap_record.totalrecord;
  END LOOP;

  return ln_gen_vap_record;

END countGenVapours;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : sumGenVapours                                                                   --
-- Description    : get sum for vapours generated exist in Generated Vapours tab
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
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
FUNCTION sumGenVapours (p_object_id VARCHAR2,
p_asset_id VARCHAR2,
p_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_gen_vap_record  IS
SELECT gv.AVAIL_VAPOURS
  FROM V_STRM_DAY_ROU_GEN_VAP gv
 WHERE gv.object_id = p_object_id
   AND gv.EQPM_ID = p_asset_id
   AND gv.DAYTIME = p_daytime;

  ln_child_count     NUMBER;
  ln_total_vol       NUMBER;
  ln_return_val      NUMBER;

BEGIN

  ln_child_count := countGenVapours(p_object_id, p_asset_id, p_daytime);
  IF ln_child_count > 0 THEN
    FOR r_gen_vap_record IN c_gen_vap_record LOOP
      ln_total_vol :=  calcVapourGenerated(p_object_id, p_daytime);
    END LOOP;
    IF ln_total_vol IS NOT NULL THEN
      ln_return_val     := nvl(ln_total_vol,0) + ln_total_vol;
    END IF;
  ELSE
    ln_return_val := 0;
  END IF;

RETURN   ln_return_val;

END sumGenVapours;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getPotentialRate                                                   --
-- Description    : Returns Potential Rate
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : --
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
  p_object_id        VARCHAR2,
  p_daytime          DATE,
  p_potential_attribute VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS

  ln_return_val  NUMBER;
  ln_on_stream NUMBER;

BEGIN

  IF p_potential_attribute = 'OIL' then
    ln_on_stream := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime);
    IF ln_on_stream > 0 THEN
       ln_return_val := ecbp_well_potential.findOilProductionPotential(p_object_id,p_daytime);
    END IF;
  ELSIF p_potential_attribute = 'GAS' then
    ln_on_stream := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime);
    IF ln_on_stream > 0 THEN
       ln_return_val := ecbp_well_potential.findGasProductionPotential(p_object_id,p_daytime);
    END IF;
  ELSIF p_potential_attribute = 'GAS_LIFT' then
    ln_on_stream := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime);
    IF ln_on_stream > 0 THEN
       ln_return_val := ecbp_well_potential.findGasLiftPotential(p_object_id,p_daytime);
    END IF;
  ELSIF p_potential_attribute = 'WAT_INJ' then
    ln_on_stream := EcDp_Well.getIwelOnStreamHrs(p_object_id,'WI',p_daytime);
    IF ln_on_stream > 0 THEN
       ln_return_val := ecbp_well_potential.findWatInjectionPotential(p_object_id,p_daytime);
    END IF;
  ELSIF p_potential_attribute = 'STEAM_INJ' then
    ln_on_stream := EcDp_Well.getIwelOnStreamHrs(p_object_id,'SI',p_daytime);
    IF ln_on_stream > 0 THEN
       ln_return_val := ecbp_well_potential.findSteamInjectionPotential(p_object_id,p_daytime);
    END IF;
  ELSIF p_potential_attribute = 'COND' then
    ln_on_stream := EcDp_Well.getPwelOnStreamHrs(p_object_id,p_daytime);
    IF ln_on_stream > 0 THEN
       ln_return_val := ecbp_well_potential.findConProductionPotential(p_object_id,p_daytime);
    END IF;
  ELSIF p_potential_attribute = 'GAS_INJ' then
    ln_on_stream := EcDp_Well.getIwelOnStreamHrs(p_object_id,'GI',p_daytime);
    IF ln_on_stream > 0 THEN
       ln_return_val := ecbp_well_potential.findGasInjectionPotential(p_object_id,p_daytime);
    END IF;
  END IF;

  RETURN ln_return_val;

END getPotentialRate;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : calcRunHours                                                              --
-- Description    :
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
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
FUNCTION calcRunHours(p_object_id VARCHAR2, p_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS

  ln_ret_val NUMBER;
  ln_prod_day_offset NUMBER;
  ln_downtime_hrs NUMBER := 0;
  ld_daytime DATE;
  lv2_on_time_method VARCHAR2(32);

 CURSOR c_equip_downtime(cp_daytime DATE) IS
SELECT *
  FROM EQUIP_DOWNTIME
 WHERE object_id = p_object_id
   AND (daytime < cp_daytime + 1 AND
       (end_date > cp_daytime OR end_date IS NULL)) --handle open downtime events
 ORDER BY daytime ASC;

BEGIN

    ln_prod_day_offset := (EcDp_ProductionDay.getProductionDayOffset('EQPM',p_object_id,p_daytime)/24);
    ld_daytime := p_daytime + ln_prod_day_offset;
    lv2_on_time_method := ec_eqpm_version.on_time_method(p_object_id,p_daytime,'<=');

   IF lv2_on_time_method = 'EQUIP_DOWNTIME_PD0022' THEN
      FOR curDowntime IN c_equip_downtime(ld_daytime) LOOP
      ln_downtime_hrs := ln_downtime_hrs + (least(nvl(curDowntime.end_date,ld_daytime+1), ld_daytime+1) - greatest((curDowntime.daytime ), ld_daytime)) * 24;
      END LOOP;
    END IF;

    ln_ret_val := Ecdp_Timestamp.getNumHours('EQPM',p_object_id, p_daytime) - Nvl(ln_downtime_hrs, 0);

  RETURN ln_ret_val;

END calcRunHours;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : calcRoutineRunHours                                                              --
-- Description    :
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
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
FUNCTION calcRoutineRunHours(p_process_unit_id VARCHAR2, p_asset_id VARCHAR2, p_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS

  ln_ret_val NUMBER;
  ln_prod_day_offset NUMBER;
  ln_downtime_hrs NUMBER := 0;
  ld_daytime DATE;
  ld_prev_end_date DATE;
  lv2_on_time_method VARCHAR2(32);


 CURSOR c_equip_downtime(cp_daytime DATE) IS
SELECT *
  FROM equip_downtime
 WHERE (object_id = p_process_unit_id
    OR object_id IN (SELECT ogc.child_obj_id
                       FROM object_group_conn ogc
                      WHERE ogc.parent_group_type = 'VF_VRS'
                        AND ogc.start_date <= p_daytime
                        AND NVL(ogc.end_date, p_daytime + 1) > p_daytime
                        AND ogc.object_id = p_process_unit_id))
   AND daytime < cp_daytime + 1
   AND (end_date > cp_daytime OR end_date IS NULL)
 ORDER BY daytime ASC, end_date DESC;

BEGIN
    ln_ret_val := ue_stream_ventflare.calcRoutineRunHours(p_process_unit_id, p_asset_id, p_daytime);
    IF ln_ret_val IS NULL THEN
      ln_prod_day_offset := (EcDp_ProductionDay.getProductionDayOffset('EQPM',p_process_unit_id,p_daytime)/24);
      ld_daytime := p_daytime + ln_prod_day_offset;
      ld_prev_end_date := ld_daytime;
      lv2_on_time_method := ec_eqpm_version.on_time_method(p_asset_id,p_daytime,'<=');
    IF lv2_on_time_method = 'EQUIP_DOWNTIME_PD0022' THEN
        FOR curDowntime IN c_equip_downtime(ld_daytime) LOOP
          IF curDowntime.end_date >= ld_prev_end_date OR curDowntime.end_date IS NULL THEN
            IF curDowntime.daytime < ld_prev_end_date THEN
            ln_downtime_hrs := ln_downtime_hrs + (least(nvl(curDowntime.end_date,ld_daytime+1), ld_daytime+1) - greatest((ld_prev_end_date), ld_daytime)) * 24;
            ELSE
            ln_downtime_hrs := ln_downtime_hrs + (least(nvl(curDowntime.end_date,ld_daytime+1), ld_daytime+1) - greatest((curDowntime.daytime), ld_daytime)) * 24;
            END IF;
          END IF;
          IF curDowntime.end_date > ld_prev_end_date THEN
          ld_prev_end_date := least(curDowntime.end_date, ld_daytime+1);
          END IF;
        END LOOP;
      END IF;
      ln_ret_val := Ecdp_Timestamp.getNumHours('EQPM',p_process_unit_id, p_daytime) - Nvl(ln_downtime_hrs, 0);
    END IF;
  RETURN ln_ret_val;

END calcRoutineRunHours;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : calcRoutineAvailVapour                                                              --
-- Description    :
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
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
FUNCTION calcRoutineAvailVapour(p_object_id VARCHAR2, p_asset_id VARCHAR2, p_process_unit_id VARCHAR2, p_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS

  ln_ret_val NUMBER;
  ln_process_unit_hrs NUMBER;
  ln_routine_hrs NUMBER;
  ln_gen_vapour NUMBER;

BEGIN
  ln_process_unit_hrs := calcRunHours(p_process_unit_id, p_daytime);
  ln_routine_hrs := calcRoutineRunHours(p_process_unit_id,p_asset_id, p_daytime);

  SELECT sum(avail_vapours)
  INTO ln_gen_vapour
  FROM v_strm_day_rou_gen_vap
  WHERE object_id = p_object_id
  AND prim_rec_sys = p_asset_id
  AND daytime = p_daytime;

  ln_ret_val := (ln_gen_vapour/ln_process_unit_hrs) * ln_routine_hrs;
  RETURN ln_ret_val;

END calcRoutineAvailVapour;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : calcUpsetAvailVapour                                                              --
-- Description    :
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
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
FUNCTION calcUpsetAvailVapour(p_object_id VARCHAR2, p_asset_id VARCHAR2, p_process_unit_id VARCHAR2, p_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS

  ln_ret_val NUMBER;
  ln_process_unit_hrs NUMBER;
  ln_gen_vapour NUMBER;

BEGIN
  ln_process_unit_hrs := calcRunHours(p_process_unit_id, p_daytime);

  SELECT sum(avail_vapours)
  INTO ln_gen_vapour
  FROM v_strm_day_rou_gen_vap
  WHERE object_id = p_object_id
  AND prim_rec_sys = p_asset_id
  AND daytime = p_daytime;

  ln_ret_val := (ln_gen_vapour/ln_process_unit_hrs) * (calcRunHours(p_asset_id, p_daytime) - calcRoutineRunHours(p_process_unit_id, p_asset_id, p_daytime));
  RETURN ln_ret_val;

END calcUpsetAvailVapour;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : calcGrsVolMass                                                              --
-- Description    :
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
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
PROCEDURE calcGrsVolMass(p_object_id VARCHAR2, p_daytime DATE, p_user VARCHAR2)

--</EC-DOC>
IS
 CURSOR c_strm_day_stream  IS
  SELECT sd.object_id, sd.source, sd.no_release_today, sd.grs_vol, sd.grs_mass
  FROM strm_day_stream sd
  WHERE object_id = p_object_id
  AND daytime = p_daytime;

  lv2_quantity_method VARCHAR2(32);
  lr_stream_version    STRM_VERSION%ROWTYPE;
  lv2_source VARCHAR2(32);
  lv2_no_release_today VARCHAR2(1);
  ln_grs_vol NUMBER;
  ln_grs_mass NUMBER;
  lv2_code_exist VARCHAR2(32);

BEGIN

    ue_stream_ventflare.calcGrsVolMass(p_object_id, p_daytime, p_user, lv2_code_exist);

    IF lv2_code_exist <> 'Y' THEN
	  FOR cur_strm_day_stream IN c_strm_day_stream LOOP
        lr_stream_version :=ec_strm_version.row_by_pk(p_object_id, p_daytime, '<=');
        IF lr_stream_version.grs_vol_method = 'MEASURED' THEN
          lv2_quantity_method := 'GROSS_VOLUME';
        ELSIF lr_stream_version.grs_mass_method = 'MEASURED' THEN
          lv2_quantity_method := 'GROSS_MASS';
        END IF;

        lv2_source := cur_strm_day_stream.source;
        lv2_no_release_today := cur_strm_day_stream.no_release_today;
        ln_grs_vol := cur_strm_day_stream.grs_vol;
        ln_grs_mass := cur_strm_day_stream.grs_mass;

      END LOOP;

      IF lv2_quantity_method = 'GROSS_VOLUME' THEN

        IF ln_grs_vol IS NOT NULL and lv2_source = 'MANUAL' THEN
           RAISE_APPLICATION_ERROR(-20231,'Gross volume value has to be cleared before clicking the Save and Update button.');
        ELSE
           IF lv2_no_release_today = 'Y' THEN
            ln_grs_vol := 0;
           ELSE
            ln_grs_vol := calcRelease(p_object_id, p_daytime);
           END IF;

          UPDATE strm_day_stream sds
           SET sds.grs_vol         = ln_grs_vol,
               sds.source          = 'CALC',
               sds.last_updated_by = p_user
         WHERE sds.object_id = p_object_id
           AND sds.daytime = p_daytime;
        END IF;

      ELSIF lv2_quantity_method = 'GROSS_MASS' THEN

        IF ln_grs_mass IS NOT NULL and lv2_source = 'MANUAL' THEN
          RAISE_APPLICATION_ERROR(-20691,'Gross mass value has to be cleared before clicking the Save and Update button.');
          null;
        ELSE
           IF lv2_no_release_today = 'Y' THEN
            ln_grs_mass := 0;
           ELSE
            ln_grs_mass := calcRelease(p_object_id, p_daytime);
           END IF;

          UPDATE strm_day_stream sds
           SET sds.grs_mass         = ln_grs_mass,
               sds.source          = 'CALC',
               sds.last_updated_by = p_user
         WHERE sds.object_id = p_object_id
           AND sds.daytime = p_daytime;
        END IF;
      END IF;
	ELSE
      NULL;
    END IF;
END calcGrsVolMass;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getGasOilRatio                                                   --
-- Description    : Returns GOR
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : --
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
FUNCTION getGasOilRatio (
  p_object_id        VARCHAR2,
  p_daytime          DATE)

RETURN NUMBER
--</EC-DOC>
IS

  ln_return_val  NUMBER;
  ln_oil_rate    NUMBER;
  ln_gas_rate    NUMBER;

BEGIN

  ln_oil_rate := getPotentialRate(p_object_id,p_daytime, 'OIL');
  ln_gas_rate := getPotentialRate(p_object_id,p_daytime, 'GAS');

  IF ln_oil_rate = 0 THEN
    IF ln_gas_rate = 0 THEN
      ln_return_val:=0;
    ELSE
      ln_return_val:=NULL;
    END IF;
  ELSE
    ln_return_val := ln_gas_rate/ln_oil_rate;
  END IF;

  RETURN ln_return_val;
END getGasOilRatio;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : calcEventVol                                                                 --
-- Description    : calculate Total Release for a given event
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : strm_day_asset_data
--                                                                                                 --
-- Using functions: calcEqpmDuration
--
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION calcEventVol (p_object_id VARCHAR2,
                         p_class_name VARCHAR2,
                         p_daytime DATE,
                         p_asset_id VARCHAR2,
                         p_start_daytime DATE,
                         p_end_daytime DATE,
                         p_release_method VARCHAR2 DEFAULT '-1',
                         p_total_num_occur NUMBER DEFAULT -1)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_strm_day_asset_data IS
  SELECT * FROM STRM_DAY_ASSET_DATA
    WHERE object_id = p_object_id
    AND class_name = p_class_name
    AND asset_id = p_asset_id
    AND start_daytime = p_start_daytime;

  ln_prodDayRel   NUMBER;
  ln_return_val NUMBER ;

BEGIN
  ln_return_val := 0;
  IF p_end_daytime IS NOT NULL THEN
    FOR cur_strm_day_asset_data IN c_strm_day_asset_data LOOP
      IF p_class_name = 'STRM_DAY_NR_OTHER' THEN
        ln_prodDayRel := cur_strm_day_asset_data.non_rou_rel_override;
      ELSIF p_class_name = 'STRM_DAY_NR_EQPM' THEN
		ln_prodDayRel := nvl(cur_strm_day_asset_data.non_rou_rel_override,calcTotalRelease(p_object_id,p_class_name,cur_strm_day_asset_data.daytime,p_asset_id,p_start_daytime,p_release_method, p_total_num_occur));
      END IF;
      ln_return_val := ln_return_val + ln_prodDayRel;
    END LOOP;
  END IF;

RETURN ln_return_val;

END calcEventVol;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : calcWellEventVol                                                                 --
-- Description    : calculate Total Release for a given event
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : strm_day_asset_data
--                                                                                                 --
-- Using functions: calcEqpmDuration
--
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION calcWellEventVol (p_object_id VARCHAR2,
                         p_class_name VARCHAR2,
                         p_daytime DATE,
                         p_asset_id VARCHAR2,
                         p_start_daytime DATE,
                         p_well_id VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_strm_day_asset_data IS
  SELECT * FROM STRM_DAY_ASSET_DATA
    WHERE object_id = p_object_id
    AND class_name = p_class_name
    AND asset_id = p_asset_id
    AND start_daytime = p_start_daytime
    order by daytime;

  ln_prodDayRel   NUMBER;
  ln_return_val NUMBER ;

BEGIN
  ln_return_val := 0;

    FOR cur_strm_day_asset_data IN c_strm_day_asset_data LOOP
      IF cur_strm_day_asset_data.end_daytime IS NOT NULL THEN
        ln_prodDayRel :=  nvl(cur_strm_day_asset_data.non_rou_rel_override,calcWellContrib(p_object_id,p_class_name,cur_strm_day_asset_data.daytime,p_asset_id,p_start_daytime,p_well_id));
        ln_return_val := ln_return_val + ln_prodDayRel;
      END IF;
    END LOOP;


RETURN ln_return_val;

END calcWellEventVol;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getTheoreticalRate                                                   --
-- Description    : Returns Theoretical Rate
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : --
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
FUNCTION getTheoreticalRate (
  p_object_id        VARCHAR2,
  p_daytime          DATE,
  p_theoretical_attribute VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS

  ln_return_val  NUMBER;

BEGIN

    IF p_theoretical_attribute = 'OIL' then
      IF ecdp_well.isWellPhaseActiveStatus(p_object_id,null,'OPEN',p_daytime) = 'Y' THEN
        ln_return_val := ecbp_well_theoretical.getOilStdRateDay(p_object_id,p_daytime);
      END IF;
    ELSIF  p_theoretical_attribute = 'GAS' then
      IF ecdp_well.isWellPhaseActiveStatus(p_object_id,null,'OPEN',p_daytime) = 'Y' THEN
        ln_return_val := ecbp_well_theoretical.getGasStdRateDay(p_object_id,p_daytime);
      END IF;
    ELSIF  p_theoretical_attribute = 'COND' then
      IF ecdp_well.isWellPhaseActiveStatus(p_object_id,null,'OPEN',p_daytime) = 'Y' THEN
        ln_return_val := ecbp_well_theoretical.getCondStdRateDay(p_object_id,p_daytime);
      END IF;
    END IF;

  RETURN ln_return_val;
END getTheoreticalRate;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : sumEqpmWellVolTheor                                                                 --
-- Description    :
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
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
FUNCTION sumEqpmWellVolTheor (p_object_id VARCHAR2,
                         p_class_name VARCHAR2,
                         p_daytime DATE,
                         p_asset_id VARCHAR2,
                         p_start_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_well_record  IS
SELECT well_id
  FROM strm_day_asset_well_data wd
 WHERE wd.object_id = p_object_id
   AND wd.class_name = p_class_name
   AND wd.daytime = p_daytime
   AND wd.asset_id = p_asset_id
   AND wd.start_daytime = p_start_daytime;
   ln_total_vol       NUMBER;
   ln_return_val      NUMBER;

BEGIN

     FOR r_well_record IN c_well_record LOOP
        ln_total_vol := nvl(ln_total_vol,0) + nvl(calcWellContribTheor(p_object_id, p_class_name, p_daytime, p_asset_id, p_start_daytime, r_well_record.well_id),0);
     END LOOP;

     ln_return_val     :=  ln_total_vol ;

RETURN   ln_return_val;

END sumEqpmWellVolTheor;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : calcWellContribTheor                                                             --
-- Description    :
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
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
FUNCTION calcWellContribTheor(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE, p_well_id VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS
  ln_ret_val NUMBER;
  ln_gas_rate NUMBER;
  ln_strm_hrs NUMBER;

BEGIN
   ln_strm_hrs := calcWellDuration(p_object_id, p_class_name, p_daytime, p_asset_id, p_start_daytime,p_well_id);
   ln_gas_rate := ecbp_stream_ventflare.getTheoreticalRate(p_well_id,p_daytime,'GAS');
   IF ln_strm_hrs > 0 THEN
     ln_ret_val := ln_gas_rate * ln_strm_hrs /24;
   END IF;

  RETURN ln_ret_val;

END calcWellContribTheor;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getTheorGasOilRatio                                                   --
-- Description    : Returns Theoretical GOR
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : --
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
FUNCTION getTheorGasOilRatio (
  p_object_id        VARCHAR2,
  p_daytime          DATE)

RETURN NUMBER
--</EC-DOC>
IS

  ln_return_val  NUMBER;
  ln_oil_rate    NUMBER;
  ln_gas_rate    NUMBER;

BEGIN

  ln_oil_rate := getTheoreticalRate(p_object_id,p_daytime, 'OIL');
  ln_gas_rate := getTheoreticalRate(p_object_id,p_daytime, 'GAS');

  IF ln_oil_rate = 0 THEN
    IF ln_gas_rate = 0 THEN
      ln_return_val:=0;
    ELSE
      ln_return_val:=NULL;
    END IF;
  ELSE
    ln_return_val := ln_gas_rate/ln_oil_rate;
  END IF;

  RETURN ln_return_val;
END getTheorGasOilRatio;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : calcMtd                                                                        --
-- Description    : Returns month to day (total for the stream for the month)
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : --
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
FUNCTION calcMtd (
  p_object_id        VARCHAR2,
  p_daytime          DATE)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_calc_mtd IS
SELECT SUM(grs_vol) sum_grs_vol FROM strm_day_stream sds
WHERE sds.object_id = p_object_id
AND sds.daytime between trunc(p_daytime, 'MM')
AND p_daytime;

  ln_total_mtd   NUMBER;

BEGIN

     FOR cur_calc_mtd IN c_calc_mtd LOOP
        ln_total_mtd := cur_calc_mtd.sum_grs_vol;
     END LOOP;

     RETURN ln_total_mtd;
END calcMtd;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : calcMtdDuration                                                                --
-- Description    : Returns month to day (total production hours for the stream for the month)
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : --
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
FUNCTION calcMtdDuration(p_object_id VARCHAR2, p_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS

  CURSOR c_rel_record  IS
   SELECT daytime, asset_id, class_name, start_daytime, downstream_fuel, downstream_sales
   FROM strm_day_asset_data sd
   WHERE object_id = p_object_id
   AND daytime between trunc(p_daytime, 'MM')
   AND p_daytime;

  ln_ret_val NUMBER;
  ln_total_mtd   NUMBER;
  ln_child_count     NUMBER;

BEGIN

  ln_child_count := countMTDRec(p_object_id , p_daytime);
  ln_ret_val := 0;

  IF ln_child_count > 0 THEN
	FOR r_rel_record IN c_rel_record LOOP
      IF r_rel_record.class_name = 'STRM_DAY_NR_WELL' THEN
         ln_total_mtd := calcWellDuration(p_object_id, r_rel_record.class_name, r_rel_record.daytime, r_rel_record.asset_id, r_rel_record.start_daytime, r_rel_record.asset_id);

      ELSIF r_rel_record.class_name = 'STRM_DAY_NR_EQPM' THEN
         ln_total_mtd := calcEqpmDuration(p_object_id, r_rel_record.class_name, r_rel_record.daytime, r_rel_record.asset_id, r_rel_record.start_daytime);

      ELSIF r_rel_record.class_name = 'STRM_DAY_NR_OTHER' THEN
         IF (nvl(r_rel_record.downstream_fuel,'N') = 'N' AND nvl(r_rel_record.downstream_sales,'N') = 'N') THEN
            ln_total_mtd := calcEqpmDuration(p_object_id, r_rel_record.class_name, r_rel_record.daytime, r_rel_record.asset_id, r_rel_record.start_daytime);
         ELSE
            ln_total_mtd := 0;
         END IF;
      END IF;

      ln_ret_val := ln_ret_val + ln_total_mtd;
     END LOOP;

  ELSE
    ln_ret_val := NULL;
  END IF;

  RETURN ln_ret_val;

END calcMtdDuration;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : countMtdRec
-- Description    : Count record exist for the 'EQPM', 'work well' and 'other' tab.
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
FUNCTION countMtdRec(p_parent_object_id VARCHAR2, p_parent_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

  CURSOR c_record  IS
    SELECT count(*) totalrecord
    FROM strm_day_asset_data wd
    WHERE object_id = p_parent_object_id
    AND daytime = p_parent_daytime;

 ln_well_record NUMBER;

BEGIN
   ln_well_record := 0;

  FOR cur_record IN c_record LOOP
    ln_well_record := cur_record.totalrecord ;
  END LOOP;

  RETURN ln_well_record;

END countMtdRec;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : recalcGrsVolMass                                                                   --
-- Description    : recalculates stream's grs vol when records are deleted from Equipment/Well Work/Other tab.
-- Preconditions  : Grs vol is only recalculated when the source is CALC.
-- Postconditions : Grs vol is recalculated and updated accordingly.                               --
--                                                                                                 --
-- Using tables   :
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
PROCEDURE recalcGrsVolMass(p_object_id VARCHAR2, p_daytime DATE, p_user VARCHAR2)

--</EC-DOC>
IS
 CURSOR c_strm_day_stream  IS
  SELECT sd.object_id, sd.source,sd.no_release_today, sd.grs_vol, sd.grs_mass
  FROM strm_day_stream sd
  WHERE object_id = p_object_id
  AND daytime = p_daytime;

  lv2_quantity_method VARCHAR2(32);
  lr_stream_version    STRM_VERSION%ROWTYPE;

  lv2_source VARCHAR2(32);
  lv2_no_release_today VARCHAR2(1);
  ln_grs_vol NUMBER;
  ln_grs_mass NUMBER;

BEGIN

   FOR cur_strm_day_stream IN c_strm_day_stream LOOP
      lr_stream_version :=ec_strm_version.row_by_pk(p_object_id, p_daytime, '<=');
      IF lr_stream_version.grs_vol_method = 'MEASURED' THEN
        lv2_quantity_method := 'GROSS_VOLUME';
      ELSIF lr_stream_version.grs_mass_method = 'MEASURED' THEN
        lv2_quantity_method := 'GROSS_MASS';
      END IF;

     lv2_source := cur_strm_day_stream.source;
     lv2_no_release_today := cur_strm_day_stream.no_release_today;
     ln_grs_vol := cur_strm_day_stream.grs_vol;
      ln_grs_mass := cur_strm_day_stream.grs_mass;

   END LOOP;

IF lv2_quantity_method = 'GROSS_VOLUME' THEN
   IF lv2_source = 'CALC' THEN
     IF lv2_no_release_today = 'Y' THEN
       ln_grs_vol := 0;
     ELSE
       ln_grs_vol := calcRelease(p_object_id, p_daytime);
     END IF;
     UPDATE strm_day_stream sds
       SET sds.grs_vol = ln_grs_vol,
           sds.source  = 'CALC',
           sds.last_updated_by = p_user
        WHERE sds.object_id = p_object_id
        AND sds.daytime = p_daytime;
   END IF;

ELSIF lv2_quantity_method = 'GROSS_MASS' THEN

    IF ln_grs_mass IS NOT NULL and lv2_source = 'MANUAL' THEN
      RAISE_APPLICATION_ERROR(-20691,'Gross mass value has to be cleared before clicking the Save and Update button.');
null;
    ELSE
       IF lv2_no_release_today = 'Y' THEN
        ln_grs_mass := 0;
       ELSE
        ln_grs_mass := calcRelease(p_object_id, p_daytime);
       END IF;

      UPDATE strm_day_stream sds
       SET sds.grs_mass         = ln_grs_mass,
           sds.source          = 'CALC',
           sds.last_updated_by = p_user
     WHERE sds.object_id = p_object_id
       AND sds.daytime = p_daytime;
    END IF;

END IF;

END recalcGrsVolMass;

END EcBp_Stream_VentFlare;