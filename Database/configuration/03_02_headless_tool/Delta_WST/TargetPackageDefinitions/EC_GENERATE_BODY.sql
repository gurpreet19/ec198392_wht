CREATE OR REPLACE PACKAGE BODY ec_generate IS
/***************************************************************
** Package:                ec_generate, body part
**
** Revision :              $Revision: 1.37.4.5 $
**
** Purpose:                code generation for ec packages
**
** Documentation:          www.energy-components.no
**
** Created:                03.02.00     Marius Fornæss
**
** Modification history:
**
** Date:    Whom: Change description:
** -------- ----- --------------------------------------------
** 23.02.00  UMF   Period-functions -> Math-functions.
**                 Math functions generated for all tables in ctrl_object with math = 'Y'
**
** 20.03.00  UMF   Added support for alias name for columns with long names.
** 18.05.00  UMF   Added support for cummulative functionality in math function.
**                 Nvl(from_day, '1-1-1900') in daytime clause
** 16.06.00      MAO     Added procedures for making dummy functions for net_vol, net_mass, grs_vol, grs_mass
**                                               in the generateDerivedStreams-procedure.
** 12.07.00  MVO   Removed constraint cursors in "generateDerivedStreams()" which selects only streams of type X and D
**                 Reason: it should be possible to generate derived formulas also for mesured streams (Net_Vol vs. Grs_Vol )
** 15.03.01  DN    Added procedures for generating journal reporting layer. Requires DM 6.2.12.
** 19.06.01  DN    Modfied prev% and next% functions to deal with a desired record number in the sequential result set.
** 09.07.01  RRA   Modified procedures for journal reporting, removed initiate and added functionality in procedure.
**                 Also changed UK test to prevent erroneus cursor generation for tables with add Unique Key(s).
** 22.02.02  DN    Function get_pk_param_list, use CURSOR q_qualifier_list to get consistent CURSOR call that matches c_revision in generated logic.
** 20.03.02  LHH   Modified writePackageHeader, writePackageBody, writePackaceView. This will add PROMPT statement to generated code.
** 02.07.02  HNE   Added copyData and generateSystemDaysRows
** 30.08.02  DN    Established journal trigger generation procedure after moving it from the old generate-package.
**                 Made the journal trigger code independent of journal rule by using rev_no testing.  Will
**                 then correspond to the journal event in the IU-trigger.
**                 Added table name as default parameter.
** 19.09.02  DN    Added getAttributeParentTable and attribute_text_by_id function code.
**                 EC-package views are now generated with the FORCE option.
** 07.10.02  DN    Moved copyData and generateSystemDaysRows to new package ec_generate_data.
**                 Moved generateDerivedStreams to new package ec_generate_stream.
**                 getAttributeParentTable: Only those attribute tables without OBJECT_ID foreign key reference.
** 04.11.02  DN    Procedure journaltrigger: Changed from user to last updated by in values clause.
** 02.01.03  DN    Procedure journaltrigger: Journal on delete event.
** 02.05.03  DN    Procedure journaltrigger: Improved journal handling on delete event.
** 20.05.03  DN    Reversed the sysnam renaming. Removed grant and synonym creation.
** 12.11.03  DN    Added better user reporting on journal logging.
** 17.11.03  DN    Procedure journalTriggers: Replaced sysdate with EcDp_Date_Time.getCurrentSysdate
** 02.12.03  DN    Added row_by_object_id.
** 10.08.04  Toha  Removes sysnam in all query and updates as necessary
** 07.03.05  DN    Removed journalReportLayer and sub-procedures.
** 08.03.05  DN    Added new procedure basicIUTriggers.
** 11.03.05  DN    Added new default parameter to generatePackages.
** 08.04.05  DN    Procedure basicIUTriggers: TI 2142
** 22.04.05  AV    Added procedure CreatePINCTriggers to generate after triggers for logging to PINC table during Installmode
** 22.04.05  CGR   Using correct EcDp_PInC.logTableContent() method in procedure CreatePINCTriggers.
** 22.04.05  CGR   Corrected BLOB handeling in  EcDp_PInC.logTableContent().
** 12.05.05  CGR   Fixed the generation of the Key-list in CreatePINCTriggers, so it is a valid WHERE stmt.
** 12.05.05  CGR   Optimized loop in CreatePINCTriggers.
** 25.05.05  CGR   CreatePINCTriggers must produce a key parameter that is usefull as a where stmt (DATE columns must have to_char()).
** 21.02.06  DN    Performance improvements on build of ec-packages
** 03.03.06  DN    Extended the journalTriggers procedure with immediate build option.
** 07.03.2006 DN   TI 3569: Added call to overloaded version of SafeBuild in EcDp_DynSql.
** 08.03.06  AV    Extended the EC_package and Triggers procedure with immediate build option.
** 06.10.06  Jerome TI4490: Updated CreatePINCTriggers's exception list - modified STOR_MTH_EXPORT_STATUS to STOR_PERIOD_EXPORT_STATUS
** 18.10.06  DN    TI 4297: Added procedure writeObjectIdFunction.
** 03.05.07  Arief ECPD-3905: Removed PLAN_VALUE from exclude list, added PROD_FORECAST, PROD_WELL_FORECAST, PROD_STRM_FORECAST, PROD_FCTY_FORECAST
** 16.07.08  Toha  Adds NAV_MODEL_OBJECT_RELATION into exclude list, autoupdated calc_object_meta, calc_attribute_meta and calc_variable_meta
** 03.07.12  Rey	 Add SUMMER_TIME flag, equal cursor will actually handel it, in other cursors it has no effect
***********************************************************************************************/

pv_line_number NUMBER;
pv_id VARCHAR2(30);
pv_lines DBMS_SQL.varchar2a;

-- This public cursor returns those column names and datatypes which is a part of a constraint
CURSOR   c_qualifier_list(cp_table_name VARCHAR2) IS
SELECT   ucc.column_name,
         Nvl(utc.data_type,'VARCHAR2') column_type
FROM     user_constraints uc,
         user_cons_columns ucc,
         user_tab_columns utc
WHERE    uc.table_name = cp_table_name
AND      uc.constraint_type = 'P'
AND      ucc.owner = uc.owner
AND      ucc.constraint_name = uc.constraint_name
AND      ucc.table_name = uc.table_name
AND      utc.table_name = uc.table_name
AND      utc.column_name = ucc.column_name
ORDER BY decode(ucc.column_name, 'SUMMER_TIME',1,0), position;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : createTextLine                                                               --
-- Description    : This procedure creates a record of generated text in the temporary table.    --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   : t_temptext                                                                   --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :
---------------------------------------------------------------------------------------------------
PROCEDURE createTextLine(p_text VARCHAR2,
                         p_target VARCHAR2 DEFAULT 'TABLE'
                        )
--</EC-DOC>
IS
BEGIN
   pv_line_number := pv_line_number + 1;

   IF p_target = 'CREATE' THEN

     EcDp_Dynsql.AddSqlLine(pv_lines,  p_text||CHR(10));

   ELSE

     INSERT INTO t_temptext
     (line_number, Id, text, created_date, created_by)
     VALUES (pv_line_number,pv_id, p_text, SYSDATE, USER);

   END IF;

END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : basicIUTriggers
-- Description    : This procedure creates basic before insert or update table triggers for
--                  tables having standard revision columns.
-- Postconditions :
--
-- Using tables   : user_tables
--                  user_tab_columns
--                  t_temptext
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : If p_table_name is null basic triggers will be generated for all tables
--                  If p_table_name is given a basic trigger for that table only is generated.
---------------------------------------------------------------------------------------------------
PROCEDURE basicIUTriggers(p_table_name VARCHAR2 DEFAULT NULL, p_missing_ind VARCHAR2 DEFAULT NULL, p_target VARCHAR2 DEFAULT 'CREATE')
--</EC-DOC>
IS

CURSOR c_basic_trigger(cp_table_name VARCHAR2, cp_missing_ind VARCHAR2) IS
SELECT t.table_name
FROM user_tables t, user_tab_columns utc
WHERE t.table_name = Nvl(cp_table_name, t.table_name)
AND t.table_name NOT LIKE '%_JN'
AND utc.table_name = t.table_name
AND utc.column_name = 'REV_NO'
AND NOT EXISTS (
SELECT 1 FROM user_triggers ut
WHERE ut.table_name = t.table_name
AND Nvl(cp_missing_ind,'N') = 'Y'
AND ut.trigger_name = 'IU_' || substr(t.table_name,1,27)
);

CURSOR c_ts_cols(cp_table_name VARCHAR2) IS
SELECT column_name
FROM user_tab_columns utc
WHERE column_name IN ('DAY','DAYTIME','DAYHR')
AND table_name = cp_table_name;

CURSOR c_object_class_table(cp_table_name VARCHAR2) IS
SELECT table_name, column_name
FROM user_tab_columns col
WHERE col.table_name = cp_table_name
AND col.column_name = 'OBJECT_ID'
AND col.nullable = 'N'
AND col.data_type = 'VARCHAR2'
AND NOT EXISTS (
SELECT 1
FROM user_constraints uc, user_cons_columns ucc
WHERE uc.table_name = col.table_name
AND uc.constraint_type = 'R'
AND ucc.owner = uc.owner
AND ucc.constraint_name = uc.constraint_name
AND ucc.table_name = uc.table_name
AND ucc.column_name = col.column_name
)
AND EXISTS (
SELECT 1
FROM user_constraints uc, user_cons_columns ucc
WHERE uc.table_name = col.table_name
AND uc.constraint_type IN ('P','U')
AND ucc.owner = uc.owner
AND ucc.constraint_name = uc.constraint_name
AND ucc.table_name = uc.table_name
AND ucc.column_name = col.column_name
AND 1 = (
SELECT count(*)
FROM user_cons_columns ucc2
WHERE ucc2.owner = ucc.owner
AND ucc2.constraint_name = ucc.constraint_name
AND ucc2.table_name = ucc.table_name)
)
;

lv2_trigger_body VARCHAR2(4000);
lv2_sys_guid VARCHAR2(2000);
lv2_daytime VARCHAR2(240);
lv2_day VARCHAR2(240);
lv2_dayhr VARCHAR2(240);

BEGIN

        IF p_target <> 'CREATE' THEN

          DELETE FROM t_temptext WHERE id='EC_TRIGGERS';

        END IF;

        pv_lines.delete;


        pv_id :='EC_TRIGGERS';
        pv_line_number :=0;

   ------------------------------------------------------------
   -- Trigger definition
   ------------------------------------------------------------

   IF p_target <> 'CREATE' THEN
     createTextLine('------------------------------------------------------------',p_target);
     createTextLine('-- EC basic triggers - generated by EC BASIS ' ||
     to_char(sysdate,'dd.mm.yyyy hh24:mi'),p_target);
     createTextLine('------------------------------------------------------------',p_target);
   END IF;

        FOR CurTab IN c_basic_trigger(p_table_name, p_missing_ind) LOOP

      lv2_sys_guid := NULL;

      FOR cur_rec IN c_object_class_table(CurTab.table_name) LOOP

          lv2_sys_guid := '      IF :new.object_id IS NULL THEN' || CHR(10) ||
                          '         :new.object_id := SYS_GUID();'  || chr(10) ||
                          '      END IF;' || chr(10);
      END LOOP;

      lv2_daytime := NULL;
      lv2_day := NULL;
      lv2_dayhr := NULL;


      IF lv2_sys_guid IS NULL THEN

         FOR cur_col IN c_ts_cols(CurTab.table_name) LOOP

            IF cur_col.column_name = 'DAYTIME' THEN
               IF INSTR(CurTab.table_name,'_DAY_') > 0 AND INSTR(CurTab.table_name,'_SUB_') < 1 THEN
                  lv2_daytime := '      :new.daytime := trunc(:new.daytime,''DD'');' || chr(10);
               ELSIF INSTR(CurTab.table_name,'_MTH_') > 0 THEN
                  lv2_daytime := '      :new.daytime := trunc(:new.daytime,''MM'');' || chr(10);
               END IF;

            ELSIF cur_col.column_name = 'DAY' THEN

               IF (INSTR(CurTab.table_name,'_DAY_') + INSTR(CurTab.table_name,'_MTH_')) < 1 AND SUBSTR(CurTab.table_name,1,5) <> 'CTRL_' THEN
                  lv2_day := '      :new.day := trunc(:new.daytime,''DD'');' || chr(10);
               END IF;

            ELSIF cur_col.column_name = 'DAYHR' THEN

               IF (INSTR(CurTab.table_name,'_DAY_') + INSTR(CurTab.table_name,'_MTH_')) < 1 AND SUBSTR(CurTab.table_name,1,5) <> 'CTRL_' THEN
                  lv2_dayhr := '      :new.dayhr := trunc(:new.daytime,''HH24'');' || chr(10);
               END IF;

            END IF;

         END LOOP;

      END IF;

      lv2_trigger_body := 'CREATE OR REPLACE TRIGGER IU_' || substr(CurTab.table_name,1,27) || chr(10) ||
                          'BEFORE INSERT OR UPDATE ON ' || CurTab.table_name || chr(10) ||
                          'FOR EACH ROW ' || chr(10) ||
                          'BEGIN ' || chr(10) ||
                          '    -- Basis' || chr(10) ||
                          '    IF Inserting THEN ' || chr(10) ||
                          lv2_daytime ||
                          lv2_day ||
                          lv2_dayhr ||
                          '      :new.record_status := nvl(:new.record_status, ''P'');' || CHR(10) ||
                                 lv2_sys_guid ||
                          '      IF :new.created_by IS NULL THEN' || CHR(10) ||
                          '         :new.created_by := User;' || chr(10) ||
                          '      END IF;'  || chr(10) ||
                          '      IF :new.created_date IS NULL THEN' || CHR(10) ||
                          '         :new.created_date := EcDp_Date_Time.getCurrentSysdate;' || chr(10) ||
                          '      END IF;'  || chr(10) ||
                          '      :new.rev_no := 0;' || chr(10) ||
                          '    ELSE ' || chr(10) ||
                          '      IF Nvl(:new.record_status,''P'') = Nvl(:old.record_status,''P'') THEN' || chr(10) ||
                          '         IF NOT UPDATING(''LAST_UPDATED_BY'') THEN' || CHR(10) ||
                          '            :new.last_updated_by := User;' || chr(10) ||
                          '         END IF;'  || chr(10) ||
                          '         IF NOT UPDATING(''LAST_UPDATED_DATE'') THEN' || CHR(10) ||
                          '           :new.last_updated_date := EcDp_Date_Time.getCurrentSysdate;' || chr(10) ||
                          '         END IF;'  || chr(10) ||
                          '      END IF;' || chr(10) ||
                          '    END IF;' || chr(10) ||
                          'END;' || chr(10) ;

         createTextLine(lv2_trigger_body, p_target);

         IF p_target = 'CREATE' THEN
           Ecdp_Dynsql.SafeBuild(CurTab.table_name,'TRIGGER',pv_lines,p_target,pv_id,'Y');
           pv_lines.delete;

        ELSE
          createTextLine('/  ',p_target);
          createTextLine('  ',p_target);
        END IF;

     END LOOP;

END basicIUTriggers;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : journalTriggers
-- Description    : This procedure creates after update and delete trigger for all tables that
--                  have associated journal table generated from Designer.
-- Postconditions :
--
-- Using tables   : user_tables
--                  user_tab_columns
--                  user_triggers
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : If p_table_name is null journal triggers will be generated for all
--                  tables configured.
--                  If p_table_name is given a journal trigger for that table only is generated.
--                  If p_missing_ind is set to 'Y' the trigger will only be generated if its not there.
--                  p_target means if the trigger is going to be created immediately or added into t_temptext.
---------------------------------------------------------------------------------------------------
PROCEDURE journalTriggers(p_table_name VARCHAR2 DEFAULT NULL,
                          p_missing_ind VARCHAR2 DEFAULT NULL,
                          p_target VARCHAR2 DEFAULT 'CREATE')
--</EC-DOC>
IS

CURSOR jour_trigger is
SELECT
'CREATE OR REPLACE TRIGGER JN_' || substr(a.table_name,1,25) || chr(10) ||
'AFTER UPDATE OR DELETE ON ' || a.table_name || chr(10) ||
'FOR EACH ROW ' || chr(10) ||
'DECLARE ' || chr(10) ||
'   lv2_operation char(3); ' || chr(10) ||
'   lv2_last_updated_by VARCHAR2(30); ' || chr(10) ||
'BEGIN ' || chr(10) ||
'   IF (Nvl(:new.rev_no, 0) <> :old.rev_no) OR (Deleting) THEN ' || chr(10) ||
'   IF Deleting THEN '|| chr(10) ||
'     lv2_operation := '||chr(39)||'DEL'||chr(39)||';'||chr(10)||
'     lv2_last_updated_by := Nvl(EcDp_User_Session.getUserSessionParameter(''USERNAME''), User);' || CHR(10) ||
'   ELSE ' || chr(10) ||
'     lv2_operation := '||chr(39)||'UPD'||chr(39)||';'||chr(10)||
'     lv2_last_updated_by := :new.last_updated_by;' || CHR(10) ||
'   END IF; ' || chr(10) ||
'       INSERT INTO ' || a.table_name || '_JN ' || chr(10) ||
'     (jn_operation, jn_oracle_user, jn_datetime, jn_notes' trigger_def,
a.table_name
FROM user_tables a
WHERE a.table_name = Nvl(p_table_name, a.table_name)
AND EXISTS (
        SELECT * FROM user_tables b
        WHERE a.table_name||'_JN' = b.table_name
)
AND NOT EXISTS (
SELECT 1 FROM user_triggers ut
WHERE ut.table_name = a.table_name
AND Nvl(p_missing_ind,'N') = 'Y'
AND ut.trigger_name = 'JN_' || substr(a.table_name,1,27)
);


CURSOR jour_trigger_line(cp_table_name VARCHAR2) IS
SELECT
'       ,' || column_name cols,
'       ,:old.' || column_name old_vals
FROM user_tab_columns
WHERE table_name = cp_table_name;

 lv2_sql VARCHAR2(32000);

BEGIN

   IF p_target <> 'CREATE' THEN

      DELETE t_temptext
      WHERE id = 'JOUR';

   END IF;

   FOR CurTab IN jour_trigger LOOP

      pv_lines.delete;

      lv2_sql := CurTab.trigger_def || CHR(10);

      FOR CurCol IN jour_trigger_line(CurTab.table_name) LOOP

         lv2_sql := lv2_sql || CurCol.cols || CHR(10);

      END LOOP;

      lv2_sql := lv2_sql || ')' || CHR(10);
      lv2_sql := lv2_sql || '   VALUES ' || CHR(10);
      lv2_sql := lv2_sql || '      (lv2_operation, lv2_last_updated_by, EcDp_Date_Time.getCurrentSysdate, EcDp_User_Session.getUserSessionParameter(''JN_NOTES'') ' || CHR(10);

      FOR CurCol IN jour_trigger_line(CurTab.table_name) LOOP

         lv2_sql := lv2_sql || CurCol.old_vals || CHR(10);

      END LOOP;
      lv2_sql := lv2_sql || ');' || CHR(10);
      lv2_sql := lv2_sql || 'END IF;' || CHR(10);
      lv2_sql := lv2_sql || 'END;';

      EcDp_Dynsql.AddSqlLine(pv_lines,  lv2_sql);

      Ecdp_Dynsql.SafeBuild('JN_' || substr(CurTab.table_name,1,25),'TRIGGER',pv_lines,p_target,'JOUR','Y');

   END LOOP;

