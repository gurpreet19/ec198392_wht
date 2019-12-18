create or replace PACKAGE BODY EcDp_DAC IS
/* ***************************************************************
** Package        :  EcDp_DAC, body part
**
** $Revision: 1.0 $
**
** Purpose        :  Data Access Control (replace Oracle EE VPD)
**
**
** Created  : 16-Feb-2018, Shengtong Zhong
**
** Modification history:
**
**  Date           Whom  Change description:
**  ------         ----- --------------------------------------
**  16-Feb-2018    Zho   Initial version
**  18-Dec-2019    dhavaalo   Jira UPGCVX-2478 : WST Gorgon specific override to let external user have access to DV and RV views as ECKERNEL_GORGON have.
*************************************************************** */
--</HEAD>

  lv_schema_name VARCHAR2(30) := EcDp_ClassMeta.GetSchemaName;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : GenPopulateProc                                                              --
-- Description    : Generate populate header and body for p_class_name.                          --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
--<FUNC>
PROCEDURE GenPopulateProc(
          p_header_buffer    IN OUT DBMS_SQL.varchar2a
,         p_body_buffer      IN OUT DBMS_SQL.varchar2a
,         p_class_name       IN VARCHAR2
,         p_class_type       IN VARCHAR2)
IS
--</FUNC>
--</EC-DOC>
  lt_db_mapping    class_cnfg%ROWTYPE;
  lt_cursor_buffer DBMS_SQL.varchar2a;
  lt_relation_list EcDp_ACL.RelationL_t;
