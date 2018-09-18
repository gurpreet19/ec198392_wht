CREATE OR REPLACE PACKAGE EcDp_Well_Analysis IS

/****************************************************************
** Package        :  EcDp_Well_Analysis, header part
**
** $Revision: 1.3 $
**
** Purpose        :  Defines well analysis.
**
** Documentation  :  www.energy-components.com
**
** Created  : 23.06.2008  Nurliza Jailuddin
**
** Modification history:
**
** Version      Date     Whom      Change description:
** -------      ------   -----     --------------------------------------
** 1.0          23.06.08  JAILUNUR  Initial version
** 1.2          22.07.08  JAILUNUR  ECPD-5638: Add function ErrCond
*****************************************************************/

PROCEDURE runQaAnalysis(
  p_nav_class_name VARCHAR2,
  p_nav_object_id VARCHAR2,
  p_fromdate DATE,
  p_todate DATE,
  p_sampling_method VARCHAR2,
  p_analysis_status VARCHAR2);

PROCEDURE runOilValidations(
  p_area VARCHAR2,
  p_subarea VARCHAR2,
  p_fcty_1 VARCHAR2,
  p_fcty_2 VARCHAR2,
  p_fromdate DATE,
  p_todate DATE,
  p_sampling_method VARCHAR2,
  p_analysis_status VARCHAR2);


PROCEDURE runGasValidations(
  p_area VARCHAR2,
  p_subarea VARCHAR2,
  p_fcty_1 VARCHAR2,
  p_fcty_2 VARCHAR2,
  p_fromdate DATE,
  p_todate DATE,
  p_sampling_method VARCHAR2,
  p_analysis_status VARCHAR2);

FUNCTION WarnMin(
      p_analysis_type VARCHAR2,
      p_attribute VARCHAR2,
      p_value NUMBER,
      p_analysis_no NUMBER,
      p_val_limit NUMBER) return VARCHAR2;

FUNCTION WarnMax(
      p_analysis_type VARCHAR2,
      p_attribute VARCHAR2,
      p_value NUMBER,
      p_analysis_no NUMBER,
      p_val_limit NUMBER) return VARCHAR2;

FUNCTION WarnPct(
      p_analysis_type VARCHAR2,
      p_attribute VARCHAR2,
      p_column VARCHAR2,
      p_daytime DATE,
      p_value NUMBER,
      p_object_id VARCHAR2,
      p_val_limit NUMBER) return VARCHAR2;


FUNCTION ErrCond(
      p_analysis_type VARCHAR2,
      p_attribute VARCHAR2,
      p_value NUMBER,
      p_analysis_no NUMBER,
      p_cond VARCHAR2) return VARCHAR2;


FUNCTION ErrMin(
      p_analysis_type VARCHAR2,
      p_attribute VARCHAR2,
      p_value NUMBER,
      p_analysis_no NUMBER,
      p_val_limit NUMBER) return VARCHAR2;

FUNCTION ErrMax(
      p_analysis_type VARCHAR2,
      p_attribute VARCHAR2,
      p_value NUMBER,
      p_analysis_no NUMBER,
      p_val_limit NUMBER) return VARCHAR2;

FUNCTION ErrMand(
      p_analysis_type VARCHAR2,
      p_attribute VARCHAR2,
      p_value NUMBER,
      p_analysis_no NUMBER,
      p_cond VARCHAR2) return VARCHAR2;

END EcDp_Well_Analysis;