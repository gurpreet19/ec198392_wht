CREATE OR REPLACE PACKAGE BODY EcDp_ClassMeta IS
/**************************************************************
** Package:    EcDp_DynSql
**
** $Revision: 1.35 $
**
** Filename:   EcDp_ClassMeta.sql
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
** Created:   	28.02.03  Arild Vervik, EC
**
**
** Modification history:
**
**
** Date:     Whom:  Change description:
** --------  ----- --------------------------------------------
** 22.05.03   AV    Added new function getObjectRefClassName
** 27.05.03   AV    Added 3 new functions: getViewColumnIsKey, getRelationColumnName, getRelIdFromColumnName
** 14.07.03   KSN   Added 2 new functions. getClassAttributeFormatMask, getClassAttributeDbMappingType
** 17.07.03   KSN   Added 2 new functions. getClassAttributeLabel, getPresSyntaxProstyCode
** 22.07.03   AV    Added function getClassType
** 11.08.03   AV    Updated GetUtilDbMapping to also handle revision info
**            KSN   Removed format mask method added get statispres
** 20.11003   SHN   Updated getClassJournalIfCondition
** 28.11.03   SHN   Added function getClassDbAttributeTable
** 11.05.2004 FBa   Added function getUOM
** 31.01.05   SHN   Added function getTruncatedDate
** 07.03.05   SHN   Added function getEcPackage
** 07.03.05   DN    Function getClassJournalIfCondition: Modified retrieval of journal rule.
** 11.03.05   SHN   Added function IsParentRelation
** 01.04.05   SHN   Added function IsValidTabCol
** 08.04.05   AV    Changed algorithm in getGroupModelDepPopupSortOrder
** 25.05.05   ROV   Added method getClassAttributeDataType
** 18.07.05   SHN   Added function IsRevTextMandatory. Tracker 2109.
** 29.08.05   AV    Added function IsImplementationsDefined.  Tracker 2574
** 01.03.07   SIAH  Added function IsValidAttribute
** 26.03.2007 HUS   Added function GetSchemaName
** 21.07.2009 RAJARSAR Updated getGroupModelDepPopupSortOrder to support Collection Point navigator
** 07.07.2010 RAJARSAR:ECPD-13347 Updated getGroupModelDepPopupSortOrder to loop only enabled relations
** 22.07.2010 RAJARSAR:ECPD-13347 Updated getGroupLevelCount, IsParentRelation and getGroupModelLabel to loop only enabled relations
** 06.08.2010 RAJARSAR:ECPD-13347 Updated getGroupModelDepPopupPres to loop only enabled relations
**************************************************************/


CURSOR c_class_attr_presentation (p_class_name VARCHAR2, p_attribute_name VARCHAR2) IS
  SELECT *
  FROM class_attr_presentation cap
  WHERE cap.class_name = p_class_name
  and cap.attribute_name = p_attribute_name
  ;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : GetUtilDbMapping
-- Description    : Find table and column mapping for class attribute
--
-- Preconditions  : None
-- Postcondition  :
-- Using Tables   : class, class_db_mapping, class_attr_db_mapping
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE GetUtilDbMapping (
  p_class_name                 VARCHAR2,
  p_property_name              VARCHAR2,
  p_table_name					OUT VARCHAR2,
  p_column_name				OUT VARCHAR2,
  p_time_scope_code			OUT VARCHAR2
)
--</EC-DOC>
IS

CURSOR c_db_mapping IS
SELECT class_db_mapping.db_object_name, class.time_scope_code, class_attr_db_mapping.db_sql_syntax
FROM   class, class_db_mapping, class_attr_db_mapping
WHERE  class_attr_db_mapping.class_name = class.class_name
AND    class_db_mapping.class_name = class.class_name
AND    class.class_name = p_class_name
AND    class_attr_db_mapping.attribute_name = p_property_name
UNION ALL
SELECT class_db_mapping.db_object_name, class.time_scope_code, class_rel_db_mapping.db_sql_syntax
FROM   class, class_db_mapping, class_rel_db_mapping
WHERE  class_rel_db_mapping.to_class_name = class.class_name
AND    class_db_mapping.class_name = class.class_name
AND    class.class_name = p_class_name
AND    class_rel_db_mapping.role_name = substr(p_property_name,1, length(p_property_name) - 3);

CURSOR c_db_revinfo IS
SELECT class_db_mapping.db_object_name, class.time_scope_code
FROM   class, class_db_mapping
WHERE  class_db_mapping.class_name = class.class_name
AND    class.class_name = p_class_name;





BEGIN

   IF p_property_name NOT IN ('RECORD_STATUS','CREATED_BY','REV_TEXT','LAST_UPDATED_BY','CREATED_DATE','LAST_UPDATED_DATE','REV_NO') THEN

   	 FOR cur_db_mapping IN c_db_mapping LOOP
   			p_table_name := cur_db_mapping.db_object_name;
   			p_column_name := cur_db_mapping.db_sql_syntax;
   			p_time_scope_code := cur_db_mapping.time_scope_code;
   	 END LOOP;


    ELSE

   	 FOR cur_db_mapping IN c_db_revinfo LOOP
   			p_table_name := cur_db_mapping.db_object_name;
   			p_column_name := p_property_name;
   			p_time_scope_code := cur_db_mapping.time_scope_code;
   	 END LOOP;


    END IF;


