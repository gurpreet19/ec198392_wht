CREATE OR REPLACE PACKAGE EcBp_TestDevice IS

/****************************************************************
** Package        :  EcBp_TestDevice
**
** $Revision: 1.17.12.2 $
**
** Purpose        :  This procedure will call functions that will
**                   calculate on -the-fly well test results depending
**                   on configuration on Test_Device object.It also have
**                   a procedure to update PWEL_RESULT table when
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
** 03.12.2007  zakiiari ECPD-7039: Added calcSingleWellTestResult, findGrsWaterVolume
** 14.01.2008  rajarsar ECPD-7226: Added findTdevRefMeterRun, findTdevRefOrificePlate,findWellRefSpecGravity and getPwelResultDate
** 16.01.2008  zakiiari ECPD-7226: Added lookupGasLifrHrRate, calcTotalizerVolume, findInvertedShrinkageFactor.
**                                 Supported additional method in some of the functions. i.e. USER_EXIT, AGA and TOTALIZER
**                                 Renamed/changed functionality of findTdevRefMeterRun and findTdevRefOrificePlate
** 16.05.2008  sharawan ECPD-8165: Update the code for updateRateSource to not check for specific attributes,
                                   but rather just set RATE_SOURCE to MANUAL every time there is a save on DV_PWEL_RESULT.
** 20.06.2008  Toha     ECPD-8361  Added findWellRefGasLiftSpecGravity, agaStaticPress, agaDiffPress
** 20.06.2008  Toha     ECPD-8512  Removed few parameters in function agaStaticPress and agaDiffPress to be the same as 9_2-PATCH ver1.7.2.2.2.2
**                                 eg: p_press_read NUMBER DEFAULT NULL, p_scale NUMBER DEFAULT NULL, p_rating NUMBER DEFAULT NULL.
** 20.06.2008  Toha     ECPD-8564  Published getAttributeName as public function so that ue_testdevice could use it
** 08.09.2008  oonnnng  ECPD-7830: Added getMeterFactor, and updEQPMResultValues functions.
** 18.09.2008  oonnnng  ECPD-9394: Added findDiluentRate and findWellWetGasRate functions.
** 20.01.2009 lauuufus  ECPD-10845 Added new function calcWaterCut
** 23.02.2009 lauuufus  ECPD-10124 Added new function findRefShrinkageFactor and findWellRefShrinkageFactor
** 06.03.2009 amirrasn  ECPD-10740 Added new function findCalcDilRate
** 03.02.2010 sharawan  ECPD-12821 Remove unneeded function findCalcDilRate.
** 20.09.2010 amirrasn  ECPD-15219:Added new procedure to check record for Test Device has already been set to be default for current Facility
** 25.02.2013 kumarsur  ECPD-23386:Added new function getMeterText, getOilMeterText, getGasMeterText and getWaterMeterText
** 27.11.2013 makkkkam  ECPD-26194: Modified calcSingleWellTestResult and added getJournalRevNo to support audit trail
*****************************************************************/

