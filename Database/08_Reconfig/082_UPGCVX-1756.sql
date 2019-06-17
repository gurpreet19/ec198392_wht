DECLARE
  CURSOR c_policy IS
    SELECT *
    FROM   user_policies;
                
  CURSOR c_dac_class IS
    SELECT DISTINCT a.class_name
    FROM   t_basis_access a, t_basis_object_partition p
    WHERE  a.t_basis_access_id = p.t_basis_access_id 
                AND    EcDp_ClassMeta_Cnfg.getAccessControlInd(a.class_name) = 'N';

  CURSOR c_dac_users(p_class_name IN VARCHAR2) IS
                SELECT u.user_id 
                FROM t_basis_user u 
    WHERE u.user_id NOT IN
                      ( SELECT DISTINCT ur.user_id 
            FROM t_basis_userrole ur,
                 t_basis_access a, 
                 t_basis_object_partition p
            WHERE ur.role_id = a.role_id
                                                AND   ur.role_id != 'WEB'
            AND   a.t_basis_access_id = p.t_basis_access_id  
                        AND   a.class_name = p_class_name);
                
  lv_schema_name VARCHAR2(200) := EcDp_ClassMeta.GetSchemaName;
  lv_addpolicy VARCHAR2(200);
  lv_owner_cntx VARCHAR2(30);
  lv_role_id VARCHAR2(30);
  
  ln_t_basis_access_id NUMBER;
  ln_t_basis_object_id NUMBER;
  ln_app_id NUMBER;
BEGIN

	ECDP_CLASSMETA_CNFG.FLUSHCACHE(); 
    execute immediate 'ALTER TRIGGER BI_T_BASIS_OBJECT_PARTITION DISABLE';
    
    FOR cur_policy in c_policy LOOP
                  lv_addpolicy := 'begin dbms_rls.drop_policy(''' || lv_schema_name || ''', ''' || cur_policy.object_name || ''', ''' || cur_policy.policy_name || '''); end;';
                  
                  execute immediate lv_addpolicy;
    END LOOP;
                
                FOR cur_dac_class in c_dac_class LOOP 
                  lv_role_id := 'eDAC_' || cur_dac_class.class_name;

      SELECT MAX(owner_cntx)
      INTO lv_owner_cntx   
                  FROM class_property_cnfg 
                  WHERE CLASS_NAME = cur_dac_class.class_name AND PROPERTY_CODE = 'ACCESS_CONTROL_IND';
                  
                  IF lv_owner_cntx IS NOT NULL THEN
                                UPDATE class_property_cnfg
                                SET PROPERTY_VALUE = 'Y', REV_NO = REV_NO + 1, LAST_UPDATED_BY = 'EC 12.0 Upgrade'
                                WHERE CLASS_NAME = cur_dac_class. class_name
                                AND OWNER_CNTX = lv_owner_cntx;                     
                  ELSE
                                INSERT INTO class_property_cnfg (class_name, property_code, owner_cntx, presentation_cntx, property_type, property_value, created_by)
                                VALUES (cur_dac_class.class_name, 'ACCESS_CONTROL_IND', 2500, '/', 'VIEWLAYER', 'Y', 'EC 12.0 Upgrade');                          
      END IF;
                  
                  SELECT OBJECT_ID, APP_ID
      INTO ln_t_basis_object_id, ln_app_id 
      FROM t_basis_object
      WHERE OBJECT_NAME = cur_dac_class.class_name;
                  
                  INSERT INTO t_basis_role(role_id, app_id, role_name, created_by)
                  VALUES (lv_role_id, ln_app_id, lv_role_id, 'EC 12.0 Upgrade');
                  
                  INSERT INTO t_basis_access (role_id, app_id, level_id, object_id, class_name, created_by)
      VALUES (lv_role_id, ln_app_id, 10, ln_t_basis_object_id, cur_dac_class.class_name, 'EC 12.0 Upgrade')
                  RETURNING t_basis_access_id 
      INTO ln_t_basis_access_id;
                                
                  INSERT INTO t_basis_object_partition (T_BASIS_ACCESS_ID, ATTRIBUTE_NAME, OPERATOR, created_by)
      VALUES (ln_t_basis_access_id, 'OBJECT_ID', 'ALL', 'EC 12.0 Upgrade');

                  FOR cur_user in c_dac_users(cur_dac_class.class_name) LOOP
                                INSERT INTO t_basis_userrole (user_id, role_id, app_id, created_by) VALUES (cur_user.user_id, lv_role_id, ln_app_id, 'EC 12.0 Upgrade');
                  END LOOP;         
    END LOOP;
                
                execute immediate 'ALTER TRIGGER BI_T_BASIS_OBJECT_PARTITION ENABLE';
                
               -- ecdp_viewlayer.BuildViewLayer(null);
              --ecdp_viewlayer.BuildReportLayer(null);
END;
/

---refresh ACL---
execute ecdp_acl.refreshall();

--DELETE FROM T_BASIS_USERROLE WHERE USER_ID='sysadmin' AND ROLE_ID='eDAC_CONTRACT_GROUP';

commit;
