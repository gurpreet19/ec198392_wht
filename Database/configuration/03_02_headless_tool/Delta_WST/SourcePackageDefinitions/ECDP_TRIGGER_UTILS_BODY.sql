CREATE OR REPLACE PACKAGE BODY ecdp_trigger_utils IS

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getActualClassName
-- Description    : Given a p_class_name, verify that it is a class_name or really a base table
--                  If it is a base table, return the editable object class that use the table.
--                  Return the base table with error message if not found
-- Postconditions :
--
-- Using tables   : user_tables
--                  class
--                  class_db_mapping
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : If p_class_name exists, return as is. If base table, try to find the class
--                  If no class uses the base table, return base table as is with error
---------------------------------------------------------------------------------------------------
FUNCTION getActualClassName(p_class_name VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
 IS
  CURSOR c_class IS
    SELECT class_name FROM class_cnfg WHERE class_name=p_class_name;

  CURSOR c_class2 IS
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
    SELECT cc.class_name class_name
      FROM class_cnfg cc
      LEFT OUTER JOIN w_read_only fc
        ON (cc.class_name = fc.class_name and
           fc.property_code = 'READ_ONLY_IND')
     WHERE cc.db_object_name = p_class_name
     AND nvl(fc.property_value, 'N')='N';

  lv_class_name class_cnfg.class_name%TYPE;
  ln_count      NUMBER := 0;
BEGIN
  FOR one IN c_class LOOP
    lv_class_name := one.class_name;
  END LOOP;

  IF lv_class_name IS NOT NULL THEN
    return lv_class_name;
  END IF;

  FOR one IN c_class2 LOOP
    lv_class_name := one.class_name;
    ln_count := ln_count + 1;
  END LOOP;

  IF ln_count > 1 THEN
    -- found multiple classes for the same base table
    RETURN NULL;
  END IF;

  IF lv_class_name IS NOT NULL THEN
    return lv_class_name;
  END IF;

  --ecdp_dynsql.writetemptext('CLASSNAMEERROR','No editable object class found for table ['||p_class_name||']');
  return p_class_name;
END getActualClassName;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : insertObject
-- Description    : Insert into objects according to the setting
--
-- Preconditions  :
--
-- Postcondition  :
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
PROCEDURE iudObject(p_class_name VARCHAR2, p_old_object_id VARCHAR2, p_new_object_id VARCHAR2, p_code VARCHAR2, p_start_date DATE, p_end_date DATE, p_created_by VARCHAR2, p_created_date DATE, p_insert BOOLEAN DEFAULT TRUE)
--</EC-DOC>
IS
  lv2_class_name    class_cnfg.class_name%TYPE;
BEGIN
  lv2_class_name := getActualClassName(p_class_name);
  IF lv2_class_name IS NOT NULL THEN
      DELETE objects_table WHERE object_id=p_old_object_id;
      IF p_insert THEN
        BEGIN
            INSERT INTO objects_table (class_name, object_id, code, start_date, end_date, created_by, created_date)
              VALUES (lv2_class_name, p_new_object_id, p_code, p_start_date, p_end_date, p_created_by, p_created_date);

        EXCEPTION WHEN OTHERS THEN
          -- EcDp_DynSql.writetemptext('IUD_OBJ_ERR', 'Unable to insert record object : [' || SQLERRM || ']');
          NULL;
        END;
      END IF;
  END IF;
END iudObject;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : insertObjectVersion
-- Description    : Insert into object_version according to the setting
--
-- Preconditions  :
--
-- Postcondition  :
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
PROCEDURE iudObjectVersion(p_class_name VARCHAR2, p_old_object_id VARCHAR2, p_new_object_id VARCHAR2, p_name VARCHAR2, p_daytime DATE, p_end_date DATE, p_created_by VARCHAR2, p_created_date DATE, p_insert BOOLEAN DEFAULT TRUE)
--</EC-DOC>
IS
BEGIN
  DELETE objects_version_table WHERE object_id=p_old_object_id AND daytime=p_daytime;
  IF p_insert THEN
    BEGIN
        INSERT INTO objects_version_table (class_name, object_id, object_start_date, object_end_date, daytime, end_date, object_code, name, created_by, created_date)
          SELECT o.class_name, p_new_object_id, o.start_date, o.end_date, p_daytime, p_end_date, o.code, p_name, p_created_by, p_created_date
            FROM objects_table o WHERE object_id = p_new_object_id;
    EXCEPTION WHEN OTHERS THEN
      -- EcDp_DynSql.writetemptext('IUD_OBJ_VER_ERR', 'Unable to insert record object version: [' || SQLERRM || ']');
      NULL;
    END;
  END IF;
END iudObjectVersion;

END ecdp_trigger_utils;