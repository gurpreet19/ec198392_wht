CREATE OR REPLACE PACKAGE BODY EcDp_DynSql IS
/**************************************************************
** Package:    EcDp_DynSql
**
** $Revision: 1.20 $
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
** Created:   	21.12.98  Arild Vervik, ISI AS
**
**
** Modification history:
**
**
** Date:     Whom:  Change description:
** --------  ----- --------------------------------------------
** 13.10.2004 AV   Fixed weaknes in date_to_string,
**                 added 3 new functions SafeString, SafeNumber, safeDate
** 08.04.2005 AV   Added logging to t_temptext for safebuild
** 08.11.2005 AV   Fixed bug in WriteTempText splitting line in wrong places
** 13.12.2005 AV   Support function converting an ID to anydata building up dynamic SQL
** 07.03.2006 DN   TI 3569: Added overloaded version of SafeBuild.
** 08.03.2006 AV   Added p_raise_error VARCHAR2 DEFAULT 'N' to SafeBuild procedure, removed dummy creation
** 11.08.2006 AV   Added new parameter to Safebuild, allowing user to spesify if parsing should
                   add linefeed after each line is structure, this is a default parameter, the default behaviour
                   remains unchanged
** 18.04.2007 HUS  Added AddSqlLines
** 28.08.2008 KEB  Added WriteDebugText
**************************************************************/

syntax_error EXCEPTION;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : execute_statement                                                            --
-- Description    : executes a dynamic SQL statement. No binding                                 --
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
-- Behaviour      : Parse and executes a SQL statement                                           --
--                                                                                               --
---------------------------------------------------------------------------------------------------
PROCEDURE execute_statement(
   p_statement      VARCHAR2
   )
--</EC-DOC>

IS

li_cursor	   integer;
li_returverdi	integer;
lv2_result     varchar2(2000);



BEGIN


   li_cursor := Dbms_sql.open_cursor;

   Dbms_sql.parse(li_cursor,p_statement,dbms_sql.v7);
   li_returverdi := Dbms_sql.execute(li_cursor);
   Dbms_Sql.Close_Cursor(li_cursor);


END execute_statement;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : execute_singlerow_date                                                       --
-- Description    : executes a dynamic SQL statement. Returns a date                             --
--                                                                                               --
-- Preconditions  : Statement must select a date column from the database                        --
-- Postcondition  : Return the data from the first row returned from database                    --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      : Parse and executes a SQL statement                                           --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION execute_singlerow_date(
   p_statement varchar2
   )
   RETURN DATE
--</EC-DOC>

IS

li_cursor	integer;
li_returverdi	integer;

ld_return_value date;

BEGIN

   li_cursor := Dbms_Sql.Open_Cursor;

   Dbms_sql.Parse(li_cursor,p_statement,dbms_sql.v7);
   Dbms_Sql.Define_Column(li_cursor,1,ld_return_value);

   li_returverdi := Dbms_Sql.Execute(li_cursor);

   IF Dbms_Sql.Fetch_Rows(li_cursor) = 0 THEN
	Dbms_Sql.Close_Cursor(li_cursor);
	RETURN NULL;
   ELSE
        Dbms_Sql.Column_Value(li_cursor,1,ld_return_value);
   END IF;

   Dbms_Sql.Close_Cursor(li_cursor);

   RETURN ld_return_value;

EXCEPTION

	WHEN OTHERS THEN

                IF  Dbms_sql.is_open(li_cursor) THEN
                    Dbms_Sql.Close_Cursor(li_cursor);
                END IF;

		-- log error, but continue
		RETURN NULL;

END execute_singlerow_date;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : execute_singlerow_varchar2                                                   --
-- Description    : executes a dynamic SQL statement. Returns a varchar2                         --
--                                                                                               --
-- Preconditions  : Statement must select a varchar2 expression from the database                --
-- Postcondition  : Return data from the first row returned from database                        --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      : Parse and executes a SQL statement                                           --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION execute_singlerow_varchar2(
   p_statement varchar2)
RETURN VARCHAR2
--</EC-DOC>

