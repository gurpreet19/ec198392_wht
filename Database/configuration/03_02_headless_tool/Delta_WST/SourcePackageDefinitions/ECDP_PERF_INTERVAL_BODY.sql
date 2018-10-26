CREATE OR REPLACE PACKAGE BODY EcDp_Perf_Interval IS
/****************************************************************
** Package      :  EcDp_Perf_Interval
**
** $Revision: 1.2 $
**
** Purpose      :  This package defines well/reservoir related
**                 functionality.

** Documentation:  www.energy-components.com
**
** Created      : 18.11.1999  Carl-Fredrik S�sen
**
** Modification history:
**
** Date         Whom       Change description:
** --------     ----       -----------------------------------
** 19.03.07     Olav       First Version
** 12.08.08     OONNNNG    ECPD-8670:  Add support of GAS_INJ and WAT_INJ in getPerfIntervalPhaseFraction function.
** 20.03.18     leongwen   ECPD-53390: Modified function getPerfIntervalPhaseFraction to sum up ln_perf_int_frac instead of ln_webo_int_frac.
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getPerfIntervalPhaseFraction                                                 --
-- Description    : Returns the fraction of a wells total production/injection of a given phase  --
--                  originating from a given perforation interval                                --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getPerfIntervalPhaseFraction(
  p_well_id well.object_id%TYPE,
  p_perf_interval_id IN perf_interval.object_id%TYPE,
  p_daytime DATE,
  p_phase  VARCHAR2)

RETURN NUMBER
--<EC-DOC>
IS
CURSOR well_perfIntervalCur(cp_well_object_id VARCHAR2) IS
  SELECT
  DISTINCT
  w.object_id AS WELL_ID,
  wbs.oil_contrib_pct as BoreOilPct,
  wbs.gas_contrib_pct as BoreGasPct,
  wbs.water_contrib_pct as BoreWaterPct,
  wbs.cond_contrib_pct as BoreCondPct,
  wbs.steam_contrib_pct as BoreSteamPct,
  wbs.gas_inj_pct as BoreGasInjPct,
  wbs.wat_inj_pct as BoreWatInjPct,
  wbis.oil_pct AS IntOilPct,
  wbis.gas_pct as IntGasPct,
  wbis.water_pct as IntWaterPct,
  wbis.cond_pct as IntCondPct,
  wbis.steam_pct as IntSteamPct,
  wbis.gas_inj_pct as IntGasInjPct,
  wbis.wat_inj_pct as IntWatInjPct,
  pis.oil_pct as PerfIntOilPct,
  pis.gas_pct as PerfIntGasPct,
  pis.water_pct as PerfIntWaterPct,
  pis.cond_pct as PerfIntCondPct,
  pis.steam_pct as PerfIntSteamPct,
  pis.gas_inj_pct as PerfIntGasInjPct,
  pis.wat_inj_pct as PerfIntWatInjPct,
  sd.daytime AS daytime
  FROM well w, webo_bore wb ,webo_interval wbi,system_days sd, webo_split_factor wbs, webo_interval_gor wbis, perf_interval pi, perf_interval_gor pis
  WHERE wb.well_id = w.object_id
  AND wbi.well_bore_id = wb.object_id
  AND pi.webo_interval_id = wbi.object_id
  AND wbs.well_bore_id = wb.object_id
  AND wbis.object_id = wbi.object_id
  AND pis.object_id = pi.object_id
  AND wbis.daytime <= sd.daytime
  AND (wbis.end_date is null OR wbis.end_date > sd.daytime)
  AND wbs.daytime <= sd.daytime
  AND (wbs.end_date is null OR wbs.end_date > sd.daytime)
  AND pis.daytime <= sd.daytime
  AND (pis.end_date is null OR pis.end_date > sd.daytime)
  AND sd.daytime = p_daytime
  AND w.object_id = cp_well_object_id
  AND pi.object_id = p_perf_interval_id;

  ln_well_rbf_frac   NUMBER;
  ln_perf_int_frac   NUMBER;
  lb_first BOOLEAN := TRUE;
  lv2_well_id VARCHAR2(32);

BEGIN
  lv2_well_id := NVL(p_well_id,getWellId(p_perf_interval_id));
  FOR myCur IN well_perfIntervalCur(lv2_well_id) LOOP
    IF p_phase = EcDp_Phase.OIL THEN
      ln_perf_int_frac := myCur.BoreOilPct/100 * myCur.IntOilPct/100 * myCur.Perfintoilpct/100;
    ELSIF p_phase = EcDp_Phase.GAS THEN
      ln_perf_int_frac := myCur.BoreGasPct/100 * myCur.IntGasPct/100 * myCur.Perfintgaspct/100;
    ELSIF p_phase = EcDp_Phase.WATER THEN
      ln_perf_int_frac := myCur.BoreWaterPct/100 * myCur.IntWaterPct/100 * myCur.Perfintwaterpct/100;
    ELSIF p_phase = EcDp_Phase.CONDENSATE THEN
      ln_perf_int_frac := myCur.BoreCondPct/100 * myCur.IntCondPct/100 * myCur.Perfintcondpct/100;
    ELSIF p_phase = EcDp_Phase.STEAM THEN
      ln_perf_int_frac := myCur.BoreSteamPct/100 * myCur.IntSteamPct/100 * myCur.Perfintsteampct/100;
    ELSIF p_phase = EcDp_Phase.GAS_INJ THEN
      ln_perf_int_frac := myCur.BoreGasInjPct/100 * myCur.IntGasInjPct/100 * myCur.PerfintGasInjpct/100;
    ELSIF p_phase = EcDp_Phase.WAT_INJ THEN
      ln_perf_int_frac := myCur.BoreWatInjPct/100 * myCur.IntWatInjPct/100 * myCur.PerfintWatInjpct/100;
    END IF;
    IF(lb_first) THEN
      ln_well_rbf_frac := ln_perf_int_frac;
      lb_first := FALSE;
    ELSE
      ln_well_rbf_frac := ln_well_rbf_frac + ln_perf_int_frac;
    END IF;
  END LOOP;
  RETURN ln_well_rbf_frac;
END getPerfIntervalPhaseFraction;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWellID                                                                    --
-- Description    : Returns the object id to the well for the perforation interval               --
--                                                                                               --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getWellID(
  p_object_id IN perf_interval.object_id%TYPE)
RETURN VARCHAR2
--<EC-DOC>
IS
CURSOR well_perfIntervalCur IS
  SELECT  wb.well_id  AS WELL_ID
  FROM webo_bore wb ,webo_interval wbi, perf_interval pi
  WHERE wbi.well_bore_id = wb.object_id
  AND pi.webo_interval_id = wbi.object_id
  AND pi.object_id = p_object_id;
  lv2_well_id         well.object_id%TYPE default null;
BEGIN
  FOR myCur IN well_perfIntervalCur LOOP
    lv2_well_id := myCur.well_id;
  END LOOP;
  RETURN lv2_well_id;
END getWellID;

END EcDp_Perf_Interval;