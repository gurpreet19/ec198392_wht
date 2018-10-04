CREATE OR REPLACE PACKAGE BODY EcDp_Performance_Test IS
/****************************************************************
** Package        :  EcDp_Performance_Test, body part
**
** $Revision: 1.130.2.12 $
**
** Purpose        :  Provide data service layer for Performace Test
**
** Documentation  :  www.energy-components.com
**
** Created  : 07/04/2005 Tor-Erik Hauge
**
** Modification history:
**
** Date        Whom      Change description:
** ------      ----- 	 ---------------------------------------------------------------------
** 07/04/2005  Haugetor  Initial
** 08/04/2005  DN        Added show-functions.
** 12/04/2005  DN        Added logic to SetRecordStatusByStatus
** 19/04/2005  Darren    Add implementation for ecdp_performance_test.processTestDeviceSampleRates
** 22/04/2005  SHN       Added function showFlowingWells, showNonFlowingWells, showPrimaryWells
** 28/04/2005  SHN       Tracker 2058. Added several new functions used by PT 0011
** 29/04/2005  Darren    Tracker 2052 Added procedure biValidateTestOnInsert
** 02/05/2005  Darren    Removed procedure biValidateTestOnInsert
** 26/05/2005  SHN       Fixed bug in get<>RateTargetWellResult and saveWellTargetResult. TD 3914, 3933
** 27/05/2005  AV        Removed
** 27/05/2005  ROV       Fixed error in cursor in function getLastValidWellResultNo
** 28/06/2005  SHN       Tracker 2385. Updated getDiluentShrinkageFromStream because stream_category is moved from table STREAM to STRM_VERSION.
** 22/07/2005  SHN       Tracker 2244. Modified getDiluentStdRateDay. Added support for well.diluent_method.
** 16/08/2005  DN        Tracker 2518: Rewritten query in function getLastValidResultNo in order to achieve better performance.
** 25/08/2005  kaurrnar  Tracker 2554: Error in formula calculating gas lift for test result - Line 2664 - Changed from ln_flcPress to ln_flcTemp
** 09/09/2005  Ron       Added 8 new functions
**                       - getNextValidWellResult
**                       - getNextValidWellResultNo
**                       - getTrendSegmentMinDate
**                       - getTrendSegmentMaxDate
**                       - findOilConstantC2
**                       - findGasConstantC2
**                       - findCondConstantC2
**                       - findWatConstantC2
** 27/09/2005  DN        Tracker 2682: Bug fixes in procedure PreProcessEqpmResultRow
** 01/10/2005  Darren    TD4414 and 4416 in findOilConstantC2, findGasConstantC2, findCondConstantC2, findWatConstantC2
** 03/10/2005  Darren    TD4414 and 4416 in findOilConstantC2, findGasConstantC2, findCondConstantC2, findWatConstantC2 again.
** 09.11.2005  AV        Changed references to WriteTempText from EcDp_genClasscode to EcDp_DynSQL (code cleanup)
** 15.11.2005  Ron       TI#2612 : Update function getGasLiftStdRateDay to support new gas lift method - Last Accepted Well Test minus Deferred.
** 27.12.2005  AV        Ref #2288 Added lock check for setRecordStatusbyStatus, processTestDeviceSampleRates, PreprocessTestResult, saveWellTargetResult,
**                       summarizeStablePeriod
** 04/01/2006  Lau       Tracker 3270: Missing production day column on class PROD_TEST_RESULT
** 11/11/2006  chongjer  Tracker 3101: Errors in function getGasLiftStdRateDay corrected.
** 05.04.2006  johanein  TI#3668/3670: Updated functions Get#StdRateDay to cater for expanded curve input parameter list.
** 26/04/2006  zakiiari  TI#3383/3384:
**                       Added procedure setWbiTestDefine, setWbiTestResult, removeWbiTestDefine, removeWbiTestResult
**                       Added function getTestObjectName
**                       Updated function getSampleDataClassName and getResultDataClassName by including WBI
**                       Updated procedure summariseStablePeriod, PreProcessEqpmResultRow, PreProcessPwelResultRow
**                       Updated procedure PreProcessTestResult to have bigger size for the variable lv2_missing_cols
** 10/05/2006  johanein	 Added support for power water subtraction by implementing getPowerWaterStdRateDay and getSumEstPWRWATRate
** 10/05/2006  johanein	 Added support for pt_calc_base VOLUME* or MASS
** 27/06/2006  rahmanaz  Modified PROCEDURE SummarizeStablePeriod
** 25/09/2006  ottermag  TI#3300: Added procedures acceptTestResult and rejectTestResult. Also changed getLastValidWellResultNo to check on USE_CALC flag on PTST_RESULT
** 01/12/2006  siahohwi  TI#4824: Added	initEQPMForPreProcess,initPFLWForPreProcess,initPWELForPreProcess
** 18/12/2006  siahohwi  ECPD-4514: Added gl_stateconv check to allow turn off the shrinkage calculation for well GAS LIFT
** 12/03/2007  Siah      Added procedure validateTestDate
** 22/03/2007  embonhaf  ECPD-5175 and ECPD-5210 : Added NULL checking in PreProcessTestResult and fix function call in PreProcessPwelResultRow.
** 12/04/2007  embonhaf  ECPD-5210 Modified getGasLiftStdRateDay, getDiluentStdRateDay and getPowerWaterStdRateDay to never return null value if no calc method selected
** 13/04/2007  embonhaf  ECPD-5143 Modified the cursor reference in PreProcessEqpmResultRow
** 30/05/2007  seongkok  ECPD-4819: Added procedures auiSyncPtstResult, auiSyncPtstResultTdev, auiSyncPwelResult, aiSyncPwelResultFromTdev, aiSyncPwelResultFromPwel, delPwelResultData and delPtstResultData
** 28/06/2007  Lau       ECPD-5948 Added procedures auisetPwelResult, auiSyncEqpmResult,auidelEqpmResult and modified procedure getLastValidWellResultNo
** 08/10/2007  kaurrnar  ECPD-6342: Added uncheckMultiselect procedure
** 03/12/2007  oonnnng   ECPD-6541: Add AVG_FLOW_MASS attribute in getGasStdRateDay, getCondStdRateDay, getOilStdRateDay, getWatStdRateDay and getGasLiftStdRateDay functions.
** 03/12/2007  Lau       ECPD-5561 Added getSingleDataClassName
** 06/12/2007  rajarsar  ECPD-7039: Updated checkLockInd,acceptTestResult, acceptTestResultNoAlloc and rejectTestResult
** 10/01/2008  rajarsar  ECPD-7226: Updated getSingleDataClassName
** 14/02/2008  zakiiari  ECPD-7277: Updated acceptTestResult, acceptTestResultNoAlloc and rejectTestResult to update EQPM_RESULT as well
** 05/03/2008  ismaiime  ECPD-7758: Modify function summarizeStablePeriod to set class_name = 'PROD_TEST_RESULT' when updating table PTST_RESULT
** 05/03/2008  ismaiime  ECPD-7762: Modify function summarizeStablePeriod to support for events with separate BS and WATER
** 10/03/2008  eizwanik  ECPD-7056: Modified many functions to include created_by/last_updated_by during inserts/updates
** 17/03/2008  rajarsar  ECPD-6167: Modified setWbiTestDefine, removeWbiTestDefine and added createGraphDefParameters and removeGraphDefParameters
** 06/05/2008  kaurrjes  ECPD-8122: Bug in ECDP_PERFORMANCE_TEST.
** 18/06/2008  embonhaf  ECPD-8622: Well attributes do not appear in prod test result datasection 7.
** 25/06/2008  ismaiime	 ECPD-8707  Modify procedures summarizeStablePeriod, auiSyncEqpmResult and auiSyncPtstResultTdev to add DAYTIME when inserting to EQPM_RESULT table.
** 27/06/2008  farhaann  ECPD-8939: Updated ORA number for error messages
** 18/09/2008  embonhaf  ECPD-9685: Modified acceptTestResult and Reject procedures, fixed revision info problem in pt10 and pt13 screen.
** 21/10/2008  ismaiime  ECPD-10140: Modify SummarizeStablePeriod() to include production_day when updating PTST_RESULT
** 23/10/2008  amirrasn  ECPD-9912: Modify procedures CalcDurationOfStablePeriod to update Nvl(lr_stable_period.duration, lr_stable_period.end_date - lr_stable_period.daytime) syntax
** 31/12/2008  sharawan  ECPD-10416:Replaced all references to EcDp_Type.pb_comp_number%TYPE with NUMBER in functions getDiluentStdRateDay, getPowerWaterStdRateDay.
** 19/03/2009  sharawan  ECPD-9433: Added checking for user access level in acceptTestResult, acceptTestResultNoAlloc, and rejectTestResult.
** 10/04/2009  leongsei  ECPD-6067: Modified function processTestDeviceSampleRates, checkLockInd, acceptTestResult, acceptTestResultNoAlloc,
**                                  rejectTestResult for local lock checking
** 15/05/2009  sharawan  ECPD-9433: Modified the added checking for user access level in acceptTestResult, acceptTestResultNoAlloc, and rejectTestResult.
** 18/05/2009  sharawan  ECPD-11594: Change the SQL statement to select the MAX value for multiple roles returned in acceptTestResult, acceptTestResultNoAlloc, and rejectTestResult.
** 18/08/2008  oonnnng   ECPD-11871: Added getDefaultTestDevice() function.
** 28/08/2009  leeeewei  ECPD-12385: Updated ORA error code from ORA-20554 to ORA-20227 and from ORA-20555 to ORA-20228 in acceptTestResult, acceptTestResultNoAlloc and rejectTestResult
** 24/09/2009  oonnnng   ECPD-12718: Add acceptSingleTestResult(), acceptSingleTestResultNoAlloc() , and rejectSingleTestResult() functions.
** 30/11/2009  leongsei  ECPD-11844: Modified function getMeterCode to improve performance
** 22/03/2010  ismaiime	 ECPD-13560: Modified fucntion AddPreprocessLog to substring the accumulated message p_missing_log to 30000. Then substring the message to 3000 before wrting to the PTST_RESULT.PREPROCESS_LOG
** 26/04/2010  madondin	 ECPD-14443: Update getGasStdRateDay(), getCondStdRateDay(), getWatStdRateDay()and getOilStdRateDay() "in the ELSE" to get latest well test.
** 22/07/2010  farhaann  ECPD-13407: Modified summarizeStablePeriod to update duration after click on 'Summarize' button
** 28/07/2010  madondin  ECPD-14607: Modified summarizestableperiod to update the test type in ptst_result table after click on 'Summarize' button
** 28/07/2010  madondin  ECPD-15382: Modified in function acceptTestResult, acceptTestResultNoAlloc and rejectTestResult to include last_updated_date
** 21/10/20101 madondin	 ECPD-15004: Modified in function summarizeEvent Summarize event bsw functionality improvement
** 26/10/2010  Leongwen  ECPD-15122: PT well fluid rate estimation should also work for user exit methods
** 28/01/2011  madondin  ECPD-15606: Modified function saveWellTargetResult to convert the estimated value before save
** 24/02/2011  musthram  ECPD-16622: Modified function acceptSingleTestResult to add validation of Valid From Date/Time for accept,use in alloc
** 29/07/2011  abdulmaw	 ECPD-17951: Modified function acceptSingleTestResult, acceptSingleTestResultNoAlloc and rejectSingleTestResult to include last_updated_date
** 21-11-2011  leongwen  ECPD-18170: Modified getGasStdRateDay(), getCondStdRateDay(), getOilStdRateDay(), getWatStdRateDay() to support liquid curve phase calc.
** 21-12-2011  madondin  ECPD-19446: Added new function findLiqConstantC2
** 10-02-2012  limmmchu  ECPD-19910: Modified function auiUpdateRecordStatus() to update last_updated_date
** 27-06-2012  limmmchu  ECPD-21379: Modified function PreProcessEqpmResultRow() to support GP2 well
** 16-10-2012  genasdev  ECPD-17464: Added parameter well_test_reason to auisyncpwelresult, auisyncptstresult and aiSyncPwelResultFromPwel.
** 27-11-2012  limmmchu  ECPD-22621: Modified function getWatStdRateDay().
** 21-01-2013  musthram  ECPD-23154: Added new function countChildEvent and deleteChildEvent
** 13-03-2013  wonggkai  ECPD-23515: Updated createGraphDefParameters.
** 30-04-2013  makkkkam	 ECPD-24066: Added procedure stablePeriodPlotParameterCount
** 20-05-2013  limmmchu  ECPD-24146: Modified processTestDeviceSampleRates
** 14-06-2013  musthram  ECPD-24533: Modified function getGasStdRateDay and getWatStdRateDay
** 19-08-2013  musthram  ECPD-24533: Modified function getGasLiftStdRateDay, getCondStdRateDay, getOilStdRateDay, getWatStdRateDay and getGasStdRateDay
** 09-10-2013  musthram  ECPD-25686: Modified function PreProcessEqpmResultRow
** 22.11.2013  kumarsur  ECPD-26104: Modified getGasLiftStdRateDay function on getCurveRate.
** 02.12.2013  makkkkam  ECPD-25991: Modified function using getCurveRate due to extra parameters
*************************************************************************************************/


CURSOR c_defined_objects(cp_test_no VARCHAR2, cp_class_name VARCHAR2) IS
SELECT object_id
FROM ptst_object
WHERE test_no = cp_test_no
AND class_name = cp_class_name;


CURSOR c_trend_curve(cp_object_id VARCHAR2, cp_daytime DATE, cp_trend_parameter VARCHAR2, cp_trend_method VARCHAR2) IS
  SELECT tc.c0, tc.c1, tc.c2
  FROM trend_curve tc
  WHERE tc.object_id = cp_object_id
    AND tc.daytime = cp_daytime
    AND tc.trend_parameter = cp_trend_parameter
    AND tc.trend_method = cp_trend_method;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : showDefinedTestDevices
-- Description    : Returns a concatenated string of names for test device objects defined in a performance test.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions: ec_ptst_definition.daytime, ec_eqpm_version.name
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION showDefinedTestDevices(p_test_no NUMBER) RETURN VARCHAR2
--</EC-DOC>
IS

lv2_result_string VARCHAR2(1000);
ld_test_date DATE;
lv2_name eqpm_version.name%TYPE;

BEGIN

   ld_test_date := ec_ptst_definition.daytime(p_test_no);

   IF ld_test_date IS NOT NULL THEN

      FOR cur_rec IN c_defined_objects(p_test_no, 'TEST_DEVICE') LOOP

         lv2_name := ec_eqpm_version.name(cur_rec.object_id, ld_test_date,'<=');

         IF c_defined_objects%ROWCOUNT = 1 THEN
            lv2_result_string := lv2_name;
         ELSE
            lv2_result_string := lv2_result_string || ', ' || lv2_name;
         END IF;

      END LOOP;

   END IF;

   RETURN lv2_result_string;

END showDefinedTestDevices;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : showDefinedFlowlines
-- Description    : Returns a concatenated string of names for flowline objects defined in a performance test.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions: ec_ptst_definition.daytime, ec_flwl_version.name
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION showDefinedFlowlines(p_test_no NUMBER) RETURN VARCHAR2
--</EC-DOC>
IS

lv2_result_string VARCHAR2(1000);
ld_test_date DATE;
lv2_name flwl_version.name%TYPE;

BEGIN

   ld_test_date := ec_ptst_definition.daytime(p_test_no);

   IF ld_test_date IS NOT NULL THEN

      FOR cur_rec IN c_defined_objects(p_test_no, 'FLOWLINE') LOOP

         lv2_name := ec_flwl_version.name(cur_rec.object_id, ld_test_date,'<=');

         IF c_defined_objects%ROWCOUNT = 1 THEN
            lv2_result_string := lv2_name;
         ELSE
            lv2_result_string := lv2_result_string || ', ' || lv2_name;
         END IF;

      END LOOP;

   END IF;

   RETURN lv2_result_string;

END showDefinedFlowlines;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : showDefinedWells
-- Description    : Returns a concatenated string of names for well objects defined in a performance test.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions: ec_ptst_definition.daytime, ec_well_version.name
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION showDefinedWells(p_test_no NUMBER) RETURN VARCHAR2
--</EC-DOC>
IS

lv2_result_string VARCHAR2(1000);
ld_test_date DATE;
lv2_name well_version.name%TYPE;

BEGIN

   ld_test_date := ec_ptst_definition.daytime(p_test_no);

   IF ld_test_date IS NOT NULL THEN

      FOR cur_rec IN c_defined_objects(p_test_no, 'WELL') LOOP

         lv2_name := ec_well_version.name(cur_rec.object_id, ld_test_date,'<=');

         IF c_defined_objects%ROWCOUNT = 1 THEN
            lv2_result_string := lv2_name;
         ELSE
            lv2_result_string := lv2_result_string || ', ' || lv2_name;
         END IF;

      END LOOP;

   END IF;

   RETURN lv2_result_string;

