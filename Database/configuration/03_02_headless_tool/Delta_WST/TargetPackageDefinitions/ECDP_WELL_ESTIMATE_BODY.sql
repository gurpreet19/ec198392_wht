CREATE OR REPLACE PACKAGE BODY EcDp_Well_Estimate IS
/******************************************************************************
** Package        :  EcDp_Well_Estimate, body part
**
** $Revision: 1.23 $
**
** Purpose        :  Provide data access functions for well estimates
**
** Documentation  :  www.energy-components.com
**
** Created  : 2/22/2002  Frode Barstad
**
** Modification history:
**
** Version  Date        Whom     Change description:
** -------  ----------  -------- -------------------------------------------
** 1.0      2/22/2002   FBa      Initial version
** 1.1      11-jun-02   PGI      Added detail functions
**                               getLastOilStdRateDetail, getLastGasStdRateDetail, getLastWatStdRateDetail,
**                               getOilRateDecline, getGasRateDecline, getWatRateDecline,
**                               getLastDetailValue,
**                               getOilStdRatePeriod, getGasStdRatePeriod and getWatStdRatePeriod
**          26-aug-02   HNE      Decline % is per year. Added '/365' in decline functions.
**          30-aug-02   PGI      OBS! FindLastValidTest and FindLastTest is now depending
**                               on status is set to 'ACCEPTED' to return a test.
** 1.2      2002.11.29  DN       Renamed getOilStdRatePeriod, getGasStdRatePeriod and getWatStdRatePeriod to vol instead of rate.
**          2004.03.08  SHN      Removed call to ec_well_estimate_detail, since these attributes have been moved to well_estimate
** 1.3      27.05.2004  FBa      Added function getLastAvgDhPumpSpeed
**          10.06.2004  KAM      Added lv_shrink_method in getLastOilStdRateDetail and getLastGasStdRateDetail.
**          17.06.2004  HNE      Bugfix in getLastGasStdRateDetail. RETURN statement was inside IF LOOP !
**          11.08.2004  mazrina  removed sysnam and update as necessary
**          12.10.2004  DN       TI 1681: Function getLastAvgDhPumpSpeed: Replaced with AVG_DH_PUMP_SPEED.
**          15.02.2005  Ron      Added new funtion getLastDiluentStdRateDay to support diluent in well test.
**          28.02.2005  Ron      Performance Upgrade: Replace reference to ec_strm_attribute to ec_strm_version.
**          12.04.2005  Chongjer Uncommented function getLastDiluentStdRateDay
**          12.04.205   SHN      Performance Test cleanup
**          13.04.2005  ROV      Added getLastCondStdRate
**          09.09.2005  Ron      Added 16 new functions
**				 - getNextOilStdRate
**				 - getNextGasStdRate
**				 - getNextCondStdRate
**				 - getNextWatStdRate
**				 - getOilStdRate
**				 - getGasStdRate
**				 - getCondStdRate
**				 - getWatStdRate
**				 - getInterpolateOilRate
**				 - getExtrapolateOilRate
**				 - getInterpolateGasRate
**				 - getExtrapolateGasRate
**				 - getInterpolateCondRate
**				 - getExtrapolateCondRate
**				 - getInterpolateWatRate
**                        	 - getExtrapolateWatRate
** 29.09.2005 Darren TD4414 and 4416 Fixed bug in
**				 - getOilStdRate
**				 - getGasStdRate
**				 - getCondStdRate
**				 - getWatStdRate
**				 - getInterpolateOilRate
**				 - getExtrapolateOilRate
**				 - getInterpolateGasRate
**				 - getExtrapolateGasRate
**				 - getInterpolateCondRate
**				 - getExtrapolateCondRate
**				 - getInterpolateWatRate
** 01.12.2005 DN      Function getInterpolatedOilProdPot moved from EcDp_Well_Potential to EcDp_Well_Estimate.
** 06.09.2007      rajarsar Added 20 new functions
** 			 - getLastOilStdMassRate
** 			 - getLastCondStdMassRate
** 			 - getLastGasStdMassRate
** 			 - getLastWatStdMassRate
** 			 - getNextOilStdMassRate
** 			 - getNextGasStdMassRate
** 			 - getNextCondStdMassRate
** 			 - getNextWatStdMassRate
** 			 - getOilStdMassRate
** 			 - getGasStdMassRate
** 			 - getCondStdMassRate
** 			 - getWatStdMassRate
** 			 - getInterpolateOilMassRate
** 			 - getExtrapolateOilMassRate
** 			 - getInterpolateGasMassRate
**           - getExtrapolateGasMassRate
**			 - getInterpolateCondMassRate
** 			 - getExtrapolateCondMassRate
**			 - getInterpolateWatMassRate
**			 - getExtrapolateWatMassRate
** 25.08.2008      rajarsar ECPD-9038: Added new function getLastCO2Fraction()
** 31.12.2008      sharawan ECPD-10416:Replaced all references to EcDp_Type.pb_comp_number%TYPE with NUMBER in function getInterpolatedOilProdPot.
******************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLastOilStdRate
-- Description    : Returns the last net oil rate from the last well estimate for a well.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions: EcDp_Performance_Test.getLastValidWellResult
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the last net oil rate from the last well estimate for a well.
---------------------------------------------------------------------------------------------------
FUNCTION getLastOilStdRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER
--</EC-DOC>
IS

lr_pwel_result	PWEL_RESULT%ROWTYPE;

BEGIN

 lr_pwel_result := EcDp_Performance_Test.getLastValidWellResult(p_object_id, p_daytime);

 RETURN lr_pwel_result.net_oil_rate_adj;

END getLastOilStdRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLastCondStdRate
-- Description    : Returns the last net condensate rate from the last well estimate for a well.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions: EcDp_Performance_Test.getLastValidWellResult
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the last net condensate rate from the last well estimate for a well.
---------------------------------------------------------------------------------------------------
FUNCTION getLastCondStdRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER
--</EC-DOC>
IS

lr_pwel_result	PWEL_RESULT%ROWTYPE;

BEGIN

 lr_pwel_result := EcDp_Performance_Test.getLastValidWellResult(p_object_id, p_daytime);

 RETURN lr_pwel_result.net_cond_rate_adj;

END getLastCondStdRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLastGasStdRate
-- Description    : Returns the last gas rate from the last well estimate for a well.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions: EcDp_Performance_Test.getLastValidWellResult
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the last gas rate from the last well estimate for a well.
---------------------------------------------------------------------------------------------------
FUNCTION getLastGasStdRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER
--</EC-DOC>
IS

lr_pwel_result	PWEL_RESULT%ROWTYPE;

BEGIN

 lr_pwel_result := EcDp_Performance_Test.getLastValidWellResult(p_object_id, p_daytime);

 RETURN lr_pwel_result.gas_rate_adj;

END getLastGasStdRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLastCO2StdRateDay
-- Description    : Returns the last CO2 from the last well estimate for a well.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getLastCO2Fraction(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER
--</EC-DOC>
IS

lr_pwel_result	PWEL_RESULT%ROWTYPE;

BEGIN

 lr_pwel_result := EcDp_Performance_Test.getLastValidWellResult(p_object_id, p_daytime);

 RETURN lr_pwel_result.co2_fraction;

END getLastCO2Fraction;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLastWatStdRate
-- Description    : Returns the last water rate from the last well estimate detail for a well.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions: EcDp_Performance_Test.getLastValidWellResult
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the last water rate from the last well estimate for a well.
---------------------------------------------------------------------------------------------------
FUNCTION getLastWatStdRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER
--</EC-DOC>
IS

lr_pwel_result	PWEL_RESULT%ROWTYPE;

BEGIN

 lr_pwel_result := EcDp_Performance_Test.getLastValidWellResult(p_object_id, p_daytime);

 RETURN lr_pwel_result.tot_water_rate_adj;

END getLastWatStdRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLastAvgDhPumpSpeed
-- Description    : Returns the last pump speed from the last well estimate detail for a well.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions: EcDp_Performance_Test.getLastValidWellResult
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the last pump speed from the last well estimate for a well.
---------------------------------------------------------------------------------------------------
FUNCTION getLastAvgDhPumpSpeed(
   p_object_id       IN VARCHAR2,
   p_daytime         IN DATE)
RETURN NUMBER
--</EC-DOC>
IS

lr_pwel_result	PWEL_RESULT%ROWTYPE;

BEGIN

 lr_pwel_result := EcDp_Performance_Test.getLastValidWellResult(p_object_id, p_daytime);

 RETURN lr_pwel_result.pump_speed;

END getLastAvgDhPumpSpeed;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLastDiluentStdRate
-- Description    : Returns the last diluent rate from the last well estimate detail for a well.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions: EcDp_Performance_Test.getLastValidWellResult
--
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the last diluent rate from the last well estimate for a well.
---------------------------------------------------------------------------------------------------
FUNCTION getLastDiluentStdRate(
   p_object_id       IN VARCHAR2,
   p_daytime         IN DATE)
RETURN NUMBER
--</EC-DOC>
IS

lr_pwel_result	PWEL_RESULT%ROWTYPE;

BEGIN

	lr_pwel_result := EcDp_Performance_Test.getLastValidWellResult(p_object_id, p_daytime);

 	RETURN lr_pwel_result.diluent_rate;

END getLastDiluentStdRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLastOilMassStdRate
-- Description    : Returns the last net oil mass rate from the last well estimate for a well.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions: EcDp_Performance_Test.getLastValidWellResult
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the last net oil mass rate from the last well estimate for a well.
---------------------------------------------------------------------------------------------------
FUNCTION getLastOilStdMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER
--</EC-DOC>
IS

lr_pwel_result	PWEL_RESULT%ROWTYPE;

BEGIN

 lr_pwel_result := EcDp_Performance_Test.getLastValidWellResult(p_object_id, p_daytime);

 RETURN lr_pwel_result.net_oil_mass_rate_adj;

END getLastOilStdMassRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLastCondMassStdRate
-- Description    : Returns the last net condensate mass rate from the last well estimate for a well.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions: EcDp_Performance_Test.getLastValidWellResult
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the last net condensate mass rate from the last well estimate for a well.
---------------------------------------------------------------------------------------------------
FUNCTION getLastCondStdMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER
--</EC-DOC>
IS

lr_pwel_result	PWEL_RESULT%ROWTYPE;

BEGIN

 lr_pwel_result := EcDp_Performance_Test.getLastValidWellResult(p_object_id, p_daytime);

 RETURN lr_pwel_result.net_cond_mass_rate_adj;

END getLastCondStdMassRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLastGasStdMassRate
-- Description    : Returns the last gas massrate from the last well estimate for a well.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions: EcDp_Performance_Test.getLastValidWellResult
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the last gas mass rate from the last well estimate for a well.
---------------------------------------------------------------------------------------------------
FUNCTION getLastGasStdMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER
--</EC-DOC>
IS

lr_pwel_result	PWEL_RESULT%ROWTYPE;

BEGIN

 lr_pwel_result := EcDp_Performance_Test.getLastValidWellResult(p_object_id, p_daytime);

 RETURN lr_pwel_result.gas_mass_rate_adj;

END getLastGasStdMassRate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLastWatStdMassRate
-- Description    : Returns the last water massrate from the last well estimate detail for a well.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions: EcDp_Performance_Test.getLastValidWellResult
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the last water mass rate from the last well estimate for a well.
---------------------------------------------------------------------------------------------------
FUNCTION getLastWatStdMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER
--</EC-DOC>
IS

lr_pwel_result	PWEL_RESULT%ROWTYPE;

BEGIN

 lr_pwel_result := EcDp_Performance_Test.getLastValidWellResult(p_object_id, p_daytime);

 RETURN lr_pwel_result.tot_water_mass_rate_adj;

END getLastWatStdMassRate;



-- getNextOilStdRate
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNextOilStdRate
-- Description    : Returns the next net oil rate from the last well estimate for a well.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions: EcDp_Performance_Test.getNextValidWellResult
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the last net oil rate from the last well estimate for a well.
---------------------------------------------------------------------------------------------------
FUNCTION getNextOilStdRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER
--</EC-DOC>
IS

lr_pwel_result	PWEL_RESULT%ROWTYPE;

BEGIN

 lr_pwel_result := EcDp_Performance_Test.getNextValidWellResult(p_object_id, p_daytime);

 RETURN lr_pwel_result.net_oil_rate_adj;

END getNextOilStdRate;

--getNextGasStdRate
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNextGasStdRate
-- Description    : Returns the next net gas rate from the last well estimate for a well.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions: EcDp_Performance_Test.getNextValidWellResult
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the last net gas rate from the last well estimate for a well.
---------------------------------------------------------------------------------------------------
FUNCTION getNextGasStdRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER
--</EC-DOC>
IS

lr_pwel_result	PWEL_RESULT%ROWTYPE;

BEGIN

 lr_pwel_result := EcDp_Performance_Test.getNextValidWellResult(p_object_id, p_daytime);

 RETURN lr_pwel_result.gas_rate_adj;

END getNextGasStdRate;

-- getNextCondStdRate
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNextCondStdRate
-- Description    : Returns the next net cond rate from the last well estimate for a well.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions: EcDp_Performance_Test.getNextValidWellResult
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the last net cond rate from the last well estimate for a well.
---------------------------------------------------------------------------------------------------
FUNCTION getNextCondStdRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER
--</EC-DOC>
IS

lr_pwel_result	PWEL_RESULT%ROWTYPE;

BEGIN

 lr_pwel_result := EcDp_Performance_Test.getNextValidWellResult(p_object_id, p_daytime);

 RETURN lr_pwel_result.net_cond_rate_adj;

END getNextCondStdRate;

-- getNextWatStdRate
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNextWatStdRate
-- Description    : Returns the next net wat rate from the last well estimate for a well.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions: EcDp_Performance_Test.getNextValidWellResult
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the last net watl rate from the last well estimate for a well.
---------------------------------------------------------------------------------------------------
FUNCTION getNextWatStdRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER
--</EC-DOC>
IS

lr_pwel_result	PWEL_RESULT%ROWTYPE;

BEGIN

 lr_pwel_result := EcDp_Performance_Test.getNextValidWellResult(p_object_id, p_daytime);

 RETURN lr_pwel_result.tot_water_rate_adj;

END getNextWatStdRate;


-- getNextOilStdMassRate
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNextOilStdMassRate
-- Description    : Returns the next net oil mass rate from the last well estimate for a well.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions: EcDp_Performance_Test.getNextValidWellResult
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the last net oil mass rate from the last well estimate for a well.
---------------------------------------------------------------------------------------------------
FUNCTION getNextOilStdMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER
--</EC-DOC>
IS

lr_pwel_result	PWEL_RESULT%ROWTYPE;

BEGIN

 lr_pwel_result := EcDp_Performance_Test.getNextValidWellResult(p_object_id, p_daytime);

 RETURN lr_pwel_result.net_oil_mass_rate_adj;

END getNextOilStdMassRate;

--getNextGasStdMassRate
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNextGasStdMassRate
-- Description    : Returns the next net gas mass rate from the last well estimate for a well.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions: EcDp_Performance_Test.getNextValidWellResult
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the last net gas mass rate from the last well estimate for a well.
---------------------------------------------------------------------------------------------------
FUNCTION getNextGasStdMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER
--</EC-DOC>
IS

lr_pwel_result	PWEL_RESULT%ROWTYPE;

BEGIN

 lr_pwel_result := EcDp_Performance_Test.getNextValidWellResult(p_object_id, p_daytime);

 RETURN lr_pwel_result.gas_mass_rate_adj;

END getNextGasStdMassRate;

-- getNextCondStdMassRate
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNextCondStdMassRate
-- Description    : Returns the next net cond rate from the last well estimate for a well.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions: EcDp_Performance_Test.getNextValidWellResult
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the last net cond massrate from the last well estimate for a well.
---------------------------------------------------------------------------------------------------
FUNCTION getNextCondStdMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER
--</EC-DOC>
IS

lr_pwel_result	PWEL_RESULT%ROWTYPE;

BEGIN

 lr_pwel_result := EcDp_Performance_Test.getNextValidWellResult(p_object_id, p_daytime);

 RETURN lr_pwel_result.net_cond_mass_rate_adj;

END getNextCondStdMassRate;

-- getNextWatStdMassRate
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNextWatStdMassRate
-- Description    : Returns the next net wat massrate from the last well estimate for a well.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions: EcDp_Performance_Test.getNextValidWellResult
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the last net watl massrate from the last well estimate for a well.
---------------------------------------------------------------------------------------------------
FUNCTION getNextWatStdMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER
--</EC-DOC>
IS

lr_pwel_result	PWEL_RESULT%ROWTYPE;

BEGIN

 lr_pwel_result := EcDp_Performance_Test.getNextValidWellResult(p_object_id, p_daytime);

 RETURN lr_pwel_result.tot_water_mass_rate_adj;

END getNextWatStdMassRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getOilStdRate
-- Description    : Returns the theor oil rate value determined by the attribute appraoch method
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getOilStdRate(p_object_id   well.object_id%TYPE,
                          p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS
	lv2_approach_method VARCHAR2(32);
BEGIN

	lv2_approach_method := ec_well_version.approach_method(p_object_id, p_daytime, '<=');

	IF (lv2_approach_method is NULL) or (lv2_approach_method = EcDp_Calc_Method.STEPPED) THEN
		return getLastOilStdRate(p_object_id, p_daytime);
	ELSIF (lv2_approach_method = EcDp_Calc_Method.INTERPOLATE_EXTRAPOLATE) THEN
		return getInterpolateOilRate(p_object_id, p_daytime);
	ELSIF (lv2_approach_method = EcDp_Calc_Method.EXTRAPOLATE) THEN
		return getExtrapolateOilRate(p_object_id, p_daytime);
	END IF;

END getOilStdRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasStdRate
-- Description    : Returns the theor gas rate value determined by the attribute appraoch method
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getGasStdRate(p_object_id   well.object_id%TYPE,
                          p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS
	lv2_approach_method VARCHAR2(32);
BEGIN

	lv2_approach_method := ec_well_version.approach_method(p_object_id, p_daytime, '<=');

	IF (lv2_approach_method is NULL) or (lv2_approach_method = EcDp_Calc_Method.STEPPED) THEN
		return getLastGasStdRate(p_object_id, p_daytime);
	ELSIF (lv2_approach_method = EcDp_Calc_Method.INTERPOLATE_EXTRAPOLATE) THEN
		return getInterpolateGasRate(p_object_id, p_daytime);
	ELSIF (lv2_approach_method = EcDp_Calc_Method.EXTRAPOLATE) THEN
		return getExtrapolateGasRate(p_object_id, p_daytime);
	END IF;

END getGasStdRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCondStdRate
-- Description    : Returns the theor cond rate value determined by the attribute appraoch method
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getCondStdRate(p_object_id   well.object_id%TYPE,
                          p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS
	lv2_approach_method VARCHAR2(32);
BEGIN

	lv2_approach_method := ec_well_version.approach_method(p_object_id, p_daytime, '<=');

	IF (lv2_approach_method is NULL) or (lv2_approach_method = EcDp_Calc_Method.STEPPED) THEN
		return getLastCondStdRate(p_object_id, p_daytime);
	ELSIF (lv2_approach_method = EcDp_Calc_Method.INTERPOLATE_EXTRAPOLATE) THEN
		return getInterpolateCondRate(p_object_id, p_daytime);
	ELSIF (lv2_approach_method = EcDp_Calc_Method.EXTRAPOLATE) THEN
		return getExtrapolateCondRate(p_object_id, p_daytime);
	END IF;

END getCondStdRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWatStdRate
-- Description    : Returns the theor wat rate value determined by the attribute appraoch method
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getWatStdRate(p_object_id   well.object_id%TYPE,
                          p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS
	lv2_approach_method VARCHAR2(32);
BEGIN

	lv2_approach_method := ec_well_version.approach_method(p_object_id, p_daytime, '<=');

	IF (lv2_approach_method is NULL) or (lv2_approach_method = EcDp_Calc_Method.STEPPED) THEN
		return getLastWatStdRate(p_object_id, p_daytime);
	ELSIF (lv2_approach_method = EcDp_Calc_Method.INTERPOLATE_EXTRAPOLATE) THEN
		return getInterpolateWatRate(p_object_id, p_daytime);
	ELSIF (lv2_approach_method = EcDp_Calc_Method.EXTRAPOLATE) THEN
		return getExtrapolateWatRate(p_object_id, p_daytime);
	END IF;

END getWatStdRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getOilMassStdRate
-- Description    : Returns the theor oil mass rate value determined by the attribute appraoch method
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getOilStdMassRate(p_object_id   well.object_id%TYPE,
                          p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS
	lv2_approach_method VARCHAR2(32);
BEGIN

	lv2_approach_method := ec_well_version.approach_method(p_object_id, p_daytime, '<=');

	IF (lv2_approach_method is NULL) or (lv2_approach_method = EcDp_Calc_Method.STEPPED) THEN
		return getLastOilStdMassRate(p_object_id, p_daytime);
	ELSIF (lv2_approach_method = EcDp_Calc_Method.INTERPOLATE_EXTRAPOLATE) THEN
		return getInterpolateOilMassRate(p_object_id, p_daytime);
	ELSIF (lv2_approach_method = EcDp_Calc_Method.EXTRAPOLATE) THEN
		return getExtrapolateOilMassRate(p_object_id, p_daytime);
	END IF;

END getOilStdMassRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasStdMassRate
-- Description    : Returns the theor gas mass rate value determined by the attribute appraoch method
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getGasStdMassRate(p_object_id   well.object_id%TYPE,
                          p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS
	lv2_approach_method VARCHAR2(32);
BEGIN

	lv2_approach_method := ec_well_version.approach_method(p_object_id, p_daytime, '<=');

	IF (lv2_approach_method is NULL) or (lv2_approach_method = EcDp_Calc_Method.STEPPED) THEN
		return getLastGasStdMassRate(p_object_id, p_daytime);
	ELSIF (lv2_approach_method = EcDp_Calc_Method.INTERPOLATE_EXTRAPOLATE) THEN
		return getInterpolateGasMassRate(p_object_id, p_daytime);
	ELSIF (lv2_approach_method = EcDp_Calc_Method.EXTRAPOLATE) THEN
		return getExtrapolateGasMassRate(p_object_id, p_daytime);
	END IF;

END getGasStdMassRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCondStdMassRate
-- Description    : Returns the theor cond mass rate value determined by the attribute appraoch method
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getCondStdMassRate(p_object_id   well.object_id%TYPE,
                          p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS
	lv2_approach_method VARCHAR2(32);
BEGIN

	lv2_approach_method := ec_well_version.approach_method(p_object_id, p_daytime, '<=');

	IF (lv2_approach_method is NULL) or (lv2_approach_method = EcDp_Calc_Method.STEPPED) THEN
		return getLastCondStdMassRate(p_object_id, p_daytime);
	ELSIF (lv2_approach_method = EcDp_Calc_Method.INTERPOLATE_EXTRAPOLATE) THEN
		return getInterpolateCondmassRate(p_object_id, p_daytime);
	ELSIF (lv2_approach_method = EcDp_Calc_Method.EXTRAPOLATE) THEN
		return getExtrapolateCondMassRate(p_object_id, p_daytime);
	END IF;

END getCondStdMassRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWatStdMassRate
-- Description    : Returns the theor wat mass rate value determined by the attribute appraoch method
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getWatStdMassRate(p_object_id   well.object_id%TYPE,
                          p_daytime     DATE)
RETURN NUMBER
--</EC-DOC>
IS
	lv2_approach_method VARCHAR2(32);
BEGIN

	lv2_approach_method := ec_well_version.approach_method(p_object_id, p_daytime, '<=');

	IF (lv2_approach_method is NULL) or (lv2_approach_method = EcDp_Calc_Method.STEPPED) THEN
		return getLastWatStdMassRate(p_object_id, p_daytime);
	ELSIF (lv2_approach_method = EcDp_Calc_Method.INTERPOLATE_EXTRAPOLATE) THEN
		return getInterpolateWatMassRate(p_object_id, p_daytime);
	ELSIF (lv2_approach_method = EcDp_Calc_Method.EXTRAPOLATE) THEN
		return getExtrapolateWatMassRate(p_object_id, p_daytime);
	END IF;

END getWatStdMassRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getInterpolateOilRate
-- Description    : Returns the intepolated oil rate value determined by the attribute appraoch method
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getInterpolateOilRate (p_object_id well.object_id%TYPE, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS
	ln_rate_1 NUMBER;
	ln_rate_2 NUMBER;
	ld_daytime_1 DATE;
	ld_daytime_2 DATE;
	ln_result_no_1 NUMBER;
	ln_result_no_2 NUMBER;
	ln_reset_trend_check_1 NUMBER;
	ln_reset_trend_check_2 NUMBER;

	-- cursor to check if there's any reset trend avalaible at any daytime > ln_daytime_1 and < p_datime
	CURSOR c_check_reset_trend_1 (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_1 DATE) IS
		select pt.result_no from pwel_result pw, ptst_result pt where
			pt.result_no = pw.result_no and
			pw.object_id = cp_object_id and
			pt.valid_from_date > cp_daytime_1 and
			pt.valid_from_date < cp_daytime and
			pw.trend_reset_ind = 'Y';



	-- cursor to check if there's any reset trend avalaible at any daytime <= ln_daytime_2 and > p_datime
	CURSOR c_check_reset_trend_2 (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_2 DATE) IS
		select pt.result_no from pwel_result pw, ptst_result pt where
			pt.result_no = pw.result_no and
			pw.object_id = cp_object_id and
			pt.valid_from_date <= cp_daytime_2 and
			pt.valid_from_date > cp_daytime and
			pw.trend_reset_ind = 'Y';

BEGIN


	ln_result_no_1 := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id, p_daytime);
	ln_result_no_2 := EcDp_Performance_Test.getNextValidWellResultNo(p_object_id, p_daytime);

	ln_rate_1 := EcDp_Well_Estimate.getLastOilStdRate(p_object_id, p_daytime);
	ln_rate_2 := EcDp_Well_Estimate.getNextOilStdRate(p_object_id, p_daytime);

	ld_daytime_1 := ec_ptst_result.valid_from_date(ln_result_no_1);
	ld_daytime_2 := ec_ptst_result.valid_from_date(ln_result_no_2);

	FOR my_cur IN c_check_reset_trend_1 (p_object_id, p_daytime, ld_daytime_1) LOOP
		ln_reset_trend_check_1 := my_cur.result_no;
	END LOOP;

	FOR my_cur2 IN c_check_reset_trend_2 (p_object_id, p_daytime, ld_daytime_2) LOOP
		ln_reset_trend_check_2 := my_cur2.result_no;
	END LOOP;

	-- if theres no performance reference point 1 and there's a reset trend at any date > daytime_1 and <= production day, then return null
	IF (ln_rate_1 IS NULL) OR (ln_reset_trend_check_1 is NOT NULL) THEN

		return NULL;
  ELSE
		-- if there's no performance reference point 2 and there's a reset trend at a date where date > production day and <= daytime_2
		IF (ln_rate_2 IS NULL) OR (ln_reset_trend_check_2 is NOT NULL) THEN

			return EcDp_Well_Estimate.getExtrapolateOilRate(p_object_id, p_daytime);

		ELSE
			-- if all the rules are fulfilled, start interpolate
			IF ld_daytime_1 IS NULL OR ld_daytime_2 IS NULL THEN
			   -- Cannot interpolate, return NULL. Should never happen!
			   RETURN NULL;
			ELSIF ld_daytime_1=ld_daytime_2 THEN
			   -- Exact hit on a daytime, no need for interpolation!
			   RETURN ln_rate_1;
			ELSE
			   -- Linear interpolation
			   RETURN ln_rate_1+(to_char(p_daytime,'J')-to_char(ld_daytime_1, 'J'))*(ln_rate_2-ln_rate_1)/(ld_daytime_2-ld_daytime_1);
		  END IF;
		END IF;
	END IF;

END getInterpolateOilRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getExtrapolateOilRate
-- Description    : Returns the extrapolated oil rate value determined by the attribute appraoch method
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getExtrapolateOilRate (p_object_id well.object_id%TYPE, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS
	ln_rate_1 NUMBER;
	ln_rate_2 NUMBER;
	ld_daytime_1 DATE;
	ld_daytime_2 DATE;
	ln_result_no_1 NUMBER;
	ln_result_no_2 NUMBER;
	ln_reset_trend_check_1 NUMBER;
	ln_reset_trend_check_2 NUMBER;
	ln_temp NUMBER;
	ln_oil_trend_c2 NUMBER;
  ln_debug VARCHAR2(3000);

	-- cursor to check if there's any reset trend avalaible at any daytime > ln_daytime_1 and < p_datime
	CURSOR c_check_reset_trend_1 (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_1 DATE) IS
		select pt.result_no from pwel_result pw, ptst_result pt where
			pt.result_no = pw.result_no and
			pw.object_id = cp_object_id and
			pt.valid_from_date > cp_daytime_1 and
			pt.valid_from_date < cp_daytime and
			pw.trend_reset_ind = 'Y';

		-- cursor to check if there's any reset trend avalaible at any daytime <= ln_daytime_2 and > p_datime
	CURSOR c_check_reset_trend_2 (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_2 DATE) IS
		select pt.result_no from pwel_result pw, ptst_result pt where
			pt.result_no = pw.result_no and
			pw.object_id = cp_object_id and
			pt.valid_from_date <= cp_daytime_2 and
			pt.valid_from_date > cp_daytime and
			pw.trend_reset_ind = 'Y';

BEGIN

	ln_result_no_1 := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id, p_daytime);
	ln_result_no_2 := EcDp_Performance_Test.getNextValidWellResultNo(p_object_id, p_daytime);

	ln_rate_1 := EcDp_Well_Estimate.getLastOilStdRate(p_object_id, p_daytime);
	ln_rate_2 := EcDp_Well_Estimate.getNextOilStdRate(p_object_id, p_daytime);

	ld_daytime_1 := ec_ptst_result.valid_from_date(ln_result_no_1);
	ld_daytime_2 := ec_ptst_result.valid_from_date(ln_result_no_2);

	ln_oil_trend_c2 := EcDp_Performance_Test.findOilConstantC2(p_object_id, p_daytime);

	FOR my_cur IN c_check_reset_trend_1 (p_object_id, p_daytime, ld_daytime_1) LOOP
		ln_reset_trend_check_1 := my_cur.result_no;
	END LOOP;

	FOR my_cur2 IN c_check_reset_trend_2 (p_object_id, p_daytime, ld_daytime_2) LOOP
		ln_reset_trend_check_2 := my_cur2.result_no;
	END LOOP;

	-- if theres no performance reference point 1 and there's no reset trend at any date > daytime_1 and <= production day, then return null
	IF (ln_rate_1 IS NULL) OR (ln_reset_trend_check_1 is NOT NULL) THEN

		return NULL;
  ELSE
		-- if theres no performance reference point 2 and there's a reset trend at a date where production day < date < daytime_2 then extrapolate
		IF (ln_rate_2 IS NULL) OR ((ln_rate_2 IS NOT NULL) AND (ln_reset_trend_check_2 IS NOT NULL)) THEN
			ln_temp := (to_char(p_daytime, 'J') - to_char(ld_daytime_1, 'J'))/30;
			return ln_rate_1 * power((1 + ln_oil_trend_c2 / 100), ln_temp);
		ELSIF (ln_rate_2 IS NOT NULL) AND (ln_reset_trend_check_2 IS NULL)THEN
      			return ln_rate_1;
		ELSE
			return NULL;
		END IF;
	END IF;

END getExtrapolateOilRate;


-- getInterpolateGasRate
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getInterpolateGasRate
-- Description    : Returns the intepolated gas rate value determined by the attribute appraoch method
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getInterpolateGasRate (p_object_id well.object_id%TYPE, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS
	ln_rate_1 NUMBER;
	ln_rate_2 NUMBER;
	ld_daytime_1 DATE;
	ld_daytime_2 DATE;
	ln_result_no_1 NUMBER;
	ln_result_no_2 NUMBER;
	ln_reset_trend_check_1 NUMBER;
	ln_reset_trend_check_2 NUMBER;

	-- cursor to check if there's any reset trend avalaible at any daytime > ln_daytime_1 and < p_datime
	CURSOR c_check_reset_trend_1 (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_1 DATE) IS
		select pt.result_no from pwel_result pw, ptst_result pt where
			pt.result_no = pw.result_no and
			pw.object_id = cp_object_id and
			pt.valid_from_date > cp_daytime_1 and
			pt.valid_from_date < cp_daytime and
			pw.trend_reset_ind = 'Y';

	-- cursor to check if there's any reset trend avalaible at any daytime <= ln_daytime_2 and > p_datime
	CURSOR c_check_reset_trend_2 (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_2 DATE) IS
		select pt.result_no from pwel_result pw, ptst_result pt where
			pt.result_no = pw.result_no and
			pw.object_id = cp_object_id and
			pt.valid_from_date <= cp_daytime_2 and
			pt.valid_from_date > cp_daytime and
			pw.trend_reset_ind = 'Y';

BEGIN


	ln_result_no_1 := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id, p_daytime);
	ln_result_no_2 := EcDp_Performance_Test.getNextValidWellResultNo(p_object_id, p_daytime);

	ln_rate_1 := EcDp_Well_Estimate.getLastGasStdRate(p_object_id, p_daytime);
	ln_rate_2 := EcDp_Well_Estimate.getNextGasStdRate(p_object_id, p_daytime);

	ld_daytime_1 := ec_ptst_result.valid_from_date(ln_result_no_1);
	ld_daytime_2 := ec_ptst_result.valid_from_date(ln_result_no_2);

	FOR my_cur IN c_check_reset_trend_1 (p_object_id, p_daytime, ld_daytime_1) LOOP
		ln_reset_trend_check_1 := my_cur.result_no;
	END LOOP;

	FOR my_cur2 IN c_check_reset_trend_2 (p_object_id, p_daytime, ld_daytime_2) LOOP
		ln_reset_trend_check_2 := my_cur2.result_no;
	END LOOP;

	-- if theres no performance reference point 1 and there's a reset trend at any date > daytime_1 and <= production day, then return null
	IF (ln_rate_1 IS NULL) OR (ln_reset_trend_check_1 is NOT NULL) THEN

		return NULL;
  ELSE
		-- if there's no performance reference point 2 and there's a reset trend at a date where date > production day and <= daytime_2
		IF (ln_rate_2 IS NULL) OR (ln_reset_trend_check_2 is NOT NULL) THEN

			return EcDp_Well_Estimate.getExtrapolateGasRate(p_object_id, p_daytime);

		ELSE
			-- if all the rules are fulfilled, start interpolate
			IF ld_daytime_1 IS NULL OR ld_daytime_2 IS NULL THEN
			   -- Cannot interpolate, return NULL. Should never happen!
			   RETURN NULL;
			ELSIF ld_daytime_1=ld_daytime_2 THEN
			   -- Exact hit on a daytime, no need for interpolation!
			   RETURN ln_rate_1;
			ELSE
			   -- Linear interpolation
			   RETURN ln_rate_1+(to_char(p_daytime,'J')-to_char(ld_daytime_1, 'J'))*(ln_rate_2-ln_rate_1)/(ld_daytime_2-ld_daytime_1);
		  END IF;
		END IF;
	END IF;

END getInterpolateGasRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getExtrapolateGasRate
-- Description    : Returns the extrapolated gas rate value determined by the attribute appraoch method
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getExtrapolateGasRate (p_object_id well.object_id%TYPE, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS
	ln_rate_1 NUMBER;
	ln_rate_2 NUMBER;
	ld_daytime_1 DATE;
	ld_daytime_2 DATE;
	ln_result_no_1 NUMBER;
	ln_result_no_2 NUMBER;
	ln_reset_trend_check_1 NUMBER;
	ln_reset_trend_check_2 NUMBER;
	ln_temp NUMBER;
	ln_gas_trend_c2 NUMBER;

	-- cursor to check if there's any reset trend avalaible at any daytime > ln_daytime_1 and < p_datime
	CURSOR c_check_reset_trend_1 (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_1 DATE) IS
		select pt.result_no from pwel_result pw, ptst_result pt where
			pt.result_no = pw.result_no and
			pw.object_id = cp_object_id and
			pt.valid_from_date > cp_daytime_1 and
			pt.valid_from_date < cp_daytime and
			pw.trend_reset_ind = 'Y';

		-- cursor to check if there's any reset trend avalaible at any daytime <= ln_daytime_2 and > p_datime
	CURSOR c_check_reset_trend_2 (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_2 DATE) IS
		select pt.result_no from pwel_result pw, ptst_result pt where
			pt.result_no = pw.result_no and
			pw.object_id = cp_object_id and
			pt.daytime <= cp_daytime_2 and
			pt.daytime > cp_daytime and
			pw.trend_reset_ind = 'Y';

BEGIN

	ln_result_no_1 := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id, p_daytime);
	ln_result_no_2 := EcDp_Performance_Test.getNextValidWellResultNo(p_object_id, p_daytime);

	ln_rate_1 := EcDp_Well_Estimate.getLastGasStdRate(p_object_id, p_daytime);
	ln_rate_2 := EcDp_Well_Estimate.getNextGasStdRate(p_object_id, p_daytime);

	ld_daytime_1 := ec_ptst_result.valid_from_date(ln_result_no_1);
	ld_daytime_2 := ec_ptst_result.valid_from_date(ln_result_no_2);

	ln_gas_trend_c2 := EcDp_Performance_Test.findGasConstantC2(p_object_id, p_daytime);

	FOR my_cur IN c_check_reset_trend_1 (p_object_id, p_daytime, ld_daytime_1) LOOP
		ln_reset_trend_check_1 := my_cur.result_no;
	END LOOP;

	FOR my_cur2 IN c_check_reset_trend_2 (p_object_id, p_daytime, ld_daytime_2) LOOP
		ln_reset_trend_check_2 := my_cur2.result_no;
	END LOOP;

	-- if theres no performance reference point 1 and there's no reset trend at any date > daytime_1 and <= production day, then return null
	IF (ln_rate_1 IS NULL) OR (ln_reset_trend_check_1 is NOT NULL) THEN

		return NULL;
	ELSE
		-- if theres no performance reference point 2 and there's a reset trend at a date where production day < date < daytime_2 then extrapolate
		IF (ln_rate_2 IS NULL) OR ((ln_rate_2 IS NOT NULL) AND (ln_reset_trend_check_2 IS NOT NULL)) THEN
			ln_temp := (to_char(p_daytime, 'J') - to_char(ld_daytime_1, 'J'))/30;
			return ln_rate_1 * power((1 + ln_gas_trend_c2 / 100), ln_temp);
		ELSIF (ln_rate_2 IS NOT NULL) AND (ln_reset_trend_check_2 IS NULL)THEN
      			return ln_rate_1;
		ELSE
			return NULL;
		END IF;
	END IF;

END getExtrapolateGasRate;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getInterpolateCondRate
-- Description    : Returns the intepolated cond rate value determined by the attribute appraoch method
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getInterpolateCondRate (p_object_id well.object_id%TYPE, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS
	ln_rate_1 NUMBER;
	ln_rate_2 NUMBER;
	ld_daytime_1 DATE;
	ld_daytime_2 DATE;
	ln_result_no_1 NUMBER;
	ln_result_no_2 NUMBER;
	ln_reset_trend_check_1 NUMBER;
	ln_reset_trend_check_2 NUMBER;

	-- cursor to check if there's any reset trend avalaible at any daytime > ln_daytime_1 and < p_datime
	CURSOR c_check_reset_trend_1 (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_1 DATE) IS
		select pt.result_no from pwel_result pw, ptst_result pt where
			pt.result_no = pw.result_no and
			pw.object_id = cp_object_id and
			pt.valid_from_date > cp_daytime_1 and
			pt.valid_from_date < cp_daytime and
			pw.trend_reset_ind = 'Y';



	-- cursor to check if there's any reset trend avalaible at any daytime <= ln_daytime_2 and > p_datime
	CURSOR c_check_reset_trend_2 (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_2 DATE) IS
		select pt.result_no from pwel_result pw, ptst_result pt where
			pt.result_no = pw.result_no and
			pw.object_id = cp_object_id and
			pt.valid_from_date <= cp_daytime_2 and
			pt.valid_from_date > cp_daytime and
			pw.trend_reset_ind = 'Y';

BEGIN


	ln_result_no_1 := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id, p_daytime);
	ln_result_no_2 := EcDp_Performance_Test.getNextValidWellResultNo(p_object_id, p_daytime);

	ln_rate_1 := EcDp_Well_Estimate.getLastCondStdRate(p_object_id, p_daytime);
	ln_rate_2 := EcDp_Well_Estimate.getNextCondStdRate(p_object_id, p_daytime);

	ld_daytime_1 := ec_ptst_result.valid_from_date(ln_result_no_1);
	ld_daytime_2 := ec_ptst_result.valid_from_date(ln_result_no_2);

	FOR my_cur IN c_check_reset_trend_1 (p_object_id, p_daytime, ld_daytime_1) LOOP
		ln_reset_trend_check_1 := my_cur.result_no;
	END LOOP;

	FOR my_cur2 IN c_check_reset_trend_2 (p_object_id, p_daytime, ld_daytime_2) LOOP
		ln_reset_trend_check_2 := my_cur2.result_no;
	END LOOP;

	-- if theres no performance reference point 1 and there's a reset trend at any date > daytime_1 and <= production day, then return null
	IF (ln_rate_1 IS NULL) OR (ln_reset_trend_check_1 is NOT NULL) THEN

		return NULL;
  ELSE
		-- if there's no performance reference point 2 and there's a reset trend at a date where date > production day and <= daytime_2
		IF (ln_rate_2 IS NULL) OR (ln_reset_trend_check_2 is NOT NULL) THEN

			return EcDp_Well_Estimate.getExtrapolateCondRate(p_object_id, p_daytime);

		ELSE
			-- if all the rules are fulfilled, start interpolate
			IF ld_daytime_1 IS NULL OR ld_daytime_2 IS NULL THEN
			   -- Cannot interpolate, return NULL. Should never happen!
			   RETURN NULL;
			ELSIF ld_daytime_1=ld_daytime_2 THEN
			   -- Exact hit on a daytime, no need for interpolation!
			   RETURN ln_rate_1;
			ELSE
			   -- Linear interpolation
			   RETURN ln_rate_1+(to_char(p_daytime,'J')-to_char(ld_daytime_1, 'J'))*(ln_rate_2-ln_rate_1)/(ld_daytime_2-ld_daytime_1);
		  END IF;
		END IF;
	END IF;

END getInterpolateCondRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getExtrapolateCondRate
-- Description    : Returns the extrapolated cond rate value determined by the attribute appraoch method
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getExtrapolateCondRate (p_object_id well.object_id%TYPE, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS
	ln_rate_1 NUMBER;
	ln_rate_2 NUMBER;
	ld_daytime_1 DATE;
	ld_daytime_2 DATE;
	ln_result_no_1 NUMBER;
	ln_result_no_2 NUMBER;
	ln_reset_trend_check_1 NUMBER;
	ln_reset_trend_check_2 NUMBER;
	ln_temp NUMBER;
	ln_cond_trend_c2 NUMBER;

	-- cursor to check if there's any reset trend avalaible at any daytime > ln_daytime_1 and < p_datime
	CURSOR c_check_reset_trend_1 (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_1 DATE) IS
		select pt.result_no from pwel_result pw, ptst_result pt where
			pt.result_no = pw.result_no and
			pw.object_id = cp_object_id and
			pt.valid_from_date > cp_daytime_1 and
			pt.valid_from_date < cp_daytime and
			pw.trend_reset_ind = 'Y';

		-- cursor to check if there's any reset trend avalaible at any daytime <= ln_daytime_2 and > p_datime
	CURSOR c_check_reset_trend_2 (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_2 DATE) IS
		select pt.result_no from pwel_result pw, ptst_result pt where
			pt.result_no = pw.result_no and
			pw.object_id = cp_object_id and
			pt.valid_from_date <= cp_daytime_2 and
			pt.valid_from_date > cp_daytime and
			pw.trend_reset_ind = 'Y';

BEGIN

	ln_result_no_1 := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id, p_daytime);
	ln_result_no_2 := EcDp_Performance_Test.getNextValidWellResultNo(p_object_id, p_daytime);

	ln_rate_1 := EcDp_Well_Estimate.getLastCondStdRate(p_object_id, p_daytime);
	ln_rate_2 := EcDp_Well_Estimate.getNextCondStdRate(p_object_id, p_daytime);

	ld_daytime_1 := ec_ptst_result.valid_from_date(ln_result_no_1);
	ld_daytime_2 := ec_ptst_result.valid_from_date(ln_result_no_2);

	ln_cond_trend_c2 := EcDp_Performance_Test.findCondConstantC2(p_object_id, p_daytime);

	FOR my_cur IN c_check_reset_trend_1 (p_object_id, p_daytime, ld_daytime_1) LOOP
		ln_reset_trend_check_1 := my_cur.result_no;
	END LOOP;

	FOR my_cur2 IN c_check_reset_trend_2 (p_object_id, p_daytime, ld_daytime_2) LOOP
		ln_reset_trend_check_2 := my_cur2.result_no;
	END LOOP;

	-- if theres no performance reference point 1 and there's no reset trend at any date > daytime_1 and <= production day, then return null
	IF (ln_rate_1 IS NULL) OR (ln_reset_trend_check_1 is NOT NULL) THEN

		return NULL;
	ELSE
		-- if theres no performance reference point 2 and there's a reset trend at a date where production day < date < daytime_2 then extrapolate
		IF (ln_rate_2 IS NULL) OR ((ln_rate_2 IS NOT NULL) AND (ln_reset_trend_check_2 IS NOT NULL)) THEN
			ln_temp := (to_char(p_daytime, 'J') - to_char(ld_daytime_1, 'J'))/30;
			return ln_rate_1 * power((1 + ln_cond_trend_c2 / 100), ln_temp);
		ELSIF (ln_rate_2 IS NOT NULL) AND (ln_reset_trend_check_2 IS NULL)THEN
      			return ln_rate_1;
		ELSE
			return NULL;
		END IF;
	END IF;

END getExtrapolateCondRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getInterpolateWatRate
-- Description    : Returns the intepolated wat rate value determined by the attribute appraoch method
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getInterpolateWatRate (p_object_id well.object_id%TYPE, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS
	ln_rate_1 NUMBER;
	ln_rate_2 NUMBER;
	ld_daytime_1 DATE;
	ld_daytime_2 DATE;
	ln_result_no_1 NUMBER;
	ln_result_no_2 NUMBER;
	ln_reset_trend_check_1 NUMBER;
	ln_reset_trend_check_2 NUMBER;

	-- cursor to check if there's any reset trend avalaible at any daytime > ln_daytime_1 and < p_datime
	CURSOR c_check_reset_trend_1 (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_1 DATE) IS
		select pt.result_no from pwel_result pw, ptst_result pt where
			pt.result_no = pw.result_no and
			pw.object_id = cp_object_id and
			pt.valid_from_date > cp_daytime_1 and
			pt.valid_from_date < cp_daytime and
			pw.trend_reset_ind = 'Y';



	-- cursor to check if there's any reset trend avalaible at any daytime <= ln_daytime_2 and > p_datime
	CURSOR c_check_reset_trend_2 (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_2 DATE) IS
		select pt.result_no from pwel_result pw, ptst_result pt where
			pt.result_no = pw.result_no and
			pw.object_id = cp_object_id and
			pt.valid_from_date <= cp_daytime_2 and
			pt.valid_from_date > cp_daytime and
			pw.trend_reset_ind = 'Y';

BEGIN


	ln_result_no_1 := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id, p_daytime);
	ln_result_no_2 := EcDp_Performance_Test.getNextValidWellResultNo(p_object_id, p_daytime);

	ln_rate_1 := EcDp_Well_Estimate.getLastWatStdRate(p_object_id, p_daytime);
	ln_rate_2 := EcDp_Well_Estimate.getNextWatStdRate(p_object_id, p_daytime);

	ld_daytime_1 := ec_ptst_result.valid_from_date(ln_result_no_1);
	ld_daytime_2 := ec_ptst_result.valid_from_date(ln_result_no_2);

	FOR my_cur IN c_check_reset_trend_1 (p_object_id, p_daytime, ld_daytime_1) LOOP
		ln_reset_trend_check_1 := my_cur.result_no;
	END LOOP;

	FOR my_cur2 IN c_check_reset_trend_2 (p_object_id, p_daytime, ld_daytime_2) LOOP
		ln_reset_trend_check_2 := my_cur2.result_no;
	END LOOP;

	-- if theres no performance reference point 1 and there's a reset trend at any date > daytime_1 and <= production day, then return null
	IF (ln_rate_1 IS NULL) OR (ln_reset_trend_check_1 is NOT NULL) THEN

		return NULL;

  ELSE
		-- if there's no performance reference point 2 and there's a reset trend at a date where date > production day and <= daytime_2
		IF (ln_rate_2 IS NULL) OR (ln_reset_trend_check_2 is NOT NULL) THEN

			return EcDp_Well_Estimate.getExtrapolateWatRate(p_object_id, p_daytime);

		ELSE
			-- if all the rules are fulfilled, start interpolate
			IF ld_daytime_1 IS NULL OR ld_daytime_2 IS NULL THEN
			   -- Cannot interpolate, return NULL. Should never happen!
			   RETURN NULL;
			ELSIF ld_daytime_1=ld_daytime_2 THEN
			   -- Exact hit on a daytime, no need for interpolation!
			   RETURN ln_rate_1;
			ELSE
			   -- Linear interpolation
			   RETURN ln_rate_1+(to_char(p_daytime,'J')-to_char(ld_daytime_1, 'J'))*(ln_rate_2-ln_rate_1)/(ld_daytime_2-ld_daytime_1);
		  END IF;
		END IF;
	END IF;

END getInterpolateWatRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getExtrapolateWatRate
-- Description    : Returns the extrapolated wat rate value determined by the attribute appraoch method
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getExtrapolateWatRate (p_object_id well.object_id%TYPE, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS
	ln_rate_1 NUMBER;
	ln_rate_2 NUMBER;
	ld_daytime_1 DATE;
	ld_daytime_2 DATE;
	ln_result_no_1 NUMBER;
	ln_result_no_2 NUMBER;
	ln_reset_trend_check_1 NUMBER;
	ln_reset_trend_check_2 NUMBER;
	ln_temp NUMBER;
	ln_wat_trend_c2 NUMBER;

	-- cursor to check if there's any reset trend avalaible at any daytime > ln_daytime_1 and < p_datime
	CURSOR c_check_reset_trend_1 (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_1 DATE) IS
		select pt.result_no from pwel_result pw, ptst_result pt where
			pt.result_no = pw.result_no and
			pw.object_id = cp_object_id and
			pt.valid_from_date > cp_daytime_1 and
			pt.valid_from_date < cp_daytime and
			pw.trend_reset_ind = 'Y';

		-- cursor to check if there's any reset trend avalaible at any daytime <= ln_daytime_2 and > p_datime
	CURSOR c_check_reset_trend_2 (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_2 DATE) IS
		select pt.result_no from pwel_result pw, ptst_result pt where
			pt.result_no = pw.result_no and
			pw.object_id = cp_object_id and
			pt.valid_from_date <= cp_daytime_2 and
			pt.valid_from_date > cp_daytime and
			pw.trend_reset_ind = 'Y';

BEGIN

	ln_result_no_1 := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id, p_daytime);
	ln_result_no_2 := EcDp_Performance_Test.getNextValidWellResultNo(p_object_id, p_daytime);

	ln_rate_1 := EcDp_Well_Estimate.getLastWatStdRate(p_object_id, p_daytime);
	ln_rate_2 := EcDp_Well_Estimate.getNextWatStdRate(p_object_id, p_daytime);

	ld_daytime_1 := ec_ptst_result.valid_from_date(ln_result_no_1);
	ld_daytime_2 := ec_ptst_result.valid_from_date(ln_result_no_2);

	ln_wat_trend_c2 := EcDp_Performance_Test.findWatConstantC2(p_object_id, p_daytime);

	FOR my_cur IN c_check_reset_trend_1 (p_object_id, p_daytime, ld_daytime_1) LOOP
		ln_reset_trend_check_1 := my_cur.result_no;
	END LOOP;

	FOR my_cur2 IN c_check_reset_trend_2 (p_object_id, p_daytime, ld_daytime_2) LOOP
		ln_reset_trend_check_2 := my_cur2.result_no;
	END LOOP;

	-- if theres no performance reference point 1 and there's no reset trend at any date > daytime_1 and <= production day, then return null
	IF (ln_rate_1 IS NULL) OR (ln_reset_trend_check_1 is NOT NULL) THEN

		return NULL;
	ELSE
		-- if theres no performance reference point 2 and there's a reset trend at a date where production day < date < daytime_2 then extrapolate
		IF (ln_rate_2 IS NULL) OR ((ln_rate_2 IS NOT NULL) AND (ln_reset_trend_check_2 IS NOT NULL)) THEN
			ln_temp := (to_char(p_daytime, 'J') - to_char(ld_daytime_1, 'J'))/30;
			return ln_rate_1 * power((1 + ln_wat_trend_c2 / 100), ln_temp);
		ELSIF (ln_rate_2 IS NOT NULL) AND (ln_reset_trend_check_2 IS NULL)THEN
      			return ln_rate_1;
		ELSE
			return NULL;
		END IF;
	END IF;

END getExtrapolateWatRate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getInterpolatedOilProdPot
-- Description    : Returns the oil production potential calculated from
--                  interpolating the last 2 valid well tests.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   : ptst_result, pwel_result
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : This function may be replaced by or use the getInterPolateOilRate function.
---------------------------------------------------------------------------------------------------
FUNCTION getInterpolatedOilProdPot (
	p_object_id well.object_id%TYPE,
   p_daytime  DATE)
RETURN NUMBER
--</EC-DOC>
IS

CURSOR well_potential_cur(cp_object_id VARCHAR2) IS
SELECT to_char(s.valid_from_date,'J') x_julian, wr.net_oil_rate_adj   potential
FROM ptst_result s, pwel_result wr
   WHERE wr.object_id = cp_object_id
   AND wr.result_no = s.result_no
ORDER BY 1 DESC;

ln_prev_potential NUMBER;
ln_xtra_potential NUMBER;
ln_potential1 NUMBER;
ln_potential2 NUMBER;
ln_x_julian NUMBER;
ln_prev_x_julian NUMBER;
ln_x1 NUMBER;
ln_x2 NUMBER;
ln_xtra NUMBER;

ln_return_val NUMBER;

BEGIN

   ln_x_julian := to_char(p_daytime,'J');

   FOR WellPotentialCur IN well_potential_cur(p_object_id) LOOP

      IF WellPotentialCur.x_julian = ln_x_julian THEN
                ln_return_val := WellPotentialCur.potential; -- got it
                RETURN ln_return_val;
      ELSIF WellPotentialCur.x_julian > ln_x_julian THEN
                ln_potential2 := WellPotentialCur.potential;
                ln_x2 := WellPotentialCur.x_julian;
                ln_potential1 := ln_prev_potential;
                ln_x1 := ln_prev_x_julian;
      ELSE
                IF ln_x2 IS NULL THEN
                        -- Avoid extrapolation when date later than latest well test (specific change request)
                        ln_return_val := WellPotentialCur.potential;
                        RETURN ln_return_val;
                ELSE
                        ln_potential2 := WellPotentialCur.potential;
                        ln_x2 := WellPotentialCur.x_julian;
                        ln_potential1 := ln_prev_potential;
                        ln_x1 := ln_prev_x_julian;

                        EXIT; -- got two points, interpolate !
                END IF;
      END IF;
      ln_prev_potential := WellPotentialCur.potential;
      ln_prev_x_julian := WellPotentialCur.x_julian;
   END LOOP;
   IF ln_xtra IS NOT NULL THEN -- perform extrapolation
        ln_return_val := Greatest( 0 , EcBp_Mathlib.interpolateLinear(to_char(p_daytime,'J'), ln_x1,ln_xtra,ln_potential1,ln_xtra_potential) );
        RETURN ln_return_val;
   ELSIF ln_x2 IS NULL AND ln_x1 IS NULL THEN
      RETURN NULL;
   ELSIF ln_x2 IS NOT NULL AND (ln_x_julian < ln_x2) THEN -- this case may incur before the well has started production
      RETURN NULL;
   ELSIF ln_x2 IS NOT NULL AND ln_x1 IS NOT NULL THEN
      ln_return_val := EcBp_Mathlib.interpolateLinear(to_char(p_daytime,'J'), ln_x1,ln_x2,ln_potential1,ln_potential2);
      RETURN ln_return_val ;
   ELSE
      ln_return_val := Nvl(ln_x2,ln_x1);
      RETURN  ln_return_val;
   END IF;

   RETURN  NULL; -- nothing found

END getInterpolatedOilProdPot;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getInterpolateOilMassRate
-- Description    : Returns the intepolated oil mass rate value determined by the attribute approach method
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getInterpolateOilMassRate (p_object_id well.object_id%TYPE, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS
	ln_rate_1 NUMBER;
	ln_rate_2 NUMBER;
	ld_daytime_1 DATE;
	ld_daytime_2 DATE;
	ln_result_no_1 NUMBER;
	ln_result_no_2 NUMBER;
	ln_reset_trend_check_1 NUMBER;
	ln_reset_trend_check_2 NUMBER;

	-- cursor to check if there's any reset trend avalaible at any daytime > ln_daytime_1 and < p_datime
	CURSOR c_check_reset_trend_1 (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_1 DATE) IS
		select pt.result_no from pwel_result pw, ptst_result pt where
			pt.result_no = pw.result_no and
			pw.object_id = cp_object_id and
			pt.valid_from_date > cp_daytime_1 and
			pt.valid_from_date < cp_daytime and
			pw.trend_reset_ind = 'Y';



	-- cursor to check if there's any reset trend avalaible at any daytime <= ln_daytime_2 and > p_datime
	CURSOR c_check_reset_trend_2 (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_2 DATE) IS
		select pt.result_no from pwel_result pw, ptst_result pt where
			pt.result_no = pw.result_no and
			pw.object_id = cp_object_id and
			pt.valid_from_date <= cp_daytime_2 and
			pt.valid_from_date > cp_daytime and
			pw.trend_reset_ind = 'Y';

BEGIN


	ln_result_no_1 := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id, p_daytime);
	ln_result_no_2 := EcDp_Performance_Test.getNextValidWellResultNo(p_object_id, p_daytime);

	ln_rate_1 := EcDp_Well_Estimate.getLastOilStdMassRate(p_object_id, p_daytime);
	ln_rate_2 := EcDp_Well_Estimate.getNextOilStdMassRate(p_object_id, p_daytime);

	ld_daytime_1 := ec_ptst_result.valid_from_date(ln_result_no_1);
	ld_daytime_2 := ec_ptst_result.valid_from_date(ln_result_no_2);

	FOR my_cur IN c_check_reset_trend_1 (p_object_id, p_daytime, ld_daytime_1) LOOP
		ln_reset_trend_check_1 := my_cur.result_no;
	END LOOP;

	FOR my_cur2 IN c_check_reset_trend_2 (p_object_id, p_daytime, ld_daytime_2) LOOP
		ln_reset_trend_check_2 := my_cur2.result_no;
	END LOOP;

	-- if theres no performance reference point 1 and there's a reset trend at any date > daytime_1 and <= production day, then return null
	IF (ln_rate_1 IS NULL) OR (ln_reset_trend_check_1 is NOT NULL) THEN

		return NULL;
  ELSE
		-- if there's no performance reference point 2 and there's a reset trend at a date where date > production day and <= daytime_2
		IF (ln_rate_2 IS NULL) OR (ln_reset_trend_check_2 is NOT NULL) THEN

			return EcDp_Well_Estimate.getExtrapolateOilMassRate(p_object_id, p_daytime);

		ELSE
			-- if all the rules are fulfilled, start interpolate
			IF ld_daytime_1 IS NULL OR ld_daytime_2 IS NULL THEN
			   -- Cannot interpolate, return NULL. Should never happen!
			   RETURN NULL;
			ELSIF ld_daytime_1=ld_daytime_2 THEN
			   -- Exact hit on a daytime, no need for interpolation!
			   RETURN ln_rate_1;
			ELSE
			   -- Linear interpolation
			   RETURN ln_rate_1+(to_char(p_daytime,'J')-to_char(ld_daytime_1, 'J'))*(ln_rate_2-ln_rate_1)/(ld_daytime_2-ld_daytime_1);
		  END IF;
		END IF;
	END IF;

END getInterpolateOilMassRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getExtrapolateOilMassRate
-- Description    : Returns the extrapolated oil mass rate value determined by the attribute appraoch method
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getExtrapolateOilMassRate (p_object_id well.object_id%TYPE, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS
	ln_rate_1 NUMBER;
	ln_rate_2 NUMBER;
	ld_daytime_1 DATE;
	ld_daytime_2 DATE;
	ln_result_no_1 NUMBER;
	ln_result_no_2 NUMBER;
	ln_reset_trend_check_1 NUMBER;
	ln_reset_trend_check_2 NUMBER;
	ln_temp NUMBER;
	ln_oil_trend_c2 NUMBER;
  ln_debug VARCHAR2(3000);

	-- cursor to check if there's any reset trend avalaible at any daytime > ln_daytime_1 and < p_datime
	CURSOR c_check_reset_trend_1 (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_1 DATE) IS
		select pt.result_no from pwel_result pw, ptst_result pt where
			pt.result_no = pw.result_no and
			pw.object_id = cp_object_id and
			pt.valid_from_date > cp_daytime_1 and
			pt.valid_from_date < cp_daytime and
			pw.trend_reset_ind = 'Y';

		-- cursor to check if there's any reset trend avalaible at any daytime <= ln_daytime_2 and > p_datime
	CURSOR c_check_reset_trend_2 (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_2 DATE) IS
		select pt.result_no from pwel_result pw, ptst_result pt where
			pt.result_no = pw.result_no and
			pw.object_id = cp_object_id and
			pt.valid_from_date <= cp_daytime_2 and
			pt.valid_from_date > cp_daytime and
			pw.trend_reset_ind = 'Y';

BEGIN

	ln_result_no_1 := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id, p_daytime);
	ln_result_no_2 := EcDp_Performance_Test.getNextValidWellResultNo(p_object_id, p_daytime);

	ln_rate_1 := EcDp_Well_Estimate.getLastOilStdMassRate(p_object_id, p_daytime);
	ln_rate_2 := EcDp_Well_Estimate.getNextOilStdMassRate(p_object_id, p_daytime);

	ld_daytime_1 := ec_ptst_result.valid_from_date(ln_result_no_1);
	ld_daytime_2 := ec_ptst_result.valid_from_date(ln_result_no_2);

	ln_oil_trend_c2 := EcDp_Performance_Test.findOilConstantC2(p_object_id, p_daytime);

	FOR my_cur IN c_check_reset_trend_1 (p_object_id, p_daytime, ld_daytime_1) LOOP
		ln_reset_trend_check_1 := my_cur.result_no;
	END LOOP;

	FOR my_cur2 IN c_check_reset_trend_2 (p_object_id, p_daytime, ld_daytime_2) LOOP
		ln_reset_trend_check_2 := my_cur2.result_no;
	END LOOP;

	-- if theres no performance reference point 1 and there's no reset trend at any date > daytime_1 and <= production day, then return null
	IF (ln_rate_1 IS NULL) OR (ln_reset_trend_check_1 is NOT NULL) THEN

		return NULL;
  ELSE
		-- if theres no performance reference point 2 and there's a reset trend at a date where production day < date < daytime_2 then extrapolate
		IF (ln_rate_2 IS NULL) OR ((ln_rate_2 IS NOT NULL) AND (ln_reset_trend_check_2 IS NOT NULL)) THEN
			ln_temp := (to_char(p_daytime, 'J') - to_char(ld_daytime_1, 'J'))/30;
			return ln_rate_1 * power((1 + ln_oil_trend_c2 / 100), ln_temp);
		ELSIF (ln_rate_2 IS NOT NULL) AND (ln_reset_trend_check_2 IS NULL)THEN
      			return ln_rate_1;
		ELSE
			return NULL;
		END IF;
	END IF;

END getExtrapolateOilMassRate;


-- getInterpolateGasMassRate
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getInterpolateGasMassRate
-- Description    : Returns the intepolated gas mass rate value determined by the attribute appraoch method
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getInterpolateGasMassRate (p_object_id well.object_id%TYPE, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS
	ln_rate_1 NUMBER;
	ln_rate_2 NUMBER;
	ld_daytime_1 DATE;
	ld_daytime_2 DATE;
	ln_result_no_1 NUMBER;
	ln_result_no_2 NUMBER;
	ln_reset_trend_check_1 NUMBER;
	ln_reset_trend_check_2 NUMBER;

	-- cursor to check if there's any reset trend avalaible at any daytime > ln_daytime_1 and < p_datime
	CURSOR c_check_reset_trend_1 (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_1 DATE) IS
		select pt.result_no from pwel_result pw, ptst_result pt where
			pt.result_no = pw.result_no and
			pw.object_id = cp_object_id and
			pt.valid_from_date > cp_daytime_1 and
			pt.valid_from_date < cp_daytime and
			pw.trend_reset_ind = 'Y';

	-- cursor to check if there's any reset trend avalaible at any daytime <= ln_daytime_2 and > p_datime
	CURSOR c_check_reset_trend_2 (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_2 DATE) IS
		select pt.result_no from pwel_result pw, ptst_result pt where
			pt.result_no = pw.result_no and
			pw.object_id = cp_object_id and
			pt.valid_from_date <= cp_daytime_2 and
			pt.valid_from_date > cp_daytime and
			pw.trend_reset_ind = 'Y';

BEGIN


	ln_result_no_1 := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id, p_daytime);
	ln_result_no_2 := EcDp_Performance_Test.getNextValidWellResultNo(p_object_id, p_daytime);

	ln_rate_1 := EcDp_Well_Estimate.getLastGasStdMassRate(p_object_id, p_daytime);
	ln_rate_2 := EcDp_Well_Estimate.getNextGasStdMassRate(p_object_id, p_daytime);

	ld_daytime_1 := ec_ptst_result.valid_from_date(ln_result_no_1);
	ld_daytime_2 := ec_ptst_result.valid_from_date(ln_result_no_2);

	FOR my_cur IN c_check_reset_trend_1 (p_object_id, p_daytime, ld_daytime_1) LOOP
		ln_reset_trend_check_1 := my_cur.result_no;
	END LOOP;

	FOR my_cur2 IN c_check_reset_trend_2 (p_object_id, p_daytime, ld_daytime_2) LOOP
		ln_reset_trend_check_2 := my_cur2.result_no;
	END LOOP;

	-- if theres no performance reference point 1 and there's a reset trend at any date > daytime_1 and <= production day, then return null
	IF (ln_rate_1 IS NULL) OR (ln_reset_trend_check_1 is NOT NULL) THEN

		return NULL;
  ELSE
		-- if there's no performance reference point 2 and there's a reset trend at a date where date > production day and <= daytime_2
		IF (ln_rate_2 IS NULL) OR (ln_reset_trend_check_2 is NOT NULL) THEN

			return EcDp_Well_Estimate.getExtrapolateGasMassRate(p_object_id, p_daytime);

		ELSE
			-- if all the rules are fulfilled, start interpolate
			IF ld_daytime_1 IS NULL OR ld_daytime_2 IS NULL THEN
			   -- Cannot interpolate, return NULL. Should never happen!
			   RETURN NULL;
			ELSIF ld_daytime_1=ld_daytime_2 THEN
			   -- Exact hit on a daytime, no need for interpolation!
			   RETURN ln_rate_1;
			ELSE
			   -- Linear interpolation
			   RETURN ln_rate_1+(to_char(p_daytime,'J')-to_char(ld_daytime_1, 'J'))*(ln_rate_2-ln_rate_1)/(ld_daytime_2-ld_daytime_1);
		  END IF;
		END IF;
	END IF;

END getInterpolateGasMassRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getExtrapolateGasMassRate
-- Description    : Returns the extrapolated gas mass rate value determined by the attribute appraoch method
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getExtrapolateGasMassRate (p_object_id well.object_id%TYPE, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS
	ln_rate_1 NUMBER;
	ln_rate_2 NUMBER;
	ld_daytime_1 DATE;
	ld_daytime_2 DATE;
	ln_result_no_1 NUMBER;
	ln_result_no_2 NUMBER;
	ln_reset_trend_check_1 NUMBER;
	ln_reset_trend_check_2 NUMBER;
	ln_temp NUMBER;
	ln_gas_trend_c2 NUMBER;

	-- cursor to check if there's any reset trend avalaible at any daytime > ln_daytime_1 and < p_datime
	CURSOR c_check_reset_trend_1 (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_1 DATE) IS
		select pt.result_no from pwel_result pw, ptst_result pt where
			pt.result_no = pw.result_no and
			pw.object_id = cp_object_id and
			pt.valid_from_date > cp_daytime_1 and
			pt.valid_from_date < cp_daytime and
			pw.trend_reset_ind = 'Y';

		-- cursor to check if there's any reset trend avalaible at any daytime <= ln_daytime_2 and > p_datime
	CURSOR c_check_reset_trend_2 (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_2 DATE) IS
		select pt.result_no from pwel_result pw, ptst_result pt where
			pt.result_no = pw.result_no and
			pw.object_id = cp_object_id and
			pt.daytime <= cp_daytime_2 and
			pt.daytime > cp_daytime and
			pw.trend_reset_ind = 'Y';

BEGIN

	ln_result_no_1 := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id, p_daytime);
	ln_result_no_2 := EcDp_Performance_Test.getNextValidWellResultNo(p_object_id, p_daytime);

	ln_rate_1 := EcDp_Well_Estimate.getLastGasStdMassRate(p_object_id, p_daytime);
	ln_rate_2 := EcDp_Well_Estimate.getNextGasStdMassRate(p_object_id, p_daytime);

	ld_daytime_1 := ec_ptst_result.valid_from_date(ln_result_no_1);
	ld_daytime_2 := ec_ptst_result.valid_from_date(ln_result_no_2);

	ln_gas_trend_c2 := EcDp_Performance_Test.findGasConstantC2(p_object_id, p_daytime);

	FOR my_cur IN c_check_reset_trend_1 (p_object_id, p_daytime, ld_daytime_1) LOOP
		ln_reset_trend_check_1 := my_cur.result_no;
	END LOOP;

	FOR my_cur2 IN c_check_reset_trend_2 (p_object_id, p_daytime, ld_daytime_2) LOOP
		ln_reset_trend_check_2 := my_cur2.result_no;
	END LOOP;

	-- if theres no performance reference point 1 and there's no reset trend at any date > daytime_1 and <= production day, then return null
	IF (ln_rate_1 IS NULL) OR (ln_reset_trend_check_1 is NOT NULL) THEN

		return NULL;
	ELSE
		-- if theres no performance reference point 2 and there's a reset trend at a date where production day < date < daytime_2 then extrapolate
		IF (ln_rate_2 IS NULL) OR ((ln_rate_2 IS NOT NULL) AND (ln_reset_trend_check_2 IS NOT NULL)) THEN
			ln_temp := (to_char(p_daytime, 'J') - to_char(ld_daytime_1, 'J'))/30;
			return ln_rate_1 * power((1 + ln_gas_trend_c2 / 100), ln_temp);
		ELSIF (ln_rate_2 IS NOT NULL) AND (ln_reset_trend_check_2 IS NULL)THEN
      			return ln_rate_1;
		ELSE
			return NULL;
		END IF;
	END IF;

END getExtrapolateGasMassRate;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getInterpolateCondMassRate
-- Description    : Returns the intepolated cond mass rate value determined by the attribute appraoch method
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getInterpolateCondMassRate (p_object_id well.object_id%TYPE, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS
	ln_rate_1 NUMBER;
	ln_rate_2 NUMBER;
	ld_daytime_1 DATE;
	ld_daytime_2 DATE;
	ln_result_no_1 NUMBER;
	ln_result_no_2 NUMBER;
	ln_reset_trend_check_1 NUMBER;
	ln_reset_trend_check_2 NUMBER;

	-- cursor to check if there's any reset trend avalaible at any daytime > ln_daytime_1 and < p_datime
	CURSOR c_check_reset_trend_1 (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_1 DATE) IS
		select pt.result_no from pwel_result pw, ptst_result pt where
			pt.result_no = pw.result_no and
			pw.object_id = cp_object_id and
			pt.valid_from_date > cp_daytime_1 and
			pt.valid_from_date < cp_daytime and
			pw.trend_reset_ind = 'Y';



	-- cursor to check if there's any reset trend avalaible at any daytime <= ln_daytime_2 and > p_datime
	CURSOR c_check_reset_trend_2 (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_2 DATE) IS
		select pt.result_no from pwel_result pw, ptst_result pt where
			pt.result_no = pw.result_no and
			pw.object_id = cp_object_id and
			pt.valid_from_date <= cp_daytime_2 and
			pt.valid_from_date > cp_daytime and
			pw.trend_reset_ind = 'Y';

BEGIN


	ln_result_no_1 := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id, p_daytime);
	ln_result_no_2 := EcDp_Performance_Test.getNextValidWellResultNo(p_object_id, p_daytime);

	ln_rate_1 := EcDp_Well_Estimate.getLastCondStdMassRate(p_object_id, p_daytime);
	ln_rate_2 := EcDp_Well_Estimate.getNextCondStdMassRate(p_object_id, p_daytime);

	ld_daytime_1 := ec_ptst_result.valid_from_date(ln_result_no_1);
	ld_daytime_2 := ec_ptst_result.valid_from_date(ln_result_no_2);

	FOR my_cur IN c_check_reset_trend_1 (p_object_id, p_daytime, ld_daytime_1) LOOP
		ln_reset_trend_check_1 := my_cur.result_no;
	END LOOP;

	FOR my_cur2 IN c_check_reset_trend_2 (p_object_id, p_daytime, ld_daytime_2) LOOP
		ln_reset_trend_check_2 := my_cur2.result_no;
	END LOOP;

	-- if theres no performance reference point 1 and there's a reset trend at any date > daytime_1 and <= production day, then return null
	IF (ln_rate_1 IS NULL) OR (ln_reset_trend_check_1 is NOT NULL) THEN

		return NULL;
  ELSE
		-- if there's no performance reference point 2 and there's a reset trend at a date where date > production day and <= daytime_2
		IF (ln_rate_2 IS NULL) OR (ln_reset_trend_check_2 is NOT NULL) THEN

			return EcDp_Well_Estimate.getExtrapolateCondMassRate(p_object_id, p_daytime);

		ELSE
			-- if all the rules are fulfilled, start interpolate
			IF ld_daytime_1 IS NULL OR ld_daytime_2 IS NULL THEN
			   -- Cannot interpolate, return NULL. Should never happen!
			   RETURN NULL;
			ELSIF ld_daytime_1=ld_daytime_2 THEN
			   -- Exact hit on a daytime, no need for interpolation!
			   RETURN ln_rate_1;
			ELSE
			   -- Linear interpolation
			   RETURN ln_rate_1+(to_char(p_daytime,'J')-to_char(ld_daytime_1, 'J'))*(ln_rate_2-ln_rate_1)/(ld_daytime_2-ld_daytime_1);
		  END IF;
		END IF;
	END IF;

END getInterpolateCondMassRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getExtrapolateCondMassRate
-- Description    : Returns the extrapolated cond mass rate value determined by the attribute appraoch method
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getExtrapolateCondMassRate (p_object_id well.object_id%TYPE, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS
	ln_rate_1 NUMBER;
	ln_rate_2 NUMBER;
	ld_daytime_1 DATE;
	ld_daytime_2 DATE;
	ln_result_no_1 NUMBER;
	ln_result_no_2 NUMBER;
	ln_reset_trend_check_1 NUMBER;
	ln_reset_trend_check_2 NUMBER;
	ln_temp NUMBER;
	ln_cond_trend_c2 NUMBER;

	-- cursor to check if there's any reset trend avalaible at any daytime > ln_daytime_1 and < p_datime
	CURSOR c_check_reset_trend_1 (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_1 DATE) IS
		select pt.result_no from pwel_result pw, ptst_result pt where
			pt.result_no = pw.result_no and
			pw.object_id = cp_object_id and
			pt.valid_from_date > cp_daytime_1 and
			pt.valid_from_date < cp_daytime and
			pw.trend_reset_ind = 'Y';

		-- cursor to check if there's any reset trend avalaible at any daytime <= ln_daytime_2 and > p_datime
	CURSOR c_check_reset_trend_2 (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_2 DATE) IS
		select pt.result_no from pwel_result pw, ptst_result pt where
			pt.result_no = pw.result_no and
			pw.object_id = cp_object_id and
			pt.valid_from_date <= cp_daytime_2 and
			pt.valid_from_date > cp_daytime and
			pw.trend_reset_ind = 'Y';

BEGIN

	ln_result_no_1 := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id, p_daytime);
	ln_result_no_2 := EcDp_Performance_Test.getNextValidWellResultNo(p_object_id, p_daytime);

	ln_rate_1 := EcDp_Well_Estimate.getLastCondStdMassRate(p_object_id, p_daytime);
	ln_rate_2 := EcDp_Well_Estimate.getNextCondStdMassRate(p_object_id, p_daytime);

	ld_daytime_1 := ec_ptst_result.valid_from_date(ln_result_no_1);
	ld_daytime_2 := ec_ptst_result.valid_from_date(ln_result_no_2);

	ln_cond_trend_c2 := EcDp_Performance_Test.findCondConstantC2(p_object_id, p_daytime);

	FOR my_cur IN c_check_reset_trend_1 (p_object_id, p_daytime, ld_daytime_1) LOOP
		ln_reset_trend_check_1 := my_cur.result_no;
	END LOOP;

	FOR my_cur2 IN c_check_reset_trend_2 (p_object_id, p_daytime, ld_daytime_2) LOOP
		ln_reset_trend_check_2 := my_cur2.result_no;
	END LOOP;

	-- if theres no performance reference point 1 and there's no reset trend at any date > daytime_1 and <= production day, then return null
	IF (ln_rate_1 IS NULL) OR (ln_reset_trend_check_1 is NOT NULL) THEN

		return NULL;
	ELSE
		-- if theres no performance reference point 2 and there's a reset trend at a date where production day < date < daytime_2 then extrapolate
		IF (ln_rate_2 IS NULL) OR ((ln_rate_2 IS NOT NULL) AND (ln_reset_trend_check_2 IS NOT NULL)) THEN
			ln_temp := (to_char(p_daytime, 'J') - to_char(ld_daytime_1, 'J'))/30;
			return ln_rate_1 * power((1 + ln_cond_trend_c2 / 100), ln_temp);
		ELSIF (ln_rate_2 IS NOT NULL) AND (ln_reset_trend_check_2 IS NULL)THEN
      			return ln_rate_1;
		ELSE
			return NULL;
		END IF;
	END IF;

END getExtrapolateCondMassRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getInterpolateWatMassRate
-- Description    : Returns the intepolated wat mass rate value determined by the attribute appraoch method
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getInterpolateWatMassRate (p_object_id well.object_id%TYPE, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS
	ln_rate_1 NUMBER;
	ln_rate_2 NUMBER;
	ld_daytime_1 DATE;
	ld_daytime_2 DATE;
	ln_result_no_1 NUMBER;
	ln_result_no_2 NUMBER;
	ln_reset_trend_check_1 NUMBER;
	ln_reset_trend_check_2 NUMBER;

	-- cursor to check if there's any reset trend avalaible at any daytime > ln_daytime_1 and < p_datime
	CURSOR c_check_reset_trend_1 (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_1 DATE) IS
		select pt.result_no from pwel_result pw, ptst_result pt where
			pt.result_no = pw.result_no and
			pw.object_id = cp_object_id and
			pt.valid_from_date > cp_daytime_1 and
			pt.valid_from_date < cp_daytime and
			pw.trend_reset_ind = 'Y';



	-- cursor to check if there's any reset trend avalaible at any daytime <= ln_daytime_2 and > p_datime
	CURSOR c_check_reset_trend_2 (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_2 DATE) IS
		select pt.result_no from pwel_result pw, ptst_result pt where
			pt.result_no = pw.result_no and
			pw.object_id = cp_object_id and
			pt.valid_from_date <= cp_daytime_2 and
			pt.valid_from_date > cp_daytime and
			pw.trend_reset_ind = 'Y';

BEGIN


	ln_result_no_1 := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id, p_daytime);
	ln_result_no_2 := EcDp_Performance_Test.getNextValidWellResultNo(p_object_id, p_daytime);

	ln_rate_1 := EcDp_Well_Estimate.getLastWatStdMassRate(p_object_id, p_daytime);
	ln_rate_2 := EcDp_Well_Estimate.getNextWatStdMassRate(p_object_id, p_daytime);

	ld_daytime_1 := ec_ptst_result.valid_from_date(ln_result_no_1);
	ld_daytime_2 := ec_ptst_result.valid_from_date(ln_result_no_2);

	FOR my_cur IN c_check_reset_trend_1 (p_object_id, p_daytime, ld_daytime_1) LOOP
		ln_reset_trend_check_1 := my_cur.result_no;
	END LOOP;

	FOR my_cur2 IN c_check_reset_trend_2 (p_object_id, p_daytime, ld_daytime_2) LOOP
		ln_reset_trend_check_2 := my_cur2.result_no;
	END LOOP;

	-- if theres no performance reference point 1 and there's a reset trend at any date > daytime_1 and <= production day, then return null
	IF (ln_rate_1 IS NULL) OR (ln_reset_trend_check_1 is NOT NULL) THEN

		return NULL;

  ELSE
		-- if there's no performance reference point 2 and there's a reset trend at a date where date > production day and <= daytime_2
		IF (ln_rate_2 IS NULL) OR (ln_reset_trend_check_2 is NOT NULL) THEN

			return EcDp_Well_Estimate.getExtrapolateWatMassRate(p_object_id, p_daytime);

		ELSE
			-- if all the rules are fulfilled, start interpolate
			IF ld_daytime_1 IS NULL OR ld_daytime_2 IS NULL THEN
			   -- Cannot interpolate, return NULL. Should never happen!
			   RETURN NULL;
			ELSIF ld_daytime_1=ld_daytime_2 THEN
			   -- Exact hit on a daytime, no need for interpolation!
			   RETURN ln_rate_1;
			ELSE
			   -- Linear interpolation
			   RETURN ln_rate_1+(to_char(p_daytime,'J')-to_char(ld_daytime_1, 'J'))*(ln_rate_2-ln_rate_1)/(ld_daytime_2-ld_daytime_1);
		  END IF;
		END IF;
	END IF;

END getInterpolateWatMassRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getExtrapolateWatMassRate
-- Description    : Returns the extrapolated wat mass rate value determined by the attribute appraoch method
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getExtrapolateWatMassRate (p_object_id well.object_id%TYPE, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS
	ln_rate_1 NUMBER;
	ln_rate_2 NUMBER;
	ld_daytime_1 DATE;
	ld_daytime_2 DATE;
	ln_result_no_1 NUMBER;
	ln_result_no_2 NUMBER;
	ln_reset_trend_check_1 NUMBER;
	ln_reset_trend_check_2 NUMBER;
	ln_temp NUMBER;
	ln_wat_trend_c2 NUMBER;

	-- cursor to check if there's any reset trend avalaible at any daytime > ln_daytime_1 and < p_datime
	CURSOR c_check_reset_trend_1 (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_1 DATE) IS
		select pt.result_no from pwel_result pw, ptst_result pt where
			pt.result_no = pw.result_no and
			pw.object_id = cp_object_id and
			pt.valid_from_date > cp_daytime_1 and
			pt.valid_from_date < cp_daytime and
			pw.trend_reset_ind = 'Y';

		-- cursor to check if there's any reset trend avalaible at any daytime <= ln_daytime_2 and > p_datime
	CURSOR c_check_reset_trend_2 (cp_object_id VARCHAR2, cp_daytime DATE, cp_daytime_2 DATE) IS
		select pt.result_no from pwel_result pw, ptst_result pt where
			pt.result_no = pw.result_no and
			pw.object_id = cp_object_id and
			pt.valid_from_date <= cp_daytime_2 and
			pt.valid_from_date > cp_daytime and
			pw.trend_reset_ind = 'Y';

BEGIN

	ln_result_no_1 := EcDp_Performance_Test.getLastValidWellResultNo(p_object_id, p_daytime);
	ln_result_no_2 := EcDp_Performance_Test.getNextValidWellResultNo(p_object_id, p_daytime);

	ln_rate_1 := EcDp_Well_Estimate.getLastWatStdMassRate(p_object_id, p_daytime);
	ln_rate_2 := EcDp_Well_Estimate.getNextWatStdMassRate(p_object_id, p_daytime);

	ld_daytime_1 := ec_ptst_result.valid_from_date(ln_result_no_1);
	ld_daytime_2 := ec_ptst_result.valid_from_date(ln_result_no_2);

	ln_wat_trend_c2 := EcDp_Performance_Test.findWatConstantC2(p_object_id, p_daytime);

	FOR my_cur IN c_check_reset_trend_1 (p_object_id, p_daytime, ld_daytime_1) LOOP
		ln_reset_trend_check_1 := my_cur.result_no;
	END LOOP;

	FOR my_cur2 IN c_check_reset_trend_2 (p_object_id, p_daytime, ld_daytime_2) LOOP
		ln_reset_trend_check_2 := my_cur2.result_no;
	END LOOP;

	-- if theres no performance reference point 1 and there's no reset trend at any date > daytime_1 and <= production day, then return null
	IF (ln_rate_1 IS NULL) OR (ln_reset_trend_check_1 is NOT NULL) THEN

		return NULL;
	ELSE
		-- if theres no performance reference point 2 and there's a reset trend at a date where production day < date < daytime_2 then extrapolate
		IF (ln_rate_2 IS NULL) OR ((ln_rate_2 IS NOT NULL) AND (ln_reset_trend_check_2 IS NOT NULL)) THEN
			ln_temp := (to_char(p_daytime, 'J') - to_char(ld_daytime_1, 'J'))/30;
			return ln_rate_1 * power((1 + ln_wat_trend_c2 / 100), ln_temp);
		ELSIF (ln_rate_2 IS NOT NULL) AND (ln_reset_trend_check_2 IS NULL)THEN
      			return ln_rate_1;
		ELSE
			return NULL;
		END IF;
	END IF;

END getExtrapolateWatMassRate;



END EcDp_Well_Estimate;