CREATE OR REPLACE PACKAGE EcDp_Performance_Test IS
/****************************************************************
** Package        :  EcDp_Performance_Test, head part
**
** $Revision: 1.42 $
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
** 21-01-2013  musthram  ECPD-22676: Added new function countChildEvent and deleteChildEvent
** 06.02.2014  abdulmaw  ECPD-19674: Create new function getPrevWellTestResult to pick up X number of previous well tests for a well
** 04.08.2014  dhavaalo  ECPD-28080: auiSyncEqpmResult renamed to auiSyncTDEVResult and auidelEqpmResult renamed to auidelTDEVResult
** 13.06.2016  dhavaalo  ECPD-33387: New function-[getAttribute] added to get class attribute in drop down on Stable Period And Summarise screen under plot parameter tab for attribute plot trace..
** 09.08.2016  jainngou  ECPD-36875: New function-[ActiveWBIsWellResult] added that will create a comma separated-list of names of the active well bore intervals (WBI) in a specific test result.
** 25.08.2016  jainngou  ECPD-36092: New procedure-[calcWellResultRatio] added to calculate well result ratio and meter factor for Gas, Wat and Hcliq.
** 05.03.2018  khatrnit  ECPD-50409: Renamed function showDefinedTestDevices to showDefinedTestDevice and also changing return of OBJECT_ID instead of OBJECT_NAME
** 18.04.2018  khatrnit  ECPD-52664: New procedure-[addWellToProductionTestResult] added to insert well while inserting production test result.
** 10.09.2018  chaudgau  ECPD-52897: New procedure setFlwlWellTestDefine and removeFlwlWellTestDefine has been added to initiate or remove flowline test based on
**                                    flowline well connection
*************************************************************************************************/

--

FUNCTION showDefinedTestDevice(p_test_no NUMBER) RETURN VARCHAR2;

FUNCTION showDefinedFlowlines(p_test_no NUMBER) RETURN VARCHAR2;

FUNCTION showDefinedWells(p_test_no NUMBER) RETURN VARCHAR2;

FUNCTION CalcDurationOfStablePeriod(p_result_no NUMBER) RETURN NUMBER;

FUNCTION getTestDeviceIDFromResult( p_result_no    NUMBER) RETURN VARCHAR2;

FUNCTION showTestDevicesWithResult(p_result_no NUMBER) RETURN VARCHAR2;

FUNCTION showFlowlinesWithResult(p_result_no NUMBER) RETURN VARCHAR2;

FUNCTION showWellsWithResult(p_result_no NUMBER) RETURN VARCHAR2;

