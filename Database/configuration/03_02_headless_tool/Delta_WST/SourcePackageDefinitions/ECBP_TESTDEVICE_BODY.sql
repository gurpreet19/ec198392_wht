CREATE OR REPLACE PACKAGE BODY EcBp_TestDevice IS

/****************************************************************
** Package        :  EcBp_TestDevice
**
** $Revision: 1.75 $
**
** Purpose        :  This procedure will call functions that will
**                   calculate on -the-fly well test results depending
**                   on configuration on Test_Device object.It also have
**                   a procedure to update PWELL_RESULT table when
**                   calculate button is pressed.
**
** Documentation  :  www.energy-components.com
**
** Created  : 22.11.2007  Davendran Mariappan
**
** Modification history:
**
** Date        Whom     Change description:
** ------      ----     --------------------------------------
** 22.11.2007  DM       First version
** 03.12.2007  zakiiari ECPD-7039: Added 2nd-onward functions / procedures and code-review
** 03.01.2008  kaurrjes ECPD-7276: Fixed Bugs and done enhancements in PT.0013 - Single Production Well Test Result.
** 14.01.2008  rajarsar ECPD-7226: Added findTdevRefMeterRun, findTdevRefOrificePlate,findWellRefSpecGravity and getPwelResultDate
** 16.01.2008  zakiiari ECPD-7226: Added lookupGasLifrHrRate, calcTotalizerVolume, findInvertedShrinkageFactor.
**                                 Supported additional method in some of the functions. i.e. USER_EXIT, AGA and TOTALIZER
**                                 Renamed/changed functionality of findTdevRefMeterRun and findTdevRefOrificePlate
** 16.01.2008  rajarsar ECPD-7226: Updated calcTotalizerVolume
** 14.02.2008  zakiiari ECPD-7277: Added WELL_FACTOR as part of shrinkage calculation
**                                 Fixed bug in shrinkage calculation
** 07.05.2008  leongsei ECPD-8428: Single Production Test Result - must support calculation of mass
** 16.05.2008  sharawan ECPD-8165: Update the code for updateRateSource to not check for specific attributes,
                                   but rather just set RATE_SOURCE to MANUAL every time there is a save on DV_PWEL_RESULT.
** 26.05.2008  oonnnng  ECPD-8471: Replace USER_EXIT test statements with [ (substr(lv2_gas_lift_method,1,9) = EcDp_Calc_Method.USER_EXIT) ].
** 20.06.2008  Toha     ECPD-8361  Added findWellRefGasLiftSpecGravity, agaStaticPress, agaDiffPress. Fixed findWellRefGasSpecGravity
** 20.06.2008  Toha     ECPD-8512  Removed few parameters in function agaStaticPress and agaDiffPress and modified content of those functions
**                                 to be the same as 9_2-PATCH ver1.15.2.2.2.4.
**                                 Changed those with "stat" or "static" to "diff" in function agaDiffPress
**                                 eg: "my_tdev_ref.gas_stat_press_max_scale" is changed to "my_tdev_ref.gas_diff_press_max_scale".
** 20.06.2008  Toha     ECPD-8564: Added value conversion for agaStaticPress. This is helped by a new local function i.e. getAttributeName
** 08.09.2008  oonnnng  ECPD-7830: Added getMeterFactor, and updEQPMResultValues functions.
                                   Updated calcShrinkageVolume function with WELL_TDEV_FACTOR method.
                                   Updated findNetRate with " nvl(getMeterFactor(lv_object_id, EcDp_phase.OIL, ld_daytime, p_result_no),1);".
** 18.09.2008  oonnnng  ECPD-9394: Added findDiluentRate and findWellWetGasRate functions.
** 19.01.2009  leeeewei ECPD-10053:Updated watercut_pct in calcSingleWellTestResult to return value in percentage
** 20.01.2009 lauuufus  ECPD-10737 Added new function calcWaterCut to calculate Water Cut % other than using findBswVol
** 22.01.2009 rajarsar  ECPD-10346 Updated agaStaticPress and agaDiffPress to add dynamic chart unit from meter run.
** 05.02.2009 lauuufus  ECPD-10863 Added USER_EXIT for findNetRate function.
** 23.02.2009 lauuufus  ECPD-10124 Added new function findRefShrinkageFactor and findWellRefShrinkageFactor
** 26.02.2009 leeeewei  ECPD-10993 Updated watercut_pct in calcSingleWellTestResult to use new function calcWaterCut
** 27.02.2009 leeeewei  ECPD-11028 Set the default return value in getMeterFactor to null
** 27.02.2009 farhaann  ECPD-11055 Modified findBswVol(): Added method=SAMPLE_ANALYSIS_SPOT,SAMPLE_ANALYSIS_DAY and SAMPLE_ANALYSIS_MTH.
** 04.03.2009 embonhaf  ECPD-10220 Updated getMeterFactor to return null when no meter_factor_method specified and calcImpurityRate minus oil in water value into volume
** 06.03.2009 amirrasn  ECPD-10740 Added new function findCalcDilRate to pass calc_diluent_rate to diluent_rate in pwel_result
** 12.03.2009 ismaiime  ECPD-9636  Updated function calcShrinkageVolume to support multiple reservoirs
** 10.08.2009 leeeewei  ECPD-12153 Modified pressure calculation for chart type = square root in agaStaticPress and agaDiffPress
** 24.08.2009 oonnnng   ECPD-11803 Updated calcTotalizerVolume() function where VCF and BSW only be used for Oil and Condensate.
**                                 Updated calcTotalizerVolume() function where the BSW to call findBswVol() function.
** 01.09.2009 oonnnng   ECPD-12596 Modify function findGrsGasLiftRate() function to test for prod_method='GL'.
** 15.09.2009 leongsei  ECPD-12583 Modified function findWetGasGravity, findNetRate, findWOR, findGLR, findWGR, findWetDryFactor
** 14.09.2009 ismaiime  ECPD-12255 Modify functions agaStaticPress and agaDiffPress to calculate correctly if chart_unit was configured in meter run.
** 18.09.2009 madondin  ECPD-12693 Added USER_EXIT for findStdNetRate,findGrsLiqVolume,findGrsGasVolume,findGrsGasLiftVolume,findGrsWaterVolume,getMeterFactor
**                                 findGOR,findGLR,findCGR,findWOR,findWGR,findBswVol function.
** 12.10.2009 leeeewei  ECPD-12907 Modified function calcShrinkageVolume where method = table lookup to use tdev temperature and pressure
** 22.10.2009 rajarsar  ECPD-12853 Updated function calcShrinkageVolume to add method = MEASURED
** 13.11.2009 oonnnng   ECPD-13101 Updated calcShrinkageVolume() function's TDEV_FACTOR, WELL_FACTOR, WELL_TDEV_FACTOR methods to include "gas in solution".
** 09.12.2009 leeeewei  ECPD-12927 Added support for Water Source well in calcSingleWellTestResult
** 10.12.2009 leeeewei  ECPD-13114 Modified function calcShrinkageVolume to find out from system attribute which formula to use to calculate shrinkage volume
**                                 Modified function calcShrinkageVolume, replace findNetRate to findStdNetRate to calculate gas shrinkage volume.
** 17.12.2009 leongsei  ECPD-13338 Modified function calcShrinkageVolume for shrinkage_method EQUATION
** 06.01.2010 ismaiime  ECPD-13031: Modified function calcShrinkageVolume to pass 'RES' when calling function to get the quality stream.
** 03.02.2010 sharawan  ECPD-12821: Remove unneeded function findCalcDilRate. Modify function calcSingleWellTestResult to remove the calling to findCalcDilRate function.
** 12.03.2010 aliassit  ECPD-14146: Update calcSingleWellTestResult to calculate DRY_WET_RATIO
** 13.07.2010 farhaann  ECPD-15100: Called findStdNetRate() instead of findNetRate() using the same parameter list for all three cases in calcShrinkageVolume function.
** 20.09.2010 amirrasn  ECPD-15219: Added new procedure to check record for Test Device has already been set to be default for current Facility
** 11.11.2010 oonnnng   ECPD-15782: Modified calcShrinkageVolume() function on 'TABLE_LOOKUP' method to support gas producer.
** 19.01.2011 oonnnng   ECPD-16527: Modified calcShrinkageVolume() function to include calling to findStdNetRate(,Ecdp_Phase.CONDENSATE,) in calculation for Gas Producer well.
** 27.01.2011 madondin  ECPD-16412: Modified functions which have update user
** 24.02.2011 amirrasn  ECPD-15842: Enhanced findInvertedShrinkageFactors() to handle p_density=NULL. Also added new Grs GL Rate Method
**                                  Bugfix in calcImpurity: For gas, its gaslift that will be the "impurity", but not if Grs Gas Rate is LIQUID_GOR, because GOR is already net gas lift
**                                  Bugfix on CalcShrinkageVolume when method is Formula. The existing code would never loop more than 1 RBF zone to calc constants
**                                  Bugfix in CalcShrinkageVolume when method is Formula. The code call ec_test_device_result() function, but used object_id from test_device.
** 08.03.2011 musaamah  ECPD-15331: Modified cursor in function calcShrinkageVolume to access quality stream from RBF_VERSION (version table) instead of RESV_BLOCK_FORMATION (main table).
**                                  This is due to the column STREAM_ID which has been moved from RESV_BLOCK_FORMATION to RBF_VERSION.
** 27.04.2012 syazwnur  ECPD-18693: Removed IF statements for user exit in findNetRate function.
** 25.02.2013 kumarsur  ECPD-20185:Added new function getMeterText, getOilMeterText, getGasMeterText and getWaterMeterText
** 23.07.2013 limmmchu  ECPD-23342: Modified getDefaultTdev
** 27.11.2013 makkkkam  ECPD-25017: Modified calcSingleWellTestResult and added getJournalRevNo to support audit trail
** 14.05.2014  deshpadi  ECPD-26763: Modified cursor in function calcShrinkageVolume to access RESB_BLOCK_FORMATION_ID, that has been moved to
                                     PERF_INTERVAL_VERSION table from PERF_INTERVAL table.
** 16.07.2014 dhavaalo  ECPD-28080: eqpm_version table changed with test_device_version. replace all occurances of eqpm_version with test_device_version
** 17.07.2014 dhavaalo ECPD-28080: Replace EQPM_RESULT with TEST_DEVICE_RESULT
** 04.08.2014 dhavaalo ECPD-28080: Replace updEQPMResultValues with updTDEVResultValues
** 19.06.2015 dhavaalo ECPD-27830: Modified findWetDryFactor as Dry Wet Factor is not calculated correctly when Gas Lift is involved
** 07.02.2017 shindani ECPD-35761: Modified procedure calcSingleWellTestResult to update rate source and removed procedure updateRateSource.
** 20.07.2017 dhavaalo ECPD-46111: Modified findRefShrinkageFactor to support user exit.
** 11.09.2017 kaushaak ECPD-48603: Modified findRefShrinkageFactor to support multiple user exit.
** 05.10.2018 kaushaak ECPD-57454: Modified getMeterText to handle more than one version on test device.

*****************************************************************/

-- Cursor to fetch TEST_DEVICE, WELL and DAYTIME based on the given RESULT_NO
CURSOR c_result(cp_result_no NUMBER) IS
  SELECT pr.daytime, pr.test_device as tdev_object_id, pr.object_id as well_object_id, pr.record_status, pr.rev_no
  FROM pwel_result pr
  WHERE pr.result_no = cp_result_no;


---------------------------------------------------------------------------------------------------
-- Function       : getAttributeName
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getAttributeName(p_result_no test_device_result.RESULT_NO%TYPE,
                           p_object_id test_device_result.OBJECT_ID%TYPE,
                           p_column_name VARCHAR2
                           )
RETURN VARCHAR2
IS
  lv_class_name      VARCHAR2(32);
  lv_attr_name       VARCHAR2(32);

  CURSOR c_attribute(cp_class_name VARCHAR2, cp_column_name VARCHAR2) IS
    SELECT * FROM class_attribute_cnfg cm
    WHERE cm.class_name = cp_class_name AND
          cm.db_sql_syntax = cp_column_name;

BEGIN
  lv_class_name := ec_test_device_result.data_class_name(p_object_id,p_result_no);

  FOR cur_attr IN c_attribute(lv_class_name,p_column_name) LOOP
    lv_attr_name := cur_attr.attribute_name;
    EXIT;
  END LOOP;

  RETURN lv_attr_name;
END getAttributeName;


