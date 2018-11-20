insert into t_basis_access(role_id, app_id, level_id, object_id) 
values('SYST.ADM', 1 , 60, (select object_id from t_basis_object where object_name='/com.ec.cvx.common.screens/message_distribution_popup'));

insert into t_basis_access(role_id, app_id, level_id, object_id) 
values('WEB', 1 , 60, (select object_id from t_basis_object where object_name='/com.ec.cvx.common.screens/message_distribution_popup'));