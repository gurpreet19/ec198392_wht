CREATE OR REPLACE PACKAGE EcDp_RR_Revn_Mapping IS
/****************************************************************
** Package        :  EcDp_RR_Revn_Mapping, header part
**
** $Revision: 1.40 $
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

    COSTMAP_TRACING_MODE_MC VARCHAR2(64) := 'MAPPING_CODE';
    COSTMAP_TRACING_MODE_WA VARCHAR2(64) := 'WBS_ACCOUNT';
    COSTMAP_TRACING_MODE_FULL VARCHAR2(64) := 'FULL';
    COST_MAPPING_USER_LOG_NAME CONSTANT VARCHAR2(32) := 'COST_MAP';

    -----------------------------------------------------------------------
    -- Constants for Data Mapping Source Mapping - Object Type
    -- This is a hard copy of EC Codes of Type SOURCE_MAPPING_OBJECT_TYPE
    --------+----------------------------------+---------------------------
    gv2_object_type_object CONSTANT PROSTY_CODES.CODE%TYPE := 'OBJECT';
    gv2_object_type_object_list CONSTANT PROSTY_CODES.CODE%TYPE := 'OBJECT_LIST';

    -----------------------------------------------------------------------
    -- Constants for Data Mapping Source Mapping - Source Mapping Type
    -- This is a hard copy of code used in the ALT CODE (first part) of Type
    -- COST_MAPPING_SRC_TYPE.
    --------+----------------------------------+---------------------------
    gv2_value_category_ec_code CONSTANT PROSTY_CODES.CODE%TYPE := 'EC_CODE';
    gv2_value_category_object CONSTANT PROSTY_CODES.CODE%TYPE := 'OBJECT';

    -----------------------------------------------------------------------
    --------+----------------------------------+---------------------------
    PROCEDURE DecodeJournalMappingSrcTypeStr(
             p_str                             prosty_codes.alt_code%TYPE
            ,p_value_category                  OUT VARCHAR2
            ,p_value_type_name                 OUT VARCHAR2
            ,p_journal_entry_attribute         OUT VARCHAR2
            );

    -----------------------------------------------------------------------
    --------+----------------------------------+---------------------------

    PROCEDURE q_cost_mapping_obj(p_cursor         OUT SYS_REFCURSOR,
	                             p_dataset            VARCHAR2,
	                             p_daytime            DATE,
	                             p_accrual_ind        VARCHAR2,
	                             p_object_id          VARCHAR2 DEFAULT NULL,
	                             p_group_contract_id  VARCHAR2 DEFAULT NULL,
	                             p_contract_id        VARCHAR2 DEFAULT NULL,
	                             p_report_ref_item_id VARCHAR2 DEFAULT NULL);

    PROCEDURE q_cost_mapping_obj_src(p_cursor              OUT SYS_REFCURSOR,
	                                 p_object_id               VARCHAR2,
	                                 p_daytime                 DATE,
	                                 p_report_ref_item_id      VARCHAR2,
	                                 p_screen_rep_ref_item_id  VARCHAR2 DEFAULT NULL);

    PROCEDURE q_object_list(p_cursor      OUT SYS_REFCURSOR,
                            p_object_code VARCHAR2,
                            p_daytime     DATE);



    PROCEDURE RunCostMapping(p_dataset VARCHAR2,
                             p_daytime DATE,
                             p_user    VARCHAR2);


    PROCEDURE SetCostMappingAccountID(p_object_id   VARCHAR2,
                                      p_daytime     DATE);



    PROCEDURE SetCostMappingWBSID(p_object_id   VARCHAR2,
                                  p_daytime     DATE);



    PROCEDURE CreateJournalEntry(p_rec_journal_entry cont_journal_entry%ROWTYPE);

    FUNCTION Adjust(p_type VARCHAR2, p_value NUMBER, p_adj NUMBER)
      RETURN NUMBER;

    PROCEDURE SetDatasetRecordStatus(p_document_key  VARCHAR2,
                                     p_record_status VARCHAR2,
                                     p_user          VARCHAR2,
									 p_accrual_ind   VARCHAR2);

    PROCEDURE AlignJournalEntryDataset(p_document_key VARCHAR2);

    PROCEDURE AddNewSourceMapping(
              p_cost_map_id VARCHAR2,
              p_period DATE,
              p_je_no NUMBER);

    PROCEDURE MoveUnmappedJEToManual(
              p_je_no NUMBER,
              p_target_document_key VARCHAR2);

    PROCEDURE MoveUnmappedJE(
              p_je_no               NUMBER,
              p_move_target_code    VARCHAR2,
              p_target_document_key VARCHAR2,
              p_target_cost_map_id  VARCHAR2,
              p_period              DATE,
              p_do_not_ignore       VARCHAR2 DEFAULT 'Y');

    FUNCTION CreateDocument(p_dataset   VARCHAR2,
                            p_contract_area_id varchar2,
                            p_object_id VARCHAR2,
                            p_period    DATE,
                            p_accrual   VARCHAR2,
                            p_user      VARCHAR2)
    RETURN VARCHAR2;

    PROCEDURE ReverseJournalEntries(p_document_key VARCHAR2,
                                    p_dataset      VARCHAR2,
                                    p_user_id      VARCHAR2);


    FUNCTION GetPrecedingDocNumber(p_dataset   VARCHAR2,
                                        p_period   DATE,
                                        p_object_id VARCHAR2,
                                        p_document_type varchar2,
                                        p_accrual_ind VARCHAR2 DEFAULT NULL,
                                        p_summary_setup_id VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;


    PROCEDURE CreateCostMappingTracing(p_dataset VARCHAR2,
                                                 p_daytime DATE,
                                                 p_group_contract_id VARCHAR2 DEFAULT NULL,
                                                 p_contract_id VARCHAR2 DEFAULT NULL,
                                                 p_force_create VARCHAR2 DEFAULT NULL);

    PROCEDURE ConfigureCostMappingTracingRep(p_document_key                 VARCHAR2,
                                            p_daytime                      VARCHAR2,
                                            p_user_id                      VARCHAR2,
                                            p_report_definition_group_code VARCHAR2 DEFAULT NULL,
                                            p_report_runable_no            NUMBER DEFAULT NULL);


    PROCEDURE DsSourceSetup(p_dataset VARCHAR2,
                            p_daytime DATE,
                            p_user_id VARCHAR2,
                            p_contract_group_id VARCHAR2,
                            p_contract_id VARCHAR2);

    PROCEDURE DsPostSetup(p_dataset VARCHAR2,
                            p_daytime DATE,
                            p_user_id VARCHAR2,
                            p_group_contract_id VARCHAR2 DEFAULT NULL,
                            p_contract_id VARCHAR2 DEFAULT NULL);


    FUNCTION CreateCostMappingLog(p_status         VARCHAR2,
                                  p_description     VARCHAR2)
    RETURN NUMBER;

    PROCEDURE UpdateCostMappingLog(p_log_no         NUMBER,
                                   p_status         VARCHAR2,
                                   p_description    VARCHAR2 DEFAULT NULL,
                                   p_param_dataset  VARCHAR2 DEFAULT NULL,
                                   p_param_period   DATE DEFAULT NULL);

    FUNCTION CreateCostMappingLogItem(p_log_no                  NUMBER,
                                      p_log_item_status         VARCHAR2,
                                      p_log_item_source         VARCHAR2,
                                      p_log_item_description    VARCHAR2,
                                      p_param_document_key      VARCHAR2)
    RETURN NUMBER;


    PROCEDURE InitNewCostMappingSource(p_last_updated_by VARCHAR2,
                                         p_object_id       VARCHAR2,
                                         p_daytime         DATE DEFAULT NULL);

    FUNCTION GetSplitKeyShare(p_split_item_other_id VARCHAR2 , p_split_key_id VARCHAR2)
    RETURN VARCHAR2;


    FUNCTION GetSourceMappingData (p_journal_entry_keys VARCHAR2,
                                   p_object_id       VARCHAR2,
                                   p_daytime         DATE DEFAULT NULL)
    RETURN T_TABLE_MIXED_DATA;

    FUNCTION GetSourceObjectListPopupValues(    p_action                           VARCHAR2
                                                ,p_source_OBJECT_type             VARCHAR2
                                                ,p_group_no_to_check               cost_mapping_src_setup.group_no%TYPE
                                                ,p_source_DATA_type             cost_mapping_src_setup.src_type%TYPE
                                                ,p_daytime                       cost_mapping_src_setup.daytime%TYPE
     )
    RETURN T_TABLE_VARCHAR2;




     FUNCTION GetObjectList(   p_src_datatype                        VARCHAR2,
                               p_daytime                               DATE)
     RETURN T_TABLE_VARCHAR2;


    TYPE T_TABLE_MAPPING_SOURCE_SETUP IS TABLE OF cost_mapping_src_setup%ROWTYPE;


    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION GetUnhandledCodeFromMapSetup(
         p_object_codes                    IN OUT NOCOPY T_TABLE_VARCHAR2
        ,p_journal_mapping_id              cost_mapping.object_id%TYPE
        ,p_journal_mapping_daytime         cost_mapping_version.daytime%TYPE
        ,p_source_mapping_type             cost_mapping_src_setup.src_type%TYPE
        ,p_group_no_to_check               cost_mapping_src_setup.group_no%TYPE
        )
    RETURN T_TABLE_VARCHAR2;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION GetUnhandledCodeFromMapSetup(
         p_object_codes                    IN OUT NOCOPY T_TABLE_VARCHAR2
        ,p_source_mapping_type             cost_mapping_src_setup.src_type%TYPE
        ,p_group_no_to_check               cost_mapping_src_setup.group_no%TYPE
        ,p_source_mapping_to_check         IN OUT NOCOPY T_TABLE_MAPPING_SOURCE_SETUP
        )
    RETURN T_TABLE_VARCHAR2;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
   PROCEDURE InsNewInObjectListSetUpAll(p_src_obj_list_name VARCHAR2,
                                         p_daytime         DATE DEFAULT NULL,
                                         p_src_all_codes_to_be_inserted VARCHAR2,
                                         p_src_type        VARCHAR2,
                                         p_journal_mapping_id VARCHAR2,
                                          p_jounal_entry_keys               VARCHAR2
                                        );
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
   PROCEDURE InsNewInObjectListSetUpMissing      (
         p_src_obj_list_id               VARCHAR2,
         p_daytime                         DATE DEFAULT NULL,
         p_src_all_codes_to_be_inserted    VARCHAR2,
         p_src_type                        VARCHAR2,
         p_journal_mapping_id              VARCHAR2,
          p_jounal_entry_keys               VARCHAR2
         );
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
   PROCEDURE  AddNewJrnlMapSrcSetupForAll  (p_daytime                         DATE DEFAULT NULL,
         p_src_all_codes_to_be_inserted    VARCHAR2,
         p_src_type                        VARCHAR2,
         p_journal_mapping_id              VARCHAR2,
         p_comment                          VARCHAR2,
         p_user                             VARCHAR2,
          p_jounal_entry_keys               VARCHAR2
         ) ;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
   PROCEDURE  AddNewJrnlMapSrcSetupForMiss  (p_daytime                         DATE DEFAULT NULL,
         p_src_all_codes_to_be_inserted    VARCHAR2,
         p_src_type                        VARCHAR2,
         p_journal_mapping_id              VARCHAR2,
         p_comment                          VARCHAR2,
         p_user                             VARCHAR2,
          p_jounal_entry_keys               VARCHAR2
         ) ;


    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION GetAllContractCodes(p_je_numbers             varchar2)
    return T_TABLE_VARCHAR2;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION GetAllExpenditureTypeCodes(p_je_numbers             varchar2)
    return T_TABLE_VARCHAR2;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION GetAllDocumentTypeCodes(p_je_numbers             varchar2)
    return T_TABLE_VARCHAR2;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------

    FUNCTION GetAllDatasetCodes(p_je_numbers             varchar2)
    return T_TABLE_VARCHAR2;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION GetAllCostCenterCodes(p_je_numbers             varchar2)
    return T_TABLE_VARCHAR2;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION GetAllAccountCodes(p_je_numbers  varchar2)
    return T_TABLE_VARCHAR2;
    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION GetAllWbsCodes(p_je_numbers             varchar2)
    return T_TABLE_VARCHAR2;

    -----------------------------------------------------------------------
    ----+----------------------------------+-------------------------------
    FUNCTION GetAllSourceCodes(
         p_code_type                       VARCHAR2
        ,p_je_numbers                      VARCHAR2
        )
    RETURN T_TABLE_VARCHAR2;


    -----------------------------------------------------------------------
    -- Initializes new journal mapping object.
    ----+----------------------------------+-------------------------------
    PROCEDURE InitializeNewJournalMapping(
         p_user_id                         VARCHAR2
        ,p_object_id                       VARCHAR2
        ,p_version                         DATE
        );
    -----------------------------------------------------------------------
    -- Initializes new journal mapping version.
    ----+----------------------------------+-------------------------------
    PROCEDURE InitializeNewJournalMappingVer(
         p_user_id                          VARCHAR2
        ,p_object_id                        VARCHAR2
        ,p_new_version                      DATE DEFAULT NULL
        );
    -----------------------------------------------------------------------
    -- Generates class mapping setups for the specified journal mapping
    -- version.
    ----+----------------------------------+-------------------------------
    PROCEDURE InitClassMappingSetup(
         p_user_id                          VARCHAR2
        ,p_object_id                        VARCHAR2
        ,p_daytime                          DATE DEFAULT NULL
        );
    FUNCTION GetMissingItems(
         p_object_codes                    T_TABLE_VARCHAR2
        ,p_journal_mapping_id              cost_mapping.object_id%TYPE
        ,p_journal_mapping_daytime         cost_mapping_version.daytime%TYPE
        ,p_source_mapping_type             cost_mapping_src_setup.src_type%TYPE
        )
    RETURN VARCHAR2;

	-----------------------------------------------------------------------
    -- Returns table type for tracing mapping values
    -- version.
    ----+----------------------------------+-------------------------------

    FUNCTION get_clob_col_split(P_cont_entry_no VARCHAR2)
    RETURN t_cont_split_method;


	-----------------------------------------------------------------------
    -- Initializes new Report Reference Item version.
    ----+----------------------------------+-------------------------------
    PROCEDURE InitializeNewRefltemMappingVer(
         p_user_id                          VARCHAR2
        ,p_object_id                        VARCHAR2
        ,p_new_version                      DATE DEFAULT NULL
        );

    -----------------------------------------------------------------------
    -- Generates source mapping setups for the specified reference item version.
    ----+----------------------------------+-------------------------------
	PROCEDURE InitNewRefltemMappingSource(
        p_last_updated_by                   VARCHAR2
       ,p_object_id                         VARCHAR2
       ,p_daytime                           DATE DEFAULT NULL
       );

    -----------------------------------------------------------------------
    -- Generates class mapping setups for the specified reference item version.
    ----+----------------------------------+-------------------------------
    PROCEDURE InitNewRefItemClassMapping(
        p_object_id                       VARCHAR2
       ,p_daytime                         DATE DEFAULT NULL
       );

    -----------------------------------------------------------------------
    -- Check whether the Report Reference is linked with a cost mapping
    -- or a report reference group item before updating the record.
    ----+----------------------------------+-------------------------------
    PROCEDURE CheckReportReferenceUse(
        p_object_id                       VARCHAR2
       ,p_daytime                         DATE
       ,p_dataset                         VARCHAR2
       );

    -----------------------------------------------------------------------
    -- Check whether the Report Reference Group is linked with a cost mapping
    -- or a report reference group item before updating the record.
    ----+----------------------------------+-------------------------------
    PROCEDURE CheckReportReferenceGroupUse(
        p_object_id                       VARCHAR2
       ,p_daytime                         DATE
       ,p_dataset                         VARCHAR2
       );

	-------------------------------------------------------------------------------
    ---Returns object name for given code from v_cost_mapping_src_object
    -------------------------------------------------------------------------------
    FUNCTION get_cost_map_src_obj_name(p_code        VARCHAR2 ,
                                       p_object_type VARCHAR2,
                                       p_source_type VARCHAR2) RETURN VARCHAR2;

    ---------------------------------------------------------------------------------
    -- Check whether the dataset linked with Report Reference or Group is valid
    -- when updating object start date or creating new verison of cost mapping record
    ----+----------------------------------+-----------------------------------------
    PROCEDURE CheckValidMappingDataset(
        p_object_id                       VARCHAR2
       ,p_daytime                         DATE
       );

    PROCEDURE OverRideEntry(
        p_journal_entry_no number,
        p_reference_id varchar2
       );

     PROCEDURE OverRideEntryExcl(
        p_journal_entry_no number,
        p_reference_id varchar2
       );

     FUNCTION GetExclusionValue(
        p_journal_entry_no number,
        p_column_name varchar2,
        p_journal_entry_src varchar2,
        p_daytime date) return varchar2;

END EcDp_RR_Revn_Mapping;