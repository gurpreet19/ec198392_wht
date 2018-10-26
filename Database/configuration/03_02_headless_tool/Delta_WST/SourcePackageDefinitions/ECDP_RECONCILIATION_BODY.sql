CREATE OR REPLACE PACKAGE BODY ecdp_reconciliation IS
  /****************************************************************
  ** Package        :  ecdp_reconciliation, header part
  **
  ** $Revision: 1.0 $
  **
  ** Purpose        :  To reconcile the 2 runs of the royalty calculation
  **
  ** Documentation  :  www.energy-components.com
  **
  ** Created  : 10.07.2016  Swastik Jain
  **
  ** Modification history:
  **
  ** Version  Date        Whom  Change description:
  ** -------  ------      ----- --------------------------------------
  ********************************************************************/

  TYPE cv_type IS REF CURSOR;

  TYPE Found_from IS RECORD --OBJECT
  (
    INVENTORY_ID   VARCHAR2(32),
    PROD_STREAM_ID VARCHAR2(32),
    LAYER_MONTH    DATE);

  TYPE TIP_DIFF IS RECORD --OBJECT
  (
    INVENTORY_ID   VARCHAR2(32),
    PROD_STREAM_ID VARCHAR2(32),
    COLUMN_NAME    VARCHAR2(32),
    MONTH          DATE,
    FROM_VALUE     NUMBER,
    TO_VALUE       NUMBER,
    PRODUCT_DESC   VARCHAR2(100),
    PRODUCT_ID     VARCHAR2(100),
    COST_TYPE      VARCHAR2(100));

  TYPE TILP_DIFF IS RECORD --OBJECT
  (
    MONTH           DATE,
    LAYER_MONTH     DATE,
    DIMENSION_TAG   VARCHAR2(1000),
    TRANSACTION_TAG VARCHAR2(1000),
    FROM_VALUE      NUMBER,
    TO_VALUE        NUMBER,
    ID              NUMBER,
    HANDLED         BOOLEAN);

  TYPE TILP_SRC_DIFF IS RECORD --OBJECT
  (
    DIRECTION              VARCHAR2(32),
    DIFF_TYPE              VARCHAR2(1000),
    REFERENCE_ID           VARCHAR2(1000),
    REFERENCE_TYPE         VARCHAR2(32),
    MAPPING_TYPE           VARCHAR2(32),
    MAPPING_ID             VARCHAR2(1000),
    DFD_ID                 VARCHAR2(1000),
    DIFF_RECON_TILP_SRC_NO NUMBER,
    RUN_TIME               DATE,
    TYPE                   VARCHAR2(32),
    VALUE                  NUMBER /*,
                                HANDLED        BOOLEAN*/);

  type rr_jm_diff_from is record(
    PARAMS            VARCHAR2(240),
    SOURCE_DOC        VARCHAR2(1000),
    SOURCE_TYPE       VARCHAR2(1000),
    QTY               VARCHAR2(32),
    AMT               VARCHAR2(32),
    MAPPING_ID        VARCHAR2(1000),
    from_reference_id VARCHAR2(1000),
    to_reference_id   VARCHAR2(1000),
    RUNDATE           DATE,
    FROM_ID           VARCHAR2(32),
    to_ID             VARCHAR2(32),
    REC_ID            VARCHAR2(2000));

  type rr_jm_diff_to is record(
    PARAMS            VARCHAR2(240),
    SOURCE_DOC        VARCHAR2(1000),
    SOURCE_TYPE       VARCHAR2(1000),
    QTY               VARCHAR2(32),
    AMT               VARCHAR2(32),
    MAPPING_ID        VARCHAR2(1000),
    from_reference_id VARCHAR2(1000),
    to_reference_id   VARCHAR2(1000),
    RUNDATE           DATE,
    FROM_ID           VARCHAR2(32),
    to_ID             VARCHAR2(32),
    REC_ID            VARCHAR2(2000));

  type t_tip_diff is table of TIP_DIFF;
  type t_Found_from is table of Found_from;
  type t_tilp_diff is table of TILP_DIFF;
  type t_tilp_src_diff is table of TILP_SRC_DIFF;
  type t_jm_diff_fr is table of rr_jm_diff_from;
  type t_jm_diff_to is table of rr_jm_diff_to;

  PROCEDURE Insert_RECONCILE_JE_DIF(P_RECONCILE_JE_DIF RECONCILE_JE_DIF%rowtype) is
    lv_log_no VARCHAR2(32);
  Begin
    insert into RECONCILE_JE_DIF
      (reconciliation_no,
       recon_line_no,
       from_doc,
       to_doc,
       month,
       type,
       from_value,
       to_value,
       variance,
       from_adj_value,
       to_adj_value,
       adj_variance,
       comments,
       from_run_time,
       to_run_time,
       from_extract_obj_id,
       to_extract_obj_id,
       from_list_item_key,
       to_list_item_key,
       documents,
       tag)
    values
      (P_RECONCILE_JE_DIF.reconciliation_no,
       P_RECONCILE_JE_DIF.recon_line_no,
       P_RECONCILE_JE_DIF.from_doc,
       P_RECONCILE_JE_DIF.to_doc,
       P_RECONCILE_JE_DIF.month,
       P_RECONCILE_JE_DIF.type,
       P_RECONCILE_JE_DIF.from_value,
       P_RECONCILE_JE_DIF.to_value,
       P_RECONCILE_JE_DIF.variance,
       P_RECONCILE_JE_DIF.from_adj_value,
       P_RECONCILE_JE_DIF.to_adj_value,
       P_RECONCILE_JE_DIF.adj_variance,
       P_RECONCILE_JE_DIF.comments,
       P_RECONCILE_JE_DIF.from_run_time,
       P_RECONCILE_JE_DIF.to_run_time,
       P_RECONCILE_JE_DIF.from_extract_obj_id,
       P_RECONCILE_JE_DIF.to_extract_obj_id,
       P_RECONCILE_JE_DIF.from_list_item_key,
       P_RECONCILE_JE_DIF.to_list_item_key,
       P_RECONCILE_JE_DIF.documents,
       P_RECONCILE_JE_DIF.tag);
  exception
    when others then
      lv_log_no := ecdp_revn_log.createlog('RoyaltyRecon',
                                           ecdp_revn_log.log_status_error,
                                           'Error in inserting record in RECONCILE_JE_DIF table');
      RAISE_APPLICATION_ERROR(-20008,
                              'Error in inserting record in RECONCILE_JE_DIF table');
  end Insert_RECONCILE_JE_DIF;

  ---------------------------------------------------------------------------------------------------
  -- Procedure      : TO insert in Reconile_jm_doc
  -- Description    : Inserts record in Reconile_jm_doc
  ---------------------------------------------------------------------------------------------------

  procedure PutInRecjmdif(p_recjmdiff reconcile_jm_dif%rowtype) is

  Begin
    insert into reconcile_jm_dif
      (RECONCILIATION_NO,
       RECON_LINE_NO,
       MONTH,
       DIRECTION,
       DIFF_TYPE,
       REFERENCE_ID,
       REFERENCE_TYPE,
       SOURCE_TYPE,
       DFD_ID,
       VALUE_TYPE,
       VALUE,
       DIFF_VALUE,
       DIFF_DFD_ID,
       MAPPING_TYPE,
       MAPPING_ID,
       RUN_TIME,
       COMMENTS,
       ACCEPTED_IND,
       PARAMETERS)
    values
      (p_recjmdiff.RECONCILIATION_NO,
       p_recjmdiff.RECON_LINE_NO,
       p_recjmdiff.MONTH,
       p_recjmdiff.DIRECTION,
       p_recjmdiff.DIFF_TYPE,
       p_recjmdiff.REFERENCE_ID,
       p_recjmdiff.REFERENCE_TYPE,
       p_recjmdiff.SOURCE_TYPE,
       p_recjmdiff.DFD_ID,
       p_recjmdiff.VALUE_TYPE,
       p_recjmdiff.VALUE,
       p_recjmdiff.DIFF_VALUE,
       p_recjmdiff.DIFF_DFD_ID,
       p_recjmdiff.MAPPING_TYPE,
       p_recjmdiff.MAPPING_ID,
       p_recjmdiff.RUN_TIME,
       p_recjmdiff.COMMENTS,
       p_recjmdiff.ACCEPTED_IND,
       p_recjmdiff.PARAMETERS);

  Exception
    when others then
      raise_application_error(-20000,
                              'Error while inserting  in RECONCILE_JM_DIF' ||
                              sqlcode || ' ' || sqlerrm);
  end PutInRecjmdif;

  ---------------------------------------------------------------------------------------------------
  -- Procedure     :  RunExtractLine
  -- Description    : Populates table RECONCILE_JM_DIFF
  ---------------------------------------------------------------------------------------------------
  procedure RunExtractLine(p_recon_no NUMBER,
                           p_daytime  DATE,
                           p_line_tag VARCHAR2) is

    Cursor C_from(cp_from_to_doc varchar2, cp_tag varchar2) is
      select ECDP_RECONCILIATION.GetRoyParams(ec_cost_mapping_version.mapping_type(ec_cont_journal_entry.cost_mapping_id(from_id),
                                                                                   dfdc.created_date,
                                                                                   '<='),
                                              from_id) PARAMS,
             dfd.from_reference_id source_doc,
             ec_cost_mapping_version.journal_entry_source(ec_cont_journal_entry.cost_mapping_id(from_id),
                                                          ec_dataset_flow_document.process_date(dfd.from_type,
                                                                                                dfd.from_reference_id),
                                                          '<=') Source_type,
             ec_cont_journal_entry.qty_1(from_id) qty,
             ec_cont_journal_entry.amount(from_id) amt,
             dfdc.mapping_id,
             dfd.FROM_REFERENCE_ID,
             DFDC.TO_REFERENCE_ID,
             DFDC.CREATED_DATE AS RUN_DATE,
             from_id,
             to_id,
             DFD.rec_id
        from dataset_flow_detail_conn dfdc, dataset_flow_doc_conn dfd
       where DFD.TO_TYPE = 'CONT_JOURNAL_SUMMARY'
         AND DFD.FROM_TYPE = 'CONT_JOURNAL_ENTRY'
         AND DFD.CONNECTION_ID = DFDC.CONNECTION_ID
         and dfdc.to_id = cp_tag
         and dfd.to_reference_id = cp_from_to_doc;


