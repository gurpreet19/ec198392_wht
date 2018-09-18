CREATE OR REPLACE PACKAGE EcDp_Fluid_Analysis IS
/****************************************************************
** Package        :  EcDp_Fluid_Analysis
**
** $Revision: 1.28.2.5 $
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
** 27.05.2004 DN       Added getLastAnalysisSampleByObject and createCompSetForAnalysis.
** 01.06.2004 DN       Added normalizeCompTo100 and convCompBetweenMolWt.
** 23.07.2004 kaurrnar Changes p_object_id type and update as necessary
** 13.12.2005 DN       TI#2288: Added getNextAnalysisSample.
** 23.12.2005 chongjer TI#2691: Added auiSetProductionDay and aiSetObjectClassName.
** 24.04.2006 Lau      TI#3310: Added normalizeCompTo100_Product
** 29.04.2006 ZakiiAri TI#3595: Added new parameter (p_user_id) on procedure createCompSetForAnalysis, convCompBetweenMolWt, normalizeCompTo100, auiSetProductionDay, aiSetObjectClassName
** 28.09.2007 rajarsar ECPD#6052: Updated createCompSetForAnalysis, createCompSetForPeriodAnalysis and delCompSetForPeriodAnalysis
** 19.06.2008 jailunur ECPD5638: Added new function sumComponentsAnalysis.
** 02.01.2009 oonnnng  ECPD-9983: Added new parameter PHASE to getLastAnalysisSample() and getNextAnalysisSample() functions.
** 10.04.2009 oonnnng  ECPD-6067: Added addtional parameter p_object_id to createCompSetForAnalysis() function.
** 01.09.2009 aliassit ECPD-12526: Added parameter p_phase to getLastAnalysisDate and getLastAnalysisNumber
** 08.10.2009 oonnnng  ECPD-12862: Removed addtional parameter p_object_id in createCompSetForAnalysis() function.
** 30.10.2009 rajarsar ECPD-12630: Updated createCompSetForAnalysis procedure.
** 02.06.2010 leongsei ECPD-13328: Modified function normalizeCompTo100, normalizeCompTo100PeriodAn, normalizeCompTo100_Product to add extra parameter p_class_name
** 21.06.2010 rajarsar ECPD-13988: Modified procedure  convCompBetweenMolWt, convCompBetweenMolWtPeriodAn to add extra parameter p_convert_to
** 23.08.2011 rajarsar ECPD-18340: Added convCompMolToEnergy.
** 18.06.2012 choonshu ECPD-21293: Modified getLastAnalysisSampleByObject function.
** 05.08.2013 wonggkai ECPD-25025:  Modified normalizeCompTo100 and normalizeCompTo100PeriodAn, add getNextAnalysisSamplePeriodAn, getAnalysisNo and getAnalysisNoPeriodAn method.
** 21.08.2013 wonggkai ECPD-25025: fix pragma for getNextAnalysisSamplePeriodAn and getAnalysisNoPeriodAn
** 12.05.2015 shindani ECPD-25870: Modified procedure normalizeCompTo100PeriodAn, added call to user exit procedure.
*****************************************************************/

FUNCTION getAnalysisNumber (
   p_object_id        stream.object_id%TYPE,
   p_analysis_type    VARCHAR2,
   p_sampling_method  VARCHAR2,
   p_daytime          DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getAnalysisNumber, WNDS, WNPS, RNPS);


FUNCTION getAnalysisSample (
   p_object_id        stream.object_id%TYPE,
   p_analysis_type    VARCHAR2,
   p_sampling_method  VARCHAR2,
   p_daytime          DATE)

RETURN object_fluid_analysis%ROWTYPE;

PRAGMA RESTRICT_REFERENCES (getAnalysisSample, WNDS, WNPS, RNPS);


