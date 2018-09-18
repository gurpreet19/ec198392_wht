CREATE OR REPLACE PACKAGE BODY EcDp_VPD IS
--<HEAD>
/****************************************************************
** Package        :  EcDp_VPD, body part
**
** $Revision: 1.13 $
**
** Purpose        :  VPD
**
** Documentation  :  www.energy-components.com
**
** Created  : 13-Mar-2007, Hanne Austad
**
** Modification history:
**
**  Date           Whom  Change description:
**  ------         ----- --------------------------------------
**  13-Mar-2007    HUS   Initial version
****************************************************************/
--</HEAD>

  lv_schema_name VARCHAR2(30):=EcDp_ClassMeta.GetSchemaName;

  CURSOR c_policy(p_object_name VARCHAR2) IS
    SELECT *
    FROM   user_policies
    WHERE  NVL(p_object_name,object_name)=object_name
    ORDER BY object_name;

  CURSOR c_view(p_view_name VARCHAR2) IS
    SELECT *
    FROM   user_views
    WHERE  view_name=p_view_name
    ORDER BY view_name;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : DropPolicies                                                                 --
-- Description    : Drop RLS policies for p_class_name. If p_class_name is null, drop all RLS    --
--                  policies. INTERFACES have no policies. The IV views select from the          --
--                  implementing OVs and consequently "inherit" their policies.                  --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   : None                                                                         --
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
PROCEDURE DropPolicies(p_class_name VARCHAR2)
IS
--</FUNC>
--</EC-DOC>
  lv_class_type VARCHAR2(32);

  -- Find the secondary classes for the input primary class
  CURSOR c_secondary_class(p_class_name VARCHAR2) IS
    SELECT cc.*
    FROM   class_dependency cd
    ,      class pc
    ,      class cc
    WHERE  cd.parent_class=p_class_name
    AND    cd.dependency_type='ACCESS_CONTROLLED_BY'
    AND    cd.parent_class=pc.class_name
    AND    pc.class_type='OBJECT'
    AND    cd.child_class=cc.class_name
    AND    cc.class_type='OBJECT';

BEGIN
  IF p_class_name IS NULL THEN
    -- Drop all policies
    FOR cur_policy in c_policy(null) LOOP
       dbms_rls.drop_policy(lv_schema_name,cur_policy.object_name,cur_policy.policy_name);
    END LOOP;
  ELSE
    -- Drop policies for given class
    lv_class_type:=Ec_Class.class_type(p_class_name);
    IF lv_class_type='DATA' THEN
       FOR cur_policy in c_policy('DV_'||p_class_name) LOOP
           dbms_rls.drop_policy(lv_schema_name,cur_policy.object_name,cur_policy.policy_name);
       END LOOP;
       FOR cur_policy in c_policy('RV_'||p_class_name) LOOP
          dbms_rls.drop_policy(lv_schema_name,cur_policy.object_name,cur_policy.policy_name);
       END LOOP;
    ELSIF lv_class_type='OBJECT' THEN
       FOR cur_policy in c_policy('OV_'||p_class_name) LOOP
           dbms_rls.drop_policy(lv_schema_name,cur_policy.object_name,cur_policy.policy_name);
       END LOOP;
       FOR cur_policy in c_policy('RV_'||p_class_name) LOOP
          dbms_rls.drop_policy(lv_schema_name,cur_policy.object_name,cur_policy.policy_name);
       END LOOP;
       -- If the input class is a primary class, drop policies from secondary classes as well!
       FOR cur_class IN c_secondary_class(p_class_name) LOOP
          FOR cur_policy in c_policy('OV_'||cur_class.class_name) LOOP
              dbms_rls.drop_policy(lv_schema_name,cur_policy.object_name,cur_policy.policy_name);
          END LOOP;
          FOR cur_policy in c_policy('RV_'||cur_class.class_name) LOOP
             dbms_rls.drop_policy(lv_schema_name,cur_policy.object_name,cur_policy.policy_name);
          END LOOP;
       END LOOP;
    END IF;
  END IF;
