CREATE OR REPLACE PACKAGE BODY EcDp_Objects_Check IS
/****************************************************************
** Package        :  EcDp_Objects_Check, header part
**
** $Revision: 1.3 $
**
** Purpose        :  Generate code for checks in ECTP packages, used by EcDp_genclasscode.
**
** Documentation  :  www.energy-components.com
**
** Created  : 01.03.2007  Arild Vervik
**
** Modification history:
**

** Date     Whom   Change description:
** -------- ------ ------ --------------------------------------
** 13.04.07 Nazli  ECPD-5323 Added Nvl(c.read_only_ind,'N') = 'N' union for All classes owned by p_class_name AddChildEndDateCursor (line 55)
*****************************************************************/



PROCEDURE AddChildEndDateCursor(p_body_lines in out DBMS_SQL.varchar2a,
                                p_class_name VARCHAR2,
                                p_union_count in out NUMBER,
                                p_recursive_level IN NUMBER,
                                p_count IN OUT NUMBER )
is

CURSOR c_owned_by IS
   -- At the moment this check is only handling classes where the underlying table have columns END_DATE or DAYTIME
	 -- All classes owned by p_class_name
    SELECT c.class_name, c.class_type, cd.DB_OBJECT_OWNER, cd.DB_OBJECT_NAME,  cd.DB_WHERE_CONDITION , 'OBJECT_ID' DB_SQL_SYNTAX,
           cas.db_sql_syntax start_date_column, cae.db_sql_syntax end_date_column
    FROM class c, class_db_mapping cd, class_attr_db_mapping cas, class_attr_db_mapping cae
    WHERE c.class_name  = cd.class_name
    AND   c.owner_class_name = p_class_name
    AND   c.class_name = cas.class_name
    AND   cas.db_sql_syntax IN ('DAYTIME','FROM_DATE','START_DATE')
    AND   c.class_name = cae.class_name
    AND   cae.db_sql_syntax IN ('END_DATE','TO_DAYTIME','TO_DATE')
    AND   Nvl(c.read_only_ind,'N') = 'N'
    AND  EXISTS( SELECT 1 FROM all_tab_columns c
                 WHERE c.owner = cd.DB_OBJECT_OWNER
                 AND c.table_name = cd.DB_OBJECT_NAME
                 AND c.column_name = 'OBJECT_ID')
    UNION ALL
    SELECT c.class_name, c.class_type, cd.DB_OBJECT_OWNER, cd.DB_OBJECT_NAME,  cd.DB_WHERE_CONDITION , 'OBJECT_ID' DB_SQL_SYNTAX,
           cas.db_sql_syntax start_date_column, 'TO_DATE(NULL)' end_date_column
    FROM class c, class_db_mapping cd, class_attr_db_mapping cas
    WHERE c.class_name  = cd.class_name
    AND   c.owner_class_name = p_class_name
    AND   c.class_name = cas.class_name
    AND   cas.db_sql_syntax IN ('DAYTIME','FROM_DATE','START_DATE')
    AND   Nvl(c.read_only_ind,'N') = 'N'
    AND  NOT EXISTS( SELECT 1 FROM all_tab_columns c
                 WHERE c.owner = cd.DB_OBJECT_OWNER
                 AND c.table_name = cd.DB_OBJECT_NAME
                 AND c.column_name IN ('END_DATE','TO_DAYTIME','TO_DATE'))
    AND  EXISTS( SELECT 1 FROM all_tab_columns c
                 WHERE c.owner = cd.DB_OBJECT_OWNER
                 AND c.table_name = cd.DB_OBJECT_NAME
                 AND c.column_name = 'OBJECT_ID')
    UNION ALL
    --ORDER BY 1; CURSOR c_referenced_by IS
    -- All data classes with a relation to p_class_name
    SELECT cr.to_class_name class_name, c.class_type, cd.DB_OBJECT_OWNER, cd.DB_OBJECT_NAME,  cd.DB_WHERE_CONDITION , cr.DB_SQL_SYNTAX,
           cas.db_sql_syntax start_date_column, cae.db_sql_syntax end_date_column
    FROM class_rel_db_mapping cr, class_db_mapping cd, class c, class_attr_db_mapping cas, class_attr_db_mapping cae
    WHERE cr.to_class_name = c.class_name
    AND   cr.to_class_name = cd.class_name
    AND   cr.from_class_name = p_class_name
    AND   c.class_type = 'DATA'
    AND   c.class_name = cas.class_name
    AND   cas.db_sql_syntax IN ('DAYTIME','FROM_DATE','START_DATE')
    AND   c.class_name = cae.class_name
    AND   cae.db_sql_syntax IN ('END_DATE','TO_DAYTIME','TO_DATE')
    AND   Nvl(c.read_only_ind,'N') = 'N'
    UNION ALL
    SELECT cr.to_class_name class_name, c.class_type, cd.DB_OBJECT_OWNER, cd.DB_OBJECT_NAME,  cd.DB_WHERE_CONDITION , cr.DB_SQL_SYNTAX,
           cas.db_sql_syntax start_date_column, 'TO_DATE(NULL)' end_date_column
    FROM class_rel_db_mapping cr, class_db_mapping cd, class c, class_attr_db_mapping cas
    WHERE cr.to_class_name = c.class_name
    AND   cr.to_class_name = cd.class_name
    AND   cr.from_class_name = p_class_name
    AND   c.class_type = 'DATA'
    AND   c.class_name = cas.class_name
    AND   cas.db_sql_syntax IN ('DAYTIME','FROM_DATE','START_DATE')
    AND  NOT EXISTS( SELECT 1 FROM all_tab_columns c
                 WHERE c.owner = cd.DB_OBJECT_OWNER
                 AND c.table_name = cd.DB_OBJECT_NAME
                 AND c.column_name IN ('END_DATE','TO_DAYTIME','TO_DATE'))
    AND   Nvl(c.read_only_ind,'N') = 'N'
    UNION ALL
    -- All object classes with a non versioned relation to p_class_name
    SELECT db.class_name class_name, c.class_type, db.DB_OBJECT_OWNER, db.DB_OBJECT_NAME,  db.DB_WHERE_CONDITION , cr.DB_SQL_SYNTAX,
           'START_DATE' start_date_column, 'END_DATE' end_date_column
    FROM class_rel_db_mapping cr, class_db_mapping db, class c
    WHERE cr.to_class_name = c.class_name
    AND   cr.to_class_name = db.class_name
    AND   cr.from_class_name = p_class_name
    AND   c.class_type = 'OBJECT'
    AND   cr.db_mapping_type = 'COLUMN'
    AND   Nvl(c.read_only_ind,'N') = 'N'
    UNION ALL
    -- All object classes with a versioned relation/group relation to p_class_name
    SELECT db.class_name, c.class_type, db.db_object_owner, db.db_object_attribute db_object_name, db.db_where_condition, cr.db_sql_syntax,
           'DAYTIME' start_date_column, 'END_DATE' end_date_column
    FROM class_rel_db_mapping cr, class c, class_db_mapping db
    WHERE cr.to_class_name = c.class_name
    AND   cr.to_class_name = db.class_name
    AND   cr.from_class_name = p_class_name
    AND   c.class_type = 'OBJECT'
    AND   cr.db_mapping_type = 'ATTRIBUTE'
    AND   Nvl(c.read_only_ind,'N') = 'N'
    UNION ALL
    -- All data classes owned by interfaces used by this class having end_date column
    SELECT c.class_name, c.class_type, cd.DB_OBJECT_OWNER, cd.DB_OBJECT_NAME,  cd.DB_WHERE_CONDITION , 'OBJECT_ID' DB_SQL_SYNTAX,
              cas.db_sql_syntax start_date_column, cae.db_sql_syntax end_date_column
    FROM class c, class_db_mapping cd, class_dependency cy, class_attr_db_mapping cas, class_attr_db_mapping cae
    WHERE c.class_name  = cd.class_name
    AND   c.owner_class_name = cy.parent_class
    AND   cy.child_class = p_class_name
    AND   cy.dependency_type = 'IMPLEMENTS'
    AND   c.class_name = cas.class_name
    AND   cas.db_sql_syntax IN ('DAYTIME','FROM_DATE','START_DATE')
    AND   c.class_name = cae.class_name
    AND   cae.db_sql_syntax IN ('END_DATE','TO_DAYTIME','TO_DATE')
    AND   c.class_type = 'DATA'
    AND  EXISTS( SELECT 1 FROM all_tab_columns c
                 WHERE c.owner = cd.DB_OBJECT_OWNER
                 AND c.table_name = cd.DB_OBJECT_NAME
                 AND c.column_name = 'OBJECT_ID')
    AND   Nvl(c.read_only_ind,'N') = 'N'
    UNION ALL
    -- All data classes owned by interfaces used by this class not having end_date column
    SELECT c.class_name, c.class_type, cd.DB_OBJECT_OWNER, cd.DB_OBJECT_NAME,  cd.DB_WHERE_CONDITION , 'OBJECT_ID' DB_SQL_SYNTAX,
              cas.db_sql_syntax start_date_column, 'TO_DATE(NULL)' end_date_column
    FROM class c, class_db_mapping cd, class_dependency cy, class_attr_db_mapping cas
    WHERE c.class_name  = cd.class_name
    AND   c.owner_class_name = cy.parent_class
    AND   cy.child_class = p_class_name
    AND   cy.dependency_type = 'IMPLEMENTS'
        AND   c.class_name = cas.class_name
    AND   cas.db_sql_syntax IN ('DAYTIME','FROM_DATE','START_DATE')
    AND   c.class_type = 'DATA'
    AND  NOT EXISTS( SELECT 1 FROM all_tab_columns c
                 WHERE c.owner = cd.DB_OBJECT_OWNER
                 AND c.table_name = cd.DB_OBJECT_NAME
                 AND c.column_name IN ('END_DATE','TO_DAYTIME','TO_DATE'))
    AND  EXISTS( SELECT 1 FROM all_tab_columns c
                 WHERE c.owner = cd.DB_OBJECT_OWNER
                 AND c.table_name = cd.DB_OBJECT_NAME
                 AND c.column_name = 'OBJECT_ID')
    AND   Nvl(c.read_only_ind,'N') = 'N'
    ORDER BY 1;




