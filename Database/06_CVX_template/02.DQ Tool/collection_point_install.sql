DEFINE update_name = 'ECDQ_CP_001'
DEFINE feature_id = 'ECDQ'
DEFINE major_version = '1'
DEFINE new_minor_version = '0'
DEFINE release_date = '01-JUL-2014' -- DD-MON-YYYY format
DEFINE description = 'Installs ECDQ collection point config'
DEFINE author = 'EC Central Support'
-- If this will install a brand new feature, update the 'set_feature' procedure on line #34 to include the
-- feature name, context code, and description.

PROMPT ------------------------------------------------------------------------------------------------
PROMPT -- EC Data Quality Tool v1.0
PROMPT --
PROMPT -- Author: Scott Sugarbaker
PROMPT -- Date:    01 - JUL - 2014
PROMPT -- Purpose: To add the collection point set-up for DQ tool
PROMPT ------------------------------------------------------------------------------------------------
 
-------------------------------------------------------------------------------------------------------
-- Boilerplate Header Code
PROMPT Loading Operation Parameters
SET DEFINE ON
@..\..\..\operation_parameters.sql

@.\Utilities\check_operation_parameters.sql

spool &&operation._&&update_name..log

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
PROMPT Installing updates
PROMPT
-------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------
-- Version updates and version checks
WHENEVER SQLERROR EXIT;
-- Uncomment this line to perform a check against a feature version. You may copy/paste as necessary
exec UE_CT_INSTALL_HISTORY.assert_feature_version('&feature_id', 1, NULL)

--exec UE_CT_INSTALL_HISTORY.entry('&&update_name', to_date('&&release_date', 'DD-MON-YYYY'), '&&description', '&&author')
--exec UE_CT_INSTALL_HISTORY.set_feature('&&feature_id', 'EC Data Quality Tool', 'CVX', to_number('&&major_version'), to_number('&&new_minor_version'), 'Tool for creating and running data quality rules within EC')
exec ECDP_PINC.EnableInstallMode('&&update_name')
WHENEVER SQLERROR CONTINUE;
-------------------------------------------------------------------------------------------------------

---Misc
PROMPT Updating Misc
---------------------------------------------
@.\CollectionPointUpdate\ec_code_collection_point_updates.sql


--------------------------------------------
@.\CollectionPointUpdate\dq_classes_col_point.sql

execute EcDp_Viewlayer.BuildViewLayer('CT_DQ_RULE_RESULTS');
execute EcDp_Viewlayer.BuildReportLayer('CT_DQ_RULE_RESULTS');

---------------------------------------------
PROMPT
PROMPT Compiling invalids
PROMPT

@.\Utilities\invalid.sql


PROMPT
PROMPT Total Invalids after running updates
PROMPT
@.\utilities\invalid_list.sql

PROMPT Updating Grants
@.\Utilities\create_missing_grants.sql

PROMPT Connecting to [connect energyx_&&operation@&&database_name]...
connect energyx_&&operation/&&ec_energyx_password@&&database_name
PROMPT Creating private synonym script for energyx.
@.\Utilities\sync_private_synonyms.sql
disconnect


spool off
exit;