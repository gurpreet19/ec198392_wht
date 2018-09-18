CREATE OR REPLACE PACKAGE BODY EcDp_Visual_Tracing IS
/***************************************************************************************************
** Package        : EcDp_Visual_Tracing, header part
**
** Release        :
**
** Purpose        : Various procedure and functions for the Visual tracing
**
**
**
** Created        : 2016-10-12 - gjossarv
**
** Modification history:
**
** Date        Whom      Change description:
** ----------  --------  ---------------------------------------------------------------------------
** 2016-10-12  gjossarv  Initial version.
***************************************************************************************************/

mth_entity_status t_mth_entity_status;

/*<EC-DOC>
-------------------------------------------------------------------------------------------------
 Function       : UpdateYearStatus                                                       --
 Description    : Finds all data entities that are linked to a data entity through the tracing.--
                  Does this for each of the data entities in the dataset_flow_document table   --
                  for the given period (month)
                                                                                               --
 Preconditions  :                                                                              --
 Postcondition  :                                                                              --
 Using Tables   :                                                                              --
                                                                                               --
 Using functions:                                                                              --
                                                                                               --
 Configuration                                                                                 --
 required       :                                                                              --
                                                                                               --
 Behaviour      :                                                                              --
                                                                                               --
-------------------------------------------------------------------------------------------------*/
PROCEDURE UpdateYearStatus (
    p_period               DATE,
    p_property_id          VARCHAR2,
    p_tr_area_code         VARCHAR2,
    p_parent_project_id    VARCHAR2 DEFAULT NULL,
    p_process_code         VARCHAR2 DEFAULT NULL,
    p_act_acc_code         VARCHAR2 DEFAULT NULL,
    p_deprecated_code      VARCHAR2 DEFAULT NULL
    )

IS
  cursor c_tracing_config (cp_tracing_area VARCHAR2) is
    SELECT * FROM visual_tracing_config x
    where x.TR_AREA = cp_tracing_area;

  cursor c_tracing_data (cp_mth DATE, cp_data_entity_cat VARCHAR2) is
    select * from v_tracing_data t
    where t.DATA_ENTITY_CAT = cp_data_entity_cat
    and t.PERIOD = to_date(cp_mth,'DD.MM.YY')
    --Include records where property_obj_id is null
    and nvl(t.PROPERTY_OBJ_ID,p_property_id) = p_property_id
    --if p_parent_project_id is null this cursor should include records where the PARENT_PROJECT_OBJ_ID is anything:
    and nvl(t.PARENT_PROJECT_OBJ_ID,'x') = nvl(p_parent_project_id,nvl(t.PARENT_PROJECT_OBJ_ID,'x'))
    --if p_process_code is null this cursor should include records where the PROCESS is anything:
    and nvl(t.PROCESS,'x') = nvl(p_process_code,nvl(t.PROCESS,'x'))
    --if p_act_acc_code in null this cursor should include records where the ACTUAL_ACCRUAL_CODE is anything:
    and nvl(t.ACTUAL_ACCRUAL_CODE,nvl(p_act_acc_code,'x')) = nvl(p_act_acc_code,nvl(t.ACTUAL_ACCRUAL_CODE,'x'))
    --exclude any data being deprected
    and nvl(t.DEPRECATED_IND,'NULL') <> 'Y'
    ;

  ld_start_of_year                    DATE;
  ld_mth                              DATE;
  lv2_mth_status                      VARCHAR2(240);
  lv2_mth_status_label                VARCHAR2(240);
  lv2_verificationstatus              VARCHAR2(240);
  lv2_icon                            VARCHAR2(240);
  ln_cnt                              NUMBER;
  ln_rec_cnt                          NUMBER;
  ln_no_data_cnt                      NUMBER;
  ln_ok_cnt                           NUMBER;

BEGIN
  -- lv2_mth_status / lv2_mth_status_label / lv2_verificationstatus
  -- will have these values:
  -----------------------------------------------------------------------
  -- lv2_mth_status   lv2_mth_status_label    lv2_icon
  -----------------------------------------------------------------------
  -- OK               OK                      tracing/OK.png
  -- WARNING          Warning                 tracing/WARNING.png
  -- NO_DATA          No Data                 tracing/NODATA.png
  -----------------------------------------------------------------------

