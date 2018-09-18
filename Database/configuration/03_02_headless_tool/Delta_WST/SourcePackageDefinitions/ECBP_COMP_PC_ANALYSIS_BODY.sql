CREATE OR REPLACE PACKAGE BODY EcBp_Comp_PC_Analysis IS
/******************************************************************************************
** Package        :  EcBp_Comp_PC_Analysis, body part
**
** $Revision: 1.1 $
**
** Purpose        :  Provides stream composition analysis methoda.
**
** Documentation  :  www.energy-components.com
**
** Created  : 15.02.2010  Kenneth Masamba
**
** Modification history:
**
** Date       Whom  Change description:
** ------     ----- ----------------------------------------------------------------
** 20.10.2016 keskaash ECPD-36865: Modified getStreamCompWtPct, added parameter p_fluid_state.
** 27.02.2017 Singishi ECPD-36028: Updated calcTotMolPeriodAnFrac , calcTotPeriodAnMassFrac , calcCompMassFracPeriodAn , calcCompMolFracPeriodAn to handle 'RES','COND','LNG','NGL'
                                   phases
******************************************************************************************/


CURSOR c_tot_wt(p_object_id VARCHAR2,p_component_no VARCHAR2,p_pc_id VARCHAR2,p_daytime DATE) IS
SELECT *
FROM strm_pc_comp_analysis
WHERE object_id = p_object_id
AND COMPONENT_NO = p_component_no
AND PROFIT_CENTRE_ID = p_pc_id
AND DAYTIME = p_daytime;

CURSOR c_tot_wt1(p_object_id VARCHAR2,p_pc_id VARCHAR2,p_daytime DATE) IS
SELECT *
FROM strm_pc_comp_analysis
WHERE object_id = p_object_id
AND PROFIT_CENTRE_ID = p_pc_id
AND DAYTIME = p_daytime;


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
-- Using functions: ec_strm_pc_analysis.row_by_pk
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
FUNCTION calcTotMolFrac(p_object_id VARCHAR2,p_pc_id VARCHAR2,p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

   ln_return_val       NUMBER;
   lv2_standard_code   constant_standard.object_code%TYPE;
   lv2_object_id      VARCHAR2(32);
   lr_analyse_sample  strm_pc_analysis%ROWTYPE;
   ln_mol_frac        NUMBER;
   --lv2_phase          VARCHAR2(32);
BEGIN

   lr_analyse_sample := ec_strm_pc_analysis.row_by_pk(p_object_id,p_pc_id,p_daytime);
   lv2_standard_code := EcDp_System.getAttributeText(lr_analyse_sample.daytime, 'STANDARD_CODE');
   lv2_object_id := ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code);

   FOR cur_rec IN c_tot_wt1(p_object_id,p_pc_id,p_daytime) LOOP

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
-- Using functions: ec_strm_pc_analysis.row_by_pk
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
FUNCTION calcTotMassFrac(p_object_id VARCHAR2,p_pc_id VARCHAR2,p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

   ln_return_val       NUMBER;
   lv2_standard_code   constant_standard.object_code%TYPE;
   lv2_object_id varchar2(32);
   lr_analyse_sample strm_pc_analysis%ROWTYPE;
   ln_mol_wt NUMBER;
   lv2_phase          VARCHAR2(32);

BEGIN

   lr_analyse_sample := ec_strm_pc_analysis.row_by_pk(p_object_id,p_pc_id,p_daytime);
   lv2_standard_code := EcDp_System.getAttributeText(lr_analyse_sample.daytime, 'STANDARD_CODE');
   lv2_object_id := ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code);

   FOR cur_rec IN c_tot_wt1(p_object_id,p_pc_id,p_daytime) LOOP

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
   p_pc_id     VARCHAR2,
   p_sampling_method    VARCHAR2,
   p_mol_pct            NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

   ln_return_val       NUMBER;
   lv2_standard_code   constant_standard.object_code%TYPE;
   lv2_object_id varchar2(32);
   lr_analyse_sample strm_pc_analysis%ROWTYPE;
   lv2_phase          VARCHAR2(32);

