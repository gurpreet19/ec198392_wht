CREATE OR REPLACE PACKAGE BODY EcDp_Fluid_Analysis IS
/****************************************************************
** Package        :  EcDp_Fluid_Analysis, body part.
**
** $Revision: 1.74 $
**
** Purpose        :  This package is responsible for data access to
**                   fluid analysis figures for any analysis object.
**
** Documentation  :  www.energy-components.com
**
** Created  : 26.05.2004  Dagfinn Njå
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 27.05.2004 DN                   Added getLastAnalysisSampleByObject.
** 01.06.2004 DN                   Added normalizeCompTo100 and convCompBetweenMolWt.
**                                 Change call to sub-functions in convCompBetweenMolWt.
** 09.06.2004 DN                   createCompSetForAnalysis: Added extra analysis test.
** 17.06.2004 AV                   Made normalizeCompTo100 more robust against missing data.
                                   Raising meaningfull error message
** 23.07.2004 kaurrnar             Changed cp_object_id type and update as necessary
** 15.02.2005 Ron/Jerome           Changed function getLastAnalysisSample, getLastAnalysisSampleByObject and cursor c_analysis.
** 24.05.2005 DN       TI 2145:    Divide by total fraction in procedure convCompBetweenMolWt
** 18.08.2005 Toha     TI 2282:    Updated getAnalysisSample, getLastAnalysisSample, getLastAnalysisSampleByObject to use stream reference
** 13.12.2005 DN       TI#2288:    Added getNextAnalysisSample.
** 23.12.2005 chongjer TI#2691:    Added auiSetProductionDay and aiSetObjectClassName.
** 24.04.2006 Lau      TI#3310:    Added normalizeCompTo100_Product
** 29.04.2006 ZakiiAri TI#3595:    Added new parameter (p_user_id) on procedure createCompSetForAnalysis, convCompBetweenMolWt, normalizeCompTo100, auiSetProductionDay, aiSetObjectClassName
**                                 Perform updates on the new added column in each procedures.
** 08.05.2006 skjorsti TI#3364:    Added function getPeriodAnalysisNumberByUK.
** 09.05.2006 skjorsti TI#3364     Added procedure createCompSetForPeriodAnalysis
** 10.05.2006 skjosti  TI#3364     Added procedures normalizeCompTo100PeriodAn, convCompBetweenMolWtPeriodAn and cursor c_period_analysis
** 22.05.2006 skjorsti TD#6106     Added procedure delCompSetForPeriodAnalysis to delete component set when period analysis is deleted.
** 06.06.2006 Zakiiari TI#4000:    Updated procedure auiSetProductionDay by removing fixed FCTY_CLASS_1 value
** 30.06.2006 chongjer TI#4111:    Updated normalizeCompTo100_Product to normalize correctly when sort order exists
** 28.09.2007 rajarsar ECPD#6052:  Updated createCompSetForAnalysis, createCompSetForPeriodAnalysis and delCompSetForPeriodAnalysis
** 17.10.2007 kaurrjes ECPD-6882:  Changed function getAverageOIW
** 22.01.2008 ismaiime ECPD-7009   Updated function convCompBetweenMolWt to convert Wt% to 0 if Mol% is 0.
** 19.06.2008 jailunur ECPD5638:   Added new function sumComponentsAnalysis.
** 02.01.2009 oonnnng  ECPD-9983:  Update getLastAnalysisSample() and getNextAnalysisSample functions with new parameter PHASE, and update the SQL inside the function.
**                                 Update getLastAnalysisSampleByObjects() function to call getLastAnalysisSample.
** 11.02.2009 leeeewei ECPD-10973: Removed nvl logic on cursor parameters in c_analyse in function getLastAnalysisParameter
**                                 Rewrote c_analyse to the correct business logic on fetching last analysis sample
** 17.02.2009 oonnnng  ECPD-6067:  Add parameter p_object_id to validatePeriodForLockOverlap()
**                                 in convCompBetweenMolWt(), normalizeCompTo100() and normalizeCompTo100_Product() functions.
** 26.02.2009 farhaann ECPD-11055: Added new cursor which is not using sampling method in getLastAnalysisSample function
** 10.04.2009 oonnnng  ECPD-6067:  Added addtional parameter p_object_id to createCompSetForAnalysis() function.
**                                 Pass additional parameter p_object_id to validatePeriodForLockOverlap() in createCompSetForAnalysis() function.
**                                 Added lock checking in convCompBetweenMolWtPeriodAn and normalizeCompTo100PeriodAn functions.
** 06.05.2009 oonnnng  ECPD-11625: Modified convCompBetweenMolWt() function checking if one column (Mol% or Wt%) is complete and the other misses at least one component (NULL).
** 24.06.2009 rajarsar ECPD-11812: Updated getLastAnalysisSample() and getNextAnalysisSample functions.
** 21-07-2009 leongwen ECPD-11578: support multiple timezones
**                                 to add production object id to pass into the function ecdp_date_time.interceptsWinterAndSummerTime() and summertime_flag()
** 27.07.2009 leongsei ECPD-12155: Updated getLastAnalysisSample and getNextAnalysisSample functions to improve performance
** 28.07.2009 oonnnng  ECPD-12334: Updated convCompBetweenMolWtPeriodAn() function to avoid division by zero error.
** 28.07.2009 oonnnng  ECPD-12305: Introduce system parameter to to hold number of decimals to be stored on components to normalizeCompTo100() function.
** 01.09.2009 aliassit ECPD-12526: Added parameter p_phase to getLastAnalysisDate and getLastAnalysisNumber and modify getLastAnalysisSample to test on the Null value for p_phase
** 08.10.2009 oonnnng  ECPD-12862: Removed addtional parameter p_object_id in createCompSetForAnalysis() function.
** 23.10.2009 madondin ECPD-12630: Support different component sets for component analysis, do the changes in createCompSetForAnalysis() function.
** 30.10.2009 rajarsar ECPD-12630: Updated createCompSetForAnalysis procedure.
** 11.03.2010 madondin ECPD-13308: Modified createCompSetForPeriodAnalysis function to get the configured component set from EcBp_Fluid_Analysis.getPeriodCompSet
** 02.06.2010 leongsei ECPD-13328: Modified function normalizeCompTo100, normalizeCompTo100PeriodAn, normalizeCompTo100_Product to create revision
** 21.06.2010 rajarsar ECPD-13988: Modified procedure  convCompBetweenMolWt, convCompBetweenMolWtPeriodAn to support mol to wt button and wt to mol button                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   , convCompBetweenMolWtPeriodAn to add extra parameter p_convert_to
** 23.08.2011 rajarsar ECPD-16693: Added convCompMolToEnergy.
** 18.06.2012 choonshu ECPD-21068: Modified getLastAnalysisSampleByObject function.
** 19.06.2012 limmmchu ECPD-21070: Modified createCompSetForPeriodAnalysis function in EcBp_Fluid_Analysis.getPeriodCompSet.
** 06.02.2013 makkkkam ECPD-22974: Modified convCompMolToEnergy.
** 05.08.2013 wonggkai ECPD-24784: Add new method getAnalysisNo, getAnalysisNoPeriodAn and getNextAnalysisSamplePeriodAn, Modified normalizeCompTo100 and normalizeCompTo100PeriodAn, change procedure called to get lr_analysis.
** 24.09.2013 wonggkai ECPD-25076: Fix logic and wrong table reference in method convCompBetweenMolWt and convCompBetweenMolWtPeriodAn, replaced p_daytime with valid_from_date in getLastAnalysisSample() and NextAnalysisSample()
**                                 Replace lv2_analysis_ref_id with p_object_id in getNextAnalysisSample() and getNextAnalysisSamplePeriodAn()
**                                 Replace daytime by valid_from_date in createCompSetForAnalysis() and convCompMolToEnergy()
** 02.10.2013 kumarsur ECPD-22966: Added new function calcHeatingValue.
** 08.10.2014 sohalran ECPD-27402: Remove Commit statement from convCompBetweenMolWt and convCompBetweenMolWtPeriodAn procedure.
** 22.05.2015 shindani ECPD-31021: Modified procedure normalizeCompTo100PeriodAn, added call to user exit procedure.
** 17.08.2015 kumarsur ECPD-28082: Modified convCompBetweenMolWt and convCompBetweenMolWtPeriodAn.
** 29.06.2016 dhavaalo ECPD-30776: Modified delCompSetForPeriodAnalysis,createCompSetForAnalysis and createCompSetForPeriodAnalysis
** 09.08.2016 beeraneh ECPD-36108: Modified getLastAnalysisSample, getNextAnalysisSample
** 19.10.2016 singishi ECPD-32618: Change all instances of UPDATE OBJECT_FLUID_ANALYSIS table to include both last_update_by and last_update_date for revision info
** 20.10.2016 keskaash ECPD-36865: Modified getLastAnalysisNumber added parameter p_fluid_state
** 06.10.2017 kashisag ECPD-23090: Added new copy analysis procedure to copy analysis for Stream/Well component analysis
** 24.04.2018 kashisag ECPD-23090: Updated copy analysis procedure to remove summertime logic for period screens
** 18.05.2018 abdulmaw ECPD-56058: Updated copyAnalysis to update valid from logic for period screens
*****************************************************************/

CURSOR c_analysis(cp_object_id         stream.object_id%TYPE,
                  cp_daytime           DATE,
                  cp_analysis_type     VARCHAR2,
                  cp_sampling_method   VARCHAR2)
IS
SELECT *
FROM object_fluid_analysis ofa
WHERE ofa.object_id = cp_object_id
AND ofa.analysis_type = cp_analysis_type
AND ofa.sampling_method = cp_sampling_method
AND ofa.daytime = cp_daytime;

CURSOR c_period_analysis(cp_object_id           stream.object_id%TYPE,
                    cp_daytime             DATE,
                    cp_daytime_summer_time   VARCHAR2,
                    cp_analysis_type       VARCHAR2,
                    cp_sampling_method     VARCHAR2)
IS
SELECT *
FROM strm_analysis_event ofa
WHERE ofa.object_id = cp_object_id
AND ofa.analysis_type = cp_analysis_type
AND ofa.sampling_method = cp_sampling_method
AND ofa.daytime = cp_daytime
AND ofa.daytime_summer_time = cp_daytime_summer_time;

CURSOR c_comp(cp_analysis_no NUMBER) IS
SELECT *
FROM fluid_analysis_component
WHERE analysis_no = cp_analysis_no
ORDER BY component_no
FOR UPDATE;

CURSOR c_comp_periodAn(cp_analysis_no NUMBER) IS
SELECT *
FROM strm_analysis_component
WHERE analysis_no = cp_analysis_no
ORDER BY component_no
FOR UPDATE;




CURSOR c_product(cp_analysis_no NUMBER) IS
SELECT *
FROM fluid_analysis_product
WHERE analysis_no = cp_analysis_no
ORDER BY object_id
FOR UPDATE;

CURSOR c_class_view(p_class_name IN VARCHAR2) IS
  SELECT class_name, EcDp_ClassMeta_Cnfg.getClassViewName(class_name, class_type) AS source_name
  FROM class_cnfg
  WHERE class_name = p_class_name;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getAnalysisNumber