BEGIN
    IF p_class_type!='OBJECT' THEN
       -- Only applicable for OBJECT classes! We should never get here.
       RETURN;
    END IF;

    lt_db_mapping:=Ec_Class_Cnfg.row_by_pk(p_class_name);

    Ecdp_Dynsql.AddSqlLine(lt_cursor_buffer, '  CURSOR c_object IS'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(lt_cursor_buffer, '    SELECT o.object_id, '''||p_class_name||''' AS class_name');

    lt_relation_list:=EcDp_ACL.GetRelations(null,p_class_name,null, null);--'TO_CLASS');
    FOR r IN 1..lt_relation_list.COUNT LOOP
        IF lt_relation_list(r).db_mapping_type='ATTRIBUTE' THEN
            Ecdp_Dynsql.AddSqlLine(lt_cursor_buffer, ', oa.'||lt_relation_list(r).db_sql_syntax);
        ELSIF lt_relation_list(r).db_mapping_type='COLUMN' THEN
            Ecdp_Dynsql.AddSqlLine(lt_cursor_buffer, ', o.'||lt_relation_list(r).db_sql_syntax);
        END IF;
    END LOOP;
    Ecdp_Dynsql.AddSqlLine(lt_cursor_buffer, CHR(10)||'    FROM '||lt_db_mapping.db_object_attribute||' oa, '||lt_db_mapping.db_object_name||' o'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(lt_cursor_buffer, '    WHERE oa.object_id = o.object_id'||CHR(10));
    Ecdp_Dynsql.AddSqlLine(lt_cursor_buffer, '    AND NVL(p_object_id,o.object_id)=o.object_id');

    IF lt_db_mapping.db_where_condition IS NOT NULL THEN
       Ecdp_Dynsql.AddSqlLine(lt_cursor_buffer, CHR(10)||'    AND '||lt_db_mapping.db_where_condition||';'||CHR(10));
    ELSE
       Ecdp_Dynsql.AddSqlLine(lt_cursor_buffer, ';'||CHR(10));
    END IF;

    Ecdp_Dynsql.AddSqlLine(p_header_buffer, 'PROCEDURE Cache(p_object_id VARCHAR2);'||CHR(10)||CHR(10));

    Ecdp_Dynsql.AddSqlLine(p_body_buffer,
      'PROCEDURE Cache(p_object_id VARCHAR2)'||CHR(10)
    ||'IS ' || CHR(10));

    Ecdp_Dynsql.AddSqlLines(p_body_buffer, lt_cursor_buffer);

    Ecdp_Dynsql.AddSqlLine(p_body_buffer, 'BEGIN'||CHR(10)
    ||'  -- Read all '||p_class_name||' objects.'||CHR(10)
    ||'  FOR c IN c_object LOOP'||CHR(10)
    ||'     EcDp_ACL.RegisterObject(c.object_id, c.class_name);'||CHR(10));

    FOR r IN 1..lt_relation_list.COUNT LOOP
        Ecdp_Dynsql.AddSqlLine(p_body_buffer,CHR(10)
        ||'     -- Register reference from '||p_class_name||' to '||lt_relation_list(r).from_class_name||'.'||CHR(10)
        ||'     IF c.'||lt_relation_list(r).db_sql_syntax||' IS NOT NULL THEN'||CHR(10)
        ||'        EcDp_ACL.RegisterObjectReference('||lt_relation_list(r).id||',c.'||lt_relation_list(r).db_sql_syntax||',c.object_id);'||CHR(10)
        ||'     END IF;'||CHR(10));
    END LOOP;
    Ecdp_Dynsql.AddSqlLine(p_body_buffer, CHR(10)
    ||'  END LOOP;'
    ||CHR(10));

    Ecdp_Dynsql.AddSqlLine(p_body_buffer, 'END Cache;'||CHR(10)||CHR(10));
END GenPopulateProc;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : GenPopulateWhereProc                                                         --
-- Description    : Generate PopulateWhere procedure headers and bodies for p_class_name.        --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
--<FUNC>
PROCEDURE GenPopulateWhereProc(
          p_header_buffer    IN OUT DBMS_SQL.varchar2a
,         p_body_buffer      IN OUT DBMS_SQL.varchar2a
,         p_class_name       IN VARCHAR2
,         p_class_type       IN VARCHAR2)
IS
--</FUNC>
--</EC-DOC>
  lt_relation_list EcDp_ACL.RelationL_t;
  lv_alias         VARCHAR2(2);
BEGIN
   IF p_class_type!='OBJECT' THEN
      -- Only applicable for OBJECT classes!
      RETURN;
   END IF;

   lt_relation_list:=EcDp_ACL.GetRelations(null,p_class_name,null,null);--'TO_CLASS');
   FOR r IN 1..lt_relation_list.COUNT LOOP
     lv_alias:='o';
     IF lt_relation_list(r).db_mapping_type='ATTRIBUTE' THEN
       lv_alias:='oa';
     END IF;

     Ecdp_Dynsql.AddSqlLine(p_header_buffer, 'PROCEDURE Cache_'||lt_relation_list(r).role_name||'(p_object_id VARCHAR2);'||CHR(10)||CHR(10));

     Ecdp_Dynsql.AddSqlLine(p_body_buffer,
       'PROCEDURE Cache_'||lt_relation_list(r).role_name||'(p_object_id VARCHAR2)'||CHR(10)
     ||'IS ' || CHR(10));

     EcDp_Dynsql.AddSqlLine(p_body_buffer,
       '  CURSOR c_'||LOWER(lt_relation_list(r).to_class_name)||' IS'||CHR(10)
     ||'    SELECT o.object_id, '''||UPPER(lt_relation_list(r).to_class_name)||''' AS class_name,'||lv_alias||'.'||lt_relation_list(r).db_sql_syntax||CHR(10)
     ||'    FROM '||lt_relation_list(r).db_object_attribute||' oa, '||lt_relation_list(r).db_object_name||' o'||CHR(10)
     ||'    WHERE oa.object_id = o.object_id'||CHR(10)
     ||'    AND '||lv_alias||'.'||lt_relation_list(r).db_sql_syntax||'=p_object_id;'||CHR(10));

     EcDp_Dynsql.AddSqlLine(p_body_buffer,
       'BEGIN'||CHR(10)
     ||'  FOR c IN c_'||LOWER(lt_relation_list(r).to_class_name)||' LOOP'||CHR(10)
     ||'     EcDp_ACL.RegisterObject(c.object_id, c.class_name);'||CHR(10)
     ||'     IF c.'||lt_relation_list(r).db_sql_syntax||' IS NOT NULL THEN'||CHR(10)
     ||'        EcDp_ACL.RegisterObjectReference('||lt_relation_list(r).id||',c.'||lt_relation_list(r).db_sql_syntax||',c.object_id);'||CHR(10)
     ||'     END IF;'||CHR(10)
     ||'   END LOOP;'||CHR(10)
     ||'END Cache_'||lt_relation_list(r).role_name||';'||CHR(10)||CHR(10));
   END LOOP;
END GenPopulateWhereProc;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : GenPackage                                                                   --
-- Description    : Generate DAC policy package for the given class. If p_class_name is null,    --
--                  generate policy packages for all ringfenced classes.                         --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
--<FUNC>
PROCEDURE GenPackage(p_class_name VARCHAR2)
IS
--</FUNC>
--</EC-DOC>
  header_lines     DBMS_SQL.varchar2a;
  body_lines       DBMS_SQL.varchar2a;
  lv_package_name  VARCHAR2(100);
BEGIN
  EcDp_ACL.RefreshRelations;
  FOR cur_class IN EcDp_ACL.c_acl_class(p_class_name) LOOP
    header_lines.DELETE;
    body_lines.DELETE;

    EcDp_DynSql.WriteTempText('GENCODEINFO','Generate policy package for '||cur_class.class_name);
    lv_package_name:='EcCp_' || cur_class.class_name;

    Ecdp_Dynsql.AddSqlLine(header_lines, 'CREATE OR REPLACE PACKAGE ' || lv_package_name || ' IS '|| CHR(10) );
    Ecdp_Dynsql.AddSqlLine(header_lines, '-- Generated by EcDp_DAC '||CHR(10));

    Ecdp_Dynsql.AddSqlLine(body_lines, 'CREATE OR REPLACE PACKAGE BODY ' || lv_package_name ||' IS '|| CHR(10) );
    Ecdp_Dynsql.AddSqlLine(body_lines, '-- Generated by EcDp_DAC '||CHR(10));

    IF cur_class.class_type='OBJECT' THEN
       GenPopulateProc(header_lines, body_lines, cur_class.class_name, cur_class.class_type);
       GenPopulateWhereProc(header_lines, body_lines, cur_class.class_name, cur_class.class_type);
    END IF;

    Ecdp_Dynsql.AddSqlLine(header_lines,'END ' || lv_package_name || ';' || CHR(10));
    Ecdp_Dynsql.AddSqlLine(body_lines,'END ' || lv_package_name || ';' || CHR(10));

    Ecdp_Dynsql.SafeBuild(lv_package_name,'PACKAGE',header_lines,'CREATE');
    Ecdp_Dynsql.SafeBuild(lv_package_name,'PACKAGE',body_lines,'CREATE');

  END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
        EcDp_DynSql.WriteTempText('GENCODEERROR','Syntax error generating policy package for '||p_class_name||CHR(10)||SQLERRM||CHR(10));
END GenPackage;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getReferenceDependencyClass                                                     --
-- Description    : get refence access controlled object class name                              --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
--<FUNC>
FUNCTION getReferenceDependencyClass(p_class_name VARCHAR2)
RETURN Varchar2 RESULT_CACHE
IS
--</FUNC>
--</EC-DOC>
  lv2_reference_dependency_class Varchar2(200);
BEGIN
    SELECT min(cd.parent_class)
    INTO lv2_reference_dependency_class
    FROM   class_dependency_cnfg cd
    ,      class_cnfg pc
    ,      class_cnfg cc
    WHERE  cd.dependency_type = 'ACCESS_CONTROLLED_BY'
    AND    cd.child_class = p_class_name
    AND    EcDp_ClassMeta_Cnfg.getAccessControlInd(pc.class_name) = 'Y'
    AND    EcDp_ClassMeta_Cnfg.getAccessControlInd(cc.class_name) = 'Y'
    AND    cd.parent_class = pc.class_name
    AND    pc.class_type = 'OBJECT'
    AND    cd.child_class = cc.class_name
    AND    cc.class_type = 'OBJECT';

   RETURN lv2_reference_dependency_class;
END getReferenceDependencyClass;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getPolicyPredicate                                                           --
-- Description    : get policy predicate for the given class name and column name.               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
--<FUNC>
FUNCTION getPolicyPredicate(p_class_name IN VARCHAR2, p_column__name IN VARCHAR2)
RETURN VARCHAR2
IS
--</FUNC>
--</EC-DOC>
  lv_predicate VARCHAR2(4000);
  lv_db_users  VARCHAR2(200);
BEGIN
   lv_db_users := '''' || lv_schema_name || '''';
   lv_predicate :=
   '((exists ( select 1'
   ||' from acl_objects acl'
   ||' where acl.class_name = ''' ||  p_class_name || ''''
   ||' and EcDp_Context.isAppUserRole(acl.role_id) = 1'
   ||' and ' || p_column__name || '_id = acl.object_id))'
-- WST specific override  Jira UPGCVX-2478 ---------------------------------------------
-- ||' OR ( EcDp_Context.getAppUser IS NULL AND USER IN (' || lv_db_users || ')))';
   ||' OR ( USER IN (' || lv_db_users || ',''BTUSER_WST'',''BTUSER_PT_WST'',''BIQRYUSER_WST'',''BTUSER_SIT'',''BTUSER_PT_SIT'',''BIQRYUSER_SIT'')))';

   Return lv_predicate;
END getPolicyPredicate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getAccessControlPredicate                                                    --
-- Description    : get policy predicate of Access Control for the given class type and name.    --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
--<FUNC>
FUNCTION getAccessControlPredicate(p_class_type VARCHAR2, p_class_name VARCHAR2)
RETURN VARCHAR2
IS
--</FUNC>
--</EC-DOC>
  CURSOR c_acl_relations IS
     SELECT r.from_class_name
     ,      r.to_class_name
     ,      r.role_name
     ,      t.db_object_name as to_class_db_object_name
     FROM   class_relation_cnfg r
     ,      class_cnfg f
     ,      class_cnfg t
     WHERE  EcDp_ClassMeta_Cnfg.getAccessControlInd(r.from_class_name) = 'Y'
     AND    EcDp_ClassMeta_Cnfg.getAccessControlMethod(r.from_class_name, r.to_class_name, r.role_name) = 'ACL_LOOKUP'
     AND    r.from_class_name = f.class_name
     AND    r.to_class_name = p_class_name
     AND    t.class_name = p_class_name
     AND    (f.class_type = 'OBJECT' OR f.class_type = 'INTERFACE')
     AND    (t.class_type = 'DATA' OR t.class_type = 'TABLE')
     AND    (NVL(r.is_key, 'N') = 'Y' OR NVL(EcDp_ClassMeta_Cnfg.isReportOnly(r.from_class_name, r.to_class_name, r.role_name), 'N') = 'N')
     AND    NVL(r.db_mapping_type,'FUNCTION') IN ('ATTRIBUTE','COLUMN');

  lv2_predicate Varchar2(2000);
  lv2_reference_dependency_class Varchar2(32);
  lr_class CLASS_CNFG%ROWTYPE;
  lr_owner_class CLASS_CNFG%ROWTYPE;
BEGIN
  IF p_class_type = 'OBJECT' THEN
     lv2_reference_dependency_class := getReferenceDependencyClass(p_class_name);
     -- reference object class access controled, higher priority
     IF lv2_reference_dependency_class IS NOT NULL THEN
       lv2_predicate := getPolicyPredicate(lv2_reference_dependency_class, 'o.object');
     -- direct object class access controled
     ELSIF EcDp_ClassMeta_Cnfg.getAccessControlInd(p_class_name) = 'Y' THEN
       lv2_predicate := getPolicyPredicate(p_class_name, 'o.object');
     END IF;
  ELSIF p_class_type = 'DATA' OR p_class_type = 'TABLE' THEN
    lr_class := Ec_Class_Cnfg.row_by_pk(p_class_name);
    lr_owner_class := Ec_Class_Cnfg.row_by_pk(lr_class.owner_class_name);

    -- owner class access control for data class
    IF p_class_type = 'DATA' AND (lr_owner_class.class_type = 'OBJECT' OR lr_owner_class.class_type = 'INTERFACE') AND EcDp_ClassMeta_Cnfg.getAccessControlInd(lr_owner_class.class_name) = 'Y' THEN
      lv2_predicate := getPolicyPredicate(lr_class.owner_class_name, lr_class.db_object_name || '.object');
    END IF;

    -- acl_lookup relational access control for data class and table class
    FOR rel IN c_acl_relations LOOP
      IF lv2_predicate IS NOT NULL THEN
        lv2_predicate := lv2_predicate || ' AND ' || getPolicyPredicate(rel.from_class_name, rel.to_class_db_object_name || '.' || rel.role_name);
      ELSE
        lv2_predicate := getPolicyPredicate(rel.from_class_name, rel.to_class_db_object_name || '.' || rel.role_name);
      END IF;
    END LOOP;
  END IF;
  RETURN lv2_predicate;
END getAccessControlPredicate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : activeObjectPartitioningCheck                                                  --
-- Description    : check the value of active object partitioning indicator for the given class  --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
--<FUNC>
Procedure activeObjectPartitioningCheck(p_t_basis_access_id VARCHAR2)
IS
--</FUNC>
--</EC-DOC>
lv2_classname VARCHAR2(100);
BEGIN
    select bo.object_name
    into lv2_classname
    from t_basis_object bo, t_basis_access ba
    where bo.object_type = 'CLASS'
    and bo.object_id = ba.object_id
    and ba.t_basis_access_id = p_t_basis_access_id;

    IF lv2_classname is NOT NULL and EcDp_ClassMeta_Cnfg.getAccessControlInd(lv2_classname) = 'N' THEN
      raise_application_error(
        -20002,
        'Cannot INSERT object partitioning '
        || 'because the active object partitioning indicator (access_control_ind on class property) of '
        || lv2_classname || ' class either does not exist or is not set to ''Y''.'
      );
    END IF;
END activeObjectPartitioningCheck;

END EcDp_DAC;
--</PACKAGE>
/
