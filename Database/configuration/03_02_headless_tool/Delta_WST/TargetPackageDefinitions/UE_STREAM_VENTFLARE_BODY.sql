CREATE OR REPLACE PACKAGE BODY ue_stream_ventflare IS
/****************************************************************
** Package        :  ue_stream_ventflare; body part
**
** $Revision: 1.6.12.3 $
**
** Purpose        :  Fucntion called for calcNormalRelease and calcUpsetRelease
**
** Documentation  :  www.energy-components.com
**
** Created        :  17.03.2010 Sarojini Rajaretnam
**
** Modification history:
**
** Date        Whom  	Change description:
** ----------  ----- 	-------------------------------------------
** 17.03.2010  rajarsar	ECPD-4828:Initial version
** 13.08.2010  rajarsar	ECPD-15495:Added calcRoutineRunHours and updated calling functions to EcBp_Stream_VentFlare.calcRoutineRunHours accordingly.
** 02.02.2011  farhaann ECPD-16411:Renamed calcNetVol to calcGrsVol
** 16.01.2014  choooshu ECPD-26654:Added calcwellduration
** 11.02.2014  jainopan ECPD-26700:Modified to have calcPotensialRelease RETURN 0 at the end;
** 09.04.2014  kumarsur ECPD-27329:calcGrsVol, rename to calcGrsVolMass.
********************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calcNormalRelease
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
FUNCTION calcNormalRelease(p_object_id VARCHAR2, p_asset_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_vapor_recovery(cp_daytime DATE) IS
SELECT asset_id,
       shares,
       sequence,
       (ec_eqpm_reference_value.normal_rec_cap_rate(asset_id, daytime, '<=') / 24) *
       EcBp_Stream_VentFlare.calcRoutineRunHours(parent_object_id,asset_id, daytime) as adj_cap,
       EcBp_Stream_VentFlare.calcRoutineAvailVapour(object_id,
                                                   asset_id,
                                                   parent_object_id,
                                                   daytime) as avail
  FROM V_STRM_DAY_ROU_REC_VAP
 WHERE daytime = cp_daytime
   AND object_id = p_object_id
 ORDER BY sequence;

CURSOR c_vapor_release(cp_daytime DATE, cp_start_system_sequence NUMBER, ln_this_sequence NUMBER) IS
SELECT asset_id,
       shares,
       sequence,
       (ec_eqpm_reference_value.normal_rec_cap_rate(asset_id, daytime, '<=') / 24) *
       EcBp_Stream_VentFlare.calcRoutineRunHours(parent_object_id,asset_id, daytime) as adj_cap,
       EcBp_Stream_VentFlare.calcRoutineAvailVapour(object_id,
                                                   asset_id,
                                                   parent_object_id,
                                                   daytime) as avail
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
     lc_next_share VARCHAR2(1) := 'Y';
     ln_this_sys_end_seq NUMBER;
     ln_this_sys_start_seq NUMBER;
     ln_no_share_rel NUMBER;

BEGIN

     SELECT MIN(sequence)
       INTO ln_this_sys_start_seq
       FROM V_STRM_DAY_ROU_REC_VAP
     WHERE object_id = p_object_id
     AND daytime = p_daytime;

     FOR cur_vap_rec IN c_vapor_recovery (p_daytime) LOOP
       FOR cur_next_share IN c_next_share (cur_vap_rec.sequence) LOOP
         lc_next_share := cur_next_share.shares;
         ln_this_sys_end_seq := cur_vap_rec.sequence;
       END LOOP;
       ln_individual_avail := cur_vap_rec.avail - cur_vap_rec.adj_cap;
       IF ln_individual_avail < 0 THEN
         ln_individual_avail := 0;
       END IF;
       ln_total_individual_avail := ln_total_individual_avail + ln_individual_avail;
       IF cur_vap_rec.shares = 'Y' and lc_next_share = 'N' THEN
         ln_total_release := calcPotensialRelease(p_object_id, cur_vap_rec.asset_id, p_daytime);
         FOR cur_vap_rel IN c_vapor_release (p_daytime, ln_this_sys_start_seq, ln_this_sys_end_seq) LOOP
           IF p_asset_id = cur_vap_rel.asset_id THEN
             IF cur_vap_rel.avail - cur_vap_rel.adj_cap > 0 THEN
               RETURN (cur_vap_rel.avail - cur_vap_rel.adj_cap) * (ln_total_release / ln_total_individual_avail);
             END IF;
           END IF;
         END LOOP;
         ln_total_release := 0;
         ln_total_individual_avail := 0;
       ELSIF cur_vap_rec.shares = 'N' AND (lc_next_share = 'N' OR lc_next_share IS NULL) THEN
         IF p_asset_id = cur_vap_rec.asset_id THEN
           ln_no_share_rel := calcPotensialRelease(p_object_id, p_asset_id, p_daytime);
           IF ln_no_share_rel > 0 THEN
             RETURN ln_no_share_rel;
           ELSE
             RETURN 0;
           END IF;
         END IF;
       END IF;
     END LOOP;
   RETURN 0;

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

CURSOR c_vapor_recovery(cp_daytime DATE) IS
SELECT asset_id,
       sequence,
       shares,
       (ec_eqpm_reference_value.normal_rec_cap_rate(asset_id, daytime, '<=') / 24) *
       EcBp_Stream_VentFlare.calcRoutineRunHours(parent_object_id,asset_id, daytime) as adj_cap,
       EcBp_Stream_VentFlare.calcRoutineAvailVapour(object_id,
                                                   asset_id,
                                                   parent_object_id,
                                                   daytime) as avail
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

     ln_calcNormalRelease NUMBER;
     ln_potensial_rel NUMBER;
     ln_previous_potensial_rel NUMBER := 0;
     ln_current_avail NUMBER;
     ln_current_adj_cap NUMBER;
     ln_previous_avail NUMBER := 0;
     ln_previous_adj_cap NUMBER := 0;
     lc_next_share VARCHAR2(1) := 'Y';

BEGIN

     FOR cur_vap_rec IN c_vapor_recovery (p_daytime) LOOP
       FOR cur_next_share IN c_next_share (cur_vap_rec.sequence) LOOP
         lc_next_share := cur_next_share.shares;
       END LOOP;
       IF cur_vap_rec.shares = 'N' AND (lc_next_share = 'N' OR lc_next_share IS NULL) THEN
         ln_current_avail := cur_vap_rec.avail;
         ln_current_adj_cap := cur_vap_rec.adj_cap;
         ln_previous_avail := 0;
         ln_previous_adj_cap := 0;
         ln_potensial_rel := ln_current_avail - ln_current_adj_cap;

         IF p_asset_id = cur_vap_rec.asset_id THEN
           RETURN ln_potensial_rel;
         END IF;
       ELSIF cur_vap_rec.shares = 'Y' THEN
         ln_current_avail := cur_vap_rec.avail;
         ln_current_adj_cap := cur_vap_rec.adj_cap;
         ln_potensial_rel := (ln_previous_potensial_rel + cur_vap_rec.avail) - cur_vap_rec.adj_cap;

         IF ln_potensial_rel < 0 THEN
           ln_potensial_rel :=0;
         END IF;
         ln_previous_potensial_rel := ln_potensial_rel;

         IF p_asset_id = cur_vap_rec.asset_id THEN
           RETURN ln_potensial_rel;
         END IF;
       END IF;
     END LOOP;
	RETURN 0;

END calcPotensialRelease;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calcUpsetRelease
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
FUNCTION calcUpsetRelease(p_object_id VARCHAR2, p_asset_id VARCHAR2, p_daytime DATE)
--</EC-DOC>
RETURN NUMBER
IS

CURSOR c_vapor_release IS
SELECT (ec_eqpm_reference_value.normal_rec_cap_rate(asset_id, daytime, '<=') / 24) *
       (EcBp_Stream_VentFlare.calcRunHours(p_asset_id, p_daytime) -
       EcBp_Stream_VentFlare.calcRoutineRunHours(parent_object_id,asset_id,
                                                  p_daytime)) as adj_cap,
       EcBp_Stream_VentFlare.calcUpsetAvailVapour(object_id,
                                                 asset_id,
                                                 parent_object_id,
                                                 daytime) as avail
  FROM V_STRM_DAY_ROU_REC_VAP
 WHERE daytime = p_daytime
   AND object_id = p_object_id
   AND asset_id = p_asset_id
 ORDER BY sequence;

    ln_calcUpsetRelease NUMBER;


BEGIN
     FOR cur_vap_rel IN c_vapor_release LOOP
       IF cur_vap_rel.avail > cur_vap_rel.adj_cap THEN
         ln_calcUpsetRelease := cur_vap_rel.avail - cur_vap_rel.adj_cap;
       ELSE
         ln_calcUpsetRelease := 0;
       END IF;
     END LOOP;

	 RETURN ln_calcUpsetRelease;

END calcUpsetRelease;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calcNormalMTDAvg
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
FUNCTION calcNormalMTDAvg(p_object_id VARCHAR2, p_daytime DATE)
--</EC-DOC>
RETURN NUMBER
IS

BEGIN

	   RETURN NULL;

END calcNormalMTDAvg;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calcGrsVolMass
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
FUNCTION calcGrsVolMass(p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS


BEGIN


	 RETURN NULL;


END calcGrsVolMass;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calcNonRoutineEqpmFailure
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
FUNCTION calcNonRoutineEqpmFailure(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS


BEGIN


	 RETURN NULL;


END calcNonRoutineEqpmFailure;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : addEqpmEvent
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
PROCEDURE addEqpmEvent(p_object_id VARCHAR2, p_daytime DATE, p_user VARCHAR2)

--</EC-DOC>
IS


BEGIN

   NULL;

END addEqpmEvent;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calcRoutineRunHours
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
FUNCTION calcRoutineRunHours(p_process_unit_id VARCHAR2, p_asset_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS


BEGIN


	 RETURN NULL;


END calcRoutineRunHours;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calcWellDuration
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
FUNCTION calcWellDuration(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE, p_well_id VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS


BEGIN


	 RETURN NULL;


END calcWellDuration;


END ue_stream_ventflare;