CREATE OR REPLACE PACKAGE EcDp_Well_Potential IS
/****************************************************************
** Package        :  EcDp_Well_Potential, header part
**
** $Revision: 1.4 $
**
** Purpose        :  Finds well potential properties.
**
** Documentation  :  www.energy-components.com
**
** Created  : 11.05.2000  Carl-Fredrik Sørensen
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- --------------------------------------
** 18.02.2001  ØJ        Added function getInterpolatedOilProdPot(..)
** 11.08.2004 mazrina    Removed sysnam and update as necessary
** 18.02.2005 Hang       Direct call to Constant like EcDp_Well_Type.WATER_GAS_INJECTOR is replaced
**                       with new function of EcDp_Well_Type.isWaterInjector as per enhancement for TI#1874.
** 01.12.2005 DN         Function getInterpolatedOilProdPot moved from EcDp_Well_Potential to EcDp_Well_Estimate.
*****************************************************************/

--

FUNCTION getConProductionPotential (
	--p_sysnam   VARCHAR2,
	--p_facility VARCHAR2,
	--p_well_no  VARCHAR2,
	p_object_id well.object_id%TYPE,
  p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getConProductionPotential, WNDS, WNPS, RNPS);

--

FUNCTION getGasInjectionPotential (
	---p_sysnam   VARCHAR2,
	---p_facility VARCHAR2,
	---p_well_no  VARCHAR2,
	p_object_id well.object_id%TYPE,
  p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getGasInjectionPotential, WNDS, WNPS, RNPS);

--

FUNCTION getOilProductionPotential (
	--p_sysnam   VARCHAR2,
	--p_facility VARCHAR2,
	--p_well_no  VARCHAR2,
	p_object_id well.object_id%TYPE,
  p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getOilProductionPotential, WNDS, WNPS, RNPS);

--

FUNCTION getWatInjectionPotential (
	--p_sysnam   VARCHAR2,
	--p_facility VARCHAR2,
	--p_well_no  VARCHAR2,
	p_object_id well.object_id%TYPE,
  p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getWatInjectionPotential, WNDS, WNPS, RNPS);

--

FUNCTION getWatProductionPotential (
	--p_sysnam   VARCHAR2,
	--p_facility VARCHAR2,
	--p_well_no  VARCHAR2,
	p_object_id well.object_id%TYPE,
  p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getWatProductionPotential, WNDS, WNPS, RNPS);

--


END EcDp_Well_Potential;