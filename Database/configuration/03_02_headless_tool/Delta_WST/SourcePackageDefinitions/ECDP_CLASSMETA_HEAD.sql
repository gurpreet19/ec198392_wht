CREATE OR REPLACE PACKAGE EcDp_ClassMeta IS
/**************************************************************
** Package:    EcDp_ClassMeta
**
** $Revision: 1.39 $
**
** Filename:   EcDp_DynSql.sql
**
** Part of :   EC Kernel
**
** Purpose:
**
** General Logic:
**
** Document References:
**
**************************************************************/

FUNCTION getDataType(p_data_type VARCHAR2)
RETURN VARCHAR2;

  CURSOR c_classes (p_class_name VARCHAR2) IS
     SELECT *
     FROM class_cnfg x
    WHERE class_name = p_class_name;

CURSOR c_classes_attr (p_class_name VARCHAR2, p_private VARCHAR2 DEFAULT 'N', p_attribute_name VARCHAR2 DEFAULT NULL) IS
  WITH db_join_alias AS (
    SELECT class_name
    ,      db_mapping_type
    ,      db_join_table
    ,      db_join_where
    ,      lower(substr(class_name, 1, 1))||substr(replace(initcap(class_name),'_'),2)||rownum AS db_join_alias
    FROM (
      SELECT DISTINCT class_name, db_mapping_type, db_join_table, db_join_where
      FROM   class_attribute_cnfg
      WHERE  db_join_table IS NOT NULL
      AND    db_join_where IS NOT NULL
      AND    class_name = p_class_name
      ORDER BY 1, 2, 3
    )
  )
  SELECT * FROM (
    SELECT
      ca.class_name,
      LTRIM(RTRIM(ca.attribute_name)) attribute_name ,
      ca.db_mapping_type,
      ca.db_sql_syntax,
      EcDp_ClassMeta_Cnfg.getDbSortOrder(ca.class_name, ca.attribute_name) AS sort_order,
      ca.is_key,
      EcDp_ClassMeta_Cnfg.isMandatory(ca.class_name, ca.attribute_name) AS is_mandatory,
      ca.app_space_cntx AS context_code,
      EcDp_ClassMeta.getDataType(ca.data_type) data_type,
      NULL AS precision,
      EcDp_ClassMeta_Cnfg.isDisabled(ca.class_name, ca.attribute_name) AS disabled_ind,
      NULL AS default_value,
      ja.db_join_table,
      ja.db_join_where,
      ja.db_join_alias,
      EcDp_ClassMeta_Cnfg.isReportOnly(ca.class_name, ca.attribute_name) AS report_only_ind
    FROM class_attribute_cnfg ca
    LEFT OUTER JOIN db_join_alias ja ON ja.class_name = ca.class_name AND ja.db_mapping_type = ca.db_mapping_type AND ja.db_join_table = ca.db_join_table AND ja.db_join_where = ca.db_join_where
    WHERE ca.class_name = p_class_name
    AND ca.attribute_name = Nvl(p_attribute_name, ca.attribute_name)
    AND EcDp_ClassMeta_Cnfg.isDisabled(ca.class_name, ca.attribute_name) = nvl(p_private, 'X')
  )
  ORDER BY sort_order
  ;


CURSOR c_dataclasses_attr (p_class_name VARCHAR2, p_private VARCHAR2 DEFAULT 'N', p_attribute_name VARCHAR2 DEFAULT NULL) IS
  WITH db_join_alias AS (
    SELECT class_name
    ,      db_mapping_type
    ,      db_join_table
    ,      db_join_where
    ,      lower(substr(class_name, 1, 1))||substr(replace(initcap(class_name),'_'),2)||rownum AS db_join_alias
    FROM (
      SELECT DISTINCT class_name, db_mapping_type, db_join_table, db_join_where
      FROM   class_attribute_cnfg
      WHERE  db_join_table IS NOT NULL
      AND    db_join_where IS NOT NULL
      AND    class_name = p_class_name
      ORDER BY 1, 2, 3
    )
  )
  SELECT * FROM (
    SELECT
      ca.class_name,
      LTRIM(RTRIM(ca.attribute_name)) attribute_name,
      ca.db_mapping_type,
      ca.db_sql_syntax,
      EcDp_ClassMeta_Cnfg.getDbSortOrder(ca.class_name, ca.attribute_name) AS sort_order,
      ca.is_key,
      EcDp_ClassMeta_Cnfg.isMandatory(ca.class_name, ca.attribute_name) AS is_mandatory,
      ca.app_space_cntx AS context_code,
      EcDp_ClassMeta.getDataType(ca.data_type) data_type,
      NULL AS precision,
      EcDp_ClassMeta_Cnfg.isDisabled(ca.class_name, ca.attribute_name) is_private ,
      NULL AS default_value,
      ja.db_join_table,
      ja.db_join_where,
      ja.db_join_alias,
      EcDp_ClassMeta_Cnfg.isReportOnly(ca.class_name, ca.attribute_name) AS report_only_ind
    FROM class_attribute_cnfg ca
    LEFT OUTER JOIN db_join_alias ja ON ja.class_name = ca.class_name AND ja.db_mapping_type = ca.db_mapping_type AND ja.db_join_table = ca.db_join_table AND ja.db_join_where = ca.db_join_where
    WHERE ca.class_name = p_class_name
    AND ca.attribute_name NOT IN ('OBJECT_CODE') -- To support both definitintion with or without this explecite defined
    AND ca.attribute_name = Nvl(p_attribute_name, ca.attribute_name)
    AND EcDp_ClassMeta_Cnfg.isDisabled(ca.class_name, ca.attribute_name) = nvl(p_private, 'X')
  )
  ORDER BY sort_order
  ;