-- Temporary table mth_entity_status will be populated per monthly record
-- It will have one record for each data_entity_cat with the status for that catergory
-- EXAMPLE:
  -----------------------------------------------------------------------------------------------
  -- DATA_ENTITY_CAT     MTH_STATUS    COMMENT
  -----------------------------------------------------------------------------------------------
  -- MTH_ALLOC           OK            There are Monthly allocations and they are Approved
  -- DATA_UPLOADS        WARNING       There are data uploads but not all of them are Approved
  -- DATA_MAPPING        NO_DATA       There are no data mappings
  -- DATA_EXTRACT        NO_DATA       There are no data extracts
  -- CALCULATIONS        NO_DATA       There are no calculations
  -- FIN_DOCS            NO_DATA       There are no Financial Documents
  -- REPORTS             NO_DATA       There are no reports
  -----------------------------------------------------------------------------------------------

-- If the MTH_STATUS is OK for all entries then the overall status for the month will be OK
-- If the MTH_STATUS is NO_DATA for all the entries then the overall status for the month will be NO_DATA
-- If there is a mix of OK and NO_DATA then the overall status for the month will be WARNING

--UE support:
  IF ue_visual_tracing.isUpdYearStatusUEEnabled = 'TRUE' THEN
    ue_visual_tracing.UpdateYearStatus(p_period,
                                       p_property_id,
                                       p_tr_area_code,
                                       p_parent_project_id,
                                       p_process_code,
                                       p_act_acc_code,
                                       p_deprecated_code
                                       );
  ELSE
    --get the first month of the year in question:
    ld_start_of_year := to_date(trunc(p_period,'YEAR'),'DD.MM.YY');

    --Temporary table for the status
    mth_entity_status := t_mth_entity_status();

    for i in 1..12 loop --loop over the months of the year in question
        ld_mth := to_date(add_months(ld_start_of_year,i-1),'DD.MM.YY');
        --for each month loop over the tracing config to analyse each category given by DATA_ENTITY_CAT:
        for tr in c_tracing_config(p_tr_area_code) loop
          --loop over the tracing data to see what we have
          --add new rec to the temp table:
          mth_entity_status.extend;
          --set the data_entity_cat for the record:
          mth_entity_status(mth_entity_status.last).data_entity_cat := tr.data_entity_cat;
          --Set the status to 'NO_DATA' initially:
          mth_entity_status(mth_entity_status.last).mth_status := 'NO_DATA';
          --loop over the tracing data for the data_entity_cat
          for tr_data in c_tracing_data(ld_mth, tr.data_entity_cat) loop
            --if we have records here then we have data for the given month and data entity category
            --set the status to OK initially:
            mth_entity_status(mth_entity_status.last).mth_status := 'OK';
            --If any of the records have record status different from A (Approved)
            --then there is still work to do for that data entity category for that month
 IF tr_data.data_entity_cat = 'FINANCIAL_DOC' THEN
              IF tr_data.dep_status <> 'Booked' THEN
                mth_entity_status(mth_entity_status.last).mth_status := 'WARNING';
              END IF;
            ELSIF tr_data.data_entity_cat = 'RRCA_REPORT' THEN
              IF tr_data.record_status = 'P' THEN
                mth_entity_status(mth_entity_status.last).mth_status := 'WARNING';
              END IF;
            ELSE
            if tr_data.record_status <> 'A' then
               mth_entity_status(mth_entity_status.last).mth_status := 'WARNING';
             END IF;
            end if;
          end loop;
        end loop;
        --get status at month level regardless of data_entity_cat:
        ln_no_data_cnt := 0;
        ln_ok_cnt := 0;
        ln_rec_cnt := 0;

        FOR ln_cnt IN mth_entity_status.first..mth_entity_status.last LOOP
            ln_rec_cnt := ln_rec_cnt + 1;
            IF mth_entity_status(ln_cnt).mth_status = 'NO_DATA' THEN
              ln_no_data_cnt := ln_no_data_cnt + 1;
            END IF;
            IF mth_entity_status(ln_cnt).mth_status = 'OK' THEN
              ln_ok_cnt := ln_ok_cnt + 1;
            END IF;
        END LOOP;

        --default the status of the month to 'WARNING'
        lv2_mth_status := 'WARNING';
        lv2_mth_status_label := 'Warning';
        lv2_verificationstatus := 'warning';
        lv2_icon := 'tracing/WARNING.png';
        --If ALL entries in the temp table are 'NO_DATA' then the overall month status will be set to 'NO_DATA':
        IF ln_no_data_cnt = ln_rec_cnt THEN
           lv2_mth_status := 'NO_DATA';
           lv2_mth_status_label := 'No Data';
           lv2_verificationstatus := 'information';
           lv2_icon := 'tracing/NODATA.png';
        END IF;
        --If ALL entries in the temp table are 'OK' then the overall month status will be set to 'OK':
        IF ln_ok_cnt = ln_rec_cnt then
           lv2_mth_status := 'OK';
           lv2_mth_status_label := 'OK';
           lv2_verificationstatus := 'information';
           lv2_icon := 'tracing/OK.png';
        END IF;

        --clear the temp table
        mth_entity_status := t_mth_entity_status();

        --Write the sataus to the YEAR STATUS TABLE for the given month:
        --delete the old record if it is there:
        DELETE FROM VISUAL_TR_YEAR_STATUS xx
          where xx.tr_mth = ld_mth
          and xx.property_obj_id = p_property_id
          and xx.tr_area_code = p_tr_area_code
          and nvl(xx.parent_project_obj_id, 'x') = nvl(p_parent_project_id,nvl(xx.parent_project_obj_id, 'x'))
          and nvl(xx.process_code, 'x') = nvl(p_process_code,nvl(xx.process_code, 'x'))
          and nvl(xx.act_acc_code,'x') = nvl(p_act_acc_code,'x')
          ;

        --add new record for the month
        insert into VISUAL_TR_YEAR_STATUS
          (ENTRY_NO,
           TR_AREA_CODE,
           PROPERTY_OBJ_ID,
           PARENT_PROJECT_OBJ_ID,
           PROCESS_CODE,
           ACT_ACC_CODE,
           DEPRECATED_CODE,
           TR_YEAR,
           TR_MTH,
           TR_LABEL,
           TR_STATUS,
           TR_STATUS_COLOR,
           TR_ICON,
           VERIFICATIONSTATUS)
          values
          (
           ecdp_system_key.assignNextKeyValue('x'), --generate a unique number
           p_tr_area_code,
           p_property_id,
           p_parent_project_id,
           p_process_code,
           p_act_acc_code,
           p_deprecated_code,
           ld_start_of_year,
           ld_mth,
           lv2_mth_status_label,
           lv2_mth_status,
           '', --color not in use
           lv2_icon,
           lv2_verificationstatus
          );
    end loop;
  END IF;
