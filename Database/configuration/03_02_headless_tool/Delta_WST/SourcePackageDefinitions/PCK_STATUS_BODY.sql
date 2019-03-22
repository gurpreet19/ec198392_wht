CREATE OR REPLACE PACKAGE BODY pck_status IS
/**************************************************************************************************************
** Package	:  PCK_STATUS
**
** $Revision: 1.46 $
**
** Purpose	:  Provide functions and procedures related data status transactions
**
** General Logic: Creates dynamic SQL to update record_status.
**
** Created:   	08.04.99 HN
**
** Modification history:
**
** Date:      Whom:    Change description:
** --------   -------  -----------------------------------------------------------------------------------------
** 18.10.02   MNY      Added check for nullity on ln_rows_updated for calulation of p_rows_updated in PROCEDURE run_tasks
** 11.12.02   HNE      Some table does not have the sysnam column. This was hardcoded, its removed.
** 18.12.02   HNE      Added p_user_id as parameter to run_process. Oracle userid <> appl userid for web appl.
** 21.01.03   HNE      Used p_sysnam value instead on text sysnam (becuase some tables does not have sysnam)
** 02.02.03   HNE      Changed the order of elements in where clause. Daytime is now last for performance.
** 12.11.03   DN       Renamed t_temptekst.
** 18.11.03   DN       Replaced sysdate with new function.
** 28.03.04   HNE      Change to fit new OV and DV views
** 10.05.04   HNE      Added support for chemical_injection, object_day_weather and ctrl_check_log
** 01.06.04   HNE      Added support for well test
** 01.06.04   HNE      Added support for analysis
** 25.06.04   DN       Added procedure set_cargo_rs_by_code. TD 1407.
** 27.09.2004 SeongKok Added procedure set_deferment_rs for TrackerIssue#679
** 28.10.2004 LIB      Added procedure set_alloc_netw_log_status_rs
** 11.11.2004 SHN      Updated sql for Weather in run_task. Tracker 1745
** 14.12.2004 DN       Replaced pck_system with EcDp_System. Tracker 1826.
** 03.02.2005 Ron      Modifid the sql statement for run_tasks function so that wells created in the middle of the month will be included. TI#1705
** 20.02.2005 HNE      Tracker #2000: Replaced usage of IN with EXISTS due to Oracle bug.
**                     Also introduced loop over all days when monthly process is run to pick up new objects or new connections.
**                     Fixed bug that did not handle sub daily correct, now production_day is used.
** 10.03.2005 DN       Redefined procedure set_alloc_netw_log_status_rs.
** 31.03.2005 SHN      Removed obsolete procedure set_welltest_rs
** 10.05.2005 SHN      Redefined procedure set_deferment_rs to use table objects_deferment_event. TD 3218 (8.1)
** 29.07.2005 CHONGJER Updated range of date and removed redundant calculation for rows updated specifically for the handling of weather.
** 09.11.2005 AV       Changed references to WriteTempText from EcDp_genClasscode to EcDp_DynSQL (code cleanup)
**                     these references where all commented out (debug only).
** 08.02.2006 Darren   TI#3257 Updated procedure run task, added handling of status of ensure_rev_text for class
** 29.04.2006 ZakiiAri TI#3595 Updated procedure run_task, added new column to be updated i.e last_updated_by
**                             Added new parameter (p_user_id) to procedure set_cargo_rs, set_alloc_netw_log_status_rs, set_analysis_rs, set_deferment_rs
** 05.11.2007 eizwanik ECPD-6626: Included special handling for class PROD_TEST_RESULT in run_tasks
** 31.03.2008 oonnnng  ECPD-7263: Add p_to_daytime (END_DATE) to update_stat_process_status and update_stat_process_status functions.
** 10.02.2009 oonnnng  ECPD-10861: Add new procedure set_aga_analysis_rs.
** 17.02.2009 oonnnng  ECPD-6067: Modified function set_analysis_rs, to add p_object_id to validatePeriodForLockOverlap
** 10.04.2009 oonnnng  ECPD-6067: Added parameter p_object_id to validatePeriodForLockOverlap in set_aga_analysis_rs() function.
** 22.04.2009 leongsei ECPD-6067: Modified function run_process to add object_id for validatePeriodForLockOverlap
** 04.02.2010 farhaann ECPD-13601: Removed special handling for chemical_injection
** 09.11.2010 farhaann ECPD-15630: Modified procedure run_tasks, special handling of weather, update the revision text
** 17.09.2013 wonggkai ECPD-25076: Modified procedure set_analysis_rs change p_daytime to valid_from_date
** 27.11.2013 musthram ECPD-23479: Removed Commit statement from procedure set_alloc_netw_log_status_rs, set_cargo_rs, set_analysis_rs, set_aga_analysis_rs and set_deferment_rs to ** work in JMS mode
** 16.10.2015 thotesan ECPD-31677: Modified procedure set_alloc_netw_log_status_rs to check for system attribute ALLOW_ALLOC_LOCK_MONTH indicator and Check for locking
** 19.10.2016 singishi ECPD-32618: Change all instances of UPDATE OBJECT_FLUID_ANALYSIS table to include both last_update_by and last_update_date for revision info
** 07.04.2016 dhavaalo ECPD-44764: Remove extra space.
** 17.05.2017 choooshu ECPD-45851: Modified run_tasks procedure to add last_updated to status process running on PROD_TEST_RESULT.
** 16.06.2017 leongwen ECPD-26180: Modified procedure run_child_process and run_tasks to support reversible process in Status Process. Modified lv_variable to standard lv2_variable and added failChkRecStsLevel to support status process validation. **                                 The CTRL_CHECK_LOG is not affected by the reverse status update process due to manual correction might be required prior to system update automatically.
** 11.07.2017 kashisag ECPD-45273: Updated Daily and subdaily cursor to handle Report only ind and disable indicator for Production Day in run_tasks
** 18.07.2017 kashisag ECPD-45817: Replaced sysdate with Ecdp_Timestamp.getCurrentSysdate
** 13.07.2017 leongwen ECPD-46335: Modified PROCEDURE run_tasks to support status process for well and flowline performance curve records
** 18.12.2017 singishi ECPD-51137: removed proc set_deferment_record_status
** 13.07.2017 mehtajig ECPD-58409: Modified PROCEDURE run_tasks to support status process for TV_WELL_DEFERMENT and DV_WELL_DEFERMENT_CHILD
**************************************************************************************************************/
--
--------------------------------------------------------------------------------------------------------------
-- PROCEDURE RUN_PROCESS
--------------------------------------------------------------------------------------------------------------
PROCEDURE run_process(P_process_id VARCHAR2,
                      p_from_daytime DATE,
                      p_to_daytime DATE DEFAULT NULL,
                      p_user_id VARCHAR2 DEFAULT NULL) IS

  CURSOR cur_status_process(p_process_id VARCHAR2) IS
  SELECT process_id
  FROM status_process
  WHERE parent_process_id=p_process_id
  ;

  lrec_status_process STATUS_PROCESS%ROWTYPE;
  ln_total_rows_upd NUMBER :=0;
  ld_from_daytime DATE;
  ld_to_daytime DATE;
  lv2_reversible_process VARCHAR2(1);

