CREATE OR REPLACE PACKAGE BODY EcBp_Comp_Analysis IS
/******************************************************************************************
** Package        :  EcBp_Comp_Analysis, body part
**
** $Revision: 1.14 $
**
** Purpose        :  Provides stream composition analysis methoda.
**
** Documentation  :  www.energy-components.com
**
** Created  : 02.04.2001  John Egil Harveland
**
** Modification history:
**
** Date       Whom  Change description:
** ------     ----- ----------------------------------------------------------------
** 02.04.2000  JEH  Initial Version
** 30.06.2001  AIE  Handle C7+ in calcCompWtPct,calcCompMolPct
** 18.11.2003  DN   Replaced sysdate with new function.
** 26.05.2004  DN   Converted to new analysis model. EC rel. 7.4.
**                  More generic mol_wt calculations.
** 02.06.2004  DN   Changed signature in calcCompWtPct and calcCompMolPct functions.
** 03.08.2004  kaurrnar     removed sysnam and stream_code and update as necessary
** 24.05.2005  DN   TI 2145: Added function calcTotMassFrac, calcTotMolFrac, calcCompMolFrac and calcCompMassFrac.
** 10.05.2005  SSK  Added functions calcTotMolPeriodAnFrac,calcTotPeriodAnMassFrac, calcCompMassFracPeriodAn, calcCompMolFracPeriodAn  and cursor c_tot_period_an_wt (TI 3364)
** 10.07.2008  rajarsar ECPD-8634: Updated function calcTotMolFrac, calcTotMolPeriodAnFrac, calcTotMassFrac, calcTotPeriodAnMassFrac, calcCompMassFrac, calcCompMassFracPeriodAn, calcCompMolFrac and calcCompMolFracPeriodAn
** 30.12.2008  sharawan ECPD-10416:Replaced all references to EcDp_Type.pb_comp_number%TYPE with NUMBER in functions calcCompMassFrac, calcCompMassFracPeriodAn.
** 06.05.2009  oonnnng ECPD-11625: Modified calcTotMolFrac(), calcTotMolPeriodAnFrac(), calcTotMassFrac(), calcTotPeriodAnMassFrac(), calcCompMassFrac(), calcCompMassFrac(),
**                     calcCompMassFracPeriodAn(), calcCompMolFrac(), calcCompMolFracPeriodAn() functions to handle analyses for well.
** 27.07.2009  oonnnng  ECPD-12334: Updated calcTotMolFrac(), calcTotMolPeriodAnFrac(), calcCompMolFrac)() and calcCompMolFracPeriodAn() functions to avoid division by zero.
** 18.10.2016  johamlei	ECPD-36303 Added procedure createCompMth().
** 05.10.2016 keskaash  ECPD-36304: Added procedure createCompOrfGas.
** 20.10.2016 keskaash  ECPD-36865: Modified createCompOrfGas and getStreamCompWtPct, added parameter p_fluid_state
** 27.02.2017  singishi ECPD-36028: Updated calcTotMolFrac, calcTotMolPeriodAnFrac, calcTotMassFrac, calcTotPeriodAnMassFrac, calcCompMassFrac, calcCompMassFracPeriodAn,  calcCompMolFrac, calcCompMolFracPeriodAn to handle 'RES','COND','LNG','NGL' phases
**29.08.2017 kashisag  ECPD-36104: Added new function findWellHCLiqPhase
**07.09.2017 kashisag  ECPD-36104: Added updated cursor condition for function findWellHCLiqPhase
******************************************************************************************/


CURSOR c_tot_wt(cp_analysis_no NUMBER) IS
SELECT *
FROM fluid_analysis_component
WHERE analysis_no = cp_analysis_no;

CURSOR c_tot_period_an_wt(cp_analysis_no NUMBER) IS
SELECT *
FROM strm_analysis_component
WHERE analysis_no = cp_analysis_no;

CURSOR c_comp IS
SELECT component_no comp_no
FROM hydrocarbon_component
ORDER BY sort_order;

CURSOR c_CompSet(cp_comp_set VARCHAR2) IS
SELECT component_no comp_no
FROM comp_set_list
WHERE component_set = cp_comp_set
ORDER BY ec_hydrocarbon_component.sort_order(component_no);

TYPE CompDataTYPE IS RECORD (
    comp_no         VARCHAR2(32)
   ,comp_mass       NUMBER
   ,comp_mol        NUMBER
   ,wt_frac         NUMBER
   ,mol_frac        NUMBER
   ,mol_wt          NUMBER
   ,density         NUMBER
   ,orf             NUMBER);

TYPE CompConstTYPE IS RECORD (
    comp_no         VARCHAR2(32)
   ,mol_wt          NUMBER
   ,compr_factor    NUMBER
   ,ideal_density   NUMBER
   ,sum_factor      NUMBER
   ,ideal_gcv       NUMBER
   ,ideal_ncv       NUMBER
   ,oil_density     NUMBER
   ,gas_density     NUMBER
   ,orf             NUMBER);

TYPE CompDataArray IS VARRAY(32) OF CompDataTYPE;
TYPE CompConstArray IS VARRAY(32) OF CompConstTYPE;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcTotMolFrac
-- Description    : Calculates the total mass fraction for an analysis.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : fluid_analysis_component
--
-- Using functions: ec_object_fluid_analysis.row_by_pk
--                  ec_component_constant.mol_wt
--                  EcDp_System.getAttributeText
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcTotMolFrac(p_analysis_no NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

   ln_return_val       NUMBER;
   lv2_standard_code   constant_standard.object_code%TYPE;
   lv2_object_id      VARCHAR2(32);
   lr_analyse_sample  object_fluid_analysis%ROWTYPE;
   ln_mol_frac        NUMBER;
   lv2_phase          VARCHAR2(32);
BEGIN

   lr_analyse_sample := ec_object_fluid_analysis.row_by_pk(p_analysis_no);
   lv2_standard_code := EcDp_System.getAttributeText(lr_analyse_sample.daytime, 'STANDARD_CODE');
   lv2_phase         := ec_strm_version.stream_phase(lr_analyse_sample.object_id, lr_analyse_sample.daytime, '<=');


   IF lv2_phase = 'GAS' THEN

      lv2_object_id := Nvl(ec_strm_version.ref_gas_const_std_id(lr_analyse_sample.object_id, lr_analyse_sample.daytime,'<='),ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code));

   ELSIF lv2_phase = 'OIL' THEN

      lv2_object_id := Nvl(ec_strm_version.ref_oil_const_std_id(lr_analyse_sample.object_id, lr_analyse_sample.daytime,'<='),ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code));

   ELSIF lv2_phase IN ('RES','COND','LNG','NGL') THEN

       lv2_object_id := Nvl(ec_strm_version.ref_oil_const_std_id(lr_analyse_sample.object_id, lr_analyse_sample.daytime,'<='),Nvl(ec_strm_version.ref_gas_const_std_id(lr_analyse_sample.object_id, lr_analyse_sample.daytime,'<='),ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code)));

   ELSE

      lv2_object_id := ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code);

   END IF;


   FOR cur_rec IN c_tot_wt(p_analysis_no) LOOP

      ln_mol_frac := cur_rec.wt_pct / ec_component_constant.mol_wt(lv2_object_id,
                                                                   cur_rec.component_no,
                                                                   lr_analyse_sample.daytime,
                                                                   '<=');

      IF ln_mol_frac IS NULL THEN

          IF cur_rec.wt_pct = 0 THEN

             ln_mol_frac := 0;

          ELSIF lr_analyse_sample.cnpl_mol_wt > 0 THEN

             ln_mol_frac := cur_rec.wt_pct / lr_analyse_sample.cnpl_mol_wt;

          END IF;

      END IF;

      IF ln_mol_frac IS NOT NULL THEN

         ln_return_val := Nvl(ln_return_val,0) + ln_mol_frac;

      END IF;

   END LOOP;

   RETURN ln_return_val;

