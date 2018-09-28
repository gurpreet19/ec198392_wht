/**************************************************************
** SQL    :          CVX_LOAD_TEMPLATE
**
** Revision:         Version 11.2

** Purpose:        Main load file for the GENERAL CVX Template.  This file will call all
**                the other sql files to load the template. The cvx Custom Development will be called
**                separately.
**
** Modification history: 
**
**Version    Date                Whom      		                    Change description:
** -------  ------              -----------------                   --------------------------------
** 11.1     CVX103_05242012 	Chase Caillet/Benjamin Segura
** 11.2     29-Jan-2018          Gayatri Kulkarni                   Defining major_version as 11.2 
** 11.2		29-Jan-2018			 Gayatri Kulkarni					Modified filename to Install-EC_CVX_11_2
**************************************************************/

DEFINE update_name = 'CVX_TEMPLATE'
DEFINE feature_id = 'CVX_TEMPLATE'
DEFINE major_version = '11.2'
DEFINE new_minor_version = '0'
DEFINE release_date = '09-FEB-2018' -- DD-MON-YYYY format
DEFINE description = 'CVX Template Release &major_version..&new_minor_version'
DEFINE author = 'EC Central Support'


PROMPT Loading Operation Parameters
@..\configuration\operation_parameters.sql

PROMPT Connecting to [connect eckernel_&operation/&ec_schema_password@&database_name]...
connect eckernel_&operation/&ec_schema_password@&database_name

spool cvx_tmpl_instl.log

-- Version updates and version checks
WHENEVER SQLERROR EXIT;
-- Uncomment this line to perform a check against a feature version. You may copy/paste as necessary

exec UE_CT_INSTALL_HISTORY.entry('&update_name', to_date('&release_date', 'DD-MON-YYYY'), '&description', '&author')
--exec UE_CT_INSTALL_HISTORY.set_feature('&feature_id', NULL, NULL, to_number('&major_version'), to_number('&new_minor_version'))
exec UE_CT_INSTALL_HISTORY.set_feature('&feature_id','&feature_id' , 'CVX', to_number('&major_version'), to_number('&new_minor_version'))
exec ECDP_PINC.EnableInstallMode('&update_name')
COMMIT;
WHENEVER SQLERROR CONTINUE;

PROMPT executing [CVX_LOAD_TEMPLATE]...

-- installing GENCLASSCODE fix before buildviewlayer is created 
-- NO LONGER REQUIRED, PRODUCT FIX SOLVES ISSUE
--@.\_Release\Packages\ECDP_GENCLASSCODE.pkb;
PROMPT LOADING DATAMODEL...
@.\_Release\cvx_load_datamodel.sql;

PROMPT LOADING METADATA...
@.\_Release\cvx_load_meta_data.sql;

PROMPT LOADING MASTER DATA...
@.\_Release\cvx_load_master_data.sql;

PROMPT LOADING PACKAGES ...
@.\_Release\cvx_load_packages.sql;

PROMPT LOADING VIEWS ...
@.\_Release\cvx_load_views.sql;

PROMPT LOADING TRIGGERS ...
@.\_Release\cvx_load_triggers.sql;

PROMPT LOADING Generate all classes...
EXECUTE ecdp_viewlayer.buildviewlayer(p_force => 'Y'); 
EXECUTE ecdp_viewlayer.buildreportlayer(p_force => 'Y');

PROMPT Creating grant script.
@.\_Release\utilities\create_missing_grants.sql;

PROMPT LOADING CALC RULES...
@.\_Release\cvx_load_calculation.sql;

PROMPT REFRESHING ACL...
EXECUTE ecdp_acl.refreshAll;

PROMPT compiling DB objects
execute dbms_utility.compile_schema(USER,FALSE);

disconnect
spool off

PROMPT Connecting to [connect energyx_&operation/&ec_application_password@&database_name]...
connect energyx_&operation/&ec_application_password@&database_name
PROMPT Creating private synonym script for energyx.
@.\_Release\utilities\sync_private_synonyms.sql  
disconnect

PROMPT Connecting to [connect Reporting_&operation@&database_name]...
connect Reporting_&operation/&ec_reporting_password@&database_name
PROMPT Creating private synonym script for reporting.
@.\_Release\utilities\sync_private_synonyms.sql
disconnect

PROMPT Connecting to [connect Transfer_&operation@&database_name]...
connect Transfer_&operation/&ec_transfer_password@&database_name
PROMPT Creating private synonym script for transfer.
@.\_Release\utilities\sync_private_synonyms.sql
disconnect

PROMPT Connecting to [connect eckernel_&operation/&ec_schema_password@&database_name]...
connect eckernel_&operation/&ec_schema_password@&database_name