BEGIN

  -- Check for production day offset have been moved to RUN_TASK, because production day offset can vary by facility connection.
  ld_from_daytime := p_from_daytime;
  ld_to_daytime := p_to_daytime;

  -- p_from_daytime can be null
  IF ld_from_daytime IS NULL THEN
    ld_from_daytime := ld_to_daytime;
  END IF;

  -- Find all colums from main process_id
  lrec_status_process := ec_status_process.row_by_pk(p_process_id);
  IF ld_to_daytime IS NULL THEN
    IF lrec_status_process.process_interval = 'MTH' THEN
      ld_to_daytime := last_day(ld_from_daytime)+1;
    ELSIF lrec_status_process.process_interval = 'DAY' THEN
      ld_to_daytime := ld_from_daytime+1;
    ELSE
      ld_to_daytime := ld_from_daytime+1;
    END IF;
  ELSE
    ld_to_daytime := ld_from_daytime + 1; -- because this procedure treats to_daytime as exclusive.
  END IF;

  -- Check for locking
  EcDp_month_lock.validatePeriodForLockOverlap('UPDATING', ld_from_daytime, ld_to_daytime, 'Can not excecute run_process when direct lock detected', 'N/A' );

  -- Check if user have acces to run this job
  IF access_to_process(  p_process_id, p_user_id) THEN
    -- Find all colums from main process_id
    lrec_status_process := ec_status_process.row_by_pk(p_process_id);

    -- Check for production day offset have been moved to RUN_TASK, because production day offset can vary by facility connection.
    ld_from_daytime := p_from_daytime;

    IF p_to_daytime IS NULL THEN
      IF lrec_status_process.process_interval = 'MTH' THEN
        ld_to_daytime := last_day(ld_from_daytime)+1;
      ELSIF lrec_status_process.process_interval = 'DAY' THEN
        ld_to_daytime := ld_from_daytime+1;
      ELSE
        -- default
        ld_to_daytime := ld_from_daytime+1;
      END IF;

    ELSE
      ld_to_daytime := p_to_daytime;
    END IF;

    IF ((lrec_status_process.process_interval = 'MTH' AND TRUNC(Ecdp_Timestamp.getCurrentSysdate,'MM') >= ld_to_daytime) OR
        (lrec_status_process.process_interval <> 'MTH' AND Ecdp_Timestamp.getCurrentSysdate > ld_from_daytime)) THEN

      lv2_reversible_process := NVL(lrec_status_process.reverse_flag, 'N');

      -- Loop through all child processes
      FOR mycur IN cur_status_process(p_process_id) LOOP
        run_child_process(mycur.process_id, lrec_status_process.from_rs_level, lrec_status_process.to_rs_level, ld_from_daytime, ld_to_daytime, ln_total_rows_upd, p_user_id, lv2_reversible_process);
      END LOOP;

      -- Execute the tasks for p_process_id
      run_tasks(p_process_id, lrec_status_process.from_rs_level, lrec_status_process.to_rs_level, ld_from_daytime, ld_to_daytime, ln_total_rows_upd, p_user_id, lv2_reversible_process);

    ELSE
      NULL; -- not allowed to run for this date at this time!!
    END IF;
  ELSE
    NULL;
  END IF;

  -- Call to user_exit
  UE_PCK_STATUS.run_process(p_process_id, p_from_daytime, p_to_daytime, p_user_id);

END run_process;


--------------------------------------------------------------------------------------------------------------
-- PROCEDURE RUN_CHILD_PROCESS
-------------------------------------------------------------------------------------------------------------
PROCEDURE run_child_process(p_process_id VARCHAR2,
                            p_from_rs_level VARCHAR2,
                            p_to_rs_level VARCHAR2,
                            p_from_daytime DATE,
                            p_to_daytime DATE,
                            p_total_rows_upd IN OUT NUMBER,
                            p_user_id VARCHAR2 DEFAULT NULL,
                            p_reversible_process VARCHAR2 DEFAULT NULL) IS

CURSOR cur_status_process(p_process_id VARCHAR2) IS
SELECT process_id
FROM status_process
WHERE parent_process_id=p_process_id
;

lrec_status_process STATUS_PROCESS%ROWTYPE;
ln_current_rows_upd NUMBER := 0;

BEGIN
	-- Loop through all child processes
	FOR child_cur IN cur_status_process(p_process_id) LOOP
		run_child_process(child_cur.process_id, p_from_rs_level, p_to_rs_level, p_from_daytime, p_to_daytime, ln_current_rows_upd, p_user_id, p_reversible_process);
	END LOOP;

	-- Execute the tasks for p_process_id
	run_tasks(p_process_id, p_from_rs_level, p_to_rs_level, p_from_daytime, p_to_daytime, ln_current_rows_upd, p_user_id, p_reversible_process);

	p_total_rows_upd := p_total_rows_upd + ln_current_rows_upd;

END run_child_process;

