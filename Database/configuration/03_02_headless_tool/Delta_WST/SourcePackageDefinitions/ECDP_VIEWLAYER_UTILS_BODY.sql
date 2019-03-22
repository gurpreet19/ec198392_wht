CREATE OR REPLACE PACKAGE BODY ecdp_viewlayer_utils IS

syntax_error EXCEPTION;

CURSOR c_dirty_classes(p_class_name IN VARCHAR2, p_dirty_type IN VARCHAR2, p_app_space_cntx IN VARCHAR2) IS
  SELECT x.dirty_type AS type, c.class_name, substr(c.class_type, 1, 1)||'V_'||c.class_name AS object_name
  FROM viewlayer_dirty_log x
  INNER JOIN class_cnfg c ON
        c.class_name = nvl(p_class_name, c.class_name) AND
        c.app_space_cntx = nvl(p_app_space_cntx, c.app_space_cntx) AND
        c.class_type <> 'META' AND
        c.class_name = x.object_name AND
        installOrder(app_space_cntx) <= installOrder(Nvl(p_app_space_cntx, app_space_cntx))
  LEFT JOIN user_views uv ON
       (p_dirty_type = 'VIEWLAYER' AND substr(c.class_type, 1, 1)||'V_'||c.class_name = uv.view_name) OR
       (p_dirty_type = 'REPORTLAYER' AND 'RV_'||c.class_name = uv.view_name)
  WHERE (x.dirty_ind = 'Y' OR uv.view_name IS NULL) AND x.dirty_type = p_dirty_type
;

FUNCTION installOrder(p_app_space_cntx IN VARCHAR2)
RETURN NUMBER
IS
BEGIN
  IF ecdp_pinc.isInstallMode THEN
    IF p_app_space_cntx = 'EC_FRMW' THEN RETURN 1; END IF;
    IF p_app_space_cntx = 'EC_BPM'  THEN RETURN 2; END IF;
    IF p_app_space_cntx = 'EC_PROD' THEN RETURN 3; END IF;
    IF p_app_space_cntx = 'EC_TRAN' THEN RETURN 4; END IF;
    IF p_app_space_cntx = 'EC_SALE' THEN RETURN 5; END IF;
    IF p_app_space_cntx = 'EC_REVN' THEN RETURN 6; END IF;
    IF p_app_space_cntx = 'EC_ECDM' THEN RETURN 7; END IF;
  END IF;
  RETURN 0;
END installOrder;

