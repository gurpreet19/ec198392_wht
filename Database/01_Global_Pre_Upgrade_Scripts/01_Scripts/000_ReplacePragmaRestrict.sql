declare

  cursor c_candidates is 
    select distinct us.name, us.type
    from   user_source us
    where  regexp_like(us.text, '^\s{0,}PRAGMA RESTRICT', 'i')
    and    not exists ( select 'X'
                        from   user_objects uo
                        where  'EC_'||uo.object_name = us.name
                        and    uo.object_type = 'TABLE'
                      )
    order by name, type;

  PROCEDURE AddSqlLine(p_lines   IN OUT DBMS_SQL.varchar2a, p_newline IN VARCHAR2, p_nowrap VARCHAR2 DEFAULT 'N' ) IS
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
  END AddSqlLine;  

  PROCEDURE SafeBuild( p_object_name VARCHAR2
                     , p_object_type VARCHAR2
					 , p_lines DBMS_SQL.varchar2a
					 , p_target VARCHAR2 DEFAULT 'CREATE'
					 , p_id VARCHAR2 DEFAULT 'GENCODE'
					 , p_raise_error VARCHAR2 DEFAULT 'N'
					 , p_lfflg VARCHAR2 DEFAULT 'N' 
					 ) 
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
      c := dbms_sql.open_cursor;
      IF p_lfflg = 'Y' THEN
         dbms_sql.parse(c,p_lines,p_lines.first,p_lines.last,TRUE,DBMS_SQL.NATIVE);
      ELSE
         dbms_sql.parse(c,p_lines,p_lines.first,p_lines.last,FALSE,DBMS_SQL.NATIVE);
      END IF;
  
      result := dbms_sql.execute(c);
      dbms_sql.close_cursor(c);
  EXCEPTION
  	WHEN OTHERS THEN
      IF  Dbms_sql.is_open(c) THEN
        Dbms_Sql.Close_Cursor(c);
      END IF;
      Raise_Application_Error(-20000,'Syntax error generating '||p_object_type ||' for '||p_object_name||CHR(10)||SQLERRM  );
  END SafeBuild;
    
  procedure replace_occurence (p_name varchar2, p_type varchar2) is
    cursor c_sources (cp_name varchar2, cp_type varchar2) is
      select name
      ,      type
      ,      line
      ,      regexp_replace(text,chr(10)||'$', '', 1, 0, 'i') as old_line
      ,      regexp_replace(regexp_replace(text,chr(10)||'$', '', 1, 0, 'i'), '^(\s{0,}PRAGMA RESTRICT)', '--\1', 1, 0, 'i') as new_line
      from   user_source
      where  name = cp_name
      and    type = cp_type
      order by line;

    src_lines             DBMS_SQL.varchar2a;
  begin
    AddSqlLine(src_lines, 'CREATE OR REPLACE ');
    for c_source in c_sources (p_name, p_type) loop
      begin
        if c_source.old_line <> c_source.new_line then
           dbms_output.put_line('Replaced line: '||c_source.old_line);
           dbms_output.put_line('Replaced with: '||c_source.new_line);
           dbms_output.put_line('');
        end if;
        AddSqlLine(src_lines, c_source.new_line || chr(10));
      end;
    end loop;
    SafeBuild (p_name, p_type, src_lines);
  end replace_occurence;

begin
  for c_candidate in c_candidates loop
    begin
      dbms_output.put_line('Found occurence in '||c_candidate.type||' '||c_candidate.name);
      dbms_output.put_line('-----------------------------------------------------------------');
      replace_occurence(c_candidate.name, c_candidate.type);
      dbms_output.put_line('-----------------------------------------------------------------');
    end;
  end loop;
end;
/ 
