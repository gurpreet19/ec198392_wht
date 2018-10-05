CREATE OR REPLACE PACKAGE BODY EcDp_RR_Revn_Summary IS
/****************************************************************
** Package        :  EcDp_RR_Revn_Summary, body part
**
** $Revision: 1.33 $
**
** Purpose        :  Provide functionality for regulatory reporting Canada,
**                   focusing on logic around creating and maintaining Summaries.
**
** Documentation  :  http://energyextra.tietoenator.com
**
** Created  : 06.05.2010  Dagfinn Rosnes
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ------      ----- --------------------------------------
********************************************************************/


TYPE cv_type IS REF CURSOR;

TYPE rec_Summary IS RECORD
  (
   tag VARCHAR2(240),
   amount NUMBER,
   qty NUMBER
  );

TYPE tbl_Summary IS TABLE OF rec_Summary;



PROCEDURE PrepareInsertRecord(p_rec_cjs IN OUT cont_journal_summary%ROWTYPE,
                              p_contract_id VARCHAR2,
                              p_company_id VARCHAR2,
                              p_fiscal_year VARCHAR2,
                              p_daytime DATE,
                              p_period DATE
)
IS

BEGIN

  -- Set Common values for insert record
  p_rec_cjs.object_id   := p_contract_id;
  p_rec_cjs.company_id  := p_company_id;
  p_rec_cjs.fiscal_year := p_fiscal_year;
  p_rec_cjs.daytime     := p_daytime;
  p_rec_cjs.period      := p_period;

  -- Reset variable values
  p_rec_cjs.document_key         := NULL;
  p_rec_cjs.list_item_key        := NULL;
  p_rec_cjs.summary_setup_id     := NULL;
  p_rec_cjs.dataset              := NULL;
  p_rec_cjs.tag                  := NULL;
  p_rec_cjs.label                := NULL;
  p_rec_cjs.fin_account_id       := NULL;
  p_rec_cjs.fin_cost_center_id   := NULL;
  p_rec_cjs.fin_revenue_order_id := NULL;
  p_rec_cjs.fin_wbs_id           := NULL;
  p_rec_cjs.debit_credit         := NULL;
  p_rec_cjs.actual_amount        := NULL;
  p_rec_cjs.actual_qty_1         := NULL;
  p_rec_cjs.amend_amount         := NULL;
  p_rec_cjs.amend_qty_1          := NULL;
  p_rec_cjs.uom1_code            := NULL;
  p_rec_cjs.currency_id          := NULL;

END PrepareInsertRecord;


PROCEDURE InsertSummaryRecord(
          p_rec_cjs cont_journal_summary%ROWTYPE
)
IS

BEGIN

    -- Insert Data Extract record
    INSERT INTO cont_journal_summary (
           object_id,
           company_id,
           fiscal_year,
           daytime,
           document_key,
           list_item_key,
           summary_setup_id,
           period,
           dataset,
           tag,
           label,
           fin_account_id,
           fin_cost_center_id,
           fin_revenue_order_id,
           fin_wbs_id,
           debit_credit,
           actual_amount,
           actual_qty_1,
           amend_amount,
           amend_qty_1,
           uom1_code,
           currency_id,
           created_by
           )
    VALUES(
           p_rec_cjs.object_id,
           p_rec_cjs.company_id,
           p_rec_cjs.fiscal_year,
           p_rec_cjs.daytime,
           p_rec_cjs.document_key,
           p_rec_cjs.list_item_key,
           p_rec_cjs.summary_setup_id,
           p_rec_cjs.period,
           p_rec_cjs.dataset,
           p_rec_cjs.tag,
           p_rec_cjs.label,
           p_rec_cjs.fin_account_id,
           p_rec_cjs.fin_cost_center_id,
           p_rec_cjs.fin_revenue_order_id,
           p_rec_cjs.fin_wbs_id,
           p_rec_cjs.debit_credit,
           p_rec_cjs.actual_amount,
           p_rec_cjs.actual_qty_1,
           p_rec_cjs.amend_amount,
           p_rec_cjs.amend_qty_1,
           p_rec_cjs.uom1_code,
           p_rec_cjs.currency_id,
           p_rec_cjs.created_by
           );

END InsertSummaryRecord;


PROCEDURE SetPrecedingSummaryTagValue(
                pt_prec_sum tbl_Summary,
                p_tag VARCHAR2,
                p_amount IN OUT NUMBER,
                p_qty IN OUT NUMBER
)
IS

BEGIN

  p_amount := NULL;
  p_qty := NULL;

  IF pt_prec_sum.COUNT = 0 THEN
     RETURN;
  END IF;

  -- Find preceding amount and qty
  FOR i IN 1..pt_prec_sum.COUNT LOOP

      IF pt_prec_sum(i).tag = p_tag THEN

        p_amount := pt_prec_sum(i).amount;
        p_qty := pt_prec_sum(i).qty;

        EXIT;

      END IF;

  END LOOP;

END SetPrecedingSummaryTagValue;



PROCEDURE CreateSummarySetMonth(
        p_summary_set_id        VARCHAR2,
        p_period                DATE,
        p_user_id               VARCHAR2,
        p_accrual_ind           VARCHAR2,
        p_dataset               VARCHAR2 DEFAULT NULL,
        p_dataset_filter_method VARCHAR2 DEFAULT 'ALL_DATASET',
        p_silent_mode_ind       VARCHAR2 DEFAULT 'N'
        )
IS

    CURSOR c_summary_set_setup_count(cp_summary_set_id VARCHAR2, p_period DATE) IS
        SELECT COUNT(*) SUMMARY_COUNT
        FROM SUMMARY_SET_SETUP, SUMMARY_SET
        WHERE SUMMARY_SET.Object_Id = cp_summary_set_id
            AND SUMMARY_SET_SETUP.OBJECT_ID = SUMMARY_SET.Object_Id
            AND SUMMARY_SET.Start_Date <= p_period
            AND NVL(SUMMARY_SET.End_Date, p_period + 1) > p_period
            AND SUMMARY_SET_SETUP.Daytime <= p_period
            AND NVL(SUMMARY_SET_SETUP.End_Date, p_period + 1) > p_period;

    CURSOR c_summary_set_setup(cp_summary_set_id VARCHAR2, p_period DATE) IS
        SELECT SUMMARY_SET_SETUP.*
        FROM SUMMARY_SET_SETUP, SUMMARY_SET
        WHERE SUMMARY_SET.Object_Id = cp_summary_set_id
            AND SUMMARY_SET_SETUP.OBJECT_ID = SUMMARY_SET.Object_Id
            AND SUMMARY_SET.Start_Date <= p_period
            AND NVL(SUMMARY_SET.End_Date, p_period + 1) > p_period
            AND SUMMARY_SET_SETUP.Daytime <= p_period
            AND NVL(SUMMARY_SET_SETUP.End_Date, p_period + 1) > p_period
        ORDER BY SUMMARY_SET_SETUP.Sort_Order;

    ln_user_log_no NUMBER;
    lv2_user_log_final_status VARCHAR2(32);
    ln_succeeded_summary_count NUMBER := 0;
    ln_summary_count NUMBER := 0;
    ln_processed_summary_count NUMBER := 0;
    user_log_item_info SUMMARY_PC_USER_LOG_ITEM_INFO;
    lv2_user_log_desc_h VARCHAR2(32) := 'Process Data Extract Set ';
    Schedule_count number;

BEGIN

    lv2_user_log_final_status := ECDP_REVN_LOG.LOG_STATUS_SUCCESS;

    -- Create a new log
    ln_user_log_no := CreateSummaryProcessLog(ECDP_REVN_LOG.LOG_STATUS_RUNNING, ECDP_REVN_LOG.GETBATCHPROCESSLOGDESCRIPTION(lv2_user_log_desc_h));

    user_log_item_info.LOG_NO := ln_user_log_no;
    user_log_item_info.LOG_ITEM_SOURCE := 'EcDp_RR_Revn_Summary.CreateSummarySetMonth';

    UpdateSummaryProcessLog(ln_user_log_no, NULL, NULL,
        (CASE p_dataset_filter_method WHEN 'SPECIFIED_DATASET' THEN p_dataset ELSE NULL END),
        p_period, p_summary_set_id);


 select count(*) INTO Schedule_count
      from (select replace(utl_raw.cast_to_varchar2(DBMS_LOB.SUBSTR(JOB_DATA,4000)),'\:',':') args from qrtz_triggers
      where (trigger_state!='COMPLETE' or ecdp_scheduler.isJobExecuting(trigger_name, trigger_group)='Y')
       and trigger_name like 'DataExtractSetProcess--!##RERUN##!%') x
   where INSTR(x.args,'PERIOD=' || to_char(p_period,'YYYY-MM-DD"T"HH24:MI:SS'))> 0
				 and (INSTR(x.args,'DATASET=' || p_dataset) > 0 OR (INSTR(x.args,'DATASET')=0 AND p_dataset IS NULL))
         and (INSTR(x.args,'DATASET_FILTER_METHOD=' || p_dataset_filter_method) > 0 OR (INSTR(x.args,'DATASET_FILTER_METHOD')=0 AND p_dataset_filter_method IS NULL))
         and INSTR(x.args,'SUMMARY_SET_ID=' || p_summary_set_id) > 0
				 and INSTR(x.args,'ACCRUAL_IND='|| p_accrual_ind) > 0 ;

  IF Schedule_count > 1 THEN
        CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_INFO, 'Not able to execute. The Extract Mapping schedule is already running. Please refresh to get status');
        UpdateSummaryProcessLog(user_log_item_info.LOG_NO, ECDP_REVN_LOG.log_status_error);
  ELSE

    CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_DEBUG, 'Start to process Data Extract set for period ' || p_period);


    FOR ci_count IN c_summary_set_setup_count(p_summary_set_id, p_period) LOOP
        ln_summary_count := ci_count.SUMMARY_COUNT;
    END LOOP;


    CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_DEBUG, ln_summary_count || ' Data Extract setups need to be processed');


    FOR ci_summary_set_setup IN c_summary_set_setup(p_summary_set_id, p_period) LOOP
        BEGIN
            user_log_item_info.PARAM_SUMMARY_ID := ci_summary_set_setup.SUMMARY_SETUP_ID;
            user_log_item_info.PARAM_CONTRACT_ID := ci_summary_set_setup.CONTRACT_ID;
            user_log_item_info.PARAM_DATA_SET := (CASE p_dataset_filter_method WHEN 'SPECIFIED_DATASET' THEN p_dataset ELSE NULL END);

            CreateSummaryMonth(ci_summary_set_setup.CONTRACT_ID, ci_summary_set_setup.SUMMARY_SETUP_ID,
                p_period, p_user_id,p_accrual_ind,ci_summary_set_setup.inventory_id, p_dataset, p_dataset_filter_method, ln_user_log_no);

            ln_processed_summary_count := ln_processed_summary_count + 1;
            ln_succeeded_summary_count := ln_succeeded_summary_count + 1;

            UpdateSummaryProcessLog(ln_user_log_no, NULL, ECDP_REVN_LOG.GETBATCHPROCESSLOGDESCRIPTION(lv2_user_log_desc_h, ln_summary_count, ln_processed_summary_count, ln_succeeded_summary_count), NULL, NULL, NULL);

        EXCEPTION
            WHEN OTHERS THEN
                ln_processed_summary_count := ln_processed_summary_count + 1;
                lv2_user_log_final_status := ECDP_REVN_LOG.LOG_STATUS_ERROR;

                CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_INFO, 'Data Extract process failed, changes made for processing this Data Extract setup have been rolled back.');

                UpdateSummaryProcessLog(ln_user_log_no, NULL, ECDP_REVN_LOG.GETBATCHPROCESSLOGDESCRIPTION(lv2_user_log_desc_h, ln_summary_count, ln_processed_summary_count, ln_succeeded_summary_count), NULL, NULL, NULL);


        END;

    END LOOP;

    user_log_item_info.PARAM_SUMMARY_ID := NULL;

    -- Log the process result
    CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_INFO, 'All Data Extract setups have been processed, ' || ln_succeeded_summary_count || ' succeeded, ' || TO_CHAR(ln_summary_count - ln_succeeded_summary_count) || ' failed.');

    UpdateSummaryProcessLog(ln_user_log_no, lv2_user_log_final_status, ECDP_REVN_LOG.GETBATCHPROCESSLOGDESCRIPTION(lv2_user_log_desc_h, ln_summary_count, ln_processed_summary_count, ln_succeeded_summary_count), NULL, NULL, NULL);
    END IF;

END CreateSummarySetMonth;


---------------------------------------------------------------------------------------------------
-- Procedure      : CreateNewSummaryMonthTracing
-- Description    : Will populated the Summary Tracing data and the dataset flow day
--                  Does by document key
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
---------------------------------------------------------------------------------------------------
PROCEDURE CreateSummaryMonthTracing(p_document_key VARCHAR2) IS

BEGIN
       CreateSummaryTracing(p_document_key, ec_cont_doc.period(p_document_key));
       Ecdp_Dataset_Flow.InsJEDataToDS(p_document_key);
END;



---------------------------------------------------------------------------------------------------
-- Procedure      : CreateNewSummaryMonthTracing
-- Description    : Will populated the Summary Tracing data and the dataset flow day
--                 Will search for nongenerated document tracing data first then call procedure to use document key
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
---------------------------------------------------------------------------------------------------
PROCEDURE CreateSummaryMonthTracing( p_contract_id           VARCHAR2,
          p_summary_setup_id      VARCHAR2,
          p_period                DATE,
          p_user_id               VARCHAR2,
          p_accrual_ind           VARCHAR2,
          p_inventory_id          VARCHAR2 DEFAULT NULL,
          p_dataset               VARCHAR2 DEFAULT NULL,
          p_dataset_filter_method VARCHAR2 DEFAULT NULL
          ) IS

  cursor cr_FindDocuments_tracing IS
         SELECT DOCUMENT_KEY
           FROM CONT_DOC cd
          WHERE cd.summary_setup_id = p_summary_setup_id
            AND object_id = p_contract_id
            AND period = p_period
            AND accrual_ind = nvl(p_accrual_ind,'N')
            and nvl(inventory_id,'xxx')= nvl(p_inventory_id,'xxx')
            and nvl(dataset,'xxx') = nvl((CASE p_dataset_filter_method WHEN 'SPECIFIED_DATASET' THEN p_dataset ELSE NULL END),'xxx')
            and document_key not in (select SUMMARY_DOC_KEY from SUMMARY_TRACING where cd.document_key=SUMMARY_DOC_KEY );

  cursor cr_FindDocuments_datasetflow IS
         SELECT DOCUMENT_KEY
           FROM CONT_DOC cd
          WHERE cd.summary_setup_id = p_summary_setup_id
            AND object_id = p_contract_id
            AND period = p_period
            AND accrual_ind = nvl(p_accrual_ind,'N')
            and nvl(inventory_id,'xxx')= nvl(p_inventory_id,'xxx')
            and nvl(dataset,'xxx') = nvl((CASE p_dataset_filter_method WHEN 'SPECIFIED_DATASET' THEN p_dataset ELSE NULL END),'xxx')
            and document_key not in (select to_reference_id from dataset_flow_doc_conn
                                            where cd.document_key=to_reference_id
                                              and to_type = 'CONT_JOURNAL_SUMMARY' );

BEGIN
       FOR tracing in cr_FindDocuments_tracing LOOP
           CreateSummaryTracing(tracing.document_key, ec_cont_doc.period(tracing.document_key));
       END LOOP;
       FOR tracing IN cr_FindDocuments_datasetflow LOOP
           Ecdp_Dataset_Flow.InsJEDataToDS(tracing.document_key);
       END LOOP;
END;


---------------------------------------------------------------------------------------------------
-- Procedure      : CreateNewSummaryMonth
-- Description    : Uses the summary list setup to extract data from journal entry table
--                  and create a new summary for the month at hand.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
---------------------------------------------------------------------------------------------------
PROCEDURE CreateSummaryMonth(
          p_contract_id           VARCHAR2,
          p_summary_setup_id      VARCHAR2,
          p_period                DATE,
          p_user_id               VARCHAR2,
          p_accrual_ind           VARCHAR2,
          p_inventory_id          VARCHAR2 DEFAULT NULL,
          p_dataset               VARCHAR2 DEFAULT NULL,
          p_dataset_filter_method VARCHAR2 DEFAULT 'ALL_DATASET',
          p_user_log_no           NUMBER DEFAULT NULL,
          p_silent_mode_ind       VARCHAR2 DEFAULT 'N'
          )
--</EC-DOC>
IS


  Schedule_count number;

  CURSOR c_sl(cp_summary_list_id VARCHAR2, cp_period DATE, cp_dataset VARCHAR2) IS
    SELECT l.*
      FROM summary_setup_list l
     WHERE l.object_id = cp_summary_list_id
       AND NVL(NVL(cp_dataset, l.dataset), '$NULL$') = NVL(l.dataset, '$NULL$')
       AND cp_period >= l.daytime
       AND cp_period <  NVL(l.end_date, cp_period + 1)
