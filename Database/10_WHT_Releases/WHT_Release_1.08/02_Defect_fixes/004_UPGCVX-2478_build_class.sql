-- Script to rebuild a class
-----------------------------
-- Owner classes under object partitioning
update viewlayer_dirty_log set dirty_ind='Y' where object_name in ('BUSINESS_UNIT','CALCULATION','COMMERCIAL_ENTITY','CONTRACT_GROUP','MESSAGE_DEFINITION','SUB_AREA');
-- Classes which has owner classes that are under object partitioning
update viewlayer_dirty_log set dirty_ind='Y' where object_name in ('MESSAGE_OUT','MESSAGE_OUT_REMARK','MESSAGE_WORKFLOW_ALERT','MOM_MESSAGE_OUT','MSG_FREE_TEXT_SUBJECT','MSG_FREE_TEXT_TEMPLATE',
'CALC_EQUATION','CALC_LOG_PRFL_PARAM_OVRD','CALC_LOG_PROFILE_OVRD','CALC_SET','CALC_SET_ALL','CALC_SET_COMBINATION','CALC_SET_CONDITION','CALC_SET_EQUATION','CALC_SET_INHERITED','CALC_STATIC_PARAMETER',
'CALC_VARIABLE_LOCAL','CALC_VAR_ALL','CALC_VAR_INHERITED','MESSAGE_DISTRIBUTION','MESSAGE_FORMAT','COENT_DAY_CPY_EQTY_DATA','REPORT_MSG_DISTRIBUTION',
'FCST_SUB_AREA_DAY_STATUS','FCST_SUB_AREA_MTH_STATUS','EQUITY_SHARE','CONTRACT_GROUP_LIST','TRBU_DAY_COMMENT',
'TRBU_DAY_SUMMARY','DATASET_FLOW_REPORT_DIST','CT_MHM_MSG');

commit;
-- Rebuild classes under object partitioning
execute ecdp_viewlayer.BuildViewLayer('BUSINESS_UNIT');
execute ecdp_viewlayer.BuildReportLayer('BUSINESS_UNIT');
execute ecdp_viewlayer.BuildViewLayer('CALCULATION');
execute ecdp_viewlayer.BuildReportLayer('CALCULATION');
execute ecdp_viewlayer.BuildViewLayer('COMMERCIAL_ENTITY');
execute ecdp_viewlayer.BuildReportLayer('COMMERCIAL_ENTITY');
execute ecdp_viewlayer.BuildViewLayer('CONTRACT_GROUP');
execute ecdp_viewlayer.BuildReportLayer('CONTRACT_GROUP');
execute ecdp_viewlayer.BuildViewLayer('MESSAGE_DEFINITION');
execute ecdp_viewlayer.BuildReportLayer('MESSAGE_DEFINITION');
execute ecdp_viewlayer.BuildViewLayer('SUB_AREA');
execute ecdp_viewlayer.BuildReportLayer('SUB_AREA');
-- rebuild classes which has owner classes that are under object partitioning
-- rebuild DV views
execute ecdp_viewlayer.BuildViewLayer('MESSAGE_OUT');
execute ecdp_viewlayer.BuildViewLayer('MESSAGE_OUT_REMARK');
execute ecdp_viewlayer.BuildViewLayer('MESSAGE_WORKFLOW_ALERT');
execute ecdp_viewlayer.BuildViewLayer('MOM_MESSAGE_OUT');
execute ecdp_viewlayer.BuildViewLayer('MSG_FREE_TEXT_SUBJECT');
execute ecdp_viewlayer.BuildViewLayer('MSG_FREE_TEXT_TEMPLATE');
execute ecdp_viewlayer.BuildViewLayer('CALC_EQUATION');
execute ecdp_viewlayer.BuildViewLayer('CALC_LOG_PRFL_PARAM_OVRD');
execute ecdp_viewlayer.BuildViewLayer('CALC_LOG_PROFILE_OVRD');
execute ecdp_viewlayer.BuildViewLayer('CALC_SET');
execute ecdp_viewlayer.BuildViewLayer('CALC_SET_ALL');
execute ecdp_viewlayer.BuildViewLayer('CALC_SET_COMBINATION');
execute ecdp_viewlayer.BuildViewLayer('CALC_SET_CONDITION');
execute ecdp_viewlayer.BuildViewLayer('CALC_SET_EQUATION');
execute ecdp_viewlayer.BuildViewLayer('CALC_SET_INHERITED');
execute ecdp_viewlayer.BuildViewLayer('CALC_STATIC_PARAMETER');
execute ecdp_viewlayer.BuildViewLayer('CALC_VARIABLE_LOCAL');
execute ecdp_viewlayer.BuildViewLayer('CALC_VAR_ALL');
execute ecdp_viewlayer.BuildViewLayer('CALC_VAR_INHERITED');
execute ecdp_viewlayer.BuildViewLayer('MESSAGE_DISTRIBUTION');
execute ecdp_viewlayer.BuildViewLayer('MESSAGE_FORMAT');
execute ecdp_viewlayer.BuildViewLayer('COENT_DAY_CPY_EQTY_DATA');
execute ecdp_viewlayer.BuildViewLayer('REPORT_MSG_DISTRIBUTION');
execute ecdp_viewlayer.BuildViewLayer('FCST_SUB_AREA_DAY_STATUS');
execute ecdp_viewlayer.BuildViewLayer('FCST_SUB_AREA_MTH_STATUS');
execute ecdp_viewlayer.BuildViewLayer('EQUITY_SHARE');
execute ecdp_viewlayer.BuildViewLayer('CONTRACT_GROUP_LIST');
execute ecdp_viewlayer.BuildViewLayer('TRBU_DAY_COMMENT');
execute ecdp_viewlayer.BuildViewLayer('TRBU_DAY_SUMMARY');
execute ecdp_viewlayer.BuildViewLayer('DATASET_FLOW_REPORT_DIST');
execute ecdp_viewlayer.BuildViewLayer('CT_MHM_MSG');