Cursor C_to(cp_from_to_doc varchar2, cp_tag varchar2) is
      select ECDP_RECONCILIATION.GetRoyParams(ec_cost_mapping_version.mapping_type(ec_cont_journal_entry.cost_mapping_id(from_id),
                                                                                   dfdc.created_date,
                                                                                   '<='),
                                              from_id) PARAMS,
             dfd.from_reference_id source_doc,
             ec_cost_mapping_version.journal_entry_source(ec_cont_journal_entry.cost_mapping_id(from_id),
                                                          ec_dataset_flow_document.process_date(dfd.from_type,
                                                                                                dfd.from_reference_id),
                                                          '<=') Source_type,
             ec_cont_journal_entry.qty_1(from_id) qty,
             ec_cont_journal_entry.amount(from_id) amt,
             dfdc.mapping_id,
             dfd.FROM_REFERENCE_ID,
             DFDC.TO_REFERENCE_ID,
             DFDC.CREATED_DATE AS RUN_DATE,
             from_id,
             to_id,
             DFD.rec_id
        from dataset_flow_detail_conn dfdc, dataset_flow_doc_conn dfd
       where DFD.TO_TYPE = 'CONT_JOURNAL_SUMMARY'
         AND DFD.FROM_TYPE = 'CONT_JOURNAL_ENTRY'
         AND DFD.CONNECTION_ID = DFDC.CONNECTION_ID
         and dfdc.to_id = cp_tag
         and dfd.to_reference_id = cp_from_to_doc;
    lv_from_doc   reconcile_je_dif.from_doc%type;
    lv_to_doc     reconcile_je_dif.to_doc%type;
    lv_tag        reconcile_je_dif.tag%type;
    lv_type       reconcile_je_dif.type%type;
    lt_jm_diff_fr t_jm_diff_fr;
    lt_jm_diff_to t_jm_diff_to;
    lrec_jm_diff  reconcile_jm_dif%rowtype;
    lv_matched    boolean := false;

  Begin

    delete from reconcile_jm_dif rjmd
     where rjmd.reconciliation_no = p_recon_no
     and recon_line_no = p_line_tag;

    begin
      select rjd.from_doc, rjd.to_doc, rjd.tag, type
        into lv_from_doc, lv_to_doc, lv_tag, lv_type
        from reconcile_je_dif rjd
       where rjd.reconciliation_no = p_recon_no
         and rjd.recon_line_no = p_line_tag;
    exception
      when no_data_found then
        RAISE_APPLICATION_ERROR(-20000,
                                'No data in RECONCILE_JE_DIF Table');
      When others then
        RAISE_APPLICATION_ERROR(-20000,
                                'Error while selecting from RECONCILE_JE_DIF Table :' ||
                                sqlcode || ' ' || sqlerrm);
    end;


       FOR lt_jm_diff_fr in C_from(lv_from_doc, lv_tag)  loop

        if (upper(lv_type) = 'QTY' and lt_jm_diff_fr.qty is not null) or
           (upper(lv_type) = 'AMT' and lt_jm_diff_fr.amt is not null) then
          lrec_jm_diff                   := null;
          lrec_jm_diff.RECONCILIATION_NO := p_recon_no;
          lrec_jm_diff.RECON_LINE_NO     := p_line_tag;
          lrec_jm_diff.MONTH             := p_daytime;
          lrec_jm_diff.DIRECTION         := 'FROM';
          lrec_jm_diff.DIFF_TYPE         := 'FROM_ONLY';
           for  lt_jm_diff_to in C_to(lv_to_doc, lv_tag) loop
             if lt_jm_diff_fr.to_id = lt_jm_diff_to.to_id
               then
                 lrec_jm_diff.DIFF_TYPE  := 'DIFFERENT_FROM';
               exit;
              end if;
           end loop;


          lrec_jm_diff.REFERENCE_ID      := lt_jm_diff_fr
                                            .from_reference_id;
          lrec_jm_diff.REFERENCE_TYPE    := 'CONT_JOURNAL_ENTRY';
          lrec_jm_diff.SOURCE_TYPE       := NVL(lt_jm_diff_fr.source_type,CASE ec_cont_journal_entry.manual_ind(lt_jm_diff_fr.from_id) WHEN 'Y' THEN 'MANUAL' END);
          lrec_jm_diff.DFD_ID            := lt_jm_diff_fr.from_id;
          lrec_jm_diff.VALUE_TYPE        := case upper(lv_type)
                                              when 'QTY' then
                                               'QUANTITY'
                                              when 'AMT' then
                                               'AMOUNT'
                                            end;
          lrec_jm_diff.VALUE             := case upper(lv_type)
                                              when 'QTY' then
                                               lt_jm_diff_fr.qty
                                              when 'AMT' then
                                               lt_jm_diff_fr.amt
                                            end;
          lrec_jm_diff.DIFF_DFD_ID       := null;
          lrec_jm_diff.MAPPING_TYPE      := 'COST_MAPPING';
          lrec_jm_diff.MAPPING_ID        := NVL(ec_cont_journal_entry.cost_mapping_id(lt_jm_diff_fr.from_id),CASE ec_cont_journal_entry.manual_ind(lt_jm_diff_fr.from_id) WHEN 'Y' THEN 'MANUAL' END);
          lrec_jm_diff.RUN_TIME          := sysdate;
          lrec_jm_diff.COMMENTS          := null;
          lrec_jm_diff.ACCEPTED_IND      := null;
          lrec_jm_diff.PARAMETERS        := case
                                             lt_jm_diff_fr.source_type
                                              WHEN 'CLASS' then
                                               lt_jm_diff_fr.params
                                              else
                                               NULL
                                            end;
          PutInRecjmdif(lrec_jm_diff);
        end if;
      end loop;


       for  lt_jm_diff_to in C_to(lv_to_doc, lv_tag) loop
        if (upper(lv_type) = 'QTY' and lt_jm_diff_to.qty is not null) or
           (upper(lv_type) = 'AMT' and lt_jm_diff_to.amt is not null) then
          lrec_jm_diff                   := null;
          lrec_jm_diff.RECONCILIATION_NO := p_recon_no;
          lrec_jm_diff.RECON_LINE_NO     := p_line_tag;
          lrec_jm_diff.MONTH             := p_daytime;
          lrec_jm_diff.DIRECTION         := 'TO';
          lrec_jm_diff.DIFF_TYPE         := 'TO_ONLY';

           for lt_jm_diff_fr in C_from(lv_from_doc, lv_tag)  loop
             if lt_jm_diff_to.to_id = lt_jm_diff_fr.to_id
               then
                 lrec_jm_diff.DIFF_TYPE  := 'DIFFERENT_TO';
               exit;
              end if;
           end loop;

          lrec_jm_diff.REFERENCE_ID      := lt_jm_diff_to
                                            .from_reference_id;
          lrec_jm_diff.REFERENCE_TYPE    := 'CONT_JOURNAL_ENTRY';
          lrec_jm_diff.SOURCE_TYPE       := NVL(lt_jm_diff_to.source_type,CASE ec_cont_journal_entry.manual_ind(lt_jm_diff_to.from_id) WHEN 'Y' THEN 'MANUAL' END);
          lrec_jm_diff.DFD_ID            := lt_jm_diff_to.from_id;
          lrec_jm_diff.VALUE_TYPE        := case upper(lv_type)
                                              when 'QTY' then
                                               'QUANTITY'
                                              when 'AMT' then
                                               'AMOUNT'
                                            end;
          lrec_jm_diff.VALUE             := case upper(lv_type)
                                              when 'QTY' then
                                               lt_jm_diff_to.qty
                                              when 'AMT' then
                                               lt_jm_diff_to.amt
                                            end;
          lrec_jm_diff.DIFF_VALUE        := null;
          lrec_jm_diff.DIFF_DFD_ID       := null;
          lrec_jm_diff.MAPPING_TYPE      := 'COST_MAPPING';
          lrec_jm_diff.MAPPING_ID        := NVL(ec_cont_journal_entry.cost_mapping_id(lt_jm_diff_to.from_id),CASE ec_cont_journal_entry.manual_ind(lt_jm_diff_to.from_id) WHEN 'Y' THEN 'MANUAL' END);
          lrec_jm_diff.RUN_TIME          := sysdate;
          lrec_jm_diff.COMMENTS          := null;
          lrec_jm_diff.ACCEPTED_IND      := null;
          lrec_jm_diff.PARAMETERS        := null;
          PutInRecjmdif(lrec_jm_diff);
        end if;
      end loop;



  end RunExtractLine;
  ---------------------------------------------------------------------------------------------------
  -- Function      :  GetReconcileCode
  -- Description    : Allows using a user exit for generating Code
  ---------------------------------------------------------------------------------------------------

  function GetReconcileCode(p_reconciliation_no VARCHAR2,
                            p_reconcile_type    VARCHAR2,
                            p_from_doc_key      NUMBER,
                            p_to_doc_key        NUMBER,
                            p_compare_type      VARCHAR2) return VARCHAR2 is
    lv2_Code VARCHAR2(32);
  Begin
    IF ue_reconciliation.UseUEReconcileCode = TRUE THEN
      lv2_Code := ue_reconciliation.GetReconcileCode(p_reconciliation_no,
                                                     p_reconcile_type,
                                                     p_from_doc_key,
                                                     p_to_doc_key,
                                                     p_compare_type);
    ELSE
      lv2_Code := TO_CHAR(p_reconciliation_no);
    END IF;

    return lv2_Code;
  end GetReconcileCode;

  ---------------------------------------------------------------------------------------------------
  -- Function      :  AppendToTIPDiff
  -- Description    : This inserts the items into the diff type so that it can later be inserted into the table
  ---------------------------------------------------------------------------------------------------
  PROCEDURE AppendToTIPDiff(lt_diffs         IN OUT t_tip_diff,
                            p_object_id      VARCHAR2,
                            p_prod_stream_id VARCHAR2,
                            p_layer_month    DATE,
                            p_column_name    VARCHAR2,
                            p_from_doc_value NUMBER,
                            p_to_doc_value   NUMBER,
                            p_daytime        DATE) IS
    ln_last NUMBER;

    CURSOR GetProduct(cp_Column_number NUMBER) IS
      select product_id, 'PRODUCT' cost_type
        from product_group_setup pgs
       where product_group_type = 'TRANS_INV'
         AND pgs.product_column = cp_Column_number
         AND (pgs.OBJECT_ID) IN
             (SELECT prod_group_id
                FROM (SELECT ec_contract_attribute.attribute_string(object_id,
                                                                    'TRANS_INV_PROD_GROUP',
                                                                    daytime,
                                                                    '<=') prod_group_id,
                             rownum rownumber
                        FROM TRANS_INV_PROD_STREAM tips
                       WHERE OBJECT_ID = p_prod_stream_id
                         AND tips.inventory_id = p_object_id
                         AND daytime <= p_daytime
                         AND NVL(end_date, p_daytime + 1) > p_daytime
                       ORDER BY EXEC_ORDER)
               WHERE rownumber = 1);

    CURSOR GetProductCost(cp_Column_number NUMBER) IS
      select pgc.product_id, pgc.cost_type
        from product_group_setup pgs, PRODUCT_GROUP_COST pgc
       where product_group_type = 'TRANS_INV'
         AND pgc.object_id = pgs.object_id
         AND pgc.product_id = pgs.product_id
         AND pgc.cost_column = cp_column_number
         AND (pgs.OBJECT_ID) IN
             (SELECT prod_group_id
                FROM (SELECT ec_contract_attribute.attribute_string(object_id,
                                                                    'TRANS_INV_PROD_GROUP',
                                                                    daytime,
                                                                    '<=') prod_group_id,
                             rownum rownumber
                        FROM TRANS_INV_PROD_STREAM tips
                       WHERE OBJECT_ID = p_prod_stream_id
                         AND tips.inventory_id = p_object_id
                         AND daytime <= p_daytime
                         AND NVL(end_date, p_daytime + 1) > p_daytime
                       ORDER BY EXEC_ORDER)
               WHERE rownumber = 1);

    p_product_id     VARCHAR2(100);
    p_product_desc   VARCHAR2(100);
    p_cost_type      VARCHAR2(32);
    ln_column_number number;
  BEGIN

    --RAISE_APPLICATION_ERROR(-20001,EC_TRANS_INVENTORY.object_code(P_OBJECT_ID));

    --Need to pull the name to display for product and product cost
    ln_column_number := to_number(substr(p_column_name,
                                         instr(p_column_name, '_', -1) + 1));

    IF substr(p_column_name, 1, instr(p_column_name, '_', -1) - 1) !=
       'COST' THEN
      FOR p in GetProduct(ln_column_number) LOOP
        p_product_id   := p.product_id;
        p_cost_type    := p.cost_type;
        p_product_desc := ec_product_version.name(p.product_id,
                                                  p_daytime,
                                                  '<=');
      END LOOP;
    ELSE
      FOR p in GetProductCost(ln_column_number) LOOP
        p_product_id   := p.product_id;
        p_cost_type    := p.cost_type;
        p_product_desc := ec_product_version.name(p.product_id,
                                                  p_daytime,
                                                  '<=') || ' ' ||
                          ec_prosty_codes.code_text(p.cost_type,
                                                    'PRODUCT_COST_TYPE');
      END LOOP;
    END IF;

    lt_diffs.extend(1);
    ln_last := lt_diffs.count;
    lt_diffs(ln_last).INVENTORY_ID := p_object_id;
    lt_diffs(ln_last).PROD_STREAM_ID := p_prod_stream_id;
    lt_diffs(ln_last).MONTH := p_layer_month;
    lt_diffs(ln_last).COLUMN_NAME := p_column_name;
    lt_diffs(ln_last).FROM_VALUE := p_from_doc_value;
    lt_diffs(ln_last).TO_VALUE := p_to_doc_value;
    lt_diffs(ln_last).PRODUCT_DESC := p_product_desc;
    lt_diffs(ln_last).PRODUCT_ID := p_product_id;
    lt_diffs(ln_last).COST_TYPE := p_cost_type;

  END AppendToTIPDiff;


  ---------------------------------------------------------------------------------------------------
  -- Function      :  RunExtract
  -- Description    : Populates tables RECONCILE_DOC and RECONCILE_JE_DIF
  ---------------------------------------------------------------------------------------------------
    function RunExtract(p_compare_type VARCHAR2, p_document_key NUMBER)
    return varchar2

   is

    lv_calculation_id        varchar2(32);
    lv_calc_collection_id    varchar2(32);
    lv_contract_area         varchar2(32);
    lv_object_id             varchar2(32);
    lv_previous_document_key VARCHAR2(32);
    ld_from_run_time         DATE;
    ld_to_run_time           DATE;
    ld_daytime               DATE;
    ln_reconciliation_no     number;
    lv_code                  VARCHAR2(32);
    lv_log_no                VARCHAR2(32);
    lv_RECONCILE_JE_DIF      RECONCILE_JE_DIF%rowtype;
    ln_recon_line_no         NUMBER;
    lv_end_user_message      VARCHAR2(240) := 'Success!';

   CURSOR c_Previous_Doc_key(cp_accrual_ind    VARCHAR2,
                              cp_compare_type   VARCHAR2,
                              cp_calculation_id VARCHAR2) is
       SELECT run_no document_key
        FROM calc_reference
       WHERE accrual_ind = nvl(cp_accrual_ind, 'N')
         AND calc_collection_id = lv_calc_collection_id
		 AND object_id = lv_object_id
		 AND record_status in ('V', 'A', 'P')
         AND ((Daytime = ld_daytime AND cp_compare_type != 'EOPS_TO_LAST_MONTH_REPORT' AND cp_calculation_id = calculation_id)
              OR
              (cp_compare_type = 'EOPS_TO_LAST_MONTH_REPORT'
               AND decode(ec_calculation.object_code(cp_calculation_id),
                          'RRCA_REVN_EOPS_PRE', 'RRCA_REVN_MRC',
                          'RRCA_REVN_EOPS_POST', 'RRCA_REVN_GFE') = ec_calculation.object_code(calculation_id)
               AND daytime = (select daytime from (select cr.daytime from calc_reference cr
                                                    where decode(ec_calculation.object_code(cp_calculation_id),
                                                                'RRCA_REVN_EOPS_PRE', 'RRCA_REVN_MRC',
                                                                'RRCA_REVN_EOPS_POST', 'RRCA_REVN_GFE') = ec_calculation.object_code(cr.calculation_id)
                                                      AND to_char(ld_daytime, 'YYYY') = to_char(daytime, 'YYYY')
                                                      AND object_id = lv_object_id
                                                      AND calc_collection_id = lv_calc_collection_id
                                                    order by daytime desc)
                              where rownum <= 1)
              )
         )
       ORDER BY CREATED_DATE DESC;

    cursor c_from_data_extract(cp_document_key varchar2) is
      select *
        from cont_journal_summary
       where document_key in
             (select from_reference_id
                from dataset_flow_doc_conn
               where from_type = 'CONT_JOURNAL_SUMMARY'
                 and to_type = 'CALC_REF_ROY'
                 and to_reference_id = cp_document_key)
       order by tag;

    cursor c_to_data_extract(cp_document_key     varchar2,
                             cp_period           date,
                             cp_summary_setup_id varchar2,
                             cp_object_id        varchar2,
                             cp_tag              varchar2) is
      select *
        from cont_journal_summary
       where document_key in
             (select from_reference_id
                from dataset_flow_doc_conn
               where from_type = 'CONT_JOURNAL_SUMMARY'
                 and to_type = 'CALC_REF_ROY'
                 and to_reference_id = cp_document_key)
         and to_char(period, 'dd-mon-yyyy') =
             to_char(cp_period, 'dd-mon-yyyy')
         and object_id = cp_object_id
         and tag = cp_tag;

    cursor c_missing_data_extract(cp_from_document_key varchar2,
                                  cp_to_doc_key        VARCHAR2) is
      select *
        from cont_journal_summary
       where document_key in
             (select from_reference_id
                from dataset_flow_doc_conn
               where from_type = 'CONT_JOURNAL_SUMMARY'
                 and to_type = 'CALC_REF_ROY'
                 and to_reference_id = cp_from_document_key
                 and not exists
               (select from_reference_id
                        from dataset_flow_doc_conn
                       where from_type = 'CONT_JOURNAL_SUMMARY'
                         and to_type = 'CALC_REF_ROY'
                         and to_reference_id = cp_to_doc_key));

  Begin
    lv_log_no := ecdp_revn_log.createlog('RoyaltyRecon',
                                         ecdp_revn_log.log_status_running,
                                         'Starting Royalty Reconciliation');
    IF nvl(ec_calc_reference.prev_run_no(p_document_key), 0) = 0 and  p_compare_type != 'EOPS_TO_LAST_MONTH_REPORT' then
      lv_log_no := ecdp_revn_log.createlog('RoyaltyRecon',
                                           ecdp_revn_log.log_status_error,
                                           'The chosen document has no previous document to compare to');

      lv_end_user_message := 'Warning!' || chr(10) ||
                             'The chosen document has no previous document to compare to';
      return lv_end_user_message;
      /*  RAISE_APPLICATION_ERROR(-20001,
      'The chosen document has no previous document to compare to'); */
    ELSE
      begin
        select daytime, calculation_id, object_id, calc_collection_id
          into ld_daytime,
               lv_calculation_id,
               lv_object_id,
               lv_calc_collection_id
          from calc_reference
         where run_no = p_document_key;
      exception
        when others then
          lv_log_no := ecdp_revn_log.createlog('RoyaltyRecon',
                                               ecdp_revn_log.log_status_error,
                                               'calc reference does not have required values for selected run_no');

          lv_end_user_message := 'Error!' || chr(10) ||
                                 'calc reference does not have required values for selected run_no';
          return lv_end_user_message;
          /* RAISE_APPLICATION_ERROR(-20002,
          'calc reference does not have required values for selected run_no:' ||
          p_document_key);*/
      end;

      select ec_contract_version.contract_area_id(lv_object_id, ld_daytime)
        into lv_contract_area
        from dual;

      CASE p_compare_type
        WHEN 'TO_ACCRUAL' THEN
          lv_log_no := ecdp_revn_log.createlog('RoyaltyRecon',
                                               ecdp_revn_log.log_status_running,
                                               'Finding Previous Accrual Document');
          FOR p_doc in c_Previous_Doc_key('Y',
                                          p_compare_type,
                                          lv_calculation_id) LOOP

            IF p_doc.document_key != p_document_key THEN
              lv_previous_document_key := p_doc.document_key;
              EXIT;
            END IF;
          END LOOP;
          if lv_previous_document_key is null then
             lv_end_user_message := 'Error!' || chr(10) ||
                                 'Could not find any preceeding accrual document.';
          return lv_end_user_message;
          end if;

        WHEN 'TO_PRECEDING' THEN
          lv_log_no                := ecdp_revn_log.createlog('RoyaltyRecon',
                                                              ecdp_revn_log.log_status_running,
                                                              'Finding Previous Document');
          lv_previous_document_key := ec_calc_reference.prev_run_no(p_document_key);
          if lv_previous_document_key is null then
             lv_end_user_message := 'Error!' || chr(10) ||
                                 'Could not find any preceeding document.';
          return lv_end_user_message;
          end if;
        WHEN 'EOPS_TO_LAST_MONTH_REPORT' THEN
          lv_log_no := ecdp_revn_log.createlog('RoyaltyRecon',
                                               ecdp_revn_log.log_status_running,
                                               'Finding EOP Document');
          FOR p_doc in c_Previous_Doc_key('N',
                                          p_compare_type,
                                          lv_calculation_id) LOOP
            IF p_doc.document_key != p_document_key THEN
              lv_previous_document_key := p_doc.document_key;
              EXIT;
            END IF;
          END LOOP;

           if ec_calculation.object_code(lv_object_id) not like '%EOPS%' then
             lv_end_user_message := 'Error!' || chr(10) ||
                                 'The chosen document is not an EOPS document.';
          return lv_end_user_message;
           elsif lv_previous_document_key is null then
             lv_end_user_message := 'Error!' || chr(10) ||
                                 'Could not find a December document for the EOPS.';
          return lv_end_user_message;
          end if;
      END CASE;
      ld_from_run_time := ec_calc_reference.run_date(lv_previous_document_key);
      ld_to_run_time   := ec_calc_reference.run_date(p_document_key);
      ld_daytime       := ec_calc_reference.daytime(p_document_key);

      Ecdp_System_Key.assignNextNumber('RECONCILE_DOC',
                                       ln_reconciliation_no);

      lv_code := GetReconcileCode(ln_reconciliation_no,
                                  'CALC_REF_ROY',
                                  lv_previous_document_key,
                                  p_document_key,
                                  p_compare_type);
        BEGIN

        DELETE from RECONCILE_JM_DIF
         where reconciliation_no in
               (select reconciliation_no
                  from reconcile_doc
                 where reconcile_type = 'ROYALTY'
                   and to_doc = p_document_key
                   and compare_type=p_compare_type);

      EXCEPTION
        when others then
          lv_log_no := ecdp_revn_log.createlog('RoyaltyRecon',
                                               ecdp_revn_log.log_status_error,
                                               'Error deleting existing records from RECONCILE_JM_DIF');
          RAISE_APPLICATION_ERROR(-20003,
                                  'Error deleting existing records from RECONCILE_JM_DIF');
      END;

      BEGIN

        DELETE from RECONCILE_JE_DIF
         where reconciliation_no in
               (select reconciliation_no
                  from reconcile_doc
                 where reconcile_type = 'ROYALTY'
                   and to_doc = p_document_key
                   and compare_type=p_compare_type);

      EXCEPTION
        when others then
          lv_log_no := ecdp_revn_log.createlog('RoyaltyRecon',
                                               ecdp_revn_log.log_status_error,
                                               'Error deleting existing records from reconcile_doc');
          RAISE_APPLICATION_ERROR(-20003,
                                  'Error deleting existing records from reconcile_doc');
      END;

      BEGIN
        DELETE from reconcile_doc
         where reconcile_type = 'ROYALTY'
              and to_doc = p_document_key
              and compare_type=p_compare_type;

      EXCEPTION
        when others then
          lv_log_no           := ecdp_revn_log.createlog('RoyaltyRecon',
                                                         ecdp_revn_log.log_status_error,
                                                         'Error deleting existing records from reconcile_doc' || '-' ||
                                                         lv_previous_document_key || '-' ||
                                                         p_document_key);
          lv_end_user_message := 'Error!' || chr(10) ||
                                 'Error deleting existing records from reconcile_doc';
          return lv_end_user_message;
          /* RAISE_APPLICATION_ERROR(-20003,
          'Error deleting existing records from reconcile_doc');*/
      END;

      BEGIN
        insert into reconcile_doc
          (reconciliation_no,
           code,
           daytime,
           from_doc,
           to_doc,
           compare_type,
           reconcile_type,
           status,
           comments,
           created_by,
           created_date)
        values
          (ln_reconciliation_no,
           lv_code,
           ec_calc_reference.daytime(p_document_key),
           lv_previous_document_key,
           p_document_key,
           p_compare_type,
           'ROYALTY',
           'NEW',
           NULL,
           NVL(ecdp_context.getAppUser, 'system'),
           sysdate);
      EXCEPTION
        when others then
          lv_log_no           := ecdp_revn_log.createlog('RoyaltyRecon',
                                                         ecdp_revn_log.log_status_error,
                                                         'Error generating record for reconcile_doc');
          lv_end_user_message := 'Error!' || chr(10) ||
                                 'Error generating record for reconcile_doc';
          return lv_end_user_message;
          /*RAISE_APPLICATION_ERROR(-20003,
          'Error generating record for reconcile_doc');*/
      END;
    END IF;
    lv_log_no := ecdp_revn_log.createlog('RoyaltyRecon',
                                         ecdp_revn_log.log_status_running,
                                         'Checking differences for Amount and quantity in corresponding extract documents');
    for p_from_extract in c_from_data_extract(lv_previous_document_key) loop

      for p_to_extract in c_to_data_extract(p_document_key,
                                            p_from_extract.period,
                                            p_from_extract.summary_setup_id,
                                            p_from_extract.object_id,
                                            p_from_extract.tag) loop


        if nvl(p_from_extract.actual_amount, 0) <>
           nvl(p_to_extract.actual_amount, 0) or
           nvl(p_from_extract.amount_adjustment, 0) <>
           nvl(p_to_extract.amount_adjustment, 0) then

          begin
            Ecdp_System_Key.assignNextNumber('RECONCILE_JE_DIF',
                                             ln_recon_line_no);

            lv_RECONCILE_JE_DIF := NULL;

            lv_RECONCILE_JE_DIF.reconciliation_no := ln_reconciliation_no;
            lv_RECONCILE_JE_DIF.recon_line_no     := ln_recon_line_no;
            lv_RECONCILE_JE_DIF.from_doc          := p_from_extract.document_key;
            lv_RECONCILE_JE_DIF.to_doc            := p_to_extract.document_key;
            lv_RECONCILE_JE_DIF.month             := p_from_extract.period;
            lv_RECONCILE_JE_DIF.type              := 'Amt';
            lv_RECONCILE_JE_DIF.from_value        := p_from_extract.actual_amount;
            lv_RECONCILE_JE_DIF.to_value          := p_to_extract.actual_amount;
            lv_RECONCILE_JE_DIF.variance          := p_from_extract.actual_amount -
                                                     p_to_extract.actual_amount;
            lv_RECONCILE_JE_DIF.from_adj_value    := nvl(p_from_extract.amount_adjustment,0);
            lv_RECONCILE_JE_DIF.to_adj_value      := nvl(p_to_extract.amount_adjustment,0);
            lv_RECONCILE_JE_DIF.adj_variance      := nvl(p_to_extract.amount_adjustment,0) - nvl(p_from_extract.amount_adjustment,0);
            lv_RECONCILE_JE_DIF.comments          := NULL;
            lv_RECONCILE_JE_DIF.from_run_time     := ld_from_run_time;
            lv_RECONCILE_JE_DIF.to_run_time       := ld_to_run_time;
            --  lv_RECONCILE_JE_DIF.from_extract_obj_id := p_from_extract.object_id;
            -- lv_RECONCILE_JE_DIF.to_extract_obj_id   := p_to_extract.object_id;
            lv_RECONCILE_JE_DIF.from_extract_obj_id := p_from_extract.summary_setup_id;
            lv_RECONCILE_JE_DIF.to_extract_obj_id   := p_to_extract.summary_setup_id;
            lv_RECONCILE_JE_DIF.from_list_item_key  := p_from_extract.list_item_key;
            lv_RECONCILE_JE_DIF.to_list_item_key    := p_to_extract.list_item_key;
            lv_RECONCILE_JE_DIF.documents           := p_from_extract.document_key || '/' ||
                                                       p_to_extract.document_key;
            lv_RECONCILE_JE_DIF.tag                 := p_from_extract.tag;

            Insert_RECONCILE_JE_DIF(lv_RECONCILE_JE_DIF);

          EXCEPTION
            when others then
              lv_log_no := ecdp_revn_log.createlog('RoyaltyRecon',
                                                   ecdp_revn_log.log_status_error,
                                                   'Error generating record for journal extract amount difference');
              /*   RAISE_APPLICATION_ERROR(-20004,
              'Error generating record for journal extract amount difference');*/
              lv_end_user_message := 'Error!' || chr(10) ||
                                     'Error generating record for journal extract amount difference';
              return lv_end_user_message;
          END;
        END IF;
        if nvl(p_from_extract.actual_qty_1, 0) <>
           nvl(p_to_extract.actual_qty_1, 0) or
           nvl(p_from_extract.qty_adjustment, 0) <>
           nvl(p_to_extract.qty_adjustment, 0) then

          Ecdp_System_Key.assignNextNumber('RECONCILE_JE_DIF',
                                           ln_recon_line_no);
          begin

            lv_RECONCILE_JE_DIF := NULL;

            lv_RECONCILE_JE_DIF.reconciliation_no := ln_reconciliation_no;
            lv_RECONCILE_JE_DIF.recon_line_no     := ln_recon_line_no;
            lv_RECONCILE_JE_DIF.from_doc          := p_from_extract.document_key;
            lv_RECONCILE_JE_DIF.to_doc            := p_to_extract.document_key;
            lv_RECONCILE_JE_DIF.month             := p_from_extract.period;
            lv_RECONCILE_JE_DIF.type              := 'Qty';
            lv_RECONCILE_JE_DIF.from_value        := p_from_extract.actual_qty_1;
            lv_RECONCILE_JE_DIF.to_value          := p_to_extract.actual_qty_1;
            lv_RECONCILE_JE_DIF.variance          := p_from_extract.actual_qty_1 -
                                                     p_to_extract.actual_qty_1;
            lv_RECONCILE_JE_DIF.from_adj_value    := nvl(p_from_extract.qty_adjustment,0);
            lv_RECONCILE_JE_DIF.to_adj_value      := nvl(p_to_extract.qty_adjustment,0);
            lv_RECONCILE_JE_DIF.adj_variance      := nvl(p_to_extract.qty_adjustment,0) - nvl(p_from_extract.qty_adjustment,0);
            lv_RECONCILE_JE_DIF.comments          := NULL;
            lv_RECONCILE_JE_DIF.from_run_time     := ld_from_run_time;
            lv_RECONCILE_JE_DIF.to_run_time       := ld_to_run_time;
            -- lv_RECONCILE_JE_DIF.from_extract_obj_id := p_from_extract.object_id;
            -- lv_RECONCILE_JE_DIF.to_extract_obj_id   := p_to_extract.object_id;
            lv_RECONCILE_JE_DIF.from_extract_obj_id := p_from_extract.summary_setup_id;
            lv_RECONCILE_JE_DIF.to_extract_obj_id   := p_to_extract.summary_setup_id;
            lv_RECONCILE_JE_DIF.from_list_item_key  := p_from_extract.list_item_key;
            lv_RECONCILE_JE_DIF.to_list_item_key    := p_to_extract.list_item_key;
            lv_RECONCILE_JE_DIF.documents           := p_from_extract.document_key || '/' ||
                                                       p_to_extract.document_key;
            lv_RECONCILE_JE_DIF.tag                 := p_from_extract.tag;

            Insert_RECONCILE_JE_DIF(lv_RECONCILE_JE_DIF);

          EXCEPTION
            when others then
              lv_log_no           := ecdp_revn_log.createlog('RoyaltyRecon',
                                                             ecdp_revn_log.log_status_error,
                                                             'Error generating record for journal extract quantity difference');
              lv_end_user_message := 'Error!' || chr(10) ||
                                     'Error generating record for journal extract quantity difference';
              return lv_end_user_message;
              /*RAISE_APPLICATION_ERROR(-20005,
              'Error generating record for journal extract quantity difference');*/
          END;
        END IF;
      end loop;
    end loop;
    lv_log_no := ecdp_revn_log.createlog('RoyaltyRecon',
                                         ecdp_revn_log.log_status_running,
                                         'Checking for missing entries');

    for p_missing_data_extract in c_missing_data_extract(lv_previous_document_key,
                                                         p_document_key) loop
      Ecdp_System_Key.assignNextNumber('RECONCILE_JE_DIF',
                                       ln_recon_line_no);
      begin

        lv_RECONCILE_JE_DIF := NULL;

        lv_RECONCILE_JE_DIF.reconciliation_no := ln_reconciliation_no;
        lv_RECONCILE_JE_DIF.recon_line_no     := ln_recon_line_no;
        lv_RECONCILE_JE_DIF.from_doc          := p_missing_data_extract.document_key;
        lv_RECONCILE_JE_DIF.to_doc            := NULL;
        lv_RECONCILE_JE_DIF.month             := p_missing_data_extract.period;
        lv_RECONCILE_JE_DIF.type              := 'Qty';
        lv_RECONCILE_JE_DIF.from_value        := p_missing_data_extract.actual_qty_1;
        lv_RECONCILE_JE_DIF.to_value          := NULL;
        lv_RECONCILE_JE_DIF.variance          := p_missing_data_extract.actual_qty_1;
        lv_RECONCILE_JE_DIF.from_adj_value    := nvl(p_missing_data_extract.qty_adjustment,0);
        lv_RECONCILE_JE_DIF.to_adj_value      := NULL;
        lv_RECONCILE_JE_DIF.adj_variance      := nvl(p_missing_data_extract.qty_adjustment,0);
        lv_RECONCILE_JE_DIF.comments          := NULL;
        lv_RECONCILE_JE_DIF.from_run_time     := ld_from_run_time;
        lv_RECONCILE_JE_DIF.to_run_time       := ld_to_run_time;
        --   lv_RECONCILE_JE_DIF.from_extract_obj_id := p_missing_data_extract.object_id;
        --    lv_RECONCILE_JE_DIF.to_extract_obj_id   := NULL;

        lv_RECONCILE_JE_DIF.from_extract_obj_id := p_missing_data_extract.summary_setup_id;
        lv_RECONCILE_JE_DIF.to_extract_obj_id   := NULL;
        lv_RECONCILE_JE_DIF.from_list_item_key  := p_missing_data_extract.list_item_key;
        lv_RECONCILE_JE_DIF.to_list_item_key    := NULL;
        lv_RECONCILE_JE_DIF.documents           := p_missing_data_extract.document_key ||
                                                   ':NULL';
        lv_RECONCILE_JE_DIF.tag                 := p_missing_data_extract.tag;

        Insert_RECONCILE_JE_DIF(lv_RECONCILE_JE_DIF);

      EXCEPTION
        when others then
          lv_log_no := ecdp_revn_log.createlog('RoyaltyRecon',
                                               ecdp_revn_log.log_status_error,
                                               'Error generating record for journal extract quantity difference');
          /* RAISE_APPLICATION_ERROR(-20006,
          'Error generating record for journal extract quantity difference');*/
          lv_end_user_message := 'Error!' || chr(10) ||
                                 'Error generating record for journal extract quantity difference';
          return lv_end_user_message;
      END;

      begin
        lv_RECONCILE_JE_DIF := NULL;

        lv_RECONCILE_JE_DIF.reconciliation_no := ln_reconciliation_no;
        lv_RECONCILE_JE_DIF.recon_line_no     := ln_recon_line_no;
        lv_RECONCILE_JE_DIF.from_doc          := p_missing_data_extract.document_key;
        lv_RECONCILE_JE_DIF.to_doc            := NULL;
        lv_RECONCILE_JE_DIF.month             := p_missing_data_extract.period;
        lv_RECONCILE_JE_DIF.type              := 'Amt';
        lv_RECONCILE_JE_DIF.from_value        := p_missing_data_extract.actual_amount;
        lv_RECONCILE_JE_DIF.to_value          := NULL;
        lv_RECONCILE_JE_DIF.variance          := p_missing_data_extract.actual_amount;
        lv_RECONCILE_JE_DIF.from_adj_value    := nvl(p_missing_data_extract.amount_adjustment,0);
        lv_RECONCILE_JE_DIF.to_adj_value      := NULL;
        lv_RECONCILE_JE_DIF.adj_variance      := nvl(p_missing_data_extract.amount_adjustment,0);
        lv_RECONCILE_JE_DIF.comments          := NULL;
        lv_RECONCILE_JE_DIF.from_run_time     := ld_from_run_time;
        lv_RECONCILE_JE_DIF.to_run_time       := ld_to_run_time;
        --lv_RECONCILE_JE_DIF.from_extract_obj_id := p_missing_data_extract.object_id;
        --lv_RECONCILE_JE_DIF.to_extract_obj_id   := NULL;
        lv_RECONCILE_JE_DIF.from_extract_obj_id := p_missing_data_extract.summary_setup_id;
        lv_RECONCILE_JE_DIF.to_extract_obj_id   := NULL;
        lv_RECONCILE_JE_DIF.from_list_item_key  := p_missing_data_extract.list_item_key;
        lv_RECONCILE_JE_DIF.to_list_item_key    := NULL;
        lv_RECONCILE_JE_DIF.documents           := p_missing_data_extract.document_key ||
                                                   ':NULL';
        lv_RECONCILE_JE_DIF.tag                 := p_missing_data_extract.tag;

        Insert_RECONCILE_JE_DIF(lv_RECONCILE_JE_DIF);
      EXCEPTION
        when others then
          lv_log_no := ecdp_revn_log.createlog('RoyaltyRecon',
                                               ecdp_revn_log.log_status_error,
                                               'Error generating record for journal extract amount difference');
          /* RAISE_APPLICATION_ERROR(-20007,
          'Error generating record for journal extract amount difference');*/
          lv_end_user_message := 'Error!' || chr(10) ||
                                 'Error generating record for journal extract amount difference';
          return lv_end_user_message;
      END;
    end loop;

    for p_missing_data_extract in c_missing_data_extract(lv_previous_document_key,
                                                         p_document_key) loop
      Ecdp_System_Key.assignNextNumber('RECONCILE_JE_DIF',
                                       ln_recon_line_no);
      BEGIN
        lv_RECONCILE_JE_DIF := NULL;

        lv_RECONCILE_JE_DIF.reconciliation_no   := ln_reconciliation_no;
        lv_RECONCILE_JE_DIF.recon_line_no       := ln_recon_line_no;
        lv_RECONCILE_JE_DIF.from_doc            := NULL;
        lv_RECONCILE_JE_DIF.to_doc              := p_missing_data_extract.document_key;
        lv_RECONCILE_JE_DIF.month               := p_missing_data_extract.period;
        lv_RECONCILE_JE_DIF.type                := 'Qty';
        lv_RECONCILE_JE_DIF.from_value          := NULL;
        lv_RECONCILE_JE_DIF.to_value            := nvl(p_missing_data_extract.actual_qty_1,0);
        lv_RECONCILE_JE_DIF.variance            := nvl(p_missing_data_extract.actual_qty_1,0);
        lv_RECONCILE_JE_DIF.from_adj_value      := NULL;
        lv_RECONCILE_JE_DIF.to_adj_value        := nvl(p_missing_data_extract.qty_adjustment,0);
        lv_RECONCILE_JE_DIF.adj_variance        := nvl(p_missing_data_extract.qty_adjustment,0);
        lv_RECONCILE_JE_DIF.comments            := NULL;
        lv_RECONCILE_JE_DIF.from_run_time       := NULL;
        lv_RECONCILE_JE_DIF.to_run_time         := ld_to_run_time;
        lv_RECONCILE_JE_DIF.from_extract_obj_id := NULL;
        -- lv_RECONCILE_JE_DIF.to_extract_obj_id   := p_missing_data_extract.object_id;
        lv_RECONCILE_JE_DIF.to_extract_obj_id  := p_missing_data_extract.summary_setup_id;
        lv_RECONCILE_JE_DIF.from_list_item_key := NULL;
        lv_RECONCILE_JE_DIF.to_list_item_key   := p_missing_data_extract.list_item_key;
        lv_RECONCILE_JE_DIF.documents          := 'null:' ||
                                                  p_missing_data_extract.document_key;
        lv_RECONCILE_JE_DIF.tag                := p_missing_data_extract.tag;

        Insert_RECONCILE_JE_DIF(lv_RECONCILE_JE_DIF);
      EXCEPTION
        when others then
          lv_log_no := ecdp_revn_log.createlog('RoyaltyRecon',
                                               ecdp_revn_log.log_status_error,
                                               'Error generating record for journal extract quantity difference');
          /*RAISE_APPLICATION_ERROR(-20007,
          'Error generating record for journal extract quantity difference');*/
          lv_end_user_message := 'Error!' || chr(10) ||
                                 'Error generating record for journal extract quantity difference';
          return lv_end_user_message;
      END;
      Ecdp_System_Key.assignNextNumber('RECONCILE_JE_DIF',
                                       ln_recon_line_no);

      BEGIN
        lv_RECONCILE_JE_DIF := NULL;

        lv_RECONCILE_JE_DIF.reconciliation_no   := ln_reconciliation_no;
        lv_RECONCILE_JE_DIF.recon_line_no       := ln_recon_line_no;
        lv_RECONCILE_JE_DIF.from_doc            := NULL;
        lv_RECONCILE_JE_DIF.to_doc              := p_missing_data_extract.document_key;
        lv_RECONCILE_JE_DIF.month               := p_missing_data_extract.period;
        lv_RECONCILE_JE_DIF.type                := 'Amt';
        lv_RECONCILE_JE_DIF.from_value          := NULL;
        lv_RECONCILE_JE_DIF.to_value            := nvl(p_missing_data_extract.actual_amount,0);
        lv_RECONCILE_JE_DIF.variance            := nvl(p_missing_data_extract.actual_amount,0);
        lv_RECONCILE_JE_DIF.from_adj_value      := NULL;
        lv_RECONCILE_JE_DIF.to_adj_value        := nvl(p_missing_data_extract.amount_adjustment,0);
        lv_RECONCILE_JE_DIF.adj_variance        := nvl(p_missing_data_extract.amount_adjustment,0);
        lv_RECONCILE_JE_DIF.comments            := NULL;
        lv_RECONCILE_JE_DIF.from_run_time       := NULL;
        lv_RECONCILE_JE_DIF.to_run_time         := ld_to_run_time;
        lv_RECONCILE_JE_DIF.from_extract_obj_id := NULL;
        -- lv_RECONCILE_JE_DIF.to_extract_obj_id   := p_missing_data_extract.object_id;
        lv_RECONCILE_JE_DIF.to_extract_obj_id  := p_missing_data_extract.summary_setup_id;
        lv_RECONCILE_JE_DIF.from_list_item_key := NULL;
        lv_RECONCILE_JE_DIF.to_list_item_key   := p_missing_data_extract.list_item_key;
        lv_RECONCILE_JE_DIF.documents          := 'null:' ||
                                                  p_missing_data_extract.document_key;
        lv_RECONCILE_JE_DIF.tag                := p_missing_data_extract.tag;

        Insert_RECONCILE_JE_DIF(lv_RECONCILE_JE_DIF);
      EXCEPTION
        when others then
          lv_log_no := ecdp_revn_log.createlog('RoyaltyRecon',
                                               ecdp_revn_log.log_status_error,
                                               'Error generating record for journal extract amount difference');
          /* RAISE_APPLICATION_ERROR(-20007,
          'Error generating record for journal extract amount difference');*/
          lv_end_user_message := 'Error!' || chr(10) ||
                                 'Error generating record for journal extract amount difference';
          return lv_end_user_message;
      END;
    end loop;
    /* EXCEPTION
    when others then
      lv_log_no := ecdp_revn_log.createlog('RoyaltyRecon',
                                           ecdp_revn_log.log_status_error,
                                           'Error in running RunExtract:-'||sqlerrm);
      lv_end_user_message := 'Error!' || chr(10) || 'Error in running RunExtract';
      return lv_end_user_message;

    /*  RAISE_APPLICATION_ERROR(-20008,
                              'Error in running RunExtract' );*/

    return lv_end_user_message;
  end RunExtract;
  ---------------------------------------------------------------------------------------------------
  -- Function      :  RunTI
  -- Description    : Populates table RECONCILE_DOC cd D:\temp\ec-db-testdata-installer\ec-db
  ---------------------------------------------------------------------------------------------------

  Procedure RunTIP(p_document_key number, p_compare_type VARCHAR2) is

    cursor c_from(cp_document_key VARCHAR2) IS
      SELECT SUM(NVL(QTY_1, 0)) QTY_1,
             SUM(NVL(QTY_2, 0)) QTY_2,
             SUM(NVL(QTY_3, 0)) QTY_3,
             SUM(NVL(QTY_4, 0)) QTY_4,
             SUM(NVL(QTY_5, 0)) QTY_5,
             SUM(NVL(QTY_6, 0)) QTY_6,
             SUM(NVL(QTY_7, 0)) QTY_7,
             SUM(NVL(QTY_8, 0)) QTY_8,
             SUM(NVL(QTY_9, 0)) QTY_9,
             SUM(NVL(QTY_10, 0)) QTY_10,
             SUM(NVL(VALUE_1, 0)) VALUE_1,
             SUM(NVL(VALUE_2, 0)) VALUE_2,
             SUM(NVL(VALUE_3, 0)) VALUE_3,
             SUM(NVL(VALUE_4, 0)) VALUE_4,
             SUM(NVL(VALUE_5, 0)) VALUE_5,
             SUM(NVL(VALUE_6, 0)) VALUE_6,
             SUM(NVL(VALUE_7, 0)) VALUE_7,
             SUM(NVL(VALUE_8, 0)) VALUE_8,
             SUM(NVL(VALUE_9, 0)) VALUE_9,
             SUM(NVL(VALUE_10, 0)) VALUE_10,
             SUM(NVL(COST_1, 0)) COST_1,
             SUM(NVL(COST_2, 0)) COST_2,
             SUM(NVL(COST_3, 0)) COST_3,
             SUM(NVL(COST_4, 0)) COST_4,
             SUM(NVL(COST_5, 0)) COST_5,
             SUM(NVL(COST_6, 0)) COST_6,
             SUM(NVL(COST_7, 0)) COST_7,
             SUM(NVL(COST_8, 0)) COST_8,
             SUM(NVL(COST_9, 0)) COST_9,
             SUM(NVL(COST_10, 0)) COST_10,
             SUM(NVL(COST_11, 0)) COST_11,
             SUM(NVL(COST_12, 0)) COST_12,
             SUM(NVL(COST_13, 0)) COST_13,
             SUM(NVL(COST_14, 0)) COST_14,
             SUM(NVL(COST_15, 0)) COST_15,
             SUM(NVL(COST_16, 0)) COST_16,
             SUM(NVL(COST_17, 0)) COST_17,
             SUM(NVL(COST_18, 0)) COST_18,
             SUM(NVL(COST_19, 0)) COST_19,
             SUM(NVL(COST_20, 0)) COST_20,
             SUM(NVL(COST_21, 0)) COST_21,
             SUM(NVL(COST_22, 0)) COST_22,
             SUM(NVL(COST_23, 0)) COST_23,
             SUM(NVL(COST_24, 0)) COST_24,
             SUM(NVL(COST_25, 0)) COST_25,
             SUM(NVL(COST_26, 0)) COST_26,
             SUM(NVL(COST_27, 0)) COST_27,
             SUM(NVL(COST_28, 0)) COST_28,
             SUM(NVL(COST_29, 0)) COST_29,
             SUM(NVL(COST_30, 0)) COST_30,
             LAYER_MONTH,
             OBJECT_ID,
             PROD_STREAM_ID,
             CALC_RUN_NO
        FROM TRANS_INVENTORY_BALANCE
      HAVING CALC_RUN_NO = cp_document_key
       GROUP BY LAYER_MONTH, PROD_STREAM_ID, OBJECT_ID, CALC_RUN_NO
       ORDER BY LAYER_MONTH DESC, PROD_STREAM_ID, OBJECT_ID, CALC_RUN_NO;

    cursor c_to(cp_document_key   VARCHAR2,
                cp_inventory_id   VARCHAR2,
                cp_prod_Stream_id VARCHAR2,
                cp_layer_month    DATE) IS
      SELECT SUM(NVL(QTY_1, 0)) QTY_1,
             SUM(NVL(QTY_2, 0)) QTY_2,
             SUM(NVL(QTY_3, 0)) QTY_3,
             SUM(NVL(QTY_4, 0)) QTY_4,
             SUM(NVL(QTY_5, 0)) QTY_5,
             SUM(NVL(QTY_6, 0)) QTY_6,
             SUM(NVL(QTY_7, 0)) QTY_7,
             SUM(NVL(QTY_8, 0)) QTY_8,
             SUM(NVL(QTY_9, 0)) QTY_9,
             SUM(NVL(QTY_10, 0)) QTY_10,
             SUM(NVL(VALUE_1, 0)) VALUE_1,
             SUM(NVL(VALUE_2, 0)) VALUE_2,
             SUM(NVL(VALUE_3, 0)) VALUE_3,
             SUM(NVL(VALUE_4, 0)) VALUE_4,
             SUM(NVL(VALUE_5, 0)) VALUE_5,
             SUM(NVL(VALUE_6, 0)) VALUE_6,
             SUM(NVL(VALUE_7, 0)) VALUE_7,
             SUM(NVL(VALUE_8, 0)) VALUE_8,
             SUM(NVL(VALUE_9, 0)) VALUE_9,
             SUM(NVL(VALUE_10, 0)) VALUE_10,
             SUM(NVL(COST_1, 0)) COST_1,
             SUM(NVL(COST_2, 0)) COST_2,
             SUM(NVL(COST_3, 0)) COST_3,
             SUM(NVL(COST_4, 0)) COST_4,
             SUM(NVL(COST_5, 0)) COST_5,
             SUM(NVL(COST_6, 0)) COST_6,
             SUM(NVL(COST_7, 0)) COST_7,
             SUM(NVL(COST_8, 0)) COST_8,
             SUM(NVL(COST_9, 0)) COST_9,
             SUM(NVL(COST_10, 0)) COST_10,
             SUM(NVL(COST_11, 0)) COST_11,
             SUM(NVL(COST_12, 0)) COST_12,
             SUM(NVL(COST_13, 0)) COST_13,
             SUM(NVL(COST_14, 0)) COST_14,
             SUM(NVL(COST_15, 0)) COST_15,
             SUM(NVL(COST_16, 0)) COST_16,
             SUM(NVL(COST_17, 0)) COST_17,
             SUM(NVL(COST_18, 0)) COST_18,
             SUM(NVL(COST_19, 0)) COST_19,
             SUM(NVL(COST_20, 0)) COST_20,
             SUM(NVL(COST_21, 0)) COST_21,
             SUM(NVL(COST_22, 0)) COST_22,
             SUM(NVL(COST_23, 0)) COST_23,
             SUM(NVL(COST_24, 0)) COST_24,
             SUM(NVL(COST_25, 0)) COST_25,
             SUM(NVL(COST_26, 0)) COST_26,
             SUM(NVL(COST_27, 0)) COST_27,
             SUM(NVL(COST_28, 0)) COST_28,
             SUM(NVL(COST_29, 0)) COST_29,
             SUM(NVL(COST_30, 0)) COST_30,
             LAYER_MONTH,
             OBJECT_ID,
             PROD_STREAM_ID,
             CALC_RUN_NO
        FROM TRANS_INVENTORY_BALANCE
      HAVING CALC_RUN_NO = cp_document_key AND OBJECT_ID = cp_inventory_id AND PROD_STREAM_ID = cp_prod_stream_id AND LAYER_MONTH = cp_layer_month
       GROUP BY LAYER_MONTH, PROD_STREAM_ID, OBJECT_ID, CALC_RUN_NO;

    lv_previous_document_key VARCHAR2(32);
    lv_accrual_ind           VARCHAR2(1);
    lt_diffs                 t_TIP_DIFF;
    lt_Found_from            t_Found_from;
    lv_last                  number;
    ln_reconciliation_no     number;
    ln_recon_tip_no          number;
    lv_code                  VARCHAR2(32);
    ld_from_run_time         DATE;
    ld_to_run_time           DATE;
    ld_daytime               DATE;
    p_daytime                DATE := ec_calc_reference.daytime(p_document_key);
    p_product_stream_group   VARCHAR2(32) := ec_calc_reference.calc_collection_id(p_document_key);

    CURSOR c_Previous_Doc_key(cp_accrual_ind VARCHAR2,
                              cp_calculation VARCHAR2) is
      SELECT run_no document_key
        FROM calc_reference
       WHERE nvl(cp_accrual_ind, nvl(accrual_ind, 'N')) =
             nvl(accrual_ind, 'N')
         AND record_status in ('V', 'A', 'P')
         AND calculation_id = cp_calculation
         AND calc_collection_id = p_product_stream_group
         AND nvl(object_id, 'x') =
             nvl(ec_calc_reference.object_id(p_document_key), 'x')
         AND daytime = p_daytime
         AND run_date < ec_calc_reference.run_date(p_document_key)
       ORDER BY CREATED_DATE DESC;

    CURSOR c_from_missing(cp_from_doc_key VARCHAR2, cp_to_doc_key VARCHAR2) IS
      SELECT SUM(NVL(QTY_1, 0)) QTY_1,
             SUM(NVL(QTY_2, 0)) QTY_2,
             SUM(NVL(QTY_3, 0)) QTY_3,
             SUM(NVL(QTY_4, 0)) QTY_4,
             SUM(NVL(QTY_5, 0)) QTY_5,
             SUM(NVL(QTY_6, 0)) QTY_6,
             SUM(NVL(QTY_7, 0)) QTY_7,
             SUM(NVL(QTY_8, 0)) QTY_8,
             SUM(NVL(QTY_9, 0)) QTY_9,
             SUM(NVL(QTY_10, 0)) QTY_10,
             SUM(NVL(VALUE_1, 0)) VALUE_1,
             SUM(NVL(VALUE_2, 0)) VALUE_2,
             SUM(NVL(VALUE_3, 0)) VALUE_3,
             SUM(NVL(VALUE_4, 0)) VALUE_4,
             SUM(NVL(VALUE_5, 0)) VALUE_5,
             SUM(NVL(VALUE_6, 0)) VALUE_6,
             SUM(NVL(VALUE_7, 0)) VALUE_7,
             SUM(NVL(VALUE_8, 0)) VALUE_8,
             SUM(NVL(VALUE_9, 0)) VALUE_9,
             SUM(NVL(VALUE_10, 0)) VALUE_10,
             SUM(NVL(COST_1, 0)) COST_1,
             SUM(NVL(COST_2, 0)) COST_2,
             SUM(NVL(COST_3, 0)) COST_3,
             SUM(NVL(COST_4, 0)) COST_4,
             SUM(NVL(COST_5, 0)) COST_5,
             SUM(NVL(COST_6, 0)) COST_6,
             SUM(NVL(COST_7, 0)) COST_7,
             SUM(NVL(COST_8, 0)) COST_8,
             SUM(NVL(COST_9, 0)) COST_9,
             SUM(NVL(COST_10, 0)) COST_10,
             SUM(NVL(COST_11, 0)) COST_11,
             SUM(NVL(COST_12, 0)) COST_12,
             SUM(NVL(COST_13, 0)) COST_13,
             SUM(NVL(COST_14, 0)) COST_14,
             SUM(NVL(COST_15, 0)) COST_15,
             SUM(NVL(COST_16, 0)) COST_16,
             SUM(NVL(COST_17, 0)) COST_17,
             SUM(NVL(COST_18, 0)) COST_18,
             SUM(NVL(COST_19, 0)) COST_19,
             SUM(NVL(COST_20, 0)) COST_20,
             SUM(NVL(COST_21, 0)) COST_21,
             SUM(NVL(COST_22, 0)) COST_22,
             SUM(NVL(COST_23, 0)) COST_23,
             SUM(NVL(COST_24, 0)) COST_24,
             SUM(NVL(COST_25, 0)) COST_25,
             SUM(NVL(COST_26, 0)) COST_26,
             SUM(NVL(COST_27, 0)) COST_27,
             SUM(NVL(COST_28, 0)) COST_28,
             SUM(NVL(COST_29, 0)) COST_29,
             SUM(NVL(COST_30, 0)) COST_30,
             LAYER_MONTH,
             OBJECT_ID,
             PROD_STREAM_ID
        FROM TRANS_INVENTORY_BALANCE tib
      HAVING CALC_RUN_NO = p_DOCUMENT_KEY AND NOT EXISTS (SELECT OBJECT_ID
                                                            FROM TRANS_INVENTORY_BALANCE
                                                           WHERE tib.OBJECT_ID =
                                                                 OBJECT_ID
                                                             AND tib.LAYER_MONTH =
                                                                 LAYER_MONTH
                                                             AND tib.Prod_Stream_Id =
                                                                 PROD_STREAM_ID
                                                             AND CALC_RUN_NO =
                                                                 cp_from_doc_key)
       GROUP BY LAYER_MONTH, PROD_STREAM_ID, OBJECT_ID, CALC_RUN_NO;

  Begin
    CASE p_compare_type
      WHEN 'TO_ACCRUAL' THEN
        lv_accrual_ind := 'Y';
      ELSE
        lv_accrual_ind := null;
    END CASE;
    FOR p_doc in c_Previous_Doc_key(lv_accrual_ind,
                                    ec_calc_reference.calculation_id(p_document_key)) LOOP

      IF p_doc.document_key != p_document_key THEN
        lv_previous_document_key := p_doc.document_key;
        EXIT;
      END IF;
    END LOOP;

    IF lv_previous_document_key is null then
      RAISE_APPLICATION_ERROR(-20001,
                              'The chosen document has no document to compare to');
    END IF;

    ld_from_run_time := Ecdp_Date_Time.getCurrentDBSysdate(ec_calc_reference.run_date(lv_previous_document_key));
    ld_to_run_time   := Ecdp_Date_Time.getCurrentDBSysdate(ec_calc_reference.run_date(p_document_key));
    ld_daytime       := ec_calc_reference.daytime(p_document_key);

    Ecdp_System_Key.assignNextNumber('RECONCILE_DOC', ln_reconciliation_no);

    lv_code := GetReconcileCode(ln_reconciliation_no,
                                'CALC_REF_TIN',
                                lv_previous_document_key,
                                p_document_key,
                                p_compare_type);

    insert into reconcile_doc
      (reconciliation_no,
       code,
       daytime,
       from_doc,
       to_doc,
       compare_type,
       reconcile_type,
       status,
       comments,
       created_by,
       created_date)
    values
      (ln_reconciliation_no,
       lv_code,
       ec_calc_reference.daytime(p_document_key),
       lv_previous_document_key,
       p_document_key,
       p_compare_type,
       'CALC_REF_TIN',
       'NEW',
       NULL,
       NVL(ecdp_context.getAppUser, 'system'),
       sysdate);
    lt_Found_from := t_Found_from();
    lt_diffs      := t_tip_diff();

    FOR from_doc in c_from(lv_previous_document_key) LOOP

      lt_Found_from.extend(1);
      lt_Found_from(lt_Found_from.count).inventory_id := from_doc.object_id;
      lt_Found_from(lt_Found_from.count).prod_stream_id := from_doc.prod_stream_id;
      lt_Found_from(lt_Found_from.count).layer_month := from_doc.layer_month;

      FOR to_doc in c_to(p_document_key,
                         from_doc.object_id,
                         from_doc.prod_Stream_id,
                         from_doc.layer_month) LOOP

        IF NVL(from_doc.QTY_1, 0) != NVL(to_doc.QTY_1, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'QTY_1',
                          from_doc.QTY_1,
                          to_doc.QTY_1,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.QTY_2, 0) != NVL(to_doc.QTY_2, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'QTY_2',
                          from_doc.QTY_2,
                          to_doc.QTY_2,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.QTY_3, 0) != NVL(to_doc.QTY_3, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'QTY_3',
                          from_doc.QTY_3,
                          to_doc.QTY_3,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.QTY_4, 0) != NVL(to_doc.QTY_4, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'QTY_4',
                          from_doc.QTY_4,
                          to_doc.QTY_4,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.QTY_5, 0) != NVL(to_doc.QTY_5, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'QTY_5',
                          from_doc.QTY_5,
                          to_doc.QTY_5,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.QTY_6, 0) != NVL(to_doc.QTY_6, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'QTY_6',
                          from_doc.QTY_6,
                          to_doc.QTY_6,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.QTY_7, 0) != NVL(to_doc.QTY_7, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'QTY_7',
                          from_doc.QTY_7,
                          to_doc.QTY_7,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.QTY_8, 0) != NVL(to_doc.QTY_8, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'QTY_8',
                          from_doc.QTY_8,
                          to_doc.QTY_8,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.QTY_9, 0) != NVL(to_doc.QTY_9, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'QTY_9',
                          from_doc.QTY_9,
                          to_doc.QTY_9,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.QTY_10, 0) != NVL(to_doc.QTY_10, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'QTY_10',
                          from_doc.QTY_10,
                          to_doc.QTY_10,
                          ld_daytime);
        END IF;

        IF NVL(from_doc.VALUE_1, 0) != NVL(to_doc.VALUE_1, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'VALUE_1',
                          from_doc.VALUE_1,
                          to_doc.VALUE_1,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.VALUE_2, 0) != NVL(to_doc.VALUE_2, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'VALUE_2',
                          from_doc.VALUE_2,
                          to_doc.VALUE_2,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.VALUE_3, 0) != NVL(to_doc.VALUE_3, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'VALUE_3',
                          from_doc.VALUE_3,
                          to_doc.VALUE_3,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.VALUE_4, 0) != NVL(to_doc.VALUE_4, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'VALUE_4',
                          from_doc.VALUE_4,
                          to_doc.VALUE_4,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.VALUE_5, 0) != NVL(to_doc.VALUE_5, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'VALUE_5',
                          from_doc.VALUE_5,
                          to_doc.VALUE_5,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.VALUE_6, 0) != NVL(to_doc.VALUE_6, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'VALUE_6',
                          from_doc.VALUE_6,
                          to_doc.VALUE_6,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.VALUE_7, 0) != NVL(to_doc.VALUE_7, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'VALUE_7',
                          from_doc.VALUE_7,
                          to_doc.VALUE_7,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.VALUE_8, 0) != NVL(to_doc.VALUE_8, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'VALUE_8',
                          from_doc.VALUE_8,
                          to_doc.VALUE_8,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.VALUE_9, 0) != NVL(to_doc.VALUE_9, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'VALUE_9',
                          from_doc.VALUE_9,
                          to_doc.VALUE_9,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.VALUE_10, 0) != NVL(to_doc.VALUE_10, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'VALUE_10',
                          from_doc.VALUE_10,
                          to_doc.VALUE_10,
                          ld_daytime);
        END IF;

        IF NVL(from_doc.COST_1, 0) != NVL(to_doc.COST_1, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'COST_1',
                          from_doc.COST_1,
                          to_doc.COST_1,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.COST_2, 0) != NVL(to_doc.COST_2, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'COST_2',
                          from_doc.COST_2,
                          to_doc.COST_2,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.COST_3, 0) != NVL(to_doc.COST_3, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'COST_3',
                          from_doc.COST_3,
                          to_doc.COST_3,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.COST_4, 0) != NVL(to_doc.COST_4, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'COST_4',
                          from_doc.COST_4,
                          to_doc.COST_4,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.COST_5, 0) != NVL(to_doc.COST_5, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'COST_5',
                          from_doc.COST_5,
                          to_doc.COST_5,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.COST_6, 0) != NVL(to_doc.COST_6, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'COST_6',
                          from_doc.COST_6,
                          to_doc.COST_6,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.COST_7, 0) != NVL(to_doc.COST_7, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'COST_7',
                          from_doc.COST_7,
                          to_doc.COST_7,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.COST_8, 0) != NVL(to_doc.COST_8, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'COST_8',
                          from_doc.COST_8,
                          to_doc.COST_8,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.COST_9, 0) != NVL(to_doc.COST_9, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'COST_9',
                          from_doc.COST_9,
                          to_doc.COST_9,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.COST_10, 0) != NVL(to_doc.COST_10, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'COST_10',
                          from_doc.COST_10,
                          to_doc.COST_10,
                          ld_daytime);

        END IF;
        IF NVL(from_doc.COST_11, 0) != NVL(to_doc.COST_11, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'COST_11',
                          from_doc.COST_11,
                          to_doc.COST_11,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.COST_12, 0) != NVL(to_doc.COST_12, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'COST_12',
                          from_doc.COST_12,
                          to_doc.COST_12,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.COST_13, 0) != NVL(to_doc.COST_13, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'COST_13',
                          from_doc.COST_13,
                          to_doc.COST_13,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.COST_14, 0) != NVL(to_doc.COST_14, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'COST_14',
                          from_doc.COST_14,
                          to_doc.COST_14,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.COST_15, 0) != NVL(to_doc.COST_15, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'COST_15',
                          from_doc.COST_15,
                          to_doc.COST_15,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.COST_16, 0) != NVL(to_doc.COST_16, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'COST_16',
                          from_doc.COST_16,
                          to_doc.COST_16,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.COST_17, 0) != NVL(to_doc.COST_17, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'COST_17',
                          from_doc.COST_17,
                          to_doc.COST_17,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.COST_18, 0) != NVL(to_doc.COST_18, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'COST_18',
                          from_doc.COST_18,
                          to_doc.COST_18,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.COST_19, 0) != NVL(to_doc.COST_19, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'COST_19',
                          from_doc.COST_19,
                          to_doc.COST_19,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.COST_20, 0) != NVL(to_doc.COST_20, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'COST_20',
                          from_doc.COST_20,
                          to_doc.COST_20,
                          ld_daytime);
        END IF;
        IF NVL(from_doc.COST_21, 0) != NVL(to_doc.COST_21, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'COST_21',
                          from_doc.COST_21,
                          to_doc.COST_21,
                          ld_daytime);
         END IF;
         IF NVL(from_doc.COST_22, 0) != NVL(to_doc.COST_22, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'COST_22',
                          from_doc.COST_22,
                          to_doc.COST_22,
                          ld_daytime);
         END IF;
         IF NVL(from_doc.COST_23, 0) != NVL(to_doc.COST_23, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'COST_23',
                          from_doc.COST_23,
                          to_doc.COST_23,
                          ld_daytime);
         END IF;
         IF NVL(from_doc.COST_24, 0) != NVL(to_doc.COST_24, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'COST_24',
                          from_doc.COST_24,
                          to_doc.COST_24,
                          ld_daytime);
         END IF;
         IF NVL(from_doc.COST_25, 0) != NVL(to_doc.COST_25, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'COST_25',
                          from_doc.COST_25,
                          to_doc.COST_25,
                          ld_daytime);
         END IF;
         IF NVL(from_doc.COST_26, 0) != NVL(to_doc.COST_26, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'COST_26',
                          from_doc.COST_26,
                          to_doc.COST_26,
                          ld_daytime);
          END IF;
         IF NVL(from_doc.COST_27, 0) != NVL(to_doc.COST_27, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'COST_27',
                          from_doc.COST_27,
                          to_doc.COST_27,
                          ld_daytime);
        END IF;
         IF NVL(from_doc.COST_28, 0) != NVL(to_doc.COST_28, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'COST_28',
                          from_doc.COST_28,
                          to_doc.COST_28,
                          ld_daytime);
         END IF;
         IF NVL(from_doc.COST_29, 0) != NVL(to_doc.COST_29, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'COST_29',
                          from_doc.COST_29,
                          to_doc.COST_29,
                          ld_daytime);
         END IF;
         IF NVL(from_doc.COST_30, 0) != NVL(to_doc.COST_30, 0) THEN
          AppendToTIPDiff(lt_diffs,
                          to_doc.object_id,
                          to_doc.prod_stream_id,
                          to_doc.LAYER_MONTH,
                          'COST_30',
                          from_doc.COST_30,
                          to_doc.COST_30,
                          ld_daytime);
        END IF;
      END LOOP;
      NULL;
      --Fill in all types
    END LOOP;

    -- Add loop for when in to and not from
    FOR to_doc in c_from_missing(lv_previous_document_key, p_document_key) LOOP

      IF NVL(to_doc.QTY_1, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'QTY_1',
                        0,
                        to_doc.QTY_1,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.QTY_2, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'QTY_2',
                        0,
                        to_doc.QTY_2,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.QTY_3, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'QTY_3',
                        0,
                        to_doc.QTY_3,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.QTY_4, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'QTY_4',
                        0,
                        to_doc.QTY_4,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.QTY_5, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'QTY_5',
                        0,
                        to_doc.QTY_5,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.QTY_6, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'QTY_6',
                        0,
                        to_doc.QTY_6,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.QTY_7, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'QTY_7',
                        0,
                        to_doc.QTY_7,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.QTY_8, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'QTY_8',
                        0,
                        to_doc.QTY_8,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.QTY_9, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'QTY_9',
                        0,
                        to_doc.QTY_9,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.QTY_10, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'QTY_10',
                        0,
                        to_doc.QTY_10,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.VALUE_1, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'VALUE_1',
                        0,
                        to_doc.VALUE_1,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.VALUE_2, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'VALUE_2',
                        0,
                        to_doc.VALUE_2,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.VALUE_3, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'VALUE_3',
                        0,
                        to_doc.VALUE_3,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.VALUE_4, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'VALUE_4',
                        0,
                        to_doc.VALUE_4,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.VALUE_5, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'VALUE_5',
                        0,
                        to_doc.VALUE_5,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.VALUE_6, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'VALUE_6',
                        0,
                        to_doc.VALUE_6,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.VALUE_7, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'VALUE_7',
                        0,
                        to_doc.VALUE_7,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.VALUE_8, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'VALUE_8',
                        0,
                        to_doc.VALUE_8,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.VALUE_9, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'VALUE_9',
                        0,
                        to_doc.VALUE_9,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.VALUE_10, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'VALUE_10',
                        0,
                        to_doc.VALUE_10,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.COST_1, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'COST_1',
                        0,
                        to_doc.COST_1,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.COST_2, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'COST_2',
                        0,
                        to_doc.COST_2,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.COST_3, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'COST_3',
                        0,
                        to_doc.COST_3,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.COST_4, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'COST_4',
                        0,
                        to_doc.COST_4,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.COST_5, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'COST_5',
                        0,
                        to_doc.COST_5,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.COST_6, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'COST_6',
                        0,
                        to_doc.COST_6,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.COST_7, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'COST_7',
                        0,
                        to_doc.COST_7,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.COST_8, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'COST_8',
                        0,
                        to_doc.COST_8,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.COST_9, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'COST_9',
                        0,
                        to_doc.COST_9,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.COST_10, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'COST_10',
                        0,
                        to_doc.COST_10,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.COST_11, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'COST_11',
                        0,
                        to_doc.COST_11,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.COST_12, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'COST_12',
                        0,
                        to_doc.COST_12,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.COST_13, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'COST_13',
                        0,
                        to_doc.COST_13,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.COST_14, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'COST_14',
                        0,
                        to_doc.COST_14,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.COST_15, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'COST_15',
                        0,
                        to_doc.COST_15,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.COST_16, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'COST_16',
                        0,
                        to_doc.COST_16,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.COST_17, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'COST_17',
                        0,
                        to_doc.COST_17,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.COST_18, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'COST_18',
                        0,
                        to_doc.COST_18,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.COST_19, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'COST_19',
                        0,
                        to_doc.COST_19,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.COST_20, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'COST_20',
                        0,
                        to_doc.COST_20,
                        ld_daytime);

      END IF;
       IF NVL(to_doc.COST_21, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'COST_21',
                        0,
                        to_doc.COST_21,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.COST_22, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'COST_22',
                        0,
                        to_doc.COST_22,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.COST_23, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'COST_23',
                        0,
                        to_doc.COST_23,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.COST_24, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'COST_24',
                        0,
                        to_doc.COST_24,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.COST_25, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'COST_25',
                        0,
                        to_doc.COST_25,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.COST_26, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'COST_26',
                        0,
                        to_doc.COST_26,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.COST_27, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'COST_27',
                        0,
                        to_doc.COST_27,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.COST_28, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'COST_28',
                        0,
                        to_doc.COST_28,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.COST_29, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'COST_29',
                        0,
                        to_doc.COST_29,
                        ld_daytime);
      END IF;
      IF NVL(to_doc.COST_30, 0) != 0 THEN
        AppendToTIPDiff(lt_diffs,
                        to_doc.object_id,
                        to_doc.prod_stream_id,
                        to_doc.LAYER_MONTH,
                        'COST_30',
                        0,
                        to_doc.COST_30,
                        ld_daytime);
      END IF;
    END LOOP;

    if nvl(lt_diffs.first, -1) > -1 then

      FOR i in lt_diffs.first .. lt_diffs.last LOOP

        Ecdp_System_Key.assignNextNumber('RECONCILE_TIP_DIFF',
                                         ln_recon_tip_no);

        insert into reconcile_tip_diff
          (RECONCILIATION_NO,
           RECON_TIP_NO,
           FROM_DOC,
           TO_DOC,
           PROD_STREAM_ID,
           INVENTORY_ID,
           LAYER_MONTH,
           PRODUCT_DESC,
           PRODUCT_ID,
           COST_TYPE,
           COLUMN_TYPE,
           FROM_NUMBER,
           TO_NUMBER,
           COMMENTS,
           FROM_RUN_TIME,
           TO_RUN_TIME,
           CREATED_BY,
           CREATED_DATE)
        VALUEs
          (ln_reconciliation_no,
           ln_recon_tip_no,
           lv_previous_document_key,
           p_document_key,
           lt_diffs(i).PROD_STREAM_ID,
           lt_diffs(i).INVENTORY_ID,
           lt_diffs(i).MONTH,
           NVL(lt_diffs(i).PRODUCT_DESC, 'UNKNOWN'),
           lt_diffs(i).PRODUCT_ID,
           lt_diffs(i).COST_TYPE,
           lt_diffs(i).COLUMN_NAME,
           lt_diffs(i).FROM_VALUE,
           lt_diffs(i).TO_VALUE,
           NULL,
           ld_from_run_time,
           ld_to_run_time,
           ecdp_context.getAppUser,
           sysdate);
      END LOOP;
    END IF;
  END;

  FUNCTION RunTILP(p_recon_tiP_no NUMBER /*,
                    p_daytime         p  DATE,
                    p_product_stream_id  VARCHAR2,
                    p_trans_inventory_id VARCHAR2,
                    p_month              DATE,
                    p_product_column     VARCHAR2*/) RETURN VARCHAR2 is

    CURSOR c_CheckOnValuationMethod(cp_inventory_id VARCHAR2) is
      SELECT VALUATION_METHOD
        FROM OV_TRANS_INVENTORY v
       WHERE v.object_id = cp_inventory_id;


    lv_end_user_message VARCHAR2(240) := 'Success!';
    lv2_Query           varchar2(4000);
    lv2_dimension_tag   varchar(4000);
    lv2_transaction_tag varchar(4000);
    lv2_from_doc_key    VARCHAR2(32);
    lv2_to_doc_key      VARCHAR2(32);
    ln_number           NUMBER;
    ld_layer_month      DATE;
    lrec_tip            RECONCILE_TIP_DIFF%ROWTYPE;
    cur                 cv_type;
    lt_diffs            t_TILP_DIFF;
    lb_found            BOOLEAN;
    ln_recon_tilp_no    number;
    lv2_source_type     VARCHAR2(32);
  Begin

    DELETE FROM reconcile_tilp_src_diff
     WHERE RECON_TIP_NO = p_recon_tiP_no;
    DELETE FROM reconcile_tilp_diff WHERE RECON_TIP_NO = p_recon_tiP_no;

    lt_diffs := t_tilp_diff();

    lrec_tip := ec_reconcile_tip_diff.row_by_pk(p_recon_tiP_no);



