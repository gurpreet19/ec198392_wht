CREATE OR REPLACE PACKAGE ecdp_synchronise IS
/**
 * Refresh/sync objects_version_table and objects_table for the given object and its group model children.
 *
 * @param p_object_id
 */
PROCEDURE SyncObjectGroups(p_object_id VARCHAR2);

/**
 * Refresh/sync groups table for the given object and its group model children.
 * Sync groups table for the given object.
 *
 * @param p_class_name
 * @param p_object_id
 */
PROCEDURE SyncGroups(p_class_name VARCHAR2 DEFAULT NULL, p_object_id VARCHAR2 DEFAULT NULL);

/**
 * Refresh/sync objects_version_table, objects_table and groups table for the given object and its group model children.
 *
 * @param p_class_name
 * @param p_object_id
 */
PROCEDURE Synchronise(p_class_name VARCHAR2 DEFAULT NULL, p_object_id VARCHAR2 DEFAULT NULL);

END;
/
CREATE OR REPLACE PACKAGE BODY ecdp_synchronise IS

PROCEDURE SyncGroups(p_class_name VARCHAR2 DEFAULT NULL, p_object_id VARCHAR2 DEFAULT NULL)
IS
  CURSOR c_relation(cp_class_name VARCHAR2) IS
    WITH class_rel_property_max AS
     (SELECT p1.from_class_name,
             p1.to_class_name,
             p1.role_name,
             p1.property_code,
             p1.property_value
        FROM class_rel_property_cnfg p1, class_cnfg cc
       WHERE p1.presentation_cntx = '/'
         AND cc.class_name = p1.to_class_name
         AND ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0
         AND p1.owner_cntx =
             (SELECT MAX(owner_cntx)
                FROM class_rel_property_cnfg p1_1
               WHERE p1.from_class_name = p1_1.from_class_name
                 AND p1.to_class_name = p1_1.to_class_name
                 AND p1.role_name = p1_1.role_name
                 AND p1.property_code = p1_1.property_code
                 AND p1.presentation_cntx = p1_1.presentation_cntx))
    SELECT cr.*,
           cdb.db_object_name,
           cdb.db_object_attribute,
           cdb.db_where_condition
      FROM class_relation_cnfg cr
     INNER JOIN class_cnfg cdb
        ON cr.to_class_name = cdb.class_name
      LEFT OUTER JOIN class_rel_property_max p1
        ON (cr.from_class_name = p1.from_class_name AND
           cr.to_class_name = p1.to_class_name AND cr.role_name = p1.role_name AND
           p1.property_code = 'DISABLED_IND')
      LEFT OUTER JOIN class_rel_property_max p2
        ON (cr.from_class_name = p2.from_class_name AND
           cr.to_class_name = p2.to_class_name AND cr.role_name = p2.role_name AND
           p2.property_code = 'ALLOC_PRIORITY')
     WHERE cr.group_type IS NOT NULL
       AND multiplicity IN ('1:1', '1:N')
       AND CR.to_class_name = NVL(cp_class_name, cr.to_class_name)
       AND nvl(p1.property_value, 'N') = 'N'
       AND cdb.db_object_name IS NOT NULL
       AND cdb.db_object_attribute IS NOT NULL
     ORDER BY group_type, p2.property_value;

 CURSOR c_alt_group_connections(cp_group_type VARCHAR2, cp_to_class_name VARCHAR2, cp_ne_from_class_name VARCHAR2) IS
    WITH class_rel_property_max AS
     (SELECT p1.from_class_name,
             p1.to_class_name,
             p1.role_name,
             p1.property_code,
             p1.property_value
        FROM class_rel_property_cnfg p1, class_cnfg cc
       WHERE p1.presentation_cntx = '/'
         AND cc.class_name = p1.to_class_name
         AND ec_install_constants.isBlockedAppSpaceCntx(cc.app_space_cntx) = 0
         AND p1.owner_cntx =
             (SELECT MAX(owner_cntx)
                FROM class_rel_property_cnfg p1_1
               WHERE p1.from_class_name = p1_1.from_class_name
                 AND p1.to_class_name = p1_1.to_class_name
                 AND p1.role_name = p1_1.role_name
                 AND p1.property_code = p1_1.property_code
                 AND p1.presentation_cntx = p1_1.presentation_cntx))
    SELECT cr.from_class_name, cr.db_sql_syntax
      FROM class_relation_cnfg cr
      LEFT OUTER JOIN class_rel_property_max p1
        ON (cr.from_class_name = p1.from_class_name AND
           cr.to_class_name = p1.to_class_name AND cr.role_name = p1.role_name AND
           p1.property_code = 'DISABLED_IND')
     WHERE cr.group_type IS NOT NULL
       AND multiplicity IN ('1:1', '1:N')
       AND nvl(p1.property_value, 'N') = 'N'
       AND cr.group_type = cp_group_type
       AND cr.to_class_name = cp_to_class_name
       AND cr.from_class_name <> cp_ne_from_class_name;


 lv2_sql         CLOB;-- VARCHAR2(32700);
 lv2_union_all  VARCHAR2(30) := '';
 ln_cur_level   NUMBER;
