CREATE OR REPLACE PACKAGE BODY EcDp_RR_Revn_Mapping IS
/****************************************************************
** Package        :  EcDp_RR_Revn_Mapping, body part
*****************************************************************/

TYPE type_cursor IS REF CURSOR;

    FUNCTION GetMissingItems(
         p_object_codes                    T_TABLE_VARCHAR2
        ,p_journal_mapping_id              cost_mapping.object_id%TYPE
        ,p_journal_mapping_daytime         cost_mapping_version.daytime%TYPE
        ,p_source_mapping_type             cost_mapping_src_setup.src_type%TYPE
        )
    RETURN VARCHAR2
    IS
        lo_source_mappings T_TABLE_MAPPING_SOURCE_SETUP;

        cursor c_objects(p_src_code varchar2, p_daytime DATE, p_type VARCHAR2) is
        SELECT COUNT(*) counting FROM
               cost_mapping_src_setup cm,
               cost_mapping_version cmv
        where cm.object_id = p_journal_mapping_id
         and cm.object_type = nvl(p_type,cm.object_type )
         and cm.src_code = nvl(p_src_code,cm.src_code)
         and cm.src_type = p_source_mapping_type
         and cm.daytime <= p_daytime
         and nvl(cmv.end_date,p_daytime+1) > p_daytime
         and cm.object_id = cmv.object_id
         --and cm.group_no = p_group_no_to_check
         ;

       cursor c_objects_list(p_src_code varchar2, p_daytime DATE ) is
       SELECT COUNT(*) counting FROM
               cost_mapping_src_setup cm,
               cost_mapping_version cmv,
               object_list_setup ols
        where cm.object_id = p_journal_mapping_id
         and cm.object_type = nvl('OBJECT_LIST',cm.object_type )
         --and cm.src_code = nvl(p_src_code,cm.src_code)
         and cm.src_type = p_source_mapping_type
         and cm.daytime <= p_daytime
         and ols.generic_object_code = p_src_code
         and ols.object_id = ec_object_list.object_id_by_uk(cm.src_code)
         and nvl(cmv.end_date,p_daytime+1) > p_daytime
         and cm.object_id = cmv.object_id
         --and cm.group_no = p_group_no_to_check
         ;

        lv2_finding VARCHAR2(32);
        ln_count    NUMBER;
        lv2_missing_list VARCHAR2(4000);
        lb_skip          boolean;
        lb_add           boolean;
    BEGIN

        -- Check that there is actually any filtering for the type

        FOR obj in c_objects(NULL,p_journal_mapping_daytime,null) LOOP
          ln_count := obj.counting;
        END LOOP;



        if ln_count >0 then

          FOR idx IN p_object_codes.FIRST  .. p_object_codes.LAST LOOP
              -- Check if object has direct mapping
              ln_count:= 0;
              lb_skip := false;
              lb_add := false;

              FOR obj in c_objects(p_object_codes(idx),p_journal_mapping_daytime,'OBJECT') LOOP
                -- see if the object  is directly connected
                IF obj.COUNTING > 0 THEN
                   lb_skip := true;
                END IF;

              END LOOP;

              if lb_skip = false then --object is directLY connected
                  -- Check if other object has direct mapping
                  FOR obj in c_objects(null,p_journal_mapping_daytime,'OBJECT') LOOP
                    IF obj.counting > 0 then
                       lb_add := true;
                    end if;
                  END LOOP;

                   if lb_skip = false and lb_add = false then

                          -- check if there are any item is in an object list
                          FOR obj in c_objects_list(p_object_codes(idx),p_journal_mapping_daytime) LOOP
                            ln_count := obj.counting;
                          END LOOP;


                      IF ln_count = 0 THEN
                        -- if not found add to the list
                        lb_add := true;
                     END IF;
                  END IF;

                  if lb_add = true then
                        IF lv2_missing_list IS NULL THEN
                           lv2_missing_list := p_object_codes(idx);
                        ELSE

                           lv2_missing_list := lv2_missing_list || ','||p_object_codes(idx);
                        END IF;
                     END IF;

              end if;
           END LOOP;

        ELSE
           FOR idx IN p_object_codes.FIRST  .. p_object_codes.LAST LOOP
             IF idx != 1 THEN
               lv2_missing_list:= lv2_missing_list || ',';
             END IF;
             lv2_missing_list := lv2_missing_list ||p_object_codes(idx);
           END LOOP;
        END IF;


        RETURN lv2_missing_list;

RETURN      p_source_mapping_type;

    END GetMissingItems;


    -----------------------------------------------------------------------
    --------+----------------------------------+---------------------------
    PROCEDURE DecodeJournalMappingSrcTypeStr(
             p_str                             prosty_codes.alt_code%TYPE
            ,p_value_category                  OUT VARCHAR2
            ,p_value_type_name                 OUT VARCHAR2
            ,p_journal_entry_attribute         OUT VARCHAR2
            )
    IS
        ln_val_category_seperator_idx NUMBER;
        ln_je_att_seperator_idx NUMBER;
    BEGIN
        ln_val_category_seperator_idx := INSTRC(p_str, ':', 1, 1);
        ln_je_att_seperator_idx := INSTRC(p_str, ';', ln_val_category_seperator_idx, 1);

        IF ln_val_category_seperator_idx <> 0 AND ln_je_att_seperator_idx <> 0
        THEN
            p_value_category := SUBSTR(p_str, 1, ln_val_category_seperator_idx - 1);
            p_value_type_name := SUBSTR(p_str, ln_val_category_seperator_idx + 1, ln_je_att_seperator_idx - ln_val_category_seperator_idx - 1);
            p_journal_entry_attribute := SUBSTR(p_str, ln_je_att_seperator_idx + 1, LENGTH(p_str) - ln_je_att_seperator_idx);
        END IF;
    END DecodeJournalMappingSrcTypeStr;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : RunCostMapping
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE RunCostMapping(p_dataset VARCHAR2,
                         p_daytime DATE,
                         p_user    VARCHAR2)
--</EC-DOC>

IS


cursor c_obj is
select cmv.*
  from cost_mapping cm, cost_mapping_version cmv
 where cmv.trg_dataset = p_dataset
   and cm.object_id = cmv.object_id
   and cmv.daytime >= cm.start_date
   and p_daytime < nvl(cmv.end_date, p_daytime + 1)
   and cmv.daytime = (select max(daytime)
                        from cost_mapping_version vd
                       where vd.object_id = cm.object_id
                         and vd.daytime <= p_daytime);


cursor c_journal(cp_company_code varchar2,
                 cp_daytime date,
                 cp_contract_code varchar2,
                 cp_dataset varchar2,
                 cp_debit_credit_code varchar2,
                 cp_document_type varchar2,
                 cp_fin_account_code varchar2,
                 cp_fin_revenue_order_code varchar2,
                 cp_fin_wbs_code varchar2) is
select j.*
  from cont_journal_entry j
 where
-- Company
 nvl(j.company_code, 'NA') = nvl(cp_company_code, 'NA')
-- Daytime
 and j.daytime = cp_daytime
-- Contract
 and nvl(j.contract_code, 'NA') = nvl(cp_contract_code, 'NA')
-- Dataset
 and j.dataset = cp_dataset
-- Debit/credit
 and nvl(j.debit_credit_code, 'NA') = nvl(cp_debit_credit_code, 'NA')
-- Document Type
 and nvl(j.document_type, 'NA') = nvl(cp_document_type, 'NA')
-- Account
 and j.fin_account_code like cp_fin_account_code
-- WBS account
 and j.fin_wbs_code like cp_fin_wbs_code
-- Rvenue order
 and NVL(j.fin_revenue_order_code, 'NA') = nvl(cp_fin_revenue_order_code, 'NA');


cursor c_prec_doc is
select d.document_key, d.record_status
  from cont_doc d
 where d.daytime = p_daytime
   and d.dataset = p_dataset
   and d.created_date = (select max(ds.created_date)
                         from cont_doc ds
                        where ds.daytime = d.daytime
                          and ds.dataset = d.dataset);

lv2_document_key cont_doc.document_key%type;
lv2_newdoc_key cont_doc.document_key%type;
lv2_company_code company.object_code%type;
lv2_src_contract_code contract.object_code%type;
lv2_trg_contract_code contract.object_code%type;
lv2_trg_fin_cost_center_code fin_cost_center.object_code%type;
lv2_src_fin_revenue_order_code fin_revenue_order.object_code%type;
lv2_trg_fin_revenue_order_code fin_revenue_order.object_code%type;
lv2_trg_fin_account_code fin_account.object_code%type;
lv2_trg_fin_wbs_code fin_wbs.object_code%type;
lrec_d cont_doc%rowtype;
lrec_je cont_journal_entry%rowtype;
prec_doc_not_approved EXCEPTION;



BEGIN




FOR pd IN c_prec_doc LOOP
    lv2_document_key := pd.document_key;

    IF (nvl(pd.Record_Status,'X') != 'A' OR nvl(pd.Record_Status,'X') != 'V') THEN
        RAISE prec_doc_not_approved;
    END IF;



END LOOP;

lrec_d.daytime := p_daytime;
lrec_d.dataset := p_dataset;
lrec_d.preceding_document_key := lv2_document_key;
lrec_d.document_type := 'COST_DATASET';
lrec_d.created_by := p_user;
--lrec_d.booking_period := TO_CHAR(ecdp_fin_period.getCurrentOpenPeriod(lv2_country_id, lv2_company_id, 'JOU_ENT', 'REPORTING'), 'YYYY'),


lv2_newdoc_key := ecdp_rr_revn_common.CreateDocument(lrec_d, 'CONT_MAPPING_DOC');


-- Loop map objects
FOR o IN c_obj LOOP


    lv2_company_code := ec_company.object_code(o.company_id);
    lv2_src_contract_code := ec_contract.object_code(o.src_contract_id);
    lv2_trg_contract_code := ec_contract.object_code(o.trg_contract_id);
    lv2_trg_fin_cost_center_code := ec_fin_cost_center.object_code(o.trg_fin_cost_center_id);
    lv2_src_fin_revenue_order_code := ec_fin_revenue_order.object_code(o.src_fin_revenue_order_id);
    lv2_trg_fin_revenue_order_code := ec_fin_revenue_order.object_code(o.trg_fin_revenue_order_id);
    lv2_trg_fin_account_code := ec_fin_account.object_code(o.trg_fin_account_id);
    lv2_trg_fin_wbs_code := ec_fin_wbs.object_code(o.trg_fin_wbs_id);

    -- Loop journal records
    FOR j IN c_journal(lv2_company_code,
                       p_daytime,
                       lv2_src_contract_code,
                       o.src_dataset,
                       o.src_debit_credit_code,
                       o.src_document_type,
                       o.src_fin_account_code,
                       lv2_src_fin_revenue_order_code,
                       o.src_fin_wbs_code)
                       LOOP

             lrec_je.Document_Type              := 'COST_DATASET';
             lrec_je.company_code               := lv2_company_code;
             lrec_je.document_key               := lv2_newdoc_key;
             lrec_je.fiscal_year                := j.fiscal_year;
             lrec_je.daytime                    := p_daytime;
             lrec_je.period                     := j.period;
             lrec_je.contract_code              := lv2_trg_contract_code;
             lrec_je.dataset                    := o.trg_dataset;
             lrec_je.posting_key                := o.posting_key;
             lrec_je.account_type               := j.account_type;
             lrec_je.debit_credit_code          := o.trg_debit_credit_code;
             lrec_je.tax_code                   := j.tax_code;
             lrec_je.amount                     := Adjust('PCT',j.amount,o.mapping_factor);
             lrec_je.tax_amount                 := Adjust('PCT',j.tax_amount,o.mapping_factor);
             lrec_je.qty_1                      := Adjust('PCT',j.qty_1,o.mapping_factor);
             lrec_je.uom1_code                  := j.uom1_code;
             lrec_je.document_type              := o.src_document_type;
             lrec_je.fin_account_code           := lv2_trg_fin_account_code;
             lrec_je.fin_cost_center_code       := lv2_trg_fin_cost_center_code;
             lrec_je.fin_revenue_order_code     := lv2_trg_fin_revenue_order_code;
             lrec_je.fin_wbs_code               := lv2_trg_fin_wbs_code;
             lrec_je.joint_venture              := j.joint_venture;
             lrec_je.comments                   := j.comments;


             CreateJournalEntry(lrec_je);




    END LOOP;


END LOOP;

EXCEPTION
  WHEN prec_doc_not_approved THEN
     RAISE_APPLICATION_ERROR(-20000, 'Can not create dataset.\n\nPreceding Data Extract (' || lv2_document_key || ') for the same month has not been approved.');

--DBMS_LOCK.sleep(seconds => 10.00);



END RunCostMapping;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : SetCostMappingAccountID
-- Description    :
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
PROCEDURE SetCostMappingAccountID(p_object_id   VARCHAR2,
                                 p_daytime     DATE)


--</EC-DOC>

IS

BEGIN

update cost_mapping_version m
   set m.src_fin_account_id = ec_fin_account.object_id_by_uk(m.src_fin_account_code)
 where m.object_id = p_object_id
   and m.daytime = p_daytime;


