CREATE OR REPLACE FORCE VIEW "V_CLASS_KEYS" ("CLASS_NAME", "SQL_SYNTAX", "LABEL", "DATA_TYPE", "SORT_ORDER") AS 
  (
----------------------------------------------------------------------------------------------------
-- File name: v_class_keys.sql
-- View name: v_class_keys
--
-- $Revision: 1.2 $
--
-- Purpose  : Returns the key attributes and relations for all classes.
--
-- Modification history:
--
-- Date       Whom  Change description:
-- ---------- ----  --------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
  SELECT class_name, 'OBJECT_ID' AS sql_syntax, 'Object ID' AS label, 'STRING' AS data_type, 0 AS sort_order FROM class WHERE class_type IN ('OBJECT','INTERFACE')
  UNION ALL
  SELECT class_name, 'DAYTIME' AS sql_syntax, 'Daytime' AS label, 'DATE' AS data_type, 1 AS sort_order FROM class WHERE class_type IN ('OBJECT','INTERFACE')
  UNION ALL
  SELECT a.class_name
  ,      a.attribute_name AS sql_syntax
  ,      NVL(ap.label, a.attribute_name) AS label
  ,      a.data_type
  ,      am.sort_order
  FROM   class c
  ,      class_attribute a
  ,      class_attr_db_mapping am
  ,      class_attr_presentation ap
  WHERE  c.class_type NOT IN ('OBJECT','INTERFACE')
  AND    Nvl(a.disabled_ind,'N')='N'
  AND    c.class_name=a.class_name
  AND    Nvl(a.is_key,'N')='Y'
  AND    am.class_name(+)=a.class_name
  AND    am.attribute_name(+)=a.attribute_name
  AND    ap.class_name(+)=a.class_name
  AND    ap.attribute_name(+)=a.attribute_name
  UNION ALL
  SELECT r.to_class_name
  ,      r.role_name||'_ID' AS sql_syntax
  ,      NVL(rp.label, r.role_name||'_ID') AS label
  ,      'STRING' AS data_type
  ,      rm.sort_order
  FROM   class_relation r
  ,      class_rel_db_mapping rm
  ,      class_rel_presentation rp
  WHERE  Nvl(r.disabled_ind,'N')='N'
  AND    Nvl(r.is_key,'N')='Y'
  AND    rm.from_class_name(+)=r.from_class_name
  AND    rm.to_class_name(+)=r.to_class_name
  AND    rm.role_name(+)=r.role_name
  AND    rp.from_class_name(+)=r.from_class_name
  AND    rp.to_class_name(+)=r.to_class_name
  AND    rp.role_name(+)=r.role_name
)