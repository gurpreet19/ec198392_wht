CREATE OR REPLACE PACKAGE BODY EcDp_Well_Company IS
/****************************************************************
** Package        :  EcDp_Well_Company, body part
**
** $Revision: 1.16 $
**
** Purpose        :  Finds well Company properties.
**
** Documentation  :  www.energy-components.com
**
** Created  : 09.05.2002  Frode Barstad
**
** Modification history:
**
** Date       Whom    Change description:
** --------   -----   --------------------------------------
** 26112002   DN       Replaced mthlib with EcDp_type
** 11.08.2004 mazrina  removed sysnam and update as necessary
** 24.02.2005 Toha     Cleanup dead codes, #1965 performance updates
** 04.03.2005 kaurrnar Removed getCompanyPhaseFraction, getCompanyOilFraction, getCompanyConFraction,
**		       getCompanyWatFraction and getCompanyGasFraction function
** 13.04.2005 DN       Removed function getCompanyPhaseFracFromWellEst.
** 15.11.2005 DN       TI2742: Changed cursor in function getCompanyPhaseFracFromEqShare according to new table structure.
** 08.11.2006 zakiiari TI4512: Updated getCompanyPhaseFracFromEqShare
** 14.05.2014  deshpadi  ECPD-26763: Modified cursor in function getCompanyPhaseFracFromEqShare to access RESB_BLOCK_FORMATION_ID, that has been moved to
                                     PERF_INTERVAL_VERSION table from PERF_INTERVAL table.
*****************************************************************/



--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : getCompanyPhaseFracFromEqShare
-- Description    : Returns the Company fraction of a well stream phase.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : PERF_INTERVAL, WEBO_INTERVAL, RESV_BLOCK_FORMATION, COMMERCIAL_ENTITY, EQUITY_SHARE
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION getCompanyPhaseFracFromEqShare(
	p_object_id     well.object_id%TYPE,
 	p_company_id	VARCHAR2,
	p_daytime	DATE,
	p_phase	  	VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_comm_entity IS
SELECT coent.object_code
FROM
   webo_interval wbi,
   perf_interval pi,
   perf_interval_version piv,
   resv_block_formation	rbf,
   rbf_version rbfv,
   commercial_entity coent,
   webo_bore wb
WHERE wbi.well_bore_id = wb.object_id
  AND wb.well_id = p_object_id
  AND pi.webo_interval_id = wbi.object_id
  --AND rbf.object_id = pi.resv_block_formation_id
  AND piv.object_id = pi.object_id
  AND rbf.object_id = piv.resv_block_formation_id
  AND coent.object_id = rbfv.commercial_entity_id
  AND rbfv.object_id = rbf.object_id
  AND p_daytime >= rbfv.daytime
  AND p_daytime < nvl(rbfv.end_date, p_daytime+1);


CURSOR c_equity (cp_shipper VARCHAR2, cp_company_id VARCHAR2, cp_daytime DATE) IS
SELECT party_share
FROM
   commercial_entity coent,
   coent_version cv,
   equity_share es,
   licence l,
   company c
WHERE coent.object_code = cp_shipper
  AND coent.object_id = cv.object_id
  AND cp_daytime >= cv.daytime
  AND cp_daytime < nvl(cv.end_date, cp_daytime+1)
  AND es.object_id = cv.licence_id
  AND es.company_id = c.object_id
  AND c.object_id = cp_company_id
  AND es.fluid_type	= p_phase
  AND es.daytime = ec_equity_share.prev_equal_daytime(
      es.object_id ,
      es.company_id,
      es.fluid_type,
      cp_daytime);

ln_shipper_contr 	NUMBER;
ln_company_contr 	NUMBER:= 0;
ln_eq_share 		NUMBER;
lv2_company 		company.object_id%TYPE;


BEGIN

	lv2_company := Nvl(p_company_id, EcDp_System.getDefaultCompanyNo );

   FOR CoentCur IN c_comm_entity LOOP

	   ln_shipper_contr := EcDp_Well_Shipper.GetShipperPhaseFraction(
         p_object_id,
         CoentCur.object_code,
         p_daytime,
         p_phase);

      FOR equityCur IN c_equity (CoentCur.object_code, lv2_company, p_daytime) LOOP
      	ln_eq_share := equityCur.party_share / 100;
   		-- add up
	   	ln_company_contr := ln_company_contr + (ln_shipper_contr * ln_eq_share);
		END LOOP;

   END LOOP;

   RETURN ln_company_contr;

END getCompanyPhaseFracFromEqShare;


END EcDp_Well_Company;