END calcTotMolFrac;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcTotMolPeriodAnFrac
-- Description    : Calculates the total mass fraction for an analysis.
--
-- Preconditions  : Used from the business function Period Stream Gas Component Analysis
-- Postconditions :
--
-- Using tables   : strm_analysis_component
--
-- Using functions: ec_strm_analysis_event.row_by_pk
--                  ec_component_constant.mol_wt
--                  EcDp_System.getAttributeText
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcTotMolPeriodAnFrac(p_analysis_no NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

   ln_return_val       NUMBER;
   lv2_standard_code   constant_standard.object_code%TYPE;
   lv2_object_id varchar2(32);
   lr_analyse_sample strm_analysis_event%ROWTYPE;
   ln_mol_frac NUMBER;
   lv2_phase          VARCHAR2(32);
BEGIN

   lr_analyse_sample := ec_strm_analysis_event.row_by_pk(p_analysis_no);
   lv2_standard_code := EcDp_System.getAttributeText(lr_analyse_sample.daytime, 'STANDARD_CODE');
   lv2_phase         := ec_strm_version.stream_phase(lr_analyse_sample.object_id, lr_analyse_sample.daytime, '<=');


   IF lv2_phase = 'GAS' THEN

      lv2_object_id := Nvl(ec_strm_version.ref_gas_const_std_id(lr_analyse_sample.object_id, lr_analyse_sample.daytime,'<='),ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code));

   ELSIF lv2_phase = 'OIL' THEN

      lv2_object_id := Nvl(ec_strm_version.ref_oil_const_std_id(lr_analyse_sample.object_id, lr_analyse_sample.daytime,'<='),ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code));

   ELSIF lv2_phase IN ('RES','COND','LNG','NGL') THEN

       lv2_object_id := Nvl(ec_strm_version.ref_oil_const_std_id(lr_analyse_sample.object_id, lr_analyse_sample.daytime,'<='),Nvl(ec_strm_version.ref_gas_const_std_id(lr_analyse_sample.object_id, lr_analyse_sample.daytime,'<='),ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code)));

   ELSE

      lv2_object_id := ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code);

   END IF;


   FOR cur_rec IN c_tot_period_an_wt(p_analysis_no) LOOP

      ln_mol_frac := cur_rec.wt_pct / ec_component_constant.mol_wt(lv2_object_id,
                                                                   cur_rec.component_no,
                                                                   lr_analyse_sample.daytime,
                                                                   '<=');

      IF ln_mol_frac IS NULL THEN

          IF cur_rec.wt_pct = 0 THEN

             ln_mol_frac := 0;

          ELSIF lr_analyse_sample.cnpl_mol_wt > 0 THEN

             ln_mol_frac := cur_rec.wt_pct / lr_analyse_sample.cnpl_mol_wt;

          END IF;

      END IF;

      IF ln_mol_frac IS NOT NULL THEN

         ln_return_val := Nvl(ln_return_val,0) + ln_mol_frac;

      END IF;

   END LOOP;

   RETURN ln_return_val;

END calcTotMolPeriodAnFrac;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcTotMassFrac
-- Description    : Calculates the total mass fraction for an analysis.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : fluid_analysis_component
--
-- Using functions: ec_object_fluid_analysis.row_by_pk
--                  ec_component_constant.mol_wt
--                  EcDp_System.getAttributeText
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcTotMassFrac(p_analysis_no NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

   ln_return_val       NUMBER;
   lv2_standard_code   constant_standard.object_code%TYPE;
   lv2_object_id varchar2(32);
   lr_analyse_sample object_fluid_analysis%ROWTYPE;
   ln_mol_wt NUMBER;
   lv2_phase          VARCHAR2(32);

BEGIN

   lr_analyse_sample := ec_object_fluid_analysis.row_by_pk(p_analysis_no);
   lv2_standard_code := EcDp_System.getAttributeText(lr_analyse_sample.daytime, 'STANDARD_CODE');
   lv2_phase         := ec_strm_version.stream_phase(lr_analyse_sample.object_id, lr_analyse_sample.daytime, '<=');

   IF lv2_phase = 'GAS' THEN

      lv2_object_id := Nvl(ec_strm_version.ref_gas_const_std_id(lr_analyse_sample.object_id, lr_analyse_sample.daytime,'<='),ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code));

   ELSIF lv2_phase = 'OIL' THEN

      lv2_object_id := Nvl(ec_strm_version.ref_oil_const_std_id(lr_analyse_sample.object_id, lr_analyse_sample.daytime,'<='),ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code));

   ELSIF lv2_phase IN ('RES','COND','LNG','NGL') THEN

       lv2_object_id := Nvl(ec_strm_version.ref_oil_const_std_id(lr_analyse_sample.object_id, lr_analyse_sample.daytime,'<='),Nvl(ec_strm_version.ref_gas_const_std_id(lr_analyse_sample.object_id, lr_analyse_sample.daytime,'<='),ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code)));

   ELSE

      lv2_object_id := ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code);

   END IF;


   FOR cur_rec IN c_tot_wt(p_analysis_no) LOOP

      ln_mol_wt := cur_rec.mol_pct * ec_component_constant.mol_wt(lv2_object_id,
                                                             cur_rec.component_no,
                                                             lr_analyse_sample.daytime,
                                                             '<=');
      -- Try analysis to get residue components
      IF ln_mol_wt IS NULL THEN

           ln_mol_wt := cur_rec.mol_pct * lr_analyse_sample.cnpl_mol_wt;

      END IF;

      IF ln_mol_wt IS NOT NULL THEN

         ln_return_val := Nvl(ln_return_val,0) + ln_mol_wt;

      END IF;

   END LOOP;

   RETURN ln_return_val;

END calcTotMassFrac;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcTotPeriodAnMassFrac
-- Description    : Calculates the total mass fraction for an analysis.
--
-- Preconditions  : Used from the business function Period Stream Gas Component Analysis
-- Postconditions :
--
-- Using tables   : strm_analysis_component
--
-- Using functions: ec_strm_analysis_event.row_by_pk
--                  ec_component_constant.mol_wt
--                  EcDp_System.getAttributeText
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcTotPeriodAnMassFrac(p_analysis_no NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

   ln_return_val       NUMBER;
   lv2_standard_code   constant_standard.object_code%TYPE;
   lv2_object_id varchar2(32);
   lr_analyse_sample strm_analysis_event%ROWTYPE;
   ln_mol_wt NUMBER;
   lv2_phase          VARCHAR2(32);

BEGIN

   lr_analyse_sample := ec_strm_analysis_event.row_by_pk(p_analysis_no);
   lv2_standard_code := EcDp_System.getAttributeText(lr_analyse_sample.daytime, 'STANDARD_CODE');
   lv2_phase         := ec_strm_version.stream_phase(lr_analyse_sample.object_id, lr_analyse_sample.daytime, '<=');

   IF lv2_phase = 'GAS' THEN

      lv2_object_id := Nvl(ec_strm_version.ref_gas_const_std_id(lr_analyse_sample.object_id, lr_analyse_sample.daytime,'<='),ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code));

   ELSIF lv2_phase = 'OIL' THEN

      lv2_object_id := Nvl(ec_strm_version.ref_oil_const_std_id(lr_analyse_sample.object_id, lr_analyse_sample.daytime,'<='),ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code));

   ELSIF lv2_phase IN ('RES','COND','LNG','NGL') THEN

       lv2_object_id := Nvl(ec_strm_version.ref_oil_const_std_id(lr_analyse_sample.object_id, lr_analyse_sample.daytime,'<='),Nvl(ec_strm_version.ref_gas_const_std_id(lr_analyse_sample.object_id, lr_analyse_sample.daytime,'<='),ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code)));
   ELSE

      lv2_object_id := ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code);

   END IF;


   FOR cur_rec IN c_tot_period_an_wt(p_analysis_no) LOOP

      ln_mol_wt := cur_rec.mol_pct * ec_component_constant.mol_wt(lv2_object_id,
                                                             cur_rec.component_no,
                                                             lr_analyse_sample.daytime,
                                                             '<=');
      -- Try analysis to get residue components
      IF ln_mol_wt IS NULL THEN

           ln_mol_wt := cur_rec.mol_pct * lr_analyse_sample.cnpl_mol_wt;

      END IF;

      IF ln_mol_wt IS NOT NULL THEN

         ln_return_val := Nvl(ln_return_val,0) + ln_mol_wt;

      END IF;

   END LOOP;

   RETURN ln_return_val;

END calcTotPeriodAnMassFrac;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcCompWtPct
-- Description    : Provides a component weight for a mol fraction as percentage of the total weigth composition.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: EcDp_Fluid_Analysis.getAnalysisNumber
--                  calcCompMassFrac, calcTotMassFrac
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcCompWtPct(
   p_object_id          VARCHAR2,
   p_daytime            DATE,
   p_component_no       VARCHAR2,
   p_analysis_type      VARCHAR2,
   p_sampling_method    VARCHAR2,
   p_mol_pct            NUMBER)
RETURN NUMBER
--</EC-DOC>
IS
ln_analysis_no NUMBER;
ln_tot_wt NUMBER;
ln_ret_val NUMBER;

BEGIN

   ln_analysis_no := EcDp_Fluid_Analysis.getAnalysisNumber(p_object_id, p_analysis_type, p_sampling_method, p_daytime);

   IF ln_analysis_no IS NOT NULL THEN

      ln_tot_wt := calcTotMassFrac(ln_analysis_no);

      IF ln_tot_wt > 0 THEN -- Only numbers in R+. Avoid division by zero.

         ln_ret_val := 100 * calcCompMassFrac(p_object_id, p_daytime, p_component_no, p_analysis_type, p_sampling_method, p_mol_pct) / ln_tot_wt;

      END IF;

   END IF;

   RETURN ln_ret_val;

