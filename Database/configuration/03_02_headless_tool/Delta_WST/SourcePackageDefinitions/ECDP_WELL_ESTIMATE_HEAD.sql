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

FUNCTION getLastCondStdRate(
	p_object_id       IN well.object_id%TYPE,
   p_daytime			IN DATE)
RETURN NUMBER;


FUNCTION getLastGasStdRate(
	p_object_id       IN well.object_id%TYPE,
   p_daytime			IN DATE)
RETURN NUMBER;


FUNCTION getLastCO2Fraction(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;


FUNCTION getLastWatStdRate(
	p_object_id       IN well.object_id%TYPE,
   p_daytime			IN DATE)
RETURN NUMBER;


FUNCTION getLastAvgDhPumpSpeed(
   p_object_id     IN VARCHAR2,
   p_daytime       IN DATE)
RETURN NUMBER;


FUNCTION getLastDiluentStdRate(
   p_object_id       IN VARCHAR2,
   p_daytime         IN DATE)
RETURN NUMBER;


FUNCTION getLastOilStdMassRate(
	p_object_id       IN well.object_id%TYPE,
   p_daytime			IN DATE)
RETURN NUMBER;

FUNCTION getLastCondStdMassRate(
	p_object_id       IN well.object_id%TYPE,
   p_daytime			IN DATE)
RETURN NUMBER;


FUNCTION getLastGasStdMassRate(
	p_object_id       IN well.object_id%TYPE,
   p_daytime			IN DATE)
RETURN NUMBER;

FUNCTION getLastWatStdMassRate(
	p_object_id       IN well.object_id%TYPE,
   p_daytime			IN DATE)
RETURN NUMBER;


FUNCTION getNextOilStdRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

--

FUNCTION getNextGasStdRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

--

FUNCTION getNextCondStdRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

--

FUNCTION getNextWatStdRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;


FUNCTION getNextOilStdMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

--

FUNCTION getNextGasStdMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

--

FUNCTION getNextCondStdMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

--

FUNCTION getNextWatStdMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

--

FUNCTION getOilStdRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

--

FUNCTION getGasStdRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

--

FUNCTION getCondStdRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

--

FUNCTION getWatStdRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

--

FUNCTION getOilStdMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;


--

FUNCTION getGasStdMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

--

FUNCTION getCondStdMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

--

FUNCTION getWatStdMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

--

FUNCTION getInterpolateOilRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

--

FUNCTION getExtrapolateOilRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

--

FUNCTION getInterpolateGasRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

--

FUNCTION getExtrapolateGasRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

--

FUNCTION getInterpolateCondRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

--

FUNCTION getExtrapolateCondRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

--

FUNCTION getInterpolateWatRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

--

FUNCTION getExtrapolateWatRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;


FUNCTION getInterpolatedOilProdPot (
  p_object_id well.object_id%TYPE,
  p_daytime  DATE)
RETURN NUMBER;

--

FUNCTION getInterpolateOilMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

--

FUNCTION getExtrapolateOilMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

--

FUNCTION getInterpolateGasMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

--

FUNCTION getExtrapolateGasMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

--

FUNCTION getInterpolateCondMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

--

FUNCTION getExtrapolateCondMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

--

FUNCTION getInterpolateWatMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;

--

FUNCTION getExtrapolateWatMassRate(
   p_object_id       IN well.object_id%TYPE,
   p_daytime         IN DATE)
RETURN NUMBER;



END EcDp_Well_Estimate;