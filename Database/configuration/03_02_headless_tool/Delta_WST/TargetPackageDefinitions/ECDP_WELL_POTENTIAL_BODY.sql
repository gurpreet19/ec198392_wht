CREATE OR REPLACE PACKAGE BODY EcDp_Well_Potential IS

/****************************************************************
** Package        :  EcDp_Well_Potential, header part
**
** $Revision: 1.8 $
**
** Purpose        :  Finds well potential properties.
**
** Documentation  :  www.energy-components.com
**
** Created  : 11.05.2000  Carl-Fredrik Sørensen
**
** Modification history:
**
** Date       Whom       Change description:
** ------     -----      --------------------------------------
** 18.02.2001  ØJ        Added function getInterpolatedOilProdPot(..)
** 11.08.2004 mazrina    removed sysnam and update as necessary
** 18.02.2005 Hang       Direct call to Constant like EcDp_Well_Type.WATER_GAS_INJECTOR is replaced
**                       with new function of EcDp_Well_Type.isWaterInjector as per enhancement for TI#1874.
** 21.02.2005 DN         Fixed syntax errors.
** 01.12.2005 DN         Function getInterpolatedOilProdPot moved from EcDp_Well_Potential to EcDp_Well_Estimate.
** 31.12.2008 sharawan   ECPD-10416:Replaced all references to EcDp_Type.pb_comp_number%TYPE with NUMBER in functions
**                       getConProductionPotential, getGasInjectionPotential, getOilProductionPotential, getWatInjectionPotential, getWatProductionPotential.
*****************************************************************/

------------------------------------------------------------------
-- Function:    getConProductionPotential
-- Description: Returns the valid condensate production potential
------------------------------------------------------------------
FUNCTION getConProductionPotential(
	--p_sysnam   VARCHAR2,
	--p_facility VARCHAR2,
	--p_well_no  VARCHAR2,
	p_object_id well.object_id%TYPE,
  p_daytime  DATE)

RETURN NUMBER IS

ln_return_val NUMBER;

BEGIN

   -- applies only to GP wells
    --IF (EcDp_Well.getWellType(
   		--p_sysnam,
   		--p_facility,
   		--p_well_no,
   		--p_object_id,
      --p_daytime) = EcDp_Well_Type.GAS_PRODUCER) THEN

    IF ec_well_version.isGasProducer(p_object_id,p_daytime,'<=') = ECDP_TYPE.IS_TRUE THEN

	   -- get data
	   ln_return_val := ec_well_potential.cond_rate(
	   							--p_sysnam,
	   							--p_facility,
	   							--p_well_no,
	   							p_object_id,
                  p_daytime,
	   							'<=');

   END IF;

   RETURN ln_return_val;

END getConProductionPotential;


------------------------------------------------------------------
-- Function:    getGasInjectionPotential
-- Description: Returns the valid water injection potential
------------------------------------------------------------------
FUNCTION getGasInjectionPotential (
	--p_sysnam   VARCHAR2,
	--p_facility VARCHAR2,
	--p_well_no  VARCHAR2,
	p_object_id well.object_id%TYPE,
  p_daytime  DATE)

RETURN NUMBER IS

ln_return_val NUMBER;

BEGIN

   -- applies only to GI or WG wells
   --IF (EcDp_Well.getWellType(
   		--p_sysnam,
   		--p_facility,
   		--p_well_no,
   		--p_object_id,
      --p_daytime) IN (EcDp_Well_Type.GAS_INJECTOR,
                      --EcDp_Well_Type.WATER_GAS_INJECTOR)) THEN

   IF ec_well_version.isGasInjector(p_object_id,p_daytime,'<=') = ECDP_TYPE.IS_TRUE AND
      ec_well_version.isWaterInjector(p_object_id,p_daytime,'<=') = ECDP_TYPE.IS_TRUE THEN

     -- get data
     ln_return_val := ec_well_potential.gas_inj_rate(p_object_id, p_daytime,  '<=');

   END IF;

   RETURN ln_return_val;

END getGasInjectionPotential;



------------------------------------------------------------------
-- Function:    getOilProductionPotential
-- Description: Returns the valid oil production potential
------------------------------------------------------------------

FUNCTION getOilProductionPotential (
	--p_sysnam   VARCHAR2,
	--p_facility VARCHAR2,
	--p_well_no  VARCHAR2,
	p_object_id well.object_id%TYPE,
  p_daytime  DATE)

RETURN NUMBER IS

ln_return_val NUMBER;

BEGIN

   -- applies only to OP wells
   --IF (EcDp_Well.getWellType(
   		--p_sysnam,
   		--p_facility,
   		--p_well_no,
   		--p_object_id,
      --p_daytime) = EcDp_Well_Type.OIL_PRODUCER) THEN

   IF ec_well_version.isOilProducer(p_object_id,p_daytime,'<=') = ECDP_TYPE.IS_TRUE THEN

	   ln_return_val := ec_well_potential.oil_rate(p_object_id, p_daytime,'<=');

   END IF;

   RETURN ln_return_val;

END getOilProductionPotential;

------------------------------------------------------------------
-- Function:    getWatInjectionPotential
-- Description: Returns the valid water injection potential
------------------------------------------------------------------
FUNCTION getWatInjectionPotential (
	--p_sysnam   VARCHAR2,
	--p_facility VARCHAR2,
	--p_well_no  VARCHAR2,
	p_object_id well.object_id%TYPE,
  p_daytime  DATE)

RETURN NUMBER IS

ln_return_val NUMBER;

BEGIN

   -- applies only to WI and WG wells

   --IF (EcDp_Well.getWellType(
        	--p_sysnam,
   		--p_facility,
   		--p_well_no,
   		--p_object_id,
      --p_daytime) IN (
        --EcDp_Well_Type.WATER_INJECTOR,
        --EcDp_Well_Type.WATER_GAS_INJECTOR)) THEN
   IF ec_well_version.isWaterInjector(p_object_id,p_daytime,'<=') = ECDP_TYPE.IS_TRUE AND
      ec_well_version.isGasInjector(p_object_id,p_daytime,'<=') = ECDP_TYPE.IS_TRUE THEN

     -- get data
     ln_return_val := ec_well_potential.water_inj_rate(p_object_id, p_daytime, '<=');

   END IF;

   RETURN ln_return_val;

END getWatInjectionPotential;



------------------------------------------------------------------
-- Function:    getWatProductionPotential
-- Description: Returns the valid water production potential
------------------------------------------------------------------
FUNCTION getWatProductionPotential (
	--p_sysnam   VARCHAR2,
	--p_facility VARCHAR2,
	--p_well_no  VARCHAR2,
	p_object_id well.object_id%TYPE,
  p_daytime  DATE)

RETURN NUMBER IS

ln_return_val NUMBER;

BEGIN

   ln_return_val := ec_well_potential.water_prod_rate(
   							--p_sysnam,
   							--p_facility,
   							--p_well_no,
   							p_object_id,
                p_daytime,
   							'<=');

   RETURN ln_return_val;

END getWatProductionPotential;


END EcDp_Well_Potential;