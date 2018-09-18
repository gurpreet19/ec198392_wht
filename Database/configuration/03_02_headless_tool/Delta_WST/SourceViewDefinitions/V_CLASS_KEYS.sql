CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_CLASS_KEYS" ("CLASS_NAME", "SQL_SYNTAX", "LABEL", "DATA_TYPE", "SORT_ORDER") AS 
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
  SELECT class_name, 'OBJECT_ID' AS sql_syntax, 'Object ID' AS label, 'STRING' AS data_type, 0 AS sort_order
  FROM class_cnfg
  WHERE class_type IN ('OBJECT','INTERFACE')
  UNION ALL
  SELECT class_name, 'DAYTIME' AS sql_syntax, 'Daytime' AS label, 'DATE' AS data_type, 1 AS sort_order
  FROM class_cnfg
  WHERE class_type IN ('OBJECT','INTERFACE')
  UNION ALL
  SELECT a.class_name
  ,      a.attribute_name AS sql_syntax
  ,      NVL(EcDp_ClassMeta_Cnfg.getLabel(a.class_name, a.attribute_name), a.attribute_name) AS label
  ,      a.data_type
  ,      EcDp_ClassMeta_Cnfg.getDbSortOrder(a.class_name, a.attribute_name) AS sort_order
  FROM   class_cnfg c
  ,      class_attribute_cnfg a
  WHERE  c.class_type NOT IN ('OBJECT','INTERFACE')
  AND    EcDp_ClassMeta_Cnfg.isDisabled(a.class_name, a.attribute_name)='N'
  AND    c.class_name=a.class_name
  AND    Nvl(a.is_key,'N')='Y'
  UNION ALL
  SELECT r.to_class_name
  ,      r.role_name||'_ID' AS sql_syntax
  ,      NVL(EcDp_ClassMeta_Cnfg.getLabel(r.from_class_name, r.to_class_name, r.role_name), r.role_name||'_ID') AS label
  ,      'STRING' AS data_type
  ,      EcDp_ClassMeta_Cnfg.getDbSortOrder(r.from_class_name, r.to_class_name, r.role_name) AS sort_order
  FROM   class_relation_cnfg r
  WHERE  EcDp_ClassMeta_Cnfg.isDisabled(r.from_class_name, r.to_class_name, r.role_name)='N'
  AND    Nvl(r.is_key,'N')='Y'
)