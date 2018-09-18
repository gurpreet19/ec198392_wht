CREATE OR REPLACE PACKAGE BODY Ue_TestDevice IS

/******************************************************************************
** Package        :  Ue_TestDevice, body part
**
** $Revision: 1.7 $
**
** Purpose        :  Customer specific implementation for test device functionality
**
** Documentation  :  www.energy-components.com
**
** Created  : 27.11.2007 Arief Zaki
**
** Modification history:
**
** Version  Date       Whom      Change description:
** -------  ------     -----     -------------------------------------------
** EC9.4    27.11.2007 zakiiari  ECPD-5561: Initial version
** EC9.4    11.01.2008 zakiiari  ECPD-7226: Added new UE function; findGrsLiqRate,findGrsGasRate,findGrsGasLiftRate,findGrsWaterRate
** EC9.4    07.05.2008 leongsei  ECPD-8428: Single Production Test Result - must support calculation of mass
**          20.06.2008 zakiiari  ECPD-8564: Added agaStaticPress and agaDiffPress ue functions
**          18.09.2008 oonnnng   ECPD-9394: Added findDiluentRate and findWellWetGasRate functions.
**			    05.02.2009 lauuufus  ECPD-10863 Added findNetRate function.
** 	    18.09.2009 madondin  ECPD12693: Added USER_EXIT for findStdNetRate,findGrsLiqVolume,findGrsGasVolume,findGrsGasLiftVolume,findGrsWaterVolume,getMeterFactor
**				    	    findGOR,findGLR,findCGR,findWOR,findWGR,findBswVol function.
** 17.07.14  dhavaalo ECPD-28080: Replace eqpm_result with TEST_DEVICE_RESULT
** 20.06.17  dhavaalo ECPD-28080: Added findRefShrinkageFactor
********************************************************************/

FUNCTION calcShrinkageVolume(p_result_no NUMBER, p_net_rate NUMBER, p_phase VARCHAR2, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
IS
  -- insert cursor here

  -- declare variables here

BEGIN
  -- insert code here
  RETURN null;
END calcShrinkageVolume;


FUNCTION findGrsLiqRate(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
IS
BEGIN
  RETURN NULL;
END findGrsLiqRate;


FUNCTION findGrsGasRate(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
IS
BEGIN
  RETURN NULL;
END findGrsGasRate;

FUNCTION findGrsGasLiftRate(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
IS
BEGIN
  RETURN NULL;
END findGrsGasLiftRate;

FUNCTION findGrsWaterRate(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER
IS
BEGIN
  RETURN NULL;
END findGrsWaterRate;

PROCEDURE calcSingleWellTestResult(p_well_object_id VARCHAR2, p_daytime DATE, p_result_no NUMBER, p_user VARCHAR2, p_code_exist OUT VARCHAR2)
IS
BEGIN
  p_code_exist := 'N';
END calcSingleWellTestResult;

FUNCTION agaStaticPress(p_result_no test_device_result.result_no%TYPE,
                        p_object_id VARCHAR2,
                        p_phase VARCHAR2)
RETURN NUMBER
IS
BEGIN
  RETURN NULL;
END agaStaticPress;

FUNCTION agaDiffPress(p_result_no test_device_result.result_no%TYPE,
                      p_object_id VARCHAR2,
                      p_phase VARCHAR2)
RETURN NUMBER
IS
BEGIN
  RETURN NULL;
END agaDiffPress;

FUNCTION findDiluentRate(p_result_no test_device_result.result_no%TYPE,
                      p_object_id VARCHAR2,
                      p_daytime DATE)
RETURN NUMBER
IS
BEGIN
  RETURN NULL;
END findDiluentRate;

FUNCTION findWellWetGasRate(p_result_no test_device_result.result_no%TYPE,
                      p_object_id VARCHAR2,
                      p_daytime DATE)
RETURN NUMBER
IS
BEGIN
  RETURN NULL;
END findWellWetGasRate;

FUNCTION findNetRate(p_result_no test_device_result.result_no%TYPE,
						         p_phase VARCHAR2,
						         p_object_id VARCHAR2,
						         p_daytime DATE)
RETURN NUMBER
IS
BEGIN
  RETURN NULL;
END findNetRate;




FUNCTION findStdNetRate(p_result_no test_device_result.result_no%TYPE,
						         p_phase VARCHAR2,
						         p_object_id VARCHAR2,
						         p_daytime DATE)
RETURN NUMBER
IS
BEGIN
  RETURN NULL;
END findStdNetRate;


FUNCTION findGrsLiqVolume(p_result_no test_device_result.result_no%TYPE,
						         p_object_id VARCHAR2,
						         p_daytime DATE)
RETURN NUMBER
IS
BEGIN
  RETURN NULL;
END findGrsLiqVolume;

FUNCTION findGrsGasVolume(p_result_no test_device_result.result_no%TYPE,
						         p_object_id VARCHAR2,
						         p_daytime DATE)
RETURN NUMBER
IS
BEGIN
  RETURN NULL;
END findGrsGasVolume;


FUNCTION findGrsGasLiftVolume(p_result_no test_device_result.result_no%TYPE,
						         p_object_id VARCHAR2,
						         p_daytime DATE)
RETURN NUMBER
IS
BEGIN
  RETURN NULL;
END findGrsGasLiftVolume;


FUNCTION findGrsWaterVolume(p_result_no test_device_result.result_no%TYPE,
						         p_object_id VARCHAR2,
						         p_daytime DATE)
RETURN NUMBER
IS
BEGIN
  RETURN NULL;
END findGrsWaterVolume;


FUNCTION getMeterFactor(p_result_no test_device_result.result_no%TYPE,
						         p_object_id VARCHAR2,
						         p_daytime DATE)
RETURN NUMBER
IS
BEGIN
  RETURN NULL;
END getMeterFactor;


FUNCTION findGOR(p_result_no test_device_result.result_no%TYPE,
						         p_object_id VARCHAR2,
						         p_daytime DATE)
RETURN NUMBER
IS
BEGIN
  RETURN NULL;
END findGOR;

FUNCTION findGLR(p_result_no test_device_result.result_no%TYPE,
						         p_object_id VARCHAR2,
						         p_daytime DATE)
RETURN NUMBER
IS
BEGIN
  RETURN NULL;
END findGLR;

FUNCTION findCGR(p_result_no test_device_result.result_no%TYPE,
						         p_object_id VARCHAR2,
						         p_daytime DATE)
RETURN NUMBER
IS
BEGIN
  RETURN NULL;
END findCGR;

FUNCTION findWOR(p_result_no test_device_result.result_no%TYPE,
						         p_object_id VARCHAR2,
						         p_daytime DATE)
RETURN NUMBER
IS
BEGIN
  RETURN NULL;
END findWOR;

FUNCTION findWGR(p_result_no test_device_result.result_no%TYPE,
						         p_object_id VARCHAR2,
						         p_daytime DATE)
RETURN NUMBER
IS
BEGIN
  RETURN NULL;
END findWGR;

FUNCTION findBswVol(p_result_no test_device_result.result_no%TYPE,
						         p_object_id VARCHAR2,
						         p_daytime DATE)
RETURN NUMBER
IS
BEGIN
  RETURN NULL;
END findBswVol;

FUNCTION findRefShrinkageFactor(p_result_no NUMBER,
						         p_phase VARCHAR2,
						         p_object_id VARCHAR2,
						         p_daytime DATE)
RETURN NUMBER
IS
BEGIN
  RETURN NULL;
END findRefShrinkageFactor;

END Ue_TestDevice;