IS

li_cursor	integer;
li_returverdi	integer;

lv2_return_value varchar2(255);

BEGIN

   li_cursor := Dbms_Sql.Open_Cursor;

   Dbms_sql.Parse(li_cursor,p_statement,dbms_sql.v7);
   Dbms_Sql.Define_Column(li_cursor,1,lv2_return_value,255);

   li_returverdi := Dbms_Sql.Execute(li_cursor);

   IF Dbms_Sql.Fetch_Rows(li_cursor) = 0 THEN
        Dbms_Sql.Close_Cursor(li_cursor);
	RETURN NULL;
   ELSE
        Dbms_Sql.Column_Value(li_cursor,1,lv2_return_value);
   END IF;

   Dbms_Sql.Close_Cursor(li_cursor);

   RETURN lv2_return_value;

EXCEPTION

	WHEN OTHERS THEN

                IF  Dbms_sql.is_open(li_cursor) THEN
                    Dbms_Sql.Close_Cursor(li_cursor);
                END IF;

                RETURN NUll;

END execute_singlerow_varchar2;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : execute_singlerow_number                                                     --
-- Description    : executes a dynamic SQL statement. Returns a number                           --
--                                                                                               --
-- Preconditions  : Statement must select a number expression from the database                  --
-- Postcondition  : Return data from the first row returned from database                        --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      : Parse and executes a SQL statement                                           --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION execute_singlerow_number(
  p_statement varchar2)
RETURN NUMBER
--</EC-DOC>

IS

li_cursor	integer;
li_returverdi	integer;

ln_return_value number;

BEGIN

   li_cursor := Dbms_Sql.Open_Cursor;

   Dbms_sql.Parse(li_cursor,p_statement,dbms_sql.v7);
   Dbms_Sql.Define_Column(li_cursor,1,ln_return_value);

   li_returverdi := Dbms_Sql.Execute(li_cursor);

   IF Dbms_Sql.Fetch_Rows(li_cursor) = 0 THEN
        Dbms_Sql.Close_Cursor(li_cursor);
	RETURN NULL;
   ELSE
        Dbms_Sql.Column_Value(li_cursor,1,ln_return_value);
   END IF;

   Dbms_Sql.Close_Cursor(li_cursor);

   RETURN ln_return_value;

EXCEPTION

	WHEN OTHERS THEN

                IF  Dbms_sql.is_open(li_cursor) THEN
                    Dbms_Sql.Close_Cursor(li_cursor);
                END IF;

        RETURN NUll;


END execute_singlerow_number
;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : date_to_string
-- Description    : takes a date and returns it as a string with to_date convertion
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
FUNCTION date_to_string(p_daytime date
)
RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_datestr VARCHAR2(100);

BEGIN

   IF p_daytime IS NOT NULL THEN

      lv2_datestr := ' to_date(''' || to_char(p_daytime,'dd.mm.yyyy hh24:mi:ss') ||
                             ''', ''dd.mm.yyyy hh24:mi:ss'')' ;

   ELSE

      lv2_datestr :=  ' to_date(NULL) ' ;


   END IF;

   RETURN lv2_datestr;


END date_to_string
;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : SafeNumber
-- Description    : takes a number and returns it as a string with . as decimal separator
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
FUNCTION SafeNumber(p_number NUMBER, p_datatype VARCHAR2 DEFAULT 'NUMBER')
RETURN VARCHAR2
--</EC-DOC>
IS

   ln_value             NUMBER;
   ld_date              DATE;
   lv2_value            VARCHAR2(32000);
   lv2_text             VARCHAR2(32000);

BEGIN


   IF p_datatype = 'NUMBER' THEN

      IF p_number IS NULL THEN
         lv2_value := 'NULL';
      ELSE
         lv2_value := TO_CHAR(p_number,'9999999999999999D9999999999','NLS_NUMERIC_CHARACTERS=''.,''') ;
      END IF;

   ELSIF p_datatype = 'INTEGER' THEN

      IF p_number IS NULL THEN
         lv2_value := 'NULL';
      ELSE

         IF p_number - FLOOR(p_number) > 0 THEN

            Raise_Application_Error(-20107,'Value '||p_number||' is not a valid INTEGER.'  );

         END IF;

         lv2_value := TO_CHAR(p_number,'9999999999999999D9999999999','NLS_NUMERIC_CHARACTERS=''.,''') ;
      END IF;

   ELSE

      Raise_Application_Error(-20108,'Unsupported data type '||p_datatype||' in Ecdp_objects.UpdateObjectDataTables .');

   END IF;

   RETURN lv2_value;

