CREATE OR REPLACE PACKAGE BODY Pck_Gen_Check IS
/**************************************************************
** Package   :  PCK_GEN_CHECK
**
** $Revision: 1.54 $
**
** Purpose   :  Provide general check according to defined entries in CTRL_CHECK_RULES
**
** General Logic: Creates dynamic SQL to perform checks
**
** Created:      08.06.99 HS/HN/TEJ
**
** Modification history:
**
** Date:      Whom:    Change description:
** -------    -----    ------------------------------------------
** 15.05.00   HVE      Included separator data 30min for checking
** 21.10.00   HNE      Enhancement: Be able to run against reporting layer. New table CTRL_CHECK_KEY
** 25.09.2001 FBa      Replaced calls to pck_well and pck_flowline.
**                     Changed UNION to UNION ALL for performance.
**                     Modified logic for STREAM. changed id2 and id3 for stream_code/facility to follow other types. Added equipment for facility as id4.
**                     REQUIRES EcDp_Stream version 3.7 or later
** 25.09.2001 DN       Replaced STOCK check with STORAGE check. Requires that table configuration in
**                     ctrl_check_rules uses new tables. Requires DM r. 6.5.0
** 18.10.2001 FBa      Added functionality for scanning groups. Will require database additions for CTRL_CHECK_RULES and
**                     packages ECG_Groups, EcDp_Equipment. (Maybe more...)
** 01.11.2001 FBa      Added functionality for groups of type Well, Tank and Facility.
**                     Requires EcDp_Tank version 1.0 or later, EcDp_Well version 3.15 or later, EcDp_Facility version 3.5 or later.
** 11.03.2002 DN       Replaced ECG_Groups with EcDp_Groups.getParentCode. Requires revision 1.0 of EcDp_Groups package.
** 27.06.2002 HNE      MPN special, simplified.
** 24.02.2003 HNE      CHAD special.
** 28.04.2003 GOZ      Added new views v_re_equipment_day_conf and v_re_equipment_day_data
** 16.06.2003 HNE      New Facility class
** 12.11.2003 DN       Renamed t_temptekst.
** 18.11.2003 DN       Replaced sysdate with new function.
** 01.12.2003 BIH      Check rule codes escaped as inline params ($$xxx$$) for multi-lingual support
** 12.02.2004 HNE      Placeholders should be replaced with object name and not object code. Changed cursor to return name instead of code.
** 19.03.2004 DN       Fix: op_fcty_code replaced with op_fcty_1_code
** 24.03.2004 HNE      Daytime in V_RE_*_CONF views are now renamed to production_day.
** 21.04.2004 DN       Procedure run_day_check. Cope with exception when p_facility is null.
** 22.04.2004 FBa      Removed functions count_rows, get_next_daytime. Functions were never being called.
** 09.06.2004 SHN      Modified run_day_check to support RV-views, removed old v_re-views
** 17.08.2004 DN       Replaced call to EcDp_Groups.findParentAttributeText.
** 04.11.2004 AV       Commented out dbms_output debug statements
** 16.11.2004 DN       Procedure insert_object_names. Sync. with check rules.
** 25.11.2004 DN       Bug: fixed unexpected exceptions in message logging.
** 14.12.2004 DN       Replaced pck_system witrh EcDp_System. Tracker 1826. Moved getScreenLabel from pck_check to here. Removed pv_commit_level.
** 18.02.2005 Hang     The following codes have been modified in function run_day_check : well_type IN ('WI','GI') to
**                     well_type IN ('WI','GI', 'OPGI', 'GPI'),  AND well_type IN ('OP','GP') to well_type IN ('OP','GP', 'OPGI', 'GPI')
**                     in order to accommodate new well types as per enhancement for TI#1874.
** 09.03.2005 DN       Replaced ec_fcty_attribute.
** 09.11.2005 AV       Changed references to WriteTempText from EcDp_genClasscode to EcDp_DynSQL (code cleanup)
**                     these references where all commented out (debug only).
** 12.07.2006 kaurrnar TI#4118 - Added run_check_all
** 20.08.2006 Toha     TI#3798 - check all performance: major changes
** 17.08.2006 Lau      TI#3998 - Schedule check rule by facility
** 19.10.2006 kaurrjes TI#4653 - Added another lv2_log_message in function insert_object_names
** 08.05.2007 Toha     ECPD5512 - adding screens rules in run_check
** 18.03.2010 leongsei ECPD-12683: Modified run_check to fixe the bug on Validation Job Does not Clear the message log
** 17.05.2010 leongsei ECPD-14769: Modified run_check, run_day_check to fix the bug on Validation Job Does not Clear the message log
** 12.05.2011 RJe      ECPD-17315: Modified run_day_check
** 10.11.2011 leongsei ECPD-16757: Modified procedure run_check, cursor check_group to return correctly
** 30.07.2012 leongsei ECPD-10325: Replaced dbms_output by EcDp_DynSql.WriteDebugText
** 23.07.2013 leongwen ECPD-23778: Modified procedure run_check
** 03.03.2014 kumarsur ECPD-26930: Modified procedure run_check
** 30.10.2014 chooysie ECPD-28784: Modified procedure run_check to pass EQPM instead of parent class to run_day_check
** 15.06.2015 chaudgau ECPD-29553: Modified procedure run_check and log_message to perform commit in autonomous transaction mode
** 01.03.2016 wonggkai ECPD-32090: Modified procedure run_day_check and removed EXISTS filtering
** 31.08.2016 dhavaalo ECPD-38607: Remove usage of EcDp_Utilities.executestatement.
** 07.04.2016 dhavaalo ECPD-44764: Remove extra space.
*****************************************************************/
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : executeStatement                                                          --
-- Description    : Used to run Dyanamic sql statements.
--                                                                                               --
-- Preconditions  :                --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                --
--                                                                                               --
-- Using functions:                                                 --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION executeStatement(
p_statement varchar2)