--       AND cp_period >= NVL(l.available_from, cp_period)
--       AND cp_period <  NVL(l.available_to, cp_period + 1)
     ORDER BY l.sort_order, l.label;

  CURSOR c_prec_doc(cp_contract_id VARCHAR2, cp_summary_setup_id VARCHAR2, cp_daytime DATE,cp_inventory_id VARCHAR2) IS
    SELECT cd.document_key, cd.record_status,cd.accrual_ind
      FROM cont_doc cd
     WHERE cd.object_id        = cp_contract_id
       AND cd.summary_setup_id = cp_summary_setup_id
       AND NVL(cd.inventory_id,'XX')     = NVL(cp_inventory_id,'XX')
       AND cd.document_type    = 'SUMMARY'
       AND cd.period           = trunc(cp_daytime, 'MM')
       AND cd.created_date     = (SELECT MAX(created_date)
                                    FROM cont_doc cdo
                                   WHERE cdo.object_id        = cd.object_id
                                     AND cdo.summary_setup_id = cd.summary_setup_id
                                     AND cdo.document_type    = 'SUMMARY'
                                     AND NVL(cdo.inventory_id,'XX')     = NVL(cd.inventory_id,'XX')
                                     AND cdo.period           = cd.period);

  CURSOR c_prec_journal_entry(cp_document_key VARCHAR2, cp_daytime DATE) IS
    SELECT cjs.tag, (NVL(cjs.actual_amount,0)+NVL(cjs.amount_adjustment,0)) amount, (NVL(cjs.actual_qty_1,0)+NVL(cjs.qty_adjustment,0)) qty
      FROM cont_journal_summary cjs
     WHERE cjs.document_key    = cp_document_key
         AND cjs.daytime       = cp_daytime;

  CURSOR c_last_summary_doc(cp_contract_id VARCHAR2, cp_parent_sum_setup_id VARCHAR2, cp_daytime DATE) IS
        SELECT cd1.document_key
          FROM cont_doc cd1, Summary_Setup_Version ssv
         WHERE cd1.summary_setup_id = ssv.object_id
           AND ssv.daytime = (SELECT MAX(daytime) FROM Summary_Setup_Version WHERE object_id = ssv.object_id AND daytime <= cp_daytime)
           AND cd1.object_id = cp_contract_id
           AND cd1.summary_setup_id = cp_parent_sum_setup_id
           AND cd1.period = TRUNC(cp_daytime, 'MM')
           AND cd1.record_status IN ('A','V')
           AND cd1.created_date = (SELECT MAX(created_date)
                                     FROM cont_doc cd2
                                    WHERE cd2.object_id = cd1.object_id
                                      AND cd2.summary_setup_id = cd1.summary_setup_id
                                      AND cd2.period = cd1.period
                                      AND cd2.record_status IN ('A','V'));

  CURSOR c_tag_value(cp_document_key VARCHAR2,cp_tag VARCHAR2) IS
      SELECT cjs.actual_amount, cjs.actual_qty_1
        FROM cont_journal_summary cjs
       WHERE cjs.document_key = cp_document_key
         AND cjs.tag = cp_tag;


  cv            cv_type;
  cur           cv_type;
  lv2_sqlQuery  VARCHAR2(2000) := NULL;
  lv2_Query     VARCHAR2(2000) := NULL;

  ln_val         NUMBER := NULL;
  ln_qty         NUMBER := NULL;
  ln_doc_key     cont_doc.document_key%TYPE;
  ln_accrual_ind cont_doc.accrual_ind%TYPE;
  lrec_doc       cont_doc%ROWTYPE;
  lrec_ssv       summary_setup_version%ROWTYPE := ec_summary_setup_version.row_by_pk(p_summary_setup_id, p_period, '<=');
  lrec_cjs       cont_journal_summary%ROWTYPE;
  lv2_doc_key    VARCHAR2(32);
  lv2_company_id VARCHAR2(32);
  lb_found       BOOLEAN;
  lb_notfound    BOOLEAN := FALSE;
  lv2_prec_doc_key VARCHAR2(32);
  ln_prec_amount NUMBER := NULL;
  ln_prec_qty    NUMBER := NULL;
  lt_prec_sum    tbl_Summary;
  lv2_fiscal_year VARCHAR2(4);
  lv2_doc_last   VARCHAR2(32);
  lv2_dataset    VARCHAR2(32);
  lv2_period     DATE;
  lv2_count      NUMBER:=0;
  lv2_user_log_desc_h VARCHAR2(32) := 'Process Data Extract ';
  user_log_item_info SUMMARY_PC_USER_LOG_ITEM_INFO;
  lv2_prev_doc_key VARCHAR2(1000);

  prec_doc_not_approved EXCEPTION;
  forecast_parent_not_found EXCEPTION;
  contract_id_not_exist EXCEPTION;
  dataset_not_provided EXCEPTION;
  prec_doc_is_final EXCEPTION;
  prev_doc_is_accrual EXCEPTION;

BEGIN

  lv2_period := TRUNC(p_period, 'DD');

  user_log_item_info.LOG_NO := p_user_log_no;
  user_log_item_info.LOG_ITEM_SOURCE := 'EcDP_RR_Revn_Summary.CreateSummaryMonth';
  user_log_item_info.PARAM_PERIOD := lv2_period;
  user_log_item_info.PARAM_SUMMARY_ID := p_summary_setup_id;
  user_log_item_info.PARAM_CONTRACT_ID := p_contract_id;
  user_log_item_info.PARAM_DATA_SET := (CASE p_dataset_filter_method WHEN 'SPECIFIED_DATASET' THEN p_dataset ELSE NULL END);

  IF p_user_log_no IS NULL THEN
    user_log_item_info.LOG_NO := CreateSummaryProcessLog(ECDP_REVN_LOG.LOG_STATUS_RUNNING, lv2_user_log_desc_h);
    UpdateSummaryProcessLog(user_log_item_info.LOG_NO, NULL, NULL,
        user_log_item_info.PARAM_DATA_SET, lv2_period, NULL, p_summary_setup_id, user_log_item_info.PARAM_CONTRACT_ID);
  END IF;

    select count(*) INTO Schedule_count
      from (select replace(utl_raw.cast_to_varchar2(DBMS_LOB.SUBSTR(JOB_DATA,4000)),'\:',':') args from qrtz_triggers
      where (trigger_state!='COMPLETE' or ecdp_scheduler.isJobExecuting(trigger_name, trigger_group)='Y')
       and trigger_name like 'DataExtractProcess--!##RERUN##!%') x
   where INSTR(x.args,'PERIOD=' || to_char(p_period,'YYYY-MM-DD"T"HH24:MI:SS'))> 0
				 and (INSTR(x.args,'INVENTORY_ID' || p_inventory_id) > 0 OR (INSTR(x.args,'INVENTORY_ID')=0 AND p_inventory_id IS NULL))
				 and INSTR(x.args,'CONTRACT_ID=' || p_contract_id) > 0
				 and (INSTR(x.args,'DATASET=' || p_dataset) > 0 OR (INSTR(x.args,'DATASET')=0 AND p_dataset IS NULL))
         and (INSTR(x.args,'DATASET_FILTER_METHOD=' || p_dataset_filter_method) > 0 OR (INSTR(x.args,'DATASET_FILTER_METHOD')=0 AND p_dataset_filter_method IS NULL))
         and INSTR(x.args,'SUMMARY_SETUP_ID=' || p_summary_setup_id) > 0
				 and INSTR(x.args,'ACCRUAL_IND='|| p_accrual_ind) > 0 ;
  IF Schedule_count > 1 THEN
        CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_INFO, 'Not able to execute. The Extract Mapping schedule is already running. Please refresh to get status');
        UpdateSummaryProcessLog(user_log_item_info.LOG_NO, ECDP_REVN_LOG.log_status_error);
  ELSE


  CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_INFO, 'Start to process Data Extract ' || ec_summary_setup.object_code(p_summary_setup_id) || ' for period ' || lv2_period || ', project ' || ec_contract.object_code(p_contract_id));


  IF p_dataset_filter_method = 'SPECIFIED_DATASET' THEN
    lv2_dataset := p_dataset;

    IF lv2_dataset IS NULL THEN
      RAISE dataset_not_provided;
    END IF;

    CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_INFO, 'Only Data Extract Setup List Item with dataset ' || lv2_dataset || ' is processed');

  END IF;





  lt_prec_sum := tbl_Summary(); -- Initialize

  lv2_company_id := ec_contract_version.company_id(p_contract_id, lv2_period, '<=');
  lv2_fiscal_year := to_char(ecdp_rr_revn_common.GetCurrentReportingPeriod(p_contract_id,lv2_period),'YYYY');


  -- Create a Data Extract document
  lrec_doc.object_id        := p_contract_id;
  lrec_doc.daytime          := TRUNC(Ecdp_Timestamp.getCurrentSysdate, 'DD');
  lrec_doc.document_type    := 'SUMMARY';
  lrec_doc.summary_setup_id := p_summary_setup_id;
  lrec_doc.period           := trunc(lv2_period, 'MM');
  lrec_doc.created_by       := p_user_id;
  lrec_doc.accrual_ind      := p_accrual_ind;
  lrec_doc.inventory_id     := p_inventory_id;

  -- INSTEAD OF user-exit
  IF ue_RR_Revn_Summary.isCreateSummaryMonthUEE = 'TRUE' THEN
    CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_DEBUG, 'Instead-of user exit is enabled, call the user exit');

    ue_RR_Revn_Summary.CreateSummaryMonth(lrec_doc, p_contract_id, p_summary_setup_id, lv2_period);

    CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_DEBUG, 'Instead-of user exit finished.');
  ELSE

    -- PRE user-exit
    IF ue_RR_Revn_Summary.isCreateSummaryMonthPreUEE = 'TRUE' THEN
      CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_DEBUG, 'PRE user exit is enabled, call the user exit');

      ue_RR_Revn_Summary.CreateSummaryMonthPre(lrec_doc, p_contract_id, p_summary_setup_id, lv2_period);

      CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_DEBUG, 'PRE user exit finished.');
    END IF;


    -- Check for approved preceding Data Extract for same month

    FOR cl_preceding_doc IN c_prec_doc(p_contract_id, p_summary_setup_id, lv2_period,p_inventory_id) LOOP
        lv2_prec_doc_key := cl_preceding_doc.document_key;

        IF nvl(cl_preceding_doc.Record_Status,'X') = 'P' THEN
		   CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_WARNING, 'Preceding Data Extract (' || lv2_prec_doc_key || ') for the same month has not been Verified/Approved.');
		   RAISE prec_doc_not_approved;
        END IF;

        IF cl_preceding_doc.accrual_ind='N' AND p_accrual_ind='Y' THEN
           RAISE prec_doc_is_final;
        END IF;

        FOR cl_journal_entry IN c_prec_journal_entry(cl_preceding_doc.document_key, lv2_period) LOOP
            -- Store all the preceding Data Extract doc values.
            -- Fast lookup when setting amend values on new Data Extract.
            IF cl_preceding_doc.accrual_ind = p_accrual_ind  THEN
               lt_prec_sum.EXTEND;
               lt_prec_sum(lt_prec_sum.LAST).tag    := cl_journal_entry.Tag;
               lt_prec_sum(lt_prec_sum.LAST).amount := cl_journal_entry.Amount;
               lt_prec_sum(lt_prec_sum.LAST).qty    := cl_journal_entry.qty;
            END IF;
        END LOOP;
    END LOOP;

    -- Validate the contract id
    IF ec_contract.start_date(p_contract_id) IS NULL THEN
        RAISE contract_id_not_exist;
    END IF;

    -- Create the document
    lrec_doc.preceding_document_key := lv2_prec_doc_key;
    lv2_doc_key := ecdp_rr_revn_common.CreateDocument(lrec_doc, 'CONT_SUMMARY_DOC');
    user_log_item_info.PARAM_DOCUMENT_KEY := lv2_doc_key;

    CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_INFO, 'Data Extract document has been created, the document key is ' || lv2_doc_key || ', preceding document key is ' || lv2_prec_doc_key);

    CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_DEBUG, 'Data Extract setup type is ' || lrec_ssv.summary_type);

    IF lrec_ssv.summary_type = 'ACTUAL' THEN

      FOR rsSL IN c_sl(p_summary_setup_id, lv2_period, lv2_dataset) LOOP

        CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_DEBUG, 'Processing Data Extract List Item, tag: ' || rsSL.TAG);

        lv2_sqlQuery := BuildSQLQuery(ec_summary_setup_list.row_by_pk(rsSL.object_id, rsSL.list_item_key), p_contract_id, lv2_period,p_inventory_id);


        IF NOT (ec_summary_setup_list.source_time_concept(rsSL.object_id, rsSL.list_item_key)='YTD' AND ec_summary_setup_list.target_time_concept(rsSL.object_id, rsSL.list_item_key)<>'YTD' AND trunc(p_period, 'MM') <> trunc(p_period, 'YYYY')) THEN


        lv2_Query    :='SELECT distinct j.document_key,ec_cont_doc.accrual_ind(j.document_key)'|| REGEXP_REPLACE(regexp_substr(lv2_sqlQuery,'FROM(.*)'),'GROUP BY(.*)',null)
                       ||'AND NOT EXISTS(SELECT cd.document_key FROM cont_doc cd WHERE cd.preceding_document_key=j.document_key AND cd.RECORD_status IN(''A'',''V''))';


        OPEN cur FOR lv2_Query;
            LOOP
              FETCH cur INTO ln_doc_key,ln_accrual_ind;
               EXIT WHEN cur%notfound;
              IF(ln_accrual_ind='Y' and p_accrual_ind='N') THEN
               lv2_count := lv2_count + 1;
               lv2_prev_doc_key:=lv2_prev_doc_key||CASE WHEN lv2_prev_doc_key IS NOT NULL THEN ',' END||ln_doc_key;
              END IF;
            END LOOP;
         CLOSE cur;
        END IF;
        SetPrecedingSummaryTagValue(lt_prec_sum, rsSL.Tag, ln_prec_amount, ln_prec_qty);

        CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_DEBUG, 'Preceding values for tag ' || rsSL.TAG || ' Amount: ' || ln_prec_amount || ', Quantity: ' || ln_prec_qty);

        BEGIN

          PrepareInsertRecord(lrec_cjs, p_contract_id, lv2_company_id, lv2_fiscal_year, lv2_period, TRUNC(lv2_period, 'MM'));

          CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_DEBUG, 'Query for getting values for Data Extract list: ' || lv2_sqlQuery);


          OPEN cv FOR lv2_sqlQuery;
            LOOP
                 FETCH cv INTO ln_val,ln_qty;

                 lb_notfound := cv%NOTFOUND;

