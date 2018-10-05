CREATE OR REPLACE PACKAGE BODY ECDP_RR_REVN_MAPPING_INTERFACE IS

    ex_missing_doc_name EXCEPTION;
    ex_newer_src_doc_found EXCEPTION;
    ex_version_not_found EXCEPTION;
    ex_no_new_upload_found EXCEPTION;
    ex_new_upload_found EXCEPTION;

    ln_default_app_error_num CONSTANT NUMBER := -20000;
    lv2_ex_missing_doc_name_msg CONSTANT VARCHAR2(64) := 'Source document name is missing from interface data.';
    lv2_ex_newer_src_doc_found_msg CONSTANT VARCHAR2(64) := 'Newer source document versions are found.';
    lv2_ex_version_not_found_msg CONSTANT VARCHAR2(64) := 'Source document version is not found.';
    lv2_ex_no_new_upload_found_msg CONSTANT VARCHAR2(64) := 'No new upload found.';
    lv2_ex_new_upload_found_msg CONSTANT VARCHAR2(64) := 'New upload found.';
    lv2_ex_meg_header_approve CONSTANT VARCHAR2(64) := 'No Update possible as the document is already in requested state';
    lv2_ex_meg_header_unapprove CONSTANT VARCHAR2(64) := 'Cannot unapprove document. ';
    lv2_ex_meg_header_receive_ifac CONSTANT VARCHAR2(64) := 'Record interfacing failed. ';
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    TYPE T_IFAC_JE_SOURCE_DOCUMENT_P IS RECORD(

         name                              IFAC_JOURNAL_ENTRY.Source_Doc_Name%TYPE
        ,period                            IFAC_JOURNAL_ENTRY.Period%TYPE
        ,version                           IFAC_JOURNAL_ENTRY.Source_Doc_Ver%TYPE
        ,is_null                           BOOLEAN
        );
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    TYPE T_IFAC_JE_SOURCE_DOCUMENT_L_P IS RECORD(
         name                              IFAC_JOURNAL_ENTRY.Source_Doc_Name%TYPE
        ,period                            IFAC_JOURNAL_ENTRY.Period%TYPE
        );
    TYPE T_TABLE_IFAC_JE_SRC_DOC_L_P IS TABLE OF T_IFAC_JE_SOURCE_DOCUMENT_L_P;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    TYPE cur_ifac_records IS REF CURSOR RETURN IFAC_JOURNAL_ENTRY%ROWTYPE;
    TYPE cur_ifac_documents IS REF CURSOR RETURN T_IFAC_JE_SOURCE_DOCUMENT_L_P;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION GetLatestDocumentVersion_P(
         p_source_document_name            IFAC_JOURNAL_ENTRY.Source_Doc_Name%TYPE
        ,p_period                          IFAC_JOURNAL_ENTRY.Period%TYPE
        ,p_new_upload_found                OUT BOOLEAN
        )
    RETURN T_IFAC_JE_SOURCE_DOCUMENT_P
    IS
        CURSOR c_latest_source_document(
             cp_source_doc_name                 IFAC_JOURNAL_ENTRY.Source_Doc_Name%TYPE
            ,cp_period                          IFAC_JOURNAL_ENTRY.Period%TYPE
            )
        IS
            SELECT DISTINCT ifac.source_doc_name, ifac.period, ifac.source_doc_ver, ifac.is_max_source_doc_ver_ind
            FROM IFAC_JOURNAL_ENTRY ifac
            WHERE (ifac.is_max_source_doc_ver_ind = ecdp_revn_common.gv2_true OR ifac.is_max_source_doc_ver_ind IS NULL)
                AND ifac.Source_Doc_Name = cp_source_doc_name
                AND ifac.period = cp_period;

        lo_source_document T_IFAC_JE_SOURCE_DOCUMENT_P;

    BEGIN
        lo_source_document.is_null := TRUE;
        p_new_upload_found := FALSE;

        FOR i_doc IN c_latest_source_document(p_source_document_name, p_period)
        LOOP
            IF i_doc.source_doc_ver IS NULL
            THEN
                p_new_upload_found := TRUE;
            ELSE
                lo_source_document.name := i_doc.source_doc_name;
                lo_source_document.period := i_doc.period;
                lo_source_document.version := i_doc.source_doc_ver;
                lo_source_document.is_null := FALSE;
            END IF;
        END LOOP;

        RETURN lo_source_document;

    END GetLatestDocumentVersion_P;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION GetUpload_P(
         p_source_document_name            IFAC_JOURNAL_ENTRY.Source_Doc_Name%TYPE
        ,p_period                          IFAC_JOURNAL_ENTRY.Period%TYPE
        ,p_document_version                IFAC_JOURNAL_ENTRY.Source_Doc_Ver%TYPE
        )
    RETURN cur_ifac_records
    IS
        lc_resultset cur_ifac_records;
    BEGIN
        OPEN lc_resultset FOR
            SELECT *
            FROM IFAC_JOURNAL_ENTRY
            WHERE ecdp_revn_common.Equals(Source_Doc_Name, p_source_document_name) = ecdp_revn_common.gv2_true
                AND period = p_period
                AND ecdp_revn_common.Equals(source_doc_ver, p_document_version) = ecdp_revn_common.gv2_true;

        RETURN lc_resultset;
    END GetUpload_P;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION GetUnapprovedUploads_P
    RETURN cur_ifac_documents
    IS
        lc_resultset cur_ifac_documents;
    BEGIN
        OPEN lc_resultset FOR
            SELECT DISTINCT Source_Doc_Name, period
            FROM IFAC_JOURNAL_ENTRY
            WHERE source_doc_ver IS NULL OR Is_Max_Source_Doc_Ver_Ind IS NULL;

        RETURN lc_resultset;

    END GetUnapprovedUploads_P;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION UpdateSourceDocumentVerInfo_P(
         p_source_document_name            IFAC_JOURNAL_ENTRY.Source_Doc_Name%TYPE
        ,p_period                          IFAC_JOURNAL_ENTRY.Period%TYPE
        ,p_original_document_version       IFAC_JOURNAL_ENTRY.Source_Doc_Ver%TYPE
        ,p_new_document_version            IFAC_JOURNAL_ENTRY.Source_Doc_Ver%TYPE
        ,p_is_latest_version               BOOLEAN
        )
    RETURN NUMBER
    IS
        lv2_is_latest_version_str VARCHAR2(1);
        lv2_user_id IFAC_JOURNAL_ENTRY.LAST_UPDATED_BY%TYPE;
    BEGIN
        lv2_user_id := NVL(ecdp_context.getAppUser, USER);

        IF p_is_latest_version IS NOT NULL
        THEN
            lv2_is_latest_version_str := ecdp_revn_common.TranslateBoolean(p_is_latest_version);
        END IF;

        UPDATE IFAC_JOURNAL_ENTRY
        SET source_doc_ver = p_new_document_version
            ,is_max_source_doc_ver_ind = lv2_is_latest_version_str
            ,last_updated_by = lv2_user_id
        WHERE ecdp_revn_common.Equals(Source_Doc_Name, p_source_document_name) = ecdp_revn_common.gv2_true
            AND TRUNC(period,'MM') = p_period
            AND ecdp_revn_common.Equals(source_doc_ver, p_original_document_version) = ecdp_revn_common.gv2_true;

        RETURN SQL%ROWCOUNT;
    END UpdateSourceDocumentVerInfo_P;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE ValidateNewIfacUpd_P(
         p_new_journal_entry_record        IN OUT NOCOPY IFAC_JOURNAL_ENTRY%ROWTYPE
        )
    IS
    lv_trans_inventory_code                VARCHAR2(32);
    BEGIN

     IF Ue_Rr_Revn_Mapping_Interface.isValidateNewIfacUpdUEE = 'TRUE' THEN
      Ue_Rr_Revn_Mapping_Interface.ValidateNewIfacUpd_P(p_new_journal_entry_record);

     ELSE

        IF Ue_Rr_Revn_Mapping_Interface.isValidateNewIfacUpdPreUEE = 'TRUE' THEN
          Ue_Rr_Revn_Mapping_Interface.ValidateNewIfacUpd_Pre(p_new_journal_entry_record);
        END IF;

        IF NVL(gv2_allow_empty_source_doc, ecdp_revn_common.gv2_false) = ecdp_revn_common.gv2_false
            AND p_new_journal_entry_record.source_doc_name IS NULL
        THEN
            RAISE ex_missing_doc_name;
        END IF;

        lv_trans_inventory_code       :=Ecdp_Inbound_Interface.getMappingCode(p_new_journal_entry_record.trans_inventory_CODE, 'TRANS_INVENTORY', p_new_journal_entry_record.daytime);
        p_new_journal_entry_record.trans_inventory_id:=ecdp_objects.GetObjIDFromCode('TRANS_INVENTORY',lv_trans_inventory_code);

        IF Ue_Rr_Revn_Mapping_Interface.isValidateNewIfacUpdPostUEE = 'TRUE' THEN
          Ue_Rr_Revn_Mapping_Interface.ValidateNewIfacUpd_Post(p_new_journal_entry_record);
        END IF;
      END IF;


    END ValidateNewIfacUpd_P;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE NewIfacUpd_SourceDoc_P(
         p_new_journal_entry_record        IN OUT NOCOPY IFAC_JOURNAL_ENTRY%ROWTYPE
        )
    IS
    BEGIN
        p_new_journal_entry_record.SOURCE_DOC_VER := NULL;
        p_new_journal_entry_record.is_max_source_doc_ver_ind := NULL;

    END NewIfacUpd_SourceDoc_P;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE NewIfacUpd_Common_P(
         p_new_journal_entry_record        IN OUT NOCOPY IFAC_JOURNAL_ENTRY%ROWTYPE
        )
    IS
    BEGIN
        p_new_journal_entry_record.record_status := nvl(p_new_journal_entry_record.record_status, ecdp_revn_common.gv2_record_status_provisional);

        IF p_new_journal_entry_record.created_by IS NULL THEN
           p_new_journal_entry_record.created_by := User;
        END IF;

        IF p_new_journal_entry_record.created_date IS NULL THEN
           p_new_journal_entry_record.created_date := Ecdp_Timestamp.getCurrentSysdate;
        END IF;

        p_new_journal_entry_record.rev_no := 0;

        -- Assign next key value for pk column, if not set by insert statement
        IF p_new_journal_entry_record.JOURNAL_ENTRY_NO IS NULL THEN
             EcDp_System_Key.assignNextNumber('IFAC_JOURNAL_ENTRY', p_new_journal_entry_record.JOURNAL_ENTRY_NO);
        END IF;

    END NewIfacUpd_Common_P;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE Register4eaTaskDetail_P(
         p_source_document_name            IFAC_JOURNAL_ENTRY.Source_Doc_Name%TYPE
        ,p_period                          IFAC_JOURNAL_ENTRY.Period%TYPE
        ,p_version                         IFAC_JOURNAL_ENTRY.SOURCE_DOC_VER%TYPE
        )
    IS
        lc_ifac_records cur_ifac_records;
        lrec_ifac_to_update T_TABLE_IFAC_JOURNAL_ENTRY;
    BEGIN
        lc_ifac_records := GetUpload_P(p_source_document_name, p_period, p_version);
        LOOP
            FETCH lc_ifac_records
                BULK COLLECT INTO lrec_ifac_to_update LIMIT 50;

            FOR idx IN 1 .. lrec_ifac_to_update.COUNT
            LOOP
                IF lrec_ifac_to_update(idx).rec_id IS NOT NULL THEN
                    Ecdp_Approval.registerTaskDetail(lrec_ifac_to_update(idx).rec_id, 'IFAC_JOURNAL_ENTRY', lrec_ifac_to_update(idx).LAST_UPDATED_BY);
                END IF;
            END LOOP;

            EXIT WHEN lrec_ifac_to_update.COUNT < 50;
        END LOOP;
    END Register4eaTaskDetail_P;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION SetRecordStatus_P(
         p_source_document_name            IFAC_JOURNAL_ENTRY.Source_Doc_Name%TYPE
        ,p_period                          IFAC_JOURNAL_ENTRY.Period%TYPE
        ,p_version                         IFAC_JOURNAL_ENTRY.SOURCE_DOC_VER%TYPE
        ,p_record_status                   ecdp_revn_common.T_RECORD_STATUS
        ,p_user                            IFAC_JOURNAL_ENTRY.LAST_UPDATED_BY%TYPE
        ) RETURN VARCHAR2
    IS
        lv2_time_string VARCHAR2(20);
        ld_time DATE;
        lv2_user_id IFAC_JOURNAL_ENTRY.LAST_UPDATED_BY%TYPE;
        lv2_rev_text IFAC_JOURNAL_ENTRY.Rev_Text%TYPE;
        lv2_approved_by IFAC_JOURNAL_ENTRY.APPROVAL_BY%TYPE;
        lv2_approved_date IFAC_JOURNAL_ENTRY.Approval_Date%TYPE;
        lv2_approved_state IFAC_JOURNAL_ENTRY.Approval_State%TYPE;
        lv2_use_4ea ECDP_REVN_COMMON.T_BOOLEAN_STR;
        lv_msg      VARCHAR2(2000);
    BEGIN
        ld_time := NVL(Ecdp_Timestamp.getCurrentSysdate, SYSDATE);
        lv2_time_string := ecdp_revn_common.GetFullDateString(ld_time);
        lv2_user_id := NVL(p_user, USER);
        lv2_use_4ea := ECDP_REVN_COMMON.gv2_false;

 lv_msg := ecdp_dataset_flow.UpdateDocFlowStatus('IFAC_JOURNAL_ENTRY',
                                                 TO_CHAR(p_period,'YYYY-MM-DD')||'$'||p_source_document_name||'$'||p_version,
                                                 p_record_status,
                                                 p_user,
                                                 true);


