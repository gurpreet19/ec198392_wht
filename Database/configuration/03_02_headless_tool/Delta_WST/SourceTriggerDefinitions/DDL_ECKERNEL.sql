CREATE OR REPLACE EDITIONABLE TRIGGER "DDL_ECKERNEL" 
/**************************************************************
** Trigger:    DDL_ECKERNEL
**
** $Revision: 1.20 $
**
** Filename:   DDL_ECKERNEL.sql
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
** Created:   	10.01.05  Christer Grimsæth, EC FRMW
**
**
** Modification history:
**
**
** Date:     Whom:  Change description:
** --------  ----- --------------------------------------------
** 10.01.05   CGR   Created.
**************************************************************/
   AFTER ddl
   ON SCHEMA
   --ON DATABASE

DECLARE
  --PRAGMA AUTONOMOUS_TRANSACTION; --NOTYET: Do we need this?
  l_md5Err CONSTANT VARCHAR2(5) := 'ERROR';
  l_md5NA  CONSTANT VARCHAR2(3) := 'N/A';

  n            INTEGER := 0; -- PLS_INTEGER?;
  l_latestMd5  VARCHAR2(32) := NULL;
  l_latestTag  VARCHAR2(512) := NULL;
  l_sqlText    ora_name_list_t;
  l_sourceTxt  BLOB := NULL;
  l_md5sum     VARCHAR2(32) := NULL;
  l_event      VARCHAR2(100) := NULL;
  l_objectType VARCHAR2(100) := NULL;
  l_objectName VARCHAR2(100) := NULL;
  l_raw        RAW(32767);
  l_tmp        VARCHAR2(2000) := NULL;
  l_timeStamp  TIMESTAMP := SYSTIMESTAMP;

  CURSOR c_getLastMd5(p_objectType varchar2, p_objectName varchar2) IS
    SELECT md5sum, tag
      FROM (SELECT md5sum, tag
              FROM CTRL_PINC c1
             WHERE c1.TYPE = p_objectType
               AND c1.NAME = p_objectName
             ORDER BY daytime DESC)
     WHERE rownum = 1;

