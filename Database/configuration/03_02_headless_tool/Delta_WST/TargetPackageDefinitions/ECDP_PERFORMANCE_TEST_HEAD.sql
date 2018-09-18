CREATE OR REPLACE PACKAGE EcDp_Performance_Test IS
/****************************************************************
** Package        :  EcDp_Performance_Test, head part
**
** $Revision: 1.39.2.3 $
**
** Purpose        :  Provide service layer for Performace Test
**
** Documentation  :  www.energy-components.com
**
** Created  : 07/04/2005 Tor-Erik Hauge
**
** Modification history:
**
** Date        Whom      Change description:
** ----------  --------  ---------------------------------------------------------------------
** 07/04/2005  Haugetor  Initial
** 08/04/2005  DN        Added show-functions.
** 22/04/2005  SHN       Added function showFlowingWells, showNonFlowingWells, showPrimaryWells
** 28/04/2205  SHN       Tracker 2058. Added several new functions used by PT 0011
** 29/04/2005  Darren    Tracker 2052 Added procedure biValidateTestOnInsert
** 02/05/2005  Darren    Remove procedure biValidateTestOnInsert
** 09/09/2005  Ron       - Added 8 new functions
**                       - getNextValidWellResult
**                       - getNextValidWellResultNo
**                       - getTrendSegmentMinDate
**                       - getTrendSegmentMaxDate
**                       - findOilConstantC2
**                       - findGasConstantC2
**                       - findCondConstantC2
**                       - findWatConstantC2
** 04/01/2006  Lau       Tracker 3270 Added procedure auiSetProductionDay
** 26/04/2006  zakiiari  TI#3384: Added procedure setWbiTestDefine, setWbiTestResult, removeWbiTestDefine, removeWbiTestResult
**                                Added function getTestObjectName
** 25/09/2006  ottermag  TI#3300: Added procedures acceptTestResult and rejectTestResult
** 30/05/2007  seongkok  ECPD-4819: Added procedures auiSyncPtstResult, auiSyncPtstResultTdev, auiSyncPwelResult, aiSyncPwelResultFromTdev, aiSyncPwelResultFromPwel, delPwelResultData and delPtstResultData
** 28/06/2007  Lau       ECPD-5948 Added procedures auisetPwelResult, auiSyncEqpmResult,auidelEqpmResult
** 08/10/2007  kaurrnar  ECPD-6342: Added uncheckMultiselect procedure
** 26/11/2007  Lau       ECPD-5561 and 6626 : Added acceptTestResultNoAlloc
** 03/12/2007  Lau       ECPD-5561 Added getSingleDataClassName
** 10/03/2008  eizwanik  ECPD-7056: Modified many functions to include created_by/last_updated_by during inserts/updates
** 17/03/2008  rajarsar  ECPD-6167: Modified setWbiTestDefine,removeWbiTestDefine and added createGraphDefParameters and removeGraphDefParameters
** 18/08/2008  oonnnng   ECPD-11871: Added getDefaultTestDevice() function.
** 24/09/2009  oonnnng   ECPD-12718: Add acceptSingleTestResult(), acceptSingleTestResultNoAlloc() , and rejectSingleTestResult() functions.
** 21-12-2011  madondin  ECPD-19446: Added new function findLiqConstantC2
** 16-10-2012  genasdev  ECPD-17464: Added parameter well_test_reason to auisyncpwelresult, auisyncptstresult and aiSyncPwelResultFromPwel.
** 21-01-2013  musthram  ECPD-23154: Added new function countChildEvent and deleteChildEvent
** 30-04-2013  makkkkam	 ECPD-24066: Added procedure stablePeriodPlotParameterCount
*************************************************************************************************/

--

FUNCTION showDefinedTestDevices(p_test_no NUMBER) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (showDefinedTestDevices, WNDS, WNPS, RNPS);

FUNCTION showDefinedFlowlines(p_test_no NUMBER) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (showDefinedFlowlines, WNDS, WNPS, RNPS);

FUNCTION showDefinedWells(p_test_no NUMBER) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (showDefinedWells, WNDS, WNPS, RNPS);