END SafeNumber;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : SafeDate
-- Description    : takes a date and returns it as a string with to_date convertion
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
FUNCTION Safedate(p_date DATE)
RETURN VARCHAR2
--</EC-DOC>
IS

   ln_value             NUMBER;
   ld_date              DATE;
   lv2_value            VARCHAR2(32000);
   lv2_text             VARCHAR2(32000);

BEGIN

   IF p_date IS NOT NULL THEN
      lv2_value := ecdp_dynsql.date_to_string(p_date);
   ELSE
      lv2_value := 'NULL' ;
   END IF;

   RETURN lv2_value;

END SafeDate;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : SafeString
-- Description    : takes a string and returns it as a string where ' has been replaced by ''
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
FUNCTION SafeString(p_string VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS

   lv2_value            VARCHAR2(32000);

BEGIN

      IF p_string IS NOT NULL THEN
         lv2_value := ''''|| REPLACE(p_string,'''','''''')||'''';
      ELSE
         lv2_value := 'NULL' ;
      END IF;


   RETURN lv2_value;

END SafeString;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : WriteDebugText                                                               --
-- Description    : Write debug to T_TEMPTEXT                                                   --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  : Truncates to 4000 chars and writes to T_temptext with ID = 'GENCODE'         --
--                  AUTONOMOUS_TRANSACTION COMMITTED                                             --
-- Using Tables   : T_TEMPTEXT and CTRL_SYSTEM_ATTRIBUTE                                         --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       : INSERT INTO ctrl_system_attribute (daytime,attribute_type,attribute_text,    --
--                  comments) values(to_date('01.01.1900','dd.mm.yyyy'),'DB_DEBUG_LEVEL','FALSE',--
--                  'Sets debug level for witing debug text. Default should be FALSE')           --
--                                                                                               --
-- Behavior       : Writes to DB based on what is set in CTRL_SYSTEM_ATTRIBUTE.ATTRIBUTE_TEXT    -- 
--                  for CTRL_SYSTEM_ATTRIBUTE.ATTRIBUTE_TYPE =DB_DEBUG_LEVEL:                    --
--                  - FALSE: Does not write anything to DB                                       --
--                  - ERROR: Write to DB if p_debuglevel equals 'ERROR'                          --
--                  - DEBUG: Write to DB if p_debuglevel equals 'DEBUG'                          --
--                  More levels can be added when needed.                                        --
---------------------------------------------------------------------------------------------------
PROCEDURE WriteDebugText(p_id_type VARCHAR2, p_sql VARCHAR2, p_debuglevel VARCHAR2)
--</EC-DOC>

IS

  CURSOR c_db_level IS
    select max(ATTRIBUTE_TEXT) as attr_text 
    from CTRL_SYSTEM_ATTRIBUTE 
    where ATTRIBUTE_TYPE='DB_DEBUG_LEVEL';

    lb_dowrite   BOOLEAN;
    lv2_db_level VARCHAR2(2000);

BEGIN

   FOR curLevel IN c_db_level LOOP
   
      lv2_db_level := NVL(curLevel.attr_text, 'FALSE');

      IF lv2_db_level = 'FALSE' THEN
         lb_dowrite := FALSE;
      ELSIF lv2_db_level='ERROR' AND p_debuglevel='ERROR' THEN
         lb_dowrite := TRUE;
      ELSIF lv2_db_level='DEBUG' AND p_debuglevel='DEBUG' THEN
         lb_dowrite := TRUE;
      ELSE  
         lb_dowrite := FALSE;
      END IF;
   
   END LOOP;

   IF lb_dowrite = TRUE THEN
      WriteTempText(p_id_type, p_sql);
   END IF;
     
END WriteDebugText;
---------------------------------------------------------------------------------

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : WriteTempText                                                                --
-- Description    : Write generated code to t_temptext                                           --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  : Truncates to 4000 chars and writes to T_temptext with ID = 'GENCODE'         --
--                  AUTONOMOUS_TRANSACTION COMMITTED                                             --
-- Using Tables   : T_TEMPTEXT                                                                   --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behavior       :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
PROCEDURE WriteTempText(p_id_type VARCHAR2, p_sql VARCHAR2)
--</EC-DOC>

IS

PRAGMA  AUTONOMOUS_TRANSACTION;

ln_line    NUMBER;
lv2_buffer VARCHAR2(4000);
ln_start   NUMBER := 1;
ln_end     NUMBER;
ln_length  NUMBER;
ln_count   NUMBER;
ln_crfound NUMBER;

BEGIN

   SELECT MAX(line_number) INTO ln_line FROM T_TEMPTEXT WHERE ID = p_id_type;

   ln_length := LENGTH(p_sql);
   ln_line := Nvl(ln_line+1,1);
   ln_crfound := 0;

   WHILE ln_length - ln_start >= 0 LOOP

    ln_crfound := 0;

    IF  ln_length - ln_start > 3999 THEN

        -- need to split in a safe place, this can be a bit tricky
        -- It's usually safe to look for a linebreak chr(10) instead of a white space.
        -- As a precaution we only go back a max number of places (but far enough!)

        ln_end := ln_start + 3999;
        ln_count := 0;

        IF SUBSTR(p_sql,ln_end,1) = CHR(10) THEN

          ln_crfound := 1;

        END IF;


        WHILE ln_count < 3000 AND SUBSTR(p_sql,ln_end,1) <> CHR(10) LOOP

           ln_end := ln_end - 1;
           ln_count := ln_count + 1;

           IF SUBSTR(p_sql,ln_end,1) = CHR(10) THEN

             ln_crfound := 1;

           END IF;


        END LOOP;

    ELSE

      ln_end := ln_length;

    END IF;

     IF ln_crfound = 1 THEN -- remove last CR from buffer
       lv2_buffer := SUBSTR(p_sql,ln_start,ln_end - ln_start);
     ELSE
       lv2_buffer := SUBSTR(p_sql,ln_start,ln_end - ln_start+1);
     END IF;

     INSERT INTO T_TEMPTEXT(id,line_number,text,created_by, created_date ) VALUES(p_id_type,ln_line,lv2_buffer,USER,SYSDATE);
     ln_start := ln_end + 1;
     ln_line := ln_line + 1;

   END LOOP;
  
   COMMIT;
  
END WriteTempText;




--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : purge_recyclebin                                                             --
-- Description    : Purges the recyclebin                                                        --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   : <recyclebin>                                                                 --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      : Purges the recyclebin, and handles exceptions for versions pre-Oracle10      --
--                                                                                               --
---------------------------------------------------------------------------------------------------
PROCEDURE PurgeRecycleBin
--</EC-DOC>

IS

BEGIN
  EXECUTE IMMEDIATE 'PURGE RECYCLEBIN';       

EXCEPTION
    WHEN OTHERS THEN
      NULL;  
  
END PurgeRecycleBin;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : AddSqlLine
-- Description    : Adds a new code line to a DBMS_SQL.varchar2a pl-sql table, splits it if string > 256 char
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
PROCEDURE AddSqlLine(p_lines   IN OUT DBMS_SQL.varchar2a,
                     p_newline IN     VARCHAR2,
                     p_nowrap         VARCHAR2 DEFAULT 'N'   -- Don't wrap long lines if this flag is set = 'Y'
)
--</EC-DOC>
IS
  lv2_newline VARCHAR2(32000) := p_newline;
  ln_end     NUMBER;
  ln_length  NUMBER;
  ln_line    NUMBER;
  ln_crfound NUMBER;

BEGIN

   IF  p_nowrap = 'N' THEN  -- split lines over 255 characters long

     -- First split on linebreak given by user
     ln_crfound := INSTR(lv2_newline,CHR(10));
     ln_length := LENGTH(lv2_newline);

     WHILE ln_crfound > 0 OR ln_length > 255 LOOP -- we need to split line

       -- see first if there is a CR that make first section < 256 characters
       IF ln_crfound > 0 AND ln_crfound < 256 THEN

         p_lines(nvl(p_lines.last,0)+1) := SUBSTR(lv2_newline,1,ln_crfound);
         lv2_newline := SUBSTR(lv2_newline,ln_crfound+1);


       ELSE -- need to split anyway, must find safe place to split use first blank chr(32) for this

         ln_end := 255;

         WHILE ln_end > 1 AND SUBSTR(lv2_newline,ln_end,1) <> CHR(32)   LOOP

            ln_end := ln_end -1;

         END LOOP;

         -- Check if we found a blank
         IF SUBSTR(lv2_newline,ln_end,1)<> CHR(32) THEN

           ln_end := 255; -- Just split after 255 characters

         END IF;

         p_lines(nvl(p_lines.last,0)+1) := SUBSTR(lv2_newline,1,ln_end);
         lv2_newline := SUBSTR(lv2_newline,ln_end+1);


      END IF;

      ln_crfound := INSTR(lv2_newline,CHR(10));
      ln_length := LENGTH(lv2_newline);

    END LOOP;

    IF LENGTH(lv2_newline) > 0 THEN

         p_lines(nvl(p_lines.last,0)+1) := SUBSTR(lv2_newline,1,256);

    END IF;

  ELSE

    p_lines(nvl(p_lines.last,0)+1) := p_newline;

  END IF;

END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : AddSqlLines
-- Description    : Adds a new code lines to a DBMS_SQL.varchar2a pl-sql table.
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
PROCEDURE AddSqlLines(p_lines    IN OUT DBMS_SQL.varchar2a,
                      p_newlines IN DBMS_SQL.varchar2a
)
--</EC-DOC>
IS
BEGIN
   FOR l IN 1..nvl(p_newlines.last,0) LOOP
	    AddSqlLine(p_lines, p_newlines(l));
   END LOOP;
END;



PROCEDURE SafeBuild(p_object_name VARCHAR2,
                    p_object_type VARCHAR2,
                    p_lines       DBMS_SQL.varchar2a,
                    p_target      VARCHAR2 DEFAULT 'CREATE',
                    p_id          VARCHAR2 DEFAULT 'GENCODE',
                    p_raise_error VARCHAR2 DEFAULT 'N',
                    p_lfflg       VARCHAR2 DEFAULT 'N'  -- Should be set to 'Y' if dbms_sql.parse should add chr(10) after each line in p_lines
                    )
--</EC-DOC>

IS

  CURSOR c_user_errors IS
  SELECT ue.line, ue.position, ue.text
  FROM user_errors ue
  WHERE ue.name = p_object_name
  AND   ue.type =  p_object_type;


  c BINARY_INTEGER;
  result         Integer;
  lb_error_found BOOLEAN := FALSE;
  lv2_errors     VARCHAR2(4000);

BEGIN

    IF p_target = 'CREATE' THEN -- create the view


      c := dbms_sql.open_cursor;
      IF p_lfflg = 'Y' THEN
         dbms_sql.parse(c,p_lines,p_lines.first,p_lines.last,TRUE,DBMS_SQL.NATIVE);
      ELSE
         dbms_sql.parse(c,p_lines,p_lines.first,p_lines.last,FALSE,DBMS_SQL.NATIVE);
      END IF;

      result := dbms_sql.execute(c);
      dbms_sql.close_cursor(c);

      -- Check for errors in user_errors
      FOR curError IN c_user_errors LOOP

        lb_error_found := TRUE;
        IF p_raise_error = 'N' THEN
          WriteTempText(p_id ||'ERROR',p_object_name||'('||curError.line||','||curError.position||'): '||curError.text|| CHR(10));

        ELSE

         Raise_Application_Error(-20000,'Syntax error generating '||p_object_type ||' for '||p_object_name||CHR(10)||
                                 '('||curError.line||','||curError.position||'): '||curError.text||p_lines(1)  );

        END IF;

      END LOOP;


      IF lb_error_found THEN

  --      WriteTempText(p_id ||'ERROR','Syntax error generating '||p_object_type ||' for '||p_object_name||CHR(10)||SQLERRM);

        FOR i IN  p_lines.first.. p_lines.last LOOP

            WriteTempText(p_id ||'ERROR',p_lines(i) || CHR(10));

        END LOOP;

        WriteTempText(p_id ||'ERROR','/'|| CHR(10));

      END IF;

    ELSE -- insert in t_temptext

        FOR i IN  p_lines.first.. p_lines.last LOOP

            WriteTempText(p_id ,p_lines(i) || CHR(10));

        END LOOP;

        WriteTempText(p_id ,'/'|| CHR(10));

    END IF;


EXCEPTION


   	WHEN OTHERS THEN

   	  IF p_raise_error = 'N' THEN

        WriteTempText(p_id || 'ERROR','Syntax error generating '||p_object_type ||' for '||p_object_name||CHR(10)||SQLERRM);

        FOR i IN  p_lines.first.. p_lines.last LOOP

            WriteTempText(p_id || 'ERROR',p_lines(i) || CHR(10));

        END LOOP;

        WriteTempText(p_id || 'ERROR','/'|| CHR(10));

        IF  Dbms_sql.is_open(c) THEN
            Dbms_Sql.Close_Cursor(c);
        END IF;

      ELSE

         Raise_Application_Error(-20000,'Syntax error generating '||p_object_type ||' for '||p_object_name||CHR(10)||SQLERRM  );


      END IF;



END SafeBuild;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : Anydata_to_String
-- Description    : Support function converting an ID to anydata building up dynamic SQL
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
FUNCTION Anydata_to_String(p_datetype VARCHAR2,p_id VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_return VARCHAR2(100);

BEGIN

   -- known data types 'STRING','NUMBER','INTEGER','DATE','VARCHAR2'

   IF p_datetype = 'DATE' THEN

     lv2_return := 'anydata.Convertdate('||p_id||')';

   ELSIF p_datetype IN ('NUMBER','INTEGER') THEN

     lv2_return := 'anydata.ConvertNumber('||p_id||')';

   ELSE

     lv2_return := 'anydata.ConvertVarChar2('||p_id||')';


   END IF;

   RETURN lv2_return;

END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : RecompileInvalid
-- Description    :
--
-- Preconditions  :
--
--
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
PROCEDURE RecompileInvalid
--</EC-DOC>
IS

    CURSOR c_invalid_obj IS
    SELECT 'alter package ' || object_name || ' compile' || chr(10) AS AlterStatement
    FROM user_objects
    WHERE status = 'INVALID'
    AND object_type = 'PACKAGE'
    UNION ALL
    SELECT 'alter package ' || object_name || ' compile body' || chr(10) AS AlterStatement
    FROM user_objects
    WHERE status = 'INVALID'
    AND object_type = 'PACKAGE BODY'
    UNION ALL
    SELECT 'alter view ' || object_name || ' compile' AS AlterStatement
    FROM user_objects
    WHERE status = 'INVALID'
    AND object_type = 'VIEW'
    UNION ALL
    SELECT 'alter trigger ' || object_name || ' compile' AS AlterStatement
    FROM user_objects
    WHERE status = 'INVALID'
    AND object_type = 'TRIGGER';

-- Comiple invalid objects

   lv2_sql      VARCHAR2(2000);
   ln_counter   NUMBER DEFAULT 0;

BEGIN   
   
   FOR curInv IN c_invalid_obj LOOP
      
      lv2_sql := curInv.AlterStatement; 
      ln_counter := ln_counter + 1;
      
      BEGIN   
         EXECUTE IMMEDIATE lv2_sql;       
      EXCEPTION
        WHEN OTHERS THEN
        lv2_sql := NULL;
      END;           
  
   END LOOP;

END;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : BackupAndDeleteTable
-- Description    : Make an old_xxx version of a table and check that all rows was coied before deleting original table 
--
-- Preconditions  : All foreign key constrainst need to be removed up front.
--
--
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
PROCEDURE BackupAndDeleteTable(p_table_name VARCHAR2) IS
--</EC-DOC>

  lv2_sql Varchar2(4000);
  ln_result  NUMBER;


BEGIN

  IF length(p_table_name) > 26 then
			Raise_Application_Error(-20100,'Filename to long to make backup as old_'|| p_table_name);
  end if;  

	lv2_sql := 'select count(*) FROM USER_TABLES WHERE TABLE_NAME = ''' ||p_table_name||'''';

  begin

		  ln_result := ecdp_dynsql.execute_singlerow_number(lv2_sql);
		
		  IF ln_result > 0 THEN 
		
		
					lv2_sql := 'CREATE TABLE OLD_'|| p_table_name ||' AS  SELECT * FROM ' ||p_table_name;
				
				
				    ecdp_dynsql.execute_statement(lv2_sql);
				
				  	lv2_sql := 'select count(*) FROM (SELECT * FROM  '|| p_table_name ||' MINUS  SELECT * FROM OLD_' ||p_table_name||')';
				  	ln_result := ecdp_dynsql.execute_singlerow_number(lv2_sql);
				
				  	IF ln_result > 0 THEN 
				      Raise_Application_Error(-20100,'Not complete backup for '|| p_table_name);
				    END IF;  
				
				    lv2_sql := 'Drop table '||p_table_name;
				    ecdp_dynsql.execute_statement(lv2_sql);
				
				
				    If p_table_name not in ('CLASS_DEPENDENCY') THEN
				    
				      lv2_sql := 'Drop table '||p_table_name||'_JN';
				      ecdp_dynsql.execute_statement(lv2_sql);
				      
				    END IF;  
		
    END IF;
		
		EXCEPTION
		
		    WHEN OTHERS THEN
		
		       Raise_Application_Error(-20100,'Failed backup for '|| p_table_name||' sql '||lv2_sql);
		
		end;



END;


FUNCTION CompareTableStructure(p_table_1 varchar2,
                               p_table_2 varchar2,
                               p_ignore_columns varchar2) RETURN NUMBER
                               
IS

cursor c_tablecompare is
select p_table_1 as table_name, column_name from cols
where table_name = p_table_1
minus 
select p_table_1 as table_name, column_name from cols
where table_name = p_table_2
union all
select p_table_2 as table_name, column_name from cols
where table_name = p_table_2
minus 
select p_table_2 as table_name, column_name from cols
where table_name = p_table_1;

ln_result number := 0;

BEGIN

  FOR curColumn in c_tablecompare LOOP
  
    IF instr(p_ignore_columns, curColumn.column_name ) = 0 THEN
  
       Raise_Application_Error(-20100,'Column Mismatch for '|| curColumn.table_name||'.'||curColumn.column_name);
       
    END IF;   

  END LOOP;

  return ln_result;
  	
	
END;	                         

PROCEDURE drop_dependent_constraints (p_table_name varchar2) IS

CURSOR c_ref_constraint IS
SELECT 'ALTER TABLE ' || b.table_name || ' DROP CONSTRAINT ' || b.constraint_name exec_stmt
from all_constraints a, all_constraints b
 where a.owner = b.r_owner
   --and a.owner = p_owner
   and a.table_name = p_table_name
   and a.constraint_type in ('P', 'U')
   and b.constraint_type = 'R'
   and b.R_CONSTRAINT_NAME = a.constraint_name;

lv2_table_spec VARCHAR2(2000);

BEGIN

   FOR cur_rec IN c_ref_constraint LOOP

      EXECUTE IMMEDIATE cur_rec.exec_stmt;

   END LOOP;
END drop_dependent_constraints;

END;	
/