END journalTriggers;


----------------------------------------------------------------------------------
-- Procedure:   get_table_colums
-- Author:              Roar Jørstad
-- Purpose:     return a string with columns defined for table P_TABLE in
--             USER_TAB_COLUMNS with delimiter set to P_DELIMITER as separator
--             between each column. Columns in list P_EXCEPT_COLS will not be
--             included in the return string
-- Parameters:
--        p_table                       Table which you want to retrive columns information
--        p_delimiter           Character that is used to separate columns
--   p_except_cols      List of columns that should NOT be included in return string
--   p_trunc_length  Maximum column length you want want the columns to be. Useful
--                   in generate function where you need extra characters for
--                   prefix and postfix information.
----------------------------------------------------------------------------------
FUNCTION get_table_colums(p_table     VARCHAR2
                          ,p_delimiter VARCHAR2
                          ,p_except_cols VARCHAR2 DEFAULT NULL
                          ,p_trunc_length NUMBER DEFAULT 30)
RETURN VARCHAR2 IS
        CURSOR c_columns(cp_table VARCHAR2) IS
        SELECT * FROM user_tab_columns
        WHERE table_name = cp_table
        ORDER BY column_id ;

        lv2_columns VARCHAR2(2000) ;
        include_col NUMBER ;
BEGIN
        -- Loop through all columns defined for table
        FOR table_column IN c_columns(p_table) LOOP
                -- Variable include_col will contain 0 if the current cursor
                -- column doesn't appears in the string with columns that should
                -- not be included in return string.
                include_col:= INSTR(p_except_cols,table_column.COLUMN_NAME) ;

                -- Do nothing if the column name exists in the exclude string or
                -- the exclude string is NULL
                IF (include_col IS NULL) OR (include_col = 0) THEN
                        table_column.COLUMN_NAME:= substr(table_column.COLUMN_NAME,1,p_trunc_length) ;
                        IF NOT lv2_columns IS NULL THEN
                        -- If the column string already contains a column, add a delimiter
                        -- character
                                lv2_columns:= RTRIM(LTRIM(lv2_columns)) || RTRIM(LTRIM(p_delimiter)) ;
                        END IF ;

                        -- Add table column to string
                        lv2_columns:= RTRIM(LTRIM(lv2_columns)) || RTRIM(LTRIM(table_column.COLUMN_NAME)) ;
                END IF;
        END LOOP;

        -- Return colums
        RETURN lv2_columns ;
END get_table_colums ;



-- --------------------------------------------------------------------------------
-- Procedure : table_exist
-- Purpose   : Returns true if table 'p_table' exist in database. Otherwise false is returned
-- Author:              Roar Jørstad
-- --------------------------------------------------------------------------------
FUNCTION table_exist(p_table_name VARCHAR2)
RETURN BOOLEAN IS

   CURSOR c_tables IS
   SELECT *
   FROM user_tables
   WHERE table_name = UPPER(p_table_name);

   lb_ret_val BOOLEAN;

BEGIN

        FOR cur_rcc IN c_tables LOOP

                lb_ret_val := TRUE;

        END LOOP;

        RETURN lb_ret_val;

END table_exist ;


-- --------------------------------------------------------------------------------
-- Function : has_table_constraint
-- Purpose  : True if the table has a constraint of the given type.
-- Author:              Roar Jørstad
-- --------------------------------------------------------------------------------
FUNCTION has_table_constraint(p_table_name VARCHAR2, p_constraint_type VARCHAR2)
RETURN BOOLEAN IS

        CURSOR c_cons_type IS
        SELECT *
        FROM user_constraints
   WHERE table_name = p_table_name
        AND constraint_type = p_constraint_type;

   lb_ret_val BOOLEAN;

BEGIN

        FOR cons IN c_cons_type LOOP

      lb_ret_val := TRUE;

        END LOOP;

        RETURN lb_ret_val;

END has_table_constraint ;

----------------------------------------------------------------------------------
-- Procedure : initiate
-- Purpose   : Delete the content in table 't_temptext' if p_append = 'APPEND',
--             otherwise the line number variabel is set to largest existing number
----------------------------------------------------------------------------------
PROCEDURE initiate(p_append VARCHAR2) IS

ln_line NUMBER;

BEGIN
   IF Upper(p_append) = 'APPEND' THEN
      SELECT  Max(line_number)
      INTO   ln_line
      FROM   t_temptext
      WHERE  id = 'EC_PACKAGES';
   ELSE
      ln_line := 0;
      DELETE FROM t_temptext
      WHERE id ='EC_PACKAGES';
   END IF;

   pv_line_number := ln_line;

END initiate;
-- End procedure



----------------------------------------------------------------------------------
-- Function : getFunctionName
-- Purpose  : Returns valid function name
----------------------------------------------------------------------------------
FUNCTION getFunctionName(p_table  VARCHAR2,
                         p_column VARCHAR2) RETURN VARCHAR2 IS

CURSOR c_alias_name IS
SELECT alias_name
FROM   CTRL_GEN_FUNCTION
WHERE  table_name = p_table
AND    column_name = p_column;

lv2_alias VARCHAR2(30);
lv2_column VARCHAR2(30);

BEGIN

  lv2_column := p_column;

  FOR mycur IN c_alias_name LOOP
    lv2_alias := mycur.alias_name;
  END LOOP;

  return Nvl(Lower(lv2_alias), Lower(lv2_column));
END;
--End function

-- --------------------------------------------------------------------------------
-- Procedure : column_exist
-- Purpose   : Returns 1 if table 'p_table' exist in database. Otherwise 0 is returned
-- Author:              Roar Jørstad
-- --------------------------------------------------------------------------------
FUNCTION column_exist(p_table VARCHAR2, p_column VARCHAR2)
RETURN NUMBER IS
        CURSOR c_table_column(p_table_1 VARCHAR2, p_column_1 VARCHAR2) IS
        SELECT DISTINCT t.table_name, t.column_name FROM user_tab_columns t
        WHERE UPPER(t.table_name)  = UPPER(p_table_1)
          AND UPPER(t.column_name) = UPPER(p_column_1) ;

        col_sts NUMBER ;
BEGIN
        col_sts:= 0 ;

        FOR fk_cols IN c_table_column(p_table, p_column) LOOP
                col_sts:= 1 ;
        END LOOP;

        RETURN col_sts ;
END column_exist ;




-- --------------------------------------------------------------------------------
-- Procedure : get_pk_param_list
-- Purpose   : This functions returns a list of all primary key columns for given
--             system and table as a parameter list with specified delimiter
-- Author:              Roar Jørstad
-- --------------------------------------------------------------------------------
FUNCTION get_pk_param_list(
                                 p_table VARCHAR2
                                ,p_delimiter VARCHAR2
            ,p_except_cols VARCHAR2 DEFAULT NULL
                                ,p_param_prefix VARCHAR2 DEFAULT 'p_'
                                ,p_param_postfix VARCHAR2 DEFAULT NULL
) RETURN VARCHAR2
IS
        lv2_columns VARCHAR2(1000) ;
        lv2_param VARCHAR2(50) ;
        lv2_datatype VARCHAR2(50) ;
        ln_include_col NUMBER ;
BEGIN
        lv2_columns:= NULL;             -- initialize return string

        -- loop all PK columns for table
        FOR pk_cols IN c_qualifier_list(p_table) LOOP

                lv2_param := LOWER(p_param_prefix) || LOWER(RTRIM(LTRIM(pk_cols.column_name))) || LOWER(p_param_postfix) ;
                lv2_datatype:= UPPER(RTRIM(LTRIM(pk_cols.column_type))) ;
                ln_include_col:= INSTR(p_except_cols,pk_cols.COLUMN_NAME) ;

                -- If p_except_cols parameter is null or current column it not in except-list
                IF (ln_include_col IS NULL) OR (ln_include_col = 0) THEN
                        IF NOT lv2_columns IS NULL THEN
                                -- add delimiter if not the fist iteration in loop
                                lv2_columns:= RTRIM(LTRIM(lv2_columns)) || p_delimiter ;
                        END IF ;

                        -- add column name and datatype
                        lv2_columns:= RTRIM(LTRIM(lv2_columns)) || lv2_param || ' ' || lv2_datatype;
                END IF;
        END LOOP;

        -- return parameter list
        RETURN lv2_columns;
END get_pk_param_list ;

-- --------------------------------------------------------------------------------
-- Procedure : get_pk_where_clause
-- Purpose   : This functions returns a list of all primary key columns for given
--             system and table as a parameter list with specified delimiter
-- Author:              Roar Jørstad
-- --------------------------------------------------------------------------------
FUNCTION get_pk_where_clause(
                                 p_table VARCHAR2
                                ,p_delimiter VARCHAR2
            ,p_except_cols VARCHAR2 DEFAULT NULL
                                ,p_table_alias VARCHAR2 DEFAULT NULL
                                ,p_param_prefix VARCHAR2 DEFAULT 'p_'
                                ,p_param_postfix VARCHAR2 DEFAULT NULL
)
RETURN VARCHAR2 IS
        CURSOR c_key_cols(p_table_1 VARCHAR2) IS
--RRA
        SELECT t.column_name, t.data_type FROM user_tab_columns t
        WHERE t.table_name  = p_table_1
          AND EXISTS(SELECT 1 FROM user_cons_columns c
                                        WHERE c.table_name = t.table_name
                                        AND c.column_name = t.column_name
                                        AND c.constraint_name LIKE 'PK%' )
        ORDER BY column_id;

        lv2_where_clause VARCHAR2(1000) ;
        lv2_param VARCHAR2(50) ;
        lv2_column VARCHAR2(50) ;
        ln_include_col NUMBER ;
BEGIN
        lv2_where_clause:= NULL;                -- initialize return string

        -- loop all PK columns for table
        FOR pk_cols IN c_key_cols(p_table) LOOP
                lv2_param := LOWER(p_param_prefix) || LOWER(pk_cols.column_name) || LOWER(p_param_postfix) ;
                lv2_column:= LOWER(p_table_alias) || '.' || LOWER(pk_cols.column_name) ;
                ln_include_col:= INSTR(p_except_cols,pk_cols.COLUMN_NAME) ;

                -- If p_except_cols parameter is null or current column it not in except-list
                IF (ln_include_col IS NULL) OR (ln_include_col = 0) THEN
                        IF lv2_where_clause IS NULL THEN
                                lv2_where_clause := 'WHERE ' || lv2_column || ' = ' || lv2_param ;
                        ELSE
                                lv2_where_clause := lv2_where_clause || chr(10) || 'AND ' || lv2_column || ' = ' || lv2_param ;
                        END IF;
                END IF;
        END LOOP;

        -- return parameter list
        RETURN lv2_where_clause;
END get_pk_where_clause ;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : writeObjectIdFunction
-- Description    : This procedure creates object_id_by_uk function code. Generated for tables
--                  with a primary key constraint consisting of OBJECT_ID and any related
--                  unique key constraint with at least OBJECT_CODE in it.
-- Postconditions :
--
-- Using tables   : user_constraints
--                  user_tab_columns
--                  user_cons_columns
--                  ctrl_object
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Creates package header or body code.
--
---------------------------------------------------------------------------------------------------
PROCEDURE writeObjectIdFunction(p_table_name VARCHAR2, p_package_part VARCHAR2, p_target VARCHAR2)
--</EC-DOC>
IS


CURSOR c_object_ID_function(cp_table VARCHAR2) IS
SELECT *
FROM  ctrl_object o
WHERE o.object_name= cp_table
AND o.view_pk_table_name IS NULL
AND 1 = (SELECT count(*) -- Primay key constraint must contain OBJECT_ID only.
         FROM user_constraints uc, user_cons_columns ucc, user_cons_columns ucc2
         WHERE ucc.owner = uc.owner
         AND ucc.table_name = uc.table_name
         AND ucc.constraint_name = uc.constraint_name
         AND uc.table_name = o.object_name
         AND uc.constraint_type = 'P'
         AND ucc.column_name = 'OBJECT_ID'
         AND ucc2.owner = uc.owner
         AND ucc2.table_name = uc.table_name
         AND ucc2.constraint_name = uc.constraint_name)
AND EXISTS (
         SELECT * -- Must have at least OBJECT_CODE in an unique key constraint
         FROM user_constraints uk, user_cons_columns ukc
         WHERE ukc.owner = uk.owner
         AND ukc.table_name = uk.table_name
         AND ukc.constraint_name = uk.constraint_name
         AND uk.table_name = o.object_name
         AND uk.constraint_type = 'U'
         AND ukc.column_name = 'OBJECT_CODE'
);

-- Get the unique constraint columns where OBJECT_CODE is among them
CURSOR   c_uk_qualifier_list(cp_table_name VARCHAR2) IS
SELECT   ucc.column_name,
         Nvl(utc.data_type,'VARCHAR2') column_type
FROM     user_constraints uc,
         user_cons_columns ucc,
         user_cons_columns ucc2,
         user_tab_columns utc
WHERE    uc.table_name = cp_table_name
AND      uc.constraint_type = 'U'
AND      ucc.owner = uc.owner
AND      ucc.constraint_name = uc.constraint_name
AND      ucc.table_name = uc.table_name
AND      utc.table_name = uc.table_name
AND      utc.column_name = ucc.column_name
AND      ucc2.owner = ucc.owner
AND      ucc2.constraint_name = ucc.constraint_name
AND      ucc2.table_name = ucc.table_name
AND      ucc2.column_name = 'OBJECT_CODE'
AND      utc.column_name <> 'SUMMER_TIME'
ORDER BY ucc.position;

lv2_parameter_list  VARCHAR2(2000);
lv2_cur_par_list    VARCHAR2(2000);
lv2_cur_call_list   VARCHAR2(2000);
lv2_qualifier_list  VARCHAR2(2000);
lv2_plsql_code      VARCHAR2(4000);
BEGIN

   IF p_package_part = 'HEAD' THEN

      FOR cur_tab_rec IN c_object_ID_function(p_table_name) LOOP

         lv2_parameter_list := NULL;

         FOR cur_rec IN c_uk_qualifier_list(p_table_name) LOOP

            IF c_uk_qualifier_list%ROWCOUNT = 1 THEN
               lv2_parameter_list := 'p_' || LOWER(cur_rec.column_name) || ' ' || cur_rec.column_type;
            ELSE
               lv2_parameter_list := lv2_parameter_list || ', p_' || LOWER(cur_rec.column_name) || ' ' || cur_rec.column_type;
            END IF;

         END LOOP;

         IF lv2_parameter_list IS NOT NULL THEN

            -- Function object-ID by code interface and pragma settings
            lv2_plsql_code := 'FUNCTION object_id_by_uk(' || lv2_parameter_list || ') RETURN ' || p_table_name ||'.OBJECT_ID%TYPE;' || chr(10) ||
                              'PRAGMA RESTRICT_REFERENCES (object_id_by_uk ' || ', WNDS, WNPS, RNPS);';
            createTextLine('  ', p_target);
            createTextLine(lv2_plsql_code, p_target);

         END IF;

      END LOOP;

   ELSIF p_package_part = 'BODY' THEN

      FOR cur_tab_rec IN c_object_ID_function(p_table_name) LOOP

         lv2_parameter_list := NULL;
         lv2_cur_par_list   := NULL;
         lv2_cur_call_list  := NULL;
         lv2_qualifier_list := NULL;

         FOR cur_rec IN c_uk_qualifier_list(p_table_name) LOOP

            IF c_uk_qualifier_list%ROWCOUNT = 1 THEN
               lv2_parameter_list := 'p_' || LOWER(cur_rec.column_name) || ' ' || cur_rec.column_type;
               lv2_cur_par_list   := 'cp_' || LOWER(cur_rec.column_name) || ' ' || cur_rec.column_type;
               lv2_cur_call_list  := 'p_' || LOWER(cur_rec.column_name);
               lv2_qualifier_list := LOWER(cur_rec.column_name) || ' = cp_' || LOWER(cur_rec.column_name);
            ELSE
               lv2_parameter_list := lv2_parameter_list || ', p_' || LOWER(cur_rec.column_name) || ' ' || cur_rec.column_type;
               lv2_cur_par_list   := lv2_cur_par_list || ', cp_' || LOWER(cur_rec.column_name) || ' ' || cur_rec.column_type;
               lv2_cur_call_list  := lv2_cur_call_list || ', p_' || LOWER(cur_rec.column_name);
               lv2_qualifier_list := lv2_qualifier_list || CHR(10) || '   AND ' || LOWER(cur_rec.column_name) || ' = cp_' || LOWER(cur_rec.column_name);
            END IF;

         END LOOP;

         IF lv2_parameter_list IS NOT NULL THEN

            lv2_plsql_code := 'FUNCTION object_id_by_uk(' || lv2_parameter_list || ')' || CHR(10) ||
                              'RETURN ' || p_table_name ||'.OBJECT_ID%TYPE' || CHR(10) ||
                              'IS' || CHR(10) ||
                              '   v_return_val ' || p_table_name || '.OBJECT_ID%TYPE;' || CHR(10) ||
                              '   CURSOR c_col_val(' || lv2_cur_par_list || ') IS' || CHR(10) ||
                              '   SELECT object_id col' || CHR(10) ||
                              '   FROM ' || p_table_name || CHR(10) ||
                              '   WHERE ' || lv2_qualifier_list || ';' || CHR(10) ||
                              'BEGIN' || CHR(10) ||
                              '   FOR cur_row IN c_col_val(' || lv2_cur_call_list || ') LOOP' || CHR(10) ||
                              '      v_return_val := cur_row.col;' || CHR(10) ||
                              '   END LOOP;' || CHR(10) ||
                              '   RETURN v_return_val;' || CHR(10) ||
                              'END object_id_by_uk;' || CHR(10);

            createTextLine('  ', p_target);
            createTextLine(lv2_plsql_code, p_target);

         END IF;

      END LOOP;

   END IF;

END writeObjectIdFunction;



----------------------------------------------------------------------------------
-- Procedure : wtitePackageHeader
-- Purpose   : Writes the header of the package
----------------------------------------------------------------------------------
PROCEDURE writePackageHeader(p_object_name        VARCHAR2,
                             p_view_pk_table_name VARCHAR2,
                             p_target VARCHAR2 DEFAULT 'CREATE'
                             ) IS

