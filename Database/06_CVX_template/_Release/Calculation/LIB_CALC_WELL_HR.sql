-- Delete 
DECLARE
BEGIN
   ecdp_calculation.deleteCalculation(EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR'));
   UPDATE OV_CALC_LIBRARY SET object_end_date = object_start_date WHERE code = 'CVX_PROD';
END;
/

-- Load CALCULATION
DECLARE
   lv_tmp_obj_id        VARCHAR2(32);
BEGIN

	INSERT INTO OV_CALC_LIBRARY (CODE, NAME, OBJECT_START_DATE, DAYTIME, DESCRIPTION, COMMENTS) VALUES ('CVX_PROD', 'CVX Prod Library', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'), 'CVX Production Module Calculation Library', 'CVX Production Module Calculation Library');

   lv_tmp_obj_id := EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18');
   IF lv_tmp_obj_id IS NULL THEN
      lv_tmp_obj_id := SYS_GUID();
      insert into CALCULATION (OBJECT_ID,CALC_CONTEXT_ID,OBJECT_CODE,START_DATE,END_DATE,CALC_LIBRARY_ID,CALC_PERIOD,CALC_TYPE,CALC_SCOPE)
      values (lv_tmp_obj_id,EcDp_Objects.getObjIdFromCode('CALC_CONTEXT', 'EC_PROD'),'0B302D55917D40F49A026B62D1445D18',to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,EcDp_Objects.getObjIdFromCode('CALC_LIBRARY', NULL),'MTH','EQUATIONS','PRIVATE_SUB');
   ELSE
      update calculation_version set end_date=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') where object_id=lv_tmp_obj_id and daytime<to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') and NVL(end_date,to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS')+1)>to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS');
   END IF;
   insert into CALCULATION_VERSION (OBJECT_ID,NAME,DAYTIME,END_DATE,MAIN_CALCULATION_ID,IMPL_CALCULATION_ID,COMMENTS,CALC_EVENT_IND,VERSION_BACK_COMPAT)
   values (lv_tmp_obj_id,'Calculate production days and operating days for injection wells',to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,EcDp_Objects.getObjIdFromCode('CALCULATION', NULL),EcDp_Objects.getObjIdFromCode('CALCULATION', NULL),'Calculate production days and operating days for injection wells',NULL,NULL);

   lv_tmp_obj_id := EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF');
   IF lv_tmp_obj_id IS NULL THEN
      lv_tmp_obj_id := SYS_GUID();
      insert into CALCULATION (OBJECT_ID,CALC_CONTEXT_ID,OBJECT_CODE,START_DATE,END_DATE,CALC_LIBRARY_ID,CALC_PERIOD,CALC_TYPE,CALC_SCOPE)
      values (lv_tmp_obj_id,EcDp_Objects.getObjIdFromCode('CALC_CONTEXT', 'EC_PROD'),'51B1505F6F984A41B0CB693255A1BDEF',to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,EcDp_Objects.getObjIdFromCode('CALC_LIBRARY', NULL),'MTH','EQUATIONS','PRIVATE_SUB');
   ELSE
      update calculation_version set end_date=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') where object_id=lv_tmp_obj_id and daytime<to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') and NVL(end_date,to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS')+1)>to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS');
   END IF;
   insert into CALCULATION_VERSION (OBJECT_ID,NAME,DAYTIME,END_DATE,MAIN_CALCULATION_ID,IMPL_CALCULATION_ID,COMMENTS,CALC_EVENT_IND,VERSION_BACK_COMPAT)
   values (lv_tmp_obj_id,'Calculate production days and operating days for production wells',to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,EcDp_Objects.getObjIdFromCode('CALCULATION', NULL),EcDp_Objects.getObjIdFromCode('CALCULATION', NULL),'Calculate production days and operating days for production wells',NULL,NULL);

   lv_tmp_obj_id := EcDp_Objects.getObjIdFromCode('CALCULATION','DA954104FA834A529A914AAE5CC8594D');
   IF lv_tmp_obj_id IS NULL THEN
      lv_tmp_obj_id := SYS_GUID();
      insert into CALCULATION (OBJECT_ID,CALC_CONTEXT_ID,OBJECT_CODE,START_DATE,END_DATE,CALC_LIBRARY_ID,CALC_PERIOD,CALC_TYPE,CALC_SCOPE)
      values (lv_tmp_obj_id,EcDp_Objects.getObjIdFromCode('CALC_CONTEXT', 'EC_PROD'),'DA954104FA834A529A914AAE5CC8594D',to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,EcDp_Objects.getObjIdFromCode('CALC_LIBRARY', NULL),'MTH','EQUATIONS','PRIVATE_SUB');
   ELSE
      update calculation_version set end_date=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') where object_id=lv_tmp_obj_id and daytime<to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') and NVL(end_date,to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS')+1)>to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS');
   END IF;
   insert into CALCULATION_VERSION (OBJECT_ID,NAME,DAYTIME,END_DATE,MAIN_CALCULATION_ID,IMPL_CALCULATION_ID,COMMENTS,CALC_EVENT_IND,VERSION_BACK_COMPAT)
   values (lv_tmp_obj_id,'Perform rounding on operating days for production wells',to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,EcDp_Objects.getObjIdFromCode('CALCULATION', NULL),EcDp_Objects.getObjIdFromCode('CALCULATION', NULL),'Perform rounding on operating days for production wells',NULL,NULL);

   lv_tmp_obj_id := EcDp_Objects.getObjIdFromCode('CALCULATION','727E9494B9B940EB922A74AC8F693045');
   IF lv_tmp_obj_id IS NULL THEN
      lv_tmp_obj_id := SYS_GUID();
      insert into CALCULATION (OBJECT_ID,CALC_CONTEXT_ID,OBJECT_CODE,START_DATE,END_DATE,CALC_LIBRARY_ID,CALC_PERIOD,CALC_TYPE,CALC_SCOPE)
      values (lv_tmp_obj_id,EcDp_Objects.getObjIdFromCode('CALC_CONTEXT', 'EC_PROD'),'727E9494B9B940EB922A74AC8F693045',to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,EcDp_Objects.getObjIdFromCode('CALC_LIBRARY', NULL),'MTH','EQUATIONS','PRIVATE_SUB');
   ELSE
      update calculation_version set end_date=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') where object_id=lv_tmp_obj_id and daytime<to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') and NVL(end_date,to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS')+1)>to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS');
   END IF;
   insert into CALCULATION_VERSION (OBJECT_ID,NAME,DAYTIME,END_DATE,MAIN_CALCULATION_ID,IMPL_CALCULATION_ID,COMMENTS,CALC_EVENT_IND,VERSION_BACK_COMPAT)
   values (lv_tmp_obj_id,'Perform rounding on operating days for injection wells',to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,EcDp_Objects.getObjIdFromCode('CALCULATION', NULL),EcDp_Objects.getObjIdFromCode('CALCULATION', NULL),'Perform rounding on operating days for injection wells',NULL,NULL);

   lv_tmp_obj_id := EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR');
   IF lv_tmp_obj_id IS NULL THEN
      lv_tmp_obj_id := SYS_GUID();
      insert into CALCULATION (OBJECT_ID,CALC_CONTEXT_ID,OBJECT_CODE,START_DATE,END_DATE,CALC_LIBRARY_ID,CALC_PERIOD,CALC_TYPE,CALC_SCOPE)
      values (lv_tmp_obj_id,EcDp_Objects.getObjIdFromCode('CALC_CONTEXT', 'EC_PROD'),'CALC_WELL_HR',to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,EcDp_Objects.getObjIdFromCode('CALC_LIBRARY', 'CVX_PROD'),'MTH','PROCESS','PUBLIC_SUB');
   ELSE
      update calculation_version set end_date=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') where object_id=lv_tmp_obj_id and daytime<to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') and NVL(end_date,to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS')+1)>to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS');
   END IF;
   insert into CALCULATION_VERSION (OBJECT_ID,NAME,DAYTIME,END_DATE,MAIN_CALCULATION_ID,IMPL_CALCULATION_ID,COMMENTS,CALC_EVENT_IND,VERSION_BACK_COMPAT)
   values (lv_tmp_obj_id,'Calculate Well Hour',to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,EcDp_Objects.getObjIdFromCode('CALCULATION', NULL),EcDp_Objects.getObjIdFromCode('CALCULATION', NULL),'CVX: Calculate production/injection days and operating days for the month',NULL,NULL);