END GetUtilDbMapping;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : OwnerClassName
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : class
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION OwnerClassName(
  p_class_name          VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>
IS
CURSOR c_class IS
SELECT owner_class_name
FROM class
WHERE class_name = p_class_name;

lv2_return_val class.owner_class_name%TYPE;

BEGIN

   FOR ClassCur IN c_class LOOP

       lv2_return_val := ClassCur.owner_class_name;

   END LOOP;

   RETURN lv2_return_val;

END OwnerClassName;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : SuperClassName
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : class
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION SuperClassName(
  p_class_name          VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>
IS
CURSOR c_class IS
SELECT super_class
FROM class
WHERE class_name = p_class_name;

lv2_return_val class.super_class%TYPE;

BEGIN

   FOR ClassCur IN c_class LOOP

       lv2_return_val := ClassCur.super_class;

   END LOOP;

   RETURN lv2_return_val;

END SuperClassName;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : IsPropertyMandatory
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : class
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION IsPropertyMandatory(
  p_class_name          VARCHAR2,
  p_property_name       VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>
IS
CURSOR c_attr IS
  SELECT NVL(is_mandatory, 'N') as is_mandatory
  FROM class_attribute
  WHERE attribute_name = p_property_name
  AND class_name = p_class_name
UNION
	SELECT NVL(is_mandatory, 'N') as is_mandatory
  FROM class_relation
  WHERE from_class_name = p_class_name
    AND role_name = substr(p_property_name,1, length(p_property_name) - 3)
    AND multiplicity IN ('1:1', '1:N')
;

lv2_is_mandatory VARCHAR2(1);
BEGIN

	 FOR cur_attr IN c_attr LOOP
			lv2_is_mandatory := cur_attr.is_mandatory;
	 END LOOP;

	 return lv2_is_mandatory;

END IsPropertyMandatory;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : IsValidTabCol
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : class
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION IsValidTabCol(
   p_class_name		 VARCHAR2,
   p_table_owner      VARCHAR2,
   p_table_name		 VARCHAR2,
   p_column_name      VARCHAR2
)
RETURN BOOLEAN
--</EC-DOC>
IS

lv2_sql 						VARCHAR2(4000);
lv2_table_name          VARCHAR2(32);
lv2_table_owner         VARCHAR2(32);

ln_cnt NUMBER;

BEGIN

  IF p_table_name IS NULL THEN

     SELECT db_object_name, db_object_owner
     INTO lv2_table_name, lv2_table_owner
     FROM class_db_mapping
     WHERE class_name = p_class_name
       AND db_object_type = 'TABLE';

  ELSE

      lv2_table_name := p_table_name;
      lv2_table_owner := p_table_owner;

  END IF;

   SELECT Count(*)
   INTO ln_cnt
   FROM all_tab_columns
   WHERE owner = lv2_table_owner
     AND table_name = lv2_table_name
     AND column_name = p_column_name;


   RETURN (ln_cnt > 0);

END IsValidTabCol;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : CountAttrRecords
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : class
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION CountAttrRecords(
   p_class_name		 VARCHAR2,
   p_table_name		 VARCHAR2,
   p_column_name      VARCHAR2
)
RETURN NUMBER
--</EC-DOC>
IS

lv2_sql 					 VARCHAR2(4000);
lv2_table_name        VARCHAR2(32);

BEGIN

  IF p_table_name IS NULL THEN

     SELECT db_object_name
     INTO lv2_table_name
     FROM class_db_mapping
     WHERE class_name = p_class_name
       AND db_object_type = 'TABLE';

  ELSE

      lv2_table_name := p_table_name;

  END IF;

  IF lv2_table_name IS NOT NULL THEN

  	IF lv2_table_name LIKE 'OBJECTS%ATTRIBUTE%' THEN
  		 lv2_sql := 'select Count(' || p_column_name || ') from ' || lv2_table_name ||' where class_name = ''' || p_class_name || '''';
  	ELSIF lv2_table_name LIKE 'OBJECTS%DATA' THEN
  		 lv2_sql := 'select Count(' || p_column_name || ') from ' || lv2_table_name ||' where class_name = ''' || p_class_name || '''';
  	ELSE
  		 lv2_sql := 'select Count(' || p_column_name || ') from ' || lv2_table_name;
    END IF;

  END IF;

	RETURN EcDp_DynSql.execute_singlerow_number(lv2_sql);

END CountAttrRecords;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : CountAttrRecords
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : class
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getClassDateHandeling(
  p_class_name          VARCHAR2,
  p_class_type          VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>
IS
  CURSOR c_dateHandeling IS
  SELECT 1
  FROM CLASS_ATTRIBUTE ca
  WHERE class_name = p_class_name
  AND   attribute_name = 'END_DATE';

  CURSOR c_dateHandeling2 IS
  SELECT 1
  FROM CLASS_ATTRIBUTE ca
  WHERE class_name = p_class_name
  AND   attribute_name = 'DAYTIME';

  lv2_date_handeling VARCHAR2(30);
  lb_end_date   BOOLEAN := FALSE;
  lb_daytime   	BOOLEAN := FALSE;

BEGIN

  IF p_class_type = 'TABLE' THEN

     lv2_date_handeling := 'NONE';

  ELSIF p_class_type IN ('OBJECT','OBJECT_CLASSIC','SUB_CLASS','INTERFACE') THEN

     lv2_date_handeling := 'OBJECT';

  ELSE

     FOR curdatehandeling IN c_dateHandeling LOOP
        lb_end_date := TRUE;
     END LOOP;

     IF lb_end_date THEN

        lv2_date_handeling := 'DAYTIME_PERIOD';

     ELSE
		FOR curdatehandeling2 IN c_dateHandeling2 LOOP
			lb_daytime := TRUE;
		END LOOP;

		IF lb_daytime THEN
			lv2_date_handeling := 'DAYTIME_ONLY';
		ELSE
        	lv2_date_handeling := 'NONE';
		END IF;
     END IF;

   END IF;

   RETURN lv2_date_handeling;

END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getClassDBTable
-- Description    : Find the database table storing the object in this class including schema owner.
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : class
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getClassDBTable(
  p_class_name          VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_db_mapping (p_class_name VARCHAR2) IS
  SELECT *
  FROM class_db_mapping x
  WHERE class_name = p_class_name
  ;


  lv2_base_table VARCHAR2(100);

BEGIN
    FOR Classes IN c_db_mapping(p_class_name) LOOP

      lv2_base_table := Classes.db_object_owner || '.' || Classes.db_object_name;

    END LOOP;

    RETURN lv2_base_table;

END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getClassViewName
-- Description    : Find the ViewName generated for this class
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : class
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getClassViewName(
  p_class_name          VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_class (p_class_name VARCHAR2) IS
  SELECT DECODE(class_type,'OBJECT','OV_'||class_name,'DATA','DV_'||class_name,'SUB_CLASS','OSV_'||class_name,
                'INTERFACE','IV_'||class_name ,'TABLE','TV_'||class_name) classviewname
  FROM class
  WHERE class_name = p_class_name
  ;


  lv2_view_name VARCHAR2(100);

BEGIN
    FOR Classes IN c_class(p_class_name) LOOP

      lv2_view_name := Classes.classviewname;

    END LOOP;

    RETURN lv2_view_name;

END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getClassJournalIfCondition
-- Description    : Find the If condition that is the criteria for Journal entries on the class
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : class
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : For now the class "inherits" the behavior from its storage table.
--                  This might have to change in the future.
---------------------------------------------------------------------------------------------------

FUNCTION getClassJournalIfCondition(
  p_class_name          VARCHAR2
)
RETURN VARCHAR2

--</EC-DOC>
IS

CURSOR c_classJournal (cp_class_name VARCHAR2) IS
  SELECT journal_rule_db_syntax if_condition
  FROM class
  WHERE class_name = cp_class_name;

  lv2_if_condition class.journal_rule_db_syntax%TYPE;

BEGIN

    FOR curClass IN c_classJournal(p_class_name) LOOP

      lv2_if_condition := curClass.if_condition;

    END LOOP;

    RETURN lv2_if_condition;

END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getViewColumnMandatory
-- Description    : Find out if a column is mandatory from class_attribute
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : class_attribute, class_relation
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : For now the class "inherits" the behavior from its storage table.
--                  This might have to change in the future.
---------------------------------------------------------------------------------------------------
FUNCTION getViewColumnMandatory(
  p_view_name          VARCHAR2,
  p_column_name        VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_classAttribute (p_class_name VARCHAR2,p_attribute_name VARCHAR2) IS
  SELECT is_key, is_mandatory
  FROM class_attribute ca
  WHERE ca.class_name = p_class_name
  AND   ca.attribute_name = p_attribute_name
  ;

CURSOR c_classRelation (p_class_name VARCHAR2,p_attribute_name VARCHAR2) IS
  SELECT is_mandatory
  FROM class_relation cr
  WHERE cr.to_class_name = p_class_name
  AND   cr.role_name = p_attribute_name
  ;


  lv2_mandatory  VARCHAR2(100) := NULL;
  lv2_rolename   VARCHAR2(100);
  lv2_column     VARCHAR2(100);
  lv2_id         VARCHAR2(10);
  lb_found       BOOLEAN;

BEGIN

    lv2_mandatory := '';
    lb_found := FALSE;
    lv2_column := RTRIM(p_column_name);

    IF lv2_column IN ('OBJECT_ID','OBJECT_CODE','CODE') THEN

       lv2_mandatory := 'ID OR CODE NOT NULL';

    ELSIF lv2_column IN ('OBJECT_START_DATE','OBJECT_END_DATE') THEN

       lv2_mandatory := '';

    ELSIF lv2_column IN ('DAYTIME') THEN

       lv2_mandatory := 'NOT NULL';

    ELSE

       FOR curClass IN c_classAttribute(SUBSTR(p_view_name,4), p_column_name) LOOP

         lb_found := TRUE;

         IF curClass.is_mandatory = 'Y' THEN

            lv2_mandatory := 'NOT NULL';

         END IF;

       END LOOP;

       IF NOT lb_found THEN

         lv2_rolename := NULL;
--         lv2_id := SUBSTR(lv2_column,LENGTH(lv2_column)-2);

         IF  SUBSTR(lv2_column,LENGTH(lv2_column)-2) = '_ID' THEN

            lv2_rolename := SUBSTR(lv2_column,1, LENGTH(RTRIM(p_column_name))-3);


         ELSIF RTRIM(SUBSTR(p_column_name,LENGTH(p_column_name)-4)) = '_CODE' THEN

            lv2_rolename := SUBSTR(p_column_name,1, LENGTH(p_column_name)-5);

         END IF;

         IF lv2_rolename IS NOT NULL THEN


             FOR curClass IN c_classRelation(SUBSTR(p_view_name,4), lv2_rolename) LOOP

               IF curClass.is_mandatory = 'Y' THEN

                  lv2_mandatory := 'ID OR CODE NOT NULL';

               END IF;

            END LOOP;

         END IF;

      END IF;



   END IF;

   RETURN lv2_mandatory;


END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getViewColumnIsKey
-- Description    : Find out if a column is mandatory from class_attribute
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : class_attribute, class_relation
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : For now the class "inherits" the behavior from its storage table.
--                  This might have to change in the future.
---------------------------------------------------------------------------------------------------
FUNCTION getViewColumnIsKey(
  p_view_name          VARCHAR2,
  p_column_name        VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_classAttribute (p_class_name VARCHAR2,p_attribute_name VARCHAR2) IS
  SELECT is_key, is_mandatory
  FROM class_attribute ca
  WHERE ca.class_name = p_class_name
  AND   ca.attribute_name = p_attribute_name
  ;

CURSOR c_classRelation (p_class_name VARCHAR2,p_attribute_name VARCHAR2) IS
  SELECT is_key
  FROM class_relation cr
  WHERE cr.to_class_name = p_class_name
  AND   cr.role_name = p_attribute_name
  ;


  lv2_mandatory  VARCHAR2(100) := NULL;
  lv2_rolename   VARCHAR2(100);
  lv2_column     VARCHAR2(100);
  lv2_id         VARCHAR2(10);
  lb_found       BOOLEAN;

BEGIN

    lv2_mandatory := '';
    lb_found := FALSE;
    lv2_column := RTRIM(p_column_name);


    FOR curClass IN c_classAttribute(SUBSTR(p_view_name,4), p_column_name) LOOP

         lb_found := TRUE;

         IF curClass.is_key = 'Y' THEN

            lv2_mandatory := 'KEY';

         END IF;

    END LOOP;

    IF NOT lb_found THEN

         lv2_rolename := NULL;

         IF  SUBSTR(lv2_column,LENGTH(lv2_column)-2) = '_ID' THEN

            lv2_rolename := SUBSTR(lv2_column,1, LENGTH(RTRIM(p_column_name))-3);


         ELSIF RTRIM(SUBSTR(p_column_name,LENGTH(p_column_name)-4)) = '_CODE' THEN

            lv2_rolename := SUBSTR(p_column_name,1, LENGTH(p_column_name)-5);

         END IF;

         IF lv2_rolename IS NOT NULL THEN


             FOR curClass IN c_classRelation(SUBSTR(p_view_name,4), lv2_rolename) LOOP

               IF curClass.is_key = 'Y' THEN

                  lv2_mandatory := 'KEY';

               END IF;

            END LOOP;

         END IF;

      END IF;


   RETURN lv2_mandatory;


END;






--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getObjectRefClassName
-- Description    : Find the class name given a class_name and the number of the ref_object_id
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : class_db_mapping, class_rel_db_mapping
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getObjectRefClassName(
  p_class_name         VARCHAR2,
  p_ref_obj_id_no      NUMBER
)
RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_class (p_class_name VARCHAR2) IS
  SELECT Nvl(owner_class_name,class_name) owner_class_name
  FROM class
  WHERE class_name = p_class_name
  ;

CURSOR c_classRelation (p_to_class_name VARCHAR2,p_db_sql_syntax VARCHAR2) IS
  SELECT from_class_name
  FROM class_rel_db_mapping cr
  WHERE cr.to_class_name = p_to_class_name
  AND   cr.db_sql_syntax = p_db_sql_syntax
  ;


  lv2_db_sql_syntax  VARCHAR2(100) := NULL;
  lv2_classname       VARCHAR2(100):= NULL;

BEGIN

    IF p_ref_obj_id_no = 0 THEN -- Owner

       FOR curClass IN c_class(p_class_name) LOOP

            lv2_classname := curClass.owner_class_name;

       END LOOP;

    ELSE

       lv2_db_sql_syntax := 'OBJECT_ID_'||TO_CHAR(p_ref_obj_id_no);

       FOR curClass IN c_classRelation(p_class_name, lv2_db_sql_syntax ) LOOP

            lv2_classname := curClass.from_class_name;

       END LOOP;


    END IF;

   RETURN lv2_classname;


END getObjectRefClassName;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getRelationColumnName
-- Description    : Find the column name used in view based on ref_object_id
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : class_db_mapping, class_rel_db_mapping
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getRelationColumnName(
  p_class_name         VARCHAR2,
  p_ref_obj_id_no      NUMBER
)
RETURN VARCHAR2
--</EC-DOC>

IS

CURSOR c_classRelation (p_to_class_name VARCHAR2,p_db_sql_syntax VARCHAR2) IS
  SELECT from_class_name, role_name
  FROM class_rel_db_mapping cr
  WHERE UPPER(cr.to_class_name) = p_to_class_name
  AND   UPPER(cr.db_sql_syntax) = p_db_sql_syntax
  ;


  lv2_db_sql_syntax  VARCHAR2(100) := NULL;
  lv2_column_name    VARCHAR2(100):= NULL;

BEGIN

    IF p_ref_obj_id_no = 0 THEN -- Owner

      lv2_column_name := 'OBJECT_CODE';

    ELSE

       lv2_db_sql_syntax := 'OBJECT_ID_'||TO_CHAR(p_ref_obj_id_no);

       FOR curClass IN c_classRelation(UPPER(p_class_name), UPPER(lv2_db_sql_syntax) ) LOOP

            lv2_column_name := curClass.role_name||'_CODE';

       END LOOP;


    END IF;

   RETURN lv2_column_name;


END getRelationColumnName;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getRelIdFromColumnName
-- Description    : Find the column name used in view based on ref_object_id
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : class_db_mapping, class_rel_db_mapping
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getRelIdFromColumnName(
  p_class_name         VARCHAR2,
  p_column_name        VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>

IS

CURSOR c_class (p_class_name VARCHAR2) IS
  SELECT Nvl(owner_class_name,class_name) owner_class_name
  FROM class
  WHERE class_name = p_class_name
  ;

CURSOR c_classRelation (p_to_class_name VARCHAR2,p_role_name VARCHAR2) IS
  SELECT db_sql_syntax
  FROM class_rel_db_mapping cr
  WHERE UPPER(cr.to_class_name) = p_to_class_name
  AND   UPPER(cr.role_name) = p_role_name
  ;


  lv2_role_name      VARCHAR2(100) := NULL;
  lv2_relid          VARCHAR2(100):= NULL;

BEGIN

    IF p_column_name = 'OBJECT_CODE' THEN -- Owner

      lv2_relid := 'OBJECT_ID';

    ELSE

       lv2_role_name := SUBSTR(p_column_name,1, LENGTH(p_column_name)-5);

       FOR curClass IN c_classRelation(UPPER(p_class_name), UPPER(lv2_role_name) ) LOOP

            lv2_relid := curClass.db_sql_syntax;

       END LOOP;


    END IF;

   RETURN lv2_relid;


END getRelIdFromColumnName;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getClassAttributeDbMappingType
-- Description    : DB mapping type for specified attribute
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : class_attr_db_mapping
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getClassAttributeDbMappingType(
  p_class_name          VARCHAR2,
  p_attribute_name       VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>

IS

CURSOR c_attr_db_mapping IS
  SELECT db_mapping_type
  FROM class_attr_db_mapping cam
 WHERE cam.class_name = p_class_name
  and cam.attribute_name = p_attribute_name
;

lv2_sb_mapping_type VARCHAR2(100);

BEGIN

	 FOR cur_attr IN c_attr_db_mapping LOOP
			lv2_sb_mapping_type := cur_attr.db_mapping_type;
	 END LOOP;

	 return lv2_sb_mapping_type;

END getClassAttributeDbMappingType;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getClassAttributeLabel
-- Description    : Get the label for specified attribute
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : class_attr_presentation
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : For now the class "inherits" the behavior from its storage table.
--                  This might have to change in the future.
---------------------------------------------------------------------------------------------------

FUNCTION getClassAttributeLabel(
  p_class_name          VARCHAR2,
  p_attribute_name        VARCHAR2
)
RETURN VARCHAR2

--</EC-DOC>
IS

  lv2_label VARCHAR2(100) := NULL;

BEGIN

    FOR curClass IN c_class_attr_presentation(UPPER(p_class_name), UPPER(p_attribute_name)) LOOP

      lv2_label := curClass.LABEL;

    END LOOP;

    RETURN lv2_label;

END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getPresSyntaxProstyCode
-- Description    : Build presentation for popup with prosty code values
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : For now the class "inherits" the behavior from its storage table.
--                  This might have to change in the future.
---------------------------------------------------------------------------------------------------

FUNCTION getPresSyntaxProstyCode(
  p_code          VARCHAR2
)
RETURN VARCHAR2

--</EC-DOC>
IS

lv2_code varchar2(2000);
begin
 lv2_code := 'PopupQueryURL=/com.ec.frmw.co.screens/query/ec_code_popup.xml;PopupLayout=/com.ec.frmw.co.screens/layout/ec_code_popup.xml;PopupWhereColumn=CODE_TYPE;PopupWhereValue='||p_code||';PopupWhereOperator==;PopupReturnColumn=1;PopupWidth=250;PopupHeight=300;PopupCache=true;PopupSortColumn=SORT_ORDER';
 return lv2_code;
end;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getClassType
-- Description    : Return the class type for a given class
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : class_attr_db_mapping
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getClassType(
  p_class_name          VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>

IS

CURSOR c_class IS
  SELECT class_type
  FROM class
  WHERE class_name = p_class_name
;

lv2_class_type VARCHAR2(100);

BEGIN

	 FOR cur_class IN c_class LOOP
			lv2_class_type := cur_class.class_type;
	 END LOOP;

	 return lv2_class_type;

END getClassType;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getStaticPres
-- Description    : Get the static presentation syntax for specified attribute
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : class_attr_presentation
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : For now the class "inherits" the behavior from its storage table.
--                  This might have to change in the future.
---------------------------------------------------------------------------------------------------

FUNCTION getStaticPres(
  p_class_name          VARCHAR2,
  p_attribute_name        VARCHAR2
)
RETURN VARCHAR2

--</EC-DOC>
IS

  lv2_static VARCHAR2(100) := NULL;

BEGIN

    FOR curClass IN c_class_attr_presentation(UPPER(p_class_name), UPPER(p_attribute_name)) LOOP

      lv2_static := curClass.static_presentation_syntax;

    END LOOP;

    RETURN lv2_static;

END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getClassDBAttributeTable
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : class_db_mapping
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the table where attribute-table is mapped.
--
---------------------------------------------------------------------------------------------------
FUNCTION getClassDBAttributeTable(
  p_class_name          VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>
IS

 CURSOR c_db_mapping (p_class_name VARCHAR2) IS
  SELECT *
  FROM class_db_mapping x
  WHERE class_name = p_class_name
  ;

  lv2_attr_table VARCHAR2(100);

BEGIN

    FOR Classes IN c_db_mapping(p_class_name) LOOP

      lv2_attr_table := Classes.db_object_attribute;

    END LOOP;

    RETURN lv2_attr_table;

END getClassDBAttributeTable;

FUNCTION getDataType(p_data_type VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
     IF p_data_type = 'BOOLEAN' THEN return 'STRING'; END IF;

     return p_data_type;
END getDataType;

FUNCTION HasTableColumn(p_table_name VARCHAR2, p_column_name VARCHAR2) RETURN BOOLEAN
IS
lv2_stmt VARCHAR2(2000);
BEGIN
     lv2_stmt := 'select ' || p_column_name || ' from ' || p_table_name || ' where 1 = 2';

     execute immediate lv2_stmt;

     return TRUE;

EXCEPTION
   WHEN OTHERS THEN
          return FALSE;

END HasTableColumn;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getGroupModelLabel
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : group_model_presentation
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the label for the selected group model relation
--
---------------------------------------------------------------------------------------------------
--</EC-DOC>
FUNCTION getGroupModelLabel(
  p_group_type          VARCHAR2,
  p_object_type			VARCHAR2,
  p_parent_group_type       VARCHAR2,
  p_parent_object_type	VARCHAR2
)
RETURN VARCHAR2

IS

 CURSOR c_group_model_pres (p_group_type VARCHAR2, p_object_type VARCHAR2, p_parent_group_type VARCHAR2, p_parent_object_type VARCHAR2) IS
  SELECT label
  FROM class_relation c, class_rel_presentation g
  WHERE c.from_class_name = g.from_class_name
  AND c.to_class_name = g.to_class_name
  AND c.role_name = g.role_name
  AND c.group_type = p_group_type
  AND  Nvl(c.disabled_ind, 'N') = 'N'
  and g.to_class_name = p_object_type
  and g.from_class_name = p_parent_object_type
  ;

  lv2_label VARCHAR2(64);

BEGIN

    FOR group_model_pres IN c_group_model_pres(p_group_type, p_object_type, p_parent_group_type, p_parent_object_type) LOOP

      lv2_label := group_model_pres.label;

    END LOOP;

    RETURN lv2_label;

END getGroupModelLabel;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getUomCode
-- Description    : Get the code for unit of measure for specified attribute
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : class_attr_presentation
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------

FUNCTION getUomCode(
  p_class_name          VARCHAR2,
  p_attribute_name        VARCHAR2
)
RETURN VARCHAR2

--</EC-DOC>
IS

  lv2_uom_code VARCHAR2(100) := NULL;

BEGIN

    FOR curClass IN c_class_attr_presentation(UPPER(p_class_name), UPPER(p_attribute_name)) LOOP

      lv2_uom_code := curClass.uom_code;

    END LOOP;

    RETURN lv2_uom_code;

END getUomCode;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getClassWhereCondition
-- Description    : Get the class where condition
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
FUNCTION getClassWhereCondition(
  p_class_name          VARCHAR2
)
RETURN VARCHAR2
IS

   lv2_where_cond       class_db_mapping.db_where_condition%TYPE;

BEGIN

   FOR curClass IN EcDp_ClassMeta.c_classes(p_class_name) LOOP

      lv2_where_cond := curClass.db_where_condition;

   END LOOP;

   RETURN lv2_where_cond;


END getClassWhereCondition;

---------------------------------------------------------------------------------------------------
-- function       : IsFunction
-- Description    :
--
-- Preconditions  :
--
--
--
--
-- Postcondition  :
--
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
FUNCTION IsFunction(
			p_class_name			VARCHAR2,
			p_attribute_name		VARCHAR2)
RETURN BOOLEAN
IS
	CURSOR c_attribute IS
	 SELECT UPPER(LTRIM(RTRIM(db_mapping_type))) db_mapping_type
	 FROM class_attr_db_mapping
	 WHERE class_name = p_class_name
	 AND attribute_name = p_attribute_name;

	lb_is_function			BOOLEAN := FALSE;

BEGIN

	FOR curAttr IN c_attribute LOOP

		IF curAttr.db_mapping_type = 'FUNCTION' THEN
			lb_is_function := TRUE;
		ELSE
			lb_is_function := FALSE;
		END IF;

	END LOOP;

	RETURN lb_is_function;

END IsFunction;


---------------------------------------------------------------------------------------------------
-- function       : getClassAttrDbSqlSyntax
-- Description    :
--
-- Preconditions  :
--
--
--
--
-- Postcondition  :
--
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getClassAttrDbSqlSyntax(
			p_class_name			VARCHAR2,
			p_attribute_name		VARCHAR2)
RETURN VARCHAR2
IS
	CURSOR c_class_attr_db_mapping IS
	 SELECT db_sql_syntax
	 FROM class_attr_db_mapping
	 WHERE class_name = p_class_name
	 AND   attribute_name = p_attribute_name;

	lv2_db_sql_syntax			class_attr_db_mapping.db_sql_syntax%TYPE;

BEGIN

	FOR curAttr IN c_class_attr_db_mapping LOOP
		lv2_db_sql_syntax := curAttr.db_sql_syntax;
	END LOOP;

	RETURN lv2_db_sql_syntax;

END getClassAttrDbSqlSyntax;

---------------------------------------------------------------------------------------------------
-- function       : getClassRelDbSqlSyntax
-- Description    :
--
-- Preconditions  :
--
--
--
--
-- Postcondition  :
--
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getClassRelDbSqlSyntax(
      p_from_class_name   VARCHAR2,
			p_to_class_name			VARCHAR2,
			p_role_name		VARCHAR2)
RETURN VARCHAR2
IS
	CURSOR c_class_rel_db_mapping IS
	 SELECT db_sql_syntax
	 FROM class_rel_db_mapping
	 WHERE from_class_name = p_from_class_name
	 AND   to_class_name = p_to_class_name
	 AND   role_name = p_role_name;

	lv2_db_sql_syntax			class_rel_db_mapping.db_sql_syntax%TYPE;

BEGIN

	FOR currel IN c_class_rel_db_mapping LOOP
		lv2_db_sql_syntax := curRel.db_sql_syntax;
	END LOOP;

	RETURN lv2_db_sql_syntax;

END getClassRelDbSqlSyntax;


FUNCTION getClassRelDbMappingType(
      p_from_class_name   VARCHAR2,
			p_to_class_name			VARCHAR2,
			p_role_name		      VARCHAR2)
RETURN VARCHAR2
IS
	CURSOR c_class_rel_db_mapping IS
	 SELECT  DB_MAPPING_TYPE
	 FROM class_rel_db_mapping
	 WHERE from_class_name = p_from_class_name
	 AND   to_class_name = p_to_class_name
	 AND   role_name = p_role_name;

	lv2_DB_MAPPING_TYPE			class_rel_db_mapping.DB_MAPPING_TYPE%TYPE;

BEGIN

	FOR currel IN c_class_rel_db_mapping LOOP
		lv2_DB_MAPPING_TYPE := curRel.DB_MAPPING_TYPE;
	END LOOP;

	RETURN lv2_DB_MAPPING_TYPE;

END getClassRelDbMappingType;



---------------------------------------------------------------------------------------------------
-- function       : getTruncatedDate
-- Description    : Trunc the p_date using the time_scop_code defined for p_class_name.
--					Only classes with time_scope_code DAY and MTH will be truncated.
--
-- Preconditions  :
--
--
--
--
-- Postcondition  :
--
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTruncatedDate(p_class_name	VARCHAR2,
						  p_date		DATE)
RETURN DATE
--</EC-DOC>
IS
	ld_date		DATE;

	CURSOR c_class IS
	SELECT UPPER(time_scope_code) tsc
	FROM class
	WHERE class_name = p_class_name
	AND time_scope_code IN ('DAY','MTH');

BEGIN

	ld_date	:= p_date;

	FOR curTSC IN c_class LOOP

		IF curTSC.tsc = 'MTH' THEN
			ld_date := TRUNC(p_date,'mm');
		ELSE -- Day
			ld_date := TRUNC(p_date);
		END IF;

	END LOOP;

	RETURN ld_date;

END getTruncatedDate;

---------------------------------------------------------------------------------------------------
-- function       : IsReadOnlyClass
-- Description    : Returns Y if the class is defined as read only, returns N otherwise
--
-- Preconditions  :
--
-- Postcondition  :
--
-- Using Tables   : class
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
FUNCTION IsReadOnlyClass(
				p_class_name	VARCHAR2
				)
RETURN VARCHAR2
--</EC-DOC>
IS

	CURSOR c_class IS
	 SELECT read_only_ind
	 FROM class
	 WHERE class_name = p_class_name;

	lv2_retVal		class.read_only_ind%TYPE;

BEGIN

	FOR curClass IN c_class LOOP

		lv2_retVal := Nvl(curClass.read_only_ind,'N');

	END LOOP;

	RETURN lv2_retVal;

END IsReadOnlyClass;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getEcPackage
-- Description    : Returns the generated Ec-package for the given class_name
--
-- Preconditions  :
--
-- Postcondition  :
--
-- Using Tables   : class
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getEcPackage(
				p_class_name	VARCHAR2
				)
RETURN VARCHAR2
--</EC-DOC>
IS

	CURSOR c_class_db_mapping IS
	 SELECT db_object_name
	 FROM class_db_mapping
	 WHERE class_name = p_class_name;

	lv2_ec_package	VARCHAR2(100);


BEGIN

	FOR curClass IN c_class_db_mapping LOOP

		lv2_ec_package := 'EC_'||curClass.db_object_name;

	END LOOP;

	RETURN lv2_ec_package;

END getEcPackage;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : IsParentGroupRelation
-- Description    : Reurns 'Y' if there exists a direct class_relation between child_class and parent_class.
--
-- Preconditions  :
--
-- Postcondition  :
--
-- Using Tables   : class_relation
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
FUNCTION IsParentRelation(
			p_child_class		VARCHAR2,
			p_parent_class		VARCHAR2,
			p_role_name			VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS

	lv2_is_parent			VARCHAR2(1) := 'N';
	ln_count					NUMBER := 0;

BEGIN

	SELECT count(*) INTO ln_count
	FROM class_relation
	WHERE from_class_name = p_parent_class
	AND to_class_name = p_child_class
	AND  Nvl(disabled_ind, 'N') = 'N'
	AND role_name = p_role_name;

	IF ln_count > 0 THEN
		lv2_is_parent := 'Y';
	END IF;


	RETURN lv2_is_parent;

END IsParentRelation;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getGroupModelDepPopupPres
-- Description    : Reurns the static presentation syntax of a popup for the group model fields.
--
-- Preconditions  :
--
-- Postcondition  :
--
-- Using Tables   : class_relation
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getGroupModelDepPopupPres(
			p_child_class		VARCHAR2,
			p_parent_class		VARCHAR2,
			p_role_name			VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS

	lv2_popup_pres      VARCHAR2(2000) := null;

  CURSOR c_popup IS
  select decode(rp.role_name
         , NULL, 'viewwidth=120;PopupURL=/FrontController/com.ec.frmw.co.screens/object_popup?CLASS_NAME='||r.from_class_name||';PopupDependency=RetrieveArg.DAYTIME=Screen.this.currentRow.DAYTIME$RetrieveArg.OBJECT_START_DATE=Screen.this.currentRow.OBJECT_START_DATE$Screen.this.currentRow.'||r.role_name||'_ID=ReturnField.OBJECT_ID;PopupReturnColumn=2;PopupWidth=250;PopupHeight=300'
         ,'viewwidth=120;PopupURL=/FrontController/com.ec.frmw.co.screens/objectclass_dep_popup;PopupReturnColumn=NAME;PopupDependency=Screen.this.currentRow.'||r.role_name||'_ID=ReturnField.OBJECT_ID$RetrieveArg.DAYTIME=Screen.this.currentRow.DAYTIME$RetrieveArg.OBJECT_START_DATE=Screen.this.currentRow.OBJECT_START_DATE$RetrieveArg.CLASS='||r.from_class_name||'$RetrieveArg.PARENT_COLUMN='||rp.role_name||'_ID$RetrieveArg.PARENT_ID=Screen.this.currentRow.'||rp.role_name||'_ID;PopupWidth=250;PopupHeight=300')
         AS static_pres_syntax
  from class_relation r, class_relation rp
  where rp.group_type (+) = r.group_type
  and rp.to_class_name (+) = r.from_class_name
  AND r.group_type is not null
  AND Nvl(rp.disabled_ind, 'N') = 'N'
  AND r.from_class_name = p_parent_class
  AND r.to_class_name = p_child_class
  AND r.role_name = p_role_name;


BEGIN

	FOR curPopup IN c_popup LOOP
      lv2_popup_pres := curPopup.Static_Pres_Syntax;
	END LOOP;

	RETURN lv2_popup_pres;

END getGroupModelDepPopupPres;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getGroupModelDepPopupSortOrder
-- Description    : Reurns the sort order of a popup for the group model fields.
--
-- Preconditions  :
--
-- Postcondition  :
--
-- Using Tables   : class_relation
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getGroupModelDepPopupSortOrder(
			p_child_class		VARCHAR2,
			p_parent_class		VARCHAR2,
			p_role_name			VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS

	lv2_sort_order      NUMBER(6) := null;


  -- Note this algorithm assumes that user group models have the highest levels
  -- mapped to GROUP_REF_ID_1 and downwards, can make more robust algorithm, but will be more time consuming
  -- to use.
  CURSOR c_popup IS
    select
      decode(r.db_sql_syntax,
             'OP_PU_ID',             10000
             ,'OP_SUB_PU_ID',        10100
             ,'OP_AREA_ID',          10200
             ,'OP_SUB_AREA_ID',      10300
             ,'OP_FCTY_CLASS_2_ID',  10400
             ,'OP_FCTY_CLASS_1_ID',  10500
             ,'OP_WELL_HOOKUP_ID',   10600
             ,'GEO_AREA_ID',         20100
             ,'GEO_SUB_AREA_ID',     20200
             ,'GEO_FIELD_ID',        20300
             ,'GEO_SUB_FIELD_ID',    20400
             ,'CP_PU_ID',            30000
             ,'CP_SUB_PU_ID',        30100
             ,'CP_AREA_ID',          30200
             ,'CP_SUB_AREA_ID',      30300
             ,'CP_OPERATOR_ROUTE_ID',30400
             ,'GROUP_REF_ID_1',      40100
             ,'GROUP_REF_ID_2',      40200
             ,'GROUP_REF_ID_3',      40300
             ,'GROUP_REF_ID_4',      40400
             ,'GROUP_REF_ID_5',      40500
             ,'GROUP_REF_ID_6',      40600
             ,'GROUP_REF_ID_7',      40700
             ,'GROUP_REF_ID_8',      40800
             ,'GROUP_REF_ID_9',      40900
             ,'GROUP_REF_ID_10',     41000
             ,50000) sort_order
    from class_relation cr, class_rel_db_mapping r
    WHERE cr.from_class_name = r.from_class_name
    AND   cr.to_class_name = r.to_class_name
    AND   cr.role_name = r.role_name
    AND   cr.group_type is not null
    AND   Nvl(cr.disabled_ind, 'N') = 'N'
    AND   r.from_class_name = p_parent_class
    AND   r.to_class_name = p_child_class
    AND   r.role_name = p_role_name;


BEGIN

	FOR curPopup IN c_popup LOOP
      lv2_sort_order := curPopup.Sort_Order;
	END LOOP;

	RETURN lv2_sort_order;

END getGroupModelDepPopupSortOrder;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : IsValidTabCol
-- Description    :
--
-- Preconditions  :
--
-- Postcondition  :
--
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
FUNCTION IsValidTabCol(
	p_table_name	VARCHAR2,
	p_column_name	VARCHAR2
)
RETURN BOOLEAN
--</EC-DOC>
IS
	CURSOR c_tab_cols IS
	 SELECT column_name
	 FROM user_tab_cols
	 WHERE table_name = p_table_name
	 AND   column_name = p_column_name;

	lb_is_valid_column	BOOLEAN := FALSE;

BEGIN

	FOR curTabCol IN c_tab_cols LOOP
		lb_is_valid_column := TRUE;
	END LOOP;

	RETURN lb_is_valid_column;

END IsValidTabCol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getClassAttributeDataType
-- Description    : Returns data type for specified attribute
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : class_attribute
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getClassAttributeDataType(
  p_class_name          VARCHAR2,
  p_attribute_name       VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>

IS

CURSOR c_attribute IS
  SELECT data_type
  FROM class_attribute ca
  WHERE ca.class_name = p_class_name
  AND ca.attribute_name = p_attribute_name
;

lv2_data_type VARCHAR2(100);

BEGIN

      FOR cur_attr IN c_attribute LOOP
        lv2_data_type := cur_attr.data_type;
      END LOOP;

  return lv2_data_type;

END getClassAttributeDataType;




FUNCTION getGroupLevelCount(
         p_group_type      VARCHAR2,
			p_child_class		VARCHAR2)
RETURN NUMBER
--</EC-DOC>

IS

CURSOR c_class_rel IS
  SELECT  from_class_name
  FROM class_relation cr
  WHERE group_type = p_group_type
  AND   to_class_name = p_child_class
  AND  Nvl(disabled_ind, 'N') = 'N'
  AND   group_type IS NOT NULL
;

ln_levels_above NUMBER;
ln_max_levels_above NUMBER;

BEGIN

  ln_max_levels_above := 0 ;

  FOR cur_rel IN c_class_rel LOOP

        ln_levels_above := getGroupLevelCount(p_group_type, cur_rel.from_class_name);

        IF ln_levels_above >= ln_max_levels_above THEN

          ln_max_levels_above := ln_levels_above + 1;

        END IF;

  END LOOP;

  return ln_max_levels_above;

END getGroupLevelCount;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getGroupModelLevelSortOrder
-- Description    : Give the sort order within a group type for given relation, 1 is top level
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   : class_relation
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getGroupModelLevelSortOrder(
         p_group_type      VARCHAR2,
			p_child_class		VARCHAR2,
			p_parent_class		VARCHAR2,
			p_role_name			VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>

IS

ln_levels_above NUMBER;

BEGIN

  ln_levels_above := getGroupLevelCount(p_group_type,p_parent_class);
  return ln_levels_above + 1;

END getGroupModelLevelSortOrder;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : IsRevTextMandatory
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION IsRevTextMandatory(p_class_name  VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS

   CURSOR c_class IS
   SELECT ensure_rev_text_on_upd
   FROM class
   WHERE class_name = p_class_name;

   lv2_is_mandatory VARCHAR2(1) := 'N';

BEGIN

   FOR curClass IN c_class LOOP
      lv2_is_mandatory := Nvl(curClass.ensure_rev_text_on_upd,'N');
   END LOOP;

   RETURN lv2_is_mandatory;

END IsRevTextMandatory;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : IsRevTextMandatory
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION IsImplementationsDefined(p_interface_name  VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>

IS

CURSOR c_implementations_exists IS
 select child_class from class_dependency t
 where parent_class = p_interface_name
 and   dependency_type='IMPLEMENTS';

   lv2_implementations_exists VARCHAR2(1) := 'N';

BEGIN

   FOR curInterface IN c_implementations_exists LOOP
      lv2_implementations_exists := 'Y';
      EXIT;
   END LOOP;

   RETURN lv2_implementations_exists;

END IsImplementationsDefined;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : IsValidAttribute
-- Description    :
--
-- Preconditions  :
--
--
--
--
-- Postcondition  :
--
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
FUNCTION IsValidAttribute(
   p_class_name   VARCHAR2,
   p_attribute_name VARCHAR2
)
RETURN BOOLEAN
--</EC-DOC>

IS

  CURSOR c_class IS
  select ec_class_attribute.data_type(p_class_name,p_attribute_name) as attr from dual;

  lv2_retVal boolean;

BEGIN

  lv2_retVal := false;

	FOR curClass IN c_class LOOP
    IF curClass.Attr IS NOT NULL THEN
      lv2_retVal := true;
    END IF;
	END LOOP;

	RETURN lv2_retVal;

END IsValidAttribute;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : GetSchemaName
-- Description    :
--
-- Preconditions  :
--
--
--
--
-- Postcondition  :
--
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
FUNCTION GetSchemaName
RETURN VARCHAR2
--</EC-DOC>
IS
  CURSOR c_class_db_mapping IS
    SELECT db_object_owner
    FROM   class_db_mapping
    WHERE  db_object_owner IS NOT NULL
    AND    rownum=1;
  lv2_retval VARCHAR2(30):=NULL;
BEGIN
  FOR cur_rec IN c_class_db_mapping LOOP
     lv2_retval:=cur_rec.db_object_owner;
     EXIT WHEN lv2_retval IS NOT NULL;
  END LOOP;
  RETURN lv2_retval;
END GetSchemaName;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : IsUsingUserFunction
-- Description    :
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION IsUsingUserFunction
RETURN VARCHAR2
--</EC-DOC>
IS
  CURSOR c_system_attribute IS
  SELECT attribute_text
	FROM ctrl_system_attribute
	WHERE attribute_type = 'USE_UE_USER';
  lv2_ue_user_function VARCHAR2(1):=NULL;
BEGIN
   FOR curAttr IN c_system_attribute LOOP
        lv2_ue_user_function := curAttr.attribute_text;
        Exit;
   END LOOP;
   IF (lv2_ue_user_function ='Y')THEN
      RETURN 'Y' ;
   else
      RETURN 'N';
   END IF;
END IsUsingUserFunction;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : TableExists
-- Description    :
--
-- Preconditions  :
-- Description    :
--
--
--
-- Postcondition  :
--
--
-- Using Tables   : All_Tables, All_Views
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
FUNCTION TableExists(
   p_table_name         VARCHAR2,
   p_table_owner        VARCHAR2
)
RETURN BOOLEAN
--</EC-DOC>
IS

   CURSOR c_tableexists(p_tableName VARCHAR2, p_tableOwner  VARCHAR2) IS
   SELECT 1 FROM ALL_TABLES
   WHERE table_name = UPPER(p_tableName)
   AND owner = Nvl(p_tableOwner,user)
   UNION ALL
   SELECT 1 FROM ALL_VIEWS
   WHERE view_name = UPPER(p_tableName)
   AND owner = Nvl(p_tableOwner,USER);

   lb_exsists           BOOLEAN := FALSE;
   lv2_table_name       VARCHAR2(32);
   ln_index             NUMBER := 0;

BEGIN

   -- Remove Schema name from table_name, i.g remove EcKernel from EcKernel.Well
   ln_index := INSTR(p_table_name,'.');

   IF ln_index > 0 THEN
      lv2_table_name := SUBSTR(p_table_name,ln_index + 1);
   ELSE
      lv2_table_name := p_table_name;
   END IF;


   FOR curTable IN c_tableexists(lv2_table_name,p_table_owner) LOOP

        lb_exsists := TRUE;

   END LOOP;

   RETURN lb_exsists;


END TableExists;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : GetSchemaName
-- Description    :
--
-- Preconditions  :
--
--
--
--
-- Postcondition  :
--
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
FUNCTION hasJournalView(p_class_name VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
  CURSOR c_class_db_mapping IS
    SELECT *
    FROM   class_db_mapping
    WHERE  class_name = p_class_name ;

    lv2_retval VARCHAR2(1):='N';

  BEGIN

    FOR cur IN c_class_db_mapping LOOP

      IF TableExists(cur.DB_OBJECT_NAME||'_JN',cur.DB_OBJECT_OWNER) THEN
        lv2_retval := 'Y';
      END IF;

    END LOOP;

    RETURN lv2_retval;

  END;

END EcDp_ClassMeta;