-- Local variables used in procedure
lv2_parameter_list          VARCHAR2(2000);
lv2_parameter_list_x        VARCHAR2(2000);
lv2_parameter_list_oper     VARCHAR2(2000); -- Parameter list included v_compare_operator DEFAULT '='
lv2_parameter_list_period   VARCHAR2(2000); -- Parameter list to be used calling period function
lv2_parameter_list_count    VARCHAR2(2000); -- Parameter list to be used calling count_rows function
lv2_parameter_list_n_rows   VARCHAR2(2000); -- Parameter list to be used calling prev or next daytime
lv2_parameter_list_attrib   VARCHAR2(2000); -- Parameter list to be used calling attribute functions
lv2_package_name            VARCHAR2(30);
lv2_table_name              VARCHAR2(32);
lv2_parent_table            VARCHAR2(32);
lv2_daytime                 VARCHAR2(1);
lv2_summet_time_flag        VARCHAR2(1);
lv2_parameter_list_oper_s   VARCHAR2(2000);
lv2_parameter_list_s   VARCHAR2(2000);

ln_func_l                   NUMBER := 25;
ln_package_l                NUMBER := 28;


-- Local cursors used in procedure

-- Count function interface and pragma settings
CURSOR count_function (p_table            VARCHAR2,
                       p_parameter_list VARCHAR2) IS
SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'FUNCTION count_rows' || p_parameter_list ||' RETURN NUMBER;' line,
'PRAGMA RESTRICT_REFERENCES (count_rows, WNDS, WNPS, RNPS);' pragma
FROM   ctrl_object
WHERE  ctrl_object.object_name = p_table
AND    ctrl_object.math = 'Y'
AND    EXISTS
      (SELECT ucc.column_name
       FROM   user_constraints uc,
              user_cons_columns ucc
       WHERE  uc.table_name = p_table
       AND    uc.constraint_type = 'P'
       AND    ucc.owner = uc.owner
       AND    ucc.constraint_name = uc.constraint_name
       AND    ucc.table_name = uc.table_name
       AND    ucc.column_name = 'DAYTIME');




-- Math function interface and pragma settings
CURSOR math_function(p_table          VARCHAR2,
                     p_parameter_list VARCHAR2) IS
SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'FUNCTION math_' || getFunctionName(p_table, column_name) || p_parameter_list || ' RETURN NUMBER;' line,
'PRAGMA RESTRICT_REFERENCES (math_' || getFunctionName(p_table, column_name) || ', WNDS, WNPS, RNPS);' pragma
FROM   ctrl_object,
       user_tab_columns
WHERE  ctrl_object.object_name = p_table
AND    ctrl_object.math = 'Y'
AND    ctrl_object.object_name = user_tab_columns.table_name
AND    data_type = 'NUMBER'
AND    user_tab_columns.column_name <> 'REV_NO'
AND    EXISTS
      (SELECT ucc.column_name
       FROM   user_constraints uc,
              user_cons_columns ucc
       WHERE  uc.table_name = p_table
       AND    uc.constraint_type = 'P'
       AND    ucc.owner = uc.owner
       AND    ucc.constraint_name = uc.constraint_name
       AND    ucc.table_name = uc.table_name
       AND    ucc.column_name = 'DAYTIME');



-- Cum function interface and pragma settings
CURSOR cum_function(p_table          VARCHAR2,
                    p_parameter_list VARCHAR2,
                    p_type           VARCHAR2) IS
SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'FUNCTION cum' || Lower(p_type) || '_' || getFunctionName(p_table, column_name) || p_parameter_list || ' RETURN NUMBER;' line,
'PRAGMA RESTRICT_REFERENCES (cum' || Lower(p_type) || '_' || getFunctionName(p_table, column_name) || ', WNDS, WNPS, RNPS);' pragma
FROM  ctrl_gen_function
WHERE table_name = p_table
AND   calc_type IN ('COLUMN','CALC')
AND   (decode(mtd_cumulative,'Y','M',null) = p_type
OR    decode(ytd_cumulative,'Y','Y',null) = p_type
OR    decode(ttd_cumulative,'Y','T',null) = p_type );



-- Avg function interface and pragma settings
CURSOR ave_function(p_table          VARCHAR2,
                    p_parameter_list VARCHAR2,
                    p_type           VARCHAR2) IS
SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'FUNCTION ave' || Lower(p_type) || '_' || getFunctionName(p_table, column_name) || p_parameter_list || ' RETURN NUMBER;' line,
'PRAGMA RESTRICT_REFERENCES (ave' || Lower(p_type) || '_' || getFunctionName(p_table, column_name) || ', WNDS, WNPS, RNPS);' pragma
FROM  ctrl_gen_function
WHERE table_name = p_table
AND   calc_type IN ('COLUMN','CALC')
AND   (decode(mtd_average,'Y','M',null) = p_type
OR    decode(ytd_average,'Y','Y',null) = p_type
OR    decode(ttd_average,'Y','T',null) = p_type );



-- Function prev_daytime interface and pragma settings
CURSOR prev_daytime_function(p_table          VARCHAR2,
                             p_parameter_list VARCHAR2) IS
SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'FUNCTION prev_' || Lower(Substr(column_name,1,ln_func_l)) || p_parameter_list || ' RETURN DATE;' line,
'PRAGMA RESTRICT_REFERENCES (prev_' || Lower(Substr(column_name,1,ln_func_l)) || ', WNDS, WNPS, RNPS);' pragma
FROM  user_tab_columns
WHERE table_name = p_table
AND   column_name = 'DAYTIME';


-- Function prev_equal_daytime interface and pragma settings
CURSOR prev_equal_daytime_function(p_table          VARCHAR2,
                                   p_parameter_list VARCHAR2) IS
SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'FUNCTION prev_equal_' || Lower(Substr(column_name,1,ln_func_l)) || p_parameter_list || ' RETURN DATE;' line,
'PRAGMA RESTRICT_REFERENCES (prev_equal_' || Lower(Substr(column_name,1,ln_func_l)) || ', WNDS, WNPS, RNPS);' pragma
FROM  user_tab_columns
WHERE table_name = p_table
AND  column_name = 'DAYTIME';


-- Function next_daytime interface and pragma settings
CURSOR next_daytime_function(p_table                            VARCHAR2,
                             p_parameter_list   VARCHAR2) IS
SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'FUNCTION next_' || Lower(Substr(column_name,1,ln_func_l)) || p_parameter_list || ' RETURN DATE;' line,
'PRAGMA RESTRICT_REFERENCES (next_' || Lower(Substr(column_name,1,ln_func_l)) || ', WNDS, WNPS, RNPS);' pragma
FROM  user_tab_columns
WHERE table_name = p_table
AND   column_name = 'DAYTIME';


-- Function next_equal_daytime interface and pragma settings
CURSOR next_equal_daytime_function(p_table          VARCHAR2,
                                   p_parameter_list VARCHAR2) IS
SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'FUNCTION next_equal_' || Lower(Substr(column_name,1,ln_func_l)) || p_parameter_list || ' RETURN DATE;' line,
'PRAGMA RESTRICT_REFERENCES (next_equal_' || Lower(Substr(column_name,1,ln_func_l)) || ', WNDS, WNPS, RNPS);' pragma
FROM  user_tab_columns
WHERE table_name = p_table
AND   column_name = 'DAYTIME';


-- Function rowtype interface and pragma settings
CURSOR rowtype_object_function(p_table VARCHAR2) IS
SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'FUNCTION row_by_object_id(p_object_id VARCHAR2) RETURN ' || p_table ||'%ROWTYPE;' line,
'PRAGMA RESTRICT_REFERENCES (row_by_object_id ' || ', WNDS, WNPS, RNPS);' pragma
FROM  ctrl_object co
WHERE co.object_name = p_table
AND   co.view_pk_table_name IS NULL
AND 1 = (SELECT count(*)
         FROM user_constraints uc, user_cons_columns ucc, user_cons_columns ucc2
         WHERE uc.table_name = co.object_name
         AND (uc.constraint_type = 'U' OR uc.constraint_type = 'P')
         AND ucc.owner = uc.owner
         AND ucc.table_name = uc.table_name
         AND ucc.constraint_name = uc.constraint_name
         AND ucc.column_name = 'OBJECT_ID'
         AND ucc2.owner = uc.owner
         AND ucc2.table_name = uc.table_name
         AND ucc2.constraint_name = uc.constraint_name);

-- Function rowtype interface and pragma settings
CURSOR rowtype_function(p_table          VARCHAR2,
                        p_parameter_list VARCHAR2) IS
SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'FUNCTION row_by_pk ' || p_parameter_list || ' RETURN ' || p_table ||'%ROWTYPE;' line,
'PRAGMA RESTRICT_REFERENCES (row_by_pk ' || ', WNDS, WNPS, RNPS);' pragma
FROM  ctrl_object
WHERE object_name=p_table
AND   view_pk_table_name IS NULL;

-- Function attribute interface and pragma settings
CURSOR attribute_function(p_table          VARCHAR2,
                          p_parameter_list VARCHAR2) IS
SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'FUNCTION attribute_text_by_id ' || p_parameter_list || ' RETURN ' || p_table ||'.ATTRIBUTE_TEXT%TYPE;' line,
'PRAGMA RESTRICT_REFERENCES (attribute_text_by_id ' || ', WNDS, WNPS, RNPS);' pragma
FROM  ctrl_object co
WHERE co.object_name=p_table
AND   co.view_pk_table_name IS NULL
AND EXISTS (
SELECT 1 FROM user_tab_columns utc
WHERE utc.table_name = co.object_name
AND utc.column_name = 'ATTRIBUTE_TEXT'
);


-- Function coltype interface and pragma settings
CURSOR coltype_function(p_pk_table       VARCHAR2,
                        p_table          VARCHAR2,
                        p_parameter_list VARCHAR2) IS
SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'FUNCTION ' || getFunctionName(p_table, utc.column_name) || p_parameter_list || ' RETURN ' || p_table || '.' || utc.column_name || '%TYPE;' line,
'PRAGMA RESTRICT_REFERENCES (' || getFunctionName(p_table, utc.column_name) || ', WNDS, WNPS, RNPS);' pragma
FROM user_tab_columns utc
WHERE utc.table_name = p_table
AND utc.column_name NOT IN ('REV_NO','REV_TEXT','CREATED_BY','CREATED_DATE','LAST_UPDATED_BY','LAST_UPDATED_DATE')
AND NOT EXISTS (
   SELECT 1
   FROM user_cons_columns ucc, user_constraints uc
   WHERE uc.constraint_name = ucc.constraint_name
   AND uc.table_name = ucc.table_name
   AND uc.owner = ucc.owner
   AND ucc.column_name = utc.column_name
   AND uc.table_name= p_pk_table
   AND uc.constraint_type = 'P');

-- Function common_cur interface and pragma settings
CURSOR common_cur_function(p_table                 VARCHAR2,
                           p_parameter_list_cursor VARCHAR2) IS
SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'FUNCTION row_by_rel_operator' || p_parameter_list_cursor || ' RETURN ' || p_table || '%ROWTYPE;' line,
'PRAGMA RESTRICT_REFERENCES (row_by_rel_operator' || ', WNDS, WNPS, RNPS);' pragma
FROM  user_tab_columns
WHERE table_name = p_table
AND   column_name = 'DAYTIME';

-- Start procedure
BEGIN
        pv_lines.delete;

        lv2_package_name := lower(substr(p_object_name,1,ln_package_l));

        ------------------------------------------------------------
        -- CREATE PACKAGE HEADER
        ------------------------------------------------------------
        createTextLine('  ',p_target);
        createTextLine('  ',p_target);
        IF p_target <> 'CREATE' THEN
          createTextLine('PROMPT Creating package header ' || UPPER(lv2_package_name) || ';',p_target);
        END IF;
        createTextLine('CREATE OR REPLACE PACKAGE ec_' || lv2_package_name || ' IS',p_target);
        createTextLine('------------------------------------------------------------------------------------',p_target);
        createTextLine('-- Package: ec_' || lv2_package_name ,p_target);
        createTextLine('-- Generated by EC_GENERATE.',p_target);
        createTextLine('  ',p_target);
        createTextLine('-- DO NOT MODIFY THIS PACKAGE! Changes will be lost when the package is regenerated.',p_target);
        createTextLine('-- Packages named pck_<component> will hold all manual written common code.         ',p_target);
        createTextLine('-- Packages named <sysnam>_<component> will hold all code not beeing common.        ',p_target);
        createTextLine('------------------------------------------------------------------------------------',p_target);
        createTextLine('  ',p_target);

        lv2_table_name := Nvl(p_view_pk_table_name, p_object_name);
        lv2_parameter_list := Null;
        lv2_daytime := 'N';
        lv2_summet_time_flag := 'N';

        -----------------------------------------------------------
        -- BUILD LIST OF COLUMNS BEING PART OF PK
        -----------------------------------------------------------
        FOR qualify_cur IN c_qualifier_list(lv2_table_name) LOOP
               IF qualify_cur.column_name = 'SUMMER_TIME' THEN
                  lv2_summet_time_flag := 'Y';
               ELSE

                 IF lv2_parameter_list IS NULL THEN
                        lv2_parameter_list := chr(10) || '         p_' || Lower(qualify_cur.column_name) || ' ' || qualify_cur.column_type;
                 ELSE
                        lv2_parameter_list := lv2_parameter_list || ',' || chr(10) || '         p_' || Lower(qualify_cur.column_name) || ' ' || qualify_cur.column_type;
                 END IF;

                 IF Lower(qualify_cur.column_name) = 'daytime' THEN
                        lv2_daytime := 'Y';
                 ELSE
                         IF lv2_parameter_list_period IS NULL THEN
                                lv2_parameter_list_period := chr(10) || '         p_' || Lower(qualify_cur.column_name) || ' ' || qualify_cur.column_type;
                         ELSE
                                 lv2_parameter_list_period := lv2_parameter_list_period || ',' || chr(10) || '         p_' || Lower(qualify_cur.column_name) || ' ' || qualify_cur.column_type;
                         END IF;

                         IF lv2_parameter_list_count IS NULL THEN
                                lv2_parameter_list_count := chr(10) || '         p_' || Lower(qualify_cur.column_name) || ' ' || qualify_cur.column_type;
                         ELSE
                                lv2_parameter_list_count := lv2_parameter_list_count || ',' || chr(10) || '         p_' || Lower(qualify_cur.column_name) || ' ' || qualify_cur.column_type;
                         END IF;

                 END IF;
               END IF;
        END LOOP;

        IF lv2_parameter_list IS NOT NULL THEN
                lv2_parameter_list_x := '(' || lv2_parameter_list || ',' || chr(10) || '         p_daytime2 DATE )';
                lv2_parameter_list_oper := '(' || lv2_parameter_list || ',' || chr(10) || '         p_compare_oper VARCHAR2 DEFAULT ''='')';
                lv2_parameter_list_period := '(' || lv2_parameter_list_period || ',' || chr(10) || '         p_from_day DATE,' || chr(10) || '         p_to_day DATE,' || chr(10) || '         p_method VARCHAR2 DEFAULT ''SUM'')';
                lv2_parameter_list_count := '(' || lv2_parameter_list_count || ',' || chr(10) || '         p_from_day DATE,' || chr(10) || '         p_to_day DATE)';
                lv2_parameter_list_n_rows := '(' || lv2_parameter_list || ',' || chr(10) || '         p_num_rows NUMBER DEFAULT 1' || ')';
                lv2_parameter_list   := '(' || lv2_parameter_list || ')';
        END IF;

        ------------------------------------------------------------
        -- CREATE FUNCTION SPECIFICATION AND PRAGMA
        ------------------------------------------------------------

        ------------------------------------------------------------
        -- count_rows
        ------------------------------------------------------------

        FOR function_cursor IN count_function(p_object_name, lv2_parameter_list_count) LOOP
                createTextLine(function_cursor.line,p_target);
                createTextLine(function_cursor.pragma,p_target);
        END LOOP;


        ------------------------------------------------------------
        -- Math function
        ------------------------------------------------------------

        FOR function_cursor IN math_function(p_object_name, lv2_parameter_list_period) LOOP
                createTextLine(function_cursor.line,p_target);
                createTextLine(function_cursor.pragma,p_target);
        END LOOP;


        ------------------------------------------------------------
        -- cummulative
        ------------------------------------------------------------
        FOR function_cursor IN cum_function(p_object_name, lv2_parameter_list, 'M') LOOP
                createTextLine(function_cursor.line,p_target);
                createTextLine(function_cursor.pragma,p_target);
        END LOOP;

        FOR function_cursor IN cum_function(p_object_name, lv2_parameter_list, 'Y') LOOP
                createTextLine(function_cursor.line,p_target);
                createTextLine(function_cursor.pragma,p_target);
        END LOOP;

        FOR function_cursor IN cum_function(p_object_name, lv2_parameter_list, 'T') LOOP
                createTextLine(function_cursor.line,p_target);
                createTextLine(function_cursor.pragma,p_target);
        END LOOP;


        ------------------------------------------------------------
        -- average
        ------------------------------------------------------------
        FOR function_cursor IN ave_function(p_object_name, lv2_parameter_list, 'M') LOOP
                createTextLine(function_cursor.line,p_target);
                createTextLine(function_cursor.pragma,p_target);
        END LOOP;

        FOR function_cursor IN ave_function(p_object_name, lv2_parameter_list, 'Y') LOOP
                createTextLine(function_cursor.line,p_target);
                createTextLine(function_cursor.pragma,p_target);
        END LOOP;

        FOR function_cursor IN ave_function(p_object_name, lv2_parameter_list, 'T') LOOP
                createTextLine(function_cursor.line,p_target);
                createTextLine(function_cursor.pragma,p_target);
        END LOOP;


        ------------------------------------------------------------
        -- prev_daytime
        ------------------------------------------------------------

        FOR function_cursor IN prev_daytime_function(p_object_name, lv2_parameter_list_n_rows) LOOP
                createTextLine(function_cursor.line,p_target);
                createTextLine(function_cursor.pragma,p_target);
        END LOOP;

        ------------------------------------------------------------
        -- prev_equal_daytime
        ------------------------------------------------------------

        FOR function_cursor IN prev_equal_daytime_function(p_object_name, lv2_parameter_list_n_rows) LOOP
                createTextLine(function_cursor.line,p_target);
                createTextLine(function_cursor.pragma,p_target);
        END LOOP;


        ------------------------------------------------------------
        -- next_daytime
        ------------------------------------------------------------

        FOR function_cursor IN next_daytime_function(p_object_name, lv2_parameter_list_n_rows) LOOP
                createTextLine(function_cursor.line,p_target);
                createTextLine(function_cursor.pragma,p_target);
        END LOOP;

        ------------------------------------------------------------
        -- next_equal_daytime
        ------------------------------------------------------------

        FOR function_cursor IN next_equal_daytime_function(p_object_name, lv2_parameter_list_n_rows) LOOP
                createTextLine(function_cursor.line,p_target);
                createTextLine(function_cursor.pragma,p_target);
        END LOOP;


        ------------------------------------------------------------
        -- single columns
        ------------------------------------------------------------
        writeObjectIdFunction(p_object_name, 'HEAD', p_target);

        ------------------------------------------------------------
        -- Cursor function
        ------------------------------------------------------------
        IF lv2_summet_time_flag = 'Y' then
          lv2_parameter_list_oper_s := substr(lv2_parameter_list_oper,1, LENGTH(lv2_parameter_list_oper)-1) ||','|| chr(10) || '         p_summertime VARCHAR2 DEFAULT NULL)';
          lv2_parameter_list_s := substr(lv2_parameter_list,1, LENGTH(lv2_parameter_list)-1) ||','|| chr(10) || '         p_summertime VARCHAR2 DEFAULT NULL)';
        ELSE
          lv2_parameter_list_oper_s := lv2_parameter_list_oper;
          lv2_parameter_list_s := lv2_parameter_list;
        END IF;
        IF lv2_daytime = 'Y' THEN
                FOR function_cursor IN common_cur_function(p_object_name, lv2_parameter_list_oper_s) LOOP
                        createTextLine(function_cursor.line,p_target);
                        createTextLine(function_cursor.pragma,p_target);
                END LOOP;

                FOR function_cursor IN coltype_function(lv2_table_name, p_object_name, lv2_parameter_list_oper_s) LOOP
                        createTextLine(function_cursor.line,p_target);
                        createTextLine(function_cursor.pragma,p_target);
                END LOOP;
        ELSE
                FOR function_cursor IN coltype_function(lv2_table_name, p_object_name, lv2_parameter_list_s) LOOP
                        createTextLine(function_cursor.line,p_target);
                        createTextLine(function_cursor.pragma,p_target);
                END LOOP;
        END IF;

        ------------------------------------------------------------
        -- rowtype function
        ------------------------------------------------------------
        IF lv2_daytime = 'Y' THEN

                FOR function_cursor IN rowtype_function(p_object_name, lv2_parameter_list_oper) LOOP
                        createTextLine(function_cursor.line,p_target);
                        createTextLine(function_cursor.pragma,p_target);
           END LOOP;

      -- Generate attribute fetch functions for attribute tables only

      IF RTRIM(p_object_name,'ATTRIBUTE') || 'ATTRIBUTE' = p_object_name THEN

         lv2_parent_table := getAttributeParentTable(p_object_name);

         IF lv2_parent_table IS NOT NULL THEN

            lv2_parameter_list_attrib := '(p_object_id ' || lv2_parent_table || '.object_id%TYPE, p_daytime DATE, p_attribute_type VARCHAR2, p_compare_oper VARCHAR2 DEFAULT ''='')';

                FOR function_cursor IN attribute_function(p_object_name, lv2_parameter_list_attrib) LOOP
                           createTextLine(function_cursor.line);
                           createTextLine(function_cursor.pragma);
                 END LOOP;

         END IF;

      END IF;

        ELSE
                FOR function_cursor IN rowtype_function(p_object_name, lv2_parameter_list) LOOP
                        createTextLine(function_cursor.line,p_target);
                        createTextLine(function_cursor.pragma,p_target);
        END LOOP;

                FOR function_cursor IN rowtype_object_function(p_object_name) LOOP
                        createTextLine(function_cursor.line,p_target);
                        createTextLine(function_cursor.pragma,p_target);
        END LOOP;

        END IF;

        ------------------------------------------------------------
        -- CREATE PACKAGE FOOTER
        ------------------------------------------------------------
        createTextLine('  ',p_target);
        createTextLine('END ec_' || lv2_package_name || ';',p_target);

        IF p_target = 'CREATE' THEN
          Ecdp_Dynsql.SafeBuild('EC_' || lv2_package_name,'PACKAGE',pv_lines,p_target,'Y');

        ELSE
          createTextLine('/  ',p_target);
          createTextLine('  ',p_target);
        END IF;