IF lv_msg is null then


        IF ecdp_4ea_utility.hasapproval('IFAC_JOURNAL_ENTRY') = 'Y' THEN
            -- ** 4-eyes approval logic ** --
            lv2_use_4ea := ECDP_REVN_COMMON.gv2_true;

            IF p_record_status <> ecdp_revn_common.gv2_record_status_approved THEN
              lv2_approved_state    := ecdp_revn_common.gv2_approval_state_updated;
            ELSE
              lv2_rev_text          := 'Approved at ' || lv2_time_string;
              lv2_approved_by       := p_user;
              lv2_approved_date     := ld_time;
              lv2_approved_state    := ecdp_revn_common.gv2_approval_state_updated;
            END IF;
        ELSE
            IF p_record_status = ecdp_revn_common.gv2_record_status_approved THEN
              lv2_rev_text          := 'Approved at ' || lv2_time_string;
              lv2_approved_by       := p_user;
              lv2_approved_date     := ld_time;
            END IF;
        END IF;

        UPDATE ifac_journal_entry
           SET record_status = p_record_status,
               last_updated_by = lv2_user_id,
               last_updated_date = ld_time,
               rev_text = lv2_rev_text,
               approval_by = lv2_approved_by,
               approval_date = lv2_approved_date,
               approval_state = lv2_approved_state,
               rev_no = DECODE(lv2_use_4ea, ECDP_REVN_COMMON.gv2_true, NVL(rev_no, 0) + 1, rev_no)
        WHERE ecdp_revn_common.Equals(Source_Doc_Name, p_source_document_name) = ecdp_revn_common.gv2_true
            AND period = p_period
            AND ecdp_revn_common.Equals(source_doc_ver, p_version) = ecdp_revn_common.gv2_true;

        IF lv2_use_4ea = ECDP_REVN_COMMON.gv2_true
        THEN
            Register4eaTaskDetail_P(p_source_document_name, p_period, p_version);
        END IF;

