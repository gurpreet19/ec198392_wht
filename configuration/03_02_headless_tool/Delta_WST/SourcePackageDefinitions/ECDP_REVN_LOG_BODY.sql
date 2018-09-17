CREATE OR REPLACE PACKAGE BODY ecdp_revn_log IS
    /****************************************************************
    ** Package        :  EcDp_Revn_Log, body part
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

    FUNCTION createlog
    (
        p_category    VARCHAR2
       ,p_status      VARCHAR2
       ,p_description VARCHAR2
       ,p_contract_id VARCHAR2 DEFAULT NULL
    ) RETURN NUMBER IS
        PRAGMA AUTONOMOUS_TRANSACTION;

        ln_log_no NUMBER;
    BEGIN

        INSERT INTO revn_log
            (log_no, daytime, category, description, contract_id, status)
        VALUES
            (ln_log_no
            ,Ecdp_Timestamp.getCurrentSysdate()
            ,p_category
            ,p_description
            ,p_contract_id
            ,p_status)
        RETURNING log_no INTO ln_log_no;

        COMMIT;

        RETURN ln_log_no;

    END createlog;

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
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;

    BEGIN
        UPDATE revn_log
        SET description = nvl(p_description, description)
           ,contract_id = nvl(p_contract_id, contract_id)
           ,status = nvl(p_status, status)
           ,param_text_1 = nvl(p_text_1, param_text_1)
           ,param_text_2 = nvl(p_text_2, param_text_2)
           ,param_text_3 = nvl(p_text_3, param_text_3)
           ,param_text_4 = nvl(p_text_4, param_text_4)
           ,param_text_5 = nvl(p_text_5, param_text_5)
           ,param_date_1 = nvl(p_date_1, param_date_1)
           ,param_value_1 = nvl(p_value_1, param_value_1)
        WHERE log_no = p_log_no;

        COMMIT;

    END updatelog;

    FUNCTION createlogitem
    (
        p_log_no                 NUMBER
       ,p_category               VARCHAR2
       ,p_log_item_status        VARCHAR2
       ,p_log_item_source        VARCHAR2
       ,p_log_item_description   VARCHAR2
       ,p_override_log_level_att VARCHAR2
       ,p_text_1                 VARCHAR2 DEFAULT NULL
       ,p_text_2                 VARCHAR2 DEFAULT NULL
       ,p_text_3                 VARCHAR2 DEFAULT NULL
       ,p_text_4                 VARCHAR2 DEFAULT NULL
       ,p_text_5                 VARCHAR2 DEFAULT NULL
       ,p_date_1                 DATE DEFAULT NULL
    ) RETURN NUMBER IS
        PRAGMA AUTONOMOUS_TRANSACTION;

        ln_log_item_no NUMBER;
    BEGIN

        IF NOT shoulddroplogitem(p_category
                                ,p_log_item_status
                                ,p_override_log_level_att) THEN
            INSERT INTO revn_log_item
                (log_no
                ,item_no
                ,category
                ,daytime
                ,status
                ,SOURCE
                ,description
                ,param_text_1
                ,param_text_2
                ,param_text_3
                ,param_text_4
                ,param_text_5
                ,param_date_1)
            VALUES
                (p_log_no
                ,ln_log_item_no
                ,p_category
                ,Ecdp_Timestamp.getCurrentSysdate()
                ,p_log_item_status
                ,p_log_item_source
                ,p_log_item_description
                ,p_text_1
                ,p_text_2
                ,p_text_3
                ,p_text_4
                ,p_text_5
                ,p_date_1)
            RETURNING item_no INTO ln_log_item_no;

        END IF;

        COMMIT;

        RETURN ln_log_item_no;

    END createlogitem;

    FUNCTION shoulddroplogitem
    (
        p_category               VARCHAR2
       ,p_log_item_status        VARCHAR2
       ,p_override_log_level_att VARCHAR2
    ) RETURN BOOLEAN IS
        lv_log_item_level_att VARCHAR2(32);
        lv_log_item_min_level VARCHAR2(32);
    BEGIN
        lv_log_item_level_att := p_override_log_level_att;

        IF lv_log_item_level_att IS NULL THEN
            lv_log_item_level_att := 'REVN_' || p_category || '_LOG_LEVEL';
        END IF;

        lv_log_item_min_level := ec_ctrl_system_attribute.attribute_text(Ecdp_Timestamp.getCurrentSysdate()
                                                                        ,lv_log_item_level_att
                                                                        ,'<=');
        lv_log_item_min_level := nvl(lv_log_item_min_level
                                    ,log_status_item_info);

        RETURN getlogstatuslevel(p_log_item_status) < getlogstatuslevel(lv_log_item_min_level);

    END shoulddroplogitem;

    FUNCTION shoulddroplogitem
    (
        p_log_item_status VARCHAR2
       ,p_log_item_level  VARCHAR2
    ) RETURN BOOLEAN IS
    BEGIN
        RETURN getlogstatuslevel(p_log_item_status) < getlogstatuslevel(p_log_item_level);
    END shoulddroplogitem;

    FUNCTION getlogstatuslevel(p_log_status VARCHAR2) RETURN NUMBER IS
    BEGIN
        CASE p_log_status
            WHEN log_status_item_debug THEN
                RETURN 1;
            WHEN log_status_item_info THEN
                RETURN 2;
            WHEN log_status_item_warning THEN
                RETURN 3;
            WHEN log_status_item_error THEN
                RETURN 4;
            ELSE
                RETURN 5;
        END CASE;
    END;

    FUNCTION getbatchprocesslogdescription
    (
        p_description_header VARCHAR2
       ,p_total_to_process   NUMBER DEFAULT NULL
       ,p_processed_num      NUMBER DEFAULT NULL
       ,p_succeeded_num      NUMBER DEFAULT NULL
    ) RETURN VARCHAR2 IS
        p_failed_num NUMBER := p_processed_num - p_succeeded_num;
    BEGIN

        RETURN p_description_header || ' (' ||(CASE WHEN
                                               p_succeeded_num IS NULL THEN '?' ELSE
                                               to_char(p_succeeded_num) END) || ' succeeded/' ||(CASE WHEN
                                                                                                 p_failed_num IS NULL THEN '?' ELSE
                                                                                                 to_char(p_failed_num) END) || ' failed/' ||(CASE WHEN
                                                                                                                                             p_total_to_process IS NULL THEN '?' ELSE
                                                                                                                                             to_char(p_total_to_process) END) || ' total)';
    END getbatchprocesslogdescription;

END ecdp_revn_log;