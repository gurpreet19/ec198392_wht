CREATE OR REPLACE PACKAGE BODY EcBp_VCF IS
/****************************************************************
** Package        :  EcBp_VCF, body part
**
** Calcuates various API gravity and volume corection factors (VCF)
** based on the Manual of Petroleum Measurement Standards Chapter 11
** Addendum 1, September 2007.
** Includes API Table 6 adjustments based on the official API documentation
**
** Explanation for the naming convention based on API spec:
** CTL: Correction for the effect of Temperature on Liquid
** CPL: Correction for the effect of Pressure on Liquid
** CTPL: Correction for Temperature and Pressure of Liquid (also known as Volume Correction Factors (VCF))
**
**  Date        Whom      Change description:
** ----------  --------  --------------------------------------
** 07.11.2012 rajarsar  ECPD-19864: Modified the function of calcAPIGravityObs, calcAPIGravityCorr and calcDensityCorr.
**                                  Added the new functions of calcDensityCorr_SI, calcVCFobsDensity_SI and calcVCFstdDensity_SI.
** 22.03.2013 kumarsur  ECPD-22598: Added calcDiluentConcentration(), calcShrinkageFactor() and calcAPIBlendShrinkage().
** 06.11.2013 musthram  ECPD-25764: Modified calcAPIBlendShrinkage() to validate Std Density are within valid range using system attribute values.
** 07.11.2013 wonggkai ECPD-25297: Updated function calcShrinkageFactor, calcDiluentConcentration. modify function to return zero when ln_grs_vol is 0.
** 05.08.2014 kumarsur	ECPD-27067: Revert changes done from ECPD-26005. Modified calcDiluentConcentration and calcShrinkageFactor.
** 19.02.2016 abdulmaw  ECPD-28016: Modified calcAPIGravityCorr, calcDensityCorr, calcDensityCorr_SI, calcVCFobsAPI, calcVCFobsDensity_SI,	calcVCFstdAPI,
                                    calcVCFstdDensity,	calcVCFstdDensity_SI to support pressure correction for VCF. Added new function convertPressAPI, calcTempIPTS68
*****************************************************************/

---------------------------------------------------------------------------------------------------
-- Function       : calcAPIGravityObs
-- Description    : Calculates what the observed API gravity would have been given the
--                  corrected API gravity and the sample temperature.
--                  NOTE this is the inverse of the normal calculation and is used in cases where
--                  the original lab work is done at a temperature different than the sample temperature
--  INPUT Corrected API gravity at 60 degrees and original sample temperature
---------------------------------------------------------------------------------------------------
FUNCTION calcAPIGravityObs(
   p_API_Gravity  NUMBER,
   p_Temp_Obs     NUMBER,
   p_decimals NUMBER DEFAULT 5)
RETURN NUMBER
IS
   ln_Alpha_60    NUMBER;
   ln_Ctl         NUMBER;
   ln_delta_Temp  NUMBER;
   ln_density_60  NUMBER;
   ln_density_obs NUMBER;
   ln_A           NUMBER;
   ln_RHO_Star    NUMBER;
   ln_result      NUMBER;
BEGIN

   -- Calculate density at 60 degrees from corrected API gravity
   ln_density_60 := EcBp_VCF.getDensityFromAPI(p_API_gravity);

   ln_A := 0.0137498 * 341.0957 / (2 * ln_density_60**2);
   ln_RHO_Star := ln_density_60 / (1+ ((exp(ln_A*(1+0.8*ln_A)) - 1)/(1+ln_a*(1+1.6*ln_a)*2)));
   ln_Alpha_60 := 341.0957 / (ln_RHO_Star**2);

   -- Convert the temperature to ITPS-68 basis
   ln_Delta_temp := EcBp_VCF.calcDeltaTempIPTS68(p_temp_obs);
   ln_Ctl := exp(-1*ln_Alpha_60*ln_Delta_temp*(1 + 0.8*ln_Alpha_60*(ln_Delta_temp + 0.01374979)));
   -- Density at temperature the sample was taken at (tank or stream temperature)
   ln_density_obs := ln_density_60 * ln_Ctl;

   -- Calculate API gravity at observed temperature from density at observed temperature
   ln_result := round(EcBp_VCF.getAPIFromDensity(ln_density_obs),p_decimals);
   RETURN ln_result;

END calcAPIGravityObs;

---------------------------------------------------------------------------------------------------
-- Function       : calcAPIGravityCorr
-- Description    : Calculates what the CORRECTED API gravity given the
--                  observed tempature and observed gravity
--                  This is normally done as a set of iterations until a certain delta is achieved
--                  In this case it is hard coded for max 10 iterations
--                  This provides good results for the normal range of operations
--
---------------------------------------------------------------------------------------------------
FUNCTION calcAPIGravityCorr(
   p_API_Gravity_obs  NUMBER,
   p_Temp_Obs         NUMBER,
   p_Press_Obs        NUMBER DEFAULT NULL,
   p_daytime          DATE DEFAULT NULL,
   p_decimals         NUMBER DEFAULT 5)
RETURN NUMBER
IS
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
   ln_fp              NUMBER;
   ln_Cpl             NUMBER;
   ln_Ctpl            NUMBER;
   ln_temp_star       NUMBER;
   ln_Dp_factor       NUMBER;
   lv2_api_vcf        VARCHAR2(32);

BEGIN

   -- Calculate density at observed condition from observed API gravity p_API_gravity_obs
   ln_density_obs := EcBp_VCF.getDensityFromAPI(p_API_gravity_obs);
   --  Use the observed density as the first guess for the corrected density
   ln_density_60 := ln_density_obs;
   -- Convert the temperature to ITPS-68 basis
   ln_Delta_temp := EcBp_VCF.calcDeltaTempIPTS68(p_temp_obs);

   -- Loop through iterations until convergence is reached
   FOR ln_counter IN 1..10 LOOP
      -- Calculate the A factor
      ln_A := 0.0137498 * 341.0957 / (2 * ln_density_60**2);

      ln_RHO_Star := ln_density_60 * (1+ ((exp(ln_A*(1+0.8*ln_A)) - 1)/(1+ln_a*(1+1.6*ln_a)*2)));

      ln_Alpha_60 := 341.0957 / (ln_RHO_Star**2);

      -- Density at temperature the sample was taken at (tank or stream temperature)
      ln_Ctl := exp(-1*ln_Alpha_60*ln_Delta_temp*(1 + (0.8*ln_Alpha_60*(ln_Delta_temp + 0.01374979))));
 	    IF ln_Ctl = 0 THEN
		     RAISE_APPLICATION_ERROR(-20000,'The combination of the Temperature and API Gravity is not valid.');
      ELSE
         lv2_api_vcf := ec_ctrl_system_attribute.attribute_text(p_daytime, 'API_VCF_PRESS_CORR', '<=');
         IF lv2_api_vcf = 'Y' AND p_Press_Obs IS NOT NULL THEN
            -- Convert the temperature to ITPS-68 basis
            ln_temp_star := EcBp_VCF.calcTempIPTS68(p_temp_obs);
            -- calculate the scaled compressibility factor
            ln_fp := exp(-1.9947 + 0.00013427 * ln_temp_star +((793920 + 2326.0* ln_temp_star)/ power(ln_RHO_Star,2)));
            -- calculate correction factor due to pressure
            -- force negative pressure to be 0
            IF p_press_Obs < 0 THEN
               ln_Cpl := 1/(1-power(10,-5) * ln_fp * 0);
            ELSE
               ln_Cpl := 1/(1-power(10,-5) * ln_fp * p_Press_Obs);
            END IF;
         END IF;
         IF ln_Cpl IS NOT NULL THEN
            ln_Ctpl := ln_Ctl * ln_Cpl;
         ELSE
            ln_Ctpl := ln_Ctl;
         END IF;
		     -- Calculate API gravity at observed temperature from density at observed temperature
		     ln_density_Delta := ln_density_obs - (ln_density_60*ln_Ctpl) ;
	    END IF;

      -- Exit when convergence is reached
      EXIT WHEN abs(ln_density_Delta) < 0.0000001;

      -- Estimate the amount of change in the density needed to get a good answer
      ln_E_factor := (ln_density_obs/ln_Ctpl) - ln_density_60;
      ln_Dt_factor := 2 * ln_alpha_60 * (p_temp_obs - 60) *(1 + 1.6 * ln_alpha_60* (p_temp_obs - 60));
      ln_Dp_factor := nvl((2 * ln_Cpl * p_Press_Obs * ln_fp *(7.93920+0.2326*p_temp_obs))/(ln_density_60 *ln_density_60),0);
      ln_delta_density_60 := ln_E_factor / (1+ln_Dt_factor + ln_Dp_factor);
      -- Adjust the guessed density based on the above delta
      ln_density_60 := ln_density_60 +  ln_delta_density_60;
   END LOOP;

   -- Convert back to API units ln_density_60
   ln_result := round(EcBp_VCF.getAPIfromDensity(ln_density_60),p_decimals);
   RETURN ln_result;

