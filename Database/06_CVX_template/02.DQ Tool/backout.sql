DEFINE update_name = 'ECDQ_UPD_001'
------------------------------------------------------------------------------------------------
-- High Performance Data Interface Uninstall Script
--
-- Author: Scott Sugarbaker
-- Date: 01-JUL-2014
-- Purpose: This script will uninstall the entirety of the EC Data Quality feature:
--      * Drops all configuration tables
--      * Drops all packages
--      * Drops all performance tables
--
-- Remember to change "SBU_UPD_XXX" to the title of this update (line 1)
-- Remember to update the details of the UE_CT_INSTALL_HISTORY (line 28)
------------------------------------------------------------------------------------------------
 
-- Boilerplate Header Code
PROMPT Loading Operation Parameters
SET DEFINE ON

@.\Utilities\operation_parameters.sql

@.\Utilities\check_operation_parameters.sql

spool &&operation._&&update_name.-BACKOUT.log

PROMPT
PROMPT Date run: &&_date
PROMPT

PROMPT Connecting to [connect eckernel_&&operation]...
connect eckernel_&&operation/&&ec_schema_password@&&database_name

PROMPT
PROMPT Total Invalids before running updates
PROMPT
@.\utilities\invalid_list.sql

PROMPT
PROMPT Installing backout updates
PROMPT

exec UE_CT_INSTALL_HISTORY.ENTRY('ECDQ-V1-BACKOUT', sysdate, 'PRODUCTION', 'Removing ECDQ', 'Issued by EC Central Support')
exec ECDP_PINC.ENABLEINSTALLMODE('ECDQ-V1-BACKOUT')


delete from tv_system_attribute
where attribute_type in ('CT_DQ_MAX_RULE_RESULTS','CT_DQ_MAX_RULE_DURATION','CT_DQ_MAX_ROWS');


-- Class Configuration Updates
PROMPT Restoring Class Configurations
---------------------------------------------
DELETE FROM CLASS_TRA_PROPERTY_CNFG 
WHERE CLASS_NAME IN ('CT_DQ_RULE','CT_DQ_RULE_GROUP','CT_DQ_RULE_RESULT_LOG','CT_DQ_RULE_GRP_COMBO','CT_DQ_RULE_RESULTS','CT_DQ_RULE_GROUP_LOG','CT_DQ_RULE_BY_GROUP','CT_DQ_RULE_RUN_LOG','CT_DQ_RUN_LOG_PARMS','CT_DQ_RULE_RUN_DET_LOG');

DELETE FROM CLASS_TRIGGER_ACTN_CNFG 
WHERE CLASS_NAME IN ('CT_DQ_RULE','CT_DQ_RULE_GROUP','CT_DQ_RULE_RESULT_LOG','CT_DQ_RULE_GRP_COMBO','CT_DQ_RULE_RESULTS','CT_DQ_RULE_GROUP_LOG','CT_DQ_RULE_BY_GROUP','CT_DQ_RULE_RUN_LOG','CT_DQ_RUN_LOG_PARMS','CT_DQ_RULE_RUN_DET_LOG');

DELETE FROM CLASS_ATTR_PROPERTY_CNFG
WHERE CLASS_NAME IN ('CT_DQ_RULE','CT_DQ_RULE_GROUP','CT_DQ_RULE_RESULT_LOG','CT_DQ_RULE_GRP_COMBO','CT_DQ_RULE_RESULTS','CT_DQ_RULE_GROUP_LOG','CT_DQ_RULE_BY_GROUP','CT_DQ_RULE_RUN_LOG','CT_DQ_RUN_LOG_PARMS','CT_DQ_RULE_RUN_DET_LOG');

DELETE FROM CLASS_ATTRIBUTE_CNFG
WHERE CLASS_NAME IN ('CT_DQ_RULE','CT_DQ_RULE_GROUP','CT_DQ_RULE_RESULT_LOG','CT_DQ_RULE_GRP_COMBO','CT_DQ_RULE_RESULTS','CT_DQ_RULE_GROUP_LOG','CT_DQ_RULE_BY_GROUP','CT_DQ_RULE_RUN_LOG','CT_DQ_RUN_LOG_PARMS','CT_DQ_RULE_RUN_DET_LOG');

