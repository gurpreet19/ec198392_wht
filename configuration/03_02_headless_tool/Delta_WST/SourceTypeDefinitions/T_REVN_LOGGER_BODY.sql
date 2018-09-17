CREATE OR REPLACE TYPE BODY T_REVN_LOGGER AS
    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    CONSTRUCTOR FUNCTION T_REVN_LOGGER(
        p_category                         VARCHAR2
       )
    RETURN SELF AS RESULT
    IS
    BEGIN
        category := p_category;
        RETURN;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    CONSTRUCTOR FUNCTION T_REVN_LOGGER(
        p_log_no                           NUMBER
    )
    RETURN SELF AS RESULT
    IS
    BEGIN
        log_no := p_log_no;
        RETURN;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE init
    IS
    BEGIN
        IF log_no IS NULL THEN
            log_no := ecdp_revn_log.CreateLog(category, NULL, NULL, NULL);
        END IF;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE update_overall_state(
        p_description                      VARCHAR2
       ,p_status                           VARCHAR2
       )
    IS
    BEGIN
        ecdp_revn_log.UpdateLog(log_no, p_status, p_description);
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE update_overall_data(
    	p_contract_id                      VARCHAR2 DEFAULT NULL
       ,p_text_1                           VARCHAR2 DEFAULT NULL
       ,p_text_2                           VARCHAR2 DEFAULT NULL
       ,p_text_3                           VARCHAR2 DEFAULT NULL
       ,p_text_4                           VARCHAR2 DEFAULT NULL
       ,p_text_5                           VARCHAR2 DEFAULT NULL
       ,p_date_1                           DATE DEFAULT NULL
       ,p_value_1                          NUMBER DEFAULT NULL
       )
    IS
    BEGIN
        ecdp_revn_log.UpdateLog(
            log_no, NULL, NULL, p_contract_id, p_text_1, p_text_2, p_text_3,
            p_text_4, p_text_5, p_date_1, p_value_1);
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE refresh
    IS
        CURSOR c_get_info(
            cp_log_no                      NUMBER
            )
        IS
            SELECT * FROM revn_log
            WHERE log_no = cp_log_no;
    BEGIN
        IF NOT ready THEN
            RETURN;
        END IF;

        FOR log IN c_get_info(log_no) LOOP
            category := log.category;
            status := log.status;
            EXIT;
        END LOOP;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE set_log_item_data(
    	p_log_item_text_1                  VARCHAR2 DEFAULT NULL
       ,p_log_item_text_2                  VARCHAR2 DEFAULT NULL
       ,p_log_item_text_3                  VARCHAR2 DEFAULT NULL
       ,p_log_item_text_4                  VARCHAR2 DEFAULT NULL
       ,p_log_item_text_5                  VARCHAR2 DEFAULT NULL
       ,p_log_item_date_1                  DATE DEFAULT NULL
    )
    IS
    BEGIN
        log_item_text_1 := nvl(p_log_item_text_1, log_item_text_1);
        log_item_text_2 := nvl(p_log_item_text_2, log_item_text_2);
        log_item_text_3 := nvl(p_log_item_text_3, log_item_text_3);
        log_item_text_4 := nvl(p_log_item_text_4, log_item_text_4);
        log_item_text_5 := nvl(p_log_item_text_5, log_item_text_5);
        log_item_date_1 := nvl(p_log_item_date_1, log_item_date_1);
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE clear_log_item_data
    IS
    BEGIN
        set_log_item_data(NULL, NULL, NULL, NULL, NULL, NULL);
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER FUNCTION ready
    RETURN BOOLEAN
    IS
    BEGIN
        RETURN log_no IS NOT NULL;
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE error(
       p_description                       VARCHAR2
    )
    IS
    BEGIN
        log(ecdp_revn_log.LOG_STATUS_ITEM_ERROR, p_description);
    END;


    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE warning(
       p_description                       VARCHAR2
    )
    IS
    BEGIN
        log(ecdp_revn_log.LOG_STATUS_ITEM_WARNING, p_description);
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE info(
       p_description                       VARCHAR2
    )
    IS
    BEGIN
        log(ecdp_revn_log.LOG_STATUS_ITEM_INFO, p_description);
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE debug(
       p_description                       VARCHAR2
    )
    IS
    BEGIN
        log(ecdp_revn_log.LOG_STATUS_ITEM_DEBUG, p_description);
    END;

    -----------------------------------------------------------------------
    -- (See header)
    ----+----------------------------------+-------------------------------
    MEMBER PROCEDURE log(
       p_level                             VARCHAR2
      ,p_description                       VARCHAR2
    )
    IS
        l_log_item_no                      NUMBER;
    BEGIN
        l_log_item_no := ecdp_revn_log.CreateLogItem(
            log_no, NULL, p_level, NULL, p_description,
            log_level_att,
            log_item_text_1,
            log_item_text_2,
            log_item_text_3,
            log_item_text_4,
            log_item_text_5,
            log_item_date_1);
    END;
END;