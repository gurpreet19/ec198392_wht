/**************************************************************
** SQL    :       CVX_LOAD_TEMPLATE
**
** Revision:      Version 11.2
**
** Purpose:       Main load file for the GENERAL CVX Template.  This file will call all
**                the other sql files to load the template. The cvx Custom Development will be called
**                separately.
**
** Modification history: 
**
** Version    Date                Whom      		                    Change description:
** -------  ------              -----------------                   --------------------------------
** 11.1     CVX103_05242012 	Chase Caillet/Benjamin Segura
** 11.2     29-Jan-2018          Gayatri Kulkarni                   Passing the parameters as 11.2 for execution of UE_CT_INSTALL_HISTORY
** 11.2		29-Jan-2018			 Gayatri Kulkarni					Modified filename to Pre-Install-EC_CVX_11_2
**
**General Logic and load order:
**************************************************************/

PROMPT Loading Operation Parameters
@..\configuration\operation_parameters.sql

PROMPT Connecting to [connect eckernel_&operation/&ec_schema_password@&database_name]...
connect eckernel_&operation/&ec_schema_password@&database_name

spool cvx_tmpl_pre_instl.log

PROMPT executing [CVX_LOAD_PRE_TEMPLATE]...

PROMPT LOADING DATAMODEL...
START .\_Release\DataModel\CT_EC_INSTALL_HISTORY.sql;
START .\_Release\DataModel\CT_EC_INSTALLED_FEATURES.sql;
exec UE_CT_INSTALL_HISTORY.entry('Backout previous template',sysdate,'Template','Tieto') 
          
PROMPT LOADING METADATA...
@.\_Release\Config\cvx_tmpl_instl_ct_hist_metadata.sql;

---------------------------------------------
PROMPT INSTALLING HISTORY PACKAGE ...
---------------------------------------------
START .\_Release\Packages\UE_CT_INSTALL_HISTORY.pks;
START .\_Release\Packages\UE_CT_INSTALL_HISTORY.pkb;

exec UE_CT_INSTALL_HISTORY.entry('11.2 CVX History Configs',sysdate,'History Configs','Central Support')
COMMIT;

PROMPT Creating grant script.
@.\_Release\utilities\create_missing_grants.sql;

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