END;
/

-- Load CALC_VARIABLE_LOCAL (CALC_VARIABLE_LOCAL)
BEGIN
   NULL;
END;
/

-- Load CALC_SET
BEGIN
   insert into CALC_SET (OBJECT_ID,DAYTIME,CALC_SET_NAME,CALC_CONTEXT_ID,CALC_OBJECT_TYPE_CODE,CALC_SET_TYPE,UNVERSIONED,SORT_ORDER,SORT_BY_SQL_SYNTAX,DESCRIPTION_OVERRIDE,SET_OPERATOR,BASE_CALC_SET_NAME)
   values (EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR'),to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),'prodWellNodes',EcDp_Objects.getObjIdFromCode('CALC_CONTEXT', 'EC_PROD'),'ALLOC_NODE','EQUATIONS',NULL,NULL,NULL,NULL,NULL,NULL);
   insert into CALC_SET (OBJECT_ID,DAYTIME,CALC_SET_NAME,CALC_CONTEXT_ID,CALC_OBJECT_TYPE_CODE,CALC_SET_TYPE,UNVERSIONED,SORT_ORDER,SORT_BY_SQL_SYNTAX,DESCRIPTION_OVERRIDE,SET_OPERATOR,BASE_CALC_SET_NAME)
   values (EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR'),to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),'m',EcDp_Objects.getObjIdFromCode('CALC_CONTEXT', 'EC_PROD'),'MTH','LIBRARY_INHERITED',NULL,NULL,NULL,'Month',NULL,NULL);
   insert into CALC_SET (OBJECT_ID,DAYTIME,CALC_SET_NAME,CALC_CONTEXT_ID,CALC_OBJECT_TYPE_CODE,CALC_SET_TYPE,UNVERSIONED,SORT_ORDER,SORT_BY_SQL_SYNTAX,DESCRIPTION_OVERRIDE,SET_OPERATOR,BASE_CALC_SET_NAME)
   values (EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR'),to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),'injWellTypes',EcDp_Objects.getObjIdFromCode('CALC_CONTEXT', 'EC_PROD'),'LITERAL(INJECTION_TYPE)','EQUATIONS',NULL,NULL,NULL,NULL,NULL,NULL);
   insert into CALC_SET (OBJECT_ID,DAYTIME,CALC_SET_NAME,CALC_CONTEXT_ID,CALC_OBJECT_TYPE_CODE,CALC_SET_TYPE,UNVERSIONED,SORT_ORDER,SORT_BY_SQL_SYNTAX,DESCRIPTION_OVERRIDE,SET_OPERATOR,BASE_CALC_SET_NAME)
   values (EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR'),to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),'injWellNodes',EcDp_Objects.getObjIdFromCode('CALC_CONTEXT', 'EC_PROD'),'ALLOC_NODE','EQUATIONS',NULL,NULL,NULL,NULL,NULL,NULL);
   insert into CALC_SET (OBJECT_ID,DAYTIME,CALC_SET_NAME,CALC_CONTEXT_ID,CALC_OBJECT_TYPE_CODE,CALC_SET_TYPE,UNVERSIONED,SORT_ORDER,SORT_BY_SQL_SYNTAX,DESCRIPTION_OVERRIDE,SET_OPERATOR,BASE_CALC_SET_NAME)
   values (EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR'),to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),'injTypes',EcDp_Objects.getObjIdFromCode('CALC_CONTEXT', 'EC_PROD'),'LITERAL(INJECTION_TYPE)','EQUATIONS',NULL,NULL,NULL,NULL,NULL,NULL);
   insert into CALC_SET (OBJECT_ID,DAYTIME,CALC_SET_NAME,CALC_CONTEXT_ID,CALC_OBJECT_TYPE_CODE,CALC_SET_TYPE,UNVERSIONED,SORT_ORDER,SORT_BY_SQL_SYNTAX,DESCRIPTION_OVERRIDE,SET_OPERATOR,BASE_CALC_SET_NAME)
   values (EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR'),to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),'daysInMonth',EcDp_Objects.getObjIdFromCode('CALC_CONTEXT', 'EC_PROD'),'DAY','LIBRARY_INHERITED',NULL,NULL,NULL,'Days in month',NULL,NULL);
   insert into CALC_SET (OBJECT_ID,DAYTIME,CALC_SET_NAME,CALC_CONTEXT_ID,CALC_OBJECT_TYPE_CODE,CALC_SET_TYPE,UNVERSIONED,SORT_ORDER,SORT_BY_SQL_SYNTAX,DESCRIPTION_OVERRIDE,SET_OPERATOR,BASE_CALC_SET_NAME)
   values (EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR'),to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),'WellStreams',EcDp_Objects.getObjIdFromCode('CALC_CONTEXT', 'EC_PROD'),'ALLOC_STREAM','LIBRARY_INHERITED',NULL,NULL,NULL,'Well Streams',NULL,NULL);
   insert into CALC_SET (OBJECT_ID,DAYTIME,CALC_SET_NAME,CALC_CONTEXT_ID,CALC_OBJECT_TYPE_CODE,CALC_SET_TYPE,UNVERSIONED,SORT_ORDER,SORT_BY_SQL_SYNTAX,DESCRIPTION_OVERRIDE,SET_OPERATOR,BASE_CALC_SET_NAME)
   values (EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR'),to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),'WellNodes',EcDp_Objects.getObjIdFromCode('CALC_CONTEXT', 'EC_PROD'),'ALLOC_NODE','LIBRARY_INHERITED',NULL,NULL,NULL,'Well Nodes',NULL,NULL);

END;
/

-- Load CALC_PARAMETER
BEGIN
   NULL;
END;
/

-- Load CALC_SET_CONDITION (CALC_SET_CONDITION)
BEGIN
   NULL;
END;
/

-- Load CALC_SET_COMBINATION (CALC_SET_COMBINATION)
BEGIN
   NULL;
END;
/

-- Load CALC_SET_EQUATION (CALC_SET_EQUATION)
BEGIN
   insert into CALC_SET_EQUATION (OBJECT_ID,DAYTIME,CALC_SET_NAME,SEQ_NO,EXEC_ORDER,DISABLED_IND)
   values (EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR'),to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),'injTypes',NULL,1,NULL);

   insert into CALC_SET_EQUATION (OBJECT_ID,DAYTIME,CALC_SET_NAME,SEQ_NO,EXEC_ORDER,DISABLED_IND)
   values (EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR'),to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),'injWellNodes',NULL,1,NULL);

   insert into CALC_SET_EQUATION (OBJECT_ID,DAYTIME,CALC_SET_NAME,SEQ_NO,EXEC_ORDER,DISABLED_IND)
   values (EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR'),to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),'injWellTypes',NULL,1,NULL);

   insert into CALC_SET_EQUATION (OBJECT_ID,DAYTIME,CALC_SET_NAME,SEQ_NO,EXEC_ORDER,DISABLED_IND)
   values (EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR'),to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),'prodWellNodes',NULL,1,NULL);

END;
/

-- Load CALC_EQUATION (CALC_EQUATION)
BEGIN
   insert into CALC_EQUATION (OBJECT_ID,DAYTIME,SEQ_NO,EXEC_ORDER,DISABLED_IND)
   values (EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18'),to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,1,NULL);

   insert into CALC_EQUATION (OBJECT_ID,DAYTIME,SEQ_NO,EXEC_ORDER,DISABLED_IND)
   values (EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18'),to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,3,NULL);

   insert into CALC_EQUATION (OBJECT_ID,DAYTIME,SEQ_NO,EXEC_ORDER,DISABLED_IND)
   values (EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18'),to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,2,'N');

   insert into CALC_EQUATION (OBJECT_ID,DAYTIME,SEQ_NO,EXEC_ORDER,DISABLED_IND)
   values (EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF'),to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,1,NULL);

   insert into CALC_EQUATION (OBJECT_ID,DAYTIME,SEQ_NO,EXEC_ORDER,DISABLED_IND)
   values (EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF'),to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,3,NULL);

   insert into CALC_EQUATION (OBJECT_ID,DAYTIME,SEQ_NO,EXEC_ORDER,DISABLED_IND)
   values (EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF'),to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,2,'N');

   insert into CALC_EQUATION (OBJECT_ID,DAYTIME,SEQ_NO,EXEC_ORDER,DISABLED_IND)
   values (EcDp_Objects.getObjIdFromCode('CALCULATION','DA954104FA834A529A914AAE5CC8594D'),to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,1,NULL);

   insert into CALC_EQUATION (OBJECT_ID,DAYTIME,SEQ_NO,EXEC_ORDER,DISABLED_IND)
   values (EcDp_Objects.getObjIdFromCode('CALCULATION','727E9494B9B940EB922A74AC8F693045'),to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,1,NULL);

END;
/

-- Load CALC_PROCESS_ELEMENT
DECLARE
   lv_tmp_obj_id        VARCHAR2(32);
BEGIN
   lv_tmp_obj_id := SYS_GUID();
   insert into CALC_PROCESS_ELEMENT (OBJECT_ID,OBJECT_CODE,START_DATE,END_DATE,CALCULATION_ID)
   values (lv_tmp_obj_id,'292AF000448097CCE053365A24920301',to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,EcDp_Objects.getObjIdFromCode('CALCULATION', 'CALC_WELL_HR'));
   insert into CALC_PROCESS_ELM_VERSION (OBJECT_ID,NAME,DAYTIME,END_DATE,CALC_PROC_ELM_TYPE,IMPLEMENTING_CALC_ID,COMMENTS,DIAGRAM_LAYOUT_INFO)
   values (lv_tmp_obj_id,'Start',to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,'START',EcDp_Objects.getObjIdFromCode('CALCULATION', NULL),NULL,'bounds={x=20.0;y=20.0;w=100.0;h=60.0}|');

   lv_tmp_obj_id := SYS_GUID();
   insert into CALC_PROCESS_ELEMENT (OBJECT_ID,OBJECT_CODE,START_DATE,END_DATE,CALCULATION_ID)
   values (lv_tmp_obj_id,'292AF000448397CCE053365A24920301',to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,EcDp_Objects.getObjIdFromCode('CALCULATION', 'CALC_WELL_HR'));
   insert into CALC_PROCESS_ELM_VERSION (OBJECT_ID,NAME,DAYTIME,END_DATE,CALC_PROC_ELM_TYPE,IMPLEMENTING_CALC_ID,COMMENTS,DIAGRAM_LAYOUT_INFO)
   values (lv_tmp_obj_id,'Calculate production days and operating days for production wells',to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,'STEP',EcDp_Objects.getObjIdFromCode('CALCULATION', '51B1505F6F984A41B0CB693255A1BDEF'),'Calculate production days and operating days for production wells','bounds={x=160.0;y=0.0;w=100.0;h=100.0}|');

   lv_tmp_obj_id := SYS_GUID();
   insert into CALC_PROCESS_ELEMENT (OBJECT_ID,OBJECT_CODE,START_DATE,END_DATE,CALCULATION_ID)
   values (lv_tmp_obj_id,'292AF000448697CCE053365A24920301',to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,EcDp_Objects.getObjIdFromCode('CALCULATION', 'CALC_WELL_HR'));
   insert into CALC_PROCESS_ELM_VERSION (OBJECT_ID,NAME,DAYTIME,END_DATE,CALC_PROC_ELM_TYPE,IMPLEMENTING_CALC_ID,COMMENTS,DIAGRAM_LAYOUT_INFO)
   values (lv_tmp_obj_id,'Stop',to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,'STOP',EcDp_Objects.getObjIdFromCode('CALCULATION', NULL),NULL,'bounds={x=720.0;y=20.0;w=100.0;h=60.0}|');

   lv_tmp_obj_id := SYS_GUID();
   insert into CALC_PROCESS_ELEMENT (OBJECT_ID,OBJECT_CODE,START_DATE,END_DATE,CALCULATION_ID)
   values (lv_tmp_obj_id,'BB7AAB08AB374027B8DE13A9AF5B3EA1',to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,EcDp_Objects.getObjIdFromCode('CALCULATION', 'CALC_WELL_HR'));
   insert into CALC_PROCESS_ELM_VERSION (OBJECT_ID,NAME,DAYTIME,END_DATE,CALC_PROC_ELM_TYPE,IMPLEMENTING_CALC_ID,COMMENTS,DIAGRAM_LAYOUT_INFO)
   values (lv_tmp_obj_id,'Perform rounding on operating days for injection wells',to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,'STEP',EcDp_Objects.getObjIdFromCode('CALCULATION', '727E9494B9B940EB922A74AC8F693045'),'Perform rounding on operating days for injection wells','bounds={x=580.0;y=0.0;w=100.0;h=100.0}|');

   lv_tmp_obj_id := SYS_GUID();
   insert into CALC_PROCESS_ELEMENT (OBJECT_ID,OBJECT_CODE,START_DATE,END_DATE,CALCULATION_ID)
   values (lv_tmp_obj_id,'E1ADC9B1D6514F82A1C89BD0EE946E1A',to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,EcDp_Objects.getObjIdFromCode('CALCULATION', 'CALC_WELL_HR'));
   insert into CALC_PROCESS_ELM_VERSION (OBJECT_ID,NAME,DAYTIME,END_DATE,CALC_PROC_ELM_TYPE,IMPLEMENTING_CALC_ID,COMMENTS,DIAGRAM_LAYOUT_INFO)
   values (lv_tmp_obj_id,'Calculate production days and operating days for injection wells',to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,'STEP',EcDp_Objects.getObjIdFromCode('CALCULATION', '0B302D55917D40F49A026B62D1445D18'),'Calculate production days and operating days for injection wells','bounds={x=440.0;y=0.0;w=100.0;h=100.0}|');

   lv_tmp_obj_id := SYS_GUID();
   insert into CALC_PROCESS_ELEMENT (OBJECT_ID,OBJECT_CODE,START_DATE,END_DATE,CALCULATION_ID)
   values (lv_tmp_obj_id,'FEB6379773D7411DADFFE5DFE5E1C9F3',to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,EcDp_Objects.getObjIdFromCode('CALCULATION', 'CALC_WELL_HR'));
   insert into CALC_PROCESS_ELM_VERSION (OBJECT_ID,NAME,DAYTIME,END_DATE,CALC_PROC_ELM_TYPE,IMPLEMENTING_CALC_ID,COMMENTS,DIAGRAM_LAYOUT_INFO)
   values (lv_tmp_obj_id,'Perform rounding on operating days for production wells',to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,'STEP',EcDp_Objects.getObjIdFromCode('CALCULATION', 'DA954104FA834A529A914AAE5CC8594D'),'Perform rounding on operating days for production wells','bounds={x=300.0;y=0.0;w=100.0;h=100.0}|');

END;
/

-- Load CALC_PROCESS_TRANSITION
DECLARE
   lv_tmp_obj_id        VARCHAR2(32);
BEGIN
   lv_tmp_obj_id := SYS_GUID();
   insert into CALC_PROCESS_TRANSITION (OBJECT_ID,OBJECT_CODE,START_DATE,END_DATE,CALCULATION_ID)
   values (lv_tmp_obj_id,'292AF000448997CCE053365A24920301',to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,EcDp_Objects.getObjIdFromCode('CALCULATION', 'CALC_WELL_HR'));
   insert into CALC_PROC_TRAN_VERSION (OBJECT_ID,NAME,DAYTIME,END_DATE,DECISION_VALUE,FROM_ELEMENT_ID,TO_ELEMENT_ID,COMMENTS,DIAGRAM_LAYOUT_INFO)
   values (lv_tmp_obj_id,'292AF000448997CCE053365A24920301',to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,NULL,EcDp_Objects.getObjIdFromCode('CALC_PROCESS_ELEMENT', '292AF000448097CCE053365A24920301'),EcDp_Objects.getObjIdFromCode('CALC_PROCESS_ELEMENT', '292AF000448397CCE053365A24920301'),NULL,'|fp=R;tp=L;');

   lv_tmp_obj_id := SYS_GUID();
   insert into CALC_PROCESS_TRANSITION (OBJECT_ID,OBJECT_CODE,START_DATE,END_DATE,CALCULATION_ID)
   values (lv_tmp_obj_id,'292AF000448C97CCE053365A24920301',to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,EcDp_Objects.getObjIdFromCode('CALCULATION', 'CALC_WELL_HR'));
   insert into CALC_PROC_TRAN_VERSION (OBJECT_ID,NAME,DAYTIME,END_DATE,DECISION_VALUE,FROM_ELEMENT_ID,TO_ELEMENT_ID,COMMENTS,DIAGRAM_LAYOUT_INFO)
   values (lv_tmp_obj_id,'292AF000448C97CCE053365A24920301',to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,NULL,EcDp_Objects.getObjIdFromCode('CALC_PROCESS_ELEMENT', '292AF000448397CCE053365A24920301'),EcDp_Objects.getObjIdFromCode('CALC_PROCESS_ELEMENT', 'FEB6379773D7411DADFFE5DFE5E1C9F3'),NULL,'|fp=R;tp=L');

   lv_tmp_obj_id := SYS_GUID();
   insert into CALC_PROCESS_TRANSITION (OBJECT_ID,OBJECT_CODE,START_DATE,END_DATE,CALCULATION_ID)
   values (lv_tmp_obj_id,'0B94139DDFB14B27A7562E1B90937003',to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,EcDp_Objects.getObjIdFromCode('CALCULATION', 'CALC_WELL_HR'));
   insert into CALC_PROC_TRAN_VERSION (OBJECT_ID,NAME,DAYTIME,END_DATE,DECISION_VALUE,FROM_ELEMENT_ID,TO_ELEMENT_ID,COMMENTS,DIAGRAM_LAYOUT_INFO)
   values (lv_tmp_obj_id,'0B94139DDFB14B27A7562E1B90937003',to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,NULL,EcDp_Objects.getObjIdFromCode('CALC_PROCESS_ELEMENT', 'FEB6379773D7411DADFFE5DFE5E1C9F3'),EcDp_Objects.getObjIdFromCode('CALC_PROCESS_ELEMENT', 'E1ADC9B1D6514F82A1C89BD0EE946E1A'),NULL,'|fp=R;tp=L');

   lv_tmp_obj_id := SYS_GUID();
   insert into CALC_PROCESS_TRANSITION (OBJECT_ID,OBJECT_CODE,START_DATE,END_DATE,CALCULATION_ID)
   values (lv_tmp_obj_id,'5ECE5CA8EB144DE9A8A0892F423364C3',to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,EcDp_Objects.getObjIdFromCode('CALCULATION', 'CALC_WELL_HR'));
   insert into CALC_PROC_TRAN_VERSION (OBJECT_ID,NAME,DAYTIME,END_DATE,DECISION_VALUE,FROM_ELEMENT_ID,TO_ELEMENT_ID,COMMENTS,DIAGRAM_LAYOUT_INFO)
   values (lv_tmp_obj_id,'5ECE5CA8EB144DE9A8A0892F423364C3',to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,NULL,EcDp_Objects.getObjIdFromCode('CALC_PROCESS_ELEMENT', 'E1ADC9B1D6514F82A1C89BD0EE946E1A'),EcDp_Objects.getObjIdFromCode('CALC_PROCESS_ELEMENT', 'BB7AAB08AB374027B8DE13A9AF5B3EA1'),NULL,'|fp=R;tp=L');

   lv_tmp_obj_id := SYS_GUID();
   insert into CALC_PROCESS_TRANSITION (OBJECT_ID,OBJECT_CODE,START_DATE,END_DATE,CALCULATION_ID)
   values (lv_tmp_obj_id,'C2B3950D82F942A78A6F47715F47B4E2',to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,EcDp_Objects.getObjIdFromCode('CALCULATION', 'CALC_WELL_HR'));
   insert into CALC_PROC_TRAN_VERSION (OBJECT_ID,NAME,DAYTIME,END_DATE,DECISION_VALUE,FROM_ELEMENT_ID,TO_ELEMENT_ID,COMMENTS,DIAGRAM_LAYOUT_INFO)
   values (lv_tmp_obj_id,'C2B3950D82F942A78A6F47715F47B4E2',to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,NULL,EcDp_Objects.getObjIdFromCode('CALC_PROCESS_ELEMENT', 'BB7AAB08AB374027B8DE13A9AF5B3EA1'),EcDp_Objects.getObjIdFromCode('CALC_PROCESS_ELEMENT', '292AF000448697CCE053365A24920301'),NULL,'|fp=R;tp=L');

END;
/

-- Load CALC_PROC_ELM_ITERATION (CALC_PROC_ELM_ITERATION)
BEGIN
   insert into CALC_PROC_ELM_ITERATION (OBJECT_ID,DAYTIME,SEQ_NO,CALCULATION_ID,ITERATOR_NAME,CALC_SET_NAME,ITERATION_TYPE)
   values (EcDp_Objects.getObjIdFromCode('CALC_PROCESS_ELEMENT','292AF000448397CCE053365A24920301'),to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,EcDp_Objects.getObjIdFromCode('CALCULATION', 'CALC_WELL_HR'),'dm','daysInMonth',NULL);

   insert into CALC_PROC_ELM_ITERATION (OBJECT_ID,DAYTIME,SEQ_NO,CALCULATION_ID,ITERATOR_NAME,CALC_SET_NAME,ITERATION_TYPE)
   values (EcDp_Objects.getObjIdFromCode('CALC_PROCESS_ELEMENT','292AF000448397CCE053365A24920301'),to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,EcDp_Objects.getObjIdFromCode('CALCULATION', 'CALC_WELL_HR'),'n','prodWellNodes',NULL);

   insert into CALC_PROC_ELM_ITERATION (OBJECT_ID,DAYTIME,SEQ_NO,CALCULATION_ID,ITERATOR_NAME,CALC_SET_NAME,ITERATION_TYPE)
   values (EcDp_Objects.getObjIdFromCode('CALC_PROCESS_ELEMENT','BB7AAB08AB374027B8DE13A9AF5B3EA1'),to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,EcDp_Objects.getObjIdFromCode('CALCULATION', 'CALC_WELL_HR'),'t','injWellTypes',NULL);

   insert into CALC_PROC_ELM_ITERATION (OBJECT_ID,DAYTIME,SEQ_NO,CALCULATION_ID,ITERATOR_NAME,CALC_SET_NAME,ITERATION_TYPE)
   values (EcDp_Objects.getObjIdFromCode('CALC_PROCESS_ELEMENT','BB7AAB08AB374027B8DE13A9AF5B3EA1'),to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,EcDp_Objects.getObjIdFromCode('CALCULATION', 'CALC_WELL_HR'),'n','injWellNodes',NULL);

   insert into CALC_PROC_ELM_ITERATION (OBJECT_ID,DAYTIME,SEQ_NO,CALCULATION_ID,ITERATOR_NAME,CALC_SET_NAME,ITERATION_TYPE)
   values (EcDp_Objects.getObjIdFromCode('CALC_PROCESS_ELEMENT','E1ADC9B1D6514F82A1C89BD0EE946E1A'),to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,EcDp_Objects.getObjIdFromCode('CALCULATION', 'CALC_WELL_HR'),'t','injWellTypes',NULL);

   insert into CALC_PROC_ELM_ITERATION (OBJECT_ID,DAYTIME,SEQ_NO,CALCULATION_ID,ITERATOR_NAME,CALC_SET_NAME,ITERATION_TYPE)
   values (EcDp_Objects.getObjIdFromCode('CALC_PROCESS_ELEMENT','E1ADC9B1D6514F82A1C89BD0EE946E1A'),to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,EcDp_Objects.getObjIdFromCode('CALCULATION', 'CALC_WELL_HR'),'dm','daysInMonth',NULL);

   insert into CALC_PROC_ELM_ITERATION (OBJECT_ID,DAYTIME,SEQ_NO,CALCULATION_ID,ITERATOR_NAME,CALC_SET_NAME,ITERATION_TYPE)
   values (EcDp_Objects.getObjIdFromCode('CALC_PROCESS_ELEMENT','E1ADC9B1D6514F82A1C89BD0EE946E1A'),to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,EcDp_Objects.getObjIdFromCode('CALCULATION', 'CALC_WELL_HR'),'n','injWellNodes',NULL);

   insert into CALC_PROC_ELM_ITERATION (OBJECT_ID,DAYTIME,SEQ_NO,CALCULATION_ID,ITERATOR_NAME,CALC_SET_NAME,ITERATION_TYPE)
   values (EcDp_Objects.getObjIdFromCode('CALC_PROCESS_ELEMENT','FEB6379773D7411DADFFE5DFE5E1C9F3'),to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS'),NULL,EcDp_Objects.getObjIdFromCode('CALCULATION', 'CALC_WELL_HR'),'n','prodWellNodes',NULL);

END;
/

-- Loading calc_set_equation.description with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injTypes' AND exec_order=1
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_set_equation set description=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injTypes' AND exec_order=1;

   select description into lob from calc_set_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injTypes' AND exec_order=1;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);


   dbms_lob.close(lob);
END;
/

-- Loading calc_set_equation.iterations with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injTypes' AND exec_order=1
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_set_equation set iterations=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injTypes' AND exec_order=1;

   select iterations into lob from calc_set_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injTypes' AND exec_order=1;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);


   dbms_lob.close(lob);
END;
/

-- Loading calc_set_equation.condition with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injTypes' AND exec_order=1
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_set_equation set condition=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injTypes' AND exec_order=1;

   select condition into lob from calc_set_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injTypes' AND exec_order=1;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);


   dbms_lob.close(lob);
END;
/

-- Loading calc_set_equation.equation with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injTypes' AND exec_order=1
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_set_equation set equation=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injTypes' AND exec_order=1;

   select equation into lob from calc_set_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injTypes' AND exec_order=1;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);

   dbms_lob.writeappend(lob, 764, '<m:math xmlns:m="http://www.w3.org/1998/Math/MathML"><m:apply><m:eq /><m:ci type="set">injTypes</m:ci><m:set><m:condition><m:apply><m:gt /><m:apply><m:csymbol definitionURL="http:#" encoding="text">objectCount</m:csymbol><m:set><m:condition><m:apply><m:csymbol definitionURL="http:#" encoding="text">classeq</m:csymbol><m:apply><m:selector /><m:ci type="attribute" object-type="ALLOC_STREAM">ToNode</m:ci><m:ci type="iterator">s</m:ci></m:apply><m:ci type="iterator">n</m:ci></m:apply></m:condition><m:apply><m:in /><m:ci type="iterator">s</m:ci><m:ci type="set">WellStreams</m:ci></m:apply></m:set></m:apply><m:cn>0</m:cn></m:apply></m:condition><m:apply><m:in /><m:ci type="iterator">n</m:ci><m:ci type="set">WellNodes</m:ci></m:apply></m:set></m:apply></m:math>');

   dbms_lob.close(lob);
END;
/

-- Loading calc_set_equation.description with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injWellNodes' AND exec_order=1
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_set_equation set description=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injWellNodes' AND exec_order=1;

   select description into lob from calc_set_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injWellNodes' AND exec_order=1;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);


   dbms_lob.close(lob);
END;
/

-- Loading calc_set_equation.iterations with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injWellNodes' AND exec_order=1
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_set_equation set iterations=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injWellNodes' AND exec_order=1;

   select iterations into lob from calc_set_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injWellNodes' AND exec_order=1;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);


   dbms_lob.close(lob);
END;
/

-- Loading calc_set_equation.condition with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injWellNodes' AND exec_order=1
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_set_equation set condition=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injWellNodes' AND exec_order=1;

   select condition into lob from calc_set_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injWellNodes' AND exec_order=1;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);


   dbms_lob.close(lob);
END;
/

-- Loading calc_set_equation.equation with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injWellNodes' AND exec_order=1
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_set_equation set equation=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injWellNodes' AND exec_order=1;

   select equation into lob from calc_set_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injWellNodes' AND exec_order=1;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);

   dbms_lob.writeappend(lob, 152, '<m:math xmlns:m="http://www.w3.org/1998/Math/MathML"><m:apply><m:eq /><m:ci type="set">injWellNodes</m:ci><m:ci type="empty">?</m:ci></m:apply></m:math>');

   dbms_lob.close(lob);
END;
/

-- Loading calc_set_equation.description with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injWellTypes' AND exec_order=1
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_set_equation set description=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injWellTypes' AND exec_order=1;

   select description into lob from calc_set_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injWellTypes' AND exec_order=1;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);


   dbms_lob.close(lob);
END;
/

-- Loading calc_set_equation.iterations with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injWellTypes' AND exec_order=1
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_set_equation set iterations=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injWellTypes' AND exec_order=1;

   select iterations into lob from calc_set_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injWellTypes' AND exec_order=1;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);


   dbms_lob.close(lob);
END;
/

-- Loading calc_set_equation.condition with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injWellTypes' AND exec_order=1
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_set_equation set condition=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injWellTypes' AND exec_order=1;

   select condition into lob from calc_set_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injWellTypes' AND exec_order=1;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);


   dbms_lob.close(lob);
END;
/

-- Loading calc_set_equation.equation with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injWellTypes' AND exec_order=1
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_set_equation set equation=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injWellTypes' AND exec_order=1;

   select equation into lob from calc_set_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='injWellTypes' AND exec_order=1;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);

   dbms_lob.writeappend(lob, 821, '<m:math xmlns:m="http://www.w3.org/1998/Math/MathML"><m:apply><m:eq /><m:ci type="set">injWellTypes</m:ci><m:set><m:condition><m:apply><m:gt /><m:apply><m:csymbol definitionURL="http:#" encoding="text">objectCount</m:csymbol><m:apply><m:csymbol definitionURL="http:#" encoding="text">args</m:csymbol><m:apply><m:selector /><m:ci type="variable">OnStrmHrs[ALLOC_NODE,DAY,LITERAL(INJECTION_TYPE)]</m:ci><m:apply><m:in /><m:ci type="iterator">n</m:ci><m:ci type="set">injWellNodes</m:ci></m:apply><m:apply><m:in /><m:ci type="iterator">dm</m:ci><m:ci type="set">*</m:ci></m:apply><m:ci type="iterator">t</m:ci></m:apply><m:ci type="iterator">n</m:ci></m:apply></m:apply><m:cn>0</m:cn></m:apply></m:condition><m:apply><m:in /><m:ci type="iterator">t</m:ci><m:ci type="set">injTypes</m:ci></m:apply></m:set></m:apply></m:math>');

   dbms_lob.close(lob);
END;
/

-- Loading calc_set_equation.description with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='prodWellNodes' AND exec_order=1
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_set_equation set description=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='prodWellNodes' AND exec_order=1;

   select description into lob from calc_set_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='prodWellNodes' AND exec_order=1;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);


   dbms_lob.close(lob);
END;
/

-- Loading calc_set_equation.iterations with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='prodWellNodes' AND exec_order=1
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_set_equation set iterations=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='prodWellNodes' AND exec_order=1;

   select iterations into lob from calc_set_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='prodWellNodes' AND exec_order=1;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);


   dbms_lob.close(lob);
END;
/

-- Loading calc_set_equation.condition with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='prodWellNodes' AND exec_order=1
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_set_equation set condition=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='prodWellNodes' AND exec_order=1;

   select condition into lob from calc_set_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='prodWellNodes' AND exec_order=1;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);


   dbms_lob.close(lob);
END;
/

-- Loading calc_set_equation.equation with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='prodWellNodes' AND exec_order=1
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_set_equation set equation=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='prodWellNodes' AND exec_order=1;

   select equation into lob from calc_set_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','CALC_WELL_HR') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND calc_set_name='prodWellNodes' AND exec_order=1;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);

   dbms_lob.writeappend(lob, 771, '<m:math xmlns:m="http://www.w3.org/1998/Math/MathML"><m:apply><m:eq /><m:ci type="set">prodWellNodes</m:ci><m:set><m:condition><m:apply><m:gt /><m:apply><m:csymbol definitionURL="http:#" encoding="text">objectCount</m:csymbol><m:set><m:condition><m:apply><m:csymbol definitionURL="http:#" encoding="text">classeq</m:csymbol><m:apply><m:selector /><m:ci type="attribute" object-type="ALLOC_STREAM">FromNode</m:ci><m:ci type="iterator">s</m:ci></m:apply><m:ci type="iterator">n</m:ci></m:apply></m:condition><m:apply><m:in /><m:ci type="iterator">s</m:ci><m:ci type="set">WellStreams</m:ci></m:apply></m:set></m:apply><m:cn>0</m:cn></m:apply></m:condition><m:apply><m:in /><m:ci type="iterator">n</m:ci><m:ci type="set">WellNodes</m:ci></m:apply></m:set></m:apply></m:math>');

   dbms_lob.close(lob);
END;
/

-- Loading calc_equation.description with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_equation set description=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1;

   select description into lob from calc_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);

   dbms_lob.writeappend(lob, 45, 'Sum of onsteam hrs divided by 24 (over month)');

   dbms_lob.close(lob);
END;
/

-- Loading calc_equation.iterations with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_equation set iterations=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1;

   select iterations into lob from calc_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);


   dbms_lob.close(lob);
END;
/

-- Loading calc_equation.condition with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_equation set condition=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1;

   select condition into lob from calc_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);

   dbms_lob.writeappend(lob, 352, '<m:math xmlns:m="http://www.w3.org/1998/Math/MathML"><m:apply><m:csymbol definitionURL="http:#" encoding="text">isValid</m:csymbol><m:apply><m:selector /><m:ci type="variable">OnStrmHrs[ALLOC_NODE,DAY,LITERAL(INJECTION_TYPE)]</m:ci><m:ci type="iterator">n</m:ci><m:ci type="iterator">dm</m:ci><m:ci type="iterator">t</m:ci></m:apply></m:apply></m:math>');

   dbms_lob.close(lob);
END;
/

-- Loading calc_equation.equation with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_equation set equation=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1;

   select equation into lob from calc_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);

   dbms_lob.writeappend(lob, 844, '<m:math xmlns:m="http://www.w3.org/1998/Math/MathML"><m:apply><m:eq /><m:apply><m:selector /><m:ci type="variable">Opr_OnStrmDays[ALLOC_NODE,MTH,LITERAL(INJECTION_TYPE)]</m:ci><m:ci type="iterator">n</m:ci><m:ci type="set">m</m:ci><m:ci type="iterator">t</m:ci></m:apply><m:apply><m:plus /><m:apply><m:selector /><m:ci type="variable">Opr_OnStrmDays[ALLOC_NODE,MTH,LITERAL(INJECTION_TYPE)]</m:ci><m:ci type="iterator">n</m:ci><m:ci type="set">m</m:ci><m:ci type="iterator">t</m:ci></m:apply><m:apply xmlns:ecm="http://www.tietoenator.com/ec/alloc/MathMLEditor" ecm:fence="()"><m:divide /><m:apply><m:selector /><m:ci type="variable">OnStrmHrs[ALLOC_NODE,DAY,LITERAL(INJECTION_TYPE)]</m:ci><m:ci type="iterator">n</m:ci><m:ci type="iterator">dm</m:ci><m:ci type="iterator">t</m:ci></m:apply><m:cn>24</m:cn></m:apply></m:apply></m:apply></m:math>');

   dbms_lob.close(lob);
END;
/

-- Loading calc_equation.description with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=3
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_equation set description=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=3;

   select description into lob from calc_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=3;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);

   dbms_lob.writeappend(lob, 47, 'Calculate the number of days with any injection');

   dbms_lob.close(lob);
END;
/

-- Loading calc_equation.iterations with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=3
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_equation set iterations=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=3;

   select iterations into lob from calc_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=3;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);


   dbms_lob.close(lob);
END;
/

-- Loading calc_equation.condition with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=3
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_equation set condition=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=3;

   select condition into lob from calc_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=3;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);

   dbms_lob.writeappend(lob, 623, '<m:math xmlns:m="http://www.w3.org/1998/Math/MathML"><m:apply><m:and /><m:apply><m:csymbol definitionURL="http:#" encoding="text">isValid</m:csymbol><m:apply><m:selector /><m:ci type="variable">OnStrmHrs[ALLOC_NODE,DAY,LITERAL(INJECTION_TYPE)]</m:ci><m:ci type="iterator">n</m:ci><m:ci type="iterator">dm</m:ci><m:ci type="iterator">t</m:ci></m:apply></m:apply><m:apply><m:gt /><m:apply><m:selector /><m:ci type="variable">OnStrmHrs[ALLOC_NODE,DAY,LITERAL(INJECTION_TYPE)]</m:ci><m:ci type="iterator">n</m:ci><m:ci type="iterator">dm</m:ci><m:ci type="iterator">t</m:ci></m:apply><m:cn>0</m:cn></m:apply></m:apply></m:math>');

   dbms_lob.close(lob);
END;
/

-- Loading calc_equation.equation with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=3
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_equation set equation=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=3;

   select equation into lob from calc_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=3;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);

   dbms_lob.writeappend(lob, 526, '<m:math xmlns:m="http://www.w3.org/1998/Math/MathML"><m:apply><m:eq /><m:apply><m:selector /><m:ci type="variable">OnStrmDays[ALLOC_NODE,MTH,LITERAL(INJECTION_TYPE)]</m:ci><m:ci type="iterator">n</m:ci><m:ci type="set">m</m:ci><m:ci type="iterator">t</m:ci></m:apply><m:apply><m:plus /><m:apply><m:selector /><m:ci type="variable">OnStrmDays[ALLOC_NODE,MTH,LITERAL(INJECTION_TYPE)]</m:ci><m:ci type="iterator">n</m:ci><m:ci type="set">m</m:ci><m:ci type="iterator">t</m:ci></m:apply><m:cn>1</m:cn></m:apply></m:apply></m:math>');

   dbms_lob.close(lob);
END;
/

-- Loading calc_equation.description with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=2
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_equation set description=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=2;

   select description into lob from calc_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=2;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);

   dbms_lob.writeappend(lob, 93, 'If on stream hours is zero, counter + 0, this is to handle zero on stream hours to avoid NULL');

   dbms_lob.close(lob);
END;
/

-- Loading calc_equation.iterations with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=2
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_equation set iterations=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=2;

   select iterations into lob from calc_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=2;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);


   dbms_lob.close(lob);
END;
/

-- Loading calc_equation.condition with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=2
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_equation set condition=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=2;

   select condition into lob from calc_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=2;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);

   dbms_lob.writeappend(lob, 619, '<m:math xmlns:m="http://www.w3.org/1998/Math/MathML"><m:apply><m:and/><m:apply><m:csymbol definitionURL="http:#" encoding="text">isValid</m:csymbol><m:apply><m:selector/><m:ci type="variable">OnStrmHrs[ALLOC_NODE,DAY,LITERAL(INJECTION_TYPE)]</m:ci><m:ci type="iterator">n</m:ci><m:ci type="iterator">dm</m:ci><m:ci type="iterator">t</m:ci></m:apply></m:apply><m:apply><m:eq/><m:apply><m:selector/><m:ci type="variable">OnStrmHrs[ALLOC_NODE,DAY,LITERAL(INJECTION_TYPE)]</m:ci><m:ci type="iterator">n</m:ci><m:ci type="iterator">dm</m:ci><m:ci type="iterator">t</m:ci></m:apply><m:cn>0</m:cn></m:apply></m:apply></m:math>');

   dbms_lob.close(lob);
END;
/

-- Loading calc_equation.equation with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=2
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_equation set equation=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=2;

   select equation into lob from calc_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','0B302D55917D40F49A026B62D1445D18') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=2;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);

   dbms_lob.writeappend(lob, 522, '<m:math xmlns:m="http://www.w3.org/1998/Math/MathML"><m:apply><m:eq/><m:apply><m:selector/><m:ci type="variable">OnStrmDays[ALLOC_NODE,MTH,LITERAL(INJECTION_TYPE)]</m:ci><m:ci type="iterator">n</m:ci><m:ci type="set">m</m:ci><m:ci type="iterator">t</m:ci></m:apply><m:apply><m:plus/><m:apply><m:selector/><m:ci type="variable">OnStrmDays[ALLOC_NODE,MTH,LITERAL(INJECTION_TYPE)]</m:ci><m:ci type="iterator">n</m:ci><m:ci type="set">m</m:ci><m:ci type="iterator">t</m:ci></m:apply><m:cn>0</m:cn></m:apply></m:apply></m:math>');

   dbms_lob.close(lob);
END;
/

-- Loading calc_equation.description with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_equation set description=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1;

   select description into lob from calc_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);

   dbms_lob.writeappend(lob, 44, 'Sum of onSteamHrs divided by 24 (over month)');

   dbms_lob.close(lob);
END;
/

-- Loading calc_equation.iterations with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_equation set iterations=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1;

   select iterations into lob from calc_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);


   dbms_lob.close(lob);
END;
/

-- Loading calc_equation.condition with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_equation set condition=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1;

   select condition into lob from calc_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);

   dbms_lob.writeappend(lob, 298, '<m:math xmlns:m="http://www.w3.org/1998/Math/MathML"><m:apply><m:csymbol definitionURL="http:#" encoding="text">isValid</m:csymbol><m:apply><m:selector /><m:ci type="variable">OnStrmHrs[ALLOC_NODE,DAY]</m:ci><m:ci type="iterator">n</m:ci><m:ci type="iterator">dm</m:ci></m:apply></m:apply></m:math>');

   dbms_lob.close(lob);
END;
/

-- Loading calc_equation.equation with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_equation set equation=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1;

   select equation into lob from calc_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);

   dbms_lob.writeappend(lob, 682, '<m:math xmlns:m="http://www.w3.org/1998/Math/MathML"><m:apply><m:eq /><m:apply><m:selector /><m:ci type="variable">Opr_OnStrmDays[ALLOC_NODE,MTH]</m:ci><m:ci type="iterator">n</m:ci><m:ci type="set">m</m:ci></m:apply><m:apply><m:plus /><m:apply><m:selector /><m:ci type="variable">Opr_OnStrmDays[ALLOC_NODE,MTH]</m:ci><m:ci type="iterator">n</m:ci><m:ci type="set">m</m:ci></m:apply><m:apply xmlns:ecm="http://www.tietoenator.com/ec/alloc/MathMLEditor" ecm:fence="()"><m:divide /><m:apply><m:selector /><m:ci type="variable">OnStrmHrs[ALLOC_NODE,DAY]</m:ci><m:ci type="iterator">n</m:ci><m:ci type="iterator">dm</m:ci></m:apply><m:cn>24</m:cn></m:apply></m:apply></m:apply></m:math>');

   dbms_lob.close(lob);
