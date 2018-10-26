CREATE OR REPLACE PACKAGE BODY EcBp_Tank IS
/****************************************************************
** Package        :  EcBp_Tank, body part
**
** $Revision: 1.78 $
**
** Purpose        :  Finds tank volumes
**
** Documentation  :  www.energy-components.com
**
** Created  : 12.10.2001  Harald Vetrhus
**
** Modification history:
**
** Version  Date         Whom     Change description:
** -------  ----------   -------- --------------------------------------
** 1.1      25.10.02     HNE      Added findTankBswFrac
**                                Added methods to findTankVolume
**                                Changed findTankNetVolume to use findTankBswFrac rather than hardcode bsw_vol from table.
**          05.05.2004   FBa      Totally rewritten package for EC release 7.3
**          09.06.2004   HNE      Added p_meas_event_type to parameter list for all functions.
**                                Bugfixes
** 1.12     25.06.2004   AV       Corrected bug in findGrsVol when given method = GRS_MASS_DENSITY
**                                Pass NULL as method to findObsDens and findGrsMass
**          06.06.2004   DN       Ref. issue 1322: Added Nvl-function to dead_stock and roof_displacement elements.
** 1.13     22.07.2004   Toha     Replaced sysnam+tank_no+tank_type to tank.object_id on signatures and made changes as necessary.
** 1.12.2.2 15.09.2004   Toha     #1556: Error in adjustments for dead stock
**                                       findGrsStdVol(line ref #286), findGrsOilVol(line ref #970) - deduction changed from - greatest(ln_free_wat_vol, ln_dead_stock) to ln_free_wat_vol
**          09.12.2004   ROV      #1851:Fixed error in EcBp_Tank.findGrsMass
**                                In general removed calls to EcDp_Tank.getDeadStockVol as it is not used anymore.
**          24.02.2005   kaurrnar  Changed tank_attribute to tank_version
**          01.03.2005   Darren   Replaced obsolete column name with new column name
**          02.03.2005   Ron Boh  Removed reference to Reference to �EcDp_Tank.getTankCalcMethod�
**          04.03.2005   kaurrnar Changed 'STD_DENS' to 'STD_DENS_METHOD' in findObsDens function
**          16.08.2005   Ron Boh  Updated findOpeningGrsMass and findOpeningGrsVol to support the new Event tanks. It should identifying latest available DAY_CLOSING in table tank_measurement for the given tank.
** 1.24     19.11.2005   chongjer Tracker 2458: Added functions: findClosingGrsVol, findClosingGrsMass, findOpeningNetVol, findClosingNetVol,
**                                                               findOpeningNetMass, findClosingNetMass, findOpeningWatVol, findClosingWatVol
**
** 1.25     13.12.2005   Ron Boh  TI# 3113 - New User Exit methods for tank calculation
**                                           modified function
**                                              findGrVol
**                                              findNetMass
**                                              findGrsMass
**                                              findVolumeCorrectionFactor
**                                              findWaterVol
**                                              findFreeWaterVol
**                                           to support user exit method
**          02.01.2006   DN       Tracker 2288: Added lock procedures.
**          16.01.2006   DN       Procedure checkTankMeasurementLock. Removed extra test on next record.
**          18.09.2006   vikaaroa Fixed bug cursors used to resolve closing volume for EVENT tanks in the findOpening/Closing## methods
**                                Updated logic related to MONTH taks in the findOpening/Closing## methods
**          12.12.2006   kaurrnar ECPD-4765: Change check for Standard Density from STD_DENS_METHOD to STD_DENS in findObsDens function
**          07.09.2007   idrussab ECPD-6214: For function findObsDEns, update 'MEASURED' and add 'API_TO_KGPERSM3', 'API_TO_LBSPERBBLS'
**          26.09.2007   rajarsar ECPD-6378: Updated findBSWVol, findObsDens and findStdDens to support User Exit.
**          21.12.2007   oonnnng  ECPD-6716: Updated findBSWWT() function to support User Exit.
**          28.12.2007   rajarsar ECPD-6054: Updated findBSWWT,findBSWVol, findObsDens and findStdDens functions to support 'STREAM_SAMPLE_ANALYSIS'.
**          10.04.2008   ismaiime ECPD-7968: Updated function findObsDens,when method = MEASURED call ec_tank_measurement.obs_density()
**          26.05.2008   oonnnng  ECPD-8471: Replace USER_EXIT test statements with [ (substr(lv2_gas_lift_method,1,9) = EcDp_Calc_Method.USER_EXIT) ].
**          22.11.2008   oonnnng  ECPD-6067: Added local month lock checking in checkTankMeasurementLock, and checkTankStrappingLock functions.
**	    27.11.2008   aliassit ECPD-10294: Added measurement_event_type in CURSOR_x_xx for every functions to ensure EVENT_CLOSING records will not be mixed with DAY_CLOSING records
**	    08.01.2008	 aliassit ECPD-10611: Modify all findOpeningXXXX/findClosingXXXX functions for a better performance.
**	    11.02.2009   musaamah ECPD-10872: Included p_daytime in the where clause of the cursor in functions (as listed below).
**					      Moved the cursor to be common for all functions rather than repeating the cursor inside many functions.
**					      Renamed the cursor to 'c_object_fluid_analysis'. Affected functions:
**	 	    			      	findBSWVol
**					      	findBSWWt
**						findStdDens
**						findObsDens
**          22.11.2008   oonnnng  ECPD-6067: Added new parameter p_object_id to checkUpdateOfLDOForLock() and validatePeriodForLockOverlap()
**                                in checkTankMeasurementLock(), and checkTankStrappingLock() functions.
**          06.03.2009	 masamken ECPD-11348: Modify all findOpeningXXXX/findClosingXXXX so that ec Stream formula return water volume day opening for EVENT tanks when current closing water volume is null.
**          08.05.2009   leongsei ECPD-11702: Added overload procedure for checkTankMeasurementLock
**          06.10.2009   Leongwen ECPD-12867: Problems with new BF Daily Well Tank Data
**          07.01.2010  oonnnng   ECPD-13585: Added USER_EXIT option to the calcRoofDisplacementVol() function.
**          21.01.2010  rajarsar  ECPD-13196: Updated findBSWvol to support new method = WELL_TANK, new method = WATER_DIV_GRS_VOL updated method = TANK_WELL and cleaned up codes
**          11.02.2010  rajarsar  ECPD-13799: Updated findBSWvol to enhance method = WELL_TANK
**          08.09.2010  saadsiti  ECPD-15639: Added new function findClosingGrsStdOilVol
**          15.08.2011  musthram  ECPD-17537: Updated CURSOR c_object_fluid_analysis
** 			01.11.2012  abdulmaw  ECPD-22037: Enhance findNetStdOilVol, findStdDens, findBSWVol. Added findNetDiluentVol, findClosingDiluentVol, findOpeningDiluentVol, findDiluentDens, findBitumenDens, calcWeightedDensFromTaps, calcWeightedBSWFromTaps
** 			22.01.2013  limmmchu  ECPD-23055: Enhance findClosingNetVol to support event closing
** 			21.03.2013  kumarsur  ECPD-22598: Modified calcWeightedDensFromTaps(), calcWeightedBSWFromTaps(), findNetStdOilVol(), findNetDiluentVol() and added findShrunkVol().
** 			07.08.2013  kumarsur  ECPD-22316: Modified findNetStdOilVol() and findNetDiluentVol() include Ue_Tank_Calculation.findBlendShrinkageFactor().
** 			24.09.2013  musthram  ECPD-25109: Modified findNetStdOilVol to maintain ec_code consistency
** 			25.09.2013  abdulmaw  ECPD-24092: Added new function findAvgPrevMthBswTruck.
** 			26.09.2013  kumarsur  ECPD-22185: Modified findGrsVol to include new method STRAPPING_DENSITY.
**			30.10.2013  makkkkam  ECPD-25873: Modified findNetStdOilVol, findNetDiluentVol, findShrunkVol so that we get 0 diluent and shrinkage when there is only water in the tank
**			31.12.2013  wonggkai  ECPD-26212: Modified findNetDiluentVol, add criteria for DILUENT_TANK
**		    02.04.2014  musthram  ECPD-27129: Modified findOpeningGrsVol, findOpeningGrsMass, findClosingGrsVol, findClosingGrsMass, findOpeningDiluentVol, findClosingDiluentVol, findOpeningNetVol, 	findClosingNetVol, findOpeningNetMass, findClosingNetMass, findOpeningWatVol, findClosingWatVol, findOpeningEnergy, findClosingEnergy, findClosingGrsStdOilVol, add criteria for meas_event_type
** 			27.05.2014  makkkkam  ECPD-27440: Modify user_exit method in findDiluentDens, findBitumenDens, findNetStdOilVol, findNetDiluentVol.
** 			05.08.2014  kumarsur  ECPD-27067: Modified findNetStdOilVol, findNetDiluentVol, findShrunkVol.
*****************************************************************/

-- Cursor to fetch STREAM SAMPLE ANALYSIS based on the given OBJECT_FLUID_ANALYSIS_OBJECT_ID and DAYTIME
CURSOR c_object_fluid_analysis(cp_ofa_object_id VARCHAR2, cp_daytime DATE) IS
  SELECT *
    FROM object_fluid_analysis ofa
	WHERE ofa.object_id = cp_ofa_object_id
	AND ofa.object_class_name = 'STREAM'
	AND ofa.analysis_type = 'STRM_SAMPLE_ANALYSIS'
	AND ofa.analysis_status = 'APPROVED'
	AND nvl(ofa.valid_from_date,ofa.daytime) = (
	SELECT max(nvl(valid_from_date,daytime))
	FROM object_fluid_analysis ofa2
	WHERE ofa2.object_id = cp_ofa_object_id
	AND ofa2.object_class_name = 'STREAM'
	AND ofa2.analysis_type = 'STRM_SAMPLE_ANALYSIS'
	AND ofa2.analysis_status = 'APPROVED'
	AND nvl(ofa2.valid_from_date,ofa2.daytime) <= cp_daytime);

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcRoofDisplacementVol
--
-- Description    : Returns roof displacement volume
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

FUNCTION calcRoofDisplacementVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_dip_level          NUMBER,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL
)
RETURN NUMBER
--</EC-DOC>
IS
  lr_tank              TANK%ROWTYPE;
  ln_roof_soak_lower   NUMBER;
  ln_roof_soak_upper   NUMBER;
  ln_roof_weight       NUMBER;
  ln_retval            NUMBER;
  ln_fluid_dens        NUMBER;
  ln_partial_soak_fact NUMBER;
  lv2_resolve_loop     VARCHAR2(2000);
  lv2_calc_method      VARCHAR2(300);

BEGIN
  IF InStr(p_resolve_loop,'findRoofDisplacementVol')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a tank''s Roof Displacement Volume. Possibly due to a mis-configuration of tank attributes.');
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findRoofDisplacementVol,';
  END IF;

  lv2_calc_method := Nvl(p_method, Ec_Tank_version.ROOF_DISP_METHOD(p_tank_object_id, p_daytime, '<=') );

  IF lv2_calc_method = 'FORMULA' THEN

    lr_tank := ec_tank.row_by_object_id(p_tank_object_id);

    ln_roof_soak_lower := ec_tank_version.ROOF_SOAK_LO_LIM(lr_tank.object_id, p_daytime, '<=');
    ln_roof_soak_upper := ec_tank_version.ROOF_SOAK_UP_LIM(lr_tank.object_id, p_daytime, '<=');
    ln_roof_weight     := ec_tank_version.ROOF_WEIGHT(lr_tank.object_id, p_daytime, '<=');
    ln_fluid_dens      := EcBp_Tank.findObsDens( p_tank_object_id, p_meas_event_type, p_daytime, NULL, lv2_resolve_loop);

    IF ln_roof_soak_lower >= ln_roof_soak_upper THEN
      ln_retval := NULL;  -- invalid configuration!
    ELSE
      IF p_dip_level > ln_roof_soak_upper THEN -- Roof floating
        IF ln_fluid_dens = 0 THEN
          ln_retval := NULL;
        ELSE
          ln_retval := ln_roof_weight / ln_fluid_dens;
        END IF;
      ELSIF p_dip_level BETWEEN ln_roof_soak_lower AND ln_roof_soak_upper THEN -- Roof in critical zone
        ln_partial_soak_fact := (p_dip_level - ln_roof_soak_lower) / (ln_roof_soak_upper - ln_roof_soak_lower); -- div/0 because lower=upper already caught by outer if clause
        IF ln_fluid_dens = 0 THEN
          ln_retval := NULL;
        ELSE
          ln_retval := ln_partial_soak_fact * ln_roof_weight / ln_fluid_dens;
        END IF;
      ELSIF p_dip_level < ln_roof_soak_lower THEN
        ln_retval := 0;
      END IF;
    END IF;

  ELSIF lv2_calc_method = 'ZERO' THEN
    ln_retval := 0;

  ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
     ln_retval :=  ue_tank_calculation.calcRoofDisplacementVol(p_tank_object_id, p_meas_event_type, p_dip_level, p_daytime);

  ELSE
    ln_retval := NULL;
  END IF;

  RETURN ln_retval;

END calcRoofDisplacementVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcRoofDisplacementMass
--
-- Description    : Returns roof displacement mass
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

