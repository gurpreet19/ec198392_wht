CREATE OR REPLACE PACKAGE BODY EcDp_Adv_Excel_Helper IS
/****************************************************************
** Package        :  EcDp_Adv_Excel_Helper, body part
**
** $Revision: 1.7 $
**
** Purpose        :  Provice helper functions for the advanced Excel Import mechanism.
**
** Documentation  :  www.energy-components.com
**
** Created  :
**
** Modification history:
**
** Version  Date        Whom    Change description:
** -------  ------      -----   --------------------------------------
**  1.1     27.01.2005  SRA     Initial revision
*****************************************************************/

FUNCTION getKey(p_class_name VARCHAR2,
                p_key_num NUMBER)
RETURN VARCHAR2 IS
CURSOR c_key(cp_class_name VARCHAR2) IS
SELECT 1 as UnionPart, ca.attribute_name, c.class_type, Ecdp_Classmeta_Cnfg.getDbSortOrder(ca.class_name, ca.attribute_name) AS sort_order
FROM class_cnfg c, class_attribute_cnfg ca
WHERE c.class_name = cp_class_name
AND c.class_name = ca.class_name
AND ca.is_key = 'Y'
union all
SELECT 2, cl.role_name || '_CODE', c.class_type, Ecdp_Classmeta_Cnfg.getDbSortOrder(cl.from_class_name, cl.to_class_name, cl.role_name) AS sort_order
FROM class_relation_cnfg cl, class_cnfg c
WHERE cl.to_class_name = cp_class_name
AND c.class_name = cl.to_class_name
AND cl.is_key = 'Y'
ORDER BY UnionPart, Sort_Order;

lv2_attributeName VARCHAR2(240);
lv2_classType VARCHAR2(10);
ln_counter NUMBER := 1;

BEGIN

    lv2_attributeName := NULL;
    lv2_classType := NULL;

    FOR curKey IN c_key(p_class_name) LOOP
        IF (ln_counter = p_key_num) THEN
            lv2_attributeName := curKey.attribute_name;
            lv2_classType := curKey.class_type;
            EXIT;
        END IF;
        ln_counter := ln_counter + 1;
    END LOOP;

    IF (lv2_attributeName = 'OBJECT_ID') THEN
        IF (lv2_classType = 'OBJECT') THEN
           lv2_attributeName := 'CODE';
        ELSE
           lv2_attributeName := 'OBJECT_CODE';
        END IF;

    END IF;

    RETURN lv2_attributeName;
END getKey;

FUNCTION getKeyType(p_class_name VARCHAR2,
                p_key_num NUMBER)
RETURN VARCHAR2 IS
CURSOR c_key(cp_class_name VARCHAR2) IS
SELECT 1 as UnionPart, ca.data_type, Ecdp_Classmeta_Cnfg.getDbSortOrder(ca.class_name, ca.attribute_name) AS sort_order
FROM class_attribute_cnfg ca
WHERE ca.class_name = cp_class_name
AND ca.is_key = 'Y'
union all
SELECT 2, 'STRING', Ecdp_Classmeta_Cnfg.getDbSortOrder(cl.from_class_name, cl.to_class_name, cl.role_name) AS sort_order
FROM class_relation_cnfg cl
WHERE cl.to_class_name = cp_class_name
AND cl.is_key = 'Y'
ORDER BY UnionPart, Sort_Order;

lv2_attributeName VARCHAR2(240);
ln_counter NUMBER := 1;

BEGIN

    lv2_attributeName := NULL;

    FOR curKey IN c_key(p_class_name) LOOP
        IF (ln_counter = p_key_num) THEN
            lv2_attributeName := curKey.data_type;
            EXIT;
        END IF;
        ln_counter := ln_counter + 1;
    END LOOP;

    RETURN lv2_attributeName;
END getKeyType;