END SetCostMappingAccountID;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : CreateDocument
-- Description    :
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
FUNCTION CreateDocument(p_dataset   VARCHAR2,
                        p_contract_area_id varchar2,
                        p_object_id VARCHAR2,
                        p_period    DATE,
                        p_accrual   VARCHAR2,
                        p_user      VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
IS

lv2_document_type VARCHAR2(32) := 'COST_DATASET';
lv2_document_key VARCHAR2(32);
lrec_d cont_doc%ROWTYPE;

cursor c_prec_doc is
select d.document_key, d.record_status, d.accrual_ind
  from cont_doc d
 where d.period = p_period
   and d.dataset = p_dataset
   and nvl(contract_id,'x') = nvl(p_object_id,'x')
   and object_id = p_contract_area_id
   and d.created_date = (select max(ds.created_date)
                         from cont_doc ds
                        where ds.period = d.period
                           and nvl(ds.object_id,'X') =  nvl(d.object_id,'X')
                           and nvl(ds.contract_id,'X') =  nvl(d.contract_id,'X')
                          and ds.dataset = d.dataset);

prec_doc_not_approved EXCEPTION;

prec_doc_is_final EXCEPTION;

BEGIN

FOR pd IN c_prec_doc LOOP
    lv2_document_key := pd.document_key;

    IF (nvl(pd.Record_Status,'X') != 'A' AND nvl(pd.Record_Status,'X') != 'V') THEN
        RAISE prec_doc_not_approved;
    END IF;

    IF (nvl(pd.accrual_ind,'N') != 'Y' AND nvl(p_accrual,'N') = 'Y' ) THEN
        RAISE prec_doc_is_final;
    END IF;

END LOOP;

lrec_d.daytime := trunc(Ecdp_Timestamp.getCurrentSysdate);
lrec_d.period := p_period;
lrec_d.object_id := p_contract_area_id;
lrec_d.contract_id := p_object_id;
lrec_d.dataset := p_dataset;
lrec_d.accrual_ind := replace(p_accrual,'N/A','N');
lrec_d.preceding_document_key :=  lv2_document_key;
lrec_d.document_type := lv2_document_type;
lrec_d.created_by := p_user;


RETURN ecdp_rr_revn_common.CreateDocument(lrec_d, 'CONT_MAPPING_DOC');




EXCEPTION
  WHEN prec_doc_not_approved THEN
     RAISE_APPLICATION_ERROR(-20000, 'Can not create dataset.Preceding Data Mapping document (' || lv2_document_key || ') for the same month has not been approved/verified.');

  WHEN prec_doc_is_final THEN
     RAISE_APPLICATION_ERROR(-20000, 'Can not create an Accrual with a Final preceding document.Preceding Data Mapping document (' || lv2_document_key || ') is final.');


END CreateDocument;




--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : SetCostMappingWBSID
-- Description    :
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
PROCEDURE SetCostMappingWBSID(p_object_id   VARCHAR2,
                              p_daytime     DATE)


--</EC-DOC>

IS

BEGIN

update cost_mapping_version m
   set m.src_fin_wbs_id = ec_fin_wbs.object_id_by_uk(m.src_fin_wbs_code)
 where m.object_id = p_object_id
   and m.daytime = p_daytime;


END SetCostMappingWBSID;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : RunCostMapping
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE CreateJournalEntry(p_rec_journal_entry cont_journal_entry%ROWTYPE)
--</EC-DOC>
IS

BEGIN

insert into cont_journal_entry values p_rec_journal_entry;

END CreateJournalEntry;

PROCEDURE CreateJournalEntry(p_rec_journal_entry_excl cont_journal_entry_excl%ROWTYPE)
--</EC-DOC>
IS

BEGIN

insert into cont_journal_entry_excl values p_rec_journal_entry_excl;

END CreateJournalEntry;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : ReverseJournalEntries
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE ReverseJournalEntries(p_document_key VARCHAR2,
                                p_dataset      VARCHAR2,
                                p_user_id      VARCHAR2)
--</EC-DOC>
IS
    lv2_prec_documnet_key cont_doc.preceding_document_key%TYPE;
    lrec_je_cont cont_journal_entry%ROWTYPE;
    ld_reversal_date DATE;
	lv2_only_manual VARCHAR2(32);

    CURSOR c_doc_je_cont(cp_document_key VARCHAR2, cp_dataset VARCHAR2,cp_manual VARCHAR2) IS
    SELECT *
      FROM cont_journal_entry e
     WHERE e.document_key = cp_document_key
       AND e.dataset = cp_dataset
       AND e.reversal_date IS NULL
	   AND (NVL(MANUAL_IND,'N') = 'Y'
	   OR  cp_manual = 'N');

BEGIN

    lv2_prec_documnet_key := ec_cont_doc.preceding_document_key(p_document_key);
    ld_reversal_date := trunc(Ecdp_Timestamp.getCurrentSysdate,'DD');
    lv2_only_manual := NVL(ec_ctrl_system_attribute.attribute_text(ec_cont_doc.period(p_document_key), 'JOURNAL_MAP_NO_REVERSALS', '<='),'N');
    FOR journal_entry IN c_doc_je_cont(lv2_prec_documnet_key, p_dataset, lv2_only_manual)
    LOOP
        lrec_je_cont := journal_entry;
        lrec_je_cont.journal_entry_no := null;
        lrec_je_cont.document_key := p_document_key;
        lrec_je_cont.amount := (-1)*nvl(journal_entry.amount,0);
        lrec_je_cont.tax_amount := (-1)*nvl(journal_entry.tax_amount,0);
        lrec_je_cont.qty_1 := (-1)*nvl(journal_entry.qty_1,0);
        lrec_je_cont.created_by := p_user_id;
        lrec_je_cont.reversal_date := ld_reversal_date;
        lrec_je_cont.record_status := 'P' ;     -- The carried forward record should be provisional and hence editable.

        CreateJournalEntry(lrec_je_cont);

        -- This will copy the manual journals where carry_forward = 'Y' to new doc
        IF lrec_je_cont.Manual_Ind = 'Y' AND lrec_je_cont.carry_forward = 'Y' THEN

           lrec_je_cont.amount := journal_entry.amount;
           lrec_je_cont.tax_amount := journal_entry.tax_amount;
           lrec_je_cont.qty_1 := journal_entry.qty_1;
           lrec_je_cont.reversal_date := NULL ;


           CreateJournalEntry(lrec_je_cont);

        END IF ;

    END LOOP;

END ReverseJournalEntries;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : Adjust
-- Description    : Applies adjustments to the passed number based on misc rules.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION Adjust(p_type VARCHAR2, p_value NUMBER, p_adj NUMBER)
  RETURN NUMBER

 IS

  ln_result NUMBER;

BEGIN

  IF nvl(p_type,'NA') = 'PCT' THEN
    ln_result := nvl(p_value, 0) * nvl(p_adj, 1);

  ELSE
    ln_result := p_value;
  END IF;

  RETURN ln_result;

END Adjust;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : SetDatasetRecordStatus
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE SetDatasetRecordStatus(p_document_key  VARCHAR2,
                                 p_record_status VARCHAR2,
                                 p_user          VARCHAR2,
								 p_accrual_ind   VARCHAR2)
IS

ld_curr_open_period DATE;
lr_cont_doc cont_doc%ROWTYPE := ec_cont_doc.row_by_pk(p_document_key);
closed_period EXCEPTION;
doc_dependency EXCEPTION;
Wrong_screen   EXCEPTION;
lv2_dep_doc_key VARCHAR2(32);
lv2_accrual_ind cont_doc.accrual_ind%type :=EC_CONT_DOC.accrual_ind(p_document_key);



    CURSOR c_dep(cp_document_key VARCHAR2) IS
    SELECT cd.document_key
      FROM cont_doc cd
     WHERE cd.preceding_document_key = cp_document_key;

     lv_msg varchar2(2000);
BEGIN

 lv_msg := ecdp_dataset_flow.UpdateDocFlowStatus('CONT_JOURNAL_ENTRY',
                                                 p_document_key,
                                                 p_record_status,
                                                 p_user,
                                                 true);



IF lv_msg is null then
IF p_record_status = 'P' THEN

     -- Check dependencies
     FOR rsD IN c_dep(p_document_key) LOOP
       lv2_dep_doc_key := rsD.document_key;
     END LOOP;

     IF lv2_dep_doc_key IS NOT NULL THEN
       RAISE doc_dependency;
     END IF;

	--Checking verification from correct screen
     if p_accrual_ind <> lv2_accrual_ind and p_accrual_ind<>'B'  then
        RAISE Wrong_screen;
      END IF;

  -- Check reporting period
  -- If the document was approved in a reporting period that is now closed, it can not be unapproved.
  ld_curr_open_period := ecdp_rr_revn_common.GetCurrentReportingPeriod(lr_cont_doc.object_id, lr_cont_doc.daytime);

    IF lr_cont_doc.reporting_period < ld_curr_open_period THEN
      RAISE closed_period;
    END IF;

  END IF;

  --Checking verification done from correct screen
      IF p_record_status = 'V' THEN
        if p_accrual_ind <> lv2_accrual_ind and p_accrual_ind<>'B' then
          RAISE Wrong_screen;
        END IF;
      end if;

   -- Set record status on document and journal entry
  ecdp_rr_revn_common.SetRecordStatusOnDocument(p_document_key, p_record_status, p_user, 'CONT_MAPPING_DOC');
  ecdp_rr_revn_common.SetRecordStatusOnJournalEntry(p_document_key, p_record_status, p_user);

END IF;

EXCEPTION
 WHEN doc_dependency THEN
       RAISE_APPLICATION_ERROR(-20000, 'Can not unapprove mapping document ' || p_document_key || ' because it has a dependent document (' || lv2_dep_doc_key || ')');

 WHEN closed_period THEN
       RAISE_APPLICATION_ERROR(-20000, 'Can not unapprove mapping document ' || p_document_key || ' because it was approved in a reporting period that is now closed (' || lr_cont_doc.reporting_period || ').');

 WHEN Wrong_screen THEN
      RAISE_APPLICATION_ERROR(-20000,CASE lv2_accrual_ind when 'Y' then 'Accrual document' else 'Final document' end || ' cannot be Verified / Un-verified from ' || CASE lv2_accrual_ind when 'Y' then 'Final screen' else 'Accrual screen' end);

END SetDatasetRecordStatus;



PROCEDURE AlignJournalEntryDataset(p_document_key VARCHAR2)
IS
    lv2_dataset VARCHAR2(32);

BEGIN
    lv2_dataset := ec_cont_doc.dataset(p_document_key);

    UPDATE cont_journal_entry
    SET dataset = lv2_dataset
    WHERE document_key = p_document_key;

END AlignJournalEntryDataset;



PROCEDURE AddNewSourceMapping(
          p_cost_map_id VARCHAR2,
          p_period DATE,
          p_je_no NUMBER)
IS

  CURSOR c_max(cp_cost_map_id VARCHAR2, cp_period DATE) IS
    SELECT MAX(ss.group_no) max_group_no
      FROM cost_mapping_src_setup ss
     WHERE ss.object_id = cp_cost_map_id
       AND ss.daytime <= cp_period; -- TODO: Date Clause..?

  CURSOR c_src(cp_cost_map_id VARCHAR2,
               cp_period      DATE,
               cp_dataset     VARCHAR2,
               cp_exp_type    VARCHAR2,
               cp_fin_account VARCHAR2,
               cp_fin_wbs     VARCHAR2,
               cp_doc_type    VARCHAR2,
               cp_contract    VARCHAR2) IS
    SELECT *
      FROM cost_mapping_src_setup cms
     WHERE cms.object_id = cp_cost_map_id
       AND cms.daytime = cp_period
       AND (
           (cms.src_type = 'DATASET'          AND cms.src_code = NVL(cp_dataset, 'XX'))
        OR (cms.src_type = 'EXPENDITURE_TYPE' AND cms.src_code = NVL(cp_exp_type, 'XX'))
        OR (cms.src_type = 'FIN_ACCOUNT'      AND cms.src_code = NVL(cp_fin_account, 'XX'))
        OR (cms.src_type = 'FIN_WBS'          AND cms.src_code = NVL(cp_fin_wbs, 'XX'))
        OR (cms.src_type = 'DOCUMENT_TYPE'    AND cms.src_code = NVL(cp_doc_type, 'XX'))
        OR (cms.src_type = 'CONTRACT'         AND cms.src_code = NVL(cp_contract, 'XX'))
           )
      ORDER BY cms.group_no, cms.src_type;

  lrec_je cont_journal_entry%ROWTYPE := ec_cont_journal_entry.row_by_pk(p_je_no);
  lrec_ref_je cont_journal_entry%ROWTYPE := ec_cont_journal_entry.row_by_pk(lrec_je.ref_journal_entry_no);
  ln_next_group_no NUMBER := 1; -- Default to 1 if no existing rows
  lv2_user VARCHAR2(32) := ecdp_context.getAppUser;
  ld_daytime DATE := ec_cost_mapping.start_date(p_cost_map_id);
  ld_sysdate DATE := Ecdp_Timestamp.getCurrentSysdate;
  lb_found BOOLEAN := FALSE;
  lb_found_ds BOOLEAN := FALSE;
  lb_found_et BOOLEAN := FALSE;
  lb_found_fa BOOLEAN := FALSE;
  lb_found_fw BOOLEAN := FALSE;
  lb_found_dt BOOLEAN := FALSE;
  lb_found_co BOOLEAN := FALSE;
  ln_group_no NUMBER := NULL;

  cost_map_id_not_provided EXCEPTION;

BEGIN

  IF p_cost_map_id IS NULL THEN
    RAISE cost_map_id_not_provided;
  END IF;

--EcDp_DynSql.WriteTempText('ROSNEDAG', 'START JE: ' || p_je_no);

/*EcDp_DynSql.WriteTempText('ROSNEDAG', 'cursor: ' ||
               p_cost_map_id || ', ' ||
               p_period  || ', ' ||
               lrec_ref_je.dataset  || ', ' ||
               lrec_je.expenditure_type  || ', ' ||
               lrec_je.fin_account_code  || ', ' ||
               lrec_je.fin_wbs_code || ', ' ||
               lrec_je.document_type || ', ' ||
               lrec_je.contract_code);*/

--  RAISE_APPLICATION_ERROR(-20000, 'Inside AddNewSourceMapping with ' || p_cost_map_id || ' - ' || p_period || ' - ' || p_je_no);


  -- Validate that the same source mapping group does not already exist.
  -- Not neccessary with more than one source mapping covering this record.

  lb_found := FALSE;

  FOR rsS IN c_src(p_cost_map_id,
               p_period,
               lrec_ref_je.dataset,
               lrec_je.expenditure_type,
               lrec_je.fin_account_code,
               lrec_je.fin_wbs_code,
               lrec_je.document_type,
               lrec_je.contract_code) LOOP

    -- Set group number
    IF ln_group_no IS NULL THEN
       ln_group_no := rsS.Group_No;

    ELSIF ln_group_no != rsS.Group_No THEN

      -- Group number changed. Reset indicators.
      lb_found_ds := FALSE;
      lb_found_et := FALSE;
      lb_found_fa := FALSE;
      lb_found_fw := FALSE;
      lb_found_dt := FALSE;
      lb_found_co := FALSE;

      ln_group_no := rsS.Group_No;

    END IF;

--    EcDp_DynSql.WriteTempText('ROSNEDAG', 'Group no: ' || rsS.Group_No);

    IF rsS.Src_Type = 'DATASET' AND rsS.Group_No = ln_group_no THEN
       lb_found_ds := TRUE;

    ELSIF rsS.Src_Type = 'EXPENDITURE_TYPE' AND rsS.Group_No = ln_group_no THEN
       lb_found_et := TRUE;

    ELSIF rsS.Src_Type = 'FIN_ACCOUNT' AND rsS.Group_No = ln_group_no THEN
       lb_found_fa := TRUE;

    ELSIF rsS.Src_Type = 'FIN_WBS' AND rsS.Group_No = ln_group_no THEN
       lb_found_fw := TRUE;

    ELSIF rsS.Src_Type = 'DOCUMENT_TYPE' AND rsS.Group_No = ln_group_no THEN
       lb_found_dt := TRUE;

    ELSIF rsS.Src_Type = 'CONTRACT' AND rsS.Group_No = ln_group_no THEN
       lb_found_co := TRUE;
    END IF;

  END LOOP;

  -- Check if journal entry had a corresponding mapping already
  IF ((lrec_ref_je.dataset      IS NOT NULL AND lb_found_ds) OR (lrec_ref_je.dataset      IS NULL AND NOT lb_found_ds)) AND
     ((lrec_je.expenditure_type IS NOT NULL AND lb_found_et) OR (lrec_je.expenditure_type IS NULL AND NOT lb_found_et)) AND
     ((lrec_je.fin_account_code IS NOT NULL AND lb_found_fa) OR (lrec_je.fin_account_code IS NULL AND NOT lb_found_fa)) AND
     ((lrec_je.fin_wbs_code     IS NOT NULL AND lb_found_fw) OR (lrec_je.fin_wbs_code     IS NULL AND NOT lb_found_fw)) AND
     ((lrec_je.document_type    IS NOT NULL AND lb_found_dt) OR (lrec_je.document_type    IS NULL AND NOT lb_found_dt)) AND
     ((lrec_je.contract_code    IS NOT NULL AND lb_found_co) OR (lrec_je.contract_code    IS NULL AND NOT lb_found_co)) THEN

    lb_found := TRUE;
--    EcDp_DynSql.WriteTempText('ROSNEDAG', 'Corresponding mapping FOUND.');

  ELSE
    null;

--    EcDp_DynSql.WriteTempText('ROSNEDAG', 'Corresponding mapping NOT FOUND.');

  END IF;


  IF NOT lb_found THEN

    -- Get next group number
    FOR rsM IN c_max(p_cost_map_id, p_period) LOOP

      ln_next_group_no := nvl(rsM.Max_Group_No,0) + 1;

    END LOOP;


--    EcDp_DynSql.WriteTempText('ROSNEDAG', 'Creating source mapping group ' || ln_next_group_no);

    -- Use cont mapping object to create new source mapping for inbound journal entry.

    -- DATASET --
    IF lrec_ref_je.dataset IS NOT NULL THEN
      INSERT INTO COST_MAPPING_SRC_SETUP
        (OBJECT_ID,
         DAYTIME,
         SPLIT_KEY_SOURCE,
         SRC_TYPE,
         OPERATOR,
         SRC_CODE,
         GROUP_NO,
         COMMENTS)
      VALUES
        (p_cost_map_id,
         ld_daytime,
         'MAPPING_DEFAULT',
         'DATASET',
         'EQUALS',
         lrec_ref_je.dataset,
         ln_next_group_no,
         'Source mapping generated from Unmapped by user: ' || lv2_User || ' at ' || ld_sysdate || '.'
        );
    END IF;

    -- EXPENDITURE_TYPE --
    IF lrec_je.expenditure_type IS NOT NULL THEN
      INSERT INTO COST_MAPPING_SRC_SETUP
        (OBJECT_ID,
         DAYTIME,
         SPLIT_KEY_SOURCE,
         SRC_TYPE,
         OPERATOR,
         SRC_CODE,
         GROUP_NO,
         COMMENTS)
      VALUES
        (p_cost_map_id,
         ld_daytime,
         'MAPPING_DEFAULT',
         'EXPENDITURE_TYPE',
         'EQUALS',
         lrec_je.expenditure_type,
         ln_next_group_no,
         'Source mapping generated from Unmapped by user: ' || lv2_User || ' at ' || ld_sysdate || '.'
        );
    END IF;

    -- FIN_ACCOUNT --
    IF lrec_je.fin_account_code IS NOT NULL THEN
      INSERT INTO COST_MAPPING_SRC_SETUP
        (OBJECT_ID,
         DAYTIME,
         SPLIT_KEY_SOURCE,
         SRC_TYPE,
         OPERATOR,
         SRC_CODE,
         GROUP_NO,
         COMMENTS)
      VALUES
        (p_cost_map_id,
         ld_daytime,
         'MAPPING_DEFAULT',
         'FIN_ACCOUNT',
         'EQUALS',
         lrec_je.fin_account_code,
         ln_next_group_no,
         'Source mapping generated from Unmapped by user: ' || lv2_User || ' at ' || ld_sysdate || '.'
        );
    END IF;

    -- FIN_WBS --
    IF lrec_je.fin_wbs_code IS NOT NULL THEN
      INSERT INTO COST_MAPPING_SRC_SETUP
        (OBJECT_ID,
         DAYTIME,
         SPLIT_KEY_SOURCE,
         SRC_TYPE,
         OPERATOR,
         SRC_CODE,
         GROUP_NO,
         COMMENTS)
      VALUES
        (p_cost_map_id,
         ld_daytime,
         'MAPPING_DEFAULT',
         'FIN_WBS',
         'EQUALS',
         lrec_je.fin_wbs_code,
         ln_next_group_no,
         'Source mapping generated from Unmapped by user: ' || lv2_User || ' at ' || ld_sysdate || '.'
        );
    END IF;

    -- DOCUMENT_TYPE --
    IF lrec_je.document_type IS NOT NULL THEN
      INSERT INTO COST_MAPPING_SRC_SETUP
        (OBJECT_ID,
         DAYTIME,
         SPLIT_KEY_SOURCE,
         SRC_TYPE,
         OPERATOR,
         SRC_CODE,
         GROUP_NO,
         COMMENTS)
      VALUES
        (p_cost_map_id,
         ld_daytime,
         'MAPPING_DEFAULT',
         'DOCUMENT_TYPE',
         'EQUALS',
         lrec_je.document_type,
         ln_next_group_no,
         'Source mapping generated from Unmapped by user: ' || lv2_User || ' at ' || ld_sysdate || '.'
        );
    END IF;

    -- CONTRACT --
    IF lrec_je.contract_code IS NOT NULL THEN
      INSERT INTO COST_MAPPING_SRC_SETUP
        (OBJECT_ID,
         DAYTIME,
         SPLIT_KEY_SOURCE,
         SRC_TYPE,
         OPERATOR,
         SRC_CODE,
         GROUP_NO,
         COMMENTS)
      VALUES
        (p_cost_map_id,
         ld_daytime,
         'MAPPING_DEFAULT',
         'CONTRACT',
         'EQUALS',
         lrec_je.contract_code,
         ln_next_group_no,
         'Source mapping generated from Unmapped by user: ' || lv2_User || ' at ' || ld_sysdate || '.'
        );
    END IF;

  END IF; -- found

--  EcDp_DynSql.WriteTempText('ROSNEDAG', 'END JE: ' || p_je_no || ' ---------------------------------------------');

EXCEPTION
    WHEN cost_map_id_not_provided THEN
        RAISE_APPLICATION_ERROR(-20000, 'Target Data Mapping ID is not provided.');

END AddNewSourceMapping;



PROCEDURE MoveUnmappedJEToManual(
          p_je_no NUMBER,
          p_target_document_key VARCHAR2)
IS
    lrec_new_journal_entry CONT_JOURNAL_ENTRY%ROWTYPE;
    lrec_new_ifac_journal_entry IFAC_JOURNAL_ENTRY%ROWTYPE;
    lrec_target_doc        CONT_DOC%ROWTYPE;
    lex_document_approved  EXCEPTION;

BEGIN
    lrec_new_journal_entry := EC_CONT_JOURNAL_ENTRY.ROW_BY_PK(p_je_no);
    lrec_target_doc := EC_CONT_DOC.ROW_BY_PK(p_target_document_key);

    IF lrec_new_journal_entry.journal_entry_no is null then
      lrec_new_ifac_journal_entry :=  EC_IFAC_JOURNAL_ENTRY.ROW_BY_PK(p_je_no);

      lrec_new_journal_entry.JOURNAL_ENTRY_NO	:=	lrec_new_ifac_journal_entry.JOURNAL_ENTRY_NO;
      lrec_new_journal_entry.COMPANY_CODE	:=	lrec_new_ifac_journal_entry.COMPANY_CODE;
      lrec_new_journal_entry.FISCAL_YEAR	:=	lrec_new_ifac_journal_entry.FISCAL_YEAR;
      lrec_new_journal_entry.DAYTIME	:=	lrec_new_ifac_journal_entry.DAYTIME;
      lrec_new_journal_entry.PERIOD	:=	lrec_new_ifac_journal_entry.PERIOD;
      lrec_new_journal_entry.CONTRACT_CODE	:=	lrec_new_ifac_journal_entry.CONTRACT_CODE;
      lrec_new_journal_entry.DATASET	:=	lrec_new_ifac_journal_entry.DATASET;
      lrec_new_journal_entry.LINE_ITEM_KEY	:=	lrec_new_ifac_journal_entry.LINE_ITEM_KEY;
      lrec_new_journal_entry.POSTING_KEY	:=	lrec_new_ifac_journal_entry.POSTING_KEY;
      lrec_new_journal_entry.ACCOUNT_TYPE	:=	lrec_new_ifac_journal_entry.ACCOUNT_TYPE;
      lrec_new_journal_entry.DEBIT_CREDIT_CODE	:=	lrec_new_ifac_journal_entry.DEBIT_CREDIT_CODE;
      lrec_new_journal_entry.TAX_CODE	:=	lrec_new_ifac_journal_entry.TAX_CODE;
      lrec_new_journal_entry.AMOUNT	:=	lrec_new_ifac_journal_entry.AMOUNT;
      lrec_new_journal_entry.TAX_AMOUNT	:=	lrec_new_ifac_journal_entry.TAX_AMOUNT;
      lrec_new_journal_entry.QTY_1	:=	lrec_new_ifac_journal_entry.QTY_1;
      lrec_new_journal_entry.UOM1_CODE	:=	lrec_new_ifac_journal_entry.UOM1_CODE;
      lrec_new_journal_entry.DOCUMENT_TYPE	:=	lrec_new_ifac_journal_entry.DOCUMENT_TYPE;
      lrec_new_journal_entry.FIN_ACCOUNT_CODE	:=	lrec_new_ifac_journal_entry.FIN_ACCOUNT_CODE;
      lrec_new_journal_entry.FIN_COST_OBJECT_CODE	:=	lrec_new_ifac_journal_entry.FIN_COST_OBJECT_CODE;
      lrec_new_journal_entry.FIN_COST_CENTER_CODE	:=	lrec_new_ifac_journal_entry.FIN_COST_CENTER_CODE;
      lrec_new_journal_entry.FIN_REVENUE_ORDER_CODE	:=	lrec_new_ifac_journal_entry.FIN_REVENUE_ORDER_CODE;
      lrec_new_journal_entry.FIN_WBS_CODE	:=	lrec_new_ifac_journal_entry.FIN_WBS_CODE;
      lrec_new_journal_entry.MATERIAL	:=	lrec_new_ifac_journal_entry.MATERIAL;
      lrec_new_journal_entry.PLANT	:=	lrec_new_ifac_journal_entry.PLANT;
      lrec_new_journal_entry.JOINT_VENTURE	:=	lrec_new_ifac_journal_entry.JOINT_VENTURE;
      lrec_new_journal_entry.RECOVERY_IND	:=	lrec_new_ifac_journal_entry.RECOVERY_IND;
      lrec_new_journal_entry.EQUITY_GROUP	:=	lrec_new_ifac_journal_entry.EQUITY_GROUP;
      lrec_new_journal_entry.PROFIT_CENTER_CODE	:=	lrec_new_ifac_journal_entry.PROFIT_CENTER_CODE;
      lrec_new_journal_entry.FIN_WBS_DESCR	:=	lrec_new_ifac_journal_entry.FIN_WBS_DESCR;
      lrec_new_journal_entry.FIN_ACCOUNT_DESCR	:=	lrec_new_ifac_journal_entry.FIN_ACCOUNT_DESCR;
      lrec_new_journal_entry.EXPENDITURE_TYPE	:=	lrec_new_ifac_journal_entry.EXPENDITURE_TYPE;
      lrec_new_journal_entry.TRANSACTION_TYPE	:=	lrec_new_ifac_journal_entry.TRANSACTION_TYPE;
      lrec_new_journal_entry.CURRENCY_CODE	:=	lrec_new_ifac_journal_entry.CURRENCY_CODE;
      lrec_new_journal_entry.PERIOD_CODE	:=	lrec_new_ifac_journal_entry.PERIOD_CODE;
      lrec_new_journal_entry.COMMENTS	:=	lrec_new_ifac_journal_entry.COMMENTS;
      lrec_new_journal_entry.TEXT_1	:=	lrec_new_ifac_journal_entry.TEXT_1;
      lrec_new_journal_entry.TEXT_2	:=	lrec_new_ifac_journal_entry.TEXT_2;
      lrec_new_journal_entry.TEXT_3	:=	lrec_new_ifac_journal_entry.TEXT_3;
      lrec_new_journal_entry.TEXT_4	:=	lrec_new_ifac_journal_entry.TEXT_4;
      lrec_new_journal_entry.TEXT_5	:=	lrec_new_ifac_journal_entry.TEXT_5;
      lrec_new_journal_entry.TEXT_6	:=	lrec_new_ifac_journal_entry.TEXT_6;
      lrec_new_journal_entry.TEXT_7	:=	lrec_new_ifac_journal_entry.TEXT_7;
      lrec_new_journal_entry.TEXT_8	:=	lrec_new_ifac_journal_entry.TEXT_8;
      lrec_new_journal_entry.TEXT_9	:=	lrec_new_ifac_journal_entry.TEXT_9;
      lrec_new_journal_entry.TEXT_10	:=	lrec_new_ifac_journal_entry.TEXT_10;
      lrec_new_journal_entry.TEXT_11	:=	lrec_new_ifac_journal_entry.TEXT_11;
      lrec_new_journal_entry.TEXT_12	:=	lrec_new_ifac_journal_entry.TEXT_12;
      lrec_new_journal_entry.TEXT_13	:=	lrec_new_ifac_journal_entry.TEXT_13;
      lrec_new_journal_entry.TEXT_14	:=	lrec_new_ifac_journal_entry.TEXT_14;
      lrec_new_journal_entry.TEXT_15	:=	lrec_new_ifac_journal_entry.TEXT_15;
      lrec_new_journal_entry.TEXT_16	:=	lrec_new_ifac_journal_entry.TEXT_16;
      lrec_new_journal_entry.TEXT_17	:=	lrec_new_ifac_journal_entry.TEXT_17;
      lrec_new_journal_entry.TEXT_18	:=	lrec_new_ifac_journal_entry.TEXT_18;
      lrec_new_journal_entry.TEXT_19	:=	lrec_new_ifac_journal_entry.TEXT_19;
      lrec_new_journal_entry.TEXT_20	:=	lrec_new_ifac_journal_entry.TEXT_20;
      lrec_new_journal_entry.VALUE_1	:=	lrec_new_ifac_journal_entry.VALUE_1;
      lrec_new_journal_entry.VALUE_2	:=	lrec_new_ifac_journal_entry.VALUE_2;
      lrec_new_journal_entry.VALUE_3	:=	lrec_new_ifac_journal_entry.VALUE_3;
      lrec_new_journal_entry.VALUE_4	:=	lrec_new_ifac_journal_entry.VALUE_4;
      lrec_new_journal_entry.VALUE_5	:=	lrec_new_ifac_journal_entry.VALUE_5;
      lrec_new_journal_entry.VALUE_6	:=	lrec_new_ifac_journal_entry.VALUE_6;
      lrec_new_journal_entry.VALUE_7	:=	lrec_new_ifac_journal_entry.VALUE_7;
      lrec_new_journal_entry.VALUE_8	:=	lrec_new_ifac_journal_entry.VALUE_8;
      lrec_new_journal_entry.VALUE_9	:=	lrec_new_ifac_journal_entry.VALUE_9;
      lrec_new_journal_entry.VALUE_10	:=	lrec_new_ifac_journal_entry.VALUE_10;
      lrec_new_journal_entry.DATE_1	:=	lrec_new_ifac_journal_entry.DATE_1;
      lrec_new_journal_entry.DATE_2	:=	lrec_new_ifac_journal_entry.DATE_2;
      lrec_new_journal_entry.DATE_3	:=	lrec_new_ifac_journal_entry.DATE_3;
      lrec_new_journal_entry.DATE_4	:=	lrec_new_ifac_journal_entry.DATE_4;
      lrec_new_journal_entry.DATE_5	:=	lrec_new_ifac_journal_entry.DATE_5;
      lrec_new_journal_entry.DATE_6	:=	lrec_new_ifac_journal_entry.DATE_6;
      lrec_new_journal_entry.DATE_7	:=	lrec_new_ifac_journal_entry.DATE_7;
      lrec_new_journal_entry.DATE_8	:=	lrec_new_ifac_journal_entry.DATE_8;
      lrec_new_journal_entry.DATE_9	:=	lrec_new_ifac_journal_entry.DATE_9;
      lrec_new_journal_entry.DATE_10	:=	lrec_new_ifac_journal_entry.DATE_10;
      lrec_new_journal_entry.REF_OBJECT_ID_1	:=	lrec_new_ifac_journal_entry.REF_OBJECT_ID_1;
      lrec_new_journal_entry.REF_OBJECT_ID_2	:=	lrec_new_ifac_journal_entry.REF_OBJECT_ID_2;
      lrec_new_journal_entry.REF_OBJECT_ID_3	:=	lrec_new_ifac_journal_entry.REF_OBJECT_ID_3;
      lrec_new_journal_entry.REF_OBJECT_ID_4	:=	lrec_new_ifac_journal_entry.REF_OBJECT_ID_4;
      lrec_new_journal_entry.REF_OBJECT_ID_5	:=	lrec_new_ifac_journal_entry.REF_OBJECT_ID_5;
      lrec_new_journal_entry.REF_OBJECT_ID_6	:=	lrec_new_ifac_journal_entry.REF_OBJECT_ID_6;
      lrec_new_journal_entry.REF_OBJECT_ID_7	:=	lrec_new_ifac_journal_entry.REF_OBJECT_ID_7;
      lrec_new_journal_entry.REF_OBJECT_ID_8	:=	lrec_new_ifac_journal_entry.REF_OBJECT_ID_8;
      lrec_new_journal_entry.REF_OBJECT_ID_9	:=	lrec_new_ifac_journal_entry.REF_OBJECT_ID_9;
      lrec_new_journal_entry.REF_OBJECT_ID_10	:=	lrec_new_ifac_journal_entry.REF_OBJECT_ID_10;

    END IF;

    IF lrec_target_doc.record_status = 'A' THEN
        RAISE lex_document_approved;
    END IF;


    -- Configure and insert the new journal entry
    lrec_new_journal_entry.MANUAL_IND := 'Y';
    lrec_new_journal_entry.JOURNAL_ENTRY_NO := NULL;
    lrec_new_journal_entry.DOCUMENT_KEY := p_target_document_key;
    lrec_new_journal_entry.DATASET := lrec_target_doc.dataset;
    lrec_new_journal_entry.REF_JOURNAL_ENTRY_NO := p_je_no;
    lrec_new_journal_entry.REVERSAL_DATE := NULL;
    lrec_new_journal_entry.RECORD_STATUS := 'P';
    lrec_new_journal_entry.CREATED_BY := ECDP_CONTEXT.GETAPPUSER();
    lrec_new_journal_entry.created_date := Ecdp_Timestamp.getCurrentSysdate;
    lrec_new_journal_entry.last_updated_by := NULL;
    lrec_new_journal_entry.last_updated_date := NULL;
    lrec_new_journal_entry.rev_no := NULL;
    lrec_new_journal_entry.rev_text := NULL;
    lrec_new_journal_entry.approval_by := NULL;
    lrec_new_journal_entry.approval_date := NULL;
    lrec_new_journal_entry.approval_state := NULL;
    lrec_new_journal_entry.rec_id := NULL;

    INSERT INTO CONT_JOURNAL_ENTRY
    VALUES lrec_new_journal_entry;

    -- Update the old the old journal entry?

EXCEPTION
    WHEN lex_document_approved THEN
        RAISE_APPLICATION_ERROR(-20000, 'Document ''' || p_target_document_key || ''' is approved, cannot move unmapped journal entries to an approved document.');


END MoveUnmappedJEToManual;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : MoveUnmappedJE
-- Description    : Move the specified unmapped journal entry to a taget.

--                  Parameter p_do_not_ignore:
--                  The parameter is for screen use, when the value is not 'Y', this
--                  procedure will return without making any change to the database. This
--                  is not a clean solution since the data filtering should be done before
--                  request reaches database. Due to performance and screen limitation,
--                  it is done this way for now.
--
---------------------------------------------------------------------------------------------------
PROCEDURE MoveUnmappedJE(
          p_je_no               NUMBER,
          p_move_target_code    VARCHAR2,
          p_target_document_key VARCHAR2,
          p_target_cost_map_id  VARCHAR2,
          p_period              DATE,
          p_do_not_ignore       VARCHAR2 DEFAULT 'Y')
IS
    target_code_not_provided EXCEPTION;
    target_code_not_supported EXCEPTION;
BEGIN

    IF p_do_not_ignore IS NULL OR p_do_not_ignore <> 'Y' THEN
        RETURN;
    END IF;

    IF p_move_target_code IS NULL THEN
        RAISE target_code_not_provided;
    END IF;

    IF p_move_target_code = 'TO_MANUAL' THEN
        MoveUnmappedJEToManual(p_je_no, p_target_document_key);
    ELSIF p_move_target_code = 'TO_COST_MAPPING' THEN
        AddNewSourceMapping(p_target_cost_map_id, p_period, p_je_no);
    ELSE
        RAISE target_code_not_supported;
    END IF;

EXCEPTION
    WHEN target_code_not_provided THEN
        RAISE_APPLICATION_ERROR(-20000, 'Target Code is not provided, please specify the target where the unmapped journal entries should be moved to.');

    WHEN target_code_not_supported THEN
        RAISE_APPLICATION_ERROR(-20000, 'Target Code ''' || p_move_target_code || ''' is not supported.');

END MoveUnmappedJE;

/* JDBC query
   Used to retrieve cost mapping objects valid on daytime and dataset
   If object id is passed, only this object will be retrieved.
 */
PROCEDURE q_cost_mapping_obj(p_cursor         OUT SYS_REFCURSOR,
                             p_dataset            VARCHAR2,
                             p_daytime            DATE,
                             p_accrual_ind        VARCHAR2,
                             p_object_id          VARCHAR2 DEFAULT NULL,
                             p_group_contract_id  VARCHAR2 DEFAULT NULL,
                             p_contract_id        VARCHAR2 DEFAULT NULL,
                             p_report_ref_item_id VARCHAR2 DEFAULT NULL)
IS

BEGIN

  OPEN p_cursor FOR
 SELECT c.object_code,
        cv.object_id trg_contract_id,
        cmv.line_item_key,
        cmv.material,
        cmv.plant,
        cmv.joint_venture,
        cmv.recovery_ind,
        cmv.equity_group,
        cmv.trg_debit_credit_code,
        cmv.posting_key,
        cmv.object_id,
        cmv.daytime,
        cmv.end_date,
        cmv.name,
        cmv.trg_fin_account_id,
        cmv.trg_fin_wbs_id,
        cmv.trg_fin_revenue_order_id,
        cmv.trg_fin_cost_center_id,
        cmv.trg_dataset,
        cmv.trg_debit_credit_code,
        cmv.company_id,
        cmv.split_key_id,
        ec_split_key.object_code(cmv.split_key_id) split_code,
        cmv.other_split_item_id split_item,
        cmv.trg_fin_wbs_value_source,
        cmv.journal_entry_source,
        cmv.date_filter,
        cmv.mapping_type,
        c.object_code trg_contract_code,
        ec_fin_account.object_code(cmv.trg_fin_account_id) trg_fin_account_code,
        ec_fin_cost_center.object_code(cmv.trg_fin_cost_center_id) trg_fin_cost_center_code,
        ec_fin_revenue_order.object_code(cmv.trg_fin_revenue_order_id) trg_fin_revenue_order_code,
        ec_fin_wbs.object_code(cmv.trg_fin_wbs_id) trg_fin_wbs_code,
        ec_fin_wbs.description(cmv.trg_fin_wbs_id) trg_fin_wbs_desc,
        NVL(ec_split_key_setup.split_share_mth(cmv.split_key_id,cmv.other_split_item_id,cmv.daytime,'<='),1) split_share,
        NVL(ec_prosty_codes.alt_code(journal_entry_source, 'COST_MAPPING_JE_SOURCE'), 'IFAC_JOURNAL_ENTRY') journal_entry_source_table,
        CASE WHEN cmv.use_report_ref_group_ind = 'Y'
             THEN ec_report_reference_version.report_reference_tag(rrg.report_ref_id,cmv.daytime,'<=')
             ELSE ec_report_reference_version.report_reference_tag(cmv.report_ref_id,cmv.daytime,'<=')
        END tag,
        CASE WHEN cmv.use_report_ref_group_ind = 'Y'
             THEN rrg.report_ref_id
             ELSE cmv.report_ref_id
        END reference_id,
        cmv.trg_inventory_id inventory_id,
        NVL(cmv.trg_contract_group_id,cv.contract_area_id) trg_contract_group_id ,
        ec_contract_area.object_code(NVL(cmv.trg_contract_group_id,cv.contract_area_id)) trg_contract_group_code,
        CASE WHEN p_accrual_ind IS NOT NULL                                -- When processing Data Mapping
             THEN rrg.report_ref_item_id
             ELSE                                                          -- When called from View Query button
                  CASE WHEN ((cmv.accrual = 'FINAL' AND rrg.accrual = 'ACCRUAL') OR
                             (cmv.accrual = 'ACCRUAL' AND rrg.accrual = 'FINAL'))
                       THEN 'X'                                            -- Assigned false value so it will not match the source mappings in q_cost_mapping_obj_src
                       ELSE  rrg.report_ref_item_id
                   END
        END report_ref_item_id,
        ec_report_reference_version.name(ec_report_ref_item_version.report_ref_id(rrg.report_ref_item_id,cmv.daytime,'<='),cmv.daytime,'<=') report_ref_name,
        ec_report_ref_group_version.name(ec_report_ref_item_version.report_ref_group_id(rrg.report_ref_item_id, cmv.daytime,'<='),cmv.daytime,'<=') report_ref_group_name
   FROM cost_mapping cm,
        cost_mapping_version cmv,
        contract_version cv,
        contract c,
        (SELECT rriv.daytime,
                rriv.object_id report_ref_item_id,
                rriv.report_ref_group_id,
                rriv.dataset,
                rriv.report_ref_id,
                rriv.accrual
           FROM report_ref_item rri,
                report_ref_item_version rriv
          WHERE rri.object_id = rriv.object_id
            AND (rri.object_id = p_report_ref_item_id   -- When called from View Query button
                OR p_report_ref_item_id IS NULL)        -- When processing Data Mapping
            AND rriv.daytime >= rri.start_date
            AND p_daytime < NVL(rriv.end_date, p_daytime + 1)
            AND (
                 ((p_accrual_ind IS NOT NULL) AND (NVL(rriv.accrual,'BOTH') IN (DECODE(p_accrual_ind,'Y','ACCRUAL','FINAL'),'BOTH'))
				 )                                      -- When processing Data Mapping
                 OR (p_accrual_ind IS NULL)             -- When called from View Query button
                )
            AND rriv.daytime = (SELECT MAX(daytime)
                                  FROM report_ref_item_version rv
                                 WHERE rv.object_id = rri.object_id
                                   AND rv.daytime <= p_daytime)) rrg
  WHERE c.object_id = cv.object_id
    AND cmv.trg_dataset = p_dataset
    AND cm.object_id = NVL(p_object_id,cm.object_id)
    AND cm.object_id = cmv.object_id
    AND cmv.report_ref_group_id = rrg.report_ref_group_id(+)
    AND cmv.trg_dataset	= rrg.dataset(+)
    AND NVL(cv.daytime,p_daytime) <= p_daytime
    AND NVL(cv.end_Date,p_daytime+1)  > p_daytime
    AND cv.object_id = NVL(p_contract_id,cv.object_id )
    AND cv.object_id = NVL(cmv.trg_contract_id,cv.object_id )
    AND cv.contract_area_id = NVL(p_group_contract_id,cv.contract_area_id)
    AND cv.contract_area_id = NVL(cmv.trg_contract_group_id,cv.contract_area_id)
    AND cmv.daytime >= cm.start_date
    AND p_daytime < NVL(cmv.end_date, p_daytime + 1)
    AND cmv.daytime = (SELECT MAX(daytime)
                         FROM cost_mapping_version vd
                        WHERE vd.object_id = cm.object_id
                          AND vd.daytime <= p_daytime)
    AND (
	     ((p_accrual_ind IS NOT NULL)
	       AND (DECODE(NVL(cmv.use_report_ref_group_ind,'N'), 'N', NVL(cmv.accrual,'BOTH'), DECODE(NVL(cmv.accrual,'BOTH'), 'REPORT_REF_GROUP', NVL(rrg.accrual,'BOTH'), NVL(cmv.accrual,'BOTH')))
		                           IN (DECODE(p_accrual_ind,'Y','ACCRUAL','FINAL'),'BOTH'))
	     )                        -- When processing Data Mapping
	     OR
		 (p_accrual_ind IS NULL)  -- When called from View Query button
		);

  END q_cost_mapping_obj;


/* JDBC query
   Used to retrieve cost mapping object's source mapping
 */
PROCEDURE q_cost_mapping_obj_src(p_cursor              OUT SYS_REFCURSOR,
                                 p_object_id               VARCHAR2,
                                 p_daytime                 DATE,
                                 p_report_ref_item_id      VARCHAR2,
                                 p_screen_rep_ref_item_id  VARCHAR2 DEFAULT NULL)
 IS

BEGIN

  OPEN p_cursor FOR
    SELECT s.object_id,
           s.daytime,
           s.src_type,
           s.src_code,
           ec_prosty_codes.alt_code(s.operator, 'CM_SRC_OPERATOR') operator,
           s.operator operator_code,
           s.split_key_source,
           s.group_no,
           s.comments,
           pc.alt_code,
           s.object_type
      FROM cost_mapping_src_setup s,
           prosty_codes pc
     WHERE s.object_id = p_object_id
       AND s.daytime = p_daytime
       AND pc.code_type = 'COST_MAPPING_SRC_TYPE'
       AND pc.code = s.src_type
    UNION
    SELECT cmv.object_id,
           rss.daytime,
           rss.src_type,
           rss.src_code,
           ec_prosty_codes.alt_code(rss.operator, 'CM_SRC_OPERATOR') operator,
           rss.operator operator_code,
           rss.split_key_source,
           rss.group_no,
           rss.comments,
           pc.alt_code,
           rss.object_type
      FROM report_ref_item_version riv,
           report_ref_grp_src_setup rss,
           cost_mapping_version cmv,
           prosty_codes pc
     WHERE riv.object_id = rss.object_id
       AND riv.report_ref_group_id = cmv.report_ref_group_id
       AND cmv.object_id = p_object_id
       AND cmv.daytime = p_daytime
       AND (
           (p_screen_rep_ref_item_id IS NULL AND riv.object_id = p_report_ref_item_id)                -- When processing Data Mapping
           OR
           (p_screen_rep_ref_item_id = 'ALL_ITEMS')                                                   -- When called from View Query button, not selected any item
           OR
           (p_screen_rep_ref_item_id = p_report_ref_item_id AND riv.object_id = p_report_ref_item_id) -- When called from View Query button, selected specific item
           )
       AND pc.code_type = 'COST_MAPPING_SRC_TYPE'
       AND pc.code = rss.src_type
     ORDER BY group_no, src_type;

END q_cost_mapping_obj_src;


/* JDBC query
   Used to retrieve object lists used in source mapping
 */
PROCEDURE q_object_list(p_cursor      OUT SYS_REFCURSOR,
                        p_object_code VARCHAR2,
                        p_daytime     DATE)

 IS

BEGIN

  OPEN p_cursor FOR
    SELECT o.object_code,o.object_id,v.class_name
      FROM object_list o, object_list_version v
     WHERE o.object_id = v.object_id
       AND o.object_code LIKE p_object_code
       AND v.daytime >= o.start_date
       AND v.daytime < nvl(o.end_date, v.daytime + 1)
       AND v.daytime = (SELECT MAX(sub.daytime)
                          FROM object_list_version sub
                         WHERE sub.object_id = o.object_id
                           AND sub.daytime <= p_daytime);

END q_object_list;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetPrecedingDocNumber
-- Description    : Gets the preceding document number for given document
--                  information. This function can be used when creating
--                  or updating a document so the preceding document number
--                  needs to be reset. Exception will be thrown when document
--                  with given parameter should not be created.
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
FUNCTION GetPrecedingDocNumber(p_dataset          VARCHAR2,
                               p_period           DATE,
                               p_object_id        VARCHAR2,
                               p_document_type    VARCHAR2,
                               p_accrual_ind      VARCHAR2,
                               p_summary_setup_id VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
--</EC-DOC>
IS


lv2_document_key VARCHAR2(32);

CURSOR c_prec_doc IS
SELECT d.document_key, d.record_status, d.accrual_ind
  FROM cont_doc d
 WHERE TRUNC(d.period, 'MONTH') = TRUNC(p_period, 'MONTH')
   AND d.dataset = p_dataset
   AND d.object_id = p_object_id
   AND NVL(p_summary_setup_id, 'XX') = NVL(d.summary_setup_id, 'XX')
   AND d.document_type = p_document_type
   AND d.created_date = (SELECT MAX(ds.created_date)
                         FROM cont_doc ds
                        WHERE TRUNC(ds.period, 'MONTH') = TRUNC(d.period, 'MONTH')
                          AND d.object_id = ds.object_id
                          AND NVL(ds.summary_setup_id, 'XX') = NVL(d.summary_setup_id, 'XX')
                          AND NVL(ds.contract_id, 'XX') = NVL(d.contract_id, 'XX')
                          AND d.document_type = ds.document_type
                          AND ds.dataset = d.dataset);

prec_doc_not_approved EXCEPTION;
prec_doc_is_final EXCEPTION;


BEGIN

FOR pd IN c_prec_doc LOOP
    lv2_document_key := pd.document_key;

    IF (nvl(pd.Record_Status,'X') = 'P') THEN
        RAISE prec_doc_not_approved;
    END IF;

    IF (nvl(pd.accrual_ind,'N') != 'Y' AND nvl(p_accrual_ind,'N') = 'Y') THEN
        RAISE prec_doc_is_final;
    END IF;

END LOOP;

RETURN lv2_document_key;


EXCEPTION
  WHEN prec_doc_not_approved THEN
     RAISE_APPLICATION_ERROR(-20000, 'Can not get preceding document.\n\nPreceding document (' || lv2_document_key || ') for the same month has not been Approved / Verified.');

  WHEN prec_doc_is_final THEN
     RAISE_APPLICATION_ERROR(-20000, 'Can not create an Accrual with a Final preceding document.Preceding Data Mapping document (' || lv2_document_key || ') is final.');

END GetPrecedingDocNumber;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetCostMappingTracingMode
-- Description    : Gets the code of the cost mapping tracing mode from system attribute.
---------------------------------------------------------------------------------------------------
FUNCTION GetCostMappingTracingMode(p_daytime DATE) RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
    RETURN NVL(ec_ctrl_system_attribute.attribute_text(p_daytime, 'JOURNAL_MAP_TRAC_MODE', '<='),
            COSTMAP_TRACING_MODE_FULL);
END GetCostMappingTracingMode;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : CreateCostMappingTracing
-- Description    : Create the cost mapping tracing data. If p_force_create is not 'Y', then
--                  data will be created only when system attribute
--                  'JOURNAL_MAP_EXT_TRAC_IND' is set to 'Y'; the system attribute
--                  will not be checked otherwise.
---------------------------------------------------------------------------------------------------
PROCEDURE CreateCostMappingTracing(p_dataset VARCHAR2,
                                             p_daytime DATE,
                                             p_group_contract_id VARCHAR2 DEFAULT NULL,
                                             p_contract_id VARCHAR2 DEFAULT NULL,
                                             p_force_create VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS
    -- Get all documents that don't have cost mapping tracing generated
    CURSOR cr_new_cost_mapping IS
        SELECT document_key
        FROM  cont_doc
        WHERE  DOCUMENT_TYPE = 'COST_DATASET'
            AND dataset = p_dataset
            AND NOT EXISTS (
                SELECT document_key
                FROM cost_map_tracing
                WHERE cost_mapp_doc_key = cont_doc.document_key);

    lv_tracing_mode VARCHAR2(32);
BEGIN
    -- If the System Attribute 'JOURNAL_MAP_EXT_TRAC_IND' = 'Y'
    -- or p_force_create = 'Y'
    IF p_force_create = 'Y' OR NVL(ec_ctrl_system_attribute.attribute_text(p_daytime,
                                                   'JOURNAL_MAP_EXT_TRAC_IND', '<='),'Y') = 'Y' THEN

        lv_tracing_mode := TRIM(GetCostMappingTracingMode(p_daytime));

        -- Get all documents that don't have cost mapping tracing generated
        FOR c_documents IN cr_new_cost_mapping LOOP
            IF lv_tracing_mode = COSTMAP_TRACING_MODE_WA THEN
                INSERT INTO cost_map_tracing(
                    COST_MAP_TRACING_NO,  -- The key
                    DAYTIME,
                    CONTRACT_CODE,
                    PERIOD,
                    DOCUMENT_TYPE,
                    DATASET,
                    TAG,
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
                    FIN_WBS_CODE,
                    FIN_ACCOUNT_CODE,
                    FIN_COST_CENTER_CODE,
                    JOURNAL_ENTRY_NO,
                    REF_JOURNAL_ENTRY_NO,
                    REVERSAL_DATE,
                    RECORD_STATUS)
                (
                    SELECT ECDP_SYSTEM_KEY.ASSIGNNEXTNUMBER('COST_TRACING') AS COST_MAP_TRACING_NO,
                        TRUNC(
                            TO_DATE(
                                NVL(
                                    ec_ctrl_system_attribute.attribute_text(Ecdp_Timestamp.getCurrentSysdate, 'DEFAULT_EC_RPT_SET_DATE', '<='),
                                    '2010-01-01T00:00:00'),
                                'yyyy-mm-dd"T"HH24:MI:SS'),
                            'MM') AS DAYTIME,
                        contract_code contract,
                        cje.period,
                        document_type,
                        dataset,
                        tag,
                        ec_cost_mapping.object_code(cost_mapping_id) as cost_mapping_code,
                        cje.src_fin_account_code load_account,
                        cje.src_wbs as load_wbs,
                        cje.src_qty as load_qty,
                        cje.src_amount load_amount,
                        nvl(abs(cje.calc_split),1) * DECODE(cje.reversal_date,NULL,1,-1) calc_split,
                        nvl(cje.mapping_split, 1) * DECODE(cje.reversal_date,NULL,1,-1) mapping_split,
                        cje.split_key_code,
                        cje.split_item_other_code,
                        cje.document_key cost_mapp_doc_key,
                        cje.QTY_1 cost_mapp_qty1,
                        AMOUNT cost_mapp_amount,
                        FIN_WBS_CODE,
                        FIN_ACCOUNT_CODE,
                        FIN_COST_CENTER_CODE,
                        cje.JOURNAL_ENTRY_NO,
                        cje.REF_JOURNAL_ENTRY_NO,
                        cje.REVERSAL_DATE,
                        'P' RECORD_STATUS
                    FROM (SELECT trg.cost_mapping_id,
                        sum(src.amount) src_amount,
                        ec_split_key.object_code(cmv.split_key_id) split_key_code,
                        ec_split_item_other.object_code(cmv.other_split_item_id) split_item_other_code,
                        (SELECT split_share_mth
                         FROM split_key_setup
                         WHERE object_id = cmv.split_key_id
                            AND split_member_id = cmv.other_split_item_id
                            AND daytime =
                                (select max(daytime)
                                   from split_key_setup
                                  where object_id = cmv.split_key_id
                                    and split_member_id =
                                        cmv.other_split_item_id
                                    and daytime <= trg.period)) mapping_split,
                        src.document_type,
                        src.fin_account_code src_fin_account_code,
                        src.fin_wbs_code src_wbs,
                        trg.fin_wbs_code,
                        trg.fin_account_code,
                        trg.fin_cost_object_code,
                        trg.fin_cost_center_code,
                        sum(trg.qty_1) qty_1,
                        sum(src.qty_1) src_qty,
                        sum(trg.amount) amount,
                        DECODE(sum(src.amount), 0, 1, sum(trg.amount) / sum(src.amount)) calc_split,
                        NULL journal_entry_no,
                        trg.document_key,
                        src.period,
                        trg.dataset,
                        trg.tag,
                        trg.contract_code,
                        trg.reversal_date reversal_date,
                        NULL ref_journal_entry_no
                   FROM ifac_journal_entry   src,
                        cont_journal_entry   trg,
                        cost_mapping_version cmv
                  WHERE trg.document_key = c_documents.document_key
                    and src.period = trg.period
                    and src.journal_entry_no = trg.ref_journal_entry_no
                    and cmv.object_id = trg.cost_mapping_id
                    and trg.reversal_date is null
                    and cmv.daytime <= trg.period
                    AND NVL(cmv.end_date, trg.period + 1) > trg.period
                 GROUP BY cmv.object_id,
                        cmv.daytime,
                        cmv.split_key_id,
                        cmv.other_split_item_id,
                        trg.period,
                        trg.cost_mapping_id,
                        --src.amount,
                        ec_split_key.object_code(cmv.split_key_id),
                        ec_split_item_other.object_code(cmv.other_split_item_id),
                        src.document_type,
                        src.fin_account_code,
                        src.fin_wbs_code,
                        trg.fin_wbs_code,
                        trg.fin_account_code,
                        trg.fin_cost_object_code,
                        trg.fin_cost_center_code,
                        trg.document_key,
                        src.period,
                        trg.dataset,
                        trg.tag,
                        trg.contract_code,
                        trg.reversal_date
                        ) cje
                        );
            ELSIF lv_tracing_mode = COSTMAP_TRACING_MODE_MC THEN
                INSERT INTO cost_map_tracing(
                    COST_MAP_TRACING_NO,  -- The key
                    DAYTIME,
                    CONTRACT_CODE,
                    PERIOD,
                    DOCUMENT_TYPE,
                    DATASET,
                    TAG,
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
                    FIN_WBS_CODE,
                    FIN_ACCOUNT_CODE,
                    FIN_COST_CENTER_CODE,
                    JOURNAL_ENTRY_NO,
                    REF_JOURNAL_ENTRY_NO,
                    REVERSAL_DATE,
                    RECORD_STATUS)
                (
                    SELECT ECDP_SYSTEM_KEY.ASSIGNNEXTNUMBER('COST_TRACING') AS COST_MAP_TRACING_NO,
                        TRUNC(
                            TO_DATE(
                                NVL(
                                    ec_ctrl_system_attribute.attribute_text(Ecdp_Timestamp.getCurrentSysdate, 'DEFAULT_EC_RPT_SET_DATE', '<='),
                                    '2010-01-01T00:00:00'),
                                'yyyy-mm-dd"T"HH24:MI:SS'),
                            'MM') AS DAYTIME,
                        contract_code contract,
                        cje.period,
                        document_type,
                        dataset,
                        tag,
                        ec_cost_mapping.object_code(cost_mapping_id) as cost_mapping_code,
                        cje.src_fin_account_code load_account,
                        cje.src_wbs as load_wbs,
                        cje.src_qty as load_qty,
                        cje.src_amount load_amount,
                        nvl(abs(cje.calc_split),1) * DECODE(cje.reversal_date,NULL,1,-1) calc_split,
                        nvl(cje.mapping_split, 1) * DECODE(cje.reversal_date,NULL,1,-1) mapping_split,
                        cje.split_key_code,
                        cje.split_item_other_code,
                        cje.document_key cost_mapp_doc_key,
                        cje.QTY_1 cost_mapp_qty1,
                        AMOUNT cost_mapp_amount,
                        FIN_WBS_CODE,
                        FIN_ACCOUNT_CODE,
                        FIN_COST_CENTER_CODE,
                        cje.JOURNAL_ENTRY_NO,
                        cje.REF_JOURNAL_ENTRY_NO,
                        cje.REVERSAL_DATE,
                        'P' RECORD_STATUS
                    FROM (SELECT trg.cost_mapping_id,
                        sum(src.amount) src_amount,
                        ec_split_key.object_code(cmv.split_key_id) split_key_code,
                        ec_split_item_other.object_code(cmv.other_split_item_id) split_item_other_code,
                        (SELECT split_share_mth
                         FROM split_key_setup
                         WHERE object_id = cmv.split_key_id
                            AND split_member_id = cmv.other_split_item_id
                            AND daytime =
                                (select max(daytime)
                                   from split_key_setup
                                  where object_id = cmv.split_key_id
                                    and split_member_id =
                                        cmv.other_split_item_id
                                    and daytime <= trg.period)) mapping_split,
                        src.document_type,
                        'MULTIPLE' src_fin_account_code,
                        'MULTIPLE' src_wbs,
                        'MULTIPLE' fin_wbs_code,
                        'MULTIPLE' fin_account_code,
                        trg.fin_cost_object_code,
                        trg.fin_cost_center_code,
                        sum(trg.qty_1) qty_1,
                        sum(src.qty_1) src_qty,
                        sum(trg.amount) amount,
                        DECODE(sum(src.amount), 0, 1, sum(trg.amount) / sum(src.amount)) calc_split,
                        NULL journal_entry_no,
                        trg.document_key,
                        src.period,
                        trg.dataset,
                        trg.tag,
                        trg.contract_code,
                        trg.reversal_date reversal_date,
                        NULL ref_journal_entry_no
                   FROM ifac_journal_entry   src,
                        cont_journal_entry   trg,
                        cost_mapping_version cmv
                  WHERE trg.document_key = c_documents.document_key
                    and src.period = trg.period
                    and src.journal_entry_no = trg.ref_journal_entry_no
                    and cmv.object_id = trg.cost_mapping_id
                    and trg.reversal_date is null
                    and cmv.daytime <= trg.period
                    AND NVL(cmv.end_date, trg.period + 1) > trg.period
                 GROUP BY cmv.object_id,
                        cmv.daytime,
                        cmv.split_key_id,
                        cmv.other_split_item_id,
                        trg.period,
                        trg.cost_mapping_id,
                        ec_split_key.object_code(cmv.split_key_id),
                        ec_split_item_other.object_code(cmv.other_split_item_id),
                        src.document_type,
                        trg.fin_cost_object_code,
                        trg.fin_cost_center_code,
                        trg.document_key,
                        src.period,
                        trg.dataset,
                        trg.tag,
                        trg.contract_code,
                        trg.reversal_date
                        ) cje
                        );
            ELSE
                -- Generate the tracing report in FULL mode by default
                INSERT INTO cost_map_tracing(
                    COST_MAP_TRACING_NO,  -- The key
                    DAYTIME,
                    CONTRACT_CODE,
                    PERIOD,
                    DOCUMENT_TYPE,
                    DATASET,
                    TAG,
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
                    FIN_WBS_CODE,
                    FIN_ACCOUNT_CODE,
                    FIN_COST_CENTER_CODE,
                    JOURNAL_ENTRY_NO,
                    REF_JOURNAL_ENTRY_NO,
                    REVERSAL_DATE,
                    RECORD_STATUS)
                (
                    SELECT ECDP_SYSTEM_KEY.ASSIGNNEXTNUMBER('COST_TRACING') AS COST_MAP_TRACING_NO,
                        TRUNC(
                            TO_DATE(
                                NVL(
                                    ec_ctrl_system_attribute.attribute_text(Ecdp_Timestamp.getCurrentSysdate, 'DEFAULT_EC_RPT_SET_DATE', '<='),
                                    '2010-01-01T00:00:00'),
                                'yyyy-mm-dd"T"HH24:MI:SS'),
                            'MM') AS DAYTIME,
                        contract_code contract,
                        cje.period,
                        document_type,
                        dataset,
                        tag,
                        ec_cost_mapping.object_code(cost_mapping_id) as cost_mapping_code,
                        cje.src_fin_account_code load_account,
                        cje.src_wbs as load_wbs,
                        cje.src_qty as load_qty,
                        cje.src_amount load_amount,
                        nvl(abs(cje.calc_split),1) * DECODE(cje.reversal_date,NULL,1,-1) calc_split,
                        nvl(cje.mapping_split, 1) * DECODE(cje.reversal_date,NULL,1,-1) mapping_split,
                        cje.split_key_code,
                        cje.split_item_other_code,
                        cje.document_key cost_mapp_doc_key,
                        cje.QTY_1 cost_mapp_qty1,
                        AMOUNT cost_mapp_amount,
                        FIN_WBS_CODE,
                        FIN_ACCOUNT_CODE,
                        FIN_COST_CENTER_CODE,
                        cje.JOURNAL_ENTRY_NO,
                        cje.REF_JOURNAL_ENTRY_NO,
                        cje.REVERSAL_DATE,
                        'P' RECORD_STATUS
                    FROM (SELECT trg.cost_mapping_id,
                        src.amount src_amount,
                        ec_split_key.object_code(cmv.split_key_id) split_key_code,
                        ec_split_item_other.object_code(cmv.other_split_item_id) split_item_other_code,
                        (SELECT split_share_mth
                         FROM split_key_setup
                         WHERE object_id = cmv.split_key_id
                            AND split_member_id = cmv.other_split_item_id
                            AND daytime =
                                (select max(daytime)
                                   from split_key_setup
                                  where object_id = cmv.split_key_id
                                    and split_member_id =
                                        cmv.other_split_item_id
                                    and daytime <= trg.period)) mapping_split,
                        src.document_type,
                        src.fin_account_code src_fin_account_code,
                        src.fin_wbs_code src_wbs,
                        trg.fin_wbs_code,
                        trg.fin_account_code,
                        trg.fin_cost_object_code,
                        trg.fin_cost_center_code,
                        trg.qty_1,
                        src.qty_1 src_qty,
                        trg.amount,
                        DECODE(src.amount, 0, 1, trg.amount / src.amount) calc_split,
                        trg.journal_entry_no,
                        trg.document_key,
                        src.period,
                        trg.dataset,
                        trg.tag,
                        trg.contract_code,
                        trg.reversal_date reversal_date,
                        trg.ref_journal_entry_no ref_journal_entry_no
                   FROM ifac_journal_entry   src,
                        cont_journal_entry   trg,
                        cost_mapping_version cmv
                  WHERE trg.document_key = c_documents.document_key
                    and src.period = trg.period
                    and src.journal_entry_no = trg.ref_journal_entry_no
                    and cmv.object_id = trg.cost_mapping_id
                    and trg.reversal_date is null
                    and cmv.daytime <= trg.period
                    AND NVL(cmv.end_date, trg.period + 1) > trg.period) cje);

            END IF; -- Is in Data Extract mode or detail mode?
        END LOOP; -- Documents have no tracing info genreated
    END IF; -- Should generate tracing info?

END CreateCostMappingTracing;



PROCEDURE ConfigureCostMappingTracingRep(p_document_key                 VARCHAR2,
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
        lv2_rep_group_code := 'JOURNAL_MAP_TRACING_DEF';
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
        (
         NVL( ec_ctrl_system_attribute.attribute_text(Ecdp_Timestamp.getCurrentSysdate, 'DEFAULT_EC_RPT_SET_DATE', '<='),'2010-01-01T00:00:00'),
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
        RAISE_APPLICATION_ERROR(-20000, 'Can not configure Data Mapping Tracing Report, no report defination found for group ' || lv2_rep_group_code || '.');

END ConfigureCostMappingTracingRep;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : DsSourceSetup
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE DsSourceSetup(p_dataset VARCHAR2,
                      p_daytime DATE,
                      p_user_id VARCHAR2,
                      p_contract_group_id VARCHAR2,
                      p_contract_id VARCHAR2)
--</EC-DOC>
IS
BEGIN
    -- Call user-exit
    IF ue_RR_Revn_Mapping.isDsSourceSetupUEE = 'TRUE' THEN
        ue_RR_Revn_Mapping.DsSourceSetup(p_dataset, p_daytime, p_user_id,p_contract_group_id);
    END IF;
END DsSourceSetup;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : DsPostSetup
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE DsPostSetup(p_dataset VARCHAR2,
                    p_daytime DATE,
                    p_user_id VARCHAR2,
                    p_group_contract_id VARCHAR2 DEFAULT NULL,
                    p_contract_id VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS
BEGIN
    -- Call user-exit
    IF ue_RR_Revn_Mapping.isDsPostSetupUEE = 'TRUE' THEN
        ue_RR_Revn_Mapping.DsPostSetup(p_dataset, p_daytime, p_user_id);
    END IF;
END DsPostSetup;


FUNCTION CreateCostMappingLog(p_status         VARCHAR2,
                              p_description     VARCHAR2)
RETURN NUMBER
IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    ln_log_no NUMBER;
BEGIN

    ln_log_no := ECDP_REVN_LOG.CreateLog(COST_MAPPING_USER_LOG_NAME, p_status, p_description);

    COMMIT;

    RETURN ln_log_no;

END CreateCostMappingLog;

PROCEDURE UpdateCostMappingLog(p_log_no         NUMBER,
                               p_status         VARCHAR2,
                               p_description    VARCHAR2 DEFAULT NULL,
                               p_param_dataset  VARCHAR2 DEFAULT NULL,
                               p_param_period   DATE DEFAULT NULL)
IS
    PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

    ECDP_REVN_LOG.UpdateLog(p_log_no, p_status, p_description, NULL,
        p_param_dataset, NULL, NULL, NULL, NULL, p_param_period);

    COMMIT;

END UpdateCostMappingLog;


FUNCTION CreateCostMappingLogItem(p_log_no                  NUMBER,
                                  p_log_item_status         VARCHAR2,
                                  p_log_item_source         VARCHAR2,
                                  p_log_item_description    VARCHAR2,
                                  p_param_document_key      VARCHAR2)
RETURN NUMBER
IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    ln_log_item_no NUMBER;
BEGIN

    ln_log_item_no := ECDP_REVN_LOG.CreateLogItem(p_log_no, COST_MAPPING_USER_LOG_NAME,
        p_log_item_status, p_log_item_source, p_log_item_description, 'JOURNAL_MAP_LOG_LEVEL', p_param_document_key);

    COMMIT;

    RETURN ln_log_item_no;

END CreateCostMappingLogItem;



  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : InitNewCostMappingSource
  -- Description    : This Procedure copies  costmapping source set up from existing cost mapping to a new version of cost mapping.
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   :
  --
  -- Using functions:
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  -------------------------------------------------------------------------------------------------------------------------------------------

 PROCEDURE InitNewCostMappingSource(p_last_updated_by VARCHAR2,
                                     p_object_id       VARCHAR2,
                                     p_daytime         DATE DEFAULT NULL)

   IS

    CURSOR c_select(cp_cost_map_id VARCHAR2, cp_prev_daytime DATE) IS
      SELECT SRC_TYPE, OPERATOR, SRC_CODE, GROUP_NO, OBJECT_TYPE, SPLIT_KEY_SOURCE
        FROM cost_mapping_src_setup ss
       WHERE ss.object_id = cp_cost_map_id
       AND ss.daytime = cp_prev_daytime;
    lv1_prev_daytime  DATE;
    lv1_user          VARCHAR2(32);
    cost_map_id_not_provided EXCEPTION;

  BEGIN

    lv1_prev_daytime := ec_cost_mapping_version.prev_daytime(p_object_id,
                                                             p_daytime);
    lv1_user         := p_last_updated_by;
    IF p_object_id IS NULL THEN
      RAISE cost_map_id_not_provided;
    END IF;

    FOR cost_map_copy IN c_select(p_object_id, lv1_prev_daytime) LOOP
      -- DATASET --
      INSERT INTO COST_MAPPING_SRC_SETUP
        (OBJECT_ID,
         DAYTIME,
         SRC_TYPE,
         OPERATOR,
         SRC_CODE,
         OBJECT_TYPE,
         GROUP_NO,
		 SPLIT_KEY_SOURCE,
         COMMENTS)
      VALUES
        (p_object_id,
         p_daytime,
         cost_map_copy.SRC_TYPE,
         cost_map_copy.OPERATOR,
         cost_map_copy.SRC_CODE,
         cost_map_copy.OBJECT_TYPE,
         cost_map_copy.GROUP_NO,
         cost_map_copy.SPLIT_KEY_SOURCE,
         'Source mapping generated by copy for new version ' || lv1_user ||
         ' at ' || Ecdp_Timestamp.getCurrentSysdate || '.');
    END LOOP;

  EXCEPTION
    WHEN cost_map_id_not_provided THEN
      RAISE_APPLICATION_ERROR(-20000,
                              'Target Cost Mapping ID is not provided.');
  END InitNewCostMappingSource;


    -----------------------------------------------------------------------
    -- Initializes new journal mapping object.
    ----+----------------------------------+-------------------------------
    PROCEDURE InitializeNewJournalMapping(
         p_user_id                         VARCHAR2
        ,p_object_id                       VARCHAR2
        ,p_version                         DATE
        )
    IS
    BEGIN
          IF ec_cost_mapping_version.journal_entry_source(p_object_id,
                                                      p_version,
                                                      '<=') = 'CLASS' THEN
         InitClassMappingSetup(p_user_id, p_object_id, p_version);
         END IF;

    END InitializeNewJournalMapping;


    -----------------------------------------------------------------------
    -- Initializes new journal mapping version.
    ----+----------------------------------+-------------------------------
    PROCEDURE InitializeNewJournalMappingVer(
         p_user_id                         VARCHAR2
        ,p_object_id                       VARCHAR2
        ,p_new_version                     DATE DEFAULT NULL
        )
    IS
    BEGIN
        InitNewCostMappingSource(p_user_id, p_object_id, p_new_version);
        InitClassMappingSetup(p_user_id, p_object_id, p_new_version);

    END InitializeNewJournalMappingVer;

    -----------------------------------------------------------------------
    -- Generates class mapping setups for the specified journal mapping
    -- version.
    ----+----------------------------------+-------------------------------
    PROCEDURE InitClassMappingSetup(
         p_user_id                          VARCHAR2
        ,p_object_id                        VARCHAR2
        ,p_daytime                          DATE DEFAULT NULL
        )
    IS
        lv1_prev_daytime  DATE;
        lv1_user          VARCHAR2(32);
        cost_map_id_not_provided EXCEPTION;

    BEGIN
      lv1_prev_daytime := ec_cost_mapping_version.prev_daytime(p_object_id, p_daytime);

      DELETE FROM JOURNAL_MAPPING_DATA_EXT
      WHERE OBJECT_ID = p_object_id AND DAYTIME = p_daytime;

      DELETE FROM JOURNAL_MAP_DATA_EXT_SETUP
      WHERE OBJECT_ID = p_object_id AND DAYTIME = p_daytime;

      IF lv1_prev_daytime IS NULL THEN
          INSERT INTO JOURNAL_MAPPING_DATA_EXT (OBJECT_ID, DAYTIME, REVN_DATA_FILTER_ID, EXTRACT_VALUE_TYPE, EXTRACT_ATTRIBUTE, CREATED_BY)
          SELECT p_object_id, p_daytime, NULL, NULL, NULL, p_user_id
          FROM DUAL;

      ELSE
          INSERT INTO JOURNAL_MAPPING_DATA_EXT (OBJECT_ID, DAYTIME, REVN_DATA_FILTER_ID, EXTRACT_VALUE_TYPE, EXTRACT_ATTRIBUTE, CREATED_BY)
          SELECT OBJECT_ID, p_daytime, REVN_DATA_FILTER_ID, EXTRACT_VALUE_TYPE, EXTRACT_ATTRIBUTE, p_user_id
          FROM JOURNAL_MAPPING_DATA_EXT
          WHERE OBJECT_ID = p_object_id AND DAYTIME = lv1_prev_daytime;

          INSERT INTO JOURNAL_MAP_DATA_EXT_SETUP (OBJECT_ID, DAYTIME, PARAMETER_NAME, VALUE_CATEGORY, VALUE, CREATED_BY)
          SELECT OBJECT_ID, p_daytime, PARAMETER_NAME, VALUE_CATEGORY, VALUE, p_user_id
          FROM JOURNAL_MAP_DATA_EXT_SETUP
          WHERE OBJECT_ID = p_object_id AND DAYTIME = lv1_prev_daytime;

      END IF;

    END InitClassMappingSetup;



 --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function      : GetSplitKeyShare
  -- Description    : This Function gets the split key share for each cost mapping.
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   :
  --
  -- Using functions:
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  -------------------------------------------------------------------------------------------------------------------------------------------


 FUNCTION GetSplitKeyShare(p_split_item_other_id VARCHAR2, p_split_key_id VARCHAR2)
    RETURN VARCHAR2
   IS
    CURSOR c_select(cp_split_item_other_id VARCHAR2 , cp_split_key_id VARCHAR2) IS
      SELECT SPLIT_SHARE_MTH
        FROM split_key_setup ss
       WHERE ss.SPLIT_MEMBER_ID = cp_split_item_other_id
       and ss.object_id = cp_split_key_id
       AND ss.class_name = 'SPLIT_SPLIT_ITEM_OTHER';

    BEGIN
      FOR cost_map_copy IN c_select(p_split_item_other_id,p_split_key_id) LOOP

        RETURN cost_map_copy.SPLIT_SHARE_MTH*100;
         END LOOP;


    RETURN NULL;
    END GetSplitKeyShare;






 --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function      : GetAllSourceCodes
  -- Description    : This Function gets all teh source codes depending on teh code type
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   :
  --
  -- Using functions:
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  -------------------------------------------------------------------------------------------------------------------------------------------


 --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function      : GetAllSourceCodes
  -- Description    : This Function gets all teh source codes depending on teh code type
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   :
  --
  -- Using functions:
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  -------------------------------------------------------------------------------------------------------------------------------------------



FUNCTION GetAllSourceCodes(
  p_code_type              varchar2,
  p_je_numbers             varchar2)
  return T_TABLE_VARCHAR2
is

begin
      if p_code_type LIKE 'FIN_WBS' then
          return GetAllWbsCodes(p_je_numbers);
      end if;
      if p_code_type LIKE 'FIN_ACCOUNT' then
          return GetAllAccountCodes(p_je_numbers);
      end if;
      if p_code_type LIKE 'FIN_COST_CENTER' then
          return GetAllCostCenterCodes(p_je_numbers);
      end if;
      if p_code_type LIKE 'DOCUMENT_TYPE' then
          return GetAllDocumentTypeCodes(p_je_numbers);
      end if;
      if p_code_type LIKE 'EXPENDITURE_TYPE' then
          return GetAllExpenditureTypeCodes(p_je_numbers);
      end if;
      if p_code_type LIKE 'DATASET' then
          return GetAllDatasetCodes(p_je_numbers);
      end if;
         if p_code_type LIKE 'CONTRACT' then
          return GetAllContractCodes(p_je_numbers);
      end if;
    return null;
end;







 --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function      : GetAllWbsCodes
  -- Description    : This Function gets all wbs codes from ifac_journal_entry depnding on teh input Data entry numbers
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   :
  --
  -- Using functions:
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  -------------------------------------------------------------------------------------------------------------------------------------------





 --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function      : GetAllRevOrderCodes
  -- Description    : This Function gets all wbs codes from ifac_journal_entry depnding on teh input Data entry numbers
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   :
  --
  -- Using functions:
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  -------------------------------------------------------------------------------------------------------------------------------------------



FUNCTION GetAllRevOrderCodes(p_je_numbers             varchar2)
  return T_TABLE_VARCHAR2
is


CURSOR get_rev_order(cp_journal_entry_keys varchar2) is
select distinct (fin_revenue_order_code) from ifac_journal_entry
where journal_entry_no in
(select to_number(column_value) from table(ecdp_revn_common.SplitStrByComma(cp_journal_entry_keys)));

lt_rev_order   T_TABLE_VARCHAR2;
je_number_not_provided EXCEPTION;

BEGIN

  IF p_je_numbers IS NULL or p_je_numbers ='' or p_je_numbers ='null' THEN
    RAISE je_number_not_provided;
  END IF;

      lt_rev_order := new T_TABLE_VARCHAR2();
      FOR src_map_rev_order IN get_rev_order(p_je_numbers) LOOP
       lt_rev_order.extend(1);
       lt_rev_order(lt_rev_order.count) := src_map_rev_order.fin_revenue_order_code;
      END LOOP;
      return lt_rev_order;

exception
WHEN je_number_not_provided THEN
  RAISE_APPLICATION_ERROR(-20001, 'No Records were selected. Please close and check at least one record before handling variances') ;

end;


 --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function      : GetAllWbsCodes
  -- Description    : This Function gets all wbs codes from ifac_journal_entry depnding on teh input Data entry numbers
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   :
  --
  -- Using functions:
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  -------------------------------------------------------------------------------------------------------------------------------------------



FUNCTION GetAllWbsCodes(p_je_numbers             varchar2)
  return T_TABLE_VARCHAR2
is


CURSOR get_wbs(cp_journal_entry_keys varchar2) is
select distinct (fin_wbs_code) from ifac_journal_entry
where journal_entry_no in
(select to_number(column_value) from table(ecdp_revn_common.SplitStrByComma(cp_journal_entry_keys)));

lt_wbs   T_TABLE_VARCHAR2;
je_number_not_provided EXCEPTION;

BEGIN

  IF p_je_numbers IS NULL or p_je_numbers ='' or p_je_numbers ='null' THEN
    RAISE je_number_not_provided;
  END IF;

      lt_wbs := new T_TABLE_VARCHAR2();
      FOR src_map_wbs IN get_wbs(p_je_numbers) LOOP
       lt_wbs.extend(1);
       lt_wbs(lt_wbs.count) := src_map_wbs.fin_wbs_code;
      END LOOP;
      return lt_wbs;

exception
WHEN je_number_not_provided THEN
  RAISE_APPLICATION_ERROR(-20001, 'No Records were selected. Please close and check at least one record before handling variances') ;

end;



 --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function      : GetAllAccountCodes
  -- Description    : This Function gets all account codes from ifac_journal_entry depnding on teh input Data entry numbers
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   :
  --
  -- Using functions:
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  -------------------------------------------------------------------------------------------------------------------------------------------


 --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function      : GetAllAccountCodes
  -- Description    : This Function gets all account codes from ifac_journal_entry depnding on teh input Data entry numbers
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   :
  --
  -- Using functions:
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  -------------------------------------------------------------------------------------------------------------------------------------------



FUNCTION GetAllAccountCodes(p_je_numbers             varchar2)
  return T_TABLE_VARCHAR2
is

CURSOR get_fin_account(cp_journal_entry_keys varchar2) is
select distinct fin_account_code from ifac_journal_entry where journal_entry_no in (select to_number(column_value) from table(ecdp_revn_common.SplitStrByComma(cp_journal_entry_keys)));

lt_account   T_TABLE_VARCHAR2;
begin
      lt_account := new T_TABLE_VARCHAR2();
      FOR src_fin_account IN get_fin_account(p_je_numbers) LOOP
       lt_account.extend(1);
       lt_account(lt_account.count) := src_fin_account.fin_account_code;
      END LOOP;

      return lt_account;
end;



 --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function      : GetAllCostCenterCodes
  -- Description    : This Function gets all cost center codes from ifac_journal_entry depnding on teh input Data entry numbers
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   :
  --
  -- Using functions:
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  -------------------------------------------------------------------------------------------------------------------------------------------

FUNCTION GetAllCostCenterCodes(p_je_numbers             varchar2)
  return T_TABLE_VARCHAR2
is
 CURSOR get_cost_center(cp_journal_entry_keys varchar2) is
 select distinct fin_cost_center_code from ifac_journal_entry where journal_entry_no in (select to_number(column_value) from table(ecdp_revn_common.SplitStrByComma(cp_journal_entry_keys)));
 lt_cost_center   T_TABLE_VARCHAR2;
begin
      lt_cost_center := new T_TABLE_VARCHAR2();
      FOR src_map_cost_center IN get_cost_center(p_je_numbers) LOOP
       lt_cost_center.extend(1);
       lt_cost_center(lt_cost_center.count) := src_map_cost_center.fin_cost_center_code;
      END LOOP;

      return lt_cost_center;
end;



 --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function      : GetAllDatasetCodes
  -- Description    : This Function gets all dataset codes from ifac_journal_entry depnding on teh input Data entry numbers
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   :
  --
  -- Using functions:
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  -------------------------------------------------------------------------------------------------------------------------------------------



 --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function      : GetAllDatasetCodes
  -- Description    : This Function gets all dataset codes from ifac_journal_entry depnding on teh input Data entry numbers
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   :
  --
  -- Using functions:
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  -------------------------------------------------------------------------------------------------------------------------------------------


FUNCTION GetAllDatasetCodes(p_je_numbers             varchar2)
  return T_TABLE_VARCHAR2
is
CURSOR get_dataset(cp_journal_entry_keys varchar2) is
select distinct dataset from ifac_journal_entry where journal_entry_no in (select to_number(column_value) from table(ecdp_revn_common.SplitStrByComma(cp_journal_entry_keys)));
lt_dataset   T_TABLE_VARCHAR2;
begin
      lt_dataset := new T_TABLE_VARCHAR2();
      FOR src_map_dataset IN get_dataset(p_je_numbers) LOOP
        lt_dataset.extend(1);
        lt_dataset(lt_dataset.count) :=src_map_dataset.dataset;
      END LOOP;
return lt_dataset;
end;


 --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function      : GetAllDocumentTypeCodes
  -- Description    : This Function gets all document type codes from ifac_journal_entry depnding on teh input Data entry numbers
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   :
  --
  -- Using functions:
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  -------------------------------------------------------------------------------------------------------------------------------------------

 --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function      : GetAllDocumentTypeCodes
  -- Description    : This Function gets all document type codes from ifac_journal_entry depnding on teh input Data entry numbers
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   :
  --
  -- Using functions:
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  -------------------------------------------------------------------------------------------------------------------------------------------

FUNCTION GetAllDocumentTypeCodes(p_je_numbers             varchar2)
  return T_TABLE_VARCHAR2
is

CURSOR get_doc_type(cp_journal_entry_keys varchar2) is
select distinct document_type from ifac_journal_entry where journal_entry_no in (select to_number(column_value) from table(ecdp_revn_common.SplitStrByComma(cp_journal_entry_keys)));
lt_doc_type   T_TABLE_VARCHAR2;
begin
      lt_doc_type := new T_TABLE_VARCHAR2();
      FOR src_map_doc_type IN get_doc_type(p_je_numbers) LOOP
        lt_doc_type.extend(1);
        lt_doc_type(lt_doc_type.count) :=src_map_doc_type.document_type;
      END LOOP;

      return lt_doc_type;
end;


 --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function      : GetAllExpenditureTypeCodes
  -- Description    : This Function gets all expenditure type codes from ifac_journal_entry depnding on teh input Data entry numbers
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   :
  --
  -- Using functions:
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  -------------------------------------------------------------------------------------------------------------------------------------------


FUNCTION GetAllExpenditureTypeCodes(p_je_numbers             varchar2)
  return T_TABLE_VARCHAR2
is
CURSOR get_expenditure(cp_journal_entry_keys varchar2) is
select distinct expenditure_type from ifac_journal_entry where journal_entry_no in (select to_number(column_value) from table(ecdp_revn_common.SplitStrByComma(cp_journal_entry_keys)));
lt_expenditure_type   T_TABLE_VARCHAR2;
begin
      lt_expenditure_type := new T_TABLE_VARCHAR2();
      FOR src_map_expenditure IN get_expenditure(p_je_numbers) LOOP
        lt_expenditure_type.extend(1);
        lt_expenditure_type(lt_expenditure_type.count) :=src_map_expenditure.expenditure_type;
      END LOOP;

      return lt_expenditure_type;
end;


 --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function      : GetAllContractCodes
  -- Description    : This Function gets all contract codes from ifac_journal_entry depnding on teh input Data entry numbers
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   :
  --
  -- Using functions:
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  -------------------------------------------------------------------------------------------------------------------------------------------

FUNCTION GetAllContractCodes(p_je_numbers             varchar2)
  return T_TABLE_VARCHAR2
is
CURSOR get_contract(cp_journal_entry_keys varchar2) is
select distinct contract_code from ifac_journal_entry where journal_entry_no in (select to_number(column_value) from table(ecdp_revn_common.SplitStrByComma(cp_journal_entry_keys)));
lt_contract   T_TABLE_VARCHAR2;
begin
      lt_contract := new T_TABLE_VARCHAR2();
      FOR src_map_contract IN get_contract(p_je_numbers) LOOP
        lt_contract.extend(1);
        lt_contract(lt_contract.count) :=src_map_contract.contract_code;
      END LOOP;

      return lt_contract;
end;


 --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function      : GetAllExpenditureTypeCodes
  -- Description    : This Function gets all expenditure type codes from ifac_journal_entry depnding on teh input Data entry numbers
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   :
  --
  -- Using functions:
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  -------------------------------------------------------------------------------------------------------------------------------------------




 --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function      : GetObjectsList
  -- Description    : This Function gets the source mapping object list
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   :
  --
  -- Using functions:
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  -------------------------------------------------------------------------------------------------------------------------------------------

FUNCTION GetCMObjectsList (p_type VARCHAR2
                        ,p_object_id       VARCHAR2,
                         p_daytime         DATE,
                         p_missing         VARCHAR2)
RETURN varchar2 IS
       p_object_list_id VARCHAR2(32);
       lo_je_wbs        T_TABLE_VARCHAR2;
       CURSOR c_items (cp_object_id varchar2, cp_daytime date,cp_type varchar2 ) is
       Select ec_object_list.object_id_by_uk((src_code)) object_id
            from cost_mapping_src_setup  cmss,
                 cost_mapping cm,
                 (select ol.object_code
                    FROM
                         object_list_setup ols,
                         object_list ol
                   WHERE ols.object_id = ol.object_id
                     AND ols.daytime <= cp_daytime
                     AND ols.generic_class_name = p_type
                     AnD lo_je_wbs(lo_je_wbs.FIRSt) = ols.generic_object_code
                     AND nvl(ols.end_date,cp_daytime +1 ) > cp_daytime) list
           where cm.object_id = cp_object_id
             AND cm.object_id = cmss.object_id
             and nvl(cm.end_date,cp_daytime+1) > cp_daytime
             and cmss.daytime <= cp_daytime
             AND OBJECT_TYPE = 'OBJECT_LIST'
             AND cmss.operator in ('EXISTS', 'IN')
             AND cmss.src_code = list.object_code(+)
             AND list.object_code is null
             and src_type = cp_type
             order by cmss.group_no;

  BEGIN
       IF p_missing IS NOT NULL THEN
           lo_je_wbs            := T_TABLE_VARCHAR2();
           lo_je_wbs := ecdp_revn_common.SplitStrByComma(p_missing);

          -- find an object list where the first missing item is not in the list to recommend to add to

          FOR i in c_items(p_object_id,p_daytime,p_type) loop
              p_object_list_id := i.object_id;
              exit;
          end loop;

         --If no list found see if there are mappings direct to items
         IF p_object_list_id is null  THEN
             Select max(src_code) INTO p_object_list_id
                    from cost_mapping_src_setup  cmss,
                         cost_mapping cm
                   where cm.object_id = p_object_id
                    -- and  nvl(cmss.end_date,p_daytime+1) > p_daytime
                     and daytime <= p_daytime
                     and nvl(cm.end_date,p_daytime+1) > p_daytime
                     AND OBJECT_TYPE = 'OBJECT'
                     AND cmss.operator = 'EQUALS'
                     and src_type = p_type;

             IF p_object_list_id IS NOT NULL THEN
               p_object_list_id := 'DIRECT';
             END IF;
         END IF;
   END IF;

    RETURN p_object_list_id;

END GetCMObjectsList;


FUNCTION GetAction(p_missing_items varchar2, p_recommended_list varchar2,p_object_type boolean) return varchar2
  is
  lv2_action VARCHAR2(32);
begin
      IF p_missing_items is not null then
        if p_recommended_list is not null then
          if p_recommended_list != 'DIRECT' and p_object_type THEN
             lv2_action := 'USE_LIST_ADD_MISSING';
          else
             lv2_action := 'ADD_MISSING';
          END IF;
        END IF;
      END IF;
      RETURN lv2_action;

END GetAction;

PROCEDURE UpdateTable(p_source_mapping_keys IN OUT NOCOPY T_TABLE_MIXED_DATA,
                  p_object_id VARCHAR2,
                  p_daytime DATE,
                  p_class varchar2,
                  p_type varchar2,
                  p_list t_table_varchar2,
                  p_object_type BOOLEAN default true) IS

      lv2_missing_items      varchar2(240);
      lv2_recommended_list   varchar2(240);
      lv2_list               varchar2(240);
      lv2_action             varchar2(32);
 Begin
      lv2_missing_items      := GetMissingItems(p_list,p_object_id,p_daytime,p_class);
      lv2_recommended_list   := GetCMObjectsList(p_class,p_object_id,p_daytime,lv2_missing_items);
      lv2_action             := getAction(lv2_missing_items,lv2_recommended_list, p_object_type) ;
      IF lv2_action = 'ADD_MISSING' THEN
        lv2_recommended_list := NULL;
      END IF;

        p_source_mapping_keys.EXTEND(1);
        p_source_mapping_keys(p_source_mapping_keys.LAST) := T_MIXED_DATA(p_type, NULL);
        p_source_mapping_keys(p_source_mapping_keys.LAST).TEXT_3 := lv2_list;
        p_source_mapping_keys(p_source_mapping_keys.LAST).TEXT_1 := p_type;
        p_source_mapping_keys(p_source_mapping_keys.LAST).TEXT_2 := lv2_missing_items;
        p_source_mapping_keys(p_source_mapping_keys.LAST).TEXT_4 := lv2_recommended_list;
        p_source_mapping_keys(p_source_mapping_keys.LAST).TEXT_5 := lv2_action;
        p_source_mapping_keys(p_source_mapping_keys.LAST).TEXT_6 := p_class;
END  UpdateTable;

 --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function      : GetSourceMappingData
  -- Description    : This Function gets the source mapping data for variance handling screen
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   :
  --
  -- Using functions:
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  -------------------------------------------------------------------------------------------------------------------------------------------


FUNCTION GetSourceMappingData (p_journal_entry_keys VARCHAR2 ,
                               p_object_id       VARCHAR2,
                               p_daytime         DATE DEFAULT NULL)
RETURN T_TABLE_MIXED_DATA
IS

    lt_source_mapping_keys T_TABLE_MIXED_DATA;
      lv2_class               varchar2(32);
      lv2_missing_items      varchar2(32);
      lv2_recommended_list   varchar2(32);
      lv2_type               varchar2(32);
      lt_list                t_table_varchar2;
      lv2_action             varchar2(32);
BEGIN
    lt_source_mapping_keys := T_TABLE_MIXED_DATA();
    lt_list                := T_TABLE_VARCHAR2();

	    lv2_class              := 'FIN_WBS';
      lv2_type               :=  'WBS';
      lt_list                := GetAllWbsCodes(p_journal_entry_keys);
      UpdateTable(lt_source_mapping_keys,p_object_id,p_daytime,lv2_class,lv2_type,lt_list);

      lv2_class              := 'FIN_ACCOUNT';
      lv2_type               :=  'Account';
      lt_list                := GetAllAccountCodes(p_journal_entry_keys);
      UpdateTable(lt_source_mapping_keys,p_object_id,p_daytime,lv2_class,lv2_type,lt_list);

      lv2_class              := 'FIN_COST_CENTER';
      lv2_type               :=  'Cost Centre';
      lt_list                := GetAllCostCenterCodes(p_journal_entry_keys);
      UpdateTable(lt_source_mapping_keys,p_object_id,p_daytime,lv2_class,lv2_type,lt_list);

      lv2_class              := 'DOCUMENT_TYPE';
      lv2_type               :=  'Document Type';
      lt_list                := GetAllDocumentTypeCodes(p_journal_entry_keys);
      UpdateTable(lt_source_mapping_keys,p_object_id,p_daytime,lv2_class,lv2_type,lt_list);

      lv2_class              := 'DATASET';
      lv2_type               :=  'Dataset';
      lt_list                := GetAllDatasetCodes(p_journal_entry_keys);
      UpdateTable(lt_source_mapping_keys,p_object_id,p_daytime,lv2_class,lv2_type,lt_list,false);

      lv2_class              := 'PROJECT';
      lv2_type               := 'Project';
      lt_list                := GetAllContractCodes(p_journal_entry_keys);
      UpdateTable(lt_source_mapping_keys,p_object_id,p_daytime,lv2_class,lv2_type,lt_list);

      lv2_class              := 'FIN_REVENUE_ORDER';
      lv2_type               := 'Revenue Order';
      lt_list                := GetAllRevOrderCodes(p_journal_entry_keys);
      UpdateTable(lt_source_mapping_keys,p_object_id,p_daytime,lv2_class,lv2_type,lt_list);

      lv2_class              := 'EXPENDITURE_TYPE';
      lv2_type               := 'Expenditure Type';
      lt_list                := GetAllExpenditureTypeCodes(p_journal_entry_keys);
      UpdateTable(lt_source_mapping_keys,p_object_id,p_daytime,lv2_class,lv2_type,lt_list,false);

    RETURN lt_source_mapping_keys;
END GetSourceMappingData;




 --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function      : GetSourceObjectListPopupValues
  -- Description    : This Function gets the source mobject list popup values and do the necessary action
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   :
  --
  -- Using functions:
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  -------------------------------------------------------------------------------------------------------------------------------------------


     FUNCTION GetSourceObjectListPopupValues(    p_action                           VARCHAR2
                                                ,p_source_OBJECT_type             VARCHAR2
                                                ,p_group_no_to_check               cost_mapping_src_setup.group_no%TYPE
                                                ,p_source_DATA_type             cost_mapping_src_setup.src_type%TYPE
                                                ,p_daytime                       cost_mapping_src_setup.daytime%TYPE
        )
        RETURN T_TABLE_VARCHAR2
        IS
             temp                      T_TABLE_VARCHAR2;

        BEGIN
        temp := T_TABLE_VARCHAR2();
        IF (p_action = 'USE_LIST' or p_action = 'USE_LIST_ADD_ALL' or p_action = 'USE_LIST_ADD_MISSING') THEN
           return GetObjectList(p_source_DATA_type,p_daytime);
        END IF ;
        IF (p_action = 'ADD_ALL' or p_action = 'ADD_MISSING' ) THEN
                     temp.extend(1);
                     temp(temp.count) := 'No Action required';
                     RETURN temp;
        END IF ;
                      temp.extend(1);
                      temp(temp.count) :='Please add a new Object List Name';
        RETURN temp;
        END GetSourceObjectListPopupValues;



 --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function      : GetObjectList
  -- Description    : This Function returns object list based on the input for example if the p_src_datatype = WBS it will return all teh objects lists of type FIN_WBS
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   :
  --
  -- Using functions:
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  -------------------------------------------------------------------------------------------------------------------------------------------


     FUNCTION GetObjectList(   p_src_datatype                        VARCHAR2,
                               p_daytime                               DATE)
     RETURN T_TABLE_VARCHAR2
     IS
       CURSOR get_obj_list(cp_src_datatype varchar2 , cp_daytime date) is
       SELECT o.object_code as object_code
       FROM object_list o, object_list_version v
       WHERE o.object_id = v.object_id
       AND v.class_name LIKE '%' || cp_src_datatype ||'%'
       AND v.daytime >= o.start_date
       AND v.daytime < nvl(o.end_date, v.daytime + 1);
       lt_obj_list            T_TABLE_VARCHAR2;
       temp_src_datatype      VARCHAR2(32);

     BEGIN
       temp_src_datatype := upper(p_src_datatype);
       lt_obj_list := T_TABLE_VARCHAR2();
       FOR src_obj_list IN get_obj_list(temp_src_datatype,p_daytime) LOOP
       lt_obj_list.extend(1);
       lt_obj_list(lt_obj_list.count) := src_obj_list.object_code;
      END LOOP;
      RETURN lt_obj_list;
     END ;



    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION GetSourceMappingSetup_P(
         p_journal_mapping_id              cost_mapping.object_id%TYPE
        ,p_journal_mapping_daytime         cost_mapping_version.daytime%TYPE
        ,p_source_mapping_type             cost_mapping_src_setup.src_type%TYPE
        ,p_group_no                        cost_mapping_src_setup.group_no%TYPE
        )
    RETURN T_TABLE_MAPPING_SOURCE_SETUP
    IS
        CURSOR lc_source_mapping_setups(
            cp_journal_mapping_id          cost_mapping.object_id%TYPE
           ,cp_journal_mapping_daytime     cost_mapping_version.daytime%TYPE
           ,cp_source_mapping_type         cost_mapping_src_setup.src_type%TYPE
           ,cp_group_no                    cost_mapping_src_setup.group_no%TYPE)
        IS
            SELECT *
            FROM cost_mapping_src_setup
            WHERE cost_mapping_src_setup.object_id = cp_journal_mapping_id
                AND cost_mapping_src_setup.daytime = cp_journal_mapping_daytime
                AND cost_mapping_src_setup.src_type = cp_source_mapping_type
                AND cost_mapping_src_setup.group_no = cp_group_no
            ORDER BY cost_mapping_src_setup.src_code;

        lo_source_mappings T_TABLE_MAPPING_SOURCE_SETUP;
    BEGIN
        OPEN lc_source_mapping_setups(
             p_journal_mapping_id
            ,p_journal_mapping_daytime
            ,p_source_mapping_type
            ,p_group_no);

        FETCH lc_source_mapping_setups BULK COLLECT INTO lo_source_mappings;
        CLOSE lc_source_mapping_setups;

        RETURN lo_source_mappings;
    END GetSourceMappingSetup_P;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION GetSourceMappingReconcilStatus(
         p_object_codes                    IN OUT NOCOPY T_TABLE_VARCHAR2
        ,p_journal_mapping_id              cost_mapping.object_id%TYPE
        ,p_journal_mapping_daytime         cost_mapping_version.daytime%TYPE
        ,p_source_mapping_type             cost_mapping_src_setup.src_type%TYPE
        ,p_group_no_to_check               cost_mapping_src_setup.group_no%TYPE
        ,p_missing_object_codes            OUT NOCOPY T_TABLE_VARCHAR2
        )
    RETURN VARCHAR2
    IS
        lo_source_mappings T_TABLE_MAPPING_SOURCE_SETUP;
    BEGIN
        p_missing_object_codes := T_TABLE_VARCHAR2();
        lo_source_mappings := GetSourceMappingSetup_P(p_journal_mapping_id, p_journal_mapping_daytime, p_source_mapping_type, p_group_no_to_check);
        p_missing_object_codes := GetUnhandledCodeFromMapSetup(p_object_codes, p_source_mapping_type, p_group_no_to_check, lo_source_mappings);

        IF p_missing_object_codes.count = 0
        THEN
              RETURN '';
        ELSE
              RETURN '' || ecdp_revn_common.Concat(p_missing_object_codes, ', ');
        END IF;

    END GetSourceMappingReconcilStatus;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION GetUnhandledCodeFromMapSetup(
         p_object_codes                    IN OUT NOCOPY T_TABLE_VARCHAR2
        ,p_journal_mapping_id              cost_mapping.object_id%TYPE
        ,p_journal_mapping_daytime         cost_mapping_version.daytime%TYPE
        ,p_source_mapping_type             cost_mapping_src_setup.src_type%TYPE
        ,p_group_no_to_check               cost_mapping_src_setup.group_no%TYPE
        )
    RETURN T_TABLE_VARCHAR2
     IS
        lo_source_mappings T_TABLE_MAPPING_SOURCE_SETUP;
     BEGIN
        lo_source_mappings := GetSourceMappingSetup_P(p_journal_mapping_id, p_journal_mapping_daytime, p_source_mapping_type, p_group_no_to_check);
        RETURN GetUnhandledCodeFromMapSetup(p_object_codes, p_source_mapping_type, p_group_no_to_check, lo_source_mappings);
    END GetUnhandledCodeFromMapSetup;



    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION GetUnhandledCodeFromMapSetup(
         p_object_codes                    IN OUT NOCOPY T_TABLE_VARCHAR2
        ,p_source_mapping_type             cost_mapping_src_setup.src_type%TYPE
        ,p_group_no_to_check               cost_mapping_src_setup.group_no%TYPE
        ,p_source_mapping_to_check         IN OUT NOCOPY T_TABLE_MAPPING_SOURCE_SETUP
        )
    RETURN T_TABLE_VARCHAR2
    IS
        lo_missing_object_codes T_TABLE_VARCHAR2;
        lo_current_source_mapping cost_mapping_src_setup%ROWTYPE;
        lb_found BOOLEAN;
    BEGIN
        lo_missing_object_codes := T_TABLE_VARCHAR2();
        IF p_object_codes.count = 0 THEN
            RETURN lo_missing_object_codes;
         END IF;

        FOR idx_object_codes IN p_object_codes.FIRST .. p_object_codes.LAST
        LOOP
            IF p_object_codes(idx_object_codes) IS NOT NULL
                AND LENGTH(p_object_codes(idx_object_codes)) > 0
            THEN
                lb_found := FALSE;

                IF p_source_mapping_to_check.COUNT > 0
                THEN
                    FOR idx_mapping_setup IN p_source_mapping_to_check.FIRST .. p_source_mapping_to_check.LAST
                    LOOP
                        lo_current_source_mapping := p_source_mapping_to_check(idx_mapping_setup);

                        IF lo_current_source_mapping.group_no = p_group_no_to_check
                            AND lo_current_source_mapping.src_type = p_source_mapping_type
                        THEN
                            IF lo_current_source_mapping.operator = 'IS_NOT_NULL'
                            THEN
                                lb_found := TRUE;
                            ELSIF lo_current_source_mapping.operator = 'IS_NULL'
                            THEN
                                NULL;
                            ELSIF lo_current_source_mapping.operator = 'EQUALS'
                            THEN
                                IF lo_current_source_mapping.object_type = ECDP_REVN_COMMON.gv2_value_category_object
                                    AND lo_current_source_mapping.src_code = p_object_codes(idx_object_codes)
                                THEN
                                    lb_found := TRUE;
                                END IF;
                            ELSIF lo_current_source_mapping.operator = 'LIKE'
                            THEN
                                IF lo_current_source_mapping.object_type = ECDP_REVN_COMMON.gv2_value_category_object
                                    AND lo_current_source_mapping.src_code LIKE p_object_codes(idx_object_codes)
                                THEN
                                    lb_found := TRUE;
                                END IF;
                            ELSIF lo_current_source_mapping.operator = 'NOT_EQUALS'
                            THEN
                                IF lo_current_source_mapping.object_type = ECDP_REVN_COMMON.gv2_value_category_object
                                    AND lo_current_source_mapping.src_code <> p_object_codes(idx_object_codes)
                                THEN
                                    lb_found := TRUE;
                                END IF;
                            ELSIF lo_current_source_mapping.operator = 'NOT_LIKE'
                            THEN
                                IF lo_current_source_mapping.object_type = ECDP_REVN_COMMON.gv2_value_category_object
                                    AND lo_current_source_mapping.src_code NOT LIKE p_object_codes(idx_object_codes)
                                THEN
                                    lb_found := TRUE;
                                END IF;
                            ELSIF lo_current_source_mapping.operator = 'IN'
                            THEN
                                IF (lo_current_source_mapping.object_type = ECDP_REVN_COMMON.gv2_value_category_object
                                        AND lo_current_source_mapping.src_code = p_object_codes(idx_object_codes))
                                    OR (lo_current_source_mapping.object_type = ECDP_REVN_COMMON.gv2_value_category_object_list
                                        AND EcDp_Object_List.IsInObjectList(p_object_codes(idx_object_codes), NULL, NULL, ecdp_revn_common.gv2_true, lo_current_source_mapping.src_code, lo_current_source_mapping.daytime) = ecdp_revn_common.gv2_true)
                                THEN
                                    lb_found := TRUE;
                                END IF;
                            ELSIF lo_current_source_mapping.operator = 'NOT_IN'
                            THEN
                                IF (lo_current_source_mapping.object_type = ECDP_REVN_COMMON.gv2_value_category_object
                                        AND lo_current_source_mapping.src_code <> p_object_codes(idx_object_codes))
                                    OR (lo_current_source_mapping.object_type = ECDP_REVN_COMMON.gv2_value_category_object_list
                                        AND EcDp_Object_List.IsInObjectList(p_object_codes(idx_object_codes), NULL, NULL, ecdp_revn_common.gv2_true, lo_current_source_mapping.src_code, lo_current_source_mapping.daytime) = ecdp_revn_common.gv2_true)
                                THEN
                                    lb_found := TRUE;
                                END IF;
                            END IF;

                            IF lb_found
                            THEN
                                EXIT;
                            END IF;

                        END IF;
                    END LOOP;
                END IF;

                IF NOT lb_found
                THEN
                    lo_missing_object_codes.extend;
                    lo_missing_object_codes(lo_missing_object_codes.last) := p_object_codes(idx_object_codes);
                END IF;

            END IF;
        END LOOP;

        RETURN lo_missing_object_codes;

    END GetUnhandledCodeFromMapSetup;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------

      PROCEDURE InsNewInObjectListSetUpAll(p_src_obj_list_name VARCHAR2,
                                             p_daytime         DATE DEFAULT NULL,
                                             p_src_all_codes_to_be_inserted VARCHAR2,
                                             p_src_type        VARCHAR2,
                                             p_journal_mapping_id VARCHAR2,
                                             p_jounal_entry_keys VARCHAR2
                                            )
      IS

        CURSOR isCodeInObjectList(cp_src_code varchar2,cp_object_code varchar2) is
        select count(*) as cnt from dv_object_list_setup
        where generic_object_code = cp_src_code and object_code = cp_object_code;
        lo_all_codes     T_TABLE_VARCHAR2;

       BEGIN
       lo_all_codes := new T_TABLE_VARCHAR2();

       lo_all_codes :=GetAllSourceCodes( p_src_type ,p_jounal_entry_keys);
        if ec_object_list.start_date(EC_OBJECT_LIST.object_id_by_uk(p_src_obj_list_name))> p_daytime then
          RAISE_APPLICATION_ERROR(-20001, 'The date given is before the state date of the object list ('|| ec_object_list.start_date(EC_OBJECT_LIST.object_id_by_uk(p_src_obj_list_name)) || '), this is not allowed. Please correct');
        END IF;

       FOR idx_all_codes IN lo_all_codes.FIRST .. lo_all_codes.LAST
        LOOP
        FOR cur_src IN isCodeInObjectList(lo_all_codes(idx_all_codes),p_src_obj_list_name) LOOP
         IF(  cur_src.cnt)  < 1 THEN
            if nvl(ecdp_objects.GetObjStartDate(ecdp_objects.GetObjIDFromCode(p_src_type,lo_all_codes(idx_all_codes))),p_daytime)> p_daytime then
              RAISE_APPLICATION_ERROR(-20001, 'The date given is before the state date of the object ('|| ecdp_objects.GetObjStartDate(ecdp_objects.GetObjIDFromCode(p_src_type,lo_all_codes(idx_all_codes))) || '), this is not allowed. Please correct');
            END IF;
         INSERT INTO DV_OBJECT_LIST_SETUP (OBJECT_CODE, DAYTIME, GENERIC_OBJECT_CODE, SORT_ORDER, GENERIC_CLASS_NAME, CREATED_BY,CREATED_DATE) VALUES (p_src_obj_list_name, p_daytime, lo_all_codes(idx_all_codes), 10, p_src_type,ecdp_context.getAppUser,ecdp_date_time.getCurrentSysdate);
         END IF;
        END LOOP;
        END LOOP;
      END InsNewInObjectListSetUpAll;


   -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------

      PROCEDURE InsNewInObjectListSetUpMissing(
         p_src_obj_list_id               VARCHAR2,
         p_daytime                         DATE DEFAULT NULL,
         p_src_all_codes_to_be_inserted    VARCHAR2,
         p_src_type                        VARCHAR2,
         p_journal_mapping_id              VARCHAR2,
         p_jounal_entry_keys               VARCHAR2
         )
      IS

        CURSOR isCodeInObjectList(cp_src_code varchar2,cp_object_id varchar2) is
        select count(*) as cnt from dv_object_list_setup
        where generic_object_code = cp_src_code and object_id = cp_object_id;
        lo_all_codes     T_TABLE_VARCHAR2;
        lo_all_codes_unhandled  T_TABLE_VARCHAR2;

       BEGIN

       lo_all_codes := new T_TABLE_VARCHAR2();
       lo_all_codes_unhandled := new T_TABLE_VARCHAR2();

       lo_all_codes :=GetAllSourceCodes( p_src_type ,p_jounal_entry_keys);

       lo_all_codes_unhandled :=GetUnhandledCodeFromMapSetup( lo_all_codes,p_journal_mapping_id,p_daytime ,p_src_type,1);

        IF ec_object_list.start_date(p_src_obj_list_id)> p_daytime then
          RAISE_APPLICATION_ERROR(-20001, 'The date given is before the state date of the object list ('|| ec_object_list.start_date(p_src_obj_list_id) || '), this is not allowed. Please correct');
        END IF;

       FOR idx_all_codes IN lo_all_codes_unhandled.FIRST .. lo_all_codes_unhandled.LAST
        LOOP

        FOR cur_src IN isCodeInObjectList(lo_all_codes_unhandled(idx_all_codes),p_src_obj_list_id) LOOP

         IF(  cur_src.cnt)  < 1 THEN
            if nvl(ecdp_objects.GetObjStartDate(ecdp_objects.GetObjIDFromCode(p_src_type,lo_all_codes(idx_all_codes))),p_daytime)> p_daytime then
              RAISE_APPLICATION_ERROR(-20001, 'The date given is before the state date of the object ('|| ecdp_objects.GetObjStartDate(ecdp_objects.GetObjIDFromCode(p_src_type,lo_all_codes(idx_all_codes))) || '), this is not allowed. Please correct');
            END IF;
         INSERT INTO DV_OBJECT_LIST_SETUP (OBJECT_ID, DAYTIME, GENERIC_OBJECT_CODE, SORT_ORDER, GENERIC_CLASS_NAME, CREATED_BY, CREATED_DATE) VALUES (p_src_obj_list_id, p_daytime, lo_all_codes_unhandled(idx_all_codes), 10, p_src_type,ecdp_context.getAppUser,ecdp_date_time.getCurrentSysdate);
         END IF;
        END LOOP;
        END LOOP;
      END InsNewInObjectListSetUpMissing;


   -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------



       PROCEDURE  AddNewJrnlMapSrcSetupForAll  (p_daytime                         DATE DEFAULT NULL,
         p_src_all_codes_to_be_inserted    VARCHAR2,
         p_src_type                        VARCHAR2,
         p_journal_mapping_id              VARCHAR2,
         p_comment                          VARCHAR2,
         p_user                             VARCHAR2,
         p_jounal_entry_keys               VARCHAR2
         )
          IS
       lo_all_codes  T_TABLE_VARCHAR2;
       BEGIN
       lo_all_codes := new T_TABLE_VARCHAR2();
       lo_all_codes :=GetAllSourceCodes( p_src_type ,p_jounal_entry_keys);

      /* lo_all_codes :=ecdp_revn_common.SplitStrByComma(p_src_all_codes_to_be_inserted);  */


       FOR idx_all_codes IN lo_all_codes.FIRST .. lo_all_codes.LAST
        LOOP
       INSERT INTO COST_MAPPING_SRC_SETUP (OBJECT_ID, DAYTIME,SPLIT_KEY_SOURCE,SRC_TYPE,OBJECT_TYPE,OPERATOR,SRC_CODE,GROUP_NO,COMMENTS,CREATED_BY) values (p_journal_mapping_id, p_daytime,'MAPPING_DEFAULT',p_src_type,'OBJECT','EQUALS',lo_all_codes(idx_all_codes),1,p_comment,p_user);
        END LOOP;
      END AddNewJrnlMapSrcSetupForAll;





   -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------



       PROCEDURE  AddNewJrnlMapSrcSetupForMiss  (p_daytime                         DATE DEFAULT NULL,
         p_src_all_codes_to_be_inserted    VARCHAR2,
         p_src_type                        VARCHAR2,
         p_journal_mapping_id              VARCHAR2,
         p_comment                          VARCHAR2,
         p_user                             VARCHAR2,
         p_jounal_entry_keys               VARCHAR2
         )
          IS
       lo_all_codes T_TABLE_VARCHAR2;
       lo_all_codes_unhandled T_TABLE_VARCHAR2;
       BEGIN
       lo_all_codes := new T_TABLE_VARCHAR2();
       lo_all_codes_unhandled := new T_TABLE_VARCHAR2();

       lo_all_codes :=GetAllSourceCodes( p_src_type ,p_jounal_entry_keys);
       /*lo_all_codes :=ecdp_revn_common.SplitStrByComma(p_src_all_codes_to_be_inserted);  */

       lo_all_codes_unhandled :=GetUnhandledCodeFromMapSetup( lo_all_codes,p_journal_mapping_id,p_daytime ,p_src_type,1);


       FOR idx_all_codes IN lo_all_codes_unhandled.FIRST .. lo_all_codes_unhandled.LAST
        LOOP
       INSERT INTO COST_MAPPING_SRC_SETUP (OBJECT_ID, DAYTIME,SPLIT_KEY_SOURCE,SRC_TYPE,OBJECT_TYPE,OPERATOR,SRC_CODE,GROUP_NO,COMMENTS,CREATED_BY) values (p_journal_mapping_id, p_daytime,'MAPPING_DEFAULT',p_src_type,'OBJECT','EQUALS',lo_all_codes_unhandled(idx_all_codes),1,p_comment,p_user);
        END LOOP;
      END AddNewJrnlMapSrcSetupForMiss;

	   -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------

      FUNCTION get_clob_col_split(P_cont_entry_no VARCHAR2)
      RETURN t_cont_split_method IS
         v_cont_split_method_data t_cont_split_method := t_cont_split_method();
         l_Index_count            NUMBER;
         l_Indx_count             NUMBER := 0;
         l_Index_count_old        NUMBER;
         TYPE clob_split_rec IS RECORD(clob_split_col VARCHAR2(1000));

         TYPE clob_split_t IS TABLE OF clob_split_rec INDEX BY BINARY_INTEGER;

         l_clob_split_t  clob_split_t;
         l_index_count_t NUMBER := 1;
         CURSOR c_split_clob_col(p_j_ent_no VARCHAR) IS
         WITH mapping_detail_split AS
        (SELECT split_source_method
           FROM cont_journal_entry a
          WHERE journal_entry_no = p_j_ent_no)
         SELECT to_char(regexp_substr(split_source_method, '[^|]+', 1, rownum)) result1
           FROM mapping_detail_split
         CONNECT BY LEVEL <= length(regexp_replace(split_source_method, '[^|]+')) + 1;



         FUNCTION count_indx(pno NUMBER) RETURN NUMBER AS
         BEGIN
         l_Indx_count      := pno + 1;
         l_Index_count_old := l_Indx_count;
         RETURN l_Indx_count;

         END;

      BEGIN

         OPEN c_split_clob_col(P_cont_entry_no);
         LOOP
          FETCH c_split_clob_col BULK COLLECT
          INTO l_clob_split_t;
          EXIT WHEN c_split_clob_col%NOTFOUND;
         END LOOP;



         l_Index_count := l_clob_split_t.count / 10;

         FOR l_index_table IN 1 .. l_Index_count LOOP
           v_cont_split_method_data.extend;
           v_cont_split_method_data(l_index_table) := t_cont_split_method_o(CASE
                                                                     WHEN l_clob_split_t.exists(count_indx(l_Indx_count)) THEN

                                                                      TRIM(l_clob_split_t(l_Index_count_old)
                                                                           .clob_split_col)
                                                                     ELSE
                                                                      NULL
                                                                   END,
                                                                   CASE
                                                                     WHEN l_clob_split_t.exists(count_indx(l_Indx_count)) THEN

                                                                      TRIM(ec_split_key_version.name(l_clob_split_t(l_Index_count_old)
                                                                                                     .clob_split_col,
                                                                                                     Ecdp_Timestamp.getCurrentSysdate,
                                                                                                     '<='))
                                                                     ELSE
                                                                      NULL
                                                                   END,
                                                                   CASE
                                                                     WHEN l_clob_split_t.exists(count_indx(l_Indx_count)) THEN

                                                                      TRIM(ecdp_objects.GetObjName(l_clob_split_t(l_Index_count_old)
                                                                                                   .clob_split_col,
                                                                                                   Ecdp_Timestamp.getCurrentSysdate))
                                                                     ELSE
                                                                      NULL
                                                                   END,
                                                                   CASE

                                                                     WHEN l_clob_split_t.exists(count_indx(l_Indx_count)) THEN

                                                                      TRIM(l_clob_split_t(l_Index_count_old)
                                                                           .clob_split_col)
                                                                     ELSE
                                                                      NULL
                                                                   END,
                                                                   CASE
                                                                     WHEN l_clob_split_t.exists(count_indx(l_Indx_count)) THEN

                                                                      TRIM(ec_object_list_version.name(l_clob_split_t(l_Index_count_old)
                                                                                                       .clob_split_col,
                                                                                                       Ecdp_Timestamp.getCurrentSysdate,
                                                                                                       '<='))

                                                                     ELSE
                                                                      NULL
                                                                   END,
                                                                   CASE
                                                                     WHEN l_clob_split_t.exists(count_indx(l_Indx_count)) THEN
                                                                      TRIM(l_clob_split_t(l_Index_count_old)
                                                                           .clob_split_col)
                                                                     ELSE
                                                                      NULL
                                                                   END,
                                                                   CASE
                                                                     WHEN l_clob_split_t.exists(count_indx(l_Indx_count)) THEN
                                                                      TRIM(l_clob_split_t(l_Index_count_old)
                                                                           .clob_split_col)
                                                                     ELSE
                                                                      NULL
                                                                   END,
                                                                   CASE

                                                                     WHEN l_clob_split_t.exists(count_indx(l_Indx_count)) THEN

                                                                     TRIM(ecdp_objects.GetObjName((l_clob_split_t(l_Index_count_old)
                                                                                                   .clob_split_col),Ecdp_Timestamp.getCurrentSysdate))
                                                                     ELSE
                                                                      NULL
                                                                   END,
                                                                   CASE
                                                                     WHEN l_clob_split_t.exists(count_indx(l_Indx_count)) THEN

                                                                      TRIM(l_clob_split_t(l_Index_count_old)
                                                                           .clob_split_col)
                                                                     ELSE
                                                                      NULL
                                                                   END,
                                                                   CASE
                                                                     WHEN l_clob_split_t.exists(count_indx(l_Indx_count)) THEN

                                                                      TRIM(l_clob_split_t(l_Index_count_old)
                                                                           .clob_split_col)
                                                                     ELSE
                                                                      NULL
                                                                   END);

         END LOOP;

         RETURN v_cont_split_method_data;
      END get_clob_col_split;

    -----------------------------------------------------------------------
    -- Initializes new report reference item mapping version.
    ----+----------------------------------+-------------------------------
    PROCEDURE InitializeNewRefltemMappingVer(
         p_user_id                         VARCHAR2
        ,p_object_id                       VARCHAR2
        ,p_new_version                     DATE DEFAULT NULL
        )
    IS
    BEGIN
        InitNewRefltemMappingSource(p_user_id, p_object_id, p_new_version);
        InitNewRefItemClassMapping(p_object_id, p_new_version);

    END InitializeNewRefltemMappingVer;

    ----------------------------------------------------------------------------------------------------------------------------
    -- This Procedure copies mapping source setups of a Report Reference Item from existing mapping to a new version of mapping
    ----------------------------------------------------------------------------------------------------------------------------

    PROCEDURE InitNewRefltemMappingSource(p_last_updated_by VARCHAR2,
                                          p_object_id       VARCHAR2,
                                          p_daytime         DATE DEFAULT NULL)

    IS

      CURSOR c_select(cp_cost_map_id VARCHAR2, cp_prev_daytime DATE) IS
        SELECT src_type, operator, src_code, group_no, object_type, split_key_source
          FROM report_ref_grp_src_setup
         WHERE object_id = cp_cost_map_id
           AND daytime = cp_prev_daytime;

      lv1_prev_daytime              DATE;
      lv1_user                      VARCHAR2(32);
      ref_item_map_id_not_provided  EXCEPTION;

    BEGIN

      lv1_prev_daytime := ec_report_ref_item_version.prev_daytime(p_object_id,
                                                                  p_daytime);
      lv1_user         := p_last_updated_by;

      IF p_object_id IS NULL THEN
        RAISE ref_item_map_id_not_provided;
      END IF;

      FOR ref_item_map_copy IN c_select(p_object_id, lv1_prev_daytime) LOOP
        -- DATASET --
        INSERT INTO report_ref_grp_src_setup
          (object_id,
           daytime,
           src_type,
           operator,
           src_code,
           object_type,
           group_no,
           split_key_source,
           comments)
        VALUES
          (p_object_id,
           p_daytime,
           ref_item_map_copy.src_type,
           ref_item_map_copy.operator,
           ref_item_map_copy.src_code,
           ref_item_map_copy.object_type,
           ref_item_map_copy.group_no,
           ref_item_map_copy.split_key_source,
           'Source mapping generated by copy for new version ' || lv1_user || ' at ' || Ecdp_Timestamp.getCurrentSysdate || '.');
      END LOOP;

    EXCEPTION
      WHEN ref_item_map_id_not_provided THEN
        RAISE_APPLICATION_ERROR(-20000,
                                'Target Report Reference Item Mapping ID is not provided.');
    END InitNewRefltemMappingSource;

    ----------------------------------------------------------------------------------------------------------------------------
    -- This Procedure generates class mapping setups of a Report Reference Item from existing mapping to a new version of mapping
    ----------------------------------------------------------------------------------------------------------------------------

    PROCEDURE InitNewRefItemClassMapping(
         p_object_id                        VARCHAR2
        ,p_daytime                          DATE DEFAULT NULL
        )
    IS

      CURSOR c_select(cp_cost_map_id VARCHAR2, cp_prev_daytime DATE) IS
        SELECT parameter_name, value_category, parameter_value
          FROM report_ref_grp_class_setup
         WHERE object_id = cp_cost_map_id
           AND daytime = cp_prev_daytime;

      lv1_prev_daytime              DATE;
      ref_item_map_id_not_provided  EXCEPTION;

    BEGIN

      lv1_prev_daytime := ec_report_ref_item_version.prev_daytime(p_object_id,
                                                                  p_daytime);

      IF p_object_id IS NULL THEN
        RAISE ref_item_map_id_not_provided;
      END IF;

      FOR ref_item_map_copy IN c_select(p_object_id, lv1_prev_daytime) LOOP
        -- DATASET --
        INSERT INTO report_ref_grp_class_setup
          (object_id,
           daytime,
           parameter_name,
           value_category,
           parameter_value)
        VALUES
          (p_object_id,
           p_daytime,
           ref_item_map_copy.parameter_name,
           ref_item_map_copy.value_category,
           ref_item_map_copy.parameter_value);
      END LOOP;

    EXCEPTION
      WHEN ref_item_map_id_not_provided THEN
        RAISE_APPLICATION_ERROR(-20000,
                                'Target Report Reference Item mapping ID is not provided.');

    END InitNewRefItemClassMapping;

    ----------------------------------------------------------------------------------------------------------------------------
    -- This Procedure checks whether the Report Reference is linked with a cost mapping or
    -- a report reference group item before updating the record.
    ----------------------------------------------------------------------------------------------------------------------------

    PROCEDURE CheckReportReferenceUse(
        p_object_id                       VARCHAR2
       ,p_daytime                         DATE
       ,p_dataset                         VARCHAR2
       )
    IS

      CURSOR c_cost_map(cp_object_id VARCHAR2, cp_daytime DATE, cp_dataset VARCHAR2) IS
      SELECT rr.code report_ref_code,
             cm.code cost_mapping_code,
             DECODE(ec.alt_code, 'REVN_PROD_STREAM', 'Product Stream','REVN_PROJECT','Project',NULL) map_type
        FROM ov_report_reference rr,
             ov_cost_mapping cm,
             prosty_codes ec
       WHERE rr.object_id = cm.report_ref_id
         AND rr.dataset = cm.trg_dataset
         AND cm.trg_dataset = ec.code
         AND ec.code_type = 'DATASET'
         AND rr.daytime BETWEEN cm.daytime AND NVL(cm.end_date - 1, rr.daytime + 1)
         AND rr.object_id = cp_object_id
         AND rr.daytime = cp_daytime
         AND rr.dataset <> cp_dataset;

      CURSOR c_ref_item(cp_object_id VARCHAR2, cp_daytime DATE, cp_dataset VARCHAR2) IS
      SELECT rr.code report_ref_code,
             ri.code ref_item_code
        FROM ov_report_reference rr,
             ov_report_ref_item ri
       WHERE rr.object_id = ri.report_ref_id
         AND rr.dataset = ri.dataset
         AND rr.daytime BETWEEN ri.daytime AND NVL(ri.end_date - 1, rr.daytime + 1)
         AND rr.object_id = cp_object_id
         AND rr.daytime = cp_daytime
         AND rr.dataset <> cp_dataset;

      report_ref_linked   EXCEPTION;
      lv_message          VARCHAR2(1000);
      r_cost_map          c_cost_map%ROWTYPE;
      r_ref_item          c_ref_item%ROWTYPE;

    BEGIN

      OPEN c_cost_map(p_object_id, p_daytime, p_dataset);
      FETCH c_cost_map INTO r_cost_map;
      IF c_cost_map%FOUND THEN
         lv_message := 'The record cannot be updated, Report Reference '
                       || r_cost_map.report_ref_code
                       || ' is linked with '
                       || r_cost_map.map_type
                       ||' Data Mapping Setup for Cost Mapping code '
                       || r_cost_map.cost_mapping_code
                       || '.';
        RAISE report_ref_linked;
      END IF;
      CLOSE c_cost_map;

      OPEN c_ref_item(p_object_id, p_daytime, p_dataset);
      FETCH c_ref_item INTO r_ref_item;
      IF c_ref_item%FOUND THEN
         lv_message := 'The record cannot be updated, Report Reference '
                       || r_ref_item.report_ref_code
                       || ' is linked with Report Reference Group Setup for Reference Item '
                       || r_ref_item.ref_item_code
                       || '.';
        RAISE report_ref_linked;
      END IF;
      CLOSE c_ref_item;

    EXCEPTION
      WHEN report_ref_linked THEN
        RAISE_APPLICATION_ERROR(-20000, lv_message);

    END CheckReportReferenceUse;

    ----------------------------------------------------------------------------------------------------------------------------
    -- This Procedure checks whether the Report Reference Group is linked with a cost mapping or
    -- a report reference group item before updating the record.
    ----------------------------------------------------------------------------------------------------------------------------

    PROCEDURE CheckReportReferenceGroupUse(
        p_object_id                       VARCHAR2
       ,p_daytime                         DATE
       ,p_dataset                         VARCHAR2
       )
    IS

      CURSOR c_cost_map(cp_object_id VARCHAR2, cp_daytime DATE, cp_dataset VARCHAR2) IS
      SELECT rr.code report_ref_group_code,
             cm.code cost_mapping_code,
             DECODE(ec.alt_code, 'REVN_PROD_STREAM', 'Product Stream','REVN_PROJECT','Project',NULL) map_type
        FROM ov_report_ref_group rr,
             ov_cost_mapping cm,
             prosty_codes ec
       WHERE rr.object_id = cm.report_ref_group_id
         AND rr.dataset = cm.trg_dataset
         AND cm.trg_dataset = ec.code
         AND ec.code_type = 'DATASET'
         AND rr.daytime BETWEEN cm.daytime AND NVL(cm.end_date - 1, rr.daytime + 1)
         AND rr.object_id = cp_object_id
         AND rr.daytime = cp_daytime
         AND rr.dataset <> cp_dataset;

      CURSOR c_ref_item(cp_object_id VARCHAR2, cp_daytime DATE, cp_dataset VARCHAR2) IS
      SELECT rr.code report_ref_group_code,
             ri.code ref_item_code
        FROM ov_report_ref_group rr,
             ov_report_ref_item ri
       WHERE rr.object_id = ri.report_ref_group_id
         AND rr.dataset = ri.dataset
         AND rr.daytime BETWEEN ri.daytime AND NVL(ri.end_date - 1, rr.daytime + 1)
         AND rr.object_id = cp_object_id
         AND rr.daytime = cp_daytime
         AND rr.dataset <> cp_dataset;

      report_ref_group_linked   EXCEPTION;
      lv_message                VARCHAR2(1000);
      r_cost_map                c_cost_map%ROWTYPE;
      r_ref_item                c_ref_item%ROWTYPE;

    BEGIN

      OPEN c_cost_map(p_object_id, p_daytime, p_dataset);
      FETCH c_cost_map INTO r_cost_map;
      IF c_cost_map%FOUND THEN
         lv_message := 'The record cannot be updated, Report Reference Group '
                       || r_cost_map.report_ref_group_code
                       || ' is linked with '
                       || r_cost_map.map_type
                       ||' Data Mapping Setup for Cost Mapping code '
                       || r_cost_map.cost_mapping_code
                       || '.';
        RAISE report_ref_group_linked;
      END IF;
      CLOSE c_cost_map;

      OPEN c_ref_item(p_object_id, p_daytime, p_dataset);
      FETCH c_ref_item INTO r_ref_item;
      IF c_ref_item%FOUND THEN
         lv_message := 'The record cannot be updated, Report Reference Group '
                       || r_ref_item.report_ref_group_code
                       || ' is linked with Report Reference Group Setup for Reference Item '
                       || r_ref_item.ref_item_code
                       || '.';
        RAISE report_ref_group_linked;
      END IF;
      CLOSE c_ref_item;

    EXCEPTION
      WHEN report_ref_group_linked THEN
        RAISE_APPLICATION_ERROR(-20000, lv_message);

    END CheckReportReferenceGroupUse;

    ----------------------------------------------------------------------------------------------------------------------------
    ---Returns object name for given code from v_cost_mapping_src_object
    ----------------------------------------------------------------------------------------------------------------------------

	FUNCTION get_cost_map_src_obj_name(p_code        VARCHAR2,
                                       p_object_type VARCHAR2,
                                       p_source_type VARCHAR2) RETURN VARCHAR2 IS
    l_name VARCHAR2(200);

     CURSOR c_mapping_src_obj(cp_code VARCHAR2, cp_object_type VARCHAR2, cp_source_type VARCHAR2)  IS
     SELECT name
       FROM v_cost_mapping_src_object
      WHERE code = cp_code
        AND object_type = cp_object_type
        AND source_type = cp_source_type;

    BEGIN

      OPEN c_mapping_src_obj(p_code, p_object_type, p_source_type) ;
      FETCH c_mapping_src_obj
       INTO l_name;
      CLOSE c_mapping_src_obj;

     RETURN l_name;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000,
                                'ERROR fetching Name for code ' ||
                                 p_code);
    END get_cost_map_src_obj_name;

    ----------------------------------------------------------------------------------------------------------------------------
    -- This Procedure checks whether the dataset linked with a Report Reference or Group is valid for the cost mapping or
    -- group item before updating the object start date or creating a new version of the mapping or group item
    ----------------------------------------------------------------------------------------------------------------------------

    PROCEDURE CheckValidMappingDataset(
        p_object_id                       VARCHAR2
       ,p_daytime                         DATE
       )
    IS

      CURSOR c_cost_map(cp_object_id VARCHAR2, cp_daytime DATE) IS
      SELECT rr.code, rr.daytime, rr.end_date, rr.dataset
        FROM ov_cost_mapping cm,
             ov_report_reference rr
       WHERE cm.object_id = p_object_id
         AND cm.report_ref_id = rr.object_id
         AND cm.trg_dataset <> rr.dataset
         AND p_daytime BETWEEN rr.daytime AND NVL(rr.end_date - 1, p_daytime + 1);

      CURSOR c_ref_item(cp_object_id VARCHAR2, cp_daytime DATE) IS
      SELECT rr.code, rr.daytime, rr.end_date, rr.dataset
        FROM ov_report_ref_item ri,
             ov_report_reference rr
       WHERE ri.object_id = p_object_id
         AND ri.report_ref_id = rr.object_id
         AND ri.dataset <> rr.dataset
         AND p_daytime BETWEEN rr.daytime AND NVL(rr.end_date - 1, p_daytime + 1);

      CURSOR c_cost_map_grp(cp_object_id VARCHAR2, cp_daytime DATE) IS
      SELECT rr.code, rr.daytime, rr.end_date, rr.dataset
        FROM ov_cost_mapping cm,
             ov_report_ref_group rr
       WHERE cm.object_id = p_object_id
         AND cm.report_ref_group_id = rr.object_id
         AND cm.trg_dataset <> rr.dataset
         AND p_daytime BETWEEN rr.daytime AND NVL(rr.end_date - 1, p_daytime + 1);

      CURSOR c_ref_item_grp(cp_object_id VARCHAR2, cp_daytime DATE) IS
      SELECT rr.code, rr.daytime, rr.end_date, rr.dataset
        FROM ov_report_ref_item ri,
             ov_report_ref_group rr
       WHERE ri.object_id = p_object_id
         AND ri.report_ref_group_id = rr.object_id
         AND ri.dataset <> rr.dataset
         AND p_daytime BETWEEN rr.daytime AND NVL(rr.end_date - 1, p_daytime + 1);

      diff_dataset_found  EXCEPTION;
      lv_message          VARCHAR2(1000);
      r_cost_map          c_cost_map%ROWTYPE;
      r_ref_item          c_ref_item%ROWTYPE;
      r_cost_map_grp      c_cost_map_grp%ROWTYPE;
      r_ref_item_grp      c_ref_item_grp%ROWTYPE;

    BEGIN

      OPEN c_cost_map(p_object_id, p_daytime);
      FETCH c_cost_map INTO r_cost_map;
      IF c_cost_map%FOUND THEN
         lv_message := 'The record cannot be updated, Report Reference '
                       || r_cost_map.code
                       || ' is having different dataset linked from '
                       || r_cost_map.daytime
                       || '.';
        RAISE diff_dataset_found;
      END IF;
      CLOSE c_cost_map;

      OPEN c_ref_item(p_object_id, p_daytime);
      FETCH c_ref_item INTO r_ref_item;
      IF c_ref_item%FOUND THEN
         lv_message := 'The record cannot be updated, Report Reference '
                       || r_ref_item.code
                       || ' is having different dataset linked from '
                       || r_ref_item.daytime
                       || '.';
        RAISE diff_dataset_found;
      END IF;
      CLOSE c_ref_item;

      OPEN c_cost_map_grp(p_object_id, p_daytime);
      FETCH c_cost_map_grp INTO r_cost_map_grp;
      IF c_cost_map_grp%FOUND THEN
         lv_message := 'The record cannot be updated, Report Reference Group '
                       || r_cost_map_grp.code
                       || ' is having different dataset linked from '
                       || r_cost_map_grp.daytime
                       || '.';
        RAISE diff_dataset_found;
      END IF;
      CLOSE c_cost_map_grp;

      OPEN c_ref_item_grp(p_object_id, p_daytime);
      FETCH c_ref_item_grp INTO r_ref_item_grp;
      IF c_ref_item_grp%FOUND THEN
         lv_message := 'The record cannot be updated, Report Reference Group '
                       || r_ref_item_grp.code
                       || ' is having different dataset linked from '
                       || r_ref_item_grp.daytime
                       || '.';
        RAISE diff_dataset_found;
      END IF;
      CLOSE c_ref_item_grp;

    EXCEPTION
      WHEN diff_dataset_found THEN
        RAISE_APPLICATION_ERROR(-20000, lv_message);
    END CheckValidMappingDataset;
    ----------------------------------------------------------------------------------------------------------------------------

    PROCEDURE OverRideEntry(
        p_journal_entry_no number,
        p_reference_id varchar2
       )  is

    lrec_je_cont cont_journal_entry%ROWTYPE;
    lrec_je_cont_excl cont_journal_entry_excl%ROWTYPE;

    CURSOR c_doc_je_cont(p_journal_entry_no number) IS
    SELECT *
      FROM cont_journal_entry e
     WHERE e.journal_entry_no = p_journal_entry_no;

     lv2_original_reference_id VARCHAR2(32);
     lv2_original_reference_tag VARCHAR2(32);
     lv2_orginal_journal_entry_no number;
       begin


         FOR journal_entry IN c_doc_je_cont(p_journal_entry_no)
    LOOP
        lrec_je_cont := journal_entry;
        --lrec_je_cont.ref_journal_entry_no := lrec_je_cont.journal_entry_no;

        lv2_original_reference_id := lrec_je_cont.reference_id;
        lv2_original_reference_tag := lrec_je_cont.tag;
        lv2_orginal_journal_entry_no := lrec_je_cont.ref_journal_entry_no;

        lrec_je_cont.manual_ind := 'Y' ;
        lrec_je_cont.reversal_date := NULL ;
        lrec_je_cont.record_status := 'P';
        lrec_je_cont.journal_entry_no := NULL;
        lrec_je_cont.reference_id:=p_reference_id;
        lrec_je_cont.cost_mapping_id:='MANUAL';
        lrec_je_cont.ref_journal_entry_src:='CONT';
        lrec_je_cont.tag:=ec_report_reference_version.report_reference_tag(p_reference_id,lrec_je_cont.daytime,'<=');
        lrec_je_cont.ref_journal_entry_no := p_journal_entry_no;
        lrec_je_cont.created_by := ECDP_CONTEXT.getAppUser;
        lrec_je_cont.created_date := Ecdp_Timestamp.getCurrentSysdate;
        if lrec_je_cont.reference_id is null and lrec_je_cont.cost_mapping_id is not null then
          lrec_je_cont.reference_id:=EC_COST_MAPPING_VERSION.report_ref_id(lrec_je_cont.cost_mapping_id,lrec_je_cont.period,'<=');
        END IF;


        IF p_reference_id = 'FORCED_EXCLUDE' THEN
           lrec_je_cont_excl.journal_entry_no:=NULL;
           lrec_je_cont_excl.document_key:=lrec_je_cont.document_key;
           lrec_je_cont_excl.contract_code:=lrec_je_cont.contract_code;
           lrec_je_cont_excl.cost_mapping_id:='MANUAL';
           lrec_je_cont_excl.ref_journal_entry_src:='CONT';
           lrec_je_cont_excl.ref_journal_entry_no:=p_journal_entry_no;
           lrec_je_cont_excl.daytime:=lrec_je_cont.daytime;
           lrec_je_cont_excl.period:=lrec_je_cont.period;
           lrec_je_cont_excl.dataset:=lrec_je_cont.dataset;
           lrec_je_cont_excl.comments:=lrec_je_cont.comments;
           lrec_je_cont_excl.amount:=lrec_je_cont.amount;
           lrec_je_cont_excl.qty_1:=lrec_je_cont.qty_1;
           lrec_je_cont_excl.created_by := ECDP_CONTEXT.getAppUser;
           lrec_je_cont_excl.created_date := Ecdp_Timestamp.getCurrentSysdate;
           CreateJournalEntry(lrec_je_cont_excl);
        ELSE
           CreateJournalEntry(lrec_je_cont);
        END IF;

        --Reverals record:
        lrec_je_cont.reference_id := lv2_original_reference_id;
        lrec_je_cont.tag := lv2_original_reference_tag;
        lrec_je_cont.amount := (-1)*nvl(journal_entry.amount,0);
        lrec_je_cont.tax_amount := (-1)*nvl(journal_entry.tax_amount,0);
        lrec_je_cont.qty_1 := (-1)*nvl(journal_entry.qty_1,0);

        CreateJournalEntry(lrec_je_cont);

       end LOOP;

END;

----------------------------------------------------------------------------------------------------------------------------

    PROCEDURE OverRideEntryExcl(
        p_journal_entry_no number,
        p_reference_id varchar2
       )  is

    lrec_je_cont cont_journal_entry%ROWTYPE;
    lrec_je_cont_excl cont_journal_entry_excl%ROWTYPE;
    lrec_je_cont_ifac ifac_journal_entry%ROWTYPE;

       begin

     lrec_je_cont_excl := ec_cont_journal_entry_excl.row_by_pk(p_journal_entry_no);
     lrec_je_cont_ifac := ec_ifac_journal_entry.row_by_pk(lrec_je_cont_excl.ref_journal_entry_no);

        --lv2_original_reference_id := lrec_je_cont_excl.reference_id;
        --lv2_original_reference_tag := lrec_je_cont.tag;
        --lv2_orginal_journal_entry_no := lrec_je_cont.ref_journal_entry_no;

        lrec_je_cont.manual_ind := 'Y' ;
        lrec_je_cont.reversal_date := NULL ;
        lrec_je_cont.record_status := 'P';
        lrec_je_cont.journal_entry_no := NULL;
        lrec_je_cont.reference_id:=p_reference_id;
        lrec_je_cont.cost_mapping_id:='MANUAL';
        lrec_je_cont.ref_journal_entry_src:='EXCL';
        lrec_je_cont.tag:=ec_report_reference_version.report_reference_tag(p_reference_id,lrec_je_cont_excl.daytime,'<=');
        lrec_je_cont.ref_journal_entry_no := p_journal_entry_no;
        lrec_je_cont.created_by := ECDP_CONTEXT.getAppUser;
        lrec_je_cont.created_date := Ecdp_Timestamp.getCurrentSysdate;

        lrec_je_cont.company_code := lrec_je_cont_ifac.company_code;
        lrec_je_cont.contract_code := lrec_je_cont_excl.contract_code;
        lrec_je_cont.document_key := lrec_je_cont_excl.document_key;
        lrec_je_cont.fin_account_code := lrec_je_cont_ifac.fin_account_code;
        lrec_je_cont.fin_cost_object_code := lrec_je_cont_ifac.fin_cost_object_code;
        lrec_je_cont.fin_cost_center_code := lrec_je_cont_ifac.fin_cost_center_code;
        lrec_je_cont.fin_revenue_order_code := lrec_je_cont_ifac.fin_revenue_order_code;
        lrec_je_cont.fin_wbs_code := lrec_je_cont_ifac.fin_wbs_code;
        lrec_je_cont.fin_wbs_descr := lrec_je_cont_ifac.fin_wbs_descr;
        lrec_je_cont.fin_account_descr := lrec_je_cont_ifac.fin_account_descr;
       -- lrec_je_cont.FIN_C .fin_cost_center_descr := lrec_je_cont_ifac.fin_cost_center_descr;
        --lrec_je_cont.FIN_RE .fin_revenue_order_descr := lrec_je_cont_ifac.fin_revenue_order_descr;
        lrec_je_cont.debit_credit_code := lrec_je_cont_ifac.debit_credit_code;
        lrec_je_cont.uom1_code :=  lrec_je_cont_ifac.uom1_code;
        lrec_je_cont.document_type := lrec_je_cont_ifac.document_type;
        lrec_je_cont.expenditure_type := lrec_je_cont_ifac.expenditure_type;

        lrec_je_cont.daytime:=lrec_je_cont_excl.daytime;
        lrec_je_cont.period:=lrec_je_cont_excl.period;
        lrec_je_cont.dataset:=lrec_je_cont_excl.dataset;
        lrec_je_cont.comments:=lrec_je_cont_excl.comments;
        lrec_je_cont.amount:=lrec_je_cont_excl.amount;
        lrec_je_cont.qty_1:=lrec_je_cont_excl.qty_1;
        lrec_je_cont.created_by := ECDP_CONTEXT.getAppUser;
        lrec_je_cont.created_date := Ecdp_Timestamp.getCurrentSysdate;

        CreateJournalEntry(lrec_je_cont);

        --Reverals record:

        lrec_je_cont_excl.amount := (-1)*nvl(lrec_je_cont_excl.amount,0);
        lrec_je_cont_excl.qty_1 := (-1)*nvl(lrec_je_cont_excl.qty_1,0);
        lrec_je_cont_excl.cost_mapping_id := 'Moved to Manual Entry';
        lrec_je_cont_excl.ref_journal_entry_src:='EXCL';
        lrec_je_cont_excl.ref_journal_entry_no:=p_journal_entry_no;
        lrec_je_cont_excl.journal_entry_no:=NULL;
        lrec_je_cont_excl.created_by := ECDP_CONTEXT.getAppUser;
        lrec_je_cont_excl.created_date := Ecdp_Timestamp.getCurrentSysdate;

        CreateJournalEntry(lrec_je_cont_excl);


END;

     FUNCTION GetExclusionValue(
        p_journal_entry_no number,
        p_column_name varchar2,
        p_journal_entry_src varchar2,
        p_daytime date)
     return varchar2 is

        lv_sql VARCHAR2(4000);
        lv_return_value varchar2(4000);
        LV_column_name varchar2(4000);
        ln_journal_entry_no NUMBER;
        lv_source varchar2(4);

        lc_li_dist_pc                      type_cursor;

     begin
        ln_journal_entry_no := p_journal_entry_no;
        lv_source := p_journal_entry_src;
        LV_column_name:=p_column_name;

        IF lv_source= 'EXCL' THEN
           ln_journal_entry_no:=ec_cont_journal_entry_EXCL.ref_journal_entry_no(p_journal_entry_no);
           lv_source:=ec_cont_journal_entry_EXCL.ref_journal_entry_src(p_journal_entry_no);
        END IF;

        IF p_column_name IN ('FIN_ACCOUNT_NAME','FIN_COST_CENTER_NAME','FIN_WBS_NAME','FIN_REVENUE_ORDER_NAME','COMPANY_NAME','CONTRACT_NAME') THEN
           LV_column_name := REPLACE(LV_column_name,'_NAME','');
           IF p_column_name!='FIN_WBS_NAME' THEN
            LV_column_name:=LV_column_name||'_CODE';
           END IF;
        ELSIF LV_column_name LIKE 'ORIG_' ||'%' THEN
              LV_column_name := REPLACE(LV_column_name,'ORIG_','');
        ELSIF LV_column_name ='FIN_WBS_CODE' THEN
              LV_column_name := 'FIN_WBS';

        END IF;

          lv_sql := 'SELECT ' || LV_column_name || ' FROM TV_' || lv_source ||'_JOURNAL_ENTRY WHERE journal_entry_no=' || ln_journal_entry_no;

          begin

          OPEN lc_li_dist_pc FOR
              lv_sql;
          LOOP
              FETCH lc_li_dist_pc
              INTO lv_return_value;
              EXIT WHEN lc_li_dist_pc%NOTFOUND;
           END LOOP;

           exception when others then
                lv_return_value:= null;
           end;

           IF p_column_name IN ('FIN_ACCOUNT_NAME','FIN_COST_CENTER_NAME','FIN_WBS_NAME','FIN_REVENUE_ORDER_NAME') THEN
             lv_return_value := ecdp_objects.GetObjName(ecdp_objects.GetObjIDFromCode(LV_column_name,lv_return_value),p_DAYTIME);
          END IF;

        return lv_return_value;
     END GetExclusionValue;

END EcDp_RR_Revn_Mapping;