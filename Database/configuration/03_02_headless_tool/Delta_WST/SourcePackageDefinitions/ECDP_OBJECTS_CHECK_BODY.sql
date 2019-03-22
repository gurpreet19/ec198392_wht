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

FUNCTION getOwnerJoinStartDateColumn(p_data_class_name VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR c_data_class_start_date_column(cp_class_name IN VARCHAR2) IS
    SELECT * FROM (
      SELECT a.class_name, a.attribute_name, a.db_sql_syntax,
             CASE WHEN a.attribute_name = 'PRODUCTION_DAY' AND (c.time_scope_code='EVENT' OR c.time_scope_code LIKE '%HR') THEN 1
                  WHEN a.attribute_name = 'DAYTIME' THEN 20
                  WHEN a.attribute_name = 'FROM_DATE' THEN 30
                  WHEN a.attribute_name = 'START_DATE' THEN 40
                  WHEN a.db_sql_syntax = 'DAYTIME' THEN 50
                  WHEN a.db_sql_syntax = 'FROM_DATE' THEN 60
                  WHEN a.db_sql_syntax = 'START_DATE' THEN 70
                  ELSE 9999
             END AS priority
      FROM   class_cnfg c
      INNER JOIN class_attribute_cnfg a ON a.class_name = c.class_name
                                       AND a.data_type = 'DATE'
                                       AND a.db_mapping_type = 'COLUMN'
                                       AND a.db_sql_syntax IS NOT NULL
                                       AND (a.attribute_name IN ('PRODUCTION_DAY', 'DAYTIME', 'FROM_DATE', 'START_DATE') OR a.db_sql_syntax IN ('DAYTIME', 'FROM_DATE', 'START_DATE'))
      WHERE c.class_name = cp_class_name AND c.class_type = 'DATA'
    )
    ORDER BY priority ASC;
BEGIN
  FOR cur IN c_data_class_start_date_column(p_data_class_name) LOOP
    RETURN cur.db_sql_syntax;
  END LOOP;
  RETURN NULL;
END getOwnerJoinStartDateColumn;

FUNCTION getOwnerJoinEndDateColumn(p_data_class_name VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR c_data_class_end_date_column(cp_class_name IN VARCHAR2) IS
    SELECT * FROM (
      SELECT a.class_name, a.attribute_name, a.db_sql_syntax,
             CASE WHEN a.attribute_name = 'PRODUCTION_DAY_END' AND (c.time_scope_code='EVENT' OR c.time_scope_code LIKE '%HR') THEN 1
                  WHEN a.attribute_name = 'END_DATE' THEN 20
                  WHEN a.attribute_name = 'TO_DAYTIME' THEN 30
                  WHEN a.attribute_name = 'TO_DATE' THEN 40
                  WHEN a.db_sql_syntax = 'END_DATE' THEN 50
                  WHEN a.db_sql_syntax = 'TO_DAYTIME' THEN 60
                  WHEN a.db_sql_syntax = 'TO_DATE' THEN 70
                  ELSE 9999
             END AS priority
      FROM   class_cnfg c
      INNER JOIN class_attribute_cnfg a ON a.class_name = c.class_name
                                       AND a.data_type = 'DATE'
                                       AND a.db_mapping_type = 'COLUMN'
                                       AND a.db_sql_syntax IS NOT NULL
                                       AND (a.attribute_name IN ('PRODUCTION_DAY_END', 'END_DATE', 'TO_DAYTIME', 'TO_DATE') OR a.db_sql_syntax IN ('END_DATE','TO_DAYTIME','TO_DATE'))
      WHERE c.class_name = cp_class_name AND c.class_type = 'DATA'
    )
    ORDER BY priority ASC;
BEGIN
  FOR cur IN c_data_class_end_date_column(p_data_class_name) LOOP
    RETURN cur.db_sql_syntax;
  END LOOP;
  RETURN NULL;
END getOwnerJoinEndDateColumn;

PROCEDURE AddChildEndDateCursor(p_body_lines in out DBMS_SQL.varchar2a,
                                p_class_name VARCHAR2,
                                p_union_count in out NUMBER,
                                p_recursive_level IN NUMBER,
                                p_count IN OUT NUMBER )
IS
  CURSOR c_owned_by IS
    SELECT class_name,
           class_type,
           db_object_owner,
           db_object_name,
           db_where_condition,
           db_sql_syntax,
           CASE WHEN production_day_column IS NOT NULL THEN production_day_column ELSE start_date_column END AS start_date_column,
           CASE WHEN production_day_end_column IS NOT NULL THEN production_day_end_column ELSE end_date_column END AS end_date_column
    FROM (
      SELECT DISTINCT
             c.*,
             EcDp_Objects_Check.getOwnerJoinStartDateColumn(c.class_name) AS production_day_column,
             EcDp_Objects_Check.getOwnerJoinEndDateColumn(c.class_name) AS production_day_end_column
      FROM (
        -- All classes owned by p_class_name
        SELECT c.class_name, c.class_type, c.DB_OBJECT_OWNER, c.DB_OBJECT_NAME,  c.DB_WHERE_CONDITION , 'OBJECT_ID' DB_SQL_SYNTAX,
               cas.db_sql_syntax start_date_column, cae.db_sql_syntax end_date_column, c.time_scope_code
        FROM class_cnfg c, class_attribute_cnfg cas, class_attribute_cnfg cae
        WHERE c.owner_class_name = p_class_name
        AND   c.class_name = cas.class_name
        AND   cas.db_sql_syntax IN ('DAYTIME','FROM_DATE','START_DATE')
        AND   c.class_name = cae.class_name
        AND   cae.db_sql_syntax IN ('END_DATE','TO_DAYTIME','TO_DATE')
        AND   EcDp_ClassMeta_Cnfg.isReadOnly(c.class_name) = 'N'
        AND  EXISTS( SELECT 1 FROM all_tab_columns c
                     WHERE c.owner = c.DB_OBJECT_OWNER
                     AND c.table_name = c.DB_OBJECT_NAME
                     AND c.column_name = 'OBJECT_ID')
        UNION ALL
        SELECT c.class_name, c.class_type, c.DB_OBJECT_OWNER, c.DB_OBJECT_NAME,  c.DB_WHERE_CONDITION , 'OBJECT_ID' DB_SQL_SYNTAX,
               cas.db_sql_syntax start_date_column, 'TO_DATE(NULL)' end_date_column, c.time_scope_code
        FROM class_cnfg c, class_attribute_cnfg cas
        WHERE c.owner_class_name = p_class_name
        AND   c.class_name = cas.class_name
        AND   cas.db_sql_syntax IN ('DAYTIME','FROM_DATE','START_DATE')
        AND   EcDp_ClassMeta_Cnfg.isReadOnly(c.class_name) = 'N'
        AND  NOT EXISTS( SELECT 1 FROM all_tab_columns atc
                     WHERE atc.owner = c.DB_OBJECT_OWNER
                     AND atc.table_name = c.DB_OBJECT_NAME
                     AND atc.column_name IN ('END_DATE','TO_DAYTIME','TO_DATE'))
        AND  EXISTS( SELECT 1 FROM all_tab_columns atc
                     WHERE atc.owner = c.DB_OBJECT_OWNER
                     AND atc.table_name = c.DB_OBJECT_NAME
                     AND atc.column_name = 'OBJECT_ID')
        UNION ALL
        -- All data classes with a relation to p_class_name
        SELECT cr.to_class_name class_name, c.class_type, c.DB_OBJECT_OWNER, c.DB_OBJECT_NAME,  c.DB_WHERE_CONDITION , cr.DB_SQL_SYNTAX,
               cas.db_sql_syntax start_date_column, cae.db_sql_syntax end_date_column, c.time_scope_code
        FROM class_relation_cnfg cr, class_cnfg c, class_attribute_cnfg cas, class_attribute_cnfg cae
        WHERE cr.to_class_name = c.class_name
        AND   cr.from_class_name = p_class_name
        AND   c.class_type = 'DATA'
        AND   c.class_name = cas.class_name
        AND   cas.db_sql_syntax IN ('DAYTIME','FROM_DATE','START_DATE')
        AND   c.class_name = cae.class_name
        AND   cae.db_sql_syntax IN ('END_DATE','TO_DAYTIME','TO_DATE')
        AND   EcDp_ClassMeta_Cnfg.isReadOnly(c.class_name) = 'N'
        UNION ALL
        SELECT cr.to_class_name class_name, c.class_type, c.DB_OBJECT_OWNER, c.DB_OBJECT_NAME,  c.DB_WHERE_CONDITION , cr.DB_SQL_SYNTAX,
               cas.db_sql_syntax start_date_column, 'TO_DATE(NULL)' end_date_column, c.time_scope_code
        FROM class_relation_cnfg cr, class_cnfg c, class_attribute_cnfg cas
        WHERE cr.to_class_name = c.class_name
        AND   cr.from_class_name = p_class_name
        AND   c.class_type = 'DATA'
        AND   c.class_name = cas.class_name
        AND   cas.db_sql_syntax IN ('DAYTIME','FROM_DATE','START_DATE')
        AND  NOT EXISTS( SELECT 1 FROM all_tab_columns atc
                     WHERE atc.owner = c.DB_OBJECT_OWNER
                     AND atc.table_name = c.DB_OBJECT_NAME
                     AND atc.column_name IN ('END_DATE','TO_DAYTIME','TO_DATE'))
        AND  EcDp_ClassMeta_Cnfg.isReadOnly(c.class_name) = 'N'
        UNION ALL
        -- All object classes with a non versioned relation to p_class_name
        SELECT c.class_name class_name, c.class_type, c.DB_OBJECT_OWNER, c.DB_OBJECT_NAME,  c.DB_WHERE_CONDITION , cr.DB_SQL_SYNTAX,
               'START_DATE' start_date_column, 'END_DATE' end_date_column, c.time_scope_code
        FROM class_relation_cnfg cr, class_cnfg c
        WHERE cr.to_class_name = c.class_name
        AND   cr.from_class_name = p_class_name
        AND   c.class_type = 'OBJECT'
        AND   cr.db_mapping_type = 'COLUMN'
        AND   EcDp_ClassMeta_Cnfg.isReadOnly(c.class_name) = 'N'
        UNION ALL
        -- All object classes with a versioned relation/group relation to p_class_name
        SELECT c.class_name, c.class_type, c.db_object_owner, c.db_object_attribute db_object_name, c.db_where_condition, cr.db_sql_syntax,
               'DAYTIME' start_date_column, 'END_DATE' end_date_column, c.time_scope_code
        FROM class_relation_cnfg cr, class_cnfg c
        WHERE cr.to_class_name = c.class_name
        AND   cr.from_class_name = p_class_name
        AND   c.class_type = 'OBJECT'
        AND   cr.db_mapping_type = 'ATTRIBUTE'
        AND   EcDp_ClassMeta_Cnfg.isReadOnly(c.class_name) = 'N'
        UNION ALL
        -- All data classes owned by interfaces used by this class having end_date column
        SELECT c.class_name, c.class_type, c.DB_OBJECT_OWNER, c.DB_OBJECT_NAME,  c.DB_WHERE_CONDITION , 'OBJECT_ID' DB_SQL_SYNTAX,
                  cas.db_sql_syntax start_date_column, cae.db_sql_syntax end_date_column, c.time_scope_code
        FROM class_cnfg c, class_dependency_cnfg cy, class_attribute_cnfg cas, class_attribute_cnfg cae
        WHERE c.owner_class_name = cy.parent_class
        AND   cy.child_class = p_class_name
        AND   cy.dependency_type = 'IMPLEMENTS'
        AND   c.class_name = cas.class_name
        AND   cas.db_sql_syntax IN ('DAYTIME','FROM_DATE','START_DATE')
        AND   c.class_name = cae.class_name
        AND   cae.db_sql_syntax IN ('END_DATE','TO_DAYTIME','TO_DATE')
        AND   c.class_type = 'DATA'
        AND  EXISTS( SELECT 1 FROM all_tab_columns atc
                     WHERE atc.owner = c.DB_OBJECT_OWNER
                     AND atc.table_name = c.DB_OBJECT_NAME
                     AND atc.column_name = 'OBJECT_ID')
        AND   EcDp_ClassMeta_Cnfg.isReadOnly(c.class_name) = 'N'
        UNION ALL
        -- All data classes owned by interfaces used by this class not having end_date column
        SELECT c.class_name, c.class_type, c.DB_OBJECT_OWNER, c.DB_OBJECT_NAME,  c.DB_WHERE_CONDITION , 'OBJECT_ID' DB_SQL_SYNTAX,
                  cas.db_sql_syntax start_date_column, 'TO_DATE(NULL)' end_date_column, c.time_scope_code
        FROM class_cnfg c, class_dependency_cnfg cy, class_attribute_cnfg cas
        WHERE c.owner_class_name = cy.parent_class
        AND   cy.child_class = p_class_name
        AND   cy.dependency_type = 'IMPLEMENTS'
        AND   c.class_name = cas.class_name
        AND   cas.db_sql_syntax IN ('DAYTIME','FROM_DATE','START_DATE')
        AND   c.class_type = 'DATA'
        AND  NOT EXISTS( SELECT 1 FROM all_tab_columns atc
                     WHERE atc.owner = c.DB_OBJECT_OWNER
                     AND atc.table_name = c.DB_OBJECT_NAME
                     AND atc.column_name IN ('END_DATE','TO_DAYTIME','TO_DATE'))
        AND  EXISTS( SELECT 1 FROM all_tab_columns atc
                     WHERE atc.owner = c.DB_OBJECT_OWNER
                     AND atc.table_name = c.DB_OBJECT_NAME
                     AND atc.column_name = 'OBJECT_ID')
        AND  EcDp_ClassMeta_Cnfg.isReadOnly(c.class_name) = 'N'
      ) c
    ) c
    ORDER BY 1;
BEGIN

  IF p_recursive_level < 5 THEN  -- Avoid to deep recursive calls

    FOR curChild IN c_owned_by LOOP
      IF EcDp_ClassMeta_Cnfg.isReadOnly(p_class_name) = 'N' THEN
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

        IF p_class_name IN ('WELL','WELL_BORE') AND p_class_name != curChild.class_name AND curChild.class_type = 'OBJECT' THEN
          AddChildEndDateCursor(p_body_lines,curChild.class_name, p_union_count, p_recursive_level+1,p_count);
        END IF;
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

    lv2_msg := '  Raise_Application_Error(-20126,''New object end_date can not be before ''||';
    lv2_msg := lv2_msg || 'TO_CHAR(nvl(cur_'||TO_CHAR(i)||'.end_date,cur_'||TO_CHAR(i)||'.start_date),''dd.mm.yyyy'')||CHR(10)||';
    lv2_msg := lv2_msg || '''Referenced in class ''||'||'cur_'||TO_CHAR(i)||'.class_name||CHR(10)||';
    lv2_msg := lv2_msg || ''' Object code ''||ecdp_objects.GetObjCode(p_object_id)||CHR(10)||';
    lv2_msg := lv2_msg || ''' Daytime ''||TO_CHAR(cur_'||TO_CHAR(i)||'.start_date,''dd.mm.yyyy''));';


      Ecdp_Dynsql.AddSqlLine(p_body_lines,'  '||lv2_msg||CHR(10));
      Ecdp_Dynsql.AddSqlLine(p_body_lines,'END LOOP;'||CHR(10)||CHR(10));

  END LOOP;



END;

END;