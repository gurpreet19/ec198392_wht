-- load standard variables, plus any additional variables that have been defined.
@std_variables.sql

DEFINE update_name = '&&buildID'
DEFINE major_version = '&&majorVersion'
DEFINE new_minor_version = '&&minorVersion'
DEFINE release_date = '09-NOV-2011' -- DD-MON-YYYY format
DEFINE description = 'Backout for SP## Updates &major_version..&new_minor_version'
DEFINE author = 'EC Central Support'



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

spool &&database_name._&&operation._backout_&&buildID..log

@.\_Release\utilities\invalid_list.sql

PROMPT
PROMPT Installing updates
PROMPT
-------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------
-- Version updates and version checks
WHENEVER SQLERROR EXIT;
exec UE_CT_INSTALL_HISTORY.entry('&update_name', to_date('&release_date', 'DD-MON-YYYY'), '&description', '&author')
exec ECDP_PINC.EnableInstallMode('&update_name')
WHENEVER SQLERROR CONTINUE;
-------------------------------------------------------------------------------------------------------
