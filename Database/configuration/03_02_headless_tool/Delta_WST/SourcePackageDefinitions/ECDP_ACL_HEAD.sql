CREATE OR REPLACE PACKAGE EcDp_ACL IS

/****************************************************************
** Package        :  EcDp_ACL, header part
**
** $Revision: 1.9 $
**
** Purpose        :  ACL list population
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
*****************************************************************/

  CURSOR c_acl_class(p_class_name VARCHAR2) IS
        SELECT DISTINCT class_name, class_type, owner_class_name  FROM (
        SELECT class_name, class_type, owner_class_name
        FROM   class_cnfg
        WHERE  EcDp_ClassMeta_Cnfg.getAccessControlInd(class_name)='Y' AND (class_type='OBJECT' OR class_type='INTERFACE')
        AND    NVL(p_class_name,class_name)=class_name
      UNION ALL
        -- Data classes with access controlled owner
        SELECT c.class_name, c.class_type, c.owner_class_name
        FROM   class_cnfg p
        ,      class_cnfg c
        WHERE  (p.class_type='OBJECT' OR p.class_type='INTERFACE')
        AND    EcDp_ClassMeta_Cnfg.getAccessControlInd(p.class_name)='Y'
        AND    c.class_type='DATA' AND c.owner_class_name=p.class_name
        AND    NVL(p_class_name,c.class_name)=c.class_name
      UNION ALL
        -- Data classes with access controlled relation
        SELECT to_class_name AS class_name, t.class_type, t.owner_class_name
        FROM   class_relation_cnfg r
        ,      class_cnfg f
        ,      class_cnfg t
        WHERE  r.to_class_name=t.class_name
        AND    r.from_class_name=f.class_name
        AND    (f.class_type='OBJECT' OR f.class_type='INTERFACE')
        AND    t.class_type='DATA'
        AND    EcDp_ClassMeta_Cnfg.getAccessControlInd(f.class_name)='Y'
        AND    Nvl(EcDp_ClassMeta_Cnfg.getAccessControlMethod(r.from_class_name, r.to_class_name, r.role_name),'NA')='ACL_LOOKUP'
        AND    NVL(p_class_name,r.to_class_name)=r.to_class_name
      )
      ORDER BY class_name;

  ----------------------------------------------------------------------------
  -- List/Set of VARCHAR2(32)
  ----------------------------------------------------------------------------
  TYPE Varchar32L_t IS TABLE OF VARCHAR2(32) NOT NULL;
  -- Helper functions for set manipulation
  FUNCTION SetFind(p_list IN Varchar32L_t, p_element IN VARCHAR2) RETURN INTEGER;
  FUNCTION SetContains(p_list IN Varchar32L_t, p_element IN VARCHAR2) RETURN BOOLEAN;
  FUNCTION SetDistinct(p_list IN Varchar32L_t) RETURN Varchar32L_t;
  FUNCTION SetUnion(p_list_a IN Varchar32L_t, p_list_b IN Varchar32L_t) RETURN Varchar32L_t;
  FUNCTION SetIntersect(p_list_a IN Varchar32L_t, p_list_b IN Varchar32L_t) RETURN Varchar32L_t;
  FUNCTION SetMinus(p_list_a IN Varchar32L_t, p_list_b IN Varchar32L_t) RETURN Varchar32L_t;
  ----------------------------------------------------------------------------

  ----------------------------------------------------------------------------
  -- Structures, functions and procedures for relation info
  ----------------------------------------------------------------------------
  TYPE Relation_t IS RECORD (
      id                    BINARY_INTEGER,
      from_class_name       class_cnfg.class_name%TYPE,
      to_class_name         class_cnfg.class_name%TYPE,
      role_name             class_relation_cnfg.role_name%TYPE,
      access_control_method class_rel_property_cnfg.property_value%TYPE,
      db_mapping_type       class_relation_cnfg.db_mapping_type%TYPE,
      db_sql_syntax         class_relation_cnfg.db_sql_syntax%TYPE,
      is_key                class_relation_cnfg.is_key%TYPE,
      is_mandatory          VARCHAR2(1),
      report_only_ind       VARCHAR2(1),
      db_object_attribute   class_cnfg.db_object_attribute%TYPE,
      db_object_name        class_cnfg.db_object_name%TYPE

  );
  -- List of Relation_t
  TYPE RelationL_t IS TABLE OF Relation_t;
  -- Reads all access controlled relations into internal structure.
  PROCEDURE RefreshRelations;
  -- Reads all access controlled relations into internal structure.
  FUNCTION  GetRelations(p_from_class VARCHAR2, p_to_class VARCHAR2, p_role_name VARCHAR2, p_method VARCHAR2) RETURN RelationL_t;
  -- Register object in internal cache.
  PROCEDURE RegisterObject(p_object_id IN VARCHAR2, p_class_name IN VARCHAR2);
  -- Register object relation in internal cache.
  PROCEDURE RegisterObjectReference(p_relation_id INTEGER, p_from_id VARCHAR2, p_to_id VARCHAR2);
  ----------------------------------------------------------------------------

  ----------------------------------------------------------------------------
  -- Object-cache structures, functions and procedures
  ----------------------------------------------------------------------------
  TYPE Object_t IS RECORD (
      object_id         acl_objects.object_id%TYPE,
      class_name        class_cnfg.class_name%TYPE,
      resolved_roles    Varchar32L_t:=Varchar32L_t(),
      partitioned_roles Varchar32L_t:=Varchar32L_t(),
      resolved          BOOLEAN:=FALSE,
      processing        BOOLEAN:=FALSE
  );
  -- ObjectCache structure
  TYPE ObjectM_t IS TABLE OF Object_t INDEX BY acl_objects.object_id%TYPE;
  ----------------------------------------------------------------------------

  ----------------------------------------------------------------------------
  -- Nested maps indexed by VARCHAR2(32)
  ----------------------------------------------------------------------------
  -- Varchar32_M1_t: One level of nesting
  TYPE Varchar32_M1_t IS TABLE OF VARCHAR2(32) INDEX BY VARCHAR2(32);
  -- Varchar32_M2_t: Two levels of nesting
  TYPE Varchar32_M2_t IS TABLE OF Varchar32_M1_t INDEX BY VARCHAR2(32);
  -- Varchar32_M3_t: Three levels of nesting
  TYPE Varchar32_M3_t IS TABLE OF Varchar32_M2_t INDEX BY VARCHAR2(32);
  -- Overloaded helper function that returns keys as a list of VARCHAR2(32)
  FUNCTION KeySet(p_map IN Varchar32_M3_t) RETURN Varchar32L_t;
  FUNCTION KeySet(p_map IN Varchar32_M2_t) RETURN Varchar32L_t;
  FUNCTION KeySet(p_map IN Varchar32_M1_t) RETURN Varchar32L_t;
  FUNCTION KeySet(p_map IN ObjectM_t) RETURN Varchar32L_t;
  ----------------------------------------------------------------------------

  -- Refresh ACL table for all objects
  PROCEDURE RefreshAll;

  -- Refresh ACL table for p_object_id and its successors.
  -- Valid values for p_action:
  --       'DELETING'
  --       'INSERTING'
  --       'UPDATING'
  PROCEDURE RefreshObject(p_object_id VARCHAR2, p_class_name VARCHAR2, p_action VARCHAR2);

  -- Raise application error if current appUser does not have access to input object
  PROCEDURE AssertAccess(p_object_id  VARCHAR2, p_class_name VARCHAR2);

  -- Set to TRUE if RefreshObject should write trace info to t_temptext
  DebugFlag      BOOLEAN:=TRUE;

  -- Set to FALSE to disable RefreshObject
  AutoRefresh    BOOLEAN:=TRUE;

  -- Test private functions and procedures
  FUNCTION AutomatedUnitTest
  RETURN BOOLEAN;

END EcDp_ACL;