END writePackageHeader;
-- End procedure




----------------------------------------------------------------------------------
-- Procedure : wtitePackageBody
-- Purpose   : Writes the body of the package
----------------------------------------------------------------------------------
PROCEDURE writePackageBody(p_object_name        VARCHAR2,
                           p_view_pk_table_name VARCHAR2,
                           p_target VARCHAR2 DEFAULT 'CREATE'
                           ) IS

-- Local variables used in procedure
lv2_parameter_list              VARCHAR2(2000);
lv2_parameter_list_x            VARCHAR2(2000);
lv2_parameter_list_attrib       VARCHAR2(2000); -- Parameter list to be used calling attribute functions
lv2_parameter_list_attrib_ext   VARCHAR2(2000); -- Parameter list to be used calling attribute functions
lv2_parameter_list_oper         VARCHAR2(2000); -- Parameter list included v_compare_operator DEFAULT '='
lv2_parameter_list_cursor       VARCHAR2(2000); -- Parameter list to be used for cursor loop
lv2_par_list_cursor_func        VARCHAR2(2000); -- Parameter list to be used calling cursor function
lv2_parameter_list_period       VARCHAR2(2000); -- Parameter list to be used calling period function
lv2_parameter_list_count        VARCHAR2(2000);
lv2_parameter_list_n_rows       VARCHAR2(2000); -- Parameter list to be used calling prev or next daytime
lv2_summet_time_flag            VARCHAR2(1);
lv2_parameter_list_s            VARCHAR2(2000);
lv2_parameter_list_oper_s       VARCHAR2(2000);
lv2_parameter_list_cursor_s     VARCHAR2(2000);
lv2_par_list_cursor_func_s      VARCHAR2(2000);


lv2_where_clause_m              VARCHAR2(2000);
lv2_where_clause_y              VARCHAR2(2000);
lv2_where_clause_t              VARCHAR2(2000);
lv2_where_clause_x              VARCHAR2(2000);
lv2_where_clause_p              VARCHAR2(2000);
lv2_where_clause_n              VARCHAR2(2000);
lv2_where_clause_pe             VARCHAR2(2000);
lv2_where_clause_ne             VARCHAR2(2000);
lv2_where_clause_sub            VARCHAR2(2000);
lv2_where_clause                VARCHAR2(2000);
lv2_where_clause_per            VARCHAR2(2000);
lv2_where_clause_count          VARCHAR2(2000);
lv2_where_clause_s              VARCHAR2(2000);

lv2_daytime                     VARCHAR2(1);

lv2_daytime_clause_m            VARCHAR2(2000);
lv2_daytime_clause_y            VARCHAR2(2000);
lv2_daytime_clause_t            VARCHAR2(2000);
lv2_daytime_clause_x            VARCHAR2(2000);
lv2_daytime_clause_p            VARCHAR2(2000);
lv2_daytime_clause_n            VARCHAR2(2000);
lv2_daytime_clause_pe           VARCHAR2(2000);
lv2_daytime_clause_ne           VARCHAR2(2000);
lv2_daytime_clause              VARCHAR2(2000);
lv2_daytime_clause_sub          VARCHAR2(2000);
lv2_daytime_clause_per          VARCHAR2(2000);

lv2_table_name                  VARCHAR2(32);
lv2_parent_table                VARCHAR2(32);
ln_func_l                       NUMBER := 25;
ln_package_l                    NUMBER := 28;
lv2_package_name                VARCHAR2(30);
lb_version_table                BOOLEAN;

-- Local cursors used in procedure

-- Find if this is a version tables where we can make assumptions about end_date handling
CURSOR c_version_table(p_table_name VARCHAR2) IS
SELECT 1
FROM class c, class_db_mapping db
WHERE c.class_name = db.class_name
AND   c.class_type = 'OBJECT'
AND   db.db_object_attribute = p_table_name
AND   p_table_name LIKE '%VERSION';



-- Count function code
CURSOR count_function_code(p_table          VARCHAR2,
                           p_parameter_list VARCHAR2,
                           p_where_clause   VARCHAR2) IS

SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'FUNCTION count_rows' || p_parameter_list || chr(10) ||
'RETURN NUMBER IS ' || chr(10) || chr(10) ||
'CURSOR c_calculate IS' || chr(10) ||
'SELECT Count(*) result' || chr(10) ||
'FROM ' || p_table || chr(10) ||
p_where_clause || ';' || chr(10) || chr(10) ||
'ln_return_val NUMBER := NULL;' || chr(10) || chr(10) ||
'BEGIN ' || chr(10) ||
'   FOR mycur IN c_calculate LOOP' || chr(10) ||
'               ln_return_val := mycur.result;' || chr(10) ||
'   END LOOP;' || chr(10) ||
'   RETURN ln_return_val;' || chr(10) ||
'END count_rows ;' || chr(10) line
FROM   ctrl_object
WHERE  ctrl_object.object_name = p_table
AND    ctrl_object.math = 'Y'
AND      EXISTS
                (SELECT ucc.column_name
       FROM   user_constraints uc,
              user_cons_columns ucc
       WHERE  uc.table_name = p_table
       AND    uc.constraint_type = 'P'
       AND    ucc.constraint_name = uc.constraint_name
       AND    ucc.table_name = uc.table_name
       AND    ucc.column_name = 'DAYTIME');


-- Math function code
CURSOR math_function_code(p_table          VARCHAR2,
                            p_parameter_list VARCHAR2,
                            p_where_clause   VARCHAR2) IS

SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'FUNCTION math_' || getFunctionName(p_table, column_name) || p_parameter_list || chr(10) ||
'RETURN NUMBER IS ' || chr(10) || chr(10) ||
'CURSOR c_calculate IS' || chr(10) ||
'SELECT Decode(Upper(p_method),' || chr(10) || '              '
        || '''SUM' || ''', Sum(' || Lower(user_tab_columns.column_name) || '),' || chr(10) || '              '
        || '''AVG' || ''', Avg(' || Lower(user_tab_columns.column_name) || '),' || chr(10) || '              '
        || '''MIN' || ''', Min(' || Lower(user_tab_columns.column_name) || '),' || chr(10) || '              '
        || '''MAX' || ''', Max(' || Lower(user_tab_columns.column_name) || '),' || chr(10) || '              '
        || '''COUNT' || ''', Count(' || Lower(user_tab_columns.column_name) || '),' || chr(10) || '              '
        || 'NULL) result' || chr(10) ||
'FROM ' || user_tab_columns.table_name || chr(10) ||
p_where_clause || ';' || chr(10) || chr(10) ||
'ln_return_val NUMBER := NULL;' || chr(10) || chr(10) ||
'BEGIN ' || chr(10) ||
'   FOR mycur IN c_calculate LOOP' || chr(10) ||
'               ln_return_val := mycur.result;' || chr(10) ||
'   END LOOP;' || chr(10) ||
'   RETURN ln_return_val;' || chr(10) ||
'END math_' || getFunctionName(p_table, column_name) || ';' || chr(10) line
FROM   ctrl_object,
       user_tab_columns
WHERE  ctrl_object.object_name = p_table
AND    ctrl_object.math = 'Y'
AND    ctrl_object.object_name = user_tab_columns.table_name
AND    data_type = 'NUMBER'
AND    user_tab_columns.column_name <> 'REV_NO'
AND    EXISTS
       (SELECT ucc.column_name
       FROM   user_constraints uc,
              user_cons_columns ucc
       WHERE  uc.table_name = p_table
       AND    uc.constraint_type = 'P'
       AND    ucc.constraint_name = uc.constraint_name
       AND    ucc.table_name = uc.table_name
       AND    ucc.column_name = 'DAYTIME');


-- Cummulative function code
CURSOR cum_function_code(p_table          VARCHAR2,
                         p_parameter_list VARCHAR2,
                         p_where_clause   VARCHAR2,
                         p_type           VARCHAR2) IS
SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'FUNCTION cum' || Lower(p_type) || '_' || getFunctionName(p_table, column_name) || p_parameter_list || chr(10) ||
'RETURN NUMBER IS ' || chr(10) || chr(10) ||
'CURSOR c_calculate IS' || chr(10) ||
'SELECT Sum(' || Decode(calc_type,'COLUMN', Lower(column_name),Lower(calc_formula)) || ') result' || chr(10) ||
'FROM ' || table_name || chr(10) ||
p_where_clause || ';' || chr(10) || chr(10) ||
'ln_return_val NUMBER := NULL;' || chr(10) ||
'BEGIN ' || chr(10) ||
'   FOR mycur IN c_calculate LOOP' || chr(10) ||
'       ln_return_val := mycur.result;' || chr(10) ||
'   END LOOP;' || chr(10) ||
'   RETURN ln_return_val;' || chr(10) ||
'END cum' || Lower(p_type) || '_' || getFunctionName(p_table, column_name) || ';' line
FROM  ctrl_gen_function
WHERE table_name = p_table
AND   calc_type IN ('COLUMN','CALC')
AND   ( decode(mtd_cumulative,'Y','M',null) = p_type
OR    decode(ytd_cumulative,'Y','Y',null) = p_type
OR    decode(ttd_cumulative,'Y','T',null) = p_type );


-- Average function code
CURSOR ave_function_code(p_table          VARCHAR2,
                         p_parameter_list VARCHAR2,
                         p_where_clause   VARCHAR2,
                         p_type           VARCHAR2) IS
SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'FUNCTION ave' || Lower(p_type) || '_' || getFunctionName(p_table, column_name) || p_parameter_list || chr(10) ||
'RETURN NUMBER IS ' || chr(10) || chr(10) ||
'CURSOR c_calculate IS ' || chr(10) ||
'SELECT Avg(' || Decode(calc_type,'COLUMN', Lower(column_name),Lower(calc_formula)) || ') result' || chr(10) ||
'FROM ' || table_name || chr(10) ||
p_where_clause || ';' || chr(10) || chr(10) ||
'ln_return_val NUMBER := NULL;' || chr(10) || chr(10) ||
'BEGIN ' || chr(10) ||
'   FOR mycur IN c_calculate LOOP' || chr(10) ||
'       ln_return_val := mycur.result;' || chr(10) ||
'   END LOOP;' || chr(10) ||
'   RETURN ln_return_val;' || chr(10) ||
'END ave' || Lower(p_type) || '_' || getFunctionName(p_table, column_name) || ';' line
FROM  ctrl_gen_function
WHERE table_name = p_table
AND   calc_type IN ('COLUMN','CALC')
AND   (decode(mtd_average,'Y','M',Null) = p_type
OR    decode(ytd_average,'Y','Y',Null) = p_type
OR    decode(ttd_average,'Y','T',Null) = p_type );



-- Function prev_daytime code
CURSOR prev_daytime_function_code(p_table          VARCHAR2,
                                  p_parameter_list VARCHAR2,
                                  p_where_clause   VARCHAR2) IS
SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'FUNCTION prev_' || Lower(Substr(column_name,1,ln_func_l)) || p_parameter_list || chr(10) ||
'RETURN DATE IS ' || chr(10) ||
'CURSOR c_compute IS' || chr(10) ||
'SELECT ' || Lower(column_name) || CHR(10) ||
'FROM ' || Lower(table_name) || chr(10) ||
p_where_clause || CHR(10) ||
'ORDER BY daytime DESC' || ';' || chr(10) ||
'ld_return_val DATE := NULL;' || chr(10) ||
'BEGIN ' || chr(10) ||
'   IF p_num_rows >= 1 THEN' || chr(10) ||
'      FOR cur_rec IN c_compute LOOP' || chr(10) ||
'         ld_return_val := cur_rec.daytime;' || chr(10) ||
'         IF c_compute%ROWCOUNT = p_num_rows THEN' || chr(10) ||
'            EXIT;' || chr(10) ||
'         END IF;' || chr(10) ||
'      END LOOP;' || chr(10) ||
'   END IF;' || chr(10) ||
'   RETURN ld_return_val;' || chr(10) ||
'END prev_' || Lower(Substr(column_name,1,ln_func_l)) || ';' || chr(10) line
FROM  user_tab_columns
WHERE table_name = p_table
AND   column_name = 'DAYTIME';


-- Function prev_equal_daytime code
CURSOR pr_equal_daytime_fun_code(p_table          VARCHAR2,
                                 p_parameter_list VARCHAR2,
                                 p_where_clause   VARCHAR2) IS
SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'FUNCTION prev_equal_' || Lower(Substr(column_name,1,ln_func_l)) || p_parameter_list || chr(10) ||
'RETURN DATE IS ' || chr(10) ||
'CURSOR c_compute IS' || chr(10) ||
'SELECT ' || Lower(column_name) || CHR(10) ||
'FROM ' || Lower(table_name) || chr(10) ||
p_where_clause || CHR(10) ||
'ORDER BY daytime DESC' || ';' || chr(10) ||
'ld_return_val DATE := NULL;' || chr(10) ||
'BEGIN ' || chr(10) ||
'   IF p_num_rows >= 1 THEN' || chr(10) ||
'      FOR cur_rec IN c_compute LOOP' || chr(10) ||
'         ld_return_val := cur_rec.daytime;' || chr(10) ||
'         IF c_compute%ROWCOUNT = p_num_rows THEN' || chr(10) ||
'            EXIT;' || chr(10) ||
'         END IF;' || chr(10) ||
'      END LOOP;' || chr(10) ||
'   END IF;' || chr(10) ||
'   RETURN ld_return_val;' || chr(10) ||
'END prev_equal_' || Lower(Substr(column_name,1,ln_func_l)) || ';' || chr(10) line
FROM  user_tab_columns
WHERE table_name = p_table
AND   column_name = 'DAYTIME';


-- Function next_daytime code
CURSOR next_daytime_function_code(p_table          VARCHAR2,
                                  p_parameter_list VARCHAR2,
                                  p_where_clause   VARCHAR2) IS
SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'FUNCTION next_' || Lower(Substr(column_name,1,ln_func_l)) || p_parameter_list || chr(10) ||
'RETURN DATE IS ' || chr(10) ||
'CURSOR c_compute IS' || chr(10) ||
'SELECT ' || Lower(column_name) || CHR(10) ||
'FROM ' || Lower(table_name) || chr(10) ||
p_where_clause || CHR(10) ||
'ORDER BY daytime ASC' || ';' || chr(10) ||
'ld_return_val DATE := NULL;' || chr(10) ||
'BEGIN ' || chr(10) ||
'   IF p_num_rows >= 1 THEN' || chr(10) ||
'      FOR cur_rec IN c_compute LOOP' || chr(10) ||
'         ld_return_val := cur_rec.daytime;' || chr(10) ||
'         IF c_compute%ROWCOUNT = p_num_rows THEN' || chr(10) ||
'            EXIT;' || chr(10) ||
'         END IF;' || chr(10) ||
'      END LOOP;' || chr(10) ||
'   END IF;' || chr(10) ||
'   RETURN ld_return_val;' || chr(10) ||
'END next_' || Lower(Substr(column_name,1,ln_func_l)) || ';' || chr(10) line
FROM  user_tab_columns
WHERE table_name = p_table
AND   column_name = 'DAYTIME';



-- Function next_daytime code
CURSOR ne_equal_daytime_fun_code(p_table          VARCHAR2,
                                 p_parameter_list VARCHAR2,
                                 p_where_clause   VARCHAR2) IS
SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'FUNCTION next_equal_' || Lower(Substr(column_name,1,ln_func_l)) || p_parameter_list || chr(10) ||
'RETURN DATE IS ' || chr(10) ||
'CURSOR c_compute IS' || chr(10) ||
'SELECT ' || Lower(column_name) || CHR(10) ||
'FROM ' || Lower(table_name) || chr(10) ||
p_where_clause || CHR(10) ||
'ORDER BY daytime ASC' || ';' || chr(10) ||
'ld_return_val DATE := NULL;' || chr(10) ||
'BEGIN ' || chr(10) ||
'   IF p_num_rows >= 1 THEN' || chr(10) ||
'      FOR cur_rec IN c_compute LOOP' || chr(10) ||
'         ld_return_val := cur_rec.daytime;' || chr(10) ||
'         IF c_compute%ROWCOUNT = p_num_rows THEN' || chr(10) ||
'            EXIT;' || chr(10) ||
'         END IF;' || chr(10) ||
'      END LOOP;' || chr(10) ||
'   END IF;' || chr(10) ||
'   RETURN ld_return_val;' || chr(10) ||
'END next_equal_' || Lower(Substr(column_name,1,ln_func_l)) || ';' || chr(10) line
FROM  user_tab_columns
WHERE table_name = p_table
AND  column_name = 'DAYTIME';



-- Function rowtype code (dt)
CURSOR rowtype_function_code_dt(p_table                 VARCHAR2,
                                p_parameter_list        VARCHAR2,
                                p_parameter_list_cursor VARCHAR2) IS
SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'FUNCTION row_by_pk ' || p_parameter_list || chr(10) ||
'RETURN ' || p_table ||'%ROWTYPE IS ' || chr(10) ||
'BEGIN ' || chr(10) ||
'   RETURN row_by_rel_operator' || p_parameter_list_cursor || ';' || chr(10) ||
'END row_by_pk' || ';' || chr(10) line
FROM  ctrl_object
WHERE object_name=p_table
AND   view_pk_table_name IS NULL;


-- Function rowtype code
CURSOR rowtype_function_code(p_table          VARCHAR2,
                             p_parameter_list VARCHAR2,
                             p_where_clause   VARCHAR2) IS
SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'FUNCTION row_by_pk ' || p_parameter_list || chr(10) ||
'RETURN ' || p_table ||'%ROWTYPE IS ' || chr(10) ||
'   v_return_rec ' || p_table ||'%ROWTYPE;' || chr(10) ||
'   CURSOR c_read_row IS' || chr(10) ||
'   SELECT * ' || chr(10) ||
'   FROM ' || object_name || chr(10) ||
    p_where_clause || ';' || chr(10) ||
'BEGIN ' || chr(10) ||
'   FOR cur_rec IN c_read_row LOOP' || chr(10) ||
'      v_return_rec := cur_rec;' || chr(10) ||
'   END LOOP;' || chr(10) ||
'   RETURN v_return_rec;' || chr(10) ||
'END row_by_pk' || ';' || chr(10) line
FROM  ctrl_object
WHERE object_name=p_table
AND   view_pk_table_name IS NULL;

-- Function rowtype interface and pragma settings
CURSOR rowtype_object_function_CODE(p_table VARCHAR2) IS
SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'FUNCTION row_by_object_id(p_object_id VARCHAR2)' || chr(10) ||
'RETURN ' || p_table ||'%ROWTYPE IS ' || chr(10) ||
'   v_return_rec ' || p_table ||'%ROWTYPE;' || chr(10) ||
'   CURSOR c_read_row IS' || chr(10) ||
'   SELECT * ' || chr(10) ||
'   FROM ' || object_name || chr(10) ||
'   WHERE object_id = p_object_id;' || chr(10) ||
'BEGIN ' || chr(10) ||
'   FOR cur_rec IN c_read_row LOOP' || chr(10) ||
'      v_return_rec := cur_rec;' || chr(10) ||
'   END LOOP;' || chr(10) ||
'   RETURN v_return_rec;' || chr(10) ||
'END row_by_object_id' || ';' || chr(10) line
FROM  ctrl_object co
WHERE co.object_name = p_table
AND   co.view_pk_table_name IS NULL
AND 1 = (SELECT count(*)
         FROM user_constraints uc, user_cons_columns ucc, user_cons_columns ucc2
         WHERE uc.table_name = co.object_name
         AND (uc.constraint_type = 'U' OR uc.constraint_type = 'P')
         AND ucc.table_name = uc.table_name
         AND ucc.constraint_name = uc.constraint_name
         AND ucc.column_name = 'OBJECT_ID'
         AND ucc2.table_name = uc.table_name
         AND ucc2.constraint_name = uc.constraint_name);


CURSOR attribute_function_code (p_table                 VARCHAR2,
                                p_parent_table          VARCHAR2,
                                p_parameter_list        VARCHAR2,
                                p_parameter_list_ext    VARCHAR2) IS
SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'FUNCTION attribute_text_by_id ' || p_parameter_list || chr(10) ||
'RETURN ' || p_table ||'.ATTRIBUTE_TEXT%TYPE IS ' || chr(10) ||
'CURSOR c_parent_table IS' || chr(10) ||
'SELECT *'|| chr(10) ||
'FROM ' || p_parent_table || chr(10) ||
'WHERE object_id = p_object_id;' || chr(10) ||
'lr_fields ' || p_table || '%ROWTYPE;' || chr(10) ||
'lr_parent_row ' || p_parent_table || '%ROWTYPE;' || chr(10) ||
'BEGIN ' || chr(10) ||
'   FOR cur_rec IN c_parent_table LOOP' || chr(10) ||
'      lr_parent_row := cur_rec;' || chr(10) ||
'   END LOOP;' || chr(10) ||
'   lr_fields := row_by_rel_operator' || p_parameter_list_ext || ';' || chr(10) ||
'   RETURN lr_fields.attribute_text;' || chr(10) ||
'END attribute_text_by_id' || ';' || chr(10) line
FROM  ctrl_object co
WHERE co.object_name = p_table
AND   co.view_pk_table_name IS NULL
AND EXISTS (
SELECT 1 FROM user_tab_columns utc
WHERE utc.table_name = co.object_name
AND utc.column_name = 'ATTRIBUTE_TEXT'
);


-- Function coltype code (dt)
CURSOR coltype_function_code_dt(p_pk_table            VARCHAR2,
                                p_table               VARCHAR2,
                                p_parameter_list      VARCHAR2,
                                p_call_parameter_list VARCHAR2) IS
SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'FUNCTION ' || getFunctionName(p_table, utc.column_name) || p_parameter_list || chr(10) ||
'RETURN ' || p_table || '.' || utc.column_name ||'%TYPE IS ' || chr(10) ||
'   lr_fields ' || p_table || '%ROWTYPE;' || chr(10) ||
'BEGIN ' || chr(10) ||
'   lr_fields := row_by_rel_operator' || p_call_parameter_list || ';' || chr(10) ||
'   RETURN lr_fields.' || Lower(utc.column_name) || ';' || chr(10) ||
'END ' || getFunctionName(p_table, utc.column_name) || ';' || chr(10) line
FROM  user_tab_columns utc
WHERE utc.table_name = p_table
AND   utc.column_name NOT IN ('REV_NO','REV_TEXT','CREATED_BY','CREATED_DATE','LAST_UPDATED_BY','LAST_UPDATED_DATE')
AND NOT EXISTS (
   SELECT 1
   FROM user_cons_columns ucc, user_constraints uc
   WHERE uc.constraint_name = ucc.constraint_name
   AND uc.table_name = ucc.table_name
   AND uc.owner = ucc.owner
   AND ucc.column_name = utc.column_name
   AND uc.table_name= p_pk_table
   AND uc.constraint_type = 'P');

-- Function coltype code
CURSOR coltype_function_code(p_pk_table       VARCHAR2,
                             p_table          VARCHAR2,
                             p_parameter_list VARCHAR2,
                             p_where_clause   VARCHAR2) IS
SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'FUNCTION ' || getFunctionName(p_table, utc.column_name) || p_parameter_list || chr(10) ||
'RETURN ' || p_table || '.' || utc.column_name ||'%TYPE IS ' || chr(10) ||
'   v_return_val '|| p_table || '.' || utc.column_name ||'%TYPE ;' || chr(10) ||
'   CURSOR c_col_val IS' || chr(10) ||
'   SELECT ' || Lower(utc.column_name) || ' col' || chr(10) ||
'   FROM ' || utc.table_name || chr(10) ||
    p_where_clause || ';' || chr(10) ||
'BEGIN ' || chr(10) ||
'   FOR cur_row IN c_col_val LOOP' || chr(10) ||
'      v_return_val := cur_row.col;' || chr(10) ||
'   END LOOP;' || chr(10) ||
'   RETURN v_return_val;' || chr(10) ||
'END ' || getFunctionName(p_table, utc.column_name) || ';' || chr(10) line
FROM  user_tab_columns utc
WHERE utc.table_name = p_table
AND   utc.column_name NOT IN ('REV_NO','REV_TEXT','CREATED_BY','CREATED_DATE','LAST_UPDATED_BY','LAST_UPDATED_DATE')
AND NOT EXISTS (
   SELECT 1
   FROM user_cons_columns ucc, user_constraints uc
   WHERE uc.constraint_name = ucc.constraint_name
   AND uc.table_name = ucc.table_name
   AND uc.owner = ucc.owner
   AND ucc.column_name = utc.column_name
   AND uc.table_name= p_pk_table
   AND uc.constraint_type = 'P');


-- Function common_cur code
CURSOR common_cur_function_code(p_table                 VARCHAR2,
                                p_parameter_list        VARCHAR2,
                                p_parameter_list_cursor VARCHAR2) IS
SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'FUNCTION row_by_rel_operator ' || p_parameter_list || chr(10) ||
'RETURN ' || p_table ||'%ROWTYPE IS ' || chr(10) ||
'   lr_return_rec ' || p_table ||'%ROWTYPE;' || chr(10) ||
'BEGIN ' || chr(10) ||
'   IF p_compare_oper = ''='' THEN ' || chr(10) ||
'      FOR cur_row IN c_equal'|| p_parameter_list_cursor || ' LOOP' || chr(10) ||
'         lr_return_rec := cur_row;' || chr(10) ||
'      END LOOP;' || chr(10) ||
'   ELSIF p_compare_oper IN (''<='',''=<'') THEN ' || chr(10) ||
'      FOR cur_row IN c_less_equal'|| p_parameter_list_cursor || ' LOOP' || chr(10) ||
'         lr_return_rec := cur_row;' || chr(10) ||
'      END LOOP;' || chr(10) ||
'   ELSIF p_compare_oper = ''<'' THEN ' || chr(10) ||
'      FOR cur_row IN c_less'|| p_parameter_list_cursor || ' LOOP' || chr(10) ||
'         lr_return_rec := cur_row;' || chr(10) ||
'      END LOOP;' || chr(10) ||
'   ELSIF p_compare_oper IN (''>='',''=>'') THEN ' || chr(10) ||
'      FOR cur_row IN c_greater_equal'|| p_parameter_list_cursor || ' LOOP' || chr(10) ||
'         lr_return_rec := cur_row;' || chr(10) ||
'      END LOOP;' || chr(10) ||
'   ELSIF p_compare_oper = ''>'' THEN ' || chr(10) ||
'      FOR cur_row IN c_greater'|| p_parameter_list_cursor || ' LOOP' || chr(10) ||
'         lr_return_rec := cur_row;' || chr(10) ||
'      END LOOP;' || chr(10) ||
'   END IF;' || chr(10) ||
'   RETURN lr_return_rec;' || chr(10) ||
'END row_by_rel_operator' || ';' || chr(10) line
FROM  user_tab_columns
WHERE table_name = p_table
AND   column_name = 'DAYTIME';


-- Cursor c_equal
CURSOR common_cur_equal(p_table          VARCHAR2,
                        p_parameter_list VARCHAR2,
                        p_where_clause   VARCHAR2) IS
SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'CURSOR c_equal ' || p_parameter_list ||' IS '|| chr(10) ||
'SELECT * ' || chr(10) ||
'FROM ' || p_table || chr(10) ||
p_where_clause || ';' line
FROM DUAL;


-- Cursor c_less_equal
CURSOR common_cur_less_equal(p_table            VARCHAR2,
                             p_parameter_list   VARCHAR2,
                             p_where_clause     VARCHAR2,
                             p_where_clause_sub VARCHAR2) IS
SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'CURSOR c_less_equal ' || p_parameter_list ||' IS '|| chr(10) ||
'SELECT * ' || chr(10) ||
'FROM ' || p_table || chr(10) ||
p_where_clause_sub || chr(10) ||
'   (SELECT max(daytime) ' || chr(10) ||
'   FROM '|| p_table || chr(10) ||
p_where_clause || ');' line
FROM DUAL;


-- Cursor c_less_equal_version
CURSOR version_cur_less_equal(p_table            VARCHAR2,
                             p_parameter_list   VARCHAR2) IS
SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'CURSOR c_less_equal ' || p_parameter_list ||' IS '|| chr(10) ||
'SELECT * ' || chr(10) ||
'FROM ' || p_table || chr(10) ||
'WHERE object_id = p_object_id' ||chr(10) ||
'AND p_daytime >= daytime' ||chr(10) ||
'AND p_daytime < nvl(end_date,p_daytime+1);' line
FROM DUAL;


-- Cursor c_less
CURSOR common_cur_less(p_table            VARCHAR2,
                       p_parameter_list   VARCHAR2,
                       p_where_clause     VARCHAR2,
                       p_where_clause_sub VARCHAR2) IS
SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'CURSOR c_less ' || p_parameter_list ||' IS '|| chr(10) ||
'SELECT * ' || chr(10) ||
'FROM ' || p_table || chr(10) ||
p_where_clause_sub || chr(10) ||
'   (SELECT max(daytime) ' || chr(10) ||
'   FROM '|| p_table || chr(10) ||
p_where_clause || ');' line
FROM DUAL;


-- Cursor c_less_version
CURSOR version_cur_less(p_table            VARCHAR2,
                       p_parameter_list   VARCHAR2) IS
SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'CURSOR c_less ' || p_parameter_list ||' IS '|| chr(10) ||
'SELECT * ' || chr(10) ||
'FROM ' || p_table || chr(10) ||
'WHERE object_id = p_object_id' ||chr(10) ||
'and daytime < p_daytime' ||chr(10) ||
'AND nvl(end_date,p_daytime) >= p_daytime;' line
FROM DUAL;



-- Cursor c_greater_equal
CURSOR common_cur_greater_equal(p_table            VARCHAR2,
                                p_parameter_list   VARCHAR2,
                                p_where_clause     VARCHAR2,
                                p_where_clause_sub VARCHAR2) IS
SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'CURSOR c_greater_equal ' || p_parameter_list ||' IS '|| chr(10) ||
'SELECT * ' || chr(10) ||
'FROM ' || p_table || chr(10) ||
p_where_clause_sub || chr(10) ||
'   (SELECT min(daytime) ' || chr(10) ||
'   FROM '|| p_table || chr(10) ||
p_where_clause || ');' line
FROM DUAL;


-- Cursor c_greater
CURSOR common_cur_greater(p_table            VARCHAR2,
                          p_parameter_list   VARCHAR2,
                          p_where_clause     VARCHAR2,
                          p_where_clause_sub VARCHAR2) IS
SELECT
'------------------------------------------------------------------------------------' || chr(10) ||
'CURSOR c_greater ' || p_parameter_list ||' IS '|| chr(10) ||
'SELECT * ' || chr(10) ||
'FROM ' || p_table || chr(10) ||
p_where_clause_sub || chr(10) ||
'   (SELECT min(daytime) ' || chr(10) ||
'   FROM '|| p_table || chr(10) ||
p_where_clause || ');' line
FROM DUAL;