END;
/

-- Loading calc_equation.description with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=3
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_equation set description=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=3;

   select description into lob from calc_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=3;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);

   dbms_lob.writeappend(lob, 48, 'Calculate the number of days with any production');

   dbms_lob.close(lob);
END;
/

-- Loading calc_equation.iterations with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=3
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_equation set iterations=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=3;

   select iterations into lob from calc_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=3;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);


   dbms_lob.close(lob);
END;
/

-- Loading calc_equation.condition with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=3
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_equation set condition=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=3;

   select condition into lob from calc_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=3;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);

   dbms_lob.writeappend(lob, 515, '<m:math xmlns:m="http://www.w3.org/1998/Math/MathML"><m:apply><m:and /><m:apply><m:csymbol definitionURL="http:#" encoding="text">isValid</m:csymbol><m:apply><m:selector /><m:ci type="variable">OnStrmHrs[ALLOC_NODE,DAY]</m:ci><m:ci type="iterator">n</m:ci><m:ci type="iterator">dm</m:ci></m:apply></m:apply><m:apply><m:gt /><m:apply><m:selector /><m:ci type="variable">OnStrmHrs[ALLOC_NODE,DAY]</m:ci><m:ci type="iterator">n</m:ci><m:ci type="iterator">dm</m:ci></m:apply><m:cn>0</m:cn></m:apply></m:apply></m:math>');

   dbms_lob.close(lob);
