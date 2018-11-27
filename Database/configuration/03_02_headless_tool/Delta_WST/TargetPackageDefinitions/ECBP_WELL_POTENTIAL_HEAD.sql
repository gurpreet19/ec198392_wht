CREATE OR REPLACE PACKAGE EcBp_Well_Potential IS

/****************************************************************
** Package        :  EcBp_Well_Potential, header part
**
** $Revision: 1.16 $
**
** Purpose        :  Finds well potential using source-method
**
** Documentation  :  www.energy-components.com
**
** Created  : 12.07.2000  Ådne Bakkane
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
** 1.0      11.08.2004 mazrina    removed sysnam and update as necessary
** 1.3	    28.02.2005 kaurrnar	Removed deadcodes
** 1.4	    22.04.2005 kaurrnar	Added new function calcDayWellDefermentVol
**          03.06.2005 ROV      Tracker #1822:Renamed function calcDayWellDefermentVol to calcDayWellProdDefermentVol
**                              to differentiate between production and injection.
** 1.5	    08.11.2005 bohhhron TI#2626 : Added new functions findGasLiftPotential and findDiluentPotential
**          05.12.2004 DN       Fixed pragmas on functions findGasLiftPotential and findDiluentPotential.
** 1.6      22.08.2007 leongsei Added new function findSteamInjectionPotential
**          06.09.2007 rajarsar ECPD-6264 Added new function findOilMassProdPotential,findGasMassProdPotential, findCondMassProdPotential, findWaterMassProdPotential, calcDayWellProdDefermentMass
**          10.10.2007 rajarsar ECPD-6313: Updated calcDayWellProdDefermentVol to support new deferment version PD.0006
**          26.08.2008 rajarsar ECPD-9038: Added new function: findCo2InjectionPotential
**          08-06-2011 leongwen ECPD-17812: EcBp_Well_Potential Incorrect input date for decline of well plan potentials
*****************************************************************/

--

FUNCTION findConProductionPotential (
        p_object_id        well.object_id%TYPE,
        p_daytime          DATE,
        p_potential_method VARCHAR2 DEFAULT NULL,
        p_decline_flag VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(findConProductionPotential, WNDS, WNPS, RNPS);

--

FUNCTION findGasInjectionPotential (
        p_object_id        well.object_id%TYPE,
        p_daytime          DATE,
        p_potential_method VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(findGasInjectionPotential, WNDS, WNPS, RNPS);

--

FUNCTION findOilProductionPotential (
        p_object_id        well.object_id%TYPE,
        p_daytime          DATE,
        p_potential_method VARCHAR2 DEFAULT NULL,
        p_decline_flag VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(findOilProductionPotential, WNDS, WNPS, RNPS);

--

FUNCTION findGasProductionPotential (
        p_object_id        well.object_id%TYPE,
        p_daytime          DATE,
        p_potential_method VARCHAR2 DEFAULT NULL,
        p_decline_flag VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(findGasProductionPotential, WNDS, WNPS, RNPS);

--

FUNCTION findWatInjectionPotential (
        p_object_id        well.object_id%TYPE,
        p_daytime          DATE,
        p_potential_method VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(findWatInjectionPotential, WNDS, WNPS, RNPS);

--

FUNCTION findSteamInjectionPotential (
        p_object_id        well.object_id%TYPE,
        p_daytime          DATE,
        p_potential_method VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(findSteamInjectionPotential , WNDS, WNPS, RNPS);

--

FUNCTION findWatProductionPotential (
        p_object_id        well.object_id%TYPE,
        p_daytime          DATE,
        p_potential_method VARCHAR2 DEFAULT NULL,
        p_decline_flag VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(findWatProductionPotential, WNDS, WNPS, RNPS);

--

FUNCTION findGasLiftPotential (
        p_object_id        well.object_id%TYPE,
        p_daytime          DATE,
        p_potential_method VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(findGasLiftPotential, WNDS, WNPS, RNPS);

--

FUNCTION findDiluentPotential (
        p_object_id        well.object_id%TYPE,
        p_daytime          DATE,
        p_potential_method VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(findDiluentPotential, WNDS, WNPS, RNPS);


--
FUNCTION findOilMassProdPotential (
        p_object_id        well.object_id%TYPE,
        p_daytime          DATE,
        p_potential_method VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(findOilMassProdPotential, WNDS, WNPS, RNPS);


--
FUNCTION findGasMassProdPotential (
        p_object_id        well.object_id%TYPE,
        p_daytime          DATE,
        p_potential_method VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(findGasMassProdPotential, WNDS, WNPS, RNPS);

--
FUNCTION findCondMassProdPotential (
        p_object_id        well.object_id%TYPE,
        p_daytime          DATE,
        p_potential_method VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(findCondMassProdPotential, WNDS, WNPS, RNPS);


--
FUNCTION findWaterMassProdPotential (
        p_object_id        well.object_id%TYPE,
        p_daytime          DATE,
        p_potential_method VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(findWaterMassProdPotential, WNDS, WNPS, RNPS);

--

FUNCTION calcDayWellProdDefermentVol (
        p_object_id     well.object_id%TYPE,
        p_daytime       DATE,
        p_phase         VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(calcDayWellProdDefermentVol, WNDS, WNPS, RNPS);

--

FUNCTION calcDayWellProdDefermentMass (
        p_object_id     well.object_id%TYPE,
        p_daytime       DATE,
        p_phase         VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(calcDayWellProdDefermentMass, WNDS, WNPS, RNPS);

--

FUNCTION findCo2InjectionPotential (
        p_object_id        well.object_id%TYPE,
        p_daytime          DATE,
        p_potential_method VARCHAR2 DEFAULT NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(findCo2InjectionPotential , WNDS, WNPS, RNPS);

--

FUNCTION findObjPlanMaxDaytime (
        p_object_id        well.object_id%TYPE,
        p_daytime          DATE,
        p_class_name       VARCHAR2)

RETURN DATE;

PRAGMA RESTRICT_REFERENCES(findObjPlanMaxDaytime , WNDS, WNPS, RNPS);

END EcBp_Well_Potential;