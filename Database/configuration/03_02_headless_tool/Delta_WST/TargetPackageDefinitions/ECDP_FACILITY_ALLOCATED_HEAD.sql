CREATE OR REPLACE PACKAGE EcDp_Facility_Allocated IS

/****************************************************************
** Package        :  EcDp_Facility_Allocated, header part
**
** $Revision: 1.3 $
**
** Purpose        :  Provides allocated fluid values (rates etc)
**	                  for a given facility.
**
** Documentation  :  www.energy-components.com
**
** Created  : 16.10.2000  Dagfinn Njå
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------  	----- --------------------------------------
**  4.0     30.03.01 RRA   Added rev info in package
**  4.0     15.05.01 DN    Added getSubseaPhaseStdVolPeriod and getPlatformPhaseStdVolPeriod.
**  4.1     10.08.04 Toha  removed sysnam and facility and changed to production_Facility.object_id instead.
**          24.09.09 aliassit ECPD-12558: Added sumFctyAllocProdVolume, sumFctyAllocProdMass, sumFctyAllocInjVolume, sumFctyAllocInjMass
*****************************************************************/

FUNCTION getFacilityPhaseStdVolPeriod(
--	p_sysnam   VARCHAR2,
--	p_facility VARCHAR2,
    p_object_id         production_facility.object_id%TYPE,
    p_from_date  DATE,
    p_to_date    DATE,
    p_phase    VARCHAR2)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getFacilityPhaseStdVolPeriod, WNDS, WNPS, RNPS);

FUNCTION getSubseaPhaseStdVolPeriod(
--	p_sysnam   VARCHAR2,
--	p_facility VARCHAR2,
    p_object_id        production_facility.object_id%TYPE,
    p_from_date  DATE,
    p_to_date    DATE,
    p_phase    VARCHAR2)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getSubseaPhaseStdVolPeriod, WNDS, WNPS, RNPS);

FUNCTION getPlatformPhaseStdVolPeriod(
--	p_sysnam   VARCHAR2,
--	p_facility VARCHAR2,
    p_object_id        production_facility.object_id%TYPE,
    p_from_date  DATE,
    p_to_date    DATE,
    p_phase    VARCHAR2)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getPlatformPhaseStdVolPeriod, WNDS, WNPS, RNPS);

FUNCTION sumFctyAllocProdVolume(
    p_object_id        production_facility.object_id%TYPE,
    p_phase    VARCHAR2,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (sumFctyAllocProdVolume, WNDS, WNPS, RNPS);

FUNCTION sumFctyAllocProdMass(
    p_object_id        production_facility.object_id%TYPE,
    p_phase    VARCHAR2,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (sumFctyAllocProdMass, WNDS, WNPS, RNPS);

FUNCTION sumFctyAllocInjVolume(
    p_object_id        production_facility.object_id%TYPE,
    p_phase    VARCHAR2,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (sumFctyAllocInjVolume, WNDS, WNPS, RNPS);

FUNCTION sumFctyAllocInjMass(
    p_object_id        production_facility.object_id%TYPE,
    p_phase    VARCHAR2,
    p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (sumFctyAllocInjMass, WNDS, WNPS, RNPS);


END EcDp_Facility_Allocated;