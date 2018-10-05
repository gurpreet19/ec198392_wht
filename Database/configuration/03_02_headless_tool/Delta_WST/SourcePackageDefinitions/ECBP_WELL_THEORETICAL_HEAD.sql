CREATE OR REPLACE PACKAGE EcBp_Well_Theoretical IS

/****************************************************************
** Package        :  EcBp_Well_Theoretical, header part
**
** $Revision: 1.59 $
**
** Purpose        :  Calculates theoretical well values (rates etc)
**
** Documentation  :  www.energy-components.com
**
** Created  : 17.01.2000  Carl-Fredrik S?sen
**
** Modification history:
**
** Date     Whom  Change description:
** ------   ----- --------------------------------------
** 17.01.00 CFS      Initial version
** 29.02.00 DN       3 new functions returns choke or whp from standard rates.
** 01.03.00 DN       3 new functions returns gas lift rates.
** 02.03.00 DN       2 new functions returns injected rates.
**                   4 new functions returns representative values.
** 04.05.00 AV       Changed package to fit new curve model,
**                   Added new functions to find stdRate from halfhour
**                   Moved some functions to EcDp_Well_Theoretical
**                   Outdated functions removed.
** 20.07.00 DN       New function findStdVolInPeriod.
** 31.08.00 DN       New function calcStdRateDayWellToFlowline.
** 13.09.00 TEJ      New function getCurveInjectionStdRate.
** 22.01.01 UMF      New parameter in getXXXStdRateDayFromHalfHour - p_calc_method
** 16.10.01 HVE      Added calcWellDefermentVol
** 26.11.01 DN       Added findLookupValue. Ref. Hydro/Snorre.
** 05.03.04 BIH      Moved findLookupValue to EcDp_Well_theoretical and renamed it to getCurveParamValue
**                   Added function getCurveStdRate
**                   Rewrote getCurveRate to use new function EcDp_Well_Theoretical.getCurveStdRate
**                   Removed code and raise an exception for performance curve operations that are
**                   not supported in the new performance curve packages.
**                   Generally renamed wgr (WaterGasRatio) to gwr (GasWaterRatio) and updated formulas accordingly
**                   Removed getCurveProdStdRate and getCurveInjectionStdRate
** 13.05.04 DN       Renamed all half-hour functions to SubDay.
** 25.05.04 FBa      Major rewrite for Release 7.4.
** 27.05.04 FBa      Added density functions and updated mass functions
** 11.08.04 mazrina  removed sysnam and update as necessary
** 15.02.05	Ron	     Added new funtion getDiluentStdRateDay to support diluent in well test.
** 18.02.05 Hang     Direct call to Constant like EcDp_Well_Type.WATER_GAS_INJECTOR is replaced
**                   with new function of EcDp_Well_Type.isWaterInjector as per enhancement for TI#1874.
** 28.02.05 kaurrnar Removed deadcodes
** 12.04.05 SHN      Performance Test cleanup
** 18.04.05 Toha     TI 1940 added getGasLiftStdRateDay
**                   Update getCurveRate: new function interface.
** 23.03.06 kaurrnar TI#2622: Added new function findBSWVol, findCondGasRatio, findSand, findGasOilRatio and findWetDryFactor
** 30.03.06 eizwanik TI#3155: Added new functions getGrsLoadOilStdRateDay and getNetLoadOilStdRateDay, to calculate total gross and total net volume
**                   for truck ticket load-to-wells operations
** 05.04.06 johanein TI#3668 and 3670  Updated all CURVE methods in functions get#StdRateday, find#MassDay, get#StdVolSubDay
** 11.04.06 johanein TI#3331 and 3334: Established correct subtraction of gas lift and diluent from measured wells
**                   New functions: getDiluentStdVolSubDay, getGasLiftStdVolSubDay
** 05.05.06 kaurrnar TI#2622: Rename findBSWVol function to findWaterCutPct
** 31.1.07  rajarsar ECPD-3633: Added Calc_Method='LAST_RATE_AND_ONTIME' in getInjectedStdRateDay
** 31.1.07  rajarsar ECPD-3633: Added new function : getLastNotNullInjRate
** 27.3.07  rajarsar ECPD-2281, ECPD-2282, ECPD-2283 Added getInjectedStdVolume, getInjectedStdDailyRate, getProducedStdVolume and getProducedStdDailyRate.
**                   Modified getGasStdRateDay, getWatStdRateDay, getCondStdRateDay and getInjectedStdRateDay to handle TOTALIZER_EVENT and TOTALIZER_EVENT_EXTRAPOLATE
** 13.6.07  rajarsar ECPD-2282: Added new function : getLastNotNullClosingValueDate
** 06.09.07 Lau      ECPD-6268: Added function getGrsLoadOilMassDay and getNetLoadOilMassDay
** 07.09.07 rajarsar ECPD-6264: Updated function findOilMassDay, findGasMassDay, findWaterMassDay, findCondMassDay
** 10.10.07 rajarsar ECPD-6313: Updated function getOilStdRateDay, getGasStdRateDay, getCondStdRateDay, getInjectedStdRateDay
** 03.12.07 oonnnnng ECPD-6541: Add p_avg_flow_mass attribute to getCurveRate function's header.
** 04.03.08 oonnnng  ECPD-7593: Add new function findWaterGasRatio().
** 08.05.08 rajarsar ECPD-8339: Added new function declineResult().
** 08.05.08 rajarsar ECPD-5065: Added new function findWaterOilRatio().
** 26.08.08 rajarsar ECPD-9038: Added new function getCO2StdRateDay() and updated getGasStdRateDay().
** 21.01.10 rajarsar ECPD-13196: Added new function findBSWTruck
** 27.01.10 aliassit ECPD-13264: Added new function getGasEnergyDay() and findGCV()
** 15.03.10 leongsei ECPD-14119: Added function findGasWaterRatio
** 18.03.10 aliassit ECPD-14146: Added function findDryWetRatio()
** 02.09.11 rajarsar ECPD-18018: Updated getCurveRate to add p_calc_method as passing parameter.
** 16.07.12 leongwen ECPD-21376: Added the function getInjectedMassStdRateDay()
** 17-10-12 kumarsur ECPD-21509: Modified findWaterCutPct ,findCondGasRatio, findGasOilRatio, findWaterGasRatio and findWaterOilRatio
** 14-06-13 musthram ECPD-22763: Modified function findWaterCutPct
** 24.09.13 kumarsur ECPD-25305: Added new function getLoadWaterStdRateDay.
** 25.09.13 abdulmaw ECPD-24092: Added new function findAvgPrevMthBswTruck.
** 02.10.13 abdulmaw ECPD-24427: Added new function getMeterMethod.
** 08.10.13 abdulmaw ECPD-24390: Added new function findFuelFlareVent and sumFuelFlareVent to support fuel, flare and vent in well.
** 13.11.13 abdulmaw ECPD-22183: Added new function findSeasonalWell to support gettting seasonal value from Well Seasonal Value screen
** 22.11.13 kumarsur ECPD-18576: Modified getCurveRate added p_phase_current,p_ac_frequency and p_intake_press.
** 02.12.13 makkkkam ECPD-23832: Modified getCurveRate added p_mpm_oil_rate,p_mpm_gas_rate,p_mpm_water_rate and p_mpm_cond_rate.
** 20.01.14 wonggkai ECPD-26368: Modified getMeterMethod added p_meter_method parameter
** 08.01.15 dhavaalo ECPD-25537: ECPD-25537: Added new function getOilStdRateEvent,getGasStdRateEvent,getWatStdRateEvent and getCondStdRateEvent
** 05.07.15 chaudgau ECPD-29040: Modified parameter list to add p_today param to function getNetLoadOilStdRateDay and getLoadWaterStdRateDay
** 15.07.16 Singishi ECPD-37144: Added External Calculated Theoretical Rate 5
** 30.08.2016 beeraneh ECPD-35760: Added new functions findHCMassDay, findHCMassSubDay.
** 31.03.2017 chaudgau ECPD-36124: Modified getCurveRate to support new Curve Parameter AVG_DH_PUMP_POWER
** 16.08.2017 shindani ECPD-31708: Modified getCurveRate to support new Curve Parameter AVG_DP_VENTURI.
*****************************************************************/