---------------------------------------------------------------------------------------------------
-- Function       : findStdNetRate
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findStdNetRate(p_result_no NUMBER, p_phase VARCHAR2, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>

IS
  lv_std_net_rate_method       VARCHAR2(100);
  lv_grs_gas_rate_method       VARCHAR2(100);
  ln_result                    NUMBER;
  ln_net_rate                  NUMBER;
  lv_object_id                 VARCHAR2(32);
  ld_daytime                   DATE;

BEGIN
  IF p_object_id IS NULL OR p_daytime IS NULL THEN
    -- find object_id and daytime
    FOR cur_rst IN c_result(p_result_no) LOOP
      lv_object_id := cur_rst.tdev_object_id;
      ld_daytime := cur_rst.daytime;
    END LOOP;
  ELSE
    lv_object_id := p_object_id;
    ld_daytime := p_daytime;
  END IF;

  -- determine the STD_NET_RATE_METHOD
  lv_std_net_rate_method := nvl(ec_test_device_version.std_net_rate_method(lv_object_id,ld_daytime,'<='), 'MEASURED');
  lv_grs_gas_rate_method := nvl(ec_test_device_version.grs_gas_rate_method(lv_object_id,ld_daytime,'<='), 'MEASURED');

  IF lv_std_net_rate_method = 'MEASURED' THEN

    IF p_phase = Ecdp_Phase.OIL THEN
      ln_result := ec_test_device_result.net_oil_rate_adj(lv_object_id,p_result_no);

    ELSIF p_phase = Ecdp_Phase.GAS THEN
      ln_result := ec_test_device_result.gas_rate_adj(lv_object_id,p_result_no);

    ELSIF p_phase = Ecdp_Phase.CONDENSATE THEN
      ln_result := ec_test_device_result.net_cond_rate_adj(lv_object_id,p_result_no);

    ELSIF p_phase = Ecdp_Phase.WATER THEN
      ln_result := ec_test_device_result.tot_water_rate_adj(lv_object_id,p_result_no);

    END IF;

  ELSIF lv_std_net_rate_method = 'SHRINKAGE' THEN
    ln_net_rate := findNetRate(p_result_no,p_phase,lv_object_id,ld_daytime);
    -- do not shrink result if GRS_GAS_RATE=LIQUID*GOR because gas is then calculated through shrunk Oil and GOR
    IF (p_phase='GAS' AND lv_grs_gas_rate_method = 'LIQUID_GOR') THEN
      ln_result := ln_net_rate;
    ELSE
      ln_result := calcShrinkageVolume(p_result_no, ln_net_rate, p_phase, lv_object_id, ld_daytime);
    END IF;

  ELSIF (substr(lv_std_net_rate_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_result := Ue_Testdevice.findStdNetRate(p_result_no,p_phase,lv_object_id, ld_daytime);

  ELSE
    ln_result := NULL;
  END IF;

  RETURN ln_result;
END findStdNetRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findNetRate
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findNetRate(p_result_no NUMBER, p_phase VARCHAR2, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>

IS
  lv_object_id                   VARCHAR2(32);
  ld_daytime                     DATE;
  lv_net_rate_method             VARCHAR2(100);
  ln_grs_rate                    NUMBER;
  ln_result                      NUMBER;
  lv_well_object_id              VARCHAR2(32);

BEGIN
  IF p_object_id IS NULL OR p_daytime IS NULL THEN
    -- find object_id and daytime
    FOR cur_rst IN c_result(p_result_no) LOOP
      lv_object_id := cur_rst.tdev_object_id;
      ld_daytime := cur_rst.daytime;
      lv_well_object_id := cur_rst.well_object_id;
    END LOOP;
  ELSE
    lv_object_id := p_object_id;
    ld_daytime := p_daytime;
  END IF;

  IF lv_well_object_id IS NULL THEN
    FOR cur_rst IN c_result(p_result_no) LOOP
      lv_well_object_id := cur_rst.well_object_id;
    END LOOP;
  END IF;

  -- determine net rate method
  lv_net_rate_method := nvl(ec_test_device_version.net_rate_method(lv_object_id,ld_daytime,'<='), 'MEASURED');

  IF p_phase = EcDp_Phase.OIL AND ec_well_version.isOilProducer(lv_well_object_id,ld_daytime,'<=') = ECDP_TYPE.IS_FALSE THEN
    RETURN NULL;
  ELSIF p_phase = EcDp_Phase.CONDENSATE
        AND (ec_well_version.isGasProducer(lv_well_object_id,ld_daytime,'<=') = ECDP_TYPE.IS_FALSE
        AND ec_well_version.isCondensateProducer(lv_well_object_id,ld_daytime,'<=') = ECDP_TYPE.IS_FALSE ) THEN
    RETURN NULL;
  ELSE

    IF lv_net_rate_method = 'MEASURED' THEN

      IF p_phase = Ecdp_Phase.OIL THEN
        ln_result := nvl(ec_test_device_result.net_oil_rate_flc(lv_object_id,p_result_no), 0) *
                       nvl(getMeterFactor(lv_object_id, EcDp_phase.OIL, ld_daytime, p_result_no),1);

      ELSIF p_phase = Ecdp_Phase.GAS THEN
        ln_result := ec_test_device_result.gas_rate_flc(lv_object_id,p_result_no);

      ELSIF p_phase = Ecdp_Phase.CONDENSATE THEN
        ln_result := nvl(ec_test_device_result.net_cond_rate_flc(lv_object_id,p_result_no), 0) *
                       nvl(getMeterFactor(lv_object_id, EcDp_phase.OIL, ld_daytime, p_result_no),1);

      ELSIF p_phase = Ecdp_Phase.WATER THEN
        ln_result := nvl(ec_test_device_result.tot_water_rate_flc(lv_object_id,p_result_no), 0) *
                       nvl(getMeterFactor(lv_object_id, EcDp_phase.WATER, ld_daytime, p_result_no),1);

      END IF;

    ELSIF lv_net_rate_method = 'GRS_MINUS_IMPURITY' THEN

      IF p_phase = Ecdp_Phase.OIL OR p_phase = Ecdp_Phase.CONDENSATE THEN
        ln_grs_rate := findGrsLiqRate(p_result_no, lv_object_id, ld_daytime);
        ln_result := (nvl(ln_grs_rate, 0) -
                     nvl(calcImpurityRate(p_result_no,ln_grs_rate,p_phase, lv_object_id, ld_daytime), 0)) *
                     nvl(getMeterFactor(lv_object_id, EcDp_phase.OIL, ld_daytime, p_result_no),1);

      ELSIF p_phase = Ecdp_Phase.GAS THEN
        ln_grs_rate := findGrsGasRate(p_result_no, lv_object_id, ld_daytime);
        ln_result := nvl(ln_grs_rate, 0) -
                     nvl(calcImpurityRate(p_result_no,ln_grs_rate,p_phase, lv_object_id, ld_daytime), 0);

      ELSIF p_phase = Ecdp_Phase.WATER THEN
        ln_grs_rate := findGrsWaterRate(p_result_no, lv_object_id, ld_daytime);
        ln_result := (nvl(ln_grs_rate, 0) +
                     nvl(calcImpurityRate(p_result_no,ln_grs_rate,p_phase, lv_object_id, ld_daytime), 0)) *
                     nvl(getMeterFactor(lv_object_id, EcDp_phase.WATER, ld_daytime, p_result_no),1);
      END IF;

    ELSIF (substr(lv_net_rate_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_result := Ue_Testdevice.findNetRate(p_result_no,p_phase,lv_object_id, ld_daytime);

    ELSE
      ln_result := NULL;

    END IF;
  END IF;

  RETURN ln_result;
END findNetRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGrsLiqRate
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findGrsLiqRate(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>

IS
  lv_grs_liq_rate_method            VARCHAR2(100);
  lv_object_id                      VARCHAR2(32);
  ld_daytime                        DATE;
  ln_result                         NUMBER;
  ln_duration                       NUMBER;

BEGIN
  IF p_object_id IS NULL OR p_daytime IS NULL THEN
    -- find object_id and daytime
    FOR cur_rst IN c_result(p_result_no) LOOP
      lv_object_id := cur_rst.tdev_object_id;
      ld_daytime := cur_rst.daytime;
    END LOOP;
  ELSE
    lv_object_id := p_object_id;
    ld_daytime := p_daytime;
  END IF;

  -- determine grs rate method
  lv_grs_liq_rate_method := nvl(ec_test_device_version.grs_liq_rate_method(lv_object_id,ld_daytime,'<='), 'MEASURED');

  IF lv_grs_liq_rate_method = 'MEASURED' THEN
    ln_result := ec_test_device_result.oil_out_rate_raw(lv_object_id,p_result_no);

  ELSIF lv_grs_liq_rate_method = 'VOLUME_DURATION' THEN
    ln_duration := findDuration(p_result_no);
    IF ln_duration > 0 THEN
      ln_result := nvl(findGrsLiqVolume(p_result_no, lv_object_id, ld_daytime), 0) / ln_duration * 24;
    END IF;

  ELSIF lv_grs_liq_rate_method = 'CGR' THEN
    ln_result := nvl(findNetRate(p_result_no, Ecdp_Phase.GAS, lv_object_id, ld_daytime), 0) * nvl(findCGR(p_result_no, lv_object_id, ld_daytime), 0);

  ELSIF (substr(lv_grs_liq_rate_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_result := Ue_Testdevice.findGrsLiqRate(p_result_no,lv_object_id, ld_daytime);

  ELSE
    ln_result := NULL;
  END IF;

  RETURN ln_result;
END findGrsLiqRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGrsGasRate
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findGrsGasRate(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>

IS
  lv_grs_gas_rate_method            VARCHAR2(100);
  lv_object_id                      VARCHAR2(32);
  ld_daytime                        DATE;
  ln_result                         NUMBER;
  ln_duration                       NUMBER;

BEGIN
  IF p_object_id IS NULL OR p_daytime IS NULL THEN
    -- find object_id and daytime
    FOR cur_rst IN c_result(p_result_no) LOOP
      lv_object_id := cur_rst.tdev_object_id;
      ld_daytime := cur_rst.daytime;
    END LOOP;
  ELSE
    lv_object_id := p_object_id;
    ld_daytime := p_daytime;
  END IF;

  -- determine grs rate method
  lv_grs_gas_rate_method := nvl(ec_test_device_version.grs_gas_rate_method(lv_object_id,ld_daytime,'<='), 'MEASURED');

  IF lv_grs_gas_rate_method = 'MEASURED' THEN
    ln_result := ec_test_device_result.gas_out_rate_raw(lv_object_id,p_result_no);

  ELSIF lv_grs_gas_rate_method = 'VOLUME_DURATION' THEN
    ln_duration := findDuration(p_result_no);
    IF ln_duration > 0 THEN
      ln_result := nvl(findGrsGasVolume(p_result_no, lv_object_id, ld_daytime), 0) / ln_duration * 24;
    END IF;

  ELSIF lv_grs_gas_rate_method = 'LIQUID_GOR' THEN
    ln_result := nvl(findStdNetRate(p_result_no, Ecdp_Phase.OIL, lv_object_id, ld_daytime), 0) * nvl(findGOR(p_result_no, lv_object_id, ld_daytime), 0);

  ELSIF (substr(lv_grs_gas_rate_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_result := Ue_Testdevice.findGrsGasRate(p_result_no,lv_object_id, ld_daytime);

  ELSE
    ln_result := NULL;
  END IF;

  RETURN ln_result;
END findGrsGasRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGrsGasLiftRate
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findGrsGasLiftRate(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>

IS
  lv_grs_gl_rate_method            VARCHAR2(100);
  lv_object_id                      VARCHAR2(32);
  ld_daytime                        DATE;
  ln_result                         NUMBER;
  ln_duration                       NUMBER;
  lv_well_object_id                 VARCHAR2(32);
  lv_prod_method                    VARCHAR2(32);

BEGIN
  IF p_object_id IS NULL OR p_daytime IS NULL THEN
    -- find object_id and daytime
    FOR cur_rst IN c_result(p_result_no) LOOP
      lv_object_id := cur_rst.tdev_object_id;
      lv_well_object_id := cur_rst.well_object_id;
      ld_daytime := cur_rst.daytime;
    END LOOP;
  ELSE
    lv_object_id := p_object_id;
    ld_daytime := p_daytime;
  END IF;

  IF lv_well_object_id IS NULL THEN
    FOR cur_rst IN c_result(p_result_no) LOOP
      lv_well_object_id := cur_rst.well_object_id;
    END LOOP;
  END IF;

  lv_prod_method := ec_well_version.prod_method(lv_well_object_id, ld_daytime, '<=');

  IF lv_prod_method = 'GL' THEN
    -- determine grs rate method
    lv_grs_gl_rate_method := nvl(ec_test_device_version.grs_gl_rate_method(lv_object_id,ld_daytime,'<='), 'MEASURED');

    IF lv_grs_gl_rate_method = 'MEASURED' THEN
      ln_result := ec_test_device_result.gas_lift_rate_raw(lv_object_id,p_result_no);

    ELSIF lv_grs_gl_rate_method = 'VOLUME_DURATION' THEN
      ln_duration := findDuration(p_result_no);
      IF ln_duration > 0 THEN
        ln_result := nvl(findGrsGasLiftVolume(p_result_no, lv_object_id, ld_daytime), 0) / ln_duration * 24;
      END IF;

    -- ECPD-15842
    -- add new method to get gas lift from the raw gas measured out of separator minus gross gas which should be "LIQUID*GOR" method for this option.
    -- the raw gas out of separator must be shrunk first before deducting Liquid*GOR
    ELSIF lv_grs_gl_rate_method = 'RAWGAS_MINUS_GAS' THEN
      ln_result := calcShrinkageVolume(p_result_no, ec_test_device_result.gas_out_rate_raw(lv_object_id,p_result_no), 'GAS', lv_object_id, ld_daytime) -
                   findGrsGasRate(p_result_no,lv_object_id,ld_daytime);

    ELSIF (substr(lv_grs_gl_rate_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
      ln_result := Ue_Testdevice.findGrsGasLiftRate(p_result_no, lv_object_id, ld_daytime);

    ELSE
      ln_result := NULL;
    END IF;

  ELSE
    ln_result := NULL;
  END IF;

  RETURN ln_result;
END findGrsGasLiftRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGrsWaterRate
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findGrsWaterRate(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>

IS
  lv_grs_water_rate_method          VARCHAR2(100);
  lv_object_id                      VARCHAR2(32);
  lv_well_object_id                 VARCHAR2(32);
  ld_daytime                        DATE;
  ln_result                         NUMBER;
  ln_duration                       NUMBER;

BEGIN
  IF p_object_id IS NULL OR p_daytime IS NULL THEN
    -- find object_id and daytime
    FOR cur_rst IN c_result(p_result_no) LOOP
      lv_object_id := cur_rst.tdev_object_id;
      ld_daytime := cur_rst.daytime;
      lv_well_object_id := cur_rst.well_object_id;
    END LOOP;
  ELSE
    lv_object_id := p_object_id;
    ld_daytime := p_daytime;
  END IF;

  -- determine grs rate method
  lv_grs_water_rate_method := nvl(ec_test_device_version.grs_water_rate_method(lv_object_id,ld_daytime,'<='), 'MEASURED');

  IF lv_grs_water_rate_method = 'MEASURED' THEN
    ln_result := ec_test_device_result.water_out_rate_raw(lv_object_id,p_result_no);

  ELSIF lv_grs_water_rate_method = 'VOLUME_DURATION' THEN
    ln_duration := findDuration(p_result_no);
    IF ln_duration > 0 THEN
      ln_result := nvl(findGrsWaterVolume(p_result_no, lv_object_id, ld_daytime), 0) / ln_duration * 24;
    END IF;

  ELSIF lv_grs_water_rate_method = 'WOR_WGR' THEN
    IF lv_well_object_id IS NULL THEN -- well object_id hasn't been fecthed yet
      FOR cur_rst IN c_result(p_result_no) LOOP
        lv_well_object_id := cur_rst.well_object_id;
      END LOOP;
    END IF;

    IF ec_well_version.isOilProducer(lv_well_object_id,ld_daytime,'<=') = ECDP_TYPE.IS_TRUE THEN
      ln_result := nvl(findNetRate(p_result_no,Ecdp_Phase.OIL, lv_object_id, ld_daytime), 0) * nvl(findWOR(p_result_no, lv_object_id, ld_daytime), 0);

    ELSIF ec_well_version.isGasProducer(lv_well_object_id,ld_daytime,'<=') = ECDP_TYPE.IS_TRUE THEN
      ln_result := nvl(findNetRate(p_result_no, Ecdp_Phase.GAS, lv_object_id, ld_daytime), 0) * nvl(findWGR(p_result_no, lv_object_id, ld_daytime), 0);

    END IF;

  ELSIF (substr(lv_grs_water_rate_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_result := Ue_Testdevice.findGrsWaterRate(p_result_no, lv_object_id, ld_daytime);

  ELSE
    ln_result := NULL;
  END IF;

  RETURN ln_result;
END findGrsWaterRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGrsGasVolume
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findGrsGasVolume(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>

IS
  lv_grs_gas_vol_method  VARCHAR2(100);
  lv_object_id           VARCHAR2(32);
  ld_daytime             DATE;
  ln_result              NUMBER;

BEGIN
  IF p_object_id IS NULL OR p_daytime IS NULL THEN
    -- find object_id and daytime
    FOR cur_rst IN c_result(p_result_no) LOOP
      lv_object_id := cur_rst.tdev_object_id;
      ld_daytime := cur_rst.daytime;
    END LOOP;
  ELSE
    lv_object_id := p_object_id;
    ld_daytime := p_daytime;
  END IF;

  -- determine GrsGasVolMethod
  lv_grs_gas_vol_method := nvl(ec_test_device_version.grs_gas_vol_method(lv_object_id,ld_daytime,'<='), 'MEASURED');

  IF lv_grs_gas_vol_method = 'MEASURED' THEN
    ln_result := ec_test_device_result.gas_out_vol_raw(lv_object_id,p_result_no);

  ELSIF lv_grs_gas_vol_method = 'ORIFICE_AGA' THEN
    ln_result := ec_test_device_result.gas_vol_out_aga(lv_object_id,p_result_no) * nvl(findDuration(p_result_no), 0);

  ELSIF (substr(lv_grs_gas_vol_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_result := Ue_Testdevice.findGrsGasVolume(p_result_no,lv_object_id, ld_daytime);

  ELSE
    ln_result := NULL;
  END IF;

  RETURN ln_result;
END findGrsGasVolume;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGrsGasLiftVolume
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findGrsGasLiftVolume(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>

IS
  lv_grs_lift_vol_method                  VARCHAR2(100);
  lv_object_id                            VARCHAR2(32);
  lv_well_object_id                       VARCHAR2(32);
  ld_daytime                              DATE;
  ln_result                               NUMBER;

BEGIN
  IF p_object_id IS NULL OR p_daytime IS NULL THEN
    -- find object_id and daytime
    FOR cur_rst IN c_result(p_result_no) LOOP
      lv_object_id := cur_rst.tdev_object_id;
      ld_daytime := cur_rst.daytime;
      lv_well_object_id := cur_rst.well_object_id;
    END LOOP;
  ELSE
    lv_object_id := p_object_id;
    ld_daytime := p_daytime;
  END IF;

  -- determine GrsLiftVolMethod
  lv_grs_lift_vol_method := nvl(ec_test_device_version.grs_gl_vol_method(lv_object_id,ld_daytime,'<='), 'MEASURED');

  IF lv_grs_lift_vol_method = 'MEASURED' THEN
    ln_result := ec_test_device_result.gas_lift_vol_raw(lv_object_id,p_result_no);

  ELSIF lv_grs_lift_vol_method = 'ORIFICE_AGA' THEN
    ln_result := ec_test_device_result.gas_lift_vol_out_aga(lv_object_id,p_result_no) * nvl(findDuration(p_result_no), 0);

  ELSIF  lv_grs_lift_vol_method = 'CHOKE_LOOKUP' THEN
    IF lv_well_object_id IS NULL THEN -- well object_id hasn't been fecthed yet
      FOR cur_rst IN c_result(p_result_no) LOOP
        lv_well_object_id := cur_rst.well_object_id;
      END LOOP;
    END IF;

    ln_result := lookupGasLiftHrRate(p_result_no,lv_well_object_id,ld_daytime) * nvl(findDuration(p_result_no), 0);

  ELSIF (substr(lv_grs_lift_vol_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN

    ln_result := Ue_Testdevice.findGrsGasLiftVolume(p_result_no,lv_object_id,ld_daytime);

  ELSE
    ln_result := NULL;
  END IF;

  RETURN ln_result;
END findGrsGasLiftVolume;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGrsLiqVolMethod
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findGrsLiqVolume(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>

IS
  lv_grs_liq_vol_method               VARCHAR2(100);
  lv_object_id                        VARCHAR2(32);
  ld_daytime                          DATE;
  ln_result                           NUMBER;

BEGIN
  IF p_object_id IS NULL OR p_daytime IS NULL THEN
    -- find object_id and daytime
    FOR cur_rst IN c_result(p_result_no) LOOP
      lv_object_id := cur_rst.tdev_object_id;
      ld_daytime := cur_rst.daytime;
    END LOOP;
  ELSE
    lv_object_id := p_object_id;
    ld_daytime := p_daytime;
  END IF;

  -- determine GrsLiqVolMethod
  lv_grs_liq_vol_method := nvl(ec_test_device_version.grs_liq_vol_method(lv_object_id,ld_daytime,'<='), 'MEASURED');

  IF lv_grs_liq_vol_method = 'MEASURED' THEN
    ln_result := ec_test_device_result.oil_out_vol_raw(lv_object_id,p_result_no);

  ELSIF lv_grs_liq_vol_method = 'TOTALIZER' THEN
    ln_result := calcTotalizerVolume(p_result_no,Ecdp_Phase.OIL,lv_object_id,ld_daytime);


  ELSIF (substr(lv_grs_liq_vol_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN

    ln_result := Ue_Testdevice.findGrsLiqVolume(p_result_no,lv_object_id,ld_daytime);

  ELSE
    ln_result := NULL;
  END IF;

  RETURN ln_result;
END findGrsLiqVolume;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGrsWaterVolume
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findGrsWaterVolume(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>

IS
  lv_grs_water_vol_method  VARCHAR2(100);
  lv_object_id             VARCHAR2(32);
  ld_daytime               DATE;
  ln_result                NUMBER;

BEGIN
  IF p_object_id IS NULL OR p_daytime IS NULL THEN
    -- find object_id and daytime
    FOR cur_rst IN c_result(p_result_no) LOOP
      lv_object_id := cur_rst.tdev_object_id;
      ld_daytime := cur_rst.daytime;
    END LOOP;
  ELSE
    lv_object_id := p_object_id;
    ld_daytime := p_daytime;
  END IF;

  -- determine the GrsWaterVolMethod
  lv_grs_water_vol_method := nvl(ec_test_device_version.grs_water_vol_method(lv_object_id, ld_daytime, '<='), 'MEASURED');

  IF lv_grs_water_vol_method = 'MEASURED' THEN
    ln_result := ec_test_device_result.water_out_vol_raw(lv_object_id, p_result_no);

  ELSIF lv_grs_water_vol_method = 'TOTALIZER' THEN
    ln_result := calcTotalizerVolume(p_result_no,Ecdp_Phase.WATER,lv_object_id,ld_daytime);

  ELSIF (substr(lv_grs_water_vol_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_result := Ue_Testdevice.findGrsWaterVolume(p_result_no,lv_object_id,ld_daytime);

  ELSE
    ln_result := NULL;
  END IF;

  RETURN ln_result;
END findGrsWaterVolume;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGOR
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findGOR(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>

IS
  lv_gor_method              VARCHAR2(100);
  lv_object_id               VARCHAR2(32);
  lv_well_object_id          VARCHAR2(32);
  ld_daytime                 DATE;
  ln_result                  NUMBER;

  ln_oil_net_rate       NUMBER;

BEGIN
  IF p_object_id IS NULL OR p_daytime IS NULL THEN
    -- find object_id and daytime
    FOR cur_rst IN c_result(p_result_no) LOOP
      lv_object_id := cur_rst.tdev_object_id;
      ld_daytime := cur_rst.daytime;
      lv_well_object_id := cur_rst.well_object_id;
    END LOOP;
  ELSE
    lv_object_id := p_object_id;
    ld_daytime := p_daytime;
  END IF;

  -- determine GORMethod
  lv_gor_method := nvl(ec_test_device_version.gor(lv_object_id,ld_daytime,'<='), 'MEASURED');

  IF lv_gor_method = 'MEASURED' THEN
    ln_result := ec_test_device_result.gor(lv_object_id,p_result_no);

  ELSIF lv_gor_method = 'GAS_DIV_OIL' THEN
    ln_oil_net_rate := nvl(findStdNetRate(p_result_no,EcDp_Phase.OIL, lv_object_id, ld_daytime),0);
    IF ln_oil_net_rate > 0 THEN
      ln_result := nvl(findStdNetRate(p_result_no,Ecdp_Phase.GAS, lv_object_id, ld_daytime),0) / ln_oil_net_rate;
    ELSE
      ln_result := NULL;
    END IF;

  ELSIF lv_gor_method = 'WELL_REFERENCE_VALUE' THEN
    IF lv_well_object_id IS NULL THEN -- well object_id hasn't been fecthed yet
      FOR cur_rst IN c_result(p_result_no) LOOP
        lv_well_object_id := cur_rst.well_object_id;
      END LOOP;
    END IF;
    ln_result := ec_well_reference_value.gor(lv_well_object_id,ld_daytime,'<=');

  ELSIF (substr(lv_gor_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_result := Ue_Testdevice.findGOR(p_result_no,lv_object_id,ld_daytime);

  ELSE
    ln_result := NULL;
  END IF;

  RETURN ln_result;
END findGOR;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findCGR
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findCGR(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>

IS
  lv_cgr_method              VARCHAR2(100);
  lv_object_id               VARCHAR2(32);
  lv_well_object_id          VARCHAR2(32);
  ld_daytime                 DATE;
  ln_result                  NUMBER;

  ln_gas_std_rate         NUMBER;

BEGIN
  IF p_object_id IS NULL OR p_daytime IS NULL THEN
    -- find object_id and daytime
    FOR cur_rst IN c_result(p_result_no) LOOP
      lv_object_id := cur_rst.tdev_object_id;
      ld_daytime := cur_rst.daytime;
      lv_well_object_id := cur_rst.well_object_id;
    END LOOP;
  ELSE
    lv_object_id := p_object_id;
    ld_daytime := p_daytime;
  END IF;

  -- determine CGR Method
  lv_cgr_method := nvl(ec_test_device_version.cgr(lv_object_id,ld_daytime,'<='), 'MEASURED');

  IF lv_cgr_method = 'MEASURED' THEN
    ln_result := ec_test_device_result.cgr(lv_object_id,p_result_no);

  ELSIF lv_cgr_method = 'COND_DIV_GAS' THEN
    ln_gas_std_rate := nvl(findStdNetRate(p_result_no,Ecdp_Phase.GAS, lv_object_id, ld_daytime),0);
    IF ln_gas_std_rate > 0 THEN
      ln_result := nvl(findStdNetRate(p_result_no,Ecdp_Phase.CONDENSATE, lv_object_id, ld_daytime),0) / ln_gas_std_rate;
    ELSE
      ln_result := NULL;
    END IF;

  ELSIF lv_cgr_method = 'WELL_REFERENCE_VALUE' THEN
    IF lv_well_object_id IS NULL THEN -- well object_id hasn't been fecthed yet
      FOR cur_rst IN c_result(p_result_no) LOOP
        lv_well_object_id := cur_rst.well_object_id;
      END LOOP;
    END IF;
    ln_result := ec_well_reference_value.cgr(lv_well_object_id,ld_daytime,'<=');

  ELSIF (substr(lv_cgr_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_result := Ue_Testdevice.findCGR(p_result_no,lv_object_id,ld_daytime);

  ELSE
    ln_result := NULL;
  END IF;

  RETURN ln_result;
END findCGR;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findBswVol
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findBswVol(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>

IS
  lv_bsw_vol_method             VARCHAR2(100);
  lv_object_id                  VARCHAR2(32);
  lv_well_object_id             VARCHAR2(32);
  ld_daytime                    DATE;
  ln_result                     NUMBER;
  lr_analysis_sample object_fluid_analysis%ROWTYPE;

BEGIN
  IF p_object_id IS NULL OR p_daytime IS NULL THEN
    -- find object_id and daytime
    FOR cur_rst IN c_result(p_result_no) LOOP
      lv_object_id := cur_rst.tdev_object_id;
      ld_daytime := cur_rst.daytime;
      lv_well_object_id := cur_rst.well_object_id;
    END LOOP;
  ELSE
    lv_object_id := p_object_id;
    ld_daytime := p_daytime;
  END IF;

  -- determine BswVolMethod
  lv_bsw_vol_method := nvl(ec_test_device_version.bsw_vol_method(lv_object_id,ld_daytime,'<='), 'MEASURED');

  --Method : MEASURED
  IF lv_bsw_vol_method = 'MEASURED' THEN
    ln_result := ec_test_device_result.water_in_oil_out(lv_object_id,p_result_no);

  --Method : SAMPLE_ANALYSIS
  ELSIF lv_bsw_vol_method = 'SAMPLE_ANALYSIS' THEN
    IF lv_well_object_id IS NULL THEN -- well object_id hasn't been fecthed yet
      FOR cur_rst IN c_result(p_result_no) LOOP
        lv_well_object_id := cur_rst.well_object_id;
      END LOOP;
    END IF;

    -- 'RES' hardcoded as all Well records in Well Sample Analysis have phase=�RES� in the db.
    lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv_well_object_id, 'WELL_SAMPLE_ANALYSIS', NULL, p_daytime, 'RES');
    ln_result := lr_analysis_sample.bs_w;

  --Method : SAMPLE_ANALYSIS_SPOT
  ELSIF lv_bsw_vol_method = 'SAMPLE_ANALYSIS_SPOT' THEN
    IF lv_well_object_id IS NULL THEN -- well object_id hasn't been fecthed yet
      FOR cur_rst IN c_result(p_result_no) LOOP
        lv_well_object_id := cur_rst.well_object_id;
      END LOOP;
    END IF;

    -- 'RES' hardcoded as all Well records in Well Sample Analysis have phase=�RES� in the db.
    lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv_well_object_id, 'WELL_SAMPLE_ANALYSIS', 'SPOT', p_daytime, 'RES');
    ln_result := lr_analysis_sample.bs_w;

  --Method : SAMPLE_ANALYSIS_DAY
  ELSIF lv_bsw_vol_method = 'SAMPLE_ANALYSIS_DAY' THEN
    IF lv_well_object_id IS NULL THEN -- well object_id hasn't been fecthed yet
      FOR cur_rst IN c_result(p_result_no) LOOP
        lv_well_object_id := cur_rst.well_object_id;
      END LOOP;
    END IF;

    -- 'RES' hardcoded as all Well records in Well Sample Analysis have phase=�RES� in the db.
    lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv_well_object_id, 'WELL_SAMPLE_ANALYSIS', 'DAY_SAMPLER', p_daytime, 'RES');
    ln_result := lr_analysis_sample.bs_w;

  --Method : SAMPLE_ANALYSIS_MTH
  ELSIF lv_bsw_vol_method = 'SAMPLE_ANALYSIS_MTH' THEN
    IF lv_well_object_id IS NULL THEN -- well object_id hasn't been fecthed yet
      FOR cur_rst IN c_result(p_result_no) LOOP
        lv_well_object_id := cur_rst.well_object_id;
      END LOOP;
    END IF;

    -- 'RES' hardcoded as all Well records in Well Sample Analysis have phase=�RES� in the db.
    lr_analysis_sample := Ecdp_Fluid_Analysis.getLastAnalysisSample(lv_well_object_id, 'WELL_SAMPLE_ANALYSIS', 'MTH_SAMPLER', p_daytime, 'RES');
    ln_result := lr_analysis_sample.bs_w;

  --Method : WELL_REFERENCE_VALUE
  ELSIF lv_bsw_vol_method = 'WELL_REFERENCE_VALUE' THEN
    IF lv_well_object_id IS NULL THEN -- well object_id hasn't been fecthed yet
      FOR cur_rst IN c_result(p_result_no) LOOP
        lv_well_object_id := cur_rst.well_object_id;
      END LOOP;
    END IF;
    ln_result := ec_well_reference_value.bsw(lv_well_object_id,ld_daytime, '<=');


  ELSIF (substr(lv_bsw_vol_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_result := Ue_Testdevice.findBswVol(p_result_no,lv_object_id,ld_daytime);

  ELSE
    ln_result := NULL;
  END IF;

  RETURN ln_result;
END findBswVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWORMethod
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findWOR(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>

IS
  lv_wor_method              VARCHAR2(100);
  lv_object_id               VARCHAR2(32);
  lv_well_object_id          VARCHAR2(32);
  ld_daytime                 DATE;
  ln_result                  NUMBER;

  ln_oil_std_rate            NUMBER;

BEGIN
  IF p_object_id IS NULL OR p_daytime IS NULL THEN
    -- find object_id and daytime
    FOR cur_rst IN c_result(p_result_no) LOOP
      lv_object_id := cur_rst.tdev_object_id;
      ld_daytime := cur_rst.daytime;
      lv_well_object_id := cur_rst.well_object_id;
    END LOOP;
  ELSE
    lv_object_id := p_object_id;
    ld_daytime := p_daytime;
  END IF;

  -- determine WORMethod
  lv_wor_method := nvl(ec_test_device_version.wor(lv_object_id,ld_daytime,'<='), 'MEASURED');

  IF lv_wor_method = 'MEASURED' THEN
    ln_result := ec_test_device_result.wor(lv_object_id,p_result_no);

  ELSIF lv_wor_method = 'WATER_DIV_OIL' THEN
    ln_oil_std_rate := nvl(findStdNetRate(p_result_no,Ecdp_Phase.OIL, lv_object_id, ld_daytime),0);
    IF ln_oil_std_rate > 0 THEN
      ln_result := nvl(findStdNetRate(p_result_no,Ecdp_Phase.WATER, lv_object_id, ld_daytime),0) / ln_oil_std_rate;
    ELSE
      ln_result := NULL;
    END IF;

  ELSIF lv_wor_method = 'WELL_REFERENCE_VALUE' THEN
    IF lv_well_object_id IS NULL THEN -- well object_id hasn't been fecthed yet
      FOR cur_rst IN c_result(p_result_no) LOOP
        lv_well_object_id := cur_rst.well_object_id;
      END LOOP;
    END IF;
    ln_result := ec_well_reference_value.wor(lv_well_object_id,ld_daytime,'<=' );

  ELSIF (substr(lv_wor_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_result := Ue_Testdevice.findWOR(p_result_no,lv_object_id,ld_daytime);

  ELSE
    ln_result := NULL;
  END IF;

  RETURN ln_result;
END findWOR;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGLR
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findGLR(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>

IS
  lv_glr_method              VARCHAR2(100);
  lv_object_id               VARCHAR2(32);
  lv_well_object_id          VARCHAR2(32);
  ld_daytime                 DATE;
  ln_result                  NUMBER;

  ln_liq_std_rate            NUMBER;

BEGIN
  IF p_object_id IS NULL OR p_daytime IS NULL THEN
    -- find object_id and daytime
    FOR cur_rst IN c_result(p_result_no) LOOP
      lv_object_id := cur_rst.tdev_object_id;
      ld_daytime := cur_rst.daytime;
      lv_well_object_id := cur_rst.well_object_id;
    END LOOP;
  ELSE
    lv_object_id := p_object_id;
    ld_daytime := p_daytime;
  END IF;

  -- determine GLRMethod
  lv_glr_method := nvl(ec_test_device_version.glr(lv_object_id,ld_daytime,'<='), 'MEASURED');

  IF lv_glr_method = 'MEASURED' THEN
    ln_result := ec_test_device_result.glr(lv_object_id,p_result_no);

  ELSIF lv_glr_method = 'GAS_DIV_LIQUID' THEN
    ln_liq_std_rate := nvl(findStdNetRate(p_result_no, Ecdp_Phase.OIL, lv_object_id, ld_daytime), 0) + nvl(findStdNetRate(p_result_no,Ecdp_Phase.WATER, lv_object_id, ld_daytime), 0);
    IF ln_liq_std_rate > 0 THEN
      ln_result := nvl(findStdNetRate(p_result_no,Ecdp_Phase.GAS, lv_object_id, ld_daytime),0) / ln_liq_std_rate;
    ELSE
      ln_result := NULL;
    END IF;

  ELSIF lv_glr_method = 'WELL_REFERENCE_VALUE' THEN
    IF lv_well_object_id IS NULL THEN -- well object_id hasn't been fecthed yet
      FOR cur_rst IN c_result(p_result_no) LOOP
        lv_well_object_id := cur_rst.well_object_id;
      END LOOP;
    END IF;
    ln_result := ec_well_reference_value.glr(lv_well_object_id,ld_daytime,'<=');

  ELSIF (substr(lv_glr_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_result := Ue_Testdevice.findGLR(p_result_no,lv_object_id,ld_daytime);

  ELSE
    ln_result := NULL;
  END IF;

  RETURN ln_result;
END findGLR;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWGR
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findWGR(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>

IS
  lv_wgr_method              VARCHAR2(100);
  lv_object_id               VARCHAR2(32);
  lv_well_object_id          VARCHAR2(32);
  ld_daytime                 DATE;
  ln_result                  NUMBER;

  ln_gas_std_rate            NUMBER;

BEGIN
  IF p_object_id IS NULL OR p_daytime IS NULL THEN
    -- find object_id and daytime
    FOR cur_rst IN c_result(p_result_no) LOOP
      lv_object_id := cur_rst.tdev_object_id;
      ld_daytime := cur_rst.daytime;
      lv_well_object_id := cur_rst.well_object_id;
    END LOOP;
  ELSE
    lv_object_id := p_object_id;
    ld_daytime := p_daytime;
  END IF;

  -- determine WGRMethod
  lv_wgr_method := nvl(ec_test_device_version.wgr(lv_object_id,ld_daytime,'<='), 'MEASURED');

  IF lv_wgr_method = 'MEASURED' THEN
    ln_result := ec_test_device_result.wgr(lv_object_id,p_result_no);

  ELSIF lv_wgr_method = 'WATER_DIV_GAS' THEN
    ln_gas_std_rate := nvl(findStdNetRate(p_result_no,Ecdp_Phase.GAS, lv_object_id, ld_daytime),0);
    IF ln_gas_std_rate > 0 THEN
      ln_result := nvl(findStdNetRate(p_result_no,Ecdp_Phase.WATER, lv_object_id, ld_daytime),0) / ln_gas_std_rate;
    ELSE
      ln_result := NULL;
    END IF;

  ELSIF lv_wgr_method = 'WELL_REFERENCE_VALUE' THEN
    IF lv_well_object_id IS NULL THEN -- well object_id hasn't been fecthed yet
      FOR cur_rst IN c_result(p_result_no) LOOP
        lv_well_object_id := cur_rst.well_object_id;
      END LOOP;
    END IF;
    ln_result := ec_well_reference_value.wgr(lv_well_object_id,ld_daytime,'<=');

  ELSIF (substr(lv_wgr_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_result := Ue_Testdevice.findWGR(p_result_no,lv_object_id,ld_daytime);

  ELSE
    ln_result := NULL;
  END IF;

  RETURN ln_result;
END findWGR;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWetDryFactor
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findWetDryFactor(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>

IS
  lv_well_obj_id                      VARCHAR2(32);
  lv_object_id                        VARCHAR2(32);
  ld_daytime                          DATE;
  ln_result                           NUMBER;
  ln_gas_std_rate                     NUMBER;

BEGIN
  IF p_object_id IS NULL OR p_daytime IS NULL THEN
    -- find object_id and daytime
    FOR cur_rst IN c_result(p_result_no) LOOP
      lv_object_id := cur_rst.tdev_object_id;
      ld_daytime := cur_rst.daytime;
      lv_well_obj_id := cur_rst.well_object_id;
    END LOOP;
  ELSE
    lv_object_id := p_object_id;
    ld_daytime := p_daytime;

    FOR cur_rst IN c_result(p_result_no) LOOP
      lv_well_obj_id := cur_rst.well_object_id;
    END LOOP;
  END IF;

  ln_gas_std_rate := nvl(findStdNetRate(p_result_no, Ecdp_Phase.GAS, lv_object_id, ld_daytime), 0);
  IF ln_gas_std_rate > 0 THEN
	ln_gas_std_rate:=ln_gas_std_rate + nvl(calcImpurityRate(p_result_no,ln_gas_std_rate,Ecdp_Phase.GAS, lv_object_id, ld_daytime), 0);
    ln_result := nvl(findWellWetGasRate(p_result_no, lv_object_id, ld_daytime), 0) / ln_gas_std_rate;
  ELSE
    ln_result := NULL;
  END IF;

  RETURN ln_result;
END findWetDryFactor;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWetGasGravity
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findWetGasGravity(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>

IS
  lv_object_id                         VARCHAR2(32);
  ld_daytime                           DATE;
  ln_result                            NUMBER;
  ln_gas_std_rate                      NUMBER;

BEGIN
  IF p_object_id IS NULL OR p_daytime IS NULL THEN
    -- find object_id and daytime
    FOR cur_rst IN c_result(p_result_no) LOOP
      lv_object_id := cur_rst.tdev_object_id;
      ld_daytime := cur_rst.daytime;
    END LOOP;
  ELSE
    lv_object_id := p_object_id;
    ld_daytime := p_daytime;
  END IF;

  --calculate the Estimate Wet Gas Gravity
  --Estimated wet gas gravity (EWGG) = 2.856 * cond_rate/dry_gas_rate + dry_gas_grav
  ln_gas_std_rate := nvl(findStdNetRate(p_result_no, Ecdp_Phase.GAS, lv_object_id, ld_daytime), 0);
  IF ln_gas_std_rate > 0 THEN
    ln_result := 2.856 *
                 (nvl(findStdNetRate(p_result_no, Ecdp_Phase.CONDENSATE, lv_object_id, ld_daytime), 0) /
                 ln_gas_std_rate) +
                 ec_test_device_result.gas_sp_grav(lv_object_id,p_result_no);
  ELSE
    ln_result := NULL;
  END IF;

  RETURN ln_result;
END findWetGasGravity;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findDuration
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findDuration(p_result_no NUMBER)
RETURN NUMBER
--</EC-DOC>

IS
  lv_well_obj_id                  VARCHAR2(32);
  ln_duration                     NUMBER;
  ln_result                       NUMBER;
  lr_pwel_result                  PWEL_RESULT%ROWTYPE;

BEGIN
  -- find object_id
  FOR cur_rst IN c_result(p_result_no) LOOP
    lv_well_obj_id := cur_rst.well_object_id;
  END LOOP;

  lr_pwel_result := ec_pwel_result.row_by_pk(lv_well_obj_id, p_result_no);

  -- get the duration
  ln_duration := lr_pwel_result.duration;

  IF ln_duration IS NOT NULL THEN
    ln_result := ln_duration;

  ELSE
    ln_result := (lr_pwel_result.end_date - lr_pwel_result.daytime) * 24;

  END IF;

  RETURN ln_result;
END findDuration;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findTdevRefShrinkageFactor
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findTdevRefShrinkageFactor(p_result_no NUMBER, p_phase VARCHAR2, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>

IS
  lv_object_id                    VARCHAR2(32);
  ld_daytime                      DATE;
  ln_result                       NUMBER;

BEGIN
  IF p_object_id IS NULL OR p_daytime IS NULL THEN
    FOR cur_rst IN c_result(p_result_no) LOOP
      lv_object_id := cur_rst.tdev_object_id;
      ld_daytime := cur_rst.daytime;
    END LOOP;
  ELSE
    lv_object_id := p_object_id;
    ld_daytime := p_daytime;
  END IF;

  IF p_phase = Ecdp_Phase.OIL THEN
    ln_result := ec_tdev_reference_value.oil_shrinkage_factor(lv_object_id, ld_daytime, '<=');
  ELSIF p_phase = Ecdp_Phase.GAS THEN
    ln_result := ec_tdev_reference_value.gas_shrinkage_factor(lv_object_id, ld_daytime, '<=');
  ELSE
    ln_result := NULL;
  END IF;

  RETURN ln_result;
END findTdevRefShrinkageFactor;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findInvertedShrinkageFactors
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findInvertedShrinkageFactors(p_object_id VARCHAR2, p_daytime DATE, p_density NUMBER, p_pressure NUMBER, p_temperature NUMBER)
RETURN STRM_DPT_CONVERSION%ROWTYPE
--</EC-DOC>

IS
  lr_sdpt       STRM_DPT_CONVERSION%ROWTYPE;
  lr_spt        STRM_PT_CONVERSION%ROWTYPE;

BEGIN
  -- ECPD-15842
  -- support density is null and call ecdp_stream_pt_value instead
  IF p_density IS NULL THEN

    lr_spt := ec_strm_pt_conversion.row_by_pk(p_object_id,p_daytime,p_pressure,p_temperature,'<=');
    IF lr_spt.Bo IS NULL THEN       -- no exact match. Thus, find thru interpolation
      lr_spt.Bo := Ecdp_Stream_pt_Value.findInvertedFactorFromPT(p_object_id,p_daytime,p_pressure,p_temperature,Ecdp_Stream_dpt_Value.COL_BO);
    END IF;
    IF lr_spt.Bg IS NULL THEN       -- no exact match. Thus, find thru interpolation
      lr_spt.Bg := Ecdp_Stream_pt_Value.findInvertedFactorFromPT(p_object_id,p_daytime,p_pressure,p_temperature,Ecdp_Stream_dpt_Value.COL_BG);
    END IF;
    IF lr_spt.Bw IS NULL THEN       -- no exact match. Thus, find thru interpolation
      lr_spt.Bw := Ecdp_Stream_pt_Value.findInvertedFactorFromPT(p_object_id,p_daytime,p_pressure,p_temperature,Ecdp_Stream_dpt_Value.COL_BW);
    END IF;
    IF lr_spt.Rs IS NULL THEN       -- no exact match. Thus, find thru interpolation
      lr_spt.Rs := Ecdp_Stream_pt_Value.findInvertedFactorFromPT(p_object_id,p_daytime,p_pressure,p_temperature,Ecdp_Stream_dpt_Value.COL_RS);
    END IF;
    IF lr_spt.Sp_Grav IS NULL THEN  -- no exact match. Thus, find thru interpolation
      lr_spt.Sp_Grav := Ecdp_Stream_pt_Value.findInvertedFactorFromPT(p_object_id,p_daytime,p_pressure,p_temperature,Ecdp_Stream_dpt_Value.COL_SP_GRAV);
    END IF;
    -- move variables over from lr_spt to lr_sdpt which are the variables returned from the function
    lr_sdpt.Bo := lr_spt.Bo;
    lr_sdpt.Bg := lr_spt.Bg;
    lr_sdpt.Bw := lr_spt.Bw;
    lr_sdpt.Rs := lr_spt.Rs;
    lr_sdpt.Sp_Grav := lr_spt.Sp_Grav;

  ELSE

    lr_sdpt := ec_strm_dpt_conversion.row_by_pk(p_object_id,p_density,p_pressure,p_temperature,p_daytime,'<=');
    IF lr_sdpt.Bo IS NULL THEN       -- no exact match. Thus, find thru interpolation
      lr_sdpt.Bo := Ecdp_Stream_Dpt_Value.findInvertedFactorFromDPT(p_object_id,p_daytime,p_density,p_pressure,p_temperature,Ecdp_Stream_Dpt_Value.COL_BO);
    END IF;
    IF lr_sdpt.Bg IS NULL THEN       -- no exact match. Thus, find thru interpolation
      lr_sdpt.Bg := Ecdp_Stream_Dpt_Value.findInvertedFactorFromDPT(p_object_id,p_daytime,p_density,p_pressure,p_temperature,Ecdp_Stream_Dpt_Value.COL_BG);
    END IF;
    IF lr_sdpt.Bw IS NULL THEN       -- no exact match. Thus, find thru interpolation
      lr_sdpt.Bw := Ecdp_Stream_Dpt_Value.findInvertedFactorFromDPT(p_object_id,p_daytime,p_density,p_pressure,p_temperature,Ecdp_Stream_Dpt_Value.COL_BW);
    END IF;
    IF lr_sdpt.Rs IS NULL THEN       -- no exact match. Thus, find thru interpolation
      lr_sdpt.Rs := Ecdp_Stream_Dpt_Value.findInvertedFactorFromDPT(p_object_id,p_daytime,p_density,p_pressure,p_temperature,Ecdp_Stream_Dpt_Value.COL_RS);
    END IF;
    IF lr_sdpt.Sp_Grav IS NULL THEN  -- no exact match. Thus, find thru interpolation
      lr_sdpt.Sp_Grav := Ecdp_Stream_Dpt_Value.findInvertedFactorFromDPT(p_object_id,p_daytime,p_density,p_pressure,p_temperature,Ecdp_Stream_Dpt_Value.COL_SP_GRAV);
    END IF;

  END IF;

  RETURN lr_sdpt;
END findInvertedShrinkageFactors;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : lookupGasLiftHrRate
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION lookupGasLiftHrRate(p_result_no NUMBER, p_well_object_id WELL.OBJECT_ID%TYPE, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>

IS
  lv2_gl_choke_object_id        VARCHAR2(32);
  ln_retval                     NUMBER;
  lr_pwel_result                PWEL_RESULT%ROWTYPE;

BEGIN

  lr_pwel_result := ec_pwel_result.row_by_pk(p_well_object_id, p_result_no);

  lv2_gl_choke_object_id := ec_well_version.gl_choke_id(p_well_object_id,p_daytime,'<=');

  IF lv2_gl_choke_object_id IS NULL THEN         -- no choke been configured, skip the lookup
    ln_retval := NULL;

  ELSE
    ln_retval := ec_choke_gl_conversion.gl_hr_rate(lv2_gl_choke_object_id,
                                                   lr_pwel_result.gl_choke_size,
                                                   lr_pwel_result.gl_diff_press,
                                                   p_daytime,
                                                   '<=');

    IF ln_retval IS NULL THEN  -- no exact match. Thus, find thru interpolation
      ln_retval := Ecdp_Well_Choke_Value.findGLRateFrmChokeAndDiffPress(lv2_gl_choke_object_id,
                                                                         p_daytime,
                                                                         lr_pwel_result.gl_choke_size,
                                                                         lr_pwel_result.gl_diff_press);

    END IF;
  END IF;

  RETURN ln_retval;
END lookupGasLiftHrRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcImpurityRate
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcImpurityRate(p_result_no NUMBER, p_grs_rate NUMBER, p_phase VARCHAR2, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>

IS
  ln_result                NUMBER;
  lv_object_id             VARCHAR2(32);
  ld_daytime               DATE;

  -- variables for OIL / COND calculation
  ln_water_in_oil          NUMBER;
  ln_diluent_inj           NUMBER;
  ln_oil_in_water          NUMBER;
  lr_test_device_result           test_device_result%ROWTYPE;

  -- variables for GAS calculation
  ln_stdPress              NUMBER;    -- pressure at standard condition
  ln_flcPress              NUMBER;    -- pressure at flowing condition
  ln_stdTemp               NUMBER;    -- temperature at standard condition
  ln_flcTemp               NUMBER;    -- temperature at flowing condition

  -- variables for WATER calculation
  ln_power_water_used      NUMBER;

BEGIN
  IF p_object_id IS NULL OR p_daytime IS NULL THEN
    -- find object_id and daytime
    FOR cur_rst IN c_result(p_result_no) LOOP
      lv_object_id := cur_rst.tdev_object_id;
      ld_daytime := cur_rst.daytime;
    END LOOP;
  ELSE
    lv_object_id := p_object_id;
    ld_daytime := p_daytime;
  END IF;

  lr_test_device_result := ec_test_device_result.row_by_pk(lv_object_id,p_result_no);

  IF p_phase = Ecdp_Phase.OIL OR p_phase = Ecdp_Phase.CONDENSATE THEN
    ln_water_in_oil := nvl(p_grs_rate, 0) * nvl(findBswVol(p_result_no, lv_object_id, ld_daytime), 0);  -- calc any water in oil
    ln_diluent_inj := nvl(findDiluentRate(p_result_no, lv_object_id, ld_daytime),0);
    ln_oil_in_water := nvl(findGrsWaterRate(p_result_no, lv_object_id, ld_daytime), 0) * (nvl(lr_test_device_result.oil_in_water_out, 0) / 1000000); -- deduct any oil in water

    ln_result := ln_water_in_oil + ln_diluent_inj - ln_oil_in_water;

  ELSIF p_phase = Ecdp_Phase.GAS THEN
    -- ECPD-15842
    -- For gas, its gaslift that will be the "impurity", but not if Grs Gas Rate is LIQUID_GOR, because GOR is already net gas lift
    IF ec_test_device_version.grs_gas_rate_method(lv_object_id,ld_daytime,'<=') = 'LIQUID_GOR' THEN
       RETURN 0;
    ELSE
      ln_flcPress := Ecdp_Unit.convertValue(lr_test_device_result.tdev_press,
                                            Ecdp_Unit.GetUnitFromLogical(EcDp_ClassMeta_Cnfg.getUomCode(lr_test_device_result.data_class_name, 'TDEV_PRESS')),
                                            'MBAR');
      ln_flcTemp := Ecdp_Unit.convertValue(lr_test_device_result.tdev_temp,
                                           Ecdp_Unit.GetUnitFromLogical(EcDp_ClassMeta_Cnfg.getUomCode(lr_test_device_result.data_class_name, 'TDEV_TEMP')),
                                           'K');
      ln_stdPress := ec_ctrl_system_attribute.attribute_value(ld_daytime, 'REF_AIR_PRESS', '<=');  -- reference pressure in milibar
      ln_stdTemp := Ecdp_Unit.convertValue(ec_ctrl_system_attribute.attribute_value(ld_daytime, 'REF_AIR_TEMP', '<='),
                                           'C',
                                           'K');  -- 15C converted to kelvin
      IF (ln_flcPress IS NULL OR ln_flcPress=0 OR ln_stdTemp IS NULL OR ln_stdTemp=0) THEN
        ln_result := nvl(findGrsGasLiftRate(p_result_no, lv_object_id, ld_daytime), 0);
      ELSE
        ln_result := nvl(findGrsGasLiftRate(p_result_no, lv_object_id, ld_daytime), 0) * (nvl(ln_stdPress,0) / nvl(ln_flcPress,0)) * (nvl(ln_flcTemp,0) / nvl(ln_stdTemp,0));
      END IF;
    END IF;

  ELSIF p_phase = Ecdp_Phase.WATER THEN
    ln_oil_in_water := nvl(lr_test_device_result.oil_in_water_out, 0) / 1000000;  -- deduct any oil in the water
    ln_water_in_oil := nvl(findGrsLiqRate(p_result_no, lv_object_id, ld_daytime), 0) * nvl(findBswVol(p_result_no, lv_object_id, ld_daytime), 0);  -- deduct any water in oil
    ln_power_water_used := nvl(lr_test_device_result.power_water_flc, 0);  -- deduct any power water used

    ln_result := ln_water_in_oil  - (nvl(p_grs_rate, 0) * ln_oil_in_water) - ln_power_water_used;

  END IF;

  RETURN ln_result;

END calcImpurityRate;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcShrinkageVolume
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcShrinkageVolume(p_result_no NUMBER, p_net_rate NUMBER, p_phase VARCHAR2, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>


IS
  ln_result                NUMBER;
  lv_object_id             VARCHAR2(32);
  lv_well_object_id        VARCHAR2(32);
  lv_q_strm_object_id      VARCHAR2(32);
  ld_daytime               DATE;
  lv_shrinkage_method      VARCHAR2(32);

  lr_strv                  STRM_REFERENCE_VALUE%ROWTYPE;
  -- Stream Ref Value: Oil Shrinakge constants
  ln_osr_const_1           NUMBER;
  ln_osr_const_press_1     NUMBER;
  ln_osr_const_press_2     NUMBER;
  ln_osr_const_press_3     NUMBER;
  ln_osr_const_press_4     NUMBER;
  ln_osr_const_press_5     NUMBER;
  ln_osr_const_press_6     NUMBER;
  ln_osr_const_temp_1      NUMBER;
  ln_osr_const_temp_2      NUMBER;
  ln_osr_const_temp_3      NUMBER;
  ln_osr_const_temp_4      NUMBER;
  -- Stream Ref Value: Gas Shrinakge constants
  ln_gsr_const_1           NUMBER;
  ln_gsr_const_press_1     NUMBER;
  ln_gsr_const_press_2     NUMBER;
  ln_gsr_const_press_3     NUMBER;
  ln_gsr_const_press_4     NUMBER;
  ln_gsr_const_press_5     NUMBER;
  ln_gsr_const_press_6     NUMBER;
  ln_gsr_const_temp_1      NUMBER;
  ln_gsr_const_temp_2      NUMBER;
  ln_gsr_const_temp_3      NUMBER;
  ln_gsr_const_temp_4      NUMBER;
  -- Stream Ref Value: Gas In Solution constants
  ln_gis_const_1           NUMBER;
  ln_gis_const_press_1     NUMBER;
  ln_gis_const_press_2     NUMBER;
  ln_gis_const_press_3     NUMBER;
  ln_gis_const_press_4     NUMBER;
  ln_gis_const_press_5     NUMBER;
  ln_gis_const_press_6     NUMBER;
  ln_gis_const_temp_1      NUMBER;
  ln_gis_const_temp_2      NUMBER;
  ln_gis_const_temp_3      NUMBER;
  ln_gis_const_temp_4      NUMBER;
  lr_eqrt                  test_device_result%ROWTYPE;
  ln_tdev_press            NUMBER;
  ln_tdev_temp             NUMBER;

  ln_oil_shrinkage_factor  NUMBER;
  ln_gas_in_solution       NUMBER;
  ln_gas_shrinkage_factor  NUMBER;

  ln_tdev_density          NUMBER;
  ln_pwr_temp              NUMBER;
  ln_pwr_press             NUMBER;

  lr_sdpt                  STRM_DPT_CONVERSION%ROWTYPE;
  lv2_formula              VARCHAR2(24);

CURSOR c_quality_streams(cp_well_id VARCHAR2, cp_daytime DATE) IS
 SELECT
 DISTINCT
 w.object_id AS WELL_ID,
 rbfv.object_id rbf_id,
 rbfv.stream_id quality_stream_id,
 (wbs.oil_contrib_pct/100)*(wbis.oil_pct/100)*(pis.oil_pct/100) resv_block_form_factor
 FROM well w,
      webo_bore wb ,
      webo_interval wbi,
      webo_split_factor wbs,
      webo_interval_gor wbis,
      resv_block_formation rbf,
      rbf_version rbfv,
      perf_interval pi,
      perf_interval_gor pis,
	  perf_interval_version piv
 WHERE wb.well_id = w.object_id
 AND wbi.well_bore_id = wb.object_id
 AND pi.webo_interval_id = wbi.object_id
 AND wbs.well_bore_id = wb.object_id
 AND wbis.object_id = wbi.object_id
 AND pis.object_id = pi.object_id
 --AND rbfv.object_id = pi.resv_block_formation_id
 AND piv.object_id = pi.object_id
 AND rbfv.object_id = piv.resv_block_formation_id
 AND wbis.daytime <= cp_daytime
 AND (wbis.end_date is null OR wbis.end_date > cp_daytime)
 AND wbs.daytime <= cp_daytime
 AND (wbs.end_date is null OR wbs.end_date > cp_daytime)
 AND pis.daytime <= cp_daytime
 AND (pis.end_date is null OR pis.end_date > cp_daytime)
 AND w.object_id = cp_well_id;

BEGIN
  ln_result := NULL;
  -- access key data
  FOR cur_rst IN c_result(p_result_no) LOOP
    -- test device object_id
    lv_object_id := NVL(p_object_id, cur_rst.tdev_object_id);
    -- Production day
    ld_daytime := EcDp_ProductionDay.getProductionDay('WELL',NVL(p_object_id, cur_rst.well_object_id), NVL(p_daytime, cur_rst.daytime),null);
    -- well object_id
    lv_well_object_id := cur_rst.well_object_id;
  END LOOP;
  -- get test_device_result row, it will be used several times in this function
  lr_eqrt := ec_test_device_result.row_by_pk(lv_object_id, p_result_no);
  ln_tdev_press := nvl(lr_eqrt.tdev_press, 0);
  ln_tdev_temp := nvl(lr_eqrt.tdev_temp, 0);
  -- determine shrinkage method
  lv_shrinkage_method := ec_test_device_version.shrinkage_method(lv_object_id, ld_daytime, '<=');
  --
  -- EQUATION as shrinkage method using constants from quality streams linked to reservoir zones
  --
  IF lv_shrinkage_method = 'EQUATION' THEN
    -- Check if the well has a direct link to one quality stream
    -- If it has a direct link, use it and do not loop through well perforations to find RBF quality streams
    lv_q_strm_object_id := ec_well_version.fluid_quality(lv_well_object_id, ld_daytime, '<=');
    -- If quality stream is NULL, then we have to loop all RBF zones the well is producing from and calculate average constants based on quality streams for RBF.
    IF lv_q_strm_object_id IS NULL THEN
      -- set all constants to 0 before entering into loop to calculcate weighted average
      -- Oil Shrinkage constants
      ln_osr_const_1 := 0;
      ln_osr_const_press_1 := 0;
      ln_osr_const_press_2 := 0;
      ln_osr_const_press_3 := 0;
      ln_osr_const_press_4 := 0;
      ln_osr_const_press_5 := 0;
      ln_osr_const_press_6 := 0;
      ln_osr_const_temp_1 := 0;
      ln_osr_const_temp_2 := 0;
      ln_osr_const_temp_3 := 0;
      ln_osr_const_temp_4 := 0;
      -- Gas Shrinkage constants
      ln_gsr_const_1 := 0;
      ln_gsr_const_press_1 := 0;
      ln_gsr_const_press_2 := 0;
      ln_gsr_const_press_3 := 0;
      ln_gsr_const_press_4 := 0;
      ln_gsr_const_press_5 := 0;
      ln_gsr_const_press_6 := 0;
      ln_gsr_const_temp_1 := 0;
      ln_gsr_const_temp_2 := 0;
      ln_gsr_const_temp_3 := 0;
      ln_gsr_const_temp_4 := 0;
      -- Gas in Solution constants
      ln_gis_const_1 := 0;
      ln_gis_const_press_1 := 0;
      ln_gis_const_press_2 := 0;
      ln_gis_const_press_3 := 0;
      ln_gis_const_press_4 := 0;
      ln_gis_const_press_5 := 0;
      ln_gis_const_press_6 := 0;
      ln_gis_const_temp_1 := 0;
      ln_gis_const_temp_2 := 0;
      ln_gis_const_temp_3 := 0;
      ln_gis_const_temp_4 := 0;

      -- loop all perforations and calculate total perforation contribution weighted factors.
      FOR mycur IN c_quality_streams(lv_well_object_id, ld_daytime) LOOP
         -- get reference values for the quality stream for this perforation interval
         lr_strv := ec_strm_reference_value.row_by_pk(mycur.quality_stream_id, ld_daytime, '<=');
         -- the resv_block_form_factor will add up to 1 for all records in the loop.
         -- Oil Shrinkage constants
         ln_osr_const_1 := ln_osr_const_1 + nvl(lr_strv.osr_const_1 * mycur.resv_block_form_factor, 0);
         ln_osr_const_press_1 := ln_osr_const_press_1 + nvl(lr_strv.osr_const_press_1 * mycur.resv_block_form_factor, 0);
         ln_osr_const_press_2 := ln_osr_const_press_2 + nvl(lr_strv.osr_const_press_2 * mycur.resv_block_form_factor, 0);
         ln_osr_const_press_3 := ln_osr_const_press_3 + nvl(lr_strv.osr_const_press_3 * mycur.resv_block_form_factor, 0);
         ln_osr_const_press_4 := ln_osr_const_press_4 + nvl(lr_strv.osr_const_press_4 * mycur.resv_block_form_factor, 0);
         ln_osr_const_press_5 := ln_osr_const_press_5 + nvl(lr_strv.osr_const_press_5 * mycur.resv_block_form_factor, 0);
         ln_osr_const_press_6 := ln_osr_const_press_6 + nvl(lr_strv.osr_const_press_6 * mycur.resv_block_form_factor, 0);
         ln_osr_const_temp_1 := ln_osr_const_temp_1 + nvl(lr_strv.osr_const_temp_1 * mycur.resv_block_form_factor,0);
         ln_osr_const_temp_2 := ln_osr_const_temp_2 + nvl(lr_strv.osr_const_temp_2 * mycur.resv_block_form_factor,0);
         ln_osr_const_temp_3 := ln_osr_const_temp_3 + nvl(lr_strv.osr_const_temp_3 * mycur.resv_block_form_factor,0);
         ln_osr_const_temp_4 := ln_osr_const_temp_4 + nvl(lr_strv.osr_const_temp_4 * mycur.resv_block_form_factor,0);
         -- Gas Shrinkage constants
         ln_gsr_const_1 := ln_gsr_const_1 + nvl(lr_strv.gsr_const_1 * mycur.resv_block_form_factor, 0);
         ln_gsr_const_press_1 := ln_gsr_const_press_1 + nvl(lr_strv.gsr_const_press_1 * mycur.resv_block_form_factor, 0);
         ln_gsr_const_press_2 := ln_gsr_const_press_2 + nvl(lr_strv.gsr_const_press_2 * mycur.resv_block_form_factor, 0);
         ln_gsr_const_press_3 := ln_gsr_const_press_3 + nvl(lr_strv.gsr_const_press_3 * mycur.resv_block_form_factor, 0);
         ln_gsr_const_press_4 := ln_gsr_const_press_4 + nvl(lr_strv.gsr_const_press_4 * mycur.resv_block_form_factor, 0);
         ln_gsr_const_press_5 := ln_gsr_const_press_5 + nvl(lr_strv.gsr_const_press_5 * mycur.resv_block_form_factor, 0);
         ln_gsr_const_press_6 := ln_gsr_const_press_6 + nvl(lr_strv.gsr_const_press_6 * mycur.resv_block_form_factor, 0);
         ln_gsr_const_temp_1 := ln_gsr_const_temp_1 + nvl(lr_strv.gsr_const_temp_1 * mycur.resv_block_form_factor, 0);
         ln_gsr_const_temp_2 := ln_gsr_const_temp_2 + nvl(lr_strv.gsr_const_temp_2 * mycur.resv_block_form_factor, 0);
         ln_gsr_const_temp_3 := ln_gsr_const_temp_3 + nvl(lr_strv.gsr_const_temp_3 * mycur.resv_block_form_factor, 0);
         ln_gsr_const_temp_4 := ln_gsr_const_temp_4 + nvl(lr_strv.gsr_const_temp_4 * mycur.resv_block_form_factor, 0);
         -- Gas in Solution constants
         ln_gis_const_1 := ln_gis_const_1 + nvl(lr_strv.gis_const_1 * mycur.resv_block_form_factor, 0);
         ln_gis_const_press_1 := ln_gis_const_press_1 + nvl(lr_strv.gis_const_press_1 * mycur.resv_block_form_factor, 0);
         ln_gis_const_press_2 := ln_gis_const_press_2 + nvl(lr_strv.gis_const_press_2 * mycur.resv_block_form_factor, 0);
         ln_gis_const_press_3 := ln_gis_const_press_3 + nvl(lr_strv.gis_const_press_3 * mycur.resv_block_form_factor, 0);
         ln_gis_const_press_4 := ln_gis_const_press_4 + nvl(lr_strv.gis_const_press_4 * mycur.resv_block_form_factor, 0);
         ln_gis_const_press_5 := ln_gis_const_press_5 + nvl(lr_strv.gis_const_press_5 * mycur.resv_block_form_factor, 0);
         ln_gis_const_press_6 := ln_gis_const_press_6 + nvl(lr_strv.gis_const_press_6 * mycur.resv_block_form_factor, 0);
         ln_gis_const_temp_1 := ln_gis_const_temp_1 + nvl(lr_strv.gis_const_temp_1 * mycur.resv_block_form_factor, 0);
         ln_gis_const_temp_2 := ln_gis_const_temp_2 + nvl(lr_strv.gis_const_temp_2 * mycur.resv_block_form_factor, 0);
         ln_gis_const_temp_3 := ln_gis_const_temp_3 + nvl(lr_strv.gis_const_temp_3 * mycur.resv_block_form_factor, 0);
         ln_gis_const_temp_4 := ln_gis_const_temp_4 + nvl(lr_strv.gis_const_temp_4 * mycur.resv_block_form_factor, 0);
      END LOOP;
    -- the well itself has a reference to a quality stream, the use this only
    ELSE
      lr_strv := ec_strm_reference_value.row_by_pk(lv_q_strm_object_id, ld_daytime, '<=');
      -- Oil Shrinkage constants
      ln_osr_const_1 := nvl(lr_strv.osr_const_1, 0);
      ln_osr_const_press_1 := nvl(lr_strv.osr_const_press_1, 0);
      ln_osr_const_press_2 := nvl(lr_strv.osr_const_press_2, 0);
      ln_osr_const_press_3 := nvl(lr_strv.osr_const_press_3, 0);
      ln_osr_const_press_4 := nvl(lr_strv.osr_const_press_4, 0);
      ln_osr_const_press_5 := nvl(lr_strv.osr_const_press_5, 0);
      ln_osr_const_press_6 := nvl(lr_strv.osr_const_press_6, 0);
      ln_osr_const_temp_1 := nvl(lr_strv.osr_const_temp_1,0);
      ln_osr_const_temp_2 := nvl(lr_strv.osr_const_temp_2,0);
      ln_osr_const_temp_3 := nvl(lr_strv.osr_const_temp_3,0);
      ln_osr_const_temp_4 := nvl(lr_strv.osr_const_temp_4,0);
      -- Gas Shrinkage constants
      ln_gsr_const_1 := nvl(lr_strv.gsr_const_1, 0);
      ln_gsr_const_press_1 := nvl(lr_strv.gsr_const_press_1, 0);
      ln_gsr_const_press_2 := nvl(lr_strv.gsr_const_press_2, 0);
      ln_gsr_const_press_3 := nvl(lr_strv.gsr_const_press_3, 0);
      ln_gsr_const_press_4 := nvl(lr_strv.gsr_const_press_4, 0);
      ln_gsr_const_press_5 := nvl(lr_strv.gsr_const_press_5, 0);
      ln_gsr_const_press_6 := nvl(lr_strv.gsr_const_press_6, 0);
      ln_gsr_const_temp_1 := nvl(lr_strv.gsr_const_temp_1, 0);
      ln_gsr_const_temp_2 := nvl(lr_strv.gsr_const_temp_2, 0);
      ln_gsr_const_temp_3 := nvl(lr_strv.gsr_const_temp_3, 0);
      ln_gsr_const_temp_4 := nvl(lr_strv.gsr_const_temp_4, 0);
      -- Gas in Solution constants
      ln_gis_const_1 := nvl(lr_strv.gis_const_1, 0);
      ln_gis_const_press_1 := nvl(lr_strv.gis_const_press_1, 0);
      ln_gis_const_press_2 := nvl(lr_strv.gis_const_press_2, 0);
      ln_gis_const_press_3 := nvl(lr_strv.gis_const_press_3, 0);
      ln_gis_const_press_4 := nvl(lr_strv.gis_const_press_4, 0);
      ln_gis_const_press_5 := nvl(lr_strv.gis_const_press_5, 0);
      ln_gis_const_press_6 := nvl(lr_strv.gis_const_press_6, 0);
      ln_gis_const_temp_1 := nvl(lr_strv.gis_const_temp_1, 0);
      ln_gis_const_temp_2 := nvl(lr_strv.gis_const_temp_2, 0);
      ln_gis_const_temp_3 := nvl(lr_strv.gis_const_temp_3, 0);
      ln_gis_const_temp_4 := nvl(lr_strv.gis_const_temp_4, 0);
    END IF;

    --if tdev_press and tdev_temp is null, ln_result := NULL
    IF ln_tdev_press IS NULL AND ln_tdev_temp IS NULL THEN
	  	ln_result := NULL;
    ELSE
		  --check from system attribute on which formula to use : PT.0013 or PT.0010
		  lv2_formula := ec_ctrl_system_attribute.attribute_text(ld_daytime, 'PT.0013_FORMULA', '<=');
      IF p_phase = Ecdp_Phase.OIL OR p_phase = Ecdp_Phase.CONDENSATE THEN
  		  IF lv2_formula IS NULL OR lv2_formula = 'PT.0013' THEN
		  	  -- use fromula PT.0013
		      BEGIN
		        ln_oil_shrinkage_factor := ((ln_osr_const_1 * (power(ln_tdev_press, ln_osr_const_press_1)) * (power(ln_tdev_temp, ln_osr_const_temp_1))) +
		                                   (ln_osr_const_press_2 * power(ln_tdev_press, ln_osr_const_press_3)) +
		                                   (ln_osr_const_press_4 * power(ln_tdev_press, ln_osr_const_press_5)) +
		                                   (ln_osr_const_temp_2 * power(ln_tdev_temp, ln_osr_const_temp_3)));

		        ln_result := nvl(p_net_rate, 0) * nvl(ln_oil_shrinkage_factor, 0);
		      EXCEPTION
		        WHEN OTHERS THEN -- trapping numeric overflow exception
		          ln_result := NULL;
		      END;
	      ELSIF lv2_formula = 'PT.0010' THEN
	      	  --use formula PT.0010
		      BEGIN
		        ln_oil_shrinkage_factor := ((ln_osr_const_press_1 * POWER(ln_tdev_press, ln_osr_const_press_2)) +
		                                    (ln_osr_const_press_3 * POWER(ln_tdev_press, ln_osr_const_press_4)) +
		                                    (ln_osr_const_press_5 / POWER(ln_tdev_press, ln_osr_const_press_6)) +
		                                    (ln_osr_const_temp_1 * POWER(ln_tdev_temp, ln_osr_const_temp_2)) +
		                                    (ln_osr_const_temp_3 * POWER(ln_tdev_temp, ln_osr_const_temp_4)) +
		                                    ln_osr_const_1);

		        ln_result := nvl(p_net_rate, 0) * nvl(ln_oil_shrinkage_factor, 0);
			    EXCEPTION
		        WHEN OTHERS THEN -- trapping numeric overflow exception
		          ln_result := NULL;
			    END;
		    END IF;
      ELSIF p_phase = Ecdp_Phase.GAS THEN
			  IF lv2_formula IS NULL OR lv2_formula = 'PT.0013' THEN
			  -- use fromula PT.0013
		      BEGIN
		        ln_gas_shrinkage_factor := ((ln_gsr_const_1 * power(ln_tdev_press, ln_gsr_const_press_1) * power(ln_tdev_temp, ln_gsr_const_temp_1)) +
		                                   (ln_gsr_const_press_2 * power(ln_tdev_press, ln_gsr_const_press_3)) +
		                                   (ln_gsr_const_press_4 * power(ln_tdev_press, ln_gsr_const_press_5)) +
		                                   (ln_gsr_const_temp_2 * power(ln_tdev_temp, ln_gsr_const_temp_3)));

		        ln_gas_in_solution := ((ln_gis_const_1 * power(ln_tdev_press, ln_gis_const_press_1) * power(ln_tdev_temp, ln_gis_const_temp_1)) +
		                              (ln_gis_const_press_2 * power(ln_tdev_press, ln_gis_const_press_3)) +
		                              (ln_gis_const_press_4 * power(ln_tdev_press, ln_gis_const_press_5)) +
		                              (ln_gis_const_temp_2 * power(ln_tdev_temp, ln_gis_const_temp_3)));

		        ln_result := nvl(p_net_rate, 0) * nvl(ln_gas_shrinkage_factor, 1) + nvl(findStdNetRate(p_result_no, Ecdp_Phase.OIL, lv_object_id, ld_daytime), 0) * nvl(ln_gas_in_solution, 0);

          EXCEPTION
            WHEN OTHERS THEN -- trapping numeric overflow exception
              ln_result := NULL;
          END;
        ELSIF lv2_formula = 'PT.0010' THEN
            --use formula PT.0010
          BEGIN
            ln_gas_shrinkage_factor := ((ln_gsr_const_press_1 * POWER(ln_tdev_press, ln_gsr_const_press_2)) +
                                        (ln_gsr_const_press_3 * POWER(ln_tdev_press, ln_gsr_const_press_4)) +
                                        (ln_gsr_const_press_5 / POWER(ln_tdev_press, ln_gsr_const_press_6)) +
                                        (ln_gsr_const_temp_1 * POWER(ln_tdev_temp, ln_gsr_const_temp_2)) +
                                        (ln_gsr_const_temp_3 * POWER(ln_tdev_temp, ln_gsr_const_temp_4)) +
                                        ln_gsr_const_1);

            ln_gas_in_solution := ((ln_gis_const_press_1 * POWER(ln_tdev_press, ln_gis_const_press_2)) +
                                     (ln_gis_const_press_3 * POWER(ln_tdev_press, ln_gis_const_press_4)) +
                                     (ln_gis_const_press_5 / POWER(ln_tdev_press, ln_gis_const_press_6)) +
                                     (ln_gis_const_temp_1 * POWER(ln_tdev_temp, ln_gis_const_temp_2)) +
                                     (ln_gis_const_temp_3 * POWER(ln_tdev_temp, ln_gis_const_temp_4)) +
                                     ln_gis_const_1);

            ln_result := nvl(p_net_rate, 0) * nvl(ln_gas_shrinkage_factor, 1) + nvl(findStdNetRate(p_result_no, Ecdp_Phase.OIL, lv_object_id, ld_daytime), 0) * nvl(ln_gas_in_solution, 0);

        EXCEPTION
            WHEN OTHERS THEN -- trapping numeric overflow exception
              ln_result := NULL;
        END;
      END IF;

      ELSIF p_phase = Ecdp_Phase.WATER THEN
	      ln_result := p_net_rate;       -- no shrinkage for WATER in this case
	    END IF;
    END IF;
  --
  -- TABLE_LOOKUP method will use Test Device Temperature and Pressure and Density if not null to find shrinkage factors Bo, Bg, Bw and Rs
  --
  ELSIF lv_shrinkage_method = 'TABLE_LOOKUP' THEN
    IF lv_well_object_id IS NULL THEN -- well object_id hasn't been fecthed yet
      FOR cur_rst IN c_result(p_result_no) LOOP
        lv_well_object_id := cur_rst.well_object_id;
      END LOOP;
    END IF;

    -- get Quality stream
    -- table lookup assumes that we have only one Quality stream configured at the stream level. No resv block formation quality streams supported yet.
    lv_q_strm_object_id := Ecdp_Well_Reservoir.getRefQualityStream(lv_well_object_id, 'RES', ld_daytime);
    -- lr_eqrt variable is already fetch in the beginning, it holds the test_device_result record.
    -- get temp and press from test device result row
    -- get test_device_result and pwel_result row

    ln_pwr_temp := lr_eqrt.tdev_temp;
    ln_pwr_press := lr_eqrt.tdev_press;
    -- get density from test device result row
    IF p_phase = Ecdp_Phase.OIL THEN
      ln_tdev_density := lr_eqrt.net_oil_density_flc;
    ELSIF p_phase = Ecdp_Phase.CONDENSATE THEN
      ln_tdev_density := lr_eqrt.net_cond_density_flc;
    ELSIF p_phase = Ecdp_Phase.GAS THEN
      ln_tdev_density := lr_eqrt.gas_density_flc;
    ELSIF p_phase = Ecdp_Phase.WATER THEN
      ln_tdev_density := lr_eqrt.tot_water_density_flc;
    END IF;

    -- get lookup inverted shrinkage factors
    lr_sdpt := findInvertedShrinkageFactors(lv_q_strm_object_id,p_daytime,ln_tdev_density,ln_pwr_press,ln_pwr_temp);

    IF p_phase = Ecdp_Phase.OIL OR p_phase = Ecdp_Phase.CONDENSATE THEN
      IF lr_sdpt.Bo > 0 THEN
         ln_result:= p_net_rate / lr_sdpt.Bo;
      END IF;

    ELSIF p_phase = Ecdp_Phase.GAS THEN
      IF lr_sdpt.Bg > 0 THEN
          IF ec_well_version.isOilProducer(lv_well_object_id,ld_daytime,'<=') = ECDP_TYPE.IS_TRUE THEN
             ln_result:= (p_net_rate / lr_sdpt.Bg) + (findStdNetRate(p_result_no,Ecdp_Phase.OIL,p_object_id,p_daytime) * nvl(lr_sdpt.Rs,0));

          ELSIF ec_well_version.isGasProducer(lv_well_object_id,ld_daytime,'<=') = ECDP_TYPE.IS_TRUE
             OR ec_well_version.isCondensateProducer(lv_well_object_id,ld_daytime,'<=') = ECDP_TYPE.IS_TRUE THEN
             ln_result:= (p_net_rate / lr_sdpt.Bg) + (findStdNetRate(p_result_no,Ecdp_Phase.CONDENSATE,p_object_id,p_daytime) * nvl(lr_sdpt.Rs,0));
          END IF;
      END IF;

    ELSIF p_phase = Ecdp_Phase.WATER THEN
      IF lr_sdpt.Bw > 0 THEN
         ln_result:= p_net_rate / lr_sdpt.Bw;
      END IF;

    ELSE
      ln_result := NULL;
    END IF;
  --
  -- TDEV_FACTOR method looks up factors from test_device reference values
  --
  ELSIF lv_shrinkage_method = 'TDEV_FACTOR' THEN
    IF p_phase IN (Ecdp_Phase.OIL, Ecdp_Phase.CONDENSATE) THEN
      ln_result := nvl(p_net_rate, 0) * nvl(lr_eqrt.oil_shrinkage_override, ec_tdev_reference_value.oil_shrinkage_factor(lv_object_id, ld_daytime, '<='));

    ELSIF p_phase = Ecdp_Phase.GAS THEN
      ln_result := nvl(p_net_rate, 0) * nvl(lr_eqrt.gas_shrinkage_override, ec_tdev_reference_value.gas_shrinkage_factor(lv_object_id, ld_daytime, '<='))
                   + nvl(findStdNetRate(p_result_no, Ecdp_Phase.OIL, lv_object_id, ld_daytime), 0) * nvl(ec_tdev_reference_value.gas_in_solution(lv_object_id, ld_daytime, '<='),0);

    ELSIF p_phase = Ecdp_Phase.WATER THEN
      ln_result := p_net_rate;
    END IF;
  --
  -- WELL_FACTOR method looks up factors from well reference vaules
  --
  ELSIF lv_shrinkage_method = 'WELL_FACTOR' THEN
    IF lv_well_object_id IS NULL THEN -- well object_id hasn't been fecthed yet
      FOR cur_rst IN c_result(p_result_no) LOOP
        lv_well_object_id := cur_rst.well_object_id;
      END LOOP;
    END IF;

    IF p_phase IN (Ecdp_Phase.OIL, Ecdp_Phase.CONDENSATE) THEN
      ln_result := nvl(p_net_rate, 0) * nvl(lr_eqrt.oil_shrinkage_override, ec_well_reference_value.wt_oil_shrinkage(lv_well_object_id, ld_daytime, '<='));

    ELSIF p_phase = Ecdp_Phase.GAS THEN
      ln_result := nvl(p_net_rate, 0) * nvl(lr_eqrt.gas_shrinkage_override, ec_well_reference_value.wt_gas_shrinkage(lv_well_object_id, ld_daytime, '<='))
                   + nvl(findStdNetRate(p_result_no, Ecdp_Phase.OIL, lv_object_id, ld_daytime), 0) * nvl(ec_well_reference_value.wt_gas_in_solution(lv_well_object_id, ld_daytime, '<='),0);

    ELSIF p_phase = Ecdp_Phase.WATER THEN
      ln_result := p_net_rate;
    END IF;
  --
  -- WELL_TDEV_FACTOR method tries to find well reference values and if null lookup up test device reference values
  --
  ELSIF lv_shrinkage_method = 'WELL_TDEV_FACTOR' THEN
    IF lv_well_object_id IS NULL THEN -- well object_id hasn't been fecthed yet
      FOR cur_rst IN c_result(p_result_no) LOOP
        lv_well_object_id := cur_rst.well_object_id;
      END LOOP;
    END IF;

    IF p_phase IN (Ecdp_Phase.OIL, Ecdp_Phase.CONDENSATE) THEN
      ln_result := nvl(p_net_rate, 0) * nvl(lr_eqrt.oil_shrinkage_override, ec_well_reference_value.wt_oil_shrinkage(lv_well_object_id, ld_daytime, '<='));

    ELSIF p_phase = Ecdp_Phase.GAS THEN
      ln_result := nvl(p_net_rate, 0) * nvl(lr_eqrt.gas_shrinkage_override, ec_well_reference_value.wt_gas_shrinkage(lv_well_object_id, ld_daytime, '<='))
                   + nvl(findStdNetRate(p_result_no, Ecdp_Phase.OIL, lv_object_id, ld_daytime), 0) * nvl(ec_well_reference_value.wt_gas_in_solution(lv_well_object_id, ld_daytime, '<='),0);

    ELSIF p_phase = Ecdp_Phase.WATER THEN
      ln_result := p_net_rate;
    END IF;

    IF ln_result IS NULL then
      IF p_phase IN (Ecdp_Phase.OIL, Ecdp_Phase.CONDENSATE) THEN
        ln_result := nvl(p_net_rate, 0) * nvl(lr_eqrt.oil_shrinkage_override, ec_tdev_reference_value.oil_shrinkage_factor(lv_object_id, ld_daytime, '<='));

      ELSIF p_phase = Ecdp_Phase.GAS THEN
        ln_result := nvl(p_net_rate, 0) * nvl(lr_eqrt.gas_shrinkage_override, ec_tdev_reference_value.gas_shrinkage_factor(lv_object_id, ld_daytime, '<='))
                   + nvl(findStdNetRate(p_result_no, Ecdp_Phase.OIL, lv_object_id, ld_daytime), 0) * nvl(ec_tdev_reference_value.gas_in_solution(lv_object_id, ld_daytime, '<='),0);

      ELSIF p_phase = Ecdp_Phase.WATER THEN
        ln_result := p_net_rate;
      END IF;
    END IF;
  --
  -- NO_SHRINKAGE method simply return the same volume, no shrinakge applied
  --
  ELSIF lv_shrinkage_method = 'NO_SHRINKAGE' THEN
    ln_result := p_net_rate;
  --
  --  MEASURED method uses the stored factor on test device record
  --
  ELSIF lv_shrinkage_method = 'MEASURED' THEN
    IF p_phase IN (Ecdp_Phase.OIL, Ecdp_Phase.CONDENSATE) THEN
      ln_result := nvl(p_net_rate, 0) * nvl(lr_eqrt.oil_shrinkage_override, 1);
    ELSIF p_phase = Ecdp_Phase.GAS THEN
      ln_result := (nvl(p_net_rate, 0) * nvl(lr_eqrt.gas_shrinkage_override,1)) +  (nvl(findNetRate(p_result_no, Ecdp_Phase.OIL, lv_object_id, ld_daytime), 0) * nvl(lr_eqrt.gas_flash_factor, 0));
    ELSIF p_phase = Ecdp_Phase.WATER THEN
      ln_result := p_net_rate;
    END IF;
  --
  -- USER_EXIT
  --
  ELSIF (substr(lv_shrinkage_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
    ln_result := Ue_TestDevice.calcShrinkageVolume(p_result_no, p_net_rate, p_phase, lv_object_id, ld_daytime);
  END IF;

  RETURN ln_result;

END calcShrinkageVolume;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcTotalizerVolume
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcTotalizerVolume(p_result_no NUMBER, p_phase VARCHAR2, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS
  ln_retvalue                     NUMBER;
  lv_object_id                    VARCHAR2(32);
  ld_daytime                      DATE;

  ln_totalizer_close              NUMBER;
  ln_totalizer_open               NUMBER;
  ln_rollover_value               NUMBER;
  ln_conversion_factor            NUMBER;
  ln_meter_factor                 NUMBER;
  ln_meter_factor_ovr             NUMBER;
  ln_shrinkage_factor             NUMBER;
  ln_shrinkage_factor_ovr         NUMBER;
  ln_vcf                          NUMBER;
  ln_bsw                          NUMBER;
  ln_adj_vol                      NUMBER;

  lr_eqrt                         test_device_result%ROWTYPE;
  lr_tdrv                         TDEV_REFERENCE_VALUE%ROWTYPE;

BEGIN

  IF p_object_id IS NULL OR p_daytime IS NULL THEN
    -- find object_id and daytime
    FOR cur_rst IN c_result(p_result_no) LOOP
      lv_object_id := cur_rst.tdev_object_id;
      ld_daytime := cur_rst.daytime;
    END LOOP;
  ELSE
    lv_object_id := p_object_id;
    ld_daytime := p_daytime;
  END IF;

  -- get test_device_result row
  lr_eqrt := ec_test_device_result.row_by_pk(lv_object_id,p_result_no);

  -- get tdev_ref_values row
  lr_tdrv := ec_tdev_reference_value.row_by_pk(lv_object_id,ld_daytime,'<=');

  -- assign values to local variables (by phase)
  IF p_phase = Ecdp_Phase.OIL OR p_phase = Ecdp_Phase.CONDENSATE THEN -- LIQUID
    ln_totalizer_close := lr_eqrt.liquid_closing_reading;
    ln_totalizer_open := lr_eqrt.liquid_opening_reading;
    ln_rollover_value := lr_tdrv.oil_totalizer_max;
    ln_conversion_factor := lr_tdrv.oil_conv_factor;
    ln_meter_factor := lr_tdrv.oil_meter_factor;
    ln_meter_factor_ovr := lr_eqrt.override_oil_mtr_factor;
    ln_shrinkage_factor := lr_tdrv.oil_shrinkage_factor;
    ln_shrinkage_factor_ovr := lr_eqrt.oil_shrinkage_override;
    ln_adj_vol      :=  lr_eqrt.liquid_adjust_volume;
    ln_vcf := lr_eqrt.vcf;
    ln_bsw := NVL(findBswVol(p_result_no, p_object_id, p_daytime),0);

  ELSIF p_phase = Ecdp_Phase.WATER THEN
    ln_totalizer_close := lr_eqrt.water_closing_reading;
    ln_totalizer_open := lr_eqrt.water_opening_reading;
    ln_rollover_value := lr_tdrv.wat_totalizer_max;
    ln_conversion_factor := lr_tdrv.wat_conv_factor;
    ln_meter_factor := lr_tdrv.water_meter_factor;
    ln_meter_factor_ovr := lr_eqrt.override_wat_mtr_factor;
    ln_shrinkage_factor := 1;      -- no shrinkage for WATER
    ln_shrinkage_factor_ovr := 1;  -- no shrinkage for WATER
    ln_adj_vol     :=  lr_eqrt.water_adjust_volume;

  ELSE
    RETURN NULL;
  END IF;

  IF ln_totalizer_close < ln_totalizer_open THEN
    ln_retvalue :=
                ((ln_totalizer_close - nvl(ln_totalizer_open, 0) + nvl(ln_rollover_value, 0))
                * nvl(ln_conversion_factor, 1)
                * nvl(ln_meter_factor, nvl(ln_meter_factor_ovr, 1))
                * nvl(ln_shrinkage_factor, nvl(ln_shrinkage_factor_ovr, 1))
                * nvl(ln_vcf, 1)) +  nvl(ln_adj_vol, 0);
  ELSE
    ln_retvalue :=
                ((ln_totalizer_close - nvl(ln_totalizer_open, 0))
                * nvl(ln_conversion_factor, 1)
                * nvl(ln_meter_factor, nvl(ln_meter_factor_ovr, 1))
                * nvl(ln_shrinkage_factor, nvl(ln_shrinkage_factor_ovr, 1))
                * nvl(ln_vcf, 1)) +  nvl(ln_adj_vol, 0);
  END IF;

  ln_retvalue := ln_retvalue * (1-NVL(ln_bsw, 0));
  RETURN ln_retvalue;
END calcTotalizerVolume;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSingleWellTestResult
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE calcSingleWellTestResult(p_well_object_id VARCHAR2, p_daytime DATE, p_result_no NUMBER, p_user VARCHAR2)
--</EC-DOC>
IS
  lv_tdev_obj_id              VARCHAR2(32);
  lv_record_status            VARCHAR2(1);
  ln_rev_no                   NUMBER;

  -- parameters
  ln_net_oil_rate_adj         NUMBER;
  ln_net_cond_rate_adj        NUMBER;
  ln_gas_rate_adj             NUMBER;
  ln_tot_water_rate_adj       NUMBER;
  ln_gl_rate                  NUMBER;
  ln_gor                      NUMBER;
  ln_glr                      NUMBER;
  ln_water_cut                NUMBER;
  ln_cgr                      NUMBER;
  ln_wgr                      NUMBER;
  ln_wet_dry_gas_ratio        NUMBER;
  ln_wet_gas_grav             NUMBER;
  ln_gas_sp_grav              NUMBER;
  ln_dry_wet_gas_ratio        NUMBER;

  lv_code_exist               VARCHAR2(32);
  ln_net_oil_mass_rate_adj    NUMBER;
  ln_net_cond_mass_rate_adj   NUMBER;
  ln_diluent_rate             NUMBER;
  ln_wor                      NUMBER;
  ln_fws_rate                 NUMBER;

BEGIN

  Ue_TestDevice.calcSingleWellTestResult(p_well_object_id, p_daytime, p_result_no, p_user, lv_code_exist);

  IF lv_code_exist <> 'Y' THEN

    -- get test_device object_id
    FOR cr IN c_result(p_result_no) LOOP
      lv_tdev_obj_id := cr.tdev_object_id;
	  lv_record_status := cr.record_status;
      ln_rev_no := cr.rev_no;
    END LOOP;

	ln_rev_no := getJournalRevNo('PWEL_RESULT',lv_record_status,ln_rev_no);

    IF ec_well_version.isOilProducer(p_well_object_id, p_daytime,'<=') = ECDP_TYPE.IS_TRUE THEN

      ln_net_oil_rate_adj := findStdNetRate(p_result_no, Ecdp_Phase.OIL, lv_tdev_obj_id, p_daytime);
      ln_gas_rate_adj := findStdNetRate(p_result_no, Ecdp_Phase.GAS, lv_tdev_obj_id, p_daytime);
      ln_tot_water_rate_adj := findStdNetRate(p_result_no, Ecdp_Phase.WATER, lv_tdev_obj_id, p_daytime);
      ln_gl_rate := findGrsGasLiftRate(p_result_no, lv_tdev_obj_id, p_daytime);
      ln_gor := findGOR(p_result_no, lv_tdev_obj_id, p_daytime);
      ln_glr := findGLR(p_result_no, lv_tdev_obj_id, p_daytime);
      ln_water_cut := calcWaterCut(p_result_no, NULL, ec_ptst_result.daytime(p_result_no));
      ln_net_oil_mass_rate_adj := findNetRate(p_result_no, Ecdp_Phase.OIL, lv_tdev_obj_id, ec_ptst_result.daytime(p_result_no)) * ec_test_device_result.Net_oil_density_flc(lv_tdev_obj_id, p_result_no);
      ln_diluent_rate := findDiluentRate(p_result_no, lv_tdev_obj_id, p_daytime);
      ln_wor := findWOR(p_result_no, lv_tdev_obj_id, p_daytime);

      IF ln_net_oil_rate_adj IS NOT NULL AND
         ln_gas_rate_adj IS NOT NULL AND
         ln_tot_water_rate_adj IS NOT NULL THEN

        UPDATE pwel_result pr
        SET
          pr.net_oil_rate_adj = ln_net_oil_rate_adj,
          pr.gas_rate_adj = ln_gas_rate_adj,
          pr.tot_water_rate_adj = ln_tot_water_rate_adj,
          pr.gl_rate = ln_gl_rate,
          pr.gor = ln_gor,
          pr.wor = ln_wor,
          pr.glr = ln_glr,
          pr.watercut_pct = ln_water_cut*100,
          pr.net_oil_mass_rate_adj = ln_net_oil_mass_rate_adj,
          pr.diluent_rate = nvl(ln_diluent_rate, pr.diluent_rate),
          pr.last_updated_by =  Nvl(p_user, ecdp_context.getAppUser()),
		  pr.rev_no = ln_rev_no
        WHERE
          pr.object_id = p_well_object_id AND pr.result_no = p_result_no;
      ELSE
           RAISE_APPLICATION_ERROR(-20547,'Cannot update test, Net results of oil, gas or water IS NULL.');
      END IF;

    ELSIF ec_well_version.isGasProducer(p_well_object_id, p_daytime,'<=') = ECDP_TYPE.IS_TRUE THEN
      ln_net_cond_rate_adj := findStdNetRate(p_result_no, Ecdp_Phase.CONDENSATE, lv_tdev_obj_id, p_daytime);
      ln_gas_rate_adj := findStdNetRate(p_result_no, Ecdp_Phase.GAS, lv_tdev_obj_id, p_daytime);
      ln_tot_water_rate_adj := findStdNetRate(p_result_no, Ecdp_Phase.WATER, lv_tdev_obj_id, p_daytime);
      ln_gl_rate := findGrsGasLiftRate(p_result_no, lv_tdev_obj_id, p_daytime);
      ln_cgr := findCGR(p_result_no, lv_tdev_obj_id, p_daytime);
      ln_wgr := findWGR(p_result_no, lv_tdev_obj_id, p_daytime);
      ln_wet_dry_gas_ratio := findWetDryFactor(p_result_no, lv_tdev_obj_id, p_daytime);
      ln_wet_gas_grav := findWetGasGravity(p_result_no, lv_tdev_obj_id, p_daytime);
      ln_gas_sp_grav := ec_test_device_result.gas_sp_grav(lv_tdev_obj_id, p_result_no);
      ln_net_cond_mass_rate_adj := findNetRate(p_result_no, Ecdp_Phase.CONDENSATE, lv_tdev_obj_id, ec_ptst_result.daytime(p_result_no)) * ec_test_device_result.net_cond_density_flc(lv_tdev_obj_id, p_result_no);
      ln_fws_rate := findWellWetGasRate(p_result_no, lv_tdev_obj_id, p_daytime);
      ln_diluent_rate := findDiluentRate(p_result_no, lv_tdev_obj_id, p_daytime);

      IF (ln_wet_dry_gas_ratio = 0 OR ln_wet_dry_gas_ratio IS NULL) THEN
        ln_dry_wet_gas_ratio := null;
      ELSE
        ln_dry_wet_gas_ratio := 1 / ln_wet_dry_gas_ratio;
      END IF;

      IF ln_net_cond_rate_adj IS NOT NULL AND
         ln_gas_rate_adj IS NOT NULL AND
         ln_tot_water_rate_adj IS NOT NULL THEN

        UPDATE pwel_result pr
        SET
          pr.net_cond_rate_adj = ln_net_cond_rate_adj,
          pr.gas_rate_adj = ln_gas_rate_adj,
          pr.tot_water_rate_adj = ln_tot_water_rate_adj,
          pr.gl_rate = ln_gl_rate,
          pr.fws_rate = nvl(ln_fws_rate,pr.fws_rate),
          pr.cgr = ln_cgr,
          pr.wgr = ln_wgr,
          pr.wet_dry_gas_ratio = ln_wet_dry_gas_ratio,
          pr.dry_wet_gas_ratio = ln_dry_wet_gas_ratio,
          pr.wet_gas_gravity = ln_wet_gas_grav,
          pr.gas_sp_grav = ln_gas_sp_grav,
          pr.net_cond_mass_rate_adj = ln_net_cond_mass_rate_adj,
          pr.diluent_rate = nvl(ln_diluent_rate, pr.diluent_rate),
          pr.last_updated_by = Nvl(p_user, ecdp_context.getAppUser()),
		  pr.rev_no = ln_rev_no
        WHERE
          pr.object_id = p_well_object_id AND pr.result_no = p_result_no;

      ELSE
           RAISE_APPLICATION_ERROR(-20547,'Cannot update test, Net results of gas, condensate or water IS NULL.');
    END IF;

	ElSIF ec_well_version.isWaterProducer(p_well_object_id,p_daytime,'<=') = ECDP_TYPE.IS_TRUE THEN
      ln_tot_water_rate_adj := findStdNetRate(p_result_no, Ecdp_Phase.WATER, lv_tdev_obj_id, p_daytime);
      ln_gl_rate := findGrsGasLiftRate(p_result_no, lv_tdev_obj_id, p_daytime);

      IF ln_tot_water_rate_adj IS NOT NULL THEN

        UPDATE pwel_result pr
        SET
          pr.tot_water_rate_adj = ln_tot_water_rate_adj,
          pr.gl_rate = ln_gl_rate,
          pr.last_updated_by = Nvl(p_user, ecdp_context.getAppUser()),
		  pr.rev_no = ln_rev_no
        WHERE
          pr.object_id = p_well_object_id AND pr.result_no = p_result_no;

      ELSE
           RAISE_APPLICATION_ERROR(-20547,'Cannot update test, Net results of gas, condensate or water IS NULL.');
      END IF;
    END IF;

  ELSE
    NULL;

  END IF;
  IF ec_well_version.isOilProducer(p_well_object_id, p_daytime,'<=') = ECDP_TYPE.IS_TRUE THEN
       IF ln_net_oil_rate_adj IS NOT NULL AND
          ln_gas_rate_adj IS NOT NULL AND
          ln_tot_water_rate_adj IS NOT NULL THEN

          UPDATE pwel_result pw SET pw.rate_source = 'CALC', pw.last_updated_by = Nvl(p_user, ecdp_context.getAppUser())
          WHERE pw.object_id = p_well_object_id AND pw.result_no = p_result_no;
       END IF;

  ELSIF ec_well_version.isGasProducer(p_well_object_id, p_daytime,'<=') = ECDP_TYPE.IS_TRUE THEN
    IF ln_net_cond_rate_adj IS NOT NULL AND
          ln_gas_rate_adj IS NOT NULL AND
          ln_tot_water_rate_adj IS NOT NULL THEN

        UPDATE pwel_result pw SET pw.rate_source = 'CALC', pw.last_updated_by = Nvl(p_user, ecdp_context.getAppUser())
          WHERE pw.object_id = p_well_object_id AND pw.result_no = p_result_no;
    END IF;
  ElSIF ec_well_version.isWaterProducer(p_well_object_id,p_daytime,'<=') = ECDP_TYPE.IS_TRUE THEN
    IF ln_tot_water_rate_adj IS NOT NULL THEN

      UPDATE pwel_result pw SET pw.rate_source = 'CALC', pw.last_updated_by = Nvl(p_user, ecdp_context.getAppUser())
          WHERE pw.object_id = p_well_object_id AND pw.result_no = p_result_no;
    END IF;
      ELSE
     NULL;
  END IF;
END calcSingleWellTestResult;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findTdevMeterRun
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findTdevMeterRun(p_result_no NUMBER, p_phase VARCHAR2, p_object_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2
--</EC-DOC>

IS
  lv_object_id                    VARCHAR2(32);
  ld_daytime                      DATE;

  lv_meter_run_id                 VARCHAR2(32);

BEGIN
  IF p_object_id IS NULL OR p_daytime IS NULL THEN
    FOR cur_rst IN c_result(p_result_no) LOOP
      lv_object_id := cur_rst.tdev_object_id;
      ld_daytime := cur_rst.daytime;
    END LOOP;
  ELSE
    lv_object_id := p_object_id;
    ld_daytime := p_daytime;
  END IF;

  IF p_phase = 'GAS' THEN
    lv_meter_run_id := ec_test_device_result.ovr_gas_meter_run_id(lv_object_id, p_result_no);
    IF lv_meter_run_id IS NULL THEN
      lv_meter_run_id := ec_tdev_reference_value.meter_run_id(lv_object_id, ld_daytime, '<=');
    END IF;

  ELSIF p_phase = 'GAS_LIFT' THEN
    lv_meter_run_id := ec_test_device_result.ovr_gl_meter_run_id(lv_object_id, p_result_no);
    IF lv_meter_run_id IS NULL THEN
      lv_meter_run_id := ec_tdev_reference_value.gl_meter_run_id(lv_object_id, ld_daytime, '<=');
    END IF;

  ELSE
    lv_meter_run_id := NULL;
  END IF;

  RETURN lv_meter_run_id;
END  findTdevMeterRun;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findTdevOrificePlate
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findTdevOrificePlate(p_result_no NUMBER, p_phase VARCHAR2, p_object_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2
--</EC-DOC>

IS
  lv_object_id                    VARCHAR2(32);
  ld_daytime                      DATE;

  lv_orifice_plate_id             VARCHAR2(32);
BEGIN
  IF p_object_id IS NULL OR p_daytime IS NULL THEN
    FOR cur_rst IN c_result(p_result_no) LOOP
      lv_object_id := cur_rst.tdev_object_id;
      ld_daytime := cur_rst.daytime;
    END LOOP;
  ELSE
    lv_object_id := p_object_id;
    ld_daytime := p_daytime;
  END IF;

  IF p_phase = 'GAS' THEN
    lv_orifice_plate_id := ec_test_device_result.ovr_gas_orifice_plate_id(lv_object_id, p_result_no);
    IF lv_orifice_plate_id IS NULL THEN
      lv_orifice_plate_id := ec_tdev_reference_value.orifice_plate_id(lv_object_id, ld_daytime, '<=');
    END IF;

  ELSIF p_phase = 'GAS_LIFT' THEN
    lv_orifice_plate_id := ec_test_device_result.ovr_gl_orifice_plate_id(lv_object_id,p_result_no);
    IF lv_orifice_plate_id IS NULL THEN
      lv_orifice_plate_id := ec_tdev_reference_value.gl_orifice_plate_id(lv_object_id, ld_daytime, '<=');
    END IF;

  ELSE
     lv_orifice_plate_id := NULL;
  END IF;

  RETURN lv_orifice_plate_id;
END  findTdevOrificePlate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWellRefSpecGravity
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findWellRefSpecGravity(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>

IS
  lv_well_id                    VARCHAR2(32);
  lv_tdev_id                    VARCHAR2(32);
  ld_daytime                      DATE;
  ln_result                       NUMBER;

BEGIN
  IF p_object_id IS NULL OR p_daytime IS NULL THEN
    FOR cur_rst IN c_result(p_result_no) LOOP
      lv_well_id := cur_rst.well_object_id;
      lv_tdev_id := cur_rst.tdev_object_id;
      ld_daytime := cur_rst.daytime;
    END LOOP;
  ELSE
    lv_well_id := p_object_id;
    -- not specifically known if the object_id given is actually well or tdev!
    lv_tdev_id := p_object_id;
    ld_daytime := p_daytime;
  END IF;
  ln_result := ec_well_reference_value.specific_gravity(lv_well_id, ld_daytime, '<=');

  IF ln_result IS NULL THEN
     ln_result := ec_tdev_reference_value.spec_gravity(lv_tdev_id, ld_daytime, '<=');
  END IF;

  RETURN ln_result;
END  findWellRefSpecGravity;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWellRefGasLiftSpecGravity
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findWellRefGasLiftSpecGravity(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>

IS
  lv_object_id                    VARCHAR2(32);
  ld_daytime                      DATE;
  ln_result                       NUMBER;

BEGIN
  IF p_object_id IS NULL OR p_daytime IS NULL THEN
    FOR cur_rst IN c_result(p_result_no) LOOP
      lv_object_id := cur_rst.tdev_object_id;
      ld_daytime := cur_rst.daytime;
    END LOOP;
  ELSE
    lv_object_id := p_object_id;
    ld_daytime := p_daytime;
  END IF;
  ln_result := ec_tdev_reference_value.gl_spec_gravity(lv_object_id, ld_daytime, '<=');

  RETURN ln_result;
END  findWellRefGasLiftSpecGravity;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getPwelDate
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getPwelResultDate(p_result_no NUMBER)
RETURN DATE
--</EC-DOC>

IS

  ln_result                       DATE;

BEGIN

    FOR cur_rst IN c_result(p_result_no) LOOP
      ln_result := cur_rst.daytime;
    END LOOP;


  RETURN ln_result;
END  getPwelResultDate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : agaStaticPress
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION agaStaticPress(p_result_no test_device_result.result_no%TYPE,
                        p_object_id VARCHAR2,
                        p_phase VARCHAR2)
RETURN number
--</EC-DOC>
IS

CURSOR c_tdev_ref(cp_daytime DATE) IS
  SELECT *
  FROM tdev_reference_value t
  WHERE t.object_id = p_object_id
  AND t.daytime =
    (SELECT max(t2.daytime)
    FROM tdev_reference_value t2
    WHERE t2.object_id = t.object_id
    AND t2.daytime <= cp_daytime);


CURSOR c_result IS
  SELECT pr.daytime, pr.test_device as tdev_object_id, pr.object_id as well_object_id
  FROM pwel_result pr
  WHERE pr.result_no = p_result_no;


lr_test_device_result test_device_result%ROWTYPE;
ln_static_chart_scale NUMBER;
ln_static_chart_rating NUMBER;
ln_static_press_read NUMBER;
lv_class_name        VARCHAR2(32);
lv_attr_name         VARCHAR2(32);
lv_meter_run_id      VARCHAR2(32);
lv_static_chart_unit VARCHAR2(32);



ln_return_value      NUMBER := 0;

BEGIN
  ln_return_value := ue_testdevice.agaStaticPress(p_result_no,p_object_id,p_phase);
  IF ln_return_value IS NOT NULL THEN
    RETURN ln_return_value;
  END IF;

  lr_test_device_result := ec_test_device_result.row_by_pk(p_object_id, p_result_no);
  lv_class_name := lr_test_device_result.data_class_name;

  FOR my_result IN c_result LOOP

     --get the object_id for meter run
    lv_meter_run_id := findTdevMeterRun(p_result_no,p_phase,p_object_id,my_result.daytime);
    IF lv_meter_run_id IS NOT NULL THEN
       lv_static_chart_unit := ec_meter_run_version.static_chart_unit(lv_meter_run_id,my_result.daytime, '<=');
    ELSE
       lv_static_chart_unit := Ecdp_Unit.GetUnitFromLogical('PRESS_GAUGE');
    END IF;

    FOR my_tdev_ref IN c_tdev_ref(my_result.daytime) LOOP
      -- use values in test_device_result, but if null default from tdev_reference_value

      IF p_phase='GAS' THEN -- gas
        ln_static_chart_scale := nvl(lr_test_device_result.gas_static_chart_scale, my_tdev_ref.gas_stat_press_max_scale);
        ln_static_chart_rating := nvl(lr_test_device_result.gas_static_chart_rating, my_tdev_ref.gas_stat_press_spg_rate);
        lv_attr_name := getAttributeName(p_result_no,p_object_id,'GAS_STATIC_PRESS_READ');
        ln_static_press_read := lr_test_device_result.gas_static_press_read;

        IF (my_tdev_ref.gas_stat_press_chart_type in ('LINEAR', 'PERCENT') AND ln_static_chart_rating>0) THEN
          ln_return_value := ln_static_press_read / nvl(ln_static_chart_scale,100) * ln_static_chart_rating;

           -- Convert back to db-unit/UOM
          ln_return_value := Ecdp_Unit.convertValue(ln_return_value,
                                                  nvl(lv_static_chart_unit,'PSIG'),
                                                  Ecdp_Unit.GetUnitFromLogical(EcDp_ClassMeta_Cnfg.getUomCode(lv_class_name,'GAS_STATIC_PRESS')));

    ELSIF (my_tdev_ref.gas_stat_press_chart_type = 'SQUARE_ROOT' AND ln_static_chart_rating>0) THEN
          ln_return_value := POWER(nvl(ln_static_press_read,0), 2) / 100 * ln_static_chart_rating;

           -- Convert back to db-unit/UOM
          ln_return_value := Ecdp_Unit.convertValue(ln_return_value,
                                                  nvl(lv_static_chart_unit,'PSIG'),
                                                  Ecdp_Unit.GetUnitFromLogical(EcDp_ClassMeta_Cnfg.getUomCode(lv_class_name,'GAS_STATIC_PRESS')));


        ELSIF my_tdev_ref.gas_stat_press_chart_type = 'READING' THEN
          ln_return_value := Ecdp_Unit.convertValue(ln_static_press_read,
                                                  nvl(lv_static_chart_unit,'PSIG'),
                                                  Ecdp_Unit.GetUnitFromLogical(EcDp_ClassMeta_Cnfg.getUomCode(lv_class_name,'GAS_STATIC_PRESS')));

        ELSIF my_tdev_ref.gas_stat_press_chart_type IS NULL THEN
          ln_return_value := Ecdp_Unit.convertValue(ln_static_press_read,
                                                  nvl(lv_static_chart_unit,'PSIG'),
                                                  Ecdp_Unit.GetUnitFromLogical(EcDp_ClassMeta_Cnfg.getUomCode(lv_class_name,'GAS_STATIC_PRESS')));

        END IF;


      ELSE -- gas lift
        ln_static_chart_scale := nvl(lr_test_device_result.gl_static_chart_scale, my_tdev_ref.gl_static_press_max_scale);
        ln_static_chart_rating := nvl(lr_test_device_result.gl_static_chart_rating, my_tdev_ref.gl_static_press_spg_rate);
        lv_attr_name := getAttributeName(p_result_no,p_object_id,'GL_STATIC_PRESS_READ');
    ln_static_press_read := lr_test_device_result.gl_static_press_read;

        IF (my_tdev_ref.gl_static_press_chart_type in ('LINEAR', 'PERCENT') AND ln_static_chart_rating>0) THEN
          ln_return_value := ln_static_press_read / nvl(ln_static_chart_scale,100) * ln_static_chart_rating;

           -- Convert back to db-unit
          ln_return_value := Ecdp_Unit.convertValue(ln_return_value,
                                                  nvl(lv_static_chart_unit,'PSIG'),
                                                  Ecdp_Unit.GetUnitFromLogical(EcDp_ClassMeta_Cnfg.getUomCode(lv_class_name,'GL_STATIC_PRESS')));


        ELSIF (my_tdev_ref.gl_static_press_chart_type = 'SQUARE_ROOT' AND ln_static_chart_rating>0) THEN
          ln_return_value := POWER(nvl(ln_static_press_read,0), 2) / 100 * ln_static_chart_rating;

              -- Convert back to db-unit
          ln_return_value := Ecdp_Unit.convertValue(ln_return_value,
                                                  nvl(lv_static_chart_unit,'PSIG'),
                                                  Ecdp_Unit.GetUnitFromLogical(EcDp_ClassMeta_Cnfg.getUomCode(lv_class_name,'GL_STATIC_PRESS')));

        ELSIF my_tdev_ref.gl_static_press_chart_type = 'READING' then
          ln_return_value := Ecdp_Unit.convertValue(ln_static_press_read,
                                                  nvl(lv_static_chart_unit,'PSIG'),
                                                  Ecdp_Unit.GetUnitFromLogical(EcDp_ClassMeta_Cnfg.getUomCode(lv_class_name,'GL_STATIC_PRESS')));


        ELSIF my_tdev_ref.gl_static_press_chart_type IS NULL THEN

          ln_return_value := Ecdp_Unit.convertValue(ln_static_press_read,
                                                  nvl(lv_static_chart_unit,'PSIG'),
                                                  Ecdp_Unit.GetUnitFromLogical(EcDp_ClassMeta_Cnfg.getUomCode(lv_class_name,'GL_STATIC_PRESS')));

        END IF;

      END IF;
    END LOOP;

  END LOOP;

  RETURN ln_return_value;
END agaStaticPress;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : agaDiffPress
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION agaDiffPress(p_result_no test_device_result.result_no%TYPE,
                      p_object_id VARCHAR2,
                      p_phase VARCHAR2)
RETURN number
--</EC-DOC>
IS

CURSOR c_tdev_ref(cp_daytime DATE) IS
  SELECT *
  FROM tdev_reference_value t
  WHERE t.object_id = p_object_id
  AND t.daytime =
    (SELECT max(t2.daytime)
    FROM tdev_reference_value t2
    WHERE t2.object_id = t.object_id
    AND t2.daytime <= cp_daytime);


CURSOR c_result IS
  SELECT pr.daytime, pr.test_device as tdev_object_id, pr.object_id as well_object_id
  FROM pwel_result pr
  WHERE pr.result_no = p_result_no;


lr_test_device_result test_device_result%ROWTYPE;
ln_diff_chart_scale NUMBER;
ln_diff_chart_rating NUMBER;
ln_diff_press_read NUMBER;
lv_class_name        VARCHAR2(32);
lv_attr_name         VARCHAR2(32);
lv_meter_run_id      VARCHAR2(32);
lv_diff_chart_unit VARCHAR2(32);

ln_return_value number := 0;

BEGIN
  ln_return_value := ue_testdevice.agaDiffPress(p_result_no,p_object_id,p_phase);
  IF ln_return_value IS NOT NULL THEN
    RETURN ln_return_value;
  END IF;

  lr_test_device_result := ec_test_device_result.row_by_pk(p_object_id, p_result_no);
  lv_class_name := lr_test_device_result.data_class_name;


  FOR my_result IN c_result LOOP
        --get the object_id for meter run
    lv_meter_run_id := findTdevMeterRun(p_result_no,p_phase,p_object_id,my_result.daytime);
    IF lv_meter_run_id IS NOT NULL THEN
      lv_diff_chart_unit := ec_meter_run_version.diff_chart_unit(lv_meter_run_id,my_result.daytime, '<=');
    ELSE
      lv_diff_chart_unit := Ecdp_Unit.GetUnitFromLogical('PRESS_DIFF');
    END IF;

    FOR my_tdev_ref IN c_tdev_ref(my_result.daytime) LOOP


      -- use values in test_device_result, but if null default from tdev_reference_value


      IF p_phase='GAS' THEN -- gas
        ln_diff_chart_scale := nvl(lr_test_device_result.gas_diff_chart_scale, my_tdev_ref.gas_diff_press_max_scale);
        ln_diff_chart_rating := nvl(lr_test_device_result.gas_diff_chart_rating, my_tdev_ref.gas_diff_press_spg_rate);
        lv_attr_name := getAttributeName(p_result_no,p_object_id,'GAS_DIFF_PRESS_READ');
        ln_diff_press_read := lr_test_device_result.gas_diff_press_read;

        IF (my_tdev_ref.gas_diff_press_chart_type in ('LINEAR', 'PERCENT') AND ln_diff_chart_rating>0) THEN
          ln_return_value := ln_diff_press_read / nvl(ln_diff_chart_scale,100) * ln_diff_chart_rating;

          -- Convert back to db-unit/UOM
          ln_return_value := Ecdp_Unit.convertValue(ln_return_value,
                                                  nvl(lv_diff_chart_unit,'INH2O'),
                                                  Ecdp_Unit.GetUnitFromLogical(EcDp_ClassMeta_Cnfg.getUomCode(lv_class_name,'GAS_DIFF_PRESS')));


        ELSIF (my_tdev_ref.gas_diff_press_chart_type = 'SQUARE_ROOT' AND ln_diff_chart_rating>0) THEN
      ln_return_value := power(Nvl(ln_diff_press_read,0), 2)/100 * ln_diff_chart_rating;
           -- Convert back to db-unit/UOM
          ln_return_value :=  Ecdp_Unit.convertValue(ln_return_value,
                                                  nvl(lv_diff_chart_unit,'INH2O'),
                                                  Ecdp_Unit.GetUnitFromLogical(EcDp_ClassMeta_Cnfg.getUomCode(lv_class_name,'GAS_DIFF_PRESS')));

        ELSIF my_tdev_ref.gas_diff_press_chart_type = 'READING' then
          ln_return_value := Ecdp_Unit.convertValue(ln_diff_press_read,
                                                  nvl(lv_diff_chart_unit,'INH2O'),
                                                  Ecdp_Unit.GetUnitFromLogical(EcDp_ClassMeta_Cnfg.getUomCode(lv_class_name,'GAS_DIFF_PRESS')));

        ELSIF my_tdev_ref.gas_diff_press_chart_type IS NULL then
          ln_return_value := Ecdp_Unit.convertValue(ln_diff_press_read,
                                                  nvl(lv_diff_chart_unit,'INH2O'),
                                                  Ecdp_Unit.GetUnitFromLogical(EcDp_ClassMeta_Cnfg.getUomCode(lv_class_name,'GAS_DIFF_PRESS')));

        END IF;

      ELSE -- gas lift
        ln_diff_chart_scale := nvl(lr_test_device_result.gl_diff_chart_scale, my_tdev_ref.gl_diff_press_max_scale);
        ln_diff_chart_rating := nvl(lr_test_device_result.gl_diff_chart_rating, my_tdev_ref.gl_diff_press_spg_rate);
        lv_attr_name := getAttributeName(p_result_no,p_object_id,'GL_DIFF_PRESS_READ');
        ln_diff_press_read := lr_test_device_result.gl_diff_press_read;

        IF (my_tdev_ref.gl_diff_press_chart_type in ('LINEAR', 'PERCENT') AND ln_diff_chart_rating>0) THEN
          ln_return_value := ln_diff_press_read / nvl(ln_diff_chart_scale,100) * ln_diff_chart_rating;

          -- Convert back to db-unit/UOM
          ln_return_value := Ecdp_Unit.convertValue(ln_return_value,
                                                  nvl(lv_diff_chart_unit,'INH2O'),
                                                  Ecdp_Unit.GetUnitFromLogical(EcDp_ClassMeta_Cnfg.getUomCode(lv_class_name,'GL_DIFF_PRESS')));


        ELSIF (my_tdev_ref.gl_diff_press_chart_type = 'SQUARE_ROOT' AND ln_diff_chart_rating>0) THEN
          ln_return_value := power(Nvl(ln_diff_press_read,0), 2)/100 * ln_diff_chart_rating;

          -- Convert back to db-unit/UOM
          ln_return_value := Ecdp_Unit.convertValue(ln_return_value,
                                                  nvl(lv_diff_chart_unit,'INH2O'),
                                                  Ecdp_Unit.GetUnitFromLogical(EcDp_ClassMeta_Cnfg.getUomCode(lv_class_name,'GL_DIFF_PRESS')));


        ELSIF my_tdev_ref.gl_diff_press_chart_type = 'READING' then
          ln_return_value := Ecdp_Unit.convertValue(ln_diff_press_read,
                                                  nvl(lv_diff_chart_unit,'INH2O'),
                                                  Ecdp_Unit.GetUnitFromLogical(EcDp_ClassMeta_Cnfg.getUomCode(lv_class_name,'GL_DIFF_PRESS')));

        ELSIF my_tdev_ref.gl_diff_press_chart_type IS NULL then
          ln_return_value := Ecdp_Unit.convertValue(ln_diff_press_read,
                                                  nvl(lv_diff_chart_unit,'INH2O'),
                                                  Ecdp_Unit.GetUnitFromLogical(EcDp_ClassMeta_Cnfg.getUomCode(lv_class_name,'GL_DIFF_PRESS')));

        END IF;

      END IF;
    END LOOP;

  END LOOP;

  RETURN ln_return_value;

END agaDiffPress;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getMeterFactor
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getMeterFactor(p_object_id VARCHAR2,
         p_phase VARCHAR2,
         p_daytime DATE,
         p_result_no NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

lv_meter_factor_method VARCHAR2(32);
ln_return_value        NUMBER := NULL;


BEGIN

lv_meter_factor_method := ec_test_device_version.meter_factor_method(p_object_id, p_daytime, '<=');
IF lv_meter_factor_method = 'COPY_FORWARD' THEN
   IF p_phase = EcDp_phase.OIL THEN
      ln_return_value := nvl(ec_test_device_result.override_oil_mtr_factor(p_object_id,p_result_no), 1);
   ELSIF p_phase = EcDp_phase.WATER THEN
      ln_return_value := nvl(ec_test_device_result.override_wat_mtr_factor(p_object_id,p_result_no), 1);
   END IF;

ELSIF lv_meter_factor_method = 'TDEV_REFERENCE' THEN
   IF p_phase = EcDp_phase.OIL THEN
      ln_return_value := nvl(ec_tdev_reference_value.oil_meter_factor(p_object_id, p_daytime, '<='), nvl(ec_test_device_result.override_oil_mtr_factor(p_object_id,p_result_no),1));
   ELSIF p_phase = EcDp_phase.WATER THEN
      ln_return_value := nvl(ec_tdev_reference_value.water_meter_factor(p_object_id, p_daytime, '<='), nvl(ec_test_device_result.override_wat_mtr_factor(p_object_id,p_result_no),1));
   END IF;


ELSIF (substr(lv_meter_factor_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
   ln_return_value := Ue_Testdevice.getMeterFactor(p_result_no,p_object_id,p_daytime);

ELSIF lv_meter_factor_method IS NULL THEN
   ln_return_value := null;

END IF;

RETURN ln_return_value;

END getMeterFactor;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getTDEVResultValues
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE updTDEVResultValues(p_object_id VARCHAR2,
         p_result_no NUMBER,
         p_daytime DATE)
--</EC-DOC>
IS

CURSOR c_pwel_result(cp_object_id VARCHAR2, cp_result_no NUMBER, cp_daytime DATE) IS
select * from pwel_result pr
where pr.test_device = cp_object_id
and pr.daytime =
             (select MAX(pr2.daytime) from pwel_result pr2
              where pr2.test_device = cp_object_id
              and pr2.daytime <= cp_daytime
              and pr2.valid_from_date <= cp_daytime
              and pr2.result_no <> cp_result_no)
and pr.result_no <> cp_result_no
and pr.valid_from_date <= cp_daytime
order by pr.daytime DESC, pr.valid_from_date DESC;

lr_test_device_result test_device_result%ROWTYPE;
lv_meter_factor_method VARCHAR2(32);

BEGIN

lv_meter_factor_method := ec_test_device_version.meter_factor_method(p_object_id, p_daytime, '<=');

IF  lv_meter_factor_method = 'COPY_FORWARD' THEN
    FOR c_last_testdevice IN c_pwel_result(p_object_id, p_result_no, p_daytime) LOOP

        lr_test_device_result := ec_test_device_result.row_by_pk(p_object_id, c_last_testdevice.result_no);

        UPDATE test_device_result ER
        SET ER.Override_Oil_Mtr_Factor = lr_test_device_result.override_oil_mtr_factor,
        ER.Override_Wat_Mtr_Factor = lr_test_device_result.override_wat_mtr_factor
        WHERE ER.Object_Id = p_object_id
        AND ER.Result_No = p_result_no;

        EXIT;

    END LOOP;

END IF;


END updTDEVResultValues;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function      : findDiluentRate
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findDiluentRate(p_result_no NUMBER,
          p_object_id VARCHAR2,
          p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

lv_diluent_rate_method       VARCHAR2(100);
lv_object_id                 VARCHAR2(32);
ld_daytime                   DATE;
ln_duration                  NUMBER;
ln_result                    NUMBER;

BEGIN

  IF p_object_id IS NULL OR p_daytime IS NULL THEN
  -- find object_id and daytime
    FOR cur_rst IN c_result(p_result_no) LOOP
      lv_object_id := cur_rst.tdev_object_id;
      ld_daytime := cur_rst.daytime;
    END LOOP;
  ELSE
    lv_object_id := p_object_id;
    ld_daytime := p_daytime;
  END IF;

  -- determine the DILUENT_RATE_METHOD
  lv_diluent_rate_method := nvl(ec_test_device_version.diluent_rate_method(lv_object_id, ld_daytime,'<='), 'MEASURED');

  IF lv_diluent_rate_method = 'MEASURED' THEN
     ln_result := ec_test_device_result.est_diluent_rate_flc(lv_object_id, p_result_no);

  ELSIF lv_diluent_rate_method = 'VOLUME_DURATION' THEN
     ln_duration := findDuration(p_result_no);

     IF ln_duration > 0 THEN
        ln_result := ec_test_device_result.est_diluent_vol_flc(lv_object_id, p_result_no) / ln_duration * 24;
     END IF;

  ELSIF lv_diluent_rate_method = 'RATE_OR_VOLUME' THEN
     ln_result := ec_test_device_result.est_diluent_rate_flc(lv_object_id, p_result_no);

     IF ln_result IS NULL THEN
        ln_duration := findDuration(p_result_no);

        IF ln_duration > 0 THEN
           ln_result := ec_test_device_result.est_diluent_vol_flc(lv_object_id, p_result_no) / ln_duration * 24;
        END IF;
     END IF;

  ELSIF (substr(lv_diluent_rate_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
     ln_result := Ue_Testdevice.findDiluentRate(p_result_no, lv_object_id, ld_daytime);

  END IF;

  RETURN ln_result;

END findDiluentRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function      : findWellWetGasRate
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findWellWetGasRate(p_result_no NUMBER,
          p_object_id VARCHAR2,
          p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

lv_well_wet_gas_rate_method  VARCHAR2(100);
lv_object_id                 VARCHAR2(32);
ld_daytime                   DATE;
ln_duration                  NUMBER;
ln_result                    NUMBER;

BEGIN

  IF p_object_id IS NULL OR p_daytime IS NULL THEN
  -- find object_id and daytime
    FOR cur_rst IN c_result(p_result_no) LOOP
      lv_object_id := cur_rst.tdev_object_id;
      ld_daytime := cur_rst.daytime;
    END LOOP;
  ELSE
    lv_object_id := p_object_id;
    ld_daytime := p_daytime;
  END IF;

  -- determine the WELL_WET_GAS_RATE_METHOD
  lv_well_wet_gas_rate_method := nvl(ec_test_device_version.well_wet_gas_rate_method(lv_object_id, ld_daytime,'<='), 'MEASURED');

  IF lv_well_wet_gas_rate_method = 'MEASURED' THEN
     ln_result := ec_test_device_result.well_wet_gas_rate(lv_object_id, p_result_no);

  ELSIF lv_well_wet_gas_rate_method = 'VOLUME_DURATION' THEN
     ln_duration := findDuration(p_result_no);

     IF ln_duration > 0 THEN
        ln_result := ec_test_device_result.well_wet_gas_vol(lv_object_id, p_result_no) / ln_duration * 24;
     END IF;

  ELSIF lv_well_wet_gas_rate_method = 'RATE_OR_VOLUME' THEN
     ln_result := ec_test_device_result.well_wet_gas_rate(lv_object_id, p_result_no);

     IF ln_result IS NULL THEN
       ln_duration := findDuration(p_result_no);

       IF ln_duration > 0 THEN
          ln_result := ec_test_device_result.well_wet_gas_vol(lv_object_id, p_result_no) / ln_duration * 24;
       END IF;
     END IF;

  ELSIF (substr(lv_well_wet_gas_rate_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN
        ln_result := Ue_Testdevice.findWellWetGasRate(p_result_no, lv_object_id, ld_daytime);

  END IF;

  RETURN ln_result;


END findWellWetGasRate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function      : calcWaterCut
-- Description    :
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION calcWaterCut(p_result_no NUMBER,p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>

IS
  lv_object_id                  VARCHAR2(32);
  lv_well_object_id             VARCHAR2(32);
  ld_daytime                    DATE;
  ln_result                     NUMBER;
  ln_water                      NUMBER;
  lv_oil_ind                    VARCHAR2(32);
  lv_con_ind                    VARCHAR2(32);
  lv2_cond_ind          VARCHAR2(32);
  lv_phase                      VARCHAR2(32);

BEGIN
  IF p_object_id IS NULL OR p_daytime IS NULL THEN
    -- find object_id and daytime
    FOR cur_rst IN c_result(p_result_no) LOOP
      lv_object_id := cur_rst.tdev_object_id;
      ld_daytime := cur_rst.daytime;
      lv_well_object_id := cur_rst.well_object_id;
    END LOOP;
  ELSE
    lv_object_id := p_object_id;
    ld_daytime := p_daytime;
  END IF;

    --find p_phase = OIL or CONDENSATE
    lv_oil_ind := nvl(ec_well_version.isoilproducer(lv_well_object_id,ld_daytime,'<='), '');
    lv_con_ind := nvl(ec_well_version.isgasproducer(lv_well_object_id,ld_daytime,'<='), '');
  lv2_cond_ind := nvl(ec_well_version.iscondensateproducer(lv_well_object_id,ld_daytime,'<='), '');
    IF lv_oil_ind = 'Y' THEN
       lv_phase := 'OIL';
    ELSIF lv_con_ind = 'Y' OR lv2_cond_ind = 'Y' THEN
       lv_phase := 'CONDENSATE';
    ELSE lv_phase := NULL;
    END IF;

    --performing calculation on Water Cut %
    IF lv_phase = 'OIL' THEN
      ln_water := nvl(findStdNetRate(p_result_no, EcDp_Phase.WATER, lv_object_id, ld_daytime),0);
      IF ln_water > 0 THEN
         ln_result := ln_water/((findStdNetRate(p_result_no, EcDp_Phase.OIL, lv_object_id, ld_daytime)+ln_water));
      END IF;
    ELSIF lv_phase = 'CONDENSATE' THEN
      ln_water := nvl(findStdNetRate(p_result_no, EcDp_Phase.WATER, lv_object_id, ld_daytime),0);
      IF ln_water > 0 THEN
         ln_result := ln_water/((findStdNetRate(p_result_no, EcDp_Phase.CONDENSATE, lv_object_id, ld_daytime)+ln_water));
      END IF;
    ELSE
      ln_result := NULL;
    END IF;

  RETURN ln_result;
END calcWaterCut;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function      : findRefShrinkageFactor
-- Description    : Find the correct Shrinkage method = TDEV_FACTOR or WELL_FACTOR or WELL_TDEV_FACTOR or USER_EXIT
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findRefShrinkageFactor(p_result_no NUMBER, p_phase VARCHAR2, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>

IS
  lv_shrinkage_method               VARCHAR2(32);
  lv_object_id                      VARCHAR2(32);
  lv_well_object_id                 VARCHAR2(32);

  ld_daytime                        DATE;
  ln_result                         NUMBER;

BEGIN
-- find object_id and daytime
    FOR cur_rst IN c_result(p_result_no) LOOP
      lv_object_id := cur_rst.tdev_object_id;
      ld_daytime := cur_rst.daytime;
      lv_well_object_id := cur_rst.well_object_id;
    END LOOP;

-- determine shrinkage method
   lv_shrinkage_method := ec_test_device_version.shrinkage_method(lv_object_id, ld_daytime,'<=');

    IF lv_shrinkage_method = 'TDEV_FACTOR' THEN --go to findTdevRefShrinkageFactor()
       ln_result := nvl(findTdevRefShrinkageFactor(p_result_no, p_phase, p_object_id, p_daytime),'') ;

    ELSIF lv_shrinkage_method = 'WELL_FACTOR' THEN --go to findWellRefShrinkageFactor()
       ln_result := nvl(findWellRefShrinkageFactor(p_result_no, p_phase, p_object_id, p_daytime),'');

    ELSIF lv_shrinkage_method = 'WELL_TDEV_FACTOR' THEN --if WELL_FACTOR = NULL then show TDEV_FACTOR
       ln_result := nvl(findWellRefShrinkageFactor(p_result_no, p_phase, p_object_id, p_daytime),
                        findTdevRefShrinkageFactor(p_result_no, p_phase, p_object_id, p_daytime));
    ELSIF  substr(lv_shrinkage_method, 1, 9) = EcDp_Calc_Method.USER_EXIT THEN
      ln_result := Ue_Testdevice.findRefShrinkageFactor(p_result_no,p_phase,p_object_id, p_daytime);
    END IF;

    RETURN ln_result;

END findRefShrinkageFactor;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWellRefShrinkageFactor
-- Description    :Find the correct reference value when shrinkage method = WELL_FACTOR
--
--
-- Preconditions  :
--
--
--
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findWellRefShrinkageFactor(p_result_no NUMBER, p_phase VARCHAR2, p_object_id VARCHAR2, p_daytime DATE)

RETURN NUMBER
--</EC-DOC>

IS
  lv_object_id                    VARCHAR2(32);
  lv_well_object_id               VARCHAR2(32);

  ld_daytime                      DATE;
  ln_result                       NUMBER;

BEGIN
    FOR cur_rst IN c_result(p_result_no) LOOP
      lv_object_id := cur_rst.tdev_object_id;
      ld_daytime := cur_rst.daytime;
      lv_well_object_id := cur_rst.well_object_id;
    END LOOP;

    IF p_phase = Ecdp_Phase.OIL THEN
       ln_result := ec_well_reference_value.wt_oil_shrinkage(lv_well_object_id, ld_daytime, '<=');

    ELSIF p_phase = Ecdp_Phase.GAS THEN
       ln_result := ec_well_reference_value.wt_gas_shrinkage(lv_well_object_id, ld_daytime, '<=');

    ELSE
       ln_result := NULL;

    END IF;

    RETURN ln_result;

END findWellRefShrinkageFactor;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : getDefaultTdev
-- Description  : Checking record for Test Device has already been set to be default for current Facility
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
---------------------------------------------------------------------------------------------------
PROCEDURE getDefaultTdev (p_fac1_id VARCHAR2,p_daytime DATE)

--<EC-DOC>
IS

CURSOR c_default_tdev IS
 SELECT object_id,name
 FROM ov_test_device
 WHERE op_fcty_1_id=p_fac1_id
 AND default_fcty_test_device='Y'
 ORDER BY name;

ln_result NUMBER:=0;
ln_id VARCHAR2(32);
ln_name VARCHAR2(240);
lv_result VARCHAR2(500);
lv_delimeter VARCHAR2(2);
lv_tot_rec NUMBER;
lv_fctyid VARCHAR2(32);
lv_tot_result LONG;

BEGIN

 SELECT COUNT(*)
 INTO ln_result
 FROM ov_test_device
 WHERE op_fcty_1_id=p_fac1_id
 AND default_fcty_test_device='Y';

 IF ln_result = 1 THEN
  SELECT object_id,name
  INTO ln_id,ln_name
  FROM ov_test_device
  WHERE op_fcty_1_id=p_fac1_id
  AND default_fcty_test_device='Y';

  lv_result:='Test Device '||ln_name||' has already been set as a default for current Facility.';
   RAISE_APPLICATION_ERROR(-20653, lv_result);

 ELSIF ln_result > 1 THEN
      SELECT op_fcty_1_id,count(*)tot_rows
      INTO lv_fctyid,lv_tot_rec
      FROM ov_test_device
      WHERE op_fcty_1_id=p_fac1_id
      AND default_fcty_test_device='Y'
      GROUP BY op_fcty_1_id;

  FOR mycur IN c_default_tdev LOOP
    IF c_default_tdev%ROWCOUNT > 0 THEN
      IF c_default_tdev%ROWCOUNT <> lv_tot_rec THEN
        lv_delimeter:=',';
      ELSE
        lv_delimeter:='';
      END IF;
    END IF;

    lv_result:=lv_result||mycur.name||lv_delimeter;
  END LOOP;
    lv_result:=substr(lv_result,1,length(lv_result));
    lv_tot_result:='Test Device '||lv_result||' has already been set a default for current Facility.';

     RAISE_APPLICATION_ERROR(-20653, lv_tot_result);
 ELSE
  NULL;
 END IF;

END getDefaultTdev;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : getMeterText
-- Description  : Get the Code Text for meter from PROSTY_CODES or V_TRANS_CONFIG.
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
---------------------------------------------------------------------------------------------------
FUNCTION getMeterText(
         p_code VARCHAR2,
         p_code_type VARCHAR2,
         p_object_id VARCHAR2,
		 p_date DATE)
RETURN VARCHAR2

IS
   CURSOR c_eccode_col_val IS
    SELECT code_text col
    FROM PROSTY_CODES
    WHERE code = p_code
         AND code_type = p_code_type;

   v_return_val VARCHAR2(1000);
   v_data_class VARCHAR2(32);

BEGIN
      v_return_val := '';

      IF p_object_id IS NOT NULL THEN
        SELECT COUNT(TD.INSTRUMENTATION_TYPE) INTO v_data_class FROM OV_TEST_DEVICE TD WHERE TD.OBJECT_ID = p_object_id AND DAYTIME < p_date AND (END_DATE >= p_date OR END_DATE IS NULL);
        IF v_data_class > 0 THEN
          SELECT 'TDEV_SAMPLE_' || to_char(TD.INSTRUMENTATION_TYPE) INTO v_data_class FROM OV_TEST_DEVICE TD WHERE TD.OBJECT_ID = p_object_id AND DAYTIME < p_date AND (END_DATE >= p_date OR END_DATE IS NULL);

          IF p_code_type = 'TDEV_OIL_METER' THEN
			       v_return_val := getOilMeterText(p_code, v_data_class, p_object_id);
          ELSIF p_code_type = 'TDEV_GAS_METER' THEN
             v_return_val := getGasMeterText(p_code, v_data_class, p_object_id);
          ELSIF p_code_type = 'TDEV_WATER_METER' THEN
             v_return_val := getWaterMeterText(p_code, v_data_class, p_object_id);
          END IF;
        END IF;
      END IF;

      IF v_return_val IS NULL THEN
         FOR cur_row IN c_eccode_col_val LOOP
            v_return_val := cur_row.col;
         END LOOP;
      END IF;

      RETURN v_return_val;

END getMeterText;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : getOilMeterText
-- Description  : Get the Code Text for meter from V_TRANS_CONFIG where the attributes are
--				  'OIL_OUT_RATE_1_RAW','OIL_OUT_RATE_2_RAW','OIL_OUT_RATE_3_RAW'.
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
---------------------------------------------------------------------------------------------------
FUNCTION getOilMeterText(
         p_code VARCHAR2,
         p_data_class VARCHAR2,
         p_object_id VARCHAR2)
RETURN VARCHAR2

IS

   CURSOR c_oil_col_val IS
    SELECT TS.ATTRIBUTE, TS.DESCRIPTION
    FROM V_TRANS_CONFIG TS
    WHERE
    TS.PK_VAL_1 = p_object_id
    AND TS.DATA_CLASS = p_data_class
    AND TS.ATTRIBUTE IN ('OIL_OUT_RATE_1_RAW','OIL_OUT_RATE_2_RAW','OIL_OUT_RATE_3_RAW');

   v_return_val VARCHAR2(1000);

BEGIN
	 FOR cur_row IN c_oil_col_val LOOP
		 IF p_code = 'OIL_METER_1' AND cur_row.ATTRIBUTE = 'OIL_OUT_RATE_1_RAW' THEN
			v_return_val := cur_row.DESCRIPTION;
		 ELSIF p_code = 'OIL_METER_2' AND cur_row.ATTRIBUTE = 'OIL_OUT_RATE_2_RAW' THEN
			v_return_val := cur_row.DESCRIPTION;
		 ELSIF p_code = 'OIL_METER_3' AND cur_row.ATTRIBUTE = 'OIL_OUT_RATE_3_RAW' THEN
			v_return_val := cur_row.DESCRIPTION;
		 END IF;
	 END LOOP;

     RETURN v_return_val;

END getOilMeterText;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : getGasMeterText
-- Description  : Get the Code Text for meter from V_TRANS_CONFIG where the attributes are
--				  'GAS_OUT_RATE_1_RAW','GAS_OUT_RATE_2_RAW','GAS_OUT_RATE_3_RAW'.
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
---------------------------------------------------------------------------------------------------
FUNCTION getGasMeterText(
         p_code VARCHAR2,
         p_data_class VARCHAR2,
         p_object_id VARCHAR2)
RETURN VARCHAR2

IS

   CURSOR c_gas_col_val IS
    SELECT TS.ATTRIBUTE, TS.DESCRIPTION
    FROM V_TRANS_CONFIG TS
    WHERE
    TS.PK_VAL_1 = p_object_id
    AND TS.DATA_CLASS = p_data_class
    AND TS.ATTRIBUTE IN ('GAS_OUT_RATE_1_RAW','GAS_OUT_RATE_2_RAW','GAS_OUT_RATE_3_RAW');

   v_return_val VARCHAR2(1000);

BEGIN
	 FOR cur_row IN c_gas_col_val LOOP
		 IF p_code = 'GAS_METER_1' AND cur_row.ATTRIBUTE = 'GAS_OUT_RATE_1_RAW' THEN
			v_return_val := cur_row.DESCRIPTION;
		 ELSIF p_code = 'GAS_METER_2' AND cur_row.ATTRIBUTE = 'GAS_OUT_RATE_2_RAW' THEN
			v_return_val := cur_row.DESCRIPTION;
		 ELSIF p_code = 'GAS_METER_3' AND cur_row.ATTRIBUTE = 'GAS_OUT_RATE_3_RAW' THEN
			v_return_val := cur_row.DESCRIPTION;
		 END IF;
	 END LOOP;

     RETURN v_return_val;

END getGasMeterText;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : getWaterMeterText
-- Description  : Get the Code Text for meter from V_TRANS_CONFIG where the attributes are
--				  'WATER_OUT_RATE_1_RAW','WATER_OUT_RATE_2_RAW','WATER_OUT_RATE_3_RAW'.
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
---------------------------------------------------------------------------------------------------
FUNCTION getWaterMeterText(
         p_code VARCHAR2,
         p_data_class VARCHAR2,
         p_object_id VARCHAR2)
RETURN VARCHAR2

IS

   CURSOR c_water_col_val IS
    SELECT TS.ATTRIBUTE, TS.DESCRIPTION
    FROM V_TRANS_CONFIG TS
    WHERE
    TS.PK_VAL_1 = p_object_id
    AND TS.DATA_CLASS = p_data_class
    AND TS.ATTRIBUTE IN ('WATER_OUT_RATE_1_RAW','WATER_OUT_RATE_2_RAW','WATER_OUT_RATE_3_RAW');

   v_return_val VARCHAR2(1000);

BEGIN
	 FOR cur_row IN c_water_col_val LOOP
		 IF p_code = 'WATER_METER_1' AND cur_row.ATTRIBUTE = 'WATER_OUT_RATE_1_RAW' THEN
			v_return_val := cur_row.DESCRIPTION;
		 ELSIF p_code = 'WATER_METER_2' AND cur_row.ATTRIBUTE = 'WATER_OUT_RATE_2_RAW' THEN
			v_return_val := cur_row.DESCRIPTION;
		 ELSIF p_code = 'WATER_METER_3' AND cur_row.ATTRIBUTE = 'WATER_OUT_RATE_3_RAW' THEN
			v_return_val := cur_row.DESCRIPTION;
		 END IF;
	 END LOOP;

     RETURN v_return_val;

END getWaterMeterText;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : getJournalRevNo
-- Description  : Get the journal configuration from table class and return rev_no based on configuration
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: CLASS
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
---------------------------------------------------------------------------------------------------
FUNCTION getJournalRevNo(p_class         VARCHAR2,
                         p_record_status VARCHAR2,
                         p_rev_no        NUMBER)
RETURN NUMBER

IS

    lv_jn_rule       VARCHAR2(240);
    lv_jn_rec_status VARCHAR2(240);

    TYPE statusarray IS VARRAY(10) OF VARCHAR2(5);
    arr_status      statusarray := statusarray();
    ln_intPos       NUMBER(5) DEFAULT 1;
    ln_prevPos      NUMBER(5) DEFAULT 1;
    ln_fieldLen     NUMBER(5);
    ln_occur        NUMBER(5) DEFAULT 1;
    ln_arrayCounter NUMBER(5) DEFAULT 1;

BEGIN
    lv_jn_rule := EcDp_ClassMeta_Cnfg.getJournalRuleDbSyntax(p_class);

    IF lv_jn_rule IS NOT NULL THEN
		IF UPPER(lv_jn_rule) = 'FALSE' THEN
			--no audit trail
			RETURN p_rev_no;
		ELSIF UPPER(lv_jn_rule) = 'TRUE' THEN
			--always audit trail
			RETURN p_rev_no + 1;
		ELSE
			--expect to get :old.RECORD_STATUS IN ('V','A'), others might give errors
			--get the record status in format V,A,
			lv_jn_rec_status := REPLACE(REPLACE(SUBSTR(lv_jn_rule, INSTR(lv_jn_rule, '''')), ')', ''), '''','')||',';

			LOOP
			  ln_intPos := INSTR(lv_jn_rec_status, ',', 1, ln_occur);
			  IF ln_intPos = 0 THEN
				EXIT;
			  END IF;
			  IF ln_occur = 1 THEN
				ln_fieldLen := ln_intPos - 1;
			  ELSE
				ln_fieldLen := ln_intPos - ln_prevPos;
			  END IF;
			  arr_status.extend;
			  arr_status(ln_arrayCounter) := SUBSTR(lv_jn_rec_status,
													ln_prevPos,
													ln_fieldLen);
			  ln_prevPos      := ln_intPos + 1;
			  ln_occur        := ln_occur + 1;
			  ln_arrayCounter := ln_arrayCounter + 1;
			END LOOP;

			FOR x IN 1 .. (arr_status.COUNT) LOOP
			  IF p_record_status = arr_status(x) THEN
				RETURN p_rev_no + 1;
			  END IF;
			END LOOP;
		END IF;
    END IF;

    RETURN p_rev_no;

  END getJournalRevNo;

END EcBp_TestDevice;