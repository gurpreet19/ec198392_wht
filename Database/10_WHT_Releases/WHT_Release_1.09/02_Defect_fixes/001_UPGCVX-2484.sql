delete from t_basis_access where object_id in (select object_id from t_basis_object where object_name = '/com.ec.sale.co.screens/processing_unit' ) and  role_id in ('PA.OBJ.READ','PA.OBJ.WRITE');

delete from t_basis_access where object_id in (select object_id from t_basis_object where object_name = '/com.ec.sale.co.screens/processing_unit' ) and  role_id = 'SYST.ADM' and level_id = '40';

delete from t_basis_access where object_id in (select object_id from t_basis_object where object_name = '/com.ec.prod.po.screens/daily_tank_status_1' ) and  role_id in ('CP.ORIGINAL.READ','PA.A.DATA.WRITE', 'PA.DATA.READ', 'PA.P.DATA.WRITE', 'PA.V.DATA.WRITE');

Insert into t_basis_access (ROLE_ID,APP_ID,LEVEL_ID,OBJECT_ID) values ('ADM.MANAGEMENT',1,40,(select object_id from t_basis_object where object_name='/com.ec.frmw.bs.calc.screens/maintain_calculation'));
Insert into t_basis_access (ROLE_ID,APP_ID,LEVEL_ID,OBJECT_ID) values ('PA.OBJ.READ',1,10,(select object_id from t_basis_object where object_name='/com.ec.frmw.bs.calc.screens/maintain_calculation'));

Insert into t_basis_access (ROLE_ID,APP_ID,LEVEL_ID,OBJECT_ID) values ('ADM.CONFIG',1,60,(select object_id from t_basis_object where object_name='/com.ec.tran.co.screens/manage_contract_group_list/OBJ_CLASS/CONTRACT_GROUP/DATA_CLASS/CONTRACT_GROUP_LIST'));
Insert into t_basis_access (ROLE_ID,APP_ID,LEVEL_ID,OBJECT_ID) values ('DG.OBJ.READ',1,10,(select object_id from t_basis_object where object_name='/com.ec.tran.co.screens/manage_contract_group_list/OBJ_CLASS/CONTRACT_GROUP/DATA_CLASS/CONTRACT_GROUP_LIST'));
Insert into t_basis_access (ROLE_ID,APP_ID,LEVEL_ID,OBJECT_ID) values ('DG.OBJ.WRITE',1,40,(select object_id from t_basis_object where object_name='/com.ec.tran.co.screens/manage_contract_group_list/OBJ_CLASS/CONTRACT_GROUP/DATA_CLASS/CONTRACT_GROUP_LIST'));

Insert into t_basis_access (ROLE_ID,APP_ID,LEVEL_ID,OBJECT_ID) values ('PA.DATA.READ',1,10,(select object_id from t_basis_object where object_name='/com.ec.prod.po.screens/daily_stream_status/CLASS_NAME/STRM_DAY_STREAM_MEAS_ELE/CLASS_NAME_DETAIL/STRM_DAY_STREAM_DER_ELE'));
Insert into t_basis_access (ROLE_ID,APP_ID,LEVEL_ID,OBJECT_ID) values ('PA.A.DATA.WRITE',1,60,(select object_id from t_basis_object where object_name='/com.ec.prod.po.screens/daily_stream_status/CLASS_NAME/STRM_DAY_STREAM_MEAS_ELE/CLASS_NAME_DETAIL/STRM_DAY_STREAM_DER_ELE'));
Insert into t_basis_access (ROLE_ID,APP_ID,LEVEL_ID,OBJECT_ID) values ('PA.V.DATA.WRITE',1,50,(select object_id from t_basis_object where object_name='/com.ec.prod.po.screens/daily_stream_status/CLASS_NAME/STRM_DAY_STREAM_MEAS_ELE/CLASS_NAME_DETAIL/STRM_DAY_STREAM_DER_ELE'));
Insert into t_basis_access (ROLE_ID,APP_ID,LEVEL_ID,OBJECT_ID) values ('PA.P.DATA.WRITE',1,40,(select object_id from t_basis_object where object_name='/com.ec.prod.po.screens/daily_stream_status/CLASS_NAME/STRM_DAY_STREAM_MEAS_ELE/CLASS_NAME_DETAIL/STRM_DAY_STREAM_DER_ELE'));

Insert into t_basis_access (ROLE_ID,APP_ID,LEVEL_ID,OBJECT_ID) values ('PA.DATA.READ',1,10,(select object_id from t_basis_object where object_name='/com.ec.prod.po.screens/daily_stream_status/CLASS_NAME/STRM_DAY_STREAM_MEAS_LNG/CLASS_NAME_DETAIL/STRM_DAY_STREAM_DER_LNG'));
Insert into t_basis_access (ROLE_ID,APP_ID,LEVEL_ID,OBJECT_ID) values ('PA.A.DATA.WRITE',1,60,(select object_id from t_basis_object where object_name='/com.ec.prod.po.screens/daily_stream_status/CLASS_NAME/STRM_DAY_STREAM_MEAS_LNG/CLASS_NAME_DETAIL/STRM_DAY_STREAM_DER_LNG'));
Insert into t_basis_access (ROLE_ID,APP_ID,LEVEL_ID,OBJECT_ID) values ('PA.V.DATA.WRITE',1,50,(select object_id from t_basis_object where object_name='/com.ec.prod.po.screens/daily_stream_status/CLASS_NAME/STRM_DAY_STREAM_MEAS_LNG/CLASS_NAME_DETAIL/STRM_DAY_STREAM_DER_LNG'));
Insert into t_basis_access (ROLE_ID,APP_ID,LEVEL_ID,OBJECT_ID) values ('PA.P.DATA.WRITE',1,40,(select object_id from t_basis_object where object_name='/com.ec.prod.po.screens/daily_stream_status/CLASS_NAME/STRM_DAY_STREAM_MEAS_LNG/CLASS_NAME_DETAIL/STRM_DAY_STREAM_DER_LNG'));

Insert into t_basis_access (ROLE_ID,APP_ID,LEVEL_ID,OBJECT_ID) values ('MA.BL.CARDOCS',1,40,(select object_id from t_basis_object where object_name='/com.ec.tran.to.screens/cargo_document/COLUMN_SORT/RUN_DATE/SORT_TYPE/DESC'));
Insert into t_basis_access (ROLE_ID,APP_ID,LEVEL_ID,OBJECT_ID) values ('MA.READ.ALL',1,10,(select object_id from t_basis_object where object_name='/com.ec.tran.to.screens/cargo_document/COLUMN_SORT/RUN_DATE/SORT_TYPE/DESC'));

COMMIT;
