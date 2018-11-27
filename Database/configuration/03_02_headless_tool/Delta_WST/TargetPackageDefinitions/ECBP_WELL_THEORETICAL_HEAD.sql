CREATE OR REPLACE PACKAGE EcBp_Well_Theoretical IS

/****************************************************************
** Package        :  EcBp_Well_Theoretical, header part
**
** $Revision: 1.48.2.6 $
**
** Purpose        :  Calculates theoretical well values (rates etc)
**
** Documentation  :  www.energy-components.com
**
** Created  : 17.01.2000  Carl-Fredrik Sørensen
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
** 16.07.12 leongwen ECPD-21488: Added the function getInjectedMassStdRateDay()
** 17-10-12 kumarsur ECPD-22074: Modified findWaterCutPct ,findCondGasRatio, findGasOilRatio, findWaterGasRatio and findWaterOilRatio
** 28-06-13 musthram ECPD-24533: Modified function findWaterCutPct
** 22.11.13 kumarsur ECPD-26104: Modified getCurveRate added p_phase_current,p_ac_frequency and p_intake_press.
** 02.12.13 makkkkam ECPD-25991: Modified getCurveRate added p_mpm_oil_rate,p_mpm_gas_rate,p_mpm_water_rate and p_mpm_cond_rate.
** 14.01.15 dhavaalo ECPD-28604: Added new function getOilStdRateEvent,getGasStdRateEvent,getWatStdRateEvent and getCondStdRateEvent
*****************************************************************/

FUNCTION getGasLiftStdRateDay(
   p_object_id        well.object_id%TYPE,
   p_daytime          DATE,
   p_gas_lift_method  VARCHAR2 default NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGasLiftStdRateDay, WNDS, WNPS, RNPS);

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
   p_pressure_zone   VARCHAR2 DEFAULT 'NORMAL',
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getCurveRate, WNDS, WNPS, RNPS);

--

FUNCTION getOilStdRateDay(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE,
   p_calc_method VARCHAR2 DEFAULT NULL ,
   p_decline_flag VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getOilStdRateDay, WNDS, WNPS, RNPS);

--

FUNCTION getGasStdRateDay(
   p_object_id well.object_id%TYPE,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL,
   p_decline_flag VARCHAR2 DEFAULT NULL,
   p_deduct_co2_flag VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGasStdRateDay, WNDS, WNPS, RNPS);

--

FUNCTION getWatStdRateDay(
   p_object_id well.object_id%TYPE,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL,
   p_decline_flag VARCHAR2 DEFAULT NULL )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getWatStdRateDay, WNDS, WNPS, RNPS);

--

FUNCTION getCondStdRateDay(
   p_object_id well.object_id%TYPE,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL,
   p_decline_flag VARCHAR2 DEFAULT NULL )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getCondStdRateDay, WNDS,WNPS, RNPS);

--

FUNCTION getInjectedStdRateDay(
   p_object_id well.object_id%TYPE,
   p_inj_type    VARCHAR2,
   p_daytime     DATE,
   p_calc_inj_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getInjectedStdRateDay, WNDS,WNPS, RNPS);

--

FUNCTION getDiluentStdRateDay(
   p_object_id       VARCHAR2,
   p_daytime         DATE,
   p_diluent_method  VARCHAR2 DEFAULT NULL )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getDiluentStdRateDay, WNDS,WNPS, RNPS);

--

FUNCTION getCO2StdRateDay(p_object_id   well.object_id%TYPE,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL,
   p_decline_flag VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getCO2StdRateDay, WNDS,WNPS, RNPS);

--

FUNCTION findOilStdDensity(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findOilStdDensity, WNDS,WNPS, RNPS);

--

FUNCTION findGasStdDensity(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findGasStdDensity, WNDS,WNPS, RNPS);

--

FUNCTION findWatStdDensity(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findWatStdDensity, WNDS,WNPS, RNPS);

--

FUNCTION findOilMassDay(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findOilMassDay, WNDS,WNPS, RNPS);

--

FUNCTION findGasMassDay (
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findGasMassDay, WNDS,WNPS, RNPS);

--

FUNCTION findWaterMassDay(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findWaterMassDay, WNDS,WNPS, RNPS);

--

FUNCTION findCondMassDay(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findCondMassDay, WNDS,WNPS, RNPS);

--

FUNCTION getOilStdVolSubDay(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getOilStdVolSubDay, WNDS, WNPS, RNPS);

--

FUNCTION getGasStdVolSubDay(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGasStdVolSubDay, WNDS, WNPS, RNPS);

--

FUNCTION getWatStdVolSubDay(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getWatStdVolSubDay, WNDS, WNPS, RNPS);

--

FUNCTION getCondStdVolSubDay(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getCondStdVolSubDay, WNDS,WNPS, RNPS);

--

FUNCTION getDiluentStdVolSubDay(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getDiluentStdVolSubDay, WNDS,WNPS, RNPS);

--

FUNCTION getGasLiftStdVolSubDay(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGasLiftStdVolSubDay, WNDS,WNPS, RNPS);

--

FUNCTION findWaterCutPct(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL,
   p_decline_flag VARCHAR2 DEFAULT NULL,
   p_class_name VARCHAR2 DEFAULT NULL,
   p_result_no NUMBER DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findWaterCutPct, WNDS,WNPS, RNPS);

--

FUNCTION findCondGasRatio(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL,
   p_decline_flag VARCHAR2 DEFAULT NULL,
   p_class_name VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findCondGasRatio, WNDS,WNPS, RNPS);

