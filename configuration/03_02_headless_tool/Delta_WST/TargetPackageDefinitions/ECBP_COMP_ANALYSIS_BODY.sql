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
******************************************************************************************/


CURSOR c_tot_wt(cp_analysis_no NUMBER) IS
SELECT *
FROM fluid_analysis_component
WHERE analysis_no = cp_analysis_no;

CURSOR c_tot_period_an_wt(cp_analysis_no NUMBER) IS
SELECT *
FROM strm_analysis_component
WHERE analysis_no = cp_analysis_no;


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
     p_sampling_method    VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS

   ln_analysis_no    NUMBER;
BEGIN

   ln_analysis_no := EcDp_Fluid_Analysis.getLastAnalysisNumber(p_object_id,
                                                               p_analysis_type,
                                                               p_sampling_method,
                                                               p_daytime);

   RETURN ec_fluid_analysis_component.wt_pct(ln_analysis_no, p_component_no);

END getStreamCompWtPct;

END;