FUNCTION calcRoofDisplacementMass(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE
)
RETURN NUMBER
--</EC-DOC>
IS
  lr_tank              TANK%ROWTYPE;
  ln_roof_weight       NUMBER;

BEGIN
  lr_tank := ec_tank.row_by_object_id(p_tank_object_id);
  ln_roof_weight     := ec_tank_version.ROOF_WEIGHT(lr_tank.object_id, p_daytime, '<=');

  RETURN ln_roof_weight;

END calcRoofDisplacementMass;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGrsVol
--
-- Description    : Returns total grs volume for tank
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

FUNCTION findGrsVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method      VARCHAR2(300);
--  ln_bsw               NUMBER;
  ln_density           NUMBER;
  ln_retval            NUMBER;
  lv2_resolve_loop     VARCHAR2(2000);
  ln_volume            NUMBER;

BEGIN
  IF InStr(p_resolve_loop,'findGrsVol')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a tank''s Grs Oil Volume. Possibly due to a mis-configuration of tank attributes.');
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findGrsVol,';
  END IF;

  lv2_calc_method := Nvl(p_method, Ec_Tank_version.GRS_VOL_METHOD(p_tank_object_id, p_daytime, '<=') );

  IF lv2_calc_method = 'MEASURED' THEN

    ln_retval := EcDp_Tank_Measurement.getGrsVol(p_tank_object_id, p_meas_event_type, p_daytime);

  ELSIF lv2_calc_method = 'STRAPPING' THEN

    ln_retval := EcDp_Tank_Strapping.findVolumeFromDip(p_tank_object_id,
                                                       EcDp_Tank_Measurement.getGrsDipLevel(p_tank_object_id, p_meas_event_type, p_daytime),
                                                       p_daytime);
  ELSIF lv2_calc_method = 'GRS_MASS_DENSITY' THEN

    ln_density := EcBp_Tank.findObsDens(p_tank_object_id, p_meas_event_type, p_daytime,
                                        NULL,  -- Can not pass the GRS_VOL_METHOD HERE
                                        lv2_resolve_loop);

    IF ln_density = 0 THEN
      ln_retval := NULL;
    ELSE
      ln_retval := EcBp_Tank.findGrsMass(p_tank_object_id, p_meas_event_type, p_daytime,
                                         NULL,  -- Can not pass the GRS_VOL_METHOD HERE
                                         lv2_resolve_loop) / ln_density;
    END IF;

  ELSIF lv2_calc_method = 'STRAPPING_DENSITY' THEN

    ln_volume := EcDp_Tank_Strapping.findVolumeFromDip(p_tank_object_id, EcDp_Tank_Measurement.getGrsDipLevel(p_tank_object_id, p_meas_event_type, p_daytime),p_daytime);
    ln_density := EcBp_Tank.findStdDens(p_tank_object_id, p_meas_event_type, p_daytime,NULL, lv2_resolve_loop);
    ln_retval := ln_volume * ln_density;

  ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN

     ln_retval :=  ue_tank_calculation.getGrsVol(p_tank_object_id, p_meas_event_type, p_daytime);

  ELSE

   ln_retval := NULL;

  END IF;

  RETURN ln_retval;

END findGrsVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGrsStdVol
--
-- Description    : Returns grs volume at tank conditions
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

FUNCTION findGrsStdVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  ln_free_wat_vol      NUMBER;
  ln_grs_std_oil_vol   NUMBER;
  ln_retval            NUMBER;
  lv2_resolve_loop     VARCHAR2(2000);

BEGIN
  IF InStr(p_resolve_loop,'findGrsStdVol')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a tank''s Grs Volume. Possibly due to a mis-configuration of tank attributes.');
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findGrsStdVol,';
  END IF;

  ln_grs_std_oil_vol := EcBp_Tank.findGrsStdOilVol(p_tank_object_id, p_meas_event_type, p_daytime, NULL, lv2_resolve_loop);
  ln_free_wat_vol    := EcBp_Tank.findFreeWaterVol(p_tank_object_id, p_meas_event_type, p_daytime, p_method, lv2_resolve_loop);

  ln_retval := ln_grs_std_oil_vol + ln_free_wat_vol;

  RETURN ln_retval;

END findGrsStdVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findNetMass
--
-- Description    : Returns net mass
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

