CREATE OR REPLACE PACKAGE EcBp_VCF IS

/****************************************************************
** Package        :  EcBp_VCF, header part
** Calcuates API gravity and volume corection factors (VCF)
** Modification history:
**
**  Date        Whom      Change description:
** ----------  --------  --------------------------------------
** 07.11.2012 rajarsar  ECPD-20359: Modified the function of calcAPIGravityObs, calcAPIGravityCorr and calcDensityCorr.
**                                  Added the new functions of calcDensityCorr_SI, calcVCFobsDensity_SI and calcVCFstdDensity_SI.
** 22.03.2013 kumarsur  ECPD-23650: Added calcDiluentConcentration(), calcShrinkageFactor() and calcAPIBlendShrinkage().
*****************************************************************/


FUNCTION calcAPIGravityObs(
   p_API_Gravity  NUMBER,
   p_Temp_Obs     NUMBER,
   p_decimals     NUMBER DEFAULT 5)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcAPIGravityObs, WNDS, WNPS, RNPS);

FUNCTION calcAPIGravityCorr(
   p_API_Gravity_obs  NUMBER,
   p_Temp_Obs         NUMBER,
   p_decimals         NUMBER DEFAULT 5)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcAPIGravityCorr, WNDS, WNPS, RNPS);

FUNCTION calcDensityCorr(
   p_Density_obs  NUMBER,
   p_Temp_Obs     NUMBER,
   p_decimals     NUMBER DEFAULT 5)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcDensityCorr, WNDS, WNPS, RNPS);

FUNCTION calcDensityCorr_SI(
   p_Density_obs  NUMBER,
   p_Temp_Obs     NUMBER,
   p_Temp_Base    NUMBER DEFAULT 15,
   p_decimals     NUMBER DEFAULT 5)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcDensityCorr_SI, WNDS, WNPS, RNPS);

FUNCTION calcVCFobsAPI(
   p_API_Gravity_obs  NUMBER,
   p_Temp_Obs         NUMBER,
   p_decimals         NUMBER DEFAULT 5)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcVCFobsAPI, WNDS, WNPS, RNPS);

FUNCTION calcVCFstdAPI(
   p_API_Gravity_std  NUMBER,
   p_Temp_Obs         NUMBER,
   p_decimals         NUMBER DEFAULT 5)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcVCFstdAPI, WNDS, WNPS, RNPS);

FUNCTION calcVCFstdDensity(
   p_Density_std  NUMBER,
   p_Temp_Obs     NUMBER,
   p_decimals     NUMBER DEFAULT 5)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcVCFstdDensity, WNDS, WNPS, RNPS);

FUNCTION calcVCFobsDensity_SI(
   p_Density_obs      NUMBER,
   p_Temp_Obs         NUMBER,
   p_Temp_Base        NUMBER DEFAULT 15,
   p_decimals         NUMBER DEFAULT 5)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcVCFobsDensity_SI, WNDS, WNPS, RNPS);

FUNCTION calcVCFstdDensity_SI(
   p_Density_Std      NUMBER,
   p_Temp_Obs         NUMBER,
   p_Temp_Base        NUMBER DEFAULT 15,
   p_decimals         NUMBER DEFAULT 5)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcVCFstdDensity_SI, WNDS, WNPS, RNPS);

FUNCTION calcDeltaTempIPTS68(
   p_Temp_Obs     NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcDeltaTempIPTS68, WNDS, WNPS, RNPS);

FUNCTION getAPIFromDensity(p_Density NUMBER) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getAPIFromDensity ,RNPS, WNPS,WNDS);

FUNCTION getDensityFromAPI(p_API NUMBER) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getDensityFromAPI ,RNPS, WNPS,WNDS);

FUNCTION calcDiluentConcentration(p_object_id stream.object_id%TYPE,
                                  p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcDiluentConcentration ,RNPS, WNPS,WNDS);

FUNCTION calcShrinkageFactor(p_object_id stream.object_id%TYPE,
                             p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcShrinkageFactor ,RNPS, WNPS,WNDS);

FUNCTION calcAPIBlendShrinkage(p_object_id stream.object_id%TYPE,
                               p_daytime DATE,
                               p_return_char VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcAPIBlendShrinkage ,RNPS, WNPS,WNDS);


END EcBp_VCF;