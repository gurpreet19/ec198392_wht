CREATE OR REPLACE PACKAGE ECDP_REVN_Actions_Cost IS

    -----------------------------------------------------------------------
    -- Ensures journal entries displayed on Journal Entry Interface screen
    -- doesn't exceed the threshold.
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
        );

    -----------------------------------------------------------------------
    -- Action for the Approval button on Journal Entry Interface screen
    ----+----------------------------------+-------------------------------
    PROCEDURE Ifac_JE_ApproveUploadDoc(
         p_source_document_name          IFAC_JOURNAL_ENTRY.Source_Doc_Name%TYPE
        ,p_period                        VARCHAR2
        ,p_source_document_version       IFAC_JOURNAL_ENTRY.SOURCE_DOC_VER%TYPE
        );

    -----------------------------------------------------------------------
    -- Action for the UnApproval button on Journal Entry Interface screen
    ----+------------------------------------+-----------------------------
    PROCEDURE Ifac_JE_UnApproveUploadDoc(
         p_source_document_name          IFAC_JOURNAL_ENTRY.Source_Doc_Name%TYPE
        ,p_period                        VARCHAR2
        ,p_source_document_version       IFAC_JOURNAL_ENTRY.SOURCE_DOC_VER%TYPE
        );
    -----------------------------------------------------------------------
    -- Ensures the number of journal entries that satisfy the serach ceria
    -- is below a certain threshold. The threshold can be configured in
    -- System Attributes.
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
        );

    -----------------------------------------------------------------------
    -- Ensures the number of unmapped journal entries that satisfy the
    -- serach ceria is below a certain threshold. The threshold can be
    -- configured in System Attributes.
    ----+----------------------------------+-------------------------------
    PROCEDURE Cont_JE_EnsureUnmappedJECount(
         p_fin_account_code       VARCHAR2
        ,p_fin_cost_center_code   VARCHAR2
        ,p_fin_revenue_order_code VARCHAR2
        ,p_contract_code          VARCHAR2
        ,p_dataset                VARCHAR2
        ,p_document_key           VARCHAR2
        ,p_from_date              DATE
        );

    -----------------------------------------------------------------------
    -- Ensures the number of excluded journal entries that satisfy the
    -- serach ceria is below a certain threshold. The threshold can be
    -- configured in System Attributes.
    ----+----------------------------------+-------------------------------
    PROCEDURE Cont_JE_EnsureExcludedJECount(
         p_dataset                         VARCHAR2
        ,p_document_key                    VARCHAR2
        ,p_from_date                       DATE
        );


END ECDP_REVN_Actions_Cost;