END calcAPIGravityCorr;


---------------------------------------------------------------------------------------------------
-- Function       : calcDensityCorr
-- Description    : Calculates what the CORRECTED density given the
--                  observed tempature and observed density
--                  This is normally done as a set of iterations until a certain delta is achieved
--                  In this case it is hard coded for max 10 iterations
--                  This provides good results for the normal range of operations
--
---------------------------------------------------------------------------------------------------
FUNCTION calcDensityCorr(
   p_Density_obs      NUMBER,
   p_Temp_Obs         NUMBER,
   p_Press_Obs        NUMBER DEFAULT NULL,
   p_daytime          DATE DEFAULT NULL,
   p_decimals         NUMBER DEFAULT 5)
RETURN NUMBER
IS
   ln_Alpha_60        NUMBER;
   ln_Ctl             NUMBER;
   ln_density_60      NUMBER;
   ln_density_delta   NUMBER;
   ln_result          NUMBER;
   ln_A               NUMBER;
   ln_RHO_Star        NUMBER;
   ln_Delta_Temp      NUMBER;
   ln_E_factor        NUMBER;
   ln_Dt_factor       NUMBER;
   ln_delta_density_60 NUMBER;
   ln_counter         NUMBER;
   ln_fp              NUMBER;
   ln_Cpl             NUMBER;
   ln_Ctpl            NUMBER;
   ln_temp_star       NUMBER;
   ln_Dp_factor       NUMBER;
   lv2_api_vcf        VARCHAR2(32);

BEGIN

   --  Use the observed density as the first guess for the corrected density
   ln_density_60 := p_Density_obs;
   -- Convert the temperature to ITPS-68 basis
   ln_Delta_temp := EcBp_VCF.calcDeltaTempIPTS68(p_temp_obs);

   -- Loop through iterations until convergence is reached
   FOR ln_counter IN 1..10 LOOP
      -- Calculate the A factor
      ln_A := 0.0137498 * 341.0957 / (2 * ln_density_60**2);

      ln_RHO_Star := ln_density_60 * (1+ ((exp(ln_A*(1+0.8*ln_A)) - 1)/(1+ln_a*(1+1.6*ln_a)*2)));

      ln_Alpha_60 := 341.0957 / (ln_RHO_Star**2);

      -- Density at temperature the sample was taken at (tank or stream temperature)
      ln_Ctl := exp(-1*ln_Alpha_60*ln_Delta_temp*(1 + (0.8*ln_Alpha_60*(ln_Delta_temp + 0.01374979))));

 	    IF ln_Ctl = 0 THEN
         RAISE_APPLICATION_ERROR(-20000,'The combination of the Temperature and Observed Density is not valid.');
      ELSE
         lv2_api_vcf := ec_ctrl_system_attribute.attribute_text(p_daytime, 'API_VCF_PRESS_CORR', '<=');
         IF lv2_api_vcf = 'Y' AND p_Press_Obs IS NOT NULL THEN
            -- Convert the temperature to ITPS-68 basis
            ln_temp_star := EcBp_VCF.calcTempIPTS68(p_temp_obs);
            -- calculate the scaled compressibility factor
            ln_fp := exp(-1.9947 + 0.00013427 * ln_temp_star +((793920 + 2326.0* ln_temp_star)/ power(ln_RHO_Star,2)));
            -- calculate correction factor due to pressure
            -- force negative pressure to be 0
            IF p_press_Obs < 0 THEN
               ln_Cpl := 1/(1-power(10,-5) * ln_fp * 0);
            ELSE
               ln_Cpl := 1/(1-power(10,-5) * ln_fp * p_Press_Obs);
            END IF;
         END IF;
         IF ln_Cpl IS NOT NULL THEN
            ln_Ctpl := ln_Ctl * ln_Cpl;
         ELSE
           ln_Ctpl := ln_Ctl;
         END IF;
         ln_density_Delta := p_Density_obs - (ln_density_60*ln_Ctpl) ;
      END IF;

      -- Exit when convergence is reached
      EXIT WHEN abs(ln_density_Delta) < 0.0000001;

      -- Estimate the amount of change in the density needed to get a good answer
      ln_E_factor := (p_Density_obs/ln_Ctpl) - ln_density_60;
      ln_Dt_factor := 2 * ln_alpha_60 * (p_temp_obs - 60) *(1 + 1.6 * ln_alpha_60* (p_temp_obs - 60));
      ln_Dp_factor := nvl((2 * ln_Cpl * p_Press_Obs * ln_fp *(7.93920+0.2326*p_temp_obs))/(ln_density_60 *ln_density_60),0);
      ln_delta_density_60 := ln_E_factor / (1+ln_Dt_factor + ln_Dp_factor);
      -- Adjust the guessed density based on the above delta
     ln_density_60 := ln_density_60 +  ln_delta_density_60;
   END LOOP;

   -- Convert back to API units ln_density_60;--
   ln_result := round(ln_density_60,p_decimals);
   RETURN ln_result;

END calcDensityCorr;


---------------------------------------------------------------------------------------------------
-- Function       : calcDensityCorrObs_SI
-- Description    : Calculates what the CORRECTED density given the
--                  observed tempature and observed density in SI Units
--                  This is normally done as a set of iterations until a certain delta is achieved
--                  In this case it is hard coded for max 10 iterations
--                  This provides good results for the normal range of operations
--
--      API Chapter 11.1  section 11.1.7.2
--
---------------------------------------------------------------------------------------------------
FUNCTION calcDensityCorr_SI(
   p_Density_obs      NUMBER,
   p_Temp_Obs         NUMBER,
   p_Press_Obs        NUMBER DEFAULT NULL,
   p_daytime          DATE DEFAULT NULL,
   p_Temp_Base       NUMBER DEFAULT 15,
   p_decimals         NUMBER DEFAULT 5)
RETURN NUMBER
IS
   ln_Alpha_60        NUMBER;
   ln_Ctl             NUMBER;
   ln_Ctl_60          NUMBER;
   ln_density_60      NUMBER;
   ln_density_delta   NUMBER;
   ln_result          NUMBER;
   ln_A               NUMBER;
   ln_RHO_Star        NUMBER;
   ln_Temp_Base_F     NUMBER;
   ln_Temp_obs_F      NUMBER;
   ln_Delta_Temp      NUMBER;
   ln_E_factor        NUMBER;
   ln_Dt_factor       NUMBER;
   ln_delta_density_60 NUMBER;
   ln_counter         NUMBER;
   ln_fp              NUMBER;
   ln_Cpl_60          NUMBER;
   ln_Ctpl_60         NUMBER;
   ln_temp_star       NUMBER;
   ln_Dp_factor       NUMBER;
   lv2_api_vcf        VARCHAR2(32);