--               RAISE_APPLICATION_ERROR(-20000, 'Not found: ' || CASE lb_notfound WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END);

                 -- Common values for found/not found values
                 lrec_cjs.document_key         := lv2_doc_key;
                 lrec_cjs.list_item_key        := rsSL.list_item_key;
                 lrec_cjs.summary_setup_id     := rsSL.object_id;
                 lrec_cjs.dataset              := rsSL.dataset;
                 lrec_cjs.tag                  := rsSL.tag;
                 lrec_cjs.label                := rsSL.label;
                 lrec_cjs.fin_account_id       := rsSL.fin_account_id;
                 lrec_cjs.fin_cost_center_id   := rsSL.fin_cost_center_id;
                 lrec_cjs.fin_revenue_order_id := rsSL.fin_revenue_order_id;
                 lrec_cjs.fin_wbs_id           := rsSL.fin_wbs_id;
                 lrec_cjs.uom1_code            := rsSL.uom1_code;
                 lrec_cjs.currency_id          := rsSL.currency_id;
                 lrec_cjs.created_by           := p_user_id;

                 IF lb_notfound = FALSE THEN

                   -- Insert Data Extract record
                   lrec_cjs.actual_amount        := CASE WHEN rsSL.value_type = 'QUANTITY' THEN NULL ELSE ln_val END;
                   lrec_cjs.actual_qty_1         := CASE WHEN rsSL.value_type = 'MONETARY' THEN NULL ELSE ln_qty END;
                   lrec_cjs.amend_amount         := ln_prec_amount;
                   lrec_cjs.amend_qty_1          := ln_prec_qty;

                   CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_DEBUG, 'Values found for tag ' || rsSL.TAG || ', Amount: ' || lrec_cjs.actual_amount || ', Quantity: ' || lrec_cjs.actual_qty_1);

                 ELSE

                   -- Insert zero value Data Extract record
                   lrec_cjs.actual_amount        := CASE WHEN rsSL.value_type = 'QUANTITY' THEN NULL ELSE 0 END;
                   lrec_cjs.actual_qty_1         := CASE WHEN rsSL.value_type = 'MONETARY' THEN NULL ELSE 0 END;
                   lrec_cjs.amend_amount         := ln_prec_amount;
                   lrec_cjs.amend_qty_1          := ln_prec_qty;

                   CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_DEBUG, 'Values not found for tag ' || rsSL.TAG);

                 END IF;

                 InsertSummaryRecord(lrec_cjs);
                 EXIT;

            END LOOP;
            CLOSE cv;

        END;

      END LOOP;

    ELSIF lrec_ssv.summary_type = 'CARE_REVN' THEN

       ue_rr_revn_summary.Revn_CreateSummaryMonth(lrec_doc, p_contract_id, p_summary_setup_id, lv2_period, lrec_cjs);


    ELSIF lrec_ssv.summary_type = 'FORECAST' THEN

      -- In Data Extract setup the parent Data Extract setup is set up with ACTUAL or FORECAST.
      -- This is why populating one forecast period will automatically determine if this is LAST_ACTUAL or LAST_FORECAST.
      -- Currently no need for differentiation between these when populating.

      PrepareInsertRecord(lrec_cjs, p_contract_id, lv2_company_id, lv2_fiscal_year, lv2_period, TRUNC(lv2_period, 'MM'));

      IF lrec_ssv.populate_method IN ('LAST_ACTUAL','LAST_FORECAST') THEN

        -- Get the sumamry document that is the last approved actual
        FOR rsDoc IN c_last_summary_doc(p_contract_id, lrec_ssv.parent_sum_setup_id, lv2_period) LOOP

          lv2_doc_last := rsDoc.document_key;

        END LOOP;

        IF lv2_doc_last IS NOT NULL THEN

          -- Set reference to parent document
          UPDATE cont_doc cd SET cd.parent_document_key = lv2_doc_last WHERE cd.document_key = lv2_doc_key;


          -- Look for the forecast tag in the document and use this value as forecast
          FOR rsLA IN c_sl(p_summary_setup_id, lv2_period, lv2_dataset) LOOP


              SetPrecedingSummaryTagValue(lt_prec_sum, rsLA.Tag, ln_prec_amount, ln_prec_qty);


              lb_found := FALSE;

              -- Common values for found/not found values
              lrec_cjs.document_key         := lv2_doc_key;
              lrec_cjs.list_item_key        := rsLA.list_item_key;
              lrec_cjs.summary_setup_id     := rsLA.object_id;
              lrec_cjs.dataset              := rsLA.dataset;
              lrec_cjs.tag                  := rsLA.tag;
              lrec_cjs.label                := rsLA.label;
              lrec_cjs.fin_account_id       := rsLA.fin_account_id;
              lrec_cjs.fin_cost_center_id   := rsLA.fin_cost_center_id;
              lrec_cjs.fin_revenue_order_id := rsLA.fin_revenue_order_id;
              lrec_cjs.fin_wbs_id           := rsLA.fin_wbs_id;
              lrec_cjs.uom1_code            := rsLA.uom1_code;
              lrec_cjs.currency_id          := rsLA.currency_id;
              lrec_cjs.created_by           := p_user_id;


              FOR rsTV IN c_tag_value(lv2_doc_last, rsLA.tag) LOOP

                lb_found := TRUE;

                -- Insert forecast/estimate record
                lrec_cjs.actual_amount        := rsTV.actual_amount;
                lrec_cjs.actual_qty_1         := rsTV.actual_qty_1;
                lrec_cjs.amend_amount         := ln_prec_amount;
                lrec_cjs.amend_qty_1          := ln_prec_qty;

                InsertSummaryRecord(lrec_cjs);

              END LOOP;

              -- Tag was not found within the parent Data Extract. Create zero value row.
              IF NOT lb_found THEN

                lrec_cjs.actual_amount        := CASE WHEN rsLA.value_type = 'QUANTITY' THEN NULL ELSE 0 END;
                lrec_cjs.actual_qty_1         := CASE WHEN rsLA.value_type = 'MONETARY' THEN NULL ELSE 0 END;
                lrec_cjs.amend_amount         := NULL;
                lrec_cjs.amend_qty_1          := NULL;

                InsertSummaryRecord(lrec_cjs);

              END IF;

          END LOOP;

        ELSE

          RAISE forecast_parent_not_found;

        END IF;

      ELSIF lrec_ssv.populate_method = 'MANUAL' THEN

        PrepareInsertRecord(lrec_cjs, p_contract_id, lv2_company_id, lv2_fiscal_year, lv2_period, TRUNC(lv2_period, 'MM'));

        -- Loop over setup list and create an empty record per list item.
        FOR rsMA IN c_sl(p_summary_setup_id, lv2_period, lv2_dataset) LOOP

            SetPrecedingSummaryTagValue(lt_prec_sum, rsMA.Tag, ln_prec_amount, ln_prec_qty);

            lrec_cjs.document_key         := lv2_doc_key;
            lrec_cjs.list_item_key        := rsMA.list_item_key;
            lrec_cjs.summary_setup_id     := rsMA.object_id;
            lrec_cjs.dataset              := rsMA.dataset;
            lrec_cjs.tag                  := rsMA.tag;
            lrec_cjs.label                := rsMA.label;
            lrec_cjs.fin_account_id       := rsMA.fin_account_id;
            lrec_cjs.fin_cost_center_id   := rsMA.fin_cost_center_id;
            lrec_cjs.fin_revenue_order_id := rsMA.fin_revenue_order_id;
            lrec_cjs.fin_wbs_id           := rsMA.fin_wbs_id;
            lrec_cjs.uom1_code            := rsMA.uom1_code;
            lrec_cjs.currency_id          := rsMA.currency_id;
            lrec_cjs.actual_amount        := CASE WHEN rsMA.value_type = 'MONETARY' THEN 0 ELSE NULL END;
            lrec_cjs.actual_qty_1         := CASE WHEN rsMA.value_type = 'QUANTITY' THEN 0 ELSE NULL END;
            lrec_cjs.amend_amount         := ln_prec_amount;
            lrec_cjs.amend_qty_1          := ln_prec_qty;
            lrec_cjs.created_by           := p_user_id;

            InsertSummaryRecord(lrec_cjs);

        END LOOP;

      ELSIF lrec_ssv.populate_method = 'PREV_MONTH' THEN

        -- Get the sumamry document that is the last approved actual
        FOR rsDoc IN c_last_summary_doc(p_contract_id, p_summary_setup_id, add_months(lv2_period, -1)) LOOP

          lv2_doc_last := rsDoc.document_key;

        END LOOP;

        IF lv2_doc_last IS NOT NULL THEN

          -- Set reference to parent document
          UPDATE cont_doc cd SET cd.parent_document_key = lv2_doc_last WHERE cd.document_key = lv2_doc_key;

          -- Look for the forecast tag in the document and use this value as forecast
          FOR rsLA IN c_sl(p_summary_setup_id, add_months(lv2_period, -1), lv2_dataset) LOOP


              SetPrecedingSummaryTagValue(lt_prec_sum, rsLA.Tag, ln_prec_amount, ln_prec_qty);


              lb_found := FALSE;

              -- Common values for found/not found values
              lrec_cjs.document_key         := lv2_doc_key;
              lrec_cjs.list_item_key        := rsLA.list_item_key;
              lrec_cjs.summary_setup_id     := rsLA.object_id;
              lrec_cjs.dataset              := rsLA.dataset;
              lrec_cjs.tag                  := rsLA.tag;
              lrec_cjs.label                := rsLA.label;
              lrec_cjs.fin_account_id       := rsLA.fin_account_id;
              lrec_cjs.fin_cost_center_id   := rsLA.fin_cost_center_id;
              lrec_cjs.fin_revenue_order_id := rsLA.fin_revenue_order_id;
              lrec_cjs.fin_wbs_id           := rsLA.fin_wbs_id;
              lrec_cjs.uom1_code            := rsLA.uom1_code;
              lrec_cjs.currency_id          := rsLA.currency_id;
              lrec_cjs.created_by           := p_user_id;


              FOR rsTV IN c_tag_value(lv2_doc_last, rsLA.tag) LOOP

                lb_found := TRUE;

                -- Insert forecast/estimate record
                lrec_cjs.actual_amount        := rsTV.actual_amount;
                lrec_cjs.actual_qty_1         := rsTV.actual_qty_1;
                lrec_cjs.amend_amount         := ln_prec_amount;
                lrec_cjs.amend_qty_1          := ln_prec_qty;

                InsertSummaryRecord(lrec_cjs);

              END LOOP;

              -- Tag was not found within the parent Data Extract. Create zero value row.
              IF NOT lb_found THEN

                lrec_cjs.actual_amount        := CASE WHEN rsLA.value_type = 'QUANTITY' THEN NULL ELSE 0 END;
                lrec_cjs.actual_qty_1         := CASE WHEN rsLA.value_type = 'MONETARY' THEN NULL ELSE 0 END;
                lrec_cjs.amend_amount         := NULL;
                lrec_cjs.amend_qty_1          := NULL;

                InsertSummaryRecord(lrec_cjs);

              END IF;

          END LOOP;

        ELSE

          PrepareInsertRecord(lrec_cjs, p_contract_id, lv2_company_id, lv2_fiscal_year, lv2_period, TRUNC(lv2_period, 'MM'));

          -- Loop over setup list and create an empty record per list item.
          FOR rsMA IN c_sl(p_summary_setup_id, lv2_period, lv2_dataset) LOOP

              SetPrecedingSummaryTagValue(lt_prec_sum, rsMA.Tag, ln_prec_amount, ln_prec_qty);

              lrec_cjs.document_key         := lv2_doc_key;
              lrec_cjs.list_item_key        := rsMA.list_item_key;
              lrec_cjs.summary_setup_id     := rsMA.object_id;
              lrec_cjs.dataset              := rsMA.dataset;
              lrec_cjs.tag                  := rsMA.tag;
              lrec_cjs.label                := rsMA.label;
              lrec_cjs.fin_account_id       := rsMA.fin_account_id;
              lrec_cjs.fin_cost_center_id   := rsMA.fin_cost_center_id;
              lrec_cjs.fin_revenue_order_id := rsMA.fin_revenue_order_id;
              lrec_cjs.fin_wbs_id           := rsMA.fin_wbs_id;
              lrec_cjs.uom1_code            := rsMA.uom1_code;
              lrec_cjs.currency_id          := rsMA.currency_id;
              lrec_cjs.actual_amount        := CASE WHEN rsMA.value_type = 'QUANTITY' THEN NULL ELSE 0 END;
              lrec_cjs.actual_qty_1         := CASE WHEN rsMA.value_type = 'MONETARY'THEN NULL ELSE 0 END;
              lrec_cjs.amend_amount         := ln_prec_amount;
              lrec_cjs.amend_qty_1          := ln_prec_qty;
              lrec_cjs.created_by           := p_user_id;

              InsertSummaryRecord(lrec_cjs);

          END LOOP;

        END IF;

      END IF;


    END IF; -- Data Extract Type

    -- POST user-exit
    IF ue_RR_Revn_Summary.isCreateSummaryMonthPostUEE = 'TRUE' THEN
        CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_DEBUG, 'POST user exit is enabled, call the user exit');

        ue_RR_Revn_Summary.CreateSummaryMonthPost(lrec_cjs, p_contract_id, p_summary_setup_id, lv2_period);

        CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_DEBUG, 'POST user exit returned');
    END IF;

    -- Generate Data Extract tracing information
    CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_INFO, 'Generating Data Extract tracing information');

    IF lv2_prev_doc_key IS NOT NULL THEN
      RAISE prev_doc_is_accrual;
    END IF;

    IF p_silent_mode_ind != 'Y' THEN

       CreateSummaryTracing(lrec_cjs.document_key, lrec_cjs.period);
       Ecdp_Dataset_Flow.InsJEDataToDS(lrec_cjs.document_key);

    END IF;
    IF p_user_log_no IS NULL THEN
      UpdateSummaryProcessLog(user_log_item_info.LOG_NO, ECDP_REVN_LOG.LOG_STATUS_SUCCESS);
    END IF;

  END IF; -- INSTEAD OF user-exit

  CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_INFO, 'Data Extract process finished successfully');
  END IF;

EXCEPTION
  WHEN prec_doc_not_approved THEN
    IF p_user_log_no IS NULL THEN
      UpdateSummaryProcessLog(user_log_item_info.LOG_NO, ECDP_REVN_LOG.LOG_STATUS_ERROR);
    END IF;

    RAISE_APPLICATION_ERROR(-20000, 'Can not create Data Extract.\n\nPreceding Data Extract (' || lv2_prec_doc_key || ') for the same month has not been Verified/Approved.');

  WHEN forecast_parent_not_found THEN
    CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_ERROR, 'Can not create forecast Data Extract. Verified/Approved parent Data Extract (Method: ' || lrec_ssv.populate_method || ') for the same month can not be found.');

    IF p_user_log_no IS NULL THEN
      UpdateSummaryProcessLog(user_log_item_info.LOG_NO, ECDP_REVN_LOG.LOG_STATUS_ERROR);
    END IF;

    RAISE_APPLICATION_ERROR(-20000, 'Can not create forecast Data Extract.\n\nVerified/Approved parent Data Extract (Method: ' || lrec_ssv.populate_method || ') for the same month can not be found.');

  WHEN contract_id_not_exist THEN
    CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_ERROR, 'Can not create Data Extract. Project id ' || p_contract_id || ' is invalid.');

    IF p_user_log_no IS NULL THEN
      UpdateSummaryProcessLog(user_log_item_info.LOG_NO, ECDP_REVN_LOG.LOG_STATUS_ERROR);
    END IF;

    RAISE_APPLICATION_ERROR(-20000, 'Can not create Data Extract. Project id ' || p_contract_id || ' is invalid.');

  WHEN dataset_not_provided THEN
    CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_ERROR, 'Can not create Data Extract. Dataset Filter Type is set to ''SPECIFIED_DATASET'' but Dataset is not specified.');

    IF p_user_log_no IS NULL THEN
      UpdateSummaryProcessLog(user_log_item_info.LOG_NO, ECDP_REVN_LOG.LOG_STATUS_ERROR);
    END IF;

    RAISE_APPLICATION_ERROR(-20000, 'Can not create Data Extract. Dataset Filter Type is set to ''SPECIFIED_DATASET'' but Dataset is not specified.');
  WHEN prec_doc_is_final THEN
       CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_ERROR, 'Can not create Accrual Data Extract on Final preceding Data Extract. Preceding Data Extract (' || lv2_prec_doc_key || ') for the same month is Final.');

    IF p_user_log_no IS NULL THEN
      UpdateSummaryProcessLog(user_log_item_info.LOG_NO, ECDP_REVN_LOG.LOG_STATUS_ERROR);
    END IF;

    RAISE_APPLICATION_ERROR(-20000, 'Can not create Accrual Data Extract on Final preceding Data Extract.\n\nPreceding Data Extract (' || lv2_prec_doc_key || ') for the same month is Final.');

  WHEN prev_doc_is_accrual THEN
     CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_ERROR, 'Cannot create a Final Extract Document using Accrual Data Mapping Document.The latest Data Mapping document (' || lv2_prev_doc_key || (case when lv2_count> 1 then ')  are Accrual.' else ')  is an Accrual.' end));

    IF p_user_log_no IS NULL THEN
      UpdateSummaryProcessLog(user_log_item_info.LOG_NO, ECDP_REVN_LOG.LOG_STATUS_ERROR);
    END IF;

    RAISE_APPLICATION_ERROR(-20000, 'Cannot create a Final Extract Document using Accrual Data Mapping Document.\n\n Latest Data Mapping document (' || lv2_prev_doc_key || (case  when lv2_count >1 then ')  are Accrual.' else ')  is an Accrual.' end));

  WHEN OTHERS THEN
    CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_ERROR, 'Can not create Data Extract. Unknown error occurred (' || SQLCODE || ') ' || '. ' || SQLERRM);

    IF p_user_log_no IS NULL THEN
      UpdateSummaryProcessLog(user_log_item_info.LOG_NO, ECDP_REVN_LOG.LOG_STATUS_ERROR);
    END IF;

    RAISE_APPLICATION_ERROR(-20000, 'Can not create Data Extract. Unknown error occurred (' || SQLCODE || ') ' || '. ' || SQLERRM);

END CreateSummaryMonth;

----------------------------------------------------------------------------------------------------------------------------------------------------

FUNCTION BuildSQLQuery(
         p_rec_ssl                  summary_setup_list%ROWTYPE,
         p_contract_id              VARCHAR2,
         p_period                   DATE,
         p_inventory_id             VARCHAR2 DEFAULT NULL
)
RETURN VARCHAR2
IS

  lv2_period         VARCHAR2(120);
  lv2_inc_period     VARCHAR2(120);
  lv2_valid_from     VARCHAR2(120);
  lv2_start_period   VARCHAR2(120);
  lv2_sqlQuery       VARCHAR2(3000) := NULL;
  lv2_sqlBaseQuery   VARCHAR2(2000) := NULL;
  lv2_sqlSelect      VARCHAR2(500)  := NULL;
  lv2_sqlClause      VARCHAR2(500)  := NULL;
  lv2_sqlDateClause  VARCHAR2(500)   := NULL;
  lv2_sqlGroup       VARCHAR2(128)  := NULL;
  lv2_retQuery       VARCHAR2(2000) := NULL;

  cv                cv_type;
  ld_first_period   DATE    := NULL;
  ld_inc_period     DATE;
  ln_count          NUMBER  := 0;

