CREATE OR REPLACE PACKAGE EcBp_Facility_Theoretical IS

/****************************************************************
** Package        :  EcBp_Facility_Theoretical, header part
**
** $Revision: 1.13 $
**
** Purpose        :  Provides theoretical fluid values (rates etc)
**	                  for a given facility.
**
** Documentation  :  www.energy-components.com
**
** Created  : 14.01.2000  Carl-Fredrik S?sen
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
**        17.07.2012 musthram ECPD-21375: Added calcFacililtyCondMass and calcSumOperFacilityCondMassDay
**        29.04.2013 rajarsar ECPD-23618: Added getFacilityPhaseStdVolDay
**        09.05.2013 rajarsar ECPD-23618: Added getFacilityPhaseFactorDay
**        19.10.2015 dhavaalo ECPD-26566: Added getFacilityPhaseVolMonth
**        19.10.2015 kashisag ECPD-26565: Added getFacilityPhaseFactorDay
**        24.02.2017 singishi ECPD-43210: Added getFacilityMassFactorDay
**        15.03.2017 kashisag ECPD-42996: Updated function definition
*****************************************************************/

FUNCTION calcPlatformPhaseStdVolPeriod(
--	p_sysnam   VARCHAR2,
--	p_facility VARCHAR2,
    p_object_id       production_facility.object_id%TYPE,
	  p_from_date    DATE,
	  p_to_date      DATE,
	  p_phase    VARCHAR2)

RETURN NUMBER;

--

FUNCTION calcSubseaPhaseStdVolPeriod(
--	p_sysnam   VARCHAR2,
--	p_facility VARCHAR2,
    p_object_id       production_facility.object_id%TYPE,
    p_from_date    DATE,
    p_to_date      DATE,
    p_phase    VARCHAR2)

RETURN NUMBER;

--

FUNCTION calcFacilityWatDay(
--	p_sysnam   VARCHAR2,
--	p_facility VARCHAR2,
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION calcFacilityOilDay(
--	p_sysnam   VARCHAR2,
--	p_facility VARCHAR2,
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION calcFacilityGasDay(
--	p_sysnam   VARCHAR2,
--	p_facility VARCHAR2,
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION calcFacilityCondDay(
--	p_sysnam   VARCHAR2,
--	p_facility VARCHAR2,
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION calcFacilityWatInjDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION calcFacilityGasInjDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION calcFacilitySteamInjDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION calcFacilityGasLiftDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION calcFacilityDiluentDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION calcFacilityCO2Day(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)
RETURN NUMBER;


--

FUNCTION calcFacilityCO2InjDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)
RETURN NUMBER;


--

FUNCTION calcFacilityOilMassDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)
RETURN NUMBER;

--

FUNCTION calcFacilityGasMassDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)
RETURN NUMBER;

--

FUNCTION calcFacilityWatMassDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)
RETURN NUMBER;

FUNCTION calcFacilityCondMassDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)
RETURN NUMBER;

FUNCTION calcSumOperFacilityWatDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION calcSumOperFacilityOilDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION calcSumOperFacilityGasDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION calcSumOperFacilityCondDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION calcSumOperFacilityWatInjDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION calcSumOperFacilityGasInjDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION calcSumOperFacilitySteamInjDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION calcSumOperFacilityGasLiftDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION calcSumOperFacilityDiluentDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION calcSumOperFacilityCO2Day(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)
RETURN NUMBER;

--

FUNCTION calcSumOperFacilityCO2InjDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)
RETURN NUMBER;

--

FUNCTION calcSumOperFacilityOilMassDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)
RETURN NUMBER;

--

FUNCTION calcSumOperFacilityGasMassDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)
RETURN NUMBER;

--

FUNCTION calcSumOperFacilityWatMassDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)
RETURN NUMBER;


FUNCTION calcSumOperFacilityCondMassDay(
    p_object_id       production_facility.object_id%TYPE,
    p_daytime  DATE)
RETURN NUMBER;

FUNCTION getFacilityPhaseStdVolDay(p_object_id    VARCHAR2,
                          p_daytime      DATE,
                          p_type  VARCHAR2,
                          p_phase VARCHAR2) RETURN NUMBER;

FUNCTION getFacilityPhaseFactorDay(p_object_id    VARCHAR2,
                          p_daytime      DATE,
                          p_phase VARCHAR2) RETURN NUMBER;

FUNCTION getFacilityPhaseVolMonth(p_object_id    VARCHAR2,
                          p_daytime      DATE,
                          p_type  VARCHAR2,
                          p_phase VARCHAR2) RETURN NUMBER;

FUNCTION getFacilityPhaseVolDay(p_object_id    VARCHAR2,
                          p_daytime      DATE,
                          p_type  VARCHAR2,
                          p_phase VARCHAR2) RETURN NUMBER ;

FUNCTION getFacilityMassFactorDay(p_object_id    VARCHAR2,
                          p_daytime      DATE,
                          p_phase VARCHAR2) RETURN NUMBER;

END EcBp_Facility_Theoretical;