CREATE OR REPLACE PACKAGE ecdp_revn_log IS
    /****************************************************************
    ** Package        :  EcDp_Revn_Log, header part
    **
    ** $Revision: 1.4 $
    **
    ** Purpose        :  Provide functionality for logging in revenue
    **
    ** Documentation  :  http://energyextra.tietoenator.com
    **
    **
    ** Modification history:
    **
    ** Version  Date        Whom  Change description:
    ** -------  ------      ----- --------------------------------------
    ********************************************************************/

    log_status_running CONSTANT VARCHAR2(32) := 'RUNNING';
    log_status_warning CONSTANT VARCHAR2(32) := 'WARNING';
    log_status_error   CONSTANT VARCHAR2(32) := 'ERROR';
    log_status_success CONSTANT VARCHAR2(32) := 'SUCCESS';
    log_status_unknown CONSTANT VARCHAR2(32) := 'UNKNOWN';

    log_status_item_debug   CONSTANT VARCHAR2(32) := 'DEBUG';
    log_status_item_info    CONSTANT VARCHAR2(32) := 'INFO';
    log_status_item_warning CONSTANT VARCHAR2(32) := 'WARNING';
    log_status_item_error   CONSTANT VARCHAR2(32) := 'ERROR';

    default_log_status_item_level CONSTANT VARCHAR2(32) := 'INFO';

    FUNCTION createlog
    (
        p_category    VARCHAR2
       ,p_status      VARCHAR2
       ,p_description VARCHAR2
       ,p_contract_id VARCHAR2 DEFAULT NULL
    ) RETURN NUMBER;

    PROCEDURE updatelog
    (
        p_log_no      NUMBER
       ,p_status      VARCHAR2
       ,p_description VARCHAR2 DEFAULT NULL
       ,p_contract_id VARCHAR2 DEFAULT NULL
       ,p_text_1      VARCHAR2 DEFAULT NULL
       ,p_text_2      VARCHAR2 DEFAULT NULL
       ,p_text_3      VARCHAR2 DEFAULT NULL
       ,p_text_4      VARCHAR2 DEFAULT NULL
       ,p_text_5      VARCHAR2 DEFAULT NULL
       ,p_date_1      DATE DEFAULT NULL
       ,p_value_1     NUMBER DEFAULT NULL
    );

    FUNCTION createlogitem
    (
        p_log_no                 NUMBER
       ,p_category               VARCHAR2
       ,p_log_item_status        VARCHAR2
       ,p_log_item_source        VARCHAR2
       ,p_log_item_description   VARCHAR2
       ,p_override_log_level_att VARCHAR2 DEFAULT NULL
       ,p_text_1                 VARCHAR2 DEFAULT NULL
       ,p_text_2                 VARCHAR2 DEFAULT NULL
       ,p_text_3                 VARCHAR2 DEFAULT NULL
       ,p_text_4                 VARCHAR2 DEFAULT NULL
       ,p_text_5                 VARCHAR2 DEFAULT NULL
       ,p_date_1                 DATE DEFAULT NULL
    ) RETURN NUMBER;

    FUNCTION shoulddroplogitem
    (
        p_category               VARCHAR2
       ,p_log_item_status        VARCHAR2
       ,p_override_log_level_att VARCHAR2
    ) RETURN BOOLEAN;

    FUNCTION shoulddroplogitem
    (
        p_log_item_status VARCHAR2
       ,p_log_item_level  VARCHAR2
    ) RETURN BOOLEAN;

    FUNCTION getlogstatuslevel(p_log_status VARCHAR2) RETURN NUMBER;

    FUNCTION getbatchprocesslogdescription
    (
        p_description_header VARCHAR2
       ,p_total_to_process   NUMBER DEFAULT NULL
       ,p_processed_num      NUMBER DEFAULT NULL
       ,p_succeeded_num      NUMBER DEFAULT NULL
    ) RETURN VARCHAR2;

END ecdp_revn_log;