END UpdateYearStatus;

-----------------------------------------------------------------------
-- Updates the status for all months in specified year.
----+----------------------------------+-------------------------------
FUNCTION GetUpdateYearStatus(
    p_period_string                    VARCHAR2,
    p_property_id                      VARCHAR2,
    p_tr_area_code                     VARCHAR2,
    p_parent_project_id                VARCHAR2,
    p_process_code                     VARCHAR2,
    p_act_acc_code                     VARCHAR2,
    p_deprecated_code                  VARCHAR2
) RETURN VARCHAR2
IS
    lv_end_user_message                VARCHAR2(240);
    lv_property_name                   VARCHAR2(240);
    lv_act_acc_message                 VARCHAR2(240);
    lv_parent_project_message          VARCHAR2(240);
    lv_process_message                 VARCHAR2(240);
    ld_period_daytime                  DATE;
    ex_validation_error                EXCEPTION;
BEGIN
    --UE support
    IF ue_visual_tracing.isGetUpdYearStatusUEEnabled = 'TRUE' THEN
      --ue_visual_tracing
      RETURN ue_visual_tracing.GetUpdateYearStatus(p_period_string,
                                                   p_property_id,
                                                   p_tr_area_code,
                                                   p_parent_project_id,
                                                   p_process_code,
                                                   p_act_acc_code,
                                                   p_deprecated_code);
    ELSE
      -- Checking mandatory parameters
      IF (p_period_string IS NULL OR p_period_string = 'null') THEN
          lv_end_user_message := 'Error!' || chr(10) ||
                                 'Not possible to execute. ''Year'' is missing!';
      ELSIF (p_property_id IS NULL OR p_property_id = 'null') THEN
          lv_end_user_message := 'Error!' || chr(10) ||
                                 'Not possible to execute. ''Property'' is missing!';
      END IF;
      IF lv_end_user_message IS NOT NULL THEN
          RAISE ex_validation_error;
      END IF;

      --No errors - continue....
      ld_period_daytime := to_date(p_period_string, 'yyyy-MM-dd"T"hh24:mi:ss');
      lv_property_name := ec_contract_area_version.name(p_property_id, ld_period_daytime, '<=');

      --Preparing text items for the 'Success' string...
      IF p_act_acc_code is not null THEN
        lv_act_acc_message := ' and Actual/Accrual = "' || ec_prosty_codes.code_text(p_act_acc_code, 'ACTUAL_ACCRUAL_CODE') || '"' ;
      ELSE
        lv_act_acc_message := '';
      END IF;

      IF p_parent_project_id is not null THEN
        lv_parent_project_message := ' and Project = "' || ec_contract_version.name(p_parent_project_id, ld_period_daytime, '<=')  || '"' ;
      ELSE
        lv_parent_project_message := '';
      END IF;

      IF p_process_code is not null THEN
        lv_process_message := ' and Process = "' || ec_prosty_codes.code_text(p_process_code, 'OIL_SANDS_PROCESS') || '"' ;
      ELSE
        lv_process_message := '';
      END IF;

      --Check that Tracing is enabled:
      IF NVL(ec_ctrl_system_attribute.attribute_text(ld_period_daytime,'ENABLE_DOC_TRACING','<='),'N') = 'N' THEN
          lv_end_user_message := 'Warning!' || chr(10) ||
                                 'The Document Tracing is not enabled.' || chr(10) ||
                                 'System Attribute ''ENABLE_DOC_TRACING'' is missing or not set to ''Y''.' || chr(10) ||
                                 'The Year Status data might be incomplete.';
      END IF;

      --Check that Tracing Highlight is enabled:
      IF NVL(ec_ctrl_system_attribute.attribute_text(ld_period_daytime,'ENABLE_VISUAL_TRACING','<='),'N') = 'N' THEN
          lv_end_user_message := 'Warning!' || chr(10) ||
                                 'The Document Tracing Highlight functionality is not enabled.' || chr(10) ||
                                 'System Attribute ''ENABLE_VISUAL_TRACING'' is missing or not set to ''Y''.' || chr(10) ||
                                 'Clicking the Trace icon inside a data entity will not give any tracing highlighting.';
      END IF;

      -- Updating the status for all months in specified year.
      UpdateYearStatus(ld_period_daytime, p_property_id, p_tr_area_code, p_parent_project_id, p_process_code, p_act_acc_code, p_deprecated_code);

      IF lv_end_user_message IS NULL THEN
          lv_end_user_message := 'Success!' || chr(10) ||
                                 'The Year Status for Property = "' || lv_property_name || '"' ||
                                 lv_parent_project_message ||
                                 lv_process_message ||
                                 lv_act_acc_message ||
                                 ' is updated for all months of year ' || extract(year from ld_period_daytime) || '.';
      END IF;
      RETURN lv_end_user_message;
    END IF;

  EXCEPTION
      WHEN ex_validation_error THEN
          RETURN lv_end_user_message;
      WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20000, SQLERRM || '\n\n' || 'Technical:\n');
