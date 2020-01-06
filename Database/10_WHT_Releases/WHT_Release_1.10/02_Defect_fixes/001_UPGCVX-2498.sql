Insert into T_BASIS_ACCESS (ROLE_ID,APP_ID,LEVEL_ID,OBJECT_ID) values ('SYST.ADM',1,60,(select object_id from t_basis_object where object_name='/com.ec.cvx.common.screens/message_distribution_popup'));
Insert into T_BASIS_ACCESS (ROLE_ID,APP_ID,LEVEL_ID,OBJECT_ID) values ('WEB',1,60,(select object_id from t_basis_object where object_name='/com.ec.cvx.common.screens/message_distribution_popup'));

commit;