END IF;

RETURN lv_msg;

    END SetRecordStatus_P;
-----------------------------------------------------------------------
----+----------------------------------+-------------------------------
    PROCEDURE ReceiveJournalEntry(
         p_journal_entry_record            IN OUT NOCOPY IFAC_JOURNAL_ENTRY%ROWTYPE
        )
    IS
    BEGIN
        ValidateNewIfacUpd_P(p_journal_entry_record);

        NewIfacUpd_Common_P(p_journal_entry_record);
        NewIfacUpd_SourceDoc_P(p_journal_entry_record);

        INSERT INTO IFAC_JOURNAL_ENTRY
        VALUES p_journal_entry_record;

    EXCEPTION
        WHEN ex_missing_doc_name
        THEN
            raise_application_error(-20000, lv2_ex_meg_header_receive_ifac || lv2_ex_missing_doc_name_msg);
    END ReceiveJournalEntry;
    -----------------------------------------------------------------------
    ----+----+-------------------------------+-----------------------------
    FUNCTION RemoveDocumentVersion_P(
         p_source_document_name          IFAC_JOURNAL_ENTRY.Source_Doc_Name%TYPE
        ,p_period                        IFAC_JOURNAL_ENTRY.Period%TYPE
        ,p_target_version                IFAC_JOURNAL_ENTRY.Source_Doc_Ver%TYPE
        )
    RETURN NUMBER
    IS
        ln_current_version   T_IFAC_JE_SOURCE_DOCUMENT_P;
        lb_new_upload_found BOOLEAN;
        ln_updated_rows NUMBER;
    BEGIN
        ln_current_version := GetLatestDocumentVersion_P(p_source_document_name, p_period, lb_new_upload_found);

        IF lb_new_upload_found THEN
            RAISE ex_new_upload_found;
        ELSIF ln_current_version.is_null OR ln_current_version.version < p_target_version THEN
            RAISE ex_version_not_found;
        ELSIF ln_current_version.version > p_target_version THEN
            RAISE ex_newer_src_doc_found;
        END IF;

        -- Mark previous version as latest
        ln_updated_rows := UpdateSourceDocumentVerInfo_P(
             p_source_document_name
            ,p_period
            ,p_target_version - 1
            ,p_target_version - 1
            ,TRUE
            );

        -- Removes the target version
        ln_updated_rows := UpdateSourceDocumentVerInfo_P(
             p_source_document_name
            ,p_period
            ,p_target_version
            ,NULL
            ,NULL
            );

        RETURN ln_updated_rows;
    END RemoveDocumentVersion_P;

    -----------------------------------------------------------------------
    -- Applies document version on journal entries with given source
    -- document that has no document version.
    --
    -- Returns: New document version. NULL is returned if no journal
    --          entry found with no source document version.
    ----+------------------------------------+-----------------------------
    FUNCTION ApplyDocumentVersion_P(
         p_source_document_name          IFAC_JOURNAL_ENTRY.Source_Doc_Name%TYPE
        ,p_period                        IFAC_JOURNAL_ENTRY.Period%TYPE
        )
    RETURN IFAC_JOURNAL_ENTRY.SOURCE_DOC_VER%TYPE
    IS
        lo_latest_upload_doc T_IFAC_JE_SOURCE_DOCUMENT_P;
        ln_new_source_doc_ver IFAC_JOURNAL_ENTRY.SOURCE_DOC_VER%TYPE;
        ln_updated_jn NUMBER;
        lb_new_upload_found BOOLEAN;
    BEGIN
        IF p_source_document_name IS NULL
        THEN
            ln_new_source_doc_ver := gn_source_doc_ver_start;
        ELSE
            lo_latest_upload_doc := GetLatestDocumentVersion_P(
                 p_source_document_name
                ,p_period
                ,lb_new_upload_found
                );

            IF lo_latest_upload_doc.is_null
            THEN
                ln_new_source_doc_ver := gn_source_doc_ver_start;
            ELSE
                ln_new_source_doc_ver := lo_latest_upload_doc.version + gn_source_doc_ver_step;
            END IF;
        END IF;

        ln_updated_jn := UpdateSourceDocumentVerInfo_P(
            p_source_document_name
           ,p_period
           ,NULL
           ,ln_new_source_doc_ver
           ,TRUE
           );

        IF ln_updated_jn > 0 AND NOT lo_latest_upload_doc.is_null
        THEN
            ln_updated_jn := UpdateSourceDocumentVerInfo_P(
                p_source_document_name
               ,p_period
               ,lo_latest_upload_doc.version
               ,lo_latest_upload_doc.version
               ,FALSE
               );
        END IF;

        IF ln_updated_jn = 0
        THEN
            ln_new_source_doc_ver := NULL;
        END IF;

        RETURN ln_new_source_doc_ver;
    END ApplyDocumentVersion_P;
    -----------------------------------------------------------------------
    ----+----+-------------------------------+-----------------------------
    PROCEDURE ApproveAllLatestUpload
    IS
        lc_ifac_records cur_ifac_documents;
        lrec_ifac_to_update T_TABLE_IFAC_JE_SRC_DOC_L_P;
        ln_record_limit NUMBER;
    BEGIN
        ln_record_limit := 50;
        lc_ifac_records := GetUnapprovedUploads_P();

        LOOP
            FETCH lc_ifac_records
                BULK COLLECT INTO lrec_ifac_to_update LIMIT ln_record_limit;

            FOR idx IN 1 .. lrec_ifac_to_update.COUNT
            LOOP
                ApproveLatestUpload(lrec_ifac_to_update(idx).name, lrec_ifac_to_update(idx).period);
            END LOOP;

            EXIT WHEN lrec_ifac_to_update.COUNT < ln_record_limit;
        END LOOP;
    END ApproveAllLatestUpload;
    -----------------------------------------------------------------------
    ----+----+-------------------------------+-----------------------------
    PROCEDURE ApproveLatestUpload(
         p_source_document_name          IFAC_JOURNAL_ENTRY.Source_Doc_Name%TYPE
        ,p_period                        IFAC_JOURNAL_ENTRY.Period%TYPE
        )
    IS
        ln_new_version IFAC_JOURNAL_ENTRY.Source_Doc_Ver%TYPE;
        ln_user IFAC_JOURNAL_ENTRY.LAST_UPDATED_BY%TYPE;
        lv_return varchar2(4000);
    BEGIN
        ln_user := ecdp_context.getAppUser();

        ln_new_version := ApplyDocumentVersion_P(p_source_document_name, p_period);

        IF ln_new_version IS NULL
        THEN
            raise_application_error(ln_default_app_error_num, lv2_ex_meg_header_approve);
        END IF;

        lv_return:= SetRecordStatus_P(p_source_document_name, p_period, ln_new_version, ecdp_revn_common.gv2_record_status_approved, ln_user);

    END ApproveLatestUpload;
    -----------------------------------------------------------------------
    ----+----+-------------------------------+-----------------------------
    PROCEDURE UnApproveLatestUpload(
         p_source_document_name          IFAC_JOURNAL_ENTRY.Source_Doc_Name%TYPE
        ,p_period                        IFAC_JOURNAL_ENTRY.Period%TYPE
        )
    IS
        ln_current_doc_verion T_IFAC_JE_SOURCE_DOCUMENT_P;
        lb_new_upload_found BOOLEAN;
    BEGIN
        ln_current_doc_verion := GetLatestDocumentVersion_P(p_source_document_name, p_period, lb_new_upload_found);


        UnApproveUpload(p_source_document_name, p_period, ln_current_doc_verion.version);

    END UnApproveLatestUpload;
    -----------------------------------------------------------------------
    ----+----+-------------------------------+-----------------------------
    PROCEDURE UnApproveUpload(
         p_source_document_name          IFAC_JOURNAL_ENTRY.Source_Doc_Name%TYPE
        ,p_period                        IFAC_JOURNAL_ENTRY.Period%TYPE
        ,p_target_version                IFAC_JOURNAL_ENTRY.Source_Doc_Ver%TYPE
        )
    IS
        ln_user               IFAC_JOURNAL_ENTRY.LAST_UPDATED_BY%TYPE;
        ln_updated_rows_count NUMBER;
        lv_return VARCHAR2(4000);
    BEGIN
        ln_user := ecdp_context.getAppUser();

        lv_return := SetRecordStatus_P(p_source_document_name, p_period, p_target_version, ecdp_revn_common.gv2_record_status_provisional, ln_user);

        IF lv_return IS NOT NULL THEN

            raise_application_error(ln_default_app_error_num,lv_return);

        END IF;


        IF lv_return IS NULL THEN
                ln_updated_rows_count := RemoveDocumentVersion_P(p_source_document_name, p_period, p_target_version);
        END IF;

    EXCEPTION
        WHEN ex_newer_src_doc_found
        THEN
            raise_application_error(ln_default_app_error_num, lv2_ex_meg_header_unapprove || lv2_ex_newer_src_doc_found_msg);
        WHEN ex_version_not_found
        THEN
            raise_application_error(ln_default_app_error_num, lv2_ex_meg_header_unapprove || lv2_ex_version_not_found_msg);
        WHEN ex_new_upload_found
        THEN
            raise_application_error(ln_default_app_error_num, lv2_ex_meg_header_unapprove || lv2_ex_new_upload_found_msg);
    END UnApproveUpload;
    -----------------------------------------------------------------------
    -- Checking if an interfaced item exists in the INTERFACED_ERP_ITEM list.
    ----+----+-------------------------------+-----------------------------
    FUNCTION ItemExists(
         p_class_type                        INTERFACED_ERP_ITEM.Class_Type%TYPE
        ,p_object_code                       INTERFACED_ERP_ITEM.Object_Code%TYPE
        ,p_ignore_type                       INTERFACED_ERP_ITEM.Ignore%TYPE DEFAULT NULL
        ,p_source_document_name              INTERFACED_ERP_ITEM.Source_Doc_Name%TYPE DEFAULT NULL
        ,p_daytime                           INTERFACED_ERP_ITEM.Daytime%Type DEFAULT NULL
        ,p_source_document_version           INTERFACED_ERP_ITEM.Source_Doc_Ver%TYPE DEFAULT NULL
        )
    RETURN BOOLEAN
    IS
        CURSOR c_item_count
        IS
            select count(*) as item_count
              from INTERFACED_ERP_ITEM
             where class_type = p_class_type
               and object_code = p_object_code
               and source_doc_name = nvl(p_source_document_name, source_doc_name)
               and trunc(daytime,'MM') = trunc(nvl(p_daytime, trunc(daytime,'MM')),'MM')
               and source_doc_ver = nvl(p_source_document_version, source_doc_ver)
               and nvl(ignore,'NULL') = nvl(p_ignore_type, nvl(ignore,'NULL'));

        ln_item_count                        NUMBER := 0;
    BEGIN
        FOR i_count IN c_item_count()
        LOOP
            ln_item_count := i_count.item_count;
        END LOOP;

        RETURN CASE ln_item_count WHEN 0 THEN FALSE ELSE TRUE END;
    END ItemExists;
    -----------------------------------------------------------------------
    -- Generating a list of interfaced objects which is not known by EC.
    -- Returns user feedback to be used in screens.
    ----+----+-------------------------------+-----------------------------
    FUNCTION GenerateMissingList(
         p_source_document_name              VARCHAR2
        ,p_daytime                           VARCHAR2
        ,p_source_document_version           VARCHAR2
        )
    RETURN VARCHAR2
    IS
        CURSOR c_new_ifac_objects(
             cp_source_doc_name              IFAC_JOURNAL_ENTRY.Source_Doc_Name%TYPE
            ,cp_period                       IFAC_JOURNAL_ENTRY.Period%TYPE
            ,cp_source_doc_ver               IFAC_JOURNAL_ENTRY.Source_Doc_Ver%TYPE
            )
        IS
              select * from (
                select 'FIN_ACCOUNT' as class_type, fin_account_code as object_code, fin_account_descr as object_name, period, source_doc_name, source_doc_ver
                  from IFAC_JOURNAL_ENTRY
                 where fin_account_code  is not null and fin_account_code not in (select object_code from fin_account)

                union all
                select 'FIN_COST_CENTER', fin_cost_center_code, fin_cost_center_descr, period, source_doc_name, source_doc_ver
                  from IFAC_JOURNAL_ENTRY
                 where fin_cost_center_code is not null and fin_cost_center_code not in (select object_code from fin_cost_center)

                union all
                select 'FIN_REVENUE_ORDER', fin_revenue_order_code, fin_revenue_order_descr, period, source_doc_name, source_doc_ver
                  from IFAC_JOURNAL_ENTRY
                 where fin_revenue_order_code is not null and fin_revenue_order_code not in (select object_code from fin_revenue_order)

                union all
                select 'FIN_WBS', fin_wbs_code, fin_wbs_descr, period, source_doc_name, source_doc_ver
                  from IFAC_JOURNAL_ENTRY
                 where fin_wbs_code is not null and fin_wbs_code not in (select object_code from fin_wbs)
            )
            where trunc(period,'MM') = trunc(cp_period,'MM')
            and source_doc_name = cp_source_doc_name
            and source_doc_ver = cp_source_doc_ver;

        ld_daytime                           DATE := to_date(p_daytime,'yyyy-MM-dd"T"HH24:MI:SS');
        ln_source_document_version           NUMBER := to_number(p_source_document_version);
        ln_pending_item_count                NUMBER := 0;
        lb_item_always_ignored               BOOLEAN := FALSE;
        lb_item_exists_on_new                BOOLEAN := FALSE;
        lv_ignore                            VARCHAR2(32);
        lv_end_user_message                  VARCHAR2(240);
        ex_validation_error                  EXCEPTION;
    BEGIN
        --Verify that the source document is approved.
        IF p_source_document_version IS NULL OR ln_source_document_version IS NULL THEN
            lv_end_user_message := 'Warning!' || chr(10) || 'Not possible to execute. Current source document ''' || p_source_document_name || ''' is not approved!';
        END IF;
        IF lv_end_user_message IS NOT NULL THEN
            RAISE ex_validation_error;
        END IF;

        --Loop over the new and unknown objects from ifac
        FOR i_new_objects IN c_new_ifac_objects(p_source_document_name, ld_daytime, ln_source_document_version)
        LOOP
            --Check if always ignored. If so, keep the same for the new ref.
            lb_item_always_ignored := ItemExists(i_new_objects.class_type, i_new_objects.object_code, 'ALWAYS');
            lb_item_exists_on_new := ItemExists(i_new_objects.class_type, i_new_objects.object_code, null, i_new_objects.source_doc_name, i_new_objects.period, i_new_objects.source_doc_ver);
            lv_ignore := CASE lb_item_always_ignored WHEN TRUE THEN 'ALWAYS' ELSE null END;

            IF NOT lb_item_exists_on_new THEN
                INSERT INTO interfaced_erp_item (
                    class_type,
                    object_code,
                    daytime,
                    source_doc_name,
                    source_doc_ver,
                    name,
                    object_id,
                    ignore,
                    selected)
                VALUES (
                    i_new_objects.class_type,
                    i_new_objects.object_code,
                    i_new_objects.period,
                    i_new_objects.source_doc_name,
                    i_new_objects.source_doc_ver,
                    i_new_objects.object_name,
                    null,
                    lv_ignore,
                    null);

                ln_pending_item_count := ln_pending_item_count + 1;
            END IF;
        END LOOP;

        --Final feedback to user
        lv_end_user_message := 'Success!' || chr(10) ||
                               ln_pending_item_count || ' new object' || case ln_pending_item_count when 1 then ' is' else 's are' end || ' found in source document ''' || p_source_document_name || ''', version ' || p_source_document_version || '.';
        RETURN lv_end_user_message;

    EXCEPTION
        WHEN ex_validation_error THEN
            RETURN lv_end_user_message;
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, SQLERRM || '\n\n' || 'Technical:\n');
    END GenerateMissingList;
    -----------------------------------------------------------------------
    -- Generating a new object which is so far not known by EC.
    -- Returns user feedback to be used in screens.
    ----+----+-------------------------------+-----------------------------
    FUNCTION GenerateObject(
         p_source_document_name              VARCHAR2
        ,p_period                            VARCHAR2
        ,p_source_document_version           VARCHAR2
        ,p_start_date                        VARCHAR2
        ,p_end_date                          VARCHAR2 DEFAULT NULL
        ,p_include_code                      VARCHAR2 DEFAULT 'N'
        )
    RETURN VARCHAR2
    IS
        CURSOR c_selected_items(
             cp_source_doc_name              INTERFACED_ERP_ITEM.Source_Doc_Name%TYPE
            ,cp_period                       INTERFACED_ERP_ITEM.DAYTIME%TYPE
            ,cp_source_doc_ver               INTERFACED_ERP_ITEM.Source_Doc_Ver%TYPE
            )
        IS
            select object_code, class_type, daytime, selected, object_id, description
              from TV_INTERFACED_ERP_ITEM
             where source_doc_name = cp_source_doc_name
               and trunc(daytime,'MM') = trunc(cp_period,'MM')
               and source_doc_ver = cp_source_doc_ver
               and ignore is null
               and nvl(selected,'N') = 'Y' for update;

        ld_period                            DATE := to_date(p_period,'yyyy-MM-dd"T"HH24:MI:SS');
        ld_start_date                        DATE := to_date(p_start_date,'yyyy-MM-dd"T"HH24:MI:SS');
        ld_end_date                          DATE := to_date(p_end_date,'yyyy-MM-dd"T"HH24:MI:SS');
        ln_item_count                        NUMBER := 0;
        lv_object_id                         VARCHAR2(32);
        lv_end_user_message                  VARCHAR2(240);
        ex_validation_error                  EXCEPTION;
        lv2_name                             varchar2(100);
    BEGIN
        --Validate parameters
        IF nvl(ld_end_date,ld_start_date+1) <= ld_start_date THEN
            lv_end_user_message := 'Warning!' || chr(10) || 'Not possible to execute. ''End Date'' cannot be less or equal to ''Start Date''.';
        END IF;
        IF lv_end_user_message IS NOT NULL THEN
            RAISE ex_validation_error;
        END IF;

        --Generate new objects
        FOR i_items IN c_selected_items(p_source_document_name, ld_period, p_source_document_version)
        LOOP
            ln_item_count := ln_item_count + 1;
            lv2_name :=i_items.description;
            if nvl(p_include_code,'N') = 'Y' THEN
              lv2_name :=i_items.object_code || ' ' ||  lv2_name;
            END IF;
            EcDp_Object_List.insObject(i_items.object_code, i_items.class_type, ld_start_date, ld_end_date, lv2_name,i_items.description);
            --Clean up current item
            lv_object_id := EcDp_Objects.GetObjIDFromCode(i_items.class_type, i_items.object_code);
            update INTERFACED_ERP_ITEM
               set selected = null, object_id = lv_object_id
             where current of c_selected_items;
        END LOOP;
        IF ln_item_count = 0 THEN
            lv_end_user_message := 'Warning!' || chr(10) || 'Not possible to generate objects. No selected items are found.';
            RAISE ex_validation_error;
        END IF;

        --Final feedback to user
        lv_end_user_message := 'Success!' || chr(10) ||
                               ln_item_count || ' item' || case ln_item_count when 1 then ' is' else 's are' end || ' generated as new object' || case ln_item_count when 1 then '' else 's' end || '.';
        RETURN lv_end_user_message;

    EXCEPTION
        WHEN ex_validation_error THEN
            RETURN lv_end_user_message;
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, SQLERRM || '\n\n' || 'Technical:\n');
    END GenerateObject;
    -----------------------------------------------------------------------
    -- Adding selected items to the given object list.
    -- Returns user feedback to be used in screens.
    ----+----+-------------------------------+-----------------------------
    FUNCTION AddToList(
         p_class_type                        VARCHAR2
        ,p_source_document_name              VARCHAR2
        ,p_period                            VARCHAR2
        ,p_source_document_version           VARCHAR2
        ,p_object_list_id                    VARCHAR2
        ,p_start_date                        VARCHAR2
        ,p_end_date                          VARCHAR2 DEFAULT NULL
        )
    RETURN VARCHAR2
    IS
        CURSOR c_selected_items(
             cp_class_type                   INTERFACED_ERP_ITEM.Class_Type%TYPE
            ,cp_source_doc_name              INTERFACED_ERP_ITEM.Source_Doc_Name%TYPE
            ,cp_period                       INTERFACED_ERP_ITEM.DAYTIME%TYPE
            ,cp_source_doc_ver               INTERFACED_ERP_ITEM.Source_Doc_Ver%TYPE
            )
        IS
            select class_type, object_code, daytime, source_doc_name, source_doc_ver, selected, object_id
              from INTERFACED_ERP_ITEM
             where class_type = cp_class_type
               and source_doc_name = cp_source_doc_name
               and trunc(daytime,'MM') = trunc(cp_period,'MM')
               and source_doc_ver = cp_source_doc_ver
               and ignore is null
               and object_id is not null
               and nvl(selected,'N') = 'Y' for update;

        CURSOR c_existing_item(
             cp_generic_class_name           OBJECT_LIST_SETUP.Generic_Class_Name%TYPE
            ,cp_object_id                    OBJECT_LIST_SETUP.Object_Id%TYPE
            ,cp_daytime                      OBJECT_LIST_SETUP.Daytime%TYPE
            ,cp_generic_object_code          OBJECT_LIST_SETUP.Generic_Object_Code%TYPE
            ,cp_end_date                     OBJECT_LIST_SETUP.End_Date%TYPE
            )
        IS
            select generic_object_code
              from object_list_setup
             where generic_class_name = cp_generic_class_name
               and object_id = cp_object_id
               and generic_object_code = cp_generic_object_code
               and (   --Check if "Start_Date" exists inside existing item
                       (cp_daytime between daytime and nvl(end_date-1, cp_daytime))
                       --Check if "End_Date" exists inside existing item
                       or (nvl(cp_end_date, end_date+1) between daytime+1 and nvl(end_date, nvl(cp_end_date, end_date+1)))
                       --Check if existing item exists between "Start_Date" and "End_Date"
                       or (cp_daytime < daytime and nvl(cp_end_date, nvl(end_date,daytime)+1) > nvl(end_date,daytime))
                   );

        CURSOR c_next_sort_order(
             cp_generic_class_name           OBJECT_LIST_SETUP.Generic_Class_Name%TYPE
            ,cp_object_id                    OBJECT_LIST_SETUP.Object_Id%TYPE
            )
        IS
            select (nvl(max(sort_order),0) + 10) as next_sort_order
              from object_list_setup
             where generic_class_name = cp_generic_class_name
               and object_id = cp_object_id;

        ld_period                            DATE := to_date(p_period,'yyyy-MM-dd"T"HH24:MI:SS');
        ld_start_date                        DATE := to_date(p_start_date,'yyyy-MM-dd"T"HH24:MI:SS');
        ld_end_date                          DATE := to_date(p_end_date,'yyyy-MM-dd"T"HH24:MI:SS');
        ln_item_count_selected               NUMBER := 0;
        ln_item_count_existing               NUMBER := 0;
        ln_item_count_new                    NUMBER := 0;
        ln_sort_order                        NUMBER;
        lb_exists                            BOOLEAN;
        lv_end_user_message                  VARCHAR2(240);
        ex_validation_error                  EXCEPTION;
    BEGIN
        --Validate parameters
        IF nvl(ld_end_date,ld_start_date+1) <= ld_start_date THEN
            lv_end_user_message := 'Warning!' || chr(10) || 'Not possible to execute. ''End Date'' cannot be less or equal to ''Start Date''.';
        END IF;
        IF lv_end_user_message IS NOT NULL THEN
            RAISE ex_validation_error;
        END IF;

        --Loop over selected items
        FOR i_items IN c_selected_items(p_class_type, p_source_document_name, ld_period, p_source_document_version)
        LOOP
            ln_item_count_selected := ln_item_count_selected + 1;
            lb_exists := FALSE;

            --Get existing list item
            FOR i_existing IN c_existing_item(p_class_type, p_object_list_id, ld_start_date, i_items.object_code, ld_end_date)
            LOOP
                lb_exists := TRUE;
            END LOOP;
            IF lb_exists THEN
                ln_item_count_existing := ln_item_count_existing + 1;
            END IF;

            IF p_class_type != ec_object_list_version.class_name(p_object_list_id,ld_start_date,'<=') THEN
                lv_end_user_message := 'Error!' || chr(10) || 'Not possible to execute. Chosen Object list is not the correct class
                 type.';
            END IF;
            IF ec_object_list.start_date(p_object_list_id)> ld_start_date then
                  lv_end_user_message := 'Error!' || chr(10) ||
                  'The date given is before the state date of the object list ('|| ec_object_list.start_date(p_object_list_id) || '), this is not allowed. Please correct.';
            END IF;

            if nvl(ecdp_objects.GetObjStartDate(i_items.object_id),ld_start_date)> ld_start_date then
              lv_end_user_message := 'Error!' || chr(10) ||
                      'The date given is before the state date of the object (' || ecdp_objects.GetObjCODE(i_items.object_id)|| '/' || ecdp_objects.GetObjStartDate(i_items.object_id) || '), this is not allowed. Please correct.';
            END IF;
            IF lv_end_user_message IS NOT NULL THEN
                RAISE ex_validation_error;
            END IF;

            --Create if not exists
            IF NOT lb_exists THEN
                --Get next sort_order
                FOR i_next IN c_next_sort_order(p_class_type, p_object_list_id)
                LOOP
                    ln_sort_order := i_next.next_sort_order;
                END LOOP;
                --Insert new item to list
                insert into object_list_setup (
                    object_id,           --key
                    generic_object_code, --key
                    generic_class_name,
                    daytime,             --key
                    end_date,
                    sort_order,
                    obj_id,
                    gen_rel_obj_code)    --key
                values (
                    p_object_list_id,
                    i_items.object_code,
                    p_class_type,
                    ld_start_date,
                    ld_end_date,
                    ln_sort_order,
                    i_items.object_id,
                    null);

                ln_item_count_new := ln_item_count_new + 1;
            END IF;

            --Clean up current item
            update INTERFACED_ERP_ITEM
               set selected = null, object_id = i_items.object_id
             where current of c_selected_items;
        END LOOP;
        IF ln_item_count_selected = 0 THEN
            lv_end_user_message := 'Warning!' || chr(10) || 'Not possible to execute. No selected items are found.';
            RAISE ex_validation_error;
        END IF;

        --Final feedback to user
        lv_end_user_message := 'Success!' || chr(10) ||
            ln_item_count_new || ' item' || case ln_item_count_new when 1 then ' is' else 's are' end || ' added to object list ''' || Ec_Object_List_Version.Name(p_object_list_id, ld_start_date, '<=') || '''.';
        IF ln_item_count_existing > 0 THEN
            lv_end_user_message := lv_end_user_message  || chr(10) || chr(10) ||
                'Mark: ' || chr(10) ||
                ln_item_count_existing  || ' of ' || ln_item_count_selected || ' selected items already exists in the object list for current period.';
        END IF;

        RETURN lv_end_user_message;

    EXCEPTION
        WHEN ex_validation_error THEN
            RETURN lv_end_user_message;
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, SQLERRM || '\n\n' || 'Technical:\n');
    END AddToList;
    -----------------------------------------------------------------------
    ----+----+-------------------------------+-----------------------------

    PROCEDURE CheckIfAddedToList (p_object_id VARCHAR2
                       ,p_object_code VARCHAR2,p_class_name VARCHAR2)
    IS

    CURSOR c_list_name
    IS
    select list_code,list_name from (
        select ecdp_objects.GetObjCode(s.object_id) as list_code,ecdp_objects.GetObjName(s.object_id,Ecdp_Timestamp.getCurrentSysdate) as list_name
          from OBJECT_LIST_SETUP s
         where s.obj_id = p_object_id
           and s.generic_object_code = p_object_code
           and s.generic_class_name = p_class_name)
     order by list_code;

    lv_list                  VARCHAR2(20000):= null;
    cnt                            number;
    BEGIN

          -- Loop to find all list where this object is used
          for i_list_name in c_list_name() LOOP
           -- IF i_count.item_count>0
             -- THEN
             lv_list := lv_list || case nvl(lv_list,'NULL') when 'NULL' then '' else chr(10) end ||
                       '  * ' || i_list_name.list_code || '    -    '||i_list_name.list_name;
          END LOOP;

            -- Tell the end user if any findings.
            if(lv_list is not null) then
                RAISE_APPLICATION_ERROR(-20000,'Warning!\n' || 'Not possible to delete. Current object (' || p_object_code || ') is used by these lists:\n' || lv_list || '\n\nCall stack:');

            END IF;
    END CheckIFAddedToList;

    -----------------------------------------------------------------------
    ----+----+-------------------------------+-----------------------------
END ECDP_RR_REVN_MAPPING_INTERFACE;