BEGIN

   lv2_period         := 'to_date(''' || to_char(p_period, 'YYYY')                 || '-' || to_char(p_period, 'MM')                 || '-01'', ''YYYY-MM-DD'')';
   lv2_valid_from     := 'to_date(''' || to_char(p_rec_ssl.daytime, 'YYYY')        || '-' || to_char(p_rec_ssl.daytime, 'MM')        || '-01'', ''YYYY-MM-DD'')';

   -- Create the base query for summing up values based on Data Extract setup list
   lv2_sqlSelect := 'SELECT ';

   IF p_rec_ssl.value_type IN ( 'MONETARY','BOTH')  THEN

      lv2_sqlSelect := lv2_sqlSelect || ' SUM(j.amount) SUM_VAL ';

   ELSE
      lv2_sqlSelect := lv2_sqlSelect || ' SUM(NULL) SUM_VAL';
   END IF;
   IF p_rec_ssl.value_type IN ( 'QUANTITY','BOTH') THEN


        lv2_sqlSelect := lv2_sqlSelect || ', SUM(j.qty_1) SUM_QTY ';

   ELSE

        lv2_sqlSelect := lv2_sqlSelect || ', NULL SUM_QTY';

   END IF;

   lv2_sqlSelect := lv2_sqlSelect || '  FROM cont_journal_entry j ';

   -- Build the base where-clause, always containing contract
   lv2_sqlClause := ' WHERE j.contract_code = ''' || ec_contract.object_code(p_contract_id) || '''';
   lv2_sqlClause := lv2_sqlClause || ' AND (NVL(j.record_status,''P'') = ''A'' OR NVL(j.record_status,''P'') = ''V'')';

   -- Always start the group by expression with contract
   lv2_sqlGroup :=  ' j.contract_code';

   lv2_sqlClause := lv2_sqlClause || ' AND (j.TAG) = ''' || p_rec_ssl.Tag ||'''';

   -- Separate clause for the period date checks
   lv2_sqlDateClause := ' AND TRUNC(j.period,''MM'') = ' || lv2_period;


   -- Check for Dataset
   IF p_rec_ssl.dataset IS NOT NULL THEN

     -- Add where clause statements
     lv2_sqlClause := lv2_sqlClause || ' AND j.dataset = ''' || p_rec_ssl.dataset || '''';

     -- Add group-by expression
     IF lv2_sqlGroup IS NOT NULL THEN
       lv2_sqlGroup := lv2_sqlGroup || ',';
     END IF;
     lv2_sqlGroup := lv2_sqlGroup || ' j.dataset';

   END IF;

   -- Check for GL / Fin account
   IF p_rec_ssl.fin_account_id IS NOT NULL THEN

     -- Add where clause statements
     lv2_sqlClause := lv2_sqlClause || ' AND j.fin_account_code = ''' || ec_fin_account.object_code(p_rec_ssl.fin_account_id) || '''';

     -- Add group-by expression
     IF lv2_sqlGroup IS NOT NULL THEN
       lv2_sqlGroup := lv2_sqlGroup || ',';
     END IF;
     lv2_sqlGroup := lv2_sqlGroup || ' j.fin_account_code';

   END IF;


   -- Check for Cost Center
   IF p_rec_ssl.fin_cost_center_id IS NOT NULL THEN

     -- Add where clause statements
     lv2_sqlClause := lv2_sqlClause || ' AND j.fin_cost_center_code = ''' || ec_fin_cost_center.object_code(p_rec_ssl.fin_cost_center_id) || '''';

     -- Add group-by expression
     IF lv2_sqlGroup IS NOT NULL THEN
       lv2_sqlGroup := lv2_sqlGroup || ',';
     END IF;
     lv2_sqlGroup := lv2_sqlGroup || ' j.fin_cost_center_code';

   END IF;


   -- Check for WBS
   IF p_rec_ssl.fin_wbs_id IS NOT NULL THEN

     -- Add where clause statements
     lv2_sqlClause := lv2_sqlClause || ' AND j.fin_wbs_code = ''' || ec_fin_wbs.object_code(p_rec_ssl.fin_wbs_id) || '''';

     -- Add group-by expression
     IF lv2_sqlGroup IS NOT NULL THEN
       lv2_sqlGroup := lv2_sqlGroup || ',';
     END IF;
     lv2_sqlGroup := lv2_sqlGroup || ' j.fin_wbs_code';

   END IF;

   IF p_rec_ssl.inventory_id IS NOT NULL THEN

      lv2_sqlClause := lv2_sqlClause || ' AND j.inventory_id = ''' || p_rec_ssl.inventory_id || '''';

     -- Add group-by expression
     IF lv2_sqlGroup IS NOT NULL THEN
       lv2_sqlGroup := lv2_sqlGroup || ',';
     END IF;

     lv2_sqlGroup := lv2_sqlGroup || ' j.inventory_id';

     ELSIF p_rec_ssl.inventory_id IS NULL AND p_inventory_id IS NOT NULL THEN

      lv2_sqlClause := lv2_sqlClause || ' AND j.inventory_id = ''' || p_inventory_id || '''';

     -- Add group-by expression
     IF lv2_sqlGroup IS NOT NULL THEN
       lv2_sqlGroup := lv2_sqlGroup || ',';
     END IF;

     lv2_sqlGroup := lv2_sqlGroup || ' j.inventory_id';

   END IF;

   -- Check for Revenue Order
   IF p_rec_ssl.fin_revenue_order_id IS NOT NULL THEN

     -- Add where clause statements
     lv2_sqlClause := lv2_sqlClause || ' AND j.fin_revenue_order_code = ''' || ec_fin_revenue_order.object_code(p_rec_ssl.fin_revenue_order_id) || '''';

     -- Add group-by expression
     IF lv2_sqlGroup IS NOT NULL THEN
       lv2_sqlGroup := lv2_sqlGroup || ',';
     END IF;
     lv2_sqlGroup := lv2_sqlGroup || ' j.fin_revenue_order_code';

   END IF;

   -- Concatenate to get a proper query
   lv2_sqlBaseQuery := lv2_sqlSelect;
   lv2_sqlBaseQuery := lv2_sqlBaseQuery || lv2_sqlClause;
   lv2_sqlBaseQuery := lv2_sqlBaseQuery || lv2_sqlDateClause;
   lv2_sqlBaseQuery := lv2_sqlBaseQuery || (CASE WHEN lv2_sqlGroup IS NOT NULL THEN ' GROUP BY ' || lv2_sqlGroup END);



   -- If source and target concepts are equal, no need to add or deduct previous values.
   IF p_rec_ssl.source_time_concept = p_rec_ssl.target_time_concept THEN

       -- Return the base query as is.
       lv2_retQuery := lv2_sqlBaseQuery;


   ELSIF p_rec_ssl.source_time_concept = 'PERIOD' THEN


      IF p_rec_ssl.target_time_concept = 'YTD' THEN

         -- Sum up values for current year

         -- If current period is january
         IF trunc(p_period, 'MM') = trunc(p_period, 'YYYY') THEN

             -- Return the base query as is.
             lv2_retQuery := lv2_sqlBaseQuery;

         ELSE

             -- Check that validity of ssl goes back to year start. If for some reason not, use daytime as start of YTD.
             IF p_rec_ssl.daytime > trunc(p_period, 'YYYY') THEN

                lv2_start_period := 'to_date(''' || to_char(p_rec_ssl.daytime, 'YYYY') || '-' || to_char(p_rec_ssl.daytime, 'MM') || '-01'', ''YYYY-MM-DD'')';  -- 'YYYY-MM-DD'

             ELSE

                lv2_start_period := 'to_date(''' || to_char(p_period, 'YYYY') || '-' || '01-01'', ''YYYY-MM-DD'')';  -- 'YYYY-MM-DD'

             END IF;


             lv2_sqlQuery := lv2_sqlSelect;
             lv2_sqlQuery := lv2_sqlQuery || lv2_sqlClause;
             lv2_sqlQuery := lv2_sqlQuery || ' AND TRUNC(j.period,''MM'') <= ' || lv2_period; -- Get values from periods earlier than or equal to current period.
             lv2_sqlQuery := lv2_sqlQuery || ' AND TRUNC(j.period,''MM'') >= ' || lv2_start_period; -- Get values from periods that are higher than or equal to the ssl validity start date.
             lv2_sqlQuery := lv2_sqlQuery || (CASE WHEN lv2_sqlGroup IS NOT NULL THEN ' GROUP BY ' || lv2_sqlGroup END);

             lv2_retQuery := lv2_sqlQuery;

         END IF;

      ELSIF p_rec_ssl.target_time_concept = 'TOTAL' THEN


          -- First build query to get start point
          lv2_sqlQuery := 'SELECT min(period) FROM cont_journal_entry j ';
          lv2_sqlQuery := lv2_sqlQuery || lv2_sqlClause;
          lv2_sqlQuery := lv2_sqlQuery || ' AND TRUNC(j.period,''MM'') <= ' || lv2_period;
          lv2_sqlQuery := lv2_sqlQuery || ' AND TRUNC(j.period,''MM'') >= ' || lv2_valid_from;
          lv2_sqlQuery := lv2_sqlQuery || ' AND (j.amount IS NOT NULL OR j.qty_1 IS NOT NULL)';
          lv2_sqlQuery := lv2_sqlQuery || ' AND NVL(j.record_status,''P'') = ''A''';

          -- Get the first period
          OPEN cv FOR lv2_sqlQuery;
               LOOP
                   FETCH cv INTO ld_first_period;
                   EXIT;
               END LOOP;
          CLOSE cv;


          -- If the first period was not found
          IF ld_first_period IS NULL THEN

             -- Return the base query as is.
             lv2_retQuery := lv2_sqlBaseQuery;


          -- If this is the first period
          ELSIF trunc(ld_first_period, 'MM') = trunc(p_period, 'MM') THEN

             -- Return the base query as is.
             lv2_retQuery := lv2_sqlBaseQuery;


          -- If there are periods preceding the current period that we need to sum up
          ELSIF trunc(ld_first_period, 'MM') < trunc(p_period, 'MM') THEN

             lv2_sqlQuery := lv2_sqlSelect;
             lv2_sqlQuery := lv2_sqlQuery || lv2_sqlClause;
             lv2_sqlQuery := lv2_sqlQuery || ' AND TRUNC(j.period,''MM'') <= ' || lv2_period; -- Get values from periods earlier than or equal to current period.
             lv2_sqlQuery := lv2_sqlQuery || ' AND TRUNC(j.period,''MM'') >= ' || lv2_valid_from; -- Get values from periods that are higher than or equal to the ssl validity start date.
             lv2_sqlQuery := lv2_sqlQuery || (CASE WHEN lv2_sqlGroup IS NOT NULL THEN ' GROUP BY ' || lv2_sqlGroup END);

             lv2_retQuery := lv2_sqlQuery;

          END IF;

      END IF;


   ELSIF p_rec_ssl.source_time_concept = 'YTD' THEN


      IF p_rec_ssl.target_time_concept = 'PERIOD' THEN

         -- Get current period value by subtracting previous month's value from this month's value.

         -- If current period is january
         IF trunc(p_period, 'MM') = trunc(p_period, 'YYYY') THEN

            -- Return the base query as is.
            lv2_retQuery := lv2_sqlBaseQuery;

         ELSE

            lv2_sqlQuery := 'SELECT NVL(NOW.SUM_VAL,0)-NVL(NEXT_MONTH.SUM_VAL,0) SUM_VAL,
                             NVL(NOW.SUM_QTY,0)-NVL(NEXT_MONTH.SUM_QTY,0) SUM_QTY ';

            -- Current period value
            lv2_sqlQuery := lv2_sqlQuery || 'from (';
            lv2_sqlQuery := lv2_sqlQuery || lv2_sqlSelect;
            lv2_sqlQuery := lv2_sqlQuery || lv2_sqlClause;
            lv2_sqlQuery := lv2_sqlQuery || lv2_sqlDateClause;
            lv2_sqlQuery := lv2_sqlQuery || ') NOW, (';

            -- Previous period value
            lv2_sqlQuery := lv2_sqlQuery || lv2_sqlSelect;
            lv2_sqlQuery := lv2_sqlQuery || lv2_sqlClause;
            lv2_sqlQuery := lv2_sqlQuery || ' AND TRUNC(j.period,''MM'') = add_months(' || lv2_period || ',-1)';
            lv2_sqlQuery := lv2_sqlQuery || ' ) next_month';
            --lv2_sqlQuery := lv2_sqlQuery || (CASE WHEN lv2_sqlGroup IS NOT NULL THEN ' GROUP BY ' || lv2_sqlGroup END);
            --lv2_sqlQuery := lv2_sqlQuery || '),0)';

            --lv2_sqlQuery := lv2_sqlQuery || ' FROM summary_number WHERE num = 1';

            lv2_retQuery := lv2_sqlQuery;

         END IF;


      ELSIF p_rec_ssl.target_time_concept = 'TOTAL' THEN


          -- First build query to get start point
          lv2_sqlQuery := 'SELECT min(period) FROM cont_journal_entry j ';
          lv2_sqlQuery := lv2_sqlQuery || lv2_sqlClause;
          lv2_sqlQuery := lv2_sqlQuery || ' AND TRUNC(j.period,''MM'') <= ' || lv2_period;
          lv2_sqlQuery := lv2_sqlQuery || ' AND TRUNC(j.period,''MM'') >= ' || lv2_valid_from;
          lv2_sqlQuery := lv2_sqlQuery || ' AND (j.amount IS NOT NULL OR j.qty_1 IS NOT NULL)';
          lv2_sqlQuery := lv2_sqlQuery || ' AND NVL(j.record_status,''P'') = ''A''';

          -- Get the first period
          OPEN cv FOR lv2_sqlQuery;
               LOOP
                   FETCH cv INTO ld_first_period;
                   EXIT;
               END LOOP;
          CLOSE cv;


          -- If this is the first period
          IF ld_first_period IS NULL THEN

             -- Return the base query as is.
             lv2_retQuery := lv2_sqlBaseQuery;


          -- If there are years preceding the year of the current period
          ELSIF trunc(ld_first_period, 'YYYY') < trunc(p_period, 'YYYY') THEN

            ld_inc_period := ld_first_period;

            lv2_sqlQuery := 'SELECT ';

            -- Build query for each year subsequent to the start point.
            WHILE trunc(ld_inc_period, 'YYYY') < trunc(p_period, 'YYYY') LOOP

               lv2_inc_period := 'to_date(''' || to_char(ld_inc_period, 'YYYY') || '-12-01'', ''YYYY-MM-DD'')';

               lv2_sqlQuery := lv2_sqlQuery || (CASE WHEN ln_count > 0 THEN '+' END);
               lv2_sqlQuery := lv2_sqlQuery || '(';
               lv2_sqlQuery := lv2_sqlQuery || lv2_sqlSelect;
               lv2_sqlQuery := lv2_sqlQuery || lv2_sqlClause;
               lv2_sqlQuery := lv2_sqlQuery || ' AND TRUNC(j.period,''MM'') = ' || lv2_inc_period;
               lv2_sqlQuery := lv2_sqlQuery || (CASE WHEN lv2_sqlGroup IS NOT NULL THEN ' GROUP BY ' || lv2_sqlGroup END);
               lv2_sqlQuery := lv2_sqlQuery || ')';

               ln_count := ln_count + 1;

               -- Increase with one year
               ld_inc_period := add_months(ld_inc_period, 12);

            END LOOP;

            -- If current period is december, the value has already been included in the above loop.
            IF to_char(p_period, 'MM') < 12 THEN

              -- Now add query that will add value for current period
              lv2_sqlQuery := lv2_sqlQuery || (CASE WHEN ln_count > 0 THEN '+' END);
              lv2_sqlQuery := lv2_sqlQuery || '(';
              lv2_sqlQuery := lv2_sqlQuery || lv2_sqlSelect;
              lv2_sqlQuery := lv2_sqlQuery || lv2_sqlClause;
              lv2_sqlQuery := lv2_sqlQuery || ' AND TRUNC(j.period,''MM'') = ' || lv2_period;
              lv2_sqlQuery := lv2_sqlQuery || (CASE WHEN lv2_sqlGroup IS NOT NULL THEN ' GROUP BY ' || lv2_sqlGroup END);
              lv2_sqlQuery := lv2_sqlQuery || ')';

            END IF;


            lv2_sqlQuery := lv2_sqlQuery || ' FROM summary_number WHERE num = 1';

            lv2_retQuery := lv2_sqlQuery;


          -- There are no years preceding the year of the current period
          ELSIF trunc(ld_first_period, 'YYYY') = trunc(p_period, 'YYYY') THEN

            -- Build query to get only the value for current period.
            lv2_retQuery := lv2_sqlBaseQuery;

          END IF;

      END IF; -- Target = TOTAL

   END IF; -- Source = YTD

   RETURN lv2_retQuery;

END BuildSQLQuery;




PROCEDURE DeleteSummary(p_document_key VARCHAR2)
IS
			lv2_record_status cont_doc.record_status%TYPE;
BEGIN
			lv2_record_status := ec_cont_doc.record_status(p_document_key);
			IF lv2_record_status = 'A'
			THEN
				raise_application_error(-20000, 'Cannot Delete an approved document, it has to be in un-approved state.');
			ELSE
        ecdp_rr_revn_common.DeleteDocument(p_document_key);
				DELETE FROM cont_journal_summary WHERE document_key = p_document_key;
			END IF;
END DeleteSummary;







FUNCTION GetSummaryDocMonth(
         p_doc_key VARCHAR2
) RETURN VARCHAR2
IS

  CURSOR c_mth(cp_doc_key VARCHAR2) IS
         SELECT trunc(Max(daytime),'MM') mth
         FROM cont_journal_summary js
         WHERE js.document_key = cp_doc_key;

  ld_ret VARCHAR2(100) := NULL;

BEGIN

  FOR rsM IN c_mth(p_doc_key) LOOP

      ld_ret := TO_CHAR(rsM.Mth, 'yyyy-mm-dd"T"hh24:mi:ss');

  END LOOP;

  RETURN ld_ret;

END GetSummaryDocMonth;


PROCEDURE SetSummaryRecordStatus(
          p_document_key VARCHAR2,
          p_record_status VARCHAR2,
          p_user VARCHAR2,
		  p_accrual_ind VARCHAR2
)
IS

  CURSOR c_dep(cp_document_key VARCHAR2) IS
    SELECT cd.document_key
      FROM cont_doc cd
     WHERE cd.preceding_document_key = cp_document_key;

  CURSOR c_aind(cpa_document_key VARCHAR2) IS
    SELECT dc.accrual_ind
      FROM cont_doc dc
     WHERE dc.document_key = cpa_document_key;

  lv2_dep_doc_key VARCHAR2(32) := NULL;
  doc_dependency EXCEPTION;
  closed_period EXCEPTION;
  Wrong_screen   EXCEPTION;
  ld_curr_open_period DATE;
  lr_cont_doc cont_doc%ROWTYPE := ec_cont_doc.row_by_pk(p_document_key);
  lv_msg VARCHAR2(2000);
  lv2_accrual_ind cont_doc.accrual_ind%type  := ec_cont_doc.accrual_ind(p_document_key);