END GetUpdateYearStatus;


/*<EC-DOC>
-------------------------------------------------------------------------------------------------
 Function       : UpdateVisualTracing                                                       --
 Description    : Finds all data entities that are linked to a data entity through the tracing.--
                  Does this for each of the data entities in the dataset_flow_document table   --
                  for the given period (month)
                                                                                               --
 Preconditions  :                                                                              --
 Postcondition  :                                                                              --
 Using Tables   :                                                                              --
                                                                                               --
 Using functions:                                                                              --
                                                                                               --
 Configuration                                                                                 --
 required       :                                                                              --
                                                                                               --
 Behaviour      :                                                                              --
                                                                                               --
-------------------------------------------------------------------------------------------------*/
PROCEDURE UpdateVisualTracing(
    p_reference_id  VARCHAR2,
    p_type          VARCHAR2,
    p_period        DATE
    )
--</EC-DOC>
IS

    cursor c_dataset_flow_documents (cp_reference_id VARCHAR, cp_type VARCHAR, cp_period DATE) is
      select * from dataset_flow_document dfd
      where dfd.process_date = cp_period
      and dfd.reference_id = cp_reference_id
      and dfd.type = cp_type
      ;

    cursor c_fw_dataset(cp_reference_id VARCHAR2, cp_type VARCHAR2) is
      SELECT
        'FORWARD',
        level,
        cc.connection_id,
        cc.from_type,
        cc.from_reference_id as SOURCE_ENTITY,
        cc.to_reference_id as HIGHLIGHT_ENTITY,
        cc.to_type as HIGHLIGHT_ENTITY_TYPE
        FROM dataset_flow_doc_conn cc , dataset_flow_document z
        where z.reference_id = cc.from_reference_id
        and z.type = cc.from_type
        and cc.to_type <> 'CLASS_MAPPING'
        and z.process_date = p_period
        and ec_dataset_flow_document.process_date(cc.to_type,cc.to_reference_id) = p_period --to exclude items from other periods
        start with cc.from_reference_id = cp_reference_id
        and cc.from_type = cp_type
        and z.process_date = p_period
        connect by nocycle cc.from_reference_id = prior cc.to_reference_id
        and cc.from_type = prior cc.to_type
        and z.process_date = p_period
        ;

    cursor c_bw_dataset(cp_reference_id VARCHAR2, cp_type VARCHAR2) is
      SELECT
        'BACKWARD',
        level,
        cc.connection_id,
        cc.to_type,
        cc.to_reference_id as SOURCE_ENTITY,
        cc.from_reference_id as HIGHLIGHT_ENTITY,
        cc.from_type as HIGHLIGHT_ENTITY_TYPE
        FROM dataset_flow_doc_conn cc , dataset_flow_document z
        where z.reference_id = cc.to_reference_id
        and z.type = cc.to_type
        and cc.from_reference_id <> '0'
        and cc.from_type <> 'CLASS_MAPPING'
        and z.process_date = p_period
        and ec_dataset_flow_document.process_date(cc.from_type,cc.from_reference_id) = p_period --to exclude items from other periods
        start with cc.to_reference_id = cp_reference_id
        and cc.to_type = cp_type
        and z.process_date = p_period
        connect by nocycle  cc.to_reference_id =prior  cc.from_reference_id
        and cc.to_type = prior cc.from_type
        and z.process_date = p_period
        ;
