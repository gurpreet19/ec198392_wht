CREATE OR REPLACE PACKAGE EcDp_RR_Revn_Summary IS
/****************************************************************
** Package        :  EcDp_RR_Revn_Summary, header part
**
** $Revision: 1.33 $
**
** Purpose        :  Provide functionality for regulatory reporting Canada
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


SUMMARY_PROCESS_USER_LOG_NAME CONSTANT VARCHAR2(32) := 'SUMMARY_PC';


TYPE SUMMARY_PC_USER_LOG_ITEM_INFO IS RECORD
(
    LOG_NO                  NUMBER,
    LOG_ITEM_SOURCE         VARCHAR2(64),
    PARAM_SUMMARY_ID        VARCHAR2(32),
    PARAM_PERIOD            DATE,
    PARAM_DOCUMENT_KEY      VARCHAR2(32),
    PARAM_DATA_SET          VARCHAR2(32),
    PARAM_CONTRACT_ID       VARCHAR2(32)
);

PROCEDURE SetSummaryRecordStatusAll(
          p_summary_set VARCHAR2,
          p_record_status VARCHAR2,
          p_daytime       DATE,
          p_user VARCHAR2,
		  p_accrual_ind VARCHAR2
);

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
          );

PROCEDURE CreateSummarySetMonth(
        p_summary_set_id        VARCHAR2,
        p_period                DATE,
        p_user_id               VARCHAR2,
        p_accrual_ind           VARCHAR2,
        p_dataset               VARCHAR2 DEFAULT NULL,
        p_dataset_filter_method VARCHAR2 DEFAULT 'ALL_DATASET',
          p_silent_mode_ind       VARCHAR2 DEFAULT 'N'
        );

PROCEDURE CreateSummaryMonthTracing(p_document_key VARCHAR2);

PROCEDURE CreateSummaryMonthTracing( p_contract_id           VARCHAR2,
          p_summary_setup_id      VARCHAR2,
          p_period                DATE,
          p_user_id               VARCHAR2,
          p_accrual_ind           VARCHAR2,
          p_inventory_id          VARCHAR2 DEFAULT NULL,
          p_dataset               VARCHAR2 DEFAULT NULL,
          p_dataset_filter_method VARCHAR2 DEFAULT NULL);

FUNCTION BuildSQLQuery(
         p_rec_ssl              summary_setup_list%ROWTYPE,
         p_contract_id          VARCHAR2,
         p_period               DATE,
         p_inventory_id         VARCHAR2 DEFAULT NULL
)RETURN VARCHAR2;

PROCEDURE DeleteSummary(
          p_document_key VARCHAR2
);

FUNCTION GetSummaryDocMonth(
         p_doc_key VARCHAR2
) RETURN VARCHAR2;

PROCEDURE SetSummaryRecordStatus(
          p_document_key VARCHAR2,
          p_record_status VARCHAR2,
          p_user VARCHAR2,
		  p_accrual_ind   VARCHAR2
);

PROCEDURE SetRecordStatusOnJournalSum(p_document_key  cont_doc.document_key%type,
                          p_record_status VARCHAR2,
                          p_user          VARCHAR2);

FUNCTION IsSummaryValidForContract(
         p_contract_id VARCHAR2,
         p_summary_setup_id VARCHAR2
         )
RETURN VARCHAR2;

FUNCTION TransInvProdStream(p_prod_stream_object_id    VARCHAR2,
                            p_transaction_inventory_id VARCHAR2,
                            p_daytime                  DATE)
  RETURN VARCHAR2;

FUNCTION GetLastAppSummaryDoc(
         p_contract_id VARCHAR2,
         p_summary_setup_id VARCHAR2,
         p_period DATE,
         p_inventory_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

PROCEDURE CreateSummaryTracing(p_document_key VARCHAR2, p_period DATE, p_force_create VARCHAR2 DEFAULT NULL);

PROCEDURE ConfigureSummaryTracingReport(p_document_key                 VARCHAR2,
                                        p_daytime                      VARCHAR2,
                                        p_user_id                      VARCHAR2,
                                        p_report_definition_group_code VARCHAR2 DEFAULT NULL,
                                        p_report_runable_no            NUMBER DEFAULT NULL);

FUNCTION CreateSummaryProcessLog(p_status         VARCHAR2,
                                 p_description    VARCHAR2)
RETURN NUMBER;

PROCEDURE UpdateSummaryProcessLog(p_log_no                NUMBER,
                                 p_status                 VARCHAR2,
                                 p_description            VARCHAR2 DEFAULT NULL,
                                 p_param_dataset          VARCHAR2 DEFAULT NULL,
                                 p_param_period           DATE DEFAULT NULL,
                                 p_param_summary_set_id   VARCHAR2 DEFAULT NULL,
                                 p_param_summary_id       VARCHAR2 DEFAULT NULL,
                                 p_contract_id            VARCHAR2 DEFAULT NULL);

PROCEDURE CreateSummaryProcessLogItem(p_log_item_info           SUMMARY_PC_USER_LOG_ITEM_INFO,
                                      p_log_item_status         VARCHAR2,
                                      p_log_item_description    VARCHAR2);

PROCEDURE InitNewSummarySetVersion(p_user_id VARCHAR2, p_summary_set_id VARCHAR2, p_daytime DATE);


FUNCTION GetJournalEntryHistory(p_journal_entry_no NUMBER)
RETURN T_TABLE_JOURNAL_ENTRY_REF_INFO;

PROCEDURE CreateSummaryYear(
          p_contract_id           VARCHAR2,
          p_summary_setup_id      VARCHAR2,
          p_year                  DATE,
          p_time_scope            VARCHAR2,
          p_user_id               VARCHAR2,
          p_accrual_ind           VARCHAR2,
          p_inventory_id          VARCHAR2 DEFAULT NULL,
          p_silent_mode_ind       VARCHAR2 DEFAULT 'Y'
          );

PROCEDURE PopulateSummaryYear(
          p_contract_id           VARCHAR2,
          p_summary_setup_id      VARCHAR2,
          p_year                  DATE,
          p_time_scope            VARCHAR2,
          p_user_id               VARCHAR2
          );

PROCEDURE SetSummaryYearRecordStatus(
          p_contract_id VARCHAR2,
          p_summary_setup_id VARCHAR2,
          p_summary_year DATE,
          p_time_scope VARCHAR2,
          p_record_status VARCHAR2,
          p_user VARCHAR2,
          p_inventory_id     VARCHAR2 DEFAULT NULL,
		  p_accrual_ind  VARCHAR2
);

FUNCTION GetLastSummaryDocKey(p_contract_id VARCHAR2,
                              p_summary_setup_id VARCHAR2,
                              p_summary_year DATE,
                              p_month VARCHAR2,
                              p_inventory_id VARCHAR2  DEFAULT NULL)
RETURN VARCHAR2;
FUNCTION GetPreSummaryDocKey(p_contract_id VARCHAR2,
                              p_summary_setup_id VARCHAR2,
                              p_summary_year DATE,
                              p_month VARCHAR2,
                              p_inventory_id VARCHAR2  DEFAULT NULL)
RETURN VARCHAR2;

FUNCTION ValidateMonth( p_month VARCHAR2) RETURN VARCHAR2;
FUNCTION GetLastSummaryDocStatus(p_contract_id VARCHAR2,
                                 p_summary_setup_id VARCHAR2,
                                 p_summary_year DATE,
                                 p_month VARCHAR2,
                                 p_inventory_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;
FUNCTION GetPreSummaryDocStatus(p_contract_id VARCHAR2,
                                 p_summary_setup_id VARCHAR2,
                                 p_summary_year DATE,
                                 p_month VARCHAR2,
                                 p_inventory_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

FUNCTION IsSummarySetSetupExist(p_object_id VARCHAR2,
                                p_daytime DATE,
                                p_summary_setup_id VARCHAR2,
                                p_contract_id VARCHAR2,
                                p_inventory_id VARCHAR2)
RETURN NUMBER;



FUNCTION getextractmsg(p_summary_set VARCHAR2 ,
                       p_record_status VARCHAR2,
                       p_accrual_ind VARCHAR2,
                       p_daytime     varchar2) RETURN VARCHAR2;

END EcDp_RR_Revn_Summary;