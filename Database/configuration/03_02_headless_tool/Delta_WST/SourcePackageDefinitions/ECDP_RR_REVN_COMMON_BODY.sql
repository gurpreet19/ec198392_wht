CREATE OR REPLACE PACKAGE BODY EcDp_RR_Revn_Common IS
/****************************************************************
** Package        :  EcDp_RR_Revn_Common, body part
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : SetRecordStatus
-- Description    : The Procedure will set record status for the document
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
PROCEDURE SetRecordStatusOnDocument(p_document_key  cont_doc.document_key%type,
                          p_record_status VARCHAR2,
                          p_user          VARCHAR2,
                          p_class_name VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS
    lv2_last_update_date VARCHAR2(20);
    lv2_4e_recid cont_doc.rec_id%TYPE;
    lv2_summary_setup_id CONT_DOC.SUMMARY_SETUP_ID%TYPE; -- It will store Summary Setup object Id
    lv2_set_when_verified SUMMARY_SETUP.SET_WHEN_VERIFIED%TYPE; -- It will store wheather "Set reporting period when Verified" is checked or not
BEGIN
    lv2_last_update_date := to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS');

    SELECT SUMMARY_SETUP_ID into lv2_summary_setup_id FROM CONT_DOC WHERE DOCUMENT_KEY=p_document_key;

    IF lv2_summary_setup_id IS NOT NULL THEN
      SELECT SET_WHEN_VERIFIED into lv2_set_when_verified FROM SUMMARY_SETUP WHERE OBJECT_ID=lv2_summary_setup_id;
    END IF;

    IF p_class_name IS NOT NULL AND NVL(EcDp_ClassMeta_Cnfg.getApprovalInd(p_class_name),'N') = 'Y' THEN

      -- ** 4-eyes approval logic ** --
      lv2_4e_recid := ec_cont_doc.rec_id(p_document_key);

      IF p_record_status = 'V' AND nvl(lv2_set_when_verified,'N')='Y' THEN -- Set reporting period for Verified record only when "Set reporting period when Verified" is checked
        UPDATE cont_doc cd
           SET cd.record_status     = p_record_status,
               cd.reporting_period  = GetCurrentReportingPeriod(cd.object_id, cd.daytime),
               cd.last_updated_by   = p_user,
               cd.last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
               cd.rev_text          = 'Verified at ' || lv2_last_update_date,
               approval_by          = p_user, --This will change to  verified_by = p_user, as verified_by column is not in the table right now,
               approval_date        = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
               approval_state    = 'U',
               rev_no = (nvl(rev_no, 0) + 1)
         WHERE document_key = p_document_key;

      ELSIF  p_record_status <> 'A' THEN
        UPDATE cont_doc cd
           SET cd.record_status     = p_record_status,
               cd.reporting_period  = NULL,
               cd.last_updated_by   = p_user,
               cd.last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
               cd.rev_text          = NULL,
               approval_by          = NULL,
               approval_date        = NULL,
               approval_state    = 'U',
               rev_no = (nvl(rev_no, 0) + 1)
         WHERE document_key = p_document_key;

      ELSE
        UPDATE cont_doc cd
           SET cd.record_status     = p_record_status,
               cd.reporting_period  = nvl(cd.reporting_period,GetCurrentReportingPeriod(cd.object_id, cd.daytime)),
               cd.last_updated_by   = p_user,
               cd.last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
               cd.rev_text          = 'Approved at ' || lv2_last_update_date,
               approval_by          = p_user,
               approval_date        = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
               approval_state    = 'U',
               rev_no = (nvl(rev_no, 0) + 1)
         WHERE document_key = p_document_key;

       -- Register new record for approval
       IF lv2_4e_recid IS NOT NULL THEN
           -- Some times the REC_ID is null even if the Approval is turned on,
           -- usually those are the old data that have been created before
           -- turning on the Approval.
           Ecdp_Approval.registerTaskDetail(lv2_4e_recid, p_class_name, Nvl(p_user, User));
       END IF;

      -- ** END 4-eyes approval ** --
      END IF;
    ELSE
      IF p_record_status = 'V' AND nvl(lv2_set_when_verified,'N')='Y' THEN --and (set on verfiide  true)
        UPDATE cont_doc cd
           SET cd.record_status     = p_record_status,
               cd.reporting_period  = GetCurrentReportingPeriod(cd.object_id, cd.daytime),
               cd.last_updated_by   = p_user,
               cd.last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
               cd.rev_text          = 'Verified at ' || lv2_last_update_date,
               approval_by          = p_user, --This will change to  verified_by = p_user, as verified_by column is not in the table right now,
               approval_date        = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE document_key = p_document_key;

      ELSIF p_record_status <> 'A' THEN
        UPDATE cont_doc cd
           SET cd.record_status     = p_record_status,
               cd.reporting_period  = NULL,
               cd.last_updated_by   = p_user,
               cd.last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
               cd.rev_text          = NULL,
               approval_by          = NULL,
               approval_date        = NULL
         WHERE document_key = p_document_key;

      ELSE
        UPDATE cont_doc cd
           SET cd.record_status     = p_record_status,
               cd.reporting_period  = nvl(cd.reporting_period , GetCurrentReportingPeriod(cd.object_id, cd.daytime)),
               cd.last_updated_by   = p_user,
               cd.last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
               cd.rev_text          = 'Approved at ' || lv2_last_update_date,
               approval_by          = p_user,
               approval_date        = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS')
         WHERE document_key = p_document_key;
      END IF;
    END IF;

END SetRecordStatusOnDocument;


    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE SetRecordStatusOnMappedJE_P(
         p_document_key                    cont_doc.document_key%TYPE
        ,p_record_status                   VARCHAR2
        ,p_user                            VARCHAR2
        )
    IS
        lv2_last_update_date VARCHAR2(20);

        CURSOR c_changed_entries_cont(cp_document_key VARCHAR2) IS
            SELECT DISTINCT 'CONT_JOURNAL_ENTRY' class_name, REC_ID
            FROM cont_journal_entry
            WHERE document_key = cp_document_key;

    BEGIN
        -- Set record status on child records in cont_journal_summary
        lv2_last_update_date := to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS');

        IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('CONT_JOURNAL_ENTRY'),'N') = 'Y' THEN

            -- ** 4-eyes approval logic ** --
            IF p_record_status <> 'A' THEN
              UPDATE cont_journal_entry
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
              UPDATE cont_journal_entry
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
          FOR lc_rec_journal_entry IN c_changed_entries_cont(p_document_key) LOOP
            -- Some times the REC_ID is null even if the Approval is turned on,
            -- usually those are the old data that have been created before
            -- turning on the Approval.
            IF lc_rec_journal_entry.rec_id IS NOT NULL THEN
                Ecdp_Approval.registerTaskDetail(lc_rec_journal_entry.rec_id, lc_rec_journal_entry.CLASS_NAME, Nvl(p_user, User));
            END IF;
          END LOOP;

         -- ** END 4-eyes approval ** --

        ELSE
            IF p_record_status <> 'A' THEN
              UPDATE cont_journal_entry
                 SET record_status     = p_record_status,
                     last_updated_by   = p_user,
                     last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
                     rev_text          = NULL,
                     approval_by       = NULL,
                     approval_date     = NULL
               WHERE document_key = p_document_key;

            ELSE
              UPDATE cont_journal_entry
                 SET record_status     = p_record_status,
                     last_updated_by   = p_user,
                     last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
                     rev_text          = 'Approved at ' || lv2_last_update_date,
                     approval_by       = p_user,
                     approval_date     = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS')
               WHERE document_key = p_document_key;
            END IF;
        END IF;

    END SetRecordStatusOnMappedJE_P;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE SetRecordStatusOnExcludedJE_P(
         p_document_key                    cont_doc.document_key%TYPE
        ,p_record_status                   VARCHAR2
        ,p_user                            VARCHAR2
        )
    IS
        lv2_last_update_date VARCHAR2(20);

        CURSOR c_changed_entries_excl(cp_document_key VARCHAR2) IS
            SELECT DISTINCT 'CONT_JOURNAL_ENTRY_EXCL' class_name, REC_ID
            FROM cont_journal_entry_excl
            WHERE document_key = cp_document_key;

    BEGIN
        -- Set record status on child records in cont_journal_summary_excl
        lv2_last_update_date := to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS');

        IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('CONT_JOURNAL_ENTRY_EXCL'),'N') = 'Y' THEN

            -- ** 4-eyes approval logic ** --

            IF p_record_status <> 'A' THEN
              UPDATE cont_journal_entry_excl
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
              UPDATE cont_journal_entry_excl
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
          FOR lc_rec_journal_entry IN c_changed_entries_excl(p_document_key) LOOP
            -- Some times the REC_ID is null even if the Approval is turned on,
            -- usually those are the old data that have been created before
            -- turning on the Approval.
            IF lc_rec_journal_entry.rec_id IS NOT NULL THEN
                Ecdp_Approval.registerTaskDetail(lc_rec_journal_entry.rec_id, lc_rec_journal_entry.CLASS_NAME, Nvl(p_user, User));
            END IF;
          END LOOP;

         -- ** END 4-eyes approval ** --

        ELSE
            IF p_record_status <> 'A' THEN
              UPDATE cont_journal_entry_excl
                 SET record_status     = p_record_status,
                     last_updated_by   = p_user,
                     last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
                     rev_text          = NULL,
                     approval_by       = NULL,
                     approval_date     = NULL
               WHERE document_key = p_document_key;

            ELSE
              UPDATE cont_journal_entry_excl
                 SET record_status     = p_record_status,
                     last_updated_by   = p_user,
                     last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
                     rev_text          = 'Approved at ' || lv2_last_update_date,
                     approval_by       = p_user,
                     approval_date     = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS')
               WHERE document_key = p_document_key;
            END IF;
        END IF;

    END SetRecordStatusOnExcludedJE_P;

    -----------------------------------------------------------------------
    -- Sets record status on Data Entries in the given document
    ----+----------------------------------+-------------------------------
    PROCEDURE SetRecordStatusOnJournalEntry(
         p_document_key                    cont_doc.document_key%TYPE
        ,p_record_status                   VARCHAR2
        ,p_user                            VARCHAR2
        )
    IS
    BEGIN
        SetRecordStatusOnMappedJE_P(p_document_key, p_record_status, p_user);
        SetRecordStatusOnExcludedJE_P(p_document_key, p_record_status, p_user);

    END SetRecordStatusOnJournalEntry;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
FUNCTION CreateDocument(
         p_rec_doc cont_doc%ROWTYPE,
         p_class_name VARCHAR2 DEFAULT NULL
)
RETURN VARCHAR2
IS

  lv2_doc_key VARCHAR2(32);
  lv2_approval_state cont_doc.approval_state%TYPE;
  lv2_rec_id cont_doc.rec_id%TYPE;
  ln_rev_no cont_doc.rev_no%TYPE;
  lb_approval_enabled BOOLEAN := FALSE;

BEGIN
    lv2_doc_key := EcDp_Document.GetNextDocumentKey(p_rec_doc.object_id, p_rec_doc.daytime);

    -- ** 4-eyes approval logic ** --
    IF p_class_name IS NOT NULL AND NVL(EcDp_ClassMeta_Cnfg.getApprovalInd(p_class_name),'N') = 'Y' THEN
      lb_approval_enabled := TRUE;

      -- Generate rec_id for the new record
      lv2_approval_state := 'N';
      lv2_rec_id := SYS_GUID();
      ln_rev_no := 0;
    END IF;
    -- ** END 4-eyes approval ** --


  INSERT INTO cont_doc (
      OBJECT_ID,
      DAYTIME,
      DOCUMENT_KEY,
      PRECEDING_DOCUMENT_KEY,
      DOCUMENT_NUMBER,
      REVERSAL_DATE,
      DATASET,
      DOCUMENT_TYPE,
      STATUS_CODE,
      REFERENCE,
      SUMMARY_SETUP_ID,
      PERIOD,
      REPORTING_PERIOD,
      IS_MANUAL_IND,
      contract_id,
      inventory_id,
      COMMENTS,
      VALUE_1,
      VALUE_2,
      VALUE_3,
      VALUE_4,
      VALUE_5,
      VALUE_6,
      VALUE_7,
      VALUE_8,
      VALUE_9,
      VALUE_10,
      TEXT_1,
      TEXT_2,
      TEXT_3,
      TEXT_4,
      TEXT_5,
      TEXT_6,
      TEXT_7,
      TEXT_8,
      TEXT_9,
      TEXT_10,
      DATE_1,
      DATE_2,
      DATE_3,
      DATE_4,
      DATE_5,
      DATE_6,
      DATE_7,
      DATE_8,
      DATE_9,
      DATE_10,
      REF_OBJECT_ID_1,
      REF_OBJECT_ID_2,
      REF_OBJECT_ID_3,
      REF_OBJECT_ID_4,
      REF_OBJECT_ID_5,
      CREATED_BY,
      REC_ID,
      APPROVAL_STATE,
      REV_NO,
      ACCRUAL_IND
      )
      VALUES (
      p_rec_doc.OBJECT_ID,
      p_rec_doc.DAYTIME,
      lv2_doc_key,
      p_rec_doc.PRECEDING_DOCUMENT_KEY,
      p_rec_doc.DOCUMENT_NUMBER,
      p_rec_doc.REVERSAL_DATE,
      p_rec_doc.DATASET,
      p_rec_doc.DOCUMENT_TYPE,
      p_rec_doc.STATUS_CODE,
      p_rec_doc.REFERENCE,
      p_rec_doc.SUMMARY_SETUP_ID,
      p_rec_doc.PERIOD,
      p_rec_doc.REPORTING_PERIOD,
      'N',
      p_rec_doc.contract_id,
      p_rec_doc.inventory_id,
      p_rec_doc.COMMENTS,
      p_rec_doc.VALUE_1,
      p_rec_doc.VALUE_2,
      p_rec_doc.VALUE_3,
      p_rec_doc.VALUE_4,
      p_rec_doc.VALUE_5,
      p_rec_doc.VALUE_6,
      p_rec_doc.VALUE_7,
      p_rec_doc.VALUE_8,
      p_rec_doc.VALUE_9,
      p_rec_doc.VALUE_10,
      p_rec_doc.TEXT_1,
      p_rec_doc.TEXT_2,
      p_rec_doc.TEXT_3,
      p_rec_doc.TEXT_4,
      p_rec_doc.TEXT_5,
      p_rec_doc.TEXT_6,
      p_rec_doc.TEXT_7,
      p_rec_doc.TEXT_8,
      p_rec_doc.TEXT_9,
      p_rec_doc.TEXT_10,
      p_rec_doc.DATE_1,
      p_rec_doc.DATE_2,
      p_rec_doc.DATE_3,
      p_rec_doc.DATE_4,
      p_rec_doc.DATE_5,
      p_rec_doc.DATE_6,
      p_rec_doc.DATE_7,
      p_rec_doc.DATE_8,
      p_rec_doc.DATE_9,
      p_rec_doc.DATE_10,
      p_rec_doc.REF_OBJECT_ID_1,
      p_rec_doc.REF_OBJECT_ID_2,
      p_rec_doc.REF_OBJECT_ID_3,
      p_rec_doc.REF_OBJECT_ID_4,
      p_rec_doc.REF_OBJECT_ID_5,
      Nvl(p_rec_doc.created_by, User),
      lv2_rec_id,
      lv2_approval_state,
      ln_rev_no,
      p_rec_doc.accrual_ind
      );

    -- ** 4-eyes approval logic ** --
    IF lb_approval_enabled THEN
      -- Register new record for approval
      Ecdp_Approval.registerTaskDetail(lv2_rec_id,
                                        p_class_name,
                                        Nvl(p_rec_doc.created_by, User));
    END IF;
    -- ** END 4-eyes approval ** --

    EcDp_DATASET_FLOW.instodsflowdoc(
       CASE p_rec_doc.DOCUMENT_TYPE WHEN 'COST_DATASET' THEN 'CONT_JOURNAL_ENTRY' ELSE 'CONT_JOURNAL_SUMMARY' END,
       p_rec_doc.PERIOD,
       CASE p_rec_doc.DOCUMENT_TYPE WHEN 'COST_DATASET' THEN p_rec_doc.DATASET ELSE p_rec_doc.OBJECT_ID END,
       lv2_doc_key,
       'P',
       'N',
       NVL(p_rec_doc.SUMMARY_SETUP_ID,p_rec_doc.DATASET),
       p_rec_doc.accrual_ind,
       NULL);

    RETURN lv2_doc_key;

END CreateDocument;

    -----------------------------------------------------------------------
    -- (See header for documentation.)
    ----+----------------------------------+-------------------------------
    PROCEDURE ClearDocument(
         p_document_key                    cont_doc.document_key%TYPE
        ,p_keep_reversal_je                ecdp_revn_common.T_BOOLEAN_STR
        )
    IS
        lv2_document_type cont_doc.document_type%TYPE;
        lv2_record_status cont_doc.record_status%TYPE;
        lv2_type VARCHAR2(32);
    BEGIN

        lv2_document_type := ec_cont_doc.document_type(p_document_key);
        lv2_record_status := ec_cont_doc.record_status(p_document_key);
        lv2_type :='CONT_JOURNAL_ENTRY';

        IF ec_cont_doc.document_type(p_document_key) = 'SUMMARY' THEN
          lv2_type := 'CONT_JOURNAL_SUMMARY';
        END IF;

        IF lv2_record_status = ecdp_revn_common.gv2_record_status_approved
        THEN
            raise_application_error(-20000, 'Cannot clear an approved document, it has to be in un-approved state.');
        END IF;

       IF lv2_document_type IN ( gv2_document_type_summary,gv2_document_type_mapping)  THEN

          IF p_keep_reversal_je = 'Y' THEN
           ecdp_dataset_flow.Delete(lv2_type,
                                    p_document_key,
                                    ec_cont_doc.object_id(p_document_key),
                                    'N');
          ELSE
           ecdp_dataset_flow.Delete(lv2_type,
                                    p_document_key,
                                    ec_cont_doc.object_id(p_document_key),
                                    'Y');
          END IF;
        END IF;

        IF lv2_document_type = gv2_document_type_mapping
        THEN


            DELETE FROM cont_journal_entry cje
            WHERE document_key = p_document_key
                AND (NVL(p_keep_reversal_je, ecdp_revn_common.gv2_false) = ecdp_revn_common.gv2_false OR reversal_date IS NULL)
            AND (NVL(cje.carry_forward,'N') != 'Y' or p_keep_reversal_je='N') ;

            DELETE FROM cont_journal_entry_excl
            WHERE document_key = p_document_key;

        ELSIF lv2_document_type = gv2_document_type_summary
        THEN
            DELETE FROM cont_journal_summary
            WHERE document_key = p_document_key;

        END IF;

    END ClearDocument;

    -----------------------------------------------------------------------
    -- (See header for documentation.)
    ----+----------------------------------+-------------------------------
    PROCEDURE ClearDocument(
         p_document_key                    cont_doc.document_key%TYPE
        )
    IS
        lv2_document_type cont_doc.document_type%TYPE;
        lv2_record_status cont_doc.record_status%TYPE;
    BEGIN
        ClearDocument(p_document_key, ecdp_revn_common.gv2_false);

    END ClearDocument;

    -----------------------------------------------------------------------
    -- (See header for documentation.)
    ----+----------------------------------+-------------------------------
    PROCEDURE DeleteDocument(
         p_document_key                    cont_doc.document_key%TYPE
        )
    IS
    BEGIN
        ClearDocument(p_document_key);

        DELETE FROM cont_doc
        WHERE document_key = p_document_key;
    END DeleteDocument;

    -----------------------------------------------------------------------
    -- (See header for documentation.)
    ----+----------------------------------+-------------------------------
    PROCEDURE DeleteAllDocuments(
         p_document_type                   cont_doc.document_type%TYPE
        )
    IS
        CURSOR c_document_keys(cp_document_type cont_doc.document_type%TYPE)
        IS
            SELECT document_key
            FROM cont_doc
            WHERE document_type = NVL(cp_document_type, document_type)
            ORDER BY created_date DESC;

    BEGIN
        FOR i_document_key IN c_document_keys(p_document_type)
        LOOP
            DeleteDocument(i_document_key.document_key);
        END LOOP;

    END DeleteAllDocuments;

    -----------------------------------------------------------------------
    -- (See header for documentation.)
    ----+----------------------------------+-------------------------------
FUNCTION GetCurrentReportingPeriod(
         p_contract_id VARCHAR2,
         p_daytime DATE
) RETURN DATE
IS

  lv2_company_id VARCHAR2(32) := ec_contract_version.company_id(p_contract_id, p_daytime, '<=');
  lv2_country_id  VARCHAR2(32) := ec_company_version.country_id(lv2_company_id, p_daytime, '<=');

BEGIN

  RETURN  ecdp_fin_period.getCurrentOpenPeriod(lv2_country_id, lv2_company_id, 'JOU_ENT', 'REPORTING');

END GetCurrentReportingPeriod;


END EcDp_RR_Revn_Common;