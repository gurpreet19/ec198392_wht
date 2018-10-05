CREATE OR REPLACE PACKAGE BODY EcDp_Well_Decline IS
/******************************************************************************
** Package        :  EcDp_Well_Decline, body part
**
** $Revision: 1.3.12.4 $
**
** Purpose        :  Business logic for well decline for the PT module.
**
** Documentation  :  www.energy-components.com
**
** Created  	  :  24.05.2010 madondin
**
** Modification history:
**
**  Date     Whom         Change description:
** ------    -------     -------------------------------------------
** 24.05.10  madondin    ECPD-13374: - Added new function getYfromX,getProductionRate and getCurveExp
** 04.05.12  limmmchu    ECPD-:20509 - Modified function getYfromX
** 30.08.12  limmmchu    ECPD-21860: - Modified function getYfromX
** 02.09.14  shindani    ECPD-28517: - Modified function getProductionRate
********************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getYfromX
-- Description    : Calculates y from a given x based on formula type and coefficients/points
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Calculates y from the given x
--
--
--
--
--
---------------------------------------------------------------------------------------------------

FUNCTION getYfromX(p_x_value NUMBER, p_c0 NUMBER, p_c1 NUMBER, p_trend_method VARCHAR2, p_c2 NUMBER DEFAULT NULL) RETURN NUMBER
--</EC-DOC>
IS
   ln_retVal	NUMBER;
   ln_temp	NUMBER;


BEGIN
   IF p_x_value IS NULL THEN
      RETURN NULL;
   END IF;

   IF p_trend_method = 'EXP' THEN

     ln_retVal := p_c0 * POWER(EXP(1),(p_c1*p_x_value));

   ELSIF p_trend_method = 'LINEAR' THEN

     ln_retVal := p_c0*(1 + (p_c1*p_x_value));

   ELSIF p_trend_method = 'HARMONIC' THEN
     -- y=Q1/(1-(k*t)
     -- Q1 = p_c0
     -- k = p_c1
     ln_temp := 1-(p_c1*p_x_value);

     IF ln_temp IS NOT NULL AND ln_temp <> 0 THEN
        ln_retVal := p_c0 /ln_temp;
     END IF;

   ELSIF p_trend_method = 'HYPERBOLIC' THEN
     -- Y=Q1/(1-(K*T*B))**(1/b)
     -- Q1 = p_c0
     -- k = p_c1
     -- b = p_c2

     IF p_c1 > 0 and p_c1 < 1 THEN
     	ln_temp := POWER(1-(p_c1*p_x_value*p_c2), (1/p_c2));

     	IF ln_temp IS NOT NULL AND ln_temp <> 0 THEN
     	   ln_retVal := p_c0 /ln_temp;
     	END IF;
     ELSE
         ln_retVal := null;
     END IF;

   ELSIF (substr(p_trend_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_retVal := Ue_Well_Decline.getYfromX(
                          p_x_value,
                          p_c0,
                          p_c1,
                          p_trend_method,
						  p_c2);
   END IF;

   return ln_retVal;

END getYfromX;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getProductionRate
-- Description    : To get the production rate depending on the phase type
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : get the production rate depending on the phase type and last valid well to get the date
--
--
--
--
--
---------------------------------------------------------------------------------------------------

FUNCTION getProductionRate(p_object_id        well.object_id%TYPE,
   p_daytime                          DATE,
   p_trend_parameter                  VARCHAR2
) RETURN NUMBER
--</EC-DOC>
IS
   ln_retVal                          NUMBER;
   ld_daytime                         DATE;
   ln_result_no                       NUMBER;
   ld_cur_sysdate                     DATE;

BEGIN

   ln_result_no := ecdp_performance_test.getLastValidWellResultNo(p_object_id, p_daytime);

   ld_daytime := ecdp_performance_test.getLastValidWellResult(p_object_id, p_daytime).daytime;

   ld_cur_sysdate := ecdp_date_time.getCurrentSysdate();

   IF p_trend_parameter = 'OIL' THEN
      IF (p_daytime > ld_cur_sysdate) THEN
        ln_retval := ecbp_well_potential.findOilProductionPotential(p_object_id,ld_daytime);
        else
        ln_retVal := ecbp_well_theoretical.getOilStdRateDay(p_object_id,ld_daytime);
      END IF;

   ELSIF p_trend_parameter = 'GAS' THEN
      IF (p_daytime > ld_cur_sysdate) THEN
        ln_retVal := ecbp_well_potential.findOilProductionPotential(p_object_id,ld_daytime);
        else
        ln_retVal := ecbp_well_theoretical.getGasStdRateDay(p_object_id,ld_daytime);
      END IF;

   ELSIF p_trend_parameter = 'Water' THEN
     IF (p_daytime > ld_cur_sysdate) THEN
          ln_retVal := ecbp_well_potential.findWatProductionPotential(p_object_id,ld_daytime);
        else
          ln_retVal := ecbp_well_theoretical.getWatStdRateDay(p_object_id,ld_daytime);
      END IF;

   ELSIF p_trend_parameter = 'GOR' THEN
      ln_retVal := ecbp_well_theoretical.findGasOilRatio(p_object_id,ld_daytime);

   ELSIF p_trend_parameter = 'CGR' THEN
      ln_retVal := ecbp_well_theoretical.findCondGasRatio(p_object_id,ld_daytime);

   ELSIF p_trend_parameter = 'WGR' THEN
      ln_retVal := ecbp_well_theoretical.findWaterGasRatio(p_object_id,ld_daytime);

   ELSIF p_trend_parameter = 'Watercut' THEN
      ln_retVal := ecbp_well_theoretical.findWaterCutPct(p_object_id,ld_daytime);

   ELSIF p_trend_parameter = 'Condensate' THEN
      IF (p_daytime > ld_cur_sysdate) THEN
        ln_retVal := ecbp_well_potential.findConProductionPotential(p_object_id,ld_daytime);
        else
      ln_retVal := ecbp_well_theoretical.getCondStdRateDay(p_object_id,ld_daytime);
       END IF;

   ELSIF p_trend_parameter = 'WOR' THEN
      ln_retVal := ecbp_well_theoretical.findWaterOilRatio(p_object_id,ld_daytime);
   END IF;

   return ln_retVal;

END getProductionRate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCurveExp
-- Description    : To get the curve exponent if trend method is hyperbolic
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Get curve exponent for hyperbolic trend method
--
--
--
--
--
---------------------------------------------------------------------------------------------------

FUNCTION getCurveExp(p_object_id        well.object_id%TYPE,
   p_daytime                          DATE,
   p_trend_parameter                  VARCHAR2
) RETURN NUMBER
--</EC-DOC>
IS
   ln_retVal                          NUMBER;


BEGIN

   ln_retVal := ec_well_decline.curve_exponential(p_object_id,p_trend_parameter,p_daytime,'<=');

   return ln_retVal;

END getCurveExp;

END EcDp_Well_Decline;