CREATE OR REPLACE PACKAGE Ue_Fluid_Analysis IS

/****************************************************************
** Package        :  Ue_Fluid_Analysis
**
** $Revision:
**
** Purpose        :  Customer specific implementation for fluid analysis
**
** Documentation  :  www.energy-components.com
**
** Created  : 11.05.2015  shindani
**
** Modification history:
**
** Date        Whom     Change description:
** ------      ----     --------------------------------------

*****************************************************************/

PROCEDURE normalizeCompTo100PeriodAn (p_object_id            stream.object_id%TYPE,
   p_analysis_type        VARCHAR2,
   p_sampling_method      VARCHAR2,
   p_daytime              DATE,
   p_daytime_summer_time  VARCHAR2,
   p_user_id              VARCHAR2 DEFAULT NULL,
   p_class_name           VARCHAR2 DEFAULT 'STRM_ANALYSIS_COMPONENT',
   p_code_exist OUT VARCHAR2);


END Ue_Fluid_Analysis;