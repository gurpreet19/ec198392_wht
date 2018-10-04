CREATE OR REPLACE PACKAGE BODY EcDp_Utilities IS
/************************************************************************
** Package   :  EcDp_utilities
** $Revision: 1.3 $
**
** Purpose   :  Convenience methods
**
** General Logic:
**
** Created:      06.03.02  Dagfinn Njå
**
**
** Modification history:
**
**
** Date:			Whom:	Change description:
** ----------	-----	------------------------------------------------------
** 06.03.2002  DN    Initial version based upon rev. 1.3 of EcDp_Us_Utilities package.
** 25.04.2002  TeJ   Fixed error message spelling error in executeStatement
** 17.07.2002  TeJ   Added function executeSinglerowString
** 16.10.2006  SRA   Added generix rounding and compare functions
***************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isNumber                                                                     --
-- Description    : Checks whether a string is a number. Returns true if this is the case        --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION isNumber(p_string_repr VARCHAR2) RETURN BOOLEAN
--</EC-DOC>
IS

ln_value NUMBER;

BEGIN

   ln_value := TO_NUMBER(p_string_repr);

   RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN RETURN FALSE;

END isNumber;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : executeSinglerowDate                                                         --
-- Description    : Executes a dynamic SQL SELECT which returns 1 row of type DATE.              --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION executeSinglerowDate(p_statement varchar2) RETURN DATE
--</EC-DOC>
IS

li_cursor	    integer;
li_returverdi	 integer;
ld_return_value date;

BEGIN

   li_cursor := DBMS_SQL.Open_Cursor;

   DBMS_SQL.Parse(li_cursor,p_statement,DBMS_SQL.v7);
   DBMS_SQL.Define_Column(li_cursor,1,ld_return_value);

   li_returverdi := DBMS_SQL.Execute(li_cursor);

   IF DBMS_SQL.Fetch_Rows(li_cursor) = 0 THEN
        DBMS_SQL.Close_Cursor(li_cursor);
	RETURN NULL;
   ELSE
        DBMS_SQL.Column_Value(li_cursor,1,ld_return_value);
   END IF;

   DBMS_SQL.Close_Cursor(li_cursor);

   RETURN ld_return_value;

EXCEPTION

	WHEN OTHERS THEN

      IF  DBMS_SQL.is_open(li_cursor) THEN
         DBMS_SQL.Close_Cursor(li_cursor);
      END IF;

   RETURN NULL;

END executeSinglerowDate;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : executeSinglerowString                                                       --
-- Description    : Executes a dynamic SQL SELECT which returns 1 row of type VARCHAR2.          --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION executeSinglerowString(p_statement VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
IS

li_cursor	    INTEGER;
li_returverdi	 INTEGER;
lv2_return_value VARCHAR2(2000);

BEGIN

   li_cursor := DBMS_SQL.Open_Cursor;

   DBMS_SQL.Parse(li_cursor,p_statement,DBMS_SQL.v7);
   DBMS_SQL.Define_Column(li_cursor,1,lv2_return_value, 2000);

   li_returverdi := DBMS_SQL.Execute(li_cursor);

   IF DBMS_SQL.Fetch_Rows(li_cursor) = 0 THEN

	   lv2_return_value := NULL;

   ELSE

      DBMS_SQL.Column_Value(li_cursor,1, lv2_return_value);

   END IF;

   DBMS_SQL.Close_Cursor(li_cursor);

   RETURN lv2_return_value;

EXCEPTION

	WHEN OTHERS THEN

      IF  DBMS_SQL.is_open(li_cursor) THEN
         DBMS_SQL.Close_Cursor(li_cursor);
      END IF;

   RETURN NULL;

END executeSinglerowString;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : executeSinglerowNumber                                                       --
-- Description    : Executes a dynamic SQL SELECT which returns 1 row of type NUMBER.            --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION executeSinglerowNumber(p_statement VARCHAR2) RETURN NUMBER
--</EC-DOC>
IS

li_cursor	    INTEGER;
li_returverdi	 INTEGER;
ln_return_value NUMBER;

BEGIN

   li_cursor := DBMS_SQL.Open_Cursor;

   DBMS_SQL.Parse(li_cursor,p_statement,DBMS_SQL.v7);
   DBMS_SQL.Define_Column(li_cursor,1,ln_return_value);

   li_returverdi := DBMS_SQL.Execute(li_cursor);

   IF DBMS_SQL.Fetch_Rows(li_cursor) = 0 THEN

	   ln_return_value := NULL;

   ELSE

      DBMS_SQL.Column_Value(li_cursor,1, ln_return_value);

   END IF;

   DBMS_SQL.Close_Cursor(li_cursor);

   RETURN ln_return_value;

EXCEPTION

	WHEN OTHERS THEN

      IF  DBMS_SQL.is_open(li_cursor) THEN
         DBMS_SQL.Close_Cursor(li_cursor);
      END IF;

   RETURN NULL;

END executeSinglerowNumber;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : executeStatement                                                             --
-- Description    : Executes a dynamic SQL statement. No binding                                 --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION executeStatement(p_statement varchar2) RETURN VARCHAR2
--</EC-DOC>
IS

li_cursor	integer;
li_ret_val	integer;
lv2_err_string VARCHAR2(2000);

BEGIN

   li_cursor := DBMS_SQL.open_cursor;

   DBMS_SQL.parse(li_cursor,p_statement,DBMS_SQL.v7);

   li_ret_val := DBMS_SQL.execute(li_cursor);

   DBMS_SQL.Close_Cursor(li_cursor);

	RETURN NULL;

EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
		   DBMS_SQL.Close_Cursor(li_cursor);

		-- record not inserted, already there...
		lv2_err_string := 'Failed to execute (record exists): ' || chr(10) || p_statement || chr(10);
		return lv2_err_string;
	WHEN INVALID_CURSOR THEN

		lv2_err_string := 'Failed to execute (' || SQLERRM || '): ' || chr(10) || p_statement || chr(10);
		return lv2_err_string;

	WHEN OTHERS THEN
		IF DBMS_SQL.is_open(li_cursor) THEN
			DBMS_SQL.Close_Cursor(li_cursor);
      END IF;

		lv2_err_string := 'Failed to execute (' || SQLERRM || '): ' || chr(10) || p_statement || chr(10);
		return lv2_err_string;

END executeStatement;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTagToken                                                                  --
-- Description    : Finds and removes and returns TAG=VALUE token from string                    --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions : p_tagged_string without the tag token.                                       --
--                                                                                               --
-- Using tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getTagToken(
   p_tagged_string IN OUT VARCHAR2,
   p_find_tag VARCHAR2,
   p_field_sep VARCHAR2,
   p_tag_sep VARCHAR2
) RETURN VARCHAR2
--</EC-DOC>
IS
   lv2_find VARCHAR2(200);
   lv2_start VARCHAR2(2000);
   lv2_end VARCHAR2(2000);
   lv2_token VARCHAR2(2000);
   li_start INTEGER;
   li_end INTEGER;
BEGIN
   lv2_token := NULL;
   lv2_start := NULL;
   lv2_end := NULL;

   -- check arguments
   IF p_tagged_string IS NULL OR p_tagged_string = '' THEN
      RETURN lv2_token;
   END IF;
   IF p_find_tag IS NULL OR p_find_tag = '' THEN
      RETURN lv2_token;
   END IF;
   IF p_field_sep IS NULL OR p_field_sep = '' THEN
      RETURN lv2_token;
   END IF;
   IF p_tag_sep IS NULL OR p_tag_sep = '' THEN
      RETURN lv2_token;
   END IF;

   -- try from beginning
   lv2_find := p_find_tag || p_tag_sep;
   li_start := 0;
   li_end := 0;

   -- starts with the required tag
   IF SUBSTR(p_tagged_string,1,LENGTH(lv2_find)) = lv2_find THEN
      li_start := 1;
      li_end := INSTR(p_tagged_string,p_field_sep,1) - 1;
      -- no more separators, take the rest
      IF li_end < 1 THEN
         li_end := LENGTH(p_tagged_string);
      END IF;
   -- perhaps further down the road
   ELSE
      lv2_find := p_field_sep || p_find_tag || p_tag_sep;
      li_start := INSTR(p_tagged_string,lv2_find,1);
      IF li_start > 0 THEN
         li_start := li_start + 1;
         li_end := INSTR(p_tagged_string,p_field_sep,li_start + LENGTH(lv2_find) -1) - 1;
         -- no more separators, take the rest
         IF li_end < 1 THEN
            li_end := LENGTH(p_tagged_string);
         END IF;
      END IF;
   END IF;

   IF li_end > 0 THEN
      lv2_token := SUBSTR(p_tagged_string,li_start,li_end - li_start + 1);
      -- and remove from original
      IF li_start > 1 THEN
         lv2_start := SUBSTR(p_tagged_string,1,li_start-1);
      END IF;
      IF li_end < LENGTH(p_tagged_string) THEN
         lv2_end := SUBSTR(p_tagged_string,li_end+2,LENGTH(p_tagged_string)-li_end-1);
      END IF;
      p_tagged_string := lv2_start || lv2_end;

   END IF;

   RETURN lv2_token;

END getTagToken;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getValue                                                                     --
-- Description    : Gets the value part of TAG=VALUE string                                      --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getValue(p_in_string VARCHAR2,p_tag_separator VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
IS
   lv2_value VARCHAR2(2000);
   li_start INTEGER;
BEGIN
   lv2_value := NULL;
   -- check arguments
   IF p_in_string IS NULL OR p_in_string = '' THEN
      RETURN lv2_value;
   END IF;

   IF p_tag_separator IS NULL OR p_tag_separator = '' THEN
      RETURN lv2_value;
   END IF;

   li_start := INSTR(p_in_string,p_tag_separator,1);
   IF li_start > 1 THEN
      lv2_value := SUBSTR(p_in_string,li_start+1,LENGTH(p_in_string) - li_start);
   END IF;

   RETURN lv2_value;

END getValue;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNextToken                                                                 --
-- Description    : Finds and removes and returns next token from string.                        --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions : p_token_string contains the remaining string                                 --
--                                                                                               --
-- Using tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getNextToken(p_token_string IN OUT VARCHAR2, p_separator VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
IS
   lv2_token   VARCHAR2(2000);
   li_start    INTEGER;
BEGIN
   lv2_token := NULL;
   -- check arguments
   IF p_token_string IS NULL OR p_token_string = '' THEN
      RETURN lv2_token;
   END IF;

   IF p_separator IS NULL OR p_separator = '' THEN
      RETURN lv2_token;
   END IF;

   li_start := 0;

   li_start := INSTR(p_token_string,p_separator, 1);
   -- last token
   IF li_start = 0 THEN
      lv2_token := p_token_string;
      p_token_string := NULL;
   -- still separators in string
   ELSE
      lv2_token := SUBSTR(p_token_string,1, li_start-1);
      p_token_string := SUBSTR(p_token_string,li_start + 1, LENGTH(p_token_string) - li_start + length(p_separator) + 1);
   END IF;

   RETURN lv2_token;

END getNextToken;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTag                                                                       --
-- Description    : Gets the tag part of TAG=VALUE string                                        --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION getTag(p_in_string VARCHAR2, p_tag_separator VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
IS
   lv2_tag VARCHAR2(2000);
   li_start INTEGER;
BEGIN
   lv2_tag := NULL;
   -- check arguments
   IF p_in_string IS NULL OR p_in_string = '' THEN
      RETURN lv2_tag;
   END IF;

   IF p_tag_separator IS NULL OR p_tag_separator = '' THEN
      RETURN lv2_tag;
   END IF;
   li_start := INSTR(p_in_string,p_tag_separator,1);
   IF li_start > 1 THEN
      lv2_tag := SUBSTR(p_in_string,1,li_start-1);
   END IF;

   RETURN lv2_tag;

END getTag;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GenericRounding                                                              --
-- Description    : Rounds to the total number which is input                                    --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
PROCEDURE GenericRounding(
      p_table_name VARCHAR2,
      p_column_name VARCHAR2,
      p_total_val  NUMBER,
      p_where VARCHAR2
)
--</EC-DOC>
IS

ln_col_sum NUMBER;
lv2_sql_statement VARCHAR2(2000);

lv2_rowid VARCHAR2(32);

li_cursor	INTEGER;
li_ret_val	INTEGER;

BEGIN

     lv2_sql_statement := 'SELECT Sum(' || p_column_name || ') ' ||
                          'FROM ' || p_table_name || ' WHERE ' || p_where;

     -- do dynamic sql parsing
     li_cursor := Dbms_Sql.Open_Cursor;

     Dbms_sql.Parse(li_cursor,lv2_sql_statement,dbms_sql.v7);
     Dbms_Sql.Define_Column(li_cursor,1,ln_col_sum);

     li_ret_val := Dbms_Sql.Execute(li_cursor);

     IF Dbms_Sql.Fetch_Rows(li_cursor) = 0 THEN
       	Dbms_Sql.Close_Cursor(li_cursor);
     ELSE
          Dbms_Sql.Column_Value(li_cursor,1,ln_col_sum);
     END IF;

     Dbms_Sql.Close_Cursor(li_cursor);


     IF p_total_val <> ln_col_sum THEN

        lv2_sql_statement := 'SELECT rowid FROM ' || p_table_name ||
                             ' WHERE ' || p_where || ' AND Abs(' || p_column_name || ') = ' ||
                             ' ( SELECT Max(Abs(' || p_column_name || ')) ' ||
                                'FROM ' || p_table_name || ' WHERE ' || p_where || ')';

        -- loop over cursor, but pick the first one
           li_cursor := Dbms_Sql.Open_Cursor;

           Dbms_sql.Parse(li_cursor,lv2_sql_statement,dbms_sql.v7);
           Dbms_Sql.Define_Column(li_cursor,1,lv2_rowid,32);

           li_ret_val := Dbms_Sql.Execute(li_cursor);

           IF Dbms_Sql.Fetch_Rows(li_cursor) > 0 THEN
                 Dbms_Sql.Column_Value(li_cursor,1,lv2_rowid);
           END IF;

           Dbms_Sql.Close_Cursor(li_cursor);

           lv2_sql_statement := 'UPDATE ' || p_table_name ||
                               ' SET ' || p_column_name || ' = ' || p_column_name || ' + ' || to_char(p_total_val - ln_col_sum,'999999999999990.9999999999','NLS_NUMERIC_CHARACTERS='',.''') ||
                               ' ,last_updated_by = ''SYSTEM'' '  ||
                               ' WHERE rowid = ''' || lv2_rowid || '''';


           li_cursor := Dbms_Sql.Open_Cursor;

           Dbms_sql.Parse(li_cursor,lv2_sql_statement,dbms_sql.v7);
           li_ret_val :=  Dbms_sql.Execute(li_cursor);

           Dbms_sql.Close_Cursor(li_cursor);

      END IF;

EXCEPTION

         WHEN OTHERS THEN
            Dbms_sql.Close_Cursor(li_cursor);
            Raise_Application_Error(-20000,'Error please contact technical personell and refer to this message : ' || lv2_sql_statement );

END GenericRounding;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isVarcharUpdated                                                             --
-- Description    : Returns true if parameters are different                                     --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION isVarcharUpdated(
      p_old VARCHAR2,
      p_new VARCHAR2
) RETURN BOOLEAN
IS
--</EC-DOC>
lb_updated BOOLEAN := false;
BEGIN
    IF (NVL(p_old, 'XXX') <> NVL(p_new, 'XXX')) THEN
        lb_updated := true;
    END IF;
    RETURN lb_updated;
END isVarcharUpdated;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isDateUpdated                                                                --
-- Description    : Returns true if parameters are different                                     --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION isDateUpdated(
      p_old DATE,
      p_new DATE
) RETURN BOOLEAN
IS
--</EC-DOC>
lb_updated BOOLEAN := false;
BEGIN
    IF (NVL(p_old, to_date('17.05.1814','DD.MM.YYYY')) <> NVL(p_new, to_date('17.05.1814','DD.MM.YYYY'))) THEN
        lb_updated := true;
    END IF;
    RETURN lb_updated;
END isDateUpdated;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isNumberUpdated                                                             --
-- Description    : Returns true if parameters are different                                     --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION isNumberUpdated(
      p_old NUMBER,
      p_new NUMBER
) RETURN BOOLEAN
IS
--</EC-DOC>
lb_updated BOOLEAN := false;
BEGIN
    IF (NVL(p_old, -99999) <> NVL(p_new, -99999)) THEN
        lb_updated := true;
    END IF;
    RETURN lb_updated;
END isNumberUpdated;

END EcDp_Utilities;