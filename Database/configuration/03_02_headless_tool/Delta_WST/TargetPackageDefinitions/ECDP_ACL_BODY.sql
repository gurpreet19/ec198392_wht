CREATE OR REPLACE PACKAGE BODY EcDp_ACL IS
--<HEAD>
/****************************************************************
** Package        :  EcDp_ACL, body part
**
** $Revision: 1.15 $
**
** Purpose        :  ACL table population
**
** Documentation  :  www.energy-components.com
**
** Created  : 13-Mar-2007, Hanne Austad
**
** Modification history:
**
**  Date           Whom  	Change description:
**  ------         ----- 	--------------------------------------
**  13-Mar-2007    HUS   	Initial version
**  09-Jan-2009    kaurrjes	ECPD-10503: changed the lv_query in ecdp_acl.EvaluatePartitions to LONG.
****************************************************************/
--</HEAD>

  --
  -- Map of Varchar32L_t
  --
  TYPE Varchar32L_M1_t IS TABLE OF Varchar32L_t INDEX BY VARCHAR2(32);

  --
  -- Map with Key=CLASS_NAME, Value=IdList_t. Initialised by Refresh for all
  -- OBJECT and INTERFACE classes with access control enabled, and used by the
  -- recursive ResolveObjectRoles. Done to avoid repeated and recursive calls to
  -- GetClassPartitionRoles.
  --
  lt_class_partition_roles Varchar32L_M1_t;

  --
  -- List of roles that should be propagated to the ACL table.
  -- Initialised by Refresh, and used by private functions to
  -- avoid repeated calls to GetAllRoles from recursive functions.
  -- I.e. GetAllRoles is called once per ACL table Refresh.
  --
  lt_all_roles Varchar32L_t:=Varchar32L_t();

  TYPE RelationM_t IS TABLE OF Relation_t INDEX BY BINARY_INTEGER;

  FromToRoleRelMap Varchar32_M3_t;
  ToFromRoleRelMap Varchar32_M3_t;

  RefFromToCache   Varchar32_M3_t;
  RefToFromCache   Varchar32_M3_t;

  Relations        RelationM_t;

  ObjectCache    ObjectM_t;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : SetFind                                                                      --
-- Description    : Returns p_element's position in p_list, or -1 if p_element is not in p_list. --
--                                                                                               --
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
FUNCTION SetFind(
         p_list    IN Varchar32L_t
,        p_element IN VARCHAR2)
RETURN INTEGER
IS
--</FUNC>
--</EC-DOC>
  li_retval  INTEGER:=-1;
  li_current INTEGER;
BEGIN
  li_current:=p_list.FIRST;
  LOOP
     EXIT WHEN li_current IS NULL OR li_retval!=-1;
     IF p_list(li_current)=p_element THEN
       li_retval:=li_current;
     END IF;
     li_current := p_list.NEXT(li_current);
   END LOOP;
   RETURN li_retval;
END SetFind;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : SetContains                                                                  --
-- Description    : Returns TRUE is the p_list contains p_element. Returns FALSE otherwise.      --
--                                                                                               --
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
FUNCTION SetContains(
         p_list    IN Varchar32L_t
,        p_element IN VARCHAR2)
RETURN BOOLEAN
IS
--</FUNC>
--</EC-DOC>
  lb_retval BOOLEAN:=FALSE;
BEGIN
  IF SetFind(p_list, p_element)!=-1 THEN
     lb_retval:=TRUE;
  END IF;
  RETURN lb_retval;
END SetContains;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : SetDistinct                                                                  --
-- Description    : Returns list of distinct elements in p_list. Userd to remove duplicates.     --
--                                                                                               --
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
FUNCTION SetDistinct(p_list IN Varchar32L_t)
RETURN Varchar32L_t
IS
--</FUNC>
--</EC-DOC>
  lt_retlist Varchar32L_t:=Varchar32L_t();
  li_current INTEGER;
BEGIN
  li_current:=p_list.FIRST;
  LOOP
     EXIT WHEN li_current IS NULL;
     IF SetContains(lt_retlist, p_list(li_current))=FALSE THEN
       lt_retlist.EXTEND(1);
       lt_retlist(lt_retlist.COUNT):=p_list(li_current);
     END IF;
     li_current := p_list.NEXT(li_current);
   END LOOP;
   RETURN lt_retlist;
END SetDistinct;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : SetUnion                                                                     --
-- Description    : Returns list of distinct elements that are in p_list_a or in p_list_b.       --
--                                                                                               --
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
FUNCTION SetUnion(
         p_list_a IN Varchar32L_t
,        p_list_b IN Varchar32L_t)
RETURN Varchar32L_t
IS
--</FUNC>
--</EC-DOC>
  lt_retlist  Varchar32L_t:=Varchar32L_t();
  li_current INTEGER;
BEGIN
  lt_retlist:=SetDistinct(p_list_a);
  li_current:=p_list_b.FIRST;
  LOOP
     EXIT WHEN li_current IS NULL;
     IF SetContains(lt_retlist, p_list_b(li_current))=FALSE THEN
       lt_retlist.EXTEND(1);
       lt_retlist(lt_retlist.COUNT):=p_list_b(li_current);
     END IF;
     li_current := p_list_b.NEXT(li_current);
   END LOOP;
  RETURN lt_retlist;
END SetUnion;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : SetIntersect                                                                 --
-- Description    : Returns list of distinct elements that are in p_list_a and in p_list_b.      --
--                                                                                               --
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
FUNCTION SetIntersect(
         p_list_a IN Varchar32L_t
,        p_list_b IN Varchar32L_t)
RETURN Varchar32L_t
IS
--</FUNC>
--</EC-DOC>
  lt_retlist  Varchar32L_t:=Varchar32L_t();
  li_current  INTEGER;
BEGIN
  li_current:=p_list_a.FIRST;
  LOOP
     EXIT WHEN li_current IS NULL;
     IF SetContains(p_list_b, p_list_a(li_current))=TRUE AND SetContains(lt_retlist, p_list_a(li_current))=FALSE THEN
        lt_retlist.EXTEND(1);
        lt_retlist(lt_retlist.COUNT):=p_list_a(li_current);
     END IF;
     li_current := p_list_a.NEXT(li_current);
   END LOOP;
  RETURN lt_retlist;
END SetIntersect;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : SetMinus                                                                     --
-- Description    : Returns list of elements in p_list_a that are not in p_list_b.               --
--                                                                                               --
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
FUNCTION SetMinus(
         p_list_a IN Varchar32L_t
,        p_list_b IN Varchar32L_t)
RETURN Varchar32L_t
IS
--</FUNC>
--</EC-DOC>
  lt_retlist  Varchar32L_t:=Varchar32L_t();
  li_current  INTEGER;
  li_position INTEGER:=-1;
BEGIN
  lt_retlist:=p_list_a;
  li_current:=p_list_b.FIRST;
  LOOP
     EXIT WHEN li_current IS NULL;
     li_position:=SetFind(lt_retlist, p_list_b(li_current));
     IF li_position!=-1 THEN
        lt_retlist.DELETE(li_position);
     END IF;
     li_current := p_list_b.NEXT(li_current);
   END LOOP;
  RETURN lt_retlist;