-- Description  : Return the analysis sequence number by the logical key.
--
--
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:
--
-- Using functions: getAnalysisSample
--
-- Configuration
-- required:
--
-- Behaviour
--
---------------------------------------------------------------------------------------------------
FUNCTION getAnalysisNumber (
   p_object_id        stream.object_id%TYPE,
   p_analysis_type    VARCHAR2,
   p_sampling_method  VARCHAR2,
   p_daytime          DATE)

RETURN NUMBER
--</EC-DOC>
IS

lr_analysis_sample object_fluid_analysis%ROWTYPE;

BEGIN

   lr_analysis_sample := getAnalysisSample(p_object_id, p_analysis_type, p_sampling_method, p_daytime);

   RETURN lr_analysis_sample.analysis_no;

END getAnalysisNumber;


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
-- Using Tables: OBJECT_FLUID_ANALYSIS
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
   p_analysis_type    VARCHAR2,
   p_sampling_method  VARCHAR2,
   p_daytime          DATE)

RETURN object_fluid_analysis%ROWTYPE
--</EC-DOC>
IS

CURSOR c_analyse(
   cp_object_id        stream.object_id%TYPE,
   cp_analysis_type    VARCHAR2,
   cp_sampling_method  VARCHAR2,
   cp_daytime          DATE
) IS
SELECT *
FROM object_fluid_analysis
WHERE object_id = cp_object_id
AND analysis_type = cp_analysis_type
AND sampling_method = cp_sampling_method
AND daytime = cp_daytime;

lr_analysis_sample object_fluid_analysis%ROWTYPE;
lv2_analysis_ref_id varchar2(32);

BEGIN
   lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(p_object_id, p_daytime);

   FOR cur_rec IN c_analyse(lv2_analysis_ref_id, p_analysis_type, p_sampling_method, p_daytime) LOOP

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
-- Using Tables: OBJECT_FLUID_ANALYSIS
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
-- Using Tables: OBJECT_FLUID_ANALYSIS
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
   p_analysis_type    VARCHAR2,
   p_sampling_method  VARCHAR2,
   p_daytime          DATE,
   p_phase            VARCHAR2 default NULL,
   p_fluid_state      VARCHAR2 default NULL)

RETURN object_fluid_analysis%ROWTYPE
--</EC-DOC>
IS

  lr_analysis_sample  object_fluid_analysis%ROWTYPE;
  lv2_analysis_ref_id varchar2(32);
  lv2_obj_class_name varchar2(32);
  lv2_phase           varchar2(32);
  -- Cursor using both sample method and fluid state
  CURSOR c_analyse_sample_fluid(
    cp_object_id        stream.object_id%TYPE,
    cp_analysis_type    VARCHAR2,
    cp_sampling_method  VARCHAR2,
    cp_fluid_state      VARCHAR2,
    cp_daytime          DATE,
    cp_phase            VARCHAR2
  ) IS
    SELECT *
      FROM object_fluid_analysis ofa
     WHERE ofa.object_id = cp_object_id
       AND ofa.analysis_type = cp_analysis_type
       AND ofa.sampling_method = cp_sampling_method
       AND ofa.fluid_state = cp_fluid_state
       AND (ofa.analysis_status = 'APPROVED' OR ofa.analysis_status IS NULL)
       AND ofa.phase = lv2_phase
       AND ofa.valid_from_date = (
           SELECT MAX(ofb.valid_from_date)
             FROM object_fluid_analysis ofb
            WHERE ofb.object_id = ofa.object_id
              AND ofb.analysis_type = ofa.analysis_type
              AND ofb.sampling_method = ofa.sampling_method
              AND ofb.fluid_state = ofa.fluid_state
              AND (ofb.analysis_status = 'APPROVED' OR ofb.analysis_status IS NULL)
              AND ofb.phase = lv2_phase
              AND ofb.valid_from_date <= cp_daytime);

  -- Cursor using the sample method only
  CURSOR c_analyse_sample(
    cp_object_id        stream.object_id%TYPE,
    cp_analysis_type    VARCHAR2,
    cp_sampling_method  VARCHAR2,
    cp_daytime          DATE,
    cp_phase            VARCHAR2
  ) IS
    SELECT *
      FROM object_fluid_analysis ofa
     WHERE ofa.object_id = cp_object_id
       AND ofa.analysis_type = cp_analysis_type
       AND ofa.sampling_method = cp_sampling_method
       AND (ofa.analysis_status = 'APPROVED' OR ofa.analysis_status IS NULL)
       AND ofa.phase = lv2_phase
       AND ofa.valid_from_date = (
           SELECT MAX(ofb.valid_from_date)
             FROM object_fluid_analysis ofb
            WHERE ofb.object_id = ofa.object_id
              AND ofb.analysis_type = ofa.analysis_type
              AND ofb.sampling_method = ofa.sampling_method
              AND (ofb.analysis_status = 'APPROVED' OR ofb.analysis_status IS NULL)
              AND ofb.phase = lv2_phase
              AND ofb.valid_from_date <= cp_daytime);
  -- Cursor using the fluid_state only
  CURSOR c_analyse_fluid(
    cp_object_id        stream.object_id%TYPE,
    cp_analysis_type    VARCHAR2,
    cp_fluid_state      VARCHAR2,
    cp_daytime          DATE,
    cp_phase            VARCHAR2
  ) IS
    SELECT *
      FROM object_fluid_analysis ofa
     WHERE ofa.object_id = cp_object_id
       AND ofa.analysis_type = cp_analysis_type
       AND ofa.fluid_state = cp_fluid_state
       AND (ofa.analysis_status = 'APPROVED' OR ofa.analysis_status IS NULL)
       AND ofa.phase = lv2_phase
       AND ofa.valid_from_date = (
           SELECT MAX(ofb.valid_from_date)
             FROM object_fluid_analysis ofb
            WHERE ofb.object_id = ofa.object_id
              AND ofb.analysis_type = ofa.analysis_type
              AND ofb.fluid_state = ofa.fluid_state
              AND (ofb.analysis_status = 'APPROVED' OR ofb.analysis_status IS NULL)
              AND ofb.phase = lv2_phase
              AND ofb.valid_from_date <= cp_daytime);
  -- Cursor that neither using sample method nor fluid_state
  CURSOR c_analyse_noSample_noFluid(
    cp_object_id        stream.object_id%TYPE,
    cp_analysis_type    VARCHAR2,
    cp_daytime          DATE,
    cp_phase            VARCHAR2
  ) IS
    SELECT *
      FROM object_fluid_analysis ofa
     WHERE ofa.object_id = cp_object_id
       AND ofa.analysis_type = cp_analysis_type
       AND (ofa.analysis_status = 'APPROVED' OR ofa.analysis_status IS NULL)
       AND ofa.phase = lv2_phase
       AND ofa.valid_from_date = (
           SELECT MAX(ofb.valid_from_date)
             FROM object_fluid_analysis ofb
            WHERE ofb.object_id = ofa.object_id
              AND ofb.analysis_type = ofa.analysis_type
              AND (ofb.analysis_status = 'APPROVED' OR ofb.analysis_status IS NULL)
              AND ofb.phase = lv2_phase
              AND ofb.valid_from_date <= cp_daytime);

BEGIN

  lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(p_object_id, p_daytime);

  --if p_phase is null, hardcode the phase based on analysis_type
  IF p_phase IS NULL THEN
     lv2_obj_class_name := ecdp_objects.GetObjClassName(p_object_id);
  IF lv2_obj_class_name = 'STREAM' THEN
     lv2_phase := ecdp_stream.getStreamPhase(lv2_analysis_ref_id);
  ELSE
     IF p_analysis_type = 'WELL_OIL_COMP' THEN
        lv2_phase := 'OIL';
     ELSIF p_analysis_type = 'WELL_GAS_COMP' THEN
        lv2_phase := 'GAS';
     ELSIF p_analysis_type = 'WELL_SAMPLE_ANALYSIS' THEN
        lv2_phase := 'RES';
     ELSE
        lv2_phase := 'GAS';
     END IF;
   END IF;

   ELSE
      lv2_phase := p_phase;
   END IF;

  -- If p_sampling_method is NOT NULL and fluid_state is NOT NULL, use cursor with sampling method and fluid_state
  IF (p_sampling_method IS NOT NULL) AND (p_fluid_state IS NOT NULL) THEN

    FOR cur_rec IN c_analyse_sample_fluid(lv2_analysis_ref_id, p_analysis_type, p_sampling_method, p_fluid_state, p_daytime, lv2_phase) LOOP

      lr_analysis_sample := cur_rec;

    END LOOP;

  ELSIF (p_sampling_method IS NOT NULL) AND (p_fluid_state IS NULL) THEN
  -- If p_sampling_method is NOT NULL and fluid_state is NULL, use cursor with sampling method only
    FOR cur_rec IN c_analyse_sample(lv2_analysis_ref_id, p_analysis_type, p_sampling_method, p_daytime, lv2_phase) LOOP

	  lr_analysis_sample := cur_rec;

    END LOOP;

  ELSIF (p_sampling_method IS NULL) AND (p_fluid_state IS NOT NULL) THEN
  -- If p_sampling_method is NULL and fluid_state is NOT NULL, use cursor with fluid state only
    FOR cur_rec IN c_analyse_fluid(lv2_analysis_ref_id, p_analysis_type, p_fluid_state, p_daytime, lv2_phase) LOOP

      lr_analysis_sample := cur_rec;

    END LOOP;

  ELSIF (p_sampling_method IS NULL) AND (p_fluid_state IS NULL) THEN
  -- If p_sampling_method is NULL and fluid_state is NULL, use cursor without sampling method and fluid state
    FOR cur_rec IN c_analyse_noSample_noFluid(lv2_analysis_ref_id, p_analysis_type, p_daytime, lv2_phase) LOOP

      lr_analysis_sample := cur_rec;

    END LOOP;

  END IF;

  RETURN lr_analysis_sample;

END getLastAnalysisSample;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getLastAnalysisDate
-- Description  : Returns the date for the last analysis sample according to the daytime in the logical key.
--
--
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: getLastAnalysisSample
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour
--
---------------------------------------------------------------------------------------------------
FUNCTION getLastAnalysisDate (
   p_object_id        stream.object_id%TYPE,
   p_analysis_type    VARCHAR2,
   p_sampling_method  VARCHAR2,
   p_daytime          DATE,
   p_phase            VARCHAR2 default NULL)

RETURN DATE
--</EC-DOC>
IS

lr_analysis_sample object_fluid_analysis%ROWTYPE;

BEGIN

   lr_analysis_sample := getLastAnalysisSample(
                                              p_object_id,
                                              p_analysis_type,
                                              p_sampling_method,
                                              p_daytime,
                                              p_phase);
   RETURN lr_analysis_sample.daytime;