FUNCTION getSampleDataClassName(p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;
--

FUNCTION getResultDataClassName(p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;

FUNCTION getLastValidWellResult(p_object_id VARCHAR2, p_daytime DATE) RETURN pwel_result%ROWTYPE;

FUNCTION showFlowingWells(p_result_no  NUMBER) RETURN VARCHAR2;

FUNCTION showNonFlowingWells(p_result_no  NUMBER) RETURN VARCHAR2;

FUNCTION showPrimaryWells(p_result_no  NUMBER) RETURN VARCHAR2;

PROCEDURE processTestDeviceSampleRates(p_object_id VARCHAR2, p_from_daytime DATE, p_to_daytime DATE, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE SetRecordStatusByStatus(p_result_no NUMBER, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE auiUpdateRecordStatus(p_result_no NUMBER, p_new_record_status VARCHAR2, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE summarizeStablePeriod(p_result_no NUMBER, p_last_updated_by    VARCHAR2 DEFAULT NULL);

FUNCTION getLastValidWellResultNo(
            p_object_id    VARCHAR2,
            p_daytime      DATE)
RETURN NUMBER;

FUNCTION getEstimatedOilProduction(
            p_target_result_no   NUMBER,
            p_comb_result_no     NUMBER)
RETURN NUMBER;

FUNCTION getEstimatedCondProduction(
            p_target_result_no   NUMBER,
            p_comb_result_no     NUMBER)
RETURN NUMBER;

FUNCTION getEstimatedGasProduction(
            p_target_result_no   NUMBER,
            p_comb_result_no     NUMBER)
RETURN NUMBER;

FUNCTION getEstimatedWaterProduction(
            p_target_result_no   NUMBER,
            p_comb_result_no     NUMBER)
RETURN NUMBER;

FUNCTION getOilRateTargetWellResult(
            p_target_result_no   NUMBER,
            p_comb_result_no     NUMBER)
RETURN NUMBER;

FUNCTION getCondRateTargetWellResult(
            p_target_result_no   NUMBER,
            p_comb_result_no     NUMBER)
RETURN NUMBER;

FUNCTION getGasRateTargetWellResult(
            p_target_result_no   NUMBER,
            p_comb_result_no     NUMBER)
RETURN NUMBER;

FUNCTION getWatRateTargetWellResult(
            p_target_result_no   NUMBER,
            p_comb_result_no     NUMBER)
RETURN NUMBER;

FUNCTION getOilStdRateDay(
            p_result_no    NUMBER,
            p_object_id    VARCHAR2,
            p_daytime      DATE)
RETURN NUMBER;

FUNCTION getCondStdRateDay(
            p_result_no    NUMBER,
            p_object_id    VARCHAR2,
            p_daytime      DATE)
RETURN NUMBER;

FUNCTION getGasStdRateDay(
            p_result_no    NUMBER,
            p_object_id    VARCHAR2,
            p_daytime      DATE)
RETURN NUMBER;

FUNCTION getWatStdRateDay(
            p_result_no    NUMBER,
            p_object_id    VARCHAR2,
            p_daytime      DATE)
RETURN NUMBER;

FUNCTION getPrimaryTargetWellID(
            p_target_result_no   NUMBER,
            p_comb_result_no     NUMBER)
RETURN VARCHAR2;

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

FUNCTION getSumEstDILRate(
            p_result_no    NUMBER
)
RETURN NUMBER;



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
--

PROCEDURE auiSetProductionDay(
            p_object_id   VARCHAR2,
            p_daytime     DATE,
            p_result_no   NUMBER,
            p_user VARCHAR2 DEFAULT NULL);

PROCEDURE auiSyncPtstResult ( p_result_no  NUMBER, p_attr_changed VARCHAR2, p_daytime DATE, p_valid_from_date DATE,
                              p_status VARCHAR2,   p_use_calc VARCHAR2, p_end_date DATE, p_duration NUMBER,
                              p_user VARCHAR2 DEFAULT NULL, p_well_test_reason VARCHAR2
                            );

PROCEDURE auiSyncTDEVResult (p_test_device VARCHAR2,p_result_no  NUMBER,p_daytime DATE, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE auidelTDEVResult (p_test_device VARCHAR2,p_result_no  NUMBER);

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

--

FUNCTION getNextValidWellResultNo(p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;

--

FUNCTION getTrendSegmentMinDate(p_object_id VARCHAR2, p_daytime DATE)
RETURN DATE;

--

FUNCTION getTrendSegmentMaxDate(p_object_id VARCHAR2, p_daytime DATE)
RETURN DATE;

--

FUNCTION findOilConstantC2(p_object_id VARCHAR2, p_daytime DATE, p_trend_method VARCHAR2 DEFAULT 'EXP')
RETURN NUMBER;

--

FUNCTION findGasConstantC2(p_object_id VARCHAR2, p_daytime DATE, p_trend_method VARCHAR2 DEFAULT 'EXP')
RETURN NUMBER;

--

FUNCTION findCondConstantC2(p_object_id VARCHAR2, p_daytime DATE, p_trend_method VARCHAR2 DEFAULT 'EXP')
RETURN NUMBER;

--

FUNCTION findWatConstantC2(p_object_id VARCHAR2, p_daytime DATE, p_trend_method VARCHAR2 DEFAULT 'EXP')
RETURN NUMBER;

--

FUNCTION findLiqConstantC2(p_object_id VARCHAR2, p_daytime DATE, p_trend_method VARCHAR2 DEFAULT 'EXP')
RETURN NUMBER;


--

FUNCTION getTestObjectName(p_object_id VARCHAR2)
RETURN VARCHAR2;


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
PROCEDURE setFlwlWellTestDefine (p_object_id VARCHAR2 -- WELL OBJECT ID
                            ,p_test_no       NUMBER
                            ,p_created_by    VARCHAR2 DEFAULT NULL);

--
PROCEDURE removeFlwlWellTestDefine
(
    p_object_id VARCHAR2 -- WELL OBJECT_ID
   ,p_test_no   NUMBER
);
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

PROCEDURE uncheckMultiselect (p_result_no NUMBER, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE validateTestDate(
            p_daytime        DATE
            );

PROCEDURE createGraphDefParameters(p_object_id VARCHAR2, p_test_no NUMBER, p_created_by VARCHAR2 DEFAULT NULL);

PROCEDURE removeGraphDefParameters(p_object_id VARCHAR2, p_test_no  NUMBER);

FUNCTION getDefaultTestDevice(p_object_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2;

PROCEDURE deleteChildEvent(p_test_no NUMBER);

FUNCTION countChildEvent(p_test_no NUMBER)
RETURN NUMBER;

FUNCTION getPrevWellTestResult(p_object_id VARCHAR2,
                               p_daytime DATE,
                               p_n_tests NUMBER DEFAULT '1',
                               p_status VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION getAttribute(p_STATIC_PRESENTATION_SYNTAX VARCHAR2, p_label VARCHAR2)
RETURN VARCHAR2;

FUNCTION activeWBIsWellResult(p_object_id VARCHAR2, p_result_no NUMBER)
RETURN VARCHAR2;

PROCEDURE calcWellResultRatio(p_object_id IN VARCHAR2, p_result_no IN NUMBER);

PROCEDURE addWellToProductionTestResult(p_object_type VARCHAR2, p_object_id VARCHAR2, p_result_no NUMBER, p_daytime DATE, p_user_id VARCHAR2);

END EcDp_Performance_Test;