CREATE OR REPLACE PACKAGE BODY EcDp_Utilities IS
/************************************************************************
** Package   :  EcDp_utilities
** $Revision: 1.3 $
**
** Purpose   :  Convenience methods
**
** General Logic:
**
** Created:      06.03.02  Dagfinn Nj�
**
**
** Modification history:
**
**
** Date:      Whom:  Change description:
** ----------  -----  ------------------------------------------------------
** 06.03.2002  DN    Initial version based upon rev. 1.3 of EcDp_Us_Utilities package.
** 25.04.2002  TeJ   Fixed error message spelling error in executeStatement
** 17.07.2002  TeJ   Added function executeSinglerowString
** 16.10.2006  SRA   Added generix rounding and compare functions
***************************************************************************/




--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : Gen_BF_Description(p_BF_Code, p_RetrieveLevel, p_StoreDataLevel)                                                --
-- Description    : Generates BF Description SQL file with the inserts/updates needed            --
--                  Each BF will get a separate SQl file!                                        --
--                  Parameter usage:                                                             --
--                  The cursor for getting the BF description use a LIKE operator               --
--                  Thus the parameter should look like this:                                    --
--                  To run for a particlar BF: p_BF_code = 'SP.0001'                             --
--                  To run for all BF in a particular area: p_BF_Code = 'SP%'                    --
--                  To run for a subset: p_BF_Code = 'SP.004%'                                   --
--                  p_StoreDataLevel is by default set to 0.
--                  You can override this to store the bf_description to either datalevel 1 or 2
--                  in order to create SQLs for datalevel 1 (Template) or datalevel 2 (Customer)
--                  p_RetrieveLevel is by default set to 2.
--                  You can override this to retrieve the bf_description from either datalevel 0 or 1
--                  in order to retrieve bf_descriptions for these data levels (1 for Template / 0 for Product)
--
-- Preconditions  : You need Read/Write access to an Oracle directory called BF_DIR              --
--
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
PROCEDURE Gen_BF_Description (p_BF_CODE VARCHAR2, p_RetrieveDataLevel NUMBER default 2, p_StoreDataLevel  NUMBER DEFAULT 0)

IS

  lob_in         clob;
  i              integer := 0;
  lob_size       integer;
  buffer_size    integer := 2000;
  template_blobx varchar2(4000);
  text_x         varchar2(4000);
  lv2_sqlstring  varchar2(4000);
  rec_cnt        number;
  lv2_bf_code    VARCHAR2(32);
  fileHandler    UTL_FILE.FILE_TYPE;
  lv2_filename   varchar2(300);
  ln_storedatalevel NUMBER;
  ln_RetrieveDataLevel NUMBER;
  lb_got_a_desc BOOLEAN;

  CallParameterError EXCEPTION;
  WrongDataStoreLevel EXCEPTION;
  WrongRetrieveLevel EXCEPTION;

  cursor bfsqls (cp_bf_code VARCHAR2) is
    select ss.sqlstring,
           ss.order_no,
           ss.bf_code
     FROM bf_desc_export ss
    where sqlstring is not null
    and ss.bf_code = cp_bf_code
     ORDER BY bf_code, ORDER_no;

  cursor bf_list is
    select distinct ss.bf_code
     FROM bf_desc_export ss
     ORDER BY bf_code;

  cursor c_bfs (cp_BF_CODE VARCHAR2)is
    select * from business_function t
    where t.bf_code like cp_BF_CODE
    --to ensure a single record if there are more than one rec in business_function with the same BF_CODE:
    and t.business_function_no = (select min(y.business_function_no) from business_function y where y.bf_code = t.bf_code)
    order by t.bf_code;


  cursor mydesc (cp_bf_code VARCHAR2, cp_RetrieveDataLevel number) IS
    select
     x.*
     from bf_description x
     where x.bf_description_no = cp_bf_code
     and x.bf_description_no = (select max(y.bf_description_no)
                                from bf_description y
                                where y.business_function_no = x.business_function_no)
     and data_level = cp_RetrieveDataLevel ; --modified help text is stored to data_level 2

