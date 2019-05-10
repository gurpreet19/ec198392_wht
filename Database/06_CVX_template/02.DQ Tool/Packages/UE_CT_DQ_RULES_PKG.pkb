CREATE OR REPLACE PACKAGE BODY UE_CT_DQ_RULES_PKG AS
/******************************************************************************
**
** Purpose        :  User exit package for executing data quality rules
**
** Created        :  07.01.2014
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
**
********************************************************************/





---------------------------------------------------------------------------------------------------
-- Procedure: batch_load_dq_results
-- Description    : This is the main procedure for running an entire rule group with an optional rule id
--
--  Called From:  EC Business Action, Run Rules button on Run Rules screen
---------------------------------------------------------------------------------------------------
PROCEDURE batch_load_dq_results(p_rule_group_code varchar2, p_rule_id integer, p_user varchar2, p_start_date date, p_end_date date)
IS

sql_stmt varchar2(10000);
object_sql_stmt varchar2(5000);
          
ld_run_date DATE;
ld_rule_started_date DATE;

ld_start_date date;
ld_end_date  date;
li_run_id integer;
li_rule_group_id integer;
lv_is_report_only varchar2(1);
lv_start_date_source varchar2(200);
lv_end_date_source varchar2(200);

lv_run_type varchar2(32);

max_results EXCEPTION;
PRAGMA EXCEPTION_INIT(max_results, -20029);

max_time EXCEPTION;
PRAGMA EXCEPTION_INIT(max_time, -20030);
      
BEGIN

li_run_id := NULL;
EcDp_System_Key.assignNextNumber('CT_DQ_RUN_ID', li_run_id);

IF li_run_id is NULL THEN
	RAISE_APPLICATION_ERROR(-20020,'Invalid read of assign_id CT_DQ_RUN_ID');
END IF;

ld_run_date := sysdate;
li_rule_group_id := NULL;

BEGIN
SELECT rule_group_id, is_report_only, start_date_source, end_date_source 
into li_rule_group_id, lv_is_report_only, lv_start_date_source, lv_end_date_source
from ct_dq_rule_group where rule_group_code = p_rule_group_code;

EXCEPTION
   	WHEN no_data_found THEN NULL;	
	WHEN OTHERS THEN 
			RAISE;

END;

IF p_rule_id is not NULL THEN

	lv_run_type := 'RULE';

ELSE
	lv_run_type := 'GROUP';

END IF;

CreateRunLog(li_run_id, lv_run_type,li_rule_group_id, p_rule_id, null, null, null, null, null, ld_run_date, p_user);

IF li_rule_group_id is NULL THEN
	UpdateRunLog(li_run_id, 'Rule Group Code ' || p_rule_group_code || ' is not a valid Rule Group', 'FAILURE', p_user);
	RAISE_APPLICATION_ERROR(-20021,'Invalid Rule Group Code');
END IF;

IF nvl(lv_is_report_only,'N') = 'Y' THEN
	UpdateRunLog(li_run_id, 'Rule Group is Report Only', 'FAILURE', p_user);
	RAISE_APPLICATION_ERROR(-20022,'Report Only Group Code');
END IF;

IF lv_start_date_source is not NULL and p_start_Date is NULL THEN  

	BEGIN
        sql_stmt := 'select ' || lv_start_date_source || ' from dual';
	EXECUTE IMMEDIATE sql_stmt into ld_start_Date;

    	EXCEPTION
        	WHEN OTHERS THEN
		UpdateRunLog(li_run_id, 'Invalid Group From Date Source. ' || SQLERRM, 'FAILURE', p_user);
            	RAISE_APPLICATION_ERROR(-20020,'Invalid From Date');

	END;


ELSE

	ld_start_date := nvl(p_start_date, to_Date('01/01/1900','mm/dd/yyyy'));

END IF;



IF lv_end_date_source is not NULL and p_end_date is NULL THEN

	BEGIN
        sql_stmt := 'select ' || lv_end_date_source || ' from dual';
        EXECUTE IMMEDIATE sql_stmt into ld_end_Date;
    	EXCEPTION
        	WHEN OTHERS THEN				
		UpdateRunLog(li_run_id, 'Invalid Group To Date Source. ' || SQLERRM, 'FAILURE', p_user);
            	RAISE_APPLICATION_ERROR(-20020,'Invalid To Date');

    	END;

ELSE

	ld_end_date := nvl(p_end_date, to_Date('12/31/9999','mm/dd/yyyy'));

END IF;

UpdateRunLogParmDates(li_run_id, ld_start_date, ld_end_date );


    begin
        for rec in (select r.rule_id, r.daytime_source, r.object_type, r.result_retention_days 
	from ct_DQ_rule r, ct_dq_rule_grp_combination c 
	where r.rule_id = c.rule_id 
	and c.rule_group_id = li_rule_group_id 
	and r.is_active = 'Y'
	order by r.rule_id)

        loop 

	    	IF p_rule_id is not NULL and p_rule_id <> rec.rule_id THEN

			CONTINUE;			

	    	END IF;   


		ld_rule_Started_Date := sysdate;

		BEGIN
            
            	sql_stmt := convert_rule_to_sql (rec.rule_id, ld_start_date, ld_end_date);

		EXCEPTION
   			WHEN OTHERS THEN
   			UpdateRunLog(li_run_id, 'Rule ID ' || rec.rule_id || ': Invalid Conversion to Dynamic SQL. ' || SQLERRM, 'FAILURE', p_user); 
   			RAISE;
		END;

		--- get the object sql

		BEGIN
            
            	object_sql_stmt := NULL;
            	object_sql_stmt := build_object_sql (rec.object_type);

		EXCEPTION
   			WHEN OTHERS THEN
   			UpdateRunLog(li_run_id, 'Rule ID ' || rec.rule_id || ': Invalid Dynamic SQL for object build. ' || SQLERRM, 'FAILURE', p_user); 
   			RAISE;
		END;

		--- add join to object table for hierarchy

		BEGIN
            
            	sql_stmt := combine_with_object_sql (sql_stmt, object_sql_stmt,null, null, null);

		EXCEPTION
   			WHEN OTHERS THEN
   			UpdateRunLog(li_run_id, 'Rule ID ' || rec.rule_id || ': Invalid Dynamic SQL for object combination. ' || SQLERRM, 'FAILURE', p_user); 
   			RAISE;
		END;

		--- the SQL needs to be date limited based on the rule group configuration

		BEGIN
            
            	sql_stmt := convert_to_date_range_sql (sql_stmt, ld_start_date, ld_end_date);

		EXCEPTION
   			WHEN OTHERS THEN
   			UpdateRunLog(li_run_id, 'Rule ID ' || rec.rule_id || ': Invalid Dynamic SQL for date limitation. ' || SQLERRM, 'FAILURE', p_user); 
   			RAISE;
		END;


		BEGIN
        
	    	Execute_sql_stmt(li_run_id, ld_run_date, sql_stmt, rec.rule_id, li_rule_group_id, p_user);


		EXCEPTION
			WHEN max_results THEN
   			UpdateRunLog(li_run_id, 'Rule ID ' || rec.rule_id || ' ' || SQLERRM, 'FAILURE',p_user); 		
			RAISE;
			WHEN max_time THEN
   			UpdateRunLog(li_run_id, 'Rule ID ' || rec.rule_id || ' ' || SQLERRM, 'FAILURE',p_user); 
			RAISE;
   			WHEN OTHERS THEN
   			UpdateRunLog(li_run_id, 'Rule ID ' || rec.rule_id || ': Error Processing SQL Statement. ' || SQLERRM, 'FAILURE',p_user); 
   			RAISE;
		END;

		---- build the dynamic sql where clause to count and perform the deletes

		sql_stmt := 'from ct_dq_rule_results where rule_id = ' || rec.rule_id || ' and last_run_id <> ' || li_run_id;
		sql_stmt := sql_stmt || ' and ((daytime >= to_date(' || CHR(39) || to_char(ld_start_date,'mm/dd/yyyy hh24:mi:ss') || CHR(39) || ',''mm/dd/yyyy hh24:mi:ss'')';
		sql_stmt := sql_stmt || ' and daytime < to_date(' || CHR(39) || to_char(ld_end_date,'mm/dd/yyyy hh24:mi:ss') || CHR(39) || ',''mm/dd/yyyy hh24:mi:ss'')) or daytime is NULL)';		

		
		PostRuleResultLog(li_run_id, rec.rule_id, ld_rule_started_date, sql_stmt,rec.result_retention_days,p_user);


		--- If the result retention days field is populated then delete any result older than the entered value.  A NULL value assumes they will be kept until resolved.  

		IF rec.result_retention_days is not NULL THEN

  	        	BEGIN

			DELETE FROM CT_DQ_RULE_RESULTS 
			WHERE RULE_ID = rec.RULE_ID 
			AND LAST_RUN_ID <> li_run_id 
			and LAST_RUN_DATE <= sysdate - rec.result_retention_days;

			EXCEPTION
   				WHEN no_data_found THEN NULL;
   				WHEN OTHERS THEN
				UpdateRunLog(li_run_id, 'Rule ID ' || rec.rule_id || ': Error Deleting from CT_DQ_RULE_RESULTS based on retention days. ' || SQLERRM, 'FAILURE', p_user); 
				RAISE;

			END;


		END IF;

		--commit;

        end loop;
        
        END;

UpdateRunLog(li_run_id, NULL, 'SUCCESS', p_user);

end batch_load_dq_results;

---------------------------------------------------------------------------------------------------
-- Procedure: batch_load_dq_results_hier
-- Description    : This is the procedure for Running a Rule Group for a hierarchy. The rule group can either be passed in as a parm
--                  or the default rule group will be utilized.  Rule ID is also optional.
--                  For all rules in the rule group - only the rules assigned via the rule role will be included
--
--  Called From:  ????

---------------------------------------------------------------------------------------------------
PROCEDURE batch_load_dq_results_hier(p_nav_class_name varchar2, p_nav_object_id varchar2, p_group_type varchar2, p_user varchar2)
IS

         
ld_run_date DATE;
ld_rule_started_date DATE;

sql_stmt varchar2(10000);
object_sql_stmt varchar2(5000);

li_run_id integer;
lv_run_type varchar2(32);
ld_start_date date;
ld_end_date date;
li_rule_group_id  integer;
lv_start_date_source varchar2(200);
lv_end_date_source varchar2(200);
lv_is_report_only varchar2(1);
      
BEGIN

ld_run_date := sysdate;
sql_stmt := NULL;
li_run_id := NULL;

li_run_id := NULL;
EcDp_System_Key.assignNextNumber('CT_DQ_RUN_ID', li_run_id);

IF li_run_id is NULL THEN
	RAISE_APPLICATION_ERROR(-20020,'Invalid read of assign_id CT_DQ_RUN_ID');
END IF;


lv_run_type := 'HIERARCHY_DEF_GROUP';

--- select the rule group designated as the run rules group
BEGIN
SELECT rule_group_id, start_date_source, end_date_source, is_report_only
into li_rule_group_id , lv_start_date_source, lv_end_date_source, lv_is_report_only
from ct_dq_rule_group where is_default = 'Y';

EXCEPTION
	WHEN no_data_found THEN
		CreateRunLog(li_run_id, lv_run_type,NULL, NULL, p_group_type, p_nav_object_id, NULL, NULL, NULL, ld_run_date, p_user);
		UpdateRunLog(li_run_id, 'No Default Rule Group Found', 'FAILURE', p_user);
		RAISE;
	WHEN too_many_rows THEN
		CreateRunLog(li_run_id, lv_run_type,NULL, NULL, p_group_type, p_nav_object_id, NULL, NULL, NULL, ld_run_date, p_user);
		UpdateRunLog(li_run_id, 'Multiple Default Rule Groups found. Only One Rule Group Can Be Default', 'FAILURE', p_user);
		RAISE;
   	WHEN OTHERS THEN 
		CreateRunLog(li_run_id, lv_run_type,NULL, NULL, p_group_type, p_nav_object_id, NULL, NULL, NULL, ld_run_date, p_user);
		UpdateRunLog(li_run_id, 'Error Reading CT_DQ_RULE_GROUP for default group: '|| SQLERRM, 'FAILURE', p_user);
		RAISE;

END;

CreateRunLog(li_run_id, lv_run_type,li_rule_group_id, NULL, p_group_type, p_nav_object_id, NULL, NULL, NULL, ld_run_date, p_user);

IF nvl(lv_is_report_only,'N') = 'Y' THEN
	UpdateRunLog(li_run_id, 'Rule Group is Report Only', 'FAILURE', p_user);
	RAISE_APPLICATION_ERROR(-20022,'Report Only Group Code');
END IF;


IF lv_start_date_source is not NULL THEN  

	BEGIN
       	sql_stmt := 'select ' || lv_start_date_source || ' from dual';
	EXECUTE IMMEDIATE sql_stmt into ld_start_Date;

    	EXCEPTION
        	WHEN OTHERS THEN
		UpdateRunLog(li_run_id, 'Invalid Group From Date Source. ' || SQLERRM, 'FAILURE', p_user);
            	RAISE_APPLICATION_ERROR(-20020,'Invalid From Date');

	END;


ELSE

	ld_start_date := to_Date('01/01/1900','mm/dd/yyyy');

END IF;

IF lv_end_date_source is not NULL THEN

	BEGIN
            sql_stmt := 'select ' || lv_end_date_source || ' from dual';
        EXECUTE IMMEDIATE sql_stmt into ld_end_Date;
    	EXCEPTION
        	WHEN OTHERS THEN				
		UpdateRunLog(li_run_id, 'Invalid Group To Date Source. ' || SQLERRM, 'FAILURE', p_user);
            	RAISE_APPLICATION_ERROR(-20020,'Invalid To Date');

    	END;

ELSE

	ld_end_date := to_Date('12/31/9999','mm/dd/yyyy');

END IF;


UpdateRunLogParmDates(li_run_id, ld_start_date, ld_end_date );


    begin
--- select all rules for the selected rule group, but limit to those where the user have access
        for rec in (select r.rule_id, r.daytime_source, r.object_type, r.result_retention_days 
	from ct_DQ_rule r, ct_dq_rule_grp_combination c 
	where r.rule_id = c.rule_id 
	and r.is_active = 'Y' 
	and c.rule_group_id = li_rule_group_id
	AND r.RULE_ID IN 
	(SELECT RULE_ID FROM CT_DQ_RULE, T_BASIS_USERROLE 
	WHERE CT_DQ_RULE.ROLE_ID IS NOT NULL 
	AND CT_DQ_RULE.ROLE_ID = T_BASIS_USERROLE.ROLE_ID
	AND USER_ID = p_user
	UNION ALL
	SELECT RULE_ID FROM CT_DQ_RULE
	WHERE ROLE_ID IS NULL)
	order by r.rule_id)

        loop 

		ld_rule_started_date := sysdate;

		BEGIN
            
            	sql_stmt := convert_rule_to_sql (rec.rule_id, ld_start_date, ld_end_date);

		EXCEPTION
   			WHEN OTHERS THEN
   			UpdateRunLog(li_run_id, 'Rule ID ' || rec.rule_id || ': Invalid Conversion to Dynamic SQL. ' || SQLERRM, 'FAILURE', p_user); 
   			RAISE;
		END;

		BEGIN

            	object_sql_stmt := NULL;
            	object_sql_stmt := build_object_sql (rec.object_type);

		EXCEPTION
   			WHEN OTHERS THEN
   			UpdateRunLog(li_run_id, 'Rule ID ' || rec.rule_id || ': Invalid Dynamic SQL for object build. ' || SQLERRM, 'FAILURE', p_user); 
   			RAISE;
		END;

		--- add join to object table for hierarchy

		BEGIN
            
            	sql_stmt := combine_with_object_sql (sql_stmt, object_sql_stmt, p_nav_class_name, p_nav_object_id, p_group_type);

		EXCEPTION
   			WHEN OTHERS THEN
   			UpdateRunLog(li_run_id, 'Rule ID ' || rec.rule_id || ': Invalid Dynamic SQL for object combination. ' || SQLERRM, 'FAILURE', p_user); 
   			RAISE;
		END;


		--- the SQL needs to be date limited based on the rule group configuration

		BEGIN
            
            	sql_stmt := convert_to_date_range_sql (sql_stmt, ld_start_date, ld_end_date);

		EXCEPTION
   			WHEN OTHERS THEN
   			UpdateRunLog(li_run_id, 'Rule ID ' || rec.rule_id || ': Invalid Dynamic SQL for date limitation. ' || SQLERRM, 'FAILURE', p_user); 
   			RAISE;
		END;


		BEGIN
        
	    	Execute_sql_stmt(li_run_id, ld_run_date, sql_stmt, rec.rule_id, li_rule_group_id, p_user);


		EXCEPTION
   			WHEN OTHERS THEN
   			UpdateRunLog(li_run_id, 'Rule ID ' || rec.rule_id || ': Error Processing SQL Statement. ' || SQLERRM, 'FAILURE',p_user); 
   			RAISE;
		END;

		---- build the dynamic sql where clause to count and perform the deletes
		---- intentionally using <= for end date since the end date is the to_date from the window (so not an end date)

		sql_stmt := 'from ct_dq_rule_results where rule_id = ' || rec.rule_id || ' and last_run_id <> ' || li_run_id;
		sql_stmt := sql_stmt || ' and ((daytime >= to_date(' || CHR(39) || to_char(ld_start_date,'mm/dd/yyyy hh24:mi:ss') || CHR(39) || ',''mm/dd/yyyy hh24:mi:ss'')';
		sql_stmt := sql_stmt || ' and daytime <= to_date(' || CHR(39) || to_char(ld_end_date,'mm/dd/yyyy hh24:mi:ss') || CHR(39) || ',''mm/dd/yyyy hh24:mi:ss'')) or daytime is NULL)';		

		IF p_group_type = 'operational' THEN

			IF p_nav_class_name = 'PRODUCTIONUNIT' THEN

				sql_stmt := sql_stmt || ' and OP_PU_ID = ' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

			ELSIF p_NAV_CLASS_NAME = 'PROD_SUB_UNIT' THEN

				sql_stmt := sql_stmt || ' and OP_SUB_PU_ID = ' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

			ELSIF p_NAV_CLASS_NAME = 'AREA' THEN

				sql_stmt := sql_stmt || ' and OP_AREA_ID = ' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

			ELSIF p_NAV_CLASS_NAME = 'SUB_AREA' THEN

				sql_stmt := sql_stmt || ' and OP_SUB_AREA_ID = ' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

			ELSIF p_NAV_CLASS_NAME = 'FCTY_CLASS_2' THEN

				sql_stmt := sql_stmt || ' and OP_FCTY_CLASS_2_ID = ' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

			ELSIF p_NAV_CLASS_NAME = 'FCTY_CLASS_1' THEN

				sql_stmt := sql_stmt || ' and OP_FCTY_CLASS_1_ID = ' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

			END IF;

		ELSIF p_group_type = 'collection_point' THEN

			IF p_nav_class_name = 'PRODUCTIONUNIT' THEN

				sql_stmt := sql_stmt || ' and CP_PU_ID = ' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

			ELSIF p_NAV_CLASS_NAME = 'PROD_SUB_UNIT' THEN

				sql_stmt := sql_stmt || ' and CP_SUB_PU_ID = ' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

			ELSIF p_NAV_CLASS_NAME = 'AREA' THEN

				sql_stmt := sql_stmt || ' and CP_AREA_ID = ' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

			ELSIF p_NAV_CLASS_NAME = 'SUB_AREA' THEN

				sql_stmt := sql_stmt || ' and CP_SUB_AREA_ID = ' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

			ELSIF p_NAV_CLASS_NAME = 'OPERATOR_ROUTE' THEN

				sql_stmt := sql_stmt || ' and CP_OPERATOR_ROUTE_ID = ' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

			ELSIF p_NAV_CLASS_NAME = 'COLLECTION_POINT' THEN

				sql_stmt := sql_stmt || ' and CP_COL_POINT_ID = ' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

			END IF;

		END IF;


		PostRuleResultLog(li_run_id, rec.rule_id, ld_rule_started_date, sql_stmt, rec.result_retention_days, p_user);


		--- If the result retention days field is populated then delete any result older than the entered value.  A NULL value assumes they will be kept until resolved.  

		IF rec.result_retention_days is not NULL THEN

  	        	BEGIN

