CREATE OR REPLACE PACKAGE EcDp_Stream_Profit_Centre IS
/****************************************************************
** Package        :  EcDp_Stream_Profit_Centre
**
** $Revision: 1.4 $
**
** Purpose        :  This package is responsible for data access to
**                   fluid analysis figures for any analysis object.
**
** Documentation  :  www.energy-components.com
**
** Created  : 15.01.2010  Kenneth Masamba
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 02.06.2010 leongsei ECPD-13328: Modified function normalizeCompTo100 to add new parameter p_class_name
*****************************************************************/

FUNCTION getAnalysisSample (
   p_object_id        stream.object_id%TYPE,
   p_sampling_method  VARCHAR2,
   p_pc_id            VARCHAR2,
   p_daytime          DATE)

RETURN strm_pc_analysis%ROWTYPE;

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
   p_pc_id  VARCHAR2,
   p_valid_from_date          DATE,
   p_daytime          DATE)

RETURN strm_pc_analysis%ROWTYPE;

PRAGMA RESTRICT_REFERENCES (getLastAnalysisSample, WNDS, WNPS, RNPS);

FUNCTION getNextAnalysisSample(
   p_object_id        stream.object_id%TYPE,
   p_pc_id VARCHAR2,
   p_valid_from_date          DATE,
   p_daytime          DATE)

RETURN strm_pc_analysis%ROWTYPE;

PRAGMA RESTRICT_REFERENCES (getNextAnalysisSample, WNDS, WNPS, RNPS);

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

PROCEDURE createCompSetForAnalysis(p_comp_set VARCHAR2 DEFAULT NULL, p_daytime DATE, p_pc_id VARCHAR2, p_object_id VARCHAR2, p_user_id VARCHAR2 DEFAULT NULL);

PROCEDURE createCompSetForPeriodAnalysis(p_object_id VARCHAR2, p_sampling_method VARCHAR2, p_comp_set VARCHAR2, p_daytime DATE, p_user_id VARCHAR2 DEFAULT NULL);

PROCEDURE delCompSetForPeriodAnalysis(p_object_id VARCHAR2, p_sampling_method VARCHAR2, p_comp_set VARCHAR2, p_daytime DATE);


PROCEDURE convCompBetweenMolWt(
   p_object_id        stream.object_id%TYPE,
   p_daytime          DATE,
   p_pc_id            VARCHAR2,
   p_valid_from_date DATE,
   p_user_id          VARCHAR2 DEFAULT NULL);

PROCEDURE normalizeCompTo100(
   p_object_id        stream.object_id%TYPE,
   p_daytime          DATE,
   p_pc_id            VARCHAR2,
   p_valid_from_date  DATE,
   p_user_id          VARCHAR2 DEFAULT NULL,
   p_class_name       VARCHAR2 DEFAULT 'STRM_PC_COMP_ANALYSIS');

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

PROCEDURE set_analysis_rs(p_object_id VARCHAR2, p_analysis_type VARCHAR2, p_sampling_method VARCHAR2, p_daytime DATE,p_pc_id VARCHAR, p_user_id VARCHAR2 DEFAULT NULL, p_valid_from_date DATE);

END EcDp_Stream_Profit_Centre;