BEGIN

   --  Use the observed density as the first guess for the corrected density
   ln_density_60 := p_Density_obs;

   -- Convert base temperature to F
   ln_temp_base_f := (p_temp_base *9/5)+32;
   ln_temp_obs_f := (p_temp_obs *9/5)+32;
   -- Convert the temperature to ITPS-68 basis
   ln_Delta_temp := EcBp_VCF.calcDeltaTempIPTS68(ln_temp_obs_f);

   -- Loop through iterations until convergence is reached
   FOR ln_counter IN 1..10 LOOP
      -- Calculate the A factor
      ln_A := 0.0137498 * 341.0957 / (2 * ln_density_60**2);

      ln_RHO_Star := ln_density_60 * (1+ ((exp(ln_A*(1+0.8*ln_A)) - 1)/(1+ln_a*(1+1.6*ln_a)*2)));

      ln_Alpha_60 := 341.0957 / (ln_RHO_Star**2);

      -- Density at temperature the sample was taken at (tank or stream temperature)
      ln_Ctl_60 := exp(-1*ln_Alpha_60*ln_Delta_temp*(1 + (0.8*ln_Alpha_60*(ln_Delta_temp + 0.01374979))));

      IF ln_Ctl_60 = 0 THEN
         RAISE_APPLICATION_ERROR(-20000,'The combination of the Temperature and Observed Density is not valid.');
      ELSE
         lv2_api_vcf := ec_ctrl_system_attribute.attribute_text(p_daytime, 'API_VCF_PRESS_CORR', '<=');
         IF lv2_api_vcf = 'Y' AND p_Press_Obs IS NOT NULL THEN
            -- Convert the temperature to ITPS-68 basis
            ln_temp_star := EcBp_VCF.calcTempIPTS68(ln_temp_obs_f);
            -- calculate the scaled compressibility factor
            ln_fp := exp(-1.9947 + 0.00013427 * ln_temp_star +((793920 + 2326.0* ln_temp_star)/ power(ln_RHO_Star,2)));
            -- calculate correction factor due to pressure
            -- force negative pressure to be 0
            IF p_press_Obs < 0 THEN
               ln_Cpl_60 := 1/(1-power(10,-5) * ln_fp * 0);
            ELSE
               ln_Cpl_60 := 1/(1-power(10,-5) * ln_fp * p_Press_Obs);
            END IF;
         END IF;
         IF ln_Cpl_60 IS NOT NULL THEN
            ln_Ctpl_60 := ln_Ctl_60 * ln_Cpl_60;
         ELSE
            ln_Ctpl_60 := ln_Ctl_60;
         END IF;

         -- Calculate API gravity at observed temperature from density at observed temperature
         ln_density_Delta := p_Density_obs - (ln_density_60*ln_Ctpl_60) ;
      END IF;

      -- Exit when convergence is reached
      EXIT WHEN abs(ln_density_Delta) < 0.0000001;

      -- Estimate the amount of change in the density needed to get a good answer
      ln_E_factor := (p_Density_obs/ln_Ctpl_60) - ln_density_60;
      ln_Dt_factor := 2 * ln_alpha_60 * (ln_temp_obs_f - 60) *(1 + 1.6 * ln_alpha_60* (ln_temp_obs_f - 60));
      ln_Dp_factor := nvl((2 * ln_Cpl_60 * p_Press_Obs * ln_fp *(7.93920+0.2326*ln_temp_obs_f))/(ln_density_60 *ln_density_60),0);
      ln_delta_density_60 := ln_E_factor / (1+ln_Dt_factor + ln_Dp_factor);
      -- Adjust the guessed density based on the above delta
      ln_density_60 := ln_density_60 +  ln_delta_density_60;
   END LOOP;

   ln_Delta_temp := EcBp_VCF.calcDeltaTempIPTS68(ln_temp_base_f);
   ln_A := 0.0137498 * 341.0957 / (2 * ln_density_60**2);
   ln_RHO_Star := ln_density_60 * (1+ ((exp(ln_A*(1+0.8*ln_A)) - 1)/(1+ln_a*(1+1.6*ln_a)*2)));
   ln_Alpha_60 := 341.0957 / (ln_RHO_Star**2);

   -- Density at temperature the sample was taken at (tank or stream temperature)
   ln_Ctl := exp(-1*ln_Alpha_60*ln_Delta_temp*(1 + (0.8*ln_Alpha_60*(ln_Delta_temp + 0.01374979))));

   -- Convert back to API units ln_density_60
   ln_result := round((ln_density_60 * ln_Ctl),p_decimals);

   RETURN ln_result;

END calcDensityCorr_SI;

---------------------------------------------------------------------------------------------------
-- Function       : calcVCFobsAPI
-- Description    : Calculates the VCF for an observed API gravity given the
--                  observed tempature
---------------------------------------------------------------------------------------------------

FUNCTION calcVCFobsAPI(
   p_API_Gravity_obs  NUMBER,
   p_Temp_Obs         NUMBER,
   p_Press_Obs        NUMBER DEFAULT NULL,
   p_daytime          DATE DEFAULT NULL,
   p_decimals         NUMBER DEFAULT 5)
RETURN NUMBER
IS
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
   ln_fp              NUMBER;
   ln_Cpl             NUMBER;
   ln_Ctpl            NUMBER;
   lv2_api_vcf        VARCHAR2(32);
   ln_temp_star       NUMBER;
   ln_Dp_factor       NUMBER;

BEGIN

   -- Calculate density at observed condition from observed API gravity
   ln_density_obs := EcBp_VCF.getDensityFromAPI(p_API_gravity_obs);
   --  Use the observed density as the first guess for the corrected density
   ln_density_60 := ln_density_obs;
   -- Convert the delta temperature to ITPS-68 basis
   ln_Delta_temp := EcBp_VCF.calcDeltaTempIPTS68(p_temp_obs);
   -- Convert the temperature to ITPS-68 basis
   ln_temp_star := EcBp_VCF.calcTempIPTS68(p_temp_obs);
   -- check for API_VCF_PRESS_CORR
   lv2_api_vcf := ec_ctrl_system_attribute.attribute_text(p_daytime, 'API_VCF_PRESS_CORR', '<=');

   -- Loop through iterations until convergence is reached
   FOR ln_counter IN 1..10 LOOP
      -- Calculate the A factor
      ln_A := 0.0137498 * 341.0957 / (2 * ln_density_60**2);

      ln_RHO_Star := ln_density_60 * (1+ ((exp(ln_A*(1+0.8*ln_A)) - 1)/(1+ln_a*(1+1.6*ln_a)*2)));

      ln_Alpha_60 := 341.0957 / (ln_RHO_Star**2);

      -- Density at temperature the sample was taken at (tank or stream temperature)
      ln_Ctl := exp(-1*ln_Alpha_60*ln_Delta_temp*(1 + (0.8*ln_Alpha_60*(ln_Delta_temp + 0.01374979))));
 	    IF ln_Ctl = 0 THEN
         RAISE_APPLICATION_ERROR(-20000,'The combination of the Temperature and Observed API is not valid.');
      ELSE
         IF lv2_api_vcf = 'Y' AND p_Press_Obs IS NOT NULL THEN
            -- calculate the scaled compressibility factor
            ln_fp := exp(-1.9947 + 0.00013427 * ln_temp_star +((793920 + 2326.0* ln_temp_star)/ power(ln_RHO_Star,2)));
            -- calculate correction factor due to pressure
            -- force negative pressure to be 0
            IF p_press_Obs < 0 THEN
               ln_Cpl := 1/(1-power(10,-5) * ln_fp * 0);
            ELSE
               ln_Cpl := 1/(1-power(10,-5) * ln_fp * p_Press_Obs);
            END IF;
         END IF;
         IF ln_Cpl IS NOT NULL THEN
            ln_Ctpl := ln_Ctl * ln_Cpl;
         ELSE
            ln_Ctpl := ln_Ctl;
         END IF;
         ln_density_Delta := ln_density_obs - (ln_density_60*ln_Ctpl) ;
      END IF;


      -- Exit when convergence is reached
      EXIT WHEN abs(ln_density_Delta) < 0.0000001;

      -- Estimate the amount of change in the density needed to get a good answer
      ln_E_factor := (ln_density_obs/ln_Ctpl) - ln_density_60;
      ln_Dt_factor := 2 * ln_alpha_60 * (p_temp_obs - 60) *(1 + 1.6 * ln_alpha_60* (p_temp_obs - 60));
      ln_Dp_factor := nvl((2 * ln_Cpl * p_Press_Obs * ln_fp *(7.93920+0.2326*p_temp_obs))/(ln_density_60 *ln_density_60),0);
      ln_delta_density_60 := ln_E_factor / (1+ln_Dt_factor + ln_Dp_factor);
      -- Adjust the guessed density based on the above delta
      ln_density_60 := ln_density_60 +  ln_delta_density_60;
   END LOOP;

   IF ln_Cpl IS NOT NULL THEN
      ln_Ctpl := ln_Ctl * ln_Cpl;
      ln_result := round(ln_Ctpl,p_decimals);
   ELSE
      ln_result := round(ln_Ctl,p_decimals);
   END IF;
   RETURN ln_result;

