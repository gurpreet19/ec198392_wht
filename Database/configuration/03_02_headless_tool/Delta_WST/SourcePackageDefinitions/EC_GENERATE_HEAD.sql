CREATE OR REPLACE PACKAGE ec_generate IS
/**************************************************************
** Package :               ec_generate, header part
**
** Revision :              $Revision: 1.11 $
**
** Purpose :               code generation for ec packages
**
** Documentation :         www.energy-components.no
**
** Created :               03.02.00 Marius Forn�
**
** Modification history:
**
** Date:    Whom: Change description:
** -------- ----- --------------------------------------------
** 23.02.00  UMF   Period-functions -> Math-functions.
**                 Math functions generated for all tables in ctrl_object with math = 'Y'
**
** 20.03.00  UMF   Added support for alias name for columns with long names.
** 16.06.00	 MAO	 Added procedures for making dummy functions for net_vol, net_mass, grs_vol, grs_mass
**						 in the generateDerivedStreams-procedure.
** 15.03.01  DN    Added procedures for generating journal reporting layer.
** 02.07.02  HNE   Added copyData and generateSystemDaysRows
** 30.08.02  DN    Established journal trigger generation procedure after moving it from the old generate-package.
**                 Added table name as default parameter.
** 18.09.02  DN    Added getAttributeParentTable.
** 07.10.02  DN    Moved copyData and generateSystemDaysRows to new package ec_generate_data.
**                 Moved generateDerivedStreams to new package ec_generate_stream.
** 07.03.05  DN    Removed journalReportLayer and sub-procedures.
** 08.03.05  DN    Added new procedure basicIUTriggers.
** 11.03.05  DN    Added new default parameter to generatePackages.
** 22.04.05  AV    Added procedure CreatePINCTriggers to generate after triggers for logging to PINC table during Installmode
** 22.04.05  CGR   Using correct EcDp_PInC.logTableContent() method in procedure CreatePINCTriggers.
** 22.04.05  CGR   Corrected BLOB handeling in  EcDp_PInC.logTableContent().
** 21.02.06  DN    Added p_missing_ind parameter to the journalTriggers procedure.
** 02.03.06  DN    Extended the journalTriggers procedure with immediate build option.
** 08.03.06  AV    Extended the EC_package and Triggers procedure with immediate build option.
***********************************************************************************************/

FUNCTION getAttributeParentTable(p_table VARCHAR2)
RETURN VARCHAR2;


FUNCTION column_exist(
	p_table VARCHAR2,
	p_column VARCHAR2) RETURN NUMBER ;

FUNCTION get_pk_param_list(
				p_table VARCHAR2
				,p_delimiter VARCHAR2
            ,p_except_cols VARCHAR2 DEFAULT NULL
				,p_param_prefix VARCHAR2 DEFAULT 'p_'
				,p_param_postfix VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 ;

FUNCTION get_pk_where_clause(
				p_table VARCHAR2
				,p_delimiter VARCHAR2
            ,p_except_cols VARCHAR2 DEFAULT NULL
				,p_table_alias VARCHAR2 DEFAULT NULL
				,p_param_prefix VARCHAR2 DEFAULT 'p_'
				,p_param_postfix VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 ;


FUNCTION get_table_colums(p_table         VARCHAR2
                          ,p_delimiter    VARCHAR2
                          ,p_except_cols  VARCHAR2 DEFAULT NULL
                          ,p_trunc_length NUMBER   DEFAULT 30)
RETURN VARCHAR2;

FUNCTION table_exist(p_table_name VARCHAR2) RETURN BOOLEAN;

FUNCTION has_table_constraint(p_table_name VARCHAR2, p_constraint_type VARCHAR2) RETURN BOOLEAN;

PROCEDURE initiate(p_append VARCHAR2) ;

PROCEDURE writePackageBody(p_object_name        VARCHAR2,
                           p_view_pk_table_name VARCHAR2,
                           p_target VARCHAR2 DEFAULT 'CREATE'
                           );

PROCEDURE writePackageHeader(p_object_name        VARCHAR2,
                             p_view_pk_table_name VARCHAR2,
                             p_target VARCHAR2 DEFAULT 'CREATE'
);

PROCEDURE writePackageViews(p_object_name        VARCHAR2,
                            p_view_pk_table_name VARCHAR2,
                            p_target VARCHAR2 DEFAULT 'CREATE'
                            );

PROCEDURE basicIUTriggers(p_table_name VARCHAR2 DEFAULT NULL, p_missing_ind VARCHAR2 DEFAULT NULL, p_target VARCHAR2 DEFAULT 'CREATE');

PROCEDURE basicAUTTriggers(p_table_name VARCHAR2 DEFAULT NULL, p_missing_ind VARCHAR2 DEFAULT NULL, p_target VARCHAR2 DEFAULT 'CREATE');

PROCEDURE basicAIUDTTriggers(p_table_name VARCHAR2 DEFAULT NULL, p_missing_ind VARCHAR2 DEFAULT NULL, p_target VARCHAR2 DEFAULT 'CREATE');

PROCEDURE journalTriggers(p_table_name VARCHAR2 DEFAULT NULL, p_missing_ind VARCHAR2 DEFAULT NULL, p_target VARCHAR2 DEFAULT 'CREATE');


PROCEDURE generatePackages(p_table  VARCHAR2, p_append VARCHAR2 DEFAULT NULL, p_missing_ind VARCHAR2 DEFAULT NULL, p_target VARCHAR2 DEFAULT 'CREATE');

FUNCTION getFunctionName(p_table  VARCHAR2,
                         p_column VARCHAR2) RETURN VARCHAR2;


PROCEDURE CreatePINCTriggers(p_table_name VARCHAR2 DEFAULT NULL, p_missing_ind VARCHAR2 DEFAULT NULL);

PROCEDURE IURTriggers(p_table_name VARCHAR2 DEFAULT NULL, p_missing_ind VARCHAR2 DEFAULT NULL, p_target VARCHAR2 DEFAULT 'CREATE');

PROCEDURE generateJnIndex(p_table VARCHAR2 DEFAULT '%');

PROCEDURE SyncObjectGroups(p_object_id VARCHAR2);
PROCEDURE SyncGroups(p_class_name VARCHAR2 DEFAULT NULL, p_object_id VARCHAR2 DEFAULT NULL);
PROCEDURE Synchronise(p_class_name VARCHAR2 DEFAULT NULL, p_object_id VARCHAR2 DEFAULT NULL);

PROCEDURE iudObject(p_class_name VARCHAR2, p_old_object_id VARCHAR2, p_new_object_id VARCHAR2, p_code VARCHAR2, p_start_date DATE, p_end_date DATE, p_created_by VARCHAR2, p_created_date DATE, p_insert BOOLEAN DEFAULT TRUE);

PROCEDURE iudObjectVersion(p_class_name VARCHAR2, p_old_object_id VARCHAR2, p_new_object_id VARCHAR2, p_name VARCHAR2, p_daytime DATE, p_end_date DATE, p_created_by VARCHAR2, p_created_date DATE, p_insert BOOLEAN DEFAULT TRUE);

END ec_generate;