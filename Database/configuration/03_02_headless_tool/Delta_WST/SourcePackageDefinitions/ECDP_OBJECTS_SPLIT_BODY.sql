CREATE OR REPLACE PACKAGE BODY EcDp_Objects_Split IS

/****************************************************************
** Package        :  EcDp_Objects_Split, body part
**
** $Revision: 1.20 $
**
** Purpose        :  Provide basic functions on objects
**
** Documentation  :  www.energy-components.com
**
** Created  : 19.01.2004  Sven Harald Nilsen
**
** Modification history:
**
**  Date       Whom  Change description:
**  ------     ----- --------------------------------------
**  19.03.2004 SHN   Added procedure ValidateValues
**  10.02.2006 DARREN TI#3473 Change Error code in ValidateValues
**  28.09.2006 zakiiari   TI#2610: Add SetSplitEndDate procedure
**  09.05.2007 rajarsar   ECPD-5231: Add SetInsertSplitEndDate procedure
**  12.11.2007 ismaiime   ECPD-6222: Add new parameter p_allow_zero to procedure ValidateValues
**  10.04.2009 oonnnng    ECPD-6067: Add additional paramter p_object_id in CreateNewShare and SetSplitEndDate functions.
**  02.02.2011 musthram   ECPD-16901: Equity Share - Support for fluid types
**  18.03.2011 rajarsar   ECPD-16901: Updated createNewShare to support different phases
**  12.04.2011 leongwen   ECPD-15663: Stream Company Split revision info
**  02.12.2011 choonshu   ECPD-19015: Modified validateShare procedure to check only ECO_SHARE column
**  07.12.2011 abdulmaw	  ECPD-18381: Modified SetSplitEndDate to update the revision info
**  17.01.2012 choonshu   ECPD-19832: Reverted the validateShare procedure to previous version
**  03.02.2012 musthram   ECPD-19862: Updated SetSplitEndDate to set split end date only for selected phase
**  18.01.2016 kumarsur   ECPD-30664: Modified CreateNewShare.
**  31.05.2016 choooshu   ECPD-34967: Modified CreateNewShare to exclude record revision details.
**  15.03.2017 khatrnit   ECPD-43869: Modified ValidateValues to add rounding after calculating the sum.
****************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : CreateNewShare
-- Description    :
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
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE CreateNewShare(
        p_owner_object_id     VARCHAR2,
        p_daytime             DATE,
        p_class_name          VARCHAR2,
        p_phase              VARCHAR2 DEFAULT NULL
        )
--</EC-DOC>
IS

   CURSOR c_columns(p_table_name  VARCHAR2) IS
    SELECT * FROM cols
    WHERE table_name = p_table_name AND column_name <> 'DAYTIME';

   CURSOR c_class_db_mapping(p_class_name  VARCHAR2) IS
    SELECT c.db_object_owner, c.db_object_name, EcDp_ClassMeta_Cnfg.getLockInd(c.class_name) AS lock_ind
    FROM class_cnfg c
    WHERE c.class_name = p_class_name;



   lv2_owner            class_cnfg.db_object_owner%TYPE;
   lv2_table_name       class_cnfg.db_object_name%TYPE;
   lv2_cols             VARCHAR2(4000);
   lv2_sql              VARCHAR2(32000);
   ld_next_daytime      DATE;
   lv2_lock_ind         VARCHAR2(1);
   lv2_appuser          VARCHAR2(30):=Nvl(EcDp_Context.getAppUser,User);
   lv2_created_date     VARCHAR2(32) := to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD HH24:MI:SS');

BEGIN

   -- Get table_name
   FOR curClass IN c_class_db_mapping(p_class_name) LOOP
      lv2_owner := curClass.db_object_owner;
      lv2_table_name := curClass.db_object_name;
      lv2_lock_ind := Nvl(curClass.lock_ind,'N');
   END LOOP;

   IF lv2_lock_ind = 'Y' THEN

     -- Need to enforce locking check, assuming that this follows the analysis case, meaning we must check if there are
     -- any locked months between the new split and the next split for given owner object.

     lv2_sql := 'SELECT min(daytime) FROM ' || lv2_owner || '.' || lv2_table_name ||
                ' WHERE object_id = :p_owner_object_id ' || CHR(10) ||
                ' AND daytime > :p_daytime ';

     BEGIN

       EXECUTE IMMEDIATE lv2_sql INTO ld_next_daytime USING p_owner_object_id, p_daytime ;

     EXCEPTION    -- This can fail if there are now next split, then set next split to NULL
       WHEN OTHERS THEN
          ld_next_daytime := NULL;

     END;

     EcDp_Month_lock.validatePeriodForLockOverlap('INSERTING', p_daytime, ld_next_daytime, 'EcDp_Objects_split.CreateNewShare, new split have effect on locked period.', p_owner_object_id);

   END IF; -- lv2_lock_ind = 'Y'

   -----------------------------
   -- Build and execute insert statement
   ------------------------------
   FOR curColum IN c_columns(lv2_table_name) LOOP
      IF 'RECORD_STATUS' != UPPER(curColum.column_name)
     	AND 'CREATED_BY' != UPPER(curColum.column_name)
      	AND 'CREATED_DATE' != UPPER(curColum.column_name)
      	AND 'LAST_UPDATED_BY' != UPPER(curColum.column_name)
      	AND 'LAST_UPDATED_DATE' != UPPER(curColum.column_name)
      	AND 'REV_NO' != UPPER(curColum.column_name)
      	AND 'REV_TEXT' != UPPER(curColum.column_name)
      	AND 'APPROVAL_BY' != UPPER(curColum.column_name)
      	AND 'APPROVAL_DATE' != UPPER(curColum.column_name)
      	AND 'APPROVAL_STATE' != UPPER(curColum.column_name)
      	AND 'REC_ID' != UPPER(curColum.column_name) THEN
			lv2_cols := lv2_cols || ', ' || curColum.column_name;
	  END IF;
   END LOOP;

   lv2_sql := 'INSERT INTO ' || lv2_owner || '.' || lv2_table_name ||
              '(daytime, created_by, created_date' || lv2_cols || ')'   || CHR(10) ||
              ' SELECT :p_daytime,'|| chr(39) || lv2_appuser || chr(39) ||', to_date('|| chr(39) || lv2_created_date || chr(39) ||','|| chr(39) ||'YYYY-MM-DD HH24:MI:SS'|| chr(39) ||')' || lv2_cols || CHR(10) ||
              ' FROM ' || lv2_owner || '.' || lv2_table_name ||
              ' WHERE object_id = :p_owner_object_id ' || CHR(10) ||
              ' AND daytime <= :p_daytime AND :p_daytime < Nvl(end_date,:p_daytime + 1/(24*60*60))';

   IF p_phase IS NOT NULL THEN
     lv2_sql := lv2_sql || ' AND fluid_type = :p_phase';
     EXECUTE IMMEDIATE lv2_sql USING p_daytime,p_owner_object_id,p_daytime,p_daytime,p_daytime,p_phase;
   ELSE
     EXECUTE IMMEDIATE lv2_sql USING p_daytime,p_owner_object_id,p_daytime,p_daytime,p_daytime;
   END IF;

   lv2_sql := 'UPDATE '|| lv2_owner || '.' || lv2_table_name ||
              ' SET end_date = :p_daytime, rev_no = NVL2(rev_no, rev_no+1, 0), last_updated_by = ' || chr(39) || lv2_appuser || chr(39) ||CHR(10)||
              ' WHERE object_id = :p_object_id AND daytime < :p_daytime  AND :p_daytime < Nvl(end_date, :p_daytime+1/(24*60*60))';

   IF p_phase IS NOT NULL THEN
     lv2_sql := lv2_sql || ' AND fluid_type = :p_phase';
     EXECUTE IMMEDIATE lv2_sql USING p_daytime,p_owner_object_id,p_daytime,p_daytime,p_daytime,p_phase;
   ELSE
     EXECUTE IMMEDIATE lv2_sql USING p_daytime,p_owner_object_id,p_daytime,p_daytime,p_daytime;
   END IF;

END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : ValidateShare
-- Description    :
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
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE ValidateShare(
        p_owner_object_id     VARCHAR2,
        p_daytime             DATE,
        p_class_name          VARCHAR2,
        p_phase               VARCHAR2 DEFAULT NULL
        )
--</EC-DOC>
IS
   -- Columns to validate
   -- Validate all columns of type NUMBER, INTEGER
   CURSOR c_number_cols IS
    SELECT ca.class_name, ca.attribute_name, ca.data_type, ca.db_sql_syntax column_name
    FROM class_attribute_cnfg ca
    WHERE ca.class_name = p_class_name
    AND   ca.data_type in ('NUMBER','INTEGER');

   lv2_table_name    VARCHAR2(100);

BEGIN

   lv2_table_name := EcDp_ClassMeta.getClassDBTable(p_class_name);

   FOR curCol IN c_number_cols LOOP

      ValidateColumn(curCol.column_name, lv2_table_name, p_owner_object_id, p_daytime, p_phase, p_class_name);

   END LOOP;

END ValidateShare;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : ValidateColumn
-- Description    :
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
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE ValidateColumn(
                p_column_name   VARCHAR2,
                p_table_name    VARCHAR2,
                p_object_id     VARCHAR2,
                p_daytime       DATE,
                p_phase         VARCHAR2 DEFAULT NULL,
                p_class_name    VARCHAR2 DEFAULT NULL
                )
--</EC-DOC>
IS

   l_value_list         t_number_list;
   lv2_sql              VARCHAR2(4000);

   TYPE split_curType IS REF CURSOR;
   split_cur split_curType;

BEGIN


   IF p_class_name = 'EQUITY_SHARE' THEN
     lv2_sql := 'SELECT '||p_column_name||CHR(10)||
              ' FROM ' || p_table_name || CHR(10) ||
              ' WHERE object_id = :p_object_id AND daytime = :p_daytime AND fluid_type = :p_phase' ;

     OPEN split_cur FOR lv2_sql USING p_object_id, p_daytime, p_phase;

   ELSE
     lv2_sql := 'SELECT '||p_column_name||CHR(10)||
                ' FROM ' || p_table_name || CHR(10) ||
                ' WHERE object_id = :p_object_id AND daytime = :p_daytime';

     OPEN split_cur FOR lv2_sql USING p_object_id, p_daytime;

   END IF;



   FETCH split_cur
      BULK COLLECT INTO l_value_list;

   CLOSE split_cur;

   ValidateValues(l_value_list,l_value_list.COUNT,p_column_name);


END ValidateColumn;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : ValidateColumn
-- Description    :
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
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE ValidateValues( p_value_list    t_number_list,
                          p_count         NUMBER,
                          p_column_name   VARCHAR2,
                          p_allow_zero    VARCHAR2 DEFAULT 'N')
--</EC-DOC>
IS

   ln_sum            NUMBER DEFAULT 0;
   ln_nulls_count    NUMBER DEFAULT 0;

BEGIN

   FOR ln_indx IN 1..p_count LOOP

      ln_sum := ln_sum + Nvl(p_value_list(ln_indx),0);

      IF p_value_list(ln_indx) IS NULL THEN
         ln_nulls_count := ln_nulls_count + 1;
      END IF;

   END LOOP;

   ln_sum := ROUND(ln_sum,9);

   -- Validate total sum, raise exceptions if not equal to 100.

   IF ln_nulls_count > 0 AND ln_nulls_count < p_count THEN -- One or more values are NULL.

      Raise_Application_Error(-20515,'All values for column '||p_column_name|| ' must be set. Cannot have empty values.');

   ELSIF ln_sum > 100 THEN

      Raise_Application_Error(-20326,'Total sum for column '||p_column_name|| ' cannot be more than 100');

   ELSIF ln_sum < 100 AND ln_nulls_count <> p_count THEN -- Exclude values where all are null

      IF p_allow_zero = 'Y' AND ln_sum = 0 THEN
           NULL ; -- do nothing
      ELSE
           Raise_Application_Error(-20326,'Total sum for column '||p_column_name|| ' cannot be less than 100');
      END IF;

   END IF;


END ValidateValues;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : SetSplitEndDate
-- Description    :
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
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE SetSplitEndDate(
        p_owner_object_id     VARCHAR2,
        p_daytime             DATE,
        p_class_name          VARCHAR2,
        p_phase               VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

   CURSOR c_class_db_mapping(p_class_name  VARCHAR2) IS
    SELECT c.db_object_owner, c.db_object_name, EcDp_ClassMeta_Cnfg.getLockInd(c.class_name) AS lock_ind
    FROM class_cnfg c
    WHERE c.class_name = p_class_name;

   lv2_owner            class_cnfg.db_object_owner%TYPE;
   lv2_table_name       class_cnfg.db_object_name%TYPE;
   lv2_sql              VARCHAR2(32000);
   ld_next_daytime      DATE;
   lv2_lock_ind         VARCHAR2(1);
   lv2_appuser          VARCHAR2(30):=Nvl(EcDp_Context.getAppUser,User);

BEGIN

   -- Get table_name
   FOR curClass IN c_class_db_mapping(p_class_name) LOOP
      lv2_owner := curClass.db_object_owner;
      lv2_table_name := curClass.db_object_name;
      lv2_lock_ind := Nvl(curClass.lock_ind,'N');
   END LOOP;

   IF lv2_lock_ind = 'Y' THEN

     -- Need to enforce locking check, assuming that this follows the analysis case, meaning we must check if there are
     -- any locked months between the new split and the next split for given owner object.

     lv2_sql := 'SELECT min(daytime) FROM ' || lv2_owner || '.' || lv2_table_name ||
                ' WHERE object_id = :p_owner_object_id ' || CHR(10) ||
                ' AND daytime > :p_daytime ';

     BEGIN

       EXECUTE IMMEDIATE lv2_sql INTO ld_next_daytime USING p_owner_object_id, p_daytime ;

     EXCEPTION    -- This can fail if there are now next split, then set next split to NULL
       WHEN OTHERS THEN
          ld_next_daytime := NULL;

     END;

     EcDp_Month_lock.validatePeriodForLockOverlap('UPDATING', p_daytime, ld_next_daytime, 'EcDp_Objects_split.SetSplitEndDate, split end-date have effect on locked period.', p_owner_object_id);

   END IF; -- lv2_lock_ind = 'Y'

   -----------------------------
   -- Build and execute update statement
   ------------------------------

   IF p_phase IS NOT NULL THEN
     lv2_sql := 'UPDATE '|| lv2_owner || '.' || lv2_table_name ||
              ' SET end_date = :p_daytime, rev_no = NVL2(rev_no, rev_no+1, 0), last_updated_by = ' || chr(39) || lv2_appuser || chr(39) ||CHR(10)||
              ' WHERE object_id = :p_object_id AND daytime < :p_daytime  AND :p_daytime < Nvl(end_date, :p_daytime+1/(24*60*60)) AND fluid_type = :p_phase';

     EXECUTE IMMEDIATE lv2_sql using p_daytime,p_owner_object_id,p_daytime,p_daytime,p_daytime,p_phase;
   ELSE
     lv2_sql := 'UPDATE '|| lv2_owner || '.' || lv2_table_name ||
              ' SET end_date = :p_daytime, rev_no = NVL2(rev_no, rev_no+1, 0), last_updated_by = ' || chr(39) || lv2_appuser || chr(39) ||CHR(10)||
              ' WHERE object_id = :p_object_id AND daytime < :p_daytime  AND :p_daytime < Nvl(end_date, :p_daytime+1/(24*60*60))';

     EXECUTE IMMEDIATE lv2_sql using p_daytime,p_owner_object_id,p_daytime,p_daytime,p_daytime;
   END IF;

END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : SetInsertSplitEndDate
-- Description    : To Set End Date for a new record after inserting when the Start Date of the new record is earlier than an existing record.
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
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE SetInsertSplitEndDate(
        p_owner_object_id     VARCHAR2,
        p_daytime             DATE,
        p_class_name          VARCHAR2
        )
--</EC-DOC>
IS

   CURSOR c_class_db_mapping(p_class_name  VARCHAR2) IS
    SELECT c.db_object_owner, c.db_object_name, EcDp_ClassMeta_Cnfg.getLockInd(c.class_name) AS lock_ind
    FROM class_cnfg c
    WHERE c.class_name = p_class_name;

   lv2_owner            class_cnfg.db_object_owner%TYPE;
   lv2_table_name       class_cnfg.db_object_name%TYPE;
   lv2_sql              VARCHAR2(32000);
   ld_next_daytime      DATE;


BEGIN

   -- Get table_name
   FOR curClass IN c_class_db_mapping(p_class_name) LOOP
      lv2_owner := curClass.db_object_owner;
      lv2_table_name := curClass.db_object_name;
   END LOOP;

   lv2_sql := 'SELECT min(daytime) FROM ' || lv2_owner || '.' || lv2_table_name ||
                ' WHERE object_id = :p_owner_object_id ' || CHR(10) ||
                ' AND daytime > :p_daytime ';

   BEGIN

     EXECUTE IMMEDIATE lv2_sql INTO ld_next_daytime USING p_owner_object_id, p_daytime ;

     EXCEPTION    -- This can fail if there are now next split, then set next split to NULL
       WHEN OTHERS THEN
          ld_next_daytime := NULL;

   END;


   -----------------------------
   -- Build and execute update statement
   ------------------------------

   lv2_sql := 'UPDATE '|| lv2_owner || '.' || lv2_table_name ||
              ' SET end_date = :ld_next_daytime'||CHR(10)||
              ' WHERE object_id = :p_object_id AND daytime = :p_daytime';

   EXECUTE IMMEDIATE lv2_sql using ld_next_daytime,p_owner_object_id,p_daytime;

END;



END EcDp_Objects_Split;