-- Start procedure
BEGIN

        pv_lines.delete;

        lv2_package_name := lower(substr(p_object_name,1,ln_package_l));

        ------------------------------------------------------------
        -- BUILD DAYTIME CLAUSES
        ------------------------------------------------------------
        lv2_daytime_clause_m := 'daytime BETWEEN to_date(to_char(p_daytime,''YYYYMM'') || ''01'',''YYYYMMDD'') AND p_daytime';
        lv2_daytime_clause_y := 'daytime BETWEEN to_date(to_char(p_daytime,''YYYY'') || ''0101'',''YYYYMMDD'') AND p_daytime';
        lv2_daytime_clause_t := 'daytime <= p_daytime';
        lv2_daytime_clause_x := 'daytime BETWEEN p_daytime AND p_daytime2';
        lv2_daytime_clause_p := 'daytime < p_daytime';
        lv2_daytime_clause_n := 'daytime > p_daytime';
        lv2_daytime_clause_pe := 'daytime <= p_daytime';
        lv2_daytime_clause_ne := 'daytime >= p_daytime';
        lv2_daytime_clause   := 'daytime = p_daytime';
        lv2_daytime_clause_sub   := 'daytime = '; -- used if subselect max/min is needed

        -- Daytime clause for Math - functions
        lv2_daytime_clause_per := 'daytime BETWEEN Nvl(p_from_day, to_date(''01-JAN-1900'',''dd-mon-yyyy'')) AND Nvl(p_to_day, p_from_day)';

        ------------------------------------------------------------
        -- CREATE PACKAGE BODY HEADER
        ------------------------------------------------------------
        IF p_target <> 'CREATE' THEN

          createTextLine('  ',p_target);
          createTextLine('  ',p_target);
          createTextLine('  ',p_target);
          createTextLine('PROMPT Creating package body for ' || UPPER(lv2_package_name) || ';',p_target);

        END IF;

        createTextLine('CREATE OR REPLACE PACKAGE BODY ec_' || lv2_package_name || ' IS',p_target);
        createTextLine('------------------------------------------------------------------------------------',p_target);
        createTextLine('-- Package body: ec_' || lv2_package_name ,p_target);
        createTextLine('-- Generated by EC_GENERATE.',p_target);
        createTextLine('------------------------------------------------------------------------------------',p_target);
        createTextLine('  ',p_target);
        createTextLine('  ',p_target);


        lv2_parameter_list := Null;
        lv2_parameter_list_cursor := Null;
        lv2_parameter_list_period := Null;
        lv2_par_list_cursor_func := Null;
        lv2_where_clause  := Null;
        lv2_table_name := Nvl(p_view_pk_table_name, p_object_name);
        lv2_daytime := 'N';
        lv2_summet_time_flag := 'N';

        lb_version_table := FALSE;

        FOR curTable IN c_version_table(lv2_table_name) LOOP
          lb_version_table := TRUE;
        END LOOP;

        -----------------------------------------------------------
        -- BUILD LIST OF COLUMNS BEING PART OF PK
        -----------------------------------------------------------
        FOR qualify_cur IN c_qualifier_list(lv2_table_name) LOOP
           IF qualify_cur.column_name = 'SUMMER_TIME' THEN
                  lv2_summet_time_flag := 'Y';
               ELSE
                IF lv2_parameter_list IS NULL THEN
                        lv2_parameter_list := chr(10) || '         p_' || Lower(qualify_cur.column_name) || ' ' || qualify_cur.column_type;
                        lv2_parameter_list_cursor := chr(10) || '         p_' || Lower(qualify_cur.column_name);
                ELSE
                        lv2_parameter_list := lv2_parameter_list || ',' || chr(10) || '         p_' || Lower(qualify_cur.column_name) || ' ' || qualify_cur.column_type;
              lv2_parameter_list_cursor := lv2_parameter_list_cursor || ',' || chr(10) || '         p_' || Lower(qualify_cur.column_name);
                END IF;

                IF qualify_cur.column_name <> 'DAYTIME' THEN -- daytime clause will be handled explicit
                        IF lv2_where_clause IS NULL THEN
                                lv2_where_clause := 'WHERE ' || Lower(qualify_cur.column_name) || ' = ' || 'p_' || Lower(qualify_cur.column_name);
                        ELSE
                                lv2_where_clause := lv2_where_clause || chr(10) || 'AND ' || Lower(qualify_cur.column_name) || ' = ' || 'p_' || Lower(qualify_cur.column_name);
                        END IF;

                        IF lv2_parameter_list_period IS NULL THEN
                                lv2_parameter_list_period := chr(10) || '         p_' || Lower(qualify_cur.column_name) || ' ' || qualify_cur.column_type;
                        ELSE
                                lv2_parameter_list_period := lv2_parameter_list_period || ',' || chr(10) || '         p_' || Lower(qualify_cur.column_name) || ' ' || qualify_cur.column_type;
                        END IF;

                        IF lv2_parameter_list_count IS NULL THEN
                                lv2_parameter_list_count := chr(10) || '         p_' || Lower(qualify_cur.column_name) || ' ' || qualify_cur.column_type;
                        ELSE
                                lv2_parameter_list_count := lv2_parameter_list_count || ',' || chr(10) || '         p_' || Lower(qualify_cur.column_name) || ' ' || qualify_cur.column_type;
                        END IF;

                ELSE
                        lv2_daytime:='Y';
                END IF;
              END IF;
        END LOOP;


        -----------------------------------------------------------
        -- INITIATE THE PARAMETERLISTS
        -----------------------------------------------------------
        IF lv2_parameter_list IS NOT NULL THEN
                lv2_parameter_list_x := '(' || lv2_parameter_list || ',' || chr(10) || '         p_daytime2 DATE)';
                lv2_parameter_list_oper := '(' || lv2_parameter_list || ',' || chr(10) || '         p_compare_oper VARCHAR2 DEFAULT ''='')';
                lv2_par_list_cursor_func := '(' || lv2_parameter_list_cursor || ', p_compare_oper)';
                lv2_parameter_list_cursor   := '(' || lv2_parameter_list_cursor || ')';
                lv2_parameter_list_period := '(' || lv2_parameter_list_period || ',' || chr(10) || '         p_from_day DATE,' || chr(10) || '         p_to_day DATE,' || chr(10) || '         p_method VARCHAR2 DEFAULT ''SUM'')';
                lv2_parameter_list_count := '(' || lv2_parameter_list_count || ',' || chr(10) || '         p_from_day DATE,' || chr(10) || '         p_to_day DATE)';
                lv2_parameter_list_n_rows := '(' || lv2_parameter_list || ',' || chr(10) || '         p_num_rows NUMBER DEFAULT 1' || ')';
                lv2_parameter_list   := '(' || lv2_parameter_list || ')';
        END IF;

        IF lv2_daytime = 'Y' THEN
                IF lv2_where_clause IS NULL THEN
                        lv2_where_clause_m := 'WHERE ' || lv2_daytime_clause_m;
                        lv2_where_clause_y := 'WHERE ' || lv2_daytime_clause_y;
                        lv2_where_clause_t := 'WHERE ' || lv2_daytime_clause_t;
                        lv2_where_clause_x := 'WHERE ' || lv2_daytime_clause_x;
                        lv2_where_clause_p := 'WHERE ' || lv2_daytime_clause_p;
                        lv2_where_clause_n := 'WHERE ' || lv2_daytime_clause_n;
                        lv2_where_clause_pe:= 'WHERE ' || lv2_daytime_clause_pe;
                        lv2_where_clause_ne:= 'WHERE ' || lv2_daytime_clause_ne;
                        lv2_where_clause_sub:='WHERE ' || lv2_daytime_clause_sub;
                        lv2_where_clause   := 'WHERE ' || lv2_daytime_clause;
                        lv2_where_clause_per :='WHERE ' || lv2_daytime_clause_per;
                        lv2_where_clause_count :='WHERE ' || lv2_daytime_clause_per;
                ELSE
                        lv2_where_clause_m := lv2_where_clause || chr(10) || 'AND ' || lv2_daytime_clause_m;
                        lv2_where_clause_y := lv2_where_clause || chr(10) || 'AND ' || lv2_daytime_clause_y;
                        lv2_where_clause_t := lv2_where_clause || chr(10) || 'AND ' || lv2_daytime_clause_t;
                        lv2_where_clause_x := lv2_where_clause || chr(10) || 'AND ' || lv2_daytime_clause_x;
                        lv2_where_clause_p := lv2_where_clause || chr(10) || 'AND ' || lv2_daytime_clause_p;
                        lv2_where_clause_n := lv2_where_clause || chr(10) || 'AND ' || lv2_daytime_clause_n;
                        lv2_where_clause_pe:= lv2_where_clause || chr(10) || 'AND ' || lv2_daytime_clause_pe;
                        lv2_where_clause_ne:= lv2_where_clause || chr(10) || 'AND ' || lv2_daytime_clause_ne;
                        lv2_where_clause_sub:=lv2_where_clause || chr(10) || 'AND ' || lv2_daytime_clause_sub;
                        lv2_where_clause_per:=lv2_where_clause || chr(10) || 'AND ' || lv2_daytime_clause_per;
                        lv2_where_clause_count:=lv2_where_clause || chr(10) || 'AND ' || lv2_daytime_clause_per;
                        lv2_where_clause   := lv2_where_clause || chr(10) || 'AND ' || lv2_daytime_clause;

                END IF;
        ELSE
                IF lv2_where_clause IS NULL THEN
                        lv2_where_clause_m := null;
                        lv2_where_clause_y := null;
                        lv2_where_clause_t := null;
                        lv2_where_clause_x := null;
                        lv2_where_clause_p := null;
                        lv2_where_clause_n := null;
                        lv2_where_clause_pe:= null;
                        lv2_where_clause_ne:= null;
                        lv2_where_clause_sub:= null;
                        lv2_where_clause   := null;
                        lv2_where_clause_per:= null;
                        lv2_where_clause_count:= null;
                ELSE
                        lv2_where_clause_m := lv2_where_clause;
                        lv2_where_clause_y := lv2_where_clause;
                        lv2_where_clause_t := lv2_where_clause;
                        lv2_where_clause_x := lv2_where_clause;
                        lv2_where_clause_p := lv2_where_clause;
                        lv2_where_clause_n := lv2_where_clause;
                        lv2_where_clause_pe:= lv2_where_clause;
                        lv2_where_clause_ne:= lv2_where_clause;
                        lv2_where_clause_sub:= lv2_where_clause;
                        lv2_where_clause   := lv2_where_clause;
                        lv2_where_clause_per:= lv2_where_clause;
                        lv2_where_clause_count:= lv2_where_clause;
                END IF;
        END IF;

        ------------------------------------------------------------
        -- CREATE COMMON CURSORS, IF TABLE CONTAINS 'DAYTIME'
        ------------------------------------------------------------
        IF lv2_daytime = 'Y' THEN

                ------------------------------------------------------------
                -- cursor for daytime = v_daytime
                ------------------------------------------------------------
                IF lv2_summet_time_flag = 'Y' then
                   lv2_parameter_list_s := substr(lv2_parameter_list,1, LENGTH(lv2_parameter_list)-1) ||','|| chr(10) || '          p_summertime VARCHAR2 DEFAULT NULL)';
                   lv2_where_clause_s := lv2_where_clause ||chr(10) || 'AND SUMMER_TIME = nvl(p_summertime, SUMMER_TIME)' || chr(10) ||'ORDER BY SUMMER_TIME ';
                 ELSE
                   lv2_parameter_list_s := lv2_parameter_list;
                   lv2_where_clause_s := lv2_where_clause;
                END IF;
                FOR common_cursor IN common_cur_equal(p_object_name, lv2_parameter_list_s, lv2_where_clause_s) LOOP
                        createTextLine(common_cursor.line,p_target);
                END LOOP;
                createTextLine('  ',p_target);

                ------------------------------------------------------------
                -- cursor for daytime <= v_daytime
                ------------------------------------------------------------
                IF NOT lb_version_table THEN

                  FOR common_cursor IN common_cur_less_equal(p_object_name, lv2_parameter_list_s, lv2_where_clause_pe, lv2_where_clause_sub) LOOP
                        createTextLine(common_cursor.line,p_target);
                  END LOOP;

                ELSE

                  FOR version_cursor IN version_cur_less_equal(p_object_name, lv2_parameter_list_s) LOOP
                        createTextLine(version_cursor.line,p_target);
                  END LOOP;


                END IF;
                createTextLine('  ',p_target);

                ------------------------------------------------------------
                -- cursor for daytime < v_daytime
                ------------------------------------------------------------
                IF NOT lb_version_table THEN

                  FOR common_cursor IN common_cur_less(p_object_name, lv2_parameter_list_s, lv2_where_clause_p, lv2_where_clause_sub) LOOP
                          createTextLine(common_cursor.line,p_target);
                  END LOOP;

                ELSE

                  FOR version_cursor2 IN version_cur_less(p_object_name, lv2_parameter_list_s) LOOP
                          createTextLine(version_cursor2.line,p_target);
                  END LOOP;

                END IF;
                createTextLine('  ',p_target);

                ------------------------------------------------------------
                -- cursor for daytime >= v_daytime
                ------------------------------------------------------------
                FOR common_cursor IN common_cur_greater_equal(p_object_name, lv2_parameter_list_s, lv2_where_clause_ne, lv2_where_clause_sub) LOOP
                        createTextLine(common_cursor.line,p_target);
                END LOOP;
                createTextLine('  ',p_target);

                ------------------------------------------------------------
                -- cursor for daytime > v_daytime
                ------------------------------------------------------------
                FOR common_cursor IN common_cur_greater(p_object_name, lv2_parameter_list_s, lv2_where_clause_n, lv2_where_clause_sub) LOOP
                        createTextLine(common_cursor.line,p_target);
                END LOOP;
                createTextLine('  ',p_target);

        END IF;

        ------------------------------------------------------------
        -- CREATE FUNCTION CODE
        ------------------------------------------------------------

        createTextLine('  ',p_target);

        ------------------------------------------------------------
        -- count_rows
        ------------------------------------------------------------
        FOR function_cursor IN count_function_code(p_object_name, lv2_parameter_list_count, lv2_where_clause_count) LOOP
                createTextLine(function_cursor.line,p_target);
        END LOOP;
        createTextLine('  ',p_target);


        ------------------------------------------------------------
        -- period functions
        ------------------------------------------------------------
        FOR function_cursor IN math_function_code(p_object_name, lv2_parameter_list_period, lv2_where_clause_per) LOOP
                createTextLine(function_cursor.line,p_target);
        END LOOP;
        createTextLine('  ',p_target);


        ------------------------------------------------------------
        -- cummulative
        ------------------------------------------------------------
        FOR function_cursor IN cum_function_code(p_object_name, lv2_parameter_list, lv2_where_clause_m, 'M') LOOP
                createTextLine(function_cursor.line,p_target);
        END LOOP;
        createTextLine('  ',p_target);

        FOR function_cursor IN cum_function_code(p_object_name, lv2_parameter_list, lv2_where_clause_y, 'Y') LOOP
                createTextLine(function_cursor.line,p_target);
        END LOOP;
        createTextLine('  ',p_target);

        FOR function_cursor IN cum_function_code(p_object_name, lv2_parameter_list, lv2_where_clause_t, 'T') LOOP
                createTextLine(function_cursor.line,p_target);
        END LOOP;
        createTextLine('  ',p_target);

        ------------------------------------------------------------
        -- average
        ------------------------------------------------------------
        FOR function_cursor IN ave_function_code(p_object_name, lv2_parameter_list, lv2_where_clause_m, 'M') LOOP
                createTextLine(function_cursor.line,p_target);
        END LOOP;
        createTextLine('  ',p_target);

        FOR function_cursor IN ave_function_code(p_object_name, lv2_parameter_list, lv2_where_clause_y, 'Y') LOOP
                createTextLine(function_cursor.line,p_target);
        END LOOP;
        createTextLine('  ',p_target);

        FOR function_cursor IN ave_function_code(p_object_name, lv2_parameter_list, lv2_where_clause_t, 'T') LOOP
                createTextLine(function_cursor.line,p_target);
        END LOOP;
        createTextLine('  ',p_target);

        ------------------------------------------------------------
        -- prev_daytime
        ------------------------------------------------------------
        FOR function_cursor IN prev_daytime_function_code(p_object_name, lv2_parameter_list_n_rows, lv2_where_clause_p) LOOP
                createTextLine(function_cursor.line,p_target);
        END LOOP;
        createTextLine('  ',p_target);

        ------------------------------------------------------------
        -- prev_equal_daytime
        ------------------------------------------------------------
        FOR function_cursor IN pr_equal_daytime_fun_code(p_object_name, lv2_parameter_list_n_rows, lv2_where_clause_pe) LOOP
                createTextLine(function_cursor.line,p_target);
        END LOOP;
        createTextLine('  ',p_target);


        ------------------------------------------------------------
        -- next_daytime
        ------------------------------------------------------------
        FOR function_cursor IN next_daytime_function_code(p_object_name, lv2_parameter_list_n_rows, lv2_where_clause_n) LOOP
                createTextLine(function_cursor.line,p_target);
        END LOOP;
        createTextLine('  ',p_target);

        ------------------------------------------------------------
        -- next_equal_daytime
        ------------------------------------------------------------
        FOR function_cursor IN ne_equal_daytime_fun_code(p_object_name, lv2_parameter_list_n_rows, lv2_where_clause_ne) LOOP
                createTextLine(function_cursor.line,p_target);
        END LOOP;
        createTextLine('  ',p_target);

        writeObjectIdFunction(p_object_name, 'BODY', p_target);

        IF lv2_daytime = 'Y' THEN
                IF lv2_summet_time_flag = 'Y' then
                   lv2_parameter_list_oper_s := substr(lv2_parameter_list_oper,1, LENGTH(lv2_parameter_list_oper)-1) ||','|| chr(10) || '        p_summertime VARCHAR2 DEFAULT NULL)';
                   lv2_parameter_list_cursor_s := substr(lv2_parameter_list_cursor,1, LENGTH(lv2_parameter_list_cursor)-1) ||','|| chr(10) || '        p_summertime)';
                   lv2_par_list_cursor_func_s :=  substr(lv2_par_list_cursor_func,1, LENGTH(lv2_par_list_cursor_func)-1) ||','|| chr(10) || '        p_summertime)';
                 ELSE
                   lv2_parameter_list_oper_s := lv2_parameter_list_oper;
                   lv2_parameter_list_cursor_s := lv2_parameter_list_cursor;
                   lv2_par_list_cursor_func_s :=lv2_par_list_cursor_func;
                END IF;

                FOR function_cursor IN common_cur_function_code(p_object_name, lv2_parameter_list_oper_s, lv2_parameter_list_cursor_s) LOOP
                        createTextLine(function_cursor.line,p_target);
                END LOOP;

                ------------------------------------------------------------
                -- single columns, if daytime is present
                ------------------------------------------------------------
                FOR function_cursor IN coltype_function_code_dt(lv2_table_name, p_object_name, lv2_parameter_list_oper_s, lv2_par_list_cursor_func_s) LOOP
                        createTextLine(function_cursor.line,p_target);
        END LOOP;
        createTextLine('  ',p_target);

        ------------------------------------------------------------
        -- rowtype, if daytime is present
        ------------------------------------------------------------
        FOR function_cursor IN rowtype_function_code_dt(p_object_name, lv2_parameter_list_oper, lv2_par_list_cursor_func) LOOP
                createTextLine(function_cursor.line,p_target);
        END LOOP;
        createTextLine('  ',p_target);

      -- Generate attribute fetch functions for attribute tables only

      IF RTRIM(p_object_name,'ATTRIBUTE') || 'ATTRIBUTE' = p_object_name THEN

         lv2_parent_table := getAttributeParentTable(p_object_name);

         IF lv2_parent_table IS NOT NULL THEN

            lv2_parameter_list_attrib_ext := NULL;

                 FOR qualify_cur IN c_qualifier_list(lv2_table_name) LOOP

                    IF qualify_cur.column_name NOT IN ('DAYTIME','ATTRIBUTE_TYPE') THEN

                            IF lv2_parameter_list_attrib_ext IS NULL THEN
                                   lv2_parameter_list_attrib_ext := chr(10) || '         lr_parent_row.' || Lower(qualify_cur.column_name);
                            ELSE
                                   lv2_parameter_list_attrib_ext := lv2_parameter_list_attrib_ext || ',' || chr(10) || '         lr_parent_row.' || Lower(qualify_cur.column_name);
                            END IF;
                    END IF;

            END LOOP;
            lv2_parameter_list_attrib_ext := '(' || lv2_parameter_list_attrib_ext || ', p_daytime, p_attribute_type, p_compare_oper)';
            lv2_parameter_list_attrib := '(p_object_id ' || lv2_parent_table || '.object_id%TYPE, p_daytime DATE, p_attribute_type VARCHAR2, p_compare_oper VARCHAR2 DEFAULT ''='')';

                FOR function_cursor IN attribute_function_code(p_object_name, lv2_parent_table, lv2_parameter_list_attrib, lv2_parameter_list_attrib_ext) LOOP
                           createTextLine(function_cursor.line,p_target);
                 END LOOP;

         END IF;

      END IF;

        ELSE

                ------------------------------------------------------------
                -- single columns, if daytime is not present
                ------------------------------------------------------------

                FOR function_cursor IN coltype_function_code(lv2_table_name, p_object_name, lv2_parameter_list, lv2_where_clause) LOOP
                        createTextLine(function_cursor.line,p_target);
                END LOOP;
                createTextLine('  ',p_target);

                ------------------------------------------------------------
                -- rowtype
                ------------------------------------------------------------
                FOR function_cursor IN rowtype_function_code(p_object_name, lv2_parameter_list, lv2_where_clause) LOOP
                        createTextLine(function_cursor.line,p_target);
                END LOOP;
                createTextLine('  ',p_target);

                FOR function_cursor IN rowtype_object_function_code(p_object_name) LOOP
                        createTextLine(function_cursor.line,p_target);
                END LOOP;
                createTextLine('  ',p_target);

        END IF;


        ------------------------------------------------------------
        -- CREATE PACKAGE FOOTER
        ------------------------------------------------------------

        createTextLine('END ec_' || lv2_package_name || ';',p_target);

        IF p_target = 'CREATE' THEN
          Ecdp_Dynsql.SafeBuild('EC_' || lv2_package_name,'PACKAGE',pv_lines,p_target,'Y');

        ELSE
          createTextLine('/ ',p_target);
          createTextLine(' ',p_target);
        END IF;

END writePackageBody;
-- End procedure