-- rebuild RV views
execute ecdp_viewlayer.BuildReportLayer('MESSAGE_OUT');
execute ecdp_viewlayer.BuildReportLayer('MESSAGE_OUT_REMARK');
execute ecdp_viewlayer.BuildReportLayer('MESSAGE_WORKFLOW_ALERT');
execute ecdp_viewlayer.BuildReportLayer('MOM_MESSAGE_OUT');
execute ecdp_viewlayer.BuildReportLayer('MSG_FREE_TEXT_SUBJECT');
execute ecdp_viewlayer.BuildReportLayer('MSG_FREE_TEXT_TEMPLATE');
execute ecdp_viewlayer.BuildReportLayer('CALC_EQUATION');
execute ecdp_viewlayer.BuildReportLayer('CALC_LOG_PRFL_PARAM_OVRD');
execute ecdp_viewlayer.BuildReportLayer('CALC_LOG_PROFILE_OVRD');
execute ecdp_viewlayer.BuildReportLayer('CALC_SET');
execute ecdp_viewlayer.BuildReportLayer('CALC_SET_ALL');
execute ecdp_viewlayer.BuildReportLayer('CALC_SET_COMBINATION');
execute ecdp_viewlayer.BuildReportLayer('CALC_SET_CONDITION');
execute ecdp_viewlayer.BuildReportLayer('CALC_SET_EQUATION');
execute ecdp_viewlayer.BuildReportLayer('CALC_SET_INHERITED');
execute ecdp_viewlayer.BuildReportLayer('CALC_STATIC_PARAMETER');
execute ecdp_viewlayer.BuildReportLayer('CALC_VARIABLE_LOCAL');
execute ecdp_viewlayer.BuildReportLayer('CALC_VAR_ALL');
execute ecdp_viewlayer.BuildReportLayer('CALC_VAR_INHERITED');
execute ecdp_viewlayer.BuildReportLayer('MESSAGE_DISTRIBUTION');
execute ecdp_viewlayer.BuildReportLayer('MESSAGE_FORMAT');
execute ecdp_viewlayer.BuildReportLayer('COENT_DAY_CPY_EQTY_DATA');
execute ecdp_viewlayer.BuildReportLayer('REPORT_MSG_DISTRIBUTION');
execute ecdp_viewlayer.BuildReportLayer('FCST_SUB_AREA_DAY_STATUS');
execute ecdp_viewlayer.BuildReportLayer('FCST_SUB_AREA_MTH_STATUS');
execute ecdp_viewlayer.BuildReportLayer('EQUITY_SHARE');
execute ecdp_viewlayer.BuildReportLayer('CONTRACT_GROUP_LIST');
execute ecdp_viewlayer.BuildReportLayer('TRBU_DAY_COMMENT');
execute ecdp_viewlayer.BuildReportLayer('TRBU_DAY_SUMMARY');
execute ecdp_viewlayer.BuildReportLayer('DATASET_FLOW_REPORT_DIST');
execute ecdp_viewlayer.BuildReportLayer('CT_MHM_MSG');

