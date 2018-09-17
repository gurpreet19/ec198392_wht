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
  ELSE
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

END ecdp_viewlayer_utils;