--------------------------------------------------------------------------------------------------------------
-- PROCEDURE RUN_TASKS
-------------------------------------------------------------------------------------------------------------
PROCEDURE run_tasks(p_process_id VARCHAR2,
                    p_from_rs_level VARCHAR2,
                    p_to_rs_level VARCHAR2,
                    p_from_daytime DATE,
                    p_to_daytime DATE,
                    p_rows_updated IN OUT NUMBER,
                    p_user_id VARCHAR2 DEFAULT NULL,
                    p_reversible_process VARCHAR2 DEFAULT NULL) IS

CURSOR cur_tasks(pid VARCHAR2) IS
	SELECT task_id, table_id, where_clause
	FROM stat_process_task
	WHERE process_id = pid
	AND table_id NOT IN ('CTRL_CHECK_LOG','WEATHER','PROD_TEST_RESULT','PROD_TEST_RESULT_SINGLE', 'PERFORMANCE_CURVE', 'PERF_CURVE_THIRD_AXIS', 'CURVE_POINT', 'PERF_CURVE_COEFFS',  'WELL_DEFERMENT'); -- these classes have special handling

CURSOR cur_sub_daily(c_class_name VARCHAR2) IS
  SELECT class_name
  FROM   class_attribute_cnfg
  WHERE  class_name                 = c_class_name
  AND    attribute_name             = 'PRODUCTION_DAY'
  AND    ecdp_classmeta_cnfg.isDisabled(class_name, attribute_name) <> 'Y'
  AND    ecdp_classmeta_cnfg.isReportOnly(class_name, attribute_name) <> 'Y';

CURSOR cur_daily(c_class_name VARCHAR2) IS
  SELECT class_name
  FROM   class_cnfg
  WHERE  class_name = c_class_name
  MINUS
  SELECT class_name
  FROM   class_attribute_cnfg
  WHERE  class_name                 = c_class_name
  AND    attribute_name             = 'PRODUCTION_DAY'
  AND    ecdp_classmeta_cnfg.isDisabled(class_name, attribute_name) <> 'Y'
  AND    ecdp_classmeta_cnfg.isReportOnly(class_name, attribute_name) <> 'Y';

CURSOR cur_owner_class(c_class_name VARCHAR2) IS
  SELECT class_name, class_type
  FROM class_cnfg
  WHERE class_name =
  (SELECT owner_class_name
  FROM class_cnfg
  WHERE class_name=c_class_name);

CURSOR cur_tasks_data_class(pid VARCHAR2, p_dataclass VARCHAR2) IS
	SELECT task_id, table_id, where_clause
	FROM stat_process_task
	WHERE process_id = pid
	AND table_id = p_dataclass;

CURSOR cur_tasks_data_class_prod_test(pid VARCHAR2) IS
	SELECT task_id, table_id, where_clause
	FROM stat_process_task
	WHERE process_id = pid
	AND table_id in ('PROD_TEST_RESULT','PROD_TEST_RESULT_SINGLE');

CURSOR cur_perf_curve_table_class(pid VARCHAR2) IS
	SELECT task_id, table_id, where_clause
	FROM stat_process_task
	WHERE process_id = pid
	AND table_id in ('PERFORMANCE_CURVE', 'PERF_CURVE_THIRD_AXIS', 'CURVE_POINT', 'PERF_CURVE_COEFFS');

CURSOR cur_deferment(pid VARCHAR2) IS
	SELECT task_id, table_id, where_clause
	FROM stat_process_task
	WHERE process_id = pid
	AND table_id in ('WELL_DEFERMENT' );

CURSOR cur_system_days IS
SELECT daytime
FROM system_days
WHERE daytime BETWEEN p_from_daytime AND p_to_daytime;

mysql VARCHAR2(2000);
lv2_owner_class_name VARCHAR2(100);
lv2_owner_class_type VARCHAR2(100);
ln_to_level_id NUMBER;
ln_from_level_id NUMBER;
ln_rows_updated NUMBER := 0;
li_cursor	INTEGER;
li_return	INTEGER;
ln_numrows NUMBER;
lv2_where_clause VARCHAR2(2000);
lv2_datewhere VARCHAR2(2000);
lv2_default_operator VARCHAR2(1) := '<';

