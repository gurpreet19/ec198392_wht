-- load standard variables, plus any additional variables that have been defined.
@std_variables.sql

DEFINE update_name = '&&buildID'
DEFINE feature_id = '&&feature_id'
DEFINE major_version = '&&majorVersion'
DEFINE new_minor_version = '&&minorVersion'
DEFINE release_date = '&&release_date' -- DD-MON-YYYY format
DEFINE description = 'BACKOUT: &context_code Template Update &major_version..&new_minor_version'
DEFINE author = 'EC Central Support'

-- If this will install a brand new feature, update the 'set_feature' procedure on line #34 to include the
-- feature name, context code, and description.

PROMPT ________________________________________________________________________________________________
PROMPT -- TITLE: &buildID
PROMPT --
PROMPT -- Author: &author
PROMPT -- Date: &release_date
PROMPT -- Purpose: &description
PROMPT ________________________________________________________________________________________________
 
-------------------------------------------------------------------------------------------------------
-- Boilerplate Header Code
PROMPT Loading Operation Parameters
SET DEFINE ON

@.\_Release\utilities\operation_parameters.sql
PROMPT
PROMPT Date run: &&_date
PROMPT
PROMPT Connecting to [eckernel_&&operation@&&database_name]...
connect eckernel_&&operation/"&&ec_schema_password"@&&database_name

-- ec_upd_parameters.sql is populated with additional parameters required by the scripts (if needed).
--@ec_upd_parameters.sql
@.\_Release\utilities\check_operation_parameters.sql

spool &&database_name._&&operation._ec_backout_&&buildID..log

@.\_Release\utilities\invalid_list.sql

PROMPT
PROMPT Installing updates
PROMPT
-------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------
-- Version updates and version checks
WHENEVER SQLERROR EXIT;
-- Uncomment this line to perform a check against a feature version. You may copy/paste as necessary
 --exec UE_CT_INSTALL_HISTORY.assert_feature_version('&feature_id', to_number('&major_version'), to_number('&new_minor_version'), '=')

exec UE_CT_INSTALL_HISTORY.entry('&update_name', to_date('&release_date', 'DD-MON-YYYY'), '&description', '&author')
exec UE_CT_INSTALL_HISTORY.set_feature('&feature_id', NULL, NULL, to_number('&major_version'), to_number('&new_minor_version') - 1)
exec ECDP_PINC.EnableInstallMode('&update_name')
WHENEVER SQLERROR CONTINUE;
-------------------------------------------------------------------------------------------------------