END SetMinus;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : KeySet                                                                       --
-- Description    : Returns keys in p_map as a list.                                             --
--                                                                                               --
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
FUNCTION KeySet(p_map IN Varchar32_M1_t)
RETURN Varchar32L_t
IS
--</FUNC>
--</EC-DOC>
  lt_key_list Varchar32L_t:=Varchar32L_t();
  lv_key      VARCHAR2(32);
BEGIN
  lv_key:=p_map.FIRST;
  LOOP
     EXIT WHEN lv_key IS NULL;
     lt_key_list.EXTEND(1);
     lt_key_list(lt_key_list.COUNT):=lv_key;
     lv_key:=p_map.NEXT(lv_key);
  END LOOP;
  RETURN SetDistinct(lt_key_list);
END KeySet;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : KeySet                                                                       --
-- Description    : Returns keys in p_map as a list.                                             --
--                                                                                               --
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
FUNCTION KeySet(p_map IN Varchar32_M2_t)
RETURN Varchar32L_t
IS
--</FUNC>
--</EC-DOC>
  lt_key_list Varchar32L_t:=Varchar32L_t();
  lv_key      VARCHAR2(32);
BEGIN
  lv_key:=p_map.FIRST;
  LOOP
     EXIT WHEN lv_key IS NULL;
     lt_key_list.EXTEND(1);
     lt_key_list(lt_key_list.COUNT):=lv_key;
     lv_key:=p_map.NEXT(lv_key);
  END LOOP;
  RETURN SetDistinct(lt_key_list);
END KeySet;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : KeySet                                                                       --
-- Description    : Returns keys in p_map as a list.                                             --
--                                                                                               --
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
FUNCTION KeySet(p_map IN Varchar32_M3_t)
RETURN Varchar32L_t
IS
--</FUNC>
--</EC-DOC>
  lt_key_list Varchar32L_t:=Varchar32L_t();
  lv_key      VARCHAR2(32);
BEGIN
  lv_key:=p_map.FIRST;
  LOOP
     EXIT WHEN lv_key IS NULL;
     lt_key_list.EXTEND(1);
     lt_key_list(lt_key_list.COUNT):=lv_key;
     lv_key:=p_map.NEXT(lv_key);
  END LOOP;
  RETURN SetDistinct(lt_key_list);
END KeySet;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : KeySet                                                                       --
-- Description    : Returns keys in p_map as a list.                                             --
--                                                                                               --
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
FUNCTION KeySet(p_map IN ObjectM_t)
RETURN Varchar32L_t
IS
--</FUNC>
--</EC-DOC>
  lt_key_list Varchar32L_t:=Varchar32L_t();
  lv_key      VARCHAR2(32);
BEGIN
  lv_key:=p_map.FIRST;
  LOOP
     EXIT WHEN lv_key IS NULL;
     lt_key_list.EXTEND(1);
     lt_key_list(lt_key_list.COUNT):=lv_key;
     lv_key:=p_map.NEXT(lv_key);
  END LOOP;
  RETURN SetDistinct(lt_key_list);
END KeySet;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetRelations                                                           --
-- Description    :
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
FUNCTION GetRelations(
         p_from_class IN VARCHAR2
,        p_to_class   IN VARCHAR2
,        p_role_name  IN VARCHAR2
,        p_method     IN VARCHAR2)
RETURN RelationL_t
IS
--</FUNC>
--</EC-DOC>
  lt_from_keys  Varchar32L_t;
  lt_to_keys    Varchar32L_t;
  lt_role_keys  Varchar32L_t;
  ln_id         INTEGER;
  lv_from       VARCHAR2(32);
  lv_to         VARCHAR2(32);
  lv_role       VARCHAR2(32);
  lt_relation   Relation_t;
  lt_result     RelationL_t:=RelationL_t();
BEGIN
  lt_from_keys:=KeySet(FromToRoleRelMap);
  FOR f IN 1..lt_from_keys.COUNT LOOP
      lv_from:=lt_from_keys(f);
      lt_to_keys:=KeySet(FromToRoleRelMap(lv_from));
      FOR t IN 1..lt_to_keys.COUNT LOOP
          lv_to:=lt_to_keys(t);
          lt_role_keys:=KeySet(FromToRoleRelMap(lv_from)(lv_to));
          FOR r IN 1..lt_role_keys.COUNT LOOP
              lv_role:=lt_role_keys(r);
              ln_id:=FromToRoleRelMap(lv_from)(lv_to)(lv_role);
              lt_relation:=Relations(ln_id);
              IF  NVL(p_from_class, lv_from)=lv_from
              AND NVL(p_to_class, lv_to)=lv_to
              AND NVL(p_role_name, lv_role)=lv_role
              AND NVL(p_method, lt_relation.access_control_method)=lt_relation.access_control_method THEN
                  lt_result.EXTEND(1);
                  lt_result(lt_result.COUNT):=Relations(ln_id);
              END IF;
          END LOOP;
      END LOOP;
  END LOOP;
  RETURN lt_result;
END GetRelations;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : RefreshRelations                                                             --
-- Description    :                                                                              --
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
PROCEDURE RefreshRelations
IS
--</FUNC>
--</EC-DOC>
  CURSOR c_acl_relations IS
     SELECT ROWNUM, rel.* FROM (
     SELECT m.from_class_name
     ,      m.to_class_name
     ,      m.role_name
     ,      m.db_mapping_type
     ,      m.db_sql_syntax
     ,      r.access_control_method
     ,      r.is_mandatory
     ,      r.is_key
     ,      r.report_only_ind
     ,      c.db_object_attribute
     ,      c.db_object_name
     ,      f.class_type AS from_class_type
     ,      t.class_type AS to_class_type
     FROM   class_relation r
     ,      class_rel_db_mapping m
     ,      class_db_mapping c
     ,      class f
     ,      class t
     WHERE  r.from_class_name=m.from_class_name
     AND    r.to_class_name=m.to_class_name
     AND    r.role_name=m.role_name
     AND    c.class_name=r.to_class_name
     AND    NVL(m.db_mapping_type,'FUNCTION') IN ('ATTRIBUTE','COLUMN')
     AND    r.access_control_method IS NOT NULL
     AND    r.from_class_name=f.class_name
     AND    r.to_class_name=t.class_name
     ORDER BY r.from_class_name,r.to_class_name,r.role_name
     ) rel;