END calcCompWtPct;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcCompMassFrac
-- Description    : Provides a component weight for a mol fraction.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcCompMassFrac(
   p_object_id          VARCHAR2,
   p_daytime            DATE,
   p_component_no       VARCHAR2,
   p_analysis_type      VARCHAR2,
   p_sampling_method    VARCHAR2,
   p_mol_pct            NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

   ln_return_val       NUMBER;
   lv2_standard_code   constant_standard.object_code%TYPE;
   lv2_object_id varchar2(32);
   lr_analyse_sample object_fluid_analysis%ROWTYPE;
   lv2_phase          VARCHAR2(32);

BEGIN

   lv2_standard_code := EcDp_System.getAttributeText(p_daytime, 'STANDARD_CODE');
   lv2_phase         := ec_strm_version.stream_phase(p_object_id, p_daytime, '<=');

   IF lv2_phase = 'GAS' THEN

      lv2_object_id := Nvl(ec_strm_version.ref_gas_const_std_id(p_object_id, p_daytime,'<='),ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code));

   ELSIF lv2_phase = 'OIL' THEN

      lv2_object_id := Nvl(ec_strm_version.ref_oil_const_std_id(p_object_id, p_daytime,'<='),ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code));

   ELSIF lv2_phase IN ('RES','COND','LNG','NGL') THEN

       lv2_object_id := Nvl(ec_strm_version.ref_oil_const_std_id(p_object_id, p_daytime,'<='),Nvl(ec_strm_version.ref_gas_const_std_id(p_object_id, p_daytime,'<='),ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code)));
   ELSE

      lv2_object_id := ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code);

   END IF;


   ln_return_val := p_mol_pct * ec_component_constant.mol_wt(lv2_object_id,
                                                             p_component_no,
                                                             p_daytime,
                                                             '<=');
   -- Try analysis to get residue components
   IF ln_return_val IS NULL THEN

         lr_analyse_sample := EcDp_Fluid_Analysis.getAnalysisSample(p_object_id,
                                                                    p_analysis_type,
                                                                    p_sampling_method,
                                                                    p_daytime);

        ln_return_val := p_mol_pct * lr_analyse_sample.cnpl_mol_wt;

   END IF;

   RETURN ln_return_val;

END calcCompMassFrac;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcCompMassFracPeriodAn
-- Description    : Provides a component weight for a mol fraction.
--
-- Preconditions  : Used from the business function Period Stream Gas Component Analysis
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcCompMassFracPeriodAn(
   p_object_id            VARCHAR2,
   p_daytime              DATE,
   p_daytime_summer_time  VARCHAR2,
   p_component_no         VARCHAR2,
   p_analysis_type        VARCHAR2,
   p_sampling_method      VARCHAR2,
   p_mol_pct              NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

   ln_return_val       NUMBER;
   lv2_standard_code   constant_standard.object_code%TYPE;
   lv2_object_id varchar2(32);
   lr_analyse_sample strm_analysis_event%ROWTYPE;
   lv2_phase          VARCHAR2(32);

BEGIN

   lv2_standard_code := EcDp_System.getAttributeText(p_daytime, 'STANDARD_CODE');
   lv2_phase         := ec_strm_version.stream_phase(p_object_id, p_daytime, '<=');

   IF lv2_phase = 'GAS' THEN

      lv2_object_id := Nvl(ec_strm_version.ref_gas_const_std_id(p_object_id, p_daytime,'<='),ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code));

   ELSIF lv2_phase = 'OIL' THEN

      lv2_object_id := Nvl(ec_strm_version.ref_oil_const_std_id(p_object_id, p_daytime,'<='),ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code));

   ELSIF lv2_phase IN ('RES','COND','LNG','NGL') THEN

       lv2_object_id := Nvl(ec_strm_version.ref_oil_const_std_id(p_object_id, p_daytime,'<='),Nvl(ec_strm_version.ref_gas_const_std_id(p_object_id, p_daytime,'<='),ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code)));
   ELSE

      lv2_object_id := ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code);

   END IF;


   ln_return_val := p_mol_pct * ec_component_constant.mol_wt(lv2_object_id,
                                                             p_component_no,
                                                             p_daytime,
                                                             '<=');
   -- Try analysis to get residue components
   IF ln_return_val IS NULL THEN

         lr_analyse_sample := EcDp_Fluid_Analysis.getPeriodAnalysisSample(p_object_id,
                                                                      p_analysis_type,
                                                                      p_sampling_method,
                                                                      p_daytime,
                                                                      p_daytime_summer_time);

        ln_return_val := p_mol_pct * lr_analyse_sample.cnpl_mol_wt;

   END IF;

   RETURN ln_return_val;

END calcCompMassFracPeriodAn;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcCompMolPct
-- Description    : Provides a component mol for a weigth percent as percentage of the total composition.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcCompMolPct(
   p_object_id          VARCHAR2,
   p_daytime            DATE,
   p_component_no       VARCHAR2,
   p_analysis_type      VARCHAR2,
   p_sampling_method    VARCHAR2,
   p_weight_pct         NUMBER)
RETURN NUMBER
--</EC-DOC>
IS
ln_analysis_no NUMBER;
ln_tot_wt NUMBER;
ln_ret_val NUMBER;

BEGIN

   ln_analysis_no := EcDp_Fluid_Analysis.getAnalysisNumber(p_object_id, p_analysis_type, p_sampling_method, p_daytime);

   IF ln_analysis_no IS NOT NULL THEN

      ln_tot_wt := calcTotMolFrac(ln_analysis_no);

      IF ln_tot_wt > 0 THEN -- Only numbers in R+. Avoid division by zero.

         ln_ret_val := 100 * calcCompMolFrac(p_object_id, p_daytime, p_component_no, p_analysis_type, p_sampling_method, p_weight_pct) / ln_tot_wt;

      END IF;

   END IF;

   RETURN ln_ret_val;

END calcCompMolPct;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcCompMolFrac
-- Description    : Calculates a component mol fraction.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcCompMolFrac(
   p_object_id          VARCHAR2,
   p_daytime            DATE,
   p_component_no       VARCHAR2,
   p_analysis_type      VARCHAR2,
   p_sampling_method    VARCHAR2,
   p_weight_pct         NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

   ln_return_val         NUMBER;
   lv2_standard_code    constant_standard.object_code%TYPE;
   lv2_object_id        varchar2(32);
   lr_analyse_sample object_fluid_analysis%ROWTYPE;
   lv2_phase          VARCHAR2(32);

BEGIN

   lv2_standard_code := EcDp_System.getAttributeText(p_daytime,
                                                      'STANDARD_CODE');
   lv2_phase         := ec_strm_version.stream_phase(p_object_id, p_daytime, '<=');

   IF lv2_phase = 'GAS' THEN

      lv2_object_id := Nvl(ec_strm_version.ref_gas_const_std_id(p_object_id, p_daytime,'<='),ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code));

   ELSIF lv2_phase = 'OIL' THEN

      lv2_object_id := Nvl(ec_strm_version.ref_oil_const_std_id(p_object_id, p_daytime,'<='),ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code));

   ELSIF lv2_phase IN ('RES','COND','LNG','NGL') THEN

       lv2_object_id := Nvl(ec_strm_version.ref_oil_const_std_id(p_object_id, p_daytime,'<='),Nvl(ec_strm_version.ref_gas_const_std_id(p_object_id, p_daytime,'<='),ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code)));
   ELSE

      lv2_object_id := ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code);

   END IF;


   ln_return_val := p_weight_pct / ec_component_constant.mol_wt(lv2_object_id,
                                                                p_component_no,
                                                                p_daytime,
                                                                '<=');
   IF ln_return_val IS NULL THEN


      lr_analyse_sample := EcDp_Fluid_Analysis.getAnalysisSample(p_object_id,
                                                                    p_analysis_type,
                                                                    p_sampling_method,
                                                                    p_daytime);

      IF p_weight_pct = 0 THEN

         ln_return_val := 0;

      ELSIF lr_analyse_sample.cnpl_mol_wt > 0 THEN

         ln_return_val := p_weight_pct / lr_analyse_sample.cnpl_mol_wt;

      END IF;

   END IF;

   RETURN ln_return_val;

END calcCompMolFrac;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcCompMolFracPeriodAn
-- Description    : Calculates a component mol fraction.
--
-- Preconditions  : Used from the business function Period Stream Gas Component Analysis
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcCompMolFracPeriodAn(
   p_object_id            VARCHAR2,
   p_daytime              DATE,
   p_daytime_summer_time  VARCHAR2,
   p_component_no         VARCHAR2,
   p_analysis_type        VARCHAR2,
   p_sampling_method      VARCHAR2,
   p_weight_pct           NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

   ln_return_val         NUMBER;
   lv2_standard_code    constant_standard.object_code%TYPE;
   lv2_object_id        varchar2(32);
   lr_analyse_sample strm_analysis_event%ROWTYPE;
   lv2_phase          VARCHAR2(32);


BEGIN

   lv2_standard_code := EcDp_System.getAttributeText(p_daytime,
                                                      'STANDARD_CODE');
   lv2_phase         := ec_strm_version.stream_phase(p_object_id, p_daytime, '<=');

   IF lv2_phase = 'GAS' THEN

      lv2_object_id := Nvl(ec_strm_version.ref_gas_const_std_id(p_object_id, p_daytime,'<='),ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code));

   ELSIF lv2_phase = 'OIL' THEN

      lv2_object_id := Nvl(ec_strm_version.ref_oil_const_std_id(p_object_id, p_daytime,'<='),ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code));

   ELSIF lv2_phase IN ('RES','COND','LNG','NGL') THEN

       lv2_object_id := Nvl(ec_strm_version.ref_oil_const_std_id(p_object_id, p_daytime,'<='),Nvl(ec_strm_version.ref_gas_const_std_id(p_object_id, p_daytime,'<='),ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code)));
   ELSE

      lv2_object_id := ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code);

   END IF;


   ln_return_val := p_weight_pct / ec_component_constant.mol_wt(lv2_object_id,
                                                                p_component_no,
                                                                p_daytime,
                                                                '<=');
   IF ln_return_val IS NULL THEN


      lr_analyse_sample := EcDp_Fluid_Analysis.getPeriodAnalysisSample(p_object_id,
                                                                    p_analysis_type,
                                                                    p_sampling_method,
                                                                    p_daytime,
                                                                    p_daytime_summer_time);

      IF p_weight_pct = 0 THEN

         ln_return_val := 0;

      ELSIF lr_analyse_sample.cnpl_mol_wt > 0 THEN

         ln_return_val := p_weight_pct / lr_analyse_sample.cnpl_mol_wt;

      END IF;

   END IF;

   RETURN ln_return_val;