BEGIN

  -- Exiting if no change
  IF lr_cont_doc.record_status = p_record_status THEN
    RETURN;
  END IF;

  -- Unapproving
  IF p_record_status = 'P' THEN

     -- Check dependencies
     FOR rsD IN c_dep(p_document_key) LOOP
       lv2_dep_doc_key := rsD.document_key;
     END LOOP;

     IF lv2_dep_doc_key IS NOT NULL THEN
       RAISE doc_dependency;
     END IF;

	   --Checking verification done from correct screen
    IF p_accrual_ind <> lv2_accrual_ind and p_accrual_ind<>'B' then
       RAISE Wrong_screen;
    END IF;

     -- Check reporting period
     -- If the document was approved in a reporting period that is now closed, it can not be unapproved.
     ld_curr_open_period := ecdp_rr_revn_common.GetCurrentReportingPeriod(lr_cont_doc.object_id, lr_cont_doc.daytime);

     IF lr_cont_doc.reporting_period < ld_curr_open_period THEN
       RAISE closed_period;
     END IF;

  END IF;

       IF p_record_status = 'V' THEN


        if p_accrual_ind <> lv2_accrual_ind and p_accrual_ind<>'B' then
          RAISE Wrong_screen;
        END IF;
      end if;


 lv_msg := ecdp_dataset_flow.UpdateDocFlowStatus('CONT_JOURNAL_SUMMARY',
                                                 p_document_key,
                                                 p_record_status,
                                                 p_user,
                                                 true);

IF lv_msg is null then
  -- Set record status on document and journal entry
  ecdp_rr_revn_common.SetRecordStatusOnDocument(p_document_key, p_record_status, p_user, 'CONT_SUMMARY_DOC');
  SetRecordStatusOnJournalSum(p_document_key, p_record_status, p_user);
END IF;

EXCEPTION
  WHEN doc_dependency THEN
       RAISE_APPLICATION_ERROR(-20000, 'Can not unapprove Data Extract ' || p_document_key || ' because it has a dependent Data Extract (' || lv2_dep_doc_key || ')');

  WHEN closed_period THEN
       RAISE_APPLICATION_ERROR(-20000, 'Can not unapprove Data Extract ' || p_document_key || ' because it was approved in a reporting period that is now closed (' || lr_cont_doc.reporting_period || ').');

	       WHEN Wrong_screen THEN
      RAISE_APPLICATION_ERROR(-20000, CASE lv2_accrual_ind when 'Y' then'Accrual extract document' else 'Final extract document' end || ' cannot be Verified / Un-verified from ' || CASE lv2_accrual_ind when 'Y' then 'Final extract screen' else 'Accrual extract screen' end);

END SetSummaryRecordStatus;

FUNCTION getextractmsg(P_SUMMARY_SET   VARCHAR2,
                       P_RECORD_STATUS VARCHAR2,
                       P_ACCRUAL_IND   VARCHAR2,
                       P_DAYTIME       VARCHAR2) RETURN VARCHAR2 is
  lv_end_user_message varchar2(2000) := null;

  CURSOR c_doc(cp_summary_set VARCHAR2, cp_daytime VARCHAR2) IS
    SELECT cd.document_key, cd.accrual_ind
      FROM SUMMARY_SET_SETUP sss, cont_doc cd
     where cd.summary_setup_id = sss.summary_setup_id
       and sss.object_id = cp_summary_set
       and period = to_date(cp_daytime, 'yyyy-MM-dd"T"HH24:MI:SS');

BEGIN

  FOR rsD IN c_doc(p_summary_set, p_daytime) LOOP
    IF ec_cont_doc.record_status(rsd.document_key) != p_record_status AND
       rsD.Accrual_Ind <> p_accrual_ind THEN

      lv_end_user_message := 'Warning !' || chr(10) || 'There are ' || CASE
                               WHEN p_accrual_ind = 'Y' THEN
                                'FINAL'

                               ELSE
                                'ACCRUAL'

                             END ||
                             ' documents in this set which will not be verified from this screen , Use '||CASE
                               WHEN p_accrual_ind = 'Y' THEN
                                'FINAL'

                               ELSE
                                'ACCRUAL'

                             END||' screen to verify '||CASE WHEN p_accrual_ind = 'Y' THEN
                                'FINAL'

                               ELSE
                                'ACCRUAL'

                             END||' documents.' ;
    END IF;

  END LOOP;

  RETURN lv_end_user_message;

END GETEXTRACTMSG;

PROCEDURE SetSummaryRecordStatusAll(
          p_summary_set VARCHAR2,
          p_record_status VARCHAR2,
          p_daytime       DATE,
          p_user VARCHAR2,
		  p_accrual_ind VARCHAR2
)
IS

    CURSOR c_doc(cp_summary_set VARCHAR2, cp_daytime DATE) IS
        SELECT cd.document_key,cd.accrual_ind
      FROM SUMMARY_SET_SETUP sss,
           cont_doc cd
      where cd.summary_setup_id = sss.summary_setup_id
     and sss.object_id  = cp_summary_set
           and period = cp_daytime
           and cd.accrual_ind=p_accrual_ind;

  lv2_dep_doc_key VARCHAR2(32) := NULL;
  doc_dependency EXCEPTION;
  closed_period EXCEPTION;
  ld_curr_open_period DATE;

BEGIN

  -- Exiting if no change



     FOR rsD IN c_doc(p_summary_set, p_daytime) LOOP
        -- Set record status on document and journal entry
          IF ec_cont_doc.record_status(rsd.document_key) != p_record_status  AND rsD.Accrual_Ind=p_accrual_ind   THEN
	        SetSummaryRecordStatus(rsD.Document_Key, p_record_status, p_user,p_accrual_ind);
            --ecdp_rr_revn_common.SetRecordStatusOnDocument(rsD.Document_Key, p_record_status, p_user, 'CONT_SUMMARY_DOC');
            --SetRecordStatusOnJournalSum(rsD.Document_Key, p_record_status, p_user);
          END IF;
     END LOOP;

END SetSummaryRecordStatusAll;



--------------------------------------------------------------------------------------------------

PROCEDURE SetRecordStatusOnJournalSum(p_document_key  cont_doc.document_key%type,
                          p_record_status VARCHAR2,
                          p_user          VARCHAR2)
IS
    lv2_last_update_date VARCHAR2(20);
    CURSOR c_changed_entries(cp_document_key VARCHAR2) IS
        SELECT DISTINCT REC_ID
        FROM cont_journal_summary
        WHERE document_key = cp_document_key;

BEGIN

    -- Set record status on child records in cont_journal_summary
    lv2_last_update_date := to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS');

    IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('CONT_JOURNAL_SUMMARY'),'N') = 'Y' THEN

        -- ** 4-eyes approval logic ** --

        IF p_record_status <> 'A' THEN
          UPDATE cont_journal_summary
             SET record_status     = p_record_status,
                 last_updated_by   = Nvl(p_user,User),
                 last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
                 rev_text          = NULL,
                 approval_by       = NULL,
                 approval_date     = NULL,
                 approval_state    = 'U',
                 rev_no = (nvl(rev_no, 0) + 1)
           WHERE document_key = p_document_key;

        ELSE
          UPDATE cont_journal_summary
             SET record_status     = p_record_status,
                 last_updated_by   = Nvl(p_user,User),
                 last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
                 rev_text          = 'Approved at ' || lv2_last_update_date,
                 approval_by       = p_user,
                 approval_date     = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
                 approval_state    = 'U',
                 rev_no = (nvl(rev_no, 0) + 1)
           WHERE document_key = p_document_key;
        END IF;

      -- Register new record for approval
      FOR lc_rec_journal_entry IN c_changed_entries(p_document_key) LOOP
        -- Some times the REC_ID is null even if the Approval is turned on,
        -- usually those are the old data that have been created before
        -- turning on the Approval.
        IF lc_rec_journal_entry.rec_id IS NOT NULL THEN
            Ecdp_Approval.registerTaskDetail(lc_rec_journal_entry.rec_id, 'CONT_JOURNAL_SUMMARY', Nvl(p_user, User));
        END IF;
      END LOOP;

     -- ** END 4-eyes approval ** --

    ELSE
        IF p_record_status <> 'A' THEN
          UPDATE cont_journal_summary
             SET record_status     = p_record_status,
                 last_updated_by   = p_user,
                 last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
                 rev_text          = NULL,
                 approval_by       = NULL,
                 approval_date     = NULL
           WHERE document_key = p_document_key;

        ELSE
          UPDATE cont_journal_summary
             SET record_status     = p_record_status,
                 last_updated_by   = p_user,
                 last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
                 rev_text          = 'Approved at ' || lv2_last_update_date,
                 approval_by       = p_user,
                 approval_date     = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS')
           WHERE document_key = p_document_key;
        END IF;
    END IF;
END SetRecordStatusOnJournalSum;

--------------------------------------------------------------------------------------------------


FUNCTION IsSummaryValidForContract(
         p_contract_id VARCHAR2,
         p_summary_setup_id VARCHAR2
         )
RETURN VARCHAR2
IS

  CURSOR c_valid(cp_contract_id VARCHAR2, cp_summary_setup_id VARCHAR2) IS
    SELECT summary_setup_id
      FROM contract_summary_setup css
     WHERE css.object_id = cp_contract_id
     AND css.summary_setup_id = cp_summary_setup_id;

  lv2_ret_val VARCHAR2(1) := 'N';

BEGIN

  FOR rsV IN c_valid(p_contract_id, p_summary_setup_id) LOOP

    lv2_ret_val := 'Y';

  END LOOP;

  RETURN lv2_ret_val;

END IsSummaryValidForContract;

FUNCTION GetLastAppSummaryDoc(
         p_contract_id VARCHAR2,
         p_summary_setup_id VARCHAR2,
         p_period DATE,
         p_inventory_id VARCHAR2 DEFAULT NULL
)  RETURN VARCHAR2
IS

  CURSOR c_doc(cp_contract_id VARCHAR2, cp_summary_setup_id VARCHAR2, cp_period DATE) IS
    SELECT cd1.document_key
      FROM cont_doc cd1
     WHERE cd1.document_type = 'SUMMARY'
       AND cd1.record_status IN ( 'A','V')
       AND cd1.object_id = cp_contract_id
       AND NVL(cd1.inventory_id,'XX') = NVL(P_inventory_id,'XX')
       AND cd1.summary_setup_id = cp_summary_setup_id
       AND cd1.period = cp_period
       AND cd1.created_date = (SELECT MAX(created_date)
                                 FROM cont_doc cd2
                                WHERE cd2.object_id = cd1.object_id
                                  AND cd2.summary_setup_id = cd1.summary_setup_id
                                  AND NVL(cd2.inventory_id,'XX') = NVL(cd1.inventory_id,'XX')
                                  AND cd2.period = cd1.period
                                  AND cd2.record_status IN ( 'A','V'));

  lv2_ret_doc_key VARCHAR2(32) := NULL;

BEGIN

  FOR rsD IN c_doc(p_contract_id, p_summary_setup_id, p_period) LOOP
    lv2_ret_doc_key := rsd.document_key;
  END LOOP;

  RETURN lv2_ret_doc_key;

