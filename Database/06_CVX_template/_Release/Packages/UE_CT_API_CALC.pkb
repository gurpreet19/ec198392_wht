CREATE OR REPLACE PACKAGE BODY Ue_CT_API_Calc IS
/****************************************************************
** Package        :  Ue_CT_API_Calc, body part
**
** Calculates various API gravity and volume correction factors (VCF)
** based on the Manual of Petroleum Measurement Standards Chapter 11
**  May 2004 addition
** Includes API Table 6 adjustments based on the official API documentation
**
** Modification history:
**
** Version  Date          Who                  Change description:
** -------  ----------    ----                 --------------------------------------
**          May 2006      Mark Berkstresser    New - created calcAPIGravityObs
** V2       September 2007  Mark Berkstresser  Added additional functions and improved accuracy
** V2.1     November 2007  Mark Berkstresser   Corrected minor error in calcAPIGravityObs
**                                             Changed iteration process to a FOR LOOP
**  V2,2    December 2007  Mark Berkstresser   Added final rounding to results
**  V3      December 2010  Mark Berkstresser  Added API Glass Correction and refined rounding rules
**
*****************************************************************/

---------------------------------------------------------------------------------------------------
-- Function       : calcAPIGravityObs
-- Description    : Calculates what the observed API gravity would have been given the
--                  given the corrected API gravity and the sample temperature
--         NOTE this is the inverse of the normal calculation and is used in cases where
--              the original lab work is done at a temperature different than the sample temperature
--  INPUT Corrected API gravity at 60 degrees and original sample temperature
---------------------------------------------------------------------------------------------------
FUNCTION calcAPIGravityObs(
   p_API_Gravity  NUMBER,
   p_Temp_Obs     NUMBER,
   p_Rounding         NUMBER DEFAULT 1)
RETURN NUMBER
IS
   ln_Alpha_60    NUMBER;
   ln_Ctl         NUMBER;
   ln_Rho_60      NUMBER;
   ln_delta_Temp  NUMBER;
   ln_density_60  NUMBER;
   ln_density_obs NUMBER;
   ln_A           NUMBER;
   ln_RHO_Star    NUMBER;
   ln_result      NUMBER;
BEGIN

   -- Calculate density at 60 degrees from corrected API gravity
   ln_density_60 := 141.5 * 999.016/(131.5 + p_API_gravity);
   
   ln_A := 0.0137498 * 341.0957 / (2 * ln_density_60**2);

   ln_RHO_Star := ln_density_60 / (1+ ((exp(ln_A*(1+0.8*ln_A)) - 1)/(1+ln_a*(1+1.6*ln_a)*2)));

    ln_Alpha_60 := 341.0957 / (ln_RHO_Star**2);
 -- Convert the temperature to ITPS-68 basis
  ln_Delta_temp := UE_CT_API_Calc.calcDeltaTempIPTS68(p_temp_obs);
   
   ln_Ctl := exp(-1*ln_Alpha_60*ln_Delta_temp*(1 + 0.8*ln_Alpha_60*(ln_Delta_temp + 0.01374979)));
     
  -- Density at temperature the sample was taken at (tank or stream temperature)
   ln_density_obs := ln_density_60 * ln_Ctl;
   -- Calculate API gravity at observed temperature from density at observed temperature
  ln_result := round(((141.5 * 999.016 / ln_density_obs) - 131.5),p_rounding);
   
   RETURN ln_result;

END calcAPIGravityObs;

---------------------------------------------------------------------------------------------------
-- Function       : calcAPIGravityCorr
-- Description    : Calculates what the CORRECTED API gravity at 60 degrees F given the
--                  observed temperature and observed gravity
--                  This is done as a set of iterations until a certain delta is achieved
--         
---------------------------------------------------------------------------------------------------
FUNCTION calcAPIGravityCorr(
   p_API_Gravity_obs  NUMBER,
   p_Temp_Obs         NUMBER,
   p_Rounding         NUMBER DEFAULT 1,
   p_Glass_Hydrometer VARCHAR2 DEFAULT 'YES')
