CREATE OR REPLACE PACKAGE EcBp_Stream_VentFlare IS
/****************************************************************
** Package        :  EcBp_Stream_VentFlare
**
** $Revision: 1.13 $
**
** Purpose        :  This package is responsible for supporting business functions
**                         related to Daily Gas Stream - Vent and Flare.
**
** Documentation  :  www.energy-components.com
**
** Created  : 17.03.2010  Sarojini Rajaretnam
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 17.03.2010 rajarsar ECPD-4828:Initial version.
** 31.05.2010 rajarsar ECPD-14622:Added function calcEventVol,calcWellDuration and calcWellEventVol
**                     removed calcRecVapours, countRecVapours and sumRecVapours and
**                     updated calcNormalRelease, calcUpsetRelease and calcNormalMTDAvg
** 13.08.2010 rajarsar ECPD-15495:Updated calcRoutineRunHours to add a new parameter which is p_asset_id
** 07.10.2010 sharawan ECPD-14866: Change 'vapor' to 'vapour' to standardize the spelling
** 08.10.2010 farhaann ECPD-14042: Added getTheoreticalRate, sumEqpmWellVolTheor, calcWellContribTheor, getTheorGasOilRatio and calcMtd
** 02.02.2011 farhaann ECPD-16411:Renamed calcNetVol to calcGrsVol
** 18.04.2011 syazwnur ECPD-17285:Added calcMtdDuration and countMtdRec
** 13.06.2012 choonshu ECPD-19245:Included end date to calcWellDuration and calcWellContrib
** 12.09.2012 leongwen ECPD-21534:Removed the p_end_daytime in FUNCTION calcWellContrib and calcWellDuration
** 09.04.2014 kumarsur ECPD-27001:Modified recalcGrsVol and calcGrsVol, rename to recalcGrsVolMass and calcGrsVolMass.
** 16.01.2018 chaudgau ECPD-51616: Modified signature of calcTotalRelease, calcEventVol for performance improvement.
** 23.03.2018 shindani ECPD-44451: Added support to calcNormalRelease,calcPotensialRelease,calcUpsetRelease.
                                   Modified functions sumRoutineRelease,sumNonRouRelease,calcVapourGenerated and calcGrsVolMass.
*****************************************************************/


FUNCTION getStreamSetCode(p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;

FUNCTION calcNormalRelease(p_object_id VARCHAR2, p_asset_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

FUNCTION calcPotensialRelease(p_object_id VARCHAR2, p_asset_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;

FUNCTION calcUpsetRelease(p_object_id VARCHAR2, p_asset_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

FUNCTION sumNormalRelease(p_object_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
--

FUNCTION sumUpsetRelease(p_object_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
--

FUNCTION calcRelease(p_object_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
--

FUNCTION calcNormalMTDAvg(p_object_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
--

FUNCTION sumRoutineRelease(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE) RETURN NUMBER;
--

FUNCTION sumNonRouRelease(p_object_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
--

FUNCTION getDataClass(p_object_id VARCHAR2, p_daytime DATE, p_tab VARCHAR2) RETURN VARCHAR2;

FUNCTION calcEqpmDuration(p_object_id VARCHAR2,p_class_name VARCHAR2,p_daytime DATE,  p_asset_id VARCHAR2,p_start_daytime DATE) RETURN NUMBER;

FUNCTION calcWellDuration(p_object_id VARCHAR2,p_class_name VARCHAR2,p_daytime DATE,  p_asset_id VARCHAR2,p_start_daytime DATE, p_well_id VARCHAR2) RETURN NUMBER;

FUNCTION calcEqpmNorCapacity(p_object_id VARCHAR2,p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE) RETURN NUMBER;

FUNCTION calcWellContrib(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE, p_well_id VARCHAR2) RETURN NUMBER;
--

FUNCTION calcEqpmRelease(p_object_id VARCHAR2,p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE) RETURN NUMBER;

FUNCTION calcVRUFailure(p_object_id VARCHAR2,p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE) RETURN NUMBER;

FUNCTION calcVapourGenerated(p_object_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
--

FUNCTION countWellContrib(p_parent_object_id VARCHAR2, p_parent_daytime DATE)
RETURN NUMBER;

FUNCTION sumEqpmWellVol(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE)
RETURN NUMBER;
--

FUNCTION calcTotalRelease(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE, p_release_method VARCHAR2 DEFAULT '-1', p_total_num_occur NUMBER DEFAULT -1)
RETURN NUMBER;
--

FUNCTION countGenVapours
(p_object_id VARCHAR2,p_asset_id VARCHAR2,p_daytime DATE)
RETURN NUMBER;

FUNCTION sumGenVapours(p_object_id VARCHAR2,p_asset_id VARCHAR2,p_daytime DATE)
RETURN NUMBER;
--

FUNCTION getPotentialRate (
	p_object_id        VARCHAR2,
	p_daytime          DATE,
	p_potential_attribute VARCHAR2)
RETURN NUMBER;
--

FUNCTION calcRunHours(p_object_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

FUNCTION calcRoutineRunHours(p_process_unit_id VARCHAR2,p_asset_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

FUNCTION calcRoutineAvailVapour(p_object_id VARCHAR2, p_asset_id VARCHAR2, p_process_unit_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

FUNCTION calcUpsetAvailVapour(p_object_id VARCHAR2, p_asset_id VARCHAR2, p_process_unit_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

PROCEDURE calcGrsVolMass(p_object_id VARCHAR2, p_daytime DATE,p_user VARCHAR2) ;

FUNCTION getGasOilRatio (
	p_object_id        VARCHAR2,
	p_daytime          DATE)
	RETURN NUMBER;
--

FUNCTION calcEventVol(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE, p_end_daytime DATE, p_release_method VARCHAR2 DEFAULT '-1', p_total_num_occur NUMBER DEFAULT -1)
RETURN NUMBER;
--


FUNCTION calcWellEventVol(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE, p_well_id VARCHAR2)
RETURN NUMBER;
--

FUNCTION getTheoreticalRate (
	p_object_id        VARCHAR2,
	p_daytime          DATE,
	p_theoretical_attribute VARCHAR2)
RETURN NUMBER;
--

FUNCTION sumEqpmWellVolTheor(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE)
RETURN NUMBER;
--

FUNCTION calcWellContribTheor(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE, p_well_id VARCHAR2) RETURN NUMBER;
--

FUNCTION getTheorGasOilRatio (
	p_object_id        VARCHAR2,
	p_daytime          DATE)
	RETURN NUMBER;
--

FUNCTION calcMtd (
	p_object_id        VARCHAR2,
	p_daytime          DATE)
	RETURN NUMBER;

FUNCTION calcMtdDuration (
	p_object_id        VARCHAR2,
	p_daytime          DATE)
	RETURN NUMBER;

FUNCTION countMtdRec(
  p_parent_object_id VARCHAR2,
  p_parent_daytime DATE)
RETURN NUMBER;

PROCEDURE recalcGrsVolMass(p_object_id VARCHAR2, p_daytime DATE,p_user VARCHAR2) ;
END EcBp_Stream_VentFlare;