END;
/

-- Loading calc_equation.equation with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=3
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_equation set equation=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=3;

   select equation into lob from calc_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=3;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);

   dbms_lob.writeappend(lob, 418, '<m:math xmlns:m="http://www.w3.org/1998/Math/MathML"><m:apply><m:eq /><m:apply><m:selector /><m:ci type="variable">OnStrmDays[ALLOC_NODE,MTH]</m:ci><m:ci type="iterator">n</m:ci><m:ci type="set">m</m:ci></m:apply><m:apply><m:plus /><m:apply><m:selector /><m:ci type="variable">OnStrmDays[ALLOC_NODE,MTH]</m:ci><m:ci type="iterator">n</m:ci><m:ci type="set">m</m:ci></m:apply><m:cn>1</m:cn></m:apply></m:apply></m:math>');

   dbms_lob.close(lob);
END;
/

-- Loading calc_equation.description with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=2
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_equation set description=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=2;

   select description into lob from calc_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=2;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);

   dbms_lob.writeappend(lob, 93, 'If on stream hours is zero, counter + 0, this is to handle zero on stream hours to avoid NULL');

   dbms_lob.close(lob);
END;
/

-- Loading calc_equation.iterations with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=2
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_equation set iterations=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=2;

   select iterations into lob from calc_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=2;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);


   dbms_lob.close(lob);
