CREATE OR REPLACE PACKAGE EcBp_Facility_Theoretical IS

/****************************************************************
** Package        :  EcBp_Facility_Theoretical, header part
**
** $Revision: 1.10.2.1 $
**
** Purpose        :  Provides theoretical fluid values (rates etc)
**	                  for a given facility.
**
** Documentation  :  www.energy-components.com
**
** Created  : 14.01.2000  Carl-Fredrik Sørensen
**
** Modification history:
**
** Version  Date     	Whom  Change description:
** -------  ------   	----- --------------------------------------
** 1.0   	14.01.00  	CFS   Initial version
** 3.0		03.03.2000	GNO	  Added calcFacilityOilDay and calcFacilityGasDay
** 4.0    07.07.2000  DN    Added calcTotFlowlineStdRateDay.
** 4.1    15.05.2001  DN    Added calcPlatformPhaseStdVolPeriod and calcSubseaPhaseStdVolPeriod
** 4.2    09.01.02    UMF   Added calcFacilityCondDay
**        25.05.2004  FBa   Removed references to EcBp_Flowline_Theoretical
**        10.08.2004  Toha  Removed sysnam and facility and made changes as necesary.
**         28.12.2005 bohhhron Add new function
**                             calcFacilityWatInjDay
**                             calcFacilityGasInjDay
**                             calcFacilitySteamInjDay
**                             calcFacilityGasLiftDay
**                             calcFacilityDiluentDay
**        04.09.2008 rajarsar ECPD-9038:Added calcFacilityCO2Day.
**        16.12.2008 oonnnng  ECPD-10317: Add new functions calcFacilityOilMassDay, calcFacilityGasMassDay, calcFacilityWatMassDay.
**        15.01.2009 aliassit ECPD-10563: Add new functions to calculate sum theoretical independent on proc_node_id_XXX
**        14.03.2009 rajarsar ECPD-9038: Added calcfacilityCO2Inj and calcSumOperFacilityCO2InjDay
**        13.07.2012 musthram ECPD-21503: Added calcFacililtyCondMass and calcSumOperFacilityCondMassDay
*****************************************************************/

FUNCTION calcPlatformPhaseStdVolPeriod(
--	p_sysnam   VARCHAR2,
--	p_facility VARCHAR2,
    p_object_id       production_facility.object_id%TYPE,
	  p_from_date    DATE,
	  p_to_date      DATE,
	  p_phase    VARCHAR2)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcPlatformPhaseStdVolPeriod, WNDS, WNPS, RNPS);

--

FUNCTION calcSubseaPhaseStdVolPeriod(
--	p_sysnam   VARCHAR2,
--	p_facility VARCHAR2,
    p_object_id       production_facility.object_id%TYPE,
    p_from_date    DATE,
    p_to_date      DATE,
    p_phase    VARCHAR2)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcSubseaPhaseStdVolPeriod, WNDS, WNPS, RNPS);

--

FUNCTION calcFacilityWatDay(
--	p_sysnam   VARCHAR2,
--	p_facility VARCHAR2,
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcFacilityWatDay, WNDS, WNPS, RNPS);

--

FUNCTION calcFacilityOilDay(
--	p_sysnam   VARCHAR2,
--	p_facility VARCHAR2,
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcFacilityOilDay, WNDS, WNPS, RNPS);

--

FUNCTION calcFacilityGasDay(
--	p_sysnam   VARCHAR2,
--	p_facility VARCHAR2,
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcFacilityGasDay, WNDS, WNPS, RNPS);

--

FUNCTION calcFacilityCondDay(
--	p_sysnam   VARCHAR2,
--	p_facility VARCHAR2,
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcFacilityCondDay, WNDS, WNPS, RNPS);

--

FUNCTION calcFacilityWatInjDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcFacilityWatInjDay, WNDS, WNPS, RNPS);

--

FUNCTION calcFacilityGasInjDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcFacilityGasInjDay, WNDS, WNPS, RNPS);

--

FUNCTION calcFacilitySteamInjDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcFacilitySteamInjDay, WNDS, WNPS, RNPS);

--

FUNCTION calcFacilityGasLiftDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcFacilityGasLiftDay, WNDS, WNPS, RNPS);

--

FUNCTION calcFacilityDiluentDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcFacilityDiluentDay, WNDS, WNPS, RNPS);

--

FUNCTION calcFacilityCO2Day(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcFacilityCO2Day, WNDS, WNPS, RNPS);


--

FUNCTION calcFacilityCO2InjDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcFacilityCO2InjDay, WNDS, WNPS, RNPS);


--

FUNCTION calcFacilityOilMassDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcFacilityOilMassDay, WNDS, WNPS, RNPS);

--

FUNCTION calcFacilityGasMassDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcFacilityGasMassDay, WNDS, WNPS, RNPS);

--

FUNCTION calcFacilityWatMassDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcFacilityWatMassDay, WNDS, WNPS, RNPS);

FUNCTION calcFacilityCondMassDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcFacilityCondMassDay, WNDS, WNPS, RNPS);

FUNCTION calcSumOperFacilityWatDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcSumOperFacilityWatDay, WNDS, WNPS, RNPS);

--

FUNCTION calcSumOperFacilityOilDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcSumOperFacilityOilDay, WNDS, WNPS, RNPS);

--

FUNCTION calcSumOperFacilityGasDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcSumOperFacilityGasDay, WNDS, WNPS, RNPS);

--

FUNCTION calcSumOperFacilityCondDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcSumOperFacilityCondDay, WNDS, WNPS, RNPS);

--

FUNCTION calcSumOperFacilityWatInjDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcSumOperFacilityWatInjDay, WNDS, WNPS, RNPS);

--

FUNCTION calcSumOperFacilityGasInjDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcSumOperFacilityGasInjDay, WNDS, WNPS, RNPS);

--

FUNCTION calcSumOperFacilitySteamInjDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcSumOperFacilitySteamInjDay, WNDS, WNPS, RNPS);

--

FUNCTION calcSumOperFacilityGasLiftDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcSumOperFacilityGasLiftDay, WNDS, WNPS, RNPS);

--

FUNCTION calcSumOperFacilityDiluentDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (calcSumOperFacilityDiluentDay, WNDS, WNPS, RNPS);

--

FUNCTION calcSumOperFacilityCO2Day(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcSumOperFacilityCO2Day, WNDS, WNPS, RNPS);

--

FUNCTION calcSumOperFacilityCO2InjDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcSumOperFacilityCO2InjDay, WNDS, WNPS, RNPS);

--

FUNCTION calcSumOperFacilityOilMassDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcSumOperFacilityOilMassDay, WNDS, WNPS, RNPS);

--

FUNCTION calcSumOperFacilityGasMassDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcSumOperFacilityGasMassDay, WNDS, WNPS, RNPS);

--

FUNCTION calcSumOperFacilityWatMassDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcSumOperFacilityWatMassDay, WNDS, WNPS, RNPS);


FUNCTION calcSumOperFacilityCondMassDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcSumOperFacilityCondMassDay, WNDS, WNPS, RNPS);


END EcBp_Facility_Theoretical;