DELETE FROM CLASS_PROPERTY_CNFG
WHERE CLASS_NAME IN ('CT_DQ_RULE','CT_DQ_RULE_GROUP','CT_DQ_RULE_RESULT_LOG','CT_DQ_RULE_GRP_COMBO','CT_DQ_RULE_RESULTS','CT_DQ_RULE_GROUP_LOG','CT_DQ_RULE_BY_GROUP','CT_DQ_RULE_RUN_LOG','CT_DQ_RUN_LOG_PARMS','CT_DQ_RULE_RUN_DET_LOG');

DELETE FROM CLASS_CNFG
WHERE CLASS_NAME IN ('CT_DQ_RULE','CT_DQ_RULE_GROUP','CT_DQ_RULE_RESULT_LOG','CT_DQ_RULE_GRP_COMBO','CT_DQ_RULE_RESULTS','CT_DQ_RULE_GROUP_LOG','CT_DQ_RULE_BY_GROUP','CT_DQ_RULE_RUN_LOG','CT_DQ_RUN_LOG_PARMS','CT_DQ_RULE_RUN_DET_LOG');

DROP VIEW TV_CT_DQ_RULE;
DROP VIEW TV_CT_DQ_RULE_GROUP;
DROP VIEW TV_CT_DQ_RULE_RESULT_LOG;
DROP VIEW TV_CT_DQ_RULE_GRP_COMBO;
DROP VIEW TV_CT_DQ_RULE_RESULTS;
DROP VIEW TV_CT_DQ_RULE_GROUP_LOG;
DROP VIEW TV_CT_DQ_RULE_BY_GROUP;
DROP VIEW TV_CT_DQ_RULE_RUN_LOG;
DROP VIEW TV_CT_DQ_RUN_LOG_PARMS;
DROP VIEW TV_CT_DQ_RULE_RUN_DET_LOG;

DROP VIEW RV_CT_DQ_RULE;
DROP VIEW RV_CT_DQ_RULE_GROUP;
DROP VIEW RV_CT_DQ_RULE_RESULT_LOG;
DROP VIEW RV_CT_DQ_RULE_GRP_COMBO;
DROP VIEW RV_CT_DQ_RULE_RESULTS;
DROP VIEW RV_CT_DQ_RULE_GROUP_LOG;
DROP VIEW RV_CT_DQ_RULE_BY_GROUP;
DROP VIEW RV_CT_DQ_RULE_RUN_LOG;
DROP VIEW RV_CT_DQ_RUN_LOG_PARMS;
DROP VIEW RV_CT_DQ_RULE_RUN_DET_LOG;

DROP VIEW TV_CT_DQ_RULE_JN;
DROP VIEW TV_CT_DQ_RULE_GROUP_JN;
DROP VIEW TV_CT_DQ_RULE_GRP_COMBO_JN;
DROP VIEW TV_CT_DQ_RULE_RESULTS_JN;
DROP VIEW TV_CT_DQ_RULE_BY_GROUP_JN;

DROP VIEW CV_DQ_RULE_GROUP_LOG;

-- Package Updates
PROMPT Restoring Original Packages
---------------------------------------------
DROP PACKAGE UE_CT_DQ_RULES_PKG;

---------------------------------------------


-- Misc Configuration Updates
PROMPT Restoring Misc Configurations
---------------------------------------------
DELETE FROM ctrl_object WHERE object_name IN ('CT_DQ_RULE','CT_DQ_RULE_GROUP','CT_DQ_RUN_LOG');

DROP PACKAGE EC_CT_DQ_RULE;
DROP PACKAGE EC_CT_DQ_RULE_GROUP;
DROP PACKAGE EC_CT_DQ_RUN_LOG;

commit;


---DELETE FROM CTRL_PROPERTY_META WHERE KEY = '/com/ec/eccommon/genericmodel/navigator/DQ_FCTY_CLASS_1';

