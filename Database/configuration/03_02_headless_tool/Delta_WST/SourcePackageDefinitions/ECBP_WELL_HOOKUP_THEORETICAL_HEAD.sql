CREATE OR REPLACE PACKAGE EcBp_Well_Hookup_Theoretical IS

/****************************************************************
** Package        :  EcBp_Well_Hookup_Theoretical, header part
**
** $Revision: 1.12 $
**
** Purpose        :  Provides theoretical fluid values (rates etc)
**                    for a given well hookup.
**
** Documentation  :  www.energy-components.com
**
** Created  : 06.08.2005  Jerome Chong
**
** Modification history:
**
** Version Date       Whom     Change description:
** ------- ---------- -------- ----------------------------------
** 1.0     06.08.2005 chongjer Initial version
**         28.12.2005 bohhhron Add new function
**                             calcWellHookupWatInjDay
**                             calcWellHookupGasInjDay
**                             calcWellHookupSteamInjDay
**                             calcWellHookupGasLiftDay
**                             calcWellHookupDiluentDay
**         26.08.2008 aliassit ECPD-9080: Modified calcWellHookupWatDay, calcWellHookupOilDay, calcWellHookupGasDay, calcWellHookupCondDay
**         29.08.2008 amirrasn ECPD-10156: Modified calcWellHookupGasLiftDay,calcWellHookupDiluentDay
**         16.12.2008 oonnnng  ECPD-10317: Add new functions calcWellHookupOilMassDay, calcWellHookupGasMassDay, and calcWellHookupWatMassDay.
**         15.01.2009 aliassit ECPD-10563: Add new functions to calculate sum theoretical independent on proc_node_id_XXX
**         14.03.2009 rajarsar ECPD-9038: Added calcWellHookupCO2InjDay, calcWellHookupCO2Day, calcSumOperWellHookCO2InjDay and calcSumOperWellHookCO2Day
**         02.03.2011 syazwnur ECPD-16737: Added new functions calcWellHookupCondMassDay and calcSumOperWellHookCondMassDay.
**         15.02.2017 singishi ECPD-43210: Added new function getWellHookPhaseFactorDay and getWellHookPhaseMassFactorDay to return the calculated factor for each phase.
*****************************************************************/

FUNCTION calcWellHookupWatDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
    p_stream_id VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

--

FUNCTION calcWellHookupOilDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
    p_stream_id VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

--

FUNCTION calcWellHookupGasDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
    p_stream_id VARCHAR2 DEFAULT NULL)

RETURN NUMBER;


--

FUNCTION calcWellHookupCO2Day(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
    p_stream_id VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

--

FUNCTION calcWellHookupCondDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
    p_stream_id VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

--

FUNCTION calcWellHookupWatInjDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION calcWellHookupGasInjDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;


--

FUNCTION calcWellHookupCO2InjDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION calcWellHookupSteamInjDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION calcWellHookupGasLiftDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
  p_stream_id VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

--

FUNCTION calcWellHookupDiluentDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
  p_stream_id VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

--


FUNCTION calcWellHookupOilMassDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
	p_stream_id VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

--

FUNCTION calcWellHookupGasMassDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
	p_stream_id VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

--

FUNCTION calcWellHookupWatMassDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
	p_stream_id VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

--

FUNCTION calcWellHookupCondMassDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
	p_stream_id VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

--

FUNCTION calcSumOperWellHookWatDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION calcSumOperWellHookOilDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION calcSumOperWellHookGasDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;


--

FUNCTION calcSumOperWellHookCO2Day(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;


--

FUNCTION calcSumOperWellHookCondDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION calcSumOperWellHookWatInjDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION calcSumOperWellHookGasInjDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;


--

FUNCTION calcSumOperWellHookCO2InjDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;



--

FUNCTION calcSumOperWellHookSteamInjDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION calcSumOperWellHookGasLiftDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION calcSumOperWellHookDiluentDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--


FUNCTION calcSumOperWellHookOilMassDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION calcSumOperWellHookGasMassDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION calcSumOperWellHookWatMassDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION calcSumOperWellHookCondMassDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--
FUNCTION getWellHookPhaseFactorDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
    p_phase VARCHAR2)

RETURN NUMBER;

--
FUNCTION getWellHookPhaseMassFactorDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
    p_phase VARCHAR2)

RETURN NUMBER;

--

END EcBp_Well_Hookup_Theoretical;