BEGIN

IF NVL(ec_ctrl_system_attribute.attribute_text(p_period,'ENABLE_VISUAL_TRACING','<='),'N')='Y' then

    IF ue_visual_tracing.isUpdGraphTracingUEEnabled = 'TRUE' THEN
     ue_visual_tracing.UpdateVisualTracing(p_reference_id, p_type, p_period);
    ELSE
      --delete existing tracing
      delete from visual_tracing gt
       where gt.period = p_period
         and gt.reference_id = p_reference_id
         and gt.type = p_type
         ;
      --add the new tracing
      FOR x in c_dataset_flow_documents(p_reference_id, p_type, p_period) LOOP
        --get backward tracing
        for b in c_bw_dataset(x.reference_id, x.type) loop
          if b.highlight_entity <> x.reference_id then
            insert into visual_tracing (visual_tracing_no
                                           ,period
                                           ,type
                                           ,reference_id
                                           ,highlight_entity
                                           ,highlight_entity_type
                                           ,direction
                                           ,trace_level
                                           ,source_entity
                                           )
                                   values (ecdp_system_key.assignNextKeyValue('VISUAL_TRACING_NO')
                                           ,p_period
                                           ,p_type
                                           ,x.reference_id
                                           ,b.highlight_entity
                                           ,b.highlight_entity_type
                                           ,'BACKWARD'
                                           ,b.level
                                           ,b.source_entity
                                           );
          --Each of the backward entities to be highlighted must themselves get a forward highlight to this entity
          --by flipping like this:
          -- BACKWARD -> FORWARD
          -- type <-> highlight_entity_type
          -- reference_id <-> highlight_entity
          --
            insert into visual_tracing (visual_tracing_no
                                           ,period
                                           ,type
                                           ,reference_id
                                           ,highlight_entity
                                           ,highlight_entity_type
                                           ,direction
                                           ,trace_level
                                           ,source_entity
                                           )
                                   values (ecdp_system_key.assignNextKeyValue('VISUAL_TRACING_NO')
                                           ,p_period
                                           ,b.highlight_entity_type --flipped from p_type
                                           ,b.highlight_entity --flipped from x.reference_id
                                           ,x.reference_id --flipped from b.highlight_entity
                                           ,p_type --flipped from b.highlight_entity_type
                                           ,'FORWARD' --flipped from BACKWARD
                                           ,b.level
                                           ,b.source_entity
                                           );
          end if;
        end loop;
        --get forward tracing
        for b in c_fw_dataset(x.reference_id, x.type) loop
          if b.highlight_entity <> x.reference_id then
            insert into visual_tracing (visual_tracing_no
                                           ,period
                                           ,type
                                           ,reference_id
                                           ,highlight_entity
                                           ,highlight_entity_type
                                           ,direction
                                           ,trace_level
                                           ,source_entity
                                           )
                                   values (ecdp_system_key.assignNextKeyValue('VISUAL_TRACING_NO')
                                           ,p_period
                                           ,p_type
                                           ,x.reference_id
                                           ,b.highlight_entity
                                           ,b.highlight_entity_type
                                           ,'FORWARD'
                                           ,b.level
                                           ,b.source_entity
                                           );
          end if;
        end loop;
    END LOOP;
  END IF; --UE