DELETE FROM TV_T_BASIS_ACCESS
WHERE OBJECT_ID IN 
(SELECT OBJECT_ID FROM TV_T_BASIS_OBJECT
WHERE OBJECT_NAME IN (
'/com.ec.cvx.common.screens/ct_dq_rules_group',
'/com.ec.cvx.common.screens/ct_dq_rules_group/RunRules',
'/com.ec.cvx.common.screens/ct_dq_rules',
'/com.ec.cvx.common.screens/ct_dq_create_rule_group',
'/com.ec.cvx.common.screens/ct_dq_rule_result',
'/com.ec.cvx.common.screens/ct_dq_run_rules_log')
);

DELETE FROM TV_T_BASIS_OBJECT WHERE OBJECT_NAME = '/com.ec.cvx.common.screens/ct_dq_rules_group';
DELETE FROM TV_T_BASIS_OBJECT WHERE OBJECT_NAME = '/com.ec.cvx.common.screens/ct_dq_rules_group/RunRules';
DELETE FROM TV_T_BASIS_OBJECT WHERE OBJECT_NAME = '/com.ec.cvx.common.screens/ct_dq_rules';
DELETE FROM TV_T_BASIS_OBJECT WHERE OBJECT_NAME = '/com.ec.cvx.common.screens/ct_dq_create_rule_group';
DELETE FROM TV_T_BASIS_OBJECT WHERE OBJECT_NAME = '/com.ec.cvx.common.screens/ct_dq_rule_result';
DELETE FROM TV_T_BASIS_OBJECT WHERE OBJECT_NAME = '/com.ec.cvx.common.screens/ct_dq_run_rules_log';


DELETE FROM TV_CTRL_TV_PRESENTATION WHERE COMPONENT_ID = 'DQ_RULES';
DELETE FROM TV_CTRL_TV_PRESENTATION WHERE COMPONENT_ID = 'DQ_RULE_GROUP';
DELETE FROM TV_CTRL_TV_PRESENTATION WHERE COMPONENT_ID = 'RUN_DQ_RULES';
DELETE FROM TV_CTRL_TV_PRESENTATION WHERE COMPONENT_ID = 'DQ_RULE_RESULTS';
DELETE FROM TV_CTRL_TV_PRESENTATION WHERE COMPONENT_ID = 'DATA_QUALITY';
DELETE FROM TV_CTRL_TV_PRESENTATION WHERE COMPONENT_ID = 'DQ_RUN_LOG';

DELETE FROM TV_EC_CODE_DEPENDENCY WHERE CODE_TYPE1 = 'CT_DQ_RULE_CATEGORY';

DELETE FROM TV_EC_CODES WHERE CODE_TYPE = 'CT_DQ_RULE_CATEGORY';
DELETE FROM TV_EC_CODES WHERE CODE_TYPE = 'CT_DQ_RULE_SUBCATEGORY';
DELETE FROM TV_EC_CODES WHERE CODE_TYPE = 'CT_DQ_ERROR_TYPE';
DELETE FROM TV_EC_CODES WHERE CODE_TYPE = 'CT_DQ_HIER_OBJ_TYPE';
DELETE FROM TV_EC_CODES WHERE CODE_TYPE = 'CT_DQ_LOGGING_LEVEL';


delete from action_instance_value
where action_instance_no in (select action_instance_no from action_instance
where business_action_no in (SELECT BUSINESS_ACTION_NO FROM TV_BUSINESS_ACTION WHERE NAME = 'RunDQRules')
);

delete from action_instance_history
where action_instance_no in (select action_instance_no from action_instance
where business_action_no in (SELECT BUSINESS_ACTION_NO FROM TV_BUSINESS_ACTION WHERE NAME = 'RunDQRules')
);

delete from action_instance
WHERE BUSINESS_ACTION_NO IN 
(SELECT BUSINESS_ACTION_NO FROM TV_BUSINESS_ACTION WHERE NAME = 'RunDQRules');

DELETE FROM TV_STATIC_ACTION_PARAMETER
WHERE BUSINESS_ACTION_NO IN 
(SELECT BUSINESS_ACTION_NO FROM TV_BUSINESS_ACTION WHERE NAME = 'RunDQRules');

