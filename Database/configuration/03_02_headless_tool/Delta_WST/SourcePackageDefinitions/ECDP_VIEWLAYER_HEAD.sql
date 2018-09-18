CREATE OR REPLACE PACKAGE ecdp_viewlayer IS
/**
 * Build class views, triggers and packages for all classes that match the given search criterion.
 * <br/><br/>
 * <u>Examples:</u>
 * <pre class="sql">
 * SQL> -- All "dirty" classes
 * SQL> execute ecdp_viewlayer.BuildViewLayer();
 * </pre>
 *
 * <pre class="sql">
 * SQL> -- All EC_PROD classes regardless of whether they are "dirty"
 * SQL> execute ecdp_viewlayer.BuildViewLayer(p_app_space_cntx => 'EC_PROD', p_force => 'Y');
 * </pre>
 *
 * <pre class="sql">
 * SQL> -- WELL class if it is "dirty"
 * SQL> execute ecdp_viewlayer.BuildViewLayer('WELL');
 * </pre>
 *
 * <pre class="sql">
 * SQL> -- WELL class regardless of whether it is "dirty"
 * SQL> execute ecdp_viewlayer.BuildViewLayer('WELL', p_force => 'Y');
 * </pre>
 *
 * @param p_class_name Name of class, or <var>null</var> for all classes
 * @param p_app_space_cntx App space context, or <var>null</var> for all contexts
 * @param p_ignore_error_ind Indicates whether errors should be ignored or not
 * @param p_force Set to <var>Y</var> to force re-build of non-dirty classes
 * @param p_incl_report to generate related report classes
 */
PROCEDURE BuildViewLayer(
          p_class_name         IN VARCHAR2 DEFAULT NULL,
          p_app_space_cntx     IN VARCHAR2 DEFAULT NULL,
          p_ignore_error_ind   IN VARCHAR2 DEFAULT 'N',
          p_force              IN VARCHAR2 DEFAULT 'N',
          p_incl_report        IN VARCHAR2 DEFAULT 'N'
);

/**
 * Build reporting views for all classes that match the given search criterion.
 * <br/><br/>
 * <u>Examples:</u>
 * <pre class="sql">
 * SQL> -- All "dirty" classes
 * SQL> execute ecdp_viewlayer.BuildReportLayer();
 * </pre>
 *
 * <pre class="sql">
 * SQL> -- All EC_PROD classes regardless of whether they are "dirty"
 * SQL> execute ecdp_viewlayer.BuildReportLayer(p_app_space_cntx => 'EC_PROD', p_force => 'Y');
 * </pre>
 *
 * <pre class="sql">
 * SQL> -- WELL class if it is "dirty"
 * SQL> execute ecdp_viewlayer.BuildReportLayer('WELL');
 * </pre>
 *
 * <pre class="sql">
 * SQL> -- WELL class regardless of whether it is "dirty"
 * SQL> execute ecdp_viewlayer.BuildReportLayer('WELL', p_force => 'Y');
 * </pre>
 *
 * <pre class="sql">
 * SQL> -- Rebuilds all "dirty" classes and their group model dependents.
 * SQL> -- Use this option when the group model has changed.
 * SQL> execute ecdp_viewlayer.BuildReportLayer(p_incl_grpmodel_deps => 'Y');
 * </pre>
 *
 * @param p_class_name Name of class, or <var>null</var> for all classes
 * @param p_app_space_cntx App space context, or <var>null</var> for all contexts
 * @param p_ignore_error_ind Indicates whether errors should be ignored or not
 * @param p_incl_grpmodel_deps Set to <var>Y</var> to build group model classes that depend on a "dirty" class
 */
PROCEDURE BuildReportLayer(
          p_class_name         IN VARCHAR2 DEFAULT NULL,
          p_app_space_cntx     IN VARCHAR2 DEFAULT NULL,
          p_force              IN VARCHAR2 DEFAULT 'N'
);

/**
  * Creates <var>deferment_groups</var> view. Currently used by the <var>ec-db-installer</var>.
  * @deprecated This procedure is called indirectly from <var>BuildViewLayer</var> and there is no need to call it independently.
  */
PROCEDURE CreateDefermentGroupsView;

/**
  * Creates <var>objects</var> view. This view is a union of all the objects classes, and are used several places.There now is a more efficient way to look up this
    information from the objects_table, but this is still kept for backward compability and ringfencing purposes
  */
PROCEDURE CreateObjectsView;

/**
  * Creates <var>objects_version</var> view. This view is a union of all the objects classes, and are used several places.There now is a more efficient way to look up this
    information from the objects_table, but this is still kept for backward compability and ringfencing purposes
  */

PROCEDURE CreateObjectsVersionView;


/**
 * Recompiles all generated class objects (i.e. views, triggers and packages). The procedure currently used by the <var>ec-db-installer</var>.
 * @deprecated This procedure will be phased out in favour of nativ Oracle alternatives.
 */
PROCEDURE RecompileInvalidViewLayer;

END ecdp_viewlayer;