END getLastAnalysisDate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getLastAnalysisNumber
-- Description  : Returns the number of the last analysis sample previous or equal to the daytime given by the logical key.
--
--
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:
--
-- Using functions: getLastAnalysisSample
--
-- Configuration
-- required:
--
-- Behaviour
--
---------------------------------------------------------------------------------------------------
FUNCTION getLastAnalysisNumber (
   p_object_id        stream.object_id%TYPE,
   p_analysis_type    VARCHAR2,
   p_sampling_method  VARCHAR2,
   p_daytime          DATE,
   p_phase            VARCHAR2 DEFAULT NULL,
   p_fluid_state      VARCHAR2 DEFAULT NULL)

RETURN NUMBER
--</EC-DOC>
IS

lr_analysis_sample object_fluid_analysis%ROWTYPE;

BEGIN

   lr_analysis_sample := getLastAnalysisSample(
                                              p_object_id,
                                              p_analysis_type,
                                              p_sampling_method,
                                              p_daytime,
                                              p_phase,
                                              p_fluid_state);
   RETURN lr_analysis_sample.analysis_no;

END getLastAnalysisNumber;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getLastAnalysisSampleByObject
-- Description  : Returns the last analysis sample previous or equal to the daytime given by the logical key.
--
--
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables:
--
-- Using functions: getLastAnalysisSample
--
-- Configuration
-- required:
--
-- Behaviour
--
---------------------------------------------------------------------------------------------------
FUNCTION getLastAnalysisSampleByObject(
   p_object_id        stream.object_id%TYPE,
   p_phase            VARCHAR2,
   p_daytime          DATE,
   p_analysis_type    VARCHAR2,
   p_sampling_method  VARCHAR2)

RETURN object_fluid_analysis%ROWTYPE
--</EC-DOC>
IS

lr_analysis_sample object_fluid_analysis%ROWTYPE;
lv2_analysis_ref_id varchar2(32);

BEGIN

   lv2_analysis_ref_id := EcDp_Stream.getAnalysisStream(p_object_id, p_daytime);

   lr_analysis_sample := EcDp_Fluid_Analysis.getLastAnalysisSample(lv2_analysis_ref_id, p_analysis_type, p_sampling_method, p_daytime, p_phase);

   RETURN lr_analysis_sample;

END getLastAnalysisSampleByObject;

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
-- Using Tables: OBJECT_FLUID_ANALYSIS
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
   p_analysis_type    VARCHAR2,
   p_sampling_method  VARCHAR2,
   p_daytime          DATE,
   p_phase            VARCHAR2 default NULL,
   p_fluid_state      VARCHAR2 default NULL)

RETURN object_fluid_analysis%ROWTYPE
--</EC-DOC>
IS
  lr_analysis_sample  object_fluid_analysis%ROWTYPE;
  lv2_obj_class_name varchar2(32);
  lv2_phase           varchar2(32);

  --Cursor using both sample method and fluid state
  CURSOR c_analyse_sample_fluid(
    cp_object_id        stream.object_id%TYPE,
    cp_analysis_type    VARCHAR2,
    cp_sampling_method  VARCHAR2,
    cp_fluid_state      VARCHAR2,
    cp_daytime          DATE,
    cp_phase            VARCHAR2 default NULL
  ) IS
    SELECT *
      FROM object_fluid_analysis ofa
     WHERE ofa.object_id = cp_object_id
       AND ofa.analysis_type = cp_analysis_type
       AND (ofa.sampling_method = cp_sampling_method OR cp_sampling_method IS NULL)
       AND ofa.fluid_state = cp_fluid_state
       AND ofa.phase = lv2_phase
       AND (ofa.analysis_status = 'APPROVED' OR ofa.analysis_status IS NULL)
       AND ofa.valid_from_date = (
           SELECT MIN(ofb.valid_from_date)
             FROM object_fluid_analysis ofb
            WHERE ofb.object_id = ofa.object_id
              AND ofb.analysis_type = ofa.analysis_type
              AND (ofb.sampling_method = cp_sampling_method OR cp_sampling_method IS NULL)
              AND ofb.fluid_state = ofa.fluid_state
              AND (ofb.analysis_status = 'APPROVED' OR ofb.analysis_status IS NULL)
              AND ofb.phase = lv2_phase
              AND ofb.valid_from_date > cp_daytime);

  --Cursor using the sample method only
  CURSOR c_analyse_sample(
    cp_object_id        stream.object_id%TYPE,
    cp_analysis_type    VARCHAR2,
    cp_sampling_method  VARCHAR2,
    cp_daytime          DATE,
    cp_phase            VARCHAR2 default NULL
  ) IS
    SELECT *
      FROM object_fluid_analysis ofa
     WHERE ofa.object_id = cp_object_id
       AND ofa.analysis_type = cp_analysis_type
       AND (ofa.sampling_method = cp_sampling_method OR cp_sampling_method IS NULL)
       AND ofa.phase = lv2_phase
       AND (ofa.analysis_status = 'APPROVED' OR ofa.analysis_status IS NULL)
       AND ofa.valid_from_date = (
           SELECT MIN(ofb.valid_from_date)
             FROM object_fluid_analysis ofb
            WHERE ofb.object_id = ofa.object_id
              AND ofb.analysis_type = ofa.analysis_type
              AND (ofb.sampling_method = cp_sampling_method OR cp_sampling_method IS NULL)
              AND (ofb.analysis_status = 'APPROVED' OR ofb.analysis_status IS NULL)
              AND ofb.phase = lv2_phase
              AND ofb.valid_from_date > cp_daytime);

  --Cursor using the fluid state only
  CURSOR c_analyse_fluid(
    cp_object_id        stream.object_id%TYPE,
    cp_analysis_type    VARCHAR2,
    cp_fluid_state      VARCHAR2,
    cp_daytime          DATE,
    cp_phase            VARCHAR2 default NULL
  ) IS
    SELECT *
      FROM object_fluid_analysis ofa
     WHERE ofa.object_id = cp_object_id
       AND ofa.analysis_type = cp_analysis_type
       AND ofa.fluid_state = cp_fluid_state
       AND ofa.phase = lv2_phase
       AND (ofa.analysis_status = 'APPROVED' OR ofa.analysis_status IS NULL)
       AND ofa.valid_from_date = (
           SELECT MIN(ofb.valid_from_date)
             FROM object_fluid_analysis ofb
            WHERE ofb.object_id = ofa.object_id
              AND ofb.analysis_type = ofa.analysis_type
              AND ofb.fluid_state = ofa.fluid_state
              AND (ofb.analysis_status = 'APPROVED' OR ofb.analysis_status IS NULL)
              AND ofb.phase = lv2_phase
              AND ofb.valid_from_date > cp_daytime);

  -- Cursor that neither using sample method nor fluid_state
  CURSOR c_analyse_noSample_noFluid(
    cp_object_id        stream.object_id%TYPE,
    cp_analysis_type    VARCHAR2,
    cp_daytime          DATE,
    cp_phase            VARCHAR2 default NULL
  ) IS
    SELECT *
      FROM object_fluid_analysis ofa
     WHERE ofa.object_id = cp_object_id
       AND ofa.analysis_type = cp_analysis_type
       AND ofa.phase = lv2_phase
       AND (ofa.analysis_status = 'APPROVED' OR ofa.analysis_status IS NULL)
       AND ofa.valid_from_date = (
           SELECT MIN(ofb.valid_from_date)
             FROM object_fluid_analysis ofb
            WHERE ofb.object_id = ofa.object_id
              AND ofb.analysis_type = ofa.analysis_type
              AND (ofb.analysis_status = 'APPROVED' OR ofb.analysis_status IS NULL)
              AND ofb.phase = lv2_phase
              AND ofb.valid_from_date > cp_daytime);

BEGIN

  IF p_phase IS NULL THEN
     lv2_obj_class_name := ecdp_objects.GetObjClassName(p_object_id);
  IF lv2_obj_class_name = 'STREAM' THEN
     lv2_phase := ecdp_stream.getStreamPhase(p_object_id);
  ELSE
     IF p_analysis_type = 'WELL_OIL_COMP' THEN
        lv2_phase := 'OIL';
     ELSIF p_analysis_type = 'WELL_GAS_COMP' THEN
        lv2_phase := 'GAS';
     ELSIF p_analysis_type = 'WELL_SAMPLE_ANALYSIS' THEN
        lv2_phase := 'RES';
     ELSE
        lv2_phase := 'GAS';
     END IF;
   END IF;

   ELSE
      lv2_phase := p_phase;
   END IF;

  -- If p_sampling_method is NOT NULL and fluid_state is NOT NULL, use cursor with sampling method and fluid_state
  IF (p_sampling_method IS NOT NULL) AND (p_fluid_state IS NOT NULL) THEN

    FOR cur_rec IN c_analyse_sample_fluid(p_object_id, p_analysis_type, p_sampling_method, p_fluid_state, p_daytime, lv2_phase) LOOP

      lr_analysis_sample := cur_rec;

    END LOOP;

  ELSIF (p_sampling_method IS NOT NULL) AND (p_fluid_state IS NULL) THEN
  -- If p_sampling_method is NOT NULL and fluid_state is NULL, use cursor with sampling method only
    FOR cur_rec IN c_analyse_sample(p_object_id, p_analysis_type, p_sampling_method, p_daytime, lv2_phase) LOOP

      lr_analysis_sample := cur_rec;

    END LOOP;

  ELSIF (p_sampling_method IS NULL) AND (p_fluid_state IS NOT NULL) THEN
  -- If p_sampling_method is NULL and fluid_state is NOT NULL, use cursor with fluid state only
    FOR cur_rec IN c_analyse_fluid(p_object_id, p_analysis_type, p_fluid_state, p_daytime, lv2_phase) LOOP

      lr_analysis_sample := cur_rec;

    END LOOP;

  ELSIF (p_sampling_method IS NULL) AND (p_fluid_state IS NULL) THEN
  -- If p_sampling_method is NULL and fluid_state is NULL, use cursor without sampling method and fluid state
    FOR cur_rec IN c_analyse_noSample_noFluid(p_object_id, p_analysis_type, p_daytime, lv2_phase) LOOP

      lr_analysis_sample := cur_rec;

    END LOOP;

  END IF;

  RETURN lr_analysis_sample;

END getNextAnalysisSample;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getNextAnalysisSamplePeriodAn
-- Description  : Returns the next valid and approved analysis sample trailing to the daytime
--                given by the logical key.
--
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: STRM_ANALYSIS_EVENT
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour
--
---------------------------------------------------------------------------------------------------
FUNCTION getNextAnalysisSamplePeriodAn(
   p_object_id        stream.object_id%TYPE,
   p_analysis_type    VARCHAR2,
   p_sampling_method  VARCHAR2,
   p_daytime          DATE,
   p_phase            VARCHAR2 default NULL)