END IF;
END UpdateVisualTracing;

--<EC-DOC>
----------------------------------------------------------------------------------------------------
-- Function       : get_upload_dataset
-- Description    : Returns a the dataset for a data upload.
-----------------------------------------------------------------------------------------------------
FUNCTION GetUploadProcess(p_source_doc_name VARCHAR2, p_source_doc_ver NUMBER, p_period DATE)
RETURN VARCHAR2
--</EC-DOC>
IS
   cursor c_upload_data (cp_source_doc_name VARCHAR2, cp_source_doc_ver NUMBER, cp_period DATE) is
     select distinct x.dataset from ifac_journal_entry x
       where x.source_doc_name = cp_source_doc_name
       and x.source_doc_ver = cp_source_doc_ver
       and x.period = cp_period;

   lv2_process VARCHAR2(240);

BEGIN
   IF ue_visual_tracing.isGetUploadProcessUEEnabled = 'TRUE' THEN
     RETURN ue_visual_tracing.GetUploadProcess(p_source_doc_name, p_source_doc_ver, p_period);
   ELSE
     lv2_process := '';
     for x in c_upload_data(p_source_doc_name, p_source_doc_ver, p_period) loop
       lv2_process := ec_prosty_codes.text_1(x.dataset,'DATASET');
     end loop;

     return lv2_process;
   END IF; --UE
END GetUploadProcess;

--<EC-DOC>
----------------------------------------------------------------------------------------------------
-- Function       : get_report_process
-- Description    : Returns a the Process for a report.
-----------------------------------------------------------------------------------------------------
FUNCTION GetReportProcess(p_document_key VARCHAR2, p_report_no NUMBER, p_period DATE)
RETURN VARCHAR2
--</EC-DOC>
IS
   cursor c_data_extracts (cp_document_key VARCHAR2, cp_report_no NUMBER) is
     select x.summary_setup_id from DATASET_FLOW_REPORT t, cont_doc x
       where t.document_key = x.document_key
       and t.document_key = cp_document_key
       and t.report_no = cp_report_no;

   lv2_process VARCHAR2(240);
   lv2_summary_setup_id VARCHAR2(32);