RETURN NUMBER
IS
   ln_API_gravity_obs NUMBER;
   ln_Alpha_60        NUMBER;
   ln_Ctl             NUMBER;
   ln_density_60      NUMBER;
   ln_density_obs     NUMBER;
   ln_density_delta   NUMBER;
   ln_result          NUMBER;
   ln_A               NUMBER;
   ln_RHO_Star        NUMBER;
   ln_Delta_Temp      NUMBER;
   ln_E_factor        NUMBER;
   ln_Dt_factor       NUMBER;
   ln_delta_density_60 NUMBER;
   ln_counter         NUMBER;
   
BEGIN

   -- Correct for Glass Hydrometer if necessary
   IF p_Glass_Hydrometer = 'YES' THEN
        ln_api_gravity_obs := UE_CT_API_CALC.calcAPIGlassCorr(p_API_Gravity_obs, p_Temp_Obs);
        ELSE
        ln_api_gravity_obs := p_API_Gravity_obs;
        END IF;
   -- Calculate density at observed condition from observed API gravity
   ln_density_obs := 141.5 * 999.016 /(131.5 + ln_API_gravity_obs);
   --  Use the observed density as the first guess for the corrected density
   ln_density_60 := ln_density_obs;
 -- Convert the temperature to ITPS-68 basis
   ln_Delta_temp := UE_CT_API_Calc.calcDeltaTempIPTS68(p_temp_obs);
   
   -- Loop through iterations until convergence is reached
  FOR ln_counter IN 1..10 LOOP
     -- Calculate the A factor
     ln_A := 0.0137498 * 341.0957 / (2 * ln_density_60**2);

     ln_RHO_Star := ln_density_60 * (1+ ((exp(ln_A*(1+0.8*ln_A)) - 1)/(1+ln_a*(1+1.6*ln_a)*2)));

     ln_Alpha_60 := 341.0957 / (ln_RHO_Star**2);
  
     -- Density at temperature the sample was taken at (tank or stream temperature)
     ln_Ctl := exp(-1*ln_Alpha_60*ln_Delta_temp*(1 + (0.8*ln_Alpha_60*(ln_Delta_temp + 0.01374979))));
     -- Calculate API gravity at observed temperature from density at observed temperature
     ln_density_Delta := (ln_density_obs / ln_Ctl) - ln_density_60;
     -- Exit when convergence is reached
     EXIT WHEN abs(ln_density_Delta) < 0.0000001;
  
     -- Estimate the amount of change in the density needed to get a good answer
     ln_E_factor := (ln_density_obs/ln_Ctl) - ln_density_60; --ln_density_Delta/ln_Ctl;
     ln_Dt_factor := 2 * ln_alpha_60 * (p_temp_obs - 60) *(1 + 1.6 * ln_alpha_60* (p_temp_obs - 60));
     ln_delta_density_60 := ln_E_factor / (1+ln_Dt_factor);
     -- Adjust the guessed density based on the above delta
     ln_density_60 := ln_density_60 +  ln_delta_density_60;
     END LOOP;
     -- Convert back to API units
  ln_result := round(((141.5 * 999.016 / ln_density_60) - 131.5),p_rounding);
  
  RETURN ln_result;

END calcAPIGravityCorr;


---------------------------------------------------------------------------------------------------
-- Function       : calcVCFobsAPI
-- Description    : Calculates the VCF for an observed API gravity given the
--                  observed temperature 
--                  This function can only be used when the temperature the sample is measured at
--                  is the same of the stream or tank temperature  
--
--    The following from return  API Table 6A
-- Ue_CT_API_Calc.calcVCFobsAPI(ue_CT_API_Calc.calcAPIGravityobs(95.6,120,10),120,'NO','TANK') VCF   
---------------------------------------------------------------------------------------------------

FUNCTION calcVCFobsAPI(
   p_API_Gravity_obs  NUMBER,
   p_Temp_Obs         NUMBER,
   p_Glass_Hydrometer VARCHAR2 DEFAULT 'YES',
   p_Measurement_type VARCHAR2 DEFAULT 'STREAM')