END calcVCFobsAPI;

---------------------------------------------------------------------------------------------------
-- Function       : calcVCFobsDensity_SI
-- Description    : Calculates what the VCF is CORRECTED density given the
--                  observed tempature and observed density in SI Units
--                  This is normally done as a set of iterations until a certain delta is achieved
--                  In this case it is hard coded for max 10 iterations
--                  This provides good results for the normal range of operations
--
--      API Chapter 11.1  section 11.1.7.2
--
---------------------------------------------------------------------------------------------------
FUNCTION calcVCFobsDensity_SI(
   p_Density_obs      NUMBER,
   p_Temp_Obs         NUMBER,
   p_Press_Obs        NUMBER DEFAULT NULL,
   p_daytime          DATE DEFAULT NULL,
   p_Temp_Base        NUMBER DEFAULT 15,
   p_decimals         NUMBER DEFAULT 5)
RETURN NUMBER
IS
   ln_Alpha_60        NUMBER;
   ln_Ctl             NUMBER;
   ln_Ctl_60          NUMBER;
   ln_density_60      NUMBER;
   ln_density_delta   NUMBER;
   ln_result          NUMBER;
   ln_A               NUMBER;
   ln_RHO_Star        NUMBER;
   ln_Temp_Base_F     NUMBER;
   ln_Temp_obs_F      NUMBER;
   ln_Delta_Temp      NUMBER;
   ln_E_factor        NUMBER;
   ln_Dt_factor       NUMBER;
   ln_delta_density_60 NUMBER;
   ln_counter         NUMBER;
   ln_fp              NUMBER;
   ln_Cpl             NUMBER;
   ln_Ctpl            NUMBER;
   lv2_api_vcf        VARCHAR2(32);
   ln_temp_star       NUMBER;
   ln_Ctpl_60         NUMBER;
   ln_Dp_factor       NUMBER;

BEGIN

   --  Use the observed density as the first guess for the corrected density
   ln_density_60 := p_Density_obs;

   -- Convert base temperature to F
   ln_temp_base_f := (p_temp_base *9/5)+32;
   ln_temp_obs_f := (p_temp_obs *9/5)+32;
   -- Convert the delta temperature to ITPS-68 basis
   ln_Delta_temp := EcBp_VCF.calcDeltaTempIPTS68(ln_temp_obs_f);
   -- Convert the temperature to ITPS-68 basis
   ln_temp_star := EcBp_VCF.calcTempIPTS68(ln_temp_obs_f);
   -- check for API_VCF_PRESS_CORR
   lv2_api_vcf := ec_ctrl_system_attribute.attribute_text(p_daytime, 'API_VCF_PRESS_CORR', '<=');

   -- Loop through iterations until convergence is reached
   FOR ln_counter IN 1..10 LOOP
      -- Calculate the A factor
      ln_A := 0.0137498 * 341.0957 / (2 * ln_density_60**2);

      ln_RHO_Star := ln_density_60 * (1+ ((exp(ln_A*(1+0.8*ln_A)) - 1)/(1+ln_a*(1+1.6*ln_a)*2)));

      ln_Alpha_60 := 341.0957 / (ln_RHO_Star**2);

      -- Density at temperature the sample was taken at (tank or stream temperature)
      ln_Ctl_60 := exp(-1*ln_Alpha_60*ln_Delta_temp*(1 + (0.8*ln_Alpha_60*(ln_Delta_temp + 0.01374979))));

      IF ln_Ctl_60 = 0 THEN
         RAISE_APPLICATION_ERROR(-20000,'The combination of the Temperature and Observed Density is not valid.');
      ELSE
         -- check for API_VCF_PRESS_CORR
         IF lv2_api_vcf = 'Y' AND p_Press_Obs IS NOT NULL THEN
            -- calculate the scaled compressibility factor
            ln_fp := exp(-1.9947 + 0.00013427 * ln_temp_star +((793920 + 2326.0* ln_temp_star)/ power(ln_RHO_Star,2)));
            -- calculate correction factor due to pressure
            -- force negative pressure to be 0
            IF p_press_Obs < 0 THEN
               ln_Cpl := 1/(1-power(10,-5) * ln_fp * 0);
            ELSE
               ln_Cpl := 1/(1-power(10,-5) * ln_fp * p_Press_Obs);
            END IF;
         END IF;

         IF ln_Cpl IS NOT NULL THEN
            ln_Ctpl_60 := ln_Ctl_60 * ln_Cpl;
         ELSE
            ln_Ctpl_60 := ln_Ctl_60;
         END IF;
         -- Calculate API gravity at observed temperature from density at observed temperature
         ln_density_Delta := p_Density_obs - (ln_density_60*ln_Ctpl_60) ;
      END IF;

      -- Exit when convergence is reached
      EXIT WHEN abs(ln_density_Delta) < 0.0000001;

      -- Estimate the amount of change in the density needed to get a good answer
      ln_E_factor := (p_Density_obs/ln_Ctpl_60) - ln_density_60;
      ln_Dt_factor := 2 * ln_alpha_60 * (ln_temp_obs_f - 60) *(1 + 1.6 * ln_alpha_60* (ln_temp_obs_f - 60));
      ln_Dp_factor := nvl((2 * ln_Cpl * p_Press_Obs * ln_fp *(7.93920+0.2326*ln_temp_obs_f))/(ln_density_60 *ln_density_60),0);
      ln_delta_density_60 := ln_E_factor / (1+ln_Dt_factor + ln_Dp_factor);
      -- Adjust the guessed density based on the above delta
      ln_density_60 := ln_density_60 +  ln_delta_density_60;
   END LOOP;

   ln_Delta_temp := EcBp_VCF.calcDeltaTempIPTS68(ln_temp_base_f);
   ln_A := 0.0137498 * 341.0957 / (2 * ln_density_60**2);
   ln_RHO_Star := ln_density_60 * (1+ ((exp(ln_A*(1+0.8*ln_A)) - 1)/(1+ln_a*(1+1.6*ln_a)*2)));
   ln_Alpha_60 := 341.0957 / (ln_RHO_Star**2);

   -- Density at temperature the sample was taken at (tank or stream temperature)
   ln_Ctl := exp(-1*ln_Alpha_60*ln_Delta_temp*(1 + (0.8*ln_Alpha_60*(ln_Delta_temp + 0.01374979))));

   --Correct ctl for base temperature:
   ln_Ctl := ln_ctl_60/ln_Ctl;

   IF ln_Cpl IS NOT NULL THEN
      ln_Ctpl := ln_Ctl * ln_Cpl;
      ln_result := round(ln_Ctpl,p_decimals);
   ELSE
      -- CTL at SI conditions
      ln_result := round(ln_ctl ,p_decimals);
   END IF;

   RETURN ln_result;