CURSOR c_sub_classes_attr (p_class_name VARCHAR2, p_private VARCHAR2 DEFAULT 'N', p_attribute_name VARCHAR2 DEFAULT NULL) IS
  SELECT
      class_name,
      LTRIM(RTRIM(attribute_name)) attribute_name,
      app_space_cntx AS context_code,
      EcDp_ClassMeta_Cnfg.isDisabled(x.class_name, x.attribute_name) AS is_private
  FROM class_attribute_cnfg x
  WHERE class_name = p_class_name
    AND EXISTS (select 'x' from class_cnfg where class_name = x.class_name and class_type = 'SUB_CLASS')
    AND EcDp_ClassMeta_Cnfg.isDisabled(x.class_name, x.attribute_name) = nvl(p_private, 'X')
    AND attribute_name = Nvl(p_attribute_name,attribute_name)
  ;


CURSOR c_classes_rel (p_class_name VARCHAR2, p_role_name VARCHAR2 DEFAULT NULL, p_disabled_ind VARCHAR2 DEFAULT 'N', p_report_only_ind VARCHAR2 DEFAULT 'N' ) IS
  SELECT * FROM (
    SELECT
      cr.from_class_name,
      cr.to_class_name,
      LTRIM(RTRIM(cr.role_name)) role_name,
      cr.db_mapping_type,
      cr.db_sql_syntax,
      EcDp_ClassMeta_Cnfg.getDbSortOrder(cr.from_class_name, cr.to_class_name, cr.role_name) AS sort_order,
       EcDp_ClassMeta_Cnfg.isMandatory(cr.from_class_name, cr.to_class_name, cr.role_name) AS is_mandatory,
      cr.is_bidirectional,
      cr.app_space_cntx AS context_code,
      cr.multiplicity,
      EcDp_ClassMeta_Cnfg.isDisabled(cr.from_class_name, cr.to_class_name, cr.role_name) AS disabled_ind,
      cr.is_key,
      EcDp_ClassMeta_Cnfg.isReportOnly(cr.from_class_name, cr.to_class_name, cr.role_name) report_only_ind,
      cr.group_type,
      EcDp_ClassMeta_Cnfg.getAccessControlMethod(cr.from_class_name, cr.to_class_name, cr.role_name) AS access_control_method
    FROM class_relation_cnfg cr
    WHERE cr.to_class_name = p_class_name
      AND cr.role_name = Nvl(p_role_name,cr.role_name)
      AND multiplicity IN ('1:1', '1:N')
      AND EcDp_ClassMeta_Cnfg.isDisabled(cr.from_class_name, cr.to_class_name, cr.role_name) = Nvl(p_disabled_ind,'X')
  )
  WHERE report_only_ind = Nvl(p_report_only_ind, report_only_ind)
  ORDER BY sort_order
  ;

CURSOR c_classes_interface (p_class_name VARCHAR2) IS
  SELECT cd.child_class, cc.app_space_cntx
  FROM class_dependency_cnfg cd
  INNER JOIN class_cnfg cc ON cc.class_name = cd.child_class
  WHERE cd.parent_class = p_class_name
  ;

CURSOR c_classes_intf_attr (p_class_name VARCHAR2, p_private VARCHAR2 DEFAULT 'N') IS
  SELECT
      LTRIM(RTRIM(ca.attribute_name)) attribute_name
  FROM class_cnfg c, class_attribute_cnfg ca
  WHERE c.class_name  = p_class_name
  AND   c.class_name = ca.class_name
  AND   c.class_type = 'INTERFACE'
  AND EcDp_ClassMeta_Cnfg.isDisabled(ca.class_name, ca.attribute_name) = nvl(p_private, 'X')
  ORDER BY attribute_name  ;