RETURN NUMBER
IS
   ln_API_gravity_obs NUMBER;
   ln_Alpha_60        NUMBER;
   ln_Ctl             NUMBER;
   ln_density_60      NUMBER;
   ln_density_obs     NUMBER;
   ln_density_delta   NUMBER;
   ln_result          NUMBER;
   ln_A               NUMBER;
   ln_RHO_Star        NUMBER;
   ln_Delta_Temp      NUMBER;
   ln_E_factor        NUMBER;
   ln_Dt_factor       NUMBER;
   ln_delta_density_60 NUMBER;
   ln_counter         NUMBER;
   
BEGIN
     -- Correct for Glass Hydrometer if necessary
   IF p_Glass_Hydrometer = 'YES' THEN
        ln_api_gravity_obs := UE_CT_API_CALC.calcAPIGlassCorr(p_API_Gravity_obs, p_Temp_Obs);
        ELSE
        ln_api_gravity_obs := p_API_Gravity_obs;
        END IF;
   -- Calculate density at observed condition from observed API gravity
   ln_density_obs := 141.5 * 999.016 /(131.5 + ln_API_gravity_obs);
   --  Use the observed density as the first guess for the corrected density
   ln_density_60 := ln_density_obs;
 -- Convert the temperature to ITPS-68 basis
   ln_Delta_temp := UE_CT_API_Calc.calcDeltaTempIPTS68(p_temp_obs);
   
   -- Loop through iterations until convergence is reached
  FOR ln_counter IN 1..10 LOOP
     -- Calculate the A factor
     ln_A := 0.0137498 * 341.0957 / (2 * ln_density_60**2);

     ln_RHO_Star := ln_density_60 * (1+ ((exp(ln_A*(1+0.8*ln_A)) - 1)/(1+ln_a*(1+1.6*ln_a)*2)));

     ln_Alpha_60 := 341.0957 / (ln_RHO_Star**2);
  
     -- Density at temperature the sample was taken at (tank or stream temperature)
     ln_Ctl := exp(-1*ln_Alpha_60*ln_Delta_temp*(1 + (0.8*ln_Alpha_60*(ln_Delta_temp + 0.01374979))));
     -- Calculate API gravity at observed temperature from density at observed temperature
     ln_density_Delta := (ln_density_obs / ln_Ctl) - ln_density_60;
     -- Exit when convergence is reached
     EXIT WHEN abs(ln_density_Delta) < 0.0000001;
  
     -- Estimate the amount of change in the density needed to get a good answer
     ln_E_factor := (ln_density_obs/ln_Ctl) - ln_density_60; --ln_density_Delta/ln_Ctl;
     ln_Dt_factor := 2 * ln_alpha_60 * (p_temp_obs - 60) *(1 + 1.6 * ln_alpha_60* (p_temp_obs - 60));
     ln_delta_density_60 := ln_E_factor / (1+ln_Dt_factor);
     -- Adjust the guessed density based on the above delta
     ln_density_60 := ln_density_60 +  ln_delta_density_60;
     END LOOP;
   
-- The API specification calls for Meter VCFs to be rounded to 4 places and tanks to 5 places
--  We will assume anything specified other than STREAM is rounded to 5 places.
   IF p_Measurement_type = 'STREAM' THEN
   ln_result := round(ln_ctl,4);
   ELSE
   ln_result := round(ln_ctl,5);
   END IF;

   RETURN ln_result;

END calcVCFobsAPI;


---------------------------------------------------------------------------------------------------
-- Function       : calcVCFstdAPI
-- Description    : Calculates the VCF for a standard API gravity given the
--                  observed temperature
--
--                  This function is typically used in conjunction with calcAPIGravityCorr to calculate the
--                   VCF when the sample is tested at a temperature different from the temperature
--                    of the tank or stream 
--
--         Ue_CT_API_Calc.calcVCFstdAPI(Ue_CT_API_Calc.calcAPIGravityCorr(56.2, 154.2,10,'NO'), 146.4,'TANK') VCF 
--         
---------------------------------------------------------------------------------------------------

FUNCTION calcVCFstdAPI(
   p_API_Gravity_std  NUMBER,
   p_Temp_Obs         NUMBER,
   p_Measurement_type VARCHAR2 DEFAULT 'STREAM')
