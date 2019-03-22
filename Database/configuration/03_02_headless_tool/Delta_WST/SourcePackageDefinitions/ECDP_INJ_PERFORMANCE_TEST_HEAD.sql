CREATE OR REPLACE PACKAGE EcDp_Inj_Performance_Test IS
/****************************************************************
** Package        :  EcDp_Inj_Performance_Test, body part
**
** $Revision: 0.0 $
**
** Purpose        :  Provide data service layer for Injection well, flowline and well bore Performace Test
**
** Documentation  :  www.energy-components.com
**
** Created  : 26/09/2018 Gaurav Chaudhary
**
** Modification history:
**
** Date        Whom      Change description:
** ------      -----      ---------------------------------------------------------------------
** 26/09/2018  chaudgau  Initial
** 24.10.2018  bagdeswa  ECPD-60616: 8 New functions and 8 procedures added
                                      - [activeWBIsWellResult] added to indentify active WBI in well result
                                      - [showInjFlowlinesWithResult] added to show injection flowlines with result
                                      - [showInjWellsWithResult] added to show injection wells with result
                                      - [showFlowingInjWells] added to show injection flowing wells
                                      - [showNonFlowingInjWells] added to show injection non-flowing wells
                                      - [showPrimaryInjWells] added to show primary injection wells
                                      - [showInjTestDevicesWithResult] added to show injection test devices
                                      - [getInjTestDeviceIDFromResult] added to get ID of injection test device
                                      - [validateTestDate] added to validate the test date
                                      - [acceptTestResult] added to accept test result
                                      - [SetRecordStatusByStatus] added to set record status as per status
                                      - [rejectTestResult] added to reject test result
                                      - [addWellToInjectionTestResult] added to add wells to injection test result
                                      - [removeWbiTestResult] added to remove Well Bore Test result
                                      - [setWbiTestResult] added to set Well Bore Test Result
                                      - [aiSyncIwelResultFromIwel] added for sync up class trigger action
** 02.11.2018  mehtajig  ECPD-60615: 1 procedure and 3 functions added
                                      - [summarizeStablePeriod] added to summarize stable period for injection testing
                                      - [getResultDataClassName] added to get result data class name
                                      - [getSampleDataClassName] added to get sample data class name
                                      - [getTestObjectName] added to get test object name
****************************************************************/

PROCEDURE deleteChildEvent(p_test_no NUMBER);

FUNCTION showDefinedFlowlines(p_test_no NUMBER) RETURN VARCHAR2;

FUNCTION showDefinedWells(p_test_no NUMBER) RETURN VARCHAR2;

FUNCTION showDefinedTestDevice(p_test_no NUMBER) RETURN VARCHAR2;

FUNCTION countChildEvent(p_test_no NUMBER) RETURN NUMBER;

PROCEDURE processTestDeviceSampleRates(p_object_id VARCHAR2, p_from_daytime DATE, p_to_daytime DATE, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE setWbiTestDefine (p_object_id     VARCHAR2,
                            p_daytime       DATE,
                            p_test_no       NUMBER,
                            p_interval_type VARCHAR2 DEFAULT 'DIACS',
                            p_created_by    VARCHAR2 DEFAULT NULL);

PROCEDURE removeWbiTestDefine (p_object_id VARCHAR2, p_test_no NUMBER);

FUNCTION activeWBIsWellResult(p_object_id VARCHAR2, p_result_no NUMBER) RETURN VARCHAR2;

FUNCTION showInjFlowlinesWithResult(p_result_no NUMBER) RETURN VARCHAR2;

FUNCTION showInjWellsWithResult(p_result_no NUMBER) RETURN VARCHAR2;

FUNCTION showFlowingInjWells(p_result_no  NUMBER) RETURN VARCHAR2;

FUNCTION showNonFlowingInjWells(p_result_no  NUMBER) RETURN VARCHAR2;

FUNCTION showPrimaryInjWells(p_result_no  NUMBER) RETURN VARCHAR2;

FUNCTION showInjTestDevicesWithResult(p_result_no NUMBER) RETURN VARCHAR2;

FUNCTION getInjTestDeviceIDFromResult( p_result_no    NUMBER) RETURN VARCHAR2;

PROCEDURE validateTestDate(
            p_daytime        DATE
            );

PROCEDURE acceptTestResult(p_result_no NUMBER, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE SetRecordStatusByStatus(p_result_no NUMBER, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE rejectTestResult (p_result_no NUMBER, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE addWellToInjectionTestResult(p_object_type VARCHAR2, p_object_id VARCHAR2, p_result_no NUMBER, p_daytime DATE, p_user_id VARCHAR2);

PROCEDURE removeWbiTestResult (p_object_id     VARCHAR2, -- WELL OBJECT ID
                               p_result_no     NUMBER);

PROCEDURE setWbiTestResult (
              p_object_id     VARCHAR2, -- WELL OBJECT ID
              p_daytime       DATE,     -- DAYTIME
              p_result_no       NUMBER,
              p_interval_type VARCHAR2 DEFAULT 'DIACS',
              p_created_by    VARCHAR2 DEFAULT NULL);

PROCEDURE summarizeStablePeriod(p_result_no NUMBER, p_last_updated_by    VARCHAR2 DEFAULT NULL);

FUNCTION getSampleDataClassName(p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;

FUNCTION getResultDataClassName(p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;

FUNCTION getTestObjectName(p_object_id VARCHAR2) RETURN VARCHAR2;

PROCEDURE aiSyncIwelResultFromIwel ( p_result_no  NUMBER, p_well_id VARCHAR2, p_user VARCHAR2 DEFAULT NULL);

END EcDp_Inj_Performance_Test;