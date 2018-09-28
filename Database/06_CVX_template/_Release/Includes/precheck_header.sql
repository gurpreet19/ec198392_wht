/* Formatted on 9/19/2011 1:36:48 PM (QP5 v5.139.911.3011) */
/**
The script below will automatically detect if site-specific changes will be overwritten
by the service pack scripts.
Check the file precheck_result.csv generated by this script. The file is in CSV format, which can 
be opened with Microsoft Excel or any text editor.
If any row exists in the result, please check for the changes on the listed item.
For table content changes (except for new insert), do the following:

SELECT ecdp_pinc.getLiveSRC(T1.TYPE, T1.NAME, T1.TABLE_PK) "CURRENT SOURCE",
       ecdp_pinc.getLiveMd5(T1.TYPE, T1.NAME, T1.TABLE_PK) "CURRENT MD5",
       T1.OBJECT "EXPECTED SOURCE",
       t1.MD5SUM "EXPECTED MD5"
  FROM CTRL_PINC T1
 WHERE t1.TYPE = 'TABLE CONTENT'
   AND t1.name = '<Object Name>'
   and t1.table_pk = '<Table PK>'
   AND t1.daytime = (SELECT MAX(t2.daytime)
                       FROM ctrl_pinc t2
                      WHERE t2.type = t1.type
                        AND t2.name = t1.name
                        AND t2.table_pk = t1.table_pk
                        AND tag IS NOT NULL
                        AND tag NOT LIKE 'EC-9_3-SP11%')

Note that column "CURRENT SOURCE" and "EXPECTED SOURCE" is BLOB with text content. Please use 
respective BLOB viewer to view the content.

For the actual sql script that perform the insert/update/delete action, please refer to the 
service pack folder. Use Operating System's search facility.

For other objects (triggers, views, packages, tables, indexes)

SELECT ecdp_pinc.getLiveSRC(T1.TYPE, T1.NAME) "CURRENT SOURCE",
       ecdp_pinc.getLiveMd5(T1.TYPE, T1.NAME) "CURRENT MD5",
       T1.OBJECT "EXPECTED SOURCE",
       t1.MD5SUM "EXPECTED MD5"
  FROM CTRL_PINC T1
 WHERE t1.TYPE = '<Object Type>'
   AND t1.name = '<Object Name>'
   AND t1.daytime = (SELECT MAX(t2.daytime)
                       FROM ctrl_pinc t2
                      WHERE t2.type = t1.type
                        AND t2.name = t1.name
                        AND tag IS NOT NULL
                        AND tag NOT LIKE 'EC-9_3-SP11%')

Note that column "CURRENT SOURCE" and "EXPECTED SOURCE" is BLOB with text content. Please use 
respective BLOB viewer to view the content.

For the actual sql script that perform update on the object, please refer to the service pack folder.
Use Operating System search facility.

------------------
ERRORS HANDLED
------------------

IF the database is imported from dump file with different username, one should change column 
class_db_mapping.db_object_owner. When this is done, a number of error will be listed in precheck log for
the table. The error with name "CLASS_DB_MAPPING" then may be ignored.

IF the database is imported from a dump file with different character set that causing automatic 
characterset conversion, the content of the object's source may change. This will cause the live
md5 calculation to be different than expected. If this is the case, one may expect a number of 
false entry in the precheck log.

	**/

@.\_Release\utilities\operation_parameters_precheck.sql
@.\std_variables.sql

DEFINE update_name = '&&buildID'
DEFINE feature_id = 'CVX_TEMPLATE'
DEFINE major_version = '&&majorVersion'
DEFINE new_minor_version = '&&minorVersion'
DEFINE release_date = '&&release_date' -- DD-MON-YYYY format
DEFINE description = 'CVX Template Update &major_version&..new_minor_version'
DEFINE author = 'EC Central Support'

PROMPT Connecting to [eckernel_&&operation@&&database_name]...
connect eckernel_&&operation/"&&ec_schema_password"@&&database_name

ALTER TRIGGER ddl_eckernel DISABLE;

CREATE GLOBAL TEMPORARY TABLE t_ctrl_pinc
(
   tag        VARCHAR2 (32),
   TYPE       VARCHAR2 (30),
   name       VARCHAR2 (240),
   md5sum     VARCHAR2 (32),
   table_pk   VARCHAR2 (2000),
   result     VARCHAR2 (2000)
)
ON COMMIT DELETE ROWS
/