RETURN VARCHAR2
--</EC-DOC>
IS

li_cursor  integer;
li_ret_val  integer;
lv2_err_string VARCHAR2(32000);

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

FUNCTION insert_object_names(p_statement VARCHAR2, p_name VARCHAR2) RETURN VARCHAR2;
FUNCTION insert_object_codes(p_statement VARCHAR2, p_code VARCHAR2) RETURN VARCHAR2;
FUNCTION execute_sql_number(p_statement VARCHAR2) RETURN NUMBER;
FUNCTION getVerTblPrefix(p_class_name VARCHAR2) RETURN VARCHAR2;
FUNCTION getObjWhereClause(p_obj_list VARCHAR2, p_class_name VARCHAR2) RETURN VARCHAR2;

---------------------------------------------------------------------------
--  PROCEDURE log_message - writes information to log table
--
---------------------------------------------------------------------------
PROCEDURE log_message(p_check_id      NUMBER,
            p_daytime         DATE,
            p_check_group     VARCHAR2,
            p_severity_level  VARCHAR2,
            p_log_message     VARCHAR2,
            p_object_id       VARCHAR2,
            p_class_name      VARCHAR2
            )
IS
PRAGMA AUTONOMOUS_TRANSACTION;

ln_count NUMBER := 0;
CURSOR check_log IS
  SELECT check_id, status
    FROM CTRL_CHECK_LOG
   WHERE check_id = p_check_id
     AND daytime = p_daytime
     AND object_id = p_object_id
;

BEGIN
  FOR CheckLog IN check_log LOOP
    ln_count := ln_count + 1;

    IF CheckLog.status = 'FIXED' THEN
      EcDp_DynSql.WriteDebugText('Pck_Gen_Check.log_message','Log was sat to fixed but is still wrong, about to perform the following update: UPDATE ctrl_check_log SET status = N WHERE check_id = ' ||p_check_id|| ' AND daytime = '||p_daytime||' AND object_id = '||p_object_id, 'DEBUG');
      UPDATE ctrl_check_log SET status = 'N', log_message = p_log_message, last_updated_by = EcDp_Context.getAppUser WHERE check_id = p_check_id AND daytime = p_daytime AND object_id = p_object_id;
    END IF;

    IF CheckLog.status = 'Y' THEN
      EcDp_DynSql.WriteDebugText('Pck_Gen_Check.log_message', 'Log was sat to fixed but is still wrong, about to perform the following update: UPDATE ctrl_check_log SET status = N WHERE check_id = ' ||p_check_id|| ' AND daytime = '||p_daytime||' AND object_id = '||p_object_id, 'DEBUG');
      UPDATE ctrl_check_log SET log_message = p_log_message, last_updated_by = EcDp_Context.getAppUser WHERE check_id = p_check_id AND daytime = p_daytime AND object_id = p_object_id;
    END IF;
  END LOOP;

  IF ln_count = 0 THEN
    EcDp_DynSql.WriteDebugText('Pck_Gen_Check.log_message','No logs for given object_id, check_id and daytime already exists, about to perform the following insert: INSERT INTO CTRL_CHECK_LOG(check_id, daytime, severity_level, log_message,object_id,class_name) VALUES (' || p_check_id ||','|| p_daytime||','|| p_severity_level||','|| p_log_message||','||p_object_id||','||p_class_name||')', 'DEBUG');
    INSERT INTO CTRL_CHECK_LOG(check_id, check_group, daytime, check_daytime, severity_level, log_message,object_id,class_name, created_by) VALUES(p_check_id, p_check_group, p_daytime, Ecdp_Timestamp.getCurrentSysdate, p_severity_level, p_log_message,p_object_id,p_class_name, EcDp_Context.getAppUser);
  END IF;

  COMMIT;

END log_message;


--------------------------------------------------------------------------------------------------------------
-- PROCEDURE RUN_CHECK_ALL
-------------------------------------------------------------------------------------------------------------
PROCEDURE run_check_all ( p_from_date DATE,
                      p_to_date DATE,
                      p_class_type VARCHAR2 DEFAULT NULL,
                      p_fcty_id VARCHAR2 DEFAULT NULL)
IS
  CURSOR object_classes IS
    SELECT class_name
      from class_cnfg t
     WHERE class_type='OBJECT'
       AND EXISTS (SELECT 1 FROM CLASS_CNFG T2
                    WHERE t2.owner_class_name=t.class_name
                      AND t2.class_type='DATA'
                      AND EXISTS (SELECT 1 FROM CTRL_CHECK_RULES where CTRL_CHECK_RULES.TABLE_ID LIKE '%'||T2.CLASS_NAME))
       AND CLASS_NAME=NVL(P_CLASS_TYPE, CLASS_NAME);

BEGIN
  FOR one IN object_classes LOOP
    run_check(p_from_date,
              p_to_date,
              NULL,
              NULL,
              NULL,
              'ALL',
              one.class_name,
              NULL,
              p_fcty_id);
  END LOOP;
END run_check_all;


--------------------------------------------------------------------------------------------------------------
-- PROCEDURE RUN_CHECK
-------------------------------------------------------------------------------------------------------------
PROCEDURE run_check(  p_from_date DATE,
                      p_to_date DATE,
                      p_object_where_clause VARCHAR2,
                      p_object_id VARCHAR2,
                      p_check_id NUMBER,
                      p_check_group VARCHAR2 DEFAULT 'ALL',
                      p_class_type VARCHAR2,
                      p_user_object VARCHAR2,
                      p_fcty_id VARCHAR2 DEFAULT NULL)

IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  CURSOR check_group IS
    SELECT check_group
      FROM CTRL_CHECK_GROUP
     WHERE (INSTR(EC_USER_OBJECT, p_user_object||'?') > 0
        OR  EC_USER_OBJECT = p_user_object);

  CURSOR get_parent_class (v_child_class VARCHAR2) IS
    SELECT parent_class
    FROM class_dependency_cnfg
    WHERE child_class = v_child_class;

  TYPE cv_type IS REF CURSOR;
  cv cv_type;
  object_id           VARCHAR2(300);
  object_name         VARCHAR2(300);
  ld_date             DATE;
  ld_from_date        DATE;
  ld_to_date          DATE;
  lv2_sql             VARCHAR2(32000);
  lv2_result          VARCHAR2(32000);
  lv2_where_clause    VARCHAR2(30000);
  lv2_fcty_class_name VARCHAR2(300);
  lv2_alt_class_type  VARCHAR2(32);

BEGIN
  -- For debuging
  EcDp_DynSql.WriteDebugText('PCK_GEN_CHECK.RUN_CHECK', 'CHECK_DEBUG ' ||
   'Username (session): '||EcDp_User_Session.getUserSessionParameter('USERNAME')||
   ' p_from_date: '||to_char(p_from_date,'dd.mm.yyyy')||
   ' p_to_date: '||to_char(p_to_date,'dd.mm.yyyy')||
   ' Object_where_clause: '||p_object_where_clause||
   ' object_id: '||p_object_id||
   ' p_check_id: '||p_check_id||
   ' p_check_group: '||p_check_group||
   ' p_class_type: '||p_class_type||
   ' p_user_object: '||p_user_object||
   ' p_fcty_id: '||p_fcty_id,
   'DEBUG'
   );

  ld_from_date := trunc(p_from_date, 'DD');
  ld_to_date := trunc(p_to_date, 'DD');

  FOR ChkParentClass IN  get_parent_class(p_class_type) LOOP
    lv2_alt_class_type := ChkParentClass.parent_class;
  END LOOP;

  IF p_object_id IS NULL THEN
    lv2_where_clause := NVL(p_object_where_clause,'1=1');
  ELSE
    lv2_where_clause := 'object_id = '||CHR(39)||p_object_id||CHR(39);
  END IF;

  lv2_sql := 'UPDATE ctrl_check_log SET status = '||CHR(39)||'FIXED'||CHR(39)||', check_daytime = Ecdp_Timestamp.getCurrentSysdate, last_updated_by = EcDp_Context.getAppUser WHERE ' || lv2_where_clause || ' AND daytime >= TO_DATE('||CHR(39)||TO_CHAR(ld_from_date,'ddmmyyyy hh24mi')||CHR(39)||','||CHR(39)||'ddmmyyyy hh24mi'||CHR(39)||') AND daytime < TO_DATE('||CHR(39)||TO_CHAR(ld_to_date,'ddmmyyyy hh24mi')||CHR(39)||','||CHR(39)||'ddmmyyyy hh24mi'||CHR(39)||')+1 AND (status = '||CHR(39)||'N'||CHR(39)||')';

  IF p_check_id IS NOT NULL THEN
    lv2_sql := lv2_sql || ' AND check_id = ' || p_check_id;
  END IF;

  IF p_class_type IS NOT NULL THEN
    IF lv2_alt_class_type = 'EQUIPMENT' THEN
       IF p_class_type IN ('TANK','EQPM') THEN
          lv2_sql := lv2_sql || ' AND class_name= '||CHR(39)||p_class_type||chr(39);
       ELSE
          lv2_sql := lv2_sql || ' AND class_name= '||CHR(39)||lv2_alt_class_type||chr(39);
       END IF;
    ELSE
      lv2_sql := lv2_sql || ' AND class_name= '||CHR(39)||p_class_type||chr(39);
    END IF;
  END IF;

  IF p_fcty_id IS NOT NULL THEN
    lv2_fcty_class_name := ecdp_objects.getobjclassname(p_fcty_id); -- find whether facility id is belong to facility class 1 or 2
    lv2_sql := lv2_sql || ' AND (ecdp_groups.findParentObjectId(' || CHR(39) || lv2_fcty_class_name || CHR(39) || ',''operational'',class_name,object_id,TO_DATE('||CHR(39)||TO_CHAR(ld_from_date,'ddmmyyyy hh24mi')||CHR(39)||','||CHR(39)||'ddmmyyyy hh24mi'||CHR(39)||')) = '|| CHR(39) || p_fcty_id || CHR(39)
                       || '   OR (class_name = '|| CHR(39) || lv2_fcty_class_name || CHR(39) || ' and object_id = '|| CHR(39) || p_fcty_id || CHR(39) || ')'
                       || '   OR ec_class_dependency_cnfg.rec_id(class_name, '|| CHR(39) || lv2_fcty_class_name || CHR(39) ||', ''IMPLEMENTS'') IS NOT NULL)';
  END IF;

  IF p_check_group IS NOT NULL AND p_check_group != 'ALL' THEN
      lv2_sql := lv2_sql || ' AND exists (select 1 from ctrl_check_combination where ctrl_check_log.check_id = ctrl_check_combination.check_id and ctrl_check_combination.check_group = ''' || p_check_group || ''')';
  END IF;

  -- only set "FIXED" to own screen's log during run_all
  IF p_user_object IS NOT NULL THEN
    lv2_sql := lv2_sql || ' AND ctrl_check_log.check_id in (select check_id from ctrl_check_combination, ctrl_check_group where ctrl_check_combination.check_id = ctrl_check_log.check_id and ctrl_check_combination.check_group = ctrl_check_group.check_group and instr(ctrl_check_group.ec_user_object, '''||p_user_object||''') > 0)';
  END IF;

  EcDp_DynSql.WriteDebugText('Pck_Gen_Check.run_check','About to run the following update statement ' || lv2_sql, 'DEBUG');
  lv2_result := executeStatement(lv2_sql);
  COMMIT;

  ld_date := ld_from_date;
  WHILE ld_date <= ld_to_date
  LOOP
    IF p_user_object IS NULL THEN
      IF lv2_alt_class_type = 'EQUIPMENT' THEN
        IF p_class_type IN ('TANK','EQPM') THEN
          ecdp_dynsql.WriteDebugText('Pck_Gen_Check.run_check','Executing run_day_check(ld_date, p_check_id, p_check_group, p_class_type, lv2_where_clause, p_fcty_id) with values ' || ld_date || ', ' || p_check_id || ', ' || p_check_group || ', ' || p_class_type || ', ' || lv2_where_clause || ', ' || p_fcty_id , 'DEBUG');
          run_day_check(ld_date, p_check_id, p_check_group, p_class_type, lv2_where_clause, p_fcty_id);
        ELSE
          ecdp_dynsql.WriteDebugText('Pck_Gen_Check.run_check','Executing run_day_check(ld_date, p_check_id, p_check_group, lv2_alt_class_type, lv2_where_clause, p_fcty_id) with values ' || ld_date || ', ' || p_check_id || ', ' || p_check_group || ', ' || lv2_alt_class_type || ', ' || lv2_where_clause || ', ' || p_fcty_id , 'DEBUG');
          run_day_check(ld_date, p_check_id, p_check_group, lv2_alt_class_type, lv2_where_clause, p_fcty_id);
        END IF;

      ELSE
        ecdp_dynsql.WriteDebugText('Pck_Gen_Check.run_check','Executing run_day_check(ld_date, p_check_id, p_check_group, p_class_type, lv2_where_clause, p_fcty_id) with values ' || ld_date || ', ' || p_check_id || ', ' || p_check_group || ', ' || p_class_type || ', ' || lv2_where_clause || ', ' || p_fcty_id , 'DEBUG');
        run_day_check(ld_date,p_check_id,p_check_group,p_class_type, lv2_where_clause,p_fcty_id);
      END IF;
    ELSE
      FOR CheckGrCur IN check_group LOOP
        IF lv2_alt_class_type = 'EQUIPMENT' THEN
          IF p_class_type IN ('TANK','EQPM') THEN
            EcDp_DynSql.WriteDebugText('Pck_Gen_Check.run_check','Executing run_day_check(ld_date, p_check_id, CheckGrCur.check_group, p_class_type, lv2_where_clause, p_fcty_id) with values ' || ld_date || ', ' || p_check_id || ', ' || CheckGrCur.check_group || ', ' || p_class_type || ', ' || lv2_where_clause || ', ' || p_fcty_id, 'DEBUG');
            run_day_check(ld_date, p_check_id, CheckGrCur.check_group, p_class_type, lv2_where_clause, p_fcty_id);
          ELSE
            EcDp_DynSql.WriteDebugText('Pck_Gen_Check.run_check','Executing run_day_check(ld_date, p_check_id, CheckGrCur.check_group, lv2_alt_class_type, lv2_where_clause, p_fcty_id) with values ' || ld_date || ', ' || p_check_id || ', ' || CheckGrCur.check_group || ', ' || lv2_alt_class_type || ', ' || lv2_where_clause || ', ' || p_fcty_id, 'DEBUG');
            run_day_check(ld_date, p_check_id, CheckGrCur.check_group, lv2_alt_class_type, lv2_where_clause, p_fcty_id);
          END IF;

        ELSE
          EcDp_DynSql.WriteDebugText('Pck_Gen_Check.run_check','Executing run_day_check(ld_date, p_check_id, CheckGrCur.check_group, p_class_type, lv2_where_clause, p_fcty_id) with values ' || ld_date || ', ' || p_check_id || ', ' || CheckGrCur.check_group || ', ' || p_class_type || ', ' || lv2_where_clause || ', ' || p_fcty_id, 'DEBUG');
          run_day_check(ld_date, p_check_id, CheckGrCur.check_group, p_class_type, lv2_where_clause, p_fcty_id);
        END IF;
      END LOOP;
    END IF;
    ld_date := ld_date + 1;
  END LOOP;

END run_check;


--------------------------------------------------------------------------------------------------------------
-- PROCEDURE RUN_DAY_CHECK
-------------------------------------------------------------------------------------------------------------
PROCEDURE run_day_check(p_day DATE,
                        p_check_id NUMBER,
                        p_check_group VARCHAR2 DEFAULT 'ALL',
                        p_class_type VARCHAR2,
                        p_where_clause VARCHAR2,
                        p_fcty_id VARCHAR2 DEFAULT NULL)

IS
  ld_prod_day_start   DATE;
  mysql               VARCHAR2(5000);
  ld_date             DATE;
  ln_all_count        NUMBER;
  ln_is_subdaily      NUMBER;
  ld_prod_day_end     DATE;
  lv2_prod_day_start  VARCHAR2(5);
  lv2_log_message     VARCHAR2(2000);
  lv2_log_status      VARCHAR2(200);
  lv2_log_daytime_attr VARCHAR2(200);
  ld_log_daytime      DATE;
  lv2_date_attrib     VARCHAR2(200) := 'DAYTIME';
  pp_object_name      VARCHAR2(200);
  pp_object_code      VARCHAR2(200);
  lecd                EcDp_Date_Time.Ec_Unique_daytime;
  lv2_class_type      VARCHAR2(32);
  lv2_fcty_class_name VARCHAR2(300);
  lv2_fcty_where_clause VARCHAR2(30000);

  TYPE cv_type IS REF CURSOR;
  cv cv_type;
  lv2_object_id VARCHAR2(32);
  ln_op NUMBER;

  CURSOR check_cur(v_check_group VARCHAR2) IS
    SELECT  x.check_id      check_id,
        x.table_id      table_id,
        x.select_clause   select_clause,
        x.where_clause    where_clause,
        x.severity_level  severity_level,
        x.check_message   check_message,
        y.check_group   check_group
    FROM CTRL_CHECK_RULES x, CTRL_CHECK_COMBINATION y
    WHERE
                ec_class_cnfg.owner_class_name(substr(x.table_id,4)) =
                     nvl(p_class_type, ec_class_cnfg.owner_class_name(substr(x.table_id,4)))
                AND
    ( x.check_id = y.check_id
      AND x.check_id = NVL(p_check_id,x.check_id)
    )
    AND
    ( y.check_group = DECODE(v_check_group,'ALL',y.check_group)
      OR y.check_group =
      ( SELECT check_group      --Include all child check groups
        FROM CTRL_CHECK_GROUP z
        WHERE y.check_group = z.check_group
        START WITH z.check_group = v_check_group
        CONNECT BY z.parent_group = PRIOR z.check_group
      )
    ) -- TRUE if ALL
    ORDER BY x.check_id
  ;

  CURSOR c_class_type(cp_table_id VARCHAR2) IS
    SELECT owner_class_name
    FROM class_cnfg
    WHERE class_name = substr(upper(cp_table_id), instr(cp_table_id, '_')+1)
  ;

  CURSOR c_Class_Date_Columns(p_class_name VARCHAR2) IS
   SELECT attribute_name
   FROM class_attribute_cnfg ca
   WHERE ca.class_name = p_class_name
   AND   ca.data_type = 'DATE'
   AND   Ecdp_Classmeta_Cnfg.isDisabled(ca.class_name, ca.attribute_name) = 'N'
   AND   ca.attribute_name IN ('PRODUCTION_DAY','DAYTIME','NOM_DATE','BL_DATE','CONTRACT_DATE')
   ORDER BY DECODE(attribute_name,'PRODUCTION_DAY',1,'DAYTIME',2,'NOM_DATE',3,'BL_DATE',4,'CONTRACT_DATE',5)
  ;

BEGIN

  FOR CheckCur IN check_cur(NVL(p_check_group, 'ALL')) LOOP

    IF p_class_type IS NULL THEN
      FOR one IN c_class_type(CheckCur.table_id) LOOP
        lv2_class_type := one.owner_class_name;
      END LOOP;
    ELSE
      lv2_class_type := p_class_type;
    END IF;

    IF p_fcty_id IS NOT NULL THEN
      -- find facility
      lv2_fcty_class_name := ecdp_objects.getobjclassname(p_fcty_id);

      lv2_fcty_where_clause := ' AND 1=1';

      FOR one IN (SELECT group_type,role_name FROM class_relation_cnfg WHERE to_class_name=lv2_class_type and from_class_name=lv2_fcty_class_name and group_type in ('operational', 'geographical') AND EcDp_ClassMeta_Cnfg.isDisabled(from_class_name, to_class_name, role_name) = 'N') LOOP
        lv2_fcty_where_clause := ' AND ' || one.role_name || '_id='||CHR(39)||p_fcty_id||chr(39);
      END LOOP;
    END IF;

    mysql := 'SELECT COUNT(*) FROM class_attribute WHERE class_name='||CHR(39)||substr(CheckCur.table_id,4)||CHR(39)||' AND attribute_name = ''PRODUCTION_DAY''';
    EcDp_DynSql.WriteDebugText('Pck_Gen_Check.run_day_check','Determine if day column exists with: ' || mysql, 'DEBUG');

    -- Not all classes uses PRODUCTION_DAY or DAYTIME, need to resolve what to use
    For curDateAttr IN c_Class_Date_Columns(substr(CheckCur.table_id,4)) LOOP
      lv2_date_attrib := curDateAttr.attribute_name;
      EXIT; -- sorting in cursor selects the right one
    END LOOP;

    -- Find which date attribute to use as value for ctrl_check_log daytime to support sub-daily daytimes.
    lv2_log_daytime_attr := lv2_date_attrib;
    For curDateAttr IN c_Class_Date_Columns(substr(CheckCur.table_id,4)) LOOP
      IF curDateAttr.attribute_name = 'DAYTIME' THEN
        lv2_log_daytime_attr := curDateAttr.attribute_name;
        EXIT;
      END IF;
    END LOOP;

    --  ln_is_subdaily := execute_sql_number(mysql);
    ld_date := p_day;
    ld_prod_day_end := p_day+1;

    ln_all_count := 0;

    mysql := 'SELECT object_id, ' || lv2_log_daytime_attr || ', ' || CheckCur.select_clause || ' op FROM ' || CheckCur.table_id || ' a ';

    IF lv2_date_attrib = 'PRODUCTION_DAY' THEN
      mysql := mysql || ' WHERE production_day = TO_DATE('||CHR(39)||TO_CHAR(p_day,'ddmmyyyy hh24mi')||CHR(39)||','||CHR(39)||'ddmmyyyy hh24mi'||CHR(39)||')';
    ELSE
      mysql := mysql || ' WHERE ' || lv2_date_attrib || ' BETWEEN TO_DATE('||CHR(39)||TO_CHAR(ld_date,'ddmmyyyy hh24mi')||CHR(39)||','||CHR(39)||'ddmmyyyy hh24mi'||CHR(39)||')';
      mysql := mysql || ' AND TO_DATE('||CHR(39)||TO_CHAR(ld_date + 1,'ddmmyyyy hh24mi')||CHR(39)||','||CHR(39)||'ddmmyyyy hh24mi'||CHR(39)||') - 0.001 ';
    END IF;

    mysql := mysql || 'AND ('||NVL(CheckCur.where_clause, '1=1')||')';
    mysql := mysql || 'AND ' || p_where_clause || lv2_fcty_where_clause || ' group by object_id, ' || lv2_log_daytime_attr;
    mysql := mysql || ' UNION SELECT object_id, daytime, 0 AS op FROM ctrl_check_log WHERE check_id = ' || CheckCur.check_id ;
    mysql := mysql || ' AND DAYTIME = TO_DATE('||CHR(39)||TO_CHAR(ld_date,'ddmmyyyy hh24mi')||CHR(39)||','||CHR(39)||'ddmmyyyy hh24mi'||CHR(39)||') AND NOT EXISTS (SELECT 1 FROM ' || CheckCur.table_id || ' WHERE ' ;

    IF lv2_date_attrib = 'PRODUCTION_DAY' THEN
      mysql := mysql || ' production_day = TO_DATE('||CHR(39)||TO_CHAR(p_day,'ddmmyyyy hh24mi')||CHR(39)||','||CHR(39)||'ddmmyyyy hh24mi'||CHR(39)||')';
    ELSE
      mysql := mysql || lv2_date_attrib || ' BETWEEN TO_DATE('||CHR(39)||TO_CHAR(ld_date,'ddmmyyyy hh24mi')||CHR(39)||','||CHR(39)||'ddmmyyyy hh24mi'||CHR(39)||')';
      mysql := mysql || ' AND TO_DATE('||CHR(39)||TO_CHAR(ld_date + 1,'ddmmyyyy hh24mi')||CHR(39)||','||CHR(39)||'ddmmyyyy hh24mi'||CHR(39)||') - 0.001 ';
    END IF;
    mysql := mysql || ' AND ('||NVL(CheckCur.where_clause, '1=1') || ') AND ' || p_where_clause || lv2_fcty_where_clause ||' AND object_id = ctrl_check_log.object_id)';

    EcDp_DynSql.WriteDebugText('Pck_Gen_Check.run_day_check','About to execute the following sql ' || mysql, 'DEBUG');
    BEGIN
    OPEN cv FOR mysql;
    LOOP
      FETCH cv INTO lv2_object_id, ld_log_daytime, ln_op;
      EXIT WHEN cv%NOTFOUND;

        EcDp_DynSql.WriteDebugText('Pck_Gen_Check.run_day_check', 'loop_item - object name: ' || ecdp_objects.GetObjCode(lv2_object_id) || ', count: ' || ln_op, 'DEBUG');
        IF  ln_op > 0 THEN
          EcDp_DynSql.WriteDebugText('Pck_Gen_Check.run_day_check', '1 ' || lv2_log_message, 'DEBUG');
          lv2_log_message := REPLACE(CheckCur.check_message,':COUNT','$$'||TO_CHAR(ln_op)||'$$');
          EcDp_DynSql.WriteDebugText('Pck_Gen_Check.run_day_check', '2 ' || lv2_log_message, 'DEBUG');

          pp_object_code := ecdp_objects.GetObjCode(lv2_object_id);
          lv2_log_message := insert_object_codes(lv2_log_message, pp_object_code);

          pp_object_name := ecdp_objects.GetObjName(lv2_object_id,p_day);
          lv2_log_message := insert_object_names(lv2_log_message, pp_object_name);

          EcDp_DynSql.WriteDebugText('Pck_Gen_Check.run_day_check', '3 ' || lv2_log_message, 'DEBUG');
          EcDp_DynSql.WriteDebugText('Pck_Gen_Check.run_day_check', 'Execute log_message(CheckCur.check_id, ld_log_daytime, CheckCur.check_group, CheckCur.severity_level, lv2_log_message, lv2_object_id) with values: ' || CheckCur.check_id || ', ' || to_char(ld_log_daytime, 'YYYY-MM-DD"T"hh24:mi:ss') || ', ' || CheckCur.check_group || ', ' || CheckCur.severity_level || ', ' || lv2_log_message || ', ' || lv2_object_id, 'DEBUG');
          log_message(CheckCur.check_id, ld_log_daytime, CheckCur.check_group, CheckCur.severity_level, lv2_log_message, lv2_object_id,lv2_class_type);
        END IF;
      END LOOP;
      CLOSE cv;

    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
  END LOOP;
