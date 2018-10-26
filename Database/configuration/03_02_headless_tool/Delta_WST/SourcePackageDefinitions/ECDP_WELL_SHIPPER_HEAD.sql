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
** Created  : 10.05.2000  Carl-Fredrik S�sen
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

--

FUNCTION getShipperGasFraction(
	--p_sysnam   VARCHAR2,
	--p_facility VARCHAR2,
	--p_well_no  VARCHAR2,
	p_object_id  well.object_id%TYPE,
  p_shipper  VARCHAR2,
	p_daytime  DATE)

RETURN NUMBER;

--

FUNCTION getShipperOilFraction(
	--p_sysnam   VARCHAR2,
	--p_facility VARCHAR2,
	--p_well_no  VARCHAR2,
	p_object_id  well.object_id%TYPE,
  p_shipper  VARCHAR2,
	p_daytime  DATE)

RETURN NUMBER;

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

--

FUNCTION getShipperWatFraction(
	--p_sysnam   VARCHAR2,
	--p_facility VARCHAR2,
	--p_well_no  VARCHAR2,
	p_object_id  well.object_id%TYPE,
  p_shipper  VARCHAR2,
	p_daytime  DATE)

RETURN NUMBER;

END EcDp_Well_Shipper;