BEGIN
   IF ue_visual_tracing.isGetReportProcessUEEnabled = 'TRUE' THEN
     RETURN ue_visual_tracing.GetReportProcess(p_document_key , p_report_no , p_period);
   ELSE
     lv2_process := '';
     for x in c_data_extracts(p_document_key, p_report_no) loop
       lv2_summary_setup_id := x.summary_setup_id;
       exit;
     end loop;

     IF lv2_summary_setup_id is not null THEN
       lv2_process := ec_summary_setup_version.text_1(lv2_summary_setup_id, p_period, '<=');
     END IF;

     return lv2_process;
   END IF; --UE
END GetReportProcess;


--<EC-DOC>
----------------------------------------------------------------------------------------------------
-- Function       : get_report_actual_accrual
-- Description    : Returns whether a report belongs to a Actual or Accrual
-----------------------------------------------------------------------------------------------------
FUNCTION GetReportActualAccrual(p_document_key VARCHAR2, p_report_no NUMBER)
RETURN VARCHAR2
--</EC-DOC>
IS
   cursor c_data_extracts (cp_document_key VARCHAR2, cp_report_no NUMBER) is
     select x.* from DATASET_FLOW_REPORT t, cont_doc x
       where t.document_key = x.document_key
       and t.document_key = cp_document_key
       and t.report_no = cp_report_no;

   lv2_actual_accrual VARCHAR2(240);

BEGIN
   IF ue_visual_tracing.isGetReportActAccUEEnabled = 'TRUE' THEN
     RETURN ue_visual_tracing.GetReportActualAccrual(p_document_key ,p_report_no);
   ELSE
     lv2_actual_accrual := '';
     for x in c_data_extracts(p_document_key, p_report_no) loop
       IF x.accrual_ind = 'Y' THEN
         lv2_actual_accrual := 'ACCRUAL';
       ELSE
         lv2_actual_accrual := 'ACTUAL';
       END IF;
     end loop;
     return lv2_actual_accrual;
   END IF; --UE
END GetReportActualAccrual;

--<EC-DOC>
----------------------------------------------------------------------------------------------------
-- Function       : get_forward_reference
-- Description    : This function is for setting icon related to new entitites
--                  Checks if the data entity has a forward reference, i.e.
--                  it exists in the 'from_reference_id' column.
--                  If there is no forward reference it means that this is a new data entity.
--                  In this case the function retuns 'WARNING'
--                  If there is a forward reference AND the data entity is PROVISIONAL/OPEN then the
--                  function returns the OPEN_LOCK.
--                  Else it returns LOCK
-----------------------------------------------------------------------------------------------------
FUNCTION GetForwardReference(p_reference_id VARCHAR2, p_type VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
   cursor c_forward_ref (cp_reference_id VARCHAR2, cp_type VARCHAR2) is
     select * from dataset_flow_doc_conn x
       where x.from_reference_id = cp_reference_id
       and x.from_type = cp_type;

   lv2_found VARCHAR2(32);

BEGIN
   IF ue_visual_tracing.isGetForwardRefUEEnabled = 'TRUE' THEN
     RETURN ue_visual_tracing.GetForwardReference(p_reference_id, p_type);
   ELSE
     lv2_found := 'false';
     for x in c_forward_ref(p_reference_id, p_type) loop
       lv2_found := 'true';
     end loop;
     return lv2_found;
   END IF; --UE
END GetForwardReference;

--<EC-DOC>
----------------------------------------------------------------------------------------------------
-- Function       : get_note_reference
-- Description    : This function is for finding out if there is a Notes reference for the seleced object
-----------------------------------------------------------------------------------------------------
FUNCTION GetNotesReference(p_reference_id VARCHAR2, p_type VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
   cursor c_notes_ref (cp_reference_id VARCHAR2, cp_type VARCHAR2) is
     select * from dataset_flow_doc_note x
       where x.reference_id = cp_reference_id
       and x.type = cp_type
       and nvl(x.one_time_msg,'N') <> 'Y';

   lv2_found VARCHAR2(32);

BEGIN
   IF ue_visual_tracing.isGetNotesRefUEEnabled = 'TRUE' THEN
     RETURN ue_visual_tracing.GetNotesReference(p_reference_id, p_type);
   ELSE
     lv2_found := 'false';
     for x in c_notes_ref(p_reference_id, p_type) loop
       lv2_found := 'true';
     end loop;
     return lv2_found;
   END IF; --UE
END GetNotesReference;

END EcDp_Visual_Tracing;