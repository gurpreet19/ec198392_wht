CREATE OR REPLACE PACKAGE BODY transfer_web_util IS
/***********************************************************************
** Package body       :  transfer_web_util
**
** $Revision: 1.5 $
**
** Purpose            :  Provide functions supporting data capture.
**
**
** Documentation  :  www.energy-components.com
**
** Created  : 16.02.2004  Harald Kaada
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- --------------------------------------'
** 2005-05-25  HAK   If PK_ATTR_X does not exist, use input string instead of NULL. (Required by Tracker 2271)
**
***************************************************************************/

CURSOR c_mapping(map_no varchar2) IS
SELECT * FROM trans_mapping t
 WHERE t.mapping_no = map_no;

--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Function       : getPrimKey
-- Description    :

--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--------------------------------------------------------------------------------------------------
FUNCTION getPrimKey(map_no VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS

lv2_retval varchar2(2000);

BEGIN
	lv2_retval := '';
	FOR m IN c_mapping(map_no) LOOP

    IF m.pk_val_1 IS NOT NULL THEN
    	lv2_retval := nvl(Ec_Class_Attribute_Cnfg.db_sql_syntax(m.data_class,m.pk_attr_1), m.pk_attr_1);
    END IF;

    IF m.pk_val_2 IS NOT NULL THEN
    	lv2_retval := lv2_retval ||','|| nvl(Ec_Class_Attribute_Cnfg.db_sql_syntax(m.data_class,m.pk_attr_2), m.pk_attr_2);
    END IF;

    IF m.pk_val_3 IS NOT NULL THEN
    	lv2_retval := lv2_retval ||','|| nvl(Ec_Class_Attribute_Cnfg.db_sql_syntax(m.data_class,m.pk_attr_3), m.pk_attr_3);
    END IF;

    IF m.pk_val_4 IS NOT NULL THEN
    	lv2_retval := lv2_retval ||','|| nvl(Ec_Class_Attribute_Cnfg.db_sql_syntax(m.data_class,m.pk_attr_4), m.pk_attr_4);
    END IF;

    IF m.pk_val_5 IS NOT NULL THEN
    	lv2_retval := lv2_retval ||','|| nvl(Ec_Class_Attribute_Cnfg.db_sql_syntax(m.data_class,m.pk_attr_5), m.pk_attr_5);
    END IF;

    IF m.pk_val_6 IS NOT NULL THEN
    	lv2_retval := lv2_retval ||','|| nvl(Ec_Class_Attribute_Cnfg.db_sql_syntax(m.data_class,m.pk_attr_6), m.pk_attr_6);
    END IF;

    IF m.pk_val_7 IS NOT NULL THEN
    	lv2_retval := lv2_retval ||','|| nvl(Ec_Class_Attribute_Cnfg.db_sql_syntax(m.data_class,m.pk_attr_7), m.pk_attr_7);
    END IF;

    IF m.pk_val_8 IS NOT NULL THEN
    	lv2_retval := lv2_retval ||','|| nvl(Ec_Class_Attribute_Cnfg.db_sql_syntax(m.data_class,m.pk_attr_8), m.pk_attr_8);
    END IF;

    IF m.pk_val_9 IS NOT NULL THEN
    	lv2_retval := lv2_retval ||','|| nvl(Ec_Class_Attribute_Cnfg.db_sql_syntax(m.data_class,m.pk_attr_9), m.pk_attr_9);
    END IF;

    IF m.pk_val_10 IS NOT NULL THEN
    	lv2_retval := lv2_retval ||','|| nvl(Ec_Class_Attribute_Cnfg.db_sql_syntax(m.data_class,m.pk_attr_10), m.pk_attr_10);
    END IF;

  END LOOP;

  RETURN lv2_retval;

END getPrimKey;


--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Function       : getPrimKeyValues
-- Description    :

--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
--------------------------------------------------------------------------------------------------
FUNCTION getPrimKeyValues(map_no VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS

lv2_retval varchar2(2000);

BEGIN
	lv2_retval := '';
	FOR m IN c_mapping(map_no) LOOP

    IF m.pk_val_1 IS NOT NULL THEN
    	lv2_retval := '''' || m.pk_val_1 || '''';
    END IF;

    IF m.pk_val_2 IS NOT NULL THEN
    	lv2_retval := lv2_retval || ',''' || m.pk_val_2 || '''';
    END IF;

    IF m.pk_val_3 IS NOT NULL THEN
    	lv2_retval := lv2_retval || ',''' || m.pk_val_3 || '''';
    END IF;

    IF m.pk_val_4 IS NOT NULL THEN
    	lv2_retval := lv2_retval || ',''' || m.pk_val_4 || '''';
    END IF;

    IF m.pk_val_5 IS NOT NULL THEN
    	lv2_retval := lv2_retval || ',''' || m.pk_val_5 || '''';
    END IF;

    IF m.pk_val_6 IS NOT NULL THEN
    	lv2_retval := lv2_retval || ',''' || m.pk_val_6 || '''';
    END IF;

    IF m.pk_val_7 IS NOT NULL THEN
    	lv2_retval := lv2_retval || ',''' || m.pk_val_7 || '''';
    END IF;

    IF m.pk_val_8 IS NOT NULL THEN
    	lv2_retval := lv2_retval || ',''' || m.pk_val_8 || '''';
    END IF;

    IF m.pk_val_9 IS NOT NULL THEN
    	lv2_retval := lv2_retval || ',''' || m.pk_val_9 || '''';
    END IF;

    IF m.pk_val_10 IS NOT NULL THEN
    	lv2_retval := lv2_retval || ',''' || m.pk_val_10 || '''';
    END IF;

  END LOOP;

  RETURN lv2_retval;

END getPrimKeyValues;


END;