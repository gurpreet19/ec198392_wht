CREATE OR REPLACE PACKAGE RR_DATASET_FLOW IS
PROCEDURE INIT;


FUNCTION getMappingScreen( p_return VARCHAR2,
                           p_mapping_type VARCHAR2,
                           p_direction VARCHAR2,
                           p_type varchar2 default null,
                           p_other_type varchar2 default null,
                           p_other_ref_id VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;


FUNCTION getObjectText(p_return      VARCHAR2,
                       p_ref_id VARCHAR2,
                       p_mapping_type VARCHAR2,
                       p_object_id    VARCHAR2,
                       p_daytime      DATE) RETURN VARCHAR2;


PROCEDURE InsToDsFlowDoc(
                        p_type                              VARCHAR2,
                        p_process_date                      DATE,
                        p_object                            VARCHAR2,
                        p_reference_id                      VARCHAR2,
                        p_STATUS                            VARCHAR2,
                        p_MAX_IND                           VARCHAR2,
                        p_DATASET                           VARCHAR2,
                        p_accrual_ind                       VARCHAR2,
                        p_screen_doc_type                   VARCHAR2 default null
                        );

PROCEDURE InsRRCAToDsFlowDoc(p_type            VARCHAR2,
                             p_process_date    DATE,
                             p_object          VARCHAR2,
                             p_reference_id    VARCHAR2,
                             p_status          VARCHAR2,
                             p_max_ind         VARCHAR2,
                             p_dataset         VARCHAR2,
                             p_accrual_ind     VARCHAR2,
                             p_screen_doc_type VARCHAR2 DEFAULT NULL);

FUNCTION GetDocStatus(p_type                                VARCHAR2,
                      p_reference_id                        VARCHAR2,
                      p_status                              VARCHAR2) RETURN VARCHAR2;

PROCEDURE Delete(       p_type                        VARCHAR2,
                        p_doc_id                            VARCHAR2,
                        p_object_id                         VARCHAR2,
                        p_clean                             VARCHAR2 DEFAULT 'N',
                        p_status                            VARCHAR2
                        );

PROCEDURE UpdateStatusInTables(
                        p_type                              VARCHAR2,
                        p_reference_id                      VARCHAR2,
                        p_status                            VARCHAR2,
                        p_user                              VARCHAR2);


FUNCTION UpdateRRCARoyRateStatus(p_type            VARCHAR2,
                                 p_reference_id    VARCHAR2,
                                 p_status          VARCHAR2,
                                 p_process_date    DATE,
                                 p_accrual_ind     VARCHAR2,
                                 p_user            VARCHAR2,
                                 p_no_table_update BOOLEAN DEFAULT FALSE,
                                 p_old_status      VARCHAR2 DEFAULT NULL,
                                 p_allow_unapprove BOOLEAN DEFAULT FALSE)
  RETURN VARCHAR2;

END;