FUNCTION checkKey(p_class_name VARCHAR2,
  p_key_value_1 VARCHAR2,
  p_key_value_2 VARCHAR2 DEFAULT NULL,
  p_key_value_3 VARCHAR2 DEFAULT NULL,
  p_key_value_4 VARCHAR2 DEFAULT NULL,
  p_key_value_5 VARCHAR2 DEFAULT NULL,
  p_key_value_6 VARCHAR2 DEFAULT NULL,
  p_key_value_7 VARCHAR2 DEFAULT NULL,
  p_key_value_8 VARCHAR2 DEFAULT NULL,
  p_key_value_9 VARCHAR2 DEFAULT NULL,
  p_key_value_10 VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
IS

lv2_return VARCHAR2(32) := 'N';
lv2_owner_class VARCHAR2(32) := NULL;
lv2_object_id VARCHAR2(32) := NULL;
lv2_sql VARCHAR2(4000) := NULL;
ln_counter NUMBER;

CURSOR c_owner(cp_class_name VARCHAR2) IS
SELECT c.owner_class_name
FROM class_cnfg c
WHERE c.class_name = cp_class_name;

CURSOR c_keys(cp_class_name VARCHAR2) IS
SELECT ca.attribute_name, c.class_type, ca.db_sql_syntax, ca.data_type
FROM class_cnfg c, class_attribute_cnfg ca
WHERE c.class_name = cp_class_name
AND c.class_name = ca.class_name
AND ca.is_key = 'Y'
ORDER BY EcDp_ClassMeta_Cnfg.getDbSortOrder(ca.class_name, ca.attribute_name);

BEGIN

    FOR CurOwner IN c_owner(p_class_name) LOOP
        lv2_owner_class := CurOwner.Owner_Class_Name;
    END LOOP;

    IF (lv2_owner_class IS NOT NULL) THEN -- Lookup based on owner class
        lv2_object_id := ecdp_objects.GetObjIDFromCode(lv2_owner_class, p_key_value_1);
    END IF;

    lv2_sql := 'SELECT count(*) FROM ' || p_class_name || ' WHERE ';
    IF (p_key_value_10 IS NOT NULL) THEN -- 10 Keys
        ln_counter := 1;
        FOR CurKeys IN c_keys(p_class_name) LOOP
            IF (ln_counter = 1) THEN
                lv2_sql := lv2_sql || ' OBJECT_ID = ''' || lv2_object_id || '''';
            ELSIF (ln_counter = 2) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_2);
            ELSIF (ln_counter = 3) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_3);
            ELSIF (ln_counter = 4) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_4);
            ELSIF (ln_counter = 5) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_5);
            ELSIF (ln_counter = 6) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_6);
            ELSIF (ln_counter = 7) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_7);
            ELSIF (ln_counter = 8) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_8);
            ELSIF (ln_counter = 9) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_9);
            ELSIF (ln_counter = 10) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_10);
            END IF;
            ln_counter := ln_counter + 1;
        END LOOP;
    ELSIF (p_key_value_9 IS NOT NULL) THEN -- 9 Keys
        ln_counter := 1;
        FOR CurKeys IN c_keys(p_class_name) LOOP
            IF (ln_counter = 1) THEN
                lv2_sql := lv2_sql || ' OBJECT_ID = ''' || lv2_object_id || '''';
            ELSIF (ln_counter = 2) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_2);
            ELSIF (ln_counter = 3) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_3);
            ELSIF (ln_counter = 4) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_4);
            ELSIF (ln_counter = 5) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_5);
            ELSIF (ln_counter = 6) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_6);
            ELSIF (ln_counter = 7) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_7);
            ELSIF (ln_counter = 8) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_8);
            ELSIF (ln_counter = 9) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_9);
            END IF;
            ln_counter := ln_counter + 1;
        END LOOP;
    ELSIF (p_key_value_8 IS NOT NULL) THEN -- 8 Keys
        ln_counter := 1;
        FOR CurKeys IN c_keys(p_class_name) LOOP
            IF (ln_counter = 1) THEN
                lv2_sql := lv2_sql || ' OBJECT_ID = ''' || lv2_object_id || '''';
            ELSIF (ln_counter = 2) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_2);
            ELSIF (ln_counter = 3) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_3);
            ELSIF (ln_counter = 4) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_4);
            ELSIF (ln_counter = 5) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_5);
            ELSIF (ln_counter = 6) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_6);
            ELSIF (ln_counter = 7) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_7);
            ELSIF (ln_counter = 8) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_8);
            END IF;
            ln_counter := ln_counter + 1;
        END LOOP;
    ELSIF (p_key_value_7 IS NOT NULL) THEN -- 7 Keys
        ln_counter := 1;
        FOR CurKeys IN c_keys(p_class_name) LOOP
            IF (ln_counter = 1) THEN
                lv2_sql := lv2_sql || ' OBJECT_ID = ''' || lv2_object_id || '''';
            ELSIF (ln_counter = 2) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_2);
            ELSIF (ln_counter = 3) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_3);
            ELSIF (ln_counter = 4) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_4);
            ELSIF (ln_counter = 5) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_5);
            ELSIF (ln_counter = 6) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_6);
            ELSIF (ln_counter = 7) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_7);
            END IF;
            ln_counter := ln_counter + 1;
        END LOOP;
    ELSIF (p_key_value_6 IS NOT NULL) THEN -- 6 Keys
        ln_counter := 1;
        FOR CurKeys IN c_keys(p_class_name) LOOP
            IF (ln_counter = 1) THEN
                lv2_sql := lv2_sql || ' OBJECT_ID = ''' || lv2_object_id || '''';
            ELSIF (ln_counter = 2) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_2);
            ELSIF (ln_counter = 3) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_3);
            ELSIF (ln_counter = 4) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_4);
            ELSIF (ln_counter = 5) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_5);
            ELSIF (ln_counter = 6) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_6);
            END IF;
            ln_counter := ln_counter + 1;
        END LOOP;
    ELSIF (p_key_value_5 IS NOT NULL) THEN -- 5 Keys
        ln_counter := 1;
        FOR CurKeys IN c_keys(p_class_name) LOOP
            IF (ln_counter = 1) THEN
                lv2_sql := lv2_sql || ' OBJECT_ID = ''' || lv2_object_id || '''';
            ELSIF (ln_counter = 2) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_2);
            ELSIF (ln_counter = 3) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_3);
            ELSIF (ln_counter = 4) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_4);
            ELSIF (ln_counter = 5) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_5);
            END IF;
            ln_counter := ln_counter + 1;
        END LOOP;
    ELSIF (p_key_value_4 IS NOT NULL) THEN -- 4 Keys
        ln_counter := 1;
        FOR CurKeys IN c_keys(p_class_name) LOOP
            IF (ln_counter = 1) THEN
                lv2_sql := lv2_sql || ' OBJECT_ID = ''' || lv2_object_id || '''';
            ELSIF (ln_counter = 2) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_2);
            ELSIF (ln_counter = 3) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_3);
            ELSIF (ln_counter = 4) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_4);
            END IF;
            ln_counter := ln_counter + 1;
        END LOOP;
    ELSIF (p_key_value_3 IS NOT NULL) THEN -- 3 Keys
        ln_counter := 1;
        FOR CurKeys IN c_keys(p_class_name) LOOP
            IF (ln_counter = 1) THEN
                lv2_sql := lv2_sql || ' OBJECT_ID = ''' || lv2_object_id || '''';
            ELSIF (ln_counter = 2) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_2);
            ELSIF (ln_counter = 3) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_3);
            END IF;
            ln_counter := ln_counter + 1;
        END LOOP;
    ELSIF (p_key_value_2 IS NOT NULL) THEN -- 2 Keys
        ln_counter := 1;
        FOR CurKeys IN c_keys(p_class_name) LOOP
            IF (ln_counter = 1) THEN
                lv2_sql := lv2_sql || ' OBJECT_ID = ''' || lv2_object_id || '''';
            ELSIF (ln_counter = 2) THEN
                lv2_sql := lv2_sql || getSQLAnd(CurKeys.Db_Sql_Syntax, CurKeys.Data_Type, p_key_value_2);
            END IF;
            ln_counter := ln_counter + 1;
        END LOOP;
    END IF;

    ln_counter := 0;
    Ecdp_Dynsql.WriteTempText('SQL', lv2_sql);
    EXECUTE IMMEDIATE lv2_sql INTO ln_counter;

    -- Returns Y when both object and data found
    -- Returns O when object found but no data found
    -- Returns N when whether object or data is found
    IF (ln_counter > 0 AND lv2_object_id IS NOT NULL) THEN
        lv2_return := 'Y';
    ELSIF (lv2_object_id IS NOT NULL) THEN
        lv2_return := 'O';
    ELSE
        lv2_return := 'N';
    END IF;

    RETURN lv2_return;
END checkKey;

FUNCTION getSQLAnd(p_column VARCHAR2, p_data_type VARCHAR2, p_value VARCHAR2)
RETURN VARCHAR2
IS
lv2_txt VARCHAR2(4000) := ' AND ';
BEGIN
    IF (p_data_type = 'DATE') THEN -- Asume ISO date
        --'2008-10-20T00:00:00'
        lv2_txt := lv2_txt || 'TO_CHAR(' || p_column || ',''YYYY-MM-DD"T"HH24:MI:SS'') = ''' || p_value || '''';
    ELSIF (p_data_type = 'NUMBER') THEN
        lv2_txt := lv2_txt || p_column || ' = ' || p_value;
    ELSE -- String
        lv2_txt := lv2_txt || p_column || ' = ''' || p_value || '''';
    END IF;
    RETURN lv2_txt;
END getSQLAnd;

END EcDp_Adv_Excel_Helper;