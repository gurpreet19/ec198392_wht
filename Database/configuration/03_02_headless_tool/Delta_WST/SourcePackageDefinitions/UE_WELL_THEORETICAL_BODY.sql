CREATE OR REPLACE PACKAGE BODY Ue_Well_Theoretical IS
/****************************************************************
** Package        :  Ue_Well_Theoretical, body part
**
** This package is used to program theoretical calculation when a predefined method supplied by EC does not cover the requirements.
** Upgrade processes will never replace this package.
** Version  Date      Whom      Change description:
** -------  ------    -----     -----------------------------------
**          22.11.07  Yoon Oon  ECPD-6635: Added new functions getDiluentStdRateDay, getGasLiftStdRateDay
**          07.01.08  Kenneth
**                    Masamba   ECPD-6861: Added new functions findWaterCutPct, findCondGasRatio, findGasOilRatio, findSand, findWetDryFactor
**          04.03.08	oonnnng	  ECPD-7593: Add new function findWaterGasRatio().
**          17.04.08  sharawan  ECPD-8222: Add new UE functions for sub daily methods
**                              (getOilStdVolSubDay, getGasStdVolSubDay, getWatStdVolSubDay, getCondStdVolSubDay, getGasLiftStdVolSubDay, getDiluentStdVolSubDay).
**          18.08.08	rajarsar  ECPD-9038: Add new function getCO2StdRateDay().
**          19.01.10  aliassit  ECPD-13264: Added new function getGasEnergyDay() and findGCV()
**          28.01.10  madondin  ECPD-13375: WELL - Added USER_EXIT to function findOilStdDensity, findGasStdDensity and findWatStdDensity
**          15.03.10  leongsei  ECPD-13916: Added function findGasWaterRatio
**          18.03.10  aliassit  ECPD-14146: Added function findDryWetFactor
**          26.10-10  Leongwen  ECPD-15122 PT well fluid rate estimation should also work for user exit methods
**          16.07.12  Leongwen  ECPD-21376 Added FUNCTION getInjectedMassStdRateDay()
** 			02.10.13  abdulmaw  ECPD-24427: Added new function getMeterMethod.
** 			08.10.13  abdulmaw  ECPD-24390: Added new function findFuelFlareVent to support fuel, flare and vent in well.
**	 		08.01.15  dhavaalo  ECPD-25537: Added new function getOilStdRateEvent,getGasStdRateEvent,getWatStdRateEvent and getCondStdRateEvent
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getOilStdRateDay
-- Description    : Returns theoretical oil volume
---------------------------------------------------------------------------------------------------
FUNCTION getOilStdRateDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE,
   p_result_no   NUMBER DEFAULT 0)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getOilStdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasStdRateDay
-- Description    : Returns theoretical gas volume
---------------------------------------------------------------------------------------------------
FUNCTION getGasStdRateDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE,
   p_result_no   NUMBER DEFAULT 0)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getGasStdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWatStdRateDay
-- Description    : Returns theoretical water volume
---------------------------------------------------------------------------------------------------
FUNCTION getWatStdRateDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE,
   p_result_no   NUMBER DEFAULT 0)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getWatStdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCondStdRateDay
-- Description    : Returns theoretical condensate volume
---------------------------------------------------------------------------------------------------
FUNCTION getCondStdRateDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE,
   p_result_no   NUMBER DEFAULT 0)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN null;
END getCondStdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getInjectedStdRateDay
-- Description    : Returns theoretical injected volume
---------------------------------------------------------------------------------------------------
FUNCTION getInjectedStdRateDay(
   p_object_id   well.object_id%TYPE,
   p_inj_type VARCHAR2,
   p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN null;
END getInjectedStdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findOilMassDay
-- Description    : Returns theoretical oil mass
---------------------------------------------------------------------------------------------------
FUNCTION findOilMassDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findOilMassDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGasMassDay
-- Description    : Returns theoretical gas mass
---------------------------------------------------------------------------------------------------
FUNCTION findGasMassDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findGasMassDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWaterMassDay
-- Description    : Returns theoretical water mass
---------------------------------------------------------------------------------------------------
FUNCTION findWaterMassDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findWaterMassDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findCondMassDay
-- Description    : Returns theoretical cond mass
---------------------------------------------------------------------------------------------------
FUNCTION findCondMassDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findCondMassDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDiluentStdRateDay
-- Description    : Returns theoretical diluent volume
---------------------------------------------------------------------------------------------------
FUNCTION getDiluentStdRateDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getDiluentStdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasLiftStdRateDay
-- Description    : Returns theoretical gas lift volume
---------------------------------------------------------------------------------------------------
FUNCTION getGasLiftStdRateDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getGasLiftStdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWaterCutPct
-- Description    : Returns BSW volume for well on a given day at standard conditions, source method specifiedReturns theoretical gas lift volume
---------------------------------------------------------------------------------------------------
FUNCTION findWaterCutPct(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findWaterCutPct;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findCondGasRatio
-- Description    : Returns Condensate Gas Ratio for well on a given day at standard conditions, source method specified
---------------------------------------------------------------------------------------------------
FUNCTION findCondGasRatio(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findCondGasRatio;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGasOilRatio
-- Description    : Returns Gas Oil Ratio for well on a given day at standard conditions, source method specified
---------------------------------------------------------------------------------------------------
FUNCTION findGasOilRatio(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findGasOilRatio;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWaterOilRatio
-- Description    : Returns Water Oil Ratio for well on a given day at standard conditions, source method specified
---------------------------------------------------------------------------------------------------
FUNCTION findWaterOilRatio(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findWaterOilRatio;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findSand
-- Description    : Returns Sand for well on a given day at standard conditions, source method specified
---------------------------------------------------------------------------------------------------
FUNCTION findSand(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findSand;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWetDryFactor
-- Description    : Returns Wet Dry Factor Ratio for well on a given day at standard conditions, source method specified
---------------------------------------------------------------------------------------------------
FUNCTION findWetDryFactor(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findWetDryFactor;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWaterGasRatio
-- Description    : Returns Water Gas Ratio for well on a given day at standard conditions, source method specified
---------------------------------------------------------------------------------------------------
FUNCTION findWaterGasRatio(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findWaterGasRatio;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getOilStdVolSubDay
-- Description    : Returns sub daily theoretical oil volume
---------------------------------------------------------------------------------------------------
FUNCTION getOilStdVolSubDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getOilStdVolSubDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasStdVolSubDay
-- Description    : Returns sub daily theoretical gas volume
---------------------------------------------------------------------------------------------------
FUNCTION getGasStdVolSubDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getGasStdVolSubDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWatStdVolSubDay
-- Description    : Returns sub daily theoretical water volume
---------------------------------------------------------------------------------------------------
FUNCTION getWatStdVolSubDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getWatStdVolSubDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCondStdVolSubDay
-- Description    : Returns sub daily theoretical condensate volume
---------------------------------------------------------------------------------------------------
FUNCTION getCondStdVolSubDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getCondStdVolSubDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDiluentStdVolSubDay
-- Description    : Returns sub daily theoretical diluent volume
---------------------------------------------------------------------------------------------------
FUNCTION getDiluentStdVolSubDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getDiluentStdVolSubDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasLiftStdVolSubDay
-- Description    : Returns sub daily theoretical gas lift volume
---------------------------------------------------------------------------------------------------
FUNCTION getGasLiftStdVolSubDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getGasLiftStdVolSubDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : declineResult
-- Description    : Returns decline Result
---------------------------------------------------------------------------------------------------
FUNCTION declineResult(p_object_id    VARCHAR2,
                         p_daytime      DATE,
                         p_from_date    DATE,
                         p_phase        VARCHAR2,
                         p_value        VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN

   RETURN NULL;
END declineResult;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCO2StdRateDay
-- Description    : Returns theoretical CO2 volume
---------------------------------------------------------------------------------------------------
FUNCTION getCO2StdRateDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getCO2StdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGCV
-- Description    : Returns gas clorific value
---------------------------------------------------------------------------------------------------
FUNCTION findGCV(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findGCV;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasEnergyDay
-- Description    : Returns theoretical gas energy volume
---------------------------------------------------------------------------------------------------
FUNCTION getGasEnergyDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getGasEnergyDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findOilStdDensity
-- Description    : Returns oil density
---------------------------------------------------------------------------------------------------
FUNCTION findOilStdDensity(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findOilStdDensity;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGasStdDensity
-- Description    : Returns gas density
---------------------------------------------------------------------------------------------------
FUNCTION findGasStdDensity(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findGasStdDensity;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWatStdDensity
-- Description    : Returns water density
---------------------------------------------------------------------------------------------------
FUNCTION findWatStdDensity(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findWatStdDensity;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGasWaterRatio
-- Description    : Returns Gas Water Ratio for well on a given day at standard conditions, source method specified
---------------------------------------------------------------------------------------------------
FUNCTION findGasWaterRatio(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findGasWaterRatio;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findDryWetFactor
-- Description    : Returns Dry Wet Factor for well on a given day at standard conditions, source method specified
---------------------------------------------------------------------------------------------------
FUNCTION findDryWetFactor(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END findDryWetFactor;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getInjectedMassStdRateDay
-- Description    : Returns the injected standard mass rate on a given day.
---------------------------------------------------------------------------------------------------
FUNCTION getInjectedMassStdRateDay(
   p_object_id   well.object_id%TYPE,
   p_inj_type VARCHAR2,
   p_daytime     DATE )
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN NULL;
END getInjectedMassStdRateDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getMeterMethod
-- Description    : Returns the meter method.
---------------------------------------------------------------------------------------------------
FUNCTION getMeterMethod(
   p_object_id well.object_id%TYPE,
   p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN

   RETURN NULL;

END getMeterMethod;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findFuelFlareVent
-- Description    :
---------------------------------------------------------------------------------------------------
FUNCTION findFuelFlareVent(
         p_object_id well.object_id%TYPE,
         p_daytime DATE,
         p_ffv_type VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN

   RETURN NULL;

END findFuelFlareVent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getOilStdRateEvent
-- Description    : Returns theoretical oil rate
---------------------------------------------------------------------------------------------------
FUNCTION getOilStdRateEvent(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN null;
END getOilStdRateEvent;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasStdRateEvent
-- Description    : Returns theoretical gas rate
---------------------------------------------------------------------------------------------------
FUNCTION getGasStdRateEvent(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN null;
END getGasStdRateEvent;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWatStdRateEvent
-- Description    : Returns theoretical water rate
---------------------------------------------------------------------------------------------------
FUNCTION getWatStdRateEvent(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN null;
END getWatStdRateEvent;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCondStdRateEvent
-- Description    : Returns theoretical condensate rate
---------------------------------------------------------------------------------------------------
FUNCTION getCondStdRateEvent(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
   RETURN null;
END getCondStdRateEvent;

END Ue_well_theoretical;