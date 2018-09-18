CREATE OR REPLACE PACKAGE BODY EcDp_ReadOnly IS


PROCEDURE ReadOnlyLockRule(p_operation VARCHAR2, p_new_lock_columns IN OUT EcDp_Month_Lock.column_list, p_old_lock_columns IN OUT EcDp_Month_Lock.column_list)
IS
    lv2_object_id VARCHAR2(32);
    lv2_daytime   DATE;
BEGIN
    IF p_new_lock_columns.exists('OBJECT_ID') THEN
        lv2_object_id := p_new_lock_columns('OBJECT_ID').column_data.AccessVarchar2;
    END IF;

    IF p_new_lock_columns.exists('DAYTIME') AND p_new_lock_columns('DAYTIME').column_data.AccessDate IS NOT NULL THEN
        lv2_daytime := p_new_lock_columns('DAYTIME').column_data.AccessDate;
    ELSIF p_old_lock_columns.exists('DAYTIME') AND p_old_lock_columns('DAYTIME').column_data.AccessDate IS NOT NULL THEN
        lv2_daytime := p_old_lock_columns('DAYTIME').column_data.AccessDate;
    ELSIF p_new_lock_columns.exists('OBJECT_START_DATE') AND p_new_lock_columns('OBJECT_START_DATE').column_data.AccessDate IS NOT NULL THEN
        lv2_daytime := p_new_lock_columns('OBJECT_START_DATE').column_data.AccessDate;
    END IF;

    IF IsReadOnly(EcDp_Context.getAppUser, lv2_object_id, lv2_daytime) = 'Y' THEN
        RAISE_APPLICATION_ERROR(-20675, 'Update to '||EcDp_Objects.GetObjCode(lv2_object_id)||' denied.');
    END IF;

END ReadOnlyLockRule;


FUNCTION IsExplicitlyReadOnly(p_object_id VARCHAR2, p_user_name VARCHAR2)
RETURN VARCHAR2
IS
    lv2_is_read_only VARCHAR2(1) := 'N';

    CURSOR c_exp_read_only(p_object_id VARCHAR2, p_user_name VARCHAR2) IS
        SELECT 'Y' AS read_only
        FROM   t_basis_userrole r, t_basis_access a, t_basis_object_partition p
        WHERE  r.user_id = p_user_name
        AND    r.role_id = a.role_id
        AND    a.t_basis_access_id = p.t_basis_access_id
        AND    p.operator = 'IN'
        AND    p.read_only LIKE '%'||p_object_id||'%';
BEGIN
    FOR read_only IN c_exp_read_only(p_object_id, p_user_name) LOOP
        lv2_is_read_only := 'Y';
    END LOOP;

    RETURN lv2_is_read_only;

END IsExplicitlyReadOnly;


FUNCTION IsExplicitlyNotReadOnly(p_object_id VARCHAR2, p_user_name VARCHAR2)
RETURN VARCHAR2
IS
    lv2_not_read_only VARCHAR2(1) := 'N';

    CURSOR c_exp_not_read_only(p_object_id VARCHAR2, p_user_name VARCHAR2) IS
        SELECT 'Y' AS not_read_only
        FROM   t_basis_userrole r, t_basis_access a, t_basis_object_partition p
        WHERE  r.user_id = p_user_name
        AND    r.role_id = a.role_id
        AND    a.t_basis_access_id = p.t_basis_access_id
        AND    p.operator = 'IN'
        AND    p.attribute_text LIKE '%'||p_object_id||'%'
        AND    (p.read_only IS NULL OR p.read_only NOT LIKE '%'||p_object_id||'%');
BEGIN
    FOR not_read_only IN c_exp_not_read_only(p_object_id, p_user_name) LOOP
        lv2_not_read_only := 'Y';
    END LOOP;

    RETURN lv2_not_read_only;

END IsExplicitlyNotReadOnly;


---------------------------------------------------------------------------------------------------
-- Returns:
--   'Y' when object is read-only.
--   'N' when object is not read-only.
--   NULL when p_object_id is NULL, or read-only status is not configured for this object or any of its parent objects.
---------------------------------------------------------------------------------------------------
FUNCTION IsReadOnly(p_user_name VARCHAR2, p_object_id VARCHAR2, p_daytime DATE, p_class_name VARCHAR2, p_read_only_precedence VARCHAR2)
RETURN VARCHAR2
IS
    CURSOR c_class_relations(p_class_name VARCHAR2) IS
        SELECT from_class_name, role_name
        FROM   class_relation_cnfg
        WHERE  to_class_name = p_class_name
        AND    EcDp_ClassMeta_Cnfg.isDisabled(from_class_name, to_class_name, role_name) = 'N';

    lv2_parent_obj_id VARCHAR2(32);
    lv2_is_read_only  VARCHAR2(1);
BEGIN
    IF p_object_id IS NULL THEN
        RETURN NULL;
    ELSIF p_read_only_precedence = 'N' AND IsExplicitlyNotReadOnly(p_object_id, p_user_name) = 'Y' THEN
        -- The object is explicitly configured as not read-only. User has write access.
        RETURN 'N';
    ELSIF IsExplicitlyReadOnly(p_object_id, p_user_name) = 'Y' THEN
        -- The object is explicitly configured as read-only. User only has read access.
        RETURN 'Y';
    END IF;

    -- Read-only status can be inherited from parent objects. Must check class relations.
    FOR cls_rel IN c_class_relations(p_class_name) LOOP
        lv2_parent_obj_id := EcDp_DynSql.execute_singlerow_varchar2(
            'select ' || cls_rel.role_name || '_ID' ||
            ' from OV_' || p_class_name ||
            ' where object_id = ''' || p_object_id || '''' ||
            ' and daytime <= to_date(''' || p_daytime || ''')' ||
            ' and nvl(end_date, to_date(''' || p_daytime || ''')+1) > to_date(''' || p_daytime || ''')');

        lv2_is_read_only := IsReadOnly(p_user_name, lv2_parent_obj_id, p_daytime, cls_rel.from_class_name, p_read_only_precedence);

        IF lv2_is_read_only IS NOT NULL THEN
            RETURN lv2_is_read_only;
        END IF;
    END LOOP;

    RETURN NULL;

END IsReadOnly;


FUNCTION IsReadOnly(p_user_name VARCHAR2, p_object_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2
IS
BEGIN
    RETURN NVL(IsReadOnly(p_user_name, p_object_id, p_daytime, EcDp_Objects.GetObjClassName(p_object_id),
        EcDp_Ctrl_Property.getSystemProperty('/com/ec/frmw/co/screens/maintain_access_partitions/read_only_precedence', p_daytime)), 'N');
END IsReadOnly;


END EcDp_ReadOnly;