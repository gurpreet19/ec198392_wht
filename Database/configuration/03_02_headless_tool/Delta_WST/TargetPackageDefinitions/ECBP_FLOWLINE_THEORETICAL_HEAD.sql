CREATE OR REPLACE PACKAGE EcBp_Flowline_Theoretical IS

/****************************************************************
** Package        :  EcBp_Flowline_Theoretical, header part
**
** $Revision: 1.8.2.1 $
**
** Purpose        :  Calculates theoretical flowline values (rates etc)
**
** Documentation  :  www.energy-components.com
**
** Created  :
**
** Modification history:
**
** Date     Whom  Change description:
** ------   ----- --------------------------------------

*****************************************************************/

FUNCTION getGasLiftStdRateDay(
   p_object_id        flowline.object_id%TYPE,
   p_daytime          DATE,
   p_gas_lift_method  VARCHAR2 default NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGasLiftStdRateDay, WNDS, WNPS, RNPS);

FUNCTION getCurveRate(
	p_object_id  flowline.object_id%TYPE,
    p_daytime         DATE,
    p_phase           VARCHAR2,
    p_curve_purpose   VARCHAR2,
    p_choke_size      NUMBER,
	p_flwl_press      NUMBER,
	p_flwl_temp       NUMBER,
	p_flwl_usc_temp   NUMBER,
	p_flwl_usc_press  NUMBER,
	p_flwl_dsc_press  NUMBER,
	p_flwl_dsc_temp   NUMBER,
	p_mpm_oil_rate    NUMBER,
	p_mpm_gas_rate    NUMBER,
	p_mpm_water_rate  NUMBER,
	p_mpm_cond_rate  NUMBER,
--                      p_gl_rate         NUMBER,
    p_pressure_zone   VARCHAR2 DEFAULT 'NORMAL')
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getCurveRate, WNDS, WNPS, RNPS);

--

FUNCTION getOilStdRateDay(
   p_object_id flowline.object_id%TYPE,
   p_daytime  DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)/*  ,
   p_decline_flag VARCHAR2 DEFAULT NULL) */
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getOilStdRateDay, WNDS, WNPS, RNPS);

--

FUNCTION getGasStdRateDay(
   p_object_id flowline.object_id%TYPE,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)/* ,
   p_decline_flag VARCHAR2 DEFAULT NULL ) */
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGasStdRateDay, WNDS, WNPS, RNPS);

--

FUNCTION getWatStdRateDay(
   p_object_id flowline.object_id%TYPE,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)/* ,
   p_decline_flag VARCHAR2 DEFAULT NULL ) */
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getWatStdRateDay, WNDS, WNPS, RNPS);

--

FUNCTION getCondStdRateDay(
   p_object_id flowline.object_id%TYPE,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)/* ,
   p_decline_flag VARCHAR2 DEFAULT NULL ) */
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getCondStdRateDay, WNDS,WNPS, RNPS);

--

FUNCTION getInjectedStdRateDay(
   p_object_id   flowline.object_id%TYPE,
   p_inj_type    VARCHAR2,
   p_daytime     DATE,
   p_calc_inj_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getInjectedStdRateDay, WNDS, WNPS, RNPS);

--

FUNCTION findOilMassDay(
   p_object_id   flowline.object_id%TYPE,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findOilMassDay, WNDS, WNPS, RNPS);

--

FUNCTION findGasMassDay(
   p_object_id flowline.object_id%TYPE,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findGasMassDay, WNDS, WNPS, RNPS);

--

FUNCTION findWaterMassDay(
   p_object_id flowline.object_id%TYPE,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findWaterMassDay, WNDS, WNPS, RNPS);

--

FUNCTION findCondMassDay(
   p_object_id flowline.object_id%TYPE,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findCondMassDay, WNDS, WNPS, RNPS);

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

FUNCTION findWaterCutPct(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)/* ,
   p_decline_flag VARCHAR2 DEFAULT NULL) */
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findWaterCutPct, WNDS,WNPS, RNPS);

--

FUNCTION findCondGasRatio(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)/* ,
   p_decline_flag VARCHAR2 DEFAULT NULL)    */
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findCondGasRatio, WNDS,WNPS, RNPS);

--

FUNCTION findGasOilRatio(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_calc_method VARCHAR2 DEFAULT NULL)/* ,
   p_decline_flag VARCHAR2 DEFAULT NULL ) */
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

END EcBp_Flowline_Theoretical;
