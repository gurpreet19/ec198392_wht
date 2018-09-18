CREATE OR REPLACE PACKAGE EcDp_GenClassCode IS
/****************************************************************
** Package        :  EcDp_GenClassCode, header part
**
** $Revision: 1.33 $
**
** Purpose        :  Generate Views, instead of triggers and class methods based on class definitions.
**
** Documentation  :  www.energy-components.com
**
** Created  : 01.01.2003  Henning Stokke
**
** Modification history:
**
** Date     Whom  Change description:
** ------   ----- --------------------------------------
** 19.03.03 AV    Merged development versions
** 26.03.03 AV    Removed procedure xxxIUTrg
** 09.05.03 DN    Postponed the class_method logic until a later release.
** 13.05.03 AV    Corrected spelling mistakes
** 14.05.03 AV    Added new procedure BuildTableViews
** 09.12.03 SHN   Added function ObjectSubClassViewIUTrg
** 12.01.04 SHN   Added function TableExists
** 26.05.04 SHN   Added function InterfaceClassViewIUTrg
** 07.06.04 SHN   Added functions ReportClassView,ReportDataClassView,ReportObjectClassView and BuildReportLayer.
** 08.10.04 SHN   Added function BuildView.
** 15.10.04 AV    Added new default parameter p_sql2 to SafeBuild
** 27.10.04 AV    Add procedure RecompileInvalidViewLayer
** 28.10.04 AV    Added procedure AddMissingAttributes
** 01.03.05 AV    New Consept for object storage
** 28.04.05 AV    Added new procedure CreateGroupSyncPackage
** 19.08.05 DN    TI2526 and TI2375: Added viewExists function.
** 09.11.05 AV    TI2591 Removed procedure WriteTempText, keeping version in EcDpDynsql
** 03.03.06 DN    TI 3569: Added default p_id parameter to SafeBuild procedure.
** 08.06.06 AV    TI 3823: Added ReportDataClassMthView to handle month RV views different from the rest.
** 05.03.18 ZHO   Removed all the functionalities, now only issue exception about the transition information to ECDP_VIEWLAYER
*****************************************************************/

--
-- To Be Removed PACKAGE
--
-- All functions and procedures in EcDp_GenClassCode will be removed.
--
-- Please use the ecdp_viewlayer package instead.
--

FUNCTION getCurrentPackageRevision RETURN VARCHAR2;



PROCEDURE SafeBuild(p_object_name VARCHAR2,
                    p_object_type VARCHAR2,
                    p_sql         CLOB,
                    p_target      VARCHAR2 DEFAULT 'CREATE',
                    p_sql2        VARCHAR2 DEFAULT '',
                    p_id          VARCHAR2 DEFAULT 'GENCODE'
);


FUNCTION getDataclassJoinDaytime(
   p_class_name   		VARCHAR2
)
RETURN VARCHAR2
;


PROCEDURE ObjectClassView(
   p_class_name  VARCHAR2,
   p_daytime    DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
);

PROCEDURE ObjectClassJNView(
   p_class_name  VARCHAR2,
   p_daytime    DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
);


PROCEDURE InterfaceClassView(
   p_class_name  VARCHAR2,
   p_daytime    DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
);


PROCEDURE TableClassView(
   p_class_name  VARCHAR2,
   p_daytime    DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
);

PROCEDURE TableClassJNView(
   p_class_name  VARCHAR2,
   p_daytime    DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
);


PROCEDURE DataClassView(
   p_class_name  VARCHAR2,
   p_daytime    DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
);

PROCEDURE DataClassJNView(
   p_class_name  VARCHAR2,
   p_daytime    DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
);


PROCEDURE ObjectClassViewIUTrg(
   p_class_name  VARCHAR2,
   p_daytime    DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
);


PROCEDURE TableClassViewIUTrg(
   p_class_name  VARCHAR2,
   p_daytime    DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
);



