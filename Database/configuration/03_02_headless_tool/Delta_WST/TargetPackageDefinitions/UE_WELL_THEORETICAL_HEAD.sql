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
**          16.07.12  Leongwen  ECPD-21488 Added FUNCTION getInjectedMassStdRateDay()
**	 		14.01.15 dhavaalo ECPD-25537: Added new function getOilStdRateEvent,getGasStdRateEvent,getWatStdRateEvent and getCondStdRateEvent
*****************************************************************/

FUNCTION getOilStdRateDay(
   p_object_id well.object_id%TYPE,
   p_daytime   DATE,
   p_result_no NUMBER DEFAULT 0)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getOilStdRateDay, WNDS, WNPS, RNPS);


FUNCTION getGasStdRateDay(
   p_object_id well.object_id%TYPE,
   p_daytime   DATE,
   p_result_no NUMBER DEFAULT 0)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGasStdRateDay, WNDS, WNPS, RNPS);


FUNCTION getWatStdRateDay(
   p_object_id well.object_id%TYPE,
   p_daytime   DATE,
   p_result_no NUMBER DEFAULT 0)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getWatStdRateDay, WNDS, WNPS, RNPS);


FUNCTION getCondStdRateDay(
   p_object_id well.object_id%TYPE,
   p_daytime   DATE,
   p_result_no NUMBER DEFAULT 0)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getCondStdRateDay, WNDS, WNPS, RNPS);


FUNCTION getInjectedStdRateDay(
   p_object_id well.object_id%TYPE,
   p_inj_type VARCHAR2,
   p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getInjectedStdRateDay, WNDS, WNPS, RNPS);


FUNCTION findOilMassDay(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findOilMassDay, WNDS, WNPS, RNPS);


FUNCTION findGasMassDay(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findGasMassDay, WNDS, WNPS, RNPS);


FUNCTION findWaterMassDay(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findWaterMassDay, WNDS, WNPS, RNPS);


FUNCTION findCondMassDay(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findCondMassDay, WNDS, WNPS, RNPS);


FUNCTION getDiluentStdRateDay(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getDiluentStdRateDay, WNDS, WNPS, RNPS);


FUNCTION getGasLiftStdRateDay(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGasLiftStdRateDay, WNDS, WNPS, RNPS);


FUNCTION findWaterCutPct(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findWaterCutPct, WNDS, WNPS, RNPS);


FUNCTION findCondGasRatio(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findCondGasRatio, WNDS, WNPS, RNPS);


FUNCTION findGasOilRatio(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findGasOilRatio, WNDS, WNPS, RNPS);


FUNCTION findWaterOilRatio(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findWaterOilRatio, WNDS, WNPS, RNPS);


FUNCTION findSand(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findSand, WNDS, WNPS, RNPS);


FUNCTION findWetDryFactor(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findWetDryFactor, WNDS, WNPS, RNPS);


FUNCTION findWaterGasRatio(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findWaterGasRatio, WNDS, WNPS, RNPS);


FUNCTION getOilStdVolSubDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getOilStdVolSubDay, WNDS, WNPS, RNPS);


FUNCTION getGasStdVolSubDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGasStdVolSubDay, WNDS, WNPS, RNPS);


FUNCTION getWatStdVolSubDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getWatStdVolSubDay, WNDS, WNPS, RNPS);


FUNCTION getCondStdVolSubDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getCondStdVolSubDay, WNDS, WNPS, RNPS);


FUNCTION getDiluentStdVolSubDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getDiluentStdVolSubDay, WNDS, WNPS, RNPS);


FUNCTION getGasLiftStdVolSubDay(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGasLiftStdVolSubDay, WNDS, WNPS, RNPS);


FUNCTION declineResult(p_object_id    VARCHAR2,
   p_daytime      DATE,
   p_from_date    DATE,
   p_phase        VARCHAR2,
   p_value        VARCHAR2)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (declineResult, WNDS,WNPS, RNPS);


FUNCTION getCO2StdRateDay(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getCO2StdRateDay, WNDS, WNPS, RNPS);


FUNCTION findGCV(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findGCV, WNDS, WNPS, RNPS);


FUNCTION getGasEnergyDay(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGasEnergyDay, WNDS, WNPS, RNPS);


FUNCTION findOilStdDensity(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findOilStdDensity, WNDS, WNPS, RNPS);


FUNCTION findGasStdDensity(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findGasStdDensity, WNDS, WNPS, RNPS);


FUNCTION findWatStdDensity(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findWatStdDensity, WNDS, WNPS, RNPS);


FUNCTION findGasWaterRatio(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findGasWaterRatio, WNDS, WNPS, RNPS);

FUNCTION findDryWetFactor(
   p_object_id   well.object_id%TYPE,
   p_daytime     DATE )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findDryWetFactor, WNDS, WNPS, RNPS);

FUNCTION getInjectedMassStdRateDay(
   p_object_id   well.object_id%TYPE,
   p_inj_type VARCHAR2,
   p_daytime     DATE )
RETURN NUMBER;

FUNCTION getOilStdRateEvent(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getOilStdRateEvent, WNDS, WNPS, RNPS);

FUNCTION getGasStdRateEvent(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGasStdRateEvent, WNDS, WNPS, RNPS);

FUNCTION getWatStdRateEvent(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getWatStdRateEvent, WNDS, WNPS, RNPS);

FUNCTION getCondStdRateEvent(
   p_object_id well.object_id%TYPE,
   p_daytime  DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getCondStdRateEvent, WNDS, WNPS, RNPS);

END Ue_Well_Theoretical;