CREATE OR REPLACE TYPE T_REVN_DOC_OP_CONTEXT AS OBJECT (
    -----------------------------------------------------------------------
    -- interface data (for period documents)
    ----+----------------------------------+-------------------------------
    ifac_period                       t_table_ifac_sales_qty
   ,ifac_cargo                        t_table_ifac_cargo_value
   ,user_id                           VARCHAR2(32)
   ,log_no                            NUMBER
   ,log_category                      VARCHAR2(32)
   ,log_level_attribute               VARCHAR2(32)
   ,processing_contract_id            VARCHAR2(32)
   ,processing_document_key           VARCHAR2(32)
   ,processing_cargo_name             VARCHAR2(100)

    -----------------------------------------------------------------------
    -- Initializes a new T_REVN_DOC_OP_CONTEXT object.
    ----+----------------------------------+-------------------------------
   ,CONSTRUCTOR FUNCTION t_revn_doc_op_context
        RETURN SELF AS RESULT


    -----------------------------------------------------------------------
    -- Configures logger with given parameters.
    -- All parameters are optional. If log number is given, the specified
    -- log will be appended; otherwise, a new log will be created using
    -- the given log type (category).
    ----+----------------------------------+-------------------------------
   ,MEMBER PROCEDURE config_logger(
        p_log_no                           NUMBER DEFAULT NULL
       ,p_log_category                     VARCHAR2 DEFAULT NULL
       ,p_log_level_attribute              VARCHAR2 DEFAULT 'DOC_GEN_LOG_LEVEL'
    )

    -----------------------------------------------------------------------
    -- Gets or creates a logger based on log_no attribute. If no log no
    -- is sat, a new log will be created.
    ----+----------------------------------+-------------------------------
   ,MEMBER PROCEDURE get_or_create_logger(
        p_logger                           OUT t_revn_logger
    )

    -----------------------------------------------------------------------
    -- Gets a value indicates if this context has no period ifac data.
    ----+----------------------------------+-------------------------------
   ,MEMBER FUNCTION is_empty_period_ifac_data RETURN BOOLEAN

    -----------------------------------------------------------------------
    -- Gets a value indicates if this context has no period ifac data.
    ----+----------------------------------+-------------------------------
   ,MEMBER FUNCTION is_empty_cargo_ifac_data RETURN BOOLEAN

    -----------------------------------------------------------------------
    -- Copies this object into a new one.
    ----+----------------------------------+-------------------------------
   ,MEMBER FUNCTION copy RETURN T_REVN_DOC_OP_CONTEXT

    -----------------------------------------------------------------------
    -- Gets a value indicates whether the given ifac has correct id
    -- sat.
    ----+----------------------------------+-------------------------------
   ,MEMBER FUNCTION has_id_ifac_period(
        p_index                            NUMBER
       ,p_transaction_id                   NUMBER
       ,p_li_id                            NUMBER
       )
    RETURN BOOLEAN


    -----------------------------------------------------------------------
    -- Gets a value indicates whether the given ifac has correct id
    -- sat.
    ----+----------------------------------+-------------------------------
   ,MEMBER FUNCTION has_id_ifac_cargo(
        p_index                            NUMBER
       ,p_transaction_id                   NUMBER
       ,p_li_id                            NUMBER
       )
    RETURN BOOLEAN

    -----------------------------------------------------------------------
    -- Removes ifac records with given ids.
    ----+----------------------------------+-------------------------------
   ,MEMBER PROCEDURE remove_ifac_period(
        p_transaction_id                   NUMBER
       ,p_li_id                            NUMBER
       )



    -----------------------------------------------------------------------
    -- Removes ifac records with given ids.
    ----+----------------------------------+-------------------------------
   ,MEMBER PROCEDURE remove_ifac_cargo(
        p_transaction_id                   NUMBER
       ,p_li_id                            NUMBER
       )


    -----------------------------------------------------------------------
    -- Removes ifac records that has line item key sat.
    ----+----------------------------------+-------------------------------
   ,MEMBER PROCEDURE remove_ifac_has_li_key_period


    -----------------------------------------------------------------------
    -- Removes ifac records that has line item key sat.
    ----+----------------------------------+-------------------------------
   ,MEMBER PROCEDURE remove_ifac_has_li_key_cargo


    -----------------------------------------------------------------------
    -- Updates keys (transaction, line item, etc.) on ifac records with
    -- given ids.
    ----+----------------------------------+-------------------------------
   ,MEMBER PROCEDURE update_ifac_keys_period(
        p_transaction_id                   NUMBER
       ,p_transaction_key                  VARCHAR
       ,p_li_id                            NUMBER
       ,p_line_item_Key                    VARCHAR
     )

    -----------------------------------------------------------------------
    -- Updates keys (transaction, line item, etc.) on ifac records with
    -- given ids.
    ----+----------------------------------+-------------------------------
   ,MEMBER PROCEDURE update_ifac_keys_period(
        p_transaction_id                   NUMBER
       ,p_document_key                     VARCHAR
       ,p_transaction_key                  VARCHAR
       ,p_li_id                            NUMBER
       ,p_line_item_Key                    VARCHAR
    )
     -----------------------------------------------------------------------
    -- Updates keys (transaction, line item, etc.) on ifac records with
    -- given ids.
    ----+----------------------------------+-------------------------------
   ,MEMBER PROCEDURE update_ifac_keys_cargo(
        p_transaction_id                   NUMBER
       ,p_transaction_key                  VARCHAR
       ,p_li_id                            NUMBER
       ,p_line_item_Key                    VARCHAR
     )

    -----------------------------------------------------------------------
    -- Updates keys (transaction, line item, etc.) on ifac records with
    -- given ids.
    ----+----------------------------------+-------------------------------
   ,MEMBER PROCEDURE update_ifac_keys_cargo(
        p_transaction_id                   NUMBER
       ,p_document_key                     VARCHAR
       ,p_transaction_key                  VARCHAR
       ,p_li_id                            NUMBER
       ,p_line_item_Key                    VARCHAR
    )

    -----------------------------------------------------------------------
    -- Updates preceding keys on ifac records with given ids.
    ----+----------------------------------+-------------------------------
   ,MEMBER PROCEDURE update_ifac_prec_keys_period(
        p_transaction_id                   NUMBER
       ,p_preceding_document_key           VARCHAR
       ,p_preceding_transaction_key        VARCHAR
       ,p_li_id                            NUMBER
       ,p_preceding_li_key                 VARCHAR
     )


    -----------------------------------------------------------------------
    -- Updates preceding keys on ifac records with given ids.
    ----+----------------------------------+-------------------------------
   ,MEMBER PROCEDURE update_ifac_prec_keys_cargo(
        p_transaction_id                   NUMBER
       ,p_preceding_document_key           VARCHAR
       ,p_preceding_transaction_key        VARCHAR
       ,p_li_id                            NUMBER
       ,p_preceding_li_key                 VARCHAR
     )

    -----------------------------------------------------------------------
    -- Updates keys (transaction, line item, etc.) on all ifac records.
    ----+----------------------------------+-------------------------------
   ,MEMBER PROCEDURE update_all_ifac_keys_period(
        p_transaction_key                  VARCHAR2
       ,p_line_item_Key                    VARCHAR2
     )

    -----------------------------------------------------------------------
    -- Updates document key on all ifac records.
    ----+----------------------------------+-------------------------------
   ,MEMBER PROCEDURE update_all_ifac_doc_key_period(
        p_document_key                     VARCHAR2
     )

    -----------------------------------------------------------------------
    -- Updates document key on all ifac records.
    ----+----------------------------------+-------------------------------
   ,MEMBER PROCEDURE update_all_ifac_doc_key_cargo(
        p_document_key                     VARCHAR2
     )

    -----------------------------------------------------------------------
    -- Gets a record from period ifac data.
    --
    -- Note:
    --     Use this function to get record from ifac_period to avoid
    --     unnecessary copying (a reference to ifac_period from outside
    --     generates a copy of ifac_period).
    ----+----------------------------------+-------------------------------
   ,MEMBER FUNCTION get_ifac_period(
        p_index                            NUMBER
     )
     RETURN t_ifac_sales_qty

    -----------------------------------------------------------------------
    -- Gets a record from cargo ifac data.
    --
    -- Note:
    --     Use this function to get record from ifac_cargo to avoid
    --     unnecessary copying (a reference to ifac_cargo from outside
    --     generates a copy of ifac_cargo).
    ----+----------------------------------+-------------------------------
   ,MEMBER FUNCTION get_ifac_cargo(
        p_index                            NUMBER
     )
     RETURN t_ifac_cargo_value
    -----------------------------------------------------------------------
    -- Gets count of records in period ifac data.
    --
    -- Note:
    --     Use this function to get count from ifac_period to avoid
    --     unnecessary copying (a reference to ifac_period from outside
    --     generates a copy of ifac_period).
    ----+----------------------------------+-------------------------------
   ,MEMBER FUNCTION ifac_period_count
     RETURN NUMBER

  -----------------------------------------------------------------------
    -- Gets count of records in cargo ifac data.
    --
    -- Note:
    --     Use this function to get count from ifac_cargo to avoid
    --     unnecessary copying (a reference to ifac_cargo from outside
    --     generates a copy of ifac_cargo).
    ----+----------------------------------+-------------------------------
   ,MEMBER FUNCTION ifac_cargo_count
     RETURN NUMBER

    -----------------------------------------------------------------------
    -- Gets index of the first record in period ifac data.
    --
    -- Note:
    --     Use this function to get first from ifac_period to avoid
    --     unnecessary copying (a reference to ifac_period from outside
    --     generates a copy of ifac_period).
    ----+----------------------------------+-------------------------------
   ,MEMBER FUNCTION ifac_period_first
     RETURN NUMBER

    -----------------------------------------------------------------------
    -- Gets index of the last record in period ifac data.
    --
    -- Note:
    --     Use this function to get last from ifac_period to avoid
    --     unnecessary copying (a reference to ifac_period from outside
    --     generates a copy of ifac_period).
    ----+----------------------------------+-------------------------------
   ,MEMBER FUNCTION ifac_period_last
     RETURN NUMBER

    -----------------------------------------------------------------------
    -- Gets index of the first record in cargo ifac data.
    --
    -- Note:
    --     Use this function to get first from ifac_cargo to avoid
    --     unnecessary copying (a reference to ifac_cargo from outside
    --     generates a copy of ifac_cargo).
    ----+----------------------------------+-------------------------------
   ,MEMBER FUNCTION ifac_cargo_first
     RETURN NUMBER

    -----------------------------------------------------------------------
    -- Gets index of the last record in cargo ifac data.
    --
    -- Note:
    --     Use this function to get last from ifac_cargo to avoid
    --     unnecessary copying (a reference to ifac_cargo from outside
    --     generates a copy of ifac_cargo).
    ----+----------------------------------+-------------------------------
   ,MEMBER FUNCTION ifac_cargo_last
     RETURN NUMBER

    -----------------------------------------------------------------------
    -- Apply changes to keys (document key, transaction key, etc.)
    -- on all ifac_period items to t_ifac_sales_qty table.
    ----+----------------------------------+-------------------------------
   ,MEMBER PROCEDURE apply_ifac_period_keys

    -----------------------------------------------------------------------
    -- Apply changes to keys (document key, transaction key, etc.)
    -- on given ifac_period item to t_ifac_sales_qty table.
    ----+----------------------------------+-------------------------------
   ,MEMBER PROCEDURE apply_ifac_period_keys(
        p_index                            NUMBER
     )

    -----------------------------------------------------------------------
    -- Apply changes to keys (document key, transaction key, etc.)
    -- on given ifac_period items to t_ifac_sales_qty table.
    ----+----------------------------------+-------------------------------
   ,MEMBER PROCEDURE apply_ifac_period_keys(
        p_indexes                          T_TABLE_NUMBER
     )

    -----------------------------------------------------------------------
    -- Apply changes to keys (document key, transaction key, etc.)
    -- on given ifac_period items to t_ifac_sales_qty table.
    ----+----------------------------------+-------------------------------
   ,MEMBER PROCEDURE apply_ifac_period_keys(
        p_trans_id                         NUMBER
       ,p_li_id                            NUMBER
     )

      -----------------------------------------------------------------------
    -- Apply changes to keys (document key, transaction key, etc.)
    -- on given ifac_cargo items to t_ifac_cargo_value table.
    ----+----------------------------------+-------------------------------
   ,MEMBER PROCEDURE apply_ifac_cargo_keys

    -----------------------------------------------------------------------
    -- Apply changes to keys (document key, transaction key, etc.)
    -- on given ifac_cargo items to t_ifac_cargo_value table.
    ----+----------------------------------+-------------------------------
   ,MEMBER PROCEDURE apply_ifac_cargo_keys(
        p_index                            NUMBER
     )

    -----------------------------------------------------------------------
    -- Apply changes to keys (document key, transaction key, etc.)
    -- on given ifac_cargo items to t_ifac_cargo_value table..
    ----+----------------------------------+-------------------------------
   ,MEMBER PROCEDURE apply_ifac_cargo_keys(
        p_indexes                          T_TABLE_NUMBER
     )

    -----------------------------------------------------------------------
    -- Apply changes to keys (document key, transaction key, etc.)
    -- on given ifac_cargo items to t_ifac_cargo_value table.
    ----+----------------------------------+-------------------------------
   ,MEMBER PROCEDURE apply_ifac_cargo_keys(
        p_trans_id                         NUMBER
       ,p_li_id                            NUMBER
     )

    -----------------------------------------------------------------------
    -- Gets all preceding line keys referenced in interface (period).
    ----+----------------------------------+-------------------------------
   ,MEMBER FUNCTION get_ifac_prec_li_keys_period
    RETURN t_table_varchar2

      -----------------------------------------------------------------------
    -- Gets all preceding line keys referenced in interface (cargo).
    ----+----------------------------------+-------------------------------
   ,MEMBER FUNCTION get_ifac_prec_li_keys_cargo
    RETURN t_table_varchar2
)
;