END calcVCFobsDensity_SI;

---------------------------------------------------------------------------------------------------
-- Function       : calcVCFstdAPI
-- Description    : Calculates the VCF for a starndard API gravity given the
--                  observed tempature
--
---------------------------------------------------------------------------------------------------

FUNCTION calcVCFstdAPI(
   p_API_Gravity_std  NUMBER,
   p_Temp_Obs         NUMBER,
   p_Press_Obs        NUMBER DEFAULT NULL,
   p_daytime          DATE DEFAULT NULL,
   p_Decimals         NUMBER DEFAULT 5)
RETURN NUMBER
IS
   ln_Alpha_60        NUMBER;
   ln_A               NUMBER;
   ln_Rho_star        NUMBER;
   ln_Ctl             NUMBER;
   ln_delta_Temp      NUMBER;
   ln_density_std     NUMBER;
   ln_result          NUMBER;
   ln_fp              NUMBER;
   ln_Cpl             NUMBER;
   ln_Ctpl            NUMBER;
   lv2_api_vcf        VARCHAR2(32);
   ln_temp_star       NUMBER;
BEGIN

   -- Convert API gravity to density
   ln_density_std := EcBp_VCF.getDensityFromAPI(p_API_gravity_std);

   ln_A := 0.0137498 * 341.0957 / (2 * ln_density_std**2);
   ln_RHO_Star := ln_density_std * (1+ ((exp(ln_A*(1+0.8*ln_A)) - 1)/(1+ln_a*(1+1.6*ln_a)*2)));

   ln_Alpha_60 := 341.0957 / (ln_RHO_Star**2);
   -- Convert the delta temperature to ITPS-68 basis
   ln_Delta_temp := EcBp_VCF.calcDeltaTempIPTS68(p_temp_obs);
   -- Convert the temperature to ITPS-68 basis
   ln_temp_star := EcBp_VCF.calcTempIPTS68(p_temp_obs);
   -- Temperature VCF factor
   ln_Ctl := exp(-1*ln_Alpha_60*ln_Delta_temp*(1 + (0.8*ln_Alpha_60*(ln_Delta_temp + 0.01374979))));

   -- check for API_VCF_PRESS_CORR
   lv2_api_vcf := ec_ctrl_system_attribute.attribute_text(p_daytime, 'API_VCF_PRESS_CORR', '<=');

   -- Calculate Cpl
   IF lv2_api_vcf = 'Y' AND p_Press_Obs IS NOT NULL THEN
      -- calculate the scaled compressibility factor
      ln_fp := exp(-1.9947 + 0.00013427 * ln_temp_star +((793920 + 2326.0* ln_temp_star)/ power(ln_RHO_Star,2)));
      -- calculate correction factor due to pressure
      -- force negative pressure to be 0
      IF p_press_Obs < 0 THEN
         ln_Cpl := 1/(1-power(10,-5) * ln_fp * 0);
      ELSE
         ln_Cpl := 1/(1-power(10,-5) * ln_fp * p_Press_Obs);
      END IF;
   END IF;

   IF ln_Cpl IS NOT NULL THEN
      ln_Ctpl := ln_Ctl * ln_Cpl;
      ln_result := round(ln_Ctpl,p_decimals);
   ELSE
      ln_result := round(ln_Ctl,p_Decimals);
   END IF;

   RETURN ln_result;

END calcVCFstdAPI;

---------------------------------------------------------------------------------------------------
-- Function       : calcVCFstdDensity
-- Description    : Calculates the VCF for a starndard density given the
--                  observed tempature
--
---------------------------------------------------------------------------------------------------

FUNCTION calcVCFstdDensity(
   p_Density_std      NUMBER,
   p_Temp_Obs         NUMBER,
   p_Press_Obs        NUMBER DEFAULT NULL,
   p_daytime          DATE DEFAULT NULL,
   p_Decimals         NUMBER DEFAULT 5)
RETURN NUMBER
IS
   ln_Alpha_60        NUMBER;
   ln_A               NUMBER;
   ln_Rho_star        NUMBER;
   ln_Ctl             NUMBER;
   ln_delta_Temp      NUMBER;
   ln_result          NUMBER;
   ln_fp              NUMBER;
   ln_Cpl             NUMBER;
   ln_Ctpl            NUMBER;
   lv2_api_vcf        VARCHAR2(32);
   ln_temp_star       NUMBER;
BEGIN

   ln_A := 0.0137498 * 341.0957 / (2 * p_Density_std**2);
   ln_RHO_Star := p_Density_std * (1+ ((exp(ln_A*(1+0.8*ln_A)) - 1)/(1+ln_a*(1+1.6*ln_a)*2)));

   ln_Alpha_60 := 341.0957 / (ln_RHO_Star**2);
   -- Convert the delta temperature to ITPS-68 basis
   ln_Delta_temp := EcBp_VCF.calcDeltaTempIPTS68(p_temp_obs);
   -- Convert the temperature to ITPS-68 basis
   ln_temp_star := EcBp_VCF.calcTempIPTS68(p_temp_obs);
   -- check for API_VCF_PRESS_CORR
   lv2_api_vcf := ec_ctrl_system_attribute.attribute_text(p_daytime, 'API_VCF_PRESS_CORR', '<=');
   -- Temperature VCF factor
   ln_Ctl := exp(-1*ln_Alpha_60*ln_Delta_temp*(1 + (0.8*ln_Alpha_60*(ln_Delta_temp + 0.01374979))));

   IF lv2_api_vcf = 'Y' AND p_Press_Obs IS NOT NULL THEN
      -- calculate the scaled compressibility factor
      ln_fp := exp(-1.9947 + 0.00013427 * ln_temp_star +((793920 + 2326.0* ln_temp_star)/ power(ln_RHO_Star,2)));
      -- calculate correction factor due to pressure
      -- force negative pressure to be 0
      IF p_press_Obs < 0 THEN
         ln_Cpl := 1/(1-power(10,-5) * ln_fp * 0);
      ELSE
         ln_Cpl := 1/(1-power(10,-5) * ln_fp * p_Press_Obs);
      END IF;
   END IF;

   IF ln_Cpl IS NOT NULL THEN
      ln_Ctpl := ln_Ctl * ln_Cpl;
      ln_result := round(ln_Ctpl,p_Decimals);
   ELSE
      ln_result := round(ln_ctl,p_Decimals);
   END IF;
   RETURN ln_result;

END calcVCFstdDensity;

---------------------------------------------------------------------------------------------------
-- Function       : calcVCFstdDensity_SI
-- Description    : Calculates what the VCF is at CORRECTED density given the
--                  observed tempature and standard density at the SI Temperature bass
--                  This is normally done as a set of iterations until a certain delta is achieved
--                  In this case it is hard coded for max 10 iterations
--                  This provides good results for the normal range of operations
--
--                APH Chapter 11  section 11.1.7.1
--
---------------------------------------------------------------------------------------------------
FUNCTION calcVCFstdDensity_SI(
   p_Density_Std      NUMBER,
   p_Temp_Obs         NUMBER,
   p_Press_Obs        NUMBER DEFAULT NULL,
   p_daytime          DATE DEFAULT NULL,
   p_Temp_Base        NUMBER DEFAULT 15,
   p_decimals         NUMBER DEFAULT 5)
