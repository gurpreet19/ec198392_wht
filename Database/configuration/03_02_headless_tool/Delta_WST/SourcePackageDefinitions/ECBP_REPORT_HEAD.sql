CREATE OR REPLACE PACKAGE EcBp_Report IS
/**************************************************************
** Package:    EcBp_Report
**
** $Revision: 1.14 $
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
** Created:     08.11.05  Magnus Otterå
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

  /* Insert a new report parameter on all report definitions connected to given report template */
  PROCEDURE insertReportDefinitionParam(p_report_template VARCHAR2, p_parameter_name VARCHAR2, p_parameter_type VARCHAR2, p_parameter_sub_type VARCHAR2, p_access_check_ind VARCHAR2, p_sort_order NUMBER);

  /* Insert a new report parameter on all report runnable connected to given report definition*/
  PROCEDURE insertReportRunableParam(p_report_definition_no NUMBER, p_daytime DATE, p_parameter_name VARCHAR2, p_parameter_type VARCHAR2, p_parameter_sub_type VARCHAR2, p_access_check_ind VARCHAR2, p_sort_order NUMBER);

  /* Insert new report parameter on all report sets and reports in report sets, connected to the given report runnable. */
  PROCEDURE insertReportSetParam(p_report_runable_no NUMBER, p_daytime DATE, p_parameter_name VARCHAR2, p_parameter_type VARCHAR2, p_parameter_sub_type VARCHAR2, p_access_check_ind VARCHAR2, p_sort_order NUMBER);

  /*Updates the report definition parameter based on changes on report template parameter. */
  PROCEDURE updateReportDefParam(p_report_template VARCHAR2, p_new_parameter_name VARCHAR2,p_old_parameter_name VARCHAR2, p_parameter_type VARCHAR2, p_new_parameter_sub_type VARCHAR2,p_old_parameter_sub_type VARCHAR2, p_new_access_check_ind VARCHAR2, p_old_access_check_ind VARCHAR2, p_sort_order NUMBER);

  /*Updates the report runnable parameter based on update on the report definition parameter.*/
  PROCEDURE updateReportRunnableParam(p_report_definition_no VARCHAR2, p_daytime DATE, p_new_parameter_name VARCHAR2,p_old_parameter_name VARCHAR2, p_parameter_type VARCHAR2, p_parameter_sub_type VARCHAR2, p_new_access_check_ind VARCHAR2, p_new_sort_order NUMBER, p_old_parameter_value VARCHAR2, p_new_parameter_value VARCHAR2, p_old_alias VARCHAR2, p_new_alias VARCHAR2 );

  /*Updates the report set parameter based on update on the report runable parameter (both report_set_report_param and report_set_param)*/
  PROCEDURE updateReportSetParam(p_report_runable_no NUMBER, p_daytime DATE, p_new_parameter_name VARCHAR2,p_old_parameter_name VARCHAR2, p_new_access_check_ind VARCHAR2, p_old_access_check_ind VARCHAR2, p_new_sort_order NUMBER, p_old_sort_order NUMBER, p_old_parameter_value VARCHAR2, p_new_parameter_value VARCHAR2);


  /* Deletes the report definition parameter and report runable parameter due to a delete on the report template parameter*/
  PROCEDURE deleteReportDefParam(p_report_template VARCHAR2, p_parameter_name VARCHAR2);

  /*Deletes the report runnable parameter connected to a definition. */
  PROCEDURE deleteReportRunableParam(p_report_definition VARCHAR2, p_daytime DATE, p_parameter_name VARCHAR2);

  /*Deletes the report parameter from all report sets (both report_set_report_param and report_set_param)*/
  PROCEDURE deleteReportSetParam(p_report_runable_no VARCHAR2, p_daytime DATE, p_parameter_name VARCHAR2);

  /* Delete parameters from a version of report definition */
  PROCEDURE deleteReportDefParams(p_report_definition_no VARCHAR2, p_daytime DATE);

  /* Insert all parameters in report definition given by the report template*/
  PROCEDURE insertReportDefParams(p_report_template VARCHAR2,p_report_definition_no NUMBER, p_daytime DATE);

  /* Insert parameters in report runable parameter*/
  PROCEDURE insertReportRunnableParams(p_report_runable_no NUMBER, p_report_group VARCHAR2,  p_user_id VARCHAR2 DEFAULT NULL);


  /* Insert parameters in report set parameter*/
  PROCEDURE insertReportSetParams(p_report_set_no NUMBER, p_ref_no NUMBER);

   /* Delete parameters in report runable parameter*/
  PROCEDURE deleteReportRunnableParams(p_report_runable_no NUMBER);

   /* Delete parameters in reportset parameter*/
  PROCEDURE deleteReportSetParams(p_report_set_no NUMBER);

  /* Delete parameters in report set report parameter*/
  PROCEDURE deleteReportSetReportParams(p_report_set_no NUMBER, p_ref_no NUMBER);

  /* Delete report set generations*/
  PROCEDURE deleteReportSetDependencies(p_report_set_no NUMBER);


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

   PROCEDURE setReportSetGenStartTime( p_seq_no NUMBER );

   /* Check if the user has access to see the generated report */
   FUNCTION hasAccessToGeneratedReport( p_report_no NUMBER ) RETURN VARCHAR2;

   /* Check if the user has access to see the report runable*/
   FUNCTION hasAccessToReportRunable( p_report_runable_no NUMBER, p_rep_group_code VARCHAR2, p_report_area_id VARCHAR2, p_nav_date DATE) RETURN VARCHAR2;

   /* Check if the user has access to see the published report */
   FUNCTION hasAccessToPublishedReport( p_report_published_no NUMBER, p_report_no NUMBER ) RETURN VARCHAR2;

   /* A procedure to use in jasper report, for testing plsql queries */
   PROCEDURE testJasperPlsql(  emp_cursor out sys_refcursor );

END EcBp_Report;