CREATE OR REPLACE PACKAGE BODY EcDp_GenClassCode IS
/****************************************************************
** Package        :  EcDp_GenClass, body part
**
** $Revision: 1.289 $
**
** Purpose        :  Generate Views, instead of triggers and class methods based on class definitions.
**
** Documentation  :  www.energy-components.com
**
*****************************************************************/

FUNCTION getCurrentPackageRevision
RETURN VARCHAR2
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END getCurrentPackageRevision;

PROCEDURE SafeBuild(p_object_name VARCHAR2,
                    p_object_type VARCHAR2,
                    p_sql         CLOB,
                    p_target      VARCHAR2 DEFAULT 'CREATE',
                    p_sql2        VARCHAR2 DEFAULT '',
                    p_id          VARCHAR2 DEFAULT 'GENCODE'
)
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END SafeBuild;

FUNCTION getDataclassJoinDaytime(
   p_class_name       VARCHAR2
)
RETURN VARCHAR2
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END getDataclassJoinDaytime;

PROCEDURE ObjectClassView(
   p_class_name  VARCHAR2,
   p_daytime    DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
)
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END ObjectClassView;

PROCEDURE ObjectClassJNView(
   p_class_name  VARCHAR2,
   p_daytime    DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
)
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END ObjectClassJNView;

PROCEDURE InterfaceClassView(
   p_class_name  VARCHAR2,
   p_daytime    DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
)
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END InterfaceClassView;

PROCEDURE TableClassView(
   p_class_name  VARCHAR2,
   p_daytime    DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
)
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END TableClassView;

PROCEDURE TableClassJNView(
   p_class_name  VARCHAR2,
   p_daytime    DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
)
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END TableClassJNView;

PROCEDURE DataClassView(
   p_class_name  VARCHAR2,
   p_daytime    DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
)
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END DataClassView;

PROCEDURE DataClassJNView(
   p_class_name  VARCHAR2,
   p_daytime    DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
)
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END DataClassJNView;


PROCEDURE ObjectClassViewIUTrg(
   p_class_name  VARCHAR2,
   p_daytime    DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
)
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END ObjectClassViewIUTrg;

PROCEDURE TableClassViewIUTrg(
   p_class_name  VARCHAR2,
   p_daytime    DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
)
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END TableClassViewIUTrg;

PROCEDURE DataClassViewIUTrg(
   p_class_name  VARCHAR2,
   p_daytime    DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
)
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END DataClassViewIUTrg;

PROCEDURE BuildView(
        p_class_name        VARCHAR2,
        p_target          VARCHAR2 DEFAULT 'CREATE'
)
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END BuildView;

PROCEDURE BuildViewAutonomous(
        p_class_name        VARCHAR2,
        p_target          VARCHAR2 DEFAULT 'CREATE'
)
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END BuildViewAutonomous;

PROCEDURE RecompileInvalidViewLayer
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END RecompileInvalidViewLayer;

PROCEDURE BuildViewLayer(
          p_target           VARCHAR2 DEFAULT 'CREATE',
          p_class_name       VARCHAR2 DEFAULT NULL,
          p_app_space_code   VARCHAR2 DEFAULT NULL,
          p_ignore_error_ind VARCHAR2 DEFAULT 'N',    -- used in to not raise error in some build cases
          p_no_refresh       VARCHAR2 DEFAULT 'N'    -- used to not refresh materialized views
)
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END BuildViewLayer;

PROCEDURE BuildViewLayerAutonomous(
          p_target           VARCHAR2 DEFAULT 'CREATE',
          p_class_name       VARCHAR2 DEFAULT NULL,
          p_app_space_code   VARCHAR2 DEFAULT NULL,
          p_ignore_error_ind VARCHAR2 DEFAULT 'N'    -- used in to not raise error in some build cases
)
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END BuildViewLayerAutonomous;

PROCEDURE BuildTableViews(p_target VARCHAR2 DEFAULT 'CREATE')
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END BuildTableViews;

PROCEDURE BuildReportLayer(p_target VARCHAR2 DEFAULT 'CREATE',
                           p_class_name  VARCHAR2 DEFAULT NULL,
                           p_app_space_code VARCHAR2 DEFAULT NULL,
               			   p_no_refresh       VARCHAR2 DEFAULT 'N'   -- used to not refresh materialized views
)
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END BuildReportLayer;

PROCEDURE BuildReportLayerAutonomous(p_target VARCHAR2 DEFAULT 'CREATE',
                           p_class_name  VARCHAR2 DEFAULT NULL,
                           p_app_space_code VARCHAR2 DEFAULT NULL,
                           p_no_refresh       VARCHAR2 DEFAULT 'N'    -- used to not refresh materialized views
)
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END BuildReportLayerAutonomous;

PROCEDURE InterfaceClassViewIUTrg(
   p_class_name  VARCHAR2,
   p_daytime     DATE,
   p_target      VARCHAR2 DEFAULT 'CREATE'
)
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END InterfaceClassViewIUTrg;

FUNCTION TableExists(
   p_table_name         VARCHAR2,
   p_table_owner        VARCHAR2
)
RETURN BOOLEAN
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END TableExists;

FUNCTION viewExists(
   p_view_name    VARCHAR2,
   p_owner        VARCHAR2
)
RETURN BOOLEAN
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END viewExists;

PROCEDURE ReportClassView(
   p_class_name   VARCHAR2,
   p_daytime      DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
)
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END ReportClassView;

PROCEDURE ReportObjectClassView(
   p_class_name   VARCHAR2,
   p_daytime      DATE,
   p_target       VARCHAR2 DEFAULT 'CREATE'
)
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END ReportObjectClassView;

PROCEDURE ReportDataClassView(
   p_class_name       VARCHAR2,
   p_daytime          DATE,
   p_target           VARCHAR2 DEFAULT 'CREATE'
)
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END ReportDataClassView;

PROCEDURE ReportTableClassView(
   p_class_name   VARCHAR2,
   p_daytime      DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
)
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END ReportTableClassView;

PROCEDURE ReportInterfaceClassView(
   p_class_name   VARCHAR2,
   p_daytime      DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
)
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END ReportInterfaceClassView;

PROCEDURE AddMissingAttributes(p_class_name VARCHAR2)
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END AddMissingAttributes;

PROCEDURE ObjectClassTriggerPackageHead(
   p_class_name  VARCHAR2,
   p_daytime    DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
)
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END ObjectClassTriggerPackageHead;

PROCEDURE ObjectClassTriggerPackageBody(
   p_class_name  VARCHAR2,
   p_daytime    DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
)
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END ObjectClassTriggerPackageBody;

PROCEDURE CreateObjectsView
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END CreateObjectsView;

PROCEDURE CreateObjectsVersionView
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END CreateObjectsVersionView;

PROCEDURE CreateDefermentGroupsView
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END CreateDefermentGroupsView;

PROCEDURE CreateGroupSyncPackage
IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'EcDp_GenClassCode is removed, please use EcDp_ViewLayer instead.');
END CreateGroupSyncPackage;

END EcDp_GenClassCode;