END DropPolicies;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : GetViewName                                                                  --
-- Description    : Takes a view name as input. Returns the view name is if view does not exist. --
--                  Otherwise returns NULL.                                                      --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   : None                                                                         --
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
FUNCTION GetViewName(p_view_name VARCHAR2)
RETURN VARCHAR2
IS
  lv_view_name VARCHAR2(30):=NULL;
BEGIN
     FOR cur_rec IN c_view(UPPER(p_view_name)) LOOP
         lv_view_name:=cur_rec.view_name;
         EXIT WHEN lv_view_name IS NOT NULL;
     END LOOP;
     RETURN lv_view_name;
END GetViewName;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : GetFunctionName                                                              --
-- Description    : Takes a package name and a procedure/function name as inputs.                --
--                  Returns <package name>.<procedure/function name> if the procedure/function   --
--                  exists. Otherwise returns NULL.                                              --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   : None                                                                         --
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
FUNCTION GetFunctionName(p_object_name VARCHAR2, p_procedure_name VARCHAR2)
RETURN VARCHAR2
IS
  lv2_signature VARCHAR2(100) := NULL;

  CURSOR c_procedure(p_object_name VARCHAR2, p_procedure_name VARCHAR2) IS
    SELECT *
    FROM   user_procedures p
    WHERE  p.object_name=Upper(p_object_name)
    AND    p.procedure_name=Upper(p_procedure_name);
BEGIN
  FOR cur_proc IN c_procedure(p_object_name, p_procedure_name) LOOP
     lv2_signature := p_object_name||'.'||p_procedure_name;
     EXIT WHEN lv2_signature IS NOT NULL;
  END LOOP;
  RETURN lv2_signature;
END GetFunctionName;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : AddPolicies                                                                  --
-- Description    : Add RLS policies for p_class_name. p_class_name must be an OBJECT or a DATA  --
--                  class.                                                                       --
--                                                                                               --
--                  NOTE: No policies should be added for interfaces. The IV views select from   --
--                  the implementing OVs, and consequently "inherit" the policies from the OVs.  --
--                                                                                               --
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
PROCEDURE AddPolicies(p_class_name VARCHAR2)
IS
--</FUNC>
--</EC-DOC>
  lr_class CLASS%ROWTYPE;
  lr_owner_class CLASS%ROWTYPE;

  lr_rv_view VARCHAR2(30):=NULL;
  lr_dv_view VARCHAR2(30):=NULL;
  lr_ov_view VARCHAR2(30):=NULL;

  lt_relation_list EcDp_ACL.RelationL_t;
