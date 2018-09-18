CREATE OR REPLACE PACKAGE BODY EcDp_Stream_Profit_Centre IS
/****************************************************************
** Package        :  EcDp_Stream_Profit_Centre, body part.
**
** $Revision: 1.3 $
**
** Purpose        :  This package is responsible for data access to
**                   fluid analysis figures for any analysis object.
**
** Documentation  :  www.energy-components.com
**
** Created  : 15.02.2010  Kenneth Masamba
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 02.06.2010 leongsei ECPD-13328: Modified function normalizeCompTo100 to create revision
** 08.10.2014 sohalran ECPD-27402: Remove Commit statement from convCompBetweenMolWt and set_analysis_rs procedure.
*****************************************************************/

CURSOR c_analysis(cp_object_id         stream.object_id%TYPE,
                  cp_daytime           DATE,
				  c_pc_id VARCHAR2
                  )
IS
SELECT *
FROM strm_pc_analysis ofa
WHERE ofa.object_id = cp_object_id
AND ofa.profit_centre_id = c_pc_id
AND ofa.daytime = cp_daytime;

CURSOR c_comp1(cp_object_id VARCHAR2,cp_pc_id VARCHAR2,cp_daytime DATE) IS
SELECT *
FROM strm_pc_comp_analysis
WHERE OBJECT_ID = cp_object_id
AND PROFIT_CENTRE_ID = cp_pc_id
AND DAYTIME = cp_daytime
ORDER BY component_no
FOR UPDATE;

CURSOR c_class_view(p_class_name IN VARCHAR2) IS
  SELECT class_name, EcDp_ClassMeta_Cnfg.getClassViewName(class_name, class_type) AS source_name
  FROM class_cnfg
  WHERE class_name = p_class_name ;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getAnalysisSample
-- Description  : Returns the analysis sample given by logical key.
--
--
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: strm_pc_analysis
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour
--
---------------------------------------------------------------------------------------------------
FUNCTION getAnalysisSample (
   p_object_id        stream.object_id%TYPE,
   p_sampling_method  VARCHAR2,
   p_pc_id            VARCHAR2,
   p_daytime          DATE)

RETURN strm_pc_analysis%ROWTYPE
--</EC-DOC>
IS

CURSOR c_analyse(
   cp_object_id        stream.object_id%TYPE,
   cp_sampling_method    VARCHAR2,
   cp_pc_id  VARCHAR2,
   cp_daytime          DATE
) IS
SELECT *
FROM strm_pc_analysis
WHERE object_id = cp_object_id
AND sampling_method = cp_sampling_method
AND profit_centre_id = cp_pc_id
AND daytime = cp_daytime;

lr_analysis_sample strm_pc_analysis%ROWTYPE;
lv2_analysis_ref_id varchar2(32);

BEGIN
   lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(p_object_id, p_daytime);

   FOR cur_rec IN c_analyse(lv2_analysis_ref_id,p_sampling_method,p_pc_id, p_daytime) LOOP

      lr_analysis_sample := cur_rec;

   END LOOP;

   RETURN lr_analysis_sample;

END getAnalysisSample;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getPeriodAnalysisSample
-- Description  : Returns the analysis sample given by logical key.
--
--
--
-- Preconditions: Used from the business function Period Stream Gas Component Analysis
-- Postcondition:
--
-- Using Tables: strm_pc_analysis
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour
--
---------------------------------------------------------------------------------------------------

FUNCTION getPeriodAnalysisSample (
   p_object_id            stream.object_id%TYPE,
   p_analysis_type        VARCHAR2,
   p_sampling_method      VARCHAR2,
   p_daytime              DATE,
   p_daytime_summer_time  VARCHAR2)

RETURN strm_analysis_event%ROWTYPE
--</EC-DOC>
IS

CURSOR c_analyse(
   cp_object_id            stream.object_id%TYPE,
   cp_analysis_type        VARCHAR2,
   cp_sampling_method      VARCHAR2,
   cp_daytime              DATE,
   cp_daytime_summer_time  VARCHAR2
) IS
SELECT *
FROM strm_analysis_event
WHERE object_id = cp_object_id
AND analysis_type = cp_analysis_type
AND sampling_method = cp_sampling_method
AND daytime = cp_daytime
AND daytime_summer_time = cp_daytime_summer_time;

lr_analysis_sample strm_analysis_event%ROWTYPE;
lv2_analysis_ref_id varchar2(32);

BEGIN
   lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(p_object_id, p_daytime);

   FOR cur_rec IN c_analyse(lv2_analysis_ref_id, p_analysis_type, p_sampling_method, p_daytime,p_daytime_summer_time) LOOP

      lr_analysis_sample := cur_rec;

   END LOOP;

   RETURN lr_analysis_sample;

