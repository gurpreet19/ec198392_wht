CREATE OR REPLACE PACKAGE BODY EcDp_PInC IS
  /**************************************************************
  ** Package:    EcDp_PInC
  **
  ** $Revision: 1.21 $
  **
  ** Filename:   EcDp_PInC_body.sql
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
  ** Created:     10.01.05  Christer Grimsæth, EC FRMW
  **
  **
  ** Modification history:
  **
  **
  ** Date:      Whom:    Change description:
  ** --------   -----    --------------------------------------------
  ** 10.01.05   CGR      Created.
  ** 15.03.05   CGR      Added support for computation of MD5 sum on objects larger than 32767 bytes.
  ** 26.04.05   MOT      Added PROCEDURE generateReport
  ** 28.04.05   MOT      generateReport updated
  ** 18.04.05   CGR      Added support for TABLE CONTENT.
  ** 25.05.05   CGR      Computation of MD5 in logTableContent() must return 'N/A' for DELETE statements.
  ** 09.05.05   MOT      Updated getLiveTag to also accept TABLE CONTENT
  **************************************************************/

  /* ***************** */
  /* Package Variables */
  /* ***************** */
  s_installModeTag VARCHAR2(100) := NULL;
  s_noTag  CONSTANT VARCHAR2(13) := 'NOT_A_RELEASE';
  s_md5NA  CONSTANT VARCHAR2(3)  := 'N/A';


  /* ***************** */
  /* Cursors           */
  /* ***************** */
  CURSOR c_missingObjects(p_typeFilter VARCHAR2, p_nameFilter VARCHAR2) IS
    SELECT DISTINCT us.TYPE TYPE, us.NAME NAME
      FROM user_source us
     WHERE NOT EXISTS (SELECT 'x'
              FROM ctrl_pinc cp
             WHERE cp.TYPE = us.TYPE
               AND cp.NAME = us.NAME)
       AND us.TYPE LIKE p_typeFilter
       AND us.TYPE LIKE p_nameFilter
    UNION ALL
    SELECT DISTINCT 'TABLE' TYPE, ut.table_name NAME
      FROM user_tables ut
     WHERE NOT EXISTS (SELECT 'x'
              FROM ctrl_pinc cp
             WHERE cp.TYPE = 'TABLE'
               AND cp.NAME = ut.table_name)
       AND 'TABLE' LIKE p_typeFilter
       AND ut.table_name LIKE p_nameFilter
     ORDER BY type, name;

  CURSOR c_currentObjects(p_daytime TIMESTAMP, p_typeFilter VARCHAR2, p_nameFilter VARCHAR2) IS
   SELECT *
      FROM CTRL_PINC c1
     WHERE c1.daytime = (SELECT MAX(daytime)
                           FROM CTRL_PINC c2
                          WHERE c2.TYPE = c1.TYPE
                            AND c2.NAME = c1.NAME
                            AND c2.daytime <= nvl(p_daytime, SYSTIMESTAMP)
                            AND nvl(c2.table_pk, 'XX') = nvl(c1.table_pk, 'XX'))
       AND c1.TYPE LIKE p_typeFilter
       AND c1.NAME LIKE p_nameFilter
     ORDER BY c1.type,c1.name,c1.daytime;

  CURSOR c_latestObject(p_type VARCHAR2, p_name VARCHAR2, p_table_pk VARCHAR2 DEFAULT NULL) IS
    SELECT *
      FROM (SELECT *
              FROM CTRL_PINC c1
             WHERE c1.TYPE = p_type
               AND c1.NAME = p_name
               AND nvl(c1.table_pk, 'XX') = nvl(p_table_pk, 'XX')
             ORDER BY daytime DESC)
     WHERE rownum = 1;



   CURSOR c_latestDaytime(p_type VARCHAR2, p_name VARCHAR2, p_table_pk VARCHAR2 DEFAULT NULL) IS
   SELECT MAX(daytime) latestDaytime
     FROM CTRL_PINC c1
    WHERE c1.TYPE = p_type
      AND c1.NAME = p_name
      AND nvl(c1.table_pk, 'XX') = nvl(p_table_pk, 'XX');


  CURSOR c_userObjects(p_typeFilter VARCHAR2, p_nameFilter VARCHAR2,  p_userFilter VARCHAR2) IS
    SELECT *
      FROM CTRL_PINC c1
     WHERE  c1.type LIKE p_typeFilter
       AND  c1.name LIKE p_nameFilter
       AND (upper(c1.username) LIKE upper(p_userFilter) OR upper(c1.osuser) LIKE upper(p_userFilter))
     ORDER BY c1.daytime;


  CURSOR c_tagObjects(p_tag VARCHAR2) IS
    SELECT * FROM CTRL_PINC c1 WHERE c1.tag = p_tag ORDER BY type, name, daytime;

  CURSOR c_historyObjects(p_type VARCHAR2, p_name VARCHAR2, p_daytime TIMESTAMP, p_table_pk VARCHAR2 DEFAULT NULL) IS
    SELECT *
      FROM CTRL_PINC c1
     WHERE c1.TYPE = p_type
       AND c1.NAME = p_name
       AND c1.daytime > p_daytime
       AND nvl(c1.table_pk,'XX') = nvl(p_table_pk, 'XX')
     ORDER BY c1.daytime;

  CURSOR c_customObjects(p_typeFilter VARCHAR2, p_nameFilter VARCHAR2) IS
    SELECT *
      FROM CTRL_PINC c1
     WHERE c1.daytime = (SELECT MAX(daytime)
                           FROM CTRL_PINC c2
                          WHERE c2.TYPE = c1.TYPE
                            AND c2.NAME = c1.NAME
                            AND nvl(c2.table_pk,'XX') = nvl(c1.table_pk,'XX')
                            AND c2.tag IS NULL)
       AND c1.TYPE LIKE p_typeFilter
       AND c1.NAME LIKE p_nameFilter
       ORDER BY c1.type, c1.name, c1.daytime;

  /* ***************** */
  /* Methods           */
  /* ***************** */
  PROCEDURE enableInstallMode(p_tag VARCHAR2) IS
  BEGIN
    s_installModeTag := p_tag;
  END;

  FUNCTION enableInstallModeSqlLdr(p_tag VARCHAR2)
  RETURN VARCHAR2
  IS
  BEGIN
    enableInstallMode(p_tag);
    RETURN NULL;
  END enableInstallModeSqlLdr;

  PROCEDURE disableInstallMode IS
  BEGIN
    s_installModeTag := NULL;
  END;

  FUNCTION isInstallMode RETURN BOOLEAN IS
  BEGIN
    RETURN(s_installModeTag IS NOT NULL);
  END;

  FUNCTION getInstallModeTag RETURN VARCHAR2 IS
  BEGIN
    RETURN s_installModeTag;
  END;

  PROCEDURE getLiveUserSrc(p_source IN OUT BLOB, p_type VARCHAR2, p_name IN VARCHAR2) IS
    l_raw RAW(32766);
    CURSOR c_pckSrc(p_objectType VARCHAR2, p_objectName VARCHAR2) IS
      SELECT text
        FROM user_source
       WHERE NAME = p_objectName
         AND TYPE = p_objectType
       ORDER BY TYPE ASC, line ASC;

  BEGIN
    FOR curSource IN c_pckSrc(p_type, p_name) LOOP
      IF c_pckSrc%ROWCOUNT = 1 THEN
        l_raw := utl_raw.cast_to_raw('CREATE OR REPLACE ');
        dbms_lob.writeappend(p_source, utl_raw.length(l_raw), l_raw);
      END IF;

      l_raw := utl_raw.cast_to_raw(curSource.Text);
      dbms_lob.writeappend(p_source, utl_raw.length(l_raw), l_raw);
    END LOOP;

    if dbms_lob.getlength(p_source) > 1 THEN
       l_raw := utl_raw.cast_to_raw(chr(0));
       dbms_lob.writeappend(p_source, utl_raw.length(l_raw), l_raw);
    END IF;
  END;

  PROCEDURE getLiveViewSrc(p_source IN OUT BLOB, p_name VARCHAR2) IS
    l_raw RAW(32767);

    CURSOR c_viewSrc(p_objectName VARCHAR2) IS
      SELECT text FROM user_views WHERE view_name = p_objectName;
  BEGIN
    -- NOTYET: This will break if text column is lager than 32K....
    FOR curSource IN c_viewSrc(p_name) LOOP
      /*  Do not add the 'CREATE OR REPLACE VIEW' part, because we don't know how to get the prototype.
      l_raw := utl_raw.cast_to_raw('CREATE OR REPLACE VIEW ' || upper(p_name) || ' AS' || chr(10));
      dbms_lob.writeappend(p_source, utl_raw.length(l_raw), l_raw);
      */

      l_raw := utl_raw.cast_to_raw(curSource.Text);
      dbms_lob.writeappend(p_source, utl_raw.length(l_raw), l_raw);

      l_raw := utl_raw.cast_to_raw(chr(0));
      dbms_lob.writeappend(p_source, utl_raw.length(l_raw), l_raw);

      exit; -- We're only interresed in the first row..
    END LOOP;
  END;


  PROCEDURE getLiveTableSrc(p_source IN OUT BLOB, p_name VARCHAR2, p_alterStmt VARCHAR2 DEFAULT NULL) IS
    l_alterStmt VARCHAR2(2000) := upper(rtrim(p_alterStmt));
    l_padding   VARCHAR2(10) := '';
    l_ln        VARCHAR2(2) := chr(13) || chr(10);
    l_dataType  VARCHAR2(240) := '';
    l_nullable  VARCHAR2(240) := '';
    l_preTxt    RAW(240) := utl_raw.cast_to_raw('CREATE TABLE ' || p_name || ' (');
    l_postTxt   RAW(240) := utl_raw.cast_to_raw(l_ln || ')');
    l_raw       RAW(32767);
    l_isDropCol BOOLEAN := FALSE;
    l_isAddCol  BOOLEAN := FALSE;

    CURSOR c_tabSrc(p_objectName VARCHAR2) IS
      SELECT column_name, data_type, data_length, DATA_PRECISION, DATA_SCALE, nullable
        FROM user_tab_cols
       WHERE table_name = p_objectName
       ORDER BY COLUMN_ID;
  BEGIN


    FOR curSource IN c_tabSrc(p_name) LOOP
      IF c_tabSrc%ROWCOUNT = 1 THEN
        dbms_lob.writeappend(p_source, utl_raw.length(l_preTxt), l_preTxt);
      END IF;

      l_isDropCol := (l_alterStmt IS NOT NULL) AND
                     (instr(l_alterStmt, 'ALTER TABLE ' || p_name || ' DROP COLUMN ' || curSource.Column_Name) > 0);
      IF NOT l_isDropCol THEN
        IF c_tabSrc%ROWCOUNT > 1 THEN
          l_padding := ',' || l_ln;
        ELSE
          l_padding := l_ln;
        END IF;
        IF curSource.Data_Type = 'VARCHAR2' THEN
          l_dataType := ' ' || curSource.Data_Type || '(' || curSource.Data_Length || ')';
        ELSIF curSource.Data_Type = 'NUMBER' THEN
          IF curSource.Data_Precision IS NULL AND curSource.Data_Scale IS NULL THEN
            l_dataType := ' ' || curSource.Data_Type;
          ELSIF curSource.Data_Precision IS NULL AND curSource.Data_Scale = 0 THEN
            l_dataType := ' INTEGER';
          ELSIF curSource.Data_Scale = 0 THEN
            l_dataType := ' ' || curSource.Data_Type || '(' || curSource.Data_Precision || ')';
          ELSE
            l_dataType := ' ' || curSource.Data_Type || '(' || curSource.Data_Precision || ',' || curSource.Data_Scale || ')';
          END IF;
        ELSE
          l_dataType := ' ' || curSource.Data_Type;
        END IF;
        l_nullable := '';
        IF curSource.Nullable = 'N' THEN
          l_nullable := ' NOT NULL';
        END IF;
      END IF;

      l_raw := utl_raw.cast_to_raw(l_padding || nvl(curSource.Column_Name, '') || l_dataType || l_nullable);
      dbms_lob.writeappend(p_source, utl_raw.length(l_raw), l_raw);

    END LOOP;

    -- If an alter-stmt is included, add it to the source.
    l_isAddCol := (l_alterStmt IS NOT NULL) AND (instr(l_alterStmt, 'ALTER TABLE ' || p_name || ' ADD ') > 0) AND (instr(l_alterStmt, 'CONSTRAINT')=0);
    IF l_isAddCol THEN
      l_alterStmt := REPLACE(l_alterStmt, chr(10));
      l_alterStmt := REPLACE(l_alterStmt, chr(0));
      l_alterStmt := rtrim(',' || l_ln || REPLACE(l_alterStmt, 'ALTER TABLE ' || p_name || ' ADD '));
      IF (instr(l_alterStmt, 'NOT NULL',-1) = 0) AND (instr(l_alterStmt, 'NULL',-1) > length(l_alterStmt) - length('NULL')) THEN
         l_alterStmt := replace(l_alterStmt, ' NULL');
      END IF;
      l_raw       := utl_raw.cast_to_raw(l_alterStmt);
      --dbms_output.put_line('alter: ' || l_tmp);

      dbms_lob.writeappend(p_source, utl_raw.length(l_raw), l_raw);
    END IF;
    IF dbms_lob.getlength(p_source) > 1 THEN
       dbms_lob.writeappend(p_source, utl_raw.length(l_postTxt), l_postTxt);
    END IF;
  END;

  PROCEDURE getLiveTableContentSrc(p_source IN OUT BLOB, p_name VARCHAR2, p_key VARCHAR2) IS
     l_raw      RAW(32767);
     l_sql      VARCHAR2(32767);
     l_cursor   INTEGER;
     l_ret      INTEGER;
     no_of_cols INTEGER;
     l_columns  dbms_sql.desc_tab;

     l_varchar2 VARCHAR2(32767);
     l_number   NUMBER;
     l_date     DATE;
     l_char     CHAR(32767);

  BEGIN
     IF p_name IS NULL OR p_key IS NULL THEN
        -- One of the args is null, so there is no way to generate a valid SQL stmt.
        return;
     END IF;

     BEGIN
        l_sql    := 'SELECT * FROM ' || p_name || ' WHERE ' || p_key;
        l_cursor := dbms_sql.open_cursor;
        dbms_sql.parse(l_cursor, l_sql, dbms_sql.native);
        dbms_sql.describe_columns(l_cursor, no_of_cols, l_columns);

        FOR i IN 1 .. no_of_cols LOOP

           IF l_columns(i).col_type = 1 THEN
              dbms_sql.define_column(l_cursor, i, l_varchar2, l_columns(i).col_max_len);
           ELSIF l_columns(i).col_type = 2 THEN
              dbms_sql.define_column(l_cursor, i, l_number);
           ELSIF l_columns(i).col_type = 12 THEN
              dbms_sql.define_column(l_cursor, i, l_date);
           ELSIF l_columns(i).col_type = 96 THEN
              dbms_sql.define_column_char(l_cursor, i, l_char, l_columns(i).col_max_len);
           ELSIF l_columns(i).col_type = 8 THEN
              NULL; -- Ignore LONG
           ELSIF l_columns(i).col_type = 23 THEN
              NULL; -- Ignore RAW
           ELSIF l_columns(i).col_type = 24 THEN
              NULL; -- Ignore LONG RAW
           ELSIF l_columns(i).col_type = 112 THEN
              NULL; -- Ignore CLOB
           ELSIF l_columns(i).col_type = 113 THEN
              NULL; -- Ignore BLOB
           ELSE
              NULL; -- Ignore all other datatypes
           END IF;
        END LOOP;

        l_ret := dbms_sql.EXECUTE(l_cursor);

        IF DBMS_SQL.FETCH_ROWS(l_cursor) >= 1 THEN
           -- Only interrested in the first row!
           FOR i IN 1 .. no_of_cols LOOP
              IF NOT l_columns(i).col_name IN ('RECORD_STATUS', 'CREATED_BY', 'CREATED_DATE', 'LAST_UPDATED_BY',
                  'LAST_UPDATED_DATE', 'REV_NO', 'REV_TEXT','REC_ID') THEN
                 IF l_columns(i).col_type = 1 THEN
                    dbms_sql.column_value(l_cursor, i, l_varchar2);
                    l_raw := utl_raw.cast_to_raw(l_columns(i).col_name || '=' || REPLACE(l_varchar2, chr(39), chr(39) || chr(39)) || ';');
                 ELSIF l_columns(i).col_type = 2 THEN
                    dbms_sql.column_value(l_cursor, i, l_number);
                    l_raw := utl_raw.cast_to_raw(l_columns(i).col_name || '=' || nvl(TO_CHAR(l_number,'9999999999999999D9999999999','NLS_NUMERIC_CHARACTERS=''.,'''),'') || ';');
                 ELSIF l_columns(i).col_type = 12 THEN
                    dbms_sql.column_value(l_cursor, i, l_date);
                    l_raw := utl_raw.cast_to_raw(l_columns(i).col_name || '=' || nvl(to_char(l_date, 'yyyy.mm.dd hh24:mi:ss'), '') || ';');
                 ELSIF l_columns(i).col_type = 96 THEN
                    dbms_sql.column_value_char(l_cursor, i, l_char);
                    l_raw := utl_raw.cast_to_raw(l_columns(i).col_name || '=' || nvl(l_char, '') || ';');
                 ELSIF l_columns(i).col_type = 8 THEN
                    NULL; -- Ignore LONG
                 ELSIF l_columns(i).col_type = 23 THEN
                    NULL; -- Ignore RAW
                 ELSIF l_columns(i).col_type = 24 THEN
                    NULL; -- Ignore LONG RAW
                 ELSIF l_columns(i).col_type = 112 THEN
                    NULL; -- Ignore CLOB
                 ELSIF l_columns(i).col_type = 113 THEN
                    NULL; -- Ignore BLOB
                 ELSE
                    NULL; -- Ignore all other datatypes
                 END IF;

                 dbms_lob.writeappend(p_source, utl_raw.length(l_raw), l_raw);
              END IF;
           END LOOP;
        END IF;

        dbms_sql.close_cursor(l_cursor);
     EXCEPTION
        WHEN OTHERS THEN
           -- Something went wrong, probably l_sql is not a valid sql stmt.
           return;
     END;
  END;


  PROCEDURE getLiveIndexSrc(p_source IN OUT BLOB, p_name VARCHAR2) IS
     l_padding VARCHAR2(10) := '';
     l_ln      VARCHAR2(2)  := chr(13) || chr(10);
     l_postTxt RAW(240)     := utl_raw.cast_to_raw(l_ln || ')');
     l_raw     RAW(32767);

     CURSOR c_indSrc(p_objectName VARCHAR2) IS
        SELECT * FROM user_ind_columns
        WHERE index_name = p_objectName
        ORDER BY COLUMN_POSITION;
  BEGIN

     FOR curSource IN c_indSrc(p_name) LOOP
        IF c_indSrc%ROWCOUNT = 1 THEN
           l_raw := utl_raw.cast_to_raw('CREATE INDEX ' || p_name || ' ON ' || curSource.Table_Name || '(');
           dbms_lob.writeappend(p_source, utl_raw.length(l_raw), l_raw);
        END IF;

        IF c_indSrc%ROWCOUNT > 1 THEN
           l_padding := ',' || l_ln;
        ELSE
           l_padding := l_ln;
        END IF;

        l_raw := utl_raw.cast_to_raw(l_padding || curSource.Column_Name);
        dbms_lob.writeappend(p_source, utl_raw.length(l_raw), l_raw);

     END LOOP;

     IF dbms_lob.getlength(p_source) > 1 THEN
        dbms_lob.writeappend(p_source, utl_raw.length(l_postTxt), l_postTxt);
     END IF;
  END;

  /*
    PROCEDURE getLiveSrcXml(p_source in out blob, p_type varchar2, p_name varchar2) is
    BEGIN
      dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'PRETTY', true);
      dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'SQLTERMINATOR', TRUE );

      dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'SEGMENT_ATTRIBUTES', false);
      dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'STORAGE', false);
      dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'TABLESPACE', false);

      dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'CONSTRAINTS', false);
      dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'REF_CONSTRAINTS', false);
      dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'CONSTRAINTS_AS_ALTER', false);

      p_source := dbms_metadata.get_xml(p_type, p_name);

      dbms_metadata.set_transform_param(dbms_metadata.SESSION_TRANSFORM, 'DEFAULT');

    END;

  */

  PROCEDURE getLiveSrc(p_source IN OUT BLOB, p_type VARCHAR2, p_name VARCHAR2, p_key VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_type IN ('TYPE', 'TYPE BODY', 'PROCEDURE', 'FUNCTION', 'PACKAGE', 'PACKAGE BODY', 'JAVA SOURCE', 'TRIGGER') THEN
      getLiveUserSrc(p_source, p_type, p_name);
    ELSIF p_type = 'TABLE CONTENT' THEN
      ecdp_pinc.getLiveTableContentSrc(p_source, p_name, p_key);
    ELSIF p_type = 'VIEW' THEN
      ecdp_pinc.getLiveViewSrc(p_source, p_name);
    ELSIF p_type = 'TABLE' THEN
      ecdp_pinc.getLiveTableSrc(p_source, p_name);
    ELSIF p_type = 'INDEX' THEN
      ecdp_pinc.getLiveIndexSrc(p_source, p_name);
    END IF;
  END;

  FUNCTION getLiveSrc(p_type VARCHAR2, p_name VARCHAR2, p_key VARCHAR2 DEFAULT NULL) RETURN BLOB IS
    l_tmp BLOB := NULL;
  BEGIN
    dbms_lob.createtemporary(l_tmp, TRUE, dbms_lob.CALL);
    getLiveSrc(l_tmp, p_type, p_name, p_key);

    IF dbms_lob.getlength(l_tmp) <= 0 THEN
      dbms_lob.freetemporary(l_tmp);
      RETURN NULL;
    ELSE
      -- NOTYET: let's hope Oracle does clean up the l_tmp blob....!
      --dbms_lob.freetemporary(l_tmp);
      RETURN l_tmp;
    END IF;
  END;

  FUNCTION getLiveTag(p_type VARCHAR2, p_name VARCHAR2, p_key VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
    tag VARCHAR2(100) := NULL;
    md5 VARCHAR2(32) := NULL;

    CURSOR c_pincTag(p_type VARCHAR2, p_name VARCHAR2, p_md5 VARCHAR2) IS
      SELECT tag
        FROM (SELECT tag
                FROM ctrl_pinc
               WHERE TYPE = p_type
                 AND NAME = p_name
                 AND md5sum = p_md5
               ORDER BY daytime DESC)
       WHERE rownum = 1;

  BEGIN
    /*
    1.Invoke getLiveMD5
    2.Find all objects with the given MD5 in the PInC table. (should not be that many... )
    3.Return the tag of the newest one.
    */
    md5 := getLiveMd5(p_type, p_name, p_key);
    FOR c_Tag IN c_pincTag(p_type, p_name, md5) LOOP
      tag := c_tag.tag;
    END LOOP;

    RETURN tag;
  END;

  PROCEDURE getSrcByTag(p_source IN OUT BLOB, p_type VARCHAR2, p_name VARCHAR2, p_tag VARCHAR2) IS

    CURSOR c_pincSrc(p_type VARCHAR2, p_name VARCHAR2, p_tag VARCHAR2) IS
      SELECT OBJECT
        FROM (SELECT OBJECT
                FROM ctrl_pinc
               WHERE TYPE = p_type
                 AND NAME = p_name
                 AND tag = tag
               ORDER BY daytime DESC)
       WHERE rownum = 1;

  BEGIN
    FOR c_src IN c_pincSrc(p_type, p_name, p_tag) LOOP
      p_source := c_src.OBJECT;
    END LOOP;

  END;

  FUNCTION computeMD5(p_object BLOB) RETURN VARCHAR2 IS
    l_chunkSize   INTEGER := 32767; -- Max size of RAW variable.
    l_chunkOffset INTEGER := 0;
    l_chunkCount  INTEGER := 0;
    l_chunkNext   RAW(32767) := NULL;
    l_md5List     VARCHAR2(32767) := NULL;
    l_md5         VARCHAR2(32) := NULL;
  BEGIN
    IF p_object IS NULL THEN
      RETURN NULL;
    END IF;

    l_chunkNext := dbms_lob.substr(p_object, l_chunkSize);
    WHILE utl_raw.length(l_chunkNext) > 0 LOOP
      IF l_chunkCount = 0 THEN
        l_md5List := 'MD5 of object with size: [' || dbms_lob.getlength(p_object) ||
                     ']Bytes and chunk size:[' || l_chunkSize || ']Bytes:';
      END IF;

      l_md5     := rawtohex(dbms_obfuscation_toolkit.md5(input => l_chunkNext));
      l_md5List := l_md5List || ';' || l_md5;

      /*
            dbms_output.new_line();
            dbms_output.put_line('l_chunkNext    :[' || utl_raw.cast_to_varchar2(l_chunkNext) || ']');
            dbms_output.put_line('l_md5          :' || l_md5);
            dbms_output.put_line('l_chunkCount   :' || l_chunkCount);
            dbms_output.put_line('l_chunkOffset  :' || l_chunkOffset);
      */

      l_chunkCount  := l_chunkCount + 1;
      l_chunkOffset := (l_chunkCount * l_chunkSize) + 1;
      l_chunkNext   := dbms_lob.substr(p_object, l_chunkSize, l_chunkOffset);
    END LOOP;

    IF l_chunkCount > 1 THEN
      l_md5 := rawtohex(dbms_obfuscation_toolkit.md5(input => utl_raw.cast_to_raw(l_md5List)));
    END IF;

    --dbms_output.put_line('ZZZ:' || l_md5);

    IF l_md5 IS NULL THEN
       l_md5 := s_md5NA;
    END IF;
    RETURN l_md5;
  END;

  FUNCTION getLiveMD5(p_type VARCHAR2, p_name VARCHAR2, p_key VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
    l_tmp  BLOB := NULL;
    md5sum VARCHAR2(32) := NULL;
  BEGIN
    dbms_lob.createtemporary(l_tmp, TRUE, dbms_lob.CALL);

    getLiveSrc(l_tmp, p_type, p_name, p_key );
    md5sum := computeMD5(l_tmp);

    dbms_lob.freetemporary(l_tmp);
    RETURN md5sum;
  END;

  FUNCTION getMD5ByTag(p_type VARCHAR2, p_name VARCHAR2, p_tag VARCHAR2) RETURN VARCHAR2 IS
    md5 VARCHAR2(32) := NULL;

    CURSOR c_pincMD5(p_type VARCHAR2, p_name VARCHAR2, p_tag VARCHAR2) IS
      SELECT md5sum
        FROM (SELECT md5sum
                FROM ctrl_pinc
               WHERE TYPE = p_type
                 AND NAME = p_name
                 AND tag = p_tag
               ORDER BY daytime DESC)
       WHERE rownum = 1;

  BEGIN
    /*
    1.Find all objects with the given Tag in the PInC table. (should not be that many, hopfully only one... )
    2.Return the tag of the newest one.
    */
    FOR c_md5 IN c_pincMd5(p_type, p_name, p_tag) LOOP
      md5 := c_md5.md5sum;
    END LOOP;

    RETURN md5;
  END;

  FUNCTION getMD5ByDaytime(p_type VARCHAR2, p_name VARCHAR2, p_daytime TIMESTAMP) RETURN VARCHAR2 IS
    md5 VARCHAR2(32) := s_md5NA;

    CURSOR c_pincMD5(p_type VARCHAR2, p_name VARCHAR2, p_daytime TIMESTAMP) IS
      SELECT md5sum
        FROM (SELECT md5sum
                FROM ctrl_pinc
               WHERE TYPE = p_type
                 AND NAME = p_name
                 AND DAYTIME <= p_daytime
               ORDER BY daytime DESC)
       WHERE rownum = 1;

  BEGIN
    /*
    1.Find all objects with daytime <= p_daytime in the PInC table.
    2.Return the tag of the newest one.
    */
    FOR c_md5 IN c_pincMd5(p_type, p_name, p_daytime) LOOP
      md5 := c_md5.md5sum;
    END LOOP;

    RETURN md5;
  END;


  /*
  PROCEDURE getObjectStatus(p_daytime DATE) IS
   BEGIN
     getObjectStatus('%', '%');
  END;


  PROCEDURE getObjectStatus(p_typeFilter VARCHAR2, p_nameFilter VARCHAR2, p_daytime DATE) IS
   BEGIN

   FOR c_allObj IN c_allObjects(p_typeFilter, p_nameFilter) LOOP

      if getLiveMD5(c_allObj.Type, c_allObj.Name) = getMD5ByDaytime(c_allObj.Type, c_allObj.Name, p_daytime) THEN

      else
          -- Ooooppss! The live version is not recorded in PInC! Has the trigger been turned off?

      END IF;


    END LOOP;

  END;
    */



  PROCEDURE writeRepMisObj(p_report IN OUT CLOB, p_typeFilter VARCHAR2, p_nameFilter VARCHAR2) IS
    l_tmp VARCHAR2(4000);
  BEGIN
    FOR c_cur IN c_missingObjects(p_typeFilter, p_nameFilter) LOOP
      l_tmp := c_cur.TYPE || ' - ' || c_cur.NAME || ' - ' ||
               '  --> ERROR: Unable to find any info on this object. Has PInC been disabled?' || chr(13) || chr(10);
      dbms_lob.writeappend(p_report, length(l_tmp), l_tmp);
    END LOOP;
  END;

  PROCEDURE writeRepObj(p_report IN OUT CLOB, p_daytime TIMESTAMP, p_typeFilter VARCHAR2, p_nameFilter VARCHAR2) IS
    l_tmp     VARCHAR2(32000);
    l_liveMd5 VARCHAR2(32);
    l_count   INTEGER := 0;
    l_typeFilter VARCHAR2(2000) := p_typeFilter;
    l_nameFilter VARCHAR2(2000) := p_nameFilter;
    l_isLatest boolean := FALSE;
    l_pk VARCHAR2(4000);
  BEGIN

    IF p_typeFilter IS NULL OR length(p_typeFilter) = 0 THEN
       l_typeFilter := '%';
    END IF;
    IF p_nameFilter IS NULL OR length(p_nameFilter) = 0 THEN
       l_nameFilter := '%';
    END IF;

    FOR c_cur IN c_currentObjects(p_daytime, l_typeFilter, l_nameFilter) LOOP
      -- Log info from CTRL_PINC
      l_count := l_count + 1;
      IF c_cur.type <> 'TABLE CONTENT' THEN
        l_pk := '';
      ELSE
        l_pk := ' - [' || c_cur.table_pk || ']';
      END IF;
      l_tmp   := c_cur.TYPE || ' - ' ||
                 c_cur.NAME || ' - ' ||
                 nvl(c_cur.tag, s_noTag) || ' - [' ||
                 c_cur.md5sum || ']' ||
                 l_pk ||
                 ' : Operation ' || c_cur.operation || ' executed by user ' || c_cur.osuser || '(' || c_cur.username ||
                 ') from ' || c_cur.machine || ' on ' || to_char(c_cur.daytime, 'yyyy.mm.dd hh24:mi:ss') || '.' ||
                 chr(13) || chr(10);

      -- If this is the LATEST object in CTRL_PINC then compare against the live object
      FOR c_latest IN c_latestDaytime(c_cur.type, c_cur.name, c_cur.table_pk) LOOP
         IF c_latest.latestdaytime = c_cur.daytime THEN
           l_isLatest := TRUE;
         END IF;
         EXIT; -- Only interrested in the one row...
      END LOOP;

      IF l_isLatest THEN
        -- Check that LiveMD5 is equal to current in CTRL_PInC
        l_liveMd5 := getLiveMD5(c_cur.TYPE, c_cur.NAME, c_cur.table_pk);
        IF nvl(l_liveMd5, s_md5NA) <> c_cur.md5sum THEN
          IF c_cur.type <> 'TABLE CONTENT' THEN
            l_tmp := l_tmp || '  --> ERROR: Live Object has MD5 [' || l_liveMd5 || '] which differ from PInC. Has PInC been disabled?' || chr(13) || chr(10);
          ELSE
            l_tmp := c_cur.TYPE || ' - ' ||
                     c_cur.NAME || ' - ' ||
                     s_noTag || ' - [' ||
                     l_liveMd5 || ']' ||
                     l_pk ||
                     ' : Row has been updated/deleted after release [' || c_cur.tag ||'].' || chr(13) || chr(10);
          END IF;
        END IF;
      END IF;
      l_tmp := REPLACE(l_tmp, chr(0)); -- Need to remove the Zero character, otherwise it will be used as a EOF marker.

      dbms_lob.writeappend(p_report, length(l_tmp), l_tmp);
    END LOOP;
    l_tmp := 'Total ' || l_count || ' objects.' || chr(13) || chr(10);
    dbms_lob.writeappend(p_report, length(l_tmp), l_tmp);

  END;

  PROCEDURE writeRepUser(p_report IN OUT CLOB, p_typeFilter VARCHAR2, p_nameFilter VARCHAR2, p_userFilter VARCHAR2) IS
    l_tmp     VARCHAR2(32000);
    l_count   INTEGER := 0;
    l_userFilter VARCHAR2(2000) := p_userFilter;
    l_typeFilter VARCHAR2(2000) := p_typeFilter;
    l_nameFilter VARCHAR2(2000) := p_nameFilter;
  BEGIN
    IF p_typeFilter IS NULL OR length(p_typeFilter) = 0 THEN
       l_typeFilter := '%';
    END IF;
    IF p_nameFilter IS NULL OR length(p_nameFilter) = 0 THEN
       l_nameFilter := '%';
    END IF;
    IF p_userFilter IS NULL OR length(p_userFilter) = 0 THEN
       l_userFilter := '%';
    END IF;


    FOR c_cur IN c_userObjects(l_typeFilter, l_nameFilter, l_userFilter) LOOP
      -- Log info from CTRL_PINC
      l_count := l_count + 1;
      l_tmp   := c_cur.TYPE || ' - ' ||
                 c_cur.NAME || ' - ' ||
                 nvl(c_cur.tag, s_noTag) || ' - [' ||
                 c_cur.md5sum ||
                 '] : Operation ' || c_cur.operation || ' executed by user ' || c_cur.osuser || '(' || c_cur.username ||
                 ') from ' || c_cur.machine || ' on ' || to_char(c_cur.daytime, 'yyyy.mm.dd hh24:mi:ss') || '.' ||
                 chr(13) || chr(10);

      l_tmp := REPLACE(l_tmp, chr(0)); -- Need to remove the Zero character, otherwise it will be used as a EOF marker.
      dbms_lob.writeappend(p_report, length(l_tmp), l_tmp);
    END LOOP;
    l_tmp := 'Total ' || l_count || ' objects.' || chr(13) || chr(10);
    dbms_lob.writeappend(p_report, length(l_tmp), l_tmp);
  END;


  PROCEDURE writeRepTag(p_report IN OUT CLOB, p_tag VARCHAR2) IS
    l_tmp     VARCHAR2(32000);
    l_liveMd5 VARCHAR2(32);
    l_pk VARCHAR2(4000);
  BEGIN
    FOR c_cur IN c_tagObjects(p_tag) LOOP
      IF c_cur.type <> 'TABLE CONTENT' THEN
        l_pk := '';
      ELSE
        l_pk := ' - [' || c_cur.table_pk || ']';
      END IF;

      l_tmp := c_cur.TYPE || ' - ' ||
               c_cur.NAME || ' - ' ||
               nvl(c_cur.tag, s_noTag) || ' - [' ||
               c_cur.md5sum ||  ']' ||
               l_pk ||
               ': Operation ' || c_cur.operation || ' executed by user ' || c_cur.osuser || '(' || c_cur.username ||
               ') from ' || c_cur.machine || ' on ' || to_char(c_cur.daytime, 'yyyy.mm.dd hh24:mi:ss') || '.' ||
               chr(13) || chr(10);

      l_liveMd5 := getLiveMD5(c_cur.TYPE, c_cur.NAME, c_cur.table_pk);
      IF l_liveMd5 <> c_cur.md5sum THEN
        IF c_cur.type <> 'TABLE CONTENT' THEN
           l_tmp := l_tmp || '  --> This Object has been replaced by a newer version:' || chr(13) || chr(10);
           FOR c_curHist IN c_historyObjects(c_cur.TYPE, c_cur.NAME, c_cur.daytime, c_cur.table_pk) LOOP
             l_tmp := l_tmp || '  --> ' ||
                      nvl(c_curHist.tag, s_noTag) || ' - [' ||
                      c_curHist.md5sum || ']: Operation ' ||
                      c_curHist.operation || ' executed by user ' ||
                      c_curHist.osuser || '(' ||
                      c_curHist.username || ') from ' ||
                      c_curHist.machine || ' on ' || to_char(c_curHist.daytime, 'yyyy.mm.dd hh24:mi:ss') || '.' ||
                      chr(13) || chr(10);
           END LOOP;
        ELSE
            l_tmp := l_tmp || '  --> ' || ' : Row has been updated/deleted after release [' || c_cur.tag ||'].' || chr(13) || chr(10);
        END IF;
      END IF;

      l_tmp := REPLACE(l_tmp, chr(0)); -- Need to remove the Zero character, otherwise it will be used as a EOF marker.
      dbms_lob.writeappend(p_report, length(l_tmp), l_tmp);
    END LOOP;
  END;

  PROCEDURE writeRepCustom(p_report IN OUT CLOB, p_typeFilter VARCHAR2, p_nameFilter VARCHAR2) IS
    l_tmp     VARCHAR2(32000);
    l_liveMd5 VARCHAR2(32);
  BEGIN
    FOR c_cur IN c_customObjects(p_typeFilter, p_nameFilter) LOOP
      l_tmp := c_cur.TYPE || ' - ' ||
               c_cur.NAME || ' - ' ||
               nvl(c_cur.tag, s_noTag) || ' - [' ||
               c_cur.md5sum || ']: Operation ' ||
               c_cur.operation || ' executed by user ' ||
               c_cur.osuser || '(' ||
               c_cur.username || ') from ' || c_cur.machine || ' on ' || to_char(c_cur.daytime, 'yyyy.mm.dd hh24:mi:ss') || '.' ||
               chr(13) || chr(10);

      l_liveMd5 := getLiveMD5(c_cur.TYPE, c_cur.NAME, c_cur.table_pk);
      IF l_liveMd5 <> c_cur.md5sum THEN
        l_tmp := l_tmp || '  --> ERROR: Live Object has MD5 [' || l_liveMd5 ||
                 '] which differ from PInC. Has PInC been disabled?' || chr(13) || chr(10);
      END IF;

      l_tmp := REPLACE(l_tmp, chr(0)); -- Need to remove the Zero character, otherwise it will be used as a EOF marker.
      dbms_lob.writeappend(p_report, length(l_tmp), l_tmp);
    END LOOP;
  END;

  PROCEDURE writeRepStatus(p_report IN OUT CLOB) IS
    l_tableSize   NUMBER;
    l_objectCount NUMBER;
    l_totalCount  NUMBER;
    l_missCount NUMBER;

    l_tmp VARCHAR2(2000);
  BEGIN

    SELECT bytes / 1024 INTO l_tableSize FROM user_segments WHERE segment_name = 'CTRL_PINC';

    SELECT COUNT(*) INTO l_totalCount FROM ctrl_pinc;

    SELECT COUNT(*) INTO l_objectCount FROM (SELECT DISTINCT NAME FROM ctrl_pinc);

    SELECT COUNT(*)
      INTO l_missCount
      FROM (SELECT DISTINCT us.TYPE TYPE, us.NAME NAME
              FROM user_source us
             WHERE NOT EXISTS (SELECT 'x'
                      FROM ctrl_pinc cp
                     WHERE cp.TYPE = us.TYPE
                       AND cp.NAME = us.NAME)
            UNION ALL
            SELECT DISTINCT 'TABLE' TYPE, ut.table_name NAME
              FROM user_tables ut
             WHERE NOT EXISTS (SELECT 'x'
                      FROM ctrl_pinc cp
                     WHERE cp.TYPE = 'TABLE'
                       AND cp.NAME = ut.table_name));



    l_tmp := 'Energy Components PInC Status:' || chr(13) || chr(10) ||
             ' - Monitoring ' || l_objectCount || ' objects with a total of ' || l_totalCount || ' revisions.' || chr(13) || chr(10) ||
             ' - PInC is currently using ' || l_tableSize || 'KB physical disk space.' || chr(13) || chr(10) ||
             ' - Number of objects with missing PInC info: ' || l_missCount || '.' || chr(13) || chr(10);
    dbms_lob.writeappend(p_report, length(l_tmp), l_tmp);

  END;


  PROCEDURE generateReport(p_reportType VARCHAR2,
                           p_daytime DATE,
                           p_prefix VARCHAR2,
                           p_suffix VARCHAR2,
                           p_filter1 VARCHAR2 DEFAULT NULL,
                           p_filter2 VARCHAR2 DEFAULT NULL,
                           p_filter3 VARCHAR2 DEFAULT NULL) IS
      l_sysdate DATE := sysdate;
      l_reportText CLOB := NULL;
      l_filter VARCHAR2(200);
      l_reportHeading VARCHAR2(200);
   BEGIN
      IF p_reportType = 'RELEASE' THEN
         l_filter := 'TAG=' || p_filter1 || ';';
      ELSE
         l_filter := 'OBJECT_TYPE=' || p_filter1 || ';FILTER=' || p_filter2 || ';';
      END IF;

      INSERT INTO CTRL_PINC_REPORT (daytime, report_type, filter, report_text) VALUES (l_sysdate,p_reportType, l_filter, EMPTY_CLOB());
      SELECT REPORT_TEXT INTO l_reportText FROM CTRL_PINC_REPORT WHERE daytime = l_sysdate AND report_type = p_reportType;

       IF p_prefix IS NOT NULL THEN
          dbms_lob.writeappend(l_reportText, length(p_prefix), p_prefix);
       END IF;


       IF p_reportType = 'FULL' THEN
          l_reportHeading := 'Full PInC report:' || chr(13) || chr(10);
          dbms_lob.writeappend(l_reportText, length(l_reportHeading), l_reportHeading);
          writeRepObj(l_reportText, p_daytime, '%', '%');
          writeRepMisObj(l_reportText, '%', '%');
       ELSIF p_reportType = 'OBJECTS' THEN
          l_reportHeading := 'PInC report of type OBJECTS where Object Type is ' || nvl(p_filter1,'ALL') || ' and filter is ' || nvl(p_filter2,'ALL') || ':' || chr(13) || chr(10);
          dbms_lob.writeappend(l_reportText, length(l_reportHeading), l_reportHeading);
          writeRepObj(l_reportText, p_daytime, p_filter1, p_filter2);
          writeRepMisObj(l_reportText, p_filter1, p_filter2);
       ELSIF p_reportType = 'RELEASE' THEN
          l_reportHeading := 'PInC report of type RELEASE where Tag is ' || p_filter1 || ':' || chr(13) || chr(10);
          dbms_lob.writeappend(l_reportText, length(l_reportHeading), l_reportHeading);
          writeRepTag(l_reportText, p_filter1);
          writeRepMisObj(l_reportText, '%', '%');
       ELSIF p_reportType = 'USER' THEN
          l_reportHeading := 'PInC report of type USER where Object Type is ' || nvl(p_filter1,'ALL') || ' and user is ' || p_filter3 || ':' || chr(13) || chr(10);
          dbms_lob.writeappend(l_reportText, length(l_reportHeading), l_reportHeading);
          writeRepUser(l_reportText, p_filter1, p_filter2, p_filter3);
       ELSIF p_reportType = 'CUSTOM' THEN
          l_reportHeading := 'PInC report of type CUSTOM where Object Type is ' || nvl(p_filter1,'ALL') || ' and filter is ' || nvl(p_filter2,'ALL') || ':' || chr(13) || chr(10);
          dbms_lob.writeappend(l_reportText, length(l_reportHeading), l_reportHeading);
          writeRepCustom(l_reportText, p_filter1, p_filter2);
          writeRepMisObj(l_reportText, p_filter1, p_filter2);
       ELSIF p_reportType = 'STATUS' THEN
          l_reportHeading := 'PInC report of type STATUS:';
          dbms_lob.writeappend(l_reportText, length(l_reportHeading), l_reportHeading);
          writeRepStatus(l_reportText);
       END IF;

       IF p_suffix IS NOT NULL THEN
          dbms_lob.writeappend(l_reportText, length(p_suffix), p_suffix);
       END IF;
       --dbms_lob.close(l_reportText);


  END;


  FUNCTION getRep_TEST(p_reportName VARCHAR2,
                       p_daytime    TIMESTAMP,
                       p_typeFilter VARCHAR2,
                       p_nameFilter VARCHAR2,
                       p_tag        VARCHAR2) RETURN CLOB IS
    l_tmp CLOB := NULL;
  BEGIN
    dbms_lob.createtemporary(l_tmp, TRUE, dbms_lob.CALL);

    IF p_reportName = 'FULL' THEN
      writeRepObj(l_tmp, p_daytime, '%', '%');

    ELSIF p_reportName = 'OBJECTS' THEN
      writeRepObj(l_tmp, p_daytime, p_typeFilter, p_nameFilter);

    ELSIF p_reportName = 'RELEASE' THEN
      writeRepTag(l_tmp, p_tag);

    ELSIF p_reportName = 'CUSTOM' THEN
      writeRepCustom(l_tmp, p_typeFilter, p_nameFilter);

    ELSIF p_reportName = 'STATUS' THEN
      writeRepStatus(l_tmp);
    END IF;

    RETURN l_tmp;
  END;



  PROCEDURE logTableContent(p_tableName VARCHAR2, p_operation VARCHAR2, p_key VARCHAR2, p_source BLOB)  IS
    l_type CONSTANT VARCHAR2(100) := 'TABLE CONTENT';
    l_md5 VARCHAR2(32);
    l_exist BOOLEAN := FALSE;
  BEGIN
    -- Compute the MD5 sum of this row.
    IF p_operation = 'DELETING' THEN
       l_md5 := s_md5NA;
    ELSE
       l_md5 := ecdp_pinc.computeMD5(p_source);
    END IF;

    -- Check if the newest row in CTRL_PINC has the same MD5, if so no need to log....
    FOR c_cur IN c_latestObject(l_type, p_tableName, p_key)  LOOP
       IF c_cur.md5sum = l_md5 THEN
          l_exist := TRUE;
       END IF;
       EXIT;
    END LOOP;

    -- Log to CTRL_PINC
    IF NOT l_exist THEN
       INSERT INTO CTRL_PINC
         (TYPE, NAME, md5sum, daytime, tag, OBJECT, operation, TABLE_PK, username, osuser, machine, terminal, created_by, created_date)
       VALUES
         (l_type,
          p_tableName,
          nvl(l_md5, 'ERROR'),
          SYSTIMESTAMP,
          ecdp_pinc.getInstallModeTag(),
          p_source,
          p_operation,
          p_key,
          SYS_CONTEXT('USERENV', 'SESSION_USER'),
          SYS_CONTEXT('USERENV', 'OS_USER'),
          SYS_CONTEXT('USERENV', 'HOST'),
          SYS_CONTEXT('USERENV', 'TERMINAL'),
          SYS_CONTEXT('USERENV', 'SESSION_USER'),
          sysdate);
      END IF;
  END;


  PROCEDURE revertObject(p_type VARCHAR2, p_name VARCHAR2, p_md5 VARCHAR2) IS
     l_oldObject BLOB := NULL;
     l_liveMd5 VARCHAR2(32);

      CURSOR c_oldObject(p_theType VARCHAR2, p_theName VARCHAR2, p_theMd5 VARCHAR2) IS
      SELECT *
        FROM ctrl_pinc
       WHERE TYPE = p_theType
         AND NAME = p_theName
         AND MD5SUM = p_md5
       ORDER BY daytime DESC;


  BEGIN
     IF p_md5 IS NULL THEN
        raise_application_error(-20000, 'ERROR: NULL is not a valid MD5 sum.');
     END IF;

     l_liveMd5 := getLiveMD5(p_type, p_name);
     IF nvl(l_liveMd5,'X') <> p_md5 THEN
        raise_application_error(-20000, 'ERROR: Can''t replace object with itself.');
     END IF;


    FOR curObj IN c_oldObject(p_type, p_name, p_md5) LOOP
      l_oldObject := curObj.object;
      exit;
    END LOOP;

    IF l_oldObject IS NOT NULL THEN
       -- Ok, do it!
       -- NOTYET!
       null;
    END IF;

  END;


/* UTIITIES METHODS */

--compare

END EcDp_PInC;