CREATE OR REPLACE PACKAGE BODY EcDp_Well_Shipper IS

/****************************************************************
** Package        :  EcDp_Well_Shipper, body part
**
** $Revision: 1.6 $
**
** Purpose        :  Finds well shipper properties.
**
** Documentation  :  www.energy-components.com
**
** Created  : 10.05.2000  Carl-Fredrik Sørensen
**
** Modification history:
**
** Date     Whom  Change description:
** ------   ----- --------------------------------------
** 11.08.2004 mazrina    removed sysnam and update as necessary
** 15.11.2005 DN         TI2742: Changed cursor in function getShipperPhaseFraction according to new table structure.
** 08.11.2006 zakiiari   TI4512: Updated getShipperPhaseFraction
*****************************************************************/


------------------------------------------------------------------
-- Function:    getShipperPhaseFraction
-- Description: Returns the shipper fraction of a well stream phase
------------------------------------------------------------------
FUNCTION getShipperPhaseFraction(
 p_object_id  well.object_id%TYPE,
 p_shipper  VARCHAR2,
 p_daytime  DATE,
 p_phase	  VARCHAR2)

RETURN NUMBER IS

CURSOR well_bores IS
SELECT object_id
FROM webo_bore
WHERE well_id = p_object_id
  AND p_daytime BETWEEN Nvl(start_date,p_daytime-1) AND Nvl(end_date,p_daytime+1);

CURSOR shipper_fraction(cp_object_id VARCHAR2, cp_wellbore VARCHAR2, cp_shipper VARCHAR2, cp_daytime DATE) IS
SELECT Sum(Nvl(w.COND_PCT,  0) / 100) CON_FRACTION,
		 Sum(Nvl(w.GAS_PCT,   0) / 100) GAS_FRACTION,
		 Sum(Nvl(w.OIL_PCT,   0) / 100) OIL_FRACTION,
		 Sum(Nvl(w.WATER_PCT, 0) / 100) WAT_FRACTION,
     Sum(Nvl(pis.COND_PCT,  0) / 100) P_CON_FRACTION,
		 Sum(Nvl(pis.GAS_PCT,   0) / 100) P_GAS_FRACTION,
		 Sum(Nvl(pis.OIL_PCT,   0) / 100) P_OIL_FRACTION,
		 Sum(Nvl(pis.WATER_PCT, 0) / 100) P_WAT_FRACTION
FROM webo_interval_gor w, webo_interval i, resv_block_formation r, rbf_version rbfv, webo_bore wb, perf_interval pi, perf_interval_gor pis
--WHERE i.resv_block_formation_id = r.object_id
WHERE pi.resv_block_formation_id = r.object_id
AND pi.webo_interval_id = i.object_id
AND i.well_bore_id      = wb.object_id
AND wb.well_id          = cp_object_id
AND wb.object_id      = cp_wellbore
AND rbfv.object_id = r.object_id
AND cp_daytime >= rbfv.daytime
AND cp_daytime < nvl(rbfv.end_date, cp_daytime+1)
AND rbfv.commercial_entity_id = cp_shipper
AND w.daytime           =
	 (SELECT Max(pis2.daytime)
     FROM perf_interval_gor pis2, perf_interval pi2
     WHERE pi2.object_id         = pi.object_id
     AND pi2.webo_interval_id    = pi.webo_interval_id
     AND pis2.daytime          <= cp_daytime);
/*
	 (SELECT Max(w2.daytime)
     FROM webo_interval_gor w2, webo_interval i2
     WHERE i2.object_id         = i.object_id
     AND i2.well_bore_id      = i.well_bore_id
     AND w2.daytime          <= cp_daytime);
*/

ln_webo_contr NUMBER;
ln_ship_contr NUMBER := 0; -- assume no contribution
ln_ship_webo_contr NUMBER;