BEGIN
  Relations.DELETE;
  FromToRoleRelMap.DELETE;
  ToFromRoleRelMap.DELETE;
  FOR c IN c_acl_relations LOOP
      Relations(c.rownum).id:=c.rownum;
      Relations(c.rownum).from_class_name:=c.from_class_name;
      Relations(c.rownum).to_class_name:=c.to_class_name;
      Relations(c.rownum).role_name:=c.role_name;
      Relations(c.rownum).access_control_method:=c.access_control_method;
      Relations(c.rownum).db_mapping_type:=c.db_mapping_type;
      Relations(c.rownum).db_sql_syntax:=c.db_sql_syntax;
      Relations(c.rownum).is_key:=c.is_key;
      Relations(c.rownum).is_mandatory:=c.is_mandatory;
      Relations(c.rownum).db_sql_syntax:=c.db_sql_syntax;
      Relations(c.rownum).report_only_ind:=c.report_only_ind;
      Relations(c.rownum).db_object_attribute:=c.db_object_attribute;
      Relations(c.rownum).db_object_name:=c.db_object_name;
      FromToRoleRelMap(c.from_class_name)(c.to_class_name)(c.role_name):=c.rownum;
      ToFromRoleRelMap(c.to_class_name)(c.from_class_name)(c.role_name):=c.rownum;
  END LOOP;
END RefreshRelations;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : RegisterObjectReference                                                      --
-- Description    : Register object relations in internal cache.                                 --
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
PROCEDURE RegisterObjectReference(p_relation_id IN INTEGER, p_from_id IN VARCHAR2, p_to_id IN VARCHAR2)
IS
--</FUNC>
--</EC-DOC>
BEGIN
     RefFromToCache(p_relation_id)(p_from_id)(p_to_id):='Y';
     RefToFromCache(p_relation_id)(p_to_id)(p_from_id):='Y';
END RegisterObjectReference;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : RegisterObject                                                               --
-- Description    : Register object in internal object cache.                                    --
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
PROCEDURE RegisterObject(p_object_id IN VARCHAR2, p_class_name IN VARCHAR2)
IS
--</FUNC>
--</EC-DOC>
BEGIN
  ObjectCache(p_object_id).object_id:=p_object_id;
  ObjectCache(p_object_id).class_name:=p_class_name;
END RegisterObject;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetObjectReferences                                                          --
-- Description    :                                                                              --
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
FUNCTION GetObjectReferences(p_map IN Varchar32_M3_t, p_relation_id IN INTEGER, p_object_id IN VARCHAR2)
RETURN Varchar32L_t
IS
--</FUNC>
--</EC-DOC>
  lt_list Varchar32L_t:=Varchar32L_t();
BEGIN
   IF  p_map.EXISTS(p_relation_id)
   AND p_map(p_relation_id).EXISTS(p_object_id) THEN
       lt_list:=KeySet(p_map(p_relation_id)(p_object_id));
   END IF;
   RETURN lt_list;
END GetObjectReferences;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetObjectPredecessors                                                        --
-- Description    :                                                                              --
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
FUNCTION GetObjectPredecessors(p_object_id IN VARCHAR2, p_class_name IN VARCHAR2)
RETURN Varchar32_M1_t
IS
--</FUNC>
--</EC-DOC>
  lt_predecessors  Varchar32_M1_t;
  lt_relation_list RelationL_t;
  lt_object_list   Varchar32L_t;
BEGIN
  lt_relation_list:=GetRelations(null, p_class_name, null, 'TO_CLASS');
  FOR r IN 1..lt_relation_list.COUNT LOOP
      lt_object_list:=GetObjectReferences(RefToFromCache, lt_relation_list(r).id, p_object_id);
      FOR o IN 1..lt_object_list.COUNT LOOP
          lt_predecessors(lt_object_list(o)):=lt_relation_list(r).from_class_name;
      END LOOP;
  END LOOP;
  lt_relation_list:=GetRelations(p_class_name, null, null, 'FROM_CLASS');
  FOR r IN 1..lt_relation_list.COUNT LOOP
      lt_object_list:=GetObjectReferences(RefFromToCache, lt_relation_list(r).id, p_object_id);
      FOR o IN 1..lt_object_list.COUNT LOOP
          lt_predecessors(lt_object_list(o)):=lt_relation_list(r).to_class_name;
      END LOOP;
  END LOOP;
  RETURN lt_predecessors;
END GetObjectPredecessors;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetObjectSuccessors                                                        --
-- Description    :                                                                              --
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
FUNCTION GetObjectSuccessors(p_object_id IN VARCHAR2, p_class_name IN VARCHAR2, p_relation_id IN NUMBER)
RETURN Varchar32_M1_t
IS
--</FUNC>
--</EC-DOC>
  lt_successors     Varchar32_M1_t;
  lt_object_list    Varchar32L_t;
  lt_relation_list1 RelationL_t:=RelationL_t();
  lt_relation_list2 RelationL_t:=RelationL_t();
BEGIN
  IF p_relation_id IS NULL THEN
    lt_relation_list1:=GetRelations(null, p_class_name, null, 'TO_CLASS');
  ELSIF Relations(p_relation_id).to_class_name=p_class_name THEN
    lt_relation_list1:=RelationL_t(Relations(p_relation_id));
  END IF;

  IF p_relation_id IS NULL THEN
    lt_relation_list2:=GetRelations(p_class_name, null, null, 'FROM_CLASS');
  ELSIF Relations(p_relation_id).from_class_name=p_class_name THEN
    lt_relation_list2:=RelationL_t(Relations(p_relation_id));
  END IF;

  FOR r IN 1..lt_relation_list1.COUNT LOOP
     lt_object_list:=GetObjectReferences(RefToFromCache, lt_relation_list1(r).id, p_object_id);
     FOR o IN 1..lt_object_list.COUNT LOOP
        lt_successors(lt_object_list(o)):=lt_relation_list1(r).from_class_name;
     END LOOP;
  END LOOP;

  FOR r IN 1..lt_relation_list2.COUNT LOOP
     lt_object_list:=GetObjectReferences(RefFromToCache, lt_relation_list2(r).id, p_object_id);
     FOR o IN 1..lt_object_list.COUNT LOOP
        lt_successors(lt_object_list(o)):=lt_relation_list2(r).to_class_name;
     END LOOP;
  END LOOP;

  RETURN lt_successors;
END GetObjectSuccessors;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : EvaluatePartitions                                                           --
-- Description    : Evaluate the object partitions for the input class and update the object     --
--                  cache with the list of roles that have access to an object according to      --
--                  the partions.                                                                --
--                  Uses "global" lt_all_roles variable to avoid repeated calls to               --
--                  GetPartitionedRoles.                                                         --
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
PROCEDURE EvaluatePartitions(p_class_name IN VARCHAR2, p_object_id IN VARCHAR2)
IS
--</FUNC>
--</EC-DOC>
  TYPE Cursor_t IS REF CURSOR;

  CURSOR c_partition(p_role_id VARCHAR2, p_class_name VARCHAR2) IS
    select p.*
    from   t_basis_object_partition p
    ,      t_basis_access a
    where  a.class_name=p_class_name
    and    a.role_id=p_role_id
    and    a.t_basis_access_id=p.t_basis_access_id
    order by p.t_basis_access_id;

  c cursor_t;

  lv_query     LONG;
  lt_rolelist  Varchar32L_t:=Varchar32L_t();
  lv_currole   VARCHAR2(32);
  lv_object_id VARCHAR2(32);
  lv_object_table class_db_mapping.db_object_name%TYPE;
  lv2_class_where class_db_mapping.db_where_condition%TYPE;