FUNCTION getPeriodAnalysisSample (
   p_object_id            stream.object_id%TYPE,
   p_analysis_type        VARCHAR2,
   p_sampling_method      VARCHAR2,
   p_daytime              DATE,
   p_daytime_summer_time  VARCHAR2)

RETURN strm_analysis_event%ROWTYPE;
PRAGMA RESTRICT_REFERENCES (getPeriodAnalysisSample, WNDS, WNPS, RNPS);

FUNCTION getLastAnalysisSample(
   p_object_id        stream.object_id%TYPE,
   p_analysis_type    VARCHAR2,
   p_sampling_method  VARCHAR2,
   p_daytime          DATE,
   p_phase            VARCHAR2 default NULL)

RETURN object_fluid_analysis%ROWTYPE;

PRAGMA RESTRICT_REFERENCES (getLastAnalysisSample, WNDS, WNPS, RNPS);


FUNCTION getLastAnalysisDate (
   p_object_id        stream.object_id%TYPE,
   p_analysis_type    VARCHAR2,
   p_sampling_method  VARCHAR2,
   p_daytime          DATE,
   p_phase            VARCHAR2 default NULL)

RETURN DATE;

PRAGMA RESTRICT_REFERENCES (getLastAnalysisDate, WNDS, WNPS, RNPS);


FUNCTION getLastAnalysisNumber (
   p_object_id        stream.object_id%TYPE,
   p_analysis_type    VARCHAR2,
   p_sampling_method  VARCHAR2,
   p_daytime          DATE,
   p_phase            VARCHAR2 default NULL)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getLastAnalysisNumber, WNDS, WNPS, RNPS);


FUNCTION getLastAnalysisSampleByObject (
   p_object_id        stream.object_id%TYPE,
   p_phase            VARCHAR2,
   p_daytime          DATE,
   p_analysis_type    VARCHAR2,
   p_sampling_method  VARCHAR2)

RETURN object_fluid_analysis%ROWTYPE;

PRAGMA RESTRICT_REFERENCES (getLastAnalysisSampleByObject, WNDS, WNPS, RNPS);

FUNCTION getNextAnalysisSample(
   p_object_id        stream.object_id%TYPE,
   p_analysis_type    VARCHAR2,
   p_sampling_method  VARCHAR2,
   p_daytime          DATE,
   p_phase            VARCHAR2 default NULL)
RETURN object_fluid_analysis%ROWTYPE;

PRAGMA RESTRICT_REFERENCES (getNextAnalysisSample, WNDS, WNPS, RNPS);

FUNCTION getNextAnalysisSamplePeriodAn(
   p_object_id        stream.object_id%TYPE,
   p_analysis_type    VARCHAR2,
   p_sampling_method  VARCHAR2,
   p_daytime          DATE,
   p_phase            VARCHAR2 default NULL)
RETURN STRM_ANALYSIS_EVENT%ROWTYPE;

PRAGMA RESTRICT_REFERENCES (getNextAnalysisSamplePeriodAn, WNDS, WNPS, RNPS);

FUNCTION getPeriodAnalysisNumberByUK (
   p_object_id            stream.object_id%TYPE,
   p_analysis_type        VARCHAR2,
   p_daytime            DATE,
   p_sampling_method      VARCHAR2,
   p_daytime_summer_time        VARCHAR2)

RETURN NUMBER;

FUNCTION getAverageOIW (
   p_object_id            stream.object_id%TYPE,
   p_analysis_type        VARCHAR2,
   p_sampling_method    VARCHAR2,
   p_analysis_status    VARCHAR2,
   p_daytime      DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getAverageOIW, WNDS, WNPS, RNPS);

PROCEDURE createCompSetForAnalysis(p_comp_set VARCHAR2 DEFAULT NULL, p_analysis_no NUMBER, p_daytime DATE, p_user_id VARCHAR2 DEFAULT NULL);

