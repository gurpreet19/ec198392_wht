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
**
** Created:     28.02.03  Arild Vervik, EC
**
**
** Modification history:
**
**
** Date:      Whom:  Change description:
** --------   ----- --------------------------------------------
** 22.05.03   AV    Added new function getObjectRefClassName
** 27.05.03   AV    Added 3 new functions: getViewColumnIsKey, getRelationColumnName, getRelIdFromColumnName
** 18.06.03   AV    Added Ltrim/Rtrim on attribute and role name
** 14.07.03    KSN    Added 2 new functions. getClassAttributeFormatMask, getClassAttributeDbMappingType
** 17.07.03    KSN    Added 2 new functions. getClassAttributeLabel, getPresSyntaxProstyCode
** 22.07.03   AV    Added function getClassType
**            KSN   Removed format mask method
** 28.11.03   SHN   Added function getClassDbAttributeTable
** 11.05.2004 FBa   Added function getUOM
** 07.06.04   SHN   Added cursor c_report_class_attr
** 07.06.04   SHN   Added function getClassWhereCondition
** 07.09.04   BIH   #1491 - Fixed bug in c_intersect_columns when p_is_key='Y' and IS_KEY=NULL for a column
** 02.10.04   AV    Added is_key to relation cursor
** 18.10.04   AV    Added new cursor for Trigger Actions
** 26.10.04   AV    Added 2 new columns to c_classes_attr cursor
** 31.01.05   SHN   Added function getTruncatedDate
** 17.02.05   AV    Changed references for renamed column is_private => disabled_ind
** 07.03.05   SHN   Added function getEcPackage
** 11.03.05   SHN   Added function IsParentRelation
** 01.04.05   SHN   Added function IsValidTabCol
** 12.04.05   DN    Added PRAGMAS.
** 22.04.05   ROV   Tracker #2194: Added missing check for disabled_ind in cursor c_intersect_columns
** 25.05.05   ROV   Added method getClassAttributeDataType
** 18.07.05   SHN   Added function IsRevTextMandatory. Tracker 2109.
** 29.08.05   AV    Added function IsImplementationsDefined.  Tracker 2574
** 01.03.07   SIAH  Added function IsValidAttribute
** 26.03.07   HUS   Added function GetSchemaName
** 30.04.07   HUS   ECPD-4908: Extended c_classes_rel cursor with access_control_method column.
** 26.02.08   KSN  ECPD-4671: Support for disabling class triggers
** 28.01.11   oonnnng	ECPD-16331: Revise the cursor c_intersect_columns statement to exclude attribute with 'Report View Only=Y' when retrieving record.
**************************************************************/

FUNCTION getDataType(p_data_type VARCHAR2)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getDataType, WNPS, WNDS, RNPS);

  CURSOR c_classes (p_class_name VARCHAR2) IS
     SELECT *
     FROM class_db_mapping x
    WHERE class_name = p_class_name;


CURSOR c_classes_attr (p_class_name VARCHAR2, p_private VARCHAR2 DEFAULT 'N', p_attribute_name VARCHAR2 DEFAULT NULL) IS
  SELECT
      cm.class_name,
      LTRIM(RTRIM(cm.attribute_name)) attribute_name ,
      cm.db_mapping_type,
      cm.db_sql_syntax,
      cm.sort_order,
      ca.is_key,
      ca.is_mandatory,
      ca.context_code,
      EcDp_ClassMeta.getDataType(ca.data_type) data_type,
      ca.precision,
      ca.disabled_ind,
      ca.default_value,
      Nvl(ca.report_only_ind,'N') report_only_ind
  FROM class_attribute ca, class_attr_db_mapping cm
  WHERE cm.class_name (+) = ca.class_name
    AND cm.attribute_name (+) = ca.attribute_name
    AND ca.class_name = p_class_name
    AND Nvl(ca.disabled_ind,'N') = nvl(p_private, 'X')
    AND cm.attribute_name = Nvl(p_attribute_name,cm.attribute_name)
  ORDER BY cm.SORT_ORDER
  ;