BEGIN
   IF lt_class_partition_roles.EXISTS(p_class_name) THEN
      lt_rolelist:=lt_class_partition_roles(p_class_name);
   END IF;

   lv_object_table := ec_class_db_mapping.db_object_name(p_class_name);
   lv2_class_where := ec_class_db_mapping.db_where_condition(p_class_name);

   FOR r IN 1..lt_rolelist.COUNT LOOP
      lv_currole:=lt_rolelist(r);
      FOR cur_rec IN c_partition(lv_currole, p_class_name) LOOP
          IF cur_rec.operator='IN' OR cur_rec.operator='NOT IN' OR cur_rec.operator='ALL' THEN
            IF r>1 THEN
               lv_query:=lv_query|| chr(10) || 'union all' || chr(10);
            END IF;
            lv_query:=lv_query
               || 'SELECT ''' || lv_currole || ''' AS role_id, object_id ' || chr(10)
            || 'FROM ' || lv_object_table ||'  o' ||chr(10) ;

            IF lv2_class_where IS NOT NULL THEN
              lv_query:=lv_query || 'where '||lv2_class_where;
            END IF;

            IF lv2_class_where IS NOT NULL AND cur_rec.operator<>'ALL' THEN

               lv_query:=lv_query|| 'AND ' || cur_rec.attribute_name || ' ' || cur_rec.operator || ' ' || nvl(cur_rec.attribute_text,'('''')');

            ELSIF cur_rec.operator<>'ALL' THEN

               lv_query:=lv_query|| 'WHERE ' || cur_rec.attribute_name || ' ' || cur_rec.operator || ' ' || nvl(cur_rec.attribute_text,'('''')');

            END IF;


            lv_query:=lv_query || chr(10);
          END IF;
      END LOOP;
   END LOOP;
   IF lv_query IS NOT NULL THEN
     OPEN c FOR lv_query;
       LOOP
         FETCH c INTO lv_currole, lv_object_id;
         EXIT WHEN c%NOTFOUND;
         IF Nvl(p_object_id, lv_object_id)=lv_object_id THEN
           IF ObjectCache.EXISTS(lv_object_id)=FALSE THEN
              Raise_Application_Error(-20106,'Failed to refresh ACL for '||p_class_name||'['||lv_object_id||']. Object not found in the internal cache.');
           END IF;
           ObjectCache(lv_object_id).partitioned_roles:=SetUnion(ObjectCache(lv_object_id).partitioned_roles, Varchar32L_t(lv_currole));
         END IF;
       END LOOP;
     CLOSE c;
   END IF;
END EvaluatePartitions;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : Debug                                                                        --
-- Description    : Debugging helper procedure.                                                  --
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
PROCEDURE Debug(p_start IN OUT TIMESTAMP, p_text IN VARCHAR2)
IS
--</FUNC>
--</EC-DOC>
  li_dt      interval day to second;
  ln_secs    number;
  ln_line_no number;
BEGIN
  IF DebugFlag THEN
     select (max(line_number)+1) into ln_line_no from t_temptext where id='ECDP_ACL_DEBUG';
     IF ln_line_no IS NULL THEN
        ln_line_no:=1;
     END IF;

     -- Calculate elapsed time
     li_dt:=systimestamp-p_start;

     -- Convert to seconds
  	 ln_secs:=extract(day from li_dt)*24*60*60+extract(hour from li_dt)*60*60+extract(minute from li_dt)*60+extract(second from li_dt);

     -- Insert DEBUG info
     INSERT INTO t_temptext(id,line_number,text)
     VALUES
     ('ECDP_ACL_DEBUG', ln_line_no, p_text||' took '|| ln_secs||' seconds.');

     -- Restart timer
     p_start:=systimestamp;
  END IF;
END Debug;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : ClearInternalCaches                                                          --
-- Description    : Clear internal memory structures                                             --
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
PROCEDURE ClearInternalCaches
IS
--</FUNC>
--</EC-DOC>
BEGIN
     lt_all_roles.DELETE;
     lt_class_partition_roles.DELETE;
     ObjectCache.DELETE;
     FromToRoleRelMap.DELETE;
     ToFromRoleRelMap.DELETE;
     RefFromToCache.DELETE;
     RefToFromCache.DELETE;
     Relations.DELETE;
END ClearInternalCaches;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : RefreshTBasisAccess                                                          --
-- Description    : Reads T_BASIS_ACCESS into nternal memory structures                          --
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
PROCEDURE RefreshTBasisAccess
IS
--</FUNC>
--</EC-DOC>
  CURSOR c_t_basis_access IS
    SELECT DISTINCT role_id, class_name
    FROM   t_basis_access
    WHERE  class_name IS NOT NULL
    ORDER BY role_id, class_name;
BEGIN
     FOR cur_rec IN c_t_basis_access LOOP
         lt_all_roles:=SetUnion(lt_all_roles, Varchar32L_t(cur_rec.role_id));
         IF NOT lt_class_partition_roles.EXISTS(cur_rec.class_name) THEN
            lt_class_partition_roles(cur_rec.class_name):=Varchar32L_t();
         END IF;
         lt_class_partition_roles(cur_rec.class_name):=SetUnion(lt_class_partition_roles(cur_rec.class_name), Varchar32L_t(cur_rec.role_id));
     END LOOP;
END RefreshTBasisAccess;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetACLObjectRoles                                                            --
-- Description    : Select roles from the ACL_OBJECTS table for p_object_id and p_class_name     --
--                  and return the roles as a list.                                              --
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
FUNCTION GetACLObjectRoles(p_object_id IN VARCHAR2, p_class_name IN VARCHAR2)
RETURN Varchar32L_t
IS
--</FUNC>
--</EC-DOC>
  CURSOR c_acl_objects(p_object_id VARCHAR2,p_class_name VARCHAR2) IS
    SELECT role_id
    FROM   acl_objects
    WHERE  object_id=p_object_id
    AND    class_name=p_class_name
    ORDER BY role_id;

  lt_role_list Varchar32L_t:=Varchar32L_t();
BEGIN
  FOR cur_rec IN c_acl_objects(p_object_id, p_class_name) LOOP
      lt_role_list.EXTEND(1);
      lt_role_list(lt_role_list.COUNT):=cur_rec.role_id;
  END LOOP;
  RETURN lt_role_list;
END GetACLObjectRoles;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : ResolveObjectRoles                                                           --
-- Description    : Recursively resolve role list for the input object. Result role list will be --
--                  a sub-set of the input role list.                                            --
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
PROCEDURE ResolveObjectRoles(
         p_object_id         IN objects.object_id%TYPE
,        p_rolelist          IN Varchar32L_t
,        p_resolve_recursive IN BOOLEAN)
IS
--</FUNC>
--</EC-DOC>
  lt_inherited      Varchar32L_t:=Varchar32L_t();
  lt_partitioned    Varchar32L_t:=Varchar32L_t();
  lv_ref_object_id  objects.object_id%TYPE;
  lv_ref_class_name objects.class_name%TYPE;
  lt_relation_list  RelationL_t;
  lt_rel_map        Varchar32L_M1_t;
  lt_rel_roles      Varchar32L_M1_t;
  lt_rel_id_list    Varchar32L_t:=Varchar32L_t();

BEGIN
  IF ObjectCache(p_object_id).processing=TRUE THEN
     -- Break circular references
     RETURN;
  END IF;
  IF ObjectCache(p_object_id).resolved=TRUE THEN
     -- Already resolved
     RETURN;
  END IF;

  -- Flag object as "being process"
  ObjectCache(p_object_id).processing:=TRUE;

  lt_inherited:=p_rolelist;
  IF lt_class_partition_roles.EXISTS(ObjectCache(p_object_id).class_name) THEN
     lt_inherited:=SetMinus(lt_inherited, lt_class_partition_roles(ObjectCache(p_object_id).class_name));
  END IF;

  lt_relation_list:=GetRelations(null, ObjectCache(p_object_id).class_name, null, 'TO_CLASS');
  FOR r IN 1..lt_relation_list.COUNT LOOP
      lt_rel_id_list.EXTEND(1);
      lt_rel_id_list(lt_rel_id_list.COUNT):=lt_relation_list(r).id;
      lt_rel_map(lt_relation_list(r).id):=GetObjectReferences(RefToFromCache, lt_relation_list(r).id, p_object_id);
  END LOOP;
  lt_relation_list:=GetRelations(ObjectCache(p_object_id).class_name, null, null, 'FROM_CLASS');
  FOR r IN 1..lt_relation_list.COUNT LOOP
      lt_rel_id_list.EXTEND(1);
      lt_rel_id_list(lt_rel_id_list.COUNT):=lt_relation_list(r).id;
      lt_rel_map(lt_relation_list(r).id):=GetObjectReferences(RefFromToCache, lt_relation_list(r).id, p_object_id);
  END LOOP;

  FOR r IN 1..lt_rel_id_list.COUNT LOOP
      lt_rel_roles(lt_rel_id_list(r)):=Varchar32L_t();
      IF  lt_rel_map(lt_rel_id_list(r)).COUNT=0
      AND Relations(lt_rel_id_list(r)).to_class_name=ObjectCache(p_object_id).class_name
      AND Relations(lt_rel_id_list(r)).access_control_method='TO_CLASS' THEN
         -- Only inherit roles for empty relations if this object is the to-object
         lt_rel_roles(lt_rel_id_list(r)):=lt_inherited;
      END IF;
      FOR o IN 1..lt_rel_map(lt_rel_id_list(r)).COUNT LOOP
          lv_ref_object_id:=lt_rel_map(lt_rel_id_list(r))(o);
          IF p_resolve_recursive THEN
             -- If we resolve access recursively we assume that objects have been registered in ObjectCache upfront.
             IF ObjectCache(lv_ref_object_id).resolved=FALSE THEN
                ResolveObjectRoles(lv_ref_object_id,p_rolelist,p_resolve_recursive);
             END IF;
          ELSE
             -- If we do not resolve access recursively the objects referenced by p_object_id will not necessarily be in the ObjectCache.
             -- Therefore, find the class name using Relations instead of ObjectCache.
             IF  Relations(lt_rel_id_list(r)).to_class_name=ObjectCache(p_object_id).class_name
             AND Relations(lt_rel_id_list(r)).access_control_method='TO_CLASS' THEN
                 lv_ref_class_name:=Relations(lt_rel_id_list(r)).from_class_name;
             ELSIF Relations(lt_rel_id_list(r)).from_class_name=ObjectCache(p_object_id).class_name
             AND   Relations(lt_rel_id_list(r)).access_control_method='FROM_CLASS' THEN
                 lv_ref_class_name:=Relations(lt_rel_id_list(r)).to_class_name;
             END IF;
             ObjectCache(lv_ref_object_id).resolved_roles:=GetACLObjectRoles(lv_ref_object_id,lv_ref_class_name);
             ObjectCache(lv_ref_object_id).resolved:=TRUE;
          END IF;

          -- Use union/logical-OR within the same relation. I.e. Must have access to at least one of the objects referenced by the relation.
          lt_rel_roles(lt_rel_id_list(r)):=SetUnion(lt_rel_roles(lt_rel_id_list(r)), ObjectCache(lv_ref_object_id).resolved_roles);
      END LOOP;
      -- Use intersect/logical-AND between relations. I.e. Must have access to all relations.
      lt_inherited:=SetIntersect(lt_inherited,lt_rel_roles(lt_rel_id_list(r)));
  END LOOP;
  lt_partitioned:=ObjectCache(p_object_id).partitioned_roles;

  -- Inherit access or get access from partition.
  ObjectCache(p_object_id).resolved_roles:=SetUnion(lt_inherited, lt_partitioned);

  -- Flag the object as resolved and processed.
  ObjectCache(p_object_id).processing:=FALSE;
  ObjectCache(p_object_id).resolved:=TRUE;

END ResolveObjectRoles;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : PopulatePredecessors                                                         --
-- Description    : Recursively read predecessors for the input object.                          --
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
PROCEDURE PopulatePredecessors(
          p_object_id   IN VARCHAR2
,         p_class_name  IN VARCHAR2)
IS
--</FUNC>
--</EC-DOC>
  lt_predecessor_map  Varchar32_M1_t;
  lt_predecessor_keys Varchar32L_t;
  lv_object_id        VARCHAR2(32);
  lv_class_name       VARCHAR2(32);
BEGIN
  lt_predecessor_map:=GetObjectPredecessors(p_object_id, p_class_name);
  lt_predecessor_keys:=KeySet(lt_predecessor_map);
  FOR i IN 1..lt_predecessor_keys.COUNT LOOP
     lv_object_id:=lt_predecessor_keys(i);
     lv_class_name:=lt_predecessor_map(lv_object_id);
     EXECUTE IMMEDIATE 'begin eccp_'||lv_class_name||'.Cache(:p_object_id); end;' USING lv_object_id;
     PopulatePredecessors(lv_object_id, lv_class_name);
  END LOOP;
END PopulatePredecessors;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : PopulateSuccessors                                                           --
-- Description    : Recursively read successors for the input object.                            --
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
PROCEDURE PopulateSuccessors(
          p_object_id   IN VARCHAR2
,         p_class_name  IN VARCHAR2)
IS
--</FUNC>
--</EC-DOC>
  lt_relation_list  RelationL_t;
  lv_procedure      VARCHAR2(100);
  lt_successor_map  Varchar32_M1_t;
  lt_successor_keys Varchar32L_t;
  lv_object_id      VARCHAR2(32);
  lv_class_name     VARCHAR2(32);
  ln_relation_id    INTEGER;
BEGIN
  lt_relation_list:=GetRelations(p_class_name, null, null, 'TO_CLASS');
  FOR i IN 1..lt_relation_list.COUNT LOOP
     ln_relation_id:=lt_relation_list(i).id;
     lv_procedure:='eccp_'||lt_relation_list(i).to_class_name||'.Cache_'||lt_relation_list(i).role_name||'(:p_object_id); ';
     EXECUTE IMMEDIATE 'begin '||lv_procedure||' end;' USING p_object_id;
     lt_successor_map:=GetObjectSuccessors(p_object_id, p_class_name, ln_relation_id);
     lt_successor_keys:=KeySet(lt_successor_map);
     FOR j IN 1..lt_successor_keys.COUNT LOOP
         lv_object_id:=lt_successor_keys(j);
         lv_class_name:=lt_successor_map(lv_object_id);
         EXECUTE IMMEDIATE 'begin eccp_'||lv_class_name||'.Cache(:p_object_id); end;' USING lv_object_id;
         PopulateSuccessors(lv_object_id, lv_class_name);
     END LOOP;
  END LOOP;
END PopulateSuccessors;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : PopulateCache                                                                --
-- Description    : Read input object into object cache. Recursively read the input object's     --
--                  predecessors if p_predecessors is TRUE. Recursively read the input object's  --
--                  successors if p_successors is TRUE.                                          --
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
PROCEDURE PopulateCache(
          p_object_id    IN VARCHAR2
,         p_class_name   IN VARCHAR2
,         p_predecessors IN BOOLEAN
,         p_successors   IN BOOLEAN)
IS
--</FUNC>
--</EC-DOC>
BEGIN
   EXECUTE IMMEDIATE 'begin eccp_'||p_class_name||'.Cache(:p_object_id); end;' USING p_object_id;
   IF p_predecessors THEN
      PopulatePredecessors(p_object_id, p_class_name);
   END IF;
   IF p_successors THEN
      PopulateSuccessors(p_object_id, p_class_name);
   END IF;
END PopulateCache;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : Evaluate                                                                     --
-- Description    :                                                                              --
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
PROCEDURE Evaluate(p_object_id IN VARCHAR2, p_class_name IN VARCHAR2, p_resolve_recursive BOOLEAN, p_propagate BOOLEAN)
IS
--</FUNC>
--</EC-DOC>
  -- ACL records for access controlled OBJECTs that implement an access controlled INTERFACE,
  CURSOR c_interface_rec1(p_object_id VARCHAR2, p_class_name VARCHAR2) IS
    SELECT o.object_id,d.parent_class,o.role_id
    FROM   acl_objects o
    ,      class_dependency d
    ,      class p
    ,      class c
    WHERE  p.class_name=d.parent_class
    AND    c.class_name=d.child_class
    AND    d.dependency_type= 'IMPLEMENTS'
    AND    o.class_name=c.class_name
    AND    NVL(p.access_control_ind,'N')='Y'
    AND    NVL(c.access_control_ind,'N')='Y'
    AND    NVL(p_object_id,o.object_id)=o.object_id
    AND    NVL(p_class_name,o.class_name)=o.class_name;

  -- OBJECTs without access control that implement an access controlled INTERFACE,
  CURSOR c_interface_rec2(p_object_id VARCHAR2, p_class_name VARCHAR2) IS
    SELECT o.object_id,d.parent_class
    FROM   objects o
    ,      class_dependency d
    ,      class p
    ,      class c
    WHERE  p.class_name=d.parent_class
    AND    c.class_name=d.child_class
    AND    d.dependency_type= 'IMPLEMENTS'
    AND    o.class_name=c.class_name
    AND    NVL(p.access_control_ind,'N')='Y'
    AND    NVL(c.access_control_ind,'N')='N'
    AND    NVL(p_object_id,o.object_id)=o.object_id
    AND    NVL(p_class_name,o.class_name)=o.class_name;

  lt_object_id_list Varchar32L_t;
  lt_relation_list  RelationL_t;
  lv_procedure      VARCHAR2(100);
  lt_successor_map  Varchar32_M1_t;
  lt_successor_keys Varchar32L_t;
  lv_object_id      VARCHAR2(32);
  lv_class_name     VARCHAR2(32);
  ln_relation_id    INTEGER;
  ln_line_no        INTEGER;
BEGIN
     IF DebugFlag THEN
        select (max(line_number)+1) into ln_line_no from t_temptext where id='ECDP_ACL_DEBUG';
        IF ln_line_no IS NULL THEN
           ln_line_no:=1;
        END IF;
        INSERT INTO t_temptext(id,line_number,text)
         VALUES
         ('ECDP_ACL_DEBUG', ln_line_no, p_class_name||'{'||p_object_id||'}='||EcDp_Objects.GetObjCode(p_object_id));
     END IF;

     IF p_object_id IS NULL THEN
        DELETE FROM acl_objects;
     ELSE
        DELETE FROM acl_objects WHERE object_id=p_object_id;
     END IF;

     IF p_object_id IS NULL THEN
        lt_object_id_list:=KeySet(ObjectCache);
     ELSE
        lt_object_id_list:=Varchar32L_t(p_object_id);
     END IF;

     FOR i IN 1..lt_object_id_list.COUNT LOOP
        ResolveObjectRoles(lt_object_id_list(i),lt_all_roles,p_resolve_recursive);
     END LOOP;

     FOR i IN 1..lt_object_id_list.COUNT LOOP
        FOR j IN 1..ObjectCache(lt_object_id_list(i)).resolved_roles.COUNT LOOP
            INSERT INTO acl_objects (object_id,class_name,role_id)
            VALUES
            (lt_object_id_list(i)
            ,ObjectCache(lt_object_id_list(i)).class_name
            ,ObjectCache(lt_object_id_list(i)).resolved_roles(j));
        END LOOP;
     END LOOP;

     --
     -- Insert records for access controlled INTERFACEs.
     --
     FOR cur_obj IN c_interface_rec1(p_object_id, p_class_name) LOOP
         INSERT INTO acl_objects (object_id,class_name,role_id) VALUES (cur_obj.object_id,cur_obj.parent_class,cur_obj.role_id);
     END LOOP;
     FOR cur_obj IN c_interface_rec2(p_object_id, p_class_name) LOOP
       FOR r IN 1..lt_all_roles.COUNT LOOP
           INSERT INTO acl_objects (object_id,class_name,role_id) VALUES (cur_obj.object_id,cur_obj.parent_class,lt_all_roles(r));
       END LOOP;
     END LOOP;

     IF p_propagate THEN
        lt_relation_list:=GetRelations(p_class_name, null, null, 'TO_CLASS');
        FOR i IN 1..lt_relation_list.COUNT LOOP
            ln_relation_id:=lt_relation_list(i).id;
            lv_procedure:='eccp_'||lt_relation_list(i).to_class_name||'.Cache_'||lt_relation_list(i).role_name||'(:p_object_id); ';
            EXECUTE IMMEDIATE 'begin '||lv_procedure||' end;' USING p_object_id;
            lt_successor_map:=GetObjectSuccessors(p_object_id, p_class_name, ln_relation_id);
            lt_successor_keys:=KeySet(lt_successor_map);
            FOR j IN 1..lt_successor_keys.COUNT LOOP
                lv_object_id:=lt_successor_keys(j);
                lv_class_name:=lt_successor_map(lv_object_id);
                EXECUTE IMMEDIATE 'begin eccp_'||lv_class_name||'.Cache(:p_object_id); end;' USING lv_object_id;
                Evaluate(lv_object_id, lv_class_name, p_resolve_recursive, p_propagate);
            END LOOP;
        END LOOP;
        lt_relation_list:=GetRelations(null, p_class_name, null, 'FROM_CLASS');
        FOR i IN 1..lt_relation_list.COUNT LOOP
            ln_relation_id:=lt_relation_list(i).id;
            lv_procedure:='eccp_'||lt_relation_list(i).from_class_name||'.Cache(:p_object_id); ';
            lt_object_id_list:=GetObjectReferences(RefToFromCache, ln_relation_id, p_object_id);
            FOR j IN 1..lt_object_id_list.COUNT LOOP
                EXECUTE IMMEDIATE 'begin '||lv_procedure||' end;' USING lt_object_id_list(j);
                Evaluate(lt_object_id_list(j), lt_relation_list(i).from_class_name, p_resolve_recursive, p_propagate);
            END LOOP;
        END LOOP;
     END IF;
END Evaluate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : RefreshAll                                                                      --
-- Description    : Refresh ACL table for all access controlled objects.                         --
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
PROCEDURE RefreshAll
IS
--</FUNC>
--</EC-DOC>
BEGIN
  ClearInternalCaches;
  RefreshRelations;
  RefreshTBasisAccess;

  -- Read all objects from all access controlled object classes into the internal object cache
  FOR cur_class IN c_acl_class(null) LOOP
      IF cur_class.class_type='OBJECT' THEN
         EXECUTE IMMEDIATE 'begin eccp_'||cur_class.class_name||'.Cache(null); end;';
         EvaluatePartitions(cur_class.class_name, null);
      END IF;
  END LOOP;

  -- Recursively evaluate access for all objects in the internal object cache
  Evaluate(null, null, TRUE, FALSE);

  ClearInternalCaches;
END RefreshAll;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : RefreshObject                                                                --
-- Description    : Single object ACL refresh - external procedure. Clears the object cache      --
--                  before and after the implementation is called.                               --
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

PROCEDURE RefreshObject(p_object_id VARCHAR2, p_class_name VARCHAR2, p_action VARCHAR2)
IS
--</FUNC>
--</EC-DOC>
BEGIN
  IF AutoRefresh=FALSE THEN
    RETURN;
  END IF;
  IF EcDp_Objects.isValidClassReference(p_class_name, p_object_id)='Y' THEN
    IF p_action='DELETING' THEN
      -- Deletes both interface and object records for p_object_id!
      DELETE FROM acl_objects WHERE object_id=p_object_id;
    ELSIF p_action='INSERTING' OR p_action='UPDATING' THEN
      ClearInternalCaches;
      RefreshRelations;
      RefreshTBasisAccess;

      -- Read the input object
      FOR cur_class IN c_acl_class(p_class_name) LOOP
          IF cur_class.class_type='OBJECT' THEN
             EXECUTE IMMEDIATE 'begin eccp_'||cur_class.class_name||'.Cache(:p_object_id); end;' USING p_object_id;
             EvaluatePartitions(cur_class.class_name, p_object_id);
          END IF;
      END LOOP;

      -- Evaluate access for the input object and its successors.
      Evaluate(p_object_id, p_class_name, FALSE, TRUE);

      ClearInternalCaches;
    END IF;
  END IF;
END RefreshObject;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : AssertAccess                                                                 --
-- Description    :                                                                              --
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
PROCEDURE AssertAccess(
   p_object_id  VARCHAR2,
   p_class_name VARCHAR2
)
IS
--</FUNC>
--</EC-DOC>
  CURSOR c_acl_lookup(p_user_id VARCHAR2) IS
    SELECT  a.*
    FROM    acl_objects a
    ,       t_basis_userrole r
    WHERE   a.object_id=p_object_id
    AND     a.class_name=p_class_name
    AND     a.role_id=r.role_id
    AND     r.user_id=p_user_id;

  lb_access BOOLEAN:=FALSE;
BEGIN
  IF  p_object_id IS NOT NULL
  AND p_class_name IS NOT NULL
  AND EcDp_Context.getAppUser IS NOT NULL THEN
    FOR curRec IN c_acl_lookup(EcDp_Context.getAppUser) LOOP
      lb_access:=TRUE;
      EXIT;
    END LOOP;
	  IF lb_access=FALSE THEN
      Raise_Application_Error(-20106,'Object is not found or is not an object of type '||p_class_name||'.' );
    END IF;
  END IF;
END AssertAccess;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : AutomatedUnitTest                                                            --
-- Description    : Automated unit test for internal helper functions.                           --
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
FUNCTION AutomatedUnitTest
RETURN BOOLEAN
IS
--</FUNC>
--</EC-DOC>
  lt_list_1  Varchar32L_t;
  lt_list_2  Varchar32L_t;
  lt_list    Varchar32L_t;
  li_test_no INTEGER:=0;
  lv_message T_TEMPTEXT.TEXT%TYPE;
  lb_status  BOOLEAN:=TRUE;
BEGIN
  DELETE FROM T_TEMPTEXT WHERE ID='ECDP_ACL_TEST';

  lv_message:='Test SetDistinct, SetContains and SetFind';
  li_test_no:=li_test_no+1;
  lt_list_1:=Varchar32L_t('F','C','D','C','E','F');
  lt_list:=SetDistinct(lt_list_1);
  IF lt_list.COUNT=4 AND
     SetContains(lt_list, 'C')=TRUE AND
     SetContains(lt_list, 'D')=TRUE AND
     SetContains(lt_list, 'E')=TRUE AND
     SetContains(lt_list, 'F')=TRUE THEN
     INSERT INTO T_TEMPTEXT (ID,LINE_NUMBER,TEXT) VALUES ('ECDP_ACL_TEST',li_test_no,'SUCCESS - '||lv_message);
  ELSE
     lb_status:=FALSE;
     INSERT INTO T_TEMPTEXT (ID,LINE_NUMBER,TEXT) VALUES ('ECDP_ACL_TEST',li_test_no,'FAIURE - '||lv_message);
  END IF;

  lv_message:='Test SetUnion';
  li_test_no:=li_test_no+1;
  lt_list_1:=Varchar32L_t('A','B','C','D');
  lt_list_2:=Varchar32L_t('C','D','E','F');
  lt_list:=SetUnion(lt_list_1, lt_list_2);
  IF lt_list.COUNT=6 AND
     SetContains(lt_list, 'A')=TRUE AND
     SetContains(lt_list, 'B')=TRUE AND
     SetContains(lt_list, 'C')=TRUE AND
     SetContains(lt_list, 'D')=TRUE AND
     SetContains(lt_list, 'E')=TRUE AND
     SetContains(lt_list, 'F')=TRUE THEN
     INSERT INTO T_TEMPTEXT (ID,LINE_NUMBER,TEXT) VALUES ('ECDP_ACL_TEST',li_test_no,'SUCCESS - '||lv_message);
  ELSE
     lb_status:=FALSE;
     INSERT INTO T_TEMPTEXT (ID,LINE_NUMBER,TEXT) VALUES ('ECDP_ACL_TEST',li_test_no,'FAIURE - '||lv_message);
  END IF;

  lv_message:='Test SetUnion';
  li_test_no:=li_test_no+1;
  lt_list:=SetUnion(Varchar32L_t('A'), Varchar32L_t());
  IF lt_list.COUNT=1 AND
     lt_list(1)='A' THEN
     INSERT INTO T_TEMPTEXT (ID,LINE_NUMBER,TEXT) VALUES ('ECDP_ACL_TEST',li_test_no,'SUCCESS - '||lv_message);
  ELSE
     lb_status:=FALSE;
     INSERT INTO T_TEMPTEXT (ID,LINE_NUMBER,TEXT) VALUES ('ECDP_ACL_TEST',li_test_no,'FAIURE - '||lv_message);
  END IF;

  lv_message:='Test SetUnion';
  li_test_no:=li_test_no+1;
  lt_list:=SetUnion(Varchar32L_t(), Varchar32L_t('A'));
  IF lt_list.COUNT=1 AND
     lt_list(1)='A' THEN
     INSERT INTO T_TEMPTEXT (ID,LINE_NUMBER,TEXT) VALUES ('ECDP_ACL_TEST',li_test_no,'SUCCESS - '||lv_message);
  ELSE
     lb_status:=FALSE;
     INSERT INTO T_TEMPTEXT (ID,LINE_NUMBER,TEXT) VALUES ('ECDP_ACL_TEST',li_test_no,'FAIURE - '||lv_message);
  END IF;

  lv_message:='Test SetIntersect';
  li_test_no:=li_test_no+1;
  lt_list:=SetIntersect(lt_list_1, lt_list_2);

  IF lt_list.COUNT=2 AND
     SetContains(lt_list, 'C')=TRUE AND
     SetContains(lt_list, 'D')=TRUE THEN
     INSERT INTO T_TEMPTEXT (ID,LINE_NUMBER,TEXT) VALUES ('ECDP_ACL_TEST',li_test_no,'SUCCESS - '||lv_message);
  ELSE
     lb_status:=FALSE;
     INSERT INTO T_TEMPTEXT (ID,LINE_NUMBER,TEXT) VALUES ('ECDP_ACL_TEST',li_test_no,'FAIURE - '||lv_message);
  END IF;

  lv_message:='Test SetIntersect';
  li_test_no:=li_test_no+1;
  lt_list:=SetIntersect(Varchar32L_t('A'), Varchar32L_t());
  IF lt_list.COUNT=0 THEN
     INSERT INTO T_TEMPTEXT (ID,LINE_NUMBER,TEXT) VALUES ('ECDP_ACL_TEST',li_test_no,'SUCCESS - '||lv_message);
  ELSE
     lb_status:=FALSE;
     INSERT INTO T_TEMPTEXT (ID,LINE_NUMBER,TEXT) VALUES ('ECDP_ACL_TEST',li_test_no,'FAIURE - '||lv_message);
  END IF;

  lv_message:='Test SetIntersect';
  li_test_no:=li_test_no+1;
  lt_list:=SetIntersect(Varchar32L_t(), Varchar32L_t('A'));
  IF lt_list.COUNT=0 THEN
     INSERT INTO T_TEMPTEXT (ID,LINE_NUMBER,TEXT) VALUES ('ECDP_ACL_TEST',li_test_no,'SUCCESS - '||lv_message);
  ELSE
     lb_status:=FALSE;
     INSERT INTO T_TEMPTEXT (ID,LINE_NUMBER,TEXT) VALUES ('ECDP_ACL_TEST',li_test_no,'FAIURE - '||lv_message);
  END IF;

  lv_message:='Test SetMinus';
  li_test_no:=li_test_no+1;
  lt_list:=SetMinus(lt_list_1, lt_list_2);
  IF lt_list.COUNT=2 AND
     SetContains(lt_list, 'A')=TRUE AND
     SetContains(lt_list, 'B')=TRUE THEN
     INSERT INTO T_TEMPTEXT (ID,LINE_NUMBER,TEXT) VALUES ('ECDP_ACL_TEST',li_test_no,'SUCCESS - '||lv_message);
  ELSE
     lb_status:=FALSE;
     INSERT INTO T_TEMPTEXT (ID,LINE_NUMBER,TEXT) VALUES ('ECDP_ACL_TEST',li_test_no,'FAIURE - '||lv_message);
  END IF;

  lv_message:='Test SetMinus';
  li_test_no:=li_test_no+1;
  lt_list:=SetMinus(lt_list_2, lt_list_1);
  IF lt_list.COUNT=2 AND
     SetContains(lt_list, 'E')=TRUE AND
     SetContains(lt_list, 'F')=TRUE THEN
     INSERT INTO T_TEMPTEXT (ID,LINE_NUMBER,TEXT) VALUES ('ECDP_ACL_TEST',li_test_no,'SUCCESS - '||lv_message);
  ELSE
     lb_status:=FALSE;
     INSERT INTO T_TEMPTEXT (ID,LINE_NUMBER,TEXT) VALUES ('ECDP_ACL_TEST',li_test_no,'FAIURE - '||lv_message);
  END IF;

  lv_message:='Test SetMinus';
  li_test_no:=li_test_no+1;
  lt_list:=SetMinus(Varchar32L_t(), Varchar32L_t());
  IF lt_list.COUNT=0 THEN
     INSERT INTO T_TEMPTEXT (ID,LINE_NUMBER,TEXT) VALUES ('ECDP_ACL_TEST',li_test_no,'SUCCESS - '||lv_message);
  ELSE
     lb_status:=FALSE;
     INSERT INTO T_TEMPTEXT (ID,LINE_NUMBER,TEXT) VALUES ('ECDP_ACL_TEST',li_test_no,'FAIURE - '||lv_message);
  END IF;

  lv_message:='Test SetMinus';
  li_test_no:=li_test_no+1;
  lt_list:=SetMinus(Varchar32L_t('A'), Varchar32L_t());
  IF lt_list.COUNT=1 AND lt_list(1)='A' THEN
     INSERT INTO T_TEMPTEXT (ID,LINE_NUMBER,TEXT) VALUES ('ECDP_ACL_TEST',li_test_no,'SUCCESS - '||lv_message);
  ELSE
     lb_status:=FALSE;
     INSERT INTO T_TEMPTEXT (ID,LINE_NUMBER,TEXT) VALUES ('ECDP_ACL_TEST',li_test_no,'FAIURE - '||lv_message);
  END IF;

  lv_message:='Test SetMinus';
  li_test_no:=li_test_no+1;
  lt_list:=SetMinus(Varchar32L_t(), Varchar32L_t('A'));
  IF lt_list.COUNT=0 THEN
     INSERT INTO T_TEMPTEXT (ID,LINE_NUMBER,TEXT) VALUES ('ECDP_ACL_TEST',li_test_no,'SUCCESS - '||lv_message);
  ELSE
     lb_status:=FALSE;
     INSERT INTO T_TEMPTEXT (ID,LINE_NUMBER,TEXT) VALUES ('ECDP_ACL_TEST',li_test_no,'FAIURE - '||lv_message);
  END IF;
  RETURN lb_status;
END AutomatedUnitTest;

END EcDp_ACL;
--</PACKAGE>