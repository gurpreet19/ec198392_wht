CREATE OR REPLACE PACKAGE EcDp_Well_Estimate IS
/******************************************************************************
** Package        :  EcDp_Well_Estimate, header part
**
** $Revision: 1.14 $
**
** Purpose        :  Provide data access functions for well estimates
**
** Documentation  :  www.energy-components.com
**
** Created  : 2/22/2002  Frode Barstad
**
** Modification history:
**
** Date            Whom     Change description:
** ----------      -----    -------------------------------------------
** 2002.02.22      FBa      Initial version
** 2002.06.11      PGI      Added detail functions
**                          getLastOilStdRateDetail, getLastGasStdRateDetail, getLastWatStdRateDetail,
**                          getOilRateDecline, getGasRateDecline, getWatRateDecline,
**                          getLastDetailValue,
**                          getOilStdRatePeriod, getGasStdRatePeriod and getWatStdRatePeriod
** 2002.11.29      DN       Renamed getOilStdRatePeriod, getGasStdRatePeriod and getWatStdRatePeriod to vol instead of rate.
** 27.05.2004      FBa      Added function getLastAvgDhPumpSpeed
** 11.08.2004      mazrina  Removed sysnam and update as necessary
** 15.2.2005       Ron      Added new funtion getLastDiluentStdRateDay to support diluent in well test.
** 12.04.2005      SHN      Performance Test cleanup
** 13.04.2005      ROV      Added getLastCondStdRate
** 09.09.2005      Ron      Added 16 new functions
** 			 - getNextOilStdRate
** 			 - getNextGasStdRate
** 			 - getNextCondStdRate
** 			 - getNextWatStdRate
** 			 - getOilStdRate
** 			 - getGasStdRate
** 			 - getCondStdRate
** 			 - getWatStdRate
** 			 - getInterpolateOilRate
** 			 - getExtrapolateOilRate
** 			 - getInterpolateGasRate
** 			 - getExtrapolateGasRate
** 			 - getInterpolateCondRate
** 			 - getExtrapolateCondRate
** 			 - getInterpolateWatRate
**            		 - getExtrapolateWatRate
** 01.12.2005      DN       Function getInterpolatedOilProdPot moved from EcDp_Well_Potential to EcDp_Well_Estimate.
** 06.09.2007      rajarsar ECPD-6264:Added 20 new functions
** 			 - getLastOilStdMassRate
** 			 - getLastCondStdMassRate
** 			 - getLastGasStdMassRate
** 			 - getLastWatStdMassRate
** 			 - getNextOilStdMassRate
** 			 - getNextGasStdMassRate
** 			 - getNextCondStdMassRate
** 			 - getNextWatStdMassRate
** 			 - getOilStdMassRate
** 			 - getGasStdMassRate
** 			 - getCondStdMassRate
** 			 - getWatStdMassRate
** 			 - getInterpolateOilMassRate
** 			 - getExtrapolateOilMassRate
** 			 - getInterpolateGasMassRate
**           - getExtrapolateGasMassRate
**			 - getInterpolateCondMassRate
** 			 - getExtrapolateCondMassRate
**			 - getInterpolateWatMassRate
**			 - getExtrapolateWatMassRate
** 25.08.2008      rajarsar ECPD-9038: Added new function getLastCO2Fraction()
***************************************************************************************************/

FUNCTION getLastOilStdRate(
	p_object_id       IN well.object_id%TYPE,
   p_daytime			IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getLastOilStdRate, WNDS, WNPS, RNPS);

FUNCTION getLastCondStdRate(
	p_object_id       IN well.object_id%TYPE,
   p_daytime			IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getLastCondStdRate, WNDS, WNPS, RNPS);


FUNCTION getLastGasStdRate(
	p_object_id       IN well.object_id%TYPE,
   p_daytime			IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getLastGasStdRate, WNDS, WNPS, RNPS);


FUNCTION getLastCO2Fraction(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getLastCO2Fraction, WNDS,WNPS, RNPS);


FUNCTION getLastWatStdRate(
	p_object_id       IN well.object_id%TYPE,
   p_daytime			IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getLastWatStdRate, WNDS, WNPS, RNPS);


FUNCTION getLastAvgDhPumpSpeed(
   p_object_id     IN VARCHAR2,
   p_daytime       IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getLastAvgDhPumpSpeed, WNDS, WNPS, RNPS);


FUNCTION getLastDiluentStdRate(
   p_object_id       IN VARCHAR2,
   p_daytime         IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getLastDiluentStdRate, WNDS,WNPS, RNPS);


