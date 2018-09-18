CREATE OR REPLACE PACKAGE EcBp_Flowline_Theoretical IS

/****************************************************************
** Package        :  EcBp_Flowline_Theoretical, header part
**
** $Revision: 1.11 $
**
** Purpose        :  Calculates theoretical flowline values (rates etc)
**
** Documentation  :  www.energy-components.com
**
** Created  :
**
** Modification history:
**
** Date     Whom     Change description:
** ------   -----    --------------------------------------
** 14.04.14 leongwen ECPD-22866: Applied the calculation methods for multiple phases Flowline Performance Curve based on the similar logic from Well Performance Curve.
** 27.09.16 keskaash ECPD-35756: Added function getSubseaWellMassRateDay and findHCMassDay
*****************************************************************/

FUNCTION getCurveRate(
  p_object_id       flowline.object_id%TYPE,
  p_daytime         DATE,
  p_phase           VARCHAR2,
  p_curve_purpose   VARCHAR2,
  p_choke_size      NUMBER,
  p_flwl_press      NUMBER,
  p_flwl_temp       NUMBER,
  p_flwl_usc_press  NUMBER,
  p_flwl_usc_temp   NUMBER,
  p_flwl_dsc_press  NUMBER,
  p_flwl_dsc_temp   NUMBER,
  p_mpm_oil_rate    NUMBER,
  p_mpm_gas_rate    NUMBER,
  p_mpm_water_rate  NUMBER,
  p_mpm_cond_rate   NUMBER,
  p_pressure_zone   VARCHAR2 DEFAULT 'NORMAL',
  p_calc_method     VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION getOilStdRateDay(
  p_object_id   flowline.object_id%TYPE,
  p_daytime     DATE,
  p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION getGasLiftStdRateDay(
   p_object_id        flowline.object_id%TYPE,
   p_daytime          DATE,
   p_gas_lift_method  VARCHAR2 default NULL)
RETURN NUMBER;

--

FUNCTION getGasStdRateDay(
  p_object_id   flowline.object_id%TYPE,
  p_daytime     DATE,
  p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION getWatStdRateDay(
  p_object_id   flowline.object_id%TYPE,
  p_daytime     DATE,
  p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION getCondStdRateDay(
  p_object_id   flowline.object_id%TYPE,
  p_daytime     DATE,
  p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION getInjectedStdRateDay(
  p_object_id        flowline.object_id%TYPE,
  p_inj_type         VARCHAR2,
  p_daytime          DATE,
  p_calc_inj_method  VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION findOilMassDay(
  p_object_id     flowline.object_id%TYPE,
  p_daytime       DATE,
  p_calc_method   VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION findGasMassDay(
  p_object_id    flowline.object_id%TYPE,
  p_daytime      DATE,
  p_calc_method  VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION findWaterMassDay(
  p_object_id     flowline.object_id%TYPE,
  p_daytime       DATE,
  p_calc_method   VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION findCondMassDay(
  p_object_id    flowline.object_id%TYPE,
  p_daytime      DATE,
  p_calc_method  VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION findHCMassDay(
  p_object_id    flowline.object_id%TYPE,
  p_daytime      DATE,
  p_calc_method  VARCHAR2 DEFAULT NULL)
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

FUNCTION findWaterCutPct(
  p_object_id   VARCHAR2,
  p_daytime     DATE,
  p_calc_method VARCHAR2 DEFAULT NULL,
  p_class_name VARCHAR2 DEFAULT NULL,
  p_result_no NUMBER DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION findCondGasRatio(
  p_object_id   VARCHAR2,
  p_daytime     DATE,
  p_calc_method VARCHAR2 DEFAULT NULL,
  p_class_name VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION findGasOilRatio(
  p_object_id   VARCHAR2,
  p_daytime     DATE,
  p_calc_method VARCHAR2 DEFAULT NULL,
  p_class_name VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION findWaterGasRatio(
  p_object_id     VARCHAR2,
  p_daytime       DATE,
  p_calc_method   VARCHAR2 DEFAULT NULL,
  p_class_name    VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--

FUNCTION findWetDryFactor(
  p_object_id   VARCHAR2,
  p_daytime     DATE,
  p_calc_method VARCHAR2 DEFAULT NULL )
RETURN NUMBER;

--

FUNCTION getAllocCondVolDay(
  p_flowline_id  FLOWLINE.OBJECT_ID%TYPE,
  p_daytime DATE)
RETURN NUMBER;

--

FUNCTION getAllocGasVolDay(
  p_flowline_id  FLOWLINE.OBJECT_ID%TYPE,
  p_daytime DATE)
 RETURN NUMBER;

--

FUNCTION getAllocOilVolDay(
  p_flowline_id  FLOWLINE.OBJECT_ID%TYPE,
  p_daytime DATE)
RETURN NUMBER;

--

FUNCTION getAllocWaterVolDay(
  p_flowline_id  FLOWLINE.OBJECT_ID%TYPE,
  p_daytime DATE)
RETURN NUMBER;

FUNCTION getSubseaWellMassRateDay(
   p_object_id   FLOWLINE.OBJECT_ID%TYPE,
   p_daytime     DATE,
   p_phase       VARCHAR2)
RETURN NUMBER;

END EcBp_Flowline_Theoretical;