RETURN NUMBER
IS
   ln_Alpha_60        NUMBER;
   ln_Ctl             NUMBER;
   ln_Ctl_60          NUMBER;
   ln_density_60      NUMBER;
   ln_density_delta   NUMBER;
   ln_result          NUMBER;
   ln_A               NUMBER;
   ln_RHO_Star        NUMBER;
   ln_Temp_Base_F     NUMBER;
   ln_Temp_obs_F      NUMBER;
   ln_Delta_Temp      NUMBER;
   ln_E_factor        NUMBER;
   ln_Dt_factor       NUMBER;
   ln_delta_density_60 NUMBER;
   ln_counter         NUMBER;
   ln_fp              NUMBER;
   ln_Cpl             NUMBER;
   ln_Ctpl            NUMBER;
   lv2_api_vcf        VARCHAR2(32);
   ln_temp_star       NUMBER;

BEGIN

   --  Use the observed density as the first guess for the corrected density
   ln_density_60 := p_Density_Std;

   -- Convert base temperature to F
   ln_temp_base_f := (p_temp_base *9/5)+32;
   ln_temp_obs_f := (p_temp_obs *9/5)+32;
   -- Convert the delta temperature to ITPS-68 basis
   ln_Delta_temp := EcBp_VCF.calcDeltaTempIPTS68(ln_temp_base_f);
   -- Convert the delta temperature to ITPS-68 basis
   ln_temp_star := EcBp_VCF.calcTempIPTS68(ln_temp_base_f);
   -- check for API_VCF_PRESS_CORR
   lv2_api_vcf := ec_ctrl_system_attribute.attribute_text(p_daytime, 'API_VCF_PRESS_CORR', '<=');

   -- Loop through iterations until convergence is reached
   FOR ln_counter IN 1..10 LOOP
      -- Calculate the A factor
      ln_A := 0.0137498 * 341.0957 / (2 * ln_density_60**2);

      ln_RHO_Star := ln_density_60 * (1+ ((exp(ln_A*(1+0.8*ln_A)) - 1)/(1+ln_a*(1+1.6*ln_a)*2)));

      ln_Alpha_60 := 341.0957 / (ln_RHO_Star**2);

      -- Density at temperature the sample was taken at (tank or stream temperature)
      ln_Ctl_60 := exp(-1*ln_Alpha_60*ln_Delta_temp*(1 + (0.8*ln_Alpha_60*(ln_Delta_temp + 0.01374979))));

      IF ln_Ctl_60 = 0 THEN
         RAISE_APPLICATION_ERROR(-20000,'The combination of the Temperature and Observed Density is not valid.');
      ELSE
         -- Calculate API gravity at observed temperature from density at observed temperature
         ln_density_Delta := (p_Density_Std / ln_Ctl_60) - ln_density_60;
      END IF;

      -- Exit when convergence is reached
      EXIT WHEN abs(ln_density_Delta) < 0.0000001;

      -- Estimate the amount of change in the density needed to get a good answer
      ln_E_factor := (p_Density_Std/ln_Ctl_60) - ln_density_60; --ln_density_Delta/ln_Ctl;
      ln_Dt_factor := 2 * ln_alpha_60 * (p_temp_obs - 60) *(1 + 1.6 * ln_alpha_60* (p_temp_obs - 60));
      ln_delta_density_60 := ln_E_factor / (1+ln_Dt_factor);
      -- Adjust the guessed density based on the above delta
      ln_density_60 := ln_density_60 +  ln_delta_density_60;
   END LOOP;

   ln_Delta_temp := EcBp_VCF.calcDeltaTempIPTS68(ln_temp_obs_f);
   ln_temp_star := EcBp_VCF.calcTempIPTS68(ln_temp_obs_f);
   ln_A := 0.0137498 * 341.0957 / (2 * ln_density_60**2);
   ln_RHO_Star := ln_density_60 * (1+ ((exp(ln_A*(1+0.8*ln_A)) - 1)/(1+ln_a*(1+1.6*ln_a)*2)));
   ln_Alpha_60 := 341.0957 / (ln_RHO_Star**2);

   -- Density at temperature the sample was taken at (tank or stream temperature)
   ln_Ctl := exp(-1*ln_Alpha_60*ln_Delta_temp*(1 + (0.8*ln_Alpha_60*(ln_Delta_temp + 0.01374979))));

   ln_ctl := ln_ctl / ln_ctl_60;

   -- Calculate Cpl
   IF lv2_api_vcf = 'Y' AND p_Press_Obs IS NOT NULL THEN
      -- calculate the scaled compressibility factor
      ln_fp := exp(-1.9947 + 0.00013427 * ln_temp_star +((793920 + 2326.0* ln_temp_star)/ power(ln_RHO_Star,2)));

      -- calculate correction factor due to pressure
      -- force negative pressure to be 0
      IF p_press_Obs < 0 THEN
         ln_Cpl := 1/(1-power(10,-5) * ln_fp * 0);
      ELSE
         ln_Cpl := 1/(1-power(10,-5) * ln_fp * p_Press_Obs);
      END IF;
   END IF;

   IF ln_Cpl IS NOT NULL THEN
      ln_Ctpl := ln_Ctl * ln_Cpl;
      ln_result := round(ln_Ctpl,p_decimals);
   ELSE
      -- CTL at SI conditions
      ln_result := round(ln_ctl,p_decimals);
   END IF;

   RETURN ln_result;

END calcVCFstdDensity_SI;


---------------------------------------------------------------------------------------------------
-- Function       : calcDeltaTempIPTS68
-- Description    : Calculates the delta temperatur for API calculations based on
--                  the IPTS-68 standard.
--                  Input temp must be in F
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
   -- ln_temp_obs_C := (p_temp_obs-32)/1.8;
   ln_temp_obs_C := Ecdp_Unit.convertValue(p_temp_obs,'F','C');
   --  Convert to scaled value
   ln_Temp_obs_scaled := ln_temp_obs_C/630;
   ln_Temp_IPTS_delta :=((-0.148759+
                        (-0.267408+
                         (1.080760+
                          (1.269056+
                           (-4.089591+
                            (-1.871251+
                             (7.438081+
                              (-3.536296*ln_Temp_obs_scaled)
                             )*ln_Temp_obs_scaled
                            )*ln_Temp_obs_scaled
                           )*ln_Temp_obs_scaled
                          )*ln_Temp_obs_scaled
                         )*ln_Temp_obs_scaled
                        )*ln_Temp_obs_scaled
                       )*ln_Temp_obs_scaled
                      );
   --Convert back to F
   -- ln_Temp_IPTS_68 := ((ln_Temp_obs_C - ln_Temp_IPTS_delta) * 1.8) + 32;
   ln_Temp_IPTS_68 := Ecdp_Unit.convertValue((ln_Temp_obs_C - ln_Temp_IPTS_delta),'C','F');
   ln_Delta_temp := ln_Temp_IPTS_68 - 60.0068749;

   RETURN ln_Delta_temp;

END calcDeltaTempIPTS68;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAPIFromDensity                                                                 --
-- Description    : returns API gravity from Density							    --
--                  API Gravity is so called oil field unit, temp is 60F. Density returned is also at 60F  --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : 			                                                 --
--                                                                                               --
-- Using functions: 					                                         --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getAPIFromDensity(p_density NUMBER)
RETURN NUMBER
IS
   ln_water_density    NUMBER;

BEGIN
-- The formula can be calculated this way:
-- API Gravity = (141.5 / Specific gravity) - 131.5
-- API Gravity = (141.5 / (Density of crude/Density of Water)) - 131.5
-- API Gravity = (141.5 * Density of water / Density of crude) - 131.5

   -- value at 60F (ITS-90) has been redefined as 999.016 kg/m3 (as per API spec Appendix D)
   ln_water_density := 999.016;

   RETURN (141.5 * ln_water_density/ p_density) - 131.5;

END getAPIfromDensity;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function : getDensityFromAPI
-- Description : returns Density from API gravity
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : 			                                                 --
--                                                                                               --
-- Using functions: 					                                         --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getDensityFromAPI(p_API NUMBER)
RETURN NUMBER
IS
   ln_water_density    NUMBER;