/*    FOR chk in c_CheckOnValuationMethod(lrec_tip.inventory_id) LOOP

      IF (chk.valuation_method = 'SUMMARY_LINE') or
         (chk.valuation_method = 'SUMMARY_INVENTORY') then
        lv_end_user_message := 'Warning!' || '\n' ||
                               'This operation is not permitted here as the valuation method of Inventory is ' ||
                               chk.valuation_method;
      END IF;
    END LOOP;*/

--RAISE_APPLICATION_ERROR(-20001,p_recon_tiP_no ||'-'||lrec_tip.inventory_id || '&'||lv_end_user_message);

    if lv_end_user_message = 'Success!' then


        lv2_Query := '    SELECT SUM(NVL(' || lrec_tip.column_type ||
                     ', 0)) VALUE,
        DIMENSION_TAG,
        TRANSACTION_TAG,
        LAYER_MONTH
        FROM (
             SELECT '|| lrec_tip.column_type ||',
             CALC_RUN_NO,
             OBJECT_ID,
             PROD_STREAM_ID,
             DIMENSION_TAG,
             TRANSACTION_TAG,
                      LAYER_MONTH
                      FROM
                      TRANS_INVENTORY_TRANS)
        HAVING CALC_RUN_NO = ' || lrec_tip.from_doc || '
        AND OBJECT_ID = ''' || lrec_tip.inventory_id || '''
        AND PROD_STREAM_ID = ''' || lrec_tip.prod_stream_id || '''
        AND TRANSACTION_TAG != ''REBALANCE_LINE''
        GROUP BY LAYER_MONTH, PROD_STREAM_ID, OBJECT_ID,CALC_RUN_NO, TRANSACTION_TAG, DIMENSION_TAG';

       --  RAISE_APPLICATION_ERROR(-20001, lv2_Query);
        OPEN cur FOR lv2_Query;
        LOOP
          FETCH cur
            INTO ln_number,
                 lv2_dimension_tag,
                 lv2_transaction_tag,
                 ld_layer_month;
          EXIT WHEN cur%notfound;
          lt_diffs.extend(1);
          lt_diffs(lt_diffs.count).DIMENSION_TAG := lv2_DIMENSION_TAG;
          lt_diffs(lt_diffs.count).TRANSACTION_TAG := lv2_TRANSACTION_TAG;
          lt_diffs(lt_diffs.count).FROM_VALUE := ln_number;
          lt_diffs(lt_diffs.count).LAYER_MONTH := ld_layer_month;
          lt_diffs(lt_diffs.count).HANDLED := false;
        END LOOP;
        CLOSE cur;

        lv2_Query := '    SELECT SUM(NVL(' || lrec_tip.column_type ||
                     ', 0)) VALUE,
        DIMENSION_TAG,TRANSACTION_TAG,
        LAYER_MONTH
        FROM (
             SELECT '|| lrec_tip.column_type ||',
             CALC_RUN_NO,
             OBJECT_ID,
             PROD_STREAM_ID,
             DIMENSION_TAG,
             TRANSACTION_TAG,
                      LAYER_MONTH
                      FROM
                      TRANS_INVENTORY_TRANS)
        HAVING CALC_RUN_NO = ''' || lrec_tip.to_doc || '''
        AND TRANSACTION_TAG != ''REBALANCE_LINE''
        AND OBJECT_ID = ''' || lrec_tip.inventory_id || '''
        AND PROD_STREAM_ID = ''' || lrec_tip.prod_stream_id || '''
        GROUP BY LAYER_MONTH, PROD_STREAM_ID, OBJECT_ID,CALC_RUN_NO, TRANSACTION_TAG, DIMENSION_TAG';

        --    RAISE_APPLICATION_ERROR(-20001, lv2_Query);

        OPEN cur FOR lv2_Query;
        lb_found := false;
        LOOP
          FETCH cur
            INTO ln_number,
                 lv2_dimension_tag,
                 lv2_transaction_tag,
                 ld_layer_month;
          EXIT WHEN cur%notfound;

          for i in lt_diffs.first .. lt_diffs.last loop

            lb_found := false;
            IF lt_diffs(i).DIMENSION_TAG = lv2_dimension_tag AND lt_diffs(i)
               .transaction_TAG = lv2_transaction_tag AND lt_diffs(i)
               .layer_month = ld_layer_month THEN
              lb_found := true;

              lt_diffs(I).TO_VALUE := ln_number;

              IF nvl(lt_diffs(I).FROM_VALUE, 0) = nvl(ln_number, 0) then
                lt_diffs(I).HANDLED := TRUE;

                --else
                --  lt_diffs(I).HANDLED := false;
              END IF;
              lb_found := true;
              EXIT;
            END IF;

          END LOOP;
          IF lb_found = FALSE THEN
            lt_diffs.extend(1);
            lt_diffs(lt_diffs.count).DIMENSION_TAG := lv2_DIMENSION_TAG;
            lt_diffs(lt_diffs.count).TRANSACTION_TAG := lv2_TRANSACTION_TAG;
            lt_diffs(lt_diffs.count).TO_VALUE := ln_number;
            lt_diffs(lt_diffs.count).FROM_VALUE := 0;

            lt_diffs(lt_diffs.count).HANDLED := false;
          END IF;
        END LOOP;
        CLOSE cur;
        if nvl(lt_diffs.first, -1) > -1 then
          FOR i in lt_diffs.first .. lt_diffs.last LOOP

            if lt_diffs(i).handled = false then
              Ecdp_System_Key.assignNextNumber('RECONCILE_TILP_DIFF',
                                               ln_recon_tilp_no);

              lv2_source_type := 'CALCULATED';
              insert into reconcile_tilp_diff
                (RECONCILIATION_NO,
                 RECON_TIP_NO,
                 RECON_TILP_NO,
                 LINE_TAG,
                 MAPPING_ID,
                 SOURCE_TYPE,
                 PROD_MTH,
                 DIMENSION1,
                 DIMENSION2,
                 FROM_NUMBER,
                 TO_NUMBER,
                 CREATED_BY,
                 CREATED_DATE)
              VALUEs
                (lrec_tip.Reconciliation_No,
                 lrec_tip.recon_tip_no,
                 ln_recon_tilp_no,
                 lt_diffs(i).TRANSACTION_TAG,
                 NULL,
                 lv2_source_type,
                 TO_dATE(substr(lt_diffs(i).dimension_tag,
                                instr(lt_diffs(i).dimension_tag, '|', -1) + 1),
                         'YYYY-MM-DD"T"HH24:MI:SS'),
                 substr(lt_diffs(i).dimension_tag,
                        1,
                        instr(lt_diffs(i).dimension_tag, '|', 1) - 1),
                 substr(lt_diffs(i).dimension_tag,
                        instr(lt_diffs(i).dimension_tag, '|', 1) + 1,
                        instr(lt_diffs(i).dimension_tag, '|', -1) -
                        instr(lt_diffs(i).dimension_tag, '|', 1) - 1),
                 lt_diffs(i).FROM_VALUE,
                 lt_diffs(i).TO_VALUE,
                 ecdp_context.getAppUser,
                 sysdate);
            END IF;
          END LOOP;
        END IF;
    END IF;
    --Should insert only those items where the value is not the same or missing from the other calc*/
    RETURN lv_end_user_message;

  END;

  Function RunTILP_SRC(p_recon_tilp_no number) RETURN VARCHAR2 IS

    CURSOR c_CheckOnValuationMethod(cp_inventory_id VARCHAR2) is
      SELECT VALUATION_METHOD
        FROM OV_TRANS_INVENTORY v
       WHERE v.object_id = cp_inventory_id;
    CURSOR c_GetLine(cp_period         DATE,
                     cp_prod_stream_id VARCHAR2,
                     cp_inventory_id   VARCHAR2,
                     cp_line_tag       VARCHAR2) is
      SELECT *
        FROM V_TRANS_INV_LINE_OVERRIDE v
       WHERE v.object_id = cp_inventory_id
         AND contract_id = cp_prod_stream_id
         AND period = cp_period
         AND v.tag = cp_line_tag;

    CURSOR c_GetLineProduct(cp_period         DATE,
                            cp_prod_stream_id VARCHAR2,
                            cp_inventory_id   VARCHAR2,
                            cp_line_tag       VARCHAR2,
                            cp_product_id     VARCHAR2,
                            cp_cost_type      VARCHAR2) is
      SELECT id
        FROM V_TRANS_INV_LI_PR_OVER v
       WHERE v.object_id = cp_inventory_id
         AND PROJECT = cp_prod_stream_id
         AND period = cp_period
         AND LINE_TAG = cp_line_tag
         AND PRODUCT_ID = cp_product_id
         AND COST_TYPE = cp_cost_type;

    CURSOR c_GetLineProdVar(cp_period         DATE,
                            cp_prod_stream_id VARCHAR2,
                            cp_inventory_id   VARCHAR2,
                            cp_line_tag       VARCHAR2,
                            cp_product_id     VARCHAR2,
                            cp_cost_type      VARCHAR2,
                            cp_val_type       VARCHAR2) is
      SELECT *
        FROM v_TRANS_INV_LI_PR_VAR_OVER v
       WHERE v.object_id = cp_inventory_id
         AND prod_stream_id = cp_prod_stream_id
         AND DAYTIME <= cp_period
         AND NVL(END_DATE, cp_period + 1) > cp_period
         AND LINE_TAG = cp_line_tag
         AND PRODUCT_ID = cp_product_id
         AND COST_TYPE = cp_cost_type
         AND cp_val_type = decode(TYPE, 'BOTH', cp_val_type, TYPE);

    CURSOR c_SummaryItem(cp_period         DATE,
                         cp_prod_stream_id VARCHAR2,
                         cp_inventory_id   VARCHAR2) IS
      SELECT source_trans_inv_line,
             source_prod_stream_id,
             source_trans_inv_id,
             layer_method,
             dimensions,
             prod_mth,
             id
        FROM TRANS_INV_SUMMARY_ITEM v
       WHERE v.TRANS_INV_ID = cp_inventory_id
         AND object_id = cp_prod_stream_id
         AND DAYTIME <= cp_period
         AND NVL(END_DATE, cp_period + 1) > cp_period;

    CURSOR c_ExtractDetail(cp_doc_key         VARCHAR2,
                           cp_line_product_id varchar2) is
      select detail.connection_id, FROM_ID, doc.from_reference_id, to_id
        from dataset_flow_detail_conn detail, dataset_flow_doc_conn doc
       where detail.connection_id = doc.connection_id
         AND doc.to_type = 'CALC_REF_TIN'
         AND doc.to_reference_id = cp_doc_key
         AND DETAIL.MAPPING_TYPE = 'TI_LINE_PROD_EXT'
         and detail.mapping_id = cp_line_product_id;

    CURSOR c_VariableDetail(cp_doc_key         VARCHAR2,
                            cp_line_product_id varchar2) is
      select detail.connection_id, FROM_ID, doc.from_reference_id, to_id
        from dataset_flow_detail_conn detail, dataset_flow_doc_conn doc
       where detail.connection_id = doc.connection_id
         AND doc.to_type = 'CALC_REF_TIN'
         AND doc.to_reference_id = cp_doc_key
         AND DETAIL.MAPPING_TYPE = 'TI_VARIABLE'
         and detail.mapping_id = cp_line_product_id;

    lrec_tilp    RECONCILE_TILP_DIFF%ROWTYPE := ec_RECONCILE_TILP_DIFF.row_by_pk(p_recon_tilp_no);
    lrec_tip     RECONCILE_TIP_DIFF%ROWTYPE := ec_RECONCILE_TIP_DIFF.row_by_pk(lrec_tilp.recon_tip_no);
    lrec_ti      RECONCILE_DOC%ROWTYPE := ec_RECONCILE_DOC.row_by_pk(lrec_tip.Reconciliation_No);
    lrec_summary cont_journal_summary%ROWTYPE;

    lv_end_user_message  VARCHAR2(240) := 'Success!';
    lt_diffs             t_TILP_SRC_DIFF;
    value_added          boolean;
    ln_recon_tilp_src_no number;
    lrec_dfd             DATASET_FLOW_DETAIL%ROWTYPE;

    lt_diffs_sum        t_TILP_DIFF;
    lv2_Query           varchar2(4000);
    lv2_dimension_tag   varchar(4000);
    lv2_transaction_tag varchar(4000);
    cur                 cv_type;
    ln_number           NUMBER;
    lb_found            BOOLEAN;
    ln_id               NUMBER;
    ld_layer_month      DATE;
    p_type              VARCHAR2(32);
  Begin
    DELETE FROM reconcile_tilp_src_diff
     WHERE RECON_TILP_NO = p_recon_tiLP_no;

    lt_diffs := t_tilp_src_diff();

    FOR chk in c_CheckOnValuationMethod(lrec_tip.inventory_id) LOOP
      IF (chk.valuation_method = 'SUMMARY_LINE') or
         (chk.valuation_method = 'SUMMARY_INVENTORY') then
        lv_end_user_message := 'Warning!' || '\n' ||
                               'This operation is not permitted here as the valuation method of Inventory is ' ||
                               chk.valuation_method;
      END IF;
    END LOOP;
    --Handle Variables
    IF ec_reconcile_tip_diff.column_type(ec_reconcile_tilp_diff.recon_tip_no(p_recon_tilP_no)) like
       'QTY_%' THEN
      p_type := 'QUANTITY';
    ELSE
      p_type := 'VALUE';
    END IF;

    FOR I in c_GetLineProdVar(lrec_ti.daytime,
                              lrec_tip.prod_stream_id,
                              lrec_tip.inventory_id,
                              lrec_tilp.line_tag,
                              lrec_tip.product_id,
                              lrec_tip.cost_type,
                              p_type) LOOP

      FOR var in c_VariableDetail(lrec_ti.from_doc, i.id) LOOP
        value_added := false;

        lt_diffs.extend(1);
        lt_diffs(lt_diffs.count).DIRECTION := 'FROM';
        lt_diffs(lt_diffs.count).MAPPING_ID := i.id;
        lt_diffs(lt_diffs.count).MAPPING_TYPE := 'TI_VARIABLE';
        lt_diffs(lt_diffs.count).REFERENCE_ID := var.from_reference_id;
        lt_diffs(lt_diffs.count).REFERENCE_TYPE := 'TI_VARIABLE';
        lt_diffs(lt_diffs.count).DFD_ID := var.FROM_ID;
        lt_diffs(lt_diffs.count).DIFF_TYPE := 'FROM_ONLY';
        lt_diffs(lt_diffs.count).TYPE := i.type;
        --raise_application_error(-20001,var.from_id);
        select sum(value)
          into lt_diffs(lt_diffs.count).VALUE
          from dataset_flow_detail
         where ref_id = var.from_id; /*
                                      lrec_dfd := ec_dataset_flow_detail.row_by_pk(var.from_id);
                                      lt_diffs(lt_diffs.count).VALUE := lrec_dfd.value;*/

      END LOOP;

      FOR var in c_VariableDetail(lrec_ti.to_doc, i.id) LOOP
        value_added := false;

        lt_diffs.extend(1);
        lt_diffs(lt_diffs.count).DIRECTION := 'TO';
        lt_diffs(lt_diffs.count).MAPPING_ID := i.id;
        lt_diffs(lt_diffs.count).MAPPING_TYPE := 'TI_VARIABLE';
        lt_diffs(lt_diffs.count).REFERENCE_ID := var.from_reference_id;
        lt_diffs(lt_diffs.count).REFERENCE_TYPE := 'TI_VARIABLE';
        lt_diffs(lt_diffs.count).DFD_ID := var.FROM_ID;
        lt_diffs(lt_diffs.count).DIFF_TYPE := 'TO_ONLY';
        lt_diffs(lt_diffs.count).TYPE := i.type;
        /*lrec_dfd := ec_dataset_flow_detail.row_by_pk(var.from_id);
        lt_diffs(lt_diffs.count).VALUE := lrec_dfd.value;*/

        select sum(value)
          into lt_diffs(lt_diffs.count).VALUE
          from dataset_flow_detail
         where ref_id = var.from_id;

        FOR x in lt_diffs.first .. lt_diffs.last LOOP
          lt_diffs(X).REFERENCE_ID := 'Product Variable';
          IF lt_diffs(X)
           .DIRECTION = 'FROM' AND lt_diffs(X).MAPPING_ID = i.id AND lt_diffs(X)
             .MAPPING_TYPE = 'TI_VARIABLE' AND lt_diffs(X)
             --.REFERENCE_ID = var.from_reference_id AND lt_diffs(X)
             .REFERENCE_TYPE = 'TI_VARIABLE' AND lt_diffs(X)
             .TYPE = lt_diffs(lt_diffs.count).TYPE AND lt_diffs(X)
             .DIFF_TYPE != 'DIFFERENT' THEN
            --lt_diffs(lt_diffs.count).DIFF_DFD_ID := lt_diffs(lt_diffs.count).DFD_ID;
            lt_diffs(X).DIFF_TYPE := 'DIFFERENT_FROM';
            lt_diffs(lt_diffs.count).DIFF_TYPE := 'DIFFERENT_TO';

            IF lt_diffs(X).VALUE = lt_diffs(lt_diffs.count).VALUE THEN
               lt_diffs(X).DIFF_TYPE := 'SAME';
               lt_diffs(lt_diffs.count).DIFF_TYPE := 'SAME';

            END IF;
          END IF;
        END LOOP;
      END LOOP;

    END LOOP;

    /*    --Handel summaries
        FOR I IN c_SummaryItem(lrec_ti.daytime,
                               lrec_tip.prod_stream_id,
                               lrec_tip.inventory_id) LOOP

          lt_diffs_sum := t_tilp_diff();
          IF i.source_trans_inv_line = 'TRANS_INVENTORY' THEN

            lv2_Query := '    SELECT SUM(NVL(' || lrec_tip.column_type ||
                         ', 0)) VALUE,
                                          DIMENSION_TAG,
                                          KEY ID,
                                          LAYER_MONTH
                                          FROM TRANS_INVENTORY_BALANCE
                                          HAVING CALC_RUN_NO = ' ||
                         lrec_tip.from_doc || '
                                          AND OBJECT_ID = ''' ||
                         i.source_trans_inv_id || '''
                                          AND PROD_STREAM_ID = ''' ||
                         i.source_prod_stream_id || '''
                                          GROUP BY KEY,LAYER_MONTH, PROD_STREAM_ID, OBJECT_ID,CALC_RUN_NO, DIMENSION_TAG';

            -- RAISE_APPLICATION_ERROR(-20001, lv2_Query);
            OPEN cur FOR lv2_Query;
            LOOP
              FETCH cur
                INTO ln_number, lv2_dimension_tag, ln_id, ld_layer_month;
              EXIT WHEN cur%notfound;
              lt_diffs_sum.extend(1);
              lt_diffs_sum(lt_diffs_sum.count).DIMENSION_TAG := lv2_DIMENSION_TAG;
              lt_diffs_sum(lt_diffs_sum.count).TRANSACTION_TAG := NULL;
              lt_diffs_sum(lt_diffs_sum.count).FROM_VALUE := ln_number;
              lt_diffs_sum(lt_diffs_sum.count).HANDLED := false;
              lt_diffs_sum(lt_diffs_sum.count).MONTH := ld_layer_month;
              lt_diffs_sum(lt_diffs_sum.count).ID := ln_id;
            END LOOP;
            CLOSE cur;

            lv2_Query := '    SELECT SUM(NVL(' || lrec_tip.column_type ||
                         ', 0)) VALUE,
                                          DIMENSION_TAG,
                                          KEY ID,
                                          LAYER_MONTH
                                          FROM TRANS_INVENTORY_BALANCE
                                          HAVING CALC_RUN_NO = ''' ||
                         lrec_tip.to_doc || '''
                                          AND OBJECT_ID = ''' ||
                         i.source_trans_inv_id || '''
                                          AND PROD_STREAM_ID = ''' ||
                         i.source_prod_stream_id || '''
                                          GROUP BY KEY,LAYER_MONTH, PROD_STREAM_ID, OBJECT_ID,CALC_RUN_NO, DIMENSION_TAG';

            -- RAISE_APPLICATION_ERROR(-20001, lv2_Query);

            OPEN cur FOR lv2_Query;
            lb_found := false;
            LOOP
              FETCH cur
                INTO ln_number, lv2_dimension_tag, ln_id, ld_layer_month;
              EXIT WHEN cur%notfound;
              for i in lt_diffs_sum.first .. lt_diffs_sum.last loop
                IF lt_diffs_sum(i).DIMENSION_TAG = lv2_dimension_tag AND lt_diffs_sum(i)
                   .MONTH = ld_layer_month THEN
                  lb_found := true;

                  lt_diffs_sum(I).TO_VALUE := ln_number;

                  IF nvl(lt_diffs_sum(I).FROM_VALUE, 0) = nvl(ln_number, 0) then
                    lt_diffs_sum(I).HANDLED := TRUE;
                  else
                    lt_diffs_sum(I).HANDLED := false;
                  END IF;
                  lb_found := false;
                  EXIT;
                END IF;
                lb_found := false;
              END LOOP;
              IF lb_found = FALSE THEN
                lt_diffs_sum.extend(1);
                lt_diffs_sum(lt_diffs_sum.count).DIMENSION_TAG := lv2_DIMENSION_TAG;
                lt_diffs_sum(lt_diffs_sum.count).TRANSACTION_TAG := lv2_TRANSACTION_TAG;
                lt_diffs_sum(lt_diffs_sum.count).TO_VALUE := ln_number;
                lt_diffs_sum(lt_diffs_sum.count).HANDLED := false;
                lt_diffs_sum(lt_diffs_sum.count).MONTH := ld_layer_month;
                lt_diffs_sum(lt_diffs_sum.count).ID := ln_id;
              END IF;
            END LOOP;
            CLOSE cur;
            if nvl(lt_diffs_sum.first, -1) > -1 then
              FOR b in lt_diffs_sum.first .. lt_diffs_sum.last LOOP
                if lt_diffs_sum(b).handled = false then
                  IF NVL(lt_diffs_sum(b).TO_VALUE, 0) != 0 THEN
                    lt_diffs.extend(1);
                    lt_diffs(lt_diffs.count).DIRECTION := 'TO';
                    lt_diffs(lt_diffs.count).MAPPING_ID := I.id;
                    lt_diffs(lt_diffs.count).MAPPING_TYPE := 'TRANS_INV_SUMMARY_ITEM';
                    lt_diffs(lt_diffs.count).REFERENCE_ID := i.id;
                    lt_diffs(lt_diffs.count).REFERENCE_TYPE := 'TRANS_INV_SUMMARY_ITEM';
                    lt_diffs(lt_diffs.count).DFD_ID := lt_diffs_sum(b).ID;
                    --lt_diffs(lt_diffs.count).MONTH := lt_diffs_sum(b).MONTH;
                    IF NVL(lt_diffs_sum(b).FROM_VALUE, 0) = 0 THEN
                      lt_diffs(lt_diffs.count).DIFF_TYPE := 'TO_ONLY';
                    ELSE
                      lt_diffs(lt_diffs.count).DIFF_TYPE := 'DIFFERENT_TO';
                    END IF;
                    lt_diffs(lt_diffs.count).VALUE := NVL(lt_diffs_sum(b)
                                                          .TO_VALUE,
                                                          0);
                  END IF;

                  IF NVL(lt_diffs_sum(b).FROM_VALUE, 0) != 0 THEN
                    lt_diffs.extend(1);
                    lt_diffs(lt_diffs.count).DIRECTION := 'FROM';
                    lt_diffs(lt_diffs.count).MAPPING_ID := I.id;
                    lt_diffs(lt_diffs.count).MAPPING_TYPE := 'TRANS_INV_SUMMARY_ITEM';
                    lt_diffs(lt_diffs.count).REFERENCE_ID := i.id;
                    lt_diffs(lt_diffs.count).REFERENCE_TYPE := 'TRANS_INV_SUMMARY_ITEM';
                    lt_diffs(lt_diffs.count).DFD_ID := lt_diffs_sum(b).ID;
                    IF NVL(lt_diffs_sum(b).TO_VALUE, 0) = 0 THEN
                      lt_diffs(lt_diffs.count).DIFF_TYPE := 'FROM_ONLY';
                    ELSE
                      lt_diffs(lt_diffs.count).DIFF_TYPE := 'DIFFERENT_FROM';
                    END IF;
                    lt_diffs(lt_diffs.count).VALUE := NVL(lt_diffs_sum(b)
                                                          .FROM_VALUE,
                                                          0);
                  END IF;
                END IF;
              END LOOP;
            END IF;

          ELSE

            lv2_Query := '    SELECT SUM(NVL(' || lrec_tip.column_type ||
                         ', 0)) VALUE,
                                          DIMENSION_TAG,
                                          TRANSACTION_TAG,
                                          KEY ID,
                                          LAYER_MONTH
                                          FROM TRANS_INVENTORY_TRANS
                                          HAVING CALC_RUN_NO = ' ||
                         lrec_tip.from_doc || '
                                          AND OBJECT_ID = ''' ||
                         i.source_trans_inv_id || '''
                                          AND PROD_STREAM_ID = ''' ||
                         i.source_prod_stream_id || '''
                                          AND TRANSACTION_TAG = ''' ||
                         i.source_trans_inv_line || '''
                                          GROUP BY KEY,LAYER_MONTH, PROD_STREAM_ID, OBJECT_ID,CALC_RUN_NO, TRANSACTION_TAG, DIMENSION_TAG';

            -- RAISE_APPLICATION_ERROR(-20001, lv2_Query);
            OPEN cur FOR lv2_Query;
            LOOP
              FETCH cur
                INTO ln_number,
                     lv2_dimension_tag,
                     lv2_transaction_tag,
                     ln_id,
                     ld_layer_month;
              EXIT WHEN cur%notfound;
              lt_diffs_sum.extend(1);
              lt_diffs_sum(lt_diffs_sum.count).DIMENSION_TAG := lv2_DIMENSION_TAG;
              lt_diffs_sum(lt_diffs_sum.count).TRANSACTION_TAG := lv2_TRANSACTION_TAG;
              lt_diffs_sum(lt_diffs_sum.count).FROM_VALUE := ln_number;
              lt_diffs_sum(lt_diffs_sum.count).MONTH := ld_layer_month;
              lt_diffs_sum(lt_diffs_sum.count).HANDLED := false;
              lt_diffs_sum(lt_diffs_sum.count).ID := ln_id;
            END LOOP;
            CLOSE cur;

            lv2_Query := '    SELECT SUM(NVL(' || lrec_tip.column_type ||
                         ', 0)) VALUE,
                                          DIMENSION_TAG,
                                          TRANSACTION_TAG,
                                          KEY ID,
                                          LAYER_MONTH
                                          FROM TRANS_INVENTORY_TRANS
                                          HAVING CALC_RUN_NO = ''' ||
                         lrec_tip.to_doc || '''
                                          AND OBJECT_ID = ''' ||
                         i.source_trans_inv_id || '''
                                          AND PROD_STREAM_ID = ''' ||
                         i.source_prod_stream_id || '''
                                          AND TRANSACTION_TAG = ''' ||
                         i.source_trans_inv_line || '''
                                          GROUP BY KEY,LAYER_MONTH, PROD_STREAM_ID, OBJECT_ID,CALC_RUN_NO, TRANSACTION_TAG, DIMENSION_TAG';

            -- RAISE_APPLICATION_ERROR(-20001, lv2_Query);

            OPEN cur FOR lv2_Query;
            lb_found := false;
            LOOP
              FETCH cur
                INTO ln_number,
                     lv2_dimension_tag,
                     lv2_transaction_tag,
                     ln_id,
                     ld_layer_month;
              EXIT WHEN cur%notfound;
              for i in lt_diffs_sum.first .. lt_diffs_sum.last loop
                IF lt_diffs_sum(i).DIMENSION_TAG = lv2_dimension_tag AND lt_diffs_sum(i)
                   .transaction_TAG = lv2_transaction_tag AND lt_diffs_sum(i)
                   .MONTH = ld_layer_month THEN
                  lb_found := true;

                  lt_diffs_sum(I).TO_VALUE := ln_number;

                  IF nvl(lt_diffs_sum(I).FROM_VALUE, 0) = nvl(ln_number, 0) then
                    lt_diffs_sum(I).HANDLED := TRUE;
                  else
                    lt_diffs_sum(I).HANDLED := false;
                  END IF;
                  lb_found := false;
                  EXIT;
                END IF;
                lb_found := false;
              END LOOP;
              IF lb_found = FALSE THEN
                lt_diffs_sum.extend(1);
                lt_diffs_sum(lt_diffs_sum.count).DIMENSION_TAG := lv2_DIMENSION_TAG;
                lt_diffs_sum(lt_diffs_sum.count).TRANSACTION_TAG := lv2_TRANSACTION_TAG;
                lt_diffs_sum(lt_diffs_sum.count).TO_VALUE := ln_number;
                lt_diffs_sum(lt_diffs_sum.count).HANDLED := false;
                lt_diffs_sum(lt_diffs_sum.count).MONTH := ld_layer_month;
                lt_diffs_sum(lt_diffs_sum.count).ID := ln_id;
              END IF;
            END LOOP;
            CLOSE cur;

          END IF;

          if nvl(lt_diffs_sum.first, -1) > -1 then
            FOR b in lt_diffs_sum.first .. lt_diffs_sum.last LOOP
              if lt_diffs_sum(b).handled = false then
                IF NVL(lt_diffs_sum(b).TO_VALUE, 0) != 0 THEN
                  lt_diffs.extend(1);
                  lt_diffs(lt_diffs.count).DIRECTION := 'TO';
                  lt_diffs(lt_diffs.count).MAPPING_ID := I.id;
                  lt_diffs(lt_diffs.count).MAPPING_TYPE := 'TRANS_INV_SUMMARY_ITEM';
                  lt_diffs(lt_diffs.count).REFERENCE_ID := i.id;
                  lt_diffs(lt_diffs.count).REFERENCE_TYPE := 'TRANS_INV_SUMMARY_ITEM';
                  lt_diffs(lt_diffs.count).DFD_ID := lt_diffs_sum(b).ID;
                  IF NVL(lt_diffs_sum(b).FROM_VALUE, 0) = 0 THEN
                    lt_diffs(lt_diffs.count).DIFF_TYPE := 'TO_ONLY';
                  ELSE
                    lt_diffs(lt_diffs.count).DIFF_TYPE := 'DIFFERENT_TO';
                  END IF;
                  lt_diffs(lt_diffs.count).VALUE := NVL(lt_diffs_sum(b).TO_VALUE,
                                                        0);
                END IF;

                IF NVL(lt_diffs_sum(b).FROM_VALUE, 0) != 0 THEN
                  lt_diffs.extend(1);
                  lt_diffs(lt_diffs.count).DIRECTION := 'FROM';
                  lt_diffs(lt_diffs.count).MAPPING_ID := I.id;
                  lt_diffs(lt_diffs.count).MAPPING_TYPE := 'TRANS_INV_SUMMARY_ITEM';
                  lt_diffs(lt_diffs.count).REFERENCE_ID := i.id;
                  lt_diffs(lt_diffs.count).REFERENCE_TYPE := 'TRANS_INV_SUMMARY_ITEM';
                  lt_diffs(lt_diffs.count).DFD_ID := lt_diffs_sum(b).ID;
                  IF NVL(lt_diffs_sum(b).TO_VALUE, 0) = 0 THEN
                    lt_diffs(lt_diffs.count).DIFF_TYPE := 'FROM_ONLY';
                  ELSE
                    lt_diffs(lt_diffs.count).DIFF_TYPE := 'DIFFERENT_FROM';
                  END IF;
                  lt_diffs(lt_diffs.count).VALUE := NVL(lt_diffs_sum(b)
                                                        .FROM_VALUE,
                                                        0);
                END IF;

              END IF;
            END LOOP;
          END IF;
        END LOOP;
    */
    --Handle Extracts
    FOR I IN c_GetLineProduct(lrec_ti.daytime,
                              lrec_tip.prod_stream_id,
                              lrec_tip.inventory_id,
                              lrec_tilp.line_tag,
                              lrec_tip.product_id,
                              lrec_tip.cost_type) LOOP

      FOR prod_line in c_ExtractDetail(lrec_ti.from_doc, i.id) LOOP
        value_added := false;

        lt_diffs.extend(1);
        lt_diffs(lt_diffs.count).DIRECTION := 'FROM';
        lt_diffs(lt_diffs.count).MAPPING_ID := i.id;
        lt_diffs(lt_diffs.count).MAPPING_TYPE := 'TI_LINE_PROD_EXT';
        lt_diffs(lt_diffs.count).REFERENCE_ID := prod_line.from_reference_id;
        lt_diffs(lt_diffs.count).REFERENCE_TYPE := 'CONT_JOURNAL_SUMMARY';
        lt_diffs(lt_diffs.count).DFD_ID := prod_line.FROM_ID;
        lt_diffs(lt_diffs.count).DIFF_TYPE := 'FROM_ONLY';
        SELECT NVL(CREATED_DATE,SYSDATE) INTO lt_diffs(lt_diffs.count).RUN_TIME
        FROM CONT_DOC WHERE DOCUMENT_KEY = prod_line.from_reference_id;

        lrec_summary := ec_cont_journal_summary.row_by_pk(ec_cont_doc.OBJECT_id(prod_line.from_reference_id),
                                                          ec_cont_doc.period(prod_line.from_reference_id),
                                                          prod_line.from_reference_id,
                                                          ec_cont_doc.summary_setup_id(prod_line.from_reference_id),
                                                          prod_line.FROM_ID);

        IF prod_line.to_id = 'QUANTITY' THEN
          IF NVL(lrec_summary.actual_qty_1, 0) != 0 THEN
            lt_diffs(lt_diffs.count).VALUE := lrec_summary.actual_qty_1;
            lt_diffs(lt_diffs.count).TYPE := 'ACTUAL_QTY';
          END IF;

          IF NVL(lrec_summary.qty_adjustment, 0) != 0 THEN

            IF NVL(lrec_summary.actual_qty_1, 0) != 0 THEN
              lt_diffs.extend(1);
              lt_diffs(lt_diffs.count).DIRECTION := 'FROM';
              lt_diffs(lt_diffs.count).MAPPING_ID := i.id;
              lt_diffs(lt_diffs.count).MAPPING_TYPE := 'TI_LINE_PROD_EXT';
              lt_diffs(lt_diffs.count).REFERENCE_ID := prod_line.from_reference_id;
              lt_diffs(lt_diffs.count).REFERENCE_TYPE := 'CONT_JOURNAL_SUMMARY';
              lt_diffs(lt_diffs.count).DFD_ID := prod_line.FROM_ID;
              lt_diffs(lt_diffs.count).DIFF_TYPE := 'FROM_ONLY';
                 SELECT NVL(CREATED_DATE,SYSDATE) INTO lt_diffs(lt_diffs.count).RUN_TIME
                 FROM CONT_DOC WHERE DOCUMENT_KEY = prod_line.from_reference_id;
            ELSE
              lt_diffs(lt_diffs.count).VALUE := lrec_summary.qty_adjustment;
              lt_diffs(lt_diffs.count).TYPE := 'ADJUSTMENT_QTY';
            END IF;

          END IF;

        ELSE
          -- Value
          IF NVL(lrec_summary.actual_amount, 0) != 0 THEN
            lt_diffs(lt_diffs.count).VALUE := lrec_summary.actual_amount;
            lt_diffs(lt_diffs.count).TYPE := 'ACTUAL_AMOUNT';
          END IF;
          IF NVL(lrec_summary.amount_adjustment, 0) != 0 THEN
            IF NVL(lrec_summary.actual_amount, 0) != 0 THEN
              lt_diffs.extend(1);
              lt_diffs(lt_diffs.count).DIRECTION := 'FROM';
              lt_diffs(lt_diffs.count).MAPPING_ID := i.id;
              lt_diffs(lt_diffs.count).MAPPING_TYPE := 'TI_LINE_PROD_EXT';
              lt_diffs(lt_diffs.count).REFERENCE_ID := prod_line.from_reference_id;
              lt_diffs(lt_diffs.count).REFERENCE_TYPE := 'CONT_JOURNAL_SUMMARY';
              lt_diffs(lt_diffs.count).DFD_ID := prod_line.FROM_ID;
              lt_diffs(lt_diffs.count).DIFF_TYPE := 'FROM_ONLY';
              SELECT NVL(CREATED_DATE,SYSDATE) INTO lt_diffs(lt_diffs.count).RUN_TIME
                 FROM CONT_DOC WHERE DOCUMENT_KEY = prod_line.from_reference_id;
            ELSE
              lt_diffs(lt_diffs.count).VALUE := lrec_summary.amount_adjustment;
              lt_diffs(lt_diffs.count).TYPE := 'ADJUSTMENT_AMT';
            END IF;
          END IF;

        END IF;

      END LOOP;
      FOR prod_line in c_ExtractDetail(lrec_ti.to_doc, i.id) LOOP

        lt_diffs.extend(1);
        lt_diffs(lt_diffs.count).DIRECTION := 'TO';
        lt_diffs(lt_diffs.count).MAPPING_ID := i.id;
        lt_diffs(lt_diffs.count).MAPPING_TYPE := 'TI_LINE_PROD_EXT';
        lt_diffs(lt_diffs.count).REFERENCE_ID := prod_line.FROM_reference_id;
        lt_diffs(lt_diffs.count).REFERENCE_TYPE := 'CONT_JOURNAL_SUMMARY';
        lt_diffs(lt_diffs.count).DFD_ID := prod_line.FROM_ID;
        lt_diffs(lt_diffs.count).DIFF_TYPE := 'TO_ONLY';
        SELECT NVL(CREATED_DATE,SYSDATE) INTO lt_diffs(lt_diffs.count).RUN_TIME
                 FROM CONT_DOC WHERE DOCUMENT_KEY = prod_line.from_reference_id;


        lrec_summary := ec_cont_journal_summary.row_by_pk(ec_cont_doc.OBJECT_id(prod_line.from_reference_id),
                                                          ec_cont_doc.period(prod_line.from_reference_id),
                                                          prod_line.from_reference_id,
                                                          ec_cont_doc.summary_setup_id(prod_line.from_reference_id),
                                                          prod_line.FROM_ID);

        IF prod_line.to_id = 'QUANTITY' THEN
          IF NVL(lrec_summary.actual_qty_1, 0) != 0 THEN
            lt_diffs(lt_diffs.count).VALUE := lrec_summary.actual_qty_1;
            lt_diffs(lt_diffs.count).TYPE := 'ACTUAL_QTY';
          END IF;
          IF NVL(lrec_summary.qty_adjustment, 0) != 0 THEN
            IF NVL(lrec_summary.actual_qty_1, 0) != 0 THEN
              lt_diffs.extend(1);
              lt_diffs(lt_diffs.count).DIRECTION := 'TO';
              lt_diffs(lt_diffs.count).MAPPING_ID := i.id;
              lt_diffs(lt_diffs.count).MAPPING_TYPE := 'TI_LINE_PROD_EXT';
              lt_diffs(lt_diffs.count).REFERENCE_ID := prod_line.from_reference_id;
              lt_diffs(lt_diffs.count).REFERENCE_TYPE := 'CONT_JOURNAL_SUMMARY';
              lt_diffs(lt_diffs.count).DFD_ID := prod_line.FROM_ID;
              lt_diffs(lt_diffs.count).DIFF_TYPE := 'TO_ONLY';
                 SELECT NVL(CREATED_DATE,SYSDATE) INTO lt_diffs(lt_diffs.count).RUN_TIME
                 FROM CONT_DOC WHERE DOCUMENT_KEY = prod_line.from_reference_id;
            ELSE
              lt_diffs(lt_diffs.count).VALUE := lrec_summary.qty_adjustment;
              lt_diffs(lt_diffs.count).TYPE := 'ADJUSTMENT_QTY';
            END IF;
          END IF;

        ELSE
          -- Value
          IF NVL(lrec_summary.actual_amount, 0) != 0 THEN
            lt_diffs(lt_diffs.count).VALUE := lrec_summary.actual_amount;
            lt_diffs(lt_diffs.count).TYPE := 'ACTUAL_AMOUNT';
          END IF;
          IF NVL(lrec_summary.amount_adjustment, 0) != 0 THEN
            IF NVL(lrec_summary.actual_amount, 0) != 0 THEN
              lt_diffs.extend(1);
              lt_diffs(lt_diffs.count).DIRECTION := 'TO';
              lt_diffs(lt_diffs.count).MAPPING_ID := i.id;
              lt_diffs(lt_diffs.count).MAPPING_TYPE := 'TI_LINE_PROD_EXT';
              lt_diffs(lt_diffs.count).REFERENCE_ID := prod_line.from_reference_id;
              lt_diffs(lt_diffs.count).REFERENCE_TYPE := 'CONT_JOURNAL_SUMMARY';
              lt_diffs(lt_diffs.count).DFD_ID := prod_line.FROM_ID;
              lt_diffs(lt_diffs.count).DIFF_TYPE := 'TO_ONLY';
                               SELECT NVL(CREATED_DATE,SYSDATE) INTO lt_diffs(lt_diffs.count).RUN_TIME
                 FROM CONT_DOC WHERE DOCUMENT_KEY = prod_line.from_reference_id;
            ELSE
              lt_diffs(lt_diffs.count).VALUE := lrec_summary.amount_adjustment;
              lt_diffs(lt_diffs.count).TYPE := 'ADJUSTMENT_AMT';
            END IF;

          END IF;
        END IF;
        FOR x in lt_diffs.first .. lt_diffs.last LOOP
          IF lt_diffs(X)
           .DIRECTION = 'FROM' AND lt_diffs(X).MAPPING_ID = i.id AND lt_diffs(X)
             .MAPPING_TYPE = 'TI_LINE_PROD_EXT'
             /*AND lt_diffs(X)
                                                                              .REFERENCE_ID != prod_line.from_reference_id*/
             AND lt_diffs(X).REFERENCE_TYPE = 'CONT_JOURNAL_SUMMARY' AND lt_diffs(X)
             .TYPE = lt_diffs(lt_diffs.count).TYPE AND lt_diffs(X)
             .DIFF_TYPE != 'DIFFERENT' THEN
            --lt_diffs(lt_diffs.count).DIFF_DFD_ID := lt_diffs(lt_diffs.count).DFD_ID;
            lt_diffs(X).DIFF_TYPE := 'DIFFERENT';
            lt_diffs(lt_diffs.count).DIFF_TYPE := 'DIFFERENT'; /*
                                                              lt_diffs(lt_diffs.count).DIFF_RECON_TILP_SRC_NO := lt_diffs(X).RECON_TILP_SRC_NO;
                                                              lt_diffs(X).DIFF_RECON_TILP_SRC_NO := lt_diffs(lt_diffs).RECON_TILP_SRC_NO;*/
          END IF;

        END LOOP;

      END LOOP;

    END LOOP;

    if nvl(lt_diffs.first, -1) > -1 then

      FOR i in lt_diffs.first .. lt_diffs.last LOOP
        Ecdp_System_Key.assignNextNumber('RECONCILE_TILP_SRC_DIFF',
                                         ln_recon_tilp_src_no);
        IF lt_diffs(i).DIFF_TYPE != 'SAME' THEN
            insert into reconcile_tilp_src_diff
              (RECONCILIATION_NO,
               RECON_TIP_NO,
               RECON_TIlP_NO,
               RECON_TILP_SRC_NO,
               DIRECTION,
               DIFF_TYPE,
               REFERENCE_ID,
               REFERENCE_TYPE,
               DFD_ID,
               VALUE,
               TYPE,
               MAPPING_TYPE,
               MAPPING_ID,
               RUN_TIME,
               CREATED_BY,
               CREATED_DATE)
            VALUEs
              (lrec_tip.Reconciliation_No,
               lrec_tip.recon_tip_no,
               lrec_tilp.recon_tilp_no,
               ln_recon_tilp_src_no,
               lt_diffs                  (i).direction,
               lt_diffs                  (i).diff_type,
               lt_diffs                  (i).reference_id,
               lt_diffs                  (i).reference_type,
               lt_diffs                  (i).dfd_id,
               lt_diffs                  (i).value,
               lt_diffs                  (i).type,
               lt_diffs                  (i).mapping_type,
               lt_diffs                  (i).mapping_id,
               lt_diffs                  (i).run_time,
               ecdp_context.getAppUser,
               sysdate);
          END IF;
      END LOOP;
    END IF;
    RETURN lv_end_user_message;
  END;

  FUNCTION GetRoyParams(p_type VARCHAR2, p_dsf_detail_id VARCHAR2)
    RETURN VARCHAR2 IS
  BEGIN
    --EC_CONT_JOURNAL_ENTRY.class_map_params(from_id)
    RETURN NULL;
  END;

  FUNCTION GetVariance(p_search_param VARCHAR2,
                       p_search_val   VARCHAR2,
                       p_table_name   VARCHAR2) return VARCHAR2 is

    lv2_Variance VARCHAR2(32);
    sql_stmt     varchar2(200);
  BEGIN
    sql_stmt := 'SELECT (FROM_NUMBER-TO_NUMBER) from ' || p_table_name ||
                ' t where t.' || p_search_param || ' = ' || p_search_val;
    execute immediate sql_stmt
      into lv2_Variance;
    RETURN lv2_Variance;
  END;


  -----------------------------------------------------------------------------------