--

FUNCTION findSand(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findSand, WNDS,WNPS, RNPS);

--

FUNCTION findGasOilRatio(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL,
   p_decline_flag VARCHAR2 DEFAULT NULL,
   p_class_name VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findGasOilRatio, WNDS,WNPS, RNPS);

--

FUNCTION findWetDryFactor(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findWetDryFactor, WNDS,WNPS, RNPS);

--

FUNCTION getGrsLoadOilStdRateDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGrsLoadOilStdRateDay, WNDS,WNPS, RNPS);

--

FUNCTION getNetLoadOilStdRateDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getNetLoadOilStdRateDay, WNDS,WNPS, RNPS);

--

FUNCTION getLastNotNullInjRate(
   p_object_id well.object_id%TYPE,
   p_daytime   DATE,
   p_inj_type    VARCHAR2)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getLastNotNullInjRate, WNDS, WNPS, RNPS);

--

FUNCTION getInjectedStdVolume(
   p_object_id well.object_id%TYPE,
   p_class_name VARCHAR2,
   p_daytime     DATE
  )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getInjectedStdVolume, WNDS,WNPS, RNPS);

--

FUNCTION getInjectedStdDailyRate(
   p_object_id well.object_id%TYPE,
   p_class_name    VARCHAR2,
   p_daytime DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getInjectedStdDailyRate, WNDS,WNPS, RNPS);

--

FUNCTION getProducedStdVolume(
   p_object_id well.object_id%TYPE,
   p_class_name VARCHAR2,
   p_daytime     DATE
  )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getProducedStdVolume, WNDS,WNPS, RNPS);

--

FUNCTION getProducedStdDailyRate(
   p_object_id well.object_id%TYPE,
   p_class_name    VARCHAR2,
   p_daytime DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getProducedStdDailyRate, WNDS,WNPS, RNPS);

--

FUNCTION getLastNotNullClosingValueDate(
   p_object_id well.object_id%TYPE,
   p_class_name    VARCHAR2,
   p_daytime DATE)
RETURN DATE;
PRAGMA RESTRICT_REFERENCES (getLastNotNullClosingValueDate, WNDS, WNPS, RNPS);

--

FUNCTION getGrsLoadOilMassDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGrsLoadOilMassDay, WNDS,WNPS, RNPS);

--

FUNCTION getNetLoadOilMassDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getNetLoadOilMassDay, WNDS,WNPS, RNPS);

--

FUNCTION findWaterGasRatio(p_object_id    VARCHAR2,
   p_daytime      DATE,
   p_calc_method  VARCHAR2 DEFAULT NULL,
   p_decline_flag VARCHAR2 DEFAULT NULL,
   p_class_name VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findWaterGasRatio, WNDS,WNPS, RNPS);

--

FUNCTION findWaterOilRatio(p_object_id    VARCHAR2,
   p_daytime      DATE,
   p_calc_method  VARCHAR2 DEFAULT NULL,
   p_decline_flag VARCHAR2 DEFAULT NULL,
   p_class_name VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findWaterOilRatio, WNDS,WNPS, RNPS);

--

FUNCTION declineResult(p_object_id    VARCHAR2,
   p_daytime      DATE,
   p_from_date    DATE,
   p_phase        VARCHAR2,
   p_value        VARCHAR2)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (declineResult, WNDS,WNPS, RNPS);

--

FUNCTION sumTruckedNetOilFromWell(p_object_id    VARCHAR2,
   p_daytime      DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (sumTruckedNetOilFromWell, WNDS,WNPS, RNPS);

--

FUNCTION sumTruckedWaterFromWell(p_object_id    VARCHAR2,
   p_daytime      DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (sumTruckedWaterFromWell, WNDS,WNPS, RNPS);

--

FUNCTION findBSWTruck(
  p_object_id     VARCHAR2,
  p_daytime            DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findBSWTruck, WNDS, WNPS, RNPS);

--

FUNCTION findGCV(
  p_object_id well.object_id%TYPE,
  p_daytime      DATE,
  p_method       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findGCV, WNDS,  WNPS, RNPS);

--

FUNCTION getGasEnergyDay(
  p_object_id    well.object_id%TYPE,
  p_daytime      DATE,
  p_method       VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGasEnergyDay, WNDS,  WNPS, RNPS);

--

FUNCTION findGasWaterRatio(
   p_object_id    VARCHAR2,
   p_daytime      DATE,
   p_calc_method  VARCHAR2 DEFAULT NULL,
   p_decline_flag VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findGasWaterRatio, WNDS,WNPS, RNPS);

--

FUNCTION findDryWetFactor(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findDryWetFactor, WNDS,WNPS, RNPS);

--

FUNCTION getInjectedMassStdRateDay (
         p_object_id   well.object_id%TYPE,
         p_inj_type    VARCHAR2,
         p_daytime     DATE,
         p_calc_inj_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--
FUNCTION getOilStdRateEvent(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getOilStdRateEvent, WNDS,WNPS, RNPS);

--

FUNCTION getGasStdRateEvent(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGasStdRateEvent, WNDS,WNPS, RNPS);

--

FUNCTION getWatStdRateEvent(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getWatStdRateEvent, WNDS,WNPS, RNPS);

--

FUNCTION getCondStdRateEvent(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getCondStdRateEvent, WNDS,WNPS, RNPS);

END EcBp_Well_Theoretical;