FUNCTION findStdNetRate(p_result_no NUMBER, p_phase VARCHAR2, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;

--

FUNCTION findNetRate(p_result_no NUMBER, p_phase VARCHAR2, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;

--

FUNCTION findGrsLiqRate(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;

--

FUNCTION findGrsGasRate(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;

--

FUNCTION findGrsGasLiftRate(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;

--

FUNCTION findGrsWaterRate(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;

--

FUNCTION findGrsGasVolume(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;

--

FUNCTION findGrsGasLiftVolume(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;

--

FUNCTION findGrsLiqVolume(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;

--

FUNCTION findGrsWaterVolume(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;

--

FUNCTION findGOR(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;

--

FUNCTION findCGR(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;

--

FUNCTION findBswVol(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;

--

FUNCTION findWOR(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;

--

FUNCTION findGLR(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;

--

FUNCTION findWGR(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;

--

FUNCTION findWetDryFactor(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;

--

FUNCTION findWetGasGravity(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;

--

FUNCTION findDuration(p_result_no NUMBER)
RETURN NUMBER;

--

FUNCTION findTdevRefShrinkageFactor(p_result_no NUMBER, p_phase VARCHAR2, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;

--

FUNCTION findInvertedShrinkageFactors(p_object_id VARCHAR2, p_daytime DATE, p_density NUMBER, p_pressure NUMBER, p_temperature NUMBER)
RETURN STRM_DPT_CONVERSION%ROWTYPE;

--

FUNCTION lookupGasLiftHrRate(p_result_no NUMBER, p_well_object_id WELL.OBJECT_ID%TYPE, p_daytime DATE)
RETURN NUMBER;

--

FUNCTION calcImpurityRate(p_result_no NUMBER, p_grs_rate NUMBER, p_phase VARCHAR2, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;

--

FUNCTION calcShrinkageVolume(p_result_no NUMBER, p_net_rate NUMBER, p_phase VARCHAR2, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;

--

FUNCTION calcTotalizerVolume(p_result_no NUMBER, p_phase VARCHAR2, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;

--

PROCEDURE calcSingleWellTestResult(p_well_object_id VARCHAR2, p_daytime DATE, p_result_no NUMBER, p_user VARCHAR2);

--

PROCEDURE updateRateSource(p_well_object_id VARCHAR2,
                           p_result_no NUMBER,
                           p_user VARCHAR2
                           );

--

FUNCTION findTdevMeterRun(p_result_no NUMBER, p_phase VARCHAR2, p_object_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2;

--

FUNCTION findTdevOrificePlate(p_result_no NUMBER, p_phase VARCHAR2, p_object_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2;

--

FUNCTION findWellRefSpecGravity(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;

FUNCTION findWellRefGasLiftSpecGravity(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;

--

FUNCTION getPwelResultDate(p_result_no NUMBER)
RETURN DATE;

--
FUNCTION agaStaticPress(p_result_no eqpm_result.result_no%TYPE, p_object_id VARCHAR2, p_phase VARCHAR2)
RETURN NUMBER;

FUNCTION agaDiffPress(p_result_no eqpm_result.result_no%TYPE, p_object_id VARCHAR2, p_phase VARCHAR2)
RETURN NUMBER;

FUNCTION getAttributeName(p_result_no EQPM_RESULT.RESULT_NO%TYPE,
                           p_object_id EQPM_RESULT.OBJECT_ID%TYPE,
                           p_column_name VARCHAR2
                           )
RETURN VARCHAR2;

FUNCTION getMeterFactor(p_object_id VARCHAR2,
         p_phase VARCHAR2,
         p_daytime DATE,
         p_result_no NUMBER)
RETURN NUMBER;

PROCEDURE updEQPMResultValues(p_object_id VARCHAR2,
         p_result_no NUMBER,
         p_daytime DATE);

FUNCTION findDiluentRate(p_result_no NUMBER,
          p_object_id VARCHAR2,
          p_daytime DATE)
RETURN NUMBER;

FUNCTION findWellWetGasRate(p_result_no NUMBER,
          p_object_id VARCHAR2,
          p_daytime DATE)
RETURN NUMBER;

Function calcWaterCut(p_result_no NUMBER, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;

FUNCTION findRefShrinkageFactor(p_result_no NUMBER, p_phase VARCHAR2, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;

FUNCTION findWellRefShrinkageFactor(p_result_no NUMBER, p_phase VARCHAR2, p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;

PROCEDURE getDefaultTdev(p_fac1_id VARCHAR2,p_daytime DATE);

FUNCTION getMeterText(
         p_code VARCHAR2,
         p_code_type VARCHAR2,
         p_object_id VARCHAR2,
		 p_date DATE) RETURN VARCHAR2;


FUNCTION getOilMeterText(
         p_code VARCHAR2,
         p_data_class VARCHAR2,
         p_object_id VARCHAR2) RETURN VARCHAR2;


FUNCTION getGasMeterText(
         p_code VARCHAR2,
         p_data_class VARCHAR2,
         p_object_id VARCHAR2) RETURN VARCHAR2;


FUNCTION getWaterMeterText(
         p_code VARCHAR2,
         p_data_class VARCHAR2,
         p_object_id VARCHAR2) RETURN VARCHAR2;

FUNCTION getJournalRevNo(p_class VARCHAR2,
         p_record_status VARCHAR2,
         p_rev_no NUMBER) RETURN NUMBER;

END EcBp_TestDevice;