CURSOR c_dataclasses_attr (p_class_name VARCHAR2, p_private VARCHAR2 DEFAULT 'N', p_attribute_name VARCHAR2 DEFAULT NULL) IS
  SELECT
      cm.class_name,
      LTRIM(RTRIM(cm.attribute_name)) attribute_name,
      cm.db_mapping_type,
      cm.db_sql_syntax,
      cm.sort_order,
      ca.is_key,
      ca.is_mandatory,
      ca.context_code,
      EcDp_ClassMeta.getDataType(ca.data_type) data_type,
      ca.precision,
      ca.disabled_ind is_private ,
      ca.default_value,
      Nvl(ca.report_only_ind,'N') report_only_ind
  FROM class_attribute ca, class_attr_db_mapping cm
  WHERE cm.class_name (+) = ca.class_name
    AND cm.attribute_name (+) = ca.attribute_name
    AND ca.class_name = p_class_name
    AND ca.attribute_name NOT IN ('OBJECT_CODE') -- To support both definitintion with or without this explecite defined
    AND Nvl(ca.disabled_ind,'N') = nvl(p_private, 'X')
    AND cm.attribute_name = Nvl(p_attribute_name,cm.attribute_name)
  ORDER BY cm.SORT_ORDER
  ;

CURSOR c_sub_classes_attr (p_class_name VARCHAR2, p_private VARCHAR2 DEFAULT 'N', p_attribute_name VARCHAR2 DEFAULT NULL) IS
  SELECT
      class_name,
      LTRIM(RTRIM(attribute_name)) attribute_name,
      context_code,
      disabled_ind is_private
  FROM class_attribute x
  WHERE class_name = p_class_name
    AND EXISTS (select 'x' from class where class_name = x.class_name and class_type = 'SUB_CLASS')
    AND Nvl(disabled_ind,'N') = nvl(p_private, 'X')
    AND attribute_name = Nvl(p_attribute_name,attribute_name)
  ;


CURSOR c_classes_rel (p_class_name VARCHAR2, p_role_name VARCHAR2 DEFAULT NULL, p_disabled_ind VARCHAR2 DEFAULT 'N', p_report_only_ind VARCHAR2 DEFAULT 'N' ) IS
  SELECT
    cm.from_class_name,
    cm.to_class_name,
    LTRIM(RTRIM(cm.role_name)) role_name,
    cm.db_mapping_type,
    cm.db_sql_syntax,
    cm.sort_order,
    cr.is_mandatory,
    cr.is_bidirectional,
    cr.context_code,
    cr.multiplicity,
    cr.disabled_ind,
    cr.is_key,
      Nvl(cr.report_only_ind,'N') report_only_ind,
      cr.group_type,
    cr.access_control_method
  FROM class_relation cr, class_rel_db_mapping cm
  WHERE cr.from_class_name = cm.from_class_name (+)
    AND cr.to_class_name = cm.to_class_name (+)
    AND cr.role_name = cm.role_name (+)
    AND cr.to_class_name = p_class_name
    AND cr.role_name = Nvl(p_role_name,cr.role_name)
    AND multiplicity IN ('1:1', '1:N')
    AND Nvl(cr.disabled_ind,'N') = Nvl(p_disabled_ind,'X')
    AND Nvl(cr.report_only_ind,'N') = Nvl(p_report_only_ind,Nvl(cr.report_only_ind,'N'))
  ORDER BY cm.sort_order
  ;

CURSOR c_classes_interface (p_class_name VARCHAR2) IS
  SELECT
      cd.child_class
  FROM class_dependency cd
  WHERE cd.parent_class = p_class_name
  ;

CURSOR c_classes_intf_attr (p_class_name VARCHAR2, p_private VARCHAR2 DEFAULT 'N') IS
  SELECT
      LTRIM(RTRIM(ca.attribute_name)) attribute_name
  FROM class c, class_attribute ca
  WHERE c.class_name  = p_class_name
  AND   c.class_name = ca.class_name
  AND   c.class_type = 'INTERFACE'
  AND Nvl(ca.disabled_ind,'N') = nvl(p_private, 'X')  ;


CURSOR c_classes_intf_rel (p_class_name VARCHAR2) IS
  SELECT
    LTRIM(RTRIM(cr.role_name)) role_name
  FROM class_relation cr
  WHERE cr.to_class_name = p_class_name
    AND multiplicity IN ('1:1', '1:N')
  ;