BEGIN

   -- value at 60F (ITS-90) has been redefined as 999.016 kg/m3 (as per API spec Appendix D)
   ln_water_density := 999.016;

RETURN (141.5 * ln_water_density/(131.5 + p_API));

END getDensityFromAPI;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function : calcDiluentConcentration
-- Description : returns Diluent concentration from API 12.3 standards
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : 			                                                                 --
--                                                                                               --
-- Using functions: 					                                                         --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcDiluentConcentration(p_object_id stream.object_id%TYPE,
                                  p_daytime DATE)
RETURN NUMBER IS
ln_diluent_vol NUMBER;
ln_diluent_cut NUMBER;
lv_class VARCHAR2(32);
ln_grs_vol_oil NUMBER;

BEGIN

lv_class := ecdp_objects.GetObjClassName(p_object_id);
IF lv_class = 'STREAM' THEN
  ln_diluent_cut := ec_strm_day_stream.diluent_cut(p_object_id, p_daytime);
  ln_grs_vol_oil := ec_strm_day_stream.grs_vol(p_object_id, p_daytime);
ELSE
  ln_diluent_cut := ec_tank_measurement.diluent_cut(p_object_id, 'DAY_CLOSING', p_daytime);
  ln_grs_vol_oil := ec_tank_measurement.grs_vol(p_object_id, 'DAY_CLOSING', p_daytime);
END IF;

IF ln_grs_vol_oil > 0 THEN
	IF ln_diluent_cut IS NOT NULL THEN
	  RETURN ln_diluent_cut;
	ELSE
	  ln_diluent_vol := calcAPIBlendShrinkage(p_object_id, p_daytime, 'DILUENT_VOLUME');
	  IF ln_diluent_vol > -1 THEN
		 RETURN (ln_diluent_vol/(ln_diluent_vol+1));
	  ELSE
		RETURN NULL;
	  END IF;
	END IF;
ELSIF ln_grs_vol_oil = 0 THEN
  RETURN 0;
ELSE
  RETURN NULL;
END IF;

END calcDiluentConcentration;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function : calcShrinkageFactor
-- Description : returns blend shrinkage factor from API 12.3 standards.
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : 			                                                 --
--                                                                                               --
-- Using functions: 					                                         --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcShrinkageFactor(p_object_id stream.object_id%TYPE,
                             p_daytime DATE)
RETURN NUMBER IS
ln_diluent_vol NUMBER;
ln_diluent_cut NUMBER;
ln_blend_vol NUMBER;
ln_diluent_dens NUMBER;
ln_bitumen_dens NUMBER;
lv_class VARCHAR2(32);
lv_unit_type VARCHAR2(32);
ln_grs_vol_oil NUMBER;

BEGIN

SELECT unit INTO lv_unit_type
FROM ctrl_uom_setup WHERE measurement_type='STD_OIL_VOL' AND db_unit_ind='Y';

lv_class := ecdp_objects.GetObjClassName(p_object_id);
IF lv_class = 'STREAM' THEN
  ln_diluent_cut := ec_strm_day_stream.diluent_cut(p_object_id, p_daytime);
  ln_grs_vol_oil := ec_strm_day_stream.grs_vol(p_object_id, p_daytime);
  ln_diluent_dens := Ecbp_Stream_Fluid.findStdDens(ec_strm_version.ref_diluent_stream_id(p_object_id,p_daytime,'<='),p_daytime);
  ln_bitumen_dens := Ecbp_Stream_Fluid.findStdDens(ec_strm_version.ref_bitumen_stream_id(p_object_id,p_daytime,'<='),p_daytime);
ELSE
  ln_diluent_cut := ec_tank_measurement.diluent_cut(p_object_id, 'DAY_CLOSING', p_daytime);
  ln_grs_vol_oil := ec_tank_measurement.grs_vol(p_object_id, 'DAY_CLOSING', p_daytime);
  ln_diluent_dens := Ecbp_Tank.findDiluentDens(p_object_id, 'DAY_CLOSING', p_daytime);
  ln_bitumen_dens := Ecbp_Tank.findBitumenDens(p_object_id, 'DAY_CLOSING', p_daytime);
END IF;

IF ln_grs_vol_oil > 0 THEN
	IF ln_diluent_cut IS NOT NULL THEN
	  ln_diluent_vol := ln_diluent_cut/(1-ln_diluent_cut);
	  IF lv_unit_type='SM3' THEN
		ln_blend_vol := (1+ln_diluent_vol)*
						(100-(2.69*10000*ln_diluent_cut*100*power((100-ln_diluent_cut*100),0.819)*POWER(((1/ln_diluent_dens)-(1/ln_bitumen_dens)),2.28)))/100;
	  ELSE
		ln_blend_vol := (1+ln_diluent_vol)*
						(100-(4.86/power(10,8)*ln_diluent_cut*100*power((100-ln_diluent_cut*100),0.819)*POWER((ln_diluent_dens-ln_bitumen_dens),2.28)))/100;
	  END IF;
	ELSE
	  ln_diluent_vol := calcAPIBlendShrinkage(p_object_id, p_daytime, 'DILUENT_VOLUME');
	  ln_blend_vol := calcAPIBlendShrinkage(p_object_id, p_daytime, 'BLEND_VOLUME');
	END IF;

	IF ln_diluent_vol > -1 THEN
	   RETURN (ln_blend_vol/(ln_diluent_vol+1));
	ELSE
	  RETURN NULL;

	END IF;
ELSIF ln_grs_vol_oil = 0 THEN
  RETURN 0;
ELSE
  RETURN NULL;
END IF;

END calcShrinkageFactor;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function : calcAPIBlendShrinkage
-- Description : returns Diluent Volume OR Blend Volume dependng on p_return_char value
--               Calculates volume of Diluent and Blend starting with 1m3 unshrunk.
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : 			                                                 --
--                                                                                               --
-- Using functions: 					                                         --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION calcAPIBlendShrinkage(p_object_id stream.object_id%TYPE,
                               p_daytime DATE,
                               p_return_char VARCHAR2)
RETURN NUMBER IS
ln_iteration_count     NUMBER :=0;
ln_diluent_vol         NUMBER :=0;
ln_delta_diluent_vol   NUMBER;
ln_delta_diluent_mass  NUMBER;
ln_delta_concentration NUMBER;
ln_delta_shrink_factor NUMBER;
ln_delta_shrink_vol    NUMBER;
ln_shrinkage_vol       NUMBER :=0;
ln_current_blend_vol   NUMBER :=1;
ln_current_blend_mass  NUMBER;
ln_current_blend_dens  NUMBER;
ln_diluent_dens        NUMBER;
ln_target_blend_dens   NUMBER;
ln_new_blend_mass      NUMBER;
ln_new_blend_vol       NUMBER;
ln_new_blend_ideal_vol NUMBER;
lv_class               VARCHAR2(32);
lv_unit_type           VARCHAR2(32);
ln_max_dil_density     NUMBER;
ln_min_dil_density     NUMBER;
ln_max_bit_density     NUMBER;
ln_min_bit_density     NUMBER;
ln_max_iterations      NUMBER;
ln_tolerance           NUMBER;

BEGIN

SELECT unit INTO lv_unit_type
FROM ctrl_uom_setup WHERE measurement_type='STD_OIL_VOL' AND db_unit_ind='Y';

lv_class := ecdp_objects.GetObjClassName(p_object_id);
IF lv_class = 'STREAM' THEN

  ln_target_blend_dens := Ecbp_Stream_Fluid.findStdDens(p_object_id, p_daytime);

  ln_diluent_dens := Ecbp_Stream_Fluid.findStdDens(ec_strm_version.ref_diluent_stream_id(p_object_id,p_daytime,'<='),p_daytime);

  ln_current_blend_dens := Ecbp_Stream_Fluid.findStdDens(ec_strm_version.ref_bitumen_stream_id(p_object_id,p_daytime,'<='),p_daytime);
