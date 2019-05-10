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
@..\..\configuration\operation_parameters.sql

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
--exec UE_CT_INSTALL_HISTORY.assert_feature_version('&feature_id', NULL, NULL)

--exec UE_CT_INSTALL_HISTORY.entry('&&update_name', to_date('&&release_date', 'DD-MON-YYYY'), '&&description', '&&author')
--exec UE_CT_INSTALL_HISTORY.set_feature('&&feature_id', 'EC Data Quality Tool', 'CVX', to_number('&&major_version'), to_number('&&new_minor_version'), 'Tool for creating and running data quality rules within EC')
exec ECDP_PINC.EnableInstallMode('&&update_name')
WHENEVER SQLERROR CONTINUE;
-------------------------------------------------------------------------------------------------------


------ set assign id

PROMPT Updating Assign ID
---------------

update assign_id
set max_id   = (select max(object_id) from t_basis_object)
where tablename = 'T_BASIS_OBJECT'
and max_id <> (select max(object_id) from t_basis_object);

commit;


-- Tables
PROMPT Updating Data Model
---------------------------------------------
--@.\DataModel\CT_DQ_RULE.sql
--@.\DataModel\CT_DQ_RULE_GROUP.sql
--@.\DataModel\CT_DQ_RULE_GRP_COMBINATION.sql
--@.\DataModel\CT_DQ_HIER_DETERMINATION.sql

PROMPT Updating Data Model Txn Tables

---@.\DataModel\CT_DQ_RULE_RESULT_LOG.sql
--@.\DataModel\CT_DQ_RULE_RESULTS.sql
--@.\DataModel\CT_DQ_RUN_LOG.sql
--@.\DataModel\CT_DQ_RULE_RUN_DETAIL_LOG.sql
--@.\DataModel\CT_DQ_RULE_RUN_LOG.sql


PROMPT Updating Data Model Journal tables
--@.\DataModel\CT_DQ_RULE_JN.sql
--@.\DataModel\CT_DQ_RULE_GROUP_JN.sql
--@.\DataModel\CT_DQ_RULE_GRP_COMBINATION_JN.sql
--@.\DataModel\CT_DQ_RULE_RESULTS_JN.sql

---Views
PROMPT Updating Views
---------------------------------------------
@.\Views\CV_DQ_RULE_GROUP_LOG.sql
---------------------------------------------


---Triggers
PROMPT Updating Triggers
---------------------------------------------
@.\Triggers\IU_CT_DQ_RULE.sql
@.\Triggers\IU_CT_DQ_RULE_GROUP.sql
@.\Triggers\IU_CT_DQ_RULE_GRP_COMBINATION.sql
@.\Triggers\IU_CT_DQ_RULE_RESULTS.sql
@.\Triggers\IU_CT_DQ_RUN_LOG.sql


exec EcDp_Generate.generate('CT_DQ_RULE',EcDp_Generate.JN_TRIGGERS);

exec EcDp_Generate.generate('CT_DQ_RULE_GROUP',EcDp_Generate.JN_TRIGGERS);

exec EcDp_Generate.generate('CT_DQ_RULE_GRP_COMBINATION',EcDp_Generate.JN_TRIGGERS);

exec EcDp_Generate.generate('CT_DQ_RULE_RESULTS',EcDp_Generate.JN_TRIGGERS);

---------------------------------------------



---Misc
PROMPT Updating Misc



@.\Misc\T_BASIS_OBJECT_AND_ACCESS.sql
-- @.\Misc\assign_id.sql
--@.\Misc\ctrl_object.sql
@.\Misc\ec_codes.sql
@.\Misc\error_language_entries.sql
--@.\Misc\attributes.sql

---------------------------------------------




-- Package Updates
PROMPT Deploying Updated Packages
---------------------------------------------
@.\Packages\UE_CT_DQ_RULES_PKG.pks
@.\Packages\UE_CT_DQ_RULES_PKG.pkb


---------------------------------------------



-- Class Updates
PROMPT Performing Class Configuration Updates
---------------------------------------------
@.\Classes\DQ_CLASSES.sql;

EXECUTE ecdp_viewlayer.buildviewlayer('CT_DQ_RULE');
EXECUTE ecdp_viewlayer.buildviewlayer('CT_DQ_RULE_GROUP');
EXECUTE ecdp_viewlayer.buildviewlayer('CT_DQ_RULE_RESULT_LOG');
EXECUTE ecdp_viewlayer.buildviewlayer('CT_DQ_RULE_GRP_COMBO');
EXECUTE ecdp_viewlayer.buildviewlayer('CT_DQ_RULE_RESULTS');
EXECUTE ecdp_viewlayer.buildviewlayer('CT_DQ_RULE_GROUP_LOG');

EXECUTE ecdp_viewlayer.buildviewlayer('CT_DQ_RULE_BY_GROUP');
EXECUTE ecdp_viewlayer.buildviewlayer('CT_DQ_RULE_RUN_LOG');
EXECUTE ecdp_viewlayer.buildviewlayer('CT_DQ_RUN_LOG_PARMS');
EXECUTE ecdp_viewlayer.buildviewlayer('CT_DQ_RULE_RUN_DET_LOG');


EXECUTE ecdp_viewlayer.buildreportlayer( 'CT_DQ_RULE');
EXECUTE ecdp_viewlayer.buildreportlayer( 'CT_DQ_RULE_GROUP');
EXECUTE ecdp_viewlayer.buildreportlayer( 'CT_DQ_RULE_RESULT_LOG');
EXECUTE ecdp_viewlayer.buildreportlayer( 'CT_DQ_RULE_GRP_COMBO');
EXECUTE ecdp_viewlayer.buildreportlayer( 'CT_DQ_RULE_RESULTS');
EXECUTE ecdp_viewlayer.buildreportlayer( 'CT_DQ_RULE_GROUP_LOG');

EXECUTE ecdp_viewlayer.buildreportlayer( 'CT_DQ_RULE_BY_GROUP');
EXECUTE ecdp_viewlayer.buildreportlayer( 'CT_DQ_RULE_RUN_LOG');
EXECUTE ecdp_viewlayer.buildreportlayer( 'CT_DQ_RUN_LOG_PARMS');
EXECUTE ecdp_viewlayer.buildreportlayer( 'CT_DQ_RULE_RUN_DET_LOG');

---------------------------------------------
PROMPT
PROMPT Compiling invalids
PROMPT

@.\Utilities\invalid.sql


--@.\Misc\ec_EXAMPLE_RULES.sql

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