FUNCTION getLastOilStdMassRate(
	p_object_id       IN well.object_id%TYPE,
   p_daytime			IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getLastOilStdMassRate, WNDS, WNPS, RNPS);

FUNCTION getLastCondStdMassRate(
	p_object_id       IN well.object_id%TYPE,
   p_daytime			IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getLastCondStdMassRate, WNDS, WNPS, RNPS);


FUNCTION getLastGasStdMassRate(
	p_object_id       IN well.object_id%TYPE,
   p_daytime			IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getLastGasStdMassRate, WNDS, WNPS, RNPS);

FUNCTION getLastWatStdMassRate(
	p_object_id       IN well.object_id%TYPE,
   p_daytime			IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getLastWatStdMassRate, WNDS, WNPS, RNPS);


FUNCTION getNextOilStdRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getNextOilStdRate, WNDS,WNPS, RNPS);

--

FUNCTION getNextGasStdRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getNextGasStdRate, WNDS,WNPS, RNPS);

--

FUNCTION getNextCondStdRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getNextCondStdRate, WNDS,WNPS, RNPS);

--

FUNCTION getNextWatStdRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getNextWatStdRate, WNDS,WNPS, RNPS);


FUNCTION getNextOilStdMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getNextOilStdMassRate, WNDS,WNPS, RNPS);

--

FUNCTION getNextGasStdMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getNextGasStdMassRate, WNDS,WNPS, RNPS);

--

FUNCTION getNextCondStdMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getNextCondStdMassRate, WNDS,WNPS, RNPS);

--

FUNCTION getNextWatStdMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getNextWatStdMassRate, WNDS,WNPS, RNPS);

--

FUNCTION getOilStdRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getOilStdRate, WNDS,WNPS, RNPS);

--

FUNCTION getGasStdRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getGasStdRate, WNDS,WNPS, RNPS);

--

FUNCTION getCondStdRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getCondStdRate, WNDS,WNPS, RNPS);

--

FUNCTION getWatStdRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getWatStdRate, WNDS,WNPS, RNPS);

--

FUNCTION getOilStdMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getOilStdMassRate, WNDS,WNPS, RNPS);


--

FUNCTION getGasStdMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getGasStdMassRate, WNDS,WNPS, RNPS);

--

FUNCTION getCondStdMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getCondStdMassRate, WNDS,WNPS, RNPS);

--

FUNCTION getWatStdMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getWatStdMassRate, WNDS,WNPS, RNPS);

--

FUNCTION getInterpolateOilRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getInterpolateOilRate, WNDS,WNPS, RNPS);

--

FUNCTION getExtrapolateOilRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getExtrapolateOilRate, WNDS,WNPS, RNPS);

--

FUNCTION getInterpolateGasRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getInterpolateGasRate, WNDS,WNPS, RNPS);

--

FUNCTION getExtrapolateGasRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getExtrapolateGasRate, WNDS,WNPS, RNPS);

--

FUNCTION getInterpolateCondRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getInterpolateCondRate, WNDS,WNPS, RNPS);

--

FUNCTION getExtrapolateCondRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getExtrapolateCondRate, WNDS,WNPS, RNPS);

--

FUNCTION getInterpolateWatRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getInterpolateWatRate, WNDS,WNPS, RNPS);

--

FUNCTION getExtrapolateWatRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getExtrapolateWatRate, WNDS,WNPS, RNPS);


FUNCTION getInterpolatedOilProdPot (
  p_object_id well.object_id%TYPE,
  p_daytime  DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getInterpolatedOilProdPot, WNDS, WNPS, RNPS);

--

FUNCTION getInterpolateOilMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getInterpolateOilMassRate, WNDS,WNPS, RNPS);

--

FUNCTION getExtrapolateOilMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getExtrapolateOilMassRate, WNDS,WNPS, RNPS);

--

FUNCTION getInterpolateGasMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getInterpolateGasMassRate, WNDS,WNPS, RNPS);

--

FUNCTION getExtrapolateGasMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getExtrapolateGasMassRate, WNDS,WNPS, RNPS);

--

FUNCTION getInterpolateCondMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getInterpolateCondMassRate, WNDS,WNPS, RNPS);

--

FUNCTION getExtrapolateCondMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getExtrapolateCondMassRate, WNDS,WNPS, RNPS);

--

FUNCTION getInterpolateWatMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getInterpolateWatMassRate, WNDS,WNPS, RNPS);

--

FUNCTION getExtrapolateWatMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getExtrapolateWatMassRate, WNDS,WNPS, RNPS);



END EcDp_Well_Estimate;