END GetLastAppSummaryDoc;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : CreateSummaryTracing
-- Description    : Create the Data Extract tracing data. If p_force_create is not 'Y', then
--                  data will be created only when system attribute
--                  'JOURNAL_MAP_EXT_TRAC_IND' is set to 'Y'; the system attribute
--                  will not be checked otherwise. The value of p_period should be the period of
--                  specified Data Extract document.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
---------------------------------------------------------------------------------------------------
PROCEDURE CreateSummaryTracing(p_document_key VARCHAR2, p_period DATE, p_force_create VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

    v_sumry_doc_cont_t   sumry_doc_cont_t := sumry_doc_cont_t();
    v_cost_mapp_info_t   cost_mapp_info_t := cost_mapp_info_t();
    v_cnt_jounl_entry_t  cnt_jounl_entry_t := cnt_jounl_entry_t();
    v_ifac_jounl_entry_t ifac_jounl_entry_t := ifac_jounl_entry_t();

    TYPE r_summary_tracing IS RECORD(
      SUMMARY_TRACING_NO             NUMBER, -- Key
      DAYTIME                        DATE,
      CONTRACT_CODE                  VARCHAR2(32),
      PERIOD                         DATE,
      TAG                            VARCHAR2(240),
      DOCUMENT_TYPE                  VARCHAR2(32),
      COST_MAPPING_CODE              VARCHAR2(32),
      LOAD_ACCOUNT                   VARCHAR2(32),
      LOAD_WBS                       VARCHAR2(240),
      LOAD_QTY                       NUMBER,
      LOAD_AMOUNT                    NUMBER,
      CALC_SPLIT                     NUMBER,
      MAPPING_SPLIT                  NUMBER,
      SPLIT_KEY_CODE                 VARCHAR2(32),
      SPLIT_ITEM_OTHER_CODE          VARCHAR2(32),
      COST_MAPP_DOC_KEY              VARCHAR2(240),
      COST_MAPP_QTY1                 NUMBER,
      COST_MAPP_AMOUNT               NUMBER,
      SUMMARY_DOC_KEY                VARCHAR2(32),
      DATASET                        VARCHAR2(32),
      LABEL                          VARCHAR2(240),
      FIN_ACCOUNT_CODE               VARCHAR2(32),
      FIN_COST_CENTER_CODE           VARCHAR2(32),
      FIN_WBS_CODE                   VARCHAR2(32),
      SUMMARY_AMOUNT                 NUMBER,
      SUMMARY_QTY_1                  NUMBER,
      SUMMARY_ADJUSTMENT             NUMBER,
      RECORD_STATUS                  VARCHAR2(1),
      COMBINED_OBJ_ID                VARCHAR2(240),
      COST_MAPP_JOURNAL_ENTRY_NO     NUMBER,
      COST_MAPP_REF_JOURNAL_ENTRY_NO NUMBER,
      COST_MAPP_REVERSAL_DATE        DATE);

    TYPE t_summary_tracing IS TABLE OF r_summary_tracing INDEX BY PLS_INTEGER;

    v_summary_tracing_t t_summary_tracing;

    CURSOR c_summary_tracing IS
      SELECT ECDP_SYSTEM_KEY.ASSIGNNEXTNUMBER('SUMMARY_TRACING'),
             TRUNC(TO_DATE(NVL(ec_ctrl_system_attribute.attribute_text(Ecdp_Timestamp.getCurrentSysdate,
                                                                       'DEFAULT_EC_RPT_SET_DATE',
                                                                       '<='),
                               '2010-01-01T00:00:00'),
                           'yyyy-mm-dd"T"HH24:MI:SS'),
                   'MM') AS DAYTIME,
             summary_doc.contract_code,
             summary_doc.period AS period,
             summary_doc.tag AS tag,
             cje_source.document_type,
             cm.object_code COST_MAPPING_CODE,
             cje_source.fin_account_code load_account,
             cje_source.fin_wbs_code load_wbs,
             cje_source.qty_1 load_qty,
             cje_source.amount load_amount,
             (SELECT nvl(abs(DECODE(SUM(cje_source.amount),
                                    0,
                                    1,
                                    SUM(cje.amount) / SUM(cje_source.amount))),
                         1) * DECODE(cje.reversal_date, NULL, 1, -1)
                FROM dual) calc_split,
             nvl((SELECT split_share_mth
                   FROM split_key_setup
                  WHERE object_id = cm.split_key_id
                    AND split_member_id = cm.other_split_item_id
                    AND daytime =
                        (SELECT MAX(daytime)
                           FROM split_key_setup
                          WHERE object_id = cm.split_key_id
                            AND split_member_id = cm.other_split_item_id
                            AND daytime <= cje.period)),
                 1) * DECODE(cje.reversal_date, NULL, 1, -1) mapping_split,
             cm.split_key_code AS split_key_code,
             cm.SPLIT_ITEM_OTHER_CODE AS SPLIT_ITEM_OTHER_CODE,
             cje.document_key cost_mapp_doc_key,
             cje.qty_1 cost_mapp_qty1,
             cje.AMOUNT cost_mapp_amount,
             summary_doc.summary_doc_key AS summary_doc_key,
             cje.dataset,
             summary_doc.label AS label,
             summary_doc.cjs_fin_account AS fin_account,
             summary_doc.cjs_fin_cost_center AS fin_cost_center,
             summary_doc.cjs_fin_wbs AS fin_wbs,
             summary_doc.actual_amount summary_amount,
             summary_doc.ACTUAL_QTY_1 summary_qty_1,
             Decode(summary_doc.SOURCE_TIME_CONCEPT,
                    'PERIOD',
                    DECODE(summary_doc.TARGET_TIME_CONCEPT,
                           'PERIOD',
                           0,
                           'TOTAL',
                           (SELECT SUM(actual_amount)
                              FROM cont_journal_summary
                             WHERE tag = summary_doc.tag
                               AND summary_doc.summary_setup_id =
                                   summary_setup_id
                               AND add_months(period, 1) = summary_doc.period),
                           'YTD',
                           (SELECT SUM(actual_amount)
                              FROM cont_journal_summary
                             WHERE tag = summary_doc.tag
                               AND summary_doc.summary_setup_id =
                                   summary_setup_id
                               AND period < summary_doc.period
                               AND TRUNC(period, 'YYYY') =
                                   TRUNC(summary_doc.period, 'YYYY'))),
                    'TOTAL',
                    DECODE(summary_doc.TARGET_TIME_CONCEPT,
                           'TOTAL',
                           0,
                           'PERIOD',
                           (SELECT SUM(actual_amount) * -1
                              FROM cont_journal_summary
                             WHERE tag = summary_doc.tag
                               AND summary_doc.summary_setup_id =
                                   summary_setup_id
                               AND add_months(period, 1) = summary_doc.period),
                           'YTD',
                           (SELECT SUM(actual_amount) * -1
                              FROM cont_journal_summary
                             WHERE tag = summary_doc.tag
                               AND summary_doc.summary_setup_id =
                                   summary_setup_id
                               AND period < summary_doc.period
                               AND TRUNC(period, 'YYYY') =
                                   TRUNC(summary_doc.period, 'YYYY'))),
                    'YTD',
                    DECODE(summary_doc.TARGET_TIME_CONCEPT,
                           'YTD',
                           0,
                           'PERIOD',
                           (SELECT SUM(actual_amount) * -1
                              FROM cont_journal_summary
                             WHERE tag = summary_doc.tag
                               AND summary_doc.summary_setup_id =
                                   summary_setup_id
                               AND period < summary_doc.period
                               AND TRUNC(period, 'YYYY') =
                                   TRUNC(summary_doc.period, 'YYYY')),
                           'TOTAL',
                           (SELECT SUM(actual_amount)
                              FROM cont_journal_summary
                             WHERE tag = summary_doc.tag
                               AND summary_doc.summary_setup_id =
                                   summary_setup_id
                               AND period < summary_doc.period
                               AND TO_CHAR(period, 'MMDD') = '0101'))) SUMMARY_ADJUSTMENT,
             'P' RECORD_STATUS,
             summary_doc.summary_doc_key || '-' ||
             summary_doc.list_item_key || '-' ||
             summary_doc.summary_setup_code || '-' || cje.journal_entry_no COMBINED_OBJ_ID,
             cje.JOURNAL_ENTRY_NO COST_MAPP_JOURNAL_ENTRY_NO,
             cje.REF_JOURNAL_ENTRY_NO COST_MAPP_REF_JOURNAL_ENTRY_NO,
             cje.REVERSAL_DATE COST_MAPP_REVERSAL_DATE
        FROM TABLE(v_sumry_doc_cont_t) summary_doc,
             TABLE(v_cost_mapp_info_t) cm,
             TABLE(v_cnt_jounl_entry_t) cje,
             TABLE(v_ifac_jounl_entry_t) cje_source
       WHERE cje.dataset = summary_doc.ssl_dataset
         AND cje.reversal_date IS NULL
         AND cje.period = summary_doc.period
         AND cje_source.period = summary_doc.period
         AND TO_CHAR(cje_source.journal_entry_no) =
             cje.ref_journal_entry_no
         AND (cje.fin_account_code = summary_doc.ssl_fin_account OR
             summary_doc.ssl_fin_account = '-')
         AND (cje.fin_cost_center_code = summary_doc.ssl_fin_cost_center OR
             summary_doc.ssl_fin_cost_center = '-')
         AND (cje.fin_wbs_code = summary_doc.ssl_fin_wbs OR
             summary_doc.ssl_fin_wbs = '-')
         AND cje.CONTRACT_CODE = summary_doc.CONTRACT_CODE
         AND NOT EXISTS
       (SELECT journal_entry_no
                FROM TABLE(v_cnt_jounl_entry_t) cje_reversal
               WHERE cje_reversal.reversal_date IS NOT NULL
                 AND cje_reversal.ref_journal_entry_no =
                     cje.ref_journal_entry_no
                 AND cje_reversal.created_date >= cje.created_date
                 AND cje_reversal.amount = -1 * cje.amount)
         AND cm.object_id = cje.cost_mapping_id
         AND cm.daytime <= cje.period
         AND (cm.end_date > cje.period OR cm.end_date IS NULL);

    CURSOR sumry_doc_cont(p_doc VARCHAR2) IS
      SELECT cjs.object_id contract_ID,
             ec_contract.object_code(cjs.object_id) contract_code,
             cjs.period,
             cjs.tag,
             cjs.document_key summary_doc_key,
             cjs.list_item_key,
             cjs.summary_setup_id,
             cjs.actual_amount,
             cjs.ACTUAL_QTY_1,
             cjs.label,
             ssl.SOURCE_TIME_CONCEPT,
             ssl.TARGET_TIME_CONCEPT,
             ec_fin_account.object_code(cjs.fin_account_id) cjs_fin_account,
             ec_fin_cost_center.object_code(cjs.fin_cost_center_id) cjs_fin_cost_center,
             ec_fin_wbs.object_code(CJS.fin_wbs_id) cjs_fin_wbs,
             NVL(ssl_account.object_code, '-') ssl_fin_account,
             NVL(ssl_wbs.object_code, '-') ssl_fin_wbs,
             NVL(ssl_cost_center.object_code, '-') ssl_fin_cost_center,
             ssl.DATASET ssl_dataset,
             ssl_o.object_code summary_setup_code
        FROM cont_journal_summary  cjs,
             summary_setup_list    ssl,
             fin_account           ssl_account,
             fin_wbs               ssl_wbs,
             fin_cost_center       ssl_cost_center,
             SUMMARY_SETUP_VERSION ssl_oa,
             SUMMARY_SETUP         ssl_o
       WHERE cjs.document_key = p_doc
         AND ssl.OBJECT_ID = cjs.summary_setup_id
         AND cjs.tag = ssl.tag
         AND ssl_account.object_id(+) = ssl.FIN_ACCOUNT_ID
         AND ssl_wbs.object_id(+) = ssl.FIN_WBS_ID
         AND ssl_cost_center.object_id(+) = ssl.Fin_Cost_Center_Id
         AND ssl.object_id = ssl_oa.object_id
         AND ssl_oa.object_id = ssl_o.object_id
         AND ssl.daytime >= ssl_oa.daytime
         AND ssl.daytime < nvl(ssl_oa.end_date, ssl.daytime + 1);

    CURSOR cost_mapp_info IS
      SELECT cm.object_code,
             cm.object_id,
             cmv.daytime,
             cmv.end_date,
             cmv.split_key_id,
             ec_split_key.object_code(cmv.split_key_id) split_key_code,
             cmv.other_split_item_id,
             ec_split_item_other.object_code(cmv.other_split_item_id) SPLIT_ITEM_OTHER_CODE
        FROM cost_mapping cm, cost_mapping_version cmv
       WHERE cmv.object_id = cm.object_id;

    CURSOR cont_jnrl_entry IS
      SELECT amount,
             reversal_date,
             period,
             document_key,
             qty_1,
             dataset,
             journal_entry_no,
             REF_JOURNAL_ENTRY_NO,
             fin_account_code,
             fin_cost_center_code,
             fin_wbs_code,
             cost_mapping_id,
             CONTRACT_CODE,
             created_date
        FROM cont_journal_entry;

    CURSOR ifac_jnrl_entry IS
      SELECT document_type,
             fin_account_code,
             qty_1,
             amount,
             period,
             journal_entry_no,
             fin_wbs_code
        FROM ifac_journal_entry;



    v_count NUMBER;
    count_1 NUMBER := 0;
BEGIN
    IF p_force_create = 'Y' OR NVL(ec_ctrl_system_attribute.attribute_text(p_period,
                                                   'JOURNAL_MAP_EXT_TRAC_IND', '<='),'Y') = 'Y' THEN

	   FOR i IN sumry_doc_cont(p_document_key) LOOP
        v_sumry_doc_cont_t.extend;
        count_1 := count_1 + 1;
        v_sumry_doc_cont_t(count_1) := sumry_doc_cont_o(i.CONTRACT_ID,
                                                        i.CONTRACT_CODE,
                                                        i.PERIOD,
                                                        i.TAG,
                                                        i.SUMMARY_DOC_KEY,
                                                        i.LIST_ITEM_KEY,
                                                        i.SUMMARY_SETUP_ID,
                                                        i.ACTUAL_AMOUNT,
                                                        i.ACTUAL_QTY_1,
                                                        i.LABEL,
                                                        i.SOURCE_TIME_CONCEPT,
                                                        i.TARGET_TIME_CONCEPT,
                                                        i.CJS_FIN_ACCOUNT,
                                                        i.CJS_FIN_COST_CENTER,
                                                        i.CJS_FIN_WBS,
                                                        i.SSL_FIN_ACCOUNT,
                                                        i.SSL_FIN_WBS,
                                                        i.SSL_FIN_COST_CENTER,
                                                        i.SSL_DATASET,
                                                        i.SUMMARY_SETUP_CODE);
      END LOOP;

  count_1 := 0;
      FOR j IN cost_mapp_info LOOP
        v_cost_mapp_info_t.extend;
        count_1 := count_1 + 1;
        v_cost_mapp_info_t(count_1) := cost_mapp_info_o(j.object_code,
                                                        j.object_id,
                                                        j.daytime,
                                                        j.end_date,
                                                        j.split_key_id,
                                                        j.split_key_code,
                                                        j.other_split_item_id,
                                                        j.SPLIT_ITEM_OTHER_CODE);
      END LOOP;

	  count_1:= 0;

      FOR k IN cont_jnrl_entry LOOP
        v_cnt_jounl_entry_t.extend;
        count_1 := count_1 + 1;
        v_cnt_jounl_entry_t(count_1) := cnt_jounl_entry_o(k.journal_entry_no,
                                                          k.cost_mapping_id,
                                                          k.document_key,
                                                          k.period,
                                                          k.dataset,
                                                          k.amount,
                                                          k.qty_1,
                                                          k.fin_account_code,
                                                          k.fin_cost_center_code,
                                                          k.fin_wbs_code,
                                                          k.ref_journal_entry_no,
                                                          k.reversal_date,
                                                          k.contract_code,
                                                          k.created_date);
      END LOOP;
	  count_1 := 0;

      FOR k IN cont_jnrl_entry LOOP
        v_cnt_jounl_entry_t.extend;
        count_1 := count_1 + 1;
        v_cnt_jounl_entry_t(count_1) := cnt_jounl_entry_o(k.journal_entry_no,
                                                          k.cost_mapping_id,
                                                          k.document_key,
                                                          k.period,
                                                          k.dataset,
                                                          k.amount,
                                                          k.qty_1,
                                                          k.fin_account_code,
                                                          k.fin_cost_center_code,
                                                          k.fin_wbs_code,
                                                          k.ref_journal_entry_no,
                                                          k.reversal_date,
                                                          k.contract_code,
                                                          k.created_date);
      END LOOP;

	   count_1 := 0;

      FOR l IN ifac_jnrl_entry LOOP
        v_ifac_jounl_entry_t.extend;
        count_1 := count_1 + 1;
        v_ifac_jounl_entry_t(count_1) := ifac_jounl_entry_o(l.document_type,
                                                            l.fin_account_code,
                                                            l.qty_1,
                                                            l.amount,
                                                            l.period,
                                                            l.journal_entry_no,
                                                            l.fin_wbs_code);
      END LOOP;


	   OPEN c_summary_tracing;
      LOOP
        FETCH c_summary_tracing BULK COLLECT
          INTO v_summary_tracing_t;
        IF c_summary_tracing%NOTFOUND THEN
          EXIT;
        END IF;
      END LOOP;

	   FORALL m IN 1 .. v_summary_tracing_t.count
        INSERT INTO SUMMARY_TRACING
          (SUMMARY_TRACING_NO, -- Key
           DAYTIME,
           CONTRACT_CODE,
           PERIOD,
           TAG,
           DOCUMENT_TYPE,
           COST_MAPPING_CODE,
           LOAD_ACCOUNT,
           LOAD_WBS,
           LOAD_QTY,
           LOAD_AMOUNT,
           CALC_SPLIT,
           MAPPING_SPLIT,
           SPLIT_KEY_CODE,
           SPLIT_ITEM_OTHER_CODE,
           COST_MAPP_DOC_KEY,
           COST_MAPP_QTY1,
           COST_MAPP_AMOUNT,
           SUMMARY_DOC_KEY,
           DATASET,
           LABEL,
           FIN_ACCOUNT_CODE,
           FIN_COST_CENTER_CODE,
           FIN_WBS_CODE,
           SUMMARY_AMOUNT,
           SUMMARY_QTY_1,
           SUMMARY_ADJUSTMENT,
           RECORD_STATUS,
           COMBINED_OBJ_ID,
           COST_MAPP_JOURNAL_ENTRY_NO,
           COST_MAPP_REF_JOURNAL_ENTRY_NO,
           COST_MAPP_REVERSAL_DATE)
        VALUES
          (v_summary_tracing_t(m).SUMMARY_TRACING_NO,
           v_summary_tracing_t(m).DAYTIME,
           v_summary_tracing_t(m).CONTRACT_CODE,
           v_summary_tracing_t(m).PERIOD,
           v_summary_tracing_t(m).TAG,
           v_summary_tracing_t(m).DOCUMENT_TYPE,
           v_summary_tracing_t(m).COST_MAPPING_CODE,
           v_summary_tracing_t(m).LOAD_ACCOUNT,
           v_summary_tracing_t(m).LOAD_WBS,
           v_summary_tracing_t(m).LOAD_QTY,
           v_summary_tracing_t(m).LOAD_AMOUNT,
           v_summary_tracing_t(m).CALC_SPLIT,
           v_summary_tracing_t(m).MAPPING_SPLIT,
           v_summary_tracing_t(m).SPLIT_KEY_CODE,
           v_summary_tracing_t(m).SPLIT_ITEM_OTHER_CODE,
           v_summary_tracing_t(m).COST_MAPP_DOC_KEY,
           v_summary_tracing_t(m).COST_MAPP_QTY1,
           v_summary_tracing_t(m).COST_MAPP_AMOUNT,
           v_summary_tracing_t(m).SUMMARY_DOC_KEY,
           v_summary_tracing_t(m).DATASET,
           v_summary_tracing_t(m).LABEL,
           v_summary_tracing_t(m).FIN_ACCOUNT_CODE,
           v_summary_tracing_t(m).FIN_COST_CENTER_CODE,
           v_summary_tracing_t(m).FIN_WBS_CODE,
           v_summary_tracing_t(m).SUMMARY_AMOUNT,
           v_summary_tracing_t(m).SUMMARY_QTY_1,
           v_summary_tracing_t(m).SUMMARY_ADJUSTMENT,
           v_summary_tracing_t(m).RECORD_STATUS,
           v_summary_tracing_t(m).COMBINED_OBJ_ID,
           v_summary_tracing_t(m).COST_MAPP_JOURNAL_ENTRY_NO,
           v_summary_tracing_t(m).COST_MAPP_REF_JOURNAL_ENTRY_NO,
           v_summary_tracing_t(m).COST_MAPP_REVERSAL_DATE);

    END IF;
END CreateSummaryTracing;


PROCEDURE ConfigureSummaryTracingReport(p_document_key                 VARCHAR2,
                                        p_daytime                      VARCHAR2,
                                        p_user_id                      VARCHAR2,
                                        p_report_definition_group_code VARCHAR2 DEFAULT NULL,
                                        p_report_runable_no            NUMBER DEFAULT NULL)
--</EC-DOC>
IS

    CURSOR c_report_defination_daytime(cp_report_def_group_code VARCHAR2) IS
        SELECT report_definition.daytime
        FROM report_definition
        WHERE report_definition.rep_group_code = cp_report_def_group_code;

CURSOR c_report_runable_param(cp_report_runable_no NUMBER, cp_parameter_name VARCHAR2, cp_parameter_date DATE) IS
    select count(*) param_count
      from report_runable_param
     where report_runable_no = cp_report_runable_no
       and parameter_name = cp_parameter_name
       and daytime = cp_parameter_date;

    ln_param_count_1         NUMBER;
    ln_param_count_2         NUMBER;

    lv2_rep_group_code       VARCHAR2(32);
    lv2_rep_daytime          DATE;
    lv2_report_runable_no    NUMBER;

    ex_no_report_def_found   EXCEPTION;

BEGIN

    -- Get the report group code
    lv2_rep_group_code := p_report_definition_group_code;

    IF lv2_rep_group_code IS NULL THEN
        lv2_rep_group_code := 'SUMMARY_TRACING_DEF';
    END IF;

    -- Get the daytime from report defination
    FOR lci_rep_def IN c_report_defination_daytime(lv2_rep_group_code) LOOP
        lv2_rep_daytime := lci_rep_def.daytime;
    END LOOP;

    IF lv2_rep_daytime IS NULL THEN
        RAISE ex_no_report_def_found;
    END IF;

    -- Get or create report runable no
    lv2_report_runable_no := p_report_runable_no;

    IF lv2_report_runable_no IS NULL THEN
        Ecdp_System_Key.assignNextNumber('REPORT_RUNABLE', lv2_report_runable_no);
    END IF;


    INSERT INTO tv_report_runable
        (report_runable_no, rep_group_code, name, created_by)
    VALUES
        (lv2_report_runable_no,
        lv2_rep_group_code,
        'Report' || '_' || lv2_report_runable_no || '_' || p_document_key,
        p_user_id);

--Look for existing partameter 1.
for Param in c_report_runable_param(lv2_report_runable_no, 'daytime', lv2_rep_daytime) loop
    ln_param_count_1 := Param.param_count;
    exit;
end loop;
--Look for existing partameter 2.
for Param in c_report_runable_param(lv2_report_runable_no, 'document_key', lv2_rep_daytime) loop
    ln_param_count_2 := Param.param_count;
    exit;
end loop;

--Create "daytime" if missing.
--Else update the parameter value.
if ln_param_count_1 = 0 then
    -- Inserting Daytime as runable report param
    INSERT INTO report_runable_param
        (parameter_value,
         parameter_name,
         parameter_type,
         parameter_sub_type,
         report_runable_no,
         daytime,
         created_by)
    VALUES
        (p_daytime,
         'daytime',
         'BASIC_TYPE',
         'DATE',
         lv2_report_runable_no,
         lv2_rep_daytime,
         p_user_id);

else
    UPDATE report_runable_param
       SET parameter_type = 'BASIC_TYPE',
           parameter_sub_type = 'DATE',
           parameter_value = p_daytime
     WHERE report_runable_no = lv2_report_runable_no
       AND daytime = lv2_rep_daytime
       AND parameter_name = 'daytime';
end if;

--Create "document_key" if missing.
--Else update the parameter value.
if ln_param_count_2 = 0 then
    -- Inserting document key as runable report param
    INSERT INTO report_runable_param
        (parameter_value,
         parameter_name,
         parameter_type,
         parameter_sub_type,
         report_runable_no,
         daytime,
         created_by)
    VALUES
        (p_document_key,
         'document_key',
         'BASIC_TYPE',
         'STRING',
         lv2_report_runable_no,
         lv2_rep_daytime,
         p_user_id);
else
    UPDATE report_runable_param
       SET parameter_type = 'BASIC_TYPE',
           parameter_sub_type = 'STRING',
           parameter_value = p_document_key
     WHERE report_runable_no = lv2_report_runable_no
       AND daytime = lv2_rep_daytime
       AND parameter_name = 'document_key';
end if;

EXCEPTION
    WHEN ex_no_report_def_found THEN
        RAISE_APPLICATION_ERROR(-20000, 'Can not configure Data Extract tracing report, no report defination found for group ' || lv2_rep_group_code || '.');

END ConfigureSummaryTracingReport;



FUNCTION CreateSummaryProcessLog(p_status         VARCHAR2,
                                 p_description    VARCHAR2)
RETURN NUMBER
IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    ln_log_no NUMBER;
BEGIN

    ln_log_no := ECDP_REVN_LOG.CreateLog(SUMMARY_PROCESS_USER_LOG_NAME, p_status, p_description);

    COMMIT;

    RETURN ln_log_no;

END CreateSummaryProcessLog;



PROCEDURE UpdateSummaryProcessLog(p_log_no                NUMBER,
                                 p_status                 VARCHAR2,
                                 p_description            VARCHAR2 DEFAULT NULL,
                                 p_param_dataset          VARCHAR2 DEFAULT NULL,
                                 p_param_period           DATE DEFAULT NULL,
                                 p_param_summary_set_id   VARCHAR2 DEFAULT NULL,
                                 p_param_summary_id       VARCHAR2 DEFAULT NULL,
                                 p_contract_id            VARCHAR2 DEFAULT NULL)
IS
    PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

    ECDP_REVN_LOG.UpdateLog(p_log_no, p_status, p_description, p_contract_id, p_param_dataset,
        p_param_summary_set_id, p_param_summary_id, NULL, NULL, p_param_period);

    COMMIT;

END UpdateSummaryProcessLog;



PROCEDURE CreateSummaryProcessLogItem(p_log_item_info           SUMMARY_PC_USER_LOG_ITEM_INFO,
                                      p_log_item_status         VARCHAR2,
                                      p_log_item_description    VARCHAR2)
IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    ln_log_item_no NUMBER;
BEGIN

    ln_log_item_no := ECDP_REVN_LOG.CreateLogItem(p_log_item_info.LOG_NO, SUMMARY_PROCESS_USER_LOG_NAME,
        p_log_item_status, p_log_item_info.LOG_ITEM_SOURCE, p_log_item_description, 'JOUR_EXT_PROC_LOG_LEVEL',
        p_log_item_info.PARAM_SUMMARY_ID, p_log_item_info.PARAM_DOCUMENT_KEY, p_log_item_info.PARAM_DATA_SET,
        p_log_item_info.PARAM_CONTRACT_ID, NULL, p_log_item_info.PARAM_PERIOD);

    COMMIT;

END CreateSummaryProcessLogItem;

PROCEDURE InitNewSummarySetVersion(p_user_id VARCHAR2, p_summary_set_id VARCHAR2, p_daytime DATE)
IS
    lv_prev_version DATE;
    lv_next_version DATE;
    lv_created_date DATE;
    lv_user_id      VARCHAR2(32);
    lv2_4e_recid    VARCHAR2(32);
BEGIN
    lv_prev_version := ec_summary_set_version.prev_daytime(p_summary_set_id, p_daytime);
    lv_next_version := ec_summary_set_version.next_daytime(p_summary_set_id, p_daytime);
    lv_user_id := CASE WHEN p_user_id IS NULL THEN ecdp_context.getAppUser() ELSE p_user_id END;
    lv_created_date := Ecdp_Timestamp.getCurrentSysdate();


    -- Align SUMMARY_SET_SETUP records with the new SUMMARY_SET_VERSION
    IF lv_prev_version IS NOT NULL THEN
        -- Copy Data Extract set setup from previous version
        INSERT INTO summary_set_setup (object_id
                                      ,summary_setup_id
                                      ,daytime
                                      ,end_date
                                      ,contract_id
                                      ,contract_group_code
                                      ,comments
                                      ,sort_order
                                      ,record_status
                                      ,created_by
                                      ,created_date)
        SELECT  object_id
               ,summary_setup_id
               ,p_daytime
               ,lv_next_version
               ,contract_id
               ,contract_group_code
               ,comments
               ,sort_order
               ,'P'
               ,lv_user_id
               ,lv_created_date
        FROM summary_set_setup
        WHERE object_id = p_summary_set_id
            AND summary_set_setup.daytime >= lv_prev_version
            AND summary_set_setup.daytime < p_daytime
            AND NOT EXISTS(SELECT object_id FROM summary_set_setup sub_summary_set_setup
                            WHERE object_id = p_summary_set_id
                                AND sub_summary_set_setup.daytime = p_daytime
                                AND sub_summary_set_setup.summary_setup_id = summary_set_setup.summary_setup_id
                                AND sub_summary_set_setup.contract_id = summary_set_setup.contract_id);


        -- ** 4-eyes approval logic ** --
        IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('SUMMARY_SET_SETUP'),'N') = 'Y' THEN

          -- Generate rec_id for the latest version record
          lv2_4e_recid := SYS_GUID();

          -- Set approval info on latest version record.
          UPDATE summary_set_setup
          SET last_updated_by = Nvl(EcDp_Context.getAppUser,User)
             ,last_updated_date = Ecdp_Timestamp.getCurrentSysdate
             ,approval_state = 'N'
             ,rec_id = lv2_4e_recid
             ,rev_no = (nvl(rev_no,0) + 1)
          WHERE object_id = p_summary_set_id
            AND daytime = p_daytime
            AND created_date = lv_created_date;

          -- Register version record for approval
          Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                           'SUMMARY_SET_SETUP',
                                           Nvl(EcDp_Context.getAppUser,User));
        END IF;
        -- ** END 4-eyes approval ** --


        -- Set the end date to the previous version
        UPDATE summary_set_setup
        SET end_date = p_daytime
           ,last_updated_by = lv_user_id
           ,last_updated_date = Ecdp_Timestamp.getCurrentSysdate()
        WHERE object_id = p_summary_set_id
            AND summary_set_setup.daytime >= lv_prev_version
            AND summary_set_setup.daytime < p_daytime;

    END IF;