----- delete for retention not restricted by hierarchy

			DELETE FROM CT_DQ_RULE_RESULTS 
			WHERE RULE_ID = rec.RULE_ID 
			AND LAST_RUN_ID <> li_run_id 
			and LAST_RUN_DATE <= sysdate - rec.result_retention_days;

			EXCEPTION
   				WHEN no_data_found THEN NULL;
   				WHEN OTHERS THEN
				UpdateRunLog(li_run_id, 'Rule ID ' || rec.rule_id || ': Error Deleting from CT_DQ_RULE_RESULTS based on retention days. ' || SQLERRM, 'FAILURE', p_user); 
				RAISE;

			END;


		END IF;

	--	commit;

        end loop;
        
        END;

UpdateRunLog(li_run_id, NULL, 'SUCCESS', p_user);

end batch_load_dq_results_hier;

---------------------------------------------------------------------------------------------------
-- Procedure: batch_load_dq_results_single
-- Description    : This is the procedure for running a DQ rule for a specific record (object_id, daytime, alt unique_key)
--
--  Called From:  ??
---------------------------------------------------------------------------------------------------
PROCEDURE batch_load_dq_results_single(p_rule_id integer, p_object_id varchar2, p_daytime date, p_alt_unique_key varchar2, p_user varchar2)
IS

sql_stmt varchar2(10000);
object_sql_stmt varchar2(5000);
          
ld_run_date DATE;

li_run_id integer;

lv_object_type varchar2(32);
li_retention_days integer;
lv_is_active varchar2(1);

      
BEGIN

li_run_id := NULL;
EcDp_System_Key.assignNextNumber('CT_DQ_RUN_ID', li_run_id);

IF li_run_id is NULL THEN
	RAISE_APPLICATION_ERROR(-20020,'Invalid read of assign_id CT_DQ_RUN_ID');
END IF;

ld_run_date := sysdate;

CreateRunLog(li_run_id, 'RECORD', NULL, p_rule_id, NULL, NULL, p_object_id, p_daytime, p_alt_unique_key, ld_run_date, p_user);


IF p_rule_id is NULL THEN

	UpdateRunLog(li_run_id, 'Rule ID is required', 'FAILURE', p_user);
	RAISE_APPLICATION_ERROR(-20021,'Rule ID is required');

END IF;

BEGIN

SELECT OBJECT_TYPE, RESULT_RETENTION_DAYS, IS_ACTIVE
into lv_object_type, li_retention_days, lv_is_active
FROM CT_DQ_RULE
WHERE RULE_ID = P_RULE_ID;

EXCEPTION
	WHEN no_data_found THEN
	UpdateRunLog(li_run_id, 'Invalid Rule ID ' || p_rule_id, 'FAILURE', p_user); 
	RAISE;
	WHEN OTHERS THEN
	UpdateRunLog(li_run_id, 'Error Reading CT_DQ_RULE for Rule ID ' || p_rule_id || ';' || SQLERRM, 'FAILURE', p_user); 
	RAISE;
END;

IF nvl(lv_is_active,'N') <> 'Y' THEN
	UpdateRunLog(li_run_id, 'Rule is not active: ' || p_rule_id, 'FAILURE', p_user); 
	RAISE_APPLICATION_ERROR(-20022,'Rule is not active');
END IF; 


BEGIN
            
sql_stmt := convert_rule_to_sql (p_rule_id, NULL, NULL);

EXCEPTION
   	WHEN OTHERS THEN
   	UpdateRunLog(li_run_id, 'Rule ID ' || p_rule_id || ': Invalid Conversion to Dynamic SQL. ' || SQLERRM, 'FAILURE', p_user); 
   	RAISE;
END;

--- get the object sql

BEGIN
            
object_sql_stmt := NULL;
object_sql_stmt := build_object_sql (lv_object_type);

EXCEPTION
   	WHEN OTHERS THEN
   	UpdateRunLog(li_run_id, 'Rule ID ' || p_rule_id || ': Invalid Dynamic SQL for object build. ' || SQLERRM, 'FAILURE', p_user); 
   	RAISE;
END;

--- add join to object table for hierarchy

BEGIN
            
sql_stmt := combine_with_object_sql (sql_stmt, object_sql_stmt,null, null, null);

EXCEPTION
   	WHEN OTHERS THEN
   	UpdateRunLog(li_run_id, 'Rule ID ' || p_rule_id || ': Invalid Dynamic SQL for object combination. ' || SQLERRM, 'FAILURE', p_user); 
   	RAISE;
END;

--- the SQL needs to be date limited based on the rule group configuration

BEGIN
            
sql_stmt := convert_to_single_sql (sql_stmt, p_object_id, p_daytime, p_alt_unique_key);

EXCEPTION
   	WHEN OTHERS THEN
   	UpdateRunLog(li_run_id, 'Rule ID ' || p_rule_id || ': Invalid Dynamic SQL for single. ' || SQLERRM, 'FAILURE', p_user); 
   	RAISE;
END;


BEGIN

Execute_sql_stmt(li_run_id, ld_run_date, sql_stmt, p_rule_id, null, p_user);


EXCEPTION
   	WHEN OTHERS THEN
   	UpdateRunLog(li_run_id, 'Rule ID ' || p_rule_id || ': Error Processing SQL Statement. ' || SQLERRM, 'FAILURE',p_user); 
   	RAISE;
END;


---- build the dynamic sql where clause to count and perform the deletes

sql_stmt := 'from ct_dq_rule_results where rule_id = ' || p_rule_id || ' and last_run_id <> ' || li_run_id;

IF p_daytime is not NULL THEN
	sql_stmt := sql_stmt || ' and daytime = to_date(' || CHR(39) || to_char(p_daytime,'mm/dd/yyyy hh24:mi:ss') || CHR(39) || ',''mm/dd/yyyy hh24:mi:ss'')';		
ELSE
	sql_stmt := sql_stmt || ' and daytime is NULL';		
END IF;

sql_stmt := sql_stmt || ' and object_id = ' || CHR(39) || p_object_id || CHR(39);

IF p_alt_unique_key is not NULL THEN
	sql_stmt := sql_stmt || ' and (alt_unique_key = ' || CHR(39) || p_alt_unique_key || CHR(39);
ELSE
	sql_stmt := sql_stmt || ' and alt_unique_key is NULL';
END IF;			

PostRuleResultLog(li_run_id, p_rule_id, ld_run_date, sql_stmt, NULL,p_user);


UpdateRunLog(li_run_id, NULL, 'SUCCESS', p_user);

end batch_load_dq_results_single;

---------------------------------------------------------------------------------------------------
-- Procedure: batch_reload_single_result
-- Description    : This is the procedure for re-running a single Rule Result
--
--  Called From:  Rule Results - Run Selected button
---------------------------------------------------------------------------------------------------
PROCEDURE batch_reload_single_result(p_result_id integer, p_user varchar2)
IS

         
ld_run_date DATE;
sql_stmt varchar2(10000);
object_sql_stmt varchar2(5000);

li_run_id integer;

li_rule_id integer;
lv_object_id varchar2(32);
ld_daytime date;
lv_alt_unique_key varchar2(200);
      
BEGIN

ld_run_date := sysdate;
sql_stmt := NULL;
li_run_id := NULL;

li_run_id := NULL;
EcDp_System_Key.assignNextNumber('CT_DQ_RUN_ID', li_run_id);

IF li_run_id is NULL THEN
	RAISE_APPLICATION_ERROR(-20020,'Invalid read of assign_id CT_DQ_RUN_ID');
END IF;

BEGIN

SELECT RULE_ID, OBJECT_ID, DAYTIME, ALT_UNIQUE_KEY
INTO li_rule_id, lv_object_id, ld_daytime, lv_alt_unique_key
FROM CT_DQ_RULE_RESULTS
WHERE RESULT_ID = p_result_id;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	CreateRunLog(li_run_id, 'ERROR_RECORD', NULL, NULL, NULL, NULL, NULL, NULL, NULL, ld_run_date, p_user);
	UpdateRunLog(li_run_id, 'Result not found for Result ID: ' || p_result_id, 'FAILURE', p_user); 
	RAISE;
	WHEN OTHERS THEN
	CreateRunLog(li_run_id, 'ERROR_RECORD', NULL, NULL, NULL, NULL, NULL, NULL, NULL, ld_run_date, p_user);
	UpdateRunLog(li_run_id, 'Invalid read of CT_DQ_RULE_RESULT for Result ID: ' || p_result_id || ';' || SQLERRM, 'FAILURE', p_user); 
	RAISE;
END;

CreateRunLog(li_run_id, 'ERROR_RECORD', NULL, li_rule_id, NULL, NULL, lv_object_id, ld_daytime, lv_alt_unique_key, ld_run_date, p_user);


BEGIN

sql_stmt := convert_rule_to_sql (li_rule_id, ld_daytime, ld_daytime + 1);

EXCEPTION
   	WHEN OTHERS THEN
   	UpdateRunLog(li_run_id, 'Rule ID ' || li_rule_id || ': Invalid Conversion to Dynamic SQL. ' || SQLERRM, 'FAILURE', p_user); 
   	RAISE;
END;

--- get the object sql

BEGIN
            
object_sql_stmt := NULL;
object_sql_stmt := build_object_sql (EC_CT_DQ_RULE.object_type(li_rule_id));

EXCEPTION
   	WHEN OTHERS THEN
   	UpdateRunLog(li_run_id, 'Rule ID ' || li_rule_id || ': Invalid Dynamic SQL for object build. ' || SQLERRM, 'FAILURE', p_user); 
   	RAISE;
END;

--- add join to object table for hierarchy

BEGIN
            
sql_stmt := combine_with_object_sql (sql_stmt, object_sql_stmt,null, null, null);

EXCEPTION
   	WHEN OTHERS THEN
   	UpdateRunLog(li_run_id, 'Rule ID ' || li_rule_id || ': Invalid Dynamic SQL for object combination. ' || SQLERRM, 'FAILURE', p_user); 
   	RAISE;
END;


BEGIN

sql_stmt := convert_to_single_sql (sql_stmt, lv_object_id, ld_daytime, lv_alt_unique_key);

EXCEPTION
   	WHEN OTHERS THEN
   	UpdateRunLog(li_run_id, 'Rule ID ' || li_rule_id || ': Invalid Conversion to Single Dynamic SQL. ' || SQLERRM, 'FAILURE', p_user); 
   	RAISE;
END;

BEGIN

--- process sql stmt

Execute_sql_stmt(li_run_id, ld_run_date, sql_stmt, li_rule_id, NULL, p_user);

EXCEPTION
   	WHEN OTHERS THEN
   	UpdateRunLog(li_run_id, 'Rule ID ' || li_rule_id || ': Error Processing SQL Statement. ' || SQLERRM, 'FAILURE',p_user); 
   	RAISE;
END;


---- build the dynamic sql where clause to count and perform the deletes

sql_stmt := 'from ct_dq_rule_results where rule_id = ' || li_rule_id || ' and last_run_id <> ' || li_run_id;
sql_stmt := sql_stmt || ' and result_id = ' || p_result_id;	

PostRuleResultLog(li_run_id, li_rule_id, ld_run_date, sql_stmt, NULL, p_user);


UpdateRunLog(li_run_id, NULL, 'SUCCESS', p_user);

end batch_reload_single_result;


---------------------------------------------------------------------------------------------------
-- Procedure: batch_reload_result_group
-- Description    : This is the procedure for re-running a group of Rule Results based on a date and hierarchy
--
--  Called From:  Rule Results - Run All button
---------------------------------------------------------------------------------------------------
PROCEDURE batch_reload_result_group(p_rule_id integer, p_nav_class_name varchar2, p_nav_object_id varchar2, p_start_date date, p_end_date date, p_user varchar2, p_group_type varchar2)
IS

         
ld_run_date DATE;
sql_stmt varchar2(10000);
object_sql_stmt  varchar2(5000);
li_run_id integer;

sql_stmt_hold varchar2(10000);
      
BEGIN


ld_run_date := sysdate;

li_run_id := NULL;
EcDp_System_Key.assignNextNumber('CT_DQ_RUN_ID', li_run_id);

IF li_run_id is NULL THEN
	RAISE_APPLICATION_ERROR(-20020,'Invalid read of assign_id CT_DQ_RUN_ID');
END IF;

CreateRunLog(li_run_id, 'ERROR_HIERARCHY', NULL, p_rule_id, p_group_type, p_nav_object_id, NULL, NULL, NULL, ld_run_date, p_user);

UpdateRunLogParmDates(li_run_id, p_start_date, p_end_date );

BEGIN

sql_stmt := convert_rule_to_sql (p_rule_id, p_start_date, p_end_date + 1);

EXCEPTION
   	WHEN OTHERS THEN
   	UpdateRunLog(li_run_id, 'Rule ID ' || p_rule_id || ': Invalid Conversion to Dynamic SQL. ' || SQLERRM, 'FAILURE', p_user); 
   	RAISE;
END;

--- get the object sql

BEGIN
            
object_sql_stmt := NULL;
object_sql_stmt := build_object_sql (ec_ct_dq_rule.object_type(p_rule_id));

EXCEPTION
   	WHEN OTHERS THEN
   	UpdateRunLog(li_run_id, 'Rule ID ' || p_rule_id || ': Invalid Dynamic SQL for object build. ' || SQLERRM, 'FAILURE', p_user); 
   	RAISE;
END;

--- add join to object table for hierarchy

BEGIN
            
sql_stmt := combine_with_object_sql (sql_stmt, object_sql_stmt,null, null, null);

EXCEPTION
   	WHEN OTHERS THEN
   	UpdateRunLog(li_run_id, 'Rule ID ' || p_rule_id || ': Invalid Dynamic SQL for object combination. ' || SQLERRM, 'FAILURE', p_user); 
   	RAISE;
END;

sql_stmt_hold := sql_stmt;
object_sql_stmt := NULL;


    begin
        for rec in (select rr.object_id, rr.daytime, rr.alt_unique_key, rr.result_id 
	from ct_dq_rule_results rr 
	where rr.rule_id = p_rule_id
	and (rr.daytime is NULL
	or (rr.daytime >= p_start_date
	and rr.daytime <= p_end_date)) 
	and (p_group_type = 'operational' and p_NAV_CLASS_NAME = 'PRODUCTIONUNIT' and rr.OP_PU_ID = p_NAV_OBJECT_ID
	or p_group_type = 'collection_point' and p_NAV_CLASS_NAME = 'PRODUCTIONUNIT' and rr.CP_PU_ID = p_NAV_OBJECT_ID
	or p_group_type = 'operational' and p_NAV_CLASS_NAME = 'PROD_SUB_UNIT' and rr.OP_SUB_PU_ID = p_NAV_OBJECT_ID
	or p_group_type = 'collection_point' and p_NAV_CLASS_NAME = 'PROD_SUB_UNIT' and rr.CP_SUB_PU_ID = p_NAV_OBJECT_ID
	or p_group_type = 'operational' and p_NAV_CLASS_NAME = 'AREA' and rr.OP_AREA_ID = p_NAV_OBJECT_ID
	or p_group_type = 'collection_point' and p_NAV_CLASS_NAME = 'AREA' and rr.CP_AREA_ID = p_NAV_OBJECT_ID
	or p_group_type = 'operational' and p_NAV_CLASS_NAME = 'SUB_AREA' and rr.OP_SUB_AREA_ID = p_NAV_OBJECT_ID
	or p_group_type = 'collection_point' and p_NAV_CLASS_NAME = 'SUB_AREA' and rr.CP_SUB_AREA_ID = p_NAV_OBJECT_ID
	or p_group_type = 'operational' and p_NAV_CLASS_NAME = 'FCTY_CLASS_2' and rr.OP_FCTY_CLASS_2_ID = p_NAV_OBJECT_ID
	or p_group_type = 'operational' and p_NAV_CLASS_NAME = 'FCTY_CLASS_1' and rr.OP_FCTY_CLASS_1_ID = p_NAV_OBJECT_ID
	or p_group_type = 'collection_point' and p_NAV_CLASS_NAME = 'OPERATOR_ROUTE' and rr.CP_OPERATOR_ROUTE_ID = p_NAV_OBJECT_ID
	or p_group_type = 'collection_point' and p_NAV_CLASS_NAME = 'COLLECTION_POINT' and rr.CP_COL_POINT_ID = p_NAV_OBJECT_ID)
	)

        loop 

		sql_stmt := NULL;

		BEGIN

		sql_stmt := convert_to_single_sql (sql_stmt_hold, rec.object_id, rec.daytime, rec.alt_unique_key);

		EXCEPTION
   			WHEN OTHERS THEN
   			UpdateRunLog(li_run_id, 'Rule ID ' || p_rule_id || ': Invalid Conversion to Single Dynamic SQL. ' || SQLERRM, 'FAILURE', p_user); 
   			RAISE;
		END;

		BEGIN

		--- process sql stmt

		Execute_sql_stmt(li_run_id, ld_run_date, sql_stmt, p_rule_id, NULL, p_user);

		EXCEPTION
   			WHEN OTHERS THEN
   			UpdateRunLog(li_run_id, 'Rule ID ' || p_rule_id || ': Error Processing SQL Statement. ' || SQLERRM, 'FAILURE',p_user); 
   			RAISE;
		END;

	end loop;

    end;


---- build the dynamic sql where clause to count and perform the deletes
---- intentionally using <= for end date since this is the to_date passed from the screen

sql_stmt := 'from ct_dq_rule_results where rule_id = ' || p_rule_id || ' and last_run_id <> ' || li_run_id;
sql_stmt := sql_stmt || ' and ((daytime >= to_date(' || CHR(39) || to_char(p_start_date,'mm/dd/yyyy hh24:mi:ss') || CHR(39) || ',''mm/dd/yyyy hh24:mi:ss'')';
sql_stmt := sql_stmt || ' and daytime <= to_date(' || CHR(39) || to_char(p_end_date,'mm/dd/yyyy hh24:mi:ss') || CHR(39) || ',''mm/dd/yyyy hh24:mi:ss'')) or daytime is NULL)';		