END getPeriodAnalysisSample;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getLastAnalysisSample
-- Description  : Returns the last analysis sample previous or equal to the daytime given by the logical key.
--
--
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: strm_pc_analysis
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour
--
---------------------------------------------------------------------------------------------------
FUNCTION getLastAnalysisSample(
   p_object_id        stream.object_id%TYPE,
   p_pc_id  VARCHAR2,
   p_valid_from_date          DATE,
   p_daytime          DATE)

RETURN strm_pc_analysis%ROWTYPE
--</EC-DOC>
IS

  lr_analysis_sample  strm_pc_analysis%ROWTYPE;
  lv2_analysis_ref_id varchar2(32);

  CURSOR c_analyse(
    cp_object_id        stream.object_id%TYPE,
	cp_pc_id VARCHAR2,
	cp_valid_from_date          DATE,
    cp_daytime          DATE
  ) IS
    SELECT *
      FROM strm_pc_analysis ofa
     WHERE ofa.object_id = cp_object_id
	   AND ofa.profit_centre_id = cp_pc_id
	   AND ofa.daytime = cp_daytime
       AND (ofa.analysis_status = 'APPROVED' OR ofa.analysis_status IS NULL)
       AND ofa.valid_from_date = (
           SELECT MAX(ofb.valid_from_date)
             FROM strm_pc_analysis ofb
            WHERE ofb.object_id = ofa.object_id
              AND (ofb.analysis_status = 'APPROVED' OR ofb.analysis_status IS NULL)
              AND ofb.valid_from_date <= cp_valid_from_date);


BEGIN

  lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(p_object_id, p_daytime);

    FOR cur_rec IN c_analyse(lv2_analysis_ref_id, p_pc_id, p_valid_from_date, p_daytime) LOOP

      lr_analysis_sample := cur_rec;

    END LOOP;

  RETURN lr_analysis_sample;

END getLastAnalysisSample;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getNextAnalysisSample
-- Description  : Returns the next valid and approved analysis sample trailing to the daytime
--                given by the logical key.
--
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: strm_pc_analysis
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour
--
---------------------------------------------------------------------------------------------------
FUNCTION getNextAnalysisSample(
   p_object_id        stream.object_id%TYPE,
   p_pc_id VARCHAR2,
   p_valid_from_date          DATE,
   p_daytime             DATE)

RETURN STRM_PC_ANALYSIS%ROWTYPE
--</EC-DOC>
IS
  lr_analysis_sample  STRM_PC_ANALYSIS%ROWTYPE;
  lv2_analysis_ref_id varchar2(32);

  CURSOR c_analyse(
    cp_object_id        stream.object_id%TYPE,
	cp_pc_id            VARCHAR2,
	cp_valid_from_date   DATE,
    cp_daytime          DATE
  ) IS
    SELECT *
      FROM STRM_PC_ANALYSIS ofa
     WHERE ofa.object_id = cp_object_id
	   AND ofa.profit_centre_id = cp_pc_id
	   AND ofa.daytime = cp_daytime
       AND (ofa.analysis_status = 'APPROVED' OR ofa.analysis_status IS NULL)
       AND ofa.valid_from_date = (
           SELECT MIN(ofb.valid_from_date)
             FROM STRM_PC_ANALYSIS ofb
            WHERE ofb.object_id = ofa.object_id
              AND (ofb.analysis_status = 'APPROVED' OR ofb.analysis_status IS NULL)
              AND ofb.valid_from_date > cp_valid_from_date);

BEGIN

  FOR cur_rec IN c_analyse(lv2_analysis_ref_id, p_pc_id, p_valid_from_date,p_daytime) LOOP

    lr_analysis_sample := cur_rec;

  END LOOP;

  RETURN lr_analysis_sample;

