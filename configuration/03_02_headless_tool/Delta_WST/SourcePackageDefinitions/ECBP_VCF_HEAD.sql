CREATE OR REPLACE PACKAGE EcBp_VCF IS

/****************************************************************
** Package        :  EcBp_VCF, header part
** Calcuates API gravity and volume corection factors (VCF)
** Modification history:
**
**  Date        Whom      Change description:
** ----------  --------  --------------------------------------
** 07.11.2012 rajarsar  ECPD-19864: Modified the function of calcAPIGravityObs, calcAPIGravityCorr and calcDensityCorr.
**                                  Added the new functions of calcDensityCorr_SI, calcVCFobsDensity_SI and calcVCFstdDensity_SI.
** 22.03.2013 kumarsur  ECPD-22598: Added calcDiluentConcentration(), calcShrinkageFactor() and calcAPIBlendShrinkage().
** 19.02.2016 abdulmaw  ECPD-28016: Modified calcVCFobsAPI, calcVCFobsDensity_SI,	calcVCFstdAPI, calcVCFstdDensity,	calcVCFstdDensity_SI.
                                    Added new function convertPressAPI, calcTempIPTS68
*****************************************************************/


FUNCTION calcAPIGravityObs(
   p_API_Gravity  NUMBER,
   p_Temp_Obs     NUMBER,
   p_decimals     NUMBER DEFAULT 5)
RETURN NUMBER;

FUNCTION calcAPIGravityCorr(
   p_API_Gravity_obs  NUMBER,
   p_Temp_Obs         NUMBER,
   p_Press_Obs        NUMBER DEFAULT NULL,
   p_daytime          DATE DEFAULT NULL,
   p_decimals         NUMBER DEFAULT 5)
RETURN NUMBER;

FUNCTION calcDensityCorr(
   p_Density_obs  NUMBER,
   p_Temp_Obs     NUMBER,
   p_Press_Obs    NUMBER DEFAULT NULL,
   p_daytime      DATE DEFAULT NULL,
   p_decimals     NUMBER DEFAULT 5)
RETURN NUMBER;

FUNCTION calcDensityCorr_SI(
   p_Density_obs  NUMBER,
   p_Temp_Obs     NUMBER,
   p_Press_Obs    NUMBER DEFAULT NULL,
   p_daytime      DATE DEFAULT NULL,
   p_Temp_Base    NUMBER DEFAULT 15,
   p_decimals     NUMBER DEFAULT 5)
RETURN NUMBER;

FUNCTION calcVCFobsAPI(
   p_API_Gravity_obs  NUMBER,
   p_Temp_Obs         NUMBER,
   p_Press_Obs        NUMBER DEFAULT NULL,
   p_daytime          DATE DEFAULT NULL,
   p_decimals         NUMBER DEFAULT 5)
RETURN NUMBER;

FUNCTION calcVCFstdAPI(
   p_API_Gravity_std  NUMBER,
   p_Temp_Obs         NUMBER,
   p_Press_Obs        NUMBER DEFAULT NULL,
   p_daytime          DATE DEFAULT NULL,
   p_decimals         NUMBER DEFAULT 5)
RETURN NUMBER;

FUNCTION calcVCFstdDensity(
   p_Density_std  NUMBER,
   p_Temp_Obs     NUMBER,
   p_Press_Obs    NUMBER DEFAULT NULL,
   p_daytime      DATE DEFAULT NULL,
   p_decimals     NUMBER DEFAULT 5)
RETURN NUMBER;

FUNCTION calcVCFobsDensity_SI(
   p_Density_obs      NUMBER,
   p_Temp_Obs         NUMBER,
   p_Press_Obs        NUMBER DEFAULT NULL,
   p_daytime          DATE DEFAULT NULL,
   p_Temp_Base        NUMBER DEFAULT 15,
   p_decimals         NUMBER DEFAULT 5)
RETURN NUMBER;

FUNCTION calcVCFstdDensity_SI(
   p_Density_Std      NUMBER,
   p_Temp_Obs         NUMBER,
   p_Press_Obs        NUMBER DEFAULT NULL,
   p_daytime          DATE DEFAULT NULL,
   p_Temp_Base        NUMBER DEFAULT 15,
   p_decimals         NUMBER DEFAULT 5)
RETURN NUMBER;

FUNCTION calcDeltaTempIPTS68(
   p_Temp_Obs     NUMBER)
RETURN NUMBER;

FUNCTION getAPIFromDensity(
   p_Density NUMBER)
RETURN NUMBER;

FUNCTION getDensityFromAPI(
   p_API NUMBER)
RETURN NUMBER;

FUNCTION calcDiluentConcentration(
   p_object_id stream.object_id%TYPE,
   p_daytime DATE)
RETURN NUMBER;

FUNCTION calcShrinkageFactor(
   p_object_id stream.object_id%TYPE,
   p_daytime DATE)
RETURN NUMBER;

FUNCTION calcAPIBlendShrinkage(
   p_object_id stream.object_id%TYPE,
   p_daytime DATE,
   p_return_char VARCHAR2)
RETURN NUMBER;

FUNCTION convertPressAPI(
   p_press_obs NUMBER,
   p_from_unit VARCHAR2,
   p_to_unit VARCHAR2)
RETURN NUMBER;

FUNCTION calcTempIPTS68(
   p_Temp_Obs     NUMBER)
RETURN NUMBER;

END EcBp_VCF;