IF p_group_type = 'operational' THEN

	IF p_nav_class_name = 'PRODUCTIONUNIT' THEN

		sql_stmt := sql_stmt || ' and OP_PU_ID = ' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

	ELSIF p_NAV_CLASS_NAME = 'PROD_SUB_UNIT' THEN

		sql_stmt := sql_stmt || ' and OP_SUB_PU_ID = ' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

	ELSIF p_NAV_CLASS_NAME = 'AREA' THEN

		sql_stmt := sql_stmt || ' and OP_AREA_ID = ' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

	ELSIF p_NAV_CLASS_NAME = 'SUB_AREA' THEN

		sql_stmt := sql_stmt || ' and OP_SUB_AREA_ID = ' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

	ELSIF p_NAV_CLASS_NAME = 'FCTY_CLASS_2' THEN

		sql_stmt := sql_stmt || ' and OP_FCTY_CLASS_2_ID = ' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

	ELSIF p_NAV_CLASS_NAME = 'FCTY_CLASS_1' THEN

		sql_stmt := sql_stmt || ' and OP_FCTY_CLASS_1_ID = ' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

	END IF;

ELSIF p_group_type = 'collection_point' THEN

	IF p_nav_class_name = 'PRODUCTIONUNIT' THEN

		sql_stmt := sql_stmt || ' and CP_PU_ID = ' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

	ELSIF p_NAV_CLASS_NAME = 'PROD_SUB_UNIT' THEN

		sql_stmt := sql_stmt || ' and CP_SUB_PU_ID = ' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

	ELSIF p_NAV_CLASS_NAME = 'AREA' THEN

		sql_stmt := sql_stmt || ' and CP_AREA_ID = ' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

	ELSIF p_NAV_CLASS_NAME = 'SUB_AREA' THEN

		sql_stmt := sql_stmt || ' and CP_SUB_AREA_ID = ' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

	ELSIF p_NAV_CLASS_NAME = 'OPERATOR_ROUTE' THEN

		sql_stmt := sql_stmt || ' and CP_OPERATOR_ROUTE_ID = ' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

	ELSIF p_NAV_CLASS_NAME = 'COLLECTION_POINT' THEN

		sql_stmt := sql_stmt || ' and CP_COL_POINT_ID = ' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

	END IF;

END IF;

PostRuleResultLog(li_run_id, p_rule_id, ld_run_date, sql_stmt, NULL, p_user);

UpdateRunLog(li_run_id, NULL, 'SUCCESS', p_user);

end batch_reload_result_group;


---------------------------------------------------------------------------------------------------
-- Function: convert_rule_to_sql
-- Description    : This is the function for turning the Rule config into a SQL statement
--
--  Called From:  procedures batch_load_dq_results, batch_load_dq_resutls_hier, batch_load_dq_results_single, batch_reload_single_result, batch_reload_result_group
--                also called as part of SQL attribute on tv_ct_dq_rule
---------------------------------------------------------------------------------------------------
FUNCTION convert_rule_to_sql (
        p_rule_id integer, p_start_date date, p_end_date date)
RETURN VARCHAR2 IS

lv_return_sql varchar2(10000);
sql_stmt varchar2(10000);
ADDNL_INFO VARCHAR2(1000);
lv_sql_fld_1_source   VARCHAR2(200);
lv_sql_fld_2_source   VARCHAR2(200);
lv_sql_fld_3_source   VARCHAR2(200);
lv_sql_fld_4_source   VARCHAR2(200);
lv_sql_fld_5_source   VARCHAR2(200);

LN_COLON_POSITION NUMBER;
LN_SPACE_POSITION NUMBER;

LV_ADDNL_INFO_BEFORE  VARCHAR2(1000);
LV_ADDNL_INFO_VARIABLE  VARCHAR2(1000);
LV_ADDNL_INFO_AFTER  VARCHAR2(1000);

LD_START_DATE DATE;
LD_END_DATE DATE;