----------------------------------------------------------------------------------
-- Procedure : writePackageViews
-- Purpose   : Writes the views of the package
----------------------------------------------------------------------------------
PROCEDURE writePackageViews(p_object_name        VARCHAR2,
                            p_view_pk_table_name VARCHAR2,
                            p_target VARCHAR2 DEFAULT 'CREATE'
                            ) IS

-- Local variables used in procedure
lv2_parameter_list   VARCHAR2(2000);

lv2_view_name_m      VARCHAR2(32);
lv2_view_name_y      VARCHAR2(32);
lv2_view_name_t      VARCHAR2(32);
lv2_pk_list          VARCHAR2(2000);

lv2_table_name       VARCHAR2(32);

ln_func_l            NUMBER := 25;
ln_view_l            NUMBER := 28;

ln_count             NUMBER;


-- Local cursors used in procedure

-- Mtd view
CURSOR mtd_view_line(p_table          VARCHAR2,
                     p_parameter_list VARCHAR2) IS
SELECT
   Decode(mtd_cumulative,'Y',
   ', ec_' || Lower(p_table) || '.cumm_' || Nvl(Lower(alias_name), Lower(Substr(column_name,1,ln_func_l))) || p_parameter_list ||
   ' CUMM_' || Nvl(Upper(alias_name), Upper(Substr(column_name,1,ln_func_l))) ) || chr(10) ||
   Decode(mtd_average,'Y',
   ', ec_' || Lower(p_table) || '.avem_' || Nvl(Lower(alias_name), Lower(Substr(column_name,1,ln_func_l))) || p_parameter_list ||
   ' AVEM_' || Nvl(Upper(alias_name), Upper(Substr(column_name,1,ln_func_l))) ) line
FROM  ctrl_gen_function
WHERE (mtd_cumulative = 'Y' OR mtd_average = 'Y')
AND   table_name = p_table
AND   calc_type IN ('COLUMN','CALC');


-- Ytd view
CURSOR ytd_view_line(p_table          VARCHAR2,
                     p_parameter_list VARCHAR2) IS
SELECT
   Decode(ytd_cumulative,'Y',
   ', ec_' || Lower(p_table) || '.cumy_' || Nvl(Lower(alias_name), Lower(Substr(column_name,1,ln_func_l))) || p_parameter_list ||
   ' CUMY_' || Nvl(Upper(alias_name), Upper(Substr(column_name,1,ln_func_l))) ) || chr(10) ||
   Decode(ytd_average,'Y',
   ', ec_' || Lower(p_table) || '.avey_' || Nvl(Lower(alias_name), Lower(Substr(column_name,1,ln_func_l))) || p_parameter_list ||
   ' AVEY_' || Nvl(Upper(alias_name), Upper(Substr(column_name,1,ln_func_l))) ) line
FROM  ctrl_gen_function
WHERE (ytd_cumulative = 'Y' OR ytd_average = 'Y')
AND   table_name = p_table
AND   calc_type IN ('COLUMN','CALC');


-- Ttd view
CURSOR ttd_view_line(p_table          VARCHAR2,
                     p_parameter_list VARCHAR2) IS
SELECT
   Decode(ttd_cumulative,'Y',
   ', ec_' || Lower(p_table) || '.cumt_' || Nvl(Lower(alias_name), Lower(Substr(column_name,1,ln_func_l))) || p_parameter_list ||
   ' CUMT_' || Nvl(Upper(alias_name), Upper(Substr(column_name,1,ln_func_l))) ) || chr(10) ||
   Decode(ttd_average,'Y',
   ', ec_' || Lower(p_table) || '.avet_' || Nvl(Lower(alias_name), Lower(Substr(column_name,1,ln_func_l))) || p_parameter_list ||
   ' AVET_' || Nvl(Upper(alias_name), Upper(Substr(column_name,1,ln_func_l))) ) line
FROM  ctrl_gen_function
WHERE (ttd_cumulative = 'Y' OR ttd_average = 'Y')
AND   table_name = p_table
AND   calc_type IN ('COLUMN','CALC');

-- Start procedure
BEGIN

        pv_lines.delete;

        lv2_parameter_list := Null;
        lv2_table_name := Nvl(p_view_pk_table_name, p_object_name);

        -----------------------------------------------------------
        -- BUILD LIST OF COLUMNS BEING PART OF PK
        -----------------------------------------------------------
        FOR qualify_cur IN c_qualifier_list(lv2_table_name) LOOP
                IF lv2_parameter_list IS NULL THEN
                        lv2_parameter_list := Lower(qualify_cur.column_name);
                ELSE
                        lv2_parameter_list := lv2_parameter_list || ', ' || Lower(qualify_cur.column_name);
                END IF;
        END LOOP;

        IF upper(p_object_name) like '%DAY%' THEN
                lv2_view_name_m := Replace(Lower(Substr(p_object_name,1,ln_view_l)),'day', 'mtd');
                lv2_view_name_y := Replace(Lower(Substr(p_object_name,1,ln_view_l)),'day', 'ytd');
                lv2_view_name_t := Replace(Lower(Substr(p_object_name,1,ln_view_l)),'day', 'ttd');
        ELSIF upper(p_object_name) like '%MTH%' THEN
                lv2_view_name_m := Replace(Lower(Substr(p_object_name,1,ln_view_l)),'mth', 'mmtd');     -- should not be used
                lv2_view_name_y := Replace(Lower(Substr(p_object_name,1,ln_view_l)),'mth', 'mytd');
                lv2_view_name_t := Replace(Lower(Substr(p_object_name,1,ln_view_l)),'mth', 'mttd');
        ELSE
                lv2_view_name_m := 'mtd_' || Lower(Substr(p_object_name,1,ln_view_l));
                lv2_view_name_y := 'ytd_' || Lower(Substr(p_object_name,1,ln_view_l));
                lv2_view_name_t := 'ttd_' || Lower(Substr(p_object_name,1,ln_view_l));
        END IF;

        IF Lower(Substr(p_object_name,1,2)) <> 'v_' THEN
                lv2_view_name_m := 'v_' || lv2_view_name_m;
                lv2_view_name_y := 'v_' || lv2_view_name_y;
                lv2_view_name_t := 'v_' || lv2_view_name_t;
        END IF;

        lv2_pk_list := lv2_parameter_list;
        lv2_parameter_list := '(' || lv2_parameter_list || ')';

        ------------------------------------------------------------
        -- CREATE MTD VIEWS
        ------------------------------------------------------------
        ln_count := 0;
        FOR view_cursor IN mtd_view_line(p_object_name, lv2_parameter_list) LOOP
                ln_count := ln_count + 1;
        END LOOP;

        IF ln_count > 0 THEN
                IF p_target <> 'CREATE' THEN
                  createTextLine('---',p_target);
                  createTextLine('PROMPT Creating view ' || UPPER(lv2_view_name_m) || ';',p_target);
                END IF;

                createTextLine('CREATE OR REPLACE FORCE VIEW ' || lv2_view_name_m || ' AS',p_target);
                createTextLine('----------------------------------------------------------------------------',p_target);
                createTextLine('-- View name: ' || lv2_view_name_m ,p_target);
                createTextLine('-- Generated by EC_GENERATE.',p_target);
                createTextLine('----------------------------------------------------------------------------');
                createTextLine('SELECT ' || Nvl(lv2_pk_list,'sysnam'),p_target);

                FOR view_cursor IN mtd_view_line(p_object_name, lv2_parameter_list) LOOP
                        createTextLine(view_cursor.line,p_target);
                END LOOP;

                createTextLine('FROM ' || p_object_name,p_target);
                IF p_target = 'CREATE' THEN

                  Ecdp_Dynsql.SafeBuild(lv2_view_name_m,'VIEW',pv_lines,p_target,'Y');
                  pv_lines.delete;

                ELSE
                  createTextLine('/',p_target);
                END IF;

        END IF;

        ------------------------------------------------------------
        -- CREATE YTD VIEWS
        ------------------------------------------------------------
        ln_count := 0;
        FOR view_cursor IN ytd_view_line(p_object_name, lv2_parameter_list) LOOP
                ln_count := ln_count + 1;
        END LOOP;

        IF ln_count > 0 THEN
                createTextLine('---',p_target);
                createTextLine('CREATE OR REPLACE FORCE VIEW ' || lv2_view_name_y || ' AS',p_target);
                createTextLine('----------------------------------------------------------------------------',p_target);
                createTextLine('-- View name: ' || lv2_view_name_y,p_target);
                createTextLine('-- Generated by EC_GENERATE.',p_target);
                createTextLine('----------------------------------------------------------------------------',p_target);
                createTextLine('SELECT ' || Nvl(lv2_pk_list,'sysnam'),p_target);

                FOR view_cursor IN ytd_view_line(p_object_name, lv2_parameter_list) LOOP
                        createTextLine(view_cursor.line,p_target);
                END LOOP;

                createTextLine('FROM ' || p_object_name,p_target);

                IF p_target = 'CREATE' THEN

                  Ecdp_Dynsql.SafeBuild(lv2_view_name_y,'VIEW',pv_lines,p_target,'Y');
                  pv_lines.delete;

                ELSE
                  createTextLine('/',p_target);
                  createTextLine(' ',p_target);
                END IF;


        END IF;

        ------------------------------------------------------------
        -- CREATE TTD VIEWS
        ------------------------------------------------------------
        ln_count := 0;
        FOR view_cursor IN ttd_view_line(p_object_name, lv2_parameter_list) LOOP
                ln_count := ln_count + 1;
        END LOOP;

        IF ln_count > 0 THEN
                createTextLine('---',p_target);
                createTextLine('CREATE OR REPLACE FORCE VIEW ' || lv2_view_name_t || ' AS',p_target);
                createTextLine('----------------------------------------------------------------------------',p_target);
                createTextLine('-- View name: ' || lv2_view_name_t ,p_target);
                createTextLine('-- Generated by EC_GENERATE.',p_target);
                createTextLine('----------------------------------------------------------------------------',p_target);
                createTextLine('SELECT ' || Nvl(lv2_pk_list,'sysnam'),p_target);

                FOR view_cursor IN ttd_view_line(p_object_name, lv2_parameter_list) LOOP
                        createTextLine(view_cursor.line,p_target);
                END LOOP;

                createTextLine('FROM ' || p_object_name,p_target);
                IF p_target = 'CREATE' THEN

                  Ecdp_Dynsql.SafeBuild(lv2_view_name_y,'VIEW',pv_lines,p_target,'Y');
                  pv_lines.delete;

                ELSE
                  createTextLine('/',p_target);
                  createTextLine(' ',p_target);

                END IF;

        END IF;

END writePackageViews;
-- End writePackageViews



-------------------------------------------------------------------------------------------------------
-- Procedure    :  generatePackages()
--
-- Purpose      :  Generates functions to provide totals and averages of table columns through a period.
--                 Generates single column functions to return a value based on PK.
--                 Generates rowtype function to return a record based on PK.
--                 Generates functions returning a calculated value based on PK.
--
-- General Logic:  For every table spesified in table 'ctrl_object' with 'math' column set to 'Y' a
--                 math_<colomn_name> function is generated. Cum/Ave functions are generated for the columns
--                 spesified in 'ctrl_gen_function'
--                 is generated.
--
-- Call interface: p_table:  Provide a specific table name as a string in upper case.
--                           If NULL is given all tables in ctrl_object may be processed.
--                 p_append: When p_target is set to 'FILE' and this option is set to 'Y' it will
--                           append the generated code as records in the t_temptext table following any
--                           previously generated code procedure.
--                 p_missing_ind: If this option is set to 'Y' only tables in ctrl_object missing ec-packages
--                                 are processed.
--
--                 p_target: If this option is set to 'CREATE' or NULL the packages are deployed in the
--                           database at once with the execute immediate command. If set to
--                           something the code will be generated to t_temptext only.
--
--                 SQL> execute generate.ec_packages('VALHALL',NULL)
--                 Result can be selected from t_temptext, id='EC_PACKAGES'.
--                 Use cre%-like script available.
--
-- Preconditions:  The tables 'ctrl_gen_function' and 'ctrl_object' should be configured to contain information
--                 about the tables the procedure should generate ec-packages for.
--
-- Created:     02.12.97  Dagfinn Njå
--
-- Modification history:
--
-- Date:      Whom: Change description:
----------   ----- --------------------------------------------
-- 03.12.98   HNE
-- 30.03.99   HNE
-- 24.02.00   UMF   Spliteted the procedure into three different subroutines.
--                  Added math_, prev_equal_daytime and next_equal_daytime-functions.
--                  Added logic to generate ec-packages for all tables in 'ctrl_object', and
--                  math-functions for tables spesified with 'Y' in the 'math' column.
-------------------------------------------------------------------------------------------------------
PROCEDURE generatePackages(p_table  VARCHAR2, p_append VARCHAR2 DEFAULT NULL, p_missing_ind VARCHAR2 DEFAULT NULL , p_target VARCHAR2 DEFAULT 'CREATE') IS

-- Choose those tables which should be iterated trough with a given column or formula.
CURSOR c_distinct_tables(cp_table  VARCHAR2, cp_missing_ind VARCHAR2) IS
SELECT o.object_name,
       o.view_pk_table_name
FROM   ctrl_object o
WHERE  o.object_name = Nvl(cp_table, o.object_name)
AND NOT EXISTS (
SELECT 1 FROM user_objects uo
WHERE uo.object_type = 'PACKAGE'
AND Nvl(cp_missing_ind,'N') = 'Y'
AND uo.object_name = 'EC_' || o.object_name
)
;

-- Start procedure
BEGIN

        pv_id := 'EC_PACKAGES';

        IF p_target <> 'CREATE' THEN
          initiate(p_append);
        END IF;

        FOR table_cursor IN c_distinct_tables(p_table, p_missing_ind) LOOP

                writePackageHeader(table_cursor.object_name, table_cursor.view_pk_table_name,p_target);
                writePackageBody(table_cursor.object_name, table_cursor.view_pk_table_name,p_target);
                writePackageViews(table_cursor.object_name, table_cursor.view_pk_table_name,p_target);

        END LOOP;
        -- Commit all the work
        commit;

END generatePackages;
-- End procedure

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : getAttributeParentTable
-- Description    : Returns the table name of the parent of a %_ATTRIBUTE table.
--                  The parent table must contain a column with the name OBJECT_ID,
--                  which is not null, and part of a primary key or a unique key.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------