CURSOR c_intersect_columns (
    p_from_class_name IN VARCHAR2,
    p_to_class_name IN VARCHAR2,
    p_is_key IN VARCHAR2)
  IS
    SELECT ca.attribute_name
      FROM class_attribute ca, class_attr_db_mapping cadm
     WHERE ca.class_name = p_to_class_name
       AND cadm.class_name=ca.class_name AND cadm.attribute_name=ca.attribute_name
       AND cadm.db_mapping_type='COLUMN'
       AND (ca.is_key = p_is_key OR p_is_key IS NULL OR (ca.is_key IS NULL AND p_is_key='N'))
       AND Nvl(ca.disabled_ind,'N') = 'N'
       AND NVL(ca.report_only_ind,'N') = 'N'
    INTERSECT
    SELECT ca.attribute_name
      FROM class_attribute ca, class_attr_db_mapping cadm
     WHERE ca.class_name = p_from_class_name
       AND cadm.class_name=ca.class_name AND cadm.attribute_name=ca.attribute_name
       AND cadm.db_mapping_type in ('COLUMN', 'FUNCTION')
       AND Nvl(ca.disabled_ind,'N') = 'N'
       AND Nvl(ca.report_only_ind,'N') = 'N';

CURSOR c_class_trigger_action (p_class_name VARCHAR2, p_trigger_type VARCHAR2 ) IS
  SELECT
    triggering_event,
      SORT_ORDER,
      DB_SQL_SYNTAX
  FROM class_trigger_action ta
  WHERE ta.class_name = p_class_name
  AND   ta.trigger_type = p_trigger_type
  AND  Nvl(ta.disabled_ind,'N') = 'N'
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
PRAGMA RESTRICT_REFERENCES (IsPropertyMandatory, WNPS, WNDS, RNPS);

FUNCTION OwnerClassName(
  p_class_name          VARCHAR2
)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (OwnerClassName, WNPS, WNDS, RNPS);

FUNCTION SuperClassName(
  p_class_name          VARCHAR2
)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (SuperClassName, WNPS, WNDS, RNPS);


FUNCTION CountAttrRecords(
   p_class_name      VARCHAR2,
   p_table_name       VARCHAR2,
   p_column_name        VARCHAR2
)
RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (CountAttrRecords, WNPS, WNDS, RNPS);

FUNCTION IsValidTabCol(
   p_class_name      VARCHAR2,
   p_table_owner        VARCHAR2,
   p_table_name       VARCHAR2,
   p_column_name        VARCHAR2
)
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES (IsValidTabCol, WNPS, WNDS, RNPS);

FUNCTION getClassDateHandeling(
  p_class_name          VARCHAR2,
  p_class_type          VARCHAR2
)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (getClassDateHandeling, WNPS, WNDS, RNPS);

FUNCTION getClassDBTable(
  p_class_name          VARCHAR2
)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (getClassDBTable, WNPS, WNDS, RNPS);


FUNCTION getClassViewName(
  p_class_name          VARCHAR2
)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (getClassViewName, WNPS, WNDS, RNPS);

FUNCTION getClassJournalIfCondition(
  p_class_name          VARCHAR2
)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (getClassJournalIfCondition, WNPS, WNDS, RNPS);


FUNCTION getViewColumnMandatory(
  p_view_name          VARCHAR2,
  p_column_name        VARCHAR2
)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (getViewColumnMandatory, WNPS, WNDS, RNPS);


FUNCTION getViewColumnIsKey(
  p_view_name          VARCHAR2,
  p_column_name        VARCHAR2
)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (getViewColumnIsKey, WNPS, WNDS, RNPS);


FUNCTION getObjectRefClassName(
  p_class_name         VARCHAR2,
  p_ref_obj_id_no      NUMBER
)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (getObjectRefClassName, WNPS, WNDS, RNPS);



FUNCTION getRelationColumnName(
  p_class_name         VARCHAR2,
  p_ref_obj_id_no      NUMBER
)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (getRelationColumnName, WNPS, WNDS, RNPS);


FUNCTION getRelIdFromColumnName(
  p_class_name         VARCHAR2,
  p_column_name        VARCHAR2
)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (getRelIdFromColumnName, WNPS, WNDS, RNPS);

FUNCTION getClassAttributeDbMappingType(
  p_class_name          VARCHAR2,
  p_attribute_name       VARCHAR2
)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (getClassAttributeDbMappingType, WNPS, WNDS, RNPS);

FUNCTION getClassAttributeLabel(
  p_class_name          VARCHAR2,
  p_attribute_name       VARCHAR2
)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (getClassAttributeLabel, WNPS, WNDS, RNPS);

FUNCTION getPresSyntaxProstyCode(
  p_code          VARCHAR2
)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (getPresSyntaxProstyCode, WNPS, WNDS, RNPS);

FUNCTION getClassType(
  p_class_name          VARCHAR2
)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getClassType, WNPS, WNDS, RNPS);


