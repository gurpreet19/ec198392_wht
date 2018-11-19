delete from t_basis_access where object_id in (select max(object_id) from t_basis_object where object_name='/analysis/execute_approve_button');
delete from t_basis_object where object_id in (select max(object_id) from t_basis_object where object_name='/analysis/execute_approve_button');

delete from t_basis_access where object_id in (select max(object_id) from t_basis_object where object_name='/analysis/execute_verify_button');
delete from t_basis_object where object_id in (select max(object_id) from t_basis_object where object_name='/analysis/execute_verify_button');

delete from t_basis_access where object_id in (select max(object_id) from t_basis_object where object_name='/com.ec.frmw.co.screens/manage_object/CLASS_NAME/CARRIER');
delete from t_basis_object where object_id in (select max(object_id) from t_basis_object where object_name='/com.ec.frmw.co.screens/manage_object/CLASS_NAME/CARRIER');

delete from t_basis_access where object_id in (select max(object_id) from t_basis_object where object_name='/com.ec.frmw.co.screens/object_all_popup');
delete from t_basis_object where object_id in (select max(object_id) from t_basis_object where object_name='/com.ec.frmw.co.screens/object_all_popup');

delete from t_basis_access where object_id in (select max(object_id) from t_basis_object where object_name='/com.ec.frmw.co.screens/object_popup');
delete from t_basis_object where object_id in (select max(object_id) from t_basis_object where object_name='/com.ec.frmw.co.screens/object_popup');

delete from t_basis_access where object_id in (select max(object_id) from t_basis_object where object_name='/com.ec.frmw.co.screens/object_popup_with_nav_param');
delete from t_basis_object where object_id in (select max(object_id) from t_basis_object where object_name='/com.ec.frmw.co.screens/object_popup_with_nav_param');

delete from t_basis_access where object_id in (select max(object_id) from t_basis_object where object_name='/com.ec.frmw.co.screens/tag_event_status');
delete from t_basis_object where object_id in (select max(object_id) from t_basis_object where object_name='/com.ec.frmw.co.screens/tag_event_status');

delete from t_basis_access where object_id in (select max(object_id) from t_basis_object where object_name='/com.ec.frmw.co.screens/trans_process_log');
delete from t_basis_object where object_id in (select max(object_id) from t_basis_object where object_name='/com.ec.frmw.co.screens/trans_process_log');

delete from t_basis_access where object_id in (select max(object_id) from t_basis_object where object_name='/com.ec.frmw.co.screens/trans_tag_activity');
delete from t_basis_object where object_id in (select max(object_id) from t_basis_object where object_name='/com.ec.frmw.co.screens/trans_tag_activity');

delete from t_basis_access where object_id in (select max(object_id) from t_basis_object where object_name='/com.ec.sale.sa.screens/daily_contract_calc_result/BF_PROFILE/SA.0019.DS_PC_CPY/CLASS/CT_SCTR_ACC_D_DS_PC_CPY');
delete from t_basis_object where object_id in (select max(object_id) from t_basis_object where object_name='/com.ec.sale.sa.screens/daily_contract_calc_result/BF_PROFILE/SA.0019.DS_PC_CPY/CLASS/CT_SCTR_ACC_D_DS_PC_CPY');

delete from t_basis_access where object_id in (select min(object_id) from t_basis_object where object_name='/com.ec.wheatstone.screens/nom_cycle_popup');
delete from t_basis_object where object_id in (select min(object_id) from t_basis_object where object_name='/com.ec.wheatstone.screens/nom_cycle_popup');

delete from t_basis_access where object_id in (select object_id from t_basis_object where object_name='/com.ec.cvx.common.screens/message_distribution_popup');
delete from t_basis_object where object_id in (select object_id from t_basis_object where object_name='/com.ec.cvx.common.screens/message_distribution_popup');