END run_day_check;


--------------------------------------------------------------------------------------------------------
--
--
--------------------------------------------------------------------------------------------------------
FUNCTION insert_object_names(p_statement VARCHAR2, p_name VARCHAR2) RETURN VARCHAR2 IS

lv2_log_message VARCHAR2(2000);

BEGIN

   lv2_log_message := p_statement;
   lv2_log_message := REPLACE(lv2_log_message, ':WELL_NAME', '$$'||p_name||'$$');
   lv2_log_message := REPLACE(lv2_log_message, ':FLWL_NAME', '$$'||p_name||'$$');
   lv2_log_message := REPLACE(lv2_log_message, ':FLOWLINE_NAME', '$$'||p_name||'$$');
   lv2_log_message := REPLACE(lv2_log_message, ':STREAM_NAME', '$$'||p_name||'$$');
   lv2_log_message := REPLACE(lv2_log_message, ':STREAM_ITEM_NAME', '$$'||p_name||'$$');
   lv2_log_message := REPLACE(lv2_log_message, ':SEPARATOR_NAME', '$$'||p_name||'$$');
   lv2_log_message := REPLACE(lv2_log_message, ':FACILITY_NAME', '$$'||p_name||'$$');
   lv2_log_message := REPLACE(lv2_log_message, ':EQUIPMENT_NAME', '$$'||p_name||'$$');
   lv2_log_message := REPLACE(lv2_log_message, ':TANK_NAME', '$$'||p_name||'$$');
   lv2_log_message := REPLACE(lv2_log_message, ':OBJECT_NAME', '$$'||p_name||'$$');

   RETURN lv2_log_message;