END calcCompMolFracPeriodAn;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getStreamCompWtPct
-- Description  : Returns a component weight percent from the latest analysis of a stream.
--
--
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:
--
-- Using functions: EcDp_Fluid_Analysis.getLastAnalysisNumber
--                  ec_fluid_analysis_component.wt_pct
-- Configuration
-- required:
--
-- Behaviour
--
---------------------------------------------------------------------------------------------------
FUNCTION getStreamCompWtPct(
--   p_sysnam             VARCHAR2,
--   p_stream_code        VARCHAR2,
     p_object_id          stream.object_id%TYPE,
     p_daytime            DATE,
     p_component_no       VARCHAR2,
     p_analysis_type      VARCHAR2,
     p_sampling_method    VARCHAR2,
     p_phase              VARCHAR2 DEFAULT NULL,
     p_fluid_state        VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

   ln_analysis_no    NUMBER;
BEGIN

   ln_analysis_no := EcDp_Fluid_Analysis.getLastAnalysisNumber(p_object_id,
                                                               p_analysis_type,
                                                               p_sampling_method,
                                                               p_daytime,
                                                               p_phase,
                                                               p_fluid_state);

   RETURN ec_fluid_analysis_component.wt_pct(ln_analysis_no, p_component_no);

END getStreamCompWtPct;

PROCEDURE createCompOrfGas(p_object_id       VARCHAR2,
                           p_daytime         DATE,
                           p_orf_type        VARCHAR2,
                           p_analysis_type   VARCHAR2,
                           p_sampling_method VARCHAR2 DEFAULT NULL,       -- sampling method for acceptable analyses - will also be set on result record
                           p_fluid_state     VARCHAR2 DEFAULT NULL,       -- fluid state for acceptable analyses
                           p_timescope       VARCHAR2 DEFAULT 'DAY')      -- DAY or MONTH


IS
--</EC-DOC>
CompDataHCFeed         CompDataArray;
CompDataGas            CompDataArray;
CompConstHCFeed        CompConstArray;
CompConstGas           CompConstArray;
--
lr_last_analysis object_fluid_analysis%ROWTYPE;
lr_next_analysis object_fluid_analysis%ROWTYPE;
--

lv2_stream_id          VARCHAR2(32);
lv2_analysis_stream_id VARCHAR2(32);
lv2_analysis_type      VARCHAR2(32);
lv2_PLComp_ORF         VARCHAR2(32);
lv2_ORF_stream_id      VARCHAR2(32);
lv2_terminator         VARCHAR2(1);
lv2_mol2wt_conv        VARCHAR2(1);
lv2_object_class       VARCHAR2(32);
lv2_HC_std_id          VARCHAR2(32);
lv2_gas_std_id         VARCHAR2(32);
--
ln_XMprodsumHC         NUMBER;
ln_GasMass             NUMBER;
ln_GasVolume           NUMBER;
ln_GasMol              NUMBER;
ln_GasMW               NUMBER;
ln_GasDens             NUMBER;
ln_GasSG               NUMBER;
ln_GasGCV              NUMBER;
ln_GasWI               NUMBER;
ln_GasCO2              NUMBER;
ln_GasH2S              NUMBER;
ln_hc_analysis_no      NUMBER;
ln_XMprodsumGas        NUMBER;
ln_Zmix                NUMBER;
ln_PL_Gas_mass         NUMBER;
ln_PL_Liq_mass         NUMBER;
ln_sum_factor          NUMBER;
ln_TargetAnalysisNo    NUMBER;
ln_15DEG_KEL           NUMBER;
ln_1ATM_TO_kPA         NUMBER;
ln_DEN_AIR_15_DEG      NUMBER;
ln_MOL_MASS_AIR        NUMBER;
ln_CONST_UNIVERSAL     NUMBER;
ln_Z_FACTOR_AIR        NUMBER;



--
indx1                  PLS_INTEGER;
indx2                  PLS_INTEGER;

BEGIN

ln_15DEG_KEL           := ec_ctrl_system_attribute.attribute_value(p_daytime,'GAS_CONST_15_DEG_TO_K','<=');
ln_1ATM_TO_kPA         := ec_ctrl_system_attribute.attribute_value(p_daytime,'GAS_CONST_1ATM_TO_kPA','<=');
ln_DEN_AIR_15_DEG      := ec_ctrl_system_attribute.attribute_value(p_daytime,'GAS_CONST_DEN_AIR_15_DEG','<=');
ln_MOL_MASS_AIR        := ec_ctrl_system_attribute.attribute_value(p_daytime,'GAS_CONST_MOL_MASS_AIR','<=');
ln_CONST_UNIVERSAL     := ec_ctrl_system_attribute.attribute_value(p_daytime,'GAS_CONST_UNIVERSAL','<=');
ln_Z_FACTOR_AIR        := ec_ctrl_system_attribute.attribute_value(p_daytime,'GAS_CONST_Z_FACTOR_AIR','<=');


lv2_object_class := ecdp_objects.getobjclassname(p_object_id);

 IF lv2_object_class = 'STREAM' THEN  -- Identify quality fluid and standard for gas stream
      lv2_stream_id  := ec_strm_version.ref_orf_stream_id(p_object_id, p_daytime,'<=');
      lv2_gas_std_id := ec_strm_version.ref_gas_const_std_id(p_object_id, p_daytime, '<=');
 END IF;

 IF lv2_stream_id IS NOT NULL THEN  -- Find most recent compositional analysis for the quality fluid - any sampling
      lv2_analysis_stream_ID := nvl(EcDp_Stream.getAnalysisStream(lv2_stream_id, p_daytime), lv2_stream_id);
      lv2_ORF_stream_id      := nvl(ec_strm_version.ref_orf_stream_id(lv2_stream_id, p_daytime, '<='), lv2_stream_id);

      ln_hc_analysis_no      := nvl(ECDP_FLUID_ANALYSIS.getLastAnalysisNumber(lv2_analysis_stream_ID, 'STRM_GAS_COMP',NULL, p_daytime,NULL,p_fluid_state)
                                   ,ECDP_FLUID_ANALYSIS.getLastAnalysisNumber(lv2_analysis_stream_ID, 'STRM_OIL_COMP',NULL, p_daytime,NULL,p_fluid_state));
      lv2_analysis_type      := ec_object_fluid_analysis.analysis_type(ln_hc_analysis_no);
      IF lv2_analysis_type = 'STRM_GAS_COMP' THEN
         lv2_HC_std_id := ec_strm_version.ref_gas_const_std_id(lv2_stream_id, p_daytime, '<=');
      ELSIF lv2_analysis_type = 'STRM_OIL_COMP' THEN
         lv2_HC_std_id := ec_strm_version.ref_oil_const_std_id(lv2_stream_id, p_daytime, '<=');
      END IF;
    END IF;

   -- Find last and next analysis for the gas analysis we are creating

lr_next_analysis := ECDP_FLUID_ANALYSIS.getNextAnalysisSample(p_object_id,p_analysis_type,p_sampling_method, p_daytime,'GAS',p_fluid_state);
 EcDp_month_lock.validatePeriodForLockOverlap('UPDATING', p_daytime, lr_next_analysis.valid_from_date, 'ECBP_comp_analysis.createCompOrfGas: can not do this
for a locked period', p_object_id);

   -- Find plus fractions
    SELECT Max(component_no) into lv2_PLComp_ORF from comp_set_list where component_set = 'STRM_ORF_COMP' and daytime <= p_daytime and SUBSTR
(component_no,LENGTH(Component_no),1) = '+';

 -- Fill the arrays from cursor with quality fluid component data and standard constants and orf constants
    ln_XMprodsumHC  := 0;
    lv2_terminator  := 'N';
    lv2_mol2wt_conv := 'N';
    CompDataHCFeed  := CompDataArray();
    CompConstHCFeed := CompConstArray();
    CompConstGas    := CompConstArray();
    indx1 := 0;

    FOR CompCur in c_comp LOOP
      indx1 := indx1 + 1;

         CompConstHCFeed.extend();
      IF  lv2_HC_std_id IS NOT NULL THEN   -- Load available info from HC standard To be used in the split process

        CompConstHCFeed(indx1).comp_no         := CompCur.comp_no;
        CompConstHCFeed(indx1).mol_wt          := ec_component_constant.mol_wt(lv2_HC_std_id, CompCur.comp_no, p_daytime, '<=');
        CompConstHCFeed(indx1).orf             := ec_strm_orf_component.orf_factor(lv2_ORF_stream_id, p_orf_type, CompCur.comp_no, p_daytime, '<=');
      END IF;

          CompConstGas.extend();
       IF  lv2_gas_std_id IS NOT NULL THEN   -- Load available info from gas standard to be applied to the gas phase

        CompConstGas(indx1).comp_no         := CompCur.comp_no;
        CompConstGas(indx1).mol_wt          := ec_component_constant.mol_wt(lv2_gas_std_id, CompCur.comp_no, p_daytime, '<=');
        CompConstGas(indx1).sum_factor      := ec_component_constant.sum_factor(lv2_gas_std_id, CompCur.comp_no, p_daytime, '<=');
        CompConstGas(indx1).ideal_gcv       := ec_component_constant.ideal_gcv(lv2_gas_std_id, CompCur.comp_no, p_daytime, '<=');
        CompConstGas(indx1).ideal_ncv       := ec_component_constant.ideal_ncv(lv2_gas_std_id, CompCur.comp_no, p_daytime, '<=');

      END IF;



      CompDataHCFeed.extend();
      CompDataHCFeed(indx1).comp_no   := CompCur.comp_no;
      CompDataHCFeed(indx1).wt_frac   := EC_FLUID_ANALYSIS_COMPONENT.WT_PCT(ln_hc_analysis_no, CompCur.comp_no)/100;
      CompDataHCFeed(indx1).mol_frac  := EC_FLUID_ANALYSIS_COMPONENT.MOL_PCT(ln_hc_analysis_no, CompCur.comp_no)/100;
      CompDataHCFeed(indx1).mol_wt    := nvl(nvl(EC_FLUID_ANALYSIS_COMPONENT.MOL_WT(ln_hc_analysis_no, CompCur.comp_no), CompConstHCFeed(indx1).mol_wt),0);
      CompDataHCFeed(indx1).density   := nvl(nvl(EC_FLUID_ANALYSIS_COMPONENT.DENSITY(ln_hc_analysis_no, CompCur.comp_no), CompConstHCFeed
(indx1).gas_density),0);
      CompDataHCFeed(indx1).orf       := nvl(ec_strm_orf_component.orf_factor(lv2_ORF_stream_id, p_orf_type, CompCur.comp_no, p_daytime, '<='),0);

        -- Set ORF termination flag if we encounter a component that has component+ as ORF plus fraction
      IF lv2_PLComp_ORF = CompCur.comp_no || '+' THEN
        lv2_terminator := 'Y';
      END IF;

       -- If terminator, ORF for the plus-fraction should be used for the rest of the components
      IF lv2_terminator = 'Y' THEN
        CompDataHCFeed(indx1).orf := nvl(ec_strm_orf_component.orf_factor(lv2_ORF_stream_id, p_orf_type, lv2_PLComp_ORF, p_daytime, '<='),0);
      END IF;

       -- Check if mol_frac to wt_frac conversion is necessary
      IF (CompDataHCFeed(indx1).wt_frac IS NULL) and (CompDataHCFeed(indx1).mol_frac IS NOT NULL) THEN
        lv2_mol2wt_conv := 'Y';
      END IF;
        -- Aggregate molwt * molfrac prodsum for use in mol_frac to wt_frac conversion

    ln_XMprodsumHC := ln_XMprodsumHC + nvl(CompDataHCFeed(indx1).mol_frac * CompDataHCFeed(indx1).mol_wt,0);

      END LOOP;

       -- Run the conversion if nexessary
    IF (lv2_mol2wt_conv = 'Y') AND ln_XMprodsumHC > 0 THEN
      indx1 := 0;
      FOR indx1 in 1..CompDataHCFeed.count LOOP
        CompDataHCFeed(indx1).wt_frac := (CompDataHCFeed(indx1).mol_frac * CompDataHCFeed(indx1).mol_wt) / ln_XMprodsumHC;

  END LOOP;
      END IF;

    -- Calculate component mass and mol
    indx1 := 0;
    FOR indx1 in 1..CompDataHCFeed.count LOOP
      CompDataHCFeed(indx1).comp_mass     := CompDataHCFeed(indx1).wt_frac;
      IF CompDataHCFeed(indx1).mol_wt > 0 THEN
        CompDataHCFeed(indx1).comp_mol    := CompDataHCFeed(indx1).comp_mass / CompDataHCFeed(indx1).mol_wt;

      END IF;
    END LOOP;

    -- Rerun the loop in order to split the phases using ORF.
    CompDataGas := CompDataArray();
    lv2_terminator := 'N';
    ln_PL_Gas_mass := 0;
    ln_PL_Liq_mass := 0;
    indx2 := 0;
     FOR indx1 in 1..CompDataHCFeed.count LOOP
      CompDataGas.extend();
      IF lv2_terminator = 'N' AND lv2_PLComp_ORF = CompDataHCFeed(indx1).comp_no || '+' THEN
        lv2_terminator := 'Y';
        indx2 := indx1;
      END IF;
        IF lv2_PLComp_ORF = CompDataHCFeed(indx1).comp_no THEN
       indx2 := indx1;
       END IF;
         IF lv2_terminator = 'N' THEN
        CompDataGas(indx1).comp_no    := CompDataHCFeed(indx1).comp_no;
        CompDataGas(indx1).comp_mass  := CompDataHCFeed(indx1).wt_frac * (1 - CompDataHCFeed(indx1).orf);
        IF CompConstGas(indx1).mol_wt > 0 THEN
          CompDataGas(indx1).comp_mol := CompDataGas(indx1).comp_mass / CompConstGas(indx1).mol_wt;
        END IF;


      ELSIF lv2_terminator = 'Y' THEN  -- Accumulate plus-fraction mass and set components to 0
        CompDataGas(indx1).comp_no    := CompDataHCFeed(indx1).comp_no;
        CompDataGas(indx1).comp_mass  := 0 * CompDataGas(indx1).comp_mass;
        CompDataGas(indx1).comp_mol   := 0 * CompDataGas(indx1).comp_mol;
        ln_PL_Gas_mass  := ln_PL_Gas_mass + nvl(CompDataHCFeed(indx1).wt_frac * (1 - CompDataHCFeed(indx1).orf),0);
        END IF;

                 END LOOP;

        -- Assign the accumulated plus- mass and mol to the correct component
        IF(indx2 <>0) THEN
    CompDataGas(indx2).comp_mass := ln_PL_Gas_mass;
    IF CompConstGas(indx2).mol_wt > 0 THEN
      CompDataGas(indx2).comp_mol  := ln_PL_Gas_mass / CompConstGas(indx2).mol_wt;
      END IF;
    END IF;


      -- Rerun the loop in order to calculate total mass and mol for phases.
    ln_GasMass  := 0;
    ln_GasMol   := 0;
    FOR indx1 in 1..CompDataHCFeed.count LOOP
      ln_GasMass := ln_GasMass + nvl(CompDataGas(indx1).comp_mass,0);
      ln_GasMol  := ln_GasMol  + nvl(CompDataGas(indx1).comp_mol,0);
    END LOOP;

    -- Rerun the loop in order to calculate weight and mol -fractions for each component and phase.
    FOR indx1 in 1..CompDataHCFeed.count LOOP
      IF ln_GasMass > 0 THEN
        CompDataGas(indx1).wt_frac  := CompDataGas(indx1).comp_mass / ln_GasMass;
        END IF;
      IF ln_GasMol > 0 THEN
        CompDataGas(indx1).mol_frac := CompDataGas(indx1).comp_mol / ln_GasMol;
         END IF;
    END LOOP;

  -------------------------------------------------------------------------------
    -- Standard theoretical density calculation for gas.  Implements the ISO6976 theoretical density calculation based on component ideal density.

    ln_XMprodsumGas  := 0;
    ln_sum_factor    := 0;
    ln_Zmix          := 0;
    FOR indx1 in 1..CompDataGas.count LOOP
      ln_XMprodsumGas  := ln_XMprodsumGas + nvl((CompDataGas(indx1).mol_frac * CompConstGas(indx1).mol_wt),0);
      ln_sum_factor := ln_sum_factor + nvl((CompDataGas(indx1).mol_frac * CompConstGas(indx1).sum_factor),0);

      IF CompDataGas(indx1).comp_no = 'CO2' THEN
        ln_GasCO2 := CompDataGas(indx1).mol_frac;
      END IF;
      IF CompDataGas(indx1).comp_no = 'H2S' THEN
        ln_GasH2S := CompDataGas(indx1).mol_frac;
      END IF;
    END LOOP;
    ln_Zmix := 1 - Power(ln_sum_factor, 2);
    IF nvl(ln_XMprodsumGas,0) > 0 THEN
       ln_GasDens := ((ln_XMprodsumGas * ln_1ATM_TO_kPA)/(ln_CONST_UNIVERSAL * ln_15DEG_KEL)) / ln_Zmix;
    END IF;
    IF nvl(ln_GasDens,0) > 0 THEN
      ln_GasVolume  := ln_GasMass / ln_GasDens;
    END IF;
    IF nvl(ln_GasMol,0) > 0 THEN
      ln_GasMW  := ln_GasMass / ln_GasMol;
    END IF;
    ln_GasSG    := ln_GasDens / ln_DEN_AIR_15_DEG;


      -------------------------------------------------------------------------------
    -- Standard theoretical GCV and Wobbe index calculation for gas.  Implements the ISO6976 theoretical gcv calculation based on component ideal gcv.
    IF nvl(ln_GasMW,0) > 0 THEN
      ln_GasGCV   := 0;
        FOR indx1 in 1..CompDataGas.count LOOP
          ln_GasGCV := ln_GasGCV + nvl((CompDataGas(indx1).mol_frac * CompConstGas(indx1).mol_wt / ln_XMprodsumGas ) * CompConstGas(indx1).ideal_GCV,0);
        END LOOP;
        ln_GasGCV := ln_GasGCV * ln_GasDens * 1e-3;
        IF NVL(ln_GasSG,0) > 0 THEN
          ln_GasWI    := ln_GasGCV / power(ln_GasSG,0.5);
        END IF;
    END IF;


      -------------------------------------------------------------------------------
    -- Create gas analysis records in object_fluid_analysis and fluid_analysis_component. Create header record if it does not exist.
    ln_TargetAnalysisNo := nvl(ECDP_FLUID_ANALYSIS.getLastAnalysisNumber(lv2_analysis_stream_ID, 'STRM_GAS_COMP',NULL, p_daytime,NULL,p_fluid_state),0);
    IF ln_TargetAnalysisNo = 0 THEN
       INSERT INTO object_fluid_analysis
         (object_id
         ,object_class_name
         ,daytime
         ,analysis_type
         ,component_set
         ,sampling_method
         ,phase
         ,valid_from_date
         ,production_day
         ,analysis_status)
       VALUES
         (p_object_id
         ,'STREAM'
         ,p_daytime
         ,'STRM_GAS_COMP'
         ,'STRM_GAS_COMP'
         ,p_sampling_method
         ,'GAS'
         ,p_daytime
         ,ecdp_productionday.getProductionDay(lv2_object_class, p_object_id, p_daytime, NULL)
         ,'APPROVED');

     END IF;

      ln_TargetAnalysisNo := nvl(ECDP_FLUID_ANALYSIS.getLastAnalysisNumber(lv2_analysis_stream_ID, 'STRM_GAS_COMP',NULL, p_daytime,NULL,p_fluid_state),0);
  IF ln_TargetAnalysisNo > 0 THEN
    -- update header record with last calculation results
    UPDATE object_fluid_analysis
    SET density  = ln_GasDens
        ,mol_wt  = ln_GasMW
        ,gcv     = ln_GasGCV
        ,REL_DENSITY = ln_GasSG
        ,WOBBE_INDEX = ln_GasWI
        ,CO2     = ln_GasCO2 * 100
        ,H2S     = ln_GasH2S * 1000000
      WHERE analysis_no = ln_TargetAnalysisNo;

   -- Remove obsolete component data
    DELETE FROM fluid_analysis_component WHERE analysis_no = ln_TargetAnalysisNo;
    FOR indx1 in 1..CompDataGas.count LOOP
        -- Create new component record

      IF CompDataGas(indx1).wt_frac is not NULL THEN
        INSERT INTO fluid_analysis_component
           (analysis_no
           ,component_no
           ,wt_pct
           ,mol_pct)
        VALUES
          (ln_TargetAnalysisNo
          ,CompDataGas(indx1).comp_no
          ,CompDataGas(indx1).wt_frac * 100
          ,CompDataGas(indx1).mol_frac * 100);
      END IF;
    END LOOP;

  END IF;

END createCompOrfGas;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : createCompMth
-- Description  : Creates month representative mass-weighted composition for a gas stream
--						based on daily gas analyses.
--						Calculates month representative density, gcv and wobbe index for the gas
--						Results are stored in object_fluid_analysis / fluid analysis_component tables
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:   object_fluid_analysis, fluid_analysis_component, ctrl_system_attribute,
--						 component_constant,strm_version
--
-- Using functions: EcDp_Fluid_Analysis.getLastAnalysisNumber
--                  EcDp_Fluid_Analysis.getNextAnalysisSample
-- Configuration
-- required:
--
-- Behaviour
--
---------------------------------------------------------------------------------------------------
PROCEDURE createCompMth(p_object_id       VARCHAR2,
                        p_daytime         DATE,
                        p_analysis_type   VARCHAR2,
                        p_sampling_method VARCHAR2 DEFAULT NULL,  -- sampling method for acceptable analyses
                        p_fluid_state     VARCHAR2 DEFAULT NULL,  -- fluid state for acceptable analyses
                        p_method          VARCHAR2 DEFAULT NULL)  -- method for retrieving daily net standard mass. Default is configured stream method.


IS
--</EC-DOC>

    CURSOR c_DaysInMonth(cp_daytime DATE)
    IS
    SELECT daytime
    FROM system_days
    WHERE trunc(daytime,'MM') = cp_daytime
    ORDER BY daytime ASC;

    CompDataFluid     CompDataArray;
    CompConstFluid    CompConstArray;
    --
    lr_last_analysis object_fluid_analysis%ROWTYPE;
    lr_next_analysis object_fluid_analysis%ROWTYPE;
    --
    ld_date                DATE;
    lv2_mol2wt_conv        VARCHAR2(1);
    lv2_phase              VARCHAR2(32);
    lv2_comp_set           VARCHAR2(32);
    lv2_object_class       VARCHAR2(32);
    lv2_fluid_std_id       VARCHAR2(32);
    lv2_comment            VARCHAR2(256) := NULL;
    lv2_comp_no            VARCHAR2(8);
    lv2_cnpl_check         VARCHAR2(4);
    --
    ln_XMprodsumFluid      NUMBER;
    ln_netmassday          NUMBER;
    ln_GasMW               NUMBER;
    ln_GasDens             NUMBER;
    ln_GasSG               NUMBER;
    ln_GasGCV              NUMBER;
    ln_GasWI               NUMBER;
    ln_GasCO2              NUMBER;
    ln_GasH2S              NUMBER;
    ln_FluidMolMth         NUMBER;
    ln_FluidMassMth        NUMBER;
    ln_LiqDens             NUMBER;
    ln_XMprodsumGas        NUMBER;
    ln_Zmix                NUMBER;
    ln_sum_factor          NUMBER;
    ln_LiqVolume           NUMBER;
    ln_analysis_no         NUMBER;
    ln_TargetAnalysisNo    NUMBER;
    ln_countMissingComp    NUMBER;
    ln_countMissingMass    NUMBER;
    ln_dens_air_15_deg_c   NUMBER;
    ln_R                   NUMBER;
    ln_T                   NUMBER;
    ln_P                   NUMBER;
    --
    indx1                  PLS_INTEGER;
    indx2                  PLS_INTEGER;
    indx3                  PLS_INTEGER;
    indx4                  PLS_INTEGER;
    indx5                  PLS_INTEGER;
    indx6                  PLS_INTEGER;

BEGIN
	--constants for ISO6976 theoretical density calculation
    ln_dens_air_15_deg_c:= ec_ctrl_system_attribute.attribute_value(p_daytime,'GAS_CONST_DEN_AIR_15_DEG','<='); -- Density of air at 15°C ISA
    ln_R := ec_ctrl_system_attribute.attribute_value(p_daytime,'GAS_CONST_UNIVERSAL','<='); -- Universal gas constant R
    ln_T := ec_ctrl_system_attribute.attribute_value(p_daytime,'GAS_CONST_15_DEG_TO_K','<='); --15°C converted to K.
    ln_P := ec_ctrl_system_attribute.attribute_value(p_daytime,'GAS_CONST_1ATM_TO_kPA','<='); -- 1atm converted to kPa.

    lv2_object_class := ecdp_objects.getobjclassname(p_object_id);
    ld_date := trunc(p_daytime,'MM');

    IF lv2_object_class = 'STREAM' THEN  -- Identify phase and standards for stream
        lv2_phase      := Ec_Strm_Version.stream_phase(p_object_id, ld_date, '<=');
        lv2_comp_set   := Ec_Strm_Version.comp_set_code(p_object_id, ld_date, '<=');
        IF lv2_phase ='GAS' AND nvl(lv2_comp_set,'STRM_GAS_COMP') = 'STRM_GAS_COMP' THEN
            lv2_fluid_std_id  := ec_strm_version.ref_gas_const_std_id(p_object_id, ld_date, '<=');
            lv2_comp_set := 'STRM_GAS_COMP';
        ELSIF lv2_phase = 'OIL' AND nvl(lv2_comp_set,'STRM_OIL_COMP') = 'STRM_OIL_COMP' THEN
            lv2_fluid_std_id  := ec_strm_version.ref_oil_const_std_id(p_object_id, ld_date, '<=');
            lv2_comp_set := 'STRM_OIL_COMP';
        ELSIF lv2_phase ='RES' THEN
            IF nvl(lv2_comp_set,'STRM_GAS_COMP') = 'STRM_GAS_COMP' THEN --
        		    lv2_fluid_std_id  := ec_strm_version.ref_gas_const_std_id(p_object_id, ld_date, '<=');
        		    lv2_comp_set := 'STRM_GAS_COMP';
        		ELSIF lv2_comp_set = 'STRM_OIL_COMP' THEN
        		    lv2_fluid_std_id := ec_strm_version.ref_oil_const_std_id(p_object_id, ld_date, '<=');
        		END IF;
        ELSE
            RETURN;  -- Have not considered NGL, LNG yet ...
        END IF;
    ELSE
        RETURN;    -- Have not considered other object classes yet
    END IF;

    -- Find last and next analysis for the month analysis we are creating
    lr_next_analysis := EcDp_Fluid_Analysis.getNextAnalysisSample(p_object_id, p_analysis_type, 'MTH_SAMPLER_CALC', ld_date, lv2_phase, p_fluid_state);
    EcDp_month_lock.validatePeriodForLockOverlap('UPDATING', ld_date, lr_next_analysis.valid_from_date, 'EcBp_Comp_Analysis.createMthComp: can not do this for a locked period', p_object_id);

     -- Load constants valid @first of month and initialise fluid Data
    IF  lv2_fluid_std_id IS NOT NULL THEN
        CompConstFluid := CompConstArray();
        CompDataFluid  := CompDataArray();
        indx1 := 0;
        FOR CompCur IN c_CompSet(lv2_comp_set) LOOP
            indx1 := indx1 + 1;
            CompConstFluid.extend();
            CompDataFluid.extend();

            -- Load available info from standard
            -- Check if CnPlus component
            lv2_cnpl_check := INSTR(CompCur.comp_No,'+');
            IF lv2_cnpl_check > 0 THEN
                CompConstFluid(indx1).comp_no         := CompCur.comp_no;
                lv2_comp_no                           := substr(CompCur.comp_no,1,instr(CompCur.comp_no,'+')-1);
                --CompConstFluid(indx1).mol_wt   --> retrieved later in the analysis cnpl_mol_wt attribute
                CompConstFluid(indx1).sum_factor      := ec_component_constant.sum_factor(lv2_fluid_std_id, lv2_comp_no, ld_date, '<=');
                CompConstFluid(indx1).ideal_gcv       := ec_component_constant.ideal_gcv(lv2_fluid_std_id, lv2_comp_no, ld_date, '<=');
                CompConstFluid(indx1).oil_density     := ec_component_constant.oil_density(lv2_fluid_std_id, lv2_comp_no, ld_date, '<=');
            ELSE
                CompConstFluid(indx1).comp_no         := CompCur.comp_no;
                CompConstFluid(indx1).mol_wt          := ec_component_constant.mol_wt(lv2_fluid_std_id, CompCur.comp_no, ld_date, '<=');
                CompConstFluid(indx1).sum_factor      := ec_component_constant.sum_factor(lv2_fluid_std_id, CompCur.comp_no, ld_date, '<=');
                CompConstFluid(indx1).ideal_gcv       := ec_component_constant.ideal_gcv(lv2_fluid_std_id, CompCur.comp_no, ld_date, '<=');
                CompConstFluid(indx1).oil_density     := ec_component_constant.oil_density(lv2_fluid_std_id, CompCur.comp_no, ld_date, '<=');
            END IF;
            -- set accumulators to zero
            CompDataFluid(indx1).comp_no    := CompCur.comp_no;
            CompDataFluid(indx1).comp_mass  := 0;
            CompDataFluid(indx1).comp_mol   := 0;
        END LOOP;
    END IF;

--   Start looping through all days in month
    ln_countMissingComp := 0;
    ln_countMissingMass := 0;

    FOR Days IN c_DaysInMonth(ld_date) LOOP
        lr_last_analysis := EcDp_Fluid_Analysis.getLastAnalysisSample(p_object_id, p_analysis_type, p_sampling_method, Days.daytime, lv2_phase, p_fluid_state);
        ln_analysis_no := lr_last_analysis.analysis_no;

        IF ec_object_fluid_analysis.valid_from_date(ln_analysis_no) < Days.daytime THEN
            ln_countMissingComp := ln_countMissingComp + 1;
        END IF;

        ln_netmassday   := nvl(EcBp_Stream_Fluid.findNetStdMass(p_object_id, Days.daytime, NULL, p_method), NULL);
        IF ln_netmassday IS NULL THEN
            ln_countMissingMass := ln_countMissingMass + 1;
        END IF;

        ln_XMprodsumFluid := 0;
        lv2_mol2wt_conv   := 'N';
        indx2 := 0;

        FOR indx2 IN 1..CompDataFluid.count LOOP
            CompDataFluid(indx2).wt_frac   := ec_fluid_analysis_component.wt_pct(ln_analysis_no, CompDataFluid(indx2).comp_no)/100;
            CompDataFluid(indx2).mol_frac  := ec_fluid_analysis_component.mol_pct(ln_analysis_no, CompDataFluid(indx2).comp_no)/100;
            CompDataFluid(indx2).mol_wt    := nvl(nvl(ec_fluid_analysis_component.mol_wt(ln_analysis_no, CompDataFluid(indx2).comp_no), CompConstFluid(indx2).mol_wt),lr_last_analysis.cnpl_mol_wt);

            -- Check if mol_frac to wt_frac conversion is necessary
            IF (CompDataFluid(indx2).wt_frac IS NULL) AND (CompDataFluid(indx2).mol_frac IS NOT NULL) THEN
                lv2_mol2wt_conv := 'Y';
            END IF;

            -- Aggregate molwt * molfrac prodsum for use in mol_frac to wt_frac conversion
            ln_XMprodsumFluid := ln_XMprodsumFluid + nvl(CompDataFluid(indx2).mol_frac * CompDataFluid(indx2).mol_wt,0);
        END LOOP;

        -- Run the conversion if necessary
        IF (lv2_mol2wt_conv = 'Y') AND ln_XMprodsumFluid > 0 THEN
            indx3 := 0;
            FOR indx3 IN 1..CompDataFluid.count LOOP
                CompDataFluid(indx3).wt_frac := (CompDataFluid(indx3).mol_frac * CompDataFluid(indx3).mol_wt) / ln_XMprodsumFluid;
            END LOOP;
        END IF;

        -- Calculate and aggregate component mass and mol over all days in month
        indx4 := 0;
        FOR indx4 in 1..CompDataFluid.count LOOP
            CompDataFluid(indx4).comp_mass     := CompDataFluid(indx4).comp_mass + nvl(ln_netmassday * CompDataFluid(indx4).wt_frac,0);
            IF CompDataFluid(indx4).mol_wt > 0 THEN
                CompDataFluid(indx4).comp_mol    := CompDataFluid(indx4).comp_mol + nvl(ln_netmassday * CompDataFluid(indx4).wt_frac / CompDataFluid(indx4).mol_wt,0);
            END IF;
        END LOOP;
    END LOOP; -- Finished aggregating all days into accumulators

    -- Rerun the loop in order to calculate total mass and mol for phases.
    ln_FluidMassMth  := 0;
    ln_FluidMolMth   := 0;
    indx5 := 0;
    FOR indx5 IN 1..CompDataFluid.count LOOP
        ln_FluidMassMth := ln_FluidMassMth + nvl(CompDataFluid(indx5).comp_mass,0);
        ln_FluidMolMth  := ln_FluidMolMth  + nvl(CompDataFluid(indx5).comp_mol,0);

    END LOOP;

    -- Rerun the loop in order to calculate weight and mol -fractions for each component and phase.
    indx6 := 0;
    FOR indx6 IN 1..CompDataFluid.count LOOP
        IF ln_FluidMassMth > 0 THEN
            CompDataFluid(indx6).wt_frac  := CompDataFluid(indx6).comp_mass / ln_FluidMassMth;
        END IF;
        IF ln_FluidMolMth > 0 THEN
            CompDataFluid(indx6).mol_frac := CompDataFluid(indx6).comp_mol / ln_FluidMolMth;
        END IF;
    END LOOP;

    ----------------------------------------------------------------------------------------------------------------------------------------------
    -- Standard theoretical density calculation for gas.  Implements the ISO6976 theoretical density calculation based on component ideal density.
    IF lv2_comp_set = 'STRM_GAS_COMP' THEN
        ln_XMprodsumGas   := 0;
        ln_sum_factor     := 0;
        ln_Zmix           := 0;
        FOR indx1 IN 1..CompDataFluid.count LOOP
            ln_XMprodsumGas := ln_XMprodsumGas + nvl((CompDataFluid(indx1).mol_frac * CompConstFluid(indx1).mol_wt),0);
            ln_sum_factor   := ln_sum_factor + nvl((CompDataFluid(indx1).mol_frac * CompConstFluid(indx1).sum_factor),0);
            IF CompDataFluid(indx1).comp_no = 'CO2' THEN
                ln_GasCO2     := CompDataFluid(indx1).mol_frac;
            END IF;
            IF CompDataFluid(indx1).comp_no = 'H2S' THEN
                ln_GasH2S     := CompDataFluid(indx1).mol_frac;
            END IF;
        END LOOP;
        ln_Zmix := 1 - Power(ln_sum_factor, 2);
        IF nvl(ln_XMprodsumGas,0) > 0 THEN
            ln_GasDens := ((ln_XMprodsumGas * ln_P)/(ln_R * ln_T)) / ln_Zmix;
        END IF;
        IF nvl(ln_FluidMolMth,0) > 0 THEN
            ln_GasMW  := ln_FluidMassMth / ln_FluidMolMth;
        END IF;

        ln_GasSG    := ln_GasDens / ln_dens_air_15_deg_c;

        ----------------------------------------------------------------------------------------------------------------------------------------------
        -- Standard theoretical GCV and Wobbe index calculation for gas.  Implements the ISO6976 theoretical gcv calculation based on component ideal gcv.
        IF nvl(ln_GasMW,0) > 0 THEN
            ln_GasGCV   := 0;
            FOR indx1 in 1..CompDataFluid.count LOOP
                ln_GasGCV := ln_GasGCV + nvl((CompDataFluid(indx1).mol_frac * CompConstFluid(indx1).mol_wt / ln_XMprodsumGas ) * CompConstFluid(indx1).ideal_GCV,0);
            END LOOP;
            ln_GasGCV := ln_GasGCV * ln_GasDens * 1e-3;
            IF NVL(ln_GasSG,0) > 0 THEN
                ln_GasWI    := ln_GasGCV / sqrt(ln_GasSG);
            END IF;
        END IF;
    END IF;

    ----------------------------------------------------------------------------------------------------------------------------------------------
    -- Standard theoretical density calculation for liquid using component standard oil densities.
    IF lv2_comp_set = 'STRM_OIL_COMP' THEN
      ln_LiqVolume := 0;
      FOR indx1 IN 1..CompDataFluid.count LOOP
        IF CompConstFluid(indx1).oil_density > 0 THEN
          ln_LiqVolume := ln_LiqVolume + nvl(CompDataFluid(indx1).comp_mass / CompConstFluid(indx1).oil_density,0);
        END IF;
      END LOOP;
      IF ln_LiqVolume > 0 THEN
        ln_LiqDens := ln_FluidMassMth / ln_LiqVolume;
      END IF;
    END IF;

    ----------------------------------------------------------------------------------------------------------------------------------------------
    -- Set warning message for comment field when data is missing
    IF ln_countMissingComp > 0 THEN
      lv2_comment := lv2_comment||' Days missing analysis='||ln_countMissingComp;
    END IF;
    IF ln_countMissingMass > 0 THEN
      lv2_comment := lv2_comment||' Days missing mass='||ln_countMissingMass;
    END IF;
    IF lv2_comment IS NOT NULL THEN
      lv2_comment := 'WARN: '||lv2_comment;
    END IF;

    -------------------------------------------------------------------------------
    -- Create analysis header record if it does not exist.
    ln_TargetAnalysisNo := nvl(ecdp_fluid_analysis.getAnalysisNumber(p_object_id,p_analysis_type,'MTH_SAMPLER_CALC',ld_date),0);
    IF ln_TargetAnalysisNo = 0 THEN
        INSERT INTO object_fluid_analysis
          (object_id
          ,object_class_name
          ,daytime
          ,analysis_type
          ,component_set
          ,sampling_method
          ,fluid_state
          ,phase
          ,valid_from_date
          ,production_day
          ,analysis_status
          ,comments)
       VALUES
          (p_object_id
          ,lv2_object_class
          ,ld_date
          ,p_analysis_type
          ,lv2_comp_set
          ,'MTH_SAMPLER_CALC'
          ,p_fluid_state
          ,lv2_phase
          ,ld_date
          ,ecdp_productionday.getProductionDay(lv2_object_class, p_object_id, ld_date, NULL)
          ,'APPROVED'
          ,lv2_comment);

    END IF;

    ln_TargetAnalysisNo := nvl(ecdp_fluid_analysis.getAnalysisNumber(p_object_id,p_analysis_type,'MTH_SAMPLER_CALC',ld_date),0);
    IF ln_TargetAnalysisNo > 0 THEN
        -- update header record with last calculation results
        UPDATE object_fluid_analysis
        SET density       = ln_GasDens
            ,mol_wt       = ln_GasMW
            ,gcv          = ln_GasGCV
            ,sp_grav      = ln_GasSG
            ,wobbe_index  = ln_GasWI
            ,CO2          = ln_GasCO2 * 100
            ,H2S          = ln_GasH2S * 1000000
            ,comments     = lv2_comment
        WHERE analysis_no = ln_TargetAnalysisNo;

        -- Remove obsolete component data and create new component records
        DELETE FROM fluid_analysis_component WHERE analysis_no = ln_TargetAnalysisNo;
        FOR indx1 in 1..CompDataFluid.count LOOP
            IF CompDataFluid(indx1).wt_frac IS NOT NULL THEN
                INSERT INTO fluid_analysis_component
                   (analysis_no
                   ,component_no
                   ,wt_pct
                   ,mol_pct)
                VALUES
                  (ln_TargetAnalysisNo
                  ,CompDataFluid(indx1).comp_no
                  ,CompDataFluid(indx1).wt_frac * 100
                  ,CompDataFluid(indx1).mol_frac * 100);
            END IF;
        END LOOP;

    END IF;

END createCompMth;

---<EC-DOC>
----------------------------------------------------------------------------------------------------
--- Function    : findWellHCLiqPhase
--- Description  : Finds the native hydrocarbon liquid phases produced by the well.
---                Investigates all quality-streams found for the well (both through
---                active rbf-connections and alternatively for the configured quality-stream on well
---
--- Preconditions:
--- Postcondition:
---
--- Using Tables:   well, webo_bore ,webo_interval, resv_block_formation, perf_interval_version
---
--- Configuration
--- required:
---
--- Behaviour
---
----------------------------------------------------------------------------------------------------

FUNCTION findWellHCLiqPhase(p_well_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2
--<EC-DOC>
  IS
-- Cursor for listing all fluid quality streams configured for any given well
-- If configured, the well_version.fluid_quality stream will override the entire well-reservoir model for that well.
  CURSOR c_rbfconnect(cp_object_id VARCHAR2, cp_daytime DATE) IS
    SELECT DISTINCT
      ec_rbf_version.stream_id(rbf.object_id,cp_daytime, '<=') AS QSTRM_ID
      , rbf.object_id AS RBF_ID
      , w.object_id AS WELL_ID
      , 'RBF' AS SOURCE
    FROM well w, webo_bore wb ,webo_interval wbi, resv_block_formation rbf, perf_interval_version piv, perf_interval pi
    WHERE rbf.object_id = piv.resv_block_formation_id
      AND pi.object_id = piv.object_id
      AND pi.webo_interval_id = wbi.object_id
      AND wbi.well_bore_id = wb.object_id
      AND wb.well_id = w.object_id
      AND ec_well_version.fluid_quality(w.object_id , cp_daytime, '<=') is null
      AND w.object_id = cp_object_id
    UNION
    SELECT DISTINCT
      ec_well_version.fluid_quality(well.object_id , cp_daytime, '<=') AS QSTRM_ID
      , 'none' AS RBF_ID
      , well.object_id AS WELL_ID
      , 'WV' AS SOURCE
    FROM well
    WHERE
      ec_well_version.fluid_quality(well.object_id , cp_daytime, '<=') is not null
      AND well.object_id = cp_object_id
    ORDER BY QSTRM_ID;


lv2_return_val      VARCHAR2(8) := 'UNKNOWN';
lv2_QstrmHCLiq      VARCHAR2(8) := NULL;
lv2_oil             VARCHAR2(1) := 'N';
lv2_cond            VARCHAR2(1) := 'N';
lr_connection       c_rbfconnect%rowtype;

BEGIN
  FOR lr_connection in c_rbfconnect(p_well_id, p_daytime) LOOP
    IF c_rbfconnect%NOTFOUND THEN
       EXIT;
    END IF;
    lv2_QstrmHCLiq := nvl(ec_strm_version.hc_liq_phase(lr_connection.qstrm_id, p_daytime, '<='),'UNKNOWN');
    IF lv2_QstrmHCLiq = 'OIL' THEN
      lv2_oil := 'Y';
    ELSIF (lv2_QstrmHCLiq = 'COND') or (lv2_QstrmHCLiq = 'GAS') THEN
      lv2_cond := 'Y';
    END IF;
  END LOOP;

    SELECT DECODE(lv2_oil||lv2_cond,'YN','OIL', 'NY', 'COND', 'YY', 'OIL+COND', 'UNKNOWN') INTO lv2_return_val FROM dual;

RETURN lv2_return_val;

END findWellHCLiqPhase;


END;