BEGIN
  lr_class:=Ec_Class.row_by_pk(p_class_name);

  lr_rv_view:=GetViewName('RV_'||lr_class.class_name);
  IF lr_class.class_type='DATA' THEN
     lr_dv_view:=GetViewName('DV_'||lr_class.class_name);
  ELSIF lr_class.class_type='OBJECT' THEN
     lr_ov_view:=GetViewName('OV_'||lr_class.class_name);
  END IF;

  IF lr_class.class_type='DATA' THEN
     lr_owner_class:=Ec_Class.row_by_pk(lr_class.owner_class_name);
     IF (lr_owner_class.class_type='OBJECT' OR lr_owner_class.class_type='INTERFACE') AND NVL(lr_owner_class.access_control_ind,'N')='Y' THEN
        -- DATA class with access controlled owner. Add policy to OBJECT_ID.
        IF lr_dv_view IS NOT NULL THEN
          dbms_rls.add_policy(lv_schema_name,
                              lr_dv_view,
                              'SEL_OBJECT_ID',
                              lv_schema_name,
                              'eccp_'||lr_class.class_name||'.object_id',
                              'select,update,delete',
                              true,
                              true,
                              FALSE);
        END IF;
        IF lr_rv_view IS NOT NULL THEN
          dbms_rls.add_policy(lv_schema_name,
                              lr_rv_view,
                              'SEL_OBJECT_ID',
                              lv_schema_name,
                              'eccp_'||lr_class.class_name||'.object_id',
                              'select',
                              true,
                              true,
                              FALSE);
        END IF;
     END IF;
     -- Loop over all access controlled relations where this DATA class is the TO-class.
     lt_relation_list:=EcDp_ACL.GetRelations(null,p_class_name,null,'ACL_LOOKUP');
     FOR r IN 1..lt_relation_list.COUNT LOOP
         IF lr_dv_view IS NOT NULL THEN
            -- Apply policy to the access controlled "foreign key", unless it is flagged as report-only.
            IF NVL(lt_relation_list(r).is_key,'N')='Y' THEN
              -- If the "foreign key" is a part of the PK, apply the policy for select, update and delete.
              dbms_rls.add_policy(lv_schema_name,
                                  lr_dv_view,
                                  'SEL_'||UPPER(lt_relation_list(r).db_sql_syntax),
                                  lv_schema_name,
                                  'eccp_'||lr_class.class_name||'.'||lower(lt_relation_list(r).role_name)||'_id',
                                  'select,update,delete',
                                  true,
                                  true,
                                  FALSE);
            ELSIF NVL(lt_relation_list(r).report_only_ind,'N')='N' THEN
              -- If the "foreign key" is not part of the PK, apply the policy for select only.
              dbms_rls.add_policy(lv_schema_name,
                                  lr_dv_view,
                                  'SEL_'||UPPER(lt_relation_list(r).db_sql_syntax),
                                  lv_schema_name,
                                  'eccp_'||lr_class.class_name||'.'||lower(lt_relation_list(r).role_name)||'_id',
                                  'select',
                                  true,
                                  true,
                                  FALSE);
            END IF;
         END IF;
         IF lr_rv_view IS NOT NULL THEN
            -- Apply policy to the access controlled "foreign key".
           dbms_rls.add_policy(lv_schema_name,
                               lr_rv_view,
                               'SEL_'||UPPER(lt_relation_list(r).db_sql_syntax),
                               lv_schema_name,
                               'eccp_'||lr_class.class_name||'.'||lower(lt_relation_list(r).role_name)||'_id',
                               'select',
                               true,
                               true,
                               FALSE);
         END IF;
     END LOOP;
  ELSIF lr_class.class_type='OBJECT' AND NVL(lr_class.access_control_ind,'N')='Y' THEN
     -- Apply policy on OBJECT_ID
     IF lr_ov_view IS NOT NULL THEN
       dbms_rls.add_policy(lv_schema_name,
                           lr_ov_view,
                           'SEL_OBJECT_ID',
                           lv_schema_name,
                           'eccp_'||lr_class.class_name||'.object_id',
                           'select,update,delete',
                           true,
                           true,
                           FALSE);
     END IF;
     IF lr_rv_view IS NOT NULL THEN
       dbms_rls.add_policy(lv_schema_name,
                           lr_rv_view,
                           'SEL_OBJECT_ID',
                           lv_schema_name,
                           'eccp_'||lr_class.class_name||'.object_id',
                           'select',
                           true,
                           true,
                           FALSE);
     END IF;
  END IF;
END AddPolicies;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : AddSecondaryClassPolicies                                                    --
-- Description    : Add given RLS policy function to the given secondary class views.            --
--                                                                                               --
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
PROCEDURE AddSecondaryClassPolicies(p_secondary_class VARCHAR2, p_policy_fn_name VARCHAR2)
IS
--</FUNC>
--</EC-DOC>
  lr_rv_view VARCHAR2(30):=NULL;
  lr_ov_view VARCHAR2(30):=NULL;

BEGIN
  IF p_policy_fn_name IS NOT NULL THEN
    lr_rv_view:=GetViewName('RV_'||p_secondary_class);
    lr_ov_view:=GetViewName('OV_'||p_secondary_class);

    -- Apply policy on OBJECT_ID
    IF lr_ov_view IS NOT NULL THEN
       dbms_rls.add_policy(lv_schema_name,
                           lr_ov_view,
                           'SEL_OBJECT_ID',
                           lv_schema_name,
                           p_policy_fn_name,
                           'select,update,delete',
                           true,
                           true,
                           FALSE);
    END IF;
    IF lr_rv_view IS NOT NULL THEN
       dbms_rls.add_policy(lv_schema_name,
                           lr_rv_view,
                           'SEL_OBJECT_ID',
                           lv_schema_name,
                           p_policy_fn_name,
                           'select',
                           true,
                           true,
                           FALSE);
    END IF;
  END IF;
