DEFINE update_name = 'ECDQ_UPD_001'
DEFINE feature_id = 'ECDQ'
DEFINE major_version = '1'
DEFINE new_minor_version = '0'
DEFINE release_date = '01-JUL-2014' -- DD-MON-YYYY format
DEFINE description = 'Installs ECDQ version 1.0'
DEFINE author = 'EC Central Support'
-- If this will install a brand new feature, update the 'set_feature' procedure on line #34 to include the
-- feature name, context code, and description.

PROMPT ------------------------------------------------------------------------------------------------
PROMPT -- EC Data Quality Tool v1.0
PROMPT --
PROMPT -- Author: Scott Sugarbaker
PROMPT -- Date:    01 - JUL - 2014
PROMPT -- Purpose: To provide a tool to define and execute data quality rules
PROMPT ------------------------------------------------------------------------------------------------
 
-------------------------------------------------------------------------------------------------------
-- Boilerplate Header Code
PROMPT Loading Operation Parameters
SET DEFINE ON
@.\Utilities\operation_parameters.sql

@.\Utilities\check_operation_parameters.sql

spool &&database_name._&&operation._&&update_name..log

PROMPT
PROMPT Date run: &&_date
PROMPT

PROMPT Connecting to [eckernel_&&operation@&&database_name]...
connect eckernel_&&operation/&&ec_schema_password@&&database_name

PROMPT
PROMPT Total Invalids before running updates
PROMPT
@.\utilities\invalid_list.sql



PROMPT
PROMPT Compiling invalids
PROMPT

@.\Utilities\invalid.sql


@.\Misc\ec_EXAMPLE_RULES.sql

PROMPT
PROMPT Total Invalids after running updates
PROMPT
@.\utilities\invalid_list.sql

PROMPT Updating Grants
@.\Utilities\create_missing_grants.sql

PROMPT Connecting to [connect energyx_&&operation@&&database_name]...
connect energyx_&&operation/&&ec_application_password@&&database_name
PROMPT Creating private synonym script for energyx.
@.\Utilities\sync_private_synonyms.sql
disconnect


spool off
exit;