EXCEPTION
   WHEN OTHERS THEN
      NULL;

END insert_object_names;


--------------------------------------------------------------------------------------------------------
--
--
--------------------------------------------------------------------------------------------------------
FUNCTION insert_object_codes(p_statement VARCHAR2, p_code VARCHAR2) RETURN VARCHAR2 IS

lv2_log_message VARCHAR2(2000);

BEGIN

   lv2_log_message := p_statement;
   lv2_log_message := REPLACE(lv2_log_message, ':WELL_CODE', '$$'||p_code||'$$');
   lv2_log_message := REPLACE(lv2_log_message, ':FLWL_CODE', '$$'||p_code||'$$');
   lv2_log_message := REPLACE(lv2_log_message, ':FLOWLINE_CODE', '$$'||p_code||'$$');
   lv2_log_message := REPLACE(lv2_log_message, ':STREAM_CODE', '$$'||p_code||'$$');
   lv2_log_message := REPLACE(lv2_log_message, ':STREAM_ITEM_CODE', '$$'||p_code||'$$');
   lv2_log_message := REPLACE(lv2_log_message, ':SEPARATOR_CODE', '$$'||p_code||'$$');
   lv2_log_message := REPLACE(lv2_log_message, ':FACILITY_CODE', '$$'||p_code||'$$');
   lv2_log_message := REPLACE(lv2_log_message, ':EQUIPMENT_CODE', '$$'||p_code||'$$');
   lv2_log_message := REPLACE(lv2_log_message, ':TANK_CODE', '$$'||p_code||'$$');
   lv2_log_message := REPLACE(lv2_log_message, ':OBJECT_CODE', '$$'||p_code||'$$');

   RETURN lv2_log_message;