END AddSecondaryClassPolicies;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : GenPolicyFunc                                                                --
-- Description    : Generate policy function header and body.                                    --
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
PROCEDURE GenPolicyFunc(
          p_header_buffer    IN OUT DBMS_SQL.varchar2a
,         p_body_buffer      IN OUT DBMS_SQL.varchar2a
,         p_class_name       IN VARCHAR2
,         p_db_sql_syntax    IN VARCHAR2
,         p_mandatory        IN BOOLEAN)
IS
--</FUNC>
--</EC-DOC>
  lv_fname     VARCHAR2(50);
  lv_body      VARCHAR2(4000);
  lv_predicate VARCHAR2(4000);
  lv_db_users  VARCHAR2(200);
  lv_namespace VARCHAR2(30):=EcDp_Context.getSessionContextName;
BEGIN
     Ecdp_Dynsql.AddSqlLine(p_header_buffer, 'FUNCTION '||LOWER(p_db_sql_syntax)||'(p_object_owner VARCHAR2, p_object_name  VARCHAR2)' || CHR(10) || 'RETURN VARCHAR2;' || CHR(10) || CHR(10));

     lv_db_users:=''''''||lv_schema_name||'''''';
     lv_predicate:='sys_context('''''||lv_namespace||''''', ''''USER_ID'''')' || ' IS NULL AND USER IN (' ||lv_db_users || ') OR ';
     IF p_mandatory=false THEN
        lv_predicate:=lv_predicate || p_db_sql_syntax || ' is null OR ';
     END IF;
     lv_predicate:=lv_predicate
     ||'exists (select 1 '
     ||'from acl_objects '
     ||'where ''||p_object_name||''.' || p_db_sql_syntax ||' = acl_objects.object_id '
     ||'and acl_objects.class_name = ''' || '''' || p_class_name || '''' || '''' || ' '
     ||'and acl_objects.role_id in ('
		 ||'sys_context('''''||lv_namespace||''''', ''''ROLE_1'''')';
     FOR n IN 2..Ecdp_Context.getMaxRoleCount LOOP
         lv_predicate:=lv_predicate
		     ||            ',sys_context('''''||lv_namespace||''''', ''''ROLE_'||n||''''')';
     END LOOP;
     lv_predicate:=lv_predicate||'))';

     lv_fname:=LOWER(p_db_sql_syntax);
     lv_body:=lv_body||'FUNCTION '||lv_fname||'(p_object_owner VARCHAR2, p_object_name  VARCHAR2)' || CHR(10) || 'RETURN VARCHAR2' || CHR(10);
     lv_body:=lv_body||'IS ' || CHR(10);
     lv_body:=lv_body||'BEGIN ' || CHR(10);
     lv_body:=lv_body||'   RETURN '''|| lv_predicate || '''' ||';'  || CHR(10);
     lv_body:=lv_body||'END ' || lv_fname || ';' || CHR(10) || CHR(10);

     Ecdp_Dynsql.AddSqlLine(p_body_buffer, lv_body);
END GenPolicyFunc;

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
  --lv_body_lines    VARCHAR2(4000):='';
  lt_db_mapping    class_db_mapping%ROWTYPE;
  lt_cursor_buffer DBMS_SQL.varchar2a;
  lt_relation_list EcDp_ACL.RelationL_t;
BEGIN
    IF p_class_type!='OBJECT' THEN
       -- Only applicable for OBJECT classes! We should never get here.
       RETURN;
    END IF;

    lt_db_mapping:=Ec_Class_Db_Mapping.row_by_pk(p_class_name);

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
-- Description    : Generate RLS policy package for the given class. If p_class_name is null,    --
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
  lt_relation_list EcDp_ACL.RelationL_t;
BEGIN
  EcDp_ACL.RefreshRelations;
  FOR cur_class IN EcDp_ACL.c_acl_class(p_class_name) LOOP
    header_lines.DELETE;
    body_lines.DELETE;

    EcDp_DynSql.WriteTempText('GENCODEINFO','Generate policy package for '||cur_class.class_name);
    lv_package_name:='EcCp_' || cur_class.class_name;

    Ecdp_Dynsql.AddSqlLine(header_lines, 'CREATE OR REPLACE PACKAGE ' || lv_package_name || ' IS '|| CHR(10) );
    Ecdp_Dynsql.AddSqlLine(header_lines, '-- Generated by EcDp_VPD '||CHR(10));

    Ecdp_Dynsql.AddSqlLine(body_lines, 'CREATE OR REPLACE PACKAGE BODY ' || lv_package_name ||' IS '|| CHR(10) );
    Ecdp_Dynsql.AddSqlLine(body_lines, '-- Generated by EcDp_VPD '||CHR(10));

    IF cur_class.class_type='OBJECT' THEN
       GenPolicyFunc(header_lines, body_lines, cur_class.class_name, 'OBJECT_ID', TRUE);
       GenPopulateProc(header_lines, body_lines, cur_class.class_name, cur_class.class_type);
       GenPopulateWhereProc(header_lines, body_lines, cur_class.class_name, cur_class.class_type);
    ELSIF cur_class.class_type='INTERFACE' THEN
       -- No populate procs for interfaces. Handled by the implementing classes' populate procs.
       GenPolicyFunc(header_lines, body_lines, cur_class.class_name, 'OBJECT_ID', TRUE);
    ELSIF cur_class.class_type='DATA' THEN
       GenPolicyFunc(header_lines, body_lines, cur_class.owner_class_name, 'OBJECT_ID', TRUE);
       lt_relation_list:=EcDp_ACL.GetRelations(null,cur_class.class_name,null,'ACL_LOOKUP');
       FOR r IN 1..lt_relation_list.COUNT LOOP
          -- Declare reference object ringfencing functions
          GenPolicyFunc(header_lines, body_lines, lt_relation_list(r).from_class_name, lt_relation_list(r).role_name||'_ID', NVL(lt_relation_list(r).is_mandatory,'N')='Y');
       END LOOP;
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
-- function       : RefreshPolicies                                                              --
-- Description    : Refresh RLS policies for the given class.                                    --
--                  Drop and add RLS given class. If p_class_name is null, all RLS policies for  --
--                  the schema will be dropped, and new policies will be added for "ringfenced"  --
--                  classes.                                                                     --
--                                                                                               --
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
PROCEDURE RefreshPolicies(p_class_name VARCHAR2)
IS
--</FUNC>
--</EC-DOC>
  -- Find secondary classes for the input class:
  --      If input class is secondary, return that class
  --      If input class is primary, return all its secondaries
  --      If input class is null, return all secondaries
  CURSOR c_secondary_class(p_class_name VARCHAR2) IS
    SELECT cd.child_class AS secondary_class
    ,      cd.parent_class AS primary_class
    FROM   class_dependency cd
    ,      class pc
    ,      class cc
    WHERE  cd.dependency_type='ACCESS_CONTROLLED_BY'
    AND    cd.parent_class=pc.class_name
    AND    pc.class_type='OBJECT'
    AND    cd.child_class=cc.class_name
    AND    cc.class_type='OBJECT'
    AND    Nvl(pc.access_control_ind,'N')='Y'
    AND    Nvl(cc.access_control_ind,'N')='N'
    AND   (cd.parent_class=Nvl(p_class_name,cd.parent_class) OR cd.child_class=Nvl(p_class_name,cd.child_class));

  lv2_policy_fn_name VARCHAR2(100) := NULL;
BEGIN
   EcDp_ACL.RefreshRelations;

   -- Drop RLS policies for p_class_name. If p_class_name is null, ALL RLS policies will be dropped
   DropPolicies(p_class_name);

   -- Add RLS policies for p_class_name. If p_class_name is null, RLS policies will be added for
   -- all ringfenced classes. If p_class_name is not a ringfenced class, the cursor will return
   -- no records. Thus, secondary classes are not processed by this loop.
   FOR cur_class IN EcDp_ACL.c_acl_class(p_class_name) LOOP
      AddPolicies(cur_class.class_name);
   END LOOP;

   -- Add secondary class policies. The secondary classes "inherit" their polify function from
   -- the primary class. In situations where the primary class is generated AFTER the secondary
   -- class, the primary class policy package may not exist. Thus need to check that the function
   -- exists before adding it to the secondary class views.
   FOR cur_class_dependency IN c_secondary_class(p_class_name) LOOP
      lv2_policy_fn_name := GetFunctionName('ECCP_'||cur_class_dependency.primary_class, 'OBJECT_ID');
      IF lv2_policy_fn_name IS NOT NULL THEN
        AddSecondaryClassPolicies(cur_class_dependency.secondary_class, lv2_policy_fn_name);
      END IF;
   END LOOP;
END RefreshPolicies;

FUNCTION hasUserAccess(p_object_id VARCHAR2)
RETURN VARCHAR2 -- Returns 'Y' if user has access and 'N' if not
IS

CURSOR c_class(cp_object_id VARCHAR2)
IS
SELECT
NVL(c.access_control_ind, 'N') access_control_ind
,class_name
FROM class c
WHERE c.class_name = Ecdp_Objects.GetObjClassName(cp_object_id);

CURSOR c_access(cp_object_id VARCHAR2, cp_class_name VARCHAR2, cp_kernel_user VARCHAR2, cp_userrole VARCHAR2)
IS
SELECT
'Y' res
FROM dual
WHERE
sys_context(cp_userrole, 'USER_ID') IS NULL
AND USER = cp_kernel_user
OR EXISTS (select 1 from acl_objects where cp_object_id = acl_objects.object_id
AND acl_objects.class_name = cp_class_name
AND acl_objects.role_id IN
    (sys_context(cp_userrole, 'ROLE_1')
    ,sys_context(cp_userrole, 'ROLE_2')
    ,sys_context(cp_userrole, 'ROLE_3')
    ,sys_context(cp_userrole, 'ROLE_4')
    ,sys_context(cp_userrole, 'ROLE_5')
    ,sys_context(cp_userrole, 'ROLE_6')
    ,sys_context(cp_userrole, 'ROLE_7')
    ,sys_context(cp_userrole, 'ROLE_8')
    ,sys_context(cp_userrole, 'ROLE_9')
    ,sys_context(cp_userrole, 'ROLE_10')))
;

lv2_access VARCHAR2(1):= 'N';

lv2_ringfencing_enabled VARCHAR2(1) := 'N';
lv2_class_name VARCHAR2(32);
lv2_operation VARCHAR2(32);
lv2_kernel_user VARCHAR2(32);
lv2_userrole VARCHAR2(32);

BEGIN
    -- Verify whether ringfencing is enabled for the class
    FOR curClass IN c_class(p_object_id) LOOP
        lv2_class_name := curClass.class_name;
        IF (curClass.access_control_ind = 'Y') THEN
            lv2_ringfencing_enabled := 'Y';
        END IF;
    END LOOP;

    IF (lv2_ringfencing_enabled = 'N') THEN
        RETURN 'Y'; -- Ringfencing disabled for this object return positive access
    END IF;

    lv2_operation := ec_t_preferanse.pref_verdi('OPERATION');
    lv2_kernel_user := 'ECKERNEL_' || lv2_operation;
    lv2_userrole := 'ECSC_USERROLES_' || lv2_operation;

    FOR curAccess IN c_access(p_object_id, lv2_class_name, lv2_kernel_user, lv2_userrole) LOOP
        lv2_access := curAccess.res;
    END LOOP;

    RETURN lv2_access;
END hasUserAccess;

END EcDp_VPD;
--</PACKAGE>