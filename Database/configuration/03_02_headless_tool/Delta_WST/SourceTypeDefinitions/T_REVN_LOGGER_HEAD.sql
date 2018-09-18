CREATE OR REPLACE TYPE T_REVN_LOGGER AS OBJECT (
    log_no                             NUMBER
   ,log_level_att                      VARCHAR2(32)
   ,status                             VARCHAR2(32)
   ,category                           VARCHAR2(32)
   ,log_item_text_1                    VARCHAR2(2000)
   ,log_item_text_2                    VARCHAR2(2000)
   ,log_item_text_3                    VARCHAR2(2000)
   ,log_item_text_4                    VARCHAR2(2000)
   ,log_item_text_5                    VARCHAR2(2000)
   ,log_item_date_1                    DATE

    -----------------------------------------------------------------------
    -- Initializes a new T_REVN_LOGGER object.
    ----+----------------------------------+-------------------------------
   ,CONSTRUCTOR FUNCTION T_REVN_LOGGER(
        p_category                         VARCHAR2
    )
    RETURN SELF AS RESULT

    -----------------------------------------------------------------------
    -- Initializes the logger with existing log. Use this to append to
    -- an exsiting log.
    ----+----------------------------------+-------------------------------
   ,CONSTRUCTOR FUNCTION T_REVN_LOGGER(
        p_log_no                           NUMBER
    )
    RETURN SELF AS RESULT

    -----------------------------------------------------------------------
    -- Initializes the logger with existing log. Use this to create a new
    -- log.
    ----+----------------------------------+-------------------------------
   ,MEMBER PROCEDURE init

    -----------------------------------------------------------------------
    -- Refreshes cached info from db.
    ----+----------------------------------+-------------------------------
   ,MEMBER PROCEDURE refresh

    -----------------------------------------------------------------------
    -- Updates overall log state.
    ----+----------------------------------+-------------------------------
    ,MEMBER PROCEDURE update_overall_state(
        p_description                      VARCHAR2
       ,p_status                           VARCHAR2
       )

    -----------------------------------------------------------------------
    -- Updates overall log data,
    ----+----------------------------------+-------------------------------
    ,MEMBER PROCEDURE update_overall_data(
    	p_contract_id                      VARCHAR2 DEFAULT NULL
       ,p_text_1                           VARCHAR2 DEFAULT NULL
       ,p_text_2                           VARCHAR2 DEFAULT NULL
       ,p_text_3                           VARCHAR2 DEFAULT NULL
       ,p_text_4                           VARCHAR2 DEFAULT NULL
       ,p_text_5                           VARCHAR2 DEFAULT NULL
       ,p_date_1                           DATE DEFAULT NULL
       ,p_value_1                          NUMBER DEFAULT NULL
       )

    -----------------------------------------------------------------------
    -- Sets data for new log items.
    ----+----------------------------------+-------------------------------
   ,MEMBER PROCEDURE set_log_item_data(
    	p_log_item_text_1                  VARCHAR2 DEFAULT NULL
       ,p_log_item_text_2                  VARCHAR2 DEFAULT NULL
       ,p_log_item_text_3                  VARCHAR2 DEFAULT NULL
       ,p_log_item_text_4                  VARCHAR2 DEFAULT NULL
       ,p_log_item_text_5                  VARCHAR2 DEFAULT NULL
       ,p_log_item_date_1                  DATE DEFAULT NULL
    )

    -----------------------------------------------------------------------
    -- Clear log item data.
    ----+----------------------------------+-------------------------------
   ,MEMBER PROCEDURE clear_log_item_data

    -----------------------------------------------------------------------
    -- Append an error log message.
    ----+----------------------------------+-------------------------------
   ,MEMBER PROCEDURE error(
       p_description                       VARCHAR2
    )

    -----------------------------------------------------------------------
    -- Append a warning log message.
    ----+----------------------------------+-------------------------------
   ,MEMBER PROCEDURE warning(
       p_description                       VARCHAR2
    )

    -----------------------------------------------------------------------
    -- Append an info log message.
    ----+----------------------------------+-------------------------------
   ,MEMBER PROCEDURE debug(
       p_description                       VARCHAR2
    )

    -----------------------------------------------------------------------
    -- Append a debug log message.
    ----+----------------------------------+-------------------------------
   ,MEMBER PROCEDURE info(
       p_description                       VARCHAR2
    )

    -----------------------------------------------------------------------
    -- Append a log message.
    ----+----------------------------------+-------------------------------
   ,MEMBER PROCEDURE log(
       p_level                             VARCHAR2
      ,p_description                       VARCHAR2
    )

    -----------------------------------------------------------------------
    -- Gets a value indicating whether the logger is ready to use.
    -- If not, use 'init' procedure to prepare the log first.
    ----+----------------------------------+-------------------------------
   ,MEMBER FUNCTION ready
    RETURN BOOLEAN
);