RETURN STRM_ANALYSIS_EVENT%ROWTYPE
--</EC-DOC>
IS
  lr_analysis_sample  STRM_ANALYSIS_EVENT%ROWTYPE;
  lv2_obj_class_name varchar2(32);
  lv2_phase           varchar2(32);
  CURSOR c_analyse(
    cp_object_id        stream.object_id%TYPE,
    cp_analysis_type    VARCHAR2,
    cp_sampling_method  VARCHAR2,
    cp_daytime          DATE
  ) IS
    SELECT *
      FROM STRM_ANALYSIS_EVENT sae
     WHERE sae.object_id = cp_object_id
       AND sae.analysis_type = cp_analysis_type
       AND (sae.sampling_method = cp_sampling_method OR cp_sampling_method IS NULL)
       AND sae.phase = lv2_phase
       AND (sae.analysis_status = 'APPROVED' OR sae.analysis_status IS NULL)
       AND sae.valid_from_date = (
           SELECT MIN(saf.valid_from_date)
             FROM STRM_ANALYSIS_EVENT saf
            WHERE saf.object_id = sae.object_id
              AND saf.analysis_type = sae.analysis_type
              AND (saf.sampling_method = cp_sampling_method OR cp_sampling_method IS NULL)
              AND (saf.analysis_status = 'APPROVED' OR saf.analysis_status IS NULL)
              AND saf.phase = lv2_phase
              AND saf.valid_from_date > cp_daytime);

BEGIN

  IF p_phase IS NULL THEN
     lv2_obj_class_name := ecdp_objects.GetObjClassName(p_object_id);
  IF lv2_obj_class_name = 'STREAM' THEN
     lv2_phase := ecdp_stream.getStreamPhase(p_object_id);
  ELSE
     IF p_analysis_type = 'WELL_OIL_COMP' THEN
        lv2_phase := 'OIL';
     ELSIF p_analysis_type = 'WELL_GAS_COMP' THEN
        lv2_phase := 'GAS';
     ELSIF p_analysis_type = 'WELL_SAMPLE_ANALYSIS' THEN
        lv2_phase := 'RES';
     ELSE
        lv2_phase := 'GAS';
     END IF;
   END IF;

   ELSE
      lv2_phase := p_phase;
   END IF;

  FOR cur_rec IN c_analyse(p_object_id, p_analysis_type, p_sampling_method, p_daytime) LOOP

    lr_analysis_sample := cur_rec;

  END LOOP;

  RETURN lr_analysis_sample;

END getNextAnalysisSamplePeriodAn;


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
-- Using Tables: FLUID_ANALYSIS_COMPONENT, COMP_SET_LIST
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour: Only instantiate if analysis exist and there is no records in the fluid_analysis_component table
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
   lr_analysis               object_fluid_analysis%ROWTYPE;
   lr_next_analysis          object_fluid_analysis%ROWTYPE;
   lv2_comp_set              VARCHAR2(16);

BEGIN

   lr_analysis := Ec_object_fluid_analysis.row_by_pk(p_analysis_no);
   --get the configured component set, if null then use the default from the parameter
   lv2_comp_set := nvl(ecbp_fluid_analysis.getCompSet(lr_analysis.object_class_name , lr_analysis.object_id , p_daytime, p_comp_set),p_comp_set);

   IF lr_analysis.valid_from_date IS NOT NULL AND lr_analysis.analysis_status = 'APPROVED' THEN

      lr_next_analysis := EcDp_Fluid_analysis.getNextAnalysisSample(lr_analysis.object_id,lr_analysis.analysis_type,lr_analysis.sampling_method,lr_analysis.valid_from_date);
      EcDp_month_lock.validatePeriodForLockOverlap('UPDATING', lr_analysis.valid_from_date, lr_next_analysis.valid_from_date, 'EcDp_Fluid_Analysis.createCompSetForAnalysis: can not do this for a locked period', lr_analysis.object_id);

   END IF;

   ln_no_components := 0;

   IF ec_object_fluid_analysis.analysis_type(p_analysis_no) IS NOT NULL THEN

      SELECT count(component_no)
      INTO ln_no_components
      FROM fluid_analysis_component
      WHERE analysis_no = p_analysis_no;

      IF ln_no_components = 0 THEN

         FOR cur_rec IN c_current_components(lv2_comp_set) LOOP

            INSERT INTO fluid_analysis_component (component_no, analysis_no, created_by)
            VALUES (cur_rec.component_no, p_analysis_no, p_user_id);

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
lv2_comp_set         VARCHAR2(16);

CURSOR c_current_components(cp_comp_set varchar2) IS
SELECT c.component_no,MAX(c.daytime)
FROM comp_set_list c
WHERE c.component_set = cp_comp_set
AND p_daytime >= c.daytime AND (p_daytime < c.end_date OR c.end_date IS NULL)
GROUP BY c.component_no;


BEGIN

lv_pday_object_id := EcDp_ProductionDay.findProductionDayDefinition(NULL, p_object_id, p_daytime);

lv_summer_time_flag := EcDp_Date_Time.summertime_flag(p_daytime, NULL, lv_pday_object_id); -- NOTYET What if daytime intercepts winter and summertime

--to get the configured component set either from stream or facilty,if null then get the default one
lv2_comp_set := nvl(EcBp_Fluid_Analysis.getPeriodCompSet(p_object_id,p_daytime,p_comp_set),p_comp_set);

ln_analysis_no := ecdp_fluid_analysis.getPeriodAnalysisNumberByUK(p_object_id,lv2_comp_set,p_daytime,p_sampling_method,lv_summer_time_flag);

ln_no_components := 0;

   IF ec_strm_analysis_event.analysis_type(ln_analysis_no) IS NOT NULL THEN

      SELECT count(component_no)
      INTO ln_no_components
      FROM strm_analysis_component
      WHERE analysis_no = ln_analysis_no;

      IF ln_no_components = 0 THEN

         FOR cur_rec IN c_current_components(lv2_comp_set) LOOP

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


BEGIN

lv_pday_object_id := EcDp_ProductionDay.findProductionDayDefinition(NULL, p_object_id, p_daytime);

lv_summer_time_flag := EcDp_Date_Time.summertime_flag(p_daytime, NULL, lv_pday_object_id); -- NOTYET What if daytime intercepts winter and summertime

ln_analysis_no := ecdp_fluid_analysis.getPeriodAnalysisNumberByUK(p_object_id,p_comp_set,p_daytime,p_sampling_method,lv_summer_time_flag);

ln_no_components := 0;

   IF ec_strm_analysis_event.analysis_type(ln_analysis_no) IS NOT NULL THEN

      SELECT count(component_no)
      INTO ln_no_components
      FROM strm_analysis_component
      WHERE analysis_no = ln_analysis_no;

      IF ln_no_components <> 0 THEN
		DELETE FROM strm_analysis_component
		WHERE analysis_no = ln_analysis_no;
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
-- Using Tables: FLUID_ANALYSIS_COMPONENT
--
-- Using functions: EcBp_Comp_Analysis.calcCompMolPct
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
   p_analysis_type    VARCHAR2,
   p_sampling_method  VARCHAR2,
   p_daytime          DATE,
   p_user_id          VARCHAR2 DEFAULT NULL,
   p_convert_to       VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS
   ln_tot_mol_frac    NUMBER :=0;
   ln_tot_mass_frac   NUMBER :=0;
   ln_analysis_no     NUMBER;
   ln_count_blank_mol NUMBER :=0;
   ln_count_blank_wt  NUMBER :=0;

   lr_analysis       object_fluid_analysis%ROWTYPE;
   lr_next_analysis  object_fluid_analysis%ROWTYPE;


BEGIN

   -- lock test
     ln_analysis_no := EcDp_Fluid_analysis.getAnalysisNo(p_object_id,p_analysis_type,p_sampling_method,p_daytime);
     lr_analysis := ec_object_fluid_analysis.row_by_pk(ln_analysis_no);

   IF lr_analysis.valid_from_date IS NOT NULL AND lr_analysis.analysis_status = 'APPROVED' THEN

      lr_next_analysis := EcDp_Fluid_analysis.getNextAnalysisSample(p_object_id,p_analysis_type,p_sampling_method,lr_analysis.valid_from_date);

      EcDp_month_lock.validatePeriodForLockOverlap('UPDATING', lr_analysis.valid_from_date, lr_next_analysis.valid_from_date, 'EcDp_Fluid_Analysis.convCompBetweenMolWt: can not do this for a locked period', p_object_id);

   END IF;

   FOR comp_rec IN c_comp(ln_analysis_no) LOOP
     IF comp_rec.wt_pct is null THEN
       ln_count_blank_wt := ln_count_blank_wt+1;
     END IF;

     IF comp_rec.mol_pct is null THEN
       ln_count_blank_mol := ln_count_blank_mol+1;
     END IF;
   END LOOP;

   IF ((p_convert_to = 'WT_TO_MOL' OR p_convert_to IS NULL) and ln_count_blank_wt = 0) OR ((p_convert_to = 'MOL_TO_WT' OR p_convert_to IS NULL) and ln_count_blank_mol = 0) THEN

     ln_tot_mol_frac  := EcBp_Comp_Analysis.calcTotMolFrac(ln_analysis_no);
     ln_tot_mass_frac := EcBp_Comp_Analysis.calcTotMassFrac(ln_analysis_no);

     FOR ana_rec IN c_analysis(p_object_id,
                                 p_daytime,
                                 p_analysis_type,
                                 p_sampling_method)
     LOOP

       FOR comp_rec IN c_comp(ana_rec.analysis_no) LOOP
         IF (p_convert_to = 'WT_TO_MOL' OR p_convert_to IS NULL) and ln_count_blank_wt = 0 THEN
           IF ln_tot_mol_frac > 0 THEN
             UPDATE fluid_analysis_component
               SET  mol_pct = 100 * EcBp_Comp_Analysis.calcCompMolFrac( p_object_id,
                                                                       ana_rec.daytime,
                                                                       comp_rec.component_no,
                                                                       ana_rec.analysis_type,
                                                                       ana_rec.sampling_method,
                                                                       comp_rec.wt_pct) / ln_tot_mol_frac,
                          last_updated_by=p_user_id
               WHERE CURRENT OF c_comp;
           END IF;
         END IF;
         IF (p_convert_to = 'MOL_TO_WT' OR p_convert_to IS NULL) and ln_count_blank_mol = 0 THEN
           IF ln_tot_mass_frac > 0 THEN
             UPDATE   fluid_analysis_component
               SET      wt_pct = 100 * EcBp_Comp_Analysis.calcCompMassFrac( p_object_id,
                                                                    ana_rec.daytime,
                                                                    comp_rec.component_no,
                                                                    ana_rec.analysis_type,
                                                                    ana_rec.sampling_method,
                                                                    comp_rec.mol_pct) / ln_tot_mass_frac,
                            last_updated_by=p_user_id
               WHERE CURRENT OF c_comp;
           END IF;
         END IF;
       END LOOP; -- component
     END LOOP; -- analysis
    END IF; -- Make sure the situation...