RETURN NUMBER
IS
   ln_Alpha_60        NUMBER;
   ln_A               NUMBER;
   ln_Rho_star        NUMBER;
   ln_Ctl             NUMBER;
   ln_delta_Temp      NUMBER;
   ln_density_std     NUMBER;
   ln_result          NUMBER;
BEGIN
    -- Convert API gravity to density
 ln_density_std := 141.5*999.016/(131.5 + p_API_gravity_std);
 ln_A := 0.0137498 * 341.0957 / (2 * ln_density_std**2);
    ln_RHO_Star := ln_density_std * (1+ ((exp(ln_A*(1+0.8*ln_A)) - 1)/(1+ln_a*(1+1.6*ln_a)*2)));

    ln_Alpha_60 := 341.0957 / (ln_RHO_Star**2);
 -- Convert the temperature to ITPS-68 basis
 ln_Delta_temp := UE_CT_API_Calc.calcDeltaTempIPTS68(p_temp_obs);
   -- Temperature VCF factor
   ln_Ctl := exp(-1*ln_Alpha_60*ln_Delta_temp*(1 + (0.8*ln_Alpha_60*(ln_Delta_temp + 0.01374979))));
-- The API specification calls for Meter VCFs to be rounded to 4 places and tanks to 5 places
--  We will assume anything specified other than STREAM is rounded to 5 places.
   IF p_Measurement_type = 'STREAM' THEN
   ln_result := round(ln_ctl,4);
   ELSE
   ln_result := round(ln_ctl,5);
   END IF;

   RETURN ln_result;

END calcVCFstdAPI;

---------------------------------------------------------------------------------------------------
-- Function       : calcDeltaTempIPTS68
-- Description    : Calculates the delta temperature for API calculations based on
--                   the IPTS-68 standard
--         
---------------------------------------------------------------------------------------------------


FUNCTION calcDeltaTempIPTS68(
   p_Temp_Obs     NUMBER)
RETURN NUMBER
IS
   ln_Temp_IPTS_68    NUMBER;
   ln_temp_obs_C      NUMBER;
   ln_Temp_obs_scaled NUMBER;
   ln_Temp_IPTS_delta NUMBER;
   ln_delta_Temp      NUMBER;
BEGIN

    -- Convert to C
 ln_temp_obs_C := (p_temp_obs-32)/1.8;
 --  Convert to scaled value
 ln_Temp_obs_scaled := ln_temp_obs_C/630;
 ln_Temp_IPTS_delta :=((-0.148759+(-0.267408+(1.080760+(1.269056+(-4.089591+(-1.871251+(7.438081+(-3.536296*ln_Temp_obs_scaled))*ln_Temp_obs_scaled)*ln_Temp_obs_scaled)*ln_Temp_obs_scaled)*ln_Temp_obs_scaled)*ln_Temp_obs_scaled)*ln_Temp_obs_scaled)*ln_Temp_obs_scaled);
 --Convert back to F
    ln_Temp_IPTS_68 := ((ln_Temp_obs_C - ln_Temp_IPTS_delta) * 1.8) + 32;
 ln_Delta_temp := ln_Temp_IPTS_68 - 60.0068749;

   RETURN ln_Delta_temp;

END calcDeltaTempIPTS68;


---------------------------------------------------------------------------------------------------
-- Function       : calcAPIGlassCorr
-- Description    : Calculates the glass hydrometer adjustment for when API is read
--                  using a glass hydrometer
--         
---------------------------------------------------------------------------------------------------


FUNCTION calcAPIGlassCorr(
   p_API_Gravity  NUMBER,
   p_Temp_Obs     NUMBER)
  RETURN NUMBER
IS
  ln_result          NUMBER;
BEGIN

    -- Adjust from API read by glass hydrometer to correct API using API methodology
 ln_result := 141.5/((141.5/(p_api_gravity + 131.50)*999.016*(1-0.00001278*(p_temp_obs-60)-0.0000000062*power((p_temp_obs-60),2))/999.016))-131.5;
 

   RETURN ln_result;

END calcAPIGlassCorr;

END; 
/