PROCEDURE DataClassViewIUTrg(
   p_class_name  VARCHAR2,
   p_daytime    DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
);

PROCEDURE BuildView(
				p_class_name				VARCHAR2,
				p_target					VARCHAR2 DEFAULT 'CREATE');

PROCEDURE BuildViewAutonomous(
				p_class_name				VARCHAR2,
				p_target					VARCHAR2 DEFAULT 'CREATE');


PROCEDURE RecompileInvalidViewLayer;


PROCEDURE BuildViewLayer(
          p_target           VARCHAR2 DEFAULT 'CREATE',
          p_class_name       VARCHAR2 DEFAULT NULL,
          p_app_space_code	 VARCHAR2 DEFAULT NULL,
          p_ignore_error_ind VARCHAR2 DEFAULT 'N',    -- used in to not raise error in some build cases
          p_no_refresh       VARCHAR2 DEFAULT 'N'    -- used to not refresh materialized views
);

PROCEDURE BuildViewLayerAutonomous(
          p_target           VARCHAR2 DEFAULT 'CREATE',
          p_class_name       VARCHAR2 DEFAULT NULL,
          p_app_space_code	 VARCHAR2 DEFAULT NULL,
          p_ignore_error_ind VARCHAR2 DEFAULT 'N'    -- used in to not raise error in some build cases
);

PROCEDURE BuildTableViews(p_target VARCHAR2 DEFAULT 'CREATE');

PROCEDURE BuildReportLayer(p_target VARCHAR2 DEFAULT 'CREATE',
                           p_class_name  VARCHAR2 DEFAULT NULL,
                           p_app_space_code	VARCHAR2 DEFAULT NULL,
						   p_no_refresh       VARCHAR2 DEFAULT 'N');    -- used to not refresh materialized views

PROCEDURE BuildReportLayerAutonomous(p_target VARCHAR2 DEFAULT 'CREATE',
                           p_class_name  VARCHAR2 DEFAULT NULL,
                           p_app_space_code	VARCHAR2 DEFAULT NULL,
						   p_no_refresh       VARCHAR2 DEFAULT 'N');    -- used to not refresh materialized views


PROCEDURE InterfaceClassViewIUTrg(
   p_class_name  VARCHAR2,
   p_daytime     DATE,
   p_target      VARCHAR2 DEFAULT 'CREATE'
);

FUNCTION TableExists(
   p_table_name         VARCHAR2,
   p_table_owner        VARCHAR2
) RETURN BOOLEAN;

FUNCTION viewExists(
   p_view_name    VARCHAR2,
   p_owner        VARCHAR2
)
RETURN BOOLEAN;

PROCEDURE ReportClassView(
   p_class_name   VARCHAR2,
   p_daytime      DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
);

PROCEDURE ReportObjectClassView(
   p_class_name   VARCHAR2,
   p_daytime      DATE,
   p_target       VARCHAR2 DEFAULT 'CREATE'
);

PROCEDURE ReportDataClassView(
   p_class_name   		VARCHAR2,
   p_daytime      		DATE,
   p_target       		VARCHAR2 DEFAULT 'CREATE'
);



PROCEDURE ReportTableClassView(
   p_class_name   VARCHAR2,
   p_daytime      DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
);

PROCEDURE ReportInterfaceClassView(
   p_class_name   VARCHAR2,
   p_daytime      DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
);


PROCEDURE AddMissingAttributes(p_class_name VARCHAR2);

PROCEDURE ObjectClassTriggerPackageHead(
   p_class_name  VARCHAR2,
   p_daytime    DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
);


PROCEDURE ObjectClassTriggerPackageBody(
   p_class_name  VARCHAR2,
   p_daytime    DATE,
   p_target VARCHAR2 DEFAULT 'CREATE'
);


PROCEDURE CreateObjectsView;

PROCEDURE CreateObjectsVersionView;

PROCEDURE CreateDefermentGroupsView;

PROCEDURE CreateGroupSyncPackage;

END EcDp_GenClassCode;