END InitNewSummarySetVersion;

---------------------------------------------------------------------------------------------------
-- Procedure      : GetJournalEntryHistory
-- Description    : Uses cont_journal_entry and ifac_journal_entry table to find the parent journal entry for
--                  given JOURNAL_ENTRY_NO

-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
----------------------------------------------------------------------------------------------------

FUNCTION GetJournalEntryHistory(p_journal_entry_no NUMBER)
RETURN T_TABLE_JOURNAL_ENTRY_REF_INFO
IS
--</EC-DOC>
v_T_TABLE_MIXED_DATA T_TABLE_JOURNAL_ENTRY_REF_INFO;
l_index number := 0;
CURSOR c_rec_JOURNAL_ENTRY_REF_INFO IS
SELECT * FROM
(
with je_ref_info as
(
    SELECT je.journal_entry_no, 'CONT' as journal_entry_source, je.ref_journal_entry_no, je.ref_journal_entry_src
    FROM cont_journal_entry je
    WHERE je.ref_journal_entry_src is not null
    UNION
    SELECT je.journal_entry_no, 'IFAC' as journal_entry_source, NULL AS ref_journal_entry_no, NULL as ref_journal_entry_source
    FROM ifac_journal_entry je
) (SELECT CONNECT_BY_ROOT je.journal_entry_no root_journal_entry_no, CONNECT_BY_ROOT je.journal_entry_source root_journal_entry_source, je.*, rownum as sort_order
FROM je_ref_info je
START WITH je.journal_entry_no is not null
CONNECT BY PRIOR je.REF_JOURNAL_ENTRY_NO = TO_CHAR(je.journal_entry_no)
AND PRIOR je.ref_journal_entry_src = je.journal_entry_source
AND je.journal_entry_no = p_journal_entry_no)) WHERE journal_entry_no=p_journal_entry_no;

BEGIN
v_T_TABLE_MIXED_DATA := T_TABLE_JOURNAL_ENTRY_REF_INFO();
FOR i IN c_rec_JOURNAL_ENTRY_REF_INFO LOOP
   v_T_TABLE_MIXED_DATA.extend;

   l_index := v_T_TABLE_MIXED_DATA.count;

   v_T_TABLE_MIXED_DATA(l_index) := T_JOURNAL_ENTRY_REF_INFO(i.root_journal_entry_no,i.root_journal_entry_source,i.journal_entry_no,i.journal_entry_source,i.ref_journal_entry_no,i.ref_journal_entry_src,i.sort_order);


 END LOOP;

RETURN v_T_TABLE_MIXED_DATA;
END GetJournalEntryHistory;
-------------------------------------------------------------------------------------------------------------------------------------------
-- Procedure      : CreateSummaryYear
-- Description    : Creates Data Extracts for specified time scope.
-- Behaviour      : Called from Create button of Data Extract By Year Screen.
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE CreateSummaryYear(
          p_contract_id           VARCHAR2,
          p_summary_setup_id      VARCHAR2,
          p_year                  DATE,
          p_time_scope            VARCHAR2,
          p_user_id               VARCHAR2,
          p_accrual_ind           VARCHAR2,
          p_inventory_id          VARCHAR2 DEFAULT NULL,
          p_silent_mode_ind       VARCHAR2 DEFAULT 'Y'
          )
--</EC-DOC>
IS

  lv2_time_scope                  VARCHAR2(32) := p_time_scope;
  lv2_accrual_ind                 VARCHAR2(32);
  ln_user_log_no                  NUMBER;
  lv2_user_log_final_status       VARCHAR2(32);
  ln_succeeded_summary_count      NUMBER := 0;
  ln_summary_count                NUMBER := 0;
  ln_processed_summary_count      NUMBER := 0;
  user_log_item_info              SUMMARY_PC_USER_LOG_ITEM_INFO;
  lv2_user_log_desc_h             VARCHAR2(32) := 'Process Data Extract By Year ';
  Schedule_count number;

BEGIN
  ln_user_log_no := CreateSummaryProcessLog(ECDP_REVN_LOG.LOG_STATUS_RUNNING, ECDP_REVN_LOG.GETBATCHPROCESSLOGDESCRIPTION(lv2_user_log_desc_h));

  user_log_item_info.LOG_NO := ln_user_log_no;
  user_log_item_info.LOG_ITEM_SOURCE := 'EcDp_RR_Revn_Summary.CreateSummaryYear';



  IF p_time_scope IS NULL THEN
    lv2_time_scope := 'JANUARY';
  END IF;

select count(*) INTO Schedule_count
      from (select replace(utl_raw.cast_to_varchar2(DBMS_LOB.SUBSTR(JOB_DATA,4000)),'\:',':') args from qrtz_triggers
      where (trigger_state!='COMPLETE' or ecdp_scheduler.isJobExecuting(trigger_name, trigger_group)='Y')
       and trigger_name like 'DataExtractSetProcess--!##RERUN##!%') x
   where INSTR(x.args,'SUMMARY_YEAR=' || to_char(p_year,'YYYY-MM-DD"T"HH24:MI:SS'))> 0
				 and INSTR(x.args,'TIME_SCOPE=' || p_time_scope) > 0
         and (INSTR(x.args,'INVENTORY_ID=' || p_inventory_id) > 0 OR (INSTR(x.args,'INVENTORY_ID')=0 AND p_inventory_id IS NULL))
         and INSTR(x.args,'SUMMARY_SETUP_ID=' || p_summary_setup_id) > 0
				 and INSTR(x.args,'ACCRUAL_IND='|| p_accrual_ind) > 0 ;

  IF Schedule_count > 1 THEN
        CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_INFO, 'Not able to execute. The Extract Mapping schedule is already running. Please refresh to get status');
        UpdateSummaryProcessLog(ln_user_log_no, ECDP_REVN_LOG.log_status_error);
  ELSE

      IF lv2_time_scope IN ('ALL_MONTHS') THEN
        FOR i IN 0..11
          LOOP
            BEGIN
               user_log_item_info.PARAM_SUMMARY_ID := p_summary_setup_id;
               user_log_item_info.PARAM_CONTRACT_ID := p_contract_id;

               CreateSummaryMonth(p_contract_id, p_summary_setup_id, add_months(trunc(p_year, 'YYYY'), i),p_user_id,p_accrual_ind,p_inventory_id);

               ln_processed_summary_count := ln_processed_summary_count + 1;
               ln_succeeded_summary_count := ln_succeeded_summary_count + 1;

               UpdateSummaryProcessLog(ln_user_log_no, NULL, ECDP_REVN_LOG.GETBATCHPROCESSLOGDESCRIPTION(lv2_user_log_desc_h, ln_summary_count, ln_processed_summary_count, ln_succeeded_summary_count), NULL, NULL, NULL);

               EXCEPTION
                WHEN OTHERS THEN
                    ln_processed_summary_count := ln_processed_summary_count + 1;
                    lv2_user_log_final_status := ECDP_REVN_LOG.LOG_STATUS_ERROR;

                    CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_INFO, 'Data Extract process failed, changes made for processing this Data Extract setup have been rolled back.');

                    UpdateSummaryProcessLog(ln_user_log_no, NULL, ECDP_REVN_LOG.GETBATCHPROCESSLOGDESCRIPTION(lv2_user_log_desc_h, ln_summary_count, ln_processed_summary_count, ln_succeeded_summary_count), NULL, NULL, NULL);

              END;
          END LOOP;
        ELSIF lv2_time_scope IN ('Q1') THEN
         FOR i IN 0..2
          LOOP
            BEGIN
               user_log_item_info.PARAM_SUMMARY_ID := p_summary_setup_id;
               user_log_item_info.PARAM_CONTRACT_ID := p_contract_id;

               CreateSummaryMonth(p_contract_id, p_summary_setup_id, add_months(trunc(p_year, 'YYYY'), i),p_user_id,p_accrual_ind,p_inventory_id);

               ln_processed_summary_count := ln_processed_summary_count + 1;
               ln_succeeded_summary_count := ln_succeeded_summary_count + 1;

             EXCEPTION
                WHEN OTHERS THEN
                    ln_processed_summary_count := ln_processed_summary_count + 1;
                    lv2_user_log_final_status := ECDP_REVN_LOG.LOG_STATUS_ERROR;

                    CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_INFO, 'Data Extract process failed, changes made for processing this Data Extract setup have been rolled back.');

                    UpdateSummaryProcessLog(ln_user_log_no, NULL, ECDP_REVN_LOG.GETBATCHPROCESSLOGDESCRIPTION(lv2_user_log_desc_h, ln_summary_count, ln_processed_summary_count, ln_succeeded_summary_count), NULL, NULL, NULL);

              END;
          END LOOP;
          ELSIF lv2_time_scope IN ('Q2') THEN
         FOR i IN 3..5
          LOOP
            BEGIN
             user_log_item_info.PARAM_SUMMARY_ID := p_summary_setup_id;
             user_log_item_info.PARAM_CONTRACT_ID := p_contract_id;

             CreateSummaryMonth(p_contract_id, p_summary_setup_id, add_months(trunc(p_year, 'YYYY'), i),p_user_id,p_accrual_ind,p_inventory_id);

              ln_processed_summary_count := ln_processed_summary_count + 1;
              ln_succeeded_summary_count := ln_succeeded_summary_count + 1;

             EXCEPTION
                WHEN OTHERS THEN
                    ln_processed_summary_count := ln_processed_summary_count + 1;
                    lv2_user_log_final_status := ECDP_REVN_LOG.LOG_STATUS_ERROR;

                    CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_INFO, 'Data Extract process failed, changes made for processing this Data Extract setup have been rolled back.');

                    UpdateSummaryProcessLog(ln_user_log_no, NULL, ECDP_REVN_LOG.GETBATCHPROCESSLOGDESCRIPTION(lv2_user_log_desc_h, ln_summary_count, ln_processed_summary_count, ln_succeeded_summary_count), NULL, NULL, NULL);

              END;
          END LOOP;
           ELSIF lv2_time_scope IN ('Q3') THEN
         FOR i IN 6..8
          LOOP
            BEGIN
             user_log_item_info.PARAM_SUMMARY_ID := p_summary_setup_id;
             user_log_item_info.PARAM_CONTRACT_ID := p_contract_id;

             CreateSummaryMonth(p_contract_id, p_summary_setup_id, add_months(trunc(p_year, 'YYYY'), i),p_user_id,p_accrual_ind,p_inventory_id);

              ln_processed_summary_count := ln_processed_summary_count + 1;
              ln_succeeded_summary_count := ln_succeeded_summary_count + 1;

             EXCEPTION
                WHEN OTHERS THEN
                    ln_processed_summary_count := ln_processed_summary_count + 1;
                    lv2_user_log_final_status := ECDP_REVN_LOG.LOG_STATUS_ERROR;

                    CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_INFO, 'Data Extract process failed, changes made for processing this Data Extract setup have been rolled back.');

                    UpdateSummaryProcessLog(ln_user_log_no, NULL, ECDP_REVN_LOG.GETBATCHPROCESSLOGDESCRIPTION(lv2_user_log_desc_h, ln_summary_count, ln_processed_summary_count, ln_succeeded_summary_count), NULL, NULL, NULL);

              END;
          END LOOP;
           ELSIF lv2_time_scope IN ('Q4') THEN
         FOR i IN 9..11
          LOOP
            BEGIN
             user_log_item_info.PARAM_SUMMARY_ID := p_summary_setup_id;
             user_log_item_info.PARAM_CONTRACT_ID := p_contract_id;

             CreateSummaryMonth(p_contract_id, p_summary_setup_id, add_months(trunc(p_year, 'YYYY'), i),p_user_id,p_accrual_ind,p_inventory_id);

              ln_processed_summary_count := ln_processed_summary_count + 1;
              ln_succeeded_summary_count := ln_succeeded_summary_count + 1;

             EXCEPTION
                WHEN OTHERS THEN
                    ln_processed_summary_count := ln_processed_summary_count + 1;
                    lv2_user_log_final_status := ECDP_REVN_LOG.LOG_STATUS_ERROR;

                    CreateSummaryProcessLogItem(user_log_item_info, ECDP_REVN_LOG.LOG_STATUS_ITEM_INFO, 'Data Extract process failed, changes made for processing this Data Extract setup have been rolled back.');

                    UpdateSummaryProcessLog(ln_user_log_no, NULL, ECDP_REVN_LOG.GETBATCHPROCESSLOGDESCRIPTION(lv2_user_log_desc_h, ln_summary_count, ln_processed_summary_count, ln_succeeded_summary_count), NULL, NULL, NULL);

              END;
          END LOOP;
          ELSE
             CreateSummaryMonth(p_contract_id, p_summary_setup_id, add_months(trunc(p_year, 'YYYY'), to_char(to_date(lv2_time_scope,'MON'),'MM','NLS_DATE_LANGUAGE=ENGLISH')-1),p_user_id,p_accrual_ind,p_inventory_id);

      END IF;
  END IF;
