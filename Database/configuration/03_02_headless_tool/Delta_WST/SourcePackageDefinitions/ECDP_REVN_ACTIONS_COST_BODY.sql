CREATE OR REPLACE PACKAGE BODY ECDP_REVN_Actions_Cost IS

    ln_default_je_count_threshold CONSTANT NUMBER := 500;

    -----------------------------------------------------------------------
    -- Raises the application error when journal entry count to show
    -- exceeds the threshold.
    ----+----------------------------------+-------------------------------
    PROCEDURE RaiseJEThresholdExeccedError_P(
         p_threshold                     NUMBER
        ,p_journal_entry_count           NUMBER
        ,p_journal_entry_desc            VARCHAR2
        ,p_addtional_info                VARCHAR2
        )
    IS
    BEGIN
        RAISE_APPLICATION_ERROR(
            -20000,
            'Too many journal entry records, only first ' || p_threshold || ' is fetched.\n\n'
                || 'Count of journal entries (' || p_journal_entry_count || ') ' || p_journal_entry_desc || ' is greater than threshold (' || p_threshold || '). '
                || p_addtional_info
                || 'The threshold can be changed in System Attribute Configuration with attribute type JOURNAL_ENTRY_THRESHOLD.');
    END RaiseJEThresholdExeccedError_P;

    -----------------------------------------------------------------------
    -- Gets journal entry screen display items threshold
    ----+----------------------------------+-------------------------------
    FUNCTION GetJournalEntryDispThreshold_P
    RETURN NUMBER
    IS
    BEGIN
        RETURN NVL(
            ec_ctrl_system_attribute.attribute_value(Ecdp_Timestamp.getCurrentSysdate, 'JOURNAL_ENTRY_THRESHOLD', '<='),
            ln_default_je_count_threshold);
    END GetJournalEntryDispThreshold_P;

    -----------------------------------------------------------------------
    -- See header for description.
    ----+----------------------------------+-------------------------------
    PROCEDURE Ifac_JE_EnsureJECountInDoc(
         p_source_document_name          IFAC_JOURNAL_ENTRY.Source_Doc_Name%TYPE
        ,p_period                        IFAC_JOURNAL_ENTRY.Period%TYPE
        ,p_source_document_version       IFAC_JOURNAL_ENTRY.SOURCE_DOC_VER%TYPE
        ,p_fin_account_code              IFAC_JOURNAL_ENTRY.Fin_Account_Code%TYPE
	,p_fin_wbs_code                  IFAC_JOURNAL_ENTRY.Fin_Wbs_Code%TYPE
        ,p_fin_cost_center_code          IFAC_JOURNAL_ENTRY.Fin_Cost_Center_Code%TYPE
        ,p_fin_revenue_order_code        IFAC_JOURNAL_ENTRY.Fin_Revenue_Order_Code%TYPE
        ,p_fin_contract                  IFAC_JOURNAL_ENTRY.Contract_Code%TYPE
        ,p_dataset                       IFAC_JOURNAL_ENTRY.Dataset%TYPE
        )
    IS
        ln_threshold NUMBER;
        ln_journal_entry_count NUMBER;

        count_higher_than_threshold EXCEPTION;
    BEGIN
        ln_threshold := GetJournalEntryDispThreshold_P;

        SELECT COUNT(*) INTO ln_journal_entry_count
        FROM IFAC_JOURNAL_ENTRY
        WHERE
            ((p_source_document_name IS NULL AND SOURCE_DOC_NAME IS NULL) OR (p_source_document_name = SOURCE_DOC_NAME))
            AND ecdp_revn_common.Equals(trunc(PERIOD,'MM'), trunc(p_period,'MM')) = 'Y'
            AND ((p_source_document_version IS NULL AND SOURCE_DOC_VER IS NULL) OR (p_source_document_version = SOURCE_DOC_VER))
            AND ecdp_revn_common.Equals(p_fin_account_code, FIN_ACCOUNT_CODE, 'Y') = 'Y'
	    AND ecdp_revn_common.Equals(p_fin_wbs_code, FIN_WBS_CODE, 'Y') = 'Y'
            AND ecdp_revn_common.Equals(p_fin_cost_center_code, FIN_COST_CENTER_CODE, 'Y') = 'Y'
            AND ecdp_revn_common.Equals(p_fin_revenue_order_code, FIN_REVENUE_ORDER_CODE, 'Y') = 'Y'
            AND ecdp_revn_common.Equals(p_fin_contract, CONTRACT_CODE, 'Y') = 'Y'
            AND ecdp_revn_common.Equals(p_dataset, DATASET, 'Y') = 'Y';

        IF ln_threshold < ln_journal_entry_count THEN
            RaiseJEThresholdExeccedError_P(ln_threshold, ln_journal_entry_count, 'linked to the selected source document', NULL);
        END IF;

    END Ifac_JE_EnsureJECountInDoc;

    -----------------------------------------------------------------------
    -- See header for description.
    ----+----------------------------------+-------------------------------
    PROCEDURE Ifac_JE_ApproveUploadDoc(
         p_source_document_name          IFAC_JOURNAL_ENTRY.Source_Doc_Name%TYPE
        ,p_period                        VARCHAR2
        ,p_source_document_version       IFAC_JOURNAL_ENTRY.SOURCE_DOC_VER%TYPE
        )
    IS
    BEGIN

        ecdp_rr_revn_mapping_interface.ApproveLatestUpload(p_source_document_name, TO_DATE(p_period,'yyyy-MM-dd"T"HH24:MI:SS'));

    END Ifac_JE_ApproveUploadDoc;

    -----------------------------------------------------------------------
    -- See header for description.
    ----+----------------------------------+-------------------------------
    PROCEDURE Ifac_JE_UnApproveUploadDoc(
         p_source_document_name          IFAC_JOURNAL_ENTRY.Source_Doc_Name%TYPE
        ,p_period                        VARCHAR2
        ,p_source_document_version       IFAC_JOURNAL_ENTRY.SOURCE_DOC_VER%TYPE
        )
    IS
    BEGIN


        ecdp_rr_revn_mapping_interface.UnApproveUpload(p_source_document_name,
        TO_DATE(p_period,'yyyy-MM-dd"T"HH24:MI:SS')  , p_source_document_version);

    END Ifac_JE_UnApproveUploadDoc;

    -----------------------------------------------------------------------
    -- See header for description.
    ----+----------------------------------+-------------------------------
    PROCEDURE Cont_JE_EnsureMappedJECount(
         p_fin_account_code                VARCHAR2
        ,p_fin_cost_center_code            VARCHAR2
        ,p_fin_revenue_order_code          VARCHAR2
        ,p_contract_code                   VARCHAR2
        ,p_dataset                         VARCHAR2
        ,p_document_key                    VARCHAR2
        ,p_manual_ind                      VARCHAR2
        ,p_from_date                       DATE
        )
    IS
        ln_manual_ind VARCHAR2(1);
        ln_threshold NUMBER;
        ln_journal_entry_count NUMBER;
        count_higher_than_threshold EXCEPTION;

    BEGIN
        IF p_manual_ind != 'Y' OR p_manual_ind IS NULL
        THEN
            ln_manual_ind := 'N';
        ELSE
            ln_manual_ind := 'Y';
        END IF;

        ln_threshold := GetJournalEntryDispThreshold_P;

        select count(JOURNAL_ENTRY_NO) INTO ln_journal_entry_count
        from CONT_JOURNAL_ENTRY
        WHERE (p_fin_account_code is null OR FIN_ACCOUNT_CODE = p_fin_account_code)
            AND (p_fin_cost_center_code is null OR FIN_COST_CENTER_CODE = p_fin_cost_center_code)
            AND (p_fin_revenue_order_code is null OR FIN_REVENUE_ORDER_CODE = p_fin_revenue_order_code)
            AND (p_contract_code is null OR CONTRACT_CODE = p_contract_code)
            AND (p_dataset is null OR DATASET = p_dataset)
            AND (p_document_key is null OR DOCUMENT_KEY = p_document_key)
            AND DECODE(MANUAL_IND, 'Y', 'Y', 'N') = ln_manual_ind
            AND trunc(PERIOD,'MM') = trunc(P_from_date,'MM');

        IF ln_threshold < ln_journal_entry_count THEN
            RAISE count_higher_than_threshold;
        END IF;

        IF ln_threshold < ln_journal_entry_count THEN
            RaiseJEThresholdExeccedError_P(ln_threshold, ln_journal_entry_count, '(mapped) linked to the selected source document', NULL);
        END IF;

    END Cont_JE_EnsureMappedJECount;

    -----------------------------------------------------------------------
    -- See header for description.
    ----+----------------------------------+-------------------------------
    PROCEDURE Cont_JE_EnsureExcludedJECount(
         p_dataset                         VARCHAR2
        ,p_document_key                    VARCHAR2
        ,p_from_date                       DATE
        )
    IS
        ln_threshold NUMBER;
        ln_journal_entry_count NUMBER;
        count_higher_than_threshold EXCEPTION;

    BEGIN
        ln_threshold := GetJournalEntryDispThreshold_P;

        select count(JOURNAL_ENTRY_NO) INTO ln_journal_entry_count
        from CONT_JOURNAL_ENTRY_EXCL
        WHERE (p_dataset is null OR DATASET = p_dataset)
            AND (p_document_key is null OR DOCUMENT_KEY = p_document_key)
            AND trunc(PERIOD,'MM') = trunc(P_from_date,'MM');

        IF ln_threshold < ln_journal_entry_count THEN
            RAISE count_higher_than_threshold;
        END IF;

        IF ln_threshold < ln_journal_entry_count THEN
            RaiseJEThresholdExeccedError_P(ln_threshold, ln_journal_entry_count, '(excluded) linked to the selected source document', NULL);
        END IF;

    END Cont_JE_EnsureExcludedJECount;

    -----------------------------------------------------------------------
    -- See header for description.
    ----+----------------------------------+-------------------------------
    PROCEDURE Cont_JE_EnsureUnmappedJECount(
         p_fin_account_code       VARCHAR2
        ,p_fin_cost_center_code   VARCHAR2
        ,p_fin_revenue_order_code VARCHAR2
        ,p_contract_code          VARCHAR2
        ,p_dataset                VARCHAR2
        ,p_document_key           VARCHAR2
        ,p_from_date              DATE
        )
    IS
        ln_threshold NUMBER;
        ln_journal_entry_count NUMBER;
        count_higher_than_threshold EXCEPTION;

    BEGIN
        ln_threshold := GetJournalEntryDispThreshold_P;

        select count(JOURNAL_ENTRY_NO) INTO ln_journal_entry_count
        from V_CONT_JOURNAL_UNMAPPED
        WHERE (p_fin_account_code is null OR FIN_ACCOUNT_CODE = p_fin_account_code)
            AND (p_fin_cost_center_code is null OR FIN_COST_CENTER_CODE = p_fin_cost_center_code)
            AND (p_fin_revenue_order_code is null OR FIN_REVENUE_ORDER_CODE = p_fin_revenue_order_code)
            AND (p_contract_code is null OR CONTRACT_CODE = p_contract_code)
            AND (p_dataset is null OR DATASET = p_dataset)
            AND (p_document_key is null OR TRG_DOC_KEY = p_document_key)
            AND trunc(PERIOD,'MM') = trunc(P_from_date,'MM');

        IF ln_threshold < ln_journal_entry_count THEN
            RaiseJEThresholdExeccedError_P(ln_threshold, ln_journal_entry_count, '(unmapped) linked to the selected source document', NULL);
        END IF;

    END Cont_JE_EnsureUnmappedJECount;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------

END ECDP_REVN_Actions_Cost;