PROCEDURE createCompSetForPeriodAnalysis(p_object_id VARCHAR2, p_sampling_method VARCHAR2, p_comp_set VARCHAR2, p_daytime DATE, p_user_id VARCHAR2 DEFAULT NULL);

PROCEDURE delCompSetForPeriodAnalysis(p_object_id VARCHAR2, p_sampling_method VARCHAR2, p_comp_set VARCHAR2, p_daytime DATE);


PROCEDURE convCompBetweenMolWt(
   p_object_id        stream.object_id%TYPE,
   p_analysis_type    VARCHAR2,
   p_sampling_method  VARCHAR2,
   p_daytime          DATE,
   p_user_id          VARCHAR2 DEFAULT NULL,
   p_convert_to       VARCHAR2 DEFAULT NULL);

PROCEDURE convCompBetweenMolWtPeriodAn(
   p_object_id            stream.object_id%TYPE,
   p_analysis_type        VARCHAR2,
   p_sampling_method      VARCHAR2,
   p_daytime              DATE,
   p_daytime_summer_time  VARCHAR2,
   p_user_id              VARCHAR2 DEFAULT NULL,
   p_convert_to       VARCHAR2 DEFAULT NULL);

PROCEDURE convCompMolToEnergy (
   p_analysis_no      NUMBER,
   p_user  VARCHAR2);

PROCEDURE normalizeCompTo100(
   p_object_id        stream.object_id%TYPE,
   p_analysis_type    VARCHAR2,
   p_sampling_method  VARCHAR2,
   p_daytime          DATE,
   p_user_id          VARCHAR2 DEFAULT NULL,
   p_class_name       VARCHAR2 DEFAULT 'FLUID_ANALYSIS_COMPONENT');


PROCEDURE normalizeCompTo100PeriodAn(
   p_object_id            stream.object_id%TYPE,
   p_analysis_type        VARCHAR2,
   p_sampling_method      VARCHAR2,
   p_daytime              DATE,
   p_daytime_summer_time  VARCHAR2,
   p_user_id              VARCHAR2 DEFAULT NULL,
   p_class_name           VARCHAR2 DEFAULT 'STRM_ANALYSIS_COMPONENT');


PROCEDURE auiSetProductionDay(
   p_object_id        VARCHAR2,
   p_daytime          DATE,
   p_analysis_type    VARCHAR2,
   p_sampling_method  VARCHAR2,
   p_phase            VARCHAR2,
   p_user_id          VARCHAR2 DEFAULT NULL);

PROCEDURE aiSetObjectClassName(
   p_object_id        VARCHAR2,
   p_daytime          DATE,
   p_analysis_type    VARCHAR2,
   p_sampling_method  VARCHAR2,
   p_phase            VARCHAR2,
   p_user_id          VARCHAR2 DEFAULT NULL);

PROCEDURE normalizeCompTo100_Product(
   p_object_id        stream.object_id%TYPE,
   p_analysis_type    VARCHAR2,
   p_sampling_method  VARCHAR2,
   p_daytime          DATE,
   p_user_id          VARCHAR2 DEFAULT NULL,
   p_class_name       VARCHAR2 DEFAULT 'FLUID_ANALYSIS_PRODUCT');

FUNCTION sumComponentsAnalysis (
   p_analysis_no      NUMBER)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (sumComponentsAnalysis, WNDS, WNPS, RNPS);


FUNCTION getAnalysisNo (
   p_object_id        stream.object_id%TYPE,
   p_analysis_type    VARCHAR2,
   p_sampling_method  VARCHAR2,
   p_daytime          DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getAnalysisNo, WNDS, WNPS, RNPS);


FUNCTION getAnalysisNoPeriodAn (
   p_object_id        stream.object_id%TYPE,
   p_analysis_type    VARCHAR2,
   p_sampling_method  VARCHAR2,
   p_daytime          DATE)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getAnalysisNoPeriodAn, WNDS, WNPS, RNPS);


END EcDp_Fluid_Analysis;