BEGIN

   lv2_standard_code := EcDp_System.getAttributeText(p_daytime, 'STANDARD_CODE');
   lv2_object_id := ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code);

   ln_return_val := p_mol_pct * ec_component_constant.mol_wt(lv2_object_id,
                                                             p_component_no,
                                                             p_daytime,
                                                             '<=');
   -- Try analysis to get residue components
   IF ln_return_val IS NULL THEN

         lr_analyse_sample := EcDp_Stream_Profit_Centre.getAnalysisSample(p_object_id,
                                                                    --p_analysis_type,
                                                                    p_sampling_method,
																	p_pc_id,
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
   p_pc_id              VARCHAR2,
   p_sampling_method    VARCHAR2,
   p_weight_pct         NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

   ln_return_val         NUMBER;
   lv2_standard_code    constant_standard.object_code%TYPE;
   lv2_object_id        varchar2(32);
   lr_analyse_sample strm_pc_analysis%ROWTYPE;
   lv2_phase          VARCHAR2(32);

BEGIN

   lv2_standard_code := EcDp_System.getAttributeText(p_daytime,'STANDARD_CODE');
   lv2_object_id := ecdp_objects.GetObjIDFromCode('CONSTANT_STANDARD',lv2_standard_code);

   ln_return_val := p_weight_pct / ec_component_constant.mol_wt(lv2_object_id,
                                                                p_component_no,
                                                                p_daytime,
                                                                '<=');
   IF ln_return_val IS NULL THEN


      lr_analyse_sample := EcDp_Stream_Profit_Centre.getAnalysisSample(p_object_id, p_sampling_method,p_pc_id,p_daytime);

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


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : checkAnalysisLock
-- Description    :
--
-- Preconditions  : Checks whether a valid last dated analysis record affects a locked month.
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: EcDp_Stream_Profit_Centre.getNextAnalysisSample,
--                  EcDp_Stream_Profit_Centre.getLastAnalysisSample,
--                  EcDp_Month_Lock.checkUpdateOfLDOForLock,
--                  EcDp_Month_Lock.buildIdentifierString,
--                  EcDp_Month_Lock.checkIfColumnsUpdated,
--                  EcDp_Month_Lock.validatePeriodForLockOverlap
--
-- Configuration
-- required       :
--
-- Behaviour      : Allows certain changes in valid dates if they appear outside locked month.
--
-- Updating sample data is not allowed if the period of the current record and the trailing next record (if any)
-- overlap a locked month.
--
-- Updating VALID_FROM_DATE is not allowed if the following situations appear:
--
--   Current or the new date values are within a locked month. Except it should be possible to move the VALID_FROM_DATE for analysis 4 from early April to the 1st of May in order to make the analysis 3 valid throughout April.
--   The period of the new dated analysis and the next trailing analysis (if any) overlap another locked period.
--   The date transition on a locked period passes by a locked month. Moving analysis 3 to June is allowed, but not to move analysis 4 to June.
--
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkAnalysisLock(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list)
--</EC-DOC>
IS

ld_new_current_valid DATE;
ld_old_current_valid DATE;
ld_new_next_valid DATE;
ld_old_next_valid DATE;
ld_old_prev_valid DATE;
lv2_new_status VARCHAR2(100);
lv2_old_status VARCHAR2(100);

ld_locked_month DATE;
lv2_id VARCHAR2(2000);

lr_analysis strm_pc_analysis%ROWTYPE;
lv2_columns_updated VARCHAR2(1);
lv2_valid_from_name  VARCHAR2(100);

lv2_o_obj_id                  VARCHAR2(32);
lv2_n_obj_id                  VARCHAR2(32);

BEGIN

   IF p_new_lock_columns.exists('VALID_FROM_DATE') THEN
      ld_new_current_valid := p_new_lock_columns('VALID_FROM_DATE').column_data.AccessDate;
      ld_old_current_valid := p_old_lock_columns('VALID_FROM_DATE').column_data.AccessDate;
      lv2_valid_from_name := 'VALID_FROM_DATE';
   ELSIF p_new_lock_columns.exists('VALID_FROM') THEN
      ld_new_current_valid := p_new_lock_columns('VALID_FROM').column_data.AccessDate;
      ld_old_current_valid := p_old_lock_columns('VALID_FROM').column_data.AccessDate;
      lv2_valid_from_name := 'VALID_FROM';
   ELSE
      ld_new_current_valid := p_new_lock_columns('DAYTIME').column_data.AccessDate;
      ld_old_current_valid := p_old_lock_columns('DAYTIME').column_data.AccessDate;
      lv2_valid_from_name := 'DAYTIME';
   END IF;

   IF p_old_lock_columns.EXISTS('OBJECT_ID') THEN
      lv2_o_obj_id := p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;

   IF p_new_lock_columns.EXISTS('OBJECT_ID') THEN
      lv2_n_obj_id := p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
   END IF;

   IF NOT (ld_new_current_valid IS NULL AND ld_old_current_valid IS NULL) THEN


      lv2_new_status := p_new_lock_columns('ANALYSIS_STATUS').column_data.Accessvarchar2;
      lv2_old_status := p_old_lock_columns('ANALYSIS_STATUS').column_data.Accessvarchar2;

      IF p_operation = 'INSERTING' THEN -- Only when inserting new valid analysis

         IF lv2_new_status = 'APPROVED' THEN -- Only test approved records

            lr_analysis := EcDp_Stream_Profit_Centre.getNextAnalysisSample
			(
                                 p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
								 p_new_lock_columns('PROFIT_CENTRE_ID').column_data.AccessVarchar2,
                                 ld_new_current_valid,
								 p_new_lock_columns('DAYTIME').column_data.AccessDate);

            ld_new_next_valid := lr_analysis.valid_from_date;
            lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);
            EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_new_current_valid, ld_new_next_valid, lv2_id, lv2_n_obj_id);

         END IF;

      ELSIF p_operation = 'UPDATING' THEN

         IF Nvl(lv2_new_status,'X') = 'APPROVED' OR Nvl(lv2_old_status,'Y') = 'APPROVED' THEN -- Only test on approved records

            lv2_id := EcDp_Month_Lock.buildIdentifierString(p_new_lock_columns);

            -- get the next valid daytime
            lr_analysis := EcDp_Stream_Profit_Centre.getNextAnalysisSample(
            p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
			p_new_lock_columns('PROFIT_CENTRE_ID').column_data.AccessVarchar2,
            ld_new_current_valid,
			p_new_lock_columns('DAYTIME').column_data.AccessDate);

            ld_new_next_valid := lr_analysis.valid_from_date;

            lr_analysis := EcDp_Stream_Profit_Centre.getNextAnalysisSample(
                                  p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
								  p_new_lock_columns('PROFIT_CENTRE_ID').column_data.AccessVarchar2,
                                  ld_old_current_valid,
								  p_new_lock_columns('DAYTIME').column_data.AccessDate);

            ld_old_next_valid := lr_analysis.valid_from_date;

            IF ld_new_next_valid = ld_old_current_valid THEN
               ld_new_next_valid := ld_old_next_valid;
            END IF;

            -- Get previous record
