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
  
  PROCEDURE p_insert_table(p_table_name_i IN VARCHAR2,p_column_name_i IN VARCHAR2)
  IS
   l_sql VARCHAR2(6000);  
  BEGIN
     l_sql := 'insert into TEMP_ASSIGN_ID VALUES('||''''||p_table_name_i||''''||','||''''||p_column_name_i||''''||','||'(SELECT MAX('||p_column_name_i||')'||' FROM '||p_table_name_i||')'||')';
     EXECUTE IMMEDIATE l_sql;
  EXCEPTION
   WHEN OTHERS THEN
        NULL;
  END;
  
BEGIN
  DELETE FROM TEMP_ASSIGN_ID WHERE 1 = 1;
  
    p_insert_table('WELL_EQUIP_DOWNTIME','EVENT_NO'); 
    p_insert_table('WELL_EQPM_MASTER_EVENT','MASTER_EVENT_ID');
    p_insert_table('WELL_DEFERMENT_EVENT','WDE_NO');
    p_insert_table('WELL_DEFERMENT','EVENT_NO');
    p_insert_table('WEBO_PRESS_TEST_GRAD','GRADIENT_SEQ');
    p_insert_table('WEBO_PRESS_TEST','EVENT_NO');
    p_insert_table('T_BASIS_OBJECT','OBJECT_ID');
    p_insert_table('T_BASIS_ACCESS','T_BASIS_ACCESS_ID');
    p_insert_table('TREND_CURVE','TREND_SEGMENT_NO');
    p_insert_table('TRANS_TEMPLATE','TEMPLATE_NO');
    p_insert_table('TRANS_PROCESS_LOG','LOG_SEQ');
    p_insert_table('TRANS_MAPPING','MAPPING_NO');
    p_insert_table('TRANSACTION_MEASUREMENT','EVENT_NO');
    p_insert_table('TASK','TASK_NO');
    p_insert_table('TANK_ANALYSIS','ANALYSIS_NO');
    p_insert_table('STRM_TRANSPORT_EVENT','EVENT_NO');
    p_insert_table('STRM_FORMULA','FORMULA_NO');
    p_insert_table('STRM_COMPANY_SWAP','SWAP_NO');
    p_insert_table('STRM_ANALYSIS_EVENT','ANALYSIS_NO');
    p_insert_table('STOR_FCST_LIFT_NOM','PARCEL_NO');
    p_insert_table('STOR_DAY_FIFO_COMP_ALLOC','FIFO_NO');
    p_insert_table('STOR_DAY_FIFO_ALLOC','FIFO_NO');
    p_insert_table('STOR_BLEND_BATCH','EVENT_NO');
    p_insert_table('STORAGE_LIFT_NOMINATION','PARCEL_NO');
    p_insert_table('STIM_PENDING_ITEM','STIM_PENDING_ITEM_NO');
    p_insert_table('STIM_PENDING','STIM_PENDING_NO');
    p_insert_table('STIM_FCST_SETUP','STIM_FCST_NO');
    p_insert_table('SCTR_DAY_LIFTING','SEQ_NO');
    p_insert_table('SCHEDULE','SCHEDULE_NO');
    p_insert_table('SAILING_ADVICE_MESSAGE','SAILING_MESSAGE_NO');
    p_insert_table('REVN_LOG_ITEM','ITEM_NO');
    p_insert_table('REVN_LOG','LOG_NO');
    p_insert_table('REVN_DATA_FILTER_RULE','FILTER_RULE_NUMBER');
    p_insert_table('REPT_SET_CONDITION','SEQ_NO');
    p_insert_table('REPT_SET_COMBINATION','SEQ_NO');
    p_insert_table('REPORT_SET','REPORT_SET_NO');
    p_insert_table('REPORT_RUNABLE','REPORT_RUNABLE_NO');
    p_insert_table('REPORT_DEFINITION','REPORT_DEFINITION_NO');
    p_insert_table('REPORT','REPORT_NO');
    p_insert_table('RECORD_EVENT','EVENT_NO');
    p_insert_table('PTST_RESULT','RESULT_NO');
    p_insert_table('PTST_DEFINITION','TEST_NO');
    p_insert_table('PROD_FORECAST','FCST_SCEN_NO');
    p_insert_table('PRODUCT_MEAS_SETUP','PRODUCT_MEAS_NO');
    p_insert_table('PRODUCT_ANALYSIS_ITEM','PAI_NO');
    p_insert_table('PROCESS_NOTIFICATION','PROCESS_NOTIFICATION_NO');
    p_insert_table('PIPE_PC_TRANSACTION','TRANSACTION_NO');
    p_insert_table('PERFORMANCE_CURVE','PERF_CURVE_ID');
    p_insert_table('PARCEL_NOMINATION','PARCEL_NO');
    p_insert_table('OPPORTUNITY','OPPORTUNITY_NO');
    p_insert_table('OBJ_FLUID_ANA_DETAIL','ANALYSIS_ITEM');
    p_insert_table('OBJLOC_SUB_DAY_NOMINATION','NOMINATION_SEQ');
    p_insert_table('OBJLOC_DAY_NOMINATION','NOMINATION_SEQ');
    p_insert_table('OBJECT_TRANSPORT_EVENT','EVENT_NO');
    p_insert_table('OBJECT_ITEM_COMMENT','COMMENT_ID');
    p_insert_table('OBJECT_FLUID_ANALYSIS','ANALYSIS_NO');
    p_insert_table('OBJECT_AGA_ANALYSIS','ANALYSIS_NO');
    p_insert_table('OBJECTS_DEFERMENT_EVENT','EVENT_ID');
    p_insert_table('NOMPNT_SUB_DAY_NOMINATION','NOMINATION_SEQ');
    p_insert_table('NOMPNT_SUB_DAY_EVENT','EVENT_SEQ');
    p_insert_table('NOMPNT_SUB_DAY_DELIVERY','NOMINATION_SEQ');
    p_insert_table('NOMPNT_SUB_DAY_CONFIRMATION','CONFIRMATION_SEQ');
    p_insert_table('NOMPNT_PERIOD_EVENT','EVENT_SEQ');
    p_insert_table('NOMPNT_MTH_TRANSFER','TRANSFER_SEQ');
    p_insert_table('NOMPNT_MTH_NOM','NOMINATION_SEQ');
    p_insert_table('NOMPNT_MTH_DELIVERY','NOMINATION_SEQ');
    p_insert_table('NOMPNT_DAY_TRANSFER','TRANSFER_SEQ');
    p_insert_table('NOMPNT_DAY_NOMINATION','NOMINATION_SEQ');
    p_insert_table('NOMPNT_DAY_FORECAST','NOMINATION_SEQ');
    p_insert_table('NOMPNT_DAY_DELIVERY','NOMINATION_SEQ');
    p_insert_table('NOMPNT_DAY_CONFIRMATION','CONFIRMATION_SEQ');
    p_insert_table('NOMLOC_PERIOD_EVENT','EVENT_SEQ');
    p_insert_table('METER_ALLOC_METHOD','ALLOC_METHOD_SEQ');
    p_insert_table('MESSAGE_WORKFLOW_ALERT','ALERT_NO');
    p_insert_table('MESSAGE_TEMPLATE','TEMPLATE_NO');
    p_insert_table('MESSAGE_OUT','MESSAGE_NO');
    p_insert_table('MESSAGE_DISTRIBUTION','MESSAGE_DISTRIBUTION_NO');
    p_insert_table('MESSAGE_ATTACHMENT','ATTACHMENT_NO');
    p_insert_table('MAPPING_CODE','MAPPING_NO');
    p_insert_table('LOG_ENTRY','LOG_ENTRY_SEQ');
    p_insert_table('INTERFACE_CONTENT','INTERFACE_NO');
    p_insert_table('HARBOUR_INTERRUPTION','HARBOUR_INTERRUPTION_NO');
    p_insert_table('FCTY_DEFERMENT_EVENT','EVENT_NO');
    p_insert_table('FCTY_DAY_POB','SEQ_NUMBER');
    p_insert_table('FCTY_DAY_ALARM','ALARM_NO');
    p_insert_table('FCST_WELL_EVENT','EVENT_NO');
    p_insert_table('FCST_SP_DAY_CPY_AFS','AFS_SEQ');
    p_insert_table('FCST_SP_DAY_AFS','AFS_SEQ');
    p_insert_table('FCST_OBJECT_FLUID','ANALYSIS_NO');
    p_insert_table('FCST_NOMPNT_SUB_DAY_EVENT','EVENT_SEQ');
    p_insert_table('FCST_NOMPNT_PERIOD_EVENT','EVENT_SEQ');
    p_insert_table('FCST_NOMPNT_DAY_CPY_AFS','AFS_SEQ');
    p_insert_table('FCST_NOMPNT_DAY_AFS','AFS_SEQ');
    p_insert_table('FCST_NOMLOC_PERIOD_EVENT','EVENT_SEQ');
    p_insert_table('FCST_MEMBER','MEMBER_NO');
    p_insert_table('FCST_COMMENT','COMMENT_NO');
    p_insert_table('FCST_ANALYSIS','ANALYSIS_NO');
    p_insert_table('DS_SOURCE_SETUP','DS_SOURCE_SETUP_NO');
    p_insert_table('DELPNT_DAY_CAP_ADJ','ADJ_SEQ');
    p_insert_table('DEF_DAY_MASTER_EVENT','INCIDENT_NO');
    p_insert_table('DEF_DAY_DEFERMENT_EVENT','DEFERMENT_EVENT_NO');
    p_insert_table('DEFER_LOSS_STRM_EVENT','SEQUENCE_NO');
    p_insert_table('DEFER_LOSS_ACC_EVENT','EVENT_NO');
    p_insert_table('CURVE_POINT','SEQ');
    p_insert_table('CURVE','CURVE_ID');
    p_insert_table('CTRL_PROPERTY','PROPERTY_NO');
    p_insert_table('CTRL_PERSONALISATION','PRES_NO');
    p_insert_table('CONT_LINE_ITEM','LINE_ITEM_KEY');
    p_insert_table('CONT_JOURNAL_ENTRY_EXCL','JOURNAL_ENTRY_NO');
    p_insert_table('CONT_JOURNAL_ENTRY','JOURNAL_ENTRY_NO');
    p_insert_table('CONT_ERP_POSTINGS','ERP_REC_KEY');
    p_insert_table('CONT_DOCUMENT_TEXT_ITEM','TEXT_ITEM_NO');
    p_insert_table('CONTROL_POINT_LINK','CONTROL_POINT_LINK_NO');
    p_insert_table('CONTRACT_PREPARE','PREPARE_NO');
    p_insert_table('CNTR_QUALITY_HANDLING','QUALITY_HANDLING_NO');
    p_insert_table('CNTR_PERIOD_CAPACITY','PERIOD_CAPACITY_NO');
    p_insert_table('CNTR_DP_TRADE_EVENT','TRADE_NO');
    p_insert_table('CNTR_DAY_LOC_INV_TRANS','TRANSACTION_SEQ');
    p_insert_table('CNTR_DAY_INV_SWAP','SWAP_SEQ');
    p_insert_table('CNTR_DAY_CAP_REQUEST','REQ_SEQ');
    p_insert_table('CNTR_CAPACITY_DAY_TRANS','TRANSACTION_SEQ');
    p_insert_table('CNTR_BUNDLE_XFER','XFER_NO');
    p_insert_table('CLASS_ATTR_PRES_CONFIG','CONFIG_NO');
    p_insert_table('CHOKE_MODEL_LIP','LIP_OPP_ID');
    p_insert_table('CARRIER_INSPECTION','INSPECTION_NO');
    p_insert_table('CARGO_TRANSPORT','CARGO_NO');
    p_insert_table('CARGO_STOR_BATCH','CARGO_BATCH_NO');
    p_insert_table('CARGO_LIFTING_DELAY','DELAY_NO');
    p_insert_table('CARGO_HARBOUR_DUES','CARGO_HARBOUR_DUES_NO');
    p_insert_table('CARGO_FCST_TRANSPORT','CARGO_NO');
    p_insert_table('CARGO_DOCUMENT','CARGO_DOCUMENT_NO');
    p_insert_table('CARGO_ANALYSIS','ANALYSIS_NO');
    p_insert_table('CARGO','CARGO_NO');
    p_insert_table('CAPACITY_REL_REPUT','REPUT_NO');
    p_insert_table('CAPACITY_RELEASE','RELEASE_NO');
    p_insert_table('CAPACITY_RECALL','RECALL_NO');
    p_insert_table('CAPACITY_BID','BID_NO');
    p_insert_table('CALC_SET_EQUATION','SEQ_NO');
    p_insert_table('CALC_SET_CONDITION','SEQ_NO');
    p_insert_table('CALC_SET_COMBINATION','SEQ_NO');
    p_insert_table('CALC_PROC_ELM_ITERATION','SEQ_NO');
    p_insert_table('CALC_PROCESS_LOG','PROCESS_NO');
    p_insert_table('CALC_EQUATION','SEQ_NO');
    p_insert_table('CALC_BATCH_LOG','RUN_NO');
    p_insert_table('BUSINESS_FUNCTION','BUSINESS_FUNCTION_NO');
    p_insert_table('BUSINESS_ACTION','BUSINESS_ACTION_NO');
    p_insert_table('BPM_PROC_OV_LIST_PROPERTY','ID');
    p_insert_table('BPM_PROC_OV_DATA_OPERATION','OP_ID');
    p_insert_table('BPM_PROC_MONITOR_PROC_CONF','ID');
    p_insert_table('BPM_PROC_MONITOR_NODE_CONF','ID');
    p_insert_table('JBPM_BPM_PA_COMMAND_QUEUE','ID');
    p_insert_table('BPM_EC_GCOMMAND_OP_P','OP_PARAM_ID');
    p_insert_table('BPM_EC_GCOMMAND_OP','BPM_EC_GCOMMAND_OP_ID');
    p_insert_table('BPM_EC_GCOMMAND_HANDLER_P','PARAM_ID');
    p_insert_table('BPM_EC_GCOMMAND_HANDLER','BPM_EC_GCOMMAND_HANDLER_ID');
    p_insert_table('BPM_EC_GCOMMAND','BPM_EC_GCOMMAND_ID');
    p_insert_table('BPM_EC_EVENT_INBOUND','ID');
    p_insert_table('BF_SCREENSHOT','BF_SCREENSHOT_NO');
    p_insert_table('BF_DESCRIPTION_IMAGE','BF_DESCRIPTION_IMG_NO');
    p_insert_table('BF_COMPONENT_ACTION','BF_COMPONENT_ACTION_NO');
    p_insert_table('BF_COMPONENT','BF_COMPONENT_NO');
    p_insert_table('BALANCING_ADJ_MTH','ADJUSTMENT_NO');
    p_insert_table('ALLOC_JOB_PASS','JOB_PASS_NO');
    p_insert_table('ALLOC_JOB_LOG','RUN_NO');
    p_insert_table('ALLOC_JOB_DEFINITION','JOB_NO');
    p_insert_table('ACTION_PARAMETER','ACTION_PARAMETER_NO');
    p_insert_table('ACTION_INSTANCE','ACTION_INSTANCE_NO');
    p_insert_table('WELL_BLOWDOWN_EVENT','EVENT_NO');
    p_insert_table('WELL_BLOWDOWN_DATA','EVENT_NO');
    p_insert_table('EQUIP_DOWNTIME','EVENT_NO');
    p_insert_table('BPM_PA_COMMAND_QUEUE','ID');
    p_insert_table('DEFERMENT_EVENT','EVENT_NO');
    p_insert_table('FCST_PROD_CURVES','FCST_CURVE_ID');
    p_insert_table('FCST_PROD_CURVES_SEGMENT','FCST_SEGMENT_ID');
    p_insert_table('NOMPNT_NP_DAY_NOMINATION','NOMINATION_SEQ');
    p_insert_table('STORAGE_LIFT_NOM_SPLIT','SPLIT_NO'); 
    p_insert_table('FCST_STOR_LIFT_CPY_SPLIT','SPLIT_NO');
 

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