END showDefinedWells;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : CalcDurationOfStablePeriod
-- Description    :
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions: ec_ptst_result.row_by_pk(
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION CalcDurationOfStablePeriod(p_result_no NUMBER) RETURN NUMBER
--</EC-DOC>
IS

ln_ret_val_hrs NUMBER;
lr_stable_period ptst_result%ROWTYPE;
BEGIN

   lr_stable_period := ec_ptst_result.row_by_pk(p_result_no);

   ln_ret_val_hrs := Nvl(lr_stable_period.duration, (lr_stable_period.end_date - lr_stable_period.daytime) * 24);

   RETURN ln_ret_val_hrs;

END CalcDurationOfStablePeriod;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTestDeviceIDFromResult
-- Description    : Returns the test device object_id for the given result.
--
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : eqpm_result
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Only one test device for each test are allowed, returns null if it exists several test devices.
--
---------------------------------------------------------------------------------------------------
FUNCTION getTestDeviceIDFromResult(
               p_result_no    NUMBER)
RETURN VARCHAR2
--</EC-DOC>
IS

   CURSOR c_td_result IS
    SELECT object_id
    FROM eqpm_result
    WHERE result_no = p_result_no;

    lv2_td_id       eqpm_result.object_id%TYPE;

BEGIN

   FOR curTestDevice IN c_td_result LOOP
      lv2_td_id := curTestDevice.object_id;

      IF c_td_result%ROWCOUNT > 1 THEN
         lv2_td_id := NULL;
      END IF;

   END LOOP;

   RETURN lv2_td_id;

END getTestDeviceIDFromResult;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : showTestDevicesWithResult
-- Description    : Returns a concatenated string of names for test device objects with available records
--                  for the given result.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : eqpm_result
--
--
--
-- Using functions: ec_ptst_result.daytime, ec_eqpm_version.name
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION showTestDevicesWithResult(p_result_no NUMBER) RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_td_result(cp_result_no NUMBER) IS
SELECT object_id
FROM eqpm_result
WHERE result_no = cp_result_no;

lv2_result_string VARCHAR2(1000);
ld_test_date DATE;
lv2_name eqpm_version.name%TYPE;

BEGIN

   ld_test_date := ec_ptst_result.daytime(p_result_no);

   IF ld_test_date IS NOT NULL THEN

      FOR cur_rec IN c_td_result(p_result_no) LOOP

         lv2_name := ec_eqpm_version.name(cur_rec.object_id, ld_test_date,'<=');

         IF c_td_result%ROWCOUNT = 1 THEN
            lv2_result_string := lv2_name;
         ELSE
            lv2_result_string := lv2_result_string || ', ' || lv2_name;
         END IF;

      END LOOP;

   END IF;

   RETURN lv2_result_string;

END showTestDevicesWithResult;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : showFlowlinesWithResult
-- Description    : Returns a concatenated string of names for flowline objects with available records
--                  for the given result.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : pflw_result
--
--
--
-- Using functions: ec_ptst_result.daytime, ec_flwl_version.name
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION showFlowlinesWithResult(p_result_no NUMBER) RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_flwl_result(cp_result_no NUMBER) IS
SELECT object_id
FROM pflw_result
WHERE result_no = cp_result_no;

lv2_result_string VARCHAR2(1000);
ld_test_date DATE;
lv2_name flwl_version.name%TYPE;

BEGIN

   ld_test_date := ec_ptst_result.daytime(p_result_no);

   IF ld_test_date IS NOT NULL THEN

      FOR cur_rec IN c_flwl_result(p_result_no) LOOP

         lv2_name := ec_flwl_version.name(cur_rec.object_id, ld_test_date,'<=');

         IF c_flwl_result%ROWCOUNT = 1 THEN
            lv2_result_string := lv2_name;
         ELSE
            lv2_result_string := lv2_result_string || ', ' || lv2_name;
         END IF;

      END LOOP;

   END IF;

   RETURN lv2_result_string;

END showFlowlinesWithResult;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : showWellsWithResult
-- Description    : Returns a concatenated string of names for well objects with available records
--                  for the given result.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : pwel_result
--
--
--
-- Using functions: ec_ptst_result.daytime, ec_well_version.name
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION showWellsWithResult(p_result_no NUMBER) RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_well_result(cp_result_no NUMBER) IS
SELECT object_id
FROM pwel_result
WHERE result_no = cp_result_no;

lv2_result_string VARCHAR2(1000);
ld_test_date DATE;
lv2_name well_version.name%TYPE;

BEGIN

   ld_test_date := ec_ptst_result.daytime(p_result_no);

   IF ld_test_date IS NOT NULL THEN

      FOR cur_rec IN c_well_result(p_result_no) LOOP

         lv2_name := ec_well_version.name(cur_rec.object_id, ld_test_date,'<=');

         IF c_well_result%ROWCOUNT = 1 THEN
            lv2_result_string := lv2_name;
         ELSE
            lv2_result_string := lv2_result_string || ', ' || lv2_name;
         END IF;

      END LOOP;

   END IF;

   RETURN lv2_result_string;

END showWellsWithResult;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSampleDataClassName
-- Description    : Retrieves the associated sample data class name for a given object when
--                  populating the test object popup in PT-0006 data sections 3,5 and 7.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PTST_OBJECT
--					PTST_DEFINITION
--
--
-- Using functions: ec_eqpm_version.instrumentation_type
--					ec_flwl_version.instrumentation_type
--					ec_well_version.instrumentation_type
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSampleDataClassName(p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2
--</EC-DOC>
IS

	lv2_inst_type 		VARCHAR2(32);
	lv2_return_value 	VARCHAR2(32);
	lv2_class_name		VARCHAR2(32) := ecdp_objects.GetObjClassName(p_object_id);

BEGIN
	IF lv2_class_name = 'TEST_DEVICE' THEN
		lv2_inst_type := ec_eqpm_version.instrumentation_type(p_object_id,p_daytime,'<=');
		IF lv2_inst_type = '1' THEN
			lv2_return_value := 'TDEV_SAMPLE_1';
		END IF;
		IF lv2_inst_type = '2' THEN
			lv2_return_value := 'TDEV_SAMPLE_2';
		END IF;
		IF lv2_inst_type = '3' THEN
			lv2_return_value := 'TDEV_SAMPLE_3';
		END IF;
	END IF;
	IF lv2_class_name = 'FLOWLINE' THEN
		lv2_inst_type := ec_flwl_version.instrumentation_type(p_object_id,p_daytime,'<=');
		IF lv2_inst_type = '1' THEN
			lv2_return_value := 'PFLW_SAMPLE_1';
		END IF;
		IF lv2_inst_type = '2' THEN
			lv2_return_value := 'PFLW_SAMPLE_2';
		END IF;
		IF lv2_inst_type = '3' THEN
			lv2_return_value := 'PFLW_SAMPLE_3';
		END IF;
	END IF;
	IF lv2_class_name = 'WELL' THEN
		lv2_inst_type := ec_well_version.instrumentation_type(p_object_id,p_daytime,'<=');
		IF lv2_inst_type = '1' THEN
			lv2_return_value := 'PWEL_SAMPLE_1';
		END IF;
		IF lv2_inst_type = '2' THEN
			lv2_return_value := 'PWEL_SAMPLE_2';
		END IF;
		IF lv2_inst_type = '3' THEN
			lv2_return_value := 'PWEL_SAMPLE_3';
		END IF;
	END IF;
	IF lv2_class_name = 'WELL_BORE_INTERVAL' THEN
    lv2_return_value := 'WBI_SAMPLE';
	END IF;
   RETURN lv2_return_value;

END getSampleDataClassName;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSampleDataClassName
-- Description    : Retrieves the associated sample data class name for a given object when
--                  populating the test object popup in PT-0006 data sections 3,5 and 7.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PTST_OBJECT
--					PTST_DEFINITION
--
--
-- Using functions: ec_eqpm_version.instrumentation_type
--					ec_flwl_version.instrumentation_type
--					ec_well_version.instrumentation_type
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getResultDataClassName(p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2
--</EC-DOC>
IS

	lv2_inst_type 		VARCHAR2(32);
	lv2_return_value 	VARCHAR2(32);
	lv2_class_name		VARCHAR2(32) := ecdp_objects.GetObjClassName(p_object_id);

BEGIN
	IF lv2_class_name = 'TEST_DEVICE' THEN
		lv2_inst_type := ec_eqpm_version.instrumentation_type(p_object_id,p_daytime,'<=');
		IF lv2_inst_type = '1' THEN
			lv2_return_value := 'TDEV_RESULT_1';
		END IF;
		IF lv2_inst_type = '2' THEN
			lv2_return_value := 'TDEV_RESULT_2';
		END IF;
		IF lv2_inst_type = '3' THEN
			lv2_return_value := 'TDEV_RESULT_3';
		END IF;
	END IF;
	IF lv2_class_name = 'FLOWLINE' THEN
		lv2_inst_type := ec_flwl_version.instrumentation_type(p_object_id,p_daytime,'<=');
		IF lv2_inst_type = '1' THEN
			lv2_return_value := 'PFLW_RESULT_1';
		END IF;
		IF lv2_inst_type = '2' THEN
			lv2_return_value := 'PFLW_RESULT_2';
		END IF;
		IF lv2_inst_type = '3' THEN
			lv2_return_value := 'PFLW_RESULT_3';
		END IF;
	END IF;
	IF lv2_class_name = 'WELL' THEN
		lv2_inst_type := ec_well_version.instrumentation_type(p_object_id,p_daytime,'<=');
		IF lv2_inst_type = '1' THEN
			lv2_return_value := 'PWEL_RESULT_1';
		END IF;
		IF lv2_inst_type = '2' THEN
			lv2_return_value := 'PWEL_RESULT_2';
		END IF;
		IF lv2_inst_type = '3' THEN
			lv2_return_value := 'PWEL_RESULT_3';
		END IF;
	END IF;
	IF lv2_class_name = 'WELL_BORE_INTERVAL' THEN
    lv2_return_value := 'WBI_RESULT';
	END IF;

   RETURN lv2_return_value;
END getResultDataClassName;

---------------------------------------------------------------------------------------------------
-- Function       : getLastValidWellResult
-- Description    :
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: EC_PWEL_RESULT.ROW_BY_PK, getLastValidWellResultNo
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getLastValidWellResult(p_object_id VARCHAR2, p_daytime DATE) RETURN pwel_result%ROWTYPE
--</EC-DOC>
IS

lr_pwel_result pwel_result%ROWTYPE;

BEGIN

   lr_pwel_result := ec_pwel_result.row_by_pk(p_object_id, EcDp_Performance_Test.getLastValidWellResultNo(p_object_id, p_daytime));

   RETURN lr_pwel_result;

END getLastValidWellResult;

---------------------------------------------------------------------------------------------------
-- Function       : getLastValidWellResultNo
-- Description    :
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PWEL_RESULT, PTST_RESULT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getLastValidWellResultNo(
            p_object_id    VARCHAR2,
            p_daytime      DATE)
RETURN NUMBER
IS

CURSOR c_valid_rec(cp_object_id VARCHAR2, cp_daytime DATE) IS
SELECT p1.result_no
FROM pwel_result p1
WHERE p1.object_id = cp_object_id
AND p1.status = 'ACCEPTED'
AND p1.use_calc = 'Y'
AND p1.primary_ind = 'Y'
AND p1.valid_from_date =
(SELECT max(p2.valid_from_date)
FROM pwel_result p2
WHERE p2.object_id = cp_object_id
AND p2.status = 'ACCEPTED'
AND p2.use_calc = 'Y'
AND p2.primary_ind = 'Y'
AND p2.valid_from_date <= cp_daytime)
;

ln_result_no NUMBER;

BEGIN

FOR curRec IN c_valid_rec(p_object_id, p_daytime) LOOP
  ln_result_no := curRec.result_no;
END LOOP;

RETURN ln_result_no;

END getLastValidWellResultNo;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : processTestDeviceSampleRates
-- Description    : Processes rate figures on every sample record for a given test device and period.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : EQPM_SAMPLE, PTST_OBJECT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : p_from_daytime = p_to_daytime >> process a single record
--                  p_to_daytime IS NULL >> process from daytime up to date.
--
---------------------------------------------------------------------------------------------------
PROCEDURE processTestDeviceSampleRates(p_object_id VARCHAR2, p_from_daytime DATE, p_to_daytime DATE, p_user VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

ld_NextTestStart DATE;

BEGIN

  -- lock check, if samples are in locked period update is not allowed
  EcDp_month_lock.validatePeriodForLockOverlap('UPDATING', p_from_daytime, p_to_daytime,' Running processTestDeviceSampleRates, direct lock detected', p_object_id);

  IF p_to_daytime IS NOT NULL THEN
     ld_NextTestStart := p_to_daytime;
  ELSE
     select (min(pd.daytime) - 1/288) into ld_NextTestStart from ptst_definition pd, ptst_object po where po.test_no = pd.test_no and po.object_id = p_object_id and pd.daytime > p_from_daytime;
  END IF;

  UPDATE EQPM_SAMPLE
  SET OIL_OUT_RATE_RAW = NULL, GAS_OUT_RATE_RAW = NULL, WATER_OUT_RATE_RAW = NULL, LAST_UPDATED_BY = Nvl(p_user,USER)
  WHERE OBJECT_ID = p_object_id
  AND DAYTIME >= p_from_daytime
  AND DAYTIME <= nvl(ld_NextTestStart, sysdate);

END processTestDeviceSampleRates;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : SetRecordStatusByStatus
-- Description    : Updates record status on PT-tables for all records related to a certain production
--                  test result when changing the status on PTST_RESULT.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : ptst_result, pwel_result, pflw_result, eqpm_result, ptst_definition, ptst_object, ptst_event
--                  pwel_sample, pflw_sample, eqpm_sample
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE SetRecordStatusByStatus(p_result_no NUMBER, p_user VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

  lv_record_status VARCHAR2(16);
  lr_result ptst_result%ROWTYPE;
  n_lock_columns       EcDp_Month_lock.column_list;


BEGIN

   lr_result := ec_ptst_result.row_by_pk(p_result_no);

   -- Lock test
   EcDp_month_lock.AddParameterToList(n_lock_columns,'CLASS_NAME','PROD_TEST_RESULT','STRING',NULL,NULL,NULL);
   EcDp_month_lock.AddParameterToList(n_lock_columns,'TABLE_NAME','PTST_RESULT','STRING',NULL,NULL,NULL);
   EcDp_month_lock.AddParameterToList(n_lock_columns,'RESULT_NO','RESULT_NO','NUMBER','Y','N',anydata.ConvertNumber(lr_result.RESULT_NO));
   EcDp_month_lock.AddParameterToList(n_lock_columns,'VALID_FROM_DATE','VALID_FROM_DATE','DATE','N','N',anydata.Convertdate(lr_result.VALID_FROM_DATE));
   EcDp_month_lock.AddParameterToList(n_lock_columns,'STATUS','STATUS','STRING','N','N',anydata.ConvertVarChar2(lr_result.STATUS));


  EcDp_Performance_lock.CheckLockProductionTest('UPDATING',n_lock_columns,n_lock_columns);



   lv_record_status := ec_prosty_codes.alt_code(lr_result.status, 'WELL_TEST_STATUS');

   IF lv_record_status IS NOT NULL THEN

      UPDATE ptst_result
      SET record_status = lv_record_status,
      	  last_updated_by = Nvl(p_user,USER)
      WHERE result_no = p_result_no;

      UPDATE pwel_result
      SET record_status = lv_record_status,
      	  last_updated_by = Nvl(p_user,USER)
      WHERE result_no = p_result_no;

      UPDATE pflw_result
      SET record_status = lv_record_status,
      	  last_updated_by = Nvl(p_user,USER)
      WHERE result_no = p_result_no;

      UPDATE eqpm_result
      SET record_status = lv_record_status,
      	  last_updated_by = Nvl(p_user,USER)
      WHERE result_no = p_result_no;

      IF lr_result.test_no IS NOT NULL THEN

         UPDATE ptst_definition
         SET record_status = lv_record_status,
      	  	 last_updated_by = Nvl(p_user,USER)
         WHERE test_no = lr_result.test_no;

         UPDATE ptst_object
         SET record_status = lv_record_status,
      	  	 last_updated_by = Nvl(p_user,USER)
         WHERE test_no = lr_result.test_no;

         UPDATE ptst_event
         SET record_status = lv_record_status,
      	     last_updated_by = Nvl(p_user,USER)
         WHERE test_no = lr_result.test_no;

         IF lr_result.summarised_ind = 'Y' THEN

            FOR cur_pwel_rec IN c_defined_objects(lr_result.test_no, 'WELL') LOOP

               UPDATE pwel_sample
               SET record_status = lv_record_status,
      	 		   last_updated_by = Nvl(p_user,USER)
               WHERE object_id = cur_pwel_rec.object_id
               AND daytime BETWEEN lr_result.daytime AND lr_result.end_date;

            END LOOP;

            FOR cur_pflw_rec IN c_defined_objects(lr_result.test_no, 'FLOWLINE') LOOP

               UPDATE pflw_sample
               SET record_status = lv_record_status,
      	  		   last_updated_by = Nvl(p_user,USER)
               WHERE object_id = cur_pflw_rec.object_id
               AND daytime BETWEEN lr_result.daytime AND lr_result.end_date;

            END LOOP;

            FOR cur_eqpm_rec IN c_defined_objects(lr_result.test_no, 'TEST_DEVICE') LOOP

               UPDATE eqpm_sample
               SET record_status = lv_record_status,
      	  		   last_updated_by = Nvl(p_user,USER)
               WHERE object_id = cur_eqpm_rec.object_id
               AND daytime BETWEEN lr_result.daytime AND lr_result.end_date;

            END LOOP;

         END IF;

      END IF;
   END IF;

END SetRecordStatusByStatus;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : auiUpdateRecordStatus
-- Description    : Similar to procedure above, but updates with specified record status value
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : pwel_result, pflw_result, eqpm_result, wbi_result
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE auiUpdateRecordStatus(p_result_no NUMBER, p_new_record_status VARCHAR2, p_user VARCHAR2 DEFAULT NULL)
IS
	lv2_last_update_date VARCHAR2(20);
BEGIN
	lv2_last_update_date := to_char(EcDp_Date_Time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS');

      UPDATE pwel_result
      SET record_status = p_new_record_status,
      	  last_updated_by = Nvl(p_user,USER),
		  last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS')
      WHERE result_no = p_result_no;

      UPDATE pflw_result
      SET record_status = p_new_record_status,
      	  last_updated_by = Nvl(p_user,USER),
		  last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS')
      WHERE result_no = p_result_no;

      UPDATE eqpm_result
      SET record_status = p_new_record_status,
      	  last_updated_by = Nvl(p_user,USER),
		  last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS')
      WHERE result_no = p_result_no;

      UPDATE wbi_result
      SET record_status = p_new_record_status,
      	  last_updated_by = Nvl(p_user,USER),
		  last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS')
      WHERE result_no = p_result_no;

	  END auiUpdateRecordStatus;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCurveRate
-- Description    : Returns theoretical rate from performance curve
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: ECDP_WELL_THEORETICAL.GETPERFORMANCECURVEID
--                  EC_PERFORMANCE_CURVE.CURVE_PARAMETER_CODE
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION summarizeEvent(p_test_no NUMBER,
						p_object_id VARCHAR2,
						p_start_date DATE,
						p_end_date DATE,
						p_event_type VARCHAR2,
						p_target_column VARCHAR2,
						p_result_data_class VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
	CURSOR c_tdev_out_bsw (cp_test_no NUMBER, cp_object_id VARCHAR2, cp_start_date DATE, cp_end_date DATE, cp_event_type VARCHAR2) IS
	SELECT quantity, unit
	FROM ptst_event
	WHERE test_no = cp_test_no
	AND object_id = cp_object_id
	AND use_in_result = 'Y'
	AND event_type = cp_event_type
	AND daytime >= cp_start_date
	AND daytime < cp_end_date;

  	ln_count 		NUMBER	:=	0;
 	ln_event_total 	NUMBER	:=	0;
 	ln_return_val 	NUMBER	:=	NULL;
 	ln_conv_val 	NUMBER	:=	0;
	lv2_target_UOM	VARCHAR2(32);
	lv2_attribute	VARCHAR2(32);
	ld_TestStart     DATE;

	BEGIN
	DELETE FROM t_temptext WHERE id = 'summarizeEvent';
	SELECT attribute_name INTO lv2_attribute FROM class_attr_db_mapping m WHERE m.class_name = p_result_data_class AND m.db_sql_syntax = p_target_column;
	lv2_target_uom := ecdp_classmeta.getUomCode(p_result_data_class,lv2_attribute);
	--if lv2_target_uom was a measurement type
	lv2_target_uom := ecdp_unit.getunitfromlogical(lv2_target_uom);
	--ecdp_dynsql.writetemptext('summarizeEvent','Have found the following data unit ' || lv2_target_uom || ' for column ' || p_target_column || ' in eqpm_sample and object ' || p_object_id);
	FOR c_event IN c_tdev_out_bsw (p_test_no, p_object_id, p_start_date, p_end_date, p_event_type) LOOP
		--ecdp_dynsql.writetemptext('summarizeEvent','Value in unit ' || c_event.unit || ' : ' || c_event.quantity);
		ln_conv_val := ecdp_unit.convertValue(c_event.quantity,c_event.unit, lv2_target_uom);
		--ecdp_dynsql.writetemptext('summarizeEvent','Value converted to unit ' || lv2_target_uom || ' : ' || ln_conv_val);
		ln_event_total := ln_event_total + ln_conv_val;
		ln_count := ln_count + 1;
	END LOOP;
	IF ln_count > 0 THEN
		ln_return_val := ln_event_total /  ln_count;
	ELSE
		ld_TestStart := ec_ptst_definition.daytime(p_test_no);
		FOR c_event IN c_tdev_out_bsw (p_test_no, p_object_id, ld_TestStart, ld_TestStart + (5/1440), p_event_type) LOOP
		  ln_conv_val := ecdp_unit.convertValue(c_event.quantity,c_event.unit, lv2_target_uom);
		  ln_event_total := ln_event_total + ln_conv_val;
		  ln_count := ln_count + 1;
		END LOOP;
		IF ln_count > 0 THEN
		  ln_return_val := ln_event_total /  ln_count;
		END IF;
	END IF;
	--ecdp_dynsql.writetemptext('summarizeEvent','Returning value ' || ln_return_val);
  	RETURN ln_return_val;
END summarizeEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : SummarizeStablePeriod
-- Description    : Traverses each equal data column in <object>_sample and corresponding
--					<object>_result table, and aggregates an average value of the sample data
--					and updates the result table column
--
-- Preconditions  : Valid record in ptst_result with both daytime and end_date
-- Postconditions : Record in result table created for result number taken as in parameter and
--					all objects related to that result number
--
-- Using tables   : PTST_RESULT
--                  COLS
--                  PTST_OBJECT
--					EQPM_SAMPLE
--					EQPM_RESULT
--					PFLW_SAMPLE
--					PFLW_RESULT
--					PWEL_SAMPLE
--					PWEL_RESULT
--
-- Using functions: EcDp_Utilities.executeStatement
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE summarizeStablePeriod(p_result_no NUMBER, p_last_updated_by    VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS
  ln_test_no 			       NUMBER;
  ln_well_count		       NUMBER := 0;
  ln_fromcolcount 	     NUMBER;
  ln_colcount 		       NUMBER;
  ln_event_value1             NUMBER;
  ln_event_value2             NUMBER;
  ln_event_value3             NUMBER;
  ln_event_value4             NUMBER;

	lv2_sample_table 		   VARCHAR2(32);
	lv2_result_table 		   VARCHAR2(32);
	lv2_result_data_class  VARCHAR2(32);
	lv2_single_well_id		 VARCHAR2(32);
	lv2_test_type 			 VARCHAR2(32);
	lv2_updatesql		       VARCHAR2(32000);
	lv2_setsql			       VARCHAR2(32000);
	lv2_result			       VARCHAR2(32000);

	ld_startdate		       DATE;
	ld_enddate		         DATE;
  ld_valid_from_date     DATE;
  lv2_status             PTST_RESULT.STATUS%TYPE;
  n_lock_columns          EcDp_Month_lock.column_list;
  lb_is_webo_interval_obj BOOLEAN;
  lr_ptst_result          ptst_result%ROWTYPE;
  lr_eqpm_result          eqpm_result%ROWTYPE;

	CURSOR c_ptst_object (cp_test_no NUMBER) IS	SELECT class_name, object_id FROM ptst_object WHERE test_no = cp_test_no;
	CURSOR c_column (st_table VARCHAR2, rt_table VARCHAR2) IS SELECT column_name FROM cols WHERE table_name = st_table AND data_type = 'NUMBER' AND column_name NOT IN ('REV_NO','RESULT_NO') INTERSECT SELECT column_name FROM cols WHERE table_name = rt_table AND data_type = 'NUMBER' AND column_name NOT IN ('REV_NO','RESULT_NO');
	CURSOR c_nullcolumn (rt_table VARCHAR2) IS SELECT column_name FROM cols WHERE table_name = rt_table AND data_type = 'NUMBER' AND column_name NOT IN ('REV_NO','RESULT_NO');
	CURSOR c_result IS SELECT test_no, daytime, end_date, valid_from_date, status, duration, result_no FROM ptst_result WHERE result_no = p_result_no;

BEGIN
	--DELETE FROM t_temptext WHERE id = 'summarizeStablePeriod';
	--COMMIT;
  	FOR result IN c_result LOOP
  		ln_test_no := result.test_no;
  		ld_startdate := result.daytime;
  		ld_enddate := result.end_date;
  		ld_valid_from_date := result.valid_from_date;
  		lv2_status := result.status;

  		IF result.daytime IS NOT NULL AND result.end_date IS NOT NULL THEN
       result.duration := (result.end_date - result.daytime)*24;
      END IF;

      UPDATE ptst_result
      SET
      end_date               = result.end_date
      ,duration              = trunc(result.duration, 2)   -- trunc the duration to 2 decimals
      ,LAST_UPDATED_BY       = Nvl(p_LAST_UPDATED_BY,USER)
      ,LAST_UPDATED_DATE     = Nvl(lr_eqpm_result.LAST_UPDATED_DATE, EcDp_Date_Time.getCurrentSysdate)
      WHERE result_no = result.result_no
      AND   daytime = result.daytime;

  	END LOOP;

	lv2_test_type := ec_ptst_definition.test_type(ln_test_no);

     -- Lock test
   EcDp_month_lock.AddParameterToList(n_lock_columns,'CLASS_NAME','PROD_TEST_RESULT','STRING',NULL,NULL,NULL);
   EcDp_month_lock.AddParameterToList(n_lock_columns,'TABLE_NAME','PTST_RESULT','STRING',NULL,NULL,NULL);
   EcDp_month_lock.AddParameterToList(n_lock_columns,'RESULT_NO','RESULT_NO','NUMBER','Y','N',anydata.ConvertNumber(p_RESULT_NO));
   EcDp_month_lock.AddParameterToList(n_lock_columns,'VALID_FROM_DATE','VALID_FROM_DATE','DATE','N','N',anydata.Convertdate(ld_VALID_FROM_DATE));
   EcDp_month_lock.AddParameterToList(n_lock_columns,'STATUS','STATUS','STRING','N','N',anydata.ConvertVarChar2(lv2_STATUS));

   EcDp_Performance_lock.CheckLockProductionTest('UPDATING',n_lock_columns,n_lock_columns);



   	IF ld_enddate IS NULL THEN
		RAISE_APPLICATION_ERROR(-20512,'Cannot perform calculation on result with no end date');
   	END IF;
	--ecdp_dynsql.writetemptext('summarizeStablePeriod','Test no ' || ln_test_no || ' From Date ' || ld_startdate || ' to date ' || ld_enddate);
	DELETE FROM eqpm_result WHERE result_no = p_result_no;
	DELETE FROM pflw_result WHERE result_no = p_result_no;
	DELETE FROM pwel_result WHERE result_no = p_result_no;
  DELETE FROM wbi_result WHERE result_no = p_result_no;

  FOR row IN c_ptst_object(ln_test_no) LOOP
  		--ecdp_dynsql.writetemptext('summarizeStablePeriod','Object with id: ' || row.object_id || ' is a ' || row.class_name || ' object');
  		lv2_result_data_class := getResultDataClassName(row.object_id, ld_startdate);
		IF row.class_name = 'TEST_DEVICE' THEN
			lv2_sample_table := 'EQPM_SAMPLE';
			lv2_result_table := 'EQPM_RESULT';
			INSERT INTO eqpm_result (object_id, result_no, daytime, data_class_name) VALUES (row.object_id, p_result_no, ld_startdate, lv2_result_data_class);
		END IF;
		IF row.class_name = 'FLOWLINE' THEN
			lv2_sample_table := 'PFLW_SAMPLE';
			lv2_result_table := 'PFLW_RESULT';
			INSERT INTO pflw_result (object_id, result_no, data_class_name) VALUES (row.object_id, p_result_no, lv2_result_data_class);
		END IF;
		IF row.class_name = 'WELL' THEN
			lv2_sample_table := 'PWEL_SAMPLE';
			lv2_result_table := 'PWEL_RESULT';
			INSERT INTO pwel_result (object_id, result_no, data_class_name, daytime, end_date, valid_from_date, status) VALUES (row.object_id, p_result_no, lv2_result_data_class, ld_startdate, ld_enddate, ld_valid_from_date, lv2_status);
			ln_well_count := ln_well_count + 1;
			IF ln_well_count = 1 THEN
				lv2_single_well_id := row.object_id;
			END IF;
		END IF;
    IF row.class_name = 'WELL_BORE_INTERVAL' THEN
    	lv2_sample_table := 'WBI_SAMPLE';
    	lv2_result_table := 'WBI_RESULT';
      lb_is_webo_interval_obj := TRUE;
    	INSERT INTO wbi_result (object_id, result_no) VALUES (row.object_id, p_result_no);
    ELSE
      lb_is_webo_interval_obj := FALSE;
    END IF;
		lv2_setsql := 'SET ';
		ln_colcount := 0;
		FOR c IN c_column(lv2_sample_table, lv2_result_table) LOOP
			--Have to split updates in order to be able to execute them. Why?
			IF MOD(ln_colcount,5) = 0 THEN
				lv2_setsql := lv2_setsql || ' rt.' || c.column_name || ' = (SELECT AVG(st.' || c.column_name || ') FROM ' || lv2_sample_table || ' st WHERE st.OBJECT_ID = ''' || row.object_id || ''' AND st.daytime >= to_date('''||to_char(ld_startDate,'yyyy-mm-dd HH24:MI:SS')||''',''yyyy-mm-dd HH24:MI:SS'') AND st.daytime < to_date('''||to_char(ld_endDate,'yyyy-mm-dd HH24:MI:SS')||''',''yyyy-mm-dd HH24:MI:SS'')) ';
			ELSE
				lv2_setsql := lv2_setsql || ', rt.' || c.column_name || ' = (SELECT AVG(st.' || c.column_name || ') FROM ' || lv2_sample_table || ' st WHERE st.OBJECT_ID = ''' || row.object_id || ''' AND st.daytime >= to_date('''||to_char(ld_startDate,'yyyy-mm-dd HH24:MI:SS')||''',''yyyy-mm-dd HH24:MI:SS'') AND st.daytime < to_date('''||to_char(ld_endDate,'yyyy-mm-dd HH24:MI:SS')||''',''yyyy-mm-dd HH24:MI:SS'')) ';
			END IF;
			IF MOD(ln_colcount,5) = 4 THEN
				ln_fromcolcount := ln_colcount - 4;
        IF lb_is_webo_interval_obj THEN
          lv2_updatesql :=  'UPDATE ' || lv2_result_table || ' rt ' || lv2_setsql || ' WHERE rt.object_id = ''' || row.object_id || ''' AND rt.result_no = ' || p_result_no;
        ELSE
          lv2_updatesql :=  'UPDATE ' || lv2_result_table || ' rt ' || lv2_setsql || ' WHERE rt.object_id = ''' || row.object_id || ''' AND rt.data_class_name = ''' || lv2_result_data_class || ''' AND rt.result_no = ' || p_result_no;
        END IF;
				--ecdp_dynsql.writetemptext('summarizeStablePeriod','Update on ' || lv2_result_table || ' from column ' || ln_fromcolcount || ' to columns ' || ln_colcount);
				--ecdp_dynsql.writetemptext('summarizeStablePeriod',lv2_updatesql);
				lv2_result := EcDp_Utilities.executeStatement(lv2_updatesql);
				IF INSTR(lv2_result,'Failed to execute') > 0 THEN
					RAISE_APPLICATION_ERROR(-20108,lv2_result);
				END IF;
				lv2_setsql := 'SET ';
			END IF;
			ln_colcount := ln_colcount + 1;
		END LOOP;
		--ecdp_dynsql.writetemptext('summarizeStablePeriod','Numner of columns: ' || ln_colcount);
		IF MOD(ln_colcount,5) > 0 THEN
			ln_fromcolcount := ln_colcount - MOD(ln_colcount,5);
      IF lb_is_webo_interval_obj THEN
        lv2_updatesql :=  'UPDATE ' || lv2_result_table || ' rt ' || lv2_setsql || ' WHERE rt.object_id = ''' || row.object_id || ''' AND rt.result_no = ' || p_result_no;
      ELSE
        lv2_updatesql :=  'UPDATE ' || lv2_result_table || ' rt ' || lv2_setsql || ' WHERE rt.object_id = ''' || row.object_id || ''' AND rt.data_class_name = ''' || lv2_result_data_class || ''' AND rt.result_no = ' || p_result_no;
      END IF;
			--ecdp_dynsql.writetemptext('summarizeStablePeriod','Update on ' || lv2_result_table || ' from column ' || ln_fromcolcount || ' to columns ' || ln_colcount);
			--ecdp_dynsql.writetemptext('summarizeStablePeriod',lv2_updatesql);
			lv2_result := EcDp_Utilities.executeStatement(lv2_updatesql);
			IF INSTR(lv2_result,'Failed to execute') > 0 THEN
				RAISE_APPLICATION_ERROR(-20108,lv2_result);
			END IF;
		END IF;
		--Adding event samples
		IF row.class_name = 'TEST_DEVICE' THEN
		        ln_event_value1 := summarizeEvent(ln_test_no, row.object_id, ld_startdate, ld_enddate, 'TDEV_OUT_BSW', 'EVENT_OIL_OUT_BSW', lv2_result_data_class);
		        IF ln_event_value1 IS NULL THEN
		        	ln_event_value1 := summarizeEvent(ln_test_no, row.object_id, ld_startdate, ld_enddate, 'TDEV_OUT_BS', 'EVENT_OIL_OUT_BSW', lv2_result_data_class);
				ln_event_value1 := ln_event_value1 + summarizeEvent(ln_test_no, row.object_id, ld_startdate, ld_enddate, 'TDEV_OUT_WATER', 'EVENT_OIL_OUT_BSW', lv2_result_data_class);
			END IF;
		        ln_event_value2 := summarizeEvent(ln_test_no, row.object_id, ld_startdate, ld_enddate, 'OIL_DENSITY', 'EVENT_OIL_OUT_DENSITY', lv2_result_data_class);
		        ln_event_value3 := summarizeEvent(ln_test_no, row.object_id, ld_startdate, ld_enddate, 'GAS_DENSITY', 'EVENT_GAS_OUT_DENSITY', lv2_result_data_class);
		        ln_event_value4 := summarizeEvent(ln_test_no, row.object_id, ld_startdate, ld_enddate, 'TDEV_OUT_BSW_WT', 'EVENT_OIL_OUT_BSW_WT', lv2_result_data_class);
		        UPDATE eqpm_result SET event_oil_out_bsw = ln_event_value1, event_oil_out_density = ln_event_value2, event_gas_out_density = ln_event_value3, event_oil_out_bsw_wt = ln_event_value4 WHERE object_id = row.object_id  AND data_class_name =  lv2_result_data_class AND result_no = p_result_no;
	       	END IF;
    IF lb_is_webo_interval_obj THEN
      lv2_updatesql :=  'UPDATE ' || lv2_result_table || ' rt set rt.last_updated_by = ''' || p_last_updated_by || ''' WHERE rt.object_id = ''' || row.object_id || ''' AND rt.result_no = ' || p_result_no;
    ELSE
      lv2_updatesql :=  'UPDATE ' || lv2_result_table || ' rt set rt.last_updated_by = ''' || p_last_updated_by || ''' WHERE rt.object_id = ''' || row.object_id || ''' AND rt.data_class_name = ''' || lv2_result_data_class || ''' AND rt.result_no = ' || p_result_no;
    END IF;
		lv2_result := EcDp_Utilities.executeStatement(lv2_updatesql);
  END LOOP;
	--ecdp_dynsql.writetemptext('summarizeStablePeriod','Number of wells in result is ' || ln_well_count);
	IF ln_well_count = 1 THEN
		UPDATE pwel_result SET primary_ind = 'Y', flowing_ind = 'Y' where object_id = lv2_single_well_id AND result_no = p_result_no;
	END IF;
   	UPDATE ptst_result SET summarised_ind = 'Y', test_type = lv2_test_type, class_name = 'PROD_TEST_RESULT', last_updated_by = p_last_updated_by, production_day = EcDp_ProductionDay.getProductionDay('WELL',lv2_single_well_id, ld_startdate) WHERE result_no = p_result_no AND daytime = ld_startdate;
END summarizeStablePeriod;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : showFlowingWells
-- Description    : Returns a concatenated string of names for flowing well objects with available records
--                  for the given result.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : pwel_result
--
--
--
-- Using functions: ec_ptst_result.daytime, ec_well_version.name
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION showFlowingWells(p_result_no NUMBER)
RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_well_result IS
SELECT object_id
FROM pwel_result
WHERE result_no = p_result_no
AND Nvl(flowing_ind,'N') = 'Y';

lv2_result_string VARCHAR2(1000);
ld_test_date DATE;
lv2_name well_version.name%TYPE;

BEGIN

   ld_test_date := ec_ptst_result.daytime(p_result_no);

   IF ld_test_date IS NOT NULL THEN

      FOR cur_rec IN c_well_result LOOP

         lv2_name := ec_well_version.name(cur_rec.object_id, ld_test_date,'<=');

         IF c_well_result%ROWCOUNT = 1 THEN
            lv2_result_string := lv2_name;
         ELSE
            lv2_result_string := lv2_result_string || ', ' || lv2_name;
         END IF;

      END LOOP;

   END IF;

   RETURN lv2_result_string;

END showFlowingWells;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : showNonFlowingWells
-- Description    : Returns a concatenated string of names non flowing well objects with available records
--                  for the given result.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : pwel_result
--
--
--
-- Using functions: ec_ptst_result.daytime, ec_well_version.name
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION showNonFlowingWells(p_result_no NUMBER)
RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_well_result IS
SELECT object_id
FROM pwel_result
WHERE result_no = p_result_no
AND Nvl(flowing_ind,'N') = 'N';

lv2_result_string VARCHAR2(1000);
ld_test_date DATE;
lv2_name well_version.name%TYPE;

BEGIN

   ld_test_date := ec_ptst_result.daytime(p_result_no);

   IF ld_test_date IS NOT NULL THEN

      FOR cur_rec IN c_well_result LOOP

         lv2_name := ec_well_version.name(cur_rec.object_id, ld_test_date,'<=');

         IF c_well_result%ROWCOUNT = 1 THEN
            lv2_result_string := lv2_name;
         ELSE
            lv2_result_string := lv2_result_string || ', ' || lv2_name;
         END IF;

      END LOOP;

   END IF;

   RETURN lv2_result_string;

END showNonFlowingWells;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : showPrimaryWells
-- Description    : Returns a concatenated string of names of primary well objects with available records
--                  for the given result.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : pwel_result
--
--
--
-- Using functions: ec_ptst_result.daytime, ec_well_version.name
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION showPrimaryWells(p_result_no NUMBER)
RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_well_result IS
SELECT object_id
FROM pwel_result
WHERE result_no = p_result_no
AND Nvl(primary_ind,'N') = 'Y';

lv2_result_string VARCHAR2(1000);
ld_test_date DATE;
lv2_name well_version.name%TYPE;

BEGIN

   ld_test_date := ec_ptst_result.daytime(p_result_no);

   IF ld_test_date IS NOT NULL THEN

      FOR cur_rec IN c_well_result LOOP

         lv2_name := ec_well_version.name(cur_rec.object_id, ld_test_date,'<=');

         IF c_well_result%ROWCOUNT = 1 THEN
            lv2_result_string := lv2_name;
         ELSE
            lv2_result_string := lv2_result_string || ', ' || lv2_name;
         END IF;

      END LOOP;

   END IF;

   RETURN lv2_result_string;

END showPrimaryWells;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getEstimatedOilProduction
-- Description    : Returns the oil production compensation given the target and combination test.
--
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
FUNCTION getEstimatedOilProduction(
            p_target_result_no   NUMBER,
            p_comb_result_no     NUMBER)
RETURN NUMBER
--</EC-DOC>
IS
   CURSOR c_well_estimate IS
    SELECT SUM(oil_rate) oil
    FROM v_perf_test_well_estimate
    WHERE target_result_no = p_target_result_no
    AND comb_result_no = p_comb_result_no;

   ln_oil_production   NUMBER;

BEGIN

   FOR curSum IN c_well_estimate LOOP
      ln_oil_production := curSum.oil;
   END LOOP;

   RETURN ln_oil_production;

END getEstimatedOilProduction;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getEstimatedCondProduction
-- Description    : Returns the condensate production compensation given the target and combination test.
--
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
FUNCTION getEstimatedCondProduction(
            p_target_result_no   NUMBER,
            p_comb_result_no     NUMBER)
RETURN NUMBER
--</EC-DOC>
IS
   CURSOR c_well_estimate IS
    SELECT SUM(cond_rate) condensate
    FROM v_perf_test_well_estimate
    WHERE target_result_no = p_target_result_no
    AND comb_result_no = p_comb_result_no;

   ln_condensate_production   NUMBER;

BEGIN

   FOR curSum IN c_well_estimate LOOP
      ln_condensate_production := curSum.condensate;
   END LOOP;

   RETURN ln_condensate_production;

END getEstimatedCondProduction;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getEstimatedGasProduction
-- Description    : Returns the gas production compensation given the target and combination test.
--
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
FUNCTION getEstimatedGasProduction(
            p_target_result_no   NUMBER,
            p_comb_result_no     NUMBER)
RETURN NUMBER
--</EC-DOC>
IS
   CURSOR c_well_estimate IS
    SELECT SUM(gas_rate) gas
    FROM v_perf_test_well_estimate
    WHERE target_result_no = p_target_result_no
    AND comb_result_no = p_comb_result_no;

   ln_gas_production   NUMBER;

BEGIN

   FOR curSum IN c_well_estimate LOOP
      ln_gas_production := curSum.gas;
   END LOOP;

   RETURN ln_gas_production;

END getEstimatedGasProduction;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getEstimatedWaterProduction
-- Description    : Returns the water production compensation given the target and combination test.
--
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
FUNCTION getEstimatedWaterProduction(
            p_target_result_no   NUMBER,
            p_comb_result_no     NUMBER)
RETURN NUMBER
--</EC-DOC>
IS
   CURSOR c_well_estimate IS
    SELECT SUM(water_rate) water
    FROM v_perf_test_well_estimate
    WHERE target_result_no = p_target_result_no
    AND comb_result_no = p_comb_result_no;

   ln_water_production   NUMBER;

BEGIN

   FOR curSum IN c_well_estimate LOOP
      ln_water_production := curSum.water;
   END LOOP;

   RETURN ln_water_production;

END getEstimatedWaterProduction;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getPrimaryTargetWell
-- Description    : Returns the well object_d where the result is calculated using a combination of tests.
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
-- Behaviour      : The primary target well is SET A =
--                   (The set of wells that are primary wells in target result)
--                   INTERSECT
--                   ( (Flowing wells in the target result)
--                     MINUS
--                     (Flowing wells in the combination result)
--                   )
--                  The set should only contains one item(well), if several exist it returns NULL.
--
---------------------------------------------------------------------------------------------------
FUNCTION getPrimaryTargetWellID(
            p_target_result_no   NUMBER,
            p_comb_result_no     NUMBER)
RETURN VARCHAR2
IS
   CURSOR c_primary_well IS
    SELECT object_id
    FROM pwel_result
    WHERE result_no = p_target_result_no
    AND primary_ind = 'Y'
    INTERSECT
    (
      SELECT object_id
      FROM pwel_result
      WHERE result_no = p_target_result_no
      AND flowing_ind = 'Y'
     MINUS
      SELECT object_id
      FROM pwel_result
      WHERE result_no = p_comb_result_no
      AND flowing_ind = 'Y'
     );

   lv2_object_id     VARCHAR2(32);
   ln_count          NUMBER := 0;

BEGIN

   FOR curWell IN c_primary_well LOOP

      ln_count := ln_count + 1;
      lv2_object_id := curWell.object_id;

   END LOOP;

   IF ln_count > 1 THEN
      lv2_object_id := NULL;
   END IF;

   RETURN lv2_object_id;

END getPrimaryTargetWellID;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasStdRateDay
-- Description    : Returns theoretical gass rate for well on a given day
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
FUNCTION getGasStdRateDay(
            p_result_no    NUMBER,
            p_object_id    VARCHAR2,
            p_daytime      DATE)
RETURN NUMBER
--</EC-DOC>
IS

   lv2_calc_method      well_version.calc_method%TYPE;
   lv2_gor_method       well_version.gor_method%TYPE;
   ln_gor               NUMBER;
   ln_ret_val           NUMBER;
   lr_pwel_result_rec   pwel_result%ROWTYPE;
   lr_params            EcDp_Well_Theoretical.PerfCurveParamRec;

BEGIN

   lv2_calc_method :=  ec_well_version.calc_gas_method(p_object_id,p_daytime,'<=');
   lr_pwel_result_rec := ec_pwel_result.row_by_pk(p_object_id,p_result_no);

   IF lv2_calc_method = EcDp_Calc_Method.MEASURED THEN

      ln_ret_val := lr_pwel_result_rec.mpm_gas_rate - Nvl(lr_pwel_result_rec.gl_rate,0); -- Subtract gas lift contribution if present

   ELSIF lv2_calc_method IN(EcDp_Calc_Method.WELL_EST_DETAIL, EcDp_Calc_Method.WELL_EST_PUMP_SPEED) THEN

      ln_ret_val := EcDp_Well_Estimate.getLastGasStdRate(p_object_id, p_daytime);

   ELSIF lv2_calc_method = EcDp_Calc_Method.CURVE_GAS THEN

      IF ec_well_version.isGasProducer(p_object_id,p_daytime,'<=') = ECDP_TYPE.IS_TRUE THEN

         lr_params.choke_size        := lr_pwel_result_rec.choke_size;
         lr_params.wh_press          := lr_pwel_result_rec.wh_press;
         lr_params.wh_temp           := lr_pwel_result_rec.wh_temp;
         lr_params.bh_press          := lr_pwel_result_rec.bh_press;
         lr_params.annulus_press     := lr_pwel_result_rec.annulus_press;
         lr_params.wh_usc_press      := lr_pwel_result_rec.wh_usc_press;
         lr_params.wh_dsc_press      := lr_pwel_result_rec.wh_dsc_press;
         lr_params.bs_w              := lr_pwel_result_rec.watercut_pct;
         lr_params.dh_pump_rpm       := lr_pwel_result_rec.pump_speed;
         lr_params.gl_choke          := lr_pwel_result_rec.gl_choke_size;
         lr_params.gl_press          := lr_pwel_result_rec.gl_press;
         lr_params.gl_rate           := lr_pwel_result_rec.gl_rate;
         lr_params.gl_diff_press     := NULL;
         lr_params.avg_flow_mass     := lr_pwel_result_rec.avg_flow_mass;
		 lr_params.phase_current     := lr_pwel_result_rec.drive_current;
		 lr_params.ac_frequency      := lr_pwel_result_rec.drive_frequency;
		 lr_params.intake_press      := lr_pwel_result_rec.intake_press;
	     lr_params.mpm_oil_rate      := lr_pwel_result_rec.mpm_oil_rate;
	     lr_params.mpm_gas_rate      := lr_pwel_result_rec.mpm_gas_rate;
	     lr_params.mpm_water_rate    := lr_pwel_result_rec.mpm_water_rate;
	     lr_params.mpm_cond_rate     := lr_pwel_result_rec.mpm_cond_rate;

         ln_ret_val :=  EcDp_Well_Theoretical.getCurveStdRate(
                                                p_object_id,
                                                p_daytime,
                                                EcDp_Curve_Purpose.PRODUCTION,
                                                EcDp_Phase.GAS,
                                                lr_params,
												lv2_calc_method);
      END IF;

   ELSIF lv2_calc_method = EcDp_Calc_Method.OIL_GOR THEN

     lv2_gor_method := ec_well_version.gor_method(p_object_id,p_daytime,'<=');
     IF (lv2_gor_method = EcDp_Calc_Method.CURVE) THEN
        ln_gor := ecdp_well_theoretical.getGasOilRatio(p_object_id, p_daytime, EcDp_Phase.OIL, EcDp_Calc_Method.CURVE, 'PWEL_RESULT', p_result_no);
     ELSIF (lv2_gor_method = EcDp_Calc_Method.CURVE_LIQUID) THEN
        ln_gor := ecdp_well_theoretical.getGasOilRatio(p_object_id, p_daytime, EcDp_Phase.LIQUID, EcDp_Calc_Method.CURVE_LIQUID, 'PWEL_RESULT', p_result_no);
     END IF;

     ln_ret_val := ln_gor * EcDp_Performance_Test.getOilStdRateDay(p_result_no,p_object_id,p_daytime);

   ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN

     ln_ret_val := Ue_Well_Theoretical.getGasStdRateDay(p_object_id,p_daytime,p_result_no);

   ELSE

      ln_ret_val := ecdp_well_estimate.getLastGasStdRate(p_object_id, p_daytime);

   END IF;

   RETURN ln_ret_val;

END getGasStdRateDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCondStdRateDay
-- Description    : Returns theoretical condensate rate for well on a given day
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
FUNCTION getCondStdRateDay(
            p_result_no    NUMBER,
            p_object_id    VARCHAR2,
            p_daytime      DATE)
RETURN NUMBER
--</EC-DOC>
IS

   lv2_calc_method      well_version.calc_method%TYPE;
   ln_ret_val           NUMBER;
   lr_pwel_result_rec   pwel_result%ROWTYPE;
   lr_params            EcDp_Well_Theoretical.PerfCurveParamRec;

BEGIN

   lv2_calc_method :=  ec_well_version.calc_cond_method(p_object_id,p_daytime,'<=');
   lr_pwel_result_rec := ec_pwel_result.row_by_pk(p_object_id,p_result_no);

   IF lv2_calc_method = EcDp_Calc_Method.MEASURED THEN

      ln_ret_val := lr_pwel_result_rec.mpm_cond_rate;

   ELSIF lv2_calc_method = EcDp_Calc_Method.WELL_EST_DETAIL THEN

      ln_ret_val := EcDp_Well_Estimate.getLastCondStdRate(p_object_id, p_daytime);

   ELSIF lv2_calc_method = EcDp_Calc_Method.CURVE THEN

         lr_params.choke_size        := lr_pwel_result_rec.choke_size;
         lr_params.wh_press          := lr_pwel_result_rec.wh_press;
         lr_params.wh_temp           := lr_pwel_result_rec.wh_temp;
         lr_params.bh_press          := lr_pwel_result_rec.bh_press;
         lr_params.annulus_press     := lr_pwel_result_rec.annulus_press;
         lr_params.wh_usc_press      := lr_pwel_result_rec.wh_usc_press;
         lr_params.wh_dsc_press      := lr_pwel_result_rec.wh_dsc_press;
         lr_params.bs_w              := lr_pwel_result_rec.watercut_pct;
         lr_params.dh_pump_rpm       := lr_pwel_result_rec.pump_speed;
         lr_params.gl_choke          := lr_pwel_result_rec.gl_choke_size;
         lr_params.gl_press          := lr_pwel_result_rec.gl_press;
         lr_params.gl_rate           := lr_pwel_result_rec.gl_rate;
         lr_params.gl_diff_press     := NULL;
         lr_params.avg_flow_mass     := lr_pwel_result_rec.avg_flow_mass;
		 lr_params.phase_current     := lr_pwel_result_rec.drive_current;
		 lr_params.ac_frequency      := lr_pwel_result_rec.drive_frequency;
		 lr_params.intake_press      := lr_pwel_result_rec.intake_press;
	     lr_params.mpm_oil_rate      := lr_pwel_result_rec.mpm_oil_rate;
	     lr_params.mpm_gas_rate      := lr_pwel_result_rec.mpm_gas_rate;
	     lr_params.mpm_water_rate    := lr_pwel_result_rec.mpm_water_rate;
	     lr_params.mpm_cond_rate     := lr_pwel_result_rec.mpm_cond_rate;

      ln_ret_val :=  EcDp_Well_Theoretical.getCurveStdRate(
                                                p_object_id,
                                                p_daytime,
                                                EcDp_Curve_Purpose.PRODUCTION,
                                                EcDp_Phase.OIL,
                                                lr_params,
												lv2_calc_method);

   ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN

     ln_ret_val := Ue_Well_Theoretical.getCondStdRateDay(p_object_id,p_daytime,p_result_no);

   ELSE

      ln_ret_val := ecdp_well_estimate.getLastCondStdRate(p_object_id, p_daytime);

   END IF;

   RETURN ln_ret_val;

END getCondStdRateDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getOilStdRateDay
-- Description    : Returns theoretical oil rate for well on a given day
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
FUNCTION getOilStdRateDay(
            p_result_no    NUMBER,
            p_object_id    VARCHAR2,
            p_daytime      DATE)
RETURN NUMBER
--</EC-DOC>
IS

   lv2_calc_method      well_version.calc_method%TYPE;
   ln_ret_val           NUMBER;
   lr_pwel_result_rec   pwel_result%ROWTYPE;
   lr_params            EcDp_Well_Theoretical.PerfCurveParamRec;

BEGIN

   lv2_calc_method :=  ec_well_version.calc_method(p_object_id,p_daytime,'<=');
   lr_pwel_result_rec := ec_pwel_result.row_by_pk(p_object_id,p_result_no);

   IF lv2_calc_method = EcDp_Calc_Method.MEASURED THEN

      ln_ret_val := lr_pwel_result_rec.mpm_oil_rate;

   ELSIF lv2_calc_method IN(EcDp_Calc_Method.WELL_EST_DETAIL,EcDp_Calc_Method.WELL_EST_PUMP_SPEED) THEN

      ln_ret_val := EcDp_Well_Estimate.getLastOilStdRate(p_object_id, p_daytime);

   ELSIF lv2_calc_method = EcDp_Calc_Method.CURVE THEN

         lr_params.choke_size        := lr_pwel_result_rec.choke_size;
         lr_params.wh_press          := lr_pwel_result_rec.wh_press;
         lr_params.wh_temp           := lr_pwel_result_rec.wh_temp;
         lr_params.bh_press          := lr_pwel_result_rec.bh_press;
         lr_params.annulus_press     := lr_pwel_result_rec.annulus_press;
         lr_params.wh_usc_press      := lr_pwel_result_rec.wh_usc_press;
         lr_params.wh_dsc_press      := lr_pwel_result_rec.wh_dsc_press;
         lr_params.bs_w              := lr_pwel_result_rec.watercut_pct;
         lr_params.dh_pump_rpm       := lr_pwel_result_rec.pump_speed;
         lr_params.gl_choke          := lr_pwel_result_rec.gl_choke_size;
         lr_params.gl_press          := lr_pwel_result_rec.gl_press;
         lr_params.gl_rate           := lr_pwel_result_rec.gl_rate;
         lr_params.gl_diff_press     := NULL;
         lr_params.avg_flow_mass     := lr_pwel_result_rec.avg_flow_mass;
		 lr_params.phase_current     := lr_pwel_result_rec.drive_current;
		 lr_params.ac_frequency      := lr_pwel_result_rec.drive_frequency;
		 lr_params.intake_press      := lr_pwel_result_rec.intake_press;
		 lr_params.mpm_oil_rate      := lr_pwel_result_rec.mpm_oil_rate;
	     lr_params.mpm_gas_rate      := lr_pwel_result_rec.mpm_gas_rate;
	     lr_params.mpm_water_rate    := lr_pwel_result_rec.mpm_water_rate;
	     lr_params.mpm_cond_rate     := lr_pwel_result_rec.mpm_cond_rate;

      ln_ret_val :=  EcDp_Well_Theoretical.getCurveStdRate(
                                                p_object_id,
                                                p_daytime,
                                                EcDp_Curve_Purpose.PRODUCTION,
                                                EcDp_Phase.OIL,
                                                lr_params,
												lv2_calc_method);

   ELSIF lv2_calc_method = EcDp_Calc_Method.CURVE_LIQUID THEN

         lr_params.choke_size        := lr_pwel_result_rec.choke_size;
         lr_params.wh_press          := lr_pwel_result_rec.wh_press;
         lr_params.wh_temp           := lr_pwel_result_rec.wh_temp;
         lr_params.bh_press          := lr_pwel_result_rec.bh_press;
         lr_params.annulus_press     := lr_pwel_result_rec.annulus_press;
         lr_params.wh_usc_press      := lr_pwel_result_rec.wh_usc_press;
         lr_params.wh_dsc_press      := lr_pwel_result_rec.wh_dsc_press;
         lr_params.bs_w              := lr_pwel_result_rec.watercut_pct;
         lr_params.dh_pump_rpm       := lr_pwel_result_rec.pump_speed;
         lr_params.gl_choke          := lr_pwel_result_rec.gl_choke_size;
         lr_params.gl_press          := lr_pwel_result_rec.gl_press;
         lr_params.gl_rate           := lr_pwel_result_rec.gl_rate;
         lr_params.gl_diff_press     := NULL;
         lr_params.avg_flow_mass     := lr_pwel_result_rec.avg_flow_mass;
		 lr_params.phase_current     := lr_pwel_result_rec.drive_current;
		 lr_params.ac_frequency      := lr_pwel_result_rec.drive_frequency;
		 lr_params.intake_press      := lr_pwel_result_rec.intake_press;
	     lr_params.mpm_oil_rate      := lr_pwel_result_rec.mpm_oil_rate;
	     lr_params.mpm_gas_rate      := lr_pwel_result_rec.mpm_gas_rate;
	     lr_params.mpm_water_rate    := lr_pwel_result_rec.mpm_water_rate;
	     lr_params.mpm_cond_rate     := lr_pwel_result_rec.mpm_cond_rate;

      ln_ret_val :=  EcDp_Well_Theoretical.getCurveStdRate(
                                                p_object_id,
                                                p_daytime,
                                                EcDp_Curve_Purpose.PRODUCTION,
                                                EcDp_Phase.LIQUID,
                                                lr_params,
												lv2_calc_method);

   ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN

     ln_ret_val := Ue_Well_Theoretical.getOilStdRateDay(p_object_id, p_daytime, p_result_no);

   ELSE

      ln_ret_val := ecdp_well_estimate.getLastOilStdRate(p_object_id, p_daytime);

   END IF;

   RETURN ln_ret_val;

END getOilStdRateDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWatStdRateDay
-- Description    : Returns theoretical water rate for well on a given day
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
FUNCTION getWatStdRateDay(
            p_result_no    NUMBER,
            p_object_id    VARCHAR2,
            p_daytime      DATE)
RETURN NUMBER
--</EC-DOC>
IS

   lv2_calc_method      well_version.calc_method%TYPE;
   ln_ret_val           NUMBER;
   ln_water_cut         NUMBER;
   ln_oil_rate          NUMBER;
   lr_pwel_result_rec   pwel_result%ROWTYPE;
   lr_params            EcDp_Well_Theoretical.PerfCurveParamRec;

BEGIN

   lv2_calc_method :=  ec_well_version.calc_water_method(p_object_id,p_daytime,'<=');
   lr_pwel_result_rec := ec_pwel_result.row_by_pk(p_object_id,p_result_no);

   IF lv2_calc_method = EcDp_Calc_Method.MEASURED THEN

      ln_ret_val := lr_pwel_result_rec.mpm_water_rate;

   ELSIF lv2_calc_method IN(EcDp_Calc_Method.WELL_EST_DETAIL,EcDp_Calc_Method.WELL_EST_PUMP_SPEED) THEN

      ln_ret_val := EcDp_Well_Estimate.getLastWatStdRate(p_object_id, p_daytime);

   ELSIF lv2_calc_method = EcDp_Calc_Method.CURVE_WATER THEN

         lr_params.choke_size        := lr_pwel_result_rec.choke_size;
         lr_params.wh_press          := lr_pwel_result_rec.wh_press;
         lr_params.wh_temp           := lr_pwel_result_rec.wh_temp;
         lr_params.bh_press          := lr_pwel_result_rec.bh_press;
         lr_params.annulus_press     := lr_pwel_result_rec.annulus_press;
         lr_params.wh_usc_press      := lr_pwel_result_rec.wh_usc_press;
         lr_params.wh_dsc_press      := lr_pwel_result_rec.wh_dsc_press;
         lr_params.bs_w              := lr_pwel_result_rec.watercut_pct;
         lr_params.dh_pump_rpm       := lr_pwel_result_rec.pump_speed;
         lr_params.gl_choke          := lr_pwel_result_rec.gl_choke_size;
         lr_params.gl_press          := lr_pwel_result_rec.gl_press;
         lr_params.gl_rate           := lr_pwel_result_rec.gl_rate;
         lr_params.gl_diff_press     := NULL;
         lr_params.avg_flow_mass     := lr_pwel_result_rec.avg_flow_mass;
		 lr_params.phase_current     := lr_pwel_result_rec.drive_current;
		 lr_params.ac_frequency      := lr_pwel_result_rec.drive_frequency;
		 lr_params.intake_press      := lr_pwel_result_rec.intake_press;
	     lr_params.mpm_oil_rate      := lr_pwel_result_rec.mpm_oil_rate;
	     lr_params.mpm_gas_rate      := lr_pwel_result_rec.mpm_gas_rate;
	     lr_params.mpm_water_rate    := lr_pwel_result_rec.mpm_water_rate;
	     lr_params.mpm_cond_rate     := lr_pwel_result_rec.mpm_cond_rate;

      ln_ret_val :=  EcDp_Well_Theoretical.getCurveStdRate(
                                                p_object_id,
                                                p_daytime,
                                                EcDp_Curve_Purpose.PRODUCTION,
                                                EcDp_Phase.WATER,
                                                lr_params,
												lv2_calc_method);

   ELSIF (lv2_calc_method = EcDp_Calc_Method.OIL_WATER_CUT) OR (lv2_calc_method = EcDp_Calc_Method.LIQ_WATER_CUT) THEN
      ln_water_cut := EcBp_well_theoretical.findWaterCutPct(p_object_id, p_daytime, NULL, NULL, 'PWEL_RESULT', p_result_no)/100;
      ln_oil_rate := getOilStdRateDay(p_result_no, p_object_id,p_daytime);
      IF ln_oil_rate > 0 THEN
         IF (1 - ln_water_cut) <> 0 THEN
            ln_ret_val := (ln_oil_rate/(1 - ln_water_cut)) * ln_water_cut;
         ELSE   -- div by zero
            ln_ret_val := null;
         END IF;
      ELSIF ln_oil_rate = 0 THEN   -- if oil is zero, then also water is zero
         ln_ret_val := 0;
      ELSE
         ln_ret_val := null;
      END IF;

   ELSIF (substr(lv2_calc_method,1,9) = EcDp_Calc_Method.USER_EXIT) THEN

     ln_ret_val := Ue_Well_Theoretical.getWatStdRateDay(p_object_id,p_daytime,p_result_no);

   ELSE

      ln_ret_val := ecdp_well_estimate.getLastWatStdRate(p_object_id, p_daytime);

   END IF;

   RETURN ln_ret_val;

END getWatStdRateDay;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasLiftStdRateDay
-- Description    : Returns theoretical gaslift volume for well
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
FUNCTION getGasLiftStdRateDay(p_result_no     NUMBER,
                              p_object_id     well.object_id%TYPE,
                              p_daytime       DATE )
RETURN NUMBER
--</EC-DOC>
IS
   lv2_gas_lift_method VARCHAR2(32);
   lr_day_rec          PWEL_DAY_STATUS%ROWTYPE;
   lr_result_rec       pwel_result%ROWTYPE;
   ln_ret_val          NUMBER;
   ln_on_strm_ratio    NUMBER;
   ln_pump_speed_ratio NUMBER;
   ln_test_pump_speed  NUMBER;

BEGIN

    lv2_gas_lift_method := ec_well_version.gas_lift_method(p_object_id,
                                                              p_daytime,
                                                              '<=');

    lr_result_rec := ec_pwel_result.row_by_pk(p_object_id,p_result_no);


   IF (lv2_gas_lift_method = EcDp_Calc_Method.MEASURED) THEN --no fallback
      ln_ret_val := lr_result_rec.gl_rate;

   ELSIF (lv2_gas_lift_method = EcDp_Calc_Method.CURVE) THEN

       ln_ret_val := lr_result_rec.gl_rate;
       IF ln_ret_val is null THEN --if no gl_rate in current, fallback to curve

           ln_ret_val := ecbp_well_theoretical.getCurveRate(p_object_id,
                                                 p_daytime,
                                                 'GAS',
                                                 'GAS_LIFT',
                                                 null,
                                                 null,
                                                 null,
                                                 null,
                                                 lr_result_rec.annulus_press,
                                                 null,
                                                 null,
                                                 null,
                                                 null,
                                                 lr_result_rec.gl_choke_size,
                                                 lr_result_rec.gl_press,
                                                 null,
                                                 null,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 NULL,
												 null,
                                                 null,
                                                 NULL,
												 NULL,
												 lv2_gas_lift_method);

       END IF;

   ELSIF (lv2_gas_lift_method = EcDp_Calc_Method.WELL_EST_DETAIL) THEN

       ln_ret_val := lr_result_rec.gl_rate;
       IF ln_ret_val is null THEN --if no gl_rate in current, fallback to most recent valid result
           lr_result_rec := EcDp_Performance_Test.getLastValidWellResult(p_object_id, p_daytime);
           ln_ret_val := lr_result_rec.gl_rate;
       END IF;

   ELSIF (lv2_gas_lift_method = EcDp_Calc_Method.WELL_EST_DETAIL_DEFERRED) THEN

   	lr_result_rec := EcDp_Performance_Test.getLastValidWellResult(p_object_id,
                                                                    p_daytime);

   	ln_ret_val := (lr_result_rec.gl_rate * ln_on_strm_ratio)
      			- ecbp_well_potential.calcDayWellProdDefermentVol(p_object_id, p_daytime, 'GAS_LIFT');

   ELSE -- undefined method
      ln_ret_val := lr_result_rec.gl_rate;
   END IF;

   RETURN ln_ret_val;

END getGasLiftStdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDiluentStdRateDay
-- Description    : Returns theoretical diluent volume for well
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
FUNCTION getDiluentStdRateDay(p_result_no     NUMBER,
                              p_object_id     VARCHAR2,
                              p_daytime       DATE )
RETURN NUMBER
--</EC-DOC>
IS
   lv2_diluent_method  VARCHAR2(32);
   lr_result_rec       PWEL_RESULT%ROWTYPE;
   ln_ret_val          NUMBER;

BEGIN

   lv2_diluent_method := ec_well_version.diluent_method(p_object_id,
                                                      p_daytime,
                                                      '<=');

   lr_result_rec := ec_pwel_result.row_by_pk(p_object_id,p_result_no);


   IF lv2_diluent_method = EcDp_Calc_Method.MEASURED THEN
      ln_ret_val := lr_result_rec.diluent_rate;
   ELSE -- undefined
      ln_ret_val := lr_result_rec.diluent_rate;
   END IF;

   RETURN ln_ret_val;

END getDiluentStdRateDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getPowerWaterStdRateDay
-- Description    : Returns theoretical PowerWater rate for well
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
FUNCTION getPowerWaterStdRateDay(p_result_no     NUMBER,
                              p_object_id     VARCHAR2,
                              p_daytime       DATE )
RETURN NUMBER
--</EC-DOC>
IS
   lv2_powerwater_method  VARCHAR2(32);
   lr_result_rec       PWEL_RESULT%ROWTYPE;
   ln_ret_val          NUMBER;

BEGIN

   lv2_powerwater_method := 'MEASURED'; -- ec_well_version.powerwater_method(p_object_id, p_daytime,'<=');
                                       -- Full support later, but only measured rate now.

   lr_result_rec := ec_pwel_result.row_by_pk(p_object_id,p_result_no);

   IF lv2_powerwater_method = EcDp_Calc_Method.MEASURED THEN
      ln_ret_val := lr_result_rec.powerwater_rate;
   ELSE -- undefined
      ln_ret_val := lr_result_rec.powerwater_rate;
   END IF;

   RETURN ln_ret_val;

END getPowerWaterStdRateDay;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getOilRateTargetWellResult
-- Description    : Returns the calculated oil rate for a well given the two combined tests.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : eqpm_result
--
-- Using functions: EcDp_Performance_Test.getEstimatedOilProduction
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getOilRateTargetWellResult(
            p_target_result_no   NUMBER,
            p_comb_result_no     NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

   CURSOR c_eqpm_result(cp_result_no   NUMBER) IS
    SELECT net_oil_rate_adj
    FROM eqpm_result
    WHERE result_no = cp_result_no;

   ln_ret_val           NUMBER;
   ln_target_oil        NUMBER;
   ln_comb_oil          NUMBER;
   ln_est_oil           NUMBER;


BEGIN

   FOR curTargetTD IN c_eqpm_result(p_target_result_no) LOOP
      ln_target_oil := curTargetTD.net_oil_rate_adj;
   END LOOP;

    FOR curTargetTD IN c_eqpm_result(p_comb_result_no) LOOP
      ln_comb_oil := curTargetTD.net_oil_rate_adj;
   END LOOP;

   ln_est_oil := EcDp_Performance_Test.getEstimatedOilProduction(p_target_result_no,p_comb_result_no);

   ln_ret_val := ln_target_oil - Nvl(ln_comb_oil,0) - Nvl(ln_est_oil,0);

   RETURN ln_ret_val;

END getOilRateTargetWellResult;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCondRateTargetWellResult
-- Description    : Returns the calculated condensate rate for a well given the two combined tests.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : eqpm_result
--
-- Using functions: EcDp_Performance_Test.getEstimatedCondProduction
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getCondRateTargetWellResult(
            p_target_result_no   NUMBER,
            p_comb_result_no     NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

   CURSOR c_eqpm_result(cp_result_no   NUMBER) IS
    SELECT net_cond_rate_adj
    FROM eqpm_result
    WHERE result_no = cp_result_no;

   ln_ret_val           NUMBER;
   ln_target_cond        NUMBER;
   ln_comb_cond          NUMBER;
   ln_est_cond           NUMBER;


BEGIN

   FOR curTargetTD IN c_eqpm_result(p_target_result_no) LOOP
      ln_target_cond := curTargetTD.net_cond_rate_adj;
   END LOOP;

    FOR curTargetTD IN c_eqpm_result(p_comb_result_no) LOOP
      ln_comb_cond := curTargetTD.net_cond_rate_adj;
   END LOOP;

   ln_est_cond := EcDp_Performance_Test.getEstimatedCondProduction(p_target_result_no,p_comb_result_no);

   ln_ret_val := ln_target_cond - Nvl(ln_comb_cond,0) - Nvl(ln_est_cond,0);

   RETURN ln_ret_val;

END getCondRateTargetWellResult;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getGasRateTargetWellResult
-- Description    : Returns the calculated gas rate for a well given the two combined tests.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : eqpm_result
--
-- Using functions: EcDp_Performance_Test.getEstimatedGasProduction
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getGasRateTargetWellResult(
            p_target_result_no   NUMBER,
            p_comb_result_no     NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

   CURSOR c_eqpm_result(cp_result_no   NUMBER) IS
    SELECT gas_rate_adj
    FROM eqpm_result
    WHERE result_no = cp_result_no;

   ln_ret_val           NUMBER;
   ln_target_gas        NUMBER;
   ln_comb_gas          NUMBER;
   ln_est_gas           NUMBER;


BEGIN

   FOR curTargetTD IN c_eqpm_result(p_target_result_no) LOOP
      ln_target_gas := curTargetTD.gas_rate_adj;
   END LOOP;

    FOR curTargetTD IN c_eqpm_result(p_comb_result_no) LOOP
      ln_comb_gas := curTargetTD.gas_rate_adj;
   END LOOP;

   ln_est_gas := EcDp_Performance_Test.getEstimatedGasProduction(p_target_result_no,p_comb_result_no);

   ln_ret_val := ln_target_gas - Nvl(ln_comb_gas,0) - Nvl(ln_est_gas,0);

   RETURN ln_ret_val;

END getGasRateTargetWellResult;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWatRateTargetWellResult
-- Description    : Returns the calculated water rate for a well given the two combined tests.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : eqpm_result
--
-- Using functions: EcDp_Performance_Test.getEstimatedWaterProduction
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getWatRateTargetWellResult(
            p_target_result_no   NUMBER,
            p_comb_result_no     NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

   CURSOR c_eqpm_result(cp_result_no   NUMBER) IS
    SELECT tot_water_rate_adj
    FROM eqpm_result
    WHERE result_no = cp_result_no;

   ln_ret_val           NUMBER;
   ln_target_water      NUMBER;
   ln_comb_water        NUMBER;
   ln_est_water         NUMBER;


BEGIN

   FOR curTargetTD IN c_eqpm_result(p_target_result_no) LOOP
      ln_target_water := curTargetTD.tot_water_rate_adj;
   END LOOP;

    FOR curTargetTD IN c_eqpm_result(p_comb_result_no) LOOP
      ln_comb_water := curTargetTD.tot_water_rate_adj;
   END LOOP;

   ln_est_water := EcDp_Performance_Test.getEstimatedWaterProduction(p_target_result_no,p_comb_result_no);

   ln_ret_val := ln_target_water - Nvl(ln_comb_water,0) - Nvl(ln_est_water,0);

   RETURN ln_ret_val;

END getWatRateTargetWellResult;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : saveWellTargetResult
-- Description    : Saves the calculated test result for a primary target well given two combined tests
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : pwel_result
--
-- Using functions: getPrimaryTargetWellID
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE saveWellTargetResult(
               p_target_result_no   NUMBER,
               p_comb_result_no     NUMBER,
               p_oil_rate           NUMBER,
               p_con_rate           NUMBER,
               p_gas_rate           NUMBER,
               p_water_rate         NUMBER,
               p_user				VARCHAR2 DEFAULT NULL)
IS

   lv2_target_well_id      VARCHAR2(32);
   lv2_well_type           well_version.well_type%TYPE;
   n_lock_columns          EcDp_Month_lock.column_list;
   lr_result               PTST_RESULT%ROWTYPE;
   ln_oil_rate             NUMBER;
   ln_con_rate             NUMBER;
   ln_gas_rate             NUMBER;
   ln_water_rate           NUMBER;

BEGIN

   lr_result := ec_ptst_result.row_by_pk(p_target_result_no);

   -- Lock test
   EcDp_month_lock.AddParameterToList(n_lock_columns,'CLASS_NAME','PROD_TEST_RESULT','STRING',NULL,NULL,NULL);
   EcDp_month_lock.AddParameterToList(n_lock_columns,'TABLE_NAME','PTST_RESULT','STRING',NULL,NULL,NULL);
   EcDp_month_lock.AddParameterToList(n_lock_columns,'RESULT_NO','RESULT_NO','NUMBER','Y','N',anydata.ConvertNumber(lr_result.RESULT_NO));
   EcDp_month_lock.AddParameterToList(n_lock_columns,'VALID_FROM_DATE','VALID_FROM_DATE','DATE','N','N',anydata.Convertdate(lr_result.VALID_FROM_DATE));
   EcDp_month_lock.AddParameterToList(n_lock_columns,'STATUS','STATUS','STRING','N','N',anydata.ConvertVarChar2(lr_result.STATUS));

   EcDp_Performance_lock.CheckLockProductionTest('UPDATING',n_lock_columns,n_lock_columns);


   lv2_target_well_id := EcDp_Performance_Test.getPrimaryTargetWellID(p_target_result_no,p_comb_result_no);

   IF lv2_target_well_id IS NULL THEN
      Raise_Application_Error(-20000,'Missing primary target well');
   END IF;

   lv2_well_type := ec_well_version.well_type(lv2_target_well_id,ec_ptst_result.daytime(p_target_result_no),'<=');
   ln_oil_rate := ecdp_unit.convertValue(p_oil_rate, ecdp_unit.GetUnitFromLogical(ec_class_attr_presentation.uom_code('TDEV_RESULT','NET_OIL_RATE_ADJ')), ecdp_unit.GetViewUnitFromLogical(ec_class_attr_presentation.uom_code('TDEV_RESULT','NET_OIL_RATE_ADJ')));
   ln_con_rate := ecdp_unit.convertValue(p_con_rate, ecdp_unit.GetUnitFromLogical(ec_class_attr_presentation.uom_code('TDEV_RESULT','NET_COND_RATE_ADJ')), ecdp_unit.GetViewUnitFromLogical(ec_class_attr_presentation.uom_code('TDEV_RESULT','NET_COND_RATE_ADJ')));
   ln_gas_rate := ecdp_unit.convertValue(p_gas_rate, ecdp_unit.GetUnitFromLogical(ec_class_attr_presentation.uom_code('TDEV_RESULT','GAS_RATE_ADJ')), ecdp_unit.GetViewUnitFromLogical(ec_class_attr_presentation.uom_code('TDEV_RESULT','GAS_RATE_ADJ')));
   ln_water_rate := ecdp_unit.convertValue(p_water_rate, ecdp_unit.GetUnitFromLogical(ec_class_attr_presentation.uom_code('TDEV_RESULT','TOT_WATER_RATE_ADJ')), ecdp_unit.GetViewUnitFromLogical(ec_class_attr_presentation.uom_code('TDEV_RESULT','TOT_WATER_RATE_ADJ')));

   IF lv2_well_type IN('OP','OPGI') THEN

      UPDATE pwel_result
      SET net_oil_rate_adj = ln_oil_rate,
         net_cond_rate_adj = ln_con_rate,
         gas_rate_adj = ln_gas_rate,
         tot_water_rate_adj = ln_water_rate,
         watercut_pct = 100*ln_water_rate / (ln_oil_rate + ln_water_rate),
         gor = ln_gas_rate / ln_oil_rate,
         result_no_comb = p_comb_result_no,
         last_updated_by = Nvl(p_user,USER)
      WHERE object_id = lv2_target_well_id
      AND result_no = p_target_result_no;

   ELSIF lv2_well_type IN('CP','GP','GPI') THEN

      UPDATE pwel_result
      SET net_oil_rate_adj = ln_oil_rate,
         net_cond_rate_adj = ln_con_rate,
         gas_rate_adj = ln_gas_rate,
         tot_water_rate_adj = ln_water_rate,
         cgr  = ln_con_rate / ln_gas_rate,
         wgr = ln_water_rate / ln_gas_rate,
         result_no_comb = p_comb_result_no,
         last_updated_by = Nvl(p_user,USER)
      WHERE object_id = lv2_target_well_id
      AND result_no = p_target_result_no;

   ELSE

      UPDATE pwel_result
      SET net_oil_rate_adj = ln_oil_rate,
         net_cond_rate_adj = ln_con_rate,
         gas_rate_adj = ln_gas_rate,
         tot_water_rate_adj = ln_water_rate,
         result_no_comb = p_comb_result_no,
         last_updated_by = Nvl(p_user,USER)
      WHERE object_id = lv2_target_well_id
      AND result_no = p_target_result_no;

   END IF;


END saveWellTargetResult;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSumEstGLRate
-- Description    : Find sum of estimated GL rates from wells on test
--
-- Preconditions  :
-- Postconditions :
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSumEstGLRate(
            p_result_no    NUMBER
)
RETURN NUMBER
--</EC-DOC>
IS

   CURSOR c_pwel_result_sum IS
   SELECT SUM(est_gl_rate) sum_gl_rate
   FROM pwel_result
   WHERE result_no = p_result_no;

   ln_sum NUMBER ;

BEGIN

   -- aggregated estimates for Test device
   FOR curWellSum IN c_pwel_result_sum LOOP

     ln_sum :=   curWellSum.sum_gl_rate;

   END LOOP;

   RETURN ln_sum;

END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSumEstDILRate
-- Description    : Find sum of estimated diluent rates from wells on test
--
-- Preconditions  :
-- Postconditions :
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSumEstDILRate(
            p_result_no    NUMBER
)
RETURN NUMBER
--</EC-DOC>
IS

   CURSOR c_pwel_result_sum IS
   SELECT SUM(est_diluent_rate) sum_diluent_rate
   FROM pwel_result
   WHERE result_no = p_result_no;

   ln_sum  NUMBER;


BEGIN

   -- aggregated estimates for Test device
   FOR curWellSum IN c_pwel_result_sum LOOP

     ln_sum :=   curWellSum.sum_diluent_rate;

   END LOOP;

   RETURN ln_sum;


END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getSumEstPWRWATRate
-- Description    : Find sum of estimated powerwater rates from wells on test
--
-- Preconditions  :
-- Postconditions :
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSumEstPWRWATRate(p_result_no    NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

   CURSOR c_pwel_result_sum IS
   SELECT SUM(est_powerwater_rate) sum_powerwater_rate
   FROM pwel_result
   WHERE result_no = p_result_no;

   ln_sum  NUMBER;


BEGIN

   -- aggregated estimates for Test device
   FOR curWellSum IN c_pwel_result_sum LOOP

     ln_sum :=   curWellSum.sum_powerwater_rate;

   END LOOP;

   RETURN ln_sum;

END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDiluentShrinkageFromStream
-- Description    : Find the shrinkage factor to use for the diluent stream
--
-- Preconditions  :
-- Postconditions :
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getDiluentShrinkageFromStream(p_result_no NUMBER, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

   -- The logic here is a a bit fuzzy,
   -- Try to find shrinkage from a quality stream for diluent
   -- NOTYET : If several exists, choose the one belonging to the same parent in the group model

   CURSOR c_strm_ref_value IS
   SELECT v.daytime, v.SHRINKAGE_FACTOR
   FROM strm_reference_value v, strm_version sv, stream s
   WHERE sv.object_id = s.object_id
   AND v.object_id = s.object_id
   AND v.daytime >= sv.daytime
   AND v.daytime < Nvl(sv.end_date,v.daytime + 1)
   AND sv.stream_category = 'OIL_DILUENT'
   AND sv.stream_type = 'Q'
   ORDER BY s.object_code, v.daytime DESC;

   ln_shrinkage NUMBER;


BEGIN

  FOR curStrm IN c_strm_ref_value LOOP

      ln_shrinkage :=  curStrm.SHRINKAGE_FACTOR;

      -- based on sorting, the first we find is the most relevant
      EXIT;

  END LOOP;

  RETURN ln_shrinkage;

END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : CalcTriangularVMD
-- Description    : Perform Triangular calculations on Volume, Mass, Denisity
--
-- Preconditions  :
-- Postconditions :
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE CalcTriangularVMD( p_vol         IN OUT NUMBER
                            ,p_Mass        IN OUT NUMBER
                            ,p_Density     IN OUT NUMBER
                            ,p_coltype     IN VARCHAR2
                            ,p_rowchanged  IN OUT VARCHAR2
                            ,p_errorfound  IN OUT VARCHAR2
                            ,p_missingcols IN OUT VARCHAR2
                               )
--</EC-DOC>
IS
  lb_error_found  BOOLEAN := FALSE;

BEGIN

   p_missingcols := NULL;

   -- Triangular Calculations
   IF p_vol     IS NULL
   OR p_Mass    IS NULL
   OR p_Density IS NULL THEN

       IF  p_vol IS NULL
       AND p_Density IS NOT NULL AND p_Density <> 0
       AND p_Mass IS NOT NULL THEN

         p_vol := p_Mass / p_Density;
         p_rowchanged := 'Y';

       ELSE

         lb_error_found := TRUE;
         p_errorfound := 'Y';


       END IF;


       IF p_Mass IS NULL
       AND p_Density IS NOT NULL
       AND p_Vol IS NOT NULL THEN

         p_Mass := p_vol * p_Density;
         p_rowchanged := 'Y';

       ELSE

         lb_error_found := TRUE;
         p_errorfound := 'Y';

       END IF;

       IF p_Density IS NULL
       AND p_Mass IS NOT NULL
       AND p_Vol IS NOT NULL AND p_Vol <> 0  THEN

         p_Density := p_Mass / p_vol;
         p_rowchanged := 'Y';

       ELSE

         lb_error_found := TRUE;
         p_errorfound := 'Y';

       END IF;

       IF lb_error_found  THEN

         IF (p_density IS NULL AND p_Mass IS NULL)
         OR (p_density IS NULL AND p_vol IS NULL)
         OR (p_mass IS NULL AND p_vol IS NULL)
         THEN

		   --error A : At least 2 of volume, mass and denisity must be not null.
		   p_missingcols := p_coltype ||' error A';

         ELSIF p_mass IS NOT NULL AND p_vol IS NOT NULL AND p_vol = 0 THEN
		   --error B : volume can not be 0 when mass <> 0.
           p_missingcols := p_coltype ||' error B';

         ELSIF p_vol IS NULL AND p_density = 0  THEN
		   --error C : Density can not be 0.
           p_missingcols := p_coltype ||' error C';

         END IF;

      END IF;

    END IF;


END CalcTriangularVMD;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : AddPreprocessLog
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CLASS_ATTRIBUTE, CLASS_ATTR_DB_MAPPING
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE AddPreprocessLog(p_missing_log   IN OUT VARCHAR2
                           ,p_missing_cols IN     VARCHAR2
                           ,p_class_name   IN     VARCHAR2
                           ,p_column_name  IN     VARCHAR2
                           )
--</EC-DOC>
IS

CURSOR c_class_attr_active(cp_class_name VARCHAR2, cp_column_name VARCHAR2) IS
SELECT 1
FROM class_attribute ca, class_attr_db_mapping db, class_attr_presentation pr
WHERE ca.class_name = db.class_name
AND ca.class_name = pr.class_name
AND   ca.attribute_name = db.attribute_name
AND ca.attribute_name = pr.attribute_name
AND   db.class_name = cp_class_name
AND   db.db_sql_syntax = cp_column_name
AND   Nvl(ca.disabled_ind,'N') = 'N'
AND lower(pr.static_presentation_syntax) not like '%viewhidden=true%';

BEGIN

   IF p_missing_cols IS NOT NULL THEN  -- Find out if we should log it as an error

     FOR curAttr IN c_class_attr_active(p_class_name,p_column_name) LOOP

        p_missing_log := SUBSTR((p_missing_log || p_missing_cols),1,30000);
        EXIT;

     END LOOP;

   END IF;

END AddPreprocessLog;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : initEQPMForPreProcess
-- Description    :
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : EQPM_RESULT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE initEQPMForPreProcess(p_result_no NUMBER, p_calc_base VARCHAR2)
--</EC-DOC>
IS

BEGIN

  IF p_calc_base = 'VOLUME' THEN
    UPDATE EQPM_RESULT SET
    net_cond_mass_rate_adj = NULL,
    net_oil_mass_rate_adj = NULL,
    tot_water_mass_rate_adj = NULL,
    gas_mass_rate_adj = NULL,
    net_cond_rate_adj = NULL,
    net_oil_rate_adj = NULL,
    tot_water_rate_adj = NULL,
    gas_rate_adj = NULL,
    gas_mass_rate = NULL,
    gas_mass_rate_flc = NULL,
    mpm_cond_mass_rate = NULL,
    mpm_cond_mass_rate_flc = NULL,
    mpm_gas_mass_rate = NULL,
    mpm_gas_mass_rate_flc = NULL,
    mpm_gas_mass_rate_raw = NULL,
    mpm_oil_mass_rate = NULL,
    mpm_oil_mass_rate_flc = NULL,
    mpm_oil_mass_rate_raw = NULL,
    mpm_water_mass_rate = NULL,
    mpm_water_mass_rate_flc = NULL,
    mpm_water_mass_rate_raw = NULL,
    net_cond_mass_rate = NULL,
    net_cond_mass_rate_flc = NULL,
    net_oil_mass_rate = NULL,
    net_oil_mass_rate_flc = NULL,
    tot_water_mass_rate = NULL,
    tot_water_mass_rate_flc = NULL
    WHERE RESULT_NO = p_result_no;

  ELSIF p_calc_base = 'MASS' THEN
    UPDATE EQPM_RESULT SET
    net_cond_mass_rate_adj = NULL,
    net_oil_mass_rate_adj = NULL,
    tot_water_mass_rate_adj = NULL,
    gas_mass_rate_adj = NULL,
    net_cond_rate_adj = NULL,
    net_oil_rate_adj = NULL,
    tot_water_rate_adj = NULL,
    gas_rate_adj = NULL,
    gas_rate = NULL,
    gas_rate_flc = NULL,
    mpm_cond_rate = NULL,
    mpm_cond_rate_flc = NULL,
    mpm_gas_rate = NULL,
    mpm_gas_rate_flc = NULL,
    mpm_gas_rate_raw = NULL,
    mpm_oil_rate = NULL,
    mpm_oil_rate_flc = NULL,
    mpm_oil_rate_raw = NULL,
    mpm_water_rate = NULL,
    mpm_water_rate_flc = NULL,
    mpm_water_rate_raw = NULL,
    net_cond_rate = NULL,
    net_cond_rate_flc = NULL,
    net_oil_rate = NULL,
    net_oil_rate_flc = NULL,
    tot_water_rate = NULL,
    tot_water_rate_flc = NULL
    WHERE RESULT_NO = p_result_no;
  END IF;

END initEQPMForPreProcess;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : initPFLWForPreProcess
-- Description    :
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PFLW_RESULT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE initPFLWForPreProcess(p_result_no NUMBER, p_calc_base VARCHAR2)
--</EC-DOC>
IS

BEGIN

  IF p_calc_base = 'VOLUME' THEN
    UPDATE PFLW_RESULT SET
    net_cond_mass_rate_adj = NULL,
    net_oil_mass_rate_adj = NULL,
    tot_water_mass_rate_adj = NULL,
    gas_mass_rate_adj = NULL,
    net_cond_rate_adj = NULL,
    net_oil_rate_adj = NULL,
    tot_water_rate_adj = NULL,
    gas_rate_adj = NULL,
    mpm_cond_mass_rate = NULL,
    mpm_cond_mass_rate_flc = NULL,
    mpm_gas_mass_rate = NULL,
    mpm_gas_mass_rate_flc = NULL,
    mpm_gas_mass_rate_raw = NULL,
    mpm_oil_mass_rate = NULL,
    mpm_oil_mass_rate_flc = NULL,
    mpm_oil_mass_rate_raw = NULL,
    mpm_water_mass_rate = NULL,
    mpm_water_mass_rate_flc = NULL,
    mpm_water_mass_rate_raw = NULL
    WHERE RESULT_NO = p_result_no;

  ELSIF p_calc_base = 'MASS' THEN
    UPDATE PFLW_RESULT SET
    net_cond_mass_rate_adj = NULL,
    net_oil_mass_rate_adj = NULL,
    tot_water_mass_rate_adj = NULL,
    gas_mass_rate_adj = NULL,
    net_cond_rate_adj = NULL,
    net_oil_rate_adj = NULL,
    tot_water_rate_adj = NULL,
    gas_rate_adj = NULL,
    mpm_cond_rate = NULL,
    mpm_cond_rate_flc = NULL,
    mpm_gas_rate = NULL,
    mpm_gas_rate_flc = NULL,
    mpm_gas_rate_raw = NULL,
    mpm_oil_rate = NULL,
    mpm_oil_rate_flc = NULL,
    mpm_oil_rate_raw = NULL,
    mpm_water_rate = NULL,
    mpm_water_rate_flc = NULL,
    mpm_water_rate_raw = NULL
    WHERE RESULT_NO = p_result_no;
  END IF;

END initPFLWForPreProcess;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : initPWELForPreProcess
-- Description    :
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PFLW_RESULT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE initPWELForPreProcess(p_result_no NUMBER, p_calc_base VARCHAR2)
--</EC-DOC>
IS

BEGIN

  IF p_calc_base = 'VOLUME' THEN
    UPDATE PWEL_RESULT SET
    net_cond_mass_rate_adj = NULL,
    net_oil_mass_rate_adj = NULL,
    tot_water_mass_rate_adj = NULL,
    gas_mass_rate_adj = NULL,
    net_cond_rate_adj = NULL,
    net_oil_rate_adj = NULL,
    tot_water_rate_adj = NULL,
    gas_rate_adj = NULL,
    mpm_cond_mass_rate = NULL,
    mpm_cond_mass_rate_flc = NULL,
    mpm_gas_mass_rate = NULL,
    mpm_gas_mass_rate_flc = NULL,
    mpm_gas_mass_rate_raw = NULL,
    mpm_oil_mass_rate = NULL,
    mpm_oil_mass_rate_flc = NULL,
    mpm_oil_mass_rate_raw = NULL,
    mpm_water_mass_rate = NULL,
    mpm_water_mass_rate_flc = NULL,
    mpm_water_mass_rate_raw = NULL
    WHERE RESULT_NO = p_result_no;

  ELSIF p_calc_base = 'MASS' THEN
    UPDATE PWEL_RESULT SET
    net_cond_mass_rate_adj = NULL,
    net_oil_mass_rate_adj = NULL,
    tot_water_mass_rate_adj = NULL,
    gas_mass_rate_adj = NULL,
    net_cond_rate_adj = NULL,
    net_oil_rate_adj = NULL,
    tot_water_rate_adj = NULL,
    gas_rate_adj = NULL,
    mpm_cond_rate = NULL,
    mpm_cond_rate_flc = NULL,
    mpm_gas_rate = NULL,
    mpm_gas_rate_flc = NULL,
    mpm_gas_rate_raw = NULL,
    mpm_oil_rate = NULL,
    mpm_oil_rate_flc = NULL,
    mpm_oil_rate_raw = NULL,
    mpm_water_rate = NULL,
    mpm_water_rate_flc = NULL,
    mpm_water_rate_raw = NULL
    WHERE RESULT_NO = p_result_no;
  END IF;

END initPWELForPreProcess;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : PreProcessEqpmResultRow
-- Description    : Preform Triangular calculations on EqpmResult
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : EQPM_RESULT
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE PreProcessEqpmResultRow(p_result_no        IN      NUMBER
                               ,p_daytime            IN      DATE
                               ,p_duration           IN      NUMBER
                               ,p_missing_log        IN OUT  VARCHAR2
                               ,p_last_updated_by    IN      VARCHAR2 DEFAULT NULL
                               ,p_last_updated_date  IN      DATE     DEFAULT NULL
                               ,p_processing_context IN      VARCHAR2 DEFAULT NULL
                               )
--</EC-DOC>


IS

CURSOR c_eqpm_result IS
SELECT * FROM eqpm_result
WHERE result_no = p_result_no;


CURSOR cWellType IS
SELECT well_type
FROM well_version wv, pwel_result pr
WHERE wv.object_id = pr.object_id
AND   p_daytime >= wv.daytime
AND   pr.result_no = p_result_no
AND   p_daytime < Nvl(wv.end_date,p_daytime+1);

CURSOR c_pwel_ptmethod IS
SELECT ec_well_version.well_test_method(object_id, p_daytime, '<=') ptmethod
FROM pwel_result
WHERE result_no = p_result_no;

lr_eqpm_result          eqpm_result%ROWTYPE;
lv2_row_Changed         VARCHAR2(1);
lv2_error_found         VARCHAR2(1) := 'N';
lv2_missing_cols        VARCHAR2(32000) := NULL;
lv2_shrinkage           VARCHAR2(1) := 'Y';
lv2_gl_stateconv        VARCHAR2(1);
lb_raise_error          BOOLEAN;
lv2_well_type           VARCHAR2(50);
lv2_SampleDataClassName VARCHAR2(30);
lv2_source_pref	        VARCHAR2(32);
lv2_calc_base 	        VARCHAR2(32);
   ln_water_content     NUMBER;
   ln_dry_oil_rate_flc  NUMBER;
   ln_diluent_shrinkage NUMBER;
   ln_diluent_flc       NUMBER;
   ln_powerwater_flc    NUMBER;
   ln_pure_oil_rate_flc NUMBER;
   ln_flcPress          NUMBER;
   ln_flctemp           NUMBER;
   ln_stdPress          NUMBER;
   ln_stdTemp           NUMBER;
   ln_sumEstGLRate_flc  NUMBER;
   ln_water_from_oil    NUMBER;



BEGIN

  --EQPM_RESULT
  FOR curWellPTmethod IN c_pwel_ptmethod LOOP
     IF NVL(curWellPTmethod.ptmethod,'NO_SHRINKAGE_VOL') = 'NO_SHRINKAGE_VOL' THEN
         lv2_shrinkage := 'N';
     END IF;
  END LOOP;

  FOR curEqpm IN c_eqpm_result LOOP
    lr_eqpm_result := curEqpm;
    lv2_row_Changed := 'N';

    lv2_SampleDataClassName  := getSampleDataClassName(curEqpm.object_id, p_daytime);

   -- Rate/volume conversion on raw input data

   IF Nvl(p_duration,0) <> 0 THEN -- Only then is it possible to convert rate/volume

      IF lr_eqpm_result.OIL_OUT_VOL_RAW IS NULL AND lr_eqpm_result.OIL_OUT_RATE_RAW IS NOT NULL THEN
           lr_eqpm_result.OIL_OUT_VOL_RAW := p_duration * lr_eqpm_result.OIL_OUT_RATE_RAW/24;
           lv2_row_Changed := 'Y';

      ELSIF lr_eqpm_result.OIL_OUT_VOL_RAW IS NOT NULL AND lr_eqpm_result.OIL_OUT_RATE_RAW IS NULL AND p_duration <> 0 THEN
           lr_eqpm_result.OIL_OUT_RATE_RAW := (lr_eqpm_result.OIL_OUT_VOL_RAW/p_duration)*24;
           lv2_row_Changed := 'Y';

      END IF;

      IF lr_eqpm_result.GAS_OUT_VOL_RAW IS NULL AND lr_eqpm_result.GAS_OUT_RATE_RAW IS NOT NULL THEN
           lr_eqpm_result.GAS_OUT_VOL_RAW := p_duration * lr_eqpm_result.GAS_OUT_RATE_RAW/24;
           lv2_row_Changed := 'Y';

      ELSIF lr_eqpm_result.GAS_OUT_VOL_RAW IS NOT NULL AND lr_eqpm_result.GAS_OUT_RATE_RAW IS NULL AND p_duration <> 0 THEN
           lr_eqpm_result.GAS_OUT_RATE_RAW := (lr_eqpm_result.GAS_OUT_VOL_RAW/p_duration)*24;
           lv2_row_Changed := 'Y';

      END IF;

      IF lr_eqpm_result.WATER_OUT_VOL_RAW IS NULL AND lr_eqpm_result.WATER_OUT_RATE_RAW IS NOT NULL THEN
           lr_eqpm_result.WATER_OUT_VOL_RAW := p_duration * lr_eqpm_result.WATER_OUT_RATE_RAW/24;
           lv2_row_Changed := 'Y';

      ELSIF lr_eqpm_result.WATER_OUT_VOL_RAW IS NOT NULL AND lr_eqpm_result.WATER_OUT_RATE_RAW IS NULL AND p_duration <> 0 THEN
           lr_eqpm_result.WATER_OUT_RATE_RAW := (lr_eqpm_result.WATER_OUT_VOL_RAW/p_duration)*24;
           lv2_row_Changed := 'Y';

      END IF;

      NULL;

    END IF;

   -- Meter correction In future multiply by x.xx
   lr_eqpm_result.GAS_OUT_RATE_FLC := Nvl(lr_eqpm_result.GAS_OUT_RATE_RAW,lr_eqpm_result.GAS_OUT_RATE_FLC) ;
   lr_eqpm_result.OIL_OUT_RATE_FLC := Nvl(lr_eqpm_result.OIL_OUT_RATE_RAW,lr_eqpm_result.OIL_OUT_RATE_FLC) ;
   lr_eqpm_result.WATER_OUT_RATE_FLC := Nvl(lr_eqpm_result.WATER_OUT_RATE_RAW,lr_eqpm_result.WATER_OUT_RATE_FLC) ;

   -- Figure out preferred data source; EVENT or METER
   lv2_source_pref  := Nvl(ec_eqpm_version.pt_source_pref(lr_eqpm_result.object_id,p_daytime,'<='),'EVENT');

   -- Figure out calculation base; VOLUME or MASS
   lv2_calc_base  := Nvl(ec_eqpm_version.pt_calc_base(lr_eqpm_result.object_id,p_daytime,'<='),'VOLUME');

   -- Figure out gas lift state conversion; Y or N
   lv2_gl_stateconv  := Nvl(ec_eqpm_version.pt_gl_stateconv(lr_eqpm_result.object_id,p_daytime,'<='),'N');

   -- Retrieve preferred water content
   IF    lv2_calc_base = 'VOLUME' THEN
         IF    lv2_source_pref = 'EVENT' THEN ln_water_content := Nvl(Nvl(lr_eqpm_result.event_oil_out_bsw,lr_eqpm_result.water_in_oil_out),0);
         ELSIF lv2_source_pref = 'METER' THEN ln_water_content := Nvl(Nvl(lr_eqpm_result.water_in_oil_out,lr_eqpm_result.event_oil_out_bsw),0);
         END IF;
   ELSIF lv2_calc_base = 'MASS' THEN
         IF    lv2_source_pref = 'EVENT' THEN ln_water_content := Nvl(Nvl(lr_eqpm_result.event_oil_out_bsw_wt,lr_eqpm_result.water_in_oil_out_wt),0);
         ELSIF lv2_source_pref = 'METER' THEN ln_water_content := Nvl(Nvl(lr_eqpm_result.water_in_oil_out_wt,lr_eqpm_result.event_oil_out_bsw_wt),0);
         END IF;
   END IF;

   --ln_water_content :=  Nvl(Nvl(lr_eqpm_result.water_in_oil_out,lr_eqpm_result.event_oil_out_bsw),0);

   -- 4. Calculate pure phase rates for oil
   ln_dry_oil_rate_flc := lr_eqpm_result.oil_out_rate_flc * (1-ln_water_content);


   IF lv2_shrinkage = 'N' THEN
       ln_diluent_shrinkage := 1;
   ELSE
       ln_diluent_shrinkage := getDiluentShrinkageFromStream(lr_eqpm_result.result_no,p_daytime);
   END IF;

   ln_diluent_flc := getSumEstDILRate(lr_eqpm_result.result_no) * (1/ln_diluent_shrinkage);
   ln_pure_oil_rate_flc := ln_dry_oil_rate_flc - Nvl(ln_diluent_flc,0);

   FOR curWellType IN cWellType LOOP

     lv2_well_type := curWellType.well_type;

   END LOOP;

   IF lv2_well_type IN ('OP','OPGI','OPSI','GP2') THEN
       IF    lv2_calc_base = 'VOLUME' THEN
              lr_eqpm_result.net_oil_rate_flc := ln_pure_oil_rate_flc;
       ELSIF lv2_calc_base = 'MASS' THEN
              lr_eqpm_result.net_oil_mass_rate_flc := ln_pure_oil_rate_flc;
       END IF;

   ELSIF lv2_well_type IN ('CP','GP','GPI') THEN
       IF    lv2_calc_base = 'VOLUME' THEN
             lr_eqpm_result.net_cond_rate_flc := ln_pure_oil_rate_flc;
       ELSIF lv2_calc_base = 'MASS' THEN
             lr_eqpm_result.net_cond_mass_rate_flc := ln_pure_oil_rate_flc;
       END IF;

   END IF;

   -- 5. Calculate pure phase rates for gas
   ln_flcPress := EcDp_unit.convertValue(lr_eqpm_result.tdev_press, EcDp_unit.GetUnitFromLogical(ec_class_attr_presentation.uom_code(lr_eqpm_result.data_class_name,'TDEV_PRESS')),'MBAR');
   ln_flctemp  := EcDp_unit.convertValue(lr_eqpm_result.tdev_temp, EcDp_unit.GetUnitFromLogical(ec_class_attr_presentation.uom_code(lr_eqpm_result.data_class_name,'TDEV_TEMP')),'K');
   ln_stdPress := Ec_Ctrl_System_Attribute.Attribute_Value(p_daytime, 'REF_AIR_PRESS', '<=');  --reference pressure in millibar
   ln_stdTemp  := EcDp_unit.convertValue(Ec_Ctrl_System_Attribute.Attribute_Value(p_daytime, 'REF_AIR_TEMP', '<='),'C','K'); -- 15C converted TO kelvin

   IF lv2_shrinkage = 'Y' and lv2_gl_stateconv = 'Y' and lv2_calc_base = 'VOLUME' THEN
      ln_sumEstGLRate_flc := getSumEstGLRate(lr_eqpm_result.result_no) * (ln_stdPress/ln_flcPress) * (ln_flcTemp/ln_stdTemp);
   ELSE
       ln_sumEstGLRate_flc := getSumEstGLRate(lr_eqpm_result.result_no);
   END IF;

   IF    lv2_calc_base = 'VOLUME' THEN
         lr_eqpm_result.gas_rate_flc :=  lr_eqpm_result.gas_out_rate_flc - Nvl(ln_sumEstGLRate_flc,0);
   ELSIF   lv2_calc_base = 'MASS' THEN
           lr_eqpm_result.gas_mass_rate_flc :=  lr_eqpm_result.gas_out_rate_flc - Nvl(ln_sumEstGLRate_flc,0);
   END IF;


   -- 6. Calculate pure phase rates for water
   ln_powerwater_flc := getSumEstPWRWATRate(lr_eqpm_result.result_no);
   ln_water_from_oil := nvl(lr_eqpm_result.oil_out_rate_flc,0) * ln_water_content;
   IF    lv2_calc_base = 'VOLUME' THEN
         lr_eqpm_result.tot_water_rate_flc := nvl(lr_eqpm_result.water_out_rate_flc,0) +  ln_water_from_oil - nvl(ln_powerwater_flc,0);
   ELSIF   lv2_calc_base = 'MASS' THEN
           lr_eqpm_result.tot_water_mass_rate_flc := nvl(lr_eqpm_result.water_out_rate_flc,0) +  ln_water_from_oil - nvl(ln_powerwater_flc,0);
   END IF;



    -- Triangular Calculations


    -- NET_OIL
   CalcTriangularVMD(lr_eqpm_result.NET_OIL_RATE, lr_eqpm_result.NET_OIL_MASS_RATE,lr_eqpm_result.NET_OIL_DENSITY
                     ,';EQPM.NET_OIL',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'NET_OIL_RATE');



    -- GAS
   CalcTriangularVMD(lr_eqpm_result.GAS_RATE, lr_eqpm_result.GAS_MASS_RATE,lr_eqpm_result.GAS_DENSITY
                     ,';EQPM.GAS',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'GAS_RATE');


    -- TOT_WATER
   CalcTriangularVMD(lr_eqpm_result.TOT_WATER_RATE, lr_eqpm_result.TOT_WATER_MASS_RATE,lr_eqpm_result.TOT_WATER_DENSITY
                     ,';EQPM.TOT_WATER',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'TOT_WATER_RATE');

    -- NET_COND

   CalcTriangularVMD(lr_eqpm_result.NET_COND_RATE, lr_eqpm_result.NET_COND_MASS_RATE,lr_eqpm_result.NET_COND_DENSITY
                     ,';EQPM.NET_COND',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'NET_COND_RATE');


    -- NET_OIL_FLC
   CalcTriangularVMD(lr_eqpm_result.NET_OIL_RATE_FLC, lr_eqpm_result.NET_OIL_MASS_RATE_FLC,lr_eqpm_result.NET_OIL_DENSITY_FLC
                     ,';EQPM.NET_OIL_FLC',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'NET_OIL_FLC');

    -- GAS_FLC
   CalcTriangularVMD(lr_eqpm_result.GAS_RATE_FLC, lr_eqpm_result.GAS_MASS_RATE_FLC,lr_eqpm_result.GAS_DENSITY_FLC
                     ,';EQPM.GAS_FLC',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'GAS_RATE_FLC');

    -- TOT_WATER_FLC
   CalcTriangularVMD(lr_eqpm_result.TOT_WATER_RATE_FLC, lr_eqpm_result.TOT_WATER_MASS_RATE_FLC,lr_eqpm_result.TOT_WATER_DENSITY_FLC
                     ,';EQPM.TOT_WATER_FLC',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'TOT_WATER_RATE_FLC');

   -- NET_COND_RATE_FLC
   CalcTriangularVMD(lr_eqpm_result.NET_COND_RATE_FLC, lr_eqpm_result.NET_COND_MASS_RATE_FLC,lr_eqpm_result.NET_COND_DENSITY_FLC
                     ,';EQPM.NET_COND_FLC',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'TOT_WATER_RATE_FLC');


   -- NET_COND_RATE_ADJ
   CalcTriangularVMD(lr_eqpm_result.NET_COND_RATE_ADJ, lr_eqpm_result.NET_COND_MASS_RATE_ADJ,lr_eqpm_result.NET_COND_DENSITY_ADJ
                     ,';EQPM.NET_COND_ADJ',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'TOT_WATER_RATE_FLC');

   -- NET_COND_RATE
   CalcTriangularVMD(lr_eqpm_result.NET_COND_RATE, lr_eqpm_result.NET_COND_MASS_RATE,lr_eqpm_result.NET_COND_DENSITY
                     ,';EQPM.NET_COND',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'TOT_WATER_RATE_FLC');


   -- MPM_COND_RATE
   CalcTriangularVMD(lr_eqpm_result.MPM_COND_RATE, lr_eqpm_result.MPM_COND_MASS_RATE,lr_eqpm_result.MPM_COND_DENSITY
                     ,';EQPM.MPM_COND',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'TOT_WATER_RATE_FLC');

   -- MPM_COND_RATE_FLC
   CalcTriangularVMD(lr_eqpm_result.MPM_COND_RATE_FLC, lr_eqpm_result.MPM_COND_MASS_RATE_FLC,lr_eqpm_result.MPM_COND_DENSITY_FLC
                     ,';EQPM.MPM_COND_FLC',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'TOT_WATER_RATE_FLC');


/*
    -- OIL_OUT
   CalcTriangularVMD(lr_eqpm_result.OIL_OUT_RATE, lr_eqpm_result.OIL_OUT_MASS_RATE,lr_eqpm_result.OIL_OUT_DENSITY
                     ,';EQPM.OIL_OUT',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'OIL_OUT_RATE');


    -- GAS_OUT
   CalcTriangularVMD(lr_eqpm_result.GAS_OUT_RATE, lr_eqpm_result.GAS_OUT_MASS_RATE,lr_eqpm_result.GAS_OUT_DENSITY
                     ,';EQPM.GAS_OUT',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'GAS_OUT_RATE');

    -- WATER_OUT
   CalcTriangularVMD(lr_eqpm_result.WATER_OUT_RATE , lr_eqpm_result.WATER_OUT_MASS_RATE ,lr_eqpm_result.WATER_OUT_DENSITY
                     ,';EQPM.WATER_OUT',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'WATER_OUT_RATE');

    -- OIL_OUT_FLC
   CalcTriangularVMD(lr_eqpm_result.OIL_OUT_RATE_FLC, lr_eqpm_result.OIL_OUT_MASS_RATE_FLC,lr_eqpm_result.OIL_OUT_DENSITY_FLC
                     ,';EQPM.OIL_OUT_FLC',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'OIL_OUT_RATE_FLC');

    -- GAS_OUT_FLC
   CalcTriangularVMD(lr_eqpm_result.GAS_OUT_RATE_FLC, lr_eqpm_result.GAS_OUT_MASS_RATE_FLC,lr_eqpm_result.GAS_OUT_DENSITY_FLC
                     ,';EQPM.GAS_OUT_FLC',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'GAS_OUT_RATE_FLC');

    -- WATER_OUT_FLC
   CalcTriangularVMD(lr_eqpm_result.WATER_OUT_RATE_FLC , lr_eqpm_result.WATER_OUT_MASS_RATE_FLC ,lr_eqpm_result.WATER_OUT_DENSITY_FLC
                     ,';EQPM.WATER_OUT_FLC',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'WATER_OUT_RATE_FLC');

*/

    -- MPM_OIL
   CalcTriangularVMD(lr_eqpm_result.MPM_OIL_RATE , lr_eqpm_result.MPM_OIL_MASS_RATE ,lr_eqpm_result.MPM_OIL_DENSITY
                     ,';EQPM.MPM_OIL',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'MPM_OIL_RATE');

    -- MPM_GAS
   CalcTriangularVMD(lr_eqpm_result.MPM_GAS_RATE , lr_eqpm_result.MPM_GAS_MASS_RATE ,lr_eqpm_result.MPM_GAS_DENSITY
                     ,';EQPM.MPM_GAS',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'MPM_GAS_RATE');

    -- MPM_WATER
   CalcTriangularVMD(lr_eqpm_result.MPM_WATER_RATE , lr_eqpm_result.MPM_WATER_MASS_RATE ,lr_eqpm_result.MPM_WATER_DENSITY
                     ,';EQPM.MPM_WATER',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'MPM_WATER_RATE');

    -- MPM_COND
   CalcTriangularVMD(lr_eqpm_result.MPM_COND_RATE , lr_eqpm_result.MPM_COND_MASS_RATE ,lr_eqpm_result.MPM_COND_DENSITY
                     ,';EQPM.MPM_COND',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'MPM_COND_RATE');


    -- MPM_OIL_FLC
   CalcTriangularVMD(lr_eqpm_result.MPM_OIL_RATE_FLC , lr_eqpm_result.MPM_OIL_MASS_RATE_FLC ,lr_eqpm_result.MPM_OIL_DENSITY_FLC
                     ,';EQPM.MPM_OIL_FLC',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'MPM_OIL_RATE_FLC');

    -- MPM_GAS_FLC
   CalcTriangularVMD(lr_eqpm_result.MPM_GAS_RATE_FLC , lr_eqpm_result.MPM_GAS_MASS_RATE_FLC ,lr_eqpm_result.MPM_GAS_DENSITY_FLC
                     ,';EQPM.MPM_GAS_FLC',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'MPM_GAS_RATE_FLC');

    -- MPM_WATER_FLC
   CalcTriangularVMD(lr_eqpm_result.MPM_WATER_RATE_FLC , lr_eqpm_result.MPM_WATER_MASS_RATE_FLC ,lr_eqpm_result.MPM_WATER_DENSITY_FLC
                     ,';EQPM.MPM_WATER_FLC',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'MPM_WATER_RATE_FLC');


   -- MPM_OIL_RAW
   CalcTriangularVMD(lr_eqpm_result.MPM_OIL_RATE_RAW , lr_eqpm_result.MPM_OIL_MASS_RATE_RAW ,lr_eqpm_result.MPM_OIL_DENSITY_RAW
                 ,';EQPM.MPM_OIL_RAW',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'MPM_OIL_RATE_RAW');

   -- MPM_GAS_RAW
   CalcTriangularVMD(lr_eqpm_result.MPM_GAS_RATE_RAW , lr_eqpm_result.MPM_GAS_MASS_RATE_RAW ,lr_eqpm_result.MPM_GAS_DENSITY_RAW
                 ,';EQPM.MPM_GAS_RAW',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'MPM_GAS_RATE_RAW');

   -- MPM_WATER_RAW
   CalcTriangularVMD(lr_eqpm_result.MPM_WATER_RATE_RAW , lr_eqpm_result.MPM_WATER_MASS_RATE_RAW ,lr_eqpm_result.MPM_WATER_DENSITY_RAW
                 ,';EQPM.MPM_WATER_RAW',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'MPM_WATER_RATE_RAW');


       UPDATE eqpm_result
       SET
            OIL_OUT_VOL_RAW       = lr_eqpm_result.OIL_OUT_VOL_RAW
           ,GAS_OUT_VOL_RAW       = lr_eqpm_result.GAS_OUT_VOL_RAW
           ,WATER_OUT_VOL_RAW     = lr_eqpm_result.WATER_OUT_VOL_RAW

           ,OIL_OUT_RATE_RAW       = lr_eqpm_result.OIL_OUT_RATE_RAW
           ,GAS_OUT_RATE_RAW       = lr_eqpm_result.GAS_OUT_RATE_RAW
           ,WATER_OUT_RATE_RAW     = lr_eqpm_result.WATER_OUT_RATE_RAW

           ,NET_OIL_RATE          = lr_eqpm_result.NET_OIL_RATE
           ,NET_OIL_MASS_RATE     = lr_eqpm_result.NET_OIL_MASS_RATE
           ,NET_OIL_DENSITY       = lr_eqpm_result.NET_OIL_DENSITY

           ,GAS_RATE              = lr_eqpm_result.GAS_RATE
           ,GAS_MASS_RATE         = lr_eqpm_result.GAS_MASS_RATE
           ,GAS_DENSITY           = lr_eqpm_result.GAS_DENSITY

           ,TOT_WATER_RATE        = lr_eqpm_result.TOT_WATER_RATE
           ,TOT_WATER_MASS_RATE   = lr_eqpm_result.TOT_WATER_MASS_RATE
           ,TOT_WATER_DENSITY     = lr_eqpm_result.TOT_WATER_DENSITY

           ,NET_OIL_RATE_FLC      = lr_eqpm_result.NET_OIL_RATE_FLC
           ,NET_OIL_MASS_RATE_FLC = lr_eqpm_result.NET_OIL_MASS_RATE_FLC
           ,NET_OIL_DENSITY_FLC   = lr_eqpm_result.NET_OIL_DENSITY_FLC

           ,GAS_RATE_FLC          = lr_eqpm_result.GAS_RATE_FLC
           ,GAS_MASS_RATE_FLC     = lr_eqpm_result.GAS_MASS_RATE_FLC
           ,GAS_DENSITY_FLC       = lr_eqpm_result.GAS_DENSITY_FLC

           ,TOT_WATER_RATE_FLC      = lr_eqpm_result.TOT_WATER_RATE_FLC
           ,TOT_WATER_MASS_RATE_FLC = lr_eqpm_result.TOT_WATER_MASS_RATE_FLC
           ,TOT_WATER_DENSITY_FLC   = lr_eqpm_result.TOT_WATER_DENSITY_FLC

           ,NET_COND_RATE_FLC      = lr_eqpm_result.NET_COND_RATE_FLC
           ,NET_COND_MASS_RATE_FLC = lr_eqpm_result.NET_COND_MASS_RATE_FLC
           ,NET_COND_DENSITY_FLC   = lr_eqpm_result.NET_COND_DENSITY_FLC

           ,NET_COND_RATE_ADJ      = lr_eqpm_result.NET_COND_RATE_ADJ
           ,NET_COND_MASS_RATE_ADJ = lr_eqpm_result.NET_COND_MASS_RATE_ADJ
           ,NET_COND_DENSITY_ADJ   = lr_eqpm_result.NET_COND_DENSITY_ADJ

           ,NET_COND_RATE      = lr_eqpm_result.NET_COND_RATE
           ,NET_COND_MASS_RATE = lr_eqpm_result.NET_COND_MASS_RATE
           ,NET_COND_DENSITY   = lr_eqpm_result.NET_COND_DENSITY

           ,MPM_COND_RATE      = lr_eqpm_result.MPM_COND_RATE
           ,MPM_COND_MASS_RATE = lr_eqpm_result.MPM_COND_MASS_RATE
           ,MPM_COND_DENSITY   = lr_eqpm_result.MPM_COND_DENSITY

           ,MPM_COND_RATE_FLC      = lr_eqpm_result.MPM_COND_RATE_FLC
           ,MPM_COND_MASS_RATE_FLC = lr_eqpm_result.MPM_COND_MASS_RATE_FLC
           ,MPM_COND_DENSITY_FLC   = lr_eqpm_result.MPM_COND_DENSITY_FLC

/*
           ,OIL_OUT_RATE          = lr_eqpm_result.OIL_OUT_RATE
           ,OIL_OUT_MASS_RATE     = lr_eqpm_result.OIL_OUT_MASS_RATE
           ,OIL_OUT_DENSITY       = lr_eqpm_result.OIL_OUT_DENSITY

           ,GAS_OUT_RATE          = lr_eqpm_result.GAS_OUT_RATE
           ,GAS_OUT_MASS_RATE     = lr_eqpm_result.GAS_OUT_MASS_RATE
           ,GAS_OUT_DENSITY       = lr_eqpm_result.GAS_OUT_DENSITY

           ,WATER_OUT_RATE        = lr_eqpm_result.WATER_OUT_RATE
           ,WATER_OUT_MASS_RATE   = lr_eqpm_result.WATER_OUT_MASS_RATE
           ,WATER_OUT_DENSITY     = lr_eqpm_result.WATER_OUT_DENSITY

           ,OIL_OUT_RATE_FLC      = lr_eqpm_result.OIL_OUT_RATE_FLC
           ,OIL_OUT_MASS_RATE_FLC = lr_eqpm_result.OIL_OUT_MASS_RATE_FLC
           ,OIL_OUT_DENSITY_FLC   = lr_eqpm_result.OIL_OUT_DENSITY_FLC

           ,GAS_OUT_RATE_FLC      = lr_eqpm_result.GAS_OUT_RATE_FLC
           ,GAS_OUT_MASS_RATE_FLC = lr_eqpm_result.GAS_OUT_MASS_RATE_FLC
           ,GAS_OUT_DENSITY_FLC   = lr_eqpm_result.GAS_OUT_DENSITY_FLC

           ,WATER_OUT_RATE_FLC       = lr_eqpm_result.WATER_OUT_RATE_FLC
           ,WATER_OUT_MASS_RATE_FLC  = lr_eqpm_result.WATER_OUT_MASS_RATE_FLC
           ,WATER_OUT_DENSITY_FLC    = lr_eqpm_result.WATER_OUT_DENSITY_FLC
*/
           ,MPM_OIL_RATE          = lr_eqpm_result.MPM_OIL_RATE
           ,MPM_OIL_MASS_RATE     = lr_eqpm_result.MPM_OIL_MASS_RATE
           ,MPM_OIL_DENSITY       = lr_eqpm_result.MPM_OIL_DENSITY

           ,MPM_GAS_RATE          = lr_eqpm_result.MPM_GAS_RATE
           ,MPM_GAS_MASS_RATE     = lr_eqpm_result.MPM_GAS_MASS_RATE
           ,MPM_GAS_DENSITY       = lr_eqpm_result.MPM_GAS_DENSITY

           ,MPM_WATER_RATE        = lr_eqpm_result.MPM_WATER_RATE
           ,MPM_WATER_MASS_RATE   = lr_eqpm_result.MPM_WATER_MASS_RATE
           ,MPM_WATER_DENSITY     = lr_eqpm_result.MPM_WATER_DENSITY

           ,MPM_OIL_RATE_FLC      = lr_eqpm_result.MPM_OIL_RATE_FLC
           ,MPM_OIL_MASS_RATE_FLC = lr_eqpm_result.MPM_OIL_MASS_RATE_FLC
           ,MPM_OIL_DENSITY_FLC   = lr_eqpm_result.MPM_OIL_DENSITY_FLC

           ,MPM_GAS_RATE_FLC      = lr_eqpm_result.MPM_GAS_RATE_FLC
           ,MPM_GAS_MASS_RATE_FLC = lr_eqpm_result.MPM_GAS_MASS_RATE_FLC
           ,MPM_GAS_DENSITY_FLC   = lr_eqpm_result.MPM_GAS_DENSITY_FLC

           ,MPM_WATER_RATE_FLC      = lr_eqpm_result.MPM_WATER_RATE_FLC
           ,MPM_WATER_MASS_RATE_FLC = lr_eqpm_result.MPM_WATER_MASS_RATE_FLC
           ,MPM_WATER_DENSITY_FLC   = lr_eqpm_result.MPM_WATER_DENSITY_FLC

           ,MPM_OIL_RATE_RAW        = lr_eqpm_result.MPM_OIL_RATE_RAW
           ,MPM_OIL_MASS_RATE_RAW   = lr_eqpm_result.MPM_OIL_MASS_RATE_RAW
           ,MPM_OIL_DENSITY_RAW     = lr_eqpm_result.MPM_OIL_DENSITY_RAW

           ,MPM_GAS_RATE_RAW        = lr_eqpm_result.MPM_GAS_RATE_RAW
           ,MPM_GAS_MASS_RATE_RAW   = lr_eqpm_result.MPM_GAS_MASS_RATE_RAW
           ,MPM_GAS_DENSITY_RAW     = lr_eqpm_result.MPM_GAS_DENSITY_RAW

           ,MPM_WATER_RATE_RAW      = lr_eqpm_result.MPM_WATER_RATE_RAW
           ,MPM_WATER_MASS_RATE_RAW = lr_eqpm_result.MPM_WATER_MASS_RATE_RAW
           ,MPM_WATER_DENSITY_RAW   = lr_eqpm_result.MPM_WATER_DENSITY_RAW

           ,LAST_UPDATED_BY       = Nvl(p_LAST_UPDATED_BY,USER)
           ,LAST_UPDATED_DATE     = Nvl(lr_eqpm_result.LAST_UPDATED_DATE, EcDp_Date_Time.getCurrentSysdate)
       WHERE object_id = lr_eqpm_result.object_id
       AND   result_no = lr_eqpm_result.result_no;


  END LOOP;

END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : PreProcessPwelResultRow
-- Description    : Preform Triangular calculations on PwelResult
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PWEL_RESULT
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE PreProcessPwelResultRow(p_result_no        IN      NUMBER
                               ,p_daytime            IN      DATE
                               ,p_duration           IN      NUMBER
                               ,p_missing_log        IN OUT  VARCHAR2
                               ,p_last_updated_by    IN      VARCHAR2 DEFAULT NULL
                               ,p_last_updated_date  IN      DATE     DEFAULT NULL
                               ,p_processing_context IN      VARCHAR2 DEFAULT NULL
                               )
--</EC-DOC>


IS

CURSOR c_pwel_result IS
SELECT * FROM pwel_result
WHERE result_no = p_result_no;

lr_pwel_result          pwel_result%ROWTYPE;
lv2_row_Changed         VARCHAR2(1);
lv2_error_found         VARCHAR2(1) := 'N';
lv2_missing_cols        VARCHAR2(32000) := NULL;
lb_raise_error          BOOLEAN;
lv2_SampleDataClassName VARCHAR2(30);



BEGIN

  --PWEL_RESULT

  FOR curwel IN c_pwel_result LOOP
    lr_pwel_result := curwel;
    lv2_row_Changed := 'N';

    lv2_SampleDataClassName  := getSampleDataClassName(curwel.object_id, p_daytime);


    -- Triangular Calculations

   CalcTriangularVMD(lr_pwel_result.MPM_OIL_RATE , lr_pwel_result.MPM_OIL_MASS_RATE ,lr_pwel_result.MPM_OIL_DENSITY
                     ,';PWEL.MPM_OIL',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'MPM_OIL_RATE');

   CalcTriangularVMD(lr_pwel_result.MPM_GAS_RATE , lr_pwel_result.MPM_GAS_RATE ,lr_pwel_result.MPM_GAS_DENSITY
                     ,';PWEL.MPM_GAS',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'MPM_GAS_RATE');

   CalcTriangularVMD(lr_pwel_result.MPM_WATER_RATE , lr_pwel_result.MPM_WATER_MASS_RATE ,lr_pwel_result.MPM_WATER_DENSITY
                     ,';PWEL.MPM_WATER',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'MPM_WATER_RATE');

   -- MPM_OIL_FLC
   CalcTriangularVMD(lr_pwel_result.MPM_OIL_RATE_FLC , lr_pwel_result.MPM_OIL_MASS_RATE_FLC ,lr_pwel_result.MPM_OIL_DENSITY_FLC
                     ,';PWEL.MPM_OIL_FLC',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'MPM_OIL_RATE_FLC');

   -- MPM_OIL_RAW
   CalcTriangularVMD(lr_pwel_result.MPM_OIL_RATE_RAW , lr_pwel_result.MPM_OIL_MASS_RATE_RAW ,lr_pwel_result.MPM_OIL_DENSITY_RAW
                     ,';PWEL.MPM_OIL_RAW',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'MPM_OIL_RATE_RAW');

   -- MPM_GAS_FLC
   CalcTriangularVMD(lr_pwel_result.MPM_GAS_RATE_FLC , lr_pwel_result.MPM_GAS_MASS_RATE_FLC ,lr_pwel_result.MPM_GAS_DENSITY_FLC
                     ,';PWEL.MPM_GAS_FLC',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'MPM_GAS_RATE_FLC');

   -- MPM_GAS_RAW
   CalcTriangularVMD(lr_pwel_result.MPM_GAS_RATE_RAW , lr_pwel_result.MPM_GAS_MASS_RATE_RAW ,lr_pwel_result.MPM_GAS_DENSITY_RAW
                     ,';PWEL.MPM_GAS_RAW',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'MPM_GAS_RATE_RAW');

   -- MPM_WATER_FLC
   CalcTriangularVMD(lr_pwel_result.MPM_WATER_RATE_FLC , lr_pwel_result.MPM_WATER_MASS_RATE_FLC ,lr_pwel_result.MPM_WATER_DENSITY_FLC
                     ,';PWEL.MPM_WATER_FLC',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'MPM_WATER_RATE_FLC');

   -- MPM_WATER_RAW
   CalcTriangularVMD(lr_pwel_result.MPM_WATER_RATE_RAW , lr_pwel_result.MPM_WATER_MASS_RATE_RAW ,lr_pwel_result.MPM_WATER_DENSITY_RAW
                     ,';PWEL.MPM_WATER_RAW',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'MPM_WATER_RATE_RAW');


   -- Estimated rates
   BEGIN
      lr_pwel_result.EST_NET_OIL_RATE     := nvl(getOilStdRateDay(lr_pwel_result.result_no, lr_pwel_result.object_id,p_daytime )        ,0);
      lr_pwel_result.EST_GAS_RATE         := nvl(getgasStdRateDay(lr_pwel_result.result_no, lr_pwel_result.object_id,p_daytime )        ,0);
      lr_pwel_result.EST_NET_COND_RATE    := nvl(getCondStdRateDay(lr_pwel_result.result_no, lr_pwel_result.object_id,p_daytime )       ,0);
      lr_pwel_result.EST_WATER_RATE       := nvl(getWatStdRateDay(lr_pwel_result.result_no, lr_pwel_result.object_id,p_daytime )        ,0);
      lr_pwel_result.EST_DILUENT_RATE     := nvl(lr_pwel_result.DILUENT_RATE, nvl(getDiluentStdRateDay(lr_pwel_result.result_no, lr_pwel_result.object_id,p_daytime ), 0));
      lr_pwel_result.EST_POWERWATER_RATE  := nvl(lr_pwel_result.POWERWATER_RATE, nvl(getPowerWaterStdRateDay(lr_pwel_result.result_no, lr_pwel_result.object_id,p_daytime ), 0));
      lr_pwel_result.EST_GL_RATE          := nvl(lr_pwel_result.GL_RATE, nvl(getGasLiftStdRateDay(lr_pwel_result.result_no, lr_pwel_result.object_id,p_daytime ), 0));


      lv2_row_Changed := 'Y';

   EXCEPTION
     WHEN OTHERS THEN
       p_missing_log := p_missing_log ||'Error calculating Estimated rates';
   END;



   IF lv2_row_Changed = 'Y' THEN

       UPDATE pwel_result
       SET  MPM_OIL_RATE          = lr_pwel_result.MPM_OIL_RATE
           ,MPM_OIL_MASS_RATE     = lr_pwel_result.MPM_OIL_MASS_RATE
           ,MPM_OIL_DENSITY       = lr_pwel_result.MPM_OIL_DENSITY

           ,MPM_GAS_RATE          = lr_pwel_result.MPM_GAS_RATE
           ,MPM_GAS_MASS_RATE     = lr_pwel_result.MPM_GAS_MASS_RATE
           ,MPM_GAS_DENSITY       = lr_pwel_result.MPM_GAS_DENSITY

           ,MPM_WATER_RATE        = lr_pwel_result.MPM_WATER_RATE
           ,MPM_WATER_MASS_RATE   = lr_pwel_result.MPM_WATER_MASS_RATE
           ,MPM_WATER_DENSITY     = lr_pwel_result.MPM_WATER_DENSITY

           ,MPM_OIL_RATE_FLC      = lr_pwel_result.MPM_OIL_RATE_FLC
           ,MPM_OIL_MASS_RATE_FLC = lr_pwel_result.MPM_OIL_MASS_RATE_FLC
           ,MPM_OIL_DENSITY_FLC   = lr_pwel_result.MPM_OIL_DENSITY_FLC

           ,MPM_OIL_RATE_RAW      = lr_pwel_result.MPM_OIL_RATE_RAW
           ,MPM_OIL_MASS_RATE_RAW = lr_pwel_result.MPM_OIL_MASS_RATE_RAW
           ,MPM_OIL_DENSITY_RAW   = lr_pwel_result.MPM_OIL_DENSITY_RAW

           ,MPM_GAS_RATE_FLC      = lr_pwel_result.MPM_GAS_RATE_FLC
           ,MPM_GAS_MASS_RATE_FLC = lr_pwel_result.MPM_GAS_MASS_RATE_FLC
           ,MPM_GAS_DENSITY_FLC   = lr_pwel_result.MPM_GAS_DENSITY_FLC

           ,MPM_GAS_RATE_RAW      = lr_pwel_result.MPM_GAS_RATE_RAW
           ,MPM_GAS_MASS_RATE_RAW = lr_pwel_result.MPM_GAS_MASS_RATE_RAW
           ,MPM_GAS_DENSITY_RAW   = lr_pwel_result.MPM_GAS_DENSITY_RAW

           ,MPM_WATER_RATE_FLC      = lr_pwel_result.MPM_WATER_RATE_FLC
           ,MPM_WATER_MASS_RATE_FLC = lr_pwel_result.MPM_WATER_MASS_RATE_FLC
           ,MPM_WATER_DENSITY_FLC   = lr_pwel_result.MPM_WATER_DENSITY_FLC

           ,MPM_WATER_RATE_RAW      = lr_pwel_result.MPM_WATER_RATE_RAW
           ,MPM_WATER_MASS_RATE_RAW = lr_pwel_result.MPM_WATER_MASS_RATE_RAW
           ,MPM_WATER_DENSITY_RAW   = lr_pwel_result.MPM_WATER_DENSITY_RAW

           ,EST_NET_OIL_RATE       = lr_pwel_result.EST_NET_OIL_RATE
           ,EST_GAS_RATE           = lr_pwel_result.EST_GAS_RATE
           ,EST_NET_COND_RATE      = lr_pwel_result.EST_NET_COND_RATE
           ,EST_WATER_RATE         = lr_pwel_result.EST_WATER_RATE
           ,EST_DILUENT_RATE       = lr_pwel_result.EST_DILUENT_RATE
           ,EST_POWERWATER_RATE    = lr_pwel_result.EST_POWERWATER_RATE
           ,EST_GL_RATE            = lr_pwel_result.EST_GL_RATE

           ,LAST_UPDATED_BY        = Nvl(p_LAST_UPDATED_BY,USER)
           ,LAST_UPDATED_DATE      = Nvl(lr_pwel_result.LAST_UPDATED_DATE, EcDp_Date_Time.getCurrentSysdate)
       WHERE object_id = lr_pwel_result.object_id
       AND   result_no = lr_pwel_result.result_no;

    END IF;

  END LOOP;


END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : PreProcessPFlwResultRow
-- Description    : Preform Triangular calculations on PflwResult
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PFLW_RESULT
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE PreProcessPFlwResultRow(p_result_no        IN      NUMBER
                               ,p_daytime            IN      DATE
                               ,p_duration           IN      NUMBER
                               ,p_missing_log        IN OUT  VARCHAR2
                               ,p_last_updated_by    IN      VARCHAR2 DEFAULT NULL
                               ,p_last_updated_date  IN      DATE     DEFAULT NULL
                               ,p_processing_context IN      VARCHAR2 DEFAULT NULL
                               )
--</EC-DOC>


IS

CURSOR c_pflw_result IS
SELECT * FROM pflw_result
WHERE result_no = p_result_no;

lr_pflw_result          pflw_result%ROWTYPE;
lv2_row_Changed         VARCHAR2(1);
lv2_error_found         VARCHAR2(1) := 'N';
lv2_missing_cols        VARCHAR2(32000) := NULL;
lb_raise_error          BOOLEAN;
lv2_SampleDataClassName VARCHAR2(30);



BEGIN

  --PFLW_RESULT

  FOR curflw IN c_pflw_result LOOP
    lr_pflw_result := curflw;
    lv2_row_Changed := 'N';

    lv2_SampleDataClassName  := getSampleDataClassName(curflw.object_id, p_daytime);


    -- Triangular Calculations

    CalcTriangularVMD(lr_pflw_result.MPM_OIL_RATE , lr_pflw_result.MPM_OIL_MASS_RATE ,lr_pflw_result.MPM_OIL_DENSITY
                        ,';PFLW.MPM_OIL',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'MPM_OIL_RATE');

    CalcTriangularVMD(lr_pflw_result.MPM_GAS_RATE , lr_pflw_result.MPM_GAS_MASS_RATE ,lr_pflw_result.MPM_GAS_DENSITY
                        ,';PFLW.MPM_GAS',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'MPM_GAS_RATE');

    CalcTriangularVMD(lr_pflw_result.MPM_WATER_RATE , lr_pflw_result.MPM_WATER_MASS_RATE ,lr_pflw_result.MPM_WATER_DENSITY
                        ,';PFLW.MPM_WATER',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'MPM_WATER_RATE');

    CalcTriangularVMD(lr_pflw_result.MPM_COND_RATE , lr_pflw_result.MPM_COND_MASS_RATE ,lr_pflw_result.MPM_COND_DENSITY
                        ,';PFLW.MPM_COND',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'MPM_COND_RATE');

   -- MPM_OIL_FLC
    CalcTriangularVMD(lr_pflw_result.MPM_OIL_RATE_FLC , lr_pflw_result.MPM_OIL_MASS_RATE_FLC ,lr_pflw_result.MPM_OIL_DENSITY_FLC
                        ,';PFLW.MPM_OIL_FLC',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'MPM_OIL_RATE_FLC');

   -- MPM_OIL_RAW
    CalcTriangularVMD(lr_pflw_result.MPM_OIL_RATE_RAW , lr_pflw_result.MPM_OIL_MASS_RATE_RAW ,lr_pflw_result.MPM_OIL_DENSITY_RAW
                        ,';PFLW.MPM_OIL_RAW',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'MPM_OIL_RATE_RAW');

   -- MPM_GAS_FLC
    CalcTriangularVMD(lr_pflw_result.MPM_GAS_RATE_FLC , lr_pflw_result.MPM_GAS_MASS_RATE_FLC ,lr_pflw_result.MPM_GAS_DENSITY_FLC
                        ,';PFLW.MPM_GAS_FLC',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'MPM_GAS_RATE_FLC');

   -- MPM_GAS_RAW
    CalcTriangularVMD(lr_pflw_result.MPM_GAS_RATE_RAW , lr_pflw_result.MPM_GAS_MASS_RATE_RAW ,lr_pflw_result.MPM_GAS_DENSITY_RAW
                        ,';PFLW.MPM_GAS_RAW',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'MPM_GAS_RATE_RAW');

   -- MPM_WATER_FLC
    CalcTriangularVMD(lr_pflw_result.MPM_WATER_RATE_FLC , lr_pflw_result.MPM_WATER_MASS_RATE_FLC ,lr_pflw_result.MPM_WATER_DENSITY_FLC
                        ,';PFLW.MPM_WATER_FLC',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'MPM_WATER_RATE_FLC');

   -- MPM_WATER_RAW
    CalcTriangularVMD(lr_pflw_result.MPM_WATER_RATE_RAW , lr_pflw_result.MPM_WATER_MASS_RATE_RAW ,lr_pflw_result.MPM_WATER_DENSITY_RAW
                        ,';PFLW.MPM_WATER_RAW',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'MPM_WATER_RATE_RAW');

   -- MPM_COND_FLC
    CalcTriangularVMD(lr_pflw_result.MPM_COND_RATE_FLC , lr_pflw_result.MPM_COND_MASS_RATE_FLC ,lr_pflw_result.MPM_COND_DENSITY_FLC
                        ,';PFLW.MPM_COND_FLC',lv2_row_changed,lv2_error_found, lv2_missing_cols);
   AddPreprocessLog(p_missing_log, lv2_missing_cols, lv2_SampleDataClassName, 'MPM_COND_RATE_FLC');


   -- Estimated rates
   BEGIN

      lr_pflw_result.EST_NET_OIL_RATE := getOilStdRateDay(lr_pflw_result.result_no, lr_pflw_result.object_id,p_daytime );
      lr_pflw_result.EST_GAS_RATE := getgasStdRateDay(lr_pflw_result.result_no, lr_pflw_result.object_id,p_daytime );
      lr_pflw_result.EST_NET_COND_RATE := getCondStdRateDay(lr_pflw_result.result_no, lr_pflw_result.object_id,p_daytime );
      lr_pflw_result.EST_WATER_RATE := getWatStdRateDay(lr_pflw_result.result_no, lr_pflw_result.object_id,p_daytime );
      lr_pflw_result.EST_DILUENT_RATE := getSumEstDILRate(lr_pflw_result.result_no);
      lr_pflw_result.EST_GL_RATE := getSumEstGLRate(lr_pflw_result.result_no);

      lv2_row_Changed := 'Y';

   EXCEPTION
     WHEN OTHERS THEN
       p_missing_log := p_missing_log ||'Error calculating Estimated rates';
   END;



    IF lv2_row_Changed = 'Y' THEN

       UPDATE pflw_result
       SET  MPM_OIL_RATE          = lr_pflw_result.MPM_OIL_RATE
           ,MPM_OIL_MASS_RATE     = lr_pflw_result.MPM_OIL_MASS_RATE
           ,MPM_OIL_DENSITY       = lr_pflw_result.MPM_OIL_DENSITY

           ,MPM_GAS_RATE          = lr_pflw_result.MPM_GAS_RATE
           ,MPM_GAS_MASS_RATE     = lr_pflw_result.MPM_GAS_MASS_RATE
           ,MPM_GAS_DENSITY       = lr_pflw_result.MPM_GAS_DENSITY

           ,MPM_WATER_RATE        = lr_pflw_result.MPM_WATER_RATE
           ,MPM_WATER_MASS_RATE   = lr_pflw_result.MPM_WATER_MASS_RATE
           ,MPM_WATER_DENSITY     = lr_pflw_result.MPM_WATER_DENSITY

           ,EST_NET_OIL_RATE      = lr_pflw_result.EST_NET_OIL_RATE
           ,EST_GAS_RATE          = lr_pflw_result.EST_GAS_RATE
           ,EST_NET_COND_RATE     = lr_pflw_result.EST_NET_COND_RATE
           ,EST_WATER_RATE        = lr_pflw_result.EST_WATER_RATE

           ,MPM_OIL_RATE_FLC      = lr_pflw_result.MPM_OIL_RATE_FLC
           ,MPM_OIL_MASS_RATE_FLC = lr_pflw_result.MPM_OIL_MASS_RATE_FLC
           ,MPM_OIL_DENSITY_FLC   = lr_pflw_result.MPM_OIL_DENSITY_FLC

           ,MPM_OIL_RATE_RAW      = lr_pflw_result.MPM_OIL_RATE_RAW
           ,MPM_OIL_MASS_RATE_RAW = lr_pflw_result.MPM_OIL_MASS_RATE_RAW
           ,MPM_OIL_DENSITY_RAW   = lr_pflw_result.MPM_OIL_DENSITY_RAW

           ,MPM_GAS_RATE_FLC      = lr_pflw_result.MPM_GAS_RATE_FLC
           ,MPM_GAS_MASS_RATE_FLC = lr_pflw_result.MPM_GAS_MASS_RATE_FLC
           ,MPM_GAS_DENSITY_FLC   = lr_pflw_result.MPM_GAS_DENSITY_FLC

           ,MPM_GAS_RATE_RAW      = lr_pflw_result.MPM_GAS_RATE_RAW
           ,MPM_GAS_MASS_RATE_RAW = lr_pflw_result.MPM_GAS_MASS_RATE_RAW
           ,MPM_GAS_DENSITY_RAW   = lr_pflw_result.MPM_GAS_DENSITY_RAW

           ,MPM_WATER_RATE_FLC      = lr_pflw_result.MPM_WATER_RATE_FLC
           ,MPM_WATER_MASS_RATE_FLC = lr_pflw_result.MPM_WATER_MASS_RATE_FLC
           ,MPM_WATER_DENSITY_FLC   = lr_pflw_result.MPM_WATER_DENSITY_FLC

           ,MPM_WATER_RATE_RAW      = lr_pflw_result.MPM_WATER_RATE_RAW
           ,MPM_WATER_MASS_RATE_RAW = lr_pflw_result.MPM_WATER_MASS_RATE_RAW
           ,MPM_WATER_DENSITY_RAW   = lr_pflw_result.MPM_WATER_DENSITY_RAW

           ,EST_DILUENT_RATE      = lr_pflw_result.EST_DILUENT_RATE
           ,EST_GL_RATE           = lr_pflw_result.EST_GL_RATE

           ,LAST_UPDATED_BY       = Nvl(p_LAST_UPDATED_BY,USER)
           ,LAST_UPDATED_DATE     = Nvl(lr_pflw_result.LAST_UPDATED_DATE, EcDp_Date_Time.getCurrentSysdate)
       WHERE object_id = lr_pflw_result.object_id
       AND   result_no = lr_pflw_result.result_no;

    END IF;

   END LOOP;

END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : PreProcessTestResult
-- Description    : Preforme Triangular calculations on Production test result tables
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PTST_RESULT
--                  EQPM_RESULT
--                  PWEL_RESULT
--                  PFLW_RESULT
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE PreProcessTestResult(p_result_no NUMBER
                               ,p_last_updated_by    VARCHAR2 DEFAULT NULL
                               ,p_last_updated_date  DATE     DEFAULT NULL
                               )
--</EC-DOC>


IS




CURSOR c_ptst_result IS
SELECT * FROM ptst_result
WHERE result_no = p_result_no;

CURSOR c_eqpm_result IS
SELECT * FROM eqpm_result
WHERE result_no = p_result_no;

lr_eqpm_result          eqpm_result%ROWTYPE;
lr_pwel_result          pwel_result%ROWTYPE;
lr_pflw_result          pflw_result%ROWTYPE;
lr_ptst_result          ptst_result%ROWTYPE;
lv2_tdev_id             VARCHAR2(32);
lv2_InputCheck          VARCHAR2(2000);
lv2_row_Changed         VARCHAR2(1);
lv2_error_found         VARCHAR2(1) := 'N';
lv2_timeerrorfound      VARCHAR2(1) := 'N';
lv2_missing_cols        VARCHAR2(4000) := NULL;
lb_raise_error          BOOLEAN;
lv2_SampleDataClassName VARCHAR2(1);
n_lock_columns       EcDp_Month_lock.column_list;
lv2_calc_base           VARCHAR2(32);
ln_object_id            eqpm_result.object_id%TYPE;

BEGIN

  FOR curTst IN c_ptst_result LOOP

    lr_ptst_result := curTst;

    -- Lock test
    EcDp_month_lock.AddParameterToList(n_lock_columns,'CLASS_NAME','PROD_TEST_RESULT','STRING',NULL,NULL,NULL);
    EcDp_month_lock.AddParameterToList(n_lock_columns,'TABLE_NAME','PTST_RESULT','STRING',NULL,NULL,NULL);
    EcDp_month_lock.AddParameterToList(n_lock_columns,'RESULT_NO','RESULT_NO','NUMBER','Y','N',anydata.ConvertNumber(lr_ptst_result.RESULT_NO));
    EcDp_month_lock.AddParameterToList(n_lock_columns,'VALID_FROM_DATE','VALID_FROM_DATE','DATE','N','N',anydata.Convertdate(lr_ptst_result.VALID_FROM_DATE));
    EcDp_month_lock.AddParameterToList(n_lock_columns,'STATUS','STATUS','STRING','N','N',anydata.ConvertVarChar2(lr_ptst_result.STATUS));

    EcDp_Performance_lock.CheckLockProductionTest('UPDATING',n_lock_columns,n_lock_columns);

    lv2_tdev_id := getTestDeviceIDFromResult(p_result_no);
    lv2_InputCheck := ec_eqpm_result.oil_out_rate_raw(lv2_tdev_id, p_result_no) ||ec_eqpm_result.gas_out_rate_raw(lv2_tdev_id, p_result_no)
                      ||ec_eqpm_result.water_out_rate_raw(lv2_tdev_id, p_result_no) ||ec_eqpm_result.oil_out_vol_raw(lv2_tdev_id, p_result_no)
                      ||ec_eqpm_result.gas_out_vol_raw(lv2_tdev_id, p_result_no) ||ec_eqpm_result.water_out_vol_raw(lv2_tdev_id, p_result_no);

    IF (lv2_tdev_id IS NOT NULL) and (lv2_InputCheck IS NULL) THEN

       RAISE_APPLICATION_ERROR(-20010,'Cannot execute, missing input values.');

    ELSE

    IF lr_ptst_result.end_date IS NULL OR lr_ptst_result.duration IS NULL THEN

       IF lr_ptst_result.end_date IS NULL AND lr_ptst_result.duration IS NULL THEN

         lv2_timeerrorfound := 'Y';
         lv2_missing_cols := 'PTST_RESULT: Can not calculate duration, need value for END_DATE or DURATION';
       ELSIF lr_ptst_result.duration IS NULL THEN

         lr_ptst_result.duration := (lr_ptst_result.end_date - lr_ptst_result.daytime)*24;
         lv2_row_Changed := 'Y';

       ELSE

         lr_ptst_result.end_date := lr_ptst_result.daytime + lr_ptst_result.duration/24;
         lv2_row_Changed := 'Y';

       END IF;

    END IF;

    FOR curEqpm IN c_eqpm_result LOOP
        ln_object_id := curEqpm.object_id;

    END LOOP;
    lv2_calc_base  := Nvl(ec_eqpm_version.pt_calc_base(ln_object_id,lr_ptst_result.daytime,'<='),'VOLUME');
    initEQPMForPreProcess(p_result_no,lv2_calc_base);
    initPFLWForPreProcess(p_result_no,lv2_calc_base);
    initPWELForPreProcess(p_result_no,lv2_calc_base);

    PreProcessPwelResultRow(p_result_no, lr_ptst_result.daytime, lr_ptst_result.duration, lv2_missing_cols,p_last_updated_by,p_last_updated_date);
    PreProcessPflwResultRow(p_result_no, lr_ptst_result.daytime, lr_ptst_result.duration, lv2_missing_cols,p_last_updated_by,p_last_updated_date);
    PreProcessEqpmResultRow(p_result_no, lr_ptst_result.daytime, lr_ptst_result.duration, lv2_missing_cols,p_last_updated_by,p_last_updated_date);


    UPDATE ptst_result
    SET
        end_date               = lr_ptst_result.end_date
        ,duration              = lr_ptst_result.duration
        ,preprocess_log        = SUBSTR(lv2_missing_cols,1,3000)
        ,LAST_UPDATED_BY       = Nvl(p_LAST_UPDATED_BY,USER)
        ,LAST_UPDATED_DATE     = Nvl(lr_eqpm_result.LAST_UPDATED_DATE, EcDp_Date_Time.getCurrentSysdate)
    WHERE result_no = lr_ptst_result.result_no
    AND   daytime = lr_ptst_result.daytime;

    IF lv2_row_Changed = 'Y' THEN
      UPDATE pwel_result SET
          end_date               = lr_ptst_result.end_date
          ,duration = lr_ptst_result.duration
          ,LAST_UPDATED_BY       = Nvl(p_LAST_UPDATED_BY,USER)
          ,LAST_UPDATED_DATE     = Nvl(lr_eqpm_result.LAST_UPDATED_DATE, EcDp_Date_Time.getCurrentSysdate)
      WHERE result_no = p_result_no;
    END IF;

  END IF;
  END LOOP;


END PreProcessTestResult;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getMeterCode
-- Description    : Returns the meter code for the test device object for the most recent test that
--					contains a valid test code. If no test code is found a default value of
--					<phase>_METER_1 is returned
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PTST_OBJECT, PTST_DEFINITION
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getMeterCode(p_object_id VARCHAR2, p_daytime DATE, p_phase VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
  ln_return_value VARCHAR2(32);

  CURSOR c_meter_code(cp_object_id VARCHAR2, cp_daytime DATE) IS
    SELECT po.oil_meter_code, po.gas_meter_code, po.water_meter_code
      FROM ptst_object po, ptst_definition pd
     WHERE po.object_id = cp_object_id
       AND pd.test_no = po.test_no
       AND pd.daytime = (SELECT max(pd2.daytime ) FROM ptst_object po2, ptst_definition pd2
                          WHERE po2.object_id = cp_object_id
                            AND pd2.test_no = po2.test_no
                            AND pd2.daytime <= cp_daytime);

BEGIN
  --Applying default values
  IF p_phase = 'OIL' THEN
    ln_return_value  := 'OIL_METER_1';
  END IF;

  IF p_phase = 'GAS' THEN
    ln_return_value  := 'GAS_METER_1';
  END IF;

  IF p_phase = 'WATER' THEN
    ln_return_value  := 'WATER_METER_1';
  END IF;

  FOR row IN c_meter_code(p_object_id, p_daytime) LOOP
    IF p_phase = 'OIL' AND row.oil_meter_code LIKE '%OIL_METER_%' THEN
      ln_return_value  := row.oil_meter_code;
    END IF;

    IF p_phase = 'GAS' AND row.gas_meter_code LIKE '%GAS_METER_%' THEN
      ln_return_value  := row.gas_meter_code;
    END IF;

    IF p_phase = 'WATER' AND row.water_meter_code LIKE '%WATER_METER_%' THEN
      ln_return_value  := row.water_meter_code;
    END IF;
  END LOOP;
  RETURN ln_return_value;
END getMeterCode;


-- getNextValidWellResult
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getNextValidWellResult
-- Description    : Get the next valid well test result
--
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getNextValidWellResult(p_object_id VARCHAR2, p_daytime DATE)
RETURN pwel_result%ROWTYPE
--</EC-DOC>
IS

lr_pwel_result pwel_result%ROWTYPE;

BEGIN
     lr_pwel_result := ec_pwel_result.row_by_pk(p_object_id, EcDp_Performance_Test.getNextValidWellResultNo(p_object_id, p_daytime));

   RETURN lr_pwel_result;

END getNextValidWellResult;

-- getNextValidWellResultNo
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getNextValidWellResultNo
-- Description    : Get the next valid well test result no
--
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PTST_OBJECT, PTST_DEFINITION
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getNextValidWellResultNo(p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

	CURSOR c_valid_rec(cp_object_id VARCHAR2, cp_daytime DATE) IS
		SELECT pr.result_no, pwr.primary_ind, pr.status
		FROM pwel_result pwr, ptst_result pr
		WHERE pr.result_no = pwr.result_no
		AND pwr.use_calc ='Y'
		AND pr.valid_from_date >= cp_daytime
		AND pwr.object_id = cp_object_id
		ORDER BY pr.valid_from_date ASC;

	   ln_result_no    NUMBER;

	BEGIN

	   FOR curRec IN c_valid_rec(p_object_id, p_daytime) LOOP

	      IF curRec.primary_ind = 'Y' AND curRec.status = 'ACCEPTED' THEN
	         ln_result_no := curRec.result_no;
	         EXIT;
	      END IF;

	   END LOOP;

	   RETURN ln_result_no;


END getNextValidWellResultNo;


-- getTrendSegmentMinDate
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getTrendSegmentMinDate
-- Description    : Determine which trend segment the date is valid, and return the min date for the segment
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTrendSegmentMinDate(p_object_id VARCHAR2, p_daytime DATE)
RETURN DATE
--</EC-DOC>
IS
	ld_min_date	DATE;

	CURSOR c_min_daytime_cur is
	SELECT MAX(ptst_result.DAYTIME) as min_daytime from pwel_result, ptst_result
	where pwel_result.result_no = ptst_result.result_no
	and pwel_result.OBJECT_ID = p_object_id
	AND pwel_result.TREND_RESET_IND = 'Y'
	AND ptst_result.DAYTIME <= p_daytime;

BEGIN

	FOR my_cur IN c_min_daytime_cur LOOP
		ld_min_date := my_cur.min_daytime;
	END LOOP;

	return ld_min_date;

END getTrendSegmentMinDate;

-- getTrendSegmentMaxDate
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getTrendSegmentMaxDate
-- Description    : Determine which trend segment the date is valid, and return the max date for the segment
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTrendSegmentMaxDate(p_object_id VARCHAR2, p_daytime DATE)
RETURN DATE
--</EC-DOC>
IS
	ld_max_date	DATE;

	CURSOR c_max_daytime_cur is
	SELECT MIN(ptst_result.DAYTIME) as max_daytime from pwel_result, ptst_result
	where pwel_result.result_no = ptst_result.result_no
	and pwel_result.OBJECT_ID = p_object_id
	AND pwel_result.TREND_RESET_IND = 'Y'
	AND ptst_result.DAYTIME > p_daytime;

BEGIN

	FOR my_cur IN c_max_daytime_cur LOOP
		ld_max_date := my_cur.max_daytime;
	END LOOP;

	return ld_max_date;

END getTrendSegmentMaxDate;

--findOilConstantC2
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : findOilConstantC2
-- Description    : Return the most recent valid oil_trend_c2 from the trend segment.
--
--                  As of ECPD-5765, oil_trend_c2 no longer exist. The column is moved to TREND_CURVE table.
--                  Old C1 become C0, old C2 become C1, C2 is kept for future use
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findOilConstantC2(p_object_id VARCHAR2, p_daytime DATE, p_trend_method VARCHAR2 DEFAULT 'EXP')
RETURN NUMBER
--</EC-DOC>
IS

	ld_min_date_1 DATE;
	ld_min_date_2 DATE;
	ld_max_date_1 DATE;
	ld_max_date_2 DATE;
  ld_trend_start_date DATE;
	ln_oil_trend_c2 NUMBER;

	-- Find min date 2 for trend segment --
	CURSOR c_min_date_2_rec(cp_object_id VARCHAR2, cp_daytime DATE) IS
		select MIN(ptst_result.daytime) as daytime from pwel_result, ptst_result where
			pwel_result.result_no = ptst_result.result_no and
			pwel_result.object_id = p_object_id and
			ptst_result.daytime <= cp_daytime;

	-- Find max date 2 for trend segment --
	CURSOR c_max_date_2_rec(cp_object_id VARCHAR2, cp_daytime DATE) IS
		select MAX(ptst_result.daytime) as daytime from pwel_result, ptst_result where
			pwel_result.result_no = ptst_result.result_no and
			pwel_result.object_id = p_object_id and
			ptst_result.daytime >= cp_daytime;

BEGIN
	-- get min date for the trend segment
	ld_min_date_1 := Ecdp_performance_test.getTrendSegmentMinDate(p_object_id, p_daytime);

	-- get max date for the trend segment
	ld_max_date_1 := Ecdp_performance_test.getTrendSegmentMaxDate(p_object_id, p_daytime);

	-- get the oldest test result before the selected daytime
	FOR my_cur1 IN c_min_date_2_rec(p_object_id, p_daytime) LOOP
		ld_min_date_2 := my_cur1.daytime;
	END LOOP;

	-- get the latest test result after the selected daytime
	FOR my_cur2 IN c_max_date_2_rec(p_object_id, p_daytime) LOOP
		ld_max_date_2 := my_cur2.daytime;
	END LOOP;

  -- ECPD-5765: pwel_result.xxx_trend_c2 is removed. Replace with trend_curve.C1
	-- get trend start date
  ld_trend_start_date := Ecdp_Well_Test_Curve.getTrendSegmentStartDaytime(p_object_id,p_daytime,ld_min_date_2,ld_max_date_2);
  FOR tc_cur IN c_trend_curve(p_object_id, ld_trend_start_date, 'NET_OIL_RATE_ADJ', p_trend_method) LOOP
    ln_oil_trend_c2 := tc_cur.c1;
  END LOOP;

  IF ln_oil_trend_c2 IS NULL THEN
     ln_oil_trend_c2 := 0;
  END IF;

	return ln_oil_trend_c2;

END findOilConstantC2;

-- findGasConstantC2
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : findGasConstantC2
-- Description    : Return the most recent valid gas_trend_c2 from the trend segment
--
--                  As of ECPD-5765, gas_trend_c2 no longer exist. The column is moved to TREND_CURVE table.
--                  Old C1 become C0, old C2 become C1, C2 is kept for future use
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findGasConstantC2(p_object_id VARCHAR2, p_daytime DATE, p_trend_method VARCHAR2 DEFAULT 'EXP')
RETURN NUMBER
--</EC-DOC>
IS

 	ld_min_date_1 DATE;
	ld_min_date_2 DATE;
	ld_max_date_1 DATE;
	ld_max_date_2 DATE;
  ld_trend_start_date DATE;
	ln_gas_trend_c2 NUMBER;

	-- Find min date 2 for trend segment --
	CURSOR c_min_date_2_rec(cp_object_id VARCHAR2, cp_daytime DATE) IS
		select MIN(ptst_result.daytime) as daytime from pwel_result, ptst_result where
			pwel_result.result_no = ptst_result.result_no and
			pwel_result.object_id = p_object_id and
			ptst_result.daytime <= cp_daytime;

	-- Find max date 2 for trend segment --
	CURSOR c_max_date_2_rec(cp_object_id VARCHAR2, cp_daytime DATE) IS
		select MAX(ptst_result.daytime) as daytime from pwel_result, ptst_result where
			pwel_result.result_no = ptst_result.result_no and
			pwel_result.object_id = p_object_id and
			ptst_result.daytime >= cp_daytime;


BEGIN
	-- get min date for the trend segment
	ld_min_date_1 := Ecdp_performance_test.getTrendSegmentMinDate(p_object_id, p_daytime);

	-- get max date for the trend segment
	ld_max_date_1 := Ecdp_performance_test.getTrendSegmentMaxDate(p_object_id, p_daytime);

	-- get the oldest test result before the selected daytime
	FOR my_cur1 IN c_min_date_2_rec(p_object_id, p_daytime) LOOP
		ld_min_date_2 := my_cur1.daytime;
	END LOOP;

	-- get the latest test result after the selected daytime
	FOR my_cur2 IN c_max_date_2_rec(p_object_id, p_daytime) LOOP
		ld_max_date_2 := my_cur2.daytime;
	END LOOP;

  -- ECPD-5765: pwel_result.xxx_trend_c2 is removed. Replace with trend_curve.C1
	-- get trend start date
  ld_trend_start_date := Ecdp_Well_Test_Curve.getTrendSegmentStartDaytime(p_object_id,p_daytime,ld_min_date_2,ld_max_date_2);
  FOR tc_cur IN c_trend_curve(p_object_id, ld_trend_start_date, 'GAS_RATE_ADJ', p_trend_method) LOOP
    ln_gas_trend_c2 := tc_cur.c1;
  END LOOP;

  IF ln_gas_trend_c2 IS NULL THEN
     ln_gas_trend_c2 := 0;
  END IF;

	return ln_gas_trend_c2;

END findGasConstantC2;

-- findCondConstantC2
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : findCondConstantC2
-- Description    : Return the most recent valid cond_trend_c2 from the trend segment
--
--
--                  As of ECPD-5765, cond_trend_c2 no longer exist. The column is moved to TREND_CURVE table.
--                  Old C1 become C0, old C2 become C1, C2 is kept for future use
--
-- Preconditions  :
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
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findCondConstantC2(p_object_id VARCHAR2, p_daytime DATE, p_trend_method VARCHAR2 DEFAULT 'EXP')
RETURN NUMBER
--</EC-DOC>
IS

	ld_min_date_1 DATE;
	ld_min_date_2 DATE;
	ld_max_date_1 DATE;
	ld_max_date_2 DATE;
  ld_trend_start_date DATE;
	ln_cond_trend_c2 NUMBER;

	-- Find min date 2 for trend segment --
	CURSOR c_min_date_2_rec(cp_object_id VARCHAR2, cp_daytime DATE) IS
		select MIN(ptst_result.daytime) as daytime from pwel_result, ptst_result where
			pwel_result.result_no = ptst_result.result_no and
			pwel_result.object_id = p_object_id and
			ptst_result.daytime <= cp_daytime;

	-- Find max date 2 for trend segment --
	CURSOR c_max_date_2_rec(cp_object_id VARCHAR2, cp_daytime DATE) IS
		select MAX(ptst_result.daytime) as daytime from pwel_result, ptst_result where
			pwel_result.result_no = ptst_result.result_no and
			pwel_result.object_id = p_object_id and
			ptst_result.daytime >= cp_daytime;


BEGIN
	-- get min date for the trend segment
	ld_min_date_1 := Ecdp_performance_test.getTrendSegmentMinDate(p_object_id, p_daytime);

	-- get max date for the trend segment
	ld_max_date_1 := Ecdp_performance_test.getTrendSegmentMaxDate(p_object_id, p_daytime);

	-- get the oldest test result before the selected daytime
	FOR my_cur1 IN c_min_date_2_rec(p_object_id, p_daytime) LOOP
		ld_min_date_2 := my_cur1.daytime;
	END LOOP;

	-- get the latest test result after the selected daytime
	FOR my_cur2 IN c_max_date_2_rec(p_object_id, p_daytime) LOOP
		ld_max_date_2 := my_cur2.daytime;
	END LOOP;

  -- ECPD-5765: pwel_result.xxx_trend_c2 is removed. Replace with trend_curve.C1
	-- get trend start date
  ld_trend_start_date := Ecdp_Well_Test_Curve.getTrendSegmentStartDaytime(p_object_id,p_daytime,ld_min_date_2,ld_max_date_2);
  FOR tc_cur IN c_trend_curve(p_object_id, ld_trend_start_date, 'NET_COND_RATE_ADJ', p_trend_method) LOOP
    ln_cond_trend_c2 := tc_cur.c1;
  END LOOP;

  IF ln_cond_trend_c2 IS NULL THEN
     ln_cond_trend_c2 := 0;
  END IF;

	return ln_cond_trend_c2;

END findCondConstantC2;

-- findWatConstantC2
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : findWatConstantC2
-- Description    : Return the most recent valid water_trend_c2 from the trend segment
--
--                  As of ECPD-5765, water_trend_c2 no longer exist. The column is moved to TREND_CURVE table.
--                  Old C1 become C0, old C2 become C1, C2 is kept for future use
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findWatConstantC2(p_object_id VARCHAR2, p_daytime DATE, p_trend_method VARCHAR2 DEFAULT 'EXP')
RETURN NUMBER
--</EC-DOC>
IS

	ld_min_date_1 DATE;
	ld_min_date_2 DATE;
	ld_max_date_1 DATE;
	ld_max_date_2 DATE;
	ld_wat_trend_c2_date DATE;
  ld_trend_start_date DATE;
	ln_wat_trend_c2 NUMBER;

	-- Find min date 2 for trend segment --
	CURSOR c_min_date_2_rec(cp_object_id VARCHAR2, cp_daytime DATE) IS
		select MIN(ptst_result.daytime) as daytime from pwel_result, ptst_result where
			pwel_result.result_no = ptst_result.result_no and
			pwel_result.object_id = p_object_id and
			ptst_result.daytime <= cp_daytime;

	-- Find max date 2 for trend segment --
	CURSOR c_max_date_2_rec(cp_object_id VARCHAR2, cp_daytime DATE) IS
		select MAX(ptst_result.daytime) as daytime from pwel_result, ptst_result where
			pwel_result.result_no = ptst_result.result_no and
			pwel_result.object_id = p_object_id and
			ptst_result.daytime >= cp_daytime;


BEGIN
	-- get min date for the trend segment
	ld_min_date_1 := Ecdp_performance_test.getTrendSegmentMinDate(p_object_id, p_daytime);

	-- get max date for the trend segment
	ld_max_date_1 := Ecdp_performance_test.getTrendSegmentMaxDate(p_object_id, p_daytime);

	-- get the oldest test result before the selected daytime
	FOR my_cur1 IN c_min_date_2_rec(p_object_id, p_daytime) LOOP
		ld_min_date_2 := my_cur1.daytime;
	END LOOP;

	-- get the latest test result after the selected daytime
	FOR my_cur2 IN c_max_date_2_rec(p_object_id, p_daytime) LOOP
		ld_max_date_2 := my_cur2.daytime;
	END LOOP;


  -- ECPD-5765: pwel_result.xxx_trend_c2 is removed. Replace with trend_curve.C1
	-- get trend start date
  ld_trend_start_date := Ecdp_Well_Test_Curve.getTrendSegmentStartDaytime(p_object_id,p_daytime,ld_min_date_2,ld_max_date_2);
  FOR tc_cur IN c_trend_curve(p_object_id, ld_trend_start_date, 'TOT_WATER_RATE_ADJ', p_trend_method) LOOP
    ln_wat_trend_c2 := tc_cur.c1;
  END LOOP;

  IF ln_wat_trend_c2 IS NULL THEN
     ln_wat_trend_c2 := 0;
  END IF;

	return ln_wat_trend_c2;

END findWatConstantC2;


---------------------------------------------------------------------------------------------------
-- Procedure : findLiqConstantC2
-- Description : Return the most recent valid liquid_trend_c2 from the trend segment
--
--
-- Preconditions :
-- Postconditions :
--
-- Using tables :
--
--
--
-- Using functions:
--
-- Configuration
-- required :
--
-- Behaviour :
--
---------------------------------------------------------------------------------------------------

FUNCTION findLiqConstantC2(p_object_id VARCHAR2, p_daytime DATE, p_trend_method VARCHAR2 DEFAULT 'EXP')
RETURN NUMBER
--</EC-DOC>
IS

	ld_min_date_1 DATE;
	ld_min_date_2 DATE;
	ld_max_date_1 DATE;
	ld_max_date_2 DATE;
	ld_trend_start_date DATE;
	ln_liq_trend_c2 NUMBER;

-- Find min date 2 for trend segment ?
  CURSOR c_min_date_2_rec(cp_object_id VARCHAR2, cp_daytime DATE) IS
  select MIN(ptst_result.daytime) as daytime from pwel_result, ptst_result where
  pwel_result.result_no = ptst_result.result_no and
  pwel_result.object_id = p_object_id and
  ptst_result.daytime <= cp_daytime;

-- Find max date 2 for trend segment ?
  CURSOR c_max_date_2_rec(cp_object_id VARCHAR2, cp_daytime DATE) IS
  select MAX(ptst_result.daytime) as daytime from pwel_result, ptst_result where
  pwel_result.result_no = ptst_result.result_no and
  pwel_result.object_id = p_object_id and
  ptst_result.daytime >= cp_daytime;

BEGIN
-- get min date for the trend segment
  ld_min_date_1 := Ecdp_performance_test.getTrendSegmentMinDate(p_object_id, p_daytime);

-- get max date for the trend segment
  ld_max_date_1 := Ecdp_performance_test.getTrendSegmentMaxDate(p_object_id, p_daytime);

-- get the oldest test result before the selected daytime
  FOR my_cur1 IN c_min_date_2_rec(p_object_id, p_daytime) LOOP
    ld_min_date_2 := my_cur1.daytime;
  END LOOP;

-- get the latest test result after the selected daytime
  FOR my_cur2 IN c_max_date_2_rec(p_object_id, p_daytime) LOOP
    ld_max_date_2 := my_cur2.daytime;
  END LOOP;

-- get trend start date
  ld_trend_start_date := Ecdp_Well_Test_Curve.getTrendSegmentStartDaytime(p_object_id,p_daytime,ld_min_date_2,ld_max_date_2);
  FOR tc_cur IN c_trend_curve(p_object_id, ld_trend_start_date, 'LIQUID_RATE_ADJ', p_trend_method) LOOP
    ln_liq_trend_c2 := tc_cur.c1;
  END LOOP;

  IF ln_liq_trend_c2 IS NULL THEN
    ln_liq_trend_c2 := 0;
  END IF;

  RETURN ln_liq_trend_c2;

END findLiqConstantC2;

---------------------------------------------------------------------------------------------------
-- Procedure      : auiSetProductionDay
-- Description    : set production_day based on result no
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PTST_RESULT
--
--
--
-- Using functions: ec_well_version, ecdp_facility.getProductionDay
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE auiSetProductionDay (p_object_id  VARCHAR2, -- WELL OBJECT ID
                               p_daytime    DATE,     -- DAYTIME
                               p_result_no  NUMBER,
                               p_user VARCHAR2 DEFAULT NULL) IS

      ld_daytime           ptst_result.daytime%TYPE;
      ld_production_day    production_facility.start_date%TYPE;

BEGIN

      IF p_daytime IS NULL THEN
        SELECT daytime INTO ld_daytime FROM ptst_result WHERE result_no = p_result_no;
      ELSE
        ld_daytime := p_daytime;
      END IF;

      ld_production_day := EcDp_ProductionDay.getProductionDay('WELL',p_object_id, ld_daytime);

      -- Update ptst_result.production_day
      UPDATE ptst_result
         SET production_day = ld_production_day,
		     last_updated_by = Nvl(p_user,USER)
       WHERE result_no = p_result_no;


END auiSetProductionDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : auiSyncPtstResult
-- Description    : if pwel_result.daytime/valid_from_date/status/use_calc is changed, then sync to ptst_result using result_no
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PTST_RESULT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE auiSyncPtstResult ( p_result_no  NUMBER, p_attr_changed VARCHAR2, p_daytime DATE, p_valid_from_date DATE,
                              p_status VARCHAR2,   p_use_calc VARCHAR2, p_end_date DATE, p_duration NUMBER,
                              p_user VARCHAR2 DEFAULT NULL, p_well_test_reason VARCHAR2
                            )
--</EC-DOC>
IS

      ln_result           NUMBER;

BEGIN
	  SELECT COUNT(*) into ln_result
	  FROM PTST_RESULT pr
	  WHERE pr.RESULT_NO = p_result_no;

	  IF ln_result=0 THEN
	  	INSERT INTO PTST_RESULT(RESULT_NO, DAYTIME, VALID_FROM_DATE, STATUS, USE_CALC, CLASS_NAME, END_DATE, DURATION, WELL_TEST_REASON, CREATED_BY)
	  		VALUES(p_result_no, p_daytime, p_valid_from_date, p_status, p_use_calc,'PROD_TEST_RESULT_SINGLE', p_end_date, p_duration, p_well_test_reason, Nvl(p_user,USER));
	  ELSE
	  	CASE p_attr_changed
	      WHEN 'DAYTIME' THEN
	        UPDATE ptst_result
		       SET daytime = p_daytime,
		       	   last_updated_by = Nvl(p_user,USER)
		       WHERE result_no = p_result_no;

	      WHEN 'VALID_FROM_DATE' THEN
	        UPDATE ptst_result
		       SET valid_from_date = p_valid_from_date,
		       	   last_updated_by = Nvl(p_user,USER)
		       WHERE result_no = p_result_no;

	      WHEN 'STATUS' THEN
	        UPDATE ptst_result
		       SET status = p_status,
		       	   last_updated_by = Nvl(p_user,USER)
		       WHERE result_no = p_result_no;

	      WHEN 'USE_CALC' THEN
	        UPDATE ptst_result
		       SET use_calc = p_use_calc,
		       	   last_updated_by = Nvl(p_user,USER)
		       WHERE result_no = p_result_no;

	      WHEN 'END_DATE' THEN
	        UPDATE ptst_result
		       SET end_date = p_end_date,
		       	   last_updated_by = Nvl(p_user,USER)
		       WHERE result_no = p_result_no;

	      WHEN 'DURATION' THEN
	        UPDATE ptst_result
		       SET duration = p_duration,
		       	   last_updated_by = Nvl(p_user,USER)
		       WHERE result_no = p_result_no;

		    WHEN 'WELL_TEST_REASON' THEN
	        UPDATE ptst_result
		       SET WELL_TEST_REASON = p_well_test_reason,
		       	   last_updated_by = Nvl(p_user,USER)
		       WHERE result_no = p_result_no;

		  WHEN 'SYNC' THEN
           INSERT INTO PTST_RESULT(RESULT_NO, DAYTIME, VALID_FROM_DATE, STATUS, USE_CALC, CLASS_NAME, END_DATE, DURATION, WELL_TEST_REASON, CREATED_BY)
	  		   VALUES(p_result_no, p_daytime, p_valid_from_date, p_status, p_use_calc,'PROD_TEST_RESULT_SINGLE', p_end_date, p_duration, p_well_test_reason, Nvl(p_user,USER));

	      ELSE
	        ecdp_dynsql.WriteTempText('EcDp_Performance_Test.auiSyncPtstResult','Invalid argument!');

	    END CASE;

	  END IF;

END auiSyncPtstResult;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : auiSyncEqpmResult
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : EQPM_RESULT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE auiSyncEqpmResult (p_test_device VARCHAR2, p_result_no NUMBER, p_daytime DATE, p_user VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

BEGIN

    IF p_test_device IS NOT NULL THEN
        INSERT INTO EQPM_RESULT (object_id,result_no,daytime,data_class_name,created_by)
        values (p_test_device,p_result_no,p_daytime,getSingleDataClassName(p_test_device, p_daytime),Nvl(p_user,USER));
    END IF;

END auiSyncEqpmResult;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : auidelEqpmResult
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : EQPM_RESULT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE auidelEqpmResult (p_test_device VARCHAR2,p_result_no  NUMBER)
--</EC-DOC>
IS
BEGIN

    IF p_test_device IS NOT NULL THEN
        DELETE EQPM_RESULT WHERE object_id = p_test_device AND result_no = p_result_no ;
    END IF;

END auidelEqpmResult;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : auiSyncPtstResultTdev
-- Description    : if pwel_result.test_device is changed, then sync to ptst_result using result_no
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PTST_RESULT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE auiSyncPtstResultTdev ( p_result_no  NUMBER, p_test_device VARCHAR2, p_daytime DATE, p_user VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

      ln_result           NUMBER;
      lv2_tdev_data_class VARCHAR2(1000);

BEGIN
    lv2_tdev_data_class := '';

	  SELECT COUNT(*) into ln_result
	  FROM PTST_RESULT pr, EQPM_RESULT er
	  WHERE pr.RESULT_NO = p_result_no
	  AND pr.RESULT_NO = er.RESULT_NO
	  AND er.OBJECT_ID = p_test_device;

      lv2_tdev_data_class := ecdp_performance_test.getResultDataClassName(p_test_device, p_daytime);
	  IF ln_result=0 THEN
    -- ecdp_dynsql.WriteTempText('ResultTdev','Going to insert test device!');
	  	INSERT INTO EQPM_RESULT(RESULT_NO, OBJECT_ID, DAYTIME, DATA_CLASS_NAME, CREATED_BY)
	  		VALUES(p_result_no, p_test_device, p_daytime, lv2_tdev_data_class, Nvl(p_user,USER));
	--  ELSE
    --   ecdp_dynsql.WriteTempText('ResultTdev','Nothing else!');
      END IF;

END auiSyncPtstResultTdev;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : auiSyncPwelResult
-- Description    : if ptst_result.daytime/valid_from_date/status/use_calc is changed, then sync to pwel_result using result_no
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PWEL_RESULT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE auiSyncPwelResult ( p_result_no  NUMBER, p_attr_changed VARCHAR2, p_daytime DATE, p_valid_from_date DATE,
                              p_status VARCHAR2,   p_use_calc VARCHAR2, p_end_date DATE, p_duration NUMBER,
                              p_user VARCHAR2 DEFAULT NULL, p_well_test_reason VARCHAR2
                            )
--</EC-DOC>
IS

      ln_result           NUMBER;

BEGIN
	  SELECT COUNT(*) into ln_result
	  FROM PWEL_RESULT pr
	  WHERE pr.RESULT_NO = p_result_no;

	  IF ln_result > 0 THEN
	  	CASE p_attr_changed
	      WHEN 'DAYTIME' THEN
	        UPDATE pwel_result
		       SET daytime = p_daytime,
		       	   last_updated_by = Nvl(p_user,USER)
		       WHERE result_no = p_result_no;

	      WHEN 'VALID_FROM_DATE' THEN
	        UPDATE pwel_result
		       SET valid_from_date = p_valid_from_date,
		       	   last_updated_by = Nvl(p_user,USER)
		       WHERE result_no = p_result_no;

	      WHEN 'STATUS' THEN
	        UPDATE pwel_result
		       SET status = p_status,
		       	   last_updated_by = Nvl(p_user,USER)
		       WHERE result_no = p_result_no;

	      WHEN 'USE_CALC' THEN
	        UPDATE pwel_result
		       SET use_calc = p_use_calc,
		       	   last_updated_by = Nvl(p_user,USER)
		       WHERE result_no = p_result_no;

	      WHEN 'END_DATE' THEN
	        UPDATE pwel_result
		       SET end_date = p_end_date,
		       	   last_updated_by = Nvl(p_user,USER)
		       WHERE result_no = p_result_no;

	      WHEN 'DURATION' THEN
	        UPDATE pwel_result
		       SET duration = p_duration,
		       	   last_updated_by = Nvl(p_user,USER)
		       WHERE result_no = p_result_no;

		    WHEN 'WELL_TEST_REASON' THEN
	        UPDATE pwel_result
		       SET well_test_reason = p_well_test_reason,
		       	   last_updated_by = Nvl(p_user,USER)
		       WHERE result_no = p_result_no;

	      ELSE
	        ecdp_dynsql.WriteTempText('EcDp_Performance_Test.auiSyncPwelResult','Invalid argument!');

	    END CASE;

	  END IF;

END auiSyncPwelResult;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : auisetPwelResult
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PWEL_RESULT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE auisetPwelResult ( p_result_no  NUMBER, p_user VARCHAR2 DEFAULT USER)
--</EC-DOC>
IS

BEGIN

    UPDATE PWEL_RESULT
    SET primary_ind = 'Y',
        flowing_ind = 'Y',
        last_updated_by=p_user
    WHERE result_no = p_result_no;

END auisetPwelResult;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : aiSyncPwelResultFromTdev
-- Description    : if there is any inserted Test Device in Production Test Result, need to sync to PWEL_RESULT.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PWEL_RESULT, PTST_RESULT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE aiSyncPwelResultFromTdev ( p_result_no  NUMBER, p_test_dev_id VARCHAR2, p_user VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS
	CURSOR c_ptst_result(cp_result_no NUMBER) IS
	SELECT result_no, daytime, valid_from_date, status, use_calc, end_date, duration
	FROM ptst_result
	WHERE result_no = cp_result_no;

	CURSOR c_pwel_result(cp_result_no NUMBER) IS
  	SELECT object_id
	FROM pwel_result
	WHERE result_no = cp_result_no;

    ln_result           NUMBER;
    lv2_well_id  VARCHAR2(1000);

BEGIN

  	ln_result:=0;

    FOR curr_rec in c_pwel_result(p_result_no) LOOP
       lv2_well_id := curr_rec.object_id;

	   SELECT COUNT(*) into ln_result
	    FROM PWEL_RESULT pr
	 	WHERE pr.RESULT_NO = p_result_no and pr.OBJECT_ID = lv2_well_id;

	  	FOR curr_rec in c_ptst_result(p_result_no) LOOP
	  		UPDATE PWEL_RESULT
		  	SET DAYTIME=curr_rec.daytime,
		  		VALID_FROM_DATE=curr_rec.valid_from_date,
		  		STATUS=curr_rec.status,
		  		USE_CALC=curr_rec.use_calc,
          END_DATE=curr_rec.end_date,
          DURATION=curr_rec.duration,
		  		TEST_DEVICE = p_test_dev_id,
		     	LAST_UPDATED_BY = Nvl(p_user,USER)
		  	WHERE RESULT_NO = p_result_no; --and OBJECT_ID = lv2_well_id;
		END LOOP;


    END LOOP;

    IF ln_result = 0 AND lv2_well_id is not null THEN
        FOR curr_rec in c_ptst_result(p_result_no) LOOP
			  	INSERT INTO PWEL_RESULT
			  	(RESULT_NO, OBJECT_ID, DAYTIME, VALID_FROM_DATE, STATUS, USE_CALC, TEST_DEVICE, END_DATE, DURATION, CREATED_BY)
			  	VALUES
			  	(curr_rec.result_no, lv2_well_id, curr_rec.daytime, curr_rec.valid_from_date, curr_rec.status, curr_rec.use_calc, p_test_dev_id, curr_rec.end_date, curr_rec.duration, Nvl(p_user,USER));
		END LOOP;
    END IF;

END aiSyncPwelResultFromTdev;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : aiSyncPwelResultFromPwel
-- Description    : if there is any inserted Well Test in Production Test Result, need to sync to PWEL_RESULT.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PWEL_RESULT, PTST_RESULT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE aiSyncPwelResultFromPwel ( p_result_no  NUMBER, p_well_id VARCHAR2, p_user VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS
	CURSOR c_ptst_result(cp_result_no NUMBER) IS
	SELECT result_no, daytime, valid_from_date, status, use_calc, end_date, duration, well_test_reason
	FROM ptst_result
	WHERE result_no = cp_result_no;

	CURSOR c_eqpm_result(cp_result_no NUMBER) IS
  	SELECT object_id
	FROM eqpm_result
	WHERE result_no = cp_result_no;

    ln_result           NUMBER;
    lv2_test_device_id  VARCHAR2(1000);

BEGIN
	 SELECT COUNT(*) into ln_result
	  FROM PWEL_RESULT pr
	  WHERE pr.RESULT_NO = p_result_no and pr.OBJECT_ID = p_well_id;

	 FOR curr_rec in c_eqpm_result(p_result_no) LOOP
       lv2_test_device_id := curr_rec.object_id;
     END LOOP;

	 IF ln_result = 0 THEN
	  	FOR curr_rec in c_ptst_result(p_result_no) LOOP
		  	INSERT INTO PWEL_RESULT
		  	(RESULT_NO, OBJECT_ID, DAYTIME, VALID_FROM_DATE, STATUS, USE_CALC, TEST_DEVICE, END_DATE, DURATION, WELL_TEST_REASON, CREATED_BY)
		  	VALUES
		  	(curr_rec.result_no, p_well_id, curr_rec.daytime, curr_rec.valid_from_date, curr_rec.status, curr_rec.use_calc, lv2_test_device_id, curr_rec.end_date, curr_rec.duration, curr_rec.well_test_reason, Nvl(p_user,USER));
		END LOOP;
	 ELSE
	  	FOR curr_rec in c_ptst_result(p_result_no) LOOP
	  		UPDATE PWEL_RESULT
		  	SET DAYTIME=curr_rec.daytime,
		  		VALID_FROM_DATE=curr_rec.valid_from_date,
		  		STATUS=curr_rec.status,
		  		USE_CALC=curr_rec.use_calc,
          END_DATE=curr_rec.end_date,
          DURATION=curr_rec.duration,
		  		TEST_DEVICE=lv2_test_device_id,
		  		WELL_TEST_REASON = curr_rec.well_test_reason,
		     	LAST_UPDATED_BY = Nvl(p_user,USER)
		  	WHERE RESULT_NO = p_result_no and OBJECT_ID = p_well_id;
		END LOOP;
	 END IF;

END aiSyncPwelResultFromPwel;


--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- Procedure      : delPwelResultData
-- Description    : This procedure deletes any data in the pwel_result table on given result_no.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PWEL_RESULT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------------
PROCEDURE delPwelResultData(p_result_no NUMBER)
--</EC-DOC>
IS

BEGIN

  DELETE pwel_result WHERE result_no = p_result_no;

END delPwelResultData;

--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- Procedure      : delPtstResultData
-- Description    : This procedure deletes any data in the ptst_result table on given result_no.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PTST_RESULT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------------
PROCEDURE delPtstResultData(p_result_no NUMBER)
--</EC-DOC>
IS

BEGIN

  DELETE ptst_result WHERE result_no = p_result_no AND class_name='PROD_TEST_RESULT_SINGLE';

END delPtstResultData;


---------------------------------------------------------------------------------------------------
-- Procedure      : setWbiTestDefine
-- Description    : instantiate well bore interval test define for the given well
--
-- Preconditions  :
-- Postconditions : ptst_object will have empty rows for given well's well bore interval
--
-- Using tables   : PTST_OBJECT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE setWbiTestDefine (p_object_id     VARCHAR2, -- WELL OBJECT ID
                            p_daytime       DATE,     -- PERFORMANCE TEST START DATE
                            p_test_no       NUMBER,
                            p_interval_type VARCHAR2 DEFAULT 'DIACS',
                            p_created_by    VARCHAR2 DEFAULT NULL)
IS

  lv_created_by     VARCHAR2(32);
  ln_count_wbi      NUMBER;
  lv_wbi_class_name VARCHAR2(32);

-- Find well bore interval which active at performance test start date
CURSOR c_wbi(cp_object_id VARCHAR2, cp_daytime DATE, cp_interval_type VARCHAR2) IS
  SELECT wbi.object_id AS object_id
  FROM webo_interval_version wbiv, webo_interval wbi, webo_bore wb, well_version wv, well w
  WHERE wbiv.object_id = wbi.object_id
  AND   wbi.well_bore_id = wb.object_id
  AND   wb.well_id = w.object_id
  AND   w.object_id = cp_object_id
  AND   wv.object_id = cp_object_id
  AND   wbiv.interval_type = cp_interval_type
  AND   wbiv.daytime <= cp_daytime
  AND   Nvl(wbiv.end_date, cp_daytime+1) > cp_daytime
  AND   wv.daytime <= cp_daytime
  AND   Nvl(wv.end_date, cp_daytime+1) > cp_daytime;

BEGIN

  lv_wbi_class_name := 'WELL_BORE_INTERVAL';

  IF p_created_by IS NULL THEN
    lv_created_by := User;
  ELSE
    lv_created_by := p_created_by;
  END IF;

  -- check existence of wbi of same test number and of a well
  SELECT count(*) INTO ln_count_wbi
  FROM ptst_object po
  WHERE po.class_name = lv_wbi_class_name
  AND po.test_no = p_test_no
  AND po.object_id IN
    (
      SELECT wbi.object_id AS object_id
      FROM webo_interval wbi, webo_bore wb, well w
      WHERE wbi.well_bore_id = wb.object_id
      AND   wb.well_id = w.object_id
      AND   w.object_id = p_object_id
    );

  IF ln_count_wbi = 0 THEN
    FOR curWbi IN c_wbi(p_object_id, p_daytime, p_interval_type) LOOP

      INSERT INTO ptst_object (object_id, test_no, class_name, created_by, created_date)
      VALUES (curWbi.object_id, p_test_no, lv_wbi_class_name, p_created_by, EcDp_Date_Time.getCurrentSysdate);

      createGraphDefParameters(curWbi.object_id,p_test_no,p_created_by);

    END LOOP;
  END IF;

END setWbiTestDefine;

---------------------------------------------------------------------------------------------------
-- Procedure      : setWbiTestResult
-- Description    : instantiate well bore interval test result for the given well
--
-- Preconditions  :
-- Postconditions : wbi_result will have empty rows for given well's well bore interval
--
-- Using tables   : WBI_RESULT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE setWbiTestResult (p_object_id     VARCHAR2, -- WELL OBJECT ID
                            p_daytime       DATE,     -- STABLE PERIOD START DATE
                            p_result_no     NUMBER,
                            p_interval_type VARCHAR2 DEFAULT 'DIACS',
                            p_created_by    VARCHAR2 DEFAULT NULL)
IS

  lv_created_by     VARCHAR2(32);
  ln_count_wbi      NUMBER;
  lv_wbi_class_name VARCHAR2(32);

-- Find well bore interval which active at stable period start date
CURSOR c_wbi(cp_object_id VARCHAR2, cp_daytime DATE, cp_interval_type VARCHAR2) IS
  SELECT wbi.object_id AS object_id
  FROM webo_interval_version wbiv, webo_interval wbi, webo_bore wb, well_version wv, well w
  WHERE wbiv.object_id = wbi.object_id
  AND   wbi.well_bore_id = wb.object_id
  AND   wb.well_id = w.object_id
  AND   w.object_id = cp_object_id
  AND   wv.object_id = cp_object_id
  AND   wbiv.interval_type = cp_interval_type
  AND   wbiv.daytime <= cp_daytime
  AND   Nvl(wbiv.end_date, cp_daytime+1) > cp_daytime
  AND   wv.daytime <= cp_daytime
  AND   Nvl(wv.end_date, cp_daytime+1) > cp_daytime;

BEGIN

  IF p_created_by IS NULL THEN
    lv_created_by := User;
  ELSE
    lv_created_by := p_created_by;
  END IF;

  -- check existence of wbi of same result number and of a well
  SELECT count(*) INTO ln_count_wbi
  FROM wbi_result wr
  WHERE wr.result_no = p_result_no
  AND wr.object_id IN
    (
      SELECT wbi.object_id AS object_id
      FROM webo_interval wbi, webo_bore wb, well w
      WHERE wbi.well_bore_id = wb.object_id
      AND   wb.well_id = w.object_id
      AND   w.object_id = p_object_id
    );
  --ecdp_dynsql.WriteTempText('AJAK:PWEL',ln_count_wbi);

  IF ln_count_wbi = 0 THEN
    --ecdp_dynsql.WriteTempText('AJAK:PWEL','obey IF condition');
    --ecdp_dynsql.WriteTempText('AJAK:PWEL','p_object_id=' || p_object_id);
    --ecdp_dynsql.WriteTempText('AJAK:PWEL','p_daytime=' || to_char(p_daytime,'YYYY-MM-DD"T"HH24:MI:SS'));
    --ecdp_dynsql.WriteTempText('AJAK:PWEL','p_interval_type=' || p_interval_type);

    FOR curWbi IN c_wbi(p_object_id, p_daytime, p_interval_type) LOOP
      --ecdp_dynsql.WriteTempText('AJAK:PWEL','in cursor loop');

      INSERT INTO wbi_result (object_id, result_no, created_by, created_date)
      VALUES (curWbi.object_id, p_result_no, p_created_by, EcDp_Date_Time.getCurrentSysdate);
      --ecdp_dynsql.WriteTempText('AJAK:PWEL','inserting ' || curWbi.object_id || ',' || p_result_no);

    END LOOP;
  END IF;

END setWbiTestResult;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTestObjectName
-- Description    : Returns test object name. For WELL BORE INTERVAL object, it will return as
--                  <well name> - <well bore name> - <well bore interval name>
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: - ecdp_objects.getobjclassname, ecdp_objects.GetObjName, ecdp_objects.GetObjStartDate
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTestObjectName(p_object_id VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS

  lv2_object_classname      VARCHAR2(32);
  lv2_webo_id               VARCHAR2(32);
  lv2_well_id               VARCHAR2(32);

  lv2_ret_test_object_name  VARCHAR2(200);


BEGIN
  lv2_object_classname := ecdp_objects.getobjclassname(p_object_id);

  IF lv2_object_classname = 'WELL_BORE_INTERVAL' THEN
    lv2_webo_id := ec_webo_interval.well_bore_id(p_object_id);
    lv2_well_id := ec_webo_bore.well_id(lv2_webo_id);

    lv2_ret_test_object_name := ecdp_objects.GetObjName(lv2_well_id, ecdp_objects.GetObjStartDate(lv2_well_id)) || ' - ' ||
                                ecdp_objects.GetObjName(lv2_webo_id, ecdp_objects.GetObjStartDate(lv2_webo_id)) || ' - ' ||
                                ecdp_objects.GetObjName(p_object_id, ecdp_objects.GetObjStartDate(p_object_id));
    /*
    lv2_ret_test_object_name := ecdp_objects.GetObjName(ec_webo_bore.well_id(ec_webo_interval.well_bore_id(p_object_id)), p_daytime) || ' - ' ||
                            ecdp_objects.GetObjName(ec_webo_interval.well_bore_id(p_object_id), p_daytime) || ' - ' ||
                            ecdp_objects.GetObjName(p_object_id, p_daytime);
    */

  ELSE
    lv2_ret_test_object_name := ecdp_objects.GetObjName(p_object_id, ecdp_objects.GetObjStartDate(p_object_id));
  END IF;

  RETURN lv2_ret_test_object_name;

END getTestObjectName;

---------------------------------------------------------------------------------------------------
-- Procedure      : removeWbiTestDefine
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PTST_OBJECT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE removeWbiTestDefine (p_object_id     VARCHAR2, -- WELL OBJECT ID
                               p_test_no       NUMBER)
IS

-- Find well bore interval which connected to the well
CURSOR c_wbi(cp_object_id VARCHAR2, cp_test_no NUMBER) IS
  SELECT wbi.object_id AS object_id
  FROM webo_interval wbi, webo_bore wb, well w
  WHERE wbi.well_bore_id = wb.object_id
  AND   wb.well_id = w.object_id
  AND   w.object_id = cp_object_id
  AND   wbi.object_id IN (SELECT po.object_id FROM ptst_object po WHERE po.test_no = cp_test_no);

BEGIN

  FOR curWbi IN c_wbi(p_object_id, p_test_no) LOOP

    DELETE FROM ptst_graph_define pt_gd
      WHERE pt_gd.object_id = curWbi.object_id
      AND pt_gd.test_no     = p_test_no;

    DELETE FROM ptst_object po
      WHERE po.class_name = 'WELL_BORE_INTERVAL'
      AND po.object_id    = curWbi.object_id
      AND po.test_no      = p_test_no;

  END LOOP;

END removeWbiTestDefine;

---------------------------------------------------------------------------------------------------
-- Procedure      : removeWbiTestResult
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : WBI_RESULT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE removeWbiTestResult (p_object_id     VARCHAR2, -- WELL OBJECT ID
                               p_result_no     NUMBER)
IS

-- Find well bore interval which connected to the well
CURSOR c_wbi(cp_object_id VARCHAR2, cp_result_no NUMBER) IS
  SELECT wbi.object_id AS object_id
  FROM webo_interval wbi, webo_bore wb, well w
  WHERE wbi.well_bore_id = wb.object_id
  AND   wb.well_id = w.object_id
  AND   w.object_id = cp_object_id
  AND   wbi.object_id IN (SELECT wr.object_id FROM wbi_result wr WHERE wr.result_no = cp_result_no);


BEGIN

  FOR curWbi IN c_wbi(p_object_id, p_result_no) LOOP
    DELETE FROM wbi_result wbi
      WHERE wbi.result_no = p_result_no
      AND   wbi.object_id = curWbi.object_id;
  END LOOP;

END removeWbiTestResult;


---------------------------------------------------------------------------------------------------
-- Procedure      : checkLockInd
-- Description    : Checks lock indicator from SYSTEM_MONTH, for given daytime value, Returns error if
--                  lock ind = Y
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
PROCEDURE checkLockInd(p_result_no NUMBER, p_daytime DATE, p_end_date DATE, p_object_id VARCHAR2)
IS
lv2_lock_ind VARCHAR(1);

BEGIN
  EcDp_Month_Lock.validatePeriodForLockOverlap('UPDATING', p_daytime, p_end_date,
                                               'Result No:'|| p_result_no, p_object_id);

END checkLockInd;

---------------------------------------------------------------------------------------------------
-- Procedure      : acceptTestResult
-- Description    : This procedure updates status on test result to be ACCEPTED, use_calc = Y,
--					        alt_code from prosty_codes, and last_updated_by
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PTST_RESULT, PWEL_RESULT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE acceptTestResult (p_result_no NUMBER
                           ,p_user VARCHAR2 DEFAULT NULL)
IS

  lv2_alt_code VARCHAR2(240);
  lv_record_status VARCHAR2(10);
  ln_access_level NUMBER;
  ld_pwel_valid_from_date DATE;
  ld_ptst_valid_from_date DATE;
  lv2_object_id VARCHAR2(32);
  ld_pwel_valid_to_date DATE;
  ld_ptst_valid_to_date DATE;

  CURSOR c_pwel_result(cp_result_no NUMBER) IS
    SELECT object_id, valid_from_date, end_date FROM pwel_result WHERE result_no=cp_result_no;

BEGIN

  ld_ptst_valid_from_date := ec_ptst_result.valid_from_date(p_result_no);
  ld_ptst_valid_to_date := ec_ptst_result.end_date(p_result_no);

  FOR curpwel_result IN c_pwel_result(p_result_no) LOOP
    lv2_object_id := curpwel_result.object_id;
    ld_pwel_valid_from_date := curpwel_result.valid_from_date;
    ld_pwel_valid_to_date := curpwel_result.end_date;
  END LOOP;

  checkLockInd(p_result_no, ld_ptst_valid_from_date, ld_ptst_valid_to_date, lv2_object_id);
  checkLockInd(p_result_no, ld_pwel_valid_from_date, ld_pwel_valid_to_date, lv2_object_id);

  lv2_alt_code := ec_prosty_codes.alt_code('ACCEPTED','WELL_TEST_STATUS');

  SELECT record_status
    into lv_record_status
    FROM ptst_result
   WHERE result_no = p_result_no;

  SELECT MAX(tba.level_id)
    INTO ln_access_level
    FROM T_BASIS_ACCESS tba, T_BASIS_OBJECT tbo
   WHERE tba.OBJECT_ID = tbo.OBJECT_ID
     and tbo.object_name =
         '/com.ec.prod.pt.screens/prod_test_result/accept_use_alloc_button'
     and role_id in (select role_id from t_basis_userrole where user_id = p_user);

  -- current record_status='A'
  IF lv_record_status = 'A' THEN
    -- must have access to modify 'A'
    IF ln_access_level >= 60 THEN
      -- This is when status is determined by status processes
      IF lv2_alt_code IS NULL THEN
        UPDATE ptst_result
           SET status          = 'ACCEPTED',
               use_calc        = 'Y',
               last_updated_by = Nvl(p_user, USER),
               last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Accepted, Use Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
        UPDATE pwel_result
           SET status          = 'ACCEPTED',
               use_calc        = 'Y',
               last_updated_by = Nvl(p_user, USER),
               last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Accepted, Use Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
      -- This is when status is determined by prosty_code.alt_code
      ELSIF lv2_alt_code IS NOT NULL THEN
        UPDATE ptst_result
           SET status          = 'ACCEPTED',
               use_calc        = 'Y',
               record_status   = lv2_alt_code,
               last_updated_by = Nvl(p_user, USER),
               last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Accepted, Use Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
        UPDATE pwel_result
           SET status          = 'ACCEPTED',
               use_calc        = 'Y',
               record_status   = lv2_alt_code,
               last_updated_by = Nvl(p_user, USER),
               last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Accepted, Use Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
        UPDATE eqpm_result
           SET record_status = lv2_alt_code,
         last_updated_by = Nvl(p_user,USER),
         last_updated_date = Ecdp_date_time.getCurrentSysdate,
         rev_no = rev_no + 1,
         rev_text = 'Accepted, Use Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
      END IF;

    ELSE
      RAISE_APPLICATION_ERROR(-20228,
                              'You do not have enough access to update well test.');
    END IF;
  -- current record_status='V'
  ELSIF lv_record_status = 'V' THEN
    -- must have access to modify 'V' or higher
    IF ln_access_level >= 50 THEN
      -- This is when status is determined by status processes
      IF lv2_alt_code IS NULL THEN
        UPDATE ptst_result
           SET status          = 'ACCEPTED',
               use_calc        = 'Y',
               last_updated_by = Nvl(p_user, USER),
               last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Accepted, Use Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
        UPDATE pwel_result
           SET status          = 'ACCEPTED',
               use_calc        = 'Y',
               last_updated_by = Nvl(p_user, USER),
               last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Accepted, Use Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
      -- This is when status is determined by prosty_code.alt_code
      ELSIF lv2_alt_code IS NOT NULL THEN
        IF (lv2_alt_code = 'V' and ln_access_level >= 50) OR
           (lv2_alt_code = 'A' and ln_access_level = 60) THEN
            UPDATE ptst_result
               SET status          = 'ACCEPTED',
                   use_calc        = 'Y',
                   record_status   = lv2_alt_code,
                   last_updated_by = Nvl(p_user, USER),
                   last_updated_date = Ecdp_date_time.getCurrentSysdate,
                   rev_no = rev_no + 1,
                   rev_text = 'Accepted, Use Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
            UPDATE pwel_result
               SET status          = 'ACCEPTED',
                   use_calc        = 'Y',
                   record_status   = lv2_alt_code,
                   last_updated_by = Nvl(p_user, USER),
                   last_updated_date = Ecdp_date_time.getCurrentSysdate,
                   rev_no = rev_no + 1,
                   rev_text = 'Accepted, Use Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
            UPDATE eqpm_result
               SET record_status = lv2_alt_code,
             last_updated_by = Nvl(p_user,USER),
             last_updated_date = Ecdp_date_time.getCurrentSysdate,
             rev_no = rev_no + 1,
             rev_text = 'Accepted, Use Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
        ELSE
          RAISE_APPLICATION_ERROR(-20228,
                                  'You do not have enough access to update well test.');
        END IF;
      END IF;
    ELSE
      RAISE_APPLICATION_ERROR(-20228,
                              'You do not have enough access to update well test.');
    END IF;
  -- current record_status='P'
  ELSIF lv_record_status = 'P' THEN
    -- This is when status is determined by status processes
    IF lv2_alt_code IS NULL THEN
      -- current record_status is 'P', must run status process first to Verify record
       RAISE_APPLICATION_ERROR(-20632,
                               'Well Test must be Verified first');
    -- This is when status is determined by prosty_code.alt_code
    ELSIF lv2_alt_code IS NOT NULL THEN
      IF (lv2_alt_code = 'V' and ln_access_level >= 50) OR
         (lv2_alt_code = 'A' and ln_access_level = 60) OR
         (lv2_alt_code = 'P' and ln_access_level >= 20) THEN
            UPDATE ptst_result
               SET status          = 'ACCEPTED',
                   use_calc        = 'Y',
                   record_status   = lv2_alt_code,
                   last_updated_by = Nvl(p_user, USER),
                   last_updated_date = Ecdp_date_time.getCurrentSysdate,
                   rev_no = rev_no + 1,
                   rev_text = 'Accepted, Use Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
            UPDATE pwel_result
               SET status          = 'ACCEPTED',
                   use_calc        = 'Y',
                   record_status   = lv2_alt_code,
                   last_updated_by = Nvl(p_user, USER),
                   last_updated_date = Ecdp_date_time.getCurrentSysdate,
                   rev_no = rev_no + 1,
                   rev_text = 'Accepted, Use Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
            UPDATE eqpm_result
               SET record_status = lv2_alt_code,
             last_updated_by = Nvl(p_user,USER),
             last_updated_date = Ecdp_date_time.getCurrentSysdate,
             rev_no = rev_no + 1,
             rev_text = 'Accepted, Use Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
      ELSE
        RAISE_APPLICATION_ERROR(-20228,
                                'You do not have enough access to update well test.');
      END IF;
    END IF;

  END IF;

END acceptTestResult;

---------------------------------------------------------------------------------------------------
-- Procedure      : acceptTestResultNoAlloc
-- Description    : This procedure updates status on test result to be ACCEPTED, use_calc = N,
--                  alt_code from prosty_codes, and last_updated_by
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PTST_RESULT, PWEL_RESULT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE acceptTestResultNoAlloc (p_result_no NUMBER
                                  ,p_user VARCHAR2 DEFAULT NULL)
IS
  lv2_alt_code VARCHAR2(240);
  lv_record_status VARCHAR2(10);
  ln_access_level NUMBER;
  ld_pwel_valid_from_date DATE;
  ld_ptst_valid_from_date DATE;
  lv2_object_id VARCHAR2(32);
  ld_pwel_valid_to_date DATE;
  ld_ptst_valid_to_date DATE;

  CURSOR c_pwel_result(cp_result_no NUMBER) IS
    SELECT object_id, valid_from_date, end_date FROM pwel_result WHERE result_no=cp_result_no;

BEGIN

  ld_ptst_valid_from_date := ec_ptst_result.valid_from_date(p_result_no);
  ld_ptst_valid_to_date := ec_ptst_result.end_date(p_result_no);

  FOR curpwel_result IN c_pwel_result(p_result_no) LOOP
    lv2_object_id := curpwel_result.object_id;
    ld_pwel_valid_from_date := curpwel_result.valid_from_date;
    ld_pwel_valid_to_date := curpwel_result.end_date;
  END LOOP;

  checkLockInd(p_result_no, ld_ptst_valid_from_date, ld_ptst_valid_to_date, lv2_object_id);
  checkLockInd(p_result_no, ld_pwel_valid_from_date, ld_ptst_valid_to_date, lv2_object_id);

  lv2_alt_code := ec_prosty_codes.alt_code('ACCEPTED','WELL_TEST_STATUS');

  SELECT record_status
    into lv_record_status
    FROM ptst_result
   WHERE result_no = p_result_no;

  SELECT MAX(tba.level_id)
    INTO ln_access_level
    FROM T_BASIS_ACCESS tba, T_BASIS_OBJECT tbo
   WHERE tba.OBJECT_ID = tbo.OBJECT_ID
     and tbo.object_name =
         '/com.ec.prod.pt.screens/prod_test_result/accept_no_alloc_button'
     AND role_id in (select role_id from t_basis_userrole where user_id = p_user);

 -- current record_status='A'
  IF lv_record_status = 'A' THEN
    -- must have access to modify 'A'
    IF ln_access_level >= 60 THEN
      -- This is when status is determined by status processes
      IF lv2_alt_code IS NULL THEN
        UPDATE ptst_result
           SET status          = 'ACCEPTED',
               use_calc        = 'N',
               last_updated_by = Nvl(p_user, USER),
               last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Accepted, No Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
        UPDATE pwel_result
           SET status          = 'ACCEPTED',
               use_calc        = 'N',
               last_updated_by = Nvl(p_user, USER),
               last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Accepted, No Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
      -- This is when status is determined by prosty_code.alt_code
      ELSIF lv2_alt_code IS NOT NULL THEN
        UPDATE ptst_result
           SET status          = 'ACCEPTED',
               use_calc        = 'N',
               record_status   = lv2_alt_code,
               last_updated_by = Nvl(p_user, USER),
               last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Accepted, No Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
        UPDATE pwel_result
           SET status          = 'ACCEPTED',
               use_calc        = 'N',
               record_status   = lv2_alt_code,
               last_updated_by = Nvl(p_user, USER),
               last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Accepted, No Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
        UPDATE eqpm_result
           SET record_status = lv2_alt_code,
           last_updated_by = Nvl(p_user,USER),
           last_updated_date = Ecdp_date_time.getCurrentSysdate,
           rev_no = rev_no + 1,
           rev_text = 'Accepted, No Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
      END IF;

    ELSE
      RAISE_APPLICATION_ERROR(-20228,
                              'You do not have enough access to update well test.');
    END IF;
  -- current record_status='V'
  ELSIF lv_record_status = 'V' THEN
    -- must have access to modify 'V' or higher
    IF ln_access_level >= 50 THEN
      -- This is when status is determined by status processes
      IF lv2_alt_code IS NULL THEN
        UPDATE ptst_result
           SET status          = 'ACCEPTED',
               use_calc        = 'N',
               last_updated_by = Nvl(p_user, USER),
               last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Accepted, No Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
        UPDATE pwel_result
           SET status          = 'ACCEPTED',
               use_calc        = 'N',
               last_updated_by = Nvl(p_user, USER),
               last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Accepted, No Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
      -- This is when status is determined by prosty_code.alt_code
      ELSIF lv2_alt_code IS NOT NULL THEN
        IF (lv2_alt_code = 'V' and ln_access_level >= 50) OR
           (lv2_alt_code = 'A' and ln_access_level = 60) THEN
            UPDATE ptst_result
               SET status          = 'ACCEPTED',
                   use_calc        = 'N',
                   record_status   = lv2_alt_code,
                   last_updated_by = Nvl(p_user, USER),
                   last_updated_date = Ecdp_date_time.getCurrentSysdate,
                   rev_no = rev_no + 1,
                   rev_text = 'Accepted, No Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
            UPDATE pwel_result
               SET status          = 'ACCEPTED',
                   use_calc        = 'N',
                   record_status   = lv2_alt_code,
                   last_updated_by = Nvl(p_user, USER),
                   last_updated_date = Ecdp_date_time.getCurrentSysdate,
                   rev_no = rev_no + 1,
                   rev_text = 'Accepted, No Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
            UPDATE eqpm_result
               SET record_status = lv2_alt_code,
               last_updated_by = Nvl(p_user,USER),
               last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Accepted, No Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
        ELSE
          RAISE_APPLICATION_ERROR(-20228,
                                  'You do not have enough access to update well test.');
        END IF;
      END IF;
    ELSE
      RAISE_APPLICATION_ERROR(-20228,
                              'You do not have enough access to update well test.');
    END IF;
  -- current record_status='P'
  ELSIF lv_record_status = 'P' THEN
    -- This is when status is determined by status processes
    IF lv2_alt_code IS NULL THEN
      -- current record_status is 'P', must run status process first to Verify record
       RAISE_APPLICATION_ERROR(-20632,
                               'Well Test must be Verified first');
    -- This is when status is determined by prosty_code.alt_code
    ELSIF lv2_alt_code IS NOT NULL THEN
      IF (lv2_alt_code = 'V' and ln_access_level >= 50) OR
         (lv2_alt_code = 'A' and ln_access_level = 60) OR
         (lv2_alt_code = 'P' and ln_access_level >= 20) THEN
            UPDATE ptst_result
               SET status          = 'ACCEPTED',
                   use_calc        = 'N',
                   record_status   = lv2_alt_code,
                   last_updated_by = Nvl(p_user, USER),
                   last_updated_date = Ecdp_date_time.getCurrentSysdate,
                   rev_no = rev_no + 1,
                   rev_text = 'Accepted, No Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
            UPDATE pwel_result
               SET status          = 'ACCEPTED',
                   use_calc        = 'N',
                   record_status   = lv2_alt_code,
                   last_updated_by = Nvl(p_user, USER),
                   last_updated_date = Ecdp_date_time.getCurrentSysdate,
                   rev_no = rev_no + 1,
                   rev_text = 'Accepted, No Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
            UPDATE eqpm_result
               SET record_status = lv2_alt_code,
               last_updated_by = Nvl(p_user,USER),
               last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Accepted, No Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
      ELSE
        RAISE_APPLICATION_ERROR(-20228,
                                'You do not have enough access to update well test.');
      END IF;
    END IF;

  END IF;

END acceptTestResultNoAlloc;

---------------------------------------------------------------------------------------------------
-- Procedure      : rejectTestResult
-- Description    : This procedure updates status on test result to be REJECTED, use_calc = N,
--                  alt_code from prosty_codes, and last_updated_by
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PTST_RESULT, PWEL_RESULT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE rejectTestResult (p_result_no NUMBER
                           ,p_user VARCHAR2 DEFAULT NULL)
IS
  lv2_alt_code VARCHAR2(240);
  lv_record_status VARCHAR2(10);
  ln_access_level NUMBER;
  ld_pwel_valid_from_date DATE;
  ld_ptst_valid_from_date DATE;
  lv2_object_id VARCHAR2(32);
  ld_pwel_valid_to_date DATE;
  ld_ptst_valid_to_date DATE;

  CURSOR c_pwel_result(cp_result_no NUMBER) IS
    SELECT object_id, valid_from_date, end_date FROM pwel_result WHERE result_no=cp_result_no;

BEGIN

  ld_ptst_valid_from_date := ec_ptst_result.valid_from_date(p_result_no);
  ld_ptst_valid_to_date := ec_ptst_result.end_date(p_result_no);

  FOR curpwel_result IN c_pwel_result(p_result_no) LOOP
    lv2_object_id := curpwel_result.object_id;
    ld_pwel_valid_from_date := curpwel_result.valid_from_date;
    ld_pwel_valid_to_date := curpwel_result.end_date;
  END LOOP;

  checkLockInd(p_result_no, ld_ptst_valid_from_date, ld_ptst_valid_to_date, lv2_object_id);
  checkLockInd(p_result_no, ld_pwel_valid_from_date, ld_pwel_valid_to_date, lv2_object_id);

  lv2_alt_code := ec_prosty_codes.alt_code('REJECTED','WELL_TEST_STATUS');

  SELECT record_status
    into lv_record_status
    FROM ptst_result
   WHERE result_no = p_result_no;

  SELECT MAX(tba.level_id)
    INTO ln_access_level
    FROM T_BASIS_ACCESS tba, T_BASIS_OBJECT tbo
   WHERE tba.OBJECT_ID = tbo.OBJECT_ID
     and tbo.object_name =
         '/com.ec.prod.pt.screens/prod_test_result/reject_button'
     AND role_id in (select role_id from t_basis_userrole where user_id = p_user);

  -- current record_status='A'
  IF lv_record_status = 'A' THEN
    -- must have access to modify 'A'
    IF ln_access_level >= 60 THEN
      -- This is when status is determined by status processes
      IF lv2_alt_code IS NULL THEN
        UPDATE ptst_result
           SET status          = 'REJECTED',
               use_calc        = 'N',
               last_updated_by = Nvl(p_user, USER),
               last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Rejected, at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
        UPDATE pwel_result
           SET status          = 'REJECTED',
               use_calc        = 'N',
               last_updated_by = Nvl(p_user, USER),
               last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Rejected, at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
      -- This is when status is determined by prosty_code.alt_code
      ELSIF lv2_alt_code IS NOT NULL THEN
        UPDATE ptst_result
           SET status          = 'REJECTED',
               use_calc        = 'N',
               record_status   = lv2_alt_code,
               last_updated_by = Nvl(p_user, USER),
               last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Rejected, at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
        UPDATE pwel_result
           SET status          = 'REJECTED',
               use_calc        = 'N',
               record_status   = lv2_alt_code,
               last_updated_by = Nvl(p_user, USER),
               last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Rejected, at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
        UPDATE eqpm_result
           SET record_status = lv2_alt_code,
               last_updated_by = Nvl(p_user,USER),
               last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Rejected, at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
      END IF;

    ELSE
      RAISE_APPLICATION_ERROR(-20227,
                              'You do not have enough access to reject the well test.');
    END IF;
  -- current record_status='V'
  ELSIF lv_record_status = 'V' THEN
    -- must have access to modify 'V' or higher
    IF ln_access_level >= 50 THEN
      -- This is when status is determined by status processes
      IF lv2_alt_code IS NULL THEN
        UPDATE ptst_result
           SET status          = 'REJECTED',
               use_calc        = 'N',
               last_updated_by = Nvl(p_user, USER),
               last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Rejected, at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
        UPDATE pwel_result
           SET status          = 'REJECTED',
               use_calc        = 'N',
               last_updated_by = Nvl(p_user, USER),
               last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Rejected, at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
      -- This is when status is determined by prosty_code.alt_code
      ELSIF lv2_alt_code IS NOT NULL THEN
        IF (lv2_alt_code = 'V' and ln_access_level >= 50) OR
           (lv2_alt_code = 'A' and ln_access_level = 60) THEN
            UPDATE ptst_result
               SET status          = 'REJECTED',
                   use_calc        = 'N',
                   record_status   = lv2_alt_code,
                   last_updated_by = Nvl(p_user, USER),
                   last_updated_date = Ecdp_date_time.getCurrentSysdate,
                   rev_no = rev_no + 1,
                   rev_text = 'Rejected, at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
            UPDATE pwel_result
               SET status          = 'REJECTED',
                   use_calc        = 'N',
                   record_status   = lv2_alt_code,
                   last_updated_by = Nvl(p_user, USER),
                   last_updated_date = Ecdp_date_time.getCurrentSysdate,
                   rev_no = rev_no + 1,
                   rev_text = 'Rejected, at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
            UPDATE eqpm_result
               SET record_status = lv2_alt_code,
               last_updated_by = Nvl(p_user,USER),
               last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1, rev_text = 'Rejected, at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
        ELSE
          RAISE_APPLICATION_ERROR(-20227,
                                  'You do not have enough access to reject the well test.');
        END IF;
      END IF;
    ELSE
      RAISE_APPLICATION_ERROR(-20227,
                              'You do not have enough access to reject the well test.');
    END IF;
  -- current record_status='P'
  ELSIF lv_record_status = 'P' THEN
    -- This is when status is determined by status processes
    IF lv2_alt_code IS NULL THEN
      -- current record_status is 'P', must run status process first to Verify record
       RAISE_APPLICATION_ERROR(-20632,
                               'Well Test must be Verified first');
    -- This is when status is determined by prosty_code.alt_code
    ELSIF lv2_alt_code IS NOT NULL THEN
      IF (lv2_alt_code = 'V' and ln_access_level >= 50) OR
         (lv2_alt_code = 'A' and ln_access_level = 60) OR
         (lv2_alt_code = 'P' and ln_access_level >= 20) THEN
            UPDATE ptst_result
               SET status          = 'REJECTED',
                   use_calc        = 'N',
                   record_status   = lv2_alt_code,
                   last_updated_by = Nvl(p_user, USER),
                   last_updated_date = Ecdp_date_time.getCurrentSysdate,
                   rev_no = rev_no + 1,
                   rev_text = 'Rejected, at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
            UPDATE pwel_result
               SET status          = 'REJECTED',
                   use_calc        = 'N',
                   record_status   = lv2_alt_code,
                   last_updated_by = Nvl(p_user, USER),
                   last_updated_date = Ecdp_date_time.getCurrentSysdate,
                   rev_no = rev_no + 1,
                   rev_text = 'Rejected, at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
            UPDATE eqpm_result
               SET record_status = lv2_alt_code,
               last_updated_by = Nvl(p_user,USER),
               last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1, rev_text = 'Rejected, at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
      ELSE
        RAISE_APPLICATION_ERROR(-20227,
                                'You do not have enough access to reject the well test.');
      END IF;
    END IF;

  END IF;

END rejectTestResult;

---------------------------------------------------------------------------------------------------
-- Procedure      : acceptSingleTestResult
-- Description    : This procedure updates status on test result to be ACCEPTED, use_calc = Y,
--					        alt_code from prosty_codes, and last_updated_by
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PTST_RESULT, PWEL_RESULT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE acceptSingleTestResult (p_result_no NUMBER
                           ,p_user VARCHAR2 DEFAULT NULL)
IS

  lv2_alt_code VARCHAR2(240);
  lv_record_status VARCHAR2(10);
  ln_access_level NUMBER;
  ld_pwel_valid_from_date DATE;
  ld_ptst_valid_from_date DATE;
  lv2_object_id VARCHAR2(32);
  ld_pwel_valid_to_date DATE;
  ld_ptst_valid_to_date DATE;

  CURSOR c_pwel_result(cp_result_no NUMBER) IS
    SELECT object_id, valid_from_date, end_date FROM pwel_result WHERE result_no=cp_result_no;

BEGIN

  ld_ptst_valid_from_date := ec_ptst_result.valid_from_date(p_result_no);
  ld_ptst_valid_to_date := ec_ptst_result.end_date(p_result_no);

  FOR curpwel_result IN c_pwel_result(p_result_no) LOOP
    lv2_object_id := curpwel_result.object_id;
    ld_pwel_valid_from_date := curpwel_result.valid_from_date;
    ld_pwel_valid_to_date := curpwel_result.end_date;
  END LOOP;

  checkLockInd(p_result_no, ld_ptst_valid_from_date, ld_ptst_valid_to_date, lv2_object_id);
  checkLockInd(p_result_no, ld_pwel_valid_from_date, ld_pwel_valid_to_date, lv2_object_id);

   -- Well Test can be accepted/used in allocation only if 'Valid From Date' is NOT NULL
   IF ld_ptst_valid_from_date is NOT NULL THEN

  lv2_alt_code := ec_prosty_codes.alt_code('ACCEPTED','WELL_TEST_STATUS');

  SELECT record_status
    into lv_record_status
    FROM ptst_result
   WHERE result_no = p_result_no;

  SELECT MAX(tba.level_id)
    INTO ln_access_level
    FROM T_BASIS_ACCESS tba, T_BASIS_OBJECT tbo
   WHERE tba.OBJECT_ID = tbo.OBJECT_ID
     and tbo.object_name =
         '/com.ec.prod.pt.screens/single_pwel_test_result/accept_alloc'
     and role_id in (select role_id from t_basis_userrole where user_id = p_user);

  -- current record_status='A'
  IF lv_record_status = 'A' THEN
    -- must have access to modify 'A'
    IF ln_access_level >= 60 THEN
      -- This is when status is determined by status processes
      IF lv2_alt_code IS NULL THEN
        UPDATE ptst_result
           SET status          = 'ACCEPTED',
               use_calc        = 'Y',
               last_updated_by = Nvl(p_user, USER),
			   last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Accepted, Use Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
        UPDATE pwel_result
           SET status          = 'ACCEPTED',
               use_calc        = 'Y',
               last_updated_by = Nvl(p_user, USER),
			   last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Accepted, Use Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
      -- This is when status is determined by prosty_code.alt_code
      ELSIF lv2_alt_code IS NOT NULL THEN
        UPDATE ptst_result
           SET status          = 'ACCEPTED',
               use_calc        = 'Y',
               record_status   = lv2_alt_code,
               last_updated_by = Nvl(p_user, USER),
			   last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Accepted, Use Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
        UPDATE pwel_result
           SET status          = 'ACCEPTED',
               use_calc        = 'Y',
               record_status   = lv2_alt_code,
               last_updated_by = Nvl(p_user, USER),
			   last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Accepted, Use Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
        UPDATE eqpm_result
           SET record_status = lv2_alt_code,
			 last_updated_by = Nvl(p_user,USER),
			 last_updated_date = Ecdp_date_time.getCurrentSysdate,
			 rev_no = rev_no + 1,
			 rev_text = 'Accepted, Use Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
      END IF;

    ELSE
      RAISE_APPLICATION_ERROR(-20228,
                              'You do not have enough access to update well test.');
    END IF;
  -- current record_status='V'
  ELSIF lv_record_status = 'V' THEN
    -- must have access to modify 'V' or higher
    IF ln_access_level >= 50 THEN
      -- This is when status is determined by status processes
      IF lv2_alt_code IS NULL THEN
        UPDATE ptst_result
           SET status          = 'ACCEPTED',
               use_calc        = 'Y',
               last_updated_by = Nvl(p_user, USER),
			   last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Accepted, Use Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
        UPDATE pwel_result
           SET status          = 'ACCEPTED',
               use_calc        = 'Y',
               last_updated_by = Nvl(p_user, USER),
			   last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Accepted, Use Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
      -- This is when status is determined by prosty_code.alt_code
      ELSIF lv2_alt_code IS NOT NULL THEN
        IF (lv2_alt_code = 'V' and ln_access_level >= 50) OR
           (lv2_alt_code = 'A' and ln_access_level = 60) THEN
            UPDATE ptst_result
               SET status          = 'ACCEPTED',
                   use_calc        = 'Y',
                   record_status   = lv2_alt_code,
                   last_updated_by = Nvl(p_user, USER),
				   last_updated_date = Ecdp_date_time.getCurrentSysdate,
                   rev_no = rev_no + 1,
                   rev_text = 'Accepted, Use Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
            UPDATE pwel_result
               SET status          = 'ACCEPTED',
                   use_calc        = 'Y',
                   record_status   = lv2_alt_code,
                   last_updated_by = Nvl(p_user, USER),
				   last_updated_date = Ecdp_date_time.getCurrentSysdate,
                   rev_no = rev_no + 1,
                   rev_text = 'Accepted, Use Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
            UPDATE eqpm_result
               SET record_status = lv2_alt_code,
				 last_updated_by = Nvl(p_user,USER),
				 last_updated_date = Ecdp_date_time.getCurrentSysdate,
				 rev_no = rev_no + 1,
				 rev_text = 'Accepted, Use Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
        ELSE
          RAISE_APPLICATION_ERROR(-20228,
                                  'You do not have enough access to update well test.');
        END IF;
      END IF;
    ELSE
      RAISE_APPLICATION_ERROR(-20228,
                              'You do not have enough access to update well test.');
    END IF;
  -- current record_status='P'
  ELSIF lv_record_status = 'P' THEN
    -- This is when status is determined by status processes
    IF lv2_alt_code IS NULL THEN
      -- current record_status is 'P', must run status process first to Verify record
       RAISE_APPLICATION_ERROR(-20632,
                               'Well Test must be Verified first');
    -- This is when status is determined by prosty_code.alt_code
    ELSIF lv2_alt_code IS NOT NULL THEN
      IF (lv2_alt_code = 'V' and ln_access_level >= 50) OR
         (lv2_alt_code = 'A' and ln_access_level = 60) OR
         (lv2_alt_code = 'P' and ln_access_level >= 20) THEN
            UPDATE ptst_result
               SET status          = 'ACCEPTED',
                   use_calc        = 'Y',
                   record_status   = lv2_alt_code,
                   last_updated_by = Nvl(p_user, USER),
				   last_updated_date = Ecdp_date_time.getCurrentSysdate,
                   rev_no = rev_no + 1,
                   rev_text = 'Accepted, Use Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
            UPDATE pwel_result
               SET status          = 'ACCEPTED',
                   use_calc        = 'Y',
                   record_status   = lv2_alt_code,
                   last_updated_by = Nvl(p_user, USER),
				   last_updated_date = Ecdp_date_time.getCurrentSysdate,
                   rev_no = rev_no + 1,
                   rev_text = 'Accepted, Use Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
            UPDATE eqpm_result
               SET record_status = lv2_alt_code,
				 last_updated_by = Nvl(p_user,USER),
				 last_updated_date = Ecdp_date_time.getCurrentSysdate,
				 rev_no = rev_no + 1,
				 rev_text = 'Accepted, Use Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
      ELSE
        RAISE_APPLICATION_ERROR(-20228,
                                'You do not have enough access to update well test.');
      END IF;
    END IF;

  END IF;
 ELSE
     RAISE_APPLICATION_ERROR(-20233,
                                'Well Test cannot be used in allocation. Valid From Date/Time is NULL.');
     -- end of validate 'Valid From Date'
 END IF;
END acceptSingleTestResult;

---------------------------------------------------------------------------------------------------
-- Procedure      : acceptSingleTestResultNoAlloc
-- Description    : This procedure updates status on test result to be ACCEPTED, use_calc = N,
--                  alt_code from prosty_codes, and last_updated_by
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PTST_RESULT, PWEL_RESULT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE acceptSingleTestResultNoAlloc (p_result_no NUMBER
                                  ,p_user VARCHAR2 DEFAULT NULL)
IS
  lv2_alt_code VARCHAR2(240);
  lv_record_status VARCHAR2(10);
  ln_access_level NUMBER;
  ld_pwel_valid_from_date DATE;
  ld_ptst_valid_from_date DATE;
  lv2_object_id VARCHAR2(32);
  ld_pwel_valid_to_date DATE;
  ld_ptst_valid_to_date DATE;

  CURSOR c_pwel_result(cp_result_no NUMBER) IS
    SELECT object_id, valid_from_date, end_date FROM pwel_result WHERE result_no=cp_result_no;

BEGIN

  ld_ptst_valid_from_date := ec_ptst_result.valid_from_date(p_result_no);
  ld_ptst_valid_to_date := ec_ptst_result.end_date(p_result_no);

  FOR curpwel_result IN c_pwel_result(p_result_no) LOOP
    lv2_object_id := curpwel_result.object_id;
    ld_pwel_valid_from_date := curpwel_result.valid_from_date;
    ld_pwel_valid_to_date := curpwel_result.end_date;
  END LOOP;

  checkLockInd(p_result_no, ld_ptst_valid_from_date, ld_ptst_valid_to_date, lv2_object_id);
  checkLockInd(p_result_no, ld_pwel_valid_from_date, ld_ptst_valid_to_date, lv2_object_id);

  lv2_alt_code := ec_prosty_codes.alt_code('ACCEPTED','WELL_TEST_STATUS');

  SELECT record_status
    into lv_record_status
    FROM ptst_result
   WHERE result_no = p_result_no;

  SELECT MAX(tba.level_id)
    INTO ln_access_level
    FROM T_BASIS_ACCESS tba, T_BASIS_OBJECT tbo
   WHERE tba.OBJECT_ID = tbo.OBJECT_ID
     and tbo.object_name =
         '/com.ec.prod.pt.screens/single_pwel_test_result/accept_no_alloc'
     AND role_id in (select role_id from t_basis_userrole where user_id = p_user);

 -- current record_status='A'
  IF lv_record_status = 'A' THEN
    -- must have access to modify 'A'
    IF ln_access_level >= 60 THEN
      -- This is when status is determined by status processes
      IF lv2_alt_code IS NULL THEN
        UPDATE ptst_result
           SET status          = 'ACCEPTED',
               use_calc        = 'N',
               last_updated_by = Nvl(p_user, USER),
			   last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Accepted, No Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
        UPDATE pwel_result
           SET status          = 'ACCEPTED',
               use_calc        = 'N',
               last_updated_by = Nvl(p_user, USER),
			   last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Accepted, No Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
      -- This is when status is determined by prosty_code.alt_code
      ELSIF lv2_alt_code IS NOT NULL THEN
        UPDATE ptst_result
           SET status          = 'ACCEPTED',
               use_calc        = 'N',
               record_status   = lv2_alt_code,
               last_updated_by = Nvl(p_user, USER),
			   last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Accepted, No Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
        UPDATE pwel_result
           SET status          = 'ACCEPTED',
               use_calc        = 'N',
               record_status   = lv2_alt_code,
               last_updated_by = Nvl(p_user, USER),
			   last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Accepted, No Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
        UPDATE eqpm_result
           SET record_status = lv2_alt_code,
			   last_updated_by = Nvl(p_user,USER),
			   last_updated_date = Ecdp_date_time.getCurrentSysdate,
			   rev_no = rev_no + 1,
			   rev_text = 'Accepted, No Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
      END IF;

    ELSE
      RAISE_APPLICATION_ERROR(-20228,
                              'You do not have enough access to update well test.');
    END IF;
  -- current record_status='V'
  ELSIF lv_record_status = 'V' THEN
    -- must have access to modify 'V' or higher
    IF ln_access_level >= 50 THEN
      -- This is when status is determined by status processes
      IF lv2_alt_code IS NULL THEN
        UPDATE ptst_result
           SET status          = 'ACCEPTED',
               use_calc        = 'N',
               last_updated_by = Nvl(p_user, USER),
			   last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Accepted, No Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
        UPDATE pwel_result
           SET status          = 'ACCEPTED',
               use_calc        = 'N',
               last_updated_by = Nvl(p_user, USER),
			   last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Accepted, No Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
      -- This is when status is determined by prosty_code.alt_code
      ELSIF lv2_alt_code IS NOT NULL THEN
        IF (lv2_alt_code = 'V' and ln_access_level >= 50) OR
           (lv2_alt_code = 'A' and ln_access_level = 60) THEN
            UPDATE ptst_result
               SET status          = 'ACCEPTED',
                   use_calc        = 'N',
                   record_status   = lv2_alt_code,
                   last_updated_by = Nvl(p_user, USER),
				   last_updated_date = Ecdp_date_time.getCurrentSysdate,
                   rev_no = rev_no + 1,
                   rev_text = 'Accepted, No Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
            UPDATE pwel_result
               SET status          = 'ACCEPTED',
                   use_calc        = 'N',
                   record_status   = lv2_alt_code,
                   last_updated_by = Nvl(p_user, USER),
				   last_updated_date = Ecdp_date_time.getCurrentSysdate,
                   rev_no = rev_no + 1,
                   rev_text = 'Accepted, No Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
            UPDATE eqpm_result
               SET record_status = lv2_alt_code,
				   last_updated_by = Nvl(p_user,USER),
				   last_updated_date = Ecdp_date_time.getCurrentSysdate,
				   rev_no = rev_no + 1,
				   rev_text = 'Accepted, No Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
        ELSE
          RAISE_APPLICATION_ERROR(-20228,
                                  'You do not have enough access to update well test.');
        END IF;
      END IF;
    ELSE
      RAISE_APPLICATION_ERROR(-20228,
                              'You do not have enough access to update well test.');
    END IF;
  -- current record_status='P'
  ELSIF lv_record_status = 'P' THEN
    -- This is when status is determined by status processes
    IF lv2_alt_code IS NULL THEN
      -- current record_status is 'P', must run status process first to Verify record
       RAISE_APPLICATION_ERROR(-20632,
                               'Well Test must be Verified first');
    -- This is when status is determined by prosty_code.alt_code
    ELSIF lv2_alt_code IS NOT NULL THEN
      IF (lv2_alt_code = 'V' and ln_access_level >= 50) OR
         (lv2_alt_code = 'A' and ln_access_level = 60) OR
         (lv2_alt_code = 'P' and ln_access_level >= 20) THEN
            UPDATE ptst_result
               SET status          = 'ACCEPTED',
                   use_calc        = 'N',
                   record_status   = lv2_alt_code,
                   last_updated_by = Nvl(p_user, USER),
				   last_updated_date = Ecdp_date_time.getCurrentSysdate,
                   rev_no = rev_no + 1,
                   rev_text = 'Accepted, No Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
            UPDATE pwel_result
               SET status          = 'ACCEPTED',
                   use_calc        = 'N',
                   record_status   = lv2_alt_code,
                   last_updated_by = Nvl(p_user, USER),
				   last_updated_date = Ecdp_date_time.getCurrentSysdate,
                   rev_no = rev_no + 1,
                   rev_text = 'Accepted, No Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
            UPDATE eqpm_result
               SET record_status = lv2_alt_code,
				   last_updated_by = Nvl(p_user,USER),
				   last_updated_date = Ecdp_date_time.getCurrentSysdate,
				   rev_no = rev_no + 1,
				   rev_text = 'Accepted, No Alloc at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
      ELSE
        RAISE_APPLICATION_ERROR(-20228,
                                'You do not have enough access to update well test.');
      END IF;
    END IF;

  END IF;

END acceptSingleTestResultNoAlloc;

---------------------------------------------------------------------------------------------------
-- Procedure      : rejectSingleTestResult
-- Description    : This procedure updates status on test result to be REJECTED, use_calc = N,
--                  alt_code from prosty_codes, and last_updated_by
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PTST_RESULT, PWEL_RESULT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE rejectSingleTestResult (p_result_no NUMBER
                           ,p_user VARCHAR2 DEFAULT NULL)
IS
  lv2_alt_code VARCHAR2(240);
  lv_record_status VARCHAR2(10);
  ln_access_level NUMBER;
  ld_pwel_valid_from_date DATE;
  ld_ptst_valid_from_date DATE;
  lv2_object_id VARCHAR2(32);
  ld_pwel_valid_to_date DATE;
  ld_ptst_valid_to_date DATE;

  CURSOR c_pwel_result(cp_result_no NUMBER) IS
    SELECT object_id, valid_from_date, end_date FROM pwel_result WHERE result_no=cp_result_no;

BEGIN

  ld_ptst_valid_from_date := ec_ptst_result.valid_from_date(p_result_no);
  ld_ptst_valid_to_date := ec_ptst_result.end_date(p_result_no);

  FOR curpwel_result IN c_pwel_result(p_result_no) LOOP
    lv2_object_id := curpwel_result.object_id;
    ld_pwel_valid_from_date := curpwel_result.valid_from_date;
    ld_pwel_valid_to_date := curpwel_result.end_date;
  END LOOP;

  checkLockInd(p_result_no, ld_ptst_valid_from_date, ld_ptst_valid_to_date, lv2_object_id);
  checkLockInd(p_result_no, ld_pwel_valid_from_date, ld_pwel_valid_to_date, lv2_object_id);

  lv2_alt_code := ec_prosty_codes.alt_code('REJECTED','WELL_TEST_STATUS');

  SELECT record_status
    into lv_record_status
    FROM ptst_result
   WHERE result_no = p_result_no;

  SELECT MAX(tba.level_id)
    INTO ln_access_level
    FROM T_BASIS_ACCESS tba, T_BASIS_OBJECT tbo
   WHERE tba.OBJECT_ID = tbo.OBJECT_ID
     and tbo.object_name =
         '/com.ec.prod.pt.screens/single_pwel_test_result/reject_button'
     AND role_id in (select role_id from t_basis_userrole where user_id = p_user);

  -- current record_status='A'
  IF lv_record_status = 'A' THEN
    -- must have access to modify 'A'
    IF ln_access_level >= 60 THEN
      -- This is when status is determined by status processes
      IF lv2_alt_code IS NULL THEN
        UPDATE ptst_result
           SET status          = 'REJECTED',
               use_calc        = 'N',
               last_updated_by = Nvl(p_user, USER),
			   last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Rejected, at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
        UPDATE pwel_result
           SET status          = 'REJECTED',
               use_calc        = 'N',
               last_updated_by = Nvl(p_user, USER),
			   last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Rejected, at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
      -- This is when status is determined by prosty_code.alt_code
      ELSIF lv2_alt_code IS NOT NULL THEN
        UPDATE ptst_result
           SET status          = 'REJECTED',
               use_calc        = 'N',
               record_status   = lv2_alt_code,
               last_updated_by = Nvl(p_user, USER),
			   last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Rejected, at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
        UPDATE pwel_result
           SET status          = 'REJECTED',
               use_calc        = 'N',
               record_status   = lv2_alt_code,
               last_updated_by = Nvl(p_user, USER),
			   last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Rejected, at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
        UPDATE eqpm_result
           SET record_status = lv2_alt_code,
               last_updated_by = Nvl(p_user,USER),
			   last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Rejected, at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
      END IF;

    ELSE
      RAISE_APPLICATION_ERROR(-20227,
                              'You do not have enough access to reject the well test.');
    END IF;
  -- current record_status='V'
  ELSIF lv_record_status = 'V' THEN
    -- must have access to modify 'V' or higher
    IF ln_access_level >= 50 THEN
      -- This is when status is determined by status processes
      IF lv2_alt_code IS NULL THEN
        UPDATE ptst_result
           SET status          = 'REJECTED',
               use_calc        = 'N',
               last_updated_by = Nvl(p_user, USER),
			   last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Rejected, at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
        UPDATE pwel_result
           SET status          = 'REJECTED',
               use_calc        = 'N',
               last_updated_by = Nvl(p_user, USER),
			   last_updated_date = Ecdp_date_time.getCurrentSysdate,
               rev_no = rev_no + 1,
               rev_text = 'Rejected, at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE result_no = p_result_no;
      -- This is when status is determined by prosty_code.alt_code
      ELSIF lv2_alt_code IS NOT NULL THEN
        IF (lv2_alt_code = 'V' and ln_access_level >= 50) OR
           (lv2_alt_code = 'A' and ln_access_level = 60) THEN
            UPDATE ptst_result
               SET status          = 'REJECTED',
                   use_calc        = 'N',
                   record_status   = lv2_alt_code,
                   last_updated_by = Nvl(p_user, USER),
				   last_updated_date = Ecdp_date_time.getCurrentSysdate,
                   rev_no = rev_no + 1,
                   rev_text = 'Rejected, at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
            UPDATE pwel_result
               SET status          = 'REJECTED',
                   use_calc        = 'N',
                   record_status   = lv2_alt_code,
                   last_updated_by = Nvl(p_user, USER),
				   last_updated_date = Ecdp_date_time.getCurrentSysdate,
                   rev_no = rev_no + 1,
                   rev_text = 'Rejected, at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
            UPDATE eqpm_result
               SET record_status = lv2_alt_code,
				   last_updated_by = Nvl(p_user,USER),
				   last_updated_date = Ecdp_date_time.getCurrentSysdate,
				   rev_no = rev_no + 1, rev_text = 'Rejected, at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
        ELSE
          RAISE_APPLICATION_ERROR(-20227,
                                  'You do not have enough access to reject the well test.');
        END IF;
      END IF;
    ELSE
      RAISE_APPLICATION_ERROR(-20227,
                              'You do not have enough access to reject the well test.');
    END IF;
  -- current record_status='P'
  ELSIF lv_record_status = 'P' THEN
    -- This is when status is determined by status processes
    IF lv2_alt_code IS NULL THEN
      -- current record_status is 'P', must run status process first to Verify record
       RAISE_APPLICATION_ERROR(-20632,
                               'Well Test must be Verified first');
    -- This is when status is determined by prosty_code.alt_code
    ELSIF lv2_alt_code IS NOT NULL THEN
      IF (lv2_alt_code = 'V' and ln_access_level >= 50) OR
         (lv2_alt_code = 'A' and ln_access_level = 60) OR
         (lv2_alt_code = 'P' and ln_access_level >= 20) THEN
            UPDATE ptst_result
               SET status          = 'REJECTED',
                   use_calc        = 'N',
                   record_status   = lv2_alt_code,
                   last_updated_by = Nvl(p_user, USER),
				   last_updated_date = Ecdp_date_time.getCurrentSysdate,
                   rev_no = rev_no + 1,
                   rev_text = 'Rejected, at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
            UPDATE pwel_result
               SET status          = 'REJECTED',
                   use_calc        = 'N',
                   record_status   = lv2_alt_code,
                   last_updated_by = Nvl(p_user, USER),
				   last_updated_date = Ecdp_date_time.getCurrentSysdate,
                   rev_no = rev_no + 1,
                   rev_text = 'Rejected, at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
            UPDATE eqpm_result
               SET record_status = lv2_alt_code,
				   last_updated_by = Nvl(p_user,USER),
				   last_updated_date = Ecdp_date_time.getCurrentSysdate,
				   rev_no = rev_no + 1,
				   rev_text = 'Rejected, at ' || to_char(Ecdp_date_time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')
             WHERE result_no = p_result_no;
      ELSE
        RAISE_APPLICATION_ERROR(-20227,
                                'You do not have enough access to reject the well test.');
      END IF;
    END IF;

  END IF;

END rejectSingleTestResult;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : uncheckMultiselect
-- Description    : This procedure updates wt_multiselect to be N in PWEL_RESULT
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PWEL_RESULT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE uncheckMultiselect (p_result_no NUMBER
               ,p_user VARCHAR2 DEFAULT NULL)
IS

BEGIN

  UPDATE pwel_result SET wt_multiselect = 'N', last_updated_by = Nvl(p_user,USER) WHERE result_no = p_result_no;


END uncheckMultiselect;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validate
-- Description    : Raise exception if future date is entered
--
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE validateTestDate(
            p_daytime        DATE
            ) IS

BEGIN

     IF p_daytime >= trunc(EcDp_Date_Time.getCurrentSysdate(),'DD') + 1 THEN
         RAISE_APPLICATION_ERROR(-20109,'Future date is not allowed');
     END IF;

END validateTestDate;

---------------------------------------------------------------------------------------------------
-- Function       : getSingleDataClassName
-- Description    : Retrieves the associated single data class name for a given TEST DEVICE
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
--
-- Using functions: ec_eqpm_version.instrumentation_type
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSingleDataClassName(p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2
--</EC-DOC>
IS

  lv2_inst_type     VARCHAR2(32);
  lv2_return_value   VARCHAR2(32);
  lv2_class_name    VARCHAR2(32) := ecdp_objects.GetObjClassName(p_object_id);

BEGIN
  IF lv2_class_name = 'TEST_DEVICE' THEN
    lv2_inst_type := ec_eqpm_version.instrumentation_type(p_object_id,p_daytime,'<=');
    IF lv2_inst_type = '1' THEN
      lv2_return_value := 'TDEV_PT_0013_1';
    END IF;
    IF lv2_inst_type = '2' THEN
      lv2_return_value := 'TDEV_PT_0013_2';
    END IF;
    IF lv2_inst_type = '3' THEN
      lv2_return_value := 'TDEV_PT_0013_3';
    END IF;
    IF lv2_inst_type = '4' THEN
      lv2_return_value := 'TDEV_PT_0013_4';
    END IF;
  END IF;

  RETURN lv2_return_value;
END getSingleDataClassName;

---------------------------------------------------------------------------------------------------
-- Procedure      : createGraphDefParameters
-- Description    : instantiate records in ptst_graph_define based on last settings of the plot parameters.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PTST_GRAPH_DEFINE
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE createGraphDefParameters (p_object_id     VARCHAR2,
                                    p_test_no       NUMBER,
                                    p_created_by    VARCHAR2 DEFAULT NULL)
IS

  lv_created_by      VARCHAR2(32);
  lv2_parameter      VARCHAR2(32);
  ln_range_max       NUMBER;
  ln_range_min       NUMBER;
  ln_test_no         NUMBER;
  lv2_autorange_ind  VARCHAR2(1);
  lv2_incl_plot_ind VARCHAR2(1);

-- Get the last parameter setting for the object_id
CURSOR c_pgd(cp_object_id VARCHAR2) IS
  SELECT pgd.test_no, pgd.parameter, pgd.range_max, pgd.range_min, pgd.autorange_ind, pgd.inc_plot
  FROM   ptst_graph_define pgd
  WHERE  pgd.object_id =cp_object_id
  AND    pgd.test_no =  (SELECT max(x.test_no) FROM ptst_graph_define x
  where x.object_id = pgd.object_id
  AND x.test_no < p_test_no);



BEGIN


  IF p_created_by IS NULL THEN
    lv_created_by := User;
  ELSE
    lv_created_by := p_created_by;
  END IF;

  FOR curPgd IN c_pgd(p_object_id) LOOP
    ln_test_no        := curPgd.Test_No;
    lv2_parameter     := curPgd.Parameter;
    ln_range_max      := curPgd.range_max;
    ln_range_min      := curPgd.range_min;
    lv2_autorange_ind := curPgd.autorange_ind;
    lv2_incl_plot_ind := curPgd.Inc_Plot;

    -- Insert the last parameter settings for the object in ptst_graph_define for the current test_no
    INSERT INTO ptst_graph_define (object_id, test_no, parameter, range_max, range_min,autorange_ind,  inc_plot,  created_by, created_date)
    VALUES (p_object_id, p_test_no, lv2_parameter, ln_range_max, ln_range_min, lv2_autorange_ind,  lv2_incl_plot_ind, lv_created_by, EcDp_Date_Time.getCurrentSysdate);


  END LOOP;



END createGraphDefParameters;


---------------------------------------------------------------------------------------------------
-- Procedure      : removeGraphDefParameters
-- Description    : When an object is removed from ptst_object, it will also be deleted from ptst_graph_define
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PTST_OBJECT
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE removeGraphDefParameters (p_object_id     VARCHAR2,
                              p_test_no       NUMBER)
IS

  lv2_objectId      VARCHAR2(32);

-- Find object_id in ptst_graph_define with the same object id and test no
CURSOR c_object IS
  SELECT * FROM ptst_graph_define p_g_d
  WHERE p_g_d.test_no = p_test_no
  AND p_g_d.object_id = p_object_id;


BEGIN

  FOR curObject IN c_object LOOP
    DELETE FROM ptst_graph_define WHERE object_id = p_object_id AND test_no = p_test_no;
  END LOOP;

 END removeGraphDefParameters;


---------------------------------------------------------------------------------------------------
-- Function       : getDefaultTestDevice
-- Description    : Retrieves the default test device for PT.0013 screen
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
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
FUNCTION getDefaultTestDevice(p_object_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2
--</EC-DOC>
IS
  lv_test_device_id          VARCHAR2(32);
  lv_test_device_default     VARCHAR2(32);

BEGIN

  lv_test_device_default := NULL;

  select max(e.object_id) into lv_test_device_default
  from equipment e, eqpm_version ev, well_version wv
  where e.object_id = ev.object_id
  and e.class_name = 'TEST_DEVICE'
  and ev.default_fcty_test_device = 'Y'
  and ev.daytime <= p_daytime and nvl(ev.end_date, p_daytime + 1) > p_daytime
  and wv.daytime <= p_daytime and nvl(wv.end_date, p_daytime + 1) > p_daytime
  and wv.object_id = p_object_id
  and wv.op_fcty_class_1_id = ev.op_fcty_class_1_id;

  lv_test_device_id := NVL(ec_well_version.test_device_id(p_object_id, p_daytime, '<='), lv_test_device_default);

  RETURN lv_test_device_id;

END getDefaultTestDevice;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : deleteChildEvent
-- Description    : Delete child events. Child table is PTST_OBJECT, parent table is PTST_DEFINITION.
--
--
-- Preconditions  : All Child records related to the Test No will be deleted first.
-- Postconditions : Parent Test Record will be deleted finally.
--
-- Using tables   : ptst_object, ptst_result, ptst_graph_definition, ptst_event, eqpm_result, pwel_result and pflw_result
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE deleteChildEvent(p_test_no NUMBER)
--</EC-DOC>
IS

 CURSOR c_ptst_result IS
  SELECT result_no
  FROM ptst_result
  WHERE test_no=p_test_no;

  lv_sql VARCHAR2(2000);
  lv_result VARCHAR2(2000);
  lv_result_no NUMBER;

 BEGIN

  DELETE FROM ptst_event where test_no = p_test_no;
  DELETE FROM ptst_graph_define WHERE test_no = p_test_no;

  FOR cur_ptst_result IN c_ptst_result LOOP
    lv_result_no := cur_ptst_result.result_no;
    lv_sql := 'DELETE FROM eqpm_result where result_no = '||lv_result_no||'';
    lv_result := EcDp_Utilities.executeStatement(lv_sql);
    lv_sql := 'DELETE FROM pwel_result where result_no = '||lv_result_no||'';
    lv_result := EcDp_Utilities.executeStatement(lv_sql);
    lv_sql := 'DELETE FROM pflw_result where result_no = '||lv_result_no||'';
    lv_result := EcDp_Utilities.executeStatement(lv_sql);
  END LOOP;

  DELETE FROM ptst_result WHERE test_no = p_test_no;
  DELETE FROM ptst_object WHERE test_no = p_test_no;

  END deleteChildEvent;

--<EC-DOC>

---------------------------------------------------------------------------------------------------
-- Procedure      : countChildEvent
-- Description    : Count child events exist for the parent test. Child table is PTST_OBJECT, parent table is PTST_DEFINITION.
--
--
-- Preconditions  :
-- Postconditions : .
--
-- Using tables   : ptst_object and ptst_definition
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
FUNCTION countChildEvent(p_test_no NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

  CURSOR c_child_event  IS
    SELECT count(object_id) totalrecord
    FROM ptst_object po
    WHERE test_no = p_test_no;

 ln_child_record NUMBER;

BEGIN
   ln_child_record := 0;

  FOR cur_child_event IN c_child_event LOOP
    ln_child_record := cur_child_event.totalrecord ;
  END LOOP;

  return ln_child_record;

END countChildEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : stablePeriodPlotParameterCount
-- Description    : Check if the row count is less than 1, if its less than 1 raise an application error
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : ptst_graph_define
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE stablePeriodPlotParameterCount(p_test_no VARCHAR2)
--</EC-DOC>
IS

   ln_row_count NUMBER;

   CURSOR plot_parameter_count_cur IS
      select COUNT(parameter) as row_count
	           from ptst_graph_define
             where test_no = p_test_no
	           and inc_plot = 'Y';

BEGIN

   FOR my_cur in plot_parameter_count_cur LOOP
       ln_row_count := my_cur.row_count;
	 end loop;

   If ln_row_count < 1 then
      RAISE_APPLICATION_ERROR(-20642, 'No Plot Parameters Defined.');
   end if;

END stablePeriodPlotParameterCount;

END EcDp_Performance_Test;