FUNCTION CalcDurationOfStablePeriod(p_result_no NUMBER) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (CalcDurationOfStablePeriod, WNDS, WNPS, RNPS);

FUNCTION getTestDeviceIDFromResult( p_result_no    NUMBER) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getTestDeviceIDFromResult, WNDS, WNPS, RNPS);

FUNCTION showTestDevicesWithResult(p_result_no NUMBER) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (showTestDevicesWithResult, WNDS, WNPS, RNPS);

FUNCTION showFlowlinesWithResult(p_result_no NUMBER) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (showDefinedWells, WNDS, WNPS, RNPS);

FUNCTION showWellsWithResult(p_result_no NUMBER) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (showWellsWithResult, WNDS, WNPS, RNPS);

FUNCTION getSampleDataClassName(p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;
--PRAGMA RESTRICT_REFERENCES (getSampleDataClassName, WNDS, WNPS, RNPS);

FUNCTION getResultDataClassName(p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getResultDataClassName, WNDS, WNPS, RNPS);

FUNCTION getLastValidWellResult(p_object_id VARCHAR2, p_daytime DATE) RETURN pwel_result%ROWTYPE;
PRAGMA RESTRICT_REFERENCES (getLastValidWellResult, WNDS, WNPS, RNPS);

FUNCTION showFlowingWells(p_result_no  NUMBER) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (showFlowingWells, WNDS, WNPS, RNPS);

FUNCTION showNonFlowingWells(p_result_no  NUMBER) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (showNonFlowingWells, WNDS, WNPS, RNPS);

FUNCTION showPrimaryWells(p_result_no  NUMBER) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (showPrimaryWells, WNDS, WNPS, RNPS);

PROCEDURE processTestDeviceSampleRates(p_object_id VARCHAR2, p_from_daytime DATE, p_to_daytime DATE, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE SetRecordStatusByStatus(p_result_no NUMBER, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE auiUpdateRecordStatus(p_result_no NUMBER, p_new_record_status VARCHAR2, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE summarizeStablePeriod(p_result_no NUMBER, p_last_updated_by    VARCHAR2 DEFAULT NULL);

FUNCTION getLastValidWellResultNo(
            p_object_id    VARCHAR2,
            p_daytime      DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getLastValidWellResultNo, WNDS, WNPS, RNPS);

FUNCTION getEstimatedOilProduction(
            p_target_result_no   NUMBER,
            p_comb_result_no     NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getEstimatedOilProduction, WNDS, WNPS, RNPS);

FUNCTION getEstimatedCondProduction(
            p_target_result_no   NUMBER,
            p_comb_result_no     NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getEstimatedCondProduction, WNDS, WNPS, RNPS);

FUNCTION getEstimatedGasProduction(
            p_target_result_no   NUMBER,
            p_comb_result_no     NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getEstimatedGasProduction, WNDS, WNPS, RNPS);

FUNCTION getEstimatedWaterProduction(
            p_target_result_no   NUMBER,
            p_comb_result_no     NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getEstimatedWaterProduction, WNDS, WNPS, RNPS);

FUNCTION getOilRateTargetWellResult(
            p_target_result_no   NUMBER,
            p_comb_result_no     NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getOilRateTargetWellResult, WNDS, WNPS, RNPS);

FUNCTION getCondRateTargetWellResult(
            p_target_result_no   NUMBER,
            p_comb_result_no     NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getCondRateTargetWellResult, WNDS, WNPS, RNPS);

FUNCTION getGasRateTargetWellResult(
            p_target_result_no   NUMBER,
            p_comb_result_no     NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGasRateTargetWellResult, WNDS, WNPS, RNPS);

FUNCTION getWatRateTargetWellResult(
            p_target_result_no   NUMBER,
            p_comb_result_no     NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getWatRateTargetWellResult, WNDS, WNPS, RNPS);

FUNCTION getOilStdRateDay(
            p_result_no    NUMBER,
            p_object_id    VARCHAR2,
            p_daytime      DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getOilStdRateDay, WNDS, WNPS, RNPS);

FUNCTION getCondStdRateDay(
            p_result_no    NUMBER,
            p_object_id    VARCHAR2,
            p_daytime      DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getCondStdRateDay, WNDS, WNPS, RNPS);

FUNCTION getGasStdRateDay(
            p_result_no    NUMBER,
            p_object_id    VARCHAR2,
            p_daytime      DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGasStdRateDay, WNDS, WNPS, RNPS);

FUNCTION getWatStdRateDay(
            p_result_no    NUMBER,
            p_object_id    VARCHAR2,
            p_daytime      DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getWatStdRateDay, WNDS, WNPS, RNPS);

FUNCTION getPrimaryTargetWellID(
            p_target_result_no   NUMBER,
            p_comb_result_no     NUMBER)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getPrimaryTargetWellID, WNDS, WNPS, RNPS);

PROCEDURE saveWellTargetResult(
               p_target_result_no   NUMBER,
               p_comb_result_no     NUMBER,
               p_oil_rate           NUMBER,
               p_con_rate           NUMBER,
               p_gas_rate           NUMBER,
               p_water_rate         NUMBER,
               p_user         VARCHAR2 DEFAULT NULL);

FUNCTION getSumEstGLRate(
            p_result_no    NUMBER
)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getSumEstGLRate, WNDS, WNPS, RNPS);

FUNCTION getSumEstDILRate(
            p_result_no    NUMBER
)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getSumEstDILRate, WNDS, WNPS, RNPS);



PROCEDURE PreProcessTestResult(p_result_no NUMBER
                               ,p_last_updated_by    VARCHAR2 DEFAULT NULL
                               ,p_last_updated_date  DATE     DEFAULT NULL
                               ) ;


FUNCTION getMeterCode(
            p_object_id      VARCHAR2,
            p_daytime        DATE,
            p_phase      VARCHAR2
            )
RETURN VARCHAR2;
--PRAGMA RESTRICT_REFERENCES (getMeterCode, WNDS, WNPS, RNPS);

PROCEDURE auiSetProductionDay(
            p_object_id   VARCHAR2,
            p_daytime     DATE,
            p_result_no   NUMBER,
            p_user VARCHAR2 DEFAULT NULL);

PROCEDURE auiSyncPtstResult ( p_result_no  NUMBER, p_attr_changed VARCHAR2, p_daytime DATE, p_valid_from_date DATE,
                              p_status VARCHAR2,   p_use_calc VARCHAR2, p_end_date DATE, p_duration NUMBER,
                              p_user VARCHAR2 DEFAULT NULL, p_well_test_reason VARCHAR2
                            );

PROCEDURE auiSyncEqpmResult (p_test_device VARCHAR2,p_result_no  NUMBER,p_daytime DATE, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE auidelEqpmResult (p_test_device VARCHAR2,p_result_no  NUMBER);

PROCEDURE auiSyncPtstResultTdev ( p_result_no  NUMBER, p_test_device VARCHAR2, p_daytime DATE, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE auiSyncPwelResult ( p_result_no  NUMBER, p_attr_changed VARCHAR2, p_daytime DATE, p_valid_from_date DATE,
                              p_status VARCHAR2,   p_use_calc VARCHAR2, p_end_date DATE, p_duration NUMBER,
                              p_user VARCHAR2 DEFAULT NULL, p_well_test_reason VARCHAR2
                            );

PROCEDURE aiSyncPwelResultFromTdev ( p_result_no  NUMBER, p_test_dev_id VARCHAR2, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE aiSyncPwelResultFromPwel ( p_result_no  NUMBER, p_well_id VARCHAR2, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE auisetPwelResult( p_result_no  NUMBER, p_user VARCHAR2 DEFAULT USER);

PROCEDURE delPwelResultData(p_result_no NUMBER);

PROCEDURE delPtstResultData(p_result_no NUMBER);

FUNCTION getNextValidWellResult(p_object_id VARCHAR2, p_daytime DATE)
RETURN pwel_result%ROWTYPE;
PRAGMA RESTRICT_REFERENCES (getNextValidWellResult, WNDS, WNPS, RNPS);

--

FUNCTION getNextValidWellResultNo(p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getNextValidWellResultNo, WNDS, WNPS, RNPS);

--

FUNCTION getTrendSegmentMinDate(p_object_id VARCHAR2, p_daytime DATE)
RETURN DATE;
PRAGMA RESTRICT_REFERENCES (getTrendSegmentMinDate, WNDS, WNPS, RNPS);

--

FUNCTION getTrendSegmentMaxDate(p_object_id VARCHAR2, p_daytime DATE)
RETURN DATE;
PRAGMA RESTRICT_REFERENCES (getTrendSegmentMaxDate, WNDS, WNPS, RNPS);

--

FUNCTION findOilConstantC2(p_object_id VARCHAR2, p_daytime DATE, p_trend_method VARCHAR2 DEFAULT 'EXP')
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findOilConstantC2, WNDS, WNPS, RNPS);

--

FUNCTION findGasConstantC2(p_object_id VARCHAR2, p_daytime DATE, p_trend_method VARCHAR2 DEFAULT 'EXP')
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findGasConstantC2, WNDS, WNPS, RNPS);

--

FUNCTION findCondConstantC2(p_object_id VARCHAR2, p_daytime DATE, p_trend_method VARCHAR2 DEFAULT 'EXP')
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findCondConstantC2, WNDS, WNPS, RNPS);

--

FUNCTION findWatConstantC2(p_object_id VARCHAR2, p_daytime DATE, p_trend_method VARCHAR2 DEFAULT 'EXP')
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findWatConstantC2, WNDS, WNPS, RNPS);

--

FUNCTION findLiqConstantC2(p_object_id VARCHAR2, p_daytime DATE, p_trend_method VARCHAR2 DEFAULT 'EXP')
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findLiqConstantC2, WNDS, WNPS, RNPS);