DELETE FROM TV_ACTION_PARAMETER
WHERE BUSINESS_ACTION_NO IN 
(SELECT BUSINESS_ACTION_NO FROM TV_BUSINESS_ACTION WHERE NAME = 'RunDQRules');

DELETE FROM TV_BUSINESS_ACTION WHERE NAME = 'RunDQRules';


delete from tv_language_target
where source_id in (select source_id from tv_language_source where language_id = 1 and source in ('ORA-20910','ORA-20911','ORA-20912','ORA-20913','ORA-20914','ORA-20915','ORA-20916','ORA-20917','ORA-20918','ORA-20919','ORA-20920','ORA-20921','ORA-20922') )
AND language_id = 1
and target IN 
('From Date Source is Required','To Date Source is Required','From Date Source is not allowed for Report Only Rule Groups','To Date Source is not allowed for Report Only Rule Groups',
'Invalid Date Source Function','Invalid Generated Dynamic SQL','Invalid Dynamic SQL: Invalid Column Name','Invalid Dynamic SQL: Column Ambiguously Defined',
'Invalid Dynamic SQL: FROM keyword not found where expected','Invalid Dynamic SQL: SQL not properly ended','Invalid Dynamic SQL: Invalid Table Name',
'Invalid Dynamic SQL: Not a Group By Expression','Invalid Dynamic SQL: Missing Right Parenthesis');


delete from tv_language_source s
where source in ('ORA-20910','ORA-20911','ORA-20912','ORA-20913','ORA-20914','ORA-20915','ORA-20916','ORA-20917','ORA-20918','ORA-20919','ORA-20920','ORA-20921','ORA-20922')
and not exists
(select * from tv_language_target t where s.source_id = t.source_id);


COMMIT;

---------------------------------------------



-- DataModel
PROMPT Dropping Tables/Views
---------------------------------------------

DROP TABLE CT_DQ_RUN_LOG;
DROP TABLE CT_DQ_RULE_RESULTS;
DROP TABLE CT_DQ_RULE_GRP_COMBINATION;
DROP TABLE CT_DQ_RULE_GROUP;
DROP TABLE CT_DQ_RULE;
DROP TABLE CT_DQ_HIER_DETERMINATION;
DROP TABLE CT_DQ_RULE_RUN_DETAIL_LOG;
DROP TABLE CT_DQ_RULE_RUN_LOG;

DROP TABLE CT_DQ_RULE_RESULTS_JN;
DROP TABLE CT_DQ_RULE_GRP_COMBINATION_JN;
DROP TABLE CT_DQ_RULE_GROUP_JN;
DROP TABLE CT_DQ_RULE_JN;

---------------------------------------------
commit;

DELETE FROM ASSIGN_ID WHERE TABLENAME = 'CT_DQ_RULE';

commit;

DELETE FROM ASSIGN_ID WHERE TABLENAME = 'CT_DQ_RULE_GROUP';

commit;

DELETE FROM ASSIGN_ID WHERE TABLENAME = 'CT_DQ_RULE_RESULTS';

commit;

DELETE FROM ASSIGN_ID WHERE TABLENAME = 'CT_DQ_RUN_ID';

commit;


PROMPT
PROMPT Compiling invalids
PROMPT
@.\Utilities\invalid.sql

PROMPT
PROMPT Total Invalids after running updates
PROMPT
@.\utilities\invalid_list.sql

PROMPT Removing Feature Information
DELETE FROM CT_EC_INSTALLED_FEATURES WHERE FEATURE_ID = 'ECDQ';
COMMIT;

------------------------------------------------------------------------------------------------
-- Boilerplate Footer Code: Do Not Alter Anything Below This Line
PROMPT Updating Grants
@.\Utilities\create_missing_grants.sql

exec ECDP_PINC.DISABLEINSTALLMODE

disconnect

PROMPT Connecting to [connect energyx_&&operation@&&database_name]...
connect energyx_&&operation/&&ec_energy_password@&&database_name
PROMPT Creating private synonym script for energyx.
@.\Utilities\sync_private_synonyms.sql
disconnect


spool off
exit;