BEGIN

   FOR WellBoreCur IN well_bores LOOP

	   -- determine total contribution of this well bore flow...
	   ln_webo_contr := 1; -- TODO: should call function that traverses the webo tree

		FOR ShipperFracCur IN shipper_fraction (p_object_id, WellBoreCur.object_id, p_shipper, p_daytime) LOOP

	  		-- determine shipper share of well bore flow
			IF (p_phase = EcDp_Phase.OIL) THEN

				ln_ship_webo_contr := ShipperFracCur.OIL_FRACTION * ShipperFracCur.P_OIL_FRACTION;

			ELSIF (p_phase = EcDp_Phase.GAS) THEN

				ln_ship_webo_contr := ShipperFracCur.GAS_FRACTION * ShipperFracCur.P_GAS_FRACTION;

			ELSIF (p_phase = EcDp_Phase.CONDENSATE) THEN

				ln_ship_webo_contr := ShipperFracCur.CON_FRACTION * ShipperFracCur.P_CON_FRACTION;

			ELSIF (p_phase = EcDp_Phase.WATER) THEN

				ln_ship_webo_contr := ShipperFracCur.WAT_FRACTION * ShipperFracCur.P_WAT_FRACTION;

			END IF;

		   IF ln_ship_webo_contr IS NULL THEN -- no contribution found for this shipper

		      ln_ship_webo_contr := 0;

		   END IF;

   		-- add up
	   	ln_ship_contr := ln_ship_contr + (ln_ship_webo_contr * ln_webo_contr);

		END LOOP;


   END LOOP;

   RETURN ln_ship_contr;

END getShipperPhaseFraction;


------------------------------------------------------------------
-- Function:    getShipperConFraction
-- Description: Returns the shipper fraction of the well stream condensate phase
------------------------------------------------------------------
FUNCTION getShipperConFraction(
	p_object_id  well.object_id%TYPE,
  p_shipper  VARCHAR2,
	p_daytime  DATE)

RETURN NUMBER IS

ln_ship_contr NUMBER := 0; -- assume no contribution

BEGIN

	ln_ship_contr := getShipperPhaseFraction(
								p_object_id,
				                p_shipper,
								p_daytime,
								EcDp_Phase.CONDENSATE);


   RETURN ln_ship_contr;

END getShipperConFraction;

------------------------------------------------------------------
-- Function:    getShipperGasFraction
-- Description: Returns the shipper fraction of the well stream gas phase
------------------------------------------------------------------

FUNCTION getShipperGasFraction(
	p_object_id  well.object_id%TYPE,
  p_shipper  VARCHAR2,
	p_daytime  DATE)

RETURN NUMBER IS

ln_ship_contr NUMBER := 0; -- assume no contribution

BEGIN

	ln_ship_contr := getShipperPhaseFraction(
								p_object_id,
				                p_shipper,
								p_daytime,
								EcDp_Phase.GAS);

   RETURN ln_ship_contr;

END getShipperGasFraction;

------------------------------------------------------------------
-- Function:    getShipperOilFraction
-- Description: Returns the shipper fraction of the well stream oil phase
------------------------------------------------------------------
FUNCTION getShipperOilFraction(
	p_object_id  well.object_id%TYPE,
  p_shipper  VARCHAR2,
	p_daytime  DATE)

RETURN NUMBER IS

ln_ship_contr NUMBER := 0; -- assume no contribution

BEGIN

	ln_ship_contr := getShipperPhaseFraction(
								p_object_id,
				                p_shipper,
								p_daytime,
								EcDp_Phase.OIL);


   RETURN ln_ship_contr;

END getShipperOilFraction;


------------------------------------------------------------------
-- Function:    getShipperWatFraction
-- Description: Returns the shipper fraction of the well stream water phase
------------------------------------------------------------------
FUNCTION getShipperWatFraction(
	p_object_id  well.object_id%TYPE,
  p_shipper  VARCHAR2,
	p_daytime  DATE)

RETURN NUMBER IS

ln_ship_contr NUMBER := 0; -- assume no contribution

BEGIN

	ln_ship_contr := getShipperPhaseFraction(
								p_object_id,
                p_shipper,
								p_daytime,
								EcDp_Phase.WATER);

   RETURN ln_ship_contr;


END getShipperWatFraction;

END EcDp_Well_Shipper;