LV_SQL_TEMP VARCHAR2(5000);

 
BEGIN


    begin
        for rec in (SELECT FROM_sql, OBJECT_ID_SOURCE, DAYTIME_SOURCE, ALT_UNIQUE_KEY_SOURCE, SQL_FLD_1_SOURCE, SQL_FLD_2_SOURCE, SQL_FLD_3_SOURCE, SQL_FLD_4_SOURCE, SQL_FLD_5_SOURCE, ADDNL_INFO 
	from CT_DQ_RULE where rule_id = p_rule_id)

        loop 

		LD_START_DATE := nvl(p_start_date, TO_DATE('01/01/1900','MM/DD/YYYY'));
		LD_END_DATE := nvl(p_end_date, TO_DATE('12/31/9999','MM/DD/YYYY'));
        
		sql_stmt := NULL;
            
            	IF REC.FROM_SQL IS NOT NULL THEN   
        
                	sql_stmt := 'SELECT' || CHR(10);
            
                	IF rec.OBJECT_ID_SOURCE is not null then
                

                    		sql_stmt := SQL_STMT || ' ' || REC.OBJECT_ID_SOURCE || ' AS OBJECT_ID' || CHR(10);
                    
                	ELSE
                

                    		sql_stmt := SQL_STMT || ' ' || 'OBJECT_ID' || ' AS OBJECT_ID' || CHR(10);

                
                	END IF;
               
                
                	IF rec.DAYTIME_SOURCE is not null then
                
                        	LV_SQL_TEMP := rec.DAYTIME_SOURCE;

                        	IF INSTR(LV_SQL_TEMP,':START_DATE') > 0 THEN

                            		LV_SQL_TEMP := REPLACE(LV_SQL_TEMP,':START_DATE','TO_DATE(''' || TO_CHAR(LD_START_DATE,'MM/DD/YYYY') || ''',''MM/DD/YYYY'')');

                        	END IF;    

                        	IF INSTR(LV_SQL_TEMP,':END_DATE') > 0 THEN

                            		LV_SQL_TEMP := REPLACE(LV_SQL_TEMP,':END_DATE','TO_DATE(''' || TO_CHAR(LD_END_DATE,'MM/DD/YYYY') || ''',''MM/DD/YYYY'')');

                        	END IF;    
                                    
                    		sql_stmt := SQL_STMT || ',' || LV_SQL_TEMP || ' AS DAYTIME' || CHR(10);
                    
                	ELSE
                
                    		sql_stmt := SQL_STMT || ',' || 'NULL' || ' AS DAYTIME' || CHR(10);
                
                	END IF;

                	IF rec.ALT_UNIQUE_KEY_SOURCE is not null then
                
                    		sql_stmt := SQL_STMT || ',' || REC.ALT_UNIQUE_KEY_SOURCE || ' AS ALT_UNIQUE_KEY' || CHR(10);
                    
                	ELSE
                
                    		sql_stmt := SQL_STMT || ',' || 'NULL' || ' AS ALT_UNIQUE_KEY' || CHR(10);
                
                	END IF;                


			lv_sql_fld_1_source := GET_SQL_ATTRIBUTE_NAME('SQL_FLD_1'); 
			lv_sql_fld_2_source := GET_SQL_ATTRIBUTE_NAME('SQL_FLD_2'); 
			lv_sql_fld_3_source := GET_SQL_ATTRIBUTE_NAME('SQL_FLD_3'); 
			lv_sql_fld_4_source := GET_SQL_ATTRIBUTE_NAME('SQL_FLD_4'); 
			lv_sql_fld_5_source := GET_SQL_ATTRIBUTE_NAME('SQL_FLD_5'); 


			IF lv_sql_fld_1_source IS NOT NULL OR lv_sql_fld_2_source IS NOT NULL OR lv_sql_fld_3_source IS NOT NULL OR lv_sql_fld_4_source IS NOT NULL OR lv_sql_fld_5_source IS NOT NULL 
			THEN
			
                		IF rec.SQL_FLD_1_SOURCE is not null then
                
                    			sql_stmt := SQL_STMT || ',' || REC.SQL_FLD_1_SOURCE || ' AS ' || lv_sql_fld_1_source || CHR(10);
                    
                		ELSE
                
                    			sql_stmt := SQL_STMT || ',' || 'NULL' || ' AS ' || NVL(lv_sql_fld_1_source,'SQL_FLD_1') || CHR(10);
                
                		END IF; 

			END IF;               


			IF lv_sql_fld_2_source IS NOT NULL OR lv_sql_fld_3_source IS NOT NULL OR lv_sql_fld_4_source IS NOT NULL OR lv_sql_fld_5_source IS NOT NULL
			THEN
			
                		IF rec.SQL_FLD_2_SOURCE is not null then
                
                    			sql_stmt := SQL_STMT || ',' || REC.SQL_FLD_2_SOURCE || ' AS ' || lv_sql_fld_2_source || CHR(10);
                    
                		ELSE
                
                    			sql_stmt := SQL_STMT || ',' || 'NULL' || ' AS ' || NVL(lv_sql_fld_2_source,'SQL_FLD_2') || CHR(10);
                
                		END IF; 

			END IF; 

			IF lv_sql_fld_3_source IS NOT NULL OR lv_sql_fld_4_source IS NOT NULL OR lv_sql_fld_5_source IS NOT NULL
			THEN
			
                		IF rec.SQL_FLD_3_SOURCE is not null then
                
                    			sql_stmt := SQL_STMT || ',' || REC.SQL_FLD_3_SOURCE || ' AS ' || lv_sql_fld_3_source || CHR(10);
                    
                		ELSE
                
                    			sql_stmt := SQL_STMT || ',' || 'NULL' || ' AS ' || NVL(lv_sql_fld_3_source,'SQL_FLD_3') || CHR(10);
                
                		END IF; 

			END IF; 

			IF lv_sql_fld_4_source IS NOT NULL OR lv_sql_fld_5_source IS NOT NULL
			THEN
			
                		IF rec.SQL_FLD_4_SOURCE is not null then
                
                    			sql_stmt := SQL_STMT || ',' || REC.SQL_FLD_4_SOURCE || ' AS ' || lv_sql_fld_4_source || CHR(10);
                    
                		ELSE
                
                    			sql_stmt := SQL_STMT || ',' || 'NULL' || ' AS ' || NVL(lv_sql_fld_4_source,'SQL_FLD_4') || CHR(10);
                
                		END IF; 

			END IF; 


			IF lv_sql_fld_5_source IS NOT NULL THEN
			
                		IF rec.SQL_FLD_5_SOURCE is not null then
                
                    			sql_stmt := SQL_STMT || ',' || REC.SQL_FLD_5_SOURCE || ' AS ' || lv_sql_fld_5_source || CHR(10);
                    
                		ELSE
                
                    			sql_stmt := SQL_STMT || ',' || 'NULL' || ' AS ' || NVL(lv_sql_fld_5_source,'SQL_FLD_5') || CHR(10);
                
                		END IF; 

			END IF; 
 
			---- build ADDNL_INFO

			IF REC.ADDNL_INFO IS NOT NULL THEN

				ADDNL_INFO := TRIM(REC.ADDNL_INFO);

				---- add a quote to lead the ADDNL_INFO if there is not one already entered and a variable does not lead the ADDNL_INFO

				IF SUBSTR(ADDNL_INFO,0,1) = CHR(39) OR SUBSTR(ADDNL_INFO,0,1) = ':' THEN
				
					NULL;
			
				ELSE
				
					ADDNL_INFO := CHR(39) || ADDNL_INFO;

				END IF;

				---- locate all variables identified by : and replace with the variable name

				LN_COLON_POSITION := INSTR(ADDNL_INFO,':');
 
				IF LN_COLON_POSITION > 0 THEN


					WHILE LN_COLON_POSITION <> 0
					LOOP

						LV_ADDNL_INFO_BEFORE := NULL;
						LV_ADDNL_INFO_VARIABLE := NULL;
						LV_ADDNL_INFO_AFTER := NULL;


						---- POSITION AFTER VARIABLE
						LN_SPACE_POSITION := INSTR(ADDNL_INFO,' ',LN_COLON_POSITION);

						IF LN_SPACE_POSITION = 0 THEN

							---- look for punctuation at end of variable - PLUS, COMMA, HYPHEN, PERIOD, SLASH, SEMICOLON, <, =, >, ?, @

							IF SUBSTR(ADDNL_INFO,-1,1) IN (CHR(43),CHR(44),CHR(45),CHR(46),CHR(47),CHR(59),CHR(60),CHR(61),CHR(62),CHR(63),CHR(64)) THEN

								LN_SPACE_POSITION := LENGTH(ADDNL_INFO);

							ELSE
				
								LN_SPACE_POSITION := 9999;

							END IF;

						ELSE

							---- look for punctuation at end of variable - PLUS, COMMA, HYPHEN, PERIOD, SLASH, SEMICOLON, <, =, >, ?, @

							IF SUBSTR(ADDNL_INFO,LN_SPACE_POSITION - 1,1) IN (CHR(43),CHR(44),CHR(45),CHR(46),CHR(47),CHR(59),CHR(60),CHR(61),CHR(62),CHR(63),CHR(64)) THEN

								LN_SPACE_POSITION := LN_SPACE_POSITION - 1;

							END IF;						


						END IF;


						---- PART OF ADDNL_INFO UP TO VARIABLE
						LV_ADDNL_INFO_BEFORE := SUBSTR(ADDNL_INFO,1,LN_COLON_POSITION - 1);

						--- VARIABLE PART OF ADDNL_INFO
						LV_ADDNL_INFO_VARIABLE := SUBSTR(ADDNL_INFO,LN_COLON_POSITION,LN_SPACE_POSITION - LN_COLON_POSITION);
						LV_ADDNL_INFO_VARIABLE := UPPER(REPLACE(LV_ADDNL_INFO_VARIABLE,':'));

						---- PART OF ADDNL_INFO AFTER VARIABLE
						LV_ADDNL_INFO_AFTER := SUBSTR(ADDNL_INFO,LN_SPACE_POSITION);


						----- REBUILD ADDNL_INFO


						IF LV_ADDNL_INFO_BEFORE IS NOT NULL THEN

							ADDNL_INFO := LV_ADDNL_INFO_BEFORE || CHR(39) || '||' || LV_ADDNL_INFO_VARIABLE;

						ELSE

							ADDNL_INFO := LV_ADDNL_INFO_VARIABLE;
					

						END IF;


						IF LV_ADDNL_INFO_AFTER IS NOT NULL THEN

							ADDNL_INFO := ADDNL_INFO || ' ||' || CHR(39) || LV_ADDNL_INFO_AFTER;

						END IF;

				
						--- GET NEXT VARIABLE POSITION
						LN_COLON_POSITION := INSTR(ADDNL_INFO,':');


					END LOOP;


				END IF;

				---- add a trailing quote if there is no already one and the ADDNL_INFO does not end with a variable

				IF SUBSTR(ADDNL_INFO,-1) = CHR(39) OR LN_SPACE_POSITION = 9999 THEN
				
					NULL;
			
				ELSE
				
					ADDNL_INFO := ADDNL_INFO || CHR(39);


				END IF;


			ELSE


				---   build a default ADDNL_INFO if none is supplied


				ADDNL_INFO := 'NULL';


			END IF;



			sql_stmt := SQL_STMT || ',' || ADDNL_INFO || ' AS ADDNL_INFO' || CHR(10);


			-----  check the from_sql for date parms

			LV_SQL_TEMP := rec.FROM_SQL;

			IF INSTR(LV_SQL_TEMP,':START_DATE') > 0 THEN

				LV_SQL_TEMP := REPLACE(LV_SQL_TEMP,':START_DATE','TO_DATE(''' || TO_CHAR(LD_START_DATE,'MM/DD/YYYY') || ''',''MM/DD/YYYY'')');

			END IF;

			IF INSTR(LV_SQL_TEMP,':END_DATE') > 0 THEN

				LV_SQL_TEMP := REPLACE(LV_SQL_TEMP,':END_DATE','TO_DATE(''' || TO_CHAR(LD_END_DATE,'MM/DD/YYYY') || ''',''MM/DD/YYYY'')');

			END IF;

			------ build the from clause

                    
			sql_stmt :=  sql_stmt || ' ' || LV_SQL_TEMP;


	     	END IF;

        END LOOP;
        
        END;

lv_return_sql := sql_stmt;

RETURN lv_return_sql;

END convert_rule_to_sql;


---------------------------------------------------------------------------------------------------
-- Function: convert_to_single_sql
-- Description    : This is the function for turning a SQL stmt into a select of a single record
--
--  Called From:  batch_reload_single_result, batch_reload_result_group, batch_load_dq_results_single, validate_dynamic_sql
---------------------------------------------------------------------------------------------------
FUNCTION convert_to_single_sql (p_sql_stmt varchar2, p_object_id varchar2, p_daytime date, p_alt_unique_key varchar2)
RETURN VARCHAR2 IS
lv_return_sql varchar2(10000);
lv_sql_fld_1_source   varchar2(200);
lv_sql_fld_2_source   varchar2(200);
lv_sql_fld_3_source   varchar2(200);
lv_sql_fld_4_source   varchar2(200);
lv_sql_fld_5_source   varchar2(200);
sql_stmt varchar2(10000);
 
BEGIN

sql_stmt := NULL;


sql_stmt := p_sql_stmt || ' AND a.OBJECT_ID = ' || CHR(39) || p_object_id || CHR(39);


IF p_daytime is not NULL THEN

	sql_stmt := sql_stmt || ' AND a.DAYTIME = to_date(' || CHR(39) || to_char(p_daytime,'mm/dd/yyyy hh24:mi:ss') || CHR(39) || ',''mm/dd/yyyy hh24:mi:ss'')';
				
END IF;

IF p_alt_unique_key is not NULL THEN

	sql_stmt := sql_stmt || ' AND a.ALT_UNIQUE_KEY = ' || CHR(39) || p_alt_unique_key || CHR(39);
				
END IF;


lv_return_sql := sql_stmt;

RETURN lv_return_sql;

END convert_to_single_sql;

---------------------------------------------------------------------------------------------------
-- Function: convert_to_date_range_sql
-- Description    : This is the function for auto adding the from and end dates to the dynamic SQL
--
--  Called From:  batch_load_dq_results, batch_load_dq_results_hier
---------------------------------------------------------------------------------------------------
FUNCTION convert_to_date_range_sql (p_sql_stmt varchar2, p_start_date date, p_end_Date date)
RETURN VARCHAR2 IS
lv_return_sql varchar2(10000);
lv_sql_fld_1_source   varchar2(200);
lv_sql_fld_2_source   varchar2(200);
lv_sql_fld_3_source   varchar2(200);
lv_sql_fld_4_source   varchar2(200);
lv_sql_fld_5_source   varchar2(200);
sql_stmt varchar2(10000);
 
BEGIN

sql_stmt := p_sql_stmt;


IF p_start_date is not NULL THEN

	sql_stmt := sql_stmt || ' AND (a.daytime is NULL or a.DAYTIME >= to_date(' || CHR(39) || to_char(p_start_date,'mm/dd/yyyy hh24:mi:ss') || CHR(39) || ',''mm/dd/yyyy hh24:mi:ss''))';

				
END IF;

IF p_end_date is not NULL THEN

	sql_stmt := sql_stmt || ' AND (a.DAYTIME is NULL or a.DAYTIME < to_date(' || CHR(39) || to_char(p_end_date,'mm/dd/yyyy hh24:mi:ss') || CHR(39) || ',''mm/dd/yyyy hh24:mi:ss''))';
				
END IF;


lv_return_sql := sql_stmt;

RETURN lv_return_sql;

END convert_to_date_range_sql;


---------------------------------------------------------------------------------------------------
-- Function: build_object_sql
-- Description    : This is the function for creating the select of an object to get the hierarchy
--
--  Called From:  procedures batch_load_dq_results, batch_load_dq_resutls_hier, batch_load_dq_results_single, batch_reload_single_result, batch_reload_result_group
---------------------------------------------------------------------------------------------------
FUNCTION build_object_sql (p_object_type varchar2)
RETURN VARCHAR2 IS
lv_return_sql varchar2(10000);
sql_stmt varchar2(10000);
lv_record_found varchar2(1);
 
BEGIN

sql_stmt := NULL;

lv_record_found := 'N';

begin
        for rec in (SELECT OBJECT_ID_SOURCE, DAYTIME_SOURCE, END_DATE_SOURCE, OP_PU_ID_SOURCE, OP_SUB_PU_ID_SOURCE, OP_AREA_ID_SOURCE, OP_SUB_AREA_ID_SOURCE, OP_FCTY_CLASS_2_ID_SOURCE, OP_FCTY_CLASS_1_ID_SOURCE,
  	OP_WELL_HOOKUP_ID_SOURCE, CP_PU_ID_SOURCE, CP_SUB_PU_ID_SOURCE, CP_AREA_ID_SOURCE, CP_SUB_AREA_ID_SOURCE, CP_OPERATOR_ROUTE_ID_SOURCE, CP_COL_POINT_ID_SOURCE,
  	GEO_AREA_ID_SOURCE, GEO_SUB_AREA_ID_SOURCE, GEO_FIELD_ID_SOURCE, GEO_SUB_FIELD_ID_SOURCE, GROUP_REF_ID_1_SOURCE, GROUP_REF_ID_2_SOURCE, GROUP_REF_ID_3_SOURCE,
  	GROUP_REF_ID_4_SOURCE, GROUP_REF_ID_5_SOURCE, GROUP_REF_ID_6_SOURCE, GROUP_REF_ID_7_SOURCE, GROUP_REF_ID_8_SOURCE, GROUP_REF_ID_9_SOURCE, GROUP_REF_ID_10_SOURCE,
  	FROM_SQL FROM CT_DQ_HIER_DETERMINATION WHERE OBJECT_TYPE = P_OBJECT_TYPE)
	loop

		lv_record_found := 'Y';

		sql_stmt := '(select ';

		IF rec.OBJECT_ID_SOURCE is not NULL THEN

			sql_stmt := sql_stmt || rec.OBJECT_ID_SOURCE || ' as OBJECT_ID,';

		ELSE

			sql_stmt := sql_stmt || 'OBJECT_ID,';

		END IF;


		IF rec.DAYTIME_SOURCE is not NULL THEN

			sql_stmt := sql_stmt || rec.DAYTIME_SOURCE || ' as DAYTIME,';

		ELSE

			sql_stmt := sql_stmt || 'DAYTIME,';

		END IF;

		IF rec.END_DATE_SOURCE is not NULL THEN

			sql_stmt := sql_stmt || rec.END_DATE_SOURCE || ' as END_DATE,';

		ELSE

			sql_stmt := sql_stmt || 'NULL AS END_DATE,';

		END IF;

		IF rec.OP_PU_ID_SOURCE is not NULL THEN

			sql_stmt := sql_stmt || rec.OP_PU_ID_SOURCE || ' as OP_PU_ID,';

		ELSE

			sql_stmt := sql_stmt || 'NULL as OP_PU_ID,';

		END IF;

		IF rec.OP_SUB_PU_ID_SOURCE is not NULL THEN 

			sql_stmt := sql_stmt || rec.OP_SUB_PU_ID_SOURCE || ' as OP_SUB_PU_ID,';

		ELSE

			sql_stmt := sql_stmt || 'NULL as OP_SUB_PU_ID,';

		END IF;

		IF rec.OP_AREA_ID_SOURCE is not NULL THEN

			sql_stmt := sql_stmt || rec.OP_AREA_ID_SOURCE || ' as OP_AREA_ID,';

		ELSE

			sql_stmt := sql_stmt || 'NULL as OP_AREA_ID,';

		END IF;

		IF rec.OP_SUB_AREA_ID_SOURCE is not NULL THEN

			sql_stmt := sql_stmt || rec.OP_SUB_AREA_ID_SOURCE || ' as OP_SUB_AREA_ID,';

		ELSE

			sql_stmt := sql_stmt || 'NULL as OP_SUB_AREA_ID,';

		END IF;

		IF rec.OP_FCTY_CLASS_2_ID_SOURCE is not NULL THEN

			sql_stmt := sql_stmt || rec.OP_FCTY_CLASS_2_ID_SOURCE || ' as OP_FCTY_CLASS_2_ID,';

		ELSE

			sql_stmt := sql_stmt || 'NULL as OP_FCTY_CLASS_2_ID,';

		END IF;

		IF rec.OP_FCTY_CLASS_1_ID_SOURCE is not NULL THEN

			sql_stmt := sql_stmt || rec.OP_FCTY_CLASS_1_ID_SOURCE || ' as OP_FCTY_CLASS_1_ID,';

		ELSE

			sql_stmt := sql_stmt || 'NULL as OP_FCTY_CLASS_1_ID,';

		END IF;

		IF rec.OP_WELL_HOOKUP_ID_SOURCE is not NULL THEN

			sql_stmt := sql_stmt || rec.OP_WELL_HOOKUP_ID_SOURCE || ' as OP_WELL_HOOKUP_ID,';

		ELSE

			sql_stmt := sql_stmt || 'NULL as OP_WELL_HOOKUP_ID,';

		END IF;

		IF rec.CP_PU_ID_SOURCE is not NULL THEN

			sql_stmt := sql_stmt || rec.CP_PU_ID_SOURCE || ' as CP_PU_ID,';

		ELSE

			sql_stmt := sql_stmt || 'NULL as CP_PU_ID,';

		END IF;

		IF rec.CP_SUB_PU_ID_SOURCE is not NULL THEN

			sql_stmt := sql_stmt || rec.CP_SUB_PU_ID_SOURCE || ' as CP_SUB_PU_ID,';

		ELSE

			sql_stmt := sql_stmt || 'NULL as CP_SUB_PU_ID,';

		END IF;

		IF rec.CP_AREA_ID_SOURCE is not NULL THEN

			sql_stmt := sql_stmt || rec.CP_AREA_ID_SOURCE || ' as CP_AREA_ID,';

		ELSE

			sql_stmt := sql_stmt || 'NULL as CP_AREA_ID,';

		END IF;

		IF rec.CP_SUB_AREA_ID_SOURCE is not NULL THEN

			sql_stmt := sql_stmt || rec.CP_SUB_AREA_ID_SOURCE || ' as CP_SUB_AREA_ID,';

		ELSE

			sql_stmt := sql_stmt || 'NULL as CP_SUB_AREA_ID,';

		END IF;

		IF rec.CP_OPERATOR_ROUTE_ID_SOURCE is not NULL THEN 

			sql_stmt := sql_stmt || rec.CP_OPERATOR_ROUTE_ID_SOURCE || ' as CP_OPERATOR_ROUTE_ID,';

		ELSE

			sql_stmt := sql_stmt || 'NULL as CP_OPERATOR_ROUTE_ID,';

		END IF;

		IF rec.CP_COL_POINT_ID_SOURCE is not NULL THEN

			sql_stmt := sql_stmt || rec.CP_COL_POINT_ID_SOURCE || ' as CP_COL_POINT_ID,';

		ELSE

			sql_stmt := sql_stmt || 'NULL as CP_COL_POINT_ID,';

		END IF;

		IF rec.GEO_AREA_ID_SOURCE is not NULL THEN

			sql_stmt := sql_stmt || rec.GEO_AREA_ID_SOURCE || ' as GEO_AREA_ID,';

		ELSE

			sql_stmt := sql_stmt || 'NULL as GEO_AREA_ID,';

		END IF;

		IF rec.GEO_SUB_AREA_ID_SOURCE is not NULL THEN

			sql_stmt := sql_stmt || rec.GEO_SUB_AREA_ID_SOURCE || ' as GEO_SUB_AREA_ID,';

		ELSE

			sql_stmt := sql_stmt || 'NULL as GEO_SUB_AREA_ID,';

		END IF;

		IF rec.GEO_FIELD_ID_SOURCE is not NULL THEN

			sql_stmt := sql_stmt || rec.GEO_FIELD_ID_SOURCE || ' as GEO_FIELD_ID,';

		ELSE

			sql_stmt := sql_stmt || 'NULL as GEO_FIELD_ID,';

		END IF;

		IF rec.GEO_SUB_FIELD_ID_SOURCE is not NULL THEN

			sql_stmt := sql_stmt || rec.GEO_SUB_FIELD_ID_SOURCE || ' as GEO_SUB_FIELD_ID,';

		ELSE

			sql_stmt := sql_stmt || 'NULL as GEO_SUB_FIELD_ID,';

		END IF;

		IF rec.GROUP_REF_ID_1_SOURCE is not NULL THEN 

			sql_stmt := sql_stmt || rec.GROUP_REF_ID_1_SOURCE || ' as GROUP_REF_ID_1,';

		ELSE

			sql_stmt := sql_stmt || 'NULL as GROUP_REF_ID_1,';

		END IF;

		IF rec.GROUP_REF_ID_2_SOURCE is not NULL THEN

			sql_stmt := sql_stmt || rec.GROUP_REF_ID_2_SOURCE || ' as GROUP_REF_ID_2,';

		ELSE

			sql_stmt := sql_stmt || 'NULL as GROUP_REF_ID_2,';

		END IF;

		IF rec.GROUP_REF_ID_3_SOURCE is not NULL THEN

			sql_stmt := sql_stmt || rec.GROUP_REF_ID_3_SOURCE || ' as GROUP_REF_ID_3,';

		ELSE

			sql_stmt := sql_stmt || 'NULL as GROUP_REF_ID_3,';

		END IF;

		IF rec.GROUP_REF_ID_4_SOURCE is not NULL THEN

			sql_stmt := sql_stmt || rec.GROUP_REF_ID_4_SOURCE || ' as GROUP_REF_ID_4,';

		ELSE

			sql_stmt := sql_stmt || 'NULL as GROUP_REF_ID_4,';

		END IF;

		IF rec.GROUP_REF_ID_5_SOURCE is not NULL THEN

			sql_stmt := sql_stmt || rec.GROUP_REF_ID_5_SOURCE || ' as GROUP_REF_ID_5,';

		ELSE

			sql_stmt := sql_stmt || 'NULL as GROUP_REF_ID_5,';

		END IF;

		IF rec.GROUP_REF_ID_6_SOURCE is not NULL THEN

			sql_stmt := sql_stmt || rec.GROUP_REF_ID_6_SOURCE || ' as GROUP_REF_ID_6,';

		ELSE

			sql_stmt := sql_stmt || 'NULL as GROUP_REF_ID_6,';

		END IF;

		IF rec.GROUP_REF_ID_7_SOURCE is not NULL THEN 

			sql_stmt := sql_stmt || rec.GROUP_REF_ID_7_SOURCE || ' as GROUP_REF_ID_7,';

		ELSE

			sql_stmt := sql_stmt || 'NULL as GROUP_REF_ID_7,';

		END IF;

		IF rec.GROUP_REF_ID_8_SOURCE is not NULL THEN

			sql_stmt := sql_stmt || rec.GROUP_REF_ID_8_SOURCE || ' as GROUP_REF_ID_8,';

		ELSE

			sql_stmt := sql_stmt || 'NULL as GROUP_REF_ID_8,';

		END IF;

		IF rec.GROUP_REF_ID_9_SOURCE is not NULL THEN

			sql_stmt := sql_stmt || rec.GROUP_REF_ID_9_SOURCE || ' as GROUP_REF_ID_9,';

		ELSE

			sql_stmt := sql_stmt || 'NULL as GROUP_REF_ID_9,';

		END IF;

		IF rec.GROUP_REF_ID_10_SOURCE is not NULL THEN

			sql_stmt := sql_stmt || rec.GROUP_REF_ID_10_SOURCE || ' as GROUP_REF_ID_10 ';

		ELSE

			sql_stmt := sql_stmt || 'NULL as GROUP_REF_ID_10 ';

		END IF;


		sql_stmt := sql_stmt || rec.FROM_SQL || ') O';

		
	end loop;

	END;

IF lv_record_found = 'N' THEN

	RAISE_APPLICATION_ERROR(-20020,'No Object Determination SQL Found');

END IF;



lv_return_sql := sql_stmt;

RETURN lv_return_sql;

END build_object_sql;


---------------------------------------------------------------------------------------------------
-- Function: combine_with_object_sql
-- Description    : This is the function for joining the rule sql with the object sql
--
--  Called From:  procedures batch_load_dq_results, batch_load_dq_resutls_hier, batch_load_dq_results_single, batch_reload_single_result, batch_reload_result_group
---------------------------------------------------------------------------------------------------
FUNCTION combine_with_object_sql (p_sql_stmt varchar2, p_object_sql_stmt varchar2, p_nav_class_name varchar2, p_nav_object_id varchar2, p_group_type varchar2)
RETURN VARCHAR2 IS
lv_return_sql varchar2(10000);
sql_stmt varchar2(10000);
sql_stmt_object_id varchar2(5000);
lv_sql_fld_1_source   varchar2(200);
lv_sql_fld_2_source   varchar2(200);
lv_sql_fld_3_source   varchar2(200);
lv_sql_fld_4_source   varchar2(200);
lv_sql_fld_5_source   varchar2(200);
 
BEGIN

sql_stmt := NULL;

---- append sql stmt with where clause to limit object id, daytime, and alt key

sql_stmt := 'select a.object_id, a.daytime, a.alt_unique_key, ';


--- rename generic sql attributes if configured on class tables
lv_sql_fld_1_source := GET_SQL_ATTRIBUTE_NAME('SQL_FLD_1'); 
lv_sql_fld_2_source := GET_SQL_ATTRIBUTE_NAME('SQL_FLD_2'); 
lv_sql_fld_3_source := GET_SQL_ATTRIBUTE_NAME('SQL_FLD_3'); 
lv_sql_fld_4_source := GET_SQL_ATTRIBUTE_NAME('SQL_FLD_4'); 
lv_sql_fld_5_source := GET_SQL_ATTRIBUTE_NAME('SQL_FLD_5'); 

IF lv_sql_fld_1_source is not NULL OR lv_sql_fld_2_source is not NULL OR lv_sql_fld_3_source is not NULL OR lv_sql_fld_4_source is not NULL OR lv_sql_fld_5_source is not NULL
THEN
	sql_stmt := sql_stmt || 'a.' || NVL(lv_sql_fld_1_source,'SQL_FLD_1') || ', ';
END IF;

--- rename generic sql attributes if configured on class tables

IF lv_sql_fld_2_source is not NULL OR lv_sql_fld_3_source is not NULL OR lv_sql_fld_4_source is not NULL OR lv_sql_fld_5_source is not NULL
THEN
	sql_stmt := sql_stmt || 'a.' || NVL(lv_sql_fld_2_source,'SQL_FLD_2') || ', ';
END IF;

--- rename generic sql attributes if configured on class tables

IF lv_sql_fld_3_source is not NULL OR lv_sql_fld_4_source is not NULL OR lv_sql_fld_5_source is not NULL
THEN
	sql_stmt := sql_stmt || 'a.' || NVL(lv_sql_fld_3_source,'SQL_FLD_3') || ', ';
END IF;

--- rename generic sql attributes if configured on class tables

IF lv_sql_fld_4_source is not NULL OR lv_sql_fld_5_source is not NULL
THEN 
	sql_stmt := sql_stmt || 'a.' || NVL(lv_sql_fld_4_source,'SQL_FLD_4') || ', ';
END IF;

--- rename generic sql attributes if configured on class tables

IF lv_sql_fld_5_source is not NULL 
THEN
	sql_stmt := sql_stmt || 'a.' || NVL(lv_sql_fld_5_source,'SQL_FLD_5') || ', ';
END IF;


sql_stmt := sql_stmt || 'a.ADDNL_INFO,';

sql_stmt := sql_stmt || 'OP_PU_ID,OP_SUB_PU_ID,OP_AREA_ID,OP_SUB_AREA_ID,OP_FCTY_CLASS_2_ID,OP_FCTY_CLASS_1_ID,OP_WELL_HOOKUP_ID,';

sql_stmt := sql_stmt || 'CP_PU_ID,CP_SUB_PU_ID,CP_AREA_ID,CP_SUB_AREA_ID,CP_OPERATOR_ROUTE_ID,CP_COL_POINT_ID,';

sql_stmt := sql_stmt || 'GEO_AREA_ID,GEO_SUB_AREA_ID,GEO_FIELD_ID,GEO_SUB_FIELD_ID,GROUP_REF_ID_1,GROUP_REF_ID_2,GROUP_REF_ID_3,GROUP_REF_ID_4,GROUP_REF_ID_5,GROUP_REF_ID_6,GROUP_REF_ID_7,GROUP_REF_ID_8,GROUP_REF_ID_9,GROUP_REF_ID_10';

sql_stmt := sql_stmt || ' from ( ' || p_sql_stmt || ') a';


IF p_object_sql_stmt is not NULL THEN

	sql_stmt := sql_stmt || ',' || p_object_sql_stmt || ' where a.object_id = o.object_id and o.daytime <= nvl(a.daytime,sysdate) and nvl(o.end_date, to_date(''12/31/9999'',''mm/dd/yyyy'')) > nvl(a.daytime,sysdate)';

END IF;

IF p_nav_object_id is not NULL THEN

	IF p_group_type = 'operational' THEN

		IF p_nav_class_name = 'PRODUCTIONUNIT' THEN

			sql_stmt := sql_stmt || ' and OP_PU_ID =' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

		ELSIF p_nav_class_name = 'PROD_SUB_UNIT' THEN

			sql_stmt := sql_stmt || ' and OP_SUB_PU_ID =' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

		ELSIF p_nav_class_name = 'AREA' THEN

			sql_stmt := sql_stmt || ' and OP_AREA_ID =' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

		ELSIF p_nav_class_name = 'SUB_AREA' THEN

			sql_stmt := sql_stmt || ' and OP_SUB_AREA_ID =' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

		ELSIF p_nav_class_name = 'FCTY_CLASS_2' THEN

			sql_stmt := sql_stmt || ' and OP_FCTY_CLASS_2_ID =' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

		ELSIF p_nav_class_name = 'FCTY_CLASS_1' THEN

			sql_stmt := sql_stmt || ' and OP_FCTY_CLASS_1_ID =' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);
		
		END IF;

	ELSIF p_group_type = 'collection_point' THEN

		IF p_nav_class_name = 'PRODUCTIONUNIT' THEN

			sql_stmt := sql_stmt || ' and CP_PU_ID =' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

		ELSIF p_nav_class_name = 'PROD_SUB_UNIT' THEN

			sql_stmt := sql_stmt || ' and CP_SUB_PU_ID =' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

		ELSIF p_nav_class_name = 'AREA' THEN

			sql_stmt := sql_stmt || ' and CP_AREA_ID =' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

		ELSIF p_nav_class_name = 'SUB_AREA' THEN

			sql_stmt := sql_stmt || ' and CP_SUB_AREA_ID =' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

		ELSIF p_nav_class_name = 'OPERATOR_ROUTE' THEN

			sql_stmt := sql_stmt || ' and CP_OPERATOR_ROUTE_ID =' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);

		ELSIF p_nav_class_name = 'COLLECTION_POINT' THEN

			sql_stmt := sql_stmt || ' and CP_COL_POINT_ID =' || CHR(39) || p_NAV_OBJECT_ID || CHR(39);
		
		END IF;

	END IF;


END IF;


lv_return_sql := sql_stmt;

RETURN lv_return_sql;

END combine_with_object_sql;

---------------------------------------------------------------------------------------------------
-- Procedure: validate_dynamic_sql
-- Description    : This is the procedure to execute the SQL stmt to confirm it is valid SQL
--
--  Called From:  tv_ct_dq_rule as part of trigger action
---------------------------------------------------------------------------------------------------
PROCEDURE validate_dynamic_sql(p_rule_id integer)
IS

sql_stmt varchar2(10000);
object_sql_stmt varchar2(5000);

LV_OBJECT_ID    VARCHAR2(32);
LD_DAYTIME      DATE;
LV_ALT_UNIQUE_KEY     VARCHAR2(200);
LV_SQL_FLD_1     VARCHAR2(200);
LV_SQL_FLD_2     VARCHAR2(200);
LV_SQL_FLD_3     VARCHAR2(200);
LV_SQL_FLD_4     VARCHAR2(200);
LV_SQL_FLD_5     VARCHAR2(200);
LV_ADDNL_INFO VARCHAR2(1000);

lv_sql_fld_1_source   varchar2(200);
lv_sql_fld_2_source   varchar2(200);
lv_sql_fld_3_source   varchar2(200);
lv_sql_fld_4_source   varchar2(200);
lv_sql_fld_5_source   varchar2(200);

LV_OP_PU_ID VARCHAR2(32); 
LV_OP_SUB_PU_ID VARCHAR2(32); 
LV_OP_AREA_ID VARCHAR2(32);
LV_OP_SUB_AREA_ID VARCHAR2(32); 
LV_OP_FCTY_CLASS_2_ID VARCHAR2(32);
LV_OP_FCTY_CLASS_1_ID VARCHAR2(32);
LV_OP_WELL_HOOKUP_ID VARCHAR2(32);
LV_CP_PU_ID VARCHAR2(32);
LV_CP_SUB_PU_ID VARCHAR2(32);
LV_CP_AREA_ID VARCHAR2(32);
LV_CP_SUB_AREA_ID VARCHAR2(32);
LV_CP_OPERATOR_ROUTE_ID VARCHAR2(32);
LV_CP_COL_POINT_ID VARCHAR2(32);
LV_GEO_AREA_ID VARCHAR2(32);
LV_GEO_SUB_AREA_ID VARCHAR2(32);
LV_GEO_FIELD_ID VARCHAR2(32);
LV_GEO_SUB_FIELD_ID VARCHAR2(32);
LV_GROUP_REF_ID_1 VARCHAR2(32);
LV_GROUP_REF_ID_2 VARCHAR2(32);
LV_GROUP_REF_ID_3 VARCHAR2(32);
LV_GROUP_REF_ID_4 VARCHAR2(32);
LV_GROUP_REF_ID_5 VARCHAR2(32);
LV_GROUP_REF_ID_6 VARCHAR2(32);
LV_GROUP_REF_ID_7 VARCHAR2(32);
LV_GROUP_REF_ID_8 VARCHAR2(32);
LV_GROUP_REF_ID_9 VARCHAR2(32);
LV_GROUP_REF_ID_10 VARCHAR2(32);
      
BEGIN

sql_stmt := NULL;


sql_stmt := convert_rule_to_sql (p_rule_id, sysdate + 1, sysdate);

--- get the object sql

            
object_sql_stmt := NULL;
object_sql_stmt := build_object_sql ('WELL');

--- add join to object table for hierarchy

           
sql_stmt := combine_with_object_sql (sql_stmt, object_sql_stmt,null, null, null);


sql_stmt := convert_to_single_sql (sql_stmt, '123', sysdate, '123');

lv_sql_fld_1_source := NULL; 
lv_sql_fld_2_source := NULL; 
lv_sql_fld_3_source := NULL; 
lv_sql_fld_4_source := NULL; 
lv_sql_fld_5_source := NULL; 

lv_sql_fld_1_source := GET_SQL_ATTRIBUTE_NAME('SQL_FLD_1'); 
lv_sql_fld_2_source := GET_SQL_ATTRIBUTE_NAME('SQL_FLD_2'); 
lv_sql_fld_3_source := GET_SQL_ATTRIBUTE_NAME('SQL_FLD_3'); 
lv_sql_fld_4_source := GET_SQL_ATTRIBUTE_NAME('SQL_FLD_4'); 
lv_sql_fld_5_source := GET_SQL_ATTRIBUTE_NAME('SQL_FLD_5'); 

IF lv_sql_fld_5_source is NOT NULL
THEN
	BEGIN

	EXECUTE IMMEDIATE sql_stmt into lv_object_id, ld_daytime, lv_alt_unique_key, lv_SQL_FLD_1, lv_SQL_FLD_2, lv_SQL_FLD_3, lv_SQL_FLD_4, lv_SQL_FLD_5, lv_ADDNL_INFO, LV_OP_PU_ID, LV_OP_SUB_PU_ID, LV_OP_AREA_ID, LV_OP_SUB_AREA_ID, LV_OP_FCTY_CLASS_2_ID, LV_OP_FCTY_CLASS_1_ID,LV_OP_WELL_HOOKUP_ID, LV_CP_PU_ID, LV_CP_SUB_PU_ID, LV_CP_AREA_ID, LV_CP_SUB_AREA_ID, LV_CP_OPERATOR_ROUTE_ID, LV_CP_COL_POINT_ID,LV_GEO_AREA_ID, LV_GEO_SUB_AREA_ID, LV_GEO_FIELD_ID, LV_GEO_SUB_FIELD_ID, LV_GROUP_REF_ID_1, LV_GROUP_REF_ID_2, LV_GROUP_REF_ID_3, LV_GROUP_REF_ID_4, LV_GROUP_REF_ID_5, LV_GROUP_REF_ID_6, LV_GROUP_REF_ID_7, LV_GROUP_REF_ID_8, LV_GROUP_REF_ID_9, LV_GROUP_REF_ID_10;

	EXCEPTION
 		WHEN NO_DATA_FOUND THEN NULL;
		WHEN OTHERS THEN
        		BEGIN
        		IF SQLCODE = -904 THEN        
            			RAISE_APPLICATION_ERROR(-20916,'Invalid column name in dynamic SQL');
        		ELSIF SQLCODE = -907 THEN        
            			RAISE_APPLICATION_ERROR(-20922,'Missing right parenthesis in dynamic SQL');
        		ELSIF SQLCODE = -918 THEN
            			RAISE_APPLICATION_ERROR(-20917,'Column ambiguously defined in dynamic SQL');
        		ELSIF SQLCODE = -923 THEN        
            			RAISE_APPLICATION_ERROR(-20918,'FROM keyword not found where expected in dynamic SQL');
        		ELSIF SQLCODE = -933 THEN        
            			RAISE_APPLICATION_ERROR(-20919,'Dynamic SQL not properly ended');
        		ELSIF SQLCODE = -942 THEN        
            			RAISE_APPLICATION_ERROR(-20920,'Invalid table name in dynamic SQL');
        		ELSIF SQLCODE = -979 THEN        
            			RAISE_APPLICATION_ERROR(-20921,'Not a Group By expression in dynamic SQL');
        		ELSE
  		    		RAISE_APPLICATION_ERROR(-20915,'Dynamic SQL is Invalid.  Returns SQLCODE = ' || SQLCODE);
        		END IF;
        		END;

	END;

ELSIF lv_sql_fld_4_source is NOT NULL
THEN

	BEGIN

	EXECUTE IMMEDIATE sql_stmt into lv_object_id, ld_daytime, lv_alt_unique_key, lv_SQL_FLD_1, lv_SQL_FLD_2, lv_SQL_FLD_3, lv_SQL_FLD_4, lv_ADDNL_INFO, LV_OP_PU_ID, LV_OP_SUB_PU_ID, LV_OP_AREA_ID, LV_OP_SUB_AREA_ID, LV_OP_FCTY_CLASS_2_ID, LV_OP_FCTY_CLASS_1_ID,LV_OP_WELL_HOOKUP_ID, LV_CP_PU_ID, LV_CP_SUB_PU_ID, LV_CP_AREA_ID, LV_CP_SUB_AREA_ID, LV_CP_OPERATOR_ROUTE_ID, LV_CP_COL_POINT_ID,LV_GEO_AREA_ID, LV_GEO_SUB_AREA_ID, LV_GEO_FIELD_ID, LV_GEO_SUB_FIELD_ID, LV_GROUP_REF_ID_1, LV_GROUP_REF_ID_2, LV_GROUP_REF_ID_3, LV_GROUP_REF_ID_4, LV_GROUP_REF_ID_5, LV_GROUP_REF_ID_6, LV_GROUP_REF_ID_7, LV_GROUP_REF_ID_8, LV_GROUP_REF_ID_9, LV_GROUP_REF_ID_10;

	EXCEPTION
 		WHEN NO_DATA_FOUND THEN NULL;
		WHEN OTHERS THEN
        		BEGIN
        		IF SQLCODE = -904 THEN        
            			RAISE_APPLICATION_ERROR(-20916,'Invalid column name in dynamic SQL');
        		ELSIF SQLCODE = -907 THEN        
            			RAISE_APPLICATION_ERROR(-20922,'Missing right parenthesis in dynamic SQL');
        		ELSIF SQLCODE = -918 THEN
            			RAISE_APPLICATION_ERROR(-20917,'Column ambiguously defined in dynamic SQL');
        		ELSIF SQLCODE = -923 THEN        
            			RAISE_APPLICATION_ERROR(-20918,'FROM keyword not found where expected in dynamic SQL');
        		ELSIF SQLCODE = -933 THEN        
            			RAISE_APPLICATION_ERROR(-20919,'Dynamic SQL not properly ended');
        		ELSIF SQLCODE = -942 THEN        
            			RAISE_APPLICATION_ERROR(-20920,'Invalid table name in dynamic SQL');
        		ELSIF SQLCODE = -979 THEN        
            			RAISE_APPLICATION_ERROR(-20921,'Not a Group By expression in dynamic SQL');
        		ELSE
  		    		RAISE_APPLICATION_ERROR(-20915,'Dynamic SQL is Invalid.  Returns SQLCODE = ' || SQLCODE);
        		END IF;
        		END;

	END;


ELSIF lv_sql_fld_3_source is NOT NULL 
THEN

	BEGIN

	EXECUTE IMMEDIATE sql_stmt into lv_object_id, ld_daytime, lv_alt_unique_key, lv_SQL_FLD_1, lv_SQL_FLD_2, lv_SQL_FLD_3, lv_ADDNL_INFO, LV_OP_PU_ID, LV_OP_SUB_PU_ID, LV_OP_AREA_ID, LV_OP_SUB_AREA_ID, LV_OP_FCTY_CLASS_2_ID, LV_OP_FCTY_CLASS_1_ID,LV_OP_WELL_HOOKUP_ID, LV_CP_PU_ID, LV_CP_SUB_PU_ID, LV_CP_AREA_ID, LV_CP_SUB_AREA_ID, LV_CP_OPERATOR_ROUTE_ID, LV_CP_COL_POINT_ID,LV_GEO_AREA_ID, LV_GEO_SUB_AREA_ID, LV_GEO_FIELD_ID, LV_GEO_SUB_FIELD_ID, LV_GROUP_REF_ID_1, LV_GROUP_REF_ID_2, LV_GROUP_REF_ID_3, LV_GROUP_REF_ID_4, LV_GROUP_REF_ID_5, LV_GROUP_REF_ID_6, LV_GROUP_REF_ID_7, LV_GROUP_REF_ID_8, LV_GROUP_REF_ID_9, LV_GROUP_REF_ID_10;

	EXCEPTION
 		WHEN NO_DATA_FOUND THEN NULL;
		WHEN OTHERS THEN
        		BEGIN
        		IF SQLCODE = -904 THEN        
            			RAISE_APPLICATION_ERROR(-20916,'Invalid column name in dynamic SQL');
        		ELSIF SQLCODE = -907 THEN        
            			RAISE_APPLICATION_ERROR(-20922,'Missing right parenthesis in dynamic SQL');
        		ELSIF SQLCODE = -918 THEN
            			RAISE_APPLICATION_ERROR(-20917,'Column ambiguously defined in dynamic SQL');
        		ELSIF SQLCODE = -923 THEN        
            			RAISE_APPLICATION_ERROR(-20918,'FROM keyword not found where expected in dynamic SQL');
        		ELSIF SQLCODE = -933 THEN        
            			RAISE_APPLICATION_ERROR(-20919,'Dynamic SQL not properly ended');
        		ELSIF SQLCODE = -942 THEN        
            			RAISE_APPLICATION_ERROR(-20920,'Invalid table name in dynamic SQL');
        		ELSIF SQLCODE = -979 THEN        
            			RAISE_APPLICATION_ERROR(-20921,'Not a Group By expression in dynamic SQL');
        		ELSE
  		    		RAISE_APPLICATION_ERROR(-20915,'Dynamic SQL is Invalid.  Returns SQLCODE = ' || SQLCODE);
        		END IF;
        		END;

	END;

ELSIF lv_sql_fld_2_source is NOT NULL
THEN

	BEGIN

	EXECUTE IMMEDIATE sql_stmt into lv_object_id, ld_daytime, lv_alt_unique_key, lv_SQL_FLD_1, lv_SQL_FLD_2, lv_ADDNL_INFO, LV_OP_PU_ID, LV_OP_SUB_PU_ID, LV_OP_AREA_ID, LV_OP_SUB_AREA_ID, LV_OP_FCTY_CLASS_2_ID, LV_OP_FCTY_CLASS_1_ID,LV_OP_WELL_HOOKUP_ID, LV_CP_PU_ID, LV_CP_SUB_PU_ID, LV_CP_AREA_ID, LV_CP_SUB_AREA_ID, LV_CP_OPERATOR_ROUTE_ID, LV_CP_COL_POINT_ID,LV_GEO_AREA_ID, LV_GEO_SUB_AREA_ID, LV_GEO_FIELD_ID, LV_GEO_SUB_FIELD_ID, LV_GROUP_REF_ID_1, LV_GROUP_REF_ID_2, LV_GROUP_REF_ID_3, LV_GROUP_REF_ID_4, LV_GROUP_REF_ID_5, LV_GROUP_REF_ID_6, LV_GROUP_REF_ID_7, LV_GROUP_REF_ID_8, LV_GROUP_REF_ID_9, LV_GROUP_REF_ID_10;

	EXCEPTION
 		WHEN NO_DATA_FOUND THEN NULL;
		WHEN OTHERS THEN
        		BEGIN
        		IF SQLCODE = -904 THEN        
            			RAISE_APPLICATION_ERROR(-20916,'Invalid column name in dynamic SQL');
        		ELSIF SQLCODE = -907 THEN        
            			RAISE_APPLICATION_ERROR(-20922,'Missing right parenthesis in dynamic SQL');
        		ELSIF SQLCODE = -918 THEN
            			RAISE_APPLICATION_ERROR(-20917,'Column ambiguously defined in dynamic SQL');
        		ELSIF SQLCODE = -923 THEN        
            			RAISE_APPLICATION_ERROR(-20918,'FROM keyword not found where expected in dynamic SQL');
        		ELSIF SQLCODE = -933 THEN        
            			RAISE_APPLICATION_ERROR(-20919,'Dynamic SQL not properly ended');
        		ELSIF SQLCODE = -942 THEN        
            			RAISE_APPLICATION_ERROR(-20920,'Invalid table name in dynamic SQL');
        		ELSIF SQLCODE = -979 THEN        
            			RAISE_APPLICATION_ERROR(-20921,'Not a Group By expression in dynamic SQL');
        		ELSE
  		    		RAISE_APPLICATION_ERROR(-20915,'Dynamic SQL is Invalid.  Returns SQLCODE = ' || SQLCODE);
        		END IF;
        		END;

	END;

ELSIF lv_sql_fld_1_source is NOT NULL THEN

	BEGIN

	EXECUTE IMMEDIATE sql_stmt into lv_object_id, ld_daytime, lv_alt_unique_key, lv_SQL_FLD_1, lv_ADDNL_INFO, LV_OP_PU_ID, LV_OP_SUB_PU_ID, LV_OP_AREA_ID, LV_OP_SUB_AREA_ID, LV_OP_FCTY_CLASS_2_ID, LV_OP_FCTY_CLASS_1_ID,LV_OP_WELL_HOOKUP_ID, LV_CP_PU_ID, LV_CP_SUB_PU_ID, LV_CP_AREA_ID, LV_CP_SUB_AREA_ID, LV_CP_OPERATOR_ROUTE_ID, LV_CP_COL_POINT_ID,LV_GEO_AREA_ID, LV_GEO_SUB_AREA_ID, LV_GEO_FIELD_ID, LV_GEO_SUB_FIELD_ID, LV_GROUP_REF_ID_1, LV_GROUP_REF_ID_2, LV_GROUP_REF_ID_3, LV_GROUP_REF_ID_4, LV_GROUP_REF_ID_5, LV_GROUP_REF_ID_6, LV_GROUP_REF_ID_7, LV_GROUP_REF_ID_8, LV_GROUP_REF_ID_9, LV_GROUP_REF_ID_10;

	EXCEPTION
 		WHEN NO_DATA_FOUND THEN NULL;
		WHEN OTHERS THEN
        		BEGIN
        		IF SQLCODE = -904 THEN        
            			RAISE_APPLICATION_ERROR(-20916,'Invalid column name in dynamic SQL');
        		ELSIF SQLCODE = -907 THEN        
            			RAISE_APPLICATION_ERROR(-20922,'Missing right parenthesis in dynamic SQL');
        		ELSIF SQLCODE = -918 THEN
            			RAISE_APPLICATION_ERROR(-20917,'Column ambiguously defined in dynamic SQL');
        		ELSIF SQLCODE = -923 THEN        
            			RAISE_APPLICATION_ERROR(-20918,'FROM keyword not found where expected in dynamic SQL');
        		ELSIF SQLCODE = -933 THEN        
            			RAISE_APPLICATION_ERROR(-20919,'Dynamic SQL not properly ended');
        		ELSIF SQLCODE = -942 THEN        
            			RAISE_APPLICATION_ERROR(-20920,'Invalid table name in dynamic SQL');
        		ELSIF SQLCODE = -979 THEN        
            			RAISE_APPLICATION_ERROR(-20921,'Not a Group By expression in dynamic SQL');
        		ELSE
  		    		RAISE_APPLICATION_ERROR(-20915,'Dynamic SQL is Invalid.  Returns SQLCODE = ' || SQLCODE);
        		END IF;
        		END;

	END;
ELSE

	BEGIN

	EXECUTE IMMEDIATE sql_stmt into lv_object_id, ld_daytime, lv_alt_unique_key, lv_ADDNL_INFO, LV_OP_PU_ID, LV_OP_SUB_PU_ID, LV_OP_AREA_ID, LV_OP_SUB_AREA_ID, LV_OP_FCTY_CLASS_2_ID, LV_OP_FCTY_CLASS_1_ID,LV_OP_WELL_HOOKUP_ID, LV_CP_PU_ID, LV_CP_SUB_PU_ID, LV_CP_AREA_ID, LV_CP_SUB_AREA_ID, LV_CP_OPERATOR_ROUTE_ID, LV_CP_COL_POINT_ID,LV_GEO_AREA_ID, LV_GEO_SUB_AREA_ID, LV_GEO_FIELD_ID, LV_GEO_SUB_FIELD_ID, LV_GROUP_REF_ID_1, LV_GROUP_REF_ID_2, LV_GROUP_REF_ID_3, LV_GROUP_REF_ID_4, LV_GROUP_REF_ID_5, LV_GROUP_REF_ID_6, LV_GROUP_REF_ID_7, LV_GROUP_REF_ID_8, LV_GROUP_REF_ID_9, LV_GROUP_REF_ID_10;

	EXCEPTION
 		WHEN NO_DATA_FOUND THEN NULL;
		WHEN OTHERS THEN
        		BEGIN
        		IF SQLCODE = -904 THEN        
            			RAISE_APPLICATION_ERROR(-20916,'Invalid column name in dynamic SQL');
        		ELSIF SQLCODE = -907 THEN        
            			RAISE_APPLICATION_ERROR(-20922,'Missing right parenthesis in dynamic SQL');
        		ELSIF SQLCODE = -918 THEN
            			RAISE_APPLICATION_ERROR(-20917,'Column ambiguously defined in dynamic SQL');
        		ELSIF SQLCODE = -923 THEN        
            			RAISE_APPLICATION_ERROR(-20918,'FROM keyword not found where expected in dynamic SQL');
        		ELSIF SQLCODE = -933 THEN        
            			RAISE_APPLICATION_ERROR(-20919,'Dynamic SQL not properly ended');
        		ELSIF SQLCODE = -942 THEN        
            			RAISE_APPLICATION_ERROR(-20920,'Invalid table name in dynamic SQL');
        		ELSIF SQLCODE = -979 THEN        
            			RAISE_APPLICATION_ERROR(-20921,'Not a Group By expression in dynamic SQL');
        		ELSE
  		    		RAISE_APPLICATION_ERROR(-20915,'Dynamic SQL is Invalid.  Returns SQLCODE = ' || SQLCODE);
        		END IF;
        		END;

	END;

END IF;


end validate_dynamic_sql;


---------------------------------------------------------------------------------------------------
-- Function: get_date_from_date_source
-- Description    : This is the function to execute the logic in the From or End Date source
--                   in order to show the current values on the rule group screen
--  Called From:  tv_ct_dq_rule_group
---------------------------------------------------------------------------------------------------
FUNCTION get_date_from_date_source (
        p_date_source varchar2)
RETURN date IS
ld_date date;
sql_stmt varchar2(1000);

 
BEGIN

sql_stmt := NULL;
ld_date := NULL;

IF p_date_source is not NULL THEN

	BEGIN
	sql_stmt := 'select ' || p_date_source || ' from dual';
	EXECUTE IMMEDIATE sql_stmt into ld_Date;
	EXCEPTION
	WHEN OTHERS THEN NULL;

	END;

END IF;

RETURN ld_date;

END get_date_from_date_source;

---------------------------------------------------------------------------------------------------
-- Procedure: validate_date_source
-- Description    : This is the procedure to execute the logic in the From or End Date source
--                   in order to validate it is not in error
--  Called From:  tv_ct_dq_rule_group as part of trigger action
---------------------------------------------------------------------------------------------------
PROCEDURE validate_date_source(p_date_source varchar2)
IS

ld_date date;

BEGIN

ld_date := NULL;

IF p_date_source is not NULL THEN

	ld_date := get_date_from_date_source(p_date_source);

	IF ld_date is NULL THEN 

		RAISE_APPLICATION_ERROR(-20914,'Date source is Invalid'); 

	END IF;


END IF;


end validate_date_source;


---------------------------------------------------------------------------------------------------
-- Procedure: Execute_sql_stmt
-- Description    : This is the procedure to actually execute the dynamic SQL, determine the hierarchy
--  Called From:  procedures: batch_load_dq_results, batch_load_dq_results_hier, batch_load_dq_single, batch_reload_single_result, batch_reload_result_group
---------------------------------------------------------------------------------------------------
PROCEDURE Execute_sql_stmt(p_run_id integer, p_run_date date, p_sql_stmt varchar2, p_rule_id integer, p_rule_group_id integer, p_user varchar2)
IS

TYPE DQCURTYP IS ref cursor;
DQ_CV DQCURTYP;

sql_stmt varchar2(10000);
      
LV_OBJECT_ID    VARCHAR2(32);
LV_OBJECT_TYPE         VARCHAR2(32);
LD_DAYTIME      DATE;
LV_ALT_UNIQUE_KEY     VARCHAR2(200);
LV_SQL_FLD_1     VARCHAR2(200);
LV_SQL_FLD_2     VARCHAR2(200);
LV_SQL_FLD_3     VARCHAR2(200);
LV_SQL_FLD_4     VARCHAR2(200);
LV_SQL_FLD_5     VARCHAR2(200);
LV_ADDNL_INFO VARCHAR2(1000);

LV_OP_PU_ID VARCHAR2(32); 
LV_OP_SUB_PU_ID VARCHAR2(32); 
LV_OP_AREA_ID VARCHAR2(32);
LV_OP_SUB_AREA_ID VARCHAR2(32); 
LV_OP_FCTY_CLASS_2_ID VARCHAR2(32);
LV_OP_FCTY_CLASS_1_ID VARCHAR2(32);
LV_OP_WELL_HOOKUP_ID VARCHAR2(32);
LV_CP_PU_ID VARCHAR2(32);
LV_CP_SUB_PU_ID VARCHAR2(32);
LV_CP_AREA_ID VARCHAR2(32);
LV_CP_SUB_AREA_ID VARCHAR2(32);
LV_CP_OPERATOR_ROUTE_ID VARCHAR2(32);
LV_CP_COL_POINT_ID VARCHAR2(32);
LV_GEO_AREA_ID VARCHAR2(32);
LV_GEO_SUB_AREA_ID VARCHAR2(32);
LV_GEO_FIELD_ID VARCHAR2(32);
LV_GEO_SUB_FIELD_ID VARCHAR2(32);
LV_GROUP_REF_ID_1 VARCHAR2(32);
LV_GROUP_REF_ID_2 VARCHAR2(32);
LV_GROUP_REF_ID_3 VARCHAR2(32);
LV_GROUP_REF_ID_4 VARCHAR2(32);
LV_GROUP_REF_ID_5 VARCHAR2(32);
LV_GROUP_REF_ID_6 VARCHAR2(32);
LV_GROUP_REF_ID_7 VARCHAR2(32);
LV_GROUP_REF_ID_8 VARCHAR2(32);
LV_GROUP_REF_ID_9 VARCHAR2(32);
LV_GROUP_REF_ID_10 VARCHAR2(32);

lv_logging_level varchar2(32);
      
ld_rule_started_date DATE;

li_total_error_count integer;
li_new_error_count integer;
li_old_error_count integer;

lv_log_object_id  VARCHAR2(32);
ln_max_rule_results NUMBER;
ln_max_rule_duration NUMBER;

    
BEGIN

ld_rule_started_date := sysdate;
ln_max_rule_results := nvl(ec_ctrl_system_attribute.ATTRIBUTE_VALUE(sysdate, 'CT_DQ_MAX_RULE_RESULTS','<='),2000);
ln_max_rule_duration := nvl(ec_ctrl_system_attribute.ATTRIBUTE_VALUE(sysdate, 'CT_DQ_MAX_RULE_DURATION','<='),10);
                    
IF p_sql_stmt is not NULL THEN
                 
	li_total_error_count := 0;
	li_new_error_count := 0;
	li_old_error_count := 0;

	lv_object_id := NULL;
	ld_daytime := NULL;
	lv_alt_unique_key := NULL;

	LV_SQL_FLD_1 := NULL;
	LV_SQL_FLD_2 := NULL;	
	LV_SQL_FLD_3 := NULL;	
	LV_SQL_FLD_4 := NULL;	
	LV_SQL_FLD_5 := NULL;	

	OPEN DQ_cv FOR p_sql_stmt;

	IF GET_SQL_ATTRIBUTE_NAME('SQL_FLD_5') is NOT NULL THEN
   
	   LOOP
            
        	FETCH DQ_CV INTO LV_OBJECT_ID, LD_DAYTIME, LV_ALT_UNIQUE_KEY, LV_SQL_FLD_1, LV_SQL_FLD_2, LV_SQL_FLD_3, LV_SQL_FLD_4, LV_SQL_FLD_5, LV_ADDNL_INFO, LV_OP_PU_ID, LV_OP_SUB_PU_ID, LV_OP_AREA_ID, LV_OP_SUB_AREA_ID, LV_OP_FCTY_CLASS_2_ID, LV_OP_FCTY_CLASS_1_ID,LV_OP_WELL_HOOKUP_ID, LV_CP_PU_ID, LV_CP_SUB_PU_ID, LV_CP_AREA_ID, LV_CP_SUB_AREA_ID, LV_CP_OPERATOR_ROUTE_ID, LV_CP_COL_POINT_ID,LV_GEO_AREA_ID, LV_GEO_SUB_AREA_ID, LV_GEO_FIELD_ID, LV_GEO_SUB_FIELD_ID, LV_GROUP_REF_ID_1, LV_GROUP_REF_ID_2, LV_GROUP_REF_ID_3, LV_GROUP_REF_ID_4, LV_GROUP_REF_ID_5, LV_GROUP_REF_ID_6, LV_GROUP_REF_ID_7, LV_GROUP_REF_ID_8, LV_GROUP_REF_ID_9, LV_GROUP_REF_ID_10;
                 
                EXIT WHEN DQ_cv%NOTFOUND;

		li_total_error_count := li_total_error_count + 1;

		IF li_total_error_count > ln_max_rule_results THEN
		
			RAISE_APPLICATION_ERROR(-20029,'Max rule results of ' || ln_max_rule_results || ' reached.');

		END IF;

		IF (sysdate - ld_rule_started_date) * 24 * 60  > ln_max_rule_duration THEN
		
			RAISE_APPLICATION_ERROR(-20030,'Max rule duration of ' || ln_max_rule_duration || ' minutes reached');

		END IF;

		BEGIN

		Process_sql_stmt(p_run_id, p_run_date, p_rule_id, p_rule_group_id, p_user, lv_OBJECT_ID, ld_DAYTIME, lv_ALT_UNIQUE_KEY, lv_SQL_FLD_1, lv_SQL_FLD_2, lv_SQL_FLD_3, lv_SQL_FLD_4, lv_SQL_FLD_5, lv_ADDNL_INFO, LV_OP_PU_ID, LV_OP_SUB_PU_ID, LV_OP_AREA_ID, LV_OP_SUB_AREA_ID, LV_OP_FCTY_CLASS_2_ID, LV_OP_FCTY_CLASS_1_ID,LV_OP_WELL_HOOKUP_ID, LV_CP_PU_ID, LV_CP_SUB_PU_ID, LV_CP_AREA_ID, LV_CP_SUB_AREA_ID, LV_CP_OPERATOR_ROUTE_ID, LV_CP_COL_POINT_ID,LV_GEO_AREA_ID, LV_GEO_SUB_AREA_ID, LV_GEO_FIELD_ID, LV_GEO_SUB_FIELD_ID, LV_GROUP_REF_ID_1, LV_GROUP_REF_ID_2, LV_GROUP_REF_ID_3, LV_GROUP_REF_ID_4, LV_GROUP_REF_ID_5, LV_GROUP_REF_ID_6, LV_GROUP_REF_ID_7, LV_GROUP_REF_ID_8, LV_GROUP_REF_ID_9, LV_GROUP_REF_ID_10 );

		EXCEPTION
   			WHEN OTHERS THEN 
				UpdateRunLog(p_run_id, 'Rule ID ' || p_rule_id || ': Error processing SQL' || SQLERRM, 'FAILURE', p_user); 
				RAISE;


		END;

           END LOOP;

	ELSIF GET_SQL_ATTRIBUTE_NAME('SQL_FLD_4') is NOT NULL THEN

	   LOOP
            
        	FETCH DQ_CV INTO LV_OBJECT_ID, LD_DAYTIME, LV_ALT_UNIQUE_KEY, LV_SQL_FLD_1, LV_SQL_FLD_2, LV_SQL_FLD_3, LV_SQL_FLD_4, LV_ADDNL_INFO, LV_OP_PU_ID, LV_OP_SUB_PU_ID, LV_OP_AREA_ID, LV_OP_SUB_AREA_ID, LV_OP_FCTY_CLASS_2_ID, LV_OP_FCTY_CLASS_1_ID,LV_OP_WELL_HOOKUP_ID, LV_CP_PU_ID, LV_CP_SUB_PU_ID, LV_CP_AREA_ID, LV_CP_SUB_AREA_ID, LV_CP_OPERATOR_ROUTE_ID, LV_CP_COL_POINT_ID,LV_GEO_AREA_ID, LV_GEO_SUB_AREA_ID, LV_GEO_FIELD_ID, LV_GEO_SUB_FIELD_ID, LV_GROUP_REF_ID_1, LV_GROUP_REF_ID_2, LV_GROUP_REF_ID_3, LV_GROUP_REF_ID_4, LV_GROUP_REF_ID_5, LV_GROUP_REF_ID_6, LV_GROUP_REF_ID_7, LV_GROUP_REF_ID_8, LV_GROUP_REF_ID_9, LV_GROUP_REF_ID_10;
                 
                EXIT WHEN DQ_cv%NOTFOUND;

		li_total_error_count := li_total_error_count + 1;

		IF li_total_error_count > ln_max_rule_results THEN
		
			RAISE_APPLICATION_ERROR(-20029,'Max rule results of ' || ln_max_rule_results || ' reached.');

		END IF;

		IF (sysdate - ld_rule_started_date) * 24 * 60  > ln_max_rule_duration THEN
		
			RAISE_APPLICATION_ERROR(-20030,'Max rule duration of ' || ln_max_rule_duration || ' minutes reached');

		END IF;

		BEGIN

		Process_sql_stmt(p_run_id, p_run_date, p_rule_id, p_rule_group_id, p_user, lv_OBJECT_ID, ld_DAYTIME, lv_ALT_UNIQUE_KEY, lv_SQL_FLD_1, lv_SQL_FLD_2, lv_SQL_FLD_3, lv_SQL_FLD_4, lv_SQL_FLD_5, lv_ADDNL_INFO, LV_OP_PU_ID, LV_OP_SUB_PU_ID, LV_OP_AREA_ID, LV_OP_SUB_AREA_ID, LV_OP_FCTY_CLASS_2_ID, LV_OP_FCTY_CLASS_1_ID,LV_OP_WELL_HOOKUP_ID, LV_CP_PU_ID, LV_CP_SUB_PU_ID, LV_CP_AREA_ID, LV_CP_SUB_AREA_ID, LV_CP_OPERATOR_ROUTE_ID, LV_CP_COL_POINT_ID,LV_GEO_AREA_ID, LV_GEO_SUB_AREA_ID, LV_GEO_FIELD_ID, LV_GEO_SUB_FIELD_ID, LV_GROUP_REF_ID_1, LV_GROUP_REF_ID_2, LV_GROUP_REF_ID_3, LV_GROUP_REF_ID_4, LV_GROUP_REF_ID_5, LV_GROUP_REF_ID_6, LV_GROUP_REF_ID_7, LV_GROUP_REF_ID_8, LV_GROUP_REF_ID_9, LV_GROUP_REF_ID_10 );

		EXCEPTION
   			WHEN OTHERS THEN 
				UpdateRunLog(p_run_id, 'Rule ID ' || p_rule_id || ': Error processing SQL' || SQLERRM, 'FAILURE', p_user); 
				RAISE;


		END;

           END LOOP;

	ELSIF GET_SQL_ATTRIBUTE_NAME('SQL_FLD_3') is NOT NULL THEN

	   LOOP
            
        	FETCH DQ_CV INTO LV_OBJECT_ID, LD_DAYTIME, LV_ALT_UNIQUE_KEY, LV_SQL_FLD_1, LV_SQL_FLD_2, LV_SQL_FLD_3, LV_ADDNL_INFO, LV_OP_PU_ID, LV_OP_SUB_PU_ID, LV_OP_AREA_ID, LV_OP_SUB_AREA_ID, LV_OP_FCTY_CLASS_2_ID, LV_OP_FCTY_CLASS_1_ID,LV_OP_WELL_HOOKUP_ID, LV_CP_PU_ID, LV_CP_SUB_PU_ID, LV_CP_AREA_ID, LV_CP_SUB_AREA_ID, LV_CP_OPERATOR_ROUTE_ID, LV_CP_COL_POINT_ID,LV_GEO_AREA_ID, LV_GEO_SUB_AREA_ID, LV_GEO_FIELD_ID, LV_GEO_SUB_FIELD_ID, LV_GROUP_REF_ID_1, LV_GROUP_REF_ID_2, LV_GROUP_REF_ID_3, LV_GROUP_REF_ID_4, LV_GROUP_REF_ID_5, LV_GROUP_REF_ID_6, LV_GROUP_REF_ID_7, LV_GROUP_REF_ID_8, LV_GROUP_REF_ID_9, LV_GROUP_REF_ID_10;
                 
                EXIT WHEN DQ_cv%NOTFOUND;

		li_total_error_count := li_total_error_count + 1;

		IF li_total_error_count > ln_max_rule_results THEN
		
			RAISE_APPLICATION_ERROR(-20029,'Max rule results of ' || ln_max_rule_results || ' reached.');

		END IF;

		IF (sysdate - ld_rule_started_date) * 24 * 60  > ln_max_rule_duration THEN
		
			RAISE_APPLICATION_ERROR(-20030,'Max rule duration of ' || ln_max_rule_duration || ' minutes reached');

		END IF;

		BEGIN

		Process_sql_stmt(p_run_id, p_run_date, p_rule_id, p_rule_group_id, p_user, lv_OBJECT_ID, ld_DAYTIME, lv_ALT_UNIQUE_KEY, lv_SQL_FLD_1, lv_SQL_FLD_2, lv_SQL_FLD_3, lv_SQL_FLD_4, lv_SQL_FLD_5, lv_ADDNL_INFO, LV_OP_PU_ID, LV_OP_SUB_PU_ID, LV_OP_AREA_ID, LV_OP_SUB_AREA_ID, LV_OP_FCTY_CLASS_2_ID, LV_OP_FCTY_CLASS_1_ID,LV_OP_WELL_HOOKUP_ID, LV_CP_PU_ID, LV_CP_SUB_PU_ID, LV_CP_AREA_ID, LV_CP_SUB_AREA_ID, LV_CP_OPERATOR_ROUTE_ID, LV_CP_COL_POINT_ID,LV_GEO_AREA_ID, LV_GEO_SUB_AREA_ID, LV_GEO_FIELD_ID, LV_GEO_SUB_FIELD_ID, LV_GROUP_REF_ID_1, LV_GROUP_REF_ID_2, LV_GROUP_REF_ID_3, LV_GROUP_REF_ID_4, LV_GROUP_REF_ID_5, LV_GROUP_REF_ID_6, LV_GROUP_REF_ID_7, LV_GROUP_REF_ID_8, LV_GROUP_REF_ID_9, LV_GROUP_REF_ID_10 );

		EXCEPTION
   			WHEN OTHERS THEN 
				UpdateRunLog(p_run_id, 'Rule ID ' || p_rule_id || ': Error processing SQL' || SQLERRM, 'FAILURE', p_user); 
				RAISE;


		END;

	  END LOOP;

	ELSIF GET_SQL_ATTRIBUTE_NAME('SQL_FLD_2') is NOT NULL THEN

	   LOOP
            
        	FETCH DQ_CV INTO LV_OBJECT_ID, LD_DAYTIME, LV_ALT_UNIQUE_KEY, LV_SQL_FLD_1, LV_SQL_FLD_2, LV_ADDNL_INFO, LV_OP_PU_ID, LV_OP_SUB_PU_ID, LV_OP_AREA_ID, LV_OP_SUB_AREA_ID, LV_OP_FCTY_CLASS_2_ID, LV_OP_FCTY_CLASS_1_ID,LV_OP_WELL_HOOKUP_ID, LV_CP_PU_ID, LV_CP_SUB_PU_ID, LV_CP_AREA_ID, LV_CP_SUB_AREA_ID, LV_CP_OPERATOR_ROUTE_ID, LV_CP_COL_POINT_ID,LV_GEO_AREA_ID, LV_GEO_SUB_AREA_ID, LV_GEO_FIELD_ID, LV_GEO_SUB_FIELD_ID, LV_GROUP_REF_ID_1, LV_GROUP_REF_ID_2, LV_GROUP_REF_ID_3, LV_GROUP_REF_ID_4, LV_GROUP_REF_ID_5, LV_GROUP_REF_ID_6, LV_GROUP_REF_ID_7, LV_GROUP_REF_ID_8, LV_GROUP_REF_ID_9, LV_GROUP_REF_ID_10;
                 
                EXIT WHEN DQ_cv%NOTFOUND;

		li_total_error_count := li_total_error_count + 1;

		IF li_total_error_count > ln_max_rule_results THEN
		
			RAISE_APPLICATION_ERROR(-20029,'Max rule results of ' || ln_max_rule_results || ' reached.');

		END IF;

		IF (sysdate - ld_rule_started_date) * 24 * 60  > ln_max_rule_duration THEN
		
			RAISE_APPLICATION_ERROR(-20030,'Max rule duration of ' || ln_max_rule_duration || ' minutes reached');

		END IF;

		BEGIN

		Process_sql_stmt(p_run_id, p_run_date, p_rule_id, p_rule_group_id, p_user, lv_OBJECT_ID, ld_DAYTIME, lv_ALT_UNIQUE_KEY, lv_SQL_FLD_1, lv_SQL_FLD_2, lv_SQL_FLD_3, lv_SQL_FLD_4, lv_SQL_FLD_5, lv_ADDNL_INFO, LV_OP_PU_ID, LV_OP_SUB_PU_ID, LV_OP_AREA_ID, LV_OP_SUB_AREA_ID, LV_OP_FCTY_CLASS_2_ID, LV_OP_FCTY_CLASS_1_ID,LV_OP_WELL_HOOKUP_ID, LV_CP_PU_ID, LV_CP_SUB_PU_ID, LV_CP_AREA_ID, LV_CP_SUB_AREA_ID, LV_CP_OPERATOR_ROUTE_ID, LV_CP_COL_POINT_ID,LV_GEO_AREA_ID, LV_GEO_SUB_AREA_ID, LV_GEO_FIELD_ID, LV_GEO_SUB_FIELD_ID, LV_GROUP_REF_ID_1, LV_GROUP_REF_ID_2, LV_GROUP_REF_ID_3, LV_GROUP_REF_ID_4, LV_GROUP_REF_ID_5, LV_GROUP_REF_ID_6, LV_GROUP_REF_ID_7, LV_GROUP_REF_ID_8, LV_GROUP_REF_ID_9, LV_GROUP_REF_ID_10 );

		EXCEPTION
   			WHEN OTHERS THEN 
				UpdateRunLog(p_run_id, 'Rule ID ' || p_rule_id || ': Error processing SQL' || SQLERRM, 'FAILURE', p_user); 
				RAISE;


		END;


           END LOOP;           

	ELSIF GET_SQL_ATTRIBUTE_NAME('SQL_FLD_1') is NOT NULL THEN

	   LOOP
            
        	FETCH DQ_CV INTO LV_OBJECT_ID, LD_DAYTIME, LV_ALT_UNIQUE_KEY, LV_SQL_FLD_1, LV_ADDNL_INFO, LV_OP_PU_ID, LV_OP_SUB_PU_ID, LV_OP_AREA_ID, LV_OP_SUB_AREA_ID, LV_OP_FCTY_CLASS_2_ID, LV_OP_FCTY_CLASS_1_ID,LV_OP_WELL_HOOKUP_ID, LV_CP_PU_ID, LV_CP_SUB_PU_ID, LV_CP_AREA_ID, LV_CP_SUB_AREA_ID, LV_CP_OPERATOR_ROUTE_ID, LV_CP_COL_POINT_ID,LV_GEO_AREA_ID, LV_GEO_SUB_AREA_ID, LV_GEO_FIELD_ID, LV_GEO_SUB_FIELD_ID, LV_GROUP_REF_ID_1, LV_GROUP_REF_ID_2, LV_GROUP_REF_ID_3, LV_GROUP_REF_ID_4, LV_GROUP_REF_ID_5, LV_GROUP_REF_ID_6, LV_GROUP_REF_ID_7, LV_GROUP_REF_ID_8, LV_GROUP_REF_ID_9, LV_GROUP_REF_ID_10;
                 
                EXIT WHEN DQ_cv%NOTFOUND;

		li_total_error_count := li_total_error_count + 1;

		IF li_total_error_count > ln_max_rule_results THEN
		
			RAISE_APPLICATION_ERROR(-20029,'Max rule results of ' || ln_max_rule_results || ' reached.');

		END IF;

		IF (sysdate - ld_rule_started_date) * 24 * 60  > ln_max_rule_duration THEN
		
			RAISE_APPLICATION_ERROR(-20030,'Max rule duration of ' || ln_max_rule_duration || ' minutes reached');

		END IF;

		BEGIN

		Process_sql_stmt(p_run_id, p_run_date, p_rule_id, p_rule_group_id, p_user, lv_OBJECT_ID, ld_DAYTIME, lv_ALT_UNIQUE_KEY, lv_SQL_FLD_1, lv_SQL_FLD_2, lv_SQL_FLD_3, lv_SQL_FLD_4, lv_SQL_FLD_5, lv_ADDNL_INFO, LV_OP_PU_ID, LV_OP_SUB_PU_ID, LV_OP_AREA_ID, LV_OP_SUB_AREA_ID, LV_OP_FCTY_CLASS_2_ID, LV_OP_FCTY_CLASS_1_ID,LV_OP_WELL_HOOKUP_ID, LV_CP_PU_ID, LV_CP_SUB_PU_ID, LV_CP_AREA_ID, LV_CP_SUB_AREA_ID, LV_CP_OPERATOR_ROUTE_ID, LV_CP_COL_POINT_ID,LV_GEO_AREA_ID, LV_GEO_SUB_AREA_ID, LV_GEO_FIELD_ID, LV_GEO_SUB_FIELD_ID, LV_GROUP_REF_ID_1, LV_GROUP_REF_ID_2, LV_GROUP_REF_ID_3, LV_GROUP_REF_ID_4, LV_GROUP_REF_ID_5, LV_GROUP_REF_ID_6, LV_GROUP_REF_ID_7, LV_GROUP_REF_ID_8, LV_GROUP_REF_ID_9, LV_GROUP_REF_ID_10 );

		EXCEPTION
   			WHEN OTHERS THEN 
				UpdateRunLog(p_run_id, 'Rule ID ' || p_rule_id || ': Error processing SQL' || SQLERRM, 'FAILURE', p_user); 
				RAISE;


		END;


           END LOOP;           

	ELSE 

	   LOOP
            
        	FETCH DQ_CV INTO LV_OBJECT_ID, LD_DAYTIME, LV_ALT_UNIQUE_KEY, LV_ADDNL_INFO, LV_OP_PU_ID, LV_OP_SUB_PU_ID, LV_OP_AREA_ID, LV_OP_SUB_AREA_ID, LV_OP_FCTY_CLASS_2_ID, LV_OP_FCTY_CLASS_1_ID,LV_OP_WELL_HOOKUP_ID, LV_CP_PU_ID, LV_CP_SUB_PU_ID, LV_CP_AREA_ID, LV_CP_SUB_AREA_ID, LV_CP_OPERATOR_ROUTE_ID, LV_CP_COL_POINT_ID,LV_GEO_AREA_ID, LV_GEO_SUB_AREA_ID, LV_GEO_FIELD_ID, LV_GEO_SUB_FIELD_ID, LV_GROUP_REF_ID_1, LV_GROUP_REF_ID_2, LV_GROUP_REF_ID_3, LV_GROUP_REF_ID_4, LV_GROUP_REF_ID_5, LV_GROUP_REF_ID_6, LV_GROUP_REF_ID_7, LV_GROUP_REF_ID_8, LV_GROUP_REF_ID_9, LV_GROUP_REF_ID_10;
                 
                EXIT WHEN DQ_cv%NOTFOUND;

		li_total_error_count := li_total_error_count + 1;

		IF li_total_error_count > ln_max_rule_results THEN
		
			RAISE_APPLICATION_ERROR(-20029,'Max rule results of ' || ln_max_rule_results || ' reached.');

		END IF;

		IF (sysdate - ld_rule_started_date) * 24 * 60  > ln_max_rule_duration THEN
		
			RAISE_APPLICATION_ERROR(-20030,'Max rule duration of ' || ln_max_rule_duration || ' minutes reached');

		END IF;

		BEGIN

		Process_sql_stmt(p_run_id, p_run_date, p_rule_id, p_rule_group_id, p_user, lv_OBJECT_ID, ld_DAYTIME, lv_ALT_UNIQUE_KEY, lv_SQL_FLD_1, lv_SQL_FLD_2, lv_SQL_FLD_3, lv_SQL_FLD_4, lv_SQL_FLD_5, lv_ADDNL_INFO, LV_OP_PU_ID, LV_OP_SUB_PU_ID, LV_OP_AREA_ID, LV_OP_SUB_AREA_ID, LV_OP_FCTY_CLASS_2_ID, LV_OP_FCTY_CLASS_1_ID,LV_OP_WELL_HOOKUP_ID, LV_CP_PU_ID, LV_CP_SUB_PU_ID, LV_CP_AREA_ID, LV_CP_SUB_AREA_ID, LV_CP_OPERATOR_ROUTE_ID, LV_CP_COL_POINT_ID,LV_GEO_AREA_ID, LV_GEO_SUB_AREA_ID, LV_GEO_FIELD_ID, LV_GEO_SUB_FIELD_ID, LV_GROUP_REF_ID_1, LV_GROUP_REF_ID_2, LV_GROUP_REF_ID_3, LV_GROUP_REF_ID_4, LV_GROUP_REF_ID_5, LV_GROUP_REF_ID_6, LV_GROUP_REF_ID_7, LV_GROUP_REF_ID_8, LV_GROUP_REF_ID_9, LV_GROUP_REF_ID_10 );

		EXCEPTION
   			WHEN OTHERS THEN 
				UpdateRunLog(p_run_id, 'Rule ID ' || p_rule_id || ': Error processing SQL' || SQLERRM, 'FAILURE', p_user); 
				RAISE;


		END;


           END LOOP;           

	END IF;

        CLOSE DQ_CV;


END IF;            

end Execute_sql_stmt;


---------------------------------------------------------------------------------------------------
-- Procedure: PostRuleResultLog
-- Description    : This is the procedure to post the counts to the Rule Run Log table
--  Called From:  procedures: batch_load_dq_results, batch_load_dq_results_hier, batch_load_dq_single, batch_reload_single_result, batch_reload_result_group
---------------------------------------------------------------------------------------------------
PROCEDURE PostRuleResultLog(p_run_id integer, p_rule_id integer, p_rule_started_date date, p_delete_sql_from_stmt varchar2, p_result_retention_days integer, p_user varchar2)
IS

TYPE DQCURTYP IS ref cursor;
DQ_CV DQCURTYP;

sql_stmt varchar2(10000);
lv_logging_level varchar2(32);
lv_logging_level_alt varchar2(240);

lv_log_object_id  VARCHAR2(32);

li_total_error_count integer;
li_new_error_count integer;
li_old_error_count integer;
li_delete_count integer; 
li_retention_delete_count integer; 

li_rule_total_error_count integer;
li_rule_new_error_count integer;
li_rule_old_error_count integer;
li_rule_delete_error_count integer;
li_rule_retention_delete_count integer;


BEGIN


li_rule_total_error_count := 0;
li_rule_new_error_count := 0;
li_rule_old_error_count := 0;
li_rule_delete_error_count := 0;
li_rule_retention_delete_count := 0;

---- create detailed logging

lv_logging_level := NULL;
lv_logging_level_alt := NULL;

lv_logging_level := ec_ct_dq_rule.logging_level(p_rule_id);
lv_logging_level_alt := ec_prosty_codes.alt_code(lv_logging_level,'CT_DQ_LOGGING_LEVEL');

sql_stmt := NULL;
lv_log_object_id := NULL;
li_total_error_count := 0;
li_new_error_count := 0;
li_old_error_count := 0;


sql_stmt := 'select log_object_id, count(*), count(new) from (select DECODE(ORIG_RUN_DATE,LAST_RUN_DATE,''NEW'',NULL) as new,';
	
	
sql_stmt := sql_stmt || nvl(trim(lv_logging_level_alt),'NULL') || ' as log_object_id';


sql_stmt := sql_stmt || ' from ct_dq_rule_results where last_run_id = ' || p_run_id || ' and rule_id = ' || p_rule_id || ') group by log_object_id';


OPEN DQ_cv FOR sql_stmt;
  
LOOP
            
        FETCH DQ_CV INTO lv_log_object_id, li_total_error_count, li_new_error_count;
                 
        EXIT WHEN DQ_cv%NOTFOUND;

	li_old_error_count := li_total_error_count - li_new_error_count;

	li_rule_total_error_count := li_rule_total_error_count + li_total_error_count ;
	li_rule_new_error_count := li_rule_new_error_count + li_new_error_count;
	li_rule_old_error_count := li_rule_old_error_count + li_old_error_count ;

	IF trim(lv_logging_level_alt) is NOT NULL THEN

		BEGIN
                
        	insert into CT_DQ_RULE_RUN_DETAIL_LOG (run_id, RULE_ID, TOTAL_ERRORS, TOTAL_NEW_ERRORS, TOTAL_OLD_ERRORS, TOTAL_DELETED_ERRORS, TOTAL_ROLLED_ERRORS, CREATED_BY, CREATED_DATE, LOG_OBJECT_ID, LOGGING_LEVEL) 
		VALUES (p_run_id, p_rule_id, li_total_error_count, li_new_error_count, li_old_error_count, 0, 0, p_user, SYSDATE, lv_log_object_id, lv_logging_level);

		EXCEPTION
   			WHEN OTHERS THEN 
			UpdateRunLog(p_run_id, 'Rule ID ' || p_rule_id || ': Error inserting to CT_DQ_RULE_RUN_DETAIL_LOG. ' || SQLERRM, 'FAILURE', p_user); 
			RAISE;

		END;
	END IF;


END LOOP;

CLOSE DQ_CV;

----- count the deletes

sql_stmt := NULL;
li_delete_count := 0;

IF trim(lv_logging_level_alt) is NULL THEN

	sql_stmt := 'select NULL, count(*) ' || p_delete_sql_from_stmt; 

ELSE
	sql_stmt := 'select ' || lv_logging_level_alt || ', count(*) ' || p_delete_sql_from_stmt || ' group by ' || lv_logging_level_alt; 

END IF;


OPEN DQ_cv FOR sql_stmt;
  
LOOP

	FETCH DQ_CV INTO lv_log_object_id, li_delete_count;
                
       	EXIT WHEN DQ_cv%NOTFOUND;

	li_rule_delete_error_count := li_rule_delete_error_count + li_delete_count ;

	IF trim(lv_logging_level_alt) is NOT NULL THEN

		BEGIN

		UPDATE CT_DQ_RULE_RUN_DETAIL_LOG SET TOTAL_DELETED_ERRORS = li_delete_count	
		WHERE RUN_ID = p_run_id
		AND RULE_ID = p_rule_id
		AND log_object_id = lv_log_object_id;

		EXCEPTION
			WHEN no_data_found THEN NULL;
			WHEN OTHERS THEN 
			UpdateRunLog(p_run_id, 'Rule ID ' || p_rule_id || ': Error Updating CT_DQ_RULE_RUN_DETAIL_LOG for delete count. ' || SQLERRM, 'FAILURE', p_user); 
			RAISE;
	
		END;

		IF SQL%NOTFOUND THEN

			BEGIN
	                
       			insert into CT_DQ_RULE_RUN_DETAIL_LOG (run_id, RULE_ID, TOTAL_ERRORS, TOTAL_NEW_ERRORS, TOTAL_OLD_ERRORS, TOTAL_DELETED_ERRORS, TOTAL_ROLLED_ERRORS, CREATED_BY, CREATED_DATE, LOG_OBJECT_ID,LOGGING_LEVEL) 
			VALUES (p_run_id, p_rule_id, 0, 0, 0, li_delete_count, 0, p_user, SYSDATE, lv_log_object_id, lv_logging_level);

			EXCEPTION
				WHEN OTHERS THEN 
				UpdateRunLog(p_run_id, 'Rule ID ' || p_rule_id || ': Error inserting to CT_DQ_RULE_RUN_DETAIL_LOG. ' || SQLERRM, 'FAILURE', p_user); 
				RAISE;

			END;

		END IF;

	END IF;

END LOOP;

CLOSE DQ_CV;

--- within the from and to dates of the group, delete any existing results that were not updated in the current run (these are assumed to be resolved)  
--- use the same sql_stmt which is used for the delete counts


sql_stmt := 'delete ' || p_delete_sql_from_stmt;

BEGIN

EXECUTE IMMEDIATE sql_stmt;	
EXCEPTION
   	WHEN no_data_found THEN NULL;
   	WHEN OTHERS THEN
	UpdateRunLog(p_run_id, 'Rule ID ' || p_rule_id || ': Error Deleting from CT_DQ_RULE_RESULTS. ' || SQLERRM, 'FAILURE', p_user); 
	RAISE;

END;



----- count the deletes for retention days

sql_stmt := NULL;
li_retention_delete_count := 0;

IF p_result_retention_days is not NULL THEN

	IF trim(lv_logging_level_alt) is NULL THEN

		sql_stmt := 'select NULL'; 

	ELSE
		sql_stmt := 'select ' || lv_logging_level_alt; 

	END IF;

	sql_stmt := sql_stmt || ', count(*) from ct_dq_rule_results where rule_id = ' || p_rule_id || ' and last_run_id <> ' || p_run_id || ' and last_run_Date <= sysdate - ' || p_result_retention_days;


	IF trim(lv_logging_level_alt) is not NULL THEN

		sql_stmt := sql_stmt || ' group by ' || lv_logging_level_alt; 

	END IF;

	OPEN DQ_cv FOR sql_stmt;
  
	LOOP

       		FETCH DQ_CV INTO lv_log_object_id, li_retention_delete_count;
                
       		EXIT WHEN DQ_cv%NOTFOUND;

		li_rule_retention_delete_count := li_rule_retention_delete_count + li_retention_delete_count ;

		IF trim(lv_logging_level_alt) is NOT NULL THEN

			BEGIN

			UPDATE CT_DQ_RULE_RUN_DETAIL_LOG SET TOTAL_ROLLED_ERRORS = li_retention_delete_count	
			WHERE RUN_ID = p_run_id
			AND RULE_ID = p_rule_id
			AND log_object_id = lv_log_object_id;

			EXCEPTION
				WHEN no_data_found THEN NULL;
				WHEN OTHERS THEN 
				UpdateRunLog(p_run_id, 'Rule ID ' || p_rule_id || ': Error Updating CT_DQ_RULE_RUN_DETAIL_LOG for retention delete count. ' || SQLERRM, 'FAILURE', p_user); 
				RAISE;

			END;

			IF SQL%NOTFOUND THEN

				BEGIN
                
       				insert into CT_DQ_RULE_RUN_DETAIL_LOG (run_id, RULE_ID, TOTAL_ERRORS, TOTAL_NEW_ERRORS, TOTAL_OLD_ERRORS, TOTAL_DELETED_ERRORS, TOTAL_ROLLED_ERRORS, CREATED_BY, CREATED_DATE, LOG_OBJECT_ID, LOGGING_LEVEL) 
				VALUES (p_run_id, p_rule_id, 0, 0, 0, 0, li_retention_delete_count, p_user, SYSDATE, lv_log_object_id, lv_logging_level);

				EXCEPTION
					WHEN OTHERS THEN 
					UpdateRunLog(p_run_id, 'Rule ID ' || p_rule_id || ': Error inserting to CT_DQ_RULE_RUN_DETAIL_LOG. ' || SQLERRM, 'FAILURE', p_user); 
					RAISE;

				END;

			END IF;

		END IF;

	END LOOP;

	CLOSE DQ_CV;

END IF;


------ total rule logging


BEGIN
                
insert into CT_DQ_RULE_RUN_LOG 
(run_id, 
RULE_ID, 
TOTAL_ERRORS, 
TOTAL_NEW_ERRORS, 
TOTAL_OLD_ERRORS, 
TOTAL_DELETED_ERRORS, 
TOTAL_ROLLED_ERRORS, 
STARTED_DATE, 
COMPLETED_DATE,
CREATED_BY, 
CREATED_DATE) 
VALUES 
(p_run_id, 
p_rule_id, 
li_rule_total_error_count, 
li_rule_new_error_count, 
li_rule_old_error_count, 
li_rule_delete_error_count, 
li_rule_retention_delete_count, 
p_rule_started_date, 
SYSDATE,
p_user, 
SYSDATE);

EXCEPTION
   	WHEN OTHERS THEN 
	UpdateRunLog(p_run_id, 'Rule ID ' || p_rule_id || ': Error inserting to CT_DQ_RULE_RUN_LOG. ' || SQLERRM, 'FAILURE', p_user); 
	RAISE;

END;




end PostRuleResultLog;


---------------------------------------------------------------------------------------------------
-- Procedure: Process_sql_stmt
-- Description    : This is the procedure to actually determine the hierarchy and log the results
--  Called From:  procedures: Execute_sql_stmt
---------------------------------------------------------------------------------------------------
PROCEDURE Process_sql_stmt(p_run_id integer, p_run_date date, p_rule_id integer, p_rule_group_id integer, p_user varchar2, p_OBJECT_ID varchar2, p_DAYTIME date, p_ALT_UNIQUE_KEY varchar2, p_SQL_FLD_1 varchar2, p_SQL_FLD_2 varchar2, p_SQL_FLD_3 varchar2, p_SQL_FLD_4 varchar2, p_SQL_FLD_5 varchar2, p_ADDNL_INFO varchar2, 
p_OP_PU_ID varchar2, p_OP_SUB_PU_ID varchar2, p_OP_AREA_ID varchar2, p_OP_SUB_AREA_ID varchar2, p_OP_FCTY_CLASS_2_ID varchar2, p_OP_FCTY_CLASS_1_ID varchar2,p_OP_WELL_HOOKUP_ID varchar2, p_CP_PU_ID varchar2, p_CP_SUB_PU_ID varchar2, p_CP_AREA_ID varchar2, p_CP_SUB_AREA_ID varchar2, p_CP_OPERATOR_ROUTE_ID varchar2, p_CP_COL_POINT_ID varchar2,p_GEO_AREA_ID varchar2, p_GEO_SUB_AREA_ID varchar2, p_GEO_FIELD_ID varchar2, p_GEO_SUB_FIELD_ID varchar2, p_GROUP_REF_ID_1 varchar2, p_GROUP_REF_ID_2 varchar2, p_GROUP_REF_ID_3 varchar2, p_GROUP_REF_ID_4 varchar2, p_GROUP_REF_ID_5 varchar2, p_GROUP_REF_ID_6 varchar2, p_GROUP_REF_ID_7 varchar2, p_GROUP_REF_ID_8 varchar2, p_GROUP_REF_ID_9 varchar2, p_GROUP_REF_ID_10 varchar2)
IS


LV_OBJECT_TYPE VARCHAR2(32);     

li_result_id INTEGER;

      
BEGIN
                 
LI_RESULT_ID :=  NULL;

lv_object_type := ECDP_OBJECTS.GETOBJCLASSNAME(p_OBJECT_ID);

BEGIN

SELECT RESULT_ID INTO LI_RESULT_ID 
FROM CT_DQ_RULE_RESULTS 
WHERE RULE_ID = p_RULE_ID 
AND OBJECT_ID = p_OBJECT_ID 
AND (DAYTIME = p_DAYTIME OR (DAYTIME IS NULL AND p_DAYTIME IS NULL))
AND (ALT_UNIQUE_KEY = p_ALT_UNIQUE_KEY OR (ALT_UNIQUE_KEY IS NULL AND p_ALT_UNIQUE_KEY IS NULL));

EXCEPTION
   		WHEN no_data_found THEN NULL;
   		WHEN OTHERS THEN 
			UpdateRunLog(p_run_id, 'Rule ID ' || p_rule_id || ': Error reading CT_DQ_RULE_RESULTS for existence check. ' || SQLERRM, 'FAILURE', p_user); 
			RAISE;

END;

IF SQL%NOTFOUND THEN

	BEGIN

        insert into CT_DQ_RULE_RESULTS (ORIG_RUN_DATE, LAST_RUN_DATE, LAST_RUN_ID, RULE_ID, OBJECT_TYPE, OBJECT_ID, DAYTIME, ALT_UNIQUE_KEY, SQL_FLD_1, SQL_FLD_2, SQL_FLD_3, SQL_FLD_4, SQL_FLD_5, ADDNL_INFO, OP_PU_ID, 
  	OP_SUB_PU_ID, OP_AREA_ID, OP_SUB_AREA_ID, OP_FCTY_CLASS_2_ID, OP_FCTY_CLASS_1_ID, OP_WELL_HOOKUP_ID, 
	CP_PU_ID, CP_SUB_PU_ID, CP_AREA_ID, CP_SUB_AREA_ID, CP_OPERATOR_ROUTE_ID, CP_COL_POINT_ID,  
	GROUP_REF_ID_1, GROUP_REF_ID_2, GROUP_REF_ID_3, GROUP_REF_ID_4, GROUP_REF_ID_5, GROUP_REF_ID_6, GROUP_REF_ID_7, GROUP_REF_ID_8, 
	GROUP_REF_ID_9, GROUP_REF_ID_10, GEO_AREA_ID, GEO_SUB_AREA_ID, GEO_FIELD_ID, GEO_SUB_FIELD_ID, CREATED_BY) 
	VALUES (p_run_date, p_run_date, P_RUN_ID, p_rule_id, LV_OBJECT_type, p_OBJECT_ID, p_DAYTIME, p_ALT_UNIQUE_KEY, p_SQL_FLD_1, p_SQL_FLD_2, p_SQL_FLD_3, p_SQL_FLD_4, p_SQL_FLD_5, p_ADDNL_INFO, p_OP_PU_ID, 
  	p_OP_SUB_PU_ID, p_OP_AREA_ID, p_OP_SUB_AREA_ID, p_OP_FCTY_CLASS_2_ID, p_OP_FCTY_CLASS_1_ID, p_OP_WELL_HOOKUP_ID, 
	p_CP_PU_ID, p_CP_SUB_PU_ID, p_CP_AREA_ID, p_CP_SUB_AREA_ID, p_CP_OPERATOR_ROUTE_ID, p_CP_COL_POINT_ID,  
	p_GROUP_REF_ID_1, p_GROUP_REF_ID_2, p_GROUP_REF_ID_3, p_GROUP_REF_ID_4, p_GROUP_REF_ID_5, p_GROUP_REF_ID_6, p_GROUP_REF_ID_7, p_GROUP_REF_ID_8, 
	p_GROUP_REF_ID_9, p_GROUP_REF_ID_10, p_GEO_AREA_ID, p_GEO_SUB_AREA_ID, p_GEO_FIELD_ID, p_GEO_SUB_FIELD_ID, p_user);

	EXCEPTION
   		WHEN OTHERS THEN 
			UpdateRunLog(p_run_id, 'Rule ID ' || p_rule_id || ': Error inserting to CT_DQ_RULE_RESULTS. ' || SQLERRM, 'FAILURE', p_user); 
			RAISE;

	END;

ELSE

	BEGIN

        UPDATE CT_DQ_RULE_RESULTS 
	set ADDNL_INFO = p_ADDNL_INFO, 
	SQL_FLD_1 = p_SQL_FLD_1,
	SQL_FLD_2 = p_SQL_FLD_2,
	SQL_FLD_3 = p_SQL_FLD_3,
	SQL_FLD_4 = p_SQL_FLD_4,
	SQL_FLD_5 = p_SQL_FLD_5,
	LAST_RUN_DATE = p_run_date,
	LAST_RUN_ID = P_RUN_ID,
	OP_PU_ID = p_OP_PU_ID, 
  	OP_SUB_PU_ID = p_OP_SUB_PU_ID, 
  	OP_AREA_ID = p_OP_AREA_ID,        
  	OP_SUB_AREA_ID = p_OP_SUB_AREA_ID,          
  	OP_FCTY_CLASS_2_ID = p_OP_FCTY_CLASS_2_ID,          
  	OP_FCTY_CLASS_1_ID = p_OP_FCTY_CLASS_1_ID,          
  	OP_WELL_HOOKUP_ID = p_OP_WELL_HOOKUP_ID,       
  	CP_PU_ID = p_CP_PU_ID,          
  	CP_SUB_PU_ID = p_CP_SUB_PU_ID,          
  	CP_AREA_ID = p_CP_AREA_ID,          
  	CP_SUB_AREA_ID = p_CP_SUB_AREA_ID,          
  	CP_OPERATOR_ROUTE_ID = p_CP_OPERATOR_ROUTE_ID,          
  	CP_COL_POINT_ID = p_CP_COL_POINT_ID,          
  	GROUP_REF_ID_1 = p_GROUP_REF_ID_1,    
  	GROUP_REF_ID_2 = p_GROUP_REF_ID_2,    
  	GROUP_REF_ID_3 = p_GROUP_REF_ID_3,    
  	GROUP_REF_ID_4 = p_GROUP_REF_ID_4,    
  	GROUP_REF_ID_5 = p_GROUP_REF_ID_5,    
  	GROUP_REF_ID_6 = p_GROUP_REF_ID_6,    
  	GROUP_REF_ID_7 = p_GROUP_REF_ID_7,    
  	GROUP_REF_ID_8 = p_GROUP_REF_ID_8,    
  	GROUP_REF_ID_9 = p_GROUP_REF_ID_9,    
  	GROUP_REF_ID_10 = p_GROUP_REF_ID_10,
	GEO_AREA_ID = p_GEO_AREA_ID,
	GEO_SUB_AREA_ID = p_GEO_SUB_AREA_ID,
	GEO_FIELD_ID = p_GEO_FIELD_ID,
	GEO_SUB_FIELD_ID = p_GEO_SUB_FIELD_ID,
	LAST_UPDATED_BY = p_user 
	WHERE RESULT_ID = LI_RESULT_ID;

	EXCEPTION
   		WHEN OTHERS THEN 
			UpdateRunLog(p_run_id, 'Rule ID ' || p_rule_id || ': Error updating CT_DQ_RULE_RESULTS. ' || SQLERRM, 'FAILURE', p_user); 
			RAISE;

	END;


END IF;


end Process_sql_stmt;

---------------------------------------------------------------------------------------------------
-- Function: get_max_rule_run_created_date
-- Description    : This is the function to get the max created date for a rule run
--  Called From:  tv_ct_dq_rule_run_log
---------------------------------------------------------------------------------------------------
FUNCTION get_max_rule_run_created_date (
        p_run_id integer, p_rule_group_id integer, p_rule_id integer, p_run_date date)
RETURN date IS
ld_created_date date;

li_prev_rule_id integer;
 
BEGIN

ld_created_date := NULL;

IF p_run_id is not NULL and p_rule_group_id is not nULL and p_rule_id is not NULL THEN

	li_prev_rule_id := NULL;

	BEGIN
		select max(c.rule_id) into li_prev_rule_id 
		from ct_dq_rule_grp_combination c
		where c.rule_group_id = p_rule_group_id
		and c.rule_id < p_rule_id;

		EXCEPTION
   		WHEN no_data_found THEN NULL;
   		WHEN OTHERS THEN RAISE;

	 END;


	IF li_prev_rule_id is not NULL THEN

		BEGIN
			SELECT max(created_date) into ld_created_date 
			from ct_dq_rule_run_log a
			where a.run_id = p_run_id
			and a.rule_id = li_prev_rule_id;

		EXCEPTION
   			WHEN no_data_found THEN NULL;
   			WHEN OTHERS THEN RAISE;

	 	END;

	ELSE

		ld_created_date := p_run_date;

	END IF;

END IF;

RETURN ld_created_date;

END get_max_rule_run_created_date;


---------------------------------------------------------------------------------------------------
-- Function: get_rule_group_rule_count
-- Description    : This is the function to count the active rules within a rule group
--  Called From:  tv_ct_dq_rule_group_log
---------------------------------------------------------------------------------------------------
FUNCTION get_rule_group_rule_count (
        p_rule_group_id integer)
RETURN number IS
ln_rule_count number;
 
BEGIN


ln_rule_count := 0;

IF p_rule_group_id is not NULL THEN

	BEGIN
	SELECT count(*) into ln_rule_count from ct_dq_rule_grp_combination c, ct_dq_rule r 
	where c.rule_group_id = p_rule_group_id
	and c.rule_id = r.rule_id
	and r.is_active = 'Y';

	EXCEPTION
   		WHEN no_data_found THEN NULL;
   		WHEN OTHERS THEN RAISE;

	 END;

END IF;

RETURN ln_rule_count;

END get_rule_group_rule_count;


---------------------------------------------------------------------------------------------------
-- Function: get_sql_attribute_name
-- Description    : This is the function to evaluate the CT_DQ_RULE_RESULTS class in order to determine if one of the SQL flex fields
--                  has been used.  If so, then the configured attribute name will be used in the generated dynamic SQL
--  Called From:  procedures: combine_with_object_sql, convert_rule_to_sql, validate_dynamic_sql, Execute_sql_stmt
---------------------------------------------------------------------------------------------------
FUNCTION get_sql_attribute_name (
        p_db_sql_syntax varchar2)
RETURN varchar2 IS
lv_attribute_name varchar2(24);

BEGIN

lv_attribute_name := NULL;

IF p_db_sql_syntax is not NULL THEN

	BEGIN

	SELECT a.attribute_name into lv_attribute_name 
	from class_attr_db_mapping db, class_attribute a
	where db.class_name = a.class_name
	and db.attribute_name = a.attribute_name
	and db.class_name = 'CT_DQ_RULE_RESULTS'
	and db.db_mapping_type = 'COLUMN'
	and db.db_sql_syntax = upper(p_db_sql_syntax)
	and nvl(a.disabled_ind,'N') = 'N';  

	EXCEPTION
   		WHEN no_data_found THEN NULL;
   		WHEN OTHERS THEN RAISE;

	 END;

END IF;

RETURN lv_attribute_name;

END get_sql_attribute_name;

---------------------------------------------------------------------------------------------------
-- Procedure: CreateRunLog
-- Description    : This is the autonomous procedure to create the log for the run status for the RUN_ID
--  Called From:  procedures: batch_load_dq_results, batch_load_dq_results_hier, batch_load_dq_results_single, batch_reload_single_result, batch_reload_result_group, Process_sql_stmt
---------------------------------------------------------------------------------------------------
PROCEDURE CreateRunLog(p_run_id integer, p_run_type varchar2, p_rule_group_id integer, p_rule_id integer, p_hier_group_type varchar2, p_hier_object_id varchar2, p_rec_object_id varchar2, p_rec_daytime date, p_rec_alt_unique_key varchar2, p_run_date date, p_user varchar2)
IS

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

	insert into ct_dq_run_log
	(run_id,
	run_type,
	rule_group_id,
	rule_id,
	hier_group_type,
	hier_object_id,
	rec_object_id,
	rec_daytime,
	rec_alt_unique_key,
	run_status,
	run_date,
	created_by)
	values
	(p_run_id,
	p_run_type,
	p_rule_group_id, 
	p_rule_id,
	p_hier_group_type,
	p_hier_object_id,
	p_rec_object_id,
	p_rec_daytime,
	p_rec_alt_unique_key,
	'RUNNING',
	p_run_date,
	p_user);


COMMIT;

END CreateRunLog;

---------------------------------------------------------------------------------------------------
-- Procedure: UpdateRunLogParmDates
-- Description    : This is the autonomous procedure to update the parm dates that are not initially known
--  Called From:  procedures: batch_load_dq_results, batch_load_dq_results_hier, batch_load_dq_results_single, batch_reload_single_result, batch_reload_result_group, Process_sql_stmt
---------------------------------------------------------------------------------------------------
PROCEDURE UpdateRunLogParmDates(p_run_id integer, p_parm_start_date date, p_parm_end_date date)
IS

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

update ct_dq_run_log
set 
parm_start_date = p_parm_start_date,
parm_end_date = p_parm_end_date
where run_id = p_run_id;


COMMIT;

END UpdateRunLogParmDates;

---------------------------------------------------------------------------------------------------
-- Procedure: UpdateRunLog
-- Description    : This is the autonomous procedure to update the run status for the RUN_ID
--  Called From:  procedures: batch_load_dq_results, batch_load_dq_results_hier, batch_load_dq_results_single, batch_reload_single_result, batch_reload_result_group, Process_sql_stmt
---------------------------------------------------------------------------------------------------
PROCEDURE UpdateRunLog(p_run_id integer, p_error_message varchar2, p_status varchar2, p_user varchar2)
IS

lv_error_message VARCHAR2(2000);

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

lv_error_message := substr(p_error_message,1,2000);

update ct_dq_run_log
set run_status = p_status,
completed_date = sysdate,
run_message = lv_error_message,
last_updated_by = p_user
where run_id = p_run_id;


COMMIT;

END UpdateRunLog;

END UE_CT_DQ_RULES_PKG;
/