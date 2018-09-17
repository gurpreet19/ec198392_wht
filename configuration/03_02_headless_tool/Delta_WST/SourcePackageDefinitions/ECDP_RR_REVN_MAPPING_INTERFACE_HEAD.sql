CREATE OR REPLACE PACKAGE ECDP_RR_REVN_MAPPING_INTERFACE IS

    SUBTYPE T_JE_VALUE_TYPE IS VARCHAR2(1);
    gv2_je_value_type_amount CONSTANT T_JE_VALUE_TYPE := 'A';
    gv2_je_value_type_quantity CONSTANT T_JE_VALUE_TYPE := 'Q';
    gn_source_doc_ver_start CONSTANT NUMBER :=  1;
    gn_source_doc_ver_step CONSTANT NUMBER :=  1;
    gv2_allow_empty_source_doc ecdp_revn_common.T_BOOLEAN_STR := ecdp_revn_common.gv2_false;
    TYPE T_TABLE_IFAC_JOURNAL_ENTRY IS TABLE OF IFAC_JOURNAL_ENTRY%ROWTYPE;

    -----------------------------------------------------------------------
    ----+------------------------------------+-----------------------------
    PROCEDURE ReceiveJournalEntry(
         p_journal_entry_record         IN OUT NOCOPY IFAC_JOURNAL_ENTRY%ROWTYPE
        );
    -----------------------------------------------------------------------
    ----+------------------------------------+-----------------------------
    PROCEDURE ApproveAllLatestUpload;
    -----------------------------------------------------------------------
    ----+------------------------------------+-----------------------------
    PROCEDURE ApproveLatestUpload(
         p_source_document_name          IFAC_JOURNAL_ENTRY.Source_Doc_Name%TYPE
        ,p_period                        IFAC_JOURNAL_ENTRY.Period%TYPE
        );
    -----------------------------------------------------------------------
    ----+------------------------------------+-----------------------------
    PROCEDURE UnApproveLatestUpload(
         p_source_document_name          IFAC_JOURNAL_ENTRY.Source_Doc_Name%TYPE
        ,p_period                        IFAC_JOURNAL_ENTRY.Period%TYPE
        );
    -----------------------------------------------------------------------
    ----+------------------------------------+-----------------------------
    PROCEDURE UnApproveUpload(
         p_source_document_name          IFAC_JOURNAL_ENTRY.Source_Doc_Name%TYPE
        ,p_period                        IFAC_JOURNAL_ENTRY.Period%TYPE
        ,p_target_version                IFAC_JOURNAL_ENTRY.Source_Doc_Ver%TYPE
        ) ;
    -----------------------------------------------------------------------
    ----+------------------------------------+-----------------------------
    FUNCTION GenerateMissingList(
         p_source_document_name              VARCHAR2
        ,p_daytime                           VARCHAR2
        ,p_source_document_version           VARCHAR2
        )
    RETURN VARCHAR2;
    -----------------------------------------------------------------------
    ----+----+-------------------------------+-----------------------------
    FUNCTION GenerateObject(
         p_source_document_name              VARCHAR2
        ,p_period                            VARCHAR2
        ,p_source_document_version           VARCHAR2
        ,p_start_date                        VARCHAR2
        ,p_end_date                          VARCHAR2 DEFAULT NULL
        ,p_include_code                      VARCHAR2 DEFAULT 'N'
        )
    RETURN VARCHAR2;
    -----------------------------------------------------------------------
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
    RETURN VARCHAR2;
    -----------------------------------------------------------------------
    ----+----+-------------------------------+-----------------------------
	PROCEDURE CheckIfAddedToList (
		p_object_id VARCHAR2
		,p_object_code VARCHAR2
		,p_class_name VARCHAR2) ;
    -----------------------------------------------------------------------
    ----+----+-------------------------------+-----------------------------

END ECDP_RR_REVN_MAPPING_INTERFACE;