BEGIN
	ln_to_level_id := ec_ctrl_record_status_level.level_id(p_to_rs_level);
	ln_from_level_id := ec_ctrl_record_status_level.level_id(p_from_rs_level);
  IF NVL(p_reversible_process,'N') = 'Y' THEN
    lv2_default_operator := '>';
  END IF;

	-- have to loop all days because new objects may be created in the middle of the month and objects may be reconected to other parents in the middle of the month. THIS WILL SLOW DONW PERFORMANCE for monthly approval
	FOR myDateCur IN cur_system_days LOOP
		FOR mycur IN cur_tasks(p_process_id) LOOP

    -- mycur.table_id is the data class name. Use the view DV_<dataclass name>
			mysql := 'UPDATE dv_'||mycur.table_id||' d SET d.record_status='||chr(39)||p_to_rs_level||chr(39);
			mysql := mysql||', d.last_updated_by='||chr(39)||p_user_id||chr(39);

			-- If the Revision Text is set to mandatory for the specific class then update the revision text as well
			IF ecdp_classmeta.IsRevTextMandatory(mycur.table_id) = 'Y' THEN
        	mysql := mysql||', d.rev_text = '''|| 'Updated by status process at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy-mm-dd hh24:mi:ss')||'''';
    	END IF;

      mysql := mysql||' WHERE ec_ctrl_record_status_level.level_id(d.record_status)' || lv2_default_operator ||ln_to_level_id;
			IF ln_from_level_id IS NOT NULL THEN
				mysql := mysql||' AND ec_ctrl_record_status_level.level_id(d.record_status)='||ln_from_level_id;
			END IF;

      -- use production_day if sub daily
      FOR myClass IN cur_sub_daily(mycur.table_id) LOOP
  			mysql := mysql||' AND d.production_day = to_date('||chr(39)||to_char(myDateCur.daytime,'DD.MM.YYYY HH24:MI')||chr(39)|| ','||chr(39)||'DD.MM.YYYY HH24:MI'||chr(39)||')';
  	    mysql := mysql||' AND EXISTS ';
  	    lv2_datewhere := ' WHERE o.daytime <= d.production_day AND (o.end_date > d.production_day OR o.end_date IS NULL)';
      END LOOP;

      -- use daytime if daily
      FOR myClass IN cur_daily(mycur.table_id) LOOP
  			mysql := mysql||' AND d.daytime = to_date('||chr(39)||to_char(myDateCur.daytime,'DD.MM.YYYY HH24:MI')||chr(39)|| ','||chr(39)||'DD.MM.YYYY HH24:MI'||chr(39)||')';
  	    mysql := mysql||' AND EXISTS ';
        lv2_datewhere := ' WHERE o.daytime <= d.daytime AND (o.end_date > d.daytime OR o.end_date IS NULL)';
      END LOOP;

	    -- sub select to find correct records
	    -- use owner class name from class
	    FOR mycur2 IN cur_owner_class(mycur.table_id) LOOP
	      lv2_owner_class_name := mycur2.class_name;
	      lv2_owner_class_type := mycur2.class_type;
	    END LOOP;
	    mysql := mysql||' ( SELECT 1 ';
	    IF lv2_owner_class_type = 'INTERFACE' THEN
	      mysql := mysql||' FROM iv_'||lv2_owner_class_name ||' o';
	    ELSIF lv2_owner_class_type = 'OBJECT' THEN
	      mysql := mysql||' FROM ov_'||lv2_owner_class_name ||' o';
	    ELSE
	      mysql := mysql||' FROM iv_facility' ||' o'; -- facility is default
	    END IF;

	    mysql := mysql || lv2_datewhere;
	    mysql := mysql || ' AND d.object_id = o.object_id ';

			IF mycur.where_clause IS NOT NULL THEN
				mysql := mysql||' AND '||mycur.where_clause;
			END IF;
			mysql := mysql ||' ) ';


			-- Debug logging that can be activated when doing debugging
			-- EcDp_DynSql.WriteTempText('PCK_STATUS',mysql);

			li_cursor := Dbms_sql.open_cursor;
			Dbms_sql.parse(li_cursor,mysql,dbms_sql.v7);
			li_return := Dbms_sql.execute(li_cursor);
			Dbms_Sql.Close_Cursor(li_cursor);

			ln_rows_updated := ln_rows_updated + li_return;

		END LOOP;
	END LOOP;

  -- special handling of ctrl_check_log as this is not a class and is not displayed in any screens
  -- Verified records are not displayed as errors anymore
	FOR mycur IN cur_tasks_data_class(p_process_id, 'CTRL_CHECK_LOG') LOOP

      -- mycur.table_id is the data class name. Use the view TV_<dataclass name> as chem_injection_status is a Table class
  		mysql := 'UPDATE '||mycur.table_id||' d SET d.record_status='||chr(39)||p_to_rs_level||chr(39);
  		mysql := mysql||' WHERE ec_ctrl_record_status_level.level_id(d.record_status)<'||ln_to_level_id;
        IF ln_from_level_id IS NOT NULL THEN
           mysql := mysql||' AND ec_ctrl_record_status_level.level_id(d.record_status)='||ln_from_level_id;
        END IF;
  		mysql := mysql||' AND daytime >= to_date('||chr(39)||to_char(p_from_daytime,'DD.MM.YYYY HH24:MI')||chr(39)|| ','||chr(39)||'DD.MM.YYYY HH24:MI'||chr(39)||')'||' AND daytime < to_date('||chr(39)||to_char(p_to_daytime-(1/1440),'DD.MM.YYYY HH24:MI')||chr(39)|| ','||chr(39)||'DD.MM.YYYY HH24:MI'||chr(39)||')+1';
      mysql := mysql||' AND '||mycur.where_clause;

  -- Debug logging that can be activated when doing debugging
  -- EcDp_DynSql.WriteTempText('PCK_STATUS',mysql);

  		li_cursor := Dbms_sql.open_cursor;
  		Dbms_sql.parse(li_cursor,mysql,dbms_sql.v7);
  		li_return := Dbms_sql.execute(li_cursor);
  		Dbms_Sql.Close_Cursor(li_cursor);

  		ln_rows_updated := ln_rows_updated + li_return;

	END LOOP;

  -- special handling of weather
  -- needs to lookup weather site to find facility conection
	FOR mycur IN cur_tasks_data_class(p_process_id, 'WEATHER') LOOP

    -- mycur.table_id is the data class name. Use the view TV_<dataclass name> as chem_injection_status is a Table class
		mysql := 'UPDATE dv_'||mycur.table_id||' d SET d.record_status='||chr(39)||P_To_Rs_Level||chr(39);

	    -- If the Revision Text is set to mandatory for the specific class then update the revision text as well
		IF ecdp_classmeta.IsRevTextMandatory(mycur.table_id) = 'Y' THEN
			mysql := mysql||', d.rev_text = '''|| 'Updated by status process at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy-mm-dd hh24:mi:ss')||'''';
		END IF;

    mysql := mysql||' WHERE ec_ctrl_record_status_level.level_id(d.record_status)'|| lv2_default_operator ||ln_to_level_id;
		IF ln_from_level_id IS NOT NULL THEN
			mysql := mysql||' AND ec_ctrl_record_status_level.level_id(d.record_status)='||ln_from_level_id;
		END IF;

		mysql := mysql||' AND d.daytime BETWEEN to_date('||chr(39)||to_char(p_from_daytime,'DD.MM.YYYY HH24:MI')||chr(39)|| ','||chr(39)||'DD.MM.YYYY HH24:MI'||chr(39)||')'||' AND to_date('||chr(39)||to_char(p_to_daytime+1-(1/1440),'DD.MM.YYYY HH24:MI')||chr(39)|| ','||chr(39)||'DD.MM.YYYY HH24:MI'||chr(39)||')';
		mysql := mysql||' AND EXISTS ('||CHR(10);
		mysql := mysql||'     SELECT 1 FROM iv_facility i'||CHR(10);
		mysql := mysql||'     WHERE i.object_id = d.object_id'||CHR(10);
		mysql := mysql||'     AND to_date('||chr(39)||to_char(p_from_daytime,'DD.MM.YYYY HH24:MI')||chr(39)|| ','||chr(39)||'DD.MM.YYYY HH24:MI'||chr(39)||') BETWEEN i.daytime and nvl(i.end_date-(1/1440),Ecdp_Timestamp.getCurrentSysdate)';
		IF mycur.where_clause IS NOT NULL THEN
			mysql := mysql||'     AND '||mycur.where_clause;
		END IF;
		mysql := mysql||') ';

        -- Debug logging that can be activated when doing debugging
        -- EcDp_DynSql.WriteTempText('PCK_STATUS',mysql);

		li_cursor := Dbms_sql.open_cursor;
		Dbms_sql.parse(li_cursor,mysql,dbms_sql.v7);
		li_return := Dbms_sql.execute(li_cursor);
		Dbms_Sql.Close_Cursor(li_cursor);

		ln_rows_updated := ln_rows_updated + li_return;

	END LOOP;

	  -- special handling of PROD_TEST_RESULT and PROD_TEST_RESULT_SINGLE
 	FOR mycur IN cur_tasks_data_class_prod_test(p_process_id) LOOP

    mysql := 'UPDATE TV_' || mycur.table_id || ' d SET d.record_status='||chr(39)||p_to_rs_level||chr(39);
		mysql := mysql||', d.last_updated_by = EcDp_Context.getAppUser';
    mysql := mysql||', d.last_updated_date = Ecdp_Timestamp.getCurrentSysdate';
		mysql := mysql||' WHERE ec_ctrl_record_status_level.level_id(d.record_status)'|| lv2_default_operator ||ln_to_level_id;
		IF ln_from_level_id IS NOT NULL THEN
			mysql := mysql||' AND ec_ctrl_record_status_level.level_id(d.record_status)='||ln_from_level_id;
		END IF;

		mysql := mysql||' AND d.PRODUCTION_DAY BETWEEN to_date('||chr(39)||to_char(p_from_daytime,'DD.MM.YYYY HH24:MI')||chr(39)|| ','||chr(39)||'DD.MM.YYYY HH24:MI'||chr(39)||')'||' AND to_date('||chr(39)||to_char(p_to_daytime+1-(1/1440),'DD.MM.YYYY HH24:MI')||chr(39)|| ','||chr(39)||'DD.MM.YYYY HH24:MI'||chr(39)||')';
		mysql := mysql||' AND EXISTS ('||CHR(10);
		mysql := mysql||'     SELECT 1 FROM pwel_result pw, ov_well ov'||CHR(10);
		mysql := mysql||'     WHERE d.result_no = pw.result_no'||CHR(10);
		mysql := mysql||'     AND ov.object_id = pw.object_id'||CHR(10);
		mysql := mysql||'     AND d.DAYTIME >= ov.DAYTIME'||CHR(10);
		mysql := mysql||'     AND d.DAYTIME < nvl(ov.END_DATE, d.DAYTIME +1)'||CHR(10);
		mysql := mysql||'     AND to_date('||chr(39)||to_char(p_from_daytime,'DD.MM.YYYY HH24:MI')||chr(39)|| ','||chr(39)||'DD.MM.YYYY HH24:MI'||chr(39)||') BETWEEN ov.daytime and nvl(ov.end_date-(1/1440),Ecdp_Timestamp.getCurrentSysdate)';
		IF mycur.where_clause IS NOT NULL THEN
			mysql := mysql||'     AND '||mycur.where_clause;
		END IF;
		mysql := mysql||') ';

        -- Debug logging that can be activated when doing debugging
        -- EcDp_DynSql.WriteTempText('PCK_STATUS',mysql);

		li_cursor := Dbms_sql.open_cursor;
		Dbms_sql.parse(li_cursor,mysql,dbms_sql.v7);
		li_return := Dbms_sql.execute(li_cursor);
		Dbms_Sql.Close_Cursor(li_cursor);

		ln_rows_updated := ln_rows_updated + li_return;

	END LOOP;

	-- special handling of TV_PERFORMANCE_CURVE, TV_PERF_CURVE_THIRD_AXIS, TV_CURVE_POINT and TV_PERF_CURVE_COEFFS
 	FOR mycur IN cur_perf_curve_table_class (p_process_id) LOOP

		mysql := 'UPDATE TV_' || mycur.table_id || ' d SET d.record_status = '||chr(39)||p_to_rs_level||chr(39);
    mysql := mysql||' WHERE ec_ctrl_record_status_level.level_id(d.record_status)' || lv2_default_operator || ln_to_level_id;
		IF ln_from_level_id IS NOT NULL THEN
			mysql := mysql||' AND ec_ctrl_record_status_level.level_id(d.record_status) = '||ln_from_level_id;
		END IF;

    IF mycur.table_id IN ('PERFORMANCE_CURVE') THEN
		  mysql := mysql||' AND d.daytime BETWEEN to_date('||chr(39)||to_char(p_from_daytime,'DD.MM.YYYY HH24:MI')||chr(39)|| ','||chr(39)||'DD.MM.YYYY HH24:MI'||chr(39)||')'||' AND to_date('||chr(39)||to_char(p_to_daytime+1-(1/1440),'DD.MM.YYYY HH24:MI')||chr(39)|| ','||chr(39)||'DD.MM.YYYY HH24:MI'||chr(39)||')';
		  IF mycur.where_clause IS NOT NULL THEN
		    mysql := mysql||' AND '||mycur.where_clause;
		  END IF;
    ELSIF mycur.table_id IN ('PERF_CURVE_THIRD_AXIS', 'PERF_CURVE_COEFFS') THEN
    	mysql := mysql||' AND EXISTS ('||CHR(10);
		  mysql := mysql||'     SELECT 1 FROM performance_curve a'||CHR(10);
		  mysql := mysql||'     WHERE a.perf_curve_id = d.perf_curve_id'||CHR(10);
		  mysql := mysql||'     AND a.daytime BETWEEN to_date('||chr(39)||to_char(p_from_daytime,'DD.MM.YYYY HH24:MI')||chr(39)|| ','||chr(39)||'DD.MM.YYYY HH24:MI'||chr(39)||')'||' AND to_date('||chr(39)||to_char(p_to_daytime+1-(1/1440),'DD.MM.YYYY HH24:MI')||chr(39)|| ','||chr(39)||'DD.MM.YYYY HH24:MI'||chr(39)||')';
		  IF mycur.where_clause IS NOT NULL THEN
		  	mysql := mysql||'     AND '||mycur.where_clause;
		  END IF;
		  mysql := mysql||') ';
    ELSIF mycur.table_id IN ('CURVE_POINT') THEN
      mysql := mysql||' AND EXISTS ('||CHR(10);
      mysql := mysql||'     SELECT 1 FROM curve b'||CHR(10);
      mysql := mysql||'     WHERE b.curve_id = d.curve_id'||CHR(10);
      mysql := mysql||'     AND EXISTS ('||CHR(10);
      mysql := mysql||'         SELECT 1 FROM performance_curve a'||CHR(10);
      mysql := mysql||'         WHERE a.perf_curve_id = b.perf_curve_id'||CHR(10);
      mysql := mysql||'         AND a.daytime BETWEEN to_date('||chr(39)||to_char(p_from_daytime,'DD.MM.YYYY HH24:MI')||chr(39)|| ','||chr(39)||'DD.MM.YYYY HH24:MI'||chr(39)||')'||' AND to_date('||chr(39)||to_char(p_to_daytime+1-(1/1440),'DD.MM.YYYY HH24:MI')||chr(39)|| ','||chr(39)||'DD.MM.YYYY HH24:MI'||chr(39)||')';
      IF INSTR(UPPER(mycur.where_clause), 'A.') = 0 OR INSTR(UPPER(mycur.where_clause), 'A.') IS NULL THEN
        -- When the "where clause" does not have the condition check on alias "a." (which is performance curve), and then it will close the bracket.
        -- Else, it will still allow the additional logic to include alias "a." if it is found later.
        mysql := mysql||')';
      END IF;
      IF mycur.where_clause IS NOT NULL THEN
        mysql := mysql||'     AND '||mycur.where_clause;
      END IF;
      mysql := mysql||') ';
      -- Here, it will close the bracket if "where clause" with alias "a." (which is filtering the performance curve instead of Curve Point defined as table_id).
      IF INSTR(UPPER(mycur.where_clause), 'A.') > 0 THEN
        mysql := mysql||') ';
      END IF;
    END IF;

    -- Debug logging that can be activated when doing debugging
    -- EcDp_DynSql.WriteTempText('PCK_STATUS',mysql);

		li_cursor := Dbms_sql.open_cursor;
		Dbms_sql.parse(li_cursor,mysql,dbms_sql.v7);
		li_return := Dbms_sql.execute(li_cursor);
		Dbms_Sql.Close_Cursor(li_cursor);

		ln_rows_updated := ln_rows_updated + li_return;

	END LOOP;

   -- special handling of Well_Deferment
    FOR mycur IN cur_deferment(p_process_id) LOOP

        mysql := 'UPDATE TV_' || mycur.table_id || ' d SET d.record_status = '||chr(39)||p_to_rs_level||chr(39);
        IF ecdp_classmeta.IsRevTextMandatory(mycur.table_id) = 'Y' THEN
            mysql := mysql||', d.rev_text = '''|| 'Updated by status process at '||to_char(Ecdp_Timestamp.getCurrentSysdate,'yyyy-mm-dd hh24:mi:ss')||'''';
        END IF;
        mysql := mysql||' WHERE ec_ctrl_record_status_level.level_id(d.record_status)' || lv2_default_operator || ln_to_level_id;
        IF ln_from_level_id IS NOT NULL THEN
            mysql := mysql||' AND ec_ctrl_record_status_level.level_id(d.record_status) = '||ln_from_level_id;
        END IF;
        mysql := mysql||' AND d.day BETWEEN to_date('||chr(39)||to_char(p_from_daytime,'DD.MM.YYYY HH24:MI')||chr(39)|| ','||chr(39)||'DD.MM.YYYY HH24:MI'||chr(39)||')'||' AND to_date('||chr(39)||to_char(p_to_daytime+1-(1/1440),'DD.MM.YYYY HH24:MI')||chr(39)|| ','||chr(39)||'DD.MM.YYYY HH24:MI'||chr(39)||')';
        IF mycur.where_clause IS NOT NULL THEN
            mysql := mysql||' AND '||mycur.where_clause;
        END IF;

        -- EcDp_DynSql.WriteTempText('PCK_STATUS',mysql);

        li_cursor := Dbms_sql.open_cursor;
        Dbms_sql.parse(li_cursor,mysql,dbms_sql.v7);
        li_return := Dbms_sql.execute(li_cursor);
        Dbms_Sql.Close_Cursor(li_cursor);

        ln_rows_updated := ln_rows_updated + li_return;

    END LOOP;


	p_rows_updated := p_rows_updated + nvl(ln_rows_updated,0);
	-- Update the table stat_process_status
	update_stat_process_status(p_process_id, p_to_rs_level, Trunc(p_from_daytime),  Trunc(p_to_daytime), p_rows_updated, p_user_id);

END run_tasks;

--------------------------------------------------------------------------------------------------------------
-- PROCEDURE UPDATE_STAT_PROCESS_STATUS
-------------------------------------------------------------------------------------------------------------
PROCEDURE update_stat_process_status(--p_sysnam VARCHAR2,
                                     p_process_id VARCHAR2,
                                     p_to_rs_level VARCHAR2,
                                     p_from_daytime DATE,
                                     p_to_daytime DATE,
                                     p_rows_updated NUMBER,
                                     p_user_id VARCHAR2 DEFAULT NULL) IS

lv2_new_status VARCHAR2(1);

BEGIN
	lv2_new_status := process_day_rs(p_process_id, p_from_daytime, p_to_daytime);
	-- Only update record_status_level if any records have been updated, else use the record status from prev. run!!!
	IF (lv2_new_status<>p_to_rs_level AND p_rows_updated>0) THEN
		lv2_new_status := p_to_rs_level;
	END IF;

	INSERT INTO stat_process_status (process_id, record_status_level, daytime, run_daytime, end_date, rows_updated, created_by)
	VALUES (p_process_id, lv2_new_status, p_from_daytime, Ecdp_Timestamp.getCurrentSysdate, p_to_daytime, p_rows_updated, p_user_id);

END update_stat_process_status;

--------------------------------------------------------------------------------------------------------------
-- FUNCTION process_day_rs
-------------------------------------------------------------------------------------------------------------
FUNCTION process_day_rs(p_process_id VARCHAR2,
                        p_from_day DATE,
						p_to_day DATE) RETURN VARCHAR2
IS
lv2_status VARCHAR2(1);
CURSOR cur_stat_process_status(p_process_id VARCHAR2, p_from_day DATE, p_to_day DATE) IS
SELECT record_status_level
FROM stat_process_status
WHERE process_id=p_process_id
AND daytime>=p_from_day
AND end_date<=p_to_day
AND run_daytime=
	(SELECT max(run_daytime)
	FROM stat_process_status
	WHERE process_id=p_process_id
	AND daytime>=p_from_day
	AND end_date<=p_to_day)
;
BEGIN
	FOR mycur IN cur_stat_process_status(p_process_id, p_from_day, p_to_day) LOOP
		lv2_status := mycur.record_status_level;
	END LOOP;

	RETURN nvl(lv2_status,'P');

END process_day_rs;

--------------------------------------------------------------------------------------------------------------
-- FUNCTION access_to_process
-------------------------------------------------------------------------------------------------------------
FUNCTION access_to_process(p_process_id VARCHAR2,
                           p_user_id VARCHAR2) RETURN BOOLEAN
IS
lb_access BOOLEAN := FALSE;
ln_number NUMBER := 0;
BEGIN
	SELECT count(*) INTO ln_number
	FROM stat_process_role x,
		t_basis_userrole y
	WHERE x.process_id = p_process_id
	AND x.role_id = y.role_id
	AND upper(y.user_id) = upper(p_user_id)
	;
	IF ln_number>0 THEN
		lb_access := TRUE;
	END IF;
	RETURN lb_access;
END access_to_process;

-----------------------------------------------------------------
-- PROCEDURE: set_cargo_rs_by_code - Wrapper procedure called from client using cargo_code as input.
-----------------------------------------------------------------
PROCEDURE set_cargo_rs_by_code(p_cargo_code VARCHAR2)

IS

CURSOR c_cargo IS
SELECT *
FROM cargo
WHERE cargo_code = p_cargo_code;

BEGIN

   FOR cur_Rec IN c_cargo LOOP

      set_cargo_rs(cur_rec.cargo_no);

   END LOOP;

END set_cargo_rs_by_code;

-----------------------------------------------------------------
-- PROCEDURE: set_cargo_rs - Set record status for all records for a cargo
-----------------------------------------------------------------
PROCEDURE set_cargo_rs(p_cargo_no NUMBER, p_user_id VARCHAR2 DEFAULT NULL) IS

lv2_record_status VARCHAR2(16);

BEGIN

   lv2_record_status := ec_prosty_codes.alt_code(ec_cargo.cargo_status(p_cargo_no),'CARGO_STATUS');
   IF ec_cargo.record_status(p_cargo_no) <> lv2_record_status THEN
      -- update all cargo tables.
   	UPDATE cargo
   	SET record_status = lv2_record_status, last_updated_by = p_user_id
   	WHERE cargo_no = p_cargo_no;

      UPDATE parcel_nomination
      SET record_status = lv2_record_status
      WHERE cargo_no = p_cargo_no;

      UPDATE parcel_load
      SET record_status = lv2_record_status
      WHERE cargo_no = p_cargo_no;

      UPDATE parcel_analysis
      SET record_status = lv2_record_status
      WHERE cargo_no = p_cargo_no;

      UPDATE parcel_discharge
      SET record_status = lv2_record_status
      WHERE cargo_no = p_cargo_no;

      UPDATE cargo_activity
      SET record_status = lv2_record_status
      WHERE cargo_no = p_cargo_no;

   END IF;
END set_cargo_rs;

-----------------------------------------------------------------
-- PROCEDURE: set_alloc_netw_log_status_rs -
-----------------------------------------------------------------
PROCEDURE set_alloc_netw_log_status_rs(p_run_no NUMBER,
                          p_user_id VARCHAR2 DEFAULT NULL) IS

lv2_record_status VARCHAR2(16);
ld_daytime DATE;
lv2_allow_lock VARCHAR2(1);

BEGIN
  ld_daytime := ec_alloc_job_log.daytime(p_run_no);
  lv2_allow_lock := NVL(ec_ctrl_system_attribute.attribute_text(ld_daytime, 'ALLOW_ALLOC_LOCK_MONTH','<='), 'N');

  -- Check for system attribute ALLOW_ALLOC_LOCK_MONTH indicator and Check for locking
   IF UPPER(lv2_allow_lock) = 'N' THEN
    IF EcDp_month_lock.withinLockedMonth(ld_daytime) IS NOT NULL THEN
      EcDp_Month_Lock.raiseValidationError('UPDATING', ld_daytime, ld_daytime, TRUNC(ld_daytime,'MONTH'), 'Can not update calculation log for locked month.');
    END IF;
   END IF;

   lv2_record_status := ec_prosty_codes.alt_code( ec_alloc_job_log.accept_status(p_run_no),
                                                'ALLOC_NETWORK_LOG_STATUS');
   IF ec_alloc_job_log.record_status(p_run_no) <> lv2_record_status THEN
      -- update alloc_network_log
     UPDATE alloc_job_log
     SET record_status = lv2_record_status, last_updated_by = NVL(p_user_id, NVL(EcDp_User_Session.getUserSessionParameter('USERNAME'), User))
     WHERE run_no = p_run_no;
   END IF;
END set_alloc_netw_log_status_rs;


-----------------------------------------------------------------
-- PROCEDURE: set_analysis_rs - Set record status for all records for a cargo
-----------------------------------------------------------------
PROCEDURE set_analysis_rs(p_object_id VARCHAR2,
                          p_analysis_type VARCHAR2,
                          p_sampling_method VARCHAR2,
                          p_daytime DATE,
                          p_user_id VARCHAR2 DEFAULT NULL) IS

lv2_record_status    VARCHAR2(16);
lr_analysis         object_fluid_analysis%ROWTYPE;
lr_next_analysis    object_fluid_analysis%ROWTYPE;

CURSOR c_object_fluid_analysis IS
SELECT *
FROM Object_Fluid_Analysis
WHERE object_id = p_object_id
AND analysis_type = p_analysis_type
AND sampling_method = p_sampling_method
AND daytime = p_daytime;

BEGIN

   FOR mycur IN c_object_fluid_analysis LOOP
      lr_analysis  := mycur;
   END LOOP;

   lv2_record_status := ec_prosty_codes.alt_code(lr_analysis.analysis_status,'ANALYSIS_STATUS');

   -- lock test

   IF lr_analysis.valid_from_date IS NOT NULL AND lr_analysis.analysis_status = 'APPROVED' THEN

     lr_next_analysis := EcDp_Fluid_analysis.getNextAnalysisSample(p_object_id,p_analysis_type,p_sampling_method,lr_analysis.valid_from_date);

     EcDp_month_lock.validatePeriodForLockOverlap('UPDATING', lr_analysis.valid_from_date, lr_next_analysis.valid_from_date, 'pck_status.set_analysis_rs: can not do this for a locked period', p_object_id);

   END IF;

   IF lr_analysis.record_status <> lv2_record_status THEN
      -- update object_fluid_analysis
   	UPDATE object_fluid_analysis
   	SET record_status = lv2_record_status, last_updated_by = p_user_id, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
   	WHERE analysis_no = lr_analysis.analysis_no;

      -- update fluid_analysis_component
   	UPDATE fluid_analysis_component
   	SET record_status = lv2_record_status, last_updated_by = p_user_id, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
   	WHERE analysis_no = lr_analysis.analysis_no;

   END IF;

END set_analysis_rs;


-----------------------------------------------------------------
-- PROCEDURE: set_aga_analysis_rs - Set record status for all records for a object_aga_analysis
-----------------------------------------------------------------
PROCEDURE set_aga_analysis_rs(p_object_id VARCHAR2,
                              p_analysis_type VARCHAR2,
                              p_daytime DATE,
                              p_user_id VARCHAR2 DEFAULT NULL) IS

lv2_record_status    VARCHAR2(16);
lr_analysis         object_aga_analysis%ROWTYPE;
lr_next_analysis    object_aga_analysis%ROWTYPE;

CURSOR c_object_aga_analysis IS
SELECT *
FROM object_aga_analysis
WHERE object_id = p_object_id
AND analysis_type = p_analysis_type
AND daytime = p_daytime;

BEGIN

   FOR mycur IN c_object_aga_analysis LOOP
      lr_analysis  := mycur;
   END LOOP;

   lv2_record_status := ec_prosty_codes.alt_code(lr_analysis.analysis_status,'ANALYSIS_STATUS');

   -- lock test
   IF lr_analysis.valid_from_date IS NOT NULL AND lr_analysis.analysis_status = 'APPROVED' THEN

     lr_next_analysis := EcDp_Stream_Analysis.getNextAGAAnalysisSample(p_object_id, p_daytime+1/86400);
     EcDp_month_lock.validatePeriodForLockOverlap('UPDATING', lr_analysis.daytime, lr_next_analysis.daytime, 'pck_status.set_aga_analysis_rs: can not do this for a locked period', p_object_id);

   END IF;

   IF lr_analysis.record_status <> lv2_record_status THEN
    -- update object_aga_analysis
     UPDATE object_aga_analysis
     SET record_status = lv2_record_status, last_updated_by = p_user_id
     WHERE analysis_no = lr_analysis.analysis_no;

   END IF;
END set_aga_analysis_rs;

-----------------------------------------------------------------
-- PROCEDURE: set_deferment_rs - Set record status for all records for a production deferment
-----------------------------------------------------------------
PROCEDURE set_deferment_rs(p_event_id VARCHAR2, p_user_id VARCHAR2 DEFAULT NULL)
IS
lv2_record_status VARCHAR2(16);
lr_objects_def_event OBJECTS_DEFERMENT_EVENT%ROWTYPE;
BEGIN
   lr_objects_def_event := ec_objects_deferment_event.row_by_pk(p_event_id);
   lv2_record_status := ec_prosty_codes.alt_code(lr_objects_def_event.status,'EVENT_STATUS');

   IF lr_objects_def_event.record_status <> lv2_record_status THEN

     UPDATE objects_deferment_event
     SET record_status = lv2_record_status, last_updated_by = p_user_id
     WHERE (event_id = lr_objects_def_event.event_id
      OR parent_event_id = lr_objects_def_event.event_id)
      AND record_status<>'V';

   END IF;

END set_deferment_rs;

--------------------------------------------------------------------------------------------------------------
-- FUNCTION failChkRecStsLevel
-------------------------------------------------------------------------------------------------------------
FUNCTION failChkRecStsLevel(p_rec_status_level VARCHAR2, p_method VARCHAR2) RETURN VARCHAR2
IS
  CURSOR c_Recs (cp_rec_status_level VARCHAR2, cp_method VARCHAR2) IS
  SELECT c1.record_status_level
  FROM ctrl_record_status_level c1
  WHERE c1.record_status_level = cp_rec_status_level
  AND c1.level_id = (SELECT DECODE(UPPER(cp_method), 'MIN', Min(c2.level_id), 'MAX', Max(c2.level_id), NULL) result
                     FROM ctrl_record_status_level c2);

  lv2_result                  VARCHAR2(1) := '';
  lv2_rec_status_level        ctrl_record_status_level.record_status_level%TYPE;
BEGIN
  FOR mycur IN c_Recs (p_rec_status_level, p_method) LOOP
    lv2_rec_status_level := mycur.record_status_level;
    IF p_rec_status_level = lv2_rec_status_level THEN
      lv2_result := 'Y';
      EXIT;
    END IF;
  END LOOP;
  RETURN lv2_result;
END failChkRecStsLevel;

END; --Package body