CURSOR c_classes_intf_rel (p_class_name VARCHAR2) IS
  SELECT
    LTRIM(RTRIM(cr.role_name)) role_name
  FROM class_relation_cnfg cr
  WHERE cr.to_class_name = p_class_name
    AND multiplicity IN ('1:1', '1:N')
  ;


CURSOR c_intersect_columns (
    p_from_class_name IN VARCHAR2,
    p_to_class_name IN VARCHAR2,
    p_is_key IN VARCHAR2)
  IS
    SELECT ca.attribute_name
      FROM class_attribute_cnfg ca
     WHERE ca.class_name = p_to_class_name
       AND ca.db_mapping_type='COLUMN'
       AND (ca.is_key = p_is_key OR p_is_key IS NULL OR (ca.is_key IS NULL AND p_is_key='N'))
       AND EcDp_ClassMeta_Cnfg.isDisabled(ca.class_name, ca.attribute_name) = 'N'
       AND EcDp_ClassMeta_Cnfg.isReportOnly(ca.class_name, ca.attribute_name) = 'N'
    INTERSECT
    SELECT ca.attribute_name
      FROM class_attribute_cnfg ca
     WHERE ca.class_name = p_from_class_name
       AND ca.db_mapping_type in ('COLUMN', 'FUNCTION')
       AND EcDp_ClassMeta_Cnfg.isDisabled(ca.class_name, ca.attribute_name) = 'N'
       AND EcDp_ClassMeta_Cnfg.isReportOnly(ca.class_name, ca.attribute_name) = 'N';

CURSOR c_class_trigger_action (p_class_name VARCHAR2, p_trigger_type VARCHAR2 ) IS
  SELECT
    triggering_event,
    sort_order,
    db_sql_syntax,
    app_space_cntx
  FROM class_trigger_actn_cnfg ta
  WHERE ta.class_name = p_class_name
  AND   ta.trigger_type = p_trigger_type
  AND  Ecdp_Classmeta_Cnfg.isDisabled(ta.class_name, ta.triggering_event, ta.trigger_type, ta.sort_order) = 'N'
  ORDER BY Nvl(ta.sort_order,9999)
  ;

PROCEDURE GetUtilDbMapping (
  p_class_name              VARCHAR2,
  p_property_name           VARCHAR2,
  p_table_name         OUT VARCHAR2,
  p_column_name      OUT VARCHAR2,
  p_time_scope_code    OUT VARCHAR2
);

FUNCTION IsPropertyMandatory(
  p_class_name          VARCHAR2,
  p_property_name       VARCHAR2
)

RETURN VARCHAR2;

FUNCTION OwnerClassName(
  p_class_name          VARCHAR2
)
RETURN VARCHAR2;

FUNCTION SuperClassName(
  p_class_name          VARCHAR2
)
RETURN VARCHAR2;


FUNCTION CountAttrRecords(
   p_class_name      VARCHAR2,
   p_table_name       VARCHAR2,
   p_column_name        VARCHAR2
)
RETURN NUMBER;
--

FUNCTION IsValidTabCol(
   p_class_name      VARCHAR2,
   p_table_owner        VARCHAR2,
   p_table_name       VARCHAR2,
   p_column_name        VARCHAR2
)
RETURN BOOLEAN;

FUNCTION getClassDateHandeling(
  p_class_name          VARCHAR2,
  p_class_type          VARCHAR2
)
RETURN VARCHAR2;

FUNCTION getClassDBTable(
  p_class_name          VARCHAR2
)
RETURN VARCHAR2;


FUNCTION getClassViewName(
  p_class_name          VARCHAR2
)
RETURN VARCHAR2;

FUNCTION getClassJournalIfCondition(
  p_class_name          VARCHAR2
)
RETURN VARCHAR2;

FUNCTION getPropertyValueFromClass(
  p_class_name          VARCHAR2,
  p_property_code       VARCHAR2
)
RETURN VARCHAR2;

FUNCTION getViewColumnMandatory(
  p_view_name          VARCHAR2,
  p_column_name        VARCHAR2
)
RETURN VARCHAR2;


FUNCTION getViewColumnIsKey(
  p_view_name          VARCHAR2,
  p_column_name        VARCHAR2
)
RETURN VARCHAR2;


FUNCTION getObjectRefClassName(
  p_class_name         VARCHAR2,
  p_ref_obj_id_no      NUMBER
)
RETURN VARCHAR2;



FUNCTION getRelationColumnName(
  p_class_name         VARCHAR2,
  p_ref_obj_id_no      NUMBER
)
RETURN VARCHAR2;


FUNCTION getRelIdFromColumnName(
  p_class_name         VARCHAR2,
  p_column_name        VARCHAR2
)
RETURN VARCHAR2;

