UPDATE T_BASIS_ACCESS SET LEVEL_ID = 0 WHERE OBJECT_ID IN (select OBJECT_ID from t_basis_object where OBJECT_NAME='/com.ec.tran.cp.screens/fcst_cargo_planning'); 
