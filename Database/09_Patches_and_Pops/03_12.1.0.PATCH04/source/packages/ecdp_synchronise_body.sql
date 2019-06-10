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


 --* sladksve 3.4.2019 varchar2 is too small size
 --lv2_sql       VARCHAR2(32700);
 lv2_sql         CLOB;
--*
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
        EXECUTE IMMEDIATE 'DELETE groups';
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
   CURSOR c_class(cp_class_name VARCHAR2) IS
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
      WHERE cl.class_name = Nvl(cp_class_name, cl.class_name)
         AND class_type = 'OBJECT'
         AND nvl(fc.property_value, 'N') = 'N'
         AND cl.db_object_name IS NOT NULL
         AND cl.db_object_attribute IS NOT NULL
         AND cl.class_name NOT LIKE 'IMP%'
      ORDER BY cl.db_object_name;

   lv_main_sub       VARCHAR2(2000) := q'[MERGE INTO objects_table t USING (
   WITH default_sub AS (
      SELECT o.class_name cascaded_class, o.object_id, daytime, name, 100 AS group_level
      FROM enumeration o INNER JOIN enumeration_version oa ON o.object_id = oa.object_id WHERE o.object_code = 'EC_DEFAULT')
   SELECT :class_name class_name, o.object_id, o.object_code, o.start_date, o.end_date, o.created_by, o.created_date, 
         unit_def.name unit_context, conv_def.name conversion_context
      FROM _tablename_ o
      INNER JOIN default_sub unit_def ON unit_def.cascaded_class = 'UNIT_CONTEXT'
      INNER JOIN default_sub conv_def ON conv_def.cascaded_class = 'CONVERSION_CONTEXT' _wherecond_
   ) t1 ON (t.class_name = t1.class_name AND t.object_id = t1.object_id AND t.code = t1.object_code)
   WHEN MATCHED THEN UPDATE SET 
      start_date = t1.start_date, end_date = t1.end_date, created_by = t1.created_by, created_date = t1.created_date,
      unit_context = t1.unit_context, conversion_context = t1.conversion_context
   WHEN NOT MATCHED THEN
      INSERT (class_name, object_id, code, start_date, end_date, created_by, created_date, unit_context, conversion_context)
      VALUES (t1.class_name, t1.object_id, t1.object_code, t1.start_date, t1.end_date, t1.created_by, t1.created_date,
               t1.unit_context, t1.conversion_context)
   ]';

   lv_version_sub    VARCHAR2(2000) := q'[MERGE INTO objects_version_table t USING (
   WITH default_sub AS (
      SELECT 'PRODUCTION_DAY' cascaded_class, object_id, daytime, name, 100 AS group_level
         FROM production_day_version
         WHERE default_ind = 'Y'
      UNION ALL -- other defaults
      SELECT o.class_name, o.object_id, daytime, name, 100
         FROM enumeration o INNER JOIN enumeration_version oa ON o.object_id = oa.object_id WHERE o.object_code = 'EC_DEFAULT')
   SELECT DISTINCT :class_name class_name, oa.object_id, o.object_code, oa.name, o.start_date object_start_date, o.end_date object_end_date, oa.daytime, oa.end_date, 
         oa.created_by, oa.created_date, tz_def.name time_zone, pday_def.object_id production_day_id
      FROM _versionname_ oa
      INNER JOIN _tablename_ o ON o.object_id = oa.object_id
      INNER JOIN default_sub tz_def ON tz_def.cascaded_class = 'TIME_ZONE_REGION'
      INNER JOIN default_sub pday_def ON pday_def.cascaded_class = 'PRODUCTION_DAY' _wherecond_ 
   ) t1 ON (t.class_name = t1.class_name AND t.object_id = t1.object_id AND t.daytime = t1.daytime)
   WHEN MATCHED THEN UPDATE SET
      name = t1.name, object_start_date = t1.object_start_date, object_end_date = t1.object_end_date, end_date = t1.end_date, created_by = t1.created_by, 
      created_date = t1.created_date, time_zone = t1.time_zone, production_day_id = t1.production_day_id
   WHEN NOT MATCHED THEN
      INSERT (class_name, object_id, object_code, name,  object_start_date, object_end_date, daytime, end_date, time_zone, production_day_id, created_by, created_date)
      VALUES (t1.class_name, t1.object_id, t1.object_code, t1.name, t1.object_start_date, t1.object_end_date, t1.daytime, t1.end_date,
               t1.time_zone, t1.production_day_id, t1.created_by, t1.created_date)
   ]';

   lv_update_main    VARCHAR2(2500) := q'[MERGE INTO objects_table t USING (
   WITH cascaded_cte(cascaded_class, from_class_name, from_object_id, from_daytime, to_class_name, object_id, daytime, group_level) AS
      (SELECT cascaded_class, from_class_name, from_object_id, from_daytime, to_class_name, object_id, daytime, 1 group_level
         FROM gv_object_rel_cascade
         WHERE cascaded_class = from_class_name
      UNION ALL
      SELECT t.cascaded_class, cte.from_class_name, cte.from_object_id, cte.from_daytime, t.to_class_name, t.object_id, t.daytime, cte.group_level + 1
         FROM gv_object_rel_cascade t
      INNER JOIN cascaded_cte cte ON t.cascaded_class = cte.cascaded_class AND t.from_class_name = cte.to_class_name AND t.from_object_id = cte.object_id
         AND t.from_daytime >= cte.daytime AND cte.daytime < Nvl(t.from_end_date, cte.daytime + 1 / 24)
   ), final_sub AS(
      SELECT cascaded_class, to_class_name, a.object_id, a.daytime, name AS value
         FROM cascaded_cte a
      INNER JOIN enumeration_version b ON a.from_object_id = b.object_id AND a.from_daytime = b.daytime
         WHERE cascaded_class = from_class_name AND cascaded_class = 'UNIT_CONTEXT'
      UNION ALL
      SELECT cascaded_class, to_class_name, a.object_id, a.daytime, name
         FROM cascaded_cte a
      INNER JOIN enumeration_version b ON a.from_object_id = b.object_id AND a.from_daytime = b.daytime
         WHERE cascaded_class = from_class_name AND cascaded_class = 'CONVERSION_CONTEXT')
   SELECT a.to_class_name class_name, a.object_id, a.daytime, unit_sub.value  AS unit_context, conv_sub.value AS conversion_context
      FROM cascaded_cte a
      LEFT OUTER JOIN final_sub unit_sub ON a.to_class_name = unit_sub.to_class_name AND a.object_id = unit_sub.object_id
         AND a.daytime = unit_sub.daytime AND unit_sub.cascaded_class = 'UNIT_CONTEXT'
      LEFT OUTER JOIN final_sub conv_sub ON a.to_class_name = conv_sub.to_class_name AND a.object_id = conv_sub.object_id
         AND a.daytime = conv_sub.daytime AND conv_sub.cascaded_class = 'CONVERSION_CONTEXT'
      WHERE (unit_sub.value IS NOT NULL OR conv_sub.value IS NOT NULL) 
   ) t1 ON (t.class_name = t1.class_name AND t.object_id = t1.object_id) 
      WHEN MATCHED THEN UPDATE SET unit_context = Nvl(t1.unit_context, unit_context), conversion_context = Nvl(t1.conversion_context, conversion_context)
   ]';

   lv_update_version VARCHAR2(2500) := q'[MERGE INTO objects_version_table t USING (
   WITH cascaded_cte(cascaded_class, from_class_name, from_object_id, from_daytime, to_class_name, object_id, daytime, group_level) AS
      (SELECT cascaded_class, from_class_name, from_object_id, from_daytime, to_class_name, object_id, daytime, 1 group_level
         FROM gv_object_rel_cascade
         WHERE cascaded_class = from_class_name
      UNION ALL
      SELECT t.cascaded_class, cte.from_class_name, cte.from_object_id, cte.from_daytime, t.to_class_name, t.object_id, t.daytime, cte.group_level + 1
         FROM gv_object_rel_cascade t
      INNER JOIN cascaded_cte cte ON t.cascaded_class = cte.cascaded_class AND t.from_class_name = cte.to_class_name AND t.from_object_id = cte.object_id
         AND t.from_daytime >= cte.daytime AND cte.daytime < Nvl(t.from_end_date, cte.daytime + 1 / 24)
   ), final_sub AS(
      SELECT cascaded_class, to_class_name, a.object_id, a.daytime, name AS value
         FROM cascaded_cte a
      INNER JOIN enumeration_version b ON a.from_object_id = b.object_id AND a.from_daytime = b.daytime
         WHERE cascaded_class = from_class_name AND cascaded_class = 'TIME_ZONE_REGION'
      UNION ALL
      SELECT cascaded_class, to_class_name, a.object_id, a.daytime, from_object_id
         FROM cascaded_cte a
         WHERE cascaded_class = from_class_name AND cascaded_class = 'PRODUCTION_DAY')
   SELECT a.to_class_name class_name, a.object_id, a.daytime, tz_sub.value  AS time_zone_region, conv_sub.value AS production_day
      FROM cascaded_cte a
      LEFT OUTER JOIN final_sub tz_sub ON a.to_class_name = tz_sub.to_class_name AND a.object_id = tz_sub.object_id
         AND a.daytime = tz_sub.daytime AND tz_sub.cascaded_class = 'TIME_ZONE_REGION'
      LEFT OUTER JOIN final_sub conv_sub ON a.to_class_name = conv_sub.to_class_name AND a.object_id = conv_sub.object_id
         AND a.daytime = conv_sub.daytime AND conv_sub.cascaded_class = 'PRODUCTION_DAY'
      WHERE (tz_sub.value IS NOT NULL OR conv_sub.value IS NOT NULL) 
   ) t1 ON (t.class_name = t1.class_name AND t.object_id = t1.object_id AND t.daytime = t1.daytime) 
   WHEN MATCHED THEN UPDATE SET time_zone = Nvl(t1.time_zone_region, time_zone), production_day_id = Nvl(t1.production_day, production_day_id)
   ]';

   lv_where             VARCHAR2(500);
   lv_main              VARCHAR2(3000);
   lv_version           VARCHAR2(3000);
   lb_first             BOOLEAN := TRUE;