FUNCTION getAttributeParentTable(p_table VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS

  lv2_attribute_table_fk   VARCHAR2(200);
  lv2_test                 VARCHAR2(200) := 'A';
  lv2_parent_table_pk      VARCHAR2(200);
  lv2_parent_table         VARCHAR2(200);
  lv2_object               VARCHAR2(200);

  CURSOR c_ref_key_constrant(cp_constraint_name VARCHAR2, cp_table_name VARCHAR2) IS
  SELECT   *
  FROM     user_constraints
  WHERE    constraint_name = cp_constraint_name
  AND      table_name = cp_table_name;

  CURSOR c_ui_constraint(cp_constraint_name VARCHAR2) IS
  SELECT   *
  FROM     user_constraints
  WHERE    constraint_name = cp_constraint_name
  AND      constraint_type IN ('P','U');

  -- Cursor that contain table_name and primary key name for all %ATTRIBUTE tables
  CURSOR c_attribute_tables IS
    SELECT  ut.table_name, uc.constraint_name
    FROM    user_tables ut, user_constraints uc
    WHERE   ut.table_name = uc.table_name
    AND     ut.table_name = p_table
    AND     uc.constraint_type = 'P';

  -- Cursor that contain all keys in a table that have a referance to another table
  CURSOR c_fk (v_tab VARCHAR2) IS
    SELECT  constraint_name
    FROM    user_constraints
    WHERE   table_name = v_tab
    AND     constraint_type = 'R';

  -- Cursor that looks for a foreign key that reference a primary key in the parent table
  CURSOR c_parent_fk (v_table VARCHAR2, v_pk_constraint VARCHAR2, v_constraint VARCHAR2) IS
    SELECT  column_name
    FROM    user_cons_columns
    WHERE   table_name = v_table
    AND     constraint_name = v_pk_constraint
    AND     column_name NOT IN ('DAYTIME','ATTRIBUTE_TYPE')
    MINUS
    SELECT  column_name
    FROM    user_cons_columns
    WHERE   table_name = v_table
    AND     constraint_name = v_constraint;

  -- Cursor that check if the parent table contain a column with the name OBJECT_ID, and
  -- that this column is NOT NULL and it is part of a primary or uniqe key
  CURSOR c_object (v_parent_table VARCHAR2, cp_table_name VARCHAR2, cp_fk_constraint VARCHAR2) IS
    SELECT  utc.column_name
    FROM    user_tab_columns utc, user_constraints uc, user_cons_columns ucc
    WHERE   utc.table_name = uc.table_name
    AND     uc.table_name = ucc.table_name
    AND     uc.constraint_name = ucc.constraint_name
    AND     utc.table_name = v_parent_table
    AND     utc.column_name = 'OBJECT_ID'
    AND     utc.nullable = 'N'
    AND     uc.constraint_type in ('U','P')
    AND     ucc.column_name = 'OBJECT_ID'
    AND NOT EXISTS (
      SELECT 1 FROM user_constraints uc2
      WHERE uc2.table_name = cp_table_name
      AND uc2.constraint_name = cp_fk_constraint
      AND uc2.constraint_type = 'R'
      AND uc2.r_constraint_name = uc.constraint_name
    );

BEGIN

  FOR att_tab_rec IN c_attribute_tables LOOP

    -- Start of loop that search for the foreign key that reference the parent table for the %_ATTRIBUTE table
    FOR fk_rec IN c_fk (att_tab_rec.table_name) LOOP

      -- Variable used to find the correct foreign key
      lv2_attribute_table_fk := fk_rec.constraint_name;

      -- Check the cursor c_fk. If this cursor returns a record then exit
      FOR parent_fk_rec IN c_parent_fk (att_tab_rec.table_name, att_tab_rec.constraint_name, fk_rec.constraint_name) LOOP
        lv2_test := fk_rec.constraint_name;
        EXIT;
      END LOOP;

      -- If these two variables is not equal then the right foreign key is found
      IF lv2_attribute_table_fk <> lv2_test THEN

        EXIT;

      END IF;

    END LOOP; -- End of the loop that gets the foreign key that reference the parent table

   -- Search for the primary key for the parent table
   FOR cur_rec IN c_ref_key_constrant(lv2_attribute_table_fk, att_tab_rec.table_name) LOOP

      lv2_parent_table_pk := cur_rec.r_constraint_name;

   END LOOP;

   -- Search for the name of the parent table
   FOR cur_rec IN c_ui_constraint(lv2_parent_table_pk) LOOP

      lv2_parent_table := cur_rec.table_name;

   END LOOP;

  END LOOP;  -- all ATTRIBUTE tables

  -- Check that it exists a column with the name OBJECT_ID in the parent table (that is not null)

  lv2_object := null;

  FOR object_rec IN c_object(lv2_parent_table, p_table, lv2_attribute_table_fk) LOOP
      lv2_object := object_rec.column_name;
      EXIT;
  END LOOP;

  IF lv2_object IS NULL THEN

     lv2_parent_table := NULL;

  END IF;

  RETURN lv2_parent_table;

END getAttributeParentTable;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : CreatePINCTriggers
-- Description    : This procedure creates after Insert, Update, Delete triggers for logging table content
--                  changes during install time modus. This trigger will be created for all tables
--                  except the tables listed in the hardcoded exception list in this procedure
-- Postconditions :
--
-- Using tables   : user_tables
--                  user_tab_columns
--                  t_temptext
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : If p_table_name is null basic triggers will be generated for all tables
--                  If p_table_name is given a basic trigger for that table only is generated.
---------------------------------------------------------------------------------------------------
PROCEDURE CreatePINCTriggers(p_table_name VARCHAR2 DEFAULT NULL, p_missing_ind VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

CURSOR c_basic_trigger(cp_table_name VARCHAR2, cp_missing_ind VARCHAR2) IS
SELECT t.table_name
FROM user_tables t
WHERE t.table_name = Nvl(cp_table_name, t.table_name)
AND t.table_name NOT LIKE '%_JN'
AND NOT EXISTS (
SELECT 1 FROM user_triggers ut
WHERE ut.table_name = t.table_name
AND Nvl(cp_missing_ind,'N') = 'Y'
AND ut.trigger_name = 'AP_' || substr(t.table_name,1,27)
);

CURSOR c_pinc_keys(cp_table_name VARCHAR2, cp_col_name VARCHAR2) IS
SELECT  data_type, column_name
FROM user_tab_columns utc
WHERE data_type NOT IN ('BLOB','CLOB')
AND table_name = cp_table_name
AND column_name = cp_col_name
AND EXISTS (
SELECT 1
FROM user_constraints uc, user_cons_columns ucc
WHERE uc.table_name = utc.table_name
AND uc.constraint_type IN ('P')
AND ucc.owner = uc.owner
AND ucc.constraint_name = uc.constraint_name
AND ucc.table_name = uc.table_name
AND ucc.column_name = utc.column_name
)
ORDER BY COLUMN_ID;

CURSOR c_pinc_cols(cp_table_name VARCHAR2) IS
SELECT  data_type, column_name
FROM user_tab_columns utc
WHERE data_type NOT IN ('BLOB','CLOB')
AND table_name = cp_table_name
AND column_name NOT IN ('RECORD_STATUS','CREATED_BY','CREATED_DATE','LAST_UPDATED_BY'
                        ,'LAST_UPDATED_DATE','REV_NO','REV_TEXT')
ORDER BY COLUMN_ID;


TYPE t_table_list_type IS TABLE OF VARCHAR2(50);

lt_exception_tables  t_table_list_type := t_table_list_type('CARGO_ANALYSIS','CARGO_ANALYSIS_ITEM','CARGO_DEMURRAGE','CARGO_LIFTING_DELAY','CARGO_TRANSPORT'
                                      ,'CARRIER_INSPECTION','CHEM_TANK_PRODUCT','CHEM_TANK_STATUS','EQPM_DAY_STATUS','EQPM_RESULT'
                                      ,'EQPM_SAMPLE','EQUITY_SHARE','FCTY_DAY_ALARM','FCTY_DAY_HSE','FCTY_DAY_POB','FCTY_DAY_VESSEL'
                                      ,'FCTY_SPILL_EVENT','FLOWLINE_SUB_WELL_CONN','IFLW_DAY_STATUS','IWEL_DAY_ALLOC','IWEL_DAY_STATUS'
                                      ,'IWEL_MTH_ALLOC','IWEL_PERIOD_STATUS','LIFTING_ACTIVITY','LIFT_ACCOUNT_MTH_BALANCE'
                                      ,'LIFT_ACCOUNT_TRANSACTION','OBJECT_DAY_WEATHER','OBJECT_ITEM_COMMENT','PFLW_DAY_STATUS'
                                      ,'PFLW_RESULT','PFLW_SAMPLE','PROD_FORECAST','PROD_WELL_FORECAST','PROD_STRM_FORECAST','PROD_FCTY_FORECAST','PRODUCT_ANALYSIS_ITEM','PRODUCT_MEAS_SETUP'
                                      ,'PRODUCT_PRICE','PWEL_DAY_ALLOC','PWEL_DAY_COMP_ALLOC','PWEL_DAY_STATUS','PWEL_MTH_ALLOC'
                                      ,'PWEL_MTH_COMP_ALLOC','PWEL_PERIOD_STATUS','PWEL_RESULT','PWEL_SAMPLE','PWEL_SUB_DAY_STATUS'
                                      ,'SCTR_ACC_PERIOD_STATUS','SCTR_DAY_DP_DELIVERY','SCTR_DAY_DP_FORECAST','SCTR_DAY_DP_NOM'
                                      ,'SCTR_DELIVERY_EVENT','SCTR_DELIVERY_PNT_USAGE','SCTR_PERIOD_STATUS','SCTR_SUB_DAY_DP_DELIVERY'
                                      ,'SCTR_SUB_DAY_DP_FORECAST','SCTR_SUB_DAY_DP_NOM','SCTR_UNIT_PRICE','STORAGE_LIFTING'
                                      ,'STORAGE_LIFT_NOMINATION','STOR_DAY_COENT_FORECAST','STOR_MTH_COENT_FORECAST','STOR_PERIOD_EXPORT_STATUS'
                                      ,'STRM_DAY_ALLOC','STRM_DAY_COMP_ALLOC','STRM_DAY_STREAM','STRM_EVENT','STRM_MTH_ALLOC'
                                      ,'STRM_MTH_COMP_ALLOC','STRM_MTH_STREAM','STRM_WATER_ANALYSIS','TANK_MEASUREMENT','TANK_STRAPPING'
                                      ,'TANK_USAGE','WEBO_INTERVAL_GOR','WEBO_PLT','WEBO_PLT_RESULT','WEBO_PRESSURE_TEST','WEBO_SPLIT_FACTOR'
                                      ,'WELL_CHRONOLOGY','CTRL_PINC','CTRL_PINC_REPORT','T_TEMPTEXT', 'NAV_MODEL_OBJECT_RELATION', 'CALC_OBJECT_META', 'CALC_ATTRIBUTE_META', 'CALC_VARIABLE_META');



lv2_trigger_body DBMS_SQL.varchar2a;
lv2_insert_Pinc VARCHAR2(32000);
ln_pinc_count NUMBER;
ln_key_count NUMBER;
lb_pinc_log BOOLEAN;
--lv2_pinc_key VARCHAR2(32000);
lv2_col_prefix VARCHAR2(50);

BEGIN

   ------------------------------------------------------------
   -- Trigger definition
   ------------------------------------------------------------

        FOR CurTab IN c_basic_trigger(p_table_name, p_missing_ind) LOOP

      lv2_trigger_body.delete;
      lb_pinc_log :=  TRUE;

      FOR i IN 1..lt_exception_tables.count LOOP
        IF lt_exception_tables(i) = CurTab.table_name THEN
           lb_pinc_log :=  FALSE;
           EXIT;
        END IF;
      END LOOP;

      IF lb_pinc_log THEN

         Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'CREATE OR REPLACE TRIGGER AP_' || substr(CurTab.table_name,1,27) || chr(10));
         Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'AFTER INSERT OR UPDATE OR DELETE ON ' || CurTab.table_name || chr(10) );
         Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'FOR EACH ROW ' || chr(10) );

         Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'  DECLARE ' || chr(10) );
         Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'    lv2_InstallModeTag varchar2(240); ' || chr(10) );
         Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'    lcl_row BLOB; ' || chr(10) );
         Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'    lv2_key VARCHAR2(4000); ' || chr(10) );
         Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'    lv2_operation VARCHAR2(30); ' || chr(10) );

         Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'BEGIN ' || chr(10) );
         Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'    -- Note, this is a autogenerated trigger, do not put handcoded logic here.' || chr(10) );

         Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'    lv2_InstallModeTag := ecdp_pinc.getInstallModeTag;' || chr(10) );

         Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'    IF lv2_InstallModeTag IS NOT NULL THEN' || CHR(10) );

         Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'      dbms_lob.createtemporary(lcl_row, TRUE, dbms_lob.CALL);' ||CHR(10) );
         Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'      lv2_key := NULL;'||CHR(10)||CHR(10) );

         Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'      IF INSERTING OR UPDATING THEN'||CHR(10)||CHR(10) );

         ln_pinc_count := 0;
         ln_key_count := 0;

         FOR curPincCols IN c_pinc_cols(CurTab.table_name) LOOP

            IF curPincCols.data_type = 'DATE' THEN
               Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'        dbms_lob.append(lcl_row,utl_raw.cast_to_raw('''||curPincCols.column_name||
                                      '=''|| to_char(:new.'||curPincCols.column_name||',''yyyy.mm.dd hh24:mi:ss'') ||'';''));'||chr(10) );
            ELSIF curPincCols.data_type = 'NUMBER' THEN
               Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'        dbms_lob.append(lcl_row,utl_raw.cast_to_raw('''||curPincCols.column_name||
                                      '=''|| TO_CHAR(:new.'||curPincCols.column_name||',''9999999999999999D9999999999'',''NLS_NUMERIC_CHARACTERS=''''.,'''''') ||'';''));'||CHR(10) );
            ELSE
               --Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'        IF :new.'||curPincCols.column_name||' IS NOT NULL THEN' || CHR(10) );
               Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'        dbms_lob.append(lcl_row,utl_raw.cast_to_raw('''||curPincCols.column_name||
                                      '=''|| Replace(:new.'||curPincCols.column_name||',chr(39),chr(39)||chr(39)) ||'';''));'||CHR(10) );
               --Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'        ELSE' || CHR(10) );
               --Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'           dbms_lob.append(lcl_row,utl_raw.cast_to_raw('''||curPincCols.column_name||
               --                       '=NULL;''));'||CHR(10) );
               --Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'        END IF;' || CHR(10) );
            END IF;
            ln_pinc_count := ln_pinc_count + 1;

            FOR curPincKey IN c_pinc_keys(CurTab.table_name,curPincCols.column_name) LOOP
               IF ln_key_count = 0 THEN
                 lv2_col_prefix := '        lv2_key := ''';
               ELSE
                 lv2_col_prefix := '        lv2_key := lv2_key ||'' AND ';
               END IF;

              IF curPincKey.data_type = 'DATE' THEN
                Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,lv2_col_prefix||'to_char('||curPincKey.column_name||
                                      ',''''yyyy.mm.dd hh24:mi:ss'''')=''''''|| to_char(:new.'||curPincKey.column_name||',''yyyy.mm.dd hh24:mi:ss'') || '''''''';'||CHR(10) );
              ELSIF curPincKey.data_type = 'NUMBER' THEN
                Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,lv2_col_prefix||curPincKey.column_name||
                                      '=''|| to_char(:new.'||curPincKey.column_name||',''9999999999999999D9999999999'',''NLS_NUMERIC_CHARACTERS=''''.,'''''');'||CHR(10) );
              ELSE
                Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,lv2_col_prefix||curPincKey.column_name||
                                      '=''''''|| Replace(:new.'||curPincKey.column_name||',chr(39),chr(39)||chr(39)) ||'''''''';'||CHR(10) );
              END IF;

              ln_key_count := ln_key_count + 1;
           END LOOP;

         END LOOP;

         Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,CHR(10) );
         Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'      ELSE'||CHR(10)||CHR(10) );

         ln_pinc_count := 0;
         ln_key_count := 0;

         FOR curPincCols IN c_pinc_cols(CurTab.table_name) LOOP

            IF curPincCols.data_type = 'DATE' THEN
               Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'        dbms_lob.append(lcl_row,utl_raw.cast_to_raw('''||curPincCols.column_name||
                                      '=''|| to_char(:old.'||curPincCols.column_name||',''yyyy.mm.dd hh24:mi:ss'') ||'';''));'||CHR(10) );
            ELSIF curPincCols.data_type = 'NUMBER' THEN
               Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'        dbms_lob.append(lcl_row,utl_raw.cast_to_raw('''||curPincCols.column_name||
                                      '=''|| TO_CHAR(:old.'||curPincCols.column_name||',''9999999999999999D9999999999'',''NLS_NUMERIC_CHARACTERS=''''.,'''''') ||'';''));'||CHR(10) );
            ELSE
               Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'        dbms_lob.append(lcl_row,utl_raw.cast_to_raw('''||curPincCols.column_name||
                                      '=''|| Replace(:old.'||curPincCols.column_name||',chr(39),chr(39)||chr(39)) ||'';''));'||CHR(10) );
            END IF;
            ln_pinc_count := ln_pinc_count + 1;

            FOR curPincKey IN c_pinc_keys(CurTab.table_name,curPincCols.column_name) LOOP
              IF ln_key_count = 0 THEN
                lv2_col_prefix := '        lv2_key := ''';
              ELSE
                lv2_col_prefix := '        lv2_key := lv2_key ||'' AND ';
              END IF;

              IF curPincKey.data_type = 'DATE' THEN
                Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,lv2_col_prefix||'to_char('||curPincKey.column_name||
                                      ',''''yyyy.mm.dd hh24:mi:ss'''')=''''''|| to_char(:old.'||curPincKey.column_name||',''yyyy.mm.dd hh24:mi:ss'') || '''''''';'||CHR(10) );

              ELSIF curPincKey.data_type = 'NUMBER' THEN
                Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,lv2_col_prefix||curPincKey.column_name||
                                      '=''|| to_char(:old.'||curPincKey.column_name||',''9999999999999999D9999999999'',''NLS_NUMERIC_CHARACTERS=''''.,'''''');'||CHR(10) );
              ELSE
                Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,lv2_col_prefix||curPincKey.column_name||
                                      '=''''''|| Replace(:new.'||curPincKey.column_name||',chr(39),chr(39)||chr(39)) ||'''''''';'||CHR(10) );
              END IF;
              ln_key_count := ln_key_count + 1;

           END LOOP;

         END LOOP;

         Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,CHR(10) );
         Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'      END IF;'||CHR(10)||CHR(10) );

         Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,CHR(10) );
         Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'      IF INSERTING THEN'||CHR(10) );
         Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'        lv2_operation := ''INSERTING'';'||CHR(10) );
         Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'      ELSIF UPDATING THEN'||CHR(10) );
         Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'         lv2_operation := ''UPDATING'';'||CHR(10) );
         Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'      ELSE'||CHR(10) );
         Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'         lv2_operation := ''DELETING'';'||CHR(10) );
         Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'      END IF;'||CHR(10) );

         Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'      EcDp_PInC.logTableContent('''||CurTab.table_name||''''||CHR(10) );
         Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'                          ,lv2_operation'||CHR(10) );
         Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'                          ,lv2_key'||CHR(10) );
         Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'                          ,lcl_row);'||CHR(10) );
         --Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'      dbms_lob.close(lcl_row);' ||CHR(10) );

        ln_pinc_count := 0;
        Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'    END IF;' || chr(10) );
        Ecdp_Dynsql.AddSqlLine(lv2_trigger_body,'END;' || chr(10) );

                Ecdp_Dynsql.SafeBuild('AP_' || substr(CurTab.table_name,1,27),'TRIGGER',lv2_trigger_body, 'CREATE');

      END IF; -- lb_pinc_log

                END LOOP;

END CreatePINCTriggers;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : IURTriggers
-- Description    : This procedure creates  before insert or update table triggers for
--                  tables having standard revision columns and REC_ID.
-- Postconditions :
--
-- Using tables   : user_tables
--                  user_tab_columns
--                  t_temptext
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : If p_table_name is null triggers will be generated for all tables
--                  If p_table_name is given a trigger for that table only is generated.
---------------------------------------------------------------------------------------------------
PROCEDURE IURTriggers(p_table_name VARCHAR2 DEFAULT NULL, p_missing_ind VARCHAR2 DEFAULT NULL, p_target VARCHAR2 DEFAULT 'CREATE')
--</EC-DOC>
IS

CURSOR c_basic_trigger(cp_table_name VARCHAR2, cp_missing_ind VARCHAR2) IS
SELECT t.table_name
FROM user_tables t, user_tab_columns utc
WHERE t.table_name = Nvl(cp_table_name, t.table_name)
AND t.table_name NOT LIKE '%_JN'
AND utc.table_name = t.table_name
AND utc.column_name = 'REV_NO'
AND NOT EXISTS (
SELECT 1 FROM user_triggers ut
WHERE ut.table_name = t.table_name
AND Nvl(cp_missing_ind,'N') = 'Y'
AND ut.trigger_name = 'IUR_' || substr(t.table_name,1,26)
);


lv2_trigger_body VARCHAR2(4000);

BEGIN

        IF p_target <> 'CREATE' THEN

          DELETE FROM t_temptext WHERE id='EC_TRIGGERS';

        END IF;

        pv_lines.delete;


        pv_id :='EC_TRIGGERS';
        pv_line_number :=0;

   ------------------------------------------------------------
   -- Trigger definition
   ------------------------------------------------------------

   IF p_target <> 'CREATE' THEN
     createTextLine('------------------------------------------------------------',p_target);
     createTextLine('-- EC IUR triggers - generated by EC BASIS ' ||
     to_char(sysdate,'dd.mm.yyyy hh24:mi'),p_target);
     createTextLine('------------------------------------------------------------',p_target);
   END IF;

        FOR CurTab IN c_basic_trigger(p_table_name, p_missing_ind) LOOP

           IF column_exist(CurTab.table_name, 'REC_ID') > 0 THEN
            lv2_trigger_body := 'CREATE OR REPLACE TRIGGER IUR_' || substr(CurTab.table_name,1,26) || chr(10) ||
                          'BEFORE INSERT OR UPDATE ON ' || CurTab.table_name || chr(10) ||
                          'FOR EACH ROW ' || chr(10) ||
                          'DECLARE' || chr(10) ||
                          'o_rec_id          VARCHAR2(32) := :OLD.rec_id;'|| chr(10) ||
                          'BEGIN ' || chr(10) ||
                          '    IF Inserting THEN ' || chr(10) ||
                          '      IF :new.rec_id IS NULL THEN ' || chr(10) ||
                          '         :new.rec_id := SYS_GUID();' || chr(10) ||
                          '      END IF;' || chr(10) ||
                          '    ELSE ' || chr(10) ||
                          '         IF o_rec_id is null THEN' || chr(10) ||
                          '            o_rec_id := SYS_GUID();' || chr(10) ||
                          '          END IF;' || chr(10) ||
                          '          IF NOT UPDATING(''REC_ID'') THEN'  || chr(10) ||
                          '            :new.rec_id := o_rec_id;' || chr(10) ||
                          '          END IF;'|| chr(10)||
                          '     END IF;'|| chr(10)||
                          'END;';

             createTextLine(lv2_trigger_body, p_target);

              IF p_target = 'CREATE' THEN
               Ecdp_Dynsql.SafeBuild(CurTab.table_name,'TRIGGER',pv_lines,p_target,pv_id,'Y');
               pv_lines.delete;

               ELSE
               createTextLine('/  ',p_target);
               createTextLine('  ',p_target);
                END IF;
            END IF;
     END LOOP;

END IURTriggers;



END ec_generate;  -- End package