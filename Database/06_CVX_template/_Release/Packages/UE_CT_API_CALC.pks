CREATE OR REPLACE PACKAGE Ue_CT_API_Calc IS

/****************************************************************
** Package        :  Ue_CT_API_Calc, header part
** Calcuates various API gravity and volume corection factors (VCF)
** based on the Manual of Petroleum Measurement Standards Chapter 11
**  May 2004 addition
*
*****************************************************************/


FUNCTION calcAPIGravityObs(
   p_API_Gravity  NUMBER,
   p_Temp_Obs     NUMBER,
   p_Rounding         NUMBER DEFAULT 1)
RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (calcAPIGravityObs, WNDS, WNPS, RNPS);

FUNCTION calcAPIGravityCorr(
   p_API_Gravity_obs  NUMBER,
   p_Temp_Obs         NUMBER,
   p_Rounding         NUMBER DEFAULT 1,
   p_Glass_Hydrometer VARCHAR2 DEFAULT 'YES')
RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (calcAPIGravityCorr, WNDS, WNPS, RNPS);

FUNCTION calcVCFobsAPI(
   p_API_Gravity_obs  NUMBER,
   p_Temp_Obs     NUMBER,
   p_Glass_Hydrometer VARCHAR2 DEFAULT 'YES',
   p_Measurement_type VARCHAR2 DEFAULT 'STREAM')
RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (calcVCFobsAPI, WNDS, WNPS, RNPS);

FUNCTION calcVCFstdAPI(
   p_API_Gravity_std  NUMBER,
   p_Temp_Obs     NUMBER,
   p_Measurement_type VARCHAR2 DEFAULT 'STREAM')
RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (calcVCFstdAPI, WNDS, WNPS, RNPS);

FUNCTION calcDeltaTempIPTS68(
   p_Temp_Obs     NUMBER)
RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (calcDeltaTempIPTS68, WNDS, WNPS, RNPS);

FUNCTION calcAPIGlassCorr(
   p_API_Gravity  NUMBER,
   p_Temp_Obs     NUMBER)
RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (calcAPIGlassCorr, WNDS, WNPS, RNPS);


END Ue_CT_API_Calc; 
/

