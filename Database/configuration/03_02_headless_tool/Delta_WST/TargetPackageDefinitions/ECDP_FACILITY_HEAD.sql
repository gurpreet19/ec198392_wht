CREATE OR REPLACE PACKAGE EcDp_Facility IS
/****************************************************************
** Package        :  EcDp_Facility, header part
**
** $Revision: 1.12 $
**
** Purpose        :  Finds facility properties.
**
** Documentation  :  www.energy-components.com
**
** Created  : 17.01.2000  Carl-Fredrik Sørensen
**
** Modification history:
**
** Version  Date        Who  Change description:
** -------  ----------  ---- --------------------------------------
** 3.0      20.05.2000  CFS  Added functions getTotalInjectedVol and
**								  	       getTotalWatSourceVol
** 3.1      14.09.2000  FBa  Added function getExportStream
** 3.3      29.11.2000  TeJ  Added procedures setAttributeText and setAttributeValue
** 3.4      01.11.2001  FBa  Added procedure getFacility
** 3.5      14.12.2001  FBa  Added alternative implementation of getFacility. Use object_id
** 3.6      2002-02-13  FBa  Added function getInterest
** 3.7      2002-02-27  FBa  Added function getInterestVol
** 3.8      2002-03-19  DN   Added getOilToStockStream.
** 3.9      2002-05-16  HNE  Added getAttributeTextById
** 3.13     2002-07-09  FBa  Added time_span as optional argument to function getInterestFromWellProd
** 3.14     2002-07-11  DN   Removed parameter p_sysnam from getFacility function where p_object_id is input.
**          2002-07-24  MTa  Changed object_id references to objects.object_id%TYPE
**          2004-05-28  FBa  Added functions getProductionDayStart and getProductionDay
**          2004-06-02  DN   Added getProductionDayOffset.
**          2004-08-10  Toha Replaced sysnam + facility and made changes as necessary.
**          2004-08-19  T0ha Removed getFacility(p_facility)
**          2005-02-23 kaurrnar	Removed setAttributeText, setAttributeValue, getAttributeText, getAttributeTextById and getAttributeValue function
**	    2005-03-04 kaurrnar	Removed getOilToStockStream function
**          2005-11-01 DN    objects.object_id replaced with  production_facility.object_id.
**          2005-11-23 DN     Moved getParentFacility to EC_PROD EcDp_Facility.
**          2006-08-28 seongkok Added functions calcSumPersonnel and calcBedsAvailable.
*****************************************************************/


FUNCTION getFacility (
   p_object_id   production_facility.object_id%TYPE,
   p_daytime     DATE)
RETURN production_facility%ROWTYPE;

PRAGMA RESTRICT_REFERENCES (getFacility,WNDS, WNPS, RNPS);

--

FUNCTION GetParentFacility(
   p_object_id  				VARCHAR2,
   p_daytime					DATE,
   p_class_name 				VARCHAR2 DEFAULT NULL
)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (GetParentFacility, WNDS, WNPS, RNPS);


FUNCTION getExportStream(
   P_object_id      production_facility.object_id%TYPE,
	p_daytime DATE,
	p_phase VARCHAR2)

RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(getExportStream, WNDS, WNPS, RNPS);

--

FUNCTION calcSumPersonnel(
  P_object_id      production_facility.object_id%TYPE,
	p_daytime DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(calcSumPersonnel, WNDS, WNPS, RNPS);


FUNCTION calcBedsAvailable(
  P_object_id      production_facility.object_id%TYPE,
	p_daytime DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(calcBedsAvailable, WNDS, WNPS, RNPS);

--

PROCEDURE copyPrTrRecFactorRecord(p_object_id VARCHAR2, p_daytime DATE, p_new_date DATE, p_end_date DATE, p_profit_centre_id VARCHAR2, p_hydrocarbon_component VARCHAR2);

END EcDp_Facility;