CREATE OR REPLACE PROCEDURE AddPrecheckMessage (
   p_message_name       VARCHAR2,
   p_message_details    VARCHAR2)
IS
BEGIN
   ecdp_dynsql.
   writeTempText (
      'PINC_EXISTS',
      '"' || p_message_name || '",,,"' || p_message_details || '"');
END;
/

CREATE OR REPLACE PROCEDURE AddPrecheckItem (
   p_object_type    VARCHAR2,
   p_object_name    VARCHAR2,
   p_md5_sum        VARCHAR2 DEFAULT NULL,
   p_table_pk       VARCHAR2 DEFAULT NULL)
IS
   ln_count   NUMBER;
BEGIN
   INSERT INTO t_ctrl_pinc (tag,
                            TYPE,
                            name,
                            md5sum,
                            table_pk)
        VALUES ('CVX_UPDATE',
                UPPER (p_object_type),
                UPPER (p_object_name),
                UPPER (p_md5_sum),
                UPPER (p_table_pk));
   --COMMIT;
END;
/

-- return Y if object updated

--CREATE OR REPLACE FUNCTION isObjectUpdated (
--   p_tag         VARCHAR2,
--   p_type        VARCHAR2,
--   p_name        VARCHAR2,
--   p_table_pk    VARCHAR2 DEFAULT NULL)
--   RETURN VARCHAR2
--IS
--   ld_prev_tag_date   DATE;
--   ld_object_date     DATE;
--   ln_count           NUMBER;
--
--   CURSOR c_get_date
--   IS
--        SELECT daytime
--          FROM ctrl_pinc
--         WHERE     TYPE = p_type
--               AND name = p_name
--               AND NVL (table_pk, 'N') = NVL (p_table_pk, 'N')
--               AND tag IS NOT NULL
--      --    AND tag <> p_tag
--      ORDER BY daytime DESC;
--
--   CURSOR c_get_object_date (
--      cp_prev_tag_date DATE)
--   IS
--        SELECT daytime
--          FROM ctrl_pinc
--         WHERE TYPE = p_type AND name = p_name
--               AND daytime >
--                      NVL (cp_prev_tag_date,
--                           TO_DATE ('1900-01-01', 'yyyy-mm-dd'))
--      --AND tag IS NULL
--      --AND tag <> p_tag
--      ORDER BY daytime DESC;
--BEGIN
--   ld_object_date := NULL;
--
--   FOR one IN c_get_date
--   LOOP
--      ld_prev_tag_date := one.daytime;
--      EXIT;
--   END LOOP;
--
--   -- get current object date
--   IF p_type = 'TABLE CONTENT'
--   THEN
--      IF ld_prev_tag_date IS NOT NULL
--      THEN
--         EXECUTE IMMEDIATE   'select max(last_updated_date) from '
--                          || p_name
--                          || ' WHERE '
--                          || p_table_pk
--                          || ' and last_updated_date > :x'
--            INTO ld_object_date
--            USING ld_prev_tag_date;
--      ELSE
--         -- NB! check if object is already in db! select * from 'p_name' where p_table_pk
--         EXECUTE IMMEDIATE   'SELECT count(*) FROM '
--                          || p_name
--                          || ' WHERE '
--                          || p_table_pk
--            INTO ln_count;
--
--         IF ln_count = 0
--         THEN
--            ld_object_date := TO_DATE ('1900-01-01', 'yyyy-mm-dd');
--         ELSE
--            ld_object_date := TO_DATE ('3045-01-01', 'yyyy-mm-dd');
--         END IF;
--      END IF;
--   ELSE
--      FOR two IN c_get_object_date (ld_prev_tag_date)
--      LOOP
--         ld_object_date := two.daytime;
--         EXIT;
--      END LOOP;
--   END IF;
--
--   IF NVL (ld_object_date, TO_DATE ('1900-01-01', 'yyyy-mm-dd')) >
--         NVL (ld_prev_tag_date, TO_DATE ('1900-01-01', 'yyyy-mm-dd'))
--   THEN
--      RETURN 'Y';
--   END IF;
--
--   RETURN 'N';
--END isObjectUpdated;
--/

DELETE t_temptext
  WHERE id LIKE 'PINC%';