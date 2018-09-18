/*Upgrade tool Precheck*/
ALTER TRIGGER DDL_ECKERNEL DISABLE
--~^UTDELIM^~--
ALTER TABLE CTRL_PINC DROP CONSTRAINT PK_CTRL_PINC DROP INDEX
--~^UTDELIM^~--
ALTER TRIGGER DDL_ECKERNEL ENABLE
--~^UTDELIM^~--

CREATE TABLE TEMP_ASSIGN_ID
(
  tablename VARCHAR2(1000),
  column_name    VARCHAR2(1000), 
  max_id    NUMBER
)
--~^UTDELIM^~--

DECLARE
  CURSOR c_gtcur IS
  SELECT * FROM TEMP_ASSIGN_ID;
  l_cnt NUMBER;
BEGIN
  DELETE FROM TEMP_ASSIGN_ID WHERE 1 = 1;
  BEGIN
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('WELL_EQUIP_DOWNTIME','EVENT_NO',(SELECT MAX(EVENT_NO) FROM WELL_EQUIP_DOWNTIME))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('WELL_EQPM_MASTER_EVENT','MASTER_EVENT_ID',(SELECT MAX(MASTER_EVENT_ID) FROM WELL_EQPM_MASTER_EVENT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('WELL_DEFERMENT_EVENT','WDE_NO',(SELECT MAX(WDE_NO) FROM WELL_DEFERMENT_EVENT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('WELL_DEFERMENT','EVENT_NO',(SELECT MAX(EVENT_NO) FROM WELL_DEFERMENT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('WEBO_PRESS_TEST_GRAD','GRADIENT_SEQ',(SELECT MAX(GRADIENT_SEQ) FROM WEBO_PRESS_TEST_GRAD))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('WEBO_PRESS_TEST','EVENT_NO',(SELECT MAX(EVENT_NO) FROM WEBO_PRESS_TEST))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('T_BASIS_OBJECT','OBJECT_ID',(SELECT MAX(OBJECT_ID) FROM T_BASIS_OBJECT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('T_BASIS_ACCESS','T_BASIS_ACCESS_ID',(SELECT MAX(T_BASIS_ACCESS_ID) FROM T_BASIS_ACCESS))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('TREND_CURVE','TREND_SEGMENT_NO',(SELECT MAX(TREND_SEGMENT_NO) FROM TREND_CURVE))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('TRANS_TEMPLATE','TEMPLATE_NO',(SELECT MAX(TEMPLATE_NO) FROM TRANS_TEMPLATE))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('TRANS_PROCESS_LOG','LOG_SEQ',(SELECT MAX(LOG_SEQ) FROM  TRANS_PROCESS_LOG))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('TRANS_MAPPING','MAPPING_NO',(SELECT MAX(MAPPING_NO) FROM TRANS_MAPPING))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('TRANSACTION_MEASUREMENT','EVENT_NO',(SELECT MAX(EVENT_NO) FROM TRANSACTION_MEASUREMENT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('TASK','TASK_NO',(SELECT MAX(TASK_NO) FROM TASK))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('TANK_ANALYSIS','ANALYSIS_NO',(SELECT MAX(ANALYSIS_NO) FROM TANK_ANALYSIS))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('STRM_TRANSPORT_EVENT','EVENT_NO',(SELECT MAX(EVENT_NO) FROM STRM_TRANSPORT_EVENT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('STRM_FORMULA','FORMULA_NO',(SELECT MAX(FORMULA_NO) FROM STRM_FORMULA))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('STRM_COMPANY_SWAP','SWAP_NO',(SELECT MAX(SWAP_NO) FROM STRM_COMPANY_SWAP))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('STRM_ANALYSIS_EVENT','ANALYSIS_NO',(SELECT MAX(ANALYSIS_NO) FROM STRM_ANALYSIS_EVENT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('STOR_FCST_LIFT_NOM','PARCEL_NO',(SELECT MAX(PARCEL_NO) FROM STOR_FCST_LIFT_NOM))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('STOR_DAY_FIFO_COMP_ALLOC','FIFO_NO',(SELECT MAX(FIFO_NO) FROM STOR_DAY_FIFO_COMP_ALLOC))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('STOR_DAY_FIFO_ALLOC','FIFO_NO',(SELECT MAX(FIFO_NO) FROM STOR_DAY_FIFO_ALLOC))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('STOR_BLEND_BATCH','EVENT_NO',(SELECT MAX(EVENT_NO) FROM STOR_BLEND_BATCH))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('STORAGE_LIFT_NOMINATION','PARCEL_NO',(SELECT MAX(PARCEL_NO) FROM STORAGE_LIFT_NOMINATION))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('STIM_PENDING_ITEM','STIM_PENDING_ITEM_NO',(SELECT MAX(STIM_PENDING_ITEM_NO) FROM STIM_PENDING_ITEM))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('STIM_PENDING','STIM_PENDING_NO',(SELECT MAX(STIM_PENDING_NO) FROM STIM_PENDING))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('STIM_FCST_SETUP','STIM_FCST_NO',(SELECT MAX(STIM_FCST_NO) FROM STIM_FCST_SETUP))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('SCTR_DAY_LIFTING','SEQ_NO',(SELECT MAX(SEQ_NO) FROM SCTR_DAY_LIFTING))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('SCHEDULE','SCHEDULE_NO',(SELECT MAX(SCHEDULE_NO) FROM  SCHEDULE))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('SAILING_ADVICE_MESSAGE','SAILING_MESSAGE_NO',(SELECT MAX(SAILING_MESSAGE_NO) FROM SAILING_ADVICE_MESSAGE))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('REVN_LOG_ITEM','ITEM_NO',(SELECT MAX(ITEM_NO) FROM REVN_LOG_ITEM))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('REVN_LOG','LOG_NO',(SELECT MAX(LOG_NO) FROM REVN_LOG))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('REVN_DATA_FILTER_RULE','FILTER_RULE_NUMBER',(SELECT MAX(FILTER_RULE_NUMBER) FROM REVN_DATA_FILTER_RULE))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('REPT_SET_CONDITION','SEQ_NO',(SELECT MAX(SEQ_NO) FROM REPT_SET_CONDITION))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('REPT_SET_COMBINATION','SEQ_NO',(SELECT MAX(SEQ_NO) FROM REPT_SET_COMBINATION))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('REPORT_SET','REPORT_SET_NO',(SELECT MAX(REPORT_SET_NO) FROM REPORT_SET))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('REPORT_RUNABLE','REPORT_RUNABLE_NO',(SELECT MAX(REPORT_RUNABLE_NO) FROM REPORT_RUNABLE))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('REPORT_DEFINITION','REPORT_DEFINITION_NO',(SELECT MAX(REPORT_DEFINITION_NO) FROM REPORT_DEFINITION))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('REPORT','REPORT_NO',(SELECT MAX(REPORT_NO) FROM REPORT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('RECORD_EVENT','EVENT_NO',(SELECT MAX(EVENT_NO) FROM RECORD_EVENT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('PTST_RESULT','RESULT_NO',(SELECT MAX(RESULT_NO) FROM PTST_RESULT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('PTST_DEFINITION','TEST_NO',(SELECT MAX(TEST_NO) FROM PTST_DEFINITION))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('PROD_FORECAST','FCST_SCEN_NO',(SELECT MAX(FCST_SCEN_NO) FROM PROD_FORECAST))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('PRODUCT_MEAS_SETUP','PRODUCT_MEAS_NO',(SELECT MAX(PRODUCT_MEAS_NO) FROM PRODUCT_MEAS_SETUP))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('PRODUCT_ANALYSIS_ITEM','PAI_NO',(SELECT MAX(PAI_NO) FROM PRODUCT_ANALYSIS_ITEM))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('PROCESS_NOTIFICATION','PROCESS_NOTIFICATION_NO',(SELECT MAX(PROCESS_NOTIFICATION_NO) FROM PROCESS_NOTIFICATION))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('PIPE_PC_TRANSACTION','TRANSACTION_NO',(SELECT MAX(TRANSACTION_NO) FROM PIPE_PC_TRANSACTION))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('PERFORMANCE_CURVE','PERF_CURVE_ID',(SELECT MAX(PERF_CURVE_ID) FROM PERFORMANCE_CURVE))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('PARCEL_NOMINATION','PARCEL_NO',(SELECT MAX(PARCEL_NO) FROM PARCEL_NOMINATION))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('OPPORTUNITY','OPPORTUNITY_NO',(SELECT MAX(OPPORTUNITY_NO) FROM OPPORTUNITY))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('OBJ_FLUID_ANA_DETAIL','ANALYSIS_ITEM',(SELECT MAX(ANALYSIS_ITEM) FROM OBJ_FLUID_ANA_DETAIL))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('OBJLOC_SUB_DAY_NOMINATION','NOMINATION_SEQ',(SELECT MAX(NOMINATION_SEQ) FROM OBJLOC_SUB_DAY_NOMINATION))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('OBJLOC_DAY_NOMINATION','NOMINATION_SEQ',(SELECT MAX(NOMINATION_SEQ) FROM OBJLOC_DAY_NOMINATION))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('OBJECT_TRANSPORT_EVENT','EVENT_NO',(SELECT MAX(EVENT_NO) FROM OBJECT_TRANSPORT_EVENT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('OBJECT_ITEM_COMMENT','COMMENT_ID',(SELECT MAX(COMMENT_ID) FROM OBJECT_ITEM_COMMENT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('OBJECT_FLUID_ANALYSIS','ANALYSIS_NO',(SELECT MAX(ANALYSIS_NO) FROM OBJECT_FLUID_ANALYSIS))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('OBJECT_AGA_ANALYSIS','ANALYSIS_NO',(SELECT MAX(ANALYSIS_NO) FROM OBJECT_AGA_ANALYSIS))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('OBJECTS_DEFERMENT_EVENT','EVENT_ID',(SELECT MAX(EVENT_ID) FROM OBJECTS_DEFERMENT_EVENT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('NOMPNT_SUB_DAY_NOMINATION','NOMINATION_SEQ',(SELECT MAX(NOMINATION_SEQ) FROM NOMPNT_SUB_DAY_NOMINATION))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('NOMPNT_SUB_DAY_EVENT','EVENT_SEQ',(SELECT MAX(EVENT_SEQ) FROM NOMPNT_SUB_DAY_EVENT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('NOMPNT_SUB_DAY_DELIVERY','NOMINATION_SEQ',(SELECT MAX(NOMINATION_SEQ) FROM NOMPNT_SUB_DAY_DELIVERY))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('NOMPNT_SUB_DAY_CONFIRMATION','CONFIRMATION_SEQ',(SELECT MAX(CONFIRMATION_SEQ) FROM NOMPNT_SUB_DAY_CONFIRMATION))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('NOMPNT_PERIOD_EVENT','EVENT_SEQ',(SELECT MAX(EVENT_SEQ) FROM NOMPNT_PERIOD_EVENT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('NOMPNT_MTH_TRANSFER','TRANSFER_SEQ',(SELECT MAX(TRANSFER_SEQ) FROM NOMPNT_MTH_TRANSFER))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('NOMPNT_MTH_NOM','NOMINATION_SEQ',(SELECT MAX(NOMINATION_SEQ) FROM NOMPNT_MTH_NOM))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('NOMPNT_MTH_DELIVERY','NOMINATION_SEQ',(SELECT MAX(NOMINATION_SEQ) FROM NOMPNT_MTH_DELIVERY))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('NOMPNT_DAY_TRANSFER','TRANSFER_SEQ',(SELECT MAX(TRANSFER_SEQ) FROM NOMPNT_DAY_TRANSFER))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('NOMPNT_DAY_NOMINATION','NOMINATION_SEQ',(SELECT MAX(NOMINATION_SEQ) FROM NOMPNT_DAY_NOMINATION))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('NOMPNT_DAY_FORECAST','NOMINATION_SEQ',(SELECT MAX(NOMINATION_SEQ) FROM NOMPNT_DAY_FORECAST))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('NOMPNT_DAY_DELIVERY','NOMINATION_SEQ',(SELECT MAX(NOMINATION_SEQ) FROM NOMPNT_DAY_DELIVERY))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('NOMPNT_DAY_CONFIRMATION','CONFIRMATION_SEQ',(SELECT MAX(CONFIRMATION_SEQ) FROM NOMPNT_DAY_CONFIRMATION))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('NOMLOC_PERIOD_EVENT','EVENT_SEQ',(SELECT MAX(EVENT_SEQ) FROM NOMLOC_PERIOD_EVENT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('METER_ALLOC_METHOD','ALLOC_METHOD_SEQ',(SELECT MAX(ALLOC_METHOD_SEQ) FROM METER_ALLOC_METHOD))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('MESSAGE_WORKFLOW_ALERT','ALERT_NO',(SELECT MAX(ALERT_NO) FROM MESSAGE_WORKFLOW_ALERT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('MESSAGE_TEMPLATE','TEMPLATE_NO',(SELECT MAX(TEMPLATE_NO) FROM MESSAGE_TEMPLATE))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('MESSAGE_OUT','MESSAGE_NO',(SELECT MAX(MESSAGE_NO) FROM MESSAGE_OUT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('MESSAGE_DISTRIBUTION','MESSAGE_DISTRIBUTION_NO',(SELECT MAX(MESSAGE_DISTRIBUTION_NO) FROM MESSAGE_DISTRIBUTION))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('MESSAGE_ATTACHMENT','ATTACHMENT_NO',(SELECT MAX(ATTACHMENT_NO) FROM MESSAGE_ATTACHMENT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('MAPPING_CODE','MAPPING_NO',(SELECT MAX(MAPPING_NO) FROM MAPPING_CODE))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('LOG_ENTRY','LOG_ENTRY_SEQ',(SELECT MAX(LOG_ENTRY_SEQ) FROM LOG_ENTRY))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('INTERFACE_CONTENT','INTERFACE_NO',(SELECT MAX(INTERFACE_NO) FROM INTERFACE_CONTENT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('HARBOUR_INTERRUPTION','HARBOUR_INTERRUPTION_NO',(SELECT MAX(HARBOUR_INTERRUPTION_NO) FROM HARBOUR_INTERRUPTION))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('FCTY_DEFERMENT_EVENT','EVENT_NO',(SELECT MAX(EVENT_NO) FROM FCTY_DEFERMENT_EVENT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('FCTY_DAY_POB','SEQ_NUMBER',(SELECT MAX(SEQ_NUMBER) FROM FCTY_DAY_POB))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('FCTY_DAY_ALARM','ALARM_NO',(SELECT MAX(ALARM_NO) FROM FCTY_DAY_ALARM))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('FCST_WELL_EVENT','EVENT_NO',(SELECT MAX(EVENT_NO) FROM FCST_WELL_EVENT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('FCST_SP_DAY_CPY_AFS','AFS_SEQ',(SELECT MAX(AFS_SEQ) FROM FCST_SP_DAY_CPY_AFS))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('FCST_SP_DAY_AFS','AFS_SEQ',(SELECT MAX(AFS_SEQ) FROM FCST_SP_DAY_AFS))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('FCST_OBJECT_FLUID','ANALYSIS_NO',(SELECT MAX(ANALYSIS_NO) FROM FCST_OBJECT_FLUID))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('FCST_NOMPNT_SUB_DAY_EVENT','EVENT_SEQ',(SELECT MAX(EVENT_SEQ) FROM FCST_NOMPNT_SUB_DAY_EVENT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('FCST_NOMPNT_PERIOD_EVENT','EVENT_SEQ',(SELECT MAX(EVENT_SEQ) FROM FCST_NOMPNT_PERIOD_EVENT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('FCST_NOMPNT_DAY_CPY_AFS','AFS_SEQ',(SELECT MAX(AFS_SEQ) FROM FCST_NOMPNT_DAY_CPY_AFS))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('FCST_NOMPNT_DAY_AFS','AFS_SEQ',(SELECT MAX(AFS_SEQ) FROM FCST_NOMPNT_DAY_AFS))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('FCST_NOMLOC_PERIOD_EVENT','EVENT_SEQ',(SELECT MAX(EVENT_SEQ) FROM FCST_NOMLOC_PERIOD_EVENT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('FCST_MEMBER','MEMBER_NO',(SELECT MAX(MEMBER_NO) FROM FCST_MEMBER))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('FCST_COMMENT','COMMENT_NO',(SELECT MAX(COMMENT_NO) FROM FCST_COMMENT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('FCST_ANALYSIS','ANALYSIS_NO',(SELECT MAX(ANALYSIS_NO) FROM FCST_ANALYSIS))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('DS_SOURCE_SETUP','DS_SOURCE_SETUP_NO',(SELECT MAX(DS_SOURCE_SETUP_NO) FROM DS_SOURCE_SETUP))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('DELPNT_DAY_CAP_ADJ','ADJ_SEQ',(SELECT MAX(ADJ_SEQ) FROM DELPNT_DAY_CAP_ADJ))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('DEF_DAY_MASTER_EVENT','INCIDENT_NO',(SELECT MAX(INCIDENT_NO) FROM DEF_DAY_MASTER_EVENT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('DEF_DAY_DEFERMENT_EVENT','DEFERMENT_EVENT_NO',(SELECT MAX(DEFERMENT_EVENT_NO) FROM DEF_DAY_DEFERMENT_EVENT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('DEFER_LOSS_STRM_EVENT','SEQUENCE_NO',(SELECT MAX(SEQUENCE_NO) FROM DEFER_LOSS_STRM_EVENT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('DEFER_LOSS_ACC_EVENT','EVENT_NO',(SELECT MAX(EVENT_NO) FROM DEFER_LOSS_ACC_EVENT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CURVE_POINT','SEQ',(SELECT MAX(SEQ) FROM CURVE_POINT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CURVE','CURVE_ID',(SELECT MAX(CURVE_ID) FROM CURVE))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CTRL_PROPERTY','PROPERTY_NO',(SELECT MAX(PROPERTY_NO) FROM CTRL_PROPERTY))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CTRL_PERSONALISATION','PRES_NO',(SELECT MAX(PRES_NO) FROM CTRL_PERSONALISATION))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CONT_LINE_ITEM','LINE_ITEM_KEY',(SELECT MAX(LINE_ITEM_KEY) FROM CONT_LINE_ITEM))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CONT_JOURNAL_ENTRY_EXCL','JOURNAL_ENTRY_NO',(SELECT MAX(JOURNAL_ENTRY_NO) FROM CONT_JOURNAL_ENTRY_EXCL))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CONT_JOURNAL_ENTRY','JOURNAL_ENTRY_NO',(SELECT MAX(JOURNAL_ENTRY_NO) FROM CONT_JOURNAL_ENTRY))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CONT_ERP_POSTINGS','ERP_REC_KEY',(SELECT MAX(ERP_REC_KEY) FROM CONT_ERP_POSTINGS))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CONT_DOCUMENT_TEXT_ITEM','TEXT_ITEM_NO',(SELECT MAX(TEXT_ITEM_NO) FROM CONT_DOCUMENT_TEXT_ITEM))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CONTROL_POINT_LINK','CONTROL_POINT_LINK_NO',(SELECT MAX(CONTROL_POINT_LINK_NO) FROM CONTROL_POINT_LINK))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CONTRACT_PREPARE','PREPARE_NO',(SELECT MAX(PREPARE_NO) FROM CONTRACT_PREPARE))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CNTR_QUALITY_HANDLING','QUALITY_HANDLING_NO',(SELECT MAX(QUALITY_HANDLING_NO) FROM CNTR_QUALITY_HANDLING))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CNTR_PERIOD_CAPACITY','PERIOD_CAPACITY_NO',(SELECT MAX(PERIOD_CAPACITY_NO) FROM CNTR_PERIOD_CAPACITY))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CNTR_DP_TRADE_EVENT','TRADE_NO',(SELECT MAX(TRADE_NO) FROM CNTR_DP_TRADE_EVENT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CNTR_DAY_LOC_INV_TRANS','TRANSACTION_SEQ',(SELECT MAX(TRANSACTION_SEQ) FROM CNTR_DAY_LOC_INV_TRANS))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CNTR_DAY_INV_SWAP','SWAP_SEQ',(SELECT MAX(SWAP_SEQ) FROM CNTR_DAY_INV_SWAP))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CNTR_DAY_CAP_REQUEST','REQ_SEQ',(SELECT MAX(REQ_SEQ) FROM CNTR_DAY_CAP_REQUEST))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CNTR_CAPACITY_DAY_TRANS','TRANSACTION_SEQ',(SELECT MAX(TRANSACTION_SEQ) FROM CNTR_CAPACITY_DAY_TRANS))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CNTR_BUNDLE_XFER','XFER_NO',(SELECT MAX(XFER_NO) FROM CNTR_BUNDLE_XFER))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CLASS_ATTR_PRES_CONFIG','CONFIG_NO',(SELECT MAX(CONFIG_NO) FROM CLASS_ATTR_PRES_CONFIG))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CHOKE_MODEL_LIP','LIP_OPP_ID',(SELECT MAX(LIP_OPP_ID) FROM CHOKE_MODEL_LIP))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CARRIER_INSPECTION','INSPECTION_NO',(SELECT MAX(INSPECTION_NO) FROM CARRIER_INSPECTION))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CARGO_TRANSPORT','CARGO_NO',(SELECT MAX(CARGO_NO) FROM CARGO_TRANSPORT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CARGO_STOR_BATCH','CARGO_BATCH_NO',(SELECT MAX(CARGO_BATCH_NO) FROM CARGO_STOR_BATCH))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CARGO_LIFTING_DELAY','DELAY_NO',(SELECT MAX(DELAY_NO) FROM CARGO_LIFTING_DELAY))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CARGO_HARBOUR_DUES','CARGO_HARBOUR_DUES_NO',(SELECT MAX(CARGO_HARBOUR_DUES_NO) FROM CARGO_HARBOUR_DUES))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CARGO_FCST_TRANSPORT','CARGO_NO',(SELECT MAX(CARGO_NO) FROM CARGO_FCST_TRANSPORT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CARGO_DOCUMENT','CARGO_DOCUMENT_NO',(SELECT MAX(CARGO_DOCUMENT_NO) FROM CARGO_DOCUMENT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CARGO_ANALYSIS','ANALYSIS_NO',(SELECT MAX(ANALYSIS_NO) FROM CARGO_ANALYSIS))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CARGO','CARGO_NO',(SELECT MAX(CARGO_NO) FROM CARGO))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CAPACITY_REL_REPUT','REPUT_NO',(SELECT MAX(REPUT_NO) FROM CAPACITY_REL_REPUT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CAPACITY_RELEASE','RELEASE_NO',(SELECT MAX(RELEASE_NO) FROM CAPACITY_RELEASE))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CAPACITY_RECALL','RECALL_NO',(SELECT MAX(RECALL_NO) FROM CAPACITY_RECALL))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CAPACITY_BID','BID_NO',(SELECT MAX(BID_NO) FROM CAPACITY_BID))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CALC_SET_EQUATION','SEQ_NO',(SELECT MAX(SEQ_NO) FROM CALC_SET_EQUATION))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CALC_SET_CONDITION','SEQ_NO',(SELECT MAX(SEQ_NO) FROM CALC_SET_CONDITION))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CALC_SET_COMBINATION','SEQ_NO',(SELECT MAX(SEQ_NO) FROM CALC_SET_COMBINATION))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CALC_PROC_ELM_ITERATION','SEQ_NO',(SELECT MAX(SEQ_NO) FROM CALC_PROC_ELM_ITERATION))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CALC_PROCESS_LOG','PROCESS_NO',(SELECT MAX(PROCESS_NO) FROM CALC_PROCESS_LOG))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CALC_EQUATION','SEQ_NO',(SELECT MAX(SEQ_NO) FROM CALC_EQUATION))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('CALC_BATCH_LOG','RUN_NO',(SELECT MAX(RUN_NO) FROM CALC_BATCH_LOG))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('BUSINESS_FUNCTION','BUSINESS_FUNCTION_NO',(SELECT MAX(BUSINESS_FUNCTION_NO) FROM BUSINESS_FUNCTION))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('BUSINESS_ACTION','BUSINESS_ACTION_NO',(SELECT MAX(BUSINESS_ACTION_NO) FROM BUSINESS_ACTION))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('BPM_PROC_OV_LIST_PROPERTY','ID',(SELECT MAX(ID) FROM BPM_PROC_OV_LIST_PROPERTY))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('BPM_PROC_OV_DATA_OPERATION','OP_ID',(SELECT MAX(OP_ID) FROM BPM_PROC_OV_DATA_OPERATION))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('BPM_PROC_MONITOR_PROC_CONF','ID',(SELECT MAX(ID) FROM BPM_PROC_MONITOR_PROC_CONF))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('BPM_PROC_MONITOR_NODE_CONF','ID',(SELECT MAX(ID) FROM BPM_PROC_MONITOR_NODE_CONF))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('JBPM_BPM_PA_COMMAND_QUEUE','ID',(SELECT MAX(ID) FROM JBPM_BPM_PA_COMMAND_QUEUE))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('BPM_EC_GCOMMAND_OP_P','OP_PARAM_ID',(SELECT MAX(OP_PARAM_ID) FROM BPM_EC_GCOMMAND_OP_P))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('BPM_EC_GCOMMAND_OP','BPM_EC_GCOMMAND_OP_ID',(SELECT MAX(BPM_EC_GCOMMAND_OP_ID) FROM BPM_EC_GCOMMAND_OP))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('BPM_EC_GCOMMAND_HANDLER_P','PARAM_ID',(SELECT MAX(PARAM_ID) FROM BPM_EC_GCOMMAND_HANDLER_P))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('BPM_EC_GCOMMAND_HANDLER','BPM_EC_GCOMMAND_HANDLER_ID',(SELECT MAX(BPM_EC_GCOMMAND_HANDLER_ID) FROM BPM_EC_GCOMMAND_HANDLER))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('BPM_EC_GCOMMAND','BPM_EC_GCOMMAND_ID',(SELECT MAX(BPM_EC_GCOMMAND_ID) FROM BPM_EC_GCOMMAND))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('BPM_EC_EVENT_INBOUND','ID',(SELECT MAX(ID) FROM BPM_EC_EVENT_INBOUND))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('BF_SCREENSHOT','BF_SCREENSHOT_NO',(SELECT MAX(BF_SCREENSHOT_NO) FROM BF_SCREENSHOT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('BF_DESCRIPTION_IMAGE','BF_DESCRIPTION_IMG_NO',(SELECT MAX(BF_DESCRIPTION_IMG_NO) FROM BF_DESCRIPTION_IMAGE))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('BF_COMPONENT_ACTION','BF_COMPONENT_ACTION_NO',(SELECT MAX(BF_COMPONENT_ACTION_NO) FROM BF_COMPONENT_ACTION))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('BF_COMPONENT','BF_COMPONENT_NO',(SELECT MAX(BF_COMPONENT_NO) FROM BF_COMPONENT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('BALANCING_ADJ_MTH','ADJUSTMENT_NO',(SELECT MAX(ADJUSTMENT_NO) FROM BALANCING_ADJ_MTH))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('ALLOC_JOB_PASS','JOB_PASS_NO',(SELECT MAX(JOB_PASS_NO) FROM ALLOC_JOB_PASS))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('ALLOC_JOB_LOG','RUN_NO',(SELECT MAX(RUN_NO) FROM ALLOC_JOB_LOG))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('ALLOC_JOB_DEFINITION','JOB_NO',(SELECT MAX(JOB_NO) FROM ALLOC_JOB_DEFINITION))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('ACTION_PARAMETER','ACTION_PARAMETER_NO',(SELECT MAX(ACTION_PARAMETER_NO) FROM ACTION_PARAMETER))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('ACTION_INSTANCE','ACTION_INSTANCE_NO',(SELECT MAX(ACTION_INSTANCE_NO) FROM ACTION_INSTANCE))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('WELL_BLOWDOWN_EVENT','EVENT_NO',(SELECT MAX(EVENT_NO) FROM WELL_BLOWDOWN_EVENT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('WELL_BLOWDOWN_DATA','EVENT_NO',(SELECT MAX(EVENT_NO) FROM WELL_BLOWDOWN_DATA))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('EQUIP_DOWNTIME','EVENT_NO',(SELECT MAX(EVENT_NO) FROM EQUIP_DOWNTIME))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    
    --START: ADDED FOR 12.0
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('BPM_PA_COMMAND_QUEUE','ID',(SELECT MAX(ID) FROM BPM_PA_COMMAND_QUEUE))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('DEFERMENT_EVENT','EVENT_NO',(SELECT MAX(EVENT_NO) FROM DEFERMENT_EVENT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END;
    
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('FCST_PROD_CURVES','FCST_CURVE_ID',(SELECT MAX(FCST_CURVE_ID) FROM FCST_PROD_CURVES))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END; 
    
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('FCST_PROD_CURVES_SEGMENT','FCST_SEGMENT_ID',(SELECT MAX(FCST_SEGMENT_ID) FROM FCST_PROD_CURVES_SEGMENT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END; 
    
     declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('NOMPNT_NP_DAY_NOMINATION','NOMINATION_SEQ',(SELECT MAX(NOMINATION_SEQ) FROM NOMPNT_NP_DAY_NOMINATION))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END; 
    
    declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('STORAGE_LIFT_NOM_SPLIT','SPLIT_NO',(SELECT MAX(SPLIT_NO) FROM STORAGE_LIFT_NOM_SPLIT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END; 
    
     declare
      no_such_table  exception;
      exc_invalid_id exception;
      pragma exception_init(exc_invalid_id, -904);
      pragma exception_init(no_such_table, -942);
      l_str varchar2(6000);
    begin
      l_str := q'[insert into TEMP_ASSIGN_ID VALUES('FCST_STOR_LIFT_CPY_SPLIT','SPLIT_NO',(SELECT MAX(SPLIT_NO) FROM FCST_STOR_LIFT_CPY_SPLIT))]';
      EXECUTE IMMEDIATE L_STR;
    EXCEPTION
      WHEN NO_SUCH_TABLE THEN
        NULL;
      WHEN EXC_INVALID_ID THEN
        NULL;
    END; 
    
    
  	--END: ADDED FOR 12.0
    
  EXCEPTION
    WHEN OTHERS THEN
      null;
  END;

  FOR i IN c_gtcur LOOP
    l_cnt := null;
  
    BEGIN
      SELECT COUNT(1)
        INTO l_cnt
        FROM assign_id
      where tablename = i.tablename;
    EXCEPTION
      WHEN OTHERS THEN
        l_cnt := 0;
    END;
  
    IF l_cnt > 0 THEN
      BEGIN
        UPDATE assign_id
          SET max_id = i.max_id
        WHERE tablename = i.tablename;
      EXCEPTION
        WHEN OTHERS THEN
          null;
      END;
    ELSE
      BEGIN
        INSERT INTO assign_id VALUES (i.tablename, nvl(i.max_id, 0));
      EXCEPTION
        WHEN OTHERS THEN
          null;
      END;
    END IF;
  END LOOP;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    null;
END;
--~^UTDELIM^~--

DROP TABLE TEMP_ASSIGN_ID
--~^UTDELIM^~--

DECLARE HASENTRY NUMBER; BEGIN SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS WHERE TRIGGER_NAME = 'JN_NAV_MODEL_OBJECT_RELATION'; IF HASENTRY > 0 THEN EXECUTE IMMEDIATE 'DROP TRIGGER JN_NAV_MODEL_OBJECT_RELATION'; END IF; END;
--~^UTDELIM^~--