BEGIN
  --Check inputs
  IF p_BF_CODE is null THEN
    --Error
    raise CallParameterError;
  END IF;

  IF p_StoreDataLevel is null THEN
    ln_storedatalevel := 0;
  END IF;

  IF p_StoreDataLevel > 2 THEN
    --Error
    raise WrongDataStoreLevel;
  ELSE
    ln_storedatalevel := p_StoreDataLevel;
  END IF;

  IF p_RetrieveDataLevel is null THEN
    ln_RetrieveDataLevel := 2;
  END IF;

  IF p_RetrieveDataLevel > 2 THEN
    --Error
    raise WrongRetrieveLevel;
  ELSE
    ln_RetrieveDataLevel := p_RetrieveDataLevel;
  END IF;
  --clean out the table for intermediate storage of the SQLs
  delete from bf_desc_export;
  --clean out t_temptext
  DELETE FROM t_temptext where id = 'GEN_BF_DESC';

  for bf in c_bfs (p_BF_CODE)  loop
    lv2_bf_code := bf.bf_code;
    lb_got_a_desc := false;

    FOR rec in mydesc (lv2_bf_code, ln_RetrieveDataLevel) loop
       lb_got_a_desc := true;
       --get the bf description and the size of it:
       if rec.description is null then
         lob_in := 'Missing Description';
       else
         lob_in := rec.description;
       end if;

       lob_in := REPLACE(lob_in,'''','''' || ''''); --put in an extra apostrophe for each existing apostrophe
       lob_size := dbms_lob.getlength(lob_in); --get the total length of the CLOB - needed for the chopping...

--*****************************************************************
       -- Create the INSERTS/UPDATES for the resulting SQL script:
--*****************************************************************
       --Delete existing bf description entry
       insert into bf_desc_export
                  (BF_CODE, order_no, sqlstring)
                values
                  (lv2_bf_code,
                   -3,
'DELETE from bf_description where bf_description_no = ''' || lv2_bf_code || ''' and data_level = '||ln_storedatalevel||';'
                 );
       --Create the initial insert.
       insert into bf_desc_export
                  (BF_CODE, order_no, sqlstring)
                values
                  (lv2_bf_code,
                   -2,
'INSERT INTO bf_description (business_function_no, data_level, bf_description_no)
 values (ECDP_BUSINESS_FUNCTION.getBusinessFunctionNo(''' || lv2_bf_code || '''), '||ln_storedatalevel||',''' || lv2_bf_code || ''');'
                   );
       --Here we go!:
       insert into bf_desc_export
                    (BF_CODE, order_no, sqlstring)
                  values
                    (lv2_bf_code,
                     -1,
'DECLARE
    lob         CLOB;
begin
    dbms_lob.createtemporary(lob,true,dbms_lob.session);
    update bf_description set description=lob where bf_description_no = ''' || lv2_bf_code || ''' and data_level = '||ln_storedatalevel||';
    select description into lob from bf_description where bf_description_no = ''' || lv2_bf_code || ''' and data_level = '||ln_storedatalevel||';
    dbms_lob.open(lob, dbms_lob.lob_readwrite);'
                     );

      --loop over the CLOB and chop it into 2000 chars chunks
      for i in 0 .. (lob_size / buffer_size) loop

        template_blobx         := dbms_lob.substr(lob_in,
                                          buffer_size,
                                          i * buffer_size + 1);
        if template_blobx is not null then
          insert into bf_desc_export
            (BF_CODE, order_no, sqlstring)
          values
            (lv2_bf_code,
             i,
             '    dbms_lob.writeappend(lob, ' || length(replace( template_blobx,'''' || '''','''')) || ',''' || template_blobx ||''' );'
             );
        end if;
        rec_cnt := i +1;
      end loop;
      --Finalize the inserts with the close of the dbms_lob and END statement
      insert into bf_desc_export
                        (BF_CODE, order_no, sqlstring)
                      values
                        (lv2_bf_code, rec_cnt,
'    dbms_lob.close(lob);
END;
/');
    end loop;

    if lb_got_a_desc = true then
      ecdp_dynsql.WriteTempText('GEN_BF_DESC','BF Description created for BF '||lv2_bf_code||' '||ec_business_function.name(bf.business_function_no));
    else
      ecdp_dynsql.WriteTempText('GEN_BF_DESC','No BF Description created for BF '||lv2_bf_code||' '||ec_business_function.name(bf.business_function_no));
    end if;
    lb_got_a_desc := false;
  end loop;

  --Write to file - One file per BF
  --NOTE: Read/Write access needed to Oracle Directory 'BF_DIR'!!
  For b in bf_list  loop
    lv2_filename := b.bf_code||'.sql';
    fileHandler := UTL_FILE.FOPEN('BF_DIR', lv2_filename, 'W', 4000);
    --Get start of file
    UTL_FILE.PUT_LINE(fileHandler, '--Generated by ecdp_utilites.Gen_BF_Description function');
    UTL_FILE.PUT_LINE(fileHandler, '--Date: '||Ecdp_Timestamp.getCurrentSysdate||'');
    UTL_FILE.PUT_LINE(fileHandler, 'SET SQLBLANKLINES ON');
    UTL_FILE.PUT_LINE(fileHandler, 'SET DEFINE OFF');
    --Get all the SQLs into the file
    for x in bfsqls (b.bf_code) loop
      lv2_sqlstring := x.sqlstring;
      UTL_FILE.PUT_LINE(fileHandler, lv2_sqlstring);
    end loop;
    UTL_FILE.PUT_LINE(fileHandler, 'SET SQLBLANKLINES OFF');
    UTL_FILE.PUT_LINE(fileHandler, 'SET DEFINE ON');
    --Close the fileHandle
    UTL_FILE.FCLOSE(fileHandler);
  end loop;

  EXCEPTION
      WHEN CallParameterError THEN
        Raise_Application_Error(-20000,'No action performed - parameter p_BF_Code is null.');
      WHEN WrongDataStoreLevel THEN
        Raise_Application_Error(-20000,'No action performed - parameter p_StoreDataLevel must be 0, 1, or 2.');
      WHEN WrongRetrieveLevel THEN
        Raise_Application_Error(-20000,'No action performed - parameter p_RetrieveDataLevel must be 0, 1, or 2.');

--UTIL_FILE error handling:

      WHEN UTL_FILE.internal_error THEN
          Raise_Application_Error(-20000,'UTL_FILE: An internal error occurred for BF '|| lv2_filename);
          UTL_FILE.FCLOSE_ALL;
      WHEN UTL_FILE.invalid_filehandle THEN
          Raise_Application_Error(-20000,'UTL_FILE: The file handle was invalid for BF '|| lv2_filename);
          UTL_FILE.FCLOSE_ALL;
      WHEN UTL_FILE.invalid_mode THEN
          Raise_Application_Error(-20000,'UTL_FILE: An invalid open mode was given for BF '|| lv2_filename);
          UTL_FILE.FCLOSE_ALL;
      WHEN UTL_FILE.invalid_operation THEN
          Raise_Application_Error(-20000,'UTL_FILE: An invalid operation was attempted for BF '|| lv2_filename);
          UTL_FILE.FCLOSE_ALL;
      WHEN UTL_FILE.invalid_path THEN
          Raise_Application_Error(-20000,'UTL_FILE: An invalid path was give for the file for BF '|| lv2_filename);
          UTL_FILE.FCLOSE_ALL;
      WHEN UTL_FILE.read_error THEN
          Raise_Application_Error(-20000,'UTL_FILE: A read error occurred for BF '|| lv2_filename);
          UTL_FILE.FCLOSE_ALL;
      WHEN UTL_FILE.write_error THEN
          Raise_Application_Error(-20000,'UTL_FILE: A write error occurred for BF '|| lv2_filename);
          UTL_FILE.FCLOSE_ALL;
      WHEN UTL_FILE.charsetmismatch THEN
          Raise_Application_Error(-20000,'UTL_FILE: A character mismatch occurred for BF '|| lv2_filename);
          UTL_FILE.FCLOSE_ALL;
      WHEN UTL_FILE.FILE_OPEN THEN
          Raise_Application_Error(-20000,'UTL_FILE: A File Open error occurred for BF '|| lv2_filename);
          UTL_FILE.FCLOSE_ALL;
      WHEN UTL_FILE.INVALID_MAXLINESIZE THEN
          Raise_Application_Error(-20000,'UTL_FILE: A Max Line Size error occurred for BF '|| lv2_filename);
          UTL_FILE.FCLOSE_ALL;
      WHEN UTL_FILE.INVALID_FILENAME THEN
          Raise_Application_Error(-20000,'UTL_FILE: An Invalid File Name error occurred for BF '|| lv2_filename);
          UTL_FILE.FCLOSE_ALL;
      WHEN UTL_FILE.ACCESS_DENIED THEN
          Raise_Application_Error(-20000,'UTL_FILE: An Access Denied error occurred for BF '|| lv2_filename);
          UTL_FILE.FCLOSE_ALL;
      WHEN UTL_FILE.INVALID_OFFSET THEN
          Raise_Application_Error(-20000,'UTL_FILE: An Invalid Offset error occurred for BF '|| lv2_filename);
          UTL_FILE.FCLOSE_ALL;
      WHEN UTL_FILE.DELETE_FAILED THEN
          Raise_Application_Error(-20000,'UTL_FILE: A Delete Failed error occurred for BF '|| lv2_filename);
          UTL_FILE.FCLOSE_ALL;
      WHEN UTL_FILE.RENAME_FAILED THEN
          Raise_Application_Error(-20000,'UTL_FILE: A Rename Failed error occurred for BF '|| lv2_filename);
          UTL_FILE.FCLOSE_ALL;
      WHEN others THEN
          Raise_Application_Error(-20000,'Some other error occurred for BF '|| lv2_filename);
          UTL_FILE.FCLOSE_ALL;
END Gen_BF_Description;

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

li_cursor      integer;
li_returverdi   integer;
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

li_cursor      INTEGER;
li_returverdi   INTEGER;
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

li_cursor      INTEGER;
li_returverdi   INTEGER;
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

li_cursor  INTEGER;
li_ret_val  INTEGER;

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