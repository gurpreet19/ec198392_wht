/* Formatted on 9/19/2011 3:17:04 PM (QP5 v5.139.911.3011) */
DECLARE
   lv_md5         VARCHAR2 (32);
   lv_prev_md5    VARCHAR2 (32);
   lv_tag         VARCHAR2 (32);
   lv_indexname   VARCHAR2 (30) := NULL;

   CURSOR c_ctrl_pinc
   IS
          SELECT c.tag,
                 c.TYPE,
                 c.name,
                 c.md5sum,
                 c.table_pk,
                 c.result,
                 ecdp_pinc.getLiveMd5 (c.TYPE, c.name, c.table_pk) cur_md5sum
            FROM t_ctrl_pinc c
        ORDER BY TYPE, name
      FOR UPDATE ;

   CURSOR c_index (cp_indexname VARCHAR2)
   IS
      SELECT index_name
        INTO lv_indexname
        FROM user_indexes
       WHERE index_name = cp_indexname;
BEGIN
   -- one.md5sum is null = expecting no record, lv_md5 <> 'N/A' = record exist in customer db
   FOR one IN c_ctrl_pinc
   LOOP
      IF (one.md5sum IS NULL OR one.md5sum = 'N/A')
         AND one.cur_md5sum <> 'N/A'
      THEN
         UPDATE t_ctrl_pinc
            SET result =
                   INITCAP (one.type)
                   || ' is expected to be new in this update, but has been previously added by the site.'
          WHERE CURRENT OF c_ctrl_pinc;
      ELSIF one.md5sum <> one.cur_md5sum
      THEN
         UPDATE t_ctrl_pinc
            SET result =
                   INITCAP (one.type)
                   || ' has been modified from expected baseline by site.'
          WHERE CURRENT OF c_ctrl_pinc;

         IF (one.name = 'CLASS_DB_MAPPING')
         THEN
            UPDATE t_ctrl_pinc
               SET result =
                      INITCAP (one.type)
                      || ' has been modified from expected baseline by site. Note that an import to a different schema may account for the difference.'
             WHERE CURRENT OF c_ctrl_pinc;
         END IF;
      END IF;
   END LOOP;

--   COMMIT;

   FOR one IN (SELECT result
                 FROM t_ctrl_pinc
                WHERE result IS NOT NULL)
   LOOP
      ecdp_dynsql.writeTempText ('PINC_PRECHECK', one.result);
   END LOOP;
END;
/

DECLARE
   ln_count    NUMBER;
   ln_count2   NUMBER;
BEGIN
   SELECT COUNT (*)
     INTO ln_count
     FROM user_objects
    WHERE object_name = 'CT_EC_INSTALL_HISTORY' AND object_type = 'TABLE';

   IF ln_count < 1
   THEN
      ecdp_dynsql.
      writeTempText (
         'PINC_EXISTS',
         '"PRODUCT NOT INSTALLED",,,"The Chevron Template is not installed in the system"');
   END IF;
END;
/

set long 9999
set heading off
set verify off
set feedback off
set echo off
set pagesize 9999
set linesize 220
set trimspool on
spool .\precheck_result.csv
--SELECT '"EC DATABASE VERSION",,,' || DECODE((SELECT count(1) AS ln_count FROM CTRL_DB_VERSION WHERE DESCRIPTION='EC-9_3-SP10'), 0, '"Database version is incorrect. Found ' ||  (select description from ctrl_db_version) || ', expecting EC-9_3-SP10"', '"Database Version is OK"') FROM dual;

SELECT text
  FROM t_temptext
 WHERE id IN ('PINC_EXISTS', 'PINC_PATCH-BEYOND');

--SELECT '"SP11 INSTALLED",,,' || DECODE((SELECT count(1) FROM ctrl_pinc WHERE tag='EC-9_3-SP11-PROD'), '0', '"Service Pack EC-9_3-SP11 can safely be installed for PROD"', '"Service Pack EC-9_3-SP11 already installed for PROD"') FROM dual;

SELECT ',,,Errors (if any) will appear here:' FROM DUAL;

SELECT '"OBJECT TYPE","OBJECT NAME","TABLE PK (for Table Content)","ERROR MESSAGE"'
  FROM DUAL;

  SELECT    '"'
         || TYPE
         || '","'
         || name
         || '","'
         || table_pk
         || '","'
         || result
         || '"'
    FROM t_ctrl_pinc
   WHERE result IS NOT NULL
ORDER BY TYPE, name, table_pk;

spool off
set heading on
set verify on
set feedback on

DELETE t_temptext
 WHERE id LIKE 'PINC%';

DROP TABLE t_ctrl_pinc;
--DROP FUNCTION isObjectUpdated;
DROP PROCEDURE AddPrecheckMessage;
DROP PROCEDURE AddPrecheckItem;
ALTER TRIGGER ddl_eckernel ENABLE;

/

exit