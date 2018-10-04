CREATE OR REPLACE PACKAGE EcBp_Alloc_Values IS
/****************************************************************
** Package        :  EcBp_Alloc_Values, header part
**
** $Revision: 1.0 $
**
** Purpose        :  Provides allocated values for a given facility, Well-Hookup.
**
** Documentation  :  www.energy-components.com
**
** Created  : 10.02.2017  singishi
**
** Modification history:
**
** Version  Date        Whom         Change description:
** -------  ------      -----        --------------------------------------
** 1.0      10.02.2017  Singishi     ECPD-43210 New data Classes for Live data for Facility and Well Hookup

*****************************************************************/


FUNCTION calcSumOperFacilityGasAlloc(
    p_object_id production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;
--------------------

FUNCTION calcSumOperFacilityOilAlloc(
    p_object_id production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--------------------

FUNCTION calcSumOperFacilityWatAlloc(
    p_object_id production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

--------------------

FUNCTION calcSumOperFacilityCondAlloc(
    p_object_id production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;
---------------------
FUNCTION calcSumOperWellHookOilAlloc(
    p_object_id well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

-------------------
FUNCTION calcSumOperWellHookGasAlloc(
    p_object_id well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

-------------------
FUNCTION calcSumOperWellHookWatAlloc(
    p_object_id well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

-------------------
FUNCTION calcSumOperWellHookCondAlloc(
    p_object_id well_hookup.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;

-------------------
FUNCTION calcSumOperFctyOilMassAlloc(
    p_object_id production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;
--------------------
FUNCTION calcSumOperFctyGasMassAlloc(
    p_object_id production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;
--------------------
FUNCTION calcSumOperFctyCondMassAlloc(
    p_object_id production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;
--------------------
FUNCTION calcSumOperFctyWatMassAlloc(
    p_object_id production_facility.object_id%TYPE,
    p_daytime  DATE)

RETURN NUMBER;
--------------------



END EcBp_Alloc_Values;