CREATE OR REPLACE PACKAGE BODY EcDp_Fcst_Fluid IS
/****************************************************************
** Package        :  EcDp_Fcst_Fluid body part.
**
** $Revision: 1.1 $
**
** Purpose        :  This package is responsible for data access to
**                   fluid analysis figures for any analysis object.
**
** Documentation  :  www.energy-components.com
**
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 29.07.2014 dhavaalo   ECPD-31274-Initial version
** 01.07.2014 dhavaalo   ECPD-30776-Component analysis screens won't insert records if there are duplicate component set list with different daytime

*****************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : createCompSetForAnalysis
-- Description  : Instantiates all hydrocarbon components associated with the current component set
--                into the fluid composition and assigns them to the analysis given.
--
--
--
-- Preconditions:
-- Postcondition: Possibly uncommitted changes.
--
-- Using Tables: fcst_fluid_component, COMP_SET_LIST
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour: Only instantiate if analysis exist and there is no records in the fcst_fluid_component table
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE createCompSetForAnalysis(p_comp_set VARCHAR2 DEFAULT NULL, p_analysis_no NUMBER, p_daytime DATE, p_user_id VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

CURSOR c_current_components(cp_comp_set varchar2) IS
SELECT c.component_no,MAX(c.daytime)
FROM comp_set_list c
WHERE c.component_set = cp_comp_set
AND p_daytime >= c.daytime AND (p_daytime < c.end_date OR c.end_date IS NULL)
GROUP BY c.component_no;

   ln_no_components NUMBER;
   lr_analysis               fcst_object_fluid%ROWTYPE;
   lv2_comp_set              VARCHAR2(16);

BEGIN

   lr_analysis := Ec_fcst_object_fluid.row_by_pk(p_analysis_no);
   --get the configured component set, if null then use the default from the parameter
   lv2_comp_set := nvl(ecbp_fluid_analysis.getCompSet(lr_analysis.object_class_name , lr_analysis.object_id , p_daytime, p_comp_set),p_comp_set);

   ln_no_components := 0;

   IF Ec_fcst_object_fluid.analysis_type(p_analysis_no) IS NOT NULL THEN

      SELECT count(component_no)
      INTO ln_no_components
      FROM fcst_fluid_component
      WHERE analysis_no = p_analysis_no;

      IF ln_no_components = 0 THEN

         FOR cur_rec IN c_current_components(lv2_comp_set) LOOP

            INSERT INTO fcst_fluid_component (component_no, analysis_no, created_by)
            VALUES (cur_rec.component_no, p_analysis_no, p_user_id);

         END LOOP;

      END IF;

   END IF;

END createCompSetForAnalysis;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : calcHeatingValue
-- Description  : Return the sum of all Components mol_frac * GCV
-- Preconditions:
-- Postcondition:
--
-- Using Tables:
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour
---------------------------------------------------------------------------------------------------
FUNCTION calcHeatingValue(p_analysis_no NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_comp_list IS
SELECT component_no, mol_pct
FROM fcst_fluid_component fac
WHERE analysis_no=p_analysis_no
AND mol_pct IS NOT NULL;

ln_gcv             NUMBER;
ln_comp_mol_sum    NUMBER := 0;
lr_analysis        fcst_object_fluid%ROWTYPE;
lv2_standard_code  constant_standard.object_code%TYPE;
lv2_phase          VARCHAR2(32);
lv2_object_id      VARCHAR2(32);
ln_energy_sum      NUMBER;

BEGIN
  lr_analysis       := Ec_fcst_object_fluid.row_by_pk(p_analysis_no);
  lv2_standard_code := EcDp_System.getAttributeText(lr_analysis.daytime, 'STANDARD_CODE');
  lv2_phase         := ec_strm_version.stream_phase(lr_analysis.object_id, lr_analysis.daytime, '<=');

  IF lv2_phase = 'GAS' THEN
    -- check to see if the stream has a dedicated standard to use other than default Standard Code
    lv2_object_id := Nvl(ec_strm_version.ref_gas_const_std_id(lr_analysis.object_id, lr_analysis.daytime,'<='),ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code));
  ELSE -- use default
    lv2_object_id := ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code);
  END IF;

  -- get the total mol_pct for all components. Should add up to 100 if analysis is normalized.
  ln_comp_mol_sum := 0;
  FOR cur_comp IN c_comp_list LOOP
    ln_comp_mol_sum := ln_comp_mol_sum + cur_comp.mol_pct;
  END LOOP;
  -- mols of components are normalized, converted to energy and the total is summed.
  IF ln_comp_mol_sum <> 0 THEN
    ln_energy_sum:=0;
    FOR cur_comp IN c_comp_list LOOP
      -- GCV is stored in component constant table, or if it is the Cn+ component the GCV will be stored on the analysis.
      ln_gcv := NVL(ec_component_constant.ideal_gcv(lv2_object_id,cur_comp.component_no,lr_analysis.daytime,'<='),
                    Ec_fcst_object_fluid.cnpl_gcv(p_analysis_no));
      IF cur_comp.mol_pct>0 AND ln_gcv>=0 THEN
        ln_energy_sum := ln_energy_sum + (cur_comp.mol_pct / ln_comp_mol_sum * ln_gcv);
      ELSIF cur_comp.mol_pct>0 AND ln_gcv IS NULL THEN
        ln_energy_sum := NULL; -- cannot calculate when we are missing GCV for one component having mol% > 0.
      END IF;
    END LOOP;
  END IF;

  RETURN ln_energy_sum;

END calcHeatingValue;

END EcDp_Fcst_Fluid;