CREATE OR REPLACE PACKAGE BODY EcDp_Well_Swing_Theoretical IS

/****************************************************************
** Package        :  EcDp_Well_Swing_Theoretical, body part
**
** $Revision: 1.9 $
**
** Purpose        :  Handle the Calculations for Swing Wells
**
** Documentation  :  www.energy-components.com
**
** Created  : 01.03.2010  aliassit
**
** Modification history:
**
** Version  Date       Whom  Change description:
** -------  --------   ----  --------------------------------------
** 1.0      11.03.10   aliassit   Initial version
*           05.05.10   aliassit   ECPD-14305: Remove unused parameter and fix all methods.
*  2.0      13.5.11    musthram   ECPD-16989: Added calcStreamWellMassDay,calcWellGasMassDay,calcWellWatMassDay,calcWellCondMassDay
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasStdRateToAsset                                                                   --
-- Description    : Calculate Gas volumes based on the volumes prior to swing                    --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   : Well_swing_connection                                                        --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getGasStdRateToAsset(
         p_object_id well.object_id%TYPE,
         p_fromday DATE,
         p_today DATE DEFAULT NULL)

RETURN NUMBER

--</EC-DOC>
IS

ln_ret_val NUMBER;
ln_dry_gas NUMBER;
ln_wet_gas NUMBER;
ln_wdr NUMBER;
ln_dwf NUMBER;


BEGIN

  ln_wet_gas := ec_well_swing_connection.well_wet_gas_vol(p_object_id,p_fromday);
  ln_wdr := ecbp_well_theoretical.findWetDryFactor(p_object_id, p_fromday);
  ln_dwf := ecbp_well_theoretical.findDryWetFactor(p_object_id, p_fromday);
  ln_dry_gas := ec_well_swing_connection.dry_gas_vol(p_object_id, p_fromday);
  IF (ln_dry_gas IS NOT NULL OR ln_wet_gas IS NOT NULL) THEN
    IF (ln_dry_gas > 0) THEN
      ln_ret_val :=  ln_dry_gas;
    ELSIF ln_dwf IS NULL THEN
      ln_ret_val := ln_wet_gas / ln_wdr;
    ELSE
      ln_ret_val := ln_wet_gas * ln_dwf;
    END IF;
  ELSE
    ln_ret_val := null;
  END IF;

RETURN ln_ret_val;
END getGasStdRateToAsset;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCondStdRateToAsset                                                                  --
-- Description    : Calculate Cond volumes based on the volumes prior to swing                   --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   : Well_swing_connection                                                        --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getCondStdRateToAsset(
         p_object_id well.object_id%TYPE,
         p_fromday DATE,
         p_today DATE DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_ret_val NUMBER;
ln_gas NUMBER;
ln_cgr NUMBER;

BEGIN

  ln_cgr := ecbp_well_theoretical.findCondGasRatio(p_object_id, p_fromday);
  ln_gas := getGasStdRateToAsset(p_object_id, p_fromday);
  ln_ret_val := ln_gas * ln_cgr;

RETURN ln_ret_val;
END getCondStdRateToAsset;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWatStdRateToAsset                                                                 --
-- Description    : Calculate water volumes based on the volumes prior to swing                  --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   : Well_swing_connection                                                        --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getWatStdRateToAsset(
         p_object_id well.object_id%TYPE,
         p_fromday DATE,
         p_today DATE DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

ln_ret_val NUMBER;
ln_wgr NUMBER;
ln_gas NUMBER;


BEGIN

  ln_wgr := ecbp_well_theoretical.findWaterGasRatio(p_object_id, p_fromday);
  ln_gas :=  getGasStdRateToAsset(p_object_id, p_fromday);
  ln_ret_val := ln_gas * ln_wgr;

RETURN ln_ret_val;
END getWatStdRateToAsset;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcWellWatDay                                                                 --
-- Description    : Calculate water volumes per well for allocation                --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :  Well_version, system days, strm_version                                                         --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------

FUNCTION calcWellWatDay(
    p_object_id       well.object_id%TYPE,
    p_asset_id        VARCHAR2,
    p_daytime  DATE,
    p_stream_id  VARCHAR2 DEFAULT NULL)

RETURN NUMBER IS

-- Cursor that list any swing during the production day.
Cursor c_swing is
select c.object_id, c.asset_id, c.daytime, c.well_wet_gas_vol, c.dry_gas_vol
from well_swing_connection c
where c.object_id = p_object_id
and c.event_day = p_daytime
order by c.daytime;

-- Cursor to find the asset the well is swung to prior the production day.
Cursor c_prev_swing is
select c.asset_id
from well_swing_connection c
where c.object_id = p_object_id
and c.daytime = (select max(c1.daytime) from well_swing_connection c1 where c1.object_id = c.object_id and c1.event_day < p_daytime);


ln_return_value     NUMBER;
ln_DWF              NUMBER;
ln_swing_volume     NUMBER;
ln_meas_volume      NUMBER;
lb_swing            BOOLEAN default false;
lv_asset_prev_swing varchar2(32);

BEGIN

   IF ec_well_version.calc_water_method(p_Object_id, p_daytime, '<=') = Ecdp_Calc_Method.MEAS_SWING_WELL THEN
      ln_return_value := 0;
      -- Find the asset the well is swing to before this production day.
      for c_res_from in c_prev_swing loop
          lv_asset_prev_swing := c_res_from.asset_id;
      end loop;

      -- Check if there are any swing during the production day.
      For c_res in c_swing loop
        lb_swing := true;
        ln_DWF := Ecbp_Well_Theoretical.findDryWetFactor(p_object_id, p_daytime);
        IF ln_DWF is null then ln_DWF := 1 / nvl(Ecbp_Well_Theoretical.findWetDryFactor(p_object_id, p_daytime),1); END IF; -- If the dry wet ratio is null, calculate it from the wet dry ratio

        if p_asset_id = lv_asset_prev_swing THEN
          -- The well swung from the stream's to node. The Volume before swing is for this node
          -- Calculate water from the measured gas + WGR factor.
          IF c_res.dry_gas_vol is not null then
            ln_swing_volume := c_res.dry_gas_vol * Ecbp_Well_Theoretical.findWaterGasRatio(p_object_id, p_daytime);
          ELSIF c_res.well_wet_gas_vol is not null then
               ln_swing_volume := c_res.well_wet_gas_vol * ln_DWF * Ecbp_Well_Theoretical.findWaterGasRatio(p_object_id, p_daytime);
          END IF;
        elsif p_asset_id = c_res.asset_id THEN
          -- if this is the last swing for the day, then the daily measured volume will be the volume,
          -- except when both the gas volume before swing and the daily measured gas volume are measured as wet gas,
          -- then volume is the different between swing before and measured.
          ln_swing_volume := 0;
          IF c_res.dry_gas_vol is not null or ecbp_well_theoretical.getGasStdRateDay(p_object_id,p_daytime,'MEASURED') is not null THEN
             ln_meas_volume := NVL(EcBp_Well_Theoretical.getWatStdRateDay(p_object_id,p_daytime,'MEASURED'),
                                  NVL(ecbp_well_theoretical.getGasStdRateDay(p_object_id,p_daytime,'MEASURED'),
                                       ecbp_well_theoretical.getGasStdRateDay(p_object_id,p_daytime,'WET_GAS_MEASURED'))
                                     * Ecbp_Well_Theoretical.findWaterGasRatio(p_object_id, p_daytime));
          ELSIF c_res.well_wet_gas_vol is not null THEN
             ln_meas_volume := NVL(EcBp_Well_Theoretical.getWatStdRateDay(p_object_id,p_daytime,'MEASURED'),
                                  NVL(ecbp_well_theoretical.getGasStdRateDay(p_object_id,p_daytime,'MEASURED'),
                                       ecbp_well_theoretical.getGasStdRateDay(p_object_id,p_daytime,'WET_GAS_MEASURED'))
                                     * Ecbp_Well_Theoretical.findWaterGasRatio(p_object_id, p_daytime))
                              - c_res.well_wet_gas_vol * ln_DWF * Ecbp_Well_Theoretical.findWaterGasRatio(p_object_id, p_daytime);
          END IF;
        else
          -- The well is not production into the stream's to node. Return 0
          ln_swing_volume := 0;
        end if;
        -- Sum up the swing volume.
        ln_return_value := ln_return_value + ln_swing_volume;
        lv_asset_prev_swing := c_res.asset_id;
      end loop;

      -- Check if there was any swing during the production day.
      IF lb_swing THEN
         -- Check if the last swing was to the stream's to node, if so add the measured volume.
          IF p_asset_id = lv_asset_prev_swing THEN
             ln_return_value := ln_return_value + ln_meas_volume;
          END IF;
      ELSE
        IF p_asset_id = lv_asset_prev_swing THEN
          -- The well is production into the stream's to node.
          ln_return_value := EcBp_Well_Theoretical.getWatStdRateDay(p_object_id, p_daytime);
        ELSE
          -- The well is not production into the stream's to node, return 0.
          ln_return_value := 0;
        END IF;
      END IF;
   ELSE
       ln_return_value := EcBp_Well_Theoretical.getWatStdRateDay(p_object_id, p_daytime) * Ecdp_Well.getPwelFracToStrmToNode(p_object_id,p_stream_id,p_daytime);
   END IF;

   RETURN ln_return_value;
END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcWellGasDay                                                                 --
-- Description    : Calculate gas volumes per well for allocation                --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   : Well_version, system days, strm_version                                                      --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------

FUNCTION calcWellGasDay(
    p_object_id       well.object_id%TYPE,
    p_asset_id        VARCHAR2,
    p_daytime  DATE,
    p_stream_id  VARCHAR2 DEFAULT NULL)

RETURN NUMBER IS

-- Cursor that list any swing during the production day.
Cursor c_swing is
select c.object_id, c.asset_id, c.daytime, c.well_wet_gas_vol, c.dry_gas_vol
from well_swing_connection c
where c.object_id = p_object_id
and c.event_day = p_daytime
order by c.daytime;

-- Cursor to find the asset the well is swung to prior the production day.
Cursor c_prev_swing is
select c.asset_id
from well_swing_connection c
where c.object_id = p_object_id
and c.daytime = (select max(c1.daytime) from well_swing_connection c1 where c1.object_id = c.object_id and c1.event_day < p_daytime);


ln_return_value     NUMBER;
ln_DWF              NUMBER;
ln_swing_volume     NUMBER;
ln_meas_volume      NUMBER;
lb_swing            BOOLEAN default false;
lv_asset_prev_swing varchar2(32);

BEGIN

   IF ec_well_version.calc_gas_method(p_Object_id, p_daytime, '<=') = Ecdp_Calc_Method.MEAS_SWING_WELL THEN
      ln_return_value := 0;
      -- Find the asset the well is swing to before this production day.
      for c_res_from in c_prev_swing loop
          lv_asset_prev_swing := c_res_from.asset_id;
      end loop;

      -- Check if there are any swing during the production day.
      For c_res in c_swing loop
        lb_swing := true;
        ln_DWF := Ecbp_Well_Theoretical.findDryWetFactor(p_object_id, p_daytime);
        IF ln_DWF is null then ln_DWF := 1 / nvl(Ecbp_Well_Theoretical.findWetDryFactor(p_object_id, p_daytime),1); END IF; -- If the dry wet ratio is null, calculate it from the wet dry ratio

        if p_asset_id = lv_asset_prev_swing THEN
          -- The well swung from the stream's to node. The Volume before swing is for this node
          -- Calculate water from the measured gas + WGR factor.
          IF c_res.dry_gas_vol is not null then
            ln_swing_volume := c_res.dry_gas_vol;
          ELSIF c_res.well_wet_gas_vol is not null then
            ln_swing_volume := c_res.well_wet_gas_vol * ln_DWF;
          END IF;
        elsif p_asset_id = c_res.asset_id THEN
          -- if this is the last swing for the day, then the daily measured volume will be the swing volume,
          -- except when both the volume before swing and the daily measured volume are measured as wet gas,
          -- then return the different between swing before and measured.
          ln_swing_volume := 0;
          ln_meas_volume := ecbp_well_theoretical.getGasStdRateDay(p_object_id,p_daytime,'MEASURED');

          IF ln_meas_volume is null THEN
            IF c_res.dry_gas_vol is not null THEN
               ln_meas_volume := ecbp_well_theoretical.getGasStdRateDay(p_object_id,p_daytime,'WET_GAS_MEASURED');
            ELSIF c_res.well_wet_gas_vol is not null THEN
               ln_meas_volume := ecbp_well_theoretical.getGasStdRateDay(p_object_id,p_daytime,'WET_GAS_MEASURED') - c_res.well_wet_gas_vol * ln_DWF;
            END IF;
          END IF;
        else
          -- The well is not production into the stream's to node. Return 0
          ln_swing_volume := 0;
        end if;
        ln_return_value := ln_return_value + ln_swing_volume;
        lv_asset_prev_swing := c_res.asset_id;
      end loop;

      -- Check if there was any swing during the production day.
      IF lb_swing THEN
         -- Check if the last swing was to the stream's to node, if so add the measured volume.
          IF p_asset_id = lv_asset_prev_swing THEN
             ln_return_value := ln_return_value + ln_meas_volume;
          END IF;
      ELSE
        IF p_asset_id = lv_asset_prev_swing THEN
          -- The well is production into the stream's to node.
          ln_return_value := EcBp_Well_Theoretical.getGasStdRateDay(p_object_id, p_daytime);
        ELSE
          -- The well is not production into the stream's to node, return 0.
          ln_return_value := 0;
        END IF;
      END IF;
   ELSE
       ln_return_value := EcBp_Well_Theoretical.getGasStdRateDay(p_object_id, p_daytime) * Ecdp_Well.getPwelFracToStrmToNode(p_object_id,p_stream_id,p_daytime);
   END IF;

   RETURN ln_return_value;
END;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcWellCondDay                                                                 --
-- Description    : Calculate condensate volumes per well for allocation                --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   : Well_version, system days, strm_version                                                      --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcWellCondDay(
    p_object_id       well.object_id%TYPE,
    p_asset_id        VARCHAR2,
    p_daytime  DATE,
    p_stream_id  VARCHAR2 DEFAULT NULL)

RETURN NUMBER IS

-- Cursor that list any swing during the production day.
Cursor c_swing is
select c.object_id, c.asset_id, c.daytime, c.well_wet_gas_vol, c.dry_gas_vol
from well_swing_connection c
where c.object_id = p_object_id
and c.event_day = p_daytime
order by c.daytime;

-- Cursor to find the asset the well is swung to prior the production day.
Cursor c_prev_swing is
select c.asset_id
from well_swing_connection c
where c.object_id = p_object_id
and c.daytime = (select max(c1.daytime) from well_swing_connection c1 where c1.object_id = c.object_id and c1.event_day < p_daytime);


ln_return_value     NUMBER;
ln_DWF              NUMBER;
ln_swing_volume     NUMBER;
ln_meas_volume      NUMBER;
lb_swing            BOOLEAN default false;
lv_asset_prev_swing varchar2(32);

BEGIN

   IF ec_well_version.calc_cond_method(p_Object_id, p_daytime, '<=') = Ecdp_Calc_Method.MEAS_SWING_WELL THEN
      ln_return_value := 0;
      -- Find the asset the well is swing to before this production day.
      for c_res_from in c_prev_swing loop
          lv_asset_prev_swing := c_res_from.asset_id;
      end loop;

      -- Check if there are any swing during the production day.
      For c_res in c_swing loop
        lb_swing := true;
        ln_DWF := Ecbp_Well_Theoretical.findDryWetFactor(p_object_id, p_daytime);
        IF ln_DWF is null then ln_DWF := 1 / nvl(Ecbp_Well_Theoretical.findWetDryFactor(p_object_id, p_daytime),1); END IF; -- If the dry wet ratio is null, calculate it from the wet dry ratio

        if p_asset_id = lv_asset_prev_swing THEN
          -- The well swung from the stream's to node. The Volume before swing is for this node
          -- Calculate water from the measured gas + CGR factor.
          IF c_res.dry_gas_vol is not null then
            ln_swing_volume := c_res.dry_gas_vol * Ecbp_Well_Theoretical.findCondGasRatio(p_object_id, p_daytime);
          ELSIF c_res.well_wet_gas_vol is not null then
               ln_swing_volume := c_res.well_wet_gas_vol * ln_DWF * Ecbp_Well_Theoretical.findCondGasRatio(p_object_id, p_daytime);
          END IF;
        elsif p_asset_id = c_res.asset_id THEN
          -- if this is the last swing for the day, then the daily measured volume will be the volume,
          -- except when both the gas volume before swing and the daily measured gas volume are measured as wet gas,
          -- then volume is the different between swing before and measured.
          ln_swing_volume := 0;
          IF c_res.dry_gas_vol is not null or ecbp_well_theoretical.getGasStdRateDay(p_object_id,p_daytime,'MEASURED') is not null THEN
             ln_meas_volume := nvl(EcBp_Well_Theoretical.getCondStdRateDay(p_object_id,p_daytime,'MEASURED'),
                                  NVL(ecbp_well_theoretical.getGasStdRateDay(p_object_id,p_daytime,'MEASURED'),
                                       ecbp_well_theoretical.getGasStdRateDay(p_object_id,p_daytime,'WET_GAS_MEASURED'))
                                     * Ecbp_Well_Theoretical.findCondGasRatio(p_object_id, p_daytime));
          ELSIF c_res.well_wet_gas_vol is not null THEN
             ln_meas_volume := nvl(EcBp_Well_Theoretical.getCondStdRateDay(p_object_id,p_daytime,'MEASURED'),
                                  NVL(ecbp_well_theoretical.getGasStdRateDay(p_object_id,p_daytime,'MEASURED'),
                                       ecbp_well_theoretical.getGasStdRateDay(p_object_id,p_daytime,'WET_GAS_MEASURED'))
                                     * Ecbp_Well_Theoretical.findCondGasRatio(p_object_id, p_daytime))
                             - c_res.well_wet_gas_vol * ln_DWF * Ecbp_Well_Theoretical.findCondGasRatio(p_object_id, p_daytime);

          END IF;
        else
          -- The well is not production into the stream's to node. Return 0
          ln_swing_volume := 0;
        end if;
        ln_return_value := ln_return_value + ln_swing_volume;
        lv_asset_prev_swing := c_res.asset_id;
      end loop;

      -- Check if there was any swing during the production day.
      IF lb_swing THEN
         -- Check if the last swing was to the stream's to node, if so add the measured volume.
          IF p_asset_id = lv_asset_prev_swing THEN
             ln_return_value := ln_return_value + ln_meas_volume;
          END IF;
      ELSE
        IF p_asset_id = lv_asset_prev_swing THEN
          -- The well is production into the stream's to node.
          ln_return_value := EcBp_Well_Theoretical.getCondStdRateDay(p_object_id, p_daytime);
        ELSE
          -- The well is not production into the stream's to node, return 0.
          ln_return_value := 0;
        END IF;
      END IF;
   ELSE
       ln_return_value := EcBp_Well_Theoretical.getCondStdRateDay(p_object_id, p_daytime) * Ecdp_Well.getPwelFracToStrmToNode(p_object_id,p_stream_id,p_daytime);
   END IF;

   RETURN ln_return_value;
END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcWellOilDay                                                                 --
-- Description    : Calculate condensate volumes per well for allocation                --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   : Well_version, system days, strm_version                                                      --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcWellOilDay(
    p_object_id       well.object_id%TYPE,
    p_daytime  DATE,
    p_stream_id  VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS


ln_return_value NUMBER;

BEGIN

  ln_return_value := EcBp_Well_Theoretical.getOilStdRateDay(p_object_id, p_daytime) * Ecdp_Well.getPwelFracToStrmToNode(p_object_id,p_stream_id,p_daytime);

RETURN ln_return_value;
END calcWellOilDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcStreamWellDay                                                            --
-- Description    : Calculate theoretical volumes per well and phase                             --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   : Well_version, system days, strm_version                                      --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcStreamWellDay(
    p_object_id       well.object_id%TYPE,
    p_asset_id        VARCHAR2,
    p_daytime  DATE,
    p_stream_id  stream.object_id%TYPE DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS


ln_return_value NUMBER;
lv2_phase    strm_version.stream_phase%type;


BEGIN
  lv2_phase := ec_strm_version.stream_phase(p_stream_id, p_daytime, '<=');

  IF nvl(ec_well_version.alloc_flag(p_object_id, p_daytime, '<='),'N') = 'Y' THEN
      IF lv2_phase = EcDp_Phase.OIL THEN
          ln_return_value := calcWellOilDay(p_object_id, p_daytime, p_stream_id);
      ELSIF lv2_phase = EcDp_Phase.GAS THEN
          ln_return_value := calcWellGasDay(p_object_id, p_asset_id, p_daytime, p_stream_id);
      ELSIF lv2_phase = EcDp_Phase.CONDENSATE THEN
          ln_return_value := calcWellCondDay(p_object_id, p_asset_id, p_daytime, p_stream_id);
      ELSIF lv2_phase = EcDp_Phase.WATER THEN
          ln_return_value := calcWellWatDay(p_object_id, p_asset_id, p_daytime, p_stream_id);
      ELSE
          ln_return_value := NULL;
      END IF;
  ELSE
      ln_return_value := NULL;
  END IF;


  RETURN ln_return_value;

END calcStreamWellDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcWellWatMassDay                                                                 --
-- Description    : Calculate water mass per well for allocation                --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :  Well_version, system days, strm_version                                                         --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------

FUNCTION calcWellWatMassDay(
    p_object_id       well.object_id%TYPE,
    --p_asset_id        VARCHAR2,
    p_daytime  DATE,
    p_stream_id  VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS
ln_return_value NUMBER;

BEGIN

  ln_return_value := EcBp_Well_Theoretical.findWaterMassDay(p_object_id, p_daytime) * Ecdp_Well.getPwelFracToStrmToNode(p_object_id,p_stream_id,p_daytime);

RETURN ln_return_value;
END calcWellWatMassDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcWellCondMassDay                                                                 --
-- Description    : Calculate water condensate per well for allocation                --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :  Well_version, system days, strm_version                                                         --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------

FUNCTION calcWellCondMassDay(
    p_object_id       well.object_id%TYPE,
    --p_asset_id        VARCHAR2,
    p_daytime  DATE,
    p_stream_id  VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS
ln_return_value NUMBER;

BEGIN

   ln_return_value := EcBp_Well_Theoretical.findCondMassDay(p_object_id, p_daytime) * Ecdp_Well.getPwelFracToStrmToNode(p_object_id,p_stream_id,p_daytime);

RETURN ln_return_value;
END calcWellCondMassDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcWellGasMassDay                                                               --
-- Description    : Calculate gas mass per well for allocation                                   --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   : Well_version, system days, strm_version                                      --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcWellGasMassDay(
    p_object_id       well.object_id%TYPE,
    p_daytime  DATE,
    p_stream_id  VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS


ln_return_value NUMBER;

BEGIN

  ln_return_value := EcBp_Well_Theoretical.findGasMassDay(p_object_id, p_daytime) * Ecdp_Well.getPwelFracToStrmToNode(p_object_id,p_stream_id,p_daytime);

RETURN ln_return_value;
END calcWellGasMassDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcStreamWellMassDay                                                            --
-- Description    : Calculate theoretical volumes per well and phase                             --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   : Well_version, system days, strm_version                                      --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcStreamWellMassDay(
    p_object_id       well.object_id%TYPE,
    p_daytime  DATE,
    p_stream_id  stream.object_id%TYPE DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS


ln_return_value NUMBER;
lv2_phase    strm_version.stream_phase%type;


BEGIN
  lv2_phase := ec_strm_version.stream_phase(p_stream_id, p_daytime, '<=');

  IF nvl(ec_well_version.alloc_flag(p_object_id, p_daytime, '<='),'N') = 'Y' THEN
    IF lv2_phase = EcDp_Phase.GAS THEN
        ln_return_value := calcWellGasMassDay(p_object_id, p_daytime, p_stream_id);
    ELSIF lv2_phase = EcDp_Phase.CONDENSATE THEN
        ln_return_value := calcWellCondMassDay(p_object_id, p_daytime, p_stream_id);
    ELSIF lv2_phase = EcDp_Phase.WATER THEN
        ln_return_value := calcWellWatMassDay(p_object_id, p_daytime, p_stream_id);
    ELSE
        ln_return_value := NULL;
    END IF;
  ELSE
    ln_return_value := NULL;
  END IF;

  RETURN ln_return_value;

END calcStreamWellMassDay;

END EcDp_Well_Swing_Theoretical;