--todo
            lr_analysis := EcDp_Stream_Profit_Centre.getLastAnalysisSample(
                           p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
						   p_new_lock_columns('PROFIT_CENTRE_ID').column_data.AccessVarchar2,
                           ld_old_current_valid - 1/86400,
						   p_new_lock_columns('DAYTIME').column_data.AccessDate);

            ld_old_prev_valid := lr_analysis.valid_from_date;

            p_old_lock_columns(lv2_valid_from_name).is_checked := 'Y';
            IF EcDp_Month_Lock.checkIfColumnsUpdated(p_old_lock_columns) THEN
               lv2_columns_updated := 'Y';
            ELSE
               lv2_columns_updated := 'N';
            END IF;

            EcDp_Month_Lock.checkUpdateOfLDOForLock(ld_new_current_valid,
                                                   ld_old_current_valid,
                                                   ld_new_next_valid,
                                                   ld_old_next_valid,
                                                   ld_old_prev_valid,
                                                   lv2_columns_updated,
                                                   lv2_id,
                                                   lv2_n_obj_id);

         END IF; -- Approved records

      ELSIF p_operation = 'DELETING' THEN -- Only when deleting a valid analysis

         IF lv2_old_status = 'APPROVED' THEN -- Only test approved records

            lr_analysis := EcDp_Stream_Profit_Centre.getNextAnalysisSample(
                               p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,
							   p_old_lock_columns('PROFIT_CENTRE_ID').column_data.AccessVarchar2,
                               ld_old_current_valid,
							   p_new_lock_columns('DAYTIME').column_data.AccessDate);

            ld_old_next_valid := lr_analysis.valid_from_date;
            lv2_id := EcDp_Month_Lock.buildIdentifierString(p_old_lock_columns);
            EcDp_Month_Lock.validatePeriodForLockOverlap(p_operation, ld_old_current_valid, ld_old_next_valid, lv2_id, lv2_o_obj_id);

         END IF;

      END IF;
   END IF;