FUNCTION removeSchemaName(p_object_name IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  RETURN SUBSTR(p_object_name, INSTR(p_object_name, '.')+1);
END removeSchemaName;

FUNCTION jnColumnList(p_ue_user_function IN VARCHAR2, p_alias IN VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
IS
  lv2_alias VARCHAR2(100) := CASE WHEN p_alias IS NOT NULL THEN p_alias||'.' ELSE '' END;
BEGIN
   RETURN lv2_alias||'JN_OPERATION AS JN_OPERATION,'||CHR(10)||
          CASE WHEN p_ue_user_function = 'Y' THEN 'ue_user.getusername('||lv2_alias||'JN_ORACLE_USER)' ELSE 'JN_ORACLE_USER' END||' AS JN_ORACLE_USER, '||CHR(10)||
          lv2_alias||'JN_DATETIME AS JN_DATETIME,'||CHR(10)||
          lv2_alias||'JN_NOTES AS JN_NOTES,'||CHR(10)||
          lv2_alias||'JN_APPLN AS JN_APPLN,'||CHR(10)||
          lv2_alias||'JN_SESSION AS JN_SESSION,';
END jnColumnList;

FUNCTION viewExists(p_name IN VARCHAR2, p_owner IN VARCHAR2)
RETURN BOOLEAN
IS

  CURSOR c_view(cp_view_name VARCHAR2, cp_view_owner  VARCHAR2) IS
    SELECT 1
    FROM all_views
    WHERE view_name = UPPER(cp_view_name)
    AND owner = Nvl(cp_view_owner, USER);

  lb_exists           BOOLEAN := FALSE;
  lv2_view_name       VARCHAR2(32) := removeSchemaName(p_name);
BEGIN
  FOR cur_rec IN c_view(lv2_view_name, p_owner) LOOP
     lb_exists := TRUE;
     EXIT;
  END LOOP;
  RETURN lb_exists;
END viewExists;

FUNCTION tableExists(p_name IN VARCHAR2, p_owner IN VARCHAR2)
RETURN BOOLEAN
IS
  CURSOR c_tableexists(p_tableName VARCHAR2, p_tableOwner  VARCHAR2) IS
    SELECT 1 FROM all_tables
    WHERE table_name = UPPER(p_tableName)
    AND owner = Nvl(p_tableOwner,user);

   lb_exsists           BOOLEAN := FALSE;
   lv2_table_name       VARCHAR2(32) := removeSchemaName(p_name);
BEGIN
  FOR curTable IN c_tableexists(lv2_table_name, p_owner) LOOP
    lb_exsists := TRUE;
    EXIT;
  END LOOP;
  RETURN lb_exsists OR viewExists(lv2_table_name, p_owner);
END TableExists;

FUNCTION columnExists(
   p_table_name         VARCHAR2,
   p_column_name        VARCHAR2,
   p_table_owner        VARCHAR2
)
RETURN BOOLEAN
IS
   CURSOR c_columnexists(cp_table_name IN VARCHAR2, cp_column_name IN VARCHAR2) IS
      SELECT 1
      FROM   all_tab_columns c
      WHERE  c.table_name = upper(cp_table_name)
      AND    c.column_name = upper(cp_column_name);

   lb_exsists           BOOLEAN := FALSE;
   lv2_table_name       VARCHAR2(32) := removeSchemaName(p_table_name);
   lv2_owner            VARCHAR2(32) := replace(nvl(p_table_owner, upper(user)), 'ENERGYX', 'ECKERNEL');

BEGIN
  IF tableExists(lv2_table_name, lv2_owner) THEN
    FOR cur IN c_columnexists(lv2_table_name, p_column_name) LOOP
        lb_exsists := TRUE;
    END LOOP;
  END IF;
  RETURN lb_exsists;
END columnExists;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : SafeBuild
-- Description    : Compile or write view to t_temptext for script building
--
-- Preconditions  : All sql comes with CREATE OR REPLACE statement (VIEWS, TRIGGERS, PACKAGES)
-- Postcondition  : Checks that view code compiles before existing view is replaced
--
-- Using Tables   :
--
-- Using functions: WriteTempText
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE SafeBuild(p_object_name VARCHAR2,
                    p_object_type VARCHAR2,
                    p_sql         CLOB,
                    p_target      VARCHAR2 DEFAULT 'CREATE',
                    p_sql2        VARCHAR2 DEFAULT '',
                    p_id          VARCHAR2 DEFAULT 'GENCODE')
--</EC-DOC>

IS
  lv2_sql         CLOB := NULL;
  lb_continue     BOOLEAN;
  lv2_dummyname   VARCHAR2(30);

  CURSOR c_user_object_status(cp_object_name VARCHAR2, cp_object_type VARCHAR2) IS
  SELECT status FROM user_objects
  WHERE object_name = UPPER(cp_object_name)
  AND   object_type = cp_object_type;


BEGIN

    IF p_target = 'CREATE' THEN -- create the view

      IF p_object_type IN ('VIEW','TRIGGER')  THEN

        -- First check if object compiles without error
        -- Need to drop dummy object if it exists

           lv2_dummyname := 'XX'||SUBSTR(p_object_name,1,28);

           FOR cur_object_status IN c_user_object_status(lv2_dummyname, p_object_type) LOOP

             lv2_sql := 'DROP '||p_object_type||' '||lv2_dummyname;

           END LOOP;

           IF lv2_sql IS NOT NULL THEN
              EXECUTE IMMEDIATE lv2_sql;
           END IF;

           lv2_sql := REGEXP_REPLACE(p_sql, p_object_name, lv2_dummyname, 1, 1);
           lb_continue := FALSE;

           EXECUTE IMMEDIATE lv2_sql||p_sql2;

           FOR cur_object_status IN c_user_object_status(lv2_dummyname, p_object_type) LOOP

             IF cur_object_status.status = 'VALID' THEN
               lb_continue := TRUE;
             ELSE
               lb_continue := FALSE;
             END IF;

           END LOOP;

           IF lb_continue THEN

             lv2_sql := 'DROP '||p_object_type||' '||lv2_dummyname;

              EXECUTE IMMEDIATE lv2_sql;

              EXECUTE IMMEDIATE p_sql||p_sql2;


           ELSE
              RAISE syntax_error;
           END IF;

        ELSE

              EXECUTE IMMEDIATE p_sql||p_sql2;

        END IF;




    ELSE -- insert in t_temptext

         IF p_sql2 IS NULL THEN

            EcDp_DynSql.WriteTempText(p_id, p_sql || CHR(10) || '/');

         ELSE

            EcDp_DynSql.WriteTempText(p_id, p_sql );
            EcDp_DynSql.WriteTempText(p_id, p_sql2 || CHR(10) || '/');

         END IF;

    END IF;


EXCEPTION

     WHEN OTHERS THEN
         EcDp_DynSql.WriteTempText(p_id || 'ERROR','Syntax error generating '||p_object_type ||' for '||p_object_name||CHR(10)||SQLERRM||CHR(10)|| p_sql);

END SafeBuild;


FUNCTION getDirtyClasses(p_class_name IN VARCHAR2, p_dirty_type IN VARCHAR2 DEFAULT 'VIEWLAYER', p_app_space_cntx IN VARCHAR2 DEFAULT NULL)
RETURN DirtyMap_t
IS
  l_dirty_map DirtyMap_t;
BEGIN
  FOR curDirty IN c_dirty_classes(p_class_name, p_dirty_type, p_app_space_cntx) LOOP
    l_dirty_map(curDirty.class_name) := 1;
  END LOOP;

  IF p_class_name IS NOT NULL THEN
    FOR curDependent IN ecdp_viewlayer_utils.c_dac_dependent_class(p_class_name) LOOP
      FOR curDirty IN c_dirty_classes(curDependent.dependent_class, p_dirty_type, p_app_space_cntx) LOOP
        l_dirty_map(curDirty.class_name) := 1;
      END LOOP;
    END LOOP;
  END IF;

  RETURN l_dirty_map;
END getDirtyClasses;

FUNCTION countDirtyClasses(p_class_name IN VARCHAR2, p_dirty_type IN VARCHAR2 DEFAULT 'VIEWLAYER', p_app_space_cntx IN VARCHAR2 DEFAULT NULL)
RETURN INTEGER
IS
  l_dirty_map DirtyMap_t := getDirtyClasses(p_class_name, p_dirty_type, p_app_space_cntx);
BEGIN
  RETURN l_dirty_map.COUNT;
END countDirtyClasses;

FUNCTION is_dirty(p_object_name IN VARCHAR2, p_dirty_type IN VARCHAR2)
RETURN BOOLEAN
IS
  ln_count NUMBER := 0;
BEGIN
  SELECT count(*) INTO ln_count
  FROM   viewlayer_dirty_log
  WHERE  object_name = nvl(p_object_name, object_name)
  AND    dirty_type = nvl(p_dirty_type, dirty_type)
  AND    dirty_ind = 'Y';
  RETURN ln_count > 0;
END is_dirty;

PROCEDURE set_dirty_ind(p_object_name IN VARCHAR2, p_dirty_type IN VARCHAR2, p_dirty IN BOOLEAN)
IS
  ln_count NUMBER;
  lv2_dirty_ind VARCHAR2(1) := CASE p_dirty WHEN TRUE THEN 'Y' ELSE 'N' END;
BEGIN
  SELECT count(*) INTO ln_count
  FROM   viewlayer_dirty_log
  WHERE  object_name = nvl(p_object_name, object_name)
  AND    dirty_type = nvl(p_dirty_type, dirty_type);

  IF ln_count > 0 THEN
    UPDATE viewlayer_dirty_log
    SET    dirty_ind = lv2_dirty_ind
    WHERE  object_name = nvl(p_object_name, object_name)
    AND    dirty_type = nvl(p_dirty_type, dirty_type)
    AND    nvl(dirty_ind, 'N') != lv2_dirty_ind;
  ELSIF p_object_name IS NOT NULL THEN
    INSERT INTO viewlayer_dirty_log (object_name, dirty_type, dirty_ind) VALUES (p_object_name, p_dirty_type, lv2_dirty_ind);
  END IF;
END set_dirty_ind;

FUNCTION hasAppSpaceFootprint(p_class_name IN VARCHAR2, p_app_space_cntx IN VARCHAR2)
RETURN VARCHAR2
IS
  ln_count NUMBER := 0;
BEGIN
  IF ln_count = 0 THEN
    SELECT count(1) INTO ln_count FROM class_cnfg WHERE class_name = p_class_name AND app_space_cntx = Nvl(p_app_space_cntx, app_space_cntx);
  END IF;
  IF ln_count = 0 THEN
    SELECT count(1) INTO ln_count FROM class_attribute_cnfg WHERE class_name = p_class_name AND app_space_cntx = Nvl(p_app_space_cntx, app_space_cntx);
  END IF;
  IF ln_count = 0 THEN
    SELECT count(1) INTO ln_count FROM class_relation_cnfg WHERE to_class_name = p_class_name AND app_space_cntx = Nvl(p_app_space_cntx, app_space_cntx);
  END IF;
  IF ln_count = 0 THEN
    SELECT count(1) INTO ln_count FROM class_dependency_cnfg WHERE parent_class = p_class_name AND app_space_cntx = Nvl(p_app_space_cntx, app_space_cntx);
  END IF;
  IF ln_count = 0 THEN
    RETURN 'N';
  ELSE
    RETURN 'Y';
  END IF;
END hasAppSpaceFootprint;

FUNCTION resolvePriority(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2, p_root_class_name IN VARCHAR2, p_property_code IN VARCHAR2)
RETURN VARCHAR2
RESULT_CACHE
IS
  CURSOR c_priority IS
      SELECT from_class_name, to_class_name, role_name, min(priority) AS priority FROM (
        SELECT LEVEL AS priority, r.from_class_name, r.to_class_name, r.role_name
        FROM   class_relation_cnfg r
        INNER JOIN v_class_rel_property_cnfg p ON p.property_code = p_property_code AND p.property_value = 'Y' AND p.from_class_name = r.from_class_name AND p.to_class_name = r.to_class_name AND p.role_name = r.role_name
        WHERE  ec_class_cnfg.class_type(r.to_class_name) = 'OBJECT' AND ecdp_classmeta_cnfg.isDisabled(r.from_class_name, r.to_class_name, r.role_name) = 'N'
        START WITH r.from_class_name = p_root_class_name
        CONNECT BY NOCYCLE r.from_class_name = PRIOR r.to_class_name
      )
      WHERE from_class_name = p_from_class_name AND to_class_name = p_to_class_name AND role_name = p_role_name
      GROUP BY from_class_name, to_class_name, role_name
      ORDER BY priority;
BEGIN
  FOR cur IN c_priority LOOP
    RETURN cur.priority;
  END LOOP;
  RETURN 0;
END;

FUNCTION objectRelCascadeSanityCheck(p_property_code IN VARCHAR2, p_error_message IN VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR invalidObjectRel(p_property_code IN VARCHAR2) IS
    select to_class_name
    from v_class_rel_property_cnfg
    where property_code = p_property_code
    and from_class_name not in ('PRODUCTION_DAY', 'TIME_ZONE_REGION', 'UNIT_CONTEXT', 'CONVERSION_CONTEXT')
    and property_value = 'Y'
    group by to_class_name
    having count(to_class_name) > 1;

  lv2_invalid_class_name VARCHAR2(2000) := '';
  lv2_error_message VARCHAR2(2000) := '';
BEGIN
  FOR cur IN invalidObjectRel(p_property_code) LOOP
    lv2_invalid_class_name:= lv2_invalid_class_name || cur.to_class_name || ' ';
  END LOOP;

  IF lv2_invalid_class_name IS NOT NULL THEN
    lv2_error_message := '>> Invalid class_rel_property_cnfg records for to_class_name: '|| '[' || lv2_invalid_class_name  || '], property_code = ' || p_property_code || '.' || CHR(10) ||
                         'For the same to_class_name where property_code = ' || p_property_code || ',' || CHR(10) ||
                         'it is only allowed to have one class relation property configuration record with property_value = Y.' || CHR(10) || CHR(10);
  END IF;

  IF lv2_error_message IS NOT NULL THEN
     lv2_error_message := p_error_message || lv2_error_message;

	 return lv2_error_message;
  END IF;

  return p_error_message;
END;

PROCEDURE buildObjectRelCascadeView
IS
  CURSOR c_cascade_view_syntax(p_cascaded_class IN VARCHAR2, p_property_code IN VARCHAR2) IS
    SELECT 'SELECT '''||p_cascaded_class||''' AS cascaded_class, '''||from_class_name||''' AS from_class_name, '''||to_class_name||''' AS to_class_name, '''||role_name||''' AS role_name, '||
           syntax||' AS from_object_id, v.daytime AS from_daytime, v.end_date AS from_end_date, '||
           'oa.object_id, oa.daytime, oa.end_date, '||
           resolvePriority(from_class_name, to_class_name, role_name, p_cascaded_class, p_property_code)||' AS priority FROM '||
           lower(tc_db_object_attribute)||' oa '||
           'INNER JOIN '||lower(tc_db_object_name)||' o ON o.object_id = oa.object_id '||
           'INNER JOIN '||lower(fc_db_object_attribute)||' v ON v.object_id = '||syntax||' AND oa.daytime BETWEEN v.daytime AND nvl(v.end_date, oa.daytime) '||
           'WHERE '||syntax||' IS NOT NULL '||decode(tc_db_where_condition, null, '', ' AND '|| tc_db_where_condition) AS view_syntax
    FROM (
      SELECT CASE WHEN r.db_mapping_type='COLUMN' THEN lower('ec_'||tc.db_object_name||'.'||r.db_sql_syntax||'(oa.object_id)')
                  WHEN r.db_mapping_type='ATTRIBUTE' THEN 'oa.'||lower(r.db_sql_syntax)
                  WHEN r.db_mapping_type='FUNCTION' THEN r.db_sql_syntax
             END AS syntax,
             r.from_class_name, r.to_class_name, r.role_name,
             fc.db_object_attribute AS fc_db_object_attribute,
             tc.db_where_condition AS tc_db_where_condition, tc.db_object_attribute AS tc_db_object_attribute, tc.db_object_name AS tc_db_object_name
      FROM v_class_rel_property_cnfg p
      INNER JOIN class_relation_cnfg r ON r.from_class_name = p.from_class_name AND r.to_class_name = p.to_class_name AND r.role_name = p.role_name
      INNER JOIN class_cnfg tc ON tc.class_name = r.to_class_name AND tc.class_type = 'OBJECT'
      INNER JOIN class_cnfg fc ON fc.class_name = r.from_class_name
      WHERE p.property_code = p_property_code AND p.property_value = 'Y'
    );

  lv_buffer DBMS_SQL.varchar2a;
  lv2_union_all VARCHAR2(32) := '';
  ln_count NUMBER := 0;
  lv2_sanity_check_error_message VARCHAR2(5000) := '';
BEGIN
  lv2_sanity_check_error_message := objectRelCascadeSanityCheck('CASCADE_PRODUCTION_DAY_IND', lv2_sanity_check_error_message);
  lv2_sanity_check_error_message := objectRelCascadeSanityCheck('CASCADE_TIMEZONE_IND', lv2_sanity_check_error_message);
  lv2_sanity_check_error_message := objectRelCascadeSanityCheck('CASCADE_UNIT_CONTEXT_IND', lv2_sanity_check_error_message);
  lv2_sanity_check_error_message := objectRelCascadeSanityCheck('CASCADE_CONVERSION_CONTEXT_IND', lv2_sanity_check_error_message);

  IF lv2_sanity_check_error_message IS NOT NULL THEN
     Raise_Application_Error (-20002, lv2_sanity_check_error_message);
  END IF;

  Ecdp_Dynsql.AddSqlLineNoWrap(lv_buffer, 'CREATE OR REPLACE VIEW gv_object_rel_cascade AS '||CHR(10));

  FOR cur IN c_cascade_view_syntax('PRODUCTION_DAY', 'CASCADE_PRODUCTION_DAY_IND') LOOP
    Ecdp_Dynsql.AddSqlLineNoWrap(lv_buffer, lv2_union_all||cur.view_syntax||CHR(10));
    lv2_union_all := 'UNION ALL'||CHR(10);
    ln_count := ln_count + 1;
  END LOOP;

  FOR cur IN c_cascade_view_syntax('TIME_ZONE_REGION', 'CASCADE_TIMEZONE_IND') LOOP
    Ecdp_Dynsql.AddSqlLineNoWrap(lv_buffer, lv2_union_all||cur.view_syntax||CHR(10));
    lv2_union_all := 'UNION ALL'||CHR(10);
    ln_count := ln_count + 1;
  END LOOP;

  FOR cur IN c_cascade_view_syntax('UNIT_CONTEXT', 'CASCADE_UNIT_CONTEXT_IND') LOOP
    Ecdp_Dynsql.AddSqlLineNoWrap(lv_buffer, lv2_union_all||cur.view_syntax||CHR(10));
    lv2_union_all := 'UNION ALL'||CHR(10);
    ln_count := ln_count + 1;
  END LOOP;

  FOR cur IN c_cascade_view_syntax('CONVERSION_CONTEXT', 'CASCADE_CONVERSION_CONTEXT_IND') LOOP
    Ecdp_Dynsql.AddSqlLineNoWrap(lv_buffer, lv2_union_all||cur.view_syntax||CHR(10));
    lv2_union_all := 'UNION ALL'||CHR(10);
    ln_count := ln_count + 1;
  END LOOP;

  IF ln_count = 0 THEN
    Ecdp_Dynsql.AddSqlLineNoWrap(lv_buffer, q'[
  SELECT null AS cascaded_class, r.from_class_name, r.to_class_name, r.role_name, null from_object_id, null from_daytime, null from_end_date, ov.object_id, ov.daytime, ov.end_date, 1 AS priority
  FROM class_relation_cnfg r
  INNER JOIN objects_version_table ov ON 0 = 1
  WHERE 0 = 1
    ]');
  END IF;
  EcDp_Dynsql.SafeBuild('GV_OBJECT_REL_CASCADE', 'VIEW', lv_buffer);
END buildObjectRelCascadeView;

END ecdp_viewlayer_utils;