BEGIN
  FOR curGM IN c_relation(p_class_name) LOOP
    lv2_sql := lv2_sql || lv2_union_all;

    lv2_sql := lv2_sql || '  SELECT '''||curGM.group_type||''' AS group_type, '''||curGM.to_class_name||''' AS object_type, o.object_id,' ;
    lv2_sql := lv2_sql || ' '''||curGM.group_type||''' AS parent_group_type, '''||curGM.from_class_name||''' AS parent_object_type, '||curGM.db_sql_syntax || ' AS parent_object_id,' || CHR(10);
    lv2_sql := lv2_sql || '    oa.daytime, oa.end_date, oa.record_status, oa.created_by, oa.created_date, oa.last_updated_by, oa.last_updated_date,';
    lv2_sql := lv2_sql || ' oa.rev_no, oa.rev_text' ||CHR(10);
    lv2_sql := lv2_sql || '  FROM '||curGM.db_object_attribute||' oa,'||curGM.DB_OBJECT_NAME||' o ' ||CHR(10);
    lv2_sql := lv2_sql || '  WHERE o.object_id = oa.object_id';

    IF curGM.db_where_condition IS NOT NULL THEN
       lv2_sql := lv2_sql ||  CHR(10) || '    AND '||curGM.db_where_condition;
    END IF;

    FOR cur_alt_path in c_alt_group_connections(curGM.group_type, curGM.to_class_name, curGM.from_class_name ) LOOP
       --multiple paths detected
       -- need to find if outer relation is the highest parent
       ln_cur_level := Ecdp_classmeta.getGroupModelLevelSortOrder (curGM.group_type, curGM.to_class_name, curGM.from_class_name);
       IF  ln_cur_level < Ecdp_classmeta.getGroupModelLevelSortOrder (curGM.group_type, curGM.to_class_name, cur_alt_path.from_class_name) THEN
         -- where "inner_child" is null
         lv2_sql := lv2_sql || CHR(10) || '    AND '||cur_alt_path.db_sql_syntax||' IS NULL';
       ELSE
         -- where "inner_child" is not null
         lv2_sql := lv2_sql || CHR(10) || '    AND '||curGM.db_sql_syntax||' IS NOT NULL';

       END IF;
    END LOOP;

    lv2_union_all := CHR(10) || '  UNION ALL' || CHR(10);

  END LOOP;

  IF length(lv2_sql) > 0 THEN
      IF p_class_name IS NULL THEN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE groups';
      ELSIF p_object_id IS NULL THEN
        DELETE groups WHERE object_type = p_class_name;
      ELSE
        DELETE groups WHERE object_type = p_class_name AND object_id = p_object_id;
      END IF;

	  lv2_sql := 'INSERT INTO groups (group_type, object_type, object_id, parent_group_type, parent_object_type, parent_object_id, daytime, end_date, record_status, created_by, created_date, last_updated_by, last_updated_date, rev_no, rev_text)'||
		        CHR(10) || ' SELECT * FROM (' || CHR(10) || lv2_sql || CHR(10) || ')' || CHR(10);

      IF p_object_id IS NOT NULL THEN
        lv2_sql := lv2_sql || ' WHERE object_id = :object_id ';
        EXECUTE IMMEDIATE lv2_sql USING p_object_id;
      ELSE
        EXECUTE IMMEDIATE lv2_sql;
      END IF;
  END IF;
END SyncGroups;

PROCEDURE SyncObjects(p_class_name VARCHAR2 DEFAULT NULL, p_object_id VARCHAR2 DEFAULT NULL)
IS
  CURSOR c_class IS
    WITH w_read_only AS
     (SELECT class_name, property_code, property_value
        FROM class_property_cnfg p1
       WHERE p1.presentation_cntx in ('/')
         AND owner_cntx =
             (SELECT MAX(owner_cntx)
                FROM class_property_cnfg p1_1
               WHERE p1.class_name = p1_1.class_name
                 AND p1.property_code = p1_1.property_code
                 AND p1.presentation_cntx = p1_1.presentation_cntx))
    SELECT UPPER(LTRIM(RTRIM(cl.class_name))) class_name,
           cl.db_object_name,
           cl.db_object_attribute,
           cl.db_where_condition
      FROM class_cnfg cl
      LEFT OUTER JOIN w_read_only fc
        ON (cl.class_name = fc.class_name and
           fc.property_code = 'READ_ONLY_IND')
     WHERE cl.class_name = Nvl(p_class_name, cl.class_name)
       AND class_type = 'OBJECT'
       AND nvl(fc.property_value, 'N') = 'N'
       AND cl.db_object_name IS NOT NULL
       AND cl.db_object_attribute IS NOT NULL
       AND cl.class_name NOT LIKE 'IMP%';


  lv2_sql_objects VARCHAR2(2000);
  lv2_sql_version VARCHAR2(2000);

BEGIN
  IF p_class_name IS NULL THEN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE objects_table';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE objects_version_table';
  ELSIF p_object_id IS NULL THEN
    DELETE objects_table WHERE class_name = p_class_name;
    DELETE objects_version_table WHERE class_name = p_class_name;
  ELSE
    DELETE objects_table WHERE class_name = p_class_name AND object_id = p_object_id;
    DELETE objects_version_table WHERE class_name = p_class_name AND object_id = p_object_id;
  END IF;

  FOR cur_class IN c_class LOOP

    lv2_sql_objects := 'INSERT INTO objects_table (object_id, class_name, code, start_date, end_date) ' ||
      'SELECT DISTINCT o.object_id, '''|| cur_class.class_name || ''', object_code, start_date, o.end_date FROM ' ||
      cur_class.db_object_name || ' o';

    lv2_sql_version := 'INSERT INTO objects_version_table (class_name, object_id, object_start_date, object_end_date, ' ||
      'daytime, end_date, object_code, name) ' ||
      'SELECT '''||cur_class.class_name||''', oa.object_id, o.start_date, o.end_date, ' ||
      'oa.daytime, oa.end_date, o.object_code, oa.name FROM ' ||
      cur_class.db_object_name || ' o INNER JOIN '  || cur_class.db_object_attribute || ' oa ON oa.object_id = o.object_id';

      IF cur_class.db_where_condition IS NOT NULL THEN
        lv2_sql_objects := lv2_sql_objects || ' INNER JOIN ' || cur_class.db_object_attribute ||
          ' oa ON oa.object_id = o.object_id AND ' || cur_class.db_where_condition;

        lv2_sql_version := lv2_sql_version || ' AND ' || cur_class.db_where_condition;
      END IF;

      IF p_object_id IS NOT NULL THEN
        IF cur_class.db_where_condition IS NOT NULL THEN
          lv2_sql_objects := lv2_sql_objects || ' AND o.object_id = :object_id';
        ELSE
          lv2_sql_objects := lv2_sql_objects || ' WHERE o.object_id = :object_id';
        END IF;

        lv2_sql_version := lv2_sql_version || ' AND o.object_id = :object_id';

        EXECUTE IMMEDIATE lv2_sql_objects USING p_object_id;
        EXECUTE IMMEDIATE lv2_sql_version USING p_object_id;
      ELSE
        EXECUTE IMMEDIATE lv2_sql_objects;
        EXECUTE IMMEDIATE lv2_sql_version;
      END IF;

  END LOOP;
END SyncObjects;

PROCEDURE SyncObjectGroups(p_object_id VARCHAR2)
IS
  CURSOR c_groups (cp_object_id VARCHAR2) IS
    WITH group_model_cte(object_id,
    object_type,
    group_level) AS
     (SELECT object_id, object_type, 1 group_level
        FROM groups
       WHERE parent_object_id = cp_object_id
      UNION ALL
      SELECT e.object_id, e.object_type, cte.group_level + 1
        FROM groups e
       INNER JOIN group_model_cte cte
          ON e.parent_object_id = cte.object_id)
    SELECT object_id,
           class_name,
           db_object_name,
           db_object_attribute,
           db_where_condition
      FROM class_cnfg m
     INNER JOIN group_model_cte g
        ON m.class_name = g.object_type
     ORDER BY class_name, object_id;

  lv2_sql_objects VARCHAR2(2000);
  lv2_sql_version VARCHAR2(2000);
  lv2_sql_and_where VARCHAR2(10);

BEGIN

  FOR one IN c_groups (p_object_id) LOOP
    DELETE objects_table WHERE class_name = one.class_name AND object_id = one.object_id;
    DELETE objects_version_table WHERE class_name = one.class_name AND object_id = one.object_id;

    lv2_sql_objects := 'INSERT INTO objects_table (object_id, class_name, code, start_date, end_date) ' ||
      'SELECT DISTINCT o.object_id, '''|| one.class_name || ''', object_code, start_date, o.end_date FROM ' ||
      one.db_object_name || ' o';

    lv2_sql_and_where := ' WHERE ';
    lv2_sql_version := 'INSERT INTO objects_version_table (class_name, object_id, object_start_date, object_end_date, ' ||
      'daytime, end_date, object_code, name) ' ||
      'SELECT '''||one.class_name||''', oa.object_id, o.start_date, o.end_date, ' ||
      'oa.daytime, oa.end_date, o.object_code, oa.name FROM ' ||
      one.db_object_name || ' o INNER JOIN '  || one.db_object_attribute || ' oa ON oa.object_id = o.object_id';

      IF one.db_where_condition IS NOT NULL THEN
        lv2_sql_objects := lv2_sql_objects || ' INNER JOIN ' || one.db_object_attribute ||
          ' oa ON oa.object_id = o.object_id AND ' || one.db_where_condition;

        lv2_sql_version := lv2_sql_version || ' AND ' || one.db_where_condition;

        lv2_sql_and_where := ' AND ';
      END IF;

      lv2_sql_objects := lv2_sql_objects || lv2_sql_and_where || 'o.object_id = :oid';
      lv2_sql_version := lv2_sql_version || ' AND o.object_id = :oid';

      EXECUTE IMMEDIATE lv2_sql_objects USING one.object_id;
      EXECUTE IMMEDIATE lv2_sql_version USING one.object_id;

  END LOOP;

END SyncObjectGroups;

PROCEDURE Synchronise(p_class_name VARCHAR2 DEFAULT NULL, p_object_id VARCHAR2 DEFAULT NULL)
IS
BEGIN
  SyncObjects(p_class_name, p_object_id);
  SyncGroups(p_class_name, p_object_id);
END Synchronise;

END;
/