END checkAnalysisLock;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : CheckFluidComponentLock
-- Description    :
--
-- Preconditions  : Checks whether a fluid component analysis record affects a locked month.
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: ec_object_fluid_analysis,
--                  checkAnalysisLock
--
-- Configuration
-- required       :
--
-- Behaviour      : Considered as an update on the parent analysis record.
--
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE CheckFluidComponentLock(p_operation VARCHAR2, p_new_lock_columns EcDp_Month_lock.column_list, p_old_lock_columns EcDp_Month_lock.column_list)
--</EC-DOC>
IS

lr_analysis strm_pc_analysis%ROWTYPE;
l_new_lock_columns EcDp_Month_lock.column_list;
l_old_lock_columns EcDp_Month_lock.column_list;

BEGIN

   IF p_operation IN ('INSERTING','UPDATING') THEN
      lr_analysis := ec_strm_pc_analysis.row_by_pk(p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2,p_new_lock_columns('PROFIT_CENTRE_ID').column_data.AccessVarchar2,p_new_lock_columns('DAYTIME').column_data.AccessDate);

   ELSE
      lr_analysis := ec_strm_pc_analysis.row_by_pk(p_old_lock_columns('OBJECT_ID').column_data.AccessVarchar2,p_old_lock_columns('PROFIT_CENTRE_ID').column_data.AccessVarchar2,p_old_lock_columns('DAYTIME').column_data.AccessDate);
   END IF;

   IF p_new_lock_columns.exists('VALID_FROM_DATE') THEN

      EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'VALID_FROM_DATE','VALID_FROM_DATE','DATE','N','N',AnyData.Convertdate(lr_analysis.valid_from_date));
      EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'VALID_FROM_DATE','VALID_FROM_DATE','DATE','N','N',AnyData.Convertdate(lr_analysis.valid_from_date));

   ELSIF  p_new_lock_columns.exists('VALID_FROM') THEN

      EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'VALID_FROM','VALID_FROM_DATE','DATE','N','N',AnyData.Convertdate(lr_analysis.valid_from_date));
      EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'VALID_FROM','VALID_FROM_DATE','DATE','N','N',AnyData.Convertdate(lr_analysis.valid_from_date));

   ELSE

      EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'DAYTIME','DAYTIME','DATE','N','N',AnyData.Convertdate(lr_analysis.daytime));
      EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'DAYTIME','DAYTIME','DATE','N','N',AnyData.Convertdate(lr_analysis.daytime));

   END IF;





   -- Populate parent table columns in structure.
   EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'CLASS_NAME','FLUID_ANALYSIS_COMPONENT','VARCHAR2','N','N', NULL);
   EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'OBJECT_ID','OBJECT_ID','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.object_id));
   EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'PROFIT_CENTRE_ID','PROFIT_CENTRE_ID','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.profit_centre_id));
   EcDp_Month_Lock.addParameterToList(l_new_lock_columns,'ANALYSIS_STATUS','ANALYSIS_STATUS','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.analysis_status));

   EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'CLASS_NAME','FLUID_ANALYSIS_COMPONENT','VARCHAR2','N','N', NULL);
   EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'OBJECT_ID','OBJECT_ID','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.object_id));
   EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'PROFIT_CENTRE_ID','PROFIT_CENTRE_ID','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.profit_centre_id));
   EcDp_Month_Lock.addParameterToList(l_old_lock_columns,'ANALYSIS_STATUS','ANALYSIS_STATUS','VARCHAR2','N','N',AnyData.ConvertVarchar2(lr_analysis.analysis_status));

   -- Do whatever you want as long the parent is unlocked
   checkAnalysisLock('UPDATING', l_new_lock_columns, l_old_lock_columns);

END CheckFluidComponentLock;


END EcBp_Comp_PC_Analysis;