CREATE OR REPLACE PACKAGE BODY EcDp_Stream_Measured IS
/****************************************************************
** Package        :  EcDp_Stream_Measured
**
** $Revision: 1.8 $
**
** Purpose        :  This package is responsible for stream fluid information
**                   from allocated stream values
**
** Documentation  :  www.energy-components.com
**
** Created  : 22.11.1999  Carl-Fredrik S�sen
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------
** 21/12/1999  CFS    First version
** 10/04/2000  HNE    Replaced cursor loops with function call to MATH functions (EC package) where appropriate.
** 12/04/2000  HNE    BUGFIX: Return value if >= 0, not if > 0 !!
** 04.04.2001  KEJ    Documented functions and procedures.
** 23.07.2004  kaurrnar          Removed p_sysnam and p_stream_code and update as necessary
** 03.12.2004  DN     TI 1823: Removed dummy package constructor.
** 23.02.2005  kaurrnar     Removed deadcode. Changed stor_attribute to stor_version
** 28.04.2005  DN     Bug fix: phase columns must be declared varchar2(32).
** 08.08.2007  idrussab  ECPD-6122: use ec_strm_version.stream_phase replacing ecdp_stream.getStreamPhase
** 31.12.2008  sharawan  ECPD-10416:Replaced all references to EcDp_Type.pb_comp_number%TYPE with NUMBER in functions
**                       getGrsStdMass, getGrsStdVol, getNetStdMass, getNetStdVol, getStdDens, getWatMass, getWatVol.
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGrsStdMass                                                                --
-- Description    : Returns measured gross standard mass for a stream for a given period         --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions: ECDP_STREAM.GETSTREAMPHASE                                                   --
--                  EC_STRM_DAY_STREAM.MATH_GRS_MASS                                             --
--                  EC_STRM_DAY_STREAM.MATH_NET_MASS                                             --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      : If there is no measured gross mass and the phase is gas or water             --
--                  the function returns the net mass.                                           --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getGrsStdMass (
     p_object_id   stream.object_id%TYPE,
     p_fromday     DATE,
     p_today       DATE)

RETURN NUMBER
--<EC-DOC>
IS

ln_return_val NUMBER;
lv2_phase     VARCHAR2(32);
ln_grs_mass   NUMBER;

BEGIN

   lv2_phase  := Ec_Strm_Version.stream_phase(p_object_id,p_fromday, '<=');

   ln_grs_mass := ec_strm_day_stream.math_grs_mass(
                        p_object_id,
                        p_fromday,
                        NVL(p_today, p_fromday),
                        'SUM');

   IF ((lv2_phase IN ('GAS','WAT')) AND (ln_grs_mass IS NULL)) THEN

      ln_grs_mass := ec_strm_day_stream.math_net_mass(
                           p_object_id,
                           p_fromday,
                           NVL(p_today, p_fromday),
                           'SUM');
   END IF;

   IF (ln_grs_mass >= 0) THEN

      ln_return_val := ln_grs_mass;

   ELSE

      ln_return_val := NULL;

   END IF;

   RETURN ln_return_val;

END getGrsStdMass;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGrsStdVol                                                                 --
-- Description    : Returns measured gross standard volume for a stream for a given period.      --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions: ECDP_STREAM.GETSTREAMPHASE                                                   --
--                  EC_STRM_DAY_STREAM.MATH_GRS_VOL                                              --
--                  EC_STRM_DAY_STREAM.MATH_NET_VOL                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getGrsStdVol (
     p_object_id   stream.object_id%TYPE,
     p_fromday     DATE,
     p_today       DATE)

RETURN NUMBER
--<EC-DOC>
IS

ln_return_val NUMBER;
lv2_phase     VARCHAR2(32);
ln_grs_vol    NUMBER;

BEGIN

   ln_return_val := NULL;

   lv2_phase  := Ec_Strm_Version.stream_phase(p_object_id,p_fromday, '<=');

   ln_grs_vol := ec_strm_day_stream.math_grs_vol(
                        p_object_id,
                        p_fromday,
                        NVL(p_today, p_fromday),
                        'SUM');

   IF ((lv2_phase IN ('GAS','WAT')) AND (ln_grs_vol IS NULL)) THEN

      ln_grs_vol := ec_strm_day_stream.math_net_vol(
                           p_object_id,
                           p_fromday,
                           NVL(p_today, p_fromday),
                           'SUM');
   END IF;

   IF (ln_grs_vol >= 0) THEN

      ln_return_val := ln_grs_vol;

   ELSE

      ln_return_val := NULL;

   END IF;

   RETURN ln_return_val;

END getGrsStdVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNetStdMass                                                                --
-- Description    : Returns measured net standard mass for a stream in a given period.           --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions: EC_STRM_DAY_STREAM.MATH_NET_MASS                                             --
--                  EC_STRM_DAY_STREAM.MATH_GRS_MASS                                             --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getNetStdMass (
     p_object_id   stream.object_id%TYPE,
     p_fromday     DATE,
     p_today       DATE)

RETURN NUMBER
--<EC-DOC>
IS

ln_return_val NUMBER;
lv2_phase     VARCHAR2(32);
ln_net_mass   NUMBER;


BEGIN

   lv2_phase  := Ec_Strm_Version.stream_phase(p_object_id,p_fromday, '<=');

   ln_net_mass := ec_strm_day_stream.math_net_mass(
                        p_object_id,
                        p_fromday,
                        NVL(p_today, p_fromday),
                        'SUM');

   IF ((lv2_phase IN ('GAS','WAT')) AND (ln_net_mass IS NULL)) THEN

      ln_net_mass := ec_strm_day_stream.math_grs_mass(
                           p_object_id,
                           p_fromday,
                           NVL(p_today, p_fromday),
                           'SUM');
   END IF;

   IF (ln_net_mass >= 0) THEN

      ln_return_val := ln_net_mass;

   ELSE

      ln_return_val := NULL;

   END IF;

   RETURN ln_return_val;

END getNetStdMass;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNetStdVol                                                                 --
-- Description    : Returns measured net standard volume for a stream in a given period.         --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions: ECDP_STREAM.GETSTREAMPHASE                                                   --
--                  EC_STRM_DAY_STREAM.MATH_NET_VOL                                              --
--                  EC_STRM_DAY_STREAM.MATH_GRS_VOL                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getNetStdVol (
     p_object_id   stream.object_id%TYPE,
     p_fromday     DATE,
     p_today       DATE)

RETURN NUMBER
--<EC-DOC>
IS

ln_return_val NUMBER;
lv2_phase     VARCHAR2(32);
ln_net_vol    NUMBER;

BEGIN

   lv2_phase  := Ec_Strm_Version.stream_phase(p_object_id,p_fromday, '<=');

   ln_net_vol := ec_strm_day_stream.math_net_vol(
                        p_object_id,
                        p_fromday,
                        NVL(p_today, p_fromday),
                        'SUM');

   IF ((lv2_phase IN ('GAS','WAT','NGL')) AND (ln_net_vol IS NULL)) THEN -- added NGL for Valhall

      ln_net_vol := ec_strm_day_stream.math_grs_vol(
                           p_object_id,
                           p_fromday,
                           NVL(p_today, p_fromday),
                           'SUM');
   END IF;

   IF (ln_net_vol >= 0) THEN

      ln_return_val := ln_net_vol;

   ELSE

      ln_return_val := NULL;

   END IF;

   RETURN ln_return_val;

END getNetStdVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getStdDens                                                                   --
-- Description    : Returns standard density to use for given stream on a given day using data   --
--                  from strm_day_stream only                                                    --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions: ECDP_STREAM.GETSTREAMPHASE                                                   --
--                  EC_STRM_DAY_STREAM.ROW_BY_PK                                                 --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getStdDens (
     p_object_id    stream.object_id%TYPE,
     p_daytime      stor_version.daytime%TYPE)

RETURN NUMBER
--<EC-DOC>
IS

ln_return_val  NUMBER;
lv2_phase      VARCHAR2(32);
lr_strm        STRM_DAY_STREAM%ROWTYPE;

BEGIN

   lr_strm := ec_strm_day_stream.row_by_pk(
               p_object_id,
               p_daytime);

	lv2_phase := Ec_Strm_Version.stream_phase(p_object_id,p_daytime, '<=');

   IF (lr_strm.density IS NOT NULL) THEN

      ln_return_val := lr_strm.density;

   -- Calculate density from net mass and volume
   ELSIF ((lr_strm.net_vol > 0) AND (lr_strm.net_mass IS NOT NULL)) THEN

      ln_return_val := lr_strm.net_mass / lr_strm.net_vol;

   -- Calculate density from gross mass and volume if water or gas phase
   ELSIF ((lv2_phase IN ('GAS','WAT')) AND (lr_strm.grs_vol > 0) AND
          (lr_strm.grs_mass IS NOT NULL)) THEN

      ln_return_val := lr_strm.grs_mass / lr_strm.grs_vol;

   ELSE

      ln_return_val := NULL;

   END IF;


   RETURN ln_return_val;

END getStdDens;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWatMass                                                                   --
-- Description    : Returns measured water mass for a stream in a given period                   --
--                                                                                               --
-- Preconditions  : Water or oil stream.                                                         --
-- Postcondition  :                                                                              --
-- Using Tables   : SYSTEM_DAYS                                                                  --
--                                                                                               --
-- Using functions: EC_STRM_DAY_STREAM.MATH_WATER_MASS                                           --
--                  EC_STRM_DAY_STREAM.ROW_BY_PK                                                 --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      : The function assumes preferably a water stream and gets the measured value.  --
--                  If no value found it calulates the water mass using p_stream_code as an      --
--                  oil stream together with weigth fraction of BS_W.                            --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getWatMass (
     p_object_id    stream.object_id%TYPE,
     p_fromday     DATE,
     p_today       DATE)

RETURN NUMBER
--<EC-DOC>
IS

CURSOR c_system_days IS
SELECT daytime
FROM system_days
WHERE  daytime BETWEEN p_fromday AND Nvl(p_today, p_fromday);

lr_strm_day   strm_day_stream%ROWTYPE;
ln_return_val NUMBER;
ld_day        DATE;
ln_wat_mass   NUMBER;

BEGIN

   ln_wat_mass := ec_strm_day_stream.math_water_mass(
                        p_object_id,
                        p_fromday,
                        NVL(p_today, p_fromday),
                        'SUM');

   IF (ln_wat_mass IS NULL) THEN

      FOR mycur IN c_system_days LOOP

         ld_day      := mycur.daytime;

         lr_strm_day := ec_strm_day_stream.row_by_pk(
                           p_object_id,
                           ld_day);

         IF ((lr_strm_day.grs_mass IS NOT NULL) AND (lr_strm_day.bs_w_wt IS NOT NULL)) THEN
            -- This apply to water mass in an oil stream
            ln_wat_mass := ln_wat_mass + lr_strm_day.grs_mass * lr_strm_day.bs_w_wt;

         END IF;

      END LOOP;

   END IF;

   IF (ln_wat_mass >= 0) THEN

      ln_return_val := ln_wat_mass;

   ELSE

      ln_return_val := NULL;

   END IF;

   RETURN ln_return_val;

END getWatMass;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWatVol                                                                    --
-- Description    : Returns measured water volume for a stream in a given period                 --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   : SYSTEM_DAYS                                                                  --
--                                                                                               --
-- Using functions:                                                                              --
--                  EC_STRM_DAY_STREAM.MATH_WATER_VOL                                            --
--                  EC_STRM_DAY_STREAM.ROW_BY_PK                                                 --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getWatVol (
     p_object_id    stream.object_id%TYPE,
     p_fromday     DATE,
     p_today       DATE)

RETURN NUMBER
--<EC-DOC>
IS

CURSOR c_system_days IS
SELECT daytime
FROM system_days
WHERE  daytime BETWEEN p_fromday AND Nvl(p_today, p_fromday);

lr_strm_day   strm_day_stream%ROWTYPE;
ln_return_val NUMBER;
ld_day        DATE;
ln_wat_vol    NUMBER;

BEGIN

   ln_wat_vol := ec_strm_day_stream.math_water_vol(
                        p_object_id,
                        p_fromday,
                        NVL(p_today, p_fromday),
                        'SUM');

   IF (ln_wat_vol IS NULL) THEN

      FOR mycur IN c_system_days LOOP

         ld_day      := mycur.daytime;

         lr_strm_day := ec_strm_day_stream.row_by_pk(
                           p_object_id,
                           ld_day);

         IF ((lr_strm_day.grs_vol IS NOT NULL) AND (lr_strm_day.bs_w IS NOT NULL)) THEN
            -- This apply to water mass an oil stream
            ln_wat_vol := ln_wat_vol + lr_strm_day.grs_vol * lr_strm_day.bs_w;

         END IF;

      END LOOP;

   END IF;

   IF (ln_wat_vol >= 0) THEN

      ln_return_val := ln_wat_vol;

   ELSE

      ln_return_val := NULL;

   END IF;

   RETURN ln_return_val;

END getWatVol;

END;