END;
/

-- Loading calc_equation.condition with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=2
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_equation set condition=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=2;

   select condition into lob from calc_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=2;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);

   dbms_lob.writeappend(lob, 511, '<m:math xmlns:m="http://www.w3.org/1998/Math/MathML"><m:apply><m:and/><m:apply><m:csymbol definitionURL="http:#" encoding="text">isValid</m:csymbol><m:apply><m:selector/><m:ci type="variable">OnStrmHrs[ALLOC_NODE,DAY]</m:ci><m:ci type="iterator">n</m:ci><m:ci type="iterator">dm</m:ci></m:apply></m:apply><m:apply><m:eq/><m:apply><m:selector/><m:ci type="variable">OnStrmHrs[ALLOC_NODE,DAY]</m:ci><m:ci type="iterator">n</m:ci><m:ci type="iterator">dm</m:ci></m:apply><m:cn>0</m:cn></m:apply></m:apply></m:math>');

   dbms_lob.close(lob);
END;
/

-- Loading calc_equation.equation with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=2
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_equation set equation=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=2;

   select equation into lob from calc_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','51B1505F6F984A41B0CB693255A1BDEF') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=2;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);

   dbms_lob.writeappend(lob, 414, '<m:math xmlns:m="http://www.w3.org/1998/Math/MathML"><m:apply><m:eq/><m:apply><m:selector/><m:ci type="variable">OnStrmDays[ALLOC_NODE,MTH]</m:ci><m:ci type="iterator">n</m:ci><m:ci type="set">m</m:ci></m:apply><m:apply><m:plus/><m:apply><m:selector/><m:ci type="variable">OnStrmDays[ALLOC_NODE,MTH]</m:ci><m:ci type="iterator">n</m:ci><m:ci type="set">m</m:ci></m:apply><m:cn>0</m:cn></m:apply></m:apply></m:math>');

   dbms_lob.close(lob);