EXCEPTION
   WHEN OTHERS THEN
      NULL;

END insert_object_codes;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getScreenLabel
-- Description    : Returns the screen label given its url.
--                  Called from ctrl_check_group class.
--
--
-- Preconditions  : The object_id is a unique key in the faclity table.
-- Postcondition  :
-- Using Tables   : - ctrl_tv_presentation
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
FUNCTION getScreenLabel(p_screen_url   VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
   CURSOR c_tv_presentation(p_url   VARCHAR2) IS
    SELECT * FROM ctrl_tv_presentation
    WHERE window_id = 'ENERGYX'
    AND   component_type = 'URL'
    AND   component_ext_name = p_url;

   lv2_label     ctrl_tv_presentation.component_label%TYPE := NULL;
   lv2_url       ctrl_tv_presentation.component_ext_name%TYPE;

BEGIN

   -- Add .. to head of url.
   -- '/com.ec.prod' is '../com.ec.prod'
   IF INSTR(p_screen_url,'..') = 0 THEN
      lv2_url := '..' || p_screen_url;
   ELSE
      lv2_url := p_screen_url;
   END IF;

   FOR curUrl IN c_tv_presentation(lv2_url) LOOP

      lv2_label := curUrl.component_label;

   END LOOP;

   RETURN lv2_label;

END;


--------------------------------------------------------------------------------------------------------
--
--
--------------------------------------------------------------------------------------------------------
FUNCTION execute_sql_number(p_statement VARCHAR2) RETURN NUMBER IS

  li_cursor   INTEGER;
  li_returverdi   INTEGER;
  ln_return_value NUMBER;

BEGIN

   EcDp_DynSql.WriteDebugText('Pck_Gen_Check.execute_sql_number', 'SQL ' || p_statement, 'DEBUG' );

   li_cursor := Dbms_Sql.Open_Cursor;

   Dbms_sql.Parse(li_cursor,p_statement,dbms_sql.v7);
   Dbms_Sql.Define_Column(li_cursor,1,ln_return_value);

   li_returverdi := Dbms_Sql.EXECUTE(li_cursor);

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
      Dbms_Sql.Close_Cursor(li_cursor);
      RETURN NULL;

END execute_sql_number;


--------------------------------------------------------------------------------------------------------
--
--
--------------------------------------------------------------------------------------------------------
FUNCTION hasLogEntires(p_component VARCHAR2, p_user VARCHAR2) RETURN NUMBER IS

  TYPE cv_log IS REF CURSOR;
  cv cv_log;
  lv2_sql VARCHAR2(30000);
  lv2_dummy VARCHAR2(300);
  lv2_component VARCHAR2(500);
  ln_severitylevel NUMBER;
  lv2_op_where_clause VARCHAR2(500) := '1=1';
  lv2_vertbl_prefix VARCHAR2(500);

  CURSOR c_objpar IS
  SELECT op.attribute_text, a.class_name
  FROM t_basis_userrole ur, t_basis_access a, t_basis_object_partition op
  WHERE ur.user_id = p_user
  AND ur.role_id = a.role_id
  AND op.t_basis_access_id = a.t_basis_access_id;

  CURSOR c_log(c_comp VARCHAR2, c_level VARCHAR2) IS
  SELECT cl.severity_level, cl.object_id, cl.class_name
  FROM ctrl_check_log cl, ctrl_check_group cg
  WHERE cl.check_group = cg.check_group
  AND Lower(cg.EC_USER_OBJECT) = c_comp
  AND cl.severity_level = c_level;

BEGIN

  lv2_component := Lower(substr(p_component,3,100));
  lv2_dummy := null;
  ln_severitylevel := 0;

  FOR log IN c_log(lv2_component,'ERROR') LOOP
    ln_severitylevel:= 100;
    EcDp_DynSql.WriteDebugText('Pck_Gen_Check.hasLogEntires', lv2_component, 'DEBUG' );

    lv2_vertbl_prefix := getVerTblPrefix(log.class_name);

    FOR op IN c_objpar LOOP
      lv2_op_where_clause := getObjWhereClause(op.attribute_text, op.class_name);
      IF lv2_op_where_clause is NULL THEN
        EXIT;
      END IF;
      lv2_sql := 'SELECT '||CHR(39)||'A'||CHR(39)||' FROM '|| lv2_vertbl_prefix ||'_version o WHERE '||CHR(39)||log.object_id||CHR(39)||' = o.object_id AND '|| lv2_op_where_clause;
      EcDp_DynSql.WriteDebugText('Pck_Gen_Check.hasLogEntires', 'About to run the following select ' || lv2_sql, 'DEBUG');

      OPEN cv FOR lv2_sql;
        LOOP
          FETCH cv INTO lv2_dummy;
          EXIT WHEN cv%NOTFOUND;
          ln_severitylevel:= 0;
        END LOOP;
      CLOSE cv;
    END LOOP;

    IF ln_severitylevel > 0 THEN
      RETURN ln_severitylevel;--An error log entry for an object that is not part of any partition was discovered
    END IF;
  END LOOP;

  FOR log IN c_log(lv2_component,'WARNING') LOOP
    ln_severitylevel:= 200;
    EcDp_DynSql.WriteDebugText('Pck_Gen_Check.hasLogEntires', lv2_component, 'DEBUG');
    lv2_vertbl_prefix := getVerTblPrefix(log.class_name);

    FOR op IN c_objpar LOOP
      lv2_op_where_clause := getObjWhereClause(op.attribute_text, op.class_name);
      IF lv2_op_where_clause is NULL THEN
        EXIT;
      END IF;
      lv2_sql := 'SELECT '||CHR(39)||'A'||CHR(39)||' FROM '|| lv2_vertbl_prefix ||'_version o WHERE '||CHR(39)||log.object_id||CHR(39)||' = o.object_id AND '|| lv2_op_where_clause;

      EcDp_DynSql.WriteDebugText('Pck_Gen_Check.hasLogEntires', 'About to run the following select ' || lv2_sql, 'DEBUG');
      OPEN cv FOR lv2_sql;
        LOOP
          FETCH cv INTO lv2_dummy;
          EXIT WHEN cv%NOTFOUND;
          ln_severitylevel:= 0;
        END LOOP;
      CLOSE cv;
    END LOOP;

    IF ln_severitylevel > 0 THEN
      RETURN ln_severitylevel;--An error log entry for an object that is not part of any partition was discovered
    END IF;
  END LOOP;

  FOR log IN c_log(lv2_component,'INFORMATION') LOOP
    ln_severitylevel:= 300;
    EcDp_DynSql.WriteDebugText('Pck_Gen_Check.hasLogEntires', lv2_component, 'DEBUG');
    lv2_vertbl_prefix := getVerTblPrefix(log.class_name);

    FOR op IN c_objpar LOOP
      lv2_op_where_clause := getObjWhereClause(op.attribute_text, op.class_name);
      IF lv2_op_where_clause is NULL THEN
        EXIT;
      END IF;
      lv2_sql := 'SELECT '||CHR(39)||'A'||CHR(39)||' FROM '|| lv2_vertbl_prefix ||'_version o WHERE '||CHR(39)||log.object_id||CHR(39)||' = o.object_id AND '|| lv2_op_where_clause;

      EcDp_DynSql.WriteDebugText('Pck_Gen_Check.hasLogEntires', 'About to run the following select ' || lv2_sql, 'DEBUG');
      OPEN cv FOR lv2_sql;
        LOOP
          FETCH cv INTO lv2_dummy;
          EXIT WHEN cv%NOTFOUND;
          ln_severitylevel:= 0;
        END LOOP;
      CLOSE cv;
    END LOOP;

    IF ln_severitylevel > 0 THEN
      RETURN ln_severitylevel;--An error log entry for an object that is not part of any partition was discovered
    END IF;
  END LOOP;

  RETURN ln_severitylevel;

END hasLogEntires;


FUNCTION getVerTblPrefix(p_class_name VARCHAR2) RETURN VARCHAR2 IS
  lv2_returnvalue VARCHAR2(30) := null;
BEGIN

  IF p_class_name = 'WELL' THEN
    lv2_returnvalue := 'well';
  END IF;

  IF p_class_name = 'STREAM' THEN
    lv2_returnvalue := 'strm';
  END IF;

  RETURN lv2_returnvalue;

END getVerTblPrefix;


FUNCTION getObjWhereClause(p_obj_list VARCHAR2, p_class_name VARCHAR2) RETURN VARCHAR2 IS
  lv2_returnvalue VARCHAR2(30000) := null;
BEGIN
  IF p_class_name= 'PRODUCTIONUNIT' THEN
    lv2_returnvalue := 'o.op_pu_id not in ' || p_obj_list;
  END IF;

  IF p_class_name = 'AREA' THEN
    lv2_returnvalue := 'o.op_area_id not in ' || p_obj_list;
  END IF;

  RETURN lv2_returnvalue;
END getObjWhereClause;


END pck_gen_check;