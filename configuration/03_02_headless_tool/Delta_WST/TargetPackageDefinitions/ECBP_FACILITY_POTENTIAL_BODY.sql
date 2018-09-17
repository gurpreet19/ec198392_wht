CREATE OR REPLACE PACKAGE BODY EcBp_Facility_Potential IS

/****************************************************************
** Package        :  EcBp_Facility_Potential, body part
**
** $Revision: 1.6 $
**
** Purpose        :  Get potentials for facility
**
** Documentation  :  www.energy-components.com
**
** Created  : 12.07.2000  Ådne Bakkane
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
** 4.1	    27.07.00  UMF   find...Potential functions return min(..)
** 4.2	    28.03.01  KEJ   Documented functions and procedures.of the other four potentials
**
**          10.08.04  Toha  Replaced sysnam + facility to object_id and made changes as necessary.
**	    01.03.05 kaurrnar	Removed deadcodes
**				Removed reference to xxx.getAttributeValue function
**	    2005-03-04 kaurrnar	Removed getOilInletPotential, findOilPotential, getGasInletPotential,
**				getOilProcessPotential, getGasProcessPotential, getOilExportPotential,
**				getGasExportPotential, findGasPotential and findOilExportNomination function
**        30.12.2008 sharawan ECPD-10416:Replaced all references to EcDp_Type.pb_comp_number%TYPE with NUMBER in functions getOilWellPotential, getGasWellPotential.
*****************************************************************/


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getOilWellPotential                                                            --
-- Description    : Returns sum of wells oil production potential                                  --
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : pwel_day_status                                                                --
--                                                                                                 --
-- Using functions: EcBp_Well_Potential.findOilProductionPotential                                 --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------


FUNCTION getOilWellPotential(
    p_object_id   production_facility.object_id%TYPE,
    p_daytime     DATE)

RETURN NUMBER
--<EC-DOC>
IS

CURSOR c_all_pwels IS
SELECT p.object_id
  FROM pwel_day_status p, well w
 WHERE ecdp_well.getFacility(w.object_id, ecdp_date_time.getCurrentSysdate) = p_object_id
   AND w.object_id = p.object_id
   AND daytime = p_daytime;


ln_ret_val NUMBER;
ln_sum_potential NUMBER;

BEGIN

	ln_sum_potential := 0;

	FOR cur_w IN c_all_pwels
	LOOP

   		ln_sum_potential := ln_sum_potential + EcBp_Well_Potential.findOilProductionPotential (
										cur_w.object_id,
										p_daytime);


	END LOOP;

   ln_ret_val := ln_sum_potential;

   RETURN ln_ret_val;

END getOilWellPotential;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getGasWellPotential                                                            --
-- Description    : Returns sum of wells gas production potential                                  --
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : pwel_day_status                                                                --
--                                                                                                 --
-- Using functions: EcBp_Well_Potential.findGasProductionPotential                                 --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------

FUNCTION getGasWellPotential(
    p_object_id   production_facility.object_id%TYPE,
    p_daytime     DATE)

RETURN NUMBER
--<EC-DOC>
IS

CURSOR c_all_pwels IS
SELECT p.object_id
  FROM pwel_day_status p, well w
 WHERE ecdp_well.getFacility(w.object_id, ecdp_date_time.getCurrentSysdate) = p_object_id
   AND w.object_id = p.object_id
   AND daytime = p_daytime;


ln_ret_val NUMBER;
ln_sum_potential NUMBER;

BEGIN

	ln_sum_potential := 0;

	FOR cur_w IN c_all_pwels
	LOOP

   	ln_sum_potential := ln_sum_potential + EcBp_Well_Potential.findGasProductionPotential (
							cur_w.object_id,
							p_daytime);

	END LOOP;

   ln_ret_val := ln_sum_potential;

   RETURN ln_ret_val;

END getGasWellPotential;


END EcBp_Facility_Potential;