END;
/

-- Loading calc_equation.description with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','DA954104FA834A529A914AAE5CC8594D') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_equation set description=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','DA954104FA834A529A914AAE5CC8594D') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1;

   select description into lob from calc_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','DA954104FA834A529A914AAE5CC8594D') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);

   dbms_lob.writeappend(lob, 50, 'Perform rounding on the calculated operating days.');

   dbms_lob.close(lob);
END;
/

-- Loading calc_equation.iterations with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','DA954104FA834A529A914AAE5CC8594D') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_equation set iterations=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','DA954104FA834A529A914AAE5CC8594D') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1;

   select iterations into lob from calc_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','DA954104FA834A529A914AAE5CC8594D') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);


   dbms_lob.close(lob);
END;
/

-- Loading calc_equation.condition with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','DA954104FA834A529A914AAE5CC8594D') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_equation set condition=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','DA954104FA834A529A914AAE5CC8594D') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1;

   select condition into lob from calc_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','DA954104FA834A529A914AAE5CC8594D') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);


   dbms_lob.close(lob);
END;
/

-- Loading calc_equation.equation with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','DA954104FA834A529A914AAE5CC8594D') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_equation set equation=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','DA954104FA834A529A914AAE5CC8594D') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1;

   select equation into lob from calc_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','DA954104FA834A529A914AAE5CC8594D') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);

   dbms_lob.writeappend(lob, 469, '<m:math xmlns:m="http://www.w3.org/1998/Math/MathML"><m:apply><m:eq /><m:apply><m:selector /><m:ci type="variable">Opr_OnStrmDays[ALLOC_NODE,MTH]</m:ci><m:ci type="iterator">n</m:ci><m:ci type="set">m</m:ci></m:apply><m:apply><m:csymbol definitionURL="http:#" encoding="text">round</m:csymbol><m:apply><m:selector /><m:ci type="variable">Opr_OnStrmDays[ALLOC_NODE,MTH]</m:ci><m:ci type="iterator">n</m:ci><m:ci type="set">m</m:ci></m:apply></m:apply></m:apply></m:math>');

   dbms_lob.close(lob);
