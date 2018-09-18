CREATE OR REPLACE PACKAGE Ue_Well_Theoretical IS

/****************************************************************
** Package        :  Ue_Well_Theoretical, header part
*
** Version  Date      Whom      Change description:
** -------  ------    -----     -----------------------------------
**          22.11.07  Yoon Oon  ECPD-6635: Added new functions getDiluentStdRateDay, getGasLiftStdRateDay
**          07.01.08  Kenneth
**                    Masamba   ECPD-6861: Added new functions findWaterCutPct, findCondGasRatio, findGasOilRatio, findSand, findWetDryFactor
**          04.03.08  oonnnng   ECPD-7593: Add new function findWaterGasRatio().
**          17.04.08  sharawan  ECPD-8222: Add new UE functions for sub daily methods
**                              (getOilStdVolSubDay, getGasStdVolSubDay, getWatStdVolSubDay, getCondStdVolSubDay, getGasLiftStdVolSubDay, getDiluentStdVolSubDay).
**          18.08.08  rajarsar  ECPD-9038: Added new function getCO2StdRateDay().
**          19.01.10  aliassit  ECPD-13264: Added new function getGasEnergyDay() and findGCV()
**          28.01.10  madondin  ECPD-13375: WELL - Added USER_EXIT to function findOilStdDensity, findGasStdDensity and findWatStdDensity
**          15.03.10  leongsei  ECPD-13916: Added function findGasWaterRatio
**          18.03.10  aliassit  ECPD-14146: Added function findDryWetFactor
**          26.10-10  Leongwen  ECPD-15122 PT well fluid rate estimation should also work for user exit methods
**          16.07.12  Leongwen  ECPD-21376 Added FUNCTION getInjectedMassStdRateDay()
** 			02.10.13  abdulmaw  ECPD-24427: Added new function getMeterMethod.
** 			08.10.13  abdulmaw  ECPD-24390: Added new function findFuelFlareVent to support fuel, flare and vent in well.
**	 		08.01.2015 dhavaalo ECPD-25537: Added new function getOilStdRateEvent,getGasStdRateEvent,getWatStdRateEvent and getCondStdRateEvent
*****************************************************************/

FUNCTION getOilStdRateDay(
   p_object_id well.object_id%TYPE,
   p_daytime   DATE,
   p_result_no NUMBER DEFAULT 0)
RETURN NUMBER;


FUNCTION getGasStdRateDay(
   p_object_id well.object_id%TYPE,
   p_daytime   DATE,
   p_result_no NUMBER DEFAULT 0)
RETURN NUMBER;


FUNCTION getWatStdRateDay(
   p_object_id well.object_id%TYPE,
   p_daytime   DATE,
   p_result_no NUMBER DEFAULT 0)
RETURN NUMBER;


FUNCTION getCondStdRateDay(
   p_object_id well.object_id%TYPE,
   p_daytime   DATE,
   p_result_no NUMBER DEFAULT 0)
RETURN NUMBER;


FUNCTION getInjectedStdRateDay(
   p_object_id well.object_id%TYPE,
   p_inj_type VARCHAR2,
   p_daytime     DATE)
RETURN NUMBER;


FUNCTION findOilMassDay(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION findGasMassDay(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION findWaterMassDay(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION findCondMassDay(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION getDiluentStdRateDay(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION getGasLiftStdRateDay(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION findWaterCutPct(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION findCondGasRatio(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION findGasOilRatio(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION findWaterOilRatio(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION findSand(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION findWetDryFactor(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION findWaterGasRatio(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER;


FUNCTION getOilStdVolSubDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;


FUNCTION getGasStdVolSubDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;


FUNCTION getWatStdVolSubDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;


FUNCTION getCondStdVolSubDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;


FUNCTION getDiluentStdVolSubDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;


FUNCTION getGasLiftStdVolSubDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;


FUNCTION declineResult(p_object_id    VARCHAR2,
   p_daytime      DATE,
   p_from_date    DATE,
   p_phase        VARCHAR2,
   p_value        VARCHAR2)
RETURN NUMBER;


FUNCTION getCO2StdRateDay(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION findGCV(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION getGasEnergyDay(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION findOilStdDensity(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION findGasStdDensity(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION findWatStdDensity(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;


FUNCTION findGasWaterRatio(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER;

FUNCTION findDryWetFactor(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER;

FUNCTION getInjectedMassStdRateDay(
   p_object_id   well.object_id%TYPE,
   p_inj_type VARCHAR2,
   p_daytime     DATE )
RETURN NUMBER;

FUNCTION getMeterMethod(
   p_object_id well.object_id%TYPE,
   p_daytime DATE)
RETURN NUMBER;

FUNCTION findFuelFlareVent(
         p_object_id well.object_id%TYPE,
         p_daytime DATE,
         p_ffv_type VARCHAR2)
RETURN NUMBER;

FUNCTION getOilStdRateEvent(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION getGasStdRateEvent(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION getWatStdRateEvent(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION getCondStdRateEvent(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

END Ue_Well_Theoretical;