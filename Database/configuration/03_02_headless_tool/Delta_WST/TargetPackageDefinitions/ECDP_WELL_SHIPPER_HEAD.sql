CREATE OR REPLACE PACKAGE EcDp_Well_Shipper IS

/****************************************************************
** Package        :  EcDp_Well_Shipper, header part
**
** $Revision: 1.2 $
**
** Purpose        :  Finds well shipper properties.
**
** Documentation  :  www.energy-components.com
**
** Created  : 10.05.2000  Carl-Fredrik Sørensen
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
** 1.1      11.08.2004 mazrina    removed sysnam and update as necessary
*****************************************************************/

FUNCTION getShipperConFraction(
	--p_sysnam   VARCHAR2,
	--p_facility VARCHAR2,
	--p_well_no  VARCHAR2,
	p_object_id  well.object_id%TYPE,
  p_shipper  VARCHAR2,
	p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getShipperConFraction, WNDS, WNPS, RNPS);

--

FUNCTION getShipperGasFraction(
	--p_sysnam   VARCHAR2,
	--p_facility VARCHAR2,
	--p_well_no  VARCHAR2,
	p_object_id  well.object_id%TYPE,
  p_shipper  VARCHAR2,
	p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getShipperGasFraction, WNDS, WNPS, RNPS);

--

FUNCTION getShipperOilFraction(
	--p_sysnam   VARCHAR2,
	--p_facility VARCHAR2,
	--p_well_no  VARCHAR2,
	p_object_id  well.object_id%TYPE,
  p_shipper  VARCHAR2,
	p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getShipperOilFraction, WNDS, WNPS, RNPS);

--

FUNCTION getShipperPhaseFraction(
	--p_sysnam   VARCHAR2,
	--p_facility VARCHAR2,
	--p_well_no  VARCHAR2,
	p_object_id  well.object_id%TYPE,
  p_shipper  VARCHAR2,
	p_daytime  DATE,
	p_phase    VARCHAR2)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getShipperPhaseFraction, WNDS, WNPS, RNPS);

--

FUNCTION getShipperWatFraction(
	--p_sysnam   VARCHAR2,
	--p_facility VARCHAR2,
	--p_well_no  VARCHAR2,
	p_object_id  well.object_id%TYPE,
  p_shipper  VARCHAR2,
	p_daytime  DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getShipperWatFraction, WNDS, WNPS, RNPS);

END EcDp_Well_Shipper;