CREATE OR REPLACE PACKAGE EcBp_Facility_Potential IS

/****************************************************************
** Package        :  EcBp_Facility_Potential, header part
**
** $Revision: 1.6 $
**
** Purpose        :  Get potentials for facility
**
** Documentation  :  www.energy-components.com
**
** Created  : 13.07.2000  Ådne Bakkane
**
** Modification history:
**
** Version  Date         Whom  Change description:
** -------  ---------    ----- --------------------------------------
**          2004-08-10   Toha   Replaced sysnam + facility to object_id in functions' signatures.
**	    2005-03-01 kaurrnar	Removed deadcodes
**	    2005-03-04 kaurrnar	Removed getOilInletPotential, findOilPotential, getGasInletPotential,
**				getOilProcessPotential, getGasProcessPotential, getOilExportPotential,
**				getGasExportPotential, findGasPotential and findOilExportNomination function
*****************************************************************/

--

FUNCTION getOilWellPotential (
    p_object_id        production_facility.object_id%TYPE,
    p_daytime          DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getOilWellPotential, WNDS, WNPS, RNPS);

--

FUNCTION getGasWellPotential (
    p_object_id        production_facility.object_id%TYPE,
    p_daytime          DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getGasWellPotential, WNDS, WNPS, RNPS);

--

END EcBp_Facility_Potential;