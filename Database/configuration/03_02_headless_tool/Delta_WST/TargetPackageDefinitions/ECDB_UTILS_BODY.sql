CREATE OR REPLACE PACKAGE BODY EcDB_Utils AS
/**************************************************************
** Package   :  ecdp_utils
** $Revision: 1.6 $
**
** Purpose   :
**
** General Logic:
**
** Created:
**
**
** Modification history:
**
**
** Date:       Whom: Change description:
** ----------  ----- --------------------------------------------
** 2002-0?-??  FBa   Initial version
** 2002-02-15  WBi   Added columnLength function.
** 2002-04-22  DN    Added countKeyColumnConstraints function
** 2002-09-19  TeJ   Added getDataType function.
** 2004-10-06  AV    Added new functions ConditionNvl (3 version with datatype overloading)
** 2005-03-08  SHN   Added FUNCTION  TruncText
** 2005-04-18  SHN   Fixed bug in TruncText
** 2008-06-19  HUS   Added FUNCTION toEcDataType
**************************************************************/

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : countKeyColumnConstraints
-- Description    : Returns the number of occurences of the table column specified in any primary
--                  or unique keys of the table.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : user_constraints, user_cons_columns
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION countKeyColumnConstraints(--p_owner VARCHAR2,
                                     p_table_name VARCHAR2,
                                     p_column_name VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS

ln_count NUMBER;

BEGIN

   SELECT count(*)
   INTO ln_count
   FROM user_constraints uc, user_cons_columns ucc
   WHERE -- uc.owner = p_owner AND
       uc.table_name = p_table_name
   AND uc.constraint_type IN ('U','P')
--   AND ucc.owner = uc.owner
   AND ucc.table_name = uc.table_name
   AND ucc.constraint_name = uc.constraint_name
   AND ucc.column_name = p_column_name;

   RETURN ln_count;

END countKeyColumnConstraints;


FUNCTION existsTableColumn(
   p_table_name   IN VARCHAR2,
   p_column_name  IN VARCHAR2)
RETURN BOOLEAN
IS

CURSOR c_tabcol (p_table_name IN VARCHAR2, p_column_name IN VARCHAR2) IS
SELECT *
FROM all_tab_columns
WHERE table_name = UPPER(p_table_name) AND column_name = UPPER(p_column_name);

lr_tabcol all_tab_columns%ROWTYPE;
lb_retval BOOLEAN;

BEGIN

   OPEN c_tabcol (p_table_name, p_column_name);

   FETCH c_tabcol INTO lr_tabcol;

   IF c_tabcol%NOTFOUND THEN
      lb_retval := FALSE;
   ELSE
      lb_retval := TRUE;
   END IF;

   CLOSE c_tabcol;

   RETURN lb_retval;

END existsTableColumn;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : getDataType
-- Description    : Returns the data type of a given column and table.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : user_tab_columns
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION columnLength(
   p_table_name   IN VARCHAR2,
   p_column_name  IN VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS

   CURSOR c_tabcol (p_table_name IN VARCHAR2, p_column_name IN VARCHAR2) IS
      SELECT *
      FROM ALL_TAB_COLUMNS
      WHERE TABLE_NAME = Upper(p_table_name)
      AND COLUMN_NAME = Upper(p_column_name);

   lr_tabcol ALL_TAB_COLUMNS%ROWTYPE;
   ln_retval NUMBER;

BEGIN

   OPEN c_tabcol (p_table_name, p_column_name);

   FETCH c_tabcol INTO lr_tabcol;

   IF c_tabcol%NOTFOUND THEN
      ln_retval := 0;
   ELSE
      ln_retval := lr_tabcol.DATA_LENGTH;
   END IF;

   CLOSE c_tabcol;

   RETURN ln_retval;

END columnLength;


--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : getDataType
-- Description    : Returns the data type of a given column and table.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : all_tab_columns
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION getDataType(
   p_object_name   IN VARCHAR2,
   p_column_name  IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS

   CURSOR c_tabCol(cp_object_name VARCHAR2, cp_column_name VARCHAR2) IS
      SELECT *
      FROM ALL_TAB_COLUMNS
      WHERE TABLE_NAME = Upper(cp_object_name)
      AND COLUMN_NAME = Upper(cp_column_name);

   lr_tabCol ALL_TAB_COLUMNS%ROWTYPE;
   lv2_retVal ALL_TAB_COLUMNS.DATA_TYPE%TYPE;

BEGIN

   OPEN c_tabCol (p_object_name, p_column_name);

   FETCH c_tabCol INTO lr_tabcol;

   IF c_tabCol%NOTFOUND THEN
      lv2_retVal := NULL;
   ELSE
      lv2_retVal := lr_tabCol.DATA_TYPE;
   END IF;

   CLOSE c_tabCol;

   RETURN lv2_retVal;

END getDataType;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : ConditionNvl
-- Description    : Only use nvl if condition is true
--
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
-- Behavior       :
--
--
--
---------------------------------------------------------------------------------------------------
FUNCTION  ConditionNvl(p_condition BOOLEAN, p1 VARCHAR2, p2 VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>

IS
  lv2_str     VARCHAR2(32000);

BEGIN

  IF p_condition THEN

     lv2_str := Nvl(p1,p2);

  ELSE

     lv2_str := p1;

  END IF;

  RETURN lv2_str;

END;

FUNCTION  ConditionNvl(p_condition BOOLEAN,p1 DATE, p2 DATE)
RETURN DATE
--</EC-DOC>

IS
  ld     DATE;

BEGIN

  IF p_condition THEN

     ld := Nvl(p1,p2);

  ELSE

     ld := p1;

  END IF;

  RETURN ld;

END;


FUNCTION  ConditionNvl(p_condition BOOLEAN,p1 NUMBER, p2 NUMBER)
RETURN NUMBER
--</EC-DOC>

IS
  ln_num     NUMBER;

BEGIN

  IF p_condition THEN

     ln_num := Nvl(p1,p2);

  ELSE

     ln_num := p1;

  END IF;

  RETURN ln_num;

END;

FUNCTION TruncText(p_text	VARCHAR2, p_max_length	NUMBER)
RETURN VARCHAR2
IS

	lv2_returnText		VARCHAR2(32000);
	ln_length			NUMBER := LENGTH(p_text);

BEGIN

	IF ln_length > p_max_length THEN

		-- Try first to remove all vowels, if this is not enough text is truncated.
		lv2_returnText := Replace(Translate(UPPER(p_text),'AEIOU','u'),'u');
   	ln_length := LENGTH(lv2_returnText);

   	IF ln_length > p_max_length THEN -- Not enought, need to trunc text

   		lv2_returnText := SUBSTR(p_text,1,p_max_length);

   	END IF;

	ELSE

		lv2_returnText := p_text;

	END IF;

	RETURN lv2_returnText;

END;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : toEcDataType
-- Description    : Returns the EC data type for the given ORA data type.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : all_tab_columns
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------
FUNCTION toEcDataType(
   p_ora_data_type   IN VARCHAR2
)
RETURN VARCHAR2
--</EC-DOC>
IS
   lv2_base_ora_data_type ALL_TAB_COLUMNS.DATA_TYPE%TYPE;
   ln_pos                 INTEGER;
BEGIN

   IF p_ora_data_type IS NULL THEN
     RETURN NULL;
   END IF;

   lv2_base_ora_data_type:=Upper(p_ora_data_type);
   ln_pos := Instr(lv2_base_ora_data_type,'(');
   IF ln_pos > 0 THEN
     lv2_base_ora_data_type:=Substr(lv2_base_ora_data_type, 0, ln_pos);
   END IF;

   IF lv2_base_ora_data_type IN ('CHAR','NCHAR','NVARCHAR2','VARCHAR2','LONG','RAW','LONG RAW') THEN
     RETURN 'STRING';
   END IF;
   IF lv2_base_ora_data_type IN ('NUMBER','NUMERIC','FLOAT','DEC','DECIMAL','INTEGER','INT','SMALLINT','REAL','DOUBLE PRECISION') THEN
     RETURN 'NUMBER';
   END IF;
   IF lv2_base_ora_data_type IN ('DATE','TIMESTAMP') THEN
     RETURN 'DATE';
   END IF;

   RETURN NULL;

END toEcDataType;


END;