FUNCTION getGasLiftStdRateDay(
   p_object_id        well.object_id%TYPE,
   p_daytime          DATE,
   p_gas_lift_method  VARCHAR2 default NULL)
RETURN NUMBER;

--

FUNCTION getCurveRate(
   p_object_id well.object_id%TYPE,
   p_daytime         DATE,
   p_phase       VARCHAR2,
   p_curve_purpose   VARCHAR2,
   p_choke_size      NUMBER,
   p_wh_press      NUMBER,
   p_wh_temp       NUMBER,
   p_bh_press      NUMBER,
   p_annulus_press   NUMBER,
   p_wh_usc_press    NUMBER,
   p_wh_dsc_press    NUMBER,
   p_bs_w            NUMBER,
   p_dh_pump_rpm     NUMBER,
   p_gl_choke        NUMBER,
   p_gl_press        NUMBER,
   p_gl_rate         NUMBER,
   p_gl_diff_press   NUMBER DEFAULT 0,
   p_avg_flow_mass   NUMBER DEFAULT 0,
   p_phase_current   NUMBER,
   p_ac_frequency    NUMBER,
   p_intake_press    NUMBER,
   p_mpm_oil_rate	 NUMBER,
   p_mpm_gas_rate	 NUMBER,
   p_mpm_water_rate	 NUMBER,
   p_mpm_cond_rate	 NUMBER,
   p_avg_dh_pump_power NUMBER,
   p_avg_dp_venturi  NUMBER,
   p_pressure_zone   VARCHAR2 DEFAULT 'NORMAL',
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION getOilStdRateDay(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE,
   p_calc_method VARCHAR2 DEFAULT NULL ,
   p_decline_flag VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION getGasStdRateDay(
   p_object_id well.object_id%TYPE,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL,
   p_decline_flag VARCHAR2 DEFAULT NULL,
   p_deduct_co2_flag VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION getWatStdRateDay(
   p_object_id well.object_id%TYPE,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL,
   p_decline_flag VARCHAR2 DEFAULT NULL )
RETURN NUMBER;

--

FUNCTION getCondStdRateDay(
   p_object_id well.object_id%TYPE,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL,
   p_decline_flag VARCHAR2 DEFAULT NULL )
RETURN NUMBER;

--

FUNCTION getInjectedStdRateDay(
   p_object_id well.object_id%TYPE,
   p_inj_type    VARCHAR2,
   p_daytime     DATE,
   p_calc_inj_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION getDiluentStdRateDay(
   p_object_id       VARCHAR2,
   p_daytime         DATE,
   p_diluent_method  VARCHAR2 DEFAULT NULL )
RETURN NUMBER;

--

FUNCTION getCO2StdRateDay(p_object_id   well.object_id%TYPE,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL,
   p_decline_flag VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION findOilStdDensity(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL )
RETURN NUMBER;

--

FUNCTION findGasStdDensity(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL )
RETURN NUMBER;

--

FUNCTION findWatStdDensity(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL )
RETURN NUMBER;

--

FUNCTION findOilMassDay(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL )
RETURN NUMBER;

--

FUNCTION findGasMassDay (
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL )
RETURN NUMBER;

--

FUNCTION findWaterMassDay(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL )
RETURN NUMBER;

--

FUNCTION findCondMassDay(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL )
RETURN NUMBER;

--

FUNCTION getOilStdVolSubDay(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2)
RETURN NUMBER;

--

FUNCTION getGasStdVolSubDay(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2)
RETURN NUMBER;

--

FUNCTION getWatStdVolSubDay(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2)
RETURN NUMBER;

--

FUNCTION getCondStdVolSubDay(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2)
RETURN NUMBER;

--

FUNCTION getDiluentStdVolSubDay(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2)
RETURN NUMBER;

--

FUNCTION getGasLiftStdVolSubDay(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2)
RETURN NUMBER;

--

FUNCTION findWaterCutPct(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL,
   p_decline_flag VARCHAR2 DEFAULT NULL,
   p_class_name VARCHAR2 DEFAULT NULL,
   p_result_no NUMBER DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION findCondGasRatio(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL,
   p_decline_flag VARCHAR2 DEFAULT NULL,
   p_class_name VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION findSand(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL )
RETURN NUMBER;

--

FUNCTION findGasOilRatio(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL,
   p_decline_flag VARCHAR2 DEFAULT NULL,
   p_class_name VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION findWetDryFactor(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL )
RETURN NUMBER;

--

FUNCTION getGrsLoadOilStdRateDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;

--

FUNCTION getNetLoadOilStdRateDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE,
   p_today       DATE DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION getLastNotNullInjRate(
   p_object_id well.object_id%TYPE,
   p_daytime   DATE,
   p_inj_type    VARCHAR2)
RETURN NUMBER;

--

FUNCTION getInjectedStdVolume(
   p_object_id well.object_id%TYPE,
   p_class_name VARCHAR2,
   p_daytime     DATE
  )
RETURN NUMBER;

--

FUNCTION getInjectedStdDailyRate(
   p_object_id well.object_id%TYPE,
   p_class_name    VARCHAR2,
   p_daytime DATE)
RETURN NUMBER;

--

FUNCTION getProducedStdVolume(
   p_object_id well.object_id%TYPE,
   p_class_name VARCHAR2,
   p_daytime     DATE
  )
RETURN NUMBER;

--

FUNCTION getProducedStdDailyRate(
   p_object_id well.object_id%TYPE,
   p_class_name    VARCHAR2,
   p_daytime DATE)
RETURN NUMBER;

--

FUNCTION getLastNotNullClosingValueDate(
   p_object_id well.object_id%TYPE,
   p_class_name    VARCHAR2,
   p_daytime DATE)
RETURN DATE;

--

FUNCTION getGrsLoadOilMassDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;

--

FUNCTION getNetLoadOilMassDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;

--

FUNCTION findWaterGasRatio(p_object_id    VARCHAR2,
   p_daytime      DATE,
   p_calc_method  VARCHAR2 DEFAULT NULL,
   p_decline_flag VARCHAR2 DEFAULT NULL,
   p_class_name VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION findWaterOilRatio(p_object_id    VARCHAR2,
   p_daytime      DATE,
   p_calc_method  VARCHAR2 DEFAULT NULL,
   p_decline_flag VARCHAR2 DEFAULT NULL,
   p_class_name VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION declineResult(p_object_id    VARCHAR2,
   p_daytime      DATE,
   p_from_date    DATE,
   p_phase        VARCHAR2,
   p_value        VARCHAR2)
RETURN NUMBER;

--

FUNCTION sumTruckedNetOilFromWell(p_object_id    VARCHAR2,
   p_daytime      DATE)
RETURN NUMBER;

--

FUNCTION sumTruckedWaterFromWell(p_object_id    VARCHAR2,
   p_daytime      DATE)
RETURN NUMBER;

--

FUNCTION findBSWTruck(
  p_object_id     VARCHAR2,
  p_daytime            DATE)
RETURN NUMBER;

--

FUNCTION findGCV(
  p_object_id well.object_id%TYPE,
  p_daytime      DATE,
  p_method       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION getGasEnergyDay(
  p_object_id    well.object_id%TYPE,
  p_daytime      DATE,
  p_method       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION findGasWaterRatio(
   p_object_id    VARCHAR2,
   p_daytime      DATE,
   p_calc_method  VARCHAR2 DEFAULT NULL,
   p_decline_flag VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION findDryWetFactor(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL )
RETURN NUMBER;

--

FUNCTION getInjectedMassStdRateDay (
         p_object_id   well.object_id%TYPE,
         p_inj_type    VARCHAR2,
         p_daytime     DATE,
         p_calc_inj_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION getLoadWaterStdRateDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE,
   p_today       DATE DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION findAvgPrevMthBswTruck(
   p_object_id VARCHAR2,
   p_daytime DATE)
RETURN NUMBER;

--

FUNCTION getMeterMethod(
   p_object_id well.object_id%TYPE,
   p_daytime DATE,
   p_meter_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION findFuelFlareVent(
         p_object_id well.object_id%TYPE,
         p_daytime DATE,
         p_ffv_type VARCHAR2)
RETURN NUMBER;

--

FUNCTION sumFuelFlareVent(
         p_object_id well.object_id%TYPE,
         p_daytime DATE,
         p_ffv_type VARCHAR2)
RETURN NUMBER;

--

FUNCTION findSeasonalWell(
         p_object_id well.object_id%TYPE,
         p_daytime DATE,
         p_ffv_type VARCHAR2)
RETURN NUMBER;

--
FUNCTION getOilStdRateEvent(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION getGasStdRateEvent(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION getWatStdRateEvent(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION getCondStdRateEvent(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION findHCMassDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER;

--

FUNCTION findHCMassSubDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER;

--
END EcBp_Well_Theoretical;