END convCompBetweenMolWt;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : convCompBetweenMolWtPeriodAn
-- Description  : Convert component between Mol% and Wt% in analysis for object given.
--
--
--
-- Preconditions: Used from the business function Period Stream Gas Component Analysis
-- Postcondition:
--
-- Using Tables: STRM_ANALYSIS_COMPONENT
--
-- Using functions: EcBp_Comp_Analysis.calcCompMolPct
--
-- Configuration
-- required:
--
-- Behaviour: If one of the values is NULL it's calculated from the other.
--            wt%   -> mole%
--            mole% -> wt%
--
---------------------------------------------------------------------------------------------------
PROCEDURE convCompBetweenMolWtPeriodAn(
   p_object_id            stream.object_id%TYPE,
   p_analysis_type        VARCHAR2,
   p_sampling_method      VARCHAR2,
   p_daytime              DATE,
   p_daytime_summer_time  VARCHAR2,
   p_user_id              VARCHAR2 DEFAULT NULL,
   p_convert_to           VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS
   ln_tot_mol_frac NUMBER;
   ln_tot_mass_frac NUMBER;
   ln_analysis_no NUMBER;
   lr_analysis       STRM_ANALYSIS_EVENT%ROWTYPE;
   lr_next_analysis  STRM_ANALYSIS_EVENT%ROWTYPE;
   ln_count_blank_mol NUMBER :=0;
   ln_count_blank_wt  NUMBER :=0;
BEGIN

   -- lock test
  ln_analysis_no := EcDp_Fluid_analysis.getAnalysisNoPeriodAn(p_object_id,p_analysis_type,p_sampling_method,p_daytime);
  lr_analysis := ec_strm_analysis_event.row_by_pk(ln_analysis_no);

   IF lr_analysis.valid_from_date IS NOT NULL AND lr_analysis.analysis_status = 'APPROVED' THEN

      lr_next_analysis := EcDp_Fluid_analysis.getNextAnalysisSamplePeriodAn(p_object_id,p_analysis_type,p_sampling_method,p_daytime);
      EcDp_month_lock.validatePeriodForLockOverlap('UPDATING', lr_analysis.valid_from_date, lr_next_analysis.valid_from_date, 'EcDp_Fluid_Analysis.convCompBetweenMolWt: can not do this for a locked period', p_object_id);

   END IF;
   -- end of lock test

   FOR comp_rec IN c_comp_periodAn(ln_analysis_no) LOOP
     IF comp_rec.wt_pct is null then
       ln_count_blank_wt := ln_count_blank_wt+1;
     END IF;

     IF comp_rec.mol_pct is null then
       ln_count_blank_mol := ln_count_blank_mol+1;
     END IF;
   END LOOP;


   IF ((p_convert_to = 'WT_TO_MOL' OR p_convert_to IS NULL) and ln_count_blank_wt = 0) OR ((p_convert_to = 'MOL_TO_WT' OR p_convert_to IS NULL) and ln_count_blank_mol = 0) THEN

     ln_tot_mass_frac := EcBp_Comp_Analysis.calcTotPeriodAnMassFrac(ln_analysis_no);
     ln_tot_mol_frac := EcBp_Comp_Analysis.calcTotMolPeriodAnFrac(ln_analysis_no);

     FOR ana_rec IN c_period_analysis(p_object_id,
                             p_daytime,
                             p_daytime_summer_time,
                             p_analysis_type,
                             p_sampling_method)
     LOOP

     FOR comp_rec IN c_comp_periodAn(ana_rec.analysis_no) LOOP
       IF (p_convert_to = 'WT_TO_MOL' OR p_convert_to IS NULL) and ln_count_blank_wt = 0 THEN
         IF ln_tot_mol_frac > 0 THEN

           UPDATE strm_analysis_component
             SET  mol_pct = 100 * EcBp_Comp_Analysis.calcCompMolFracperiodAn( p_object_id,
                                                                      ana_rec.daytime,
                                                                      ana_rec.daytime_summer_time,
                                                                      comp_rec.component_no,
                                                                      ana_rec.analysis_type,
                                                                      ana_rec.sampling_method,
                                                                      comp_rec.wt_pct) / ln_tot_mol_frac,
                         last_updated_by=p_user_id
             WHERE CURRENT OF c_comp_periodAn;

         END IF;
       END IF;
       IF (p_convert_to = 'MOL_TO_WT' OR p_convert_to IS NULL) and ln_count_blank_mol = 0 THEN
         IF ln_tot_mass_frac > 0 THEN

           UPDATE   strm_analysis_component
             SET      wt_pct = 100 * EcBp_Comp_Analysis.calcCompMassFracPeriodAn( p_object_id,
                                                                ana_rec.daytime,
                                                                ana_rec.daytime_summer_time,
                                                                comp_rec.component_no,
                                                                ana_rec.analysis_type,
                                                                ana_rec.sampling_method,
                                                                comp_rec.mol_pct) / ln_tot_mass_frac,
                        last_updated_by=p_user_id
           WHERE CURRENT OF c_comp_periodAn;
         END IF;
       END IF;
     END LOOP; -- component
   END LOOP; -- analysis
 END IF;
END convCompBetweenMolWtPeriodAn;

--<EC-DOC>
-- Procedure    : convCompMolToEnergy
-- Description  : Convert component from Mol% to Energy% in a analysis.
--
--
--
-- Preconditions: GCV of components that has it must be filled at Component Constant screen.
-- Postcondition:
--
-- Using Tables: FLUID_ANALYSIS_COMPONENT
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
---------------------------------------------------------------------------------------------------
PROCEDURE convCompMolToEnergy (
   p_analysis_no      NUMBER,
   p_user  VARCHAR2)

--</EC-DOC>
IS

  CURSOR c_comp_list IS
  SELECT component_no, mol_pct
  FROM fluid_analysis_component fac
  WHERE analysis_no=p_analysis_no
  AND mol_pct IS NOT NULL;

  ln_gcv             NUMBER;
  ln_comp_mol_sum    NUMBER;
  lr_analysis        object_fluid_analysis%ROWTYPE;
  lr_next_analysis   object_fluid_analysis%ROWTYPE;
  lv2_standard_code  constant_standard.object_code%TYPE;
  lv2_phase          VARCHAR2(32);
  lv2_object_id      VARCHAR2(32);
  ln_component_energy_sum  NUMBER;

 BEGIN

  lr_analysis       := ec_object_fluid_analysis.row_by_pk(p_analysis_no);

  IF lr_analysis.valid_from_date IS NOT NULL AND lr_analysis.analysis_status = 'APPROVED' THEN

    lr_next_analysis := EcDp_Fluid_analysis.getNextAnalysisSample(lr_analysis.object_id,lr_analysis.analysis_type,lr_analysis.sampling_method,lr_analysis.valid_from_date);
    EcDp_month_lock.validatePeriodForLockOverlap('UPDATING', lr_analysis.valid_from_date, lr_next_analysis.valid_from_date, 'EcDp_Fluid_Analysis.convCompMolToEnergy: can not do this for a locked period', lr_analysis.object_id);

  END IF;

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
    ln_component_energy_sum:=0;
    FOR cur_comp IN c_comp_list LOOP
      -- GCV is stored in component constant table, or if it is the Cn+ component the GCV will be stored on the analysis.
      ln_gcv := NVL(ec_component_constant.ideal_gcv(lv2_object_id,cur_comp.component_no,lr_analysis.daytime,'<='),
                    ec_object_fluid_analysis.cnpl_gcv(p_analysis_no));
      IF cur_comp.mol_pct>0 AND ln_gcv>0 THEN
        ln_component_energy_sum := ln_component_energy_sum + (cur_comp.mol_pct / ln_comp_mol_sum * 100 * ln_gcv);
      ELSIF (cur_comp.mol_pct IS NULL OR (ln_gcv IS NULL AND cur_comp.mol_pct>0)) THEN
        ln_component_energy_sum := NULL; -- missing GCV or mol% for at least one of the components
      END IF;
    END LOOP;
  -- update the energy for each component.
    FOR cur_comp IN c_comp_list LOOP
      -- Cn+ component will not have a GCV from the Standard. The GCV will be stored on the analysis for Cn+.
      ln_gcv := NVL(ec_component_constant.ideal_gcv(lv2_object_id,cur_comp.component_no,lr_analysis.daytime,'<='),
                    ec_object_fluid_analysis.cnpl_gcv(p_analysis_no));
      UPDATE fluid_analysis_component
      SET energy_pct = (cur_comp.mol_pct*100/ln_comp_mol_sum*ln_gcv/ln_component_energy_sum)*100,
      last_updated_by = p_user
      WHERE  analysis_no = p_analysis_no
      AND component_no = cur_comp.component_no;
    END LOOP;
  END IF;
END convCompMolToEnergy;

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
-- Using Tables: FLUID_ANALYSIS_COMPONENT
--
-- Using functions: EcBp_Comp_Analysis.calcCompMolPct
--
-- Configuration
-- required:
--
-- Behaviour:
--
---------------------------------------------------------------------------------------------------
PROCEDURE normalizeCompTo100(
  p_object_id        stream.object_id%TYPE,
  p_analysis_type    VARCHAR2,
  p_sampling_method  VARCHAR2,
  p_daytime          DATE,
  p_user_id          VARCHAR2 DEFAULT NULL,
  p_class_name       VARCHAR2 DEFAULT 'FLUID_ANALYSIS_COMPONENT')
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
  lr_analysis       object_fluid_analysis%ROWTYPE;
  lr_next_analysis  object_fluid_analysis%ROWTYPE;
  ln_decimals       NUMBER;

  lv_sql            VARCHAR2(4000);
  j                 NUMBER;
  lv_view_name      VARCHAR2(24);
  ln_analysis_no    NUMBER;

BEGIN

  -- lock test
  ln_analysis_no := EcDp_Fluid_analysis.getAnalysisNo(p_object_id,p_analysis_type,p_sampling_method,p_daytime);
  lr_analysis := ec_object_fluid_analysis.row_by_pk(ln_analysis_no);

  IF lr_analysis.valid_from_date IS NOT NULL AND lr_analysis.analysis_status = 'APPROVED' THEN
    lr_next_analysis := EcDp_Fluid_analysis.getNextAnalysisSample(p_object_id,p_analysis_type,p_sampling_method,lr_analysis.valid_from_date);
    EcDp_month_lock.validatePeriodForLockOverlap('UPDATING', lr_analysis.valid_from_date, lr_next_analysis.valid_from_date, 'EcDp_Fluid_Analysis.normalizeCompTo100: can not do this for a locked period', p_object_id);

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
                            p_analysis_type,
                            p_sampling_method)
  LOOP

    FOR comp_rec IN c_comp(ana_rec.analysis_no)
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
    FOR comp_rec IN c_comp(ana_rec.analysis_no) LOOP
      -- Assumes that no changes has been done on component records (insert, delete, update(key values)).
      i := i + 1;

      FOR class_rec IN c_class_view(p_class_name) LOOP
        lv_view_name := class_rec.class_name;

        j := 0;
        lv_sql := 'UPDATE ' || class_rec.source_name || ' SET ';

        FOR attr_rec IN (SELECT a.attribute_name, a.db_sql_syntax, EcDp_ClassMeta_Cnfg.isDisabled(a.class_name, a.attribute_name) ASdisabled_ind
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
          lv_sql := RTRIM(lv_sql, ', ') || ', last_updated_by = ''' || p_user_id || ''' WHERE analysis_no = ' || comp_rec.analysis_no || ' AND component_no = ''' || comp_rec.component_no || '''';

          EcDp_DynSql.Execute_Statement(lv_sql);
        END IF;
      END LOOP;

    END LOOP;

  END LOOP; -- analysis

END normalizeCompTo100;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : normalizeCompTo100PeriodAn
-- Description  : Normalize sum(wt% or mol%) to 100 for Stream.
--                Multiply with factor 100/sum(%).
--                Add remaining fraction to largerst component.
--
--    Sum(wt%)   = 100
--    Sum(mole%) = 100
--
--
--
-- Preconditions: Used from the business function Period Stream Gas Component Analysis
-- Postcondition:
--
-- Using Tables: strm_analysis_component
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
---------------------------------------------------------------------------------------------------
PROCEDURE normalizeCompTo100PeriodAn(
  p_object_id            stream.object_id%TYPE,
  p_analysis_type        VARCHAR2,
  p_sampling_method      VARCHAR2,
  p_daytime              DATE,
  p_daytime_summer_time  VARCHAR2,
  p_user_id              VARCHAR2 DEFAULT NULL,
  p_class_name           VARCHAR2 DEFAULT 'STRM_ANALYSIS_COMPONENT')
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

  lr_analysis       STRM_ANALYSIS_EVENT%ROWTYPE;
  lr_next_analysis  STRM_ANALYSIS_EVENT%ROWTYPE;
  lv_code_exist     VARCHAR2(32);
  lv_sql            VARCHAR2(4000);
  j                 NUMBER;
  lv_view_name      VARCHAR2(24);
  ln_analysis_no    NUMBER;

BEGIN
  -- start local lock test
  ln_analysis_no := EcDp_Fluid_analysis.getAnalysisNoPeriodAn(p_object_id,p_analysis_type,p_sampling_method,p_daytime);
  lr_analysis := ec_strm_analysis_event.row_by_pk(ln_analysis_no);

  IF lr_analysis.valid_from_date IS NOT NULL AND lr_analysis.analysis_status = 'APPROVED' THEN

    lr_next_analysis := EcDp_Fluid_analysis.getNextAnalysisSamplePeriodAn(p_object_id,p_analysis_type,p_sampling_method,p_daytime);
    EcDp_month_lock.validatePeriodForLockOverlap('UPDATING', lr_analysis.valid_from_date, lr_next_analysis.valid_from_date, 'EcDp_Fluid_Analysis.normalizeCompTo100: can not do this for a locked period', p_object_id);

  END IF;
  -- end local lock test
	Ue_Fluid_Analysis.normalizeCompTo100PeriodAn (p_object_id,p_analysis_type,p_sampling_method,p_daytime,p_daytime_summer_time,p_user_id,p_class_name,lv_code_exist);

  IF lv_code_exist <> 'Y' THEN

  i                 := 0;

  ln_mol_tot        := 0;
  ln_mol_max        := 0;
  ln_mol_max_i      := 0;
  ln_mol_fact       := 0;

  ln_wt_tot         := 0;
  ln_wt_max         := 0;
  ln_wt_max_i       := 0;
  ln_wt_fact        := 0;

  FOR ana_rec IN c_period_analysis(p_object_id,
                                   p_daytime,
                                   p_daytime_summer_time,
                                   p_analysis_type,
                                   p_sampling_method)
  LOOP

    FOR comp_rec IN c_comp_periodAn(ana_rec.analysis_no) LOOP
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
        mol_compTab(i) := mol_compTab(i) * ln_mol_fact;
        ln_mol_tot     := ln_mol_tot + mol_compTab(i);
      END IF;

      IF ln_wt_fact IS NOT NULL THEN
        wt_compTab(i)  := wt_compTab(i) * ln_wt_fact;
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
    FOR comp_rec IN c_comp_periodAn(ana_rec.analysis_no) LOOP
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
          lv_sql := RTRIM(lv_sql, ', ') || ', last_updated_by = ''' || p_user_id || ''' WHERE analysis_no = ' || comp_rec.analysis_no || ' AND component_no = ''' || comp_rec.component_no || '''';

          EcDp_DynSql.Execute_Statement(lv_sql);
        END IF;
      END LOOP;

    END LOOP;

  END LOOP; -- analysis
  ELSE
    NULL;
  END IF;

END normalizeCompTo100PeriodAn;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : auiSetProductionDay
-- Description  : Update value to object_fluid_analysis.production_day column
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: OBJECT_FLUID_ANALYSIS
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
      lv2_obj_class_name   object_fluid_analysis.object_class_name%TYPE;

BEGIN

      lv2_obj_class_name := ecdp_objects.GetObjClassName(p_object_id);

      ld_production_day := EcDp_ProductionDay.getProductionDay(lv2_obj_class_name, p_object_id, p_daytime);

      -- Update object_fluid_analysis.production_day
      UPDATE object_fluid_analysis
         SET production_day = ld_production_day,
             last_updated_by = p_user_id,
             last_updated_date = Ecdp_Timestamp.getCurrentSysdate
       WHERE object_id = p_object_id
         AND daytime = p_daytime
         AND analysis_type = p_analysis_type
         AND sampling_method = p_sampling_method
         AND phase = p_phase;

END auiSetProductionDay;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : aiSetObjectClassName
-- Description  : Update value to object_fluid_analysis.object_class_name column
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: OBJECT_FLUID_ANALYSIS
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

      lv2_obj_class_name    object_fluid_analysis.object_class_name%TYPE;

BEGIN

      lv2_obj_class_name := ecdp_objects.GetObjClassName(p_object_id);

      -- Update object_fluid_analysis.object_class_name
      UPDATE object_fluid_analysis
         SET object_class_name = lv2_obj_class_name,
             last_updated_by = p_user_id,
             last_updated_date = Ecdp_Timestamp.getCurrentSysdate
       WHERE object_id = p_object_id
         AND daytime = p_daytime
         AND analysis_type = p_analysis_type
         AND sampling_method = p_sampling_method
         AND phase = p_phase;

END aiSetObjectClassName;


PROCEDURE normalizeCompTo100_Product(
  p_object_id        stream.object_id%TYPE,
  p_analysis_type    VARCHAR2,
  p_sampling_method  VARCHAR2,
  p_daytime          DATE,
  p_user_id          VARCHAR2 DEFAULT NULL,
  p_class_name       VARCHAR2 DEFAULT 'FLUID_ANALYSIS_PRODUCT')

--</EC-DOC>
IS
  CURSOR c_max_sort_order (cp_analysis_no NUMBER) IS
    SELECT sort_order, pver.object_id FROM product_version pver, fluid_analysis_product fap
             WHERE pver.object_id = fap.object_id
             AND fap.analysis_no = cp_analysis_no
             AND daytime = (SELECT MAX(daytime) FROM product_version pv
                                   WHERE pv.OBJECT_ID = pver.object_id
                                   AND daytime <= ec_object_fluid_analysis.daytime(cp_analysis_no))
   ORDER BY sort_order DESC;

  TYPE compTabTyp IS TABLE OF EcDp_Type.pb_comp_number%TYPE -- Return a PowerBuilder compliant number
  INDEX BY binary_integer;

  i                 NUMBER;
  ln_no             NUMBER;

  ln_wt_tot         NUMBER;
  ln_wt_max         NUMBER;
  ln_wt_max_i       NUMBER;
  ln_wt_fact        NUMBER;
  ln_max_sort_order NUMBER;
  wt_compTab        compTabTyp;
  lr_analysis       object_fluid_analysis%ROWTYPE;
  lr_next_analysis  object_fluid_analysis%ROWTYPE;
  lv2_object_id     stream.object_id%TYPE;

  lv_sql1           VARCHAR2(4000);
  lv_sql2           VARCHAR2(4000);
  j                 NUMBER;
  lv_view_name      VARCHAR2(24);

BEGIN

  -- lock test
  lr_analysis := EcDp_Fluid_analysis.getLastAnalysisSample(p_object_id,p_analysis_type,p_sampling_method,p_daytime);

  IF lr_analysis.valid_from_date IS NOT NULL AND lr_analysis.analysis_status = 'APPROVED' THEN

    lr_next_analysis := EcDp_Fluid_analysis.getNextAnalysisSample(p_object_id,p_analysis_type,p_sampling_method,p_daytime);
    EcDp_month_lock.validatePeriodForLockOverlap('UPDATING', lr_analysis.valid_from_date, lr_next_analysis.valid_from_date, 'EcDp_Fluid_Analysis.normalizeCompTo100: can not do this for a locked period', p_object_id);

  END IF;

  i                 := 0;
  ln_wt_tot         := 0;
  ln_wt_max         := 0;
  ln_wt_max_i       := 0;
  ln_wt_fact        := 0;
  ln_max_sort_order := 0;

  FOR ana_rec IN c_analysis(p_object_id,
                            p_daytime,
                            p_analysis_type,
                            p_sampling_method)
  LOOP
    FOR comp_rec IN c_product(ana_rec.analysis_no)
    LOOP
      i := i + 1;

      --wt
      wt_compTab(i) := comp_rec.wt_pct;
      ln_wt_tot      := ln_wt_tot + wt_compTab(i);
      IF ln_wt_max < wt_compTab(i) THEN
        ln_wt_max   := wt_compTab(i);
        ln_wt_max_i := i;
      END IF;

    END LOOP; -- product
    ln_no       := i;    -- total number of records

    IF Nvl(ln_wt_tot,0) <> 0 THEN
      ln_wt_fact  := 100 / ln_wt_tot;
    ELSE
      ln_wt_fact  := NULL;
    END IF;

    IF ln_wt_fact IS NULL THEN
      RAISE_APPLICATION_ERROR(-20201,'Missing product value(s). All products must have a value to be able to normalize.');
    END IF;

    ln_wt_tot := 0;

    --Multiply with "factor" and calculate new total.
    FOR i IN 1 ..ln_no LOOP

      IF ln_wt_fact IS NOT NULL THEN
        wt_compTab(i)  := wt_compTab(i) * ln_wt_fact;
        ln_wt_tot      := ln_wt_tot + wt_compTab(i);
      END IF;

    END LOOP;

    --Add remaninig fraction (100-NewTotal) to largest component.
    IF ln_wt_fact IS NOT NULL THEN
      wt_compTab(ln_wt_max_i)    := wt_compTab(ln_wt_max_i) + (100 - ln_wt_tot);
    END IF;

    --Get largest sort order
    FOR one_row in c_max_sort_order(ana_rec.analysis_no) LOOP
      ln_max_sort_order := one_row.sort_order;
      lv2_object_id := one_row.object_id;
      EXIT;
    END LOOP;

    --Undo adding remaining fraction if largest sort order exists
    IF ln_max_sort_order > 0 THEN
      wt_compTab(ln_wt_max_i)    := wt_compTab(ln_wt_max_i) - (100 - ln_wt_tot);
    END IF;

    -- Update database with result.
    i := 0;
    FOR comp_rec IN c_product(ana_rec.analysis_no) LOOP
      -- Assumes that no changes has been done on component records (insert, delete, update(key values)).
      i := i + 1;

      FOR class_rec IN c_class_view(p_class_name) LOOP
        lv_view_name := class_rec.class_name;

        j := 0;
        lv_sql1 := 'UPDATE ' || class_rec.source_name || ' SET ';
        lv_sql2 := 'UPDATE ' || class_rec.source_name || ' SET ';

        FOR attr_rec IN (SELECT a.attribute_name, a.db_sql_syntax, EcDp_ClassMeta_Cnfg.isDisabled(a.class_name, a.attribute_name) AS disabled_ind
                           FROM class_attribute_cnfg a
                          WHERE a.class_name = lv_view_name
                            AND EcDp_ClassMeta_Cnfg.isDisabled(a.class_name, a.attribute_name) = 'N'
                            AND a.DB_SQL_SYNTAX IN ('WT_PCT')) LOOP
          j := j + 1;

          IF attr_rec.db_sql_syntax  = 'WT_PCT' THEN
            IF wt_compTab(i) IS NOT NULL THEN
              lv_sql1 := lv_sql1 || attr_rec.attribute_name || ' = ' || wt_compTab(i) || ', ';
              lv_sql2 := lv_sql2 || attr_rec.attribute_name || ' = wt_pct + (100 - ' || ln_wt_tot || ') ';
            END IF;

          END IF;
        END LOOP;

        IF j != 0 THEN
          lv_sql1 := RTRIM(lv_sql1, ', ') || ', last_updated_by = ''' || p_user_id || ''' WHERE analysis_no = ' || comp_rec.analysis_no || ' AND object_id = ''' || comp_rec.object_id || '''';

          EcDp_DynSql.Execute_Statement(lv_sql1);

        END IF;

      END LOOP;

    END LOOP;

    lv_sql2 := RTRIM(lv_sql2, ', ') || ', last_updated_by = ''' || p_user_id || ''' WHERE analysis_no = ' || ana_rec.analysis_no || ' AND object_id = ''' || lv2_object_id || '''';
    EcDp_DynSql.Execute_Statement(lv_sql2);

  END LOOP; -- analysis

END normalizeCompTo100_Product;


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
FROM system_days s, object_fluid_analysis ofa
WHERE ofa.production_day =
(SELECT MAX(ofa2.production_day)
FROM object_fluid_analysis ofa2
WHERE ofa2.object_id= ofa.object_id
AND ofa2.analysis_type = p_analysis_type
AND ofa2.sampling_method = nvl(p_sampling_method, ofa2.sampling_method)
AND ofa2.analysis_status = nvl(p_analysis_status, ofa2.analysis_status)
AND ofa2.production_day <= s.daytime)
AND s.daytime BETWEEN TRUNC(p_daytime,'MM') AND p_daytime
AND ofa.analysis_type = p_analysis_type
AND ofa.sampling_method = nvl(p_sampling_method, ofa.sampling_method)
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

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : sumComponentsAnalysis
-- Description  : Return the sum of all Components based on the analysis_no
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
FUNCTION sumComponentsAnalysis (
   p_analysis_no      NUMBER)

RETURN NUMBER
--</EC-DOC>

IS

ln_sum NUMBER := 0;

BEGIN

  SELECT sum(wt_pct) INTO ln_sum FROM fluid_analysis_component where analysis_no=p_analysis_no;

  IF ln_sum IS NULL THEN
     ln_sum := 0;
  END IF;

  return ln_sum;

END sumComponentsAnalysis;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getAnalysisNo
-- Description  : Return the analysis sequence number by the logical key.
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
FUNCTION getAnalysisNo (
   p_object_id        stream.object_id%TYPE,
   p_analysis_type    VARCHAR2,
   p_sampling_method  VARCHAR2,
   p_daytime          DATE)
RETURN NUMBER
--</EC-DOC>
IS

v_return_analysis_no OBJECT_FLUID_ANALYSIS.ANALYSIS_NO%TYPE;

   CURSOR c_rec IS
   SELECT analysis_no
   FROM OBJECT_FLUID_ANALYSIS
   where object_id = p_object_id
   AND analysis_type = p_analysis_type
   AND sampling_method = p_sampling_method
   AND daytime = p_daytime;


BEGIN
   FOR cur_rec IN c_rec LOOP
      v_return_analysis_no := cur_rec.analysis_no;
   END LOOP;
   RETURN v_return_analysis_no;

END getAnalysisNO;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : getAnalysisNoPeriodAn
-- Description  : Return the analysis sequence number by the logical key.
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
FUNCTION getAnalysisNoPeriodAn (
   p_object_id        stream.object_id%TYPE,
   p_analysis_type    VARCHAR2,
   p_sampling_method  VARCHAR2,
   p_daytime          DATE)
RETURN NUMBER
--</EC-DOC>
IS

v_return_analysis_no STRM_ANALYSIS_EVENT.ANALYSIS_NO%TYPE;

   CURSOR c_rec IS
   SELECT analysis_no
   FROM STRM_ANALYSIS_EVENT
   where object_id = p_object_id
   AND analysis_type = p_analysis_type
   AND sampling_method = p_sampling_method
   AND daytime = p_daytime;


BEGIN
   FOR cur_rec IN c_rec LOOP
      v_return_analysis_no := cur_rec.analysis_no;
   END LOOP;
   RETURN v_return_analysis_no;

END getAnalysisNoPeriodAn;

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
FROM fluid_analysis_component fac
WHERE analysis_no=p_analysis_no
AND mol_pct IS NOT NULL;

ln_gcv             NUMBER;
ln_comp_mol_sum    NUMBER := 0;
lr_analysis        object_fluid_analysis%ROWTYPE;
lv2_standard_code  constant_standard.object_code%TYPE;
lv2_phase          VARCHAR2(32);
lv2_object_id      VARCHAR2(32);
ln_energy_sum      NUMBER;

BEGIN
  lr_analysis       := ec_object_fluid_analysis.row_by_pk(p_analysis_no);
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
                    ec_object_fluid_analysis.cnpl_gcv(p_analysis_no));
      IF cur_comp.mol_pct>0 AND ln_gcv>=0 THEN
        ln_energy_sum := ln_energy_sum + (cur_comp.mol_pct / ln_comp_mol_sum * ln_gcv);
      ELSIF cur_comp.mol_pct>0 AND ln_gcv IS NULL THEN
        ln_energy_sum := NULL; -- cannot calculate when we are missing GCV for one component having mol% > 0.
      END IF;
    END LOOP;
  END IF;

  RETURN ln_energy_sum;

END calcHeatingValue;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function     : copyAnalysis
-- Description  : Copy Anaysis for Well, Stream for oil,gas, flash gas, gas inj as applicable
-- Preconditions:
-- Postcondition:
--
-- Using Tables: OBJECT_FLUID_ANALYSIS, FLUID_ANALYSIS_COMPONENT, STRM_ANALYSIS_EVENT, STRM_ANALYSIS_COMPONENT
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour
---------------------------------------------------------------------------------------------------

PROCEDURE  copyAnalysis( p_object_type   VARCHAR2,
                       p_src_object_id   VARCHAR2,
                       p_daytime         DATE,
                       p_target_daytime  DATE,
                       p_analysis_type   VARCHAR2,
                       p_sampling_method VARCHAR2,
                       p_daytime_summer_time VARCHAR2)
--</EC-DOC>
IS

ln_old_analysis_no NUMBER(10) := 0;
ln_new_analysis_no NUMBER(10):= 0;


BEGIN

  IF p_target_daytime IS NULL THEN
     RAISE_APPLICATION_ERROR(-20419,'New Date is missing or could not be understood as a date and time.');
  END IF;

  IF p_object_type IN ('STREAM','WELL') THEN

    INSERT INTO OBJECT_FLUID_ANALYSIS ( OBJECT_ID, OBJECT_CLASS_NAME, DAYTIME, ANALYSIS_TYPE, SAMPLING_METHOD, PHASE, VALID_FROM_DATE, PRODUCTION_DAY, ANALYSIS_STATUS, SAMPLE_PRESS, SAMPLE_TEMP, DENSITY, GAS_DENSITY, OIL_DENSITY, GROSS_LIQ_DENSITY, DENSITY_OBS, SP_GRAV, API, SHRINKAGE_FACTOR, SOLUTION_GOR, BS_W, BS_W_WT, MOL_WT, CNPL_MOL_WT, CNPL_SP_GRAV, CNPL_DENSITY, MW_MIX, SG_MIX, SULFUR_WT, GCV, GCV_FLASH, GCV_FLASH_PRESS, GCV_PRESS, NCV, GCR, WDP, RVP, H2S, CO2, SAND, SALT, EMULSION, EMULSION_FRAC, EMULSION_FACT, SCALE_INHIB, WAX_CONTENT, CRITICAL_PRESS, CRITICAL_TEMP, LABORATORY, LAB_REF_NO, SAMPLED_BY, SAMPLED_DATE, OIL_IN_WATER, O2, CHLORINE, ALUMINIUM, BARIUM, BICARBONATE, BORON, CALCIUM, CARBONATE, CHLORIDE, HYDROXIDE, IRON, IRON_TOTAL, LITHIUM, MAGNESIUM, ORGANIC_ACID, POTASSIUM, SILICON, SODIUM, STRONTIUM, SULFATE, PHOSPHORUS, CNPL_GCV, CNPL_API, VAPOUR, SALINITY, FLASH_GAS_FACTOR, OIL_IN_WATER_CONTENT, BUTANOATE, DISS_SOLIDS, ETHANOATE, HEXANOATE, METHANOATE, PENTANOATE, PH, PROPIONATE, RESISTIVITY, SULFATE_2, SUSP_SOLIDS, TOT_ALKALINITY, SAMPLING_POINT, FLUID_STATE, COMPONENT_SET, CGR, METER_FACTOR, TVP, GOR, TDS, HCDP, REL_DENSITY, WOBBE_INDEX, ZMIX, WATER_FRAC, MEG, CONDUCTIVITY, COMMENTS, VALUE_1, VALUE_2, VALUE_3, VALUE_4, VALUE_5, VALUE_6, VALUE_7, VALUE_8, VALUE_9, VALUE_10, VALUE_11, VALUE_12, VALUE_13, VALUE_14, VALUE_15, VALUE_16, VALUE_17, VALUE_18, VALUE_19, VALUE_20, VALUE_21, VALUE_22, VALUE_23, VALUE_24, VALUE_25, VALUE_26, VALUE_27, VALUE_28, VALUE_29, VALUE_30, VALUE_31, VALUE_32, VALUE_33, VALUE_34, VALUE_35, VALUE_36, VALUE_37, VALUE_38, VALUE_39, VALUE_40, VALUE_41, VALUE_42, VALUE_43, VALUE_44, VALUE_45, VALUE_46, VALUE_47, TEXT_1, TEXT_2, TEXT_3, TEXT_4, TEXT_5, TEXT_6, TEXT_7, TEXT_8, TEXT_9, TEXT_10, TEXT_11, TEXT_12, TEXT_13, TEXT_14, TEXT_15, TEXT_16, TEXT_17, TEXT_18, TEXT_19, TEXT_20, TEXT_21, TEXT_22, TEXT_23, TEXT_24, TEXT_25, TEXT_26, TEXT_27, TEXT_28, TEXT_29, TEXT_30, TEXT_31, TEXT_32, TEXT_33, TEXT_34, TEXT_35, TEXT_36, TEXT_37, TEXT_38, TEXT_39, TEXT_40, TEXT_41, TEXT_42, DATE_1, DATE_2, DATE_3, DATE_4, DATE_5, DATE_6, DATE_7, DATE_8, DATE_9, DATE_10, DATE_11)
    SELECT OBJECT_ID, OBJECT_CLASS_NAME, p_target_daytime, ANALYSIS_TYPE, SAMPLING_METHOD, PHASE, NULL, NULL, 'NEW', SAMPLE_PRESS, SAMPLE_TEMP, DENSITY, GAS_DENSITY, OIL_DENSITY, GROSS_LIQ_DENSITY, DENSITY_OBS, SP_GRAV, API, SHRINKAGE_FACTOR, SOLUTION_GOR, BS_W, BS_W_WT, MOL_WT, CNPL_MOL_WT, CNPL_SP_GRAV, CNPL_DENSITY, MW_MIX, SG_MIX, SULFUR_WT, GCV, GCV_FLASH, GCV_FLASH_PRESS, GCV_PRESS, NCV, GCR, WDP, RVP, H2S, CO2, SAND, SALT, EMULSION, EMULSION_FRAC, EMULSION_FACT, SCALE_INHIB, WAX_CONTENT, CRITICAL_PRESS, CRITICAL_TEMP, LABORATORY, LAB_REF_NO, SAMPLED_BY, SAMPLED_DATE, OIL_IN_WATER, O2, CHLORINE, ALUMINIUM, BARIUM, BICARBONATE, BORON, CALCIUM, CARBONATE, CHLORIDE, HYDROXIDE, IRON, IRON_TOTAL, LITHIUM, MAGNESIUM, ORGANIC_ACID, POTASSIUM, SILICON, SODIUM, STRONTIUM, SULFATE, PHOSPHORUS, CNPL_GCV, CNPL_API, VAPOUR, SALINITY, FLASH_GAS_FACTOR, OIL_IN_WATER_CONTENT, BUTANOATE, DISS_SOLIDS, ETHANOATE, HEXANOATE, METHANOATE, PENTANOATE, PH, PROPIONATE, RESISTIVITY, SULFATE_2, SUSP_SOLIDS, TOT_ALKALINITY, SAMPLING_POINT, FLUID_STATE, COMPONENT_SET, CGR, METER_FACTOR, TVP, GOR, TDS, HCDP, REL_DENSITY, WOBBE_INDEX, ZMIX, WATER_FRAC, MEG, CONDUCTIVITY, COMMENTS, VALUE_1, VALUE_2, VALUE_3, VALUE_4, VALUE_5, VALUE_6, VALUE_7, VALUE_8, VALUE_9, VALUE_10, VALUE_11, VALUE_12, VALUE_13, VALUE_14, VALUE_15, VALUE_16, VALUE_17, VALUE_18, VALUE_19, VALUE_20, VALUE_21, VALUE_22, VALUE_23, VALUE_24, VALUE_25, VALUE_26, VALUE_27, VALUE_28, VALUE_29, VALUE_30, VALUE_31, VALUE_32, VALUE_33, VALUE_34, VALUE_35, VALUE_36, VALUE_37, VALUE_38, VALUE_39, VALUE_40, VALUE_41, VALUE_42, VALUE_43, VALUE_44, VALUE_45, VALUE_46, VALUE_47, TEXT_1, TEXT_2, TEXT_3, TEXT_4, TEXT_5, TEXT_6, TEXT_7, TEXT_8, TEXT_9, TEXT_10, TEXT_11, TEXT_12, TEXT_13, TEXT_14, TEXT_15, TEXT_16, TEXT_17, TEXT_18, TEXT_19, TEXT_20, TEXT_21, TEXT_22, TEXT_23, TEXT_24, TEXT_25, TEXT_26, TEXT_27, TEXT_28, TEXT_29, TEXT_30, TEXT_31, TEXT_32, TEXT_33, TEXT_34, TEXT_35, TEXT_36, TEXT_37, TEXT_38, TEXT_39, TEXT_40, TEXT_41, TEXT_42, DATE_1, DATE_2, DATE_3, DATE_4, DATE_5, DATE_6, DATE_7, DATE_8, DATE_9, DATE_10, DATE_11
    FROM OBJECT_FLUID_ANALYSIS
    WHERE OBJECT_ID = p_src_object_id
    AND   DAYTIME   = p_daytime
    AND   ANALYSIS_TYPE = p_analysis_type
    AND   SAMPLING_METHOD = p_sampling_method ;

    SELECT ANALYSIS_NO
    INTO ln_old_analysis_no
    FROM OBJECT_FLUID_ANALYSIS
    WHERE OBJECT_ID = p_src_object_id
    AND   DAYTIME   = p_daytime
    AND   ANALYSIS_TYPE = p_analysis_type
    AND   SAMPLING_METHOD = p_sampling_method ;

    SELECT ANALYSIS_NO
    INTO ln_new_analysis_no
    FROM OBJECT_FLUID_ANALYSIS
    WHERE OBJECT_ID = p_src_object_id
    AND   DAYTIME   = p_target_daytime
    AND   ANALYSIS_TYPE = p_analysis_type
    AND   SAMPLING_METHOD = p_sampling_method ;

    INSERT INTO FLUID_ANALYSIS_COMPONENT ( ANALYSIS_NO, COMPONENT_NO, WT_PCT ,MOL_PCT,MOL_WT ,DENSITY,ENERGY_PCT  ,VOL_PCT,MEAS_MOL_WT ,MEAS_SPECIFIC_GRAVITY ,VALUE_1,VALUE_2,VALUE_3,VALUE_4,VALUE_5,VALUE_6,VALUE_7,VALUE_8,VALUE_9,VALUE_10    ,TEXT_1 ,TEXT_2 ,TEXT_3 ,TEXT_4)
    SELECT  ln_new_analysis_no ,COMPONENT_NO,WT_PCT ,MOL_PCT,MOL_WT ,DENSITY,ENERGY_PCT,VOL_PCT,MEAS_MOL_WT ,MEAS_SPECIFIC_GRAVITY ,VALUE_1,VALUE_2,VALUE_3,VALUE_4,VALUE_5,VALUE_6,VALUE_7,VALUE_8,VALUE_9,VALUE_10    ,TEXT_1 ,TEXT_2 ,TEXT_3 ,TEXT_4
    FROM FLUID_ANALYSIS_COMPONENT
    WHERE     ANALYSIS_NO = ln_old_analysis_no ;

  ELSIF p_object_type = 'PERIOD_STREAM' THEN

    INSERT INTO STRM_ANALYSIS_EVENT ( OBJECT_ID, DAYTIME, ANALYSIS_TYPE, SAMPLING_METHOD, DAYTIME_SUMMER_TIME, PRODUCTION_DAY, VALID_FROM_DATE, VALID_TO_DATE, VALID_FROM_SUMMER_TIME, VALID_TO_SUMMER_TIME, ANALYSIS_STATUS, PHASE, SAMPLE_PRESS, SAMPLE_TEMP, SP_GRAV, GCV, NCV, GCVM, NCVM, GCR, MOL_WT, CNPL_MOL_WT, CRITICAL_PRESS, CRITICAL_TEMP, RVP, SALT, DENSITY, LABORATORY, LAB_REF_NO, COMMENTS, SHRINKAGE_FACTOR, BSW_WT, CNPL_SP_GRAV, CNPL_DENSITY, BS_W, FLUID_STATE, CNPL_GCV, SULFUR_WT, VAPOUR, CNPL_API, SALINITY, FLASH_GAS_FACTOR, API, VALUE_1, VALUE_2, VALUE_3, VALUE_4, VALUE_5, VALUE_6, VALUE_7, VALUE_8, VALUE_9, VALUE_10, TEXT_1, TEXT_2, TEXT_3, TEXT_4 )
    SELECT  OBJECT_ID, p_target_daytime, ANALYSIS_TYPE, SAMPLING_METHOD, DAYTIME_SUMMER_TIME, NULL, NULL, VALID_TO_DATE, VALID_FROM_SUMMER_TIME, VALID_TO_SUMMER_TIME, 'NEW', PHASE, SAMPLE_PRESS, SAMPLE_TEMP, SP_GRAV, GCV, NCV, GCVM, NCVM, GCR, MOL_WT, CNPL_MOL_WT, CRITICAL_PRESS, CRITICAL_TEMP, RVP, SALT, DENSITY, LABORATORY, LAB_REF_NO, COMMENTS, SHRINKAGE_FACTOR, BSW_WT, CNPL_SP_GRAV, CNPL_DENSITY, BS_W, FLUID_STATE, CNPL_GCV, SULFUR_WT, VAPOUR, CNPL_API, SALINITY, FLASH_GAS_FACTOR, API, VALUE_1, VALUE_2, VALUE_3, VALUE_4, VALUE_5, VALUE_6, VALUE_7, VALUE_8, VALUE_9, VALUE_10, TEXT_1, TEXT_2, TEXT_3, TEXT_4
    FROM STRM_ANALYSIS_EVENT
    WHERE OBJECT_ID = p_src_object_id
    AND   DAYTIME   = p_daytime
    AND   ANALYSIS_TYPE = p_analysis_type
    AND   SAMPLING_METHOD = p_sampling_method ;

    SELECT ANALYSIS_NO
    INTO ln_old_analysis_no
    FROM STRM_ANALYSIS_EVENT
    WHERE OBJECT_ID = p_src_object_id
    AND   DAYTIME   = p_daytime
    AND   ANALYSIS_TYPE = p_analysis_type
    AND   SAMPLING_METHOD = p_sampling_method ;

    SELECT ANALYSIS_NO
    INTO ln_new_analysis_no
    FROM STRM_ANALYSIS_EVENT
    WHERE OBJECT_ID = p_src_object_id
    AND   DAYTIME   = p_target_daytime
    AND   ANALYSIS_TYPE = p_analysis_type
    AND   SAMPLING_METHOD = p_sampling_method ;

    INSERT INTO STRM_ANALYSIS_COMPONENT (ANALYSIS_NO, COMPONENT_NO, WT_PCT, MOL_PCT, MOL_WT, DENSITY, VALUE_1, VALUE_2, VALUE_3, VALUE_4, VALUE_5, VALUE_6, VALUE_7, VALUE_8, VALUE_9, VALUE_10, TEXT_1, TEXT_2, TEXT_3, TEXT_4)
    SELECT ln_new_analysis_no, COMPONENT_NO, WT_PCT, MOL_PCT, MOL_WT, DENSITY, VALUE_1, VALUE_2, VALUE_3, VALUE_4, VALUE_5, VALUE_6, VALUE_7, VALUE_8, VALUE_9, VALUE_10, TEXT_1, TEXT_2, TEXT_3, TEXT_4
    FROM STRM_ANALYSIS_COMPONENT
    WHERE ANALYSIS_NO = ln_old_analysis_no;

 END IF;




EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
        RAISE_APPLICATION_ERROR(-20418,'Analysis record already exists with same date and time.');
END copyAnalysis;




END EcDp_Fluid_Analysis;