FUNCTION findNetMass(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method      VARCHAR2(300);
  ln_bsw               NUMBER;
  ln_retval            NUMBER;
  lv2_resolve_loop     VARCHAR2(2000);

BEGIN
  IF InStr(p_resolve_loop,'findNetMass')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a tank''s Net Mass. Possibly due to a mis-configuration of tank attributes.');
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findNetMass,';
  END IF;

  lv2_calc_method := Nvl(p_method, Ec_Tank_Version.NET_MASS_METHOD(p_tank_object_id, p_daytime, '<=') );

  -- MEASURED is not currently a valid option - maybe in the future.
  IF lv2_calc_method = 'MEASURED' THEN

    ln_retval := EcDp_Tank_Measurement.getNetMass(p_tank_object_id, p_meas_event_type, p_daytime);

  ELSIF lv2_calc_method = 'GRS_MASS_BSW' THEN

    ln_bsw := EcBp_Tank.findBSWWt(p_tank_object_id, p_meas_event_type, p_daytime, NULL, lv2_resolve_loop);
    IF ln_bsw = 1 THEN
      ln_retval := 0;
    ELSE
      ln_retval := EcBp_Tank.findGrsMass(p_tank_object_id, p_meas_event_type, p_daytime, NULL, lv2_resolve_loop) * (1 - ln_bsw);
    END IF;

  ELSIF lv2_calc_method = 'NET_VOL_DENSITY' THEN

    ln_retval :=
      EcBp_Tank.findNetStdOilVol(p_tank_object_id, p_meas_event_type, p_daytime, NULL, lv2_resolve_loop) *
      EcBp_Tank.findStdDens(p_tank_object_id, p_meas_event_type, p_daytime, NULL, lv2_resolve_loop);

  ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN

     ln_retval :=  ue_tank_calculation.getNetMass(p_tank_object_id, p_meas_event_type, p_daytime);

  ELSE

   ln_retval := NULL;

  END IF;

  RETURN ln_retval;

END findNetMass;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGrsMass
--
-- Description    : Returns gross mass
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

FUNCTION findGrsMass(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method      VARCHAR2(300);
  ln_retval            NUMBER;
  lv2_resolve_loop     VARCHAR2(2000);

BEGIN
  IF InStr(p_resolve_loop,'findGrsMass')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a tank''s Grs Volume. Possibly due to a mis-configuration of tank attributes.');
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findGrsMass,';
  END IF;

  lv2_calc_method := Nvl(p_method, Ec_Tank_Version.GRS_MASS_METHOD(p_tank_object_id, p_daytime, '<=') );

  IF lv2_calc_method = 'MEASURED' THEN

    ln_retval := EcDp_Tank_Measurement.getGrsMass(p_tank_object_id, p_meas_event_type, p_daytime);

  ELSIF lv2_calc_method = 'STRAPPING' THEN

    ln_retval := EcDp_Tank_Strapping.findMassFromDip(p_tank_object_id,
                                                     EcDp_Tank_Measurement.getGrsDipLevel(p_tank_object_id, p_meas_event_type, p_daytime),
                                                     p_daytime) -
                 EcBp_Tank.calcRoofDisplacementMass(p_tank_object_id, p_meas_event_type, p_daytime);

  ELSIF lv2_calc_method = 'GRS_VOL_DENSITY' THEN

    ln_retval :=
      EcBp_Tank.findGrsOilVol(p_tank_object_id, p_meas_event_type, p_daytime, NULL, lv2_resolve_loop) *
      EcBp_Tank.findObsDens(p_tank_object_id, p_meas_event_type, p_daytime, NULL, lv2_resolve_loop);

  ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN

           ln_retval := ue_tank_calculation.getGrsMass(p_tank_object_id, p_meas_event_type, p_daytime);

  ELSE

   ln_retval := NULL;

  END IF;

  RETURN ln_retval;

END findGrsMass;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findBSWVol
--
-- Description    : Returns BS and W (volume) at standard conditions
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

FUNCTION findBSWVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method      VARCHAR2(300);
  ln_retval            NUMBER;
  lr_tank              TANK%ROWTYPE;
  lv2_resolve_loop     VARCHAR2(2000);
  lv2_analysis_strm_id VARCHAR2(32);
  lv2_well_id          VARCHAR2(32);
  ln_totWatTruck       NUMBER;
  ln_waterVol          NUMBER;
  ln_grsClosing        NUMBER;
  ln_waterOpening      NUMBER;
  ln_waterClosing      NUMBER;
  ln_sum_grsClosing    NUMBER;
  ln_sum_waterOpening  NUMBER;
  ln_sum_waterClosing  NUMBER;


CURSOR c_tank_well(cp_object_id well.object_id%TYPE) IS
    SELECT DISTINCT (tm.object_id)
     FROM tank_version tv, tank_measurement tm
    WHERE tv.tank_well = cp_object_id
      AND tv.object_id = tm.object_id
      AND tv.bf_usage = 'WR.0060'
      AND tm.measurement_event_type = 'DAY_CLOSING'
      AND tv.daytime <= p_daytime
      AND (tv.end_date > p_daytime OR tv.end_date IS NULL)
      AND (exclude_tank_well = 'N' OR exclude_tank_well IS NULL)
      AND tm.daytime = p_daytime;



BEGIN
  IF InStr(p_resolve_loop,'findBSWVol')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a tank''s BS and W (volume). Possibly due to a mis-configuration of tank attributes.');
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findBSWVol,';
  END IF;

  lv2_calc_method := Nvl(p_method, Ec_Tank_version.BS_W_VOL_METHOD(p_tank_object_id, p_daytime, '<=') );

  IF lv2_calc_method = 'MEASURED' THEN

    ln_retval := EcDp_Tank_Measurement.getBSWVol(p_tank_object_id, p_meas_event_type, p_daytime);

  ELSIF lv2_calc_method = 'REF_VALUE' THEN

    lr_tank := ec_tank.row_by_object_id(p_tank_object_id);
    ln_retval := ec_tank_version.BS_W_VOL(lr_tank.object_id, p_daytime, '<=');

  ELSIF lv2_calc_method = 'ZERO' THEN

    ln_retval := 0;

  ELSIF lv2_calc_method = 'STREAM_SAMPLE_ANALYSIS' THEN
    lr_tank := ec_tank.row_by_object_id(p_tank_object_id);
    lv2_analysis_strm_id := ec_tank_version.analysis_stream_id(lr_tank.object_id, p_daytime, '<=');
    For cur_ofa_bswvol in c_object_fluid_analysis(lv2_analysis_strm_id, p_daytime) Loop
      ln_retval  := cur_ofa_bswvol.bs_w;
    End Loop;

  ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN

    ln_retval := ue_tank_calculation.getBSWVol(p_tank_object_id, p_meas_event_type, p_daytime);

  ELSIF lv2_calc_method = 'TANK_WELL' THEN

    lv2_well_id := ec_tank_version.tank_well(p_tank_object_id,p_daytime,'<=');
    ln_retval  := nvl(EcDp_Tank_Measurement.getBSWVol(p_tank_object_id, p_meas_event_type, p_daytime),
                      nvl(ec_pwel_day_status.bs_w(lv2_well_id,p_daytime,'='),ecbp_well_theoretical.findbswtruck(lv2_well_id, p_daytime)));

  ELSIF lv2_calc_method = 'WELL_TANK' THEN
     -- to fetch well id which is connected to tank
    lv2_well_id := ec_tank_version.tank_well(p_tank_object_id,p_daytime,'<=');
    --for loop to get all tanks connected to the same well and has records in Daily Well Tank Data Screen
    FOR mycur in c_tank_well(lv2_well_id) LOOP
      ln_grsClosing       := nvl(EcBp_Tank.findGrsStdVol(mycur.object_id,p_meas_event_type,p_daytime),0) ;
      ln_sum_grsClosing   := nvl(ln_sum_grsClosing,0) + ln_grsClosing;
      ln_waterOpening     := nvl(EcBp_Tank.findOpeningWatVol(mycur.object_id,p_meas_event_type,p_daytime),0);
      ln_sum_waterOpening := nvl(ln_sum_waterOpening,0) +  ln_waterOpening ;
    END LOOP;
    -- fetching total water trucked
    ln_totWatTruck   := nvl(Ecbp_Well_Theoretical.sumTruckedWaterFromWell(lv2_well_id, p_daytime),0);
    -- fetching water produced from the well
    ln_waterVol      := Ecbp_Well_Theoretical.getWatStdRateDay(lv2_well_id,p_daytime) -(ln_totWatTruck);
    -- calculate closing water as = opening water in tank + well water produced into tank - trucked water out of tank
    ln_sum_waterClosing := ln_sum_waterOpening + ln_waterVol ;
    --- Test NULL division
    IF ln_sum_grsClosing = 0 THEN
      IF ln_sum_waterClosing = 0 THEN
        ln_retval:=0;
      ELSE
        ln_retval:=NULL;
      END IF;
    ELSE
    --calculating BSW FRAC as closing water volume / closing grs volume on tank
      ln_retval:= ln_sum_waterClosing/ln_sum_grsClosing ;
    END IF;

  ELSIF lv2_calc_method = 'WATER_DIV_GRS_VOL' THEN

    ln_waterVol     := EcBp_Tank.findWaterVol(p_tank_object_id,p_meas_event_type,p_daytime);
    ln_grsClosing   := EcBp_Tank.findGrsStdOilVol(p_tank_object_id,p_meas_event_type,p_daytime);
    --- perform NULL division
    IF ln_grsClosing = 0 THEN
      IF ln_waterVol = 0 THEN
        ln_retval:=0;
      ELSE
        ln_retval:=NULL;
      END IF;
    ELSE
      --calculating BSW FRAC as water volume / closing grs volume on tank
      ln_retval := ln_waterVol/ln_grsClosing;
    END IF;

  ELSIF lv2_calc_method = 'TANK_TAP_ANALYSIS' THEN

    ln_retval := calcWeightedBSWFromTaps(p_tank_object_id, p_daytime);

  ELSIF lv2_calc_method = 'WELL_TRUCK' THEN

    lv2_well_id := ec_tank_version.tank_well(p_tank_object_id,p_daytime,'<=');
    ln_retval := ecbp_well_theoretical.findAvgPrevMthBswTruck(lv2_well_id, trunc(add_months(p_daytime,-1),'MM'));

  ELSE

    ln_retval := NULL;

  END IF;

  RETURN ln_retval;

END findBSWVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findBSWWt
--
-- Description    : Returns BS and W (weight) at standard conditions
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

FUNCTION findBSWWt(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method      VARCHAR2(300);
  ln_retval            NUMBER;
  lr_tank              TANK%ROWTYPE;
  lv2_resolve_loop     VARCHAR2(2000);
  lv2_analysis_strm_id VARCHAR2(32);

BEGIN
  IF InStr(p_resolve_loop,'findBSWWt')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a tank''s BS and W (weight). Possibly due to a mis-configuration of tank attributes.');
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findBSWWt,';
  END IF;

  lv2_calc_method := Nvl(p_method, Ec_Tank_Version.BS_W_WT_METHOD(p_tank_object_id, p_daytime, '<=') );

  IF lv2_calc_method = 'MEASURED' THEN

    ln_retval := EcDp_Tank_Measurement.getBSWWt(p_tank_object_id, p_meas_event_type, p_daytime);

  ELSIF lv2_calc_method = 'REF_VALUE' THEN

    lr_tank := ec_tank.row_by_object_id(p_tank_object_id);
    ln_retval := ec_tank_version.BS_W_WT(lr_tank.object_id, p_daytime, '<=');

  ELSIF lv2_calc_method = 'ZERO' THEN

    ln_retval := 0;

  ELSIF lv2_calc_method = 'STREAM_SAMPLE_ANALYSIS' THEN
    lr_tank := ec_tank.row_by_object_id(p_tank_object_id);
    lv2_analysis_strm_id := ec_tank_version.analysis_stream_id(lr_tank.object_id, p_daytime, '<=');
    For cur_ofa_bswwt in c_object_fluid_analysis(lv2_analysis_strm_id, p_daytime) Loop
      ln_retval  := cur_ofa_bswwt.bs_w_wt;
    End Loop;

  ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN

    ln_retval := ue_tank_calculation.getBSWWT(p_tank_object_id, p_meas_event_type, p_daytime);

  ELSE

    ln_retval := NULL;

  END IF;

  RETURN ln_retval;

END findBSWWt;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAnalysisNo
--
-- Description    : Returns density of diluent
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

FUNCTION getAnalysisNo(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_daytime            DATE)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method      VARCHAR2(300);
  ln_vol               NUMBER;
  ln_retval            NUMBER;
  lr_tank              TANK%ROWTYPE;
  lv2_resolve_loop     VARCHAR2(2000);
  lv2_analysis_strm_id VARCHAR2(32);

BEGIN
  SELECT MAX(analysis_no) INTO ln_retval
  FROM tank_analysis t1
  WHERE t1.object_id = p_tank_object_id
  AND t1.valid_from_date =
    (SELECT max(t2.valid_from_date)
     FROM tank_analysis t2
     WHERE t2.object_id = p_tank_object_id
     AND t2.valid_from_date <= p_daytime)
  ;

  RETURN ln_retval;

END getAnalysisNo;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findDiluentDens
--
-- Description    : Returns density of diluent
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

FUNCTION findDiluentDens(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method      VARCHAR2(300);
  ln_vol               NUMBER;
  ln_retval            NUMBER;
  lr_tank              TANK%ROWTYPE;
  lv2_resolve_loop     VARCHAR2(2000);
  lv2_analysis_strm_id VARCHAR2(32);

BEGIN
  IF InStr(p_resolve_loop,'findDiluentDens')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to find a tank''s Diluent Density. Possibly due to a mis-configuration of tank attributes.');
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findDiluentDens,';
  END IF;

  lv2_calc_method := Nvl(p_method, Ec_Tank_version.DILUENT_DENS_METHOD(p_tank_object_id, p_daytime, '<='));

  IF lv2_calc_method = 'SYSTEM_REF_VALUE' THEN

    ln_retval := ec_ctrl_system_attribute.attribute_value(p_daytime,'DILUENT_DENSITY','<=');

  ELSIF lv2_calc_method = 'TANK_TAP_ANALYSIS' THEN

    ln_retval := ec_tank_analysis.diluent_density(getAnalysisNo(p_tank_object_id, p_daytime));

  ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN

    ln_retval := ue_tank_calculation.findDiluentDens(p_tank_object_id, p_meas_event_type, p_daytime);

  ELSE

    ln_retval := NULL;

  END IF;

  RETURN ln_retval;

END findDiluentDens;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findBitumenDens
--
-- Description    : Returns density of bitumen
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

FUNCTION findBitumenDens(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method      VARCHAR2(300);
  ln_vol               NUMBER;
  ln_retval            NUMBER;
  lr_tank              TANK%ROWTYPE;
  lv2_resolve_loop     VARCHAR2(2000);
  lv2_analysis_strm_id VARCHAR2(32);

BEGIN
  IF InStr(p_resolve_loop,'findBitumenDens')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to find a tank''s Bitumen Density. Possibly due to a mis-configuration of tank attributes.');
  ELSE
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findBitumenDens,';
  END IF;

  lv2_calc_method := Nvl(p_method, Ec_Tank_version.BITUMEN_DENS_METHOD(p_tank_object_id, p_daytime, '<='));

  IF lv2_calc_method = 'SYSTEM_REF_VALUE' THEN

    ln_retval := ec_ctrl_system_attribute.attribute_value(p_daytime,'BITUMEN_DENSITY','<=');

  ELSIF lv2_calc_method = 'TANK_TAP_ANALYSIS' THEN

    ln_retval := ec_tank_analysis.bitumen_density(getAnalysisNo(p_tank_object_id, p_daytime));

  ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN

    ln_retval := ue_tank_calculation.findBitumenDens(p_tank_object_id, p_meas_event_type, p_daytime);

  ELSE

    ln_retval := NULL;

  END IF;

  RETURN ln_retval;

END findBitumenDens;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findStdDens
--
-- Description    : Returns density at standard conditions
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

FUNCTION findStdDens(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method      VARCHAR2(300);
  ln_vol               NUMBER;
  ln_retval            NUMBER;
  lr_tank              TANK%ROWTYPE;
  lv2_resolve_loop     VARCHAR2(2000);
  lv2_analysis_strm_id VARCHAR2(32);

BEGIN
  IF InStr(p_resolve_loop,'findStdDens')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a tank''s Std Density. Possibly due to a mis-configuration of tank attributes.');
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findStdDens,';
  END IF;

  lv2_calc_method := Nvl(p_method, Ec_Tank_version.DENSITY_METHOD(p_tank_object_id, p_daytime, '<=') );

  IF lv2_calc_method = 'MEASURED' THEN

    ln_retval := EcDp_Tank_Measurement.getStdDens(p_tank_object_id, p_meas_event_type, p_daytime);

  ELSIF lv2_calc_method = 'REF_VALUE' THEN

    lr_tank := ec_tank.row_by_object_id(p_tank_object_id);
    ln_retval := ec_tank_version.DENSITY(lr_tank.object_id, p_daytime, '<=');

  ELSIF lv2_calc_method = 'MASS_VOL' THEN

    ln_vol := EcBp_Tank.findNetStdOilVol(p_tank_object_id, p_meas_event_type, p_daytime, NULL, lv2_resolve_loop);
    IF ln_vol = 0 THEN
      ln_retval := NULL;
    ELSE
      ln_retval := EcBp_Tank.findNetMass(p_tank_object_id, p_meas_event_type, p_daytime, NULL, lv2_resolve_loop) / ln_vol;
    END IF;

  ELSIF lv2_calc_method = 'STREAM_SAMPLE_ANALYSIS' THEN
    lr_tank := ec_tank.row_by_object_id(p_tank_object_id);
    lv2_analysis_strm_id := ec_tank_version.analysis_stream_id(lr_tank.object_id, p_daytime, '<=');
    For cur_ofa_stdden in c_object_fluid_analysis(lv2_analysis_strm_id, p_daytime) Loop
      ln_retval  := cur_ofa_stdden.density;
    End Loop;

  ELSIF lv2_calc_method = 'TANK_TAP_ANALYSIS' THEN

    ln_retval := calcWeightedDensFromTaps(p_tank_object_id, p_daytime);

  ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN

    ln_retval := ue_tank_calculation.getStdDens(p_tank_object_id, p_meas_event_type, p_daytime);

  ELSE

    ln_retval := NULL;

  END IF;

  RETURN ln_retval;

END findStdDens;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findObsDens
--
-- Description    : Returns density at stock tank conditions
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

FUNCTION findObsDens(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method      VARCHAR2(300);
  ln_vol               NUMBER;
  ln_retval            NUMBER;
  lv2_resolve_loop     VARCHAR2(2000);
  lr_tank              TANK%ROWTYPE;
  lv2_analysis_strm_id VARCHAR2(32);

BEGIN
  IF InStr(p_resolve_loop,'findObsDens')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a tank''s Observed Density. Possibly due to a mis-configuration of tank attributes.');
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findObsDens,';
  END IF;

  lv2_calc_method := Nvl(p_method, Ec_Tank_version.OBS_DENS_METHOD(p_tank_object_id, p_daytime, '<=') );

  IF lv2_calc_method = 'MEASURED' THEN

    ln_retval := ec_tank_measurement.obs_density(p_tank_object_id, p_meas_event_type, p_daytime);

  ELSIF lv2_calc_method = 'MASS_VOL' THEN

    ln_vol := EcBp_Tank.findGrsOilVol(p_tank_object_id, p_meas_event_type, p_daytime, NULL, lv2_resolve_loop);
    IF ln_vol = 0 THEN
      ln_retval := NULL;
    ELSE
      ln_retval := EcBp_Tank.findGrsMass(p_tank_object_id, p_meas_event_type, p_daytime, NULL, lv2_resolve_loop) / ln_vol;
    END IF;

  ELSIF lv2_calc_method = 'STD_DENS' THEN

    ln_retval := EcBp_Tank.findStdDens(p_tank_object_id, p_meas_event_type, p_daytime, NULL, lv2_resolve_loop);

  ELSIF lv2_calc_method = 'API_TO_KGPERSM3' THEN

    ln_retval := (141.5 * 1000) / (131.5 + ec_tank_measurement.api(p_tank_object_id, p_meas_event_type, p_daytime));

  ELSIF lv2_calc_method = 'API_TO_LBSPERBBLS' THEN

    ln_retval := EcDp_Unit.convertValue((141.5 * 1000) / (131.5 + ec_tank_measurement.api(p_tank_object_id, p_meas_event_type, p_daytime)), 'KGPERSM3', 'LBSPERBBLS');


  ELSIF lv2_calc_method = 'STREAM_SAMPLE_ANALYSIS' THEN
    lr_tank := ec_tank.row_by_object_id(p_tank_object_id);
    lv2_analysis_strm_id := ec_tank_version.analysis_stream_id(lr_tank.object_id, p_daytime, '<=');
    For cur_ofa_obsden in c_object_fluid_analysis(lv2_analysis_strm_id, p_daytime) Loop
      ln_retval  := cur_ofa_obsden.density_obs;
    End Loop;

  ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN

    ln_retval := ue_tank_calculation.getObsDens(p_tank_object_id, p_meas_event_type, p_daytime);


  ELSE

    ln_retval := NULL;

  END IF;

  RETURN ln_retval;

END findObsDens;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcWeightedDensFromTaps
--
-- Description    : Returns weighted density from taps
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

FUNCTION calcWeightedDensFromTaps(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_daytime            DATE)
RETURN NUMBER
--</EC-DOC>
IS
  ln_sum        NUMBER;
  ln_prev_tap_volume NUMBER;
  ln_tap_volume NUMBER;
  ln_max_height NUMBER;
  ln_density_override NUMBER;

  -- get all tap heights that have a density recorded.
  CURSOR c_tank_tap_data IS
  SELECT tta.height, tta.density
  FROM tank_analysis ta,
       tank_tap_analysis tta
  WHERE ta.analysis_no=tta.analysis_no
  AND ta.object_id=p_tank_object_id
  AND ta.valid_from_date=
    (SELECT MAX(ta2.valid_from_date) FROM tank_analysis ta2
     WHERE ta2.object_id=ta.object_id
     AND ta2.valid_from_date <= p_daytime)
  AND tta.density IS NOT NULL
  ORDER BY height ASC;

BEGIN
  ln_sum := 0;
  ln_prev_tap_volume := 0;

  ln_density_override := ec_tank_analysis.tank_density_override(EcBp_Tank.getAnalysisNo(p_tank_object_id, p_daytime));
  IF ln_density_override IS NULL THEN
    FOR mycur IN c_tank_tap_data LOOP
      -- will be used to get the max volume in final division outside of cursor
      ln_max_height := mycur.height;
      -- this is the volume of current height minus previous height
      ln_tap_volume := Ecdp_Tank_Strapping.findVolumeFromDip(p_tank_object_id, mycur.height, p_daytime) - ln_prev_tap_volume;
      -- multiply current volume with assosiated density and add to total sum
      ln_sum := ln_sum + (ln_tap_volume * mycur.density);
      ln_prev_tap_volume := Ecdp_Tank_Strapping.findVolumeFromDip(p_tank_object_id, mycur.height, p_daytime);
    END LOOP;
    IF ln_prev_tap_volume > 0 THEN
    -- to find final weighted density, divide the total sum by the volume of the final height
      RETURN ln_sum/ln_prev_tap_volume;
    ELSE
      RETURN NULL;
    END IF;
  ELSE
    RETURN ln_density_override;
  END IF;

END calcWeightedDensFromTaps;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcWeightedBSWFromTaps
--
-- Description    : Returns weighted bsw from taps
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

FUNCTION calcWeightedBSWFromTaps(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_daytime            DATE)
RETURN NUMBER
--</EC-DOC>
IS
  ln_sum        NUMBER;
  ln_prev_tap_volume NUMBER;
  ln_tap_volume NUMBER;
  ln_max_height NUMBER;
  ln_bsw_override NUMBER;

  -- get all tap heights that have a bsw recorded.
  CURSOR c_tank_tap_data IS
  SELECT tta.height, tta.bsw
  FROM tank_analysis ta,
       tank_tap_analysis tta
  WHERE ta.analysis_no=tta.analysis_no
  AND ta.object_id=p_tank_object_id
  AND ta.valid_from_date=
    (SELECT MAX(ta2.valid_from_date) FROM tank_analysis ta2
     WHERE ta2.object_id=ta.object_id
     AND ta2.valid_from_date <= p_daytime)
  AND tta.bsw IS NOT NULL
  ORDER BY height ASC;

BEGIN
  ln_sum := 0;
  ln_prev_tap_volume := 0;
  ln_bsw_override := ec_tank_analysis.tank_bsw_override(EcBp_Tank.getAnalysisNo(p_tank_object_id, p_daytime));
  IF ln_bsw_override IS NULL THEN
    FOR mycur IN c_tank_tap_data LOOP
      -- will be used to get the max volume in final division outside of cursor
      ln_max_height := mycur.height;
      -- this is the volume of current height minus previous height
      ln_tap_volume := Ecdp_Tank_Strapping.findVolumeFromDip(p_tank_object_id, mycur.height, p_daytime) - ln_prev_tap_volume;
      -- multiply current volume with assosiated bsw and add to total sum
      ln_sum := ln_sum + (ln_tap_volume * mycur.bsw);
      ln_prev_tap_volume := Ecdp_Tank_Strapping.findVolumeFromDip(p_tank_object_id, mycur.height, p_daytime);
    END LOOP;
    IF ln_prev_tap_volume > 0 THEN
      -- to find final weighted bsw, divide the total sum by the volume of the final height. Return fraction
      RETURN ln_sum/ln_prev_tap_volume/100;
    ELSE
      RETURN NULL;
    END IF;
  ELSE
    RETURN ln_bsw_override/100;
  END IF;

END calcWeightedBSWFromTaps;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findVolumeCorrectionFactor
--
-- Description    : Returns shrinkage factor from storage to standard conditions
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: EcDp_Tank_Measurement.getVolumeCorrectionFactor
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION findVolumeCorrectionFactor(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method      VARCHAR2(300);
  ln_retval            NUMBER;
  lv2_resolve_loop     VARCHAR2(2000);

BEGIN
  IF InStr(p_resolve_loop,'findVolumeCorrectionFactor')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a tank''s Volume Correction Factor. Possibly due to a mis-configuration of tank attributes.');
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findVolumeCorrectionFactor,';
  END IF;

  lv2_calc_method := Nvl(p_method, Ec_tank_version.VCF_METHOD(p_tank_object_id, p_daytime, '<=') );

  IF lv2_calc_method = 'API' THEN

    ln_retval := EcDp_Tank_Measurement.getVolumeCorrectionFactor(p_tank_object_id, p_meas_event_type, p_daytime);

  ELSIF lv2_calc_method = 'NO_VCF' THEN

    ln_retval := 1;

  ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN

           ln_retval := ue_tank_calculation.getVolumeCorrectionFactor(p_tank_object_id, p_meas_event_type, p_daytime);

  ELSE

    ln_retval := NULL;

  END IF;

  RETURN ln_retval;

END findVolumeCorrectionFactor;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findFreeWaterVol
--
-- Description    : Returns free water volume (at stock tank conditions)
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

FUNCTION findFreeWaterVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method      VARCHAR2(300);
  ln_retval            NUMBER;
  lv2_resolve_loop     VARCHAR2(2000);

BEGIN
  IF InStr(p_resolve_loop,'findFreeWaterVol')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a tank''s Free Water Volume. Possibly due to a mis-configuration of tank attributes.');
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findFreeWaterVol,';
  END IF;

  lv2_calc_method := Nvl(p_method, Ec_Tank_version.FREE_WAT_VOL_MET(p_tank_object_id, p_daytime, '<=') );

  IF lv2_calc_method = 'MEASURED' THEN

    ln_retval := EcDp_Tank_Measurement.getWaterVol(p_tank_object_id, p_meas_event_type, p_daytime);

  ELSIF lv2_calc_method = 'ZERO' THEN

    ln_retval := 0;

  ELSIF lv2_calc_method = 'STRAPPING' THEN

    ln_retval := EcDp_Tank_Strapping.findVolumeFromDip(p_tank_object_id,
                                                       EcDp_Tank_Measurement.getWaterDipLevel(p_tank_object_id, p_meas_event_type, p_daytime),
                                                       p_daytime);
  ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN

           ln_retval := ue_tank_calculation.getFreeWaterVol(p_tank_object_id, p_meas_event_type, p_daytime);

  ELSE

    ln_retval := NULL;

  END IF;

  RETURN ln_retval;

END findFreeWaterVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWaterVol
--
-- Description    : Returns total water volume for tank (at stock tank conditions)
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

FUNCTION findWaterVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_calc_method      VARCHAR2(300);
  ln_retval            NUMBER;
  ln_free_wat_vol      NUMBER;
  ln_grs_oil_vol       NUMBER;
  ln_bsw               NUMBER;
   ln_bsw_vol         NUMBER;
  lv2_resolve_loop     VARCHAR2(2000);

BEGIN
  IF InStr(p_resolve_loop,'findWaterVol')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a tank''s Water Volume. Possibly due to a mis-configuration of tank attributes.');
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findWaterVol,';
  END IF;

  lv2_calc_method := Nvl(p_method, Ec_Tank_Version.WATER_VOL_METHOD(p_tank_object_id, p_daytime, '<=') );

 IF ec_tank_version.tank_well(p_tank_object_id,p_daytime,'<=') IS NOT NULL THEN --calculate well tank BSW

    ln_free_wat_vol := nvl(EcBp_Tank.findFreeWaterVol(p_tank_object_id, p_meas_event_type, p_daytime, NULL, lv2_resolve_loop),0);
    ln_grs_oil_vol  := nvl(EcBp_Tank.findGrsStdOilVol(p_tank_object_id, p_meas_event_type, p_daytime, NULL, lv2_resolve_loop),0);
    ln_bsw_vol := nvl(EcBp_Tank.findBSWVol(p_tank_object_id,p_meas_event_type,p_daytime),0);

    ln_retval := ln_free_wat_vol + ( ln_grs_oil_vol * ln_bsw_vol);

  ELSE
    IF lv2_calc_method = 'ZERO' THEN

        ln_retval := 0;

      ELSIF lv2_calc_method = 'GRS_VOL' THEN

        ln_retval := EcBp_Tank.findGrsVol(p_tank_object_id, p_meas_event_type, p_daytime);

      ELSIF lv2_calc_method = 'FREE_BSW' THEN

        ln_free_wat_vol := EcBp_Tank.findFreeWaterVol(p_tank_object_id, p_meas_event_type, p_daytime, NULL, lv2_resolve_loop);
        ln_grs_oil_vol  := EcBp_Tank.findGrsStdOilVol(p_tank_object_id, p_meas_event_type, p_daytime, NULL, lv2_resolve_loop);

        ln_bsw := EcBp_Tank.findBSWVol(p_tank_object_id, p_meas_event_type, p_daytime, NULL, lv2_resolve_loop);
        ln_retval := ln_free_wat_vol + ( ln_grs_oil_vol * ln_bsw);

      ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN

               ln_retval := ue_tank_calculation.getWaterVol(p_tank_object_id, p_meas_event_type, p_daytime);
      ELSE

        ln_retval := NULL;

      END IF;
   END IF;

  RETURN ln_retval;

END findWaterVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGrsOilVol
--
-- Description    : Returns total oil volume for tank (at stock tank conditions)
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

FUNCTION findGrsOilVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  ln_retval            NUMBER;
  ln_grs_vol           NUMBER;
  ln_free_wat_vol      NUMBER;
  ln_roof_displacement NUMBER;
  lv2_resolve_loop     VARCHAR2(2000);

BEGIN
  IF InStr(p_resolve_loop,'findGrsOilVol')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a tank''s Grs Oil Volume. Possibly due to a mis-configuration of tank attributes.');
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findGrsOilVol,';
  END IF;

  ln_grs_vol           := EcBp_Tank.findGrsVol(p_tank_object_id, p_meas_event_type, p_daytime, p_method, lv2_resolve_loop);
  ln_free_wat_vol      := Nvl(EcBp_Tank.findFreeWaterVol(p_tank_object_id, p_meas_event_type, p_daytime, p_method, lv2_resolve_loop),0);
  ln_roof_displacement := Nvl(calcRoofDisplacementVol(p_tank_object_id,
                                         p_meas_event_type,
                                         EcDp_Tank_Measurement.getGrsDipLevel(p_tank_object_id, p_meas_event_type, p_daytime),
                                         p_daytime,
                                         NULL,
                                         lv2_resolve_loop), 0);

  ln_retval := ln_grs_vol - ln_roof_displacement - ln_free_wat_vol;

  RETURN ln_retval;

END findGrsOilVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGrsStdOilVol
--
-- Description    : Returns total oil volume for tank (at standard conditions)
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

FUNCTION findGrsStdOilVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  ln_retval            NUMBER;
  ln_grs_vol           NUMBER;
  ln_vcf               NUMBER;
  lv2_resolve_loop     VARCHAR2(2000);

BEGIN
  IF InStr(p_resolve_loop,'findGrsStdOilVol')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a tank''s Grs Std Oil Volume. Possibly due to a mis-configuration of tank attributes.');
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findGrsStdOilVol,';
  END IF;

  ln_grs_vol      := EcBp_Tank.findGrsOilVol(p_tank_object_id, p_meas_event_type, p_daytime, NULL, lv2_resolve_loop);
  ln_vcf          := EcBp_Tank.findVolumeCorrectionFactor(p_tank_object_id, p_meas_event_type, p_daytime, NULL, lv2_resolve_loop);

  ln_retval := ln_grs_vol * ln_vcf;

  RETURN ln_retval;

END findGrsStdOilVol;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findClosingGrsStdOilVol
--
-- Description    : Returns closing grs std oil volume at tank conditions, passed in daytime's reading
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

FUNCTION findClosingGrsStdOilVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_period           VARCHAR2(300);
  ld_daytime           DATE;
  ln_retval            NUMBER;
  lv2_resolve_loop     VARCHAR2(2000);
  lv2_meas_event_type  VARCHAR2(32);
  lv2_bf_usage         VARCHAR2(32);

CURSOR c_closing_grs_std_oil_vol(cp_object_id tank_measurement.object_id%TYPE,
                      cp_measurement_type tank_measurement.measurement_event_type%TYPE,
                      cp_daytime date) IS
select daytime from tank_measurement
where object_id = cp_object_id
and measurement_event_type = cp_measurement_type
and daytime <= cp_daytime
order by daytime desc;

BEGIN
  IF InStr(p_resolve_loop,'findClosingGrsVol')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a tank''s Closing Grs Volume. Possibly due to a mis-configuration of tank attributes.');
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findClosingGrsVol,';
  END IF;

  lv2_bf_usage := ec_tank_version.bf_usage(p_tank_object_id, p_daytime ,'<=');
  IF lv2_bf_usage = 'PO.0082' THEN
    lv2_meas_event_type := 'EVENT_CLOSING';
  ELSE
    lv2_meas_event_type := 'DAY_CLOSING';
  END IF;

  lv2_period := EcDp_Tank.getTankMeterFrequency(p_tank_object_id, p_daytime);
  IF lv2_period = 'DAY' THEN
    ld_daytime := p_daytime; -- do nothing
  ELSIF lv2_period = 'MONTH' THEN
    ld_daytime := LAST_DAY(p_daytime);
  ELSIF lv2_period = 'EVENT' THEN
    FOR mycur in c_closing_grs_std_oil_vol(p_tank_object_id, lv2_meas_event_type, p_daytime) LOOP
      IF EcBp_Tank.findGrsStdOilVol(p_tank_object_id,lv2_meas_event_type,mycur.daytime) IS NOT NULL THEN
        ld_daytime := mycur.daytime;
        EXIT;
      END IF;
    END LOOP;
  END IF;

  IF ld_daytime < EcDp_Tank.getStartDate(p_tank_object_id) THEN
    ln_retval := 0;
  ELSE
    ln_retval := EcBp_Tank.findGrsStdOilVol(p_tank_object_id, lv2_meas_event_type, ld_daytime, p_method, lv2_resolve_loop);
  END IF;

  RETURN ln_retval;

END findClosingGrsStdOilVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findNetStdOilVol
--
-- Description    : Returns net oil volume for tank (at standard conditions)
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

FUNCTION findNetStdOilVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  ln_retval            NUMBER;
  ln_grs_vol           NUMBER;
  ln_bsw_vol           NUMBER;
  lv2_resolve_loop     VARCHAR2(2000);
  lv2_calc_method      VARCHAR2(300);
  ln_bitumen_dens      NUMBER;
  ln_diluent_dens      NUMBER;
  ln_tank_dens         NUMBER;

BEGIN
  IF InStr(p_resolve_loop,'findNetStdOilVol')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a tank''s Net Std Oil Volume. Possibly due to a mis-configuration of tank attributes.');
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findNetStdOilVol,';
  END IF;

  lv2_calc_method := Nvl(p_method, Ec_Tank_version.NET_VOL_METHOD(p_tank_object_id, p_daytime, '<=') );

  IF (lv2_calc_method IN ('GRS_BSW_DILUENT','GRS_VOL_BSW','GRS_BSW_API_SHRINKAGE') OR lv2_calc_method IS NULL) THEN
    -- get Gross Std Oil Vol, this includes shrinkage calc
    ln_grs_vol:= EcBp_Tank.findGrsStdOilVol(p_tank_object_id, p_meas_event_type, p_daytime, NULL, lv2_resolve_loop);

	IF ln_grs_vol = 0 THEN
      ln_retval := 0;
    ELSE
		-- deduct bsw
		IF ec_tank_version.tank_well(p_tank_object_id,p_daytime,'<=') IS NULL THEN
		  ln_bsw_vol:= EcBp_Tank.findBSWVol(p_tank_object_id, p_meas_event_type, p_daytime, NULL, lv2_resolve_loop);
		  ln_retval := ln_grs_vol * (1 - ln_bsw_vol);
		ELSE --the tank is tank well
		  ln_bsw_vol:= EcBp_Tank.findBSWVol(p_tank_object_id,p_meas_event_type,p_daytime);
		  ln_retval := ln_grs_vol * (1 - ln_bsw_vol);
		END IF;
	END IF;

	IF ln_retval > 0 THEN
		-- continue to deduct diluent if method is GRS_BSW_DILUENT
		IF lv2_calc_method = 'GRS_BSW_DILUENT' THEN
		  ln_bitumen_dens := findBitumenDens(p_tank_object_id,p_meas_event_type,p_daytime);
		  ln_diluent_dens := findDiluentDens(p_tank_object_id,p_meas_event_type,p_daytime);
		  -- get Tank density
		  ln_tank_dens := findStdDens(p_tank_object_id, p_meas_event_type, p_daytime, NULL, lv2_resolve_loop);
		  -- fraction of oil in tank: 1 - ((bitumen density - tank density) / (bitumen density - diluent density))
		  ln_retval := ln_retval * (1 - ((ln_bitumen_dens - ln_tank_dens) / (ln_bitumen_dens - ln_diluent_dens)))* nvl(Ue_Tank_Calculation.findBlendShrinkageFactor(p_tank_object_id,p_meas_event_type,p_daytime,ln_diluent_dens,ln_bitumen_dens,ln_tank_dens),1);
		ELSIF lv2_calc_method = 'GRS_BSW_API_SHRINKAGE' THEN
		  ln_retval := (ln_retval + findShrunkVol(p_tank_object_id,p_meas_event_type,p_daytime)) *
					   (1 - EcBp_VCF.calcDiluentConcentration(p_tank_object_id,p_daytime));
		END IF;
	END IF;

  ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_retval := ue_tank_calculation.findNetStdOilVol(p_tank_object_id, p_meas_event_type, p_daytime);
  ELSE -- unknown method
    ln_retval := NULL;
  END IF;

  RETURN ln_retval;

END findNetStdOilVol;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findNetDiluentVol
--
-- Description    : Returns net diluent volume for tank (at standard conditions)
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

FUNCTION findNetDiluentVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  ln_retval            NUMBER;
  ln_grs_vol           NUMBER;
  ln_bsw_vol           NUMBER;
  lv2_resolve_loop     VARCHAR2(2000);
  lv2_calc_method      VARCHAR2(300);
  ln_bitumen_dens      NUMBER;
  ln_diluent_dens      NUMBER;
  ln_tank_dens         NUMBER;
BEGIN
  IF InStr(p_resolve_loop,'findNetDiluentVol')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a tank''s Net Diluent Volume. Possibly due to a mis-configuration of tank attributes.');
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findNetDiluentVol,';
  END IF;
  lv2_calc_method := Nvl(p_method, Ec_Tank_version.DILUENT_METHOD(p_tank_object_id, p_daytime, '<=') );

  IF lv2_calc_method = 'DENSITY_CALC' THEN
    ln_retval := findNetStdOilVol(p_tank_object_id, p_meas_event_type, p_daytime, 'GRS_VOL_BSW', lv2_resolve_loop);
	IF ln_retval <> 0 THEN
		ln_bitumen_dens := findBitumenDens(p_tank_object_id,p_meas_event_type,p_daytime);
		ln_diluent_dens := findDiluentDens(p_tank_object_id,p_meas_event_type,p_daytime);
		-- get Tank density
		ln_tank_dens := findStdDens(p_tank_object_id, p_meas_event_type, p_daytime, NULL, lv2_resolve_loop);
		-- fraction of oil in tank: ((bitumen density - tank density) / (bitumen density - diluent density))
		ln_retval := ln_retval * ((ln_bitumen_dens - ln_tank_dens) / (ln_bitumen_dens - ln_diluent_dens))* nvl(Ue_Tank_Calculation.findBlendShrinkageFactor(p_tank_object_id,p_meas_event_type,p_daytime,ln_diluent_dens,ln_bitumen_dens,ln_tank_dens),1);
	END IF;
  ELSIF lv2_calc_method = 'API_BLEND_SHRINKAGE' THEN
    ln_retval := findNetStdOilVol(p_tank_object_id, p_meas_event_type, p_daytime, 'GRS_VOL_BSW', lv2_resolve_loop);
	IF ln_retval > 0 THEN
		ln_retval := (ln_retval + findShrunkVol(p_tank_object_id,p_meas_event_type,p_daytime)) *
					 (EcBp_VCF.calcDiluentConcentration(p_tank_object_id,p_daytime));
	END IF;
--  ELSIF lv2_calc_method = 'DILUENT_CUT' THEN
--    ln_retval := findNetStdOilVol(p_tank_object_id, p_meas_event_type, p_daytime, 'GRS_VOL_BSW', lv2_resolve_loop) *
--                 ec_tank_measurement.diluent_cut(p_tank_object_id, p_meas_event_type, p_daytime);
  ELSIF lv2_calc_method = 'DILUENT_TANK' THEN
    ln_retval := findClosingNetVol(p_tank_object_id, p_meas_event_type, p_daytime, 'GRS_VOL_BSW', lv2_resolve_loop);

  ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_retval := ue_tank_calculation.findNetDiluentVol(p_tank_object_id, p_meas_event_type, p_daytime);
  ELSE -- unknown method
    ln_retval := NULL;
  END IF;

  RETURN ln_retval;

END findNetDiluentVol;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findShrunkVol
--
-- Description    : Returns shrunk volume due to blending diluent and bitumen using API 12.3 standard
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

FUNCTION findShrunkVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE)
RETURN NUMBER
--</EC-DOC>
IS
  ln_retval            NUMBER;

BEGIN
  IF Ec_Tank_version.NET_VOL_METHOD(p_tank_object_id, p_daytime, '<=') = 'GRS_BSW_API_SHRINKAGE' THEN
    -- hardcode method GRS_VOL_BSW because we only want net of water here. Not hardcoding will lead to loop.
    ln_retval := findNetStdOilVol(p_tank_object_id, p_meas_event_type, p_daytime, 'GRS_VOL_BSW');
	IF ln_retval > 0 THEN
		ln_retval := ln_retval - (ln_retval * EcBp_VCF.calcShrinkageFactor(p_tank_object_id,p_daytime));
	END IF;
  ELSE
    ln_retval := NULL;
  END IF;
RETURN ln_retval;

END findShrunkVol;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findAvailableVol
--
-- Description    : Returns available volume for tank (at stock tank conditions) (max volume - grs_vol)
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

FUNCTION findAvailableVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  ln_retval            NUMBER;
  ln_max_vol           NUMBER;
  ln_grs_vol           NUMBER;
  lv2_resolve_loop     VARCHAR2(2000);

BEGIN
  IF InStr(p_resolve_loop,'findAvailableVol')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a tank''s Available Volume. Possibly due to a mis-configuration of tank attributes.');
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findAvailableVol,';
  END IF;

  ln_grs_vol      := EcBp_Tank.findGrsStdVol(p_tank_object_id, p_meas_event_type, p_daytime, p_method, lv2_resolve_loop);
  ln_max_vol      := EcDp_Tank.getMaxVol(p_tank_object_id, p_daytime);

  ln_retval := Greatest((ln_max_vol - ln_grs_vol), 0);

  RETURN ln_retval;

END findAvailableVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findOpeningGrsVol
--
-- Description    : Returns grs volume at tank conditions, previous reading
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

FUNCTION findOpeningGrsVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_period           VARCHAR2(300);
  ld_prev_daytime      DATE;
  ln_retval            NUMBER;
  lv2_resolve_loop     VARCHAR2(2000);
  lv2_meas_event_type  VARCHAR2(32);
  lv2_bf_usage         VARCHAR2(32);

CURSOR c_closing_grs_vol(cp_object_id tank_measurement.object_id%TYPE,
                      cp_measurement_type tank_measurement.measurement_event_type%TYPE,
                      cp_daytime date) IS
select daytime from tank_measurement
where object_id = cp_object_id
and measurement_event_type = cp_measurement_type
and daytime < cp_daytime
order by daytime desc;

BEGIN
  IF InStr(p_resolve_loop,'findOpeningGrsVol')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a tank''s Opening Grs Volume. Possibly due to a mis-configuration of tank attributes.');
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findOpeningGrsVol,';
  END IF;

  lv2_bf_usage := ec_tank_version.bf_usage(p_tank_object_id, p_daytime ,'<=');
  IF lv2_bf_usage = 'PO.0082' THEN
    lv2_meas_event_type := 'EVENT_CLOSING';
  ELSE
    lv2_meas_event_type := 'DAY_CLOSING';
  END IF;

  lv2_period := EcDp_Tank.getTankMeterFrequency(p_tank_object_id, p_daytime);
  IF lv2_period = 'DAY' THEN
    ld_prev_daytime := p_daytime - 1;
  ELSIF lv2_period = 'MONTH' THEN
    ld_prev_daytime := LAST_DAY(ADD_MONTHS(p_daytime, -1));
  ELSIF lv2_period = 'EVENT' THEN
    FOR mycur in c_closing_grs_vol(p_tank_object_id, lv2_meas_event_type, p_daytime) LOOP
      IF EcBp_Tank.findGrsVol(p_tank_object_id,lv2_meas_event_type,mycur.daytime) IS NOT NULL THEN
        ld_prev_daytime := mycur.daytime;
        EXIT;
      END IF;
    END LOOP;
  END IF;

  IF ld_prev_daytime < EcDp_Tank.getStartDate(p_tank_object_id) THEN
    ln_retval := 0;
  ELSE
    ln_retval := EcBp_Tank.findGrsVol(p_tank_object_id, lv2_meas_event_type, ld_prev_daytime, p_method, lv2_resolve_loop);
  END IF;

  RETURN ln_retval;

END findOpeningGrsVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findOpeningGrsMass
--
-- Description    : Returns grs mass at tank conditions, previous reading
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

FUNCTION findOpeningGrsMass(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_period           VARCHAR2(300);
  ld_prev_daytime      DATE;
  ln_retval            NUMBER;
  lv2_resolve_loop     VARCHAR2(2000);
  lv2_meas_event_type  VARCHAR2(32);
  lv2_bf_usage         VARCHAR2(32);

CURSOR c_closing_grs_mass(cp_object_id tank_measurement.object_id%TYPE,
                      cp_measurement_type tank_measurement.measurement_event_type%TYPE,
                      cp_daytime date) IS
select daytime from tank_measurement
where object_id = cp_object_id
and measurement_event_type = cp_measurement_type
and daytime < cp_daytime
order by daytime desc;

BEGIN
  IF InStr(p_resolve_loop,'findOpeningGrsVol')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a tank''s Opening Grs Volume. Possibly due to a mis-configuration of tank attributes.');
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findOpeningGrsVol,';
  END IF;

  lv2_bf_usage := ec_tank_version.bf_usage(p_tank_object_id, p_daytime ,'<=');
  IF lv2_bf_usage = 'PO.0082' THEN
    lv2_meas_event_type := 'EVENT_CLOSING';
  ELSE
    lv2_meas_event_type := 'DAY_CLOSING';
  END IF;

  lv2_period := EcDp_Tank.getTankMeterFrequency(p_tank_object_id, p_daytime);
  IF lv2_period = 'DAY' THEN
    ld_prev_daytime := p_daytime - 1;
  ELSIF lv2_period = 'MONTH' THEN
    ld_prev_daytime := LAST_DAY(ADD_MONTHS(p_daytime, -1));
  ELSIF lv2_period = 'EVENT' THEN
    FOR mycur in c_closing_grs_mass(p_tank_object_id, lv2_meas_event_type, p_daytime) LOOP
      IF EcBp_Tank.findGrsMass(p_tank_object_id,lv2_meas_event_type,mycur.daytime) IS NOT NULL THEN
        ld_prev_daytime := mycur.daytime;
  EXIT;
      END IF;
    END LOOP;
  END IF;

  IF ld_prev_daytime < EcDp_Tank.getStartDate(p_tank_object_id) THEN
    ln_retval := 0;
  ELSE
    ln_retval := EcBp_Tank.findGrsMass(p_tank_object_id, lv2_meas_event_type, ld_prev_daytime, p_method, lv2_resolve_loop);
  END IF;

  RETURN ln_retval;

END findOpeningGrsMass;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findClosingGrsVol
--
-- Description    : Returns closing grs volume at tank conditions, passed in daytime's reading
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

FUNCTION findClosingGrsVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_period           VARCHAR2(300);
  ld_daytime           DATE;
  ln_retval            NUMBER;
  lv2_resolve_loop     VARCHAR2(2000);
  lv2_meas_event_type  VARCHAR2(32);
  lv2_bf_usage         VARCHAR2(32);

CURSOR c_closing_grs_vol(cp_object_id tank_measurement.object_id%TYPE,
                      cp_measurement_type tank_measurement.measurement_event_type%TYPE,
                      cp_daytime date) IS
select daytime from tank_measurement
where object_id = cp_object_id
and measurement_event_type = cp_measurement_type
and daytime <= cp_daytime
order by daytime desc;

BEGIN
  IF InStr(p_resolve_loop,'findClosingGrsVol')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a tank''s Closing Grs Volume. Possibly due to a mis-configuration of tank attributes.');
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findClosingGrsVol,';
  END IF;

  lv2_bf_usage := ec_tank_version.bf_usage(p_tank_object_id, p_daytime ,'<=');
  IF lv2_bf_usage = 'PO.0082' THEN
    lv2_meas_event_type := 'EVENT_CLOSING';
  ELSE
	lv2_meas_event_type := 'DAY_CLOSING';
  END IF;

  lv2_period := EcDp_Tank.getTankMeterFrequency(p_tank_object_id, p_daytime);
  IF lv2_period = 'DAY' THEN
    ld_daytime := p_daytime; -- do nothing
  ELSIF lv2_period = 'MONTH' THEN
    ld_daytime := LAST_DAY(p_daytime);
  ELSIF lv2_period = 'EVENT' THEN
    FOR mycur in c_closing_grs_vol(p_tank_object_id, lv2_meas_event_type, p_daytime) LOOP
      IF EcBp_Tank.findGrsVol(p_tank_object_id,lv2_meas_event_type,mycur.daytime) IS NOT NULL THEN
        ld_daytime := mycur.daytime;
        EXIT;
      END IF;
    END LOOP;
  END IF;

  IF ld_daytime < EcDp_Tank.getStartDate(p_tank_object_id) THEN
    ln_retval := 0;
  ELSE
    ln_retval := EcBp_Tank.findGrsVol(p_tank_object_id, lv2_meas_event_type, ld_daytime, p_method, lv2_resolve_loop);
  END IF;

  RETURN ln_retval;

END findClosingGrsVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findClosingGrsMass
--
-- Description    : Returns closing grs mass at tank conditions, passed in daytime's reading
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

FUNCTION findClosingGrsMass(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_period           VARCHAR2(300);
  ld_daytime           DATE;
  ln_retval            NUMBER;
  lv2_resolve_loop     VARCHAR2(2000);
  lv2_meas_event_type  VARCHAR2(32);
  lv2_bf_usage         VARCHAR2(32);

CURSOR c_closing_grs_mass(cp_object_id tank_measurement.object_id%TYPE,
                      cp_measurement_type tank_measurement.measurement_event_type%TYPE,
                      cp_daytime date) IS
select daytime from tank_measurement
where object_id = cp_object_id
and measurement_event_type = cp_measurement_type
and daytime <= cp_daytime
order by daytime desc;

BEGIN
  IF InStr(p_resolve_loop,'findClosingGrsVol')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a tank''s Closing Grs Volume. Possibly due to a mis-configuration of tank attributes.');
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findClosingGrsVol,';
  END IF;

  lv2_bf_usage := ec_tank_version.bf_usage(p_tank_object_id, p_daytime ,'<=');
  IF lv2_bf_usage = 'PO.0082' THEN
    lv2_meas_event_type := 'EVENT_CLOSING';
  ELSE
	lv2_meas_event_type := 'DAY_CLOSING';
  END IF;

  lv2_period := EcDp_Tank.getTankMeterFrequency(p_tank_object_id, p_daytime);
  IF lv2_period = 'DAY' THEN
    ld_daytime := p_daytime; -- do nothing
  ELSIF lv2_period = 'MONTH' THEN
    ld_daytime := LAST_DAY(p_daytime);
  ELSIF lv2_period = 'EVENT' THEN
    FOR mycur in c_closing_grs_mass(p_tank_object_id, lv2_meas_event_type, p_daytime) LOOP
      IF EcBp_Tank.findGrsMass(p_tank_object_id, lv2_meas_event_type, mycur.daytime) IS NOT NULL THEN
        ld_daytime := mycur.daytime;
  EXIT;
      END IF;
    END LOOP;
  END IF;

  IF ld_daytime < EcDp_Tank.getStartDate(p_tank_object_id) THEN
    ln_retval := 0;
  ELSE
    ln_retval := EcBp_Tank.findGrsMass(p_tank_object_id, lv2_meas_event_type, ld_daytime, p_method, lv2_resolve_loop);
  END IF;

  RETURN ln_retval;

END findClosingGrsMass;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findOpeningDiluentVol
--
-- Description    : Returns Net volume at tank conditions, previous reading
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

FUNCTION findOpeningDiluentVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_period           VARCHAR2(300);
  ld_prev_daytime      DATE;
  ln_retval            NUMBER;
  lv2_resolve_loop     VARCHAR2(2000);
  lv2_meas_event_type  VARCHAR2(32);
  lv2_bf_usage         VARCHAR2(32);

CURSOR c_closing_net_vol(cp_object_id tank_measurement.object_id%TYPE,
                      cp_measurement_type tank_measurement.measurement_event_type%TYPE,
                      cp_daytime date) IS
select daytime from tank_measurement
where object_id = cp_object_id
and measurement_event_type = cp_measurement_type
and daytime < cp_daytime
order by daytime desc;

BEGIN
  IF InStr(p_resolve_loop,'findOpeningDiluentVol')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a tank''s Opening Diluent Volume. Possibly due to a mis-configuration of tank attributes.');
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findOpeningDiluentVol,';
  END IF;

  lv2_bf_usage := ec_tank_version.bf_usage(p_tank_object_id, p_daytime ,'<=');
  IF lv2_bf_usage = 'PO.0082' THEN
    lv2_meas_event_type := 'EVENT_CLOSING';
  ELSE
	lv2_meas_event_type := 'DAY_CLOSING';
  END IF;
  lv2_period := EcDp_Tank.getTankMeterFrequency(p_tank_object_id, p_daytime);
  IF lv2_period = 'DAY' THEN
    ld_prev_daytime := p_daytime - 1;
  ELSIF lv2_period = 'MONTH' THEN
    ld_prev_daytime := LAST_DAY(ADD_MONTHS(p_daytime, -1));
  ELSIF lv2_period = 'EVENT' THEN
    FOR mycur in c_closing_net_vol(p_tank_object_id, lv2_meas_event_type, p_daytime) LOOP
      IF EcBp_Tank.findNetDiluentVol(p_tank_object_id,lv2_meas_event_type,mycur.daytime) IS NOT NULL THEN
        ld_prev_daytime := mycur.daytime;
        EXIT;
      END IF;
    END LOOP;
  END IF;

  IF ld_prev_daytime < EcDp_Tank.getStartDate(p_tank_object_id) THEN
    ln_retval := 0;
  ELSE
    ln_retval := EcBp_Tank.findNetDiluentVol(p_tank_object_id, lv2_meas_event_type, ld_prev_daytime, p_method, lv2_resolve_loop);
  END IF;

  RETURN ln_retval;

END findOpeningDiluentVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findClosingDiluentVol
--
-- Description    : Returns closing diluent volume at tank conditions, passed in daytime's reading
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

FUNCTION findClosingDiluentVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_period           VARCHAR2(300);
  ld_daytime           DATE;
  ln_retval            NUMBER;
  lv2_resolve_loop     VARCHAR2(2000);
  lv2_meas_event_type  VARCHAR2(32);
  lv2_bf_usage         VARCHAR2(32);

CURSOR c_closing_net_vol(cp_object_id tank_measurement.object_id%TYPE,
                      cp_measurement_type tank_measurement.measurement_event_type%TYPE,
                      cp_daytime date) IS
select daytime from tank_measurement
where object_id = cp_object_id
and measurement_event_type = cp_measurement_type
and daytime <= cp_daytime
order by daytime desc;

BEGIN
  IF InStr(p_resolve_loop,'findClosingDiluentVol')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a tank''s Closing Diluent Volume. Possibly due to a mis-configuration of tank attributes.');
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findClosingDiluentVol,';
  END IF;

  lv2_bf_usage := ec_tank_version.bf_usage(p_tank_object_id, p_daytime ,'<=');
  IF lv2_bf_usage = 'PO.0082' THEN
    lv2_meas_event_type := 'EVENT_CLOSING';
  ELSE
	lv2_meas_event_type := 'DAY_CLOSING';
  END IF;

  lv2_period := EcDp_Tank.getTankMeterFrequency(p_tank_object_id, p_daytime);
  IF lv2_period = 'DAY' THEN
    ld_daytime := p_daytime; -- do nothing
  ELSIF lv2_period = 'MONTH' THEN
    ld_daytime := LAST_DAY(p_daytime);
  ELSIF lv2_period = 'EVENT' THEN
    FOR mycur in c_closing_net_vol(p_tank_object_id, lv2_meas_event_type, p_daytime) LOOP
      IF EcBp_Tank.findNetDiluentVol(p_tank_object_id,lv2_meas_event_type,mycur.daytime) IS NOT NULL THEN
        ld_daytime := mycur.daytime;
  EXIT;
      END IF;
    END LOOP;
  END IF;

  IF ld_daytime < EcDp_Tank.getStartDate(p_tank_object_id) THEN
    ln_retval := 0;
  ELSE
    ln_retval := EcBp_Tank.findNetDiluentVol(p_tank_object_id, lv2_meas_event_type, ld_daytime, p_method, lv2_resolve_loop);
  END IF;

  RETURN ln_retval;

END findClosingDiluentVol;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findOpeningNetVol
--
-- Description    : Returns Net volume at tank conditions, previous reading
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

FUNCTION findOpeningNetVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_period           VARCHAR2(300);
  ld_prev_daytime      DATE;
  ln_retval            NUMBER;
  lv2_resolve_loop     VARCHAR2(2000);
  lv2_meas_event_type  VARCHAR2(32);
  lv2_bf_usage         VARCHAR2(32);

CURSOR c_closing_net_vol(cp_object_id tank_measurement.object_id%TYPE,
                      cp_measurement_type tank_measurement.measurement_event_type%TYPE,
                      cp_daytime date) IS
select daytime from tank_measurement
where object_id = cp_object_id
and measurement_event_type = cp_measurement_type
and daytime < cp_daytime
order by daytime desc;

BEGIN
  IF InStr(p_resolve_loop,'findOpeningNetVol')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a tank''s Opening Net Volume. Possibly due to a mis-configuration of tank attributes.');
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findOpeningNetVol,';
  END IF;

  lv2_bf_usage := ec_tank_version.bf_usage(p_tank_object_id, p_daytime ,'<=');
  IF lv2_bf_usage = 'PO.0082' THEN
    lv2_meas_event_type := 'EVENT_CLOSING';
  ELSE
    lv2_meas_event_type := 'DAY_CLOSING';
  END IF;

  lv2_period := EcDp_Tank.getTankMeterFrequency(p_tank_object_id, p_daytime);
  IF lv2_period = 'DAY' THEN
    ld_prev_daytime := p_daytime - 1;
  ELSIF lv2_period = 'MONTH' THEN
    ld_prev_daytime := LAST_DAY(ADD_MONTHS(p_daytime, -1));
  ELSIF lv2_period = 'EVENT' THEN
    FOR mycur in c_closing_net_vol(p_tank_object_id, lv2_meas_event_type, p_daytime) LOOP
      IF EcBp_Tank.findNetStdOilVol(p_tank_object_id,lv2_meas_event_type,mycur.daytime) IS NOT NULL THEN
        ld_prev_daytime := mycur.daytime;
        EXIT;
      END IF;
    END LOOP;
  END IF;

  IF ld_prev_daytime < EcDp_Tank.getStartDate(p_tank_object_id) THEN
    ln_retval := 0;
  ELSE
    ln_retval := EcBp_Tank.findNetStdOilVol(p_tank_object_id, lv2_meas_event_type, ld_prev_daytime, p_method, lv2_resolve_loop);
  END IF;

  RETURN ln_retval;

END findOpeningNetVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findClosingNetVol
--
-- Description    : Returns closing Net volume at tank conditions, passed in daytime's reading
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

FUNCTION findClosingNetVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_period           VARCHAR2(300);
  ld_daytime           DATE;
  ln_retval            NUMBER;
  lv2_resolve_loop     VARCHAR2(2000);
  lv2_meas_event_type  VARCHAR2(32);
  lv2_bf_usage         VARCHAR2(32);

CURSOR c_closing_net_vol(cp_object_id tank_measurement.object_id%TYPE,
                      cp_measurement_type tank_measurement.measurement_event_type%TYPE,
                      cp_daytime date) IS
select daytime from tank_measurement
where object_id = cp_object_id
and measurement_event_type = cp_measurement_type
and daytime <= cp_daytime
order by daytime desc;

BEGIN

  IF InStr(p_resolve_loop,'findClosingNetVol')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a tank''s Closing Net Volume. Possibly due to a mis-configuration of tank attributes.');
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findClosingNetVol,';
  END IF;

  lv2_bf_usage := ec_tank_version.bf_usage(p_tank_object_id, p_daytime ,'<=');
  IF lv2_bf_usage = 'PO.0082' THEN
    lv2_meas_event_type := 'EVENT_CLOSING';
  ELSE
    lv2_meas_event_type := 'DAY_CLOSING';
  END IF;

  lv2_period := EcDp_Tank.getTankMeterFrequency(p_tank_object_id, p_daytime);
  IF lv2_period = 'DAY' THEN
    ld_daytime := p_daytime; -- do nothing
  ELSIF lv2_period = 'MONTH' THEN
    ld_daytime := LAST_DAY(p_daytime);
  ELSIF lv2_period = 'EVENT' THEN
    FOR mycur in c_closing_net_vol(p_tank_object_id, lv2_meas_event_type, p_daytime) LOOP
      IF EcBp_Tank.findNetStdOilVol(p_tank_object_id,lv2_meas_event_type,mycur.daytime) IS NOT NULL THEN
        ld_daytime := mycur.daytime;
  EXIT;
      END IF;
    END LOOP;
  END IF;

  IF ld_daytime < EcDp_Tank.getStartDate(p_tank_object_id) THEN
    ln_retval := 0;
  ELSE
    ln_retval := EcBp_Tank.findNetStdOilVol(p_tank_object_id, lv2_meas_event_type, ld_daytime, p_method, lv2_resolve_loop);
  END IF;

  RETURN ln_retval;

END findClosingNetVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findOpeningNetMass
--
-- Description    : Returns Net mass at tank conditions, previous reading
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

FUNCTION findOpeningNetMass(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_period           VARCHAR2(300);
  ld_prev_daytime      DATE;
  ln_retval            NUMBER;
  lv2_resolve_loop     VARCHAR2(2000);
  lv2_meas_event_type  VARCHAR2(32);
  lv2_bf_usage         VARCHAR2(32);

CURSOR c_closing_net_mass(cp_object_id tank_measurement.object_id%TYPE,
                      cp_measurement_type tank_measurement.measurement_event_type%TYPE,
                      cp_daytime date) IS
select daytime from tank_measurement
where object_id = cp_object_id
and measurement_event_type = cp_measurement_type
and daytime < cp_daytime
order by daytime desc;

BEGIN
  IF InStr(p_resolve_loop,'findOpeningNetMass')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a tank''s Opening Net Mass. Possibly due to a mis-configuration of tank attributes.');
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findOpeningNetMass,';
  END IF;

  lv2_bf_usage := ec_tank_version.bf_usage(p_tank_object_id, p_daytime ,'<=');
  IF lv2_bf_usage = 'PO.0082' THEN
    lv2_meas_event_type := 'EVENT_CLOSING';
  ELSE
    lv2_meas_event_type := 'DAY_CLOSING';
  END IF;

  lv2_period := EcDp_Tank.getTankMeterFrequency(p_tank_object_id, p_daytime);
  IF lv2_period = 'DAY' THEN
    ld_prev_daytime := p_daytime - 1;
  ELSIF lv2_period = 'MONTH' THEN
    ld_prev_daytime := LAST_DAY(ADD_MONTHS(p_daytime, -1));
  ELSIF lv2_period = 'EVENT' THEN
    FOR mycur in c_closing_net_mass(p_tank_object_id, lv2_meas_event_type, p_daytime) LOOP
      IF EcBp_Tank.findNetMass(p_tank_object_id,lv2_meas_event_type,mycur.daytime) IS NOT NULL THEN
        ld_prev_daytime := mycur.daytime;
        EXIT;
      END IF;
    END LOOP;
  END IF;

  IF ld_prev_daytime < EcDp_Tank.getStartDate(p_tank_object_id) THEN
    ln_retval := 0;
  ELSE
    ln_retval := EcBp_Tank.findNetMass(p_tank_object_id, lv2_meas_event_type, ld_prev_daytime, p_method, lv2_resolve_loop);
  END IF;

  RETURN ln_retval;

END findOpeningNetMass;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findClosingNetMass
--
-- Description    : Returns closing Net mass at tank conditions, passed in daytime's reading
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

FUNCTION findClosingNetMass(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_period           VARCHAR2(300);
  ld_daytime           DATE;
  ln_retval            NUMBER;
  lv2_resolve_loop     VARCHAR2(2000);
  lv2_meas_event_type  VARCHAR2(32);
  lv2_bf_usage         VARCHAR2(32);

CURSOR c_closing_net_mass(cp_object_id tank_measurement.object_id%TYPE,
                      cp_measurement_type tank_measurement.measurement_event_type%TYPE,
                      cp_daytime date) IS
select daytime from tank_measurement
where object_id = cp_object_id
and measurement_event_type = cp_measurement_type
and daytime <= cp_daytime
order by daytime desc;

BEGIN
  IF InStr(p_resolve_loop,'findClosingNetMass')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a tank''s Closing Net Mass. Possibly due to a mis-configuration of tank attributes.');
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findClosingNetMass,';
  END IF;

  lv2_bf_usage := ec_tank_version.bf_usage(p_tank_object_id, p_daytime ,'<=');
  IF lv2_bf_usage = 'PO.0082' THEN
    lv2_meas_event_type := 'EVENT_CLOSING';
  ELSE
	lv2_meas_event_type := 'DAY_CLOSING';
  END IF;

  lv2_period := EcDp_Tank.getTankMeterFrequency(p_tank_object_id, p_daytime);
  IF lv2_period = 'DAY' THEN
    ld_daytime := p_daytime; -- do nothing
  ELSIF lv2_period = 'MONTH' THEN
    ld_daytime := LAST_DAY(p_daytime);
  ELSIF lv2_period = 'EVENT' THEN
    FOR mycur in c_closing_net_mass(p_tank_object_id, lv2_meas_event_type, p_daytime) LOOP
      IF EcBp_Tank.findNetMass(p_tank_object_id,lv2_meas_event_type,mycur.daytime) IS NOT NULL THEN
        ld_daytime := mycur.daytime;
  EXIT;
      END IF;
    END LOOP;
  END IF;

  IF ld_daytime < EcDp_Tank.getStartDate(p_tank_object_id) THEN
    ln_retval := 0;
  ELSE
    ln_retval := EcBp_Tank.findNetMass(p_tank_object_id, lv2_meas_event_type, ld_daytime, p_method, lv2_resolve_loop);
  END IF;

  RETURN ln_retval;

END findClosingNetMass;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findOpeningWatVol
--
-- Description    : Returns Water Vol at tank conditions, previous reading
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

FUNCTION findOpeningWatVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_period           VARCHAR2(300);
  ld_prev_daytime      DATE;
  ln_retval            NUMBER;
  lv2_resolve_loop     VARCHAR2(2000);
  lv2_meas_event_type  VARCHAR2(32);
  lv2_bf_usage         VARCHAR2(32);

CURSOR c_closing_wat_vol(cp_object_id tank_measurement.object_id%TYPE,
                      cp_measurement_type tank_measurement.measurement_event_type%TYPE,
                      cp_daytime date) IS
select daytime from tank_measurement
where object_id = cp_object_id
and measurement_event_type = cp_measurement_type
and daytime < cp_daytime
order by daytime desc;

BEGIN
  IF InStr(p_resolve_loop,'findOpeningWatVol')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a tank''s Opening Water Vol. Possibly due to a mis-configuration of tank attributes.');
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findOpeningWatVol,';
  END IF;

  lv2_bf_usage := ec_tank_version.bf_usage(p_tank_object_id, p_daytime ,'<=');
  IF lv2_bf_usage = 'PO.0082' THEN
    lv2_meas_event_type := 'EVENT_CLOSING';
  ELSE
    lv2_meas_event_type := 'DAY_CLOSING';
  END IF;

  lv2_period := EcDp_Tank.getTankMeterFrequency(p_tank_object_id, p_daytime);
  IF lv2_period = 'DAY' THEN
    ld_prev_daytime := p_daytime - 1;
  ELSIF lv2_period = 'MONTH' THEN
    ld_prev_daytime := LAST_DAY(ADD_MONTHS(p_daytime, -1));
  ELSIF lv2_period = 'EVENT' THEN
    FOR mycur in c_closing_wat_vol(p_tank_object_id, lv2_meas_event_type, p_daytime) LOOP
      IF EcBp_Tank.findWaterVol(p_tank_object_id,lv2_meas_event_type,mycur.daytime) IS NOT NULL THEN
        ld_prev_daytime := mycur.daytime;
  EXIT;
      END IF;
    END LOOP;
  END IF;

  IF ld_prev_daytime < EcDp_Tank.getStartDate(p_tank_object_id) THEN
    ln_retval := 0;
  ELSE
    ln_retval := EcBp_Tank.findWaterVol(p_tank_object_id, lv2_meas_event_type, ld_prev_daytime, p_method, lv2_resolve_loop);
  END IF;

  RETURN ln_retval;

END findOpeningWatVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findClosingWatVol
--
-- Description    : Returns closing Water Vol at tank conditions, passed in daytime's reading
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

FUNCTION findClosingWatVol(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_period           VARCHAR2(300);
  ld_daytime           DATE;
  ln_retval            NUMBER;
  lv2_resolve_loop     VARCHAR2(2000);
  lv2_meas_event_type  VARCHAR2(32);
  lv2_bf_usage         VARCHAR2(32);

CURSOR c_closing_wat_vol(cp_object_id tank_measurement.object_id%TYPE,
                      cp_measurement_type tank_measurement.measurement_event_type%TYPE,
                      cp_daytime date) IS
select daytime from tank_measurement
where object_id = cp_object_id
and measurement_event_type = cp_measurement_type
and daytime <= cp_daytime
order by daytime desc;

BEGIN
  IF InStr(p_resolve_loop,'findClosingWatVol')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a tank''s Closing Water Vol. Possibly due to a mis-configuration of tank attributes.');
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findClosingWatVol,';
  END IF;

  lv2_bf_usage := ec_tank_version.bf_usage(p_tank_object_id, p_daytime ,'<=');
  IF lv2_bf_usage = 'PO.0082' THEN
    lv2_meas_event_type := 'EVENT_CLOSING';
  ELSE
    lv2_meas_event_type := 'DAY_CLOSING';
  END IF;

  lv2_period := EcDp_Tank.getTankMeterFrequency(p_tank_object_id, p_daytime);
  IF lv2_period = 'DAY' THEN
    ld_daytime := p_daytime; -- do nothing
  ELSIF lv2_period = 'MONTH' THEN
    ld_daytime := LAST_DAY(p_daytime);
  ELSIF lv2_period = 'EVENT' THEN
    FOR mycur in c_closing_wat_vol(p_tank_object_id, lv2_meas_event_type, p_daytime) LOOP
      IF EcBp_Tank.findWaterVol(p_tank_object_id,lv2_meas_event_type,mycur.daytime) IS NOT NULL THEN
        ld_daytime := mycur.daytime;
        EXIT;
      END IF;
    END LOOP;
  END IF;

  IF ld_daytime < EcDp_Tank.getStartDate(p_tank_object_id) THEN
    ln_retval := 0;
  ELSE
    ln_retval := EcBp_Tank.findWaterVol(p_tank_object_id, lv2_meas_event_type, ld_daytime, p_method, lv2_resolve_loop);
  END IF;

  RETURN ln_retval;

END findClosingWatVol;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findOpeningEnergy
--
-- Description    : Returns energy at tank conditions, previous reading
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

FUNCTION findOpeningEnergy(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_period           VARCHAR2(300);
  ld_prev_daytime      DATE;
  ln_retval            NUMBER;
  lv2_resolve_loop     VARCHAR2(2000);
  lv2_meas_event_type  VARCHAR2(32);
  lv2_bf_usage         VARCHAR2(32);

CURSOR c_closing_energy(cp_object_id tank_measurement.object_id%TYPE,
                      cp_measurement_type tank_measurement.measurement_event_type%TYPE,
                      cp_daytime date) IS
select * from tank_measurement
where object_id = cp_object_id
and measurement_event_type = cp_measurement_type
and daytime < cp_daytime
order by daytime desc;

BEGIN
  IF InStr(p_resolve_loop,'findOpeningEnergy')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a tank''s Opening Energy. Possibly due to a mis-configuration of tank attributes.');
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findOpeningEnergy,';
  END IF;

  lv2_bf_usage := ec_tank_version.bf_usage(p_tank_object_id, p_daytime ,'<=');
  IF lv2_bf_usage = 'PO.0082' THEN
    lv2_meas_event_type := 'EVENT_CLOSING';
  ELSE
    lv2_meas_event_type := 'DAY_CLOSING';
  END IF;
  lv2_period := EcDp_Tank.getTankMeterFrequency(p_tank_object_id, p_daytime);
  IF lv2_period = 'DAY' THEN
    ld_prev_daytime := p_daytime - 1;
  ELSIF lv2_period = 'MONTH' THEN
    ld_prev_daytime := LAST_DAY(ADD_MONTHS(p_daytime, -1));
  ELSIF lv2_period = 'EVENT' THEN
    FOR mycur in c_closing_energy(p_tank_object_id, lv2_meas_event_type, p_daytime) LOOP
      IF EcBp_Tank.findWaterVol(p_tank_object_id,lv2_meas_event_type,mycur.daytime) IS NOT NULL THEN
        ld_prev_daytime := mycur.daytime;
        EXIT;
      END IF;
    END LOOP;
  END IF;

  IF ld_prev_daytime < EcDp_Tank.getStartDate(p_tank_object_id) THEN
    ln_retval := 0;
  ELSE
    ln_retval := ec_tank_measurement.closing_energy(p_tank_object_id, lv2_meas_event_type, ld_prev_daytime, '<=');
  END IF;

  RETURN ln_retval;

END findOpeningEnergy;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findClosingEnergy
--
-- Description    : Returns closing Energy at tank conditions, passed in daytime's reading
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

FUNCTION findClosingEnergy(
  p_tank_object_id     TANK.OBJECT_ID%TYPE,
  p_meas_event_type    TANK_MEASUREMENT.MEASUREMENT_EVENT_TYPE%TYPE,
  p_daytime            DATE,
  p_method             VARCHAR2 DEFAULT NULL,
  p_resolve_loop       VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_period           VARCHAR2(300);
  ld_daytime           DATE;
  ln_retval            NUMBER;
  lv2_resolve_loop     VARCHAR2(2000);
  lv2_meas_event_type  VARCHAR2(32);
  lv2_bf_usage         VARCHAR2(32);

CURSOR c_closing_energy(cp_object_id tank_measurement.object_id%TYPE,
                      cp_measurement_type tank_measurement.measurement_event_type%TYPE,
                      cp_daytime date) IS
select * from tank_measurement
where object_id = cp_object_id
and measurement_event_type = cp_measurement_type
and daytime <= cp_daytime
order by daytime desc;

BEGIN
  IF InStr(p_resolve_loop,'findClosingEnergy')>0 THEN
    RAISE_APPLICATION_ERROR(-20000,'A loop was detected when trying to calculate a tank''s Closing Energy. Possibly due to a mis-configuration of tank attributes.');
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findClosingEnergy,';
  END IF;

  lv2_bf_usage := ec_tank_version.bf_usage(p_tank_object_id, p_daytime ,'<=');
  IF lv2_bf_usage = 'PO.0082' THEN
    lv2_meas_event_type := 'EVENT_CLOSING';
  ELSE
    lv2_meas_event_type := 'DAY_CLOSING';
  END IF;

  lv2_period := EcDp_Tank.getTankMeterFrequency(p_tank_object_id, p_daytime);
  IF lv2_period = 'DAY' THEN
    ld_daytime := p_daytime; -- do nothing
  ELSIF lv2_period = 'MONTH' THEN
    ld_daytime := LAST_DAY(p_daytime);
  ELSIF lv2_period = 'EVENT' THEN
    FOR mycur in c_closing_energy(p_tank_object_id, lv2_meas_event_type, p_daytime) LOOP
      IF EcBp_Tank.findWaterVol(p_tank_object_id,lv2_meas_event_type,mycur.daytime) IS NOT NULL THEN
        ld_daytime := mycur.daytime;
        EXIT;
      END IF;
    END LOOP;
  END IF;

  IF ld_daytime < EcDp_Tank.getStartDate(p_tank_object_id) THEN
    ln_retval := 0;
  ELSE
    ln_retval := ec_tank_measurement.closing_energy(p_tank_object_id, lv2_meas_event_type, ld_daytime, '<=');
  END IF;

  RETURN ln_retval;

END findClosingEnergy;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkTankMeasurementLock
-- Description    : Checks whether a last dated tank measurement record affects a locked month.
--
-- Preconditions  : Events of type DAY_CLOSING and without time fraction.
--                  Any current record depends on the values on the previuos record.
--                  Hence, the current and the previous records are considered as a pair with a unified time span.
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: EcDp_Month_Lock.checkUpdateOfLDOForLock,
--                  EcDp_Month_Lock.buildIdentifierString,
--                  EcDp_Month_Lock.checkIfColumnsUpdated,
--                  EcDp_Month_Lock.validatePeriodForLockOverlap
--                  ec_tank_measurement
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkTankMeasurementLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list)
--</EC-DOC>
IS

  ld_new_current_valid DATE;
  ld_old_current_valid DATE;
  ld_new_next_valid DATE;
  ld_old_next_valid DATE;
  ld_old_prev_valid DATE;

  ld_locked_month DATE;
  lv2_id VARCHAR2(2000);
  lv2_columns_updated VARCHAR2(1);

  lv2_o_obj_id                  VARCHAR2(32);
  lv2_n_obj_id                  VARCHAR2(32);

BEGIN

  ld_new_current_valid := p_new_lock_columns('DAYTIME').column_data.AccessDate;
  ld_old_current_valid := p_old_lock_columns('DAYTIME').column_data.AccessDate;

  IF p_old_lock_columns.EXISTS('OBJECT_ID')  THEN
    lv2_o_obj_id := p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
  END IF;

  IF p_new_lock_columns.EXISTS('OBJECT_ID')  THEN
    lv2_n_obj_id := p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
  END IF;

  IF p_operation = 'INSERTING' THEN

    lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

    ld_new_next_valid := ec_tank_measurement.next_daytime(
                         p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                         'DAY_CLOSING',
                         ld_new_current_valid);

    EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_new_current_valid,
                                                 ld_new_next_valid, lv2_id,
                                                 lv2_n_obj_id);

  ELSIF p_operation = 'UPDATING' THEN

    lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

    -- get the next valid daytime
    ld_new_next_valid := ec_tank_measurement.next_daytime(
                         p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                         'DAY_CLOSING',
                         ld_new_current_valid);

    ld_old_next_valid := ec_tank_measurement.next_daytime(
                         p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                         'DAY_CLOSING',
                         ld_old_current_valid);

    IF ld_new_next_valid = ld_old_current_valid THEN
      ld_new_next_valid := ld_old_next_valid;
    END IF;

      -- Get previous record
      ld_old_prev_valid := ec_tank_measurement.prev_daytime(
                           p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           'DAY_CLOSING',
                           ld_old_current_valid);

      p_old_lock_columns('DAYTIME').is_checked := 'Y';

      IF EcDp_Month_Lock.checkIfColumnsUpdated(p_old_lock_columns) THEN
         lv2_columns_updated := 'Y';
      ELSE
         lv2_columns_updated := 'N';
      END IF;

      EcDp_Month_Lock.checkUpdateOfLDOForLock(ld_new_current_valid,
                                             ld_old_current_valid,
                                             ld_new_next_valid,
                                             ld_old_next_valid,
                                             ld_old_prev_valid,
                                             lv2_columns_updated,
                                             lv2_id,
                                             lv2_n_obj_id);

   ELSIF p_operation = 'DELETING' THEN

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_old_lock_columns);

      ld_old_next_valid := ec_tank_measurement.next_daytime(
                           p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           'DAY_CLOSING',
                           ld_old_current_valid);

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_old_current_valid,
                                                   ld_old_next_valid, lv2_id,
                                                   lv2_o_obj_id);

   END IF;

END checkTankMeasurementLock;


PROCEDURE checkTankMeasurementLock(p_object_id VARCHAR2, p_measurement_event_type VARCHAR2, p_daytime DATE, p_class_name VARCHAR2) IS
  lr_tank_measurement  tank_measurement%ROWTYPE;
  n_lock_columns       EcDp_Month_lock.column_list;
BEGIN

  lr_tank_measurement := ec_tank_measurement.row_by_pk(p_object_id, p_measurement_event_type, p_daytime);

  -- Lock test
  EcDp_month_lock.AddParameterToList(n_lock_columns,'CLASS_NAME',p_class_name,'STRING',NULL,NULL,NULL);
  EcDp_month_lock.AddParameterToList(n_lock_columns,'TABLE_NAME','TANK_MEASUREMENT','STRING',NULL,NULL,NULL);
  EcDp_month_lock.AddParameterToList(n_lock_columns,'OBJECT_ID','OBJECT_ID','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_tank_measurement.object_id));
  EcDp_month_lock.AddParameterToList(n_lock_columns,'DAYTIME','DAYTIME','DATE','N','N',anydata.Convertdate(lr_tank_measurement.DAYTIME));

  EcBp_Tank.checkTankMeasurementLock('UPDATING',n_lock_columns,n_lock_columns);

END checkTankMeasurementLock;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkTankStrappingLock
-- Description    :
--
-- Preconditions  : Checks whether a last dated tank measurement record affects a locked month.
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--                  EcDp_Month_Lock.checkUpdateOfLDOForLock,
--                  EcDp_Month_Lock.buildIdentifierString,
--                  EcDp_Month_Lock.checkIfColumnsUpdated,
--                  EcDp_Month_Lock.validatePeriodForLockOverlap
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkTankStrappingLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list)
--</EC-DOC>
IS

ld_new_current_valid DATE;
ld_old_current_valid DATE;
ld_new_next_valid DATE;
ld_old_next_valid DATE;
ld_old_prev_valid DATE;

ld_locked_month DATE;
lv2_id VARCHAR2(2000);
lv2_columns_updated VARCHAR2(1);

lv2_o_obj_id                  VARCHAR2(32);
lv2_n_obj_id                  VARCHAR2(32);

BEGIN

   ld_new_current_valid := p_new_lock_columns('DAYTIME').column_data.AccessDate;
   ld_old_current_valid := p_old_lock_columns('DAYTIME').column_data.AccessDate;

   IF p_old_lock_columns.EXISTS('OBJECT_ID')  THEN
      lv2_o_obj_id := p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;

   IF p_new_lock_columns.EXISTS('OBJECT_ID')  THEN
      lv2_n_obj_id := p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;

   IF p_operation = 'INSERTING' THEN -- Only when inserting new valid analysis

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

      ld_new_next_valid := ec_tank_strapping.next_daytime(
                           p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_new_current_valid,
                           p_new_lock_columns('DIP_LEVEL').column_data.AccessNumber);

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_new_current_valid,
                                                   ld_new_next_valid, lv2_id,
                                                   lv2_n_obj_id);

   ELSIF p_operation = 'UPDATING' THEN

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

      -- get the next valid daytime
      ld_new_next_valid := ec_tank_strapping.next_daytime(
                           p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_new_current_valid,
                           p_new_lock_columns('DIP_LEVEL').column_data.AccessNumber);

      ld_old_next_valid := ec_tank_strapping.next_daytime(
                           p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_old_current_valid,
                           p_old_lock_columns('DIP_LEVEL').column_data.AccessNumber);

      IF ld_new_next_valid = ld_old_current_valid THEN
         ld_new_next_valid := ld_old_next_valid;
      END IF;

      -- Get previous record
      ld_old_prev_valid := ec_tank_strapping.prev_daytime(
                           p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_old_current_valid,
                           p_new_lock_columns('DIP_LEVEL').column_data.AccessNumber);

      p_old_lock_columns('DAYTIME').is_checked := 'Y';

      IF EcDp_Month_Lock.checkIfColumnsUpdated(p_old_lock_columns) THEN
         lv2_columns_updated := 'Y';
      ELSE
         lv2_columns_updated := 'N';
      END IF;

      EcDp_Month_Lock.checkUpdateOfLDOForLock(ld_new_current_valid,
                                             ld_old_current_valid,
                                             ld_new_next_valid,
                                             ld_old_next_valid,
                                             ld_old_prev_valid,
                                             lv2_columns_updated,
                                             lv2_id,
                                             lv2_n_obj_id);


   ELSIF p_operation = 'DELETING' THEN -- Only when deleting a valid analysis

      lv2_id := EcDp_Month_Lock.buildIdentifierString(p_old_lock_columns);

      ld_old_next_valid := ec_tank_strapping.next_daytime(
                           p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
                           ld_old_current_valid,
                           p_old_lock_columns('DIP_LEVEL').column_data.AccessNumber);

      EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_old_current_valid,
                                                   ld_old_next_valid, lv2_id,
                                                   lv2_o_obj_id);

   END IF;

END checkTankStrappingLock;

END EcBp_Tank;