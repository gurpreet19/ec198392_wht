CREATE OR REPLACE PACKAGE EcDp_RR_Revn_Common IS
    /****************************************************************
    ** Package        :  EcDp_RR_Revn_Common, header part
    **
    ** $Revision: 1.9 $
    **
    ** Purpose        :  Provide functionality for regulatory reporting Canada
    **
    ** Documentation  :  http://energyextra.tietoenator.com
    **
    ** Created  : 22.04.2010  SKJORSTI
    **
    ** Modification history:
    **
    ** Version  Date        Whom  Change description:
    ** -------  ------      ----- --------------------------------------
    ********************************************************************/

    SUBTYPE T_JE_TYPE IS VARCHAR2(32);
    gv2_je_type_je_mapping T_JE_TYPE := 'JOURNAL_MAPPING';
    gv2_je_type_je_exclusion T_JE_TYPE := 'JOURNAL_EXCLUSION';
    gv2_document_type_summary cont_doc.document_type%TYPE := 'SUMMARY';
    gv2_document_type_mapping cont_doc.document_type%TYPE := 'COST_DATASET';

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE SetRecordStatusOnDocument(
         p_document_key                    cont_doc.document_key%TYPE
        ,p_record_status                   VARCHAR2
        ,p_user                            VARCHAR2
        ,p_class_name                      VARCHAR2 DEFAULT NULL
        );

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    PROCEDURE SetRecordStatusOnJournalEntry(
         p_document_key                    cont_doc.document_key%TYPE
        ,p_record_status                   VARCHAR2
        ,p_user                            VARCHAR2
        );

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION CreateDocument(
         p_rec_doc                         cont_doc%ROWTYPE
        ,p_class_name                      VARCHAR2 DEFAULT NULL
        )
    RETURN VARCHAR2;


    -----------------------------------------------------------------------
    -- Clears content in the given document (journal entries, summary items,
    -- etc.).
    -- p_keep_reversal_je: 'Y' to keep reversal journal entries, other
    --     values including NULL will have all reversals removed.
    ----+----------------------------------+-------------------------------
    PROCEDURE ClearDocument(
         p_document_key                    cont_doc.document_key%TYPE
        ,p_keep_reversal_je                ecdp_revn_common.T_BOOLEAN_STR
        ,p_rerun                           VARCHAR2 DEFAULT 'Y'
        );

    -----------------------------------------------------------------------
    -- Clears content in the given document (journal entries, summary items,
    -- etc.).
    ----+----------------------------------+-------------------------------
    PROCEDURE ClearDocument(
         p_document_key                    cont_doc.document_key%TYPE
         );

    -----------------------------------------------------------------------
    -- Deletes the given document.
    ----+----------------------------------+-------------------------------
    PROCEDURE DeleteDocument(
         p_document_key                    cont_doc.document_key%TYPE
        );

    -----------------------------------------------------------------------
    -- Deletes all cost documents.
    ----+----------------------------------+-------------------------------
    PROCEDURE DeleteAllDocuments(
         p_document_type                   cont_doc.document_type%TYPE
        );

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION GetCurrentReportingPeriod(
         p_contract_id                     VARCHAR2
        ,p_daytime                         DATE
        )
    RETURN DATE;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------

END EcDp_RR_Revn_Common;