BEGIN

   IF p_class_name IS NULL THEN
      DELETE objects_table;
      DELETE objects_version_table;
   END IF;

   FOR one IN c_class(p_class_name) LOOP
      IF p_class_name IS NOT NULL THEN
         EXECUTE IMMEDIATE 'DELETE objects_table WHERE class_name = :class_name ' USING one.class_name;
         EXECUTE IMMEDIATE 'DELETE objects_version_table WHERE class_name = :class_name ' USING one.class_name;
      END IF;

      lv_where := '';
      IF one.db_where_condition IS NOT NULL THEN
         lv_where := CHR(10) || '      WHERE ' || one.db_where_condition;
      END IF;

      lv_main     := REPLACE(REPLACE(lv_main_sub, '_tablename_', one.db_object_name), '_wherecond_', lv_where);
      lv_version  := REPLACE(REPLACE(REPLACE(lv_version_sub, '_tablename_', one.db_object_name), 
         '_versionname_', one.db_object_attribute), '_wherecond_', lv_where);

      -- because pk doesn't have class_name, dup_val check is needed for EC-12.1
      BEGIN
         EXECUTE IMMEDIATE lv_main USING one.class_name;
         EXECUTE IMMEDIATE lv_version USING one.class_name;
      EXCEPTION WHEN dup_val_on_index THEN
         NULL;
      END;

      lb_first := FALSE;
   END LOOP;

   IF NOT lb_first THEN

      EXECUTE IMMEDIATE lv_update_main;
      EXECUTE IMMEDIATE lv_update_version;

   END IF;
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

    lv2_sql_objects := 'INSERT INTO objects_table (object_id, class_name, code, start_date, end_date, unit_context, conversion_context) ' ||
      'SELECT DISTINCT o.object_id, '''|| one.class_name || ''', object_code, start_date, o.end_date, '||
	  'EcDp_Objects.resolveDomainObjectName(''UNIT_CONTEXT'', '''||one.class_name||''', o.object_id, o.start_date), '||
	  'EcDp_Objects.resolveDomainObjectName(''CONVERSION_CONTEXT'', '''||one.class_name||''', oa.object_id, o.start_date) '||
	  'FROM ' ||
      one.db_object_name || ' o ';

    lv2_sql_and_where := ' WHERE ';
    lv2_sql_version := 'INSERT INTO objects_version_table (class_name, object_id, object_start_date, object_end_date, ' ||
      'daytime, end_date, object_code, name, time_zone, production_day_id) ' ||
      'SELECT '''||one.class_name||''', oa.object_id, o.start_date, o.end_date, ' ||
      'oa.daytime, oa.end_date, o.object_code, oa.name, '||
	    'EcDp_Objects.resolveDomainObjectName(''TIME_ZONE_REGION'', '''||one.class_name||''', oa.object_id, oa.daytime), '||
	    'EcDp_Objects.resolveProductionDayId('''||one.class_name||''', oa.object_id, oa.daytime) FROM ' ||
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