FUNCTION accrual_ind(
         p_document_key VARCHAR2)
RETURN CALC_REFERENCE.ACCRUAL_IND%TYPE  IS
   v_return_val CONT_DOC.ACCRUAL_IND%TYPE ;
   CURSOR c_col_val IS
   SELECT accrual_ind col
   FROM CALC_REFERENCE
WHERE RUN_NO = p_document_key;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END accrual_ind;



-----------------------------------------------------------------------------------
FUNCTION summary_setup_id(
         p_dataset VARCHAR2)
RETURN varchar2  IS
   v_summary_set_up_id varchar2(32);
   CURSOR c_col_val IS
   SELECT object_id col
   FROM summary_setup
WHERE object_code = p_dataset;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_summary_set_up_id := cur_row.col;
   END LOOP;
   RETURN v_summary_set_up_id;
END summary_setup_id;
--------------------------------------------------------------------------------------------------
FUNCTION IsSummary(p_inventory_id VARCHAR2)

RETURN VARCHAR2 IS
lv_valuation_method       VARCHAR2(100);

BEGIN
  ecdp_dynsql.WriteTempText('Deepika',p_inventory_id);
   SELECT VALUATION_METHOD INTO lv_valuation_method
        FROM OV_TRANS_INVENTORY v
       WHERE v.object_id = p_inventory_id;
  IF lv_valuation_method IN ('SUMMARY_LINE','SUMMARY_INVENTORY')THEN
    RETURN 'Y';
    ELSE
      RETURN 'N';
    END IF;

END IsSummary;

End ecdp_reconciliation;