END CreateSummaryYear;
---------------------------------------------------------------------------------------------------
-- Procedure      : PopulateSummaryYear
-- Description    : Populates Data Extracts for specified time scope.
-- Behaviour      : Called from Populate button of Data Extract By Year Screen.
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE PopulateSummaryYear(
          p_contract_id           VARCHAR2,
          p_summary_setup_id      VARCHAR2,
          p_year                  DATE,
          p_time_scope            VARCHAR2,
          p_user_id               VARCHAR2
          )
--</EC-DOC>
IS

BEGIN

  RAISE_APPLICATION_ERROR(-20000, 'Separate function for populating Summary Year has not yet been implemented.');


END PopulateSummaryYear;
------------------------------------------------------------------------------------------------------------------------------------------
-- Procedure      : SetSummaryYearRecordStatus
-- Description    : Set selected document status to approve or un-approve.
-- Behaviour      : Called from Approve/Un-Approve button of Data Extract By Year Screen.
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE SetSummaryYearRecordStatus(
          p_contract_id      VARCHAR2,
          p_summary_setup_id VARCHAR2,
          p_summary_year     DATE,
          p_time_scope       VARCHAR2,
          p_record_status    VARCHAR2,
          p_user             VARCHAR2,
          p_inventory_id     VARCHAR2 DEFAULT NULL,
		  p_accrual_ind       VARCHAR2
)
IS

  lv2_doc_key VARCHAR2(32) := NULL;

BEGIN

  IF p_time_scope IS NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'It is not allowed to ' ||
      CASE p_record_status WHEN 'P' THEN 'UN-' END ||
      'APPROVE summary document(s) without selecting a Time Scope first.');
  END IF;

  IF p_time_scope IN ('ALL_MONTHS','JANUARY','Q1') THEN
    lv2_doc_key := GetLastSummaryDocKey(p_contract_id, p_summary_setup_id, p_summary_year, 'JANUARY',p_inventory_id);
    IF lv2_doc_key IS NOT NULL THEN
    SetSummaryRecordStatus(lv2_doc_key, p_record_status, p_user,p_accrual_ind);
    END IF;
  END IF;

  IF p_time_scope IN ('ALL_MONTHS','FEBRUARY','Q1') THEN
    lv2_doc_key := GetLastSummaryDocKey(p_contract_id, p_summary_setup_id, p_summary_year, 'FEBRUARY',p_inventory_id);
    IF lv2_doc_key IS NOT NULL THEN
    SetSummaryRecordStatus(lv2_doc_key, p_record_status, p_user,p_accrual_ind);
    END IF;
  END IF;

  IF p_time_scope IN ('ALL_MONTHS','MARCH','Q1') THEN
    lv2_doc_key := GetLastSummaryDocKey(p_contract_id, p_summary_setup_id, p_summary_year, 'MARCH',p_inventory_id);
    IF lv2_doc_key IS NOT NULL THEN
    SetSummaryRecordStatus(lv2_doc_key, p_record_status, p_user,p_accrual_ind);
    END IF;
  END IF;

  IF p_time_scope IN ('ALL_MONTHS','APRIL','Q2') THEN
    lv2_doc_key := GetLastSummaryDocKey(p_contract_id, p_summary_setup_id, p_summary_year, 'APRIL',p_inventory_id);
    IF lv2_doc_key IS NOT NULL THEN
    SetSummaryRecordStatus(lv2_doc_key, p_record_status, p_user,p_accrual_ind);
    END IF;
  END IF;

  IF p_time_scope IN ('ALL_MONTHS','MAY','Q2') THEN
    lv2_doc_key := GetLastSummaryDocKey(p_contract_id, p_summary_setup_id, p_summary_year, 'MAY',p_inventory_id);
  IF lv2_doc_key IS NOT NULL THEN
   SetSummaryRecordStatus(lv2_doc_key, p_record_status, p_user,p_accrual_ind);
    END IF;
  END IF;

  IF p_time_scope IN ('ALL_MONTHS','JUNE','Q2') THEN
    lv2_doc_key := GetLastSummaryDocKey(p_contract_id, p_summary_setup_id, p_summary_year, 'JUNE',p_inventory_id);
    IF lv2_doc_key IS NOT NULL THEN
    SetSummaryRecordStatus(lv2_doc_key, p_record_status, p_user,p_accrual_ind);
    END IF;
  END IF;

  IF p_time_scope IN ('ALL_MONTHS','JULY','Q3') THEN
    lv2_doc_key := GetLastSummaryDocKey(p_contract_id, p_summary_setup_id, p_summary_year, 'JULY',p_inventory_id);
    IF lv2_doc_key IS NOT NULL THEN
    SetSummaryRecordStatus(lv2_doc_key, p_record_status, p_user,p_accrual_ind);
    END IF;
  END IF;

  IF p_time_scope IN ('ALL_MONTHS','AUGUST','Q3') THEN
    lv2_doc_key := GetLastSummaryDocKey(p_contract_id, p_summary_setup_id, p_summary_year, 'AUGUST',p_inventory_id);
    IF lv2_doc_key IS NOT NULL THEN
    SetSummaryRecordStatus(lv2_doc_key, p_record_status, p_user,p_accrual_ind);
    END IF;
  END IF;

  IF p_time_scope IN ('ALL_MONTHS','SEPTEMBER','Q3') THEN
    lv2_doc_key := GetLastSummaryDocKey(p_contract_id, p_summary_setup_id, p_summary_year, 'SEPTEMBER',p_inventory_id);
    IF lv2_doc_key IS NOT NULL THEN
    SetSummaryRecordStatus(lv2_doc_key, p_record_status, p_user,p_accrual_ind);
    END IF;
  END IF;

  IF p_time_scope IN ('ALL_MONTHS','OCTOBER','Q4') THEN
    lv2_doc_key := GetLastSummaryDocKey(p_contract_id, p_summary_setup_id, p_summary_year, 'OCTOBER',p_inventory_id);
    IF lv2_doc_key IS NOT NULL THEN
    SetSummaryRecordStatus(lv2_doc_key, p_record_status, p_user,p_accrual_ind);
    END IF;
  END IF;

  IF p_time_scope IN ('ALL_MONTHS','NOVEMBER','Q4') THEN
    lv2_doc_key := GetLastSummaryDocKey(p_contract_id, p_summary_setup_id, p_summary_year, 'NOVEMBER',p_inventory_id);
    IF lv2_doc_key IS NOT NULL THEN
    SetSummaryRecordStatus(lv2_doc_key, p_record_status, p_user,p_accrual_ind);
    END IF;
  END IF;

  IF p_time_scope IN ('ALL_MONTHS','DECEMBER','Q4') THEN
    lv2_doc_key := GetLastSummaryDocKey(p_contract_id, p_summary_setup_id, p_summary_year, 'DECEMBER',p_inventory_id);
    IF lv2_doc_key IS NOT NULL THEN
    SetSummaryRecordStatus(lv2_doc_key, p_record_status, p_user,p_accrual_ind);
    END IF;
  END IF;



END SetSummaryYearRecordStatus;
---------------------------------------------------------------------------------------------------
-- Function      : GetLastSummaryDocKey
-- Description    : Gives latest Data Extract document key for given month of year.
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetLastSummaryDocKey(p_contract_id VARCHAR2,
                              p_summary_setup_id VARCHAR2,
                              p_summary_year DATE,
                              p_month VARCHAR2,
                              p_inventory_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
IS

  CURSOR c_Doc(cp_contract_id VARCHAR2, cp_summary_setup_id VARCHAR2, cp_summary_year DATE, cp_month_num INTEGER) IS
    SELECT cd.document_key
      FROM cont_doc cd
     WHERE cd.object_id = cp_contract_id
       AND cd.summary_setup_id = cp_summary_setup_id
       AND cd.period = add_months(cp_summary_year, (cp_month_num - 1))
       AND NVL(p_inventory_id,'XX') = NVL(cd.inventory_id,'XX')
     ORDER BY created_date DESC; -- get only the latest, if multiple exists

  lv2_ret_doc VARCHAR2(32) := NULL;

BEGIN


  FOR rsDoc IN c_Doc(p_contract_id, p_summary_setup_id, p_summary_year, to_char(to_date(p_month,'MON'),'MM','NLS_DATE_LANGUAGE=ENGLISH')) LOOP
    lv2_ret_doc := rsDoc.Document_Key;
    EXIT;
  END LOOP;

  RETURN lv2_ret_doc;

END GetLastSummaryDocKey;

---------------------------------------------------------------------------------------------------
-- Procedure      : IsSummarySetSetupExist
-- Description    : Checks whenther there is any existing summary set setup with same extract,Inventory and project and daytime
--

---------------------------------------------------------------------------------------------------


FUNCTION IsSummarySetSetupExist(p_object_id VARCHAR2,
                                p_daytime DATE,
                                p_summary_setup_id VARCHAR2,
                                p_contract_id VARCHAR2,
                                p_inventory_id VARCHAR2)
RETURN NUMBER
IS
lv_count NUMBER;

BEGIN
  SELECT COUNT(object_id) INTO lv_count FROM SUMMARY_SET_SETUP
   WHERE  OBJECT_ID=p_object_id
   AND DAYTIME= p_daytime
   AND SUMMARY_SETUP_ID= p_summary_setup_id
   AND CONTRACT_ID= p_contract_id
   AND NVL(INVENTORY_ID,'XX')=NVL(p_inventory_id,'XX');

   RETURN CASE WHEN lv_count>0 THEN 1 ELSE 0 END;

END IsSummarySetSetupExist;

---------------------------------------------------------------------------------------------------
-- Procedure      : TransInvProdStream
-- Description    : Return the product stream object if it is connected to the passed transaction inventory
---------------------------------------------------------------------------------------------------
FUNCTION TransInvProdStream(p_prod_stream_object_id    VARCHAR2,
                            p_transaction_inventory_id VARCHAR2,
                            p_daytime                  DATE)
RETURN VARCHAR2
IS

-- Query to find if transaction inventory is connected to product stream on table trans_inv_prod_stream
CURSOR c IS
SELECT ts.object_id
  FROM trans_inv_prod_stream ts
 WHERE ts.inventory_id = p_transaction_inventory_id
   AND ts.object_id = p_prod_stream_object_id
   AND ts.daytime <= p_daytime
   AND p_daytime < NVL(ts.end_date, p_daytime + 1);

lv2_res_id CONTRACT.OBJECT_ID%TYPE := NULL;

BEGIN

FOR r IN c LOOP
      lv2_res_id := r.object_id;
  END LOOP;

   RETURN lv2_res_id;

END TransInvProdStream;
---------------------------------------------------------------------------------------------------
-- Function      : GetPreSummaryDocKey
-- Description    : Gives Preceding document key for latest Data Extract document key for given month of year.
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetPreSummaryDocKey(p_contract_id VARCHAR2,
                              p_summary_setup_id VARCHAR2,
                              p_summary_year DATE,
                              p_month VARCHAR2,
                              p_inventory_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
IS

  CURSOR c_Doc(cp_contract_id VARCHAR2, cp_summary_setup_id VARCHAR2, cp_summary_year DATE, cp_month_num INTEGER) IS
    SELECT cd.document_key
      FROM cont_doc cd
     WHERE cd.object_id = cp_contract_id
       AND cd.summary_setup_id = cp_summary_setup_id
       AND cd.period = add_months(cp_summary_year, (cp_month_num - 1))
       AND NVL(p_inventory_id,'XX') = NVL(cd.inventory_id,'XX')
     ORDER BY created_date DESC; -- get only the latest, if multiple exists

  lv2_ret_doc VARCHAR2(32) := NULL;

BEGIN

  FOR rsDoc IN c_Doc(p_contract_id, p_summary_setup_id, p_summary_year, to_char(to_date(p_month,'MON'),'MM','NLS_DATE_LANGUAGE=ENGLISH')) LOOP
    lv2_ret_doc :=Ec_Cont_Doc.preceding_document_key(rsDoc.Document_Key);
    EXIT;
  END LOOP;

  RETURN lv2_ret_doc;


END GetPreSummaryDocKey;
---------------------------------------------------------------------------------------------------
-- Function      : ValidateMonth
-- Description   : Checks whether given month is specific month or not.
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION ValidateMonth( p_month VARCHAR2)
  RETURN VARCHAR2
IS
lv_end_user_message    VARCHAR2(240);

BEGIN

  lv_end_user_message:=null;
  IF(p_month IN ('ALL_MONTHS','Q1','Q2','Q3','Q4'))  THEN

  lv_end_user_message:='Error!' || chr(10) ||
                            'Please select a specific month in the time scope';
  END IF;

  RETURN lv_end_user_message;

END ValidateMonth;
--------------------------------------------------------------------------------------------------------------------------------------
-- Function      : GetLastSummaryDocStatus
-- Description    : Returns  CONT_JOURNAL_SUMMARY_Y when latest Data Extract document is accrual else returns  CONT_JOURNAL_SUMMARY_N.
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetLastSummaryDocStatus(p_contract_id VARCHAR2,
                                 p_summary_setup_id VARCHAR2,
                                 p_summary_year DATE,
                                 p_month VARCHAR2,
                                 p_inventory_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
IS

  CURSOR c_Doc(cp_contract_id VARCHAR2, cp_summary_setup_id VARCHAR2, cp_summary_year DATE, cp_month_num INTEGER) IS
    SELECT cd.document_key
      FROM cont_doc cd
     WHERE cd.object_id = cp_contract_id
       AND cd.summary_setup_id = cp_summary_setup_id
       AND cd.period = add_months(cp_summary_year, (cp_month_num - 1))
       AND NVL(p_inventory_id,'XX') = NVL(cd.inventory_id,'XX')
     ORDER BY created_date DESC; -- get only the latest, if multiple exists

  lv2_ret_doc VARCHAR2(32) := NULL;

BEGIN

  FOR rsDoc IN c_Doc(p_contract_id, p_summary_setup_id, p_summary_year, to_char(to_date(p_month,'MON'),'MM','NLS_DATE_LANGUAGE=ENGLISH')) LOOP
    lv2_ret_doc :=rsDoc.Document_Key;
    EXIT;
  END LOOP;

  RETURN CASE Ec_Cont_Doc.accrual_ind(lv2_ret_doc) WHEN 'Y' THEN 'CONT_JOURNAL_SUMMARY_Y' ELSE 'CONT_JOURNAL_SUMMARY_N' END;


END GetLastSummaryDocStatus;
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Function      : GetPreSummaryDocStatus
-- Description    : Returns  CONT_JOURNAL_SUMMARY_Y when preceding document for latest Data Extract document is accrual else returns  CONT_JOURNAL_SUMMARY_N.
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GetPreSummaryDocStatus(p_contract_id VARCHAR2,
                                 p_summary_setup_id VARCHAR2,
                                 p_summary_year DATE,
                                 p_month VARCHAR2,
                                 p_inventory_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
IS

  CURSOR c_Doc(cp_contract_id VARCHAR2, cp_summary_setup_id VARCHAR2, cp_summary_year DATE, cp_month_num INTEGER) IS
    SELECT cd.document_key
      FROM cont_doc cd
     WHERE cd.object_id = cp_contract_id
       AND cd.summary_setup_id = cp_summary_setup_id
       AND cd.period = add_months(cp_summary_year, (cp_month_num - 1))
       AND NVL(p_inventory_id,'XX') = NVL(cd.inventory_id,'XX')
     ORDER BY created_date DESC; -- get only the latest, if multiple exists

  lv2_ret_doc VARCHAR2(32) := NULL;

BEGIN

  FOR rsDoc IN c_Doc(p_contract_id, p_summary_setup_id, p_summary_year, to_char(to_date(p_month,'MON'),'MM','NLS_DATE_LANGUAGE=ENGLISH')) LOOP
    lv2_ret_doc :=Ec_Cont_Doc.preceding_document_key(rsDoc.Document_Key);
    EXIT;
  END LOOP;

  RETURN CASE Ec_Cont_Doc.accrual_ind(lv2_ret_doc) WHEN 'Y' THEN 'CONT_JOURNAL_SUMMARY_Y' ELSE 'CONT_JOURNAL_SUMMARY_N' END;


END GetPreSummaryDocStatus;


END EcDp_RR_Revn_Summary;