--  ln_local_count  NUMBER;

BEGIN

  IF p_recursive_level < 5 THEN  -- Avoid to deep recursive calls


    FOR curChild IN c_owned_by LOOP

      IF MOD(p_count,10) = 0 THEN
        p_union_count := p_union_count + 1;
  	    Ecdp_Dynsql.AddSqlLine(p_body_lines,'CURSOR c_'||TO_CHAR(p_union_count)||' IS '||CHR(10));
  	  ELSE
  	    Ecdp_Dynsql.AddSqlLine(p_body_lines,'UNION ALL ');
      END IF;

  	  Ecdp_Dynsql.AddSqlLine(p_body_lines,'SELECT '''||curChild.class_name||''' class_name, '||curChild.start_date_column||' start_date , '||Nvl(curChild.end_date_column,'NULL')||' end_date FROM '||curChild.DB_OBJECT_OWNER||'.'||curChild.DB_OBJECT_NAME||CHR(10));
  	  Ecdp_Dynsql.AddSqlLine(p_body_lines,' WHERE '||curChild.DB_SQL_SYNTAX||' = p_object_id '||CHR(10));
  	  Ecdp_Dynsql.AddSqlLine(p_body_lines,' AND NVL('||Nvl(curChild.end_date_column,'NULL')||','||curChild.start_date_column||') > p_end_date '||CHR(10));
      p_count  := p_count + 1;

      IF MOD(p_count,10) = 0 THEN
  	    Ecdp_Dynsql.AddSqlLine(p_body_lines,';'||CHR(10)||CHR(10));
  	  END IF;

      -- The previous check on end_date had a very limited recursive check, since this first version here is intended for Hotfixes,
      -- we will keep the same limitation here for now, but the consept here basically supports full recursive checking, but the
      -- performance penalty must be investigated first.

      IF p_class_name IN ('WELL','WELL_BORE') THEN
        AddChildEndDateCursor(p_body_lines,curChild.class_name, p_union_count, p_recursive_level+1,p_count);
      END IF;

    END LOOP;

    IF p_count > 0 AND p_recursive_level = 0  AND  MOD(p_count,10) > 0 THEN
      Ecdp_Dynsql.AddSqlLine(p_body_lines,';'||CHR(10)||CHR(10));
    END IF;

  END IF;



END;


PROCEDURE AddChildEndDateCheck (p_body_lines in out DBMS_SQL.varchar2a,
                                p_union_count in NUMBER)
IS
  lv2_msg  VARCHAR2(1000);

BEGIN
  NULL;
  FOR i IN 1..p_union_count LOOP

	  Ecdp_Dynsql.AddSqlLine(p_body_lines,'FOR cur_'||TO_CHAR(i)||' IN c_'||TO_CHAR(i)||' LOOP ' || CHR(10));

    lv2_msg := '  Raise_Application_Error(-20110,''New object end_date can not be before ''||';
    lv2_msg := lv2_msg || 'TO_CHAR(nvl(cur_'||TO_CHAR(i)||'.end_date,cur_'||TO_CHAR(i)||'.start_date),''dd.mm.yyyy'')||CHR(10)||';
    lv2_msg := lv2_msg || '''Referenced in class ''||'||'cur_'||TO_CHAR(i)||'.class_name||CHR(10)||';
    lv2_msg := lv2_msg || ''' Object code ''||ecdp_objects.GetObjCode(p_object_id)||CHR(10)||';
    lv2_msg := lv2_msg || ''' Daytime ''||TO_CHAR(cur_'||TO_CHAR(i)||'.start_date,''dd.mm.yyyy''));';


	  Ecdp_Dynsql.AddSqlLine(p_body_lines,'  '||lv2_msg||CHR(10));
	  Ecdp_Dynsql.AddSqlLine(p_body_lines,'END LOOP;'||CHR(10)||CHR(10));

  END LOOP;



END;

END;