FUNCTION getClassAttributeDbMappingType(
  p_class_name          VARCHAR2,
  p_attribute_name       VARCHAR2
)
RETURN VARCHAR2;

FUNCTION getClassAttributeLabel(
  p_class_name          VARCHAR2,
  p_attribute_name       VARCHAR2
)
RETURN VARCHAR2;

FUNCTION getPresSyntaxProstyCode(
  p_code          VARCHAR2
)
RETURN VARCHAR2;

FUNCTION getClassType(
  p_class_name          VARCHAR2
)
RETURN VARCHAR2;


FUNCTION getStaticPres(
  p_class_name          VARCHAR2,
  p_attribute_name       VARCHAR2
)
RETURN VARCHAR2;

FUNCTION getClassDBAttributeTable(
  p_class_name          VARCHAR2
)
RETURN VARCHAR2;

FUNCTION HasTableColumn(p_table_name VARCHAR2, p_column_name VARCHAR2) RETURN BOOLEAN;

FUNCTION getGroupModelLabel(
  p_group_type          VARCHAR2,
  p_object_type      VARCHAR2,
  p_parent_group_type       VARCHAR2,
  p_parent_object_type  VARCHAR2
)
RETURN VARCHAR2;

FUNCTION getUomCode(
  p_class_name          VARCHAR2,
  p_attribute_name       VARCHAR2
)
RETURN VARCHAR2;

FUNCTION getClassWhereCondition(
  p_class_name          VARCHAR2
)
RETURN VARCHAR2;
--

FUNCTION IsFunction(
      p_class_name      VARCHAR2,
      p_attribute_name    VARCHAR2)
RETURN BOOLEAN;

FUNCTION getClassAttrDbSqlSyntax(
      p_class_name      VARCHAR2,
      p_attribute_name    VARCHAR2)
RETURN VARCHAR2;

FUNCTION getClassRelDbSqlSyntax(
      p_from_class_name   VARCHAR2,
      p_to_class_name      VARCHAR2,
      p_role_name          VARCHAR2)
RETURN VARCHAR2;

FUNCTION getClassRelDbMappingType(
      p_from_class_name   VARCHAR2,
      p_to_class_name      VARCHAR2,
      p_role_name          VARCHAR2)
RETURN VARCHAR2;



FUNCTION getTruncatedDate(p_class_name  VARCHAR2,
              p_date    DATE)
RETURN DATE;

FUNCTION IsReadOnlyClass(
        p_class_name  VARCHAR2
        )
RETURN VARCHAR2;

FUNCTION getEcPackage(
        p_class_name  VARCHAR2
        )
RETURN VARCHAR2;

FUNCTION IsParentRelation(
      p_child_class    VARCHAR2,
      p_parent_class    VARCHAR2,
      p_role_name      VARCHAR2)
RETURN VARCHAR2;

FUNCTION getGroupModelDepPopupPres(
      p_child_class    VARCHAR2,
      p_parent_class    VARCHAR2,
      p_role_name      VARCHAR2)
RETURN VARCHAR2;

FUNCTION getGroupModelDepPopupSortOrder(
      p_child_class    VARCHAR2,
      p_parent_class    VARCHAR2,
      p_role_name      VARCHAR2)
RETURN NUMBER;

FUNCTION IsValidTabCol(
  p_table_name  VARCHAR2,
  p_column_name  VARCHAR2
)
RETURN BOOLEAN;


FUNCTION getClassAttributeDataType(
  p_class_name          VARCHAR2,
  p_attribute_name       VARCHAR2
)
RETURN VARCHAR2;


FUNCTION getGroupModelLevelSortOrder(
         p_group_type      VARCHAR2,
      p_child_class    VARCHAR2,
      p_parent_class    VARCHAR2,
      p_role_name      VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

FUNCTION IsRevTextMandatory(p_class_name  VARCHAR2)
RETURN VARCHAR2;

FUNCTION IsImplementationsDefined(p_interface_name  VARCHAR2)
RETURN VARCHAR2;

FUNCTION IsValidAttribute(
   p_class_name   VARCHAR2,
   p_attribute_name VARCHAR2
)
RETURN BOOLEAN;

FUNCTION GetSchemaName
RETURN VARCHAR2;

FUNCTION IsUsingUserFunction
RETURN VARCHAR2;


FUNCTION hasJournalView(p_class_name VARCHAR2)
RETURN VARCHAR2;

FUNCTION getClassKeys(p_class_name VARCHAR2)
RETURN VARCHAR2;

FUNCTION getClassNonKeysMandatory(p_class_name VARCHAR2)
RETURN VARCHAR2;

PROCEDURE RefreshMViews(p_refresh_method IN VARCHAR2 DEFAULT NULL, p_force IN VARCHAR2 DEFAULT 'N');

END;