END;
/

-- Loading calc_equation.description with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','727E9494B9B940EB922A74AC8F693045') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_equation set description=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','727E9494B9B940EB922A74AC8F693045') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1;

   select description into lob from calc_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','727E9494B9B940EB922A74AC8F693045') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);

   dbms_lob.writeappend(lob, 50, 'Perform rounding on the calculated operating days.');

   dbms_lob.close(lob);
END;
/

-- Loading calc_equation.iterations with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','727E9494B9B940EB922A74AC8F693045') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_equation set iterations=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','727E9494B9B940EB922A74AC8F693045') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1;

   select iterations into lob from calc_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','727E9494B9B940EB922A74AC8F693045') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);


   dbms_lob.close(lob);
END;
/

-- Loading calc_equation.condition with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','727E9494B9B940EB922A74AC8F693045') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_equation set condition=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','727E9494B9B940EB922A74AC8F693045') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1;

   select condition into lob from calc_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','727E9494B9B940EB922A74AC8F693045') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);


   dbms_lob.close(lob);
END;
/

-- Loading calc_equation.equation with where condition object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','727E9494B9B940EB922A74AC8F693045') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1
DECLARE
   lob        CLOB;
BEGIN
   dbms_lob.createtemporary(lob,true,dbms_lob.session);
   update calc_equation set equation=lob where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','727E9494B9B940EB922A74AC8F693045') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1;

   select equation into lob from calc_equation where object_id=EcDp_Objects.getObjIdFromCode('CALCULATION','727E9494B9B940EB922A74AC8F693045') AND daytime=to_date('1900-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS') AND exec_order=1;
   dbms_lob.open(lob, dbms_lob.lob_readwrite);

   dbms_lob.writeappend(lob, 577, '<m:math xmlns:m="http://www.w3.org/1998/Math/MathML"><m:apply><m:eq /><m:apply><m:selector /><m:ci type="variable">Opr_OnStrmDays[ALLOC_NODE,MTH,LITERAL(INJECTION_TYPE)]</m:ci><m:ci type="iterator">n</m:ci><m:ci type="set">m</m:ci><m:ci type="iterator">t</m:ci></m:apply><m:apply><m:csymbol definitionURL="http:#" encoding="text">round</m:csymbol><m:apply><m:selector /><m:ci type="variable">Opr_OnStrmDays[ALLOC_NODE,MTH,LITERAL(INJECTION_TYPE)]</m:ci><m:ci type="iterator">n</m:ci><m:ci type="set">m</m:ci><m:ci type="iterator">t</m:ci></m:apply></m:apply></m:apply></m:math>');

   dbms_lob.close(lob);
END;
/