BEGIN
  -- FILTER-1: ignore the following events.
  IF (ORA_SYSEVENT = 'ALTER' AND ORA_DICT_OBJ_TYPE IN ('PACKAGE', 'PACKAGE BODY', 'TRIGGER', 'VIEW')) OR
     (ORA_SYSEVENT = 'GRANT') OR
     (ORA_SYSEVENT = 'COMMENT' AND ORA_DICT_OBJ_TYPE in ('TABLE', 'COLUMN')) OR
     (ORA_DICT_OBJ_TYPE = 'INDEX') OR
     (ORA_DICT_OBJ_NAME IN ('ECDP_PINC','CLASS','CLASS_ATTRIBUTE','CLASS_DB_MAPPING','CLASS_DEPENDENCY','CLASS_REL_DB_MAPPING','CLASS_RELATION','CLASS_TRIGGER_ACTION','CLASS_ATTR_PRESENTATION','CLASS_REL_PRESENTATION'))
     -- TODO: Ignore public synonyms
     -- TODO: Support seq
  THEN
    RETURN;
  END IF;

  dbms_lob.createtemporary(l_sourceTxt, TRUE);

  BEGIN
    l_event      := ORA_SYSEVENT;
    l_objectType := ORA_DICT_OBJ_TYPE;
    l_objectName := ORA_DICT_OBJ_NAME;

    -- *******************************************
    -- (1) Get the source text for this operation.
    IF l_objectType = 'TABLE' AND l_event in ('CREATE', 'ALTER') THEN
      -- We can't use the sqlText() to retrive the "CREATE TABLE" stmt, because there is no way to re-create it from the dictionay views.
      -- Instead we just use the live object (becase it has been commited!.
      -- I seams that the ALTER stmt is not commited before this trigger triggers, so send the alter stmt to getLiveTableSrc().
      IF l_event = 'ALTER' THEN
        -- Get the ALTER stmt
        n := ora_sql_txt(l_sqlText);
        FOR i IN 1 .. n LOOP
          l_tmp := l_sqlText(i);
        END LOOP;
      END IF;
      ecdp_pinc.getLiveTableSrc(l_sourceTxt, upper(l_objectName), l_tmp);
    ELSIF l_objectType = 'VIEW' THEN
       -- We can't use the sqlText() to retrive the "CREATE OR REPLACE VIEW" stmt, because there is no way to re-create it from the dictionay views.
       -- Instead we just use the live object (becase it has been commited!.
       ecdp_pinc.getLiveSrc(l_sourceTxt, l_objectType,  upper(l_objectName));
    ELSE
      -- Retrieve the source text from the sqlText() method.
      n := ora_sql_txt(l_sqlText);
      FOR i IN 1 .. n LOOP
        l_raw := utl_raw.cast_to_raw(l_sqlText(i));
        dbms_lob.writeappend(l_sourceTxt, utl_raw.length(l_raw), l_raw);
      END LOOP;
    END IF;

    -- *******************************************
    -- (2) Compute the MD5sum of the sourceTxt.
    IF l_event <> 'DROP' THEN
       l_md5sum := ecdp_pinc.computeMD5(l_sourceTxt);
    ELSE
       l_md5sum := l_md5NA;
    END IF;


  EXCEPTION
    WHEN OTHERS THEN
      l_sourceTxt := utl_raw.cast_to_raw('ERROR: PInC could not retrieve the source code for ' || l_objectType || '::' || l_objectName || '. [ ' || SQLERRM || ']');
      l_event := 'ERROR';
      l_md5sum := l_md5Err;

      BEGIN
        -- If we are in install mode, then raise application error!
        IF ecdp_pinc.isInstallMode() AND SQLCODE <> '-6502' THEN
          raise_application_error(-20000, utl_raw.cast_to_varchar2(l_sourceTxt));
        END IF;
      END;

  END;

  BEGIN
    -- *******************************************
    -- (3) Ignore this operation if it is equal to the _latest_ version of the object.
    FOR cur IN c_getLastMd5(l_objectType, l_objectName) LOOP
      l_latestMd5 := cur.md5sum;
      l_latestTag := cur.tag;
    END LOOP;

    IF ( nvl(l_latestMd5, 'X') <> nvl(l_md5sum, 'Y') OR (ecdp_pinc.isInstallMode() AND ecdp_pinc.getInstallModeTag() <> l_latestTag) ) THEN
      -- *******************************************
      -- (4) Log action to CTRL_AUDIT_SOURCE_HISTORY table.
      INSERT INTO CTRL_PINC
      (type, name, md5sum, daytime, tag ,object, operation, username, osuser, machine, terminal, created_by, created_date)
      VALUES
        (l_objectType,
         l_objectName,
         nvl(l_md5sum, l_md5Err),
         l_timeStamp,
         ecdp_pinc.getInstallModeTag(),
         l_sourceTxt,
         l_event,
         SYS_CONTEXT('USERENV', 'SESSION_USER'),
         SYS_CONTEXT('USERENV', 'OS_USER'),
         SYS_CONTEXT('USERENV', 'HOST'),
         SYS_CONTEXT('USERENV', 'TERMINAL'),
         SYS_CONTEXT('USERENV', 'SESSION_USER'),
         SYSDATE);
      --commit; --Commit this Autonomous Transaction.

    END IF;

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      NULL; -- Shoud not get any Unique Constraint errors, but if we do then ignore it!
    WHEN OTHERS THEN
      BEGIN
        -- If we are in install mode, then raise application error!
        IF ecdp_pinc.isInstallMode() THEN
          raise_application_error(-20000, chr(10) ||
                                          'ERROR    : PInC could not log ' || l_event || ' info for ' || l_objectType || '::' || l_objectName || ' to CTRL_PINC table.' || chr(10) ||
                                          '  ORA MSG:[' || SQLERRM || ']' || chr(10) ||
                                          '  DATA   : TYPE=' || l_objectType || ';NAME=' || l_objectName|| ';MD5SUM=' || nvl(l_md5sum, l_md5Err)|| ';DAYTIME=' || to_char(l_timeStamp, 'yyyy.mm.dd hh24:mi:ss')|| ';TAG=' || ecdp_pinc.getInstallModeTag()|| ';OPERATION=' || l_event);
        END IF;
      END;
  END;

  dbms_lob.freetemporary(l_sourceTxt);

END DDL_ECKERNEL;
