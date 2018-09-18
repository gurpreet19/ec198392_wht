CREATE OR REPLACE PACKAGE EcBp_Stream_VentFlare IS
/****************************************************************
** Package        :  EcBp_Stream_VentFlare
**
** $Revision: 1.10.2.4 $
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
** 10.09.2012 leongwen ECPD-21939:Removed the p_end_daytime in FUNCTION calcWellContrib and calcWellDuration
** 09.04.2014 kumarsur ECPD-27329:Modified recalcGrsVol and calcGrsVol, rename to recalcGrsVolMass and calcGrsVolMass.
*****************************************************************/


FUNCTION getStreamSetCode(p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getStreamSetCode, WNDS, WNPS, RNPS);

FUNCTION calcNormalRelease(p_object_id VARCHAR2, p_asset_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcNormalRelease, WNDS, WNPS, RNPS);

FUNCTION calcUpsetRelease(p_object_id VARCHAR2, p_asset_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcUpsetRelease, WNDS, WNPS, RNPS);

FUNCTION sumNormalRelease(p_object_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (calcNormalRelease, WNDS, WNPS, RNPS);

FUNCTION sumUpsetRelease(p_object_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (calcUpsetRelease, WNDS, WNPS, RNPS);

FUNCTION calcRelease(p_object_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (calcRelease, WNDS, WNPS, RNPS);

FUNCTION calcNormalMTDAvg(p_object_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (calcNormalMTDAvg, WNDS, WNPS, RNPS);

FUNCTION sumRoutineRelease(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE) RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (sumRoutineRelease, WNDS, WNPS, RNPS);

FUNCTION sumNonRouRelease(p_object_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (sumNonRouRelease, WNDS, WNPS, RNPS);

FUNCTION getDataClass(p_object_id VARCHAR2, p_daytime DATE, p_tab VARCHAR2) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getDataClass, WNDS, WNPS, RNPS);

FUNCTION calcEqpmDuration(p_object_id VARCHAR2,p_class_name VARCHAR2,p_daytime DATE,  p_asset_id VARCHAR2,p_start_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcEqpmDuration, WNDS, WNPS, RNPS);

FUNCTION calcWellDuration(p_object_id VARCHAR2,p_class_name VARCHAR2,p_daytime DATE,  p_asset_id VARCHAR2,p_start_daytime DATE, p_well_id VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcWellDuration, WNDS, WNPS, RNPS);

FUNCTION calcEqpmNorCapacity(p_object_id VARCHAR2,p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcEqpmNorCapacity, WNDS, WNPS, RNPS);

FUNCTION calcWellContrib(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE, p_well_id VARCHAR2) RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (calcWellContrib, WNDS, WNPS, RNPS);

FUNCTION calcEqpmRelease(p_object_id VARCHAR2,p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcEqpmRelease, WNDS, WNPS, RNPS);

FUNCTION calcVRUFailure(p_object_id VARCHAR2,p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcVRUFailure, WNDS, WNPS, RNPS);

FUNCTION calcVapourGenerated(p_object_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (calcVapourGenerated, WNDS, WNPS, RNPS);

FUNCTION countWellContrib(p_parent_object_id VARCHAR2, p_parent_daytime DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (countWellContrib, WNDS, WNPS, RNPS);

FUNCTION sumEqpmWellVol(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE)
RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (sumEqpmWellVol, WNDS, WNPS, RNPS);

FUNCTION calcTotalRelease(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE)
RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (calcTotalRelease, WNDS, WNPS, RNPS);

FUNCTION countGenVapours
(p_object_id VARCHAR2,p_asset_id VARCHAR2,p_daytime DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (countGenVapours, WNDS, WNPS, RNPS);

FUNCTION sumGenVapours(p_object_id VARCHAR2,p_asset_id VARCHAR2,p_daytime DATE)
RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (sumGenVapours, WNDS, WNPS, RNPS);

FUNCTION getPotentialRate (
	p_object_id        VARCHAR2,
	p_daytime          DATE,
	p_potential_attribute VARCHAR2)
RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (getPotentialRate, WNDS, WNPS, RNPS);

FUNCTION calcRunHours(p_object_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcRunHours, WNDS, WNPS, RNPS);

FUNCTION calcRoutineRunHours(p_process_unit_id VARCHAR2,p_asset_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcRoutineRunHours, WNDS, WNPS, RNPS);

FUNCTION calcRoutineAvailVapour(p_object_id VARCHAR2, p_asset_id VARCHAR2, p_process_unit_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcRoutineAvailVapour, WNDS, WNPS, RNPS);

FUNCTION calcUpsetAvailVapour(p_object_id VARCHAR2, p_asset_id VARCHAR2, p_process_unit_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcUpsetAvailVapour, WNDS, WNPS, RNPS);

PROCEDURE calcGrsVolMass(p_object_id VARCHAR2, p_daytime DATE,p_user VARCHAR2) ;

FUNCTION getGasOilRatio (
	p_object_id        VARCHAR2,
	p_daytime          DATE)
	RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (getGasOilRatio, WNDS, WNPS, RNPS);

FUNCTION calcEventVol(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE, p_end_daytime DATE)
RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (calcEventVol, WNDS, WNPS, RNPS);


FUNCTION calcWellEventVol(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE, p_well_id VARCHAR2)
RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (calcWellEventVol, WNDS, WNPS, RNPS);

FUNCTION getTheoreticalRate (
	p_object_id        VARCHAR2,
	p_daytime          DATE,
	p_theoretical_attribute VARCHAR2)
RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (getTheoreticalRate, WNDS, WNPS, RNPS);

FUNCTION sumEqpmWellVolTheor(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE)
RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (sumEqpmWellVolTheor, WNDS, WNPS, RNPS);

FUNCTION calcWellContribTheor(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE, p_well_id VARCHAR2) RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (calcWellContribTheor, WNDS, WNPS, RNPS);

FUNCTION getTheorGasOilRatio (
	p_object_id        VARCHAR2,
	p_daytime          DATE)
	RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (getTheorGasOilRatio, WNDS, WNPS, RNPS);

FUNCTION calcMtd (
	p_object_id        VARCHAR2,
	p_daytime          DATE)
	RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcMtd, WNDS, WNPS, RNPS);

FUNCTION calcMtdDuration (
	p_object_id        VARCHAR2,
	p_daytime          DATE)
	RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcMtdDuration, WNDS, WNPS, RNPS);

FUNCTION countMtdRec(
  p_parent_object_id VARCHAR2,
  p_parent_daytime DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (countMtdRec, WNDS, WNPS, RNPS);

PROCEDURE recalcGrsVolMass(p_object_id VARCHAR2, p_daytime DATE,p_user VARCHAR2) ;
END EcBp_Stream_VentFlare;