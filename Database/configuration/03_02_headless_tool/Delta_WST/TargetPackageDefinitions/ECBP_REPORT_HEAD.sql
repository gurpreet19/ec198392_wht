CREATE OR REPLACE PACKAGE EcBp_Report IS
/**************************************************************
** Package:    EcBp_Report
**
** $Revision: 1.12.14.2 $
**
** Filename:   EcBp_Report_head.sql
**
** Part of :   EC FRMW
**
** Purpose:
**
** General Logic:
**
** Document References:
**
**
** Created:   	08.11.05  Magnus Otter?
**
**
** Modification history:
**
**
** Date:     Whom:  Change description:
** --------  ----- --------------------------------------------
** 08.11.05   MOT   Created.
** 06.12.05   MOT   Added function isReportDefInGroup
** 06.01.06   MOT   Added insertReportRunnableParams and deleteReportRunnableParams
** 26.05.09   rajarsar Updated updateReportParamFromDef, insertReportDefParam, insertReportRunnableParams to add daytime and added insertReportDefinition and deleteReportDefinition
**************************************************************/


  /* Create report system parameters */
  PROCEDURE createReportSystemParams(p_report_template VARCHAR2, p_report_system VARCHAR2);

  /* Deletes report system parameters associated with the current report template in the REPORT_TEMPLATE_PARAM table*/
  PROCEDURE deleteReportSystemParams(p_report_template VARCHAR2, p_param_type VARCHAR2);

  /* Copies the report template parameter to the report definition and report runable */
  PROCEDURE copyReportParam(p_report_template VARCHAR2, p_parameter_name VARCHAR2, p_parameter_type VARCHAR2, p_parameter_sub_type VARCHAR2, p_access_check_ind VARCHAR2, p_sort_order NUMBER);

  /* Updates the report definition parameter and report runable parameter due to an update on the report template parameter*/
  PROCEDURE updateReportParam(p_report_template VARCHAR2,
            p_new_parameter_name VARCHAR2, p_old_parameter_name VARCHAR2, p_parameter_type VARCHAR2, p_new_parameter_sub_type VARCHAR2, p_old_parameter_sub_type VARCHAR2, p_new_access_check_ind VARCHAR2, p_old_access_check_ind VARCHAR2, p_sort_order NUMBER);

 /* Updates report parameters on report runable and report set after
    1. Adding/Deleting/Updating an alias on report definition
    2. Adding/Removing a value on report definition*/
  PROCEDURE updateReportParamFromDef(p_report_definition_no NUMBER, p_parameter_name VARCHAR2, p_parameter_type VARCHAR2,
            p_parameter_sub_type VARCHAR2, p_new_parameter_value VARCHAR2, p_old_parameter_value VARCHAR2, p_new_alias VARCHAR2, p_old_alias VARCHAR2, p_daytime DATE, p_new_access_check_ind VARCHAR2, p_old_access_check_ind VARCHAR2);

  /* Deletes the report definition parameter and report runable parameter due to a delete on the report template parameter*/
  PROCEDURE deleteReportParam(p_report_template VARCHAR2, p_parameter_name VARCHAR2);

  /* Delete parameters from report definition given by the report template*/
  PROCEDURE deleteReportDefParam(p_report_template VARCHAR2,p_report_definition_no NUMBER);

  /* Insert parameters in report definition given by the report template*/
  PROCEDURE insertReportDefParam(p_report_template VARCHAR2,p_report_definition_no NUMBER, p_daytime DATE);

  /* Insert parameters in report runable parameter*/
  PROCEDURE insertReportRunnableParams(p_report_runable_no NUMBER, p_report_group VARCHAR2,  p_user_id VARCHAR2 DEFAULT NULL);


  /* Insert parameters in report set parameter*/
  PROCEDURE insertReportSetParams(p_report_set_no NUMBER   );

   /* Delete parameters in report runable parameter*/
  PROCEDURE deleteReportRunnableParams(p_report_runable_no NUMBER);

   /* Delete parameters in reportset parameter*/
  PROCEDURE deleteReportSetParams(p_report_set_no NUMBER);

   /* Delete parameteres in report param */
  PROCEDURE  delReportParam(p_report_no  NUMBER);

  /*Check if the given report definition number is a part of the given group. Return 'Y' if it is.*/
  FUNCTION isReportDefInGroup(p_report_def_no VARCHAR2, p_report_group VARCHAR2) RETURN VARCHAR2;

  /* Insert or update template parameter. */
  PROCEDURE setReportTmplParam(
      p_report_template_code VARCHAR2,
      p_report_parameter_name VARCHAR2,
      p_report_parameter_type VARCHAR2,
      p_report_parameter_sub_type VARCHAR2,
      p_mandatory_ind VARCHAR2,
      p_access_check_ind VARCHAR2,
      p_sort_order NUMBER,
      p_userid VARCHAR2);


   /* Inserts into report definition*/
  PROCEDURE insertReportDefinition(
      p_rep_group_code VARCHAR2,
      p_daytime DATE);

   /* Deletes report definition and report definition param for the given group and code */
   PROCEDURE deleteReportDefinition(p_rep_group_code VARCHAR2,p_daytime DATE);

   /* Insert default report published parameters for one generated report with given report_published_no */
   PROCEDURE insertReportPublishedParams(p_report_no NUMBER, p_report_published_no NUMBER);

   /* Check to see if the report definition has HIDE_IND set to true or false */
   FUNCTION getHideInd(p_rep_group_code VARCHAR2) RETURN VARCHAR2;

END EcBp_Report;