ELSIF lv_class = 'TANK' THEN

  ln_target_blend_dens := Ecbp_Tank.findStdDens(p_object_id, 'DAY_CLOSING', p_daytime);

  ln_diluent_dens := Ecbp_Tank.findDiluentDens(p_object_id, 'DAY_CLOSING', p_daytime);

  ln_current_blend_dens := Ecbp_Tank.findBitumenDens(p_object_id, 'DAY_CLOSING', p_daytime);
ELSE
  NULL;
END IF;

ln_max_dil_density := ec_ctrl_system_attribute.attribute_value(p_daytime, 'API_CALC_DIL_DENSITY_MAX', '<=');
ln_min_dil_density := ec_ctrl_system_attribute.attribute_value(p_daytime, 'API_CALC_DIL_DENSITY_MIN', '<=');
ln_max_bit_density := ec_ctrl_system_attribute.attribute_value(p_daytime, 'API_CALC_BIT_DENSITY_MAX', '<=');
ln_min_bit_density := ec_ctrl_system_attribute.attribute_value(p_daytime, 'API_CALC_BIT_DENSITY_MIN', '<=');
ln_max_iterations  := ec_ctrl_system_attribute.attribute_value(p_daytime, 'API_CALC_MAX_ITERATIONS', '<=');
ln_tolerance       := ec_ctrl_system_attribute.attribute_value(p_daytime, 'API_CALC_TOLERANCE', '<=');

IF ln_target_blend_dens>0 AND ln_diluent_dens>0 AND ln_current_blend_dens>0
  AND ln_target_blend_dens > ln_diluent_dens and ln_target_blend_dens <= ln_current_blend_dens
  AND ln_diluent_dens BETWEEN ln_min_dil_density AND ln_max_dil_density
  AND ln_current_blend_dens BETWEEN ln_min_bit_density AND ln_max_bit_density
THEN

  WHILE (ln_iteration_count <= ln_max_iterations OR abs(ln_target_blend_dens-ln_current_blend_dens) > ln_tolerance) LOOP
    ln_current_blend_mass := ln_current_blend_vol * ln_current_blend_dens;
    ln_delta_diluent_vol := ln_current_blend_vol * ((ln_current_blend_dens-ln_target_blend_dens)/(ln_target_blend_dens-ln_diluent_dens));
    ln_diluent_vol := ln_diluent_vol + ln_delta_diluent_vol;
    ln_delta_diluent_mass := ln_delta_diluent_vol * ln_diluent_dens;
    ln_new_blend_mass := ln_current_blend_mass + ln_delta_diluent_mass;
    ln_new_blend_ideal_vol := ln_delta_diluent_vol + ln_current_blend_vol;
    ln_delta_concentration := (ln_delta_diluent_vol/ln_new_blend_ideal_vol)*100;

    IF lv_unit_type='SM3' THEN

      ln_delta_shrink_factor := 26900 *
                                ln_delta_concentration *
                                POWER((100-ln_delta_concentration),0.819) *
                                POWER(((1/ln_diluent_dens)-(1/ln_current_blend_dens)),2.28);
    ELSE

      ln_delta_shrink_factor := 4.86/power(10,8)*
                                ln_delta_concentration *
                                POWER((100-ln_delta_concentration),0.819) *
                                POWER((ln_diluent_dens-ln_current_blend_dens),2.28);
    END IF;
    ln_delta_shrink_vol := (ln_delta_shrink_factor/100) * ln_new_blend_ideal_vol;
    ln_shrinkage_vol := ln_shrinkage_vol + ln_delta_shrink_vol;
    ln_new_blend_vol := ln_new_blend_ideal_vol - ln_delta_shrink_vol;
    ln_current_blend_vol := ln_new_blend_vol;
    ln_current_blend_dens := (ln_new_blend_mass/ln_new_blend_vol);

    ln_iteration_count := ln_iteration_count + 1;
  END LOOP;

  IF p_return_char='BLEND_VOLUME' THEN
    RETURN ln_current_blend_vol;
  ELSIF p_return_char = 'DILUENT_VOLUME' THEN
    RETURN ln_diluent_vol;
  ELSE
    RETURN NULL;
  END IF;
ELSE
  RETURN NULL;
END IF;

END calcAPIBlendShrinkage;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function : convertPressAPI
-- Description : convert pressure unit from kPa(kila Pascal) and bar to PSIG (if not in PSIG already)
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : 			                                                 --
--                                                                                               --
-- Using functions: 					                                         --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------

FUNCTION convertPressAPI(p_press_obs NUMBER,
                         p_from_unit VARCHAR2,
                         p_to_unit VARCHAR2)
RETURN NUMBER IS

  ln_return_val NUMBER;

BEGIN

  IF p_from_unit IS NOT NULL THEN
     IF p_from_unit = 'BARG' THEN
        ln_return_val := p_press_obs/0.06894757;
        --ln_return_val := Ecdp_Unit.convertValue(p_press_obs, p_from_unit, p_to_unit);
     ELSIF p_from_unit = 'KPA' THEN
        ln_return_val := p_press_obs/6.894757;
        --ln_return_val := Ecdp_Unit.convertValue(p_press_obs, p_from_unit, p_to_unit);
     ELSIF p_from_unit = 'PSIG' THEN
        ln_return_val := p_press_obs;
     ELSE
        RAISE_APPLICATION_ERROR(-20000,'Only KPA, BARG and PSIG are supported for Pressure.');
     END IF;

     IF ln_return_val < 0 OR ln_return_val > 1500 THEN
        RAISE_APPLICATION_ERROR(-20000,'Observed pressure need to be in between 0 and 1500 PSIG.');
     END IF;

     RETURN ln_return_val; --return as PSIG unit

  ELSE
     RAISE_APPLICATION_ERROR(-20000,'Observed pressure is empty.');
  END IF;

END convertPressAPI;

---------------------------------------------------------------------------------------------------
-- Function       : calcTempIPTS68
-- Description    : Calculates the delta temperatur for API calculations based on
--                  the IPTS-68 standard.
--                  Input temp must be in F
---------------------------------------------------------------------------------------------------


FUNCTION calcTempIPTS68(
   p_Temp_Obs     NUMBER)
RETURN NUMBER
IS
   ln_Temp_IPTS_68    NUMBER;
   ln_temp_obs_C      NUMBER;
   ln_Temp_obs_scaled NUMBER;
   ln_Temp_IPTS_delta NUMBER;
BEGIN

   -- Convert to C
   -- ln_temp_obs_C := (p_temp_obs-32)/1.8;
   ln_temp_obs_C := Ecdp_Unit.convertValue(p_temp_obs,'F','C');
   --  Convert to scaled value
   ln_Temp_obs_scaled := ln_temp_obs_C/630;
   ln_Temp_IPTS_delta :=((-0.148759+
                        (-0.267408+
                         (1.080760+
                          (1.269056+
                           (-4.089591+
                            (-1.871251+
                             (7.438081+
                              (-3.536296*ln_Temp_obs_scaled)
                             )*ln_Temp_obs_scaled
                            )*ln_Temp_obs_scaled
                           )*ln_Temp_obs_scaled
                          )*ln_Temp_obs_scaled
                         )*ln_Temp_obs_scaled
                        )*ln_Temp_obs_scaled
                       )*ln_Temp_obs_scaled
                      );
   --Convert back to F
   -- ln_Temp_IPTS_68 := ((ln_Temp_obs_C - ln_Temp_IPTS_delta) * 1.8) + 32;
   ln_Temp_IPTS_68 := Ecdp_Unit.convertValue((ln_Temp_obs_C - ln_Temp_IPTS_delta),'C','F');

   RETURN ln_Temp_IPTS_68;

END calcTempIPTS68;

END EcBp_VCF;