FUNCTION getStaticPres(
  p_class_name          VARCHAR2,
  p_attribute_name       VARCHAR2
)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getStaticPres, WNPS, WNDS, RNPS);

FUNCTION getClassDBAttributeTable(
  p_class_name          VARCHAR2
)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (getClassDBAttributeTable, WNPS, WNDS, RNPS);

FUNCTION HasTableColumn(p_table_name VARCHAR2, p_column_name VARCHAR2) RETURN BOOLEAN;

FUNCTION getGroupModelLabel(
  p_group_type          VARCHAR2,
  p_object_type      VARCHAR2,
  p_parent_group_type       VARCHAR2,
  p_parent_object_type  VARCHAR2
)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (getGroupModelLabel, WNPS, WNDS, RNPS);

FUNCTION getUomCode(
  p_class_name          VARCHAR2,
  p_attribute_name       VARCHAR2
)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getUomCode, WNPS, WNDS, RNPS);

FUNCTION getClassWhereCondition(
  p_class_name          VARCHAR2
)
RETURN VARCHAR2;
--PRAGMA RESTRICT_REFERENCES (getClassWhereCondition, WNPS, WNDS, RNPS);

FUNCTION IsFunction(
      p_class_name      VARCHAR2,
      p_attribute_name    VARCHAR2)
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES (IsFunction, WNPS, WNDS, RNPS);

FUNCTION getClassAttrDbSqlSyntax(
      p_class_name      VARCHAR2,
      p_attribute_name    VARCHAR2)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getClassAttrDbSqlSyntax, WNPS, WNDS, RNPS);

FUNCTION getClassRelDbSqlSyntax(
      p_from_class_name   VARCHAR2,
      p_to_class_name      VARCHAR2,
      p_role_name          VARCHAR2)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getClassRelDbSqlSyntax, WNPS, WNDS, RNPS);

FUNCTION getClassRelDbMappingType(
      p_from_class_name   VARCHAR2,
      p_to_class_name      VARCHAR2,
      p_role_name          VARCHAR2)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getClassRelDbSqlSyntax, WNPS, WNDS, RNPS);



FUNCTION getTruncatedDate(p_class_name  VARCHAR2,
              p_date    DATE)
RETURN DATE;
PRAGMA RESTRICT_REFERENCES (getTruncatedDate, WNPS, WNDS, RNPS);

FUNCTION IsReadOnlyClass(
        p_class_name  VARCHAR2
        )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (IsReadOnlyClass, WNPS, WNDS, RNPS);

FUNCTION getEcPackage(
        p_class_name  VARCHAR2
        )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getEcPackage, WNPS, WNDS, RNPS);

FUNCTION IsParentRelation(
      p_child_class    VARCHAR2,
      p_parent_class    VARCHAR2,
      p_role_name      VARCHAR2)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (IsParentRelation, WNPS, WNDS, RNPS);

FUNCTION getGroupModelDepPopupPres(
      p_child_class    VARCHAR2,
      p_parent_class    VARCHAR2,
      p_role_name      VARCHAR2)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (getGroupModelDepPopupPres, WNPS, WNDS, RNPS);

FUNCTION getGroupModelDepPopupSortOrder(
      p_child_class    VARCHAR2,
      p_parent_class    VARCHAR2,
      p_role_name      VARCHAR2)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGroupModelDepPopupSortOrder, WNPS, WNDS, RNPS);

FUNCTION IsValidTabCol(
  p_table_name  VARCHAR2,
  p_column_name  VARCHAR2
)
RETURN BOOLEAN;

PRAGMA RESTRICT_REFERENCES(IsValidTabCol, WNDS, WNPS, RNPS);


FUNCTION getClassAttributeDataType(
  p_class_name          VARCHAR2,
  p_attribute_name       VARCHAR2
)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (getClassAttributeDataType, WNPS, WNDS, RNPS);


FUNCTION getGroupModelLevelSortOrder(
         p_group_type      VARCHAR2,
      p_child_class    VARCHAR2,
      p_parent_class    VARCHAR2,
      p_role_name      VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getGroupModelDepPopupSortOrder, WNPS, WNDS, RNPS);

FUNCTION IsRevTextMandatory(p_class_name  VARCHAR2)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (IsRevTextMandatory, WNPS, WNDS, RNPS);

FUNCTION IsImplementationsDefined(p_interface_name  VARCHAR2)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (IsRevTextMandatory, WNPS, WNDS, RNPS);

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

END;