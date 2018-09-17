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
*****************************************************************/

FUNCTION calcWellHookupWatDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
    p_stream_id VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcWellHookupWatDay, WNDS, WNPS, RNPS);

--

FUNCTION calcWellHookupOilDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
    p_stream_id VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcWellHookupOilDay, WNDS, WNPS, RNPS);

--

FUNCTION calcWellHookupGasDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
    p_stream_id VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcWellHookupGasDay, WNDS, WNPS, RNPS);


--

FUNCTION calcWellHookupCO2Day(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
    p_stream_id VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcWellHookupCO2Day, WNDS, WNPS, RNPS);

--

FUNCTION calcWellHookupCondDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
    p_stream_id VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcWellHookupCondDay, WNDS, WNPS, RNPS);

--

FUNCTION calcWellHookupWatInjDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcWellHookupWatInjDay, WNDS, WNPS, RNPS);

--

FUNCTION calcWellHookupGasInjDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcWellHookupGasInjDay, WNDS, WNPS, RNPS);


--

FUNCTION calcWellHookupCO2InjDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcWellHookupCO2InjDay, WNDS, WNPS, RNPS);

--

FUNCTION calcWellHookupSteamInjDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcWellHookupSteamInjDay, WNDS, WNPS, RNPS);

--

FUNCTION calcWellHookupGasLiftDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
  p_stream_id VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcWellHookupGasLiftDay, WNDS, WNPS, RNPS);

--

FUNCTION calcWellHookupDiluentDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
  p_stream_id VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcWellHookupDiluentDay, WNDS, WNPS, RNPS);

--


FUNCTION calcWellHookupOilMassDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
	p_stream_id VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcWellHookupOilMassDay, WNDS, WNPS, RNPS);

--

FUNCTION calcWellHookupGasMassDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
	p_stream_id VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcWellHookupGasMassDay, WNDS, WNPS, RNPS);

--

FUNCTION calcWellHookupWatMassDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
	p_stream_id VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcWellHookupWatMassDay, WNDS, WNPS, RNPS);

--

FUNCTION calcWellHookupCondMassDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE,
	p_stream_id VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcWellHookupCondMassDay, WNDS, WNPS, RNPS);

--

FUNCTION calcSumOperWellHookWatDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcSumOperWellHookWatDay, WNDS, WNPS, RNPS);

--

FUNCTION calcSumOperWellHookOilDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcSumOperWellHookOilDay, WNDS, WNPS, RNPS);

--

FUNCTION calcSumOperWellHookGasDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcSumOperWellHookGasDay, WNDS, WNPS, RNPS);


--

FUNCTION calcSumOperWellHookCO2Day(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcSumOperWellHookCO2Day, WNDS, WNPS, RNPS);


--

FUNCTION calcSumOperWellHookCondDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcSumOperWellHookCondDay, WNDS, WNPS, RNPS);

--

FUNCTION calcSumOperWellHookWatInjDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcSumOperWellHookWatInjDay, WNDS, WNPS, RNPS);

--

FUNCTION calcSumOperWellHookGasInjDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcSumOperWellHookGasInjDay, WNDS, WNPS, RNPS);


--

FUNCTION calcSumOperWellHookCO2InjDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcSumOperWellHookCO2InjDay, WNDS, WNPS, RNPS);



--

FUNCTION calcSumOperWellHookSteamInjDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcSumOperWellHookSteamInjDay, WNDS, WNPS, RNPS);

--

FUNCTION calcSumOperWellHookGasLiftDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcSumOperWellHookGasLiftDay, WNDS, WNPS, RNPS);

--

FUNCTION calcSumOperWellHookDiluentDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcSumOperWellHookDiluentDay, WNDS, WNPS, RNPS);

--


FUNCTION calcSumOperWellHookOilMassDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcSumOperWellHookOilMassDay, WNDS, WNPS, RNPS);

--

FUNCTION calcSumOperWellHookGasMassDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcSumOperWellHookGasMassDay, WNDS, WNPS, RNPS);

--

FUNCTION calcSumOperWellHookWatMassDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcSumOperWellHookWatMassDay, WNDS, WNPS, RNPS);

--

FUNCTION calcSumOperWellHookCondMassDay(
    p_object_id       well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcSumOperWellHookCondMassDay, WNDS, WNPS, RNPS);

--

END EcBp_Well_Hookup_Theoretical;