--

FUNCTION getTestObjectName(p_object_id VARCHAR2)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getTestObjectName, WNDS, WNPS, RNPS);


--

PROCEDURE setWbiTestDefine (
              p_object_id     VARCHAR2, -- WELL OBJECT ID
              p_daytime       DATE,     -- DAYTIME
              p_test_no       NUMBER,
              p_interval_type VARCHAR2 DEFAULT 'DIACS',
              p_created_by    VARCHAR2 DEFAULT NULL);

--

PROCEDURE setWbiTestResult (
              p_object_id     VARCHAR2, -- WELL OBJECT ID
              p_daytime       DATE,     -- DAYTIME
              p_result_no       NUMBER,
              p_interval_type VARCHAR2 DEFAULT 'DIACS',
              p_created_by    VARCHAR2 DEFAULT NULL);

--

PROCEDURE removeWbiTestDefine (p_object_id     VARCHAR2, -- WELL OBJECT ID
                               p_test_no       NUMBER);

--

PROCEDURE removeWbiTestResult (p_object_id     VARCHAR2, -- WELL OBJECT ID
                               p_result_no     NUMBER);

PROCEDURE acceptTestResult (p_result_no NUMBER,  p_user VARCHAR2 DEFAULT NULL);

PROCEDURE acceptTestResultNoAlloc (p_result_no NUMBER, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE rejectTestResult (p_result_no NUMBER, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE acceptSingleTestResult (p_result_no NUMBER,  p_user VARCHAR2 DEFAULT NULL);

PROCEDURE acceptSingleTestResultNoAlloc (p_result_no NUMBER, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE rejectSingleTestResult (p_result_no NUMBER, p_user VARCHAR2 DEFAULT NULL);

FUNCTION getSingleDataClassName(p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getSingleDataClassName, WNDS, WNPS, RNPS);

PROCEDURE uncheckMultiselect (p_result_no NUMBER, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE validateTestDate(
            p_daytime        DATE
            );

PROCEDURE createGraphDefParameters(p_object_id VARCHAR2, p_test_no NUMBER, p_created_by VARCHAR2 DEFAULT NULL);

PROCEDURE removeGraphDefParameters(p_object_id VARCHAR2, p_test_no  NUMBER);

FUNCTION getDefaultTestDevice(p_object_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getDefaultTestDevice, WNDS, WNPS, RNPS);

PROCEDURE deleteChildEvent(p_test_no NUMBER);

FUNCTION countChildEvent(p_test_no NUMBER)
RETURN NUMBER;

PROCEDURE stablePeriodPlotParameterCount(p_test_no VARCHAR2);

END EcDp_Performance_Test;