END getNextAnalysisSample;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getPeriodAnalysisNumberByUK
-- Description    : Returns the analysis_no for the record having the unique key specified in arguments.
--
--
--
--
-- Preconditions: Used from the business function Period Stream Gas Component Analysis
-- Postcondition:
--
-- Using Tables: strm_analysis_event
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
--
---------------------------------------------------------------------------------------------------
FUNCTION getPeriodAnalysisNumberByUK (
   p_object_id            stream.object_id%TYPE,
   p_analysis_type        VARCHAR2,
   p_daytime            DATE,
   p_sampling_method      VARCHAR2,
   p_daytime_summer_time        VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_analyse(
   cp_object_id        stream.object_id%TYPE,
   cp_analysis_type        VARCHAR2,
   cp_daytime              DATE,
   cp_sampling_method      VARCHAR2,
   cp_daytime_summer_time   VARCHAR2
) IS
SELECT  *
FROM   strm_analysis_event
WHERE   object_id = cp_object_id
AND   analysis_type = cp_analysis_type
AND   daytime = cp_daytime
AND   sampling_method = cp_sampling_method
AND   daytime_summer_time = cp_daytime_summer_time;

lv_analysis_no strm_analysis_event.analysis_no%TYPE;
lv2_analysis_ref_id varchar2(32);

BEGIN
   lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(p_object_id, p_daytime);

   FOR cur_rec IN c_analyse(lv2_analysis_ref_id, p_analysis_type, p_daytime, p_sampling_method, p_daytime_summer_time) LOOP

      lv_analysis_no := cur_rec.analysis_no;

   END LOOP;

   RETURN lv_analysis_no;
END getPeriodAnalysisNumberByUK;

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
-- Using Tables: strm_pc_comp_analysis, COMP_SET_LIST
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour: Only instantiate if analysis exist and there is no records in the strm_pc_comp_analysis table
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE createCompSetForAnalysis(p_comp_set VARCHAR2 DEFAULT NULL, p_daytime DATE, p_pc_id VARCHAR2, p_object_id VARCHAR2, p_user_id VARCHAR2 DEFAULT NULL)

--</EC-DOC>
IS

CURSOR c_current_components(cp_comp_set varchar2) IS
SELECT c.component_no
FROM comp_set_list c
WHERE c.component_set = cp_comp_set
AND p_daytime >= c.daytime AND (p_daytime < c.end_date OR c.end_date IS NULL);

   ln_no_components NUMBER;
   lr_analysis               STRM_PC_ANALYSIS%ROWTYPE;
   lr_next_analysis          STRM_PC_ANALYSIS%ROWTYPE;
   lv2_comp_set              VARCHAR2(16);

BEGIN

   lr_analysis := Ec_STRM_PC_ANALYSIS.row_by_pk(p_object_id,p_pc_id,p_daytime);
   --get the configured component set, if null then use the default from the parameter
   lv2_comp_set := nvl(ecbp_fluid_analysis.getCompSet(lr_analysis.object_class_name , lr_analysis.object_id , p_daytime, p_comp_set),p_comp_set);

   IF lr_analysis.valid_from_date IS NOT NULL AND lr_analysis.analysis_status = 'APPROVED' THEN

      lr_next_analysis := EcDp_Stream_Profit_Centre.getNextAnalysisSample(lr_analysis.object_id,lr_analysis.profit_centre_id,lr_analysis.valid_from_date,lr_analysis.daytime);
      EcDp_month_lock.validatePeriodForLockOverlap('UPDATING', lr_analysis.valid_from_date, lr_next_analysis.valid_from_date, 'EcDp_Stream_Profit_Centre.createCompSetForAnalysis: can not do this for a locked period', lr_analysis.object_id);

   END IF;

   ln_no_components := 0;

   IF ec_STRM_PC_ANALYSIS.sampling_method(p_object_id,p_pc_id,p_daytime) IS NOT NULL THEN

      SELECT count(component_no)
      INTO ln_no_components
      FROM STRM_PC_COMP_ANALYSIS
      WHERE object_id = p_object_id
	  AND profit_centre_id = p_pc_id
	  AND daytime = p_daytime;

      IF ln_no_components = 0 THEN

         FOR cur_rec IN c_current_components(lv2_comp_set) LOOP

            INSERT INTO STRM_PC_COMP_ANALYSIS (component_no, object_id, profit_centre_id, daytime, created_by)
            VALUES (cur_rec.component_no, p_object_id, p_pc_id, p_daytime, p_user_id);

         END LOOP;

      END IF;

   END IF;

END createCompSetForAnalysis;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : createCompSetForPeriodAnalysis
-- Description  : Instantiates all hydrocarbon components associated with the current component set
--                into the composition and assigns them to the analysis given.
--
--
--
-- Preconditions: Used from the business function Period Stream Gas Component Analysis
-- Postcondition: Possibly uncommitted changes.
--
-- Using Tables: STRM_ANALYSIS_COMPONENT, COMP_SET_LIST
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour: Only instantiate if analysis exist and there is no records in the strm_analysis_component table
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE createCompSetForPeriodAnalysis(p_object_id VARCHAR2, p_sampling_method VARCHAR2, p_comp_set VARCHAR2, p_daytime DATE, p_user_id VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

lv_summer_time_flag  VARCHAR2(1);
ln_analysis_no        NUMBER;
ln_no_components   NUMBER;
lv_pday_object_id    VARCHAR2(32);

CURSOR c_current_components IS
SELECT c.component_no
FROM comp_set_list c
WHERE c.component_set = p_comp_set
AND p_daytime >= c.daytime AND (p_daytime < c.end_date OR c.end_date IS NULL);


BEGIN

lv_pday_object_id := EcDp_ProductionDay.findProductionDayDefinition(NULL, p_object_id, p_daytime);

lv_summer_time_flag := EcDp_Date_Time.summertime_flag(p_daytime, NULL, lv_pday_object_id); -- NOTYET What if daytime intercepts winter and summertime

ln_analysis_no := EcDp_Stream_Profit_Centre.getPeriodAnalysisNumberByUK(p_object_id,p_comp_set,p_daytime,p_sampling_method,lv_summer_time_flag);

ln_no_components := 0;

   IF ec_strm_analysis_event.analysis_type(ln_analysis_no) IS NOT NULL THEN

      SELECT count(component_no)
      INTO ln_no_components
      FROM strm_analysis_component
      WHERE analysis_no = ln_analysis_no;

      IF ln_no_components = 0 THEN

         FOR cur_rec IN c_current_components LOOP

            INSERT INTO strm_analysis_component (component_no, analysis_no, created_by)
            VALUES (cur_rec.component_no, ln_analysis_no, p_user_id);

         END LOOP;

      END IF;

   END IF;

END createCompSetForPeriodAnalysis;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : delCompSetForPeriodAnalysis
-- Description  : This procedure is called from class STRM_GAS_ANALYSIS_EVENT as a before delete trigger.
--      Used to delete the component set that belongs to the period analysis which is being deleted.
--
--
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: STRM_ANALYSIS_COMPONENT, COMP_SET_LIST
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE delCompSetForPeriodAnalysis(p_object_id VARCHAR2, p_sampling_method VARCHAR2, p_comp_set VARCHAR2, p_daytime DATE)
--</EC-DOC>
IS
lv_summer_time_flag  VARCHAR2(1);
ln_analysis_no        NUMBER;
ln_no_components   NUMBER;
lv_pday_object_id    VARCHAR2(32);


CURSOR c_current_components IS
SELECT c.component_no
FROM comp_set_list c
WHERE c.component_set = p_comp_set
AND p_daytime >= c.daytime AND (p_daytime < c.end_date OR c.end_date IS NULL);

BEGIN

lv_pday_object_id := EcDp_ProductionDay.findProductionDayDefinition(NULL, p_object_id, p_daytime);

lv_summer_time_flag := EcDp_Date_Time.summertime_flag(p_daytime, NULL, lv_pday_object_id); -- NOTYET What if daytime intercepts winter and summertime

ln_analysis_no := EcDp_Stream_Profit_Centre.getPeriodAnalysisNumberByUK(p_object_id,p_comp_set,p_daytime,p_sampling_method,lv_summer_time_flag);

ln_no_components := 0;

   IF ec_strm_analysis_event.analysis_type(ln_analysis_no) IS NOT NULL THEN

      SELECT count(component_no)
      INTO ln_no_components
      FROM strm_analysis_component
      WHERE analysis_no = ln_analysis_no;

      IF ln_no_components <> 0 THEN

         FOR cur_rec IN c_current_components LOOP

    DELETE   FROM strm_analysis_component
    WHERE   component_no = cur_rec.component_no
    AND   analysis_no = ln_analysis_no;
        END LOOP;

      END IF;

   END IF;

END delCompSetForPeriodAnalysis;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : convCompBetweenMolWt
-- Description  : Convert component between Mol% and Wt% in analysis for object given.
--
--
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: strm_pc_comp_analysis
--
-- Using functions: EcBp_Comp_PC_Analysis.calcCompMolPct
--
-- Configuration
-- required:
--
-- Behaviour: If one column is complete and the other one has at least one NULL value, the whole column get NULLed out
--            and recalculated from the other.
--            wt%   -> mole%
--            mole% -> wt%
--
---------------------------------------------------------------------------------------------------
PROCEDURE convCompBetweenMolWt(
   p_object_id        stream.object_id%TYPE,
   p_daytime          DATE,
   p_pc_id            VARCHAR2,
   p_valid_from_date DATE,
   p_user_id          VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS
   ln_tot_mol_frac    NUMBER :=0;
   ln_tot_mass_frac   NUMBER :=0;
   ln_count_blank_mol NUMBER :=0;
   ln_count_blank_wt  NUMBER :=0;

   lr_analysis       strm_pc_analysis%ROWTYPE;
   lr_next_analysis  strm_pc_analysis%ROWTYPE;


BEGIN

   -- lock test
   lr_analysis := EcDp_Stream_Profit_Centre.getLastAnalysisSample(p_object_id,p_pc_id,p_valid_from_date,p_daytime);

   IF lr_analysis.valid_from_date IS NOT NULL AND lr_analysis.analysis_status = 'APPROVED' THEN

      lr_next_analysis := EcDp_Stream_Profit_Centre.getNextAnalysisSample(p_object_id,p_pc_id,p_valid_from_date,p_daytime);

      EcDp_month_lock.validatePeriodForLockOverlap('UPDATING', lr_analysis.valid_from_date, lr_next_analysis.valid_from_date, 'EcDp_Stream_Profit_Centre.convCompBetweenMolWt: can not do this for a locked period', p_object_id);

   END IF;

   FOR comp_rec IN c_comp1(p_object_id,p_pc_id,p_daytime) LOOP
       if comp_rec.wt_pct is null then
          ln_count_blank_wt := ln_count_blank_wt+1;
       end if;

       if comp_rec.mol_pct is null then
          ln_count_blank_mol := ln_count_blank_mol+1;
       end if;

   END LOOP;

-- Make sure the situation is as expected: One column is complete, the other has one or more missing values (NULL). In any other case, just exit.
   If (ln_count_blank_wt = 0 and ln_count_blank_mol > 0) OR (ln_count_blank_mol = 0 and ln_count_blank_wt > 0) THEN

       If ln_count_blank_wt = 0 and ln_count_blank_mol > 0 THEN

          update strm_pc_comp_analysis
          set    mol_pct = NULL
          where  object_id = p_object_id
		  and profit_centre_id = p_pc_id
		  and daytime = p_daytime;

          ln_tot_mol_frac  := EcBp_Comp_PC_Analysis.calcTotMolFrac(p_object_id,p_pc_id,p_daytime);

       end if;

       If ln_count_blank_mol = 0 and ln_count_blank_wt > 0 THEN

          update strm_pc_comp_analysis
          set    wt_pct = NULL
          where  object_id = p_object_id
		  and profit_centre_id = p_pc_id
		  and daytime = p_daytime;

          ln_tot_mass_frac := EcBp_Comp_PC_Analysis.calcTotMassFrac(p_object_id,p_pc_id,p_daytime);

       end if;

       FOR ana_rec IN c_analysis(p_object_id,
                                 p_daytime,
								 p_pc_id)
       LOOP

          FOR comp_rec IN c_comp1(ana_rec.OBJECT_ID,ana_rec.PROFIT_CENTRE_ID, ana_rec.DAYTIME) LOOP

           IF comp_rec.mol_pct IS NULL and ln_tot_mol_frac > 0 THEN
                 UPDATE strm_pc_comp_analysis
                 SET      mol_pct = 100 * EcBp_Comp_PC_Analysis.calcCompMolFrac( p_object_id,
                                                                       ana_rec.daytime,
                                                                       comp_rec.component_no,
																	   ana_rec.profit_centre_id,
                                                                       ana_rec.sampling_method,
                                                                       comp_rec.wt_pct) / ln_tot_mol_frac,
                          last_updated_by=p_user_id
                 WHERE CURRENT OF c_comp1;
                 END IF;

           IF comp_rec.wt_pct IS NULL and ln_tot_mass_frac > 0 THEN

                   UPDATE   strm_pc_comp_analysis
                   SET      wt_pct = 100 * EcBp_Comp_PC_Analysis.calcCompMassFrac( p_object_id,
                                                                    ana_rec.daytime,
                                                                    comp_rec.component_no,
																	ana_rec.profit_centre_id,
                                                                    ana_rec.sampling_method,
                                                                    comp_rec.mol_pct) / ln_tot_mass_frac,
                            last_updated_by=p_user_id
                   WHERE CURRENT OF c_comp1;
             END IF;

          END LOOP; -- component
       END LOOP; -- analysis

    END IF; -- Make sure the situation...

END convCompBetweenMolWt;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : normalizeCompTo100
-- Description  : Normalize sum(wt% or mol%) to 100 for Stream.
--                Multiply with factor 100/sum(%).
--                Add remaining fraction to largerst component.
--
--    Sum(wt%)   = 100
--    Sum(mole%) = 100
--
--
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: strm_pc_comp_analysis
--
-- Using functions: EcBp_Comp_PC_Analysis.calcCompMolPct
--
-- Configuration
-- required:
--
-- Behaviour:
--
---------------------------------------------------------------------------------------------------
PROCEDURE normalizeCompTo100(
  p_object_id        stream.object_id%TYPE,
  p_daytime          DATE,
  p_pc_id            VARCHAR2,
  p_valid_from_date  DATE,
  p_user_id          VARCHAR2 DEFAULT NULL,
  p_class_name       VARCHAR2 DEFAULT 'STRM_PC_COMP_ANALYSIS')
--</EC-DOC>
IS
  TYPE compTabTyp IS TABLE OF EcDp_Type.pb_comp_number%TYPE -- Return a PowerBuilder compliant number
  INDEX BY binary_integer;

  i                 NUMBER;
  ln_no             NUMBER;

  ln_mol_tot        NUMBER;
  ln_mol_max        NUMBER;
  ln_mol_max_i      NUMBER;
  ln_mol_fact       NUMBER;
  mol_compTab       compTabTyp;

  ln_wt_tot         NUMBER;
  ln_wt_max         NUMBER;
  ln_wt_max_i       NUMBER;
  ln_wt_fact        NUMBER;
  wt_compTab        compTabTyp;
  lr_analysis       strm_pc_analysis%ROWTYPE;
  lr_next_analysis  strm_pc_analysis%ROWTYPE;
  ln_decimals       NUMBER;

  lv_sql            VARCHAR2(4000);
  j                 NUMBER;
  lv_view_name      VARCHAR2(24);

BEGIN

  -- lock test
  lr_analysis := EcDp_Stream_Profit_Centre.getLastAnalysisSample(p_object_id,p_pc_id,p_valid_from_date,p_daytime);

  IF lr_analysis.valid_from_date IS NOT NULL AND lr_analysis.analysis_status = 'APPROVED' THEN
    lr_next_analysis := EcDp_Stream_Profit_Centre.getNextAnalysisSample(p_object_id,p_pc_id,p_valid_from_date,p_daytime);
    EcDp_month_lock.validatePeriodForLockOverlap('UPDATING', lr_analysis.valid_from_date, lr_next_analysis.valid_from_date, 'EcDp_Stream_Profit_Centre.normalizeCompTo100: can not do this for a locked period', p_object_id);
  END IF;

  ln_decimals := ec_ctrl_system_attribute.attribute_value(p_daytime,'DECIMAL_COMP_NORMALIZE','<=');

  i                 := 0;

  ln_mol_tot        := 0;
  ln_mol_max        := 0;
  ln_mol_max_i      := 0;
  ln_mol_fact       := 0;

  ln_wt_tot         := 0;
  ln_wt_max         := 0;
  ln_wt_max_i       := 0;
  ln_wt_fact        := 0;

  FOR ana_rec IN c_analysis(p_object_id,
                            p_daytime,
                            p_pc_id)
  LOOP

    FOR comp_rec IN c_comp1(ana_rec.OBJECT_ID, ana_rec.profit_centre_id, ana_rec.daytime)
    LOOP
      i := i + 1;

      --mol
      mol_compTab(i) := comp_rec.mol_pct;
      ln_mol_tot     := ln_mol_tot + mol_compTab(i);
      IF ln_mol_max < mol_compTab(i) THEN
        ln_mol_max     := mol_compTab(i);
        ln_mol_max_i   := i;
      END IF;

      --wt
      wt_compTab(i) := comp_rec.wt_pct;
      ln_wt_tot      := ln_wt_tot + wt_compTab(i);
      IF ln_wt_max < wt_compTab(i) THEN
        ln_wt_max   := wt_compTab(i);
        ln_wt_max_i := i;
      END IF;

    END LOOP; -- component

    ln_no       := i;    -- total number of records

    IF Nvl(ln_mol_tot,0) <> 0 THEN
      ln_mol_fact := 100 / ln_mol_tot;
    ELSE
      ln_mol_fact := NULL;
    END IF;

    IF Nvl(ln_wt_tot,0) <> 0 THEN
      ln_wt_fact  := 100 / ln_wt_tot;
    ELSE
      ln_wt_fact  := NULL;
    END IF;

    IF ln_mol_fact IS NULL AND ln_wt_fact IS NULL THEN
      RAISE_APPLICATION_ERROR(-20201,'Missing component value(s). All components must have a value to be able to normalize.');
    END IF;

    ln_mol_tot := 0;
    ln_wt_tot := 0;

    --Multiply with "factor" and calculate new total.
    FOR i IN 1 ..ln_no LOOP

      IF ln_mol_fact IS NOT NULL THEN
        IF ln_decimals IS NOT NULL THEN
          mol_compTab(i) := round(mol_compTab(i) * ln_mol_fact,ln_decimals);
        ELSE
          mol_compTab(i) := mol_compTab(i) * ln_mol_fact;
        END IF;
        ln_mol_tot     := ln_mol_tot + mol_compTab(i);
      END IF;

      IF ln_wt_fact IS NOT NULL THEN
        IF ln_decimals IS NOT NULL THEN
          wt_compTab(i) := round(wt_compTab(i) * ln_wt_fact,ln_decimals);
        ELSE
          wt_compTab(i)  := wt_compTab(i) * ln_wt_fact;
        END IF;
        ln_wt_tot      := ln_wt_tot + wt_compTab(i);
      END IF;

    END LOOP;

    --Add remaninig fraction (100-NewTotal) to largest component.
    IF ln_mol_fact IS NOT NULL THEN
      mol_compTab(ln_mol_max_i)  := mol_compTab(ln_mol_max_i) + (100 - ln_mol_tot);
    END IF;

    IF ln_wt_fact IS NOT NULL THEN
      wt_compTab(ln_wt_max_i)    := wt_compTab(ln_wt_max_i) + (100 - ln_wt_tot);
    END IF;

    -- Update database with result.
    i := 0;
    FOR comp_rec IN c_comp1(ana_rec.OBJECT_ID, ana_rec.PROFIT_CENTRE_ID, ana_rec.DAYTIME) LOOP
      -- Assumes that no changes has been done on component records (insert, delete, update(key values)).
      i := i + 1;

      FOR class_rec IN c_class_view(p_class_name) LOOP
        lv_view_name := class_rec.class_name;

        j := 0;
        lv_sql := 'UPDATE ' || class_rec.source_name || ' SET ';

        FOR attr_rec IN (SELECT a.attribute_name, a.db_sql_syntax, EcDp_ClassMeta_Cnfg.isDisabled(a.class_name, a.attribute_name) AS disabled_ind
                           FROM class_attribute_cnfg a
                          WHERE a.class_name = lv_view_name
                            AND EcDp_ClassMeta_Cnfg.isDisabled(a.class_name, a.attribute_name) = 'N'
                            AND a.DB_SQL_SYNTAX IN ('MOL_PCT', 'WT_PCT')) LOOP

          j := j + 1;

          IF attr_rec.db_sql_syntax = 'MOL_PCT' THEN
            IF mol_compTab(i) IS NOT NULL THEN
              lv_sql := lv_sql || attr_rec.attribute_name || ' = ' || mol_compTab(i) || ', ';
            END IF;

          ELSIF attr_rec.db_sql_syntax  = 'WT_PCT' THEN
            IF wt_compTab(i) IS NOT NULL THEN
              lv_sql := lv_sql || attr_rec.attribute_name || ' = ' || wt_compTab(i) || ', ';
            END IF;
          END IF;
        END LOOP;

        IF j != 0 THEN
          lv_sql := RTRIM(lv_sql, ', ') || ', last_updated_by = ''' || p_user_id || ''' WHERE object_id = ''' || comp_rec.object_id || ''' AND component_no = ''' || comp_rec.component_no || ''' AND profit_centre_id = ''' || comp_rec.profit_centre_id || ''' AND daytime = TO_DATE(''' || TO_CHAR(comp_rec.daytime, 'yyyymmddhh24miss') || ''', ''yyyymmddhh24miss'')';

          EcDp_DynSql.Execute_Statement(lv_sql);
        END IF;
      END LOOP;

    END LOOP;

  END LOOP; -- analysis

END normalizeCompTo100;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : auiSetProductionDay
-- Description  : Update value to strm_pc_analysis.production_day column
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: strm_pc_analysis
--
-- Using functions: EcDp_Objects.GetObjClassName,
--                  ec_well_version.op_fcty_class_1_id,
--                  ec_strm_version.op_fcty_class_1_id,
--                  Ecdp_Facility.getProductionDay
--
-- Configuration
-- required:
--
-- Behaviour:
--
---------------------------------------------------------------------------------------------------
PROCEDURE auiSetProductionDay (p_object_id       VARCHAR2, -- OBJECT ID
                               p_daytime         DATE,     -- DAYTIME
                               p_analysis_type   VARCHAR2, -- ANALYSIS TYPE
                               p_sampling_method VARCHAR2, -- SAMPLING METHOD
                               p_phase           VARCHAR2, -- PHASE
                               p_user_id         VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

      ld_production_day    production_facility.start_date%TYPE;
      lv2_obj_class_name   strm_pc_analysis.object_class_name%TYPE;

BEGIN

      lv2_obj_class_name := ecdp_objects.GetObjClassName(p_object_id);

      ld_production_day := EcDp_ProductionDay.getProductionDay(lv2_obj_class_name, p_object_id, p_daytime);

      -- Update strm_pc_analysis.production_day
      UPDATE strm_pc_analysis
         SET production_day = ld_production_day,
             last_updated_by = p_user_id
       WHERE object_id = p_object_id
         AND daytime = p_daytime
         AND sampling_method = p_sampling_method;

END auiSetProductionDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : aiSetObjectClassName
-- Description  : Update value to strm_pc_analysis.object_class_name column
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: strm_pc_analysis
--
-- Using functions: EcDp_Objects.GetObjClassName
--
-- Configuration
-- required:
--
-- Behaviour:
--
---------------------------------------------------------------------------------------------------
PROCEDURE aiSetObjectClassName (p_object_id       VARCHAR2, -- OBJECT ID
                                p_daytime         DATE,     -- DAYTIME
                                p_analysis_type   VARCHAR2, -- ANALYSIS TYPE
                                p_sampling_method VARCHAR2, -- SAMPLING METHOD
                                p_phase           VARCHAR2, -- PHASE
                                p_user_id         VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

      lv2_obj_class_name    strm_pc_analysis.object_class_name%TYPE;

BEGIN

      lv2_obj_class_name := ecdp_objects.GetObjClassName(p_object_id);

      -- Update strm_pc_analysis.object_class_name
      UPDATE strm_pc_analysis
         SET object_class_name = lv2_obj_class_name,
             last_updated_by = p_user_id
       WHERE object_id = p_object_id
         AND daytime = p_daytime
         AND sampling_method = p_sampling_method;

END aiSetObjectClassName;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getAverageOIW
-- Description  : Return the average Oil_In_Water for the Month to Date
--
--
--
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
--
---------------------------------------------------------------------------------------------------
FUNCTION getAverageOIW (
   p_object_id        stream.object_id%TYPE,
   p_analysis_type    VARCHAR2,
   p_sampling_method  VARCHAR2,
   p_analysis_status  VARCHAR2,
   p_daytime          DATE)

RETURN NUMBER
--</EC-DOC>

IS

ln_total_volume NUMBER;
ln_volume_times_oiw NUMBER;
ln_volume NUMBER;

CURSOR c_month_to_date IS
SELECT
s.daytime daytime,
AVG(ofa.oil_in_water) avg_oiw
FROM system_days s, strm_pc_analysis ofa
WHERE ofa.production_day =
(SELECT MAX(ofa2.production_day)
FROM strm_pc_analysis ofa2
WHERE ofa2.object_id= ofa.object_id
AND ofa2.analysis_status = nvl(p_analysis_status, ofa2.analysis_status)
AND ofa2.production_day <= s.daytime)
AND s.daytime BETWEEN TRUNC(p_daytime,'MM') AND p_daytime
AND ofa.analysis_status = nvl(p_analysis_status, ofa.analysis_status)
AND ofa.object_id = p_object_id
GROUP BY s.daytime;

BEGIN

  ln_total_volume := 0;
  ln_volume_times_oiw := 0;
  ln_volume := 0;

  FOR mycur IN c_month_to_date LOOP
    ln_volume := ecbp_stream_fluid.findGrsStdVol(p_object_id, mycur.daytime, mycur.daytime);
    ln_total_volume := ln_total_volume + ln_volume;
    ln_volume_times_oiw := ln_volume_times_oiw + (ln_volume * mycur.avg_oiw);
  END LOOP;

  IF ln_total_volume > 0 THEN
    RETURN ln_volume_times_oiw / ln_total_volume;
  ELSE
    RETURN NULL;
  END IF;

END getAverageOIW;

-----------------------------------------------------------------
-- PROCEDURE: set_analysis_rs - Set record status for all records for a cargo
-----------------------------------------------------------------
PROCEDURE set_analysis_rs(p_object_id VARCHAR2,
                          p_analysis_type VARCHAR2, --todo
                          p_sampling_method VARCHAR2,
                          p_daytime DATE,
						  p_pc_id VARCHAR,
                          p_user_id VARCHAR2 DEFAULT NULL,
						  p_valid_from_date DATE) IS

lv_record_status    VARCHAR2(16);
lr_analysis         strm_pc_analysis%ROWTYPE;
lr_next_analysis    strm_pc_analysis%ROWTYPE;

CURSOR c_strm_pc_analysis IS
SELECT *
FROM strm_pc_analysis
WHERE object_id = p_object_id
AND daytime = p_daytime
AND profit_centre_id = p_pc_id;

BEGIN

   FOR mycur IN c_strm_pc_analysis LOOP
      lr_analysis  := mycur;
   END LOOP;

   lv_record_status := ec_prosty_codes.alt_code(lr_analysis.analysis_status,'ANALYSIS_STATUS');

   -- lock test

   IF lr_analysis.valid_from_date IS NOT NULL AND lr_analysis.analysis_status = 'APPROVED' THEN

     lr_next_analysis := EcDp_Stream_Profit_Centre.getNextAnalysisSample(p_object_id,p_pc_id,p_valid_from_date,p_daytime+1/86400);

     EcDp_month_lock.validatePeriodForLockOverlap('UPDATING', lr_analysis.daytime, lr_next_analysis.daytime, 'pck_status.set_analysis_rs: can not do this for a locked period', p_object_id);

   END IF;

   IF lr_analysis.record_status <> lv_record_status THEN
      -- update strm_pc_analysis
   	UPDATE strm_pc_analysis
   	SET record_status = lv_record_status, last_updated_by = p_user_id
	WHERE object_id = p_object_id
	AND daytime = p_daytime
	AND profit_centre_id = p_pc_id;
   	--WHERE analysis_no = lr_analysis.analysis_no; todo

      -- update strm_pc_comp_analysis
   	UPDATE strm_pc_comp_analysis
   	SET record_status = lv_record_status, last_updated_by = p_user_id, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
	WHERE object_id = p_object_id
	AND daytime = p_daytime
	AND profit_centre_id = p_pc_id;

   END IF;

END set_analysis_rs;

END EcDp_Stream_Profit_Centre;